#!/bin/bash

set -e

echo "Installing go-pmtiles binary..."

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

# Map OS to release format
case $OS in
    Darwin)
        OS_NAME="Darwin"
        EXT="zip"
        PREFIX="go-pmtiles-"
        ;;
    Linux)
        OS_NAME="Linux"
        EXT="tar.gz"
        PREFIX="go-pmtiles_"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        OS_NAME="Windows"
        EXT="zip"
        PREFIX="go-pmtiles_"
        ;;
    *)
        echo "ERROR: Unsupported OS: $OS"
        exit 1
        ;;
esac

# Map architecture to release format
case $ARCH in
    x86_64)
        ARCH_NAME="x86_64"
        ;;
    arm64|aarch64)
        ARCH_NAME="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Get latest version
LATEST_VERSION=$(curl -s https://api.github.com/repos/protomaps/go-pmtiles/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')

# Download URL
DOWNLOAD_URL="https://github.com/protomaps/go-pmtiles/releases/download/v${LATEST_VERSION}/${PREFIX}${LATEST_VERSION}_${OS_NAME}_${ARCH_NAME}.${EXT}"

echo "Latest version: $LATEST_VERSION"
echo "Downloading from: $DOWNLOAD_URL"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download and extract
if [ "$EXT" = "zip" ]; then
    curl -L -o pmtiles.zip "$DOWNLOAD_URL"
    unzip pmtiles.zip
else
    curl -L -o pmtiles.tar.gz "$DOWNLOAD_URL"
    tar -xzf pmtiles.tar.gz
fi

# Check if we can write to /usr/local/bin
if [ -w /usr/local/bin ] 2>/dev/null; then
    sudo mv pmtiles /usr/local/bin/pmtiles
    echo "Installed pmtiles to /usr/local/bin/pmtiles"
else
    # Install to current directory
    ORIGINAL_DIR=$(pwd)
    cd - > /dev/null
    mv "$TEMP_DIR/pmtiles" "./pmtiles"
    echo "Installed pmtiles to $(pwd)/pmtiles"
    echo "You may want to add this directory to your PATH"
fi

# Clean up
rm -rf "$TEMP_DIR"

echo "Installation complete!"
echo "Test with: pmtiles version"
