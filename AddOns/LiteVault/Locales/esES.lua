-- esES.lua - Spanish locale for LiteVault
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
    TOOLTIP_VOIDSHARDS_TITLE = "Ascendant Voidshards",
    TOOLTIP_VOIDCORES_TITLE = "Ascendant Voidcores",

    TOOLTIP_VAULT_TITLE = "La Gran Bóveda",
    TOOLTIP_VAULT_DESC = "Pulsa para abrir la Gran Bóveda",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Abrir la Gran Bóveda.",
    TOOLTIP_VAULT_ALT_ONLY = "La Gran Bóveda solo puede abrirse para el personaje activo.",

    TOOLTIP_CURRENCY_TITLE = "Monedas del personaje",
    TOOLTIP_CURRENCY_DESC = "Clic para ver la lista completa.",

    TOOLTIP_BAGS_TITLE = "Ver bolsas",
    TOOLTIP_BAGS_DESC = "Ver contenido guardado de bolsas y bolsa de reagentes.",

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
    ["Darkness Unmade"] = "Oscuridad Deshecha",
    ["Cosechando el Vacío"] = "Cosechando el Vacío",
    ["Midnight: Saltheril's Soiree"] = "Medianoche: velada de Saltheril",
    ["Fortificar las piedras rúnicas: Caballeros de Sangre"] = "Fortificar las piedras rúnicas: Caballeros de Sangre",
    ["Fortificar las piedras rúnicas: Sombras del Barrio"] = "Fortificar las piedras rúnicas: Sombras del Barrio",
    ["Fortificar las piedras rúnicas: Magistrados"] = "Fortificar las piedras rúnicas: Magistrados",
    ["Fortificar las piedras rúnicas: Errantes"] = "Fortificar las piedras rúnicas: Errantes",
    ["Dales más brío al andar"] = "Dales más brío al andar",
    ["Tentempiés ligeros"] = "Tentempiés ligeros",
    ["Less Lawless"] = "Menos desenfreno",
    ["The Subtle Game"] = "El juego sutil",
    ["Cortejando el éxito"] = "Cortejando el éxito",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Alquimia",
    ["Herrería"] = "Herrería",
    ["Enchanting"] = "Encantamiento",
    ["Ingeniería"] = "Ingeniería",
    ["Inscripción"] = "Inscripción",
    ["Joyería"] = "Joyería",
    ["Peletería"] = "Peletería",
    ["Sastrería"] = "Sastrería",
    ["Herboristería"] = "Herboristería",
    ["Minería"] = "Minería",
    ["Skinning"] = "Desuello",

    ["Remnant of Anguish"] = "Remanente de angustia",
    ["Shard of Dundun"] = "Fragmento de Dundun",
    ["Adventurer Dawncrest"] = "Emblema del Alba de aventurero",
    ["Veteran Dawncrest"] = "Emblema del Alba de veterano",
    ["Emblema del Alba de campeón"] = "Emblema del Alba de campeón",
    ["Emblema del Alba de héroe"] = "Emblema del Alba de héroe",
    ["Emblema del Alba mítico"] = "Emblema del Alba mítico",
    ["Brimming Arcana"] = "Arcana rebosante",
    ["Marga de luz del Vacío"] = "Marga de luz del Vacío",
    ["Undercoin"] = "Moneda inferior",
    ["Throw the Dice"] = "Tira los dados",
    ["We Need a Refill"] = "Necesitamos reponer",
    ["Lovely Plumage"] = "Plumaje encantador",
    ["The Cauldron of Echoes"] = "El caldero de los ecos",
    ["The Echoless Flame"] = "La llama sin eco",
    ["Hidey-Hole"] = "Escondite",
    ["Victorious Stormarion Pinnacle Cache"] = "Alijo de la Cima de Stormarion victoriosa",
    ["Overflowing Abundant Satchel"] = "Cartera rebosante de abundancia",
    ["Paquete de suministros del aprendiz ávido"] = "Paquete de suministros del aprendiz ávido",
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
    BUTTON_PROFIT = "Beneficio",
    LABEL_PROFIT_GOALS = "Objetivos de banda guerrera",
    LABEL_WEEKLY_GOAL = "Objetivo semanal",
    LABEL_MONTHLY_GOAL = "Objetivo mensual",
    BUTTON_EDIT = "Editar",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "Mayor beneficio neto de este reinicio.",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "Mejor beneficio neto del mes actual.",
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
    ["Completa «Gloria del Abisante de Midnight» para obtener esta montura."] = "Completa «Gloria del Abisante de Midnight» para obtener esta montura.",
    ["Halcón dragón carmesí"] = "Halcón dragón carmesí",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Reward"] = "Recompensa",
    ["Información"] = "Información",
    ["Botín compartido"] = "Botín compartido",
    ["Back"] = "Volver",
    ["Unknown"] = "Desconocido",
    ["Item"] = "Objeto",
    ["Click to set waypoint."] = "Haz clic para fijar un punto de ruta.",
    ["Rastreador aún no añadido."] = "Rastreador aún no añadido.",
    ["Completa aquí la cueva para obtener crédito."] = "Completa aquí la cueva para obtener crédito.",
    ["Carga la piedra rúnica con Arcana latente para iniciar su evento de defensa."] = "Carga la piedra rúnica con Arcana latente para iniciar su evento de defensa.",
    ["Crédito del logro por:"] = "Crédito del logro por:",
    ["Ever-Painting"] = "Pintura eterna",
    ["Las entradas rastreadas para Ever-Painting aún no se han añadido."] = "Las entradas rastreadas para Ever-Painting aún no se han añadido.",
    ["Fiebre de piedras rúnicas"] = "Fiebre de piedras rúnicas",
    ["Las entradas rastreadas para Runestone Rush aún no se han añadido."] = "Las entradas rastreadas para Runestone Rush aún no se han añadido.",
    ["Sigue las cuatro invitaciones de facción de La fiesta debe continuar. x/y marcados."] = "Sigue las cuatro invitaciones de facción de La fiesta debe continuar. x/y marcados.",
    ["Las entradas rastreadas para La fiesta debe continuar aún no se han añadido."] = "Las entradas rastreadas para La fiesta debe continuar aún no se han añadido.",
    ["Rastreadores de exploración"] = "Rastreadores de exploración",
    ["Sigue el progreso de Explorar Bosque Canción Eterna. x/y marcados."] = "Sigue el progreso de Explorar Bosque Canción Eterna. x/y marcados.",
    ["Las entradas rastreadas para Explorar Bosque Canción Eterna aún no se han añadido."] = "Las entradas rastreadas para Explorar Bosque Canción Eterna aún no se han añadido.",
    ["Las entradas rastreadas para Explorar Tormenta Abisal aún no se han añadido."] = "Las entradas rastreadas para Explorar Tormenta Abisal aún no se han añadido.",
    ["Las entradas rastreadas para Explorar Zul'Aman aún no se han añadido."] = "Las entradas rastreadas para Explorar Zul'Aman aún no se han añadido.",
    ["Las entradas rastreadas para Explorar Harandar aún no se han añadido."] = "Las entradas rastreadas para Explorar Harandar aún no se han añadido.",
    ["La emoción de la persecución"] = "La emoción de la persecución",
    ["Las entradas rastreadas para La emoción de la persecución aún no se han añadido."] = "Las entradas rastreadas para La emoción de la persecución aún no se han añadido.",
    ["Completa la misión del mundo de Harandar 'Aplicación de la garra' con 15 o más acumulaciones de Persecución del depredador."] = "Completa la misión del mundo de Harandar 'Aplicación de la garra' con 15 o más acumulaciones de Persecución del depredador.",
    ["Este logro no necesita seguimiento de coordenadas en LiteVault. Completa la misión del mundo de Harandar 'Aplicación de la garra' con 15 o más acumulaciones de Persecución del depredador."] = "Este logro no necesita seguimiento de coordenadas en LiteVault. Completa la misión del mundo de Harandar 'Aplicación de la garra' con 15 o más acumulaciones de Persecución del depredador.",
    ["Las entradas rastreadas para No hay tiempo para patas aún no se han añadido."] = "Las entradas rastreadas para No hay tiempo para patas aún no se han añadido.",
    ["Estos diarios solo están disponibles durante la misión semanal 'Leyendas de los Haranir'. Mientras estés en una visión, busca el icono de la lupa en tu minimapa."] = "Estos diarios solo están disponibles durante la misión semanal 'Leyendas de los Haranir'. Mientras estés en una visión, busca el icono de la lupa en tu minimapa.",
    ["Recupera las entradas del diario de los Haranir que aparecen a continuación."] = "Recupera las entradas del diario de los Haranir que aparecen a continuación.",
    ["Recupera las entradas del diario de los Haranir que aparecen a continuación. x/y marcados."] = "Recupera las entradas del diario de los Haranir que aparecen a continuación. x/y marcados.",
    ["Esto está vinculado a la misión semanal 'Leyendas de los Haranir'. Si aún no tienes progreso, se calcula que tardarás unas 7 semanas en completarlo."] = "Esto está vinculado a la misión semanal 'Leyendas de los Haranir'. Si aún no tienes progreso, se calcula que tardarás unas 7 semanas en completarlo.",
    ["Defiende cada ubicación de leyenda de los Haranir indicada a continuación."] = "Defiende cada ubicación de leyenda de los Haranir indicada a continuación.",
    ["Protege cada ubicación de leyenda de los Haranir indicada a continuación. x/y marcados."] = "Protege cada ubicación de leyenda de los Haranir indicada a continuación. x/y marcados.",
    ["Sacúdeles el polvo"] = "Sacúdeles el polvo",
    ["Los grupos de coordenadas aún no se han añadido."] = "Los grupos de coordenadas aún no se han añadido.",
    ["Este rastreador está dividido en 3 grupos de 40 coordenadas para que las rutas de polillas sean manejables."] = "Este rastreador está dividido en 3 grupos de 40 coordenadas para que las rutas de polillas sean manejables.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Las polillas 41-80 aparecen con Renombre Hara'ti 4, seguimiento en Renombre 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Las polillas 81-120 aparecen con Renombre Hara'ti 9, seguimiento en Renombre 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "Las rutas de LiteVault asumen que ya tienes desbloqueado el Renombre Hara'ti 11.",
    ["Group 1"] = "Grupo 1",
    ["Group 2"] = "Grupo 2",
    ["Group 3"] = "Grupo 3",
    ["Las entradas rastreadas para Un problema singular aún no se han añadido."] = "Las entradas rastreadas para Un problema singular aún no se han añadido.",
    ["Abundancia: ¡Plenitud próspera!"] = "Abundancia: ¡Plenitud próspera!",
    ["Completa una carrera de cueva de Cosecha abundante en cada ubicación. x/y marcados."] = "Completa una carrera de cueva de Cosecha abundante en cada ubicación. x/y marcados.",
    ["Tienes que completar una carrera de cueva de Cosecha abundante en cada ubicación para obtener crédito. No basta con visitar la cueva."] = "Tienes que completar una carrera de cueva de Cosecha abundante en cada ubicación para obtener crédito. No basta con visitar la cueva.",
    ["Las entradas rastreadas para Abundancia: ¡Plenitud próspera! aún no se han añadido."] = "Las entradas rastreadas para Abundancia: ¡Plenitud próspera! aún no se han añadido.",
    ["Altar of Blessings"] = "Altar de bendiciones",
    ["Activa cada efecto de bendición indicado para obtener crédito."] = "Activa cada efecto de bendición indicado para obtener crédito.",
    ["Activa cada efecto de bendición indicado. x/y marcados."] = "Activa cada efecto de bendición indicado. x/y marcados.",
    ["Resúmenes de meta logros"] = "Resúmenes de meta logros",
    ["Completa los logros de Bosque Canción Eterna indicados a continuación. x/y hechos."] = "Completa los logros de Bosque Canción Eterna indicados a continuación. x/y hechos.",
    ["Completa todos los logros de Tormenta Abisal indicados a continuación. x/y hechos."] = "Completa todos los logros de Tormenta Abisal indicados a continuación. x/y hechos.",
    ["Completa todos los logros de Zul'Aman indicados a continuación. x/y hechos."] = "Completa todos los logros de Zul'Aman indicados a continuación. x/y hechos.",
    ["Reúne a tus fuerzas contra Xal'atath completando los logros siguientes. x/y hechos."] = "Reúne a tus fuerzas contra Xal'atath completando los logros siguientes. x/y hechos.",
    ["Las entradas rastreadas para Making an Amani Out of You aún no se han añadido."] = "Las entradas rastreadas para Making an Amani Out of You aún no se han añadido.",
    ["Las entradas rastreadas para That's Aln, Folks! aún no se han añadido."] = "Las entradas rastreadas para That's Aln, Folks! aún no se han añadido.",
    ["Las entradas rastreadas para Forever Song aún no se han añadido."] = "Las entradas rastreadas para Forever Song aún no se han añadido.",
    ["Las entradas rastreadas para Yelling into the Voidstorm aún no se han añadido."] = "Las entradas rastreadas para Yelling into the Voidstorm aún no se han añadido.",
    ["Las entradas rastreadas para Light Up the Night aún no se han añadido."] = "Las entradas rastreadas para Light Up the Night aún no se han añadido.",
    ["Montura: Alapétalo brillante"] = "Montura: Alapétalo brillante",
    ["Decoración de vivienda: Llamada de On'ohia"] = "Decoración de vivienda: Llamada de On'ohia",
    ["Título: \"Señor del polvo\""] = "Título: \"Señor del polvo\"",
    ["Título: \"Cronista de los Haranir\""] = "Título: \"Cronista de los Haranir\"",
    ["home reward labels:"] = "Etiquetas de recompensa del hogar:",
}

