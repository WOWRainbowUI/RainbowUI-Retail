--[[

Random Hearthstone
======================================================================================================================================================
If there's a new hearthstone but the addon isn't being updated simply add it to the bottom of the list below.
ItemID can be found from the URL of the item page on Wowhead.com

Weary Spirit Binding (ID: 163206) does not appear to be in-game. Adding it to the list below will cause errors!

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
}

------------------------------------------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW HERE
-- Unless you want to, I'm not your supervisor.

local rhList, count, macroIcon, macroName
local rhCheckButtons = {}
local wait = false
local addon = ...
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Frames
------------------------------------------------------------------------------------------------------------------------------------------------------
local rhOptionsPanel = CreateFrame("Frame")
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
local rhDropdown = CreateFrame("Frame", nil, rhOptionsScroll, "UIDropDownMenuTemplate")
local rhDalHearth = CreateFrame("CheckButton", nil, rhOptionsScroll, "UICheckButtonTemplate")
local rhGarHearth = CreateFrame("CheckButton", nil, rhOptionsScroll, "UICheckButtonTemplate")

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create or update global macro
local function updateMacro()
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		local macroText
		if #rhList == 0 then
			print("|cffFF0000No valid Hearthstone toy chosen -|r Setting macro to use Hearthstone")
			macroText = "#showtooltip " .. macroName .. "\n/use " .. macroName
		else
			macroText = "#showtooltip " .. macroName .. "\n/stopcasting\n/click [btn:2]rhB 2;[btn:3]rhB 3;rhB"
		end
		local macroIndex = GetMacroIndexByName("Random Hearth")
		if macroIndex == 0 then
			CreateMacro("Random Hearth", macroIcon, macroText, nil)
		else
			EditMacro(macroIndex, nil, macroIcon, macroText)
		end
	end
end

-- Generate a list of valid toys
local function listGenerate()
	rhList = {}
	count = 0
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
				rhCheckButtons[v[3]].Extratext:SetFont("STANDARD_TEXT_FONT", 13)
				rhCheckButtons[v[3]].Extratext:SetText("|cff777777(Renown locked)|r")
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
					if raceID ~= 11 or raceID ~= 30 then
						addToy = false
					end
				end
				-- Create the list
				if addToy == true then
					count = count + 1
					table.insert(rhList, i)
				end
			end
		end
	end

	-- Set variables for macro text and icon
	local rnd
	if #rhList > 0 then
		rnd = rhList[math.random(1, count)]
	else
		rnd = 6948
	end
	local item = Item:CreateFromItemID(rnd)
	item:ContinueOnItemLoad(function()
		macroName = item:GetItemName()
		if rhDB.iconOverride.name ~= "Random" then
			macroIcon = rhDB.iconOverride.icon
		else
			macroIcon = item:GetItemIcon()
		end
		updateMacro()
	end)
end

-- Set random Hearthstone
local function setRandom()
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) and #rhList > 0 then
		local rnd = rhList[math.random(1, count)]
		rhBtn:SetAttribute("toy", rhDB.L.tList[rnd]["name"])
		if rhDB.iconOverride.name == "Random" then
			macroIcon = rhDB.L.tList[rnd]["icon"]
			local macroIndex = GetMacroIndexByName("Random Hearth")
			if macroIndex ~= 0 then
				EditMacro(macroIndex, nil, macroIcon)
			end
		end
	end
end

-- Update Hearthstone selections when options panel closes
local function rhOptionsOkay()
	for i, v in pairs(rhDB.L.tList) do
		v["status"] = rhCheckButtons[i]:GetChecked()
	end
	rhDB.settings.covOverride = rhOverride:GetChecked()
	rhDB.settings.dalOpt = rhDalHearth:GetChecked()
	rhDB.settings.garOpt = rhGarHearth:GetChecked()
	listGenerate()
end

-- Macro icon selection
local function rhDropDownOnClick(self, arg1)
	if arg1 == "Random" then
		rhDB.iconOverride.name = "Random"
		rhDB.iconOverride.icon = 134400
		rhDB.iconOverride.id = nil
	elseif arg1 == "Hearthstone" then
		rhDB.iconOverride.name = "Hearthstone"
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
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		if (button == "2" or button == "RightButton") and rhDB.settings.dalOpt then
			rhBtn:SetAttribute("toy", rhDB.L.dalaran)
		elseif (button == "3" or button == "MiddleButton") and rhDB.settings.garOpt then
			rhBtn:SetAttribute("toy", rhDB.L.garrison)
		else
			setRandom()
		end
	end
