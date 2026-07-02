-- ptBR.lua - Brazilian Portuguese locale for LiteVault
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
    BUTTON_CLOSE = "Fechar",
    BUTTON_YES = "Sim",
    BUTTON_NO = "Não",
    BUTTON_MANAGE = "Gerenciar",
    BUTTON_BACK = "Voltar",
    BUTTON_ALL = "Todos",
    BUTTON_NONE = "Nenhum",
    BUTTON_FILTER = "Filtrar",
    DIALOG_DELETE_CHAR = "Excluir %s do LiteVault?",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "Filtros do mapa",

    BUTTON_RAID_LOCKOUTS = "Bloqueios de raide",
    BUTTON_WORLD_EVENTS = "Eventos mundiais",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "Bloqueios de raide",
    TOOLTIP_RAID_LOCKOUTS_DESC = "Ver chefes derrotados de todos os personagens",
    TOOLTIP_THEME_TITLE = "Alternar tema",
    TOOLTIP_THEME_DESC = "Alternar entre modo escuro e claro",
    TOOLTIP_FILTER_TITLE = "Filtro do mapa",
    TOOLTIP_FILTER_DESC = "Clique para ver lista completa",
    TOOLTIP_WORLD_EVENTS_TITLE = "Eventos mundiais",
    TOOLTIP_WORLD_EVENTS_DESC = "Ver eventos mundiais",

    -- Sort controls
    LABEL_SORT_BY = "Ordenar:",
    SORT_GOLD = "Ouro",
    SORT_ILVL = "iLvl",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "Atividade",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "Missões semanais de %s",
    BUTTON_WEEKLIES = "Semanais",
    BUTTON_EVENTS = "Eventos",
    BUTTON_FACTIONS = "Facções",
    BUTTON_AMANI_TRIBE = "Tribo Amani",
    BUTTON_HARATI = "Hara'ti",
    BUTTON_SINGULARITY = "A Singularidade",
    BUTTON_SILVERMOON_COURT = "Corte de Luaprata",
    TITLE_FACTION_WEEKLIES = "Semanais de facção de %s",
    WARNING_EVENT_QUESTS = "Alguns desses eventos estão bugados ou bloqueados no jogo.",

    WARNING_WEEKLY_HARATI_CHOICE = "Aviso! Depois de escolher uma missão de Lendas dos Haranir, ela fica bloqueada para sua conta.",
    WARNING_WEEKLY_RUNESTONES = "Aviso! Escolha a missão das Pedras Rúnicas com cuidado. Depois de escolher uma na semana, essa escolha vale para toda a conta.",
    LABEL_WEEKLY_PROFIT = "Lucro semanal:",
    LABEL_WARBAND_PROFIT = "Lucro da banda:",
    LABEL_WARBAND_BANK = "Banco da banda:",
    LABEL_TOP_EARNERS = "Maiores ganhos (Semanal):",
    LABEL_TOTAL_GOLD = "Ouro total: %s",
    LABEL_TOTAL_TIME = "Tempo total: %s",
    LABEL_COMBINED_TIME = "Tempo combinado: %dd %dh",

    TOOLTIP_TOTAL_TIME_TITLE = "Tempo total",
    TOOLTIP_TOTAL_TIME_DESC = "Tempo de jogo total de todos os personagens rastreados.",
    TOOLTIP_TOTAL_TIME_CLICK = "Clique para mudar formato.",

    -- Quest status
    STATUS_DONE = "[Concluído]",
    STATUS_IN_PROGRESS = "[Em andamento]",
    STATUS_NOT_STARTED = "[Não iniciado]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Gerenciar personagens",
    TOOLTIP_MANAGE_BACK = "Voltar à aba principal.",
    TOOLTIP_MANAGE_VIEW = "Ver personagens ignorados.",

    TOOLTIP_CATALYST_TITLE = "Cargas de catalisador",
    TOOLTIP_SPARKS_TITLE = "Faíscas de criação",
    TOOLTIP_VOIDSHARDS_TITLE = "Ascendant Voidshards",
    TOOLTIP_VOIDCORES_TITLE = "Ascendant Voidcores",

    TOOLTIP_VAULT_TITLE = "Grande C?mara",
    TOOLTIP_VAULT_DESC = "Pressione para abrir a Grande C?mara",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Abrir a Grande C?mara.",
    TOOLTIP_VAULT_ALT_ONLY = "A Grande C?mara s? pode ser aberta para o personagem ativo.",

    TOOLTIP_CURRENCY_TITLE = "Moedas do personagem",
    TOOLTIP_CURRENCY_DESC = "Clique para ver lista completa.",

    TOOLTIP_BAGS_TITLE = "Ver bolsas",
    TOOLTIP_BAGS_DESC = "Ver o conteúdo salvo das bolsas e bolsa de reagentes.",

    TOOLTIP_LEDGER_DESC = "Rastrear receitas e despesas de ouro por fonte.",

    TOOLTIP_WARBAND_BANK_TITLE = "Livro do banco da banda",
    TOOLTIP_WARBAND_BANK_DESC = "Clique para ver transações.",

    TOOLTIP_RESTORE_TITLE = "Restaurar",
    TOOLTIP_RESTORE_DESC = "Restaurar este personagem à página principal",

    TOOLTIP_IGNORE_TITLE = "Ignorar",
    TOOLTIP_IGNORE_DESC = "Remover este personagem da página principal",

    TOOLTIP_DELETE_TITLE = "Excluir",
    TOOLTIP_DELETE_DESC = "Excluir permanentemente os dados deste personagem",
    TOOLTIP_DELETE_WARNING = "Aviso: Esta ação não pode ser desfeita!",

    TOOLTIP_FAVORITE_TITLE = "Favorito",
    TOOLTIP_FAVORITE_DESC = "Fixar este personagem no topo da lista",

    -- Character data displays
    LABEL_ILVL = "iLvl: %d",
    LABEL_MPLUS_SCORE = "Pontuação M+: %d",
    LABEL_NO_KEY = "Sem chave M+",
    LABEL_NO_PROFESSIONS = "Sem profissões",
    LABEL_UNKNOWN = "Desconhecido",
    LABEL_SKILL_LEVEL = "Habilidade: %d/%d",
    LABEL_CONCENTRATION = "Concentração: %d/%d",
    LABEL_CONC_DAILY_RESET = "Diário: %dh %dm",
    LABEL_CONC_WEEKLY_RESET = "Reset completo: %dd %dh",
    LABEL_CONC_FULL = "(Cheio)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d Conhecimento disponível",
    LABEL_NO_KNOWLEDGE = "Sem conhecimento disponível",
    LABEL_VAULT_PROGRESS = "R: %d/3    M+: %d/3    M: %d/3",
    BUTTON_PROFS = "Ofícios",

    TOOLTIP_PROFS_TITLE = "Profissões",
    TOOLTIP_PROFS_DESC = "Ver concentração e conhecimento",
    TITLE_PROFESSIONS = "Profissões de %s",
    TITLE_KNOWLEDGE_SOURCES = "Fontes de Conhecimento",
    TAB_TREASURES = "Tesouros",
    LABEL_UNIQUE_TREASURES = "Tesouros únicos",
    LABEL_WEEKLY_TREASURES = "Tesouros semanais",
    LABEL_HOVER_TREASURE_CHECKLIST = "Passe o mouse para ver a lista de tesouros",
    TITLE_PROF_TREASURES_FMT = "Tesouros de %s",
    LABEL_PROFESSION = "Profissão",
    LABEL_UNIQUE_TREASURE_FMT = "Tesouro único de %s %d",
    LABEL_WEEKLY_TREASURE_FMT = "Tesouro semanal de %s %d",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "Dom",
    DAY_MON = "Seg",
    DAY_TUE = "Ter",
    DAY_WED = "Qua",
    DAY_THU = "Qui",
    DAY_FRI = "Sex",
    DAY_SAT = "Sáb",

    TOOLTIP_ACTIVITY_FOR = "Atividade para %d/%d/%d",
    MSG_NO_WORLD_EVENTS = "Sem eventos mundiais neste mês",

    -- Filter categories
    FILTER_TIMEWALKING = "Caminhada Temporal",
    FILTER_DARKMOON = "Lua Negra",
    FILTER_DUNGEONS = "Masmorras",
    FILTER_PVP = "JxJ",
    FILTER_BONUS = "Bônus",

    -- World events
    WORLD_EVENT_LOVE = "O Amor Está no Ar",
    WORLD_EVENT_LUNAR = "Festival da Lua",
    WORLD_EVENT_NOBLEGARDEN = "Jardinova",
    WORLD_EVENT_CHILDREN = "Semana das Crianças",
    WORLD_EVENT_MIDSUMMER = "Festival do Fogo do Solstício",
    WORLD_EVENT_BREWFEST = "CervaFest",
    WORLD_EVENT_HALLOWS = "Noturnália",
    WORLD_EVENT_WINTERVEIL = "Festa do Véu de Inverno",
    WORLD_EVENT_DEAD = "Dia dos Mortos",
    WORLD_EVENT_PIRATES = "Dia dos Piratas",
    WORLD_EVENT_STYLE = "Prova de Estilo",
    WORLD_EVENT_OUTLAND = "Copa de Terralém",
    WORLD_EVENT_NORTHREND = "Copa de Nortúndria",
    WORLD_EVENT_KALIMDOR = "Copa de Kalimdor",
    WORLD_EVENT_EASTERN = "Copa dos Reinos do Leste",
    WORLD_EVENT_WINDS = "Ventos da Fortuna Misteriosa",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "Moedas de %s",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "Bloqueios de raide",
    TITLE_RAID_FORMAT = "%s %s %s - Forja de Mana Ômega",

    BUTTON_PROGRESSION = "Progressão",
    BUTTON_LOCKOUTS = "Bloqueios",

    DIFFICULTY_NORMAL = "Normal",
    DIFFICULTY_HEROIC = "Heroico",
    DIFFICULTY_MYTHIC = "Mítico",

    TOOLTIP_VIEW_LOCKOUTS = "Mostrando: Bloqueios (esta semana)",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "Clique para ver Progressão (melhor resultado)",
    TOOLTIP_VIEW_PROGRESSION = "Mostrando: Progressão (melhor resultado)",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "Clique para ver Bloqueios (esta semana)",

    MSG_NO_CHAR_DATA = "Nenhum dado de personagem encontrado",
    MSG_NO_PROGRESSION = "Nenhuma progressão %s registrada",
    MSG_NO_LOCKOUT = "Sem bloqueio %s esta semana",

    LABEL_BOSS = "Chefe %d",
    LABEL_PROGRESS_COUNT = "%d/8",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "Livro do banco da banda",
    LABEL_CURRENT_BALANCE = "Saldo atual:",
    LABEL_RECENT_TRANSACTIONS = "Transações recentes:",
    MSG_NO_TRANSACTIONS = "(Nenhuma transação registrada ainda)",
    TIP_RELOAD_SAVE = "Dica: /reload antes de trocar de personagem para salvar",
    ACTION_DEPOSITED = "depositou",
    ACTION_WITHDREW = "sacou",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    LABEL_RESETS_IN = "Reinicia em %dd %dh",

    TAB_SUMMARY = "Resumo",
    TAB_HISTORY = "Histórico",
    TAB_WARBAND = "Warband",
    HEADER_SOURCE = "Fonte",
    HEADER_INCOME = "Receita",
    HEADER_EXPENSE = "Despesa",

    LABEL_TOTAL = "Total",
    LABEL_NET_PROFIT = "Lucro líquido",
    MSG_NO_GOLD_ACTIVITY = "Sem atividade de ouro esta semana",
    MSG_NO_TRANSACTIONS_WEEK = "Sem transações esta semana",

    -- Ledger source categories
    LEDGER_QUESTS = "Missões",
    LEDGER_AUCTION = "Casa de Leilões",
    LEDGER_TRADE = "Comércio",
    LEDGER_VENDOR = "Vendedor",
    LEDGER_REPAIRS = "Reparos",
    LEDGER_TRANSMOG = "Transmogrificação",
    LEDGER_FLIGHT = "Rotas de voo",
    LEDGER_CRAFTING = "Criação",
    LEDGER_CACHE = "Baú/Tesouro",
    LEDGER_MAIL = "Correio",
    LEDGER_LOOT = "Saque",
    LEDGER_WARBAND_BANK = "Banco da banda",
    LEDGER_OTHER = "Outro",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "Nunca",
    FRESH_TODAY = "Ativo hoje",
    FRESH_1_DAY = "Há 1 dia",
    FRESH_DAYS = "Há %d dias",

    -- Time format styles
    TIME_YEARS_DAYS = "%da %dd",
    TIME_DAYS_HOURS = "%dd %dh",
    TIME_DAYS = "%s Dias",
    TIME_HOURS = "%s Horas",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "Saudações %s,\nvocê gostaria que o LiteVault rastreie este personagem?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "Reinício semanal detectado! Bloqueios de raide apagados.",
    MSG_ALREADY_TRACKED = "Este personagem já está sendo rastreado.",
    MSG_CHAR_ADDED = "%s foi adicionado ao rastreamento.",
    MSG_RAID_RESET_SEASON = "A progressão de raide foi reiniciada para Midnight Temporada 1!",
    MSG_CLEARED_PROGRESSION = "Dados de progressão apagados para %d personagens.",
    MSG_WEEKLY_PROFIT_RESET = "Rastreamento de lucro semanal reiniciado para %d personagens.",
    MSG_WARBAND_BALANCE = "Banda: %s",
    MSG_WARBAND_BANK_BALANCE = "Banco da banda: %s",
    MSG_WEEKLY_DATA_RESET = "Dados semanais reiniciados para %d personagens.",
    MSG_RAID_MANUAL_RESET = "Progressão de raide reiniciada manualmente!",
    MSG_CLEARED_DATA = "Dados apagados para %d personagens.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "A mensagem inicial de tempo jogado da Blizzard não pode ser suprimida.",

    -- Slash command help
    HELP_RESET_TITLE = "Comandos de reinício do LiteVault",
    HELP_REGION = "Região: %s (reinício %s)",
    HELP_LAST_SEASON = "Último reinício de temporada: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - Reiniciar rastreamento de lucro semanal",
    HELP_RESET_SEASON = "/lvreset season - Reiniciar progressão de raide (novo nível)",
    HELP_NEVER = "Nunca",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "Idioma",
    TOOLTIP_LANGUAGE_TITLE = "Idioma",
    TOOLTIP_LANGUAGE_DESC = "Alterar o idioma da interface",
    TITLE_LANGUAGE_SELECT = "Selecionar idioma",
    LANG_AUTO = "Auto (detectar)",
    MSG_LANGUAGE_CHANGED = "Idioma alterado. Recarregue a interface para aplicar todas as alterações.",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "Opções",
    TOOLTIP_OPTIONS_TITLE = "Opções",
    TOOLTIP_OPTIONS_DESC = "Configurar as opções do LiteVault",
    TITLE_OPTIONS = "Opções do LiteVault",
    OPTION_DISABLE_TIMEPLAYED = "Desativar rastreamento de tempo jogado",
    OPTION_DISABLE_TIMEPLAYED_DESC = "Impede que mensagens /played apareçam no chat",
    OPTION_DARK_MODE = "Modo escuro",
    OPTION_DARK_MODE_DESC = "Alternar entre temas escuro e claro",
    OPTION_DISABLE_BAG_VIEWING = "Desativar visualizador de bolsas/banco",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Oculta o botão de Bolsas e desativa a visualização de bolsas, banco e banco da banda de guerra salvos.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Desativar sistema de sobreposição",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Oculta as sobreposições de nível de item e bloqueio do LiteVault no equipamento do personagem e de inspeção.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "Desativar teletransportes M+",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Oculta o emblema de teletransporte M+ e desativa o painel de teletransporte do LiteVault.",

    -- Month names
    MONTH_1 = "Janeiro",
    MONTH_2 = "Fevereiro",
    MONTH_3 = "Março",
    MONTH_4 = "Abril",
    MONTH_5 = "Maio",
    MONTH_6 = "Junho",
    MONTH_7 = "Julho",
    MONTH_8 = "Agosto",
    MONTH_9 = "Setembro",
    MONTH_10 = "Outubro",
    MONTH_11 = "Novembro",
    MONTH_12 = "Dezembro",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["Dawnlight Manaflux"] = "Fluxo de Mana do Alvorecer",

    -- ==========================================================================
    -- WEEKLY QUESTS (Midnight)
    -- ==========================================================================
    ["Community Engagement"] = "Community Engagement",
    WARNING_ACCOUNT_BOUND = "Vinculado à conta",
    ["Midnight: Prey"] = "Midnight: Prey",
    ["Saltheril's Soiree"] = "Sarau de Saltheril",
    ["Evento de Abund?ncia"] = "Evento de Abund?ncia",
    ["Legends of the Haranir"] = "Lendas dos Haranir",
    ["Escuridão Desfeita"] = "Escuridão Desfeita",
    ["Colhendo o Vácuo"] = "Colhendo o Vácuo",
    ["Midnight: Saltheril's Soiree"] = "Meia-noite: sarau de Saltheril",
    ["Fortificar as pedras rúnicas: Cavaleiros Sangrentos"] = "Fortificar as pedras rúnicas: Cavaleiros Sangrentos",
    ["Fortificar as pedras rúnicas: Sombras da Rua"] = "Fortificar as pedras rúnicas: Sombras da Rua",
    ["Fortificar as pedras rúnicas: Magísteres"] = "Fortificar as pedras rúnicas: Magísteres",
    ["Fortificar as pedras rúnicas: Andarilhos"] = "Fortificar as pedras rúnicas: Andarilhos",
    ["Dê mais impulso ao passo deles"] = "Dê mais impulso ao passo deles",
    ["Light Snacks"] = "Lanches leves",
    ["Less Lawless"] = "Menos desordem",
    ["The Subtle Game"] = "O jogo sutil",
    ["Courting Success"] = "Conquistando o sucesso",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Alquimia",
    ["Blacksmithing"] = "Ferraria",
    ["Enchanting"] = "Encantamento",
    ["Engineering"] = "Engenharia",
    ["Inscription"] = "Escrivania",
    ["Jewelcrafting"] = "Joalheria",
    ["Leatherworking"] = "Couraria",
    ["Tailoring"] = "Alfaiataria",
    ["Herbalism"] = "Herborismo",
    ["Mineração"] = "Mineração",
    ["Skinning"] = "Esfolamento",

    ["Remanescente da Angústia"] = "Remanescente da Angústia",
    ["Estilhaço de Dundun"] = "Estilhaço de Dundun",
    ["Brasão da Aurora de aventureiro"] = "Brasão da Aurora de aventureiro",
    ["Brasão da Aurora de veterano"] = "Brasão da Aurora de veterano",
    ["Brasão da Aurora de campeão"] = "Brasão da Aurora de campeão",
    ["Brasão da Aurora de herói"] = "Brasão da Aurora de herói",
    ["Brasão da Aurora mítico"] = "Brasão da Aurora mítico",
    ["Brimming Arcana"] = "Arcana transbordante",
    ["Voidlight Marl"] = "Marga da Luz do Vazio",
    ["Undercoin"] = "Submoeda",
    ["Throw the Dice"] = "Jogue os dados",
    ["We Need a Refill"] = "Precisamos reabastecer",
    ["Plumagem adorável"] = "Plumagem adorável",
    ["O caldeirão dos ecos"] = "O caldeirão dos ecos",
    ["The Echoless Flame"] = "A chama sem eco",
    ["Hidey-Hole"] = "Esconderijo",
    ["Reserva do Pináculo de Stormarion Vitoriosa"] = "Reserva do Pináculo de Stormarion Vitoriosa",
    ["Bolsa transbordando de abund?ncia"] = "Bolsa transbordando de abund?ncia",
    ["Pacote de suprimentos do aprendiz ávido"] = "Pacote de suprimentos do aprendiz ávido",
    ["Surplus Bag of Party Favors"] = "Bolsa excedente de lembrancinhas de festa",
    OPTION_ENABLE_24HR_CLOCK = "Ativar relógio de 24 horas",
    OPTION_ENABLE_24HR_CLOCK_DESC = "Alternar entre os formatos de 24h e 12h",
    TELEPORT_PANEL_TITLE = "Teletransportes M+",
    TELEPORT_CAST_BTN = "Teleporte",
    TELEPORT_ERR_COMBAT = "Não é possível se teletransportar em combate.",
    BUTTON_VAULT = "Cofre",
    BUTTON_ACTIONS = "Ações",
    BUTTON_RAIDS = "Raides",
    BUTTON_FAVORITE = "Favorito",
    BUTTON_UNFAVORITE = "Remover favorito",
    BUTTON_IGNORE = "Ignorar",
    BUTTON_RESTORE = "Restaurar",
    BUTTON_DELETE = "Excluir",
    TOOLTIP_ACTIONS_TITLE = "Ações do personagem",
    TOOLTIP_ACTIONS_DESC = "Abrir menu de ações",
    BUTTON_INSTANCES = "Inst?ncias",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Rastreador de inst?ncias",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Acompanhar masmorras e raides",
    LABEL_RENOWN_PROGRESS = "Renome %d (%d/%d)",

    LABEL_RENOWN = "Renome",
    LABEL_RENOWN_LEVEL = "Nível",
    LABEL_RENOWN_UNAVAILABLE = "Renome indisponível",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "Nenhuma missão de facção configurada ainda.",
    BUTTON_KNOWLEDGE = "Conhecimento",
    WORLD_EVENT_SALTHERIL = "Sarau de Saltheril",
    WORLD_EVENT_ABUNDANCE = "Abund?ncia",
    WORLD_EVENT_HARANIR = "Lendas dos Haranir",
    WORLD_EVENT_STORMARION = "Assalto de Stormarion",
    TITLE_KNOWLEDGE_TRACKER = "Rastreador de conhecimento",
    TOOLTIP_KNOWLEDGE_DESC = "Ver conhecimento gasto, não gasto e máximo",
    LABEL_SPENT = "Gasto",
    LABEL_UNSPENT = "Não gasto",
    LABEL_MAX = "Máximo",
    LABEL_EARNED = "Obtido",
    LABEL_TREATISE = "Tratado",
    LABEL_ARTISAN_QUEST = "Artífice",
    LABEL_CATCHUP = "Atualização",
    LABEL_WEEKLY = "Semanal",
    LABEL_UNLOCKED = "Desbloqueado",
    LABEL_UNLOCK_REQUIREMENTS = "Requisitos de desbloqueio",
    LABEL_SOURCE_NOTE = "Fontes semanais e panorama de recuperação",
    LABEL_TREASURE_CLICK_HINT = "Clique em um tesouro único para definir um ponto de rota",
    LABEL_ZONE = "Zona",
    LABEL_QUEST = "Missão",
    LABEL_COORDINATES = "Coordenadas",
    TOOLTIP_TREASURE_SET_WAYPOINT = "Clique para colocar um ponto de rota do TomTom",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "Clique para colocar um ponto de rota no mapa",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "Este tesouro não tem localização fixa",
    MSG_TREASURE_NO_WAYPOINT = "Este tesouro não tem um ponto de rota fixo.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom não detectado.",
    MSG_TREASURE_WAYPOINT_SET = "Ponto de rota definido: %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "Ponto no mapa definido: %s (%.1f, %.1f)",
    STATUS_DONE_WORD = "Concluído",
    STATUS_MISSING_WORD = "Faltando",
    LABEL_MIDNIGHT_SEASON_1 = "Temporada 1 de Midnight",
    TAB_SOURCES = "Fontes",
    TIME_TODAY = "Hoje %H:%M",
    MSG_CAP_WARNING = "Aviso de limite de inst?ncia! %d/10 inst?ncias nesta hora.",
    MSG_CAP_SLOT_OPEN = "Um espaço de instância está livre agora! (%d/10 usadas)",
    MSG_RELOAD_TIMEPLAYED = "Recarregue a interface para aplicar a supressão do tempo jogado.",
    MSG_RAID_DEBUG_ON = "Depuração de raide do LiteVault: LIGADA",
    MSG_RAID_DEBUG_OFF = "Depuração de raide do LiteVault: DESLIGADA",
    MSG_RAID_DEBUG_TIP = "Use /lvraiddbg novamente para desligar a saída de depuração",
    MSG_TRACKED_KILL = "Abate rastreado de %s: %s (%s)",
    LOCALE_DEBUG_ON = "Modo de depuração de idioma LIGADO - exibindo chaves de texto",
    LOCALE_DEBUG_OFF = "Modo de depuração de idioma DESLIGADO - exibindo traduções",
    LOCALE_BORDERS_ON = "Modo de bordas LIGADO - exibindo limites do texto",
    LOCALE_BORDERS_HINT = "Verde = cabe, Vermelho = pode ultrapassar",
    LOCALE_BORDERS_OFF = "Modo de bordas DESLIGADO",
    LOCALE_FORCED = "Idioma forçado para %s",
    LOCALE_RESET_TIP = "Use /lvlocale reset para voltar à detecção automática",
    LOCALE_INVALID = "Idioma inválido. Opções válidas:",
    LOCALE_RESET = "Idioma redefinido para detecção automática: %s",
    LOCALE_TITLE = "Localização do LiteVault",
    LOCALE_DETECTED = "Idioma detectado: %s",
    LOCALE_FORCED_TO = "Idioma forçado: %s",
    LOCALE_DEBUG_KEYS = "Chaves de depuração:",
    LOCALE_DEBUG_BORDERS = "Bordas de depuração:",
    LOCALE_ON = "LIGADO",
    LOCALE_OFF = "DESLIGADO",
    LOCALE_COMMANDS = "Comandos:",
    LOCALE_CMD_DEBUG = "/lvlocale debug - Alternar modo de exibição de chaves",
    LOCALE_CMD_BORDERS = "/lvlocale borders - Alternar visualização das bordas do texto",
    LOCALE_CMD_LANG = "/lvlocale lang XX - Forçar idioma (ex.: deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - Voltar para detecção automática",
    TITLE_INSTANCE_TRACKER = "Rastreador de inst?ncias",
    SECTION_INSTANCE_CAP = "Limite de inst?ncias (10/hora)",
    LABEL_CAP_CURRENT = "Atual: %d/10",
    LABEL_CAP_STATUS = "Status: %s",
    LABEL_NEXT_SLOT = "Próximo espaço em: %s",
    STATUS_SAFE = "SEGURO",
    STATUS_WARNING = "AVISO",
    STATUS_LOCKED = "BLOQUEADO",
    SECTION_CURRENT_RUN = "Corrida atual",
    LABEL_DURATION = "Duração: %s",
    LABEL_NOT_IN_INSTANCE = "Não está em uma instância",
    SECTION_PERFORMANCE = "Desempenho de hoje",
    LABEL_DUNGEONS_TODAY = "Masmorras: %d",
    LABEL_RAIDS_TODAY = "Raides: %d",
    LABEL_AVG_TIME = "Média: %s",
    SECTION_LEGACY_RAIDS = "Raides legadas nesta semana",
    LABEL_LEGACY_RUNS = "Corridas: %d",
    LABEL_GOLD_EARNED = "Ouro: %s",
    SECTION_RECENT_RUNS = "Corridas recentes",
    LABEL_NO_RECENT_RUNS = "Nenhuma corrida recente",
    SECTION_MPLUS = "Mítica+",
    LABEL_MPLUS_CURRENT_KEY = "Chave atual:",
    LABEL_RUNS_TODAY = "Corridas hoje: %d",
    LABEL_RUNS_THIS_WEEK = "Corridas nesta semana: %d",
    SECTION_RECENT_MPLUS_RUNS = "Corridas M+ recentes",
    LABEL_NO_RECENT_MPLUS_RUNS = "Nenhuma corrida M+ recente",
    BUTTON_DASHBOARD = "Painel",
    BUTTON_PROFIT = "Lucro",
    LABEL_PROFIT_GOALS = "Metas do Bando de Guerra",
    LABEL_WEEKLY_GOAL = "Meta semanal",
    LABEL_MONTHLY_GOAL = "Meta mensal",
    BUTTON_EDIT = "Editar",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "Maior lucro líquido desta redefinição.",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "Melhor lucro líquido do mês atual.",
    BUTTON_ACHIEVEMENTS = "Conquistas",
    TITLE_ACHIEVEMENTS = "Conquistas",
    DESC_ACHIEVEMENTS = "Escolha um rastreador de conquistas para ver o progresso detalhado.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "Caçador de Glifos da Meia-noite",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "Caçador de Glifos da Meia-noite",
    LABEL_REWARD = "Recompensa",
    DESC_GLYPH_REWARD = "Complete Caçador de Glifos da Meia-noite para ganhar esta montaria.",
    MSG_NO_ACHIEVEMENT_DATA = "Nenhum dado de rastreamento de conquistas disponível.",
    LABEL_CRITERIA = "Critérios",
    LABEL_GLYPHS_COLLECTED = "Glifos Coletados",
    LABEL_ACHIEVEMENT = "Conquista",
    BUTTON_BAGS = "Bolsas",
    BUTTON_BANK = "Banco",
    BUTTON_WARBAND_BANK = "Banco da Banda de Guerra",
    BAGS_EMPTY_STATE = "Nenhum item de bolsa salvo para este personagem ainda.",
    BANK_EMPTY_STATE = "Nenhum item de banco salvo para este personagem ainda.",
    WARBANK_EMPTY_STATE = "Nenhum item do banco da banda de guerra salvo ainda.",
    LABEL_BAG_SLOTS = "Espaços: %d / %d usados",
    LABEL_SCANNED = "verificado",
    ["Coffer Key Shards"] = "Fragmentos de Chave de Cofre",
    BUTTON_WEEKLY_PLANNER = "Planejador",
    TITLE_WEEKLY_PLANNER = "Planejador semanal",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "Planejador semanal",
    TOOLTIP_WEEKLY_PLANNER_DESC = "Lista semanal editável por personagem. Itens concluídos são reiniciados toda semana.",
    TOOLTIP_VAULT_STATUS = "Verificar status do cofre.",
    TITLE_GREAT_VAULT = "O Grande Cofre",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "Raide",
    LABEL_VAULT_ROW_DUNGEONS = "Masmorras",
    LABEL_VAULT_ROW_WORLD = "Mundo",
    LABEL_VAULT_SLOTS_UNLOCKED = "%d/9 espaços desbloqueados",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "Ainda não há dados de limite salvos.",
    MSG_VAULT_LIVE_ACTIVE = "Progresso ao vivo do Grande Cofre para o personagem ativo.",
    MSG_VAULT_LIVE = "Progresso ao vivo do Grande Cofre.",
    MSG_VAULT_SAVED = "Instant?neo salvo do Grande Cofre do ?ltimo login deste personagem.",
    SECTION_DELVE_CURRENCY = "Moeda de Imersão",
    SECTION_UPGRADE_CRESTS = "Brasões de aprimoramento",
    LABEL_CAP_SHORT = "limite %s",
    ["Glória do Escavador de Midnight"] = "Glória do Escavador de Midnight",
    ["Complete \"Glória do Escavador de Midnight\" para obter esta montaria."] = "Complete \"Glória do Escavador de Midnight\" para obter esta montaria.",
    ["Complete os cinco telescópios nesta zona."] = "Complete os cinco telescópios nesta zona.",
    ["Crimson Dragonhawk"] = "Falcodrago Carmesim",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Reward"] = "Recompensa",
    ["Critérios"] = "Critérios",
    ["Informações"] = "Informações",
    ["Unknown"] = "Desconhecido",
    ["Item"] = "Item",
    ["Click to set waypoint."] = "Clique para definir um waypoint.",
    ["Rastreador ainda não adicionado."] = "Rastreador ainda não adicionado.",
    ["Conclua a caverna aqui para receber crédito."] = "Conclua a caverna aqui para receber crédito.",
    ["Carregue a pedra rúnica com Arcana Latente para iniciar seu evento de defesa."] = "Carregue a pedra rúnica com Arcana Latente para iniciar seu evento de defesa.",
    ["Crédito de conquista obtido por:"] = "Crédito de conquista obtido por:",
    ["Ever-Painting"] = "Pintura Eterna",
    ["As entradas rastreadas de Ever-Painting ainda não foram adicionadas."] = "As entradas rastreadas de Ever-Painting ainda não foram adicionadas.",
    ["Corrida das Pedras Rúnicas"] = "Corrida das Pedras Rúnicas",
    ["As entradas rastreadas de Runestone Rush ainda não foram adicionadas."] = "As entradas rastreadas de Runestone Rush ainda não foram adicionadas.",
    ["Acompanhe os quatro convites de facção de A festa precisa continuar. x/y marcados."] = "Acompanhe os quatro convites de facção de A festa precisa continuar. x/y marcados.",
    ["As entradas rastreadas de A festa precisa continuar ainda não foram adicionadas."] = "As entradas rastreadas de A festa precisa continuar ainda não foram adicionadas.",
    ["Rastreadores de exploração"] = "Rastreadores de exploração",
    ["As entradas rastreadas de Explore Eversong Woods ainda não foram adicionadas."] = "As entradas rastreadas de Explore Eversong Woods ainda não foram adicionadas.",
    ["As entradas rastreadas de Explore Voidstorm ainda não foram adicionadas."] = "As entradas rastreadas de Explore Voidstorm ainda não foram adicionadas.",
    ["As entradas rastreadas de Explore Zul'Aman ainda não foram adicionadas."] = "As entradas rastreadas de Explore Zul'Aman ainda não foram adicionadas.",
    ["As entradas rastreadas de Explore Harandar ainda não foram adicionadas."] = "As entradas rastreadas de Explore Harandar ainda não foram adicionadas.",
    ["A emoção da perseguição"] = "A emoção da perseguição",
    ["Escape das garras da Presença Faminta em Voidstorm por pelo menos 60 segundos."] = "Escape das garras da Presença Faminta em Voidstorm por pelo menos 60 segundos.",
    ["Esta conquista não precisa de rastreamento de coordenadas no LiteVault. Sobreviva ao evento da Presença Faminta em Voidstorm por pelo menos 60 segundos."] = "Esta conquista não precisa de rastreamento de coordenadas no LiteVault. Sobreviva ao evento da Presença Faminta em Voidstorm por pelo menos 60 segundos.",
    ["As entradas rastreadas de A emoção da perseguição ainda não foram adicionadas."] = "As entradas rastreadas de A emoção da perseguição ainda não foram adicionadas.",
    ["Complete a missão mundial de Harandar 'Aplicação das Garras' com 15 ou mais acúmulos de Perseguição do Predador."] = "Complete a missão mundial de Harandar 'Aplicação das Garras' com 15 ou mais acúmulos de Perseguição do Predador.",
    ["Esta conquista não precisa de rastreamento de coordenadas no LiteVault. Complete a missão mundial de Harandar 'Aplicação das Garras' com 15 ou mais acúmulos de Perseguição do Predador."] = "Esta conquista não precisa de rastreamento de coordenadas no LiteVault. Complete a missão mundial de Harandar 'Aplicação das Garras' com 15 ou mais acúmulos de Perseguição do Predador.",
    ["As entradas rastreadas de Sem tempo para patas ainda não foram adicionadas."] = "As entradas rastreadas de Sem tempo para patas ainda não foram adicionadas.",
    ["Do berço ao túmulo"] = "Do berço ao túmulo",
    ["Tente voar até O Berço, bem alto no céu acima de Harandar."] = "Tente voar até O Berço, bem alto no céu acima de Harandar.",
    ["Voe até O Berço, bem alto no céu acima de Harandar, para completar esta conquista."] = "Voe até O Berço, bem alto no céu acima de Harandar, para completar esta conquista.",
    ["Esses diários só estão disponíveis durante a missão semanal 'Lendas dos Haranir'. Enquanto estiver em uma visão, procure o ícone de lupa no minimapa."] = "Esses diários só estão disponíveis durante a missão semanal 'Lendas dos Haranir'. Enquanto estiver em uma visão, procure o ícone de lupa no minimapa.",
    ["Recupere as entradas de diário dos Haranir listadas abaixo."] = "Recupere as entradas de diário dos Haranir listadas abaixo.",
    ["Recupere as entradas de diário dos Haranir listadas abaixo. x/y marcados."] = "Recupere as entradas de diário dos Haranir listadas abaixo. x/y marcados.",
    ["Isto está ligado à missão semanal 'Lendas dos Haranir'. Se você ainda não tiver progresso, estima-se que leve cerca de 7 semanas para concluir."] = "Isto está ligado à missão semanal 'Lendas dos Haranir'. Se você ainda não tiver progresso, estima-se que leve cerca de 7 semanas para concluir.",
    ["Os grupos de coordenadas ainda não foram adicionados."] = "Os grupos de coordenadas ainda não foram adicionados.",
    ["Este rastreador está dividido em 3 grupos de 40 coordenadas para manter as rotas das mariposas gerenciáveis."] = "Este rastreador está dividido em 3 grupos de 40 coordenadas para manter as rotas das mariposas gerenciáveis.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "As mariposas 41-80 aparecem com Renome Hara'ti 4, rastreamento no Renome 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "As mariposas 81-120 aparecem com Renome Hara'ti 9, rastreamento no Renome 11.",
    ["O roteamento do LiteVault assume que você já desbloqueou o Renome Hara'ti 11."] = "O roteamento do LiteVault assume que você já desbloqueou o Renome Hara'ti 11.",
    ["%s contém %d coordenadas de mariposas. Clique em uma mariposa para colocar um waypoint."] = "%s contém %d coordenadas de mariposas. Clique em uma mariposa para colocar um waypoint.",
    ["Group 1"] = "Grupo 1",
    ["Group 2"] = "Grupo 2",
    ["Group 3"] = "Grupo 3",
    ["Conclua as três ondas do Assalto a Stormarion. x/y marcados."] = "Conclua as três ondas do Assalto a Stormarion. x/y marcados.",
    ["As entradas rastreadas de Um problema singular ainda não foram adicionadas."] = "As entradas rastreadas de Um problema singular ainda não foram adicionadas.",
    ["Abundância: Plenitude próspera!"] = "Abundância: Plenitude próspera!",
    ["Você precisa concluir uma corrida de caverna Colheita Abundante em cada local para receber crédito. Apenas visitar a caverna não é suficiente."] = "Você precisa concluir uma corrida de caverna Colheita Abundante em cada local para receber crédito. Apenas visitar a caverna não é suficiente.",
    ["As entradas rastreadas de Abundância: Plenitude próspera! ainda não foram adicionadas."] = "As entradas rastreadas de Abundância: Plenitude próspera! ainda não foram adicionadas.",
    ["Altar das Bênçãos"] = "Altar das Bênçãos",
    ["Ative cada efeito de bênção listado para receber crédito."] = "Ative cada efeito de bênção listado para receber crédito.",
    ["Ative cada efeito de bênção listado. x/y marcados."] = "Ative cada efeito de bênção listado. x/y marcados.",
    ["Meta achievement summaries"] = "Resumos de meta-conquistas",
    ["Conclua as conquistas de Eversong Woods listadas abaixo. x/y concluídos."] = "Conclua as conquistas de Eversong Woods listadas abaixo. x/y concluídos.",
    ["Conclua todas as conquistas de Voidstorm listadas abaixo. x/y concluídos."] = "Conclua todas as conquistas de Voidstorm listadas abaixo. x/y concluídos.",
    ["Conclua todas as conquistas de Zul'Aman listadas abaixo. x/y concluídos."] = "Conclua todas as conquistas de Zul'Aman listadas abaixo. x/y concluídos.",
    ["Ajude os Hara'ti completando as conquistas abaixo. x/y concluídos."] = "Ajude os Hara'ti completando as conquistas abaixo. x/y concluídos.",
    ["Reúna suas forças contra Xal'atath completando as conquistas abaixo. x/y concluídos."] = "Reúna suas forças contra Xal'atath completando as conquistas abaixo. x/y concluídos.",
    ["As entradas rastreadas de Making an Amani Out of You ainda não foram adicionadas."] = "As entradas rastreadas de Making an Amani Out of You ainda não foram adicionadas.",
    ["As entradas rastreadas de That's Aln, Folks! ainda não foram adicionadas."] = "As entradas rastreadas de That's Aln, Folks! ainda não foram adicionadas.",
    ["As entradas rastreadas de Forever Song ainda não foram adicionadas."] = "As entradas rastreadas de Forever Song ainda não foram adicionadas.",
    ["As entradas rastreadas de Yelling into the Voidstorm ainda não foram adicionadas."] = "As entradas rastreadas de Yelling into the Voidstorm ainda não foram adicionadas.",
    ["As entradas rastreadas de Light Up the Night ainda não foram adicionadas."] = "As entradas rastreadas de Light Up the Night ainda não foram adicionadas.",
    ["Montaria: Asa-pétala brilhante"] = "Montaria: Asa-pétala brilhante",
    ["Decoração de Casa: Chamado de On'ohia"] = "Decoração de Casa: Chamado de On'ohia",
    ["Título: \"Senhor da Poeira\""] = "Título: \"Senhor da Poeira\"",
    ["Título: \"Cronista dos Haranir\""] = "Título: \"Cronista dos Haranir\"",
    ["Rótulos de recompensa da casa:"] = "Rótulos de recompensa da casa:",
}

