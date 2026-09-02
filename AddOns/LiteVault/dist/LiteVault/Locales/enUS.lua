-- enUS.lua - English (US) locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",

    -- ==========================================================================
    -- COMMON UI ELEMENTS
    -- ==========================================================================
    BUTTON_CLOSE = "Close",
    BUTTON_YES = "Yes",
    BUTTON_NO = "No",
    BUTTON_MANAGE = "Manage",
    BUTTON_BACK = "Back",
    BUTTON_ALL = "All",
    BUTTON_NONE = "None",
    BUTTON_FILTER = "Filter",
    BUTTON_BREAKDOWN = "Breakdown",
    BUTTON_WARBAND_PROFIT_BREAKDOWN = "Warband Breakdown",
    DIALOG_DELETE_CHAR = "Delete %s from LiteVault?",
    LABEL_MYTHIC_PLUS = "M+",
    TELEPORT_PANEL_TITLE = "M+ Teleports",
    TELEPORT_CAST_BTN = "Teleport",
    TELEPORT_ERR_COMBAT = "Cannot teleport during combat.",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "Map Filters",

    BUTTON_RAID_LOCKOUTS = "Raid Lockouts",
    BUTTON_WORLD_EVENTS = "World Events",
    BUTTON_VAULT = "Vault",
    BUTTON_ACTIONS = "Actions",
    BUTTON_RAIDS = "Raids",
    BUTTON_FAVORITE = "Favorite",
    BUTTON_UNFAVORITE = "Unfavorite",
    BUTTON_IGNORE = "Ignore",
    BUTTON_RESTORE = "Restore",
    BUTTON_DELETE = "Delete",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "Raid Lockouts",
    TOOLTIP_RAID_LOCKOUTS_DESC = "View raid lockouts and progression",
    TOOLTIP_ACTIONS_TITLE = "Character Actions",
    TOOLTIP_ACTIONS_DESC = "Open action menu",
    TOOLTIP_THEME_TITLE = "Toggle Theme",
    TOOLTIP_THEME_DESC = "Switch between Dark and Light mode",
    TOOLTIP_FILTER_TITLE = "Map Filter",
    TOOLTIP_FILTER_DESC = "Click to view full list",
    TOOLTIP_WORLD_EVENTS_TITLE = "World Events",
    TOOLTIP_WORLD_EVENTS_DESC = "See world events",
    BUTTON_INSTANCES = "Instances",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Instance Tracker",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Track dungeon and raid runs",

    -- Sort controls
    LABEL_SORT_BY = "Sort by:",
    SORT_GOLD = "Gold",
    SORT_ILVL = "iLvl",
    SORT_MPLUS = "M+ Score",
    SORT_LAST_ACTIVE = "Last Active",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "%s's Weekly Quests",
    BUTTON_WEEKLIES = "Weeklies",
    BUTTON_EVENTS = "Events",
    BUTTON_FACTIONS = "Factions",
    BUTTON_FACTION_WEEKLIES = "Faction Weeklies",
    BUTTON_AMANI_TRIBE = "Amani Tribe",
    BUTTON_HARATI = "Hara'ti",
    BUTTON_SINGULARITY = "The Singularity",
    BUTTON_SILVERMOON_COURT = "Silvermoon Court",
    BUTTON_RITUAL_SITES = "Ritual Sites",
    BUTTON_ZULJARRA_FORCES = "Zul'jarra's Forces",
    BUTTON_CAPTAIN_TOKKA = "Captain Tokka",
    LABEL_VALEERA_SANGUINAR = "Valeera Sanguinar",
    LABEL_SLAYERS_DUELLUM = "Slayer's Duellum",
    LABEL_MAXIMUM = "Maximum",
    TITLE_TREASURES_OF_THE_DAMNED = "Treasures of the Damned",
    LABEL_COMPLETED = "Completed",
    LABEL_NOT_COMPLETED = "Not Completed",
    LABEL_QUEST_FMT = "Quest: %s",
    LABEL_QUEST_ID_FMT = "Quest ID: %d",
    TOOLTIP_TOKKA_TREASURE_HINT = "Fish this artifact up on the Coiled Isle and return it to Second Mate Sluggs at Tokka's Folly.",
    WARNING_TOKKA_ONE_TIME_ARTIFACTS = "Warning: These artifact quests are one-time Warband turn-ins. They do not reset daily or weekly and can only reward reputation once.",
    TITLE_FACTION_WEEKLIES = "%s's Faction Weeklies",
    LABEL_RENOWN_PROGRESS = "Renown %d (%d/%d)",
    LABEL_RENOWN = "Renown",
    LABEL_RENOWN_LEVEL = "Level",
    LABEL_RENOWN_UNAVAILABLE = "Renown unavailable",
    LABEL_MAX_RENOWN = "Maximum Renown",
    LABEL_PARAGON = "Paragon",
    LABEL_REWARD_FMT = "Reward: %s",
    LABEL_REWARD_LOADING = "Reward data loading...",
    TOOLTIP_FACTION_CARD_HINT = "Click to switch this faction.",
    WARNING_EVENT_QUESTS = "Some of these events are bugged or locked in game.",
    WARNING_WEEKLY_HARATI_CHOICE = "Warning! Once you choose a Legends of the Haranir quest, it's locked to your account.",
    WARNING_WEEKLY_RUNESTONES = "Warning! Choose the Runestone quest wisely. Once you pick one for the week, that choice is locked for your account.",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "No faction quests configured yet.",
    LABEL_WEEKLY_PROFIT = "Weekly Profit:",
    LABEL_WARBAND_PROFIT = "Warband Profit:",
    LABEL_WARBAND_BANK = "Warband Bank:",
    LABEL_FIRST_KILL = "First kill:",
    LABEL_EARLIEST_RECORDED_KILL = "Earliest recorded kill:",
    TEXT_HISTORICAL_DATA_UNAVAILABLE = "Historical data unavailable",
    LABEL_KNOWN_KILLS = "Known kills:",
    LABEL_ALSO_KILLED_BY = "Also killed by:",
    TEXT_KILL_DATE_UNAVAILABLE = "Kill date unavailable",
    LABEL_WOW_TOKEN = "WoW Token:",
    LABEL_LAST_UPDATED = "Last Updated",
    LABEL_TOKEN_DELTA = "Delta",
    LABEL_TOKEN_AFFORDABLE = "Affordable",
    LABEL_TOKEN_NOT_AFFORDABLE = "Cannot Afford",
    LABEL_TOKEN_STALE = "Stale",
    LABEL_GAINED = "Gained",
    LABEL_TOP_EARNERS = "Top Earners (Weekly):",
    LABEL_TOP_SOURCES = "Top Sources",
    LABEL_TOP_INCOME_SOURCE = "Top Income Source",
    LABEL_TOP_EXPENSE_SOURCE = "Top Expense Source",
    LABEL_TOTAL_GOLD = "Total Gold: %s",
    LABEL_TOTAL_TIME = "Total Time: %s",
    LABEL_COMBINED_TIME = "Combined Time: %dd %dh",

    TOOLTIP_TOTAL_TIME_TITLE = "Total Time",
    TOOLTIP_TOTAL_TIME_DESC = "Total time played across all tracked characters.",
    TOOLTIP_TOTAL_TIME_CLICK = "Click to cycle format.",
    TOOLTIP_WOW_TOKEN_TITLE = "WoW Token",
    TOOLTIP_WOW_TOKEN_DESC = "Last known WoW Token market price.",
    MSG_WOW_TOKEN_VISIT_AH_SHORT = "Visit AH",
    MSG_WOW_TOKEN_VISIT_AH = "Visit the Auction House to update WoW Token price.",

    -- Quest status
    STATUS_DONE = "[Done]",
    STATUS_IN_PROGRESS = "[In-Progress]",
    STATUS_NOT_STARTED = "[Not Started]",
    TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE = "Source mix across your warband's weekly income and spending.",
    TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS = "Where your warband made the most gold this week.",
    TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND = "Where your warband spent the most gold this week.",
    MSG_PROFIT_NO_INCOME = "No income recorded yet.",
    MSG_PROFIT_NO_SPENDING = "No spending recorded yet.",
    MSG_NO_GOLD_WORLD_QUESTS = "No active gold world quests found.",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Manage Characters",
    TOOLTIP_MANAGE_BACK = "Go back to main tab.",
    TOOLTIP_MANAGE_VIEW = "See ignored characters.",

    TOOLTIP_CATALYST_TITLE = "Catalyst Charges",
    TOOLTIP_SPARKS_TITLE = "Crafting Sparks",
    TOOLTIP_VOIDSHARDS_TITLE = "Ascendant Voidshards",
    TOOLTIP_VOIDCORES_TITLE = "Ascendant Voidcores",

    TOOLTIP_VAULT_TITLE = "Great Vault",
    TOOLTIP_VAULT_DESC = "Press to open the great vault",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Open the Great Vault.",
    TOOLTIP_VAULT_ALT_ONLY = "Great Vault can only be opened for the active character.",

    TOOLTIP_CURRENCY_TITLE = "Character Currencies",
    TOOLTIP_CURRENCY_DESC = "Click to view full list.",

    TOOLTIP_BAGS_TITLE = "View Bags",
    TOOLTIP_BAGS_DESC = "View saved bag contents and reagent bag items for this character.",

    TOOLTIP_LEDGER_DESC = "Track gold income and expenses by source.",

    TOOLTIP_WARBAND_BANK_TITLE = "Warband Bank Ledger",
    TOOLTIP_WARBAND_BANK_DESC = "Click to view warband bank transactions.",

    TOOLTIP_RESTORE_TITLE = "Restore",
    TOOLTIP_RESTORE_DESC = "Restore this character to the main page",

    TOOLTIP_IGNORE_TITLE = "Ignore",
    TOOLTIP_IGNORE_DESC = "Remove this character from the main page",

    TOOLTIP_DELETE_TITLE = "Delete",
    TOOLTIP_DELETE_DESC = "Permanently delete this character's data",
    TOOLTIP_DELETE_WARNING = "Warning: This cannot be undone!",

    TOOLTIP_FAVORITE_TITLE = "Favorite",
    TOOLTIP_FAVORITE_DESC = "Pin this character to the top of the list",

    -- Character data displays
    LABEL_ILVL = "iLvl: %d",
    LABEL_MPLUS_SCORE = "M+ Score: %d",
    LABEL_NO_KEY = "No M+ Key",
    LABEL_NO_PROFESSIONS = "No Professions",
    LABEL_UNKNOWN = "Unknown",
    LABEL_SKILL_LEVEL = "Skill: %d/%d",
    LABEL_CONCENTRATION = "Concentration: %d/%d",
    LABEL_CONC_DAILY_RESET = "Daily: %dh %dm",
    LABEL_CONC_WEEKLY_RESET = "Full reset: %dd %dh",
    LABEL_CONC_FULL = "(Full)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d Knowledge Available",
    LABEL_NO_KNOWLEDGE = "No Knowledge Available",
    LABEL_VAULT_PROGRESS = "R: %d/3    M+: %d/3    W: %d/3",
    BUTTON_PROFS = "Skills",

    TOOLTIP_PROFS_TITLE = "Professions",
    TOOLTIP_PROFS_DESC = "See concentration and knowledge points.",
    BUTTON_KNOWLEDGE = "Knowledge",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "Sun",
    DAY_MON = "Mon",
    DAY_TUE = "Tue",
    DAY_WED = "Wed",
    DAY_THU = "Thu",
    DAY_FRI = "Fri",
    DAY_SAT = "Sat",

    TOOLTIP_ACTIVITY_FOR = "Activity for %d/%d/%d",
    MSG_NO_WORLD_EVENTS = "No world events this month",
    -- Filter categories
    FILTER_TIMEWALKING = "Timewalking",
    FILTER_DARKMOON = "Darkmoon",
    FILTER_DUNGEONS = "Dungeons",
    FILTER_PVP = "PvP",
    FILTER_BONUS = "Bonus",

    -- World events
    WORLD_EVENT_LOVE = "Love is in the Air",
    WORLD_EVENT_LUNAR = "Lunar Festival",
    WORLD_EVENT_NOBLEGARDEN = "Noblegarden",
    WORLD_EVENT_CHILDREN = "Children's Week",
    WORLD_EVENT_MIDSUMMER = "Midsummer Fire Festival",
    WORLD_EVENT_BREWFEST = "Brewfest",
    WORLD_EVENT_HALLOWS = "Hallow's End",
    WORLD_EVENT_WINTERVEIL = "Feast of Winter Veil",
    WORLD_EVENT_DEAD = "Day of the Dead",
    WORLD_EVENT_PIRATES = "Pirates' Day",
    WORLD_EVENT_STYLE = "Trial of Style",
    WORLD_EVENT_OUTLAND = "Outland Cup",
    WORLD_EVENT_NORTHREND = "Northrend Cup",
    WORLD_EVENT_KALIMDOR = "Kalimdor Cup",
    WORLD_EVENT_EASTERN = "Eastern Kingdoms Cup",
    WORLD_EVENT_WINDS = "Winds of Mysterious Fortune",
    WORLD_EVENT_SALTHERIL = "Saltheril's Soiree",
    WORLD_EVENT_ABUNDANCE = "Abundance",
    WORLD_EVENT_HARANIR = "Legends of the Haranir",
    WORLD_EVENT_STORMARION = "Stormarion Assault",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "%s's Currencies",

    -- ==========================================================================
    -- PROFESSION WINDOW
    -- ==========================================================================
    TITLE_PROFESSIONS = "%s's Professions",
    TITLE_KNOWLEDGE_TRACKER = "Knowledge Tracker",
    TOOLTIP_KNOWLEDGE_DESC = "View spent, unspent, and max knowledge",
    LABEL_SPENT = "Spent",
    LABEL_UNSPENT = "Unspent",
    LABEL_MAX = "Max",
    LABEL_EARNED = "Earned",
    LABEL_TREATISE = "Treatise",
    LABEL_ARTISAN_QUEST = "Artisan",
    LABEL_CATCHUP = "Catch-up",
    LABEL_WEEKLY = "Weekly",
    LABEL_UNLOCKED = "Unlocked",
    LABEL_UNLOCK_REQUIREMENTS = "Unlock Requirements",
    LABEL_SOURCE_NOTE = "Weekly sources and catch-up snapshot",
    TITLE_KNOWLEDGE_SOURCES = "Knowledge Sources",
    TAB_TREASURES = "Treasures",
    LABEL_UNIQUE_TREASURES = "Unique Treasures",
    LABEL_WEEKLY_TREASURES = "Weekly Treasures",
    LABEL_HOVER_TREASURE_CHECKLIST = "Hover for treasure checklist",
    LABEL_TREASURE_CLICK_HINT = "Click a unique treasure to set a waypoint",
    LABEL_ZONE = "Zone",
    LABEL_QUEST = "Quest",
    LABEL_COORDINATES = "Coordinates",

    TOOLTIP_TREASURE_SET_WAYPOINT = "Click to place a TomTom waypoint",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "Click to place a map waypoint",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "No fixed location for this treasure",
    MSG_TREASURE_NO_WAYPOINT = "No fixed waypoint for this treasure.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom not detected.",
    MSG_TREASURE_WAYPOINT_SET = "Waypoint set: %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "Map waypoint set: %s (%.1f, %.1f)",
    TITLE_PROF_TREASURES_FMT = "%s Treasures",
    LABEL_PROFESSION = "Profession",
    LABEL_UNIQUE_TREASURE_FMT = "%s Unique Treasure %d",
    LABEL_WEEKLY_TREASURE_FMT = "%s Weekly Treasure %d",
    STATUS_DONE_WORD = "Done",
    STATUS_MISSING_WORD = "Missing",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_FORMAT = "%s's %s %s - Manaforge Omega",

    DIFFICULTY_LFR = "LFR",
    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Heroic",
    DIFFICULTY_MYTHIC = "Mythic",

    MSG_NO_CHAR_DATA = "No character data found",
    MSG_NO_PROGRESSION = "No %s progression recorded",
    MSG_NO_LOCKOUT = "No %s lockout this week",

    LABEL_BOSS = "Boss %d",
    LABEL_CHARACTER = "Character",
    LABEL_PROGRESS_COUNT = "%d/8",
    LABEL_MIDNIGHT_SEASON_1 = "Season 1 of Midnight",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "Warband Bank Ledger",
    LABEL_CURRENT_BALANCE = "Current Balance:",
    LABEL_RECENT_TRANSACTIONS = "Recent Transactions:",
    MSG_NO_TRANSACTIONS = "(No transactions recorded yet)",
    TIP_RELOAD_SAVE = "Tip: /reload before switching characters to save data",
    ACTION_DEPOSITED = "deposited",
    ACTION_WITHDREW = "withdrew",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    LABEL_RESETS_IN = "Resets in %dd %dh",

    TAB_SUMMARY = "Summary",
    TAB_SOURCES = "Sources",
    TAB_HISTORY = "History",
    TAB_WARBAND = "Warband",
    HEADER_SOURCE = "Source",
    HEADER_INCOME = "Income",
    HEADER_EXPENSE = "Expense",

    LABEL_TOTAL = "Total",
    LABEL_NET_PROFIT = "Net Profit",
    MSG_NO_GOLD_ACTIVITY = "No gold activity this week",
    MSG_NO_TRANSACTIONS_WEEK = "No transactions this week",

    -- Ledger source categories
    LEDGER_QUESTS = "Quests",
    LEDGER_WORLD_QUESTS = "World Quests",
    LEDGER_AUCTION = "Auction House",
    LEDGER_TRADE = "Trade",
    LEDGER_VENDOR = "Vendor",
    LEDGER_UPGRADE = "Upgrade",
    LEDGER_REPAIRS = "Repairs",
    LEDGER_TRANSMOG = "Transmog",
    LEDGER_FLIGHT = "Flight Paths",
    LEDGER_CRAFTING = "Crafting",
    LEDGER_CACHE = "Cache/Trove",
    LEDGER_MAIL = "Mail",
    LEDGER_LOOT = "Loot",
    LEDGER_WARBAND_BANK = "Warband Bank",
    LEDGER_OTHER = "Other",

    -- Time formats
    TIME_TODAY = "Today %H:%M",

    -- ==========================================================================
    -- FRESHNESS INDICATORS (Utils.lua)
    -- ==========================================================================
    FRESH_NEVER = "Never",
    FRESH_TODAY = "Active Today",
    FRESH_1_DAY = "1 day ago",
    FRESH_DAYS = "%d days ago",

    -- Time format styles
    TIME_YEARS_DAYS = "%dy %dd",
    TIME_DAYS_HOURS = "%dd %dh",
    TIME_DAYS = "%s Days",
    TIME_HOURS = "%s Hours",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "Greetings %s,\nwould you like LiteVault to track this character?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "Weekly reset detected! Raid lockouts cleared.",
    MSG_ALREADY_TRACKED = "This character is already being tracked.",
    MSG_CHAR_ADDED = "%s has been added to tracking.",
    MSG_RAID_RESET_SEASON = "Raid progression has been reset for Midnight Season 1!",
    MSG_CLEARED_PROGRESSION = "Cleared progression data for %d characters.",
    MSG_WEEKLY_PROFIT_RESET = "Weekly profit tracking reset for %d characters.",
    MSG_WARBAND_BALANCE = "Warband: %s",
    MSG_WARBAND_BANK_BALANCE = "Warband Bank: %s",
    MSG_WEEKLY_DATA_RESET = "Weekly data reset for %d characters.",
    MSG_RAID_MANUAL_RESET = "Raid progression manually reset!",
    MSG_CLEARED_DATA = "Cleared data for %d characters.",
    MSG_CAP_WARNING = "Instance cap warning! %d/10 instances this hour.",
    MSG_CAP_SLOT_OPEN = "An instance slot is now open! (%d/10 used)",

    -- Prompt to reload when time-played suppression setting changes
    MSG_RELOAD_TIMEPLAYED = "Reload the UI for time-played suppression to take effect.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "Blizzard initial time played message cannot be suppressed.",

    -- Slash command help
    HELP_RESET_TITLE = "LiteVault Reset Commands",
    HELP_REGION = "Region: %s (resets %s)",
    HELP_LAST_SEASON = "Last season reset: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - Reset weekly profit tracking",
    HELP_RESET_SEASON = "/lvreset season - Reset raid progression (new tier)",
    HELP_NEVER = "Never",

    -- Raid debug
    MSG_RAID_DEBUG_ON = "LiteVault raid debug: ON",
    MSG_RAID_DEBUG_OFF = "LiteVault raid debug: OFF",
    MSG_RAID_DEBUG_TIP = "Use /lvraiddbg again to turn off debug output",
    MSG_TRACKED_KILL = "Tracked %s kill: %s (%s)",

    -- ==========================================================================
    -- LOCALE DEBUG (Localization.lua)
    -- ==========================================================================
    LOCALE_DEBUG_ON = "Locale debug mode ON - Showing string keys",
    LOCALE_DEBUG_OFF = "Locale debug mode OFF - Showing translations",
    LOCALE_BORDERS_ON = "Border mode ON - Showing text boundaries",
    LOCALE_BORDERS_HINT = "Green = fits, Red = may overflow",
    LOCALE_BORDERS_OFF = "Border mode OFF",
    LOCALE_FORCED = "Locale forced to %s",
    LOCALE_RESET_TIP = "Use /lvlocale reset to return to auto-detect",
    LOCALE_INVALID = "Invalid locale. Valid options:",
    LOCALE_RESET = "Locale reset to auto-detect: %s",

    LOCALE_TITLE = "LiteVault Localization",
    LOCALE_DETECTED = "Detected locale: %s",
    LOCALE_FORCED_TO = "Forced locale: %s",
    LOCALE_DEBUG_KEYS = "Debug keys:",
    LOCALE_DEBUG_BORDERS = "Debug borders:",
    LOCALE_ON = "ON",
    LOCALE_OFF = "OFF",
    LOCALE_COMMANDS = "Commands:",
    LOCALE_CMD_DEBUG = "/lvlocale debug - Toggle key display mode",
    LOCALE_CMD_BORDERS = "/lvlocale borders - Toggle text border visualization",
    LOCALE_CMD_LANG = "/lvlocale lang XX - Force locale (e.g., deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - Reset to auto-detect",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "Lang",
    TOOLTIP_LANGUAGE_TITLE = "Language",
    TOOLTIP_LANGUAGE_DESC = "Change the interface language",
    TITLE_LANGUAGE_SELECT = "Select Language",
    LANG_AUTO = "Auto (detect)",
    MSG_LANGUAGE_CHANGED = "Language changed. Reload UI to apply all changes.",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "Options",
    TOOLTIP_OPTIONS_TITLE = "Options",
    TOOLTIP_OPTIONS_DESC = "Configure LiteVault settings",
    TITLE_OPTIONS = "LiteVault Options",
    OPTION_DISABLE_TIMEPLAYED = "Disable Time Played Tracking",
    OPTION_DISABLE_TIMEPLAYED_DESC = "Prevents /played messages from appearing in chat",
    OPTION_ENABLE_24HR_CLOCK = "Enable 24hr Clock",
    OPTION_ENABLE_24HR_CLOCK_DESC = "Swap between 24hr and 12hr",
    OPTION_DISABLE_BAG_VIEWING = "Disable Bag/Bank Viewer",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Hide the Bags button and disable saved bag, bank, and warband bank viewing.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Disable Overlay System",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Hide LiteVault's item level and lock overlays on character and inspect gear.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "Disable M+ Teleports",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Hide the M+ teleport badge and disable LiteVault's teleport panel.",
    OPTION_DISABLE_RUNESTONE_MAP_PINS = "Disable Runestone Map Pins",
    OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC = "Hide LiteVault's Fortify the Runestones pins on the Eversong Woods map.",
    OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS = "Enable Calendar Profit Highlights",
    OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC = "Show green and red profit-day highlights on the calendar.",
    -- Instance Tracker
    TITLE_INSTANCE_TRACKER = "Instance Tracker",
    SECTION_INSTANCE_CAP = "Instance Cap (10/hour)",
    LABEL_CAP_CURRENT = "Current: %d/10",
    LABEL_CAP_STATUS = "Status: %s",
    LABEL_NEXT_SLOT = "Next slot in: %s",
    STATUS_SAFE = "SAFE",
    STATUS_WARNING = "WARNING",
    STATUS_LOCKED = "LOCKED",
    SECTION_CURRENT_RUN = "Current Run",
    LABEL_DURATION = "Duration: %s",
    LABEL_NOT_IN_INSTANCE = "Not in an instance",
    SECTION_PERFORMANCE = "Performance Today",
    LABEL_DUNGEONS_TODAY = "Dungeons: %d",
    LABEL_RAIDS_TODAY = "Raids: %d",
    LABEL_AVG_TIME = "Avg: %s",
    SECTION_LEGACY_RAIDS = "Legacy Raids This Week",
    LABEL_LEGACY_RUNS = "Runs: %d",
    LABEL_GOLD_EARNED = "Gold: %s",
    SECTION_RECENT_RUNS = "Recent Runs",
    LABEL_NO_RECENT_RUNS = "No recent runs",
    SECTION_MPLUS = "Mythic+",
    LABEL_MPLUS_CURRENT_KEY = "Current Key:",
    LABEL_RUNS_TODAY = "Runs Today: %d",
    LABEL_RUNS_THIS_WEEK = "Runs This Week: %d",
    SECTION_RECENT_MPLUS_RUNS = "Recent M+ Runs",
    LABEL_NO_RECENT_MPLUS_RUNS = "No recent M+ runs",

    -- ==========================================================================
    -- ACHIEVEMENT TRACKER
    -- ==========================================================================
    BUTTON_DASHBOARD = "Dashboard",
    BUTTON_PROFIT = "Profit",
    LABEL_PROFIT_GOALS = "Warband Goals",
    LABEL_WEEKLY_GOAL = "Weekly Goal",
    LABEL_MONTHLY_GOAL = "Monthly Goal",
    BUTTON_EDIT = "Edit",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "Highest net profit this reset.",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "Best net profit across the current month.",
    BUTTON_ACHIEVEMENTS = "Achievements",
    TITLE_ACHIEVEMENTS = "Achievements",
    DESC_ACHIEVEMENTS = "Choose an achievement tracker to view detailed progress.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "Midnight Glyph Hunter",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "Midnight Glyph Hunter",
    LABEL_REWARD = "Reward",
    DESC_GLYPH_REWARD = "Complete Midnight Glyph Hunter to earn this mount.",
    MSG_NO_ACHIEVEMENT_DATA = "No achievement tracking data is available.",
    LABEL_CRITERIA = "Criteria",
    LABEL_GLYPHS_COLLECTED = "Glyphs Collected",
    LABEL_ACHIEVEMENT = "Achievement",

    -- ==========================================================================
    -- BAG PANEL
    -- ==========================================================================
    BUTTON_BAGS = "Bags",
    BUTTON_BANK = "Bank",
    BUTTON_WARBAND_BANK = "Warband Bank",
    BAGS_EMPTY_STATE = "No saved bag items for this character yet.",
    BANK_EMPTY_STATE = "No saved bank items for this character yet.",
    WARBANK_EMPTY_STATE = "No saved warband bank items yet.",
    LABEL_BAG_SLOTS = "Slots: %d / %d used",
    LABEL_SCANNED = "scanned",

    -- Month names
    MONTH_1 = "January",
    MONTH_2 = "February",
    MONTH_3 = "March",
    MONTH_4 = "April",
    MONTH_5 = "May",
    MONTH_6 = "June",
    MONTH_7 = "July",
    MONTH_8 = "August",
    MONTH_9 = "September",
    MONTH_10 = "October",
    MONTH_11 = "November",
    MONTH_12 = "December",

    -- ==========================================================================
    -- Midnight Weekly Quests
    ["Community Engagement"] = "Community Engagement",
    ["Void Strike"] = "Void Strike",
    ["Void Assaults"] = "Void Assaults",
    ["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods",
    ["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman",
    LABEL_NEXT_WEEK_FMT = "Next Week: %s",
    ["Midnight: Prey"] = "Midnight: Prey",
    ["Saltheril's Soiree"] = "Saltheril's Soiree",
    ["Abundance Event"] = "Abundance Event",
    ["Legends of the Haranir"] = "Legends of the Haranir",
    ["Stormarion Assault"] = "Stormarion Assault",
    ["Darkness Unmade"] = "Darkness Unmade",
    ["Turn Back the Surge"] = "Turn Back the Surge",
    ["Purging the Vaults"] = "Purging the Vaults",
    ["Harvesting the Void"] = "Harvesting the Void",

    -- PROFESSION NAMES (for locale override)
    -- ==========================================================================
    ["Alchemy"] = "Alchemy",
    ["Blacksmithing"] = "Blacksmithing",
    ["Enchanting"] = "Enchanting",
    ["Engineering"] = "Engineering",
    ["Inscription"] = "Inscription",
    ["Jewelcrafting"] = "Jewelcrafting",
    ["Leatherworking"] = "Leatherworking",
    ["Tailoring"] = "Tailoring",
    ["Herbalism"] = "Herbalism",
    ["Mining"] = "Mining",
    ["Skinning"] = "Skinning",
    ["Remnant of Anguish"] = "Remnant of Anguish",
    ["Brimming Arcana"] = "Brimming Arcana",
    ["Voidlight Marl"] = "Voidlight Marl",
    ["Undercoin"] = "Undercoin",
    ["Coffer Key Shards"] = "Coffer Key Shards",
    ["Shard of Dundun"] = "Shard of Dundun",
    ["Adventurer Dawncrest"] = "Adventurer Dawncrest",
    ["Spark of Tides"] = "Spark of Tides",
    ["Venomblight Manaflux"] = "Venomblight Manaflux",
    ["Adventurer Mistcrest"] = "Adventurer Mistcrest",
    ["Veteran Mistcrest"] = "Veteran Mistcrest",
    ["Champion Mistcrest"] = "Champion Mistcrest",
    ["Hero Mistcrest"] = "Hero Mistcrest",
    ["Myth Mistcrest"] = "Myth Mistcrest",
    ["Corrosive Coin"] = "Corrosive Coin",
    ["Trailing Xal'atath"] = "Trailing Xal'atath",
    ["My Venomous Nemesis"] = "My Venomous Nemesis",
    ["Veteran Dawncrest"] = "Veteran Dawncrest",
    ["Champion Dawncrest"] = "Champion Dawncrest",
    ["Hero Dawncrest"] = "Hero Dawncrest",
    ["Myth Dawncrest"] = "Myth Dawncrest",
    BUTTON_WEEKLY_PLANNER = "Planner",
    TITLE_WEEKLY_PLANNER = "Weekly Planner",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "Weekly Planner",
    TOOLTIP_WEEKLY_PLANNER_DESC = "Editable per-character weekly checklist. Completed items reset each week.",
    TOOLTIP_VAULT_STATUS = "Check vault status.",
    TITLE_GREAT_VAULT = "The Great Vault",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "Raid",
    LABEL_VAULT_ROW_DUNGEONS = "Dungeons",
    LABEL_VAULT_ROW_WORLD = "World",
    LABEL_VAULT_SLOTS_UNLOCKED = "%d/9 slots unlocked",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    LABEL_VAULT_TIER_FMT = "Tier %d",
    MSG_VAULT_NO_THRESHOLD = "No threshold data saved yet.",
    WARNING_ACCOUNT_BOUND = "Account Bound",
    MSG_VAULT_LIVE_ACTIVE = "Live Great Vault progress for the active character.",
    MSG_VAULT_LIVE = "Live Great Vault progress.",
    MSG_VAULT_SAVED = "Saved Great Vault snapshot from this character's last login.",
    SECTION_DELVE_CURRENCY = "Delve Currency",
    SECTION_UPGRADE_CRESTS = "Upgrade Crests",
    LABEL_CAP_SHORT = "cap %s",
}

L["Raid resync unavailable."] = "Raid resync unavailable."
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Time played messages restored."] = "Time played messages restored."
L["%dm %02ds"] = "%dm %02ds"
L["Crests:"] = "Crests:"
L["Mount Drops"] = "Mount Drops"
L["(Collected)"] = "(Collected)"
L["(Uncollected)"] = "(Uncollected)"
L["LABEL_CRESTS"] = "Crests:"
L["TITLE_MOUNT_DROPS"] = "Mount Drops"
L["STATUS_COLLECTED_PARENS"] = "(Collected)"
L["STATUS_UNCOLLECTED_PARENS"] = "(Uncollected)"
L["Mounts: %d/%d"] = "Mounts: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Mounts: %d/%d"
L["The Voidspire"] = "The Voidspire"
L["The Dreamrift"] = "The Dreamrift"
L["March of Quel'Danas"] = "March of Quel'Danas"
L["Lady Liadrin Weekly"] = "Lady Liadrin Weekly"
L["Back"] = "Back"
L["Warband Bank"] = "Warband Bank"
L["Treatise"] = "Treatise"
L["Artisan"] = "Artisan"
L["Catch-up"] = "Catch-up"
L["LABEL_MONTHLY_PROFIT"] = "Monthly Profit"
L["LABEL_TOP_WEEKLY_EARNERS"] = "Top Weekly Earners"
L["LABEL_TOP_MONTHLY_EARNERS"] = "Top Monthly Earners"
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
L["LABEL_HISTORY_COUNT"] = "History Count"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_WARBAND_WEEKLY_PROFIT"] = "Warband Weekly Profit"
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
L["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = "WoW Token Purchase"
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
L["TEXT_PROFIT_SOURCE_WOW_TOKEN"] = "WoW Token"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "Daily net profit for the current character over the last 7 days."
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "Recent weekly transactions for the current character."
L["TIME_DAYS_AGO_FMT"] = "%dd ago"
L["TIME_HOURS_AGO_FMT"] = "%dh ago"
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "%dm ago"
L["TIME_YESTERDAY"] = "Yesterday"
L["TITLE_GLYPH_HUNTER"] = "Glyph Hunter"
L["OPTION_ENABLE_MINI_OMNIUM_FOLIO"] = "Enable Mini Omnium Folio"
L["OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC"] = "Show a movable Omnium Folio panel outside the main LiteVault window for quick node access."
L["TEXT_FOLIO_AVAILABLE_POINTS_FMT"] = "Available Points: %d"
L["TEXT_OMNIUM_FOLIO_UNAVAILABLE"] = "Omnium Folio is unavailable."
L["TITLE_RAID_SEASON_FMT"] = "%s - %s"
L["TAB_RAID_CURRENT"] = "Current"
L["TAB_RAID_LEGACY"] = "Legacy"
L["LABEL_WARBAND_PROGRESSION"] = "Warband Progression"
L["STATUS_KILLED"] = "Killed"
L["STATUS_NOT_KILLED"] = "Not killed"
L["LABEL_KILLED_BY"] = "Killed by:"
L["TEXT_NO_WARBAND_RAID_KILL"] = "No tracked character has this kill."
L["TEXT_MORE_CHARACTERS_FMT"] = "+ %d more"
L["TOOLTIP_RAID_BOSS_DIFFICULTY_FMT"] = "%s — %s"
L["LABEL_RAID_AOTC"] = "Warband Ahead of the Curve"
L["LABEL_RAID_CUTTING_EDGE"] = "Warband Cutting Edge"
L["MSG_RAID_DEBUG_NO_ENCOUNTER"] = "No ENCOUNTER_END event has been observed this session."
L["DIFFICULTY_WORLD"] = "World"
L["The Tidebound Grotto"] = "The Tidebound Grotto"
L["Nymrissa Wavecaller"] = "Nymrissa Wavecaller"
L["TITLE_RAIDS"] = "Raids"
L["TITLE_RAIDS_CHARACTER_FMT"] = "{character} - {raids} - {season}"
L["LABEL_THIS_WEEK"] = "This Week"
L["LABEL_WARBAND"] = "Warband"
L["LABEL_CHARACTER_PROGRESSION"] = "Character Progression"
L["STATUS_SAVED_KILLED"] = "Saved / Killed"
L["STATUS_NOT_SAVED_KILLED"] = "Not recorded as killed this week"
L["TITLE_MINI_OMNIUM_FOLIO"] = "Omnium Folio"
L["TOOLTIP_HIDE_MINI_FOLIO"] = "Hide Mini Folio"
L["TOOLTIP_LOCK_MINI_FOLIO"] = "Lock Mini Folio"
L["TOOLTIP_UNLOCK_MINI_FOLIO"] = "Unlock Mini Folio"
L["TEXT_PROFIT_TOKENS_THIS_MONTH_FMT"] = "Tokens This Month: %d"
L["TITLE_PROFIT_WOW_TOKENS_THIS_MONTH"] = "WoW Tokens This Month"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_PROFIT_WOW_TOKENS_THIS_MONTH"] = "Counts WoW Tokens purchased during the current calendar month. Token purchases are excluded from profit totals."
L["TOOLTIP_RUNESTONE_EVENT"] = "Fortify the Runestones"
L["TOOLTIP_RUNESTONE_SET_WAYPOINT"] = "Click to set waypoint."
L["TEXT_ACHIEVEMENT_MOUNT_FMT"] = "Mount: %s"
L["LABEL_INFO"] = "Info"
L["Achievements"] = "Achievements"
L["Criteria"] = "Criteria"
L["Details"] = "Details"
L["Groups"] = "Groups"
L["Back to Groups"] = "Back to Groups"
L["Ever-Painting"] = "Ever-Painting"
L["Midnight, the Highest Peaks"] = "Midnight, the Highest Peaks"
L["Explore Eversong Woods"] = "Explore Eversong Woods"
L["Explore Voidstorm"] = "Explore Voidstorm"
L["Explore Zul'Aman"] = "Explore Zul'Aman"
L["Explore Harandar"] = "Explore Harandar"
L["Thrill of the Chase"] = "Thrill of the Chase"
L["Treasures of Midnight"] = "Treasures of Midnight"
L["Glory of the Midnight Delver"] = "Glory of the Midnight Delver"
L["Runestone Rush"] = "Runestone Rush"
L["The Party Must Go On"] = "The Party Must Go On"
L["Making an Amani Out of You"] = "Making an Amani Out of You"
L["That's Aln, Folks!"] = "That's Aln, Folks!"
L["Forever Song"] = "Forever Song"
L["Yelling into the Voidstorm"] = "Yelling into the Voidstorm"
L["Light Up the Night"] = "Light Up the Night"
L["A Singular Problem"] = "A Singular Problem"
L["From The Cradle to the Grave"] = "From The Cradle to the Grave"
L["Chronicler of the Haranir"] = "Chronicler of the Haranir"
L["Legends Never Die"] = "Legends Never Die"
L["Dust 'Em Off"] = "Dust 'Em Off"
L["No Time to Paws"] = "No Time to Paws"
L["Moths"] = "Moths"
L["Shared Loot"] = "Shared Loot"
L["Rares of Midnight"] = "Rares of Midnight"
L["Track the four Midnight treasure achievements and their rewards."] = "Track the four Midnight treasure achievements and their rewards."
L["Track Midnight treasure achievements and their rewards."] = "Track Midnight treasure achievements and their rewards."
L["Track the four zone achievements for Midnight, the Highest Peaks."] = "Track the four zone achievements for Midnight, the Highest Peaks."
L["Complete Glory of the Midnight Delver to earn this mount."] = "Complete Glory of the Midnight Delver to earn this mount."
L["Track the four Midnight rare achievements and zone rare rewards."] = "Track the four Midnight rare achievements and zone rare rewards."
L["Track the four Midnight rare achievements."] = "Track the four Midnight rare achievements."
L["Track Midnight rare achievements, rewards, and shared drops."] = "Track Midnight rare achievements, rewards, and shared drops."
L["Discover the lore objects of the Coiled Isle."] = "Discover the lore objects of the Coiled Isle."
L["Discover all of the lore objects found on the Coiled Isle."] = "Discover all of the lore objects found on the Coiled Isle."
L["Complete the Coiled Isle achievements."] = "Complete the Coiled Isle achievements."
L["Complete the Vaults of Atal'Utek achievements."] = "Complete the Vaults of Atal'Utek achievements."
L["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."
L["Track Ever-Painting progress. Entry details can be filled in later."] = "Track Ever-Painting progress. Entry details can be filled in later."
L["Track Runestone Rush progress. Entry details can be filled in later."] = "Track Runestone Rush progress. Entry details can be filled in later."
L["Track The Party Must Go On progress. Entry details can be filled in later."] = "Track The Party Must Go On progress. Entry details can be filled in later."
L["Complete the five telescopes in this zone."] = "Complete the five telescopes in this zone."
L["Tracked entries for Ever-Painting have not been added yet."] = "Tracked entries for Ever-Painting have not been added yet."
L["Tracked entries for Runestone Rush have not been added yet."] = "Tracked entries for Runestone Rush have not been added yet."
L["Track the four faction invites for The Party Must Go On. x/y marked."] = "Track the four faction invites for The Party Must Go On. x/y marked."
L["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."
L["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."
L["Altar of Blessings: Sacred Buffet Devotee"] = "Altar of Blessings: Sacred Buffet Devotee"
L["Tracked entries for The Party Must Go On have not been added yet."] = "Tracked entries for The Party Must Go On have not been added yet."
L["Track Explore Eversong Woods progress. Entry details can be filled in later."] = "Track Explore Eversong Woods progress. Entry details can be filled in later."
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
L["Title: \"Dustlord\""] = "Title: \"Dustlord\""
L["Title: \"Chronicler of the Haranir\""] = "Title: \"Chronicler of the Haranir\""

-- Register this locale
L.LABEL_CURRENT_CHARACTER = L.LABEL_CURRENT_CHARACTER or "Current Character"
L.LABEL_WARBAND_THIS_WEEK = L.LABEL_WARBAND_THIS_WEEK or "Warband This Week"
L.LABEL_RUNS = L.LABEL_RUNS or "Runs"
L.STATUS_TIMED = L.STATUS_TIMED or "Timed"
L.STATUS_DEPLETED = L.STATUS_DEPLETED or "Depleted"
L.LABEL_BEST_TIMED = L.LABEL_BEST_TIMED or "Best Timed"
L.FILTER_THIS_WEEK = L.FILTER_THIS_WEEK or "This Week"
L.FILTER_SEASON = L.FILTER_SEASON or "Season"
L.FILTER_ALL_HISTORY = L.FILTER_ALL_HISTORY or "All History"
L.SECTION_SEASON_BESTS = L.SECTION_SEASON_BESTS or "Season Bests"
L.LABEL_BEST = L.LABEL_BEST or "Best"
L.LABEL_SCORE = L.LABEL_SCORE or "Score"
L.LABEL_NO_RUN = L.LABEL_NO_RUN or "No Run"
L.LABEL_LOWEST_SCORE = L.LABEL_LOWEST_SCORE or "Lowest Score"
L.LABEL_NO_MPLUS_KEY = L.LABEL_NO_MPLUS_KEY or "No M+ Key"
L.LABEL_DUNGEON = L.LABEL_DUNGEON or "Dungeon"
L.LABEL_KEY = L.LABEL_KEY or "Key"
L.LABEL_RESULT = L.LABEL_RESULT or "Result"
L.LABEL_TIME = L.LABEL_TIME or "Time"
L.LABEL_DATE = L.LABEL_DATE or "Date"
L.LABEL_REWARDS = L.LABEL_REWARDS or "Rewards"
L.LABEL_MAP_RECORD = L.LABEL_MAP_RECORD or "Map Record"
L.LABEL_AFFIX_RECORD = L.LABEL_AFFIX_RECORD or "Affix Record"
L.LABEL_MPLUS_SCORE_PLAIN = L.LABEL_MPLUS_SCORE_PLAIN or "M+ Score"
L.LABEL_TIMER = L.LABEL_TIMER or "Timer"
L.LABEL_TIME_REMAINING = L.LABEL_TIME_REMAINING or "Time Remaining"
L.LABEL_OVER_TIMER = L.LABEL_OVER_TIMER or "Over Timer"
L.LABEL_RECORDED_DURATION = L.LABEL_RECORDED_DURATION or "Recorded Duration"
L.LABEL_NOT_AVAILABLE = L.LABEL_NOT_AVAILABLE or "--"
L.SECTION_MPLUS_HISTORY = L.SECTION_MPLUS_HISTORY or "Mythic+ History"
L.TEXT_NO_MPLUS_RUNS_THIS_WEEK = L.TEXT_NO_MPLUS_RUNS_THIS_WEEK or "No Mythic+ runs completed this week."
L.TEXT_NO_MPLUS_RUNS_THIS_SEASON = L.TEXT_NO_MPLUS_RUNS_THIS_SEASON or "No Mythic+ runs completed this season."
L.TEXT_NO_MPLUS_RUNS_RECORDED = L.TEXT_NO_MPLUS_RUNS_RECORDED or "No Mythic+ runs recorded."
L.BUTTON_PLAN_RATING = L.BUTTON_PLAN_RATING or "Plan Rating"
L.TITLE_MPLUS_RATING_PLANNER = L.TITLE_MPLUS_RATING_PLANNER or "Mythic+ Rating Planner"
L.BUTTON_BACK_TO_DASHBOARD = L.BUTTON_BACK_TO_DASHBOARD or "Back to Dashboard"
L.LABEL_CURRENT_RATING = L.LABEL_CURRENT_RATING or "Current Rating"
L.LABEL_TARGET_RATING = L.LABEL_TARGET_RATING or "Target Rating"
L.LABEL_MINIMUM_KEY = L.LABEL_MINIMUM_KEY or "Minimum Key"
L.LABEL_MAXIMUM_KEY = L.LABEL_MAXIMUM_KEY or "Maximum Key"
L.LABEL_AVOID_DUNGEONS = L.LABEL_AVOID_DUNGEONS or "Avoid Dungeons"
L.BUTTON_CALCULATE_PLAN = L.BUTTON_CALCULATE_PLAN or "Calculate Plan"
L.LABEL_MAXIMUM_PROJECTED_RATING = L.LABEL_MAXIMUM_PROJECTED_RATING or "Maximum Projected Rating"
L.LABEL_PROJECTED_RATING = L.LABEL_PROJECTED_RATING or "Projected Rating"
L.LABEL_CURRENT = L.LABEL_CURRENT or "Current"
L.LABEL_PLAN = L.LABEL_PLAN or "Plan"
L.LABEL_GAIN = L.LABEL_GAIN or "Gain"
L.TEXT_PLANNER_ALREADY_REACHED = L.TEXT_PLANNER_ALREADY_REACHED or "You have already reached this rating."
L.TEXT_PLANNER_UNREACHABLE = L.TEXT_PLANNER_UNREACHABLE or "Target cannot be reached with the current planner limits."
L.TEXT_PLANNER_INVALID_MINIMUM = L.TEXT_PLANNER_INVALID_MINIMUM or "Minimum Key must be an integer of 2 or higher."
L.TEXT_PLANNER_INVALID_MAXIMUM = L.TEXT_PLANNER_INVALID_MAXIMUM or "Maximum Key must be an integer at least as high as Minimum Key, up to 20."
L.TEXT_PLANNER_INVALID_TARGET = L.TEXT_PLANNER_INVALID_TARGET or "Enter a valid whole-number target rating."
L.TEXT_PLANNER_TIMED_ASSUMPTION = L.TEXT_PLANNER_TIMED_ASSUMPTION or "Projection assumes each suggested key is completed in time."
L.PLANNER_FASTEST = L.PLANNER_FASTEST or "FASTEST"
L.PLANNER_BALANCED = L.PLANNER_BALANCED or "BALANCED"
L.PLANNER_EASIEST = L.PLANNER_EASIEST or "EASIEST"
lv.RegisterLocale("enUS", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["enUS"] = L










