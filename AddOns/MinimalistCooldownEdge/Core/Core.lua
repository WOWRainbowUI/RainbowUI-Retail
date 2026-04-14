-- Core.lua – Addon skeleton, shared utilities, and database defaults

local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, C.Addon.AceName,
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(C.Addon.AceName)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- === UPVALUE LOCALS (Performance) ===
local pcall = pcall
local select = select
local tostring = tostring
local type = type
local tconcat = table.concat
local C_Timer_NewTimer = C_Timer.NewTimer
local C_Timer_After = C_Timer.After
local CHAT_PREFIX = C.Chat.Prefix
local OPTION_SLIDER_DEBOUNCE_DELAY = C.Options.SliderDebounceDelay
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs
local hooksecurefunc = hooksecurefunc
local issecretvalue = issecretvalue or function() return false end
local canaccessallvalues = canaccessallvalues

local RELOAD_PROMPT_POPUP_ID = "MCE_ReloadPrompt"

MCE.Constants = C

-- Shared weak-keyed state tables accessible to all modules
local weakMeta = { __mode = "k" }
addon.weakMeta = weakMeta
addon.frameState = setmetatable({}, weakMeta)
addon.fontState = setmetatable({}, weakMeta)

local addonLoadState = {}

local function QueryAddonLoaded(addonName)
    if type(addonName) ~= "string" or addonName == "" then
        return false
    end

    if C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function" then
        return C_AddOns.IsAddOnLoaded(addonName) == true
    end

    if type(IsAddOnLoaded) == "function" then
        local loaded = IsAddOnLoaded(addonName)
        return loaded == true or loaded == 1
    end

    return false
end

-- =========================================================================
-- SHARED UTILITIES  (used across all modules)
-- =========================================================================

--- Safe forbidden-frame check (pcall guards tainted frames).
--- Must use pcall because indexing a tainted frame itself throws.
--- Pre-defined helper avoids creating a closure on every call.
local function checkForbidden(frame)
    return frame:IsForbidden()
end

local function checkSecretValue(value)
    return issecretvalue(value)
end

local function getTableValue(tbl, key)
    return tbl[key]
end

function MCE:IsForbidden(frame)
    if not frame then return true end
    local ok, val = pcall(checkForbidden, frame)
    return not ok or val
end

function MCE:SafeTableGet(tbl, key)
    if tbl == nil or key == nil then
        return nil
    end

    local ok, value = pcall(getTableValue, tbl, key)
    if not ok then
        return nil
    end

    return value
end

function MCE:CanUseFrameAsTableKey(frame)
    if not frame then return false end

    local frameType = type(frame)
    if frameType ~= "table" and frameType ~= "userdata" then
        return false
    end

    local ok, isSecret = pcall(checkSecretValue, frame)
    if not ok or isSecret then
        return false
    end

    if canaccessallvalues then
        local accessOk, canAccess = pcall(canaccessallvalues, frame)
        if not accessOk or not canAccess then
            return false
        end
    end

    return not self:IsForbidden(frame)
end

--- WoW API expects "" not "NONE" for font outline flags.
function MCE.NormalizeFontStyle(style)
    if not style or style == C.Style.FontStyles.None then return "" end
    return style
end

--- Resolves "GAMEDEFAULT" to WoW's native font path.
function MCE.ResolveFontPath(fontPath)
    if fontPath == C.Style.Fonts.GameDefault then
        return GameFontNormal:GetFont()
    end
    return fontPath
end

function MCE:SetAddonLoadState(addonName, isLoaded)
    if type(addonName) ~= "string" or addonName == "" then
        return false
    end

    addonLoadState[addonName] = isLoaded == true
    return addonLoadState[addonName]
end

function MCE:IsAddonLoadedCached(addonName)
    if type(addonName) ~= "string" or addonName == "" then
        return false
    end

    local cached = addonLoadState[addonName]
    if cached ~= nil then
        return cached
    end

    return self:SetAddonLoadState(addonName, QueryAddonLoaded(addonName))
end

