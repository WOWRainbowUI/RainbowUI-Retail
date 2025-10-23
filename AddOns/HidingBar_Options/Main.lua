local main, hb = HidingBarConfigAddon, HidingBarAddon
local addon, L = main.name, main.L
main.noIcon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
main.noIcon:SetTexCoord(.05, .95, .05, .95)
main.noIcon:Hide()
main.buttons, main.mbuttons, main.mixedButtons = {}, {}, {}
main.defIcon = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and 651945 or 450906
local media = LibStub("LibSharedMedia-3.0")
local lsfdd = LibStub("LibSFDropDown-1.5")


local ddCreateStretchButton, ddCreateButton, ddCreateMediaBackgroundButton, ddCreateMediaBorderButton, ddCreateMediaStatusbarButton
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	ddCreateStretchButton = function(...) return lsfdd:CreateStretchButton(...) end
	ddCreateButton = function(...) return lsfdd:CreateModernButton(...) end
	ddCreateMediaBackgroundButton = function(...) return lsfdd:CreateMediaBackgroundModernButton(...) end
	ddCreateMediaBorderButton = function(...) return lsfdd:CreateMediaBorderModernButton(...) end
	ddCreateMediaStatusbarButton = function(...) return lsfdd:CreateMediaStatusbarModernButton(...) end
else
	ddCreateStretchButton = function(...)
		local btn = lsfdd:CreateStretchButton(...)
		btn:ddSetDisplayMode("menuBackdrop")
		return btn
	end
	ddCreateButton = function(...) return lsfdd:CreateButton(...) end
	ddCreateMediaBackgroundButton = function(...) return lsfdd:CreateMediaBackgroundButton(...) end
	ddCreateMediaBorderButton = function(...) return lsfdd:CreateMediaBorderButton(...) end
	ddCreateMediaStatusbarButton = function(...) return lsfdd:CreateMediaStatusbarButton(...) end
end


local lang, margin = GetLocale()
if lang == "zhTW" or lang == "zhCN" then
	margin = 16
else
	margin = 18
end


local scale = WorldFrame:GetWidth() / GetPhysicalScreenSize() / UIParent:GetScale()
main.optionsPanelBackdrop = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 14 * scale,
	edgeSize = 14 * scale,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


main.editBoxBackdrop = {
	bgFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	tile = true, edgeSize = 1 * scale, tileSize = 5 * scale,
}


main.colorButtonBackdrop = {
	edgeFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeSize = 1 * scale,
}


main.darkPanelBackdrop = {
	bgFile = "Interface/ChatFrame/ChatFrameBackground",
	edgeFile = "Interface/Buttons/UI-SliderBar-Border",
	tile = true,
	tileEdge = true,
	tileSize = 8 * scale,
	edgeSize = 8 * scale,
	insets = {left = 3, right = 3, top = 6, bottom = 6},
}


local function toHex(tbl)
	local str = ("%02x"):format(tbl[1] * 255)
	for i = 2, #tbl do
		str = str..("%02x"):format(tbl[i] * 255)
	end
	return str
end


local function showColorPicker(color, cb)
	if ColorPickerFrame:IsShown() then
		if ColorPickerFrame.cancelFunc then ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues) end
		HideUIPanel(ColorPickerFrame)
	end
	local info = {}
	info.r, info.g, info.b, info.opacity = unpack(color)
	if info.opacity then
		info.hasOpacity = true
		info.opacity = info.opacity
		info.opacityFunc = function()
			if OpacitySliderFrame then
				cb(nil, nil, nil, OpacitySliderFrame:GetValue())
			else
				cb(nil, nil, nil, ColorPickerFrame:GetColorAlpha())
			end
		end
	end
	info.swatchFunc = function()
		cb(ColorPickerFrame:GetColorRGB())
	end
	info.cancelFunc = function(color)
		cb(color.r, color.g, color.b, color.opacity or color.a)
	end
	if OpenColorPicker then
		OpenColorPicker(info)
	else
		ColorPickerFrame:SetupColorPickerAndShow(info)
	end
end


local function alignText(...)
	local maxWidth = 0
	for i = 1, select("#", ...) do
		maxWidth = math.max(maxWidth, select(i, ...):GetWidth())
	end
	for i = 1, select("#", ...) do
		local text = select(i, ...)
		text:SetWidth(maxWidth)
		text:SetJustifyH("RIGHT")
	end
end


local function tabClick(tab)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
	for i = 1, #tab.tabs do
		local checked = tab == tab.tabs[i]
		tab.tabs[i]:SetEnabled(not checked)
		tab.tabs[i].panel:SetShown(checked)
	end
end


