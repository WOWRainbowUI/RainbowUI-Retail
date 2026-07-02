-- zhTW.lua - Traditional Chinese locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",
    ADDON_VERSION = "v12.0.7.3",

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
    DIALOG_DELETE_CHAR = "要從 LiteVault 刪除 %s 嗎？",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "地圖篩選",

    BUTTON_RAID_LOCKOUTS = "團隊鎖定",
    BUTTON_WORLD_EVENTS = "世界活動",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "團隊鎖定",
    TOOLTIP_RAID_LOCKOUTS_DESC = "查看團隊鎖定與進度",
    TOOLTIP_ACTIONS_TITLE = "角色動作",
    TOOLTIP_ACTIONS_DESC = "開啟動作選單",
    TOOLTIP_THEME_TITLE = "切換主題",
    TOOLTIP_THEME_DESC = "在暗色與亮色主題間切換",
    TOOLTIP_FILTER_TITLE = "地圖篩選",
    TOOLTIP_FILTER_DESC = "點一下查看完整清單",
    TOOLTIP_WORLD_EVENTS_TITLE = "世界活動",
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

    WARNING_WEEKLY_HARATI_CHOICE = "警告！一旦選擇了哈拉尼爾傳說任務，該選擇將鎖定至整個帳號。",
    WARNING_WEEKLY_RUNESTONES = "警告！請謹慎選擇符文石任務。一旦你本週選定一個，該選擇就會鎖定到整個帳號。",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "此陣營尚未設定每週任務。",
    LABEL_WEEKLY_PROFIT = "本週收益：",
    LABEL_WARBAND_PROFIT = "戰隊收益：",
    LABEL_WARBAND_BANK = "戰隊銀行：",
    LABEL_TOP_EARNERS = "本週最高收入：",
    LABEL_TOTAL_GOLD = "總金幣：%s",
    LABEL_TOTAL_TIME = "總時間：%s",
    LABEL_COMBINED_TIME = "總遊玩時間：%d天 %d小時",

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
    TOOLTIP_VOIDSHARDS_TITLE = "Ascendant Voidshards",
    TOOLTIP_VOIDCORES_TITLE = "Ascendant Voidcores",

    TOOLTIP_VAULT_TITLE = "寶庫",
    TOOLTIP_VAULT_DESC = "點一下開啟每週寶庫",
    TOOLTIP_VAULT_ACTIVE_ONLY = "開啟每週寶庫。",
    TOOLTIP_VAULT_ALT_ONLY = "每週寶庫只能為目前啟用的角色開啟。",
    TOOLTIP_CURRENCY_TITLE = "貨幣",
    TOOLTIP_CURRENCY_DESC = "點一下查看完整清單。",

    TOOLTIP_BAGS_TITLE = "查看背包",
    TOOLTIP_BAGS_DESC = "查看此角色已儲存的背包和材料袋內容。",

    TOOLTIP_LEDGER_DESC = "依來源追蹤金幣收入與支出。",

    TOOLTIP_WARBAND_BANK_TITLE = "戰隊銀行帳本",
    TOOLTIP_WARBAND_BANK_DESC = "點一下查看戰隊銀行交易。",

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
    LABEL_TREATISE = "論文",
    LABEL_ARTISAN_QUEST = "工匠任務",
    LABEL_CATCHUP = "追趕",
    LABEL_WEEKLY = "每週",
    LABEL_UNLOCKED = "已解鎖",
    LABEL_UNLOCK_REQUIREMENTS = "解鎖需求",
    LABEL_SOURCE_NOTE = "每週來源與追趕進度快照",
    TITLE_KNOWLEDGE_SOURCES = "知識來源",
    TAB_TREASURES = "寶藏",
    LABEL_UNIQUE_TREASURES = "唯一寶藏",
    LABEL_WEEKLY_TREASURES = "每週寶藏",
    LABEL_HOVER_TREASURE_CHECKLIST = "滑鼠懸停可查看寶藏清單",
    LABEL_TREASURE_CLICK_HINT = "點擊唯一寶藏以設置路線點",
    LABEL_ZONE = "區域",
    LABEL_COORDINATES = "座標",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "點一下設定地圖路線點",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "此寶藏沒有固定位置",
    MSG_TREASURE_NO_WAYPOINT = "此寶藏沒有固定路線點。",
    MSG_TOMTOM_NOT_DETECTED = "未偵測到 TomTom。",

    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "已設置地圖路線點：%s（%.1f，%.1f）",
    TITLE_PROF_TREASURES_FMT = "%s寶藏",
    LABEL_PROFESSION = "專業",
    LABEL_UNIQUE_TREASURE_FMT = "%s唯一寶藏 %d",
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
    WORLD_EVENT_LUNAR = "農曆新年",
    WORLD_EVENT_NOBLEGARDEN = "復活節慶典",
    WORLD_EVENT_CHILDREN = "兒童週",
    WORLD_EVENT_MIDSUMMER = "仲夏火焰節",
    WORLD_EVENT_BREWFEST = "啤酒節",
    WORLD_EVENT_HALLOWS = "萬鬼節",
    WORLD_EVENT_WINTERVEIL = "冬幕節",
    WORLD_EVENT_DEAD = "亡者節",
    WORLD_EVENT_PIRATES = "海盜節",
    WORLD_EVENT_STYLE = "風格試煉",
    WORLD_EVENT_OUTLAND = "外域盃",
    WORLD_EVENT_NORTHREND = "北裂境盃",
    WORLD_EVENT_KALIMDOR = "卡林多盃",
    WORLD_EVENT_EASTERN = "東部王國盃",
    WORLD_EVENT_WINDS = "神秘財富之風",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "%s的貨幣",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "團隊鎖定",
    TITLE_RAID_FORMAT = "%s的%s%s - 法力熔爐奧米加",

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
    PROMPT_GREETINGS = "%s，你好！\n是否要讓 LiteVault 追蹤這個角色？",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "偵測到每週重置！已清除團隊鎖定。",
    MSG_ALREADY_TRACKED = "此角色已在追蹤清單中。",
    MSG_CHAR_ADDED = "%s 已加入追蹤。",
    MSG_RAID_RESET_SEASON = "至暗之夜第1賽季的團隊進度已重置！",
    MSG_CLEARED_PROGRESSION = "已清除 %d 個角色的進度資料。",
    MSG_WEEKLY_PROFIT_RESET = "已重置 %d 個角色的每週收益追蹤。",
    MSG_WARBAND_BALANCE = "戰隊：%s",
    MSG_WARBAND_BANK_BALANCE = "戰隊銀行：%s",
    MSG_WEEKLY_DATA_RESET = "已重置 %d 個角色的每週資料。",
    MSG_RAID_MANUAL_RESET = "已手動重置團隊進度！",
    MSG_CLEARED_DATA = "已清除 %d 個角色的資料。",

    -- Prompt to reload when time-played suppression setting changes
    MSG_RELOAD_TIMEPLAYED = "請重新載入介面以套用遊玩時間訊息抑制。",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "暴雪初始的遊玩時間訊息無法被抑制。",

    -- Slash command help
    HELP_RESET_TITLE = "LiteVault 重置指令",
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
    TOOLTIP_OPTIONS_DESC = "設定 LiteVault 選項",
    TITLE_OPTIONS = "LiteVault 設定",
    OPTION_DISABLE_TIMEPLAYED = "停用遊玩時間追蹤",
    OPTION_DISABLE_TIMEPLAYED_DESC = "防止 /played 訊息出現在聊天視窗",
    OPTION_ENABLE_24HR_CLOCK = "啟用 24 小時制時鐘",
    OPTION_ENABLE_24HR_CLOCK_DESC = "在 24 小時制與 12 小時制之間切換",
    OPTION_DARK_MODE = "深色模式",
    OPTION_DARK_MODE_DESC = "在深色與淺色主題間切換",
    OPTION_DISABLE_BAG_VIEWING = "停用背包/銀行檢視器",
    OPTION_DISABLE_BAG_VIEWING_DESC = "隱藏背包按鈕並停用已儲存的背包、銀行和戰隊銀行的查看功能。",
    OPTION_DISABLE_CHARACTER_OVERLAY = "停用覆蓋層系統",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "隱藏 LiteVault 在角色和檢查裝備上的裝等與鎖定覆蓋層。",
    OPTION_DISABLE_MPLUS_TELEPORTS = "停用 M+ 傳送",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "隱藏 M+ 傳送徽章並停用 LiteVault 的傳送面板。",

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
    ["復原的寶庫鑰匙"] = "復原的寶庫鑰匙",
    ["地底幣"] = "地底幣",
    ["Kej"] = "Kej",
    ["共鳴水晶"] = "共鳴水晶",
    ["暮刃徽記"] = "暮刃徽記",
    ["虛光泥灰"] = "虛光泥灰",
    ["敦敦裂片"] = "敦敦裂片",
    ["擲骰子"] = "擲骰子",
    ["我們需要補充"] = "我們需要補充",
    ["可愛的羽飾"] = "可愛的羽飾",
    ["回響之釜"] = "回響之釜",
    ["無回響之焰"] = "無回響之焰",
    ["藏身處"] = "藏身處",
    ["凱旋的風暴阿瑞恩之巔寶匣"] = "凱旋的風暴阿瑞恩之巔寶匣",
