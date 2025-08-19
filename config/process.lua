-- Maritime Map Processing Script for tilemaker 3.0+
-- Focuses on sea-related features, ports, and minimal land features
-- Includes global coastline handling and clipping

-- Enter/exit Tilemaker
function init_function(name, is_first)
end

function exit_function()
end

-- Process nodes
function node_function()
  -- Enhanced seamarks with anchorage and mooring
  local seamark_type = Find("seamark:type")
  if seamark_type ~= "" then
    Layer("seamarks", false)
    Attribute("seamark_type", seamark_type)
    
    -- Add specific seamark attributes
    local anchorage = Find("seamark:anchorage:category")
    if anchorage ~= "" then
      Attribute("anchorage_category", anchorage)
    end
    
    local mooring = Find("seamark:mooring:category")
    if mooring ~= "" then
      Attribute("mooring_category", mooring)
    end
    
    local buoy_category = Find("seamark:buoy:category")
    if buoy_category ~= "" then
      Attribute("buoy_category", buoy_category)
    end
    
    local light_char = Find("seamark:light:characteristic")
    if light_char ~= "" then
      Attribute("light_characteristic", light_char)
    end
    
    local beacon_category = Find("seamark:beacon:category")
    if beacon_category ~= "" then
      Attribute("beacon_category", beacon_category)
    end
  end
  
  -- Cities and settlements (only major cities with admin_level 2)
  local place = Find("place")
  if place == "city" or place == "town" then
    local admin_level = Find("admin_level")
    
    -- Only include major cities with admin_level 2
    if admin_level == "2" then
      Layer("cities", false)
      Attribute("place", place)
      Attribute("admin_level", admin_level)
      local name = Find("name")
      if name ~= "" then
        Attribute("name", name)
      end
    end
  end
  
  -- Airports (only outline and name)
  local aeroway = Find("aeroway")
  local amenity = Find("amenity")
  if aeroway == "aerodrome" or amenity == "aerodrome" then
    Layer("airports", false)
    Attribute("type", "aerodrome")
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
    local iata = Find("iata")
    if iata ~= "" then
      Attribute("iata", iata)
    end
    local icao = Find("icao")
    if icao ~= "" then
      Attribute("icao", icao)
    end
  end
  
  -- Military areas
  local military = Find("military")
  local landuse = Find("landuse")
  if military ~= "" or landuse == "military" then
    Layer("military", false)
    if military ~= "" then
      Attribute("military", military)
    end
  end
  
  -- Ports and marinas
  local harbour = Find("harbour")
  local port = Find("port")
  local marina = Find("marina")
  local amenity = Find("amenity")
  local leisure = Find("leisure")
  
  if harbour ~= "" or port ~= "" or marina ~= "" or amenity == "marina" then
    if marina ~= "" or leisure == "marina" then
      Layer("marinas", false)
      Attribute("type", "marina")
    else
      Layer("ports", false)
      Attribute("type", "port")
    end
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
end

