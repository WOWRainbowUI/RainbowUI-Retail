-- enUS.lua - English (US) locale for LiteVault
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
    BUTTON_CLOSE = "Close",
    BUTTON_YES = "Yes",
    BUTTON_NO = "No",
    BUTTON_MANAGE = "Manage",
    BUTTON_BACK = "Back",
    BUTTON_ALL = "All",
    BUTTON_NONE = "None",
    BUTTON_FILTER = "Filter",
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
    BUTTON_AMANI_TRIBE = "Amani Tribe",
    BUTTON_HARATI = "Hara'ti",
    BUTTON_SINGULARITY = "The Singularity",
    BUTTON_SILVERMOON_COURT = "Silvermoon Court",
    TITLE_FACTION_WEEKLIES = "%s's Faction Weeklies",
    LABEL_RENOWN_PROGRESS = "Renown %d (%d/%d)",
    LABEL_RENOWN = "Renown",
    LABEL_RENOWN_LEVEL = "Level",
    LABEL_RENOWN_UNAVAILABLE = "Renown unavailable",
    WARNING_EVENT_QUESTS = "Some of these events are bugged or locked in game.",
    WARNING_WEEKLY_HARATI_CHOICE = "Warning! Once you choose a Legends of the Haranir quest, it's locked to your account.",
    WARNING_WEEKLY_RUNESTONES = "Warning! Choose the Runestone quest wisely. Once you pick one for the week, that choice is locked for your account.",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "No faction quests configured yet.",
    LABEL_WEEKLY_PROFIT = "Weekly Profit:",
    LABEL_WARBAND_PROFIT = "Warband Profit:",
    LABEL_WARBAND_BANK = "Warband Bank:",
    LABEL_TOP_EARNERS = "Top Earners (Weekly):",
    LABEL_TOTAL_GOLD = "Total Gold: %s",
    LABEL_TOTAL_TIME = "Total Time: %s",
    LABEL_COMBINED_TIME = "Combined Time: %dd %dh",

    TOOLTIP_TOTAL_TIME_TITLE = "Total Time",
    TOOLTIP_TOTAL_TIME_DESC = "Total time played across all tracked characters.",
    TOOLTIP_TOTAL_TIME_CLICK = "Click to cycle format.",

    -- Quest status
    STATUS_DONE = "[Done]",
    STATUS_IN_PROGRESS = "[In-Progress]",
    STATUS_NOT_STARTED = "[Not Started]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Manage Characters",
    TOOLTIP_MANAGE_BACK = "Go back to main tab.",
    TOOLTIP_MANAGE_VIEW = "See ignored characters.",

    TOOLTIP_CATALYST_TITLE = "Catalyst Charges",
    TOOLTIP_SPARKS_TITLE = "Crafting Sparks",

    TOOLTIP_VAULT_TITLE = "Great Vault",
    TOOLTIP_VAULT_DESC = "Press to open the great vault",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Open the Great Vault.",
    TOOLTIP_VAULT_ALT_ONLY = "Great Vault can only be opened for the active character.",

    TOOLTIP_CURRENCY_TITLE = "Character Currencies",
    TOOLTIP_CURRENCY_DESC = "Click to view full list.",
    TOOLTIP_BAGS_TITLE = "View Bags",
    TOOLTIP_BAGS_DESC = "View saved bag contents and reagent bag items for this character.",

    TOOLTIP_LEDGER_TITLE = "Weekly Profit Ledger",
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
    BUTTON_LEDGER = "Ledger",
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
    TITLE_RAID_LOCKOUTS_WINDOW = "Raid Lockouts",
    TITLE_RAID_FORMAT = "%s's %s %s - Manaforge Omega",

    BUTTON_PROGRESSION = "Progression",
    BUTTON_LOCKOUTS = "Lockouts",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Heroic",
    DIFFICULTY_MYTHIC = "Mythic",

    TOOLTIP_VIEW_LOCKOUTS = "Currently showing: Lockouts (this week)",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "Click to view Progression (best ever)",
    TOOLTIP_VIEW_PROGRESSION = "Currently showing: Progression (best ever)",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "Click to view Lockouts (this week)",

    MSG_NO_CHAR_DATA = "No character data found",
    MSG_NO_PROGRESSION = "No %s progression recorded",
    MSG_NO_LOCKOUT = "No %s lockout this week",

    LABEL_BOSS = "Boss %d",
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
    TITLE_WEEKLY_LEDGER = "%s - Weekly Ledger",
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
    LEDGER_AUCTION = "Auction House",
    LEDGER_TRADE = "Trade",
    LEDGER_VENDOR = "Vendor",
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
    TIME_YESTERDAY = "Yest %H:%M",

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
    MSG_LEDGER_NOT_AVAILABLE = "Ledger not available.",
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
    OPTION_DARK_MODE = "Dark Mode",
    OPTION_DARK_MODE_DESC = "Toggle between dark and light themes",
    OPTION_DISABLE_BAG_VIEWING = "Disable Bag/Bank Viewer",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Hide the Bags button and disable saved bag, bank, and warband bank viewing.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Disable Overlay System",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Hide LiteVault's item level and lock overlays on character and inspect gear.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "Disable M+ Teleports",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Hide the M+ teleport badge and disable LiteVault's teleport panel.",

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
    ["Midnight: Prey"] = "Midnight: Prey",
    ["Saltheril's Soiree"] = "Saltheril's Soiree",
    ["Abundance Event"] = "Abundance Event",
    ["Legends of the Haranir"] = "Legends of the Haranir",
    ["Stormarion Assault"] = "Stormarion Assault",
    ["Darkness Unmade"] = "Darkness Unmade",
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
L["Mounts: %d/%d"] = "Mounts: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Mounts: %d/%d"
L["The Voidspire"] = "The Voidspire"
L["The Dreamrift"] = "The Dreamrift"
L["March of Quel'Danas"] = "March of Quel'Danas"
L["Raid Progression"] = "Raid Progression"
L["Lady Liadrin Weekly"] = "Lady Liadrin Weekly"
L["Change Log"] = "Change Log"
L["Back"] = "Back"
L["Warband Bank"] = "Warband Bank"
L["Treatise"] = "Treatise"
L["Artisan"] = "Artisan"
L["Catch-up"] = "Catch-up"
L["LiteVault Update Summary"] = "LiteVault Update Summary"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."
L["Added a large batch of new translations across supported locales."] = "Added a large batch of new translations across supported locales."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "Improved localized text rendering and refresh behavior throughout the addon."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "Updated localization support for buttons, bag tabs, weekly text, and other UI labels."
L["Fixed multiple localization-related layout issues."] = "Fixed multiple localization-related layout issues."
L["Fixed several localization-related crash issues."] = "Fixed several localization-related crash issues."

-- Register this locale
lv.RegisterLocale("enUS", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["enUS"] = L










