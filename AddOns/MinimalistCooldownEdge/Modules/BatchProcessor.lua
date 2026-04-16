-- BatchProcessor.lua – Coalesces rapid cooldown updates into a single style pass
--
-- When hooks fire rapidly (e.g., Blizzard touching the same button multiple
-- times in one tick), this batches them into one C_Timer.After(0) pass.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local BatchProcessor = MCE:NewModule("BatchProcessor")

local C_Timer_After = C_Timer.After
local wipe = wipe

local dirtyFrames = {}
local dirtyCount = 0
local batchScheduled = false

-- Style callback, set by Styler during initialization
local styleCallback = nil

function BatchProcessor:SetStyleCallback(fn)
    styleCallback = fn
end

local function ProcessDirtyFrames()
    batchScheduled = false
    if dirtyCount == 0 or not styleCallback then return end

    for frame, forcedCategory in pairs(dirtyFrames) do
        if frame and not MCE:IsForbiddenCached(frame) then
            styleCallback(frame, forcedCategory ~= true and forcedCategory or nil)
        end
    end
    wipe(dirtyFrames)
    dirtyCount = 0
end

function BatchProcessor:QueueUpdate(frame, forcedCategory)
    if not frame or MCE:IsForbiddenCached(frame) then return end

    local existing = dirtyFrames[frame]
    if existing == nil then
        dirtyCount = dirtyCount + 1
    end

    if forcedCategory then
        dirtyFrames[frame] = forcedCategory
    elseif existing == nil then
        dirtyFrames[frame] = true
    end

    if not batchScheduled then
        batchScheduled = true
        C_Timer_After(0, ProcessDirtyFrames)
    end
end

function BatchProcessor:Reset()
    wipe(dirtyFrames)
    dirtyCount = 0
    batchScheduled = false
end
