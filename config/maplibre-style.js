/**
 * Generate MapLibre style for Maritime Map
 * @param {Object} config - Style configuration object
 * @returns {Object} MapLibre style object
 */
function generateMaritimeStyle(config = {}) {
  // Default configuration
  const defaultConfig = {
    // Water colors
    water: {
      fill: '#a8d1e0',
      opacity: 0.8
    },
    
    // Coastline colors
    coastline: {
      color: '#2c5aa0',
      width: 1
    },
    
    // Landuse colors
    landuse: {
      beach: '#f4e4c1',
      earth: '#d2b48c',
      protected: '#90ee90',
      default: '#f5f5f5',
      opacity: 0.7
    },
    
    // River colors
    rivers: {
      color: '#4a90e2',
      minWidth: 1,
      maxWidth: 3
    },
    
    // Ferry routes
    ferry: {
      color: '#ff6b35',
      width: 2,
      dashArray: [2, 2]
    },
    
    // Territorial waters
    territorial: {
      color: '#ff0000',
      width: 2,
      dashArray: [5, 5]
    },
    
    // Military areas
    military: {
      fill: '#ff6b6b',
      opacity: 0.3
    },
    
    // Airports
    airports: {
      fill: '#8b4513',
      outline: '#654321',
      opacity: 0.5
    },
    
    // Ports
    ports: {
      fill: '#4169e1',
      opacity: 0.6
    },
    
    // Marinas
    marinas: {
      fill: '#32cd32',
      opacity: 0.6
    },
    
    // Underwater cables
    cables: {
      color: '#ff1493',
      width: 1,
      dashArray: [1, 1]
    },
    
    // Seamarks
    seamarks: {
      buoy: '#ffff00',
      beacon: '#ffa500',
      light: '#ffff00',
      default: '#ff0000',
      radius: 3,
      strokeColor: '#000000',
      strokeWidth: 1
    },
    
    // Text colors
    text: {
      color: '#000000',
      haloColor: '#ffffff',
      haloWidth: 1
    },
    
    // Background
    background: '#e8f4f8',
    
    // Fonts
    fonts: {
      primary: ['Open Sans Regular'],
      secondary: ['Open Sans Regular']
    }
  };

  // Merge user config with defaults
  const styleConfig = {
    ...defaultConfig,
    ...config,
    water: { ...defaultConfig.water, ...config.water },
    coastline: { ...defaultConfig.coastline, ...config.coastline },
    landuse: { ...defaultConfig.landuse, ...config.landuse },
    rivers: { ...defaultConfig.rivers, ...config.rivers },
    ferry: { ...defaultConfig.ferry, ...config.ferry },
    territorial: { ...defaultConfig.territorial, ...config.territorial },
    military: { ...defaultConfig.military, ...config.military },
    airports: { ...defaultConfig.airports, ...config.airports },
    ports: { ...defaultConfig.ports, ...config.ports },
    marinas: { ...defaultConfig.marinas, ...config.marinas },
    cables: { ...defaultConfig.cables, ...config.cables },
    seamarks: { ...defaultConfig.seamarks, ...config.seamarks },
    text: { ...defaultConfig.text, ...config.text }
  };

  return {
    version: 8,
            name: "Maritime Map",
    sources: {
      "maritime-tiles": {
        type: "vector",
                  url: "./maritime.pmtiles"
      }
    },
    sprite: "",
    glyphs: "https://fonts.openmaptiles.org/{fontstack}/{range}.pbf",
    layers: [
      {
        id: "background",
        type: "background",
        paint: {
          "background-color": styleConfig.background
        }
      },
      {
        id: "water",
        type: "fill",
        source: "maritime-tiles",
        "source-layer": "water",
        paint: {
          "fill-color": styleConfig.water.fill,
          "fill-opacity": styleConfig.water.opacity
        }
      },
      {
        id: "coastline",
        type: "line",
        source: "maritime-tiles",
        "source-layer": "coastline",
        paint: {
          "line-color": styleConfig.coastline.color,
          "line-width": styleConfig.coastline.width
        }
      },
      {
        id: "landuse",
        type: "fill",
        source: "maritime-tiles",
        "source-layer": "landuse",
        paint: {
          "fill-color": [
            "case",
            ["==", ["get", "landuse"], "beach"], styleConfig.landuse.beach,
            ["==", ["get", "landuse"], "earth"], styleConfig.landuse.earth,
            ["==", ["get", "landuse"], "protected_area"], styleConfig.landuse.protected,
            ["==", ["get", "natural"], "beach"], styleConfig.landuse.beach,
            ["==", ["get", "natural"], "protected_area"], styleConfig.landuse.protected,
            styleConfig.landuse.default
          ],
          "fill-opacity": styleConfig.landuse.opacity
        }
      },
      {
        id: "rivers",
        type: "line",
        source: "maritime-tiles",
        "source-layer": "rivers",
        minzoom: 10,
        paint: {
          "line-color": styleConfig.rivers.color,
          "line-width": [
            "interpolate",
            ["linear"],
            ["zoom"],
            10, styleConfig.rivers.minWidth,
            14, styleConfig.rivers.maxWidth
          ]
        }
      },
      {
        id: "ferry-routes",
        type: "line",
        source: "maritime-tiles",
        "source-layer": "ferry_routes",
        paint: {
          "line-color": styleConfig.ferry.color,
          "line-width": styleConfig.ferry.width,
          "line-dasharray": styleConfig.ferry.dashArray
        }
      },
      {
        id: "territorial-waters",
        type: "line",
        source: "maritime-tiles",
        "source-layer": "territorial_waters",
        paint: {
          "line-color": styleConfig.territorial.color,
          "line-width": styleConfig.territorial.width,
          "line-dasharray": styleConfig.territorial.dashArray
        }
      },
      {
        id: "military",
        type: "fill",
        source: "maritime-tiles",
        "source-layer": "military",
        paint: {
          "fill-color": styleConfig.military.fill,
          "fill-opacity": styleConfig.military.opacity
        }
      },
      {
        id: "airports",
        type: "fill",
        source: "maritime-tiles",
        "source-layer": "airports",
        paint: {
          "fill-color": styleConfig.airports.fill,
          "fill-opacity": styleConfig.airports.opacity
        }
      },
      {
        id: "airports-outline",
        type: "line",
        source: "maritime-tiles",
        "source-layer": "airports",
        paint: {
          "line-color": styleConfig.airports.outline,
          "line-width": 1
        }
      },
      {
        id: "ports",
        type: "fill",
        source: "maritime-tiles",
        "source-layer": "ports",
        paint: {
          "fill-color": styleConfig.ports.fill,
          "fill-opacity": styleConfig.ports.opacity
        }
      },
      {
        id: "marinas",
        type: "fill",
        source: "maritime-tiles",
        "source-layer": "marinas",
        paint: {
          "fill-color": styleConfig.marinas.fill,
          "fill-opacity": styleConfig.marinas.opacity
        }
      },
      {
        id: "cables",
        type: "line",
        source: "maritime-tiles",
        "source-layer": "cables",
        paint: {
          "line-color": styleConfig.cables.color,
          "line-width": styleConfig.cables.width,
          "line-dasharray": styleConfig.cables.dashArray
        }
      },
      {
        id: "seamarks",
        type: "circle",
        source: "maritime-tiles",
        "source-layer": "seamarks",
        paint: {
          "circle-radius": styleConfig.seamarks.radius,
          "circle-color": [
            "case",
            ["==", ["get", "seamark_type"], "buoy"], styleConfig.seamarks.buoy,
            ["==", ["get", "seamark_type"], "beacon"], styleConfig.seamarks.beacon,
            ["==", ["get", "seamark_type"], "light"], styleConfig.seamarks.light,
            styleConfig.seamarks.default
          ],
          "circle-stroke-color": styleConfig.seamarks.strokeColor,
          "circle-stroke-width": styleConfig.seamarks.strokeWidth
        }
      },
      {
        id: "cities",
        type: "symbol",
        source: "maritime-tiles",
        "source-layer": "cities",
        layout: {
          "text-field": ["get", "name"],
          "text-font": styleConfig.fonts.primary,
          "text-size": [
            "interpolate",
            ["linear"],
            ["zoom"],
            4, 10,
            14, 16
          ]
        },
        paint: {
          "text-color": styleConfig.text.color,
          "text-halo-color": styleConfig.text.haloColor,
          "text-halo-width": styleConfig.text.haloWidth
        }
      },
      {
        id: "airport-labels",
        type: "symbol",
        source: "maritime-tiles",
        "source-layer": "airports",
        layout: {
          "text-field": ["get", "name"],
          "text-font": styleConfig.fonts.secondary,
          "text-size": 12
        },
        paint: {
          "text-color": styleConfig.airports.outline,
          "text-halo-color": styleConfig.text.haloColor,
          "text-halo-width": styleConfig.text.haloWidth
        }
      },
      {
        id: "port-labels",
        type: "symbol",
        source: "maritime-tiles",
        "source-layer": "ports",
        layout: {
          "text-field": ["get", "name"],
          "text-font": styleConfig.fonts.secondary,
          "text-size": 11
        },
        paint: {
          "text-color": styleConfig.ports.fill,
          "text-halo-color": styleConfig.text.haloColor,
          "text-halo-width": styleConfig.text.haloWidth
        }
      },
      {
        id: "marina-labels",
        type: "symbol",
        source: "maritime-tiles",
        "source-layer": "marinas",
        layout: {
          "text-field": ["get", "name"],
          "text-font": styleConfig.fonts.secondary,
          "text-size": 10
        },
        paint: {
          "text-color": styleConfig.marinas.fill,
          "text-halo-color": styleConfig.text.haloColor,
          "text-halo-width": styleConfig.text.haloWidth
        }
      }
    ]
  };
}

// Export for use in different environments
if (typeof module !== 'undefined' && module.exports) {
  module.exports = generateMaritimeStyle;
} else if (typeof window !== 'undefined') {
  window.generateMaritimeStyle = generateMaritimeStyle;
}
