#!/bin/bash

set -e

TILE_URL=${1:-"https://tile.openstreetmap.org/{z}/{x}/{y}.png"}
OUTPUT_FILE=${2:-"output/tiles/region_maritime.pmtiles"}
MIN_ZOOM=${3:-"0"}
MAX_ZOOM=${4:-"14"}
BBOX=${5:-"-9.5,36.9,-6.2,42.2"}
CONCURRENCY=${6:-"20"}

mkdir -p $(dirname "$OUTPUT_FILE")

if ! command -v tilepack &> /dev/null; then
    if command -v brew &> /dev/null; then
        brew tap eknowles/tools
        brew install tilepack
    else
        echo "ERROR: Homebrew not found, please install tilepack manually"
        exit 1
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