function MCE:IsMiniCCAvailable()
    return self:IsAddonLoadedCached(C.Addon.MiniCCName)
end

function MCE:IsDominosAvailable()
    if _G.DominosFrame1 or _G.DominosActionButton1 then
        self:SetAddonLoadState(C.Addon.DominosName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.DominosName)
        or self:IsAddonLoadedCached(C.Addon.DominosCastName)
        or self:IsAddonLoadedCached(C.Addon.DominosConfigName)
end

function MCE:IsBartender4Available()
    if _G.BT4Button1 then
        self:SetAddonLoadState(C.Addon.Bartender4Name, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.Bartender4Name)
end

function MCE:IsSArenaAvailable()
    return self:IsAddonLoadedCached(C.Addon.SArenaName)
end

function MCE:IsTellMeWhenAvailable()
    return self:IsAddonLoadedCached(C.Addon.TellMeWhenName)
end

function MCE:IsElvUIAvailable()
    if type(_G.ElvUI) == "table" then
        self:SetAddonLoadState("ElvUI", true)
        return true
    end

    return self:IsAddonLoadedCached("ElvUI")
end

function MCE:IsCooldownManagerCenteredAvailable()
    local addonName = C.Addon.CooldownManagerCenteredName
    if type(_G[addonName]) == "table" then
        self:SetAddonLoadState(addonName, true)
        return true
    end

    return self:IsAddonLoadedCached(addonName)
end

function MCE:IsMUIAvailable()
    if type(_G.mUI) == "table" then
        self:SetAddonLoadState(C.Addon.MUIName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.MUIName)
end

function MCE:IsShinyAurasAvailable()
    if _G.ShinyAurasFrame or type(_G.ShinyAurasDB) == "table" then
        self:SetAddonLoadState(C.Addon.ShinyAurasName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.ShinyAurasName)
end

function MCE:IsShinyAurasAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.shinyAurasAdapterEnabled ~= false
end

function MCE:IsDominosAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.dominosAdapterEnabled ~= false
end

function MCE:IsBartender4AdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.bartender4AdapterEnabled ~= false
end

function MCE:IsElvUIAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.elvuiAdapterEnabled ~= false
end

local function BuildChatMessage(...)
    local count = select("#", ...)
    if count == 0 then
        return CHAT_PREFIX
    end

    local parts = {}
    for i = 1, count do
        parts[i] = tostring(select(i, ...))
    end

    return CHAT_PREFIX .. " " .. tconcat(parts, " ")
end

function MCE:Print(...)
    DEFAULT_CHAT_FRAME:AddMessage(BuildChatMessage(...))
end

function MCE:MarkReloadRequired()
    self.reloadRequired = true
    self.reloadChangeVersion = (self.reloadChangeVersion or 0) + 1
end

function MCE:ClearReloadRequired()
    self.reloadRequired = false
    self.reloadPromptedVersion = self.reloadChangeVersion or 0
end

function MCE:ShouldPromptForReload()
    return self.reloadRequired == true
        and (self.reloadPromptedVersion or 0) < (self.reloadChangeVersion or 0)
end

function MCE:EnsureReloadPromptDialog()
    if self.reloadPromptDialogRegistered or type(StaticPopupDialogs) ~= "table" then
        return
    end

    StaticPopupDialogs[RELOAD_PROMPT_POPUP_ID] = StaticPopupDialogs[RELOAD_PROMPT_POPUP_ID] or {
        text = L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"],
        button1 = RELOADUI,
        button2 = NOT_NOW or CANCEL,
        OnAccept = function()
            self:ClearReloadRequired()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
    }

    self.reloadPromptDialogRegistered = true
end

function MCE:QueueReloadPrompt()
    if not self:ShouldPromptForReload() or self.reloadPromptQueued then
        return
    end

    self.reloadPromptQueued = true
    C_Timer_After(0, function()
        self.reloadPromptQueued = nil

        if self:ShouldPromptForReload() and type(StaticPopup_Show) == "function" then
            self.reloadPromptedVersion = self.reloadChangeVersion or 0
            StaticPopup_Show(RELOAD_PROMPT_POPUP_ID)
        end
    end)
