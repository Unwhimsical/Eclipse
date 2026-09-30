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

// Shadowrocket semantics: "-" / "!" exclusions take priority over
// inclusions, so an excluded host under a wildcard is not intercepted.
func TestMatchHostnameExclusionPriority(t *testing.T) {
	p := &Proxy{}
	p.config.Enabled = true
	p.config.Hostnames = []string{"*.example.com", "-foo.example.com"}

	cases := []struct {
		host  string
		match bool
	}{
		{"foo.example.com", false},
		{"FOO.EXAMPLE.COM", false},
		{"foo.example.com:443", false},
		{"bar.example.com", true},
		{"example.com", false},
		{"other.com", false},
	}
	for _, c := range cases {
		if got := p.matchHostname(c.host); got != c.match {
			t.Errorf("matchHostname(%q) = %v, want %v", c.host, got, c.match)
		}
	}
}

func TestMatchHostnameExclusionBangPrefix(t *testing.T) {
	p := &Proxy{}
	p.config.Enabled = true
	p.config.Hostnames = []string{"*.example.com", "!blocked.example.com"}

	for host, want := range map[string]bool{
		"blocked.example.com": false,
		"ok.example.com":      true,
	} {
		if got := p.matchHostname(host); got != want {
			t.Errorf("matchHostname(%q) = %v, want %v", host, got, want)
		}
	}
}

func TestMatchHostnameExclusionWildcard(t *testing.T) {
	p := &Proxy{}
	p.config.Enabled = true
	p.config.Hostnames = []string{"*.example.com", "-*.internal.example.com"}

	for host, want := range map[string]bool{
		"a.internal.example.com": false,
		"b.example.com":          true,
	} {
		if got := p.matchHostname(host); got != want {
			t.Errorf("matchHostname(%q) = %v, want %v", host, got, want)
		}
	}
}

func TestMatchHostnameExclusionOnly(t *testing.T) {
	p := &Proxy{}
	p.config.Enabled = true
	p.config.Hostnames = []string{"-foo.example.com"}

	for host, want := range map[string]bool{
		"foo.example.com": false,
		"bar.example.com": false,
	} {
		if got := p.matchHostname(host); got != want {
			t.Errorf("matchHostname(%q) = %v, want %v", host, got, want)
		}
	}
}

func TestMatchHostnameSkipsDirectives(t *testing.T) {
	p := &Proxy{}
	p.config.Enabled = true
	p.config.Hostnames = []string{"%APPEND%", "example.com"}

	for host, want := range map[string]bool{
		"example.com": true,
		"%append%":    false,
	} {
		if got := p.matchHostname(host); got != want {
			t.Errorf("matchHostname(%q) = %v, want %v", host, got, want)
		}
	}
}
