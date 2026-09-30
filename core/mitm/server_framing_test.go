package mitm

import (
	"bufio"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"testing"
	"time"
)

// stubRT is an http.RoundTripper that returns canned upstream responses,
// standing in for the mihomo dialUpstream path in tests.
type stubRT struct {
	fn func(*http.Request) (*http.Response, error)
}

func (s stubRT) RoundTrip(r *http.Request) (*http.Response, error) { return s.fn(r) }

func newFramingProxy(rt http.RoundTripper) *Proxy {
	p := &Proxy{config: Config{Enabled: true}, scripts: NewScriptRegistry()}
	p.testTransport = rt
	return p
}

// pipeHarness drives p.handleHTTP over a net.Pipe with a keep-alive read loop
// on the server side, mirroring handleConnect's per-connection loop.
type pipeHarness struct {
	t    *testing.T
	conn net.Conn
	br   *bufio.Reader
}

func newPipeHarness(t *testing.T, p *Proxy, isTLS bool) *pipeHarness {
	t.Helper()
	cc, sc := net.Pipe()
	deadline := time.Now().Add(10 * time.Second)
	_ = cc.SetDeadline(deadline)
	_ = sc.SetDeadline(deadline)
	go func() {
		defer sc.Close()
		br := bufio.NewReader(sc)
		for {
			req, err := http.ReadRequest(br)
			if err != nil {
				return
			}
			p.handleHTTP(sc, req, isTLS)
			if req.Close {
				return
			}
		}
	}()
	return &pipeHarness{t: t, conn: cc, br: bufio.NewReader(cc)}
}

func (h *pipeHarness) do(rawReq string) *http.Response {
	h.t.Helper()
	if _, err := io.WriteString(h.conn, rawReq); err != nil {
		h.t.Fatalf("write request: %v", err)
	}
	dummy, _ := http.NewRequest("GET", "http://example.com/", nil)
	if strings.HasPrefix(rawReq, "HEAD ") {
		dummy, _ = http.NewRequest("HEAD", "http://example.com/", nil)
	}
	resp, err := http.ReadResponse(h.br, dummy)
	if err != nil {
		h.t.Fatalf("read response: %v", err)
	}
	return resp
}

func readBodyString(t *testing.T, resp *http.Response) string {
	t.Helper()
	defer resp.Body.Close()
	b, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("read body: %v", err)
	}
	return string(b)
}

func cannedResponse(status int, header http.Header, body string, contentLength int64) *http.Response {
	return &http.Response{
		Status:        fmt.Sprintf("%d %s", status, http.StatusText(status)),
		StatusCode:    status,
		Header:        header,
		Body:          io.NopCloser(strings.NewReader(body)),
		ContentLength: contentLength,
		Request:       &http.Request{Method: "GET"},
	}
}

