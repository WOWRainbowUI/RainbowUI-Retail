--- MSA-AceAddon-3.0
--- Extend default AceAddon-3.0
---
--- Marouan Sabbagh <mar.sabbagh@gmail.com>

local name, version = "MSA-AceAddon-3.0", 0

local AceAddon = LibStub:NewLibrary(name, version)
if not AceAddon then return end

-- Lua API
local pairs = pairs

AceAddon.raw = LibStub("AceAddon-3.0")

local function NewModule(self, ...)
	local module = self:NewModuleRaw(...)
	AceAddon.raw.addons[module.name] = nil
	return module
end

local mixins = {
	NewModule = NewModule
}

local function Embed(target)
	for k, v in pairs(mixins) do
		target[k.."Raw"] = target[k]
		target[k] = v
	end
end

function AceAddon:NewAddon(...)
	local addon = self.raw:NewAddon(...)
	self.raw.addons[addon.name] = nil
	Embed(addon)
	return addon
end

AceAddon = setmetatable(AceAddon, { __index = AceAddon.raw, __newindex = function() end, __metatable = false })