-- Process ways
function way_function()
  -- Water bodies (oceans, seas, lakes)
  local natural = Find("natural")
  local water = Find("water")
  local waterway = Find("waterway")
  
  if natural == "water" or water ~= "" then
    Layer("water", false)
    if natural == "water" then
      Attribute("type", "water")
    elseif water ~= "" then
      Attribute("type", water)
    end
  end
  
  -- Rivers (only at zoom 10+)
  if waterway == "river" then
    Layer("rivers", false)
    Attribute("type", "river")
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Coastline (will be clipped to global coastlines)
  if natural == "coastline" then
    Layer("coastline", false)
    Attribute("type", "coastline")
  end
  
  -- Landuse (simple land vs water distinction)
  local landuse = Find("landuse")
  local natural = Find("natural")
  local water = Find("water")
  
  -- Only include basic land/water distinction
  if landuse == "earth" or natural == "beach" or water ~= "" then
    Layer("landuse", false)
    if landuse == "earth" then
      Attribute("type", "land")
    elseif natural == "beach" then
      Attribute("type", "beach")
    elseif water ~= "" then
      Attribute("type", "water")
    end
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Ferry routes (roads with route=ferry)
  local route = Find("route")
  local ferry = Find("ferry")
  local highway = Find("highway")
  if route == "ferry" or ferry == "yes" or (highway == "ferry" and route == "ferry") then
    Layer("ferry_routes", false)
    Attribute("type", "ferry")
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Underwater cables
  local cable = Find("cable")
  local power = Find("power")
  local submarine = Find("submarine")
  if cable ~= "" or power == "cable" or submarine == "yes" then
    Layer("cables", false)
    if cable ~= "" then
      Attribute("cable_type", cable)
    elseif power == "cable" then
      Attribute("cable_type", "power")
    end
  end
  
  -- Territorial waters
  local boundary = Find("boundary")
  local border_type = Find("border_type")
  if boundary == "territorial" or border_type == "territorial" then
    Layer("territorial_waters", false)
    Attribute("type", "territorial")
  end
  
  -- Military areas
  local military = Find("military")
  local landuse = Find("landuse")
  if military ~= "" or landuse == "military" then
    Layer("military", false)
    if military ~= "" then
      Attribute("military", military)
    end
  end
  
  -- Airports (only outline)
  local aeroway = Find("aeroway")
  if aeroway == "aerodrome" or aeroway == "runway" or aeroway == "taxiway" then
    Layer("airports", false)
    Attribute("aeroway", aeroway)
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Ports and marinas
  local harbour = Find("harbour")
  local port = Find("port")
  local marina = Find("marina")
  local leisure = Find("leisure")
  
  if harbour ~= "" or port ~= "" or marina ~= "" then
    if marina ~= "" or leisure == "marina" then
      Layer("marinas", false)
      Attribute("type", "marina")
    else
      Layer("ports", false)
      Attribute("type", "port")
    end
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
end

-- Process relations
function relation_function()
  -- Water bodies (oceans, seas, lakes, rivers)
  local natural = Find("natural")
  local water = Find("water")
  local waterway = Find("waterway")
  
  if natural == "water" or water ~= "" or waterway ~= "" then
    Layer("water", true)
    if natural == "water" then
      Attribute("type", "water")
    elseif water ~= "" then
      Attribute("type", water)
    elseif waterway ~= "" then
      Attribute("type", waterway)
    end
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Coastline (will be clipped to global coastlines)
  if natural == "coastline" then
    Layer("coastline", true)
    Attribute("type", "coastline")
  end
  
  -- Landuse (simple land vs water distinction)
  local landuse = Find("landuse")
  local natural = Find("natural")
  local water = Find("water")
  
  -- Only include basic land/water distinction
  if landuse == "earth" or natural == "beach" or water ~= "" then
    Layer("landuse", true)
    if landuse == "earth" then
      Attribute("type", "land")
    elseif natural == "beach" then
      Attribute("type", "beach")
    elseif water ~= "" then
      Attribute("type", "water")
    end
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Territorial waters
  local boundary = Find("boundary")
  local border_type = Find("border_type")
  if boundary == "territorial" or border_type == "territorial" then
    Layer("territorial_waters", true)
    Attribute("type", "territorial")
  end
  
  -- Military areas
  local military = Find("military")
  local landuse = Find("landuse")
  if military ~= "" or landuse == "military" then
    Layer("military", true)
    if military ~= "" then
      Attribute("military", military)
    end
  end
  
  -- Airports (only outline)
  local aeroway = Find("aeroway")
  if aeroway == "aerodrome" then
    Layer("airports", true)
    Attribute("type", "aerodrome")
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Ports and marinas
  local harbour = Find("harbour")
  local port = Find("port")
  local marina = Find("marina")
  local leisure = Find("leisure")
  
  if harbour ~= "" or port ~= "" or marina ~= "" then
    if marina ~= "" or leisure == "marina" then
      Layer("marinas", true)
      Attribute("type", "marina")
    else
      Layer("ports", true)
      Attribute("type", "port")
    end
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
  
  -- Major cities (only admin_level 2)
  local place = Find("place")
  if place == "city" or place == "town" then
    local admin_level = Find("admin_level")
    
    -- Only include major cities with admin_level 2
    if admin_level == "2" then
      Layer("cities", true)
      Attribute("place", place)
      Attribute("admin_level", admin_level)
      local name = Find("name")
      if name ~= "" then
        Attribute("name", name)
      end
    end
  end
end