-- esES.lua - Spanish locale for LiteVault
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
    BUTTON_CLOSE = "Cerrar",
    BUTTON_YES = "Sí",
    BUTTON_NO = "No",
    BUTTON_MANAGE = "Gestionar",
    BUTTON_BACK = "Atrás",
    BUTTON_ALL = "Todos",
    BUTTON_NONE = "Ninguno",
    BUTTON_FILTER = "Filtro",
    DIALOG_DELETE_CHAR = "¿Eliminar %s de LiteVault?",
    LABEL_MYTHIC_PLUS = "M+",
    BUTTON_LANGUAGE = "Idioma",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "Filtros de mapa",

    BUTTON_RAID_LOCKOUTS = "Salvaciones",
    BUTTON_WORLD_EVENTS = "Eventos del mundo",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "Salvaciones de banda",
    TOOLTIP_RAID_LOCKOUTS_DESC = "Ver jefes derrotados de todos los personajes",
    TOOLTIP_THEME_TITLE = "Cambiar tema",
    TOOLTIP_THEME_DESC = "Cambiar entre modo claro y oscuro",
    TOOLTIP_FILTER_TITLE = "Filtros de mapa",
    TOOLTIP_FILTER_DESC = "Clic para ver la lista completa",
    TOOLTIP_WORLD_EVENTS_TITLE = "Eventos del mundo",
    TOOLTIP_WORLD_EVENTS_DESC = "Mostrar eventos mundiales",
    TOOLTIP_LANGUAGE_TITLE = "Idioma",
    TOOLTIP_LANGUAGE_DESC = "Cambiar el idioma de la interfaz",

    -- Sort controls
    LABEL_SORT_BY = "Ordenar:",
    SORT_GOLD = "Oro",
    SORT_ILVL = "NdO",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "Actividad",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "Misiones semanales de %s",
    BUTTON_WEEKLIES = "Semanales",
    BUTTON_EVENTS = "Eventos",
    BUTTON_FACTIONS = "Facciones",
    BUTTON_AMANI_TRIBE = "Tribu Amani",
    BUTTON_HARATI = "Hara'ti",
    BUTTON_SINGULARITY = "La Singularidad",
    BUTTON_SILVERMOON_COURT = "Corte de Lunargenta",
    TITLE_FACTION_WEEKLIES = "Semanales de facción de %s",
    WARNING_EVENT_QUESTS = "Algunos de estos eventos están bugueados o bloqueados en el juego.",
    WARNING_WEEKLY_HARATI_CHOICE = "¡Advertencia! Una vez elegida la misión de Leyendas de los Haranir, queda bloqueada para tu cuenta.",
    WARNING_WEEKLY_RUNESTONES = "¡Advertencia! Elige con cuidado la misión de piedras rúnicas. Cuando elijas una para la semana, esa elección quedará fijada para toda tu cuenta.",
    LABEL_WEEKLY_PROFIT = "Beneficio semanal:",
    LABEL_WARBAND_PROFIT = "Beneficio de banda guerrera:",
    LABEL_WARBAND_BANK = "Banco de banda guerrera:",
    LABEL_TOP_EARNERS = "Mayores ingresos (Semanal):",
    LABEL_TOTAL_GOLD = "Oro total: %s",
    LABEL_TOTAL_TIME = "Tiempo total: %s",
    LABEL_COMBINED_TIME = "Tiempo combinado: %dd %dh",

    TOOLTIP_TOTAL_TIME_TITLE = "Tiempo de juego total",
    TOOLTIP_TOTAL_TIME_DESC = "Tiempo total de juego de todos los personajes rastreados.",
    TOOLTIP_TOTAL_TIME_CLICK = "Clic para cambiar el formato.",

    -- Quest status
    STATUS_DONE = "[Completada]",
    STATUS_IN_PROGRESS = "[En curso]",
    STATUS_NOT_STARTED = "[Sin empezar]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Gestionar personajes",
    TOOLTIP_MANAGE_BACK = "Volver a la vista principal.",
    TOOLTIP_MANAGE_VIEW = "Ver personajes ignorados.",

    TOOLTIP_CATALYST_TITLE = "Cargas del catalizador",
    TOOLTIP_SPARKS_TITLE = "Chispas de creación",

    TOOLTIP_VAULT_TITLE = "La Gran Bóveda",
    TOOLTIP_VAULT_DESC = "Pulsa para abrir la Gran Bóveda",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Abrir la Gran Bóveda.",
    TOOLTIP_VAULT_ALT_ONLY = "La Gran Bóveda solo puede abrirse para el personaje activo.",

    TOOLTIP_CURRENCY_TITLE = "Monedas del personaje",
    TOOLTIP_CURRENCY_DESC = "Clic para ver la lista completa.",
    TOOLTIP_BAGS_TITLE = "Ver bolsas",
    TOOLTIP_BAGS_DESC = "Ver contenido guardado de bolsas y bolsa de reagentes.",

    TOOLTIP_LEDGER_TITLE = "Registro de beneficios semanal",
    TOOLTIP_LEDGER_DESC = "Rastrear ingresos y gastos de oro por fuente.",

    TOOLTIP_WARBAND_BANK_TITLE = "Registro del banco de banda",
    TOOLTIP_WARBAND_BANK_DESC = "Clic para ver transacciones.",

    TOOLTIP_RESTORE_TITLE = "Restaurar",
    TOOLTIP_RESTORE_DESC = "Restaurar personaje a la página principal",

    TOOLTIP_IGNORE_TITLE = "Ignorar",
    TOOLTIP_IGNORE_DESC = "Eliminar personaje de la página principal",

    TOOLTIP_DELETE_TITLE = "Borrar",
    TOOLTIP_DELETE_DESC = "Borrar permanentemente los datos del personaje",
    TOOLTIP_DELETE_WARNING = "Advertencia: ¡Esto no se puede deshacer!",

    TOOLTIP_FAVORITE_TITLE = "Favorito",
    TOOLTIP_FAVORITE_DESC = "Fijar personaje al principio de la lista",

    -- Character data displays
    LABEL_ILVL = "Nivel: %d",
    LABEL_MPLUS_SCORE = "Punt. M+: %d",
    LABEL_NO_KEY = "Sin piedra angular",
    LABEL_NO_PROFESSIONS = "Sin profesiones",
    LABEL_UNKNOWN = "Desconocido",
    LABEL_SKILL_LEVEL = "Habilidad: %d/%d",
    LABEL_CONCENTRATION = "Concentración: %d/%d",
    LABEL_CONC_DAILY_RESET = "Diario: %dh %dm",
    LABEL_CONC_WEEKLY_RESET = "Reset completo: %dd %dh",
    LABEL_CONC_FULL = "(Lleno)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d Conocimiento disponible",
    LABEL_NO_KNOWLEDGE = "Sin conocimiento disponible",
    LABEL_VAULT_PROGRESS = "B: %d/3    M+: %d/3    M: %d/3",
    BUTTON_LEDGER = "Registro",
    BUTTON_PROFS = "Oficios",

    TOOLTIP_PROFS_TITLE = "Profesiones",
    TOOLTIP_PROFS_DESC = "Ver concentración y conocimiento",
    TITLE_PROFESSIONS = "Profesiones de %s",
    TITLE_KNOWLEDGE_SOURCES = "Fuentes de conocimiento",
    TAB_TREASURES = "Tesoros",
    LABEL_UNIQUE_TREASURES = "Tesoros únicos",
    LABEL_WEEKLY_TREASURES = "Tesoros semanales",
    LABEL_HOVER_TREASURE_CHECKLIST = "Pasa el cursor para ver la lista de tesoros",
    TITLE_PROF_TREASURES_FMT = "Tesoros de %s",
    LABEL_PROFESSION = "Profesión",
    LABEL_UNIQUE_TREASURE_FMT = "Tesoro único de %s %d",
    LABEL_WEEKLY_TREASURE_FMT = "Tesoro semanal de %s %d",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "Dom",
    DAY_MON = "Lun",
    DAY_TUE = "Mar",
    DAY_WED = "Mié",
    DAY_THU = "Jue",
    DAY_FRI = "Vie",
    DAY_SAT = "Sáb",

    TOOLTIP_ACTIVITY_FOR = "Actividad del %d/%d/%d",
    MSG_NO_WORLD_EVENTS = "No hay eventos mundiales este mes",

    -- Filter categories
    FILTER_TIMEWALKING = "Paseo en el Tiempo",
    FILTER_DARKMOON = "Luna Negra",
    FILTER_DUNGEONS = "Mazmorras",
    FILTER_PVP = "JcJ",
    FILTER_BONUS = "Evento de bonificación",

    -- World events
    WORLD_EVENT_LOVE = "El amor está en el aire",
    WORLD_EVENT_LUNAR = "Festival Lunar",
    WORLD_EVENT_NOBLEGARDEN = "Jardín Noble",
    WORLD_EVENT_CHILDREN = "Semana de los Niños",
    WORLD_EVENT_MIDSUMMER = "Festival de Fuego del Solsticio de Verano",
    WORLD_EVENT_BREWFEST = "Fiesta de la Cerveza",
    WORLD_EVENT_HALLOWS = "Halloween",
    WORLD_EVENT_WINTERVEIL = "Festival de Invierno",
    WORLD_EVENT_DEAD = "Día de los Muertos",
    WORLD_EVENT_PIRATES = "Día de los Piratas",
    WORLD_EVENT_STYLE = "Prueba de Estilo",
    WORLD_EVENT_OUTLAND = "Copa de Terrallende",
    WORLD_EVENT_NORTHREND = "Copa de Rasganorte",
    WORLD_EVENT_KALIMDOR = "Copa de Kalimdor",
    WORLD_EVENT_EASTERN = "Copa de los Reinos del Este",
    WORLD_EVENT_WINDS = "Vientos de fortuna misteriosa",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "Monedas de %s",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "Salvaciones de banda",
    TITLE_RAID_FORMAT = "%s - %s %s",

    BUTTON_PROGRESSION = "Progresión",
    BUTTON_LOCKOUTS = "Salvaciones",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Heroico",
    DIFFICULTY_MYTHIC = "Mítico",

    TOOLTIP_VIEW_LOCKOUTS = "Mostrando: Salvaciones (esta semana)",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "Clic para ver progresión (mejor marca)",
    TOOLTIP_VIEW_PROGRESSION = "Mostrando: Progresión (mejor marca)",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "Clic para ver salvaciones (esta semana)",

    MSG_NO_CHAR_DATA = "No se han encontrado datos del personaje",
    MSG_NO_PROGRESSION = "No hay progresión de %s registrada",
    MSG_NO_LOCKOUT = "No hay salvación de %s esta semana",

    LABEL_BOSS = "Jefe %d",
    LABEL_PROGRESS_COUNT = "%d/8",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "Registro del banco de banda guerrera",
    LABEL_CURRENT_BALANCE = "Saldo actual:",
    LABEL_RECENT_TRANSACTIONS = "Transacciones recientes:",
    MSG_NO_TRANSACTIONS = "(Aún no hay transacciones registradas)",
    TIP_RELOAD_SAVE = "Consejo: /reload antes de cambiar de personaje para guardar",
    ACTION_DEPOSITED = "depositado",
    ACTION_WITHDREW = "retirado",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    TITLE_WEEKLY_LEDGER = "%s - Registro semanal",
    LABEL_RESETS_IN = "Reinicio en %dd %dh",

    TAB_SUMMARY = "Resumen",
    TAB_HISTORY = "Historial",
    TAB_WARBAND = "Warband",
    HEADER_SOURCE = "Fuente",
    HEADER_INCOME = "Ingresos",
    HEADER_EXPENSE = "Gastos",

    LABEL_TOTAL = "Total",
    LABEL_NET_PROFIT = "Beneficio neto",
    MSG_NO_GOLD_ACTIVITY = "Sin actividad de oro esta semana",
    MSG_NO_TRANSACTIONS_WEEK = "Sin transacciones esta semana",

    -- Ledger source categories
    LEDGER_QUESTS = "Misiones",
    LEDGER_AUCTION = "Casa de subastas",
    LEDGER_TRADE = "Comercio",
    LEDGER_VENDOR = "Vendedor",
    LEDGER_REPAIRS = "Reparaciones",
    LEDGER_TRANSMOG = "Transfiguración",
    LEDGER_FLIGHT = "Maestro de vuelo",
    LEDGER_CRAFTING = "Profesiones",
    LEDGER_CACHE = "Cofre/Contenedor",
    LEDGER_MAIL = "Correo",
    LEDGER_LOOT = "Botín",
    LEDGER_WARBAND_BANK = "Banco de banda guerrera",
    LEDGER_OTHER = "Otros",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "Nunca",
    FRESH_TODAY = "Hoy",
    FRESH_1_DAY = "Hace 1 día",
    FRESH_DAYS = "Hace %d días",

    -- Time format styles
    TIME_YEARS_DAYS = "%da %dd",
    TIME_DAYS_HOURS = "%dd %dh",
    TIME_DAYS = "%s días",
    TIME_HOURS = "%s horas",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "Saludos %s,\n¿Quieres que LiteVault rastree a este personaje?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "¡Reinicio semanal detectado! Salvaciones de banda borradas.",
    MSG_ALREADY_TRACKED = "Este personaje ya está siendo rastreado.",
    MSG_CHAR_ADDED = "%s ha sido añadido al rastreo.",
    MSG_LEDGER_NOT_AVAILABLE = "Registro no disponible.",
    MSG_RAID_RESET_SEASON = "¡La progresión de banda ha sido reiniciada para Midnight Temporada 1!",
    MSG_CLEARED_PROGRESSION = "Datos de progresión borrados para %d personajes.",
    MSG_WEEKLY_PROFIT_RESET = "Rastreo de ganancias semanal reiniciado para %d personajes.",
    MSG_WARBAND_BALANCE = "Banda guerrera: %s",
    MSG_WARBAND_BANK_BALANCE = "Banco de banda guerrera: %s",
    MSG_WEEKLY_DATA_RESET = "Datos semanales reiniciados para %d personajes.",
    MSG_RAID_MANUAL_RESET = "¡Progresión de banda reiniciada manualmente!",
    MSG_CLEARED_DATA = "Datos borrados para %d personajes.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "El mensaje inicial de tiempo jugado de Blizzard no se puede suprimir.",
    MSG_LANGUAGE_CHANGED = "Idioma cambiado. Recarga la interfaz para aplicar todos los cambios.",

    -- Slash command help
    HELP_RESET_TITLE = "Comandos de reinicio de LiteVault",
    HELP_REGION = "Región: %s (reinicio %s)",
    HELP_LAST_SEASON = "Último reinicio de temporada: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - Reiniciar rastreo de ganancias semanal",
    HELP_RESET_SEASON = "/lvreset season - Reiniciar progresión de banda (nuevo tier)",
    HELP_NEVER = "Nunca",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    TITLE_LANGUAGE_SELECT = "Seleccionar idioma",
    LANG_AUTO = "Automático (detectar)",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "Opciones",
    TOOLTIP_OPTIONS_TITLE = "Opciones",
    TOOLTIP_OPTIONS_DESC = "Configurar los ajustes de LiteVault",
    TITLE_OPTIONS = "Opciones de LiteVault",
    OPTION_DISABLE_TIMEPLAYED = "Desactivar seguimiento de tiempo jugado",
    OPTION_DISABLE_TIMEPLAYED_DESC = "Evita que mensajes de /played aparezcan en el chat",
    OPTION_DARK_MODE = "Modo oscuro",
    OPTION_DARK_MODE_DESC = "Alternar entre temas oscuro y claro",
    OPTION_DISABLE_BAG_VIEWING = "Desactivar visor de bolsas/banco",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Oculta el botón de Bolsas y desactiva la visualización de bolsas, banco y banco de banda de guerra guardados.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Desactivar sistema de superposición",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Oculta las superposiciones de nivel de objeto y candado de LiteVault en el equipo del personaje e inspección.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "Desactivar teletransportes M+",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Oculta la insignia de teletransporte M+ y desactiva el panel de teletransporte de LiteVault.",

    -- Month names
    MONTH_1 = "Enero",
    MONTH_2 = "Febrero",
    MONTH_3 = "Marzo",
    MONTH_4 = "Abril",
    MONTH_5 = "Mayo",
    MONTH_6 = "Junio",
    MONTH_7 = "Julio",
    MONTH_8 = "Agosto",
    MONTH_9 = "Septiembre",
    MONTH_10 = "Octubre",
    MONTH_11 = "Noviembre",
    MONTH_12 = "Diciembre",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["Dawnlight Manaflux"] = "Manafluzo Albaluz",

    -- ==========================================================================
    -- WEEKLY QUESTS (Midnight)
    -- ==========================================================================
    ["Community Engagement"] = "Community Engagement",
    WARNING_ACCOUNT_BOUND = "Ligado a la cuenta",
    ["Midnight: Prey"] = "Midnight: Prey",
    ["Saltheril's Soiree"] = "Velada de Saltheril",
    ["Abundance Event"] = "Evento de Abundancia",
    ["Legends of the Haranir"] = "Leyendas de los Haranir",
    ["Stormarion Assault"] = "Asalto de Stormarion",
    ["Darkness Unmade"] = "Oscuridad Deshecha",
    ["Harvesting the Void"] = "Cosechando el Vacío",
    ["Midnight: Saltheril's Soiree"] = "Medianoche: velada de Saltheril",
    ["Fortify the Runestones: Blood Knights"] = "Fortificar las piedras rúnicas: Caballeros de Sangre",
    ["Fortify the Runestones: Shades of the Row"] = "Fortificar las piedras rúnicas: Sombras del Barrio",
    ["Fortify the Runestones: Magisters"] = "Fortificar las piedras rúnicas: Magistrados",
    ["Fortify the Runestones: Farstriders"] = "Fortificar las piedras rúnicas: Errantes",
    ["Put a Little Snap in Their Step"] = "Dales más brío al andar",
    ["Light Snacks"] = "Tentempiés ligeros",
    ["Less Lawless"] = "Menos desenfreno",
    ["The Subtle Game"] = "El juego sutil",
    ["Courting Success"] = "Cortejando el éxito",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Alquimia",
    ["Blacksmithing"] = "Herrería",
    ["Enchanting"] = "Encantamiento",
    ["Engineering"] = "Ingeniería",
    ["Inscription"] = "Inscripción",
    ["Jewelcrafting"] = "Joyería",
    ["Leatherworking"] = "Peletería",
    ["Tailoring"] = "Sastrería",
    ["Herbalism"] = "Herboristería",
    ["Mining"] = "Minería",
    ["Skinning"] = "Desuello",

    ["Remnant of Anguish"] = "Remanente de angustia",
    ["Shard of Dundun"] = "Fragmento de Dundun",
    ["Adventurer Dawncrest"] = "Emblema del Alba de aventurero",
    ["Veteran Dawncrest"] = "Emblema del Alba de veterano",
    ["Champion Dawncrest"] = "Emblema del Alba de campeón",
    ["Hero Dawncrest"] = "Emblema del Alba de héroe",
    ["Myth Dawncrest"] = "Emblema del Alba mítico",
    ["Brimming Arcana"] = "Arcana rebosante",
    ["Voidlight Marl"] = "Marga de luz del Vacío",
    ["Undercoin"] = "Moneda inferior",
    ["Throw the Dice"] = "Tira los dados",
    ["We Need a Refill"] = "Necesitamos reponer",
    ["Lovely Plumage"] = "Plumaje encantador",
    ["The Cauldron of Echoes"] = "El caldero de los ecos",
    ["The Echoless Flame"] = "La llama sin eco",
    ["Hidey-Hole"] = "Escondite",
    ["Victorious Stormarion Pinnacle Cache"] = "Alijo de la Cima de Stormarion victoriosa",
    ["Overflowing Abundant Satchel"] = "Cartera rebosante de abundancia",
    ["Avid Learner's Supply Pack"] = "Paquete de suministros del aprendiz ávido",
    ["Surplus Bag of Party Favors"] = "Bolsa sobrante de regalos de fiesta",
    TELEPORT_PANEL_TITLE = "Teletransportes M+",
    TELEPORT_CAST_BTN = "Teletransporte",
    TELEPORT_ERR_COMBAT = "No puedes teletransportarte durante el combate.",
    BUTTON_VAULT = "Bóveda",
    BUTTON_ACTIONS = "Acciones",
    BUTTON_RAIDS = "Bandas",
    BUTTON_FAVORITE = "Favorito",
    BUTTON_UNFAVORITE = "Quitar favorito",
    BUTTON_IGNORE = "Ignorar",
    BUTTON_RESTORE = "Restaurar",
    BUTTON_DELETE = "Eliminar",
    TOOLTIP_ACTIONS_TITLE = "Acciones del personaje",
    TOOLTIP_ACTIONS_DESC = "Abrir menú de acciones",
    BUTTON_INSTANCES = "Instancias",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Seguimiento de instancias",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Rastrear mazmorras y bandas",
    LABEL_RENOWN_PROGRESS = "Renombre %d (%d/%d)",
    LABEL_RENOWN = "Prestigio",
    LABEL_RENOWN_LEVEL = "Nivel",
    LABEL_RENOWN_UNAVAILABLE = "Renombre no disponible",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "Aún no hay misiones de facción configuradas.",
    BUTTON_KNOWLEDGE = "Conocimiento",
    WORLD_EVENT_SALTHERIL = "Velada de Saltheril",
    WORLD_EVENT_ABUNDANCE = "Abundancia",
    WORLD_EVENT_HARANIR = "Leyendas de los Haranir",
    WORLD_EVENT_STORMARION = "Asalto de Stormarion",
    TITLE_KNOWLEDGE_TRACKER = "Seguimiento de conocimiento",
    TOOLTIP_KNOWLEDGE_DESC = "Ver conocimiento gastado, disponible y máximo",
    LABEL_SPENT = "Gastado",
    LABEL_UNSPENT = "Sin gastar",
    LABEL_MAX = "Máximo",
    LABEL_EARNED = "Obtenido",
    LABEL_TREATISE = "Tratado",
    LABEL_ARTISAN_QUEST = "Artesano",
    LABEL_CATCHUP = "Recuperación",
    LABEL_WEEKLY = "Semanal",
    LABEL_UNLOCKED = "Desbloqueado",
    LABEL_UNLOCK_REQUIREMENTS = "Requisitos de desbloqueo",
    LABEL_SOURCE_NOTE = "Fuentes semanales y resumen de recuperación",
    LABEL_TREASURE_CLICK_HINT = "Haz clic en un tesoro único para colocar un punto de ruta",
    LABEL_ZONE = "Zona",
    LABEL_QUEST = "Misión",
    LABEL_COORDINATES = "Coordenadas",
    TOOLTIP_TREASURE_SET_WAYPOINT = "Haz clic para colocar un punto de ruta de TomTom",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "Haz clic para colocar un punto de ruta del mapa",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "Este tesoro no tiene una ubicación fija",
    MSG_TREASURE_NO_WAYPOINT = "Este tesoro no tiene un punto de ruta fijo.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom no detectado.",
    MSG_TREASURE_WAYPOINT_SET = "Punto de ruta establecido: %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "Punto del mapa establecido: %s (%.1f, %.1f)",
    STATUS_DONE_WORD = "Hecho",
    STATUS_MISSING_WORD = "Falta",
    LABEL_MIDNIGHT_SEASON_1 = "Temporada 1 de Midnight",
    TAB_SOURCES = "Fuentes",
    TIME_TODAY = "Hoy %H:%M",
    TIME_YESTERDAY = "Ayer %H:%M",
    MSG_CAP_WARNING = "¡Aviso de límite de instancias! %d/10 instancias esta hora.",
    MSG_CAP_SLOT_OPEN = "¡Ahora hay un hueco de instancia libre! (%d/10 usadas)",
    MSG_RELOAD_TIMEPLAYED = "Recarga la interfaz para que surta efecto la supresión del tiempo jugado.",
    MSG_RAID_DEBUG_ON = "Depuración de bandas de LiteVault: ACTIVADA",
    MSG_RAID_DEBUG_OFF = "Depuración de bandas de LiteVault: DESACTIVADA",
    MSG_RAID_DEBUG_TIP = "Usa /lvraiddbg otra vez para desactivar la salida de depuración",
    MSG_TRACKED_KILL = "Muerte registrada de %s: %s (%s)",
    LOCALE_DEBUG_ON = "Modo de depuración de idioma ACTIVADO - se muestran las claves",
    LOCALE_DEBUG_OFF = "Modo de depuración de idioma DESACTIVADO - se muestran las traducciones",
    LOCALE_BORDERS_ON = "Modo bordes ACTIVADO - se muestran los límites del texto",
    LOCALE_BORDERS_HINT = "Verde = cabe, Rojo = puede desbordarse",
    LOCALE_BORDERS_OFF = "Modo bordes DESACTIVADO",
    LOCALE_FORCED = "Idioma forzado a %s",
    LOCALE_RESET_TIP = "Usa /lvlocale reset para volver a la detección automática",
    LOCALE_INVALID = "Idioma no válido. Opciones válidas:",
    LOCALE_RESET = "Idioma restablecido a detección automática: %s",
    LOCALE_TITLE = "Localización de LiteVault",
    LOCALE_DETECTED = "Idioma detectado: %s",
    LOCALE_FORCED_TO = "Idioma forzado: %s",
    LOCALE_DEBUG_KEYS = "Claves de depuración:",
    LOCALE_DEBUG_BORDERS = "Bordes de depuración:",
    LOCALE_ON = "ACTIVADO",
    LOCALE_OFF = "DESACTIVADO",
    LOCALE_COMMANDS = "Comandos:",
    LOCALE_CMD_DEBUG = "/lvlocale debug - Alternar modo de visualización de claves",
    LOCALE_CMD_BORDERS = "/lvlocale borders - Alternar visualización de bordes del texto",
    LOCALE_CMD_LANG = "/lvlocale lang XX - Forzar idioma (por ejemplo, deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - Volver a la detección automática",
    TITLE_INSTANCE_TRACKER = "Seguimiento de instancias",
    SECTION_INSTANCE_CAP = "Límite de instancias (10/hora)",
    LABEL_CAP_CURRENT = "Actual: %d/10",
    LABEL_CAP_STATUS = "Estado: %s",
    LABEL_NEXT_SLOT = "Siguiente hueco en: %s",
    STATUS_SAFE = "SEGURO",
    STATUS_WARNING = "ADVERTENCIA",
    STATUS_LOCKED = "BLOQUEADO",
    SECTION_CURRENT_RUN = "Recorrido actual",
    LABEL_DURATION = "Duración: %s",
    LABEL_NOT_IN_INSTANCE = "No estás en una instancia",
    SECTION_PERFORMANCE = "Rendimiento de hoy",
    LABEL_DUNGEONS_TODAY = "Mazmorras: %d",
    LABEL_RAIDS_TODAY = "Bandas: %d",
    LABEL_AVG_TIME = "Media: %s",
    SECTION_LEGACY_RAIDS = "Bandas heredadas esta semana",
    LABEL_LEGACY_RUNS = "Recorridos: %d",
    LABEL_GOLD_EARNED = "Oro: %s",
    SECTION_RECENT_RUNS = "Recorridos recientes",
    LABEL_NO_RECENT_RUNS = "Sin recorridos recientes",
    SECTION_MPLUS = "Mítica+",
    LABEL_MPLUS_CURRENT_KEY = "Clave actual:",
    LABEL_RUNS_TODAY = "Recorridos hoy: %d",
    LABEL_RUNS_THIS_WEEK = "Recorridos esta semana: %d",
    SECTION_RECENT_MPLUS_RUNS = "Recorridos M+ recientes",
    LABEL_NO_RECENT_MPLUS_RUNS = "Sin recorridos M+ recientes",
    BUTTON_DASHBOARD = "Panel",
    BUTTON_ACHIEVEMENTS = "Logros",
    TITLE_ACHIEVEMENTS = "Logros",
    DESC_ACHIEVEMENTS = "Elige un rastreador de logros para ver el progreso detallado.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "Cazador de glifos de medianoche",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "Cazador de glifos de medianoche",
    LABEL_REWARD = "Recompensa",
    DESC_GLYPH_REWARD = "Completa Cazador de glifos de medianoche para obtener esta montura.",
    MSG_NO_ACHIEVEMENT_DATA = "No hay datos de seguimiento de logros disponibles.",
    LABEL_CRITERIA = "Criterios",
    LABEL_GLYPHS_COLLECTED = "Glifos recopilados",
    LABEL_ACHIEVEMENT = "Logro",
    BUTTON_BAGS = "Bolsas",
    BUTTON_BANK = "Banco",
    BUTTON_WARBAND_BANK = "Banco de banda de guerra",
    BAGS_EMPTY_STATE = "Aún no hay objetos de bolsa guardados para este personaje.",
    BANK_EMPTY_STATE = "Aún no hay objetos de banco guardados para este personaje.",
    WARBANK_EMPTY_STATE = "Aún no hay objetos del banco de banda de guerra guardados.",
    LABEL_BAG_SLOTS = "Espacios: %d / %d usados",
    LABEL_SCANNED = "escaneado",
    OPTION_ENABLE_24HR_CLOCK = "Activar reloj de 24 horas",
    OPTION_ENABLE_24HR_CLOCK_DESC = "Cambiar entre formato de 24 y 12 horas",
    ["Coffer Key Shards"] = "Fragmentos de llave de arca",
    BUTTON_WEEKLY_PLANNER = "Planificador",
    TITLE_WEEKLY_PLANNER = "Planificador semanal",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "Planificador semanal",
    TOOLTIP_WEEKLY_PLANNER_DESC = "Lista semanal editable por personaje. Los elementos completados se reinician cada semana.",
    TOOLTIP_VAULT_STATUS = "Comprobar estado de la bóveda.",
    TITLE_GREAT_VAULT = "La Gran Cámara",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "Banda",
    LABEL_VAULT_ROW_DUNGEONS = "Mazmorras",
    LABEL_VAULT_ROW_WORLD = "Mundo",
    LABEL_VAULT_SLOTS_UNLOCKED = "%d/9 espacios desbloqueados",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "Aún no hay datos de umbral guardados.",
    MSG_VAULT_LIVE_ACTIVE = "Progreso en vivo de la Gran Cámara para el personaje activo.",
    MSG_VAULT_LIVE = "Progreso en vivo de la Gran Cámara.",
    MSG_VAULT_SAVED = "Instantánea guardada de la Gran Cámara del último inicio de sesión de este personaje.",
    SECTION_DELVE_CURRENCY = "Moneda de Profundidades",
    SECTION_UPGRADE_CRESTS = "Blasones de mejora",
    LABEL_CAP_SHORT = "límite %s",
    ["Treasures of Midnight"] = "Tesoros de Midnight",
    ["Track the four Midnight treasure achievements and their rewards."] = "Sigue los cuatro logros de tesoros de Midnight y sus recompensas.",
    ["Glory of the Midnight Delver"] = "Gloria del Abisante de Midnight",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "Completa «Gloria del Abisante de Midnight» para obtener esta montura.",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "Sigue los cuatro logros de raros de Midnight y las recompensas de los raros de zona.",
    ["Track the four Midnight rare achievements."] = "Sigue los cuatro logros de raros de Midnight.",
    ["Complete the five telescopes in this zone."] = "Completa los cinco telescopios de esta zona.",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "Completa los cuatro logros de apoyo del Abisante de Midnight para terminar este meta logro.",
    ["Crimson Dragonhawk"] = "Halcón dragón carmesí",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Achievements"] = "Logros",
    ["Reward"] = "Recompensa",
    ["Details"] = "Detalles",
    ["Criteria"] = "Criterios",
    ["Info"] = "Información",
    ["Shared Loot"] = "Botín compartido",
    ["Groups"] = "Grupos",
    ["Back to Groups"] = "Volver a los grupos",
    ["Back"] = "Volver",
    ["Unknown"] = "Desconocido",
    ["Item"] = "Objeto",
    ["No achievement reward listed."] = "No se muestra ninguna recompensa de logro.",
    ["Click to set waypoint."] = "Haz clic para fijar un punto de ruta.",
    ["Click to open this tracker."] = "Haz clic para abrir este rastreador.",
    ["Tracker not added yet."] = "Rastreador aún no añadido.",
    ["Coordinates pending."] = "Coordenadas pendientes.",
    ["Complete the cave run here for credit."] = "Completa aquí la cueva para obtener crédito.",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "Carga la piedra rúnica con Arcana latente para iniciar su evento de defensa.",
    ["Achievement credit from:"] = "Crédito del logro por:",
    ["Stormarion Assault"] = "Asalto a Stormarion",
    ["Ever-Painting"] = "Pintura eterna",
    ["Track the known Ever-Painting canvases. x/y marked."] = "Sigue los lienzos conocidos de Ever-Painting. x/y marcados.",
    ["Tracked entries for Ever-Painting have not been added yet."] = "Las entradas rastreadas para Ever-Painting aún no se han añadido.",
    ["Runestone Rush"] = "Fiebre de piedras rúnicas",
    ["Track the known Runestone Rush entries. x/y marked."] = "Sigue las entradas conocidas de Runestone Rush. x/y marcados.",
    ["Tracked entries for Runestone Rush have not been added yet."] = "Las entradas rastreadas para Runestone Rush aún no se han añadido.",
    ["The Party Must Go On"] = "La fiesta debe continuar",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "Sigue las cuatro invitaciones de facción de La fiesta debe continuar. x/y marcados.",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "Las entradas rastreadas para La fiesta debe continuar aún no se han añadido.",
    ["Explore trackers"] = "Rastreadores de exploración",
    ["Track Explore Eversong Woods progress. x/y marked."] = "Sigue el progreso de Explorar Bosque Canción Eterna. x/y marcados.",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "Las entradas rastreadas para Explorar Bosque Canción Eterna aún no se han añadido.",
    ["Track Explore Voidstorm progress. x/y marked."] = "Sigue el progreso de Explorar Tormenta Abisal. x/y marcados.",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "Las entradas rastreadas para Explorar Tormenta Abisal aún no se han añadido.",
    ["Track Explore Zul'Aman progress. x/y marked."] = "Sigue el progreso de Explorar Zul'Aman. x/y marcados.",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "Las entradas rastreadas para Explorar Zul'Aman aún no se han añadido.",
    ["Track Explore Harandar progress. x/y marked."] = "Sigue el progreso de Explorar Harandar. x/y marcados.",
    ["Tracked entries for Explore Harandar have not been added yet."] = "Las entradas rastreadas para Explorar Harandar aún no se han añadido.",
    ["Thrill of the Chase"] = "La emoción de la persecución",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "Esquiva el agarre de la Presencia Hambrienta en Tormenta Abisal durante al menos 60 segundos.",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "Este logro no necesita seguimiento de coordenadas en LiteVault. Sobrevive al evento de la Presencia Hambrienta en Tormenta Abisal durante al menos 60 segundos.",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "Las entradas rastreadas para La emoción de la persecución aún no se han añadido.",
    ["No Time to Paws"] = "No hay tiempo para patas",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "Completa la misión del mundo de Harandar 'Aplicación de la garra' con 15 o más acumulaciones de Persecución del depredador.",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "Este logro no necesita seguimiento de coordenadas en LiteVault. Completa la misión del mundo de Harandar 'Aplicación de la garra' con 15 o más acumulaciones de Persecución del depredador.",
    ["Tracked entries for No Time to Paws have not been added yet."] = "Las entradas rastreadas para No hay tiempo para patas aún no se han añadido.",
    ["From The Cradle to the Grave"] = "De la cuna a la tumba",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "Intenta volar hasta La Cuna, en lo alto del cielo sobre Harandar.",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "Vuela hacia La Cuna, en lo alto del cielo sobre Harandar, para completar este logro.",
    ["Chronicler of the Haranir"] = "Cronista de los Haranir",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "Estos diarios solo están disponibles durante la misión semanal ligada a la cuenta 'Leyendas de los Haranir'. Mientras estés en una visión, busca el icono de la lupa en tu minimapa.",
    ["Recover the Haranir journal entries listed below."] = "Recupera las entradas del diario de los Haranir que aparecen a continuación.",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "Recupera las entradas del diario de los Haranir que aparecen a continuación. x/y marcados.",
    ["Legends Never Die"] = "Las leyendas nunca mueren",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "Esto está vinculado a la misión semanal ligada a la cuenta 'Leyendas de los Haranir'. Si aún no tienes progreso, se calcula que tardarás unas 7 semanas en completarlo.",
    ["Defend each Haranir legend location listed below."] = "Defiende cada ubicación de leyenda de los Haranir indicada a continuación.",
    ["Protect each Haranir legend location listed below. x/y marked."] = "Protege cada ubicación de leyenda de los Haranir indicada a continuación. x/y marcados.",
    ["Dust 'Em Off"] = "Sacúdeles el polvo",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "Encuentra todas las polillas brillantes escondidas en Harandar. x/y encontradas.",
    ["Coordinate groups have not been added yet."] = "Los grupos de coordenadas aún no se han añadido.",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "Este rastreador está dividido en 3 grupos de 40 coordenadas para que las rutas de polillas sean manejables.",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "Las polillas 1-40 aparecen con Renombre Hara'ti 1, seguimiento en Renombre 2.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Las polillas 41-80 aparecen con Renombre Hara'ti 4, seguimiento en Renombre 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Las polillas 81-120 aparecen con Renombre Hara'ti 9, seguimiento en Renombre 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "Las rutas de LiteVault asumen que ya tienes desbloqueado el Renombre Hara'ti 11.",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s contiene %d coordenadas de polillas. Haz clic en una polilla para colocar un punto de ruta.",
    ["Group 1"] = "Grupo 1",
    ["Group 2"] = "Grupo 2",
    ["Group 3"] = "Grupo 3",
    ["Moths"] = "Polillas",
    ["A Singular Problem"] = "Un problema singular",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "Completa las tres oleadas del Asalto a Stormarion. x/y marcados.",
    ["Tracked entries for A Singular Problem have not been added yet."] = "Las entradas rastreadas para Un problema singular aún no se han añadido.",
    ["Abundance: Prosperous Plentitude!"] = "Abundancia: ¡Plenitud próspera!",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "Completa una carrera de cueva de Cosecha abundante en cada ubicación. x/y marcados.",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "Tienes que completar una carrera de cueva de Cosecha abundante en cada ubicación para obtener crédito. No basta con visitar la cueva.",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "Las entradas rastreadas para Abundancia: ¡Plenitud próspera! aún no se han añadido.",
    ["Altar of Blessings"] = "Altar de bendiciones",
    ["Trigger each listed blessing effect for credit."] = "Activa cada efecto de bendición indicado para obtener crédito.",
    ["Trigger each listed blessing effect. x/y marked."] = "Activa cada efecto de bendición indicado. x/y marcados.",
    ["Meta achievement summaries"] = "Resúmenes de meta logros",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "Completa los logros de Bosque Canción Eterna indicados a continuación. x/y hechos.",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "Completa todos los logros de Tormenta Abisal indicados a continuación. x/y hechos.",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "Completa todos los logros de Zul'Aman indicados a continuación. x/y hechos.",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "Ayuda a los Hara'ti completando los logros siguientes. x/y hechos.",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "Reúne a tus fuerzas contra Xal'atath completando los logros siguientes. x/y hechos.",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "Las entradas rastreadas para Making an Amani Out of You aún no se han añadido.",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "Las entradas rastreadas para That's Aln, Folks! aún no se han añadido.",
    ["Tracked entries for Forever Song have not been added yet."] = "Las entradas rastreadas para Forever Song aún no se han añadido.",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "Las entradas rastreadas para Yelling into the Voidstorm aún no se han añadido.",
    ["Tracked entries for Light Up the Night have not been added yet."] = "Las entradas rastreadas para Light Up the Night aún no se han añadido.",
    ["Mount: Brilliant Petalwing"] = "Montura: Alapétalo brillante",
    ["Housing Decor: On'ohia's Call"] = "Decoración de vivienda: Llamada de On'ohia",
    ["Title: \"Dustlord\""] = "Título: \"Señor del polvo\"",
    ["Title: \"Chronicler of the Haranir\""] = "Título: \"Cronista de los Haranir\"",
    ["home reward labels:"] = "Etiquetas de recompensa del hogar:",
}

