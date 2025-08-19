#!/bin/bash

set -e

if [ ! -d ".git" ]; then
    echo "ERROR: Not a git repository"
    exit 1
fi

chmod +x scripts/*.sh
chmod +x setup.sh

mkdir -p data/osm data/coastline output/tiles output/logs output/reports

if command -v python3 &> /dev/null; then
    python3 -m json.tool config/config.json > /dev/null
    python3 -m json.tool config/maplibre-style.json > /dev/null
fi

if command -v lua &> /dev/null; then
    lua -c config/process.lua
fi
