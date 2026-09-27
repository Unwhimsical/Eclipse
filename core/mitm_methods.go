package main

import (
	"encoding/json"
	"fmt"
	"sync"

	"core/mitm"
)

var (
	mitmProxy   *mitm.Proxy
	mitmProxyMu sync.Mutex
)

// mitmConfigFromMap parses the Flutter-provided config map.
func mitmConfigFromMap(m map[string]interface{}) (mitm.Config, error) {
	var cfg mitm.Config
	if v, ok := m["listen"].(string); ok {
		cfg.Listen = v
	} else {
		cfg.Listen = "127.0.0.1:9092"
	}
	if v, ok := m["caCert"].(string); ok {
		cfg.CACertPEM = v
	}
	if v, ok := m["caKey"].(string); ok {
		cfg.CAKeyPEM = v
	}
	if v, ok := m["upstream"].(string); ok {
		cfg.Upstream = v
	}
	if hosts, ok := m["hosts"].([]interface{}); ok {
		for _, h := range hosts {
			if s, ok := h.(string); ok && s != "" {
				cfg.Hosts = append(cfg.Hosts, s)
			}
		}
	}
	if rewrites, ok := m["rewrites"].([]interface{}); ok {
		for _, r := range rewrites {
			if rm, ok := r.(map[string]interface{}); ok {
				rule := mitm.RewriteRule{}
				if v, ok := rm["pattern"].(string); ok {
					rule.Pattern = v
				}
				if v, ok := rm["target"].(string); ok {
					rule.Target = v
				}
				if v, ok := rm["status"].(string); ok {
					rule.Status = v
				}
				if rule.Pattern != "" {
					cfg.Rewrites = append(cfg.Rewrites, rule)
				}
			}
		}
	}
	if scripts, ok := m["scripts"].([]interface{}); ok {
		for _, s := range scripts {
			if sm, ok := s.(map[string]interface{}); ok {
				script := mitm.Script{}
				if v, ok := sm["name"].(string); ok {
					script.Name = v
				}
				if v, ok := sm["type"].(string); ok {
					script.Type = v
				}
				if v, ok := sm["pattern"].(string); ok {
					script.Pattern = v
				}
				if v, ok := sm["scriptPath"].(string); ok {
					script.ScriptPath = v
				}
				if v, ok := sm["content"].(string); ok {
					script.Content = v
				}
				if b, ok := sm["requiresBody"].(bool); ok {
					script.RequiresBody = b
				}
				cfg.Scripts = append(cfg.Scripts, script)
			}
		}
	}
	return cfg, nil
}

func handleMitmStart(args map[string]interface{}) (map[string]interface{}, error) {
	mitmProxyMu.Lock()
	defer mitmProxyMu.Unlock()
	cfg, err := mitmConfigFromMap(args)
	if err != nil {
		return nil, err
	}
	if mitmProxy != nil && mitmProxy.IsRunning() {
		mitmProxy.UpdateConfig(cfg)
		return map[string]interface{}{"running": true, "listen": cfg.Listen}, nil
	}
	p, err := mitm.New(cfg)
	if err != nil {
		return nil, err
	}
	if err := p.Start(); err != nil {
		return nil, err
	}
	mitmProxy = p
	return map[string]interface{}{"running": true, "listen": cfg.Listen}, nil
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
		return nil, fmt.Errorf("mitm: not running")
	}
	cfg, err := mitmConfigFromMap(args)
	if err != nil {
		return nil, err
	}
	mitmProxy.UpdateConfig(cfg)
	return map[string]interface{}{"ok": true}, nil
}

func handleMitmGetStatus() (map[string]interface{}, error) {
	mitmProxyMu.Lock()
	defer mitmProxyMu.Unlock()
	running := mitmProxy != nil && mitmProxy.IsRunning()
	return map[string]interface{}{"running": running}, nil
}

// ensure mitm package JSON marshaling works for logging.
var _ = json.Marshal