L["Raid resync unavailable."] = "La resincronización de banda no está disponible."
L["Time played messages will be suppressed."] = "Los mensajes de tiempo jugado se ocultarán."
L["Time played messages restored."] = "Los mensajes de tiempo jugado se han restaurado."
L["%dm %02ds"] = "%d min %02d s"
L["Crests:"] = "Blasones:"
L["Mount Drops"] = "Botín de montura"
L["(Collected)"] = "(Obtenida)"
L["(Uncollected)"] = "(No obtenida)"
L["Mounts: %d/%d"] = "Monturas: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Monturas: %d/%d"
L["The Voidspire"] = "La Aguja del Vacío"
L["The Dreamrift"] = "La Grieta Onírica"
L["March of Quel'Danas"] = "La Marcha de Quel'Danas"
L["Raid Progression"] = "Progreso de banda"
L["Lady Liadrin Weekly"] = "Semanal: Lady Liadrin"
L["Change Log"] = "Registro de cambios"
L["Back"] = "Atrás"
L["Warband Bank"] = "Banco de banda guerrera"
L["Treatise"] = "Tratado"
L["Artisan"] = "Artesano"
L["Catch-up"] = "Puesta al día"
L["LiteVault Update Summary"] = "Resumen de la actualización de LiteVault"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Se han renovado varios elementos principales de la interfaz, incluidos el icono de moneda, el icono de banda, la barra de profesiones y el seguimiento de la Gran Cámara."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "Se ha actualizado la visualización del nivel de objeto del botín de la cámara para que se parezca más a la presentación predeterminada de la Gran Cámara de Blizzard."
L["Added a large batch of new translations across supported locales."] = "Se ha añadido un gran lote de nuevas traducciones en los idiomas compatibles."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "Se ha mejorado la visualización y la actualización del texto localizado en todo el addon."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "Se ha actualizado la compatibilidad de localización para botones, pestañas de bolsas, texto semanal y otras etiquetas de la interfaz."
L["Fixed multiple localization-related layout issues."] = "Se han corregido varios problemas de diseño relacionados con la localización."
L["Fixed several localization-related crash issues."] = "Se han corregido varios cierres inesperados relacionados con la localización."

-- Register this locale
lv.RegisterLocale("esES", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["esES"] = L




