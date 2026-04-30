--====================================================================================
-- RGX | Simple Quest Plates! - core.lua

-- Author: DonnieDice
-- Description: Main addon initialization and settings management.
--====================================================================================

local addonName, SQP = ...

local RGX = assert(_G.RGXFramework, "SQP: RGX-Framework not loaded")

-- Cache frequently used globals
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
local UnitAffectingCombat = UnitAffectingCombat
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

SQP.VERSION = "2.0.16" -- Addon version (also in TOC file)
SQP.NAME = GetAddOnMetadataCompat(addonName, "Title") or addonName or "SimpleQuestPlates"
SQP.AUTHOR = GetAddOnMetadataCompat(addonName, "Author") or "DonnieDice"
SQP.LOCALE = GetLocale()
SQP.ICON_TEXTURE = GetAddOnMetadataCompat(addonName, "IconTexture")
    or ("Interface\\AddOns\\" .. (addonName or "SimpleQuestPlates") .. "\\media\\icon")

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
    offsetX = 0,
    offsetY = 3,
    anchor = "RIGHT",
    relativeTo = "LEFT",
    hideInCombat = false,
    hideInInstance = false,
    minimapIconEnabled = false, -- 更改預設值
    minimapAngle = 220,
    itemColor = {0.2, 1, 0.2},   -- Green
    killColor = {1, 0.82, 0},    -- Gold
    percentColor = {0.2, 1, 1},  -- Cyan
    killColorNameplate = false,
    killNameplateColor = {1, 0.82, 0},
    lootColorNameplate = false,
    lootNameplateColor = {0.2, 1, 0.2},
    percentColorNameplate = false,
    percentNameplateColor = {0.2, 1, 1},
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
    -- Per-type font: kill
    killFontSize = 12,
    killFontFamily = "Fonts\\FRIZQT__.TTF",
    killFontOutline = "",
    killOutlineWidth = 0,
    killOutlineAlpha = 0,
    killOutlineColor = {0, 0, 0},
    -- Per-type font: loot
    lootFontSize = 12,
    lootFontFamily = "Fonts\\FRIZQT__.TTF",
    lootFontOutline = "",
    lootOutlineWidth = 0,
    lootOutlineAlpha = 0,
    lootOutlineColor = {0, 0, 0},
    -- Per-type font: percent
    percentFontSize = 8,
    percentFontFamily = "Fonts\\FRIZQT__.TTF",
    percentFontOutline = "",
    percentOutlineWidth = 0,
    percentOutlineAlpha = 0,
    percentOutlineColor = {0, 0, 0},
    animateQuestIcon = false,
    animateQuestIcons = true,
    useGlobalAnimationSettings = false,
    globalAnimationEnabled = true,
    animationCombatMode = "always", -- always | combat | outofcombat
    globalAnimationIntensity = 100,
    killAnimationIntensity = 100,
    lootAnimationIntensity = 100,
    percentAnimationIntensity = 100,
    showIconBackground = true, -- Legacy shared display style toggle
    killShowIconBackground = true,
    lootShowIconBackground = true,
    percentShowIconBackground = true,
    killIconOffsetX = 2,
    killIconOffsetY = 15,
    lootIconOffsetX = -38,
    lootIconOffsetY = 16,
    percentIconOffsetX = 18,
    percentIconOffsetY = 0,
    killIconSize = 14,
    lootIconSize = 14,
    percentIconSize = 8,
    iconTintMain = false,
    iconTintMainColor = {1, 1, 1},
    iconTintQuest = false,
    iconTintQuestColor = {1, 1, 1},
    -- Per-type main icon (jellybean) animation
    killAnimateMain = false,
    lootAnimateMain = false,
    percentAnimateMain = false,
    -- Per-type main icon (jellybean) tinting
    killTintMain = false,
    killTintMainColor = {1, 1, 1},
    lootTintMain = false,
    lootTintMainColor = {1, 1, 1},
    percentTintMain = false,
    percentTintMainColor = {1, 1, 1},
    -- Per-type mini icon tinting (kill/loot task icons)
    killTintIcon = false,
    killTintIconColor = {1, 1, 1},
    lootTintIcon = false,
    lootTintIconColor = {1, 1, 1},
    percentTintIcon = false,
    percentTintIconColor = {1, 1, 1},
    debug = false,
}

