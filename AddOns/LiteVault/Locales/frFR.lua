-- frFR.lua - French locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",

    -- ==========================================================================
    -- COMMON UI ELEMENTS
    -- ==========================================================================
    BUTTON_CLOSE = "Fermer",
    BUTTON_YES = "Oui",
    BUTTON_NO = "Non",
    BUTTON_MANAGE = "Gérer",
    BUTTON_BACK = "Retour",
    BUTTON_ALL = "Tous",
    BUTTON_NONE = "Aucun",
    BUTTON_FILTER = "Filtrer",
    TAB_TRACKERS = "Suivis",
    TAB_META_ACHIEVEMENTS = "Méta-hauts faits",
    TEXT_FOLIO_NODE_FMT = "Nœud %d",
    TEXT_GEAR_TITLE_FMT = "%s — %s",
    LABEL_GEAR_CRIT = "Critique",
    LABEL_GEAR_HASTE = "Hâte",
    LABEL_GEAR_MASTERY = "Maîtrise",
    LABEL_GEAR_VERS = "Polyvalence",
    TEXT_GEAR_ILVL_COLORED_FMT = "Niv. d’objet |c%s%d|r",
    STATUS_LIVE = "[DIRECT]",
    STATUS_CACHED = "[EN CACHE]",
    STATUS_STALE = "[OBSOLÈTE]",
    TAB_OVERVIEW = "Vue d’ensemble",
    DIALOG_DELETE_CHAR = "Supprimer %s de LiteVault ?",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "Filtres de carte",

    BUTTON_RAID_LOCKOUTS = "Verrouillages raid",
    BUTTON_WORLD_EVENTS = "Événements",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "Verrouillages de raid",
    TOOLTIP_RAID_LOCKOUTS_DESC = "Voir les boss tués de tous les personnages",
    TOOLTIP_THEME_TITLE = "Changer de thème",
    TOOLTIP_THEME_DESC = "Alterner entre mode sombre et clair",
    TOOLTIP_FILTER_TITLE = "Filtre de carte",
    TOOLTIP_FILTER_DESC = "Cliquer pour voir la liste complète",
    TOOLTIP_WORLD_EVENTS_TITLE = "Événements mondiaux",
    TOOLTIP_WORLD_EVENTS_DESC = "Voir les événements mondiaux",

    -- Sort controls
    LABEL_SORT_BY = "Trier:",
    SORT_GOLD = "Or",
    SORT_ILVL = "iLvl",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "Activité",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "Quêtes hebdo de %s",
    LABEL_WEEKLY_COMPLETION_SUMMARY = "%d / %d terminées",
    BUTTON_WEEKLIES = "Hebdo",
    BUTTON_EVENTS = "Événements",
    BUTTON_FACTIONS = "Factions",
    BUTTON_AMANI_TRIBE = "Tribu Amani",
    BUTTON_HARATI = "Hara'ti",
    BUTTON_SINGULARITY = "La Singularité",
    BUTTON_SILVERMOON_COURT = "Cour de Lune-d’Argent",
    TITLE_FACTION_WEEKLIES = "Hebdos de faction de %s",
    WARNING_EVENT_QUESTS = "Certains de ces événements sont buggés ou verrouillés en jeu.",

    WARNING_WEEKLY_HARATI_CHOICE = "Attention ! Une fois la quête Légendes des Haranir choisie, elle est verrouillée pour votre compte.",
    WARNING_WEEKLY_RUNESTONES = "Attention ! Choisissez soigneusement la quête des pierres runiques. Une fois votre choix fait pour la semaine, il s'applique à tout le compte.",
    LABEL_WEEKLY_PROFIT = "Profit hebdo:",
    LABEL_WARBAND_PROFIT = "Profit de bande:",
    LABEL_WARBAND_BANK = "Banque de bande:",
    LABEL_TOP_EARNERS = "Meilleurs gains (Hebdo):",
    LABEL_TOTAL_GOLD = "Or total: %s",
    LABEL_TOTAL_TIME = "Temps total: %s",
    LABEL_COMBINED_TIME = "Temps combiné: %dj %dh",

    TOOLTIP_TOTAL_TIME_TITLE = "Temps total",
    TOOLTIP_TOTAL_TIME_DESC = "Temps de jeu total de tous les personnages suivis.",
    TOOLTIP_TOTAL_TIME_CLICK = "Cliquer pour changer le format.",

    -- Quest status
    STATUS_DONE = "[Terminé]",
    STATUS_IN_PROGRESS = "[En cours]",
    STATUS_NOT_STARTED = "[Non commencé]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Gérer les personnages",
    TOOLTIP_MANAGE_BACK = "Retourner à l'onglet principal.",
    TOOLTIP_MANAGE_VIEW = "Voir les personnages ignorés.",

    TOOLTIP_CATALYST_TITLE = "Charges de catalyseur",
    TOOLTIP_SPARKS_TITLE = "Étincelles d'artisanat",
    TOOLTIP_VOIDSHARDS_TITLE = "Éclats du Vide ascendants",
    TOOLTIP_VOIDCORES_TITLE = "Noyaux du Vide ascendants",

    TOOLTIP_VAULT_TITLE = "Grande chambre forte",
    TOOLTIP_VAULT_DESC = "Appuyer pour ouvrir la grande chambre forte",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Ouvrir la Grande chambre forte.",
    TOOLTIP_VAULT_ALT_ONLY = "La Grande chambre forte ne peut être ouverte que pour le personnage actif.",

    TOOLTIP_CURRENCY_TITLE = "Devises du personnage",
    TOOLTIP_CURRENCY_DESC = "Cliquer pour voir la liste complète.",

    TOOLTIP_BAGS_TITLE = "Voir les sacs",
    TOOLTIP_BAGS_DESC = "Voir le contenu des sacs et des sacs de réactifs sauvegardés.",

    TOOLTIP_LEDGER_DESC = "Suivre les revenus et dépenses d'or par source.",

    TOOLTIP_WARBAND_BANK_TITLE = "Registre de banque de bande",
    TOOLTIP_WARBAND_BANK_DESC = "Cliquer pour voir les transactions.",

    TOOLTIP_RESTORE_TITLE = "Restaurer",
    TOOLTIP_RESTORE_DESC = "Restaurer ce personnage sur la page principale",

    TOOLTIP_IGNORE_TITLE = "Ignorer",
    TOOLTIP_IGNORE_DESC = "Retirer ce personnage de la page principale",

    TOOLTIP_DELETE_TITLE = "Supprimer",
    TOOLTIP_DELETE_DESC = "Supprimer définitivement les données de ce personnage",
    TOOLTIP_DELETE_WARNING = "Attention: Cette action est irréversible!",

    TOOLTIP_FAVORITE_TITLE = "Favori",
    TOOLTIP_FAVORITE_DESC = "Épingler ce personnage en haut de la liste",

    -- Character data displays
    LABEL_ILVL = "iLvl: %d",
    LABEL_MPLUS_SCORE = "Score M+: %d",
    LABEL_NO_KEY = "Pas de clé M+",
    LABEL_NO_PROFESSIONS = "Pas de métiers",
    LABEL_UNKNOWN = "Inconnu",
    LABEL_SKILL_LEVEL = "Compétence: %d/%d",
    LABEL_CONCENTRATION = "Concentration: %d/%d",
    LABEL_CONC_DAILY_RESET = "Quotidien: %dh %dm",
    LABEL_CONC_WEEKLY_RESET = "Reset complet: %dj %dh",
    LABEL_CONC_FULL = "(Plein)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d Connaissances disponibles",
    LABEL_NO_KNOWLEDGE = "Aucune connaissance disponible",
    LABEL_VAULT_PROGRESS = "R: %d/3    M+: %d/3    M: %d/3",
    BUTTON_PROFS = "Métiers",

    TOOLTIP_PROFS_TITLE = "Métiers",
    TOOLTIP_PROFS_DESC = "Voir concentration et connaissances",
    TITLE_PROFESSIONS = "Métiers de %s",
    TITLE_KNOWLEDGE_SOURCES = "Sources de connaissance",
    TAB_TREASURES = "Trésors",
    LABEL_UNIQUE_TREASURES = "Trésors uniques",
    LABEL_WEEKLY_TREASURES = "Trésors hebdomadaires",
    LABEL_HOVER_TREASURE_CHECKLIST = "Survolez pour voir la liste des trésors",
    TITLE_PROF_TREASURES_FMT = "Trésors de %s",
    LABEL_PROFESSION = "Métier",
    LABEL_UNIQUE_TREASURE_FMT = "Trésor unique de %s %d",
    LABEL_WEEKLY_TREASURE_FMT = "Trésor hebdomadaire de %s %d",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "Dim",
    DAY_MON = "Lun",
    DAY_TUE = "Mar",
    DAY_WED = "Mer",
    DAY_THU = "Jeu",
    DAY_FRI = "Ven",
    DAY_SAT = "Sam",

    TOOLTIP_ACTIVITY_FOR = "Activité pour le %d/%d/%d",
    MSG_NO_WORLD_EVENTS = "Pas d'événements mondiaux ce mois-ci",

    -- Filter categories
    FILTER_TIMEWALKING = "Marcheurs du temps",
    FILTER_DARKMOON = "Sombrelune",
    FILTER_DUNGEONS = "Donjons",
    FILTER_PVP = "JcJ",
    FILTER_BONUS = "Bonus",

    -- World events
    WORLD_EVENT_LOVE = "De l'amour dans l'air",
    WORLD_EVENT_LUNAR = "Fête lunaire",
    WORLD_EVENT_NOBLEGARDEN = "Le Jardin des nobles",
    WORLD_EVENT_CHILDREN = "Semaine des enfants",
    WORLD_EVENT_MIDSUMMER = "Fête du Feu du solstice d'été",
    WORLD_EVENT_BREWFEST = "Fête des Brasseurs",
    WORLD_EVENT_HALLOWS = "Sanssaint",
    WORLD_EVENT_WINTERVEIL = "Voile d'hiver",
    WORLD_EVENT_DEAD = "Jour des morts",
    WORLD_EVENT_PIRATES = "Jour des pirates",
    WORLD_EVENT_STYLE = "Épreuve de style",
    WORLD_EVENT_OUTLAND = "Coupe de l'Outreterre",
    WORLD_EVENT_NORTHREND = "Coupe de Norfendre",
    WORLD_EVENT_KALIMDOR = "Coupe de Kalimdor",
    WORLD_EVENT_EASTERN = "Coupe des Royaumes de l'Est",
    WORLD_EVENT_WINDS = "Vents de fortune mystérieuse",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "Devises de %s",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_FORMAT = "%s %s %s - Forge de mana Omega",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Héroïque",
    DIFFICULTY_MYTHIC = "Mythique",

    MSG_NO_CHAR_DATA = "Aucune donnée de personnage trouvée",
    MSG_NO_PROGRESSION = "Aucune progression %s enregistrée",
    MSG_NO_LOCKOUT = "Pas de verrouillage %s cette semaine",

    LABEL_BOSS = "Boss %d",
    LABEL_PROGRESS_COUNT = "%d/8",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "Registre de banque de bande",
    LABEL_CURRENT_BALANCE = "Solde actuel:",
    LABEL_RECENT_TRANSACTIONS = "Transactions récentes:",
    MSG_NO_TRANSACTIONS = "(Aucune transaction enregistrée)",
    TIP_RELOAD_SAVE = "Conseil: /reload avant de changer de personnage pour sauvegarder",
    ACTION_DEPOSITED = "déposé",
    ACTION_WITHDREW = "retiré",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    LABEL_RESETS_IN = "Reset dans %dj %dh",

    TAB_SUMMARY = "Résumé",
    TAB_HISTORY = "Historique",
    TAB_WARBAND = "Warband",
    HEADER_SOURCE = "Source",
    HEADER_INCOME = "Revenus",
    HEADER_EXPENSE = "Dépenses",

    LABEL_TOTAL = "Total",
    LABEL_NET_PROFIT = "Profit net",
    MSG_NO_GOLD_ACTIVITY = "Aucune activité d'or cette semaine",
    MSG_NO_TRANSACTIONS_WEEK = "Aucune transaction cette semaine",

    -- Ledger source categories
    LEDGER_QUESTS = "Quêtes",
    LEDGER_AUCTION = "Hôtel des ventes",
    LEDGER_TRADE = "Échange",
    LEDGER_VENDOR = "Vendeur",
    LEDGER_REPAIRS = "Réparations",
    LEDGER_TRANSMOG = "Transmogrification",
    LEDGER_FLIGHT = "Trajets de vol",
    LEDGER_CRAFTING = "Artisanat",
    LEDGER_CACHE = "Cache/Trésor",
    LEDGER_MAIL = "Courrier",
    LEDGER_LOOT = "Butin",
    LEDGER_WARBAND_BANK = "Banque de bande",
    LEDGER_OTHER = "Autre",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "Jamais",
    FRESH_TODAY = "Actif aujourd'hui",
    FRESH_1_DAY = "Il y a 1 jour",
    FRESH_DAYS = "Il y a %d jours",

    -- Time format styles
    TIME_YEARS_DAYS = "%da %dj",
    TIME_DAYS_HOURS = "%dj %dh",
    TIME_DAYS = "%s Jours",
    TIME_HOURS = "%s Heures",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "Salutations %s,\nvoulez-vous que LiteVault suive ce personnage?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "Reset hebdomadaire détecté! Verrouillages de raid effacés.",
    MSG_ALREADY_TRACKED = "Ce personnage est déjà suivi.",
    MSG_CHAR_ADDED = "%s a été ajouté au suivi.",
    MSG_RAID_RESET_SEASON = "La progression de raid a été réinitialisée pour Midnight Saison 1!",
    MSG_CLEARED_PROGRESSION = "Données de progression effacées pour %d personnages.",
    MSG_WEEKLY_PROFIT_RESET = "Suivi de profit hebdo réinitialisé pour %d personnages.",
    MSG_WARBAND_BALANCE = "Bande: %s",
    MSG_WARBAND_BANK_BALANCE = "Banque de bande: %s",
    MSG_WEEKLY_DATA_RESET = "Données hebdo réinitialisées pour %d personnages.",
    MSG_RAID_MANUAL_RESET = "Progression de raid réinitialisée manuellement!",
    MSG_CLEARED_DATA = "Données effacées pour %d personnages.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "Le message initial du temps de jeu de Blizzard ne peut pas être supprimé.",

    -- Slash command help
    HELP_RESET_TITLE = "Commandes de reset LiteVault",
    HELP_REGION = "Région: %s (reset %s)",
    HELP_LAST_SEASON = "Dernier reset de saison: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - Réinitialiser le suivi de profit hebdo",
    HELP_RESET_SEASON = "/lvreset season - Réinitialiser la progression de raid (nouveau palier)",
    HELP_NEVER = "Jamais",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "Langue",
    TOOLTIP_LANGUAGE_TITLE = "Langue",
    TOOLTIP_LANGUAGE_DESC = "Changer la langue de l'interface",
    TITLE_LANGUAGE_SELECT = "Choisir la langue",
    LANG_AUTO = "Auto (détecter)",
    MSG_LANGUAGE_CHANGED = "Langue changée. Rechargez l'interface pour appliquer tous les changements.",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "Options",
    TOOLTIP_OPTIONS_TITLE = "Options",
    TOOLTIP_OPTIONS_DESC = "Configurer les paramètres de LiteVault",
    TITLE_OPTIONS = "Options LiteVault",
    OPTION_DISABLE_TIMEPLAYED = "Désactiver le suivi du temps de jeu",
    OPTION_DISABLE_TIMEPLAYED_DESC = "Empêche les messages /played d'apparaître dans le chat",
    OPTION_DISABLE_BAG_VIEWING = "Désactiver la visionneuse de sacs/banque",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Masque le bouton Sacs et désactive la consultation des sacs, banque et banque de cohorte enregistrés.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Désactiver le système de superposition",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Masque les superpositions de niveau d'objet et de verrou de LiteVault sur l'équipement du personnage et d'inspection.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "Désactiver les téléportations M+",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Masque le badge de téléportation M+ et désactive le panneau de téléportation de LiteVault.",


    -- Month names
    MONTH_1 = "Janvier",
    MONTH_2 = "Février",
    MONTH_3 = "Mars",
    MONTH_4 = "Avril",
    MONTH_5 = "Mai",
    MONTH_6 = "Juin",
    MONTH_7 = "Juillet",
    MONTH_8 = "Août",
    MONTH_9 = "Septembre",
    MONTH_10 = "Octobre",
    MONTH_11 = "Novembre",
    MONTH_12 = "Décembre",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["Dawnlight Manaflux"] = "Flux de mana d'aubastre",

    -- ==========================================================================
    -- WEEKLY QUESTS (Midnight)
    -- ==========================================================================
    ["Community Engagement"] = "Community Engagement",
    WARNING_ACCOUNT_BOUND = "Lié au compte",
    ["Midnight: Prey"] = "Midnight: Prey",
    ["Soirée de Saltheril"] = "Soirée de Saltheril",
    ["Événement d'abondance"] = "Événement d'abondance",
    ["Légendes des Haranir"] = "Légendes des Haranir",
    ["Ténèbres Défaites"] = "Ténèbres Défaites",
    ["Récolte du Vide"] = "Récolte du Vide",
    ["Minuit : soirée de Saltheril"] = "Minuit : soirée de Saltheril",
    ["Fortify the Runestones: Blood Knights"] = "Fortifier les pierres runiques : chevaliers de sang",
    ["Fortify the Runestones: Shades of the Row"] = "Fortifier les pierres runiques : ombres de la rue",
    ["Fortifier les pierres runiques : magistères"] = "Fortifier les pierres runiques : magistères",
    ["Fortifier les pierres runiques : pérégrins"] = "Fortifier les pierres runiques : pérégrins",
    ["Put a Little Snap in Their Step"] = "Mettez plus d'entrain dans leur pas",
    ["Collations légères"] = "Collations légères",
    ["Less Lawless"] = "Moins d'anarchie",
    ["The Subtle Game"] = "Le jeu subtil",
    ["Courtiser le succès"] = "Courtiser le succès",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Alchimie",
    ["Blacksmithing"] = "Forge",
    ["Enchanting"] = "Enchantement",
    ["Ingénierie"] = "Ingénierie",
    ["Inscription"] = "Calligraphie",
    ["Jewelcrafting"] = "Joaillerie",
    ["Leatherworking"] = "Travail du cuir",
    ["Tailoring"] = "Couture",
    ["Herbalism"] = "Herboristerie",
    ["Mining"] = "Minage",
    ["Dépeçage"] = "Dépeçage",

    ["Remnant of Anguish"] = "Vestige d'angoisse",
    ["Éclat de Dundun"] = "Éclat de Dundun",
    ["Écu de l'Aube d'aventurier"] = "Écu de l'Aube d'aventurier",
    ["Écu de l'Aube de vétéran"] = "Écu de l'Aube de vétéran",
    ["Écu de l'Aube de champion"] = "Écu de l'Aube de champion",
    ["Écu de l'Aube de héros"] = "Écu de l'Aube de héros",
    ["Écu de l'Aube mythique"] = "Écu de l'Aube mythique",
    ["Mystères débordants"] = "Mystères débordants",
    ["Lancez les dés"] = "Lancez les dés",
    ["Nous avons besoin de réapprovisionner"] = "Nous avons besoin de réapprovisionner",
    ["Lovely Plumage"] = "Joli plumage",
    ["Le chaudron des échos"] = "Le chaudron des échos",
    ["La flamme sans écho"] = "La flamme sans écho",
    ["Hidey-Hole"] = "Cachette",
    ["Victorious Stormarion Pinnacle Cache"] = "Cache du Pinnacle de Stormarion victorieuse",
    ["Sacoche débordante d’abondance"] = "Sacoche débordante d’abondance",
    ["Paquet de fournitures de l’apprenant assidu"] = "Paquet de fournitures de l’apprenant assidu",
    ["Sac excédentaire de cadeaux de fête"] = "Sac excédentaire de cadeaux de fête",
    ["Marne de Néantlumière"] = "Marne de Néantlumière",
    ["Sous-pièce"] = "Sous-pièce",
    TELEPORT_PANEL_TITLE = "Téléportations M+",
    TELEPORT_CAST_BTN = "Téléporter",
    TELEPORT_ERR_COMBAT = "Impossible de se téléporter en combat.",
    BUTTON_VAULT = "Coffre",
    BUTTON_ACTIONS = "Actions",
    BUTTON_RAIDS = "Raids",
    BUTTON_FAVORITE = "Favori",
    BUTTON_UNFAVORITE = "Retirer le favori",
    BUTTON_IGNORE = "Ignorer",
    BUTTON_RESTORE = "Restaurer",
    BUTTON_DELETE = "Supprimer",
    TOOLTIP_ACTIONS_TITLE = "Actions du personnage",
    TOOLTIP_ACTIONS_DESC = "Ouvrir le menu d'actions",
    BUTTON_INSTANCES = "Instances",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Suivi des instances",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Suivre les donjons et les raids",
    LABEL_RENOWN_PROGRESS = "Renom %d (%d/%d)",

    LABEL_RENOWN = "Renom",
    LABEL_RENOWN_LEVEL = "Niveau",
    LABEL_RENOWN_UNAVAILABLE = "Renom indisponible",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "Aucune quête de faction n'est encore configurée.",
    BUTTON_KNOWLEDGE = "Connaissance",
    WORLD_EVENT_SALTHERIL = "Soirée de Saltheril",
    WORLD_EVENT_ABUNDANCE = "Abondance",
    WORLD_EVENT_HARANIR = "Légendes des Haranir",
    WORLD_EVENT_STORMARION = "Assaut de Stormarion",
    TITLE_KNOWLEDGE_TRACKER = "Suivi des connaissances",
    TOOLTIP_KNOWLEDGE_DESC = "Voir les connaissances dépensées, disponibles et maximales",
    LABEL_SPENT = "Dépensé",
    LABEL_UNSPENT = "Non dépensé",
    LABEL_MAX = "Maximum",
    LABEL_EARNED = "Obtenu",
    LABEL_TREATISE = "Traité",
    LABEL_ARTISAN_QUEST = "Artisan",
    LABEL_CATCHUP = "Rattrapage",
    LABEL_WEEKLY = "Hebdomadaire",
    LABEL_UNLOCKED = "Débloqué",
    LABEL_UNLOCK_REQUIREMENTS = "Conditions de déblocage",
    LABEL_SOURCE_NOTE = "Sources hebdomadaires et instantané de rattrapage",
    LABEL_TREASURE_CLICK_HINT = "Cliquez sur un trésor unique pour placer un point de passage",
    LABEL_ZONE = "Zone",
    LABEL_QUEST = "Quête",
    LABEL_COORDINATES = "Coordonnées",
    TOOLTIP_TREASURE_SET_WAYPOINT = "Cliquez pour placer un point de passage TomTom",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "Cliquez pour placer un point de passage sur la carte",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "Ce trésor n'a pas d'emplacement fixe",
    MSG_TREASURE_NO_WAYPOINT = "Aucun point de passage fixe pour ce trésor.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom non détecté.",
    MSG_TREASURE_WAYPOINT_SET = "Point de passage placé : %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "Point de carte placé : %s (%.1f, %.1f)",
    STATUS_DONE_WORD = "Terminé",
    STATUS_MISSING_WORD = "Manquant",
    LABEL_MIDNIGHT_SEASON_1 = "Saison 1 de Midnight",
    TAB_SOURCES = "Sources",
    TIME_TODAY = "Aujourd'hui %H:%M",
    MSG_CAP_WARNING = "Alerte limite d'instance ! %d/10 instances cette heure.",
    MSG_CAP_SLOT_OPEN = "Un emplacement d'instance est maintenant libre ! (%d/10 utilisés)",
    MSG_RELOAD_TIMEPLAYED = "Rechargez l'interface pour appliquer la suppression du temps joué.",
    MSG_RAID_DEBUG_ON = "Debug raid LiteVault : ACTIVÉ",
    MSG_RAID_DEBUG_OFF = "Debug raid LiteVault : DÉSACTIVÉ",
    MSG_RAID_DEBUG_TIP = "Utilisez /lvraiddbg à nouveau pour désactiver la sortie de debug",
    MSG_TRACKED_KILL = "Kill %s suivi : %s (%s)",
    LOCALE_DEBUG_ON = "Mode debug de langue ACTIVÉ - affiche les clés",
    LOCALE_DEBUG_OFF = "Mode debug de langue DÉSACTIVÉ - affiche les traductions",
    LOCALE_BORDERS_ON = "Mode bordures ACTIVÉ - affiche les limites du texte",
    LOCALE_BORDERS_HINT = "Vert = tient, Rouge = peut déborder",
    LOCALE_BORDERS_OFF = "Mode bordures DÉSACTIVÉ",
    LOCALE_FORCED = "Langue forcée sur %s",
    LOCALE_RESET_TIP = "Utilisez /lvlocale reset pour revenir à la détection automatique",
    LOCALE_INVALID = "Langue invalide. Options valides :",
    LOCALE_RESET = "Langue réinitialisée sur détection automatique : %s",
    LOCALE_TITLE = "Localisation LiteVault",
    LOCALE_DETECTED = "Langue détectée : %s",
    LOCALE_FORCED_TO = "Langue forcée : %s",
    LOCALE_DEBUG_KEYS = "Clés de debug :",
    LOCALE_DEBUG_BORDERS = "Bordures de debug :",
    LOCALE_ON = "ACTIVÉ",
    LOCALE_OFF = "DÉSACTIVÉ",
    LOCALE_COMMANDS = "Commandes :",
    LOCALE_CMD_DEBUG = "/lvlocale debug - Basculer le mode d'affichage des clés",
    LOCALE_CMD_BORDERS = "/lvlocale borders - Basculer la visualisation des limites du texte",
    LOCALE_CMD_LANG = "/lvlocale lang XX - Forcer la langue (ex. : deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - Revenir à la détection automatique",
    TITLE_INSTANCE_TRACKER = "Suivi des instances",
    SECTION_INSTANCE_CAP = "Limite d'instances (10/heure)",
    LABEL_CAP_CURRENT = "Actuel : %d/10",
    LABEL_CAP_STATUS = "Statut : %s",
    LABEL_NEXT_SLOT = "Prochaine place dans : %s",
    STATUS_SAFE = "SÛR",
    STATUS_WARNING = "ALERTE",
    STATUS_LOCKED = "BLOQUÉ",
    SECTION_CURRENT_RUN = "Sortie actuelle",
    LABEL_DURATION = "Durée : %s",
    LABEL_NOT_IN_INSTANCE = "Pas dans une instance",
    SECTION_PERFORMANCE = "Performance du jour",
    LABEL_DUNGEONS_TODAY = "Donjons : %d",
    LABEL_RAIDS_TODAY = "Raids : %d",
    LABEL_AVG_TIME = "Moy. : %s",
    SECTION_LEGACY_RAIDS = "Raids d'héritage cette semaine",
    LABEL_LEGACY_RUNS = "Sorties : %d",
    LABEL_GOLD_EARNED = "Or : %s",
    SECTION_RECENT_RUNS = "Sorties récentes",
    LABEL_NO_RECENT_RUNS = "Aucune sortie récente",
    SECTION_MPLUS = "Mythique+",
    LABEL_MPLUS_CURRENT_KEY = "Clé actuelle :",
    LABEL_RUNS_TODAY = "Sorties aujourd'hui : %d",
    LABEL_RUNS_THIS_WEEK = "Sorties cette semaine : %d",
    SECTION_RECENT_MPLUS_RUNS = "Sorties M+ récentes",
    LABEL_NO_RECENT_MPLUS_RUNS = "Aucune sortie M+ récente",
    BUTTON_DASHBOARD = "Tableau de bord",
    BUTTON_PROFIT = "Profit",
    LABEL_PROFIT_GOALS = "Objectifs du bataillon",
    LABEL_WEEKLY_GOAL = "Objectif hebdomadaire",
    LABEL_MONTHLY_GOAL = "Objectif mensuel",
    BUTTON_EDIT = "Modifier",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "Profit net le plus élevé depuis cette réinitialisation.",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "Meilleur profit net du mois en cours.",
    BUTTON_ACHIEVEMENTS = "Succès",
    TITLE_ACHIEVEMENTS = "Succès",
    DESC_ACHIEVEMENTS = "Choisissez un suivi de succès pour voir la progression détaillée.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "Chasseur de glyphes de minuit",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "Chasseur de glyphes de minuit",
    LABEL_REWARD = "Récompense",
    DESC_GLYPH_REWARD = "Terminez Chasseur de glyphes de minuit pour obtenir cette monture.",
    MSG_NO_ACHIEVEMENT_DATA = "Aucune donnée de suivi de succès disponible.",
    LABEL_CRITERIA = "Critères",
    LABEL_GLYPHS_COLLECTED = "Glyphes collectés",
    LABEL_ACHIEVEMENT = "Succès",
    BUTTON_BAGS = "Sacs",
    BUTTON_BANK = "Banque",
    BUTTON_WARBAND_BANK = "Banque de cohorte",
    BAGS_EMPTY_STATE = "Aucun objet de sac sauvegardé pour ce personnage.",
    BANK_EMPTY_STATE = "Aucun objet de banque sauvegardé pour ce personnage.",
    WARBANK_EMPTY_STATE = "Aucun objet de banque de cohorte sauvegardé.",
    LABEL_BAG_SLOTS = "Emplacements : %d / %d utilisés",
    LABEL_SCANNED = "scanné",
    OPTION_ENABLE_24HR_CLOCK = "Activer l'horloge 24 h",
    OPTION_ENABLE_24HR_CLOCK_DESC = "Basculer entre le format 24 h et 12 h",
    ["Éclats de clé de coffre"] = "Éclats de clé de coffre",
    BUTTON_WEEKLY_PLANNER = "Planificateur",
    TITLE_WEEKLY_PLANNER = "Planificateur hebdomadaire",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "Planificateur hebdomadaire",
    TOOLTIP_WEEKLY_PLANNER_DESC = "Liste hebdomadaire modifiable par personnage. Les éléments terminés sont réinitialisés chaque semaine.",
    TOOLTIP_VAULT_STATUS = "Vérifier l'état du coffre.",
    TITLE_GREAT_VAULT = "Le Grand coffre-fort",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "Raid",
    LABEL_VAULT_ROW_DUNGEONS = "Donjons",
    LABEL_VAULT_ROW_WORLD = "Monde",
    LABEL_VAULT_SLOTS_UNLOCKED = "%d/9 emplacements déverrouillés",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "Aucune donnée de palier enregistrée pour le moment.",
    MSG_VAULT_LIVE_ACTIVE = "Progression en direct du Grand coffre-fort pour le personnage actif.",
    MSG_VAULT_LIVE = "Progression en direct du Grand coffre-fort.",
    MSG_VAULT_SAVED = "Instantané enregistré du Grand coffre-fort lors de la dernière connexion de ce personnage.",
    SECTION_DELVE_CURRENCY = "Monnaie des Gouffres",
    SECTION_UPGRADE_CRESTS = "Écussons d’amélioration",
    LABEL_CAP_SHORT = "cap. %s",
    ["Trésors de Midnight"] = "Trésors de Midnight",
    ["Suivez les quatre hauts faits de trésors de Midnight et leurs récompenses."] = "Suivez les quatre hauts faits de trésors de Midnight et leurs récompenses.",
    ["Terminez « Gloire du Fouilleur de Midnight » pour obtenir cette monture."] = "Terminez « Gloire du Fouilleur de Midnight » pour obtenir cette monture.",
    ["Suivez les quatre hauts faits de rares de Midnight et les récompenses des rares de zone."] = "Suivez les quatre hauts faits de rares de Midnight et les récompenses des rares de zone.",
    ["Terminez les cinq télescopes de cette zone."] = "Terminez les cinq télescopes de cette zone.",
    ["Terminez les quatre hauts faits de soutien du Fouilleur de Midnight pour achever ce méta haut fait."] = "Terminez les quatre hauts faits de soutien du Fouilleur de Midnight pour achever ce méta haut fait.",
    ["Crimson Dragonhawk"] = "Faucon-dragon cramoisi",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Récompense"] = "Récompense",
    ["Détails"] = "Détails",
    ["Critères"] = "Critères",
    ["Info"] = "Infos",
    ["Butin partagé"] = "Butin partagé",
    ["Unknown"] = "Inconnu",
    ["Item"] = "Objet",
    ["Aucune récompense de haut fait indiquée."] = "Aucune récompense de haut fait indiquée.",
    ["Cliquez pour définir un point de passage."] = "Cliquez pour définir un point de passage.",
    ["Suivi pas encore ajouté."] = "Suivi pas encore ajouté.",
    ["Coordonnées en attente."] = "Coordonnées en attente.",
    ["Terminez le parcours de la grotte ici pour obtenir le crédit."] = "Terminez le parcours de la grotte ici pour obtenir le crédit.",
    ["Chargez la pierre runique avec de l’arcane latente pour lancer son événement de défense."] = "Chargez la pierre runique avec de l’arcane latente pour lancer son événement de défense.",
    ["Crédit du haut fait obtenu via :"] = "Crédit du haut fait obtenu via :",
    ["Peinture éternelle"] = "Peinture éternelle",
    ["Suivez les toiles connues de Ever-Painting. x/y indiqués."] = "Suivez les toiles connues de Ever-Painting. x/y indiqués.",
    ["Les entrées suivies pour Ever-Painting n’ont pas encore été ajoutées."] = "Les entrées suivies pour Ever-Painting n’ont pas encore été ajoutées.",
    ["Ruée vers les pierres runiques"] = "Ruée vers les pierres runiques",
    ["Suivez les entrées connues de Runestone Rush. x/y indiqués."] = "Suivez les entrées connues de Runestone Rush. x/y indiqués.",
    ["Les entrées suivies pour Runestone Rush n’ont pas encore été ajoutées."] = "Les entrées suivies pour Runestone Rush n’ont pas encore été ajoutées.",
    ["La fête doit continuer"] = "La fête doit continuer",
    ["Suivez les quatre invitations de faction pour La fête doit continuer. x/y indiqués."] = "Suivez les quatre invitations de faction pour La fête doit continuer. x/y indiqués.",
    ["Les entrées suivies pour La fête doit continuer n’ont pas encore été ajoutées."] = "Les entrées suivies pour La fête doit continuer n’ont pas encore été ajoutées.",
    ["Suivis d’exploration"] = "Suivis d’exploration",
    ["Suivez la progression de Explore Eversong Woods. x/y indiqués."] = "Suivez la progression de Explore Eversong Woods. x/y indiqués.",
    ["Les entrées suivies pour Explore Eversong Woods n’ont pas encore été ajoutées."] = "Les entrées suivies pour Explore Eversong Woods n’ont pas encore été ajoutées.",
    ["Suivez la progression de Explore Voidstorm. x/y indiqués."] = "Suivez la progression de Explore Voidstorm. x/y indiqués.",
    ["Les entrées suivies pour Explore Voidstorm n’ont pas encore été ajoutées."] = "Les entrées suivies pour Explore Voidstorm n’ont pas encore été ajoutées.",
    ["Suivez la progression de Explore Zul'Aman. x/y indiqués."] = "Suivez la progression de Explore Zul'Aman. x/y indiqués.",
    ["Les entrées suivies pour Explore Zul'Aman n’ont pas encore été ajoutées."] = "Les entrées suivies pour Explore Zul'Aman n’ont pas encore été ajoutées.",
    ["Suivez la progression de Explore Harandar. x/y indiqués."] = "Suivez la progression de Explore Harandar. x/y indiqués.",
    ["Les entrées suivies pour Explore Harandar n’ont pas encore été ajoutées."] = "Les entrées suivies pour Explore Harandar n’ont pas encore été ajoutées.",
    ["Thrill of the Chase"] = "Le frisson de la chasse",
    ["Échappez à l’emprise de la Présence affamée dans Voidstorm pendant au moins 60 secondes."] = "Échappez à l’emprise de la Présence affamée dans Voidstorm pendant au moins 60 secondes.",
    ["Ce haut fait n’a pas besoin d’un suivi de coordonnées dans LiteVault. Survivez à l’événement de la Présence affamée dans Voidstorm pendant au moins 60 secondes."] = "Ce haut fait n’a pas besoin d’un suivi de coordonnées dans LiteVault. Survivez à l’événement de la Présence affamée dans Voidstorm pendant au moins 60 secondes.",
    ["Les entrées suivies pour Le frisson de la chasse n’ont pas encore été ajoutées."] = "Les entrées suivies pour Le frisson de la chasse n’ont pas encore été ajoutées.",
    ["Terminez la quête mondiale de Harandar « Application de la griffe » avec 15 charges ou plus de Poursuite du prédateur."] = "Terminez la quête mondiale de Harandar « Application de la griffe » avec 15 charges ou plus de Poursuite du prédateur.",
    ["Ce haut fait n’a pas besoin d’un suivi de coordonnées dans LiteVault. Terminez la quête mondiale de Harandar « Application de la griffe » avec 15 charges ou plus de Poursuite du prédateur."] = "Ce haut fait n’a pas besoin d’un suivi de coordonnées dans LiteVault. Terminez la quête mondiale de Harandar « Application de la griffe » avec 15 charges ou plus de Poursuite du prédateur.",
    ["Les entrées suivies pour Pas le temps de niaiser n’ont pas encore été ajoutées."] = "Les entrées suivies pour Pas le temps de niaiser n’ont pas encore été ajoutées.",
    ["Du berceau à la tombe"] = "Du berceau à la tombe",
    ["Tentez de voler jusqu’au Berceau, haut dans le ciel au-dessus de Harandar."] = "Tentez de voler jusqu’au Berceau, haut dans le ciel au-dessus de Harandar.",
    ["Ces journaux ne sont disponibles que pendant la quête hebdomadaire « Légendes des Haranir ». Pendant une vision, cherchez l’icône de loupe sur votre mini-carte."] = "Ces journaux ne sont disponibles que pendant la quête hebdomadaire « Légendes des Haranir ». Pendant une vision, cherchez l’icône de loupe sur votre mini-carte.",
    ["Récupérez les entrées de journal haranir listées ci-dessous."] = "Récupérez les entrées de journal haranir listées ci-dessous.",
    ["Récupérez les entrées de journal haranir listées ci-dessous. x/y indiqués."] = "Récupérez les entrées de journal haranir listées ci-dessous. x/y indiqués.",
    ["Les légendes ne meurent jamais"] = "Les légendes ne meurent jamais",
    ["Ceci est lié à la quête hebdomadaire « Légendes des Haranir ». Si vous n’avez encore aucune progression, il faut environ 7 semaines pour l’achever."] = "Ceci est lié à la quête hebdomadaire « Légendes des Haranir ». Si vous n’avez encore aucune progression, il faut environ 7 semaines pour l’achever.",
    ["Défendez chaque lieu de légende haranir listé ci-dessous."] = "Défendez chaque lieu de légende haranir listé ci-dessous.",
    ["Protégez chaque lieu de légende haranir listé ci-dessous. x/y indiqués."] = "Protégez chaque lieu de légende haranir listé ci-dessous. x/y indiqués.",
    ["Époussetez-les"] = "Époussetez-les",
    ["Trouvez tous les papillons lumineux cachés dans Harandar. x/y trouvés."] = "Trouvez tous les papillons lumineux cachés dans Harandar. x/y trouvés.",
    ["Les groupes de coordonnées n’ont pas encore été ajoutés."] = "Les groupes de coordonnées n’ont pas encore été ajoutés.",
    ["Ce suivi est divisé en 3 groupes de 40 coordonnées afin que les itinéraires des papillons restent gérables."] = "Ce suivi est divisé en 3 groupes de 40 coordonnées afin que les itinéraires des papillons restent gérables.",
    ["Les papillons 1-40 apparaissent à la Renommée Hara'ti 1, suivi à la Renommée 2."] = "Les papillons 1-40 apparaissent à la Renommée Hara'ti 1, suivi à la Renommée 2.",
    ["Les papillons 41-80 apparaissent à la Renommée Hara'ti 4, suivi à la Renommée 6."] = "Les papillons 41-80 apparaissent à la Renommée Hara'ti 4, suivi à la Renommée 6.",
    ["Les papillons 81-120 apparaissent à la Renommée Hara'ti 9, suivi à la Renommée 11."] = "Les papillons 81-120 apparaissent à la Renommée Hara'ti 9, suivi à la Renommée 11.",
    ["Le routage LiteVault suppose que vous avez déjà débloqué la Renommée Hara'ti 11."] = "Le routage LiteVault suppose que vous avez déjà débloqué la Renommée Hara'ti 11.",
    ["%s contient %d coordonnées de papillons. Cliquez sur un papillon pour placer un point de passage."] = "%s contient %d coordonnées de papillons. Cliquez sur un papillon pour placer un point de passage.",
    ["Group 1"] = "Groupe 1",
    ["Group 2"] = "Groupe 2",
    ["Group 3"] = "Groupe 3",
    ["Un problème singulier"] = "Un problème singulier",
    ["Terminez les trois vagues de l’Assaut de Stormarion. x/y indiqués."] = "Terminez les trois vagues de l’Assaut de Stormarion. x/y indiqués.",
    ["Les entrées suivies pour Un problème singulier n’ont pas encore été ajoutées."] = "Les entrées suivies pour Un problème singulier n’ont pas encore été ajoutées.",
    ["Abondance : Plénitude prospère !"] = "Abondance : Plénitude prospère !",
    ["Terminez une course de grotte Récolte abondante à chaque emplacement. x/y indiqués."] = "Terminez une course de grotte Récolte abondante à chaque emplacement. x/y indiqués.",
    ["Vous devez terminer une course de grotte Récolte abondante à chaque emplacement pour obtenir le crédit. Il ne suffit pas de visiter la grotte."] = "Vous devez terminer une course de grotte Récolte abondante à chaque emplacement pour obtenir le crédit. Il ne suffit pas de visiter la grotte.",
    ["Les entrées suivies pour Abondance : Plénitude prospère ! n’ont pas encore été ajoutées."] = "Les entrées suivies pour Abondance : Plénitude prospère ! n’ont pas encore été ajoutées.",
    ["Autel des bénédictions"] = "Autel des bénédictions",
    ["Déclenchez chaque effet de bénédiction indiqué pour obtenir le crédit."] = "Déclenchez chaque effet de bénédiction indiqué pour obtenir le crédit.",
    ["Déclenchez chaque effet de bénédiction indiqué. x/y indiqués."] = "Déclenchez chaque effet de bénédiction indiqué. x/y indiqués.",
    ["Résumés des méta hauts faits"] = "Résumés des méta hauts faits",
    ["Terminez les hauts faits d’Eversong Woods listés ci-dessous. x/y faits."] = "Terminez les hauts faits d’Eversong Woods listés ci-dessous. x/y faits.",
    ["Terminez tous les hauts faits de Voidstorm listés ci-dessous. x/y faits."] = "Terminez tous les hauts faits de Voidstorm listés ci-dessous. x/y faits.",
    ["Terminez tous les hauts faits de Zul'Aman listés ci-dessous. x/y faits."] = "Terminez tous les hauts faits de Zul'Aman listés ci-dessous. x/y faits.",
    ["Les entrées suivies pour Making an Amani Out of You n’ont pas encore été ajoutées."] = "Les entrées suivies pour Making an Amani Out of You n’ont pas encore été ajoutées.",
    ["Les entrées suivies pour That's Aln, Folks! n’ont pas encore été ajoutées."] = "Les entrées suivies pour That's Aln, Folks! n’ont pas encore été ajoutées.",
    ["Les entrées suivies pour Forever Song n’ont pas encore été ajoutées."] = "Les entrées suivies pour Forever Song n’ont pas encore été ajoutées.",
    ["Les entrées suivies pour Yelling into the Voidstorm n’ont pas encore été ajoutées."] = "Les entrées suivies pour Yelling into the Voidstorm n’ont pas encore été ajoutées.",
    ["Les entrées suivies pour Light Up the Night n’ont pas encore été ajoutées."] = "Les entrées suivies pour Light Up the Night n’ont pas encore été ajoutées.",
    ["Monture : Pétalaile brillante"] = "Monture : Pétalaile brillante",
    ["Décoration de maison : Appel d’On'ohia"] = "Décoration de maison : Appel d’On'ohia",
    ["Titre : \"Seigneur des poussières\""] = "Titre : \"Seigneur des poussières\"",
    ["Libellés de récompense du foyer :"] = "Libellés de récompense du foyer :",
}

