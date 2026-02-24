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

-- =========================================================================
-- CACHES  (weak-keyed → auto-collected with their frames)
-- =========================================================================

local trackedCooldowns = setmetatable({}, { __mode = "k" })
local styledCategory   = setmetatable({}, { __mode = "k" })

-- Anti-flicker: track last-applied API values per frame to skip redundant calls
local lastAppliedEdge      = setmetatable({}, { __mode = "k" })
local lastAppliedEdgeScale = setmetatable({}, { __mode = "k" })
local lastAppliedHideNums  = setmetatable({}, { __mode = "k" })

-- =========================================================================
-- BATCH PROCESSOR  (coalesces rapid hook fires into a single pass)
-- Eliminates visual flickering caused by rapid sequential API calls.
-- =========================================================================

local dirtyFrames = {}
local dirtyCount = 0
local batchTimerScheduled = false

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

    -- Invalidate anti-flicker caches for this frame
    lastAppliedEdge[frame]      = nil
    lastAppliedEdgeScale[frame] = nil
    lastAppliedHideNums[frame]  = nil

    -- Already-classified frames: apply immediately (no flicker risk)
    if Classifier:IsCached(frame) then
        self:ApplyStyle(frame, forcedCategory)
        return
    end

    -- Unknown frames: defer to batch processor for classification.
    -- No existing style to flicker since they haven't been styled yet.
    if not dirtyFrames[frame] then
        dirtyCount = dirtyCount + 1
    end
    dirtyFrames[frame] = forcedCategory or true

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

-- =========================================================================
-- STACK COUNT STYLING  (action bar only)
-- =========================================================================

function Styler:StyleStackCount(cdFrame, config, category)
    if category ~= "actionbar" or not config.stackEnabled then return end

    local parent = cdFrame:GetParent()
    if not parent then return end

    local parentName  = parent.GetName and parent:GetName()
    local countRegion = parent.Count or (parentName and _G[parentName .. "Count"])

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
        -- Disabled category: clear edge only if we previously set it (anti-flicker)
        if lastAppliedEdge[cdFrame] ~= false then
            if cdFrame.SetDrawEdge then
                pcall(cdFrame.SetDrawEdge, cdFrame, false)
            end
            lastAppliedEdge[cdFrame] = false
        end
        MCE:LogStyleApplication(cdFrame, category .. " (Disabled)", false)
        return
    end

    MCE:LogStyleApplication(cdFrame, category, true)

    -- === Edge glow — only call API when value actually changed ===
    if cdFrame.SetDrawEdge then
        if lastAppliedEdge[cdFrame] ~= config.edgeEnabled then
            pcall(cdFrame.SetDrawEdge, cdFrame, config.edgeEnabled)
            lastAppliedEdge[cdFrame] = config.edgeEnabled
        end
        if config.edgeEnabled and cdFrame.SetEdgeScale then
            if lastAppliedEdgeScale[cdFrame] ~= config.edgeScale then
                pcall(cdFrame.SetEdgeScale, cdFrame, config.edgeScale)
                lastAppliedEdgeScale[cdFrame] = config.edgeScale
            end
        end
    end

    -- === Hide/show countdown numbers — only call API when value changed ===
    if cdFrame.SetHideCountdownNumbers then
        local hideNums = config.hideCountdownNumbers

        -- Charge-based abilities: force-hide numbers on the main cooldown
        -- when a charge cooldown is actively displaying its own timer,
        -- preventing overlapping countdown text.
        if category == "actionbar" and not hideNums
           and IsMainCooldownWithActiveChargeCooldown(cdFrame) then
            hideNums = true
        end

        if lastAppliedHideNums[cdFrame] ~= hideNums then
            pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
            lastAppliedHideNums[cdFrame] = hideNums
        end
    end

    -- Skip full font re-style if category hasn't changed (prevents text flashing)
    if styledCategory[cdFrame] == category then return end
    styledCategory[cdFrame] = category

    -- Stack counts (action bar only)
    self:StyleStackCount(cdFrame, config, category)

    -- Font string styling & positioning
    if not cdFrame.GetRegions then return end
    local numRegions = cdFrame.GetNumRegions and cdFrame:GetNumRegions() or 0
    if numRegions == 0 then return end

    local fontStyle    = MCE.NormalizeFontStyle(config.fontStyle)
    local resolvedFont = MCE.ResolveFontPath(config.font)
    local regions      = { cdFrame:GetRegions() }

    for i = 1, numRegions do
        local region = regions[i]
        if region:GetObjectType() == "FontString" and not MCE:IsForbidden(region) then
            region:SetFont(resolvedFont, config.fontSize, fontStyle)
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

    if fullScan or not self.fullScanDone then
        self.fullScanDone = true
        local frame = EnumerateFrames()
        while frame do
            if not MCE:IsForbidden(frame) then
                if frame:IsObjectType("Cooldown") then
                    self:QueueUpdate(frame)
                elseif frame.cooldown and type(frame.cooldown) == "table"
                   and not MCE:IsForbidden(frame.cooldown) then
                    self:QueueUpdate(frame.cooldown)
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
    -- Primary hook: fires on every cooldown start/reset
    self:SecureHook("CooldownFrame_Set", function(f)
        if f and not MCE:IsForbidden(f) then self:QueueUpdate(f) end
    end)

    -- Action button specific hook (provides forced "actionbar" category)
    if ActionButton_UpdateCooldown then
        self:SecureHook("ActionButton_UpdateCooldown", function(button)
            local cd = button and (button.cooldown or button.Cooldown)
            if cd then self:QueueUpdate(cd, "actionbar") end
        end)
    end

    -- LibActionButton support (Bartender4, etc.)
    local LAB = LibStub("LibActionButton-1.0", true)
    if LAB then
        LAB:RegisterCallback("OnButtonUpdate", function(_, button)
            if button and button.cooldown then
                self:QueueUpdate(button.cooldown, "actionbar")
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
        elseif frame.cooldown and type(frame.cooldown) == "table"
           and not MCE:IsForbidden(frame.cooldown) then
            self:QueueUpdate(frame.cooldown, forcedCategory)
        end

        local childCount = frame.GetNumChildren and frame:GetNumChildren() or 0
        if childCount > 0 and frame.GetChildren then
            local children = { frame:GetChildren() }
            for i = 1, childCount do scan(children[i], depth + 1) end
        end
    end

    scan(rootFrame, 0)
end