L["La resincronización de banda no está disponible."] = "La resincronización de banda no está disponible."
L["Los mensajes de tiempo jugado se ocultarán."] = "Los mensajes de tiempo jugado se ocultarán."
L["Time played messages restored."] = "Los mensajes de tiempo jugado se han restaurado."
L["%dm %02ds"] = "%d min %02d s"
L["Crests:"] = "Blasones:"
L["Botín de montura"] = "Botín de montura"
L["(Collected)"] = "(Obtenida)"
L["(Uncollected)"] = "(No obtenida)"
L["Mounts: %d/%d"] = "Monturas: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Monturas: %d/%d"
L["La Aguja del Vacío"] = "La Aguja del Vacío"
L["La Grieta Onírica"] = "La Grieta Onírica"
L["March of Quel'Danas"] = "La Marcha de Quel'Danas"
L["Raid Progression"] = "Progreso de banda"
L["Lady Liadrin Weekly"] = "Semanal: Lady Liadrin"
L["Change Log"] = "Registro de cambios"
L["Atrás"] = "Atrás"
L["Warband Bank"] = "Banco de banda guerrera"
L["Treatise"] = "Tratado"
L["Artisan"] = "Artesano"
L["Puesta al día"] = "Puesta al día"
L["Resumen de la actualización de LiteVault"] = "Resumen de la actualización de LiteVault"
L["Se han renovado varios elementos principales de la interfaz, incluidos el icono de moneda, el icono de banda, la barra de profesiones y el seguimiento de la Gran Cámara."] = "Se han renovado varios elementos principales de la interfaz, incluidos el icono de moneda, el icono de banda, la barra de profesiones y el seguimiento de la Gran Cámara."
L["Se ha actualizado la visualización del nivel de objeto del botín de la cámara para que se parezca más a la presentación predeterminada de la Gran Cámara de Blizzard."] = "Se ha actualizado la visualización del nivel de objeto del botín de la cámara para que se parezca más a la presentación predeterminada de la Gran Cámara de Blizzard."
L["Se ha añadido un gran lote de nuevas traducciones en los idiomas compatibles."] = "Se ha añadido un gran lote de nuevas traducciones en los idiomas compatibles."
L["Se ha mejorado la visualización y la actualización del texto localizado en todo el addon."] = "Se ha mejorado la visualización y la actualización del texto localizado en todo el addon."
L["Se ha actualizado la compatibilidad de localización para botones, pestañas de bolsas, texto semanal y otras etiquetas de la interfaz."] = "Se ha actualizado la compatibilidad de localización para botones, pestañas de bolsas, texto semanal y otras etiquetas de la interfaz."
L["Se han corregido varios problemas de diseño relacionados con la localización."] = "Se han corregido varios problemas de diseño relacionados con la localización."
L["Se han corregido varios cierres inesperados relacionados con la localización."] = "Se han corregido varios cierres inesperados relacionados con la localización."

