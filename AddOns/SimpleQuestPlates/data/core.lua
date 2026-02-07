--====================================================================================
-- RGX | Simple Quest Plates! - core.lua

-- Author: DonnieDice
-- Description: Main addon initialization and settings management.
--====================================================================================

local addonName, SQP = ...

-- Cache frequently used globals
local C_Timer = C_Timer
local pcall = pcall
local tonumber = tonumber
local tinsert = table.insert
local tremove = table.remove
local wipe = wipe
local select = select
local type = type
local next = next
local pairs = pairs
local unpack = unpack
local floor = math.floor
local format = string.format
local strmatch = string.match

-- Lua Globals
local UnitName = UnitName
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsPlayer = UnitIsPlayer
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local GetBuildInfo = GetBuildInfo
local PlaySound = PlaySound
local GetCursorPosition = GetCursorPosition
local GetCurrentMapAreaID = GetCurrentMapAreaID
local IsInInstance = IsInInstance

-- Addon namespace
-- SQP will be initialized by the XML
if not SQP then SQP = {} end

-- Addon metadata
local function GetAddOnMetadataCompat(name, field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(name, field)
    end
    if GetAddOnMetadata then
        return GetAddOnMetadata(name, field)
    end
    if GetAddOnInfo then
        local _, title, notes = GetAddOnInfo(name)
        if field == "Title" then
            return title
        elseif field == "Notes" then
            return notes
        end
    end
    return nil
end

SQP.VERSION = "1.6.12" -- Addon version (also in TOC file)
SQP.NAME = GetAddOnMetadataCompat(addonName, "Title") or addonName or "SimpleQuestPlates"
SQP.AUTHOR = GetAddOnMetadataCompat(addonName, "Author") or "DonnieDice"
SQP.LOCALE = GetLocale()
SQP.ICON_TEXTURE = GetAddOnMetadataCompat(addonName, "IconTexture")
    or ("Interface\\AddOns\\" .. (addonName or "SimpleQuestPlates") .. "\\images\\icon")

do
    local _, _, _, tocversion = GetBuildInfo and GetBuildInfo() or nil
    tocversion = tonumber(tocversion)
    if not tocversion then
        local interfaceString = GetAddOnMetadataCompat(addonName, "Interface")
        if type(interfaceString) == "string" then
            tocversion = tonumber(interfaceString:match("%d+"))
        end
    end
    SQP.tocversion = tocversion or 0
end

-- Default settings
SQP.DEFAULTS = {
    enabled = true,
    scale = 1.0,
    offsetX = 0,
    offsetY = 0,
    anchor = "RIGHT", -- LEFT or RIGHT
    relativeTo = "LEFT", -- ANCHOR_LEFT or ANCHOR_RIGHT
    hideInCombat = false,
    hideInInstance = false,
    itemColor = {0.2, 1, 0.2}, -- Green
    killColor = {1, 0.82, 0}, -- Gold
    percentColor = {0.2, 1, 1}, -- Cyan
    fontOutline = "THICKOUTLINE", -- NONE, THINOUTLINE, THICKOUTLINE, MONOCHROME
    fontSize = 12,
    fontColor = {1, 1, 1}, -- White
    iconTint = false,
    iconTintColor = {1, 1, 1}, -- White
    debug = false,
}

-- Current settings (initialized later)
SQPSettings = SQPSettings or {}

-- Store frames for quest plates
SQP.QuestPlates = {}

-- Store active nameplate IDs
SQP.ActiveNameplates = {}

-- Last saved position of the options panel
SQP.lastPanelPosition = {a1 = "CENTER", a2 = "CENTER", x = 0, y = 0}

-- Sounds
SQP.SOUND_KIT_ID_QUEST_COMPLETE = 816 -- UI_QuestLog_QuestComplete (default sound)
SQP.SOUND_KIT_ID_QUEST_ACCEPT = 815 -- UI_QuestLog_QuestAccepted

-- Constants for UI
SQP.PANEL_WIDTH = 700
SQP.PANEL_HEIGHT = 600
SQP.PANEL_NAME = format("|TInterface\AddOns\%s\images\icon:0|t |cff58be81S|r|cffffffffimple|r |cff58be81Q|r|cffffffffuest|r |cff58be81P|r|cfffffffflates|r|cff58be81!|r", addonName)
SQP.SECTION_COLOR = { r = 0.58, g = 0.79, b = 1, a = 1 } -- RGX Blue
SQP.BACKDROP_DARK = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

-- Compatibility (overridden by compat.lua)
SQP.Compat = {}

-- Error handling
function SQP:ErrorHandler(msg)
    if not msg then return end
    local err = debugstack()
    self:PrintMessage("|cffff0000Error: |r" .. tostring(msg))
    self:PrintMessage("|cffff0000Stack: |r" .. tostring(err))
end

-- Print message to chat frame
function SQP:PrintMessage(msg, level)
    if DEFAULT_CHAT_FRAME then
        local icon = format("|T%s:0|t", self.ICON_TEXTURE or "")
        local prefix = format("%s - |cff58be81[SQP]|r", icon)
        if level and level ~= "" then
            local levelColor = "fffff569"
            if tostring(level) == "DEBUG" then
                levelColor = "ff9d9d9d"
            end
            prefix = prefix .. " |c" .. levelColor .. "[" .. tostring(level) .. "]|r"
        end
        DEFAULT_CHAT_FRAME:AddMessage(format("%s %s", prefix, msg))
    end
end

-- Initialize default settings
function SQP:InitializeSettings()
    SQPSettings = self:GetSavedSettings()
end

-- Backwards-compatible alias used by events.lua
function SQP:LoadSettings()
    self:InitializeSettings()
end

-- Get saved settings or defaults
function SQP:GetSavedSettings()
    if SQPSettings == nil then
        SQPSettings = {}
    end
    
    -- Copy defaults if new or missing
    for k, v in pairs(self.DEFAULTS) do
        if SQPSettings[k] == nil then
            SQPSettings[k] = v
        end
    end
    
    -- Legacy alias for older code paths
    SQPSavedSettings = SQPSettings
    
    return SQPSettings
end

-- Save settings
function SQP:SaveSettings()
    if SQPSettings == nil then
        SQPSettings = {}
    end
    SQPSavedSettings = SQPSettings
end

-- Set a single setting and persist it
function SQP:SetSetting(key, value)
    if not key then return end
    if SQPSettings == nil then
        self:InitializeSettings()
    end
    SQPSettings[key] = value
    self:SaveSettings()
end

-- Reset settings to default
function SQP:ResetSettings()
    SQPSavedSettings = nil
    self:InitializeSettings()
    self:PrintMessage(self.L["SETTINGS_RESET"])
    self:RefreshAllNameplates()
end

-- Enable addon
function SQP:EnableAddon()
    SQPSettings.enabled = true
    self:SaveSettings()
    self:PrintMessage(self.L["ADDON_ENABLED"])
    self:RefreshAllNameplates()
end

-- Disable addon
function SQP:DisableAddon()
    SQPSettings.enabled = false
    self:SaveSettings()
    self:PrintMessage(self.L["ADDON_DISABLED"])
    self:RefreshAllNameplates()
end

-- Toggle options panel
function SQP:OpenOptions()
    if self.optionsPanel and self.optionsPanel.Show then
        self.optionsPanel:Show()
    end
end

-- Refresh all nameplates to apply new settings
function SQP:RefreshAllNameplates()
    -- This function will be defined in nameplates.lua
end
