package main

import (
	"net"
	"os"
	"time"

	"golang.org/x/net/icmp"
	"golang.org/x/net/ipv4"
	"golang.org/x/net/ipv6"
)

func probeTCP(addr string, timeout time.Duration) int32 {
	if addr == "" {
		return -1
	}
	started := time.Now()
	conn, err := net.DialTimeout("tcp", addr, timeout)
	if err != nil {
		return -1
	}
	_ = conn.Close()
	return clampDelay(time.Since(started))
}

func probeICMP(addr string, timeout time.Duration) int32 {
	host := icmpHost(addr)
	if host == "" {
		return -1
	}
	ips, err := net.LookupIP(host)
	if err != nil {
		return -1
	}
	for _, ip := range ips {
		if ip4 := ip.To4(); ip4 != nil {
			if delay := echoDelay("udp4", ip4, timeout, false); delay > 0 {
				return delay
			}
		}
	}
	for _, ip := range ips {
		if ip.To4() == nil {
			if delay := echoDelay("udp6", ip, timeout, true); delay > 0 {
				return delay
			}
		}
	}
	return -1
}

func icmpHost(addr string) string {
	host, _, err := net.SplitHostPort(addr)
	if err != nil {
		return addr
	}
	return host
}

func clampDelay(elapsed time.Duration) int32 {
	ms := elapsed.Milliseconds()
	if ms <= 0 {
		return 1
	}
	if ms > 65535 {
		return 65535
	}
	return int32(ms)
}

func echoDelay(network string, ip net.IP, timeout time.Duration, ipv6Echo bool) int32 {
	conn, err := icmp.ListenPacket(network, "")
	if err != nil {
		return -1
	}
	defer conn.Close()

	message := icmp.Message{
		Code: 0,
		Body: &icmp.Echo{
			ID:   os.Getpid() & 0xffff,
			Seq:  1,
			Data: []byte("eclipse"),
		},
	}
	protocol := 1
	if ipv6Echo {
		message.Type = ipv6.ICMPTypeEchoRequest
		protocol = 58
	} else {
		message.Type = ipv4.ICMPTypeEcho
	}
	payload, err := message.Marshal(nil)
	if err != nil {
		return -1
	}
	started := time.Now()
	if _, err = conn.WriteTo(payload, &net.UDPAddr{IP: ip}); err != nil {
		return -1
	}
	_ = conn.SetReadDeadline(time.Now().Add(timeout))
	buffer := make([]byte, 1500)
	for {
		n, _, err := conn.ReadFrom(buffer)
		if err != nil {
			return -1
		}
		reply, err := icmp.ParseMessage(protocol, buffer[:n])
		if err != nil {
			continue
		}
		if _, ok := reply.Body.(*icmp.Echo); ok {
			return clampDelay(time.Since(started))
		}
	}
}
