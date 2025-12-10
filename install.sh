#!/bin/bash
set -e

# Location: ~/.local/bin (Standard user bin dir)
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

# URL (Using the "latest" magic URL)
URL="https://github.com/nanofleets/get-noa/releases/latest/download/noa-$OS-$ARCH"
DEST="$INSTALL_DIR/noa"

# Install
echo "Downloading $URL"
echo "       to $DEST"

if curl -fsSL "$URL" -o "$DEST"; then
    chmod +x "$DEST"
else
    echo "Download failed. Check your internet or platform support."
    exit 1
fi

# macOS: Clear quarantine
if [ "$OS" = "darwin" ]; then
    xattr -d com.apple.quarantine "$DEST" 2>/dev/null || true
fi

# Path Check
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Note: $INSTALL_DIR is not in your PATH."
fi

echo ""
echo "Finished. Run 'noa version' to verify."