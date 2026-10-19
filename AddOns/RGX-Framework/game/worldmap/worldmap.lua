--=============================================================================
-- RGX-Framework | RGXWorldMap
--
-- World-map pin and waypoint primitives that replace HereBeDragons-Pins
-- semantics for RGX consumers (e.g. realmgx-guides Phase 5 map pins).
--
-- Provides:
--   Pin lifecycle on world map and minimap:
--     AddWorldMapIcon, RemoveWorldMapIcon, UpdateWorldMapIcon
--     AddMinimapIcon, RemoveMinimapIcon, UpdateMinimapIcon
--     RemoveAllWorldMapIcons, RemoveAllMinimapIcons
--
--   Zone-data isolation adapter:
--     All coordinate calls go through the WoW C_Map API with HereBeDragons
--     zone data isolated behind a single adapter (RGXWorldMap.Coords) so
--     consumers never embed the full library. If the retail C_Map layer
--     is unavailable (Classic era / Wrath), the adapter transparently
--     falls back to LibStub("HereBeDragons-2.0") when it is present.
--
--   Coordinate helpers:
--     GetPlayerWorldPosition, GetPlayerZone, GetZoneSize,
--     GetWorldCoordinatesFromZone, GetZoneCoordinatesFromWorld,
--     GetWorldVector, GetWorldDistance
--
-- The public module surface mirrors HereBeDragons-Pins argument shapes so
-- realmgx-guides call sites can be ported 1:1.
--
-- Flavors:
--   Retail (120105+) — C_Map native path, no fallback required.
--   Classic / Wrath / TBC / Cata / Mists — C_Map is partial; the adapter
--   falls back to HereBeDragons-2.0 when a C_Map call returns nil.
--=============================================================================

local addonName, RGX = ...

local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE or 1
local WOW_PROJECT_CLASSIC = WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 3
local WOW_PROJECT_WRATH_CLASSIC = WOW_PROJECT_WRATH_CLASSIC or 4
local WOW_PROJECT_CATACLYSM_CLASSIC = WOW_PROJECT_CATACLYSM_CLASSIC or 5
local WOW_PROJECT_MISTS_CLASSIC = WOW_PROJECT_MISTS_CLASSIC or 6

local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

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
    _hbd = nil,
}

-- Unique pin ID counter for registry keys.
local pinIdCounter = 0

local function genId()
    pinIdCounter = pinIdCounter + 1
    return "RGXWorldMap_Pin_" .. pinIdCounter
end

--=============================================================================
-- Coordinate adapter — isolates HereBeDragons zone data behind one seam.
--=============================================================================

-- Lazy-load HereBeDragons-2.0 if available (Classic fallbacks).
local function loadHBD()
    if WorldMap._hbd ~= nil then return WorldMap._hbd end
    WorldMap._hbd = false
    if LibStub then
        local ok, hbd = pcall(LibStub, "HereBeDragons-2.0")
        if ok and hbd then
            WorldMap._hbd = hbd
        end
    end
    return WorldMap._hbd
end

-- Get the active coordinate adapter (C_Map first, HBD fallback).
function WorldMap:GetCoordsAdapter()
    if self._coordsAdapter then return self._coordsAdapter end

    local adapter = {}

    -- C_Map path — Retail and Mists+ Classic have full C_Map coverage.
    -- Zone-data isolation: we wrap each C_Map call so consumers never
    -- need to know whether HBD is present.
    function adapter.GetPlayerWorldPosition()
        if C_Map and C_Map.GetPlayerInfoInWorldMap then
            local r = C_Map.GetPlayerInfoInWorldMap()
            if r and r.position then
                local x, y = r.position:GetXY()
                return x or 0, y or 0, r.instanceID or 0
            end
        end
        local hbd = loadHBD()
        if hbd and hbd.GetPlayerWorldPosition then
            return hbd:GetPlayerWorldPosition()
        end
        return nil, nil, nil
    end

    function adapter.GetPlayerZone()
        if C_Map and C_Map.GetBestMapForUnit then
            local mapID = C_Map.GetBestMapForUnit("player")
            if mapID then return mapID end
        end
        local hbd = loadHBD()
        if hbd and hbd.GetPlayerZone then
            return hbd:GetPlayerZone()
        end
        return nil
    end

    function adapter.GetZoneSize(mapID)
        local hbd = loadHBD()
        if hbd and hbd.GetZoneSize then
            return hbd:GetZoneSize(mapID)
        end
        -- C_Map does not expose zone width/height directly; HBD is the
        -- zone-data source of record. Without HBD we cannot resolve it.
        return nil, nil
    end

    function adapter.GetWorldCoordinatesFromZone(zoneX, zoneY, mapID, floor)
        -- C_Map.GetWorldPosFromMapPos takes a UiMapPoint; construct from floats.
        if C_Map and C_Map.GetWorldPosFromMapPos and uiMapPoint then
            local point = uiMapPoint(zoneX / 100, zoneY / 100)
            local pos = C_Map.GetWorldPosFromMapPos(mapID, point)
            if pos then
                return pos:GetXYZ()
            end
        end
        local hbd = loadHBD()
        if hbd and hbd.GetWorldCoordinatesFromZone then
            return hbd:GetWorldCoordinatesFromZone(zoneX, zoneY, mapID, floor)
        end
        return nil, nil, nil
    end

    function adapter.GetZoneCoordinatesFromWorld(worldX, worldY, mapID)
        if C_Map and C_Map.GetMapPosFromWorldPos then
            local pos = C_Map.GetMapPosFromWorldPos(mapID, worldX, worldY)
            if pos then
                local x, y = pos:GetXY()
                return x * 100, y * 100
            end
        end
        local hbd = loadHBD()
        if hbd and hbd.GetZoneCoordinatesFromWorld then
            return hbd:GetZoneCoordinatesFromWorld(worldX, worldY, mapID)
        end
        return nil, nil
    end

    function adapter.GetWorldVector(instance, x1, y1, x2, y2)
        local hbd = loadHBD()
        if hbd and hbd.GetWorldVector then
            return hbd:GetWorldVector(instance, x1, y1, x2, y2)
        end
        -- Compute from raw distance formula as a last resort.
        if x1 and y1 and x2 and y2 then
            local dx, dy = x2 - x1, y2 - y1
            local dist = math.sqrt(dx * dx + dy * dy)
            local angle = math.atan2(dy, dx)
            return angle, dist
        end
        return nil, nil
    end

    function adapter.GetWorldDistance(instance, x1, y1, x2, y2)
        local hbd = loadHBD()
        if hbd and hbd.GetWorldDistance then
            return hbd:GetWorldDistance(instance, x1, y1, x2, y2)
        end
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
-- Mirrors HBD-Pins:AddWorldMapIconMap signature adapted for 1:1 porting.
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

function WorldMap:GetZoneCoordinatesFromWorld(worldX, worldY, mapID)
    return self:GetCoordsAdapter().GetZoneCoordinatesFromWorld(worldX, worldY, mapID)
end

function WorldMap:GetWorldVector(instance, x1, y1, x2, y2)
    return self:GetCoordsAdapter().GetWorldVector(instance, x1, y1, x2, y2)
end

function WorldMap:GetWorldDistance(instance, x1, y1, x2, y2)
    return self:GetCoordsAdapter().GetWorldDistance(instance, x1, y1, x2, y2)
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
