--[[
    RGX-Framework - Database
--]]

local _, RGX = ...

function RGX:InitDatabase()
    _G.RGXFrameworkDB = _G.RGXFrameworkDB or {}
    self.db = _G.RGXFrameworkDB

    _G.RGXFrameworkDBChar = _G.RGXFrameworkDBChar or {}
    self.dbChar = _G.RGXFrameworkDBChar

    -- Apply defaults
    for k, v in pairs(self.defaults.global) do
        if self.db[k] == nil then
            self.db[k] = v
        end
    end

    self:Debug("Database initialized")
end

function RGX:GetDB()
    return self.db
end

-- Initialize a SavedVariables global and return it. Call inside OnLoad/OnLogin
-- so WoW has already restored saved values. Optional defaults table is applied
-- shallowly (keys are only set if nil).
--   local db = RGX:DB("MyAddonDB")
--   local db = RGX:DB("MyAddonDB", { volume = 1.0, debug = false })
function RGX:DB(name, defaults)
    _G[name] = _G[name] or {}
    local db = _G[name]
    if type(defaults) == "table" then
        for k, v in pairs(defaults) do
            if db[k] == nil then
                db[k] = v
            end
        end
    end
    return db
end
