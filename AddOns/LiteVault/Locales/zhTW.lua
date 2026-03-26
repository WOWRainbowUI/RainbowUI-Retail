-- zhTW.lua - Traditional Chinese locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",
    ADDON_VERSION = "v12.0.1",

    -- ==========================================================================
    -- COMMON UI ELEMENTS
    -- ==========================================================================
    BUTTON_CLOSE = "關閉",
    BUTTON_YES = "是",
    BUTTON_NO = "否",
    BUTTON_MANAGE = "管理",
    BUTTON_BACK = "返回上頁",
    BUTTON_ALL = "全部",
    BUTTON_NONE = "無",
    BUTTON_FILTER = "篩選",
    DIALOG_DELETE_CHAR = "要從戰隊追蹤刪除 %s 嗎？",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "戰隊追蹤",
    TITLE_MAP_FILTERS = "地圖篩選",

    BUTTON_RAID_LOCKOUTS = "團隊鎖定",
    BUTTON_WORLD_EVENTS = "世界事件",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "團隊鎖定",
    TOOLTIP_RAID_LOCKOUTS_DESC = "查看團隊鎖定與進度",
    TOOLTIP_ACTIONS_TITLE = "角色動作",
    TOOLTIP_ACTIONS_DESC = "開啟動作選單",
    TOOLTIP_THEME_TITLE = "切換主題",
    TOOLTIP_THEME_DESC = "在暗色與亮色主題間切換",
    TOOLTIP_FILTER_TITLE = "地圖篩選",
    TOOLTIP_FILTER_DESC = "點擊查看完整清單",
    TOOLTIP_WORLD_EVENTS_TITLE = "世界事件",
    TOOLTIP_WORLD_EVENTS_DESC = "檢視世界事件",

    BUTTON_INSTANCES = "副本",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "副本追蹤器",
    TOOLTIP_INSTANCE_TRACKER_DESC = "追蹤地城與團隊次數",
    BUTTON_VAULT = "寶庫",
    BUTTON_ACTIONS = "動作",
    BUTTON_RAIDS = "團隊",
    BUTTON_FAVORITE = "最愛",
    BUTTON_UNFAVORITE = "取消最愛",
    BUTTON_IGNORE = "忽略",
    BUTTON_RESTORE = "還原",
    BUTTON_DELETE = "刪除",

    -- Sort controls
    LABEL_SORT_BY = "排序方式：",
    SORT_GOLD = "金幣",
    SORT_ILVL = "裝等",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "最近活躍",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "%s的每週任務",
    BUTTON_WEEKLIES = "每週",
    BUTTON_EVENTS = "事件",
    BUTTON_FACTIONS = "陣營",
    BUTTON_AMANI_TRIBE = "阿曼尼部族",
    BUTTON_HARATI = "哈拉提",
    BUTTON_SINGULARITY = "奇異點",
    BUTTON_SILVERMOON_COURT = "銀月城宮廷",
    TITLE_FACTION_WEEKLIES = "%s的陣營每週任務",
    LABEL_RENOWN_PROGRESS = "名望 %d（%d/%d）",

    LABEL_RENOWN = "聲望",
    LABEL_RENOWN_LEVEL = "等級",
    LABEL_RENOWN_UNAVAILABLE = "名望資料不可用",
    WARNING_EVENT_QUESTS = "部分活動目前在遊戲內仍有問題或尚未解鎖。",

    WARNING_WEEKLY_HARATI_CHOICE = "警告！一旦選擇了哈拉尼爾的傳說任務，該選擇將鎖定至整個帳號。",
    WARNING_WEEKLY_RUNESTONES = "警告！請謹慎選擇符石任務。一旦你本週選定一個，該選擇就會鎖定到整個帳號。",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "此陣營尚未設定每週任務。",
    LABEL_WEEKLY_PROFIT = "本週收益：",
    LABEL_WARBAND_PROFIT = "戰隊收益：",
    LABEL_WARBAND_BANK = "戰隊銀行：",
    LABEL_TOP_EARNERS = "本週最高收入：",
    LABEL_TOTAL_GOLD = "總金幣：%s",
    LABEL_TOTAL_TIME = "總時間：%s",
    LABEL_COMBINED_TIME = "總遊戲時間：%d天 %d小時",

    TOOLTIP_TOTAL_TIME_TITLE = "總時間",
    TOOLTIP_TOTAL_TIME_DESC = "所有已追蹤角色的總遊玩時間。",
    TOOLTIP_TOTAL_TIME_CLICK = "點擊切換顯示格式。",

    -- Quest status
    STATUS_DONE = "[完成]",
    STATUS_IN_PROGRESS = "[進行中]",
    STATUS_NOT_STARTED = "[未開始]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "角色管理",
    TOOLTIP_MANAGE_BACK = "返回主畫面。",
    TOOLTIP_MANAGE_VIEW = "檢視已忽略角色。",
    TOOLTIP_CATALYST_TITLE = "催化劑充能",
    TOOLTIP_SPARKS_TITLE = "製作火花",

    TOOLTIP_VAULT_TITLE = "寶庫",
    TOOLTIP_VAULT_DESC = "點擊開啟每週寶庫",
    TOOLTIP_VAULT_ACTIVE_ONLY = "開啟每週寶庫。",
    TOOLTIP_VAULT_ALT_ONLY = "每週寶庫只能為目前啟用的角色開啟。",
    TOOLTIP_CURRENCY_TITLE = "貨幣",
    TOOLTIP_CURRENCY_DESC = "點擊查看完整清單。",

    TOOLTIP_BAGS_TITLE = "查看背包",
    TOOLTIP_BAGS_DESC = "查看此角色已儲存的背包和材料袋內容。",

    TOOLTIP_LEDGER_TITLE = "每週收益帳本",
    TOOLTIP_LEDGER_DESC = "依來源追蹤金幣收入與支出。",

    TOOLTIP_WARBAND_BANK_TITLE = "戰隊銀行帳本",
    TOOLTIP_WARBAND_BANK_DESC = "點擊查看戰隊銀行交易。",

    TOOLTIP_RESTORE_TITLE = "還原",
    TOOLTIP_RESTORE_DESC = "將此角色還原到主頁",

    TOOLTIP_IGNORE_TITLE = "忽略",
    TOOLTIP_IGNORE_DESC = "將此角色從主頁移除",

    TOOLTIP_DELETE_TITLE = "刪除",
    TOOLTIP_DELETE_DESC = "永久刪除此角色資料",
    TOOLTIP_DELETE_WARNING = "警告：此動作無法復原！",

    TOOLTIP_FAVORITE_TITLE = "最愛",
    TOOLTIP_FAVORITE_DESC = "將此角色釘選到清單頂端",

    -- Character data displays
    LABEL_ILVL = "裝等：%d",
    LABEL_MPLUS_SCORE = "M+分數：%d",
    LABEL_NO_KEY = "沒有M+鑰石",
    LABEL_NO_PROFESSIONS = "無專業",
    LABEL_UNKNOWN = "未知",
    LABEL_SKILL_LEVEL = "技能：%d/%d",
    LABEL_CONCENTRATION = "專注：%d/%d",
    LABEL_CONC_DAILY_RESET = "每日：%d小時 %d分鐘",
    LABEL_CONC_WEEKLY_RESET = "完全重置：%d天 %d小時",
    LABEL_CONC_FULL = "(已滿)",
    LABEL_KNOWLEDGE_AVAILABLE = "可用知識點：%d",
    LABEL_NO_KNOWLEDGE = "沒有可用知識點",
    LABEL_VAULT_PROGRESS = "團：%d/3    M+：%d/3    世界：%d/3",
    BUTTON_LEDGER = "帳本",
    BUTTON_KNOWLEDGE = "知識",
    BUTTON_PROFS = "專業",

    TOOLTIP_PROFS_TITLE = "專業",
    TOOLTIP_PROFS_DESC = "檢視專注與知識點。",
    TITLE_PROFESSIONS = "%s的專業",
    TITLE_KNOWLEDGE_TRACKER = "知識追蹤器",
    TOOLTIP_KNOWLEDGE_DESC = "檢視已花費、未花費與總知識點",
    LABEL_SPENT = "已花費",
    LABEL_UNSPENT = "未花費",
    LABEL_MAX = "上限",
    LABEL_EARNED = "已獲得",
    LABEL_TREATISE = "概論",
    LABEL_ARTISAN_QUEST = "工匠任務",
    LABEL_CATCHUP = "追趕",
    LABEL_WEEKLY = "每週",
    LABEL_UNLOCKED = "已解鎖",
    LABEL_UNLOCK_REQUIREMENTS = "解鎖需求",
    LABEL_SOURCE_NOTE = "每週來源與追趕進度快照",
    TITLE_KNOWLEDGE_SOURCES = "知識來源",
    TAB_TREASURES = "寶藏",
    LABEL_UNIQUE_TREASURES = "一次性寶藏",
    LABEL_WEEKLY_TREASURES = "每週寶藏",
    LABEL_HOVER_TREASURE_CHECKLIST = "滑鼠懸停可查看寶藏清單",
    LABEL_TREASURE_CLICK_HINT = "點擊一次性寶藏以設置路徑點",
    LABEL_ZONE = "區域",
    LABEL_COORDINATES = "座標",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "點擊設置地圖路徑點",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "此寶藏沒有固定位置",
    MSG_TREASURE_NO_WAYPOINT = "此寶藏沒有固定路線點。",
    MSG_TOMTOM_NOT_DETECTED = "未偵測到 TomTom。",

    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "已設置地圖路線點：%s（%.1f，%.1f）",
    TITLE_PROF_TREASURES_FMT = "%s寶藏",
    LABEL_PROFESSION = "專業",
    LABEL_UNIQUE_TREASURE_FMT = "%s一次性寶藏 %d",
    LABEL_WEEKLY_TREASURE_FMT = "%s每週寶藏 %d",
    STATUS_DONE_WORD = "完成",
    STATUS_MISSING_WORD = "缺少",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "日",
    DAY_MON = "一",
    DAY_TUE = "二",
    DAY_WED = "三",
    DAY_THU = "四",
    DAY_FRI = "五",
    DAY_SAT = "六",

    TOOLTIP_ACTIVITY_FOR = "%d/%d/%d 的活動",
    MSG_NO_WORLD_EVENTS = "本月沒有世界事件",

    -- Filter categories
    FILTER_TIMEWALKING = "時光漫遊",
    FILTER_DARKMOON = "暗月馬戲團",
    FILTER_DUNGEONS = "地城",
    FILTER_PVP = "玩家對玩家",
    FILTER_BONUS = "獎勵",

    -- World events
    WORLD_EVENT_LOVE = "愛就在身邊",
    WORLD_EVENT_LUNAR = "新年慶典",
    WORLD_EVENT_NOBLEGARDEN = "貴族花園",
    WORLD_EVENT_CHILDREN = "兒童週",
    WORLD_EVENT_MIDSUMMER = "仲夏火焰節慶",
    WORLD_EVENT_BREWFEST = "啤酒節",
    WORLD_EVENT_HALLOWS = "萬鬼節",
    WORLD_EVENT_WINTERVEIL = "冬幕節",
    WORLD_EVENT_DEAD = "亡者節",
    WORLD_EVENT_PIRATES = "海盜節",
    WORLD_EVENT_STYLE = "時尚大考驗",
    WORLD_EVENT_OUTLAND = "外域杯",
    WORLD_EVENT_NORTHREND = "北裂境杯",
    WORLD_EVENT_KALIMDOR = "卡林多杯",
    WORLD_EVENT_EASTERN = "東部王國杯",
    WORLD_EVENT_WINDS = "神秘命運之風",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "%s的貨幣",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "團隊鎖定",
    TITLE_RAID_FORMAT = "%s的%s%s - 法力熔爐歐美加",

    BUTTON_PROGRESSION = "進度",
    BUTTON_LOCKOUTS = "鎖定",

    DIFFICULTY_NORMAL = "普通",
    DIFFICULTY_HEROIC = "英雄",
    DIFFICULTY_MYTHIC = "傳奇",

    TOOLTIP_VIEW_LOCKOUTS = "目前顯示：本週鎖定",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "點擊查看進度（歷來最佳）",
    TOOLTIP_VIEW_PROGRESSION = "目前顯示：進度（歷來最佳）",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "點擊查看本週鎖定",

    MSG_NO_CHAR_DATA = "找不到角色資料",
    MSG_NO_PROGRESSION = "沒有%s進度記錄",
    MSG_NO_LOCKOUT = "本週沒有%s鎖定",

    LABEL_BOSS = "首領 %d",
    LABEL_PROGRESS_COUNT = "%d/8",
    LABEL_MIDNIGHT_SEASON_1 = "至暗之夜第1賽季",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "戰隊銀行帳本",
    LABEL_CURRENT_BALANCE = "目前餘額：",
    LABEL_RECENT_TRANSACTIONS = "最近交易：",
    MSG_NO_TRANSACTIONS = "（尚無交易紀錄）",
    TIP_RELOAD_SAVE = "提示：切換角色前請先 /reload 以儲存資料",
    ACTION_DEPOSITED = "存入",
    ACTION_WITHDREW = "提領",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    TITLE_WEEKLY_LEDGER = "%s - 每週帳本",
    LABEL_RESETS_IN = "%d天 %d小時後重置",

    TAB_SUMMARY = "總覽",
    TAB_SOURCES = "來源",
    TAB_HISTORY = "紀錄",
    TAB_WARBAND = "戰隊",
    HEADER_SOURCE = "來源",
    HEADER_INCOME = "收入",
    HEADER_EXPENSE = "支出",

    LABEL_TOTAL = "總計",
    LABEL_NET_PROFIT = "淨收益",
    MSG_NO_GOLD_ACTIVITY = "本週沒有金幣活動",
    MSG_NO_TRANSACTIONS_WEEK = "本週沒有交易",

    -- Ledger source categories
    LEDGER_QUESTS = "任務",
    LEDGER_AUCTION = "拍賣場",
    LEDGER_TRADE = "交易",
    LEDGER_VENDOR = "商人",
    LEDGER_REPAIRS = "修裝",
    LEDGER_TRANSMOG = "塑形",
    LEDGER_FLIGHT = "飛行路線",
    LEDGER_CRAFTING = "製作",
    LEDGER_CACHE = "寶箱/藏寶",
    LEDGER_MAIL = "郵件",
    LEDGER_LOOT = "拾取",
    LEDGER_WARBAND_BANK = "戰隊銀行",
    LEDGER_OTHER = "其他",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "從未",
    FRESH_TODAY = "今日活躍",
    FRESH_1_DAY = "1天前",
    FRESH_DAYS = "%d天前",

    -- Time format styles
    TIME_YEARS_DAYS = "%d年 %d天",
    TIME_DAYS_HOURS = "%d天 %d小時",
    TIME_DAYS = "%s 天",
    TIME_HOURS = "%s 小時",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "%s，你好！\n是否要讓戰隊追蹤插件追蹤這個角色？",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "戰隊追蹤：",
    MSG_WEEKLY_RESET = "偵測到每週重置！已清除團隊鎖定。",
    MSG_ALREADY_TRACKED = "此角色已在追蹤清單中。",
    MSG_CHAR_ADDED = "%s 已加入追蹤。",
    MSG_LEDGER_NOT_AVAILABLE = "帳本不可用。",
    MSG_RAID_RESET_SEASON = "至暗之夜第1賽季的團隊進度已重置！",
    MSG_CLEARED_PROGRESSION = "已清除 %d 個角色的進度資料。",
    MSG_WEEKLY_PROFIT_RESET = "已重置 %d 個角色的每週收益追蹤。",
    MSG_WARBAND_BALANCE = "戰隊：%s",
    MSG_WARBAND_BANK_BALANCE = "戰隊銀行：%s",
    MSG_WEEKLY_DATA_RESET = "已重置 %d 個角色的每週資料。",
    MSG_RAID_MANUAL_RESET = "已手動重置團隊進度！",
    MSG_CLEARED_DATA = "已清除 %d 個角色的資料。",

    -- Prompt to reload when time-played suppression setting changes
    MSG_RELOAD_TIMEPLAYED = "請重新載入介面以套用遊戲時間訊息抑制。",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "暴雪初始的遊戲時間訊息無法被抑制。",

    -- Slash command help
    HELP_RESET_TITLE = "戰隊追蹤重置指令",
    HELP_REGION = "區域：%s（重置時間 %s）",
    HELP_LAST_SEASON = "上次賽季重置：%s",
    HELP_RESET_WEEKLY = "/lvreset weekly - 重置每週收益追蹤",
    HELP_RESET_SEASON = "/lvreset season - 重置團隊進度（新賽季）",
    HELP_NEVER = "從未",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "語言",
    TOOLTIP_LANGUAGE_TITLE = "語言",
    TOOLTIP_LANGUAGE_DESC = "更改介面語言",
    TITLE_LANGUAGE_SELECT = "選擇語言",
    LANG_AUTO = "自動（偵測）",
    MSG_LANGUAGE_CHANGED = "語言已變更。請重新載入介面以套用所有變更。",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "設定",
    TOOLTIP_OPTIONS_TITLE = "設定",
    TOOLTIP_OPTIONS_DESC = "設定戰隊追蹤選項",
    TITLE_OPTIONS = "戰隊追蹤設定",
    OPTION_DISABLE_TIMEPLAYED = "停用遊戲時間追蹤",
    OPTION_DISABLE_TIMEPLAYED_DESC = "防止 /played 訊息出現在聊天視窗",
    OPTION_ENABLE_24HR_CLOCK = "啟用 24 小時制時鐘",
    OPTION_ENABLE_24HR_CLOCK_DESC = "在 24 小時制與 12 小時制之間切換",
    OPTION_DARK_MODE = "深色模式",
    OPTION_DARK_MODE_DESC = "在深色與淺色主題間切換",
    OPTION_DISABLE_BAG_VIEWING = "停用背包/銀行檢視器",
    OPTION_DISABLE_BAG_VIEWING_DESC = "隱藏背包按鈕並停用已儲存的背包、銀行和戰隊銀行的查看功能。",
    OPTION_DISABLE_CHARACTER_OVERLAY = "停用覆蓋層系統",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "隱藏戰隊追蹤在角色和檢查裝備上的裝等與鎖定覆蓋層。",
    OPTION_DISABLE_MPLUS_TELEPORTS = "停用 M+ 傳送",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "隱藏 M+ 傳送徽章並停用戰隊追蹤的傳送面板。",

    -- Instance Tracker
    TITLE_INSTANCE_TRACKER = "副本追蹤器",
    SECTION_INSTANCE_CAP = "副本上限（每小時10次）",
    LABEL_CAP_CURRENT = "目前：%d/10",
    LABEL_CAP_STATUS = "狀態：%s",
    LABEL_NEXT_SLOT = "下個空位：%s",
    STATUS_SAFE = "安全",
    STATUS_WARNING = "警告",
    STATUS_LOCKED = "鎖定",
    SECTION_CURRENT_RUN = "目前進行",
    LABEL_DURATION = "持續時間：%s",
    LABEL_NOT_IN_INSTANCE = "目前不在副本中",
    SECTION_PERFORMANCE = "今日表現",
    LABEL_DUNGEONS_TODAY = "地城：%d",
    LABEL_RAIDS_TODAY = "團隊：%d",
    LABEL_AVG_TIME = "平均：%s",
    SECTION_LEGACY_RAIDS = "本週舊團隊",
    LABEL_LEGACY_RUNS = "次數：%d",
    LABEL_GOLD_EARNED = "金幣：%s",
    SECTION_RECENT_RUNS = "近期副本",
    LABEL_NO_RECENT_RUNS = "沒有近期紀錄",
    SECTION_MPLUS = "傳奇+",
    LABEL_MPLUS_CURRENT_KEY = "目前鑰石：",
    LABEL_RUNS_TODAY = "今日次數：%d",
    LABEL_RUNS_THIS_WEEK = "本週次數：%d",
    SECTION_RECENT_MPLUS_RUNS = "近期 M+ 紀錄",
    LABEL_NO_RECENT_MPLUS_RUNS = "沒有近期 M+ 紀錄",

    -- Month names
    MONTH_1 = "一月",
    MONTH_2 = "二月",
    MONTH_3 = "三月",
    MONTH_4 = "四月",
    MONTH_5 = "五月",
    MONTH_6 = "六月",
    MONTH_7 = "七月",
    MONTH_8 = "八月",
    MONTH_9 = "九月",
    MONTH_10 = "十月",
    MONTH_11 = "十一月",
    MONTH_12 = "十二月",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["Restored Coffer Key"] = "復原的寶庫鑰匙",
    ["Undercoin"] = "地底幣",
    ["Kej"] = "卡吉",
    ["Resonance Crystals"] = "共鳴水晶",
    ["Twilight's Blade Insignia"] = "暮光之刃徽記",
    ["Voidlight Marl"] = "虛光泥灰",
    ["Shard of Dundun"] = "敦敦裂片",
    ["Throw the Dice"] = "擲骰子",
    ["We Need a Refill"] = "我們需要補充",
    ["Lovely Plumage"] = "可愛的羽飾",
    ["The Cauldron of Echoes"] = "回響之釜",
    ["The Echoless Flame"] = "無回響之焰",
    ["Hidey-Hole"] = "藏身處",
    ["Victorious Stormarion Pinnacle Cache"] = "勝利的風瑪利昂尖端儲物箱",
