--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@type KalielsTracker
local api = {}

---Toggle (public API)
--- - true - show the tracker
--- - false - hide the tracker
--- - empty (nil) - toggle the tracker
---@param show boolean|nil @show / hide / toggle
function api:Toggle(show)
    KT:ToggleTracker(show)
end

---@public
---@class KalielsTracker
KalielsTracker = setmetatable({}, { __index = api, __newindex = function() end, __metatable = false })