local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

local function ResolveMenuValue(value)
	if type(value) == "function" then
		return value()
	end
	return value
end

function Fonts:CreateFontMenuItems(opts)
	opts = opts or {}
	return self:BuildGroupedFontItems({
		current = opts.current,
		keepShownOnClick = opts.keepShownOnClick,
		onSelect = opts.onSelect,
	})
end

function Fonts:CreateFlagMenuItems(opts)
	opts = opts or {}

	local current = self:NormalizeFlags(ResolveMenuValue(opts.current))
	local items = {}

	for _, preset in ipairs(self:GetFlagPresets()) do
		local flagValue = preset.value
		local presetInfo = preset
		items[#items + 1] = {
			text = preset.label,
			value = flagValue,
			checked = current == flagValue,
			isNotRadio = true,
			keepShownOnClick = opts.keepShownOnClick ~= false,
			func = function()
				if type(opts.onSelect) == "function" then
					opts.onSelect(flagValue, presetInfo)
				end
			end,
			onClick = function()
				if type(opts.onSelect) == "function" then
					opts.onSelect(flagValue, presetInfo)
				end
			end,
		}
	end

	return items
end

function Fonts:CreateSizeMenuItems(opts)
	opts = opts or {}

	local current = tonumber(ResolveMenuValue(opts.current)) or self.defaultSize
	local minSize = tonumber(opts.minSize) or 8
	local maxSize = tonumber(opts.maxSize) or 24
	local step = tonumber(opts.step) or 1
	local items = {}

	for size = minSize, maxSize, step do
		local menuSize = math.floor(size + 0.5)
		local selectedSize = menuSize
		items[#items + 1] = {
			text = string.format("%d pt", selectedSize),
			value = selectedSize,
			checked = math.floor(current + 0.5) == selectedSize,
			isNotRadio = true,
			keepShownOnClick = opts.keepShownOnClick ~= false,
			func = function()
				if type(opts.onSelect) == "function" then
					opts.onSelect(selectedSize)
				end
			end,
			onClick = function()
				if type(opts.onSelect) == "function" then
					opts.onSelect(selectedSize)
				end
			end,
		}
	end

	return items
end

function Fonts:CreateStyleMenuItems(opts)
	opts = opts or {}

	local function getStyle()
		local source
		if type(opts.getStyle) == "function" then
			source = opts.getStyle()
		elseif type(opts.db) == "table" and type(opts.key) == "string" then
			source = opts.db[opts.key]
		else
			source = opts.value
		end

		return Fonts:NormalizeStyle(source or opts.default or {
			font = Fonts:GetDefault(),
			size = Fonts.defaultSize,
			flags = Fonts.defaultFlags,
		})
	end

	local function saveStyle(style)
		local normalized = Fonts:NormalizeStyle(style)
		if type(opts.db) == "table" and type(opts.key) == "string" then
			opts.db[opts.key] = normalized
		end
		if type(opts.onChange) == "function" then
			opts.onChange(normalized, opts)
		end
	end

	local style = getStyle()
	local fontChildren = self:BuildGroupedFontItems({
		current = style.font,
		keepShownOnClick = opts.keepShownOnClick,
		onSelect = function(fontName)
			local nextStyle = getStyle()
			nextStyle.font = fontName
			saveStyle(nextStyle)
		end,
	})
	local flagChildren = self:CreateFlagMenuItems({
		current = style.flags,
		keepShownOnClick = opts.keepShownOnClick,
		onSelect = function(flags)
			local nextStyle = getStyle()
			nextStyle.flags = flags or ""
			saveStyle(nextStyle)
		end,
	})
	local sizeChildren = self:CreateSizeMenuItems({
		current = style.size,
		minSize = opts.minSize,
		maxSize = opts.maxSize,
		step = opts.sizeStep,
		keepShownOnClick = opts.keepShownOnClick,
		onSelect = function(size)
			local nextStyle = getStyle()
			nextStyle.size = size
			saveStyle(nextStyle)
		end,
	})

	local items = {
		{
			text = "Font: " .. self:GetDropdownFontLabel(style.font),
			hasArrow = true,
			notCheckable = true,
			children = fontChildren,
			menuList = fontChildren,
		},
		{
			text = "Style: " .. self:DescribeFlags(style.flags),
			hasArrow = true,
			notCheckable = true,
			children = flagChildren,
			menuList = flagChildren,
		},
		{
			text = string.format("Size: %d pt", style.size or self.defaultSize),
			hasArrow = true,
			notCheckable = true,
			children = sizeChildren,
			menuList = sizeChildren,
		},
	}

	if opts.default then
		items[#items + 1] = {
			text = "Reset",
			notCheckable = true,
			keepShownOnClick = opts.keepShownOnClick ~= false,
			func = function()
				saveStyle(opts.default)
			end,
		}
	end

	return items
end
