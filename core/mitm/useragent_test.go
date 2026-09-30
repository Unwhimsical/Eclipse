package mitm

import (
	"net/http"
	"testing"
)

func TestUARejectKind(t *testing.T) {
	cases := []struct {
		policy     string
		wantKind   string
		wantStatus int
		wantOk     bool
	}{
		{"REJECT", "reject", 502, true},
		{"reject", "reject", 502, true},
		{"-", "reject", 502, true},
		{"REJECT-NO-DROP", "reject", 502, true},
		{"reject-nodrop", "reject", 502, true},
		{"REJECT-200", "reject", 200, true},
		{"REJECT-DICT", "reject-json", 200, true},
		{"reject-json", "reject-json", 200, true},
		{"REJECT-ARRAY", "reject-array", 200, true},
		{"REJECT-IMG", "reject-img", 200, true},
		{"REJECT-TINYGIF", "reject-img", 200, true},
		{"REJECT-VIDEO", "reject-video", 200, true},
		{"PROXY", "", 0, false},
		{"DIRECT", "", 0, false},
		{"MyGroup", "", 0, false},
		{"", "", 0, false},
	}
	for _, c := range cases {
		kind, status, ok := UARejectKind(c.policy)
		if kind != c.wantKind || status != c.wantStatus || ok != c.wantOk {
			t.Errorf("UARejectKind(%q) = (%q, %d, %v), want (%q, %d, %v)",
				c.policy, kind, status, ok, c.wantKind, c.wantStatus, c.wantOk)
		}
	}
}

func mustUARejectRule(t *testing.T, pattern, policy string) UARejectRule {
	t.Helper()
	kind, status, ok := UARejectKind(policy)
	if !ok {
		t.Fatalf("UARejectKind(%q) not ok", policy)
	}
	r, err := CompileUARejectRule(pattern, kind, status)
	if err != nil {
		t.Fatalf("CompileUARejectRule(%q) error: %v", pattern, err)
	}
	return *r
}

func TestApplyUARejectRules(t *testing.T) {
	p := &Proxy{config: Config{Enabled: true, UARules: []UARejectRule{
		mustUARejectRule(t, "AVOS*", "REJECT-DICT"),
		mustUARejectRule(t, "*ads*", "REJECT"),
		mustUARejectRule(t, "curl/*", "REJECT-200"),
	}}}
	cases := []struct {
		ua         string
		wantKind   string
		wantStatus int
	}{
		{"AVOSCloud/3.4.1", "reject-json", 200},
		{"avoscloud/3.4.1", "reject-json", 200},
		{"XAVOSCloud/1.0", "", 0},
		{"my-ads-sdk/1.0", "reject", 502},
		{"curl/8.4.0", "reject", 200},
		{"curl", "", 0},
		{"Mozilla/5.0", "", 0},
		{"", "", 0},
	}
	for _, c := range cases {
		req, _ := http.NewRequest("GET", "http://example.com/", nil)
		if c.ua != "" {
			req.Header.Set("User-Agent", c.ua)
		}
		res := p.applyUARejectRules(req)
		if c.wantKind == "" {
			if res != nil {
				t.Errorf("ua %q: got %+v, want nil", c.ua, res)
			}
			continue
		}
		if res == nil {
			t.Errorf("ua %q: got nil, want kind %q", c.ua, c.wantKind)
			continue
		}
		if res.Kind != c.wantKind || res.Status != c.wantStatus {
			t.Errorf("ua %q: got kind=%q status=%d, want kind=%q status=%d",
				c.ua, res.Kind, res.Status, c.wantKind, c.wantStatus)
		}
	}
}

func TestUpdateConfigCopiesRejectAndUARules(t *testing.T) {
	p := &Proxy{}
	p.UpdateConfig(Config{
		Enabled:     true,
		RejectRules: []RejectRule{{HostPattern: "a.example", Kind: "reject", Status: 502}},
		UARules:     []UARejectRule{mustUARejectRule(t, "BadBot*", "REJECT")},
	})
	if len(p.config.RejectRules) != 1 || p.config.RejectRules[0].HostPattern != "a.example" {
		t.Errorf("RejectRules not copied: %+v", p.config.RejectRules)
	}
	if len(p.config.UARules) != 1 || p.config.UARules[0].Pattern != "BadBot*" {
		t.Errorf("UARules not copied: %+v", p.config.UARules)
	}
	req, _ := http.NewRequest("GET", "http://example.com/", nil)
	req.Header.Set("User-Agent", "BadBot/2.0")
	if res := p.applyUARejectRules(req); res == nil || res.Kind != "reject" {
		t.Errorf("UA rule lost its compiled matcher across UpdateConfig: %+v", res)
	}
}

func TestUARejectEndToEnd(t *testing.T) {
	p := &Proxy{
		config: Config{Enabled: true, UARules: []UARejectRule{
			mustUARejectRule(t, "BadBot*", "REJECT-DICT"),
		}},
		scripts: NewScriptRegistry(),
	}
	upstreamHit := false
	p.testTransport = stubRT{fn: func(r *http.Request) (*http.Response, error) {
		upstreamHit = true
		return cannedResponse(200, http.Header{}, "upstream", 8), nil
	}}
	h := newPipeHarness(t, p, false)
	defer h.conn.Close()

	resp := h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\nUser-Agent: BadBot/1.0\r\n\r\n")
	if resp.StatusCode != 200 {
		t.Errorf("status = %d, want 200", resp.StatusCode)
	}
	if got := readBodyString(t, resp); got != "{}" {
		t.Errorf("body = %q, want %q", got, "{}")
	}
	if upstreamHit {
		t.Error("rejected request reached upstream")
	}

	resp = h.do("GET http://example.com/ HTTP/1.1\r\nHost: example.com\r\nUser-Agent: GoodBot/1.0\r\n\r\n")
	if got := readBodyString(t, resp); got != "upstream" {
		t.Errorf("body = %q, want upstream passthrough", got)
	}
	if !upstreamHit {
		t.Error("non-matching request did not reach upstream")
	}
}
