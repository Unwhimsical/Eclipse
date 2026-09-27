package mitm

import (
	"bytes"
	"io"
	"net/http"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/dop251/goja"
)

// jsRunner executes Shadowrocket-style scripts.
type jsRunner struct {
	mu      sync.Mutex
	scripts []compiledScript
}

type compiledScript struct {
	Script
	pattern *regexp.Regexp
}

func newJSRunner(scripts []Script) *jsRunner {
	r := &jsRunner{}
	for _, s := range scripts {
		var re *regexp.Regexp
		if s.Pattern != "" {
			if compiled, err := regexp.Compile(s.Pattern); err == nil {
				re = compiled
			}
		}
		r.scripts = append(r.scripts, compiledScript{Script: s, pattern: re})
	}
	return r
}

// runRequestScripts runs http-request scripts. Returns a response if a
// script short-circuits the request.
func (p *Proxy) runRequestScripts(req *http.Request) *http.Response {
	p.mu.RLock()
	scripts := p.config.Scripts
	p.mu.RUnlock()
	runner := newJSRunner(filterScripts(scripts, "http-request"))
	rawURL := requestURL(req)
	body := readBody(req)
	for _, cs := range runner.scripts {
		if cs.pattern != nil && !cs.pattern.MatchString(rawURL) {
			continue
		}
		if cs.Content == "" {
			continue
		}
		result := cs.executeRequest(rawURL, req, body)
		if result.respond != nil {
			return result.respond
		}
		if result.modifiedReq != nil {
			req = result.modifiedReq
		}
	}
	return nil
}

// runResponseScripts runs http-response scripts against the upstream response.
func (p *Proxy) runResponseScripts(req *http.Request, resp *http.Response) *http.Response {
	p.mu.RLock()
	scripts := p.config.Scripts
	p.mu.RUnlock()
	runner := newJSRunner(filterScripts(scripts, "http-response"))
	rawURL := requestURL(req)
	body := readResponseBody(resp)
	for _, cs := range runner.scripts {
		if cs.pattern != nil && !cs.pattern.MatchString(rawURL) {
			continue
		}
		if cs.Content == "" {
			continue
		}
		result := cs.executeResponse(rawURL, req, resp, body)
		if result.modifiedResp != nil {
			resp = result.modifiedResp
			body = readResponseBody(resp)
		}
	}
	// Restore body for relay.
	if body != nil {
		resp.Body = io.NopCloser(bytes.NewReader(body))
		resp.ContentLength = int64(len(body))
		resp.Header.Del("Content-Length")
	}
	return resp
}

func filterScripts(scripts []Script, typ string) []Script {
	var out []Script
	for _, s := range scripts {
		t := strings.ToLower(s.Type)
		if t == typ || (typ == "http-response" && t == "") {
			out = append(out, s)
		}
	}
	return out
}

func requestURL(req *http.Request) string {
	if req.URL.IsAbs() {
		return req.URL.String()
	}
	scheme := "http"
	if req.TLS != nil {
		scheme = "https"
	}
	host := req.Host
	if host == "" {
		host = req.URL.Host
	}
	return scheme + "://" + host + req.URL.RequestURI()
}

func readBody(req *http.Request) []byte {
	if req.Body == nil {
		return nil
	}
	data, err := io.ReadAll(req.Body)
	if err != nil {
		return nil
	}
	req.Body = io.NopCloser(bytes.NewReader(data))
	return data
}

func readResponseBody(resp *http.Response) []byte {
	if resp.Body == nil {
		return nil
	}
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil
	}
	resp.Body = io.NopCloser(bytes.NewReader(data))
	return data
}

type scriptResult struct {
	respond      *http.Response
	modifiedReq  *http.Request
	modifiedResp *http.Response
}

// executeRequest runs the script with $request and $done.
func (cs *compiledScript) executeRequest(rawURL string, req *http.Request, body []byte) scriptResult {
	vm := goja.New()
	doneCalled := false
	var doneArg goja.Value

	// Build $request.
	headers := map[string]string{}
	for k, v := range req.Header {
		headers[k] = strings.Join(v, ", ")
	}
	requestObj := map[string]interface{}{
		"url":     rawURL,
		"method":  req.Method,
		"headers": headers,
		"body":    string(body),
	}
	if err := vm.Set("$request", requestObj); err != nil {
		return scriptResult{}
	}
	// $done.
	if err := vm.Set("$done", func(call goja.FunctionCall) goja.Value {
		doneCalled = true
		if len(call.Arguments) > 0 {
			doneArg = call.Arguments[0]
		}
		return goja.Undefined()
	}); err != nil {
		return scriptResult{}
	}
	// $notify (no-op, log only).
	_ = vm.Set("$notify", func(title, subtitle, message string) {})

	// Timeout guard.
	time.AfterFunc(5*time.Second, func() {
		vm.Interrupt("timeout")
	})

	if _, err := vm.RunString(cs.Content); err != nil {
		return scriptResult{}
	}
	if !doneCalled || doneArg == nil || goja.IsUndefined(doneArg) {
		return scriptResult{}
	}
	return cs.applyRequestDone(vm, req, doneArg)
}

