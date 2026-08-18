-- BetterBlizzPlatesAdapter.lua - BetterBlizzPlates 12.1 nameplate aura support
--
-- BBP owns aura selection, size, spacing, positioning, borders, stack text,
-- timer visibility/formatting, and the base swipe. MiniCE only layers duration
-- font/color/positioning and swipe-edge thickness/visibility on top. While the
-- adapter is enabled, MiniCE's static color or remaining-time curve replaces
-- BBP's normal/low colors and low threshold for both timer text variants.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("BetterBlizzPlatesAdapter")

local type, pairs, ipairs, pcall = type, pairs, ipairs, pcall
local format = string.format
local min = math.min
local hooksecurefunc = hooksecurefunc

local CATEGORY = C.Categories
local BBP_CONSTANTS = C.Adapter.BetterBlizzPlates

-- Third-party GetAuraGroupFrameCount() results are trusted only up to this
-- ceiling; a stale/buggy count from BetterBlizzPlates must not turn the scan
-- loop below into a multi-second stall ("script ran too long").
local MAX_SCANNED_AURA_GROUP_FRAMES = 64

local Registry
local trackedCooldowns = setmetatable({}, addon.weakMeta)
local initializationStyling = setmetatable({}, addon.weakMeta)
local durationBindingStyling = setmetatable({}, addon.weakMeta)
local blizzardCountdownRefreshHooked = setmetatable({}, addon.weakMeta)
local customAuraButtonAPI
local durationCooldownHookInstalled = false
local durationTextHookInstalled = false
local finalStyleHookInstalled = false
local bbpAuraInitializerWrapped = false
local InstallLifecycleHooks
local bbpDurationCurve
local bbpDurationCurveSignature
local durationFormatters = {}

local function IsObjectTypeSafe(frame, objectType)
    local isObjectType = MCE:SafeTableGet(frame, "IsObjectType")
    if type(isObjectType) ~= "function" then return false end
    local ok, result = pcall(isObjectType, frame, objectType)
    if not ok or MCE:IsSecretValue(result)
       or not addon.CanAccessAllValues(result) then
        return false
    end
    return result == true
end

local function ReadMethodValue(object, methodName)
    local method = object and MCE:SafeTableGet(object, methodName) or nil
    if type(method) ~= "function" then return nil end
    local ok, value = pcall(method, object)
    if not ok or MCE:IsSecretValue(value)
       or not addon.CanAccessAllValues(value) then
        return nil
    end
    return value
end

local function GetAuraSettings()
    local bbp = MCE:SafeTableGet(_G, "BBP")
    local settings = MCE:SafeTableGet(bbp, "auraSettings")
    return type(settings) == "table" and settings or nil
end

local function GetColorComponents(settings, key, defaultR, defaultG, defaultB, defaultA)
    local color = settings and MCE:SafeTableGet(settings, key) or nil
    if type(color) ~= "table" then
        return defaultR, defaultG, defaultB, defaultA
    end

    local r = type(color[1]) == "number" and color[1] or defaultR
    local g = type(color[2]) == "number" and color[2] or defaultG
    local b = type(color[3]) == "number" and color[3] or defaultB
    local a = type(color[4]) == "number" and color[4] or defaultA
    return r, g, b, a
end

