package mitm

import (
	"io"
	"net/http"
	"strings"
	"testing"
	"time"
)

func testProxyWithScripts(scripts ...*Script) *Proxy {
	p := &Proxy{scripts: NewScriptRegistry()}
	p.scripts.Set(scripts)
	return p
}

func jsScript(typeName, content string) *Script {
	return &Script{
		Name:        "verify.js",
		Type:        typeName,
		TimeoutSec:  5,
		MaxBodySize: 1024 * 1024,
		Content:     content,
	}
}

func TestVerifyScriptRequestModifiesHeaders(t *testing.T) {
	p := testProxyWithScripts(jsScript("http-request", `$done({headers: {"X-Added": "yes"}});`))
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	done, handled := p.runRequestScripts(req, "https://example.com/", true)
	if handled || done != nil {
		t.Fatalf("expected (nil,false), got (%v,%v)", done, handled)
	}
	if got := req.Header.Get("X-Added"); got != "yes" {
		t.Errorf("X-Added = %q, want %q", got, "yes")
	}
}

func TestVerifyScriptRequestSeesRequestAndArgument(t *testing.T) {
	s := jsScript("http-request", `$done({headers: {"X-Method": $request.method, "X-Arg": $argument}});`)
	s.Argument = "hello-arg"
	p := testProxyWithScripts(s)
	req, _ := http.NewRequest("POST", "https://example.com/", nil)
	p.runRequestScripts(req, "https://example.com/", true)
	if got := req.Header.Get("X-Method"); got != "POST" {
		t.Errorf("X-Method = %q, want POST", got)
	}
	if got := req.Header.Get("X-Arg"); got != "hello-arg" {
		t.Errorf("X-Arg = %q, want hello-arg", got)
	}
}

func TestVerifyScriptResponseModifiesBody(t *testing.T) {
	s := jsScript("http-response", `$done({body: $response.body + "-suffix"});`)
	s.RequiresBody = true
	p := testProxyWithScripts(s)
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	resp := &http.Response{
		StatusCode: 200,
		Header:     http.Header{},
		Body:       io.NopCloser(strings.NewReader("orig")),
		Request:    req,
	}
	body := p.runResponseScripts("https://example.com/", resp)
	if string(body) != "orig-suffix" {
		t.Errorf("body = %q, want %q", body, "orig-suffix")
	}
}

func TestVerifyScriptResponseSeesStatus(t *testing.T) {
	p := testProxyWithScripts(jsScript("http-response", `$done({status: $response.status + 1});`))
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	resp := &http.Response{
		StatusCode: 200,
		Header:     http.Header{},
		Body:       io.NopCloser(strings.NewReader("")),
		Request:    req,
	}
	p.runResponseScripts("https://example.com/", resp)
	if resp.StatusCode != 201 {
		t.Errorf("status = %d, want 201", resp.StatusCode)
	}
}

func TestVerifyScriptBinaryBodyUint8Array(t *testing.T) {
	s := jsScript("http-request", `
		if (!($request.body instanceof Uint8Array)) { throw new Error("not a Uint8Array"); }
		$done({body: $request.body});
	`)
	s.RequiresBody = true
	s.BinaryBody = true
	p := testProxyWithScripts(s)
	raw := []byte{0x00, 0x01, 0xff, 0xfe, 0x41}
	req, _ := http.NewRequest("POST", "https://example.com/", io.NopCloser(strings.NewReader(string(raw))))
	done, handled := p.runRequestScripts(req, "https://example.com/", true)
	if handled || done != nil {
		t.Fatalf("expected in-place body rewrite, got (%v,%v)", done, handled)
	}
	out, _ := io.ReadAll(req.Body)
	if string(out) != string(raw) {
		t.Errorf("binary body round-trip = %v, want %v", out, raw)
	}
}

func TestVerifyScriptNoDoneCallIsNoop(t *testing.T) {
	p := testProxyWithScripts(jsScript("http-request", `var x = 1 + 1;`))
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	req.Header.Set("X-Keep", "v")
	done, handled := p.runRequestScripts(req, "https://example.com/", true)
	if handled || done != nil {
		t.Fatalf("expected (nil,false), got (%v,%v)", done, handled)
	}
	if got := req.Header.Get("X-Keep"); got != "v" {
		t.Errorf("X-Keep changed to %q", got)
	}
}

func TestVerifyScriptErrorFailsOpen(t *testing.T) {
	p := testProxyWithScripts(jsScript("http-request", `this is not valid javascript (((`))
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	done, handled := p.runRequestScripts(req, "https://example.com/", true)
	if handled || done != nil {
		t.Fatalf("expected (nil,false), got (%v,%v)", done, handled)
	}
}

func TestVerifyScriptTimeoutTerminates(t *testing.T) {
	s := jsScript("http-request", `while (true) {}`)
	s.TimeoutSec = 1
	p := testProxyWithScripts(s)
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	start := time.Now()
	done, handled := p.runRequestScripts(req, "https://example.com/", true)
	elapsed := time.Since(start)
	if handled || done != nil {
		t.Fatalf("expected (nil,false), got (%v,%v)", done, handled)
	}
	if elapsed > 10*time.Second {
		t.Errorf("script took %v, timeout did not terminate it", elapsed)
	}
	t.Logf("runaway script terminated after %v", elapsed)
}

func TestVerifyScriptSynthesizesResponse(t *testing.T) {
	p := testProxyWithScripts(jsScript(
		"http-request",
		`$done({response: {status: 200, headers: {"Content-Type": "text/plain"}, body: "mocked"}});`,
	))
	req, _ := http.NewRequest("GET", "https://example.com/", nil)
	done, handled := p.runRequestScripts(req, "https://example.com/", true)
	if !handled || done == nil {
		t.Fatalf("expected synthesized response, got (%v,%v)", done, handled)
	}
	if done.status != 200 || string(done.body) != "mocked" {
		t.Errorf("synthesized = status %d body %q", done.status, done.body)
	}
}
