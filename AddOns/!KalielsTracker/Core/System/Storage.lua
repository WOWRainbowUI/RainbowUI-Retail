--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

function KT:Storage_Init()
    KalielsTrackerCache = KalielsTrackerCache or {}

    -- Quests
    local charKey = self.db.keys.char
    KalielsTrackerCache.quests = KalielsTrackerCache.quests or {}
    KalielsTrackerCache.quests[charKey] = KalielsTrackerCache.quests[charKey] or {}

    -- Achievements
    KalielsTrackerCache.achievements = KalielsTrackerCache.achievements or {}

    self.storage = {
        quests = KalielsTrackerCache.quests[charKey],
        achievements = KalielsTrackerCache.achievements,
    }
end