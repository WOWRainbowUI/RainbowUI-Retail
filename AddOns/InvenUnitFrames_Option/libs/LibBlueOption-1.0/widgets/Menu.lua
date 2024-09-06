local widget, version = "Menu", 1
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

local function selectMenu(self, idx)
	if idx and self.buttons[idx] then
		self.selected = idx
		if type(self.buttons[idx].func) == "function" then
			self.buttons[idx].func(idx, self.arg1, self.arg2, self.arg3)
		end
		for i, button in ipairs(self.buttons) do
			if i == idx then
				button:LockHighlight()
			else
				button:UnlockHighlight()
			end
		end
	else
		self.selected = nil
		for i, button in ipairs(self.buttons) do
			button:UnlockHighlight()
		end
	end
end

local function getSelectedMenu(self)
	return self.selected
end

local function buttonOnClick(self)
	selectMenu(self:GetParent():GetParent():GetParent():GetParent(), self:GetID())
--	PlaySound("igMainMenuOptionCheckBoxOn")
end

local function buttonOnEnter(self)
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 0)
		GameTooltip:AddLine(self:GetText(), 1, 1, 1)
		GameTooltip:AddLine(self.tooltip, nil, nil, nil, true)
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end
end

local function createButton(self, i)
	self.buttons[i] = CreateFrame("Button", self:GetName().."Button"..i, self.inner.content, "OptionsListButtonTemplate")
	self.buttons[i]:SetID(i)
	self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, 0)
	self.buttons[i]:SetPoint("TOPRIGHT", self.buttons[i - 1], "BOTTOMRIGHT", 0, 0)
	self.buttons[i]:SetScript("OnClick", buttonOnClick)
	self.buttons[i]:SetScript("OnEnter", buttonOnEnter)
	self.buttons[i]:SetScript("OnLeave", GameTooltip_Hide)
	self.buttons[i]:SetText(self.get[i].name or " ")
	self.buttons[i].text = self.buttons[i]:GetFontString()
	self.buttons[i].text:ClearAllPoints()
	self.buttons[i].text:SetPoint("TOPLEFT", 6, 0)
	self.buttons[i].text:SetPoint("BOTTOMRIGHT", -6, 0)
	self.buttons[i].tooltip = self.get[i].desc
	self.buttons[i].func = self.get[i].func
	self.buttons[i]:Show()
end

LBO:RegisterWidget(widget, version, function(self, name)
	self:SetBackdrop(backdrop)
	self:SetBackdropBorderColor(1, 1, 1)
	if type(self.get) ~= "table" or #self.get == 0 then return end
	self.inner = LBO:CreateWidget("ScrollFrame", self)
	self.inner:SetPoint("TOPLEFT", 5, -5)
	self.inner:SetPoint("BOTTOMRIGHT", -5, 5)
	self.buttons = {}
	self.num = #self.get
	for i = 1, self.num do
		createButton(self, i)
	end
	self.buttons[1]:ClearAllPoints()
	self.buttons[1]:SetPoint("TOPLEFT", -2, -1)
	self.buttons[1]:SetPoint("TOPRIGHT", 2, -1)
	self.SetValue = selectMenu
	self.GetValue = getSelectedMenu
end)