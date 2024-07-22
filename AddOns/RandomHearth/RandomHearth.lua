local rhList, count, src
local addon = ...

--------------------------------------------------------------------
-- Hearthstone List
-- ----------------
-- If there's a new hearthstone but the addon isn't being updated
-- simply add it to the bottom of the list below, following the
-- format of the items listed. ItemID can be found from the URL
-- of the item page on Wowhead.com
--------------------------------------------------------------------
local rhToys = {
	{180290, "Night Fae Hearthstone"},
	{182773, "Necrolord Hearthstone"},
	{183716, "Venthyr Sinstone"},
	{184353, "Kyrian Hearthstone"},
	{54452, "Ethereal Portal"},
	{64488, "The Innkeeper's Daughter"},
	{93672, "Dark Portal"},
	{142542, "Tome of Town Portal"},
	{162973, "Greatfather Winter's Hearthstone"},
	{163045, "Headless Horseman's Hearthstone"},
	{165669, "Lunar Elder's Hearthstone"},
	{165670, "Peddlefeet's Lovely Hearthstone"},
	{165802, "Noble Gardener's Hearthstone"},
	{166746, "Fire Eater's Hearthstone"},
	{166747, "Brewfest Reveler's Hearthstone"},
	{168907, "Holographic Digitalization Hearthstone"},
	{172179, "Eternal Traveler's Hearthstone"},
	{193588, "Timewalker's Hearthstone"},
	{188952, "Dominated Hearthstone"},
	{200630, "Ohnir Windsage's Hearthstone"},
	{190237, "Broker Translocation Matrix"},
	{190196, "Enlightened Hearthstone"},
	{163206, "Weary Spirit Binding"},
	{209035, "Hearthstone of the Flame"},
	{208704, "Deepdweller's Earthen Hearthstone"},
	{206195, "Path of the Naaru"},
	{212337, "Stone of the Hearth"},
	{210455, "Draenic Hologem"},
	}

--------------------------------------------------------------------
-- Options panel
--------------------------------------------------------------------

local rhOptionsPanel = CreateFrame("Frame")
rhOptionsPanel.name = "Random Hearthstone"
rhOptionsPanel.okay = function() optionsOkay(); end
rhOptionsPanel.cancel = function() optionsCancel(); end
-- InterfaceOptions_AddCategory(rhOptionsPanel)
local category = Settings.RegisterCanvasLayoutCategory(rhOptionsPanel, rhOptionsPanel.name)
category.ID = "RandomHearth"
Settings.RegisterAddOnCategory(category)

-- Title
local rhTitle = CreateFrame("Frame",nil, rhOptionsPanel)
rhTitle:SetPoint("TOPLEFT", 10, -10)
rhTitle:SetWidth(SettingsPanel.Container:GetWidth()-35)
rhTitle:SetHeight(1)
rhTitle.text = rhTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhTitle.text:SetPoint("TOPLEFT", rhTitle, 0, 0)
rhTitle.text:SetText("Random Hearthstone")
rhTitle.text:SetFont("Fonts\\FRIZQT__.TTF", 18)

-- Thanks
rhOptionsPanel.Thanks = rhOptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhOptionsPanel.Thanks:SetPoint("BOTTOMRIGHT",-5,5)
rhOptionsPanel.Thanks:SetText("Thanks for using my addon :)\nNiian - Khaz'Goroth")
rhOptionsPanel.Thanks:SetFont("Fonts\\FRIZQT__.TTF", 9)
rhOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
local rhDesc = CreateFrame("Frame", nil, rhOptionsPanel)
rhDesc:SetPoint("TOPLEFT", 20, -40)
rhDesc:SetWidth(SettingsPanel.Container:GetWidth()-35)
rhDesc:SetHeight(1)
rhDesc.text = rhDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDesc.text:SetPoint("TOPLEFT", rhDesc, 0, 0)
rhDesc.text:SetText("Add or remove hearthstone toys from rotation")
rhDesc.text:SetFont("Fonts\\FRIZQT__.TTF", 14)

-- Scroll Frame
local rhOptionsScroll = CreateFrame("ScrollFrame", nil, rhOptionsPanel, "UIPanelScrollFrameTemplate")
rhOptionsScroll:SetPoint("TOPLEFT", 5, -60)
rhOptionsScroll:SetPoint("BOTTOMRIGHT", -25, 100)

