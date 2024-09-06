local widget, version = "CheckBox", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local function update(self)
	if self:GetValue() then
		self.check:Show()
	else
		self.check:Hide()
	end
end

local function click(self)
	self = self:GetParent()
	self:SetValue(not self:GetValue())
	if self.check:IsShown() then
--		PlaySound("igMainMenuOptionCheckBoxOn")
	else
--		PlaySound("igMainMenuOptionCheckBoxOff")
	end
end

local function enable(self)
	self.bg:SetDesaturated(nil)
	self.check:SetDesaturated(nil)
	self.check:SetAlpha(1)
	self.title:SetTextColor(1, 1, 1)
	self.highlight:SetAlpha(1)
	self.button:SetScript("OnClick", click)
end

local function disable(self)
	self.bg:SetDesaturated(true)
	self.check:SetDesaturated(true)
	self.check:SetAlpha(0.75)
	self.title:SetTextColor(0.58, 0.58, 0.58)
	self.highlight:SetAlpha(0)
	self.button:SetScript("OnClick", nil)
end



LBO:RegisterWidget(widget, version, function(self)
	self.bg = self:CreateTexture(nil, "BACKGROUND")
	self.bg:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
	self.bg:SetPoint("LEFT", 0, 0)
	self.bg:SetWidth(24)
	self.bg:SetHeight(24)
	self.check = self:CreateTexture(nil, "OVERLAY")
	self.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	self.check:SetPoint("CENTER", self.bg, "CENTER", 0, 0)
	self.check:SetWidth(24)
	self.check:SetHeight(24)
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.title:SetPoint("LEFT", self.bg, "RIGHT", 0, 0)
	self.title:SetTextColor(1, 1, 1)
	self.title:SetJustifyH("LEFT")
	self.highlight = self:CreateTexture(nil, "ARTWORK")
	self.highlight:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	self.highlight:SetBlendMode("ADD")
	self.highlight:SetAllPoints(self.bg)
	self.highlight:Hide()
	self.button = CreateFrame("Button", nil, self)
	self.button:RegisterForClicks("LeftButtonUp")
	self.button:SetPoint("LEFT", self.bg, "LEFT", 0, 0)
	self.button:SetPoint("RIGHT", self.title, "RIGHT", 0, 0)
	self.button:SetHeight(24)
	self.button:SetScript("OnClick", click)
	self.Enable = enable
	self.Disable = disable
	self.Setup = update
end)