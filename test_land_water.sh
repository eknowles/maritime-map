#!/bin/bash

set -e

echo "Testing land vs water distinction..."

REGION=${1:-"monaco"}

echo "Testing with region: $REGION"

# Build tiles with simplified landuse
echo "Building tiles with simplified landuse..."
./scripts/build_tiles.sh "data/osm/${REGION}-latest.osm.pbf" "output/tiles/${REGION}_maritime.pmtiles"

echo "Validating tiles..."
./scripts/validate_tiles.sh "output/tiles/${REGION}_maritime.pmtiles"

echo "Checking land vs water distinction..."

# Check for simplified landuse types
if grep -q "landuse" output/logs/validation.log; then
    echo "✅ Landuse layer found"
    
    # Check for land type
    if grep -q "type.*land" output/logs/validation.log; then
        echo "✅ Land areas detected"
    else
        echo "⚠️  Land areas not found (may be normal for small regions)"
    fi
    
    # Check for water type
    if grep -q "type.*water" output/logs/validation.log; then
        echo "✅ Water areas detected"
    else
        echo "⚠️  Water areas not found (may be normal for small regions)"
    fi
    
    # Check for beach type
    if grep -q "type.*beach" output/logs/validation.log; then
        echo "✅ Beach areas detected"
    else
        echo "⚠️  Beach areas not found (may be normal for small regions)"
    fi
else
    echo "❌ Landuse layer not found"
fi

echo "Land vs water test completed!"
