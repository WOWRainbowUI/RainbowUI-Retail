-----------------------------------------------------------------------
-- Description: Creates and manages the tab buttons for the Accountant Classic frame.
-- This file is used to build the tab UI and handle tab switching behavior
-- within the main window.
-----------------------------------------------------------------------

local _G = getfenv(0)
local _, private = ...

local Client = private.Client
local function createRetailTabTextures(tab)
	local left = tab:CreateTexture(nil, "BACKGROUND")
	left:SetAtlas("uiframe-tab-left", true)
	left:SetPoint("TOPLEFT", tab, "TOPLEFT", -3, 0)
	tab.Left = left

	local right = tab:CreateTexture(nil, "BACKGROUND")
	right:SetAtlas("uiframe-tab-right", true)
	right:SetPoint("TOPRIGHT", tab, "TOPRIGHT", 7, 0)
	tab.Right = right

	local middle = tab:CreateTexture(nil, "BACKGROUND")
	middle:SetAtlas("_uiframe-tab-center", true)
	middle:SetHorizTile(true)
	middle:SetPoint("LEFT", left, "RIGHT")
	middle:SetPoint("RIGHT", right, "LEFT")
	tab.Middle = middle

	local leftActive = tab:CreateTexture(nil, "BACKGROUND")
	leftActive:SetAtlas("uiframe-activetab-left", true)
	leftActive:SetPoint("TOPLEFT", tab, "TOPLEFT", -1, 0)
	tab.LeftActive = leftActive

	local rightActive = tab:CreateTexture(nil, "BACKGROUND")
	rightActive:SetAtlas("uiframe-activetab-right", true)
	rightActive:SetPoint("TOPRIGHT", tab, "TOPRIGHT", 8, 0)
	tab.RightActive = rightActive

	local middleActive = tab:CreateTexture(nil, "BACKGROUND")
	middleActive:SetAtlas("_uiframe-activetab-center", true)
	middleActive:SetHorizTile(true)
	middleActive:SetPoint("LEFT", leftActive, "RIGHT")
	middleActive:SetPoint("RIGHT", rightActive, "LEFT")
	tab.MiddleActive = middleActive

	local text = tab:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	text:SetPoint("CENTER", tab, "CENTER", 0, 2)
	tab.Text = text
end

local function createTab(parent, index, text)
	local template
	if Client.isAnyClassic then
		template = "CharacterFrameTabButtonTemplate"
	end

	local tab = CreateFrame("Button", parent:GetName().."Tab"..index, parent, template)
	tab:SetID(index)
	tab:SetSize(10, 32)
	if not template then
		createRetailTabTextures(tab)
	else
		tab.Text = tab.Text or _G[tab:GetName().."Text"]
	end

	tab.Text:SetText(text)
	tab:SetScript("OnEnter", AccountantClassicTabButtonMixin.OnEnter)
	tab:SetScript("OnLeave", AccountantClassicTabButtonMixin.OnLeave)
	tab:SetScript("OnClick", AccountantClassicTabButtonMixin.OnClick)
	tab:SetScript("OnShow", AccountantClassicTabButtonMixin.OnShow)
	tab:RegisterEvent("DISPLAY_SIZE_CHANGED")
	tab:SetScript("OnEvent", AccountantClassicTabButtonMixin.OnEvent)
	AccountantClassicTabButtonMixin.OnLoad(tab)
	return tab
end

function AccountantClassic_CreateTabs(parent)
	local tabText = private.constants.tabText
	local tabs = {}
	for index = 1, #tabText do
		tabs[index] = createTab(parent, index, tabText[index])
	end

	local firstTab = tabs[1]
	firstTab:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", Client.isAnyClassic and 5 or 15, -20)
	for index = 2, 10 do
		local row = index % 2 == 0 and 1 or 2
		local previous = tabs[index == 2 and 1 or index - 2]
		local offset = Client.isAnyClassic and -20 or 5
		local y = index == 3 and (Client.isAnyClassic and -26 or -32) or 0
		tabs[index]:SetPoint("LEFT", previous, "RIGHT", offset, y)
	end
	tabs[11]:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", Client.isAnyClassic and 0 or -5, -20)
	return tabs
end
