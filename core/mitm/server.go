package mitm

import (
	"bufio"
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io"
	"net"
	"net/http"
	"strconv"
	"time"
)

func (p *Proxy) handleConn(conn net.Conn) {
	defer conn.Close()
	br := bufio.NewReader(conn)
	req, err := http.ReadRequest(br)
	if err != nil {
		return
	}
	if req.Method == http.MethodConnect {
		p.handleConnect(conn, req)
		return
	}
	p.handleHTTP(conn, req, false)
}

func (p *Proxy) handleConnect(conn net.Conn, req *http.Request) {
	host := req.Host
	if host == "" {
		host = req.URL.Host
	}
	if !p.matchHostname(host) {
		p.tunnelRaw(conn, req)
		return
	}
	if _, err := io.WriteString(conn, "HTTP/1.1 200 Connection Established\r\n\r\n"); err != nil {
		return
	}
	cert, err := p.certForHost(host)
	if err != nil {
		return
	}
	tlsConn := tls.Server(conn, &tls.Config{Certificates: []tls.Certificate{*cert}})
	if err := tlsConn.Handshake(); err != nil {
		tlsConn.Close()
		return
	}
	defer tlsConn.Close()
	br := bufio.NewReader(tlsConn)
	for {
		tlsConn.SetReadDeadline(time.Now().Add(60 * time.Second))
		inner, err := http.ReadRequest(br)
		if err != nil {
			return
		}
		p.handleHTTP(tlsConn, inner, true)
		if inner.Close {
			return
		}
	}
}

func (p *Proxy) handleHTTP(conn net.Conn, req *http.Request, isTLS bool) {
	// Build the full URL for rewrite matching. CONNECT-decrypted inner
	// requests are origin-form (URL has path only), so reconstruct it.
	fullURL := req.URL.String()
	if req.URL.Host == "" {
		scheme := "http"
		if isTLS {
			scheme = "https"
		}
		fullURL = scheme + "://" + req.Host + req.URL.RequestURI()
	}
	if res := p.applyRewrite(req, fullURL); res != nil {
		w := newConnWriter(conn, req)
		writeRewriteResult(w, res)
		_ = w.finish()
		return
	}
	if res := p.applyMapLocal(fullURL); res != nil {
		w := newConnWriter(conn, req)
		writeMapLocalResult(w, req, res)
		_ = w.finish()
		return
	}
	p.applyRequestBodyRewrites(fullURL, req)
	// http-request scripts: may rewrite the request or synthesize a response.
	if p.scripts != nil {
		if done, handled := p.runRequestScripts(req, fullURL, isTLS); handled {
			w := newConnWriter(conn, req)
			if done != nil {
				writeScriptResult(w, done)
			}
			_ = w.finish()
			return
		}
	}
	// Granular reject rules from [Rule] (REJECT-DICT & co.): render the
	// graceful empty response instead of forwarding upstream.
	if res := p.applyRejectRules(req); res != nil {
		w := newConnWriter(conn, req)
		writeRewriteResult(w, res)
		_ = w.finish()
		return
	}
	// USER-AGENT granular rejects: match the request User-Agent header.
	if res := p.applyUARejectRules(req); res != nil {
		w := newConnWriter(conn, req)
		writeRewriteResult(w, res)
		_ = w.finish()
		return
	}
	// Header rewrites: modify request headers before forwarding upstream.
	p.applyHeaderRewrites(req, fullURL)
	p.forward(conn, req, isTLS)
}

func (p *Proxy) tunnelRaw(conn net.Conn, req *http.Request) {
	host := req.Host
	if host == "" {
		host = req.URL.Host
	}
	h, port := splitHostPort(host, 443)
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	// Route through the mihomo proxy chain, not direct.
	up, err := dialUpstream(ctx, h, port)
	if err != nil {
		_, _ = io.WriteString(conn, "HTTP/1.1 502 Bad Gateway\r\n\r\n")
		return
	}
	defer up.Close()
	_, _ = io.WriteString(conn, "HTTP/1.1 200 Connection Established\r\n\r\n")
	go io.Copy(up, conn)
	_, _ = io.Copy(conn, up)
}

// upstreamTLSConfig builds a verifying TLS config for upstream connections.
// InsecureSkipVerify is never used: a failed verification drops the connection.
func (p *Proxy) upstreamTLSConfig(host string) *tls.Config {
	roots, err := x509.SystemCertPool()
	if err != nil || roots == nil {
		roots = x509.NewCertPool()
	}
	return &tls.Config{
		ServerName: host,
		RootCAs:    roots,
		MinVersion: tls.VersionTLS12,
	}
}

// upstreamTransport dials upstream via the mihomo chain; tests override it.
func (p *Proxy) upstreamTransport() http.RoundTripper {
	if p.testTransport != nil {
		return p.testTransport
	}
	dialTCP := func(ctx context.Context, _, addr string) (net.Conn, error) {
		h, port := splitHostPort(addr, 80)
		return dialUpstream(ctx, h, port)
	}
	dialTLS := func(ctx context.Context, _, addr string) (net.Conn, error) {
		h, port := splitHostPort(addr, 443)
		raw, err := dialUpstream(ctx, h, port)
		if err != nil {
			return nil, err
		}
		tlsConn := tls.Client(raw, p.upstreamTLSConfig(h))
		if err := tlsConn.HandshakeContext(ctx); err != nil {
			raw.Close()
			return nil, err
		}
		return tlsConn, nil
	}
	return &http.Transport{
		DialContext:    dialTCP,
		DialTLSContext: dialTLS,
	}
}

