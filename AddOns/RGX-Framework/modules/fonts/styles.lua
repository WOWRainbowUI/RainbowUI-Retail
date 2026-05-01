local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:NormalizeStyle(style)
	style = style or {}
	if type(style) == "string" then
		style = { font = style }
	end

	local font = self:ResolveName(style.font or style.name, self:GetDefault()) or self:GetDefault()

	local size = tonumber(style.size) or self.defaultSize or 12
	size = math.floor(RGX:Clamp(size, 6, 72) + 0.5)

	local flags = self:NormalizeFlags(style.flags or style.outline or self.defaultFlags or "")

	local color = nil
	if style.color ~= nil or style.textColor ~= nil then
		color = self:NormalizeColorValue(style.color or style.textColor)
	end

	local shadowColor = nil
	if style.shadowColor ~= nil or style.shadow ~= nil then
		shadowColor = self:NormalizeColorValue(style.shadowColor or style.shadow)
	end

	local shadowOffset = nil
	if style.shadowOffset ~= nil or style.shadowXY ~= nil then
		local shadowX, shadowY = self:NormalizeShadowOffset(style.shadowOffset or style.shadowXY, 1, -1)
		shadowOffset = { x = shadowX, y = shadowY }
	end

	local alpha = style.alpha
	if alpha ~= nil then
		alpha = RGX:Clamp(tonumber(alpha) or 1, 0, 1)
	end

	local justifyH = nil
	if style.justifyH ~= nil or style.align ~= nil or style.justify ~= nil then
		justifyH = self:NormalizeJustify(style.justifyH or style.align or style.justify, "LEFT", false)
	end

	local justifyV = nil
	if style.justifyV ~= nil or style.valign ~= nil then
		justifyV = self:NormalizeJustify(style.justifyV or style.valign, "TOP", true)
	end

	local spacing = nil
	if style.spacing ~= nil then
		spacing = tonumber(style.spacing)
		if spacing ~= nil then
			spacing = RGX:Clamp(spacing, 0, 64)
		end
	end

	return {
		font = font,
		size = size,
		flags = flags,
		color = color,
		shadowColor = shadowColor,
		shadowOffset = shadowOffset,
		alpha = alpha,
		justifyH = justifyH,
		justifyV = justifyV,
		spacing = spacing,
	}
end

function Fonts:CreateStyle(style)
	return self:NormalizeStyle(style)
end

function Fonts:GetStyle(font, size, flags)
	if type(font) == "table" then
		return self:NormalizeStyle(font)
	end

	return self:NormalizeStyle({
		font = font,
		size = size,
		flags = flags,
	})
end

function Fonts:ApplyStyle(fontString, style)
	local normalized = self:NormalizeStyle(style)
	local applied = self:Apply(fontString, normalized.font, normalized.size, normalized.flags)
	if not applied or not fontString then
		return false
	end

	if normalized.color and fontString.SetTextColor then
		local alpha = normalized.alpha
		if alpha == nil then
			alpha = normalized.color.a
		end
		fontString:SetTextColor(
			normalized.color.r,
			normalized.color.g,
			normalized.color.b,
			alpha or 1
		)
	end

	if normalized.shadowColor and fontString.SetShadowColor then
		fontString:SetShadowColor(
			normalized.shadowColor.r,
			normalized.shadowColor.g,
			normalized.shadowColor.b,
			normalized.shadowColor.a or 1
		)
	end

	if normalized.shadowOffset and fontString.SetShadowOffset then
		fontString:SetShadowOffset(normalized.shadowOffset.x or 0, normalized.shadowOffset.y or 0)
	end

	if normalized.justifyH and fontString.SetJustifyH then
		fontString:SetJustifyH(normalized.justifyH)
	end

	if normalized.justifyV and fontString.SetJustifyV then
		fontString:SetJustifyV(normalized.justifyV)
	end

	if normalized.spacing ~= nil and fontString.SetSpacing then
		fontString:SetSpacing(normalized.spacing)
	end

	if normalized.alpha ~= nil and fontString.SetAlpha then
		fontString:SetAlpha(normalized.alpha)
	end

	return true
end

function Fonts:ApplyTextStyle(fontString, style)
	return self:ApplyStyle(fontString, style)
end

function Fonts:ApplyStyleMap(targets, styleTable)
	if type(targets) ~= "table" or type(styleTable) ~= "table" then
		return false
	end

	local applied = false

	for key, fontString in pairs(targets) do
		if fontString and fontString.SetFont and type(styleTable[key]) == "table" then
			self:ApplyStyle(fontString, styleTable[key])
			applied = true
		end
	end

	return applied
end
