-- PlayerAuraStyler.lua - Styling for Blizzard default player buffs, debuffs, and external defensives

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local PlayerAuraStyler = MCE:NewModule("PlayerAuraStyler", "AceEvent-3.0")

local type, pcall, tostring = type, pcall, tostring
local pairs, select, next = pairs, select, next
local strfind = string.find
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local RunNextFrame = addon.RunNextFrame
local RunAfter = addon.RunAfter
local GetTime = GetTime
local _G = _G

local IsSecretValue = addon.IsSecretValue
local CanAccessAllValues = addon.CanAccessAllValues
local GetParentSafe = addon.GetParentSafe

local CATEGORY = C.Categories.PlayerAura
local AURA_TYPE = C.PlayerAuraTypes
local AURA_TYPE_BUFF = AURA_TYPE.Buff
local AURA_TYPE_DEBUFF = AURA_TYPE.Debuff
local AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS = AURA_TYPE.ExternalDefensiveBuffs
local STYLER = C.Styler
local PLAYER_UNIT = "player"
local VEHICLE_UNIT = "vehicle"
local MAX_PARENT_SCAN_DEPTH = 8
local SECRET_AURA_REFRESH_INTERVAL = STYLER.SecretAuraRefreshInterval or 0.25

local managedButtons = setmetatable({}, addon.weakMeta)
local managedAuraTypes = setmetatable({}, addon.weakMeta)
local hookedButtons = setmetatable({}, addon.weakMeta)
local assignedAuraTypes = setmetatable({}, addon.weakMeta)
local originalFontStrings = setmetatable({}, addon.weakMeta)
local elvuiManagedButtons = setmetatable({}, addon.weakMeta)
local alphaOverrideGuards = setmetatable({}, addon.weakMeta)

local hooksInstalled = false
local pendingForceUpdate = false
local lastSecretAuraRefresh = 0
local elvuiAurasHooked = false

local function IsTrackedAuraRoot(frame)
    return (BuffFrame and frame == BuffFrame)
        or (DebuffFrame and frame == DebuffFrame)
        or (DeadlyDebuffFrame and frame == DeadlyDebuffFrame)
        or (ExternalDefensivesFrame and frame == ExternalDefensivesFrame)
end

local function GetAuraRoot(button)
    local current = button
    for _ = 1, MAX_PARENT_SCAN_DEPTH do
        if not current then break end
        if IsTrackedAuraRoot(current) then
            return current
        end

        current = GetParentSafe(current)
    end

    return nil
end

local function GetAuraTypeFromRoot(root)
    if not root then
        return nil
    end

    if BuffFrame and root == BuffFrame then
        return AURA_TYPE_BUFF
    end

    if (DebuffFrame and root == DebuffFrame) or (DeadlyDebuffFrame and root == DeadlyDebuffFrame) then
        return AURA_TYPE_DEBUFF
    end

    if ExternalDefensivesFrame and root == ExternalDefensivesFrame then
        return AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS
    end

    return nil
end

local function GetConfig()
    local profile = MCE.db and MCE.db.profile
    local categories = profile and profile.categories
    return categories and categories[CATEGORY] or nil
end

local function IsConfigEnabled(config)
    return config and config.enabled == true
end

local function IsAuraTypeEnabled(config, auraType)
    local typeConfig = config and config[auraType]
    if auraType == AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS then
        return type(typeConfig) == "table" and typeConfig.enabled == true
    end

    return type(typeConfig) ~= "table" or typeConfig.enabled ~= false
end

local function GetAuraStyleConfig(config, auraType)
    local typeConfig = config and config[auraType]
    if type(typeConfig) == "table" then
        return typeConfig
    end

    return config
end

local function IsForbidden(frame)
    return not frame or MCE:IsForbiddenCached(frame)
end

local function CaptureFontStringState(region)
    if not region or originalFontStrings[region] then
        return
    end

    local state = {}

    if region.GetFontObject then
        local ok, fontObject = pcall(region.GetFontObject, region)
        if ok then state.fontObject = fontObject end
    end

    if region.IsShown then
        local ok, shown = pcall(region.IsShown, region)
        if ok then state.shown = shown == true end
    end

    if region.GetFont then
        local ok, fontPath, fontSize, fontStyle = pcall(region.GetFont, region)
        if ok then
            state.fontPath = fontPath
            state.fontSize = fontSize
            state.fontStyle = fontStyle
        end
    end

    if region.GetTextColor then
        local ok, r, g, b, a = pcall(region.GetTextColor, region)
        if ok then
            state.r, state.g, state.b, state.a = r, g, b, a
        end
    end

    if region.GetNumPoints and region.GetPoint then
        local ok, pointCount = pcall(region.GetNumPoints, region)
        if ok and type(pointCount) == "number" and pointCount > 0 then
            state.points = {}
            for i = 1, pointCount do
                local pointOk, point, relativeTo, relativePoint, offsetX, offsetY = pcall(region.GetPoint, region, i)
                if pointOk and point then
                    state.points[#state.points + 1] = {
                        point = point,
                        relativeTo = relativeTo,
                        relativePoint = relativePoint,
                        offsetX = offsetX,
                        offsetY = offsetY,
                    }
                end
            end
        end
    end

    originalFontStrings[region] = state
