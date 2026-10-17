--- MSA-AceGUIWidget-Label - label widget with some modifications
--- Based on default widget AceGUIWidget-Label
---
--- Marouan Sabbagh <mar.sabbagh@gmail.com>

--[[-----------------------------------------------------------------------------
Label Widget
Displays text and optionally an icon.
-------------------------------------------------------------------------------]]
local Type, Version = "MSA-Label", 29
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local max, select, pairs, unpack = math.max, select, pairs, unpack  -- MSA

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function UpdateImageAnchor(self)
	if self.resizing then return end
	local frame = self.frame
	local width = frame.width or frame:GetWidth() or 0
	local marginLeft = self.marginLeft or 0  -- MSA
	local contentWidth = max(width - marginLeft, 0)  -- MSA
	local image = self.image
	local label = self.label
	local height

	label:ClearAllPoints()
	image:ClearAllPoints()

	if self.imageshown then
		local imagewidth = image:GetWidth()
		if (contentWidth - imagewidth) < 200 or (label:GetText() or "") == "" then  -- MSA
			-- image goes on top centered when less than 200 width for the text, or if there is no text
			image:SetPoint("TOP", frame, "TOPLEFT", marginLeft + contentWidth / 2, 0)  -- MSA
			label:SetPoint("TOP", image, "BOTTOM")
			label:SetPoint("LEFT", frame, "LEFT", marginLeft, 0)  -- MSA
			label:SetWidth(contentWidth)  -- MSA
			height = image:GetHeight() + label:GetStringHeight()
		else
			-- image on the left
			image:SetPoint("TOPLEFT", frame, "TOPLEFT", marginLeft, 0)  -- MSA
			if image:GetHeight() > label:GetStringHeight() then
				label:SetPoint("LEFT", image, "RIGHT", 4, 0)
			else
				label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)
			end
			label:SetWidth(contentWidth - imagewidth - 4)  -- MSA
			height = max(image:GetHeight(), label:GetStringHeight())
		end
	else
		-- no image shown
		label:SetPoint("TOPLEFT", frame, "TOPLEFT", marginLeft, 0)  -- MSA
		label:SetWidth(contentWidth)  -- MSA
		height = label:GetStringHeight()
	end

	-- avoid zero-height labels, since they can used as spacers
	if not height or height == 0 then
		height = 1
	end

	self.resizing = true
	frame:SetHeight(height)
	frame.height = height
	self.resizing = nil
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- set the flag to stop constant size updates
		self.resizing = true
		-- height is set dynamically by the text and image size
		self:SetWidth(200)
		self:SetMarginLeft(0)  -- MSA
		self:SetText()
		self:SetImage(nil)
		self:SetImageSize(16, 16)
		self:SetColor()
		self:SetFontObject()
		self:SetJustifyH("LEFT")
		self:SetJustifyV("TOP")
		self:SetDisabled(false)  -- MSA

		-- reset the flag
		self.resizing = nil
		-- run the update explicitly
		UpdateImageAnchor(self)
	end,

	-- ["OnRelease"] = nil,

	["OnWidthSet"] = function(self, width)
		UpdateImageAnchor(self)
	end,

	-- MSA
	["SetMarginLeft"] = function(self, margin)
		self.marginLeft = max(margin, 0)
		UpdateImageAnchor(self)
	end,

	["SetText"] = function(self, text)
		self.label:SetText(text)
		UpdateImageAnchor(self)
	end,

	["SetColor"] = function(self, r, g, b)
		if not (r and g and b) then
			r, g, b = 1, 1, 1
		end
		self.label:SetVertexColor(r, g, b)
		self.color = { r, g, b }  -- MSA
	end,

	["SetImage"] = function(self, path, ...)
		local image = self.image
		image:SetTexture(path)

		if image:GetTexture() then
			self.imageshown = true
			local n = select("#", ...)
			if n == 4 or n == 8 then
				image:SetTexCoord(...)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
		else
			self.imageshown = nil
		end
		UpdateImageAnchor(self)
	end,

	["SetImageByAtlas"] = function(self, atlasString)
		self.imageshown = true
		local image = self.image
		image:SetAtlas(atlasString)
		UpdateImageAnchor(self)
	end,

	["SetFont"] = function(self, font, height, flags)
		if not self.fontObject then
			self.fontObject = CreateFont("AceGUI30LabelFont" .. AceGUI:GetNextWidgetNum(Type))
		end
		self.fontObject:SetFont(font, height, flags)
		self:SetFontObject(self.fontObject)
	end,

	["SetFontObject"] = function(self, font)
		self.label:SetFontObject(font or GameFontHighlightSmall)
		UpdateImageAnchor(self)
	end,

	["SetImageSize"] = function(self, width, height)
		self.image:SetWidth(width)
		self.image:SetHeight(height)
		UpdateImageAnchor(self)
	end,

	["SetJustifyH"] = function(self, justifyH)
		self.label:SetJustifyH(justifyH)
	end,

	["SetJustifyV"] = function(self, justifyV)
		self.label:SetJustifyV(justifyV)
	end,

	-- MSA
	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.label:SetTextColor(.5, .5, .5)
		else
			self.label:SetTextColor(unpack(self.color))
		end
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	local image = frame:CreateTexture(nil, "BACKGROUND")

	-- create widget
	local widget = {
		label = label,
		image = image,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
