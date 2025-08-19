# Maritime Map

Offline maritime-focused maps using PMTiles with data derived from OSM.

## Quick Start

### Using just (Recommended)
```bash
# Install just if not already installed
brew install just

# Build tiles for a region
just build monaco

# Development workflow (build, validate, serve)
just dev monaco

# See all available commands
just --list
```

### Using scripts directly
```bash
# Build tiles for a region
./build_maritime_map.sh region_name

# Serve tiles locally (multiple options)
./scripts/serve_tiles.sh                    # Uses go-pmtiles (recommended)
./scripts/serve_tileserver_gl.sh            # Uses tileserver-gl
python3 scripts/serve_pmtiles.py            # Uses Python PMTiles server

# Install go-pmtiles binary
./scripts/install_pmtiles.sh
```

## Project Structure

```
maritime-map/
├── config/
│   ├── config.json              # Tilemaker configuration
│   ├── process.lua              # Data processing script
│   ├── maplibre-style.js        # JavaScript style generator
│   ├── maplibre-style.json      # Static MapLibre style
│   └── example-usage.html       # Map example
├── scripts/
│   ├── download_data.sh         # Download OSM data
│   ├── build_tiles.sh           # Build vector tiles
│   ├── build_tilepack.sh        # Build raster tiles
│   ├── validate_tiles.sh        # Validate tiles
│   └── serve_tiles.sh           # Serve tiles locally
├── data/
│   ├── cache/                   # Cached downloads
│   ├── osm/                     # OSM PBF files
│   └── coastline/               # Coastline data
├── output/
│   └── tiles/                   # Generated PMTiles
└── README.md
```

## Usage

### Build Vector Tiles

```bash
# Download OSM data
./scripts/download_data.sh region_name

# Build maritime vector tiles
./scripts/build_tiles.sh
```

### Coastline Handling

The maritime map includes global coastline handling based on [tilemaker's coastline capabilities](https://github.com/systemed/tilemaker/blob/master/docs/RUNNING.md#creating-a-map-with-varying-detail):

- **Global coastlines**: Uses water polygons from OSM data
- **Coastline clipping**: Maritime features are clipped to coastlines
- **Varying detail**: Different zoom levels with appropriate simplification
- **Coastline layer**: Dedicated coastline layer for precise boundaries

Test coastline handling:
```bash
just test-coastline monaco
```

### Layer Visibility

The maritime map includes optimized layer visibility:

- **Coastlines**: Always visible globally (zoom 0-14)
- **Land vs Water**: Simple distinction between land and water (zoom 0-14)
- **Water Bodies**: Detailed water features at zoom 10+
- **Cables**: Visible at zoom 7+ for underwater infrastructure
- **Major Cities**: Only admin_level 2 cities visible at zoom 7+
- **Seamarks**: Visible at zoom 8+ for maritime navigation

Test visibility:
```bash
just test-visibility monaco
```

Test land vs water distinction:
```bash
just test-land-water monaco
```

### Build Raster Tiles

```bash
# Download seamark tiles
./scripts/build_tilepack.sh \
  "https://t1.openseamap.org/seamark/{z}/{x}/{y}.png" \
  "output/tiles/seamark_raster.pmtiles" \
  "0" "14" "bbox_coordinates" "20"
```

### MapLibre Integration

```javascript
// Initialize PMTiles protocol
const protocol = new pmtiles.Protocol();
maplibregl.addProtocol("pmtiles", protocol.tile);

// Create map
const map = new maplibregl.Map({
    container: 'map',
    style: generateMaritimeStyle(),
    center: [0, 0],
    zoom: 6
});
```

## Prerequisites

- tilemaker v3.0.0
- tilepack
- pmtiles
- Docker (for serving tiles)

## Testing GitHub Action Locally

### Using act (Recommended)
```bash
# Install act if not already installed
brew install act

# Test the complete GitHub Action workflow locally
./test_with_act.sh monaco "7.4,43.7,7.5,43.8"

# Test only the build jobs (faster, no deployment)
./test_build_only.sh monaco "7.4,43.7,7.5,43.8"

# Or run act directly
act workflow_dispatch \
  -W .github/workflows/build-and-deploy.yml \
  --input osm_region="monaco" \
  --input bbox="7.4,43.7,7.5,43.8" \
  --input build_vector="true" \
  --input build_raster="true" \
  --container-architecture linux/amd64 \
  --verbose
```

### Manual Testing
```bash
# Test individual components
./scripts/download_data.sh monaco
./scripts/build_tiles.sh data/osm/monaco-latest.osm.pbf output/tiles/monaco_maritime.pmtiles
./scripts/serve_tiles.sh output/tiles/monaco_maritime.pmtiles
```

## License

Open source. Respect tile server terms of service.
