--[[

Random Hearthstone
======================================================================================================================================================
If there's a new hearthstone but the addon isn't being updated simply add it to the bottom of the list below.
ItemID can be found from the URL of the item page on Wowhead.com

Weary Spirit Binding (ID: 163206) does not appear to be in-game. Adding it to the list below will cause errors!

If you would like to contribute to localisation translations please reach out on:
	Github	https://github.com/JamienAU/RandomHearth/
	Curse	https://legacy.curseforge.com/private-messages/send?recipient=jamienau

]]
------------------------------------------------------------------------------------------------------------------------------------------------------
local rhToys = {
	184353, --Kyrian Hearthstone
	183716, --Venthyr Sinstone
	180290, --Night Fae Hearthstone
	182773, --Necrolord Hearthstone
	54452, --Ethereal Portal
	64488, --The Innkeeper's Daughter
	93672, --Dark Portal
	142542, --Tome of Town Portal
	162973, --Greatfather Winter's Hearthstone
	163045, --Headless Horseman's Hearthstone
	165669, --Lunar Elder's Hearthstone
	165670, --Peddlefeet's Lovely Hearthstone
	165802, --Noble Gardener's Hearthstone
	166746, --Fire Eater's Hearthstone
	166747, --Brewfest Reveler's Hearthstone
	168907, --Holographic Digitalization Hearthstone
	172179, --Eternal Traveler's Hearthstone
	193588, --Timewalker's Hearthstone
	188952, --Dominated Hearthstone
	200630, --Ohn'ir Windsage's Hearthstone
	190237, --Broker Translocation Matrix
	190196, --Enlightened Hearthstone
	209035, --Hearthstone of the Flame
	208704, --Deepdweller's Earthen Hearthstone
	206195, --Path of the Naaru
	212337, --Stone of the Hearth
	210455, --Draenic Hologem
	228940, --Notorious Thread's Hearthstone
	235016, --Redeployment Module
	236687, -- Explosive Hearthstone
}

------------------------------------------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW HERE
-- Unless you want to, I'm not your supervisor.

