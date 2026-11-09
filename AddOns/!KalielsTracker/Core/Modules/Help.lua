--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Help
local M = KT:NewModule("使用說明")
KT.Help = M

local T = LibStub("MSA-Tutorials-1.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local HELP_TITLE = KT.TITLE.." |cffffffff"..KT.VERSION.."|r"
local HELP_PATH = KT.MEDIA_PATH.."Help\\"
local HEADER_BUTTONS = KT.MEDIA_PATH.."UI-KT-HeaderButtons"
local ICON_URL = HELP_PATH.."help_icon-url"
local ICON_HEART = "|T"..HELP_PATH.."help_patreon:14:14:2:0:256:32:174:190:0:16|t"

local db, dbChar
local helpName = "help"
local supportersName = "supporters"
local cTitle = "|cffffd200"
local cBold = "|cff00ffe3"
local cNote = "|cff999999"
local cWarning = "|cffff7f00"
local cWarning2 = "|cffff4200"
local cDots = "|cff808080"
local offs = "\n|T:1:9|t"
local offs2 = "|T:1:13|t"
local offs3 = "\n|T:1:21|t"
local ebSpace = "|T:16:1|t\n"

local KTF = KT.frame

-- Internal ------------------------------------------------------------------------------------------------------------

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

-- External ------------------------------------------------------------------------------------------------------------

function M.AddonInfo(name, title)
	title = title or name
	local info = "\n插件 "..title
	if C_AddOns.IsAddOnLoaded(name) then
		info = info.." |cff00ff00已安裝|r。支援性可以在設定選項中啟用/停用。\n"..ebSpace
	else
		info = info.." |cffff0000未安裝|r。\n"..ebSpace
	end
	return info
end

M.pages = {
	intro = {
		image = HELP_PATH.."help_kaliels-tracker",
		text = cTitle..KT.TITLE.." ("..KT.FLAVOR.name..")|r 以暴雪任務追蹤清單為基礎，並提供多項增強功能。\n\n"..
				"包含下面這些功能:\n"..
				"- 更改追蹤清單位置\n"..
				"- 根據追蹤清單位置 (方向) 展開/收起追蹤清單\n"..
				"- 根據內容自動調整追蹤清單高度，可以限制最大高度\n"..
				"- 內容較多，超出最大高度時可以捲動\n"..
				"- 登出/結束遊戲時會記憶收起的追蹤清單狀態\n\n"..
				"……還有更多增強功能"..cBold.."（請見後續頁面）|r。",
		shine = "Background",
		shineTop = 5,
		shineBottom = -5,
		shineLeft = -6,
		shineRight = 6,
	},
	header = {
		image = HELP_PATH.."help_header-buttons",
		imageHeight = 128,
		heading = "標題列按鈕",
		text = "最小化按鈕:                                其他按鈕:\n"..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:0:14:0:14:209:170:0|t "..cDots.."...|r 展開追蹤清單                     "..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:0:14:209:170:0|t "..cDots.."...|r Open "..KT.TEXT.TRACKER_QUESTLOG.."\n"..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:0:14:16:30:209:170:0|t "..cDots.."...|r 收起追蹤清單                     "..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:16:30:209:170:0|t "..cDots.."...|r Open "..KT.TEXT.TRACKER_ACHIEVEMENTS.."\n"..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:0:14:32:46:209:170:0|t "..cDots.."...|r 追蹤清單是空的時候          "..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:32:46:209:170:0|t "..cDots.."...|r 打開過濾方式選單\n\n"..
				"按鈕 |T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:0:14:209:170:0|t 和 "..
				"|T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:16:30:209:170:0|t 可以在設定選項中停用。\n\n"..
				"可以設定 "..cBold.."[按鍵綁定]|r 來最小化追蹤清單。\n"..
				cBold.."右鍵點擊|r 最小化按鈕 - 將最近的任務設為焦點。\n"..
				cBold.."Alt+左鍵|r 點擊最小化按鈕會開啟 "..KT.TITLE.." 的設定選項。",
		paddingBottom = 18,
		shine = "MinimizeButton",
		shineTop = 13,
		shineBottom = -14,
		shineRight = 15,
	},
	quests = {
		image = HELP_PATH.."help_quests",
		imageHeight = 128,
		heading = "任務",
		text = cTitle.."模組標題|r\n\n"..
				"標題文字可顯示任務數量 "..cDots.."...|r "..cBold.."任務 (14/"..MAX_QUESTS.." +3)|r.\n\n"..
				"    "..cBold.."14|r "..cDots.."...|r 任務日誌中的目前任務數量\n"..
				"    "..cBold..MAX_QUESTS.."|r "..cDots.."...|r 任務日誌的最大任務數量\n"..
				"    "..cBold.."+3|r "..cDots.."...|r 帳號/召喚任務（不計入上限）\n\n"..
				cTitle.."標題標籤|r\n\n"..
				"在任務標題開頭，你會看到像這樣的標籤 |cffff8000[90|r|cff00b3ff*!!|r|cffff8000]|r。\n\n"..
				"    |cff00b3ff•|r "..cDots..".......|r 帳號/戰團任務\n"..
				"    |cff00b3ff!|r|T:14:3|t "..cDots..".......|r 每日任務\n"..
				"    |cff00b3ff!!|r "..cDots.."......|r 每週任務\n"..
				"    |cff00b3ffg3|r "..cDots..".....|r 組隊任務（附組隊人數）\n"..
				"    |cff00b3ffd|r "..cDots..".......|r 地城任務\n"..
				"    |cff00b3ffhc|r "..cDots..".....|r 英雄難度任務\n"..
				"    |cff00b3ffr|r "..cDots.."........|r 團隊任務\n"..
				"    |cff00b3ffr10|r "..cDots.."...|r 10人團隊任務\n"..
				"    |cff00b3ffr25|r "..cDots.."...|r 25人團隊任務\n"..
				"    |cff00b3ffde|r "..cDots..".....|r 深淵任務\n"..
				"    |cff00b3ffs|r "..cDots..".......|r 事件任務\n"..
				"    |cff00b3ffpvp|r "..cDots.."...|r PvP 任務\n"..
				"    |cff00b3ffleg|r "..cDots.."....|r 傳說任務",
		paddingBottom = 16,
		shineTop = 11,
		shineBottom = -9,
		shineLeft = -11,
		shineRight = 13,
	},
	filters = {
		image = HELP_PATH.."help_tracker-filters",
		heading = "任務過濾",
		text = "要開啟過濾方式選單請"..cBold.."點一下|r這個按鈕 |T"..HEADER_BUTTONS..":14:14:-1:1:32:64:16:30:32:46:209:170:0|t.\n\n"..
				"過濾方式分為兩種類型:\n"..
				cTitle.."固定過濾|r - 依據規則 (例如 \"每日\") 加入要追蹤的任務/成就，並且可以手動新增/移除項目。\n"..
				cTitle.."動態過濾|r - 自動依據規則加入要追蹤的任務/成就 (例如 \"|cff00ff00自動|r區域\") "..
				"並且會持續更新項目。這種類型不允許手動加入/移除項目。"..
				"啟用動態過濾時，標題按鈕是綠色 |T"..HEADER_BUTTONS..":14:14:-1:1:32:64:16:30:32:46:0:255:0|t.\n\n"..
				"|cff009bff最愛|r - 現在可以將任務或成就加入最愛，然後使用這種過濾方式。\n\n"..
				"更改成就的搜尋類別時，也會影響過濾的結果。\n\n"..
				"這個選單也會顯示影響追蹤清單內容的其他選項 (例如 戰寵助手插件 PetTracker 所使用的選項)",
		shine = "FilterButton",
		shineTop = 9,
		shineBottom = -10,
		shineLeft = -10,
		shineRight = 11,
	},
	buttons = {
		image = HELP_PATH.."help_quest-item-buttons",
		heading = "任務物品按鈕",
		text = "按鈕在任務追蹤清單外面，因為暴雪不允許預設的清單介面使用動作按鈕。\n\n"..
				"|T"..HELP_PATH.."help_quest-item-buttons_2:32:32:0:0:64:32:0:32:0:32|t "..cDots.."...|r  這個標籤代表任務中的任務物品。裡面的數字用來辨別\n"..
				"              移動後的任務物品按鈕。\n\n"..
				"|T"..HELP_PATH.."help_quest-item-buttons_2:32:32:0:3:64:32:32:64:0:32|t "..cDots.."...|r  真正的任務物品按鈕已經移動到清單的左/右側\n"..
				"              (依據所選擇的對齊畫面位置)。標籤數字仍然相同。\n\n"..
				cWarning.."特別注意:|r\n"..
				"在某些戰鬥中，任務物品按鈕的動作會被暫停，直到戰鬥結束後才能使用。",
		shine = "Buttons",
		shineTop = 3,
		shineBottom = -2,
		shineLeft = -4,
		shineRight = 3,
	},
	activeButton = {
		image = HELP_PATH.."help_active-button",
		heading = "當前任務物品按鈕",
		text = "當前任務物品按鈕提供任務物品較佳的使用方式。將 '距離最近' 的任務的物品顯示為額外快捷鍵。(類似德拉諾的要塞技能)\n\n"..
				"功能特色：\n"..
				"- "..cBold.."接近可以使用任務物品的地方時"..
				offs.."自動顯示|r當前任務物品按鈕。\n"..
				"- "..cBold.."點選地圖上或任務追蹤清單旁的 POI 按鈕可以"..
				offs.."手動顯示|r當前任務物品按鈕。\n"..
				"- 可以設定"..cBold.." [快速鍵]|r 來使用任務物品，請在設定選項中指定要綁定的按鍵。"..KT.TITLE..
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
	modules = {
		image = HELP_PATH.."help_tracker-modules",
		heading = "模組",
		text = cTitle.."模組順序|r\n\n"..
				"允許更改模組在追蹤清單中的順序。支援所有模組，也包含外部插件 (例如：戰寵助手)。\n\n\n"..
				cTitle.."可收合的模組|r\n\n"..
				"所有模組，包含外部插件的，都可以點一下模組標題收合起來。",
		shine = "Background",
		shineTop = 5,
		shineBottom = -5,
		shineLeft = -6,
		shineRight = 6,
	},
	events = {
		image = HELP_PATH.."help_events",
		heading = "事件",
		text = "事件模組會在追蹤清單中顯示當前進行中的事件。它們通常可在世界地圖上看到。\n\n"..
				"篩選 |T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:32:46:209:170:0|t 下拉選單選項：\n"..
				"- "..cBold.."追蹤事件|r – 啟用或停用在追蹤清單中追蹤事件。\n"..
				"- "..cBold.."顯示長期事件|r – 除了當前進行中的事件，還會顯示那些"..
				offs.."持續 24 小時或更久的事件。",
	},
	masque = {
		image = HELP_PATH.."help_addon-masque",
		heading = "支援插件 Masque",
		text = "Masque 提供任務物品按鈕與啟用按鈕的外觀美化。\n"..
				M.AddonInfo("按鈕外觀 Masque"),
		editbox = {
			{
				icon = ICON_URL,
				text = "https://www.curseforge.com/wow/addons/masque",
				width = 510,
				bottom = 2,
			}
		},
	},
	pettracker = {
		image = HELP_PATH.."help_addon-pettracker",
		heading = "支援插件 PetTracker",
		text = "支援 PetTracker 後，將在 "..KT.TITLE.." 中顯示區域寵物追蹤，並提供自訂版面與更佳的"..
				"視覺呈現。\n\n"..
				"篩選 |T"..HEADER_BUTTONS..":14:14:-1:2:32:64:16:30:32:46:209:170:0|t 下拉選單選項：\n"..
				"- "..cBold.."追蹤寵物|r – 啟用或停用追蹤器中的寵物模組。\n"..
				"- "..cBold.."顯示已捕獲|r – 顯示或隱藏已捕獲的區域寵物。\n"..
				M.AddonInfo("PetTracker"),
		editbox = {
			{
				icon = ICON_URL,
				text = "https://www.curseforge.com/wow/addons/pettracker",
				width = 510,
				bottom = 2,
			}
		},
	},
	tomtom = {
		image = HELP_PATH.."help_addon-tomtom",
		heading = "支援插件 TomTom",
		text = "TomTom 支援結合了暴雪的 POI 與 TomTom 的箭頭。\n\n"..
				"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:0:256:256:128:160:96:128|t+"..
				"|T"..KT.MEDIA_PATH.."KT-TomTomTag:32:32:-8:0:32:16:0:16:0:16|t"..cDots.."...|r 啟用的 POI 按鈕，並帶有 TomTom 路徑點。\n"..
				"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:0:256:256:128:160:96:128|t+"..
				"|T"..KT.MEDIA_PATH.."KT-TomTomTag:32:32:-8:0:32:16:16:32:0:16|t"..cDots.."...|r 啟用的 POI 按鈕，但沒有 TomTom 路徑點（無資料）。\n\n"..
				"功能特色：\n"..
				"- 適用於任務與世界任務，但路徑點僅限於當前"..
				offs.."大陸（TomTom 與暴雪的限制）。\n"..
				"- 其他地圖 POI 也能設定導航點（請見「地圖導航點」）。\n"..
				"- "..cBold.."左鍵點擊|r POI 按鈕（在追蹤器或世界地圖上）即可設置路徑點。\n"..
				"- 新追蹤的任務或最近的任務會自動獲得路徑點。\n"..
				"- 未追蹤或放棄的任務，其路徑點會被移除。\n"..
				"- "..cBold.."左鍵點擊|r箭頭 - 打開世界地圖。\n"..
				"- "..cBold.."右鍵點擊|r箭頭 - 從箭頭移除路徑點，清除 POI"..
				offs.."選擇並刪除路徑點（若由 "..KT.TITLE.." 建立）。\n"..
				"- "..cBold.."Shift + 右鍵點擊|r箭頭 - 打開 TomTom 右鍵選單。\n"..
				M.AddonInfo("TomTom"),
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
	rarescanner = {
		image = HELP_PATH.."help_addon-rarescanner",
		heading = "支援插件 RareScanner",
		text = "支援 RareScanner 後，將取代原有的 RareScanner 按鈕，並把偵測到的稀有怪物顯示於 "..
				"inside "..KT.TITLE.."的獨立模組中。\n\n"..
				"功能特色：\n"..
				"- 僅顯示稀有怪物的模型與名稱，不顯示寶藏或寶箱。\n"..
				"- 顯示戰利品圖示及浮動提示（需在 RareScanner 中啟用）。\n"..
				"- "..cBold.."左鍵點擊|r - 建立 TomTom 路徑點（若已在 RareScanner 中啟用）。\n"..
				"- "..cBold.."右鍵點擊|r - 從追蹤器中移除已偵測到的 NPC。\n"..
				"- 由於暴雪的限制，不支援透過左鍵點擊來鎖定 NPC。"..
				offs.."請使用 RareScanner 的快捷鍵進行鎖定。\n"..
				"- 所有其他 RareScanner 設定均會反映在此模組的行為上。\n"..
				M.AddonInfo("RareScanner"),
		editbox = {
			{
				icon = ICON_URL,
				text = "https://www.curseforge.com/wow/addons/rarescanner",
				width = 510,
				bottom = 2,
			}
		},
	},
	waypoints = {
		image = HELP_PATH.."help_map-waypoints",
		heading = "地圖導航",
		text = KT.TITLE.." 允許在地圖上的任何 POI 設定 TomTom 導航路線。包括新任務、"..
				"事件、地城、團隊副本、深淵、飛行點、傳送門等等。\n\n"..
				cTitle.."導航範例|r\n"..
				"上方圖片顯示了支援的導航模式。\n\n"..
				"1 - "..cBold.."直接導航|r - TomTom 箭頭會直接指向位於"..
				offs3.."同一導航區域（同一區域與大陸）的目標。\n"..
				"2 - "..cBold.."大陸內直接導航|r - TomTom 箭頭會指向"..
				offs3.."同一大陸不同區域的目標。此外，會顯示「前往 ...」"..
				offs3.."的指示。\n"..
				"3 - "..cBold.."跨大陸導航|r - TomTom 箭頭會指向最近的轉移點"..
				offs3.."(例如傳送門)。移動到正確的大陸後，導航"..
				offs3.."會自動更新。此外，會顯示前往轉移點的指示。"..
				offs3.."此模式僅在任務中能可靠使用。\n"..
				"4 - "..cBold.."間接導航（沒有 TomTom 箭頭）|r - 只會顯示「前往……」"..
				offs3.."指示，因為目標位於目前無法導航的區域。"..
				offs3.."進入正確的大陸"..
				offs3.."或區域後才會顯示 TomTom 箭頭。",
		shineTop = 10,
		shineBottom = -10,
		shineLeft = -11,
		shineRight = 11,
	},
	battlepetcompletionist = {
		image = HELP_PATH.."help_addon-battlepetcompletionist",
		heading = "支援插件 Battle Pet Completionist",
		text = "支援 Battle Pet Completionist 後，將為 "..KT.TITLE.." 加入區域寵物追蹤功能，\n"..
				"並提供自訂版面配置與更佳的視覺呈現方式。\n\n"..
				"功能特色：\n"..
				"- 每一列寵物皆可點擊，點擊後會在寵物圖鑑中開啟該寵物。\n\n"..
				"篩選 |T"..HEADER_BUTTONS..":14:14:-1:1:32:64:16:30:32:46:209:170:0|t 選單選項：\n"..
				"- "..cBold.."追蹤寵物|r – 啟用或停用追蹤器中的寵物模組。\n"..
				"- "..cBold.."顯示已捕獲|r – 顯示或隱藏已捕獲的區域寵物。\n"..
				M.AddonInfo("BattlePetCompletionist", "Battle Pet Completionist"),
		editbox = {
			{
				icon = ICON_URL,
				text = "https://www.curseforge.com/wow/addons/battle-pet-completionist",
				width = 510,
				bottom = 2,
			}
		},
	},
	whatsNew = {
		image = HELP_PATH.."help_whats-new_logo",
		imageWidth = 512,
		imageHeight = 128,
		imageTexCoords = { 0, 1, 0, 1 },
		imagePoint = "TOPRIGHT",
		imageX = -9,
		imageY = -26,
		imageAbsolute = true,
		heading = "     最新功能",
		headingFont = STANDARD_TEXT_FONT,
		headingSize = 26,
		text = "|cff66ff66"..KT.TITLE.." 是由一人獨自開發與維護的。|r\n"..ebSpace.."\n"..

				(cTitle.."版本 8.11.1|r\n"..
				"- 修正 - TomTom - 設定說明缺漏\n"..
				"\n")..

				(cTitle.."版本 8.11.0|r\n"..
				"- 變更 - 插件支援：Narcissus 1.8.7 c\n"..
				"- 變更 - 插件支援：Auctionator 343\n"..
				"- 變更 - 插件支援：TomTom 4.4.1\n"..
				"- 變更 - 插件支援：BtWQuests 2.69.0\n"..
				"\n")..

				cTitle.."回報問題|r\n"..
				"回報問題時請使用 "..cBold.."問題單|r，而不是 CurseForge 留言。\n"..ebSpace.."\n"..

				cWarning.."回報錯誤前，請先停用其他所有插件，確認問題不是插件衝突所造成。|r",
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
				bottom = 39,
			}
		},
		shine = "Background",
		shineTop = 5,
		shineBottom = -5,
		shineLeft = -6,
		shineRight = 6,
	},
	patreon = {
		heading = "      成為贊助者",
		text = KT.TITLE.." 是由一人獨自開發與維護的。\n\n\n\n"..
				"在 Patreon 創立之前，本插件已經歷了超過 10 年的開發歲月。隨著時間推移，它已從"..
				"一個小型的個人專案，成長為需要投入大量時間且持續維護的龐大系統。\n\n"..
				"非常感謝所有協助維持本專案運作的支持者們 "..ICON_HEART.."\n\n\n"..
				cTitle.."目前的贊助者|r\n"..
				SetFormatedPatronName("Legendary", "Liothen", "Emerald Dream")..
				SetFormatedPatronName("Rare", "David Blanchard")..
				SetFormatedPatronName("Rare", "Ian F")..
				SetFormatedPatronName("Rare", "Sal")..
				SetFormatedPatronName("Rare", "Spence")..
				SetFormatedPatronName("Uncommon", "Anaara", "Auchindoun")..
				SetFormatedPatronName("Uncommon", "Camalus")..
				SetFormatedPatronName("Uncommon", "Charles Howarth")..
				SetFormatedPatronName("Uncommon", "Cool Blue")..
				SetFormatedPatronName("Uncommon", "Durona")..
				SetFormatedPatronName("Uncommon", "Gene M Linkoski")..
				SetFormatedPatronName("Uncommon", "Harry J Hightower")..
				SetFormatedPatronName("Uncommon", "Illidanclone", "Kazzak")..
				SetFormatedPatronName("Uncommon", "Jason Brown")..
				SetFormatedPatronName("Uncommon", "Mystekal")..
				SetFormatedPatronName("Uncommon", "Naturegurl")..
				SetFormatedPatronName("Uncommon", "Papus", "Ulduar")..
				SetFormatedPatronName("Uncommon", "Paul Westervelt")..
				SetFormatedPatronName("Uncommon", "Scott Ingram")..
				SetFormatedPatronName("Uncommon", "Semy", "Ravencrest")..
				SetFormatedPatronName("Uncommon", "Torresman", "Drak'thul")..
				SetFormatedPatronName("Uncommon", "Veratais")..
				SetFormatedPatronName("Common", "Darren Divecha")..
				"\n"..
				cTitle.."測試人員|r\n"..
				SetFormatedPlayerName("Asimeria", "Drak'thul"),
		editbox = {
			{
				icon = ICON_URL,
				text = "https://patreon.com/kalielstracker",
				width = 510,
				top = 52,
			}
		},
	},
}

M.helpPages = {}

M.supportersPages = {
	M.pages.patreon,
}

function M:Setup_Help()
	local data = {
		savedvariable = KT.db.global,
		key = helpName.."Tutorial",
		title = HELP_TITLE,
		icon = HELP_PATH.."KT_logo",
		font = STANDARD_TEXT_FONT,
		width = 582,
		height = 632,
		paddingX = 35,
		paddingTop = 26,
		paddingBottom = 24,
		imageWidth = 512,
		imageHeight = 256,
		onShow = function(self, i)
			KT:Tracker_Expand()

			local page = self[i]
			if type(page.shine) == "string" then
				page.shine = KTF[page.shine]
			end

			if page == M.pages.header then
				if KTF.FilterButton then
					page.shineLeft = db.hdrOtherButtons and -74 or -34
				else
					page.shineLeft = db.hdrOtherButtons and -54 or -14
				end
			elseif page == M.pages.quests then
				local block = KT_QuestObjectiveTracker.firstBlock
				if block then
					page.shine = block
				end
			elseif page == M.pages.tomtom then
				local block = KT_QuestObjectiveTracker.firstBlock
				local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0
				if superTrackedQuestID > 0 then
					block = KT_QuestObjectiveTracker:GetExistingBlock(superTrackedQuestID)
				end
				if block and block.poiButton then
					page.shine = block.poiButton
				end
			end
		end,
		onHide = function()
			T.TriggerTutorial(supportersName, #M.supportersPages)
		end,
	}

	for i, page in ipairs(self.helpPages) do
		data[i] = page
	end

	T.RegisterTutorial(helpName, data)
end

function M:Setup_Supporters()
	local data = {
		savedvariable = KT.db.global,
		key = supportersName.."Tutorial",
		title = HELP_TITLE,
		icon = HELP_PATH.."KT_logo",
		font = STANDARD_TEXT_FONT,
		width = 582,
		height = 610,
		paddingX = 35,
		paddingTop = 26,
		paddingBottom = 24,
	}

	for i, page in ipairs(self.supportersPages) do
		data[i] = page
	end

	T.RegisterTutorial(supportersName, data)
end

function M:ShowHelp(index)
	HideUIPanel(SettingsPanel)
	T.ResetTutorial(helpName)
	T.TriggerTutorial(helpName, #self.helpPages, index or false)
end

function M:ShowSupporters()
	HideUIPanel(SettingsPanel)
	T.ResetTutorial(supportersName)
	T.TriggerTutorial(supportersName, #self.supportersPages)
end

function M:OnInitialize()
	_DBG("|cffffff00初始化|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
	_DBG("|cff00ff00啟用|r - "..self:GetName(), true)
	self:Setup_Help()
	self:Setup_Supporters()

	local last = false
	local helpNumPages = #self.helpPages
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
