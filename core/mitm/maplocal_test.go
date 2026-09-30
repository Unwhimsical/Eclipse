package mitm

import (
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func mustCompileMapLocal(t *testing.T, pattern, dataType, data string, status int, headers map[string]string) *MapLocalRule {
	t.Helper()
	r, err := CompileMapLocal(pattern, dataType, data, status, headers)
	if err != nil {
		t.Fatalf("CompileMapLocal: %v", err)
	}
	return r
}

func TestCompileMapLocalValidation(t *testing.T) {
	if _, err := CompileMapLocal("([", "text", "x", 200, nil); err == nil {
		t.Error("expected error for invalid pattern")
	}
	if _, err := CompileMapLocal("^https://a", "yaml", "x", 200, nil); err == nil {
		t.Error("expected error for unknown data type")
	}
	r, err := CompileMapLocal("^https://a", "", "x", 0, nil)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if r.DataType != "text" || r.StatusCode != 200 {
		t.Errorf("defaults not applied: %+v", r)
	}
}

func TestApplyMapLocalText(t *testing.T) {
	p := &Proxy{config: Config{Enabled: true}, scripts: NewScriptRegistry()}
	p.config.MapLocal = []MapLocalRule{
		*mustCompileMapLocal(t, `^https://track\.example\.com`, "text", "blocked", 200, map[string]string{"X-ML": "1"}),
	}
	res := p.applyMapLocal("https://track.example.com/pixel.gif")
	if res == nil {
		t.Fatal("expected a map-local result")
	}
	if res.Status != 200 || string(res.Body) != "blocked" {
		t.Errorf("unexpected result: %+v", res)
	}
	if res.Headers["X-ML"] != "1" {
		t.Errorf("extra header lost: %v", res.Headers)
	}
	if res.Headers["Content-Type"] != "text/plain; charset=utf-8" {
		t.Errorf("unexpected content type: %v", res.Headers)
	}
	if p.applyMapLocal("https://other.example.com/") != nil {
		t.Error("expected nil for non-matching URL")
	}
}

func TestApplyMapLocalBase64(t *testing.T) {
	p := &Proxy{config: Config{Enabled: true}, scripts: NewScriptRegistry()}
	p.config.MapLocal = []MapLocalRule{
		*mustCompileMapLocal(t, `^https://b\.example\.com`, "base64", "aGVsbG8=", 200, nil),
		*mustCompileMapLocal(t, `^https://bad\.example\.com`, "base64", "!!!not-base64!!!", 200, nil),
	}
	res := p.applyMapLocal("https://b.example.com/x")
	if res == nil || string(res.Body) != "hello" {
		t.Errorf("base64 not decoded: %+v", res)
	}
	// Invalid base64 fails open: no synthesized response.
	if p.applyMapLocal("https://bad.example.com/x") != nil {
		t.Error("expected fail-open nil for invalid base64")
	}
}

func TestApplyMapLocalTinyGif(t *testing.T) {
	p := &Proxy{config: Config{Enabled: true}, scripts: NewScriptRegistry()}
	p.config.MapLocal = []MapLocalRule{
		*mustCompileMapLocal(t, `\.gif$`, "tiny-gif", "", 200, nil),
	}
	res := p.applyMapLocal("https://ads.example.com/pixel.gif")
	if res == nil {
		t.Fatal("expected a map-local result")
	}
	if res.Headers["Content-Type"] != "image/gif" {
		t.Errorf("unexpected content type: %v", res.Headers)
	}
	if string(res.Body) != string(rejectImg) {
		t.Error("tiny-gif body is not the 1x1 GIF")
	}
}

func TestApplyMapLocalFile(t *testing.T) {
	dir := t.TempDir()
	fp := filepath.Join(dir, "mock.json")
	if err := os.WriteFile(fp, []byte(`{"mock":true}`), 0644); err != nil {
		t.Fatal(err)
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"remote":true}`))
	}))
	defer srv.Close()

	p := &Proxy{config: Config{Enabled: true}, scripts: NewScriptRegistry()}
	p.config.MapLocal = []MapLocalRule{
		*mustCompileMapLocal(t, `^https://local\.example\.com`, "file", fp, 200, nil),
		*mustCompileMapLocal(t, `^https://remote\.example\.com`, "file", srv.URL+"/data", 200, nil),
		*mustCompileMapLocal(t, `^https://missing\.example\.com`, "file", filepath.Join(dir, "nope.json"), 200, nil),
	}
	res := p.applyMapLocal("https://local.example.com/api")
	if res == nil || string(res.Body) != `{"mock":true}` {
		t.Errorf("local file not served: %+v", res)
	}
	res = p.applyMapLocal("https://remote.example.com/api")
	if res == nil || string(res.Body) != `{"remote":true}` {
		t.Errorf("remote file not fetched: %+v", res)
	}
	if res != nil && res.Headers["Content-Type"] != "application/json" {
		t.Errorf("remote content type not propagated: %v", res.Headers)
	}
	// Missing file fails open.
	if p.applyMapLocal("https://missing.example.com/api") != nil {
		t.Error("expected fail-open nil for missing file")
	}
}

func TestMapLocalEndToEnd(t *testing.T) {
	upstreamHit := false
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		upstreamHit = true
		return &http.Response{
			StatusCode:    200,
			Header:        http.Header{"Content-Type": []string{"text/plain"}},
			Body:          io.NopCloser(strings.NewReader("upstream")),
			ContentLength: 8,
		}, nil
	}}
	p := newFramingProxy(rt)
	p.config.MapLocal = []MapLocalRule{
		*mustCompileMapLocal(t, `^https://ads\.example\.com`, "text", "ad-blocked", 200, nil),
		*mustCompileMapLocal(t, `^https://empty\.example\.com`, "text", "", 204, nil),
	}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET https://ads.example.com/banner.js HTTP/1.1\r\nHost: ads.example.com\r\n\r\n")
	body := readBodyString(t, resp)
	if resp.StatusCode != 200 || body != "ad-blocked" {
		t.Errorf("map-local response wrong: %d %q", resp.StatusCode, body)
	}
	if resp.ContentLength != int64(len("ad-blocked")) {
		t.Errorf("map-local framing wrong: ContentLength=%d", resp.ContentLength)
	}
	if upstreamHit {
		t.Error("upstream must not be contacted for map-local URLs")
	}

	// Non-matching URL goes upstream.
	resp = h.do("GET https://other.example.com/ HTTP/1.1\r\nHost: other.example.com\r\n\r\n")
	body = readBodyString(t, resp)
	if body != "upstream" || !upstreamHit {
		t.Errorf("non-matching URL not forwarded: hit=%v body=%q", upstreamHit, body)
	}

	// 204 carries no body but keeps explicit framing.
	resp = h.do("GET https://empty.example.com/ HTTP/1.1\r\nHost: empty.example.com\r\n\r\n")
	if resp.StatusCode != 204 {
		t.Errorf("expected 204, got %d", resp.StatusCode)
	}
	body = readBodyString(t, resp)
	if body != "" {
		t.Errorf("204 must have no body, got %q", body)
	}
}