L["Raid resync unavailable."] = "Resynchronisation du raid indisponible."
L["Les messages de temps de jeu seront masqués."] = "Les messages de temps de jeu seront masqués."
L["Les messages de temps de jeu ont été rétablis."] = "Les messages de temps de jeu ont été rétablis."
L["%dm %02ds"] = "%d min %02d s"
L["Écus :"] = "Écus :"
L["(Collecté)"] = "(Collecté)"
L["(Non collecté)"] = "(Non collecté)"
L["LABEL_MOUNTS_FMT"] = "Montures : %d/%d"
L["La Flèche du Vide"] = "La Flèche du Vide"
L["The Dreamrift"] = "La Faille onirique"
L["March of Quel'Danas"] = "La Marche de Quel'Danas"
L["Raid Progression"] = "Progression du raid"
L["Lady Liadrin Weekly"] = "Hebdomadaire : Dame Liadrin"
L["Back"] = "Retour"
L["Warband Bank"] = "Banque de bataillon"
L["Traité"] = "Traité"
L["Artisan"] = "Artisan"
L["Catch-up"] = "Rattrapage"
L["Résumé de la mise à jour de LiteVault"] = "Résumé de la mise à jour de LiteVault"
L["Plusieurs éléments essentiels de l’interface ont été actualisés, notamment l’icône des monnaies, l’icône de raid, la barre des métiers et le suivi du Grand coffre."] = "Plusieurs éléments essentiels de l’interface ont été actualisés, notamment l’icône des monnaies, l’icône de raid, la barre des métiers et le suivi du Grand coffre."
L["L’affichage du niveau d’objet du coffre a été mis à jour afin de correspondre davantage à la présentation par défaut du Grand coffre de Blizzard."] = "L’affichage du niveau d’objet du coffre a été mis à jour afin de correspondre davantage à la présentation par défaut du Grand coffre de Blizzard."
L["Un grand nombre de nouvelles traductions ont été ajoutées pour les langues prises en charge."] = "Un grand nombre de nouvelles traductions ont été ajoutées pour les langues prises en charge."
L["L’affichage et l’actualisation du texte localisé ont été améliorés dans l’ensemble de l’addon."] = "L’affichage et l’actualisation du texte localisé ont été améliorés dans l’ensemble de l’addon."
L["La prise en charge de la localisation a été mise à jour pour les boutons, les onglets de sacs, les textes hebdomadaires et d’autres libellés d’interface."] = "La prise en charge de la localisation a été mise à jour pour les boutons, les onglets de sacs, les textes hebdomadaires et d’autres libellés d’interface."
L["Plusieurs problèmes de mise en page liés à la localisation ont été corrigés."] = "Plusieurs problèmes de mise en page liés à la localisation ont été corrigés."
L["Plusieurs plantages liés à la localisation ont été corrigés."] = "Plusieurs plantages liés à la localisation ont été corrigés."

