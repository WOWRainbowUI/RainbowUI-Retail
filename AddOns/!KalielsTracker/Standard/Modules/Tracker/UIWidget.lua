--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class UIWidget
local M = KT:NewModule("UIWidget")
KT.UIWidget = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00初始化|r - "..self:GetName(), true)
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00啟用|r - "..self:GetName(), true)
    KT:Tracker_RegisterModule("KT_UIWidgetObjectiveTracker", not self.isAvailable)
end