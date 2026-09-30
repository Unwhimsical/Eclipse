package main

import (
	"fmt"
	"strconv"
	"strings"
	"sync"

	"core/mitm"
)

var (
	mitmProxy   *mitm.Proxy
	mitmProxyMu sync.Mutex
)

func mitmConfigFromArgs(args map[string]interface{}) (mitm.Config, error) {
	// Calling Start implies enable; Dart may omit the flag.
	cfg := mitm.Config{ListenAddr: "127.0.0.1:18080", Enabled: true}
	if v, ok := args["enabled"].(bool); ok {
		cfg.Enabled = v
	}
	// Dart sends 'listen'; accept 'listenAddr' as well.
	if v, ok := args["listen"].(string); ok && v != "" {
		cfg.ListenAddr = v
	} else if v, ok := args["listenAddr"].(string); ok && v != "" {
		cfg.ListenAddr = v
	}
	if v, ok := args["caCert"].(string); ok {
		cfg.CACertPEM = v
	}
	if v, ok := args["caKey"].(string); ok {
		cfg.CAKeyPEM = v
	}
	// Dart sends 'hosts'; accept 'hostnames' as well.
	var rawHosts []interface{}
	if v, ok := args["hosts"].([]interface{}); ok {
		rawHosts = v
	} else if v, ok := args["hostnames"].([]interface{}); ok {
		rawHosts = v
	}
	for _, h := range rawHosts {
		if s, ok := h.(string); ok {
			cfg.Hostnames = append(cfg.Hostnames, s)
		}
	}
	if v, ok := args["rewrites"].([]interface{}); ok {
		for _, r := range v {
			m, ok := r.(map[string]interface{})
			if !ok {
				continue
			}
			pattern, _ := m["pattern"].(string)
			action, _ := m["action"].(string)
			target, _ := m["target"].(string)
			status := 302
			switch s := m["status"].(type) {
			case float64:
				status = int(s)
			case int:
				status = s
			case string:
				if n, err := strconv.Atoi(strings.TrimSpace(s)); err == nil {
					status = n
				}
			}
			if action == "" {
				action = "redirect"
				if target == "-" || strings.HasPrefix(strings.ToLower(target), "reject") {
					action = "reject"
					target = ""
				}
			}
			rule, err := mitm.CompileRewrite(pattern, action, target, status)
			if err != nil {
				continue
			}
			cfg.Rewrites = append(cfg.Rewrites, *rule)
		}
	}
	// Header rewrites: list of {pattern,action,args}.
	if hr, ok := args["headerRewrites"].([]interface{}); ok {
		for _, item := range hr {
			m, ok := item.(map[string]interface{})
			if !ok {
				continue
			}
			pattern, _ := m["pattern"].(string)
			action, _ := m["action"].(string)
			var hargs []string
			if raw, ok := m["args"].([]interface{}); ok {
				for _, a := range raw {
					if s, ok := a.(string); ok {
						hargs = append(hargs, s)
					}
				}
			}
			if pattern == "" || action == "" {
				continue
			}
			rule, err := mitm.CompileHeaderRewrite(pattern, action, hargs)
			if err != nil {
				continue
			}
			cfg.HeaderRewrites = append(cfg.HeaderRewrites, *rule)
		}
	}
	// Scripts: list of {name,type,pattern,requiresBody,binaryBody,
	// timeout,maxSize,argument,content}.
	if scripts, ok := args["scripts"].([]interface{}); ok {
		for _, item := range scripts {
			m, ok := item.(map[string]interface{})
			if !ok {
				continue
			}
			cfg.Scripts = append(cfg.Scripts, mitm.ParseScriptEntry(m))
		}
	}
	if cfg.CACertPEM == "" || cfg.CAKeyPEM == "" {
		return cfg, fmt.Errorf("mitm: CA certificate and key are required")
	}
	return cfg, nil
}

func handleMitmStart(args map[string]interface{}) (map[string]interface{}, error) {
	mitmProxyMu.Lock()
	defer mitmProxyMu.Unlock()
	if mitmProxy != nil && mitmProxy.IsRunning() {
		return map[string]interface{}{"running": true}, nil
	}
	cfg, err := mitmConfigFromArgs(args)
	if err != nil {
		return nil, err
	}
	p, err := mitm.New(cfg)
	if err != nil {
		return nil, err
	}
	if err := p.Start(); err != nil {
		return nil, err
	}
	mitmProxy = p
	return map[string]interface{}{"running": true, "listenAddr": cfg.ListenAddr}, nil
}

func handleMitmStop() (map[string]interface{}, error) {
	mitmProxyMu.Lock()
	defer mitmProxyMu.Unlock()
	if mitmProxy != nil {
		_ = mitmProxy.Stop()
		mitmProxy = nil
	}
	return map[string]interface{}{"running": false}, nil
}

func handleMitmUpdateConfig(args map[string]interface{}) (map[string]interface{}, error) {
	mitmProxyMu.Lock()
	defer mitmProxyMu.Unlock()
	if mitmProxy == nil {
		return map[string]interface{}{"running": false}, nil
	}
	cfg, err := mitmConfigFromArgs(args)
	if err != nil {
		return nil, err
	}
	mitmProxy.UpdateConfig(cfg)
	return map[string]interface{}{"running": mitmProxy.IsRunning()}, nil
}

func handleMitmGetStatus() (map[string]interface{}, error) {
	mitmProxyMu.Lock()
	defer mitmProxyMu.Unlock()
	running := mitmProxy != nil && mitmProxy.IsRunning()
	return map[string]interface{}{"running": running}, nil
}
