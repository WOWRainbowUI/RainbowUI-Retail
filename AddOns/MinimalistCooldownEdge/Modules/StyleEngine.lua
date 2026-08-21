-- StyleEngine.lua – Core visual style application for cooldown frames
--
-- Owns frameState / fontState helpers, text region discovery, font styling,
-- swipe/edge application, stack count styling, charge cooldown detection,
-- cooldown context resolution, and the main ApplyStyle entry point.
-- Duration colors are handled by DurationColorController.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local StyleEngine = MCE:NewModule("StyleEngine")

local type, pcall, wipe = type, pcall, wipe
local strfind = string.find
local select = select
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local issecretvalue = issecretvalue

local CATEGORY = C.Categories
local VIEWER_TYPE = C.CooldownManagerViewers
local MINIAURAS_FRAME_TYPE = C.MiniAurasFrameTypes
local SARENA_FRAME_TYPE = C.SArenaFrameTypes

local STYLER_CONSTANTS = C.Styler
local MINIAURAS_NATIVE_SWIPE_ALPHA = C.Adapter.MiniAuras.NativeSwipeAlpha
local LARGE_AURA_WIDTH_THRESHOLD = 20
local AURA_INSTANCE_ID_KEYS = {
    "auraInstanceID",
    "auraDataInstanceID",
    "auraInstanceId",
    "auraDataInstanceId",
}
local UNIT_TOKEN_KEYS = {
    "unitToken",
    "unit",
    "displayedUnit",
    "memberUnit",
    "auraDataUnit",
}
local NESTED_UNIT_TOKEN_KEYS = {
    "unitid",
    "unitID",
    "unitToken",
    "displayedUnit",
    "memberUnit",
    "unit",
}

-- Shared state from addon namespace
local frameState = addon.frameState
local fontState = addon.fontState
local hookedFontStrings = setmetatable({}, addon.weakMeta)
local actionbarTextOverlays = setmetatable({}, addon.weakMeta)
local actionbarTextOriginalParents = setmetatable({}, addon.weakMeta)

-- Lazy module references (resolved on first use in OnEnable)
local Registry, DurationColor, Classifier
local RestoreActionbarCooldownText
local GetParentSafe

-- Pre-computed style keys to avoid per-call string concatenation.
-- category x subtype combinations are a small fixed set.
local styleKeyCache = {}

local function GetStyleKey(category, subtype)
    if not subtype then return category end
    local catCache = styleKeyCache[category]
    if not catCache then
        catCache = {}
        styleKeyCache[category] = catCache
    end
    local key = catCache[subtype]
    if not key then
        key = category .. ":" .. subtype
        catCache[subtype] = key
    end
    return key
end

function StyleEngine:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    DurationColor = MCE:GetModule("DurationColorController")
    Classifier = MCE:GetModule("Classifier")
end

-- =========================================================================
-- SAFE VALUE HELPERS
-- =========================================================================

-- Re-export from shared addon namespace for external module access
StyleEngine.IsSecretValue = addon.IsSecretValue
StyleEngine.CanAccessAllValues = addon.CanAccessAllValues

local IsSecretValue = addon.IsSecretValue
local CanAccessAllValues = addon.CanAccessAllValues

local function GetAccessibleNumber(value)
    if IsSecretValue(value)
       or not CanAccessAllValues(value)
       or type(value) ~= "number" then
        return nil
    end
    return value
end

local function IsInspectableUIObject(value)
    local valueType = type(value)
    if valueType ~= "table" and valueType ~= "userdata" then
        return false
    end
    if IsSecretValue(value) or not CanAccessAllValues(value) then
        return false
    end
    return true
end

local function GetObjectTypeSafe(region)
    if not IsInspectableUIObject(region) then
        return nil
    end
    local getObjectType = MCE:SafeTableGet(region, "GetObjectType")
    if type(getObjectType) ~= "function" then
        return nil
    end
    local ok, objectType = pcall(getObjectType, region)
    if not ok then
        return nil
    end
    return MCE:GetNonSecretString(objectType)
end

local function IsUsableFontString(region)
    return GetObjectTypeSafe(region) == "FontString"
        and not MCE:IsForbiddenCached(region)
end

-- =========================================================================
-- FRAME STATE
-- =========================================================================

function StyleEngine:GetFrameState(frame)
    local s = frameState[frame]
    if not s then
        s = {}
        frameState[frame] = s
    end
    return s
end

function StyleEngine:GetFontState(region)
    local s = fontState[region]
    if not s then
        s = {}
        fontState[region] = s
    end
    return s
end

-- =========================================================================
-- NUMERIC COMPARISON
-- =========================================================================

local IsNearlyEqual = addon.IsNearlyEqual
local IsSameSwipeColor = addon.IsSameSwipeColor

local function IsMasqueManagedCooldown(cooldown)
    return cooldown and cooldown._MSQ_Color ~= nil
end

local IsMUIStyledCooldown = addon.IsMUIStyledCooldown

local function CaptureCountdownThresholdState(cdFrame, fs)
    if not cdFrame or not fs then
        return
    end

    if fs.originalCountdownAbbrevThreshold == nil
       and type(cdFrame.GetCountdownAbbrevThreshold) == "function" then
        local ok, seconds = pcall(cdFrame.GetCountdownAbbrevThreshold, cdFrame)
        if ok and type(seconds) == "number" then
            fs.originalCountdownAbbrevThreshold = seconds
        end
    end

    if fs.originalCountdownMillisecondsThreshold == nil
       and type(cdFrame.GetCountdownMillisecondsThreshold) == "function" then
        local ok, seconds = pcall(cdFrame.GetCountdownMillisecondsThreshold, cdFrame)
        if ok and type(seconds) == "number" then
            fs.originalCountdownMillisecondsThreshold = seconds
        end
    end
end

local function RestoreCountdownThresholdState(cdFrame, fs)
    if not cdFrame or not fs then
        return
    end

    if fs.originalCountdownAbbrevThreshold ~= nil
       and type(cdFrame.SetCountdownAbbrevThreshold) == "function"
       and fs.countdownAbbrevThreshold ~= nil
       and fs.countdownAbbrevThreshold ~= fs.originalCountdownAbbrevThreshold then
        fs.suppressCountdownAbbrevThreshold = true
        pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame, fs.originalCountdownAbbrevThreshold)
        fs.suppressCountdownAbbrevThreshold = nil
    end

    if fs.originalCountdownMillisecondsThreshold ~= nil
       and type(cdFrame.SetCountdownMillisecondsThreshold) == "function"
       and fs.countdownMillisecondsThreshold ~= nil
       and fs.countdownMillisecondsThreshold ~= fs.originalCountdownMillisecondsThreshold then
        fs.suppressCountdownMillisecondsThreshold = true
        pcall(cdFrame.SetCountdownMillisecondsThreshold, cdFrame, fs.originalCountdownMillisecondsThreshold)
        fs.suppressCountdownMillisecondsThreshold = nil
    end

    fs.originalCountdownAbbrevThreshold = nil
    fs.originalCountdownMillisecondsThreshold = nil
end

-- =========================================================================
-- UNIT / AURA HELPERS
-- =========================================================================

local function ExtractUnitToken(unit)
    local directToken = MCE:GetNonSecretString(unit)
    if directToken then
        return directToken
    end
    if type(unit) ~= "table"
       or IsSecretValue(unit)
       or not CanAccessAllValues(unit) then
        return nil
    end
    for i = 1, #NESTED_UNIT_TOKEN_KEYS do
        local token = MCE:GetNonSecretString(
            MCE:SafeTableGet(unit, NESTED_UNIT_TOKEN_KEYS[i]))
        if token then return token end
    end
    return nil
end

function StyleEngine:GetFrameUnitToken(frame)
    if not frame then return nil end
    for i = 1, #UNIT_TOKEN_KEYS do
        local token = ExtractUnitToken(MCE:SafeTableGet(frame, UNIT_TOKEN_KEYS[i]))
        if token then return token end
    end
    return nil
end

function StyleEngine:GetFrameAuraInstanceID(frame)
    if not frame then return nil end
    for i = 1, #AURA_INSTANCE_ID_KEYS do
        local value = MCE:SafeTableGet(frame, AURA_INSTANCE_ID_KEYS[i])
        value = GetAccessibleNumber(value)
        if value then return value end
    end
    return nil
end

-- WoW 12.1 turns aura data secret while combat, instance, or PvP restrictions
-- are active, so Blizzard aura items expose an unreadable auraInstanceID.
-- The strict reader above drops it, which also loses the owner frame it was
-- found on. Passing the raw handle through keeps owner resolution working;
-- callers must treat the value itself as opaque and only hand it to APIs.
function StyleEngine:GetFrameAuraInstanceIDValue(frame)
    if not frame then return nil end
    for i = 1, #AURA_INSTANCE_ID_KEYS do
        local value = MCE:SafeTableGet(frame, AURA_INSTANCE_ID_KEYS[i])
        if value ~= nil then return value end
    end
    return nil
end

local function GetCooldownInfoSafe(owner)
    if not owner then
        return nil
    end
    local getCooldownInfo = MCE:SafeTableGet(owner, "GetCooldownInfo")
    if type(getCooldownInfo) ~= "function" then
        return nil
    end

    local ok, info = pcall(getCooldownInfo, owner)
    if ok
       and not IsSecretValue(info)
       and CanAccessAllValues(info)
       and type(info) == "table" then
        return info
    end

    return nil
end

local function GetAccessibleBoolean(value)
    if IsSecretValue(value)
       or not CanAccessAllValues(value)
       or type(value) ~= "boolean" then
        return nil
    end
    return value == true
end

function StyleEngine:GetCooldownSpellID(owner)
    if not owner then return nil end
    local info = GetCooldownInfoSafe(owner)
    if info then
        local spellID = GetAccessibleNumber(MCE:SafeTableGet(info, "overrideSpellID"))
        if not spellID then
            spellID = GetAccessibleNumber(MCE:SafeTableGet(info, "spellID"))
        end
        if spellID then return spellID end
    end
    local getSpellID = MCE:SafeTableGet(owner, "GetSpellID")
    if type(getSpellID) == "function" then
        local ok, spellID = pcall(getSpellID, owner)
        spellID = ok and GetAccessibleNumber(spellID) or nil
        if spellID then return spellID end
    end
    return GetAccessibleNumber(MCE:SafeTableGet(owner, "spellID"))
