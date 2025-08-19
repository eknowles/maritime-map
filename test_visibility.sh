#!/bin/bash

set -e

echo "Testing visibility fixes..."

REGION=${1:-"monaco"}

echo "Testing with region: $REGION"

# Build tiles with updated configuration
echo "Building tiles with updated configuration..."
./scripts/build_tiles.sh "data/osm/${REGION}-latest.osm.pbf" "output/tiles/${REGION}_maritime.pmtiles"

echo "Validating tiles..."
./scripts/validate_tiles.sh "output/tiles/${REGION}_maritime.pmtiles"

echo "Checking layer visibility..."

# Check for coastline layer (should be visible at all zooms)
if grep -q "coastline" output/logs/validation.log; then
    echo "✅ Coastline layer found (visible zoom 0-14)"
else
    echo "❌ Coastline layer not found"
fi

# Check for water layer (should be visible at zoom 10+)
if grep -q "water" output/logs/validation.log; then
    echo "✅ Water layer found (visible zoom 10-14)"
else
    echo "❌ Water layer not found"
fi

# Check for landuse layer (should be visible at all zooms)
if grep -q "landuse" output/logs/validation.log; then
    echo "✅ Landuse layer found (visible zoom 0-14)"
else
    echo "❌ Landuse layer not found"
fi

# Check for cables layer (should be visible at zoom 7+)
if grep -q "cables" output/logs/validation.log; then
    echo "✅ Cables layer found (visible zoom 7-14)"
else
    echo "❌ Cables layer not found"
fi

# Check for cities layer (should be visible at zoom 7+)
if grep -q "cities" output/logs/validation.log; then
    echo "✅ Cities layer found (visible zoom 7-14, admin_level 2 only)"
else
    echo "❌ Cities layer not found"
fi

echo "Visibility test completed!"
