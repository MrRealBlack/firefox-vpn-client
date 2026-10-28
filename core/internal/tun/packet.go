//go:build linux || ios

package tun

import (
	"context"
	"errors"
	"gvisor.dev/gvisor/pkg/buffer"
	"gvisor.dev/gvisor/pkg/tcpip/header"
	"gvisor.dev/gvisor/pkg/tcpip/link/channel"
	"gvisor.dev/gvisor/pkg/tcpip/stack"
)

// PacketTunnel connects a native packet API (such as NEPacketTunnelFlow)
// to the same TCP forwarder and fake DNS used by Android. Packets are raw
// IPv4/IPv6 datagrams, without a platform-specific TUN header.
type PacketTunnel struct {
	*Tunnel
	link *channel.Endpoint
}

func StartPackets(mtu uint32, dial Dialer, allow Allow, dns *FakeDNS) (*PacketTunnel, error) {
	link := channel.New(256, mtu, "")
	t, err := startLink(link, link.Close, dial, allow, dns)
	if err != nil {
		link.Close()
		return nil, err
	}
	return &PacketTunnel{Tunnel: t, link: link}, nil
}

// Inject copies one incoming IP datagram. Never retain a gomobile buffer.
func (t *PacketTunnel) Inject(data []byte) error {
	if len(data) == 0 || len(data) > int(t.link.MTU()) {
		return errors.New("tun: invalid IP packet size")
	}
	select {
	case <-t.ctx.Done():
		return context.Canceled
	default:
	}
	var protocol = header.IPv4ProtocolNumber
	switch data[0] >> 4 {
	case 4:
		if len(data) < header.IPv4MinimumSize {
			return errors.New("tun: short IPv4 packet")
		}
	case 6:
		if len(data) < header.IPv6MinimumSize {
			return errors.New("tun: short IPv6 packet")
		}
		protocol = header.IPv6ProtocolNumber
	default:
		return errors.New("tun: unknown IP version")
	}
	packet := stack.NewPacketBuffer(stack.PacketBufferOptions{Payload: buffer.MakeWithData(append([]byte(nil), data...))})
	defer packet.DecRef()
	t.link.InjectInbound(protocol, packet)
	return nil
}

// Read blocks until an outgoing IP packet is available or Stop is called.
// Call on a dedicated native worker queue, never the UI or packet reader.
func (t *PacketTunnel) Read() []byte {
	packet := t.link.ReadContext(t.ctx)
	if packet == nil {
		return nil
	}
	defer packet.DecRef()
	view := packet.ToView()
	defer view.Release()
	return append([]byte(nil), view.AsSlice()...)
}