end

function StyleEngine:IsCooldownManagerAuraDisplay(cdFrame)
    if not cdFrame then return false end
    if not Registry or Registry:GetCategory(cdFrame) ~= CATEGORY.CooldownManager then
        return false
    end

    local parent = GetParentSafe(cdFrame)
    if not parent or MCE:IsForbiddenCached(parent) then
        return false
    end

    return GetAccessibleBoolean(MCE:SafeTableGet(parent, "wasSetFromAura")) == true
end

function StyleEngine:IsCooldownManagerChargeDisplay(cdFrame, parent)
    if not cdFrame then return false end
    if not Registry or Registry:GetCategory(cdFrame) ~= CATEGORY.CooldownManager then
        return false
    end

    if not IsInspectableUIObject(parent) then
        parent = GetParentSafe(cdFrame)
    end
    if not parent or MCE:IsForbiddenCached(parent) then
        return false
    end

    local chargesShown = GetAccessibleBoolean(
        MCE:SafeTableGet(parent, "cooldownChargesShown"))
    if chargesShown ~= nil then
        return chargesShown
    end

    local spellID = self:GetCooldownSpellID(parent)
    if type(spellID) ~= "number" then
        return false
    end

    local ok, charges = pcall(C_Spell.GetSpellCharges, spellID)
    if not ok
       or IsSecretValue(charges)
       or not CanAccessAllValues(charges)
       or type(charges) ~= "table" then
        return false
    end

    local maxCharges = GetAccessibleNumber(MCE:SafeTableGet(charges, "maxCharges"))
    return maxCharges and maxCharges > 1 or false
end

-- =========================================================================
-- ACTION BAR HELPERS
-- =========================================================================

function StyleEngine:GetActionIDFromButton(parent)
    if not parent then return nil end
    local calculateAction = MCE:SafeTableGet(parent, "CalculateAction")
    if type(calculateAction) == "function" then
        local ok, actionID = pcall(calculateAction, parent)
        actionID = ok and GetAccessibleNumber(actionID) or nil
        if actionID then return actionID end
    end
    local actionID = GetAccessibleNumber(MCE:SafeTableGet(parent, "action"))
    if actionID then return actionID end
    local getAttribute = MCE:SafeTableGet(parent, "GetAttribute")
    if type(getAttribute) == "function" then
        local ok, attr = pcall(getAttribute, parent, "action")
        attr = ok and GetAccessibleNumber(attr) or nil
        if attr then return attr end
    end
    return nil
end

function StyleEngine:IsChargeCooldownFrame(cooldown, parent)
    if not cooldown or not parent then return false end
    return MCE:SafeTableGet(parent, "chargeCooldown") == cooldown
        or MCE:SafeTableGet(parent, "ChargeCooldown") == cooldown
end

function StyleEngine:IsMainCooldownWithActiveChargeCooldown(cdFrame)
    local parent = GetParentSafe(cdFrame)
    if not parent then return false end
    local mainCD = MCE:SafeTableGet(parent, "cooldown")
        or MCE:SafeTableGet(parent, "Cooldown")
    if mainCD ~= cdFrame then return false end
    local chargeCD = MCE:SafeTableGet(parent, "chargeCooldown")
        or MCE:SafeTableGet(parent, "ChargeCooldown")
    if not chargeCD or chargeCD == cdFrame or MCE:IsForbiddenCached(chargeCD) then
        return false
    end

    local isShown = MCE:SafeTableGet(chargeCD, "IsShown")
    if type(isShown) ~= "function" then return false end
    local ok, shown = pcall(isShown, chargeCD)
    return ok and GetAccessibleBoolean(shown) == true
end

function StyleEngine:IsAssistedCombatActionCooldown(cdFrame)
    if not cdFrame or not C_ActionBar or type(C_ActionBar.IsAssistedCombatAction) ~= "function" then
        return false
    end

    local fs = self:GetFrameState(cdFrame)
    local parent = GetParentSafe(cdFrame)
    if not parent or MCE:IsForbiddenCached(parent) then return false end

    local actionID = self:GetActionIDFromButton(parent)
    if not actionID then
        local context = self:ResolveCooldownContext(cdFrame)
        actionID = context and context.actionID ~= false and context.actionID or nil
    end

    if type(actionID) ~= "number" then
        fs.assistedCombatActionID = nil
        fs.assistedCombatAction = nil
        return false
    end

    if fs.assistedCombatActionID == actionID and fs.assistedCombatAction ~= nil then
        return fs.assistedCombatAction == true
    end

    local ok, isAssisted = pcall(C_ActionBar.IsAssistedCombatAction, actionID)
    fs.assistedCombatActionID = actionID
    fs.assistedCombatAction = ok and isAssisted == true or false
    return fs.assistedCombatAction
end

-- =========================================================================
-- COOLDOWN CONTEXT RESOLUTION
-- =========================================================================

local MAX_OWNER_SCAN_DEPTH = STYLER_CONSTANTS.MaxCooldownOwnerScanDepth

local function SyncResolvedActionContext(self, fs)
    if not fs then
        return
    end

    local actionButton = fs.actionButton ~= false and fs.actionButton or nil
    if not actionButton then
        return
    end

    local liveActionID = self:GetActionIDFromButton(actionButton)
    local cachedActionID = fs.actionID ~= false and fs.actionID or nil
    if liveActionID == cachedActionID then
        return
    end

    fs.actionID = liveActionID or false
    fs.durationObject = nil
    fs.appliedTextColor = nil
    fs.assistedCombatActionID = nil
    fs.assistedCombatAction = nil
end

function StyleEngine:ResolveCooldownContext(cdFrame, forceRefresh)
    local fs = self:GetFrameState(cdFrame)
    if fs.contextResolved and not forceRefresh then
        SyncResolvedActionContext(self, fs)
        return fs
    end

    local current = GetParentSafe(cdFrame)
    local actionButton, actionID
    local spellOwner, auraInstanceOwner, auraUnitOwner
    local compactPartyCenterDefensiveBuff = false
    local hasAuraNamedAncestor = false

    for _ = 1, MAX_OWNER_SCAN_DEPTH do
        if not current then break end

        if not actionButton then
            local resolvedActionID = self:GetActionIDFromButton(current)
            if resolvedActionID then
                actionButton = current
                actionID = resolvedActionID
            end
        end

        if not spellOwner and self:GetCooldownSpellID(current) ~= nil then
            spellOwner = current
        end

        if not auraInstanceOwner and self:GetFrameAuraInstanceIDValue(current) ~= nil then
            auraInstanceOwner = current
        end

        if not auraUnitOwner and self:GetFrameUnitToken(current) ~= nil then
            auraUnitOwner = current
        end

        if not compactPartyCenterDefensiveBuff then
            local parent = GetParentSafe(current)
            local centerDefensiveBuff = MCE:SafeTableGet(parent, "CenterDefensiveBuff")
            if MCE:CanUseFrameAsTableKey(centerDefensiveBuff)
               and centerDefensiveBuff == current then
                compactPartyCenterDefensiveBuff = true
                hasAuraNamedAncestor = true
            end
        end

        local name = MCE:GetFrameName(current) or ""
        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true) then
            hasAuraNamedAncestor = true
        end

        current = GetParentSafe(current)
    end

    fs.contextResolved = true
    fs.actionButton = actionButton or false
    fs.actionID = actionID or false
    fs.spellOwner = spellOwner or false
    fs.auraInstanceOwner = auraInstanceOwner or false
    fs.auraUnitOwner = auraUnitOwner or false
    fs.compactPartyCenterDefensiveBuff = compactPartyCenterDefensiveBuff or false
    fs.hasAuraNamedAncestor = hasAuraNamedAncestor or false
    return fs
end

-- =========================================================================
-- SWIPE / EDGE
-- =========================================================================

function StyleEngine:GetSwipeShadeAlpha(config)
    local alphaPercent = config and config.swipeAlpha
    if type(alphaPercent) ~= "number" then
        alphaPercent = STYLER_CONSTANTS.DefaultSwipeAlpha
    end
    if alphaPercent < STYLER_CONSTANTS.AlphaPercentMin then
        alphaPercent = STYLER_CONSTANTS.AlphaPercentMin
    elseif alphaPercent > STYLER_CONSTANTS.AlphaPercentMax then
        alphaPercent = STYLER_CONSTANTS.AlphaPercentMax
    end
    return alphaPercent / STYLER_CONSTANTS.AlphaPercentMax
end

function StyleEngine:ResetSwipeColor(cdFrame)
    if not cdFrame or type(cdFrame.SetSwipeColor) ~= "function" then return end
    local fs = frameState[cdFrame]
    if not fs or not fs.swipeColor then return end
    if IsMasqueManagedCooldown(cdFrame) or IsMUIStyledCooldown(cdFrame) then
        fs.swipeColor = nil
        return
    end
    fs.suppressSwipe = true
    pcall(cdFrame.SetSwipeColor, cdFrame, 0, 0, 0)
    fs.suppressSwipe = nil
    fs.swipeColor = nil
end

-- MiniAuras paints its swipe once, when it creates the cooldown, and never
-- re-applies it. The generic reset above would hand back Blizzard's opaque
-- default and visibly darken frames MiniCE no longer manages, so release
-- MiniAuras cooldowns to the provider's own value instead.
local function RestoreMiniAurasSwipeColor(cdFrame, fs)
    if not fs or not fs.swipeColor then return end
    local setSwipeColor = MCE:SafeTableGet(cdFrame, "SetSwipeColor")
    if type(setSwipeColor) ~= "function" then return end
    fs.suppressSwipe = true
    pcall(setSwipeColor, cdFrame, 0, 0, 0, MINIAURAS_NATIVE_SWIPE_ALPHA)
    fs.suppressSwipe = nil
end

