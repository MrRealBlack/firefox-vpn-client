//go:build linux

package tun

import (
	"fmt"
	"golang.org/x/sys/unix"
	"gvisor.dev/gvisor/pkg/tcpip/link/fdbased"
)

// Start takes over the TUN device fd (it closes it on Stop): TCP goes
// through dial, DNS (UDP port 53, to any address) is answered by dns, and
// other UDP is refused with ICMP port unreachable, so apps fall back to TCP.
func Start(fd int, mtu uint32, dial Dialer, allow Allow, dns *FakeDNS) (*Tunnel, error) {
	if err := unix.SetNonblock(fd, true); err != nil {
		return nil, fmt.Errorf("tun: %w", err)
	}
	link, err := fdbased.New(&fdbased.Options{FDs: []int{fd}, MTU: mtu})
	if err != nil {
		return nil, fmt.Errorf("tun: %w", err)
	}
	return startLink(link, func() { _ = unix.Close(fd) }, dial, allow, dns)
}
