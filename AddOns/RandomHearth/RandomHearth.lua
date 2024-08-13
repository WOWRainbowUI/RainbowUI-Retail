--[[

██████╗  █████╗ ███╗   ██╗██████╗  ██████╗ ███╗   ███╗    ██╗  ██╗███████╗ █████╗ ██████╗ ████████╗██╗  ██╗███████╗████████╗ ██████╗ ███╗   ██╗███████╗
██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔═══██╗████╗ ████║    ██║  ██║██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██║  ██║██╔════╝╚══██╔══╝██╔═══██╗████╗  ██║██╔════╝
██████╔╝███████║██╔██╗ ██║██║  ██║██║   ██║██╔████╔██║    ███████║█████╗  ███████║██████╔╝   ██║   ███████║███████╗   ██║   ██║   ██║██╔██╗ ██║█████╗  
██╔══██╗██╔══██║██║╚██╗██║██║  ██║██║   ██║██║╚██╔╝██║    ██╔══██║██╔══╝  ██╔══██║██╔══██╗   ██║   ██╔══██║╚════██║   ██║   ██║   ██║██║╚██╗██║██╔══╝  
██║  ██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝██║ ╚═╝ ██║    ██║  ██║███████╗██║  ██║██║  ██║   ██║   ██║  ██║███████║   ██║   ╚██████╔╝██║ ╚████║███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝     ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝

If there's a new hearthstone but the addon isn't being updated simply add it to the bottom of the list below.
+ ItemID can be found from the URL of the item page on Wowhead.com
+ IconID can be found on the item page, by clicking the icon on the left and copying the ID field from the popup window.
+ Spaces in the table below are just for looks, the format is:

  {ItemID, "Item Name", IconID}, 

]]
-------------------------------------------------------------------------------------------------------------------------------------------------------
local rhToys = {
	{ 184353, "琪瑞安爐石",                     3257748 },
	{ 183716, "汎希爾爐石",                       3514225 },
	{ 180290, "暗夜妖精爐石",                  3489827 },
	{ 182773, "死靈領主爐石",                  3716927 },
	{ 54452,  "虛靈之門",                         236222 },
	{ 64488,  "旅店老闆的女兒",                458254 },
	{ 93672,  "黑暗之門",                             255348 },
	{ 142542, "城鎮傳送之書",                    1529351 },
	{ 162973, "冬天爺爺的爐石",       2124576 },
	{ 163045, "無頭騎士的爐石",        2124575 },
	{ 165669, "春節長者的爐石",              2491049 },
	{ 165670, "傳播者充滿愛的爐石",        2491048 },
	{ 165802, "復活節的爐石",           2491065 },
	{ 166746, "吞火者的爐石",               2491064 },
	{ 166747, "啤酒節狂歡者的爐石",         2491063 },
	{ 168907, "全像數位化爐石", 2491049 },
	{ 172179, "永恆旅者的爐石",         3084684 }, -- Icon for this might be incorrect?
	{ 193588, "時空漫遊者的爐石",               4571434 }, -- Icon for this might be incorrect?
	{ 188952, "統御的爐石",                  3528303 },
	{ 200630, "雍伊爾風之賢者爐石",          4080564 },
	{ 190237, "仲介者傳送矩陣",            3954409 },
	{ 190196, "受啟迪的爐石",                3950360 },
	{ 163206, "Weary Spirit Binding",                    135234 },
	{ 209035, "烈焰爐石",               2491064 },
	{ 208704, "深淵居者的大地爐石",      5333528 }, -- Icon for this might be incorrect?
	{ 206195, "那魯之道",                      1708140 },
	{ 212337, "爐石之石",                    5524923 },
	{ 210455, "德萊尼全像寶石",                        1686574 },
}

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW HERE
-- Unless you want to, I'm not your supervisor.

local rhList, count, macroIcon, macroName
local rhCheckButtons = {}
local addon = ...
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Frames
-------------------------------------------------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------
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
			rhCheckButtons[i].Text:SetText(rhToys[i][2] .. "  |cff777777(需要解鎖名望)|r")
		end
	end

	if select(4, GetAchievementInfo(15241)) == true then
		if rhDB.settings.covOverride == true then
			allCovenant = false
		else
			allCovenant = true
		end
	end

	for i = 1, #rhDB.chkStatus do
		if rhDB.chkStatus[i][2] == true then
			if PlayerHasToy(rhDB.chkStatus[i][1]) then
				local addToy = true
				-- Check for Covenant
				for _, v in pairs(covenantHearths) do
					if rhDB.chkStatus[i][1] == v[3] then
						if v[4] == false and C_Covenants.GetActiveCovenantID() ~= v[2] then
							addToy = false
						elseif allCovenant == false and C_Covenants.GetActiveCovenantID() ~= v[2] then
							addToy = false
							break
						end
					end
				end
				-- Check Draenai
				if rhDB.chkStatus[i][1] == 210455 then
					local _, _, raceID = UnitRace("player")
					if raceID ~= 11 or raceID ~= 30 then
						addToy = false
					end
				end
				-- Create the list
				if addToy == true then
					count = count + 1
					table.insert(rhList, rhDB.chkStatus[i][1])
				end
			end
		end
	end
