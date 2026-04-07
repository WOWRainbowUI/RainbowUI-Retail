-- deDE.lua - German locale for LiteVault
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
    BUTTON_CLOSE = "Schließen",
    BUTTON_YES = "Ja",
    BUTTON_NO = "Nein",
    BUTTON_MANAGE = "Verwalten",
    BUTTON_BACK = "Zurück",
    BUTTON_ALL = "Alle",
    BUTTON_NONE = "Keine",
    BUTTON_FILTER = "Filter",
    DIALOG_DELETE_CHAR = "%s aus LiteVault löschen?",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "Kartenfilter",

    BUTTON_RAID_LOCKOUTS = "Raid-Sperren",
    BUTTON_WORLD_EVENTS = "Weltereignisse",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "Raid-Sperren",
    TOOLTIP_RAID_LOCKOUTS_DESC = "Bosskills aller Charaktere anzeigen",
    TOOLTIP_THEME_TITLE = "Design umschalten",
    TOOLTIP_THEME_DESC = "Zwischen Dunkel- und Hellmodus wechseln",
    TOOLTIP_FILTER_TITLE = "Kartenfilter",
    TOOLTIP_FILTER_DESC = "Klicken für vollständige Liste",
    TOOLTIP_WORLD_EVENTS_TITLE = "Weltereignisse",
    TOOLTIP_WORLD_EVENTS_DESC = "Weltereignisse anzeigen",

    -- Sort controls (shortened for button width)
    LABEL_SORT_BY = "Sortieren:",
    SORT_GOLD = "Gold",
    SORT_ILVL = "GS",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "Aktivität",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "%ss Wöchentliche Quests",
    BUTTON_WEEKLIES = "Wöchentlich",
    BUTTON_EVENTS = "Ereignisse",
    BUTTON_FACTIONS = "Fraktionen",
    BUTTON_AMANI_TRIBE = "Stamm der Amani",
    BUTTON_HARATI = "Hara'ti",
    BUTTON_SINGULARITY = "Die Singularität",
    BUTTON_SILVERMOON_COURT = "Hof von Silbermond",
    TITLE_FACTION_WEEKLIES = "%ss Fraktionsaufgaben",
    WARNING_EVENT_QUESTS = "Einige dieser Events sind im Spiel fehlerhaft oder gesperrt.",
    WARNING_WEEKLY_HARATI_CHOICE = "Warnung! Einmal gewählt, ist die Haranir-Quest für deinen Account gesperrt.",
    WARNING_WEEKLY_RUNESTONES = "Warnung! Wählt die Runenstein-Quest mit Bedacht. Sobald ihr eine für die Woche auswählt, gilt diese Wahl für euren gesamten Account.",
    LABEL_WEEKLY_PROFIT = "Wochengewinn:",
    LABEL_WARBAND_PROFIT = "Kriegsmeute-Gewinn:",
    LABEL_WARBAND_BANK = "Kriegsmeute-Bank:",
    LABEL_TOP_EARNERS = "Top-Verdiener (Wöchentlich):",
    LABEL_TOTAL_GOLD = "Gesamtgold: %s",
    LABEL_TOTAL_TIME = "Gesamtzeit: %s",
    LABEL_COMBINED_TIME = "Kombinierte Zeit: %dT %dStd.",

    TOOLTIP_TOTAL_TIME_TITLE = "Gesamtspielzeit",
    TOOLTIP_TOTAL_TIME_DESC = "Gesamtspielzeit aller verfolgten Charaktere.",
    TOOLTIP_TOTAL_TIME_CLICK = "Klicken um Format zu wechseln.",

    -- Quest status
    STATUS_DONE = "[Abgeschlossen]",
    STATUS_IN_PROGRESS = "[Laufend]",
    STATUS_NOT_STARTED = "[Nicht begonnen]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Charaktere verwalten",
    TOOLTIP_MANAGE_BACK = "Zurück zur Hauptansicht.",
    TOOLTIP_MANAGE_VIEW = "Ignorierte Charaktere anzeigen.",

    TOOLTIP_CATALYST_TITLE = "Katalysator-Aufladungen",
    TOOLTIP_SPARKS_TITLE = "Handwerksfunken",

    TOOLTIP_VAULT_TITLE = "Die Große Schatzkammer",
    TOOLTIP_VAULT_DESC = "Klicken um die Große Schatzkammer zu öffnen",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Die Große Schatzkammer öffnen.",
    TOOLTIP_VAULT_ALT_ONLY = "Die Große Schatzkammer kann nur für den aktiven Charakter geöffnet werden.",

    TOOLTIP_CURRENCY_TITLE = "Abzeichen & Währungen",
    TOOLTIP_CURRENCY_DESC = "Klicken für vollständige Liste.",
    TOOLTIP_BAGS_TITLE = "Taschen anzeigen",
    TOOLTIP_BAGS_DESC = "Gespeicherte Taschen- und Reagenzieninhalt anzeigen.",

    TOOLTIP_LEDGER_TITLE = "Wöchentliches Gewinnbuch",
    TOOLTIP_LEDGER_DESC = "Goldeinnahmen und -ausgaben nach Quelle verfolgen.",

    TOOLTIP_WARBAND_BANK_TITLE = "Kriegsmeute-Bank Buch",
    TOOLTIP_WARBAND_BANK_DESC = "Klicken um Transaktionen anzuzeigen.",

    TOOLTIP_RESTORE_TITLE = "Wiederherstellen",
    TOOLTIP_RESTORE_DESC = "Charakter auf Hauptseite wiederherstellen",

    TOOLTIP_IGNORE_TITLE = "Ignorieren",
    TOOLTIP_IGNORE_DESC = "Charakter von Hauptseite entfernen",

    TOOLTIP_DELETE_TITLE = "Löschen",
    TOOLTIP_DELETE_DESC = "Charakterdaten dauerhaft löschen",
    TOOLTIP_DELETE_WARNING = "Warnung: Dies kann nicht rückgängig gemacht werden!",

    TOOLTIP_FAVORITE_TITLE = "Favorit",
    TOOLTIP_FAVORITE_DESC = "Charakter oben in der Liste anheften",

    -- Character data displays
    LABEL_ILVL = "GS: %d",
    LABEL_MPLUS_SCORE = "Wertung: %d",
    LABEL_NO_KEY = "Kein Schlüsselstein",
    LABEL_NO_PROFESSIONS = "Keine Berufe",
    LABEL_UNKNOWN = "Unbekannt",
    LABEL_SKILL_LEVEL = "Fertigkeit: %d/%d",
    LABEL_CONCENTRATION = "Konzentration: %d/%d",
    LABEL_CONC_DAILY_RESET = "Täglich: %dh %dm",
    LABEL_CONC_WEEKLY_RESET = "Voll-Reset: %dT %dh",
    LABEL_CONC_FULL = "(Voll)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d Wissen verfügbar",
    LABEL_NO_KNOWLEDGE = "Kein Wissen verfügbar",
    LABEL_VAULT_PROGRESS = "S: %d/3    M+: %d/3    W: %d/3",
    BUTTON_LEDGER = "Buch",
    BUTTON_PROFS = "Berufe",

    TOOLTIP_PROFS_TITLE = "Berufe",
    TOOLTIP_PROFS_DESC = "Konzentration und Wissen anzeigen",
    TITLE_PROFESSIONS = "%ss Berufe",
    TITLE_KNOWLEDGE_SOURCES = "Wissensquellen",
    TAB_TREASURES = "Schätze",
    LABEL_UNIQUE_TREASURES = "Einmalige Schätze",
    LABEL_WEEKLY_TREASURES = "Wöchentliche Schätze",
    LABEL_HOVER_TREASURE_CHECKLIST = "Für Schatzliste darüberfahren",
    TITLE_PROF_TREASURES_FMT = "%s-Schätze",
    LABEL_PROFESSION = "Beruf",
    LABEL_UNIQUE_TREASURE_FMT = "%s Einmaliger Schatz %d",
    LABEL_WEEKLY_TREASURE_FMT = "%s Wöchentlicher Schatz %d",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "So",
    DAY_MON = "Mo",
    DAY_TUE = "Di",
    DAY_WED = "Mi",
    DAY_THU = "Do",
    DAY_FRI = "Fr",
    DAY_SAT = "Sa",

    TOOLTIP_ACTIVITY_FOR = "Aktivität für %d.%d.%d",
    MSG_NO_WORLD_EVENTS = "Keine Weltereignisse diesen Monat",

    -- Filter categories
    FILTER_TIMEWALKING = "Zeitwanderung",
    FILTER_DARKMOON = "Dunkelmond",
    FILTER_DUNGEONS = "Dungeons",
    FILTER_PVP = "PvP",
    FILTER_BONUS = "Bonusereignis",

    -- World events
    WORLD_EVENT_LOVE = "Liebe liegt in der Luft",
    WORLD_EVENT_LUNAR = "Mondfest",
    WORLD_EVENT_NOBLEGARDEN = "Nobelgarten",
    WORLD_EVENT_CHILDREN = "Kinderwoche",
    WORLD_EVENT_MIDSUMMER = "Sonnenwendfest",
    WORLD_EVENT_BREWFEST = "Braufest",
    WORLD_EVENT_HALLOWS = "Schlotternächte",
    WORLD_EVENT_WINTERVEIL = "Winterhauch",
    WORLD_EVENT_DEAD = "Tag der Toten",
    WORLD_EVENT_PIRATES = "Piratentag",
    WORLD_EVENT_STYLE = "Probe des Stils",
    WORLD_EVENT_OUTLAND = "Scherbenwelt-Cup",
    WORLD_EVENT_NORTHREND = "Nordend-Cup",
    WORLD_EVENT_KALIMDOR = "Kalimdor-Cup",
    WORLD_EVENT_EASTERN = "Östliche Königreiche-Cup",
    WORLD_EVENT_WINDS = "Winde des geheimnisvollen Glücks",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "%ss Währungen",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "Raid-Sperren",
    TITLE_RAID_FORMAT = "%ss %s %s",

    BUTTON_PROGRESSION = "Fortschritt",
    BUTTON_LOCKOUTS = "Sperren",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Heroisch",
    DIFFICULTY_MYTHIC = "Mythisch",

    TOOLTIP_VIEW_LOCKOUTS = "Aktuell angezeigt: Sperren (diese Woche)",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "Klicken für Fortschritt (bester Stand)",
    TOOLTIP_VIEW_PROGRESSION = "Aktuell angezeigt: Fortschritt (bester Stand)",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "Klicken für Sperren (diese Woche)",

    MSG_NO_CHAR_DATA = "Keine Charakterdaten gefunden",
    MSG_NO_PROGRESSION = "Kein %s Fortschritt aufgezeichnet",
    MSG_NO_LOCKOUT = "Keine %s Sperre diese Woche",

    LABEL_BOSS = "Boss %d",
    LABEL_PROGRESS_COUNT = "%d/8",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "Kriegsmeute-Bank Buch",
    LABEL_CURRENT_BALANCE = "Aktueller Stand:",
    LABEL_RECENT_TRANSACTIONS = "Letzte Transaktionen:",
    MSG_NO_TRANSACTIONS = "(Noch keine Transaktionen aufgezeichnet)",
    TIP_RELOAD_SAVE = "Tipp: /reload vor Charakterwechsel zum Speichern",
    ACTION_DEPOSITED = "eingezahlt",
    ACTION_WITHDREW = "entnommen",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    TITLE_WEEKLY_LEDGER = "%s - Wöchentliches Buch",
    LABEL_RESETS_IN = "Reset in %dT %dStd.",

    TAB_SUMMARY = "Übersicht",
    TAB_HISTORY = "Verlauf",
    TAB_WARBAND = "Warband",
    HEADER_SOURCE = "Quelle",
    HEADER_INCOME = "Einnahmen",
    HEADER_EXPENSE = "Ausgaben",

    LABEL_TOTAL = "Gesamt",
    LABEL_NET_PROFIT = "Nettogewinn",
    MSG_NO_GOLD_ACTIVITY = "Keine Goldaktivität diese Woche",
    MSG_NO_TRANSACTIONS_WEEK = "Keine Transaktionen diese Woche",

    -- Ledger source categories
    LEDGER_QUESTS = "Quests",
    LEDGER_AUCTION = "Auktionshaus",
    LEDGER_TRADE = "Handel",
    LEDGER_VENDOR = "Händler",
    LEDGER_REPAIRS = "Reparaturen",
    LEDGER_TRANSMOG = "Transmogrifikation",
    LEDGER_FLIGHT = "Flugmeister",
    LEDGER_CRAFTING = "Berufe & Handwerk",
    LEDGER_CACHE = "Truhe/Behälter",
    LEDGER_MAIL = "Post",
    LEDGER_LOOT = "Beute",
    LEDGER_WARBAND_BANK = "Kriegsmeute-Bank",
    LEDGER_OTHER = "Sonstiges",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "Nie",
    FRESH_TODAY = "Heute",
    FRESH_1_DAY = "Vor 1 Tag",
    FRESH_DAYS = "Vor %d Tagen",

    -- Time format styles
    TIME_YEARS_DAYS = "%dJ %dT",
    TIME_DAYS_HOURS = "%dT %dStd.",
    TIME_DAYS = "%s Tage",
    TIME_HOURS = "%s Std.",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "Grüße %s,\nmöchtest du diesen Charakter mit LiteVault verfolgen?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "Wöchentlicher Reset erkannt! Sperren gelöscht.",
    MSG_ALREADY_TRACKED = "Dieser Charakter wird bereits verfolgt.",
    MSG_CHAR_ADDED = "%s wurde zur Verfolgung hinzugefügt.",
    MSG_LEDGER_NOT_AVAILABLE = "Buch nicht verfügbar.",
    MSG_RAID_RESET_SEASON = "Schlachtzugsfortschritt wurde für Midnight Saison 1 zurückgesetzt!",
    MSG_CLEARED_PROGRESSION = "Fortschrittsdaten für %d Charaktere gelöscht.",
    MSG_WEEKLY_PROFIT_RESET = "Wöchentliche Gewinnverfolgung für %d Charaktere zurückgesetzt.",
    MSG_WARBAND_BALANCE = "Kriegsmeute: %s",
    MSG_WARBAND_BANK_BALANCE = "Kriegsmeute-Bank: %s",
    MSG_WEEKLY_DATA_RESET = "Wöchentliche Daten für %d Charaktere zurückgesetzt.",
    MSG_RAID_MANUAL_RESET = "Schlachtzugsfortschritt manuell zurückgesetzt!",
    MSG_CLEARED_DATA = "Daten für %d Charaktere gelöscht.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "Blizzards anfängliche Spielzeitmeldung kann nicht unterdrückt werden.",

    -- Slash command help
    HELP_RESET_TITLE = "LiteVault Reset-Befehle",
    HELP_REGION = "Region: %s (Reset %s)",
    HELP_LAST_SEASON = "Letzter Saison-Reset: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - Wöchentliche Gewinnverfolgung zurücksetzen",
    HELP_RESET_SEASON = "/lvreset season - Schlachtzugsfortschritt zurücksetzen (neue Stufe)",
    HELP_NEVER = "Nie",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "Sprache",
    TOOLTIP_LANGUAGE_TITLE = "Sprache",
    TOOLTIP_LANGUAGE_DESC = "Sprache der Benutzeroberfläche ändern",
    TITLE_LANGUAGE_SELECT = "Sprache wählen",
    LANG_AUTO = "Automatisch",
    MSG_LANGUAGE_CHANGED = "Sprache geändert. UI neu laden um alle Änderungen anzuwenden.",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "Optionen",
    TOOLTIP_OPTIONS_TITLE = "Optionen",
    TOOLTIP_OPTIONS_DESC = "LiteVault-Einstellungen konfigurieren",
    TITLE_OPTIONS = "LiteVault Optionen",
    OPTION_DISABLE_TIMEPLAYED = "Spielzeit-Verfolgung deaktivieren",
    OPTION_DISABLE_TIMEPLAYED_DESC = "Verhindert /played Nachrichten im Chat",
    OPTION_DARK_MODE = "Dunkelmodus",
    OPTION_DARK_MODE_DESC = "Zwischen dunklem und hellem Design wechseln",
    OPTION_DISABLE_BAG_VIEWING = "Taschen-/Bank-Ansicht deaktivieren",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Versteckt den Taschen-Button und deaktiviert die Ansicht von gespeicherten Taschen, Bank und Kriegsmeute-Bank.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Überlagerungssystem deaktivieren",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Versteckt LiteVaults Gegenstandsstufen- und Sperr-Überlagerungen auf Charakter- und Inspektionsausrüstung.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "M+-Teleporte deaktivieren",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Versteckt das M+-Teleport-Abzeichen und deaktiviert LiteVaults Teleport-Panel.",

    -- Month names
    MONTH_1 = "Januar",
    MONTH_2 = "Februar",
    MONTH_3 = "März",
    MONTH_4 = "April",
    MONTH_5 = "Mai",
    MONTH_6 = "Juni",
    MONTH_7 = "Juli",
    MONTH_8 = "August",
    MONTH_9 = "September",
    MONTH_10 = "Oktober",
    MONTH_11 = "November",
    MONTH_12 = "Dezember",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["Dawnlight Manaflux"] = "Morgenlichtmanaflux",

    -- ==========================================================================
    -- WEEKLY QUESTS (Midnight)
    -- ==========================================================================
    ["Community Engagement"] = "Community Engagement",
    WARNING_ACCOUNT_BOUND = "Accountgebunden",
    ["Midnight: Prey"] = "Midnight: Prey",
    ["Saltheril's Soiree"] = "Saltherils Soiree",
    ["Abundance Event"] = "Überfluss",
    ["Legends of the Haranir"] = "Legenden der Haranir",
    ["Stormarion Assault"] = "Sturmarion-Angriff",
    ["Darkness Unmade"] = "Ungefertigte Dunkelheit",
    ["Harvesting the Void"] = "Ernte der Leere",
    ["Midnight: Saltheril's Soiree"] = "Mitternacht: Saltherils Soiree",
    ["Fortify the Runestones: Blood Knights"] = "Runensteine stärken: Blutritter",
    ["Fortify the Runestones: Shades of the Row"] = "Runensteine stärken: Schatten der Gasse",
    ["Fortify the Runestones: Magisters"] = "Runensteine stärken: Magister",
    ["Fortify the Runestones: Farstriders"] = "Runensteine stärken: Weltenwanderer",
    ["Put a Little Snap in Their Step"] = "Gib ihrem Schritt mehr Schwung",
    ["Light Snacks"] = "Leichte Snacks",
    ["Less Lawless"] = "Weniger gesetzlos",
    ["The Subtle Game"] = "Das subtile Spiel",
    ["Courting Success"] = "Erfolgreiches Werben",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Alchemie",
    ["Blacksmithing"] = "Schmiedekunst",
    ["Enchanting"] = "Verzauberkunst",
    ["Engineering"] = "Ingenieurskunst",
    ["Inscription"] = "Inschriftenkunde",
    ["Jewelcrafting"] = "Juwelierskunst",
    ["Leatherworking"] = "Lederverarbeitung",
    ["Tailoring"] = "Schneiderei",
    ["Herbalism"] = "Kräuterkunde",
    ["Mining"] = "Bergbau",
    ["Skinning"] = "Kürschnerei",

    ["Remnant of Anguish"] = "Überrest der Qual",
    ["Shard of Dundun"] = "Splitter von Dundun",
    ["Adventurer Dawncrest"] = "Abenteurer-Dämmerwappen",
    ["Veteran Dawncrest"] = "Veteranen-Dämmerwappen",
    ["Champion Dawncrest"] = "Champion-Dämmerwappen",
    ["Hero Dawncrest"] = "Helden-Dämmerwappen",
    ["Myth Dawncrest"] = "Mythisches Dämmerwappen",
    ["Brimming Arcana"] = "Prall gefüllte Arkana",
    ["Throw the Dice"] = "Würfle",
    ["We Need a Refill"] = "Wir brauchen Nachschub",
    ["Lovely Plumage"] = "Liebliches Gefieder",
    ["The Cauldron of Echoes"] = "Der Kessel der Echos",
    ["The Echoless Flame"] = "Die echolose Flamme",
    ["Hidey-Hole"] = "Versteck",
    ["Victorious Stormarion Pinnacle Cache"] = "Siegreiches Sturmarion-Gipfelversteck",
    ["Overflowing Abundant Satchel"] = "Überquellender Beutel des Überflusses",
    ["Avid Learner's Supply Pack"] = "Versorgungspaket des eifrigen Lernenden",
    ["Surplus Bag of Party Favors"] = "Überschüssiger Beutel mit Partygeschenken",
    ["Voidlight Marl"] = "Leerenlichtmergel",
    ["Undercoin"] = "Untermünze",
    TELEPORT_PANEL_TITLE = "M+ Teleporte",
    TELEPORT_CAST_BTN = "Teleport",
    TELEPORT_ERR_COMBAT = "Teleportieren ist im Kampf nicht möglich.",
    BUTTON_VAULT = "Tresor",
    BUTTON_ACTIONS = "Aktionen",
    BUTTON_RAIDS = "Raids",
    BUTTON_FAVORITE = "Favorit",
    BUTTON_UNFAVORITE = "Favorit entfernen",
    BUTTON_IGNORE = "Ignorieren",
    BUTTON_RESTORE = "Wiederherstellen",
    BUTTON_DELETE = "Löschen",
    TOOLTIP_ACTIONS_TITLE = "Charakteraktionen",
    TOOLTIP_ACTIONS_DESC = "Aktionsmenü öffnen",
    BUTTON_INSTANCES = "Instanzen",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Instanz-Tracker",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Dungeon- und Raidläufe verfolgen",
    LABEL_RENOWN_PROGRESS = "Ruhmstufe %d (%d/%d)",
    LABEL_RENOWN = "Renommee",
    LABEL_RENOWN_LEVEL = "Stufe",
    LABEL_RENOWN_UNAVAILABLE = "Ruhmstufe nicht verfügbar",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "Noch keine Fraktionsquests konfiguriert.",
    BUTTON_KNOWLEDGE = "Wissen",
    WORLD_EVENT_SALTHERIL = "Saltherils Soiree",
    WORLD_EVENT_ABUNDANCE = "Überfluss",
    WORLD_EVENT_HARANIR = "Legenden der Haranir",
    WORLD_EVENT_STORMARION = "Sturmarion-Angriff",
    TITLE_KNOWLEDGE_TRACKER = "Wissens-Tracker",
    TOOLTIP_KNOWLEDGE_DESC = "Ausgegebenes, unverbrauchtes und maximales Wissen anzeigen",
    LABEL_SPENT = "Ausgegeben",
    LABEL_UNSPENT = "Nicht ausgegeben",
    LABEL_MAX = "Maximum",
    LABEL_EARNED = "Erhalten",
    LABEL_TREATISE = "Traktat",
    LABEL_ARTISAN_QUEST = "Handwerker",
    LABEL_CATCHUP = "Aufholen",
    LABEL_WEEKLY = "Wöchentlich",
    LABEL_UNLOCKED = "Freigeschaltet",
    LABEL_UNLOCK_REQUIREMENTS = "Freischaltanforderungen",
    LABEL_SOURCE_NOTE = "Wöchentliche Quellen und Aufhol-Schnappschuss",
    LABEL_TREASURE_CLICK_HINT = "Klicke auf einen einzigartigen Schatz, um einen Wegpunkt zu setzen",
    LABEL_ZONE = "Zone",
    LABEL_QUEST = "Quest",
    LABEL_COORDINATES = "Koordinaten",
    TOOLTIP_TREASURE_SET_WAYPOINT = "Klicken, um einen TomTom-Wegpunkt zu setzen",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "Klicken, um einen Kartenwegpunkt zu setzen",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "Für diesen Schatz gibt es keinen festen Ort",
    MSG_TREASURE_NO_WAYPOINT = "Für diesen Schatz gibt es keinen festen Wegpunkt.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom nicht erkannt.",
    MSG_TREASURE_WAYPOINT_SET = "Wegpunkt gesetzt: %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "Kartenwegpunkt gesetzt: %s (%.1f, %.1f)",
    STATUS_DONE_WORD = "Erledigt",
    STATUS_MISSING_WORD = "Fehlt",
    LABEL_MIDNIGHT_SEASON_1 = "Saison 1 von Midnight",
    TAB_SOURCES = "Quellen",
    TIME_TODAY = "Heute %H:%M",
    TIME_YESTERDAY = "Gest. %H:%M",
    MSG_CAP_WARNING = "Instanzlimit-Warnung! %d/10 Instanzen in dieser Stunde.",
    MSG_CAP_SLOT_OPEN = "Ein Instanzplatz ist jetzt frei! (%d/10 belegt)",
    MSG_RELOAD_TIMEPLAYED = "Ladet die UI neu, damit die Unterdrückung der Spielzeit wirksam wird.",
    MSG_RAID_DEBUG_ON = "LiteVault-Raid-Debug: AN",
    MSG_RAID_DEBUG_OFF = "LiteVault-Raid-Debug: AUS",
    MSG_RAID_DEBUG_TIP = "Verwendet /lvraiddbg erneut, um die Debug-Ausgabe auszuschalten",
    MSG_TRACKED_KILL = "%s-Kill erfasst: %s (%s)",
    LOCALE_DEBUG_ON = "Sprach-Debugmodus AN - Zeigt String-Schlüssel an",
    LOCALE_DEBUG_OFF = "Sprach-Debugmodus AUS - Zeigt Übersetzungen an",
    LOCALE_BORDERS_ON = "Rahmenmodus AN - Zeigt Textgrenzen",
    LOCALE_BORDERS_HINT = "Grün = passt, Rot = könnte überlaufen",
    LOCALE_BORDERS_OFF = "Rahmenmodus AUS",
    LOCALE_FORCED = "Sprache auf %s erzwungen",
    LOCALE_RESET_TIP = "Verwendet /lvlocale reset, um zur automatischen Erkennung zurückzukehren",
    LOCALE_INVALID = "Ungültige Sprache. Gültige Optionen:",
    LOCALE_RESET = "Sprache auf automatische Erkennung zurückgesetzt: %s",
    LOCALE_TITLE = "LiteVault-Lokalisierung",
    LOCALE_DETECTED = "Erkannte Sprache: %s",
    LOCALE_FORCED_TO = "Erzwungene Sprache: %s",
    LOCALE_DEBUG_KEYS = "Debug-Schlüssel:",
    LOCALE_DEBUG_BORDERS = "Debug-Rahmen:",
    LOCALE_ON = "AN",
    LOCALE_OFF = "AUS",
    LOCALE_COMMANDS = "Befehle:",
    LOCALE_CMD_DEBUG = "/lvlocale debug - Modus zur Schlüsselanzeige umschalten",
    LOCALE_CMD_BORDERS = "/lvlocale borders - Textgrenzen-Visualisierung umschalten",
    LOCALE_CMD_LANG = "/lvlocale lang XX - Sprache erzwingen (z. B. deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - Auf automatische Erkennung zurücksetzen",
    TITLE_INSTANCE_TRACKER = "Instanz-Tracker",
    SECTION_INSTANCE_CAP = "Instanzlimit (10/Stunde)",
    LABEL_CAP_CURRENT = "Aktuell: %d/10",
    LABEL_CAP_STATUS = "Status: %s",
    LABEL_NEXT_SLOT = "Nächster Platz in: %s",
    STATUS_SAFE = "SICHER",
    STATUS_WARNING = "WARNUNG",
    STATUS_LOCKED = "GESPERRT",
    SECTION_CURRENT_RUN = "Aktueller Lauf",
    LABEL_DURATION = "Dauer: %s",
    LABEL_NOT_IN_INSTANCE = "Nicht in einer Instanz",
    SECTION_PERFORMANCE = "Leistung heute",
    LABEL_DUNGEONS_TODAY = "Dungeons: %d",
    LABEL_RAIDS_TODAY = "Raids: %d",
    LABEL_AVG_TIME = "Ø: %s",
    SECTION_LEGACY_RAIDS = "Legacy-Raids diese Woche",
    LABEL_LEGACY_RUNS = "Läufe: %d",
    LABEL_GOLD_EARNED = "Gold: %s",
    SECTION_RECENT_RUNS = "Letzte Läufe",
    LABEL_NO_RECENT_RUNS = "Keine letzten Läufe",
    SECTION_MPLUS = "Mythic+",
    LABEL_MPLUS_CURRENT_KEY = "Aktueller Schlüssel:",
    LABEL_RUNS_TODAY = "Läufe heute: %d",
    LABEL_RUNS_THIS_WEEK = "Läufe diese Woche: %d",
    SECTION_RECENT_MPLUS_RUNS = "Letzte M+-Läufe",
    LABEL_NO_RECENT_MPLUS_RUNS = "Keine letzten M+-Läufe",
    BUTTON_DASHBOARD = "Übersicht",
    BUTTON_ACHIEVEMENTS = "Erfolge",
    TITLE_ACHIEVEMENTS = "Erfolge",
    DESC_ACHIEVEMENTS = "Wähle einen Erfolgs-Tracker, um detaillierten Fortschritt zu sehen.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "Mitternacht-Glyphenjäger",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "Mitternacht-Glyphenjäger",
    LABEL_REWARD = "Belohnung",
    DESC_GLYPH_REWARD = "Schließe den Mitternacht-Glyphenjäger ab, um dieses Reittier zu erhalten.",
    MSG_NO_ACHIEVEMENT_DATA = "Keine Erfolgs-Tracking-Daten verfügbar.",
    LABEL_CRITERIA = "Kriterien",
    LABEL_GLYPHS_COLLECTED = "Gesammelte Glyphen",
    LABEL_ACHIEVEMENT = "Erfolg",
    BUTTON_BAGS = "Taschen",
    BUTTON_BANK = "Bank",
    BUTTON_WARBAND_BANK = "Kriegsmeute-Bank",
    BAGS_EMPTY_STATE = "Noch keine gespeicherten Tascheninhalte für diesen Charakter.",
    BANK_EMPTY_STATE = "Noch keine gespeicherten Bankinhalte für diesen Charakter.",
    WARBANK_EMPTY_STATE = "Noch keine gespeicherten Kriegsmeute-Bank-Inhalte.",
    LABEL_BAG_SLOTS = "Plätze: %d / %d belegt",
    LABEL_SCANNED = "gescannt",
    OPTION_ENABLE_24HR_CLOCK = "24-Stunden-Uhr aktivieren",
    OPTION_ENABLE_24HR_CLOCK_DESC = "Zwischen 24- und 12-Stunden-Format wechseln",
    ["Coffer Key Shards"] = "Schlüsselstein-Splitter",
    BUTTON_WEEKLY_PLANNER = "Planer",
    TITLE_WEEKLY_PLANNER = "Wochenplaner",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "Wochenplaner",
    TOOLTIP_WEEKLY_PLANNER_DESC = "Bearbeitbare wöchentliche Checkliste pro Charakter. Abgeschlossene Einträge werden jede Woche zurückgesetzt.",
    TOOLTIP_VAULT_STATUS = "Tresorstatus prüfen.",
    TITLE_GREAT_VAULT = "Das Große Gewölbe",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "Schlachtzug",
    LABEL_VAULT_ROW_DUNGEONS = "Dungeons",
    LABEL_VAULT_ROW_WORLD = "Welt",
    LABEL_VAULT_SLOTS_UNLOCKED = "%d/9 Plätze freigeschaltet",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "Noch keine Schwellenwert-Daten gespeichert.",
    MSG_VAULT_LIVE_ACTIVE = "Live-Fortschritt des Großen Gewölbes für den aktiven Charakter.",
    MSG_VAULT_LIVE = "Live-Fortschritt des Großen Gewölbes.",
    MSG_VAULT_SAVED = "Gespeicherte Momentaufnahme des Großen Gewölbes vom letzten Login dieses Charakters.",
    SECTION_DELVE_CURRENCY = "Tiefenwährung",
    SECTION_UPGRADE_CRESTS = "Aufwertungswappen",
    LABEL_CAP_SHORT = "Limit %s",
    ["Treasures of Midnight"] = "Schätze von Midnight",
    ["Track the four Midnight treasure achievements and their rewards."] = "Verfolge die vier Schatz-Erfolge von Midnight und ihre Belohnungen.",
    ["Glory of the Midnight Delver"] = "Ruhm des Midnight-Tiefenforschers",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "Schließe „Ruhm des Midnight-Tiefenforschers“ ab, um dieses Reittier zu erhalten.",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "Verfolge die vier seltenen Erfolge von Midnight und die Belohnungen der Zonen-Rares.",
    ["Track the four Midnight rare achievements."] = "Verfolge die vier seltenen Erfolge von Midnight.",
    ["Complete the five telescopes in this zone."] = "Schließe die fünf Teleskope in dieser Zone ab.",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "Schließe alle vier unterstützenden Midnight-Tiefenforscher-Erfolge ab, um diesen Meta-Erfolg abzuschließen.",
    ["Crimson Dragonhawk"] = "Karmesinroter Drachenfalke",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Achievements"] = "Erfolge",
    ["Reward"] = "Belohnung",
    ["Details"] = "Details",
    ["Criteria"] = "Kriterien",
    ["Info"] = "Info",
    ["Shared Loot"] = "Geteilte Beute",
    ["Groups"] = "Gruppen",
    ["Back to Groups"] = "Zurück zu den Gruppen",
    ["Back"] = "Zurück",
    ["Unknown"] = "Unbekannt",
    ["Item"] = "Gegenstand",
    ["No achievement reward listed."] = "Keine Erfolgsbelohnung aufgeführt.",
    ["Click to set waypoint."] = "Klicken, um einen Wegpunkt zu setzen.",
    ["Click to open this tracker."] = "Klicken, um diesen Tracker zu öffnen.",
    ["Tracker not added yet."] = "Tracker noch nicht hinzugefügt.",
    ["Coordinates pending."] = "Koordinaten ausstehend.",
    ["Complete the cave run here for credit."] = "Schließe hier den Höhlenlauf ab, um Fortschritt zu erhalten.",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "Lade den Runenstein mit latenter Arkana auf, um sein Verteidigungsereignis zu starten.",
    ["Achievement credit from:"] = "Erfolgsfortschritt durch:",
    ["Stormarion Assault"] = "Sturm auf Stormarion",
    ["Ever-Painting"] = "Immerwährende Malerei",
    ["Track the known Ever-Painting canvases. x/y marked."] = "Verfolge die bekannten Leinwände von Ever-Painting. x/y markiert.",
    ["Tracked entries for Ever-Painting have not been added yet."] = "Verfolgte Einträge für Ever-Painting wurden noch nicht hinzugefügt.",
    ["Runestone Rush"] = "Runenstein-Rausch",
    ["Track the known Runestone Rush entries. x/y marked."] = "Verfolge die bekannten Einträge für Runestone Rush. x/y markiert.",
    ["Tracked entries for Runestone Rush have not been added yet."] = "Verfolgte Einträge für Runestone Rush wurden noch nicht hinzugefügt.",
    ["The Party Must Go On"] = "Die Party muss weitergehen",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "Verfolge die vier Fraktionseinladungen für Die Party muss weitergehen. x/y markiert.",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "Verfolgte Einträge für Die Party muss weitergehen wurden noch nicht hinzugefügt.",
    ["Explore trackers"] = "Erkundungs-Tracker",
    ["Track Explore Eversong Woods progress. x/y marked."] = "Verfolge den Fortschritt für Erkundet Immersangwald. x/y markiert.",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "Verfolgte Einträge für Erkundet Immersangwald wurden noch nicht hinzugefügt.",
    ["Track Explore Voidstorm progress. x/y marked."] = "Verfolge den Fortschritt für Erkundet Voidstorm. x/y markiert.",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "Verfolgte Einträge für Erkundet Voidstorm wurden noch nicht hinzugefügt.",
    ["Track Explore Zul'Aman progress. x/y marked."] = "Verfolge den Fortschritt für Erkundet Zul'Aman. x/y markiert.",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "Verfolgte Einträge für Erkundet Zul'Aman wurden noch nicht hinzugefügt.",
    ["Track Explore Harandar progress. x/y marked."] = "Verfolge den Fortschritt für Erkundet Harandar. x/y markiert.",
    ["Tracked entries for Explore Harandar have not been added yet."] = "Verfolgte Einträge für Erkundet Harandar wurden noch nicht hinzugefügt.",
    ["Thrill of the Chase"] = "Nervenkitzel der Jagd",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "Entkomme dem Griff der Hungernden Präsenz in Voidstorm für mindestens 60 Sekunden.",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Überlebe das Ereignis der Hungernden Präsenz in Voidstorm für mindestens 60 Sekunden.",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "Verfolgte Einträge für Nervenkitzel der Jagd wurden noch nicht hinzugefügt.",
    ["No Time to Paws"] = "Keine Zeit für Pfoten",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "Schließe die Harandar-Weltquest „Pfotenrecht“ mit 15 oder mehr Stapeln von „Jagd des Jägers“ ab.",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Schließe die Harandar-Weltquest „Pfotenrecht“ mit 15 oder mehr Stapeln von „Jagd des Jägers“ ab.",
    ["Tracked entries for No Time to Paws have not been added yet."] = "Verfolgte Einträge für Keine Zeit für Pfoten wurden noch nicht hinzugefügt.",
    ["From The Cradle to the Grave"] = "Von der Wiege bis ins Grab",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "Versuche, zur Wiege hoch am Himmel über Harandar zu fliegen.",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "Fliege in die Wiege hoch am Himmel über Harandar, um diesen Erfolg abzuschließen.",
    ["Chronicler of the Haranir"] = "Chronist der Haranir",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "Diese Journale sind nur während der accountgebundenen Wochenquest „Legenden der Haranir“ verfügbar. Suche während einer Vision auf deiner Minikarte nach dem Lupensymbol.",
    ["Recover the Haranir journal entries listed below."] = "Finde die unten aufgeführten Haranir-Journaleinträge wieder.",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "Finde die unten aufgeführten Haranir-Journaleinträge wieder. x/y markiert.",
    ["Legends Never Die"] = "Legenden sterben nie",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "Dies ist an die accountgebundene Wochenquest „Legenden der Haranir“ gebunden. Wenn du noch keinen Fortschritt hast, dauert es schätzungsweise etwa 7 Wochen bis zum Abschluss.",
    ["Defend each Haranir legend location listed below."] = "Verteidige jeden unten aufgeführten Ort der Haranir-Legenden.",
    ["Protect each Haranir legend location listed below. x/y marked."] = "Beschütze jeden unten aufgeführten Ort der Haranir-Legenden. x/y markiert.",
    ["Dust 'Em Off"] = "Staub sie ab",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "Finde alle Leuchtenden Motten, die sich in Harandar verstecken. x/y gefunden.",
    ["Coordinate groups have not been added yet."] = "Koordinatengruppen wurden noch nicht hinzugefügt.",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "Dieser Tracker ist in 3 Gruppen mit je 40 Koordinaten aufgeteilt, damit die Mottenrouten überschaubar bleiben.",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "Motten 1-40 erscheinen bei Hara'ti-Ruhm 1, Verfolgung ab Ruhm 2.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Motten 41-80 erscheinen bei Hara'ti-Ruhm 4, Verfolgung ab Ruhm 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Motten 81-120 erscheinen bei Hara'ti-Ruhm 9, Verfolgung ab Ruhm 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "Die LiteVault-Routen gehen davon aus, dass du Hara'ti-Ruhm 11 bereits freigeschaltet hast.",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s enthält %d Mottenkoordinaten. Klicke auf eine Motte, um einen Wegpunkt zu setzen.",
    ["Group 1"] = "Gruppe 1",
    ["Group 2"] = "Gruppe 2",
    ["Group 3"] = "Gruppe 3",
    ["Moths"] = "Motten",
    ["A Singular Problem"] = "Ein singuläres Problem",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "Schließe alle drei Wellen des Sturms auf Stormarion ab. x/y markiert.",
    ["Tracked entries for A Singular Problem have not been added yet."] = "Verfolgte Einträge für Ein singuläres Problem wurden noch nicht hinzugefügt.",
    ["Abundance: Prosperous Plentitude!"] = "Überfluss: Wohlhabende Fülle!",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "Schließe an jedem Ort einen Überreiche-Ernte-Höhlenlauf ab. x/y markiert.",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "Du musst an jedem Ort einen Überreiche-Ernte-Höhlenlauf abschließen, um Fortschritt zu erhalten. Es reicht nicht aus, die Höhle nur zu besuchen.",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "Verfolgte Einträge für Überfluss: Wohlhabende Fülle! wurden noch nicht hinzugefügt.",
    ["Altar of Blessings"] = "Altar der Segnungen",
    ["Trigger each listed blessing effect for credit."] = "Löse jeden aufgeführten Segnungseffekt aus, um Fortschritt zu erhalten.",
    ["Trigger each listed blessing effect. x/y marked."] = "Löse jeden aufgeführten Segnungseffekt aus. x/y markiert.",
    ["Meta achievement summaries"] = "Meta-Erfolgsübersichten",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "Schließe die unten aufgeführten Erfolge im Immersangwald ab. x/y erledigt.",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "Schließe alle unten aufgeführten Erfolge in Voidstorm ab. x/y erledigt.",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "Schließe alle unten aufgeführten Erfolge in Zul'Aman ab. x/y erledigt.",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "Hilf den Hara'ti, indem du die folgenden Erfolge abschließt. x/y erledigt.",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "Sammle deine Streitkräfte gegen Xal'atath, indem du die folgenden Erfolge abschließt. x/y erledigt.",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "Verfolgte Einträge für Making an Amani Out of You wurden noch nicht hinzugefügt.",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "Verfolgte Einträge für That's Aln, Folks! wurden noch nicht hinzugefügt.",
    ["Tracked entries for Forever Song have not been added yet."] = "Verfolgte Einträge für Forever Song wurden noch nicht hinzugefügt.",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "Verfolgte Einträge für Yelling into the Voidstorm wurden noch nicht hinzugefügt.",
    ["Tracked entries for Light Up the Night have not been added yet."] = "Verfolgte Einträge für Light Up the Night wurden noch nicht hinzugefügt.",
    ["Mount: Brilliant Petalwing"] = "Reittier: Prächtiger Blütenflügler",
    ["Housing Decor: On'ohia's Call"] = "Wohnungsdekor: On'ohias Ruf",
    ["Title: \"Dustlord\""] = "Titel: „Staubfürst“",
    ["Title: \"Chronicler of the Haranir\""] = "Titel: „Chronist der Haranir“",
    ["home reward labels:"] = "Heim-Belohnungsbezeichnungen:",
}