L["Ressincronização da raide indisponível."] = "Ressincronização da raide indisponível."
L["As mensagens de tempo jogado serão ocultadas."] = "As mensagens de tempo jogado serão ocultadas."
L["Time played messages restored."] = "As mensagens de tempo jogado foram restauradas."
L["%dm %02ds"] = "%d min %02d s"
L["Brasões:"] = "Brasões:"
L["Mount Drops"] = "Montarias obtidas"
L["(Collected)"] = "(Coletada)"
L["(Não coletada)"] = "(Não coletada)"
L["Mounts: %d/%d"] = "Montarias: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Montarias: %d/%d"
L["The Voidspire"] = "A Agulha do Caos"
L["A Fenda Onírica"] = "A Fenda Onírica"
L["March of Quel'Danas"] = "A Marcha de Quel'Danas"
L["Raid Progression"] = "Progresso da raide"
L["Lady Liadrin Weekly"] = "Semanal da Lady Liadrin"
L["Registro de alterações"] = "Registro de alterações"
L["Back"] = "Voltar"
L["Warband Bank"] = "Banco do Bando de Guerra"
L["Treatise"] = "Tratado"
L["Artesão"] = "Artesão"
L["Recuperação"] = "Recuperação"
L["Resumo da atualização do LiteVault"] = "Resumo da atualização do LiteVault"
L["Vários elementos principais da interface foram atualizados, incluindo o ícone de moeda, o ícone de raide, a barra de profissões e o rastreador do Grande Cofre."] = "Vários elementos principais da interface foram atualizados, incluindo o ícone de moeda, o ícone de raide, a barra de profissões e o rastreador do Grande Cofre."
L["A exibição do nível de item do cofre foi atualizada para ficar mais próxima da apresentação padrão do Grande Cofre da Blizzard."] = "A exibição do nível de item do cofre foi atualizada para ficar mais próxima da apresentação padrão do Grande Cofre da Blizzard."
L["Um grande conjunto de novas traduções foi adicionado aos idiomas compatíveis."] = "Um grande conjunto de novas traduções foi adicionado aos idiomas compatíveis."
L["A exibição e a atualização do texto localizado foram melhoradas em todo o addon."] = "A exibição e a atualização do texto localizado foram melhoradas em todo o addon."
L["O suporte de localização para botões, abas de bolsas, texto semanal e outros rótulos da interface foi atualizado."] = "O suporte de localização para botões, abas de bolsas, texto semanal e outros rótulos da interface foi atualizado."
L["Vários problemas de layout relacionados à localização foram corrigidos."] = "Vários problemas de layout relacionados à localização foram corrigidos."
L["Vários problemas de travamento relacionados à localização foram corrigidos."] = "Vários problemas de travamento relacionados à localização foram corrigidos."