end

local function RestoreFontStringState(region)
    local state = region and originalFontStrings[region]
    if not state or IsForbidden(region) then
        return
    end

    if region.ClearAllPoints and state.points then
        pcall(region.ClearAllPoints, region)
        for i = 1, #state.points do
            local point = state.points[i]
            pcall(region.SetPoint, region, point.point, point.relativeTo, point.relativePoint, point.offsetX or 0, point.offsetY or 0)
        end
    end

    if state.fontObject and region.SetFontObject then
        pcall(region.SetFontObject, region, state.fontObject)
    elseif state.fontPath and state.fontSize and region.SetFont then
        pcall(region.SetFont, region, state.fontPath, state.fontSize, state.fontStyle)
    end

    if state.r and region.SetTextColor then
        region:SetTextColor(state.r, state.g, state.b, state.a or 1)
    end

    if state.shown ~= nil and region.SetShown then
        region:SetShown(state.shown)
    end
end

-- Comparison bodies are predefined (called through pcall against secret/tainted
-- values) to avoid allocating a closure on every per-frame style pass.
local function ComparePoint(currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY,
                            point, relativeTo, relativePoint, offsetX, offsetY)
    if IsSecretValue(currentPoint)
        or IsSecretValue(currentRelativeTo)
        or IsSecretValue(currentRelativePoint)
        or IsSecretValue(currentOffsetX)
        or IsSecretValue(currentOffsetY) then
        return false
    end

    return currentPoint == point
        and currentRelativeTo == relativeTo
        and currentRelativePoint == relativePoint
        and addon.IsNearlyEqual(currentOffsetX or 0, offsetX or 0)
        and addon.IsNearlyEqual(currentOffsetY or 0, offsetY or 0)
end

local function IsSamePoint(region, point, relativeTo, relativePoint, offsetX, offsetY)
    if not region or not region.GetPoint then return false end

    local ok, currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY =
        pcall(region.GetPoint, region, 1)
    if not ok then return false end

    local compareOk, same = pcall(ComparePoint,
        currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY,
        point, relativeTo, relativePoint, offsetX, offsetY)

    return compareOk and same or false
end

local function CompareFont(fontPath, fontSize, fontStyle, desiredFontPath, desiredFontSize, desiredFontStyle)
    if IsSecretValue(fontPath) or IsSecretValue(fontStyle) then
        return false
    end

    return fontPath == desiredFontPath
        and addon.IsNearlyEqual(fontSize, desiredFontSize)
        and fontStyle == desiredFontStyle
end

local function IsSameFont(fontPath, fontSize, fontStyle, desiredFontPath, desiredFontSize, desiredFontStyle)
    local compareOk, same = pcall(CompareFont,
        fontPath, fontSize, fontStyle, desiredFontPath, desiredFontSize, desiredFontStyle)

    return compareOk and same or false
end

local function ApplyFontStringStyle(region, relativeFrame, fontPath, fontSize, fontStyle, color, point, relativePoint, offsetX, offsetY)
    if not region or IsForbidden(region) then
        return
    end

    CaptureFontStringState(region)

    if region.GetFont and region.SetFont then
        local ok, currentFontPath, currentFontSize, currentFontStyle = pcall(region.GetFont, region)
        if ok and not IsSameFont(currentFontPath, currentFontSize, currentFontStyle, fontPath, fontSize, fontStyle) then
            pcall(region.SetFont, region, fontPath, fontSize, fontStyle)
        end
    end

    if color and region.SetTextColor then
        region:SetTextColor(color.r, color.g, color.b, color.a or 1)
    end

    if point and relativeFrame and region.ClearAllPoints and region.SetPoint then
        relativePoint = relativePoint or point
        if not IsSamePoint(region, point, relativeFrame, relativePoint, offsetX or 0, offsetY or 0) then
            local previousChangingPoint = region.changingPoint
            -- BetterBlizzFrames guards its aura Duration:SetPoint hook with this field.
            region.changingPoint = true
            pcall(region.ClearAllPoints, region)
            pcall(region.SetPoint, region, point, relativeFrame, relativePoint, offsetX or 0, offsetY or 0)
            region.changingPoint = previousChangingPoint
        end
    end
end

--- PlayerFrame swaps its unit to "vehicle" while the player is in a vehicle.
--- Returns nil when the token is missing, empty, or secret.
local function GetPlayerFrameUnit()
    local unit = PlayerFrame and PlayerFrame.unit
    if type(unit) ~= "string" or unit == "" or IsSecretValue(unit) then
        return nil
    end

    return unit
end

local function GetButtonUnit(button)
    local unit = button and button.unit
    if type(unit) == "string" and unit ~= "" and not IsSecretValue(unit) then
        return unit
    end

    return GetPlayerFrameUnit() or PLAYER_UNIT
end

