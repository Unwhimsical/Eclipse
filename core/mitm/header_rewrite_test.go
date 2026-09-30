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