end)
rhBtn:SetScript("PostClick", function(self, button)
	if button == "2" or button == "RightButton" or button == "3" or button == "MiddleButton" then
		setRandom()
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Options panel
------------------------------------------------------------------------------------------------------------------------------------------------------
rhOptionsPanel.name = "Random Hearthstone"
rhOptionsPanel.OnCommit = function() rhOptionsOkay(); end
rhOptionsPanel.OnDefault = function() end
rhOptionsPanel.OnRefresh = function() end
local rhCategory = Settings.RegisterCanvasLayoutCategory(rhOptionsPanel, "Random Hearthstone")
Settings.RegisterAddOnCategory(rhCategory)

-- Title
rhTitle:SetPoint("TOPLEFT", 10, -10)
rhTitle:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhTitle:SetHeight(1)
rhTitle.text = rhTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhTitle.text:SetPoint("TOPLEFT", rhTitle, 0, 0)
rhTitle.text:SetText("Random Hearthstone")
rhTitle.text:SetFont("STANDARD_TEXT_FONT", 18)

-- Thanks
rhOptionsPanel.Thanks = rhOptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhOptionsPanel.Thanks:SetPoint("BOTTOMRIGHT", -5, 5)
rhOptionsPanel.Thanks:SetText("Thanks for using my addon :)\nNiian - Khaz'Goroth")
rhOptionsPanel.Thanks:SetFont("STANDARD_TEXT_FONT", 9)
rhOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
rhDesc:SetPoint("TOPLEFT", 20, -40)
rhDesc:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhDesc:SetHeight(1)
rhDesc.text = rhDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDesc.text:SetPoint("TOPLEFT", rhDesc, 0, 0)
rhDesc.text:SetText("Add or remove hearthstone toys from rotation")
rhDesc.text:SetFont("STANDARD_TEXT_FONT", 14)

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
	local item = Item:CreateFromItemID(rhToys[i])
	item:ContinueOnItemLoad(function()
		rhCheckButtons[rhToys[i]].Text:SetText(item:GetItemName())
	end)
	rhCheckButtons[rhToys[i]].Text:SetTextColor(1, 1, 1, 1)
	rhCheckButtons[rhToys[i]].Text:SetFont("STANDARD_TEXT_FONT", 13)
	rhCheckButtons[rhToys[i]].Text:SetPoint("LEFT", 28, 0)
end

-- Select All button
rhSelectAll:SetPoint("TOPLEFT", rhSelectAll:GetParent(), "BOTTOMLEFT", 20, -20)
rhSelectAll:SetSize(100, 25)
rhSelectAll:SetText("Select all")
rhSelectAll:SetScript("OnClick", function(self)
	for i, v in pairs(rhCheckButtons) do
		v:SetChecked(true)
	end
end)

-- Deselect All button
rhDeselectAll:SetPoint("TOPLEFT", rhDeselectAll:GetParent(), "BOTTOMLEFT", 135, -20)
rhDeselectAll:SetSize(100, 25)
rhDeselectAll:SetText("Deselect all")
rhDeselectAll:SetScript("OnClick", function(self)
	for i, v in pairs(rhCheckButtons) do
		v:SetChecked(false)
	end
end)

-- Macro override dropdown
rhDropdown:SetPoint("TOPRIGHT", rhOverride:GetParent(), "BOTTOMRIGHT", 0, -20)
rhDropdown.Texture = rhDropdown:CreateTexture()
rhDropdown.Texture:SetSize(24, 24)
rhDropdown.Texture:SetPoint("LEFT", rhDropdown, "RIGHT", -10, 2)
rhDropdown.Extratext = rhDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDropdown.Extratext:SetFont("STANDARD_TEXT_FONT", 13)
rhDropdown.Extratext:SetText("Macro icon")
rhDropdown.Extratext:SetPoint("RIGHT", rhDropdown, "LEFT", 10, 2)

-- Covenant override checkbox
rhOverride:SetPoint("TOPLEFT", rhOverride:GetParent(), "BOTTOMLEFT", 15, -50)
rhOverride:SetSize(25, 25)
rhOverride.Text:SetText(" Allow player's current Covenant hearthstone only")
rhOverride.Text:SetTextColor(1, 1, 1, 1)
rhOverride.Text:SetFont("STANDARD_TEXT_FONT", 13)

-- Dalaran hearth checkbox
rhDalHearth:SetPoint("TOPLEFT", rhOverride, "BOTTOMLEFT", 0, 0)
rhDalHearth:SetSize(25, 25)
rhDalHearth.Text:SetText(" Cast Dalaran Hearth on macro right click")
rhDalHearth.Text:SetTextColor(1, 1, 1, 1)
rhDalHearth.Text:SetFont("STANDARD_TEXT_FONT", 13)

-- Garrison hearth checkbox
rhGarHearth:SetPoint("TOPLEFT", rhDalHearth, "BOTTOMLEFT", 0, 0)
rhGarHearth:SetSize(25, 25)
rhGarHearth.Text:SetText(" Cast Garrison Hearth on macro middle click")
rhGarHearth.Text:SetTextColor(1, 1, 1, 1)
rhGarHearth.Text:SetFont("STANDARD_TEXT_FONT", 13)

-- Listener for addon loaded shenanigans
rhListener:RegisterEvent("ADDON_LOADED")
rhListener:RegisterEvent("PLAYER_ENTERING_WORLD")
rhListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addon then
		-- Set savedvariable defaults if first load or compare and update savedvariables with toy list
		if rhDB == nil then
			print("Setting up Random Hearthstone DB variables")
			print("You can now cast Dalaran hearth with right click, and Garrison hearth with middle mouse button.")
			print("These settings can be changed in the options, type /rh")
			rhDB = {}
		end
		rhInitDB(rhDB, "settings", {})
		rhInitDB(rhDB.settings, "covOverride", false)
		rhInitDB(rhDB.settings, "dalOpt", true)
		rhInitDB(rhDB.settings, "garOpt", true)
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
			info.arg1, info.text, info.checked, info.icon = "Random", "Random", rhDB.iconOverride.name == "Random",
				134400
			UIDropDownMenu_AddButton(info)
			info.arg1, info.text, info.checked, info.icon = "Hearthstone", "Hearthstone",
				rhDB.iconOverride.name == "Hearthstone", 134414
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
