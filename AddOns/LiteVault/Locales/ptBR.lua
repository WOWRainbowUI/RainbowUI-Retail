-- ptBR.lua - Brazilian Portuguese locale for LiteVault
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

    TOOLTIP_VAULT_TITLE = "Grande Câmara",
    TOOLTIP_VAULT_DESC = "Pressione para abrir a Grande Câmara",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Abrir a Grande Câmara.",
    TOOLTIP_VAULT_ALT_ONLY = "A Grande Câmara só pode ser aberta para o personagem ativo.",

    TOOLTIP_CURRENCY_TITLE = "Moedas do personagem",
    TOOLTIP_CURRENCY_DESC = "Clique para ver lista completa.",
    TOOLTIP_BAGS_TITLE = "Ver bolsas",
    TOOLTIP_BAGS_DESC = "Ver o conteúdo salvo das bolsas e bolsa de reagentes.",

    TOOLTIP_LEDGER_TITLE = "Livro de lucros semanal",
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
    BUTTON_LEDGER = "Livro",
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
    TITLE_WEEKLY_LEDGER = "%s - Livro semanal",
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
    MSG_LEDGER_NOT_AVAILABLE = "Livro não disponível.",
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
    ["Abundance Event"] = "Evento de Abundância",
    ["Legends of the Haranir"] = "Lendas dos Haranir",
    ["Stormarion Assault"] = "Investida de Stormarion",
    ["Darkness Unmade"] = "Escuridão Desfeita",
    ["Harvesting the Void"] = "Colhendo o Vácuo",
    ["Midnight: Saltheril's Soiree"] = "Meia-noite: sarau de Saltheril",
    ["Fortify the Runestones: Blood Knights"] = "Fortificar as pedras rúnicas: Cavaleiros Sangrentos",
    ["Fortify the Runestones: Shades of the Row"] = "Fortificar as pedras rúnicas: Sombras da Rua",
    ["Fortify the Runestones: Magisters"] = "Fortificar as pedras rúnicas: Magísteres",
    ["Fortify the Runestones: Farstriders"] = "Fortificar as pedras rúnicas: Andarilhos",
    ["Put a Little Snap in Their Step"] = "Dê mais impulso ao passo deles",
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
    ["Mining"] = "Mineração",
    ["Skinning"] = "Esfolamento",

    ["Remnant of Anguish"] = "Remanescente da Angústia",
    ["Shard of Dundun"] = "Estilhaço de Dundun",
    ["Adventurer Dawncrest"] = "Brasão da Aurora de aventureiro",
    ["Veteran Dawncrest"] = "Brasão da Aurora de veterano",
    ["Champion Dawncrest"] = "Brasão da Aurora de campeão",
    ["Hero Dawncrest"] = "Brasão da Aurora de herói",
    ["Myth Dawncrest"] = "Brasão da Aurora mítico",
    ["Brimming Arcana"] = "Arcana transbordante",
    ["Voidlight Marl"] = "Marga da Luz do Vazio",
    ["Undercoin"] = "Submoeda",
    ["Throw the Dice"] = "Jogue os dados",
    ["We Need a Refill"] = "Precisamos reabastecer",
    ["Lovely Plumage"] = "Plumagem adorável",
    ["The Cauldron of Echoes"] = "O caldeirão dos ecos",
    ["The Echoless Flame"] = "A chama sem eco",
    ["Hidey-Hole"] = "Esconderijo",
    ["Victorious Stormarion Pinnacle Cache"] = "Reserva do Pináculo de Stormarion Vitoriosa",
    ["Overflowing Abundant Satchel"] = "Bolsa transbordando de abundância",
    ["Avid Learner's Supply Pack"] = "Pacote de suprimentos do aprendiz ávido",
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
    BUTTON_INSTANCES = "Instâncias",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Rastreador de instâncias",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Acompanhar masmorras e raides",
    LABEL_RENOWN_PROGRESS = "Renome %d (%d/%d)",
    LABEL_RENOWN = "Renome",
    LABEL_RENOWN_LEVEL = "Nível",
    LABEL_RENOWN_UNAVAILABLE = "Renome indisponível",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "Nenhuma missão de facção configurada ainda.",
    BUTTON_KNOWLEDGE = "Conhecimento",
    WORLD_EVENT_SALTHERIL = "Sarau de Saltheril",
    WORLD_EVENT_ABUNDANCE = "Abundância",
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
    TIME_YESTERDAY = "Ontem %H:%M",
    MSG_CAP_WARNING = "Aviso de limite de instância! %d/10 instâncias nesta hora.",
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
    TITLE_INSTANCE_TRACKER = "Rastreador de instâncias",
    SECTION_INSTANCE_CAP = "Limite de instâncias (10/hora)",
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
    MSG_VAULT_SAVED = "Instantâneo salvo do Grande Cofre do último login deste personagem.",
    SECTION_DELVE_CURRENCY = "Moeda de Imersão",
    SECTION_UPGRADE_CRESTS = "Brasões de aprimoramento",
    LABEL_CAP_SHORT = "limite %s",
    ["Treasures of Midnight"] = "Tesouros de Midnight",
    ["Track the four Midnight treasure achievements and their rewards."] = "Acompanhe as quatro conquistas de tesouros de Midnight e suas recompensas.",
    ["Glory of the Midnight Delver"] = "Glória do Escavador de Midnight",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "Complete \"Glória do Escavador de Midnight\" para obter esta montaria.",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "Acompanhe as quatro conquistas de raros de Midnight e as recompensas dos raros da zona.",
    ["Track the four Midnight rare achievements."] = "Acompanhe as quatro conquistas de raros de Midnight.",
    ["Complete the five telescopes in this zone."] = "Complete os cinco telescópios nesta zona.",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "Complete as quatro conquistas de apoio do Escavador de Midnight para concluir esta meta-conquista.",
    ["Crimson Dragonhawk"] = "Falcodrago Carmesim",
    ["Giganto-Manis"] = "Giganto-Manis",
    ["Achievements"] = "Conquistas",
    ["Reward"] = "Recompensa",
    ["Details"] = "Detalhes",
    ["Criteria"] = "Critérios",
    ["Info"] = "Informações",
    ["Shared Loot"] = "Saque compartilhado",
    ["Groups"] = "Grupos",
    ["Back to Groups"] = "Voltar para Grupos",
    ["Back"] = "Voltar",
    ["Unknown"] = "Desconhecido",
    ["Item"] = "Item",
    ["No achievement reward listed."] = "Nenhuma recompensa de conquista listada.",
    ["Click to set waypoint."] = "Clique para definir um waypoint.",
    ["Click to open this tracker."] = "Clique para abrir este rastreador.",
    ["Tracker not added yet."] = "Rastreador ainda não adicionado.",
    ["Coordinates pending."] = "Coordenadas pendentes.",
    ["Complete the cave run here for credit."] = "Conclua a caverna aqui para receber crédito.",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "Carregue a pedra rúnica com Arcana Latente para iniciar seu evento de defesa.",
    ["Achievement credit from:"] = "Crédito de conquista obtido por:",
    ["Stormarion Assault"] = "Assalto a Stormarion",
    ["Ever-Painting"] = "Pintura Eterna",
    ["Track the known Ever-Painting canvases. x/y marked."] = "Acompanhe as telas conhecidas de Ever-Painting. x/y marcados.",
    ["Tracked entries for Ever-Painting have not been added yet."] = "As entradas rastreadas de Ever-Painting ainda não foram adicionadas.",
    ["Runestone Rush"] = "Corrida das Pedras Rúnicas",
    ["Track the known Runestone Rush entries. x/y marked."] = "Acompanhe as entradas conhecidas de Runestone Rush. x/y marcados.",
    ["Tracked entries for Runestone Rush have not been added yet."] = "As entradas rastreadas de Runestone Rush ainda não foram adicionadas.",
    ["The Party Must Go On"] = "A festa precisa continuar",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "Acompanhe os quatro convites de facção de A festa precisa continuar. x/y marcados.",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "As entradas rastreadas de A festa precisa continuar ainda não foram adicionadas.",
    ["Explore trackers"] = "Rastreadores de exploração",
    ["Track Explore Eversong Woods progress. x/y marked."] = "Acompanhe o progresso de Explore Eversong Woods. x/y marcados.",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "As entradas rastreadas de Explore Eversong Woods ainda não foram adicionadas.",
    ["Track Explore Voidstorm progress. x/y marked."] = "Acompanhe o progresso de Explore Voidstorm. x/y marcados.",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "As entradas rastreadas de Explore Voidstorm ainda não foram adicionadas.",
    ["Track Explore Zul'Aman progress. x/y marked."] = "Acompanhe o progresso de Explore Zul'Aman. x/y marcados.",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "As entradas rastreadas de Explore Zul'Aman ainda não foram adicionadas.",
    ["Track Explore Harandar progress. x/y marked."] = "Acompanhe o progresso de Explore Harandar. x/y marcados.",
    ["Tracked entries for Explore Harandar have not been added yet."] = "As entradas rastreadas de Explore Harandar ainda não foram adicionadas.",
    ["Thrill of the Chase"] = "A emoção da perseguição",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "Escape das garras da Presença Faminta em Voidstorm por pelo menos 60 segundos.",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "Esta conquista não precisa de rastreamento de coordenadas no LiteVault. Sobreviva ao evento da Presença Faminta em Voidstorm por pelo menos 60 segundos.",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "As entradas rastreadas de A emoção da perseguição ainda não foram adicionadas.",
    ["No Time to Paws"] = "Sem tempo para patas",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "Complete a missão mundial de Harandar 'Aplicação das Garras' com 15 ou mais acúmulos de Perseguição do Predador.",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "Esta conquista não precisa de rastreamento de coordenadas no LiteVault. Complete a missão mundial de Harandar 'Aplicação das Garras' com 15 ou mais acúmulos de Perseguição do Predador.",
    ["Tracked entries for No Time to Paws have not been added yet."] = "As entradas rastreadas de Sem tempo para patas ainda não foram adicionadas.",
    ["From The Cradle to the Grave"] = "Do berço ao túmulo",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "Tente voar até O Berço, bem alto no céu acima de Harandar.",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "Voe até O Berço, bem alto no céu acima de Harandar, para completar esta conquista.",
    ["Chronicler of the Haranir"] = "Cronista dos Haranir",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "Esses diários só estão disponíveis durante a missão semanal vinculada à conta 'Lendas dos Haranir'. Enquanto estiver em uma visão, procure o ícone de lupa no minimapa.",
    ["Recover the Haranir journal entries listed below."] = "Recupere as entradas de diário dos Haranir listadas abaixo.",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "Recupere as entradas de diário dos Haranir listadas abaixo. x/y marcados.",
    ["Legends Never Die"] = "Lendas nunca morrem",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "Isto está ligado à missão semanal vinculada à conta 'Lendas dos Haranir'. Se você ainda não tiver progresso, estima-se que leve cerca de 7 semanas para concluir.",
    ["Defend each Haranir legend location listed below."] = "Defenda cada local de lenda dos Haranir listado abaixo.",
    ["Protect each Haranir legend location listed below. x/y marked."] = "Proteja cada local de lenda dos Haranir listado abaixo. x/y marcados.",
    ["Dust 'Em Off"] = "Tire a poeira deles",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "Encontre todas as Mariposas Brilhantes escondidas em Harandar. x/y encontrados.",
    ["Coordinate groups have not been added yet."] = "Os grupos de coordenadas ainda não foram adicionados.",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "Este rastreador está dividido em 3 grupos de 40 coordenadas para manter as rotas das mariposas gerenciáveis.",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "As mariposas 1-40 aparecem com Renome Hara'ti 1, rastreamento no Renome 2.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "As mariposas 41-80 aparecem com Renome Hara'ti 4, rastreamento no Renome 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "As mariposas 81-120 aparecem com Renome Hara'ti 9, rastreamento no Renome 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "O roteamento do LiteVault assume que você já desbloqueou o Renome Hara'ti 11.",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s contém %d coordenadas de mariposas. Clique em uma mariposa para colocar um waypoint.",
    ["Group 1"] = "Grupo 1",
    ["Group 2"] = "Grupo 2",
    ["Group 3"] = "Grupo 3",
    ["Moths"] = "Mariposas",
    ["A Singular Problem"] = "Um problema singular",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "Conclua as três ondas do Assalto a Stormarion. x/y marcados.",
    ["Tracked entries for A Singular Problem have not been added yet."] = "As entradas rastreadas de Um problema singular ainda não foram adicionadas.",
    ["Abundance: Prosperous Plentitude!"] = "Abundância: Plenitude próspera!",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "Conclua uma corrida de caverna Colheita Abundante em cada local. x/y marcados.",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "Você precisa concluir uma corrida de caverna Colheita Abundante em cada local para receber crédito. Apenas visitar a caverna não é suficiente.",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "As entradas rastreadas de Abundância: Plenitude próspera! ainda não foram adicionadas.",
    ["Altar of Blessings"] = "Altar das Bênçãos",
    ["Trigger each listed blessing effect for credit."] = "Ative cada efeito de bênção listado para receber crédito.",
    ["Trigger each listed blessing effect. x/y marked."] = "Ative cada efeito de bênção listado. x/y marcados.",
    ["Meta achievement summaries"] = "Resumos de meta-conquistas",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "Conclua as conquistas de Eversong Woods listadas abaixo. x/y concluídos.",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "Conclua todas as conquistas de Voidstorm listadas abaixo. x/y concluídos.",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "Conclua todas as conquistas de Zul'Aman listadas abaixo. x/y concluídos.",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "Ajude os Hara'ti completando as conquistas abaixo. x/y concluídos.",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "Reúna suas forças contra Xal'atath completando as conquistas abaixo. x/y concluídos.",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "As entradas rastreadas de Making an Amani Out of You ainda não foram adicionadas.",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "As entradas rastreadas de That's Aln, Folks! ainda não foram adicionadas.",
    ["Tracked entries for Forever Song have not been added yet."] = "As entradas rastreadas de Forever Song ainda não foram adicionadas.",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "As entradas rastreadas de Yelling into the Voidstorm ainda não foram adicionadas.",
    ["Tracked entries for Light Up the Night have not been added yet."] = "As entradas rastreadas de Light Up the Night ainda não foram adicionadas.",
    ["Mount: Brilliant Petalwing"] = "Montaria: Asa-pétala brilhante",
    ["Housing Decor: On'ohia's Call"] = "Decoração de Casa: Chamado de On'ohia",
    ["Title: \"Dustlord\""] = "Título: \"Senhor da Poeira\"",
    ["Title: \"Chronicler of the Haranir\""] = "Título: \"Cronista dos Haranir\"",
    ["home reward labels:"] = "Rótulos de recompensa da casa:",
}

