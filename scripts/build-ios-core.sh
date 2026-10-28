#!/usr/bin/env bash
# Build the Go mobile bindings for the iOS device and simulator.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root/core"
mkdir -p "$root/app/ios/Frameworks"
# Keep the binding generator aligned with the version pinned by go.mod.
bin="$(mktemp -d)"
trap 'rm -rf "$bin"' EXIT
GOBIN="$bin" go install golang.org/x/mobile/cmd/gobind
export PATH="$bin:$PATH"
go run golang.org/x/mobile/cmd/gomobile bind \
  -target=ios,iossimulator -iosversion=15.0 \
  -o "$root/app/ios/Frameworks/Core.xcframework" ./mobile