["Overflowing Abundant Satchel"] = "滿溢的豐足背袋",
["Avid Learner's Supply Pack"] = "勤學者補給",
["Surplus Bag of Party Favors"] = "多出的一袋派對小禮物",
    ["Brimming Arcana"] = "滿溢秘能",
    ["Valorstones"] = "勇氣石",
    ["Weathered Ethereal Crest"] = "陳舊以太紋章",
    ["Carved Ethereal Crest"] = "雕刻以太紋章",
    ["Runed Ethereal Crest"] = "符文以太紋章",
    ["Gilded Ethereal Crest"] = "鍍金以太紋章",
    ["Adventurer Dawncrest"] = "冒險者晨曦紋章",
    ["Veteran Dawncrest"] = "精兵晨曦紋章",
    ["Champion Dawncrest"] = "勇士晨曦紋章",
    ["Hero Dawncrest"] = "英雄晨曦紋章",
    ["Myth Dawncrest"] = "傳奇晨曦紋章",
    ["Remnant of Anguish"] = "餘留苦痛",
    ["Dawnlight Manaflux"] = "曙光法力通量",

    -- ==========================================================================
    -- WEEKLY QUESTS
    -- ==========================================================================
    ["Call of the Worldsoul"] = "世界之魂的呼喚",
    ["Theater Troupe"] = "劇場演出",
    ["Awakening Machine"] = "甦醒機械",
    ["Seeking History"] = "尋覓歷史",
    ["Worldwide Research"] = "世界性研究",
    ["Urge to Surge"] = "拼命賺錢",
    ["Spreading Light"] = "散布光芒",
    -- Midnight Weekly Quests
    ["Community Engagement"] = "社群參與",
    WARNING_ACCOUNT_BOUND = "帳號綁定",
    ["Midnight: Prey"] = "至暗之夜: 狩獵",
    ["Saltheril's Soiree"] = "薩瑟里的晚會",
    ["Abundance Event"] = "豐足活動",
    ["Legends of the Haranir"] = "哈拉尼爾的傳說",
    ["Stormarion Assault"] = "風瑪利昂襲擊",
    ["Darkness Unmade"] = "破滅黑暗",
    ["Harvesting the Void"] = "收割虛無",
    ["Midnight: Saltheril's Soiree"] = "至暗之夜：薩瑟里的晚會",
    ["Fortify the Runestones: Blood Knights"] = "強化符石：血騎士",
    ["Fortify the Runestones: Shades of the Row"] = "強化符石：兇殺路之影",
    ["Fortify the Runestones: Magisters"] = "強化符石：博學者",
    ["Fortify the Runestones: Farstriders"] = "強化符石：遠行者",
    ["Put a Little Snap in Their Step"] = "讓他們步伐更俐落",
    ["Light Snacks"] = "輕食點心",
    ["Less Lawless"] = "少點無法無天",
    ["The Subtle Game"] = "微妙的遊戲",
    ["Courting Success"] = "求愛得手",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "鍊金術",
    ["Blacksmithing"] = "鍛造",
    ["Enchanting"] = "附魔",
    ["Engineering"] = "工程學",
    ["Inscription"] = "銘文學",
    ["Jewelcrafting"] = "珠寶設計",
    ["Leatherworking"] = "製皮",
    ["Tailoring"] = "裁縫",
    ["Herbalism"] = "草藥學",
    ["Mining"] = "採礦",
    ["Skinning"] = "剝皮",
    TELEPORT_PANEL_TITLE = "M+ 傳送",
    TELEPORT_CAST_BTN = "傳送",
    TELEPORT_ERR_COMBAT = "戰鬥中無法傳送。",
    WORLD_EVENT_SALTHERIL = "薩瑟里的晚會",
    WORLD_EVENT_ABUNDANCE = "豐足",
    WORLD_EVENT_HARANIR = "哈拉尼爾的傳說",
    WORLD_EVENT_STORMARION = "風瑪利昂襲擊",
    TOOLTIP_TREASURE_SET_WAYPOINT = "點擊設定 TomTom 路徑點",
    MSG_TREASURE_WAYPOINT_SET = "路徑點已設定：%s (%.1f, %.1f)",
    TIME_TODAY = "今天 %H:%M",
    TIME_YESTERDAY = "昨天 %H:%M",
    MSG_CAP_WARNING = "副本上限警告！本小時已進入 %d/10 個副本。",
    MSG_CAP_SLOT_OPEN = "副本名額現在已空出！(已使用 %d/10)",
    MSG_RAID_DEBUG_ON = "戰隊追蹤團隊副本除錯：開啟",
    MSG_RAID_DEBUG_OFF = "戰隊追蹤團隊副本除錯：關閉",
    MSG_RAID_DEBUG_TIP = "再次使用 /lvraiddbg 可關閉除錯輸出",
    MSG_TRACKED_KILL = "已追蹤 %s 擊殺：%s (%s)",
    LOCALE_DEBUG_ON = "語言除錯模式已開啟 - 顯示字串鍵名",
    LOCALE_DEBUG_OFF = "語言除錯模式已關閉 - 顯示翻譯文字",
    LOCALE_BORDERS_ON = "邊框模式已開啟 - 顯示文字邊界",
    LOCALE_BORDERS_HINT = "綠色 = 適配，紅色 = 可能溢出",
    LOCALE_BORDERS_OFF = "邊框模式已關閉",
    LOCALE_FORCED = "語言已強制設為 %s",
    LOCALE_RESET_TIP = "使用 /lvlocale reset 恢復自動偵測",
    LOCALE_INVALID = "無效語言。有效選項：",
    LOCALE_RESET = "語言已重設為自動偵測：%s",
    LOCALE_TITLE = "戰隊追蹤本地化",
    LOCALE_DETECTED = "偵測到的語言：%s",
    LOCALE_FORCED_TO = "強制語言：%s",
    LOCALE_DEBUG_KEYS = "除錯鍵：",
    LOCALE_DEBUG_BORDERS = "除錯邊框：",
    LOCALE_ON = "開啟",
    LOCALE_OFF = "關閉",
    LOCALE_COMMANDS = "命令：",
    LOCALE_CMD_DEBUG = "/lvlocale debug - 切換鍵名顯示模式",
    LOCALE_CMD_BORDERS = "/lvlocale borders - 切換文字邊界視覺化",
    LOCALE_CMD_LANG = "/lvlocale lang XX - 強制語言（例如 deDE、zhCN）",
    LOCALE_CMD_RESET = "/lvlocale reset - 重設為自動偵測",
    LABEL_QUEST = "任務",
    BUTTON_DASHBOARD = "概覽",
    BUTTON_ACHIEVEMENTS = "成就",
    TITLE_ACHIEVEMENTS = "成就",
    DESC_ACHIEVEMENTS = "選擇一個成就追蹤器以查看詳細進度。",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "至暗之夜雕紋獵人",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "至暗之夜雕紋獵人",
    LABEL_REWARD = "獎勵",
    DESC_GLYPH_REWARD = "完成至暗之夜雕紋獵人以獲得該坐騎。",
    MSG_NO_ACHIEVEMENT_DATA = "沒有可用的成就追蹤資料。",
    LABEL_CRITERIA = "條件",
    LABEL_GLYPHS_COLLECTED = "已收集符文",
    LABEL_ACHIEVEMENT = "成就",
    BUTTON_BAGS = "背包",
    BUTTON_BANK = "銀行",
    BUTTON_WARBAND_BANK = "戰隊銀行",
    BAGS_EMPTY_STATE = "此角色尚無保存的背包物品。",
    BANK_EMPTY_STATE = "此角色尚無保存的銀行物品。",
    WARBANK_EMPTY_STATE = "尚無保存的戰隊銀行物品。",
    LABEL_BAG_SLOTS = "格子：%d/%d 已用",
    LABEL_SCANNED = "已掃描",
    ["Coffer Key Shards"] = "寶庫鑰匙裂片",
    ["Untainted Mana-Crystals"] = "未受污染的法力水晶",
    BUTTON_WEEKLY_PLANNER = "計畫表",
    TITLE_WEEKLY_PLANNER = "每週計畫表",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s的 %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "每週計畫表",
    TOOLTIP_WEEKLY_PLANNER_DESC = "可依角色編輯的每週清單。已完成的項目會在每週重置。",
    TOOLTIP_VAULT_STATUS = "查看寶庫狀態。",
    TITLE_GREAT_VAULT = "寶庫",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s的 %s",
    LABEL_VAULT_ROW_RAID = "團隊副本",
    LABEL_VAULT_ROW_DUNGEONS = "地下城",
    LABEL_VAULT_ROW_WORLD = "世界",
    LABEL_VAULT_SLOTS_UNLOCKED = "已解鎖 %d/9 個欄位",
    LABEL_VAULT_OVERALL_PROGRESS = "整體進度: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "尚未儲存門檻資料。",
    MSG_VAULT_LIVE_ACTIVE = "目前角色的寶庫即時進度。",
    MSG_VAULT_LIVE = "寶庫即時進度。",
    MSG_VAULT_SAVED = "此角色上次登入時儲存的寶庫快照。",
    SECTION_DELVE_CURRENCY = "探究貨幣",
    SECTION_UPGRADE_CRESTS = "升級紋章",
    LABEL_CAP_SHORT = "上限 %s",
    ["Treasures of Midnight"] = "至暗之夜寶藏",
    ["Track the four Midnight treasure achievements and their rewards."] = "追蹤至暗之夜的四個寶藏成就與其獎勵。",
    ["Glory of the Midnight Delver"] = "至暗之夜探究者的榮耀",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "完成「至暗之夜探究者的榮耀」以獲得這隻坐騎。",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "追蹤至暗之夜的四個稀有成就與區域稀有獎勵。",
    ["Track the four Midnight rare achievements."] = "追蹤至暗之夜的四個稀有成就。",
    ["Complete the five telescopes in this zone."] = "完成此區域的五個望遠鏡。",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "完成全部四個至暗之夜探究者支援成就，以完成這個綜合成就。",
    ["Crimson Dragonhawk"] = "赤紅龍鷹",
    ["Giganto-Manis"] = "巨型螳螂",
    ["Achievements"] = "成就",
    ["Reward"] = "獎勵",
    ["Details"] = "詳細資訊",
    ["Criteria"] = "條件",
    ["Info"] = "資訊",
    ["Shared Loot"] = "共用掉落",
    ["Groups"] = "群組",
    ["Back to Groups"] = "返回群組",
    ["Back"] = "返回",
    ["Unknown"] = "未知",
    ["Item"] = "物品",
    ["No achievement reward listed."] = "未列出成就獎勵。",
    ["Click to set waypoint."] = "點擊以設定路徑點。",
    ["Click to open this tracker."] = "點擊以開啟此追蹤器。",
    ["Tracker not added yet."] = "追蹤器尚未加入。",
    ["Coordinates pending."] = "座標待補充。",
    ["Complete the cave run here for credit."] = "在此完成洞穴流程以取得進度。",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "使用潛在秘能為符石充能，以啟動它的防禦事件。",
    ["Achievement credit from:"] = "成就進度來源：",
    ["Stormarion Assault"] = "風瑪利昂襲擊",
    ["Ever-Painting"] = "永恆繪景",
    ["Track the known Ever-Painting canvases. x/y marked."] = "追蹤已知的 Ever-Painting 畫布。x/y 已標記。",
    ["Tracked entries for Ever-Painting have not been added yet."] = "尚未加入 Ever-Painting 的追蹤條目。",
    ["Runestone Rush"] = "符石保衛戰",
    ["Track the known Runestone Rush entries. x/y marked."] = "追蹤已知的符石保衛戰條目。x/y 已標記。",
    ["Tracked entries for Runestone Rush have not been added yet."] = "尚未加入符石保衛戰的追蹤條目。",
    ["The Party Must Go On"] = "派對必須要繼續",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "追蹤「派對必須要繼續」的四個陣營邀請。x/y 已標記。",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "尚未加入「派對必須要繼續」的追蹤條目。",
    ["Explore trackers"] = "探索追蹤器",
    ["Track Explore Eversong Woods progress. x/y marked."] = "追蹤永歌森林探索的進度。x/y 已標記。",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "尚未加入永歌森林探索的追蹤條目。",
    ["Track Explore Voidstorm progress. x/y marked."] = "追蹤虛無風暴探索的進度。x/y 已標記。",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "尚未加入虛無風暴探索的追蹤條目。",
    ["Track Explore Zul'Aman progress. x/y marked."] = "追蹤祖阿曼探索的進度。x/y 已標記。",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "尚未加入祖阿曼探索的追蹤條目。",
    ["Track Explore Harandar progress. x/y marked."] = "追蹤哈朗達探索的進度。x/y 已標記。",
    ["Tracked entries for Explore Harandar have not been added yet."] = "尚未加入哈朗達探索的追蹤條目。",
    ["Thrill of the Chase"] = "追逐快感",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "在虛無風暴中躲避飢渴存在的追捕至少 60 秒。",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "這個成就不需要在戰隊追蹤中追蹤座標。在虛無風暴中撐過飢渴存在事件至少 60 秒。",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "尚未加入「追逐快感」的追蹤條目。",
    ["No Time to Paws"] = "爪子不能停",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "在擁有 15 層或以上「掠食者追擊」時完成哈朗達世界任務「利爪執法」。",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "這個成就不需要在戰隊追蹤中追蹤座標。在擁有 15 層或以上「掠食者追擊」時完成哈朗達世界任務「捕獵者追擊」。",
    ["Tracked entries for No Time to Paws have not been added yet."] = "尚未加入「爪子不能停」的追蹤條目。",
    ["From The Cradle to the Grave"] = "從育所到墳墓",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "嘗試飛往哈朗達上空高處的 育所。",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "飛入哈朗達上空高處的育所以完成這個成就。",
    ["Chronicler of the Haranir"] = "哈拉尼爾撰史者",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "這些日誌只會在帳號綁定的每週任務「哈拉尼爾傳說」期間出現。處於幻象中時，請留意小地圖上的放大鏡圖示。",
    ["Recover the Haranir journal entries listed below."] = "找回下方列出的哈拉尼爾日誌條目。",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "找回下方列出的哈拉尼爾日誌條目。x/y 已標記。",
    ["Legends Never Die"] = "傳說永不消逝",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "這與帳號綁定的每週任務「哈拉尼爾傳說」有關。如果你目前還沒有進度，預計大約需要 7 週完成。",
    ["Defend each Haranir legend location listed below."] = "守護下方列出的每個哈拉尼爾傳說地點。",
    ["Protect each Haranir legend location listed below. x/y marked."] = "保護下方列出的每個哈拉尼爾傳說地點。x/y 已標記。",
    ["Dust 'Em Off"] = "協助除塵",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "找出所有藏在哈朗達的發光飛蛾。x/y 已找到。",
    ["Coordinate groups have not been added yet."] = "尚未加入座標分組。",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "這個追蹤器分成 3 組，每組 40 個座標，讓飛蛾路線更容易管理。",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "飛蛾 1-40 會在哈拉提聲望 1 出現，並於聲望 2 可追蹤。",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "飛蛾 41-80 會在哈拉提聲望 4 出現，並於聲望 6 可追蹤。",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "飛蛾 81-120 會在哈拉提聲望 9 出現，並於聲望 11 可追蹤。",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "戰隊追蹤路線預設你已經解鎖哈拉提聲望 11。",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s 包含 %d 個飛蛾座標。點擊飛蛾以放置路徑點。",
    ["Group 1"] = "第 1 組",
    ["Group 2"] = "第 2 組",
    ["Group 3"] = "第 3 組",
    ["Moths"] = "飛蛾",
    ["A Singular Problem"] = "奇異點問題",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "完成風瑪利昂襲擊的三波攻勢。x/y 已標記。",
    ["Tracked entries for A Singular Problem have not been added yet."] = "尚未加入「奇異點問題」的追蹤條目。",
    ["Abundance: Prosperous Plentitude!"] = "豐足：飽滿豐足！",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "在每個地點完成一次豐饒收穫洞穴流程。x/y 已標記。",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "你必須在每個地點完成一次豐足收穫洞穴流程才能獲得進度。只拜訪洞穴是不夠的。",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "尚未加入「豐足：飽滿豐足！」的追蹤條目。",
    ["Altar of Blessings"] = "祝福祭壇",
    ["Trigger each listed blessing effect for credit."] = "觸發每個列出的祝福效果以取得進度。",
    ["Trigger each listed blessing effect. x/y marked."] = "觸發每個列出的祝福效果。x/y 已標記。",
    ["Meta achievement summaries"] = "綜合成就摘要",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "完成下方列出的永歌森林成就。x/y 已完成。",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "完成下方列出的所有虛無風暴成就。x/y 已完成。",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "完成下方列出的所有祖阿曼成就。x/y 已完成。",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "透過完成下方成就來協助哈拉提。x/y 已完成。",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "透過完成下方成就來集結你的力量對抗薩拉塔斯。x/y 已完成。",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "尚未加入成為阿曼尼的追蹤條目。",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "尚未加入各位，這就是艾恩！的追蹤條目。",
    ["Tracked entries for Forever Song have not been added yet."] = "尚未加入永恆之歌的追蹤條目。",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "尚未加入向虛無風暴吶喊的追蹤條目。",
    ["Tracked entries for Light Up the Night have not been added yet."] = "尚未加入照亮夜晚的追蹤條目。",
    ["Mount: Brilliant Petalwing"] = "坐騎：光輝瓣翼鳥",
    ["Housing Decor: On'ohia's Call"] = "方屋裝飾：昂西亞的呼喚",
    ["Title: \"Dustlord\""] = "頭銜：「粉塵之主」",
    ["Title: \"Chronicler of the Haranir\""] = "頭銜：「哈拉尼爾撰史者」",
    ["home reward labels:"] = "住家獎勵標籤：",
}

