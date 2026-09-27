package mitm

import (
	"io"
	"net/http"
	"regexp"
	"strconv"
	"strings"
)

// RewriteAction is the result of matching a rewrite rule.
type RewriteAction struct {
	Kind   string // "redirect", "reject", "reject-dict", "reject-200", "reject-img", "reject-video"
	Target string
	Status int
}

func (a *RewriteAction) writeTo(conn interface {
	Write([]byte) (int, error)
}, req *http.Request) {
	// Implemented via http.Response for simplicity by caller.
}

// applyRewrite matches the request URL against rewrite rules.
// Returns nil when no rule matches.
func (p *Proxy) applyRewrite(req *http.Request) *http.Response {
	rawURL := req.URL.String()
	if req.URL.IsAbs() == false && req.Host != "" {
		scheme := "http"
		if req.TLS != nil {
			scheme = "https"
		}
		rawURL = scheme + "://" + req.Host + req.URL.RequestURI()
	}
	p.mu.RLock()
	rules := p.config.Rewrites
	p.mu.RUnlock()
	for _, rule := range rules {
		re, err := regexp.Compile(rule.Pattern)
		if err != nil {
			continue
		}
		if !re.MatchString(rawURL) {
			continue
		}
		return buildRewriteResponse(rule, re, rawURL, req)
	}
	return nil
}

func buildRewriteResponse(rule RewriteRule, re *regexp.Regexp, rawURL string, req *http.Request) *http.Response {
	target := rule.Target
	status := rule.Status
	upper := strings.ToUpper(status)

	// Expand $1, $2 captures in target.
	if strings.Contains(target, "$") {
		target = re.ReplaceAllString(rawURL, target)
	}

	switch {
	case upper == "REJECT", upper == "REJECT-DROP":
		return textResponse(req, 502, "Rejected")
	case upper == "REJECT-DICT":
		return jsonResponse(req, `{"code":-1,"message":"rejected"}`)
	case upper == "REJECT-200":
		return textResponse(req, 200, "")
	case upper == "REJECT-IMG":
		return textResponse(req, 200, "")
	case upper == "REJECT-VIDEO":
		return textResponse(req, 200, "")
	case upper == "_":
		// "_" target means block.
		return textResponse(req, 502, "Rejected")
	case target == "" || target == "_":
		return textResponse(req, 502, "Rejected")
	default:
		code := 302
		if n, err := strconv.Atoi(status); err == nil && (n == 301 || n == 302 || n == 307 || n == 308) {
			code = n
		}
		resp := textResponse(req, code, "")
		resp.Header.Set("Location", target)
		return resp
	}
}

func textResponse(req *http.Request, code int, body string) *http.Response {
	return &http.Response{
		StatusCode: code,
		ProtoMajor: 1,
		ProtoMinor: 1,
		Header:     make(http.Header),
		Body:       io.NopCloser(strings.NewReader(body)),
		Request:    req,
	}
}

func jsonResponse(req *http.Request, body string) *http.Response {
	resp := textResponse(req, 200, body)
	resp.Header.Set("Content-Type", "application/json")
	return resp
}

// ParseRewriteLine parses one `[URL Rewrite]` line:
// `<pattern> <target> [status]`
func ParseRewriteLine(line string) *RewriteRule {
	parts := strings.Fields(line)
	if len(parts) < 2 {
		return nil
	}
	rule := &RewriteRule{
		Pattern: parts[0],
		Target:  parts[1],
		Status:  "302",
	}
	if len(parts) >= 3 {
		rule.Status = parts[2]
	}
	return rule
}