L["Répartition"] = "Répartition"
L["Répartition du bataillon"] = "Répartition du bataillon"
L["BUTTON_RITUAL_SITES"] = "Sites rituels"
L["LABEL_MAX_RENOWN"] = "Renom maximum"
L["LABEL_PARAGON"] = "Parangon"
L["Récompense : %s"] = "Récompense : %s"
L["Chargement des données de récompense..."] = "Chargement des données de récompense..."
L["TOOLTIP_FACTION_CARD_HINT"] = "Cliquez pour afficher cette faction."
L["LABEL_GAINED"] = "Obtenu"
L["LABEL_TOP_SOURCES"] = "Sources principales"
L["LABEL_TOP_INCOME_SOURCE"] = "Principale source de revenus"
L["Principale source de dépenses"] = "Principale source de dépenses"
L["Répartition des sources des revenus et dépenses hebdomadaires de votre bataillon."] = "Répartition des sources des revenus et dépenses hebdomadaires de votre bataillon."
L["Ce qui a rapporté le plus d’or à votre bataillon cette semaine."] = "Ce qui a rapporté le plus d’or à votre bataillon cette semaine."
L["Ce qui a coûté le plus d’or à votre bataillon cette semaine."] = "Ce qui a coûté le plus d’or à votre bataillon cette semaine."
L["Aucun revenu enregistré pour le moment."] = "Aucun revenu enregistré pour le moment."
L["Aucune dépense enregistrée pour le moment."] = "Aucune dépense enregistrée pour le moment."
L["Aucune expédition d’or active trouvée."] = "Aucune expédition d’or active trouvée."
L["Expéditions"] = "Expéditions"
L["Amélioration"] = "Amélioration"
L["Désactiver les marqueurs de pierres runiques"] = "Désactiver les marqueurs de pierres runiques"
L["Masque les marqueurs de pierres runiques de LiteVault sur la carte du bois des Chants éternels."] = "Masque les marqueurs de pierres runiques de LiteVault sur la carte du bois des Chants éternels."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "Activer les surbrillances de profit du calendrier"
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"] = "Affiche des surbrillances vertes et rouges pour les jours de profit dans le calendrier."
L["LABEL_NEXT_WEEK_FMT"] = "Semaine prochaine : %s"
L["LABEL_MONTHLY_PROFIT"] = "Profit mensuel"
L["LABEL_TOP_WEEKLY_EARNERS"] = "Meilleurs gains hebdomadaires"
L["LABEL_TOP_MONTHLY_EARNERS"] = "Meilleurs gains mensuels"

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
L["LABEL_HISTORY_COUNT"] = "Nombre d'entrées dans l'historique"
L["LABEL_LAST_UPDATED"] = "Last Updated"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_TOKEN_AFFORDABLE"] = "Abordable"
L["LABEL_TOKEN_DELTA"] = "Écart"
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
L["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = "Achat de Jeton WoW"
L["TEXT_PROFIT_ITEM_FALLBACK_FMT"] = "Objet %d"
L["TEXT_PROFIT_GOALS_SUBTITLE"] = "Objectifs de bénéfice net hebdomadaires et mensuels pour votre bataillon."
L["TEXT_PROFIT_GOAL_EDITOR_HINT"] = "Saisissez un objectif en pièces d'or. Laissez vide ou saisissez 0 pour l'effacer."
L["TEXT_PROFIT_GRAPH_EMPTY_MONTHLY"] = "No monthly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND"] = "No warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY"] = "No monthly warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"] = "No weekly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_PENDING_MONTHLY"] = "L'historique du graphique mensuel est désormais suivi et se remplira à mesure que vous gagnerez ou dépenserez de l'or."
L["TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"] = "L'historique mensuel du bataillon est désormais suivi et se remplira à mesure que les variations d'or seront enregistrées."
L["TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"] = "No monthly ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WARBAND"] = "No warband ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"] = "No weekly ledger transactions recorded yet."
L["TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"] = "Bénéfice net quotidien du personnage actuel ce mois-ci. Les nouvelles données apparaissent à mesure que les variations d'or sont enregistrées."
L["TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"] = "Transactions mensuelles récentes du personnage actuel."
L["TEXT_PROFIT_SUBTITLE"] = "Weekly and monthly profit across your tracked characters."
L["TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"] = "Bénéfice quotidien cumulé des personnages suivis au cours des 7 derniers jours."
L["TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"] = "Transactions hebdomadaires cumulées récentes des personnages suivis."
L["TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"] = "Bénéfice quotidien cumulé des personnages suivis ce mois-ci."
L["TEXT_PROFIT_SOURCE_AH_FEE"] = "Frais de l'hôtel des ventes"
L["TEXT_PROFIT_SOURCE_BLACK_MARKET"] = "Black Market"
L["TEXT_PROFIT_SOURCE_CHEST"] = "Chest"
L["TEXT_PROFIT_SOURCE_CRAFT"] = "Craft"
L["TEXT_PROFIT_SOURCE_FLIGHT_PATH"] = "Flight Path"
L["TEXT_PROFIT_SOURCE_GUILD_BANK"] = "Guild Bank"
L["TEXT_PROFIT_SOURCE_LOOTED"] = "Looted"
L["TEXT_PROFIT_SOURCE_REPAIR"] = "Repair"
L["TEXT_PROFIT_SOURCE_TRAINING"] = "Training"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "Bénéfice net quotidien du personnage actuel au cours des 7 derniers jours."
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "Transactions hebdomadaires récentes du personnage actuel."
L["TEXT_TRACKED_ACHIEVEMENT_ENTRIES_UNAVAILABLE_FMT"] = "Aucune entrée suivie n'a encore été ajoutée pour %s."
L["TIME_DAYS_AGO_FMT"] = "il y a %d j"
L["TIME_HOURS_AGO_FMT"] = "il y a %d h"
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "il y a %d min"
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
L["TEXT_PROFIT_TOKENS_THIS_MONTH_FMT"] = "Jetons ce mois-ci : %d"
L["TITLE_PROFIT_WOW_TOKENS_THIS_MONTH"] = "Jetons WoW ce mois-ci"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_PROFIT_WOW_TOKENS_THIS_MONTH"] = "Compte les jetons WoW achetés pendant le mois civil en cours. Les achats de jetons sont exclus des bénéfices totaux."
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
L["Discover all of the lore objects found on the Coiled Isle."] = "Découvrez tous les objets de savoir de Coiled Isle."
L["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s contient %d coordonnées de phalènes. Cliquez sur une phalène pour placer un point de passage."
L["Abundance: Prosperous Plentitude!"] = "Abundance: Prosperous Plentitude!"


L["DIFFICULTY_LFR"] = "LFR"
L["LABEL_VAULT_TIER_FMT"] = "Tier %d"
L["LABEL_CRESTS"] = "Crests:"
L["TITLE_MOUNT_DROPS"] = "Mount Drops"
L["STATUS_COLLECTED_PARENS"] = "(Collected)"
L["STATUS_UNCOLLECTED_PARENS"] = "(Uncollected)"

L["BUTTON_BREAKDOWN"] = "Breakdown"
L["BUTTON_WARBAND_PROFIT_BREAKDOWN"] = "Warband Breakdown"
L["LABEL_REWARD_FMT"] = "Récompense : %s"
L["LABEL_REWARD_LOADING"] = "Chargement des données de récompense..."
L["LABEL_TOP_EXPENSE_SOURCE"] = "Principale source de dépenses"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "Répartition des sources des revenus et dépenses hebdomadaires de votre bataillon."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "Où votre bataillon a gagné le plus d’or cette semaine."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "Où votre bataillon a dépensé le plus d’or cette semaine."
L["MSG_PROFIT_NO_INCOME"] = "Aucun revenu enregistré pour le moment."
L["MSG_PROFIT_NO_SPENDING"] = "Aucune dépense enregistrée pour le moment."
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No active gold world quests found."
L["LEDGER_WORLD_QUESTS"] = "World Quests"
L["LEDGER_UPGRADE"] = "Amélioration"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "Désactiver les marqueurs de pierres runiques"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "Masque les marqueurs de pierres runiques de LiteVault sur la carte des bois des Chants éternels."
L["Void Strike"] = "Void Strike"
L["Void Assaults"] = "Void Assaults"
L["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods"
L["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman"
L["Saltheril's Soiree"] = "Saltheril's Soiree"
L["Abundance Event"] = "Abundance Event"
L["Legends of the Haranir"] = "Legends of the Haranir"
L["Darkness Unmade"] = "Darkness Unmade"
L["Harvesting the Void"] = "Harvesting the Void"
L["Engineering"] = "Engineering"
L["Skinning"] = "Skinning"
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
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Time played messages restored."] = "Time played messages restored."
L["The Voidspire"] = "The Voidspire"
L["Treatise"] = "Traité"

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
L["LABEL_FIRST_KILL"] = "Première victoire :"
L["LABEL_EARLIEST_RECORDED_KILL"] = "Première victoire enregistrée :"
L["TEXT_HISTORICAL_DATA_UNAVAILABLE"] = "Données historiques indisponibles"
L["LABEL_KNOWN_KILLS"] = "Victoires connues :"
L["LABEL_ALSO_KILLED_BY"] = "Également vaincu par :"
L["TEXT_KILL_DATE_UNAVAILABLE"] = "Date de victoire indisponible"

L["BUTTON_ZULJARRA_FORCES"] = "Zul'jarra's Forces"
L["BUTTON_CAPTAIN_TOKKA"] = "Capitaine Tokka"
L["LABEL_VALEERA_SANGUINAR"] = "Valeera Sanguinar"
L["LABEL_SLAYERS_DUELLUM"] = "Slayer's Duellum"
L["LABEL_MAXIMUM"] = "Maximum"
L["BUTTON_FACTION_WEEKLIES"] = "Faction Weeklies"
L["TITLE_TREASURES_OF_THE_DAMNED"] = "Treasures of the Damned"
L["LABEL_COMPLETED"] = "Completed"
L["LABEL_NOT_COMPLETED"] = "Not Completed"
L["LABEL_QUEST_FMT"] = "Quête : %s"
L["LABEL_QUEST_ID_FMT"] = "ID de quête : %d"
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
L.LABEL_CURRENT_CHARACTER = L.LABEL_CURRENT_CHARACTER or "Personnage actuel"
L.LABEL_WARBAND_THIS_WEEK = L.LABEL_WARBAND_THIS_WEEK or "Bataillon cette semaine"
L.LABEL_RUNS = L.LABEL_RUNS or "Courses"
L.STATUS_TIMED = L.STATUS_TIMED or "Dans les temps"
L.STATUS_DEPLETED = L.STATUS_DEPLETED or "Épuisée"
L.LABEL_BEST_TIMED = L.LABEL_BEST_TIMED or "Meilleure dans les temps"
L.FILTER_THIS_WEEK = L.FILTER_THIS_WEEK or "Cette semaine"
L.FILTER_SEASON = L.FILTER_SEASON or "Saison"
L.FILTER_ALL_HISTORY = L.FILTER_ALL_HISTORY or "Tout l’historique"
L.SECTION_SEASON_BESTS = L.SECTION_SEASON_BESTS or "Meilleurs de la saison"
L.LABEL_BEST = L.LABEL_BEST or "Meilleur"
L.LABEL_SCORE = L.LABEL_SCORE or "Cote"
L.LABEL_NO_RUN = L.LABEL_NO_RUN or "Aucune course"
L.LABEL_LOWEST_SCORE = L.LABEL_LOWEST_SCORE or "Cote la plus basse"
L.LABEL_NO_MPLUS_KEY = L.LABEL_NO_MPLUS_KEY or "Aucune clé M+"
L.LABEL_DUNGEON = L.LABEL_DUNGEON or "Donjon"
L.LABEL_KEY = L.LABEL_KEY or "Clé"
L.LABEL_RESULT = L.LABEL_RESULT or "Résultat"
L.LABEL_TIME = L.LABEL_TIME or "Temps"
L.LABEL_DATE = L.LABEL_DATE or "Date"
L.LABEL_REWARDS = L.LABEL_REWARDS or "Récompenses"
L.LABEL_MAP_RECORD = L.LABEL_MAP_RECORD or "Record du donjon"
L.LABEL_AFFIX_RECORD = L.LABEL_AFFIX_RECORD or "Record d’affixes"
L.LABEL_MPLUS_SCORE_PLAIN = L.LABEL_MPLUS_SCORE_PLAIN or "Cote M+"
L.LABEL_TIMER = L.LABEL_TIMER or "Chronomètre"
L.LABEL_TIME_REMAINING = L.LABEL_TIME_REMAINING or "Temps restant"
L.LABEL_OVER_TIMER = L.LABEL_OVER_TIMER or "Temps dépassé"
L.LABEL_RECORDED_DURATION = L.LABEL_RECORDED_DURATION or "Durée enregistrée"
L.LABEL_NOT_AVAILABLE = L.LABEL_NOT_AVAILABLE or "--"
L.SECTION_MPLUS_HISTORY = L.SECTION_MPLUS_HISTORY or "Historique Mythique+"
L.TEXT_NO_MPLUS_RUNS_THIS_WEEK = L.TEXT_NO_MPLUS_RUNS_THIS_WEEK or "Aucune course Mythique+ terminée cette semaine."
L.TEXT_NO_MPLUS_RUNS_THIS_SEASON = L.TEXT_NO_MPLUS_RUNS_THIS_SEASON or "Aucune course Mythique+ terminée cette saison."
L.TEXT_NO_MPLUS_RUNS_RECORDED = L.TEXT_NO_MPLUS_RUNS_RECORDED or "Aucune course Mythique+ enregistrée."
L.BUTTON_PLAN_RATING = L.BUTTON_PLAN_RATING or "Planifier la cote"
L.TITLE_MPLUS_RATING_PLANNER = L.TITLE_MPLUS_RATING_PLANNER or "Planificateur de cote M+"
L.BUTTON_BACK_TO_DASHBOARD = L.BUTTON_BACK_TO_DASHBOARD or "Retour au tableau de bord"
L.LABEL_CURRENT_RATING = L.LABEL_CURRENT_RATING or "Cote actuelle"
L.LABEL_TARGET_RATING = L.LABEL_TARGET_RATING or "Cote cible"
L.LABEL_MINIMUM_KEY = L.LABEL_MINIMUM_KEY or "Clé minimale"
L.LABEL_MAXIMUM_KEY = L.LABEL_MAXIMUM_KEY or "Clé maximale"
L.LABEL_AVOID_DUNGEONS = L.LABEL_AVOID_DUNGEONS or "Donjons à éviter"
L.BUTTON_CALCULATE_PLAN = L.BUTTON_CALCULATE_PLAN or "Calculer le plan"
L.LABEL_MAXIMUM_PROJECTED_RATING = L.LABEL_MAXIMUM_PROJECTED_RATING or "Cote projetée maximale"
L.LABEL_PROJECTED_RATING = L.LABEL_PROJECTED_RATING or "Cote projetée"
L.LABEL_CURRENT = L.LABEL_CURRENT or "Actuel"
L.LABEL_PLAN = L.LABEL_PLAN or "Plan"
L.LABEL_GAIN = L.LABEL_GAIN or "Gain"
L.TEXT_PLANNER_ALREADY_REACHED = L.TEXT_PLANNER_ALREADY_REACHED or "Vous avez déjà atteint cette cote."
L.TEXT_PLANNER_UNREACHABLE = L.TEXT_PLANNER_UNREACHABLE or "La cible est inaccessible avec les limites actuelles."
L.TEXT_PLANNER_INVALID_MINIMUM = L.TEXT_PLANNER_INVALID_MINIMUM or "La clé minimale doit être un entier supérieur ou égal à 2."
L.TEXT_PLANNER_INVALID_MAXIMUM = L.TEXT_PLANNER_INVALID_MAXIMUM or "La clé maximale doit être au moins égale au minimum et ne pas dépasser 20."
L.TEXT_PLANNER_INVALID_TARGET = L.TEXT_PLANNER_INVALID_TARGET or "Saisissez une cote cible entière valide."
L.TEXT_PLANNER_TIMED_ASSUMPTION = L.TEXT_PLANNER_TIMED_ASSUMPTION or "La projection suppose que chaque clé suggérée est terminée dans les temps."
L.PLANNER_FASTEST = L.PLANNER_FASTEST or "PLUS RAPIDE"
L.PLANNER_BALANCED = L.PLANNER_BALANCED or "ÉQUILIBRÉ"
L.PLANNER_EASIEST = L.PLANNER_EASIEST or "PLUS FACILE"
local phase2 = {
MSG_NO_FACTION_WEEKLY_COMPLETIONS="Aucune activité hebdomadaire terminée enregistrée.", TOOLTIP_QUEST_ID_FMT="ID : |cffffffff%d", CALENDAR_MONTH_YEAR_FMT="%s %d",
LABEL_RENOWN_LEVEL_MAXIMUM_FMT="Niveau de renom %d – Maximum", LABEL_RENOWN_LEVEL_PROGRESS_FMT="Niveau de renom %d (%d/%d)", LABEL_RENOWN_LEVEL_FMT="Niveau de renom %d", LABEL_RENOWN_VALUE_FMT="Renom %d",
TEXT_CRESTS_WITH_VALUES_FMT="Écussons %s", TOOLTIP_REWARDS_FMT="Récompenses : %s", TOOLTIP_MOUNT_COLLECTED_FMT="%s (Obtenue)", TOOLTIP_MOUNT_UNCOLLECTED_FMT="%s (Non obtenue)", LABEL_REWARD="Récompense", LABEL_NOTE="Remarque", STATUS_ACTIVE="Actif",
TOOLTIP_ENTRANCE_COORDINATES_FMT="Entrée : %.2f, %.2f (carte %d)", TOOLTIP_INSCRIPTION_COORDINATES_FMT="Inscription : %.2f, %.2f (carte %d)", TOOLTIP_ENTRANCE_INSCRIPTION_CLICK_INSTRUCTIONS="Maj-clic pour l’entrée ; clic pour l’inscription.", LABEL_100_RENOWN_FMT="100 de renom : %s", TOOLTIP_ACHIEVEMENT_CREDIT_FROM_FMT="Crédit de haut fait accordé par : %s",
NOTE_HARANDAR_TREASURE_REQUIREMENTS="Certains trésors nécessitent des étapes ou des objets supplémentaires.", NOTE_FORGOTTEN_MASK_LOCATION="Sur un mur de pierre brisé de l’île de Gnarldor, au sud de l’entrée du gouffre.", NOTE_HEAD_MASONS_TABLET_LOCATION="Dans la porte du Croc oriental. Entrée : 45.72, 64.94 sur la carte 2512.", NOTE_PROFANED_PLAQUE_LOCATION="Dans la porte du Croc occidental, dans la salle immédiatement à gauche après l’entrée. Entrée : 31.80, 64.91 sur la carte 2512.",
BUTTON_CANCEL="Annuler", BUTTON_SAVE="Enregistrer", BUTTON_SELECT_ALL="Tout sélectionner", LABEL_COMPLETED="Terminé", LABEL_NOT_COMPLETED="Non terminé", LABEL_DETAILS="Détails", LABEL_DETAIL="Détail", LABEL_INFO="Infos", LABEL_MAXIMUM="Maximum", LABEL_PREVIOUS="Précédent", LABEL_RECENT_HISTORY="Historique récent", LABEL_SOURCE="Source", LABEL_STATUS="Statut", TIME_JUST_NOW="À l’instant", TIME_YESTERDAY="Hier",
BUTTON_BACK_TO_GROUPS="Retour aux groupes", TEXT_COORDINATE_GROUPS_NOT_AVAILABLE="Les groupes de coordonnées n’ont pas encore été ajoutés.", TEXT_ZONE_REWARD_NOT_AVAILABLE="Récompense de zone pas encore ajoutée.", TEXT_META_REWARD_NOT_AVAILABLE="Récompense de méta haut fait pas encore ajoutée.", TEXT_ACHIEVEMENT_REWARD_NOT_LISTED="Aucune récompense de haut fait indiquée.", TOOLTIP_RUNESTONE_CHARGE_INSTRUCTION="Chargez la pierre runique avec de l’arcane latent pour lancer son événement de défense.", TEXT_COORDINATES_PENDING="Coordonnées en attente.", TOOLTIP_CLICK_OPEN_TRACKER="Cliquez pour ouvrir ce suivi.", TEXT_TRACKER_NOT_AVAILABLE="Suivi pas encore ajouté.",
MSG_PROFIT_GOAL_INVALID="Saisissez un montant d’or valide.", MSG_PROFIT_GOAL_NOT_SET="Aucun objectif défini", TEXT_PROFIT_EXPORT_HINT="Cliquez dans la zone et appuyez sur Ctrl+C pour copier.", TEXT_PROFIT_EXPORT_SUBTITLE="Copiez le texte CSV ci-dessous.", TEXT_PROFIT_SOURCE_BLACK_MARKET="Marché noir", TEXT_PROFIT_SOURCE_CHEST="Coffre", TEXT_PROFIT_SOURCE_CRAFT="Artisanat", TEXT_PROFIT_SOURCE_FLIGHT_PATH="Maître de vol", TEXT_PROFIT_SOURCE_GUILD_BANK="Banque de guilde", TEXT_PROFIT_SOURCE_LOOTED="Butin", TEXT_PROFIT_SOURCE_REPAIR="Réparation", TEXT_PROFIT_SOURCE_TRAINING="Entraînement", TEXT_PROFIT_SOURCE_WORLD_QUEST="Expédition", MSG_RAID_RESYNC_COMPLETE="Resynchronisation du raid terminée.", MSG_RAID_RESYNC_STARTED="Resynchronisation du raid lancée...", MSG_RAID_RESYNC_UNAVAILABLE="Resynchronisation du raid indisponible.",
TEXT_PROFIT_FALLBACK_APPEARANCE_COST="Coût d’apparence", TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT="Dépôt aux enchères", TEXT_PROFIT_FALLBACK_AUCTION_FEE="Commission de l’hôtel des ventes", TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE="Achat aux enchères", TEXT_PROFIT_FALLBACK_AUCTION_SALE="Vente aux enchères", TEXT_PROFIT_FALLBACK_BARBER_COST="Coût du salon de coiffure", TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE="Achat au marché noir", TEXT_PROFIT_FALLBACK_CRAFTING_ORDER="Commande d’artisanat", TEXT_PROFIT_FALLBACK_GEAR_UPGRADE="Amélioration d’équipement", TEXT_PROFIT_FALLBACK_GOLD_RECEIVED="Or reçu", TEXT_PROFIT_FALLBACK_GOLD_REWARD="Récompense en or", TEXT_PROFIT_FALLBACK_GOLD_SENT="Or envoyé", TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT="Dépôt de guilde", TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL="Retrait de guilde", TEXT_PROFIT_FALLBACK_RAW_GOLD="Or brut", TEXT_PROFIT_FALLBACK_SERVICE_COST="Coût de service", TEXT_PROFIT_FALLBACK_TRADE_GAIN="Gain d’échange", TEXT_PROFIT_FALLBACK_TRADE_PAYMENT="Paiement d’échange", TEXT_PROFIT_FALLBACK_TRAINING_COST="Coût d’apprentissage", TEXT_PROFIT_FALLBACK_TRAVEL_COST="Frais de voyage", TEXT_PROFIT_GRAPH_EMPTY_MONTHLY="Aucun historique mensuel de bénéfices enregistré.", TEXT_PROFIT_GRAPH_EMPTY_WARBAND="Aucun historique de bénéfices du bataillon enregistré.", TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY="Aucun historique mensuel de bénéfices du bataillon enregistré.", TEXT_PROFIT_GRAPH_EMPTY_WEEKLY="Aucun historique hebdomadaire de bénéfices enregistré.", TEXT_PROFIT_LEDGER_EMPTY_MONTHLY="Aucune transaction mensuelle enregistrée dans le registre.", TEXT_PROFIT_LEDGER_EMPTY_WARBAND="Aucune transaction du bataillon enregistrée dans le registre.", TEXT_PROFIT_LEDGER_EMPTY_WEEKLY="Aucune transaction hebdomadaire enregistrée dans le registre.", TEXT_PROFIT_SUBTITLE="Bénéfices hebdomadaires et mensuels de vos personnages suivis.",
BUTTON_BREAKDOWN="Répartition", BUTTON_FILTER="Filtrer", BUTTON_SET="Définir", BUTTON_RAIDS="Raids", BUTTON_WARBAND_BANK_HISTORY="Historique de la banque du bataillon", TITLE_TREASURES_OF_THE_DAMNED="Trésors des damnés", TOOLTIP_TOKKA_TREASURE_HINT="Pêchez cet artéfact sur Coiled Isle et rapportez-le à Second Mate Sluggs à Tokka's Folly.", WARNING_TOKKA_ONE_TIME_ARTIFACTS="Attention : ces quêtes d’artéfact sont des remises uniques pour le bataillon. Elles ne se réinitialisent ni chaque jour ni chaque semaine et ne confèrent de la réputation qu’une fois.", MSG_RAID_HISTORY_PRESERVED="L’historique des raids a été conservé ; la réinitialisation destructive de saison est désactivée.", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", TITLE_MINI_OMNIUM_FOLIO="Folio d’Omnium", TOOLTIP_HIDE_MINI_FOLIO="Masquer le mini folio", TOOLTIP_LOCK_MINI_FOLIO="Verrouiller le mini folio", TOOLTIP_UNLOCK_MINI_FOLIO="Déverrouiller le mini folio", TAB_GLYPHS="Glyphes", TITLE_GLYPH_HUNTER="Chasseur de glyphes", TOOLTIP_RUNESTONE_SET_WAYPOINT="Cliquez pour placer un point de passage.", LABEL_CHARACTER_TIME="Temps du personnage", LABEL_LAST_UPDATED="Dernière mise à jour", LABEL_VAULT_OVERALL_PROGRESS="Progression globale : %d/%d", LABEL_VAULT_ROW_DUNGEONS="Donjons", TITLE_CHARACTER_GREAT_VAULT_FMT="Grande chambre forte de %s : %s", TITLE_CHARACTER_WEEKLY_PLANNER_FMT="Planificateur hebdomadaire de %s : %s", LABEL_NEXT_WEEK_FMT="Semaine prochaine : %s",
BUTTON_EDIT_MONTHLY_GOAL="Modifier l’objectif mensuel", BUTTON_EDIT_WEEKLY_GOAL="Modifier l’objectif hebdomadaire", BUTTON_EXPORT_CSV="Exporter en CSV", BUTTON_MONTHLY_PROFIT_EXPORT="Bénéfices mensuels en CSV", BUTTON_WARBAND_PROFIT_BREAKDOWN="Répartition du bataillon", BUTTON_WARBAND_PROFIT_EXPORT="Bénéfices hebdomadaires du bataillon en CSV", BUTTON_WEEKLY_PROFIT_EXPORT="Bénéfices hebdomadaires en CSV", LABEL_GOAL_AMOUNT="Montant de l’objectif (or)", LABEL_GOLD="Or", LABEL_NET="Net", LABEL_SHARE="Partager", LABEL_ZONE="Zone", LABEL_WARBAND_WEEKLY_PROFIT="Bénéfices hebdomadaires du bataillon", MSG_NIT_TIMEPLAYED_WARNING="NovaInstanceTracker détecté. Le message /played peut être masqué par NIT même si l’option de LiteVault est désactivée.", MSG_TIMEPLAYED_RESTORED="Les messages de temps de jeu ont été rétablis.", MSG_TIMEPLAYED_SUPPRESSED="Les messages de temps de jeu seront masqués.", MSG_WOW_TOKEN_API_UNAVAILABLE="L’API du Jeton WoW n’est pas disponible dans ce client.", MSG_WOW_TOKEN_DATA_UNAVAILABLE="Données du Jeton WoW indisponibles.", MSG_WOW_TOKEN_VISIT_AH="Consultez l’hôtel des ventes pour actualiser le prix du Jeton WoW.", OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC="Affiche des repères verts et rouges sur les jours de bénéfice ou de perte du calendrier.",
TITLE_ACHIEVEMENTS="Hauts faits", LABEL_ACHIEVEMENT_GROUPS="Groupes", LABEL_GLOWING_MOTHS="Phalènes", LABEL_SHARED_LOOT="Butin partagé", LABEL_KNOWLEDGE_CATCHUP="Rattrapage", STATUS_ASSAULT_WAVE_1_COMPLETE="Vague 1 terminée", STATUS_ASSAULT_WAVE_2_COMPLETE="Vague 2 terminée", STATUS_ASSAULT_WAVE_3_COMPLETE="Vague 3 terminée", TEXT_MIDNIGHT_RARES_TRACKER_DESCRIPTION="Suivez les hauts faits de créatures rares de Midnight, leurs récompenses et le butin partagé.", TEXT_MIDNIGHT_TREASURES_TRACKER_DESCRIPTION="Suivez les hauts faits de trésors de Midnight et leurs récompenses.", TEXT_HARANIR_JOURNAL_INSTRUCTION="Récupérez les entrées du journal haranir indiquées ci-dessous.", TEXT_HARANIR_LEGEND_DEFENSE_INSTRUCTION="Défendez chaque lieu de légende haranir indiqué ci-dessous.", TEXT_BLESSING_EFFECT_INSTRUCTION="Déclenchez chaque effet de bénédiction indiqué pour obtenir le crédit.", TOOLTIP_CAVE_RUN_CREDIT_INSTRUCTION="Terminez le parcours de cette grotte pour obtenir le crédit.", TEXT_TELESCOPE_ZONE_REQUIREMENT="Terminez les cinq télescopes de cette zone.",
TEXT_MIDNIGHT_DELVER_META_INSTRUCTION="Terminez les quatre hauts faits de gouffres associés à Midnight pour achever ce méta haut fait.", TEXT_COILED_ISLE_META_INSTRUCTION="Terminez les hauts faits de Coiled Isle.", TEXT_MIDNIGHT_ZONE_META_REWARD_REQUIREMENT="Terminez les quatre méta hauts faits de zone de Midnight et obtenez la monture en récompense.", TEXT_CLAW_ENFORCEMENT_REQUIREMENT="Terminez l’expédition de Harandar 'Claw Enforcement' avec au moins 15 charges de Predator's Pursuit.", TEXT_ATALUTEK_META_INSTRUCTION="Terminez les hauts faits de Vaults of Atal'Utek.", TEXT_COILED_ISLE_LORE_INSTRUCTION="Découvrez les objets de savoir de Coiled Isle.", TEXT_HUNGERING_PRESENCE_REQUIREMENT="Échappez à l’emprise de Hungering Presence dans Voidstorm pendant au moins 60 secondes.", TEXT_CRADLE_FLIGHT_REQUIREMENT="Volez jusque dans The Cradle, très haut au-dessus de Harandar, pour accomplir ce haut fait.", TEXT_EVERSONG_META_TRACKER_DESCRIPTION="Suivez le méta haut fait d’Eversong Woods et accédez à ses suivis enfants.", TEXT_MIDNIGHT_PEAKS_TRACKER_DESCRIPTION="Suivez les quatre hauts faits de zone de Midnight, the Highest Peaks.", TEXT_HARANDAR_META_TRACKER_DESCRIPTION="Suivez le méta haut fait de Harandar et accédez à ses suivis enfants.", TEXT_VOIDSTORM_META_TRACKER_DESCRIPTION="Suivez le méta haut fait de Voidstorm et accédez à ses suivis enfants.", TEXT_ZULAMAN_META_TRACKER_DESCRIPTION="Suivez le méta haut fait de Zul'Aman et accédez à ses suivis enfants.", TEXT_CRADLE_FLIGHT_ATTEMPT="Essayez de voler jusqu’à The Cradle, très haut au-dessus de Harandar.", NOTE_MOTH_ROUTE_RENOWN_REQUIREMENT="Le parcours de LiteVault suppose que Hara'ti Renown 11 est déjà débloqué.",
TEXT_HARATI_META_PROGRESS_INSTRUCTION="Aidez les Hara'ti en accomplissant les hauts faits ci-dessous. x/y terminés.", TEXT_VOIDSTORM_META_PROGRESS_INSTRUCTION="Accomplissez tous les hauts faits de Voidstorm indiqués ci-dessous. x/y terminés.", TEXT_ZULAMAN_META_PROGRESS_INSTRUCTION="Accomplissez tous les hauts faits de Zul'Aman indiqués ci-dessous. x/y terminés.", TEXT_STORMARION_ASSAULT_PROGRESS_INSTRUCTION="Terminez les trois vagues de Stormarion Assault. x/y validées.", TEXT_ABUNDANT_HARVEST_PROGRESS_INSTRUCTION="Terminez un parcours de grotte Abundant Harvest à chaque emplacement. x/y validés.", TEXT_EVERSONG_META_PROGRESS_INSTRUCTION="Accomplissez les hauts faits d’Eversong Woods indiqués ci-dessous. x/y terminés.", TEXT_GLOWING_MOTH_PROGRESS="Trouvez toutes les Glowing Moths cachées en Harandar. x/y trouvées.", TEXT_HARANIR_LEGEND_PROGRESS="Protégez chaque lieu de légende haranir indiqué ci-dessous. x/y validés.", TEXT_XALATATH_META_PROGRESS="Ralliez vos forces contre Xal'atath en accomplissant les hauts faits ci-dessous. x/y terminés.", TEXT_HARANIR_JOURNAL_PROGRESS="Récupérez les entrées du journal haranir indiquées ci-dessous. x/y validées.", TEXT_BLESSING_EFFECT_PROGRESS="Déclenchez chaque effet de bénédiction indiqué. x/y validés.", TEXT_FACTION_INVITE_PROGRESS="Suivez les quatre invitations de faction de The Party Must Go On. x/y validées.", TEXT_EVER_PAINTING_PROGRESS="Suivez les tableaux connus d’Ever-Painting. x/y validés.", TEXT_RUNESTONE_RUSH_PROGRESS="Suivez les entrées connues de Runestone Rush. x/y validées.",
TEXT_DELVER_MOUNT_REWARD_REQUIREMENT="Accomplissez Glory of the Midnight Delver pour obtenir cette monture.", NOTE_MOTH_GROUP_1_RENOWN="Les phalènes 1 à 40 apparaissent à Hara'ti Renown 1, et leur suivi à Renown 2.", NOTE_MOTH_GROUP_2_RENOWN="Les phalènes 41 à 80 apparaissent à Hara'ti Renown 4, et leur suivi à Renown 6.", NOTE_MOTH_GROUP_3_RENOWN="Les phalènes 81 à 120 apparaissent à Hara'ti Renown 9, et leur suivi à Renown 11.", NOTE_HARANIR_JOURNAL_AVAILABILITY="Ces journaux ne sont disponibles que pendant la quête hebdomadaire liée au compte 'Legends of the Haranir'. Dans une vision, cherchez l’icône de loupe sur la minicarte.", NOTE_CLAW_ENFORCEMENT_NO_COORDINATES="Ce haut fait ne nécessite pas de suivi de coordonnées dans LiteVault. Terminez l’expédition de Harandar 'Claw Enforcement' avec au moins 15 charges de Predator's Pursuit.", NOTE_HUNGERING_PRESENCE_NO_COORDINATES="Ce haut fait ne nécessite pas de suivi de coordonnées dans LiteVault. Survivez à l’événement Hungering Presence dans Voidstorm pendant au moins 60 secondes.", NOTE_HARANIR_LEGENDS_WEEKLY_ESTIMATE="Ceci est lié à la quête hebdomadaire liée au compte 'Legends of the Haranir'. Sans progression, comptez environ 7 semaines pour terminer.", NOTE_MOTH_TRACKER_GROUPING="Ce suivi est divisé en 3 groupes de 40 coordonnées afin que les parcours des phalènes restent faciles à gérer.", TEXT_EVER_PAINTING_TRACKER_PLACEHOLDER="Suivez la progression d’Ever-Painting. Les détails pourront être ajoutés plus tard.", TEXT_EXPLORE_EVERSONG_TRACKER_PLACEHOLDER="Suivez la progression d’Explore Eversong Woods. Les détails pourront être ajoutés plus tard.", TEXT_RUNESTONE_RUSH_TRACKER_PLACEHOLDER="Suivez la progression de Runestone Rush. Les détails pourront être ajoutés plus tard.", TEXT_PARTY_TRACKER_PLACEHOLDER="Suivez la progression de The Party Must Go On. Les détails pourront être ajoutés plus tard.", TOOLTIP_ABUNDANT_HARVEST_CREDIT_REQUIREMENT="Vous devez terminer un parcours de grotte Abundant Harvest à chaque emplacement. Une simple visite ne suffit pas.",
TEXT_EXPLORE_EVERSONG_PROGRESS="Suivez la progression d’Explore Eversong Woods. x/y validés.", TEXT_EXPLORE_HARANDAR_PROGRESS="Suivez la progression d’Explore Harandar. x/y validés.", TEXT_EXPLORE_VOIDSTORM_PROGRESS="Suivez la progression d’Explore Voidstorm. x/y validés.", TEXT_EXPLORE_ZULAMAN_PROGRESS="Suivez la progression d’Explore Zul'Aman. x/y validés.",
}
for key,value in pairs(phase2) do L[key]=value end
lv.RegisterLocale("frFR", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["frFR"] = L
