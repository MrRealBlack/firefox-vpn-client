//go:build ios

package mobile

import (
	"context"
	"errors"
	"github.com/armanlife/firefox-vpn-client/core/internal/tun"
	"net"
)

var packets *tun.PacketTunnel

// StartPacketTunnel attaches Apple's NEPacketTunnelFlow to the running
// core. The extension must start the core first and install its network
// settings before submitting packets. iOS excludes the provider's own
// sockets from its tunnel; do not extract a private utun file descriptor.
func StartPacketTunnel() error {
	mu.Lock()
	defer mu.Unlock()
	if running == nil {
		return errors.New("the core does not run")
	}
	if packets != nil {
		return errors.New("the packet tunnel already runs")
	}
	d := running
	dial := func(ctx context.Context, target string) (net.Conn, error) {
		addr, user, password := d.ProxyEndpoint()
		if addr == "" {
			return nil, errors.New("the proxy is not listening")
		}
		dialer, err := tun.SOCKS5Dialer(addr, user, password)
		if err != nil {
			return nil, err
		}
		return dialer(ctx, target)
	}
	t, err := tun.StartPackets(tunMTU, dial, d.TunnelAllows, tun.NewFakeDNS())
	if err != nil {
		return err
	}
	packets = t
	return nil
}

// WritePacket copies a raw IP datagram from NEPacketTunnelFlow.
func WritePacket(data []byte) error {
	mu.Lock()
	t := packets
	mu.Unlock()
	if t == nil {
		return errors.New("the packet tunnel does not run")
	}
	return t.Inject(data)
}

// ReadPacket blocks until a packet is ready to write to NEPacketTunnelFlow.
// Stop unblocks it with nil. Call from one dedicated worker queue.
func ReadPacket() []byte {
	mu.Lock()
	t := packets
	mu.Unlock()
	if t == nil {
		return nil
	}
	return t.Read()
}

func stopPlatformTunnel() {
	mu.Lock()
	t := packets
	packets = nil
	mu.Unlock()
	if t != nil {
		t.Stop()
	}
}
