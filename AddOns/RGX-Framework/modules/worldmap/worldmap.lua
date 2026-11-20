--=============================================================================
-- RGX-Framework | RGXWorldMap
--
-- World-map pin and waypoint primitives for RGX consumers (e.g.
-- realmgx-guides map pins), implemented entirely over the native WoW
-- C_Map API. The framework writes its own libraries: no external
-- coordinate libraries are referenced or embedded.
--
-- Provides:
--   Pin lifecycle on world map and minimap:
--     AddWorldMapIcon, RemoveWorldMapIcon, UpdateWorldMapIcon
--     AddMinimapIcon, RemoveMinimapIcon, UpdateMinimapIcon
--     RemoveAllWorldMapIcons, RemoveAllMinimapIcons
--
--   Zone-data adapter (the only supported coordinate seam):
--     All coordinate conversions route through one adapter,
--     RGXWorldMap:GetCoordsAdapter(), so consumers never call C_Map
--     directly. Every call is capability-gated: a flavor that lacks an
--     API yields nils, never errors.
--
--   Waypoints (the game's own map pin) and the nearest place:
--     CanSetWaypoint, SetWaypoint, ClearWaypoint, Nearest
--
--   Coordinate helpers:
--     GetPlayerWorldPosition, GetPlayerZone, GetZoneSize,
--     GetWorldCoordinatesFromZone, GetZoneCoordinatesFromWorld,
--     GetWorldVector, GetWorldDistance
--
-- Argument shapes follow the legacy pin call sites realmgx-guides already
-- ships so its port stays 1:1.
--
-- Flavors (verified against the client API dumps):
--   Retail / Forever - full coverage (incl. C_Map.GetMapWorldSize).
--   Classic-era / TBC / Mists - C_Map without GetMapWorldSize; zone size
--     returns nils there (documented capability difference).
--   Wrath / Cata - C_Map per client capability; every call is nil-guarded.
--=============================================================================

local addonName, RGX = ...

--=============================================================================
-- Internal state
--=============================================================================

local WorldMap = {
    name = "worldmap",
    version = "1.0.0",
    _pins = {},
    _minimapPins = {},
    _pinPool = {},
    _minimapPinPool = {},
    _worldMapFrame = nil,
    _minimapFrame = nil,
    _coordsAdapter = nil,
}

-- Unique pin ID counter for registry keys.
local pinIdCounter = 0

local function genId()
    pinIdCounter = pinIdCounter + 1
    return "RGXWorldMap_Pin_" .. pinIdCounter
end

--=============================================================================
-- Coordinate adapter - our own C_Map-native seam (no external libraries).
--=============================================================================

-- Real APIs (verified against the client API dumps and Blizzard's generated
-- API documentation; signatures must not be guessed):
--   C_Map.GetBestMapForUnit(unitToken) -> uiMapID
--   C_Map.GetPlayerMapPosition(uiMapID, unitToken) -> vector2 (0-1 map coords)
--   C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition) -> continentID, worldPosition
--   C_Map.GetMapPosFromWorldPos(continentID, worldPosition [, overrideUiMapID])
--     -> uiMapID, mapPosition
--   C_Map.GetMapWorldSize(uiMapID) -> width, height (yards)
--   CreateVector2D(x, y) -> vector2 (FrameXML global)

-- Get the active coordinate adapter (native C_Map, capability-gated).
-- A position the client hands back: a vector (GetXY) or, on some clients, a plain { x, y } table.
local function XY(pos)
    if type(pos) ~= "table" then return nil, nil end
    if type(pos.GetXY) == "function" then
        local ok, x, y = pcall(pos.GetXY, pos)
        if ok and type(x) == "number" and type(y) == "number" then return x, y end
    end
    if type(pos.x) == "number" and type(pos.y) == "number" then return pos.x, pos.y end
    return nil, nil
end

