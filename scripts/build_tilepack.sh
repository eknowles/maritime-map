#!/bin/bash

set -e

TILE_URL=${1:-"https://t1.openseamap.org/seamark/{z}/{x}/{y}.png"}
OUTPUT_FILE=${2:-"output/tiles/region_maritime.pmtiles"}
MIN_ZOOM=${3:-"0"}
MAX_ZOOM=${4:-"14"}
BBOX=${5:-"-9.5,36.9,-6.2,42.2"}
CONCURRENCY=${6:-"20"}

mkdir -p $(dirname "$OUTPUT_FILE")

if ! command -v tilepack &> /dev/null; then
    echo "Installing tilepack..."
    
    # Try Homebrew first
    if command -v brew &> /dev/null; then
        echo "Using Homebrew to install tilepack..."
        brew tap eknowles/tools
        brew install tilepack
    else
        echo "Homebrew not found, downloading manually..."
        
        # Detect OS and architecture
        OS=$(uname -s)
        ARCH=$(uname -m)
        
        # Map OS to release format
        case $OS in
            Darwin)
                OS_NAME="darwin"
                ;;
            Linux)
                OS_NAME="linux"
                ;;
            MINGW*|MSYS*|CYGWIN*)
                OS_NAME="windows"
                ;;
            *)
                echo "ERROR: Unsupported OS: $OS"
                exit 1
                ;;
        esac
        
        # Map architecture to release format
        case $ARCH in
            x86_64)
                ARCH_NAME="x64"
                ;;
            arm64|aarch64)
                ARCH_NAME="arm64"
                ;;
            *)
                echo "WARNING: Unknown architecture: $ARCH, trying x64"
                ARCH_NAME="x64"
                ;;
        esac
        
        # Download tilepack
        VERSION="1.4.0"
        DOWNLOAD_URL="https://github.com/eknowles/tilepack/releases/download/v${VERSION}/tilepack-${VERSION}-${OS_NAME}-${ARCH_NAME}.tar.gz"
        
        echo "Downloading tilepack from: $DOWNLOAD_URL"
        
        # Create temp directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Download and extract
        curl -L -o tilepack.tar.gz "$DOWNLOAD_URL"
        tar -xzf tilepack.tar.gz
        
        # Install to /usr/local/bin if possible, otherwise to current directory
        if [ -w /usr/local/bin ] 2>/dev/null; then
            sudo mv tilepack /usr/local/bin/tilepack
            echo "Installed tilepack to /usr/local/bin/tilepack"
        else
            # Install to current directory
            ORIGINAL_DIR=$(pwd)
            cd - > /dev/null
            mv "$TEMP_DIR/tilepack" "./tilepack"
            echo "Installed tilepack to $(pwd)/tilepack"
            echo "You may want to add this directory to your PATH"
        fi
        
        # Clean up
        rm -rf "$TEMP_DIR"
        
        echo "Tilepack installation complete!"
    fi
fi

TEMP_MBTILES="${OUTPUT_FILE%.pmtiles}.mbtiles"

tilepack \
    --input "$TILE_URL" \
    --output "$TEMP_MBTILES" \
    --minzoom "$MIN_ZOOM" \
    --maxzoom "$MAX_ZOOM" \
    --bbox "$BBOX" \
    --concurrency "$CONCURRENCY"

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    if command -v pmtiles &> /dev/null; then
        pmtiles convert "$TEMP_MBTILES" "$OUTPUT_FILE"
        rm "$TEMP_MBTILES"
    fi
    exit 0
else
    echo "ERROR: Tile download failed"
    exit 1
fi