local function GetAuraInstanceID(button)
    local info = button and button.buttonInfo
    local auraInstanceID = info and info.auraInstanceID or button and button.deadlyInstanceID
    if auraInstanceID then
        return auraInstanceID
    end

    if not (info and info.index) then
        return nil
    end

    local filter = button and button.GetFilter and button:GetFilter() or nil
    if type(filter) ~= "string" or filter == "" then
        return nil
    end

    -- WoW 12.1: every UnitAura API returns a full secret or nil while auras are
    -- secret, so the returned table may not be indexable. SafeTableGet pcalls
    -- the field read; the instance ID itself stays usable (secret or not) since
    -- it is only ever handed straight back to C_UnitAuras, never inspected.
    local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, GetButtonUnit(button), info.index, filter)
    if ok and type(auraData) == "table" then
        return MCE:SafeTableGet(auraData, "auraInstanceID")
    end

    return nil
end

local function GetAuraDurationObject(button)
    local auraInstanceID = GetAuraInstanceID(button)
    if not auraInstanceID then
        return nil
    end

    local ok, durationObject = pcall(C_UnitAuras.GetAuraDuration, GetButtonUnit(button), auraInstanceID)
    if ok and durationObject then
        return durationObject
    end

    return nil
end

local function HideFontString(region)
    if not region or IsForbidden(region) then
        return
    end

    if region.SetText then
        pcall(region.SetText, region, "")
    end
    if region.SetAlpha then
        pcall(region.SetAlpha, region, 0)
    end
    if region.Hide then
        pcall(region.Hide, region)
    end
end

local function IsFontString(region)
    if not (region and region.GetObjectType) then
        return false
    end

    local ok, objectType = pcall(region.GetObjectType, region)
    return ok and objectType == "FontString"
end

