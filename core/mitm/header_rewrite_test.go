package mitm

import (
	"net/http"
	"testing"
)

func mustHeaderRule(t *testing.T, pattern, action string, args ...string) HeaderRewriteRule {
	t.Helper()
	r, err := CompileHeaderRewrite(pattern, action, args)
	if err != nil {
		t.Fatalf("CompileHeaderRewrite(%q, %q) error: %v", pattern, action, err)
	}
	return *r
}

func TestCompileHeaderRewriteInvalidPattern(t *testing.T) {
	if _, err := CompileHeaderRewrite("([invalid", "header-del", []string{"X-A"}); err == nil {
		t.Error("expected error for invalid pattern")
	}
}

func TestApplyHeaderRewrites(t *testing.T) {
	p := &Proxy{}
	p.config.HeaderRewrites = []HeaderRewriteRule{
		mustHeaderRule(t, `^https://example\.com/`, "header-del", "X-Unwanted"),
		mustHeaderRule(t, `^https://example\.com/`, "header-add", "X-Custom: value"),
		mustHeaderRule(t, `^https://example\.com/`, "header-replace", "X-Replace: new"),
		mustHeaderRule(t, `^https://example\.com/`, "header-replace-regex", "X-Token", "secret-[0-9]+", "secret-***"),
		mustHeaderRule(t, `^https://other\.com/`, "header-del", "X-Other"),
	}

	req, _ := http.NewRequest("GET", "https://example.com/path", nil)
	req.Header.Set("X-Unwanted", "1")
	req.Header.Set("X-Replace", "old")
	req.Header.Set("X-Token", "secret-123")
	req.Header.Set("X-Other", "keep")

	p.applyHeaderRewrites(req, "https://example.com/path")

	if req.Header.Get("X-Unwanted") != "" {
		t.Error("header-del did not remove X-Unwanted")
	}
	if got := req.Header.Values("X-Custom"); len(got) != 1 || got[0] != "value" {
		t.Errorf("header-add X-Custom = %v, want [value]", got)
	}
	if got := req.Header.Get("X-Replace"); got != "new" {
		t.Errorf("header-replace X-Replace = %q, want %q", got, "new")
	}
	if got := req.Header.Get("X-Token"); got != "secret-***" {
		t.Errorf("header-replace-regex X-Token = %q, want %q", got, "secret-***")
	}
	// Rule for other.com must not fire on example.com.
	if got := req.Header.Get("X-Other"); got != "keep" {
		t.Errorf("X-Other = %q, want %q (rule pattern must not match)", got, "keep")
	}
}

func TestApplyHeaderRewritesNoMatch(t *testing.T) {
	p := &Proxy{}
	p.config.HeaderRewrites = []HeaderRewriteRule{
		mustHeaderRule(t, `^https://example\.com/`, "header-del", "X-Unwanted"),
	}
	req, _ := http.NewRequest("GET", "https://unrelated.com/", nil)
	req.Header.Set("X-Unwanted", "1")
	p.applyHeaderRewrites(req, "https://unrelated.com/")
	if got := req.Header.Get("X-Unwanted"); got != "1" {
		t.Errorf("X-Unwanted = %q, want untouched %q", got, "1")
	}
}

func TestApplyHeaderRewriteUnknownAction(t *testing.T) {
	p := &Proxy{}
	p.config.HeaderRewrites = []HeaderRewriteRule{
		mustHeaderRule(t, `^https://example\.com/`, "header-bogus", "X-A"),
	}
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	req.Header.Set("X-A", "1")
	// Must not panic; unknown actions are ignored.
	p.applyHeaderRewrites(req, "https://example.com/")
	if got := req.Header.Get("X-A"); got != "1" {
		t.Errorf("X-A = %q, want untouched %q", got, "1")
	}
}

func TestApplyHeaderRewritesSkipsResponseActions(t *testing.T) {
	p := &Proxy{}
	p.config.HeaderRewrites = []HeaderRewriteRule{
		mustHeaderRule(t, `^https://example\.com/`, "response-header-del", "X-A"),
	}
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	req.Header.Set("X-A", "1")
	p.applyHeaderRewrites(req, "https://example.com/")
	if got := req.Header.Get("X-A"); got != "1" {
		t.Errorf("X-A = %q, want untouched %q (response actions apply to responses only)", got, "1")
	}
}

