-- frFR.lua - French locale for LiteVault
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
    BUTTON_CLOSE = "Fermer",
    BUTTON_YES = "Oui",
    BUTTON_NO = "Non",
    BUTTON_MANAGE = "Gérer",
    BUTTON_BACK = "Retour",
    BUTTON_ALL = "Tous",
    BUTTON_NONE = "Aucun",
    BUTTON_FILTER = "Filtrer",
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

    TOOLTIP_VAULT_TITLE = "Grande chambre forte",
    TOOLTIP_VAULT_DESC = "Appuyer pour ouvrir la grande chambre forte",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Ouvrir la Grande chambre forte.",
    TOOLTIP_VAULT_ALT_ONLY = "La Grande chambre forte ne peut être ouverte que pour le personnage actif.",

    TOOLTIP_CURRENCY_TITLE = "Devises du personnage",
    TOOLTIP_CURRENCY_DESC = "Cliquer pour voir la liste complète.",
    TOOLTIP_BAGS_TITLE = "Voir les sacs",
    TOOLTIP_BAGS_DESC = "Voir le contenu des sacs et des sacs de réactifs sauvegardés.",

    TOOLTIP_LEDGER_TITLE = "Registre de profit hebdo",
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
    BUTTON_LEDGER = "Registre",
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
    TITLE_RAID_LOCKOUTS_WINDOW = "Verrouillages de raid",
    TITLE_RAID_FORMAT = "%s %s %s - Forge de mana Omega",

    BUTTON_PROGRESSION = "Progression",
    BUTTON_LOCKOUTS = "Verrouillages",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Héroïque",
    DIFFICULTY_MYTHIC = "Mythique",

    TOOLTIP_VIEW_LOCKOUTS = "Affichage actuel: Verrouillages (cette semaine)",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "Cliquer pour voir la Progression (meilleur résultat)",
    TOOLTIP_VIEW_PROGRESSION = "Affichage actuel: Progression (meilleur résultat)",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "Cliquer pour voir les Verrouillages (cette semaine)",

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
    TITLE_WEEKLY_LEDGER = "%s - Registre hebdo",
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
    MSG_LEDGER_NOT_AVAILABLE = "Registre non disponible.",
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
    OPTION_DARK_MODE = "Mode sombre",
    OPTION_DARK_MODE_DESC = "Basculer entre les thèmes sombre et clair",
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
    ["Saltheril's Soiree"] = "Soirée de Saltheril",
    ["Abundance Event"] = "Événement d'abondance",
    ["Legends of the Haranir"] = "Légendes des Haranir",
    ["Stormarion Assault"] = "Assaut de Stormarion",
    ["Darkness Unmade"] = "Ténèbres Défaites",
    ["Harvesting the Void"] = "Récolte du Vide",
    ["Midnight: Saltheril's Soiree"] = "Minuit : soirée de Saltheril",
    ["Fortify the Runestones: Blood Knights"] = "Fortifier les pierres runiques : chevaliers de sang",
    ["Fortify the Runestones: Shades of the Row"] = "Fortifier les pierres runiques : ombres de la rue",
    ["Fortify the Runestones: Magisters"] = "Fortifier les pierres runiques : magistères",
    ["Fortify the Runestones: Farstriders"] = "Fortifier les pierres runiques : pérégrins",
    ["Put a Little Snap in Their Step"] = "Mettez plus d'entrain dans leur pas",
    ["Light Snacks"] = "Collations légères",
    ["Less Lawless"] = "Moins d'anarchie",
    ["The Subtle Game"] = "Le jeu subtil",
    ["Courting Success"] = "Courtiser le succès",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Alchimie",
    ["Blacksmithing"] = "Forge",
    ["Enchanting"] = "Enchantement",
    ["Engineering"] = "Ingénierie",
    ["Inscription"] = "Calligraphie",
    ["Jewelcrafting"] = "Joaillerie",
    ["Leatherworking"] = "Travail du cuir",
    ["Tailoring"] = "Couture",
    ["Herbalism"] = "Herboristerie",
    ["Mining"] = "Minage",
    ["Skinning"] = "Dépeçage",

    ["Remnant of Anguish"] = "Vestige d'angoisse",
    ["Shard of Dundun"] = "Éclat de Dundun",
    ["Adventurer Dawncrest"] = "Écu de l'Aube d'aventurier",
    ["Veteran Dawncrest"] = "Écu de l'Aube de vétéran",
    ["Champion Dawncrest"] = "Écu de l'Aube de champion",
    ["Hero Dawncrest"] = "Écu de l'Aube de héros",
    ["Myth Dawncrest"] = "Écu de l'Aube mythique",
    ["Brimming Arcana"] = "Mystères débordants",
    ["Throw the Dice"] = "Lancez les dés",
    ["We Need a Refill"] = "Nous avons besoin de réapprovisionner",
    ["Lovely Plumage"] = "Joli plumage",
    ["The Cauldron of Echoes"] = "Le chaudron des échos",
    ["The Echoless Flame"] = "La flamme sans écho",
    ["Hidey-Hole"] = "Cachette",
    ["Victorious Stormarion Pinnacle Cache"] = "Cache du Pinnacle de Stormarion victorieuse",
    ["Overflowing Abundant Satchel"] = "Sacoche débordante d’abondance",
    ["Avid Learner's Supply Pack"] = "Paquet de fournitures de l’apprenant assidu",
    ["Surplus Bag of Party Favors"] = "Sac excédentaire de cadeaux de fête",
    ["Voidlight Marl"] = "Marne de Néantlumière",
    ["Undercoin"] = "Sous-pièce",
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
    TIME_YESTERDAY = "Hier %H:%M",
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
    ["Coffer Key Shards"] = "Éclats de clé de coffre",
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
    ["Treasures of Midnight"] = "Trésors de Midnight",
    ["Track the four Midnight treasure achievements and their rewards."] = "Suivez les quatre hauts faits de trésors de Midnight et leurs récompenses.",
    ["Glory of the Midnight Delver"] = "Gloire du Fouilleur de Midnight",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "Terminez « Gloire du Fouilleur de Midnight » pour obtenir cette monture.",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "Suivez les quatre hauts faits de rares de Midnight et les récompenses des rares de zone.",
    ["Track the four Midnight rare achievements."] = "Suivez les quatre hauts faits de rares de Midnight.",
    ["Complete the five telescopes in this zone."] = "Terminez les cinq télescopes de cette zone.",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "Terminez les quatre hauts faits de soutien du Fouilleur de Midnight pour achever ce méta haut fait.",
    ["Crimson Dragonhawk"] = "Faucon-dragon cramoisi",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Achievements"] = "Hauts faits",
    ["Reward"] = "Récompense",
    ["Details"] = "Détails",
    ["Criteria"] = "Critères",
    ["Info"] = "Infos",
    ["Shared Loot"] = "Butin partagé",
    ["Groups"] = "Groupes",
    ["Back to Groups"] = "Retour aux groupes",
    ["Back"] = "Retour",
    ["Unknown"] = "Inconnu",
    ["Item"] = "Objet",
    ["No achievement reward listed."] = "Aucune récompense de haut fait indiquée.",
    ["Click to set waypoint."] = "Cliquez pour définir un point de passage.",
    ["Click to open this tracker."] = "Cliquez pour ouvrir ce suivi.",
    ["Tracker not added yet."] = "Suivi pas encore ajouté.",
    ["Coordinates pending."] = "Coordonnées en attente.",
    ["Complete the cave run here for credit."] = "Terminez le parcours de la grotte ici pour obtenir le crédit.",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "Chargez la pierre runique avec de l’arcane latente pour lancer son événement de défense.",
    ["Achievement credit from:"] = "Crédit du haut fait obtenu via :",
    ["Stormarion Assault"] = "Assaut sur Stormarion",
    ["Ever-Painting"] = "Peinture éternelle",
    ["Track the known Ever-Painting canvases. x/y marked."] = "Suivez les toiles connues de Ever-Painting. x/y indiqués.",
    ["Tracked entries for Ever-Painting have not been added yet."] = "Les entrées suivies pour Ever-Painting n’ont pas encore été ajoutées.",
    ["Runestone Rush"] = "Ruée vers les pierres runiques",
    ["Track the known Runestone Rush entries. x/y marked."] = "Suivez les entrées connues de Runestone Rush. x/y indiqués.",
    ["Tracked entries for Runestone Rush have not been added yet."] = "Les entrées suivies pour Runestone Rush n’ont pas encore été ajoutées.",
    ["The Party Must Go On"] = "La fête doit continuer",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "Suivez les quatre invitations de faction pour La fête doit continuer. x/y indiqués.",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "Les entrées suivies pour La fête doit continuer n’ont pas encore été ajoutées.",
    ["Explore trackers"] = "Suivis d’exploration",
    ["Track Explore Eversong Woods progress. x/y marked."] = "Suivez la progression de Explore Eversong Woods. x/y indiqués.",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "Les entrées suivies pour Explore Eversong Woods n’ont pas encore été ajoutées.",
    ["Track Explore Voidstorm progress. x/y marked."] = "Suivez la progression de Explore Voidstorm. x/y indiqués.",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "Les entrées suivies pour Explore Voidstorm n’ont pas encore été ajoutées.",
    ["Track Explore Zul'Aman progress. x/y marked."] = "Suivez la progression de Explore Zul'Aman. x/y indiqués.",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "Les entrées suivies pour Explore Zul'Aman n’ont pas encore été ajoutées.",
    ["Track Explore Harandar progress. x/y marked."] = "Suivez la progression de Explore Harandar. x/y indiqués.",
    ["Tracked entries for Explore Harandar have not been added yet."] = "Les entrées suivies pour Explore Harandar n’ont pas encore été ajoutées.",
    ["Thrill of the Chase"] = "Le frisson de la chasse",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "Échappez à l’emprise de la Présence affamée dans Voidstorm pendant au moins 60 secondes.",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "Ce haut fait n’a pas besoin d’un suivi de coordonnées dans LiteVault. Survivez à l’événement de la Présence affamée dans Voidstorm pendant au moins 60 secondes.",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "Les entrées suivies pour Le frisson de la chasse n’ont pas encore été ajoutées.",
    ["No Time to Paws"] = "Pas le temps de niaiser",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "Terminez la quête mondiale de Harandar « Application de la griffe » avec 15 charges ou plus de Poursuite du prédateur.",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "Ce haut fait n’a pas besoin d’un suivi de coordonnées dans LiteVault. Terminez la quête mondiale de Harandar « Application de la griffe » avec 15 charges ou plus de Poursuite du prédateur.",
    ["Tracked entries for No Time to Paws have not been added yet."] = "Les entrées suivies pour Pas le temps de niaiser n’ont pas encore été ajoutées.",
    ["From The Cradle to the Grave"] = "Du berceau à la tombe",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "Tentez de voler jusqu’au Berceau, haut dans le ciel au-dessus de Harandar.",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "Envolez-vous vers le Berceau, haut dans le ciel au-dessus de Harandar, pour accomplir ce haut fait.",
    ["Chronicler of the Haranir"] = "Chroniqueur des Haranir",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "Ces journaux ne sont disponibles que pendant la quête hebdomadaire liée au compte « Légendes des Haranir ». Pendant une vision, cherchez l’icône de loupe sur votre mini-carte.",
    ["Recover the Haranir journal entries listed below."] = "Récupérez les entrées de journal haranir listées ci-dessous.",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "Récupérez les entrées de journal haranir listées ci-dessous. x/y indiqués.",
    ["Legends Never Die"] = "Les légendes ne meurent jamais",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "Ceci est lié à la quête hebdomadaire liée au compte « Légendes des Haranir ». Si vous n’avez encore aucune progression, il faut environ 7 semaines pour l’achever.",
    ["Defend each Haranir legend location listed below."] = "Défendez chaque lieu de légende haranir listé ci-dessous.",
    ["Protect each Haranir legend location listed below. x/y marked."] = "Protégez chaque lieu de légende haranir listé ci-dessous. x/y indiqués.",
    ["Dust 'Em Off"] = "Époussetez-les",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "Trouvez tous les papillons lumineux cachés dans Harandar. x/y trouvés.",
    ["Coordinate groups have not been added yet."] = "Les groupes de coordonnées n’ont pas encore été ajoutés.",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "Ce suivi est divisé en 3 groupes de 40 coordonnées afin que les itinéraires des papillons restent gérables.",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "Les papillons 1-40 apparaissent à la Renommée Hara'ti 1, suivi à la Renommée 2.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Les papillons 41-80 apparaissent à la Renommée Hara'ti 4, suivi à la Renommée 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Les papillons 81-120 apparaissent à la Renommée Hara'ti 9, suivi à la Renommée 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "Le routage LiteVault suppose que vous avez déjà débloqué la Renommée Hara'ti 11.",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s contient %d coordonnées de papillons. Cliquez sur un papillon pour placer un point de passage.",
    ["Group 1"] = "Groupe 1",
    ["Group 2"] = "Groupe 2",
    ["Group 3"] = "Groupe 3",
    ["Moths"] = "Papillons",
    ["A Singular Problem"] = "Un problème singulier",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "Terminez les trois vagues de l’Assaut de Stormarion. x/y indiqués.",
    ["Tracked entries for A Singular Problem have not been added yet."] = "Les entrées suivies pour Un problème singulier n’ont pas encore été ajoutées.",
    ["Abundance: Prosperous Plentitude!"] = "Abondance : Plénitude prospère !",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "Terminez une course de grotte Récolte abondante à chaque emplacement. x/y indiqués.",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "Vous devez terminer une course de grotte Récolte abondante à chaque emplacement pour obtenir le crédit. Il ne suffit pas de visiter la grotte.",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "Les entrées suivies pour Abondance : Plénitude prospère ! n’ont pas encore été ajoutées.",
    ["Altar of Blessings"] = "Autel des bénédictions",
    ["Trigger each listed blessing effect for credit."] = "Déclenchez chaque effet de bénédiction indiqué pour obtenir le crédit.",
    ["Trigger each listed blessing effect. x/y marked."] = "Déclenchez chaque effet de bénédiction indiqué. x/y indiqués.",
    ["Meta achievement summaries"] = "Résumés des méta hauts faits",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "Terminez les hauts faits d’Eversong Woods listés ci-dessous. x/y faits.",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "Terminez tous les hauts faits de Voidstorm listés ci-dessous. x/y faits.",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "Terminez tous les hauts faits de Zul'Aman listés ci-dessous. x/y faits.",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "Aidez les Hara'ti en terminant les hauts faits ci-dessous. x/y faits.",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "Ralliez vos forces contre Xal'atath en terminant les hauts faits ci-dessous. x/y faits.",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "Les entrées suivies pour Making an Amani Out of You n’ont pas encore été ajoutées.",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "Les entrées suivies pour That's Aln, Folks! n’ont pas encore été ajoutées.",
    ["Tracked entries for Forever Song have not been added yet."] = "Les entrées suivies pour Forever Song n’ont pas encore été ajoutées.",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "Les entrées suivies pour Yelling into the Voidstorm n’ont pas encore été ajoutées.",
    ["Tracked entries for Light Up the Night have not been added yet."] = "Les entrées suivies pour Light Up the Night n’ont pas encore été ajoutées.",
    ["Mount: Brilliant Petalwing"] = "Monture : Pétalaile brillante",
    ["Housing Decor: On'ohia's Call"] = "Décoration de maison : Appel d’On'ohia",
    ["Title: \"Dustlord\""] = "Titre : \"Seigneur des poussières\"",
    ["Title: \"Chronicler of the Haranir\""] = "Titre : \"Chroniqueur des Haranir\"",
    ["home reward labels:"] = "Libellés de récompense du foyer :",
}