function WorldMap:GetCoordsAdapter()
    if self._coordsAdapter then return self._coordsAdapter end

    local adapter = {}

    function adapter.GetPlayerZone()
        if C_Map and C_Map.GetBestMapForUnit then
            return C_Map.GetBestMapForUnit("player")
        end
        return nil
    end

    -- Player position in world coordinates (continent yards).
    -- Returns worldX, worldY, continentID; nils when unresolvable.
    function adapter.GetPlayerWorldPosition()
        local mapID = adapter.GetPlayerZone()
        if mapID and C_Map.GetPlayerMapPosition and C_Map.GetWorldPosFromMapPos
            and CreateVector2D then
            local x, y = XY(C_Map.GetPlayerMapPosition(mapID, "player"))
            if x then
                local continentID, worldPos =
                    C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
                local wx, wy = XY(worldPos)
                if wx then return wx, wy, continentID end
            end
        end
        return nil, nil, nil
    end

    function adapter.GetZoneSize(mapID)
        -- C_Map.GetMapWorldSize ships on Retail and Forever; Classic-era,
        -- TBC and Mists do not expose zone dimensions (capability
        -- difference: nils, never errors).
        if mapID and C_Map and C_Map.GetMapWorldSize then
            return C_Map.GetMapWorldSize(mapID)
        end
        return nil, nil
    end

    -- zoneX/zoneY are 0-100 zone coordinates (legacy pin call shape).
    -- 'floor' is accepted for call-shape compatibility only; C_Map has no
    -- floor concept. Returns worldX, worldY, continentID.
    function adapter.GetWorldCoordinatesFromZone(zoneX, zoneY, mapID, floor)
        if mapID and zoneX and zoneY and C_Map and C_Map.GetWorldPosFromMapPos
            and CreateVector2D then
            local continentID, worldPos = C_Map.GetWorldPosFromMapPos(
                mapID, CreateVector2D(zoneX / 100, zoneY / 100))
            local wx, wy = XY(worldPos)
            if wx then return wx, wy, continentID end
        end
        return nil, nil, nil
    end

    -- continentID is the continent the world coordinates live in (the
    -- first return of GetWorldPosFromMapPos). Returns zoneX, zoneY (0-100)
    -- and the resolved uiMapID.
    function adapter.GetZoneCoordinatesFromWorld(worldX, worldY, continentID)
        if continentID and worldX and worldY and C_Map and C_Map.GetMapPosFromWorldPos
            and CreateVector2D then
            local uiMapID, mapPos = C_Map.GetMapPosFromWorldPos(
                continentID, CreateVector2D(worldX, worldY))
            local x, y = XY(mapPos)
            if x then return x * 100, y * 100, uiMapID end
        end
        return nil, nil
    end

    -- 'instance' is accepted for call-shape compatibility; unused. World
    -- coordinates are per continent, so planar math is exact within one.
    function adapter.GetWorldVector(instance, x1, y1, x2, y2)
        if x1 and y1 and x2 and y2 then
            local dx, dy = x2 - x1, y2 - y1
            return math.atan2(dy, dx), math.sqrt(dx * dx + dy * dy)
        end
        return nil, nil
    end

    function adapter.GetWorldDistance(instance, x1, y1, x2, y2)
        if x1 and y1 and x2 and y2 then
            local dx, dy = x2 - x1, y2 - y1
            return math.sqrt(dx * dx + dy * dy)
        end
        return nil
    end

    self._coordsAdapter = adapter
    return adapter
end

--=============================================================================
-- Frame management
--=============================================================================

local function getWorldMapFrame()
    if WorldMap._worldMapFrame then
        return WorldMap._worldMapFrame
    end
    if _G.WorldMapFrame then
        WorldMap._worldMapFrame = _G.WorldMapFrame
    end
    return WorldMap._worldMapFrame
end

local function getMinimapFrame()
    if WorldMap._minimapFrame then
        return WorldMap._minimapFrame
    end
    if _G.Minimap then
        WorldMap._minimapFrame = _G.Minimap
    end
    return WorldMap._minimapFrame
