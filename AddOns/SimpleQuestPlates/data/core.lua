--====================================================================================
-- RGX | Simple Quest Plates! - core.lua

-- Author: DonnieDice
-- Description: Main addon initialization and settings management.
--====================================================================================

local addonName, SQP = ...
local SQPSettings

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

SQP.VERSION = "2.1.8" -- Addon version (also in TOC file)
SQP.NAME = GetAddOnMetadataCompat(addonName, "Title") or addonName or "SimpleQuestPlates"
SQP.AUTHOR = GetAddOnMetadataCompat(addonName, "Author") or "DonnieDice"
SQP.LOCALE = GetLocale()
SQP.ICON_TEXTURE = GetAddOnMetadataCompat(addonName, "IconTexture")
    or ("Interface\\AddOns\\" .. (addonName or "SimpleQuestPlates") .. "\\media\\icon")

do
    local tocversion = tonumber(RGX.interfaceVersion)
    if not tocversion or tocversion <= 0 then
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
    offsetY = 0,
    anchor = "RIGHT",
    relativeTo = "LEFT",
    unifiedNameplates = false,
    chipTexture = "coin",
    hideInCombat = false,
    hideInInstance = false,
    minimapIconEnabled = true,
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
    fontFamily = "Fonts/FRIZQT__.TTF", -- Operator's saved Default profile baseline
    outlineColor = {0, 0, 0},
    outlineAlpha = 0,
    showMessages = true,
    showKillIcon = true,
    showLootIcon = true,
    showPercentIcon = false,
    -- Per-type fonts (kill/loot/percent) inherit the global font settings by
    -- default; per-type keys only exist once a user overrides them on the
    -- Kill / Loot / Percent tabs.
    showQuestMarker = true,          -- Animated quest marker on plate show
    questMarkerSize = 40,
    percentSignSide = "right",       -- right | left
    killIconSide = "left",           -- kill task icon badge side: left | right
    lootIconSide = "left",           -- Operator's saved Default profile baseline
    showTargetGlow = true,           -- (retired: never touch Blizzard's selection highlight)
    syncAnimations = false,
    toastDuration = 1.3,
    toastHeight = 30,          -- play all task/main pulses in phase; new baseline
    animateQuestIcon = false,
    animateQuestIcons = true,
    animateMainIcons = false, -- Global main-icon option; per-type toggles apply when off
    useGlobalAnimationSettings = false,
    globalAnimationEnabled = true,
    animationsEnabled = true,
    killAnimationsEnabled = true,
    lootAnimationsEnabled = true,
    percentAnimationsEnabled = false,
    killEnabled = true,
    lootEnabled = true,
    percentEnabled = true,
    animationCombatMode = "always", -- always | combat | outofcombat
    globalAnimationIntensity = 100,
    killAnimationIntensity = 100,
    lootAnimationIntensity = 100,
    percentAnimationIntensity = 100,
    showIconBackground = true, -- Legacy shared display style toggle
    -- Per-type background overrides are absent by default and inherit Global.
    killIconOffsetX = 1,
    killIconOffsetY = 16,
    lootIconOffsetX = 3,
    lootIconOffsetY = 16,
    -- Percent sign offsets are measured from the shipped baseline position
    -- (the current in-game look); 0 renders exactly there.
    percentIconOffsetX = 0,
    percentIconOffsetY = 0,
    killIconSize = 12,
    lootIconSize = 14,
    -- Starts at the shared 12; the sign would otherwise render smaller than
    -- the kill/loot counts it floats beside.
    percentIconSize = 12,
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

-- Atlas candidates present in both Retail and Forever client dumps.
-- Actual small-background appearance is selected through in-game testing.
SQP.CHIP_TEXTURES = {
    square = { atlas = "QuestLog-tab" },
    round = { atlas = "QuestNormal" },
    coin = { atlas = "auctionhouse-icon-coin-gold" },
    dark = { atlas = "QuestLog-reward-tile-vertical" },
    logo = "Interface\\AddOns\\SimpleQuestPlates\\media\\logo.tga",
    questBook = { atlas = "UI-HUD-MicroMenu-Questlog-Up" },
    questScroll = { atlas = "QuestLog-tab-icon-quest" },
    questParchment = { atlas = "QuestLog-main-background" },
    mapTurnin = { atlas = "QuestTurnin" },
    mapDaily = { atlas = "QuestDaily" },
    mapCampaign = { atlas = "Quest-Campaign-Available" },
    mapBoss = { atlas = "worldquest-icon-boss" },
    silver = { atlas = "auctionhouse-icon-coin-silver" },
    copper = { atlas = "auctionhouse-icon-coin-copper" },
    -- File IDs and UV crops agree in the Retail and Forever atlas sheets.
    minimapFill = { file = 4618657, coords = {0.03125, 0.53125, 0.03125, 0.53125} },
    minimapPressed = { file = 4618660, coords = {0.03125, 0.53125, 0.03125, 0.53125} },
    parchmentFile = { file = 5684755, coords = {0.302734375, 0.6025390625, 0.001953125, 0.998046875} },
    questTabFile = { file = 5684744, coords = {0.001953125, 0.126953125, 0.2890625, 0.33203125} },
    questRewardFile = { file = 5684744, coords = {0.21484375, 0.814453125, 0.423828125, 0.5859375} },
    medalGold = { atlas = "challenges-medal-small-gold" },
    medalSilver = { atlas = "challenges-medal-small-silver" },
    medalBronze = { atlas = "challenges-medal-small-bronze" },
    artifactMedal = { atlas = "Artifacts-PerkRing-GoldMedal" },
    levelBadge1 = { atlas = "Garr_LevelBadge_1" },
    levelBadge2 = { atlas = "Garr_LevelBadge_2" },
    levelBadge3 = { atlas = "Garr_LevelBadge_3" },
    currencyBadge = { atlas = "common-currencybox-a" },
    guildBadge = { atlas = "UI-Achievement-Guild-Badge" },
    campaignBadge = { atlas = "AutoQuest-Badge-Campaign" },
    rewardDisc = { atlas = "RecruitAFriend_RewardPane_IconBackground" },
    goldRing2 = { atlas = "Azerite-GoldRing-Rank2" },
    goldRing3 = { atlas = "Azerite-GoldRing-Rank3" },
    titanDisc = { atlas = "Azerite-TitanBG-Rank2" },
    housingDisc = { atlas = "house-upgrade-reward-icon-background" },
}

-- One entry per logo design; SQP/Classic share the existing SQP image.
-- Other logos are bundled, so no source addon is a runtime dependency.
SQP.LOGO_BACKGROUNDS = {
    { key = "logo", label = "SQP / SQP Classic" },
    { key = "BLU", label = "BLU" },
    { key = "FinalFantasyLevelUp", label = "Final Fantasy LevelUp" },
    { key = "FortniteLevelUp", label = "Fortnite LevelUp" },
    { key = "KingdomHearts3LevelUp", label = "Kingdom Hearts 3 LevelUp" },
    { key = "LeagueOfLegendsLevelUp", label = "League of Legends LevelUp" },
    { key = "MaplestoryLevelUp", label = "Maplestory LevelUp" },
    { key = "MinecraftLevelUp", label = "Minecraft LevelUp" },
    { key = "ModernWarfare2LevelUp", label = "Modern Warfare 2 LevelUp" },
    { key = "MorrowindLevelUp", label = "Morrowind LevelUp" },
    { key = "PathOfExileLevelUp", label = "Path of Exile LevelUp" },
    { key = "PokemonLevelUp", label = "Pokemon LevelUp" },
    { key = "ReputationLevelUp", label = "Reputation LevelUp" },
    { key = "RunescapeLevelUp", label = "Runescape LevelUp" },
    { key = "SkyrimLevelUp", label = "Skyrim LevelUp" },
    { key = "SonicTheHedgehogLevelUp", label = "Sonic the Hedgehog LevelUp" },
    { key = "SuperMarioBros3LevelUp", label = "Super Mario Bros 3 LevelUp" },
    { key = "Warcraft3LevelUp", label = "Warcraft 3 LevelUp" },
    { key = "RemoveNameplateDebuffs", label = "RND" },
    { key = "EnhancedTravelersLog", label = "ETL" },
    { key = "CoordinationCloakUtility", label = "CCU" },
    { key = "BattlePetUtility", label = "BPU" },
}
for _, logo in ipairs(SQP.LOGO_BACKGROUNDS) do
    if logo.key ~= "logo" then
        SQP.CHIP_TEXTURES[logo.key] = "Interface\\AddOns\\SimpleQuestPlates\\media\\backgrounds\\" .. logo.key .. ".tga"
    end
end

-- Every control and renderer resolves the same baseline. Per-type fonts
-- inherit General until an explicit override is saved.
function SQP:GetSettingBaseline(key)
    if key == "offsetX" and SQPSettings.anchor == "LEFT" then return 23 end
    if key == "killIconOffsetX" and SQPSettings.anchor ~= "LEFT" then
        local chip = SQPSettings.killLevelChip
        if chip == nil then chip = SQPSettings.unifiedNameplates end
        if chip == true then return 0 end
    end
    if SQPSettings.anchor == "LEFT" then
        if key == "killIconOffsetX" then return -3 end
        if key == "lootIconOffsetX" then return -44 end
    end
    local value = self.DEFAULTS[key]
    if value ~= nil then return value end
    if key:match("^(kill)FontSize$") or key:match("^(loot)FontSize$") or key:match("^(percent)FontSize$") then
        return SQPSettings.fontSize or self.DEFAULTS.fontSize
    end
    if key:match("^(kill)FontFamily$") or key:match("^(loot)FontFamily$") or key:match("^(percent)FontFamily$") then
        return SQPSettings.fontFamily or self.DEFAULTS.fontFamily
    end
end

function SQP:GetSettingValue(key)
    local value = SQPSettings[key]
    if value ~= nil then return value end
    return self:GetSettingBaseline(key)
end

-- Declare defaults before constructing the single persistent database owner.
SQP.db = RGX:NewDatabase("SQPSettings", SQP.DEFAULTS, {
    legacyFlat = true,
    profileIsGlobal = true,
    onSwitch = function()
        if SQP.optionsPanel then
            SQP.optionsPanel:InvalidateAllTabs()
            SQP.optionsPanel:Refresh()
        end
        if SQP.QuestPlates and type(SQP.RefreshAllNameplates) == "function" then
            SQP:RefreshAllNameplates()
        end
    end,
})
-- Keep the TOC SavedVariables owner raw; modules bind the profile view locally.
SQPSettings = SQP.db.global

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
    if settings.animationsEnabled == false or (typeKey and settings[typeKey .. "AnimationsEnabled"] == false) then
        return false
    end
    local baseEnabled = false

    if settings.useGlobalAnimationSettings == true then
        baseEnabled = settings.globalAnimationEnabled ~= false
    elseif isTaskIcon then
        baseEnabled = settings.animateQuestIcons == true
    elseif typeKey and typeKey ~= "" then
        baseEnabled = settings.animateMainIcons == true or settings[typeKey .. "AnimateMain"] == true
    end

    if not baseEnabled then
        return false
    end

    return self:IsAnimationCombatAllowed()
end

function SQP:GetAnimationIntensity(typeKey)
    local settings = SQPSettings or self.DEFAULTS or {}
    local intensity

    if settings.useGlobalAnimationSettings == true or settings.syncAnimations == true then
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
    local baseDuration = SQPSettings and SQPSettings.syncAnimations and 0.6 or (isMain and 0.5 or 0.6)
    local intensity = self:GetAnimationIntensity(typeKey)
    local duration = baseDuration * (100 / intensity)
    if duration < 0.15 then duration = 0.15 end
    if duration > 2 then duration = 2 end
    return duration
end

function SQP:ApplyPulseDuration(animationGroup, duration)
    if not animationGroup or not duration then return end
    if animationGroup._pulseDuration == duration then return end
    animationGroup._pulseDuration = duration

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

-- Font default migration: profiles saved before the RGX font default carry
-- legacy Friz Quadrata values (auto-filled per-type keys that shadow the
-- global font settings). Rewrite the legacy global default and clear
-- per-type values that still match the legacy defaults so they inherit the
-- global font (and General tab font changes) again.
local LEGACY_DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"
function SQP:MigrateLegacyFontDefaults(settings)
    settings = settings or SQPSettings
    if type(settings) ~= "table" then
        return
    end
    if settings.fontFamily == LEGACY_DEFAULT_FONT then
        settings.fontFamily = self.DEFAULTS.fontFamily
    end
    for _, typeKey in ipairs({ "kill", "loot", "percent" }) do
        if settings[typeKey .. "FontFamily"] == LEGACY_DEFAULT_FONT then
            settings[typeKey .. "FontFamily"] = nil
        end
        -- Explicit size/outline choices are user data, even when equal to old
        -- defaults. There is no evidence they were automatically generated.
    end
end

-- Current settings (initialized later)
-- SQPSettings = SQPSettings or {}  -- Now managed by RGX:NewDatabase

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
SQP.PANEL_NAME = format("|T%s:16:16:0:0|t %s", SQP.ICON_TEXTURE, SQP.NAME)
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

-- Initialize default settings (now handled by RGX:NewDatabase)
function SQP:InitializeSettings()
	-- Database is auto-initialized by RGX:NewDatabase
	-- SQPSettings global already points to db.global
end

-- Backwards-compatible alias used by events.lua
function SQP:LoadSettings()
	self:InitializeSettings()
end

-- Get settings table (database proxy)
function SQP:GetSavedSettings()
	return SQPSettings
end
SQP.GetSettings = SQP.GetSavedSettings

-- Save settings (RGX handles persistence automatically)
function SQP:SaveSettings()
	-- RGX:NewDatabase handles persistence; no-op for manual save
end

-- Set a single setting and persist it
function SQP:SetSetting(key, value)
	if not key then return end

	-- Explicit values stay boolean; nil deliberately clears an override.
	local defaultValue = self.DEFAULTS and self.DEFAULTS[key]
	if value ~= nil and type(defaultValue) == "boolean" then
		value = value and true or false
	end

	SQPSettings[key] = value
	-- RGX handles persistence automatically
end

-- Reset settings to default
function SQP:ResetSettings()
	-- The framework deep-fills fresh values; never alias nested default tables.
	if not self.db:ResetProfile() then return end
	self:PrintMessage(self.L["SETTINGS_RESET"] or "|cff58be81All settings have been reset to defaults|r")
	self:RefreshAllNameplates()
end

-- Enable addon
function SQP:EnableAddon()
	SQPSettings.enabled = true
	self:PrintMessage(self.L["ADDON_ENABLED"])
	self:RefreshAllNameplates()
end

-- Disable addon
function SQP:DisableAddon()
	SQPSettings.enabled = false
	self:PrintMessage(self.L["ADDON_DISABLED"])
	self:RefreshAllNameplates()
end

function SQP:SetupMinimapButton()
    local MM = RGX and RGX:GetMinimap() or nil
    if not MM then return end

    self.minimapBtn = MM:Create({
        name         = "SQP_MinimapButton",
        icon         = self.ICON_TEXTURE or "",
        defaultAngle = self.defaultMinimapAngle,
        storage      = SQPSettings,  -- Uses database proxy
        angleKey     = "minimapAngle",
        enabledKey   = "minimapIconEnabled",
        tooltip = {
            title = SQP.NAME or "Simple Quest Plates!",
            lines = {
                { left = "|cff58be81Left-Click|r",       right = "Open options" },
                { left = "|cff58be81Right-Click|r",      right = SQPSettings.enabled and "Disable overlays" or "Enable overlays" },
                { left = "|cff4ecdc4Drag|r",             right = "Move around minimap" },
                { left = "|cffe74c3cCtrl+Right-Click|r", right = "Hide minimap icon" },
            },
        },
        onLeftClick = function() SQP:ToggleOptions() end,
        onRightClick = function()
            SQP:SetSetting('enabled', SQPSettings.enabled == false)
            SQP:RefreshAllNameplates()
        end,
        onCtrlRight = function() SQP:ToggleMinimapIcon(false) end,
    })
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