local function GetBBPDurationCurve(settings)
    if not settings then return nil end

    local hideFrom = BBP_CONSTANTS.HideLongTimerFrom
    local threshold = type(settings.timerThreshold) == "number"
        and settings.timerThreshold or BBP_CONSTANTS.LowColorThresholdDefault
    threshold = min(threshold, hideFrom - 1)

    local baseR, baseG, baseB, baseA =
        GetColorComponents(settings, "timerBase", 1, 0.82, 0, 1)
    local lowR, lowG, lowB, lowA =
        GetColorComponents(settings, "timerLow", 1, 0.1, 0.1, 1)
    local timerColor = settings.timerColor ~= false
    local hideLongTimers = settings.hideLongTimers ~= false
    local signature = format(
        "%s|%.4f|%s|%.4f,%.4f,%.4f,%.4f|%.4f,%.4f,%.4f,%.4f",
        tostring(timerColor), threshold, tostring(hideLongTimers),
        baseR, baseG, baseB, baseA, lowR, lowG, lowB, lowA)

    if not bbpDurationCurve then
        bbpDurationCurve = C_CurveUtil.CreateColorCurve()
        bbpDurationCurve:SetType(Enum.LuaCurveType.Step)
    elseif bbpDurationCurveSignature == signature then
        return bbpDurationCurve
    else
        bbpDurationCurve:ClearPoints()
    end
    bbpDurationCurveSignature = signature

    local baseColor = CreateColor(baseR, baseG, baseB, baseA)
    if timerColor then
        bbpDurationCurve:AddPoint(0, CreateColor(lowR, lowG, lowB, lowA))
        bbpDurationCurve:AddPoint(threshold, baseColor)
    else
        bbpDurationCurve:AddPoint(0, baseColor)
    end
    if hideLongTimers then
        bbpDurationCurve:AddPoint(hideFrom, CreateColor(baseR, baseG, baseB, 0))
    end
    return bbpDurationCurve
end

