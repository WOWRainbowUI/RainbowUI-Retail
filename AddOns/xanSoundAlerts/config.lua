local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

addon.configFrame = CreateFrame("frame", ADDON_NAME.."_config_eventFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
local configFrame = addon.configFrame

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local lastObject
local function addConfigEntry(objEntry, adjustX, adjustY)

	objEntry:ClearAllPoints()

	if not lastObject then
		objEntry:SetPoint("TOPLEFT", 20, -150)
	else
		objEntry:SetPoint("LEFT", lastObject, "BOTTOMLEFT", adjustX or 0, adjustY or -30)
	end

	lastObject = objEntry
end

local chkBoxIndex = 0
local function createCheckbutton(parentFrame, displayText)
	chkBoxIndex = chkBoxIndex + 1

	local checkbutton = CreateFrame("CheckButton", ADDON_NAME.."_config_chkbtn_" .. chkBoxIndex, parentFrame, "ChatConfigCheckButtonTemplate")
	getglobal(checkbutton:GetName() .. 'Text'):SetText(" "..displayText)

	return checkbutton
end

local buttonIndex = 0
local function createButton(parentFrame, displayText)
	buttonIndex = buttonIndex + 1

	local button = CreateFrame("Button", ADDON_NAME.."_config_button_" .. buttonIndex, parentFrame, "UIPanelButtonTemplate")
	button:SetText(displayText)
	button:SetHeight(30)
	button:SetWidth(button:GetTextWidth() + 30)

	return button
end

local sliderIndex = 0
local function createSlider(parentFrame, displayText, minVal, maxVal)
	sliderIndex = sliderIndex + 1

	local SliderBackdrop  = {
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, tileSize = 8, edgeSize = 8,
		insets = { left = 3, right = 3, top = 6, bottom = 6 }
	}

	local slider = CreateFrame("Slider", ADDON_NAME.."_config_slider_" .. sliderIndex, parentFrame, BackdropTemplateMixin and "BackdropTemplate")
	slider:SetOrientation("HORIZONTAL")
	slider:SetHeight(15)
	slider:SetWidth(300)
	slider:SetHitRectInsets(0, 0, -10, 0)
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetMinMaxValues(minVal or 0, maxVal or 100)
	slider:SetValue(0)
	slider:SetBackdrop(SliderBackdrop)

	local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("CENTER", slider, "CENTER", 0, 16)
	label:SetJustifyH("CENTER")
	label:SetHeight(15)
	label:SetText(displayText)

	local lowtext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	lowtext:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
	lowtext:SetText(minVal)

	local hightext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	hightext:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)
	hightext:SetText(maxVal)

	local currVal = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	currVal:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 45, 12)
	currVal:SetText('(?)')
	slider.currVal = currVal

	return slider
end

local function LoadAboutFrame()

	--Code inspired from tekKonfigAboutPanel
	local about = CreateFrame("Frame", ADDON_NAME.."AboutPanel", InterfaceOptionsFramePanelContainer, BackdropTemplateMixin and "BackdropTemplate")
	about.name = ADDON_NAME
	about:Hide()

    local fields = {"Version", "Author"}
	local notes = GetAddOnMetadata(ADDON_NAME, "Notes")

    local title = about:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")

	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(ADDON_NAME)

	local subtitle = about:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", about, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(notes)

	local anchor
	for _,field in pairs(fields) do
		local val = GetAddOnMetadata(ADDON_NAME, field)
		if val then
			local title = about:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			title:SetWidth(75)
			if not anchor then title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -8)
			else title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6) end
			title:SetJustifyH("RIGHT")
			title:SetText(field:gsub("X%-", ""))

			local detail = about:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			detail:SetPoint("LEFT", title, "RIGHT", 4, 0)
			detail:SetPoint("RIGHT", -16, 0)
			detail:SetJustifyH("LEFT")
			detail:SetText(val)

			anchor = title
		end
	end

	InterfaceOptions_AddCategory(about)

	return about
end

function configFrame:EnableConfig()

	addon.aboutPanel = LoadAboutFrame()

	local btnHealth = createCheckbutton(addon.aboutPanel, L.ChkBtnHealthInfo)
	btnHealth:SetScript("OnShow", function() btnHealth:SetChecked(XanSA_DB.allowHealth) end)
	btnHealth.func = function(slashSwitch)
		local value = XanSA_DB.allowHealth
		if not slashSwitch then value = XanSA_DB.allowHealth end

		if value then
			XanSA_DB.allowHealth = false
			DEFAULT_CHAT_FRAME:AddMessage(L.ChkBtnHealthOff)
		else
			XanSA_DB.allowHealth = true
			DEFAULT_CHAT_FRAME:AddMessage(L.ChkBtnHealthOn)
		end
	end
	btnHealth:SetScript("OnClick", btnHealth.func)

	addConfigEntry(btnHealth, 0, -20)
	addon.aboutPanel.btnHealth = btnHealth

	local btnMana = createCheckbutton(addon.aboutPanel, L.ChkBtnManaInfo)
	btnMana:SetScript("OnShow", function() btnMana:SetChecked(XanSA_DB.allowMana) end)
	btnMana.func = function(slashSwitch)
		local value = XanSA_DB.allowMana
		if not slashSwitch then value = XanSA_DB.allowMana end

		if value then
			XanSA_DB.allowMana = false
			DEFAULT_CHAT_FRAME:AddMessage(L.ChkBtnManaOff)
		else
			XanSA_DB.allowMana = true
			DEFAULT_CHAT_FRAME:AddMessage(L.ChkBtnManaOn)
		end
	end
	btnMana:SetScript("OnClick", btnMana.func)

	addConfigEntry(btnMana, 0, -20)
	addon.aboutPanel.btnMana = btnMana

	if IsRetail then
		for i=1, table.getn(addon.orderIndex) do
			local k = addon.orderIndex[i]

			if k and _G[k] then

				addon.aboutPanel["btn"..k] = createCheckbutton(addon.aboutPanel, string.format(L.ChkBtnOtherInfo, _G[k] ))
				local btnTemp = addon.aboutPanel["btn"..k]

				btnTemp:SetScript("OnShow", function() btnTemp:SetChecked(XanSA_DB["allow"..k]) end)
				btnTemp.func = function(slashSwitch)
					local value = XanSA_DB["allow"..k]
					if not slashSwitch then value = XanSA_DB["allow"..k] end

					if value then
						XanSA_DB["allow"..k] = false
						DEFAULT_CHAT_FRAME:AddMessage(string.format(L.ChkBtnOtherOff, _G[k] ))
					else
						XanSA_DB["allow"..k] = true
						DEFAULT_CHAT_FRAME:AddMessage(string.format(L.ChkBtnOtherOn, _G[k] ))
					end
				end
				btnTemp:SetScript("OnClick", btnTemp.func)

				addConfigEntry(btnTemp, 0, -20)

			end

		end
	end

end
