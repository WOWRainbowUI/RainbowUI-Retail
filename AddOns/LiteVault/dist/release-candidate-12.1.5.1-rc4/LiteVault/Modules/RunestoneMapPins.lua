local _, lv = ...
local L = lv.L

local EVERSONG_WOODS_MAP_ID = 2395
local PIN_TEMPLATE = "LiteVaultRunestoneMapPinTemplate"

local providerFrame = CreateFrame("Frame")
local dataProvider
local activePins = {}
local inactivePins = {}
local pendingRefresh = false

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

local function IsCombatLockedDown()
    return InCombatLockdown and InCombatLockdown()
end

local function GetWorldMapCanvas()
    if not WorldMapFrame or not WorldMapFrame.ScrollContainer then
        return nil
    end
    return WorldMapFrame.ScrollContainer.Child or WorldMapFrame.ScrollContainer
end

local function ReleasePin(pin)
    if not pin then return end

    if GameTooltip and GameTooltip:GetOwner() == pin then
        GameTooltip:Hide()
    end
    pin.location = nil
    pin:Hide()
    pin:ClearAllPoints()
    inactivePins[#inactivePins + 1] = pin
end

local function RemoveAllPins()
    while #activePins > 0 do
        ReleasePin(tremove(activePins))
    end
end

local function PositionPin(pin, parent, location)
    if not pin or not parent or not location then return end

    local width = parent:GetWidth() or 0
    local height = parent:GetHeight() or 0
    if width <= 0 or height <= 0 then
        return false
    end

    pin:ClearAllPoints()
    pin:SetPoint("CENTER", parent, "TOPLEFT", ((location.x or 0) / 100) * width, -((location.y or 0) / 100) * height)
    return true
end

local function AcquireOverlayPin(parent, location)
    local pin = tremove(inactivePins)
    if not pin then
        pin = CreateFrame("Frame", nil, parent, PIN_TEMPLATE)
        if pin.OnLoad then
            pin:OnLoad()
        end
    elseif pin:GetParent() ~= parent then
        pin:SetParent(parent)
    end

    pin:OnAcquired(location)
    if PositionPin(pin, parent, location) then
        pin:Show()
    else
        pin:Hide()
    end

    activePins[#activePins + 1] = pin
    return pin
end

LiteVaultRunestoneMapPinMixin = {}

function LiteVaultRunestoneMapPinMixin:OnLoad()
    if self.LiteVaultInitialized then
        return
    end
    self.LiteVaultInitialized = true

    self:SetSize(28, 28)
    self:EnableMouse(true)
    self.mouseButtonPassthrough = nil
    self.MouseButtonPassthrough = nil

    self:SetScript("OnEnter", self.OnMouseEnter)
    self:SetScript("OnLeave", self.OnMouseLeave)
    self:SetScript("OnMouseDown", self.OnMouseDown)
    self:SetScript("OnMouseUp", function(pin, button)
        pin:OnMouseUp(button)
        if button == "LeftButton" then
            pin:OnClick(button)
        end
    end)

    self.icon = self:CreateTexture(nil, "OVERLAY")
    self.icon:SetAllPoints()
    self.icon:SetAtlas("poi-saltherilssoiree", true)
end

function LiteVaultRunestoneMapPinMixin:OnAcquired(location)
    self.location = location
    self:SetFrameLevel(9000)
    self:Raise()
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

function LiteVaultRunestoneMapPinMixin:OnMouseDown(_button)
end

function LiteVaultRunestoneMapPinMixin:OnMouseUp(_button)
end

function LiteVaultRunestoneMapPinMixin:OnClick(button)
    if button and button ~= "LeftButton" then
        return
    end
    SetRunestoneWaypoint(self.location)
end

local function InstallDataProvider()
    if dataProvider or not WorldMapFrame or not MapCanvasDataProviderMixin then return end

    dataProvider = CreateFromMixins(MapCanvasDataProviderMixin)
    dataProvider.mouseButtonPassthrough = nil
    dataProvider.MouseButtonPassthrough = nil

    function dataProvider:RemoveAllData()
        RemoveAllPins()
    end

    function dataProvider:RefreshAllData()
        if IsCombatLockedDown() then
            pendingRefresh = true
            return
        end

        pendingRefresh = false
        self:RemoveAllData()

        local map = self.GetMap and self:GetMap()
        local canvas = GetWorldMapCanvas()
        if LiteVaultDB and LiteVaultDB.disableRunestoneMapPins then
            return
        end
        if not map or not map.GetMapID or map:GetMapID() ~= EVERSONG_WOODS_MAP_ID or not canvas then
            return
        end

        for _, location in ipairs(GetRunestoneEntries()) do
            AcquireOverlayPin(canvas, location)
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
providerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
providerFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_REGEN_ENABLED" then
        if pendingRefresh then
            pendingRefresh = false
            if WorldMapFrame and WorldMapFrame:IsShown() then
                RefreshWorldMapDataProvider()
            end
        end
        return
    end

    if event == "ADDON_LOADED" and arg1 ~= "Blizzard_WorldMap" then
        return
    end

    InstallDataProvider()
    InstallRefreshHooks()
    RefreshWorldMapDataProviderSoon()
end)
