--- Kaliel's Tracker
--- Copyright (c) 2012-2023, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_Help")
KT.Help = M

local T = LibStub("MSA-Tutorials-1.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"
local helpPath = mediaPath.."Help\\"
local helpName = "help"
local helpNumPages = 12
local supportersName = "supporters"
local supportersNumPages = 1
local cTitle = "|cffffd200"
local cBold = "|cff00ffe3"
local cWarning = "|cffff7f00"
local cWarning2 = "|cffff4200"
local cDots = "|cff808080"
local offs = "\n|T:1:9|t"
local offs2 = "\n|T:1:18|t"
local beta = "|cffff7fff[Beta]|r"
local new = "|cffff7fff[新功能]|r"

local KTF = KT.frame

--------------
-- Internal --
--------------

local function AddonInfo(name)
	local info = "\n插件 "..name
	if IsAddOnLoaded(name) then
		info = info.." |cff00ff00已安裝|r。可以在設定選項中啟用/停用支援插件。"
	else
		info = info.." |cffff0000未安裝|r。"
	end
	return info
end

local function SetFormatedPatronName(tier, name, realm, note)
	if realm then
		realm = " @"..realm
	else
		realm = ""
	end
	if note then
		note = " ... "..note
	else
		note = ""
	end
	return format("- |cff%s%s|r|cff7f7f7f%s%s|r\n", KT.QUALITY_COLORS[tier], name, realm, note)
end

local function SetFormatedPlayerName(name, realm, note)
	if realm then
		realm = " @"..realm
	else
		realm = ""
	end
	if note then
		note = " ... "..note
	else
		note = ""
	end
	return format("- %s|cff7f7f7f%s%s|r\n", name, realm, note)
end

local function SetupTutorials()
	T.RegisterTutorial(helpName, {
		savedvariable = KT.db.global,
		key = "helpTutorial",
		title = KT.title.." |cffffffff"..KT.version.."|r",
		icon = helpPath.."KT_logo",
		font = "Fonts\\bLEI00D.ttf",
		width = 552,
		imageHeight = 256,
		{	-- 1
			image = helpPath.."help_kaliels-tracker",
			text = cTitle..KT.title.."|r 以遊戲預設的任務追蹤清單為基礎，並且增強它的功能。\n\n"..
					"包含下面這些功能:\n"..
					"- 更改追蹤清單位置\n"..
					"- 根據追蹤清單位置 (方向) 展開/收起追蹤清單\n"..
					"- 根據內容自動調整追蹤清單高度，可以限制最大高度\n"..
					"- 內容較多，超出最大高度時可以捲動\n"..
					"- 登出/結束遊戲時會記憶收起的追蹤清單狀態\n\n"..
					"... 還有更多其他增強功能 (請繼續看下一頁)。",
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 2
			image = helpPath.."help_header-buttons",
			imageHeight = 128,
			text = cTitle.."標題列按鈕|r\n\n"..
					"最小化按鈕:                                其他按鈕:\n"..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:0:14:209:170:0|t "..cDots.."...|r 展開追蹤清單                    "..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:4:2:32:64:16:30:0:14:209:170:0|t  "..cDots.."...|r 開啟任務日誌\n"..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:16:30:209:170:0|t "..cDots.."...|r 收起追蹤清單                    "..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:4:2:32:64:16:30:16:30:209:170:0|t  "..cDots.."...|r 開啟成就視窗\n"..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:32:46:209:170:0|t "..cDots.."...|r 追蹤清單是空的時候         "..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:4:2:32:64:16:30:32:46:209:170:0|t  "..cDots.."...|r 開啟過濾方式選單\n\n"..
					"按鈕 |T"..mediaPath.."UI-KT-HeaderButtons:14:14:0:2:32:64:16:30:0:14:209:170:0|t 和 "..
					"|T"..mediaPath.."UI-KT-HeaderButtons:14:14:0:2:32:64:16:30:16:30:209:170:0|t 可以在設定選項中停用。\n\n"..
					"可以設定"..cBold.." [快速鍵]|r 來最小化追蹤清單。\n"..
					cBold.."Alt+左鍵|r 點擊最小化按鈕會開啟 "..KT.title.."的設定選項。",
			textY = 16,
			shine = KTF.MinimizeButton,
			shineTop = 13,
			shineBottom = -14,
			shineRight = 16,
		},
		{	-- 3
			image = helpPath.."help_quest-title-tags",
			imageHeight = 128,
			text = cTitle.."特殊文字標籤|r\n\n"..
					"任務標題的前方可以看到像是這樣的標籤 |cffff8000[100|r|cff00b3ffhc!|r|cffff8000]|r。\n"..
					"任務日誌中的標題也會顯示任務標籤。\n\n"..
					"|cff00b3ff!|r|T:14:3|t "..cDots..".......|r 每日任務|T:14:104|t|cff00b3ffr|r "..cDots.."........|r 團隊任務\n"..
					"|cff00b3ff!!|r "..cDots.."........|r 每週任務|T:14:100|t|cff00b3ffr10|r "..cDots.."....|r 10人團隊任務\n"..
					"|cff00b3ffg3|r "..cDots..".....|r 組隊任務 (含隊伍人數)|T:14:18|t|cff00b3ffr25|r "..cDots.."...|r 25人團隊任務\n"..
					"|cff00b3ffpvp|r "..cDots.."...|r PvP 任務|T:14:98|t|cff00b3ffs|r "..cDots.."........|r 事件任務\n"..
					"|cff00b3ffd|r "..cDots..".......|r 地城任務|T:14:101|t|cff00b3ffa|r "..cDots.."........|r 帳號共通任務\n"..
					"|cff00b3ffhc|r "..cDots..".....|r 英雄任務|T:14:102|t|cff00b3ffleg|r "..cDots..".....|r 傳說任務",
			shineTop = 10,
			shineBottom = -9,
			shineLeft = -12,
			shineRight = 10,
		},
		{	-- 4
			image = helpPath.."help_tracker-filters",
			text = cTitle.."任務過濾|r\n\n"..
					"要開啟過濾方式選單請"..cBold.."點一下|r這個按鈕 |T"..mediaPath.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:32:46:209:170:0|t。\n\n"..
					"過濾方式分為兩種類型:\n"..
					cTitle.."固定過濾|r - 依據規則 (例如 \"每日\") 可以手動新增/移除項目。\n"..
					cTitle.."動態過濾|r - 自動新增任務/成就依據條件 (例如 \"|cff00ff00自動|r區域\") "..
					"會持續更新項目。這種類型不允許手動加入/移除項目。"..
					"啟用動態過濾時，標題按鈕是綠色 |T"..mediaPath.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:32:46:0:255:0|t.\n\n"..
					"|cff009bff最愛|r - 現在可以將任務或成就加入最愛，然後使用這種過濾方式。\n\n"..
					"更改成就的搜尋類別時，也會影響過濾的結果。\n\n"..
					"這個選單也會顯示影響追蹤清單內容的其他選項 (例如 戰寵助手插件 PetTracker 所使用的選項)。",
			textY = 16,
			shine = KTF.FilterButton,
			shineTop = 10,
			shineBottom = -11,
			shineLeft = -10,
			shineRight = 11,
		},
		{	-- 5
			image = helpPath.."help_quest-item-buttons",
			text = cTitle.."任務物品按鈕|r\n\n"..
					"按鈕在任務追蹤清單外面，因為暴雪不允許預設的清單介面使用動作按鈕。\n\n"..
					"|T"..helpPath.."help_quest-item-buttons_2:32:32:1:0:64:32:0:32:0:32|t "..cDots.."...|r  這個標籤代表任務中的任務物品。裡面的數字用來辨別\n"..
					"                移動後的任務物品按鈕。\n\n"..
					"|T"..helpPath.."help_quest-item-buttons_2:32:32:0:3:64:32:32:64:0:32|t "..cDots.."...|r  真正的任務物品按鈕已經移動到清單的左/右側\n"..
					"               (依據所選擇的對齊畫面位置)。標籤數字仍然相同。\n\n"..
					cWarning.."特別注意:|r\n"..
					"在某些戰鬥中，任務物品按鈕的動作會被暫停，直到戰鬥結束後才能使用。",
			shineTop = 3,
			shineBottom = -2,
			shineLeft = -4,
			shineRight = 3,
		},
		{	-- 6
			image = helpPath.."help_active-button",
			text = cTitle.."大型任務物品按鈕|r\n\n"..
					"大型任務物品按鈕提供任務物品較佳的使用方式。將 '距離最近' 的任務的物品顯示為額外快捷鍵。(類似德拉諾的要塞技能)\n\n"..
					"功能:\n"..
					"- "..cBold.."接近可以使用任務物品的地方時"..
					offs.."自動顯示|r大型任務物品按鈕。\n"..
					"- "..cBold.."點選地圖上或任務追蹤清單旁的 POI 按鈕可以"..
					offs.."手動顯示|r大型任務物品按鈕。\n"..
					"- 可以設定"..cBold.." [快速鍵]|r 來使用任務物品，請在設定選項中指定要綁定的按鍵。"..
					offs.."大型任務物品按鈕使用和額外快捷鍵相同的按鍵綁定。\n"..
					"- 要移動按鈕請到設定選項 > \"任務物品"..
					"按鈕\" > 按下 \"解鎖\" 後便可移動。\n\n"..
					cWarning.."特別注意:|r\n"..
					"- 只有已經追蹤的任務才能使用大型任務物品按鈕。\n"..
					"- 追蹤清單收合起來的時候，會一併暫停大型任務物品按鈕的功能。",
			shineTop = 30,
			shineBottom = -30,
			shineLeft = -80,
			shineRight = 80,
		},
		{	-- 7
			image = helpPath.."help_tracker-modules",
			text = cTitle.."模組順序|r\n\n"..
					"允許更改模組在追蹤清單中的順序。支援所有的模組，也包含外部插件 (例如：戰寵助手)。\n\n\n"..
					cTitle.."可收合的模組|r\n\n"..
					"所有模組，包含外部插件的，都可以點一下模組標題收合起來。",
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 8
			image = helpPath.."help_addon-masque",
			text = cTitle.."支援插件: 按鈕外觀 - Masque|r\n\n"..
					"Masque 提供更改任務物品按鈕外觀的功能，同時也會影響大型任務物品按鈕 (請看上一頁)。\n"..
					AddonInfo("Masque"),
		},
		{	-- 9
			image = helpPath.."help_addon-pettracker",
			text = cTitle.."支援插件: 戰寵助手 - PetTracker|r\n\n"..
					"支援在任務追蹤清單增強裡面顯示 PetTracker 的區域寵物追蹤，同時也修正了顯示上的一些問題。\n"..
					AddonInfo("PetTracker"),
		},
		{	-- 10
			image = helpPath.."help_addon-tomtom",
			text = cTitle.."支援插件: 箭頭導航 - TomTom|r\n\n"..
					"TomTom 的支援性整合了暴雪的 POI 和 TomTom 的導航箭頭。\n\n"..
					"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:0:256:256:128:160:96:128|t+"..
					"|T"..mediaPath.."KT-TomTomTag:32:32:-8:0|t"..cDots.."...|r   點一下任務的 POI 按鈕來使用 TomTom 導航。\n \n"..
					"功能:\n"..
					"- 一般任務和世界任務都可以使用，但是只有目前區域的任務才能導航!|r "..
					offs.." (這是 TomTom 和暴雪的功能限制)\n"..
					"- "..cBold.."點一下|r (任務清單中或是世界地圖上的) POI 按鈕會顯示該任務的"..
					offs.."路線導航箭頭。\n"..
					"- 新追蹤或最靠近的任務會自動顯示路線導航。\n"..
					"- 取消追蹤或放棄任務時會移除導航。\n"..
					AddonInfo("TomTom"),
			shineTop = 10,
			shineBottom = -10,
			shineLeft = -11,
			shineRight = 11,
		},
		{	-- 11
			text = cTitle.."         駭入|r\n\n"..
					cWarning.."警告:|r 駭入功能可能會影響其他插件!\n\n"..
					cTitle.."駭入尋求組隊|r\n\n"..
					cBold.."影響在任務追蹤清單中尋找隊伍用的小眼睛。|r"..
					"啟用駭客功能時按鈕可以正常使用，不會發生錯誤。停用時將無法使用按鈕。\n\n"..
					cWarning2.."負面|r影響:\n"..
					"- 建立預組隊伍的對話框中會隱藏 \"目標\" 項目。\n"..
					"- 預組隊伍列表中項目的滑鼠提示會隱藏第二行 (綠色) 的 \"目標\"。\n"..
					"- 建立預組隊伍的對話框不會自動設定好 \"標題\"，"..
					offs.."  例如 M+ 鑰石層數。\n\n"..
					"預設會啟用尋求組隊駭客功能，可以在任務追蹤清單增強的設定選項 (\"駭入\") 中停用。",
			textY = -20,
		},
		{	-- 12
			text = cTitle.."         更新資訊|r\n\n"..
					cTitle.."6.4.0 版本|r\n"..
					"- 新增 - 支援魔獸世界 10.1.7\n"..
                    "- 修正 - 選項 - Masque 按鈕\n"..
                    "- 更新 - 支援插件 - Masque 10.1.7\n"..
                    "- 更新 - 支援插件 - ElvUI 13.40, Tukui 20.38\n"..
                    "- 更新 - 支援插件 - SpartanUI 6.2.21\n"..
                    "- 更新 - 函式庫\n\n"..

					cTitle.."WoW 10.1.7 - 尚無解決方法的已知問題|r\n"..
					"- 戰鬥中點擊追蹤的任務或成就不會有反應。\n"..
					"- 戰鬥中標題列的 Q 和 A 按鈕無法運作。\n\n"..

					cTitle.."回報問題|r\n"..
					"請使用下方的"..cBold.."回報單網址|r而不是在 CurseForge 留言。\n\n\n\n"..

					cWarning.."回報錯誤之前，請先停用所有其他的插件，以確保不是和其他插件相衝突。|r",
			textY = -20,
			editbox = {
				{
					text = "https://www.curseforge.com/wow/addons/kaliels-tracker/issues",
					width = 450,
					bottom = 25,
				}
			},
			shine = KTF,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		onShow = function(self, i)
			if dbChar.collapsed then
				KT:MinimizeButton_OnClick(true)
			end
			if i == 2 then
				if KTF.FilterButton then
					self[i].shineLeft = db.hdrOtherButtons and -75 or -35
				else
					self[i].shineLeft = db.hdrOtherButtons and -55 or -15
				end
			elseif i == 3 then
				local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(1)
				local block = KT_QUEST_TRACKER_MODULE:GetExistingBlock(questID)
				if block then
					self[i].shine = block
				end
			elseif i == 5 then
				self[i].shine = KTF.Buttons
			elseif i == 10 then
				for j=1, C_QuestLog.GetNumQuestWatches() do
					local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(j)
					local block = KT_QUEST_TRACKER_MODULE:GetExistingBlock(questID)
					if block and (QuestHasPOIInfo(questID) or block.questCompleted) then
						self[i].shine = KT_ObjectiveTrackerFrame.BlocksFrame:FindButtonByQuestID(questID)
						break
					end
				end
			end
		end,
		onHide = function()
			T.TriggerTutorial("supporters", 1)
		end
	})

	T.RegisterTutorial("supporters", {
		savedvariable = KT.db.global,
		key = "supportersTutorial",
		title = KT.title.." |cffffffff"..KT.version.."|r",
		icon = helpPath.."KT_logo",
		font = "Fonts\\bLEI00D.ttf",
		width = 552,
		imageHeight = 256,
		{	-- 1
			text = cTitle.."         成為贊助者|r\n\n"..
					"如果你喜歡 "..KT.title.."，請在 |cfff34a54Patreon|r 贊助我。\n\n"..
					"在 CurseForge 的插件頁面點一下 |T"..helpPath.."help_patreon:20:154:1:0:256:32:0:156:0:20|t 按鈕。\n\n"..
					"經過了 10 年的插件工作後，我啟用了 Patreon，當作是開發插件所需時間的補償。\n\n"..
					"                                    非常感謝所有贊助者  |T"..helpPath.."help_patreon:16:16:0:0:256:32:157:173:0:16|t\n\n"..
					cTitle.."Patrons|r\n"..
					SetFormatedPatronName("Legendary", "FrankN'Furter")..
					SetFormatedPatronName("Legendary", "Zayah", "Vek'nilash")..
					SetFormatedPatronName("Epic", "Haekwon", "Elune")..
					SetFormatedPatronName("Epic", "Monty", "Winterhoof")..
					SetFormatedPatronName("Epic", "Squishses", "Area 52")..
					SetFormatedPatronName("Rare", "Liothen", "Emerald Dream")..
					SetFormatedPatronName("Uncommon", "Anaara", "Auchindoun")..
					SetFormatedPatronName("Uncommon", "Charles Howarth")..
					SetFormatedPatronName("Uncommon", "Chris J")..
					SetFormatedPatronName("Uncommon", "Flex (drantor)")..
					SetFormatedPatronName("Uncommon", "Jason")..
					SetFormatedPatronName("Uncommon", "Kevin Costa")..
					SetFormatedPatronName("Uncommon", "Kyle Fuller")..
					SetFormatedPatronName("Uncommon", "Pablo Sebastián Molina Silva")..
					SetFormatedPatronName("Uncommon", "Semy", "Ravencrest")..
					SetFormatedPatronName("Uncommon", "Sopleb")..
					SetFormatedPatronName("Uncommon", "Torresman", "Drak'thul")..
					SetFormatedPatronName("Uncommon", "Xeelee", "Razorfen")..
					SetFormatedPatronName("Common", "Darren Divecha")..
					"\n"..
					cTitle.."Testers|r\n"..
					SetFormatedPlayerName("Asimeria", "Drak'thul")..
					SetFormatedPlayerName("Torresman", "Drak'thul"),
			textY = -20,
		},
	})
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00初始化|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
end

function M:OnEnable()
	_DBG("|cff00ff00啟用|r - "..self:GetName(), true)
	SetupTutorials()
	local last = false
	if KT.version ~= KT.db.global.version then
		local data = T.GetTutorial(helpName)
		local index = data.savedvariable[data.key]
		if index then
			last = index < helpNumPages and index or true
			T.ResetTutorial(helpName)
		end
	end
	T.TriggerTutorial(helpName, helpNumPages, last)
end

function M:ShowHelp(index)
	HideUIPanel(SettingsPanel)
	T.ResetTutorial(helpName)
	T.TriggerTutorial(helpName, helpNumPages, index or false)
end

function M:ShowSupporters()
	HideUIPanel(SettingsPanel)
	T.ResetTutorial(supportersName)
	T.TriggerTutorial(supportersName, supportersNumPages)
end