func TestApplyResponseHeaderRewrites(t *testing.T) {
	p := &Proxy{}
	p.config.HeaderRewrites = []HeaderRewriteRule{
		mustHeaderRule(t, `^https://example\.com/`, "response-header-del", "X-Unwanted"),
		mustHeaderRule(t, `^https://example\.com/`, "response-header-add", "X-Custom: value"),
		mustHeaderRule(t, `^https://example\.com/`, "response-header-replace", "X-Replace: new"),
		mustHeaderRule(t, `^https://example\.com/`, "response-header-replace-regex", "X-Token", "secret-[0-9]+", "secret-***"),
		mustHeaderRule(t, `^https://example\.com/`, "header-del", "X-Request-Only"),
		mustHeaderRule(t, `^https://other\.com/`, "response-header-del", "X-Other"),
	}

	resp := &http.Response{Header: http.Header{}}
	resp.Header.Set("X-Unwanted", "1")
	resp.Header.Set("X-Replace", "old")
	resp.Header.Set("X-Token", "secret-123")
	resp.Header.Set("X-Request-Only", "keep")
	resp.Header.Set("X-Other", "keep")

	p.applyResponseHeaderRewrites(resp, "https://example.com/path")

	if resp.Header.Get("X-Unwanted") != "" {
		t.Error("response-header-del did not remove X-Unwanted")
	}
	if got := resp.Header.Values("X-Custom"); len(got) != 1 || got[0] != "value" {
		t.Errorf("response-header-add X-Custom = %v, want [value]", got)
	}
	if got := resp.Header.Get("X-Replace"); got != "new" {
		t.Errorf("response-header-replace X-Replace = %q, want %q", got, "new")
	}
	if got := resp.Header.Get("X-Token"); got != "secret-***" {
		t.Errorf("response-header-replace-regex X-Token = %q, want %q", got, "secret-***")
	}
	if got := resp.Header.Get("X-Request-Only"); got != "keep" {
		t.Errorf("X-Request-Only = %q, want untouched %q (request actions do not apply to responses)", got, "keep")
	}
	if got := resp.Header.Get("X-Other"); got != "keep" {
		t.Errorf("X-Other = %q, want untouched %q (rule pattern must not match)", got, "keep")
	}
}

func TestApplyResponseHeaderRewritesUnknownAction(t *testing.T) {
	p := &Proxy{}
	p.config.HeaderRewrites = []HeaderRewriteRule{
		mustHeaderRule(t, `^https://example\.com/`, "response-header-bogus", "X-A"),
	}
	resp := &http.Response{Header: http.Header{}}
	resp.Header.Set("X-A", "1")
	// Must not panic; unknown response actions are ignored.
	p.applyResponseHeaderRewrites(resp, "https://example.com/")
	if got := resp.Header.Get("X-A"); got != "1" {
		t.Errorf("X-A = %q, want untouched %q", got, "1")
	}
}

func TestResponseHeaderRewriteEndToEnd(t *testing.T) {
	p := &Proxy{
		config: Config{Enabled: true, HeaderRewrites: []HeaderRewriteRule{
			mustHeaderRule(t, `^http://example\.com/`, "response-header-del", "X-Upstream-Secret"),
			mustHeaderRule(t, `^http://example\.com/`, "response-header-add", "X-Added: yes"),
		}},
		scripts: NewScriptRegistry(),
	}
	p.testTransport = stubRT{fn: func(r *http.Request) (*http.Response, error) {
		h := http.Header{}
		h.Set("X-Upstream-Secret", "s3cr3t")
		h.Set("X-Keep", "1")
		return cannedResponse(200, h, "ok", 2), nil
	}}
	h := newPipeHarness(t, p, false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if got := resp.Header.Get("X-Upstream-Secret"); got != "" {
		t.Errorf("X-Upstream-Secret = %q, want deleted", got)
	}
	if got := resp.Header.Get("X-Added"); got != "yes" {
		t.Errorf("X-Added = %q, want %q", got, "yes")
	}
	if got := resp.Header.Get("X-Keep"); got != "1" {
		t.Errorf("X-Keep = %q, want untouched %q", got, "1")
	}
	if got := readBodyString(t, resp); got != "ok" {
		t.Errorf("body = %q, want %q", got, "ok")
	}
}
