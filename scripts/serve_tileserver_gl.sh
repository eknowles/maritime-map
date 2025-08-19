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

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not found"
    exit 1
fi

echo "Starting tileserver-gl on port $PORT..."
echo "Tile file: $TILES_FILE"
echo "Access: http://localhost:$PORT"
echo "Press Ctrl+C to stop"

# Create a temporary config file for tileserver-gl
CONFIG_FILE=$(mktemp)
cat > "$CONFIG_FILE" << EOF
{
  "options": {
    "paths": {
      "root": "/data",
      "fonts": "/data/fonts",
      "styles": "/data/styles",
      "mbtiles": "/data"
    },
    "serveAllFonts": true,
    "formatQuality": {
      "jpeg": 80,
      "webp": 90
    },
    "maxSize": 2048,
    "pbfAlias": "pbf"
  },
  "styles": {
    "maritime": {
      "style": "/data/maritime-style.json",
      "tilejson": {
        "bounds": [-180, -85, 180, 85]
      }
    }
  },
  "data": {
    "maritime": {
      "mbtiles": "/data/$(basename "$TILES_FILE")"
    }
  }
}
EOF

docker run --rm \
    -p "$PORT:80" \
    -v "$(pwd)/output:/data" \
    -v "$CONFIG_FILE:/etc/tileserver-gl/config.json" \
    maptiler/tileserver-gl:latest

# Clean up
rm "$CONFIG_FILE"
