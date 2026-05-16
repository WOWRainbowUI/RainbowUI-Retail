-- PlayerAuraStyler.lua - Styling for Blizzard default player buffs, debuffs, and external defensives

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local PlayerAuraStyler = MCE:NewModule("PlayerAuraStyler", "AceEvent-3.0")

local type, pcall, tostring = type, pcall, tostring
local ipairs, pairs = ipairs, pairs
local strfind = string.find
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local C_Timer_After = C_Timer.After

local CATEGORY = C.Categories.PlayerAura
local AURA_TYPE = C.PlayerAuraTypes
local AURA_TYPE_BUFF = AURA_TYPE.Buff
local AURA_TYPE_DEBUFF = AURA_TYPE.Debuff
local AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS = AURA_TYPE.ExternalDefensiveBuffs
local STYLER = C.Styler
local PLAYER_UNIT = "player"
local MAX_PARENT_SCAN_DEPTH = 8

local managedButtons = setmetatable({}, addon.weakMeta)
local hookedButtons = setmetatable({}, addon.weakMeta)
local assignedAuraTypes = setmetatable({}, addon.weakMeta)
local originalFontStrings = setmetatable({}, addon.weakMeta)

local hooksInstalled = false
local pendingForceUpdate = false

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

        current = current.GetParent and current:GetParent() or nil
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

local function IsSamePoint(region, point, relativeTo, relativePoint, offsetX, offsetY)
    if not region or not region.GetPoint then return false end

    local ok, currentPoint, currentRelativeTo, currentRelativePoint, currentOffsetX, currentOffsetY =
        pcall(region.GetPoint, region, 1)
    if not ok then return false end

    local compareOk, same = pcall(function()
        if addon.IsSecretValue(currentPoint)
            or addon.IsSecretValue(currentRelativeTo)
            or addon.IsSecretValue(currentRelativePoint)
            or addon.IsSecretValue(currentOffsetX)
            or addon.IsSecretValue(currentOffsetY) then
            return false
        end

        return currentPoint == point
            and currentRelativeTo == relativeTo
            and currentRelativePoint == relativePoint
            and addon.IsNearlyEqual(currentOffsetX or 0, offsetX or 0)
            and addon.IsNearlyEqual(currentOffsetY or 0, offsetY or 0)
    end)

    return compareOk and same or false
end

local function IsSameFont(fontPath, fontSize, fontStyle, desiredFontPath, desiredFontSize, desiredFontStyle)
    local compareOk, same = pcall(function()
        if addon.IsSecretValue(fontPath) or addon.IsSecretValue(fontStyle) then
            return false
        end

        return fontPath == desiredFontPath
            and addon.IsNearlyEqual(fontSize, desiredFontSize)
            and fontStyle == desiredFontStyle
    end)

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

local function GetButtonUnit(button)
    if button and type(button.unit) == "string" and button.unit ~= "" then
        return button.unit
    end

    if PlayerFrame and type(PlayerFrame.unit) == "string" and PlayerFrame.unit ~= "" then
        return PlayerFrame.unit
    end

    return PLAYER_UNIT
end

local function GetAuraInstanceID(button)
    local info = button and button.buttonInfo
    local auraInstanceID = info and info.auraInstanceID or button and button.deadlyInstanceID
    if auraInstanceID then
        return auraInstanceID
    end

    if not (info and info.index and C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then
        return nil
    end

    local filter = button and button.GetFilter and button:GetFilter() or nil
    if type(filter) ~= "string" or filter == "" then
        return nil
    end

    local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, GetButtonUnit(button), info.index, filter)
    if ok and type(auraData) == "table" then
        return auraData.auraInstanceID
    end

    return nil
end

local function GetAuraDurationObject(button)
    local auraInstanceID = GetAuraInstanceID(button)
    if not auraInstanceID or not (C_UnitAuras and C_UnitAuras.GetAuraDuration) then
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
        local ok, regions = pcall(function()
            return { cooldown:GetRegions() }
        end)
        if ok and type(regions) == "table" then
            for i = 1, #regions do
                local region = regions[i]
                if IsFontString(region) then
                    HideFontString(region)
                end
            end
        end
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

    local container = button and button.GetParent and button:GetParent() or nil
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

