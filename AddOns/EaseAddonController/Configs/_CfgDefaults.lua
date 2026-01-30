local _, U1 = ...

local D = {}
U1.CfgDefaults = D
D["!gmFonts"] = {
	defaultEnable = 1,
	tags = { "MISC" }, 
	title = "遊戲字體",
	desc = "載入時會自動將遊戲預設的系統、聊天、提示說明和傷害數字，更改為字體材質包中的字體。``可以在設定選項中調整視窗介面文字的字體和大小，其他地方的文字則是在每個插件中分別設定。例如聊天文字在 '聊天視窗美化' 插件設定、玩家和怪頭上的名字在 '威力血條' 設定...等等。``要使用自己的字體，請看問與答`https://addons.miliui.com/wow/rainbowui#q157 ``關閉此插件便可以換回遊戲原本的字體。`",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory(862032892)
		end,
    },
	{
		type = "text",
		text = "|cffFF2D2D特別注意：請不要選擇英文字體，會無法顯示中文字。|r",
	},
};
D["AAgmFonts"] = {
	defaultEnable = 0,
	title = "(請刪除) 遊戲字體",
	desc = "這個插件的資料夾已經改名為 !gmFonts。`請自行刪除 AddOns 裡面的 AAgmFonts 資料夾。`",
	modifier = "彩虹ui",
};
D["AbilityTimeline"] = {
	defaultEnable = 0,
	tags = { "BOSSRAID" }, 
	title = "首領時間線增強",
	desc = "優化並擴展遊戲內建的首領時間線顯示功能。它的特色是和 WA 的風格一致，同時加入更多實用的提示與自訂選項，讓玩家在團隊副本或地城中能更清晰掌握技能冷卻與戰鬥節奏。`",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_AT"]("") end,
    },
};
D["AccWideUILayoutSelection"] = {
	defaultEnable = 0,
	tags = { "MISC" }, 
	title = "帳號共用介面設定",
	desc = "讓角色專用的介面設定可以在整個帳號中同步，避免每次創建新角色或切換角色時都要重新調整設定。``它會自動將你常用的介面選項套用到所有角色。``注意：若要讓不同的角色載入相同的插件，請使用插件控制台上方的 '方案管理' 功能。`",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_AWI"]("") end,
    },
};
D["Ace3"] = {
	defaultEnable = 1,
	protected = true, 
	tags = { "MISC" },
	title = "Ace3 共用函式庫",
	desc = "大部分插件都會使用到的函式庫。``|cffFF2D2D請千萬千萬不要關閉!!!|r`",
};
D["AABugGrabber"] = { 
	defaultEnable = 1,
	optdeps = { "BugSack", },
	protected = true, 
	title = "錯誤收集器",
	desc = "收集錯誤訊息，防止遊戲中斷，訊息會顯示在錯誤訊息袋中。`",
	modifier = "Rabbit, Whyv, zhTW",
	icon = "Interface\\AddOns\\BugSack\\Media\\icon",
	img = true,
};
D["!KalielsTracker"] = {
	defaultEnable = 1,
	title = "任務追蹤清單增強",
	desc = "增強畫面右方任務追蹤清單的功能。在設定選項中可以調整位置和文字大小。`",
	modifier = "BNS, 彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["KALIELSTRACKER"]("config") end,
    },
};
D["Accountant_Classic"] = {
	defaultEnable = 1,
	title = "個人會計",
	desc = "追蹤每個角色的所有收入與支出狀況，並可顯示當日小計、當週小計、以及自有記錄起的總計。並可顯示所有角色的總金額。`",
	modifier = "arith, 彩虹ui",
	icon = "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantClassicButton-Up",
	img = true,
	{
        text = "顯示/隱藏個人會計",
        callback = function() AccountantClassic_ButtonOnClick() end,
    },
    {
        text = "設定選項",
        callback = function() 
			Accountant_Classic:OpenOptions();
		end,
    },
	{
		type = "text",
		text = "點小地圖按鈕的 '個人會計' 按鈕也可以打開主視窗。",
	}
};
D["AchievementsBackButton"] = {
	defaultEnable = 1,
	tags = { "COLLECTION" },
	title = "成就回上一頁",
	desc = "在成就視窗上方、成就點數右側新增返回上一頁的按鈕，方便瀏覽。`",
};
D["ActionCamPlus"] = {
	defaultEnable = 0,
	tags = { "MISC" },
	title = "動感鏡頭 Plus",
	desc = "啟用遊戲內建的動作鏡頭功能，有多種不同的鏡頭效果可供調整。``像是會記憶騎乘坐騎的鏡頭距離，下坐騎後便會自動恢復。或是記憶戰鬥中的鏡頭距離，戰鬥結束後便會自動恢復。``如果想要更像家機般的遊玩感受，請在設定選項中啟用 '動感鏡頭' 和 '上下調整鏡頭'`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_eyeoftheowl",
    {
        text = "開/關動感鏡頭",
        callback = function() SlashCmdList["ACTIONCAMPLUS"]("") end,
    },
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACTIONCAMPLUS"]("h") end,
    },
};
D["AdvancedInterfaceOptions"] = {
	defaultEnable = 0,
	tags = { "MISC" },
	title = "進階遊戲選項",
	desc = "軍臨天下版本移除了一些遊戲內建的介面選項，這個插件除了讓你可以使用這些被移除的介面選項，還可以瀏覽和設定 CVar 遊戲參數，以及更多遊戲設定。`",
	modifier = "BNS, 彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["AIO"]("") end,
    },
	{
		type = "text",
        text = "鏡頭最遠距離：調整前請先關閉功能百寶箱裡面的 '最大鏡頭縮放'。\n",       
	},
};
D["AdventureGuideLockouts"] = {
	defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "副本進度 (冒險指南)",
	desc = "在冒險指南中顯示副本首領和世界王的擊殺進度，方便查看否已經打過。``注意：僅限目前登入的角色，若要查看其他分身角色的副本進度，請改用 '我的分身名冊' 插件。",
	img = true,
};
D["AppearanceTooltip"] = {
	defaultEnable = 1,
	title = "塑形外觀預覽",
	desc = "滑鼠指向裝備圖示時，會顯示你的角色穿上時的外觀預覽。``設定選項中可以調整縮放大小、自動旋轉、脫光其他部位，以及其他相關設定。`",
	modifier = "BNS, 彩虹ui",
	icon = "Interface\\Icons\\inv_raidpriestmythic_q_01chest",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["APPEARANCETOOLTIP"]("") end,
    },
	{
		type = "text",
        text = "旋轉外觀預覽：滾動滑鼠滾輪。",       
	},
};
D["AstralKeys"] = {
	defaultEnable = 0,
	tags = { "BOSSRAID" },
	title = "(暫時停用) M+ 鑰石名單",
	desc = "列出你的每個角色、公會成員和好友的鑰石，也會顯示保底打了沒，一起揪揪 M+！！`",
	modifier = "彩虹ui",
	img = true,
    {
        text = "顯示主視窗",
        callback = function() SlashCmdList["ASTRALKEYS"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
	{
		type = "text",
        text = "點小地圖按鈕也可以打開主視窗。\n",
	},
	{
		type = "text",
        text = "開啟/關閉新鑰石通報：點主視窗右上角的喇叭小圖示。\n\n密語/邀請加入隊伍：在對方角色名字上點右鍵。\n\n要看其他角色的鑰石：需要每週登入角色一次。\n\n要看公會成員和好友的鑰石：公會成員和好友也需要安裝並載入這個插件。\n\n沒有安裝彩虹ui的玩家，可以推薦他到奇樂下載這個單體插件。\n\n",
	},
	   
};
D["Auctionator"] = {
	defaultEnable = 1,
	title = "拍賣小幫手",
	desc = "一個輕量級的插件，增強拍賣場的功能，方便快速的購買、銷售和管理拍賣。`",
	modifier = "BNS, 彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() AuctionatorConfigTabMixin:OpenOptions() end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["AutoPotion"] = {
	defaultEnable = 0,
	tags = { "COMBAT" },
	title = "一鍵吃糖/喝紅水",
	desc = "只要按一個按鈕或快速鍵，便能使用治療石、治療藥水或自己的補血技能。``會自動選用背包中的物品，有糖先吃糖，有水喝水，節省快捷列格子又方便!`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_potion_54",
	img = true,
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
        text = "設定選項",
        callback = function() SlashCmdList["HAM"]("") end,
    },
	{
		type = "text",
        text = "使用巨集: 載入插件後，從 Esc > 巨集設定，將名稱為 '治療' 巨集拉到快捷列上，然後重新載入介面。\n\n使用快速鍵: 從 Esc > 選項 > 按鍵綁定 > 插件 > 使用治療巨集，設定一個按鍵後便能使用。\n\n當背包中有相關物品但巨集無效時，只要重新載入介面即可。\n",       
	},
};
D["Baganator"] = {
	defaultEnable = 1,
	tags = { "ITEM" },
	title = "多角色背包",
	desc = "可以選擇要使用不分類合併背包，也可以是分類背包。隨時隨地都能查看銀行，還可以查看分身的背包/銀行。``|cffFF2D2D需要打開過一次銀行才能離線查看銀行，其他角色需要登入過一次並且打開過背包和銀行，才能隨時查看。|r`",
	modifier = "BNS, 彩虹ui",
	{
        text = "設定選項",
        callback = function() SlashCmdList["Baganator"]("") end,
    },
	{
		type = "text",
        text = "自訂分類: 在設定選項>分類>建立新分類。\n\n用過關鍵字過濾的方式來決定自訂分類要擺放哪些物品。\n\n例如輸入 '裝綁' 就會把所有裝備綁定的物品放在一起。\n\n其他關鍵字請按 '說明' 按鈕查看。\n",       
	},
	{
		type = "text",
        text = "外觀主題: 載入 '多角色背包外觀-簡單黑' 插件就會改變背包的外觀。\n\n要恢復成原本的外觀只要取消載入外觀插件即可。\n",       
	},
};
D["BattleGroundEnemies"] = {
	defaultEnable = 0,
	tags = { "PVP" },
	title = "戰場目標框架",
	desc = "戰場專用的友方和敵方單位框架，可以監控敵人的血量、減益效果、控場遞減...等等多種狀態。`",
	modifier = "彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["BattleGroundEnemies"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
};
D["BattlePetBreedID"] = {
	defaultEnable = 0,
	title = "戰寵品級提示",
	desc = "在寵物日誌、對戰、聊天視窗連結和拍賣場的滑鼠提示中顯示戰寵的屬性品級資訊。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_pet_achievement_raise75petstolevel25",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["BATTLEPETBREEDID"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
};
D["BetterBlizzFrames"] = {
	defaultEnable = 0,
	tags = { "UNITFRAME" }, 
	title = "內建頭像增強",
	desc = "改良並強化暴雪原生的單位框架。它的特色在於保留原始框架的風格，同時加入更多功能與設定選項，讓玩家能更靈活地調整介面。``首次載入使用請到設定選項中選擇一種設定檔，才會有效果。`",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["BBF"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
};
D["BlizzMove"] = {
	defaultEnable = 1,
	tags = { "ENHANCEMENT" }, 
	title = "移動暴雪視窗",
	desc = "允許自由拖曳移動和縮放遊戲內建的各種視窗，可選擇是否要永久保存位置，還是登出/重載後要還原。``如果怕不小心移動到，可以在設定選項中勾選需要按住輔助按鍵，才能移動/縮放。`",
	modifier = "彩虹ui",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_BLIZZMOVE"]("config") end,
    },
	{
		type = "text",
		text = "移動視窗: 按住左鍵拖曳視窗標題，或拖曳視窗內沒有功能的地方來移動位置。\n\n縮放視窗: 按住 Ctrl 在視窗標題列上滾動滑鼠滾輪。\n\n重置位置: 按住 Shift 在視窗標題列上點右鍵。\n\n重置縮放: 按住 Ctrl 在視窗標題列上點右鍵。\n",
	},
};
D["BtWLoadouts"] = {
    defaultEnable = 0,
	tags = { "MISC" },
	title = "快速切換",
	desc = "更改專精、天賦、裝備、靈印和快捷列，一次全部搞定！還可以依據不同的區域，快速切換所有設定。`",
	modifier = "BNS, 彩虹ui",
	icon = "Interface\\Icons\\Ability_marksmanship",
    {
        text = "設定選項",
        callback = function() SlashCmdList["BTWLOADOUTS"]("") end,
    },
	{
		type = "text",
        text = "點小地圖按鈕的 '快速切換' 按鈕也可以開啟設定選項。\n\n使用方法：先在設定選項中建立好設定檔，右鍵點小地圖按鈕便可以快速切換設定檔。\n",
	},
};
D["BtWQuests"] = {
    defaultEnable = 0,
	tags = { "QUEST" },
	title = "任務指南",
	desc = "列出所有主線和支線任務串、需要什麼前置條件、記錄每個角色完成了哪些任務，並且可以地圖上顯示接任務的位置。``要清光任務拿名望或成就時非常實用。`",
	modifier = "Breeni, mccma, 彩虹ui",
    {
        text = "打開任務指南",
        callback = function() SlashCmdList["BTWQUESTS"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
	{
		type = "text",
        text = "點小地圖按鈕的 '任務指南' 按鈕也可以打開主視窗。\n",
	},
};
D["BugSack"] = {
	defaultEnable = 1,
	parent = "AABugGrabber",
	protected = true,
	{
        text = "查看錯誤訊息",
        callback = function() SlashCmdList["BugSack"]("show") end,
    },
    {
        text = "設定選項",
        callback = function() SlashCmdList["BugSack"]("") end,
    },
	{
		type = "text",
		text = "點小地圖按鈕的 '紅色小袋子' 也可以查看錯誤訊息。"
	}
};
D["ButtonForge"] = {
	defaultEnable = 0,
	title = "更多快捷列",
	desc = "快捷列不夠用嗎?``讓你可以打造出更多的快捷列和按鈕。要幾個、要擺哪裡都可以隨意搭配。``還可以使用巨集指令來控制何時要顯示/隱藏快捷列。`",
	modifier = "彩虹ui",
	img = true,
	{
        text = "設定選項",
        callback = function()
			if (BFConfigureLayer:IsShown()) then
				BFConfigureLayer:Hide();
			else
				BFConfigureLayer:Show();
			end
		end,
    },
	{
		type = "text",
        text = "也可以在 Esc > 選項 > 按鍵綁定 > 插件 > 更多快捷列，綁定一個快速鍵來切換顯示更多快捷列工具。\n",
	},
	{
        text = "按鈕間距",
		type = "spin",
		range = {0, 20, 1},
		default	= 6,
        callback = function(cfg, v, loadin) SlashCmdList["BUTTONFORGE"]("-gap "..v) end,
    },
};
D["BuyEmAll"] = {
	defaultEnable = 1,
	tags = { "AUCTION" },
	title = "大量購買",
	desc = "在商人視窗按 Shift+左鍵 點一下物品可一次購買一組或最大數量。`",
	img = true,
};
D["CalReminder"] = {
	defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "行事曆活動提醒",
	desc = "當行事曆中今天和明天有公會或社群活動，但是你還沒有回覆是否要參加時，會有 NPC 來提醒你。``可以在設定選項中選擇喜愛的 NPC。`",
	modifier = "彩虹ui",
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_CRM"]("") end,
    },
};
D["Cell"] = {
	defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "團隊框架 (Cell)",
	desc = "簡單好用又美觀的團隊框架，載入即可使用，幾乎不用設定。``有提供自訂外觀、增益/減益圖示和其他功能。對於補師，還有滑鼠點一下快速施法的功能。`",
	modifier = "BSN, 彩虹ui",
	{
        text = "設定選項",
        callback = function() SlashCmdList["CELL"]("options") end,
    },
	{
        text = "重置位置",
        callback = function() SlashCmdList["CELL"]("resetposition") end,
    },
	{
        text = "恢復為預設值",
        callback = function() SlashCmdList["CELL"]("resetall") end,
    },
};
D["ClearMapPin"] = {
	defaultEnable = 1,
	tags = { "MAP" },
	title = "清除地圖標記快速鍵",
	desc = "讓你能夠自訂一個快速按鍵來清除遊戲內建的地圖標記導航，不用每次都要打開地圖再按住 Ctrl 鍵點地圖標記來清除。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_misc_map_01",
	{
        type = "text",
		text = "第一次使用: 從 Esc > 選項 > 按鍵綁定 > 插件 > 清除地圖標記，設定快速鍵。\n\n放在快捷列上使用: 建立一個巨集，內容如下 (不換行):\n/script C_Map.ClearUserWaypoint()\n",
    },
};
D["Clique"] = {
    defaultEnable = 0,
	tags = { "COMBAT" },
	title = "可麗果點擊施法",
	desc = "提供強大的點滑鼠擊施法與懸停施法功能。玩家可以將幾乎任何滑鼠或鍵盤組合綁定到技能或巨集，並直接在單位框架或 3D 遊戲世界中施放。這大幅簡化了操作流程，讓你能更快選擇技能並指定目標，省去額外的點擊步驟。`",
	modifier = "彩虹ui",
	{
        text = "綁定法術",
        callback = function() SlashCmdList["CLIQUE"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
		text = "點擊法術書右邊外側的按鈕也能綁定法術。\n",
	},
};
D["ColorPickerPlus"] = {
	defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "顏色選擇器 Plus",
	desc = "提供更方便的方式來選擇顏色，可以輸入顏色數值、直接選擇職業顏色，或是將自訂顏色儲存成色票供日後使用。``選擇顏色時會自動出現。`",
	modifier = "彩虹ui",
	img = true,
};
D["ConsolePort"] = {
	defaultEnable = 0,
	tags = { "ENHANCEMENT" },
};
D["CopyAnything"] = {
    defaultEnable = 1,
	tags = { "SOCIAL" },
	title = "快速複製文字",
	desc = "快速複製任何框架上面的文字!``聊天視窗中的文字、隊伍框架上面的隊友名字、選取目標框架上面的怪物名字，甚至是設定選項、插件名稱都能複製。``|cffFF2D2D將滑鼠指向要複製的文字，然後連按兩次 Ctrl+C 就複製好了! ``特別注意：使用前必須先將快速鍵設為 Ctrl+C，詳細請點上方的齒輪圖示標籤頁看用法說明。|r`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\boss_odunrunes_orange",
	{
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory("複製文字")
		end,
    },
	{
		type = "text",
		text = "使用方法：\n\n1.先在 Esc > 選項 > 按鍵綁定 > 插件 > 顯示複製文字，設定快速鍵 (建議設為 Ctrl+C)。\n\n2.將滑鼠指向要複製的文字，按下快速鍵 (例如 Ctrl+C)。\n\n3.在彈出的視窗中拖曳滑鼠選取要複製的文字，按下 Ctrl+C 來複製文字。複製成功視窗會自動關閉。\n\n4.在要貼上文字的地方，例如聊天視窗的輸入框，按下 Ctrl+V 貼上文字。\n",
	},
	{
		type = "text",
		text = "|cffFF2D2D小技巧：滑鼠指向文字後，連按兩次 Ctrl+C 會直接快速複製整段文字。|r\n",
	},
};
D["CursorTrail"] = {
    defaultEnable = 0,
	tags = { "ENHANCEMENT" },
	title = "鼠之軌跡",
	desc = "移動滑鼠時會出現漂亮的彩虹，讓你能夠輕鬆的找到滑鼠游標在哪裡。``有多種滑鼠圖形和軌跡特效可供選擇。`",
	modifier = "彩虹ui",
	{
        text = "設定選項",
        callback = function() SlashCmdList["CursorTrail"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "設定是每個角色分開儲存的，若要共用需使用 /ct 相關指命，詳細請在設定選項中按 '設定檔' 按鈕來查看。",       
	},
};
D["DBM-StatusBarTimers"] = {
    defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "<DBM> 首領技能警報",
	desc = "提供地城/團隊副本首領的技能提醒、倒數計時條和警報功能。``小女孩快跑! 是打團必備的插件。`",
	icon = "Interface\\AddOns\\DBM-Core\\textures\\dbm_airhorn",
	img = true,
    {
        text = "測試計時條",
        callback = function() DBM:DemoMode() end,
    },
    {
        text = "設定選項",
        callback = function() SlashCmdList["DEADLYBOSSMODS"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
		text = "中文語音：輸入 /dbm > 選項 > 語音警告，右邊第五個下拉選單\n'設置語音警告的語音包' 選擇 '安格斯'。\n\n移動計時條：輸入 /dbm > 選項 > 計時條外觀 > 移動。\n\n開啟/關閉大型計時條：輸入 /dbm > 選項 > 計時條外觀 > (內容往下捲) 開啟大型計時條。",
	},
	{
		type = "text",
		text = " ",
	},
};
D["DBM-CountPack-Overwatch"] = {defaultEnable = 1,};
D["DBM-VPSaha"] = {defaultEnable = 1,};
D["DBM-VPSahaJh"] = {defaultEnable = 1,};
D["Decursive"] = {
	defaultEnable = 0,
	tags = { "CLASSALL" },
	title = "(暫時停用) 一鍵驅散",
	desc = "每個隊友會顯示成一個小方格，當隊友獲得 Debuff (負面狀態效果) 時，小方格會亮起來。``點一下亮起來的小方格，立即驅散。``設定選項中還可以設定進階過濾和優先權。`",
	modifier = "Adavak, Archarodim, BNS, deleted_1214024, laincat, sheahoi, titanium0107, YuiFAN, zhTW, 彩虹ui",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_DECURSIVE"]("") end,
    },
	{
        type = "text",
		text = "驅散 Debuff：點一下亮起來的小方格。\n\n移動格子：滑鼠指向第一個小方格的上方 (不是上面)，出現小亮點時按住 Alt 來拖曳移動。\n\n中 Debuff 的玩家清單：在設定選項中開啟或關閉 '即時清單'。",
    },
};
D["Dejunk"] = {
	defaultEnable = 1,
	tags = { "AUCTION" },
	title = "大量賣垃圾",
	desc = "一旦設定好後，便可以自動的大量賣出不要的裝備和物品。可自訂賣出清單和排除清單，刷副本坐騎時特別好用!`",
	modifier = "彩虹ui",
	{
        text = "設定選項",
        callback = function() SlashCmdList["DEJUNK"]("") end,
    },
	{
        text = "顯示垃圾物品",
        callback = function() SlashCmdList["DEJUNK"]("junk") end,
    },
	{
		type = "text",
        text = "點小地圖按鈕的 '大量賣垃圾' 按鈕也可以打開垃圾物品視窗。",
    },
	{
		type = "text",
        text = "使用方法：\n\n拖曳賣出: 點小地圖按鈕打開垃圾物品視窗，將不要的裝備或物品拖曳到視窗中，然後和商人對話按開始賣出。\n\n插件會記住垃圾物品，日後便不用再拖曳，可快速賣出。\n\n設定賣出裝等: 還可以在設定選項中，設定好要賣出裝等多少以下的物品。\n",
    },
};
D["Details"] = {
	defaultEnable = 0,
	title = "Details! 戰鬥統計",
	desc = "可以看自己和隊友的DPS、HPS...等模組化的傷害統計資訊，還有仇恨值表和各種好用的戰鬥分析工具和外掛套件。``|cffFF2D2D特別注意：請勿同時載入兩種戰鬥統計插件，只要載入其中一個就好。`",
	modifier = "BNS, Fang2hou, kxd0116 , lohipp, sheahoi, Whyv, 彩虹ui",
	icon = "Interface\\AddOns\\Details\\images\\minimap",
	img = true,
	{
        text = "顯示/隱藏主視窗",
        callback = function() SlashCmdList["DETAILS"]("toggle") end,
    },
	{
        text = "顯示/隱藏M+計分板",
        callback = function() SlashCmdList["SCORE"]("open") end,
    },
	{
        text = "設定選項",
        callback = function() SlashCmdList["DETAILS"]("config") end,
    },
	{
        text = "重置設定/重新安裝",
        callback = function() SlashCmdList["DETAILS"]("reinstall") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D第一次打勾載入插件不需要重新載入介面，之後若有取消再載入插件都需要重新載入介面。|r",       
	},
	{
        type = "text",
		text = "切換顯示傷害/治療或其他統計：右鍵點戰鬥統計視窗標題。\n\n切換顯示整體/單次傷害：滑鼠指向戰鬥統計視窗右上方的文件圖示。\n\n切換顯示書籤：右鍵點戰鬥統計視窗內容。\n\n開新視窗：滑鼠指向戰鬥統計視窗右上方的小齒輪 > 視窗控制 > 建立視窗。\n\n顯示仇恨值：滑鼠指向戰鬥統計視窗右上方的小齒輪 (不要點它) > 外掛套件：團隊 > Tiny Threat。建議開一個新視窗來專門顯示仇恨表。\n\n|cffFF2D2D要顯示其他人的仇恨值，對方也需要安裝並更新到最新版本的 Details! 戰鬥統計插件。|r\n\n修正距離太遠 (超過50碼) 看不到 DPS 的問題：按下上方的 '開啟/關閉同步資料' 按鈕，或是輸入\n /details sync\n",
    },
};
D["DFFriendlyNameplates"] = {
    defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "友善友方名條",
	desc = "讓你可以設定在副本內開啟友方名條時，是否只要顯示隊友的名字，不顯示隊友的血條和施法條，讓畫面不會那麼混亂。``還可以設定隊友名字的字體、大小...等更多自訂選項，進入副本不需要重新載入介面。``|cffFF2D2D特別注意：可能會遇到某些設定選項會沒有作用。如果使用此插件沒有效果時，可以改用備用的插件 '友方只顯示名字' 。`(目前還不清楚為何有些角色會沒有效果)``請勿和 '友方只顯示名字' 插件同時載入使用，選擇其中一個使用即可。``使用威力血條時，要在副本內顯示隊友名字，請在威力血條設定>自動>隱藏友方血條，取消打勾。|r`",
	icon = "Interface\\Icons\\boss_odunrunes_green",
	{
        text = "設定選項",
        callback = function() SlashCmdList["CFRN"]("") end,
    },
};
D["DialogueUI"] = {
	defaultEnable = 1,
	tags = { "QUEST" },
	title = "任務對話 (羊皮紙)",
	desc = "與NPC對話、接受/交回任務時，將任務內容顯示在羊皮紙上，取代傳統的任務說明，讓你更能享受並融入任務內容的對話劇情。``對話時會隱藏遊戲介面，並將鏡頭拉近放大角色，有沉浸感。也可以設定為不要移動鏡頭。",
	modifier = "彩虹ui",
	{
		type = "text",
        text = "|cffFF2D2D有多種任務對話插件，選擇其中一種載入使用就好，不要同時載入。|r\n",
	},
	{
        type = "text",
		text = "設定選項: 和 NPC 對話時按下 F1。\n",
    },
};
D["Dominos"] = {
	defaultEnable = 1,
	title = "達美樂快捷列",
	desc = "用來取代遊戲內建的主要快捷列，提供方便的快捷列配置、快速鍵設定，讓你可以自由安排快捷列的位置和大小，以及多種自訂功能。`",
	modifier = "彩虹ui",
	img = true,
	{
        text = "設定快捷列",
        callback = function() SlashCmdList["ACECONSOLE_DOMINOS"]("config") end,
    },
	{
        text = "設定快捷鍵",
        callback = function() SlashCmdList["ACECONSOLE_DOMINOS"]("bind") end,
    },
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_DOMINOS"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D施法條：同時出現兩個施法條時，請關閉下方的 '達美樂-施法條' 模組，或是 Stuf 頭像設定 > 玩家 > 施法條，其中一個。|r\n",
	},
	{
		type = "text",
		text = "點小地圖按鈕的 '達美樂快捷列' 按鈕也可以開啟設定。\n\n右鍵自我施法：預設使用滑鼠右鍵點快捷列上的圖示是對自己施放法術，可以在設定選項 > 右鍵點擊的目標是，更改施法對象。\n\n經驗/榮譽/聲望/艾澤萊晶岩條：滑鼠點幾下經驗條來切換顯示。\n\n額外快捷鍵：如果遇到無法移動的額外快捷鍵，請試試將圖示拖曳到快捷列上擺放，或是載入 '版面配置' 插件來移動它。\n\n更多詳細用法和說明請看：\nhttp://wp.me/p7DTni-e1",
	},
	{
		type = "text",
		text = " ",
	}
};
D["Dominos_Cast"] = { defaultEnable = 0, };
D["Dominos_Roll"] = { defaultEnable = 0, };
D["DragonRider"] = {
	defaultEnable = 1,
	tags = { "ENHANCEMENT" }, 
	title = "飛行速度條",
	desc = "顯示天空騎術的飛行速度，方便達成快意翱翔的效果，並且提供一些自訂選項。`",
	modifier = "彩虹ui",
	{
        text = "設定選項",
		callback = function()
			SlashCmdList["DRAGONRIDER"]("option")
		end,
    },
	{
        text = "天空騎術競賽成績",
		callback = function()
			SlashCmdList["DRAGONRIDER"]("")
		end,
    },
};
D["EditModeExpanded"] = {
	defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "編輯模式擴充包",
	desc = "讓編輯模式可以調整更多介面框架。``在設定選項中勾選後，還有更多框架可供調整!``|cffFF2D2D特別注意：請在設定選項中關閉不需要調整的框架，以避免和其他插件衝突。|r`",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory(EditModeExpandedADB.global.EMEOptions.categoryID)
		end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["Exlist"] = {
	defaultEnable = 0,
	tags = { "BOSSRAID" },
	title = "我的分身名冊",
	desc = "快速查看自己所有分身的地城/團隊/世界王擊殺進度、傳奇鑰石/最佳成績、每日/每週/世界任務、金錢、兌換通貨數量、專業、裝備... 還有更多!`",
	modifier = "彩虹ui",
	icon = "Interface\\AddOns\\Exlist\\Media\\Icons\\logo",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["CHARINF"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
		text = "點小地圖按鈕的 'i' 按鈕顯示分身資訊。\n",
	},
	{
		type = "text",
		text = "打開設定選項後，按一下 '顯示設定選項'，左側選單的 '分身' 旁會出現 + 號可以展開來有更多設定。\n\n看不到 + 號的話，上方的標籤頁面先切換到遊戲，再切換回插件就有了。\n",
	},
	{
		type = "text",
		text = "在設定選項中選擇要顯示哪些資訊，角色要橫向或直向排列。\n\n每個分身至少需要登入一次，才會記錄相關資訊。\n",
	}
};
D["FFLU"] = {
	defaultEnable = 1,
	tags = { "QUEST" },
	title = "FF XIV 升級音效",
	desc = "升級時會播放最終幻想14的升級音效。`",
	icon = "Interface\\Icons\\achievement_level_70",
};
D["FriendGroups"] = {
	defaultEnable = 1,
	tags = { "SOCIAL" },
	title = "好友群組",
	desc = "增強遊戲內建的好友名單，可以建立多個不同的群組來分類管理好友名單、顯示職業顏色、搜尋好友、還有更多自訂選項。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_misc_groupneedmore",
	{
		type = "text",
        text = "加入/移出群組: 在好友名字上面點右鍵。\n\n新增/刪除群組/設定選項: 在群組名稱或 [沒有群組] 上面點右鍵。\n",       
	},
};
D["GatherMate2"] = {
	defaultEnable = 0,
	tags = { "PROFESSION" },
	title = "採集助手",
	desc = "採草、挖礦、釣魚的好幫手。``收集草、礦、考古學、寶藏和釣魚的位置，在世界地圖和小地圖上顯示採集點的位置。`",
	modifier = "alpha2009, arith, BNS, chenyuli, ibmibmibm, icearea, jerry99spkk, kagaro, laxgenius, machihchung, morphlings, scars377, sheahoi, soso15, titanium0107, wxx011, zhTW",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["GatherMate2"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r\n\n匯入資料庫：從設定選項>匯入資料>勾選草藥學、採礦...等你想看到的採集點>匯入GatherMate2Data。\n\n只需要匯入一次即可。",
	},
};
D["GTFO"] = {
	defaultEnable = 1,
	tags = { "COMBAT" }, 
	title = "地板傷害警報",
	desc = "你快死了! 麻煩神走位!``踩在會受到傷害的區域上面時會發出警報聲，趕快離開吧!``受到傷害愈嚴重警報聲音愈大，設定選項中可以調整音量。`",
	modifier = "Andyca, BNS, wowuicn, Zensunim",
	icon = "Interface\\Icons\\spell_fire_volcano",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["GTFO"]("options") end,
    },
};
D["GW2_UI"] = {
	defaultEnable = 0,
	tags = { "ENHANCEMENT" },
	title = "GW2 UI (激戰2)",
	desc = "一個經過精心設計，用來替換魔獸世界原本的遊戲介面。讓你可以聚焦在需要專注的地方，心無旁騖地盡情遊戲。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\pet_type_dragon",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["GWSLASH"]("") end,
    },
};
D["HandyMinimapArrow"] = {
	defaultEnable = 0,
	tags = { "MAP" },
	title = "小地圖游標增強",
	desc = "讓你能夠調整小地圖中玩家游標的大小和圖案，並且會顯示在其他插件 (地圖標記、稀有怪) 的圖示上面，避免被遮住，更容易看清楚方向。``|cffFF2D2D特別注意：副本內無法調整小地圖游標，而且還會讓游標變得特別小，如果你不介意的話可以使用。`",
	modifier = "彩虹ui",
	icon = "Interface\\Minimap\\MinimapArrow",
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory(37920793)
		end,
    },
};
D["HandyNotes"] = {
	defaultEnable = 1,
	title = "地圖標記",
	desc = "在地圖上提供方便的標註功能。``搭配相關模組一起使用時，可以在地圖上顯示寶箱、稀有怪...的位置。`",
	modifier = "Sprider @巴哈姆特, BNS, Charlie, 彩虹ui",
	icon = "Interface\\Icons\\icon_treasuremap",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_HANDYNOTES"]("gui") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "如果覺得地圖上的圖示太多太亂，可以在設定選項中關閉不想看到的特定圖示。\n",       
	},
};
D["HideActionbarAnimations"] = {
	defaultEnable = 0,
	tags = { "ACTIONBAR" },
	title = "隱藏快捷列動畫特效",
	desc = "不要顯示 10.1.5 新增的，快捷列圖示施法讀條效果和完成閃光動畫。`",
};
D["HidingBar"] = {
	defaultEnable = 1,
	tags = { "MAP" },
	title = "小地圖按鈕整合",
	desc = "將小地圖周圍的按鈕，整合成一個彈出式按鈕選單!``可以自訂按鈕選單的位置、樣式，選擇要收入哪些按鈕、啟用/停用按鈕、重新排列按鈕，還可以建立多個選單將按鈕分組。自訂性很高!`",
	modifier = "BNS, sfmict, terry1314, 彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["HIDDINGBAR"]("") end,
    },
};
D["iPMythicTimer"] = {
    defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "M+ 時間",
	desc = "在傳奇鑰石的副本中，顯示兩箱、三箱的時間和小怪進度。`",
    {
        text = "設定選項",
        callback = function() SlashCmdList["IPMTOPTS"]("") end,
    },
	{
		type = "text",
        text = "點小地圖按鈕的 'M+ 時間' 按鈕也可以打開設定選項。|n|n移動位置：打開設定選項後，拖曳框架中空白的地方來移動。|n",
    },
};
D["JsFilter"] = {
    defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "預組語言過濾",
	icon = "Interface\\Icons\\inv_10_jewelcrafting3_rainbowprism_color1",
	desc = "在預組隊伍視窗上方新增過濾方式，可以篩選是否要看到簡體中文和英文的隊伍。``|cffFF2D2D特別注意：切換過濾方式後，需要按一下重新搜尋按鈕，隊伍列表才會更新。|r`",
};
D["KeyMaster"] = {
    defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "M+ 鑰石大師",
	desc = "顯示你和隊友的 M+ 詳細資訊，有非常清楚漂亮的介面。`",
    {
        text = "打開主視窗",
        callback = function() SlashCmdList["KeyMaster"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
	{
		type = "text",
        text = "點小地圖按鈕的 '鑰石大師' 按鈕也可以打開主視窗。",
    },
};
D["KeystoneLoot"] = {
    defaultEnable = 0,
	tags = { "ITEM" },
	title = "職業適合裝備查詢",
	desc = "方便尋找在 M+ 地城、團隊和寶庫可取得的裝備，可以依照職業、專精、部位和物品等級來找裝備，還能加入我的最愛。`",
    {
        text = "打開主視窗",
        callback = function() SlashCmdList["KEYSTONELOOT"]("") end,
    },
	{
		type = "text",
        text = "點小地圖按鈕的 '職業適合裝備查詢' 按鈕也可以打開主視窗。",
    },
};
D["Krowi_ExtendedVendorUI"] = {
    defaultEnable = 1,
	tags = { "AUCTION" },
	title = "商人介面增強",
	desc = "加大商人的購買視窗，方便選購，可自訂商人視窗大小。可隱藏已有的寵物、坐騎和玩具，避免重複購買。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_misc_coin_01",
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory("商人")
		end,
    },
	{
		type = "text",
        text = "過濾物品: 點商人視窗右上角的過濾設定。\n",
    },
};
D["Leatrix_Maps"] = {
    defaultEnable = 1,
	tags = { "MAP" },
	title = "世界地圖增強",
	desc = "讓大地圖視窗化，可自由移動位置和調整大小。還有顯示未探索區域、副本入口、區域等級和坐標...等功能。`",
	modifier = "BNS, 彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["Leatrix_Maps"]("") end,
    },
	{
		type = "text",
        text = "移動地圖位置：拖曳地圖四周的邊框。\n\n縮放地圖內容大小：在地圖上捲動滑鼠滾輪。\n\n調整地圖視窗大小：在設定選項中點一下 '縮放地圖大小' 旁的小齒輪來調整百分比。|r\n\n顯示選擇地區的選單：在設定選項中取消勾選 '移除地圖邊框'，然後重新載入介面。\n",
    },
};
D["Leatrix_Plus"] = {
    defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "功能百寶箱",
	desc = "讓生活更美好的插件，提供多種各式各樣的遊戲功能設定。``包括自動修裝、自動賣垃圾、加大鏡頭最遠距離...還有更多功能!",
	modifier = "彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["Leatrix_Plus"]("") end,
    },
	{
		type = "text",
        text = "點小地圖按鈕的 '功能百寶箱' 按鈕，也可以打開主視窗。",
    },
};
D["ls_Glass"] = {
    defaultEnable = 0,
	title = "(請刪除) 聊天視窗美化",
	desc = "這是舊版的插件，已經移除。`請自行刪除 AddOns 裡面的 ls_Glass 資料夾。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_evoker_powerswell",
};
D["ls_Toasts"] = {
    defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "通知面板增強",
	desc = "可以完全自訂彈出式通知面板，移動位置、調整大小、選擇要顯示哪些通知，還有更多自訂選項。``選擇自己想看的通知，讓彈出的通知不會再擋住快捷列或重要的畫面。`",
	modifier = "彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["LSTOASTS"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["MailLogger"] = {
    defaultEnable = 1,
	tags = { "AUCTION" },
	title = "交易通知/記錄",
	desc = "自動記錄與玩家交易，以及郵件的物品內容。方便查看交易歷史記錄。`",
	modifier = "Aoikaze, 彩虹ui",
	icon = "Interface\\MINIMAP\\TRACKING\\Mailbox",
	-- img = true,
	{
        text = "顯示交易記錄",
        callback = function() SlashCmdList["MLC"]("all") end,
    },
    {
        text = "設定選項",
        callback = function() SlashCmdList["MLC"]("gui") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["Masque"] = {
    defaultEnable = 0,
	tags = { "ACTIONBAR" },
	title = "按鈕外觀",
	desc = "讓你可以變換達美樂快捷列、WA 技能提醒、血條浮動戰鬥文字... 等等多種插件的按鈕圖示外觀，讓遊戲介面更具風格!``有許多外觀主題可供選擇。``|cffFF2D2D特別注意：遊戲內建的快捷列不支援更改按鈕外觀。|r`",
	modifier = "a9012456, Adavak, BNS, chenyuli, StormFX, yunrong, zhTW, 彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["MASQUE"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["MythicDungeonTools"] = {
    defaultEnable = 0,
	tags = { "BOSSRAID" },
	title = "M+ 地城規劃工具",
	desc = "顯示副本中小怪的分佈位置，幫助你計算 M+ 的小怪%，方便事先規劃出最佳拉怪路線。要衝層就靠它了！！``還可以將規劃好的路線匯出分享給隊友或其他人，或是和隊友 Live 連線一起同步規劃路線。`",
	modifier = "彩虹ui",
	img = true,
    {
        text = "顯示主視窗",
        callback = function() SlashCmdList["MYTHICDUNGEONTOOLS"]("") end,
    },
	{
        text = "重置視窗位置",
        callback = function() SlashCmdList["MYTHICDUNGEONTOOLS"]("reset") end,
    },
	{
		type = "text",
        text = "點小地圖按鈕的 'M+ 地城規劃工具' 按鈕也可以打開主視窗。\n",
    },
	{
		type = "text",
        text = "迷你視窗：點主視窗右上角的縮小箭頭切換成迷你導覽視窗。\n\n(下方的插件模組需要打勾載入)\n",
    },
};
D["MidnightSimpleUnitFrames"] = {
    defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "至暗之夜頭像",
	desc = "替換遊戲內建的單位框架，提供更簡潔、直觀且可高度自訂的介面。它的設計理念是將戰鬥資訊集中在角色附近，避免玩家需要分散注意力到螢幕角落。`",
    {
        text = "設定選項",
        callback = function() SlashCmdList["MIDNIGHTSUF"]("") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
};
D["MikScrollingBattleText"] = {
    defaultEnable = 0,
	tags = { "COMBAT" },
	title = "MSBT捲動戰鬥文字",
	desc = "讓打怪的傷害數字和系統訊息，整齊的在角色周圍捲動。``可以自訂顯示的位置、大小和要顯示哪些戰鬥文字。`",
	icon = "Interface\\Icons\\ability_warrior_challange",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["MSBT"]("") end,
    },
};
D["Molinari"] = {
    defaultEnable = 0,
	title = "一鍵分解物品",
	desc = "提供快速拆裝分解、研磨草藥、勘探寶石和開鎖的功能!``只要按下 Ctrl+Alt 鍵再點一下背包中物品，立馬分解!``設定選項中可以將要避免不小心被處理掉的物品加入忽略清單。`",
    {
        text = "設定選項",
        callback = function() SlashCmdList["MolinariSlash"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "分解物品：滑鼠指向背包內要分解或處理的物品，按住 Ctrl+Alt 鍵不放，再用滑鼠左鍵點一下物品，即可執行專業技能的處理動作。\n\n只能分解或處理背包和交易視窗內的物品，銀行中的不行。\n\n|cffFF2D2D使用 'DJ智能分類背包' 時，請勿將一鍵分解物品的輔助鍵設為只有 Alt 鍵，以避免和自訂物品分類的快速鍵相衝突。|r",
    },
};
D["MRT"] = {
	defaultEnable = 0,
	tags = { "BOSSRAID" },
	title = "MRT 團隊工具包",
	desc = "提供出團時會用到的許多方便功能。像是團隊分析觀察、準備確認、檢查食物精煉、上光柱標記助手、團隊技能CD監控、團隊輔助工具和一些首領的戰鬥模組...等。`",
	modifier = "永霜, BNS",
	icon = "Interface\\AddOns\\MRT\\media\\OptionLogo2",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["mrtSlash"]("set") end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
	{
		type = "text",
		text = "點小地圖按鈕的 'MRT 團隊工具包' 按鈕也可以開啟設定選項。",
	}
};
D["NoAutoClose"] = {
    defaultEnable = 0,
	tags = { "ENHANCEMENT" },
	title = "同時打開多個視窗",
	desc = "打開新視窗時，讓其他視窗不會自動關閉。",
	modifier = "彩虹ui",
	{
        text = "設定選項",
        callback = function() SlashCmdList["NOAUTOCLOSE"]("") end,
    },
};
D["OPie"] = {
    defaultEnable = 0,
	title = "環形快捷列",
	desc = "按下快速鍵時顯示圓環形的技能群組，可以做為輔助的快捷列使用，十分方便!`",
	modifier = "foxlit, moseciqing, zhTW, 彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["OPIE"]("") end,
    },
	{
		type = "text",
        text = "開始使用：在設定選項的 '快速鍵' 中幫環形快捷列設定按鍵。",
	},
	{
		type = "text",
        text = " ",
	},
};
D["ParagonReputation"] = {
    defaultEnable = 0,
	tags = { "ENHANCEMENT" },
	title = "巔峰聲望",
	desc = "顯示巔峰聲望進度、聲望獎勵的收集進度，以及領取巔峰箱的通知。`",
	modifier = "彩虹ui",
     {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory(ParagonReputationDB.categoryID)
		end,
    },
};
D["Pawn"] = {
    defaultEnable = 1,
	title = "裝備屬性比較",
	desc = "計算屬性 EP 值並給予裝備提升百分比的建議。``此建議適用於大部分的情況，但因為天賦、配裝和手法流派不同，所需求的屬性可能不太一樣，這時可以自訂屬性權重分數，以便完全符合個人需求。`",
	author = "VgerAN",
	modifier = "BNS, scars377, 彩虹ui",
	icon = "Interface\\Icons\\achievement_garrisonfollower_levelup",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["PAWN"]("") end,
    },
	{
		type = "text",
        text = "遊戲有內建裝備比較的功能，只要滑指向裝備物品時，按住 Shift 鍵不放，便能和自己身上的裝備做比較。\n\n如果想要不用按 Shift 鍵，總是會自動比較裝備，請輸入: \n\n/console set alwaysCompareItems 1\n\n(必須輸入在同一行，不要換行)",       
	},
};
D["PetTracker"] = {
    defaultEnable = 0,
	title = "(暫時停用) 戰寵助手",
	desc = "追蹤你在該區域已有和缺少的戰寵。`",
	img = true,
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory(PetTracker_Sets.categoryID)
		end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["Platynator"] = {
    defaultEnable = 1,
	tags = { "UNITFRAME" },
	title = "鉑金血條",
	desc = "簡單易用、可高度自訂的名條插件，設計上兼顧效能與靈活性。它提供即時視覺化編輯器，讓玩家能快速調整名條外觀。`",
    {
        text = "設定選項",
        callback = function() SlashCmdList["Platynator"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
};
D["Postal"] = {
	defaultEnable = 1,
	title = "超強信箱",
	desc = "強化信箱功能。``收件人可以快速地選擇分身，避免寄錯；一次收取所有信件，還有更多功能。`",
	modifier = "a9012456, Adavak, andy52005, BNS, NightOw1, smartdavislin, titanium0107, whocare, Whyv",
	img = true,
};
D["PremadeGroupsFilter"] = {
    defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "預組隊伍過濾",
	desc = "提供進階的過濾方式來篩選隊伍。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_dualwieldspecialization",
	{
        text = "設定選項",
        callback = function() 
			premadeGroupsFilterOpenSettings()
		end,
    },
};
D["PremadeSort"] = {
    defaultEnable = 1,
	tags = { "BOSSRAID" },
	title = "預組隊伍排序",
	desc = "讓預組隊伍列表依據隊伍建立的時間排序。``報名按鈕旁打勾時，點兩下隊伍名稱可以直接報名隊伍，並且跳過選擇角色職責。",
	modifier = "彩虹ui",
	{
        text = "顯示/隱藏時間標記",
        callback = function() SlashCmdList["PREMADESORT"]("timestamp") end,
    },
	{
		type = "text",
        text = "按下顯示/隱藏時間標記後需要重新整理預組隊伍列表才會有效果。\n",       
	},
};
D["PrettyReps"] = {
    defaultEnable = 0,
	tags = { "ENHANCEMENT" },
	title = "聲望介面增強",
	desc = "在聲望介面中，顯示目前角色和帳號中所有角色最高的聲望，並且提供加入最愛和巔峰聲望條的功能。``|cffFF2D2D需要將其他角色登入一次才會計算該角色的聲望。|r`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\achievement_reputation_05",
	img = true,
	{
		type = "text",
        text = "切換帳號/角色聲望：點聲望介面上方的標籤頁。\n\n設定選項：點聲望介面右上角的小三角箭頭。\n",       
	},
};
D["Quartz"] = {
	defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "Quartz 施法條",
	desc = "功能增強、模組化、可自訂外觀的施法條。``包括玩家、寵物的施法條，還有 GCD、揮擊、增益/減益效果和環境對應的計時條，都可以自訂調整。``|cffFF2D2D特別注意：請勿和 '內建施法條增強' 插件一起使用。|r`",
	modifier = "a9012456, Adavak, alpha2009, Adavak, Ananhaid, nevcairiel, Seelerv, Whyv, YuiFAN, 半熟魷魚, 彩虹ui",
	icon = "Interface\\Icons\\spell_holy_divineprovidence",
	img = true,
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory("施法條")
		end,
    },
};
D["QuestPlates"] = {
    defaultEnable = 1,
	tags = { "QUEST" },
	title = "(請刪除) 任務怪提示",
	desc = "這是舊版的插件，已經移除。`請自行刪除 AddOns 裡面的 QuestPlates 資料夾。`",
	img = true,
};
D["QuickTargets"] = {
    defaultEnable = 0,
	tags = { "BOSSRAID" },
	title = "快速上標",
	desc = "快速幫目標加上骷髏、叉叉、星星、月亮...等標記圖示，只要按一下快速鍵!``|cffFF2D2D第一次使用前請先在 Esc > 選項 > 按鍵綁定 > 插件 > 快速上標，設定好快速鍵。|r`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_creature_cursed_02",
	-- img = true,
	{
		type = "text",
        text = "先在 Esc > 選項 > 按鍵綁定 > 插件 > 快速上標，設定好快速鍵 (預設為 Shift+F，如果曾經有調整過按鍵設定就需要重新設定)。\n\n把滑鼠指向要上標的對象，按下快速鍵直接上標，不用選取為目標。\n\n上標時多按幾下快速鍵可以循環切換成不同的標記圖示。\n",       
	},
};
D["RandomHearth"] = {
	defaultEnable = 1,
	tags = { "ITEM" },
	title = "隨機爐石",
	desc = "隨機使用你有的爐石玩具。``載入後會自動產生一個叫做 '爐石' 的巨集，將這個巨集拖曳到快捷列上使用即可。``可以在設定選項中選擇要隨機使用哪些爐石玩具。`",
	modifier = "BNS, 彩虹ui",
	icon = "Interface\\Icons\\inv_10_misc_dragonorb_color1",
	{
        text = "設定選項",
        callback = function() SlashCmdList["RandomHearthstone"]("") end,
    },
};
D["RangeDisplay"] = {
    defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "顯示距離",
	desc = "顯示你和目標之間的距離，包括當前目標、專注目標、寵物、滑鼠指向對象以及競技場對象。還可以依據距離遠近來設定警告音效。``|cffFF2D2D特別注意：Stuf 頭像已有顯示距離的功能，如無特別需求可以不用載入這個插件。|r``使用暴雪頭像 (美化調整) 或遊戲內建的頭像時，可以搭配此插件一起使用。`",
	modifier = "alpha2009, BNS, lcncg, 彩虹ui",
	icon = "Interface\\Icons\\ability_hunter_pathfinding",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["RANGEDISPLAY"]("") end,
    },
	{
		type = "text",
        text = "第一次使用請從設定選項中將距離數字框架鎖定，或解鎖移動。",       
	},
	{
		type = "text",
        text = " ",       
	},
};
D["ReloadUI"] = {
	defaultEnable = 1,
	tags = { "MISC" },
	title = "重新載入按鈕",
	desc = "在按 Esc 的遊戲選單和選項視窗加上重新載入按鈕，調整UI或遇到汙染問題，需要常常 /reload 時非常好用。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_vehicle_loadselfcatapult",
};
D["Rematch"] = {
	defaultEnable = 0,
	title = "寵物再戰",
	desc = "寵物日誌介面增強，可以儲存對戰隊伍，對戰時快速載入隊伍，管理和升級戰寵更方便。`",
	modifier = "彩虹ui",
	img = true,
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "按 Shift+P 打開收藏視窗 > 寵物日誌，就會發現不一樣!",       
	},
};
D["REPorter"] = {
	defaultEnable = 0,
	title = "戰場地圖",
	desc = "加強型的戰場地圖，包含戰場喊話的功能。`",
	modifier = "chenyuli, ningxi, 彩虹ui",
	img = true,
	{
        text = "設定選項",
        callback = function() 
			local REPorterSettings = LibStub("AceDB-3.0"):New("REPorterSettings")
			Settings.OpenToCategory(REPorterSettings.profile.categoryID)
		end,
    },
	{
		type = "text",
        text = "切換地圖顯示內容：按住 Shift+Alt 或 Shift+Ctrl 點地圖。\n\n喊話通報到頻道：點地圖上的點，或是地圖旁的按鈕。\n",       
	},
};
D["SexyMap"] = {
    defaultEnable = 0,
	title = "性感小地圖",
	desc = "讓你的小地圖更具特色和樂趣，並增添一些性感的選項設定。`",
	icon = "Interface\\Icons\\spell_arcane_blast",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["SexyMap"]("") end,
    },
	{
		type = "text",
		text = "坐標：在設定選項中啟用。\n",
	},
};
D["SharedMedia_Rainbow"] = {
    defaultEnable = 1,
	tags = { "MISC" },
	title = "彩虹字體材質包",
	desc = "讓不同的插件能夠共享材質、背景、邊框、字體和音效，也提供了多種中英文字體和材質可供設定插件時使用。``|cffFF2D2D特別注意：在插件的設定中選擇字體時，英文字體只能顯示英文、無法顯示中文 (遇到中文字會變成問號)。如有需要顯示中文，請選擇中文字體。|r`",
	icon = "Interface\\Icons\\achievement_doublerainbow",
};
D["SharedMedia_BNS"] = {
    defaultEnable = 1,
	tags = { "MISC" },
	title = "BNS 音效材質包",
	desc = "讓不同的插件能夠共享材質、背景、邊框、字體和音效，也提供了多種中英文字體、音效和材質可供 WA 和其他插件使用。`",
};
D["Shooter"] = {
	defaultEnable = 1,
	title = "成就自動截圖",
	desc = "獲得成就時會自動擷取螢幕畫面，為你的魔獸生活捕捉難忘的回憶。``畫面截圖都存放在`World of Warcraft > _retail_ > Screenshots 資料夾內。`",
	icon = "Interface\\Icons\\inv_misc_toy_07",
	img = true,
};
D["SilverDragon"] = {
    defaultEnable = 0,
	tags = { "MAP" },
	title = "稀有怪獸與牠們的產地",
	desc = "功能強大的稀有怪通知插件，記錄稀有怪的位置和時間，發現時會通知你。支援舊地圖的稀有怪!``發現稀有怪獸時預設的通知效果會顯示通知面板、螢幕閃紅光和發出音效，還可以和隊友、公會同步通知發現的稀有怪，都可以在設定選項中調整。`",
	modifier = "彩虹ui",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_SILVERDRAGON"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "|cffFF2D2D如果稀有怪的名字是英文的，請重開遊戲，就會顯示中文了 (只重登可能無效)。|r",       
	},
};
D["SilverPlateTweaks"] = {
	defaultEnable = 1,
	tags = { "UNITFRAME" },
	title = "血條距離微調",
	desc = "自動調整血條的視野距離 (可以看見距離多遠範圍內的血條) 和堆疊時的間距，以及一些其他的 CVar 遊戲參數。``|cffFF2D2D若要手動調整血條距離時 (從 Esc > 介面 > 插件 > 進階)，請關閉這個插件。|r`",
	icon = "Interface\\Icons\\spell_misc_hellifrepvpcombatmorale",
	img = true,
};
D["SimpleAssistedCombatIcon"] = {
    defaultEnable = 0,
	tags = { "COMBAT" },
	title = "簡易輸出助手",
	desc = "將當前建議施放的技能以圖示形式顯示在螢幕上，讓玩家不必時刻盯著快捷列，就能快速掌握戰鬥節奏。`",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_SACI"]("") end,
    },
};
D["SimpleQuestPlates"] = {
    defaultEnable = 1,
	tags = { "QUEST" },
	title = "簡易任務怪提示",
	desc = "在任務怪名字和血條的左側顯示任務目標進度的提示圖示，開啟敵方血條就會出現。``圖示內的數字表示完成任務還需要多少數量或百分比。",
	modifier = "彩虹ui",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["SQP"]("") end,
    },
};
D["SmartQuest"] = {
    defaultEnable = 1,
	title = "智能任務通報",
	desc = "追蹤和通報隊伍成員的任務進度，一起組隊解任務時粉方便!``|cffFF2D2D特別注意：有安裝並載入這個插件的隊友，才會互相通報任務進度。|r`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\achievement_quests_completed_uldum",
    {
        text = "設定選項",
        callback = function() SlashCmdList["SMARTQUEST"]("OPTIONS") end,
    },
};
D["Spy"] = {
    defaultEnable = 0,
	title = "偵測敵方玩家",
	desc = "PvP 的野外求生的利器，偵測並列出附近所有的敵對陣營玩家。將玩家加入 KOS 即殺清單，出現在你附近時便會播放警告音效，或是通報到聊天頻道。``還能夠和公會、隊伍、團隊成員分享即殺玩家的資料，自保圍剿兩相宜。也會記錄最近遇到的敵方玩家和勝敗次數統計。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\achievement_pvp_a_h",
	img = true,
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
        text = "顯示主視窗",
        callback = function() SlashCmdList["ACECONSOLE_SPY"]("show") end,
    },
    {
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_SPY"]("config") end,
    },
	{
        text = "調整警告位置",
        callback = function() SlashCmdList["ACECONSOLE_SPY"]("test") end,
    },
	{
        text = "恢復為預設值",
        callback = function() SlashCmdList["ACECONSOLE_SPY"]("reset") end,
    },
	{
		type = "text",
        text = "選取為目標：點一下主視窗中的玩家名字，非戰鬥中才可以使用。\n\n加入即殺/忽略清單：右鍵點擊主視窗中的玩家名字，或是按住 Ctrl 點玩家名字直接加入忽略清單、按住 Shift 點玩家名字直接加入即殺清單。\n\n調整警告位置：需先在設定選項 > 警告 > 選擇警告訊息的位置 > 選擇 '可移動的'，按下上方的調整警告位置按鈕時，才能拖曳移動位置\n。",
    },
};
D["Stuf"] = {
    defaultEnable = 0,
	title = "Stuf 頭像",
	desc = "玩家、目標、小隊和首領頭像血條框架，簡單好用自訂性高!``也有傳統頭像樣式和其他外觀樣式可供選擇，詳細用法說明請看：`http://wp.me/p7DTni-142`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_misc_petmoonkinta",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["STUF"]("") SlashCmdList["STUF"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "看不到設定選項時，請先按 Esc 或 '取消' 關閉設定視窗，然後再按一次 '設定選項' 按鈕。\n\n點選自己/隊友：要點在血量條上 (有顏色的地方)，點其他地方無法選取。\n\n職業資源條：與 '編輯模式擴充包' 插件一起使用時，可以使用編輯模式擴充包來調整職業資源條的位置。\n\n如果要使用 Stuf 頭像的選項調整職業資源條，需要在 Esc > 選項 > 插件 > 編輯模式 > 你的職業資源條，取消打勾 > 重新載入介面。\n\n詳細用法說明請看：\nhttp://wp.me/p7DTni-142\n",       
	},
	{
		type = "text",
        text = " ",       
	},
};
D["Syndicator"] = {
    defaultEnable = 1,
	tags = { "ITEM" },
	title = "多角色物品統計",
	desc = "在物品的浮動提示資訊中顯示其他角色擁有此物品的數量，可在設定選項中調整要顯示幾個角色。``可搭配內建背包或任意背包插件一起使用。``|cffFF2D2D其他角色需要登入一次並且打開銀行後，才會記錄該角色的物品。|r`",
	modifier = "BNS, plusmouse, 彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["Syndicator"]("") end,
    },
	{
		type = "text",
        text = "\n隱藏角色資料: 請輸入\n /syn hide 角色名字-伺服器\n\n刪除角色資料: 請輸入\n /syn remove 角色名字-伺服器\n\n|cffFF2D2D隱藏或刪除完後，若物品的浮動提示出現大量資訊，按一下 Shift 鍵即可。|r\n",       
	},
};
D["TankMD"] = {
	defaultEnable = 0,
	tags = { "CLASSALL" },
	title = "一鍵誤導/偷天/啟動",
	desc = "只要一個按鈕或快速鍵便會自動偷天/誤導坦克，德魯伊則會啟動補師，不用切換選取目標!``無須將坦克/補師選為目標或設為專注目標，隊伍順序重新排列也沒問題。``可以設定兩個按鈕或快速鍵，分別給兩個不同的坦克/補師。``沒有隊伍或隊伍中沒有坦克時，獵人會自動誤導給寵物。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_hunter_misdirection",
	img = true,
	 {
        text = "設定選項",
        callback = function()
			local TankMDSettings = LibStub("AceDB-3.0"):New("TankMDDB")
			Settings.OpenToCategory(TankMDSettings.profile.categoryID)
		end,
    },
	{
		type = "text",
		text = "快速鍵：從 Esc > 選項 > 按鍵綁定 > 插件 > 一鍵誤導/偷天/啟動，設定按鍵。\n\n快捷列按鈕：新增巨集拉到快捷列上。\n\n誤導給第一個坦克的巨集內容為：\n\n#showtooltip 誤導\n/click TankMDButton1 LeftButton 1\n/click TankMDButton1 LeftButton 0\n\n誤導給第二個坦克的巨集內容為：\n\n#showtooltip 誤導\n/click TankMDButton2 LeftButton 1\n/click TankMDButton2 LeftButton 0\n\n(每個 /click ... 為同一行不換行)\n\n盜賊和德魯伊請自行將誤導改為偷天換日或啟動\n\n這是插件所提供的巨集指令，需要載入插件才能使用。",
	}
};
D["TargetNameplateIndicator"] = {
	defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "目標指示箭頭",
	desc = "在當前目標、專注目標、滑鼠指向目標和目標的目標血條上方顯示箭頭，讓目標更明顯。``|cffFF2D2D特別注意：一定要開啟敵方和友方的名條/血條，才能顯示出箭頭。|r`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_warrior_charge",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_TNI"]("") end,
    },
};
D["TeleportMenu"] = {
	defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "傳送選單",
	desc = "在 Esc 遊戲選單旁邊顯示各種爐石/傳送法術的按鈕。`",
	modifier = "BNS, 彩虹ui",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["TPMENU"]("") end,
    },
};
D["TidyPlates_ThreatPlates"] = {
    defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "威力血條",
	desc = "威力強大、能夠根據仇恨值變化血條、提供更多自訂選項的血條。還可以幫指定的怪自訂血條樣式，讓血條更清楚明顯。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\ability_warrior_innerrage",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["ACECONSOLE_TPTP"]("") end,
    },
	{
        text = "切換血條重疊/堆疊",
        callback = function() SlashCmdList["TPTPOVERLAP"]("") end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "|cffFF2D2D請勿和 '經典血條 Plus' 同時載入使用。|r",       
	},
	{
		type = "text",
        text = "增益圖示：從設定選項 > 套件 > 光環 > 增益，調整是否要在血條上顯示增益圖示。\n\n顯示激勵或其他敵方增益圖示：從設定選項 > 套件 > 光環 > 增益 > NPC 全部，打勾。\n",
	},
	{
		type = "text",
        text = "保持顯示血條：威力血條有血條檢視 (同時顯示血條和名字) 和 名字檢視 (只顯示名字) 兩種模式，預設為離開戰鬥會自動切換成名字檢視，讓非戰鬥時能夠充分享受遊戲內容畫面，不受血條干擾。|n|n要啟用/停用自動切換血條的檢視模式，請到設定選項 > 一般設定 > 自動 > 非戰鬥中使用名字檢視。\n\nEsc > 介面 > 名稱 > 總是顯示名條，也要記得打勾。\n",
	},
};
D["TinyChat"] = {
	defaultEnable = 1,
	tags = { "SOCIAL" },
	title = "聊天按鈕和功能增強",
	desc = "一個超輕量級的聊天功能增強插件。``提供快速切換頻道按鈕、表情圖案、開怪倒數、擲骰子、顯示物品圖示...還有更多功能。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_misc_food_28",
    img = true,
	{
        text = "重置聊天按鈕位置",
        callback = function() resetTinyChat() end,
    },
	{
		type = "text",
		text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",
	},
	{
		type = "text",
        text = "使用方法：\n\n聊天增強設定選項：右鍵點頻道按鈕最左側的小圖示。\n\n移動頻道按鈕：按住 Alt 鍵拖曳頻道按鈕最左側的小圖示。\n\n顯示/隱藏社群頻道按鈕：設定選項 > 顯示頻道按鈕 > 社群頻道。\n\n切換頻道：左鍵點聊天視窗上方的頻道名稱。\n\n開啟/關閉頻道：右鍵點聊天視窗上方的頻道名稱。\n\n快速切換頻道：輸入文字時按 Tab 鍵。\n\n快速輸入之前的內容：輸入文字時按上下鍵。\n\n快速捲動到最上/下面：按住 Ctrl 滾動滑鼠滾輪。\n\n輸入表情符號：打字時輸入 { 會顯示表情符號選單。\n\n開怪倒數：左鍵點 '開' 會開始倒數，右鍵點 '開' 會取消倒數。\n\n開怪倒數時間和喊話：右鍵點頻道按鈕最左側的小圖示 > 開怪倒數。\n\n對話泡泡：方便快速手動開/關對話泡泡。\n",
	},
};
D["TinyInspect"] = {
    defaultEnable = 1,
	tags = { "ITEM" },
	title = "裝備觀察",
	desc = "觀察其他玩家和自己時會在角色資訊視窗右方列出已裝備的物品清單，方便查看裝備和物品等級。``還包含裝備欄物品等級、背包中物品等級，和滑鼠提示中顯示玩家專精和裝等的功能。`",
	icon = "Interface\\Icons\\achievement_garrisonfollower_itemlevel650",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["TinyInspect"]("") end,
    },
};
D["TinyTooltip-Reforged"] = {
    defaultEnable = 0,
	title = "(請刪除) 浮動提示資訊增強",
	desc = "這是舊版的插件，已經移除。`請自行刪除 AddOns 裡面的 TinyTooltip-Reforged 資料夾。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_wand_02",
};
D["TinyTooltip-Remake"] = {
    defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "浮動提示資訊增強",
	desc = "重製並優化遊戲中的浮動提示資訊，讓玩家在查看目標資訊時能獲得更清晰、直觀的體驗。`",
	modifier = "彩虹ui",
	icon = "Interface\\Icons\\inv_wand_02",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["TinyTooltip"]("general") end,
    },
	{
        text = "恢復為預設值",
        callback = function() SlashCmdList["TinyTooltip"]("reset") end,
		reload = true,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
		text = "移動位置：在遊戲內建的編輯模式中勾選 '浮動提示資訊' 來移動位置。\n\n查看法術ID：滑鼠指向時按住 Alt 鍵。\n\n戰鬥中顯示滑鼠提示：在設定選項中取消勾選 '戰鬥中隱藏'，玩家和NPC的戰鬥中隱藏也要分別取消勾選。\n\nDIY 模式：在設定選項中按下 DIY，可以分別拖曳每種資訊文字，自行安排呈現的位置。\n\n|cffFF2D2D請勿同時開啟 功能百寶箱 > 界面設置 > 增強工具提示 的功能，以免發生衝突。|r\n",
	},
};
D["tullaRange"] = {
    defaultEnable = 1,
	title = "射程著色",
	desc = "超出射程時，快捷列圖示會顯示紅色，能量不足時顯示藍色，技能無法使用時顯示灰色。`",
	img = true,
    {
        text = "設定選項",
        callback = function() 
			Settings.OpenToCategory(TULLARANGE_COLORS.categoryID)
		end,
    },
};
D["UnlimitedMapPinDistance"] = {
    defaultEnable = 1,
	tags = { "MAP" },
	title = "無限距離導航",
	desc = "移除遊戲內建的任務導航/地圖標記導航距離只有 1000 碼的限制，很遠的地方都能導航。但有些受限制的區域仍無法導航。``並且提供輸入指令 /way、/uway 或 /pin 加上坐標數字來建立地圖標記導航的功能。``還能自動開始導航，(按住 Ctrl 鍵在世界地圖上點一下) 建立遊戲內建的地圖標記後，會自動開始導航，不用再多點一下剛建立的地圖標記。`",
	icon = "Interface\\Icons\\inv_10_elementalcombinedfoozles_titan",
	img = true,
	{
        text = "設定選項",
        callback = function() SlashCmdList["UMPDO"]("") end,
    },
};
D["VCB"] = {
    defaultEnable = 1,
	tags = { "UNITFRAME" },
	title = "內建施法條增強",
	desc = "幫遊戲內建的施法條加入一些巫毒魔法，顯示法術圖示、時間、延遲和施法斷點。``|cffFF2D2D特別注意：請勿和 'Quartz 施法條' 插件一起使用。|r`",
	icon = "Interface\\Icons\\spell_holy_surgeoflight_shadow",
	modifier = "彩虹ui",
    {
        text = "設定選項",
        callback = function() SlashCmdList["VCB"]("") end,
    },
};
D["VuhDo"] = {
    defaultEnable = 0,
	tags = { "UNITFRAME" },
	title = "團隊框架 (巫毒)",
	desc = "功能強大的補血框架，可用來取代內建的隊伍/團隊框架，滑鼠點一下就能快速施放法術/補血，是補師的好朋友!``可以自訂框架的外觀、順序，提供治療、驅散、施放增益效果、使用飾品、距離檢查和仇恨提示和更多功能。``還有精美且清楚的 HOT 和動畫效果提醒驅散的 DEBUFF 圖示。`",
	img = true,
    {
        text = "設定選項",
        callback = function() SlashCmdList["VUHDO"]("opt") end,
    },
	{
		type = "text",
        text = "設定檔懶人包匯入教學請看\nhttps://addons.miliui.com/show/49/4\n\n更多設定檔下載\nhttps://wago.io/vuhdo\n",
	},
};
D["WIM"] = {
    defaultEnable = 1,
	title = "魔獸世界即時通",
	desc = "密語會彈出小視窗，就像使用即時通訊軟體般的方便。``隨時可以查看密語，不會干擾戰鬥，也有密語歷史記錄的功能。`",
	modifier = "wuchiwa, zhTW",
	icon = "Interface\\Icons\\ui_chat",
	img = true,
    {
        text = "設定選項",
        callback = function() WIM.ShowOptions() end,
    },
	{
		type = "text",
        text = "|cffFF2D2D啟用插件後需要重新載入介面。|r",       
	},
	{
		type = "text",
        text = "點小地圖按鈕的 '即時通' 按鈕顯示密語視窗。",
	},
};
D["WorldQuestTracker"] = {
	defaultEnable = 1,
	tags = { "QUEST" },
	title = "世界任務追蹤",
	desc = "加強地圖上世界任務圖示的相關功能、提供世界任務追蹤清單，更容易找到和追蹤你要的世界任務。`",
	modifier = "BNS, mccma, qkdev5307, sopgri, 彩虹ui",
	icon = "Interface\\Icons\\inv_ability_holyfire_orb",
	{
		type = "text",
        text = "點世界地圖左下角的 '選項' 進行設定。",
	},

};
D["WorldQuestTab"] = {
	defaultEnable = 1,
	tags = { "QUEST" },
	title = "世界任務標籤頁",
	desc = "在世界地圖旁的任務記錄中顯示世界任務的標籤頁面，可以過濾任務和加入追蹤，操作方式和一般的任務完全相同!``還會增強世界地圖上面的世界任務圖示。`",
	modifier = "BNS, LanceDH, 流水輕飄, 彩虹ui",
	{
		type = "text",
        text = "設定選項：點世界地圖旁的世界任務標籤頁 > 過濾方式 > 設定。",
	},
};
D["XIV_Databar_Continued"] = {
    defaultEnable = 1,
	tags = { "ENHANCEMENT" },
	title = "功能資訊列",
	desc = "在畫面最下方顯示一排遊戲功能小圖示，取代原本的微型選單和背包按鈕。還會顯示時間、耐久度、天賦、專業、兌換通貨、金錢、傳送和系統資訊等等。``在設定選項中可以自行選擇要顯示哪些資訊、調整位置和顏色。`",
	modifier = "彩虹ui",
	img = true,
    {
        text = "設定選項",
		callback = function()
			local XIVBarSettings = LibStub("AceDB-3.0"):New("XIVBarDB")
			Settings.OpenToCategory(XIVBarSettings.profile.categoryID)
		end,
    },
	{
		type = "text",
        text = "設定功能模組：打開設定選項視窗後，在視窗左側點 '資訊列' 旁的加號將它展開，再選擇 '功能模組'。\n",
	},
	{
		type = "text",
        text = "開啟/關閉功能模組後如果沒有正常顯示，請重新載入。",
	},
};
D["YouGotMail"] = {
	defaultEnable = 1,
	tags = { "ITEM" },
	title = "新郵件通知音效",
	desc = "收到新的郵件時會播放 You got mail 經典音效。`",
	icon = "Interface\\Icons\\achievement_guildperk_gmail",
};