local widget, version = "EditBox", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local CreateFrame = _G.CreateFrame

local function update(self)
	self.box:ClearFocus()
	self.box:SetValue(self:GetValue())
end

local function enterPressed(self, value)
	self:GetParent():SetValue(value)
	update(self:GetParent())
end

local function setNumeric(self, state)
	self.box:SetNumeric(state)
end

local function enable(self)
	self.box:Enable()
	self.box:SetTextColor(1, 1, 1)
	self.title:SetTextColor(1, 1, 1)
end

local function disable(self)
	self.box:Disable()
	self.title:SetTextColor(0.58, 0.58, 0.58)
end

LBO:RegisterWidget(widget, version, function(self)
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.title:SetPoint("LEFT", 2, 0)
	self.title:SetTextColor(1, 1, 1)
	self.box = LBO:CreateEditBox(self, enterPressed, nil, nil, true)
	self.box:SetHeight(18)
	self.box:SetPoint("LEFT", self.title, "RIGHT", 2, -1)
	self.box:SetPoint("RIGHT", -2, -1)
	self.Enable = enable
	self.Disable = disable
	self.Setup = update
	self.SetNumeric = setNumeric
end)