func TestFramingContentLengthPassthrough(t *testing.T) {
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		h := http.Header{"Content-Length": {"11"}, "X-Custom-Header": {"v"}}
		return cannedResponse(200, h, "hello world", 11), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp.StatusCode != 200 {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	if got := readBodyString(t, resp); got != "hello world" {
		t.Errorf("body = %q, want %q", got, "hello world")
	}
	if got := resp.Header.Get("Content-Length"); got != "11" {
		t.Errorf("Content-Length = %q, want 11", got)
	}
	// Keep-alive: a second request on the same connection must work.
	resp2 := h.do("GET http://example.com/again HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp2.StatusCode != 200 {
		t.Errorf("second status = %d, want 200", resp2.StatusCode)
	}
	if got := readBodyString(t, resp2); got != "hello world" {
		t.Errorf("second body = %q", got)
	}
}

func TestFramingChunkedUpstream(t *testing.T) {
	// Upstream used chunked encoding: Go de-chunks, ContentLength is unknown.
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		return cannedResponse(200, http.Header{}, "chunked-body-data", -1), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if got := readBodyString(t, resp); got != "chunked-body-data" {
		t.Errorf("body = %q, want %q", got, "chunked-body-data")
	}
	// Keep-alive reuse must still work: without valid framing the client
	// would hang waiting for EOF and the second request would never run.
	resp2 := h.do("GET http://example.com/again HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if got := readBodyString(t, resp2); got != "chunked-body-data" {
		t.Errorf("second body = %q", got)
	}
}

func TestFramingChunkedUpstreamLarge(t *testing.T) {
	big := strings.Repeat("0123456789abcdef", 4096) // 64KB streamed, not buffered
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		return cannedResponse(200, http.Header{}, big, -1), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/big HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if got := readBodyString(t, resp); got != big {
		t.Errorf("large body mismatch: got %d bytes, want %d", len(got), len(big))
	}
}

func TestFramingRewriteRejectJSON(t *testing.T) {
	rule, err := CompileRewrite(`example\.com/blocked`, "reject-json", "", 200)
	if err != nil {
		t.Fatal(err)
	}
	p := newFramingProxy(stubRT{fn: func(r *http.Request) (*http.Response, error) {
		t.Error("upstream must not be hit for a rejected URL")
		return nil, fmt.Errorf("unreachable")
	}})
	p.config.Rewrites = []RewriteRule{*rule}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET /blocked HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp.StatusCode != 200 {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	if got := readBodyString(t, resp); got != "{}" {
		t.Errorf("body = %q, want {}", got)
	}
	if ct := resp.Header.Get("Content-Type"); ct != "application/json" {
		t.Errorf("Content-Type = %q", ct)
	}
	// Connection must stay usable afterwards.
	resp2 := h.do("GET /blocked HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if got := readBodyString(t, resp2); got != "{}" {
		t.Errorf("second body = %q", got)
	}
}

func TestFramingRewriteRedirect(t *testing.T) {
	rule, err := CompileRewrite(`^https://example\.com/old$`, "redirect", "https://example.com/new", 302)
	if err != nil {
		t.Fatal(err)
	}
	p := newFramingProxy(stubRT{fn: func(r *http.Request) (*http.Response, error) {
		t.Error("upstream must not be hit for a redirect")
		return nil, fmt.Errorf("unreachable")
	}})
	p.config.Rewrites = []RewriteRule{*rule}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET /old HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp.StatusCode != 302 {
		t.Fatalf("status = %d, want 302", resp.StatusCode)
	}
	if got := resp.Header.Get("Location"); got != "https://example.com/new" {
		t.Errorf("Location = %q", got)
	}
	if got := readBodyString(t, resp); got != "" {
		t.Errorf("redirect body = %q, want empty", got)
	}
	resp2 := h.do("GET /old HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp2.StatusCode != 302 {
		t.Errorf("second status = %d, want 302", resp2.StatusCode)
	}
	_ = readBodyString(t, resp2)
}

func TestFramingScriptSynthStatusOnly(t *testing.T) {
	p := &Proxy{config: Config{Enabled: true}, scripts: NewScriptRegistry()}
	p.scripts.Set([]*Script{{
		Name:       "s.js",
		Type:       "http-request",
		TimeoutSec: 5,
		Content:    `$done({response: {status: 403}});`,
	}})
	p.testTransport = stubRT{fn: func(r *http.Request) (*http.Response, error) {
		t.Error("upstream must not be hit when a script synthesizes a response")
		return nil, fmt.Errorf("unreachable")
	}}
	h := newPipeHarness(t, p, true)
	defer h.conn.Close()

	resp := h.do("GET /x HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp.StatusCode != 403 {
		t.Fatalf("status = %d, want 403", resp.StatusCode)
	}
	if got := readBodyString(t, resp); got != "" {
		t.Errorf("body = %q, want empty", got)
	}
	resp2 := h.do("GET /x HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp2.StatusCode != 403 {
		t.Errorf("second status = %d, want 403", resp2.StatusCode)
	}
	_ = readBodyString(t, resp2)
}

func TestFramingUpstreamErrorGives502(t *testing.T) {
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		return nil, fmt.Errorf("dial tcp: connection refused")
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp.StatusCode != 502 {
		t.Fatalf("status = %d, want 502", resp.StatusCode)
	}
	if got := readBodyString(t, resp); got != "" {
		t.Errorf("502 body = %q, want empty", got)
	}
}

func TestFramingTruncatedUpstreamFailsOpen(t *testing.T) {
	// Upstream promised 100 bytes but the connection broke after 5.
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		h := http.Header{"Content-Length": {"100"}}
		return cannedResponse(200, h, "short", 100), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	start := time.Now()
	if _, err := io.WriteString(h.conn, "GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n"); err != nil {
		t.Fatal(err)
	}
	dummy, _ := http.NewRequest("GET", "http://example.com/", nil)
	resp, err := http.ReadResponse(h.br, dummy)
	if err != nil {
		t.Fatalf("read response headers: %v", err)
	}
	_, err = io.ReadAll(resp.Body)
	resp.Body.Close()
	if err == nil {
		t.Errorf("expected a body error for truncated upstream, got nil")
	}
	if d := time.Since(start); d > 5*time.Second {
		t.Errorf("truncated response hung for %v, want prompt fail-open", d)
	}
}

func TestFramingHeadRequest(t *testing.T) {
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		h := http.Header{"Content-Length": {"1234"}}
		return cannedResponse(200, h, "", 1234), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("HEAD http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if resp.StatusCode != 200 {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	if got := readBodyString(t, resp); got != "" {
		t.Errorf("HEAD body = %q, want empty", got)
	}
	if got := resp.Header.Get("Content-Length"); got != "1234" {
		t.Errorf("Content-Length = %q, want 1234", got)
	}
}

func TestFramingRequestBodyLengthPreserved(t *testing.T) {
	var gotLen int64 = -2
	var gotBody string
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		gotLen = r.ContentLength
		b, _ := io.ReadAll(r.Body)
		gotBody = string(b)
		return cannedResponse(200, http.Header{"Content-Length": {"2"}}, "ok", 2), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("POST http://example.com/ HTTP/1.1\r\nHost: example.com\r\nContent-Length: 5\r\n\r\nhello")
	_ = readBodyString(t, resp)
	if gotLen != 5 {
		t.Errorf("upstream saw ContentLength = %d, want 5 (must not be re-chunked)", gotLen)
	}
	if gotBody != "hello" {
		t.Errorf("upstream saw body %q, want %q", gotBody, "hello")
	}
}

func TestFramingHeaderCaseRoundTrip(t *testing.T) {
	rt := stubRT{fn: func(r *http.Request) (*http.Response, error) {
		h := http.Header{"Content-Length": {"3"}, "X-Mixed-Case": {"VaL"}}
		return cannedResponse(200, h, "abc", 3), nil
	}}
	h := newPipeHarness(t, newFramingProxy(rt), false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\n\r\n")
	if got := resp.Header.Get("X-Mixed-Case"); got != "VaL" {
		t.Errorf("X-Mixed-Case = %q, want VaL", got)
	}
	if got := readBodyString(t, resp); got != "abc" {
		t.Errorf("body = %q", got)
	}
}
