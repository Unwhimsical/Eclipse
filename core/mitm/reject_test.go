package mitm

import (
	"net/http"
	"strings"
	"testing"
)

func TestMatchPatternContains(t *testing.T) {
	cases := []struct {
		pat, host string
		want      bool
	}{
		{"*ads*", "myadsx.com", true},
		{"*ads*", "ads.com", true},
		{"*ads*", "example.com", false},
		{"*ADS*", "myadsx.com", false}, // matchPattern itself is case-sensitive; callers lowercase
		{"**", "example.com", false},
		{"*a*", "a", true},
	}
	for _, c := range cases {
		if got := matchPattern(c.pat, c.host); got != c.want {
			t.Errorf("matchPattern(%q, %q) = %v, want %v", c.pat, c.host, got, c.want)
		}
	}
}

func rejectTestProxy() *Proxy {
	return &Proxy{
		config: Config{
			Enabled: true,
			RejectRules: []RejectRule{
				{HostPattern: "*.dict.example", Kind: "reject-json", Status: 200},
				{HostPattern: "*.array.example", Kind: "reject-array", Status: 200},
				{HostPattern: "*.empty.example", Kind: "reject", Status: 200},
				{HostPattern: "*.img.example", Kind: "reject-img", Status: 200},
				{HostPattern: "*.video.example", Kind: "reject-video", Status: 200},
				{HostPattern: "*keyword*", Kind: "reject-json", Status: 200},
				{HostPattern: "exact.example", Kind: "reject", Status: 200},
			},
		},
		scripts: NewScriptRegistry(),
	}
}

func TestApplyRejectRules(t *testing.T) {
	p := rejectTestProxy()
	cases := []struct {
		host       string
		wantKind   string
		wantStatus int
	}{
		{"a.dict.example", "reject-json", 200},
		{"A.DICT.EXAMPLE", "reject-json", 200},
		{"a.dict.example:443", "reject-json", 200},
		{"b.array.example", "reject-array", 200},
		{"c.empty.example", "reject", 200},
		{"d.img.example", "reject-img", 200},
		{"e.video.example", "reject-video", 200},
		{"mykeywordads.com", "reject-json", 200},
		{"exact.example", "reject", 200},
		{"sub.exact.example", "", 0},
		{"unrelated.com", "", 0},
	}
	for _, c := range cases {
		req, _ := http.NewRequest("GET", "http://"+c.host+"/", nil)
		req.Host = c.host
		res := p.applyRejectRules(req)
		if c.wantKind == "" {
			if res != nil {
				t.Errorf("host %q: got %+v, want nil", c.host, res)
			}
			continue
		}
		if res == nil {
			t.Errorf("host %q: got nil, want kind %q", c.host, c.wantKind)
			continue
		}
		if res.Kind != c.wantKind || res.Status != c.wantStatus {
			t.Errorf("host %q: got kind=%q status=%d, want kind=%q status=%d",
				c.host, res.Kind, res.Status, c.wantKind, c.wantStatus)
		}
	}
}

func TestRejectActionForTarget(t *testing.T) {
	cases := []struct {
		target, want string
	}{
		{"-", "reject"},
		{"reject", "reject"},
		{"REJECT", "reject"},
		{"reject-200", "reject-200"},
		{"reject-dict", "reject-dict"},
		{"reject-json", "reject-dict"},
		{"reject-array", "reject-array"},
		{"reject-img", "reject-img"},
		{"reject-tinygif", "reject-img"},
		{"reject-video", "reject-video"},
		{"reject-nodrop", "reject-nodrop"},
		{"reject-no-drop", "reject-nodrop"},
		{"reject-bogus", "reject"},
	}
	for _, c := range cases {
		if got := RejectActionForTarget(c.target); got != c.want {
			t.Errorf("RejectActionForTarget(%q) = %q, want %q", c.target, got, c.want)
		}
	}
}

func TestRejectEndToEnd(t *testing.T) {
	p := rejectTestProxy()
	upstreamHit := false
	p.testTransport = stubRT{fn: func(r *http.Request) (*http.Response, error) {
		upstreamHit = true
		return cannedResponse(200, http.Header{}, "upstream", 8), nil
	}}
	h := newPipeHarness(t, p, false)
	defer h.conn.Close()

	cases := []struct {
		host            string
		wantStatus      int
		wantBody        string
		wantContentType string
	}{
		{"a.dict.example", 200, "{}", "application/json"},
		{"b.array.example", 200, "[]", "application/json"},
		{"c.empty.example", 200, "", ""},
		{"e.video.example", 200, "", "video/mp4"},
	}
	for _, c := range cases {
		resp := h.do("GET http://" + c.host + "/ HTTP/1.1\r\nHost: " + c.host + "\r\n\r\n")
		if resp.StatusCode != c.wantStatus {
			t.Errorf("host %q: status = %d, want %d", c.host, resp.StatusCode, c.wantStatus)
		}
		if got := readBodyString(t, resp); got != c.wantBody {
			t.Errorf("host %q: body = %q, want %q", c.host, got, c.wantBody)
		}
		if c.wantContentType != "" && resp.Header.Get("Content-Type") != c.wantContentType {
			t.Errorf("host %q: content-type = %q, want %q",
				c.host, resp.Header.Get("Content-Type"), c.wantContentType)
		}
	}
	// Image body must be the 1x1 transparent GIF.
	resp := h.do("GET http://d.img.example/i HTTP/1.1\r\nHost: d.img.example\r\n\r\n")
	body := readBodyString(t, resp)
	if !strings.HasPrefix(body, "GIF89a") || resp.Header.Get("Content-Type") != "image/gif" {
		t.Errorf("img body = %q..., content-type = %q", body[:min(6, len(body))], resp.Header.Get("Content-Type"))
	}
	// Unmatched host must reach upstream untouched.
	resp = h.do("GET http://unrelated.com/ HTTP/1.1\r\nHost: unrelated.com\r\n\r\n")
	if got := readBodyString(t, resp); got != "upstream" {
		t.Errorf("unrelated host body = %q, want upstream passthrough", got)
	}
	if !upstreamHit {
		t.Error("unrelated host did not reach upstream")
	}
}
