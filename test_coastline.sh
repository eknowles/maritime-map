#!/bin/bash

set -e

echo "Testing coastline handling..."

REGION=${1:-"monaco"}

echo "Testing with region: $REGION"

# Check if coastline data exists
if [ ! -f "data/coastline/water_polygons.shp" ]; then
    echo "Downloading coastline data..."
    ./scripts/download_data.sh "$REGION"
fi

# Check if OSM data exists
if [ ! -f "data/osm/${REGION}-latest.osm.pbf" ]; then
    echo "Downloading OSM data..."
    ./scripts/download_data.sh "$REGION"
fi

echo "Building tiles with coastline handling..."
./scripts/build_tiles.sh "data/osm/${REGION}-latest.osm.pbf" "output/tiles/${REGION}_maritime.pmtiles"

echo "Validating tiles..."
./scripts/validate_tiles.sh "output/tiles/${REGION}_maritime.pmtiles"

echo "Checking for coastline layer..."
if grep -q "coastline" output/logs/validation.log; then
    echo "✅ Coastline layer found in tiles"
else
    echo "❌ Coastline layer not found in tiles"
fi

echo "Coastline test completed!"
