local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:Exists(name)
	return self.registry[name] ~= nil
end

function Fonts:GetInfo(name)
	return self.registry[name]
end

function Fonts:IsAvailable(name)
	local font = self.registry[name]
	if not font then return false end
	if font.available == nil then
		font.available = true
	end
	return font.available
end

function Fonts:GetPath(name)
	name = self:ResolveName(name, self.default) or self.default or "FrizQuadrata"

	local font = self.registry[name]
	if font and self:IsAvailable(name) then
		return font.path
	end

	local defaultName = self.default
	if defaultName and defaultName ~= name then
		local defaultFont = self.registry[defaultName]
		if defaultFont and self:IsAvailable(defaultName) then
			return defaultFont.path
		end
	end

	local friz = self.registry.FrizQuadrata
	if friz and self:IsAvailable("FrizQuadrata") then
		return friz.path
	end

	return "Fonts/FRIZQT__.TTF"
end

function Fonts:Get(name, size, flags)
	local path = self:GetPath(name)
	local s = size or self.defaultSize
	local f = flags or self.defaultFlags

	if self.autoScale then
		s = s * UIParent:GetEffectiveScale()
	end

	return path, s, f
end

function Fonts:GetFont(name, size, flags)
	name = self:ResolveName(name, self.default) or self.default

	if not self:Exists(name) then
		return nil
	end

	if not size and not flags then
		if not self.objects[name] then
			local path = self:GetPath(name)
			local obj = CreateFont("RGX_Font_" .. name:gsub("[^%w]", "_"))
			obj:SetFont(path, self.defaultSize, self.defaultFlags)
			self.objects[name] = obj
		end
		return self.objects[name]
	end

	local path = self:GetPath(name)
	local tempName = string.format("RGX_Font_%s_%d_%s",
		name:gsub("[^%w]", "_"), size or 0, flags or "")

	local temp = _G[tempName]
	if not temp then
		temp = CreateFont(tempName)
		temp:SetFont(path, size or self.defaultSize, flags or self.defaultFlags)
	end

	return temp
end

function Fonts:List()
	local list = {}
	for name, data in pairs(self.registry) do
		table.insert(list, {
			name = name,
			displayName = data.name,
			family = data.family,
			category = data.category,
			path = data.path,
			available = data.available,
			isCustom = data.isCustom,
		})
	end
	table.sort(list, function(a, b) return a.name < b.name end)
	return list
end

function Fonts:ListAvailable()
if self._availableListCache then
self:_ChatDebug(string.format("ListAvailable: cache hit, %d items", #self._availableListCache))
return self._availableListCache
end

local list = {}
local registry = self.registry or {}
local regCount = 0
for _ in pairs(registry) do regCount = regCount + 1 end
self:_ChatDebug(string.format("ListAvailable: registry has %d entries", regCount))

for name, data in pairs(registry) do
local record = self:_CopyFontRecord(name, data)
local blocked = (self.unavailableFonts and (self.unavailableFonts[name] or self.unavailableFonts[record.name])) or false
if record.available ~= false and not blocked then
table.insert(list, record)
end
end

table.sort(list, function(a, b)
return tostring(a.displayName or a.name or a.key) < tostring(b.displayName or b.name or b.key)
end)

self:_ChatDebug(string.format("ListAvailable: %d available of %d registered", #list, regCount))
	self._availableListCache = list
	return list
end

function Fonts:ListByCategory(category)
	local list = {}
	for name, data in pairs(self.registry) do
		if data.category == category and self:IsAvailable(name) then
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

function Fonts:GetCategories()
	local cats = {}
	for cat in pairs(self.categories) do
		table.insert(cats, cat)
	end
	table.sort(cats)
	return cats
end

function Fonts:GetFamilies()
	local map = {}
	for name, data in pairs(self.registry) do
		if self:IsAvailable(name) then
			map[data.family or data.name] = true
		end
	end

	local list = {}
	for family in pairs(map) do
		table.insert(list, family)
	end
	table.sort(list)
	return list
end

function Fonts:FindByPath(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end

	self._findByPathCache = self._findByPathCache or {}
	local cachedName = self._findByPathCache[path]
	if cachedName ~= nil then
		if cachedName == false then
			return nil
		end
		return cachedName, self.registry and self.registry[cachedName]
	end

	local normalizedPath = self:_NormalizeFontPath(path)
	local fontName = normalizedPath and self.pathLookup and self.pathLookup[normalizedPath]
	if fontName then
		self._findByPathCache[path] = fontName
		return fontName, self.registry[fontName]
	end

	self._findByPathCache[path] = false
	return nil
end

function Fonts:ResolveName(value, fallback)
	if type(value) == "string" and value ~= "" then
		if self:Exists(value) and self:IsAvailable(value) then
			return value
		end

		local found = self:FindByPath(value)
		if found and self:IsAvailable(found) then
			return found
		end
	end

	if type(fallback) == "string" and fallback ~= "" then
		if self:Exists(fallback) and self:IsAvailable(fallback) then
			return fallback
		end

		local fallbackName = self:FindByPath(fallback)
		if fallbackName and self:IsAvailable(fallbackName) then
			return fallbackName
		end
	end

	local defaultName = self:GetDefault()
	if type(defaultName) == "string" and defaultName ~= "" and self:Exists(defaultName) and self:IsAvailable(defaultName) then
		return defaultName
	end

	if self:Exists("FrizQuadrata") and self:IsAvailable("FrizQuadrata") then
		return "FrizQuadrata"
	end

	return nil
end

function Fonts:ResolvePath(value, fallback)
	self._resolvePathCache = self._resolvePathCache or {}
	local cacheKey = tostring(value or "") .. "\031" .. tostring(fallback or "")
	local cached = self._resolvePathCache[cacheKey]
	if cached then
		return cached.path, cached.name
	end

	local fontName = self:ResolveName(value, fallback)
	if fontName then
		local path = self:GetPath(fontName) or "Fonts/FRIZQT__.TTF"
		self._resolvePathCache[cacheKey] = { path = path, name = fontName }
		return path, fontName
	end

	self._resolvePathCache[cacheKey] = { path = "Fonts/FRIZQT__.TTF" }
	return "Fonts/FRIZQT__.TTF", nil
end
