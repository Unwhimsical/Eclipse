package mitm

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"net"
	"sync"
)

type Config struct {
	Enabled    bool
	ListenAddr string
	CACertPEM  string
	CAKeyPEM   string
	Hostnames  []string
	Rewrites   []RewriteRule
}

type Proxy struct {
	config    Config
	caCert    *x509.Certificate
	caKey     *rsa.PrivateKey
	certCache sync.Map
	listener  net.Listener
	mu        sync.RWMutex
	running   bool
}

func New(cfg Config) (*Proxy, error) {
	p := &Proxy{config: cfg}
	if err := p.loadCA(); err != nil {
		return nil, err
	}
	return p, nil
}

func (p *Proxy) loadCA() error {
	certBlock, _ := pem.Decode([]byte(p.config.CACertPEM))
	if certBlock == nil {
		return fmt.Errorf("mitm: invalid CA certificate PEM")
	}
	cert, err := x509.ParseCertificate(certBlock.Bytes)
	if err != nil {
		return fmt.Errorf("mitm: parse CA certificate: %w", err)
	}
	keyBlock, _ := pem.Decode([]byte(p.config.CAKeyPEM))
	if keyBlock == nil {
		return fmt.Errorf("mitm: invalid CA private key PEM")
	}
	key, err := x509.ParsePKCS1PrivateKey(keyBlock.Bytes)
	if err != nil {
		k, err2 := x509.ParsePKCS8PrivateKey(keyBlock.Bytes)
		if err2 != nil {
			return fmt.Errorf("mitm: parse CA private key: %w", err)
		}
		var ok bool
		key, ok = k.(*rsa.PrivateKey)
		if !ok {
			return fmt.Errorf("mitm: CA private key is not RSA")
		}
	}
	p.caCert = cert
	p.caKey = key
	return nil
}

func (p *Proxy) IsRunning() bool {
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.running
}

func (p *Proxy) Start() error {
	p.mu.Lock()
	if p.running {
		p.mu.Unlock()
		return fmt.Errorf("mitm: proxy already running")
	}
	ln, err := net.Listen("tcp", p.config.ListenAddr)
	if err != nil {
		p.mu.Unlock()
		return fmt.Errorf("mitm: listen %s: %w", p.config.ListenAddr, err)
	}
	p.listener = ln
	p.running = true
	p.mu.Unlock()
	go p.serve()
	return nil
}

func (p *Proxy) Stop() error {
	p.mu.Lock()
	defer p.mu.Unlock()
	if !p.running {
		return nil
	}
	p.running = false
	if p.listener != nil {
		return p.listener.Close()
	}
	return nil
}

func (p *Proxy) UpdateConfig(cfg Config) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.config.Hostnames = cfg.Hostnames
	p.config.Rewrites = cfg.Rewrites
	p.config.Enabled = cfg.Enabled
}

func (p *Proxy) serve() {
	for {
		conn, err := p.listener.Accept()
		if err != nil {
			return
		}
		go p.handleConn(conn)
	}
}

func (p *Proxy) matchHostname(host string) bool {
	p.mu.RLock()
	patterns := p.config.Hostnames
	enabled := p.config.Enabled
	p.mu.RUnlock()
	if !enabled {
		return false
	}
	if h, _, err := net.SplitHostPort(host); err == nil {
		host = h
	}
	for _, pat := range patterns {
		if pat == "" {
			continue
		}
		if pat == host {
			return true
		}
		if len(pat) > 2 && pat[:2] == "*." {
			suffix := pat[1:]
			if len(host) > len(suffix) && host[len(host)-len(suffix):] == suffix {
				return true
			}
			continue
		}
		if len(pat) > 1 && pat[len(pat)-1] == '*' {
			if len(host) >= len(pat)-1 && host[:len(pat)-1] == pat[:len(pat)-1] {
				return true
			}
		}
	}
	return false
}
