package mitm

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

// HeaderRewriteRule rewrites request headers for URLs matching Pattern.
// Actions mirror Shadowrocket's [Header Rewrite]: header-del, header-add,
// header-replace, header-replace-regex.
type HeaderRewriteRule struct {
	Pattern string
	Action  string
	Args    []string
	re      *regexp.Regexp
}

func CompileHeaderRewrite(pattern, action string, args []string) (*HeaderRewriteRule, error) {
	re, err := regexp.Compile(pattern)
	if err != nil {
		return nil, fmt.Errorf("mitm: invalid header rewrite pattern %q: %w", pattern, err)
	}
	return &HeaderRewriteRule{Pattern: pattern, Action: action, Args: args, re: re}, nil
}

func splitNameValue(s string) (name, value string, ok bool) {
	idx := strings.Index(s, ":")
	if idx <= 0 {
		return "", "", false
	}
	name = strings.TrimSpace(s[:idx])
	value = strings.TrimSpace(s[idx+1:])
	return name, value, name != ""
}

func isResponseHeaderAction(action string) bool {
	return strings.HasPrefix(strings.ToLower(action), "response-header-")
}

func applyHeaderAction(h http.Header, action string, args []string) {
	switch strings.ToLower(action) {
	case "header-del":
		if len(args) >= 1 && args[0] != "" {
			h.Del(args[0])
		}
	case "header-add":
		if len(args) >= 1 {
			if name, value, ok := splitNameValue(args[0]); ok {
				h.Add(name, value)
			}
		}
	case "header-replace":
		if len(args) >= 1 {
			if name, value, ok := splitNameValue(args[0]); ok {
				h.Set(name, value)
			}
		}
	case "header-replace-regex":
		if len(args) >= 3 && args[0] != "" {
			re, err := regexp.Compile(args[1])
			if err != nil {
				return
			}
			vals := h.Values(args[0])
			if len(vals) == 0 {
				return
			}
			out := make([]string, len(vals))
			for i, v := range vals {
				out[i] = re.ReplaceAllString(v, args[2])
			}
			h.Del(args[0])
			for _, v := range out {
				h.Add(args[0], v)
			}
		}
	}
}

func (p *Proxy) applyHeaderRewrites(req *http.Request, urlStr string) {
	p.mu.RLock()
	rules := p.config.HeaderRewrites
	p.mu.RUnlock()
	for _, r := range rules {
		if r.re == nil || !r.re.MatchString(urlStr) || isResponseHeaderAction(r.Action) {
			continue
		}
		applyHeaderAction(req.Header, r.Action, r.Args)
	}
}

func (p *Proxy) applyResponseHeaderRewrites(resp *http.Response, urlStr string) {
	p.mu.RLock()
	rules := p.config.HeaderRewrites
	p.mu.RUnlock()
	for _, r := range rules {
		if r.re == nil || !r.re.MatchString(urlStr) || !isResponseHeaderAction(r.Action) {
			continue
		}
		base := strings.ToLower(r.Action)[len("response-header-"):]
		applyHeaderAction(resp.Header, "header-"+base, r.Args)
	}
}
