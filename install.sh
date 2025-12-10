#!/bin/bash
set -e

REPO="nanofleets/get-noa"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$INSTALL_DIR"

# Detect OS & Arch
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Resolve latest version (Parsing the redirect URL, safe from API limits)
VERSION=$(curl -sLI -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest" | xargs basename)
echo "Found version: $VERSION"

# URL & Dest
URL="https://github.com/$REPO/releases/latest/download/noa-$OS-$ARCH"
DEST="$INSTALL_DIR/noa"

# Install
echo "Downloading $URL"
echo "         to $DEST"

if curl -fsSL "$URL" -o "$DEST"; then
    chmod +x "$DEST"
else
    echo "Download failed."
    exit 1
fi

# macOS: Clear quarantine
if [ "$OS" = "darwin" ]; then
    xattr -d com.apple.quarantine "$DEST" 2>/dev/null || true
fi

# Path Check
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Note: $INSTALL_DIR is not in your PATH."
fi

echo "Finished. Run 'noa version' to verify."