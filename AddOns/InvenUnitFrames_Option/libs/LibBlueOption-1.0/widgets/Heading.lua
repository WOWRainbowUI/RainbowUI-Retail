local widget, version = "Heading", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local function enable(self)
	self.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	self.left:SetDesaturated(nil)
	self.right:SetDesaturated(nil)
end

local function disable(self)
	self.title:SetTextColor(0.58, 0.58, 0.58)
	self.left:SetDesaturated(true)
	self.right:SetDesaturated(true)
end

LBO:RegisterWidget(widget, version, function(self, name)
	self:EnableMouse(nil)
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.title:SetPoint("CENTER", 0, 0)
	self.left = self:CreateTexture(nil, "BACKGROUND")
	self.left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	self.left:SetTexCoord(0.81, 0.94, 0.5, 1)
	self.left:SetPoint("RIGHT", self.title, "LEFT", -5, 0)
	self.left:SetPoint("LEFT", 3, 0)
	self.left:SetHeight(12)
	self.right = self:CreateTexture(nil, "BACKGROUND")
	self.right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	self.right:SetTexCoord(0.81, 0.94, 0.5, 1)
	self.right:SetPoint("LEFT", self.title, "RIGHT", 5, 0)
	self.right:SetPoint("RIGHT", -3, 0)
	self.right:SetHeight(12)
	self.over = CreateFrame("Frame", nil, self)
	self.over:EnableMouse(self.tooltipText and true or nil)
	self.over:SetHeight(14)
	self.over:SetPoint("LEFT", 3, 0)
	self.over:SetPoint("RIGHT", -3, 0)
	self.Enable = enable
	self.Disable = disable
end)