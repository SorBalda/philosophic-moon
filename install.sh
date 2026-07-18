#!/bin/sh
# philosophic moon installer — one command, one binary, zero dependencies.
#
#   curl -fsSL https://raw.githubusercontent.com/SorBalda/philosophic-moon/main/install.sh | sh
#
# Detects OS/arch, downloads the right binary from the latest GitHub Release,
# verifies its SHA256 against the published SHA256SUMS, installs it into
# ~/.local/bin (or $MOON_INSTALL_DIR). Music is built in; there is nothing
# else to install. Windows: grab moon-windows-amd64.exe from the Releases
# page instead.
set -eu

REPO="SorBalda/philosophic-moon"
BASE="https://github.com/${REPO}/releases/latest/download"
DIR="${MOON_INSTALL_DIR:-$HOME/.local/bin}"

os=$(uname -s); arch=$(uname -m)
case "$os" in
	Linux)  os=linux ;;
	Darwin) os=macos ;;
	*) echo "moon: unsupported OS '$os' — see https://github.com/${REPO}/releases" >&2; exit 1 ;;
esac
case "$arch" in
	x86_64|amd64)  arch=amd64 ;;
	arm64|aarch64) arch=arm64 ;;
	*) echo "moon: unsupported arch '$arch' — see https://github.com/${REPO}/releases" >&2; exit 1 ;;
esac
bin="moon-${os}-${arch}"
if [ "$os" = linux ] && [ "$arch" = arm64 ]; then
	echo "moon: no linux-arm64 release yet — build from source or open an issue." >&2
	exit 1
fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "· downloading ${bin} …"
curl -fsSL -o "$tmp/$bin" "$BASE/$bin"
curl -fsSL -o "$tmp/SHA256SUMS" "$BASE/SHA256SUMS"

echo "· verifying checksum …"
(cd "$tmp" && grep " ${bin}\$" SHA256SUMS | sha256sum -c - >/dev/null 2>&1) || \
(cd "$tmp" && grep " ${bin}\$" SHA256SUMS | shasum -a 256 -c - >/dev/null) || {
	echo "moon: checksum verification FAILED — aborting." >&2; exit 1; }

mkdir -p "$DIR"
install -m 0755 "$tmp/$bin" "$DIR/moon"
echo "· installed to $DIR/moon"

case ":$PATH:" in
	*":$DIR:"*) ;;
	*) echo "  note: $DIR is not in your PATH — add:  export PATH=\"$DIR:\$PATH\"" ;;
esac
echo ""
echo "Type 'moon' and look up.  ☾"
