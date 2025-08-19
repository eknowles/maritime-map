#!/bin/bash

set -e

REGION=${1:-"region"}
DATA_DIR="./data"
OSM_DIR="${DATA_DIR}/osm"
COASTLINE_DIR="${DATA_DIR}/coastline"
CACHE_DIR="${DATA_DIR}/cache"

mkdir -p $OSM_DIR $COASTLINE_DIR $CACHE_DIR

OSM_FILE="${OSM_DIR}/${REGION}-latest.osm.pbf"
OSM_CACHE="${CACHE_DIR}/${REGION}-latest.osm.pbf"

if [ -f "$OSM_CACHE" ]; then
    cp "$OSM_CACHE" "$OSM_FILE"
else
    wget -O "$OSM_FILE" \
        "https://download.geofabrik.de/europe/${REGION}-latest.osm.pbf"
    
    if [ $? -eq 0 ]; then
        cp "$OSM_FILE" "$OSM_CACHE"
    else
        echo "ERROR: Failed to download OSM data for ${REGION}"
        exit 1
    fi
fi

WATER_POLYGONS_CACHE="${CACHE_DIR}/water-polygons-split-4326.zip"
WATER_POLYGONS_FILE="${COASTLINE_DIR}/water_polygons.shp.zip"

if [ -f "$WATER_POLYGONS_CACHE" ]; then
    cp "$WATER_POLYGONS_CACHE" "$WATER_POLYGONS_FILE"
else
    wget -O "$WATER_POLYGONS_FILE" \
        "https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip"
    
    if [ $? -eq 0 ]; then
        cp "$WATER_POLYGONS_FILE" "$WATER_POLYGONS_CACHE"
    else
        echo "ERROR: Failed to download coastline data"
        exit 1
    fi
fi

unzip -o "$WATER_POLYGONS_FILE" -d "${COASTLINE_DIR}/"

LAND_POLYGONS_CACHE="${CACHE_DIR}/land-polygons-complete-4326.zip"
LAND_POLYGONS_FILE="${COASTLINE_DIR}/land-polygons-complete-4326.zip"

if [ -f "$LAND_POLYGONS_CACHE" ]; then
    cp "$LAND_POLYGONS_CACHE" "$LAND_POLYGONS_FILE"
else
    wget -O "$LAND_POLYGONS_FILE" \
        "https://osmdata.openstreetmap.de/download/land-polygons-complete-4326.zip" || true
    
    if [ $? -eq 0 ]; then
        cp "$LAND_POLYGONS_FILE" "$LAND_POLYGONS_CACHE"
    fi
fi