SQP.defaultMinimapAngle = 220

-- Animation setting helpers
function SQP:IsAnimationCombatAllowed()
    local settings = SQPSettings or self.DEFAULTS or {}
    local mode = settings.animationCombatMode

    if mode ~= "always" and mode ~= "combat" and mode ~= "outofcombat" then
        mode = "always"
    end

    if mode == "always" then
        return true
    end

    local inCombat = UnitAffectingCombat and UnitAffectingCombat("player")
    if mode == "combat" then
        return inCombat and true or false
    end
    return not inCombat
end

function SQP:IsAnimationEnabled(typeKey, isTaskIcon)
    local settings = SQPSettings or self.DEFAULTS or {}
    local baseEnabled = false

    if settings.useGlobalAnimationSettings == true then
        baseEnabled = settings.globalAnimationEnabled ~= false
    elseif isTaskIcon then
        baseEnabled = settings.animateQuestIcons == true
    elseif typeKey and typeKey ~= "" then
        baseEnabled = settings[typeKey .. "AnimateMain"] == true
    end

    if not baseEnabled then
        return false
    end

    return self:IsAnimationCombatAllowed()
end

function SQP:GetAnimationIntensity(typeKey)
    local settings = SQPSettings or self.DEFAULTS or {}
    local intensity

    if settings.useGlobalAnimationSettings == true then
        intensity = settings.globalAnimationIntensity
    elseif typeKey and typeKey ~= "" then
        intensity = settings[typeKey .. "AnimationIntensity"]
    end

    if intensity == nil then
        intensity = settings.globalAnimationIntensity
    end

    intensity = tonumber(intensity) or 100
    if intensity < 25 then intensity = 25 end
    if intensity > 200 then intensity = 200 end
    return intensity
end

function SQP:GetAnimationDuration(typeKey, isMain)
    local baseDuration = isMain and 0.5 or 0.6
    local intensity = self:GetAnimationIntensity(typeKey)
    local duration = baseDuration * (100 / intensity)
    if duration < 0.15 then duration = 0.15 end
    if duration > 2 then duration = 2 end
    return duration
end

function SQP:ApplyPulseDuration(animationGroup, duration)
    if not animationGroup or not duration then return end

    if animationGroup._fadeOut and animationGroup._fadeOut.SetDuration then
        animationGroup._fadeOut:SetDuration(duration)
    end
    if animationGroup._fadeIn and animationGroup._fadeIn.SetDuration then
        animationGroup._fadeIn:SetDuration(duration)
    end
end