end

-- Set random Hearthstone
local function setRandom()
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) and #rhList > 0 then
		local rnd = rhList[math.random(1, count)]
		for i = 1, #rhToys do
			if rnd == rhToys[i][1] then
				macroName = rhToys[i][2]
				macroIcon = rhToys[i][3]
			end
		end
		if rhDB.iconOverride.name ~= "隨機" then
			macroIcon = rhDB.iconOverride.id
		end
		rhBtn:SetAttribute("toy", macroName)
	end
end

-- Create or update global macro
local function updateMacro()
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		local macroText
		if #rhList == 0 then
			print("|cffFF0000沒有選擇有效的爐石玩具 -|r 將巨集設定為使用爐石")
			macroIcon = "134414"
			macroText = "#showtooltip 爐石\n/使用 爐石"
		else
			macroText = "#showtooltip " .. macroName .. "\n/stopcasting\n/click [btn:2]rhB 2;[btn:3]rhB 3;rhB"
		end
		local macroIndex = GetMacroIndexByName("爐石")
		if macroIndex > 0 then
			EditMacro(macroIndex, "爐石", macroIcon, macroText)
		else
			CreateMacro("爐石", macroIcon, macroText, nil)
		end
	end
end

-- Update Hearthstone selections when options panel closes
local function rhOptionsOkay()
	for i = 1, #rhDB.chkStatus do
		for _, v in pairs(rhDB.chkStatus) do
			if rhCheckButtons[i].ID == v[1] then
				v[2] = rhCheckButtons[i]:GetChecked()
			end
		end
	end
	rhDB.settings.covOverride = rhOverride:GetChecked()
	rhDB.settings.dalOpt = rhDalHearth:GetChecked()
	rhDB.settings.garOpt = rhGarHearth:GetChecked()
	listGenerate()
	setRandom()
	updateMacro()
end

