--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

KT.Safe = {}

---@see _G#CooldownFrame_Set
function KT.Safe.CooldownFrame_Set(self, durationObj, isActive, forceShowDrawEdge)
    if isActive and durationObj then
        self:SetDrawEdge(not not forceShowDrawEdge)
        self:SetCooldownFromDurationObject(durationObj)
    else
        CooldownFrame_Clear(self)
    end
end

---@see _G#ShouldShowMawBuffs
function KT.Safe.ShouldShowMawBuffs()
    return IsInJailersTower()
end