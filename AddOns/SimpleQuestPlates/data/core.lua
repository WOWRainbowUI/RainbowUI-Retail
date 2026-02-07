--=====================================================================================
-- RGX | Simple Quest Plates! - core.lua
-- Version: 1.6.4
-- Author: DonnieDice
-- Description: Main initialization and core functions
--=====================================================================================

-- Get addon namespace
local addonName, SQP = ...
_G.SQP = SQP
SQP.L = SQP.L or {}
SQP.VERSION = "1.6.4"

-- Version detection
local tocversion = select(4, GetBuildInfo())
SQP.isRetail = tocversion >= 110000
SQP.isCata = tocversion >= 40400 and tocversion < 50000
SQP.isWrath = tocversion >= 30400 and tocversion < 40000
SQP.isVanilla = tocversion < 20000
SQP.isClassic = tocversion < 110000  -- Any non-retail version
SQP.isMoP = tocversion >= 50400 and tocversion < 60000

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
local DEFAULTS = {
    enabled = true,
    scale = 1.0,
    offsetX = 40,
    offsetY = 0,
    anchor = "RIGHT",
    relativeTo = "LEFT",
    debug = false,
    -- Font settings
    fontSize = 12,
    fontFamily = "Fonts\\FRIZQT__.TTF",  -- Default WoW font
    fontOutline = "",
    outlineWidth = 1,
    -- Color settings
    killColor = {1, 0.82, 0},      -- Yellow/gold
    itemColor = {0.2, 1, 0.2},     -- Green
    percentColor = {0.2, 1, 1},    -- Cyan
    customColors = false,
    -- Icon tinting
    iconTint = false,
    iconTintColor = {1, 1, 1},      -- White (no tint by default)
    -- Text outline color
    outlineColor = {0, 0, 0},        -- Black outline by default
    -- Additional settings
    showMessages = true,
    hideInCombat = false,
    hideInInstance = false
}

-- Load settings from saved variables
function SQP:LoadSettings()
    -- Ensure we're using the global saved variable
    if not _G.SQPSettings then
        _G.SQPSettings = {}
    end
    
    -- Deep copy defaults for nested tables
    local function deepCopy(orig)
        local copy
        if type(orig) == 'table' then
            copy = {}
            for k, v in pairs(orig) do
                copy[k] = deepCopy(v)
            end
        else
            copy = orig
        end
        return copy
    end
    
    -- Apply defaults for missing values
    for key, value in pairs(DEFAULTS) do
        if _G.SQPSettings[key] == nil then
            _G.SQPSettings[key] = deepCopy(value)
        elseif type(value) == "table" and type(_G.SQPSettings[key]) == "table" then
            -- Ensure color tables have all required fields
            for k, v in pairs(value) do
                if _G.SQPSettings[key][k] == nil then
                    _G.SQPSettings[key][k] = v
                end
            end
        end
    end
    
    -- Create a reference for easier access
    SQPSettings = _G.SQPSettings
end

-- Save settings (automatic via SavedVariables)
function SQP:SaveSettings()
    -- Settings are automatically saved by WoW
end

-- Helper function to update a setting value
function SQP:SetSetting(key, value)
    _G.SQPSettings[key] = value
    SQPSettings[key] = value
end

-- Reset settings to defaults
function SQP:ResetSettings()
    -- Deep copy defaults for nested tables
    local function deepCopy(orig)
        local copy
        if type(orig) == 'table' then
            copy = {}
            for k, v in pairs(orig) do
                copy[k] = deepCopy(v)
            end
        else
            copy = orig
        end
        return copy
    end
    
    _G.SQPSettings = {}
    for key, value in pairs(DEFAULTS) do
        _G.SQPSettings[key] = deepCopy(value)
    end
    SQPSettings = _G.SQPSettings
    self:PrintMessage(self.L["CMD_RESET"])
    self:RefreshAllNameplates()
    
    -- Refresh the options panel if it exists
    if self.optionsPanel and self.optionsPanel:IsShown() then
        self:RefreshOptionsPanel()
    end
end

-- Refresh all options panel UI elements
function SQP:RefreshOptionsPanel()
    -- Store references to all checkboxes and controls during creation
    if not self.optionControls then 
        return 
    end
    
    -- Update all controls based on type
    for settingName, control in pairs(self.optionControls) do
        if type(control) == "table" and control.SetChecked then
            -- Handle checkboxes
            if settingName == "showMessages" then
                control:SetChecked(SQPSettings[settingName] ~= false)
            else
                control:SetChecked(SQPSettings[settingName])
            end
        elseif type(control) == "table" and control.SetValue then
            -- Handle sliders
            control:SetValue(SQPSettings[settingName])
        elseif type(control) == "table" and control.SetColorTexture then
            -- Handle color swatches
            local colorSetting = settingName:gsub("Swatch", "")
            local color = SQPSettings[colorSetting]
            if color then
                control:SetColorTexture(unpack(color))
            end
        elseif type(control) == "function" then
            -- Handle update functions
            control()
        elseif settingName == "fontFamily" and control.SetText then
            -- Handle dropdown menus
            UIDropDownMenu_SetText(control, "Default")
        end
    end
    
    -- Update anchor buttons if the function exists
    if self.optionControls.anchorUpdateFunc then
        self.optionControls.anchorUpdateFunc()
    end
    
    -- Update preview if visible
    if self.UpdatePreview then
        self:UpdatePreview()
    end
end

-- Print formatted message to chat
function SQP:PrintMessage(message)
    if message then
        print(string.format("%s - [%s] %s", ADDON_ICON, ADDON_PREFIX, message))
    end
end

-- Enable addon
function SQP:Enable()
    _G.SQPSettings.enabled = true
    SQPSettings.enabled = true
    self:SaveSettings()
    self:PrintMessage(self.L["CMD_ENABLED"])
    self:RefreshAllNameplates()
end

-- Disable addon
function SQP:Disable()
    _G.SQPSettings.enabled = false
    SQPSettings.enabled = false
    self:SaveSettings()
    self:PrintMessage(self.L["CMD_DISABLED"])
    
    -- Hide all quest plates
    for plate, frame in pairs(self.QuestPlates or {}) do
        frame:Hide()
    end
end

-- Wrapper functions for compatibility
function SQP:EnableAddon()
    self:Enable()
end

function SQP:DisableAddon()
    self:Disable()
end

-- Public API
_G["SimpleQuestPlates"] = SQP