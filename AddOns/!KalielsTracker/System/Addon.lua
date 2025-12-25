--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

-- Subsystem

KT.subsystems = {}
KT.subsystemsOrder = {}

---@class Subsystem
---@field name string Subsystem name
---@field Init fun(self: Subsystem, ...)|nil Initialization function

---Create a new subsystem.
---@param name string Subsystem name
---@return Subsystem Subsystem object
function KT:NewSubsystem(name)
    self.Assert(name, "NewSubsystem", "name", "string", type(name) == "string" and name ~= "")
    self.Assert(self.subsystems[name], "NewSubsystem", name, "nil")

    ---@type Subsystem
    local subsystem = {
        name = name
    }
    self.subsystems[name] = subsystem
    tinsert(self.subsystemsOrder, name)

    return subsystem
end

---Initialize all subsystems that have an Init method.
---@param settings table|nil Attributes for each subsystem
function KT:InitSubsystems(settings)
    for _, name in ipairs(self.subsystemsOrder) do
        local subsys = self.subsystems[name]
        if subsys.Init then
            if settings and settings[name] then
                subsys:Init(unpack(settings[name]))
            else
                subsys:Init()
            end
        end
    end
end

-- Module

---Enable all modules.
function KT:EnableModules()
    for _, module in ipairs(self.orderedModules) do
        if module.isAvailable and module.OnEnable then
            module:Enable()
        end
    end
end