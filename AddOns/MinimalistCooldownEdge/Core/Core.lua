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
local tconcat = table.concat
local C_Timer_NewTimer = C_Timer.NewTimer
local C_Timer_After = C_Timer.After
local CHAT_PREFIX = C.Chat.Prefix
local OPTION_SLIDER_DEBOUNCE_DELAY = C.Options.SliderDebounceDelay
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs
local hooksecurefunc = hooksecurefunc

local RELOAD_PROMPT_POPUP_ID = "MCE_ReloadPrompt"

MCE.Constants = C

-- Shared weak-keyed state tables accessible to all modules
local weakMeta = { __mode = "k" }
addon.weakMeta = weakMeta
addon.frameState = setmetatable({}, weakMeta)
addon.fontState = setmetatable({}, weakMeta)

-- =========================================================================
-- SHARED UTILITIES  (used across all modules)
-- =========================================================================

--- Safe forbidden-frame check (pcall guards tainted frames).
--- Must use pcall because indexing a tainted frame itself throws.
--- Pre-defined helper avoids creating a closure on every call.
local function checkForbidden(frame)
    return frame:IsForbidden()
end

function MCE:IsForbidden(frame)
    if not frame then return true end
    local ok, val = pcall(checkForbidden, frame)
    return not ok or val
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

function MCE:IsMiniCCAvailable()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(C.Addon.MiniCCName) or false
end

function MCE:IsSArenaAvailable()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(C.Addon.SArenaName) or false
end

function MCE:IsTellMeWhenAvailable()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(C.Addon.TellMeWhenName) or false
end

function MCE:IsElvUIAvailable()
    if type(_G.ElvUI) == "table" then
        return true
    end

    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("ElvUI") or false
end

function MCE:IsShinyAurasAvailable()
    if _G.ShinyAurasFrame or type(_G.ShinyAurasDB) == "table" then
        return true
    end

    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(C.Addon.ShinyAurasName) or false
end

function MCE:IsShinyAurasAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.shinyAurasAdapterEnabled ~= false
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

local function IsCompactPartyAuraConfigAtDefaults(config)
    if type(config) ~= "table" then
        return false
    end

    local defaults = compactPartyAuraTextDefaults
    local color = config.textColor
    local defaultColor = defaults.textColor

    local stackColor = config.stackColor
    local defaultStackColor = defaults.stackColor

    return config.enabled == defaults.enabled
        and config.raidEnabled == defaults.raidEnabled
        and config.font == defaults.font
        and config.fontSize == defaults.fontSize
        and config.defensiveBuffFontSize == defaults.defensiveBuffFontSize
        and config.allowThresholdColors == defaults.allowThresholdColors
        and config.fontStyle == defaults.fontStyle
        and config.drawSwipe == defaults.drawSwipe
        and config.edgeEnabled == defaults.edgeEnabled
        and config.edgeScale == defaults.edgeScale
        and config.textAnchor == defaults.textAnchor
        and config.textOffsetX == defaults.textOffsetX
        and config.textOffsetY == defaults.textOffsetY
        and config.stackEnabled == defaults.stackEnabled
        and config.hideStackText == defaults.hideStackText
        and config.stackFont == defaults.stackFont
        and config.stackSize == defaults.stackSize
        and config.stackStyle == defaults.stackStyle
        and config.stackAnchor == defaults.stackAnchor
        and config.stackOffsetX == defaults.stackOffsetX
        and config.stackOffsetY == defaults.stackOffsetY
        and type(color) == "table"
        and color.r == defaultColor.r
        and color.g == defaultColor.g
        and color.b == defaultColor.b
        and color.a == defaultColor.a
        and type(stackColor) == "table"
        and stackColor.r == defaultStackColor.r
        and stackColor.g == defaultStackColor.g
        and stackColor.b == defaultStackColor.b
        and stackColor.a == defaultStackColor.a
end

