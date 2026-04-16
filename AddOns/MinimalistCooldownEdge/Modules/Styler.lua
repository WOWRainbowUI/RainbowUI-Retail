-- Styler.lua – Thin orchestrator
--
-- Coordinates the adapter-driven registry model. Connects BatchProcessor
-- to StyleEngine, manages the overall lifecycle, and provides ForceUpdateAll.
-- No EnumerateFrames – discovery is adapters-only.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Styler = MCE:NewModule("Styler")

local wipe = wipe
local C_Timer_After = C_Timer.After

local CATEGORY = C.Categories

local Registry, BatchProcessor, StyleEngine, DurationColor, CompactAura, Classifier

-- =========================================================================
-- LIFECYCLE
-- =========================================================================

function Styler:OnEnable()
    Registry       = MCE:GetModule("TargetRegistry")
    BatchProcessor = MCE:GetModule("BatchProcessor")
    StyleEngine    = MCE:GetModule("StyleEngine")
    DurationColor  = MCE:GetModule("DurationColorController")
    CompactAura    = MCE:GetModule("CompactGroupAuraController")
    Classifier     = MCE:GetModule("Classifier")

    -- Wire batch processor → StyleEngine
    BatchProcessor:SetStyleCallback(function(cdFrame, forcedCategory)
        StyleEngine:ApplyStyle(cdFrame, forcedCategory)
    end)

    -- Initial adapter-driven discovery (short delay so frames exist)
    C_Timer_After(2, function()
        self:ForceUpdateAll(true)
    end)
end

function Styler:OnDisable()
    DurationColor:Reset()
    CompactAura:Reset(true)
    BatchProcessor:Reset()
    StyleEngine:WipeState()
    Registry:WipeAll()
end

-- =========================================================================
-- QUEUE + APPLY  (delegations)
-- =========================================================================

function Styler:QueueUpdate(frame, forcedCategory)
    if not frame or MCE:IsForbiddenCached(frame) then return end
    if Classifier and Classifier:IsBlacklisted(frame) then return end
    BatchProcessor:QueueUpdate(frame, forcedCategory)
end

function Styler:StyleStackCount(cdFrame, config, category)
    StyleEngine:StyleStackCount(cdFrame, config, category)
end

-- =========================================================================
-- FORCE UPDATE  (no EnumerateFrames)
-- =========================================================================

function Styler:ForceUpdateAll(fullScan)
    -- Reset all module state
    DurationColor:Reset()
    -- During an internal refresh, keep current compact-aura visuals until the
    -- next style pass instead of briefly restoring Blizzard native text.
    CompactAura:Reset(false)
    StyleEngine:WipeState()
    BatchProcessor:Reset()

    if fullScan then
        -- Full rebuild: wipe registry, ask every adapter to re-discover
        Registry:WipeAll()
        Registry:RebuildAll()
    end

    -- Queue all registered cooldowns for restyling
    for cd in Registry:IterateAll() do
        if cd and not MCE:IsForbiddenCached(cd) then
            BatchProcessor:QueueUpdate(cd)
        end
    end
end
