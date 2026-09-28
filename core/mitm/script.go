package mitm

import (
	"fmt"
	"io"
	"net/http"
	"sync"

	"github.com/dop251/goja"
)

type Script struct {
	Pattern      string
	ScriptPath   string
	RequiresBody bool
	code         string
	vm           *goja.Runtime
	mu           sync.Mutex
}

type ScriptResult struct {
	Modified bool
	Body     []byte
	Headers  http.Header
	Reject   bool
}

func NewScript(pattern, scriptPath string, requiresBody bool) *Script {
	return &Script{
		Pattern:      pattern,
		ScriptPath:   scriptPath,
		RequiresBody: requiresBody,
	}
}

func (s *Script) loadCode() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.code != "" {
		return nil
	}
	// TODO: Load from file or URL. For now, return error.
	return fmt.Errorf("mitm: script loading not implemented: %s", s.ScriptPath)
}

func (s *Script) Execute(req *http.Request, resp *http.Response, body []byte) (*ScriptResult, error) {
	if err := s.loadCode(); err != nil {
		return nil, err
	}
	s.mu.Lock()
	defer s.mu.Unlock()

	vm := goja.New()
	vm.Set("$request", map[string]interface{}{
		"url":     req.URL.String(),
		"method":  req.Method,
		"headers": req.Header,
	})
	if resp != nil {
		vm.Set("$response", map[string]interface{}{
			"status":  resp.StatusCode,
			"headers": resp.Header,
			"body":    string(body),
		})
	}
	doneCalled := false
	var doneArg map[string]interface{}
	vm.Set("$done", func(arg map[string]interface{}) {
		doneCalled = true
		doneArg = arg
	})

	_, err := vm.RunString(s.code)
	if err != nil {
		return nil, fmt.Errorf("mitm: script error: %w", err)
	}
	if !doneCalled {
		return &ScriptResult{Modified: false}, nil
	}
	result := &ScriptResult{Modified: true}
	if b, ok := doneArg["body"].(string); ok {
		result.Body = []byte(b)
	} else {
		result.Body = body
	}
	if h, ok := doneArg["headers"].(map[string]interface{}); ok {
		result.Headers = make(http.Header)
		for k, v := range h {
			if vs, ok := v.(string); ok {
				result.Headers.Set(k, vs)
			}
		}
	}
	return result, nil
}

func (p *Proxy) matchScript(req *http.Request) *Script {
	// TODO: Implement script pattern matching
	return nil
}

func (p *Proxy) applyScript(req *http.Request, resp *http.Response) (*http.Response, error) {
	script := p.matchScript(req)
	if script == nil {
		return resp, nil
	}
	var body []byte
	if script.RequiresBody && resp.Body != nil {
		var err error
		body, err = io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			return resp, err
		}
	}
	result, err := script.Execute(req, resp, body)
	if err != nil {
		return resp, err
	}
	if !result.Modified {
		return resp, nil
	}
	// TODO: Reconstruct response with modified body/headers
	return resp, nil
}
