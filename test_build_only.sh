#!/bin/bash

set -e

echo "Testing build jobs only with act..."

REGION=${1:-"monaco"}
BBOX=${2:-"7.4,43.7,7.5,43.8"}

echo "Parameters:"
echo "  Region: $REGION"
echo "  BBox: $BBOX"

echo ""
echo "Running build-vector-tiles job..."
act workflow_dispatch \
  -W .github/workflows/build-and-deploy.yml \
  -j build-vector-tiles \
  --input osm_region="$REGION" \
  --input bbox="$BBOX" \
  --input tile_url="https://t1.openseamap.org/seamark/{z}/{x}/{y}.png" \
  --input min_zoom="0" \
  --input max_zoom="14" \
  --input build_vector="true" \
  --input build_raster="true" \
  --container-architecture linux/amd64 \
  --verbose

echo ""
echo "Running build-raster-tiles job..."
act workflow_dispatch \
  -W .github/workflows/build-and-deploy.yml \
  -j build-raster-tiles \
  --input osm_region="$REGION" \
  --input bbox="$BBOX" \
  --input tile_url="https://t1.openseamap.org/seamark/{z}/{x}/{y}.png" \
  --input min_zoom="0" \
  --input max_zoom="14" \
  --input build_vector="true" \
  --input build_raster="true" \
  --container-architecture linux/amd64 \
  --verbose

echo ""
echo "Build jobs test completed!"
