local _, addon = ...
local Fonts = addon._fontsModule

function Fonts:Apply(fontString, name, size, flags)
	if not fontString or not fontString.SetFont then
		return false
	end

	local path, s, f = self:Get(name, size, flags)
	if type(path) ~= "string" or path == "" then
		path = "Fonts/FRIZQT__.TTF"
	end
	if not s or s <= 0 then
		s = self.defaultSize or 12
	end
	fontString:SetFont(path, s, f or "")
	return true
end

function Fonts:Quick(fontString, name, size, flags)
	if not fontString then return false end

	name = name or self.default

	if name == "default" or name == "normal" then
		name = self.default
	elseif name == "header" then
		size = size or 16
		flags = flags or "OUTLINE"
		name = self.default
	elseif name == "title" then
		size = size or 18
		flags = flags or "OUTLINE"
		name = self.default
	elseif name == "small" then
		size = size or 10
		name = self.default
	end

	return self:Apply(fontString, name, size, flags)
end

function Fonts:ApplyChildren(frame, name, size, flags)
	if not frame then return end

	local regions = {frame:GetRegions()}
	for _, region in ipairs(regions) do
		if region.SetFont then
			self:Apply(region, name, size, flags)
		end
	end

	for _, child in ipairs({frame:GetChildren()}) do
		self:ApplyChildren(child, name, size, flags)
	end
end

function Fonts:CreateString(parent, fontName, size, flags, layer)
	parent = parent or UIParent
	layer = layer or "OVERLAY"

	local fs = parent:CreateFontString(nil, layer)
	self:Quick(fs, fontName, size, flags)

	return fs
end

function Fonts:FromTemplate(parent, template, text, layer)
	local settings = {
		header = { size = 16, flags = "OUTLINE" },
		title = { size = 18, flags = "OUTLINE" },
		body = { size = 12, flags = "" },
		caption = { size = 10, flags = "" },
		small = { size = 9, flags = "" },
	}

	local setting = settings[template] or settings.body
	local fs = self:CreateString(parent, self.default, setting.size, setting.flags, layer)
	if text then fs:SetText(text) end

	return fs
end