L["Raid resync unavailable."] = "Raid-Neusynchronisierung nicht verfügbar."
L["Time played messages will be suppressed."] = "Spielzeitmeldungen werden unterdrückt."
L["Time played messages restored."] = "Spielzeitmeldungen wiederhergestellt."
L["%dm %02ds"] = "%d Min. %02d Sek."
L["Crests:"] = "Wappen:"
L["Mount Drops"] = "Reittierbeute"
L["(Collected)"] = "(Gesammelt)"
L["(Uncollected)"] = "(Nicht gesammelt)"
L["Mounts: %d/%d"] = "Reittiere: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Reittiere: %d/%d"
L["The Voidspire"] = "Die Leerennadel"
L["The Dreamrift"] = "Der Traumriss"
L["March of Quel'Danas"] = "Marsch auf Quel'Danas"
L["Raid Progression"] = "Schlachtzugsfortschritt"
L["Lady Liadrin Weekly"] = "Wöchentlich: Lady Liadrin"
L["Change Log"] = "Änderungsprotokoll"
L["Back"] = "Zurück"
L["Warband Bank"] = "Kriegsmeutenbank"
L["Treatise"] = "Abhandlung"
L["Artisan"] = "Handwerker"
L["Catch-up"] = "Aufholmechanik"
L["LiteVault Update Summary"] = "LiteVault-Updateübersicht"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Mehrere zentrale UI-Elemente wurden überarbeitet, darunter das Währungssymbol, das Schlachtzugssymbol, die Berufe-Leiste und die Verfolgung der Großen Schatzkammer."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "Die Anzeige der Gegenstandsstufe in der Schatzkammer wurde angepasst, damit sie Blizzards standardmäßiger Darstellung der Großen Schatzkammer stärker entspricht."
L["Added a large batch of new translations across supported locales."] = "Eine große Anzahl neuer Übersetzungen für unterstützte Sprachen wurde hinzugefügt."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "Die Darstellung und Aktualisierung lokalisierter Texte im gesamten Addon wurde verbessert."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "Die Lokalisierungsunterstützung für Schaltflächen, Taschentabs, Wochentexte und weitere UI-Bezeichnungen wurde aktualisiert."
L["Fixed multiple localization-related layout issues."] = "Mehrere lokalisierungsbezogene Layoutprobleme wurden behoben."
L["Fixed several localization-related crash issues."] = "Mehrere lokalisierungsbezogene Absturzprobleme wurden behoben."

-- Register this locale
lv.RegisterLocale("deDE", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["deDE"] = L