L["BUTTON_BREAKDOWN"] = "Detalhamento"
L["BUTTON_WARBAND_PROFIT_BREAKDOWN"] = "Detalhamento do Bando de Guerra"
L["BUTTON_RITUAL_SITES"] = "Locais de ritual"
L["Renome máximo"] = "Renome máximo"
L["LABEL_PARAGON"] = "Paragon"
L["LABEL_REWARD_FMT"] = "Recompensa: %s"
L["LABEL_REWARD_LOADING"] = "Carregando dados da recompensa..."
L["Clique para trocar para esta facção."] = "Clique para trocar para esta facção."
L["LABEL_GAINED"] = "Recebido"
L["LABEL_TOP_SOURCES"] = "Principais fontes"
L["LABEL_TOP_INCOME_SOURCE"] = "Principal fonte de renda"
L["LABEL_TOP_EXPENSE_SOURCE"] = "Principal fonte de gasto"
L["Composição das fontes de renda e gastos semanais do seu Bando de Guerra."] = "Composição das fontes de renda e gastos semanais do seu Bando de Guerra."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "Onde seu Bando de Guerra ganhou mais ouro nesta semana."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "Onde seu Bando de Guerra gastou mais ouro nesta semana."
L["MSG_PROFIT_NO_INCOME"] = "Nenhuma renda registrada ainda."
L["MSG_PROFIT_NO_SPENDING"] = "Nenhum gasto registrado ainda."
L["Nenhuma Missão Mundial de ouro ativa encontrada."] = "Nenhuma Missão Mundial de ouro ativa encontrada."
L["Missões Mundiais"] = "Missões Mundiais"
L["LEDGER_UPGRADE"] = "Aprimoramento"
L["Desativar marcadores de pedras rúnicas no mapa"] = "Desativar marcadores de pedras rúnicas no mapa"
L["Oculta os marcadores de pedras rúnicas do LiteVault no mapa da Floresta do Canto Eterno."] = "Oculta os marcadores de pedras rúnicas do LiteVault no mapa da Floresta do Canto Eterno."
L["Ativar destaques de lucro no calendário"] = "Ativar destaques de lucro no calendário"
L["Mostra destaques verdes e vermelhos para dias de lucro no calendário."] = "Mostra destaques verdes e vermelhos para dias de lucro no calendário."
L["Próxima semana: %s"] = "Próxima semana: %s"
L["LABEL_MONTHLY_PROFIT"] = "Lucro mensal"
L["LABEL_TOP_WEEKLY_EARNERS"] = "Maiores ganhos semanais"
L["LABEL_TOP_MONTHLY_EARNERS"] = "Maiores ganhos mensais"

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
L["TOOLTIP_FACTION_CARD_HINT"] = "Click to switch this faction."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "Source mix across your warband's weekly income and spending."
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No active gold world quests found."
L["LEDGER_WORLD_QUESTS"] = "World Quests"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "Disable Runestone Map Pins"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "Hide LiteVault's Fortify the Runestones pins on the Eversong Woods map."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "Enable Calendar Profit Highlights"
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"] = "Show green and red profit-day highlights on the calendar."
L["Void Strike"] = "Void Strike"
L["Void Assaults"] = "Void Assaults"
L["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods"
L["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman"
L["LABEL_NEXT_WEEK_FMT"] = "Next Week: %s"
L["Abundance Event"] = "Abundance Event"
L["Darkness Unmade"] = "Darkness Unmade"
L["Harvesting the Void"] = "Harvesting the Void"
L["Mining"] = "Mining"
L["Remnant of Anguish"] = "Remnant of Anguish"
L["Shard of Dundun"] = "Shard of Dundun"
L["Adventurer Dawncrest"] = "Adventurer Dawncrest"
L["Veteran Dawncrest"] = "Veteran Dawncrest"
L["Champion Dawncrest"] = "Champion Dawncrest"
L["Hero Dawncrest"] = "Hero Dawncrest"
L["Myth Dawncrest"] = "Myth Dawncrest"
L["Raid resync unavailable."] = "Raid resync unavailable."
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Crests:"] = "Crests:"
L["(Uncollected)"] = "(Uncollected)"
L["The Dreamrift"] = "The Dreamrift"
L["Change Log"] = "Change Log"
L["Artisan"] = "Artisan"
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
L["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."
L["Altar of Blessings: Sacred Buffet Devotee"] = "Altar of Blessings: Sacred Buffet Devotee"

-- Register this locale
lv.RegisterLocale("ptBR", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["ptBR"] = L