local function createTabPanel(tabs, name)
	local panel = CreateFrame("FRAME", nil, main, "HidingBarAddonOptionsPanel")
	local tab = CreateFrame("BUTTON", nil, main, "HidingBarAddonTabTemplate")
	tab.panel = panel
	tab.tabs = tabs
	tab:SetText(name)
	tab:SetWidth(tab:GetTextWidth() + 48)
	tab:SetScript("OnClick", tabClick)

	if #tabs == 0 then
		tab:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 3, -1)
		tab:Disable()
	else
		local anchorTab = tabs[#tabs]
		tab:SetPoint("LEFT", anchorTab, "RIGHT", -16, 0)
		panel:SetPoint("TOPLEFT", anchorTab.panel)
		panel:SetPoint("BOTTOMRIGHT", anchorTab.panel)
		panel:Hide()
	end
	tinsert(tabs, tab)

	return panel
end
local buttonsTabs, barSettingsTabs = {}, {}

-- DIALOGS
main.addonName = ("%s_ADDON_"):format(addon:upper())
StaticPopupDialogs[main.addonName.."NEW_PROFILE"] = {
	text = addon..": "..L["New profile"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	editBoxWidth = 350,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) cb(self) end,
	EditBoxOnEnterPressed = function(self)
		StaticPopup_OnClick(self:GetParent(), 1)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		local editBox = self.EditBox or self.editBox
		editBox:SetText(UnitName("player").." - "..GetRealmName())
		editBox:HighlightText()
	end,
}
local function profileExistsAccept(popup, data)
	if not popup then return end
	popup:Hide()
	main:profilePopupAction(data)
	main.profilePopupAction = nil
	main.lastProfileName = nil
end
StaticPopupDialogs[main.addonName.."PROFILE_EXISTS"] = {
	text = addon..": "..L["A profile with the same name exists."],
	button1 = OKAY,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = profileExistsAccept,
	OnCancel = profileExistsAccept,
}
StaticPopupDialogs[main.addonName.."EDIT_PROFILE"] = {
	text = addon..": "..EDIT,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	editBoxWidth = 350,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) cb(self) end,
	EditBoxOnEnterPressed = function(self)
		StaticPopup_OnClick(self:GetParent(), 1)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
}
StaticPopupDialogs[main.addonName.."DELETE_PROFILE"] = {
	text = addon..": "..L["Are you sure you want to delete profile %s?"],
	button1 = DELETE,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."NEW_BAR"] = {
	text = addon..": "..L["Add bar"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	editBoxWidth = 350,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) cb(self) end,
	EditBoxOnEnterPressed = function(self)
		StaticPopup_OnClick(self:GetParent(), 1)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		local editBox = self.EditBox or self.editBox
		editBox:SetText(L["Bar"].." "..(#main.pBars + 1))
		editBox:HighlightText()
	end,
}
local function barExistsAccept(popup, data)
	if not popup then return end
	popup:Hide()
	main:barPopupAction(data)
	main.barPopupAction = nil
	main.lastBarName = nil
end
StaticPopupDialogs[main.addonName.."BAR_EXISTS"] = {
	text = addon..": "..L["A bar with the same name exists."],
	button1 = OKAY,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = barExistsAccept,
	OnCancel = barExistsAccept,
}
StaticPopupDialogs[main.addonName.."DELETE_BAR"] = {
	text = addon..": "..L["Are you sure you want to delete bar %s?"],
	button1 = DELETE,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."GET_RELOAD"] = {
	text = addon..": "..L["RELOAD_INTERFACE_QUESTION"],
	button1 = YES,
	button2 = NO,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function() ReloadUI() end,
}
StaticPopupDialogs[main.addonName.."ADD_IGNORE_MBTN"] = {
	text = addon..": "..L["ADD_IGNORE_MBTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."REMOVE_IGNORE_MBTN"] = {
	text = addon..": "..L["REMOVE_IGNORE_MBTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."ADD_CUSTOM_GRAB_BTN"] = {
	text = addon..": "..L["ADD_CUSTOM_GRAB_BTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}
StaticPopupDialogs[main.addonName.."REMOVE_CUSTOM_GRAB_BTN"] = {
	text = addon..": "..L["REMOVE_CUSTOM_GRAB_BTN_QUESTION"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1,
	whileDead = 1,
	OnAccept = function(self, cb) self:Hide() cb() end,
}

-- ADDON INFO
local info = main:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
info:SetPoint("TOPLEFT", 40, 20)
info:SetTextColor(.5, .5, .5, 1)
info:SetJustifyH("RIGHT")
info:SetText(C_AddOns.GetAddOnMetadata(addon, "Version"))

-- TITLE
local title = main:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetJustifyH("LEFT")
title:SetText(L["%s Configuration"]:format(L["HidingBar "])) -- 設定選項標題

-- PROFILES COMBOBOX
local profilesCombobox = ddCreateStretchButton(main, 150, 22)
profilesCombobox:SetPoint("TOPRIGHT", -16, -12)

profilesCombobox:ddSetInitFunc(function(self, level)
	local info = {}

	if level == 1 then
		local widgets = {
			{
				icon = [[Interface\WorldMap\GEAR_64GREY]],
				OnClick = function(btn)
					main:editProfile(btn.value)
					self:ddCloseMenus()
				end,
				OnTooltipShow = function(_, tooltip)
					tooltip:SetText(EDIT)
				end,
			},
		}

		local function removeProfile(btn)
			main:removeProfile(btn.value)
		end

		local function selectProfile(btn)
			hb:setProfile(btn.value)
			main:setProfile()
			main:hidingBarUpdate()
		end

		info.list = {}
		for i, profile in ipairs(hb.profiles) do
			local subInfo = {
				text = profile.isDefault and profile.name.." "..DARKGRAY_COLOR:WrapTextInColorCode(DEFAULT) or profile.name,
				value = profile.name,
				checked = profile.name == main.currentProfile.name,
				func = selectProfile,
				widgets = widgets,
			}
			if #hb.profiles > 1 then
				subInfo.remove = removeProfile
			end
			tinsert(info.list, subInfo)
		end
		self:ddAddButton(info, level)
		info.list = nil

		self:ddAddSeparator(level)

		info.keepShownOnClick = true
		info.notCheckable = true
		info.hasArrow = true
		info.text = L["New profile"]
		self:ddAddButton(info, level)

		if not main.currentProfile.isDefault then
			info.keepShownOnClick = nil
			info.hasArrow = nil
			info.text = L["Set as default"]
			info.func = function()
				for _, profile in ipairs(hb.profiles) do
					profile.isDefault = nil
				end
				main.currentProfile.isDefault = true
			end
			self:ddAddButton(info, level)
		end
	else
		info.notCheckable = true

		info.text = L["Create"]
		info.func = function() main:createProfile() end
		self:ddAddButton(info, level)

		info.text = L["Copy current"]
		info.func = function() main:createProfile(true) end
		self:ddAddButton(info, level)
	end
end)

-- PROFILES TEXT
local profilesText = main:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
profilesText:SetPoint("RIGHT", profilesCombobox, "LEFT", -5, 0)
profilesText:SetText(L["Profile"])

-------------------------------------------
-- BAR TAB PANEL
-------------------------------------------
main.barPanel = createTabPanel(buttonsTabs, L["Bar"])
main.barPanel:SetHeight(242)
main.barPanel:SetPoint("TOPLEFT", 8, -58)
main.barPanel:SetPoint("TOPRIGHT", -8, -58)

local barPanelScroll = CreateFrame("ScrollFrame", nil, main.barPanel)
barPanelScroll:SetPoint("TOPLEFT", main.barPanel, 4, -4)
barPanelScroll:SetPoint("BOTTOMRIGHT", main.barPanel, -23, 23)

barPanelScroll:SetScript("OnVerticalScroll", function(self, offset)
	local scrollRange = self:GetVerticalScrollRange()
	self.vBar:SetScrollPercentage(scrollRange > 0 and offset / scrollRange or 0, ScrollBoxConstants.NoScrollInterpolation)
end)
barPanelScroll:SetScript("OnHorizontalScroll", function(self, offset)
	local scrollRange = self:GetHorizontalScrollRange()
	self.hBar:SetScrollPercentage(scrollRange > 0 and offset / scrollRange or 0, ScrollBoxConstants.NoScrollInterpolation)
end)
barPanelScroll:SetScript("OnScrollRangeChanged", function(self, xrange, yrange)
	self:GetScript("OnVerticalScroll")(self, self:GetVerticalScroll())
	self:GetScript("OnHorizontalScroll")(self, self:GetHorizontalScroll())
	local num = 30
	local width, height = self:GetSize()
	self.vBar:SetVisibleExtentPercentage(height > 0 and height / (yrange + height) or 0)
	self.vBar:SetPanExtentPercentage(yrange > 0 and num / yrange or 0)
	self.hBar:SetVisibleExtentPercentage(width > 0 and width / (xrange + width) or 0)
	self.hBar:SetPanExtentPercentage(xrange > 0 and num / xrange or 0)
end)
barPanelScroll:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 then
		if self.vBar:GetScrollPercentage() > 0 and self.vBar:GetThumb():IsShown() then
			self.vBar:ScrollStepInDirection(-delta)
		else
			self.hBar:ScrollStepInDirection(-delta * 3)
		end
	else
		if self.vBar:GetScrollPercentage() < 1 and self.vBar:GetThumb():IsShown() then
			self.vBar:ScrollStepInDirection(-delta)
		else
			self.hBar:ScrollStepInDirection(-delta * 3)
		end
	end
end)

barPanelScroll.vBar = CreateFrame("EventFrame", nil, main.barPanel, "WowTrimScrollBar")
barPanelScroll.vBar:SetPoint("TOPLEFT", barPanelScroll, "TOPRIGHT", -2, 4)
barPanelScroll.vBar:SetPoint("BOTTOMLEFT", barPanelScroll, "BOTTOMRIGHT", -2, -4)
barPanelScroll.vBar.Background:Hide()
barPanelScroll.vBar.Backplate:SetPoint("TOPLEFT", 4, -4)
barPanelScroll.vBar.Backplate:SetPoint("BOTTOMRIGHT", -4, 4)
barPanelScroll.vBar.Backplate:SetTexture("interface/buttons/white8x8")
barPanelScroll.vBar.Backplate:SetVertexColor(0, 0, 0, .2)
barPanelScroll.vBar:RegisterCallback(barPanelScroll.vBar.Event.OnScroll, function(scrollFrame, scrollPercentage)
	scrollFrame:SetVerticalScroll(scrollPercentage * scrollFrame:GetVerticalScrollRange())
end, barPanelScroll)

barPanelScroll.hBar = CreateFrame("EventFrame", nil, main.barPanel, "WowTrimHorizontalScrollBar")
barPanelScroll.hBar:SetPoint("TOPLEFT", barPanelScroll, "BOTTOMLEFT", -5, 2)
barPanelScroll.hBar:SetPoint("TOPRIGHT", barPanelScroll, "BOTTOMRIGHT", 4, 2)
barPanelScroll.hBar.Background:Hide()
barPanelScroll.hBar.Backplate = barPanelScroll.hBar:GetRegions()
barPanelScroll.hBar.Backplate:SetPoint("TOPLEFT", 4, -4)
barPanelScroll.hBar.Backplate:SetPoint("BOTTOMRIGHT", -4, 4)
barPanelScroll.hBar.Backplate:SetTexture("interface/buttons/white8x8")
barPanelScroll.hBar.Backplate:SetVertexColor(0, 0, 0, .2)
barPanelScroll.hBar:RegisterCallback(barPanelScroll.hBar.Event.OnScroll, function(scrollFrame, scrollPercentage)
	scrollFrame:SetHorizontalScroll(scrollPercentage * scrollFrame:GetHorizontalScrollRange())
end, barPanelScroll)

barPanelScroll.child = CreateFrame("FRAME")
barPanelScroll.child:SetSize(1, 1)
barPanelScroll:SetScrollChild(barPanelScroll.child)

-- BAR COMBOBOX
local barCombobox = ddCreateButton(barPanelScroll.child, 120)
barCombobox:SetPoint("TOPLEFT", 3, -6)

barCombobox:ddSetInitFunc(function(self)
	local info = {}
	info.list = {}

	local widgets = {
		{
			icon = [[Interface\WorldMap\GEAR_64GREY]],
			OnClick = function(btn)
				main:editBar(btn.value.name)
				self:ddCloseMenus()
			end,
			OnTooltipShow = function(_, tooltip)
				tooltip:SetText(EDIT)
			end,
		},
	}

	local function removeBar(btn)
		main:removeBar(btn.value.name)
	end

	local function selectBar(btn)
		main:setBar(btn.value)
	end

	for i, bar in ipairs(main.pBars) do
		local subInfo = {
			text = bar.isDefault and bar.name.." "..DARKGRAY_COLOR:WrapTextInColorCode(DEFAULT) or bar.name,
			value = bar,
			checked = bar.name == main.currentBar.name,
			func = selectBar,
			widgets = widgets,
		}
		if #main.pBars > 1 then
			subInfo.remove = removeBar
		end
		tinsert(info.list, subInfo)
	end
	self:ddAddButton(info)
	info.list = nil

	self:ddAddSeparator()

	info.notCheckable = true
	info.text = L["Add bar"]
	info.func = function() main:createBar() end
	self:ddAddButton(info)

	if not main.currentBar.isDefault then
		info.text = L["Set as default"]
		info.func = function()
			for _, bar in ipairs(main.pBars) do
				bar.isDefault = nil
			end
			main.currentBar.isDefault = true
			hb:updateBars()
			main:setBar(main.currentBar)
		end
		self:ddAddButton(info)
	end
end)

-- BAR HELP
main.helpPlate = CreateFrame("FRAME", nil, barPanelScroll.child, "HidingBarAddonHelpPlate")
main.helpPlate:SetPoint("LEFT", barCombobox, "RIGHT", -15, 1)

-- BUTTON PANEL
main.buttonPanel = CreateFrame("Frame", nil, barPanelScroll.child, "HidingBarAddonPanel")
main.buttonPanel:SetPoint("TOPLEFT", barCombobox, "BOTTOMLEFT", 2, -5)

-------------------------------------------
-- IGNORE TAB PANEL
-------------------------------------------
main.ignoreTabPanel = createTabPanel(buttonsTabs, L["Ignore list"])

-- ADD IGNORE TEXT
local editBoxIgnore = CreateFrame("EditBox", nil, main.ignoreTabPanel, "HidingBarAddonAddTextBox")
editBoxIgnore:SetPoint("TOPLEFT", main.ignoreTabPanel, 15, -9)
editBoxIgnore:SetScript("OnTextChanged", function(editBox)
	local textExists = editBox:GetText() ~= ""
	main.ignoreBtn:SetEnabled(textExists)
	editBox.clearButton:SetShown(editBox:HasFocus() or textExists)
end)
editBoxIgnore:SetScript("OnEnterPressed", function(editBox)
	local text = editBox:GetText()
	if text ~= "" then
		main:addIgnoreName(text)
		editBox:SetText("")
	end
	EditBox_ClearFocus(editBox)
end)

-- ADD IGNORE BUTTON
main.ignoreBtn = CreateFrame("BUTTON", nil, main.ignoreTabPanel, "UIPanelButtonTemplate")
main.ignoreBtn:SetSize(80, 22)
main.ignoreBtn:SetPoint("LEFT", editBoxIgnore, "RIGHT")
main.ignoreBtn:SetText(ADD)
main.ignoreBtn:Disable()
main.ignoreBtn:SetScript("OnClick", function()
	local text = editBoxIgnore:GetText()
	if text ~= "" then
		main:addIgnoreName(text)
		editBoxIgnore:SetText("")
	end
	EditBox_ClearFocus(editBoxIgnore)
end)

-- IGNORE SCROLL
main.ignoreScroll = CreateFrame("FRAME", nil, main.ignoreTabPanel, "WowScrollBoxList")
main.ignoreScroll:SetSize(302, 200)
main.ignoreScroll:SetPoint("TOPLEFT", editBoxIgnore, "BOTTOMLEFT", -2, -2)
local customGrabScrollBg = main.ignoreScroll:CreateTexture(nil, "BACKGROUND")
customGrabScrollBg:SetAllPoints()
customGrabScrollBg:SetColorTexture(0, 0, 0, .2)
main.ignoreScroll.scrollBar = CreateFrame("EventFrame", nil, main.ignoreTabPanel, "MinimalScrollBar")
main.ignoreScroll.scrollBar:SetPoint("TOPLEFT", main.ignoreScroll, "TOPRIGHT", 6, -2)
main.ignoreScroll.scrollBar:SetPoint("BOTTOMLEFT", main.ignoreScroll, "BOTTOMRIGHT", 6, 0)
main.ignoreScroll.view = CreateScrollBoxListLinearView()
main.ignoreScroll.view:SetElementInitializer("HidingBarAddonCustomGrabButtonTemplate", function(btn, data)
	btn:SetText(data.name:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1"))
	btn.removeButton:SetScript("OnClick", function()
		main:removeIgnoreName(data.name)
	end)
end)
ScrollUtil.InitScrollBoxListWithScrollBar(main.ignoreScroll, main.ignoreScroll.scrollBar, main.ignoreScroll.view)
main.ignoreScroll.update = function(scroll)
	local dataProvider = CreateDataProvider()
	for i = 1, #main.pConfig.ignoreMBtn do
		dataProvider:Insert({index = i, name = main.pConfig.ignoreMBtn[i]})
	end
	scroll:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

-- IGNORE DESCRIPTION
local ignoreDescription = main.ignoreTabPanel:CreateFontString("ARTWORK", nil, "GameFontHighlight")
ignoreDescription:SetPoint("TOPLEFT", main.ignoreBtn, "TOPRIGHT", 5, 0)
ignoreDescription:SetPoint("BOTTOMRIGHT", main.ignoreTabPanel, -5, 5)
ignoreDescription:SetJustifyH("LEFT")
ignoreDescription:SetText(L["IGNORE_DESCRIPTION"])

-------------------------------------------
-- ADD BUTTONS OPTIONS TAB PANEL
-------------------------------------------
main.addBtnOptionsPanel = createTabPanel(buttonsTabs, L["Options of adding buttons"])

local addBtnOptionsScroll = CreateFrame("ScrollFrame", nil, main.addBtnOptionsPanel)
addBtnOptionsScroll:SetPoint("TOPLEFT", main.addBtnOptionsPanel, 4, -4)
addBtnOptionsScroll:SetPoint("BOTTOMRIGHT", main.addBtnOptionsPanel, -22, 4)

addBtnOptionsScroll.scrollBar = CreateFrame("EventFrame", nil, main.addBtnOptionsPanel, "MinimalScrollBar")
addBtnOptionsScroll.scrollBar:SetPoint("TOPLEFT", addBtnOptionsScroll, "TOPRIGHT", 5, 0)
addBtnOptionsScroll.scrollBar:SetPoint("BOTTOMLEFT", addBtnOptionsScroll, "BOTTOMRIGHT", 5, 0)
ScrollUtil.InitScrollFrameWithScrollBar(addBtnOptionsScroll, addBtnOptionsScroll.scrollBar)

addBtnOptionsScroll.child = CreateFrame("FRAME")
addBtnOptionsScroll.child:SetSize(1, 1)
addBtnOptionsScroll:SetScrollChild(addBtnOptionsScroll.child)

-- ADD FROM DATA BROKER
main.addBtnFromDataBroker = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.addBtnFromDataBroker:SetPoint("TOPLEFT", 4, -2)
main.addBtnFromDataBroker.Text:SetText(L["Add buttons from DataBroker"])
main.addBtnFromDataBroker:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	main.pConfig.addFromDataBroker = checked
	hb:addButtons()
	main:setBar()
	main:hidingBarUpdate(true)
	main.addAnyTypeFromDataBroker:SetEnabled(checked)
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- ADD ANY TYPE FROM DATA BROKER
main.addAnyTypeFromDataBroker = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.addAnyTypeFromDataBroker:SetPoint("TOPLEFT", main.addBtnFromDataBroker, "BOTTOMLEFT", 20, 0)
main.addAnyTypeFromDataBroker.Text:SetText(L["Add buttons of any data type"])
main.addAnyTypeFromDataBroker:SetScript("OnClick", function(btn)
	main.pConfig.addAnyTypeFromDataBroker = btn:GetChecked()
	hb:addButtons()
	main:setBar()
	main:hidingBarUpdate(true)
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

-- GRAB DEFAULT BUTTONS
main.grabDefault = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grabDefault:SetPoint("TOPLEFT", main.addAnyTypeFromDataBroker, "BOTTOMLEFT", -20, 0)
main.grabDefault.Text:SetText(L["Grab default buttons on minimap"])
main.grabDefault:SetScript("OnClick", function(btn)
	main.pConfig.grabDefMinimap = btn:GetChecked()
	main:removeAllMButtonsWithoutOMB()
	hb:addButtons()
	main:hidingBarUpdate()
	if LibStub("Masque", true) then
		StaticPopup_Show(main.addonName.."GET_RELOAD")
	end
end)

-- GRAB ADDONS BUTTONS
main.grab = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grab:SetPoint("TOPLEFT", main.grabDefault, "BOTTOMLEFT")
main.grab.Text:SetText(L["Grab addon buttons on minimap"])
main.grab:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	main.pConfig.grabMinimap = checked
	main:removeAllMButtonsWithoutOMB()
	hb:addButtons()
	main:hidingBarUpdate()
	main.grabAfter:SetEnabled(checked)
	main.grabWithoutName:SetEnabled(checked)
	if LibStub("Masque", true) then
		StaticPopup_Show(main.addonName.."GET_RELOAD")
	end
end)

-- GRAB AFTER N SECOND
main.grabAfter = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grabAfter:SetPoint("TOPLEFT", main.grab, "BOTTOMLEFT", 20, 0)
main.grabAfter.Text:SetText(L["Try to grab after"])
main.grabAfter:SetHitRectInsets(0, -main.grabAfter.Text:GetWidth(), 0, 0)
main.grabAfter:SetScript("OnClick", function(btn)
	main.pConfig.grabMinimapAfter = btn:GetChecked()
	StaticPopup_Show(main.addonName.."GET_RELOAD")
end)

main.afterNumber = CreateFrame("EditBox", nil, addBtnOptionsScroll.child, "HidingBarAddonNumberTextBox")
main.afterNumber:SetPoint("LEFT", main.grabAfter.Text, "RIGHT", 3, 0)
main.afterNumber:setOnChanged(function(editBox, n)
	if n < 1 then n = 1 end
	editBox:SetNumber(n)
	main.pConfig.grabMinimapAfterN = n
end)

main.grabAfterTextSec = addBtnOptionsScroll.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.grabAfterTextSec:SetPoint("LEFT", main.afterNumber, "RIGHT", 3, 0)
main.grabAfterTextSec:SetText(L["sec."])

main.grabAfter:HookScript("OnEnable", function(btn)
	main.afterNumber:Enable()
	main.grabAfterTextSec:SetTextColor(btn.Text:GetTextColor())
end)
main.grabAfter:HookScript("OnDisable", function(btn)
	main.afterNumber:Disable()
	main.grabAfterTextSec:SetTextColor(btn.Text:GetTextColor())
end)

-- GRAB WITHOUT NAME
main.grabWithoutName = CreateFrame("CheckButton", nil, addBtnOptionsScroll.child, "HidingBarAddonCheckButtonTemplate")
main.grabWithoutName:SetPoint("TOPLEFT", main.grabAfter, "BOTTOMLEFT")
main.grabWithoutName.Text:SetText(L["Grab buttons without a name"])
main.grabWithoutName:SetScript("OnClick", function(btn)
	main.pConfig.grabMinimapWithoutName = btn:GetChecked()
	main:removeAllMButtonsWithoutOMB()
	hb:addButtons()
	main:hidingBarUpdate()
	if LibStub("Masque", true) then
		StaticPopup_Show(main.addonName.."GET_RELOAD")
	end
end)

-- ADD BUTTON MANUALLY
local addButtonManuallyText = addBtnOptionsScroll.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
addButtonManuallyText:SetPoint("TOPLEFT", main.grabWithoutName, "BOTTOMLEFT", -13, -15)
addButtonManuallyText:SetText(L["Add button manually"])

-- MANUALLY GRAB EDITBOX
local editBoxGrab = CreateFrame("EditBox", nil, addBtnOptionsScroll.child, "HidingBarAddonAddTextBox")
editBoxGrab:SetWidth(348)
editBoxGrab:SetPoint("TOPLEFT", addButtonManuallyText, 0, -12)
editBoxGrab:SetScript("OnTextChanged", function(editBox)
	local textExists = editBox:GetText() ~= ""
	main.customGrabBtn:SetEnabled(textExists)
	editBox.clearButton:SetShown(editBox:HasFocus() or textExists)
end)
editBoxGrab:SetScript("OnEnterPressed", function(editBox)
	local text = editBox:GetText()
	if text ~= "" then
		main:addCustomGrabName(text)
		editBox:SetText("")
	end
	EditBox_ClearFocus(editBox)
end)

-- CUSTOM GRAB BTN
main.customGrabBtn = CreateFrame("BUTTON", nil, addBtnOptionsScroll.child, "UIPanelButtonTemplate")
main.customGrabBtn:SetSize(80, 22)
main.customGrabBtn:SetPoint("LEFT", editBoxGrab, "RIGHT")
main.customGrabBtn:SetText(ADD)
main.customGrabBtn:Disable()
main.customGrabBtn:SetScript("OnClick", function()
	local text = editBoxGrab:GetText()
	if text ~= "" then
		main:addCustomGrabName(text)
		editBoxGrab:SetText("")
	end
	EditBox_ClearFocus(editBoxGrab)
end)

-- CUSTOM POINT BTN
local coverGreen = CreateFrame("BUTTON")
coverGreen:SetFrameStrata("TOOLTIP")
coverGreen:SetFrameLevel(10000)
coverGreen.bg = coverGreen:CreateTexture(nil, "BACKGROUND")
coverGreen.bg:SetAllPoints()
coverGreen.bg:SetColorTexture(.2, 1, .2, .7)
coverGreen:Hide()
coverGreen:SetScript("OnClick", function(btn)
	main:addCustomGrabName(btn.name)
	main.customGrabPointBtn:Click()
end)
coverGreen:SetMouseMotionEnabled(false)

local ignoredNames = {
	"StaticPopup.+",
}

local function getNoErr(func, ...)
	local status, val = pcall(func, ...)
	return status and val
end

main.customGrabPointBtn = CreateFrame("BUTTON", nil, addBtnOptionsScroll.child, "UIPanelButtonTemplate")
main.customGrabPointBtn:SetSize(140, 22)
main.customGrabPointBtn:SetPoint("LEFT", main.customGrabBtn, "RIGHT")
main.customGrabPointBtn:SetText(L["Point to button"])
main.customGrabPointBtn:SetScript("OnUpdate", function(btn)
	if not btn.isPoint then return end
	local focus = GetMouseFoci()[1]
	if focus then
		local name = getNoErr(btn.GetName, focus)
		if name and not getNoErr(btn.IsProtected, focus) and (
				getNoErr(btn.HasScript, focus, "OnClick") and getNoErr(btn.GetScript, focus, "OnClick")
				or getNoErr(btn.HasScript, focus, "OnMouseUp") and getNoErr(btn.GetScript, focus, "OnMouseUp")
				or getNoErr(btn.HasScript, focus, "OnMouseDown") and getNoErr(btn.GetScript, focus, "OnMouseDown")
			)
		then
			for i = 1, #ignoredNames do
				if name:match(ignoredNames[i]) then return end
			end

			for i = 1, #hb.bars do
				local bar = hb.bars[i]
				if bar:IsShown() and bar:IsMouseOver() then return end
			end

			coverGreen.name = name
			coverGreen:SetAllPoints(focus)
			coverGreen:Show()
		else
			coverGreen:Hide()
		end
	else
		coverGreen:Hide()
	end
end)
main.customGrabPointBtn:SetScript("OnHide", function(btn)
	if btn.isPoint then btn:Click() end
end)
main.customGrabPointBtn:SetScript("OnClick", function(btn)
	if btn.isPoint then
		btn.isPoint = nil
		btn:SetText(L["Point to button"])
		coverGreen:Hide()
	else
		btn.isPoint = true
		btn:SetText(CANCEL)
	end
end)

-- CUSTOM GRAB SCROLL
main.customGrabScroll = CreateFrame("FRAME", nil, addBtnOptionsScroll.child, "WowScrollBoxList")
main.customGrabScroll:SetSize(547, 195)
main.customGrabScroll:SetPoint("TOPLEFT", editBoxGrab, "BOTTOMLEFT", -2, -2)
local customGrabScrollBg = main.customGrabScroll:CreateTexture(nil, "BACKGROUND")
customGrabScrollBg:SetAllPoints()
customGrabScrollBg:SetColorTexture(0, 0, 0, .2)
main.customGrabScroll.scrollBar = CreateFrame("EventFrame", nil, addBtnOptionsScroll.child, "MinimalScrollBar")
main.customGrabScroll.scrollBar:SetPoint("TOPLEFT", main.customGrabScroll, "TOPRIGHT", 6, -2)
main.customGrabScroll.scrollBar:SetPoint("BOTTOMLEFT", main.customGrabScroll, "BOTTOMRIGHT", 6, 0)
main.customGrabScroll.view = CreateScrollBoxListLinearView()
main.customGrabScroll.view:SetElementInitializer("HidingBarAddonCustomGrabButtonTemplate", function(btn, data)
	btn:SetText(data.name)
	btn.removeButton:SetScript("OnClick", function()
		main:removeCustomGrabName(data.name)
	end)
end)
ScrollUtil.InitScrollBoxListWithScrollBar(main.customGrabScroll, main.customGrabScroll.scrollBar, main.customGrabScroll.view)
main.customGrabScroll.update = function(scroll)
	local dataProvider = CreateDataProvider()
	for i = 1, #main.pConfig.customGrabList do
		dataProvider:Insert({index = i, name = main.pConfig.customGrabList[i]})
	end
	scroll:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

-------------------------------------------
-- BAR SETTINGS TAB PANEL
-------------------------------------------
main.barSettingsPanel = createTabPanel(barSettingsTabs, L["Bar settings"])
main.barSettingsPanel:SetPoint("TOPLEFT", main.barPanel, "BOTTOMLEFT", 0, -25)
main.barSettingsPanel:SetPoint("BOTTOMRIGHT", main, -8, 8)

-- RELOAD BUTTON
local reloadBtn = CreateFrame("BUTTON", nil, main, "UIPanelButtonTemplate")
reloadBtn:SetSize(96, 22)
reloadBtn:SetPoint("BOTTOMRIGHT", main.barSettingsPanel, "TOPRIGHT")
reloadBtn:SetText(RELOADUI)
reloadBtn:SetScript("OnClick", function()
	ReloadUI()
end)

-- EXPAND TO TEXT
local expandToText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
expandToText:SetPoint("TOPRIGHT", -10, -8)
expandToText:SetWidth(114)
expandToText:SetText(L["Expand to"])

-- EXPAND TO COMBOBOX
local expandToCombobox = ddCreateButton(main.barSettingsPanel, 120)
expandToCombobox:SetPoint("TOPRIGHT", expandToText, "BOTTOMRIGHT", 2, -5)
expandToCombobox.texts = {[0] = L["Right / Bottom"], L["Left / Top"], L["Both direction"]}

local function updateExpandTo(btn)
	expandToCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setBarExpand(btn.value)
	main:hidingBarUpdate()
end

expandToCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateExpandTo
		self:ddAddButton(info)
	end
end)

-- ORIENTATION TEXT
local orientationText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
orientationText:SetPoint("TOPLEFT", 8, -20)
orientationText:SetText(L["Orientation"])

-- ORIENTATION COMBOBOX
local orientationCombobox = ddCreateButton(main.barSettingsPanel, 120)
orientationCombobox:SetPoint("LEFT", orientationText, "RIGHT", 3, 0)
orientationCombobox.texts = {[0] = L["Auto"], L["Horizontal"], L["Vertical"]}

local function orientationChange(btn)
	orientationCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setOrientation(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

orientationCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = orientationChange
		self:ddAddButton(info)
	end
end)

-- FRAME STARTA TEXT
local fsText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fsText:SetPoint("LEFT", orientationCombobox, "RIGHT", 10, 0)
fsText:SetText(L["Strata of panel"])

-- FRAME STRATA COMBOBOX
local fsCombobox = ddCreateButton(main.barSettingsPanel, 120)
fsCombobox:SetPoint("LEFT", fsText, "RIGHT", 3, 0)
fsCombobox.texts = {[0] = "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}

local function fsChange(btn)
	fsCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setFrameStrata(btn.value)
end

fsCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = fsChange
		self:ddAddButton(info)
	end
end)

-- LOCK
local lock = CreateFrame("CheckButton", nil, main.barSettingsPanel, "HidingBarAddonCheckButtonTemplate")
lock:SetPoint("TOPLEFT", orientationText, "BOTTOMLEFT", 0, -13)
lock.Text:SetText(L["Lock the bar's location"])
lock:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.barFrame:setLocked(checked)
end)
hb:on("LOCK_UPDATED", function(_, isLocked, bar)
	if main.barFrame == bar then
		lock:SetChecked(isLocked)
	end
end)

-- HIDE HANDLER TEXT
local hideHandlerText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
hideHandlerText:SetPoint("TOPLEFT", lock, "BOTTOMLEFT", 0, -10)
hideHandlerText:SetText(L["Hide by"])

-- HIDE HANDLER
local hideHandlerCombobox = ddCreateButton(main.barSettingsPanel, 120)
hideHandlerCombobox:SetPoint("LEFT", hideHandlerText, "RIGHT", 3, 0)
hideHandlerCombobox.texts = {[0] = L["Timer"], L["Clicking on a free place"], L["Timer or clicking on a free place"], L["Clicking on a line or button"]}

local function updatehideHandler(btn)
	hideHandlerCombobox:ddSetSelectedValue(btn.value)
	main.bConfig.hideHandler = btn.value
	main:hidingBarUpdate()
end

hideHandlerCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updatehideHandler
		self:ddAddButton(info)
	end
end)

-- DELAY TO HIDE
local delayToHideText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
delayToHideText:SetPoint("LEFT", hideHandlerCombobox, "RIGHT", 10, 0)
delayToHideText:SetText(L["Delay to hide"])

local delayToHideEditBox = CreateFrame("EditBox", nil, main.barSettingsPanel, "HidingBarAddonDelayTextBox")
delayToHideEditBox:SetPoint("LEFT", delayToHideText, "RIGHT", 2, 0)
delayToHideEditBox:setOnChanged(function(editBox, value)
	main.bConfig.hideDelay = value
end)

-- SHOW HANDLER TEXT
local showHandlerText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
showHandlerText:SetPoint("TOPLEFT", hideHandlerText, "BOTTOMLEFT", 0, -margin)
showHandlerText:SetText(L["Show on"])

-- SHOW HANDLER
local showHandlerCombobox = ddCreateButton(main.barSettingsPanel, 120)
showHandlerCombobox:SetPoint("LEFT", showHandlerText, "RIGHT", 3, 0)
showHandlerCombobox.texts = {[0] = L["Hover"], L["Click"], L["Hover or Click"], L["Allways"]}

local function updateShowHandler(btn)
	showHandlerCombobox:ddSetSelectedValue(btn.value)
	local bar = main.barFrame
	bar.drag:setShowHandler(btn.value)
	main.lineColor.updateLineColor()
	bar:leave(math.max(1.5, bar.config.hideDelay))
end

showHandlerCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateShowHandler
		self:ddAddButton(info)
	end
end)

-- DELAY TO SHOW
local delayToShowText = main.barSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
delayToShowText:SetPoint("LEFT", showHandlerCombobox, "RIGHT", 10, 0)
delayToShowText:SetText(L["Delay to show"])

local delayToShowEditBox = CreateFrame("EditBox", nil, main.barSettingsPanel, "HidingBarAddonDelayTextBox")
delayToShowEditBox:SetPoint("LEFT", delayToShowText, "RIGHT", 2, 0)
delayToShowEditBox:setOnChanged(function(editBox, value)
	main.bConfig.showDelay = value
end)

-- FADE
main.fade = CreateFrame("CheckButton", nil, main.barSettingsPanel, "HidingBarAddonCheckButtonTemplate")
main.fade:SetPoint("TOPLEFT", showHandlerText, "BOTTOMLEFT", 0, -13)
main.fade:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.fadeOpacity:setEnabled(checked)
	main.barFrame:setFade(checked)
end)

-- FADE OPACITY
main.fadeOpacity = CreateFrame("FRAME", nil, main.barSettingsPanel, "HidingBarAddonSliderFrameTemplate")
main.fadeOpacity:SetPoint("LEFT", main.fade.Text, "RIGHT", 20, 5)
main.fadeOpacity:SetPoint("RIGHT", -10, 0)
main.fadeOpacity:setMinMax(0, .95)
main.fadeOpacity:setStep(.05)
main.fadeOpacity:setText(L["Opacity"])
main.fadeOpacity:setMaxLetters(4)
main.fadeOpacity:setOnChanged(function(frame, value)
	main.barFrame:setFadeOpacity(value)
end)

-- PET BATTLE HIDE
if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
	main.petBattleHide = CreateFrame("CheckButton", nil, main.barSettingsPanel, "HidingBarAddonCheckButtonTemplate")
	main.petBattleHide:SetPoint("TOPLEFT", main.fade, "BOTTOMLEFT", 0, -5)
	main.petBattleHide.Text:SetText(L["Hide the bar in Pet Battle"])
	main.petBattleHide:SetScript("OnClick", function(btn)
		local checked = btn:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		main.bConfig.petBattleHide = checked
		main.barFrame:refreshShown()
	end)
end

-- ALIGN
alignText(orientationText, hideHandlerText, showHandlerText)

-------------------------------------------
-- BAR DISPLAY SETTINGS
-------------------------------------------
main.displayPanel = createTabPanel(barSettingsTabs, L["Display"])

-- TEXTURES HELP TOOLTIP
local texturesHelpTooltip = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonHelpPlate")
texturesHelpTooltip:SetPoint("TOPRIGHT", 10, 10)
texturesHelpTooltip.tooltip = L["TEXTURES_HELP_TOOLTIP"]
texturesHelpTooltip.wrap = true

-- BACKGROUND TEXT
local bgText = main.displayPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
bgText:SetPoint("TOPLEFT", 8, -20)
bgText:SetText(L["Background"])

-- BACKGROUND COMBOBOX
local bgCombobox = ddCreateMediaBackgroundButton(main.displayPanel, 120)
bgCombobox:SetPoint("LEFT", bgText, "RIGHT", 3, 0)
bgCombobox:ddSetOnSelectedFunc(function(value)
	if value == "None" then value = false end
	main.barFrame:setBackground(value)
	main.buttonPanel.bg:SetTexture(media:Fetch("background", main.bConfig.bgTexture, true))
	main:hidingBarUpdate()
end)

-- BACKGROUND COLOR
local bgColor = CreateFrame("BUTTON", nil, main.displayPanel, "HidingBarAddonColorButton")
bgColor:SetPoint("LEFT", bgCombobox, "RIGHT", 3, 2)

bgColor:SetScript("OnClick", function()
	showColorPicker(main.bConfig.bgColor, function(...)
		main.barFrame:setBackground(nil, ...)
		main.buttonPanel.bg:SetVertexColor(unpack(main.bConfig.bgColor))
		bgColor.color:SetColorTexture(unpack(main.bConfig.bgColor))
		main:hidingBarUpdate()
	end)
end)

-- BORDER TEXT
local borderText = main.displayPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
borderText:SetPoint("TOPLEFT", bgText, "BOTTOMLEFT", 0, -margin)
borderText:SetText(L["Border"])

-- BORDER COMBOBOX
local borderCombobox = ddCreateMediaBorderButton(main.displayPanel, 120)
borderCombobox:SetPoint("LEFT", borderText, "RIGHT", 3, 0)
borderCombobox:ddSetOnSelectedFunc(function(value)
	if value == "None" then value = false end
	main.barFrame:setBorder(value)
	main:hidingBarUpdate()
end)

-- BORDER COLOR
local borderColor = CreateFrame("BUTTON", nil, main.displayPanel, "HidingBarAddonColorButton")
borderColor:SetPoint("LEFT", borderCombobox, "RIGHT", 3, 2)

borderColor:SetScript("OnClick", function()
	showColorPicker(main.bConfig.borderColor, function(...)
		main.barFrame:setBorder(nil, nil, ...)
		borderColor.color:SetColorTexture(unpack(main.bConfig.borderColor))
		main:hidingBarUpdate()
	end)
end)

-- BORDER OFFSET
local borderOffset = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonSliderFrameTemplate")
borderOffset:SetPoint("LEFT", borderColor, "RIGHT", 10, 2.5)
borderOffset:SetPoint("RIGHT", -10, 0)
borderOffset:setMinMax(0, 32)
borderOffset:setText(L["Border Offset"])
borderOffset:setMaxLetters(2)
borderOffset:setOnChanged(function(frame, value)
	main.barFrame:setBorderOffset(value)
	main:hidingBarUpdate(true)
end)

-- BORDER SIZE
local borderSize = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonSliderFrameTemplate")
borderSize:SetPoint("TOPLEFT", borderText, "BOTTOMLEFT", 0, 12 - margin)
borderSize:SetPoint("RIGHT", -10, 0)
borderSize:setMinMax(1, 64)
borderSize:setText(L["Border Size"])
borderSize:setMaxLetters(2)
borderSize:setOnChanged(function(frame, value)
	main.barFrame:setBorder(nil, value)
	main:hidingBarUpdate()
end)

-- LINE TEXT
local lineText = main.displayPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
lineText:SetPoint("TOPLEFT", borderSize, "BOTTOMLEFT", 0, -margin)
lineText:SetText(L["Line"])

-- LINE TEXTURE COMBOBOX
local lineTextureCombobox = ddCreateMediaStatusbarButton(main.displayPanel, 120)
lineTextureCombobox:SetPoint("LEFT", lineText, "RIGHT", 3, 0)
lineTextureCombobox:ddSetOnSelectedFunc(function(value)
	main.barFrame:setLineTexture(value)
end)

-- LINE COLOR
main.lineColor = CreateFrame("BUTTON", nil, main.displayPanel, "HidingBarAddonColorButton")
main.lineColor:SetPoint("LEFT", lineTextureCombobox, "RIGHT", 3, 2)

main.lineColor.updateLineColor = function()
	local hexColor = toHex(main.bConfig.lineColor)
	main.helpPlate.tooltipTitle = L["SETTINGS_DESCRIPTION"]:format(hexColor)
	if main.bConfig.showHandler == 3 then
		main.fade.Text:SetText(L["Fade out bar"])
	else
		main.fade.Text:SetText(L["Fade out line"]:format(hexColor))
	end
	main.lineWidth:setText(L["Line width"]:format(hexColor))
	main.lineBorderOffset:setText(L["Line Border Offset"]:format(hexColor))
	main.lineBorderSize:setText(L["Line Border Size"]:format(hexColor))
	main.gapSize:setText(L["Distance from line to bar"]:format(hexColor))
	main.lineColor.color:SetColorTexture(unpack(main.bConfig.lineColor))
end

main.lineColor:SetScript("OnClick", function()
	showColorPicker(main.bConfig.lineColor, function(...)
		main.barFrame:setLineTexture(nil, ...)
		main.lineColor.updateLineColor()
		main:hidingBarUpdate()
	end)
end)

-- LINE WIDTH
main.lineWidth = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonSliderFrameTemplate")
main.lineWidth:SetPoint("LEFT", main.lineColor, "RIGHT", 10, 2.5)
main.lineWidth:SetPoint("RIGHT", -10, 0)
main.lineWidth:setMinMax(4, 20)
main.lineWidth:setMaxLetters(2)
main.lineWidth:setOnChanged(function(frame, value)
	main.barFrame:setLineWidth(value)
end)

-- LINE BORDER TEXT
local lineBorderText = main.displayPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
lineBorderText:SetPoint("TOPLEFT", lineText, "BOTTOMLEFT", 0, -margin)
lineBorderText:SetText(L["Line Border"])

-- BORDER COMBOBOX
local lineBorderCombobox = ddCreateMediaBorderButton(main.displayPanel, 120)
lineBorderCombobox:SetPoint("LEFT", lineBorderText, "RIGHT", 3, 0)
lineBorderCombobox:ddSetOnSelectedFunc(function(value)
	if value == "None" then value = false end
	main.barFrame:setLineBorder(value)
	main:hidingBarUpdate()
end)

-- LINE BORDER COLOR
local lineBorderColor = CreateFrame("BUTTON", nil, main.displayPanel, "HidingBarAddonColorButton")
lineBorderColor:SetPoint("LEFT", lineBorderCombobox, "RIGHT", 3, 2)

lineBorderColor:SetScript("OnClick", function()
	showColorPicker(main.bConfig.lineBorderColor, function(...)
		main.barFrame:setLineBorder(nil, nil, ...)
		lineBorderColor.color:SetColorTexture(unpack(main.bConfig.lineBorderColor))
		main:hidingBarUpdate()
	end)
end)

-- LINE BORDER OFFSET
main.lineBorderOffset = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonSliderFrameTemplate")
main.lineBorderOffset:SetPoint("LEFT", lineBorderColor, "RIGHT", 10, 2.5)
main.lineBorderOffset:SetPoint("RIGHT", -10, 0)
main.lineBorderOffset:setMinMax(0, 32)
main.lineBorderOffset:setMaxLetters(2)
main.lineBorderOffset:setOnChanged(function(frame, value)
	main.barFrame:setLineBorderOffset(value)
	main:hidingBarUpdate()
end)

-- BORDER SIZE
main.lineBorderSize = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonSliderFrameTemplate")
main.lineBorderSize:SetPoint("TOPLEFT", lineBorderText, "BOTTOMLEFT", 0, 12 - margin)
main.lineBorderSize:SetPoint("RIGHT", -10, 0)
main.lineBorderSize:setMinMax(1, 64)
main.lineBorderSize:setMaxLetters(2)
main.lineBorderSize:setOnChanged(function(frame, value)
	main.barFrame:setLineBorder(nil, value)
	main:hidingBarUpdate()
end)

-- DISTANCE FROM LINE TO BAR
main.gapSize = CreateFrame("FRAME", nil, main.displayPanel, "HidingBarAddonSliderFrameTemplate")
main.gapSize:SetPoint("TOPLEFT", main.lineBorderSize, "BOTTOMLEFT", 0, 18 - margin)
main.gapSize:SetPoint("RIGHT", -10, 0)
main.gapSize:setMinMax(-8, 64)
main.gapSize:setMaxLetters(2)
main.gapSize:setOnChanged(function(frame, value)
	main.barFrame:setGapPosition(value)
	main:hidingBarUpdate()
end)

-- ALIGN
alignText(borderText, bgText, lineText, lineBorderText)

-------------------------------------------
-- BUTTON SETTINGS TAB PANEL
-------------------------------------------
main.buttonSettingsPanel =  createTabPanel(barSettingsTabs, L["Button settings"])

-- SLIDER NUMBER BUTTONS IN ROW
local buttonNumber = CreateFrame("FRAME", nil, main.buttonSettingsPanel, "HidingBarAddonSliderFrameTemplate")
buttonNumber:SetPoint("TOPLEFT", 8, -8)
buttonNumber:SetPoint("RIGHT", -10, 0)
buttonNumber:setMinMax(1, 30)
buttonNumber:setText(L["Number of buttons"])
buttonNumber:setMaxLetters(2)
buttonNumber:setOnChanged(function(slider, value)
	if main.bConfig.size ~= value then
		main.barFrame:setMaxButtons(value)
		main:applyLayout(.3)
		main:hidingBarUpdate()
	end
end)

-- SLIDER BUTTONS SIZE
local buttonSize = CreateFrame("FRAME", nil, main.buttonSettingsPanel, "HidingBarAddonSliderFrameTemplate")
buttonSize:SetPoint("TOPLEFT", buttonNumber, "BOTTOMLEFT", 0, 18 - margin)
buttonSize:SetPoint("RIGHT", -10, 0)
buttonSize:setMinMax(16, 64)
buttonSize:setText(L["Buttons Size"])
buttonSize:setMaxLetters(2)
buttonSize:setOnChanged(function(frame, value)
	if main.bConfig.buttonSize ~= value then
		main.barFrame:setButtonSize(value)
		main:setButtonSize()
		main:applyLayout()
		main:hidingBarUpdate()
	end
end)

-- SLIDER DISTANCE TO BAR BORDER
local barOffset =  CreateFrame("FRAME", nil, main.buttonSettingsPanel, "HidingBarAddonSliderFrameTemplate")
barOffset:SetPoint("TOPLEFT", buttonSize, "BOTTOMLEFT", 0, 18 - margin)
barOffset:SetPoint("RIGHT", -10, 0)
barOffset:setMinMax(0, 20)
barOffset:setText(L["Distance to bar border"])
barOffset:setMaxLetters(2)
barOffset:setOnChanged(function(frame, value)
	if main.bConfig.barOffset ~= value then
		main.barFrame:setBarOffset(value)
		main:applyLayout()
		main:hidingBarUpdate()
	end
end)

-- SLIDER DISTANCE BETWEEN BUTTONS
local rangeBetweenBtns = CreateFrame("FRAME", nil, main.buttonSettingsPanel, "HidingBarAddonSliderFrameTemplate")
rangeBetweenBtns:SetPoint("TOPLEFT", barOffset, "BOTTOMLEFT", 0, 18 - margin)
rangeBetweenBtns:SetPoint("RIGHT", -10, 0)
rangeBetweenBtns:setMinMax(-5, 30)
rangeBetweenBtns:setText(L["Distance between buttons"])
rangeBetweenBtns:setMaxLetters(2)
rangeBetweenBtns:setOnChanged(function(frame, value)
	if main.bConfig.rangeBetweenBtns ~= value then
		main.barFrame:setRangeBetweenBtns(value)
		main:applyLayout()
		main:hidingBarUpdate()
	end
end)

-- POSTION OF MINIMAP BUTTON TEXT
local mbtnPostionText = main.buttonSettingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
mbtnPostionText:SetPoint("TOPLEFT", rangeBetweenBtns, "BOTTOMLEFT", 0, -margin)
mbtnPostionText:SetText(L["Position of minimap buttons"])

-- POSITION OF MINIMAP BUTTON
local mbtnPostionCombobox = ddCreateButton(main.buttonSettingsPanel, 120)
mbtnPostionCombobox:SetPoint("LEFT", mbtnPostionText, "RIGHT", 3, 0)
mbtnPostionCombobox.texts = {[0] = L["A new line"], L["Followed"], L["Mixed"]}

local function updateMBtnPostion(btn)
	mbtnPostionCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setMBtnPosition(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

mbtnPostionCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateMBtnPostion
		self:ddAddButton(info)
	end
end)

-- DIRECTION OF BUTTONS
local buttonDirection = ddCreateStretchButton(main.buttonSettingsPanel, 150, 22)
buttonDirection:SetPoint("LEFT", mbtnPostionCombobox, "RIGHT", 10, 1)
buttonDirection:SetText(L["Direction of buttons"])

buttonDirection:ddSetInitFunc(function(self, level)
	local info = {}

	local function setDirection(btn, ...)
		main.barFrame:setButtonDirection(...)
		main:applyLayout(.3)
		main:hidingBarUpdate(true)
		self:ddRefresh()
	end

	info.keepShownOnClick = true
	info.isTitle = true
	info.notCheckable = true
	info.text = L["Horizontal"]
	self:ddAddButton(info)

	info.isTitle = nil
	info.notCheckable = nil

	for i, text in ipairs({L["Auto"], L["Left to right"], L["Right to left"]}) do
		i = i - 1
		info.text = text
		info.arg1 = "H"
		info.arg2 = i
		info.checked = function() return main.bConfig.buttonDirection.H == i end
		info.func = setDirection
		self:ddAddButton(info)
	end

	self:ddAddSpace()

	info.checked = nil
	info.func = nil
	info.isTitle = true
	info.notCheckable = true
	info.text = L["Vertical"]
	self:ddAddButton(info)

	info.isTitle = nil
	info.notCheckable = nil

	for i, text in ipairs({L["Auto"], L["Top to bottom"], L["Bottom to top"]}) do
		i = i - 1
		info.text = text
		info.arg1 = "V"
		info.arg2 = i
		info.checked = function() return main.bConfig.buttonDirection.V == i end
		info.func = setDirection
		self:ddAddButton(info)
	end
end)

-- INTERCEPT THE POSITION OF TOOLTIPS
local interceptTooltip = CreateFrame("CheckButton", nil, main.buttonSettingsPanel, "HidingBarAddonCheckButtonTemplate")
interceptTooltip:SetPoint("TOPLEFT", mbtnPostionText, "BOTTOMLEFT", 0, -13)
interceptTooltip.Text:SetText(L["Intercept the position of tooltips"])
interceptTooltip:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.bConfig.interceptTooltip = checked
	main.tooltipPositionCombobox:SetEnabled(checked)
end)

-- TOOLTIP POSITION
main.tooltipPositionCombobox = ddCreateButton(main.buttonSettingsPanel, 120)
main.tooltipPositionCombobox:SetPoint("LEFT", interceptTooltip.Text, "RIGHT", 3, 0)
main.tooltipPositionCombobox.texts = {
	[0] = L["Auto"],
	L["Top"],
	L["Top left"],
	L["Top right"],
	L["Bottom"],
	L["Bottom left"],
	L["Bottom right"],
	L["Left"],
	L["Left top"],
	L["Left bottom"],
	L["Right"],
	L["Right top"],
	L["Right bottom"],
}

local function updateTooltipPostion(btn)
	main.tooltipPositionCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setTooltipPosition(btn.value)
end

main.tooltipPositionCombobox:ddSetInitFunc(function(self)
	local info = {}
	for i = 0, #self.texts do
		info.text = self.texts[i]
		info.value = i
		info.func = updateTooltipPostion
		self:ddAddButton(info)
	end
end)

-------------------------------------------
-- POSITION BAR PANEL
-------------------------------------------
main.positionBarPanel = createTabPanel(barSettingsTabs, L["Bar position"])

local function updateBarTypePosition()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	main.attachedToSide.check:SetShown(main.bConfig.barTypePosition == 0)
	main.freeMove.check:SetShown(main.bConfig.barTypePosition == 1)
	main.hideToCombobox:SetEnabled(main.bConfig.barTypePosition == 1)
	main.coordX:SetEnabled(main.bConfig.barTypePosition == 1)
	main.coordY:SetEnabled(main.bConfig.barTypePosition == 1)
	main.likeMB.check:SetShown(main.bConfig.barTypePosition == 2)
	main.ombIcon:SetEnabled(main.bConfig.barTypePosition == 2)
	main.ombIconCustom:SetEnabled(main.bConfig.barTypePosition == 2)
	main.ombShowToCombobox:SetEnabled(main.bConfig.barTypePosition == 2)
	main.ombSize:setEnabled(main.bConfig.barTypePosition == 2 and not main.bConfig.omb.canGrabbed)
	main.distanceFromButtonToBar:setEnabled(main.bConfig.barTypePosition == 2)
	main.ombBarDisplacement:setEnabled(main.bConfig.barTypePosition == 2)
	main.canGrabbed:SetEnabled(main.bConfig.barTypePosition == 2)
	main.buttonHide:SetEnabled(main.bConfig.barTypePosition == 2 and not main.bConfig.omb.canGrabbed)
	main.ombFade:setEnabled(main.bConfig.barTypePosition == 2 and not main.bConfig.omb.canGrabbed)
end

-- BAR ATTACHED TO THE SIDE
main.attachedToSide = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.attachedToSide:SetPoint("TOPLEFT", 8, -8)
main.attachedToSide.Text:SetText(L["Bar attached to the side"])
main.attachedToSide:SetScript("OnClick", function()
	main.barFrame:setBarCoords(nil, 0)
	main.barFrame:setBarTypePosition(0)
	main:applyLayout(.3)
	if main.barFrame.omb then
		if main.barFrame.omb.isGrabbed then
			for i, btn in ipairs(main.mbuttons) do
				if btn.rButton == main.barFrame.omb then
					main:removeMButton(btn, i)
					break
				end
			end
		end
		if main.bConfig.omb.canGrabbed then
			main:removeOmbGrabQueue(main.barFrame.id)
		end
	end
	hb:updateBars()
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- BAR MOVES FREELY
main.freeMove = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.freeMove:SetPoint("TOPLEFT", main.attachedToSide, "BOTTOMLEFT")
main.freeMove.Text:SetText(L["Bar moves freely"])
main.freeMove:SetScript("OnClick", function()
	main.barFrame:setBarTypePosition(1)
	main:applyLayout(.3)
	if main.barFrame.omb then
		if main.barFrame.omb.isGrabbed then
			for i, btn in ipairs(main.mbuttons) do
				if btn.rButton == main.barFrame.omb then
					main:removeMButton(btn, i)
					break
				end
			end
		end
		if main.bConfig.omb.canGrabbed then
			main:removeOmbGrabQueue(main.barFrame.id)
		end
	end
	hb:updateBars()
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- HIDE TO
main.hideToCombobox = ddCreateButton(main.positionBarPanel, 120)
main.hideToCombobox:SetPoint("TOPLEFT", main.freeMove, "BOTTOMLEFT", 23, -3)
main.hideToCombobox.texts = {
	left = L["Hiding to left"],
	right = L["Hiding to right"],
	top = L["Hiding to up"],
	bottom = L["Hiding to down"],
}

local function updateBarAnchor(btn)
	main.hideToCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setBarAnchor(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

main.hideToCombobox:ddSetInitFunc(function(self)
	local info = {}
	for _, value in ipairs({"left", "right", "top", "bottom"}) do
		info.text = self.texts[value]
		info.value = value
		info.func = updateBarAnchor
		self:ddAddButton(info)
	end
end)
hb:on("ANCHOR_UPDATED", function(_, value, bar)
	if main.barFrame == bar then
		main.hideToCombobox:ddSetSelectedValue(value)
		main.hideToCombobox:ddSetSelectedText(main.hideToCombobox.texts[value])
		main:applyLayout(.3)
	end
end)

-- COORD X
main.coordXText = main.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.coordXText:SetPoint("LEFT", main.hideToCombobox, "RIGHT", 10, 1)
main.coordXText:SetText("X")

main.coordX = CreateFrame("EditBox", nil, main.positionBarPanel, "HidingBarAddonCoordTextBox")
main.coordX:SetPoint("LEFT", main.coordXText, "RIGHT", 1, 0)
main.coordX:setOnChanged(function(editBox, x)
	if main.bConfig.anchor == "left" or main.bConfig.anchor == "right" then
		main.barFrame:setBarCoords(nil, x)
	else
		main.barFrame:setBarCoords(x)
	end
	main.barFrame:updateBarPosition()
end)

-- COORD Y
main.coordYText = main.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.coordYText:SetPoint("LEFT", main.coordX, "RIGHT", 5, 0)
main.coordYText:SetText("Y")

main.coordY = CreateFrame("EditBox", nil, main.positionBarPanel, "HidingBarAddonCoordTextBox")
main.coordY:SetPoint("LEFT", main.coordYText, "RIGHT", 1, 0)
main.coordY:setOnChanged(function(editBox, y)
	if main.bConfig.anchor == "left" or main.bConfig.anchor == "right" then
		main.barFrame:setBarCoords(y)
	else
		main.barFrame:setBarCoords(nil, y)
	end
	main.barFrame:updateBarPosition()
end)

-- BAR LIKE MINIMAP BUTTON
main.likeMB = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonRadioButtonTemplate")
main.likeMB:SetPoint("TOPLEFT", main.hideToCombobox, "BOTTOMLEFT", -23, -4)
main.likeMB.Text:SetText(L["Bar like a minimap button"])
main.likeMB:SetScript("OnClick", function()
	main.barFrame:setBarTypePosition(2)
	main.barFrame:setGapPosition()
	main:applyLayout(.3)
	if main.bConfig.omb.canGrabbed and not main.barFrame.omb.isGrabbed then
		main:addOmbGrabQueue(main.barFrame.id)
		if hb:grabOwnButton(main.barFrame.omb) then
			hb:sort()
			main.barFrame.omb:GetParent():setButtonSize()
		end
	end
	updateBarTypePosition()
	main:hidingBarUpdate()
end)

-- MINIMAP BUTTON ICON
main.ombIcon = CreateFrame("BUTTON", nil, main.positionBarPanel, "HidingBarAddonIconButtonTemplate")
main.ombIcon:SetPoint("TOPLEFT", main.likeMB, "BOTTOMLEFT", 24, -3)
main.ombIcon.icon:SetTexture(hb.ombDefIcon)
main.ombIcon:SetScript("OnClick", function(btn)
	main.iconData:init(btn, function()
		local icon = btn.icon:GetTexture()
		if icon == main.defIcon then icon = nil end
		main.bConfig.omb.icon = icon
		main.ombIconCustom:SetText(icon or "")
		main.barFrame:setBarTypePosition()
		main:hidingBarUpdate()
	end)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end)

-- MINIMAP BUTTON ICON CUSTOM TEXT
main.ombIconCustomText = main.positionBarPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
main.ombIconCustomText:SetPoint("BOTTOMLEFT", main.ombIcon, "BOTTOMRIGHT", 10, 4)
main.ombIconCustomText:SetText(L["Icon"])

-- MINIMAP BUTTON ICON CUSTOM
main.ombIconCustom = CreateFrame("EditBox", nil, main.positionBarPanel, "InputBoxTemplate")
main.ombIconCustom:SetPoint("LEFT", main.ombIconCustomText, "RIGHT", 5, 0)
main.ombIconCustom:SetPoint("RIGHT", -10 , 0)
main.ombIconCustom:SetHeight(20)
main.ombIconCustom:SetAutoFocus(false)
main.ombIconCustom.bgText = main.ombIconCustom:CreateFontString(nil, "BACKGROUND", "GameFontDisable")
main.ombIconCustom.bgText:SetPoint("LEFT", 0, 0)
main.ombIconCustom.bgText:SetText(hb.ombDefIcon)
main.ombIconCustom:SetScript("OnEscapePressed", EditBox_ClearFocus)
main.ombIconCustom:SetScript("OnEnterPressed", EditBox_ClearFocus)
main.ombIconCustom:SetScript("OnEditFocusLost", function(editBox)
	local text = editBox:GetText():trim()
	editBox:SetText(text)
	if text == "" then
		main.bConfig.omb.icon = nil
	else
		main.bConfig.omb.icon = text
	end
	main.ombIcon.icon:SetTexture(main.bConfig.omb.icon or hb.ombDefIcon)
	main.barFrame:setBarTypePosition()
	main:hidingBarUpdate()
end)
main.ombIconCustom:SetScript("OnTextChanged", function(editBox)
	local text = editBox:GetText()
	editBox.bgText:SetShown(text == "")
end)
main.ombIconCustom:SetScript("OnDisable", function(editBox)
	editBox:SetTextColor(GRAY_FONT_COLOR:GetRGB())
end)
main.ombIconCustom:SetScript("OnEnable", function(editBox)
	editBox:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
end)

-- MINIMAP BUTTON SHOW TO
main.ombShowToCombobox = ddCreateButton(main.positionBarPanel, 120)
main.ombShowToCombobox:SetPoint("TOPLEFT", main.ombIcon, "BOTTOMLEFT", -1, -10)
main.ombShowToCombobox.texts = {
	right = L["Show to left"],
	left = L["Show to right"],
	bottom = L["Show to up"],
	top = L["Show to down"],
}

local function mbShowToChange(btn)
	main.ombShowToCombobox:ddSetSelectedValue(btn.value)
	main.barFrame:setOMBAnchor(btn.value)
	main:applyLayout(.3)
	main:hidingBarUpdate()
end

main.ombShowToCombobox:ddSetInitFunc(function(self)
	local info = {}
	for _, value in ipairs({"right", "left", "bottom", "top"}) do
		info.text = self.texts[value]
		info.value = value
		info.func = mbShowToChange
		self:ddAddButton(info)
	end
end)

-- SLIDER MINIMAP BUTTON SIZE
main.ombSize = CreateFrame("FRAME", nil, main.positionBarPanel, "HidingBarAddonSliderFrameTemplate")
main.ombSize:SetPoint("LEFT", main.ombShowToCombobox, "RIGHT", 10, 5)
main.ombSize:SetPoint("RIGHT", -10, 0)
main.ombSize:setMinMax(16, 64)
main.ombSize:setText(L["Button Size"])
main.ombSize:setMaxLetters(2)
main.ombSize:setOnChanged(function(frame, value)
	if main.bConfig.omb.size ~= value then
		main.barFrame:setOMBSize(value)
		main.barFrame:setBarTypePosition()
	end
end)

-- SLIDER DISTANCE FROM BUTTON TO BAR
main.distanceFromButtonToBar = CreateFrame("FRAME", nil, main.positionBarPanel, "HidingBarAddonSliderFrameTemplate")
main.distanceFromButtonToBar:SetPoint("TOPLEFT", main.ombShowToCombobox, "BOTTOMLEFT", 0, 0)
main.distanceFromButtonToBar:SetWidth(280)
main.distanceFromButtonToBar:setMinMax(-32, 32)
main.distanceFromButtonToBar:setText(L["Distance from button to bar"])
main.distanceFromButtonToBar:setMaxLetters(3)
main.distanceFromButtonToBar.noLimit = true
main.distanceFromButtonToBar:setOnChanged(function(frame, value)
	if main.bConfig.omb.distanceToBar ~= value then
		main.bConfig.omb.distanceToBar = value
		main.barFrame:setBarTypePosition()
		main:hidingBarUpdate()
	end
end)

-- SLIDER MINIMAP BUTTON DISPLACEMENT
main.ombBarDisplacement = CreateFrame("FRAME", nil, main.positionBarPanel, "HidingBarAddonSliderFrameTemplate")
main.ombBarDisplacement:SetPoint("LEFT", main.distanceFromButtonToBar, "RIGHT", 6, 0)
main.ombBarDisplacement:SetWidth(280)
main.ombBarDisplacement:setMinMax(-32, 32)
main.ombBarDisplacement:setText(L["Bar offset relative to the button"])
main.ombBarDisplacement:setMaxLetters(3)
main.ombBarDisplacement.noLimit = true
main.ombBarDisplacement:setOnChanged(function(frame, value)
	if main.bConfig.omb.barDisplacement ~= value then
		main.bConfig.omb.barDisplacement = value
		main.barFrame:setBarTypePosition()
		main:hidingBarUpdate()
	end
end)

-- THE BUTTON CAN BE GRABBED
main.canGrabbed = CreateFrame("CheckButton", nil, main.positionBarPanel, "HidingBarAddonCheckButtonTemplate")
main.canGrabbed:SetPoint("TOPLEFT", main.distanceFromButtonToBar, "BOTTOMLEFT", -2, -8)
main.canGrabbed.Text:SetText(L["The button can be grabbed"])
main.canGrabbed.tooltipText = L["If a suitable bar exists then the button will be grabbed"]
main.canGrabbed:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.ombSize:setEnabled(not checked)
	main.buttonHide:SetEnabled(not checked)
	main.ombFade:setEnabled(not checked)

	local omb = main.barFrame.omb
	main.bConfig.omb.canGrabbed = checked
	if checked then
		main:addOmbGrabQueue(main.barFrame.id)
		if hb:grabOwnButton(omb) then
			hb:sort()
			omb:GetParent():setButtonSize()
		end
	else
		main:removeOmbGrabQueue(main.barFrame.id)
		for i, btn in ipairs(main.mbuttons) do
			if btn.rButton == omb then
				main:removeMButton(btn, i)
				break
			end
		end
		hb:updateBars()
	end
	main:hidingBarUpdate()
end)


-- THE BUTTON HIDE
main.buttonHide = CreateFrame("CheckButton", nil, main.positionBarPanel, "HidingBarAddonCheckButtonTemplate")
main.buttonHide:SetPoint("LEFT", main.canGrabbed.Text, "RIGHT", 6, 0)
main.buttonHide.Text:SetText(HIDE)
main.buttonHide:SetScript("OnClick", function(btn)
	local checked = btn:GetChecked()
	PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	main.bConfig.ombHide = checked
	main.barFrame:setBarTypePosition()
end)


-- THE BUTTON FADE
main.ombFade = CreateFrame("FRAME", nil, main.positionBarPanel, "HidingBarAddonSliderFrameTemplate")
main.ombFade:SetPoint("LEFT", main.buttonHide.Text, "RIGHT", 20, 5)
main.ombFade:SetPoint("RIGHT", -10, 0)
main.ombFade:setMinMax(0, 1)
main.ombFade:setStep(.05)
main.ombFade:setText(L["Opacity"])
main.ombFade:setMaxLetters(4)
main.ombFade:setOnChanged(function(frame, value)
	main.barFrame:setOMBFade(value)
end)


-- CONTEXT MENU
local contextmenu = lsfdd:SetMixin({})
contextmenu:ddSetDisplayMode("menu")
contextmenu:ddHideWhenButtonHidden(main.buttonPanel)

contextmenu:ddSetInitFunc(function(self, level, btn)
	local info = {}

	if level == 1 then
		info.notCheckable = true
		info.keepShownOnClick = true
		info.hasArrow = true
		info.text = L["Move to"]
		info.value = btn
		self:ddAddButton(info, level)

		info.notCheckable = nil
		info.isNotRadio = true
		info.hasArrow = nil
		info.text = DISABLE
		info.checked = btn.settings[1]
		info.func = function()
			btn.settings[1] = not btn.settings[1]
			btn:SetChecked(btn.settings[1])
			main:hidingBarUpdate(true)
		end
		self:ddAddButton(info, level)

		info.text = L["Clip button"]
		info.checked = btn.settings[4]
		info.func = function(_,_,_, checked)
			btn.settings[4] = checked and true or nil
			hb:setClipButtons()
		end
		info.OnTooltipShow = function(_, tooltip)
			tooltip:AddLine(L["Prevents button elements from going over the edges."], nil, nil, nil, true)
		end
		self:ddAddButton(info, level)

		if btn.toIgnore or btn.manually then
			info.tooltipWhileDisabled = true
			info.disabled = hb.btnParams[btn.rButton].autoShowHideDisabled
			info.text = L["Auto show/hide"]
			info.checked = btn.settings[5]
			info.func = function(_,_,_, checked)
				btn.settings[5] = checked
				main:hidingBarUpdate(true)
			end
			info.OnTooltipShow = function(_, tooltip)
				tooltip:AddLine(L["Allow the button to control its own visibility"], nil, nil, nil, true)
			end
			self:ddAddButton(info, level)

			info.tooltipWhileDisabled = nil
			info.disabled = nil
		end

		info.OnTooltipShow = nil

		if LibStub("Masque", true) and not btn.name:match(hb.matchName) then
			info.text = L["Disable Masque"]
			info.checked = btn.settings[6]
			info.func = function(_,_,_, checked)
				btn.settings[6] = checked and true or nil
				StaticPopup_Show(main.addonName.."GET_RELOAD")
			end
			self:ddAddButton(info, level)
		end

		info.notCheckable = true
		info.keepShownOnClick = nil
		info.checked = nil

		if btn.toIgnore then
			info.text = L["Add to ignore list"]
			info.func = function()
				StaticPopup_Show(main.addonName.."ADD_IGNORE_MBTN", NORMAL_FONT_COLOR:WrapTextInColorCode(btn.name), nil, function()
					main:addIgnoreName(btn.name)
				end)
			end
			self:ddAddButton(info, level)
		end

		info.text = CANCEL
		info.func = function() self:ddCloseMenus() end
		self:ddAddButton(info, level)
	else
		info.list = {}

		local function moveTo(menu)
			local bar = menu.value
			if bar.isDefault then
				btn.settings[3] = nil
			else
				btn.settings[3] = bar.name
			end
			hb:updateBars()
			main:hidingBarUpdate()
			main:setBar(main.currentBar)
		end

		for i, bar in ipairs(main.pBars) do
			if bar ~= main.currentBar
			and not (btn.name:match(hb.matchName)
				and hb:isBarParent(btn.rButton, hb.barByName[bar.name]))
			then
				tinsert(info.list, {
					notCheckable = true,
					text = bar.name,
					value = bar,
					func = moveTo
				})
			end
		end

		if #info.list == 0 then
			info.list[1] = {
				notCheckable = true,
				disabled = true,
				text = EMPTY,
			}
		end

		self:ddAddButton(info, level)
	end
end)


-- METHODS
local function copyTable(t)
	local n = {}
	for k, v in pairs(t) do
		n[k] = type(v) == "table" and copyTable(v) or v
	end
	return n
end


function main:createProfile(copy)
	local dialog = StaticPopup_Show(self.addonName.."NEW_PROFILE", nil, nil, function(popup)
		local text = (popup.EditBox or popup.editBox):GetText()
		popup:Hide()
		if text and text ~= "" then
			for _, profile in ipairs(hb.profiles) do
				if profile.name == text then
					self.lastProfileName = text
					self.profilePopupAction = self.createProfile
					StaticPopup_Show(self.addonName.."PROFILE_EXISTS", nil, nil, copy)
					return
				end
			end
			local profile = copy and copyTable(self.currentProfile) or {}
			profile.name = text
			profile.isDefault = nil
			hb:checkProfile(profile)
			tinsert(hb.profiles, profile)
			sort(hb.profiles, function(a, b) return strcmputf8i(a.name, b.name) < 0 end)
			hb:setProfile(text)
			self:setProfile()
			self:hidingBarUpdate()
		end
	end)
	if dialog and self.lastProfileName then
		local editBox = dialog.EditBox or dialog.editBox
		editBox:SetText(self.lastProfileName)
		editBox:HighlightText()
	end
end


function main:editProfile(profileName)
	local dialog = StaticPopup_Show(self.addonName.."EDIT_PROFILE", nil, nil, function(popup)
		local text = (popup.EditBox or popup.editBox):GetText()
		popup:Hide()
		if text and text ~= profileName and text ~= "" then
			local editProfile
			for _, profile in ipairs(hb.profiles) do
				if profile.name == text then
					self.lastProfileName = text
					self.profilePopupAction = self.editProfile
					StaticPopup_Show(self.addonName.."PROFILE_EXISTS", nil, nil, profileName)
					return
				elseif profile.name == profileName then
					editProfile = profile
				end
			end
			if editProfile then
				editProfile.name = text
				sort(hb.profiles,  function(a, b) return strcmputf8i(a.name, b.name) < 0 end)
				hb:setProfile(text)
				profilesCombobox:SetText(self.currentProfile.name)
			end
		end
	end)
	if dialog then
		local editBox = dialog.EditBox or dialog.editBox
		editBox:SetText(self.lastProfileName or profileName)
		editBox:HighlightText()
	end
end


function main:removeProfile(profileName)
	StaticPopup_Show(self.addonName.."DELETE_PROFILE", NORMAL_FONT_COLOR:WrapTextInColorCode(profileName), nil, function()
		for i, profile in ipairs(hb.profiles) do
			if profile.name == profileName then
				tremove(hb.profiles, i)
				if profile.isDefault then
					hb.profiles[1].isDefault = true
				end
				break
			end
		end
		if self.currentProfile.name == profileName then
			hb:setProfile()
			self:setProfile()
		end
	end)
end


function main:setProfile()
	local currentProfileName, currentProfile, default = hb.charDB.currentProfileName

	for _, profile in ipairs(hb.profiles) do
		if profile.name == currentProfileName then
			currentProfile = profile
			break
		end
		if profile.isDefault then
			default = profile
		end
	end
	currentProfile = currentProfile or default

	if self.currentProfile then
		if self.pConfig.addFromDataBroker ~= currentProfile.config.addFromDataBroker
		or self.pConfig.addFromDataBroker and
			not self.pConfig.addAnyTypeFromDataBroker ~= not currentProfile.config.addAnyTypeFromDataBroker
		or (self.pConfig.grabMinimap or currentProfile.config.grabMinimap) and
			(not self.pConfig.grabMinimapWithoutName ~= not currentProfile.config.grabMinimapWithoutName
			or not self.pConfig.grabMinimapAfter ~= not currentProfile.config.grabMinimapAfter
			or self.pConfig.grabMinimapAfter and self.pConfig.grabMinimapAfterN ~= currentProfile.config.grabMinimapAfterN)
		or LibStub("Masque", true)
		then
			StaticPopup_Show(self.addonName.."GET_RELOAD")
		end

		self:removeAllMButtonsWithoutOMB()
		hb:addButtons()
	end

	self.currentProfile = currentProfile
	self.pConfig = self.currentProfile.config
	self.pBars = self.currentProfile.bars
	profilesCombobox:SetText(self.currentProfile.name)

	for _, btn in ipairs(self.buttons) do
		btn.settings = self.pConfig.btnSettings[btn.title]
	end

	local i = 1
	local btn = self.mbuttons[i]
	while btn do
		if btn.name:match(hb.matchName) and not btn.rButton.isGrabbed then
			self:removeMButton(btn, i)
		else
			btn.settings = self.pConfig.mbtnSettings[btn.name]
			i = i + 1
		end
		btn = self.mbuttons[i]
	end

	self.ignoreScroll:update()
	self.addBtnFromDataBroker:SetChecked(self.pConfig.addFromDataBroker)
	self.addAnyTypeFromDataBroker:SetEnabled(self.pConfig.addFromDataBroker)
	self.addAnyTypeFromDataBroker:SetChecked(self.pConfig.addAnyTypeFromDataBroker)
	self.grabDefault:SetChecked(self.pConfig.grabDefMinimap)
	self.grab:SetChecked(self.pConfig.grabMinimap)
	self.grabAfter:SetChecked(self.pConfig.grabMinimapAfter)
	self.afterNumber:SetText(self.pConfig.grabMinimapAfterN)
	self.grabAfter:SetEnabled(self.pConfig.grabMinimap)
	self.grabWithoutName:SetEnabled(self.pConfig.grabMinimap)
	self.grabWithoutName:SetChecked(self.pConfig.grabMinimapWithoutName)
	self.customGrabScroll:update()

	self:sort(self.buttons)
	self:sort(self.mbuttons)
	self:sort(self.mixedButtons)
	self:setBar()
end


function main:createBar()
	local dialog = StaticPopup_Show(self.addonName.."NEW_BAR", nil, nil, function(popup)
		local text = (popup.EditBox or popup.editBox):GetText()
		popup:Hide()
		if text and text ~= "" then
			for _, bar in ipairs(self.pBars) do
				if bar.name == text then
					self.lastBarName = text
					self.barPopupAction = self.createBar
					StaticPopup_Show(self.addonName.."BAR_EXISTS")
					return
				end
			end
			local bar = {name = text}
			tinsert(self.pBars, bar)
			self:updateBarsObjects(function()
				sort(self.pBars, function(a, b) return strcmputf8i(a.name, b.name) < 0 end)
			end)
			hb:checkProfile(self.currentProfile)
			self:removeAllControlOMB()
			hb:updateBars()
			self:setBar(self.currentBar)
			self:hidingBarUpdate()
		end
	end)
	if dialog and self.lastBarName then
		local editBox = dialog.EditBox or dialog.editBox
		editBox:SetText(self.lastBarName)
		editBox:HighlightText()
	end
end


function main:editBar(barName)
	local dialog = StaticPopup_Show(self.addonName.."EDIT_PROFILE", nil, nil, function(popup)
		local text = (popup.EditBox or popup.editBox):GetText()
		if text and text ~= barName and text ~= "" then
			local editBar
			for _, bar in ipairs(self.pBars) do
				if bar.name == text then
					self.lastBarName = text
					self.barPopupAction = self.editBar
					StaticPopup_Show(self.addonName.."BAR_EXISTS", nil, nil, barName)
					return
				elseif bar.name == barName then
					editBar = bar
				end
			end
			if editBar then
				editBar.name = text
				for _, btnSettings in pairs(self.pConfig.btnSettings) do
					if btnSettings[3] == barName then
						btnSettings[3] = text
					end
				end
				for _, btnSettings in pairs(self.pConfig.mbtnSettings) do
					if btnSettings[3] == barName then
						btnSettings[3] = text
					end
				end
				self:updateBarsObjects(function()
					sort(self.pBars, function(a, b) return strcmputf8i(a.name, b.name) < 0 end)
				end)
				self:removeAllControlOMB()
				hb:updateBars()
				self:setBar(self.currentBar)
			end
		end
	end)
	if dialog then
		local editBox = dialog.EditBox or dialog.editBox
		editBox:SetText(self.lastBarName or barName)
		editBox:HighlightText()
	end
end


function main:removeBar(barName)
	StaticPopup_Show(self.addonName.."DELETE_BAR", NORMAL_FONT_COLOR:WrapTextInColorCode(barName), nil, function()
		for i, bar in ipairs(self.pBars) do
			if bar.name == barName then
				self:removeOmbGrabQueue(i)
				self:updateBarsObjects(function()
					tremove(self.pBars, i)
				end)
				if bar.isDefault then
					self.pBars[1].isDefault = true
				end
				break
			end
		end
		for _, settings in pairs(self.pConfig.btnSettings) do
			if settings[3] == barName then
				settings[3] = nil
			end
		end
		for _, settings in pairs(self.pConfig.mbtnSettings) do
			if settings[3] == barName then
				settings[3] = nil
			end
		end
		self:removeAllControlOMB()
		hb:updateBars()
		if self.currentBar.name == barName then
			self:setBar()
		else
			self:setBar(self.currentBar)
		end
		self:hidingBarUpdate()
	end)
end


function main:setBar(bar)
	if not bar then
		for _, b in ipairs(self.pBars) do
			if b.isDefault then
				bar = b
				break
			end
		end
	end

	if self.currentBar ~= bar then
		self.currentBar = bar
		self.bConfig = self.currentBar.config

		self.buttonPanel.bg:SetTexture(media:Fetch("background", self.bConfig.bgTexture), true)
		self.buttonPanel.bg:SetVertexColor(unpack(self.bConfig.bgColor))
		expandToCombobox:ddSetSelectedValue(self.bConfig.expand)
		expandToCombobox:ddSetSelectedText(expandToCombobox.texts[self.bConfig.expand])
		orientationCombobox:ddSetSelectedValue(self.bConfig.orientation)
		orientationCombobox:ddSetSelectedText(orientationCombobox.texts[self.bConfig.orientation])
		fsCombobox:ddSetSelectedValue(self.bConfig.frameStrata)
		fsCombobox:ddSetSelectedText(fsCombobox.texts[self.bConfig.frameStrata])
		lock:SetChecked(self.bConfig.lock)
		showHandlerCombobox:ddSetSelectedValue(self.bConfig.showHandler)
		showHandlerCombobox:ddSetSelectedText(showHandlerCombobox.texts[self.bConfig.showHandler])
		delayToShowEditBox:SetNumber(self.bConfig.showDelay)
		hideHandlerCombobox:ddSetSelectedValue(self.bConfig.hideHandler)
		hideHandlerCombobox:ddSetSelectedText(hideHandlerCombobox.texts[self.bConfig.hideHandler])
		delayToHideEditBox:SetNumber(self.bConfig.hideDelay)
		self.fade:SetChecked(self.bConfig.fade)
		self.fadeOpacity:setValue(self.bConfig.fadeOpacity)
		self.fadeOpacity:setEnabled(not not self.bConfig.fade)
		if self.petBattleHide then self.petBattleHide:SetChecked(self.bConfig.petBattleHide) end

		bgCombobox:ddSetSelectedValue(self.bConfig.bgTexture or "None")
		bgColor.color:SetColorTexture(unpack(self.bConfig.bgColor))
		borderCombobox:ddSetSelectedValue(self.bConfig.borderEdge or "None")
		borderColor.color:SetColorTexture(unpack(self.bConfig.borderColor))
		borderOffset:setValue(self.bConfig.borderOffset)
		borderSize:setValue(self.bConfig.borderSize)
		lineTextureCombobox:ddSetSelectedValue(self.bConfig.lineTexture)
		main.lineColor.color:SetColorTexture(unpack(self.bConfig.lineColor))
		main.lineColor.updateLineColor()
		self.lineWidth:setValue(self.bConfig.lineWidth)
		lineBorderCombobox:ddSetSelectedValue(self.bConfig.lineBorderEdge or "None")
		lineBorderColor.color:SetColorTexture(unpack(self.bConfig.lineBorderColor))
		self.lineBorderOffset:setValue(self.bConfig.lineBorderOffset)
		self.lineBorderSize:setValue(self.bConfig.lineBorderSize)
		self.gapSize:setValue(self.bConfig.gapSize)

		buttonNumber:setValue(self.bConfig.size)
		buttonSize:setValue(self.bConfig.buttonSize)
		barOffset:setValue(self.bConfig.barOffset)
		rangeBetweenBtns:setValue(self.bConfig.rangeBetweenBtns)
		mbtnPostionCombobox:ddSetSelectedValue(self.bConfig.mbtnPosition)
		mbtnPostionCombobox:ddSetSelectedText(mbtnPostionCombobox.texts[self.bConfig.mbtnPosition])
		interceptTooltip:SetChecked(self.bConfig.interceptTooltip)
		self.tooltipPositionCombobox:ddSetSelectedValue(self.bConfig.interceptTooltipPosition)
		self.tooltipPositionCombobox:ddSetSelectedText(self.tooltipPositionCombobox.texts[self.bConfig.interceptTooltipPosition])
		self.tooltipPositionCombobox:SetEnabled(self.bConfig.interceptTooltip)

		self.hideToCombobox:ddSetSelectedValue(self.bConfig.anchor)
		self.hideToCombobox:ddSetSelectedText(self.hideToCombobox.texts[self.bConfig.anchor])
		self.ombIcon.icon:SetTexture(self.bConfig.omb.icon or hb.ombDefIcon)
		self.ombIconCustom:SetText(self.bConfig.omb.icon or "")
		self.ombShowToCombobox:ddSetSelectedValue(self.bConfig.omb.anchor)
		self.ombShowToCombobox:ddSetSelectedText(self.ombShowToCombobox.texts[self.bConfig.omb.anchor])
		self.ombSize:setValue(self.bConfig.omb.size)
		self.distanceFromButtonToBar:setValue(self.bConfig.omb.distanceToBar)
		self.ombBarDisplacement:setValue(self.bConfig.omb.barDisplacement)
		self.canGrabbed:SetChecked(self.bConfig.omb.canGrabbed)
		self.buttonHide:SetChecked(self.bConfig.ombHide)
		self.ombFade:setValue(self.bConfig.omb.fadeOpacity)

		updateBarTypePosition()
	end
	barCombobox:ddSetSelectedText(self.currentBar.name)

	self.barFrame = hb.barByName[self.currentBar.name]
	self.direction = self.barFrame.direction
	self:updateCoords()

	for _, btn in ipairs(self.buttons) do
		local show = (
				btn.title == addon or self.pConfig.addFromDataBroker and (
					self.pConfig.addAnyTypeFromDataBroker or btn.rButton.data.type == "launcher"
				)
			)
			and (btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
		btn:SetShown(show)
		if show then btn:SetChecked(btn.settings[1]) end
	end

	for _, btn in ipairs(self.mbuttons) do
		local show = btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault
		btn:SetShown(show)
		if show then btn:SetChecked(btn.settings[1]) end
	end

	self:setButtonSize()
	self:applyLayout()
end


function main:updateBarsObjects(callback)
	local curQueue = {}
	for i = 1, #self.pConfig.ombGrabQueue do
		curQueue[self.pBars[self.pConfig.ombGrabQueue[i]].name] =  i
	end
	local btnSettings = {}
	for i = 1, #self.pBars do
		local ombName = hb.ldbiPrefix..addon..i
		btnSettings[self.pBars[i].name] = rawget(self.pConfig.mbtnSettings, ombName)
		self.pConfig.mbtnSettings[ombName] = nil
	end
	callback()
	for i = 1, #self.pBars do
		local queue = curQueue[self.pBars[i].name]
		if queue then
			self.pConfig.ombGrabQueue[queue] = i
		end
		self.pConfig.mbtnSettings[hb.ldbiPrefix..addon..i] = btnSettings[self.pBars[i].name]
	end
end


function main:addOmbGrabQueue(id)
	for i = 1, #self.pConfig.ombGrabQueue do
		if self.pConfig.ombGrabQueue[i] == id then
			return
		end
	end
	self.pConfig.ombGrabQueue[#self.pConfig.ombGrabQueue + 1] = id
end


function main:removeOmbGrabQueue(id)
	local i = 1
	local barID = self.pConfig.ombGrabQueue[i]
	while barID do
		if barID == id then
			tremove(self.pConfig.ombGrabQueue, i)
		else
			i = i + 1
		end
		barID = self.pConfig.ombGrabQueue[i]
	end
end


function main:updateCoords()
	if not self.barFrame then return end

	local x = self.barFrame.position or 0
	local y = self.barFrame.secondPosition or 0
	local anchor = self.bConfig.barTypePosition == 2 and self.bConfig.omb.anchor or self.bConfig.anchor
	if anchor == "left" or anchor == "right" then x, y = y, x end

	self.coordX:SetNumber(math.floor(x + .5))
	self.coordY:SetNumber(math.floor(y + .5))
end
hb:on("COORDS_UPDATED", function(_, bar)
	if main.barFrame == bar then
		main:updateCoords()
	end
end)


function main:removeAllControlOMB()
	local i = 1
	local btn = self.mbuttons[i]
	while btn do
		if btn.name:match(hb.matchName) and btn.rButton.isGrabbed then
			self:removeMButton(btn, i)
		else
			i = i + 1
		end
		btn = self.mbuttons[i]
	end
end


function main:removeAllMButtonsWithoutOMB()
	local i = 1
	local btn = self.mbuttons[i]
	while btn do
		if not btn.name:match(hb.matchName) then
			self:removeMButton(btn, i)
			hb:removeMButton(btn.rButton)
		else
			i = i + 1
		end
		btn = self.mbuttons[i]
	end

	-- remove unnamed buttons
	i = 1
	btn = hb.minimapButtons[i]
	while btn do
		if self.GetName(btn) then
			i = i + 1
		else
			hb:removeMButton(btn)
		end
		btn = hb.minimapButtons[i]
	end
end


function main:removeMButtonByName(name, update)
	for i, btn in ipairs(self.mbuttons) do
		if btn.name == name then
			self:removeMButton(btn, i, update)
			hb:removeMButton(btn.rButton, update)
			if btn.rButton.__MSQ_Enabled or btn.rButton.rButton and btn.rButton.rButton.__MSQ_Enabled then
				StaticPopup_Show(self.addonName.."GET_RELOAD")
			end
			break
		end
	end
end


function main:removeMButton(button, mIndex, update)
	tremove(self.mbuttons, mIndex)
	for i, btn in ipairs(self.mixedButtons) do
		if btn == button then
			tremove(self.mixedButtons, i)
			break
		end
	end

	button:Hide()
	self.removedButtons = self.removedButtons or {}
	self.removedButtons[button.rButton] = button

	if update then
		self:applyLayout()
	end
end


function main:restoreMbutton(rButton)
	if not (self.removedButtons and self.removedButtons[rButton]) then return end

	local btn = self.removedButtons[rButton]
	self.removedButtons[rButton] = nil
	if not next(self.removedButtons) then self.removedButtons = nil end

	tinsert(self.mbuttons, btn)
	tinsert(self.mixedButtons, btn)
	btn.settings = self.pConfig.mbtnSettings[hb:getBtnName(rButton)]
	local bar = self.currentBar
	btn:SetShown(btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
	btn:SetChecked(btn.settings[1])
	self:sort(self.mbuttons)
	self:sort(self.mixedButtons)
	self:setButtonSize()
	self:applyLayout()
end


function main:addIgnoreName(name)
	local mName = name:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "%%%1")
	for _, n in ipairs(self.pConfig.ignoreMBtn) do
		if mName == n then return end
	end
	self:removeMButtonByName(name, true)
	tinsert(self.pConfig.ignoreMBtn, mName)
	sort(self.pConfig.ignoreMBtn)
	self.ignoreScroll:update()
end


function main:removeIgnoreName(name)
	StaticPopup_Show(self.addonName.."REMOVE_IGNORE_MBTN", NORMAL_FONT_COLOR:WrapTextInColorCode(name:gsub("%%([%(%)%.%%%+%-%*%?%[%^%$])", "%1")), nil, function()
		for i = 1, #self.pConfig.ignoreMBtn do
			if name == self.pConfig.ignoreMBtn[i] then
				tremove(self.pConfig.ignoreMBtn, i)
				break
			end
		end
		self.ignoreScroll:update()
		hb:addButtons()
	end)
end


function main:addCustomGrabName(name)
	StaticPopup_Show(self.addonName.."ADD_CUSTOM_GRAB_BTN", NORMAL_FONT_COLOR:WrapTextInColorCode(name), nil, function()
		for _, n in ipairs(self.pConfig.customGrabList) do
			if name == n then return end
		end
		tinsert(self.pConfig.customGrabList, name)
		sort(self.pConfig.customGrabList)
		self.customGrabScroll:update()

		local btn = hb:addCustomGrabButton(name)
		if btn then
			hb:setMBtnSettings(btn)
			hb:setBtnParent(btn)
			hb:sort()
			self.GetParent(btn):setButtonSize()
			self:initMButtons(true)
		end
	end)
end


function main:removeCustomGrabName(name)
	StaticPopup_Show(self.addonName.."REMOVE_CUSTOM_GRAB_BTN", NORMAL_FONT_COLOR:WrapTextInColorCode(name), nil, function()
		for i = 1, #self.pConfig.customGrabList do
			if name == self.pConfig.customGrabList[i] then
				tremove(self.pConfig.customGrabList, i)
				break
			end
		end
		self.customGrabScroll:update()
		if name:match(hb.matchName) then
			local btn = _G[name]
			if not btn or btn.bar.config.omb.canGrabbed then return end
		end
		self:removeMButtonByName(name, true)
	end)
end


function main:hidingBarUpdate(updateButtons)
	for i = 1, #self.pBars do
		local bar = hb.bars[i]
		if updateButtons then bar:applyLayout() end
		bar:enter()
		bar:leave(math.max(1.5, bar.config.hideDelay))
	end
end


function main:dragBtn(btn)
	local scale, x, y = btn:GetScale()
	if self.direction.V == "BOTTOM" then
		y = btn:GetBottom() - (self.buttonPanel:GetBottom() + self.bConfig.barOffset) / scale
	else
		y = (self.buttonPanel:GetTop() - self.bConfig.barOffset) / scale - btn:GetTop()
	end
	if self.direction.H == "RIGHT" then
		x = (self.buttonPanel:GetRight() - self.bConfig.barOffset) / scale - btn:GetRight()
	else
		x = btn:GetLeft() - (self.buttonPanel:GetLeft() + self.bConfig.barOffset) / scale
	end
	if self.orientation then x, y = y, x end
	local buttonSize = (self.bConfig.buttonSize + self.bConfig.rangeBetweenBtns) / scale
	local row, column = math.floor(y / buttonSize + .5), math.floor(x / buttonSize + .5) + 1
	if row < btn.minRow then row = btn.minRow
	elseif row > btn.maxRow then row = btn.maxRow end
	if column < 1 then column = 1
	elseif column > btn.maxColumn then column = btn.maxColumn end
	local order = row * self.bConfig.size + column - btn.orderDelta
	if order < 1 then order = 1
	elseif order > #btn.btnList then order = #btn.btnList end

	local step = order > btn.settings[2] and 1 or -1
	for i = btn.settings[2], order - step, step do
		local button = btn.btnList[i + step]
		btn.btnList[i] = button
		button.settings[2] = i
		self:setPointBtn(button, i + btn.orderDelta, .1)
	end
	btn.btnList[order] = btn
	btn.settings[2] = order
end


function main:dragStart(btn, orderDelta)
	GameTooltip:Hide()
	contextmenu:ddCloseMenus()
	btn.isDrag = true
	local list = self.bConfig.mbtnPosition == 2 and self.mixedButtons or btn.defBtnList
	btn.btnList = {}
	for i = 1, #list do
		if list[i]:IsShown() then
			local j = #btn.btnList + 1
			btn.btnList[j] = list[i]
			list[i].settings[2] = j
		end
	end
	if not btn.level then btn.level = btn:GetFrameLevel() end
	btn:SetFrameLevel(btn.level + 2)
	btn.orderDelta = orderDelta or 0
	btn.maxColumn = #btn.btnList + btn.orderDelta
	btn.minRow = math.floor(btn.orderDelta / self.bConfig.size)
	btn.maxRow = math.ceil(btn.maxColumn / self.bConfig.size) - 1
	if btn.maxColumn > self.bConfig.size then btn.maxColumn = self.bConfig.size end
	btn:SetScript("OnUpdate", function(btn) self:dragBtn(btn) end)
	btn:StartMoving()
end


function main:dragStop(btn)
	btn.isDrag = nil
	btn.btnList = nil
	btn:SetFrameLevel(btn.level)
	btn:SetScript("OnUpdate", nil)
	btn:StopMovingOrSizing()
	self:setPointBtn(btn, btn.settings[2] + btn.orderDelta, .3)
	btn.orderDelta = nil
	btn.maxColumn = nil
	btn.minRow = nil
	btn.maxRow = nil
	self:sort(btn.defBtnList)
	self:sort(self.mixedButtons)
	self:applyLayout()
	hb:sort()
	self:hidingBarUpdate(true)
end


function main:sort(buttons)
	sort(buttons, function(a, b)
		local o1, o2 = a.settings[2], b.settings[2]
		return o1 and not o2
			 or o1 and o2 and o1 < o2
			 or o1 == o2 and a.name < b.name
	end)
end


do
	local buttonsByName = {}

	local function btnClick(btn, button)
		if button == "LeftButton" then
			btn.settings[1] = btn:GetChecked()
			main:hidingBarUpdate(true)
			contextmenu:ddCloseMenus()
		elseif button == "RightButton" then
			btn:SetChecked(not btn:GetChecked())
			if btn.isDrag then return end
			contextmenu:ddToggle(1, btn, btn)
		end
	end

	local function btnDragStart(btn)
		main:dragStart(btn)
	end

	local function btnDragStop(btn)
		main:dragStop(btn)
	end

	local function btnEnter(btn)
		if btn.isDrag then return end
		GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
		GameTooltip:SetText(btn.title)
		GameTooltip:AddLine(L["Source:"]..GRAY_FONT_COLOR:WrapTextInColorCode(" DataBroker"), .3, .5, .7)
		GameTooltip:AddLine(L["BUTTON_TOOLTIP"], 1, 1, 1)
		GameTooltip:Show()
	end

	function main:createButton(name, button, update)
		if buttonsByName[name] then return end
		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigButtonTemplate")
		btn.rButton = button
		btn.name = button:GetName()
		btn.title = name
		if button.iconTex then
			btn.icon:SetTexture(button.iconTex)
			if button.iconCoords then
				btn.icon:SetTexCoord(unpack(button.iconCoords))
			end
			btn.icon:SetVertexColor(button.iconR or 1, button.iconG or 1, button.iconB or 1)
		end
		btn.color = {btn.icon:GetVertexColor()}
		btn.iconDesaturated = button.iconDesaturated
		btn.defBtnList = self.buttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", btnDragStart)
		btn:SetScript("OnDragStop", btnDragStop)
		btn:HookScript("OnEnter", btnEnter)
		contextmenu:ddSetNoGlobalMouseEvent(true, btn)
		buttonsByName[name] = btn
		tinsert(self.buttons, btn)
		tinsert(self.mixedButtons, btn)

		if update and self.barFrame then
			btn.settings = self.pConfig.btnSettings[name]
			local bar = self.currentBar
			btn:SetShown(btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
			btn:SetChecked(btn.settings[1])
			self:sort(self.buttons)
			self:sort(self.mixedButtons)
			self:setButtonSize()
			self:applyLayout()
		end
	end
	hb:on("BUTTON_ADDED", function(_, ...) main:createButton(...) end)
end


do
	local buttonsByName = {}

	local function btnClick(btn, button)
		if button == "LeftButton" then
			btn.settings[1] = btn:GetChecked()
			main:hidingBarUpdate(true)
			contextmenu:ddCloseMenus()
		elseif button == "RightButton" then
			btn:SetChecked(not btn:GetChecked())
			if btn.isDrag then return end
			contextmenu:ddToggle(1, btn, btn)
		end
	end

	local function btnDragStart(btn)
		main:dragStart(btn, main.orderMBtnDelta)
	end

	local function btnDragStop(btn)
		main:dragStop(btn)
	end

	local function btnEnter(btn)
		if btn.isDrag then return end
		GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
		GameTooltip:SetText(btn.title)
		GameTooltip:AddLine(L["Source:"].." "..GRAY_FONT_COLOR:WrapTextInColorCode(btn.manually and L["Manually added"] or "Minimap"), .3, .5, .7)
		GameTooltip:AddLine(L["BUTTON_TOOLTIP"], 1, 1, 1)
		GameTooltip:Show()
	end

	function main:createMButton(button, name, icon, update)
		if type(name) ~= "string" then return end
		if buttonsByName[name] then
			self:restoreMbutton(button)
			return
		end

		local btn = CreateFrame("CheckButton", nil, self.buttonPanel, "HidingBarAddonConfigMButtonTemplate")
		btn.rButton = button
		btn.name = name
		btn.title = name:gsub(hb.ldbiPrefix, "")
		local atlas = icon:GetAtlas()
		if atlas then
			btn.icon:SetAtlas(atlas)
		else
			btn.icon:SetTexture(icon:GetTexture())
		end
		btn.icon:SetTexCoord(icon:GetTexCoord())
		btn.color = {icon:GetVertexColor()}
		btn.defBtnList = self.mbuttons
		btn:HookScript("OnClick", btnClick)
		btn:SetScript("OnDragStart", btnDragStart)
		btn:SetScript("OnDragStop", btnDragStop)
		btn:SetScript("OnEnter", btnEnter)
		contextmenu:ddSetNoGlobalMouseEvent(true, btn)
		btn.manually = hb.manuallyButtons[button]
		hb.manuallyButtons[button] = nil
		btn.toIgnore = not (btn.manually or name:match(hb.matchName))
		buttonsByName[name] = btn
		tinsert(self.mbuttons, btn)
		tinsert(self.mixedButtons, btn)

		if update and self.barFrame then
			btn.settings = self.pConfig.mbtnSettings[name]
			local bar = self.currentBar
			btn:SetShown(btn.settings[3] == bar.name or not btn.settings[3] and bar.isDefault)
			btn:SetChecked(btn.settings[1])
			self:sort(self.mbuttons)
			self:sort(self.mixedButtons)
			self:setButtonSize()
			self:applyLayout()
		end
	end
	hb:on("MBUTTON_ADDED", function(_, btn) main:createMButton(btn, btn:GetName(), btn.icon, true) end)
end


function main:initButtons()
	for _, button in ipairs(hb.createdButtons) do
		self:createButton(button.name, button)
	end
end


function main:initMButtons(update)
	for _, button in ipairs(hb.minimapButtons) do
		local name = hb:getBtnName(button)
		if name then
			local icon = button.icon
			          or button.Icon
			          or _G[name.."icon"]
			          or _G[name.."Icon"]
			          or button.__MSQ_Icon
			          or button.GetNormalTexture and button:GetNormalTexture()
			          or button.texture
			          or button.Texture
			          or button.background
			          or button.Background
			if not icon or not icon.GetTexture or not icon:GetTexture() then
				icon = self.noIcon
			end
			self:createMButton(button, name, icon, update)
		end
	end
end
hb:on("MBUTTONS_UPDATED", function() main:initMButtons(true) end)


function main:setButtonSize()
	for _, button in ipairs(self.buttons) do
		if button:IsShown() then
			button:SetScale(self.bConfig.buttonSize / button:GetWidth())
		end
	end
	for _, button in ipairs(self.mbuttons) do
		if button:IsShown() then
			button:SetScale(self.bConfig.buttonSize / button:GetWidth())
		end
	end
end


local function setPosAnimated(btn, elapsed)
	btn.timer = btn.timer - elapsed
	btn:ClearAllPoints()
	if btn.timer <= 0 then
		btn:SetPoint(main.direction.rPoint, btn.x, btn.y)
		btn:SetScript("OnUpdate", nil)
	else
		local scale = btn:GetScale()
		local deltaY = main.direction.V == "BOTTOM"
			and btn.deltaY + btn:GetHeight() - main.buttonPanel:GetHeight() / scale
			or btn.deltaY
		local deltaX = main.direction.H == "RIGHT"
			and btn.deltaX + main.buttonPanel:GetWidth() / scale - btn:GetWidth()
			or btn.deltaX
		local k = btn.timer / btn.delay
		btn:SetPoint(main.direction.rPoint, btn.x - deltaX * k, btn.y - deltaY * k)
	end
end


function main:setPointBtn(btn, order, delay)
	if btn.isDrag then return end
	local scale = btn:GetScale()
	local buttonSize = self.bConfig.buttonSize + self.bConfig.rangeBetweenBtns
	order = order - 1
	btn.x = (order % self.bConfig.size * buttonSize + self.bConfig.barOffset) / scale
	btn.y = (-math.floor(order / self.bConfig.size) * buttonSize - self.bConfig.barOffset) / scale
	if self.orientation then btn.x, btn.y = -btn.y, -btn.x end
	if self.direction.V == "BOTTOM" then btn.y = -btn.y end
	if self.direction.H == "RIGHT" then btn.x = -btn.x end

	if delay and btn:IsVisible() then
		btn.timer = delay
		btn.delay = delay
		btn.deltaX = btn.x - btn:GetLeft() + self.buttonPanel:GetLeft() / scale
		btn.deltaY = btn.y - btn:GetTop() + self.buttonPanel:GetTop() / scale
		btn:SetScript("OnUpdate", setPosAnimated)
	else
		btn:ClearAllPoints()
		btn:SetPoint(self.direction.rPoint, btn.x, btn.y)
	end
end


function main:applyLayout(delay)
	if self.bConfig.orientation == 0 then
		local anchor = self.bConfig.barTypePosition == 2 and self.bConfig.omb.anchor or self.bConfig.anchor
		self.orientation = anchor == "top" or anchor == "bottom"
	else
		self.orientation = self.bConfig.orientation == 2
	end

	local i, columns, rows = 0, self.bConfig.size
	if self.bConfig.mbtnPosition == 2 then
		for _, btn in ipairs(self.mixedButtons) do
			if btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, delay)
			end
		end
		self.orderMBtnDelta = 0
		rows = math.ceil(i / columns)
	else
		for _, btn in ipairs(self.buttons) do
			if btn:IsShown() then
				i = i + 1
				self:setPointBtn(btn, i, delay)
			end
		end
		self.orderMBtnDelta = self.bConfig.mbtnPosition == 1 and i or math.ceil(i / columns) * columns
		local j = 0
		for _, btn in ipairs(self.mbuttons) do
			if btn:IsShown() then
				j = j + 1
				self:setPointBtn(btn, j + self.orderMBtnDelta, delay)
			end
		end
		rows = math.ceil((j + self.orderMBtnDelta) / columns)
	end

	if rows < 1 then rows = 1 end
	local buttonSize = self.bConfig.buttonSize + self.bConfig.rangeBetweenBtns
	local offset = self.bConfig.barOffset * 2 - self.bConfig.rangeBetweenBtns
	local width = columns * buttonSize + offset
	local height = rows * buttonSize + offset
	if self.orientation then width, height = height, width end
	self.buttonPanel:SetSize(width, height)
end


-- INIT
do
	local function init()
		main:initButtons()
		main:initMButtons()
		main:setProfile()
		hb.off(main, "INIT")
	end

	if hb.init then
		hb.on(main, "INIT", init)
	else
		init()
	end
end