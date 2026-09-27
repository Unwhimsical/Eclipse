// Package mitm implements a local HTTP(S) proxy with TLS interception,
// JavaScript script execution, and URL rewriting - compatible with
// Shadowrocket's MITM / Script / URL Rewrite features.
package mitm

import (
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"net"
	"sync"
)

// Config holds the MITM proxy configuration.
type Config struct {
	// Listen address, e.g. "127.0.0.1:9092".
	Listen string
	// CA certificate and key (PEM) for TLS interception.
	CACertPEM string
	CAKeyPEM  string
	// Hosts to intercept (from [MITM] hostname).
	Hosts []string
	// URL rewrite rules.
	Rewrites []RewriteRule
	// Scripts.
	Scripts []Script
	// Upstream proxy (Mihomo HTTP proxy) for forwarding, e.g. "127.0.0.1:7890".
	// Empty means direct.
	Upstream string
}

// RewriteRule is a parsed URL rewrite line.
type RewriteRule struct {
	Pattern string
	Target  string
	Status  string // 302, 307, REJECT, REJECT-DICT, etc.
}

// Script is a parsed [Script] entry.
type Script struct {
	Name        string
	Type        string // http-request, http-response
	Pattern     string
	RequiresBody bool
	// ScriptPath is a URL or local path to the JS file.
	ScriptPath string
	// Cached script content.
	Content string
}

// Proxy is the MITM proxy server.
type Proxy struct {
	config   Config
	caCert   *x509.Certificate
	caKey    *rsa.PrivateKey
	certCache sync.Map // host -> *tls.Certificate
	listener net.Listener
	mu       sync.RWMutex
	running  bool
}

// New creates a MITM proxy from config.
func New(cfg Config) (*Proxy, error) {
	p := &Proxy{config: cfg}
	if cfg.CACertPEM != "" && cfg.CAKeyPEM != "" {
		cert, err := tls.X509KeyPair([]byte(cfg.CACertPEM), []byte(cfg.CAKeyPEM))
		if err != nil {
			return nil, fmt.Errorf("mitm: invalid CA: %w", err)
		}
		caCert, err := x509.ParseCertificate(cert.Certificate[0])
		if err != nil {
			return nil, fmt.Errorf("mitm: parse CA cert: %w", err)
		}
		block, _ := pem.Decode([]byte(cfg.CAKeyPEM))
		if block == nil {
			return nil, fmt.Errorf("mitm: decode CA key")
		}
		caKey, err := x509.ParsePKCS1PrivateKey(block.Bytes)
		if err != nil {
			return nil, fmt.Errorf("mitm: parse CA key: %w", err)
		}
		p.caCert = caCert
		p.caKey = caKey
	}
	return p, nil
}

// ShouldIntercept reports whether the host should be TLS-intercepted.
func (p *Proxy) ShouldIntercept(host string) bool {
	p.mu.RLock()
	defer p.mu.RUnlock()
	for _, h := range p.config.Hosts {
		if matchHost(h, host) {
			return true
		}
	}
	return false
}

// matchHost supports exact, *.suffix, and prefix* patterns.
func matchHost(pattern, host string) bool {
	if pattern == host {
		return true
	}
	if len(pattern) > 2 && pattern[:2] == "*." {
		suffix := pattern[1:]
		return len(host) > len(suffix) && host[len(host)-len(suffix):] == suffix
	}
	if len(pattern) > 1 && pattern[len(pattern)-1] == '*' {
		prefix := pattern[:len(pattern)-1]
		return len(host) >= len(prefix) && host[:len(prefix)] == prefix
	}
	return false
}

// UpdateConfig replaces the proxy configuration at runtime.
func (p *Proxy) UpdateConfig(cfg Config) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.config.Hosts = cfg.Hosts
	p.config.Rewrites = cfg.Rewrites
	p.config.Scripts = cfg.Scripts
	p.config.Upstream = cfg.Upstream
}

// IsRunning reports whether the proxy is serving.
func (p *Proxy) IsRunning() bool {
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.running
}
