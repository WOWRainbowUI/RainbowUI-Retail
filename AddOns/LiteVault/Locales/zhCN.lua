-- zhCN.lua - Simplified Chinese locale for LiteVault
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
    TOOLTIP_VOIDSHARDS_TITLE = "Ascendant Voidshards",
    TOOLTIP_VOIDCORES_TITLE = "Ascendant Voidcores",

    TOOLTIP_VAULT_TITLE = "宝库",
    TOOLTIP_VAULT_DESC = "点击打开每周宝库",
    TOOLTIP_VAULT_ACTIVE_ONLY = "打开每周宝库。",
    TOOLTIP_VAULT_ALT_ONLY = "每周宝库只能为当前激活的角色打开。",

    TOOLTIP_CURRENCY_TITLE = "角色货币",
    TOOLTIP_CURRENCY_DESC = "点击查看完整列表。",

    TOOLTIP_BAGS_TITLE = "查看背包",
    TOOLTIP_BAGS_DESC = "查看该角色已保存的背包和材料袋内容。",

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
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "检测到每周重置！已清除团队锁定。",
    MSG_ALREADY_TRACKED = "该角色已在追踪列表中。",
    MSG_CHAR_ADDED = "%s 已加入追踪。",
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
    ["复原的宝库钥匙"] = "复原的宝库钥匙",
    ["地底币"] = "地底币",
    ["Kej"] = "Kej",
    ["共鸣水晶"] = "共鸣水晶",
    ["暮刃徽记"] = "暮刃徽记",

    ["敦敦裂片"] = "敦敦裂片",
    ["掷骰子"] = "掷骰子",
    ["我们需要补充"] = "我们需要补充",
    ["可爱的羽饰"] = "可爱的羽饰",
    ["回响之釜"] = "回响之釜",
    ["无回响之焰"] = "无回响之焰",
    ["藏身处"] = "藏身处",
    ["胜利的风暴阿瑞恩巅峰宝匣"] = "胜利的风暴阿瑞恩巅峰宝匣",
    ["满溢的丰饶小袋"] = "满溢的丰饶小袋",
    ["勤学者的补给包"] = "勤学者的补给包",
    ["多余的派对礼品袋"] = "多余的派对礼品袋",
    ["满溢秘能"] = "满溢秘能",
    ["勇气石"] = "勇气石",
    ["风化虚空纹章"] = "风化虚空纹章",
    ["雕琢虚空纹章"] = "雕琢虚空纹章",
    ["符刻虚空纹章"] = "符刻虚空纹章",
    ["鎏金虚空纹章"] = "鎏金虚空纹章",
    ["冒险者晨辉纹章"] = "冒险者晨辉纹章",
    ["老兵晨辉纹章"] = "老兵晨辉纹章",
    ["勇士晨辉纹章"] = "勇士晨辉纹章",
    ["英雄晨辉纹章"] = "英雄晨辉纹章",
    ["神话晨辉纹章"] = "神话晨辉纹章",
    ["余留苦痛"] = "余留苦痛",
    ["晨光法力流"] = "晨光法力流",

    -- ==========================================================================
    -- WEEKLY QUESTS
    -- ==========================================================================
    ["世界之魂的呼唤"] = "世界之魂的呼唤",
    ["剧场巡演"] = "剧场巡演",
    ["觉醒机器"] = "觉醒机器",
    ["追寻历史"] = "追寻历史",
    ["全球研究"] = "全球研究",
    ["激涌冲动"] = "激涌冲动",
    ["散播圣光"] = "散播圣光",
    -- Midnight Weekly Quests
    ["社区参与"] = "社区参与",
    WARNING_ACCOUNT_BOUND = "账号绑定",
    ["午夜：猎物"] = "午夜：猎物",
    ["萨瑟里尔晚宴"] = "萨瑟里尔晚宴",
    ["丰饶活动"] = "丰饶活动",
    ["哈拉尼尔传说"] = "哈拉尼尔传说",
    ["破灭黑暗"] = "破灭黑暗",
    ["收割虚空"] = "收割虚空",
    ["午夜：萨瑟里尔晚宴"] = "午夜：萨瑟里尔晚宴",
    ["强化符文石：血骑士"] = "强化符文石：血骑士",
    ["强化符文石：街巷暗影"] = "强化符文石：街巷暗影",
    ["强化符文石：魔导师"] = "强化符文石：魔导师",
    ["强化符文石：远行者"] = "强化符文石：远行者",
    ["让他们步伐更利落"] = "让他们步伐更利落",
    ["小点心"] = "小点心",
    ["少点无法无天"] = "少点无法无天",
    ["微妙的游戏"] = "微妙的游戏",
    ["求爱得手"] = "求爱得手",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["炼金术"] = "炼金术",
    ["锻造"] = "锻造",
    ["附魔"] = "附魔",
    ["工程学"] = "工程学",
    ["铭文学"] = "铭文学",
    ["珠宝加工"] = "珠宝加工",
    ["制皮"] = "制皮",
    ["裁缝"] = "裁缝",
    ["草药学"] = "草药学",
    ["采矿"] = "采矿",
    ["剥皮"] = "剥皮",
    ["虚光泥灰"] = "虚光泥灰",
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
    BUTTON_PROFIT = "收益",
    LABEL_PROFIT_GOALS = "战团目标",
    LABEL_WEEKLY_GOAL = "每周目标",
    LABEL_MONTHLY_GOAL = "每月目标",
    BUTTON_EDIT = "编辑",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "本次重置期间的最高净收益。",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "当前月份中的最佳净收益。",
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
    ["宝库钥匙裂片"] = "宝库钥匙裂片",
    ["未受污染的法力水晶"] = "未受污染的法力水晶",
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
    ["午夜宝藏"] = "午夜宝藏",
    ["追踪午夜的四个宝藏成就及其奖励。"] = "追踪午夜的四个宝藏成就及其奖励。",
    ["午夜地下堡行者的荣耀"] = "午夜地下堡行者的荣耀",
    ["完成“午夜地下堡行者的荣耀”以获得这只坐骑。"] = "完成“午夜地下堡行者的荣耀”以获得这只坐骑。",
    ["追踪午夜的四个稀有成就和区域稀有奖励。"] = "追踪午夜的四个稀有成就和区域稀有奖励。",
    ["追踪午夜的四个稀有成就。"] = "追踪午夜的四个稀有成就。",
    ["完成该区域的五个望远镜。"] = "完成该区域的五个望远镜。",
    ["完成全部四个午夜地下堡行者支撑成就，以完成这个综合成就。"] = "完成全部四个午夜地下堡行者支撑成就，以完成这个综合成就。",
    ["猩红龙鹰"] = "猩红龙鹰",
    ["巨型螳螂"] = "巨型螳螂",
    ["成就"] = "成就",
    ["奖励"] = "奖励",
    ["详情"] = "详情",
    ["条件"] = "条件",
    ["信息"] = "信息",
    ["共享掉落"] = "共享掉落",
    ["分组"] = "分组",
    ["返回分组"] = "返回分组",
    ["未知"] = "未知",
    ["物品"] = "物品",
    ["未列出成就奖励。"] = "未列出成就奖励。",
    ["点击设置路径点。"] = "点击设置路径点。",
    ["点击打开此追踪器。"] = "点击打开此追踪器。",
    ["追踪器尚未添加。"] = "追踪器尚未添加。",
    ["坐标待补充。"] = "坐标待补充。",
    ["在这里完成洞穴流程以获得进度。"] = "在这里完成洞穴流程以获得进度。",
    ["用潜伏奥术为符文石充能，以开启它的防御事件。"] = "用潜伏奥术为符文石充能，以开启它的防御事件。",
    ["成就进度来源："] = "成就进度来源：",
    ["风暴阿里昂突袭"] = "风暴阿里昂突袭",
    ["永恒绘景"] = "永恒绘景",
    ["追踪已知的 Ever-Painting 画布。x/y 已标记。"] = "追踪已知的 Ever-Painting 画布。x/y 已标记。",
    ["尚未添加 Ever-Painting 的追踪条目。"] = "尚未添加 Ever-Painting 的追踪条目。",
    ["符文石竞速"] = "符文石竞速",
    ["追踪已知的 Runestone Rush 条目。x/y 已标记。"] = "追踪已知的 Runestone Rush 条目。x/y 已标记。",
    ["尚未添加 Runestone Rush 的追踪条目。"] = "尚未添加 Runestone Rush 的追踪条目。",
    ["派对必须继续"] = "派对必须继续",
    ["追踪“派对必须继续”的四个阵营邀请。x/y 已标记。"] = "追踪“派对必须继续”的四个阵营邀请。x/y 已标记。",
    ["尚未添加“派对必须继续”的追踪条目。"] = "尚未添加“派对必须继续”的追踪条目。",
    ["探索追踪器"] = "探索追踪器",
    ["追踪 Explore Eversong Woods 的进度。x/y 已标记。"] = "追踪 Explore Eversong Woods 的进度。x/y 已标记。",
    ["尚未添加 Explore Eversong Woods 的追踪条目。"] = "尚未添加 Explore Eversong Woods 的追踪条目。",
    ["追踪 Explore Voidstorm 的进度。x/y 已标记。"] = "追踪 Explore Voidstorm 的进度。x/y 已标记。",
    ["尚未添加 Explore Voidstorm 的追踪条目。"] = "尚未添加 Explore Voidstorm 的追踪条目。",
    ["追踪 Explore Zul'Aman 的进度。x/y 已标记。"] = "追踪 Explore Zul'Aman 的进度。x/y 已标记。",
    ["尚未添加 Explore Zul'Aman 的追踪条目。"] = "尚未添加 Explore Zul'Aman 的追踪条目。",
    ["追踪 Explore Harandar 的进度。x/y 已标记。"] = "追踪 Explore Harandar 的进度。x/y 已标记。",
    ["尚未添加 Explore Harandar 的追踪条目。"] = "尚未添加 Explore Harandar 的追踪条目。",
    ["追逐的刺激"] = "追逐的刺激",
    ["在 Voidstorm 中躲避饥渴存在的抓握至少 60 秒。"] = "在 Voidstorm 中躲避饥渴存在的抓握至少 60 秒。",
    ["这个成就不需要在 LiteVault 中进行坐标追踪。在 Voidstorm 中存活于饥渴存在事件至少 60 秒。"] = "这个成就不需要在 LiteVault 中进行坐标追踪。在 Voidstorm 中存活于饥渴存在事件至少 60 秒。",
    ["尚未添加“追逐的刺激”的追踪条目。"] = "尚未添加“追逐的刺激”的追踪条目。",
    ["没时间磨爪子"] = "没时间磨爪子",
    ["在拥有 15 层或以上“掠食者追猎”时完成 Harandar 世界任务“利爪执法”。"] = "在拥有 15 层或以上“掠食者追猎”时完成 Harandar 世界任务“利爪执法”。",
    ["这个成就不需要在 LiteVault 中进行坐标追踪。在拥有 15 层或以上“掠食者追猎”时完成 Harandar 世界任务“利爪执法”。"] = "这个成就不需要在 LiteVault 中进行坐标追踪。在拥有 15 层或以上“掠食者追猎”时完成 Harandar 世界任务“利爪执法”。",
    ["尚未添加“没时间磨爪子”的追踪条目。"] = "尚未添加“没时间磨爪子”的追踪条目。",
    ["从摇篮到坟墓"] = "从摇篮到坟墓",
    ["尝试飞向 Harandar 上空高处的 The Cradle。"] = "尝试飞向 Harandar 上空高处的 The Cradle。",
    ["飞入 Harandar 上空高处的 The Cradle 以完成该成就。"] = "飞入 Harandar 上空高处的 The Cradle 以完成该成就。",
    ["哈拉尼尔编年史家"] = "哈拉尼尔编年史家",
    ["这些日志只会在周常任务“哈拉尼尔传说”期间出现。处于幻象中时，请留意小地图上的放大镜图标。"] = "这些日志只会在周常任务“哈拉尼尔传说”期间出现。处于幻象中时，请留意小地图上的放大镜图标。",
    ["找回下方列出的哈拉尼尔日志条目。"] = "找回下方列出的哈拉尼尔日志条目。",
    ["找回下方列出的哈拉尼尔日志条目。x/y 已标记。"] = "找回下方列出的哈拉尼尔日志条目。x/y 已标记。",
    ["传奇永不消逝"] = "传奇永不消逝",
    ["这与周常任务“哈拉尼尔传说”相关。如果你目前还没有进度，预计大约需要 7 周完成。"] = "这与周常任务“哈拉尼尔传说”相关。如果你目前还没有进度，预计大约需要 7 周完成。",
    ["守卫下方列出的每一个哈拉尼尔传奇地点。"] = "守卫下方列出的每一个哈拉尼尔传奇地点。",
    ["保护下方列出的每一个哈拉尼尔传奇地点。x/y 已标记。"] = "保护下方列出的每一个哈拉尼尔传奇地点。x/y 已标记。",
    ["把它们掸干净"] = "把它们掸干净",
    ["找到所有藏在 Harandar 的发光飞蛾。x/y 已找到。"] = "找到所有藏在 Harandar 的发光飞蛾。x/y 已找到。",
    ["尚未添加坐标分组。"] = "尚未添加坐标分组。",
    ["该追踪器分为 3 组，每组 40 个坐标，以便飞蛾路线更易管理。"] = "该追踪器分为 3 组，每组 40 个坐标，以便飞蛾路线更易管理。",
    ["飞蛾 1-40 会在 Hara'ti 名望 1 出现，并在名望 2 时可追踪。"] = "飞蛾 1-40 会在 Hara'ti 名望 1 出现，并在名望 2 时可追踪。",
    ["飞蛾 41-80 会在 Hara'ti 名望 4 出现，并在名望 6 时可追踪。"] = "飞蛾 41-80 会在 Hara'ti 名望 4 出现，并在名望 6 时可追踪。",
    ["飞蛾 81-120 会在 Hara'ti 名望 9 出现，并在名望 11 时可追踪。"] = "飞蛾 81-120 会在 Hara'ti 名望 9 出现，并在名望 11 时可追踪。",
    ["LiteVault 路线默认你已经解锁 Hara'ti 名望 11。"] = "LiteVault 路线默认你已经解锁 Hara'ti 名望 11。",
    ["%s 包含 %d 个飞蛾坐标。点击飞蛾以放置路径点。"] = "%s 包含 %d 个飞蛾坐标。点击飞蛾以放置路径点。",
    ["第 1 组"] = "第 1 组",
    ["第 2 组"] = "第 2 组",
    ["第 3 组"] = "第 3 组",
    ["飞蛾"] = "飞蛾",
    ["一个奇点问题"] = "一个奇点问题",
    ["完成 Stormarion Assault 的全部三波。x/y 已标记。"] = "完成 Stormarion Assault 的全部三波。x/y 已标记。",
    ["尚未添加“一个奇点问题”的追踪条目。"] = "尚未添加“一个奇点问题”的追踪条目。",
    ["丰饶：繁盛充盈！"] = "丰饶：繁盛充盈！",
    ["在每个地点完成一次丰饶收获洞穴流程。x/y 已标记。"] = "在每个地点完成一次丰饶收获洞穴流程。x/y 已标记。",
    ["你需要在每个地点完成一次丰饶收获洞穴流程才能获得进度。仅仅访问洞穴并不足够。"] = "你需要在每个地点完成一次丰饶收获洞穴流程才能获得进度。仅仅访问洞穴并不足够。",
    ["尚未添加“丰饶：繁盛充盈！”的追踪条目。"] = "尚未添加“丰饶：繁盛充盈！”的追踪条目。",
    ["祝福祭坛"] = "祝福祭坛",
    ["触发每个列出的祝福效果以获得进度。"] = "触发每个列出的祝福效果以获得进度。",
    ["触发每个列出的祝福效果。x/y 已标记。"] = "触发每个列出的祝福效果。x/y 已标记。",
    ["综合成就摘要"] = "综合成就摘要",
    ["完成下方列出的 Eversong Woods 成就。x/y 已完成。"] = "完成下方列出的 Eversong Woods 成就。x/y 已完成。",
    ["完成下方列出的全部 Voidstorm 成就。x/y 已完成。"] = "完成下方列出的全部 Voidstorm 成就。x/y 已完成。",
    ["完成下方列出的全部 Zul'Aman 成就。x/y 已完成。"] = "完成下方列出的全部 Zul'Aman 成就。x/y 已完成。",
    ["通过完成下方成就来协助 Hara'ti。x/y 已完成。"] = "通过完成下方成就来协助 Hara'ti。x/y 已完成。",
    ["通过完成下方成就来集结你的力量对抗 Xal'atath。x/y 已完成。"] = "通过完成下方成就来集结你的力量对抗 Xal'atath。x/y 已完成。",
    ["尚未添加 Making an Amani Out of You 的追踪条目。"] = "尚未添加 Making an Amani Out of You 的追踪条目。",
    ["尚未添加 That's Aln, Folks! 的追踪条目。"] = "尚未添加 That's Aln, Folks! 的追踪条目。",
    ["尚未添加 Forever Song 的追踪条目。"] = "尚未添加 Forever Song 的追踪条目。",
    ["尚未添加 Yelling into the Voidstorm 的追踪条目。"] = "尚未添加 Yelling into the Voidstorm 的追踪条目。",
    ["尚未添加 Light Up the Night 的追踪条目。"] = "尚未添加 Light Up the Night 的追踪条目。",
    ["坐骑：璀璨花瓣翼"] = "坐骑：璀璨花瓣翼",
    ["家园装饰：On'ohia 的呼唤"] = "家园装饰：On'ohia 的呼唤",
    ["头衔：“尘领主”"] = "头衔：“尘领主”",
    ["头衔：“哈拉尼尔编年史家”"] = "头衔：“哈拉尼尔编年史家”",
    ["家园奖励标签："] = "家园奖励标签：",
}

