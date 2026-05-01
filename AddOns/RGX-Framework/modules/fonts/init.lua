--[[
RGX-Framework - Fonts Module

Simple font management for WoW addons.

For Addon Developers:
1. Add ## RequiredDeps: RGX-Framework to your .toc
2. Get fonts: local Fonts = RGX:GetModule("fonts")
3. Use fonts: local path = Fonts:GetPath("Inter-Regular")

API:
Fonts:GetPath(name) - Get font file path
Fonts:Get(name, size, flags) - Get path, size, flags
Fonts:GetFont(name) - Get Font object
Fonts:Apply(fontString, name, size, flags) - Apply to FontString
Fonts:List() - Get all fonts
Fonts:ListAvailable() - Get only available fonts
Fonts:Register(name, path, info) - Add custom font
Fonts:SetDefault(name) - Set default font
Fonts:GetDefault() - Get default font name

Quick Apply:
Fonts:Quick(textObject, "Inter-Bold", 14, "OUTLINE")
Fonts:Quick(textObject, "default") -- Uses default font
]]

local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

if not RGX then
	error("RGX Fonts: RGX-Framework not loaded")
	return
end

Fonts.name = "fonts"
Fonts.version = "1.0.0"
_G.RGXFonts = Fonts

Fonts.registry = {}
Fonts.objects = {}
Fonts.categories = {}
Fonts.pathLookup = {}
Fonts._findByPathCache = {}
Fonts._resolvePathCache = {}

Fonts.default = nil
Fonts.defaultSize = 12
Fonts.defaultFlags = ""
Fonts.autoScale = true
Fonts.previewSample = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus posuere, sapien ut gravida feugiat, augue turpis placerat velit, sed porta dui justo eget lorem."
Fonts._widgetId = 0
Fonts.flagPresets = {
	{ value = "", label = "Normal" },
	{ value = "OUTLINE", label = "Outline" },
	{ value = "THICKOUTLINE", label = "Thick Outline" },
	{ value = "MONOCHROME", label = "Monochrome" },
	{ value = "OUTLINE,MONOCHROME", label = "Outline Monochrome" },
	{ value = "THICKOUTLINE,MONOCHROME", label = "Thick Monochrome" },
}

Fonts._normalizedPathCache = {}

function Fonts:_NormalizeFontPath(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end

	local cached = self._normalizedPathCache[path]
	if cached then
		return cached
	end

	local normalized = string.lower((path:gsub("\\", "/")))
	self._normalizedPathCache[path] = normalized
	return normalized
end

Fonts._probeCounter = 0

function Fonts:_ProbeFontPath(path, probeName)
	if type(path) ~= "string" or path == "" then
		return false
	end

	self._probeCounter = self._probeCounter + 1
	local safeName = tostring(probeName or path):gsub("[^%w]", "_")
	local testFont = CreateFont("RGX_Test_" .. safeName .. "_" .. self._probeCounter)
	local ok, applied = pcall(function()
		return testFont:SetFont(path, 12, "")
	end)

	return ok and applied == true
end

function Fonts:_CopyFontRecord(name, data)
	local out = {}
	if type(data) == "table" then
		for k, v in pairs(data) do
			out[k] = v
		end
	end
	out.name = out.name or name
	out.key = out.key or out.name or name
	out.displayName = out.displayName or out.label or out.text or out.title or out.family or out.name or out.key
	out.text = out.text or out.displayName
	out.value = out.value or out.name or out.key
	out.category = out.category or out.group or out.familyCategory or "Sans-serif"
	if out.available == nil then
		out.available = true
	end
	return out
end

function Fonts:_SafeDropdownSetText(dropdown, text)
	if RGX and type(RGX.SafeUIDropDownMenu_SetText) == "function" then
		return RGX:SafeUIDropDownMenu_SetText(dropdown, text)
	end
	if type(UIDropDownMenu_SetText) == "function" then
		UIDropDownMenu_SetText(dropdown, text)
		return true
	end
	return false
end

function Fonts:_SafeDropdownEnable(dropdown)
	if RGX and type(RGX.SafeUIDropDownMenu_EnableDropDown) == "function" then
		return RGX:SafeUIDropDownMenu_EnableDropDown(dropdown)
	end
	if type(UIDropDownMenu_EnableDropDown) == "function" then
		UIDropDownMenu_EnableDropDown(dropdown)
		return true
	end
	return false
end

function Fonts:_SafeDropdownDisable(dropdown)
	if RGX and type(RGX.SafeUIDropDownMenu_DisableDropDown) == "function" then
		return RGX:SafeUIDropDownMenu_DisableDropDown(dropdown)
	end
	if type(UIDropDownMenu_DisableDropDown) == "function" then
		UIDropDownMenu_DisableDropDown(dropdown)
		return true
	end
	return false
end

function Fonts:_ChatDebug(message)
	if (RGX.debugMode or Fonts._forceDebug) and DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffbc6fa8[RGX:fonts]|r " .. tostring(message))
	end
end

function Fonts:Init()
	self:RegisterBuiltInFonts()

	if type(self.definitions) == "table" then
		for name, def in pairs(self.definitions) do
			self:Register(name, self.fontPath .. def.file, {
				displayName = def.family,
				family = def.family,
				category = def.category,
				license = def.license,
				available = self.unavailableFonts[name] and false or true,
			})
		end
	end

	if self:IsAvailable("Inter-Regular") then
		self:SetDefault("Inter-Regular")
	else
		self:SetDefault("FrizQuadrata")
	end

	RGX:RegisterModule("fonts", self)
	_G.RGXFonts = self
end