local function SetMiniAurasDurationTextAlpha(fs, alpha)
    local durationText = fs and fs.miniAurasDurationText
    local setAlpha = durationText and MCE:SafeTableGet(durationText, "SetAlpha") or nil
    if type(setAlpha) ~= "function" then return false end

    fs.miniAurasSuppressDurationTextAlpha = true
    local ok = pcall(setAlpha, durationText, alpha)
    fs.miniAurasSuppressDurationTextAlpha = nil
    return ok
end

local function ReleaseMiniAurasNativeDurationText(cdFrame, fs)
    if not (fs and fs.miniAurasNativeDurationText == true) then return end

    fs.miniAurasNativeDurationTextActive = nil
    local requestedAlpha = fs.miniAurasRequestedDurationTextAlpha
    if type(requestedAlpha) == "number" then
        SetMiniAurasDurationTextAlpha(fs, requestedAlpha)
    end

    local requestedHide = fs.miniAurasRequestedHideCountdownNumbers
    if requestedHide ~= nil and type(MCE:SafeTableGet(cdFrame, "SetHideCountdownNumbers")) == "function" then
        fs.suppressHideNums = true
        pcall(cdFrame.SetHideCountdownNumbers, cdFrame, requestedHide == true)
        fs.suppressHideNums = nil
    end

    fs.miniAurasDurationTextHidden = nil
end

function StyleEngine:ReleaseManagedVisualState(cdFrame, category)
    local fs = self:GetFrameState(cdFrame)
    if fs.unitFrameNativeDurationText == true then
        local holder = fs.unitFrameDurationTextHolder
        local setAlpha = holder and MCE:SafeTableGet(holder, "SetAlpha") or nil
        if type(setAlpha) == "function" then
            pcall(setAlpha, holder, 0)
        end
        fs.unitFrameDurationTextHidden = true
    end
    if category == CATEGORY.MiniAuras then
        ReleaseMiniAurasNativeDurationText(cdFrame, fs)
        RestoreMiniAurasSwipeColor(cdFrame, fs)
    end
    RestoreCountdownThresholdState(cdFrame, fs)
    fs.edgeScale = nil
    fs.edgeColor = nil
    fs.reverseSwipe = nil
    fs.hideNums = nil
    fs.drawSwipe = nil
    fs.edge = nil
    fs.swipeColor = nil
    fs.appliedTextColor = nil
    fs.assistedCombatTextHidden = nil
    fs.countdownAbbrevThreshold = nil
    fs.countdownMillisecondsThreshold = nil

    if category == CATEGORY.Actionbar and RestoreActionbarCooldownText then
        RestoreActionbarCooldownText(self, cdFrame)
    end

    if category == CATEGORY.MiniAuras or category == CATEGORY.SArena then
        local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
        for i = 1, textRegionCount do
            fontState[textRegions[i]] = nil
        end
        fs.textRegions = nil
    end

    return fs
end

local DEFAULT_EDGE_COLOR = C.Colors.White

function StyleEngine:GetDesiredEdgeColor(cdFrame)
    local fs = frameState[cdFrame]
    if fs and fs.elvuiSupported then
        return DEFAULT_EDGE_COLOR
    end

    return nil
end

-- =========================================================================
-- TEXT REGION MANAGEMENT
-- =========================================================================

local textRegionScratch = {}

