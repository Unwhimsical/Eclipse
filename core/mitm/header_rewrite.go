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

func (p *Proxy) applyHeaderRewrites(req *http.Request, urlStr string) {
	p.mu.RLock()
	rules := p.config.HeaderRewrites
	p.mu.RUnlock()
	for _, r := range rules {
		if r.re == nil || !r.re.MatchString(urlStr) {
			continue
		}
		switch strings.ToLower(r.Action) {
		case "header-del":
			if len(r.Args) >= 1 && r.Args[0] != "" {
				req.Header.Del(r.Args[0])
			}
		case "header-add":
			if len(r.Args) >= 1 {
				if name, value, ok := splitNameValue(r.Args[0]); ok {
					req.Header.Add(name, value)
				}
			}
		case "header-replace":
			if len(r.Args) >= 1 {
				if name, value, ok := splitNameValue(r.Args[0]); ok {
					req.Header.Set(name, value)
				}
			}
		case "header-replace-regex":
			if len(r.Args) >= 3 && r.Args[0] != "" {
				re, err := regexp.Compile(r.Args[1])
				if err != nil {
					continue
				}
				vals := req.Header.Values(r.Args[0])
				if len(vals) == 0 {
					continue
				}
				out := make([]string, len(vals))
				for i, v := range vals {
					out[i] = re.ReplaceAllString(v, r.Args[2])
				}
				req.Header.Del(r.Args[0])
				for _, v := range out {
					req.Header.Add(r.Args[0], v)
				}
			}
		}
	}
}
