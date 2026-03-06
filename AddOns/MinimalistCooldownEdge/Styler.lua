-- Styler.lua – Style application, hooks, batch processing & nameplates (AceModule)
--
-- Uses AceHook for auto-unhook on disable and AceEvent for clean event lifecycle.

local MCE        = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Styler     = MCE:NewModule("Styler", "AceEvent-3.0", "AceHook-3.0")
local Classifier = MCE:GetModule("Classifier")

local pairs, ipairs, type, pcall, wipe = pairs, ipairs, type, pcall, wipe
local setmetatable = setmetatable
local C_Timer_After = C_Timer.After
local InCombatLockdown = InCombatLockdown
local EnumerateFrames  = EnumerateFrames
local GetTime = GetTime
local hooksecurefunc = hooksecurefunc

-- =========================================================================
-- CACHES  (weak-keyed → auto-collected with their frames)
-- =========================================================================

local trackedCooldowns = setmetatable({}, { __mode = "k" })
local styledCategory   = setmetatable({}, { __mode = "k" })

-- Anti-flicker: track last-applied API values per frame to skip redundant calls
local lastAppliedEdge      = setmetatable({}, { __mode = "k" })
local lastAppliedEdgeScale = setmetatable({}, { __mode = "k" })
local lastAppliedHideNums  = setmetatable({}, { __mode = "k" })

-- Re-entrancy guards for API enforcement hooks
local suppressEdgeEnforcement      = setmetatable({}, { __mode = "k" })
local suppressEdgeScaleEnforcement = setmetatable({}, { __mode = "k" })
local suppressHideNumsEnforcement  = setmetatable({}, { __mode = "k" })

-- =========================================================================
-- DURATION-BASED TEXT COLORING  (Action Bar only)
-- =========================================================================
-- Uses WoW-native APIs (C_CurveUtil ColorCurve + C_ActionBar DurationObject)
-- to avoid tainted/secret value issues in TWW+.  Same approach as tullaCTC.

-- Weak-keyed: tracks action bar cooldowns registered for color updates
local durationColoredFrames = setmetatable({}, { __mode = "k" })
local durationColorTicker = nil

-- Cached WoW ColorCurve built from user thresholds; invalidated on config change
local actionbarColorCurve = nil

local function QueueKnownCooldownMembers(frame, queueUpdate, forcedCategory)
    local seen = {}

    for i = 1, select("#", "cooldown", "Cooldown", "chargeCooldown", "ChargeCooldown") do
        local key = select(i, "cooldown", "Cooldown", "chargeCooldown", "ChargeCooldown")
        local cooldown = frame[key]
        if type(cooldown) == "table"
           and not seen[cooldown]
           and not MCE:IsForbidden(cooldown) then
            seen[cooldown] = true
            queueUpdate(cooldown, forcedCategory)
        end
    end
end

local function GetActionIDFromButton(parent)
    if not parent then return nil end

    local actionID = parent.action
    if type(actionID) == "number" then
        return actionID
    end

    if parent.GetAttribute then
        local ok, attr = pcall(parent.GetAttribute, parent, "action")
        if ok and type(attr) == "number" then
            return attr
        end
    end

    return nil
end

