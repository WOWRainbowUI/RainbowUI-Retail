local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:CreateFontDropdown(parent, opts)
	opts = opts or {}
	parent = parent or UIParent

	local D = RGX:GetDropdowns()
	if not D then
		self:_ChatDebug("CreateFontDropdown: RGX:GetDropdowns() returned nil")
		RGX:Debug("Fonts:CreateFontDropdown: RGX:GetDropdowns() returned nil")
		return nil
	end

	local initialValue = self:ResolveName(opts.value, self:GetDefault()) or self:GetDefault()
	self:_ChatDebug(string.format("CreateFontDropdown: value=%s default=%s", tostring(opts.value), tostring(initialValue)))
	RGX:Debug(string.format("Fonts:CreateFontDropdown: value=%s default=%s registry=%d", tostring(opts.value), tostring(initialValue), self.registry and #self.registry or -1))

	local regCount = 0
	if self.registry then
		for _ in pairs(self.registry) do regCount = regCount + 1 end
	end
	RGX:Debug(string.format("Fonts:CreateFontDropdown: registryCount=%d", regCount))

	local function buildItems()
		local groupedItems = self:BuildGroupedFontItems({
			keepShownOnClick = true,
		})

		if #groupedItems == 0 then
			groupedItems[#groupedItems + 1] = { text = "No fonts available", notCheckable = true }
		end

		return groupedItems
	end

	local holder = D:CreateNestedDropdown(parent, {
		width = opts.width or 260,
		height = opts.height or 56,
		label = opts.label or "Font",
		buttonWidth = opts.buttonWidth or 180,
		value = initialValue,
		items = buildItems,
		getValueText = function(value)
			return Fonts:GetDropdownFontLabel(value)
		end,
		onChange = function(value, item, h)
			local resolved = Fonts:ResolveName(value, h.value) or h.value or Fonts:GetDefault()
			h.value = resolved
			h.path = Fonts:GetPath(resolved)
			if type(opts.onChange) == "function" then
				opts.onChange(resolved, h.path, nil, h)
			end
		end,
	})

	if not holder then
		RGX:Debug("Fonts:CreateFontDropdown: CreateNestedDropdown returned nil")
		return nil
	end

	holder.path = self:GetPath(holder.value or initialValue)

	local _origRefresh = holder.Refresh
	function holder:Refresh(value)
		_origRefresh(self, value)
		self.path = Fonts:GetPath(self.value)
	end

	holder:Refresh(holder.value)
	return holder
end

function Fonts:CreateSimpleFontSelector(parent, opts)
	return self:CreateFontDropdown(parent, opts)
end
