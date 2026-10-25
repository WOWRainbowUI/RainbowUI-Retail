local addonName, lv = ...

-- Temporary, read-only runtime research command for the future M+ planner.
-- This module deliberately has no SavedVariables or production score model.
local function Emit(message)
    local text = "|cffd4af37LiteVault M+ Planner Debug:|r " .. tostring(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then DEFAULT_CHAT_FRAME:AddMessage(text) else print(text) end
end

local function IsSafePrimitive(value)
    if issecretvalue and issecretvalue(value) then return false end
    local kind = type(value)
    return kind == "string" or kind == "number" or kind == "boolean"
end

local function SafeValue(value)
    if value == nil then return "nil" end
    if not IsSafePrimitive(value) then return "<" .. type(value) .. ">" end
    local ok, text = pcall(tostring, value)
    return ok and text or "<unavailable>"
end

local function SafeCall(owner, methodName, ...)
    local method = owner and owner[methodName]
    if type(method) ~= "function" then return nil end
    local results = { n=0 }
    local function Pack(...)
        results.n = select("#", ...)
        for index=1,results.n do results[index] = select(index, ...) end
    end
    Pack(pcall(method, ...))
    if not results[1] then return nil end
    return unpack(results, 2, results.n)
end

local function DumpPrimitiveTable(label, value)
    if type(value) ~= "table" then Emit(label .. " = " .. SafeValue(value)); return end
    local found = false
    local ok = pcall(function()
        for key, entry in pairs(value) do
            if IsSafePrimitive(key) and IsSafePrimitive(entry) then
                Emit(string.format("%s.%s = %s", label, SafeValue(key), SafeValue(entry))); found = true
            elseif IsSafePrimitive(key) and type(entry) == "table" then
                for nestedKey, nestedValue in pairs(entry) do
                    if IsSafePrimitive(nestedKey) and IsSafePrimitive(nestedValue) then
                        Emit(string.format("%s.%s.%s = %s", label, SafeValue(key), SafeValue(nestedKey), SafeValue(nestedValue))); found = true
                    end
                end
            end
        end
    end)
    if not ok then Emit(label .. " = <restricted table>"); return end
    if not found then Emit(label .. " = <no safe primitive fields>") end
end

local function GetMapName(mapID)
    local name, _, timeLimit = SafeCall(C_ChallengeMode, "GetMapUIInfo", mapID)
    return name, timeLimit
end

local function PrintSeasonBest(mapID)
    local intimeInfo, overtimeInfo = SafeCall(C_MythicPlus, "GetSeasonBestForMap", mapID)
    local function PrintRecord(kind, record)
        if type(record) ~= "table" then Emit("  " .. kind .. ": none"); return end
        Emit(string.format("  %s: level=%s durationSec=%s dungeonScore=%s", kind,
            SafeValue(record.level), SafeValue(record.durationSec), SafeValue(record.dungeonScore)))
    end
    PrintRecord("INTIME", intimeInfo)
    PrintRecord("OVERTIME", overtimeInfo)
    local displayBest, displayKind
    if type(intimeInfo) == "table" then displayBest, displayKind = intimeInfo, "INTIME" end
    if type(overtimeInfo) == "table" and (not displayBest or (tonumber(overtimeInfo.dungeonScore) or -1) > (tonumber(displayBest.dungeonScore) or -1)) then
        displayBest, displayKind = overtimeInfo, "OVERTIME"
    end
    if displayBest then
        Emit(string.format("  DISPLAY BEST: %s level=%s durationSec=%s dungeonScore=%s", displayKind,
            SafeValue(displayBest.level), SafeValue(displayBest.durationSec), SafeValue(displayBest.dungeonScore)))
    else
        Emit("  DISPLAY BEST: none")
    end
end

local function PrintAffixScoreData(mapID)
    local affixScores, bestOverAllScore = SafeCall(C_MythicPlus, "GetSeasonBestAffixScoreInfoForMap", mapID)
    Emit("  bestOverAllScore=" .. SafeValue(bestOverAllScore))
    if type(affixScores) ~= "table" then Emit("  affixScores: none"); return end
    Emit("  affixScores count=" .. #affixScores)
    for index, entry in ipairs(affixScores) do
        Emit(string.format("  affixScores[%d]: name=%s score=%s level=%s durationSec=%s overTime=%s", index,
            SafeValue(entry.name), SafeValue(entry.score), SafeValue(entry.level), SafeValue(entry.durationSec), SafeValue(entry.overTime)))
        DumpPrimitiveTable("  affixScores[" .. index .. "]", entry)
    end
end

local function PrintMapScoreInfo()
    Emit("MAP SCORE INFO")
    local first, second, third, fourth, fifth = SafeCall(C_ChallengeMode, "GetMapScoreInfo")
    local displayScores
    for _, candidate in pairs({first, second, third, fourth, fifth}) do
        if type(candidate) == "table" then
            if type(candidate.displayScores) == "table" then displayScores = candidate.displayScores; break end
            if not displayScores and #candidate > 0 then displayScores = candidate end
        end
    end
    if type(displayScores) ~= "table" then Emit("  displayScores: none"); return end
    for index, entry in ipairs(displayScores) do DumpPrimitiveTable("  displayScores[" .. index .. "]", entry) end
end

local function PrintCurrentAffixes()
    Emit("CURRENT AFFIXES")
    local affixes = SafeCall(C_MythicPlus, "GetCurrentAffixes")
    if type(affixes) ~= "table" then Emit("  none/unavailable"); return end
    for index, entry in ipairs(affixes) do
        local id = type(entry) == "table" and (entry.id or entry.affixID) or entry
        local seasonID = type(entry) == "table" and entry.seasonID or nil
        local name = SafeCall(C_ChallengeMode, "GetAffixInfo", id)
        Emit(string.format("  [%d] id=%s seasonID=%s name=%s", index, SafeValue(id), SafeValue(seasonID), SafeValue(name)))
    end
end

local function GetResearchCandidateScore(level, durationSec, timeLimit)
    return lv.MPlusPlanner and lv.MPlusPlanner.EstimateTimedScore(level, durationSec, timeLimit)
end

local function PrintRunHistory(currentSeason)
    Emit("RUN HISTORY (unfiltered recent sample)")
    local history = SafeCall(C_MythicPlus, "GetRunHistory", true, false, true)
    if type(history) ~= "table" then Emit("  none/unavailable"); return end
    Emit("  total history records returned=" .. #history)
    local printed = 0
    for _, run in ipairs(history) do
        local runSeason = run.seasonID or run.season
        local mapID = run.mapChallengeModeID or run.challengeMapID
        local name, timeLimit = GetMapName(mapID)
        local sameSeason
        if currentSeason ~= nil and runSeason ~= nil then sameSeason = tonumber(runSeason) == tonumber(currentSeason) end
        local candidate = GetResearchCandidateScore(run.level, run.durationSec, timeLimit)
        local difference = candidate and tonumber(run.runScore) and (tonumber(run.runScore) - candidate) or nil
        Emit(string.format("  mapChallengeModeID=%s name=%s level=%s thisWeek=%s completed=%s runScore=%s durationSec=%s season=%s currentSeasonMatch=%s",
            SafeValue(mapID), SafeValue(name), SafeValue(run.level), SafeValue(run.thisWeek), SafeValue(run.completed),
            SafeValue(run.runScore), SafeValue(run.durationSec), SafeValue(runSeason), SafeValue(sameSeason)))
        Emit(string.format("    RESEARCH candidateEstimate=%s difference(actual-candidate)=%s", candidate and string.format("%.2f", candidate) or "unavailable", difference and string.format("%.2f", difference) or "unavailable"))
        printed = printed + 1
        if printed >= 25 then break end
    end
    if printed == 0 then Emit("  no history records") end
end

SLASH_LVMPLUSPLANNERDEBUG1 = "/lvmplusplannerdebug"
SlashCmdList["LVMPLUSPLANNERDEBUG"] = function()
    Emit("BEGIN")
    local version, build, buildDate, interfaceVersion = SafeCall(_G, "GetBuildInfo")
    Emit(string.format("client version=%s build=%s buildDate=%s interface=%s", SafeValue(version), SafeValue(build), SafeValue(buildDate), SafeValue(interfaceVersion)))
    local currentSeason = SafeCall(C_MythicPlus, "GetCurrentSeason")
    Emit("currentSeason=" .. SafeValue(currentSeason))
    local overallScore = SafeCall(C_ChallengeMode, "GetOverallDungeonScore")
    Emit("overallDungeonScore=" .. SafeValue(overallScore))

    Emit("CURRENT MAPS")
    local maps = SafeCall(C_ChallengeMode, "GetMapTable")
    if type(maps) == "table" then
        for _, mapID in ipairs(maps) do
            local name, timeLimit = GetMapName(mapID)
            Emit(string.format("MAP mapChallengeModeID=%s name=%s timeLimit=%s", SafeValue(mapID), SafeValue(name), SafeValue(timeLimit)))
            PrintSeasonBest(mapID)
            PrintAffixScoreData(mapID)
        end
    else
        Emit("  no maps/unavailable")
    end
    PrintMapScoreInfo()
    PrintCurrentAffixes()
    PrintRunHistory(currentSeason)
    Emit("END")
end
