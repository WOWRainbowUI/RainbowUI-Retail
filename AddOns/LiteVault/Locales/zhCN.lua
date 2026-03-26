-- zhCN.lua - Simplified Chinese locale for LiteVault
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
    BUTTON_CLOSE = "关闭",
    BUTTON_YES = "是",
    BUTTON_NO = "否",
    BUTTON_MANAGE = "管理",
    BUTTON_BACK = "返回",
    BUTTON_ALL = "全部",
    BUTTON_NONE = "无",
    BUTTON_FILTER = "筛选",
    DIALOG_DELETE_CHAR = "要从 LiteVault 删除 %s 吗？",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "地图筛选",

    BUTTON_RAID_LOCKOUTS = "团队锁定",
    BUTTON_WORLD_EVENTS = "世界事件",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "团队锁定",
    TOOLTIP_RAID_LOCKOUTS_DESC = "查看团队锁定与进度",
    TOOLTIP_ACTIONS_TITLE = "角色操作",
    TOOLTIP_ACTIONS_DESC = "打开操作菜单",
    TOOLTIP_THEME_TITLE = "切换主题",
    TOOLTIP_THEME_DESC = "在暗色与亮色主题间切换",
    TOOLTIP_FILTER_TITLE = "地图筛选",
    TOOLTIP_FILTER_DESC = "点击查看完整列表",
    TOOLTIP_WORLD_EVENTS_TITLE = "世界事件",
    TOOLTIP_WORLD_EVENTS_DESC = "查看世界事件",

    BUTTON_INSTANCES = "副本",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "副本追踪器",
    TOOLTIP_INSTANCE_TRACKER_DESC = "追踪地下城和团队次数",
    BUTTON_VAULT = "宝库",
    BUTTON_ACTIONS = "操作",
    BUTTON_RAIDS = "团队",
    BUTTON_FAVORITE = "收藏",
    BUTTON_UNFAVORITE = "取消收藏",
    BUTTON_IGNORE = "忽略",
    BUTTON_RESTORE = "恢复",
    BUTTON_DELETE = "删除",

    -- Sort controls
    LABEL_SORT_BY = "排序：",
    SORT_GOLD = "金币",
    SORT_ILVL = "装等",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "最近活跃",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "%s的每周任务",
    BUTTON_WEEKLIES = "每周",
    BUTTON_EVENTS = "活动",
    BUTTON_FACTIONS = "阵营",
    BUTTON_AMANI_TRIBE = "阿曼尼部族",
    BUTTON_HARATI = "哈拉提",
    BUTTON_SINGULARITY = "奇点",
    BUTTON_SILVERMOON_COURT = "银月宫廷",
    TITLE_FACTION_WEEKLIES = "%s的阵营每周任务",
    LABEL_RENOWN_PROGRESS = "名望 %d（%d/%d）",
    LABEL_RENOWN = "声望",
    LABEL_RENOWN_LEVEL = "等级",
    LABEL_RENOWN_UNAVAILABLE = "名望数据不可用",
    WARNING_EVENT_QUESTS = "这些活动中的一部分在游戏内仍有问题或尚未解锁。",
    WARNING_WEEKLY_HARATI_CHOICE = "警告！一旦选择了哈拉尼尔传说任务，该选择将锁定至整个账号。",
    WARNING_WEEKLY_RUNESTONES = "警告！请选择符文石任务时务必谨慎。一旦你本周选定一个，该选择就会锁定到整个账号。",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "该阵营尚未设置每周任务。",
    LABEL_WEEKLY_PROFIT = "本周收益：",
    LABEL_WARBAND_PROFIT = "战团收益：",
    LABEL_WARBAND_BANK = "战团银行：",
    LABEL_TOP_EARNERS = "本周最高收入：",
    LABEL_TOTAL_GOLD = "总金币：%s",
    LABEL_TOTAL_TIME = "总时间：%s",
    LABEL_COMBINED_TIME = "总游戏时间：%d天 %d小时",

    TOOLTIP_TOTAL_TIME_TITLE = "总时间",
    TOOLTIP_TOTAL_TIME_DESC = "所有已追踪角色的总游戏时间。",
    TOOLTIP_TOTAL_TIME_CLICK = "点击切换显示格式。",

    -- Quest status
    STATUS_DONE = "[完成]",
    STATUS_IN_PROGRESS = "[进行中]",
    STATUS_NOT_STARTED = "[未开始]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "管理角色",
    TOOLTIP_MANAGE_BACK = "返回主页面。",
    TOOLTIP_MANAGE_VIEW = "查看已忽略角色。",

    TOOLTIP_CATALYST_TITLE = "催化充能",
    TOOLTIP_SPARKS_TITLE = "制造火花",

    TOOLTIP_VAULT_TITLE = "宝库",
    TOOLTIP_VAULT_DESC = "点击打开每周宝库",
    TOOLTIP_VAULT_ACTIVE_ONLY = "打开每周宝库。",
    TOOLTIP_VAULT_ALT_ONLY = "每周宝库只能为当前激活的角色打开。",

    TOOLTIP_CURRENCY_TITLE = "角色货币",
    TOOLTIP_CURRENCY_DESC = "点击查看完整列表。",
    TOOLTIP_BAGS_TITLE = "查看背包",
    TOOLTIP_BAGS_DESC = "查看该角色已保存的背包和材料袋内容。",

    TOOLTIP_LEDGER_TITLE = "每周收益账本",
    TOOLTIP_LEDGER_DESC = "按来源追踪金币收入与支出。",

    TOOLTIP_WARBAND_BANK_TITLE = "战团银行账本",
    TOOLTIP_WARBAND_BANK_DESC = "点击查看战团银行交易。",

    TOOLTIP_RESTORE_TITLE = "恢复",
    TOOLTIP_RESTORE_DESC = "将此角色恢复到主页",

    TOOLTIP_IGNORE_TITLE = "忽略",
    TOOLTIP_IGNORE_DESC = "将此角色从主页移除",

    TOOLTIP_DELETE_TITLE = "删除",
    TOOLTIP_DELETE_DESC = "永久删除此角色数据",
    TOOLTIP_DELETE_WARNING = "警告：此操作无法撤销！",

    TOOLTIP_FAVORITE_TITLE = "收藏",
    TOOLTIP_FAVORITE_DESC = "将此角色固定到列表顶部",

    -- Character data displays
    LABEL_ILVL = "装等：%d",
    LABEL_MPLUS_SCORE = "M+分数：%d",
    LABEL_NO_KEY = "没有M+钥石",
    LABEL_NO_PROFESSIONS = "无专业",
    LABEL_UNKNOWN = "未知",
    LABEL_SKILL_LEVEL = "技能：%d/%d",
    LABEL_CONCENTRATION = "专注：%d/%d",
    LABEL_CONC_DAILY_RESET = "每日：%d小时 %d分钟",
    LABEL_CONC_WEEKLY_RESET = "完全重置：%d天 %d小时",
    LABEL_CONC_FULL = "(已满)",
    LABEL_KNOWLEDGE_AVAILABLE = "可用知识点：%d",
    LABEL_NO_KNOWLEDGE = "没有可用知识点",
    LABEL_VAULT_PROGRESS = "团：%d/3    M+：%d/3    世界：%d/3",
    BUTTON_LEDGER = "账本",
    BUTTON_KNOWLEDGE = "知识",
    BUTTON_PROFS = "专业",

    TOOLTIP_PROFS_TITLE = "专业",
    TOOLTIP_PROFS_DESC = "查看专注和知识点。",
    TITLE_PROFESSIONS = "%s的专业",
    TITLE_KNOWLEDGE_TRACKER = "知识追踪器",
    TOOLTIP_KNOWLEDGE_DESC = "查看已花费、未花费与总知识点",
    LABEL_SPENT = "已花费",
    LABEL_UNSPENT = "未花费",
    LABEL_MAX = "最大",
    LABEL_EARNED = "已获得",
    LABEL_TREATISE = "论述",
    LABEL_ARTISAN_QUEST = "工匠",
    LABEL_CATCHUP = "追赶",
    LABEL_WEEKLY = "每周",
    LABEL_UNLOCKED = "已解锁",
    LABEL_UNLOCK_REQUIREMENTS = "解锁需求",
    LABEL_SOURCE_NOTE = "每周来源与追赶进度快照",
    TITLE_KNOWLEDGE_SOURCES = "知识来源",
    TAB_TREASURES = "宝藏",
    LABEL_UNIQUE_TREASURES = "唯一宝藏",
    LABEL_WEEKLY_TREASURES = "每周宝藏",
    LABEL_HOVER_TREASURE_CHECKLIST = "悬停可查看宝藏清单",
    LABEL_TREASURE_CLICK_HINT = "点击唯一宝藏以设置路径点",
    LABEL_ZONE = "区域",
    LABEL_COORDINATES = "坐标",

    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "点击设置地图路径点",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "此宝藏没有固定位置",
    MSG_TREASURE_NO_WAYPOINT = "此宝藏没有固定路径点。",
    MSG_TOMTOM_NOT_DETECTED = "未检测到 TomTom。",

    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "已设置地图路径点：%s（%.1f，%.1f）",
    TITLE_PROF_TREASURES_FMT = "%s宝藏",
    LABEL_PROFESSION = "专业",
    LABEL_UNIQUE_TREASURE_FMT = "%s唯一宝藏 %d",
    LABEL_WEEKLY_TREASURE_FMT = "%s每周宝藏 %d",
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

    TOOLTIP_ACTIVITY_FOR = "%d/%d/%d 的活动",
    MSG_NO_WORLD_EVENTS = "本月没有世界事件",

    -- Filter categories
    FILTER_TIMEWALKING = "时光漫游",
    FILTER_DARKMOON = "暗月马戏团",
    FILTER_DUNGEONS = "地下城",
    FILTER_PVP = "玩家对玩家",
    FILTER_BONUS = "奖励",

    -- World events
    WORLD_EVENT_LOVE = "爱在空气中",
    WORLD_EVENT_LUNAR = "春节庆典",
    WORLD_EVENT_NOBLEGARDEN = "复活节庆典",
    WORLD_EVENT_CHILDREN = "儿童周",
    WORLD_EVENT_MIDSUMMER = "仲夏火焰节",
    WORLD_EVENT_BREWFEST = "美酒节",
    WORLD_EVENT_HALLOWS = "万圣节",
    WORLD_EVENT_WINTERVEIL = "冬幕节",
    WORLD_EVENT_DEAD = "亡者节",
    WORLD_EVENT_PIRATES = "海盗节",
    WORLD_EVENT_STYLE = "幻化大赛",
    WORLD_EVENT_OUTLAND = "外域杯",
    WORLD_EVENT_NORTHREND = "诺森德杯",
    WORLD_EVENT_KALIMDOR = "卡利姆多杯",
    WORLD_EVENT_EASTERN = "东部王国杯",
    WORLD_EVENT_WINDS = "神秘财运之风",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "%s的货币",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "团队锁定",
    TITLE_RAID_FORMAT = "%s的%s%s - 法力熔炉欧米伽",

    BUTTON_PROGRESSION = "进度",
    BUTTON_LOCKOUTS = "锁定",

    DIFFICULTY_NORMAL = "普通",
    DIFFICULTY_HEROIC = "英雄",
    DIFFICULTY_MYTHIC = "史诗",

    TOOLTIP_VIEW_LOCKOUTS = "当前显示：本周锁定",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "点击查看进度（历史最佳）",
    TOOLTIP_VIEW_PROGRESSION = "当前显示：进度（历史最佳）",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "点击查看本周锁定",

    MSG_NO_CHAR_DATA = "未找到角色数据",
    MSG_NO_PROGRESSION = "没有%s进度记录",
    MSG_NO_LOCKOUT = "本周没有%s锁定",

    LABEL_BOSS = "首领 %d",
    LABEL_PROGRESS_COUNT = "%d/8",
    LABEL_MIDNIGHT_SEASON_1 = "午夜第1赛季",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "战团银行账本",
    LABEL_CURRENT_BALANCE = "当前余额：",
    LABEL_RECENT_TRANSACTIONS = "近期交易：",
    MSG_NO_TRANSACTIONS = "（尚无交易记录）",
    TIP_RELOAD_SAVE = "提示：切换角色前请先 /reload 以保存数据",
    ACTION_DEPOSITED = "存入",
    ACTION_WITHDREW = "取出",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    TITLE_WEEKLY_LEDGER = "%s - 每周账本",
    LABEL_RESETS_IN = "%d天 %d小时后重置",

    TAB_SUMMARY = "总览",
    TAB_SOURCES = "来源",
    TAB_HISTORY = "记录",
    TAB_WARBAND = "战团",
    HEADER_SOURCE = "来源",
    HEADER_INCOME = "收入",
    HEADER_EXPENSE = "支出",

    LABEL_TOTAL = "总计",
    LABEL_NET_PROFIT = "净收益",
    MSG_NO_GOLD_ACTIVITY = "本周没有金币活动",
    MSG_NO_TRANSACTIONS_WEEK = "本周没有交易",

    -- Ledger source categories
    LEDGER_QUESTS = "任务",
    LEDGER_AUCTION = "拍卖行",
    LEDGER_TRADE = "交易",
    LEDGER_VENDOR = "商人",
    LEDGER_REPAIRS = "修理",
    LEDGER_TRANSMOG = "幻化",
    LEDGER_FLIGHT = "飞行路线",
    LEDGER_CRAFTING = "制造",
    LEDGER_CACHE = "宝箱/藏品",
    LEDGER_MAIL = "邮件",
    LEDGER_LOOT = "拾取",
    LEDGER_WARBAND_BANK = "战团银行",
    LEDGER_OTHER = "其他",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "从未",
    FRESH_TODAY = "今日活跃",
    FRESH_1_DAY = "1天前",
    FRESH_DAYS = "%d天前",

    -- Time format styles
    TIME_YEARS_DAYS = "%d年 %d天",
    TIME_DAYS_HOURS = "%d天 %d小时",
    TIME_DAYS = "%s 天",
    TIME_HOURS = "%s 小时",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "%s，你好！\n是否要让 LiteVault 追踪这个角色？",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault：",
    MSG_WEEKLY_RESET = "检测到每周重置！已清除团队锁定。",
    MSG_ALREADY_TRACKED = "该角色已在追踪列表中。",
    MSG_CHAR_ADDED = "%s 已加入追踪。",
    MSG_LEDGER_NOT_AVAILABLE = "账本不可用。",
    MSG_RAID_RESET_SEASON = "午夜第1赛季的团队进度已重置！",
    MSG_CLEARED_PROGRESSION = "已清除 %d 个角色的进度数据。",
    MSG_WEEKLY_PROFIT_RESET = "已重置 %d 个角色的每周收益追踪。",
    MSG_WARBAND_BALANCE = "战团：%s",
    MSG_WARBAND_BANK_BALANCE = "战团银行：%s",
    MSG_WEEKLY_DATA_RESET = "已重置 %d 个角色的每周数据。",
    MSG_RAID_MANUAL_RESET = "已手动重置团队进度！",
    MSG_CLEARED_DATA = "已清除 %d 个角色的数据。",

    -- Prompt to reload when time-played suppression setting changes
    MSG_RELOAD_TIMEPLAYED = "请重新加载界面以使游戏时间消息抑制生效。",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "暴雪初始的游戏时间消息无法被抑制。",

    -- Slash command help
    HELP_RESET_TITLE = "LiteVault 重置命令",
    HELP_REGION = "区域：%s（重置时间 %s）",
    HELP_LAST_SEASON = "上次赛季重置：%s",
    HELP_RESET_WEEKLY = "/lvreset weekly - 重置每周收益追踪",
    HELP_RESET_SEASON = "/lvreset season - 重置团队进度（新赛季）",
    HELP_NEVER = "从未",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "语言",
    TOOLTIP_LANGUAGE_TITLE = "语言",
    TOOLTIP_LANGUAGE_DESC = "更改界面语言",
    TITLE_LANGUAGE_SELECT = "选择语言",
    LANG_AUTO = "自动（检测）",
    MSG_LANGUAGE_CHANGED = "语言已更改。请重新加载界面以应用所有更改。",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "选项",
    TOOLTIP_OPTIONS_TITLE = "选项",
    TOOLTIP_OPTIONS_DESC = "配置 LiteVault 选项",
    TITLE_OPTIONS = "LiteVault 选项",
    OPTION_DISABLE_TIMEPLAYED = "禁用游戏时间追踪",
    OPTION_DISABLE_TIMEPLAYED_DESC = "阻止 /played 消息出现在聊天框",
    OPTION_ENABLE_24HR_CLOCK = "启用 24 小时制时钟",
    OPTION_ENABLE_24HR_CLOCK_DESC = "在 24 小时制与 12 小时制之间切换",
    OPTION_DARK_MODE = "暗色模式",
    OPTION_DARK_MODE_DESC = "在暗色和亮色主题间切换",
    OPTION_DISABLE_BAG_VIEWING = "禁用背包/银行查看器",
    OPTION_DISABLE_BAG_VIEWING_DESC = "隐藏背包按钮并禁用保存的背包、银行和战团银行查看功能。",
    OPTION_DISABLE_CHARACTER_OVERLAY = "禁用叠加层系统",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "隐藏 LiteVault 在角色和检查装备上的装等与锁定叠加层。",
    OPTION_DISABLE_MPLUS_TELEPORTS = "禁用 M+ 传送",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "隐藏 M+ 传送徽章并禁用 LiteVault 的传送面板。",

    -- Instance Tracker
    TITLE_INSTANCE_TRACKER = "副本追踪器",
    SECTION_INSTANCE_CAP = "副本上限（每小时10次）",
    LABEL_CAP_CURRENT = "当前：%d/10",
    LABEL_CAP_STATUS = "状态：%s",
    LABEL_NEXT_SLOT = "下个空位：%s",
    STATUS_SAFE = "安全",
    STATUS_WARNING = "警告",
    STATUS_LOCKED = "锁定",
    SECTION_CURRENT_RUN = "当前进行",
    LABEL_DURATION = "持续时间：%s",
    LABEL_NOT_IN_INSTANCE = "当前不在副本中",
    SECTION_PERFORMANCE = "今日表现",
    LABEL_DUNGEONS_TODAY = "地下城：%d",
    LABEL_RAIDS_TODAY = "团队：%d",
    LABEL_AVG_TIME = "平均：%s",
    SECTION_LEGACY_RAIDS = "本周旧团队",
    LABEL_LEGACY_RUNS = "次数：%d",
    LABEL_GOLD_EARNED = "金币：%s",
    SECTION_RECENT_RUNS = "近期副本",
    LABEL_NO_RECENT_RUNS = "没有近期记录",
    SECTION_MPLUS = "史诗+",
    LABEL_MPLUS_CURRENT_KEY = "当前钥石：",
    LABEL_RUNS_TODAY = "今日次数：%d",
    LABEL_RUNS_THIS_WEEK = "本周次数：%d",
    SECTION_RECENT_MPLUS_RUNS = "近期 M+ 记录",
    LABEL_NO_RECENT_MPLUS_RUNS = "没有近期 M+ 记录",

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
    ["Restored Coffer Key"] = "复原的宝库钥匙",
    ["Undercoin"] = "地底币",
    ["Kej"] = "Kej",
    ["Resonance Crystals"] = "共鸣水晶",
    ["Twilight's Blade Insignia"] = "暮刃徽记",

    ["Shard of Dundun"] = "敦敦裂片",
    ["Throw the Dice"] = "掷骰子",
    ["We Need a Refill"] = "我们需要补充",
    ["Lovely Plumage"] = "可爱的羽饰",
    ["The Cauldron of Echoes"] = "回响之釜",
    ["The Echoless Flame"] = "无回响之焰",
    ["Hidey-Hole"] = "藏身处",
    ["Victorious Stormarion Pinnacle Cache"] = "胜利的风暴阿瑞恩巅峰宝匣",
    ["Overflowing Abundant Satchel"] = "满溢的丰饶小袋",
    ["Avid Learner's Supply Pack"] = "勤学者的补给包",
    ["Surplus Bag of Party Favors"] = "多余的派对礼品袋",
    ["Brimming Arcana"] = "满溢秘能",
    ["Valorstones"] = "勇气石",
    ["Weathered Ethereal Crest"] = "风化虚空纹章",
    ["Carved Ethereal Crest"] = "雕琢虚空纹章",
    ["Runed Ethereal Crest"] = "符刻虚空纹章",
    ["Gilded Ethereal Crest"] = "鎏金虚空纹章",
    ["Adventurer Dawncrest"] = "冒险者晨辉纹章",
    ["Veteran Dawncrest"] = "老兵晨辉纹章",
    ["Champion Dawncrest"] = "勇士晨辉纹章",
    ["Hero Dawncrest"] = "英雄晨辉纹章",
    ["Myth Dawncrest"] = "神话晨辉纹章",
    ["Remnant of Anguish"] = "余留苦痛",
    ["Dawnlight Manaflux"] = "晨光法力流",

    -- ==========================================================================
    -- WEEKLY QUESTS
    -- ==========================================================================
    ["Call of the Worldsoul"] = "世界之魂的呼唤",
    ["Theater Troupe"] = "剧场巡演",
    ["Awakening Machine"] = "觉醒机器",
    ["Seeking History"] = "追寻历史",
    ["Worldwide Research"] = "全球研究",
    ["Urge to Surge"] = "激涌冲动",
    ["Spreading Light"] = "散播圣光",
    -- Midnight Weekly Quests
    ["Community Engagement"] = "社区参与",
    WARNING_ACCOUNT_BOUND = "账号绑定",
    ["Midnight: Prey"] = "午夜：猎物",
    ["Saltheril's Soiree"] = "萨瑟里尔晚宴",
    ["Abundance Event"] = "丰饶活动",
    ["Legends of the Haranir"] = "哈拉尼尔传说",
    ["Stormarion Assault"] = "风暴阿里昂突袭",
    ["Darkness Unmade"] = "破灭黑暗",
    ["Harvesting the Void"] = "收割虚空",
    ["Midnight: Saltheril's Soiree"] = "午夜：萨瑟里尔晚宴",
    ["Fortify the Runestones: Blood Knights"] = "强化符文石：血骑士",
    ["Fortify the Runestones: Shades of the Row"] = "强化符文石：街巷暗影",
    ["Fortify the Runestones: Magisters"] = "强化符文石：魔导师",
    ["Fortify the Runestones: Farstriders"] = "强化符文石：远行者",
    ["Put a Little Snap in Their Step"] = "让他们步伐更利落",
    ["Light Snacks"] = "小点心",
    ["Less Lawless"] = "少点无法无天",
    ["The Subtle Game"] = "微妙的游戏",
    ["Courting Success"] = "求爱得手",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "炼金术",
    ["Blacksmithing"] = "锻造",
    ["Enchanting"] = "附魔",
    ["Engineering"] = "工程学",
    ["Inscription"] = "铭文学",
    ["Jewelcrafting"] = "珠宝加工",
    ["Leatherworking"] = "制皮",
    ["Tailoring"] = "裁缝",
    ["Herbalism"] = "草药学",
    ["Mining"] = "采矿",
    ["Skinning"] = "剥皮",
    ["Voidlight Marl"] = "虚光泥灰",
    TELEPORT_PANEL_TITLE = "M+ 传送",
    TELEPORT_CAST_BTN = "传送",
    TELEPORT_ERR_COMBAT = "战斗中无法传送。",
    WORLD_EVENT_SALTHERIL = "萨瑟里尔的夜宴",
    WORLD_EVENT_ABUNDANCE = "丰饶",
    WORLD_EVENT_HARANIR = "哈拉尼尔传奇",
    WORLD_EVENT_STORMARION = "风暴玛瑞恩突袭",
    TOOLTIP_TREASURE_SET_WAYPOINT = "点击放置 TomTom 路径点",
    MSG_TREASURE_WAYPOINT_SET = "路径点已设置：%s (%.1f, %.1f)",
    TIME_TODAY = "今天 %H:%M",
    TIME_YESTERDAY = "昨天 %H:%M",
    MSG_CAP_WARNING = "副本上限警告！本小时已进入 %d/10 个副本。",
    MSG_CAP_SLOT_OPEN = "副本名额现已空出！(已使用 %d/10)",
    MSG_RAID_DEBUG_ON = "LiteVault 团队副本调试：开启",
    MSG_RAID_DEBUG_OFF = "LiteVault 团队副本调试：关闭",
    MSG_RAID_DEBUG_TIP = "再次使用 /lvraiddbg 可关闭调试输出",
    MSG_TRACKED_KILL = "已追踪 %s 击杀：%s (%s)",
    LOCALE_DEBUG_ON = "语言调试模式已开启 - 显示字符串键名",
    LOCALE_DEBUG_OFF = "语言调试模式已关闭 - 显示翻译文本",
    LOCALE_BORDERS_ON = "边框模式已开启 - 显示文本边界",
    LOCALE_BORDERS_HINT = "绿色 = 适配，红色 = 可能溢出",
    LOCALE_BORDERS_OFF = "边框模式已关闭",
    LOCALE_FORCED = "语言已强制设为 %s",
    LOCALE_RESET_TIP = "使用 /lvlocale reset 恢复自动检测",
    LOCALE_INVALID = "无效语言。有效选项：",
    LOCALE_RESET = "语言已重置为自动检测：%s",
    LOCALE_TITLE = "LiteVault 本地化",
    LOCALE_DETECTED = "检测到的语言：%s",
    LOCALE_FORCED_TO = "强制语言：%s",
    LOCALE_DEBUG_KEYS = "调试键：",
    LOCALE_DEBUG_BORDERS = "调试边框：",
    LOCALE_ON = "开启",
    LOCALE_OFF = "关闭",
    LOCALE_COMMANDS = "命令：",
    LOCALE_CMD_DEBUG = "/lvlocale debug - 切换键名显示模式",
    LOCALE_CMD_BORDERS = "/lvlocale borders - 切换文本边界可视化",
    LOCALE_CMD_LANG = "/lvlocale lang XX - 强制语言（例如 deDE、zhCN）",
    LOCALE_CMD_RESET = "/lvlocale reset - 重置为自动检测",
    LABEL_QUEST = "任务",
    BUTTON_DASHBOARD = "概览",
    BUTTON_ACHIEVEMENTS = "成就",
    TITLE_ACHIEVEMENTS = "成就",
    DESC_ACHIEVEMENTS = "选择一个成就追踪器以查看详细进度。",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "午夜符文猎手",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "午夜符文猎手",
    LABEL_REWARD = "奖励",
    DESC_GLYPH_REWARD = "完成午夜符文猎手以获得该坐骑。",
    MSG_NO_ACHIEVEMENT_DATA = "没有可用的成就追踪数据。",
    LABEL_CRITERIA = "条件",
    LABEL_GLYPHS_COLLECTED = "已收集符文",
    LABEL_ACHIEVEMENT = "成就",
    BUTTON_BAGS = "背包",
    BUTTON_BANK = "银行",
    BUTTON_WARBAND_BANK = "战团银行",
    BAGS_EMPTY_STATE = "该角色还没有保存的背包物品。",
    BANK_EMPTY_STATE = "该角色还没有保存的银行物品。",
    WARBANK_EMPTY_STATE = "还没有保存的战团银行物品。",
    LABEL_BAG_SLOTS = "栏位：%d / %d 已用",
    LABEL_SCANNED = "已扫描",
    ["Coffer Key Shards"] = "宝库钥匙裂片",
    ["Untainted Mana-Crystals"] = "未受污染的法力水晶",
    BUTTON_WEEKLY_PLANNER = "计划表",
    TITLE_WEEKLY_PLANNER = "每周计划表",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "每周计划表",
    TOOLTIP_WEEKLY_PLANNER_DESC = "可按角色编辑的每周清单。已完成的项目会在每周重置。",
    TOOLTIP_VAULT_STATUS = "查看宝库状态。",
    TITLE_GREAT_VAULT = "宏伟宝库",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "团队副本",
    LABEL_VAULT_ROW_DUNGEONS = "地下城",
    LABEL_VAULT_ROW_WORLD = "世界",
    LABEL_VAULT_SLOTS_UNLOCKED = "已解锁 %d/9 个槽位",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "尚未保存阈值数据。",
    MSG_VAULT_LIVE_ACTIVE = "当前角色的宏伟宝库实时进度。",
    MSG_VAULT_LIVE = "宏伟宝库实时进度。",
    MSG_VAULT_SAVED = "该角色上次登录时保存的宏伟宝库快照。",
    SECTION_DELVE_CURRENCY = "地下堡货币",
    SECTION_UPGRADE_CRESTS = "升级纹章",
    LABEL_CAP_SHORT = "上限 %s",
    ["Treasures of Midnight"] = "午夜宝藏",
    ["Track the four Midnight treasure achievements and their rewards."] = "追踪午夜的四个宝藏成就及其奖励。",
    ["Glory of the Midnight Delver"] = "午夜地下堡行者的荣耀",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "完成“午夜地下堡行者的荣耀”以获得这只坐骑。",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "追踪午夜的四个稀有成就和区域稀有奖励。",
    ["Track the four Midnight rare achievements."] = "追踪午夜的四个稀有成就。",
    ["Complete the five telescopes in this zone."] = "完成该区域的五个望远镜。",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "完成全部四个午夜地下堡行者支撑成就，以完成这个综合成就。",
    ["Crimson Dragonhawk"] = "猩红龙鹰",
    ["Giganto-Manis"] = "巨型螳螂",
    ["Achievements"] = "成就",
    ["Reward"] = "奖励",
    ["Details"] = "详情",
    ["Criteria"] = "条件",
    ["Info"] = "信息",
    ["Shared Loot"] = "共享掉落",
    ["Groups"] = "分组",
    ["Back to Groups"] = "返回分组",
    ["Back"] = "返回",
    ["Unknown"] = "未知",
    ["Item"] = "物品",
    ["No achievement reward listed."] = "未列出成就奖励。",
    ["Click to set waypoint."] = "点击设置路径点。",
    ["Click to open this tracker."] = "点击打开此追踪器。",
    ["Tracker not added yet."] = "追踪器尚未添加。",
    ["Coordinates pending."] = "坐标待补充。",
    ["Complete the cave run here for credit."] = "在这里完成洞穴流程以获得进度。",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "用潜伏奥术为符文石充能，以开启它的防御事件。",
    ["Achievement credit from:"] = "成就进度来源：",
    ["Stormarion Assault"] = "风暴阿里昂突袭",
    ["Ever-Painting"] = "永恒绘景",
    ["Track the known Ever-Painting canvases. x/y marked."] = "追踪已知的 Ever-Painting 画布。x/y 已标记。",
    ["Tracked entries for Ever-Painting have not been added yet."] = "尚未添加 Ever-Painting 的追踪条目。",
    ["Runestone Rush"] = "符文石竞速",
    ["Track the known Runestone Rush entries. x/y marked."] = "追踪已知的 Runestone Rush 条目。x/y 已标记。",
    ["Tracked entries for Runestone Rush have not been added yet."] = "尚未添加 Runestone Rush 的追踪条目。",
    ["The Party Must Go On"] = "派对必须继续",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "追踪“派对必须继续”的四个阵营邀请。x/y 已标记。",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "尚未添加“派对必须继续”的追踪条目。",
    ["Explore trackers"] = "探索追踪器",
    ["Track Explore Eversong Woods progress. x/y marked."] = "追踪 Explore Eversong Woods 的进度。x/y 已标记。",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "尚未添加 Explore Eversong Woods 的追踪条目。",
    ["Track Explore Voidstorm progress. x/y marked."] = "追踪 Explore Voidstorm 的进度。x/y 已标记。",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "尚未添加 Explore Voidstorm 的追踪条目。",
    ["Track Explore Zul'Aman progress. x/y marked."] = "追踪 Explore Zul'Aman 的进度。x/y 已标记。",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "尚未添加 Explore Zul'Aman 的追踪条目。",
    ["Track Explore Harandar progress. x/y marked."] = "追踪 Explore Harandar 的进度。x/y 已标记。",
    ["Tracked entries for Explore Harandar have not been added yet."] = "尚未添加 Explore Harandar 的追踪条目。",
    ["Thrill of the Chase"] = "追逐的刺激",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "在 Voidstorm 中躲避饥渴存在的抓握至少 60 秒。",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "这个成就不需要在 LiteVault 中进行坐标追踪。在 Voidstorm 中存活于饥渴存在事件至少 60 秒。",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "尚未添加“追逐的刺激”的追踪条目。",
    ["No Time to Paws"] = "没时间磨爪子",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "在拥有 15 层或以上“掠食者追猎”时完成 Harandar 世界任务“利爪执法”。",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "这个成就不需要在 LiteVault 中进行坐标追踪。在拥有 15 层或以上“掠食者追猎”时完成 Harandar 世界任务“利爪执法”。",
    ["Tracked entries for No Time to Paws have not been added yet."] = "尚未添加“没时间磨爪子”的追踪条目。",
    ["From The Cradle to the Grave"] = "从摇篮到坟墓",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "尝试飞向 Harandar 上空高处的 The Cradle。",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "飞入 Harandar 上空高处的 The Cradle 以完成该成就。",
    ["Chronicler of the Haranir"] = "哈拉尼尔编年史家",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "这些日志只会在账号绑定周常任务“哈拉尼尔传说”期间出现。处于幻象中时，请留意小地图上的放大镜图标。",
    ["Recover the Haranir journal entries listed below."] = "找回下方列出的哈拉尼尔日志条目。",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "找回下方列出的哈拉尼尔日志条目。x/y 已标记。",
    ["Legends Never Die"] = "传奇永不消逝",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "这与账号绑定周常任务“哈拉尼尔传说”相关。如果你目前还没有进度，预计大约需要 7 周完成。",
    ["Defend each Haranir legend location listed below."] = "守卫下方列出的每一个哈拉尼尔传奇地点。",
    ["Protect each Haranir legend location listed below. x/y marked."] = "保护下方列出的每一个哈拉尼尔传奇地点。x/y 已标记。",
    ["Dust 'Em Off"] = "把它们掸干净",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "找到所有藏在 Harandar 的发光飞蛾。x/y 已找到。",
    ["Coordinate groups have not been added yet."] = "尚未添加坐标分组。",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "该追踪器分为 3 组，每组 40 个坐标，以便飞蛾路线更易管理。",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "飞蛾 1-40 会在 Hara'ti 名望 1 出现，并在名望 2 时可追踪。",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "飞蛾 41-80 会在 Hara'ti 名望 4 出现，并在名望 6 时可追踪。",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "飞蛾 81-120 会在 Hara'ti 名望 9 出现，并在名望 11 时可追踪。",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "LiteVault 路线默认你已经解锁 Hara'ti 名望 11。",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s 包含 %d 个飞蛾坐标。点击飞蛾以放置路径点。",
    ["Group 1"] = "第 1 组",
    ["Group 2"] = "第 2 组",
    ["Group 3"] = "第 3 组",
    ["Moths"] = "飞蛾",
    ["A Singular Problem"] = "一个奇点问题",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "完成 Stormarion Assault 的全部三波。x/y 已标记。",
    ["Tracked entries for A Singular Problem have not been added yet."] = "尚未添加“一个奇点问题”的追踪条目。",
    ["Abundance: Prosperous Plentitude!"] = "丰饶：繁盛充盈！",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "在每个地点完成一次丰饶收获洞穴流程。x/y 已标记。",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "你需要在每个地点完成一次丰饶收获洞穴流程才能获得进度。仅仅访问洞穴并不足够。",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "尚未添加“丰饶：繁盛充盈！”的追踪条目。",
    ["Altar of Blessings"] = "祝福祭坛",
    ["Trigger each listed blessing effect for credit."] = "触发每个列出的祝福效果以获得进度。",
    ["Trigger each listed blessing effect. x/y marked."] = "触发每个列出的祝福效果。x/y 已标记。",
    ["Meta achievement summaries"] = "综合成就摘要",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "完成下方列出的 Eversong Woods 成就。x/y 已完成。",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "完成下方列出的全部 Voidstorm 成就。x/y 已完成。",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "完成下方列出的全部 Zul'Aman 成就。x/y 已完成。",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "通过完成下方成就来协助 Hara'ti。x/y 已完成。",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "通过完成下方成就来集结你的力量对抗 Xal'atath。x/y 已完成。",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "尚未添加 Making an Amani Out of You 的追踪条目。",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "尚未添加 That's Aln, Folks! 的追踪条目。",
    ["Tracked entries for Forever Song have not been added yet."] = "尚未添加 Forever Song 的追踪条目。",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "尚未添加 Yelling into the Voidstorm 的追踪条目。",
    ["Tracked entries for Light Up the Night have not been added yet."] = "尚未添加 Light Up the Night 的追踪条目。",
    ["Mount: Brilliant Petalwing"] = "坐骑：璀璨花瓣翼",
    ["Housing Decor: On'ohia's Call"] = "家园装饰：On'ohia 的呼唤",
    ["Title: \"Dustlord\""] = "头衔：“尘领主”",
    ["Title: \"Chronicler of the Haranir\""] = "头衔：“哈拉尼尔编年史家”",
    ["home reward labels:"] = "家园奖励标签：",
}

