local _, lv = ...
local L = lv.L

local EVERSONG_WOODS_MAP_ID = 2395
local PIN_TEMPLATE = "LiteVaultRunestoneMapPinTemplate"

local providerFrame = CreateFrame("Frame")
local dataProvider

local function GetRunestoneEntries()
    return lv.RUNESTONE_RUSH_ENTRIES or {}
end

local function T(key, fallback)
    local value = L and L[key]
    if not value or value == key then
        return fallback
    end
    return value
end

local function SetRunestoneWaypoint(location)
    if not location then return end

    local x = (location.x or 0) / 100
    local y = (location.y or 0) / 100
    local title = location.name or T("LABEL_RUNESTONE", "Runestone")

    if _G.TomTom and _G.TomTom.AddWaypoint then
        _G.TomTom:AddWaypoint(location.mapID, x, y, {
            title = title,
            persistent = false,
            minimap = true,
            world = true,
        })
        return
    end

    if C_Map and C_Map.SetUserWaypoint and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        local point = UiMapPoint.CreateFromCoordinates(location.mapID, x, y)
        if point then
            C_Map.SetUserWaypoint(point)
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
    end
end

LiteVaultRunestoneMapPinMixin = CreateFromMixins(MapCanvasPinMixin or {})

function LiteVaultRunestoneMapPinMixin:OnLoad()
    if MapCanvasPinMixin and not self.SetPosition then
        Mixin(self, MapCanvasPinMixin)
    end
    if self.UseFrameLevelType then
        self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
    end
    if self.SetScalingLimits then
        self:SetScalingLimits(1, 1.0, 1.25)
    end
    self:SetSize(28, 28)
    self:EnableMouse(true)

    self.icon = self:CreateTexture(nil, "OVERLAY")
    self.icon:SetAllPoints()
    self.icon:SetAtlas("poi-saltherilssoiree", true)
end

function LiteVaultRunestoneMapPinMixin:OnAcquired(location)
    self.location = location
    if self.SetPosition then
        self:SetPosition((location.x or 0) / 100, (location.y or 0) / 100)
    end
    self:SetFrameLevel(9000)
    self:Raise()
    self:Show()
end

function LiteVaultRunestoneMapPinMixin:OnMouseEnter()
    local location = self.location
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(location and location.name or T("LABEL_RUNESTONE", "Runestone"), 1, 0.82, 0)
    if location then
        GameTooltip:AddLine(string.format("%.2f, %.2f", location.x, location.y), 1, 1, 1)
        if location.boss and location.boss ~= "" then
            GameTooltip:AddLine(string.format(T("LABEL_DEFENSE_FMT", "Defense: %s"), location.boss), 0.8, 0.8, 0.8, true)
        end
    end
    GameTooltip:AddLine(T("TOOLTIP_RUNESTONE_EVENT", "Fortify the Runestones"), 0.72, 0.52, 1)
    GameTooltip:AddLine(T("TOOLTIP_RUNESTONE_SET_WAYPOINT", "Click to set waypoint."), 0.2, 1, 0.2)
    GameTooltip:Show()
end

function LiteVaultRunestoneMapPinMixin:OnMouseLeave()
    GameTooltip:Hide()
end

function LiteVaultRunestoneMapPinMixin:OnMouseDown()
end

function LiteVaultRunestoneMapPinMixin:OnMouseUp()
end

function LiteVaultRunestoneMapPinMixin:OnClick()
    SetRunestoneWaypoint(self.location)
end

local function InstallDataProvider()
    if dataProvider or not WorldMapFrame or not MapCanvasDataProviderMixin then return end

    dataProvider = CreateFromMixins(MapCanvasDataProviderMixin)

    function dataProvider:RemoveAllData()
        local map = self.GetMap and self:GetMap()
        if map and map.RemoveAllPinsByTemplate then
            map:RemoveAllPinsByTemplate(PIN_TEMPLATE)
        end
    end

    function dataProvider:RefreshAllData()
        self:RemoveAllData()

        local map = self.GetMap and self:GetMap()
        if LiteVaultDB and LiteVaultDB.disableRunestoneMapPins then
            return
        end
        if not map or not map.GetMapID or map:GetMapID() ~= EVERSONG_WOODS_MAP_ID or not map.AcquirePin then
            return
        end

        for _, location in ipairs(GetRunestoneEntries()) do
            map:AcquirePin(PIN_TEMPLATE, location)
        end
    end

    WorldMapFrame:AddDataProvider(dataProvider)
    lv.WorldMapDataProvider = dataProvider
end

local function RefreshWorldMapDataProvider()
    if lv.WorldMapDataProvider then
        lv.WorldMapDataProvider:RefreshAllData()
    end
end
lv.RefreshRunestoneMapPins = RefreshWorldMapDataProvider

local function RefreshWorldMapDataProviderSoon()
    RefreshWorldMapDataProvider()
    if C_Timer then
        C_Timer.After(0, RefreshWorldMapDataProvider)
        C_Timer.After(0.15, RefreshWorldMapDataProvider)
    end
end

local function InstallRefreshHooks()
    if not WorldMapFrame or WorldMapFrame.LiteVaultRunestoneRefreshHooked then return end
    WorldMapFrame.LiteVaultRunestoneRefreshHooked = true

    WorldMapFrame:HookScript("OnShow", function()
        RefreshWorldMapDataProviderSoon()
    end)
    if hooksecurefunc and type(WorldMapFrame.OnMapChanged) == "function" then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            RefreshWorldMapDataProviderSoon()
        end)
    end
    if WorldMapFrame.ScrollContainer and not WorldMapFrame.ScrollContainer.LiteVaultRunestoneRefreshHooked then
        WorldMapFrame.ScrollContainer.LiteVaultRunestoneRefreshHooked = true
        WorldMapFrame.ScrollContainer:HookScript("OnSizeChanged", function()
            RefreshWorldMapDataProviderSoon()
        end)
    end
end

providerFrame:RegisterEvent("PLAYER_LOGIN")
providerFrame:RegisterEvent("ADDON_LOADED")
providerFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 ~= "Blizzard_WorldMap" then
        return
    end

    InstallDataProvider()
    InstallRefreshHooks()
    RefreshWorldMapDataProviderSoon()
end)