["滿溢的豐足背袋"] = "滿溢的豐足背袋",
["勤學者補給"] = "勤學者補給",
["多出的一袋派對小禮物"] = "多出的一袋派對小禮物",
    ["滿溢秘能"] = "滿溢秘能",
    ["英勇石"] = "英勇石",
    ["風化虛無紋章"] = "風化虛無紋章",
    ["雕琢虛無紋章"] = "雕琢虛無紋章",
    ["符刻虛無紋章"] = "符刻虛無紋章",
    ["鍍金虛無紋章"] = "鍍金虛無紋章",
    ["冒險者晨曦紋章"] = "冒險者晨曦紋章",
    ["精兵晨曦紋章"] = "精兵晨曦紋章",
    ["勇士晨曦紋章"] = "勇士晨曦紋章",
    ["英雄晨曦紋章"] = "英雄晨曦紋章",
    ["傳奇晨曦紋章"] = "傳奇晨曦紋章",
    ["餘留苦痛"] = "餘留苦痛",
    ["曙光法力通量"] = "曙光法力通量",

    -- ==========================================================================
    -- WEEKLY QUESTS
    -- ==========================================================================
    ["世界之魂的呼喚"] = "世界之魂的呼喚",
    ["劇場巡演"] = "劇場巡演",
    ["覺醒機器"] = "覺醒機器",
    ["追尋歷史"] = "追尋歷史",
    ["全球研究"] = "全球研究",
    ["激湧衝動"] = "激湧衝動",
    ["散播聖光"] = "散播聖光",
    -- Midnight Weekly Quests
    ["社群參與"] = "社群參與",
    WARNING_ACCOUNT_BOUND = "帳號綁定",
    ["午夜：獵物"] = "午夜：獵物",
    ["薩瑟里爾晚宴"] = "薩瑟里爾晚宴",
    ["豐饒活動"] = "豐饒活動",
    ["哈拉尼爾傳說"] = "哈拉尼爾傳說",
    ["風暴亞里昂突襲"] = "風暴亞里昂突襲",
    ["破滅黑暗"] = "破滅黑暗",
    ["收割虛無"] = "收割虛無",
    ["午夜：薩瑟里爾晚宴"] = "午夜：薩瑟里爾晚宴",
    ["強化符文石：血騎士"] = "強化符文石：血騎士",
    ["強化符文石：街巷魅影"] = "強化符文石：街巷魅影",
    ["強化符文石：博學者"] = "強化符文石：博學者",
    ["強化符文石：遠行者"] = "強化符文石：遠行者",
    ["讓他們步伐更俐落"] = "讓他們步伐更俐落",
    ["輕食點心"] = "輕食點心",
    ["少點無法無天"] = "少點無法無天",
    ["微妙的遊戲"] = "微妙的遊戲",
    ["求愛得手"] = "求愛得手",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["鍊金術"] = "鍊金術",
    ["鍛造"] = "鍛造",
    ["附魔"] = "附魔",
    ["工程學"] = "工程學",
    ["銘文學"] = "銘文學",
    ["珠寶設計"] = "珠寶設計",
    ["製皮"] = "製皮",
    ["裁縫"] = "裁縫",
    ["草藥學"] = "草藥學",
    ["採礦"] = "採礦",
    ["剝皮"] = "剝皮",
    TELEPORT_PANEL_TITLE = "M+ 傳送",
    TELEPORT_CAST_BTN = "傳送",
    TELEPORT_ERR_COMBAT = "戰鬥中無法傳送。",
    WORLD_EVENT_SALTHERIL = "薩瑟里爾的晚宴",
    WORLD_EVENT_ABUNDANCE = "豐饒",
    WORLD_EVENT_HARANIR = "哈拉尼爾傳奇",
    WORLD_EVENT_STORMARION = "風暴瑪瑞恩突襲",
    TOOLTIP_TREASURE_SET_WAYPOINT = "點擊放置 TomTom 路徑點",
    MSG_TREASURE_WAYPOINT_SET = "路徑點已設定：%s (%.1f, %.1f)",
    TIME_TODAY = "今天 %H:%M",
    MSG_CAP_WARNING = "副本上限警告！本小時已進入 %d/10 個副本。",
    MSG_CAP_SLOT_OPEN = "副本名額現在已空出！(已使用 %d/10)",
    MSG_RAID_DEBUG_ON = "LiteVault 團隊副本除錯：開啟",
    MSG_RAID_DEBUG_OFF = "LiteVault 團隊副本除錯：關閉",
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
    LOCALE_TITLE = "LiteVault 本地化",
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
    BUTTON_PROFIT = "收益",
    LABEL_PROFIT_GOALS = "戰隊目標",
    LABEL_WEEKLY_GOAL = "每週目標",
    LABEL_MONTHLY_GOAL = "每月目標",
    BUTTON_EDIT = "編輯",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "本次重置期間的最高淨收益。",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "本月期間的最佳淨收益。",
    BUTTON_ACHIEVEMENTS = "成就",
    TITLE_ACHIEVEMENTS = "成就",
    DESC_ACHIEVEMENTS = "選擇一個成就追蹤器以查看詳細進度。",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "午夜符文獵手",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "午夜符文獵手",
    LABEL_REWARD = "獎勵",
    DESC_GLYPH_REWARD = "完成午夜符文獵手以獲得該坐騎。",
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
    LABEL_BAG_SLOTS = "格子：%d / %d 已用",
    LABEL_SCANNED = "已掃描",
    ["寶庫鑰匙裂片"] = "寶庫鑰匙裂片",
    ["未受污染的法力水晶"] = "未受污染的法力水晶",
    BUTTON_WEEKLY_PLANNER = "計畫表",
    TITLE_WEEKLY_PLANNER = "每週計畫表",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "每週計畫表",
    TOOLTIP_WEEKLY_PLANNER_DESC = "可依角色編輯的每週清單。已完成的項目會在每週重置。",
    TOOLTIP_VAULT_STATUS = "查看寶庫狀態。",
    TITLE_GREAT_VAULT = "偉大的寶庫",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "團隊副本",
    LABEL_VAULT_ROW_DUNGEONS = "地城",
    LABEL_VAULT_ROW_WORLD = "世界",
    LABEL_VAULT_SLOTS_UNLOCKED = "已解鎖 %d/9 個欄位",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "尚未儲存門檻資料。",
    MSG_VAULT_LIVE_ACTIVE = "目前角色的偉大寶庫即時進度。",
    MSG_VAULT_LIVE = "偉大寶庫即時進度。",
    MSG_VAULT_SAVED = "此角色上次登入時儲存的偉大寶庫快照。",
    SECTION_DELVE_CURRENCY = "探究貨幣",
    SECTION_UPGRADE_CRESTS = "升級紋章",
    LABEL_CAP_SHORT = "上限 %s",
    ["午夜寶藏"] = "午夜寶藏",
    ["追蹤午夜的四個寶藏成就與其獎勵。"] = "追蹤午夜的四個寶藏成就與其獎勵。",
    ["午夜探究者的榮耀"] = "午夜探究者的榮耀",
    ["完成「午夜探究者的榮耀」以獲得這隻坐騎。"] = "完成「午夜探究者的榮耀」以獲得這隻坐騎。",
    ["追蹤午夜的四個稀有成就與區域稀有獎勵。"] = "追蹤午夜的四個稀有成就與區域稀有獎勵。",
    ["追蹤午夜的四個稀有成就。"] = "追蹤午夜的四個稀有成就。",
    ["完成此區域的五個望遠鏡。"] = "完成此區域的五個望遠鏡。",
    ["完成全部四個午夜探究者支援成就，以完成這個綜合成就。"] = "完成全部四個午夜探究者支援成就，以完成這個綜合成就。",
    ["赤紅龍鷹"] = "赤紅龍鷹",
    ["巨型螳螂"] = "巨型螳螂",
    ["成就"] = "成就",
    ["獎勵"] = "獎勵",
    ["詳細資訊"] = "詳細資訊",
    ["條件"] = "條件",
    ["資訊"] = "資訊",
    ["共用掉落"] = "共用掉落",
    ["群組"] = "群組",
    ["返回群組"] = "返回群組",
    ["未知"] = "未知",
    ["物品"] = "物品",
    ["未列出成就獎勵。"] = "未列出成就獎勵。",
    ["點擊以設定路徑點。"] = "點擊以設定路徑點。",
    ["點擊以開啟此追蹤器。"] = "點擊以開啟此追蹤器。",
    ["追蹤器尚未加入。"] = "追蹤器尚未加入。",
    ["座標待補充。"] = "座標待補充。",
    ["在此完成洞穴流程以取得進度。"] = "在此完成洞穴流程以取得進度。",
    ["使用潛伏祕法為符文石充能，以啟動它的防禦事件。"] = "使用潛伏祕法為符文石充能，以啟動它的防禦事件。",
    ["成就進度來源："] = "成就進度來源：",
    ["風暴艾里昂突襲"] = "風暴艾里昂突襲",
    ["永恆繪景"] = "永恆繪景",
    ["追蹤已知的 Ever-Painting 畫布。x/y 已標記。"] = "追蹤已知的 Ever-Painting 畫布。x/y 已標記。",
    ["尚未加入 Ever-Painting 的追蹤條目。"] = "尚未加入 Ever-Painting 的追蹤條目。",
    ["符文石衝刺"] = "符文石衝刺",
    ["追蹤已知的 Runestone Rush 條目。x/y 已標記。"] = "追蹤已知的 Runestone Rush 條目。x/y 已標記。",
    ["尚未加入 Runestone Rush 的追蹤條目。"] = "尚未加入 Runestone Rush 的追蹤條目。",
    ["派對必須繼續"] = "派對必須繼續",
    ["追蹤「派對必須繼續」的四個陣營邀請。x/y 已標記。"] = "追蹤「派對必須繼續」的四個陣營邀請。x/y 已標記。",
    ["尚未加入「派對必須繼續」的追蹤條目。"] = "尚未加入「派對必須繼續」的追蹤條目。",
    ["探索追蹤器"] = "探索追蹤器",
    ["追蹤 Explore Eversong Woods 的進度。x/y 已標記。"] = "追蹤 Explore Eversong Woods 的進度。x/y 已標記。",
    ["尚未加入 Explore Eversong Woods 的追蹤條目。"] = "尚未加入 Explore Eversong Woods 的追蹤條目。",
    ["追蹤 Explore Voidstorm 的進度。x/y 已標記。"] = "追蹤 Explore Voidstorm 的進度。x/y 已標記。",
    ["尚未加入 Explore Voidstorm 的追蹤條目。"] = "尚未加入 Explore Voidstorm 的追蹤條目。",
    ["追蹤 Explore Zul'Aman 的進度。x/y 已標記。"] = "追蹤 Explore Zul'Aman 的進度。x/y 已標記。",
    ["尚未加入 Explore Zul'Aman 的追蹤條目。"] = "尚未加入 Explore Zul'Aman 的追蹤條目。",
    ["追蹤 Explore Harandar 的進度。x/y 已標記。"] = "追蹤 Explore Harandar 的進度。x/y 已標記。",
    ["尚未加入 Explore Harandar 的追蹤條目。"] = "尚未加入 Explore Harandar 的追蹤條目。",
    ["追逐的刺激"] = "追逐的刺激",
    ["在 Voidstorm 中躲避飢渴存在的追捕至少 60 秒。"] = "在 Voidstorm 中躲避飢渴存在的追捕至少 60 秒。",
    ["這個成就不需要在 LiteVault 中追蹤座標。在 Voidstorm 中撐過飢渴存在事件至少 60 秒。"] = "這個成就不需要在 LiteVault 中追蹤座標。在 Voidstorm 中撐過飢渴存在事件至少 60 秒。",
    ["尚未加入「追逐的刺激」的追蹤條目。"] = "尚未加入「追逐的刺激」的追蹤條目。",
    ["沒時間磨爪"] = "沒時間磨爪",
    ["在擁有 15 層或以上「掠食者追擊」時完成 Harandar 世界任務「利爪執法」。"] = "在擁有 15 層或以上「掠食者追擊」時完成 Harandar 世界任務「利爪執法」。",
    ["這個成就不需要在 LiteVault 中追蹤座標。在擁有 15 層或以上「掠食者追擊」時完成 Harandar 世界任務「利爪執法」。"] = "這個成就不需要在 LiteVault 中追蹤座標。在擁有 15 層或以上「掠食者追擊」時完成 Harandar 世界任務「利爪執法」。",
    ["尚未加入「沒時間磨爪」的追蹤條目。"] = "尚未加入「沒時間磨爪」的追蹤條目。",
    ["從搖籃到墳墓"] = "從搖籃到墳墓",
    ["嘗試飛往 Harandar 上空高處的 The Cradle。"] = "嘗試飛往 Harandar 上空高處的 The Cradle。",
    ["飛入 Harandar 上空高處的 The Cradle 以完成這個成就。"] = "飛入 Harandar 上空高處的 The Cradle 以完成這個成就。",
    ["哈拉尼爾編年史家"] = "哈拉尼爾編年史家",
    ["這些日誌只會在每週任務「哈拉尼爾傳說」期間出現。處於幻象中時，請留意小地圖上的放大鏡圖示。"] = "這些日誌只會在每週任務「哈拉尼爾傳說」期間出現。處於幻象中時，請留意小地圖上的放大鏡圖示。",
    ["找回下方列出的哈拉尼爾日誌條目。"] = "找回下方列出的哈拉尼爾日誌條目。",
    ["找回下方列出的哈拉尼爾日誌條目。x/y 已標記。"] = "找回下方列出的哈拉尼爾日誌條目。x/y 已標記。",
    ["傳說永不消逝"] = "傳說永不消逝",
    ["這與每週任務「哈拉尼爾傳說」有關。如果你目前還沒有進度，預計大約需要 7 週完成。"] = "這與每週任務「哈拉尼爾傳說」有關。如果你目前還沒有進度，預計大約需要 7 週完成。",
    ["守護下方列出的每個哈拉尼爾傳說地點。"] = "守護下方列出的每個哈拉尼爾傳說地點。",
    ["保護下方列出的每個哈拉尼爾傳說地點。x/y 已標記。"] = "保護下方列出的每個哈拉尼爾傳說地點。x/y 已標記。",
    ["把牠們拍乾淨"] = "把牠們拍乾淨",
    ["找出所有藏在 Harandar 的發光飛蛾。x/y 已找到。"] = "找出所有藏在 Harandar 的發光飛蛾。x/y 已找到。",
    ["尚未加入座標分組。"] = "尚未加入座標分組。",
    ["這個追蹤器分成 3 組，每組 40 個座標，讓飛蛾路線更容易管理。"] = "這個追蹤器分成 3 組，每組 40 個座標，讓飛蛾路線更容易管理。",
    ["飛蛾 1-40 會在 Hara'ti 聲望 1 出現，並於聲望 2 可追蹤。"] = "飛蛾 1-40 會在 Hara'ti 聲望 1 出現，並於聲望 2 可追蹤。",
    ["飛蛾 41-80 會在 Hara'ti 聲望 4 出現，並於聲望 6 可追蹤。"] = "飛蛾 41-80 會在 Hara'ti 聲望 4 出現，並於聲望 6 可追蹤。",
    ["飛蛾 81-120 會在 Hara'ti 聲望 9 出現，並於聲望 11 可追蹤。"] = "飛蛾 81-120 會在 Hara'ti 聲望 9 出現，並於聲望 11 可追蹤。",
    ["LiteVault 路線預設你已經解鎖 Hara'ti 聲望 11。"] = "LiteVault 路線預設你已經解鎖 Hara'ti 聲望 11。",
    ["%s 包含 %d 個飛蛾座標。點擊飛蛾以放置路徑點。"] = "%s 包含 %d 個飛蛾座標。點擊飛蛾以放置路徑點。",
    ["第 1 組"] = "第 1 組",
    ["第 2 組"] = "第 2 組",
    ["第 3 組"] = "第 3 組",
    ["飛蛾"] = "飛蛾",
    ["一個奇點問題"] = "一個奇點問題",
    ["完成 Stormarion Assault 的三波攻勢。x/y 已標記。"] = "完成 Stormarion Assault 的三波攻勢。x/y 已標記。",
    ["尚未加入「一個奇點問題」的追蹤條目。"] = "尚未加入「一個奇點問題」的追蹤條目。",
    ["豐饒：繁盛滿盈！"] = "豐饒：繁盛滿盈！",
    ["在每個地點完成一次豐饒收穫洞穴流程。x/y 已標記。"] = "在每個地點完成一次豐饒收穫洞穴流程。x/y 已標記。",
    ["你必須在每個地點完成一次豐饒收穫洞穴流程才能獲得進度。只拜訪洞穴是不夠的。"] = "你必須在每個地點完成一次豐饒收穫洞穴流程才能獲得進度。只拜訪洞穴是不夠的。",
    ["尚未加入「豐饒：繁盛滿盈！」的追蹤條目。"] = "尚未加入「豐饒：繁盛滿盈！」的追蹤條目。",
    ["祝福祭壇"] = "祝福祭壇",
    ["觸發每個列出的祝福效果以取得進度。"] = "觸發每個列出的祝福效果以取得進度。",
    ["觸發每個列出的祝福效果。x/y 已標記。"] = "觸發每個列出的祝福效果。x/y 已標記。",
    ["綜合成就摘要"] = "綜合成就摘要",
    ["完成下方列出的 Eversong Woods 成就。x/y 已完成。"] = "完成下方列出的 Eversong Woods 成就。x/y 已完成。",
    ["完成下方列出的所有 Voidstorm 成就。x/y 已完成。"] = "完成下方列出的所有 Voidstorm 成就。x/y 已完成。",
    ["完成下方列出的所有 Zul'Aman 成就。x/y 已完成。"] = "完成下方列出的所有 Zul'Aman 成就。x/y 已完成。",
    ["透過完成下方成就來協助 Hara'ti。x/y 已完成。"] = "透過完成下方成就來協助 Hara'ti。x/y 已完成。",
    ["透過完成下方成就來集結你的力量對抗 Xal'atath。x/y 已完成。"] = "透過完成下方成就來集結你的力量對抗 Xal'atath。x/y 已完成。",
    ["尚未加入 Making an Amani Out of You 的追蹤條目。"] = "尚未加入 Making an Amani Out of You 的追蹤條目。",
    ["尚未加入 That's Aln, Folks! 的追蹤條目。"] = "尚未加入 That's Aln, Folks! 的追蹤條目。",
    ["尚未加入 Forever Song 的追蹤條目。"] = "尚未加入 Forever Song 的追蹤條目。",
    ["尚未加入 Yelling into the Voidstorm 的追蹤條目。"] = "尚未加入 Yelling into the Voidstorm 的追蹤條目。",
    ["尚未加入 Light Up the Night 的追蹤條目。"] = "尚未加入 Light Up the Night 的追蹤條目。",
    ["坐騎：璀璨花翼"] = "坐騎：璀璨花翼",
    ["家園裝飾：On'ohia 的呼喚"] = "家園裝飾：On'ohia 的呼喚",
    ["頭銜：「塵領主」"] = "頭銜：「塵領主」",
    ["頭銜：「哈拉尼爾編年史家」"] = "頭銜：「哈拉尼爾編年史家」",
    ["家園獎勵標籤："] = "家園獎勵標籤：",
}