end

function MCE:HandleTrackedBlizzardOptionsClosed()
    if not self.visitedBlizzardOptions then
        return
    end

    self.visitedBlizzardOptions = false
    self:QueueReloadPrompt()
end

function MCE:EnsureSettingsPanelCloseHooks()
    local function HookSettingsFrame(frame)
        if not frame or not frame.HookScript or frame._mceReloadPromptHooked then
            return false
        end

        frame:HookScript("OnHide", function()
            self:HandleTrackedBlizzardOptionsClosed()
        end)
        frame._mceReloadPromptHooked = true
        return true
    end

    local hooked = false
    hooked = HookSettingsFrame(_G.SettingsPanel) or hooked
    hooked = HookSettingsFrame(_G.InterfaceOptionsFrame) or hooked

    self.settingsPanelCloseHooksInstalled = hooked or self.settingsPanelCloseHooksInstalled
end

function MCE:RegisterBlizzardOptionsPanel(panel)
    local frame = panel and (panel.frame or panel)
    if not frame or not frame.HookScript or frame._mceReloadPromptTracked then
        return panel
    end

    frame:HookScript("OnShow", function()
        self.visitedBlizzardOptions = true
        self:EnsureSettingsPanelCloseHooks()
    end)
    frame._mceReloadPromptTracked = true

    return panel
end

function MCE:EnsureOptionsCloseHooks()
    if self.optionsCloseHooksInstalled or type(hooksecurefunc) ~= "function" then
        return
    end

    hooksecurefunc(AceConfigDialog, "Open", function(_, appName)
        local widget = AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[appName]
        local frame = widget and widget.frame
        if not frame or not frame.HookScript then
            return
        end

        frame._mceReloadPromptAppName = appName
        if not frame._mceReloadPromptHooked then
            frame:HookScript("OnHide", function(closingFrame)
                if closingFrame and closingFrame._mceReloadPromptAppName == addonName then
                    self:QueueReloadPrompt()
                end
            end)
            frame._mceReloadPromptHooked = true
        end
    end)

    self.optionsCloseHooksInstalled = true
end

-- =========================================================================
-- DATABASE DEFAULTS
-- =========================================================================

local function CategoryDefaults(categoryKey, enabled, fontSize)
    local defaults = C.Defaults.Category
    local allowThresholdColors = C.Defaults.AllowThresholdColorsByCategory[categoryKey] == true
    return {
        enabled = enabled,
        font = defaults.Font,
        fontSize = fontSize or defaults.FontSize,
        fontStyle = defaults.FontStyle,
        textColor = CopyTable(defaults.TextColor),
        textAnchor = defaults.TextAnchor,
        textOffsetX = defaults.TextOffsetX,
        textOffsetY = defaults.TextOffsetY,
        allowThresholdColors = allowThresholdColors,
        hideCountdownNumbers = defaults.HideCountdownNumbers,
        auraCdTextOnlyMine = defaults.AuraCdTextOnlyMine,
        drawSwipe = defaults.DrawSwipe,
        edgeEnabled = defaults.EdgeEnabled,
        edgeScale = defaults.EdgeScale,
        stackEnabled = defaults.StackEnabled,
        hideStackText = defaults.HideStackText,
        stackFont = defaults.StackFont,
        stackSize = defaults.StackSize,
        stackStyle = defaults.StackStyle,
        stackColor = CopyTable(defaults.StackColor),
        stackAnchor = defaults.StackAnchor,
        stackOffsetX = defaults.StackOffsetX,
        stackOffsetY = defaults.StackOffsetY,
    }
end

local function DurationTextColorDefaults()
    local defaults = C.Defaults.DurationTextColors
    local thresholds = {}

    for i = 1, #defaults.Thresholds do
        thresholds[i] = {
            threshold = defaults.Thresholds[i].threshold,
            color = CopyTable(defaults.Thresholds[i].color),
        }
    end

    return {
        enabled = defaults.Enabled,
        offset = defaults.Offset,
        thresholds = thresholds,
        defaultColor = CopyTable(defaults.DefaultColor),
    }
