--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("LocalizationService")

local overrides = {}

function KT.LocalizationService_Override(name, func)
    overrides[name] = func
end

function KT.LocalizationService_Reset(name)
    overrides[name] = nil
end

function KT.LocalizationService_Get(name, originalText, ...)
    local func = overrides[name]
    if func then
        local text = func(...)
        if text ~= nil then
            return text
        end
    end

    return originalText
end