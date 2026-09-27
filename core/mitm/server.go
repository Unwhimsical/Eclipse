package mitm

import (
	"bufio"
	"crypto/tls"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// Start begins serving the MITM proxy.
func (p *Proxy) Start() error {
	p.mu.Lock()
	if p.running {
		p.mu.Unlock()
		return nil
	}
	ln, err := net.Listen("tcp", p.config.Listen)
	if err != nil {
		p.mu.Unlock()
		return fmt.Errorf("mitm: listen %s: %w", p.config.Listen, err)
	}
	p.listener = ln
	p.running = true
	p.mu.Unlock()

	go p.serve(ln)
	return nil
}

// Stop shuts down the proxy.
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

func (p *Proxy) serve(ln net.Listener) {
	for {
		conn, err := ln.Accept()
		if err != nil {
			return
		}
		go p.handleConn(conn)
	}
}

func (p *Proxy) handleConn(conn net.Conn) {
	defer conn.Close()
	br := bufio.NewReader(conn)
	req, err := http.ReadRequest(br)
	if err != nil {
		return
	}
	if req.Method == http.MethodConnect {
		p.handleConnect(conn, br, req)
		return
	}
	p.handleHTTP(conn, br, req, false)
}

// handleConnect handles HTTPS CONNECT. If the host is in the MITM list,
// perform TLS interception; otherwise tunnel transparently.
func (p *Proxy) handleConnect(conn net.Conn, br *bufio.Reader, req *http.Request) {
	host := req.Host
	if h, _, err := net.SplitHostPort(host); err == nil {
		host = h
	}
	if !p.ShouldIntercept(host) {
		p.tunnel(conn, br, req)
		return
	}
	// MITM: acknowledge CONNECT, then TLS handshake with generated cert.
	fmt.Fprintf(conn, "HTTP/1.1 200 Connection Established\r\n\r\n")
	cert, err := p.getCert(host)
	if err != nil {
		return
	}
	tlsConn := tls.Server(conn, &tls.Config{
		Certificates: []tls.Certificate{*cert},
	})
	if err := tlsConn.Handshake(); err != nil {
		tlsConn.Close()
		return
	}
	defer tlsConn.Close()
	tlsReader := bufio.NewReader(tlsConn)
	for {
		tlsReader.Reset(tlsConn)
		req, err := http.ReadRequest(tlsReader)
		if err != nil {
			return
		}
		// Ensure absolute URL for forwarding.
		if !req.URL.IsAbs() {
			req.URL.Scheme = "https"
			req.URL.Host = host
		}
		p.handleHTTP(tlsConn, tlsReader, req, true)
		if req.Close {
			return
		}
	}
}

// tunnel transparently proxies a CONNECT tunnel upstream.
func (p *Proxy) handleConnectTunnel(conn net.Conn, br *bufio.Reader, req *http.Request) {
	p.tunnel(conn, br, req)
}

func (p *Proxy) tunnel(conn net.Conn, br *bufio.Reader, req *http.Request) {
	upstream, err := p.dialUpstream(req.Host)
	if err != nil {
		fmt.Fprintf(conn, "HTTP/1.1 502 Bad Gateway\r\n\r\n")
		return
	}
	defer upstream.Close()
	fmt.Fprintf(conn, "HTTP/1.1 200 Connection Established\r\n\r\n")
	go io.Copy(upstream, br)
	io.Copy(conn, upstream)
}

// dialUpstream dials the target directly, or via the configured upstream
// HTTP proxy.
func (p *Proxy) dialUpstream(addr string) (net.Conn, error) {
	if _, _, err := net.SplitHostPort(addr); err != nil {
		addr = net.JoinHostPort(addr, "443")
	}
	if p.config.Upstream == "" {
		return net.DialTimeout("tcp", addr, 10*time.Second)
	}
	// Via upstream HTTP proxy.
	proxyConn, err := net.DialTimeout("tcp", p.config.Upstream, 10*time.Second)
	if err != nil {
		return nil, err
	}
	fmt.Fprintf(proxyConn, "CONNECT %s HTTP/1.1\r\nHost: %s\r\n\r\n", addr, addr)
	br := bufio.NewReader(proxyConn)
	resp, err := http.ReadResponse(br, nil)
	if err != nil {
		proxyConn.Close()
		return nil, err
	}
	resp.Body.Close()
	if resp.StatusCode != 200 {
		proxyConn.Close()
		return nil, fmt.Errorf("mitm: upstream CONNECT %d", resp.StatusCode)
	}
	return proxyConn, nil
}

// handleHTTP processes a decrypted HTTP request: URL rewrite, scripts,
// then forward upstream and relay the response.
func (p *Proxy) handleHTTP(conn net.Conn, br *bufio.Reader, req *http.Request, isTLS bool) {
	// 1. URL Rewrite (request).
	if resp := p.applyRewrite(req); resp != nil {
		resp.Write(conn)
		return
	}
	// 2. http-request scripts.
	if resp := p.runRequestScripts(req); resp != nil {
		writeResponse(conn, req, resp)
		return
	}
	// 3. Forward upstream.
	upResp, err := p.forward(req, isTLS)
	if err != nil {
		writeError(conn, req, 502)
		return
	}
	defer upResp.Body.Close()
	// 4. http-response scripts.
	upResp = p.runResponseScripts(req, upResp)
	// 5. Relay.
	upResp.Write(conn)
}

// forward sends the request upstream (direct or via upstream proxy).
func (p *Proxy) forward(req *http.Request, isTLS bool) (*http.Response, error) {
	outReq := req.Clone(req.Context())
	outReq.RequestURI = ""
	transport := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	if p.config.Upstream != "" {
		proxyURL, err := parseProxyURL(p.config.Upstream)
		if err == nil {
			transport.Proxy = http.ProxyURL(proxyURL)
		}
	}
	client := &http.Client{
		Transport: transport,
		Timeout:   30 * time.Second,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	return client.Do(outReq)
}

func parseProxyURL(addr string) (*url.URL, error) {
	if !strings.Contains(addr, "://") {
		addr = "http://" + addr
	}
	return url.Parse(addr)
}

func writeResponse(conn net.Conn, req *http.Request, resp *http.Response) {
	resp.Write(conn)
}

func writeError(conn net.Conn, req *http.Request, code int) {
	resp := &http.Response{
		StatusCode: code,
		ProtoMajor: 1,
		ProtoMinor: 1,
		Header:     make(http.Header),
		Body:       io.NopCloser(strings.NewReader(http.StatusText(code))),
	}
	resp.Write(conn)
}
