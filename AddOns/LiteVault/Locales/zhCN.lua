-- zhCN.lua - Simplified Chinese locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",

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
    TAB_TRACKERS = "追踪器",
    TAB_META_ACHIEVEMENTS = "元成就",
    TEXT_FOLIO_NODE_FMT = "节点 %d",
    TEXT_GEAR_TITLE_FMT = "%s的%s",
    LABEL_GEAR_CRIT = "暴击",
    LABEL_GEAR_HASTE = "急速",
    LABEL_GEAR_MASTERY = "精通",
    LABEL_GEAR_VERS = "全能",
    TEXT_GEAR_ILVL_COLORED_FMT = "装等 |c%s%d|r",
    STATUS_LIVE = "[实时]",
    STATUS_CACHED = "[已缓存]",
    STATUS_STALE = "[已过期]",
    TAB_OVERVIEW = "概览",
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
    LABEL_WEEKLY_COMPLETION_SUMMARY = "%d / %d 已完成",
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
    TOOLTIP_VOIDSHARDS_TITLE = "升腾虚空碎片",
    TOOLTIP_VOIDCORES_TITLE = "升腾虚空核心",

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
    TITLE_RAID_FORMAT = "%s的%s%s - 法力熔炉欧米伽",

    DIFFICULTY_NORMAL = "普通",
    DIFFICULTY_HEROIC = "英雄",
    DIFFICULTY_MYTHIC = "史诗",

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
L["LABEL_CHARACTER_TIME"] = "Character / Time"
L["LABEL_CURRENT"] = "Current"
L["LABEL_DEFENSE_FMT"] = "Defense: %s"
L["LABEL_DETAIL"] = "Detail"
L["LABEL_DETAILS"] = "Details"
L["LABEL_GOLD"] = "Gold"
L["LABEL_GOAL_AMOUNT"] = "Goal Amount (gold)"
L["LABEL_HISTORY_COUNT"] = "历史记录数"
L["LABEL_LAST_UPDATED"] = "Last Updated"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_TOKEN_AFFORDABLE"] = "可负担"
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
L["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = "购买时光徽章"
L["TEXT_PROFIT_ITEM_FALLBACK_FMT"] = "物品 %d"
L["TEXT_PROFIT_GOALS_SUBTITLE"] = "为你的战团设定每周和每月净利润目标。"
L["TEXT_PROFIT_GOAL_EDITOR_HINT"] = "输入以金币为单位的目标。留空或输入 0 可将其清除。"
L["TEXT_PROFIT_GRAPH_EMPTY_MONTHLY"] = "No monthly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND"] = "No warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY"] = "No monthly warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"] = "No weekly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_PENDING_MONTHLY"] = "月度图表历史现已开始记录，并会随着你获得或花费金币逐步显示数据。"
L["TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"] = "战团月度图表历史现已开始记录，并会随着金币变化被记录而逐步显示数据。"
L["TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"] = "No monthly ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WARBAND"] = "No warband ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"] = "No weekly ledger transactions recorded yet."
L["TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"] = "当前角色本月的每日净利润。记录到金币变化后将逐步显示新数据。"
L["TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"] = "当前角色近期的月度交易。"
L["TEXT_PROFIT_SUBTITLE"] = "Weekly and monthly profit across your tracked characters."
L["TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"] = "过去 7 天所有已追踪角色的每日合计利润。"
L["TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"] = "所有已追踪角色近期合计的每周交易。"
L["TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"] = "本月所有已追踪角色的每日合计利润。"
L["TEXT_PROFIT_SOURCE_AH_FEE"] = "拍卖行手续费"
L["TEXT_PROFIT_SOURCE_BLACK_MARKET"] = "Black Market"
L["TEXT_PROFIT_SOURCE_CHEST"] = "Chest"
L["TEXT_PROFIT_SOURCE_CRAFT"] = "Craft"
L["TEXT_PROFIT_SOURCE_FLIGHT_PATH"] = "Flight Path"
L["TEXT_PROFIT_SOURCE_GUILD_BANK"] = "Guild Bank"
L["TEXT_PROFIT_SOURCE_LOOTED"] = "Looted"
L["TEXT_PROFIT_SOURCE_REPAIR"] = "Repair"
L["TEXT_PROFIT_SOURCE_TRAINING"] = "Training"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "当前角色过去 7 天的每日净利润。"
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "当前角色近期的每周交易。"
L["TEXT_TRACKED_ACHIEVEMENT_ENTRIES_UNAVAILABLE_FMT"] = "尚未添加“%s”的追踪条目。"
L["TIME_DAYS_AGO_FMT"] = "%d天前"
L["TIME_HOURS_AGO_FMT"] = "%d小时前"
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "%d分钟前"
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
L["TEXT_PROFIT_TOKENS_THIS_MONTH_FMT"] = "本月时光徽章：%d"
L["TITLE_PROFIT_WOW_TOKENS_THIS_MONTH"] = "本月的魔兽世界时光徽章"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_PROFIT_WOW_TOKENS_THIS_MONTH"] = "统计当前自然月内购买的魔兽世界时光徽章。购买时光徽章的支出不计入利润总额。"
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
L["Discover all of the lore objects found on the Coiled Isle."] = "发现 Coiled Isle 的所有传说物件。"
L["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s包含%d个飞蛾坐标。点击飞蛾以设置路径点。"
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
L["LABEL_PARAGON"] = "典范"
L["LABEL_REWARD_FMT"] = "奖励：%s"
L["LABEL_REWARD_LOADING"] = "正在加载奖励数据……"
L["TOOLTIP_FACTION_CARD_HINT"] = "Click to switch this faction."
L["LABEL_GAINED"] = "收入"
L["LABEL_TOP_SOURCES"] = "主要来源"
L["LABEL_TOP_INCOME_SOURCE"] = "最高收入来源"
L["LABEL_TOP_EXPENSE_SOURCE"] = "最高支出来源"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "战团每周收入与支出的来源构成。"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "本周战团获得金币最多的来源。"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "本周战团花费金币最多的去向。"
L["MSG_PROFIT_NO_INCOME"] = "尚未记录收入。"
L["MSG_PROFIT_NO_SPENDING"] = "尚未记录支出。"
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No active gold world quests found."
L["LEDGER_WORLD_QUESTS"] = "World Quests"
L["LEDGER_UPGRADE"] = "升级"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "禁用符文石地图标记"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "不再在永歌森林地图上显示 LiteVault 的符文石标记。"
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "启用日历利润高亮"
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
L["Lady Liadrin Weekly"] = "莉亚德琳女士周常"
L["Back"] = "Back"
L["Warband Bank"] = "Warband Bank"
L["Treatise"] = "论述"
L["Artisan"] = "工匠"
L["Catch-up"] = "Catch-up"
L["LABEL_MONTHLY_PROFIT"] = "月度利润"
L["LABEL_TOP_WEEKLY_EARNERS"] = "每周收益最高角色"
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
L["LABEL_FIRST_KILL"] = "首次击杀："
L["LABEL_EARLIEST_RECORDED_KILL"] = "最早记录击杀："
L["TEXT_HISTORICAL_DATA_UNAVAILABLE"] = "历史数据不可用"
L["LABEL_KNOWN_KILLS"] = "已知击杀："
L["LABEL_ALSO_KILLED_BY"] = "其他击杀角色："
L["TEXT_KILL_DATE_UNAVAILABLE"] = "击杀日期不可用"

L["BUTTON_ZULJARRA_FORCES"] = "Zul'jarra's Forces"
L["BUTTON_CAPTAIN_TOKKA"] = "托卡队长"
L["LABEL_VALEERA_SANGUINAR"] = "Valeera Sanguinar"
L["LABEL_SLAYERS_DUELLUM"] = "Slayer's Duellum"
L["LABEL_MAXIMUM"] = "Maximum"
L["BUTTON_FACTION_WEEKLIES"] = "Faction Weeklies"
L["TITLE_TREASURES_OF_THE_DAMNED"] = "Treasures of the Damned"
L["LABEL_COMPLETED"] = "Completed"
L["LABEL_NOT_COMPLETED"] = "Not Completed"
L["LABEL_QUEST_FMT"] = "任务：%s"
L["LABEL_QUEST_ID_FMT"] = "任务 ID：%d"
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
L.LABEL_CURRENT_CHARACTER = L.LABEL_CURRENT_CHARACTER or "当前角色"
L.LABEL_WARBAND_THIS_WEEK = L.LABEL_WARBAND_THIS_WEEK or "本周战团"
L.LABEL_RUNS = L.LABEL_RUNS or "次数"
L.STATUS_TIMED = L.STATUS_TIMED or "限时完成"
L.STATUS_DEPLETED = L.STATUS_DEPLETED or "超时"
L.LABEL_BEST_TIMED = L.LABEL_BEST_TIMED or "最高限时层数"
L.FILTER_THIS_WEEK = L.FILTER_THIS_WEEK or "本周"
L.FILTER_SEASON = L.FILTER_SEASON or "赛季"
L.FILTER_ALL_HISTORY = L.FILTER_ALL_HISTORY or "全部历史"
L.SECTION_SEASON_BESTS = L.SECTION_SEASON_BESTS or "赛季最佳"
L.LABEL_BEST = L.LABEL_BEST or "最佳"
L.LABEL_SCORE = L.LABEL_SCORE or "评分"
L.LABEL_NO_RUN = L.LABEL_NO_RUN or "无记录"
L.LABEL_LOWEST_SCORE = L.LABEL_LOWEST_SCORE or "最低评分"
L.LABEL_NO_MPLUS_KEY = L.LABEL_NO_MPLUS_KEY or "无史诗钥石"
L.LABEL_DUNGEON = L.LABEL_DUNGEON or "地下城"
L.LABEL_KEY = L.LABEL_KEY or "钥匙"
L.LABEL_RESULT = L.LABEL_RESULT or "结果"
L.LABEL_TIME = L.LABEL_TIME or "时间"
L.LABEL_DATE = L.LABEL_DATE or "日期"
L.LABEL_REWARDS = L.LABEL_REWARDS or "奖励"
L.LABEL_MAP_RECORD = L.LABEL_MAP_RECORD or "地图纪录"
L.LABEL_AFFIX_RECORD = L.LABEL_AFFIX_RECORD or "词缀纪录"
L.LABEL_MPLUS_SCORE_PLAIN = L.LABEL_MPLUS_SCORE_PLAIN or "史诗钥石评分"
L.LABEL_TIMER = L.LABEL_TIMER or "计时器"
L.LABEL_TIME_REMAINING = L.LABEL_TIME_REMAINING or "剩余时间"
L.LABEL_OVER_TIMER = L.LABEL_OVER_TIMER or "超时时间"
L.LABEL_RECORDED_DURATION = L.LABEL_RECORDED_DURATION or "记录时长"
L.LABEL_NOT_AVAILABLE = L.LABEL_NOT_AVAILABLE or "--"
L.SECTION_MPLUS_HISTORY = L.SECTION_MPLUS_HISTORY or "史诗钥石历史"
L.TEXT_NO_MPLUS_RUNS_THIS_WEEK = L.TEXT_NO_MPLUS_RUNS_THIS_WEEK or "本周尚未完成史诗钥石地下城。"
L.TEXT_NO_MPLUS_RUNS_THIS_SEASON = L.TEXT_NO_MPLUS_RUNS_THIS_SEASON or "本赛季尚未完成史诗钥石地下城。"
L.TEXT_NO_MPLUS_RUNS_RECORDED = L.TEXT_NO_MPLUS_RUNS_RECORDED or "尚无史诗钥石记录。"
L.BUTTON_PLAN_RATING = L.BUTTON_PLAN_RATING or "规划评分"
L.TITLE_MPLUS_RATING_PLANNER = L.TITLE_MPLUS_RATING_PLANNER or "史诗钥石评分规划器"
L.BUTTON_BACK_TO_DASHBOARD = L.BUTTON_BACK_TO_DASHBOARD or "返回面板"
L.LABEL_CURRENT_RATING = L.LABEL_CURRENT_RATING or "当前评分"
L.LABEL_TARGET_RATING = L.LABEL_TARGET_RATING or "目标评分"
L.LABEL_MINIMUM_KEY = L.LABEL_MINIMUM_KEY or "最低钥石"
L.LABEL_MAXIMUM_KEY = L.LABEL_MAXIMUM_KEY or "最高钥石"
L.LABEL_AVOID_DUNGEONS = L.LABEL_AVOID_DUNGEONS or "避开地下城"
L.BUTTON_CALCULATE_PLAN = L.BUTTON_CALCULATE_PLAN or "计算方案"
L.LABEL_MAXIMUM_PROJECTED_RATING = L.LABEL_MAXIMUM_PROJECTED_RATING or "最高预计评分"
L.LABEL_PROJECTED_RATING = L.LABEL_PROJECTED_RATING or "预计评分"
L.LABEL_CURRENT = L.LABEL_CURRENT or "当前"
L.LABEL_PLAN = L.LABEL_PLAN or "方案"
L.LABEL_GAIN = L.LABEL_GAIN or "提升"
L.TEXT_PLANNER_ALREADY_REACHED = L.TEXT_PLANNER_ALREADY_REACHED or "你已经达到此评分。"
L.TEXT_PLANNER_UNREACHABLE = L.TEXT_PLANNER_UNREACHABLE or "在当前规划限制下无法达到目标。"
L.TEXT_PLANNER_INVALID_MINIMUM = L.TEXT_PLANNER_INVALID_MINIMUM or "最低钥石必须是大于或等于2的整数。"
L.TEXT_PLANNER_INVALID_MAXIMUM = L.TEXT_PLANNER_INVALID_MAXIMUM or "最高钥石必须不低于最低钥石且不超过20。"
L.TEXT_PLANNER_INVALID_TARGET = L.TEXT_PLANNER_INVALID_TARGET or "请输入有效的整数目标评分。"
L.TEXT_PLANNER_TIMED_ASSUMPTION = L.TEXT_PLANNER_TIMED_ASSUMPTION or "预计评分假定每个建议钥石都能限时完成。"
L.PLANNER_FASTEST = L.PLANNER_FASTEST or "最快"
L.PLANNER_BALANCED = L.PLANNER_BALANCED or "均衡"
L.PLANNER_EASIEST = L.PLANNER_EASIEST or "最简单"
local phase2 = {
MSG_NO_FACTION_WEEKLY_COMPLETIONS="暂无已追踪的每周完成记录。", TOOLTIP_QUEST_ID_FMT="ID：|cffffffff%d", CALENDAR_MONTH_YEAR_FMT="%d年%s", LABEL_RENOWN_LEVEL_MAXIMUM_FMT="名望等级 %d - 已满", LABEL_RENOWN_LEVEL_PROGRESS_FMT="名望等级 %d（%d/%d）", LABEL_RENOWN_LEVEL_FMT="名望等级 %d", LABEL_RENOWN_VALUE_FMT="名望 %d", TEXT_CRESTS_WITH_VALUES_FMT="纹章 %s", TOOLTIP_REWARDS_FMT="奖励：%s", TOOLTIP_MOUNT_COLLECTED_FMT="%s（已收集）", TOOLTIP_MOUNT_UNCOLLECTED_FMT="%s（未收集）", LABEL_REWARD="奖励", LABEL_NOTE="备注", STATUS_ACTIVE="启用", TOOLTIP_ENTRANCE_COORDINATES_FMT="入口：%.2f, %.2f（地图 %d）", TOOLTIP_INSCRIPTION_COORDINATES_FMT="铭文：%.2f, %.2f（地图 %d）", TOOLTIP_ENTRANCE_INSCRIPTION_CLICK_INSTRUCTIONS="Shift点击设置入口；点击设置铭文位置。", LABEL_100_RENOWN_FMT="100 名望：%s", TOOLTIP_ACHIEVEMENT_CREDIT_FROM_FMT="成就计数来源：%s", NOTE_HARANDAR_TREASURE_REQUIREMENTS="部分宝藏需要额外步骤或物品才能开启。", NOTE_FORGOTTEN_MASK_LOCATION="位于格纳尔多岛的一面残破石墙上，在地下堡入口以南。", NOTE_HEAD_MASONS_TABLET_LOCATION="位于东牙之门内。入口：地图 2512 的 45.72, 64.94。", NOTE_PROFANED_PLAQUE_LOCATION="位于西牙之门内，进入后左手边的房间。入口：地图 2512 的 31.80, 64.91。", BUTTON_CANCEL="取消", BUTTON_SAVE="保存", BUTTON_SELECT_ALL="全选", LABEL_COMPLETED="已完成", LABEL_NOT_COMPLETED="未完成", LABEL_DETAILS="详情", LABEL_DETAIL="详细信息", LABEL_INFO="信息", LABEL_MAXIMUM="最大", LABEL_PREVIOUS="上一个", LABEL_RECENT_HISTORY="近期记录", LABEL_SOURCE="来源", LABEL_STATUS="状态", TIME_JUST_NOW="刚刚", TIME_YESTERDAY="昨天",
CALENDAR_MONTH_YEAR_FMT="%s %d年",
BUTTON_BACK_TO_GROUPS="返回分组", TEXT_COORDINATE_GROUPS_NOT_AVAILABLE="尚未添加坐标分组。", TEXT_ZONE_REWARD_NOT_AVAILABLE="尚未添加区域奖励。", TEXT_META_REWARD_NOT_AVAILABLE="尚未添加综合成就奖励。", TEXT_ACHIEVEMENT_REWARD_NOT_LISTED="未列出成就奖励。", TOOLTIP_RUNESTONE_CHARGE_INSTRUCTION="使用潜在奥术为符文石充能，以开始防御事件。", TEXT_COORDINATES_PENDING="坐标待补充。", TOOLTIP_CLICK_OPEN_TRACKER="点击打开此追踪器。", TEXT_TRACKER_NOT_AVAILABLE="尚未添加追踪器。",
MSG_PROFIT_GOAL_INVALID="请输入有效的金币数额。", MSG_PROFIT_GOAL_NOT_SET="未设置目标", TEXT_PROFIT_EXPORT_HINT="点击文本框并按 Ctrl+C 复制。", TEXT_PROFIT_EXPORT_SUBTITLE="复制下方的 CSV 文本。", TEXT_PROFIT_SOURCE_BLACK_MARKET="黑市", TEXT_PROFIT_SOURCE_CHEST="宝箱", TEXT_PROFIT_SOURCE_CRAFT="制造", TEXT_PROFIT_SOURCE_FLIGHT_PATH="飞行路线", TEXT_PROFIT_SOURCE_GUILD_BANK="公会银行", TEXT_PROFIT_SOURCE_LOOTED="拾取", TEXT_PROFIT_SOURCE_REPAIR="修理", TEXT_PROFIT_SOURCE_TRAINING="训练", TEXT_PROFIT_SOURCE_WORLD_QUEST="世界任务", MSG_RAID_RESYNC_COMPLETE="团队副本重新同步完成。", MSG_RAID_RESYNC_STARTED="团队副本重新同步已开始...", MSG_RAID_RESYNC_UNAVAILABLE="团队副本重新同步不可用。",
TEXT_PROFIT_FALLBACK_APPEARANCE_COST="外观费用", TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT="拍卖押金", TEXT_PROFIT_FALLBACK_AUCTION_FEE="拍卖手续费", TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE="拍卖购买", TEXT_PROFIT_FALLBACK_AUCTION_SALE="拍卖出售", TEXT_PROFIT_FALLBACK_BARBER_COST="理发费用", TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE="黑市购买", TEXT_PROFIT_FALLBACK_CRAFTING_ORDER="制造订单", TEXT_PROFIT_FALLBACK_GEAR_UPGRADE="装备升级", TEXT_PROFIT_FALLBACK_GOLD_RECEIVED="收到金币", TEXT_PROFIT_FALLBACK_GOLD_REWARD="金币奖励", TEXT_PROFIT_FALLBACK_GOLD_SENT="发送金币", TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT="公会存款", TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL="公会取款", TEXT_PROFIT_FALLBACK_RAW_GOLD="直接金币", TEXT_PROFIT_FALLBACK_SERVICE_COST="服务费用", TEXT_PROFIT_FALLBACK_TRADE_GAIN="交易收入", TEXT_PROFIT_FALLBACK_TRADE_PAYMENT="交易支出", TEXT_PROFIT_FALLBACK_TRAINING_COST="训练费用", TEXT_PROFIT_FALLBACK_TRAVEL_COST="旅行费用", TEXT_PROFIT_GRAPH_EMPTY_MONTHLY="尚未记录每月利润历史。", TEXT_PROFIT_GRAPH_EMPTY_WARBAND="尚未记录战团利润历史。", TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY="尚未记录每月战团利润历史。", TEXT_PROFIT_GRAPH_EMPTY_WEEKLY="尚未记录每周利润历史。", TEXT_PROFIT_LEDGER_EMPTY_MONTHLY="尚未记录每月账本交易。", TEXT_PROFIT_LEDGER_EMPTY_WARBAND="尚未记录战团账本交易。", TEXT_PROFIT_LEDGER_EMPTY_WEEKLY="尚未记录每周账本交易。", TEXT_PROFIT_SUBTITLE="已追踪角色的每周和每月利润。",
BUTTON_BREAKDOWN="明细", BUTTON_FILTER="筛选", BUTTON_SET="设置", BUTTON_RAIDS="团队副本", BUTTON_WARBAND_BANK_HISTORY="战团银行历史", TITLE_TREASURES_OF_THE_DAMNED="诅咒者的宝藏", TOOLTIP_TOKKA_TREASURE_HINT="在 Coiled Isle 钓起这件神器，并将其交还给 Tokka's Folly 的 Second Mate Sluggs。", WARNING_TOKKA_ONE_TIME_ARTIFACTS="警告：这些神器任务是战团一次性上交任务。它们不会每日或每周重置，且只能奖励一次声望。", MSG_RAID_HISTORY_PRESERVED="团队副本历史已保留；会清除数据的赛季重置已禁用。", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", TITLE_MINI_OMNIUM_FOLIO="奥秘宝典", TOOLTIP_HIDE_MINI_FOLIO="隐藏迷你宝典", TOOLTIP_LOCK_MINI_FOLIO="锁定迷你宝典", TOOLTIP_UNLOCK_MINI_FOLIO="解锁迷你宝典", TAB_GLYPHS="雕文", TITLE_GLYPH_HUNTER="雕文猎手", TOOLTIP_RUNESTONE_SET_WAYPOINT="点击设置路径点。", LABEL_CHARACTER_TIME="角色时间", LABEL_LAST_UPDATED="上次更新", LABEL_VAULT_OVERALL_PROGRESS="总进度：%d/%d", LABEL_VAULT_ROW_DUNGEONS="地下城", TITLE_CHARACTER_GREAT_VAULT_FMT="%s的宏伟宝库：%s", TITLE_CHARACTER_WEEKLY_PLANNER_FMT="%s的每周规划：%s", LABEL_NEXT_WEEK_FMT="下周：%s",
BUTTON_EDIT_MONTHLY_GOAL="编辑每月目标", BUTTON_EDIT_WEEKLY_GOAL="编辑每周目标", BUTTON_EXPORT_CSV="导出 CSV", BUTTON_MONTHLY_PROFIT_EXPORT="每月利润 CSV", BUTTON_WARBAND_PROFIT_BREAKDOWN="战团明细", BUTTON_WARBAND_PROFIT_EXPORT="战团每周利润 CSV", BUTTON_WEEKLY_PROFIT_EXPORT="每周利润 CSV", LABEL_GOAL_AMOUNT="目标金额（金币）", LABEL_GOLD="金币", LABEL_NET="净额", LABEL_SHARE="分享", LABEL_ZONE="区域", LABEL_WARBAND_WEEKLY_PROFIT="战团每周利润", MSG_NIT_TIMEPLAYED_WARNING="检测到 NovaInstanceTracker。即使 LiteVault 的选项已禁用，NIT 仍可能隐藏 /played 消息。", MSG_TIMEPLAYED_RESTORED="游戏时间消息已恢复。", MSG_TIMEPLAYED_SUPPRESSED="游戏时间消息将被隐藏。", MSG_WOW_TOKEN_API_UNAVAILABLE="此客户端无法使用魔兽世界时光徽章 API。", MSG_WOW_TOKEN_DATA_UNAVAILABLE="魔兽世界时光徽章数据不可用。", MSG_WOW_TOKEN_VISIT_AH="请访问拍卖行以更新魔兽世界时光徽章价格。", OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC="在日历上以绿色和红色标记盈利和亏损日期。",
TITLE_ACHIEVEMENTS="成就", LABEL_ACHIEVEMENT_GROUPS="分组", LABEL_GLOWING_MOTHS="飞蛾", LABEL_SHARED_LOOT="共享战利品", LABEL_KNOWLEDGE_CATCHUP="追赶", STATUS_ASSAULT_WAVE_1_COMPLETE="第1波完成", STATUS_ASSAULT_WAVE_2_COMPLETE="第2波完成", STATUS_ASSAULT_WAVE_3_COMPLETE="第3波完成", TEXT_MIDNIGHT_RARES_TRACKER_DESCRIPTION="追踪 Midnight 稀有成就、奖励和共享掉落。", TEXT_MIDNIGHT_TREASURES_TRACKER_DESCRIPTION="追踪 Midnight 宝藏成就及其奖励。", TEXT_HARANIR_JOURNAL_INSTRUCTION="找回下方列出的 Haranir 日志条目。", TEXT_HARANIR_LEGEND_DEFENSE_INSTRUCTION="保卫下方列出的每个 Haranir 传说地点。", TEXT_BLESSING_EFFECT_INSTRUCTION="触发列出的每种祝福效果以获得计数。", TOOLTIP_CAVE_RUN_CREDIT_INSTRUCTION="完成此处的洞穴挑战以获得计数。", TEXT_TELESCOPE_ZONE_REQUIREMENT="完成此区域的五个望远镜目标。",
TEXT_MIDNIGHT_DELVER_META_INSTRUCTION="完成四项 Midnight 地下堡辅助成就以完成此综合成就。", TEXT_COILED_ISLE_META_INSTRUCTION="完成 Coiled Isle 成就。", TEXT_MIDNIGHT_ZONE_META_REWARD_REQUIREMENT="完成四项 Midnight 区域综合成就并获得坐骑奖励。", TEXT_CLAW_ENFORCEMENT_REQUIREMENT="在拥有至少15层 Predator's Pursuit 时完成 Harandar 世界任务“Claw Enforcement”。", TEXT_ATALUTEK_META_INSTRUCTION="完成 Vaults of Atal'Utek 成就。", TEXT_COILED_ISLE_LORE_INSTRUCTION="发现 Coiled Isle 的传说物件。", TEXT_HUNGERING_PRESENCE_REQUIREMENT="在 Voidstorm 躲避 Hungering Presence 的抓捕至少60秒。", TEXT_CRADLE_FLIGHT_REQUIREMENT="飞入 Harandar 高空中的 The Cradle 以完成此成就。", TEXT_EVERSONG_META_TRACKER_DESCRIPTION="追踪 Eversong Woods 综合成就并进入其子追踪器。", TEXT_MIDNIGHT_PEAKS_TRACKER_DESCRIPTION="追踪 Midnight, the Highest Peaks 的四项区域成就。", TEXT_HARANDAR_META_TRACKER_DESCRIPTION="追踪 Harandar 综合成就并进入其子追踪器。", TEXT_VOIDSTORM_META_TRACKER_DESCRIPTION="追踪 Voidstorm 综合成就并进入其子追踪器。", TEXT_ZULAMAN_META_TRACKER_DESCRIPTION="追踪 Zul'Aman 综合成就并进入其子追踪器。", TEXT_CRADLE_FLIGHT_ATTEMPT="尝试飞向 Harandar 高空中的 The Cradle。", NOTE_MOTH_ROUTE_RENOWN_REQUIREMENT="LiteVault 路线假定你已解锁 Hara'ti Renown 11。",
TEXT_HARATI_META_PROGRESS_INSTRUCTION="完成下方成就以协助 Hara'ti。已完成 x/y。", TEXT_VOIDSTORM_META_PROGRESS_INSTRUCTION="完成下方列出的所有 Voidstorm 成就。已完成 x/y。", TEXT_ZULAMAN_META_PROGRESS_INSTRUCTION="完成下方列出的所有 Zul'Aman 成就。已完成 x/y。", TEXT_STORMARION_ASSAULT_PROGRESS_INSTRUCTION="完成 Stormarion Assault 的全部三波。已标记 x/y。", TEXT_ABUNDANT_HARVEST_PROGRESS_INSTRUCTION="在每个地点完成一次 Abundant Harvest 洞穴挑战。已标记 x/y。", TEXT_EVERSONG_META_PROGRESS_INSTRUCTION="完成下方列出的 Eversong Woods 成就。已完成 x/y。", TEXT_GLOWING_MOTH_PROGRESS="找出藏在 Harandar 的所有 Glowing Moths。已找到 x/y。", TEXT_HARANIR_LEGEND_PROGRESS="保护下方列出的每个 Haranir 传说地点。已标记 x/y。", TEXT_XALATATH_META_PROGRESS="完成下方成就以集结力量对抗 Xal'atath。已完成 x/y。", TEXT_HARANIR_JOURNAL_PROGRESS="找回下方列出的 Haranir 日志条目。已标记 x/y。", TEXT_BLESSING_EFFECT_PROGRESS="触发列出的每种祝福效果。已标记 x/y。", TEXT_FACTION_INVITE_PROGRESS="追踪 The Party Must Go On 的四份阵营邀请。已标记 x/y。", TEXT_EVER_PAINTING_PROGRESS="追踪已知的 Ever-Painting 画布。已标记 x/y。", TEXT_RUNESTONE_RUSH_PROGRESS="追踪已知的 Runestone Rush 条目。已标记 x/y。",
TEXT_DELVER_MOUNT_REWARD_REQUIREMENT="完成 Glory of the Midnight Delver 以获得此坐骑。", NOTE_MOTH_GROUP_1_RENOWN="飞蛾1–40在 Hara'ti Renown 1出现，并在 Renown 2解锁追踪。", NOTE_MOTH_GROUP_2_RENOWN="飞蛾41–80在 Hara'ti Renown 4出现，并在 Renown 6解锁追踪。", NOTE_MOTH_GROUP_3_RENOWN="飞蛾81–120在 Hara'ti Renown 9出现，并在 Renown 11解锁追踪。", NOTE_HARANIR_JOURNAL_AVAILABILITY="这些日志仅在账号通用每周任务“Legends of the Haranir”期间可用。进入幻象后，请留意小地图上的放大镜图标。", NOTE_CLAW_ENFORCEMENT_NO_COORDINATES="此成就无需 LiteVault 坐标追踪。在拥有至少15层 Predator's Pursuit 时完成 Harandar 世界任务“Claw Enforcement”。", NOTE_HUNGERING_PRESENCE_NO_COORDINATES="此成就无需 LiteVault 坐标追踪。在 Voidstorm 的 Hungering Presence 事件中存活至少60秒。", NOTE_HARANIR_LEGENDS_WEEKLY_ESTIMATE="此内容与账号通用每周任务“Legends of the Haranir”相关。如果尚无进度，预计约需7周完成。", NOTE_MOTH_TRACKER_GROUPING="此追踪器分为3组，每组40个坐标，以便管理飞蛾路线。", TEXT_EVER_PAINTING_TRACKER_PLACEHOLDER="追踪 Ever-Painting 进度。条目详情可稍后补充。", TEXT_EXPLORE_EVERSONG_TRACKER_PLACEHOLDER="追踪 Explore Eversong Woods 进度。条目详情可稍后补充。", TEXT_RUNESTONE_RUSH_TRACKER_PLACEHOLDER="追踪 Runestone Rush 进度。条目详情可稍后补充。", TEXT_PARTY_TRACKER_PLACEHOLDER="追踪 The Party Must Go On 进度。条目详情可稍后补充。", TOOLTIP_ABUNDANT_HARVEST_CREDIT_REQUIREMENT="你需要在每个地点完成一次 Abundant Harvest 洞穴挑战。仅仅到访洞穴并不足够。",
TEXT_EXPLORE_EVERSONG_PROGRESS="追踪 Explore Eversong Woods 进度。已标记 x/y。", TEXT_EXPLORE_HARANDAR_PROGRESS="追踪 Explore Harandar 进度。已标记 x/y。", TEXT_EXPLORE_VOIDSTORM_PROGRESS="追踪 Explore Voidstorm 进度。已标记 x/y。", TEXT_EXPLORE_ZULAMAN_PROGRESS="追踪 Explore Zul'Aman 进度。已标记 x/y。",
}
for key,value in pairs(phase2) do L[key]=value end
lv.RegisterLocale("zhCN", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["zhCN"] = L






