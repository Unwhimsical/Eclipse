package mitm

import (
	"context"
	"net"
	"net/netip"
	"strconv"

	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

// mitmProxyName is the http outbound Dart injects for MITM domains.
// pickProxy skips it so MITM upstream traffic never loops back into MITM.
const mitmProxyName = "Eclipse-MITM"

// pickProxy selects an outbound for MITM upstream traffic by replaying
// mihomo's rule matching. The MITM proxy itself is skipped to avoid loops.
func pickProxy(md *constant.Metadata) constant.Proxy {
	proxies := tunnel.Proxies()
	for _, rule := range tunnel.Rules() {
		matched, adapterName := rule.Match(md, constant.RuleMatchHelper{})
		if !matched {
			continue
		}
		if adapterName == mitmProxyName {
			continue
		}
		if p, ok := proxies[adapterName]; ok {
			return p
		}
	}
	if p, ok := proxies["DIRECT"]; ok {
		return p
	}
	return nil
}

// dialUpstream opens a TCP connection to host:port through the outbound
// selected by mihomo rules, instead of dialing directly. This keeps
// decrypted MITM traffic on the user's chosen node/policy.
func dialUpstream(ctx context.Context, host string, port uint16) (net.Conn, error) {
	md := &constant.Metadata{
		NetWork: constant.TCP,
		Type:    constant.HTTP,
		Host:    host,
		DstPort: port,
		SrcIP:   netip.MustParseAddr("127.0.0.1"),
	}
	proxy := pickProxy(md)
	if proxy == nil {
		return nil, &net.DNSError{Err: "mitm: no proxy available", Name: host}
	}
	if proxy.Type() == constant.Direct {
		if ip, err := resolver.ResolveIP(ctx, host); err == nil {
			md.DstIP = ip
		}
	}
	return proxy.DialContext(ctx, md)
}

// splitHostPort splits "host:port", falling back to defaultPort when the
// port is missing or invalid.
func splitHostPort(hostport string, defaultPort uint16) (string, uint16) {
	if h, p, err := net.SplitHostPort(hostport); err == nil {
		if n, err := strconv.Atoi(p); err == nil && n > 0 && n < 65536 {
			return h, uint16(n)
		}
		return h, defaultPort
	}
	return hostport, defaultPort
}
