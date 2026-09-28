package mitm

import (
	"bytes"
	"io"
	"net/http"
	"net/url"
	"strconv"
)

// runRequestScripts runs http-request scripts for req.
// Returns (result, true) if a script synthesized a response (handled),
// (nil, false) to continue with normal forwarding. A script may also
// rewrite req in place (url/headers/body) and return (nil, false).
func (p *Proxy) runRequestScripts(req *http.Request, fullURL string, isTLS bool) (*scriptResult, bool) {
	scripts := p.scripts.Match("http-request", fullURL)
	if len(scripts) == 0 {
		return nil, false
	}
	for _, s := range scripts {
		var body []byte
		if s.RequiresBody && req.Body != nil {
			body, _ = io.ReadAll(io.LimitReader(req.Body, s.MaxBodySize+1))
			req.Body.Close()
			if int64(len(body)) > s.MaxBodySize {
				body = body[:s.MaxBodySize]
			}
			// Restore the body for forwarding.
			req.Body = io.NopCloser(bytes.NewReader(body))
		}
		reqInfo := map[string]interface{}{
			"method":  req.Method,
			"url":     fullURL,
			"headers": headerMap(req.Header),
		}
		if s.RequiresBody {
			reqInfo["body"] = jsBodyValue(body, s.BinaryBody)
		}
		res := runScript(s, "request", reqInfo, nil)
		if res == nil || !res.called {
			continue
		}
		// $done({response: {...}}) — synthesize a response immediately.
		if res.response {
			return res, true
		}
		// Apply in-place request modifications.
		if res.url != "" {
			if u, err := url.Parse(res.url); err == nil {
				req.URL = u
				req.Host = u.Host
			}
		}
		if len(res.headers) > 0 {
			for k, v := range res.headers {
				req.Header.Set(k, v)
			}
		}
		if res.bodySet {
			req.Body = io.NopCloser(bytes.NewReader(res.body))
			req.ContentLength = int64(len(res.body))
		}
	}
	return nil, false
}

// runResponseScripts runs http-response scripts on resp.
// Returns the (possibly modified) body to send to the client.
func (p *Proxy) runResponseScripts(fullURL string, resp *http.Response) []byte {
	scripts := p.scripts.Match("http-response", fullURL)
	if len(scripts) == 0 {
		return nil
	}
	var body []byte
	bodyRead := false
	for _, s := range scripts {
		if s.RequiresBody && !bodyRead {
			body, _ = io.ReadAll(io.LimitReader(resp.Body, s.MaxBodySize+1))
			resp.Body.Close()
			if int64(len(body)) > s.MaxBodySize {
				body = body[:s.MaxBodySize]
			}
			bodyRead = true
		}
		respInfo := map[string]interface{}{
			"status":  resp.StatusCode,
			"headers": headerMap(resp.Header),
		}
		if s.RequiresBody {
			respInfo["body"] = jsBodyValue(body, s.BinaryBody)
		}
		reqInfo := map[string]interface{}{
			"method":  resp.Request.Method,
			"url":     fullURL,
			"headers": headerMap(resp.Request.Header),
		}
		res := runScript(s, "response", reqInfo, respInfo)
		if res == nil || !res.called {
			continue
		}
		if res.status != 0 {
			resp.StatusCode = res.status
		}
		if len(res.headers) > 0 {
			for k, v := range res.headers {
				resp.Header.Set(k, v)
			}
		}
		if res.bodySet {
			body = res.body
			bodyRead = true
		}
	}
	if bodyRead {
		return body
	}
	return nil
}

// jsBodyValue converts body bytes to the JS-visible value.
func jsBodyValue(body []byte, binary bool) interface{} {
	if body == nil {
		return nil
	}
	if binary {
		// goja maps []byte to Uint8Array.
		cp := make([]byte, len(body))
		copy(cp, body)
		return cp
	}
	return string(body)
}

// writeScriptResult writes a synthesized script response to the client.
func writeScriptResult(w *connWriter, res *scriptResult) {
	status := res.status
	if status == 0 {
		status = 200
	}
	for k, v := range res.headers {
		w.Header().Set(k, v)
	}
	// Ensure a Content-Length so the client knows the framing.
	if res.bodySet {
		w.Header().Set("Content-Length", strconv.Itoa(len(res.body)))
	}
	w.WriteHeader(status)
	if res.bodySet {
		_, _ = w.Write(res.body)
	}
}
