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

-- Shallow copy table values (nested tables copied one level deep)
local function CloneValue(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        if type(v) == "table" then
            local nested = {}
            for nk, nv in pairs(v) do
                nested[nk] = nv
            end
            copy[k] = nested
        else
            copy[k] = v
        end
    end
    return copy
end

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

SQP.VERSION = "1.8.4" -- Addon version (also in TOC file)
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

-- Default settings (based on tuned in-game values)
SQP.DEFAULTS = {
    enabled = true,
    scale = 1.1,
    offsetX = 12,
    offsetY = 3,
    anchor = "RIGHT",
    relativeTo = "LEFT",
    hideInCombat = false,
    hideInInstance = false,
    itemColor = {0.2, 1, 0.2},   -- Green
    killColor = {1, 0.82, 0},    -- Gold
    percentColor = {0.2, 1, 1},  -- Cyan
    fontOutline = "",            -- No outline by default
    outlineWidth = 0,
    fontSize = 12,
    fontFamily = "Fonts\\FRIZQT__.TTF",
    outlineColor = {0, 0, 0},
    outlineAlpha = 0,
    showMessages = true,
    showKillIcon = true,
    showLootIcon = true,
    showPercentIcon = true,
    animateQuestIcon = false,
    animateQuestIcons = true,
    showIconBackground = true,
    killIconOffsetX = 2,
    killIconOffsetY = 15,
    lootIconOffsetX = -38,
    lootIconOffsetY = 16,
    percentIconOffsetX = -17,
    percentIconOffsetY = 0,
    killIconSize = 14,
    lootIconSize = 14,
    percentIconSize = 8,
    iconTintMain = false,
    iconTintMainColor = {1, 1, 1},
    iconTintQuest = false,
    iconTintQuestColor = {1, 1, 1},
    debug = false,
}

-- Determine effective outline settings
function SQP:GetOutlineInfo()
    local settings = SQPSettings or self.DEFAULTS or {}
    local fontOutline = settings.fontOutline or "OUTLINE"
    local outlineWidth = settings.outlineWidth
    local noOutline = fontOutline == "" or fontOutline == "NONE"
    if noOutline then
        outlineWidth = 0
    elseif not outlineWidth then
        if fontOutline == "THICKOUTLINE" then
            outlineWidth = 3
        elseif fontOutline == "OUTLINE" then
            outlineWidth = 2
        else
            outlineWidth = 1
        end
    end
    if outlineWidth < 0 then
        outlineWidth = 0
    end
    return outlineWidth, fontOutline, noOutline
end

-- Apply default settings to a settings table (does not overwrite existing values)
function SQP:ApplyDefaults(settings)
    for k, v in pairs(self.DEFAULTS) do
        if settings[k] == nil or (type(v) == "table" and type(settings[k]) ~= "table") then
            settings[k] = CloneValue(v)
        end
    end
end

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
    if not msg then return end
    if DEFAULT_CHAT_FRAME then
        local icon = format("|T%s:0|t", self.ICON_TEXTURE or "")
        local prefix = format("%s - |cffffffff[|r|cff58be81SQP|r|cffffffff]|r", icon)
        if level and level ~= "" then
            local levelColor = "fffff569"
            if tostring(level) == "DEBUG" then
                levelColor = "ff9d9d9d"
            end
            prefix = prefix .. " |cffffffff[|r|c" .. levelColor .. tostring(level) .. "|r|cffffffff]|r"
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
    self:ApplyDefaults(SQPSettings)

    -- Migrate legacy tint settings
    if SQPSettings.iconTint ~= nil then
        if SQPSettings.iconTintMain == nil then
            SQPSettings.iconTintMain = SQPSettings.iconTint
        end
        if SQPSettings.iconTintQuest == nil then
            SQPSettings.iconTintQuest = SQPSettings.iconTint
        end
    end
    if type(SQPSettings.iconTintColor) == "table" then
        if SQPSettings.iconTintMainColor == nil then
            SQPSettings.iconTintMainColor = CloneValue(SQPSettings.iconTintColor)
        end
        if SQPSettings.iconTintQuestColor == nil then
            SQPSettings.iconTintQuestColor = CloneValue(SQPSettings.iconTintColor)
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
    self:ApplyDefaults(SQPSettings)
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
    SQPSettings = {}
    self:ApplyDefaults(SQPSettings)
    SQPSavedSettings = SQPSettings
    self:PrintMessage(self.L["SETTINGS_RESET"] or "|cff58be81All settings have been reset to defaults|r")
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