-- Retail action-button labels live in a high-level text container (level 500
-- in Blizzard's mixin). Draw-layer sublevels cannot cross frame boundaries,
-- so countdown text needs its own child frame above the label parents.
local ACTION_BUTTON_TEXT_FRAME_KEYS = { "TextOverlayContainer", "textOverlayContainer" }
local ACTION_BUTTON_TEXT_REGION_KEYS = {
    "HotKey", "hotkey",
    "Name", "name",
    "MacroName", "macroName",
    "Count", "count",
}

GetParentSafe = function(region)
    local getParent = MCE:SafeTableGet(region, "GetParent")
    if type(getParent) ~= "function" then return nil end
    local ok, parent = pcall(getParent, region)
    if not ok or not MCE:CanUseFrameAsTableKey(parent) then
        return nil
    end
    return parent
end

local function GetFrameLevelSafe(frame)
    local getFrameLevel = MCE:SafeTableGet(frame, "GetFrameLevel")
    if type(getFrameLevel) ~= "function" then return nil end
    local ok, level = pcall(getFrameLevel, frame)
    return ok and GetAccessibleNumber(level) or nil
end

local function IncludeFrameLevel(maxLevel, frame)
    local level = GetFrameLevelSafe(frame)
    if level and (not maxLevel or level > maxLevel) then
        return level
    end
    return maxLevel
end

local function GetActionButtonTextFrameLevel(button)
    local maxLevel = GetFrameLevelSafe(button)

    for i = 1, #ACTION_BUTTON_TEXT_FRAME_KEYS do
        local frame = MCE:SafeTableGet(button, ACTION_BUTTON_TEXT_FRAME_KEYS[i])
        maxLevel = IncludeFrameLevel(maxLevel, frame)
    end

    for i = 1, #ACTION_BUTTON_TEXT_REGION_KEYS do
        local region = MCE:SafeTableGet(button, ACTION_BUTTON_TEXT_REGION_KEYS[i])
        maxLevel = IncludeFrameLevel(maxLevel, GetParentSafe(region))
    end

    local buttonName = MCE:GetFrameName(button)
    if buttonName then
        maxLevel = IncludeFrameLevel(maxLevel, GetParentSafe(_G[buttonName .. "HotKey"]))
        maxLevel = IncludeFrameLevel(maxLevel, GetParentSafe(_G[buttonName .. "Name"]))
        maxLevel = IncludeFrameLevel(maxLevel, GetParentSafe(_G[buttonName .. "Count"]))
    end

    return maxLevel or 0
end

local function GetActionbarCooldownTextOverlay(cdFrame, button)
    local overlay = actionbarTextOverlays[cdFrame]
    if not overlay then
        if type(CreateFrame) ~= "function" then return nil end

        local ok, created = pcall(CreateFrame, "Frame", nil, cdFrame)
        if not ok or not created then return nil end

        overlay = created
        actionbarTextOverlays[cdFrame] = overlay

        if overlay.SetAllPoints then
            pcall(overlay.SetAllPoints, overlay, cdFrame)
        end
        if overlay.EnableMouse then
            pcall(overlay.EnableMouse, overlay, false)
        end
    end

    local targetLevel = GetActionButtonTextFrameLevel(button)
        + STYLER_CONSTANTS.ActionbarTextFrameLevelOffset
    if GetFrameLevelSafe(overlay) ~= targetLevel and overlay.SetFrameLevel then
        pcall(overlay.SetFrameLevel, overlay, targetLevel)
    end
    if overlay.Show then
        overlay:Show()
    end

    return overlay
end

local function RaiseActionbarCooldownText(cdFrame, button, textRegions, textRegionCount)
    if not button or not textRegionCount or textRegionCount == 0 then return false end

    local overlay = GetActionbarCooldownTextOverlay(cdFrame, button)
    if not overlay then return false end

    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and type(region.SetParent) == "function" then
            local currentParent = GetParentSafe(region)
            if currentParent ~= overlay then
                if not actionbarTextOriginalParents[region] then
                    actionbarTextOriginalParents[region] = currentParent
                end
                pcall(region.SetParent, region, overlay)
            end
        end
    end
    return true
end

RestoreActionbarCooldownText = function(self, cdFrame)
    local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
    for i = 1, textRegionCount do
        local region = textRegions[i]
        local originalParent = region and actionbarTextOriginalParents[region]
        if originalParent and type(region.SetParent) == "function" then
            pcall(region.SetParent, region, originalParent)
            actionbarTextOriginalParents[region] = nil
        end
    end

    local overlay = actionbarTextOverlays[cdFrame]
    if overlay and overlay.Hide then
        overlay:Hide()
    end

    local fs = frameState[cdFrame]
    if fs then
        fs.actionbarTextStructureApplied = nil
        fs.actionbarStackStyleApplied = nil
        fs.actionbarStackCountResolved = nil
        fs.actionbarStackCountRegion = nil
        fs.actionbarStackCountParent = nil
    end
end

local function FilterFontStringRegions(count, firstRegion, ...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region ~= firstRegion
           and IsUsableFontString(region) then
            count = count + 1
            textRegionScratch[count] = region
        end
    end
    return count
end

local function FilterFontStringRegionsFromCall(count, firstRegion, ok, ...)
    if not ok then return count end
    return FilterFontStringRegions(count, firstRegion, ...)
end

function StyleEngine:GetCooldownTextRegions(cdFrame)
    local count = 0
    local firstRegion = nil

    local state = frameState[cdFrame]

    -- A 12.1 MiniAuras aura button carries two countdown FontStrings: the bound
    -- duration text, and the cooldown widget's own. MiniAuras shows the bound one
    -- only for bars, colour-by-time or a milliseconds threshold, and parks it at
    -- alpha 0 otherwise - which is the default Group Auras / Raid Frame Auras case,
    -- where its native numbers are what is on screen.
    --
    -- Which one is live cannot be determined from Lua: alpha values on these buttons
    -- are secret, so the parked FontString reads identically to the drawn one, and
    -- GetHideCountdownNumbers does not settle it either. Style both instead - the
    -- configured size then lands on whichever MiniAuras actually draws.
    if state and state.miniAurasNativeDurationText == true then
        local regionCount = 0

        local nativeText = MCE:SafeTableGet(cdFrame, "MiniAurasFontString")
        if not IsUsableFontString(nativeText) then
            local getNativeText = MCE:SafeTableGet(cdFrame, "GetCountdownFontString")
            if type(getNativeText) == "function" then
                local ok, discovered = pcall(getNativeText, cdFrame)
                nativeText = ok and discovered or nil
            end
        end
        if IsUsableFontString(nativeText) then
            regionCount = regionCount + 1
            textRegionScratch[regionCount] = nativeText
        end

        local durationText = state.miniAurasDurationText
        if IsUsableFontString(durationText) and durationText ~= nativeText then
            regionCount = regionCount + 1
            textRegionScratch[regionCount] = durationText
        end

        if regionCount > 0 then
            for i = regionCount + 1, #textRegionScratch do
                textRegionScratch[i] = nil
            end
            return textRegionScratch, regionCount
        end
    end

    if state and state.unitFrameCustomAura == true then
        local countdownText = state.unitFrameCountdownText
        if not IsUsableFontString(countdownText) then
            local trackedRegions = state.textRegions
            if trackedRegions and (trackedRegions.count or 0) > 0 then
                countdownText = trackedRegions[1]
            end
        end

        -- CustomAuraContainer applies access restrictions after its public
        -- initialize callback. The retained output FontString stays usable,
        -- while querying the cooldown for it later can be forbidden in combat.
        if IsUsableFontString(countdownText) then
            textRegionScratch[1] = countdownText
            for i = 2, #textRegionScratch do
                textRegionScratch[i] = nil
            end
            return textRegionScratch, 1
        end

        for i = 1, #textRegionScratch do
            textRegionScratch[i] = nil
        end
        return textRegionScratch, 0
    end

    -- Shackled hides Blizzard's own countdown numbers and draws its own
    -- remaining-time FontString on a sibling frame instead, so the generic
    -- GetRegions() scan below (which only looks at cdFrame's own regions) would
    -- never find it. The adapter resolves it via a cheap structural lookup
    -- (icon.timeText); cache the result since nothing else on this plain,
    -- non-secret frame tree can invalidate it.
    if Registry and Registry:GetCategory(cdFrame) == CATEGORY.Shackled then
        local durationText = state and state.shackledDurationText
        if not IsUsableFontString(durationText) then
            local adapter = Registry:GetAdapter(CATEGORY.Shackled)
            local resolve = adapter and adapter.ResolveDurationText
            if type(resolve) == "function" then
                local ok, resolved = pcall(resolve, adapter, cdFrame)
                if ok and IsUsableFontString(resolved) then
                    durationText = resolved
                    if state then state.shackledDurationText = resolved end
                end
            end
        end

        for i = 1, #textRegionScratch do textRegionScratch[i] = nil end
        if IsUsableFontString(durationText) then
            textRegionScratch[1] = durationText
            return textRegionScratch, 1
        end
        return textRegionScratch, 0
    end

    -- MyDRs parents its DR state label ("50%" / "IMM") to the cooldown itself.
    -- Restrict styling to the countdown FontString so that label keeps MyDRs'
    -- own font, anchor, and text.
    if Registry and Registry:GetCategory(cdFrame) == CATEGORY.MyDRs then
        local getMyDRsCountdown = MCE:SafeTableGet(cdFrame, "GetCountdownFontString")
        if type(getMyDRsCountdown) == "function" then
            local ok, countdownText = pcall(getMyDRsCountdown, cdFrame)
            if ok and IsUsableFontString(countdownText) then
                textRegionScratch[1] = countdownText
                for i = 2, #textRegionScratch do
                    textRegionScratch[i] = nil
                end
                return textRegionScratch, 1
            end
        end

        for i = 1, #textRegionScratch do
            textRegionScratch[i] = nil
        end
        return textRegionScratch, 0
    end

    -- MiniAuras caches its countdown FontString on the cooldown frame after the
    -- first size update. Reuse that reference so repeated MiniAuras style passes
    -- do not rescan every region on the frame.
    local miniAurasCountdownText = MCE:SafeTableGet(cdFrame, "MiniAurasFontString")
    if IsUsableFontString(miniAurasCountdownText) then
        textRegionScratch[1] = miniAurasCountdownText
        for i = 2, #textRegionScratch do
            textRegionScratch[i] = nil
        end
        return textRegionScratch, 1
    end

    local getCountdownFontString = MCE:SafeTableGet(cdFrame, "GetCountdownFontString")
    if type(getCountdownFontString) == "function" then
        local ok, countdownText = pcall(getCountdownFontString, cdFrame)
        if ok and IsUsableFontString(countdownText) then
            count = 1
            textRegionScratch[1] = countdownText
            firstRegion = countdownText
        end
    end

    local getRegions = MCE:SafeTableGet(cdFrame, "GetRegions")
    if type(getRegions) == "function" then
        count = FilterFontStringRegionsFromCall(
            count, firstRegion, pcall(getRegions, cdFrame))
    end

    for i = count + 1, #textRegionScratch do
        textRegionScratch[i] = nil
    end

    return textRegionScratch, count
end

local function HaveCooldownTextRegionsChanged(fs, textRegions, textRegionCount)
    local trState = fs.textRegions
    if not trState then
        trState = {}
        fs.textRegions = trState
    end

    local changed = (trState.count ~= textRegionCount)
    for i = 1, textRegionCount do
        if trState[i] ~= textRegions[i] then changed = true end
        trState[i] = textRegions[i]
    end
    for i = textRegionCount + 1, trState.count or 0 do
        trState[i] = nil
    end
    trState.count = textRegionCount
    return changed
end

local function GetTrackedTextRegionCount(fs)
    local trackedRegions = fs and fs.textRegions
    return trackedRegions and trackedRegions.count or 0
end

function StyleEngine:GetCachedCooldownTextRegions(cdFrame)
    local fs = frameState[cdFrame]
    local trackedRegions = fs and fs.textRegions
    if trackedRegions and (trackedRegions.count or 0) > 0 then
        return trackedRegions, trackedRegions.count
    end

    local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
    if not fs then fs = self:GetFrameState(cdFrame) end
    HaveCooldownTextRegionsChanged(fs, textRegions, textRegionCount)

    trackedRegions = fs.textRegions
    if trackedRegions then
        return trackedRegions, trackedRegions.count or 0
    end
    return textRegions, textRegionCount
end

function StyleEngine:SetCooldownTextRegionsVisible(cdFrame, visible)
    local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and not MCE:IsForbiddenCached(region) then
            if visible then
                region:SetAlpha(1)
                region:Show()
            else
                region:SetAlpha(0)
                region:Hide()
            end
        end
    end
end

-- =========================================================================
-- TEXT COLOR APPLICATION
-- =========================================================================

function StyleEngine:ApplyRGBAColorToCooldownRegions(cdFrame, r, g, b, a)
    local textRegions, textRegionCount = self:GetCachedCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    local fs = self:GetFrameState(cdFrame)
    if IsSameSwipeColor(fs.appliedTextColor, r, g, b, a) then return true end

    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and not MCE:IsForbiddenCached(region) then
            -- Duration curves evaluated from secret aura data return secret
            -- colour components. FontStrings accept them, but the call is
            -- guarded so a restricted region cannot abort the style pass.
            pcall(region.SetTextColor, region, r, g, b, a)
        end
    end

    local applied = fs.appliedTextColor or {}
    applied.r, applied.g, applied.b, applied.a = r, g, b, a
    fs.appliedTextColor = applied
    return true
end

function StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, color)
    if not color then return false end
    return self:ApplyRGBAColorToCooldownRegions(cdFrame, color.r, color.g, color.b, color.a)
end

function StyleEngine:ResetCountdownTextColor(cdFrame, config)
    local tc = config and config.textColor
    if not tc then return false end
    return self:ApplyTextColorToCooldownRegions(cdFrame, tc)
end

-- =========================================================================
-- FONT STRING STYLING
-- =========================================================================

local function EnsureFontStringSetFontHook(region)
    local fs = fontState[region]
    if not fs then
        fs = {}
        fontState[region] = fs
    end
    if hookedFontStrings[region] or not region.SetFont then return end

    hooksecurefunc(region, "SetFont", function(self, fontPath, fontSize, fontStyle)
        if issecretvalue(self) or issecretvalue(fontPath) then return end
        local s = fontState[self]
        if not s or s.suppressSetFont or not s.enforceFont then return end

        local desiredFontSize = s.fontSize
        if s.preserveFontSize and type(fontSize) == "number" then
            desiredFontSize = fontSize
            s.fontSize = fontSize
        end

        if (not issecretvalue(fontPath) and fontPath == s.fontPath)
           and IsNearlyEqual(fontSize, desiredFontSize)
           and (not issecretvalue(fontStyle) and fontStyle == s.fontStyle) then
            return
        end
        s.suppressSetFont = true
        pcall(self.SetFont, self, s.fontPath, desiredFontSize, s.fontStyle)
        s.suppressSetFont = nil
    end)

    if type(region.SetTextColor) == "function" then
        hooksecurefunc(region, "SetTextColor", function(self, r, g, b, a)
            if issecretvalue(self) or issecretvalue(r) or issecretvalue(g)
               or issecretvalue(b) or issecretvalue(a) then
                return
            end
            local s = fontState[self]
            if not s or s.suppressSetTextColor or not s.enforceColor then return end
            if IsNearlyEqual(r, s.colorR) and IsNearlyEqual(g, s.colorG)
               and IsNearlyEqual(b, s.colorB) and IsNearlyEqual(a, s.colorA) then
                return
            end

            s.suppressSetTextColor = true
            pcall(self.SetTextColor, self,
                s.colorR, s.colorG, s.colorB, s.colorA)
            s.suppressSetTextColor = nil
        end)
    end

    hookedFontStrings[region] = true
end

local function GetCurrentFontSize(region, fallback)
    if not region or MCE:IsForbiddenCached(region) or type(region.GetFont) ~= "function" then
        return fallback
    end

    local ok, _, fontSize = pcall(region.GetFont, region)
    if ok and type(fontSize) == "number" then
        return fontSize
    end

    return fallback
end

function StyleEngine:ApplyFontStringStyle(region, relativeFrame, fontPath, fontSize, fontStyle,
                                          color, point, relativePoint, offsetX, offsetY,
                                      drawLayer, drawLayerSubLevel, enforceFont, preserveFontSize,
                                      enforceColor)
    if not region or MCE:IsForbiddenCached(region) then return end

    relativePoint = relativePoint or point
    drawLayerSubLevel = drawLayerSubLevel or 0

    local state = self:GetFontState(region)
    state.enforceFont = enforceFont or false
    state.enforceColor = enforceColor or false
    state.preserveFontSize = preserveFontSize or false
    if state.enforceFont or state.enforceColor then
        EnsureFontStringSetFontHook(region)
    end

    if state.fontPath ~= fontPath
       or state.fontSize ~= fontSize
       or state.fontStyle ~= fontStyle then
        state.suppressSetFont = true
        region:SetFont(fontPath, fontSize, fontStyle)
        state.suppressSetFont = nil
        state.fontPath = fontPath
        state.fontSize = fontSize
        state.fontStyle = fontStyle
    end

    if color then
        if state.colorR ~= color.r or state.colorG ~= color.g
           or state.colorB ~= color.b or state.colorA ~= color.a then
            state.suppressSetTextColor = true
            region:SetTextColor(color.r, color.g, color.b, color.a)
            state.suppressSetTextColor = nil
            state.colorR, state.colorG, state.colorB, state.colorA = color.r, color.g, color.b, color.a
        end
    end

    if point and relativeFrame then
        if state.point ~= point or state.relativeFrame ~= relativeFrame
           or state.relativePoint ~= relativePoint
           or state.offsetX ~= offsetX or state.offsetY ~= offsetY then
            region:ClearAllPoints()
            region:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
            state.point = point
            state.relativeFrame = relativeFrame
            state.relativePoint = relativePoint
            state.offsetX = offsetX
            state.offsetY = offsetY
        end
    end

    if drawLayer and region.SetDrawLayer then
        if state.drawLayer ~= drawLayer or state.drawLayerSubLevel ~= drawLayerSubLevel then
            -- Restricted aura output regions can refuse layer changes. Keep
            -- the cached state untouched so a later pass retries.
            if pcall(region.SetDrawLayer, region, drawLayer, drawLayerSubLevel) then
                state.drawLayer = drawLayer
                state.drawLayerSubLevel = drawLayerSubLevel
            end
        end
    end
end

-- =========================================================================
-- STACK COUNT STYLING
-- =========================================================================

local function ResolveCountRegion(container)
    if not container or MCE:IsForbiddenCached(container) then return nil end

    local region = MCE:SafeTableGet(container, "Count")
        or MCE:SafeTableGet(container, "count")
        or MCE:SafeTableGet(container, "StackCount")
        or MCE:SafeTableGet(container, "stackCount")
    if IsUsableFontString(region) then
        return region
    end

    local containerName = MCE:GetFrameName(container)
    if containerName then
        region = _G[containerName .. "Count"] or _G[containerName .. "StackCount"]
        if IsUsableFontString(region) then
            return region
        end
    end

    return nil
end

local function GetStackCountRegion(cdFrame, category)
    local state = frameState[cdFrame]
    if category == CATEGORY.Actionbar
       and state and state.actionbarStackCountResolved == true then
        local cachedRegion = state.actionbarStackCountRegion
        local cachedParent = state.actionbarStackCountParent
        return cachedRegion ~= false and cachedRegion or nil,
            cachedParent ~= false and cachedParent or nil
    end

    -- MiniAuras registers its stack count on the aura button, which goes
    -- restricted after initialization, so the region is captured by the adapter
    -- rather than looked up here. Without this branch the count fell through
    -- every case below and kept MiniAuras' own icon-derived size for good.
    if category == CATEGORY.MiniAuras
       and state and IsUsableFontString(state.miniAurasStackText) then
        return state.miniAurasStackText, cdFrame
    end

    if category == CATEGORY.Unitframe
       and state and IsUsableFontString(state.unitFrameCount) then
        -- WoW 12.1 custom AuraButtons become inaccessible while auras are
        -- secret. Their public count FontString is captured at initialization,
        -- so style it without inspecting the restricted parent button.
        return state.unitFrameCount, cdFrame
    end

    local parent = GetParentSafe(cdFrame)
    if not parent then
        if category == CATEGORY.Actionbar then
            state = state or {}
            frameState[cdFrame] = state
            state.actionbarStackCountResolved = true
            state.actionbarStackCountRegion = false
            state.actionbarStackCountParent = false
        end
        return nil, nil
    end
    local countRegion

    if category == CATEGORY.Actionbar then
        countRegion = ResolveCountRegion(parent)
    elseif category == CATEGORY.Nameplate
           or category == CATEGORY.Unitframe then
        local countFrame = MCE:SafeTableGet(parent, "CountFrame")
            or MCE:SafeTableGet(parent, "countFrame")
        countRegion = ResolveCountRegion(countFrame) or ResolveCountRegion(parent)
    elseif category == CATEGORY.CooldownManager then
        local chargeCount = MCE:SafeTableGet(parent, "ChargeCount")
        if chargeCount then
            countRegion = MCE:SafeTableGet(chargeCount, "Current")
        end
        if not countRegion then
            local applications = MCE:SafeTableGet(parent, "Applications")
            if applications then
                countRegion = MCE:SafeTableGet(applications, "Applications")
            end
        end
    end

    if category == CATEGORY.Actionbar then
        state = state or {}
        frameState[cdFrame] = state
        state.actionbarStackCountResolved = true
        state.actionbarStackCountRegion = IsUsableFontString(countRegion) and countRegion or false
        state.actionbarStackCountParent = parent
    end

    if not IsUsableFontString(countRegion) then return nil, parent end
    return countRegion, parent
end

function StyleEngine:GetStackCountRegion(cdFrame, category)
    return GetStackCountRegion(cdFrame, category)
end

function StyleEngine:GetStackFontSize(cdFrame, category, config, subtype)
    if category == CATEGORY.CooldownManager then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if subtype == VIEWER_TYPE.Essential then return config.essentialStackSize or config.stackSize end
        if subtype == VIEWER_TYPE.Utility then return config.utilityStackSize or config.stackSize end
        if subtype == VIEWER_TYPE.BuffIcon then return config.buffIconStackSize or config.stackSize end
    end

    return config.stackSize
end

function StyleEngine:StyleStackCount(cdFrame, config, category)
    local fs = self:GetFrameState(cdFrame)
    if category == CATEGORY.Actionbar and fs.actionbarStackStyleApplied == true then
        return
    end

    local countRegion, parent = self:GetStackCountRegion(cdFrame, category)
    if not countRegion or not parent then
        if category == CATEGORY.Actionbar then
            fs.actionbarStackStyleApplied = true
        end
        return
    end

    local isCustomUnitFrameAura = category == CATEGORY.Unitframe
        and fs.unitFrameCustomAura == true

    if config.hideStackText then
        if not fs.stackCountHidden then
            countRegion:SetAlpha(0)
            -- SetApplicationCount owns the Shown aspect on 12.1 custom aura
            -- buttons. Alpha remains addon-controlled; Show/Hide does not.
            if not isCustomUnitFrameAura then
                countRegion:Hide()
            end
            fs.stackCountHidden = true
        end
        if category == CATEGORY.Actionbar then
            fs.actionbarStackStyleApplied = true
        end
        return
    end

    if fs.stackCountHidden then
        countRegion:SetAlpha(1)
        if not isCustomUnitFrameAura then
            countRegion:Show()
        end
        fs.stackCountHidden = nil
    elseif isCustomUnitFrameAura then
        -- WipeState deliberately discards transient style flags. Explicitly
        -- restore alpha when Hide Stack Text is turned off after a refresh.
        countRegion:SetAlpha(1)
    end

    if not config.stackEnabled then
        if category == CATEGORY.Actionbar then
            fs.actionbarStackStyleApplied = true
        end
        return
    end

    if isCustomUnitFrameAura and type(countRegion.SetScale) == "function" then
        pcall(countRegion.SetScale, countRegion, 1)
    end

    if category ~= CATEGORY.Nameplate
       and category ~= CATEGORY.Unitframe then
        countRegion:SetAlpha(1)
        countRegion:Show()
    end

    -- MiniAuras re-derives this font from the icon size on every restyle pass,
    -- so the chosen size has to be enforced the way the countdown font is.
    local enforceStackFont = category == CATEGORY.MiniAuras

    self:ApplyFontStringStyle(
        countRegion, parent,
        MCE.ResolveFontPath(config.stackFont),
        self:GetStackFontSize(cdFrame, category, config),
        MCE.NormalizeFontStyle(config.stackStyle),
        config.stackColor,
        config.stackAnchor, config.stackAnchor,
        config.stackOffsetX, config.stackOffsetY,
        STYLER_CONSTANTS.StackTextLayer,
        STYLER_CONSTANTS.StackTextSubLevel,
        enforceStackFont)

    if category == CATEGORY.Actionbar then
        fs.actionbarStackStyleApplied = true
    end
end

-- =========================================================================
-- FONT SIZE RESOLUTION
-- =========================================================================

function StyleEngine:GetCooldownFontSize(cdFrame, category, config, subtype)
    if category == CATEGORY.MiniAuras then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if subtype == MINIAURAS_FRAME_TYPE.CC then return config.ccFontSize or config.fontSize end
        if subtype == MINIAURAS_FRAME_TYPE.RaidFrameAura then return config.raidFrameAuraFontSize or config.fontSize end
        if subtype == MINIAURAS_FRAME_TYPE.LegacyEnemyCD then return config.enemyCdFontSize or config.overlayFontSize or config.fontSize end
        if subtype == MINIAURAS_FRAME_TYPE.LegacyFriendlyCD then return config.friendlyCdFontSize or config.raidFrameAuraFontSize or config.fontSize end
        if subtype == MINIAURAS_FRAME_TYPE.Portrait then return config.portraitFontSize or config.fontSize end
        if subtype == MINIAURAS_FRAME_TYPE.Overlay then return config.overlayFontSize or config.fontSize end
        return config.fontSize
    end

    if category == CATEGORY.SArena then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if subtype == SARENA_FRAME_TYPE.ClassIcon then return config.classIconFontSize or config.fontSize end
        if subtype == SARENA_FRAME_TYPE.DR then return config.drFontSize or config.fontSize end
        if subtype == SARENA_FRAME_TYPE.Trinket or subtype == SARENA_FRAME_TYPE.Racial then
            return config.trinketRacialFontSize or config.fontSize
        end
        return config.fontSize
    end

    if category == CATEGORY.CooldownManager then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if subtype == VIEWER_TYPE.Essential then return config.essentialFontSize or config.fontSize end
        if subtype == VIEWER_TYPE.Utility then return config.utilityFontSize or config.fontSize end
        if subtype == VIEWER_TYPE.BuffIcon then return config.buffIconFontSize or config.fontSize end
        return config.fontSize
    end

    return config.fontSize
end

-- =========================================================================
-- HIDE COUNTDOWN NUMBERS RESOLUTION
-- =========================================================================

local function GetTellMeWhenTimerOption(cdFrame, optionKey)
    local adapter = Registry and Registry:GetAdapter(CATEGORY.TellMeWhen) or nil
    local getter = adapter and adapter.GetTimerOption or nil
    if type(getter) ~= "function" then return nil end

    local ok, value = pcall(getter, adapter, cdFrame, optionKey)
    if ok and type(value) == "boolean" then
        return value
    end
    return nil
end

function StyleEngine:GetDesiredHideCountdownNumbers(cdFrame, category, config, isAssistedCombat, subtype)
    if category == CATEGORY.TellMeWhen then
        return GetTellMeWhenTimerOption(cdFrame, "hideCountdownNumbers")
    end

    local hideNums = config.hideCountdownNumbers

    if category == CATEGORY.MiniAuras then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if subtype == MINIAURAS_FRAME_TYPE.CC then
            return config.ccHideCountdownNumbers ~= nil and config.ccHideCountdownNumbers or hideNums
        end
        if subtype == MINIAURAS_FRAME_TYPE.RaidFrameAura then
            return config.raidFrameAuraHideCountdownNumbers ~= nil and config.raidFrameAuraHideCountdownNumbers or hideNums
        end
        if subtype == MINIAURAS_FRAME_TYPE.LegacyEnemyCD then
            return config.enemyCdHideCountdownNumbers ~= nil and config.enemyCdHideCountdownNumbers or hideNums
        end
        if subtype == MINIAURAS_FRAME_TYPE.LegacyFriendlyCD then
            return config.friendlyCdHideCountdownNumbers ~= nil and config.friendlyCdHideCountdownNumbers or hideNums
        end
        if subtype == MINIAURAS_FRAME_TYPE.Portrait then
            return config.portraitHideCountdownNumbers ~= nil and config.portraitHideCountdownNumbers or hideNums
        end
        if subtype == MINIAURAS_FRAME_TYPE.Overlay then
            return config.overlayHideCountdownNumbers ~= nil and config.overlayHideCountdownNumbers or hideNums
        end
        return hideNums
    end

    -- MyDRs owns whether its DR icons show countdown numbers at all, so its
    -- own "Show countdown text" toggle stays authoritative when it is off.
    if category == CATEGORY.MyDRs and not hideNums then
        local adapter = Registry and Registry:GetAdapter(CATEGORY.MyDRs) or nil
        local getter = adapter and adapter.IsCountdownTextEnabled or nil
        if type(getter) == "function" then
            local ok, enabled = pcall(getter, adapter)
            if ok and enabled == false then
                return true
            end
        end
    end

    if category == CATEGORY.Actionbar and isAssistedCombat then
        return true
    end

    if category == CATEGORY.Actionbar and not hideNums then
        local parent = GetParentSafe(cdFrame)
        local isChargeCooldown = self:IsChargeCooldownFrame(cdFrame, parent)
        if config.hideChargeTimers and isChargeCooldown then
            hideNums = true
        elseif not config.hideChargeTimers
               and self:IsMainCooldownWithActiveChargeCooldown(cdFrame) then
            hideNums = true
        end
    end

    if category == CATEGORY.Unitframe and not hideNums and config.auraCdTextOnlyMine then
        local isLargeAura = self:IsUnitFrameLargeAura(cdFrame)
        if isLargeAura ~= nil then
            return not isLargeAura
        end
    end

    return hideNums
end

-- =========================================================================
-- DRAW SWIPE RESOLUTION
-- =========================================================================

local function GetMiniAurasHideSwipeSetting(config, subtype)
    if subtype == MINIAURAS_FRAME_TYPE.CC then
        return config.ccHideSwipe
    end
    if subtype == MINIAURAS_FRAME_TYPE.RaidFrameAura then
        return config.raidFrameAuraHideSwipe
    end
    if subtype == MINIAURAS_FRAME_TYPE.LegacyEnemyCD then
        return config.enemyCdHideSwipe
    end
    if subtype == MINIAURAS_FRAME_TYPE.LegacyFriendlyCD then
        return config.friendlyCdHideSwipe
    end
    if subtype == MINIAURAS_FRAME_TYPE.Portrait then
        return config.portraitHideSwipe
    end
    if subtype == MINIAURAS_FRAME_TYPE.Overlay then
        return config.overlayHideSwipe
    end
    return nil
end

function StyleEngine:GetDesiredDrawSwipe(cdFrame, category, config, isChargeCooldown, hasActiveCharge, subtype)
    if category == CATEGORY.TellMeWhen then
        return GetTellMeWhenTimerOption(cdFrame, "drawSwipe")
    end

    local baseWant = config.drawSwipe ~= false

    if baseWant and category == CATEGORY.MiniAuras then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if GetMiniAurasHideSwipeSetting(config, subtype) then
            baseWant = false
        end
    end

    return baseWant and (not isChargeCooldown or hasActiveCharge)
end

function StyleEngine:GetDesiredEdgeEnabled(cdFrame, category, config, subtype)
    -- Charge recovery is represented by a dedicated cooldown frame. Keep its
    -- progress edge visible even when regular action-bar edges are disabled.
    if category == CATEGORY.Actionbar then
        local parent = GetParentSafe(cdFrame)
        if self:IsChargeCooldownFrame(cdFrame, parent) then
            return true
        end
    end

    if not config.edgeEnabled then return false end

    if category == CATEGORY.MiniAuras then
        subtype = subtype or (Registry and Registry:GetSubtype(cdFrame))
        if GetMiniAurasHideSwipeSetting(config, subtype) then return false end
    end

    return true
end

-- =========================================================================
-- UNIT FRAME LARGE AURA
-- =========================================================================

function StyleEngine:IsUnitFrameLargeAura(cdFrame)
    local trackedState = frameState[cdFrame]
    if trackedState and trackedState.unitFrameAuraIsMine ~= nil then
        return trackedState.unitFrameAuraIsMine == true
    end

    local fs = self:ResolveCooldownContext(cdFrame)
    -- Preserve pre-refactor behavior: once a cooldown is already classified as a
    -- unit-frame aura, the "Only Mine" heuristic should still run even if the
    -- current parent chain does not expose Buff/Debuff/Aura in frame names.
    if not fs.hasAuraNamedAncestor then
        local category = Registry and Registry:GetCategory(cdFrame)
        if category ~= CATEGORY.Unitframe then
            return nil
        end
    end

    local auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
    if not auraOwner then
        local parent = GetParentSafe(cdFrame)
        if parent and not MCE:IsForbiddenCached(parent) then
            auraOwner = parent
        else
            return nil
        end
    end

    local auraInstanceID = self:GetFrameAuraInstanceID(auraOwner)
    if auraInstanceID
       and fs.auraTextOnlyMineInstanceID == auraInstanceID
       and fs.isLargeAura ~= nil then
        return fs.isLargeAura == true
    end

    local getWidth = MCE:SafeTableGet(auraOwner, "GetWidth")
    if type(getWidth) ~= "function" then return nil end

    local ok, width = pcall(getWidth, auraOwner)
    width = ok and GetAccessibleNumber(width) or nil
    if not width then return nil end
    if width <= 0 then return nil end

    local isLargeAura = width > LARGE_AURA_WIDTH_THRESHOLD
    if auraInstanceID then
        fs.auraTextOnlyMineInstanceID = auraInstanceID
        fs.isLargeAura = isLargeAura
    end
    return isLargeAura
end

-- =========================================================================
-- MAIN STYLE APPLICATION
-- =========================================================================

function StyleEngine:ApplyStyle(cdFrame, forcedCategory)
    if MCE:IsForbiddenCached(cdFrame) then return end

    -- Check blacklist
    local trackedState = frameState[cdFrame]
    if not (trackedState and trackedState.allowBlacklisted == true)
       and Classifier and Classifier:IsBlacklisted(cdFrame) then
        return
    end

    -- Get category from registry
    local category = forcedCategory
    if not category then
        category = Registry and Registry:GetCategory(cdFrame)
    end
    if not category then return end

    -- Override: MiniAuras takes precedence when detected
    local subtype = Registry and Registry:GetSubtype(cdFrame) or nil
    if forcedCategory == CATEGORY.Nameplate and subtype then
        if subtype == MINIAURAS_FRAME_TYPE.CC or subtype == MINIAURAS_FRAME_TYPE.RaidFrameAura
           or subtype == MINIAURAS_FRAME_TYPE.LegacyEnemyCD
           or subtype == MINIAURAS_FRAME_TYPE.LegacyFriendlyCD
           or subtype == MINIAURAS_FRAME_TYPE.Portrait or subtype == MINIAURAS_FRAME_TYPE.Overlay then
            category = CATEGORY.MiniAuras
        end
    end

    -- Guard: DB must be ready
    if not (MCE.db and MCE.db.profile and MCE.db.profile.categories) then return end

    local config = MCE.db.profile.categories[category]

    if not config or not MCE:IsCategoryActive(category, config) then
        if DurationColor then
            DurationColor:ClearTrackedDurationColor(cdFrame)
        end
        self:ReleaseManagedVisualState(cdFrame, category)
        return
    end

    -- Resolved below the enabled guard: the release branch above never reads it,
    -- and IsAssistedCombatActionCooldown walks the parent chain for the action ID.
    local isAssistedCombat = (category == CATEGORY.Actionbar and self:IsAssistedCombatActionCooldown(cdFrame))

    local fs = self:GetFrameState(cdFrame)
    local parent = GetParentSafe(cdFrame)

    local isChargeCooldown = self:IsChargeCooldownFrame(cdFrame, parent)
    local hasActiveCharge = isChargeCooldown and self:IsMainCooldownWithActiveChargeCooldown(cdFrame)

    -- Draw Swipe
    local wantSwipe = self:GetDesiredDrawSwipe(cdFrame, category, config, isChargeCooldown, hasActiveCharge, subtype)
    if wantSwipe ~= nil and cdFrame.SetDrawSwipe then
        if fs.drawSwipe ~= wantSwipe then
            fs.suppressSwipeDraw = true
            pcall(cdFrame.SetDrawSwipe, cdFrame, wantSwipe)
            fs.suppressSwipeDraw = nil
            fs.drawSwipe = wantSwipe
        end
    elseif category == CATEGORY.TellMeWhen then
        fs.drawSwipe = nil
    end

    -- Reverse Swipe
    if (category == CATEGORY.Actionbar or category == CATEGORY.MyDRs
        or category == CATEGORY.Shackled) and cdFrame.SetReverse then
        local wantReverse = config.reverseSwipe == true
        if fs.reverseSwipe ~= wantReverse then
            fs.suppressReverseSwipe = true
            pcall(cdFrame.SetReverse, cdFrame, wantReverse)
            fs.suppressReverseSwipe = nil
            fs.reverseSwipe = wantReverse
        end
    end

    -- Draw Edge
    local wantEdge = self:GetDesiredEdgeEnabled(cdFrame, category, config, subtype)
    if wantEdge ~= nil and cdFrame.SetDrawEdge then
        if fs.edge ~= wantEdge then
            fs.suppressEdge = true
            pcall(cdFrame.SetDrawEdge, cdFrame, wantEdge)
            fs.suppressEdge = nil
            fs.edge = wantEdge
        end
        if wantEdge and cdFrame.SetEdgeScale then
            if fs.edgeScale ~= config.edgeScale then
                fs.suppressEdgeScale = true
                pcall(cdFrame.SetEdgeScale, cdFrame, config.edgeScale)
                fs.suppressEdgeScale = nil
                fs.edgeScale = config.edgeScale
            end
        else
            fs.edgeScale = nil
        end
    elseif category == CATEGORY.TellMeWhen then
        fs.edge = nil
        fs.edgeScale = nil
    end

    if wantEdge and cdFrame.SetEdgeColor then
        local edgeColor = self:GetDesiredEdgeColor(cdFrame)
        if edgeColor and not IsSameSwipeColor(fs.edgeColor, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a) then
            fs.suppressEdgeColor = true
            pcall(cdFrame.SetEdgeColor, cdFrame, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a)
            fs.suppressEdgeColor = nil
            local ec = fs.edgeColor or {}
            ec.r, ec.g, ec.b, ec.a = edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a
            fs.edgeColor = ec
        elseif not edgeColor then
            fs.edgeColor = nil
        end
    else
        fs.edgeColor = nil
    end

    -- Swipe Color
    local isMasqueManaged = IsMasqueManagedCooldown(cdFrame)
    local isMUIManaged = IsMUIStyledCooldown(cdFrame)
    if cdFrame.SetSwipeColor and not isMasqueManaged and not isMUIManaged then
        if category == CATEGORY.Actionbar
           or category == CATEGORY.MiniAuras
           or category == CATEGORY.MyDRs
           or category == CATEGORY.Shackled then
            local r, g, b, a = 0, 0, 0, self:GetSwipeShadeAlpha(config)
            if not IsSameSwipeColor(fs.swipeColor, r, g, b, a) then
                fs.suppressSwipe = true
                pcall(cdFrame.SetSwipeColor, cdFrame, r, g, b, a)
                fs.suppressSwipe = nil
                local sc = fs.swipeColor or {}
                sc.r, sc.g, sc.b, sc.a = r, g, b, a
                fs.swipeColor = sc
            end
        else
            self:ResetSwipeColor(cdFrame)
        end
    elseif (isMasqueManaged or isMUIManaged) and fs.swipeColor then
        fs.swipeColor = nil
    end

    -- Hide countdown numbers
    local hideNums
    local miniAurasWantTextHidden
    if cdFrame.SetHideCountdownNumbers then
        local requestedHideNums = self:GetDesiredHideCountdownNumbers(
            cdFrame, category, config, isAssistedCombat, subtype)
        if requestedHideNums == nil and category == CATEGORY.TellMeWhen then
            hideNums = nil
        elseif category == CATEGORY.Unitframe and fs.unitFrameNativeDurationText == true then
            local holder = fs.unitFrameDurationTextHolder
            local setAlpha = holder and MCE:SafeTableGet(holder, "SetAlpha") or nil
            if type(setAlpha) == "function"
               and fs.unitFrameDurationTextHidden ~= requestedHideNums then
                pcall(setAlpha, holder, requestedHideNums and 0 or 1)
                fs.unitFrameDurationTextHidden = requestedHideNums
            end
            -- The secure duration FontString replaces the cooldown widget's
            -- own numbers; keeping both enabled draws duplicate countdowns.
            hideNums = true
        elseif category == CATEGORY.MiniAuras
               and fs.miniAurasNativeDurationText == true
               and fs.miniAurasNativeDurationTextReady == true then
            fs.miniAurasNativeDurationTextActive = true
            miniAurasWantTextHidden = requestedHideNums == true
            if fs.miniAurasDurationTextHidden ~= requestedHideNums then
                SetMiniAurasDurationTextAlpha(fs, requestedHideNums and 0 or 1)
                fs.miniAurasDurationTextHidden = requestedHideNums
            end
            -- AuraContainer owns the secret remaining time. Its bound
            -- FontString replaces the cooldown widget's own numbers.
            hideNums = true
        elseif category == CATEGORY.Shackled then
            -- Shackled's own FontString is a plain, non-secret region: unlike
            -- MiniAuras nothing fights the alpha back, so a direct SetAlpha
            -- toggle is all "Hide Numbers" needs here.
            local durationText = fs.shackledDurationText
            if IsUsableFontString(durationText) then
                local wantHidden = requestedHideNums == true
                if fs.shackledDurationTextHidden ~= wantHidden then
                    pcall(durationText.SetAlpha, durationText, wantHidden and 0 or 1)
                    fs.shackledDurationTextHidden = wantHidden
                end
            end
            -- Blizzard's own countdown text never draws on these cooldowns
            -- regardless (Shackled disables it and renders its own FontString
            -- instead); keep the widget flag aligned so nothing ever tries to
            -- draw a second number over Shackled's own.
            hideNums = true
        else
            hideNums = requestedHideNums
        end
        if hideNums ~= nil and fs.hideNums ~= hideNums then
            fs.suppressHideNums = true
            pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
            fs.suppressHideNums = nil
            fs.hideNums = hideNums
        elseif hideNums == nil and category == CATEGORY.TellMeWhen then
            fs.hideNums = nil
        end
    end

    -- Style key for change detection (cached to avoid per-call string concat)
    local styleKey
    if category == CATEGORY.CooldownManager
       or category == CATEGORY.MiniAuras
       or category == CATEGORY.SArena then
        styleKey = GetStyleKey(category, subtype or "default")
    else
        styleKey = category
    end

    local needsFullRestyle = fs.styledCat ~= styleKey
    local textRegions, textRegionCount, textRegionsChanged
    local needsDeferredTextRefresh = fs.forceTextRegionRefresh == true
    local shouldRefreshTextRegions = needsFullRestyle
        or category == CATEGORY.SArena
        or needsDeferredTextRefresh
        or (not hideNums and GetTrackedTextRegionCount(fs) == 0)

    if shouldRefreshTextRegions then
        textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
        textRegionsChanged = HaveCooldownTextRegionsChanged(fs, textRegions, textRegionCount)
        fs.forceTextRegionRefresh = nil
    end

    local needsActionbarTextStructure = category == CATEGORY.Actionbar
        and (needsFullRestyle
            or needsDeferredTextRefresh
            or textRegionsChanged
            or fs.actionbarTextStructureApplied ~= true)
    if needsActionbarTextStructure then
        if not textRegions then
            textRegions, textRegionCount = self:GetCachedCooldownTextRegions(cdFrame)
        end
        if RaiseActionbarCooldownText(cdFrame, parent, textRegions, textRegionCount) then
            fs.actionbarTextStructureApplied = true
        end
    end

    if needsFullRestyle then fs.styledCat = styleKey end

    -- Action Button count regions and layout are structural. Blizzard owns the
    -- displayed value, so ordinary cooldown/GCD broadcasts need no work here.
    if category ~= CATEGORY.Actionbar
       or needsFullRestyle
       or needsDeferredTextRefresh
       or fs.actionbarStackStyleApplied ~= true then
        self:StyleStackCount(cdFrame, config, category)
    end

    -- Assisted combat action: hide text
    if isAssistedCombat then
        if not fs.assistedCombatTextHidden then
            self:SetCooldownTextRegionsVisible(cdFrame, false)
            fs.assistedCombatTextHidden = true
        end
        if DurationColor then DurationColor:ClearTrackedDurationColor(cdFrame) end
        return
    elseif fs.assistedCombatTextHidden then
        self:SetCooldownTextRegionsVisible(cdFrame, not hideNums)
        fs.assistedCombatTextHidden = nil
    end

    -- Font styling (only when category/viewer changed or text regions changed)
    if needsFullRestyle or textRegionsChanged then
        fs.appliedTextColor = nil
        local fontStyle = MCE.NormalizeFontStyle(config.fontStyle)
        local resolvedFont = MCE.ResolveFontPath(config.font)
        local fontSize = self:GetCooldownFontSize(cdFrame, category, config, subtype)
        local preserveFontSize = (category == CATEGORY.HealerCC)
        -- Aura buttons draw dispel borders and third-party glows in OVERLAY on
        -- the button itself, and their cooldowns
        -- inherit the button frame level, so corner-anchored countdown text
        -- is covered unless it is raised to a higher sublevel.
        local raiseText = category == CATEGORY.Actionbar
            or category == CATEGORY.Unitframe
            or category == CATEGORY.Nameplate
        local textLayer = raiseText and STYLER_CONSTANTS.CooldownTextLayer or nil
        local textSubLevel = raiseText and STYLER_CONSTANTS.CooldownTextSubLevel or nil

        -- Some third-party addons recalculate cooldown font size after MiniCE
        -- applies styling. Enforce our chosen font for those integrations so
        -- the configured text size remains stable.
        local enforceFont = (category == CATEGORY.SArena
            or category == CATEGORY.MiniAuras
            or category == CATEGORY.HealerCC
            or category == CATEGORY.Shackled
            or (category == CATEGORY.Unitframe and fs.unitFrameCustomAura == true))
        local cooldownTextColor = fs.unitFrameNativeDurationText == true
            and nil or config.textColor
        -- MiniAuras re-tints the cooldown's own countdown text from its style on
        -- every restyle pass, so MiniCE has to hold its colour there. Threshold
        -- colours stay off for these frames (DurationColorController bails on
        -- miniAurasNativeDurationText), so a static colour cannot fight them.
        local enforceMiniAurasColor = category == CATEGORY.MiniAuras
            and fs.miniAurasNativeDurationText == true
            and cooldownTextColor ~= nil

        for i = 1, textRegionCount do
            local region = textRegions[i]
            if category == CATEGORY.Unitframe
               and fs.unitFrameCustomAura == true
               and type(region.SetScale) == "function" then
                pcall(region.SetScale, region, 1)
            end
            -- MiniAuras binds an engine-evaluated colour curve to its duration
            -- text; the engine owns that one's colour, so only the size/face are
            -- applied there. The native countdown text has no such binding.
            local isMiniAurasDurationText = region == fs.miniAurasDurationText
            local regionColor = isMiniAurasDurationText and nil or cooldownTextColor
            local regionEnforceColor = enforceMiniAurasColor
                and not isMiniAurasDurationText
            local regionFontSize = preserveFontSize and GetCurrentFontSize(region, fontSize) or fontSize
            self:ApplyFontStringStyle(
                region, cdFrame,
                resolvedFont, regionFontSize, fontStyle,
                regionColor,
                config.textAnchor, config.textAnchor,
                config.textOffsetX, config.textOffsetY,
                textLayer, textSubLevel, enforceFont, preserveFontSize,
                regionEnforceColor)
        end
    end

    -- SetHideCountdownNumbers does not suppress the countdown on MiniAuras' 12.1
    -- duration-object cooldowns: the widget reports the flag set while the number
    -- stays on screen. Alpha on the regions themselves is the lever that works -
    -- the same one that makes the font size stick - so drive both text regions
    -- with it rather than trusting the widget flag alone.
    -- The engine writes a secret alpha back over ours on most of these regions
    -- (the number blinks out for a frame and returns), so alpha alone does not
    -- hold. Shown state and text colour are separate properties on the same
    -- FontString; drive all three so whichever one the engine leaves alone wins.
    if miniAurasWantTextHidden ~= nil then
        local regions, regionCount = self:GetCachedCooldownTextRegions(cdFrame)
        fs.miniAurasSuppressDurationTextAlpha = true
        for i = 1, regionCount do
            local region = regions[i]
            if region and not MCE:IsForbiddenCached(region) then
                local fontStyleState = self:GetFontState(region)
                if miniAurasWantTextHidden then
                    pcall(region.SetAlpha, region, 0)
                    pcall(region.Hide, region)
                    -- The draw layer is the one that holds: it is plain Lua
                    -- state the engine never recomputes, so parking the text
                    -- under the icon texture survives the alpha overwrite.
                    pcall(region.SetDrawLayer, region, "BACKGROUND", -8)
                    fontStyleState.drawLayer = nil
                    fontStyleState.suppressSetTextColor = true
                    pcall(region.SetTextColor, region, 0, 0, 0, 0)
                    fontStyleState.suppressSetTextColor = nil
                    fontStyleState.colorR, fontStyleState.colorG = nil, nil
                    fontStyleState.colorB, fontStyleState.colorA = nil, nil
                elseif fs.miniAurasTextRegionsHidden then
                    pcall(region.SetAlpha, region, 1)
                    pcall(region.Show, region)
                    pcall(region.SetDrawLayer, region, "OVERLAY", 0)
                    fontStyleState.drawLayer = nil
                    fontStyleState.colorR = nil
                end
            end
        end
        fs.miniAurasSuppressDurationTextAlpha = nil
        fs.miniAurasTextRegionsHidden = miniAurasWantTextHidden
    end

    -- Abbreviation threshold
    local profile = MCE.db and MCE.db.profile
    if profile and cdFrame.SetCountdownAbbrevThreshold then
        CaptureCountdownThresholdState(cdFrame, fs)
        local abbrevThreshold = profile.abbrevThreshold or C.Options.DefaultAbbrevThreshold
        if fs.countdownAbbrevThreshold ~= abbrevThreshold then
            fs.suppressCountdownAbbrevThreshold = true
            pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame, abbrevThreshold)
            fs.suppressCountdownAbbrevThreshold = nil
            fs.countdownAbbrevThreshold = abbrevThreshold
        end
    end
    if profile and cdFrame.SetCountdownMillisecondsThreshold then
        CaptureCountdownThresholdState(cdFrame, fs)
        local millisecondsThreshold = profile.countdownMillisecondsThreshold or C.Options.DefaultMillisecondsThreshold
        if fs.countdownMillisecondsThreshold ~= millisecondsThreshold then
            fs.suppressCountdownMillisecondsThreshold = true
            pcall(cdFrame.SetCountdownMillisecondsThreshold, cdFrame, millisecondsThreshold)
            fs.suppressCountdownMillisecondsThreshold = nil
            fs.countdownMillisecondsThreshold = millisecondsThreshold
        end
    end

    -- Duration colors
    if DurationColor then
        DurationColor:RefreshTrackedDurationColor(cdFrame, category, config)
    end
end

-- =========================================================================
-- STATE MANAGEMENT
-- =========================================================================

function StyleEngine:WipeState()
    local preservedUnitFrameState = {}
    local preservedMiniAurasState = {}
    local preservedClaims = {}
    for cooldown, state in pairs(frameState) do
        if state and state.allowBlacklisted == true then
            preservedClaims[#preservedClaims + 1] = cooldown
        end
        if state and state.unitFrameCustomAura == true then
            preservedUnitFrameState[#preservedUnitFrameState + 1] = {
                cooldown = cooldown,
                managedAura = state.unitFrameManagedAura == true,
                initializing = state.unitFrameAuraInitializing == true,
                initialized = state.unitFrameAuraInitialized == true,
                isMine = state.unitFrameAuraIsMine,
                count = state.unitFrameCount,
                countdownText = state.unitFrameCountdownText,
                auraButton = state.unitFrameAuraButton,
                durationTextHolder = state.unitFrameDurationTextHolder,
                nativeDurationText = state.unitFrameNativeDurationText,
                nativeDurationTextReady = state.unitFrameNativeDurationTextReady,
                textRegions = state.textRegions,
                durationObject = state.durationObject,
            }
        end
        if state and state.miniAurasNativeDurationText == true then
            preservedMiniAurasState[#preservedMiniAurasState + 1] = {
                cooldown = cooldown,
                durationText = state.miniAurasDurationText,
                requestedDurationTextAlpha = state.miniAurasRequestedDurationTextAlpha,
                requestedHideCountdownNumbers = state.miniAurasRequestedHideCountdownNumbers,
                nativeDurationTextReady = state.miniAurasNativeDurationTextReady,
                stackText = state.miniAurasStackText,
                -- Records that the countdown is currently parked out of sight;
                -- without it the restore path cannot tell there is anything to
                -- put back, and turning Hide Numbers off needs a reload.
                textRegionsHidden = state.miniAurasTextRegionsHidden,
                textRegions = state.textRegions,
            }
        end
    end

    wipe(frameState)
    wipe(fontState)

    -- An adapter sets allowBlacklisted to claim a frame whose parent chain would
    -- otherwise be rejected: a MiniAuras aura button goes forbidden right after
    -- initialization, and Classifier:IsBlacklisted walks parents, so its cooldown
    -- is blacklisted from then on without the claim. That claim is adapter
    -- metadata, not styling cache - dropping it here left every tracked cooldown
    -- that carries no richer preserved state (the pooled majority) permanently
    -- skipped by ApplyStyle after the first option refresh.
    for i = 1, #preservedClaims do
        frameState[preservedClaims[i]] = { allowBlacklisted = true }
    end

    -- Adapter metadata describes stable public output widgets, not styling
    -- cache. Preserve it across ordinary (non-discovery) option refreshes.
    for i = 1, #preservedUnitFrameState do
        local preserved = preservedUnitFrameState[i]
        frameState[preserved.cooldown] = {
            allowBlacklisted = true,
            unitFrameCustomAura = true,
            unitFrameManagedAura = preserved.managedAura == true,
            unitFrameAuraInitializing = preserved.initializing == true,
            unitFrameAuraInitialized = preserved.initialized == true,
            unitFrameAuraIsMine = preserved.isMine,
            unitFrameCount = preserved.count,
            unitFrameCountdownText = preserved.countdownText,
            unitFrameAuraButton = preserved.auraButton,
            unitFrameDurationTextHolder = preserved.durationTextHolder,
            unitFrameNativeDurationText = preserved.nativeDurationText == true,
            unitFrameNativeDurationTextReady = preserved.nativeDurationTextReady == true,
            textRegions = preserved.textRegions,
            durationObject = preserved.durationObject,
        }
    end
    for i = 1, #preservedMiniAurasState do
        local preserved = preservedMiniAurasState[i]
        frameState[preserved.cooldown] = {
            allowBlacklisted = true,
            miniAurasDurationText = preserved.durationText,
            miniAurasRequestedDurationTextAlpha = preserved.requestedDurationTextAlpha,
            miniAurasRequestedHideCountdownNumbers = preserved.requestedHideCountdownNumbers,
            miniAurasNativeDurationText = true,
            miniAurasNativeDurationTextReady = preserved.nativeDurationTextReady == true,
            miniAurasStackText = preserved.stackText,
            miniAurasTextRegionsHidden = preserved.textRegionsHidden,
            textRegions = preserved.textRegions,
        }
    end
end
