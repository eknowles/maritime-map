#!/bin/bash

set -e

TILES_FILE=${1:-"output/tiles/region_maritime.pmtiles"}
PORT=${2:-"8080"}

if [ ! -f "$TILES_FILE" ]; then
    echo "ERROR: Tile file not found: $TILES_FILE"
    exit 1
fi

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "ERROR: Port $PORT is already in use"
    exit 1
fi

echo "Starting PMTiles server on port $PORT..."
echo "Tile file: $TILES_FILE"
echo "Access: http://localhost:$PORT"
echo "Press Ctrl+C to stop"

# Try to use go-pmtiles binary
if command -v pmtiles &> /dev/null; then
    echo "Using local pmtiles binary..."
    pmtiles serve "$TILES_FILE" --port "$PORT"
elif command -v brew &> /dev/null; then
    echo "Installing pmtiles via Homebrew..."
    brew install pmtiles
    pmtiles serve "$TILES_FILE" --port "$PORT"
elif command -v docker &> /dev/null; then
    echo "Using go-pmtiles via Docker..."
    # Download and use go-pmtiles binary
    docker run --rm \
        -p "$PORT:8080" \
        -v "$(pwd)/output:/data" \
        -w "/data" \
        alpine:latest \
        sh -c "
            apk add --no-cache wget curl unzip &&
            LATEST_VERSION=\$(curl -s https://api.github.com/repos/protomaps/go-pmtiles/releases/latest | grep '\"tag_name\"' | cut -d'\"' -f4 | sed 's/v//') &&
            wget -O pmtiles.tar.gz https://github.com/protomaps/go-pmtiles/releases/download/v\${LATEST_VERSION}/go-pmtiles_\${LATEST_VERSION}_Linux_x86_64.tar.gz &&
            tar -xzf pmtiles.tar.gz &&
            chmod +x pmtiles &&
            ./pmtiles serve /data/$(basename "$TILES_FILE") --port 8080
        "
else
    echo "Using Python HTTP server as fallback..."
    cd output && python3 -m http.server "$PORT"
fi
