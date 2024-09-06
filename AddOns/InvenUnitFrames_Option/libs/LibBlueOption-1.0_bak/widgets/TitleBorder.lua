local widget, version = "TitleBorder", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local type = _G.type
local ipairs = _G.ipairs
local CreateFrame = _G.CreateFrame

local backdrop = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local function setBackdropBorderColor(self, ...)
	UIParent.SetBackdropBorderColor(self, ...)
	self._top1:SetVertexColor(self._top0:GetVertexColor())
	self._top2:SetVertexColor(self._top0:GetVertexColor())
end

LBO:RegisterWidget(widget, version, function(self, name)
	self:SetBackdrop(backdrop)
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.title:SetPoint("CENTER", self, "TOP", 0, -3)

	self._top0 = select(3, self:GetRegions())

	self._top1 = self:CreateTexture(nil, self._top0:GetDrawLayer())
	self._top1:SetTexture(self._top0:GetTexture())
	self._top1:SetTexCoord(0.2578125, 1, 0.3671875, 1, 0.2578125, 0.0625, 0.3671875, 0.0625)
	self._top1:SetHeight(16)
	self._top1:SetPoint(self._top0:GetPoint(1))
	self._top1:SetPoint("RIGHT", self.title, "LEFT", -4, 0)

	self._top2 = self:CreateTexture(nil, self._top0:GetDrawLayer())
	self._top2:SetTexture(self._top1:GetTexture())
	self._top2:SetTexCoord(self._top1:GetTexCoord())
	self._top2:SetHeight(16)
	self._top2:SetPoint(self._top0:GetPoint(2))
	self._top2:SetPoint("LEFT", self.title, "RIGHT", 4, 0)

	self._top0:SetTexture("")

	self.SetBackdropBorderColor = setBackdropBorderColor
	self:SetBackdropBorderColor(1, 1, 1)
end)