-- Divider
local rhDivider = rhOptionsScroll:CreateLine()
rhDivider:SetStartPoint("BOTTOMLEFT", 20, -10)
rhDivider:SetEndPoint("BOTTOMRIGHT", 0, -10)
rhDivider:SetColorTexture(0.25,0.25,0.25,1)
rhDivider:SetThickness(1.2)

-- Scroll Frame child
local rhScrollChild = CreateFrame("Frame")
rhOptionsScroll:SetScrollChild(rhScrollChild)
rhScrollChild:SetWidth(SettingsPanel.Container:GetWidth()-35)
rhScrollChild:SetHeight(1)

-- Checkbox for each toy
local rhCheckButtons = {}
for i = 1, #rhToys do
	local chkOffset = 0
	if i > 1 then
		local _,_,_,_,yOffSet = rhCheckButtons[i-1]:GetPoint()
		chkOffset = math.floor(yOffSet) + -26
	end
	rhCheckButtons[i] = CreateFrame("CheckButton", nil, rhScrollChild, "UICheckButtonTemplate")
	rhCheckButtons[i]:SetPoint("TOPLEFT", 15, chkOffset)
	rhCheckButtons[i]:SetSize(25,25)
	rhCheckButtons[i].ID = rhToys[i][1]
	rhCheckButtons[i].Text:SetText("  " .. rhToys[i][2])
	rhCheckButtons[i].Text:SetTextColor(1,1,1,1)
	rhCheckButtons[i].Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
end

-- Select All button
local rhSelectAll = CreateFrame("Button", nil, rhOptionsPanel, "UIPanelButtonTemplate")
rhSelectAll:SetPoint("BOTTOMLEFT", 20, 50)
rhSelectAll:SetSize(100,25)
rhSelectAll:SetText("Select all")
rhSelectAll:SetScript("OnClick", function(self)
	for i = 1, #rhToys do
		rhCheckButtons[i]:SetChecked(true)
	end
end)

-- Deselect All button
local rhDeselectAll = CreateFrame("Button", nil, rhOptionsPanel, "UIPanelButtonTemplate")
rhDeselectAll:SetPoint("BOTTOMLEFT", 135, 50)
rhDeselectAll:SetSize(100,25)
rhDeselectAll:SetText("Deselect all")
rhDeselectAll:SetScript("OnClick", function(self)
	for i = 1, #rhToys do
		rhCheckButtons[i]:SetChecked(false)
	end
end)

-- Covenant override checkbox
local rhOverride = CreateFrame("CheckButton", nil, rhOptionsPanel, "UICheckButtonTemplate")
rhOverride:SetPoint("BOTTOMLEFT", 20, 20)
rhOverride:SetSize(25,25)
rhOverride.Text:SetText("  Coventant Hearth override")
rhOverride.Text:SetTextColor(1,1,1,1)
rhOverride.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
rhOverride.Extratext = rhOverride:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhOverride.Extratext:SetPoint("TOPLEFT", rhOverride, 32, -25)
rhOverride.Extratext:SetText("Will only allow current covenant hearthstone if ticked")
rhOverride.Extratext:SetFont("Fonts\\FRIZQT__.TTF", 12)

local rhListener = CreateFrame("Frame")
rhListener:RegisterEvent("ADDON_LOADED")
rhListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addon then
		-- Set savedvariable defaults if first load or compare and update savedvariables with toy list
		if rhOverrideChk == nil then
			rhOverrideChk = false
		end

		if rhOptions == nil then
			-- Adds all toy IDs to savedvariables as enabled
			rhOptions = {}
			for i=1, #rhToys do
				rhOptions[i] = {rhToys[i][1], true}
			end
		else
			-- Deletes toy IDs that no longer exist in rhToys list
			for i,v in pairs(rhOptions) do
				local chk = 0
				for l = 1, #rhToys do
					if v[1] == rhToys[l][1] then
						chk = 1
					end
				end
				if chk == 0 then 
					rhOptions[i] = nil
				end
			end

			-- Adds any missing toy IDs to savedvariables as enabled
			for i,v in pairs(rhToys) do
				local chk = 0
				for l = 1, #rhOptions do
					if v[1] == rhOptions[l][1] then
						chk = 1
					end
				end
				if chk == 0 then
					table.insert(rhOptions, {v[1], true})
				end
			end
		end
		
		-- Loop through options and set checkbox state
		for i,v in pairs(rhOptions) do
			for l = 1, #rhOptions do
				if rhCheckButtons[l].ID == v[1] and v[2] == true then
					rhCheckButtons[l]:SetChecked(true)
				end
			end
		end

		rhOverride:SetChecked(rhOverrideChk)

	self:UnregisterEvent("ADDON_LOADED")
	end
