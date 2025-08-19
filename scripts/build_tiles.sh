#!/bin/bash

set -e

INPUT_FILE=${1:-"data/osm/portugal-latest.osm.pbf"}
OUTPUT_FILE=${2:-"output/tiles/portugal_maritime.pmtiles"}
CONFIG_FILE=${3:-"config/config.json"}
PROCESS_FILE=${4:-"config/process.lua"}
TEMP_DIR=${5:-"./temp"}

if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: Input file not found: $INPUT_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$PROCESS_FILE" ]; then
    echo "ERROR: Process file not found: $PROCESS_FILE"
    exit 1
fi

mkdir -p $(dirname "$OUTPUT_FILE") $TEMP_DIR

if ! command -v tilemaker &> /dev/null; then
    echo "ERROR: tilemaker not found"
    exit 1
fi

CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || printf "4")

tilemaker \
    "$INPUT_FILE" \
    --output "$OUTPUT_FILE" \
    --config "$CONFIG_FILE" \
    --process "$PROCESS_FILE" \
    --store "$TEMP_DIR" \
    --threads $CPU_CORES

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    rm -rf "$TEMP_DIR"/*
    exit 0
else
    echo "ERROR: Tile generation failed"
    exit 1
fi