end

local function ensurePinPool()
    if not WorldMap._pinPool then
        WorldMap._pinPool = {}
    end
end

--=============================================================================
-- Pin lifecycle — world map
--=============================================================================

-- AddWorldMapIcon(pinFrame, icon, mapID, x, y, name)
-- Argument order kept stable for existing callers.
-- pinFrame: a frame to use as the pin (or nil to create one)
-- icon: texture path
-- mapID: uiMapID (0/nil = player's current zone)
-- x, y: 0-1 world map coordinates
-- name: unique identifier for this pin
function WorldMap:AddWorldMapIcon(pinFrame, icon, mapID, x, y, name)
    if type(icon) ~= "string" then
        error("RGXWorldMap: AddWorldMapIcon requires icon (string) as 2nd arg", 2)
    end

    local key = name or genId()
    mapID = mapID or (self:GetCoordsAdapter().GetPlayerZone() or 0)

    local frame = pinFrame
    if not frame or type(frame) ~= "table" then
        frame = CreateFrame("Frame", key, getWorldMapFrame(), "BackdropTemplate")
        if not frame then return nil end
    end

    frame.texture = frame.texture or frame:CreateTexture(nil, "OVERLAY")
    frame.texture:SetTexture(icon)
    frame.texture:SetAllPoints(frame)

    frame:SetWidth(16)
    frame:SetHeight(16)
    frame:SetPoint("CENTER", getWorldMapFrame(), "TOPLEFT", x * 100, -y * 100)
    frame:Show()

    self._pins[key] = {
        frame = frame,
        icon = icon,
        mapID = mapID,
        x = x,
        y = y,
        name = key,
    }

    return frame
end

function WorldMap:RemoveWorldMapIcon(name)
    if type(name) ~= "string" then return false end
    local pin = self._pins[name]
    if not pin then return false end
    if pin.frame and type(pin.frame) == "table" and pin.frame.SetParent then
        pin.frame:SetParent(nil)
        pin.frame:Hide()
    end
    self._pins[name] = nil
    return true
end

function WorldMap:UpdateWorldMapIcon(name, x, y)
    local pin = self._pins[name]
    if not pin then return false end
    pin.x = x or pin.x
    pin.y = y or pin.y
    if pin.frame and pin.frame.SetPoint then
        pin.frame:SetPoint("CENTER", getWorldMapFrame(), "TOPLEFT", pin.x * 100, -pin.y * 100)
    end
    return true
end

function WorldMap:RemoveAllWorldMapIcons()
    for key, pin in pairs(self._pins) do
        if pin.frame and type(pin.frame) == "table" and pin.frame.SetParent then
            pin.frame:SetParent(nil)
            pin.frame:Hide()
        end
    end
    self._pins = {}
    return true
end

--=============================================================================
-- Pin lifecycle — minimap
--=============================================================================

-- AddMinimapIcon(pinFrame, icon, mapID, x, y, name)
-- Similar to world map; positions on minimap texture relative to center.
function WorldMap:AddMinimapIcon(pinFrame, icon, mapID, x, y, name)
    if type(icon) ~= "string" then
        error("RGXWorldMap: AddMinimapIcon requires icon (string) as 2nd arg", 2)
    end

    local key = name or genId()
    local minimap = getMinimapFrame()

    local frame = pinFrame
    if not frame or type(frame) ~= "table" then
        if not minimap then return nil end
        frame = CreateFrame("Frame", key, minimap, "BackdropTemplate")
        if not frame then return nil end
    end

    frame.texture = frame.texture or frame:CreateTexture(nil, "OVERLAY")
    frame.texture:SetTexture(icon)
    frame.texture:SetAllPoints(frame)

    frame:SetWidth(16)
    frame:SetHeight(16)

    -- If x,y are 0-1 map coords, scale to minimap radius. Otherwise treat as raw offsets.
    if minimap then
        if x and y and x <= 1 and y <= 1 and x >= 0 and y >= 0 then
            local radius = 80
            frame:SetPoint("CENTER", minimap, "CENTER", (x - 0.5) * radius * 2, (y - 0.5) * radius * 2)
        else
            frame:SetPoint("CENTER", minimap, "CENTER", x or 0, y or 0)
        end
    end

    frame:Show()

    self._minimapPins[key] = {
        frame = frame,
        icon = icon,
        mapID = mapID,
        x = x,
        y = y,
        name = key,
    }

    return frame
end

function WorldMap:RemoveMinimapIcon(name)
    if type(name) ~= "string" then return false end
    local pin = self._minimapPins[name]
    if not pin then return false end
    if pin.frame and type(pin.frame) == "table" and pin.frame.SetParent then
        pin.frame:SetParent(nil)
        pin.frame:Hide()
    end
    self._minimapPins[name] = nil
    return true
end

function WorldMap:UpdateMinimapIcon(name, x, y)
    local pin = self._minimapPins[name]
    if not pin then return false end
    pin.x = x or pin.x
    pin.y = y or pin.y
    if pin.frame and pin.frame.SetPoint then
        local minimap = getMinimapFrame()
        if minimap then
            if pin.x and pin.y and pin.x <= 1 and pin.y <= 1 and pin.x >= 0 and pin.y >= 0 then
                local radius = 80
                pin.frame:SetPoint("CENTER", minimap, "CENTER", (pin.x - 0.5) * radius * 2, (pin.y - 0.5) * radius * 2)
            else
                pin.frame:SetPoint("CENTER", minimap, "CENTER", pin.x or 0, pin.y or 0)
            end
        end
    end
    return true
end

function WorldMap:RemoveAllMinimapIcons()
    for key, pin in pairs(self._minimapPins) do
        if pin.frame and type(pin.frame) == "table" and pin.frame.SetParent then
            pin.frame:SetParent(nil)
            pin.frame:Hide()
        end
    end
    self._minimapPins = {}
    return true
end

--=============================================================================
-- Public coordinate helpers — thin pass-throughs to the adapter.
--=============================================================================

function WorldMap:GetPlayerWorldPosition()
    return self:GetCoordsAdapter().GetPlayerWorldPosition()
end

function WorldMap:GetPlayerZone()
    return self:GetCoordsAdapter().GetPlayerZone()
end

function WorldMap:GetZoneSize(mapID)
    return self:GetCoordsAdapter().GetZoneSize(mapID)
end

function WorldMap:GetWorldCoordinatesFromZone(zoneX, zoneY, mapID, floor)
    return self:GetCoordsAdapter().GetWorldCoordinatesFromZone(zoneX, zoneY, mapID, floor)
end

function WorldMap:GetZoneCoordinatesFromWorld(worldX, worldY, continentID)
    return self:GetCoordsAdapter().GetZoneCoordinatesFromWorld(worldX, worldY, continentID)
end

function WorldMap:GetWorldVector(instance, x1, y1, x2, y2)
    return self:GetCoordsAdapter().GetWorldVector(instance, x1, y1, x2, y2)
end

function WorldMap:GetWorldDistance(instance, x1, y1, x2, y2)
    return self:GetCoordsAdapter().GetWorldDistance(instance, x1, y1, x2, y2)
end

--=============================================================================
-- Waypoints - the game's own map pin
--=============================================================================

-- Check accessibility before comparing, calculating with or forwarding a value.
local function waypointValueAccessible(value)
    local api = RGX.API
    if not (api and type(api.CanAccessValue) == "function") then return false end
    local ok, accessible = pcall(api.CanAccessValue, value)
    return ok and accessible == true
end

local function waypointNumber(value)
    return waypointValueAccessible(value) and type(value) == "number"
        and value == value and value > -math.huge and value < math.huge
end

local function ValidMapID(mapID)
    return waypointNumber(mapID) and mapID > 0 and mapID % 1 == 0
end

-- Zone coordinates are finite numbers within 0-100.
local function ValidZoneCoord(v)
    return waypointNumber(v) and v >= 0 and v <= 100
end

-- True only when the client explicitly permits its map pin on this map.
function WorldMap:CanSetWaypoint(mapID)
    if not waypointNumber(mapID) or mapID <= 0 or mapID % 1 ~= 0 then return false end
    if not (C_Map and type(C_Map.SetUserWaypoint) == "function"
        and type(C_Map.CanSetUserWaypointOnMap) == "function"
        and type(CreateVector2D) == "function") then return false end
    local ok, can = pcall(C_Map.CanSetUserWaypointOnMap, mapID)
    return ok and waypointValueAccessible(can) and can == true
end

-- Put the game's map pin on mapID at zone coordinates x, y (0-100) and track it (opts.track = false leaves
-- tracking alone). Returns true when the pin is set; false for invalid input, a map the client cannot pin, or a
-- setter error. The caller tells the player.
function WorldMap:SetWaypoint(mapID, x, y, opts)
    if not waypointNumber(x) or not waypointNumber(y)
        or x < 0 or x > 100 or y < 0 or y > 100
        or not self:CanSetWaypoint(mapID) then return false end
    local px, py = x / 100, y / 100
    local point = { uiMapID = mapID, position = CreateVector2D(px, py) }
    if _G.UiMapPoint and type(_G.UiMapPoint.CreateFromCoordinates) == "function" then
        local ok, made = pcall(_G.UiMapPoint.CreateFromCoordinates, mapID, px, py)
        if ok and made then point = made end
    end
    local ok, wasSet = pcall(C_Map.SetUserWaypoint, point)
    if not (ok and waypointValueAccessible(wasSet) and wasSet == true) then return false end
    if not (type(opts) == "table" and opts.track == false)
        and C_SuperTrack and type(C_SuperTrack.SetSuperTrackedUserWaypoint) == "function" then
        pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
    end
    return true