end)

function optionsOkay()
	for i = 1, #rhOptions do
		for _,v in pairs(rhOptions) do
			if rhCheckButtons[i].ID == v[1] then
				v[2] = rhCheckButtons[i]:GetChecked()
			end
		end
	end
	rhOverrideChk = rhOverride:GetChecked()
	listGenerate()
	setRandom()
end

function optionsCancel()
	for i,v in pairs(rhOptions) do
		for l = 1, #rhOptions do
			if rhCheckButtons[l].ID == v[1] and v[2] == true then
				rhCheckButtons[l]:SetChecked(true)
			end
		end
	end
	rhOverride:SetChecked(rhOverrideChk)
end

--------------------------------------------------------------------
-- Button creation
--------------------------------------------------------------------
local rhBtn = CreateFrame("Button", "rhButton", nil,  "SecureActionButtonTemplate")
rhBtn:RegisterEvent("PLAYER_ENTERING_WORLD")
rhBtn:RegisterEvent("UNIT_SPELLCAST_STOP")
rhBtn:RegisterForClicks("LeftButtonDown", "LeftButtonUp" )
rhBtn:SetAttribute("type","toy")
rhBtn:SetScript("OnEvent", function(self,event, arg1)
		if not InCombatLockdown() then
			if event == "PLAYER_ENTERING_WORLD" then
				listGenerate()
				setRandom()
			end
			
			if event == "UNIT_SPELLCAST_STOP" and arg1 == "player" then
				setRandom()
			end
		end
	end)

--------------------------------------------------------------------
-- Generate list of valid Hearthstone toys
--------------------------------------------------------------------
local covenantHearths = {
	{1,184353}, --Kyrian
	{2,183716}, --Venthyr
	{3,180290}, --Night Fae
	{4,182773}  --Necrolord
}

function listGenerate()
	rhList = {}
	count = 0

	if select(4,GetAchievementInfo(15241)) == true then
		if rhOverrideChk == true then
			allCovenant = false
		else
			allCovenant = true
		end
	end

	for i=1, #rhOptions do
		if rhOptions[i][2] == true then
			if PlayerHasToy(rhOptions[i][1]) then
				local addToy = true
				-- Check for Covenant
				for _,v in pairs(covenantHearths) do
					if rhOptions[i][1] == v[2] then
						if allCovenant == false and C_Covenants.GetActiveCovenantID() ~= v[1] then
							addToy = false
							break
						end
					end
				end
				-- Check Draenai
				if rhOptions[i][1] == 210455 then
					local _,_,raceID = UnitRace("player")
					if raceID ~= 11 or raceID ~= 30 then
						addToy = false
					end
				end
				-- Create the list
				if addToy == true then
					count = count + 1
					table.insert(rhList,rhOptions[i][1])
				end
			end
		end
	end

	if #rhList == 0 then 
		print("|cffFF0000No valid Hearthstone toy chosen -|r Setting macro to use Hearthstone")
		src = "\n/use Hearthstone"
	else 
		src = "\n/click rhButton 1\n/click rhButton LeftButton 1" 
	end
end

--------------------------------------------------------------------
-- Set random Hearthstone
--------------------------------------------------------------------
function setRandom()
	if not InCombatLockdown() and #rhList > 0 then
		local rnd = math.random(1,count)
		local item = Item:CreateFromItemID(rhList[rnd])
		item:ContinueOnItemLoad(function()
			local name = item:GetItemName()
			local icon = item:GetItemIcon()
			rhBtn:SetAttribute("toy",name)
			updateMacro(name,icon)
		end)
	elseif #rhList == 0 then
		updateMacro("Hearthstone","134414")
	end
end

--------------------------------------------------------------------
-- Create or update global macro
--------------------------------------------------------------------
function updateMacro(name,icon)
	if not InCombatLockdown() then
		local macroIndex = GetMacroIndexByName("Random Hearth")
		if macroIndex > 0 then
			EditMacro(macroIndex, "Random Hearth", icon, "#showtooltip " .. name .. src)
		else
			CreateMacro("Random Hearth", icon, "#showtooltip " .. name .. src, nil)
		end
	end
end

--------------------------------------------------------------------
-- Create slash command
--------------------------------------------------------------------
SLASH_RandomHearthstone1 = "/rh"
function SlashCmdList.RandomHearthstone(msg, editbox)
Settings.OpenToCategory("RandomHearth")
end