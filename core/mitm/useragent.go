package mitm

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

// UARejectRule matches the request User-Agent header against a Shadowrocket
// USER-AGENT glob. Mihomo has no USER-AGENT rule type, so PROXY/DIRECT
// policies cannot be enforced at L7; UARejectKind reports ok=false for them.
type UARejectRule struct {
	Pattern string
	Kind    string
	Status  int
	re      *regexp.Regexp
}

func UARejectKind(policy string) (kind string, status int, ok bool) {
	switch strings.ToLower(strings.TrimSpace(policy)) {
	case "reject", "-", "reject-nodrop", "reject-no-drop":
		return "reject", 502, true
	case "reject-200":
		return "reject", 200, true
	case "reject-dict", "reject-json":
		return "reject-json", 200, true
	case "reject-array":
		return "reject-array", 200, true
	case "reject-img", "reject-tinygif":
		return "reject-img", 200, true
	case "reject-video":
		return "reject-video", 200, true
	}
	return "", 0, false
}

func CompileUARejectRule(pattern, kind string, status int) (*UARejectRule, error) {
	re, err := regexp.Compile(uaGlobRegex(pattern))
	if err != nil {
		return nil, fmt.Errorf("mitm: invalid user-agent pattern %q: %w", pattern, err)
	}
	return &UARejectRule{Pattern: pattern, Kind: kind, Status: status, re: re}, nil
}

func uaGlobRegex(pattern string) string {
	var b strings.Builder
	b.WriteString("(?i)^")
	for _, r := range pattern {
		if r == '*' {
			b.WriteString(".*")
		} else {
			b.WriteString(regexp.QuoteMeta(string(r)))
		}
	}
	b.WriteString("$")
	return b.String()
}

func (p *Proxy) applyUARejectRules(req *http.Request) *RewriteResult {
	p.mu.RLock()
	rules := p.config.UARules
	p.mu.RUnlock()
	ua := req.Header.Get("User-Agent")
	for _, r := range rules {
		if r.re != nil && r.re.MatchString(ua) {
			return &RewriteResult{Kind: r.Kind, Status: r.Status}
		}
	}
	return nil
}