L["团队副本重新同步不可用。"] = "团队副本重新同步不可用。"
L["游戏时长消息将被隐藏。"] = "游戏时长消息将被隐藏。"
L["游戏时长消息已恢复。"] = "游戏时长消息已恢复。"
L["%d分%02d秒"] = "%d分%02d秒"
L["纹章："] = "纹章："
L["坐骑掉落"] = "坐骑掉落"
L["（已收集）"] = "（已收集）"
L["（未收集）"] = "（未收集）"
L["坐骑：%d/%d"] = "坐骑：%d/%d"
L["虚空尖塔"] = "虚空尖塔"
L["梦境裂隙"] = "梦境裂隙"
L["奎尔达纳斯远征"] = "奎尔达纳斯远征"
L["团队进度"] = "团队进度"
L["莉亚德琳女士周常"] = "莉亚德琳女士周常"
L["更新日志"] = "更新日志"
L["返回"] = "返回"
L["战团银行"] = "战团银行"
L["论述"] = "论述"
L["工匠"] = "工匠"
L["追赶"] = "追赶"
L["LiteVault 更新摘要"] = "LiteVault 更新摘要"
L["更新了多项核心界面元素，包括货币图标、团队副本图标、专业条以及宏伟宝库追踪器。"] = "更新了多项核心界面元素，包括货币图标、团队副本图标、专业条以及宏伟宝库追踪器。"
L["调整了宝库物品等级显示，使其更接近暴雪默认的宏伟宝库表现方式。"] = "调整了宝库物品等级显示，使其更接近暴雪默认的宏伟宝库表现方式。"
L["为支持的语言环境新增了大量翻译内容。"] = "为支持的语言环境新增了大量翻译内容。"
L["优化了整个插件中的本地化文本显示与刷新表现。"] = "优化了整个插件中的本地化文本显示与刷新表现。"
L["更新了按钮、背包分页、每周文本及其他界面标签的本地化支持。"] = "更新了按钮、背包分页、每周文本及其他界面标签的本地化支持。"
L["修复了多个与本地化相关的布局问题。"] = "修复了多个与本地化相关的布局问题。"
L["修复了多个与本地化相关的崩溃问题。"] = "修复了多个与本地化相关的崩溃问题。"

