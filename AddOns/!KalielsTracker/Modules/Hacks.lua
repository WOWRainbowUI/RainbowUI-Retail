--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Hacks
local M = KT:NewModule("Hacks")
KT.Hacks = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

local function Noop() end



function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true

    if self.isAvailable then

    end
end