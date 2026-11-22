package main

import (
	"net"
	"testing"
	"time"
)

func TestProbeTCP(t *testing.T) {
	if probeTCP("", time.Second) != -1 {
		t.Fatal("empty address")
	}
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer ln.Close()
	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			_ = conn.Close()
		}
	}()
	if probeTCP(ln.Addr().String(), time.Second) <= 0 {
		t.Fatal("expected a positive handshake delay")
	}
	if probeTCP("127.0.0.1:1", 200*time.Millisecond) != -1 {
		t.Fatal("closed port")
	}
}

func TestProbeICMPEmpty(t *testing.T) {
	if probeICMP("", time.Second) != -1 {
		t.Fatal("empty address")
	}
}

func TestHandleTestDelayTCPMissingProxy(t *testing.T) {
	got := handleTestDelay(&TestDelayParams{
		ProxyName: "missing-tcp",
		Timeout:   50,
		Method:    "tcp",
	})
	if got == nil || got.Value != -1 {
		t.Fatalf("delay = %+v, want -1", got)
	}
}