local function MigrateLegacyPartyRaidFramesConfig(profile)
    local categories = type(profile.categories) == "table" and profile.categories or nil
    if not categories then
        return
    end

    local legacyCategory = rawget(categories, "partyraidframes")
        or rawget(categories, C.Categories.CompactPartyAura)
    if type(legacyCategory) ~= "table" then
        return
    end

    local explicitCompactConfig = rawget(profile, "compactPartyAuraText")
    local shouldMigrateLegacy = type(explicitCompactConfig) ~= "table"
    if not shouldMigrateLegacy and next(explicitCompactConfig) == nil then
        shouldMigrateLegacy = true
    end
    if not shouldMigrateLegacy and IsCompactPartyAuraConfigAtDefaults(EnsureCompactPartyAuraTextConfig(CopyTable(explicitCompactConfig))) then
        shouldMigrateLegacy = true
    end

    if shouldMigrateLegacy then
        explicitCompactConfig = {}
        profile.compactPartyAuraText = explicitCompactConfig

        if legacyCategory.enabled ~= nil then
            explicitCompactConfig.enabled = legacyCategory.enabled and true or false
        elseif legacyCategory.partyAuraTextEnabled ~= nil then
            explicitCompactConfig.enabled = legacyCategory.partyAuraTextEnabled and true or false
        end

        if legacyCategory.enableForRaidOverFive ~= nil then
            explicitCompactConfig.raidEnabled = legacyCategory.enableForRaidOverFive and true or false
        elseif legacyCategory.raidAuraTextEnabled ~= nil then
            explicitCompactConfig.raidEnabled = legacyCategory.raidAuraTextEnabled and true or false
        end

        if legacyCategory.font ~= nil then
            explicitCompactConfig.font = legacyCategory.font
        end
        if legacyCategory.fontSize ~= nil then
            explicitCompactConfig.fontSize = legacyCategory.fontSize
        end
        if legacyCategory.defensiveBuffFontSize ~= nil then
            explicitCompactConfig.defensiveBuffFontSize = legacyCategory.defensiveBuffFontSize
        end
        if legacyCategory.allowThresholdColors ~= nil then
            explicitCompactConfig.allowThresholdColors = legacyCategory.allowThresholdColors and true or false
        end
        if legacyCategory.fontStyle ~= nil then
            explicitCompactConfig.fontStyle = legacyCategory.fontStyle
        end
        if legacyCategory.drawSwipe ~= nil then
            explicitCompactConfig.drawSwipe = legacyCategory.drawSwipe and true or false
        end
        if legacyCategory.edgeEnabled ~= nil then
            explicitCompactConfig.edgeEnabled = legacyCategory.edgeEnabled and true or false
        end
        if legacyCategory.edgeScale ~= nil then
            explicitCompactConfig.edgeScale = legacyCategory.edgeScale
        end
        if type(legacyCategory.textColor) == "table" then
            explicitCompactConfig.textColor = CopyTable(legacyCategory.textColor)
        end
        if legacyCategory.textAnchor ~= nil then
            explicitCompactConfig.textAnchor = legacyCategory.textAnchor
        end
        if legacyCategory.textOffsetX ~= nil then
            explicitCompactConfig.textOffsetX = legacyCategory.textOffsetX
        end
        if legacyCategory.textOffsetY ~= nil then
            explicitCompactConfig.textOffsetY = legacyCategory.textOffsetY
        end
    end

    categories.partyraidframes = nil
    categories[C.Categories.CompactPartyAura] = nil
end

MCE.DurationTextColorDefaults = DurationTextColorDefaults
MCE.EnsureDurationTextColorConfig = EnsureDurationTextColorConfig
MCE.EnsureCompactPartyAuraTextConfig = EnsureCompactPartyAuraTextConfig

local cooldownManagerDefaults = CategoryDefaults(C.Categories.CooldownManager, false, 18)
cooldownManagerDefaults.essentialFontSize = C.Defaults.CooldownManager.EssentialFontSize
cooldownManagerDefaults.utilityFontSize = C.Defaults.CooldownManager.UtilityFontSize
cooldownManagerDefaults.buffIconFontSize = C.Defaults.CooldownManager.BuffIconFontSize

local miniCCDefaults = CategoryDefaults(C.Categories.MiniCC, false, 18)
miniCCDefaults.ccFontSize = C.Defaults.MiniCC.CCFontSize
miniCCDefaults.ccHideCountdownNumbers = C.Defaults.MiniCC.CCHideCountdownNumbers
miniCCDefaults.friendlyCdFontSize = C.Defaults.MiniCC.FriendlyCDFontSize
miniCCDefaults.friendlyCdHideCountdownNumbers = C.Defaults.MiniCC.FriendlyCDHideCountdownNumbers
miniCCDefaults.nameplateFontSize = C.Defaults.MiniCC.NameplateFontSize
miniCCDefaults.nameplateHideCountdownNumbers = C.Defaults.MiniCC.NameplateHideCountdownNumbers
miniCCDefaults.portraitFontSize = C.Defaults.MiniCC.PortraitFontSize
miniCCDefaults.portraitHideCountdownNumbers = C.Defaults.MiniCC.PortraitHideCountdownNumbers
miniCCDefaults.overlayFontSize = C.Defaults.MiniCC.OverlayFontSize
miniCCDefaults.overlayHideCountdownNumbers = C.Defaults.MiniCC.OverlayHideCountdownNumbers

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
    global = {
        versionAlertsShown = {},
    },
    profile = {
        abbrevThreshold = C.Options.DefaultAbbrevThreshold,
        shinyAurasAdapterEnabled = true,
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

    MigrateLegacyPartyRaidFramesConfig(profile)

    if profile.shinyAurasAdapterEnabled == nil then
        profile.shinyAurasAdapterEnabled = true
    end

    if profile.elvuiAdapterEnabled == nil then
        profile.elvuiAdapterEnabled = true
    end

    if not profile.durationTextColors then
        local legacyConfig = profile.categories
            and profile.categories[C.Categories.Actionbar]
            and profile.categories[C.Categories.Actionbar].textColorByDuration

        if type(legacyConfig) == "table" then
            profile.durationTextColors = CopyTable(legacyConfig)
        else
            profile.durationTextColors = CopyTable(defaultDurationTextColors)
        end
    end

    EnsureDurationTextColorConfig(profile.durationTextColors)
    profile.compactPartyAuraText = EnsureCompactPartyAuraTextConfig(profile.compactPartyAuraText)
end

function MCE:HandleProfileUpdated()
    if self.suppressProfileCallbacks then return end

    self:UpgradeProfile()
    self:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
end

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
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

    C.Addon.ShortName = L["MinimalistCooldownEdge"] -- 自行修改
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
