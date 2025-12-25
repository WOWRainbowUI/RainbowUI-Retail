--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Achievements")

local BUILD_VERSION = select(1, KT.GAME_VERSION)
local achievsCache = {}

function KT.AchievementsCache_Build()
    local cache = {}

    local categories = GetCategoryList() or {}
    for _, categoryID in ipairs(categories) do
        local _, parentID = GetCategoryInfo(categoryID)
        local numAchievs = GetCategoryNumAchievements(categoryID)
        if numAchievs > 0 then
            cache[categoryID] = {}
            for i = 1, numAchievs do
                local id, name, _, _, _, _, _, description = GetAchievementInfo(categoryID, i)
                if id then
                    cache[categoryID][id] = {
                        name = name,
                        description = description,
                        categoryID = categoryID,
                        parentID = parentID,
                    }
                end
            end
        end
    end

    achievsCache.build = BUILD_VERSION
    achievsCache.locale = KT.LOCALE
    achievsCache.data = cache
end

function KT.AchievementsCache_GetCategory(id)
    return achievsCache.data and achievsCache.data[id] or {}
end

function KT.AchievementsCache_GetByID(id)
    for _, achievs in pairs(achievsCache.data) do
        if achievs[id] then
            return achievs[id]
        end
    end
end

function KT.AchievementsCache_Reset(storage)
    if storage then
        achievsCache = storage
    end

    wipe(achievsCache)
    achievsCache.data = {}
end

function SS:Init(storage)
    if storage then
        achievsCache = storage
    end

    achievsCache.data = achievsCache.data or {}

    KT:RegEvent("PLAYER_ENTERING_WORLD", function(eventID)
        if not (achievsCache and
                achievsCache.build == BUILD_VERSION and
                achievsCache.locale == KT.LOCALE) then
            KT.AchievementsCache_Build()
        end
        KT:UnregEvent(eventID)
    end, self)
end