L["Raid resync unavailable."] = "Ressincronização da raide indisponível."
L["Time played messages will be suppressed."] = "As mensagens de tempo jogado serão ocultadas."
L["Time played messages restored."] = "As mensagens de tempo jogado foram restauradas."
L["%dm %02ds"] = "%d min %02d s"
L["Crests:"] = "Brasões:"
L["Mount Drops"] = "Montarias obtidas"
L["(Collected)"] = "(Coletada)"
L["(Uncollected)"] = "(Não coletada)"
L["Mounts: %d/%d"] = "Montarias: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Montarias: %d/%d"
L["The Voidspire"] = "A Agulha do Caos"
L["The Dreamrift"] = "A Fenda Onírica"
L["March of Quel'Danas"] = "A Marcha de Quel'Danas"
L["Raid Progression"] = "Progresso da raide"
L["Lady Liadrin Weekly"] = "Semanal da Lady Liadrin"
L["Change Log"] = "Registro de alterações"
L["Back"] = "Voltar"
L["Warband Bank"] = "Banco do Bando de Guerra"
L["Treatise"] = "Tratado"
L["Artisan"] = "Artesão"
L["Catch-up"] = "Recuperação"
L["LiteVault Update Summary"] = "Resumo da atualização do LiteVault"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Vários elementos principais da interface foram atualizados, incluindo o ícone de moeda, o ícone de raide, a barra de profissões e o rastreador do Grande Cofre."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "A exibição do nível de item do cofre foi atualizada para ficar mais próxima da apresentação padrão do Grande Cofre da Blizzard."
L["Added a large batch of new translations across supported locales."] = "Um grande conjunto de novas traduções foi adicionado aos idiomas compatíveis."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "A exibição e a atualização do texto localizado foram melhoradas em todo o addon."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "O suporte de localização para botões, abas de bolsas, texto semanal e outros rótulos da interface foi atualizado."
L["Fixed multiple localization-related layout issues."] = "Vários problemas de layout relacionados à localização foram corrigidos."
L["Fixed several localization-related crash issues."] = "Vários problemas de travamento relacionados à localização foram corrigidos."

-- Register this locale
lv.RegisterLocale("ptBR", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["ptBR"] = L




