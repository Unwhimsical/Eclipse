package mitm

import (
	"time"

	"github.com/dop251/goja"
)

// scriptResult carries what the script passed to $done.
type scriptResult struct {
	called   bool
	headers  map[string]string
	body     []byte
	bodySet  bool
	status   int
	url      string
	response bool // $done({response: {...}}) — synthesize a response
}

// runScript executes content with $request/$response/$argument/$done injected.
// kind is "request" or "response". Returns the $done payload, or
// called=false when the script did not call $done or failed (fail-open).
func runScript(s *Script, kind string, reqInfo map[string]interface{}, respInfo map[string]interface{}) (res *scriptResult) {
	res = &scriptResult{}
	defer func() {
		if r := recover(); r != nil {
			// Fail open: any panic means "no modification".
			res = &scriptResult{}
		}
	}()

	vm := goja.New()

	// Timeout: interrupt the VM from another goroutine.
	timer := time.AfterFunc(time.Duration(s.TimeoutSec)*time.Second, func() {
		vm.Interrupt("script timeout")
	})
	defer timer.Stop()

	// $request / $response as plain objects.
	if err := vm.Set("$request", reqInfo); err != nil {
		return res
	}
	if respInfo != nil {
		if err := vm.Set("$response", respInfo); err != nil {
			return res
		}
	} else {
		_ = vm.Set("$response", goja.Undefined())
	}
	if s.Argument != "" {
		_ = vm.Set("$argument", s.Argument)
	} else {
		_ = vm.Set("$argument", goja.Undefined())
	}

	// $done captures its argument for the Go side.
	var doneArg goja.Value
	_ = vm.Set("$done", func(call goja.FunctionCall) goja.Value {
		res.called = true
		if len(call.Arguments) > 0 && !goja.IsUndefined(call.Argument(0)) {
			doneArg = call.Argument(0)
		}
		return goja.Undefined()
	})

	// Minimal console.* -> dropped (could wire to logs later).
	console := map[string]interface{}{
		"log":   func(goja.FunctionCall) goja.Value { return goja.Undefined() },
		"info":  func(goja.FunctionCall) goja.Value { return goja.Undefined() },
		"warn":  func(goja.FunctionCall) goja.Value { return goja.Undefined() },
		"error": func(goja.FunctionCall) goja.Value { return goja.Undefined() },
	}
	_ = vm.Set("console", console)

	// Wrap in an async IIFE so top-level await works. goja drains the
	// promise microtask queue before RunString returns, so $done called
	// from promise continuations has already run at this point.
	wrapped := "(async () => {\n" + s.Content + "\n})();"
	if _, err := vm.RunString(wrapped); err != nil {
		return res // syntax/runtime error: fail open
	}

	if !res.called || doneArg == nil {
		return res
	}
	applyDoneArg(vm, doneArg, res, s.BinaryBody)
	return res
}

// applyDoneArg reads the object passed to $done into res.
func applyDoneArg(vm *goja.Runtime, v goja.Value, res *scriptResult, binaryBody bool) {
	obj, ok := v.(*goja.Object)
	if !ok {
		return
	}
	getStr := func(key string) (string, bool) {
		val := obj.Get(key)
		if val == nil || goja.IsUndefined(val) || goja.IsNull(val) {
			return "", false
		}
		return val.String(), true
	}

	if url, ok := getStr("url"); ok {
		res.url = url
	}
	if st := obj.Get("status"); st != nil && !goja.IsUndefined(st) {
		res.status = int(st.ToInteger())
	}
	// headers: object of string->string
	if h := obj.Get("headers"); h != nil && !goja.IsUndefined(h) {
		if ho, ok := h.(*goja.Object); ok {
			res.headers = map[string]string{}
			for _, k := range ho.Keys() {
				val := ho.Get(k)
				if val != nil && !goja.IsUndefined(val) {
					res.headers[k] = val.String()
				}
			}
		}
	}
	// body: string or Uint8Array/ArrayBuffer
	if b := obj.Get("body"); b != nil && !goja.IsUndefined(b) {
		res.bodySet = true
		res.body = jsValueToBytes(vm, b, binaryBody)
	}
	// response: nested object to synthesize a full response
	if r := obj.Get("response"); r != nil && !goja.IsUndefined(r) {
		res.response = true
		if ro, ok := r.(*goja.Object); ok {
			applyDoneArg(vm, ro, res, binaryBody)
			res.response = true
		}
	}
}

// jsValueToBytes converts a JS string / Uint8Array / ArrayBuffer to bytes.
func jsValueToBytes(vm *goja.Runtime, v goja.Value, _ bool) []byte {
	if v == nil || goja.IsUndefined(v) || goja.IsNull(v) {
		return nil
	}
	// goja exports []byte for typed arrays / ArrayBuffers.
	if exp := v.Export(); exp != nil {
		switch e := exp.(type) {
		case []byte:
			cp := make([]byte, len(e))
			copy(cp, e)
			return cp
		case string:
			return []byte(e)
		}
	}
	return []byte(v.String())
}

// headerMap converts http.Header to a plain map for JS.
func headerMap(h map[string][]string) map[string]interface{} {
	out := make(map[string]interface{}, len(h))
	for k, vv := range h {
		if len(vv) == 1 {
			out[k] = vv[0]
		} else {
			out[k] = vv
		}
	}
	return out
}