-- Determine effective outline settings for a quest type (or global if typeKey is nil)
function SQP:GetOutlineInfo(typeKey)
    local settings = SQPSettings or self.DEFAULTS or {}
    local fontOutline, outlineWidth
    if typeKey then
        fontOutline  = settings[typeKey .. "FontOutline"]
        outlineWidth = settings[typeKey .. "OutlineWidth"]
    end
    if fontOutline  == nil then fontOutline  = settings.fontOutline  or "" end
    if outlineWidth == nil then outlineWidth = settings.outlineWidth or 0  end
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
    if outlineWidth < 0 then outlineWidth = 0 end
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
SQP.PANEL_NAME = format("|TInterface\\AddOns\\%s\\media\\logo.tga:16:16:0:0|t |cff58be81S|r|cffffffffimple|r |cff58be81Q|r|cffffffffuest|r |cff58be81P|r|cfffffffflates|r|cff58be81!|r", addonName)
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
        local prefix = RGX and RGX.CreateChatPrefix and RGX:CreateChatPrefix({
            icon = self.ICON_TEXTURE,
            tag = "SQP",
            tagColor = "58be81",
            iconSize = 16,
        }) or format("|T%s:16:16:0:0|t - |cffffffff[|r|cff58be81SQP|r|cffffffff]|r", self.ICON_TEXTURE or "")
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

    -- Migrate global font settings to per-type (must run before ApplyDefaults)
    local function migrateFont(tk, sizeDefault)
        if SQPSettings[tk.."FontSize"]    == nil then SQPSettings[tk.."FontSize"]    = SQPSettings.fontSize    or sizeDefault end
        if SQPSettings[tk.."FontFamily"]  == nil then SQPSettings[tk.."FontFamily"]  = SQPSettings.fontFamily  or "Fonts\\FRIZQT__.TTF" end
        if SQPSettings[tk.."FontOutline"] == nil then SQPSettings[tk.."FontOutline"] = SQPSettings.fontOutline or "" end
        if SQPSettings[tk.."OutlineWidth"]== nil then SQPSettings[tk.."OutlineWidth"]= SQPSettings.outlineWidth or 0 end
        if SQPSettings[tk.."OutlineAlpha"]== nil then SQPSettings[tk.."OutlineAlpha"]= SQPSettings.outlineAlpha or 0 end
        if SQPSettings[tk.."OutlineColor"]== nil then
            local oc = SQPSettings.outlineColor
            SQPSettings[tk.."OutlineColor"] = oc and {oc[1], oc[2], oc[3]} or {0, 0, 0}
        end
    end
    migrateFont("kill",    12)
    migrateFont("loot",    12)
    migrateFont("percent",  8)
    -- percentIconSize -> percentFontSize migration
    if SQPSettings.percentFontSize == nil and SQPSettings.percentIconSize then
        SQPSettings.percentFontSize = SQPSettings.percentIconSize
    end

    -- Migrate shared display style to per-type display styles
    -- 1.9.3 behavior: default to Icon mode per tab (do not inherit old shared Text mode)
    local legacyShowIconBackground = SQPSettings.showIconBackground
    if SQPSettings.killShowIconBackground == nil then
        SQPSettings.killShowIconBackground = true
    end
    if SQPSettings.lootShowIconBackground == nil then
        SQPSettings.lootShowIconBackground = true
    end
    if SQPSettings.percentShowIconBackground == nil then
        SQPSettings.percentShowIconBackground = true
    end

    -- One-time normalization for installs that inherited old shared style/toggles.
    -- If everything is uniformly off, treat it as migrated legacy state and reset to defaults.
    if not SQPSettings.migratedDefaults193 then
        local allStyleOff =
            SQPSettings.killShowIconBackground == false and
            SQPSettings.lootShowIconBackground == false and
            SQPSettings.percentShowIconBackground == false
        local allShowOff =
            SQPSettings.showKillIcon == false and
            SQPSettings.showLootIcon == false and
            SQPSettings.showPercentIcon == false

        if allStyleOff or legacyShowIconBackground == false then
            SQPSettings.killShowIconBackground = true
            SQPSettings.lootShowIconBackground = true
            SQPSettings.percentShowIconBackground = true
        end
        if allShowOff then
            SQPSettings.showKillIcon = true
            SQPSettings.showLootIcon = true
            SQPSettings.showPercentIcon = true
        end
        SQPSettings.migratedDefaults193 = true
    end

    -- Copy defaults if new or missing
    self:ApplyDefaults(SQPSettings)

    -- Normalize animation combat mode
    local animationMode = SQPSettings.animationCombatMode
    if animationMode ~= "always" and animationMode ~= "combat" and animationMode ~= "outofcombat" then
        SQPSettings.animationCombatMode = "always"
    end

    -- Normalize boolean settings (older clients/checkbuttons may store 1/nil or strings)
    for key, defaultValue in pairs(self.DEFAULTS) do
        if type(defaultValue) == "boolean" then
            local currentValue = SQPSettings[key]
            if currentValue == nil then
                SQPSettings[key] = defaultValue
            elseif type(currentValue) ~= "boolean" then
                if type(currentValue) == "number" then
                    SQPSettings[key] = currentValue ~= 0
                elseif type(currentValue) == "string" then
                    local lowered = string.lower(currentValue)
                    if lowered == "true" or lowered == "1" then
                        SQPSettings[key] = true
                    elseif lowered == "false" or lowered == "0" or lowered == "" then
                        SQPSettings[key] = false
                    else
                        SQPSettings[key] = defaultValue
                    end
                else
                    SQPSettings[key] = currentValue and true or false
                end
            end
        end
    end

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

    -- Persist booleans as explicit true/false (never nil), so unchecked checkboxes
    -- cannot silently revert to a default true on SaveSettings().
    local defaultValue = self.DEFAULTS and self.DEFAULTS[key]
    if type(defaultValue) == "boolean" then
        value = value and true or false
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

