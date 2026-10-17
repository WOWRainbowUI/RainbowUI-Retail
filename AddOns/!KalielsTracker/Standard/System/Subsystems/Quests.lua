--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Quests")

local CACHE_SCHEMA = 1
local questsCache = {}

local function Quests_Ready(eventID)
    KT.QuestsCache_Update(true)
    KT:SendSignal("QUESTS_READY")
    KT:UnregEvent(eventID)
end

function KT.QuestsCache_Update(force)
    local data = questsCache.data
    local numQuests = 0
    local numQuestsOver = 0
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local headerTitle
    local validIDs = {}

    for i = 1, numEntries do
        local questInfo = C_QuestLog.GetInfo(i)
        if not questInfo.isHidden then
            if questInfo.isHeader then
                headerTitle = questInfo.title
            else
                if not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
                    local quest = data[questInfo.questID]
                    if not quest or force then
                        quest = {
                            title = questInfo.title,
                            level = questInfo.level,
                            zone = headerTitle,
                            isAccount = C_QuestLog.IsAccountQuest(questInfo.questID),
                            isCalling = C_QuestLog.IsQuestCalling(questInfo.questID),
                            startMapID = quest and quest.startMapID,
                            state = quest and quest.state or "",
                            updateTime = quest and quest.updateTime or 0
                        }
                        data[questInfo.questID] = quest
                    end
                    validIDs[questInfo.questID] = true

                    if not quest.isAccount and not quest.isCalling then
                        numQuests = numQuests + 1
                    else
                        numQuestsOver = numQuestsOver + 1
                    end
                end
            end
        end
    end

    if force then
        for questID in pairs(data) do
            if not validIDs[questID] then
                data[questID] = nil
            end
        end
    end

    return numQuests, numQuestsOver
end

function KT.QuestsCache_RemoveQuest(questID)
    questsCache.data[questID] = nil
end

function KT.QuestsCache_GetInfo(questID)
    return questsCache.data[questID]
end

function KT.QuestsCache_GetProperty(questID, key)
    local quest = questsCache.data[questID]
    return quest and quest[key]
end

function KT.QuestsCache_UpdateProperty(questID, key, value)
    local quest = questsCache.data[questID]
    if quest then
        quest[key] = value
    end
end

function KT.QuestsCache_Reset()
    wipe(questsCache.data)
end

function SS:Init(storage)
    if storage then
        questsCache = storage

        -- Legacy
        local legacyCache = rawget(KT.db.char.quests, "cache")
        if type(legacyCache) == "table" and next(legacyCache) then
            questsCache.data = legacyCache
            questsCache.schema = 0
        end
        rawset(KT.db.char.quests, "cache", nil)
    end

    questsCache.data = questsCache.data or {}
    questsCache.schema = questsCache.schema or CACHE_SCHEMA

    -- Migration
    if questsCache.schema == 0 then
        for _, quest in pairs(questsCache.data) do
            if quest.startMapID == 0 then
                quest.startMapID = nil
            end
        end
        questsCache.schema = 1
    end

    KT:RegEvent("PLAYER_ENTERING_WORLD", function(eventID, isInitialLogin, isReloadingUI)
        if isInitialLogin then
            KT:RegEvent("QUEST_POI_UPDATE", Quests_Ready, self)
        elseif isReloadingUI then
            KT:RegEvent("QUEST_LOG_UPDATE", Quests_Ready, self)
        end
        KT:UnregEvent(eventID)
    end, self)
end