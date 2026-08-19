-- BatchProcessor.lua – Coalesces rapid cooldown updates into a single style pass
--
-- When hooks fire rapidly (e.g., Blizzard touching the same button multiple
-- times in one tick), this batches them into a single pass driven by MiniCE's
-- own work driver frame (see Core.lua) so the cost is attributed to MiniCE.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local BatchProcessor = MCE:NewModule("BatchProcessor")

local RunNextFrame = addon.RunNextFrame
local wipe = wipe
local min = math.min

-- Processing a huge batch (e.g. a full-scan ForceUpdateAll touching every
-- action button on every bar) in one synchronous pass can trip WoW's
-- "script ran too long" watchdog, since each frame's ApplyStyle performs
-- several secure-frame pcalls. Cap how many frames are styled per tick and
-- spread the rest across subsequent frames.
local CHUNK_SIZE = 40

local dirtyFrames = {}
local dirtyCount = 0
local batchScheduled = false

-- Snapshot of the frames currently being processed, consumed CHUNK_SIZE at a time.
local snapshotFrames = {}
local snapshotForced = {}
local snapshotTotal = 0
local snapshotIndex = 0

-- Style callback, set by Styler during initialization
local styleCallback = nil

function BatchProcessor:SetStyleCallback(fn)
    styleCallback = fn
end

local function ProcessDirtyFrames()
    if snapshotIndex == 0 then
        if dirtyCount == 0 or not styleCallback then
            batchScheduled = false
            return
        end

        -- Snapshot into arrays and clear the live table up front so any
        -- QueueUpdate calls triggered by styleCallback below start a clean
        -- table for the next pass instead of mutating this one mid-iteration.
        snapshotTotal = 0
        for frame, forcedCategory in pairs(dirtyFrames) do
            snapshotTotal = snapshotTotal + 1
            snapshotFrames[snapshotTotal] = frame
            snapshotForced[snapshotTotal] = forcedCategory
        end
        wipe(dirtyFrames)
        dirtyCount = 0
        snapshotIndex = 1
    end

    local stop = min(snapshotIndex + CHUNK_SIZE - 1, snapshotTotal)
    for i = snapshotIndex, stop do
        local frame = snapshotFrames[i]
        local forcedCategory = snapshotForced[i]
        snapshotFrames[i] = nil
        snapshotForced[i] = nil
        if frame and not MCE:IsForbiddenCached(frame) then
            styleCallback(frame, forcedCategory ~= true and forcedCategory or nil)
        end
    end

    if stop >= snapshotTotal then
        snapshotIndex = 0
        snapshotTotal = 0
        if dirtyCount > 0 then
            RunNextFrame(ProcessDirtyFrames)
        else
            batchScheduled = false
        end
    else
        snapshotIndex = stop + 1
        RunNextFrame(ProcessDirtyFrames)
    end
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
        RunNextFrame(ProcessDirtyFrames)
    end
end

function BatchProcessor:Reset()
    wipe(dirtyFrames)
    dirtyCount = 0
    batchScheduled = false
    wipe(snapshotFrames)
    wipe(snapshotForced)
    snapshotTotal = 0
    snapshotIndex = 0
end
