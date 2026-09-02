local addonName, lv = ...
local L = lv.L

lv.Stats = lv.Stats or {}

local function EnsureDB()
    LiteVaultDB = LiteVaultDB or {}
    LiteVaultDB.instances = LiteVaultDB.instances or {}
    LiteVaultDB.instances.runs = LiteVaultDB.instances.runs or {}
    LiteVaultDB.instances.current = LiteVaultDB.instances.current or nil
    LiteVaultDB.legacyRaids = LiteVaultDB.legacyRaids or {}
    LiteVaultDB.legacyRaids.runs = LiteVaultDB.legacyRaids.runs or {}
    LiteVaultDB.instanceCap = LiteVaultDB.instanceCap or {}
    LiteVaultDB.instanceCap.hourlyRuns = LiteVaultDB.instanceCap.hourlyRuns or {}
    LiteVaultDB.instanceCap.lastWarning = LiteVaultDB.instanceCap.lastWarning or 0
end

local function StartOfCurrentResetDay()
    local now = time()
    if lv.GetSecondsUntilDailyReset then
        local untilReset = tonumber(lv.GetSecondsUntilDailyReset()) or 0
        -- Start = current time - elapsed since last daily reset.
        return now - math.max(0, 86400 - untilReset)
    end

    -- Fallback to local midnight if reset helper is unavailable.
    local t = date("*t", now)
    t.hour, t.min, t.sec = 0, 0, 0
    return time(t)
end

local function BuildCombinedRuns()
    EnsureDB()
    local out = {}
    for i, run in ipairs(LiteVaultDB.instances.runs) do
        local row = {}
        for k, v in pairs(run) do
            row[k] = v
        end
        row._lvSource = "instances"
        row._lvIndex = i
        out[#out + 1] = row
    end
    table.sort(out, function(a, b)
        local at = a.endTime or a.startTime or 0
        local bt = b.endTime or b.startTime or 0
        return at > bt
    end)
    return out
end

function lv.Stats.FormatDuration(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%d:%02d", m, s)
end

function lv.Stats.GetTodayRuns(runType)
    EnsureDB()
    local startDay = StartOfCurrentResetDay()
    local count = 0
    for _, run in ipairs(BuildCombinedRuns()) do
        local endTime = run.endTime or run.startTime or 0
        if endTime >= startDay then
            if not runType or run.type == runType then
                count = count + 1
            end
        end
    end
    return count
end

function lv.Stats.GetAverageTime(runType)
    EnsureDB()
    local startDay = StartOfCurrentResetDay()
    local total = 0
    local count = 0
    for _, run in ipairs(BuildCombinedRuns()) do
        local endTime = run.endTime or run.startTime or 0
        if endTime >= startDay and run.duration and run.duration > 0 then
            if not runType or run.type == runType then
                total = total + run.duration
                count = count + 1
            end
        end
    end
    if count == 0 then
        return 0
    end
    return math.floor(total / count)
end

function lv.Stats.GetRecentRuns(count)
    EnsureDB()
    local take = tonumber(count) or 5
    local combined = BuildCombinedRuns()
    local out = {}
    for i = 1, math.min(take, #combined) do
        out[#out + 1] = combined[i]
    end
    return out
end

function lv.Stats.GetTodayGold()
    EnsureDB()
    local startDay = StartOfCurrentResetDay()
    local total = 0
    for _, run in ipairs(LiteVaultDB.legacyRaids.runs) do
        local endTime = run.endTime or run.startTime or 0
        if endTime >= startDay then
            total = total + math.max(0, run.gold or 0)
        end
    end
    return total
end

function lv.Stats.EnsureDB()
    EnsureDB()
end