-- Macro icon selection
local function rhDropDownOnClick(self, arg1)
	if arg1 == "隨機" then
		rhDB.iconOverride.name = "隨機"
		rhDB.iconOverride.id = 134400
	elseif arg1 == "爐石" then
		rhDB.iconOverride.name = "爐石"
		rhDB.iconOverride.id = 134414
	else
		rhDB.iconOverride.name = rhToys[arg1][2]
		rhDB.iconOverride.id = rhToys[arg1][3]
	end
	UIDropDownMenu_SetText(rhDropdown, rhDB.iconOverride.name)
	rhDropdown.Texture:SetTexture(rhDB.iconOverride.id)
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

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Button creation
-------------------------------------------------------------------------------------------------------------------------------------------------------
rhBtn:RegisterEvent("PLAYER_ENTERING_WORLD")
rhBtn:RegisterForClicks("AnyDown")
rhBtn:SetAttribute("pressAndHoldAction", true)
rhBtn:SetAttribute("type", "toy")
rhBtn:SetAttribute("typerelease", "toy")
rhBtn:SetScript("OnEvent", function(self, event, arg1)
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		if event == "PLAYER_ENTERING_WORLD" then
			listGenerate()
			setRandom()
			updateMacro()
		end
	end
end)
rhBtn:SetScript("PreClick", function(self, button, isDown)
	if not (InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		--if isDown ~= GetCVarBool("ActionButtonUseKeyDown") then return end
		if (button == "2" or button == "RightButton") and rhDB.settings.dalOpt then
			rhBtn:SetAttribute("toy", "Dalaran Hearthstone")
		elseif (button == "3" or button == "MiddleButton") and rhDB.settings.garOpt then
			rhBtn:SetAttribute("toy", "Garrison Hearthstone")
		else
			setRandom()
		end
	end
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Options panel
-------------------------------------------------------------------------------------------------------------------------------------------------------
rhOptionsPanel.name = "爐石"
rhOptionsPanel.OnCommit = function() rhOptionsOkay(); end
rhOptionsPanel.OnDefault = function() end
rhOptionsPanel.OnRefresh = function() end
local rhCategory = Settings.RegisterCanvasLayoutCategory(rhOptionsPanel, rhOptionsPanel.name)
rhCategory.ID = rhOptionsPanel.name
Settings.RegisterAddOnCategory(rhCategory)

-- Title
rhTitle:SetPoint("TOPLEFT", 10, -10)
rhTitle:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhTitle:SetHeight(1)
rhTitle.text = rhTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhTitle.text:SetPoint("TOPLEFT", rhTitle, 0, 0)
rhTitle.text:SetText("隨機爐石")
rhTitle.text:SetFont("Fonts\\bLEI00D.ttf", 18)

-- Thanks
rhOptionsPanel.Thanks = rhOptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhOptionsPanel.Thanks:SetPoint("BOTTOMRIGHT", -5, 5)
rhOptionsPanel.Thanks:SetText("感謝使用我的插件 :)\nNiian - Khaz'Goroth")
rhOptionsPanel.Thanks:SetFont("Fonts\\bLEI00D.ttf", 12)
rhOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
rhDesc:SetPoint("TOPLEFT", 20, -40)
rhDesc:SetWidth(SettingsPanel.Container:GetWidth() - 35)
rhDesc:SetHeight(1)
rhDesc.text = rhDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDesc.text:SetPoint("TOPLEFT", rhDesc, 0, 0)
rhDesc.text:SetText("選擇要隨機使用的爐石玩具，然後將巨集 \"爐石\" 拉到快捷列上使用。")
rhDesc.text:SetFont("Fonts\\bLEI00D.ttf", 14)

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
for i = 1, #rhToys do
	local chkOffset = 0
	if i > 1 then
		local _, _, _, _, yOffSet = rhCheckButtons[i - 1]:GetPoint()
		chkOffset = math.floor(yOffSet) + -26
	end
	rhCheckButtons[i] = CreateFrame("CheckButton", nil, rhScrollChild, "UICheckButtonTemplate")
	rhCheckButtons[i]:SetPoint("TOPLEFT", 15, chkOffset)
	rhCheckButtons[i]:SetSize(25, 25)
	rhCheckButtons[i].ID = rhToys[i][1]
	rhCheckButtons[i].Text:SetText(rhToys[i][2])
	rhCheckButtons[i].Text:SetTextColor(1, 1, 1, 1)
	rhCheckButtons[i].Text:SetFont("Fonts\\bLEI00D.ttf", 14)
	rhCheckButtons[i].Text:SetPoint("LEFT", 28, 0)
end

-- Select All button
rhSelectAll:SetPoint("TOPLEFT", rhSelectAll:GetParent(), "BOTTOMLEFT", 20, -20)
rhSelectAll:SetSize(100, 25)
rhSelectAll:SetText("全選")
rhSelectAll:SetScript("OnClick", function(self)
	for i = 1, #rhToys do
		rhCheckButtons[i]:SetChecked(true)
	end
end)

-- Deselect All button
rhDeselectAll:SetPoint("TOPLEFT", rhDeselectAll:GetParent(), "BOTTOMLEFT", 135, -20)
rhDeselectAll:SetSize(100, 25)
rhDeselectAll:SetText("取消全選")
rhDeselectAll:SetScript("OnClick", function(self)
	for i = 1, #rhToys do
		rhCheckButtons[i]:SetChecked(false)
	end
end)

-- Macro override dropdown
rhDropdown:SetPoint("TOPRIGHT", rhOverride:GetParent(), "BOTTOMRIGHT", 0, -20)
rhDropdown.Texture = rhDropdown:CreateTexture()
rhDropdown.Texture:SetSize(24, 24)
rhDropdown.Texture:SetPoint("LEFT", rhDropdown, "RIGHT", -10, 2)
rhDropdown.Extratext = rhDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rhDropdown.Extratext:SetFont("Fonts\\bLEI00D.ttf", 14)
rhDropdown.Extratext:SetText("巨集圖示")
rhDropdown.Extratext:SetPoint("RIGHT", rhDropdown, "LEFT", 10, 2)

-- Covenant override checkbox
rhOverride:SetPoint("TOPLEFT", rhOverride:GetParent(), "BOTTOMLEFT", 15, -50)
rhOverride:SetSize(25, 25)
rhOverride.Text:SetText(" 只使用玩家當前誓盟的爐石")
rhOverride.Text:SetTextColor(1, 1, 1, 1)
rhOverride.Text:SetFont("Fonts\\bLEI00D.ttf", 14)

-- Dalaran hearth checkbox
rhDalHearth:SetPoint("TOPLEFT", rhOverride, "BOTTOMLEFT", 0, 0)
rhDalHearth:SetSize(25, 25)
rhDalHearth.Text:SetText(" 右鍵點擊巨集使用達拉然爐石")
rhDalHearth.Text:SetTextColor(1, 1, 1, 1)
rhDalHearth.Text:SetFont("Fonts\\bLEI00D.ttf", 14)

-- Garrison hearth checkbox
rhGarHearth:SetPoint("TOPLEFT", rhDalHearth, "BOTTOMLEFT", 0, 0)
rhGarHearth:SetSize(25, 25)
rhGarHearth.Text:SetText(" 中鍵點擊巨集使用要塞爐石")
rhGarHearth.Text:SetTextColor(1, 1, 1, 1)
rhGarHearth.Text:SetFont("Fonts\\bLEI00D.ttf", 14)

-- Listener for addon loaded shenanigans
rhListener:RegisterEvent("ADDON_LOADED")
rhListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addon then
		-- Set savedvariable defaults if first load or compare and update savedvariables with toy list
		if rhDB == nil then
			print("正在設定隨機爐石資料庫變數")
			print("現在點右鍵會使用達拉然爐石，點中鍵會使用要塞爐石。")
			print("可以在設定中更改這些設定，請輸入 /rh")
			rhDB = {
				chkStatus = {}
			}
		end
		rhInitDB(rhDB, "settings", {})
		rhInitDB(rhDB.settings, "covOverride",false)
		rhInitDB(rhDB.settings, "dalOpt", true)
		rhInitDB(rhDB.settings, "garOpt", true)
		rhInitDB(rhDB, "iconOverride", {name = "隨機", id = 134400})

		-- Transfer old settings
		if rhOptions ~= nil then
			if type(rhOptions[1][1] == "number") and type(rhOptions[1][2] == "boolean") then
				print("正在將舊的隨機爐石變數更新成新的資料庫格式")
				for i = 1, #rhOptions do
					table.insert(rhDB.chkStatus, { rhOptions[i][1], rhOptions[i][2] })
				end
			end
		end

		-- Add all toy IDs to savedvariables as enabled
		if rhDB.chkStatus == nil or #rhDB.chkStatus == 0 then
			rhDB.chkStatus = {}
			for i = 1, #rhToys do
				rhDB.chkStatus[i] = { rhToys[i][1], true }
			end
		end

		-- Remove IDs that no longer exist in rhToys list
		for i, v in pairs(rhDB.chkStatus) do
			local chk = 0
			for l = 1, #rhToys do
				if v[1] == rhToys[l][1] then
					chk = 1
				end
			end
			if chk == 0 then
				rhDB.chkStatus[i] = nil
			end
		end

		-- Add any new IDs to saved variables as enabled
		for i, v in pairs(rhToys) do
			local chk = 0
			for l = 1, #rhDB.chkStatus do
				if v[1] == rhDB.chkStatus[l][1] then
					chk = 1
				end
			end
			if chk == 0 then
				table.insert(rhDB.chkStatus, { v[1], true })
			end
		end

		-- Loop through options and set checkbox state
		for i, v in pairs(rhDB.chkStatus) do
			for l = 1, #rhDB.chkStatus do
				if rhCheckButtons[l].ID == v[1] and v[2] == true then
					rhCheckButtons[l]:SetChecked(true)
				end
			end
		end
		rhOverride:SetChecked(rhDB.settings.covOverride)
		rhDalHearth:SetChecked(rhDB.settings.dalOpt)
		rhGarHearth:SetChecked(rhDB.settings.garOpt)
		rhDropdown.Texture:SetTexture(rhDB.iconOverride.id)
		UIDropDownMenu_SetText(rhDropdown, rhDB.iconOverride.name)
		UIDropDownMenu_SetWidth(rhDropdown, 200)
		UIDropDownMenu_SetAnchor(rhDropdown, 0, 0, "BOTTOM", rhDropdown, "TOP")
		UIDropDownMenu_Initialize(rhDropdown, function(self)
			local info = UIDropDownMenu_CreateInfo()
			info.func, info.topPadding, info.tSizeX, info.tSizeY = rhDropDownOnClick, 3, 15, 15
			info.arg1, info.text, info.checked, info.icon = "隨機", "隨機", rhDB.iconOverride.name == "隨機",
				134400
			UIDropDownMenu_AddButton(info)
			info.arg1, info.text, info.checked, info.icon = "爐石", "爐石",
				rhDB.iconOverride.name == "爐石", 134414
			UIDropDownMenu_AddButton(info)
			for i = 1, #rhToys do
				info.arg1, info.text, info.checked, info.icon = i, rhToys[i][2], rhDB.iconOverride.name == rhToys[i][2],
					rhToys[i][3]
				UIDropDownMenu_AddButton(info)
			end
		end)

		self:UnregisterEvent("ADDON_LOADED")
	end
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create slash command
-------------------------------------------------------------------------------------------------------------------------------------------------------
SLASH_RandomHearthstone1 = "/rh"
function SlashCmdList.RandomHearthstone(msg, editbox)
	Settings.OpenToCategory(rhCategory:GetID())
end

--[[
	Ignore this, it's for future me when Blizz breaks things again:
	/Interface/SharedXML/Settings/Blizzard_Settings.lua
]]
