package main

import (
	"fmt"
	"sync"

	"core/mitm"
)

var (
	mitmProxy   *mitm.Proxy
	mitmProxyMu sync.Mutex
)

func mitmConfigFromArgs(args map[string]interface{}) (mitm.Config, error) {
	cfg := mitm.Config{ListenAddr: "127.0.0.1:18080"}
	if v, ok := args["enabled"].(bool); ok {
		cfg.Enabled = v
	}
	if v, ok := args["listenAddr"].(string); ok && v != "" {
		cfg.ListenAddr = v
	}
	if v, ok := args["caCert"].(string); ok {
		cfg.CACertPEM = v
	}
	if v, ok := args["caKey"].(string); ok {
		cfg.CAKeyPEM = v
	}
	if v, ok := args["hostnames"].([]interface{}); ok {
		for _, h := range v {
			if s, ok := h.(string); ok {
				cfg.Hostnames = append(cfg.Hostnames, s)
			}
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
			if s, ok := m["status"].(float64); ok {
				status = int(s)
			}
			rule, err := mitm.CompileRewrite(pattern, action, target, status)
			if err != nil {
				continue
			}
			cfg.Rewrites = append(cfg.Rewrites, *rule)
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
