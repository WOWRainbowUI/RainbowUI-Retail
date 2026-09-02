-- zhTW.lua - Traditional Chinese locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",

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
    TAB_TRACKERS = "追蹤器",
    TAB_META_ACHIEVEMENTS = "元成就",
    TEXT_FOLIO_NODE_FMT = "節點 %d",
    TEXT_GEAR_TITLE_FMT = "%s的%s",
    LABEL_GEAR_CRIT = "致命一擊",
    LABEL_GEAR_HASTE = "加速",
    LABEL_GEAR_MASTERY = "精通",
    LABEL_GEAR_VERS = "臨機應變",
    TEXT_GEAR_ILVL_COLORED_FMT = "裝等 |c%s%d|r",
    STATUS_LIVE = "[即時]",
    STATUS_CACHED = "[已快取]",
    STATUS_STALE = "[已過期]",
    TAB_OVERVIEW = "總覽",
    DIALOG_DELETE_CHAR = "要從戰隊追蹤刪除 %s 嗎？",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "戰隊追蹤",
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
    LABEL_WEEKLY_COMPLETION_SUMMARY = "%d / %d 已完成",
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
    TOOLTIP_VOIDSHARDS_TITLE = "昇華虛空裂片",
    TOOLTIP_VOIDCORES_TITLE = "昇華虛空核心",

    TOOLTIP_VAULT_TITLE = "寶庫",
    TOOLTIP_VAULT_DESC = "點擊開啟每週寶庫",
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
    LABEL_UNIQUE_TREASURES = "一次性寶藏",
    LABEL_WEEKLY_TREASURES = "每週寶藏",
    LABEL_HOVER_TREASURE_CHECKLIST = "滑鼠指向可查看寶藏清單",
    LABEL_TREASURE_CLICK_HINT = "點擊一次性寶藏以設置路線點",
    LABEL_ZONE = "區域",
    LABEL_COORDINATES = "座標",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "點一下設定地圖路線點",
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
    TITLE_RAID_FORMAT = "%s的%s%s - 法力熔爐奧米加",

    DIFFICULTY_NORMAL = "普通",
    DIFFICULTY_HEROIC = "英雄",
    DIFFICULTY_MYTHIC = "傳奇",

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
    PROMPT_GREETINGS = "%s，你好！\n是否要讓戰隊追蹤插件追蹤這個角色？",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "戰隊追蹤:",
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
    OPTION_DISABLE_TIMEPLAYED = "停用遊玩時間追蹤",
    OPTION_DISABLE_TIMEPLAYED_DESC = "防止 /played 訊息出現在聊天視窗",
    OPTION_ENABLE_24HR_CLOCK = "啟用 24 小時制時鐘",
    OPTION_ENABLE_24HR_CLOCK_DESC = "在 24 小時制與 12 小時制之間切換",
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
    ["寶庫鑰匙裂片"] = "寶庫鑰匙裂片",
    ["未受污染的法力水晶"] = "未受污染的法力水晶",
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
L["LiteVault 更新摘要"] = "戰隊追蹤更新摘要"
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
L["在永歌森林地圖上隱藏 LiteVault 的符文石標記。"] = "在永歌森林地圖上隱藏戰隊追蹤的符文石標記。"
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
L["LABEL_CHARACTER_TIME"] = "Character / Time"
L["LABEL_CURRENT"] = "Current"
L["LABEL_DEFENSE_FMT"] = "Defense: %s"
L["LABEL_DETAIL"] = "Detail"
L["LABEL_DETAILS"] = "Details"
L["LABEL_GOLD"] = "Gold"
L["LABEL_GOAL_AMOUNT"] = "Goal Amount (gold)"
L["LABEL_HISTORY_COUNT"] = "歷史記錄數"
L["LABEL_LAST_UPDATED"] = "Last Updated"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_TOKEN_AFFORDABLE"] = "可負擔"
L["LABEL_TOKEN_DELTA"] = "差值"
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
L["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = "購買魔獸代幣"
L["TEXT_PROFIT_ITEM_FALLBACK_FMT"] = "物品 %d"
L["TEXT_PROFIT_GOALS_SUBTITLE"] = "為你的戰隊設定每週與每月淨利目標。"
L["TEXT_PROFIT_GOAL_EDITOR_HINT"] = "輸入以金幣為單位的目標。留白或輸入 0 即可清除。"
L["TEXT_PROFIT_GRAPH_EMPTY_MONTHLY"] = "No monthly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND"] = "No warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY"] = "No monthly warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"] = "No weekly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_PENDING_MONTHLY"] = "每月圖表記錄現已開始追蹤，並會隨著你獲得或花費金幣逐步顯示資料。"
L["TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"] = "戰隊每月圖表記錄現已開始追蹤，並會隨著金幣變動被記錄而逐步顯示資料。"
L["TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"] = "No monthly ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WARBAND"] = "No warband ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"] = "No weekly ledger transactions recorded yet."
L["TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"] = "目前角色本月的每日淨利。記錄到金幣變動後將逐步顯示新資料。"
L["TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"] = "目前角色近期的每月交易。"
L["TEXT_PROFIT_SUBTITLE"] = "Weekly and monthly profit across your tracked characters."
L["TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"] = "過去 7 天所有已追蹤角色的每日合計利潤。"
L["TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"] = "所有已追蹤角色近期合計的每週交易。"
L["TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"] = "本月所有已追蹤角色的每日合計利潤。"
L["TEXT_PROFIT_SOURCE_AH_FEE"] = "拍賣場手續費"
L["TEXT_PROFIT_SOURCE_BLACK_MARKET"] = "Black Market"
L["TEXT_PROFIT_SOURCE_CHEST"] = "Chest"
L["TEXT_PROFIT_SOURCE_CRAFT"] = "Craft"
L["TEXT_PROFIT_SOURCE_FLIGHT_PATH"] = "Flight Path"
L["TEXT_PROFIT_SOURCE_GUILD_BANK"] = "Guild Bank"
L["TEXT_PROFIT_SOURCE_LOOTED"] = "Looted"
L["TEXT_PROFIT_SOURCE_REPAIR"] = "Repair"
L["TEXT_PROFIT_SOURCE_TRAINING"] = "Training"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "目前角色過去 7 天的每日淨利。"
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "目前角色近期的每週交易。"
L["TEXT_TRACKED_ACHIEVEMENT_ENTRIES_UNAVAILABLE_FMT"] = "尚未加入「%s」的追蹤項目。"
L["TIME_DAYS_AGO_FMT"] = "%d天前"
L["TIME_HOURS_AGO_FMT"] = "%d小時前"
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "%d分鐘前"
L["TIME_YESTERDAY"] = "Yesterday"
L["TITLE_GLYPH_HUNTER"] = "Glyph Hunter"
L["OPTION_ENABLE_MINI_OMNIUM_FOLIO"] = "Enable Mini Omnium Folio"
L["OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC"] = "Show a movable Omnium Folio panel outside the main LiteVault window for quick node access."
L["TEXT_FOLIO_AVAILABLE_POINTS_FMT"] = "Available Points: %d"
L["TEXT_OMNIUM_FOLIO_UNAVAILABLE"] = "Omnium Folio is unavailable."
L["TITLE_MINI_OMNIUM_FOLIO"] = "Omnium Folio"
L["TOOLTIP_HIDE_MINI_FOLIO"] = "Hide Mini Folio"
L["TOOLTIP_LOCK_MINI_FOLIO"] = "Lock Mini Folio"
L["TOOLTIP_UNLOCK_MINI_FOLIO"] = "Unlock Mini Folio"
L["TEXT_PROFIT_TOKENS_THIS_MONTH_FMT"] = "本月魔獸代幣：%d"
L["TITLE_PROFIT_WOW_TOKENS_THIS_MONTH"] = "本月的 WoW 代幣"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_PROFIT_WOW_TOKENS_THIS_MONTH"] = "統計目前日曆月份內購買的 WoW 代幣。代幣購買支出不計入利潤總額。"
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
L["Rares of Midnight"] = "Rares of Midnight"
L["Discover all of the lore objects found on the Coiled Isle."] = "發現 Coiled Isle 的所有傳說物件。"
L["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s包含%d個飛蛾座標。點擊飛蛾以設定路徑點。"
L["Abundance: Prosperous Plentitude!"] = "Abundance: Prosperous Plentitude!"


L["DIFFICULTY_LFR"] = "LFR"
L["LABEL_VAULT_TIER_FMT"] = "Tier %d"
L["LABEL_CRESTS"] = "Crests:"
L["TITLE_MOUNT_DROPS"] = "Mount Drops"
L["STATUS_COLLECTED_PARENS"] = "(Collected)"
L["STATUS_UNCOLLECTED_PARENS"] = "(Uncollected)"

L["BUTTON_BREAKDOWN"] = "Breakdown"
L["BUTTON_WARBAND_PROFIT_BREAKDOWN"] = "Warband Breakdown"
L["BUTTON_RITUAL_SITES"] = "Ritual Sites"
L["LABEL_MAX_RENOWN"] = "最高名望"
L["LABEL_PARAGON"] = "典範"
L["LABEL_REWARD_FMT"] = "獎勵：%s"
L["LABEL_REWARD_LOADING"] = "正在載入獎勵資料……"
L["TOOLTIP_FACTION_CARD_HINT"] = "Click to switch this faction."
L["LABEL_GAINED"] = "收入"
L["LABEL_TOP_SOURCES"] = "主要來源"
L["LABEL_TOP_INCOME_SOURCE"] = "最高收入來源"
L["LABEL_TOP_EXPENSE_SOURCE"] = "最高支出來源"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "戰隊每週收入與支出的來源分布。"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "本週戰隊獲得金幣最多的來源。"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "本週戰隊花費金幣最多的去向。"
L["MSG_PROFIT_NO_INCOME"] = "尚未記錄收入。"
L["MSG_PROFIT_NO_SPENDING"] = "尚未記錄支出。"
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No active gold world quests found."
L["LEDGER_WORLD_QUESTS"] = "World Quests"
L["LEDGER_UPGRADE"] = "升級"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "停用符文石地圖標記"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "不再於永歌森林地圖上顯示 LiteVault 的符文石標記。"
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "啟用行事曆利潤醒目提示"
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
L["LABEL_MOUNTS_FMT"] = "Mounts: %d/%d"
L["The Voidspire"] = "The Voidspire"
L["The Dreamrift"] = "The Dreamrift"
L["March of Quel'Danas"] = "March of Quel'Danas"
L["Lady Liadrin Weekly"] = "莉雅德倫女士每週任務"
L["Back"] = "Back"
L["Warband Bank"] = "Warband Bank"
L["Treatise"] = "論述"
L["Artisan"] = "工匠"
L["Catch-up"] = "Catch-up"
L["LABEL_MONTHLY_PROFIT"] = "每月利潤"
L["LABEL_TOP_WEEKLY_EARNERS"] = "每週收益最高角色"
L["LABEL_TOP_MONTHLY_EARNERS"] = "每月收益最高角色"

L["LABEL_CHARACTER"] = "Character"


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
L["Altar of Blessings: Sacred Buffet Devotee"] = "Altar of Blessings: Sacred Buffet Devotee"

-- Register this locale
L["LABEL_FIRST_KILL"] = "首次擊殺："
L["LABEL_EARLIEST_RECORDED_KILL"] = "最早記錄擊殺："
L["TEXT_HISTORICAL_DATA_UNAVAILABLE"] = "歷史資料無法使用"
L["LABEL_KNOWN_KILLS"] = "已知擊殺："
L["LABEL_ALSO_KILLED_BY"] = "其他擊殺角色："
L["TEXT_KILL_DATE_UNAVAILABLE"] = "擊殺日期無法使用"

L["BUTTON_ZULJARRA_FORCES"] = "Zul'jarra's Forces"
L["BUTTON_CAPTAIN_TOKKA"] = "托卡隊長"
L["LABEL_VALEERA_SANGUINAR"] = "Valeera Sanguinar"
L["LABEL_SLAYERS_DUELLUM"] = "Slayer's Duellum"
L["LABEL_MAXIMUM"] = "Maximum"
L["BUTTON_FACTION_WEEKLIES"] = "Faction Weeklies"
L["TITLE_TREASURES_OF_THE_DAMNED"] = "Treasures of the Damned"
L["LABEL_COMPLETED"] = "Completed"
L["LABEL_NOT_COMPLETED"] = "Not Completed"
L["LABEL_QUEST_FMT"] = "任務：%s"
L["LABEL_QUEST_ID_FMT"] = "任務 ID：%d"
L["TOOLTIP_TOKKA_TREASURE_HINT"] = "Fish this artifact up on the Coiled Isle and return it to Second Mate Sluggs at Tokka's Folly."
L["WARNING_TOKKA_ONE_TIME_ARTIFACTS"] = "Warning: These artifact quests are one-time Warband turn-ins. They do not reset daily or weekly and can only reward reputation once."
L["Turn Back the Surge"] = "Turn Back the Surge"
L["Purging the Vaults"] = "Purging the Vaults"
L["Spark of Tides"] = "Spark of Tides"
L["Venomblight Manaflux"] = "Venomblight Manaflux"
L["Adventurer Mistcrest"] = "Adventurer Mistcrest"
L["Veteran Mistcrest"] = "Veteran Mistcrest"
L["Champion Mistcrest"] = "Champion Mistcrest"
L["Hero Mistcrest"] = "Hero Mistcrest"
L["Myth Mistcrest"] = "Myth Mistcrest"
L["Corrosive Coin"] = "Corrosive Coin"
L["Trailing Xal'atath"] = "Trailing Xal'atath"
L["My Venomous Nemesis"] = "My Venomous Nemesis"
L.LABEL_CURRENT_CHARACTER = L.LABEL_CURRENT_CHARACTER or "目前角色"
L.LABEL_WARBAND_THIS_WEEK = L.LABEL_WARBAND_THIS_WEEK or "本週戰隊"
L.LABEL_RUNS = L.LABEL_RUNS or "次數"
L.STATUS_TIMED = L.STATUS_TIMED or "限時完成"
L.STATUS_DEPLETED = L.STATUS_DEPLETED or "超時"
L.LABEL_BEST_TIMED = L.LABEL_BEST_TIMED or "最高限時層數"
L.FILTER_THIS_WEEK = L.FILTER_THIS_WEEK or "本週"
L.FILTER_SEASON = L.FILTER_SEASON or "賽季"
L.FILTER_ALL_HISTORY = L.FILTER_ALL_HISTORY or "全部歷史"
L.SECTION_SEASON_BESTS = L.SECTION_SEASON_BESTS or "賽季最佳"
L.LABEL_BEST = L.LABEL_BEST or "最佳"
L.LABEL_SCORE = L.LABEL_SCORE or "評分"
L.LABEL_NO_RUN = L.LABEL_NO_RUN or "無記錄"
L.LABEL_LOWEST_SCORE = L.LABEL_LOWEST_SCORE or "最低評分"
L.LABEL_NO_MPLUS_KEY = L.LABEL_NO_MPLUS_KEY or "無傳奇鑰石"
L.LABEL_DUNGEON = L.LABEL_DUNGEON or "地城"
L.LABEL_KEY = L.LABEL_KEY or "鑰匙"
L.LABEL_RESULT = L.LABEL_RESULT or "結果"
L.LABEL_TIME = L.LABEL_TIME or "時間"
L.LABEL_DATE = L.LABEL_DATE or "日期"
L.LABEL_REWARDS = L.LABEL_REWARDS or "獎勵"
L.LABEL_MAP_RECORD = L.LABEL_MAP_RECORD or "地圖紀錄"
L.LABEL_AFFIX_RECORD = L.LABEL_AFFIX_RECORD or "詞綴紀錄"
L.LABEL_MPLUS_SCORE_PLAIN = L.LABEL_MPLUS_SCORE_PLAIN or "傳奇鑰石評分"
L.LABEL_TIMER = L.LABEL_TIMER or "計時器"
L.LABEL_TIME_REMAINING = L.LABEL_TIME_REMAINING or "剩餘時間"
L.LABEL_OVER_TIMER = L.LABEL_OVER_TIMER or "超時時間"
L.LABEL_RECORDED_DURATION = L.LABEL_RECORDED_DURATION or "記錄時長"
L.LABEL_NOT_AVAILABLE = L.LABEL_NOT_AVAILABLE or "--"
L.SECTION_MPLUS_HISTORY = L.SECTION_MPLUS_HISTORY or "傳奇鑰石歷史"
L.TEXT_NO_MPLUS_RUNS_THIS_WEEK = L.TEXT_NO_MPLUS_RUNS_THIS_WEEK or "本週尚未完成傳奇鑰石地城。"
L.TEXT_NO_MPLUS_RUNS_THIS_SEASON = L.TEXT_NO_MPLUS_RUNS_THIS_SEASON or "本賽季尚未完成傳奇鑰石地城。"
L.TEXT_NO_MPLUS_RUNS_RECORDED = L.TEXT_NO_MPLUS_RUNS_RECORDED or "尚無傳奇鑰石記錄。"
L.BUTTON_PLAN_RATING = L.BUTTON_PLAN_RATING or "規劃評分"
L.TITLE_MPLUS_RATING_PLANNER = L.TITLE_MPLUS_RATING_PLANNER or "傳奇鑰石評分規劃器"
L.BUTTON_BACK_TO_DASHBOARD = L.BUTTON_BACK_TO_DASHBOARD or "返回面板"
L.LABEL_CURRENT_RATING = L.LABEL_CURRENT_RATING or "目前評分"
L.LABEL_TARGET_RATING = L.LABEL_TARGET_RATING or "目標評分"
L.LABEL_MINIMUM_KEY = L.LABEL_MINIMUM_KEY or "最低鑰石"
L.LABEL_MAXIMUM_KEY = L.LABEL_MAXIMUM_KEY or "最高鑰石"
L.LABEL_AVOID_DUNGEONS = L.LABEL_AVOID_DUNGEONS or "避開地城"
L.BUTTON_CALCULATE_PLAN = L.BUTTON_CALCULATE_PLAN or "計算方案"
L.LABEL_MAXIMUM_PROJECTED_RATING = L.LABEL_MAXIMUM_PROJECTED_RATING or "最高預計評分"
L.LABEL_PROJECTED_RATING = L.LABEL_PROJECTED_RATING or "預計評分"
L.LABEL_CURRENT = L.LABEL_CURRENT or "目前"
L.LABEL_PLAN = L.LABEL_PLAN or "方案"
L.LABEL_GAIN = L.LABEL_GAIN or "提升"
L.TEXT_PLANNER_ALREADY_REACHED = L.TEXT_PLANNER_ALREADY_REACHED or "你已經達到此評分。"
L.TEXT_PLANNER_UNREACHABLE = L.TEXT_PLANNER_UNREACHABLE or "在目前規劃限制下無法達到目標。"
L.TEXT_PLANNER_INVALID_MINIMUM = L.TEXT_PLANNER_INVALID_MINIMUM or "最低鑰石必須是大於或等於2的整數。"
L.TEXT_PLANNER_INVALID_MAXIMUM = L.TEXT_PLANNER_INVALID_MAXIMUM or "最高鑰石必須不低於最低鑰石且不超過20。"
L.TEXT_PLANNER_INVALID_TARGET = L.TEXT_PLANNER_INVALID_TARGET or "請輸入有效的整數目標評分。"
L.TEXT_PLANNER_TIMED_ASSUMPTION = L.TEXT_PLANNER_TIMED_ASSUMPTION or "預計評分假定每個建議鑰石都能限時完成。"
L.PLANNER_FASTEST = L.PLANNER_FASTEST or "最快"
L.PLANNER_BALANCED = L.PLANNER_BALANCED or "均衡"
L.PLANNER_EASIEST = L.PLANNER_EASIEST or "最簡單"
local phase2 = {
MSG_NO_FACTION_WEEKLY_COMPLETIONS="目前沒有已追蹤的每週完成紀錄。", TOOLTIP_QUEST_ID_FMT="ID：|cffffffff%d", CALENDAR_MONTH_YEAR_FMT="%d年%s", LABEL_RENOWN_LEVEL_MAXIMUM_FMT="名望等級 %d - 已滿", LABEL_RENOWN_LEVEL_PROGRESS_FMT="名望等級 %d（%d/%d）", LABEL_RENOWN_LEVEL_FMT="名望等級 %d", LABEL_RENOWN_VALUE_FMT="名望 %d", TEXT_CRESTS_WITH_VALUES_FMT="紋章 %s", TOOLTIP_REWARDS_FMT="獎勵：%s", TOOLTIP_MOUNT_COLLECTED_FMT="%s（已收集）", TOOLTIP_MOUNT_UNCOLLECTED_FMT="%s（未收集）", LABEL_REWARD="獎勵", LABEL_NOTE="備註", STATUS_ACTIVE="啟用", TOOLTIP_ENTRANCE_COORDINATES_FMT="入口：%.2f, %.2f（地圖 %d）", TOOLTIP_INSCRIPTION_COORDINATES_FMT="銘文：%.2f, %.2f（地圖 %d）", TOOLTIP_ENTRANCE_INSCRIPTION_CLICK_INSTRUCTIONS="Shift點擊設定入口；點擊設定銘文位置。", LABEL_100_RENOWN_FMT="100 名望：%s", TOOLTIP_ACHIEVEMENT_CREDIT_FROM_FMT="成就進度來源：%s", NOTE_HARANDAR_TREASURE_REQUIREMENTS="部分寶藏需要額外步驟或物品才能開啟。", NOTE_FORGOTTEN_MASK_LOCATION="位於格納爾多島的一面破損石牆上，在探究入口南方。", NOTE_HEAD_MASONS_TABLET_LOCATION="位於東牙之門內。入口：地圖 2512 的 45.72, 64.94。", NOTE_PROFANED_PLAQUE_LOCATION="位於西牙之門內，進入後左手邊的房間。入口：地圖 2512 的 31.80, 64.91。", BUTTON_CANCEL="取消", BUTTON_SAVE="儲存", BUTTON_SELECT_ALL="全選", LABEL_COMPLETED="已完成", LABEL_NOT_COMPLETED="未完成", LABEL_DETAILS="詳細資料", LABEL_DETAIL="詳細資訊", LABEL_INFO="資訊", LABEL_MAXIMUM="最大", LABEL_PREVIOUS="上一個", LABEL_RECENT_HISTORY="近期紀錄", LABEL_SOURCE="來源", LABEL_STATUS="狀態", TIME_JUST_NOW="剛剛", TIME_YESTERDAY="昨天",
CALENDAR_MONTH_YEAR_FMT="%s %d年",
BUTTON_BACK_TO_GROUPS="返回群組", TEXT_COORDINATE_GROUPS_NOT_AVAILABLE="尚未加入座標群組。", TEXT_ZONE_REWARD_NOT_AVAILABLE="尚未加入區域獎勵。", TEXT_META_REWARD_NOT_AVAILABLE="尚未加入綜合成就獎勵。", TEXT_ACHIEVEMENT_REWARD_NOT_LISTED="未列出成就獎勵。", TOOLTIP_RUNESTONE_CHARGE_INSTRUCTION="使用潛在秘法為符文石充能，以開始防禦事件。", TEXT_COORDINATES_PENDING="座標待補充。", TOOLTIP_CLICK_OPEN_TRACKER="點擊開啟此追蹤器。", TEXT_TRACKER_NOT_AVAILABLE="尚未加入追蹤器。",
MSG_PROFIT_GOAL_INVALID="請輸入有效的金幣數額。", MSG_PROFIT_GOAL_NOT_SET="未設定目標", TEXT_PROFIT_EXPORT_HINT="點擊文字方塊並按 Ctrl+C 複製。", TEXT_PROFIT_EXPORT_SUBTITLE="複製下方的 CSV 文字。", TEXT_PROFIT_SOURCE_BLACK_MARKET="黑市", TEXT_PROFIT_SOURCE_CHEST="寶箱", TEXT_PROFIT_SOURCE_CRAFT="製造", TEXT_PROFIT_SOURCE_FLIGHT_PATH="飛行路線", TEXT_PROFIT_SOURCE_GUILD_BANK="公會銀行", TEXT_PROFIT_SOURCE_LOOTED="拾取", TEXT_PROFIT_SOURCE_REPAIR="修理", TEXT_PROFIT_SOURCE_TRAINING="訓練", TEXT_PROFIT_SOURCE_WORLD_QUEST="世界任務", MSG_RAID_RESYNC_COMPLETE="團隊副本重新同步完成。", MSG_RAID_RESYNC_STARTED="團隊副本重新同步已開始...", MSG_RAID_RESYNC_UNAVAILABLE="團隊副本重新同步無法使用。",
TEXT_PROFIT_FALLBACK_APPEARANCE_COST="外觀費用", TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT="拍賣押金", TEXT_PROFIT_FALLBACK_AUCTION_FEE="拍賣手續費", TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE="拍賣購買", TEXT_PROFIT_FALLBACK_AUCTION_SALE="拍賣出售", TEXT_PROFIT_FALLBACK_BARBER_COST="美容院費用", TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE="黑市購買", TEXT_PROFIT_FALLBACK_CRAFTING_ORDER="製造訂單", TEXT_PROFIT_FALLBACK_GEAR_UPGRADE="裝備升級", TEXT_PROFIT_FALLBACK_GOLD_RECEIVED="收到金幣", TEXT_PROFIT_FALLBACK_GOLD_REWARD="金幣獎勵", TEXT_PROFIT_FALLBACK_GOLD_SENT="寄出金幣", TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT="公會存款", TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL="公會提款", TEXT_PROFIT_FALLBACK_RAW_GOLD="直接金幣", TEXT_PROFIT_FALLBACK_SERVICE_COST="服務費用", TEXT_PROFIT_FALLBACK_TRADE_GAIN="交易收入", TEXT_PROFIT_FALLBACK_TRADE_PAYMENT="交易支出", TEXT_PROFIT_FALLBACK_TRAINING_COST="訓練費用", TEXT_PROFIT_FALLBACK_TRAVEL_COST="旅行費用", TEXT_PROFIT_GRAPH_EMPTY_MONTHLY="尚未記錄每月利潤歷史。", TEXT_PROFIT_GRAPH_EMPTY_WARBAND="尚未記錄戰隊利潤歷史。", TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY="尚未記錄每月戰隊利潤歷史。", TEXT_PROFIT_GRAPH_EMPTY_WEEKLY="尚未記錄每週利潤歷史。", TEXT_PROFIT_LEDGER_EMPTY_MONTHLY="尚未記錄每月帳本交易。", TEXT_PROFIT_LEDGER_EMPTY_WARBAND="尚未記錄戰隊帳本交易。", TEXT_PROFIT_LEDGER_EMPTY_WEEKLY="尚未記錄每週帳本交易。", TEXT_PROFIT_SUBTITLE="已追蹤角色的每週與每月利潤。",
BUTTON_BREAKDOWN="明細", BUTTON_FILTER="篩選", BUTTON_SET="設定", BUTTON_RAIDS="團隊副本", BUTTON_WARBAND_BANK_HISTORY="戰隊銀行歷史", TITLE_TREASURES_OF_THE_DAMNED="受詛者的寶藏", TOOLTIP_TOKKA_TREASURE_HINT="在 Coiled Isle 釣起這件神器，並將其交還給 Tokka's Folly 的 Second Mate Sluggs。", WARNING_TOKKA_ONE_TIME_ARTIFACTS="警告：這些神器任務是戰隊一次性繳交任務。它們不會每日或每週重置，且只能獲得一次聲望。", MSG_RAID_HISTORY_PRESERVED="團隊副本歷史已保留；會清除資料的賽季重置已停用。", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", TITLE_MINI_OMNIUM_FOLIO="奧秘寶典", TOOLTIP_HIDE_MINI_FOLIO="隱藏迷你寶典", TOOLTIP_LOCK_MINI_FOLIO="鎖定迷你寶典", TOOLTIP_UNLOCK_MINI_FOLIO="解鎖迷你寶典", TAB_GLYPHS="雕紋", TITLE_GLYPH_HUNTER="雕紋獵手", TOOLTIP_RUNESTONE_SET_WAYPOINT="點擊設定導航點。", LABEL_CHARACTER_TIME="角色時間", LABEL_LAST_UPDATED="上次更新", LABEL_VAULT_OVERALL_PROGRESS="總進度：%d/%d", LABEL_VAULT_ROW_DUNGEONS="地城", TITLE_CHARACTER_GREAT_VAULT_FMT="%s的寶庫：%s", TITLE_CHARACTER_WEEKLY_PLANNER_FMT="%s的每週規劃：%s", LABEL_NEXT_WEEK_FMT="下週：%s",
BUTTON_EDIT_MONTHLY_GOAL="編輯每月目標", BUTTON_EDIT_WEEKLY_GOAL="編輯每週目標", BUTTON_EXPORT_CSV="匯出 CSV", BUTTON_MONTHLY_PROFIT_EXPORT="每月利潤 CSV", BUTTON_WARBAND_PROFIT_BREAKDOWN="戰隊明細", BUTTON_WARBAND_PROFIT_EXPORT="戰隊每週利潤 CSV", BUTTON_WEEKLY_PROFIT_EXPORT="每週利潤 CSV", LABEL_GOAL_AMOUNT="目標金額（金幣）", LABEL_GOLD="金幣", LABEL_NET="淨額", LABEL_SHARE="分享", LABEL_ZONE="區域", LABEL_WARBAND_WEEKLY_PROFIT="戰隊每週利潤", MSG_NIT_TIMEPLAYED_WARNING="偵測到 NovaInstanceTracker。即使 LiteVault 的選項已停用，NIT 仍可能隱藏 /played 訊息。", MSG_TIMEPLAYED_RESTORED="遊戲時間訊息已恢復。", MSG_TIMEPLAYED_SUPPRESSED="遊戲時間訊息將被隱藏。", MSG_WOW_TOKEN_API_UNAVAILABLE="此遊戲版本無法使用魔獸代幣 API。", MSG_WOW_TOKEN_DATA_UNAVAILABLE="魔獸代幣資料無法使用。", MSG_WOW_TOKEN_VISIT_AH="請造訪拍賣場以更新魔獸代幣價格。", OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC="在行事曆上以綠色和紅色標示獲利與虧損日期。",
TITLE_ACHIEVEMENTS="成就", LABEL_ACHIEVEMENT_GROUPS="群組", LABEL_GLOWING_MOTHS="飛蛾", LABEL_SHARED_LOOT="共享拾取", LABEL_KNOWLEDGE_CATCHUP="追趕", STATUS_ASSAULT_WAVE_1_COMPLETE="第1波完成", STATUS_ASSAULT_WAVE_2_COMPLETE="第2波完成", STATUS_ASSAULT_WAVE_3_COMPLETE="第3波完成", TEXT_MIDNIGHT_RARES_TRACKER_DESCRIPTION="追蹤 Midnight 稀有成就、獎勵與共享掉落。", TEXT_MIDNIGHT_TREASURES_TRACKER_DESCRIPTION="追蹤 Midnight 寶藏成就及其獎勵。", TEXT_HARANIR_JOURNAL_INSTRUCTION="找回下方列出的 Haranir 日誌項目。", TEXT_HARANIR_LEGEND_DEFENSE_INSTRUCTION="保衛下方列出的每個 Haranir 傳說地點。", TEXT_BLESSING_EFFECT_INSTRUCTION="觸發列出的每種祝福效果以取得進度。", TOOLTIP_CAVE_RUN_CREDIT_INSTRUCTION="完成此處的洞穴挑戰以取得進度。", TEXT_TELESCOPE_ZONE_REQUIREMENT="完成此區域的五個望遠鏡目標。",
TEXT_MIDNIGHT_DELVER_META_INSTRUCTION="完成四項 Midnight 探究輔助成就以完成此綜合成就。", TEXT_COILED_ISLE_META_INSTRUCTION="完成 Coiled Isle 成就。", TEXT_MIDNIGHT_ZONE_META_REWARD_REQUIREMENT="完成四項 Midnight 區域綜合成就並取得坐騎獎勵。", TEXT_CLAW_ENFORCEMENT_REQUIREMENT="在擁有至少15層 Predator's Pursuit 時完成 Harandar 世界任務「Claw Enforcement」。", TEXT_ATALUTEK_META_INSTRUCTION="完成 Vaults of Atal'Utek 成就。", TEXT_COILED_ISLE_LORE_INSTRUCTION="發現 Coiled Isle 的傳說物件。", TEXT_HUNGERING_PRESENCE_REQUIREMENT="在 Voidstorm 躲避 Hungering Presence 的抓捕至少60秒。", TEXT_CRADLE_FLIGHT_REQUIREMENT="飛入 Harandar 高空中的 The Cradle 以完成此成就。", TEXT_EVERSONG_META_TRACKER_DESCRIPTION="追蹤 Eversong Woods 綜合成就並進入其子追蹤器。", TEXT_MIDNIGHT_PEAKS_TRACKER_DESCRIPTION="追蹤 Midnight, the Highest Peaks 的四項區域成就。", TEXT_HARANDAR_META_TRACKER_DESCRIPTION="追蹤 Harandar 綜合成就並進入其子追蹤器。", TEXT_VOIDSTORM_META_TRACKER_DESCRIPTION="追蹤 Voidstorm 綜合成就並進入其子追蹤器。", TEXT_ZULAMAN_META_TRACKER_DESCRIPTION="追蹤 Zul'Aman 綜合成就並進入其子追蹤器。", TEXT_CRADLE_FLIGHT_ATTEMPT="嘗試飛向 Harandar 高空中的 The Cradle。", NOTE_MOTH_ROUTE_RENOWN_REQUIREMENT="LiteVault 路線假定你已解鎖 Hara'ti Renown 11。",
TEXT_HARATI_META_PROGRESS_INSTRUCTION="完成下方成就以協助 Hara'ti。已完成 x/y。", TEXT_VOIDSTORM_META_PROGRESS_INSTRUCTION="完成下方列出的所有 Voidstorm 成就。已完成 x/y。", TEXT_ZULAMAN_META_PROGRESS_INSTRUCTION="完成下方列出的所有 Zul'Aman 成就。已完成 x/y。", TEXT_STORMARION_ASSAULT_PROGRESS_INSTRUCTION="完成 Stormarion Assault 的全部三波。已標記 x/y。", TEXT_ABUNDANT_HARVEST_PROGRESS_INSTRUCTION="在每個地點完成一次 Abundant Harvest 洞穴挑戰。已標記 x/y。", TEXT_EVERSONG_META_PROGRESS_INSTRUCTION="完成下方列出的 Eversong Woods 成就。已完成 x/y。", TEXT_GLOWING_MOTH_PROGRESS="找出藏在 Harandar 的所有 Glowing Moths。已找到 x/y。", TEXT_HARANIR_LEGEND_PROGRESS="保護下方列出的每個 Haranir 傳說地點。已標記 x/y。", TEXT_XALATATH_META_PROGRESS="完成下方成就以集結力量對抗 Xal'atath。已完成 x/y。", TEXT_HARANIR_JOURNAL_PROGRESS="找回下方列出的 Haranir 日誌項目。已標記 x/y。", TEXT_BLESSING_EFFECT_PROGRESS="觸發列出的每種祝福效果。已標記 x/y。", TEXT_FACTION_INVITE_PROGRESS="追蹤 The Party Must Go On 的四份陣營邀請。已標記 x/y。", TEXT_EVER_PAINTING_PROGRESS="追蹤已知的 Ever-Painting 畫布。已標記 x/y。", TEXT_RUNESTONE_RUSH_PROGRESS="追蹤已知的 Runestone Rush 項目。已標記 x/y。",
TEXT_DELVER_MOUNT_REWARD_REQUIREMENT="完成 Glory of the Midnight Delver 以取得此坐騎。", NOTE_MOTH_GROUP_1_RENOWN="飛蛾1–40在 Hara'ti Renown 1出現，並在 Renown 2解鎖追蹤。", NOTE_MOTH_GROUP_2_RENOWN="飛蛾41–80在 Hara'ti Renown 4出現，並在 Renown 6解鎖追蹤。", NOTE_MOTH_GROUP_3_RENOWN="飛蛾81–120在 Hara'ti Renown 9出現，並在 Renown 11解鎖追蹤。", NOTE_HARANIR_JOURNAL_AVAILABILITY="這些日誌僅在帳號通用每週任務「Legends of the Haranir」期間可用。進入幻象後，請留意小地圖上的放大鏡圖示。", NOTE_CLAW_ENFORCEMENT_NO_COORDINATES="此成就不需要 LiteVault 座標追蹤。在擁有至少15層 Predator's Pursuit 時完成 Harandar 世界任務「Claw Enforcement」。", NOTE_HUNGERING_PRESENCE_NO_COORDINATES="此成就不需要 LiteVault 座標追蹤。在 Voidstorm 的 Hungering Presence 事件中存活至少60秒。", NOTE_HARANIR_LEGENDS_WEEKLY_ESTIMATE="此內容與帳號通用每週任務「Legends of the Haranir」相關。如果尚無進度，預計約需7週完成。", NOTE_MOTH_TRACKER_GROUPING="此追蹤器分為3組，每組40個座標，以便管理飛蛾路線。", TEXT_EVER_PAINTING_TRACKER_PLACEHOLDER="追蹤 Ever-Painting 進度。項目詳情可稍後補充。", TEXT_EXPLORE_EVERSONG_TRACKER_PLACEHOLDER="追蹤 Explore Eversong Woods 進度。項目詳情可稍後補充。", TEXT_RUNESTONE_RUSH_TRACKER_PLACEHOLDER="追蹤 Runestone Rush 進度。項目詳情可稍後補充。", TEXT_PARTY_TRACKER_PLACEHOLDER="追蹤 The Party Must Go On 進度。項目詳情可稍後補充。", TOOLTIP_ABUNDANT_HARVEST_CREDIT_REQUIREMENT="你需要在每個地點完成一次 Abundant Harvest 洞穴挑戰。僅僅造訪洞穴並不足夠。",
TEXT_EXPLORE_EVERSONG_PROGRESS="追蹤 Explore Eversong Woods 進度。已標記 x/y。", TEXT_EXPLORE_HARANDAR_PROGRESS="追蹤 Explore Harandar 進度。已標記 x/y。", TEXT_EXPLORE_VOIDSTORM_PROGRESS="追蹤 Explore Voidstorm 進度。已標記 x/y。", TEXT_EXPLORE_ZULAMAN_PROGRESS="追蹤 Explore Zul'Aman 進度。已標記 x/y。",
}
for key,value in pairs(phase2) do L[key]=value end
lv.RegisterLocale("zhTW", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["zhTW"] = L