end

local actionbarDefaults = CategoryDefaults(C.Categories.Actionbar, true, 18)
actionbarDefaults.hideChargeTimers = C.Defaults.Actionbar.HideChargeTimers
actionbarDefaults.swipeAlpha = C.Defaults.Actionbar.SwipeAlpha

local nameplateDefaults = CategoryDefaults(C.Categories.Nameplate, false, C.Defaults.Nameplate.FontSize)
nameplateDefaults.stackSize = C.Defaults.Nameplate.StackSize
nameplateDefaults.stackAnchor = C.Defaults.Nameplate.StackAnchor
nameplateDefaults.stackOffsetX = C.Defaults.Nameplate.StackOffsetX
nameplateDefaults.stackOffsetY = C.Defaults.Nameplate.StackOffsetY

local unitframeDefaults = CategoryDefaults(C.Categories.Unitframe, false, 12)
unitframeDefaults.stackSize = C.Defaults.Unitframe.StackSize
unitframeDefaults.stackAnchor = C.Defaults.Unitframe.StackAnchor
unitframeDefaults.stackOffsetX = C.Defaults.Unitframe.StackOffsetX
unitframeDefaults.stackOffsetY = C.Defaults.Unitframe.StackOffsetY

local defaultDurationTextColors = DurationTextColorDefaults()
local compactPartyAuraTextDefaults

local function EnsureDurationTextColorConfig(config)
    if type(config) ~= "table" then
        return CopyTable(defaultDurationTextColors)
    end

    if config.enabled == nil then
        config.enabled = defaultDurationTextColors.enabled
    end

    if type(config.offset) ~= "number" then
        config.offset = defaultDurationTextColors.offset
    end

    if type(config.thresholds) ~= "table" then
        config.thresholds = {}
    end

    for i = 1, #defaultDurationTextColors.thresholds do
        local defaultThreshold = defaultDurationTextColors.thresholds[i]
        local threshold = config.thresholds[i]

        if type(threshold) ~= "table" then
            config.thresholds[i] = CopyTable(defaultThreshold)
        else
            if threshold.threshold == nil then
                threshold.threshold = defaultThreshold.threshold
            end
            if type(threshold.color) ~= "table" then
                threshold.color = CopyTable(defaultThreshold.color)
            else
                threshold.color.r = threshold.color.r or defaultThreshold.color.r
                threshold.color.g = threshold.color.g or defaultThreshold.color.g
                threshold.color.b = threshold.color.b or defaultThreshold.color.b
                threshold.color.a = threshold.color.a or defaultThreshold.color.a
            end
        end
    end

    if type(config.defaultColor) ~= "table" then
        config.defaultColor = CopyTable(defaultDurationTextColors.defaultColor)
    else
        config.defaultColor.r = config.defaultColor.r or defaultDurationTextColors.defaultColor.r
        config.defaultColor.g = config.defaultColor.g or defaultDurationTextColors.defaultColor.g
        config.defaultColor.b = config.defaultColor.b or defaultDurationTextColors.defaultColor.b
        config.defaultColor.a = config.defaultColor.a or defaultDurationTextColors.defaultColor.a
    end

    return config
end

