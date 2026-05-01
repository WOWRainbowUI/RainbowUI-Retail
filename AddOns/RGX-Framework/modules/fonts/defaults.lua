local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:SetDefault(name)
	if not self:Exists(name) then
		RGX:Debug("Fonts: Cannot set default - font not found:", name)
		return false
	end
	if not self:IsAvailable(name) then
		RGX:Debug("Fonts: Cannot set default - font unavailable:", name)
		return false
	end
	self.default = name
	return true
end

function Fonts:GetDefault()
	return self.default
end

function Fonts:SetDefaultSize(size)
	self.defaultSize = size
end

function Fonts:SetDefaultFlags(flags)
	self.defaultFlags = self:NormalizeFlags(flags)
end

function Fonts:SetAutoScale(enable)
	self.autoScale = enable
end