L["BUTTON_BREAKDOWN"] = "Desglose"
L["BUTTON_WARBAND_PROFIT_BREAKDOWN"] = "Desglose de banda guerrera"
L["BUTTON_RITUAL_SITES"] = "Sitios rituales"
L["Renombre máximo"] = "Renombre máximo"
L["Parangón"] = "Parangón"
L["LABEL_REWARD_FMT"] = "Recompensa: %s"
L["LABEL_REWARD_LOADING"] = "Cargando datos de recompensa..."
L["Haz clic para cambiar a esta facción."] = "Haz clic para cambiar a esta facción."
L["LABEL_GAINED"] = "Ganado"
L["LABEL_TOP_SOURCES"] = "Fuentes principales"
L["LABEL_TOP_INCOME_SOURCE"] = "Fuente principal de ingresos"
L["LABEL_TOP_EXPENSE_SOURCE"] = "Fuente principal de gastos"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "Mezcla de fuentes de los ingresos y gastos semanales de tu banda guerrera."
L["De dónde obtuvo más oro tu banda guerrera esta semana."] = "De dónde obtuvo más oro tu banda guerrera esta semana."
L["Dónde gastó más oro tu banda guerrera esta semana."] = "Dónde gastó más oro tu banda guerrera esta semana."
L["Aún no hay ingresos registrados."] = "Aún no hay ingresos registrados."
L["Aún no hay gastos registrados."] = "Aún no hay gastos registrados."
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No se encontraron misiones del mundo de oro activas."
L["LEDGER_WORLD_QUESTS"] = "Misiones del mundo"
L["LEDGER_UPGRADE"] = "Mejora"
L["Desactivar marcadores de piedra rúnica en el mapa"] = "Desactivar marcadores de piedra rúnica en el mapa"
L["Oculta los marcadores de piedra rúnica de LiteVault en el mapa del Bosque Canción Eterna."] = "Oculta los marcadores de piedra rúnica de LiteVault en el mapa del Bosque Canción Eterna."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "Activar resaltados de beneficio en el calendario"
L["Muestra resaltados verdes y rojos para los días de beneficio en el calendario."] = "Muestra resaltados verdes y rojos para los días de beneficio en el calendario."
L["Próxima semana: %s"] = "Próxima semana: %s"
L["LABEL_MONTHLY_PROFIT"] = "Beneficio mensual"
L["LABEL_TOP_WEEKLY_EARNERS"] = "Mayores ganancias semanales"
L["LABEL_TOP_MONTHLY_EARNERS"] = "Mayores ganancias mensuales"

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