local function EnsureCompactPartyAuraTextConfig(config)
    if type(config) ~= "table" then
        return CopyTable(compactPartyAuraTextDefaults)
    end

    if config.enabled == nil then
        config.enabled = compactPartyAuraTextDefaults.enabled
    end
    if config.raidEnabled == nil then
        config.raidEnabled = compactPartyAuraTextDefaults.raidEnabled
    end
    if config.font == nil then
        config.font = compactPartyAuraTextDefaults.font
    end
    if type(config.fontSize) ~= "number" then
        config.fontSize = compactPartyAuraTextDefaults.fontSize
    end
    if type(config.defensiveBuffFontSize) ~= "number" then
        config.defensiveBuffFontSize = compactPartyAuraTextDefaults.defensiveBuffFontSize
    end
    if config.allowThresholdColors == nil then
        config.allowThresholdColors = compactPartyAuraTextDefaults.allowThresholdColors
    end
    if config.fontStyle == nil then
        config.fontStyle = compactPartyAuraTextDefaults.fontStyle
    end
    if config.drawSwipe == nil then
        config.drawSwipe = compactPartyAuraTextDefaults.drawSwipe
    end
    if config.edgeEnabled == nil then
        config.edgeEnabled = compactPartyAuraTextDefaults.edgeEnabled
    end
    if type(config.edgeScale) ~= "number" then
        config.edgeScale = compactPartyAuraTextDefaults.edgeScale
    end
    if config.textAnchor == nil then
        config.textAnchor = compactPartyAuraTextDefaults.textAnchor
    end
    if type(config.textOffsetX) ~= "number" then
        config.textOffsetX = compactPartyAuraTextDefaults.textOffsetX
    end
    if type(config.textOffsetY) ~= "number" then
        config.textOffsetY = compactPartyAuraTextDefaults.textOffsetY
    end

    if config.stackEnabled == nil then
        config.stackEnabled = compactPartyAuraTextDefaults.stackEnabled
    end
    if config.hideStackText == nil then
        config.hideStackText = compactPartyAuraTextDefaults.hideStackText
    end
    if config.stackFont == nil then
        config.stackFont = compactPartyAuraTextDefaults.stackFont
    end
    if type(config.stackSize) ~= "number" then
        config.stackSize = compactPartyAuraTextDefaults.stackSize
    end
    if config.stackStyle == nil then
        config.stackStyle = compactPartyAuraTextDefaults.stackStyle
    end
    if config.stackAnchor == nil then
        config.stackAnchor = compactPartyAuraTextDefaults.stackAnchor
    end
    if type(config.stackOffsetX) ~= "number" then
        config.stackOffsetX = compactPartyAuraTextDefaults.stackOffsetX
    end
    if type(config.stackOffsetY) ~= "number" then
        config.stackOffsetY = compactPartyAuraTextDefaults.stackOffsetY
    end
    if type(config.stackColor) ~= "table" then
        config.stackColor = CopyTable(compactPartyAuraTextDefaults.stackColor)
    else
        local defaultStackColor = compactPartyAuraTextDefaults.stackColor
        if config.stackColor.r == nil then config.stackColor.r = defaultStackColor.r end
        if config.stackColor.g == nil then config.stackColor.g = defaultStackColor.g end
        if config.stackColor.b == nil then config.stackColor.b = defaultStackColor.b end
        if config.stackColor.a == nil then config.stackColor.a = defaultStackColor.a end
    end

    if type(config.textColor) ~= "table" then
        config.textColor = CopyTable(compactPartyAuraTextDefaults.textColor)
    else
        local defaultColor = compactPartyAuraTextDefaults.textColor
        if config.textColor.r == nil then config.textColor.r = defaultColor.r end
        if config.textColor.g == nil then config.textColor.g = defaultColor.g end
        if config.textColor.b == nil then config.textColor.b = defaultColor.b end
        if config.textColor.a == nil then config.textColor.a = defaultColor.a end
    end

    return config
end

local function CleanupObsoleteProfileFields(profile)
    local categories = type(profile.categories) == "table" and profile.categories or nil
    if not categories then
        return
    end

    profile.cooldownManagerCenteredOverrideEnabled = nil
    categories.partyraidframes = nil
    categories[C.Categories.CompactPartyAura] = nil

    local actionbarCategory = categories[C.Categories.Actionbar]
    if type(actionbarCategory) == "table" then
        actionbarCategory.textColorByDuration = nil
    end
end

local function CleanupObsoleteDatabaseFields(db, profile)
    if type(db) == "table" and type(db.global) == "table" then
        db.global.versionAlertsShown = nil
    end

    if profile then
        CleanupObsoleteProfileFields(profile)
    end
end

MCE.DurationTextColorDefaults = DurationTextColorDefaults
MCE.EnsureDurationTextColorConfig = EnsureDurationTextColorConfig
MCE.EnsureCompactPartyAuraTextConfig = EnsureCompactPartyAuraTextConfig

