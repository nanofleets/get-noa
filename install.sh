#!/bin/bash
set -e

# NOA CLI installer script
# Usage: curl -sSL https://raw.githubusercontent.com/nanofleets/get-noa/main/install.sh | bash

REPO="nanofleets/get-noa"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="noa"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux)
        PLATFORM="linux"
        ;;
    darwin)
        PLATFORM="darwin"
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

BINARY_FILE="${BINARY_NAME}-${PLATFORM}-${ARCH}"

echo "Installing NOA CLI for ${PLATFORM}/${ARCH}..."

# Get latest release version
echo "Fetching latest release..."
LATEST_RELEASE=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
    echo "Error: Could not fetch latest release version"
    exit 1
fi

echo "Latest version: $LATEST_RELEASE"

# Download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_RELEASE}/${BINARY_FILE}"

echo "Downloading from: $DOWNLOAD_URL"

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download binary
if ! curl -sL -o "${TMP_DIR}/${BINARY_NAME}" "$DOWNLOAD_URL"; then
    echo "Error: Failed to download binary"
    exit 1
fi

# Make executable
chmod +x "${TMP_DIR}/${BINARY_NAME}"

# Install binary
echo "Installing to ${INSTALL_DIR}/${BINARY_NAME}..."
if [ -w "$INSTALL_DIR" ]; then
    mv "${TMP_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
else
    echo "Note: ${INSTALL_DIR} requires sudo access"
    sudo mv "${TMP_DIR}/${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
fi

echo ""
echo "✓ NOA CLI installed successfully!"
echo ""
echo "Run 'noa --help' to get started"