func (p *Proxy) forward(conn net.Conn, req *http.Request, isTLS bool) {
	scheme := "http"
	if isTLS {
		scheme = "https"
	}
	target := *req.URL
	if target.Scheme == "" {
		target.Scheme = scheme
	}
	if target.Host == "" {
		target.Host = req.Host
	}
	out, err := http.NewRequest(req.Method, target.String(), req.Body)
	if err != nil {
		return
	}
	out.Header = req.Header.Clone()
	out.Header.Del("Proxy-Connection")
	out.Header.Del("Proxy-Authorization")
	// NewRequest can't infer a server-parsed body's length; copy it to avoid re-chunking.
	out.ContentLength = req.ContentLength
	out.Close = req.Close
	// Upstream goes through the mihomo proxy chain with real TLS verification.
	client := &http.Client{
		Timeout:   30 * time.Second,
		Transport: p.upstreamTransport(),
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	resp, err := client.Do(out)
	if err != nil {
		w := newConnWriter(conn, req)
		w.Header().Set("Content-Length", "0")
		w.WriteHeader(http.StatusBadGateway)
		_ = w.finish()
		return
	}
	defer resp.Body.Close()

	// http-response scripts: may modify status/headers/body.
	var scriptBody []byte
	if p.scripts != nil {
		// Reconstruct full URL for pattern matching.
		scriptURL := out.URL.String()
		scriptBody = p.runResponseScripts(scriptURL, resp)
	}

	finalBody, haveFinal := scriptBody, scriptBody != nil
	if responseHasBody(resp.StatusCode, req.Method) {
		if rb, ok := p.applyResponseBodyRewrites(out.URL.String(), resp, finalBody, haveFinal); ok {
			finalBody, haveFinal = rb, true
		}
	}

	p.applyResponseHeaderRewrites(resp, out.URL.String())

	w := newConnWriter(conn, req)
	for k, vv := range resp.Header {
		for _, v := range vv {
			w.Header().Add(k, v)
		}
	}
	w.Header().Del("Transfer-Encoding")
	w.WriteHeader(resp.StatusCode)
	if haveFinal {
		w.Header().Set("Content-Length", strconv.Itoa(len(finalBody)))
		if responseHasBody(resp.StatusCode, req.Method) {
			_, _ = w.Write(finalBody)
		}
	} else if !responseHasBody(resp.StatusCode, req.Method) {
	} else if resp.ContentLength >= 0 {
		w.Header().Set("Content-Length", strconv.FormatInt(resp.ContentLength, 10))
		n, _ := io.Copy(w, resp.Body)
		if n < resp.ContentLength {
			// Truncated upstream: close so the client sees EOF instead of hanging.
			_ = conn.Close()
		}
	} else {
		w.Header().Set("Transfer-Encoding", "chunked")
		writeChunked(w, resp.Body)
	}
	_ = w.finish()
}

func responseHasBody(status int, method string) bool {
	if method == http.MethodHead {
		return false
	}
	switch {
	case status >= 100 && status <= 199,
		status == http.StatusNoContent,
		status == http.StatusNotModified:
		return false
	}
	return true
}

// writeChunked streams r chunked; on mid-body read error the terminator is omitted.
func writeChunked(w io.Writer, r io.Reader) {
	buf := make([]byte, 32*1024)
	for {
		n, rerr := r.Read(buf)
		if n > 0 {
			_, _ = fmt.Fprintf(w, "%x\r\n", n)
			_, _ = w.Write(buf[:n])
			_, _ = io.WriteString(w, "\r\n")
		}
		if rerr != nil {
			if rerr == io.EOF {
				_, _ = io.WriteString(w, "0\r\n\r\n")
			}
			return
		}
	}
}

type connWriter struct {
	conn   net.Conn
	header http.Header
	status int
	wrote  bool
}

func newConnWriter(conn net.Conn, req *http.Request) *connWriter {
	return &connWriter{conn: conn, header: make(http.Header), status: 200}
}

func (w *connWriter) Header() http.Header { return w.header }

func (w *connWriter) Write(b []byte) (int, error) {
	if !w.wrote {
		w.writeHead()
	}
	return w.conn.Write(b)
}

func (w *connWriter) WriteHeader(status int) { w.status = status }

func (w *connWriter) writeHead() {
	w.wrote = true
	_, _ = io.WriteString(w.conn, "HTTP/1.1 "+strconv.Itoa(w.status)+" "+http.StatusText(w.status)+"\r\n")
	for k, vv := range w.header {
		for _, v := range vv {
			_, _ = io.WriteString(w.conn, k+": "+v+"\r\n")
		}
	}
	_, _ = io.WriteString(w.conn, "\r\n")
}

func (w *connWriter) finish() error {
	if !w.wrote {
		w.writeHead()
	}
	return nil
}
