local widget, version = "Slider", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local min = _G.math.min
local max  = _G.math.max
local floor = _G.math.floor
local strmatch = _G.string.match
local CreateFrame = _G.CreateFrame

local tmp

local sliderBackdrop  = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	tile = true, tileSize = 8, edgeSize = 8,
	insets = { left = 3, right = 3, top = 6, bottom = 6 }
}

local function sliderOnValueChanged(self, value)
	self = self:GetParent()
	value = floor(value + 0.5)
	self.box:ClearFocus()
--	self.box:SetValue(self.pattern:format(self.value, self.unit))
	self.box:SetValue(self.value)
	if self.value ~= value then
		self.value = value
		self:SetValue(self.value)
	end
end

local function editBoxOnEnterPressed(self, value)
	self = self:GetParent()
	value = min(max(self.min, value), self.max)
	self.slider:SetValue(value)
	self.box:ClearFocus()
--	self.box:SetValue(self.pattern:format(value, self.unit))
	self.box:SetValue(value)
end

local function update(self)
	self.value, self.min, self.max, self.step, self.unit = self:GetValue()
	self.step = self.step or 1
	if floor(self.step) == self.step then
		self.floor = 0
		self.pattern = "%d%s"
	else
		self.floor = strmatch(self.step, "%.(.+)"):len()
		self.pattern = "%."..self.floor.."f%s"
	end
	self.min = self.min or 0
	self.max = self.max or 100
	self.value = min(max(self.min, self.value), self.max)
	self.unit = (self.unit or ""):trim()
	self.slider:SetScript("OnValueChanged", nil)
	self.slider:SetMinMaxValues(self.min, self.max)
	self.slider:SetValue(self.value)
	self.slider:SetValueStep(self.step)
	self.minText:SetText(self.min)
	self.maxText:SetText(self.max)
--	self.box:SetValue(self.pattern:format(self.value, self.unit))
	self.box:SetValue(self.value)
	self.slider:SetScript("OnValueChanged", sliderOnValueChanged)
end

local function enable(self)
	self.title:SetTextColor(1, 1, 1)
	self.minText:SetTextColor(1, 1, 1)
	self.maxText:SetTextColor(1, 1, 1)
	self.slider.thumb:Show()
	self.slider:Enable()
	self.box:Enable()
end

local function disable(self)
	self.title:SetTextColor(0.58, 0.58, 0.58)
	self.minText:SetTextColor(0.58, 0.58, 0.58)
	self.maxText:SetTextColor(0.58, 0.58, 0.58)
	self.slider.thumb:Hide()
	self.slider:Disable()
	self.box:Disable()
end

LBO:RegisterWidget(widget, version, function(self, name)
	self.slider = CreateFrame("Slider", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	self.slider:SetBackdrop(sliderBackdrop)
	self.slider:SetPoint("LEFT", 4, 0)
	self.slider:SetPoint("RIGHT", -4, 0)
	self.slider:SetHeight(15)
	self.slider:SetOrientation("HORIZONTAL")
	self.slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	self.slider.thumb = self.slider:GetThumbTexture()
	self.slider:SetScript("OnValueChanged", sliderOnValueChanged)
	self.minText = self.slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.minText:SetPoint("TOPLEFT", self.slider, "BOTTOMLEFT", 2, 3)
	self.maxText = self.slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	self.maxText:SetPoint("TOPRIGHT", self.slider, "BOTTOMRIGHT", -2, 3)
	self.box = LBO:CreateEditBox(self, editBoxOnEnterPressed, "GameFontHighlightSmall", nil, true)
	self.box:SetPoint("BOTTOM", self ,"BOTTOM", 0, 1)
	self.box:SetHeight(14)
	self.box:SetWidth(70)
	self.box:SetNumeric(true)
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.title:SetPoint("TOP", self, "TOP", 0, -2)
	self.title:SetTextColor(1, 1, 1)
	self.Setup = update
	self.Enable = enable
	self.Disable = disable
end)