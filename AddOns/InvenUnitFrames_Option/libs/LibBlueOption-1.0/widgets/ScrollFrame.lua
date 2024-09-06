local widget, version = "ScrollFrame", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local pairs = _G.pairs
local CreateFrame = _G.CreateFrame
local texture

local function onScroll(self)
	GameTooltip:Hide()
	for menu in pairs(LBO.widgetMenus) do
		menu.parent = nil
		menu:Hide()
	end
end

local function updateSize(self)
	if not(self:IsVisible() and self.scrollframe:GetWidth() and self.scrollframe:GetWidth() > 0) then return end
	self:SetScript("OnUpdate", nil)
	if self.scrollbar:IsVisible() then
		self.content:SetWidth(self.scrollframe:GetWidth() - 23)
	else
		self.content:SetWidth(self.scrollframe:GetWidth())
	end
end

local function onShow(self)
	ScrollFrame_OnScrollRangeChanged(self.scrollframe)
	self:SetScript("OnUpdate", updateSize)
end

local function onHide(self)
	self:SetScript("OnUpdate", nil)
end

local function scrollbarShow(self)
	self = self:GetParent():GetParent()
	self.Show(self.scrollbar)
	updateSize(self)

end

local function scrollbarHide(self)
	self = self:GetParent():GetParent()
	self.Hide(self.scrollbar)
	updateSize(self)
end

LBO:RegisterWidget(widget, version, function(self, name)
	self:SetWidth(0)
	self:SetHeight(0)
	self.scrollframe = CreateFrame("ScrollFrame", name.."Parent", self, "UIPanelScrollFrameTemplate")
	self.scrollframe:SetAllPoints()
	self.scrollframe.scrollBarHideable = 1
	self.content = CreateFrame("Frame", nil, self.scrollframe)
	self.content:SetWidth(1)
	self.content:SetHeight(1)
	self.scrollbar = _G[name.."ParentScrollBar"]
	self.scrollbar:ClearAllPoints()
	self.scrollbar:SetPoint("TOPRIGHT", 0, -16)
	self.scrollbar:SetPoint("BOTTOMRIGHT", 0, 15)
	self.scrollbar:HookScript("OnValueChanged", onScroll)
	self.scrollframe:SetScrollChild(self.content)
	self.scrollframe:DisableDrawLayer("BACKGROUND")
	texture = self.scrollbar:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(0, 0, 0, 0.5)
	texture:SetPoint("TOP", _G[name.."ParentScrollBarScrollUpButton"], "BOTTOM", 0, -3)
	texture:SetPoint("BOTTOM", _G[name.."ParentScrollBarScrollDownButton"], "TOP", 0, 3)
	texture:SetWidth(8)
	texture = self.scrollbar:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(1, 1, 1, 0.2)
	texture:SetPoint("TOP", _G[name.."ParentScrollBarScrollUpButton"], "BOTTOM", 0, -4)
	texture:SetPoint("BOTTOM", _G[name.."ParentScrollBarScrollDownButton"], "TOP", 0, 4)
	texture:SetWidth(6)
	self:SetScript("OnShow", onShow)
	self:SetScript("OnHide", onHide)
	self:SetScript("OnSizeChanged", updateSize)
	self.scrollbar.Show = scrollbarShow
	self.scrollbar.Hide = scrollbarHide
	onShow(self)
end)