L["團隊副本重新同步無法使用。"] = "團隊副本重新同步無法使用。"
L["遊玩時間訊息將被隱藏。"] = "遊玩時間訊息將被隱藏。"
L["遊玩時間訊息已恢復。"] = "遊玩時間訊息已恢復。"
L["%d分%02d秒"] = "%d分%02d秒"
L["紋章："] = "紋章："
L["坐騎掉落"] = "坐騎掉落"
L["（已收藏）"] = "（已收藏）"
L["（未收藏）"] = "（未收藏）"
L["坐騎：%d/%d"] = "坐騎：%d/%d"
L["虛無尖塔"] = "虛無尖塔"
L["夢境裂隙"] = "夢境裂隙"
L["奎爾達納斯遠征"] = "奎爾達納斯遠征"
L["團隊進度"] = "團隊進度"
L["莉亞德琳女士每週任務"] = "莉亞德琳女士每週任務"
L["更新日誌"] = "更新日誌"
L["返回"] = "返回"
L["戰隊銀行"] = "戰隊銀行"
L["論述"] = "論述"
L["工匠"] = "工匠"
L["追趕"] = "追趕"
L["LiteVault 更新摘要"] = "LiteVault 更新摘要"
L["更新了多項核心介面元素，包括貨幣圖示、團隊副本圖示、專業技能列以及豐碩寶庫追蹤器。"] = "更新了多項核心介面元素，包括貨幣圖示、團隊副本圖示、專業技能列以及豐碩寶庫追蹤器。"
L["調整了寶庫物品等級顯示，使其更接近暴雪預設的豐碩寶庫呈現方式。"] = "調整了寶庫物品等級顯示，使其更接近暴雪預設的豐碩寶庫呈現方式。"
L["為支援的語系新增了大量翻譯內容。"] = "為支援的語系新增了大量翻譯內容。"
L["優化了整個插件中的在地化文字顯示與刷新表現。"] = "優化了整個插件中的在地化文字顯示與刷新表現。"
L["更新了按鈕、背包分頁、每週文字及其他介面標籤的在地化支援。"] = "更新了按鈕、背包分頁、每週文字及其他介面標籤的在地化支援。"
L["修復了多項與在地化相關的版面配置問題。"] = "修復了多項與在地化相關的版面配置問題。"
L["修復了多項與在地化相關的崩潰問題。"] = "修復了多項與在地化相關的崩潰問題。"

