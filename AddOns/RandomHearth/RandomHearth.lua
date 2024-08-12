local rhList, count, src, rhOverrideChk, allCovenant, validCovHearths
local rhCheckButtons = {}
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
	{184353, "琪瑞安爐石"},
	{183716, "汎希爾爐石"},
	{180290, "暗夜妖精爐石"},
	{182773, "死靈領主爐石"},
 	{54452, "虛靈之門"},
	{64488, "旅店老闆的女兒"},
	{93672, "黑暗之門"},
	{142542, "城鎮傳送之書"},
	{162973, "冬天爺爺的爐石"},
	{163045, "無頭騎士的爐石"},
	{165669, "春節長者的爐石"},
	{165670, "傳播者充滿愛的爐石"},
	{165802, "復活節的爐石"},
	{166746, "吞火者的爐石"},
	{166747, "啤酒節狂歡者的爐石"},
	{168907, "全像數位化爐石"},
	{172179, "永恆旅者的爐石"},
	{193588, "時空漫遊者的爐石"},
	{188952, "統御的爐石"},
	{200630, "雍伊爾風之賢者爐石"},
	{190237, "仲介者傳送矩陣"},
	{190196, "受啟迪的爐石"},
	{163206, "Weary Spirit Binding"},
	{209035, "烈焰爐石"},
	{208704, "深淵居者的大地爐石"},
	{206195, "那魯之道"},
	{212337, "爐石之石"},
	{210455, "德萊尼全像寶石"},
}

--------------------------------------------------------------------
-- Frames
--------------------------------------------------------------------
local rhOptionsPanel = CreateFrame("Frame")
local rhTitle = CreateFrame("Frame",nil, rhOptionsPanel)
local rhDesc = CreateFrame("Frame", nil, rhOptionsPanel)
local rhOptionsScroll = CreateFrame("ScrollFrame", nil, rhOptionsPanel, "UIPanelScrollFrameTemplate")
local rhDivider = rhOptionsScroll:CreateLine()
local rhScrollChild = CreateFrame("Frame")
local rhSelectAll = CreateFrame("Button", nil, rhOptionsPanel, "UIPanelButtonTemplate")
local rhDeselectAll = CreateFrame("Button", nil, rhOptionsPanel, "UIPanelButtonTemplate")
local rhOverride = CreateFrame("CheckButton", nil, rhOptionsPanel, "UICheckButtonTemplate")
local rhListener = CreateFrame("Frame")
local rhBtn = CreateFrame("Button", "rhButton", nil,  "SecureActionButtonTemplate")

--------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------
-- Generate a list of valid toys
local function listGenerate()
	rhList = {}
	count = 0
	local covenantHearths = {
		-- {Criteria index, Covenant index, Covenant toy, Enabled}
		{1,1,184353,false}, --Kyrian
		{4,2,183716,false}, --Venthyr
		{3,3,180290,false}, --Night Fae
		{2,4,182773,false}  --Necrolord
	}
	for i,v in pairs(covenantHearths) do
		if select(3,GetAchievementCriteriaInfo(15646,v[1])) == true then
			covenantHearths[i][4] = true
		elseif C_Covenants.GetActiveCovenantID() ~= v[2] then
			rhCheckButtons[i].Text:SetText("  " .. rhToys[i][2] .. "  |cff777777(Renown locked)|r")
		end
	end

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
					if rhOptions[i][1] == v[3] then
						if v[4] == false and C_Covenants.GetActiveCovenantID() ~= v[2] then
							addToy = false
						elseif allCovenant == false and C_Covenants.GetActiveCovenantID() ~= v[2] then
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

-- Create or update global macro
local function updateMacro(name,icon)
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		local macroIndex = GetMacroIndexByName("Random Hearth")
		if macroIndex > 0 then
			EditMacro(macroIndex, "Random Hearth", icon, "#showtooltip " .. name .. src)
		else
			CreateMacro("Random Hearth", icon, "#showtooltip " .. name .. src, nil)
		end
	end
end

-- Set random Hearthstone
local function setRandom()
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) and #rhList > 0 then
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

-- Update Hearthstone selections when options panel closes
local function rhOptionsOkay()
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

