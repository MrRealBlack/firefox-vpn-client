//go:build linux || ios

package tun

import (
	"encoding/binary"
	"golang.org/x/net/dns/dnsmessage"
	"testing"
	"time"
)

func TestPacketTunnelDNS(t *testing.T) {
	tunnel, err := StartPackets(1500, nil, nil, NewFakeDNS())
	if err != nil {
		t.Fatal(err)
	}
	defer tunnel.Stop()
	question := dnsmessage.Message{
		Header:    dnsmessage.Header{ID: 42, RecursionDesired: true},
		Questions: []dnsmessage.Question{{Name: dnsmessage.MustNewName("example.com."), Type: dnsmessage.TypeA, Class: dnsmessage.ClassINET}},
	}
	query, err := question.Pack()
	if err != nil {
		t.Fatal(err)
	}
	// IPv4 + UDP. A zero UDP checksum is permitted for IPv4.
	packet := make([]byte, 28+len(query))
	packet[0], packet[8], packet[9] = 0x45, 64, 17
	binary.BigEndian.PutUint16(packet[2:4], uint16(len(packet)))
	copy(packet[12:16], []byte{172, 19, 0, 1})
	copy(packet[16:20], []byte{172, 19, 0, 2})
	var sum uint32
	for i := 0; i < 20; i += 2 {
		sum += uint32(binary.BigEndian.Uint16(packet[i : i+2]))
	}
	for sum > 0xffff {
		sum = (sum & 0xffff) + (sum >> 16)
	}
	binary.BigEndian.PutUint16(packet[10:12], ^uint16(sum))
	binary.BigEndian.PutUint16(packet[20:22], 12345)
	binary.BigEndian.PutUint16(packet[22:24], 53)
	binary.BigEndian.PutUint16(packet[24:26], uint16(8+len(query)))
	copy(packet[28:], query)
	if err := tunnel.Inject(packet); err != nil {
		t.Fatal(err)
	}
	output := make(chan []byte, 1)
	go func() { output <- tunnel.Read() }()
	select {
	case reply := <-output:
		if len(reply) < 28 {
			t.Fatalf("short reply: %x", reply)
		}
		offset := int(reply[0]&15)*4 + 8
		var answer dnsmessage.Message
		if err := answer.Unpack(reply[offset:]); err != nil {
			t.Fatal(err)
		}
		if answer.ID != 42 || !answer.Response || len(answer.Answers) != 1 {
			t.Fatalf("unexpected DNS answer: %+v", answer)
		}
		record, ok := answer.Answers[0].Body.(*dnsmessage.AResource)
		if !ok || record.A[0] != 198 || record.A[1] != 18 {
			t.Fatalf("expected fake DNS address: %+v", answer.Answers)
		}
	case <-time.After(3 * time.Second):
		t.Fatal("no DNS packet returned")
	}
}

func TestPacketTunnelStopUnblocksRead(t *testing.T) {
	tunnel, err := StartPackets(1500, nil, nil, NewFakeDNS())
	if err != nil {
		t.Fatal(err)
	}
	output := make(chan []byte, 1)
	go func() { output <- tunnel.Read() }()
	tunnel.Stop()
	tunnel.Stop()
	select {
	case packet := <-output:
		if packet != nil {
			t.Fatalf("expected nil after Stop, got %x", packet)
		}
	case <-time.After(time.Second):
		t.Fatal("Stop did not unblock Read")
	}
	if err := tunnel.Inject(make([]byte, 20)); err == nil {
		t.Fatal("accepted packet after Stop")
	}
}

func TestPacketTunnelRejectsMalformedPackets(t *testing.T) {
	tunnel, err := StartPackets(1500, nil, nil, NewFakeDNS())
	if err != nil {
		t.Fatal(err)
	}
	defer tunnel.Stop()
	for _, packet := range [][]byte{nil, {0}, {0x45}, {0x60}, make([]byte, 1501)} {
		if err := tunnel.Inject(packet); err == nil {
			t.Fatalf("accepted malformed packet: %x", packet)
		}
	}
}