local rhList, macroIcon, macroToyName, macroTimer, waitTimer
local rhCheckButtons, wait, lastRnd, loginMsg = {}, false, 0, "r21"
local playerClass = select(3,UnitClass("player"))
local addon, RH = ...
local L = RH.Localisation

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Frames
------------------------------------------------------------------------------------------------------------------------------------------------------
local rhOptionsPanel = CreateFrame("Frame")
local rhCategory = Settings.RegisterCanvasLayoutCategory(rhOptionsPanel, L["MACRO_NAME"])
local rhTitle = CreateFrame("Frame", nil, rhOptionsPanel)
local rhDesc = CreateFrame("Frame", nil, rhOptionsPanel)
local rhOptionsScroll = CreateFrame("ScrollFrame", nil, rhOptionsPanel, "UIPanelScrollFrameTemplate")
local rhDivider = rhOptionsScroll:CreateLine()
local rhScrollChild = CreateFrame("Frame")
local rhSelectAll = CreateFrame("Button", nil, rhOptionsScroll, "UIPanelButtonTemplate")
local rhDeselectAll = CreateFrame("Button", nil, rhOptionsScroll, "UIPanelButtonTemplate")
local rhOverride = CreateFrame("CheckButton", nil, rhOptionsScroll, "UICheckButtonTemplate")
local rhListener = CreateFrame("Frame")
local rhBtn = CreateFrame("Button", "rhB", nil, "SecureActionButtonTemplate")
local rhDropdown = CreateFrame("Frame", nil, rhOptionsPanel, "UIDropDownMenuTemplate")
local rhDalHearth = CreateFrame("CheckButton", nil, rhOptionsPanel, "UICheckButtonTemplate")
local rhGarHearth = CreateFrame("CheckButton", nil, rhOptionsPanel, "UICheckButtonTemplate")
local rhMacroName = CreateFrame("EditBox", nil, rhOptionsPanel, "InputBoxTemplate")

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Combat Check
local function combatCheck()
	if (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		return true
	end
end

-- Create or update global macro
local function updateMacro()
	if not combatCheck() then
		local macroText
		if #rhList == 0 then
			if rhDB.settings.warnMsg ~= true then
				rhDB.settings.warnMsg = true
				print(L["NO_VALID_CHOSEN"])
			end
			macroText = "#showtooltip " .. macroToyName .. "\n/use " .. macroToyName
		else
			-- Add cancelform to macro if player is a druid
			if playerClass == 11 then
				macroText = "#showtooltip " .. macroToyName .. "\n/cancelform\n/stopcasting\n/click [btn:2]rhB 2;[btn:3]rhB 3;rhB"
			else
				macroText = "#showtooltip " .. macroToyName .. "\n/stopcasting\n/click [btn:2]rhB 2;[btn:3]rhB 3;rhB"
			end
		end
		if macroTimer ~= true then
			macroTimer = true
			C_Timer.After(0.1, function()
				local macroIndex = GetMacroIndexByName(rhDB.settings.macroName)
				if macroIndex == 0 then
					print(L["MACRO_NOT_FOUND"], rhDB.settings.macroName, "'")
					CreateMacro(rhDB.settings.macroName, macroIcon, macroText, nil)
					rhMacroName:SetText(rhDB.settings.macroName)
				else
					EditMacro(macroIndex, nil, macroIcon, macroText)
				end
				macroTimer = false
			end)
		end
	end
end

local function updateMacroName()
	if not combatCheck() then
		local name = rhMacroName:GetText()
		local macroIndex = GetMacroIndexByName(rhDB.settings.macroName)
		if macroIndex == 0 then
			updateMacro()
		else
			EditMacro(macroIndex, name)
			rhDB.settings.macroName = name
			print(L["UPDATE_MACRO_NAME"], name, "'")
		end
	end
end

local function checkMacroName()
	if not combatCheck() then
		local name = rhMacroName:GetText()
		if name == rhDB.settings.macroName or string.len(name) == 0 then return end
		if GetMacroIndexByName(name) == 0 then
			rhMacroName.Icon:Hide()
			updateMacroName()
		end
	end
end
-- Set random Hearthstone
local function setRandom()
	if not combatCheck() then
		if #rhList > 0 then
			local rnd = rhList[math.random(1, #rhList)]
			if #rhList > 1 then
				while rnd == lastRnd do
					rnd = rhList[math.random(1, #rhList)]
				end
				lastRnd = rnd
			end
			macroToyName = rhDB.L.tList[rnd]["name"]
			rhBtn:SetAttribute("toy", macroToyName)
			if rhDB.iconOverride.name == L["RANDOM"] then
				macroIcon = rhDB.L.tList[rnd]["icon"]
			else
				macroIcon = rhDB.iconOverride.icon
			end
		else
			macroToyName = "item:6948"
			macroIcon = 134414
		end
		updateMacro()
	end
end

-- Generate a list of valid toys
local function listGenerate()
	rhList = {}
	local allCovenant
	local covenantHearths = {
		-- {Criteria index, Covenant index, Covenant toy, Enabled}
		{ 1, 1, 184353, false }, --Kyrian
		{ 4, 2, 183716, false }, --Venthyr
		{ 3, 3, 180290, false }, --Night Fae
		{ 2, 4, 182773, false } --Necrolord
	}
	for i, v in pairs(covenantHearths) do
		if select(3, GetAchievementCriteriaInfo(15646, v[1])) == true then
			covenantHearths[i][4] = true
		elseif C_Covenants.GetActiveCovenantID() ~= v[2] then
			if rhDB.L.tList[v[3]] ~= nil then
				rhCheckButtons[v[3]].Extratext = rhCheckButtons[v[3]]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				rhCheckButtons[v[3]].Extratext:SetText("|cff777777(" .. L["RENOWN_LOCKED"] .. ")|r")
				rhCheckButtons[v[3]].Extratext:SetPoint("LEFT", rhCheckButtons[v[3]].Text, "RIGHT", 10, 0)
			end
		end
	end

	if select(4, GetAchievementInfo(15241)) == true then
		if rhDB.settings.covOverride == true then
			allCovenant = false
		else
			allCovenant = true
		end
	end

	for i, v in pairs(rhDB.L.tList) do
		if v["status"] == true then
			if PlayerHasToy(i) then
				local addToy = true
				-- Check for Covenant
				for _, k in pairs(covenantHearths) do
					if i == k[3] then
						if k[4] == false and C_Covenants.GetActiveCovenantID() ~= k[2] then
							addToy = false
						elseif allCovenant == false and C_Covenants.GetActiveCovenantID() ~= k[2] then
							addToy = false
							break
						end
					end
				end
				-- Check Draenai
				if i == 210455 then
					local _, _, raceID = UnitRace("player")
					if not (raceID == 11 or raceID == 30) then
						addToy = false
					end
				end
				-- Create the list
				if addToy == true then
					table.insert(rhList, i)
				end
			end
		end
	end
	setRandom()
end

-- Update Hearthstone selections when options panel closes
local function rhOptionsOkay()
	for i, v in pairs(rhDB.L.tList) do
		v["status"] = rhCheckButtons[i]:GetChecked()
	end
	rhDB.settings.covOverride = rhOverride:GetChecked()
	rhDB.settings.dalOpt = rhDalHearth:GetChecked()
	rhDB.settings.garOpt = rhGarHearth:GetChecked()
	rhDB.settings.warnMsg = false
	listGenerate()
end

-- Macro icon selection
local function rhDropDownOnClick(self, arg1)
	if arg1 == "Random" then
		rhDB.iconOverride.name = L["RANDOM"]
		rhDB.iconOverride.icon = 134400
		rhDB.iconOverride.id = nil
	elseif arg1 == "Hearthstone" then
		rhDB.iconOverride.name = L["HEARTHSTONE"]
		rhDB.iconOverride.icon = 134414
		rhDB.iconOverride.id = 6948
	else
		rhDB.iconOverride.name = rhDB.L.tList[arg1]["name"]
		rhDB.iconOverride.icon = rhDB.L.tList[arg1]["icon"]
		rhDB.iconOverride.id = arg1
	end
	UIDropDownMenu_SetText(rhDropdown, rhDB.iconOverride.name)
	rhDropdown.Texture:SetTexture(rhDB.iconOverride.icon)
	CloseDropDownMenus()
end

-- Add items in savedvariable
local function rhInitDB(table, item, value)
	local isTable = type(value) == "table"
	local exists = false
	-- Check if the item already exists in the table
	for k, v in pairs(table) do
		if k == item or (type(v) == "table" and isTable and v == value) then
			exists = true
			break
		end
	end
	-- If the item does not exist, add it
	if not exists then
		if value ~= nil then
			-- Add item with a value
			table[item] = value
		else
			-- Add item without a value
			table.insert(table, item)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Button creation
------------------------------------------------------------------------------------------------------------------------------------------------------
rhBtn:RegisterForClicks("AnyDown")
rhBtn:SetAttribute("pressAndHoldAction", true)
rhBtn:SetAttribute("type", "toy")
rhBtn:SetAttribute("typerelease", "toy")
rhBtn:SetScript("PreClick", function(self, button, isDown)
	if not combatCheck() then
		if (button == "2" or button == "RightButton") and rhDB.settings.dalOpt then
			rhBtn:SetAttribute("toy", rhDB.L.dalaran)
		elseif (button == "3" or button == "MiddleButton") and rhDB.settings.garOpt then
			rhBtn:SetAttribute("toy", rhDB.L.garrison)
		end
	end
end)
rhBtn:SetScript("PostClick", function(self, button)
	if not combatCheck() then
		if (button == "2" or button == "RightButton") and rhDB.settings.dalOpt then
			rhBtn:SetAttribute("toy", macroToyName)
		elseif (button == "3" or button == "MiddleButton") and rhDB.settings.garOpt then
			rhBtn:SetAttribute("toy", macroToyName)
		else
			setRandom()
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Options panel
------------------------------------------------------------------------------------------------------------------------------------------------------
rhOptionsPanel.name = "Random Hearthstone"
rhOptionsPanel.OnCommit = function() rhOptionsOkay(); end
rhOptionsPanel.OnDefault = function() end
rhOptionsPanel.OnRefresh = function() end
Settings.RegisterAddOnCategory(rhCategory)

-- Title
rhTitle:SetPoint("TOPLEFT", 10, -10)
rhTitle:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhTitle:SetHeight(1)
rhTitle.Text = rhTitle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
rhTitle.Text:SetPoint("TOPLEFT", rhTitle, 0, 0)
rhTitle.Text:SetText(L["ADDON_NAME"])

-- Thanks
rhOptionsPanel.Thanks = rhOptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rhOptionsPanel.Thanks:SetPoint("TOPRIGHT", rhOptionsPanel, "TOPRIGHT", -5, -5)
rhOptionsPanel.Thanks:SetTextColor(1, 1, 1, 0.5)
rhOptionsPanel.Thanks:SetText(L["THANKS"] .. " :)\nNiian - Khaz'Goroth")
rhOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
rhDesc:SetPoint("TOPLEFT", 20, -40)
rhDesc:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhDesc:SetHeight(1)
rhDesc.Text = rhDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDesc.Text:SetPoint("TOPLEFT", rhDesc, 0, 0)
rhDesc.Text:SetText(L["DESCRIPTION"])

-- Scroll Frame
rhOptionsScroll:SetPoint("TOPLEFT", 5, -60)
rhOptionsScroll:SetPoint("BOTTOMRIGHT", -25, 150)

-- Divider
rhDivider:SetStartPoint("BOTTOMLEFT", rhDivider:GetParent(), 20, -10)
rhDivider:SetEndPoint("BOTTOMRIGHT", rhDivider:GetParent(), 0, -10)
rhDivider:SetColorTexture(0.25, 0.25, 0.25, 1)
rhDivider:SetThickness(1.2)

-- Scroll Frame child
rhOptionsScroll:SetScrollChild(rhScrollChild)
rhScrollChild:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhScrollChild:SetHeight(1)

-- Checkbox for each toy
local chkOffset = 0
for i = 1, #rhToys do
	if i > 1 then
		chkOffset = chkOffset + -26
	end
	rhCheckButtons[rhToys[i]] = CreateFrame("CheckButton", nil, rhScrollChild, "UICheckButtonTemplate")
	rhCheckButtons[rhToys[i]]:SetPoint("TOPLEFT", 15, chkOffset)
	rhCheckButtons[rhToys[i]]:SetSize(25, 25)
	rhCheckButtons[rhToys[i]].Text = rhCheckButtons[rhToys[i]]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local item = Item:CreateFromItemID(rhToys[i])
	item:ContinueOnItemLoad(function()
		rhCheckButtons[rhToys[i]].Text:SetText(item:GetItemName())
	end)
	rhCheckButtons[rhToys[i]].Text:SetTextColor(1, 1, 1, 1)
	rhCheckButtons[rhToys[i]].Text:SetPoint("LEFT", 28, 0)
end

-- Select All button
rhSelectAll:SetPoint("TOPLEFT", rhSelectAll:GetParent(), "BOTTOMLEFT", 20, -20)
rhSelectAll:SetSize(100, 25)
rhSelectAll:SetText(L["SELECT_ALL"])
rhSelectAll:SetScript("OnClick", function(self)
	for i, v in pairs(rhCheckButtons) do
		v:SetChecked(true)
	end
end)

-- Deselect All button
rhDeselectAll:SetPoint("TOPLEFT", rhDeselectAll:GetParent(), "BOTTOMLEFT", 135, -20)
rhDeselectAll:SetSize(100, 25)
rhDeselectAll:SetText(L["DESELECT_ALL"])
rhDeselectAll:SetScript("OnClick", function(self)
	for i, v in pairs(rhCheckButtons) do
		v:SetChecked(false)
	end
end)

-- Macro override dropdown
rhDropdown:SetPoint("TOPRIGHT", rhOverride:GetParent(), "BOTTOMRIGHT", 0, -35)
rhDropdown.Texture = rhDropdown:CreateTexture()
rhDropdown.Texture:SetSize(24, 24)
rhDropdown.Texture:SetPoint("LEFT", rhDropdown, "RIGHT", -10, 2)
rhDropdown.Extratext = rhDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDropdown.Extratext:SetText(L["OPT_MACRO_ICON"])
rhDropdown.Extratext:SetPoint("BOTTOMLEFT", rhDropdown, "TOPLEFT", 25, 5)

-- Covenant override checkbox
rhOverride:SetPoint("TOPLEFT", rhOverride:GetParent(), "BOTTOMLEFT", 15, -50)
rhOverride:SetSize(25, 25)
rhOverride.Text:SetJustifyH("LEFT")
rhOverride.Text:SetText(" " .. L["COV_ONLY"])
rhOverride.Text:SetTextColor(1, 1, 1, 1)

-- Dalaran hearth checkbox
rhDalHearth:SetPoint("TOPLEFT", rhOverride, "BOTTOMLEFT", 0, 0)
rhDalHearth:SetSize(25, 25)
rhDalHearth.Text:SetJustifyH("LEFT")
rhDalHearth.Text:SetText(" " .. L["DAL_R_CLICK"])
rhDalHearth.Text:SetTextColor(1, 1, 1, 1)

-- Garrison hearth checkbox
rhGarHearth:SetPoint("TOPLEFT", rhDalHearth, "BOTTOMLEFT", 0, 0)
rhGarHearth:SetSize(25, 25)
rhDalHearth.Text:SetJustifyH("LEFT")
rhGarHearth.Text:SetText(" " .. L["GAR_M_CLICK"])
rhGarHearth.Text:SetTextColor(1, 1, 1, 1)

-- Custom macro name box
rhMacroName:SetPoint("TOPLEFT", rhDropdown, "BOTTOMLEFT", 25, -20)
rhMacroName:SetAutoFocus(false)
rhMacroName:SetSize(208, 20)
rhMacroName:SetFontObject("GameFontNormal")
rhMacroName:SetTextColor(1, 1, 1, 1)
rhMacroName:SetMaxLetters(16)
rhMacroName.Text = rhMacroName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhMacroName.Text:SetText(L["OPT_MACRO_NAME"])
rhMacroName.Text:SetPoint("BOTTOMLEFT", rhMacroName, "TOPLEFT", 0, 5)
rhMacroName.Exist = rhMacroName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhMacroName.Exist:SetTextColor(1, 0, 0, 1)
rhMacroName.Exist:SetJustifyH("LEFT")
rhMacroName.Exist:SetPoint("TOPLEFT", rhMacroName, "BOTTOMLEFT", 0, -5)
rhMacroName.Exist:SetText(L["UNIQUE_NAME_ERROR"])
rhMacroName.Exist:Hide()
rhMacroName.Icon = rhMacroName:CreateTexture(nil, "OVERLAY")
rhMacroName.Icon:SetPoint("LEFT", rhMacroName, "RIGHT", 5, 0)
rhMacroName.Icon:SetTexture("Interface/COMMON/CommonIcons.PNG")
rhMacroName.Icon:SetSize(24, 24)
rhMacroName:SetScript("OnShow", function()
	rhMacroName.Exist:Hide()
	rhMacroName.Icon:Hide()
	rhMacroName:SetText(rhDB.settings.macroName)
end)
rhMacroName:SetScript("OnTextChanged", function(self, userInput)
	if userInput == true then
		-- Checking if the macro exists. Adding in a timer so it doesn't spam check on every key press.
		if waitTimer ~= true then
			waitTimer = true
			C_Timer.After(0.5, function()
				local name = rhMacroName:GetText()
				if name ~= rhDB.settings.macroName and GetMacroIndexByName(name) ~= 0 then
					rhMacroName.Exist:Show()
					rhMacroName.Icon:SetTexCoord(0.25, 0.38, 0, 0.26)
					rhMacroName.Icon:Show()
				elseif string.len(name) == 0 then
					rhMacroName.Icon:Hide()
				else
					rhMacroName.Exist:Hide()
					rhMacroName.Icon:SetTexCoord(0, 0.13, 0.51, 0.75)
					rhMacroName.Icon:Show()
				end
				waitTimer = false
			end)
		end
	end
end)
rhMacroName:SetScript("OnEditFocusLost", function() checkMacroName() end)
rhMacroName:SetScript("OnEnterPressed", function() checkMacroName() end)

-- Listener for addon loaded shenanigans
rhListener:RegisterEvent("ADDON_LOADED")
rhListener:RegisterEvent("PLAYER_ENTERING_WORLD")
rhListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addon then
		-- Set savedvariable defaults if first load or compare and update savedvariables with toy list
		if rhDB == nil then
			print(L["SETUP_1"])
			print(L["SETUP_2"])
			print(L["SETUP_3"])
			rhDB = {}
		end
		rhInitDB(rhDB, "settings", {})
		rhInitDB(rhDB.settings, "covOverride", false)
		rhInitDB(rhDB.settings, "dalOpt", true)
		rhInitDB(rhDB.settings, "garOpt", true)
		rhInitDB(rhDB.settings, "macroName", L["MACRO_NAME"])
		rhInitDB(rhDB.settings, "loginMsg", "")
		rhInitDB(rhDB.settings, "warnMsg", false)
		rhInitDB(rhDB, "iconOverride", { name = "Random", icon = 134400 })
		rhInitDB(rhDB, "L", {})
		rhInitDB(rhDB.L, "locale", GetLocale())

		if rhDB.L.tList == nil then
			wait = true
			rhDB.L.tList = {}
			for i = 1, #rhToys do
				local item = Item:CreateFromItemID(rhToys[i])
				item:ContinueOnItemLoad(function()
					rhDB.L.tList[rhToys[i]] = {
						name = item:GetItemName(),
						icon = item:GetItemIcon(),
						status = true
					}
				end)
			end
		end

		rhDB.chkStatus = nil

		-- Remove IDs that no longer exist in rhToys list
		for i, v in pairs(rhDB.L.tList) do
			local exists = 0
			for l = 1, #rhToys do
				if i == rhToys[l] then
					exists = 1
				end
			end
			if exists == 0 then
				rhDB.L.tList[i] = nil
			end
		end

		-- Add any new IDs to saved variables as enabled
		for i = 1, #rhToys do
			if not rhDB.L.tList[rhToys[i]] then
				wait = true
				local item = Item:CreateFromItemID(rhToys[i])
				item:ContinueOnItemLoad(function()
					rhDB.L.tList[rhToys[i]] = {
						name = item:GetItemName(),
						icon = item:GetItemIcon(),
						status = true
					}
					rhCheckButtons[rhToys[i]]:SetChecked(true)
					if i == #rhToys then
						listGenerate()
					end
				end)
			end
		end

		-- Update rhDB if locale has changed
		if rhDB.L.locale ~= GetLocale() then
			-- Update main list
			for i, v in pairs(rhDB.L.tList) do
				local item = Item:CreateFromItemID(i)
				item:ContinueOnItemLoad(function()
					rhDB.L.tList[i]["name"] = item:GetItemName()
				end)
			end

			-- Update iconOverride
			if rhDB.iconOverride.id ~= nil then
				local item = Item:CreateFromItemID(rhDB.iconOverride.id)
				item:ContinueOnItemLoad(function()
					rhDB.iconOverride.name = item:GetItemName()
					UIDropDownMenu_SetText(rhDropdown, rhDB.iconOverride.name)
				end)
			end

			rhDB.L.locale = GetLocale()
		end

		-- Loop through options and set checkbox state
		for i, v in pairs(rhDB.L.tList) do
			rhCheckButtons[i]:SetChecked(v["status"])
		end

		-- Set localised name for Dalaran and Garrison hearths
		local tmp = { { "dalaran", 140192 }, { "garrison", 110560 } }
		for _, v in pairs(tmp) do
			local item = Item:CreateFromItemID(v[2])
			item:ContinueOnItemLoad(function()
				rhDB.L[v[1]] = item:GetItemName()
			end)
		end

		rhOverride:SetChecked(rhDB.settings.covOverride)
		rhDalHearth:SetChecked(rhDB.settings.dalOpt)
		rhGarHearth:SetChecked(rhDB.settings.garOpt)
		rhDropdown.Texture:SetTexture(rhDB.iconOverride.icon)
		UIDropDownMenu_SetText(rhDropdown, rhDB.iconOverride.name)
		UIDropDownMenu_SetWidth(rhDropdown, 200)
		UIDropDownMenu_SetAnchor(rhDropdown, 0, 0, "BOTTOM", rhDropdown, "TOP")
		UIDropDownMenu_Initialize(rhDropdown, function(self)
			local info = UIDropDownMenu_CreateInfo()
			info.func, info.topPadding, info.tSizeX, info.tSizeY = rhDropDownOnClick, 3, 15, 15
			info.arg1, info.text, info.checked, info.icon = "Random", L["Random"], rhDB.iconOverride.name == L["Random"],
				134400
			UIDropDownMenu_AddButton(info)
			info.arg1, info.text, info.checked, info.icon = "Hearthstone", L["Hearthstone"],
				rhDB.iconOverride.name == L["Hearthstone"], 134414
			UIDropDownMenu_AddButton(info)
			for i = 1, #rhToys do
				if rhDB.L.tList[rhToys[i]] ~= nil then
					info.arg1 = rhToys[i]
					info.text = rhDB.L.tList[rhToys[i]]["name"]
					info.checked = rhDB.iconOverride.name == rhDB.L.tList[rhToys[i]]["name"]
					info.icon = rhDB.L.tList[rhToys[i]]["icon"]
					UIDropDownMenu_AddButton(info)
				end
			end
		end)

		self:UnregisterEvent("ADDON_LOADED")
	end

	if rhDB.settings.loginMsg ~= loginMsg then
		rhDB.settings.loginMsg = loginMsg
		print(L["LOGIN_MESSAGE"])
	end

	if event == "PLAYER_ENTERING_WORLD" then
		if not wait then
			listGenerate()
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create slash command
------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_RandomHearthstone1 = "/rh"
function SlashCmdList.RandomHearthstone(msg, editbox)
	Settings.OpenToCategory(rhCategory:GetID())
end

--[[
	Ignore this, it's for future me when Blizz breaks things again:
	/Interface/SharedXML/Settings/Blizzard_Settings.lua
]]
