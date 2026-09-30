package mitm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/itchyny/gojq"
)

// maxBodyRewriteSize caps buffered bodies; larger ones skip rewriting (fail-open).
const maxBodyRewriteSize = 10 * 1024 * 1024

// bodyRewriteTimeout bounds one jq evaluation; a pathological query fails open.
const bodyRewriteTimeout = 5 * time.Second

// BodyRewriteRule mirrors Shadowrocket's [Body Rewrite] section.
type BodyRewriteRule struct {
	Type    string // http-request | http-response | http-request-jq | http-response-jq
	Pattern string
	Regex   string
	Replace string
	JQ      string
	re      *regexp.Regexp
	rx      *regexp.Regexp
	jqCode  *gojq.Code
	isJQ    bool
}

func CompileBodyRewrite(typ, pattern, regex, replace, jqExpr string) (*BodyRewriteRule, error) {
	switch typ {
	case "http-request", "http-response", "http-request-jq", "http-response-jq":
	default:
		return nil, fmt.Errorf("mitm: unknown body-rewrite type %q", typ)
	}
	re, err := regexp.Compile(pattern)
	if err != nil {
		return nil, fmt.Errorf("mitm: invalid body-rewrite pattern %q: %w", pattern, err)
	}
	r := &BodyRewriteRule{Type: typ, Pattern: pattern, Regex: regex, Replace: replace, JQ: jqExpr, re: re}
	if strings.HasSuffix(typ, "-jq") {
		q, err := gojq.Parse(jqExpr)
		if err != nil {
			return nil, fmt.Errorf("mitm: invalid jq expression %q: %w", jqExpr, err)
		}
		code, err := gojq.Compile(q)
		if err != nil {
			return nil, fmt.Errorf("mitm: cannot compile jq expression %q: %w", jqExpr, err)
		}
		r.jqCode = code
		r.isJQ = true
	} else {
		rx, err := regexp.Compile(regex)
		if err != nil {
			return nil, fmt.Errorf("mitm: invalid body-rewrite regex %q: %w", regex, err)
		}
		r.rx = rx
	}
	return r, nil
}

func (r *BodyRewriteRule) forRequest() bool {
	return r.Type == "http-request" || r.Type == "http-request-jq"
}

func (r *BodyRewriteRule) forResponse() bool {
	return r.Type == "http-response" || r.Type == "http-response-jq"
}

func (r *BodyRewriteRule) apply(body []byte) ([]byte, bool) {
	if r.isJQ {
		return r.applyJQ(body)
	}
	if !r.rx.Match(body) {
		return body, false
	}
	return r.rx.ReplaceAll(body, []byte(r.Replace)), true
}

func (r *BodyRewriteRule) applyJQ(body []byte) ([]byte, bool) {
	var v any
	if err := json.Unmarshal(body, &v); err != nil {
		return body, false
	}
	ctx, cancel := context.WithTimeout(context.Background(), bodyRewriteTimeout)
	defer cancel()
	iter := r.jqCode.RunWithContext(ctx, v)
	out, ok := iter.Next()
	if !ok {
		return body, false
	}
	if jerr, ok := out.(error); ok && jerr != nil {
		return body, false
	}
	nb, err := json.Marshal(normalizeJqValue(out))
	if err != nil {
		return body, false
	}
	return nb, true
}

func normalizeJqValue(v any) any {
	switch n := v.(type) {
	case *big.Int:
		if n.IsInt64() {
			return n.Int64()
		}
		f, _ := new(big.Float).SetInt(n).Float64()
		return f
	case []any:
		for i, e := range n {
			n[i] = normalizeJqValue(e)
		}
		return n
	case map[string]any:
		for k, e := range n {
			n[k] = normalizeJqValue(e)
		}
		return n
	default:
		return v
	}
}

func (p *Proxy) matchingBodyRewriteRules(urlStr string, request bool) []*BodyRewriteRule {
	p.mu.RLock()
	rules := p.config.BodyRewrites
	p.mu.RUnlock()
	var matched []*BodyRewriteRule
	for i := range rules {
		r := &rules[i]
		if request != r.forRequest() || !r.re.MatchString(urlStr) {
			continue
		}
		matched = append(matched, r)
	}
	return matched
}

// drainBody reads up to max bytes. On oversize/unreadable it returns a reader
// chaining the buffered prefix back onto the remainder, so the caller can
// restore the stream untouched (fail-open).
func drainBody(r io.Reader, max int64) (body []byte, restore io.Reader) {
	var buf bytes.Buffer
	n, err := io.CopyN(&buf, r, max+1)
	if (err != nil && err != io.EOF) || n > max {
		return nil, io.MultiReader(&buf, r)
	}
	return buf.Bytes(), nil
}

func (p *Proxy) applyRequestBodyRewrites(urlStr string, req *http.Request) {
	matched := p.matchingBodyRewriteRules(urlStr, true)
	if len(matched) == 0 || req.Body == nil {
		return
	}
	if req.ContentLength > maxBodyRewriteSize {
		return
	}
	body, restore := drainBody(req.Body, maxBodyRewriteSize)
	if restore != nil {
		req.Body = io.NopCloser(restore)
		return
	}
	_ = req.Body.Close()
	for _, r := range matched {
		if nb, changed := r.apply(body); changed {
			body = nb
		}
	}
	req.Body = io.NopCloser(bytes.NewReader(body))
	req.ContentLength = int64(len(body))
	req.Header.Set("Content-Length", strconv.Itoa(len(body)))
}

// applyResponseBodyRewrites returns the rewritten body and true on URL match.
// A true return means resp.Body is consumed: write the bytes with explicit
// framing and do not copy from resp.Body. False leaves it untouched.
func (p *Proxy) applyResponseBodyRewrites(urlStr string, resp *http.Response, src []byte, haveSrc bool) ([]byte, bool) {
	matched := p.matchingBodyRewriteRules(urlStr, false)
	if len(matched) == 0 {
		return nil, false
	}
	if !haveSrc {
		if resp.ContentLength > maxBodyRewriteSize {
			return nil, false
		}
		body, restore := drainBody(resp.Body, maxBodyRewriteSize)
		if restore != nil {
			resp.Body = io.NopCloser(restore)
			return nil, false
		}
		_ = resp.Body.Close()
		src = body
	}
	body := src
	for _, r := range matched {
		if nb, changed := r.apply(body); changed {
			body = nb
		}
	}
	return body, true
}