local function HideFontStringRegions(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if IsFontString(region) then
            HideFontString(region)
        end
    end
end

local function HideCooldownFontStrings(cooldown)
    HideFontStringRegions(cooldown:GetRegions())
end

local function SuppressSwipeCooldownText(cooldown)
    if not cooldown or IsForbidden(cooldown) then
        return
    end

    cooldown.MCEPlayerAuraVisualOnly = true
    cooldown.noCooldownCount = true
    cooldown.noOCC = true

    if cooldown.SetHideCountdownNumbers then
        pcall(cooldown.SetHideCountdownNumbers, cooldown, true)
    end

    if cooldown.GetCountdownFontString then
        local ok, countdownText = pcall(cooldown.GetCountdownFontString, cooldown)
        if ok then
            HideFontString(countdownText)
        end
    end

    if cooldown.GetRegions then
        pcall(HideCooldownFontStrings, cooldown)
    end
end

local function ApplyAuraDurationObject(cooldown, button)
    if not (cooldown and cooldown.SetCooldownFromDurationObject) then
        return false
    end

    SuppressSwipeCooldownText(cooldown)

    local durationObject = GetAuraDurationObject(button)
    if not durationObject then
        return false
    end

    local ok = pcall(cooldown.SetCooldownFromDurationObject, cooldown, durationObject)
    if not ok then
        return false
    end

    cooldown.MCEPlayerAuraSignature = nil
    SuppressSwipeCooldownText(cooldown)
    cooldown:Show()
    return true
end

local function IsConsolidatedBuffButton(button)
    return button and (button.UpdateConsolidatedAuraCount ~= nil or button.Tooltip ~= nil)
end

local function IsPlayerAuraButton(button)
    if not button or IsForbidden(button) or IsConsolidatedBuffButton(button) then
        return false
    end

    if not (button.Icon and button.Duration and button.Count) then
        return false
    end

    return assignedAuraTypes[button] ~= nil or GetAuraTypeFromRoot(GetAuraRoot(button)) ~= nil
end

local function GetPlayerAuraButtonType(button)
    if not IsPlayerAuraButton(button) then
        return nil
    end

    local assignedType = assignedAuraTypes[button]
    if assignedType == AURA_TYPE_BUFF
        or assignedType == AURA_TYPE_DEBUFF
        or assignedType == AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS then
        return assignedType
    end

    local auraType = GetAuraTypeFromRoot(GetAuraRoot(button))
    if auraType then
        return auraType
    end

    local filter = button.GetFilter and button:GetFilter() or nil
    if type(filter) == "string" then
        if strfind(filter, "HARMFUL", 1, true) then
            return AURA_TYPE_DEBUFF
        end
        if strfind(filter, "HELPFUL", 1, true) then
            return AURA_TYPE_BUFF
        end
    end

    return nil
end

local function GetDurationPoint(button, config)
    if config and config.timerInsideIcon == true then
        return "CENTER", "CENTER"
    end

    local container = GetParentSafe(button)
    if container and container.isHorizontal ~= nil then
        if container.isHorizontal then
            return container.addIconsToTop and "BOTTOM" or "TOP",
                container.addIconsToTop and "TOP" or "BOTTOM"
        end

        return container.addIconsToRight and "LEFT" or "RIGHT",
            container.addIconsToRight and "RIGHT" or "LEFT"
    end

    return "TOP", "BOTTOM"
end

local function GetSwipeShadeAlpha(config)
    local alphaPercent = config and config.swipeAlpha
    if type(alphaPercent) ~= "number" then
        alphaPercent = STYLER.DefaultSwipeAlpha
    end
    if alphaPercent < STYLER.AlphaPercentMin then
        alphaPercent = STYLER.AlphaPercentMin
    elseif alphaPercent > STYLER.AlphaPercentMax then
        alphaPercent = STYLER.AlphaPercentMax
    end
    return alphaPercent / STYLER.AlphaPercentMax
end

local function EnsureSwipeCooldown(button)
    local cooldown = button and button.MCEPlayerAuraCooldown
    if cooldown then
        SuppressSwipeCooldownText(cooldown)
        return cooldown
    end
    if not (button and button.Icon and CreateFrame) then
        return cooldown
    end

    cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    SuppressSwipeCooldownText(cooldown)
    cooldown:SetAllPoints(button.Icon)

    if cooldown.SetFrameStrata and button.GetFrameStrata then
        cooldown:SetFrameStrata(button:GetFrameStrata())
    end
    if cooldown.SetFrameLevel and button.GetFrameLevel then
        cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
    end

    if cooldown.SetHideCountdownNumbers then
        pcall(cooldown.SetHideCountdownNumbers, cooldown, true)
    end
    if cooldown.SetDrawBling then
        pcall(cooldown.SetDrawBling, cooldown, false)
    end
    if cooldown.SetReverse then
        pcall(cooldown.SetReverse, cooldown, true)
    end

    cooldown:Hide()
    button.MCEPlayerAuraCooldown = cooldown
    return cooldown
end

local function BuildSwipeSignature(info)
    local expirationTime = info.expirationTime or 0
    local duration = info.duration or 0
    if type(expirationTime) ~= "number" or type(duration) ~= "number"
        or expirationTime <= 0 or duration <= 0 then
        return nil
    end

    local timeMod = info.timeMod or 1
    return tostring(info.auraInstanceID or info.ID or "") .. ":" .. expirationTime .. ":" .. duration .. ":" .. timeMod
end

local function GetSwipeSignature(button)
    local info = button and button.buttonInfo
    if type(info) ~= "table" then
        return nil
    end

    -- buttonInfo fields can be secret values; pcall a predefined builder.
    local ok, signature = pcall(BuildSwipeSignature, info)

    return ok and signature or nil
end

local function ApplySwipeCooldownFromInfo(cooldown, info)
    local duration = info.duration
    local expirationTime = info.expirationTime
    local startTime = expirationTime - duration
    cooldown:SetCooldown(startTime, duration, info.timeMod or 1)
end

local function SyncSwipeCooldown(button, config)
    local cooldown = button and button.MCEPlayerAuraCooldown
    local wantsSwipe = config.drawSwipe ~= false or config.edgeEnabled == true

    if not wantsSwipe or button.isExample then
        if cooldown then cooldown:Hide() end
        return
    end

    cooldown = EnsureSwipeCooldown(button)
    if not cooldown then return end
    SuppressSwipeCooldownText(cooldown)

    local alpha = GetSwipeShadeAlpha(config)
    local reverseSwipe = config.reverseSwipe ~= false
    local drawSwipe = config.drawSwipe ~= false
    local edgeEnabled = config.edgeEnabled == true

    -- Field-by-field change detection keeps aura refreshes cheap.
    if cooldown.MCELastDrawSwipe ~= drawSwipe
        or cooldown.MCELastEdgeEnabled ~= edgeEnabled
        or cooldown.MCELastEdgeScale ~= config.edgeScale
        or cooldown.MCELastReverse ~= reverseSwipe
        or cooldown.MCELastSwipeAlpha ~= alpha then
        if cooldown.SetDrawSwipe then
            pcall(cooldown.SetDrawSwipe, cooldown, drawSwipe)
        end
        if cooldown.SetDrawEdge then
            pcall(cooldown.SetDrawEdge, cooldown, edgeEnabled)
        end
        if cooldown.SetEdgeScale and config.edgeScale then
            pcall(cooldown.SetEdgeScale, cooldown, config.edgeScale)
        end
        if cooldown.SetReverse then
            pcall(cooldown.SetReverse, cooldown, reverseSwipe)
        end
        if cooldown.SetSwipeColor then
            pcall(cooldown.SetSwipeColor, cooldown, 0, 0, 0, alpha)
        end
        cooldown.MCELastDrawSwipe = drawSwipe
        cooldown.MCELastEdgeEnabled = edgeEnabled
        cooldown.MCELastEdgeScale = config.edgeScale
        cooldown.MCELastReverse = reverseSwipe
        cooldown.MCELastSwipeAlpha = alpha
    end

    if ApplyAuraDurationObject(cooldown, button) then
        return
    end

    local signature = GetSwipeSignature(button)
    if not signature then
        cooldown:Hide()
        cooldown.MCEPlayerAuraSignature = nil
        return
    end

    if cooldown.MCEPlayerAuraSignature ~= signature then
        pcall(ApplySwipeCooldownFromInfo, cooldown, button.buttonInfo)
        cooldown.MCEPlayerAuraSignature = signature
    end

    SuppressSwipeCooldownText(cooldown)
    cooldown:Show()
end

local function GetVisibleAuraCount(button, countRegion)
    local count = button.buttonInfo and button.buttonInfo.count
    if type(count) == "number" and CanAccessAllValues(count) then
        return count
    end

    if not countRegion or not countRegion.GetText then
        return nil
    end

    local ok, text = pcall(countRegion.GetText, countRegion)
    if not ok then
        return nil
    end

    text = MCE:GetNonSecretString(text)
    if not text then
        return nil
    end

    return tonumber(text)
end

local function RestoreButton(button)
    if not managedButtons[button] then
        return
    end

    if button.Duration then
        RestoreFontStringState(button.Duration)
        button.Duration:SetAlpha(1)
    end

    if button.Count then
        RestoreFontStringState(button.Count)
        button.Count:SetAlpha(1)
        local count = GetVisibleAuraCount(button, button.Count)
        if type(count) == "number" and count > 1 then
            button.Count:Show()
        end
    end

    if button.MCEPlayerAuraCooldown then
        button.MCEPlayerAuraCooldown:Hide()
        button.MCEPlayerAuraCooldown.MCEPlayerAuraSignature = nil
    end

    button:SetAlpha(1)
    managedButtons[button] = nil
    managedAuraTypes[button] = nil
end

local function StyleDuration(button, config)
    local duration = button.Duration
    if not duration then return end

    if config.hideCountdownNumbers then
        CaptureFontStringState(duration)
        duration:SetAlpha(0)
        duration:Hide()
        return
    end

    duration:SetAlpha(1)

    local point, relativePoint = GetDurationPoint(button, config)
    ApplyFontStringStyle(
        duration,
        button.Icon or button,
        MCE.ResolveFontPath(config.font),
        config.fontSize,
        MCE.NormalizeFontStyle(config.fontStyle),
        config.textColor,
        point,
        relativePoint,
        config.textOffsetX or 0,
        config.textOffsetY or 0)
end

local function StyleCount(button, config)
    local countRegion = button.Count
    if not countRegion then return end

    CaptureFontStringState(countRegion)

    if config.hideStackText then
        countRegion:SetAlpha(0)
        countRegion:Hide()
        return
    end

    local count = GetVisibleAuraCount(button, countRegion)
    if type(count) == "number" and count > 1 then
        countRegion:SetAlpha(1)
        countRegion:Show()
    end

    if not config.stackEnabled then
        return
    end

    ApplyFontStringStyle(
        countRegion,
        button.Icon or button,
        MCE.ResolveFontPath(config.stackFont),
        config.stackSize,
        MCE.NormalizeFontStyle(config.stackStyle),
        config.stackColor,
        config.stackAnchor,
        config.stackAnchor,
        config.stackOffsetX or 0,
        config.stackOffsetY or 0)
end

local function RefreshDurationAfterAuraUpdate(button)
    if not managedButtons[button] then
        return
    end

    local auraType = managedAuraTypes[button]
    local config = GetConfig()
    if not IsConfigEnabled(config) or not IsAuraTypeEnabled(config, auraType) then
        return
    end

    local styleConfig = GetAuraStyleConfig(config, auraType)
    local duration = button and button.Duration
    if not duration or IsForbidden(duration) then
        return
    end

    if styleConfig.hideCountdownNumbers then
        duration:SetAlpha(0)
        duration:Hide()
        return
    end

    local color = styleConfig.textColor
    if color and duration.SetTextColor then
        duration:SetTextColor(color.r, color.g, color.b, color.a or 1)
    end
end

local function EnforceUnfadedAlpha(button, alpha)
    if IsSecretValue(alpha) or not CanAccessAllValues(alpha) then
        return
    end

    if alphaOverrideGuards[button] or alpha == 1 or not managedButtons[button] then
        return
    end

    local config = GetConfig()
    if not (config and config.disableFading) then
        return
    end

    alphaOverrideGuards[button] = true
    button:SetAlpha(1)
    alphaOverrideGuards[button] = nil
end

function PlayerAuraStyler:StyleAuraButton(button)
    local auraType = GetPlayerAuraButtonType(button)
    if not auraType then
        RestoreButton(button)
        return
    end

    local config = GetConfig()
    if not IsConfigEnabled(config) or not IsAuraTypeEnabled(config, auraType) then
        RestoreButton(button)
        return
    end

    local styleConfig = GetAuraStyleConfig(config, auraType)
    managedButtons[button] = true
    managedAuraTypes[button] = auraType

    StyleDuration(button, styleConfig)
    StyleCount(button, styleConfig)
    SyncSwipeCooldown(button, styleConfig)

    if config.disableFading then
        button:SetAlpha(1)
    end
end

local function HookButton(button)
    -- hookedButtons first: it is a single table lookup, while IsPlayerAuraButton
    -- walks up to eight parents. Both still have to be false to proceed.
    if hookedButtons[button] or not IsPlayerAuraButton(button) then
        return
    end

    if button.HookScript then
        button:HookScript("OnShow", function(frame)
            PlayerAuraStyler:StyleAuraButton(frame)
        end)
    end

    if type(button.Update) == "function" then
        hooksecurefunc(button, "Update", function(frame)
            PlayerAuraStyler:StyleAuraButton(frame)
        end)
    end

    if type(button.UpdateDuration) == "function" then
        hooksecurefunc(button, "UpdateDuration", function(frame)
            RefreshDurationAfterAuraUpdate(frame)
        end)
    end

    if type(button.SetAlpha) == "function" then
        hooksecurefunc(button, "SetAlpha", EnforceUnfadedAlpha)
    end

    hookedButtons[button] = true
end

local function ForEachKnownAuraButton(callback)
    -- Blizzard auraFrames tables can reject generic iteration while aura data
    -- is secret and execution is addon-tainted. Read their known numeric keys
    -- through SafeTableGet instead; an unreadable entry cleanly ends the same
    -- contiguous-array walk that ipairs performed.
    local function ScanAuraFrames(auraFrames, auraType)
        if type(auraFrames) ~= "table" then return end

        local index = 1
        while true do
            local button = MCE:SafeTableGet(auraFrames, index)
            if not button then return end

            if MCE:CanUseFrameAsTableKey(button) then
                assignedAuraTypes[button] = auraType
                callback(button)
            end
            index = index + 1
        end
    end

    local function ScanRoot(root, auraType)
        ScanAuraFrames(MCE:SafeTableGet(root, "auraFrames"), auraType)
    end

    ScanRoot(BuffFrame, AURA_TYPE_BUFF)
    ScanRoot(DebuffFrame, AURA_TYPE_DEBUFF)
    ScanRoot(ExternalDefensivesFrame, AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS)

    local consolidated = MCE:SafeTableGet(BuffFrame, "ConsolidatedBuffs")
    local tooltip = MCE:SafeTableGet(consolidated, "Tooltip")
    local tooltipAuras = MCE:SafeTableGet(tooltip, "Auras")
    ScanAuraFrames(MCE:SafeTableGet(tooltipAuras, "auraFrames"), AURA_TYPE_BUFF)

    local deadlyDebuff = MCE:SafeTableGet(DeadlyDebuffFrame, "Debuff")
    if MCE:CanUseFrameAsTableKey(deadlyDebuff) then
        assignedAuraTypes[deadlyDebuff] = AURA_TYPE_DEBUFF
        callback(deadlyDebuff)
    end
end

function PlayerAuraStyler:HookKnownButtons()
    ForEachKnownAuraButton(HookButton)
end

-- =========================================================================
-- ELVUI PLAYER AURA SUPPORT
-- =========================================================================
-- When ElvUI's standalone Auras module is active it replaces the Blizzard
-- BuffFrame/DebuffFrame with its own ElvUIPlayerBuffs / ElvUIPlayerDebuffs
-- headers. Those buttons display the timer through the native Blizzard
-- cooldown countdown numbers on button.cooldown (ElvUI's own cooldown text is
-- disabled in this configuration), so the Blizzard-button path above never
-- reaches them. Style only the countdown text here and leave the icon, swipe,
-- bar and overall look to ElvUI.

local ELVUI_AURA_HEADER_NAMES = { "ElvUIPlayerBuffs", "ElvUIPlayerDebuffs" }

-- ElvUI's CreateIcon replaces the aura cooldown edge with an invisible texture,
-- so the swipe edge must be restored to the stock Blizzard cooldown edge before
-- it can be shown again.
local ELVUI_EDGE_TEXTURE = "Interface\\Cooldown\\edge"

local function IsElvUIPlayerAuraActive()
    if not (MCE:IsElvUIAvailable() and MCE:IsElvUIAdapterEnabled()) then
        return false
    end

    return _G.ElvUIPlayerBuffs ~= nil or _G.ElvUIPlayerDebuffs ~= nil
end

local function GetElvUIAuraType(button)
    local auraType = button and button.auraType
    if auraType == "buffs" then
        return AURA_TYPE_BUFF
    end
    if auraType == "debuffs" then
        return AURA_TYPE_DEBUFF
    end

    local filter = button and button.filter
    if filter == "HELPFUL" then
        return AURA_TYPE_BUFF
    end
    if filter == "HARMFUL" then
        return AURA_TYPE_DEBUFF
    end

    return nil
end

local function GetCooldownCountdownFontString(cooldown)
    if not cooldown or IsForbidden(cooldown) then
        return nil
    end

    if cooldown.GetCountdownFontString then
        local ok, fontString = pcall(cooldown.GetCountdownFontString, cooldown)
        if ok and IsFontString(fontString) and not IsForbidden(fontString) then
            return fontString
        end
    end

    if cooldown.GetRegions then
        local ok, regions = pcall(function()
            return { cooldown:GetRegions() }
        end)
        if ok and type(regions) == "table" then
            for i = 1, #regions do
                local region = regions[i]
                if IsFontString(region) and not IsForbidden(region) then
                    return region
                end
            end
        end
    end

    return nil
end

local function ApplyElvUISwipe(cooldown, config)
    local drawSwipe = config.drawSwipe ~= false
    local edgeEnabled = config.edgeEnabled == true
    local reverseSwipe = config.reverseSwipe ~= false
    local edgeScale = config.edgeScale
    local alpha = GetSwipeShadeAlpha(config)

    local signature = tostring(drawSwipe)
        .. ":" .. tostring(edgeEnabled)
        .. ":" .. tostring(edgeScale or "")
        .. ":" .. tostring(reverseSwipe)
        .. ":" .. tostring(alpha)

    if cooldown.MCEElvUISwipeSignature == signature then
        return
    end

    if cooldown.SetDrawSwipe then
        pcall(cooldown.SetDrawSwipe, cooldown, drawSwipe)
    end
    if drawSwipe and cooldown.SetSwipeColor then
        pcall(cooldown.SetSwipeColor, cooldown, 0, 0, 0, alpha)
    end

    if cooldown.SetDrawEdge then
        pcall(cooldown.SetDrawEdge, cooldown, edgeEnabled)
    end
    if edgeEnabled then
        if cooldown.SetEdgeTexture then
            pcall(cooldown.SetEdgeTexture, cooldown, ELVUI_EDGE_TEXTURE)
        end
        if edgeScale and cooldown.SetEdgeScale then
            pcall(cooldown.SetEdgeScale, cooldown, edgeScale)
        end
    end

    if cooldown.SetReverse then
        pcall(cooldown.SetReverse, cooldown, reverseSwipe)
    end

    cooldown.MCEElvUISwipeSignature = signature
end

local function ResetElvUISwipe(cooldown)
    if not cooldown or not cooldown.MCEElvUISwipeSignature then
        return
    end

    -- Restore ElvUI's default aura look: swipe and edge hidden.
    if cooldown.SetDrawSwipe then
        pcall(cooldown.SetDrawSwipe, cooldown, false)
    end
    if cooldown.SetDrawEdge then
        pcall(cooldown.SetDrawEdge, cooldown, false)
    end

    cooldown.MCEElvUISwipeSignature = nil
end

local function RestoreElvUIButton(button)
    if not elvuiManagedButtons[button] then
        return
    end

    local cooldown = button.cooldown
    if cooldown then
        if cooldown.MCEElvUIHidNumbers then
            if cooldown.SetHideCountdownNumbers then
                pcall(cooldown.SetHideCountdownNumbers, cooldown, false)
            end
            cooldown.MCEElvUIHidNumbers = nil
        end

        ResetElvUISwipe(cooldown)

        local fontString = GetCooldownCountdownFontString(cooldown)
        if fontString then
            RestoreFontStringState(fontString)
            if fontString.SetAlpha then
                pcall(fontString.SetAlpha, fontString, 1)
            end
        end
    end

    elvuiManagedButtons[button] = nil
end

local function StyleElvUIAuraButton(button)
    if not button or IsForbidden(button) then
        return true
    end

    if not IsElvUIPlayerAuraActive() then
        RestoreElvUIButton(button)
        return true
    end

    local cooldown = button.cooldown
    if not cooldown or IsForbidden(cooldown) then
        return true
    end

    local auraType = GetElvUIAuraType(button)
    if not auraType then
        RestoreElvUIButton(button)
        return true
    end

    local config = GetConfig()
    if not IsConfigEnabled(config) or not IsAuraTypeEnabled(config, auraType) then
        RestoreElvUIButton(button)
        return true
    end

    local styleConfig = GetAuraStyleConfig(config, auraType)
    elvuiManagedButtons[button] = true

    -- Swipe / edge are independent of the timer text, so apply them first (this
    -- also covers the "Hide Numbers" swipe-only case below).
    ApplyElvUISwipe(cooldown, styleConfig)

    if styleConfig.hideCountdownNumbers then
        if cooldown.SetHideCountdownNumbers then
            pcall(cooldown.SetHideCountdownNumbers, cooldown, true)
        end
        cooldown.MCEElvUIHidNumbers = true
        return true
    end

    if cooldown.MCEElvUIHidNumbers then
        if cooldown.SetHideCountdownNumbers then
            pcall(cooldown.SetHideCountdownNumbers, cooldown, false)
        end
        cooldown.MCEElvUIHidNumbers = nil
    end

    local fontString = GetCooldownCountdownFontString(cooldown)
    if not fontString then
        -- The native countdown FontString is created lazily once numbers are
        -- drawn. Report "not ready" so the caller can retry on the next tick.
        return false
    end

    fontString:SetAlpha(1)

    -- ElvUI draws the aura timer through the native cooldown countdown text,
    -- which sits centered over the icon, so anchor to the cooldown frame and
    -- apply the configured offsets (matches StyleEngine's cooldown text path).
    ApplyFontStringStyle(
        fontString,
        cooldown,
        MCE.ResolveFontPath(styleConfig.font),
        styleConfig.fontSize,
        MCE.NormalizeFontStyle(styleConfig.fontStyle),
        styleConfig.textColor,
        "CENTER",
        "CENTER",
        styleConfig.textOffsetX or 0,
        styleConfig.textOffsetY or 0)

    return true
end

local function StyleElvUIAuraButtonSoon(button)
    if not StyleElvUIAuraButton(button) then
        -- ElvUI sets the cooldown a frame before the native countdown
        -- FontString exists, so retry once on the next tick.
        RunAfter(0.05, function()
            StyleElvUIAuraButton(button)
        end)
    end
end

local function GetElvUIAurasModule()
    -- _G.ElvUI is the engine array {E, L, V, P, G}; the Auras module hangs off E.
    local engine = _G.ElvUI
    local E = type(engine) == "table" and engine[1] or nil
    if type(E) ~= "table" then
        return nil
    end

    return E.Auras
end

local function InstallElvUIAurasHooks()
    if elvuiAurasHooked then
        return
    end

    local A = GetElvUIAurasModule()
    if type(A) ~= "table" or type(A.UpdateButton) ~= "function" then
        return
    end

    -- ElvUI calls A:UpdateButton(button, ...) right after it sets the aura
    -- cooldown, which is the authoritative moment to (re)apply the text style.
    hooksecurefunc(A, "UpdateButton", function(_, button)
        if button and button.cooldown then
            StyleElvUIAuraButtonSoon(button)
        end
    end)

    elvuiAurasHooked = true
end

local function ForEachElvUIAuraButton(callback)
    for h = 1, #ELVUI_AURA_HEADER_NAMES do
        local header = _G[ELVUI_AURA_HEADER_NAMES[h]]
        if header and not IsForbidden(header) and header.GetChildren then
            local children = { header:GetChildren() }
            for i = 1, #children do
                local button = children[i]
                if button and not IsForbidden(button) and button.cooldown and button.auraType then
                    callback(button)
                end
            end
        end
    end
end

function PlayerAuraStyler:UpdateElvUIPlayerAuras()
    if not IsElvUIPlayerAuraActive() then
        for button in pairs(elvuiManagedButtons) do
            RestoreElvUIButton(button)
        end
        return
    end

    InstallElvUIAurasHooks()

    ForEachElvUIAuraButton(function(button)
        StyleElvUIAuraButton(button)
    end)
end

function PlayerAuraStyler:InstallMixinHooks()
    if hooksInstalled or type(AuraButtonMixin) ~= "table" then
        return hooksInstalled
    end

    if type(AuraButtonMixin.Update) == "function" then
        hooksecurefunc(AuraButtonMixin, "Update", function(button)
            HookButton(button)
            PlayerAuraStyler:StyleAuraButton(button)
        end)
    end

    hooksInstalled = true
    return true
end

function PlayerAuraStyler:ScheduleForceUpdate()
    if pendingForceUpdate then
        return
    end

    pendingForceUpdate = true
    RunNextFrame(function()
        pendingForceUpdate = false
        self:ForceUpdateAll()
    end)
end

-- Hoisted out of ForceUpdateAll so the sweep below does not allocate a closure
-- on every UNIT_AURA-driven refresh.
local function StyleKnownAuraButton(button)
    PlayerAuraStyler:StyleAuraButton(button)
end

function PlayerAuraStyler:ForceUpdateAll()
    self:InstallMixinHooks()

    local config = GetConfig()
    local enabled = IsConfigEnabled(config)

    -- UNIT_AURA drives this several times per second in combat. With the
    -- category off and nothing left to restore, the button sweep has no
    -- observable effect: enabling the category runs ForceUpdateAll again, and
    -- the mixin hook installed above still reaches buttons created meanwhile.
    if enabled or next(managedButtons) then
        self:HookKnownButtons()

        if enabled then
            ForEachKnownAuraButton(StyleKnownAuraButton)
        else
            for button in pairs(managedButtons) do
                RestoreButton(button)
            end
        end
    end

    self:UpdateElvUIPlayerAuras()
end

function PlayerAuraStyler:ADDON_LOADED(_, loadedAddonName)
    if loadedAddonName == "Blizzard_BuffFrame"
        or loadedAddonName == C.Addon.Name
        or loadedAddonName == C.Addon.BetterBlizzFramesName then
        self:ScheduleForceUpdate()
    end
end

function PlayerAuraStyler:PLAYER_ENTERING_WORLD()
    self:ScheduleForceUpdate()
end

function PlayerAuraStyler:UNIT_AURA(unit)
    -- WoW 12.1: UNIT_AURA delivers a fully secret payload while auras are
    -- secret (combat, encounters, M+, PvP). A secret token matches none of the
    -- comparisons below, so filtering on it would silently stop the refresh in
    -- exactly the contexts where it matters. Fall back to refreshing on any
    -- unreadable token -- throttled, because those payloads also fire for every
    -- group member and nameplate, not just the player.
    if type(unit) ~= "string" or IsSecretValue(unit) then
        local now = GetTime()
        if now - lastSecretAuraRefresh < SECRET_AURA_REFRESH_INTERVAL then
            return
        end

        lastSecretAuraRefresh = now
        self:ScheduleForceUpdate()
        return
    end

    if unit == PLAYER_UNIT or unit == VEHICLE_UNIT or unit == GetPlayerFrameUnit() then
        self:ScheduleForceUpdate()
    end
end

function PlayerAuraStyler:OnEnable()
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_AURA")
    self:ScheduleForceUpdate()
end

function PlayerAuraStyler:OnDisable()
    for button in pairs(managedButtons) do
        RestoreButton(button)
    end

    for button in pairs(elvuiManagedButtons) do
        RestoreElvUIButton(button)
    end
end
