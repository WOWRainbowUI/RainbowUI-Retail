--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

function KT.Storage_Init()
    KalielsTrackerCache = KalielsTrackerCache or {}
    KalielsTrackerCache.achievements = KalielsTrackerCache.achievements or {}
end