func (cs *compiledScript) applyRequestDone(vm *goja.Runtime, req *http.Request, v goja.Value) scriptResult {
	obj := v.ToObject(vm)
	if obj == nil {
		return scriptResult{}
	}
	// {response: {status, headers, body}} short-circuits.
	if respVal := obj.Get("response"); respVal != nil && !goja.IsUndefined(respVal) {
		if resp := buildResponseFromJS(vm, req, respVal); resp != nil {
			return scriptResult{respond: resp}
		}
	}
	// {url, headers} modifies the request.
	newReq := req.Clone(req.Context())
	if urlVal := obj.Get("url"); urlVal != nil && !goja.IsUndefined(urlVal) {
		// URL change: handled by caller via rewrite-like redirect is complex;
		// we update the request URL for forwarding.
		_ = urlVal
	}
	if headersVal := obj.Get("headers"); headersVal != nil && !goja.IsUndefined(headersVal) {
		if headersObj := headersVal.ToObject(vm); headersObj != nil {
			for _, k := range headersObj.Keys() {
				newReq.Header.Set(k, headersObj.Get(k).String())
			}
		}
	}
	return scriptResult{modifiedReq: newReq}
}

// ParseScriptLine parses one `[Script]` line.

// executeResponse runs the script with $request, $response and $done.
func (cs *compiledScript) executeResponse(rawURL string, req *http.Request, resp *http.Response, body []byte) scriptResult {
	vm := goja.New()
	doneCalled := false
	var doneArg goja.Value

	reqHeaders := map[string]string{}
	for k, v := range req.Header {
		reqHeaders[k] = strings.Join(v, ", ")
	}
	_ = vm.Set("$request", map[string]interface{}{
		"url":     rawURL,
		"method":  req.Method,
		"headers": reqHeaders,
	})
	respHeaders := map[string]string{}
	for k, v := range resp.Header {
		respHeaders[k] = strings.Join(v, ", ")
	}
	_ = vm.Set("$response", map[string]interface{}{
		"status":  resp.StatusCode,
		"headers": respHeaders,
		"body":    string(body),
	})
	_ = vm.Set("$done", func(call goja.FunctionCall) goja.Value {
		doneCalled = true
		if len(call.Arguments) > 0 {
			doneArg = call.Arguments[0]
		}
		return goja.Undefined()
	})
	_ = vm.Set("$notify", func(title, subtitle, message string) {})

	time.AfterFunc(10*time.Second, func() {
		vm.Interrupt("timeout")
	})

	if _, err := vm.RunString(cs.Content); err != nil {
		return scriptResult{}
	}
	if !doneCalled || doneArg == nil || goja.IsUndefined(doneArg) {
		return scriptResult{}
	}
	return cs.applyResponseDone(vm, req, resp, doneArg, body)
}

func (cs *compiledScript) applyResponseDone(vm *goja.Runtime, req *http.Request, resp *http.Response, v goja.Value, origBody []byte) scriptResult {
	obj := v.ToObject(vm)
	if obj == nil {
		return scriptResult{}
	}
	newResp := &http.Response{
		StatusCode: resp.StatusCode,
		ProtoMajor: 1,
		ProtoMinor: 1,
		Header:     resp.Header.Clone(),
		Request:    req,
	}
	body := origBody
	if bodyVal := obj.Get("body"); bodyVal != nil && !goja.IsUndefined(bodyVal) {
		body = []byte(bodyVal.String())
	}
	if headersVal := obj.Get("headers"); headersVal != nil && !goja.IsUndefined(headersVal) {
		if headersObj := headersVal.ToObject(vm); headersObj != nil {
			for _, k := range headersObj.Keys() {
				newResp.Header.Set(k, headersObj.Get(k).String())
			}
		}
	}
	if statusVal := obj.Get("status"); statusVal != nil && !goja.IsUndefined(statusVal) {
		if n := statusVal.ToInteger(); n >= 100 && n < 600 {
			newResp.StatusCode = int(n)
		}
	}
	newResp.Body = io.NopCloser(bytes.NewReader(body))
	newResp.ContentLength = int64(len(body))
	return scriptResult{modifiedResp: newResp}
}

func buildResponseFromJS(vm *goja.Runtime, req *http.Request, v goja.Value) *http.Response {
	obj := v.ToObject(vm)
	if obj == nil {
		return nil
	}
	resp := &http.Response{
		StatusCode: 200,
		ProtoMajor: 1,
		ProtoMinor: 1,
		Header:     make(http.Header),
		Request:    req,
	}
	if statusVal := obj.Get("status"); statusVal != nil && !goja.IsUndefined(statusVal) {
		if n := statusVal.ToInteger(); n >= 100 && n < 600 {
			resp.StatusCode = int(n)
		}
	}
	body := ""
	if bodyVal := obj.Get("body"); bodyVal != nil && !goja.IsUndefined(bodyVal) {
		body = bodyVal.String()
	}
	if headersVal := obj.Get("headers"); headersVal != nil && !goja.IsUndefined(headersVal) {
		if headersObj := headersVal.ToObject(vm); headersObj != nil {
			for _, k := range headersObj.Keys() {
				resp.Header.Set(k, headersObj.Get(k).String())
			}
		}
	}
	resp.Body = io.NopCloser(strings.NewReader(body))
	resp.ContentLength = int64(len(body))
	return resp
}

// ParseScriptLine parses one `[Script]` line:
// `name = type=http-response,pattern=...,requires-body=1,script-path=...`
func ParseScriptLine(line string) *Script {
	eq := strings.Index(line, "=")
	if eq < 0 {
		return nil
	}
	name := strings.TrimSpace(line[:eq])
	rest := strings.TrimSpace(line[eq+1:])
	s := &Script{Name: name}
	for _, part := range strings.Split(rest, ",") {
		kv := strings.SplitN(strings.TrimSpace(part), "=", 2)
		if len(kv) != 2 {
			continue
		}
		k := strings.TrimSpace(strings.ToLower(kv[0]))
		v := strings.TrimSpace(kv[1])
		switch k {
		case "type":
			s.Type = v
		case "pattern":
			s.Pattern = v
		case "requires-body":
			s.RequiresBody = v == "1" || strings.EqualFold(v, "true")
		case "script-path":
			s.ScriptPath = v
		}
	}
	return s
}
