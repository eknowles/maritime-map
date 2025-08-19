# Maritime Map Justfile
# Run `just --list` to see all available recipes

# Default recipe - show help
default:
    @just --list

# Build maritime tiles for a region
[group('build')]
build region="monaco":
    #!/usr/bin/env bash
    echo "Building maritime tiles for {{region}}..."
    ./build_maritime_map.sh {{region}}

# Download OSM data for a region
[group('build')]
download region="monaco":
    #!/usr/bin/env bash
    echo "Downloading OSM data for {{region}}..."
    ./scripts/download_data.sh {{region}}

# Build vector tiles
[group('build')]
tiles input="data/osm/monaco-latest.osm.pbf" output="output/tiles/monaco_maritime.pmtiles":
    #!/usr/bin/env bash
    echo "Building vector tiles..."
    ./scripts/build_tiles.sh {{input}} {{output}}

# Build raster tiles with tilepack
[group('build')]
raster url="https://t1.openseamap.org/seamark/{z}/{x}/{y}.png" output="output/tiles/seamark_raster.pmtiles" bbox="7.4,43.7,7.5,43.8":
    #!/usr/bin/env bash
    echo "Building raster tiles..."
    ./scripts/build_tilepack.sh {{url}} {{output}} "0" "14" {{bbox}} "20"

# Validate generated tiles
[group('build')]
validate tiles="output/tiles/monaco_maritime.pmtiles":
    #!/usr/bin/env bash
    echo "Validating tiles..."
    ./scripts/validate_tiles.sh {{tiles}}

# Serve tiles locally
[group('serve')]
serve tiles="output/tiles/monaco_maritime.pmtiles" port="8080":
    #!/usr/bin/env bash
    echo "Serving tiles on port {{port}}..."
    ./scripts/serve_tiles.sh {{tiles}} {{port}}

# Serve tiles with tileserver-gl
[group('serve')]
serve-gl tiles="output/tiles/monaco_maritime.pmtiles" port="8080":
    #!/usr/bin/env bash
    echo "Serving tiles with tileserver-gl on port {{port}}..."
    ./scripts/serve_tileserver_gl.sh {{tiles}} {{port}}

# Serve tiles with Python PMTiles server
[group('serve')]
serve-py tiles="output/tiles/monaco_maritime.pmtiles" port="8080":
    #!/usr/bin/env bash
    echo "Serving tiles with Python PMTiles server on port {{port}}..."
    python3 scripts/serve_pmtiles.py {{tiles}} --port {{port}}

# Install go-pmtiles binary
[group('setup')]
install-pmtiles:
    #!/usr/bin/env bash
    echo "Installing go-pmtiles binary..."
    ./scripts/install_pmtiles.sh

# Setup project
[group('setup')]
setup:
    #!/usr/bin/env bash
    echo "Setting up project..."
    ./setup.sh

# Test GitHub Action with act (complete workflow)
[group('test')]
test-act region="monaco" bbox="7.4,43.7,7.5,43.8":
    #!/usr/bin/env bash
    echo "Testing GitHub Action with act..."
    ./test_with_act.sh {{region}} "{{bbox}}"

# Test GitHub Action with act (build jobs only)
[group('test')]
test-build region="monaco" bbox="7.4,43.7,7.5,43.8":
    #!/usr/bin/env bash
    echo "Testing build jobs with act..."
    ./test_build_only.sh {{region}} "{{bbox}}"

# Test coastline handling
[group('test')]
test-coastline region="monaco":
    #!/usr/bin/env bash
    echo "Testing coastline handling..."
    ./test_coastline.sh {{region}}

# Test visibility fixes
[group('test')]
test-visibility region="monaco":
    #!/usr/bin/env bash
    echo "Testing visibility fixes..."
    ./test_visibility.sh {{region}}

# Test land vs water distinction
[group('test')]
test-land-water region="monaco":
    #!/usr/bin/env bash
    echo "Testing land vs water distinction..."
    ./test_land_water.sh {{region}}

# Test city filtering (admin_level 2 only)
[group('test')]
test-cities region="monaco":
    #!/usr/bin/env bash
    echo "Testing city filtering..."
    ./test_cities.sh {{region}}

# Test tilepack installation
[group('test')]
test-tilepack:
    #!/usr/bin/env bash
    echo "Testing tilepack installation..."
    ./test_tilepack.sh

# Test architecture detection
[group('test')]
test-architecture:
    #!/usr/bin/env bash
    echo "Testing architecture detection..."
    ./test_architecture.sh

# Test Homebrew installation
[group('test')]
test-homebrew:
    #!/usr/bin/env bash
    echo "Testing Homebrew installation..."
    ./test_homebrew.sh

# Clean up generated files
[group('clean')]
clean:
    #!/usr/bin/env bash
    echo "Cleaning up generated files..."
    rm -rf output/tiles/*.pmtiles
    rm -rf output/logs/*
    rm -rf output/reports/*
    rm -rf temp/*
    rm -rf dist/*

# Clean everything including downloaded data
[group('clean')]
clean-all:
    #!/usr/bin/env bash
    echo "Cleaning everything..."
    rm -rf data/osm/*
    rm -rf data/coastline/*
    rm -rf data/cache/*
    rm -rf output/*
    rm -rf temp/*
    rm -rf dist/*

# Show project status
[group('info')]
status:
    #!/usr/bin/env bash
    echo "=== Maritime Map Project Status ==="
    echo ""
    echo "Generated tiles:"
    ls -la output/tiles/ 2>/dev/null || echo "No tiles found"
    echo ""
    echo "Downloaded data:"
    ls -la data/osm/ 2>/dev/null || echo "No OSM data found"
    echo ""
    echo "Cache size:"
    du -sh data/cache/ 2>/dev/null || echo "No cache found"
    echo ""
    echo "Output size:"
    du -sh output/ 2>/dev/null || echo "No output found"

# Quick build for Monaco (small region for testing)
[group('quick')]
monaco:
    #!/usr/bin/env bash
    echo "Quick build for Monaco..."
    just build monaco
    just validate output/tiles/monaco_maritime.pmtiles

# Quick build for Portugal (larger region)
[group('quick')]
portugal:
    #!/usr/bin/env bash
    echo "Building for Portugal..."
    just build portugal
    just validate output/tiles/portugal_maritime.pmtiles

# Development workflow - build, validate, and serve
[group('dev')]
dev region="monaco":
    #!/usr/bin/env bash
    echo "Development workflow for {{region}}..."
    just build {{region}}
    just validate output/tiles/{{region}}_maritime.pmtiles
    echo "Starting local server..."
    just serve output/tiles/{{region}}_maritime.pmtiles

# Check prerequisites
[group('info')]
check:
    #!/usr/bin/env bash
    echo "Checking prerequisites..."
    echo "tilemaker: $(which tilemaker 2>/dev/null || echo 'NOT FOUND')"
    echo "tilepack: $(which tilepack 2>/dev/null || echo 'NOT FOUND')"
    echo "pmtiles: $(which pmtiles 2>/dev/null || echo 'NOT FOUND')"
    echo "docker: $(which docker 2>/dev/null || echo 'NOT FOUND')"
    echo "act: $(which act 2>/dev/null || echo 'NOT FOUND')"
    echo "just: $(which just 2>/dev/null || echo 'NOT FOUND')"


