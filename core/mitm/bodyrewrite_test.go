package mitm

import (
	"bytes"
	"io"
	"net/http"
	"strings"
	"testing"
)

func mustCompileBodyRewrite(t *testing.T, typ, pattern, regex, replace, jq string) *BodyRewriteRule {
	t.Helper()
	r, err := CompileBodyRewrite(typ, pattern, regex, replace, jq)
	if err != nil {
		t.Fatalf("CompileBodyRewrite: %v", err)
	}
	return r
}

func TestCompileBodyRewriteValidation(t *testing.T) {
	if _, err := CompileBodyRewrite("http-ftp", "^https://a", "", "", ""); err == nil {
		t.Error("expected error for unknown type")
	}
	if _, err := CompileBodyRewrite("http-response", "([", "", "", ""); err == nil {
		t.Error("expected error for invalid URL pattern")
	}
	if _, err := CompileBodyRewrite("http-response", "^https://a", "([", "x", ""); err == nil {
		t.Error("expected error for invalid body regex")
	}
	if _, err := CompileBodyRewrite("http-response-jq", "^https://a", "", "", ".a | |"); err == nil {
		t.Error("expected error for invalid jq expression")
	}
	r, err := CompileBodyRewrite("http-request-jq", "^https://a", "", "", ".a = 1")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !r.forRequest() || r.forResponse() {
		t.Error("direction flags wrong for http-request-jq")
	}
}

func TestBodyRewriteJQ(t *testing.T) {
	r := mustCompileBodyRewrite(t, "http-response-jq", `^https://api\.example\.com`, "", "", `.user.name = "pig" | del(.secret)`)

	out, changed := r.apply([]byte(`{"user":{"name":"x"},"secret":1}`))
	if !changed {
		t.Fatal("expected a change")
	}
	if !strings.Contains(string(out), `"name":"pig"`) || strings.Contains(string(out), "secret") {
		t.Errorf("jq transform wrong: %s", out)
	}

	// Non-JSON body fails open.
	out, changed = r.apply([]byte(`not json`))
	if changed || string(out) != "not json" {
		t.Errorf("non-JSON must fail open: changed=%v %q", changed, out)
	}

	// jq runtime error fails open (indexing a number).
	bad := mustCompileBodyRewrite(t, "http-response-jq", `^https://api\.example\.com`, "", "", `.a.b`)
	out, changed = bad.apply([]byte(`{"a":1}`))
	if changed {
		t.Errorf("jq error must fail open, got %q", out)
	}

	// Nested construction keeps valid JSON.
	nest := mustCompileBodyRewrite(t, "http-request-jq", `^https://api\.example\.com`, "", "", `{wrapped: .}`)
	out, changed = nest.apply([]byte(`[1,2]`))
	if !changed || string(out) != `{"wrapped":[1,2]}` {
		t.Errorf("jq construction wrong: changed=%v %q", changed, out)
	}
}

func TestBodyRewriteRegex(t *testing.T) {
	r := mustCompileBodyRewrite(t, "http-response", `^https://ad\.example\.com`, `banner\d+`, "REPLACED", "")

	out, changed := r.apply([]byte(`<div>banner123</div><div>banner456</div>`))
	if !changed {
		t.Fatal("expected a change")
	}
	if string(out) != `<div>REPLACED</div><div>REPLACED</div>` {
		t.Errorf("regex replace wrong: %s", out)
	}
	if _, changed := r.apply([]byte(`nothing here`)); changed {
		t.Error("no match must report unchanged")
	}
}

func TestRequestBodyRewriteEndToEnd(t *testing.T) {
	var gotBody string
	var gotLen int64
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		b, _ := io.ReadAll(r.Body)
		gotBody, gotLen = string(b), r.ContentLength
		return &http.Response{
			StatusCode:    200,
			Header:        http.Header{"Content-Type": []string{"text/plain"}},
			Body:          io.NopCloser(strings.NewReader("ok")),
			ContentLength: 2,
		}, nil
	}}
	p := newFramingProxy(rt)
	p.config.BodyRewrites = []BodyRewriteRule{
		*mustCompileBodyRewrite(t, "http-request-jq", `^https://api\.example\.com/login`, "", "", `.password = "***"`),
	}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	rawBody := `{"user":"u","password":"hunter2"}`
	raw := "POST https://api.example.com/login HTTP/1.1\r\n" +
		"Host: api.example.com\r\n" +
		"Content-Type: application/json\r\n" +
		"Content-Length: 33\r\n" +
		"\r\n" +
		rawBody
	resp := h.do(raw)
	_ = readBodyString(t, resp)
	if len(rawBody) != 33 {
		t.Fatalf("test body length changed: %d", len(rawBody))
	}
	if !strings.Contains(gotBody, `"password":"***"`) || strings.Contains(gotBody, "hunter2") {
		t.Errorf("request body not rewritten upstream: %q", gotBody)
	}
	if gotLen != int64(len(gotBody)) {
		t.Errorf("ContentLength not synced: %d vs %d", gotLen, len(gotBody))
	}
}

