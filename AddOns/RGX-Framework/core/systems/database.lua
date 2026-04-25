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
