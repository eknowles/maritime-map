#!/bin/bash

set -e

REGION=${1:-"region"}
OUTPUT_FILE="output/tiles/${REGION}_maritime.pmtiles"

if [ ! -f "config/config.json" ] || [ ! -f "config/process.lua" ]; then
    echo "ERROR: Configuration files not found"
    exit 1
fi

./scripts/download_data.sh "$REGION"

if [ $? -ne 0 ]; then
    echo "ERROR: Data download failed"
    exit 1
fi

./scripts/build_tiles.sh "data/osm/${REGION}-latest.osm.pbf" "$OUTPUT_FILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Tile generation failed"
    exit 1
fi

./scripts/validate_tiles.sh "$OUTPUT_FILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Validation failed"
    exit 1
fi

