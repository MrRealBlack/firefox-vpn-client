# iOS port — networking foundation

This branch is not yet an installable iPhone app. The Flutter host,
extension target integration, signing, and real-device testing remain.

## Architecture

Reuse the Flutter mobile UI and Go daemon. On iOS the connected daemon
belongs to a `NEPacketTunnelProvider` extension so traffic can continue
while the UI is suspended. The host must not spawn a subprocess or rely
on an in-app background daemon.

`core/internal/tun/packet.go` feeds raw IPv4/IPv6 datagrams into Android's
existing TCP forwarder and fake DNS stack. The native provider uses the
public `NEPacketTunnelFlow` API; it does not extract a private utun fd.
Packet buffers are copied at the gomobile boundary. Shutdown cancels the
blocking output reader.

`app/ios/PacketTunnel/` contains provider source, Info.plist and entitlement
templates. These sources are not yet attached to an Xcode target.
Successful provider startup means packet handling is ready, not that
Mozilla authentication or upstream connectivity succeeded. The host must
display the core's actual connection state and errors.

Upstream restrictions remain: TCP only and limited destination ports.
IPv6 is captured as well, avoiding an accidental IPv6 bypass; fake DNS
currently supplies IPv4 answers. Android's per-app exclusions cannot be
directly ported to an ordinary consumer iOS VPN.

## Build

With Xcode installed and its license accepted, run:

```sh
scripts/build-ios-core.sh
```

Go and gomobile versions come from `core/go.mod`. A temporary gobind
installation builds device and simulator slices into
`app/ios/Frameworks/Core.xcframework`, which is ignored by Git.

## Remaining integration

1. Generate the Flutter iOS host using the Flutter version in
   `.github/workflows/build.yml`. Use the mobile layout on iOS, add an iOS
   method channel and disable desktop subprocess management, downloaded
   updates, and Android-only settings.
2. Add a packet tunnel extension target compiling `PacketTunnelProvider.m`.
   Use its Info.plist and entitlements, link NetworkExtension and the Core
   framework, and embed the extension in the host. Register unique bundle
   identifiers and the same App Group for both targets. Replace the
   example App Group entitlement with the developer team's registered ID.
3. Implement `NETunnelProviderManager` in the host. Set the extension's
   actual `providerBundleIdentifier` and `providerConfiguration["appGroup"]`.
   Save and reload preferences before starting. Let iOS request VPN consent.
4. Keep data in `core/` inside the shared App Group container. The host
   may run the core for account/settings access while disconnected. Stop
   that core and close API connections before starting the extension.
   Never run two daemons against the same folder. While connected, use
   the extension's API and current local token. Keep credentials out of Git.
5. Observe system VPN status and reconcile foreground/background changes,
   user cancellation and provider failures. Exercise stop-during-start,
   reconnect, device lock, Wi-Fi/cellular changes, DNS/IPv6 and extension
   memory limits on a real iPhone. Simulator compilation cannot validate
   VPN entitlements or actual traffic forwarding.

Apple reference: [NEPacketTunnelProvider](https://developer.apple.com/documentation/networkextension/nepackettunnelprovider).

## Tests

```sh
cd core
go test -race ./mobile ./internal/tun
```

Linux executes the packet tests: inject an actual IPv4/UDP DNS query,
verify the returned fake DNS answer, reject malformed packets and check
that stopping unblocks a waiting reader. Ordinary macOS builds exclude
the packet stack; cross-compilation does not execute these tests.
Building the iOS framework separately checks its build tags and bindings.
