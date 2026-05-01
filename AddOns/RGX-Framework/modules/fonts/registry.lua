local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:Register(name, path, info)
	if type(name) ~= "string" or name == "" then
		RGX:Debug("Fonts: Invalid font name")
		return nil
	end

	if self.registry[name] then
		return self.registry[name]
	end

	info = info or {}

	local displayName = info.displayName or info.name or info.label or name
	self.registry[name] = {
		name = name,
		key = name,
		displayName = displayName,
		text = displayName,
		value = name,
		family = info.family or info.displayName or info.name or name,
		category = info.category or info.group or "Sans-serif",
		path = path,
		available = info.available ~= false,
		isCustom = info.isCustom or false,
		license = info.license or "Unknown",
	}

	self.categories[info.category or "Sans-serif"] = true
	local normalizedPath = self:_NormalizeFontPath(path)
	if normalizedPath and not self.pathLookup[normalizedPath] then
		self.pathLookup[normalizedPath] = name
	end
	self._findByPathCache = {}
	self._resolvePathCache = {}
	self._availableListCache = nil
	self._groupedFontsCache = nil

	RGX:Debug("Fonts: Registered", name)
	return self.registry[name]
end

function Fonts:RegisterAddonFont(addonName, fontName, fontFile, info)
	info = info or {}
	info.isCustom = true
	info.addon = addonName

	local path = string.format("Interface/AddOns/%s/fonts/%s", addonName, fontFile)
	return self:Register(fontName, path, info)
end

function Fonts:RegisterFontPack(addonName, definitions)
	if type(addonName) ~= "string" or addonName == "" then
		RGX:Debug("Fonts: Invalid font pack addon name")
		return 0
	end

	if type(definitions) ~= "table" then
		RGX:Debug("Fonts: Invalid font pack definitions")
		return 0
	end

	local registered = 0

	for fontName, def in pairs(definitions) do
		if type(fontName) == "string" and type(def) == "table" and type(def.file) == "string" then
			self:RegisterAddonFont(addonName, fontName, def.file, {
				displayName = def.displayName or def.family or fontName,
				family = def.family or fontName,
				category = def.category or "Sans-serif",
				license = def.license or "Unknown",
				available = def.available,
			})
			registered = registered + 1
		end
	end

	RGX:Debug("Fonts: Registered font pack", addonName, registered)
	return registered
end

function Fonts:RegisterBuiltInFonts()
	self:Register("FrizQuadrata", "Fonts/FRIZQT__.TTF", {
		displayName = "Friz Quadrata",
		family = "Friz Quadrata",
		category = "WoW Defaults",
		license = "Blizzard Built-in",
		available = true,
	})
	self:Register("ArialNarrow", "Fonts/ARIALN.TTF", {
		displayName = "Arial Narrow",
		family = "Arial Narrow",
		category = "WoW Defaults",
		license = "Blizzard Built-in",
		available = true,
	})
	self:Register("Morpheus", "Fonts/MORPHEUS.TTF", {
		displayName = "Morpheus",
		family = "Morpheus",
		category = "WoW Defaults",
		license = "Blizzard Built-in",
		available = true,
	})
	self:Register("Skurri", "Fonts/SKURRI.TTF", {
		displayName = "Skurri",
		family = "Skurri",
		category = "WoW Defaults",
		license = "Blizzard Built-in",
		available = true,
	})
end