L["明细"] = "明细"
L["战团明细"] = "战团明细"
L["仪式地点"] = "仪式地点"
L["最高名望"] = "最高名望"
L["巅峰"] = "巅峰"
L["奖励：%s"] = "奖励：%s"
L["奖励数据加载中…"] = "奖励数据加载中…"
L["点击切换此阵营。"] = "点击切换此阵营。"
L["获得"] = "获得"
L["主要来源"] = "主要来源"
L["最高收入来源"] = "最高收入来源"
L["最高支出来源"] = "最高支出来源"
L["显示战团本周收入与支出的来源构成。"] = "显示战团本周收入与支出的来源构成。"
L["本周战团获得金币最多的来源。"] = "本周战团获得金币最多的来源。"
L["本周战团花费金币最多的来源。"] = "本周战团花费金币最多的来源。"
L["尚无收入记录。"] = "尚无收入记录。"
L["尚无支出记录。"] = "尚无支出记录。"
L["未找到活跃的金币世界任务。"] = "未找到活跃的金币世界任务。"
L["世界任务"] = "世界任务"
L["升级"] = "升级"
L["禁用符文石地图标记"] = "禁用符文石地图标记"
L["在永歌森林地图上隐藏 LiteVault 的符文石标记。"] = "在永歌森林地图上隐藏 LiteVault 的符文石标记。"
L["启用日历收益高亮"] = "启用日历收益高亮"
L["在日历上显示绿色和红色的收益日高亮。"] = "在日历上显示绿色和红色的收益日高亮。"
L["下周：%s"] = "下周：%s"
L["月度收益"] = "月度收益"
L["本周收益最高角色"] = "本周收益最高角色"
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
lv.RegisterLocale("zhCN", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["zhCN"] = L