local function GetDurationFormatter(showMilliseconds, hideLongTimers)
    local key = (showMilliseconds and "ms" or "plain")
        .. (hideLongTimers and "+hide" or "")
    if durationFormatters[key] then return durationFormatters[key] end

    local formatter = C_StringUtil.CreateNumericRuleFormatter()
    local breakpoints = {}
    if showMilliseconds then
        breakpoints[#breakpoints + 1] = { threshold = 0, format = "%.1f" }
    end
    breakpoints[#breakpoints + 1] = {
        threshold = showMilliseconds and BBP_CONSTANTS.MillisecondThreshold or 0,
        format = "%d",
        step = 1,
        rounding = Enum.NumericRuleFormatRounding.Up,
    }
    if hideLongTimers then
        breakpoints[#breakpoints + 1] = {
            threshold = BBP_CONSTANTS.HideLongTimerFrom,
            format = " ",
        }
    end
    formatter:SetBreakpoints(breakpoints)
    durationFormatters[key] = formatter
    return formatter
end

local function SetDurationBinding(button, setDurationText, target, options)
    durationBindingStyling[button] = true
    local ok = pcall(setDurationText, button, target, options)
    durationBindingStyling[button] = nil
    return ok
end

local function GetDurationTextBinding(button)
    local getBinding = button and MCE:SafeTableGet(
        button, "GetDurationTextBinding") or nil
    if type(getBinding) ~= "function" then return nil end

    local ok, binding = pcall(getBinding, button)
    return ok and binding or nil
end

local function RefreshBlizzardCountdownBinding(cooldown)
    local state = addon.frameState[cooldown]
    if not state or not state.betterBlizzPlatesCountdownText
       or state.betterBlizzPlatesBoundDurationText
            ~= state.betterBlizzPlatesCountdownText then
        return
    end

    local binding = state.betterBlizzPlatesDurationBinding
    local updateFontString = binding
        and MCE:SafeTableGet(binding, "UpdateFontString") or nil
    if type(updateFontString) == "function" then
        pcall(updateFontString, binding)
    end
end

local function EnsureBlizzardCountdownRefreshHook(cooldown)
    if blizzardCountdownRefreshHooked[cooldown] then return true end

    local hookScript = MCE:SafeTableGet(cooldown, "HookScript")
    if type(hookScript) ~= "function" then return false end

    local ok = pcall(hookScript, cooldown, "OnUpdate", function(frame)
        -- The Cooldown widget updates its built-in text internally. Reapply
        -- the CustomAuraButton binding afterward so MiniCE's secret-safe color
        -- curve is the final writer for BBP's "Use Blizzard Numbers" mode.
        RefreshBlizzardCountdownBinding(frame)
    end)
    if ok then blizzardCountdownRefreshHooked[cooldown] = true end
    return ok
end

local function ActivateBlizzardCountdownBinding(cooldown, state, button)
    state.betterBlizzPlatesDurationBinding = GetDurationTextBinding(button)
    if not state.betterBlizzPlatesDurationBinding then return false end

    EnsureBlizzardCountdownRefreshHook(cooldown)
    RefreshBlizzardCountdownBinding(cooldown)
    return true
end

local function BindDurationText(cooldown, config, restoreBBPBinding)
    local state = addon.frameState[cooldown]
    if not (state and state.betterBlizzPlatesAura == true) then return false end

    local button = state.betterBlizzPlatesAuraButton
    local setDurationText = button and MCE:SafeTableGet(button, "SetDurationText") or nil
    if type(setDurationText) ~= "function" then return false end

    local settings = GetAuraSettings()
    if not settings then return false end

    local useBlizzardText = not restoreBBPBinding and settings.blizzardCdText == true
    local target = useBlizzardText
        and state.betterBlizzPlatesCountdownText
        or state.betterBlizzPlatesDurationText
    if not target then return false end

    local originalOptions = state.betterBlizzPlatesOriginalDurationOptions
    if restoreBBPBinding and type(originalOptions) == "table" then
        if state.betterBlizzPlatesBoundDurationText == target
           and state.betterBlizzPlatesBoundDurationOptions == originalOptions then
            return true
        end
        if not SetDurationBinding(button, setDurationText, target, originalOptions) then
            return false
        end
        state.betterBlizzPlatesBoundDurationText = target
        state.betterBlizzPlatesBoundDurationOptions = originalOptions
        state.betterBlizzPlatesBoundDurationCurve = nil
        state.betterBlizzPlatesBoundDurationFormatter = nil
        state.betterBlizzPlatesDurationBinding = nil
        return true
    end

    local durationColor = MCE:GetModule("DurationColorController", true)
    local curve = restoreBBPBinding
        and GetBBPDurationCurve(settings)
        or (durationColor and durationColor:GetDurationTextCurve(
            CATEGORY.BetterBlizzPlates, config))
    if not curve then return false end

    local currentMilliseconds = MCE:SafeTableGet(button, "bbpMilliseconds")
    if type(currentMilliseconds) == "boolean" then
        state.betterBlizzPlatesMilliseconds = currentMilliseconds
    end
    local showMilliseconds = state.betterBlizzPlatesMilliseconds == true
    local hideLongTimers = settings.hideLongTimers ~= false
    local formatter = GetDurationFormatter(
        showMilliseconds, not restoreBBPBinding and hideLongTimers)
    if state.betterBlizzPlatesBoundDurationText == target
       and state.betterBlizzPlatesBoundDurationCurve == curve
       and state.betterBlizzPlatesBoundDurationFormatter == formatter then
        if useBlizzardText then
            ActivateBlizzardCountdownBinding(cooldown, state, button)
        end
        return true
    end

    local options = {
        textFormatter = formatter,
        textColor = {
            curve = curve,
            property = Enum.DurationTextBindingProperty.RemainingDuration,
        },
    }
    if not SetDurationBinding(button, setDurationText, target, options) then
        return false
    end

    state.betterBlizzPlatesBoundDurationText = target
    state.betterBlizzPlatesBoundDurationOptions = nil
    state.betterBlizzPlatesBoundDurationCurve = curve
    state.betterBlizzPlatesBoundDurationFormatter = formatter
    state.betterBlizzPlatesDurationBinding = nil
    if useBlizzardText then
        ActivateBlizzardCountdownBinding(cooldown, state, button)
    end
    return true
end

local function CaptureTextOriginal(state, region)
    if not state or not IsObjectTypeSafe(region, "FontString") then return end

    local originals = state.betterBlizzPlatesTextOriginals
    if not originals then
        originals = setmetatable({}, addon.weakMeta)
        state.betterBlizzPlatesTextOriginals = originals
    end
    if originals[region] then return end

    local original = {}
    local getFont = MCE:SafeTableGet(region, "GetFont")
    if type(getFont) == "function" then
        local ok, fontPath, fontSize, fontStyle = pcall(getFont, region)
        if ok and type(fontPath) == "string" and type(fontSize) == "number"
           and addon.CanAccessAllValues(fontPath, fontSize, fontStyle) then
            original.fontPath = fontPath
            original.fontSize = fontSize
            original.fontStyle = fontStyle or ""
        end
    end

    local getTextColor = MCE:SafeTableGet(region, "GetTextColor")
    if type(getTextColor) == "function" then
        local ok, r, g, b, a = pcall(getTextColor, region)
        if ok and type(r) == "number" and type(g) == "number"
           and type(b) == "number" and type(a) == "number"
           and addon.CanAccessAllValues(r, g, b, a) then
            original.color = { r = r, g = g, b = b, a = a }
        end
    end

    local getNumPoints = MCE:SafeTableGet(region, "GetNumPoints")
    local getPoint = MCE:SafeTableGet(region, "GetPoint")
    if type(getNumPoints) == "function" and type(getPoint) == "function" then
        local ok, pointCount = pcall(getNumPoints, region)
        if ok and type(pointCount) == "number" and pointCount > 0 then
            original.points = {}
            for pointIndex = 1, pointCount do
                local pointOk, point, relativeTo, relativePoint, offsetX, offsetY =
                    pcall(getPoint, region, pointIndex)
                if pointOk and type(point) == "string" then
                    original.points[#original.points + 1] = {
                        point, relativeTo, relativePoint, offsetX, offsetY,
                    }
                end
            end
        end
    end

    originals[region] = original
end

local function CaptureNativeEdgeState(cooldown, state, force)
    local drawEdge = ReadMethodValue(cooldown, "GetDrawEdge")
    if type(drawEdge) == "boolean" and (force or state.betterBlizzPlatesDrawEdge == nil) then
        state.betterBlizzPlatesDrawEdge = drawEdge
    else
        local settings = MCE:SafeTableGet(MCE:SafeTableGet(_G, "BBP"), "auraSettings")
        local hideSwipe = type(settings) == "table"
            and MCE:SafeTableGet(settings, "hideSwipe") or nil
        if type(hideSwipe) == "boolean"
           and (force or state.betterBlizzPlatesDrawEdge == nil) then
            state.betterBlizzPlatesDrawEdge = not hideSwipe
        end
    end

    local edgeScale = ReadMethodValue(cooldown, "GetEdgeScale")
    if type(edgeScale) == "number" and (force or state.betterBlizzPlatesEdgeScale == nil) then
        state.betterBlizzPlatesEdgeScale = edgeScale
    elseif state.betterBlizzPlatesEdgeScale == nil then
        state.betterBlizzPlatesEdgeScale = BBP_CONSTANTS.NativeEdgeScale
    end
end

local function GetNativeCountdownText(cooldown)
    local getCountdownFontString = MCE:SafeTableGet(cooldown, "GetCountdownFontString")
    if type(getCountdownFontString) ~= "function" then return nil end
    local ok, region = pcall(getCountdownFontString, cooldown)
    if ok and IsObjectTypeSafe(region, "FontString") then return region end
    return nil
end

local function MarkTrackedCooldown(cooldown, button, afterBBPRestyle)
    if not MCE:CanUseFrameAsTableKey(cooldown)
       or not MCE:IsBetterBlizzPlatesAuraCooldown(cooldown) then
        return nil
    end

    -- Bootstrap the shared AuraButton hooks only from a genuine button that
    -- Blizzard's secure AuraContainer has already allocated for BBP.
    if InstallLifecycleHooks then
        InstallLifecycleHooks(button)
    end

    local state = addon.frameState[cooldown]
    if not state then
        state = {}
        addon.frameState[cooldown] = state
    end

    local timer = MCE:SafeTableGet(button, "bbpTimer")
    if not IsObjectTypeSafe(timer, "FontString") then timer = nil end
    local countdownText = GetNativeCountdownText(cooldown)

    if state.betterBlizzPlatesDurationText ~= timer
       or state.betterBlizzPlatesCountdownText ~= countdownText then
        state.forceTextRegionRefresh = true
        state.textRegions = nil
    end

    state.allowBlacklisted = true
    state.betterBlizzPlatesAura = true
    state.betterBlizzPlatesAuraButton = button
    state.betterBlizzPlatesDurationText = timer
    state.betterBlizzPlatesCountdownText = countdownText
    state.betterBlizzPlatesOwnsTimerColors = true
    local milliseconds = MCE:SafeTableGet(button, "bbpMilliseconds")
    if type(milliseconds) == "boolean" then
        state.betterBlizzPlatesMilliseconds = milliseconds
    end

    CaptureTextOriginal(state, timer)
    CaptureTextOriginal(state, countdownText)
    CaptureNativeEdgeState(cooldown, state, afterBBPRestyle)
    if afterBBPRestyle then
        -- HookBridge intentionally does not enforce MiniCE state over BBP
        -- setters. Force this pass to layer the configured edge back on top.
        state.edge = nil
        state.edgeScale = nil
        state.forceTextRegionRefresh = true
        state.betterBlizzPlatesBoundDurationText = nil
        state.betterBlizzPlatesBoundDurationOptions = nil
        state.betterBlizzPlatesBoundDurationCurve = nil
        state.betterBlizzPlatesBoundDurationFormatter = nil
        state.betterBlizzPlatesDurationBinding = nil
    end

    trackedCooldowns[cooldown] = true
    if Registry then
        Registry:Register(cooldown, CATEGORY.BetterBlizzPlates)
    end
    return state
end

local function ApplyStyleImmediately(cooldown)
    if initializationStyling[cooldown] then return end
    local styleEngine = MCE:GetModule("StyleEngine", true)
    if not (styleEngine and styleEngine:IsEnabled()) then return end

    initializationStyling[cooldown] = true
    pcall(styleEngine.ApplyStyle, styleEngine, cooldown, CATEGORY.BetterBlizzPlates)
    initializationStyling[cooldown] = nil
end

local function TrackAuraButton(button, applyImmediately)
    if not MCE:IsBetterBlizzPlatesAuraCustomizationActive()
       or not MCE:CanUseFrameAsTableKey(button) then
        return nil
    end

    local cooldown = MCE:SafeTableGet(button, "bbpCooldown")
    if not MarkTrackedCooldown(cooldown, button, applyImmediately) then return nil end
    if applyImmediately then ApplyStyleImmediately(cooldown) end
    return cooldown
end

local function CaptureBBPDurationBinding(button, cooldown, durationText, options)
    if durationBindingStyling[button] or type(options) ~= "table" then return end

    local state = cooldown and addon.frameState[cooldown] or nil
    local timer = state and state.betterBlizzPlatesDurationText or nil
    if timer and durationText == timer then
        -- Keep BBP's actual formatter and curve object. Restoring this exact
        -- options table returns future BBP color updates to BBP ownership.
        state.betterBlizzPlatesOriginalDurationOptions = options
    end
end

local function GetCustomAuraButtonAPI(button)
    if customAuraButtonAPI then return customAuraButtonAPI end
    if not MCE:CanUseFrameAsTableKey(button) then return nil end

    local metaOk, meta = pcall(getmetatable, button)
    if not metaOk or type(meta) ~= "table" then return nil end
    local api = MCE:SafeTableGet(meta, "__index")
    if type(api) ~= "table"
       or type(MCE:SafeTableGet(api, "SetDurationCooldown")) ~= "function"
       or type(MCE:SafeTableGet(api, "SetDurationText")) ~= "function" then
        return nil
    end

    customAuraButtonAPI = api
    return customAuraButtonAPI
end

InstallLifecycleHooks = function(button)
    if not MCE:IsBetterBlizzPlatesAvailable() then return end

    local api = GetCustomAuraButtonAPI(button)
    if not api then return end

    if not durationCooldownHookInstalled
       and type(MCE:SafeTableGet(api, "SetDurationCooldown")) == "function" then
        durationCooldownHookInstalled = pcall(
            hooksecurefunc, api, "SetDurationCooldown", function(button)
                -- BBP assigns button.bbpCooldown immediately before binding it.
                -- Claim it before a generic nameplate scan can see the child.
                TrackAuraButton(button, false)
            end)
    end

    if not durationTextHookInstalled
       and type(MCE:SafeTableGet(api, "SetDurationText")) == "function" then
        durationTextHookInstalled = pcall(
            hooksecurefunc, api, "SetDurationText", function(button, durationText, options)
                -- Capture BBP's untouched duration FontString and anchor before
                -- MiniCE applies any typography.
                local cooldown = TrackAuraButton(button, false)
                CaptureBBPDurationBinding(button, cooldown, durationText, options)
            end)
    end

    if not finalStyleHookInstalled
       and type(MCE:SafeTableGet(api, "SetHideTooltipInCombat")) == "function" then
        finalStyleHookInstalled = pcall(
            hooksecurefunc, api, "SetHideTooltipInCombat", function(button)
                -- BBP calls this at the end of ApplyMutableStyle. Applying here
                -- lets every BBP option land first, then adds MiniCE's
                -- restricted styling.
                TrackAuraButton(button, true)
            end)
    end
end

local function InstallBBPAuraInitializerWrapper()
    if bbpAuraInitializerWrapped then return true end

    local mixin = MCE:SafeTableGet(_G, "CustomAuraContainerSharedMixin")
    local originalAddAuraGroup = type(mixin) == "table"
        and MCE:SafeTableGet(mixin, "AddAuraGroup") or nil
    if type(originalAddAuraGroup) ~= "function" then return false end

    local wrappedAddAuraGroup
    wrappedAddAuraGroup = function(container, groupKey, filter, options)
        local styles = MCE:SafeTableGet(container, "bbpStyles")
        local kind = MCE:SafeTableGet(container, "bbpKind")
        local initializeFrame = type(options) == "table"
            and MCE:SafeTableGet(options, "initializeFrame") or nil
        if type(styles) ~= "table" or kind == nil
           or type(initializeFrame) ~= "function" then
            return originalAddAuraGroup(container, groupKey, filter, options)
        end

        local wrappedOptions = {}
        for key, value in pairs(options) do
            wrappedOptions[key] = value
        end
        wrappedOptions.initializeFrame = function(button, ...)
            -- The provider invokes this while the real output button is still
            -- public. Install the secure post-hooks before BBP binds its timer.
            InstallLifecycleHooks(button)
            initializeFrame(button, ...)
            if not finalStyleHookInstalled then
                TrackAuraButton(button, true)
            end
        end
        return originalAddAuraGroup(
            container, groupKey, filter, wrappedOptions)
    end

    local ok = pcall(function()
        mixin.AddAuraGroup = wrappedAddAuraGroup
    end)
    bbpAuraInitializerWrapped = ok
        and mixin.AddAuraGroup == wrappedAddAuraGroup
    return bbpAuraInitializerWrapped
end

local function DiscoverContainer(container)
    if not MCE:CanUseFrameAsTableKey(container) then return end
    local groups = MCE:SafeTableGet(container, "bbpHasGroup")
        or MCE:SafeTableGet(container, "bbpStyles")
    local getCount = MCE:SafeTableGet(container, "GetAuraGroupFrameCount")
    local getFrame = MCE:SafeTableGet(container, "GetAuraGroupFrame")
    if type(groups) ~= "table" or type(getCount) ~= "function"
       or type(getFrame) ~= "function" then
        return
    end

    for groupKey in pairs(groups) do
        local countOk, frameCount = pcall(getCount, container, groupKey)
        if countOk and type(frameCount) == "number" then
            for frameIndex = 1, min(frameCount, MAX_SCANNED_AURA_GROUP_FRAMES) do
                local frameOk, button = pcall(getFrame, container, groupKey, frameIndex)
                if frameOk and button then
                    local cooldown = MCE:SafeTableGet(button, "bbpCooldown")
                    local state = MCE:SafeTableGet(addon.frameState, cooldown)
                    local captureNative = not (
                        state and state.betterBlizzPlatesMiniCEStyled == true)
                    MarkTrackedCooldown(cooldown, button, captureNative)
                end
            end
        end
    end
end

local function DiscoverExistingButtons()
    local bbp = MCE:SafeTableGet(_G, "BBP")
    local pool = MCE:SafeTableGet(bbp, "auraPool")
    local sets = MCE:SafeTableGet(pool, "sets")
    if type(sets) == "table" then
        for _, set in pairs(sets) do
            if type(set) == "table" then
                for _, kind in ipairs(BBP_CONSTANTS.AuraKinds) do
                    DiscoverContainer(MCE:SafeTableGet(set, kind))
                end
            end
        end
    end

    DiscoverContainer(MCE:SafeTableGet(bbp, "prdAuraContainer"))
end

function Adapter:CaptureTextOriginal(cooldown, region)
    local state = addon.frameState[cooldown]
    if state and state.betterBlizzPlatesAura == true then
        CaptureTextOriginal(state, region)
    end
end

function Adapter:GetNativeDrawEdge(cooldown)
    local state = addon.frameState[cooldown]
    if state and type(state.betterBlizzPlatesDrawEdge) == "boolean" then
        return state.betterBlizzPlatesDrawEdge
    end

    local settings = MCE:SafeTableGet(MCE:SafeTableGet(_G, "BBP"), "auraSettings")
    local hideSwipe = type(settings) == "table"
        and MCE:SafeTableGet(settings, "hideSwipe") or nil
    if type(hideSwipe) == "boolean" then return not hideSwipe end
    return true
end

function Adapter:ApplyDurationColorBinding(cooldown, config)
    return BindDurationText(cooldown, config, false)
end

function Adapter:RestoreNativeStyle(cooldown)
    local state = addon.frameState[cooldown]
    if not state or state.betterBlizzPlatesAura ~= true
       or state.betterBlizzPlatesMiniCEStyled ~= true then
        return
    end

    local originals = state.betterBlizzPlatesTextOriginals
    if originals then
        for region, original in pairs(originals) do
            if MCE:CanUseFrameAsTableKey(region) then
                addon.fontState[region] = nil
            end
            if IsObjectTypeSafe(region, "FontString") and type(original) == "table" then
                if original.fontPath and type(MCE:SafeTableGet(region, "SetFont")) == "function" then
                    pcall(region.SetFont, region,
                        original.fontPath, original.fontSize, original.fontStyle)
                end
                if original.color and type(MCE:SafeTableGet(region, "SetTextColor")) == "function" then
                    pcall(region.SetTextColor, region,
                        original.color.r, original.color.g,
                        original.color.b, original.color.a)
                end
                if original.points and type(MCE:SafeTableGet(region, "ClearAllPoints")) == "function"
                   and type(MCE:SafeTableGet(region, "SetPoint")) == "function" then
                    pcall(region.ClearAllPoints, region)
                    for pointIndex = 1, #original.points do
                        local point = original.points[pointIndex]
                        pcall(region.SetPoint, region,
                            point[1], point[2], point[3], point[4], point[5])
                    end
                end
            end
        end
    end

    if type(MCE:SafeTableGet(cooldown, "SetDrawEdge")) == "function"
       and type(state.betterBlizzPlatesDrawEdge) == "boolean" then
        pcall(cooldown.SetDrawEdge, cooldown, state.betterBlizzPlatesDrawEdge)
    end
    if type(MCE:SafeTableGet(cooldown, "SetEdgeScale")) == "function"
       and type(state.betterBlizzPlatesEdgeScale) == "number" then
        pcall(cooldown.SetEdgeScale, cooldown, state.betterBlizzPlatesEdgeScale)
    end

    -- BBP normally binds its own hidden/custom timer even when Blizzard's
    -- countdown is visible. Restore BBP's captured formatter and curve object
    -- so later BBP option changes remain fully BBP-owned.
    state.betterBlizzPlatesBoundDurationText = nil
    state.betterBlizzPlatesBoundDurationOptions = nil
    state.betterBlizzPlatesBoundDurationCurve = nil
    state.betterBlizzPlatesBoundDurationFormatter = nil
    state.betterBlizzPlatesDurationBinding = nil
    local button = state.betterBlizzPlatesAuraButton
    local timer = state.betterBlizzPlatesDurationText
    local options = state.betterBlizzPlatesOriginalDurationOptions
    local setDurationText = button and MCE:SafeTableGet(button, "SetDurationText") or nil
    local restored = type(setDurationText) == "function" and timer
        and type(options) == "table"
        and SetDurationBinding(button, setDurationText, timer, options)
    if not restored then
        -- Buttons discovered after BBP initialized may lack the captured table;
        -- use an equivalent BBP 12.1 binding as a safe fallback.
        BindDurationText(cooldown, nil, true)
    end
    state.betterBlizzPlatesMiniCEStyled = nil
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.BetterBlizzPlates, self)
    InstallBBPAuraInitializerWrapper()
    self:Rebuild()
