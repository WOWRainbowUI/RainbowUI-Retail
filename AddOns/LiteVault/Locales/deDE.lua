-- deDE.lua - German locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",

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
    TAB_TRACKERS = "Tracker",
    TAB_META_ACHIEVEMENTS = "Meta-Erfolge",
    TEXT_FOLIO_NODE_FMT = "Knoten %d",
    TEXT_GEAR_TITLE_FMT = "%s – %s",
    LABEL_GEAR_CRIT = "Krit",
    LABEL_GEAR_HASTE = "Tempo",
    LABEL_GEAR_MASTERY = "Meisterschaft",
    LABEL_GEAR_VERS = "Vielseitigkeit",
    TEXT_GEAR_ILVL_COLORED_FMT = "Gegenstandsstufe |c%s%d|r",
    STATUS_LIVE = "[LIVE]",
    STATUS_CACHED = "[ZWISCHENGESPEICHERT]",
    STATUS_STALE = "[VERALTET]",
    TAB_OVERVIEW = "Übersicht",
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
    LABEL_WEEKLY_COMPLETION_SUMMARY = "%d / %d abgeschlossen",
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
    TOOLTIP_VOIDSHARDS_TITLE = "Aufgestiegene Leerensplitter",
    TOOLTIP_VOIDCORES_TITLE = "Aufgestiegene Leerenkerne",

    TOOLTIP_VAULT_TITLE = "Die Große Schatzkammer",
    TOOLTIP_VAULT_DESC = "Klicken um die Große Schatzkammer zu öffnen",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Die Große Schatzkammer öffnen.",
    TOOLTIP_VAULT_ALT_ONLY = "Die Große Schatzkammer kann nur für den aktiven Charakter geöffnet werden.",

    TOOLTIP_CURRENCY_TITLE = "Abzeichen & Währungen",
    TOOLTIP_CURRENCY_DESC = "Klicken für vollständige Liste.",

    TOOLTIP_BAGS_TITLE = "Taschen anzeigen",
    TOOLTIP_BAGS_DESC = "Gespeicherte Taschen- und Reagenzieninhalt anzeigen.",

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
    TITLE_RAID_FORMAT = "%ss %s %s",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Heroisch",
    DIFFICULTY_MYTHIC = "Mythisch",

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
    ["Überfluss"] = "Überfluss",
    ["Legends of the Haranir"] = "Legenden der Haranir",
    ["Darkness Unmade"] = "Ungefertigte Dunkelheit",
    ["Harvesting the Void"] = "Ernte der Leere",
    ["Midnight: Saltheril's Soiree"] = "Mitternacht: Saltherils Soiree",
    ["Runensteine stärken: Blutritter"] = "Runensteine stärken: Blutritter",
    ["Runensteine stärken: Schatten der Gasse"] = "Runensteine stärken: Schatten der Gasse",
    ["Runensteine stärken: Magister"] = "Runensteine stärken: Magister",
    ["Runensteine stärken: Weltenwanderer"] = "Runensteine stärken: Weltenwanderer",
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
    ["Kräuterkunde"] = "Kräuterkunde",
    ["Mining"] = "Bergbau",
    ["Kürschnerei"] = "Kürschnerei",

    ["Überrest der Qual"] = "Überrest der Qual",
    ["Shard of Dundun"] = "Splitter von Dundun",
    ["Abenteurer-Dämmerwappen"] = "Abenteurer-Dämmerwappen",
    ["Veteranen-Dämmerwappen"] = "Veteranen-Dämmerwappen",
    ["Champion-Dämmerwappen"] = "Champion-Dämmerwappen",
    ["Helden-Dämmerwappen"] = "Helden-Dämmerwappen",
    ["Mythisches Dämmerwappen"] = "Mythisches Dämmerwappen",
    ["Prall gefüllte Arkana"] = "Prall gefüllte Arkana",
    ["Würfle"] = "Würfle",
    ["We Need a Refill"] = "Wir brauchen Nachschub",
    ["Lovely Plumage"] = "Liebliches Gefieder",
    ["The Cauldron of Echoes"] = "Der Kessel der Echos",
    ["The Echoless Flame"] = "Die echolose Flamme",
    ["Hidey-Hole"] = "Versteck",
    ["Victorious Stormarion Pinnacle Cache"] = "Siegreiches Sturmarion-Gipfelversteck",
    ["Überquellender Beutel des Überflusses"] = "Überquellender Beutel des Überflusses",
    ["Avid Learner's Supply Pack"] = "Versorgungspaket des eifrigen Lernenden",
    ["Überschüssiger Beutel mit Partygeschenken"] = "Überschüssiger Beutel mit Partygeschenken",
    ["Voidlight Marl"] = "Leerenlichtmergel",
    ["Untermünze"] = "Untermünze",
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
    BUTTON_PROFIT = "Gewinn",
    LABEL_PROFIT_GOALS = "Kriegsmeuten-Ziele",
    LABEL_WEEKLY_GOAL = "Wochenziel",
    LABEL_MONTHLY_GOAL = "Monatsziel",
    BUTTON_EDIT = "Bearbeiten",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "Höchster Nettogewinn in dieser Zurücksetzung.",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "Bester Nettogewinn im aktuellen Monat.",
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
    ["Schlüsselstein-Splitter"] = "Schlüsselstein-Splitter",
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
    ["Schätze von Midnight"] = "Schätze von Midnight",
    ["Schließe „Ruhm des Midnight-Tiefenforschers“ ab, um dieses Reittier zu erhalten."] = "Schließe „Ruhm des Midnight-Tiefenforschers“ ab, um dieses Reittier zu erhalten.",
    ["Schließe die fünf Teleskope in dieser Zone ab."] = "Schließe die fünf Teleskope in dieser Zone ab.",
    ["Schließe alle vier unterstützenden Midnight-Tiefenforscher-Erfolge ab, um diesen Meta-Erfolg abzuschließen."] = "Schließe alle vier unterstützenden Midnight-Tiefenforscher-Erfolge ab, um diesen Meta-Erfolg abzuschließen.",
    ["Crimson Dragonhawk"] = "Karmesinroter Drachenfalke",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Reward"] = "Belohnung",
    ["Info"] = "Info",
    ["Zurück zu den Gruppen"] = "Zurück zu den Gruppen",
    ["Unknown"] = "Unbekannt",
    ["Item"] = "Gegenstand",
    ["Keine Erfolgsbelohnung aufgeführt."] = "Keine Erfolgsbelohnung aufgeführt.",
    ["Click to set waypoint."] = "Klicken, um einen Wegpunkt zu setzen.",
    ["Klicken, um diesen Tracker zu öffnen."] = "Klicken, um diesen Tracker zu öffnen.",
    ["Tracker noch nicht hinzugefügt."] = "Tracker noch nicht hinzugefügt.",
    ["Schließe hier den Höhlenlauf ab, um Fortschritt zu erhalten."] = "Schließe hier den Höhlenlauf ab, um Fortschritt zu erhalten.",
    ["Immerwährende Malerei"] = "Immerwährende Malerei",
    ["Verfolge die bekannten Leinwände von Ever-Painting. x/y markiert."] = "Verfolge die bekannten Leinwände von Ever-Painting. x/y markiert.",
    ["Verfolgte Einträge für Ever-Painting wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Ever-Painting wurden noch nicht hinzugefügt.",
    ["Verfolge die bekannten Einträge für Runestone Rush. x/y markiert."] = "Verfolge die bekannten Einträge für Runestone Rush. x/y markiert.",
    ["Verfolgte Einträge für Runestone Rush wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Runestone Rush wurden noch nicht hinzugefügt.",
    ["Verfolge die vier Fraktionseinladungen für Die Party muss weitergehen. x/y markiert."] = "Verfolge die vier Fraktionseinladungen für Die Party muss weitergehen. x/y markiert.",
    ["Verfolgte Einträge für Die Party muss weitergehen wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Die Party muss weitergehen wurden noch nicht hinzugefügt.",
    ["Explore trackers"] = "Erkundungs-Tracker",
    ["Verfolge den Fortschritt für Erkundet Immersangwald. x/y markiert."] = "Verfolge den Fortschritt für Erkundet Immersangwald. x/y markiert.",
    ["Verfolgte Einträge für Erkundet Immersangwald wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Erkundet Immersangwald wurden noch nicht hinzugefügt.",
    ["Verfolge den Fortschritt für Erkundet Voidstorm. x/y markiert."] = "Verfolge den Fortschritt für Erkundet Voidstorm. x/y markiert.",
    ["Verfolgte Einträge für Erkundet Voidstorm wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Erkundet Voidstorm wurden noch nicht hinzugefügt.",
    ["Verfolge den Fortschritt für Erkundet Zul'Aman. x/y markiert."] = "Verfolge den Fortschritt für Erkundet Zul'Aman. x/y markiert.",
    ["Verfolgte Einträge für Erkundet Zul'Aman wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Erkundet Zul'Aman wurden noch nicht hinzugefügt.",
    ["Verfolge den Fortschritt für Erkundet Harandar. x/y markiert."] = "Verfolge den Fortschritt für Erkundet Harandar. x/y markiert.",
    ["Verfolgte Einträge für Erkundet Harandar wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Erkundet Harandar wurden noch nicht hinzugefügt.",
    ["Thrill of the Chase"] = "Nervenkitzel der Jagd",
    ["Entkomme dem Griff der Hungernden Präsenz in Voidstorm für mindestens 60 Sekunden."] = "Entkomme dem Griff der Hungernden Präsenz in Voidstorm für mindestens 60 Sekunden.",
    ["Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Überlebe das Ereignis der Hungernden Präsenz in Voidstorm für mindestens 60 Sekunden."] = "Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Überlebe das Ereignis der Hungernden Präsenz in Voidstorm für mindestens 60 Sekunden.",
    ["Verfolgte Einträge für Nervenkitzel der Jagd wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Nervenkitzel der Jagd wurden noch nicht hinzugefügt.",
    ["Keine Zeit für Pfoten"] = "Keine Zeit für Pfoten",
    ["Schließe die Harandar-Weltquest „Pfotenrecht“ mit 15 oder mehr Stapeln von „Jagd des Jägers“ ab."] = "Schließe die Harandar-Weltquest „Pfotenrecht“ mit 15 oder mehr Stapeln von „Jagd des Jägers“ ab.",
    ["Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Schließe die Harandar-Weltquest „Pfotenrecht“ mit 15 oder mehr Stapeln von „Jagd des Jägers“ ab."] = "Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Schließe die Harandar-Weltquest „Pfotenrecht“ mit 15 oder mehr Stapeln von „Jagd des Jägers“ ab.",
    ["Verfolgte Einträge für Keine Zeit für Pfoten wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Keine Zeit für Pfoten wurden noch nicht hinzugefügt.",
    ["Versuche, zur Wiege hoch am Himmel über Harandar zu fliegen."] = "Versuche, zur Wiege hoch am Himmel über Harandar zu fliegen.",
    ["Fliege in die Wiege hoch am Himmel über Harandar, um diesen Erfolg abzuschließen."] = "Fliege in die Wiege hoch am Himmel über Harandar, um diesen Erfolg abzuschließen.",
    ["Diese Journale sind nur während der Wochenquest „Legenden der Haranir“ verfügbar. Suche während einer Vision auf deiner Minikarte nach dem Lupensymbol."] = "Diese Journale sind nur während der Wochenquest „Legenden der Haranir“ verfügbar. Suche während einer Vision auf deiner Minikarte nach dem Lupensymbol.",
    ["Finde die unten aufgeführten Haranir-Journaleinträge wieder."] = "Finde die unten aufgeführten Haranir-Journaleinträge wieder.",
    ["Finde die unten aufgeführten Haranir-Journaleinträge wieder. x/y markiert."] = "Finde die unten aufgeführten Haranir-Journaleinträge wieder. x/y markiert.",
    ["Dies ist an die Wochenquest „Legenden der Haranir“ gebunden. Wenn du noch keinen Fortschritt hast, dauert es schätzungsweise etwa 7 Wochen bis zum Abschluss."] = "Dies ist an die Wochenquest „Legenden der Haranir“ gebunden. Wenn du noch keinen Fortschritt hast, dauert es schätzungsweise etwa 7 Wochen bis zum Abschluss.",
    ["Verteidige jeden unten aufgeführten Ort der Haranir-Legenden."] = "Verteidige jeden unten aufgeführten Ort der Haranir-Legenden.",
    ["Beschütze jeden unten aufgeführten Ort der Haranir-Legenden. x/y markiert."] = "Beschütze jeden unten aufgeführten Ort der Haranir-Legenden. x/y markiert.",
    ["Koordinatengruppen wurden noch nicht hinzugefügt."] = "Koordinatengruppen wurden noch nicht hinzugefügt.",
    ["Dieser Tracker ist in 3 Gruppen mit je 40 Koordinaten aufgeteilt, damit die Mottenrouten überschaubar bleiben."] = "Dieser Tracker ist in 3 Gruppen mit je 40 Koordinaten aufgeteilt, damit die Mottenrouten überschaubar bleiben.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Motten 41-80 erscheinen bei Hara'ti-Ruhm 4, Verfolgung ab Ruhm 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Motten 81-120 erscheinen bei Hara'ti-Ruhm 9, Verfolgung ab Ruhm 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "Die LiteVault-Routen gehen davon aus, dass du Hara'ti-Ruhm 11 bereits freigeschaltet hast.",
    ["%s enthält %d Mottenkoordinaten. Klicke auf eine Motte, um einen Wegpunkt zu setzen."] = "%s enthält %d Mottenkoordinaten. Klicke auf eine Motte, um einen Wegpunkt zu setzen.",
    ["Group 1"] = "Gruppe 1",
    ["Group 2"] = "Gruppe 2",
    ["Group 3"] = "Gruppe 3",
    ["Ein singuläres Problem"] = "Ein singuläres Problem",
    ["Schließe alle drei Wellen des Sturms auf Stormarion ab. x/y markiert."] = "Schließe alle drei Wellen des Sturms auf Stormarion ab. x/y markiert.",
    ["Verfolgte Einträge für Ein singuläres Problem wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Ein singuläres Problem wurden noch nicht hinzugefügt.",
    ["Überfluss: Wohlhabende Fülle!"] = "Überfluss: Wohlhabende Fülle!",
    ["Schließe an jedem Ort einen Überreiche-Ernte-Höhlenlauf ab. x/y markiert."] = "Schließe an jedem Ort einen Überreiche-Ernte-Höhlenlauf ab. x/y markiert.",
    ["Du musst an jedem Ort einen Überreiche-Ernte-Höhlenlauf abschließen, um Fortschritt zu erhalten. Es reicht nicht aus, die Höhle nur zu besuchen."] = "Du musst an jedem Ort einen Überreiche-Ernte-Höhlenlauf abschließen, um Fortschritt zu erhalten. Es reicht nicht aus, die Höhle nur zu besuchen.",
    ["Verfolgte Einträge für Überfluss: Wohlhabende Fülle! wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Überfluss: Wohlhabende Fülle! wurden noch nicht hinzugefügt.",
    ["Altar of Blessings"] = "Altar der Segnungen",
    ["Löse jeden aufgeführten Segnungseffekt aus, um Fortschritt zu erhalten."] = "Löse jeden aufgeführten Segnungseffekt aus, um Fortschritt zu erhalten.",
    ["Löse jeden aufgeführten Segnungseffekt aus. x/y markiert."] = "Löse jeden aufgeführten Segnungseffekt aus. x/y markiert.",
    ["Meta-Erfolgsübersichten"] = "Meta-Erfolgsübersichten",
    ["Schließe die unten aufgeführten Erfolge im Immersangwald ab. x/y erledigt."] = "Schließe die unten aufgeführten Erfolge im Immersangwald ab. x/y erledigt.",
    ["Schließe alle unten aufgeführten Erfolge in Voidstorm ab. x/y erledigt."] = "Schließe alle unten aufgeführten Erfolge in Voidstorm ab. x/y erledigt.",
    ["Schließe alle unten aufgeführten Erfolge in Zul'Aman ab. x/y erledigt."] = "Schließe alle unten aufgeführten Erfolge in Zul'Aman ab. x/y erledigt.",
    ["Hilf den Hara'ti, indem du die folgenden Erfolge abschließt. x/y erledigt."] = "Hilf den Hara'ti, indem du die folgenden Erfolge abschließt. x/y erledigt.",
    ["Sammle deine Streitkräfte gegen Xal'atath, indem du die folgenden Erfolge abschließt. x/y erledigt."] = "Sammle deine Streitkräfte gegen Xal'atath, indem du die folgenden Erfolge abschließt. x/y erledigt.",
    ["Verfolgte Einträge für Making an Amani Out of You wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Making an Amani Out of You wurden noch nicht hinzugefügt.",
    ["Verfolgte Einträge für That's Aln, Folks! wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für That's Aln, Folks! wurden noch nicht hinzugefügt.",
    ["Verfolgte Einträge für Forever Song wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Forever Song wurden noch nicht hinzugefügt.",
    ["Verfolgte Einträge für Yelling into the Voidstorm wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Yelling into the Voidstorm wurden noch nicht hinzugefügt.",
    ["Verfolgte Einträge für Light Up the Night wurden noch nicht hinzugefügt."] = "Verfolgte Einträge für Light Up the Night wurden noch nicht hinzugefügt.",
    ["Reittier: Prächtiger Blütenflügler"] = "Reittier: Prächtiger Blütenflügler",
    ["Titel: „Staubfürst“"] = "Titel: „Staubfürst“",
    ["Titel: „Chronist der Haranir“"] = "Titel: „Chronist der Haranir“",
    ["home reward labels:"] = "Heim-Belohnungsbezeichnungen:",
}

L["Raid-Neusynchronisierung nicht verfügbar."] = "Raid-Neusynchronisierung nicht verfügbar."
L["Spielzeitmeldungen werden unterdrückt."] = "Spielzeitmeldungen werden unterdrückt."
L["Time played messages restored."] = "Spielzeitmeldungen wiederhergestellt."
L["%dm %02ds"] = "%d Min. %02d Sek."
L["LABEL_MOUNTS_FMT"] = "Reittiere: %d/%d"
L["The Voidspire"] = "Die Leerennadel"
L["The Dreamrift"] = "Der Traumriss"
L["March of Quel'Danas"] = "Marsch auf Quel'Danas"
L["Raid Progression"] = "Schlachtzugsfortschritt"
L["Wöchentlich: Lady Liadrin"] = "Wöchentlich: Lady Liadrin"
L["Änderungsprotokoll"] = "Änderungsprotokoll"
L["Zurück"] = "Zurück"
L["Warband Bank"] = "Kriegsmeutenbank"
L["Treatise"] = "Abhandlung"
L["Artisan"] = "Handwerker"
L["Catch-up"] = "Aufholmechanik"
L["LiteVault-Updateübersicht"] = "LiteVault-Updateübersicht"
L["Mehrere zentrale UI-Elemente wurden überarbeitet, darunter das Währungssymbol, das Schlachtzugssymbol, die Berufe-Leiste und die Verfolgung der Großen Schatzkammer."] = "Mehrere zentrale UI-Elemente wurden überarbeitet, darunter das Währungssymbol, das Schlachtzugssymbol, die Berufe-Leiste und die Verfolgung der Großen Schatzkammer."
L["Die Anzeige der Gegenstandsstufe in der Schatzkammer wurde angepasst, damit sie Blizzards standardmäßiger Darstellung der Großen Schatzkammer stärker entspricht."] = "Die Anzeige der Gegenstandsstufe in der Schatzkammer wurde angepasst, damit sie Blizzards standardmäßiger Darstellung der Großen Schatzkammer stärker entspricht."
L["Eine große Anzahl neuer Übersetzungen für unterstützte Sprachen wurde hinzugefügt."] = "Eine große Anzahl neuer Übersetzungen für unterstützte Sprachen wurde hinzugefügt."
L["Die Lokalisierungsunterstützung für Schaltflächen, Taschentabs, Wochentexte und weitere UI-Bezeichnungen wurde aktualisiert."] = "Die Lokalisierungsunterstützung für Schaltflächen, Taschentabs, Wochentexte und weitere UI-Bezeichnungen wurde aktualisiert."

L["Aufschlüsselung"] = "Aufschlüsselung"
L["Kriegsmeuten-Aufschlüsselung"] = "Kriegsmeuten-Aufschlüsselung"
L["Ritualstätten"] = "Ritualstätten"
L["LABEL_MAX_RENOWN"] = "Maximales Renommee"
L["LABEL_PARAGON"] = "Paragon"
L["LABEL_REWARD_FMT"] = "Belohnung: %s"
L["LABEL_REWARD_LOADING"] = "Belohnungsdaten werden geladen..."
L["TOOLTIP_FACTION_CARD_HINT"] = "Klicken, um zu dieser Fraktion zu wechseln."
L["LABEL_GAINED"] = "Erhalten"
L["LABEL_TOP_SOURCES"] = "Top-Quellen"
L["LABEL_TOP_INCOME_SOURCE"] = "Top-Einnahmequelle"
L["LABEL_TOP_EXPENSE_SOURCE"] = "Top-Ausgabequelle"
L["Quellenmix aus den wöchentlichen Einnahmen und Ausgaben eurer Kriegsmeute."] = "Quellenmix aus den wöchentlichen Einnahmen und Ausgaben eurer Kriegsmeute."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "Womit eure Kriegsmeute diese Woche am meisten Gold verdient hat."
L["Wofür eure Kriegsmeute diese Woche am meisten Gold ausgegeben hat."] = "Wofür eure Kriegsmeute diese Woche am meisten Gold ausgegeben hat."
L["MSG_PROFIT_NO_INCOME"] = "Noch keine Einnahmen aufgezeichnet."
L["MSG_PROFIT_NO_SPENDING"] = "Noch keine Ausgaben aufgezeichnet."
L["MSG_NO_GOLD_WORLD_QUESTS"] = "Keine aktiven Gold-Weltquests gefunden."
L["LEDGER_WORLD_QUESTS"] = "Weltquests"
L["LEDGER_UPGRADE"] = "Aufwertung"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "Runenstein-Kartenmarkierungen deaktivieren"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "Blendet LiteVaults Runenstein-Markierungen auf der Karte des Immersangwalds aus."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "Kalender-Gewinnhervorhebungen aktivieren"
L["Zeigt grüne und rote Gewinn-Tageshervorhebungen im Kalender an."] = "Zeigt grüne und rote Gewinn-Tageshervorhebungen im Kalender an."
L["Nächste Woche: %s"] = "Nächste Woche: %s"
L["LABEL_MONTHLY_PROFIT"] = "Monatsgewinn"
L["LABEL_TOP_WEEKLY_EARNERS"] = "Top-Wochenverdiener"
L["LABEL_TOP_MONTHLY_EARNERS"] = "Top-Monatsverdiener"

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
L["LABEL_HISTORY_COUNT"] = "Anzahl Verlaufseinträge"
L["LABEL_LAST_UPDATED"] = "Last Updated"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_TOKEN_AFFORDABLE"] = "Erschwinglich"
L["LABEL_TOKEN_DELTA"] = "Differenz"
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
L["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = "WoW-Marke gekauft"
L["TEXT_PROFIT_ITEM_FALLBACK_FMT"] = "Gegenstand %d"
L["TEXT_PROFIT_GOALS_SUBTITLE"] = "Wöchentliche und monatliche Nettogewinnziele für deine Kriegsmeute."
L["TEXT_PROFIT_GOAL_EDITOR_HINT"] = "Gib ein Ziel in Gold ein. Leer lassen oder 0 eingeben, um es zu löschen."
L["TEXT_PROFIT_GRAPH_EMPTY_MONTHLY"] = "No monthly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND"] = "No warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY"] = "No monthly warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"] = "No weekly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_PENDING_MONTHLY"] = "Der monatliche Diagrammverlauf wird jetzt erfasst und füllt sich, sobald du Gold verdienst oder ausgibst."
L["TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"] = "Der monatliche Diagrammverlauf der Kriegsmeute wird jetzt erfasst und füllt sich, sobald Goldänderungen aufgezeichnet werden."
L["TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"] = "No monthly ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WARBAND"] = "No warband ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"] = "No weekly ledger transactions recorded yet."
L["TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"] = "Täglicher Nettogewinn des aktuellen Charakters in diesem Monat. Neue Daten erscheinen, sobald Goldänderungen aufgezeichnet werden."
L["TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"] = "Neueste monatliche Transaktionen des aktuellen Charakters."
L["TEXT_PROFIT_SUBTITLE"] = "Weekly and monthly profit across your tracked characters."
L["TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"] = "Täglicher Gesamtgewinn aller erfassten Charaktere in den letzten 7 Tagen."
L["TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"] = "Neueste zusammengefasste Wochentransaktionen aller erfassten Charaktere."
L["TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"] = "Täglicher Gesamtgewinn aller erfassten Charaktere in diesem Monat."
L["TEXT_PROFIT_SOURCE_AH_FEE"] = "Auktionshausgebühr"
L["TEXT_PROFIT_SOURCE_BLACK_MARKET"] = "Black Market"
L["TEXT_PROFIT_SOURCE_CHEST"] = "Chest"
L["TEXT_PROFIT_SOURCE_CRAFT"] = "Craft"
L["TEXT_PROFIT_SOURCE_FLIGHT_PATH"] = "Flight Path"
L["TEXT_PROFIT_SOURCE_GUILD_BANK"] = "Guild Bank"
L["TEXT_PROFIT_SOURCE_LOOTED"] = "Looted"
L["TEXT_PROFIT_SOURCE_REPAIR"] = "Repair"
L["TEXT_PROFIT_SOURCE_TRAINING"] = "Training"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "Täglicher Nettogewinn des aktuellen Charakters in den letzten 7 Tagen."
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "Neueste Wochentransaktionen des aktuellen Charakters."
L["TEXT_TRACKED_ACHIEVEMENT_ENTRIES_UNAVAILABLE_FMT"] = "Für %s wurden noch keine verfolgten Einträge hinzugefügt."
L["TIME_DAYS_AGO_FMT"] = "vor %d T."
L["TIME_HOURS_AGO_FMT"] = "vor %d Std."
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "vor %d Min."
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
L["TEXT_PROFIT_TOKENS_THIS_MONTH_FMT"] = "Marken in diesem Monat: %d"
L["TITLE_PROFIT_WOW_TOKENS_THIS_MONTH"] = "WoW-Marken in diesem Monat"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_PROFIT_WOW_TOKENS_THIS_MONTH"] = "Zählt die im aktuellen Kalendermonat gekauften WoW-Marken. Markenkäufe werden nicht in die Gewinnsummen einbezogen."
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
L["Discover all of the lore objects found on the Coiled Isle."] = "Entdecke alle Wissensobjekte von Coiled Isle."
L["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s enthält %d Mottenkoordinaten. Klicke auf eine Motte, um einen Wegpunkt zu setzen."
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
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "Quellenverteilung der wöchentlichen Einnahmen und Ausgaben eurer Kriegsmeute."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "Wofür eure Kriegsmeute diese Woche am meisten Gold ausgegeben hat."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"] = "Show green and red profit-day highlights on the calendar."
L["Void Strike"] = "Void Strike"
L["Void Assaults"] = "Void Assaults"
L["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods"
L["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman"
L["LABEL_NEXT_WEEK_FMT"] = "Next Week: %s"
L["Abundance Event"] = "Abundance Event"
L["Herbalism"] = "Herbalism"
L["Skinning"] = "Skinning"
L["Remnant of Anguish"] = "Remnant of Anguish"
L["Brimming Arcana"] = "Brimming Arcana"
L["Undercoin"] = "Undercoin"
L["Coffer Key Shards"] = "Coffer Key Shards"
L["Adventurer Dawncrest"] = "Adventurer Dawncrest"
L["Veteran Dawncrest"] = "Veteran Dawncrest"
L["Champion Dawncrest"] = "Champion Dawncrest"
L["Hero Dawncrest"] = "Hero Dawncrest"
L["Myth Dawncrest"] = "Myth Dawncrest"
L["Raid resync unavailable."] = "Raid resync unavailable."
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Lady Liadrin Weekly"] = "Wöchentlich: Lady Liadrin"
L["Back"] = "Back"

L["LABEL_CHARACTER"] = "Character"


L["Ever-Painting"] = "Ever-Painting"
L["Midnight, the Highest Peaks"] = "Midnight, the Highest Peaks"
L["Explore Eversong Woods"] = "Explore Eversong Woods"
L["Explore Voidstorm"] = "Explore Voidstorm"
L["Explore Zul'Aman"] = "Explore Zul'Aman"
L["Explore Harandar"] = "Explore Harandar"
L["Making an Amani Out of You"] = "Making an Amani Out of You"
L["That's Aln, Folks!"] = "That's Aln, Folks!"
L["Forever Song"] = "Forever Song"
L["Yelling into the Voidstorm"] = "Yelling into the Voidstorm"
L["Light Up the Night"] = "Light Up the Night"
L["Altar of Blessings: Sacred Buffet Devotee"] = "Altar of Blessings: Sacred Buffet Devotee"

-- Register this locale
L["LABEL_FIRST_KILL"] = "Erster Sieg:"
L["LABEL_EARLIEST_RECORDED_KILL"] = "Frühester erfasster Sieg:"
L["TEXT_HISTORICAL_DATA_UNAVAILABLE"] = "Historische Daten nicht verfügbar"
L["LABEL_KNOWN_KILLS"] = "Bekannte Siege:"
L["LABEL_ALSO_KILLED_BY"] = "Außerdem besiegt von:"
L["TEXT_KILL_DATE_UNAVAILABLE"] = "Siegesdatum nicht verfügbar"

L["BUTTON_ZULJARRA_FORCES"] = "Zul'jarra's Forces"
L["BUTTON_CAPTAIN_TOKKA"] = "Kapitän Tokka"
L["LABEL_VALEERA_SANGUINAR"] = "Valeera Sanguinar"
L["LABEL_SLAYERS_DUELLUM"] = "Slayer's Duellum"
L["LABEL_MAXIMUM"] = "Maximum"
L["BUTTON_FACTION_WEEKLIES"] = "Faction Weeklies"
L["TITLE_TREASURES_OF_THE_DAMNED"] = "Treasures of the Damned"
L["LABEL_COMPLETED"] = "Completed"
L["LABEL_NOT_COMPLETED"] = "Not Completed"
L["LABEL_QUEST_FMT"] = "Aufgabe: %s"
L["LABEL_QUEST_ID_FMT"] = "Quest-ID: %d"
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
L.LABEL_CURRENT_CHARACTER = L.LABEL_CURRENT_CHARACTER or "Aktueller Charakter"
L.LABEL_WARBAND_THIS_WEEK = L.LABEL_WARBAND_THIS_WEEK or "Kriegsmeute diese Woche"
L.LABEL_RUNS = L.LABEL_RUNS or "Läufe"
L.STATUS_TIMED = L.STATUS_TIMED or "Im Zeitlimit"
L.STATUS_DEPLETED = L.STATUS_DEPLETED or "Abgelaufen"
L.LABEL_BEST_TIMED = L.LABEL_BEST_TIMED or "Bester Lauf im Zeitlimit"
L.FILTER_THIS_WEEK = L.FILTER_THIS_WEEK or "Diese Woche"
L.FILTER_SEASON = L.FILTER_SEASON or "Saison"
L.FILTER_ALL_HISTORY = L.FILTER_ALL_HISTORY or "Gesamter Verlauf"
L.SECTION_SEASON_BESTS = L.SECTION_SEASON_BESTS or "Saisonbestleistungen"
L.LABEL_BEST = L.LABEL_BEST or "Beste"
L.LABEL_SCORE = L.LABEL_SCORE or "Wertung"
L.LABEL_NO_RUN = L.LABEL_NO_RUN or "Kein Lauf"
L.LABEL_LOWEST_SCORE = L.LABEL_LOWEST_SCORE or "Niedrigste Wertung"
L.LABEL_NO_MPLUS_KEY = L.LABEL_NO_MPLUS_KEY or "Kein M+ Schlüssel"
L.LABEL_DUNGEON = L.LABEL_DUNGEON or "Dungeon"
L.LABEL_KEY = L.LABEL_KEY or "Schlüssel"
L.LABEL_RESULT = L.LABEL_RESULT or "Ergebnis"
L.LABEL_TIME = L.LABEL_TIME or "Zeit"
L.LABEL_DATE = L.LABEL_DATE or "Datum"
L.LABEL_REWARDS = L.LABEL_REWARDS or "Belohnungen"
L.LABEL_MAP_RECORD = L.LABEL_MAP_RECORD or "Kartenrekord"
L.LABEL_AFFIX_RECORD = L.LABEL_AFFIX_RECORD or "Affixrekord"
L.LABEL_MPLUS_SCORE_PLAIN = L.LABEL_MPLUS_SCORE_PLAIN or "M+ Wertung"
L.LABEL_TIMER = L.LABEL_TIMER or "Zeitlimit"
L.LABEL_TIME_REMAINING = L.LABEL_TIME_REMAINING or "Verbleibende Zeit"
L.LABEL_OVER_TIMER = L.LABEL_OVER_TIMER or "Über dem Zeitlimit"
L.LABEL_RECORDED_DURATION = L.LABEL_RECORDED_DURATION or "Aufgezeichnete Dauer"
L.LABEL_NOT_AVAILABLE = L.LABEL_NOT_AVAILABLE or "--"
L.SECTION_MPLUS_HISTORY = L.SECTION_MPLUS_HISTORY or "Mythisch+-Verlauf"
L.TEXT_NO_MPLUS_RUNS_THIS_WEEK = L.TEXT_NO_MPLUS_RUNS_THIS_WEEK or "Diese Woche wurden keine Mythisch+-Läufe abgeschlossen."
L.TEXT_NO_MPLUS_RUNS_THIS_SEASON = L.TEXT_NO_MPLUS_RUNS_THIS_SEASON or "In dieser Saison wurden keine Mythisch+-Läufe abgeschlossen."
L.TEXT_NO_MPLUS_RUNS_RECORDED = L.TEXT_NO_MPLUS_RUNS_RECORDED or "Keine Mythisch+-Läufe aufgezeichnet."
L.BUTTON_PLAN_RATING = L.BUTTON_PLAN_RATING or "Wertung planen"
L.TITLE_MPLUS_RATING_PLANNER = L.TITLE_MPLUS_RATING_PLANNER or "Mythisch+-Wertungsplaner"
L.BUTTON_BACK_TO_DASHBOARD = L.BUTTON_BACK_TO_DASHBOARD or "Zurück zur Übersicht"
L.LABEL_CURRENT_RATING = L.LABEL_CURRENT_RATING or "Aktuelle Wertung"
L.LABEL_TARGET_RATING = L.LABEL_TARGET_RATING or "Zielwertung"
L.LABEL_MINIMUM_KEY = L.LABEL_MINIMUM_KEY or "Minimaler Schlüssel"
L.LABEL_MAXIMUM_KEY = L.LABEL_MAXIMUM_KEY or "Maximaler Schlüssel"
L.LABEL_AVOID_DUNGEONS = L.LABEL_AVOID_DUNGEONS or "Dungeons vermeiden"
L.BUTTON_CALCULATE_PLAN = L.BUTTON_CALCULATE_PLAN or "Plan berechnen"
L.LABEL_MAXIMUM_PROJECTED_RATING = L.LABEL_MAXIMUM_PROJECTED_RATING or "Maximal erwartete Wertung"
L.LABEL_PROJECTED_RATING = L.LABEL_PROJECTED_RATING or "Erwartete Wertung"
L.LABEL_CURRENT = L.LABEL_CURRENT or "Aktuell"
L.LABEL_PLAN = L.LABEL_PLAN or "Plan"
L.LABEL_GAIN = L.LABEL_GAIN or "Gewinn"
L.TEXT_PLANNER_ALREADY_REACHED = L.TEXT_PLANNER_ALREADY_REACHED or "Diese Wertung wurde bereits erreicht."
L.TEXT_PLANNER_UNREACHABLE = L.TEXT_PLANNER_UNREACHABLE or "Das Ziel ist mit den aktuellen Grenzen nicht erreichbar."
L.TEXT_PLANNER_INVALID_MINIMUM = L.TEXT_PLANNER_INVALID_MINIMUM or "Der minimale Schlüssel muss eine ganze Zahl ab 2 sein."
L.TEXT_PLANNER_INVALID_MAXIMUM = L.TEXT_PLANNER_INVALID_MAXIMUM or "Der maximale Schlüssel muss mindestens dem Minimum entsprechen und darf höchstens 20 sein."
L.TEXT_PLANNER_INVALID_TARGET = L.TEXT_PLANNER_INVALID_TARGET or "Gib eine gültige ganzzahlige Zielwertung ein."
L.TEXT_PLANNER_TIMED_ASSUMPTION = L.TEXT_PLANNER_TIMED_ASSUMPTION or "Die Prognose setzt voraus, dass jeder vorgeschlagene Schlüssel im Zeitlimit abgeschlossen wird."
L.PLANNER_FASTEST = L.PLANNER_FASTEST or "SCHNELLSTE"
L.PLANNER_BALANCED = L.PLANNER_BALANCED or "AUSGEWOGEN"
L.PLANNER_EASIEST = L.PLANNER_EASIEST or "EINFACHSTE"
local phase2 = {
MSG_NO_FACTION_WEEKLY_COMPLETIONS="Keine wöchentlichen Abschlüsse erfasst.", TOOLTIP_QUEST_ID_FMT="ID: |cffffffff%d", CALENDAR_MONTH_YEAR_FMT="%s %d",
LABEL_RENOWN_LEVEL_MAXIMUM_FMT="Ruhmstufe %d – Maximum", LABEL_RENOWN_LEVEL_PROGRESS_FMT="Ruhmstufe %d (%d/%d)", LABEL_RENOWN_LEVEL_FMT="Ruhmstufe %d", LABEL_RENOWN_VALUE_FMT="Ruhm %d",
TEXT_CRESTS_WITH_VALUES_FMT="Wappen %s", TOOLTIP_REWARDS_FMT="Belohnungen: %s", TOOLTIP_MOUNT_COLLECTED_FMT="%s (Gesammelt)", TOOLTIP_MOUNT_UNCOLLECTED_FMT="%s (Nicht gesammelt)", LABEL_REWARD="Belohnung", LABEL_NOTE="Hinweis", STATUS_ACTIVE="Aktiv",
TOOLTIP_ENTRANCE_COORDINATES_FMT="Eingang: %.2f, %.2f (Karte %d)", TOOLTIP_INSCRIPTION_COORDINATES_FMT="Inschrift: %.2f, %.2f (Karte %d)", TOOLTIP_ENTRANCE_INSCRIPTION_CLICK_INSTRUCTIONS="Umschalt-Klick für den Eingang; Klick für die Inschrift.", LABEL_100_RENOWN_FMT="100 Ruhm: %s", TOOLTIP_ACHIEVEMENT_CREDIT_FROM_FMT="Erfolgskredit durch: %s",
NOTE_HARANDAR_TREASURE_REQUIREMENTS="Einige Schätze erfordern zusätzliche Schritte oder Gegenstände.", NOTE_FORGOTTEN_MASK_LOCATION="An einer beschädigten Steinmauer auf der Insel Gnarldor, südlich des Tiefeneingangs.", NOTE_HEAD_MASONS_TABLET_LOCATION="Im Tor des Östlichen Fangzahns. Eingang: 45.72, 64.94 auf Karte 2512.", NOTE_PROFANED_PLAQUE_LOCATION="Im Tor des Westlichen Fangzahns, im Raum direkt links nach dem Eingang. Eingang: 31.80, 64.91 auf Karte 2512.",
BUTTON_CANCEL="Abbrechen", BUTTON_SAVE="Speichern", BUTTON_SELECT_ALL="Alle auswählen", LABEL_COMPLETED="Abgeschlossen", LABEL_NOT_COMPLETED="Nicht abgeschlossen", LABEL_DETAILS="Details", LABEL_DETAIL="Detail", LABEL_INFO="Info", LABEL_MAXIMUM="Maximum", LABEL_PREVIOUS="Vorherige", LABEL_RECENT_HISTORY="Letzter Verlauf", LABEL_SOURCE="Quelle", LABEL_STATUS="Status", TIME_JUST_NOW="Gerade eben", TIME_YESTERDAY="Gestern",
BUTTON_BACK_TO_GROUPS="Zurück zu den Gruppen", TEXT_COORDINATE_GROUPS_NOT_AVAILABLE="Koordinatengruppen wurden noch nicht hinzugefügt.", TEXT_ZONE_REWARD_NOT_AVAILABLE="Zonenbelohnung noch nicht hinzugefügt.", TEXT_META_REWARD_NOT_AVAILABLE="Meta-Belohnung noch nicht hinzugefügt.", TEXT_ACHIEVEMENT_REWARD_NOT_LISTED="Keine Erfolgsbelohnung aufgeführt.", TOOLTIP_RUNESTONE_CHARGE_INSTRUCTION="Lade den Runenstein mit latenter Arkana auf, um sein Verteidigungsereignis zu starten.", TEXT_COORDINATES_PENDING="Koordinaten ausstehend.", TOOLTIP_CLICK_OPEN_TRACKER="Klicken, um diesen Tracker zu öffnen.", TEXT_TRACKER_NOT_AVAILABLE="Tracker noch nicht hinzugefügt.",
MSG_PROFIT_GOAL_INVALID="Gib einen gültigen Goldbetrag ein.", MSG_PROFIT_GOAL_NOT_SET="Kein Ziel festgelegt", TEXT_PROFIT_EXPORT_HINT="Klicke in das Feld und drücke Strg+C zum Kopieren.", TEXT_PROFIT_EXPORT_SUBTITLE="Kopiere den folgenden CSV-Text.", TEXT_PROFIT_SOURCE_BLACK_MARKET="Schwarzmarkt", TEXT_PROFIT_SOURCE_CHEST="Truhe", TEXT_PROFIT_SOURCE_CRAFT="Herstellung", TEXT_PROFIT_SOURCE_FLIGHT_PATH="Flugpunkt", TEXT_PROFIT_SOURCE_GUILD_BANK="Gildenbank", TEXT_PROFIT_SOURCE_LOOTED="Erbeutet", TEXT_PROFIT_SOURCE_REPAIR="Reparatur", TEXT_PROFIT_SOURCE_TRAINING="Ausbildung", TEXT_PROFIT_SOURCE_WORLD_QUEST="Weltquest", MSG_RAID_RESYNC_COMPLETE="Schlachtzugssynchronisierung abgeschlossen.", MSG_RAID_RESYNC_STARTED="Schlachtzugssynchronisierung gestartet...", MSG_RAID_RESYNC_UNAVAILABLE="Schlachtzugssynchronisierung nicht verfügbar.",
TEXT_PROFIT_FALLBACK_APPEARANCE_COST="Aussehenskosten", TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT="Auktionskaution", TEXT_PROFIT_FALLBACK_AUCTION_FEE="Auktionsgebühr", TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE="Auktionskauf", TEXT_PROFIT_FALLBACK_AUCTION_SALE="Auktionsverkauf", TEXT_PROFIT_FALLBACK_BARBER_COST="Barbierkosten", TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE="Schwarzmarktkauf", TEXT_PROFIT_FALLBACK_CRAFTING_ORDER="Handwerksauftrag", TEXT_PROFIT_FALLBACK_GEAR_UPGRADE="Ausrüstungsaufwertung", TEXT_PROFIT_FALLBACK_GOLD_RECEIVED="Gold erhalten", TEXT_PROFIT_FALLBACK_GOLD_REWARD="Goldbelohnung", TEXT_PROFIT_FALLBACK_GOLD_SENT="Gold gesendet", TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT="Gildeneinzahlung", TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL="Gildenabhebung", TEXT_PROFIT_FALLBACK_RAW_GOLD="Direktes Gold", TEXT_PROFIT_FALLBACK_SERVICE_COST="Dienstleistungskosten", TEXT_PROFIT_FALLBACK_TRADE_GAIN="Handelsgewinn", TEXT_PROFIT_FALLBACK_TRADE_PAYMENT="Handelszahlung", TEXT_PROFIT_FALLBACK_TRAINING_COST="Ausbildungskosten", TEXT_PROFIT_FALLBACK_TRAVEL_COST="Reisekosten", TEXT_PROFIT_GRAPH_EMPTY_MONTHLY="Noch kein monatlicher Gewinnverlauf aufgezeichnet.", TEXT_PROFIT_GRAPH_EMPTY_WARBAND="Noch kein Gewinnverlauf der Kriegsmeute aufgezeichnet.", TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY="Noch kein monatlicher Gewinnverlauf der Kriegsmeute aufgezeichnet.", TEXT_PROFIT_GRAPH_EMPTY_WEEKLY="Noch kein wöchentlicher Gewinnverlauf aufgezeichnet.", TEXT_PROFIT_LEDGER_EMPTY_MONTHLY="Noch keine monatlichen Hauptbuchtransaktionen aufgezeichnet.", TEXT_PROFIT_LEDGER_EMPTY_WARBAND="Noch keine Hauptbuchtransaktionen der Kriegsmeute aufgezeichnet.", TEXT_PROFIT_LEDGER_EMPTY_WEEKLY="Noch keine wöchentlichen Hauptbuchtransaktionen aufgezeichnet.", TEXT_PROFIT_SUBTITLE="Wöchentlicher und monatlicher Gewinn deiner erfassten Charaktere.",
BUTTON_BREAKDOWN="Aufschlüsselung", BUTTON_FILTER="Filter", BUTTON_SET="Festlegen", BUTTON_RAIDS="Schlachtzüge", BUTTON_WARBAND_BANK_HISTORY="Kriegsmeutenbank-Verlauf", TITLE_TREASURES_OF_THE_DAMNED="Schätze der Verdammten", TOOLTIP_TOKKA_TREASURE_HINT="Angle dieses Artefakt auf Coiled Isle und bringe es zu Second Mate Sluggs in Tokka's Folly zurück.", WARNING_TOKKA_ONE_TIME_ARTIFACTS="Warnung: Diese Artefaktquests sind einmalige Abgaben der Kriegsmeute. Sie werden weder täglich noch wöchentlich zurückgesetzt und gewähren nur einmal Ruf.", MSG_RAID_HISTORY_PRESERVED="Der Schlachtzugsverlauf wurde beibehalten; die destruktive Saisonzurücksetzung ist deaktiviert.", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", TITLE_MINI_OMNIUM_FOLIO="Omniumfoliant", TOOLTIP_HIDE_MINI_FOLIO="Mini-Foliant ausblenden", TOOLTIP_LOCK_MINI_FOLIO="Mini-Foliant sperren", TOOLTIP_UNLOCK_MINI_FOLIO="Mini-Foliant entsperren", TAB_GLYPHS="Glyphen", TITLE_GLYPH_HUNTER="Glyphenjäger", TOOLTIP_RUNESTONE_SET_WAYPOINT="Klicken, um einen Wegpunkt zu setzen.", LABEL_CHARACTER_TIME="Charakterzeit", LABEL_LAST_UPDATED="Zuletzt aktualisiert", LABEL_VAULT_OVERALL_PROGRESS="Gesamtfortschritt: %d/%d", LABEL_VAULT_ROW_DUNGEONS="Dungeons", TITLE_CHARACTER_GREAT_VAULT_FMT="Große Schatzkammer von %s: %s", TITLE_CHARACTER_WEEKLY_PLANNER_FMT="Wochenplaner von %s: %s", LABEL_NEXT_WEEK_FMT="Nächste Woche: %s",
BUTTON_EDIT_MONTHLY_GOAL="Monatsziel bearbeiten", BUTTON_EDIT_WEEKLY_GOAL="Wochenziel bearbeiten", BUTTON_EXPORT_CSV="CSV exportieren", BUTTON_MONTHLY_PROFIT_EXPORT="Monatlicher Gewinn als CSV", BUTTON_WARBAND_PROFIT_BREAKDOWN="Kriegsmeuten-Aufschlüsselung", BUTTON_WARBAND_PROFIT_EXPORT="Wöchentlicher Kriegsmeutengewinn als CSV", BUTTON_WEEKLY_PROFIT_EXPORT="Wöchentlicher Gewinn als CSV", LABEL_GOAL_AMOUNT="Zielbetrag (Gold)", LABEL_GOLD="Gold", LABEL_NET="Netto", LABEL_SHARE="Teilen", LABEL_ZONE="Zone", LABEL_WARBAND_WEEKLY_PROFIT="Wöchentlicher Kriegsmeutengewinn", MSG_NIT_TIMEPLAYED_WARNING="NovaInstanceTracker erkannt. Die /played-Meldung kann von NIT unterdrückt werden, selbst wenn die LiteVault-Option deaktiviert ist.", MSG_TIMEPLAYED_RESTORED="Spielzeitmeldungen wiederhergestellt.", MSG_TIMEPLAYED_SUPPRESSED="Spielzeitmeldungen werden unterdrückt.", MSG_WOW_TOKEN_API_UNAVAILABLE="Die WoW-Token-API ist in diesem Client nicht verfügbar.", MSG_WOW_TOKEN_DATA_UNAVAILABLE="WoW-Token-Daten nicht verfügbar.", MSG_WOW_TOKEN_VISIT_AH="Besuche das Auktionshaus, um den WoW-Token-Preis zu aktualisieren.", OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC="Zeigt grüne und rote Hervorhebungen für Gewinntage im Kalender an.",
TITLE_ACHIEVEMENTS="Erfolge", LABEL_ACHIEVEMENT_GROUPS="Gruppen", LABEL_GLOWING_MOTHS="Motten", LABEL_SHARED_LOOT="Gemeinsame Beute", LABEL_KNOWLEDGE_CATCHUP="Aufholen", STATUS_ASSAULT_WAVE_1_COMPLETE="Welle 1 abgeschlossen", STATUS_ASSAULT_WAVE_2_COMPLETE="Welle 2 abgeschlossen", STATUS_ASSAULT_WAVE_3_COMPLETE="Welle 3 abgeschlossen", TEXT_MIDNIGHT_RARES_TRACKER_DESCRIPTION="Verfolge seltene Midnight-Erfolge, Belohnungen und gemeinsame Beute.", TEXT_MIDNIGHT_TREASURES_TRACKER_DESCRIPTION="Verfolge Midnight-Schatz-Erfolge und ihre Belohnungen.", TEXT_HARANIR_JOURNAL_INSTRUCTION="Berge die unten aufgeführten Haranir-Tagebucheinträge.", TEXT_HARANIR_LEGEND_DEFENSE_INSTRUCTION="Verteidige jeden unten aufgeführten Ort einer Haranir-Legende.", TEXT_BLESSING_EFFECT_INSTRUCTION="Löse jeden aufgeführten Segnungseffekt für die Wertung aus.", TOOLTIP_CAVE_RUN_CREDIT_INSTRUCTION="Schließe den Höhlenlauf hier für die Wertung ab.", TEXT_TELESCOPE_ZONE_REQUIREMENT="Schließe die fünf Teleskope in dieser Zone ab.",
TEXT_MIDNIGHT_DELVER_META_INSTRUCTION="Schließe alle vier unterstützenden Tiefen-Erfolge von Midnight ab, um diesen Meta-Erfolg zu vollenden.", TEXT_COILED_ISLE_META_INSTRUCTION="Schließe die Erfolge von Coiled Isle ab.", TEXT_MIDNIGHT_ZONE_META_REWARD_REQUIREMENT="Schließe die vier Zonen-Meta-Erfolge von Midnight ab und erhalte die Reittierbelohnung.", TEXT_CLAW_ENFORCEMENT_REQUIREMENT="Schließe die Harandar-Weltquest 'Claw Enforcement' mit mindestens 15 Stapeln von Predator's Pursuit ab.", TEXT_ATALUTEK_META_INSTRUCTION="Schließe die Erfolge von Vaults of Atal'Utek ab.", TEXT_COILED_ISLE_LORE_INSTRUCTION="Entdecke die Wissensobjekte von Coiled Isle.", TEXT_HUNGERING_PRESENCE_REQUIREMENT="Entkomme dem Griff von Hungering Presence in Voidstorm mindestens 60 Sekunden lang.", TEXT_CRADLE_FLIGHT_REQUIREMENT="Fliege hoch über Harandar in The Cradle hinein, um diesen Erfolg abzuschließen.", TEXT_EVERSONG_META_TRACKER_DESCRIPTION="Verfolge den Meta-Erfolg von Eversong Woods und öffne seine untergeordneten Tracker.", TEXT_MIDNIGHT_PEAKS_TRACKER_DESCRIPTION="Verfolge die vier Zonenerfolge für Midnight, the Highest Peaks.", TEXT_HARANDAR_META_TRACKER_DESCRIPTION="Verfolge den Harandar-Meta-Erfolg und öffne seine untergeordneten Tracker.", TEXT_VOIDSTORM_META_TRACKER_DESCRIPTION="Verfolge den Voidstorm-Meta-Erfolg und öffne seine untergeordneten Tracker.", TEXT_ZULAMAN_META_TRACKER_DESCRIPTION="Verfolge den Zul'Aman-Meta-Erfolg und öffne seine untergeordneten Tracker.", TEXT_CRADLE_FLIGHT_ATTEMPT="Versuche, hoch über Harandar nach The Cradle zu fliegen.", NOTE_MOTH_ROUTE_RENOWN_REQUIREMENT="Die LiteVault-Route setzt voraus, dass Hara'ti Renown 11 bereits freigeschaltet ist.",
TEXT_HARATI_META_PROGRESS_INSTRUCTION="Hilf den Hara'ti, indem du die Erfolge unten abschließt. x/y abgeschlossen.", TEXT_VOIDSTORM_META_PROGRESS_INSTRUCTION="Schließe alle unten aufgeführten Voidstorm-Erfolge ab. x/y abgeschlossen.", TEXT_ZULAMAN_META_PROGRESS_INSTRUCTION="Schließe alle unten aufgeführten Zul'Aman-Erfolge ab. x/y abgeschlossen.", TEXT_STORMARION_ASSAULT_PROGRESS_INSTRUCTION="Schließe alle drei Wellen von Stormarion Assault ab. x/y markiert.", TEXT_ABUNDANT_HARVEST_PROGRESS_INSTRUCTION="Schließe an jedem Ort einen Höhlenlauf von Abundant Harvest ab. x/y markiert.", TEXT_EVERSONG_META_PROGRESS_INSTRUCTION="Schließe die unten aufgeführten Erfolge von Eversong Woods ab. x/y abgeschlossen.", TEXT_GLOWING_MOTH_PROGRESS="Finde alle in Harandar versteckten Glowing Moths. x/y gefunden.", TEXT_HARANIR_LEGEND_PROGRESS="Beschütze jeden unten aufgeführten Ort einer Haranir-Legende. x/y markiert.", TEXT_XALATATH_META_PROGRESS="Stelle dich Xal'atath, indem du die Erfolge unten abschließt. x/y abgeschlossen.", TEXT_HARANIR_JOURNAL_PROGRESS="Berge die unten aufgeführten Haranir-Tagebucheinträge. x/y markiert.", TEXT_BLESSING_EFFECT_PROGRESS="Löse jeden aufgeführten Segnungseffekt aus. x/y markiert.", TEXT_FACTION_INVITE_PROGRESS="Verfolge die vier Fraktionseinladungen für The Party Must Go On. x/y markiert.", TEXT_EVER_PAINTING_PROGRESS="Verfolge die bekannten Gemälde von Ever-Painting. x/y markiert.", TEXT_RUNESTONE_RUSH_PROGRESS="Verfolge die bekannten Einträge von Runestone Rush. x/y markiert.",
TEXT_DELVER_MOUNT_REWARD_REQUIREMENT="Schließe Glory of the Midnight Delver ab, um dieses Reittier zu erhalten.", NOTE_MOTH_GROUP_1_RENOWN="Motten 1–40 erscheinen bei Hara'ti Renown 1, die Verfolgung bei Renown 2.", NOTE_MOTH_GROUP_2_RENOWN="Motten 41–80 erscheinen bei Hara'ti Renown 4, die Verfolgung bei Renown 6.", NOTE_MOTH_GROUP_3_RENOWN="Motten 81–120 erscheinen bei Hara'ti Renown 9, die Verfolgung bei Renown 11.", NOTE_HARANIR_JOURNAL_AVAILABILITY="Diese Tagebücher sind nur während der accountweiten Wochenquest 'Legends of the Haranir' verfügbar. Achte in einer Vision auf das Lupensymbol auf der Minikarte.", NOTE_CLAW_ENFORCEMENT_NO_COORDINATES="Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Schließe die Harandar-Weltquest 'Claw Enforcement' mit mindestens 15 Stapeln von Predator's Pursuit ab.", NOTE_HUNGERING_PRESENCE_NO_COORDINATES="Dieser Erfolg benötigt keine Koordinatenverfolgung in LiteVault. Überstehe das Ereignis Hungering Presence in Voidstorm mindestens 60 Sekunden lang.", NOTE_HARANIR_LEGENDS_WEEKLY_ESTIMATE="Dies ist an die accountweite Wochenquest 'Legends of the Haranir' gebunden. Ohne bisherigen Fortschritt dauert der Abschluss schätzungsweise etwa 7 Wochen.", NOTE_MOTH_TRACKER_GROUPING="Dieser Tracker ist in 3 Gruppen mit je 40 Koordinaten aufgeteilt, damit die Mottenrouten übersichtlich bleiben.", TEXT_EVER_PAINTING_TRACKER_PLACEHOLDER="Verfolge den Fortschritt von Ever-Painting. Eintragsdetails können später ergänzt werden.", TEXT_EXPLORE_EVERSONG_TRACKER_PLACEHOLDER="Verfolge den Fortschritt von Explore Eversong Woods. Eintragsdetails können später ergänzt werden.", TEXT_RUNESTONE_RUSH_TRACKER_PLACEHOLDER="Verfolge den Fortschritt von Runestone Rush. Eintragsdetails können später ergänzt werden.", TEXT_PARTY_TRACKER_PLACEHOLDER="Verfolge den Fortschritt von The Party Must Go On. Eintragsdetails können später ergänzt werden.", TOOLTIP_ABUNDANT_HARVEST_CREDIT_REQUIREMENT="Du musst an jedem Ort einen Höhlenlauf von Abundant Harvest abschließen. Der bloße Besuch der Höhle genügt nicht.",
TEXT_EXPLORE_EVERSONG_PROGRESS="Verfolge den Fortschritt von Explore Eversong Woods. x/y markiert.", TEXT_EXPLORE_HARANDAR_PROGRESS="Verfolge den Fortschritt von Explore Harandar. x/y markiert.", TEXT_EXPLORE_VOIDSTORM_PROGRESS="Verfolge den Fortschritt von Explore Voidstorm. x/y markiert.", TEXT_EXPLORE_ZULAMAN_PROGRESS="Verfolge den Fortschritt von Explore Zul'Aman. x/y markiert.",
}
for key,value in pairs(phase2) do L[key]=value end
lv.RegisterLocale("deDE", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["deDE"] = L