local cooldownManagerDefaults = CategoryDefaults(C.Categories.CooldownManager, false, 18)
cooldownManagerDefaults.essentialFontSize = C.Defaults.CooldownManager.EssentialFontSize
cooldownManagerDefaults.utilityFontSize = C.Defaults.CooldownManager.UtilityFontSize
cooldownManagerDefaults.buffIconFontSize = C.Defaults.CooldownManager.BuffIconFontSize
cooldownManagerDefaults.auraColorEnabled = C.Defaults.CooldownManager.AuraColorEnabled
cooldownManagerDefaults.auraColor = CopyTable(C.Defaults.CooldownManager.AuraColor)

local function EnsureCooldownManagerConfig(config)
    if type(config) ~= "table" then
        return CopyTable(cooldownManagerDefaults)
    end

    if type(config.essentialFontSize) ~= "number" then
        config.essentialFontSize = C.Defaults.CooldownManager.EssentialFontSize
    end
    if type(config.utilityFontSize) ~= "number" then
        config.utilityFontSize = C.Defaults.CooldownManager.UtilityFontSize
    end
    if type(config.buffIconFontSize) ~= "number" then
        config.buffIconFontSize = C.Defaults.CooldownManager.BuffIconFontSize
    end
    if config.auraColorEnabled == nil then
        config.auraColorEnabled = C.Defaults.CooldownManager.AuraColorEnabled
    end
    if type(config.auraColor) ~= "table" then
        config.auraColor = CopyTable(C.Defaults.CooldownManager.AuraColor)
    else
        local defaultColor = C.Defaults.CooldownManager.AuraColor
        if config.auraColor.r == nil then config.auraColor.r = defaultColor.r end
        if config.auraColor.g == nil then config.auraColor.g = defaultColor.g end
        if config.auraColor.b == nil then config.auraColor.b = defaultColor.b end
        if config.auraColor.a == nil then config.auraColor.a = defaultColor.a end
    end

    return config
end

local miniCCDefaults = CategoryDefaults(C.Categories.MiniCC, false, 18)
miniCCDefaults.ccFontSize = C.Defaults.MiniCC.CCFontSize
miniCCDefaults.ccHideCountdownNumbers = C.Defaults.MiniCC.CCHideCountdownNumbers
miniCCDefaults.ccHideSwipe = C.Defaults.MiniCC.CCHideSwipe
miniCCDefaults.friendlyCdFontSize = C.Defaults.MiniCC.FriendlyCDFontSize
miniCCDefaults.friendlyCdHideCountdownNumbers = C.Defaults.MiniCC.FriendlyCDHideCountdownNumbers
miniCCDefaults.friendlyCdHideSwipe = C.Defaults.MiniCC.FriendlyCDHideSwipe
miniCCDefaults.nameplateFontSize = C.Defaults.MiniCC.NameplateFontSize
miniCCDefaults.nameplateHideCountdownNumbers = C.Defaults.MiniCC.NameplateHideCountdownNumbers
miniCCDefaults.nameplateHideSwipe = C.Defaults.MiniCC.NameplateHideSwipe
miniCCDefaults.portraitFontSize = C.Defaults.MiniCC.PortraitFontSize
miniCCDefaults.portraitHideCountdownNumbers = C.Defaults.MiniCC.PortraitHideCountdownNumbers
miniCCDefaults.portraitHideSwipe = C.Defaults.MiniCC.PortraitHideSwipe
miniCCDefaults.overlayFontSize = C.Defaults.MiniCC.OverlayFontSize
miniCCDefaults.overlayHideCountdownNumbers = C.Defaults.MiniCC.OverlayHideCountdownNumbers
miniCCDefaults.overlayHideSwipe = C.Defaults.MiniCC.OverlayHideSwipe

