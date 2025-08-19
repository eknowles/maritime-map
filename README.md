# Maritime Map

Generate offline maritime vector tiles from OpenStreetMap data using PMTiles format.

## Features

- **Vector Tiles**: Build maritime-focused vector tiles with tilemaker
- **Raster Tiles**: Download raster tiles from OpenSeaMap using tilepack
- **Offline Maps**: Single-file PMTiles archives for offline use
- **Global Coastlines**: Built-in coastline handling and clipping
- **Maritime Focus**: Seamarks, ports, marinas, and maritime infrastructure

## Installation

The project requires:
- `tilemaker` for building vector tiles
- `tilepack` for downloading raster tiles (via Homebrew: `brew tap eknowles/tools && brew install tilepack`)
- `pmtiles` for serving tiles (via Homebrew: `brew install pmtiles`)

## Quick Start

```bash
# Setup the project
./setup.sh

# Build maritime tiles for a region
./build_maritime_map.sh monaco

# Serve tiles locally
./scripts/serve_tiles.sh
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

Test city filtering:
```bash
just test-cities monaco
```

## Development

### Testing with Act

Test GitHub Actions locally:

```bash
# Test complete workflow
./test_with_act.sh monaco

# Test build jobs only
./test_build_only.sh monaco
```

### Testing Tools

```bash
# Test Homebrew installation
just test-homebrew

# Test tilepack installation
just test-tilepack

# Test architecture detection
just test-architecture
```

## Commands

Use `just` for common tasks:

```bash
# Build maritime tiles
just build monaco

# Download data
just download monaco

# Build tiles
just tiles

# Build raster tiles
just raster

# Validate tiles
just validate

# Serve tiles
just serve

# Clean up
just clean
```

## License

MIT License