L["明細"] = "明細"
L["戰隊明細"] = "戰隊明細"
L["儀式地點"] = "儀式地點"
L["最高名望"] = "最高名望"
L["巔峰"] = "巔峰"
L["獎勵：%s"] = "獎勵：%s"
L["獎勵資料載入中…"] = "獎勵資料載入中…"
L["點擊以切換此陣營。"] = "點擊以切換此陣營。"
L["獲得"] = "獲得"
L["主要來源"] = "主要來源"
L["最高收入來源"] = "最高收入來源"
L["最高支出來源"] = "最高支出來源"
L["顯示戰隊本週收入與支出的來源構成。"] = "顯示戰隊本週收入與支出的來源構成。"
L["本週戰隊獲得金幣最多的來源。"] = "本週戰隊獲得金幣最多的來源。"
L["本週戰隊花費金幣最多的來源。"] = "本週戰隊花費金幣最多的來源。"
L["尚無收入紀錄。"] = "尚無收入紀錄。"
L["尚無支出紀錄。"] = "尚無支出紀錄。"
L["未找到進行中的金幣世界任務。"] = "未找到進行中的金幣世界任務。"
L["世界任務"] = "世界任務"
L["升級"] = "升級"
L["停用符文石地圖標記"] = "停用符文石地圖標記"
L["在永歌森林地圖上隱藏 LiteVault 的符文石標記。"] = "在永歌森林地圖上隱藏 LiteVault 的符文石標記。"
L["啟用行事曆收益標示"] = "啟用行事曆收益標示"
L["在行事曆上顯示綠色與紅色的收益日標示。"] = "在行事曆上顯示綠色與紅色的收益日標示。"
L["下週：%s"] = "下週：%s"
L["每月收益"] = "每月收益"
L["本週收益最高角色"] = "本週收益最高角色"
L["本月收益最高角色"] = "本月收益最高角色"