L["Raid resync unavailable."] = "團隊副本重新同步無法使用。"
L["Time played messages will be suppressed."] = "遊戲時間訊息將被隱藏。"
L["Time played messages restored."] = "遊戲時間訊息已恢復。"
L["%dm %02ds"] = "%d分%02d秒"
L["Crests:"] = "紋章："
L["Mount Drops"] = "坐騎掉落"
L["(Collected)"] = "（已收藏）"
L["(Uncollected)"] = "（未收藏）"
L["Mounts: %d/%d"] = "坐騎：%d/%d"
L["LABEL_MOUNTS_FMT"] = "坐騎：%d/%d"
L["The Voidspire"] = "虛無尖塔"
L["The Dreamrift"] = "夢境裂隙"
L["March of Quel'Danas"] = "奎爾達納斯遠征"
L["Raid Progression"] = "團隊進度"
L["Lady Liadrin Weekly"] = "莉亞德琳女士每週任務"
L["Change Log"] = "更新日誌"
L["Back"] = "返回"
L["Warband Bank"] = "戰隊銀行"
L["Treatise"] = "概論"
L["Artisan"] = "工匠"
L["Catch-up"] = "追趕"
L["LiteVault Update Summary"] = "戰隊追蹤更新摘要"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "更新了多項核心介面元素，包括貨幣圖示、團隊副本圖示、專業技能列以及豐碩寶庫追蹤器。"
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "調整了寶庫物品等級顯示，使其更接近暴雪預設的豐碩寶庫呈現方式。"
L["Added a large batch of new translations across supported locales."] = "為支援的語系新增了大量翻譯內容。"
L["Improved localized text rendering and refresh behavior throughout the addon."] = "優化了整個插件中的在地化文字顯示與刷新表現。"
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "更新了按鈕、背包分頁、每週文字及其他介面標籤的在地化支援。"
L["Fixed multiple localization-related layout issues."] = "修復了多項與在地化相關的版面配置問題。"
L["Fixed several localization-related crash issues."] = "修復了多項與在地化相關的崩潰問題。"

-- Register this locale
lv.RegisterLocale("zhTW", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["zhTW"] = L