L["Raid resync unavailable."] = "Resynchronisation du raid indisponible."
L["Time played messages will be suppressed."] = "Les messages de temps de jeu seront masqués."
L["Time played messages restored."] = "Les messages de temps de jeu ont été rétablis."
L["%dm %02ds"] = "%d min %02d s"
L["Crests:"] = "Écus :"
L["Mount Drops"] = "Butin de monture"
L["(Collected)"] = "(Collecté)"
L["(Uncollected)"] = "(Non collecté)"
L["Mounts: %d/%d"] = "Montures : %d/%d"
L["LABEL_MOUNTS_FMT"] = "Montures : %d/%d"
L["The Voidspire"] = "La Flèche du Vide"
L["The Dreamrift"] = "La Faille onirique"
L["March of Quel'Danas"] = "La Marche de Quel'Danas"
L["Raid Progression"] = "Progression du raid"
L["Lady Liadrin Weekly"] = "Hebdomadaire : Dame Liadrin"
L["Change Log"] = "Journal des modifications"
L["Back"] = "Retour"
L["Warband Bank"] = "Banque de bataillon"
L["Treatise"] = "Traité"
L["Artisan"] = "Artisan"
L["Catch-up"] = "Rattrapage"
L["LiteVault Update Summary"] = "Résumé de la mise à jour de LiteVault"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Plusieurs éléments essentiels de l’interface ont été actualisés, notamment l’icône des monnaies, l’icône de raid, la barre des métiers et le suivi du Grand coffre."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "L’affichage du niveau d’objet du coffre a été mis à jour afin de correspondre davantage à la présentation par défaut du Grand coffre de Blizzard."
L["Added a large batch of new translations across supported locales."] = "Un grand nombre de nouvelles traductions ont été ajoutées pour les langues prises en charge."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "L’affichage et l’actualisation du texte localisé ont été améliorés dans l’ensemble de l’addon."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "La prise en charge de la localisation a été mise à jour pour les boutons, les onglets de sacs, les textes hebdomadaires et d’autres libellés d’interface."
L["Fixed multiple localization-related layout issues."] = "Plusieurs problèmes de mise en page liés à la localisation ont été corrigés."
L["Fixed several localization-related crash issues."] = "Plusieurs plantages liés à la localisation ont été corrigés."

-- Register this locale
lv.RegisterLocale("frFR", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["frFR"] = L