L["BUTTON_CANCEL"] = "Cancel"
L["BUTTON_EDIT_MONTHLY_GOAL"] = "Edit Monthly Goal"
L["BUTTON_EDIT_WEEKLY_GOAL"] = "Edit Weekly Goal"
L["BUTTON_EXPORT_CSV"] = "Export CSV"
L["BUTTON_MONTHLY_PROFIT_EXPORT"] = "Monthly Profit CSV"
L["BUTTON_SAVE"] = "Save"
L["BUTTON_SELECT_ALL"] = "Select All"
L["BUTTON_SET"] = "Set"
L["BUTTON_WARBAND_BANK_HISTORY"] = "Warband Bank History"
L["BUTTON_WARBAND_PROFIT_EXPORT"] = "Warband Weekly Profit CSV"
L["BUTTON_WEEKLY_PROFIT_EXPORT"] = "Weekly Profit CSV"
L["HELP_THEME_CURRENT_FMT"] = "Current: %s"
L["HELP_THEME_DARK"] = "/lvtheme dark - Switch to Dark theme"
L["HELP_THEME_LIGHT"] = "/lvtheme light - Switch to Light theme"
L["HELP_THEME_TITLE"] = "LiteVault Theme Commands:"
L["HELP_THEME_TOGGLE"] = "/lvtheme - Toggle between themes"
L["LABEL_CHARACTER_TIME"] = "Character / Time"
L["LABEL_CURRENT"] = "Current"
L["LABEL_DEFENSE_FMT"] = "Defense: %s"
L["LABEL_DETAIL"] = "Detail"
L["LABEL_DETAILS"] = "Details"
L["LABEL_GOLD"] = "Gold"
L["LABEL_GOAL_AMOUNT"] = "Goal Amount (gold)"
L["LABEL_HISTORY_COUNT"] = "History Count"
L["LABEL_LAST_UPDATED"] = "Last Updated"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_TOKEN_AFFORDABLE"] = "Affordable"
L["LABEL_TOKEN_DELTA"] = "Delta"
L["LABEL_TOKEN_NOT_AFFORDABLE"] = "Cannot Afford"
L["LABEL_TOKEN_STALE"] = "Stale"
L["LABEL_WARBAND_WEEKLY_PROFIT"] = "Warband Weekly Profit"
L["LABEL_WOW_TOKEN"] = "WoW Token:"
L["MSG_NIT_TIMEPLAYED_WARNING"] = "NovaInstanceTracker detected. The /played message may be suppressed by NIT even when LiteVault's option is disabled."
L["MSG_PROFIT_GOAL_INVALID"] = "Enter a valid gold amount."
L["MSG_PROFIT_GOAL_NOT_SET"] = "No goal set"
L["MSG_RAID_RESYNC_COMPLETE"] = "Raid resync complete."
L["MSG_RAID_RESYNC_STARTED"] = "Raid resync started..."
L["MSG_RAID_RESYNC_UNAVAILABLE"] = "Raid resync unavailable."
L["MSG_THEME_SET_DARK"] = "Theme set to Dark (Void Purple)"
L["MSG_THEME_SET_LIGHT"] = "Theme set to Light"
L["MSG_THEME_SWITCHED_FMT"] = "Theme switched to %s"
L["MSG_TIMEPLAYED_RESTORED"] = "Time played messages restored."
L["MSG_TIMEPLAYED_SUPPRESSED"] = "Time played messages will be suppressed."
L["MSG_WOW_TOKEN_API_UNAVAILABLE"] = "WoW Token API is unavailable in this client."
L["MSG_WOW_TOKEN_DATA_UNAVAILABLE"] = "WoW Token data unavailable."
L["MSG_WOW_TOKEN_VISIT_AH"] = "Visit the Auction House to update WoW Token price."
L["MSG_WOW_TOKEN_VISIT_AH_SHORT"] = "Visit AH"
L["TAB_GLYPHS"] = "Glyphs"
L["TEXT_PROFIT_EXPORT_HINT"] = "Click in the box and press Ctrl+C to copy."
L["TEXT_PROFIT_EXPORT_SUBTITLE"] = "Copy the CSV text below."
L["TEXT_PROFIT_FALLBACK_APPEARANCE_COST"] = "Appearance cost"
L["TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT"] = "Auction deposit"
L["TEXT_PROFIT_FALLBACK_AUCTION_FEE"] = "Auction fee"
L["TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE"] = "Auction purchase"
L["TEXT_PROFIT_FALLBACK_AUCTION_SALE"] = "Auction sale"
L["TEXT_PROFIT_FALLBACK_BARBER_COST"] = "Barber cost"
L["TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE"] = "Black Market purchase"
L["TEXT_PROFIT_FALLBACK_CRAFTING_ORDER"] = "Crafting order"
L["TEXT_PROFIT_FALLBACK_GEAR_UPGRADE"] = "Gear upgrade"
L["TEXT_PROFIT_FALLBACK_GOLD_RECEIVED"] = "Gold received"
L["TEXT_PROFIT_FALLBACK_GOLD_REWARD"] = "Gold reward"
L["TEXT_PROFIT_FALLBACK_GOLD_SENT"] = "Gold sent"
L["TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT"] = "Guild deposit"
L["TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL"] = "Guild withdrawal"
L["TEXT_PROFIT_FALLBACK_RAW_GOLD"] = "Raw gold"
L["TEXT_PROFIT_FALLBACK_SERVICE_COST"] = "Service cost"
L["TEXT_PROFIT_FALLBACK_TRADE_GAIN"] = "Trade gain"
L["TEXT_PROFIT_FALLBACK_TRADE_PAYMENT"] = "Trade payment"
L["TEXT_PROFIT_FALLBACK_TRAINING_COST"] = "Training cost"
L["TEXT_PROFIT_FALLBACK_TRAVEL_COST"] = "Travel cost"
L["TEXT_PROFIT_ITEM_FALLBACK_FMT"] = "Item %d"
L["TEXT_PROFIT_GOALS_SUBTITLE"] = "Weekly and monthly net-profit targets for your warband."
L["TEXT_PROFIT_GOAL_EDITOR_HINT"] = "Enter a goal in gold. Leave blank or 0 to clear it."
L["TEXT_PROFIT_GRAPH_EMPTY_MONTHLY"] = "No monthly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND"] = "No warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY"] = "No monthly warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"] = "No weekly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_PENDING_MONTHLY"] = "Monthly graph history is now tracking and will populate as you earn or spend gold."
L["TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"] = "Monthly warband graph history is now tracking and will populate as gold changes are recorded."
L["TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"] = "No monthly ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WARBAND"] = "No warband ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"] = "No weekly ledger transactions recorded yet."
L["TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"] = "Daily net profit for the current character this month. New data starts filling as gold changes are recorded."
L["TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"] = "Recent monthly transactions for the current character."
L["TEXT_PROFIT_SUBTITLE"] = "Weekly and monthly profit across your tracked characters."
L["TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"] = "Daily combined profit across tracked characters over the last 7 days."
L["TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"] = "Recent combined weekly transactions across tracked characters."
L["TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"] = "Daily combined profit across tracked characters this month."
L["TEXT_PROFIT_SOURCE_AH_FEE"] = "AH Fee"
L["TEXT_PROFIT_SOURCE_BLACK_MARKET"] = "Black Market"
L["TEXT_PROFIT_SOURCE_CHEST"] = "Chest"
L["TEXT_PROFIT_SOURCE_CRAFT"] = "Craft"
L["TEXT_PROFIT_SOURCE_FLIGHT_PATH"] = "Flight Path"
L["TEXT_PROFIT_SOURCE_GUILD_BANK"] = "Guild Bank"
L["TEXT_PROFIT_SOURCE_LOOTED"] = "Looted"
L["TEXT_PROFIT_SOURCE_REPAIR"] = "Repair"
L["TEXT_PROFIT_SOURCE_TRAINING"] = "Training"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "Daily net profit for the current character over the last 7 days."
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "Recent weekly transactions for the current character."
L["TIME_DAYS_AGO_FMT"] = "%dd ago"
L["TIME_HOURS_AGO_FMT"] = "%dh ago"
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "%dm ago"
L["TIME_YESTERDAY"] = "Yesterday"
L["TITLE_GLYPH_HUNTER"] = "Glyph Hunter"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_RUNESTONE_EVENT"] = "Fortify the Runestones"
L["TOOLTIP_RUNESTONE_SET_WAYPOINT"] = "Click to set waypoint."
L["TOOLTIP_WOW_TOKEN_DESC"] = "Last known WoW Token market price."
L["TOOLTIP_WOW_TOKEN_TITLE"] = "WoW Token"

