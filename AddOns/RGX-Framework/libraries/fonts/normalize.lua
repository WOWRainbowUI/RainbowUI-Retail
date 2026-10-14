local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:SplitFlags(flags)
	if type(flags) ~= "string" or flags == "" then
		return {}
	end

	local map = {}
	for token in string.gmatch(flags, "([^,]+)") do
		local normalized = strtrim(token):upper()
		if normalized ~= "" then
			map[normalized] = true
		end
	end
	return map
end

function Fonts:NormalizeFlags(flags)
	if type(flags) == "table" then
		local tokens = {}
		local hasThick = flags.thickOutline or flags.thickoutline or flags.THICKOUTLINE
		local hasOutline = flags.outline or flags.OUTLINE
		local hasMono = flags.monochrome or flags.MONOCHROME

		if hasThick then
			table.insert(tokens, "THICKOUTLINE")
		elseif hasOutline then
			table.insert(tokens, "OUTLINE")
		end

		if hasMono then
			table.insert(tokens, "MONOCHROME")
		end

		return table.concat(tokens, ",")
	end

	local map = self:SplitFlags(flags)
	local tokens = {}

	if map.THICKOUTLINE then
		table.insert(tokens, "THICKOUTLINE")
	elseif map.OUTLINE then
		table.insert(tokens, "OUTLINE")
	end

	if map.MONOCHROME then
		table.insert(tokens, "MONOCHROME")
	end

	return table.concat(tokens, ",")
end

function Fonts:DescribeFlags(flags)
	local normalized = self:NormalizeFlags(flags)
	for _, preset in ipairs(self.flagPresets) do
		if preset.value == normalized then
			return preset.label
		end
	end
	return normalized ~= "" and normalized or "Normal"
end

function Fonts:GetFlagPresets()
	local list = {}
	for _, preset in ipairs(self.flagPresets) do
		table.insert(list, RGX:CopyTable(preset))
	end
	return list
end

function Fonts:NormalizeColorValue(color, fallback)
	local Colors = _G.RGXColors
	local source = color

	if source == nil or source == "" then
		source = fallback
	end

	if source == nil or source == "" then
		return nil
	end

	if Colors and type(Colors.Get) == "function" then
		local normalized = Colors:Get(source)
		if normalized then
			return {
				r = normalized.r,
				g = normalized.g,
				b = normalized.b,
				a = normalized.a,
				hex = normalized.hex,
			}
		end
	end

	if type(source) == "table" then
		local r = tonumber(source.r or source[1])
		local g = tonumber(source.g or source[2])
		local b = tonumber(source.b or source[3])
		local a = source.a ~= nil and RGX:Clamp(tonumber(source.a) or 1, 0, 1) or nil

		if r and g and b then
			return {
				r = RGX:Clamp(r, 0, 1),
				g = RGX:Clamp(g, 0, 1),
				b = RGX:Clamp(b, 0, 1),
				a = a,
			}
		end
	end

	return nil
end

function Fonts:NormalizeShadowOffset(offset, fallbackX, fallbackY)
	local x
	local y

	if type(offset) == "table" then
		x = offset.x or offset[1]
		y = offset.y or offset[2]
	elseif type(offset) == "number" then
		x = offset
		y = -offset
	end

	x = tonumber(x)
	y = tonumber(y)

	if x == nil then
		x = fallbackX or 0
	end
	if y == nil then
		y = fallbackY or 0
	end

	return math.floor(x + 0.5), math.floor(y + 0.5)
end

function Fonts:NormalizeJustify(value, fallback, isVertical)
	if type(value) ~= "string" or value == "" then
		return fallback
	end

	value = value:upper()
	if isVertical then
		if value == "TOP" or value == "MIDDLE" or value == "BOTTOM" then
			return value
		end
	else
		if value == "LEFT" or value == "CENTER" or value == "RIGHT" then
			return value
		end
	end

	return fallback
end
