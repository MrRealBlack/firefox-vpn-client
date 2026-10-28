//go:build ios

package tun

import "errors"

// iOS uses the public NEPacketTunnelFlow packet API, not an extracted fd.
func Start(fd int, mtu uint32, dial Dialer, allow Allow, dns *FakeDNS) (*Tunnel, error) {
	return nil, errors.New("tun: iOS requires StartPackets")
}