--------------------------------------------------------------------
-- Button creation
--------------------------------------------------------------------
rhBtn:RegisterEvent("PLAYER_ENTERING_WORLD")
rhBtn:RegisterEvent("UNIT_SPELLCAST_STOP")
rhBtn:RegisterForClicks("LeftButtonDown", "LeftButtonUp" )
rhBtn:SetAttribute("type","toy")
rhBtn:SetScript("OnEvent", function(self,event, arg1)
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
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
-- Options panel
--------------------------------------------------------------------
rhOptionsPanel.name = "爐石"
rhOptionsPanel.OnCommit = function() rhOptionsOkay(); end
rhOptionsPanel.OnDefault = function() end
rhOptionsPanel.OnRefresh = function() end
local rhCategory = Settings.RegisterCanvasLayoutCategory(rhOptionsPanel, rhOptionsPanel.name)
rhCategory.ID = rhOptionsPanel.name
Settings.RegisterAddOnCategory(rhCategory)

-- Title
rhTitle:SetPoint("TOPLEFT", 10, -10)
rhTitle:SetWidth(SettingsPanel.Container:GetWidth()-35)
rhTitle:SetHeight(1)
rhTitle.text = rhTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhTitle.text:SetPoint("TOPLEFT", rhTitle, 0, 0)
rhTitle.text:SetText("隨機爐石")
rhTitle.text:SetFont("Fonts\\bLEI00D.ttf", 18)

-- Thanks
rhOptionsPanel.Thanks = rhOptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhOptionsPanel.Thanks:SetPoint("BOTTOMRIGHT",-5,5)
rhOptionsPanel.Thanks:SetText("感謝使用我的插件 :)\nNiian - Khaz'Goroth")
rhOptionsPanel.Thanks:SetFont("Fonts\\bLEI00D.ttf", 12)
rhOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
rhDesc:SetPoint("TOPLEFT", 20, -40)
rhDesc:SetWidth(SettingsPanel.Container:GetWidth()-35)
rhDesc:SetHeight(1)
rhDesc.text = rhDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDesc.text:SetPoint("TOPLEFT", rhDesc, 0, 0)
rhDesc.text:SetText("選擇要隨機使用的爐石玩具，然後將巨集 \"爐石\" 拉到快捷列上使用。")
rhDesc.text:SetFont("Fonts\\bLEI00D.ttf", 14)

-- Scroll Frame
rhOptionsScroll:SetPoint("TOPLEFT", 5, -60)
rhOptionsScroll:SetPoint("BOTTOMRIGHT", -25, 100)

-- Divider
rhDivider:SetStartPoint("BOTTOMLEFT", 20, -10)
rhDivider:SetEndPoint("BOTTOMRIGHT", 0, -10)
rhDivider:SetColorTexture(0.25,0.25,0.25,1)
rhDivider:SetThickness(1.2)

-- Scroll Frame child
rhOptionsScroll:SetScrollChild(rhScrollChild)
rhScrollChild:SetWidth(SettingsPanel.Container:GetWidth()-35)
rhScrollChild:SetHeight(1)

-- Checkbox for each toy
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
	rhCheckButtons[i].Text:SetFont("Fonts\\bLEI00D.ttf", 14)
end

-- Select All button
rhSelectAll:SetPoint("BOTTOMLEFT", 20, 50)
rhSelectAll:SetSize(100,25)
rhSelectAll:SetText("全選")
rhSelectAll:SetScript("OnClick", function(self)
	for i = 1, #rhToys do
		rhCheckButtons[i]:SetChecked(true)
	end
end)

-- Deselect All button
rhDeselectAll:SetPoint("BOTTOMLEFT", 135, 50)
rhDeselectAll:SetSize(100,25)
rhDeselectAll:SetText("取消全選")
rhDeselectAll:SetScript("OnClick", function(self)
	for i = 1, #rhToys do
		rhCheckButtons[i]:SetChecked(false)
	end
end)

-- Covenant override checkbox
rhOverride:SetPoint("BOTTOMLEFT", 20, 20)
rhOverride:SetSize(25,25)
rhOverride.Text:SetText("  只有啟用的誓盟")
rhOverride.Text:SetTextColor(1,1,1,1)
rhOverride.Text:SetFont("Fonts\\bLEI00D.ttf", 14)
rhOverride.Extratext = rhOverride:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhOverride.Extratext:SetPoint("TOPLEFT", rhOverride, 32, -25)
rhOverride.Extratext:SetText("勾選時，只會使用當前誓盟的爐石")
rhOverride.Extratext:SetFont("Fonts\\bLEI00D.ttf", 13)

rhListener:RegisterEvent("ADDON_LOADED")
rhListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addon then
		-- Set savedvariable defaults if first load or compare and update savedvariables with toy list
		if rhOverrideChk == nil then
			rhOverrideChk = true -- 更改預設值，只用誓盟爐石
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

--------------------------------------------------------------------
-- Create slash command
--------------------------------------------------------------------
SLASH_RandomHearthstone1 = "/rh"
function SlashCmdList.RandomHearthstone(msg, editbox)
Settings.OpenToCategory(rhCategory:GetID())
end

--[[
	Ignore this, it's for future me when Blizz breaks things again:
	/Interface/SharedXML/Settings/Blizzard_Settings.lua
]]