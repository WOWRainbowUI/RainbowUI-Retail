--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@type KalielsTracker
local api = {}

---Toggle tracker visibility (public API).
---@param show boolean|nil Tracker visibility (true = show, false = hide, nil = toggle)
function api:Toggle(show)
    if show == nil then
        KT:SetHidden()
    else
        KT:SetHidden(not show)
    end
end

---@public
---@class KalielsTracker
KalielsTracker = setmetatable({}, { __index = api, __newindex = function() end, __metatable = false })