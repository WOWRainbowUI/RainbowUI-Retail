--- MSA-Quests-1.0
--- Copyright (c) 2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-Quests-1.0", 0

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

-- Lua API
local ipairs = ipairs
local tinsert = table.insert
local tremove = table.remove

local trackedQuests = {}
local selectedQuest = 0

local function GetTrackedQuest(questID)
    local result
    for _, quest in ipairs(trackedQuests) do
        if quest.id == questID then
            result = quest
            break
        end
    end
    return result
end

local function TrackQuest(questID, watchType)
    if not GetTrackedQuest(questID) then
        tinsert(trackedQuests, {
            id = questID,
            watchType = watchType
        })
    end
end

local function UntrackQuest(questID)
    for k, quest in ipairs(trackedQuests) do
        if quest.id == questID then
            tremove(trackedQuests, k)
            break
        end
    end
end

local function SanitizeQuests()
    local numEntries, _ = C_QuestLog.GetNumQuestLogEntries()
    print("|cff00ffff... Sanitize Quests ... ", numEntries)
    if numEntries == 0 then
        C_Timer.After(0.2, SanitizeQuests)
        return
    end

    for i = #trackedQuests, 1, -1 do
        local questID = trackedQuests[i].id
        local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if not questLogIndex or questLogIndex <= 0 then
            tremove(trackedQuests, i)
        end
    end
end

local function FireEvent(event, ...)
    print("|cffff00ffFIRE -|r", event, "-", ...)
    local frames = { GetFramesRegisteredForEvent(event) }
    for _, frame in ipairs(frames) do
        local func = frame:GetScript("OnEvent")
        if func then
            func(frame, event, ...)
        end
    end
end

local function Overrides()
    C_QuestLog.AddQuestWatch = function(questID, watchType)
        print("|cff00ff00Track ...", questID)
        TrackQuest(questID, watchType or 1)
        FireEvent("QUEST_WATCH_LIST_CHANGED", questID, true)
        return true
    end

    C_QuestLog.RemoveQuestWatch = function(questID)
        print("|cffff0000Untrack ...", questID)
        UntrackQuest(questID)
        FireEvent("QUEST_WATCH_LIST_CHANGED", questID)
        return true
    end

    C_QuestLog.GetNumQuestWatches = function()
        return #trackedQuests
    end

    C_QuestLog.GetQuestIDForQuestWatchIndex = function(questWatchIndex)
        return trackedQuests[questWatchIndex] and trackedQuests[questWatchIndex].id
    end

    local bck_C_QuestLog_GetQuestWatchType = C_QuestLog.GetQuestWatchType
    C_QuestLog.GetQuestWatchType = function(questID)
        local result
        if questID then
            if C_QuestLog.IsWorldQuest(questID) then
                result = bck_C_QuestLog_GetQuestWatchType(questID)
            else
                local quest = GetTrackedQuest(questID)
                result = quest and quest.watchType
            end
        end
        return result
    end

    hooksecurefunc(C_QuestLog, "SetSelectedQuest", function(questID)
        selectedQuest = questID
    end)

    hooksecurefunc(C_QuestLog, "AbandonQuest", function()
        UntrackQuest(selectedQuest)
        selectedQuest = 0
    end)
end

function lib:Init(saveTrackedQuests)
    trackedQuests = saveTrackedQuests
    Overrides()

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(self, event)
        SanitizeQuests()
        self:UnregisterEvent(event)
    end)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
end