L["Raid resync unavailable."] = "团队副本重新同步不可用。"
L["Time played messages will be suppressed."] = "游戏时长消息将被隐藏。"
L["Time played messages restored."] = "游戏时长消息已恢复。"
L["%dm %02ds"] = "%d分%02d秒"
L["Crests:"] = "纹章："
L["Mount Drops"] = "坐骑掉落"
L["(Collected)"] = "（已收集）"
L["(Uncollected)"] = "（未收集）"
L["Mounts: %d/%d"] = "坐骑：%d/%d"
L["LABEL_MOUNTS_FMT"] = "坐骑：%d/%d"
L["The Voidspire"] = "虚空尖塔"
L["The Dreamrift"] = "梦境裂隙"
L["March of Quel'Danas"] = "奎尔达纳斯远征"
L["Raid Progression"] = "团队进度"
L["Lady Liadrin Weekly"] = "莉亚德琳女士周常"
L["Change Log"] = "更新日志"
L["Back"] = "返回"
L["Warband Bank"] = "战团银行"
L["Treatise"] = "论述"
L["Artisan"] = "工匠"
L["Catch-up"] = "追赶"
L["LiteVault Update Summary"] = "LiteVault 更新摘要"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "更新了多项核心界面元素，包括货币图标、团队副本图标、专业条以及宏伟宝库追踪器。"
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "调整了宝库物品等级显示，使其更接近暴雪默认的宏伟宝库表现方式。"
L["Added a large batch of new translations across supported locales."] = "为支持的语言环境新增了大量翻译内容。"
L["Improved localized text rendering and refresh behavior throughout the addon."] = "优化了整个插件中的本地化文本显示与刷新表现。"
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "更新了按钮、背包分页、每周文本及其他界面标签的本地化支持。"
L["Fixed multiple localization-related layout issues."] = "修复了多个与本地化相关的布局问题。"
L["Fixed several localization-related crash issues."] = "修复了多个与本地化相关的崩溃问题。"

-- Register this locale
lv.RegisterLocale("zhCN", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["zhCN"] = L













