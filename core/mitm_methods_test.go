package main

import "testing"

func TestMitmConfigRewritePlaceholders(t *testing.T) {
	cases := []struct {
		target string
		status string
		action string
	}{
		{"-", "reject", "reject"},
		{"-", "reject-200", "reject-200"},
		{"-", "reject-dict", "reject-dict"},
		{"-", "reject-array", "reject-array"},
		{"-", "reject-img", "reject-img"},
		{"-", "302", "reject"},
		{"_", "reject", "reject"},
		{"_", "reject-200", "reject-200"},
		{"_", "reject-video", "reject-video"},
		{"reject-200", "302", "reject-200"},
		{"reject", "302", "reject"},
		{"https://example.com", "302", "redirect"},
		{"https://example.com", "307", "redirect"},
	}
	for _, c := range cases {
		cfg, err := mitmConfigFromArgs(map[string]interface{}{
			"caCert": "dummy",
			"caKey":  "dummy",
			"rewrites": []interface{}{
				map[string]interface{}{
					"pattern": `^https://a\.com`,
					"target":  c.target,
					"status":  c.status,
				},
			},
		})
		if err != nil {
			t.Fatalf("target %q status %q: unexpected error %v", c.target, c.status, err)
		}
		if len(cfg.Rewrites) != 1 {
			t.Fatalf("target %q status %q: got %d rules, want 1", c.target, c.status, len(cfg.Rewrites))
		}
		if got := cfg.Rewrites[0].Action; got != c.action {
			t.Errorf("target %q status %q: action = %q, want %q", c.target, c.status, got, c.action)
		}
	}
}
