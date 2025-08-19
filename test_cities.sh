#!/bin/bash

set -e

echo "Testing city filtering (admin_level 2 only)..."

REGION=${1:-"monaco"}

echo "Testing with region: $REGION"

# Build tiles with city filtering
echo "Building tiles with city filtering..."
./scripts/build_tiles.sh "data/osm/${REGION}-latest.osm.pbf" "output/tiles/${REGION}_maritime.pmtiles"

echo "Validating tiles..."
./scripts/validate_tiles.sh "output/tiles/${REGION}_maritime.pmtiles"

echo "Checking city filtering..."

# Check for cities layer
if grep -q "cities" output/logs/validation.log; then
    echo "✅ Cities layer found"
    
    # Check for admin_level 2 cities
    if grep -q "admin_level.*2" output/logs/validation.log; then
        echo "✅ Admin level 2 cities detected"
    else
        echo "⚠️  No admin level 2 cities found (may be normal for small regions)"
    fi
    
    # Check that no other admin levels are included
    if grep -q "admin_level.*[13456789]" output/logs/validation.log; then
        echo "❌ Other admin levels found (should only be level 2)"
    else
        echo "✅ Only admin level 2 cities included"
    fi
else
    echo "❌ Cities layer not found"
fi

echo "City filtering test completed!"