local sArenaDefaults = CategoryDefaults(C.Categories.SArena, false, 18)
sArenaDefaults.classIconFontSize = C.Defaults.SArena.ClassIconFontSize
sArenaDefaults.drFontSize = C.Defaults.SArena.DRFontSize
sArenaDefaults.trinketRacialFontSize = C.Defaults.SArena.TrinketRacialFontSize

local tellMeWhenDefaults = CategoryDefaults(C.Categories.TellMeWhen, false, C.Defaults.TellMeWhen.FontSize)

local compactPartyAuraDefaults = C.Defaults.CompactPartyAuraText
compactPartyAuraTextDefaults = {
    enabled = compactPartyAuraDefaults.Enabled,
    raidEnabled = compactPartyAuraDefaults.RaidEnabled,
    font = compactPartyAuraDefaults.Font,
    fontSize = compactPartyAuraDefaults.FontSize,
    defensiveBuffFontSize = compactPartyAuraDefaults.DefensiveBuffFontSize,
    allowThresholdColors = C.Defaults.AllowThresholdColorsByCategory[C.Categories.CompactPartyAura] == true,
    fontStyle = compactPartyAuraDefaults.FontStyle,
    drawSwipe = compactPartyAuraDefaults.DrawSwipe,
    edgeEnabled = compactPartyAuraDefaults.EdgeEnabled,
    edgeScale = compactPartyAuraDefaults.EdgeScale,
    textColor = CopyTable(compactPartyAuraDefaults.TextColor),
    textAnchor = compactPartyAuraDefaults.TextAnchor,
    textOffsetX = compactPartyAuraDefaults.TextOffsetX,
    textOffsetY = compactPartyAuraDefaults.TextOffsetY,
    stackEnabled = compactPartyAuraDefaults.StackEnabled,
    hideStackText = compactPartyAuraDefaults.HideStackText,
    stackFont = compactPartyAuraDefaults.StackFont,
    stackSize = compactPartyAuraDefaults.StackSize,
    stackStyle = compactPartyAuraDefaults.StackStyle,
    stackColor = CopyTable(compactPartyAuraDefaults.StackColor),
    stackAnchor = compactPartyAuraDefaults.StackAnchor,
    stackOffsetX = compactPartyAuraDefaults.StackOffsetX,
    stackOffsetY = compactPartyAuraDefaults.StackOffsetY,
}

MCE.defaults = {
    profile = {
        abbrevThreshold = C.Options.DefaultAbbrevThreshold,
        shinyAurasAdapterEnabled = true,
        dominosAdapterEnabled = true,
        bartender4AdapterEnabled = true,
        elvuiAdapterEnabled = true,
        compactPartyAuraText = compactPartyAuraTextDefaults,
        durationTextColors = defaultDurationTextColors,
        categories = {
            [C.Categories.Actionbar] = actionbarDefaults,
            [C.Categories.Nameplate] = nameplateDefaults,
            [C.Categories.Unitframe] = unitframeDefaults,
            [C.Categories.CooldownManager] = cooldownManagerDefaults,
            [C.Categories.MiniCC] = miniCCDefaults,
            [C.Categories.SArena] = sArenaDefaults,
            [C.Categories.TellMeWhen] = tellMeWhenDefaults,
        },
    },
}

function MCE:UpgradeProfile()
    local profile = self.db and self.db.profile
    if not profile then return end

    CleanupObsoleteDatabaseFields(self.db, profile)

    if profile.shinyAurasAdapterEnabled == nil then
        profile.shinyAurasAdapterEnabled = true
    end

    if profile.dominosAdapterEnabled == nil then
        profile.dominosAdapterEnabled = true
    end

    if profile.bartender4AdapterEnabled == nil then
        profile.bartender4AdapterEnabled = true
    end

    if profile.elvuiAdapterEnabled == nil then
        profile.elvuiAdapterEnabled = true
    end

    if not profile.durationTextColors then
        profile.durationTextColors = CopyTable(defaultDurationTextColors)
    end

    if type(profile.categories) ~= "table" then
        profile.categories = CopyTable(self.defaults.profile.categories)
    end

    profile.categories[C.Categories.CooldownManager] =
        EnsureCooldownManagerConfig(profile.categories[C.Categories.CooldownManager])

    EnsureDurationTextColorConfig(profile.durationTextColors)
    profile.compactPartyAuraText = EnsureCompactPartyAuraTextConfig(profile.compactPartyAuraText)
