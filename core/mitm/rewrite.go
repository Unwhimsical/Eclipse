package mitm

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

type RewriteRule struct {
	Pattern string
	Action  string
	Target  string
	Status  int
	re      *regexp.Regexp
}

func CompileRewrite(pattern, action, target string, status int) (*RewriteRule, error) {
	re, err := regexp.Compile(pattern)
	if err != nil {
		return nil, fmt.Errorf("mitm: invalid rewrite pattern %q: %w", pattern, err)
	}
	return &RewriteRule{Pattern: pattern, Action: action, Target: target, Status: status, re: re}, nil
}

type RewriteResult struct {
	Kind   string
	Target string
	Status int
}

func (p *Proxy) applyRewrite(req *http.Request, urlStr string) *RewriteResult {
	p.mu.RLock()
	rules := p.config.Rewrites
	p.mu.RUnlock()
	for _, r := range rules {
		if r.re == nil || !r.re.MatchString(urlStr) {
			continue
		}
		switch strings.ToLower(r.Action) {
		case "redirect", "302", "307":
			target := r.re.ReplaceAllString(urlStr, r.Target)
			status := r.Status
			if status != 307 {
				status = 302
			}
			return &RewriteResult{Kind: "redirect", Target: target, Status: status}
		case "reject":
			return &RewriteResult{Kind: "reject", Status: 502}
		case "reject-200":
			return &RewriteResult{Kind: "reject", Status: 200}
		case "reject-dict", "reject-json":
			return &RewriteResult{Kind: "reject-json", Status: 200}
		case "reject-img":
			return &RewriteResult{Kind: "reject-img", Status: 200}
		case "reject-video":
			return &RewriteResult{Kind: "reject-video", Status: 200}
		case "reject-nodrop", "reject-no-drop":
			return &RewriteResult{Kind: "reject", Status: 502}
		}
	}
	return nil
}

var (
	rejectJSON = []byte("{}")
	// 1x1 transparent GIF.
	rejectImg = []byte{
		0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00,
		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21,
		0xf9, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00,
		0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02, 0x44,
		0x01, 0x00, 0x3b,
	}
)

func writeRewriteResult(w http.ResponseWriter, res *RewriteResult) {
	switch res.Kind {
	case "redirect":
		w.Header().Set("Location", res.Target)
		w.WriteHeader(res.Status)
	case "reject-json":
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(res.Status)
		_, _ = w.Write(rejectJSON)
	case "reject-img":
		w.Header().Set("Content-Type", "image/gif")
		w.WriteHeader(res.Status)
		_, _ = w.Write(rejectImg)
	case "reject-video":
		w.Header().Set("Content-Type", "video/mp4")
		w.WriteHeader(res.Status)
	default:
		w.WriteHeader(res.Status)
	}
}
