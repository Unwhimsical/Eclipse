package mitm

import (
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

// maxMapLocalFileSize caps file responses; larger files fail open upstream.
const maxMapLocalFileSize = 10 * 1024 * 1024

// MapLocalRule mirrors Shadowrocket's [Map Local] section.
type MapLocalRule struct {
	Pattern    string
	DataType   string // text | file | tiny-gif | base64
	Data       string
	StatusCode int
	Headers    map[string]string
	re         *regexp.Regexp
}

type MapLocalResult struct {
	Status  int
	Headers map[string]string
	Body    []byte
}

func CompileMapLocal(pattern, dataType, data string, statusCode int, headers map[string]string) (*MapLocalRule, error) {
	re, err := regexp.Compile(pattern)
	if err != nil {
		return nil, fmt.Errorf("mitm: invalid map-local pattern %q: %w", pattern, err)
	}
	if dataType == "" {
		dataType = "text"
	}
	switch dataType {
	case "text", "file", "tiny-gif", "base64":
	default:
		return nil, fmt.Errorf("mitm: unknown map-local data type %q", dataType)
	}
	if statusCode <= 0 {
		statusCode = http.StatusOK
	}
	return &MapLocalRule{
		Pattern:    pattern,
		DataType:   dataType,
		Data:       data,
		StatusCode: statusCode,
		Headers:    headers,
		re:         re,
	}, nil
}

func (p *Proxy) applyMapLocal(urlStr string) *MapLocalResult {
	p.mu.RLock()
	rules := p.config.MapLocal
	p.mu.RUnlock()
	for i := range rules {
		if !rules[i].re.MatchString(urlStr) {
			continue
		}
		if res := rules[i].build(); res != nil {
			return res
		}
	}
	return nil
}

func (r *MapLocalRule) build() *MapLocalResult {
	res := &MapLocalResult{Status: r.StatusCode, Headers: map[string]string{}}
	for k, v := range r.Headers {
		res.Headers[k] = v
	}
	setContentType := func(ct string) {
		if _, ok := res.Headers["Content-Type"]; !ok {
			res.Headers["Content-Type"] = ct
		}
	}
	switch r.DataType {
	case "tiny-gif":
		setContentType("image/gif")
		res.Body = rejectImg
	case "base64":
		raw, err := base64.StdEncoding.DecodeString(strings.TrimSpace(r.Data))
		if err != nil {
			raw, err = base64.URLEncoding.DecodeString(strings.TrimSpace(r.Data))
		}
		if err != nil {
			return nil
		}
		setContentType("application/octet-stream")
		res.Body = raw
	case "file":
		raw, ctype, ok := loadMapLocalFile(r.Data)
		if !ok {
			return nil
		}
		if ctype != "" {
			setContentType(ctype)
		} else {
			setContentType("application/octet-stream")
		}
		res.Body = raw
	default: // text
		setContentType("text/plain; charset=utf-8")
		res.Body = []byte(r.Data)
	}
	return res
}

func loadMapLocalFile(ref string) (body []byte, contentType string, ok bool) {
	ref = strings.TrimSpace(ref)
	if ref == "" {
		return nil, "", false
	}
	if strings.HasPrefix(ref, "http://") || strings.HasPrefix(ref, "https://") {
		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Get(ref)
		if err != nil || resp.StatusCode != http.StatusOK {
			if resp != nil {
				resp.Body.Close()
			}
			return nil, "", false
		}
		defer resp.Body.Close()
		body, ok = readCapped(resp.Body, maxMapLocalFileSize)
		if !ok {
			return nil, "", false
		}
		return body, resp.Header.Get("Content-Type"), true
	}
	raw, err := os.ReadFile(ref)
	if err != nil || len(raw) > maxMapLocalFileSize {
		return nil, "", false
	}
	return raw, http.DetectContentType(raw), true
}

func readCapped(r io.Reader, max int64) (body []byte, ok bool) {
	b, err := io.ReadAll(io.LimitReader(r, max+1))
	if err != nil || int64(len(b)) > max {
		return nil, false
	}
	return b, true
}

func writeMapLocalResult(w http.ResponseWriter, req *http.Request, res *MapLocalResult) {
	for k, v := range res.Headers {
		w.Header().Set(k, v)
	}
	// Explicit framing: a synthesized response must never leave a keep-alive
	// client waiting for a body that will not come.
	w.Header().Set("Content-Length", fmt.Sprintf("%d", len(res.Body)))
	w.WriteHeader(res.Status)
	if responseHasBody(res.Status, req.Method) {
		_, _ = w.Write(res.Body)
	}
}