local function GetCooldownTextRegions(cdFrame)
    local results = {}
    local seen = {}

    local countdownText = cdFrame.GetCountdownFontString and cdFrame:GetCountdownFontString()
    if countdownText and not MCE:IsForbidden(countdownText) then
        results[1] = countdownText
        seen[countdownText] = true
    end

    if cdFrame.GetRegions then
        local numRegions = cdFrame.GetNumRegions and cdFrame:GetNumRegions() or 0
        if numRegions > 0 then
            local regions = { cdFrame:GetRegions() }
            for i = 1, numRegions do
                local region = regions[i]
                if region and region.GetObjectType
                   and region:GetObjectType() == "FontString"
                   and not seen[region]
                   and not MCE:IsForbidden(region) then
                    results[#results + 1] = region
                    seen[region] = true
                end
            end
        end
    end

    return results
end

--- Builds a WoW C_CurveUtil Step color curve from the threshold config.
--- Mirrors tullaCTC's generateColorCurve() logic.
local function BuildColorCurve(durationConfig)
    local thresholds = durationConfig.thresholds
    if not thresholds or #thresholds == 0 then return nil end

    local sortedThresholds = {}
    for i = 1, #thresholds do
        sortedThresholds[i] = thresholds[i]
    end

    table.sort(sortedThresholds, function(a, b)
        return (a.threshold or 0) < (b.threshold or 0)
    end)

    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)

    local offset = 0.5

    -- Point at 0: color for the shortest remaining time
    local c1 = sortedThresholds[1].color
    curve:AddPoint(0, CreateColor(c1.r, c1.g, c1.b, c1.a or 1))

    -- Intermediate threshold points
    for i = 2, #sortedThresholds do
        local startAt = (sortedThresholds[i - 1].threshold or 0) + offset
        local c = sortedThresholds[i].color
        curve:AddPoint(startAt, CreateColor(c.r, c.g, c.b, c.a or 1))
    end

    -- Default color for durations beyond the last threshold
    if durationConfig.defaultColor then
        local startAt = (sortedThresholds[#sortedThresholds].threshold or 0) + offset
        local dc = durationConfig.defaultColor
        curve:AddPoint(startAt, CreateColor(dc.r, dc.g, dc.b, dc.a or 1))
    end

    return curve
end

--- Invalidates the cached color curve (call on any config change).
local function InvalidateColorCurve()
    actionbarColorCurve = nil
end

--- Returns the color curve, building it lazily from current config.
local function GetColorCurve()
    if actionbarColorCurve then return actionbarColorCurve end

    local config = MCE.db and MCE.db.profile and MCE.db.profile.categories.actionbar
    if not config or not config.textColorByDuration or not config.textColorByDuration.enabled then
        return nil
    end

    actionbarColorCurve = BuildColorCurve(config.textColorByDuration)
    return actionbarColorCurve
end

--- Gets the WoW DurationObject for an action bar cooldown frame.
--- Uses C_ActionBar APIs that return untainted values (safe in TWW+).
local function GetActionBarDuration(cdFrame)
    local parent = cdFrame:GetParent()
    if not parent then return nil end

    local actionID = GetActionIDFromButton(parent)
    if not actionID then return nil end

    local chargeCooldown = parent.chargeCooldown or parent.ChargeCooldown
    if chargeCooldown == cdFrame then
        return C_ActionBar.GetActionChargeDuration(actionID)
    end

    return C_ActionBar.GetActionCooldownDuration(actionID)
end

--- Ticker callback: updates countdown text color on tracked action bar cooldowns.
local function UpdateDurationColors()
    local curve = GetColorCurve()
    if not curve then
        -- Feature disabled or no valid curve
        wipe(durationColoredFrames)
        if durationColorTicker then
            durationColorTicker:Cancel()
            durationColorTicker = nil
        end
        return
    end

    local hasActive = false

    for cdFrame in pairs(durationColoredFrames) do
        if cdFrame and not MCE:IsForbidden(cdFrame) then
            local duration = GetActionBarDuration(cdFrame)
            if duration then
                -- EvaluateRemainingDuration handles expired durations gracefully;
                -- we never call IsZero() as it returns secret-tainted booleans in TWW+.
                local text = cdFrame:GetCountdownFontString()
                if text then
                    local ok, color = pcall(duration.EvaluateRemainingDuration, duration, curve)
                    if ok and color then
                        hasActive = true
                        text:SetTextColor(color:GetRGBA())
                    else
                        durationColoredFrames[cdFrame] = nil
                    end
                else
                    hasActive = true
                end
            else
                -- No duration available (not an action bar frame or expired)
                durationColoredFrames[cdFrame] = nil
            end
        else
            durationColoredFrames[cdFrame] = nil
        end
    end

    if not hasActive and durationColorTicker then
        durationColorTicker:Cancel()
        durationColorTicker = nil
    end
end

local function StartDurationColorTicker()
    if durationColorTicker then return end
    durationColorTicker = C_Timer.NewTicker(0.1, UpdateDurationColors)
end

-- =========================================================================
-- BATCH PROCESSOR  (coalesces rapid hook fires into a single pass)
-- Eliminates visual flickering caused by rapid sequential API calls.
-- =========================================================================

local dirtyFrames = {}
local dirtyCount = 0
local batchTimerScheduled = false

local function MarkFrameDirty(frame, forcedCategory)
    local existing = dirtyFrames[frame]
    if existing == nil then
        dirtyCount = dirtyCount + 1
    end

    -- Preserve the strongest category hint seen during the current batch.
    if forcedCategory then
        dirtyFrames[frame] = forcedCategory
    elseif existing == nil then
        dirtyFrames[frame] = true
    end
end

local function ProcessDirtyFrames()
    batchTimerScheduled = false
    if dirtyCount == 0 then return end

    for frame, forcedCategory in pairs(dirtyFrames) do
        if frame and not MCE:IsForbidden(frame) then
            Styler:ApplyStyle(frame, forcedCategory ~= true and forcedCategory or nil)
        end
    end
    wipe(dirtyFrames)
    dirtyCount = 0
end

function Styler:QueueUpdate(frame, forcedCategory)
    if not frame or MCE:IsForbidden(frame) then return end
    if Classifier:IsBlacklisted(frame) then return end

    -- Always coalesce rapid hook bursts into a single pass.
    -- This matters most on action buttons / assisted-combat suggestions,
    -- where Blizzard can touch the same cooldown multiple times in one tick.
    MarkFrameDirty(frame, forcedCategory)

    if not batchTimerScheduled then
        batchTimerScheduled = true
        C_Timer_After(0, ProcessDirtyFrames)
    end
end

-- =========================================================================
-- LIFECYCLE
-- =========================================================================

function Styler:OnEnable()
    self:SetupHooks()

    if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        if InCombatLockdown() then self:PLAYER_REGEN_DISABLED() end
    end

    C_Timer_After(2, function()
        MCE:DebugPrint("Initial full scan scheduled on enable.")
        self:ForceUpdateAll(true)
    end)
    MCE:DebugPrint("Styler enabled.")
end

function Styler:OnDisable()
    if self.nameplateTicker then
        self.nameplateTicker:Cancel()
        self.nameplateTicker = nil
    end
    if durationColorTicker then
        durationColorTicker:Cancel()
        durationColorTicker = nil
    end
    wipe(durationColoredFrames)
    -- AceEvent auto-unregisters events; AceHook auto-unhooks.
end

-- =========================================================================
-- CHARGE COOLDOWN OVERLAP PREVENTION
-- =========================================================================
-- For charge-based abilities (e.g., Fire Blast, Shield of the Righteous),
-- WoW uses two separate cooldown frames on the same action button:
--   • button.cooldown       – the main/full cooldown (all charges spent)
--   • button.chargeCooldown – the per-charge recharge timer
-- When charges remain, only the chargeCooldown should show countdown text.
-- Without this guard, the addon's styling forces both frames to display
-- numbers simultaneously, causing the "overlapping timers" visual glitch.
local function IsMainCooldownWithActiveChargeCooldown(cdFrame)
    local parent = cdFrame:GetParent()
    if not parent then return false end

    -- Verify this frame is the *main* cooldown, not the charge cooldown
    local mainCD = parent.cooldown or parent.Cooldown
    if mainCD ~= cdFrame then return false end

    -- Check for a sibling charge cooldown that is currently visible
    local chargeCD = parent.chargeCooldown or parent.ChargeCooldown
    if chargeCD and chargeCD ~= cdFrame and not MCE:IsForbidden(chargeCD)
       and chargeCD.IsShown and chargeCD:IsShown() then
        return true
    end
    return false
end

local function GetDesiredHideCountdownNumbers(cdFrame, category, config)
    local hideNums = config.hideCountdownNumbers

    -- Charge-based abilities: force-hide numbers on the main cooldown
    -- when a charge cooldown is actively displaying its own timer,
    -- preventing overlapping countdown text.
    if category == "actionbar" and not hideNums
       and IsMainCooldownWithActiveChargeCooldown(cdFrame) then
        hideNums = true
    end

    return hideNums
end

local function IsSameValueSafe(a, b)
    local ok, same = pcall(function()
        return a == b
    end)

    if ok then
        return same
    end

    return false
end

-- =========================================================================
-- STACK COUNT STYLING  (action bar + CooldownManager viewers)
-- =========================================================================

function Styler:StyleStackCount(cdFrame, config, category)
    if not config.stackEnabled then return end

    local parent = cdFrame:GetParent()
    if not parent then return end

    local countRegion

    if category == "actionbar" then
        -- Action bar: standard Count region on the button
        local parentName = parent.GetName and parent:GetName()
        countRegion = parent.Count or (parentName and _G[parentName .. "Count"])
    elseif category == "global" then
        -- CooldownManager viewers:
        -- EssentialCooldownViewer / UtilityCooldownViewer:
        --   ChargeCount is a Frame (setAllPoints), ChargeCount.Current is the FontString.
        -- BuffIconCooldownViewer:
        --   Applications is a Frame (setAllPoints), Applications.Applications is the FontString.
        local chargeCount = parent.ChargeCount
        if chargeCount and chargeCount.Current then
            countRegion = chargeCount.Current
        end
        if not countRegion then
            local applications = parent.Applications
            if applications and applications.Applications then
                countRegion = applications.Applications
            end
        end
    end

    if not countRegion or not countRegion.GetObjectType then return end
    if countRegion:GetObjectType() ~= "FontString" then return end
    if MCE:IsForbidden(countRegion) then return end

    countRegion:SetFont(
        MCE.ResolveFontPath(config.stackFont),
        config.stackSize,
        MCE.NormalizeFontStyle(config.stackStyle))
    local sc = config.stackColor
    countRegion:SetTextColor(sc.r, sc.g, sc.b, sc.a)
    countRegion:ClearAllPoints()
    countRegion:SetPoint(config.stackAnchor, parent, config.stackAnchor,
        config.stackOffsetX, config.stackOffsetY)
    if countRegion.GetDrawLayer then
        countRegion:SetDrawLayer("OVERLAY", 7)
    end
end

-- =========================================================================
-- STYLE APPLICATION
-- =========================================================================
-- Main entry point called from the batch processor (ProcessDirtyFrames).
-- Uses change-detection on edge/countdown APIs to prevent visual flicker:
-- SetDrawEdge, SetEdgeScale, SetHideCountdownNumbers are only called when
-- their value actually differs from the last-applied value.

function Styler:ApplyStyle(cdFrame, forcedCategory)
    if MCE:IsForbidden(cdFrame) then return end
    if Classifier:IsBlacklisted(cdFrame) then return end

    trackedCooldowns[cdFrame] = true

    -- Override cached category when a specific one is forced (e.g., "actionbar" from hooks)
    if forcedCategory and forcedCategory ~= "global" then
        if Classifier:GetCategory(cdFrame) ~= forcedCategory then
            Classifier:SetCategory(cdFrame, forcedCategory)
            styledCategory[cdFrame] = nil
        end
    end

    -- Guard: DB must be ready
    if not (MCE.db and MCE.db.profile and MCE.db.profile.categories) then return end

    local category = forcedCategory or Classifier:GetCategory(cdFrame)

    -- Handle deferred aura classification (single retry, then fallback to global)
    if category == "aura_pending" then
        Classifier:SetCategory(cdFrame, nil)
        C_Timer_After(0.1, function()
            if cdFrame and not MCE:IsForbidden(cdFrame) then
                local retryCategory = Classifier:ClassifyFrame(cdFrame)
                if retryCategory == "aura_pending" then
                    retryCategory = "global"
                end
                Classifier:SetCategory(cdFrame, retryCategory)
                self:ApplyStyle(cdFrame)
            end
        end)
        return
    end

    if category == "blacklist" then
        MCE:LogStyleApplication(cdFrame, "blacklist", false)
        return
    end

    local config = MCE.db.profile.categories[category]
    if not config or not config.enabled then
        durationColoredFrames[cdFrame] = nil
        lastAppliedEdgeScale[cdFrame] = nil
        lastAppliedHideNums[cdFrame] = nil

        -- Disabled category: clear edge only if we previously set it (anti-flicker)
        if lastAppliedEdge[cdFrame] ~= false then
            if cdFrame.SetDrawEdge then
                lastAppliedEdge[cdFrame] = false
                suppressEdgeEnforcement[cdFrame] = true
                pcall(cdFrame.SetDrawEdge, cdFrame, false)
                suppressEdgeEnforcement[cdFrame] = nil
            end
        else
            lastAppliedEdge[cdFrame] = false
        end
        MCE:LogStyleApplication(cdFrame, category .. " (Disabled)", false)
        return
    end

    MCE:LogStyleApplication(cdFrame, category, true)

    -- === Duration-based text coloring (actionbar only) ===
    if category == "actionbar" and config.textColorByDuration
       and config.textColorByDuration.enabled then
        durationColoredFrames[cdFrame] = true
        StartDurationColorTicker()
    else
        durationColoredFrames[cdFrame] = nil
    end

    -- === Edge glow — only call API when value actually changed ===
    if cdFrame.SetDrawEdge then
        if lastAppliedEdge[cdFrame] ~= config.edgeEnabled then
            suppressEdgeEnforcement[cdFrame] = true
            pcall(cdFrame.SetDrawEdge, cdFrame, config.edgeEnabled)
            suppressEdgeEnforcement[cdFrame] = nil
            lastAppliedEdge[cdFrame] = config.edgeEnabled
        end
        if config.edgeEnabled and cdFrame.SetEdgeScale then
            if lastAppliedEdgeScale[cdFrame] ~= config.edgeScale then
                suppressEdgeScaleEnforcement[cdFrame] = true
                pcall(cdFrame.SetEdgeScale, cdFrame, config.edgeScale)
                suppressEdgeScaleEnforcement[cdFrame] = nil
                lastAppliedEdgeScale[cdFrame] = config.edgeScale
            end
        else
            lastAppliedEdgeScale[cdFrame] = nil
        end
    end

    -- === Hide/show countdown numbers — only call API when value changed ===
    if cdFrame.SetHideCountdownNumbers then
        local hideNums = GetDesiredHideCountdownNumbers(cdFrame, category, config)

        if lastAppliedHideNums[cdFrame] ~= hideNums then
            suppressHideNumsEnforcement[cdFrame] = true
            pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
            suppressHideNumsEnforcement[cdFrame] = nil
            lastAppliedHideNums[cdFrame] = hideNums
        end
    end

    -- Skip full font re-style if category hasn't changed (prevents text flashing)
    if styledCategory[cdFrame] ~= category then
        styledCategory[cdFrame] = category

        -- Stack / charge counts (actionbar + CooldownViewer globals)
        self:StyleStackCount(cdFrame, config, category)

        -- Font string styling & positioning
        do
            local fontStyle    = MCE.NormalizeFontStyle(config.fontStyle)
            local resolvedFont = MCE.ResolveFontPath(config.font)
            local textRegions  = GetCooldownTextRegions(cdFrame)

            for i = 1, #textRegions do
                local region = textRegions[i]
                region:SetFont(resolvedFont, config.fontSize, fontStyle)
                -- Always apply static text color as default
                if config.textColor then
                    local tc = config.textColor
                    region:SetTextColor(tc.r, tc.g, tc.b, tc.a)
                end
                if config.textAnchor then
                    region:ClearAllPoints()
                    region:SetPoint(config.textAnchor, cdFrame, config.textAnchor,
                        config.textOffsetX, config.textOffsetY)
                end
            end
        end
    end

    -- Apply duration-based color on EVERY call, not just first style.
    -- Must live outside the styledCategory guard: when a new cooldown starts
    -- on an already-styled action button, the text still carries the RED
    -- "expiring" color from the previous cooldown.  Without this, the color
    -- is only corrected 0-100 ms later by the ticker, causing a visible
    -- red flash on every cast.
    if category == "actionbar" and config.textColorByDuration
       and config.textColorByDuration.enabled then
        local duration = GetActionBarDuration(cdFrame)
        local curve = GetColorCurve()
        if duration and curve then
            local text = cdFrame:GetCountdownFontString()
            if text then
                local ok, color = pcall(duration.EvaluateRemainingDuration, duration, curve)
                if ok and color then
                    text:SetTextColor(color:GetRGBA())
                end
            end
        end
    end
end

-- =========================================================================
-- FORCE UPDATE
-- =========================================================================

function Styler:ForceUpdateAll(fullScan)
    MCE:DebugPrint("ForceUpdateAll called (fullScan=" .. tostring(fullScan) .. ").")

    -- Clear all caches so everything gets a fresh pass
    Classifier:WipeCache()
    wipe(styledCategory)
    wipe(lastAppliedEdge)
    wipe(lastAppliedEdgeScale)
    wipe(lastAppliedHideNums)
    wipe(durationColoredFrames)
    InvalidateColorCurve()
    if durationColorTicker then
        durationColorTicker:Cancel()
        durationColorTicker = nil
    end

    if fullScan or not self.fullScanDone then
        self.fullScanDone = true
        local frame = EnumerateFrames()
        while frame do
            if not MCE:IsForbidden(frame) then
                if frame:IsObjectType("Cooldown") then
                    self:QueueUpdate(frame)
                else
                    QueueKnownCooldownMembers(frame, function(cooldown)
                        self:QueueUpdate(cooldown)
                    end)
                end
            end
            frame = EnumerateFrames(frame)
        end
        return
    end

    -- Incremental: only update previously tracked cooldowns
    for cd in pairs(trackedCooldowns) do
        if cd and cd.IsObjectType and cd:IsObjectType("Cooldown") then
            self:QueueUpdate(cd)
        end
    end
end

-- =========================================================================
-- HOOKS  (AceHook: auto-unhook on Disable)
-- =========================================================================
-- All hooks queue frames into the batch processor instead of applying styles
-- directly, eliminating flickering from rapid sequential hook fires.

function Styler:SetupHooks()
    if not self.enforcementHooksInstalled then
        local sampleCooldown = ActionButton1Cooldown
            or (ActionButton1 and (ActionButton1.cooldown or ActionButton1.Cooldown))

        if sampleCooldown then
            local cooldownAPI = getmetatable(sampleCooldown)
            cooldownAPI = cooldownAPI and cooldownAPI.__index or sampleCooldown

            if type(cooldownAPI) == "table" then
                if type(cooldownAPI.SetDrawEdge) == "function" then
                    hooksecurefunc(cooldownAPI, "SetDrawEdge", function(cooldown, value)
                        if not cooldown or MCE:IsForbidden(cooldown) then return end
                        if suppressEdgeEnforcement[cooldown] then return end

                        local desired = lastAppliedEdge[cooldown]
                        if desired == nil or IsSameValueSafe(desired, value) then return end

                        suppressEdgeEnforcement[cooldown] = true
                        pcall(cooldown.SetDrawEdge, cooldown, desired)
                        suppressEdgeEnforcement[cooldown] = nil
                    end)
                end

                if type(cooldownAPI.SetEdgeScale) == "function" then
                    hooksecurefunc(cooldownAPI, "SetEdgeScale", function(cooldown, value)
                        if not cooldown or MCE:IsForbidden(cooldown) then return end
                        if suppressEdgeScaleEnforcement[cooldown] then return end

                        local desired = lastAppliedEdgeScale[cooldown]
                        if desired == nil or IsSameValueSafe(desired, value) then return end

                        suppressEdgeScaleEnforcement[cooldown] = true
                        pcall(cooldown.SetEdgeScale, cooldown, desired)
                        suppressEdgeScaleEnforcement[cooldown] = nil
                    end)
                end

                if type(cooldownAPI.SetHideCountdownNumbers) == "function" then
                    hooksecurefunc(cooldownAPI, "SetHideCountdownNumbers", function(cooldown, value)
                        if not cooldown or MCE:IsForbidden(cooldown) then return end
                        if suppressHideNumsEnforcement[cooldown] then return end

                        local desired = lastAppliedHideNums[cooldown]
                        if desired == nil or IsSameValueSafe(desired, value) then return end

                        suppressHideNumsEnforcement[cooldown] = true
                        pcall(cooldown.SetHideCountdownNumbers, cooldown, desired)
                        suppressHideNumsEnforcement[cooldown] = nil
                    end)
                end

                self.enforcementHooksInstalled = true
            end
        end
    end

    -- Primary hook: fires on every cooldown start/reset
    self:SecureHook("CooldownFrame_Set", function(f)
        if f and not MCE:IsForbidden(f) then self:QueueUpdate(f) end
    end)

    -- Action button specific hook (provides forced "actionbar" category)
    if ActionButton_UpdateCooldown then
        self:SecureHook("ActionButton_UpdateCooldown", function(button)
            local cd = button and (button.cooldown or button.Cooldown)
            if cd then self:QueueUpdate(cd, "actionbar") end

            local chargeCD = button and (button.chargeCooldown or button.ChargeCooldown)
            if chargeCD then self:QueueUpdate(chargeCD, "actionbar") end
        end)
    end

    -- LibActionButton support (Bartender4, etc.)
    local LAB = LibStub("LibActionButton-1.0", true)
    if LAB then
        LAB:RegisterCallback("OnButtonUpdate", function(_, button)
            local cd = button and (button.cooldown or button.Cooldown)
            if cd then
                self:QueueUpdate(cd, "actionbar")
            end

            local chargeCD = button and (button.chargeCooldown or button.ChargeCooldown)
            if chargeCD then
                self:QueueUpdate(chargeCD, "actionbar")
            end
        end)
    end
end

-- =========================================================================
-- NAMEPLATE EVENTS
-- =========================================================================

function Styler:NAME_PLATE_UNIT_ADDED(_, unit)
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end

    -- Single deferred call (batch processor coalesces any rapid follow-ups)
    C_Timer_After(0.05, function()
        if plate and not MCE:IsForbidden(plate) then
            self:StyleCooldownsInFrame(plate, "nameplate", 10)
        end
    end)
end

function Styler:RefreshVisibleNameplates()
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end

    for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do
        if plate and not MCE:IsForbidden(plate) then
            self:StyleCooldownsInFrame(plate, "nameplate", 10)
        end
    end
end

function Styler:PLAYER_REGEN_DISABLED()
    if self.nameplateTicker then return end
    self.nameplateTicker = C_Timer.NewTicker(0.5, function()
        self:RefreshVisibleNameplates()
    end)
end

function Styler:PLAYER_REGEN_ENABLED()
    if self.nameplateTicker then
        self.nameplateTicker:Cancel()
        self.nameplateTicker = nil
    end
end

-- =========================================================================
-- SCOPED SCANNING
-- =========================================================================
-- Recursively scans a frame tree and queues all Cooldown frames found
-- for batch style processing. Used primarily for nameplate scanning.

function Styler:StyleCooldownsInFrame(rootFrame, forcedCategory, maxDepth)
    if not rootFrame then return end
    maxDepth = maxDepth or 5

    local function scan(frame, depth)
        if not frame or depth > maxDepth then return end
        if MCE:IsForbidden(frame) then return end

        if frame.IsObjectType and frame:IsObjectType("Cooldown") then
            self:QueueUpdate(frame, forcedCategory)
        else
            QueueKnownCooldownMembers(frame, function(cooldown, category)
                self:QueueUpdate(cooldown, category)
            end, forcedCategory)
        end

        local childCount = frame.GetNumChildren and frame:GetNumChildren() or 0
        if childCount > 0 and frame.GetChildren then
            local children = { frame:GetChildren() }
            for i = 1, childCount do scan(children[i], depth + 1) end
        end
    end

    scan(rootFrame, 0)
end