end

function MCE:HandleProfileUpdated()
    if self.suppressProfileCallbacks then return end

    self:UpgradeProfile()
    self:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
end

function MCE:ADDON_LOADED(_, loadedAddonName)
    self:SetAddonLoadState(loadedAddonName, true)
end

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self:RegisterEvent("ADDON_LOADED")
    self.db = LibStub("AceDB-3.0"):New(C.Addon.SavedVariables, self.defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "HandleProfileUpdated")
    self.db.RegisterCallback(self, "OnProfileCopied", "HandleProfileUpdated")
    self.db.RegisterCallback(self, "OnProfileReset", "HandleProfileUpdated")
    self:UpgradeProfile()
    self.pendingOptionRefresh = nil
    self.pendingOptionRefreshFullScan = false
    self.reloadRequired = false
    self.reloadChangeVersion = 0
    self.reloadPromptedVersion = 0
    self.reloadPromptQueued = false
    self.visitedBlizzardOptions = false
    self:EnsureReloadPromptDialog()
    self:EnsureOptionsCloseHooks()

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)

    do
        local status = AceConfigDialog:GetStatusTable(addonName)
        status.width = math.max(status.width or 0, C.Options.FrameWidth)
        status.height = math.max(status.height or 0, C.Options.FrameHeight)
        status.groups = status.groups or {}
        status.groups.treewidth = math.max(status.groups.treewidth or 0, C.Options.TreeWidth)
        status.groups.treesizable = true
    end

    self.optionsFrame = self:RegisterBlizzardOptionsPanel(
        AceConfigDialog:AddToBlizOptions(addonName, C.Addon.ShortName, nil, "general")
    )
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Action Bars"], C.Addon.ShortName, C.Categories.Actionbar))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Nameplates"], C.Addon.ShortName, C.Categories.Nameplate))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Unit Frames"], C.Addon.ShortName, C.Categories.Unitframe))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Party / Raid Frames"], C.Addon.ShortName, C.Categories.CompactPartyAura))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["CooldownManager"], C.Addon.ShortName, C.Categories.CooldownManager))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["MiniCC"], C.Addon.ShortName, C.Categories.MiniCC))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["sArena"], C.Addon.ShortName, C.Categories.SArena))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["TellMeWhen"], C.Addon.ShortName, C.Categories.TellMeWhen))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Help & Support"], C.Addon.ShortName, "help"))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Profiles"], C.Addon.ShortName, "profiles"))

    for i = 1, #C.Addon.SlashCommands do
        self:RegisterChatCommand(C.Addon.SlashCommands[i], "SlashCommand")
    end
end

function MCE:OnDisable()
    self:CancelDebouncedOptionRefresh()
end

function MCE:SlashCommand(input)
    if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[addonName] then
        AceConfigDialog:Close(addonName)
        return
    end

    AceConfigDialog:Open(addonName)
end

--- Public API – delegates to Styler module.
function MCE:CancelDebouncedOptionRefresh()
    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
        self.pendingOptionRefresh = nil
    end

    self.pendingOptionRefreshFullScan = false
end

function MCE:RequestDebouncedOptionRefresh(fullScan, delay)
    self.pendingOptionRefreshFullScan = self.pendingOptionRefreshFullScan or fullScan or false

    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
    end

    self.pendingOptionRefresh = C_Timer_NewTimer(delay or OPTION_SLIDER_DEBOUNCE_DELAY, function()
        local needsFullScan = self.pendingOptionRefreshFullScan
        self.pendingOptionRefresh = nil
        self.pendingOptionRefreshFullScan = false
        self:ForceUpdateAll(needsFullScan)
    end)
end

function MCE:ForceUpdateAll(fullScan)
    self:CancelDebouncedOptionRefresh()
    self:GetModule("Styler"):ForceUpdateAll(fullScan)
end
