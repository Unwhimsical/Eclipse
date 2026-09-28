package mitm

import (
	"bufio"
	"crypto/tls"
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
	if res := p.applyRewrite(req); res != nil {
		w := newConnWriter(conn, req)
		writeRewriteResult(w, res)
		_ = w.finish()
		return
	}
	p.forward(conn, req, isTLS)
}

func (p *Proxy) tunnelRaw(conn net.Conn, req *http.Request) {
	host := req.Host
	if host == "" {
		host = req.URL.Host
	}
	if _, _, err := net.SplitHostPort(host); err != nil {
		host = net.JoinHostPort(host, "443")
	}
	up, err := net.DialTimeout("tcp", host, 15*time.Second)
	if err != nil {
		_, _ = io.WriteString(conn, "HTTP/1.1 502 Bad Gateway\r\n\r\n")
		return
	}
	defer up.Close()
	_, _ = io.WriteString(conn, "HTTP/1.1 200 Connection Established\r\n\r\n")
	go io.Copy(up, conn)
	_, _ = io.Copy(conn, up)
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
	client := &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			DialContext: (&net.Dialer{
				Timeout: 15 * time.Second,
			}).DialContext,
		},
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
	resp, err := client.Do(out)
	if err != nil {
		return
	}
	defer resp.Body.Close()
	w := newConnWriter(conn, req)
	for k, vv := range resp.Header {
		for _, v := range vv {
			w.Header().Add(k, v)
		}
	}
	w.WriteHeader(resp.StatusCode)
	_, _ = io.Copy(w, resp.Body)
	_ = w.finish()
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