function SQP:SetupMinimapButton()
--[[
    local MM = RGX and RGX:GetMinimap() or nil
    if not MM then return end

    self.minimapBtn = MM:Create({
        name         = "SQP_MinimapButton",
        icon         = self.ICON_TEXTURE or "",
        defaultAngle = self.defaultMinimapAngle,
        storage      = SQPSettings,
        angleKey     = "minimapAngle",
        enabledKey   = "minimapIconEnabled",
        tooltip = {
            title = format("|T%s:18:18:0:0|t |cff58be81S|r|cffffffffimple |cff58be81Q|r|cffffffffuest |cff58be81P|r|cfffffffflates|cff58be81!|r", self.ICON_TEXTURE or ""),
            lines = {
                { left = "|cff58be81Left-Click|r",       right = "Open options" },
                { left = "|cff4ecdc4Drag|r",             right = "Move around minimap" },
                { left = "|cffe74c3cCtrl+Right-Click|r", right = "Hide minimap icon" },
            },
        },
        onLeftClick = function()
            local function openOptions()
                SQP:OpenOptions()
            end
            if C_Timer and type(C_Timer.After) == "function" then
                C_Timer.After(0, openOptions)
            elseif RGX and type(RGX.After) == "function" then
                RGX:After(0, openOptions)
            else
                openOptions()
            end
        end,
        onCtrlRight = function() SQP:ToggleMinimapIcon(false) end,
    })
--]]
end

function SQP:ToggleMinimapIcon(show, silent)
    if not self.minimapBtn then return end
    self.minimapBtn:SetVisible(show)
    if not silent then
        if show then
            self:PrintMessage("Minimap icon shown.")
        else
            self:PrintMessage("Minimap icon hidden. Use |cfffff569/sqp icon on|r to show it again.")
        end
    end
end

function SQP:ApplyMinimapVisibility()
    if not self.minimapBtn then
        self:SetupMinimapButton()
    end
    if self.minimapBtn then
        self.minimapBtn:SetVisible(self.minimapBtn:GetEnabled())
    end
end

function SQP:InitializeFrameworkUI()
    if self._frameworkUIInitialized then
        return
    end

    local rgx = _G.RGXFramework
    if not rgx then
        return
    end

    self:ApplyMinimapVisibility()

    self._frameworkUIInitialized = true
end

-- Toggle options panel
function SQP:OpenOptions()
    if not self.optionsPanel then
        self:CreateOptionsPanel()
    end

    if self.optionsPanel and self.optionsPanel.Open then
        self.optionsPanel:Open()
    elseif self.optionsPanel and self.optionsPanel.Show then
        self.optionsPanel:Show()
    end
end

-- Refresh all nameplates to apply new settings
function SQP:RefreshAllNameplates()
    -- This function will be defined in nameplates.lua
end
