--- MSA-AceAddon-3.0
--- Extend default AceAddon-3.0
---
--- Marouan Sabbagh <mar.sabbagh@gmail.com>

local name, version = "MSA-AceAddon-3.0", 1

local AceAddon = LibStub:NewLibrary(name, version)
if not AceAddon then return end

-- Lua API
local pairs = pairs

local AceAddonRaw = LibStub("AceAddon-3.0")
local AceAddonApiRaw = {}

local function NewModule(...)
    local module = AceAddonApiRaw.NewModule(...)
    AceAddonRaw.addons[module.name] = nil
    return module
end

local mixins = {
    NewModule = NewModule
}

local function Embed(target)
    for k, v in pairs(mixins) do
        if not AceAddonApiRaw[k] then
            AceAddonApiRaw[k] = target[k]
        end
        target[k] = v
    end
end

function AceAddon:NewAddon(...)
    local addon = AceAddonRaw:NewAddon(...)
    AceAddonRaw.addons[addon.name] = nil
    Embed(addon)
    return addon
end

AceAddon = setmetatable(AceAddon, { __index = AceAddonRaw, __newindex = function() end, __metatable = false })