end

function Adapter:Rebuild()
    InstallBBPAuraInitializerWrapper()
    if not MCE:IsBetterBlizzPlatesAuraCustomizationActive() then return end

    for cooldown in pairs(trackedCooldowns) do
        if MCE:CanUseFrameAsTableKey(cooldown) then
            local state = addon.frameState[cooldown]
            local button = MCE:SafeTableGet(state, "betterBlizzPlatesAuraButton")
            if state and state.betterBlizzPlatesAura == true then
                -- The AuraButton parent can become restricted while aura data
                -- is secret. Preserved initialization metadata is sufficient
                -- to keep the cooldown registered across a full rebuild.
                Registry:Register(cooldown, CATEGORY.BetterBlizzPlates)
            end
            if not MCE:CanUseFrameAsTableKey(button) then
                local getParent = MCE:SafeTableGet(cooldown, "GetParent")
                if type(getParent) == "function" then
                    local ok
                    ok, button = pcall(getParent, cooldown)
                    if not ok then button = nil end
                else
                    button = nil
                end
            end
            if button and MCE:IsBetterBlizzPlatesAuraCooldown(cooldown) then
                MarkTrackedCooldown(cooldown, button)
            end
        else
            trackedCooldowns[cooldown] = nil
        end
    end

    DiscoverExistingButtons()
end

function Adapter:TryClaim(cooldown)
    if not MCE:IsBetterBlizzPlatesAuraCustomizationActive()
       or not MCE:IsBetterBlizzPlatesAuraCooldown(cooldown) then
        return nil
    end

    local getParent = MCE:SafeTableGet(cooldown, "GetParent")
    if type(getParent) ~= "function" then return nil end
    local ok, button = pcall(getParent, cooldown)
    if not ok or not button then return nil end

    MarkTrackedCooldown(cooldown, button)
    return CATEGORY.BetterBlizzPlates
end

-- BBP builds its AuraContainer pool on later OnUpdate ticks. Wrap the public
-- initializer during file loading so the first real button can bootstrap the
-- shared lifecycle hooks without instantiating a restricted Blizzard template.
InstallBBPAuraInitializerWrapper()
