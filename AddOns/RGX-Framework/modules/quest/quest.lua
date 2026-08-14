--=====================================================================================
-- RGX-Framework | RGXQuest
-- Quest accept, completion, turn-in, and objective progress callbacks.
--=====================================================================================

local addonName, RGX = ...

local Quest = {
    _eventsInit = false,
    _onAccepted = {},
    _onComplete = {},
    _onTurnedIn = {},
    _onProgress = {},
    _progressCooldowns = {},
    _objectiveCache = {},
}

local PROGRESS_COOLDOWN_SECONDS = 0.25

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    list[#list + 1] = fn
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXQuest] Callback error: " .. tostring(err)) end
    end
end

local function ResolveQuestID(questRef)
    if type(questRef) ~= "number" or questRef <= 0 then return nil end

    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local index = C_QuestLog.GetLogIndexForQuestID(questRef)
        if type(index) == "number" and index > 0 then return questRef end
    end

    if C_QuestLog and C_QuestLog.GetQuestIDForQuestWatchIndex then
        local watched = C_QuestLog.GetQuestIDForQuestWatchIndex(questRef)
        if type(watched) == "number" and watched > 0 then return watched end
    end

    if RGX.API and RGX.API.GetQuestLogInfo then
        local info = RGX.API.GetQuestLogInfo(questRef)
        if info and type(info.questID) == "number" and info.questID > 0 then return info.questID end
    end

    return questRef
end

local function BuildObjectiveSnapshot(questID)
    if type(questID) ~= "number" or questID <= 0 then return nil end
    local objectives = RGX.API and RGX.API.GetQuestObjectives and RGX.API.GetQuestObjectives(questID)
    if type(objectives) ~= "table" then return nil end

    local snapshot, hasEntries = {}, false
    for index, objective in ipairs(objectives) do
        if type(objective) == "table" then
            local text = objective.text or ("objective_" .. tostring(index))
            snapshot[index] = {
                fulfilled = tonumber(objective.numFulfilled) or 0,
                required = tonumber(objective.numRequired) or 0,
                finished = objective.finished == true,
                percent = tonumber(string.match(text, "(%d+)%%")),
                text = text,
            }
            hasEntries = true
        end
    end

    return hasEntries and snapshot or nil
end

local function DidProgressIncrease(previous, current)
    if type(previous) ~= "table" or type(current) ~= "table" then return false end

    for index, now in pairs(current) do
        local old = previous[index]
        if old then
            if (now.percent or 0) > (old.percent or 0) then return true end
            if (now.fulfilled or 0) > (old.fulfilled or 0) then return true end
            if now.finished and not old.finished then return true end
        end
    end

    return false
end

function Quest:RefreshObjectiveCache()
    local refreshed = {}
    local count = RGX.API and RGX.API.GetNumQuestLogEntries and RGX.API.GetNumQuestLogEntries() or 0
    for index = 1, count do
        local info = RGX.API.GetQuestLogInfo(index)
        local questID = info and info.questID
        if type(questID) == "number" and questID > 0 then
            refreshed[questID] = BuildObjectiveSnapshot(questID)
        end
    end
    self._objectiveCache = refreshed
end

function Quest:OnAccepted(fn) return AddCb(self._onAccepted, fn) end
function Quest:OnComplete(fn) return AddCb(self._onComplete, fn) end
function Quest:OnTurnedIn(fn) return AddCb(self._onTurnedIn, fn) end
function Quest:OnProgress(fn) return AddCb(self._onProgress, fn) end

function Quest:_FireProgress(questID, source)
    questID = ResolveQuestID(questID)
    if type(questID) ~= "number" or questID <= 0 then return end

    local now = GetTime and GetTime() or 0
    local last = self._progressCooldowns[questID]
    if last and (now - last) < PROGRESS_COOLDOWN_SECONDS then return end
    self._progressCooldowns[questID] = now

    local snapshot = BuildObjectiveSnapshot(questID)
    self._objectiveCache[questID] = snapshot or self._objectiveCache[questID]
    Fire(self._onProgress, questID, snapshot, source)
end

function Quest:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("QUEST_ACCEPTED", function(_, questID)
        if type(questID) == "number" and questID > 0 then
            Quest._objectiveCache[questID] = BuildObjectiveSnapshot(questID)
        end
        Fire(Quest._onAccepted, questID)
    end, "RGXQuest_Accepted")

    RGX:RegisterEvent("QUEST_COMPLETE", function(...)
        Fire(Quest._onComplete, ...)
    end, "RGXQuest_Complete")

    RGX:RegisterEvent("QUEST_TURNED_IN", function(_, questID, xpReward, moneyReward)
        if type(questID) == "number" and questID > 0 then
            Quest._objectiveCache[questID] = nil
            Quest._progressCooldowns[questID] = nil
        end
        Fire(Quest._onTurnedIn, questID, xpReward, moneyReward)
    end, "RGXQuest_TurnedIn")

    RGX:RegisterEvent("QUEST_WATCH_UPDATE", function(_, questID)
        Quest:_FireProgress(questID, "QUEST_WATCH_UPDATE")
    end, "RGXQuest_WatchUpdate")

    RGX:RegisterEvent("QUEST_LOG_UPDATE", function()
        local count = RGX.API and RGX.API.GetNumQuestLogEntries and RGX.API.GetNumQuestLogEntries() or 0
        for index = 1, count do
            local info = RGX.API.GetQuestLogInfo(index)
            local questID = info and info.questID
            if type(questID) == "number" and questID > 0 then
                local current = BuildObjectiveSnapshot(questID)
                local previous = Quest._objectiveCache[questID]
                Quest._objectiveCache[questID] = current or previous
                if current and previous and DidProgressIncrease(previous, current) then
                    Quest:_FireProgress(questID, "QUEST_LOG_UPDATE")
                end
            end
        end
    end, "RGXQuest_LogUpdate")

    self:RefreshObjectiveCache()
end

_G.RGXQuest = Quest
RGX:RegisterModule("quest", Quest)