local function GetSwipeSignature(button)
    local info = button and button.buttonInfo
    if type(info) ~= "table" then
        return nil
    end

    local ok, signature = pcall(function()
        local expirationTime = info.expirationTime or 0
        local duration = info.duration or 0
        if type(expirationTime) ~= "number" or type(duration) ~= "number"
            or expirationTime <= 0 or duration <= 0 then
            return nil
        end

        local timeMod = info.timeMod or 1
        return tostring(info.auraInstanceID or info.ID or "") .. ":" .. expirationTime .. ":" .. duration .. ":" .. timeMod
    end)

    return ok and signature or nil
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
    local styleSignature = tostring(config.drawSwipe ~= false)
        .. ":" .. tostring(config.edgeEnabled == true)
        .. ":" .. tostring(config.edgeScale or "")
        .. ":" .. tostring(reverseSwipe)
        .. ":" .. tostring(alpha)

    if cooldown.MCEPlayerAuraStyleSignature ~= styleSignature then
        if cooldown.SetDrawSwipe then
            pcall(cooldown.SetDrawSwipe, cooldown, config.drawSwipe ~= false)
        end
        if cooldown.SetDrawEdge then
            pcall(cooldown.SetDrawEdge, cooldown, config.edgeEnabled == true)
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
        cooldown.MCEPlayerAuraStyleSignature = styleSignature
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
        local info = button.buttonInfo
        pcall(function()
            local duration = info.duration
            local expirationTime = info.expirationTime
            local startTime = expirationTime - duration
            cooldown:SetCooldown(startTime, duration, info.timeMod or 1)
        end)

        cooldown.MCEPlayerAuraSignature = signature
    end

    SuppressSwipeCooldownText(cooldown)
    cooldown:Show()
end

local function GetVisibleAuraCount(button, countRegion)
    local count = button.buttonInfo and button.buttonInfo.count
    if type(count) == "number" and addon.CanAccessAllValues(count) then
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

    StyleDuration(button, styleConfig)
    StyleCount(button, styleConfig)
    SyncSwipeCooldown(button, styleConfig)

    if config.disableFading then
        button:SetAlpha(1)
    end
end

local function HookButton(button)
    if not IsPlayerAuraButton(button) or hookedButtons[button] then
        return
    end

    if button.HookScript then
        button:HookScript("OnShow", function(frame)
            PlayerAuraStyler:StyleAuraButton(frame)
        end)
        button:HookScript("OnUpdate", function(frame)
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
            PlayerAuraStyler:StyleAuraButton(frame)
        end)
    end

    hookedButtons[button] = true
end

local function ForEachKnownAuraButton(callback)
    local function ScanRoot(root, auraType)
        local auraFrames = root and root.auraFrames
        if type(auraFrames) == "table" then
            for _, button in ipairs(auraFrames) do
                if button then
                    assignedAuraTypes[button] = auraType
                    callback(button)
                end
            end
        end
    end

    ScanRoot(BuffFrame, AURA_TYPE_BUFF)
    ScanRoot(DebuffFrame, AURA_TYPE_DEBUFF)
    ScanRoot(ExternalDefensivesFrame, AURA_TYPE_EXTERNAL_DEFENSIVE_BUFFS)

    if BuffFrame and BuffFrame.ConsolidatedBuffs
        and BuffFrame.ConsolidatedBuffs.Tooltip
        and BuffFrame.ConsolidatedBuffs.Tooltip.Auras
        and type(BuffFrame.ConsolidatedBuffs.Tooltip.Auras.auraFrames) == "table" then
        for _, button in ipairs(BuffFrame.ConsolidatedBuffs.Tooltip.Auras.auraFrames) do
            if button then
                assignedAuraTypes[button] = AURA_TYPE_BUFF
                callback(button)
            end
        end
    end

    if DeadlyDebuffFrame and DeadlyDebuffFrame.Debuff then
        assignedAuraTypes[DeadlyDebuffFrame.Debuff] = AURA_TYPE_DEBUFF
        callback(DeadlyDebuffFrame.Debuff)
    end
end

function PlayerAuraStyler:HookKnownButtons()
    ForEachKnownAuraButton(HookButton)
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

    if type(AuraButtonMixin.UpdateDuration) == "function" then
        hooksecurefunc(AuraButtonMixin, "UpdateDuration", function(button)
            HookButton(button)
            PlayerAuraStyler:StyleAuraButton(button)
        end)
    end

    if type(AuraButtonMixin.OnUpdate) == "function" then
        hooksecurefunc(AuraButtonMixin, "OnUpdate", function(button)
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
    C_Timer_After(0, function()
        pendingForceUpdate = false
        self:ForceUpdateAll()
    end)
end

function PlayerAuraStyler:ForceUpdateAll()
    self:InstallMixinHooks()
    self:HookKnownButtons()

    local config = GetConfig()
    if IsConfigEnabled(config) then
        ForEachKnownAuraButton(function(button)
            self:StyleAuraButton(button)
        end)
    else
        for button in pairs(managedButtons) do
            RestoreButton(button)
        end
    end
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
    if unit == PLAYER_UNIT or unit == "vehicle" or (PlayerFrame and unit == PlayerFrame.unit) then
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
end
