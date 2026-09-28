package mitm

import (
	"regexp"
	"strings"
	"sync"
)

// Script is a Shadowrocket [Script] entry: a JavaScript snippet that runs
// on matching HTTP requests or responses after MITM decryption.
type Script struct {
	Name         string
	Type         string // http-request | http-response
	Pattern      *regexp.Regexp
	RequiresBody bool
	BinaryBody   bool
	TimeoutSec   int
	MaxBodySize  int64
	Argument     string
	Content      string
}

// ScriptRegistry holds the active scripts, in module order.
type ScriptRegistry struct {
	mu      sync.RWMutex
	scripts []*Script
}

func NewScriptRegistry() *ScriptRegistry {
	return &ScriptRegistry{}
}

func (r *ScriptRegistry) Set(scripts []*Script) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.scripts = scripts
}

func (r *ScriptRegistry) Clear() {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.scripts = nil
}

// Match returns scripts of the given type whose pattern matches url,
// in registry order.
func (r *ScriptRegistry) Match(scriptType, url string) []*Script {
	r.mu.RLock()
	defer r.mu.RUnlock()
	var out []*Script
	for _, s := range r.scripts {
		if !strings.EqualFold(s.Type, scriptType) {
			continue
		}
		if s.Pattern != nil && !s.Pattern.MatchString(url) {
			continue
		}
		if s.Content == "" {
			continue
		}
		out = append(out, s)
	}
	return out
}

// ParseScriptEntry builds a Script from the map Dart sends.
// Expected keys: name, type, pattern, requiresBody, binaryBody,
// timeout, maxSize, argument, content.
func ParseScriptEntry(m map[string]interface{}) *Script {
	str := func(key string) string {
		if v, ok := m[key]; ok {
			if s, ok := v.(string); ok {
				return s
			}
		}
		return ""
	}
	num := func(key string) int64 {
		if v, ok := m[key]; ok {
			switch n := v.(type) {
			case float64:
				return int64(n)
			case int:
				return int64(n)
			case int64:
				return n
			}
		}
		return 0
	}
	boolean := func(key string) bool {
		if v, ok := m[key]; ok {
			switch b := v.(type) {
			case bool:
				return b
			case float64:
				return b != 0
			case string:
				lb := strings.ToLower(strings.TrimSpace(b))
				return lb == "1" || lb == "true" || lb == "yes"
			}
		}
		return false
	}

	patternStr := str("pattern")
	var pattern *regexp.Regexp
	if patternStr != "" {
		// Shadowrocket patterns are regex; tolerate invalid ones by
		// falling back to a literal substring match.
		if re, err := regexp.Compile(patternStr); err == nil {
			pattern = re
		} else {
			pattern = regexp.MustCompile(regexp.QuoteMeta(patternStr))
		}
	}

	timeout := num("timeout")
	if timeout <= 0 {
		timeout = 20
	}
	if timeout > 120 {
		timeout = 120
	}
	maxSize := num("maxSize")
	if maxSize <= 0 {
		maxSize = 10 << 20 // 10 MiB default cap
	}

	return &Script{
		Name:         str("name"),
		Type:         str("type"),
		Pattern:      pattern,
		RequiresBody: boolean("requiresBody"),
		BinaryBody:   boolean("binaryBody"),
		TimeoutSec:   int(timeout),
		MaxBodySize:  maxSize,
		Argument:     str("argument"),
		Content:      str("content"),
	}
}
