package mitm

import "testing"

func TestMatchHostnameCaseInsensitive(t *testing.T) {
	p := &Proxy{}
	p.config.Enabled = true
	p.config.Hostnames = []string{"gs-loc.apple.com", "*.Example.ORG"}

	cases := []struct {
		host  string
		match bool
	}{
		{"gs-loc.apple.com", true},
		{"GS-LOC.APPLE.COM", true},
		{"Gs-Loc.Apple.Com", true},
		{"gs-loc.apple.com:443", true},
		{"sub.example.org", true},
		{"SUB.EXAMPLE.ORG", true},
		{"other.com", false},
		{"example.org", false},
	}
	for _, c := range cases {
		if got := p.matchHostname(c.host); got != c.match {
			t.Errorf("matchHostname(%q) = %v, want %v", c.host, got, c.match)
		}
	}
}
