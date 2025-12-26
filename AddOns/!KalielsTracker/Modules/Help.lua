--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Help
local M = KT:NewModule("Help")
KT.Help = M

local T = LibStub("MSA-Tutorials-1.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local HELP_TITLE = KT.TITLE.." |cffffffff"..KT.VERSION.."|r"
local HELP_PATH = KT.MEDIA_PATH.."Help\\"
local ICON_URL = HELP_PATH.."help_icon-url"
local ICON_HEART = "|T"..HELP_PATH.."help_patreon:14:14:2:0:256:32:174:190:0:16|t"

local db, dbChar
local helpName = "help"
local helpNumPages = 15
local supportersName = "supporters"
local supportersNumPages = 1
local cTitle = "|cffffd200"
local cBold = "|cff00ffe3"
local cWarning = "|cffff7f00"
local cWarning2 = "|cffff4200"
local cDots = "|cff808080"
local offs = "\n|T:1:9|t"
local offs2 = "\n|T:1:21|t"
local ebSpace = "|T:16:1|t\n"
local beta = "|cffff7fff[Beta]|r"
local new = "|cffff7fff[新功能]|r"

local KTF = KT.frame

-- Internal ------------------------------------------------------------------------------------------------------------

local function AddonInfo(name)
	local info = "\n插件 "..name
	if C_AddOns.IsAddOnLoaded(name) then
		info = info.." |cff00ff00已安裝|r。支援性可以在設定選項中啟用/停用。\n"..ebSpace
	else
		info = info.." |cffff0000未安裝|r。\n"..ebSpace
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
		title = HELP_TITLE,
		icon = HELP_PATH.."KT_logo",
		font = "Fonts\\bLEI00D.ttf",
		width = 582,
		height = 620,
		paddingX = 35,
		paddingTop = 26,
		paddingBottom = 24,
		imageWidth = 512,
		imageHeight = 256,
		{	-- 1
			image = HELP_PATH.."help_kaliels-tracker",
			text = cTitle..KT.TITLE.."|r 以遊戲預設的任務追蹤清單為基礎，並且增強它的功能。\n\n"..
					"包含下面這些功能:\n"..
					"- 更改追蹤清單位置\n"..
					"- 根據追蹤清單位置 (方向) 展開/收起追蹤清單\n"..
					"- 根據內容自動調整追蹤清單高度，可以限制最大高度\n"..
					"- 內容較多，超出最大高度時可以捲動\n"..
					"- 登出/結束遊戲時會記憶收起的追蹤清單狀態\n\n"..
					"... 還有更多其他增強功能 (請繼續看下一頁)。",
			shine = KTF.Background,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 2
			image = HELP_PATH.."help_header-buttons",
			imageHeight = 128,
			heading = "標題列按鈕",
			text = "最小化按鈕:                                其他按鈕:\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:0:14:209:170:0|t "..cDots.."...|r 展開追蹤清單                     "..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:0:14:209:170:0|t "..cDots.."...|r 打開任務日誌\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:16:30:209:170:0|t "..cDots.."...|r 收起追蹤清單                     "..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:16:30:209:170:0|t "..cDots.."...|r 打開成就視窗\n"..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:0:14:32:46:209:170:0|t "..cDots.."...|r 追蹤清單是空的時候          "..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:32:46:209:170:0|t "..cDots.."...|r 打開過濾方式選單\n\n"..
					"按鈕 |T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:0:14:209:170:0|t 和 "..
					"|T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:2:32:64:16:30:16:30:209:170:0|t 可以在設定選項中停用。\n\n"..
					"可以設定 "..cBold.."[按鍵綁定]|r 來最小化追蹤清單。\n"..
					cBold.."右鍵點擊|r 最小化按鈕 - 將最近的任務設為焦點。\n"..
					cBold.."Alt+左鍵|r 點擊最小化按鈕會開啟 "..KT.TITLE.." 的設定選項。",
			paddingBottom = 18,
			shine = KTF.MinimizeButton,
			shineTop = 13,
			shineBottom = -14,
			shineRight = 15,
		},
		{	-- 3
			image = HELP_PATH.."help_quest-title-tags",
			imageHeight = 128,
			heading = "任務標題標籤",
			text = "任務標題的前方可以看到像是這樣的標籤 |cffff8000[100|r|cff00b3ffhc!|r|cffff8000]|r。\n"..
					"任務日誌中的標題也會顯示任務標籤。\n\n"..
					"|cff00b3ff!|r|T:14:3|t "..cDots.."........|r 每日任務|T:14:108|t|cff00b3ffr|r "..cDots..".......|r 團隊任務\n"..         -- Kept new icons
					"|cff00b3ff!!|r "..cDots.."........|r 每週任務|T:14:108|t|cff00b3ffr10|r "..cDots.."...|r 10人團隊任務\n"..     -- Kept new icons
					"|cff00b3ffg3|r "..cDots..".....|r 組隊任務 (含隊伍人數)|T:14:30|t|cff00b3ffr25|r "..cDots.."...|r 25人團隊任務\n".. -- Kept new icons
					"|cff00b3ffpvp|r "..cDots.."...|r PvP 任務|T:14:112|t|cff00b3ffs|r "..cDots..".......|r 事件任務\n"..         -- Kept new icons (Scenario -> Event translation kept from old)
					"|cff00b3ffd|r "..cDots..".......|r 地城任務|T:14:109|t|cff00b3ffa|r "..cDots..".......|r 帳號共通任務\n"..     -- Kept new icons
					"|cff00b3ffhc|r "..cDots..".....|r 英雄任務|T:14:109|t|cff00b3ffleg|r "..cDots.."....|r 傳說任務", -- Kept new icons
			paddingBottom = 16,
			shineTop = 11,
			shineBottom = -9,
			shineLeft = -11,
			shineRight = 13,
		},
		{	-- 4
			image = HELP_PATH.."help_tracker-filters",
			heading = "任務過濾",
			text = "要開啟過濾方式選單請"..cBold.."點一下|r這個按鈕 |T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:1:32:64:16:30:32:46:209:170:0|t.\n\n".. -- Kept new icon reference
					"過濾方式分為兩種類型:\n"..
					cTitle.."固定過濾|r - 依據規則 (例如 \"每日\") 加入要追蹤的任務/成就，並且可以手動新增/移除項目。\n"..
					cTitle.."動態過濾|r - 自動依據規則加入要追蹤的任務/成就 (例如 \"|cff00ff00自動|r區域\") "..
					"並且會持續更新項目。這種類型不允許手動加入/移除項目。"..
					"啟用動態過濾時，標題按鈕是綠色 |T"..KT.MEDIA_PATH.."UI-KT-HeaderButtons:14:14:-1:1:32:64:16:30:32:46:0:255:0|t.\n\n".. -- Kept new icon reference
					"|cff009bff最愛|r - 現在可以將任務或成就加入最愛，然後使用這種過濾方式。\n\n"..
					"更改成就的搜尋類別時，也會影響過濾的結果。\n\n"..
					"這個選單也會顯示影響追蹤清單內容的其他選項 (例如 戰寵助手插件 PetTracker 所使用的選項)",
			shine = KTF.FilterButton,
			shineTop = 9,
			shineBottom = -10,
			shineLeft = -10,
			shineRight = 11,
		},
		{	-- 5
			image = HELP_PATH.."help_quest-item-buttons",
			heading = "任務物品按鈕",
			text = "按鈕在任務追蹤清單外面，因為暴雪不允許預設的清單介面使用動作按鈕。\n\n"..
					"|T"..HELP_PATH.."help_quest-item-buttons_2:32:32:1:0:64:32:0:32:0:32|t "..cDots.."...|r  這個標籤代表任務中的任務物品。裡面的數字用來辨別\n"..
					"              移動後的任務物品按鈕。\n\n"..
					"|T"..HELP_PATH.."help_quest-item-buttons_2:32:32:0:3:64:32:32:64:0:32|t "..cDots.."...|r  真正的任務物品按鈕已經移動到清單的左/右側\n"..
					"              (依據所選擇的對齊畫面位置)。標籤數字仍然相同。\n\n"..
					cWarning.."特別注意:|r\n"..
					"在某些戰鬥中，任務物品按鈕的動作會被暫停，直到戰鬥結束後才能使用。",
			shineTop = 3,
			shineBottom = -2,
			shineLeft = -4,
			shineRight = 3,
		},
		{	-- 6
			image = HELP_PATH.."help_active-button",
			heading = "當前任務物品按鈕",
			text = "當前任務物品按鈕提供任務物品較佳的使用方式。將 '距離最近' 的任務的物品顯示為額外快捷鍵。(類似德拉諾的要塞技能)\n\n"..
					"功能:\n"..
					"- "..cBold.."接近可以使用任務物品的地方時"..
					offs.."自動顯示|r當前任務物品按鈕。\n"..
					"- "..cBold.."點選地圖上或任務追蹤清單旁的 POI 按鈕可以"..
					offs.."手動顯示|r當前任務物品按鈕。\n"..
					"- 可以設定"..cBold.." [快速鍵]|r 來使用任務物品，請在設定選項中指定要綁定的按鍵。"..
					offs.."當前任務物品按鈕使用和額外快捷鍵相同的按鍵綁定。\n"..
					"- 要移動按鈕請到設定選項 > \"任務物品"..
					offs.."按鈕\" > 按下 \"解鎖\" 後便可移動。\n\n"..
					cWarning.."特別注意:|r\n"..
					"- 只有已經追蹤的任務才能使用當前任務物品按鈕。\n"..
					"- 追蹤清單收合起來的時候，會一併暫停當前任務物品按鈕的功能。",
			shineTop = 30,
			shineBottom = -30,
			shineLeft = -80,
			shineRight = 80,
		},
		{	-- 7
			image = HELP_PATH.."help_tracker-modules",
			heading = "模組",
			text = cTitle.."模組順序|r\n\n"..
					"允許更改模組在追蹤清單中的順序。支援所有模組，也包含外部插件 (例如：戰寵助手)。\n\n\n"..
					cTitle.."可收合的模組|r\n\n"..
					"所有模組，包含外部插件的，都可以點一下模組標題收合起來。",
			shine = KTF.Background,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		{	-- 8
			heading = "         遊戲修正",
			text = "預設會啟用所有遊戲修正，可以在 "..KT.TITLE.." 的設定選項 (\"遊戲修正\") 中停用。\n\n"..
					cWarning.."警告:|r 遊戲修正可能會影響其他插件!!\n\n"..
					cTitle.."尋求組隊修正|r\n\n"..
					cBold.."影響在任務追蹤清單中尋找隊伍用的小眼睛。|r"..
					"啟用遊戲修正時按鈕可以正常使用，不會發生錯誤。停用時將無法使用按鈕。\n\n"..
					cWarning2.."負面影響:|r\n"..
					"- 建立預組隊伍的對話框不會自動設定好 \"標題\"，"..
					offs.."例如 M+ 鑰石層數。\n\n"..
					cTitle.."世界地圖修正|r "..beta.."\n\n"..
					cBold.."影響世界地圖|r並且移除汙染錯誤。"..
					"這個遊戲修正避免呼叫受限制的函數。"..
					"停用遊戲修正時，世界地圖顯示會導致錯誤。"..
					"由於任務追蹤清單與遊戲框架有很多互動，所以無法消除這些錯誤。\n\n"..
					cWarning2.."負面影響:|r 在魔獸世界 11.2.7 尚未可知。",
		},
		{	-- 9
			image = HELP_PATH.."help_events",
			heading = "事件",
			text = "事件模組會在追蹤清單中顯示當前進行中的事件。它們通常可在世界地圖上看到。\n\n"..
					"過濾下拉選單選項：\n"..
					"- "..cBold.."追蹤事件|r – 啟用或停用在追蹤清單中追蹤事件。\n"..
					"- "..cBold.."顯示長期事件|r – 除了當前進行中的事件，還會顯示那些"..
					offs.."持續 24 小時或更久的事件。",
		},

		{	-- 10
			image = HELP_PATH.."help_addon-masque",
			heading = "支援插件 Masque",
			text = "Masque 提供更改任務物品按鈕外觀的功能，同時也會影響當前任務物品按鈕 (請看上一頁)。\n".. -- Combined translation
					AddonInfo("Masque"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/masque",
					width = 510,
					bottom = 2,
				}
			},
		},
		{	-- 11
			image = HELP_PATH.."help_addon-pettracker",
			heading = "支援插件 PetTracker",
			text = "支援在任務追蹤清單增強裡面顯示 PetTracker 的區域寵物追蹤，同時也修正了顯示上的一些問題。\n"..
					AddonInfo("PetTracker"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/pettracker",
					width = 510,
					bottom = 2,
				}
			},
		},
		{	-- 12
			image = HELP_PATH.."help_addon-tomtom",
			heading = "支援插件 TomTom",
			text = "TomTom 的支援性整合了暴雪的 POI 和 TomTom 的導航箭頭。\n\n"..
					"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:0:256:256:128:160:96:128|t+"..
					"|T"..KT.MEDIA_PATH.."KT-TomTomTag:32:32:-8:0:32:16:0:16:0:16|t"..cDots.."...|r   當前 POI 按鈕包含 TomTom 導航。\n".. -- Text translated, icons kept
					"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:0:256:256:128:160:96:128|t+"..
					"|T"..KT.MEDIA_PATH.."KT-TomTomTag:32:32:-8:0:32:16:16:32:0:16|t"..cDots.."...|r   當前 POI 按鈕不包含 TomTom 導航 (沒有資料)。\n\n".. -- Text translated, icons kept
					"功能:\n"..
					"- 一般任務和世界任務都可以使用，但是只有當前區域的任務才能導航!"..
					offs.."(這是 TomTom 和暴雪的功能限制)\n"..
					"- "..cBold.."點一下|r (任務清單中或是世界地圖上的) POI 按鈕會顯示該任務的"..
					offs.."導航箭頭。\n"..
					"- 新追蹤或距離最近的任務會自動顯示導航。\n"..
					"- 取消追蹤或放棄任務時會移除導航。\n"..
					"- "..cBold.."左鍵點擊|r箭頭 - 打開世界地圖。\n"..
                    "- "..cBold.."右鍵點擊|r箭頭 - 移除導航並取消選取 POI。\n"..
                    "- "..cBold.."Shift + 右鍵點擊|r箭頭 - 顯示右鍵選單。\n"..
					AddonInfo("TomTom"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/tomtom",
					width = 510,
					bottom = 4,
				}
			},
			shineTop = 10,
			shineBottom = -10,
			shineLeft = -11,
			shineRight = 11,
		},
		{	-- 13
			image = HELP_PATH.."help_addon-rarescanner",
			heading = "支援插件 RareScanner "..beta,
			text = "RareScanner 支援會取代原本的 RareScanner 按鈕，並將偵測到的稀有 NPC "..
					"直接顯示在任務追蹤清單內，作為獨立模組。\n\n"..
					"功能：\n"..
					"- 僅顯示稀有 NPC - 模型與名稱。寶藏/寶箱不會顯示。\n"..
					"- 顯示戰利品圖示與浮動提示資訊 (若有在 RareScanner 中啟用)。\n"..
					"- "..cBold.."左鍵點擊|r - 建立 TomTom 導航 (若有在 RareScanner 中啟用)。\n"..
					"- "..cBold.."右鍵點擊|r - 從追蹤清單移除已偵測到的 NPC。\n"..
					"- 由於暴雪的限制，不支援透過左鍵點擊選取 NPC。"..
					offs.."請使用 RareScanner 的按鍵綁定進行選取。\n"..
					"- RareScanner 的其他設定皆會反映在此模組的行為上。\n"..
					AddonInfo("RareScanner"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/rarescanner",
					width = 510,
					bottom = 2,
				}
			},
		},
		{	-- 14
			image = HELP_PATH.."help_map-waypoints",
			heading = "地圖導航",
			text = KT.TITLE.." 允許在地圖上的任何 POI 設定 TomTom 導航路線。包括新任務、"..
                    "事件、副本、團隊、副洞窟、飛行點、傳送門等等。\n\n"..
                    cTitle.."導航範例|r\n"..
                    "上方圖片顯示了支援的導航模式。\n\n"..
                    "1 - "..cBold.."直接導航|r - TomTom 箭頭會直接指向位於"..
                    offs2.."同一導航區域（同一區域與大陸）的目標。\n"..
                    "2 - "..cBold.."大陸內直接導航|r - TomTom 箭頭會指向"..
                    offs2.."同一大陸不同區域的目標。此外，會顯示「前往 ...」"..
                    offs2.."的指示。\n"..
                    "3 - "..cBold.."跨大陸導航|r - TomTom 箭頭會指向最近的轉移點"..
                    offs2.."(例如傳送門)。移動到正確的大陸後，導航"..
                    offs2.."會自動更新。此外，會顯示前往轉移點的指示。"..
                    offs2.."此模式僅在任務中能可靠使用。\n"..
                    "4 - "..cBold.."間接導航（沒有 TomTom 箭頭）|r - 僅顯示「前往 ...」"..
                    offs2.."的指示，因為目標位於當前可導航世界之外。"..
                    offs2.."只有在進入正確的大陸或區域後，TomTom 箭頭才會出現。",
			shineTop = 10,
			shineBottom = -10,
			shineLeft = -11,
			shineRight = 11,
		},
		{	-- 15
			image = HELP_PATH.."help_whats-new_logo",
			imageWidth = 512,
			imageHeight = 128,
			imageTexCoords = { 0, 1, 0, 1 },
			imagePoint = "TOPRIGHT",
			imageX = -9,
			imageY = -26,
			imageAbsolute = true,
			heading = "     最新功能",
			headingFont = "Fonts\\bLEI00D.ttf",
			headingSize = 26,
			text = "如果你喜歡 "..KT.TITLE.."，請考慮在 Patreon 贊助 "..ICON_HEART.."|r\n"..ebSpace.."\n"..

					(cTitle.."Version 7.18.1|r\n"..
					"- 修改 - 插件支援 - Auctionator 306\n"..
					"- 修改 - 插件支援 - RareScanner 11.2.7.3\n"..
					"- 修改 - 插件支援 - TomTom 4.2.8\n"..
					"- 修改 - 插件支援 - PetTracker 11.2.7\n"..
					"- 修改 - 插件支援 - Masque 11.2.9\n"..
					"- 修正 - Masque - 啟用外觀後，當前按鈕樣式不會被移除\n"..
					"\n")..

					(cTitle.."Version 7.18.0|r\n"..
					"- 新增 - TomTom - 住宅地塊的航點支援\n"..
					"- 新增 - 支援 WoW 11.2.7.64704\n"..
					"- 修改 - 插件支援 - ElvUI 14.04, Tukui 20.463\n"..
					"- 修改 (過濾器) - 改善副本成就過濾功能\n"..
					"- 修改 - 插件區塊 - 改進 (左鍵/右鍵點擊)\n"..
					"- 修改 - 選項 - 新增基於住宅偵測的顯示規則\n"..
					"- 修改 - 插件支援 - BtWQuests 2.58.0\n"..
					"- 修改 - 插件支援 - Auctionator 305\n"..
					"- 修改 - 插件支援 - Masque 11.2.7\n"..
					"- 修改 - 插件支援 - RareScanner 11.2.7\n"..
					"- 修改 - 插件支援 - TomTom 4.2.4\n"..
					"- 修正 (過濾器) - 當缺少任務地圖資訊時的錯誤\n"..
					"- 修正 - 當缺少任務區域資訊時的錯誤\n"..
					"\n")..

					cTitle.."Issue reporting|r\n"..
					"For reporting please use "..cBold.."Tickets|r instead of Comments on CurseForge.\n"..ebSpace.."\n"..

					cWarning.."回報錯誤之前，請先停用所有其他的插件，以確保不是和其他插件相衝突。|r",
			editbox = {
				{
					icon = ICON_URL,
					text = "https://patreon.com/kalielstracker",
					width = 510,
					top = 52,
				},
				{
					icon = ICON_URL,
					text = "https://www.curseforge.com/wow/addons/kaliels-tracker/issues",
					width = 510,
					bottom = 20,
				}
			},
			shine = KTF.Background,
			shineTop = 5,
			shineBottom = -5,
			shineLeft = -6,
			shineRight = 6,
		},
		onShow = function(self, i)
			if KT:IsCollapsed() then
				KT:MinimizeButton_OnClick()
			end
			if i == 2 then
				if KTF.FilterButton then
					self[i].shineLeft = db.hdrOtherButtons and -74 or -34
				else
					self[i].shineLeft = db.hdrOtherButtons and -54 or -14
				end
			elseif i == 3 then
				local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(1)
				local block = KT_QuestObjectiveTracker:GetExistingBlock(questID)
				if block then
					self[i].shine = block
				end
			elseif i == 5 then
				self[i].shine = KTF.Buttons
			elseif i == 10 then
				local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0
				for j = 1, C_QuestLog.GetNumQuestWatches() do
					local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(j)
					local block = KT_QuestObjectiveTracker:GetExistingBlock(questID)
					if block and block.poiButton then
						if superTrackedQuestID == 0 or superTrackedQuestID == questID then
							self[i].shine = block.poiButton
							break
						end
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
		title = HELP_TITLE,
		icon = HELP_PATH.."KT_logo",
		font = "Fonts\\bLEI00D.ttf",
		width = 582,
		height = 610,
		paddingX = 35,
		paddingTop = 26,
		paddingBottom = 24,
		{	-- 1
			heading = "       成為贊助者",
			text = "如果你喜歡 "..KT.TITLE..", 請在 |cfff34a54Patreon|r 贊助我。\n\n"..
					"在 CurseForge 的插件頁面點一下 |T"..HELP_PATH.."help_patreon:20:173:0:0:256:32:0:173:0:20|t 按鈕。\n\n"..
					"經過了 10 年的插件工作後，我啟用了 Patreon，作為開發插件所需時間的補償。\n\n"..
					"                                    非常感謝所有贊助者  |T"..HELP_PATH.."help_patreon:16:16:0:0:256:32:174:190:0:16|t\n\n"..
					cTitle.."Active Patrons|r\n"..
                    SetFormatedPatronName("Epic", "Liothen", "Emerald Dream")..
                    SetFormatedPatronName("Rare", "Ian F")..
                    SetFormatedPatronName("Rare", "Spance")..
                    SetFormatedPatronName("Uncommon", "Charles Howarth")..
                    SetFormatedPatronName("Uncommon", "Cool Blue")..
                    SetFormatedPatronName("Uncommon", "David Blanchard")..
                    SetFormatedPatronName("Uncommon", "Illidanclone", "Kazzak")..
                    SetFormatedPatronName("Uncommon", "Mystekal")..
                    SetFormatedPatronName("Uncommon", "Paul Westervelt")..
                    SetFormatedPatronName("Uncommon", "Semy", "Ravencrest")..
                    SetFormatedPatronName("Uncommon", "Xeelee", "Razorfen")..
                    SetFormatedPatronName("Common", "Darren Divecha")..
					"\n"..
					cTitle.."Testers|r\n"..
					SetFormatedPlayerName("Asimeria", "Drak'thul")..
					SetFormatedPlayerName("Torresman", "Drak'thul"),
			editbox = {
				{
					icon = ICON_URL,
					text = "https://patreon.com/kalielstracker",
					width = 510,
					top = 52,
				}
			},
		},
	})
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00初始化|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
	_DBG("|cff00ff00啟用|r - "..self:GetName(), true)
	SetupTutorials()
	local last = false
	if KT.VERSION ~= KT.db.global.version then
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