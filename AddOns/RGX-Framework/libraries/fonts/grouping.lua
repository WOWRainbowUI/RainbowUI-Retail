local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:GetCategoryLabel(category)
	local labels = {
		["Sans-serif"] = "Sans / UI",
		["Serif"] = "Serif",
		["Monospace"] = "Monospace",
		["Display"] = "Display",
		["Pixel"] = "Pixel",
		["Fantasy"] = "Fantasy / Themed",
		["WoW Defaults"] = "WoW Defaults",
	}

	return labels[category] or category or "Other"
end

function Fonts:GetGroupedFonts()
	if self._groupedFontsCache then
		return self._groupedFontsCache
	end

	local groups = {}
	local availableFonts = self:ListAvailable()

	for _, fontInfo in ipairs(availableFonts) do
		if type(fontInfo) ~= "table" or type(fontInfo.name) ~= "string" or fontInfo.name == "" then
			if RGX.debugMode then
				RGX:Debug("[RGX:fonts] Malformed font record:", fontInfo)
			end
		else
			local category = fontInfo.category or "Sans-serif"
			local family = fontInfo.family or fontInfo.displayName or fontInfo.name
			if type(family) ~= "string" or family == "" then
				family = "Unknown"
			end

			if not groups[category] then
				groups[category] = {
					category = category,
					label = self:GetCategoryLabel(category),
					count = 0,
					families = {},
				}
			end

			local categoryGroup = groups[category]
			if not categoryGroup.families[family] then
				categoryGroup.families[family] = {
					family = family,
					styles = {},
				}
			end

			table.insert(categoryGroup.families[family].styles, fontInfo)
			categoryGroup.count = categoryGroup.count + 1
		end
	end

	local categoryOrder = { "Sans-serif", "Serif", "Monospace", "Display", "Pixel", "Fantasy", "WoW Defaults" }
	local orderedGroups = {}
	local seen = {}

	for _, category in ipairs(categoryOrder) do
		if groups[category] then
			table.insert(orderedGroups, groups[category])
			seen[category] = true
		end
	end

	for category, group in pairs(groups) do
		if not seen[category] then
			table.insert(orderedGroups, group)
		end
	end

	table.sort(orderedGroups, function(a, b)
		if a.label == b.label then
			return a.category < b.category
		end
		return a.label < b.label
	end)

	for _, group in ipairs(orderedGroups) do
		local families = {}
		for _, familyData in pairs(group.families) do
			table.sort(familyData.styles, function(a, b)
				return (a.displayName or a.text or a.name or "") < (b.displayName or b.text or b.name or "")
			end)
			table.insert(families, familyData)
		end

		table.sort(families, function(a, b)
			return a.family < b.family
		end)

		group.families = families
	end

	self._groupedFontsCache = orderedGroups
	return orderedGroups
end

function Fonts:GetDebugCounts()
	local total = 0
	local available = 0

	for name in pairs(self.registry or {}) do
		total = total + 1
		if self:IsAvailable(name) then
			available = available + 1
		end
	end

	return total, available, self:GetDefault() or "nil"
end

function Fonts:DebugStatus(reason)
	local total, available, defaultName = self:GetDebugCounts()
	self:_ChatDebug(string.format(
		"%s total=%d available=%d default=%s",
		tostring(reason or "status"),
		total,
		available,
		tostring(defaultName)
	))
end

function Fonts:GetDropdownFontLabel(fontName)
	local info = self.registry[fontName]
	if not info then
		return fontName or self:GetDefault()
	end

	local family = info.family or fontName
	if family == fontName then
		return family
	end

	return string.format("%s - %s", family, fontName)
end

function Fonts:BuildGroupedFontItems(opts)
	opts = opts or {}
	local available = self:ListAvailable() or {}
	local current = self:ResolveName(type(opts.current) == "function" and opts.current() or opts.current, self:GetDefault()) or self:GetDefault()
	local groups = self:GetGroupedFonts()
	local items = {}

	for _, group in ipairs(groups) do
		local children = {}
		for _, familyData in ipairs(group.families) do
			for _, fontInfo in ipairs(familyData.styles) do
				local text = fontInfo.family or fontInfo.displayName or fontInfo.name
				if fontInfo.name and fontInfo.name ~= text then
					text = string.format("%s - %s", text, fontInfo.name)
				end
				children[#children + 1] = {
					text = text,
					value = fontInfo.name,
					path = fontInfo.path,
					checked = current == fontInfo.name,
					isNotRadio = true,
					keepShownOnClick = opts.keepShownOnClick ~= false,
					func = function()
						if type(opts.onSelect) == "function" then
							opts.onSelect(fontInfo.name, fontInfo.path, fontInfo)
						end
					end,
					onClick = function()
						if type(opts.onSelect) == "function" then
							opts.onSelect(fontInfo.name, fontInfo.path, fontInfo)
						end
					end,
				}
			end
		end

		if #children > 0 then
			items[#items + 1] = {
				text = group.label,
				children = children,
				menuList = children,
				notCheckable = true,
				hasArrow = true,
			}
		end
	end

	if #items == 0 then
		items[#items + 1] = {
			text = "No fonts available",
			disabled = true,
			notCheckable = true,
		}
	end

	return items
end
