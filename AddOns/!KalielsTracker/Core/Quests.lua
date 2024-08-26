--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local _, KT = ...

-- Quests Cache
local questsCache = {}

function KT.QuestsCache_Update(isForced)
    local numQuests = 0
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local headerTitle

    for i = 1, numEntries do
        local questInfo = C_QuestLog.GetInfo(i)
        if not questInfo.isHidden then
            if questInfo.isHeader then
                headerTitle = questInfo.title
            else
                if not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
                    if not questsCache[questInfo.questID] or isForced then
                        questsCache[questInfo.questID] = {
                            title = questInfo.title,
                            level = questInfo.level,
                            zone = headerTitle,
                            startMapID = questsCache[questInfo.questID] and questsCache[questInfo.questID].startMapID or 0,
                            isCalling = C_QuestLog.IsQuestCalling(questInfo.questID)
                        }
                    end
                end
                if not C_QuestLog.IsQuestCalling(questInfo.questID) then
                    numQuests = numQuests + 1
                end
            end
        end
    end

    return numQuests
end

function KT.QuestsCache_GetInfo(questID)
    return questsCache[questID] and questsCache[questID]
end

function KT.QuestsCache_GetProperty(questID, key)
    return questsCache[questID] and questsCache[questID][key]
end

function KT.QuestsCache_UpdateProperty(questID, key, value)
    if questsCache[questID] then
        questsCache[questID][key] = value
    end
end

function KT.QuestsCache_RemoveQuest(questID)
    questsCache[questID] = nil
end

function KT.QuestsCache_Init()
    return KT.QuestsCache_Update(true)
end

-- Init
function KT.Quests_Init(store)
    questsCache = store.cache

    KT:RegEvent("QUEST_LOG_UPDATE", function(eventID)
        local numEntries = C_QuestLog.GetNumQuestLogEntries()
        if numEntries > 1 then
            KT.QuestsCache_Init()
            KT:UnregEvent(eventID)
        end
    end)
end