end

function WorldMap:ClearWaypoint()
    if C_Map and type(C_Map.ClearUserWaypoint) == "function" then
        return pcall(C_Map.ClearUserWaypoint)
    end
    return false
end

-- The place nearest the player. places is a list of tables with a map id (mapID or zoneID) and zone coordinates
-- x, y (0-100). Distance is measured in world yards on the player's continent; places on other continents
-- count only when nothing on the player's continent is known. Returns the place and its distance (nil when the
-- player's position cannot be read; the first place is returned then).
function WorldMap:Nearest(places)
    if type(places) ~= "table" or #places == 0 then return nil end
    local adapter = self:GetCoordsAdapter()
    local pwx, pwy, pCont = adapter.GetPlayerWorldPosition()
    local best, bestDist = nil, nil
    if pwx then
        for _, place in ipairs(places) do
            local mapID = type(place) == "table" and (place.mapID or place.zoneID) or nil
            local wx, wy, cont
            if ValidMapID(mapID) and ValidZoneCoord(place.x) and ValidZoneCoord(place.y) then
                wx, wy, cont = adapter.GetWorldCoordinatesFromZone(place.x, place.y, mapID)
            end
            if wx and cont == pCont then
                local d = adapter.GetWorldDistance(nil, pwx, pwy, wx, wy)
                if d and (not bestDist or d < bestDist) then best, bestDist = place, d end
            end
        end
    end
    return best or places[1], bestDist
end

--=============================================================================
-- Init & registration
--=============================================================================

function WorldMap:Init()
    ensurePinPool()
    self._pins = {}
    self._minimapPins = {}
end

_G.RGXWorldMap = WorldMap
RGX:RegisterModule("worldmap", WorldMap, {
    category = "game",
    global = "RGXWorldMap",
})