L["TEXT_ACHIEVEMENT_MOUNT_FMT"] = "Mount: %s"
L["LABEL_INFO"] = "Info"
L["Achievements"] = "Achievements"
L["Criteria"] = "Criteria"
L["Details"] = "Details"
L["Groups"] = "Groups"
L["Back to Groups"] = "Back to Groups"
L["Treasures of Midnight"] = "Treasures of Midnight"
L["Glory of the Midnight Delver"] = "Glory of the Midnight Delver"
L["Runestone Rush"] = "Runestone Rush"
L["The Party Must Go On"] = "The Party Must Go On"
L["A Singular Problem"] = "A Singular Problem"
L["From The Cradle to the Grave"] = "From The Cradle to the Grave"
L["Chronicler of the Haranir"] = "Chronicler of the Haranir"
L["Legends Never Die"] = "Legends Never Die"
L["Dust 'Em Off"] = "Dust 'Em Off"
L["No Time to Paws"] = "No Time to Paws"
L["Stormarion Assault"] = "Stormarion Assault"
L["Moths"] = "Moths"
L["Shared Loot"] = "Shared Loot"
L["Rares of Midnight"] = "Rares of Midnight"
L["Track the four Midnight treasure achievements and their rewards."] = "Track the four Midnight treasure achievements and their rewards."
L["Track the four zone achievements for Midnight, the Highest Peaks."] = "Track the four zone achievements for Midnight, the Highest Peaks."
L["Complete Glory of the Midnight Delver to earn this mount."] = "Complete Glory of the Midnight Delver to earn this mount."
L["Track the four Midnight rare achievements and zone rare rewards."] = "Track the four Midnight rare achievements and zone rare rewards."
L["Track the four Midnight rare achievements."] = "Track the four Midnight rare achievements."
L["Track Ever-Painting progress. Entry details can be filled in later."] = "Track Ever-Painting progress. Entry details can be filled in later."
L["Track Runestone Rush progress. Entry details can be filled in later."] = "Track Runestone Rush progress. Entry details can be filled in later."
L["Track The Party Must Go On progress. Entry details can be filled in later."] = "Track The Party Must Go On progress. Entry details can be filled in later."
L["Complete the five telescopes in this zone."] = "Complete the five telescopes in this zone."
L["Tracked entries for Ever-Painting have not been added yet."] = "Tracked entries for Ever-Painting have not been added yet."
L["Tracked entries for Runestone Rush have not been added yet."] = "Tracked entries for Runestone Rush have not been added yet."
L["Track the four faction invites for The Party Must Go On. x/y marked."] = "Track the four faction invites for The Party Must Go On. x/y marked."
L["Tracked entries for The Party Must Go On have not been added yet."] = "Tracked entries for The Party Must Go On have not been added yet."
L["Track Explore Eversong Woods progress. x/y marked."] = "Track Explore Eversong Woods progress. x/y marked."
L["Tracked entries for Explore Eversong Woods have not been added yet."] = "Tracked entries for Explore Eversong Woods have not been added yet."
L["Track the Eversong Woods meta-achievement and jump into its child trackers."] = "Track the Eversong Woods meta-achievement and jump into its child trackers."
L["Track Explore Voidstorm progress. x/y marked."] = "Track Explore Voidstorm progress. x/y marked."
L["Tracked entries for Explore Voidstorm have not been added yet."] = "Tracked entries for Explore Voidstorm have not been added yet."
L["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."
L["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."
L["Track Explore Zul'Aman progress. x/y marked."] = "Track Explore Zul'Aman progress. x/y marked."
L["Tracked entries for Explore Zul'Aman have not been added yet."] = "Tracked entries for Explore Zul'Aman have not been added yet."
L["Track the Voidstorm meta-achievement and jump into its child trackers."] = "Track the Voidstorm meta-achievement and jump into its child trackers."
L["Track the Zul'Aman meta-achievement and jump into its child trackers."] = "Track the Zul'Aman meta-achievement and jump into its child trackers."
L["Track Explore Harandar progress. x/y marked."] = "Track Explore Harandar progress. x/y marked."
L["Tracked entries for Explore Harandar have not been added yet."] = "Tracked entries for Explore Harandar have not been added yet."
L["Track the Harandar meta-achievement and jump into its child trackers."] = "Track the Harandar meta-achievement and jump into its child trackers."
L["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."
L["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."
L["Tracked entries for No Time to Paws have not been added yet."] = "Tracked entries for No Time to Paws have not been added yet."
L["Attempt to fly to The Cradle high in the sky above Harandar."] = "Attempt to fly to The Cradle high in the sky above Harandar."
L["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "Fly into The Cradle high in the sky above Harandar to complete this achievement."
L["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."
L["Recover the Haranir journal entries listed below."] = "Recover the Haranir journal entries listed below."
L["Recover the Haranir journal entries listed below. x/y marked."] = "Recover the Haranir journal entries listed below. x/y marked."
L["Protect each Haranir legend location listed below. x/y marked."] = "Protect each Haranir legend location listed below. x/y marked."
L["Defend each Haranir legend location listed below."] = "Defend each Haranir legend location listed below."
L["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "Find all of the Glowing Moths hiding in Harandar. x/y found."
L["Coordinate groups have not been added yet."] = "Coordinate groups have not been added yet."
L["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."
L["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."
L["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s contains %d moth coordinates. Click a moth to place a waypoint."
L["Complete all three waves of the Stormarion Assault. x/y marked."] = "Complete all three waves of the Stormarion Assault. x/y marked."
L["Wave 1 Complete"] = "Wave 1 Complete"
L["Wave 2 Complete"] = "Wave 2 Complete"
L["Wave 3 Complete"] = "Wave 3 Complete"
L["Tracked entries for A Singular Problem have not been added yet."] = "Tracked entries for A Singular Problem have not been added yet."
L["Abundance: Prosperous Plentitude!"] = "Abundance: Prosperous Plentitude!"
L["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."
L["Complete an Abundant Harvest cave run in each location. x/y marked."] = "Complete an Abundant Harvest cave run in each location. x/y marked."
L["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."
L["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "Rally your forces against Xal'atath by completing the achievements below. x/y done."
L["Aid the Hara'ti by completing the achievements below. x/y done."] = "Aid the Hara'ti by completing the achievements below. x/y done."
L["Complete all of the Voidstorm achievements listed below. x/y done."] = "Complete all of the Voidstorm achievements listed below. x/y done."
L["Complete all of the Zul'Aman achievements listed below. x/y done."] = "Complete all of the Zul'Aman achievements listed below. x/y done."
L["Complete the Eversong Woods achievements listed below. x/y done."] = "Complete the Eversong Woods achievements listed below. x/y done."
L["Complete the four Midnight zone meta-achievements and earn the mount reward."] = "Complete the four Midnight zone meta-achievements and earn the mount reward."
L["Track the known Ever-Painting canvases. x/y marked."] = "Track the known Ever-Painting canvases. x/y marked."
L["Track the known Runestone Rush entries. x/y marked."] = "Track the known Runestone Rush entries. x/y marked."
L["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "Complete all four supporting Midnight delver achievements to finish this meta achievement."
L["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."
L["Tracked entries for Thrill of the Chase have not been added yet."] = "Tracked entries for Thrill of the Chase have not been added yet."
L["Trigger each listed blessing effect. x/y marked."] = "Trigger each listed blessing effect. x/y marked."
L["Trigger each listed blessing effect for credit."] = "Trigger each listed blessing effect for credit."
L["Tracked entries for Making an Amani Out of You have not been added yet."] = "Tracked entries for Making an Amani Out of You have not been added yet."
L["Tracked entries for That's Aln, Folks! have not been added yet."] = "Tracked entries for That's Aln, Folks! have not been added yet."
L["Tracked entries for Forever Song have not been added yet."] = "Tracked entries for Forever Song have not been added yet."
L["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "Tracked entries for Yelling into the Voidstorm have not been added yet."
L["Tracked entries for Light Up the Night have not been added yet."] = "Tracked entries for Light Up the Night have not been added yet."
L["Click to open this tracker."] = "Click to open this tracker."
L["Achievement credit from:"] = "Achievement credit from:"
L["Complete the cave run here for credit."] = "Complete the cave run here for credit."
L["Charge the runestone with Latent Arcana to start its defense event."] = "Charge the runestone with Latent Arcana to start its defense event."
L["Coordinates pending."] = "Coordinates pending."
L["Tracker not added yet."] = "Tracker not added yet."
L["Zone reward not added yet."] = "Zone reward not added yet."
L["Meta reward not added yet."] = "Meta reward not added yet."
L["No achievement reward listed."] = "No achievement reward listed."
L["Mount: Brilliant Petalwing"] = "Mount: Brilliant Petalwing"
L["Housing Decor: On'ohia's Call"] = "Housing Decor: On'ohia's Call"


L["Track Explore Eversong Woods progress. Entry details can be filled in later."] = "Track Explore Eversong Woods progress. Entry details can be filled in later."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."

L["TITLE_RAID_PROGRESSION"] = "Raid Progression"
L["DIFFICULTY_LFR"] = "LFR"
L["LABEL_VAULT_TIER_FMT"] = "Tier %d"
L["LABEL_CRESTS"] = "Crests:"
L["TITLE_MOUNT_DROPS"] = "Mount Drops"
L["STATUS_COLLECTED_PARENS"] = "(Collected)"
L["STATUS_UNCOLLECTED_PARENS"] = "(Uncollected)"

L["BUTTON_BREAKDOWN"] = "Breakdown"
L["BUTTON_WARBAND_PROFIT_BREAKDOWN"] = "Warband Breakdown"
L["BUTTON_RITUAL_SITES"] = "Ritual Sites"
L["LABEL_MAX_RENOWN"] = "Maximum Renown"
L["LABEL_PARAGON"] = "Paragon"
L["LABEL_REWARD_FMT"] = "Reward: %s"
L["LABEL_REWARD_LOADING"] = "Reward data loading..."
L["TOOLTIP_FACTION_CARD_HINT"] = "Click to switch this faction."
L["LABEL_GAINED"] = "Gained"
L["LABEL_TOP_SOURCES"] = "Top Sources"
L["LABEL_TOP_INCOME_SOURCE"] = "Top Income Source"
L["LABEL_TOP_EXPENSE_SOURCE"] = "Top Expense Source"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "Source mix across your warband's weekly income and spending."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "Where your warband made the most gold this week."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "Where your warband spent the most gold this week."
L["MSG_PROFIT_NO_INCOME"] = "No income recorded yet."
L["MSG_PROFIT_NO_SPENDING"] = "No spending recorded yet."
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No active gold world quests found."
L["LEDGER_WORLD_QUESTS"] = "World Quests"
L["LEDGER_UPGRADE"] = "Upgrade"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "Disable Runestone Map Pins"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "Hide LiteVault's Fortify the Runestones pins on the Eversong Woods map."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "Enable Calendar Profit Highlights"
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"] = "Show green and red profit-day highlights on the calendar."
L["Community Engagement"] = "Community Engagement"
L["Void Strike"] = "Void Strike"
L["Void Assaults"] = "Void Assaults"
L["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods"
L["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman"
L["LABEL_NEXT_WEEK_FMT"] = "Next Week: %s"
L["Midnight: Prey"] = "Midnight: Prey"
L["Saltheril's Soiree"] = "Saltheril's Soiree"
L["Abundance Event"] = "Abundance Event"
L["Legends of the Haranir"] = "Legends of the Haranir"
L["Darkness Unmade"] = "Darkness Unmade"
L["Harvesting the Void"] = "Harvesting the Void"
L["Alchemy"] = "Alchemy"
L["Blacksmithing"] = "Blacksmithing"
L["Enchanting"] = "Enchanting"
L["Engineering"] = "Engineering"
L["Inscription"] = "Inscription"
L["Jewelcrafting"] = "Jewelcrafting"
L["Leatherworking"] = "Leatherworking"
L["Tailoring"] = "Tailoring"
L["Herbalism"] = "Herbalism"
L["Mining"] = "Mining"
L["Skinning"] = "Skinning"
L["Remnant of Anguish"] = "Remnant of Anguish"
L["Brimming Arcana"] = "Brimming Arcana"
L["Voidlight Marl"] = "Voidlight Marl"
L["Undercoin"] = "Undercoin"
L["Coffer Key Shards"] = "Coffer Key Shards"
L["Shard of Dundun"] = "Shard of Dundun"
L["Adventurer Dawncrest"] = "Adventurer Dawncrest"
L["Veteran Dawncrest"] = "Veteran Dawncrest"
L["Champion Dawncrest"] = "Champion Dawncrest"
L["Hero Dawncrest"] = "Hero Dawncrest"
L["Myth Dawncrest"] = "Myth Dawncrest"
L["Raid resync unavailable."] = "Raid resync unavailable."
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Time played messages restored."] = "Time played messages restored."
L["%dm %02ds"] = "%dm %02ds"
L["Crests:"] = "Crests:"
L["Mount Drops"] = "Mount Drops"
L["(Collected)"] = "(Collected)"
L["(Uncollected)"] = "(Uncollected)"
L["Mounts: %d/%d"] = "Mounts: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Mounts: %d/%d"
L["The Voidspire"] = "The Voidspire"
L["The Dreamrift"] = "The Dreamrift"
L["March of Quel'Danas"] = "March of Quel'Danas"
L["Lady Liadrin Weekly"] = "Lady Liadrin Weekly"
L["Change Log"] = "Change Log"
L["Back"] = "Back"
L["Warband Bank"] = "Warband Bank"
L["Treatise"] = "Treatise"
L["Artisan"] = "Artisan"
L["Catch-up"] = "Catch-up"
L["LiteVault Update Summary"] = "LiteVault Update Summary"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."
L["Added a large batch of new translations across supported locales."] = "Added a large batch of new translations across supported locales."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "Improved localized text rendering and refresh behavior throughout the addon."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "Updated localization support for buttons, bag tabs, weekly text, and other UI labels."
L["Fixed multiple localization-related layout issues."] = "Fixed multiple localization-related layout issues."
L["Fixed several localization-related crash issues."] = "Fixed several localization-related crash issues."
L["LABEL_MONTHLY_PROFIT"] = "Monthly Profit"
L["LABEL_TOP_WEEKLY_EARNERS"] = "Top Weekly Earners"
L["LABEL_TOP_MONTHLY_EARNERS"] = "Top Monthly Earners"

L["LABEL_CHARACTER"] = "Character"

L["WARNING_WEEKLY_AMANI_CHOICE"] = "Warning! Once you choose an Amani Tribe quest, it's locked to your account."
L["WARNING_WEEKLY_SINGULARITY_CHOICE"] = "Warning! Once you choose a The Singularity quest, it's locked to your account."

L["Ever-Painting"] = "Ever-Painting"
L["Midnight, the Highest Peaks"] = "Midnight, the Highest Peaks"
L["Explore Eversong Woods"] = "Explore Eversong Woods"
L["Explore Voidstorm"] = "Explore Voidstorm"
L["Explore Zul'Aman"] = "Explore Zul'Aman"
L["Explore Harandar"] = "Explore Harandar"
L["Thrill of the Chase"] = "Thrill of the Chase"
L["Making an Amani Out of You"] = "Making an Amani Out of You"
L["That's Aln, Folks!"] = "That's Aln, Folks!"
L["Forever Song"] = "Forever Song"
L["Yelling into the Voidstorm"] = "Yelling into the Voidstorm"
L["Light Up the Night"] = "Light Up the Night"
L["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."
L["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."
L["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."
L["Altar of Blessings: Sacred Buffet Devotee"] = "Altar of Blessings: Sacred Buffet Devotee"

-- Register this locale
lv.RegisterLocale("zhTW", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["zhTW"] = L






