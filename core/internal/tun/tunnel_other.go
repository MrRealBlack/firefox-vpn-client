//go:build !linux && !ios

package tun

import "errors"

type Tunnel struct{}

func Start(fd int, mtu uint32, dial Dialer, allow Allow, dns *FakeDNS) (*Tunnel, error) {
	return nil, errors.New("tun: this platform does not support a TUN file descriptor")
}
func (t *Tunnel) Stop() {}