L["LABEL_MAX_RENOWN"] = "Maximum Renown"
L["LABEL_PARAGON"] = "Paragon"
L["TOOLTIP_FACTION_CARD_HINT"] = "Click to switch this faction."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "Where your warband made the most gold this week."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "Where your warband spent the most gold this week."
L["MSG_PROFIT_NO_INCOME"] = "No income recorded yet."
L["MSG_PROFIT_NO_SPENDING"] = "No spending recorded yet."
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "Disable Runestone Map Pins"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "Hide LiteVault's Fortify the Runestones pins on the Eversong Woods map."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"] = "Show green and red profit-day highlights on the calendar."
L["Void Strike"] = "Void Strike"
L["Void Assaults"] = "Void Assaults"
L["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods"
L["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman"
L["LABEL_NEXT_WEEK_FMT"] = "Next Week: %s"
L["Harvesting the Void"] = "Harvesting the Void"
L["Blacksmithing"] = "Blacksmithing"
L["Engineering"] = "Engineering"
L["Inscription"] = "Inscription"
L["Jewelcrafting"] = "Jewelcrafting"
L["Leatherworking"] = "Leatherworking"
L["Tailoring"] = "Tailoring"
L["Herbalism"] = "Herbalism"
L["Mining"] = "Mining"
L["Voidlight Marl"] = "Voidlight Marl"
L["Champion Dawncrest"] = "Champion Dawncrest"
L["Hero Dawncrest"] = "Hero Dawncrest"
L["Myth Dawncrest"] = "Myth Dawncrest"
L["Raid resync unavailable."] = "Raid resync unavailable."
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Mount Drops"] = "Mount Drops"
L["The Voidspire"] = "The Voidspire"
L["The Dreamrift"] = "The Dreamrift"
L["Catch-up"] = "Catch-up"
L["LiteVault Update Summary"] = "LiteVault Update Summary"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."
L["Added a large batch of new translations across supported locales."] = "Added a large batch of new translations across supported locales."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "Improved localized text rendering and refresh behavior throughout the addon."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "Updated localization support for buttons, bag tabs, weekly text, and other UI labels."
L["Fixed multiple localization-related layout issues."] = "Fixed multiple localization-related layout issues."
L["Fixed several localization-related crash issues."] = "Fixed several localization-related crash issues."

L["LABEL_CHARACTER"] = "Character"

L["WARNING_WEEKLY_AMANI_CHOICE"] = "Warning! Once you choose an Amani Tribe quest, it's locked to your account."
L["WARNING_WEEKLY_SINGULARITY_CHOICE"] = "Warning! Once you choose a The Singularity quest, it's locked to your account."

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
lv.RegisterLocale("esES", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["esES"] = L
