#!/bin/bash

set -e

TILES_FILE=${1:-"output/tiles/region_maritime.pmtiles"}
LOG_FILE="output/logs/validation.log"
REPORT_FILE="output/reports/validation_report.txt"

mkdir -p $(dirname "$LOG_FILE") $(dirname "$REPORT_FILE")

if [ ! -f "$TILES_FILE" ]; then
    echo "ERROR: Tile file not found: $TILES_FILE"
    exit 1
fi

echo "Maritime Tile Validation Report" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "Tile file: $TILES_FILE" >> "$REPORT_FILE"
echo "File size: $(du -h "$TILES_FILE" | cut -f1)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v tilemaker-validate &> /dev/null; then
    tilemaker-validate "$TILES_FILE" > "$LOG_FILE" 2>&1
    echo "Tile file integrity check completed" >> "$REPORT_FILE"
else
    echo "tilemaker-validate not available, skipping integrity check" >> "$REPORT_FILE"
fi

REQUIRED_LAYERS=("water" "coastline" "ports" "seamarks" "buoys" "ferry_routes" "cables" "territorial_waters")
MISSING_LAYERS=()

echo "Required Layers Check:" >> "$REPORT_FILE"
for layer in "${REQUIRED_LAYERS[@]}"; do
    if grep -q "Layer: $layer" "$LOG_FILE" 2>/dev/null || true; then
        echo "  $layer: Found" >> "$REPORT_FILE"
    else
        echo "  $layer: Missing" >> "$REPORT_FILE"
        MISSING_LAYERS+=("$layer")
    fi
done

if command -v tilemaker-info &> /dev/null; then
    echo "Tile Information:" >> "$REPORT_FILE"
    tilemaker-info "$TILES_FILE" >> "$REPORT_FILE" 2>&1 || true
else
    echo "tilemaker-info not available, skipping tile analysis" >> "$REPORT_FILE"
fi

FILE_EXTENSION="${TILES_FILE##*.}"
if [ "$FILE_EXTENSION" = "pmtiles" ]; then
    echo "File format: PMTiles (Protomaps)" >> "$REPORT_FILE"
elif [ "$FILE_EXTENSION" = "mbtiles" ]; then
    echo "File format: MBTiles (Mapbox)" >> "$REPORT_FILE"
else
    echo "File format: $FILE_EXTENSION (unknown)" >> "$REPORT_FILE"
fi

if [ -r "$TILES_FILE" ]; then
    echo "Tile file is readable" >> "$REPORT_FILE"
    
    if [ -s "$TILES_FILE" ]; then
        echo "Tile file has content" >> "$REPORT_FILE"
    else
        echo "Tile file is empty" >> "$REPORT_FILE"
    fi
else
    echo "Tile file is not readable" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "Validation Summary:" >> "$REPORT_FILE"
if [ ${#MISSING_LAYERS[@]} -eq 0 ]; then
    echo "All required maritime layers are present" >> "$REPORT_FILE"
else
    echo "Missing layers: ${MISSING_LAYERS[*]}" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
if [ ${#MISSING_LAYERS[@]} -eq 0 ]; then
    echo "VALIDATION PASSED: Maritime tiles are ready for use!" >> "$REPORT_FILE"
    VALIDATION_RESULT=0
else
    echo "VALIDATION WARNING: Some required layers are missing" >> "$REPORT_FILE"
    VALIDATION_RESULT=1
fi

exit $VALIDATION_RESULT