func TestResponseBodyRewriteEndToEnd(t *testing.T) {
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		const upstream = `{"data":"x","ads":[{"id":1}]}`
		return &http.Response{
			StatusCode:    200,
			Header:        http.Header{"Content-Type": []string{"application/json"}},
			Body:          io.NopCloser(strings.NewReader(upstream)),
			ContentLength: int64(len(upstream)),
		}, nil
	}}
	p := newFramingProxy(rt)
	p.config.BodyRewrites = []BodyRewriteRule{
		*mustCompileBodyRewrite(t, "http-response-jq", `^https://api\.example\.com/feed`, "", "", `del(.ads)`),
		*mustCompileBodyRewrite(t, "http-response", `^https://static\.example\.com`, `evil`, "good", ""),
	}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET https://api.example.com/feed HTTP/1.1\r\nHost: api.example.com\r\n\r\n")
	body := readBodyString(t, resp)
	if strings.Contains(body, "ads") || !strings.Contains(body, `"data":"x"`) {
		t.Errorf("response jq rewrite wrong: %q", body)
	}
	if resp.ContentLength != int64(len(body)) {
		t.Errorf("framing not fixed after rewrite: ContentLength=%d body=%d", resp.ContentLength, len(body))
	}
}

func TestResponseBodyRewriteNoMatchStreams(t *testing.T) {
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		return &http.Response{
			StatusCode:    200,
			Header:        http.Header{"Content-Type": []string{"text/plain"}},
			Body:          io.NopCloser(strings.NewReader("plain")),
			ContentLength: 5,
		}, nil
	}}
	p := newFramingProxy(rt)
	p.config.BodyRewrites = []BodyRewriteRule{
		*mustCompileBodyRewrite(t, "http-response-jq", `^https://other\.example\.com`, "", "", `del(.x)`),
	}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET https://api.example.com/feed HTTP/1.1\r\nHost: api.example.com\r\n\r\n")
	if body := readBodyString(t, resp); body != "plain" {
		t.Errorf("non-matching URL must stream untouched: %q", body)
	}
}

func TestDrainBodyOversizeRestores(t *testing.T) {
	src := io.MultiReader(strings.NewReader("abc"), strings.NewReader("def"))
	body, restore := drainBody(src, 2)
	if body != nil || restore == nil {
		t.Fatal("expected restore reader for oversized input")
	}
	restored, err := io.ReadAll(restore)
	if err != nil || string(restored) != "abcdef" {
		t.Errorf("stream not restored intact: %q err=%v", restored, err)
	}
	body, restore = drainBody(strings.NewReader("ab"), 10)
	if restore != nil || string(body) != "ab" {
		t.Errorf("small body must be returned directly: %q", body)
	}
}

func TestOversizedBodiesSkipRewrite(t *testing.T) {
	big := bytes.Repeat([]byte("x"), int(maxBodyRewriteSize)+1024)
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		return &http.Response{
			StatusCode:    200,
			Header:        http.Header{"Content-Type": []string{"application/json"}},
			Body:          io.NopCloser(bytes.NewReader(big)),
			ContentLength: int64(len(big)),
		}, nil
	}}
	p := newFramingProxy(rt)
	p.config.BodyRewrites = []BodyRewriteRule{
		*mustCompileBodyRewrite(t, "http-response-jq", `^https://big\.example\.com`, "", "", `.a = 1`),
	}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET https://big.example.com/data HTTP/1.1\r\nHost: big.example.com\r\n\r\n")
	body := readBodyString(t, resp)
	if len(body) != len(big) {
		t.Errorf("oversized body must pass through untouched: got %d bytes", len(body))
	}
}
