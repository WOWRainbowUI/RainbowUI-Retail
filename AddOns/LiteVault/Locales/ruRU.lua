-- ruRU.lua - Russian locale for LiteVault
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
    BUTTON_CLOSE = "Закрыть",
    BUTTON_YES = "Да",
    BUTTON_NO = "Нет",
    BUTTON_MANAGE = "Управление",
    BUTTON_BACK = "Назад",
    BUTTON_ALL = "Все",
    BUTTON_NONE = "Ничего",
    BUTTON_FILTER = "Фильтр",
    DIALOG_DELETE_CHAR = "Удалить %s из LiteVault?",
    LABEL_MYTHIC_PLUS = "M+",
    BUTTON_ACTIONS = "Действия",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "Фильтры карты",

    BUTTON_RAID_LOCKOUTS = "Блокировки рейдов",
    BUTTON_WORLD_EVENTS = "Мировые события",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "Блокировки рейдов",
    TOOLTIP_RAID_LOCKOUTS_DESC = "Просмотр убитых боссов всех персонажей",
    TOOLTIP_THEME_TITLE = "Переключить тему",
    TOOLTIP_THEME_DESC = "Переключение между тёмной и светлой темой",
    TOOLTIP_FILTER_TITLE = "Фильтр карты",
    TOOLTIP_FILTER_DESC = "Нажмите для полного списка",
    TOOLTIP_WORLD_EVENTS_TITLE = "Мировые события",
    TOOLTIP_WORLD_EVENTS_DESC = "Просмотр мировых событий",

    -- Sort controls
    LABEL_SORT_BY = "Сорт.:",
    SORT_GOLD = "Золото",
    SORT_ILVL = "Ур. пр.",
    SORT_MPLUS = "М+",
    SORT_LAST_ACTIVE = "Актив.",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "Еженедельные задания %s",
    BUTTON_WEEKLIES = "Неделя",
    BUTTON_EVENTS = "События",
    BUTTON_FACTIONS = "Фракции",
    BUTTON_AMANI_TRIBE = "Племя Амани",
    BUTTON_HARATI = "Хара'ти",
    BUTTON_SINGULARITY = "Сингулярность",
    BUTTON_SILVERMOON_COURT = "Двор Сребролуния",
    WARNING_EVENT_QUESTS = "Некоторые из этих событий могут быть сломаны или недоступны в игре.",
    WARNING_WEEKLY_HARATI_CHOICE = "Внимание! Выбранное задание «Легенды Харанир» блокируется для всей учётной записи.",
    WARNING_WEEKLY_RUNESTONES = "Внимание! Выбирайте задание с руническими камнями с умом. Как только вы выберете одно на эту неделю, выбор закрепится за всей учетной записью.",
    LABEL_WEEKLY_PROFIT = "Недельная прибыль:",
    LABEL_WARBAND_PROFIT = "Прибыль отряда:",
    LABEL_WARBAND_BANK = "Банк отряда:",
    LABEL_TOP_EARNERS = "Лучшие заработки (Неделя):",
    LABEL_TOTAL_GOLD = "Всего золота: %s",
    LABEL_TOTAL_TIME = "Общее время: %s",
    LABEL_COMBINED_TIME = "Суммарное время: %dд %dч",

    TOOLTIP_TOTAL_TIME_TITLE = "Общее время",
    TOOLTIP_TOTAL_TIME_DESC = "Общее время игры всех отслеживаемых персонажей.",
    TOOLTIP_TOTAL_TIME_CLICK = "Нажмите для смены формата.",

    -- Quest status
    STATUS_DONE = "[Выполнено]",
    STATUS_IN_PROGRESS = "[В процессе]",
    STATUS_NOT_STARTED = "[Не начато]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "Управление персонажами",
    TOOLTIP_MANAGE_BACK = "Вернуться на главную вкладку.",
    TOOLTIP_MANAGE_VIEW = "Показать игнорируемых персонажей.",

    TOOLTIP_CATALYST_TITLE = "Заряды катализатора",
    TOOLTIP_SPARKS_TITLE = "Искры ремесла",

    TOOLTIP_VAULT_TITLE = "Великое Хранилище",
    TOOLTIP_VAULT_DESC = "Нажмите чтобы открыть великое хранилище",
    TOOLTIP_VAULT_ACTIVE_ONLY = "Открыть Великое Хранилище.",
    TOOLTIP_VAULT_ALT_ONLY = "Великое Хранилище можно открыть только для активного персонажа.",

    TOOLTIP_CURRENCY_TITLE = "Валюты персонажа",
    TOOLTIP_CURRENCY_DESC = "Нажмите для полного списка.",
    TOOLTIP_BAGS_TITLE = "Просмотр сумок",
    TOOLTIP_BAGS_DESC = "Просмотр сохранённого содержимого сумок и сумки реагентов.",

    TOOLTIP_LEDGER_TITLE = "Недельный журнал прибыли",
    TOOLTIP_LEDGER_DESC = "Отслеживание доходов и расходов золота по источникам.",

    TOOLTIP_WARBAND_BANK_TITLE = "Журнал банка отряда",
    TOOLTIP_WARBAND_BANK_DESC = "Нажмите для просмотра транзакций.",

    TOOLTIP_RESTORE_TITLE = "Восстановить",
    TOOLTIP_RESTORE_DESC = "Восстановить этого персонажа на главную страницу",

    TOOLTIP_IGNORE_TITLE = "Игнорировать",
    TOOLTIP_IGNORE_DESC = "Убрать этого персонажа с главной страницы",

    TOOLTIP_DELETE_TITLE = "Удалить",
    TOOLTIP_DELETE_DESC = "Навсегда удалить данные этого персонажа",
    TOOLTIP_DELETE_WARNING = "Внимание: Это действие нельзя отменить!",

    TOOLTIP_FAVORITE_TITLE = "Избранное",
    TOOLTIP_FAVORITE_DESC = "Закрепить этого персонажа вверху списка",

    -- Character data displays
    LABEL_ILVL = "Ур. пр.: %d",
    LABEL_MPLUS_SCORE = "Рейтинг М+: %d",
    LABEL_NO_KEY = "Нет ключа М+",
    LABEL_NO_PROFESSIONS = "Нет профессий",
    LABEL_UNKNOWN = "Неизвестно",
    LABEL_SKILL_LEVEL = "Навык: %d/%d",
    LABEL_CONCENTRATION = "Концентрация: %d/%d",
    LABEL_CONC_DAILY_RESET = "Ежедневно: %dч %dм",
    LABEL_CONC_WEEKLY_RESET = "Полный сброс: %dд %dч",
    LABEL_CONC_FULL = "(Полная)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d Знаний доступно",
    LABEL_NO_KNOWLEDGE = "Нет доступных знаний",
    LABEL_VAULT_PROGRESS = "Р: %d/3    М+: %d/3    М: %d/3",
    BUTTON_LEDGER = "Журнал",
    BUTTON_PROFS = "Проф.",

    TOOLTIP_PROFS_TITLE = "Профессии",
    TOOLTIP_PROFS_DESC = "Просмотр концентрации и знаний",
    TITLE_PROFESSIONS = "Профессии %s",
    TITLE_KNOWLEDGE_SOURCES = "Источники знаний",
    TAB_TREASURES = "Сокровища",
    LABEL_UNIQUE_TREASURES = "Уникальные сокровища",
    LABEL_WEEKLY_TREASURES = "Еженедельные сокровища",
    LABEL_HOVER_TREASURE_CHECKLIST = "Наведите, чтобы увидеть список сокровищ",
    TITLE_PROF_TREASURES_FMT = "Сокровища: %s",
    LABEL_PROFESSION = "Профессия",
    LABEL_UNIQUE_TREASURE_FMT = "Уникальное сокровище %s %d",
    LABEL_WEEKLY_TREASURE_FMT = "Еженедельное сокровище %s %d",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "Вс",
    DAY_MON = "Пн",
    DAY_TUE = "Вт",
    DAY_WED = "Ср",
    DAY_THU = "Чт",
    DAY_FRI = "Пт",
    DAY_SAT = "Сб",

    TOOLTIP_ACTIVITY_FOR = "Активность за %d.%d.%d",
    MSG_NO_WORLD_EVENTS = "Нет мировых событий в этом месяце",

    -- Filter categories
    FILTER_TIMEWALKING = "Путешествие во времени",
    FILTER_DARKMOON = "Ярмарка Новолуния",
    FILTER_DUNGEONS = "Подземелья",
    FILTER_PVP = "Игрок против игрока",
    FILTER_BONUS = "Бонус",

    -- World events
    WORLD_EVENT_LOVE = "Любовь витает в воздухе",
    WORLD_EVENT_LUNAR = "Лунный фестиваль",
    WORLD_EVENT_NOBLEGARDEN = "Сад чудес",
    WORLD_EVENT_CHILDREN = "Детская неделя",
    WORLD_EVENT_MIDSUMMER = "Огненный солнцеворот",
    WORLD_EVENT_BREWFEST = "Хмельной фестиваль",
    WORLD_EVENT_HALLOWS = "Тыквовин",
    WORLD_EVENT_WINTERVEIL = "Зимний Покров",
    WORLD_EVENT_DEAD = "День мёртвых",
    WORLD_EVENT_PIRATES = "День пирата",
    WORLD_EVENT_STYLE = "Испытание стилем",
    WORLD_EVENT_OUTLAND = "Кубок Запределья",
    WORLD_EVENT_NORTHREND = "Кубок Нордскола",
    WORLD_EVENT_KALIMDOR = "Кубок Калимдора",
    WORLD_EVENT_EASTERN = "Кубок Восточных королевств",
    WORLD_EVENT_WINDS = "Ветра таинственной удачи",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "Валюты %s",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_LOCKOUTS_WINDOW = "Блокировки рейдов",
    TITLE_RAID_FORMAT = "%s %s %s - Манакузня Омега",

    BUTTON_PROGRESSION = "Прогресс",
    BUTTON_LOCKOUTS = "Блокировки",

    DIFFICULTY_NORMAL = "Обычный",
    DIFFICULTY_HEROIC = "Героический",
    DIFFICULTY_MYTHIC = "Эпохальный",

    TOOLTIP_VIEW_LOCKOUTS = "Показано: Блокировки (эта неделя)",
    TOOLTIP_VIEW_LOCKOUTS_SWITCH = "Нажмите для просмотра Прогресса (лучший результат)",
    TOOLTIP_VIEW_PROGRESSION = "Показано: Прогресс (лучший результат)",
    TOOLTIP_VIEW_PROGRESSION_SWITCH = "Нажмите для просмотра Блокировок (эта неделя)",

    MSG_NO_CHAR_DATA = "Данные персонажа не найдены",
    MSG_NO_PROGRESSION = "Нет записанного прогресса %s",
    MSG_NO_LOCKOUT = "Нет блокировки %s на этой неделе",

    LABEL_BOSS = "Босс %d",
    LABEL_PROGRESS_COUNT = "%d/8",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "Журнал банка отряда",
    LABEL_CURRENT_BALANCE = "Текущий баланс:",
    LABEL_RECENT_TRANSACTIONS = "Последние транзакции:",
    MSG_NO_TRANSACTIONS = "(Транзакции ещё не записаны)",
    TIP_RELOAD_SAVE = "Совет: /reload перед сменой персонажа для сохранения",
    ACTION_DEPOSITED = "внёс",
    ACTION_WITHDREW = "снял",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    TITLE_WEEKLY_LEDGER = "%s - Недельный журнал",
    LABEL_RESETS_IN = "Сброс через %dд %dч",

    TAB_SUMMARY = "Сводка",
    TAB_HISTORY = "История",
    TAB_WARBAND = "Отряд",
    HEADER_SOURCE = "Источник",
    HEADER_INCOME = "Доход",
    HEADER_EXPENSE = "Расход",

    LABEL_TOTAL = "Всего",
    LABEL_NET_PROFIT = "Чистая прибыль",
    MSG_NO_GOLD_ACTIVITY = "Нет активности золота на этой неделе",
    MSG_NO_TRANSACTIONS_WEEK = "Нет транзакций на этой неделе",

    -- Ledger source categories
    LEDGER_QUESTS = "Задания",
    LEDGER_AUCTION = "Аукцион",
    LEDGER_TRADE = "Торговля",
    LEDGER_VENDOR = "Торговец",
    LEDGER_REPAIRS = "Ремонт",
    LEDGER_TRANSMOG = "Трансмогрификация",
    LEDGER_FLIGHT = "Маршруты полётов",
    LEDGER_CRAFTING = "Ремесло",
    LEDGER_CACHE = "Сундук/Тайник",
    LEDGER_MAIL = "Почта",
    LEDGER_LOOT = "Добыча",
    LEDGER_WARBAND_BANK = "Банк отряда",
    LEDGER_OTHER = "Прочее",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "Никогда",
    FRESH_TODAY = "Активен сегодня",
    FRESH_1_DAY = "1 день назад",
    FRESH_DAYS = "%d дней назад",

    -- Time format styles
    TIME_YEARS_DAYS = "%dл %dд",
    TIME_DAYS_HOURS = "%dд %dч",
    TIME_DAYS = "%s Дней",
    TIME_HOURS = "%s Часов",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "Приветствую, %s!\nХотите, чтобы LiteVault отслеживал этого персонажа?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "Обнаружен еженедельный сброс! Блокировки рейдов очищены.",
    MSG_ALREADY_TRACKED = "Этот персонаж уже отслеживается.",
    MSG_CHAR_ADDED = "%s добавлен в отслеживание.",
    MSG_LEDGER_NOT_AVAILABLE = "Журнал недоступен.",
    MSG_RAID_RESET_SEASON = "Прогресс рейда сброшен для Midnight Сезон 1!",
    MSG_CLEARED_PROGRESSION = "Данные прогресса очищены для %d персонажей.",
    MSG_WEEKLY_PROFIT_RESET = "Отслеживание недельной прибыли сброшено для %d персонажей.",
    MSG_WARBAND_BALANCE = "Отряд: %s",
    MSG_WARBAND_BANK_BALANCE = "Банк отряда: %s",
    MSG_WEEKLY_DATA_RESET = "Недельные данные сброшены для %d персонажей.",
    MSG_RAID_MANUAL_RESET = "Прогресс рейда сброшен вручную!",
    MSG_CLEARED_DATA = "Данные очищены для %d персонажей.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "Начальное сообщение Blizzard о времени игры не может быть скрыто.",

    -- Slash command help
    HELP_RESET_TITLE = "Команды сброса LiteVault",
    HELP_REGION = "Регион: %s (сброс %s)",
    HELP_LAST_SEASON = "Последний сброс сезона: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - Сбросить отслеживание недельной прибыли",
    HELP_RESET_SEASON = "/lvreset season - Сбросить прогресс рейда (новый уровень)",
    HELP_NEVER = "Никогда",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "Язык",
    TOOLTIP_LANGUAGE_TITLE = "Язык",
    TOOLTIP_LANGUAGE_DESC = "Изменить язык интерфейса",
    TITLE_LANGUAGE_SELECT = "Выбор языка",
    LANG_AUTO = "Авто (определить)",
    MSG_LANGUAGE_CHANGED = "Язык изменён. Перезагрузите интерфейс для применения всех изменений.",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "Настройки",
    TOOLTIP_OPTIONS_TITLE = "Настройки",
    TOOLTIP_OPTIONS_DESC = "Настроить параметры LiteVault",
    TITLE_OPTIONS = "Настройки LiteVault",
    OPTION_DISABLE_TIMEPLAYED = "Отключить отслеживание времени игры",
    OPTION_DISABLE_TIMEPLAYED_DESC = "Предотвращает появление сообщений /played в чате",
    OPTION_DARK_MODE = "Тёмный режим",
    OPTION_DARK_MODE_DESC = "Переключение между тёмной и светлой темами",
    OPTION_DISABLE_BAG_VIEWING = "Отключить просмотр сумок/банка",
    OPTION_DISABLE_BAG_VIEWING_DESC = "Скрывает кнопку Сумок и отключает просмотр сохранённых сумок, банка и банка отряда.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "Отключить систему оверлея",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "Скрывает оверлеи уровня предметов и замков LiteVault на снаряжении персонажа и при инспектировании.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "Отключить телепорты M+",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "Скрывает значок телепорта M+ и отключает панель телепортов LiteVault.",

    -- Month names
    MONTH_1 = "Январь",
    MONTH_2 = "Февраль",
    MONTH_3 = "Март",
    MONTH_4 = "Апрель",
    MONTH_5 = "Май",
    MONTH_6 = "Июнь",
    MONTH_7 = "Июль",
    MONTH_8 = "Август",
    MONTH_9 = "Сентябрь",
    MONTH_10 = "Октябрь",
    MONTH_11 = "Ноябрь",
    MONTH_12 = "Декабрь",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["Voidlight Marl"] = "Мергель светопустоты",
    ["Shard of Dundun"] = "Осколок Дун-Дуна",
    ["Brimming Arcana"] = "Переполненная аркана",
    ["Remnant of Anguish"] = "Осколок боли",
    ["Adventurer Dawncrest"] = "Рассветный гребень искателя",
    ["Veteran Dawncrest"] = "Гребень Рассвета ветерана",
    ["Champion Dawncrest"] = "Гребень Рассвета защитника",
    ["Hero Dawncrest"] = "Гребень Рассвета героя",
    ["Myth Dawncrest"] = "Гребень Рассвета мифа",
    ["Dawnlight Manaflux"] = "Манапоток рассвета",

    -- ==========================================================================
    -- WEEKLY QUESTS (Midnight)
    -- ==========================================================================
    ["Community Engagement"] = "Участие сообщества",
    WARNING_ACCOUNT_BOUND = "Привязано к учетной записи",
    ["Midnight: Prey"] = "Полночь: Добыча",
    ["Saltheril's Soiree"] = "Суаре Сальтериля",
    ["Abundance Event"] = "Событие изобилия",
    ["Legends of the Haranir"] = "Легенды хараниров",
    ["Stormarion Assault"] = "Штурм Стормариона",
    ["Darkness Unmade"] = "Развеянная тьма",
    ["Harvesting the Void"] = "Сбор пустоты",
    ["Midnight: Saltheril's Soiree"] = "Полночь: Суаре Сальтериля",
    ["Fortify the Runestones: Blood Knights"] = "Укрепление рунных камней: рыцари крови",
    ["Fortify the Runestones: Shades of the Row"] = "Укрепление рунных камней: тени улиц",
    ["Fortify the Runestones: Magisters"] = "Укрепление рунных камней: магистры",
    ["Fortify the Runestones: Farstriders"] = "Укрепление рунных камней: Следопыты",
    ["Put a Little Snap in Their Step"] = "Добавь им прыти",
    ["Light Snacks"] = "Легкие закуски",
    ["Less Lawless"] = "Меньше беззакония",
    ["The Subtle Game"] = "Тонкая игра",
    ["Courting Success"] = "Успех в ухаживании",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["Alchemy"] = "Алхимия",
    ["Blacksmithing"] = "Кузнечное дело",
    ["Enchanting"] = "Наложение чар",
    ["Engineering"] = "Инженерное дело",
    ["Inscription"] = "Начертание",
    ["Jewelcrafting"] = "Ювелирное дело",
    ["Leatherworking"] = "Кожевничество",
    ["Tailoring"] = "Портняжное дело",
    ["Herbalism"] = "Травничество",
    ["Mining"] = "Горное дело",
    ["Skinning"] = "Снятие шкур",
    TITLE_FACTION_WEEKLIES = "Еженедельные задания фракций %s",
    ["Undercoin"] = "Подземная монета",
    ["Throw the Dice"] = "Бросить кости",
    ["We Need a Refill"] = "Нужно пополнить запасы",
    ["Lovely Plumage"] = "Прелестное оперение",
    ["The Cauldron of Echoes"] = "Котёл эха",
    ["The Echoless Flame"] = "Безэховое пламя",
    ["Hidey-Hole"] = "Укрытие",
    ["Victorious Stormarion Pinnacle Cache"] = "Тайник победителя: Пик Штормариона",
    ["Overflowing Abundant Satchel"] = "Переполненная сумка изобилия",
    ["Avid Learner's Supply Pack"] = "Набор припасов усердного ученика",
    ["Surplus Bag of Party Favors"] = "Лишний мешок с праздничными подарками",
    OPTION_ENABLE_24HR_CLOCK = "Включить 24-часовой формат",
    OPTION_ENABLE_24HR_CLOCK_DESC = "Переключение между 24- и 12-часовым форматом",
    TELEPORT_PANEL_TITLE = "M+ телепорты",
    TELEPORT_CAST_BTN = "Телепорт",
    TELEPORT_ERR_COMBAT = "Нельзя телепортироваться в бою.",
    BUTTON_VAULT = "Хранилище",
    BUTTON_RAIDS = "Рейды",
    BUTTON_FAVORITE = "Избранное",
    BUTTON_UNFAVORITE = "Убрать из избранного",
    BUTTON_IGNORE = "Игнорировать",
    BUTTON_RESTORE = "Восстановить",
    BUTTON_DELETE = "Удалить",
    TOOLTIP_ACTIONS_TITLE = "Действия персонажа",
    TOOLTIP_ACTIONS_DESC = "Открыть меню действий",
    BUTTON_INSTANCES = "Инстансы",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "Отслеживание инстансов",
    TOOLTIP_INSTANCE_TRACKER_DESC = "Отслеживать забеги в подземелья и рейды",
    LABEL_RENOWN_PROGRESS = "Известность %d (%d/%d)",
    LABEL_RENOWN = "Репутация",
    LABEL_RENOWN_LEVEL = "Уровень",
    LABEL_RENOWN_UNAVAILABLE = "Известность недоступна",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "Задания фракций пока не настроены.",
    BUTTON_KNOWLEDGE = "Знания",
    WORLD_EVENT_SALTHERIL = "Вечер Салтерила",
    WORLD_EVENT_ABUNDANCE = "Изобилие",
    WORLD_EVENT_HARANIR = "Легенды Харанир",
    WORLD_EVENT_STORMARION = "Штурм Штормариона",
    TITLE_KNOWLEDGE_TRACKER = "Отслеживание знаний",
    TOOLTIP_KNOWLEDGE_DESC = "Показать потраченные, непотраченные и максимальные знания",
    LABEL_SPENT = "Потрачено",
    LABEL_UNSPENT = "Не потрачено",
    LABEL_MAX = "Максимум",
    LABEL_EARNED = "Получено",
    LABEL_TREATISE = "Трактат",
    LABEL_ARTISAN_QUEST = "Ремесленник",
    LABEL_CATCHUP = "Навёрстывание",
    LABEL_WEEKLY = "Еженедельно",
    LABEL_UNLOCKED = "Открыто",
    LABEL_UNLOCK_REQUIREMENTS = "Требования для открытия",
    LABEL_SOURCE_NOTE = "Еженедельные источники и снимок навёрстывания",
    LABEL_TREASURE_CLICK_HINT = "Нажмите на уникальное сокровище, чтобы поставить точку маршрута",
    LABEL_ZONE = "Зона",
    LABEL_COORDINATES = "Координаты",
    TOOLTIP_TREASURE_SET_WAYPOINT = "Нажмите, чтобы поставить точку маршрута TomTom",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "Нажмите, чтобы поставить точку на карте",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "У этого сокровища нет фиксированного местоположения",
    MSG_TREASURE_NO_WAYPOINT = "У этого сокровища нет фиксированной точки маршрута.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom не обнаружен.",
    MSG_TREASURE_WAYPOINT_SET = "Точка маршрута установлена: %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "Точка на карте установлена: %s (%.1f, %.1f)",
    STATUS_DONE_WORD = "Готово",
    STATUS_MISSING_WORD = "Отсутствует",
    LABEL_MIDNIGHT_SEASON_1 = "1-й сезон Midnight",
    TAB_SOURCES = "Источники",
    TIME_TODAY = "Сегодня %H:%M",
    TIME_YESTERDAY = "Вчера %H:%M",
    MSG_CAP_WARNING = "Предупреждение о лимите инстансов! %d/10 инстансов за этот час.",
    MSG_CAP_SLOT_OPEN = "Теперь доступен слот инстанса! (%d/10 использовано)",
    MSG_RELOAD_TIMEPLAYED = "Перезагрузите интерфейс, чтобы скрытие сообщения /played вступило в силу.",
    MSG_RAID_DEBUG_ON = "Отладка рейдов LiteVault: ВКЛ",
    MSG_RAID_DEBUG_OFF = "Отладка рейдов LiteVault: ВЫКЛ",
    MSG_RAID_DEBUG_TIP = "Используйте /lvraiddbg ещё раз, чтобы отключить вывод отладки",
    MSG_TRACKED_KILL = "Отслежен килл %s: %s (%s)",
    LOCALE_DEBUG_ON = "Режим отладки локали ВКЛ - показываются ключи строк",
    LOCALE_DEBUG_OFF = "Режим отладки локали ВЫКЛ - показываются переводы",
    LOCALE_BORDERS_ON = "Режим границ ВКЛ - показываются границы текста",
    LOCALE_BORDERS_HINT = "Зелёный = помещается, Красный = может выйти за пределы",
    LOCALE_BORDERS_OFF = "Режим границ ВЫКЛ",
    LOCALE_FORCED = "Локаль принудительно установлена на %s",
    LOCALE_RESET_TIP = "Используйте /lvlocale reset, чтобы вернуться к автоопределению",
    LOCALE_INVALID = "Недопустимая локаль. Допустимые варианты:",
    LOCALE_RESET = "Локаль сброшена на автоопределение: %s",
    LOCALE_TITLE = "Локализация LiteVault",
    LOCALE_DETECTED = "Определённая локаль: %s",
    LOCALE_FORCED_TO = "Принудительная локаль: %s",
    LOCALE_DEBUG_KEYS = "Ключи отладки:",
    LOCALE_DEBUG_BORDERS = "Границы отладки:",
    LOCALE_ON = "ВКЛ",
    LOCALE_OFF = "ВЫКЛ",
    LOCALE_COMMANDS = "Команды:",
    LOCALE_CMD_DEBUG = "/lvlocale debug - Переключить режим показа ключей",
    LOCALE_CMD_BORDERS = "/lvlocale borders - Переключить отображение границ текста",
    LOCALE_CMD_LANG = "/lvlocale lang XX - Принудительно выбрать локаль (например, deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - Вернуться к автоопределению",
    TITLE_INSTANCE_TRACKER = "Отслеживание инстансов",
    SECTION_INSTANCE_CAP = "Лимит инстансов (10/час)",
    LABEL_CAP_CURRENT = "Текущее: %d/10",
    LABEL_CAP_STATUS = "Статус: %s",
    LABEL_NEXT_SLOT = "Следующий слот через: %s",
    STATUS_SAFE = "БЕЗОПАСНО",
    STATUS_WARNING = "ПРЕДУПРЕЖДЕНИЕ",
    STATUS_LOCKED = "ЗАБЛОКИРОВАНО",
    SECTION_CURRENT_RUN = "Текущий забег",
    LABEL_DURATION = "Длительность: %s",
    LABEL_NOT_IN_INSTANCE = "Не в инстансе",
    SECTION_PERFORMANCE = "Результаты за сегодня",
    LABEL_DUNGEONS_TODAY = "Подземелья: %d",
    LABEL_RAIDS_TODAY = "Рейды: %d",
    LABEL_AVG_TIME = "Средн.: %s",
    SECTION_LEGACY_RAIDS = "Старые рейды на этой неделе",
    LABEL_LEGACY_RUNS = "Забеги: %d",
    LABEL_GOLD_EARNED = "Золото: %s",
    SECTION_RECENT_RUNS = "Недавние забеги",
    LABEL_NO_RECENT_RUNS = "Нет недавних забегов",
    SECTION_MPLUS = "Мифик+",
    LABEL_MPLUS_CURRENT_KEY = "Текущий ключ:",
    LABEL_RUNS_TODAY = "Забеги сегодня: %d",
    LABEL_RUNS_THIS_WEEK = "Забеги за неделю: %d",
    SECTION_RECENT_MPLUS_RUNS = "Недавние забеги М+",
    LABEL_NO_RECENT_MPLUS_RUNS = "Нет недавних забегов М+",
    LABEL_QUEST = "Задание",
    BUTTON_DASHBOARD = "Обзор",
    BUTTON_ACHIEVEMENTS = "Достижения",
    TITLE_ACHIEVEMENTS = "Достижения",
    DESC_ACHIEVEMENTS = "Выберите трекер достижений для просмотра подробного прогресса.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "Охотник за глифами Полуночи",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "Охотник за глифами Полуночи",
    LABEL_REWARD = "Награда",
    DESC_GLYPH_REWARD = "Выполните «Охотника за глифами Полуночи», чтобы получить это ездовое животное.",
    MSG_NO_ACHIEVEMENT_DATA = "Данные отслеживания достижений недоступны.",
    LABEL_CRITERIA = "Критерии",
    LABEL_GLYPHS_COLLECTED = "Собранные глифы",
    LABEL_ACHIEVEMENT = "Достижение",
    BUTTON_BAGS = "Сумки",
    BUTTON_BANK = "Банк",
    BUTTON_WARBAND_BANK = "Банк отряда",
    BAGS_EMPTY_STATE = "Нет сохранённых предметов в сумках для этого персонажа.",
    BANK_EMPTY_STATE = "Нет сохранённых предметов в банке для этого персонажа.",
    WARBANK_EMPTY_STATE = "Нет сохранённых предметов в банке отряда.",
    LABEL_BAG_SLOTS = "Ячейки: %d / %d использовано",
    LABEL_SCANNED = "проверено",
    ["Coffer Key Shards"] = "Осколки ключа от сундука",
    BUTTON_WEEKLY_PLANNER = "Планировщик",
    TITLE_WEEKLY_PLANNER = "Еженедельный планировщик",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "Еженедельный планировщик",
    TOOLTIP_WEEKLY_PLANNER_DESC = "Редактируемый еженедельный список задач для каждого персонажа. Выполненные пункты сбрасываются каждую неделю.",
    TOOLTIP_VAULT_STATUS = "Проверить состояние хранилища.",
    TITLE_GREAT_VAULT = "Великое хранилище",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "Рейд",
    LABEL_VAULT_ROW_DUNGEONS = "Подземелья",
    LABEL_VAULT_ROW_WORLD = "Мир",
    LABEL_VAULT_SLOTS_UNLOCKED = "Открыто слотов: %d/9",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "Данные о порогах пока не сохранены.",
    MSG_VAULT_LIVE_ACTIVE = "Текущий прогресс Великого хранилища для активного персонажа.",
    MSG_VAULT_LIVE = "Текущий прогресс Великого хранилища.",
    MSG_VAULT_SAVED = "Сохранённый снимок Великого хранилища с последнего входа этого персонажа.",
    SECTION_DELVE_CURRENCY = "Валюта вылазок",
    SECTION_UPGRADE_CRESTS = "Гербы улучшения",
    LABEL_CAP_SHORT = "лимит %s",
    ["Treasures of Midnight"] = "Сокровища Midnight",
    ["Track the four Midnight treasure achievements and their rewards."] = "Отслеживайте четыре достижения за сокровища Midnight и их награды.",
    ["Glory of the Midnight Delver"] = "Слава исследователя вылазок Midnight",
    ["Complete Glory of the Midnight Delver to earn this mount."] = "Завершите «Слава исследователя вылазок Midnight», чтобы получить это средство передвижения.",
    ["Track the four Midnight rare achievements and zone rare rewards."] = "Отслеживайте четыре достижения за редких существ Midnight и награды за редких существ зоны.",
    ["Track the four Midnight rare achievements."] = "Отслеживайте четыре достижения за редких существ Midnight.",
    ["Complete the five telescopes in this zone."] = "Завершите все пять телескопов в этой зоне.",
    ["Complete all four supporting Midnight delver achievements to finish this meta achievement."] = "Завершите все четыре вспомогательных достижения исследователя вылазок Midnight, чтобы получить это мета-достижение.",
    ["Crimson Dragonhawk"] = "Багровый дракондор",
    ["Giganto-Manis"] = "Гиганто-Манис",
    ["Achievements"] = "Достижения",
    ["Reward"] = "Награда",
    ["Details"] = "Подробности",
    ["Criteria"] = "Критерии",
    ["Info"] = "Информация",
    ["Shared Loot"] = "Общая добыча",
    ["Groups"] = "Группы",
    ["Back to Groups"] = "Назад к группам",
    ["Back"] = "Назад",
    ["Unknown"] = "Неизвестно",
    ["Item"] = "Предмет",
    ["No achievement reward listed."] = "Награда за достижение не указана.",
    ["Click to set waypoint."] = "Нажмите, чтобы установить точку маршрута.",
    ["Click to open this tracker."] = "Нажмите, чтобы открыть этот отслеживатель.",
    ["Tracker not added yet."] = "Отслеживатель ещё не добавлен.",
    ["Coordinates pending."] = "Координаты ожидаются.",
    ["Complete the cave run here for credit."] = "Завершите прохождение пещеры здесь, чтобы получить зачет.",
    ["Charge the runestone with Latent Arcana to start its defense event."] = "Зарядите рунический камень скрытой арканой, чтобы начать событие его защиты.",
    ["Achievement credit from:"] = "Зачёт достижения даётся за:",
    ["Stormarion Assault"] = "Штурм Стормариона",
    ["Ever-Painting"] = "Вечная живопись",
    ["Track the known Ever-Painting canvases. x/y marked."] = "Отслеживайте известные полотна Ever-Painting. x/y отмечены.",
    ["Tracked entries for Ever-Painting have not been added yet."] = "Отслеживаемые записи для Ever-Painting ещё не добавлены.",
    ["Runestone Rush"] = "Гонка рунических камней",
    ["Track the known Runestone Rush entries. x/y marked."] = "Отслеживайте известные записи Runestone Rush. x/y отмечены.",
    ["Tracked entries for Runestone Rush have not been added yet."] = "Отслеживаемые записи для Runestone Rush ещё не добавлены.",
    ["The Party Must Go On"] = "Праздник должен продолжаться",
    ["Track the four faction invites for The Party Must Go On. x/y marked."] = "Отслеживайте четыре приглашения фракций для Праздник должен продолжаться. x/y отмечены.",
    ["Tracked entries for The Party Must Go On have not been added yet."] = "Отслеживаемые записи для Праздник должен продолжаться ещё не добавлены.",
    ["Explore trackers"] = "Отслеживание исследования",
    ["Track Explore Eversong Woods progress. x/y marked."] = "Отслеживайте прогресс Explore Eversong Woods. x/y отмечены.",
    ["Tracked entries for Explore Eversong Woods have not been added yet."] = "Отслеживаемые записи для Explore Eversong Woods ещё не добавлены.",
    ["Track Explore Voidstorm progress. x/y marked."] = "Отслеживайте прогресс Explore Voidstorm. x/y отмечены.",
    ["Tracked entries for Explore Voidstorm have not been added yet."] = "Отслеживаемые записи для Explore Voidstorm ещё не добавлены.",
    ["Track Explore Zul'Aman progress. x/y marked."] = "Отслеживайте прогресс Explore Zul'Aman. x/y отмечены.",
    ["Tracked entries for Explore Zul'Aman have not been added yet."] = "Отслеживаемые записи для Explore Zul'Aman ещё не добавлены.",
    ["Track Explore Harandar progress. x/y marked."] = "Отслеживайте прогресс Explore Harandar. x/y отмечены.",
    ["Tracked entries for Explore Harandar have not been added yet."] = "Отслеживаемые записи для Explore Harandar ещё не добавлены.",
    ["Thrill of the Chase"] = "Острота погони",
    ["Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds."] = "Уклоняйтесь от хватки Голодного Присутствия в Voidstorm не менее 60 секунд.",
    ["This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds."] = "Это достижение не требует отслеживания координат в LiteVault. Переживите событие Голодного Присутствия в Voidstorm не менее 60 секунд.",
    ["Tracked entries for Thrill of the Chase have not been added yet."] = "Отслеживаемые записи для Острота погони ещё не добавлены.",
    ["No Time to Paws"] = "Нет времени на лапы",
    ["Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."] = "Выполните локальное задание Harandar 'Когти закона', имея 15 или более эффектов Преследования хищника.",
    ["This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit."] = "Это достижение не требует отслеживания координат в LiteVault. Выполните локальное задание Harandar 'Когти закона', имея 15 или более эффектов Преследования хищника.",
    ["Tracked entries for No Time to Paws have not been added yet."] = "Отслеживаемые записи для Нет времени на лапы ещё не добавлены.",
    ["From The Cradle to the Grave"] = "От колыбели до могилы",
    ["Attempt to fly to The Cradle high in the sky above Harandar."] = "Попробуйте долететь до Колыбели высоко в небе над Harandar.",
    ["Fly into The Cradle high in the sky above Harandar to complete this achievement."] = "Чтобы завершить это достижение, долетите до Колыбели высоко в небе над Harandar.",
    ["Chronicler of the Haranir"] = "Летописец Харанир",
    ["These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap."] = "Эти журналы доступны только во время еженедельного задания для учетной записи 'Легенды Харанир'. Находясь в видении, ищите на миникарте значок лупы.",
    ["Recover the Haranir journal entries listed below."] = "Найдите записи журнала Харанир, перечисленные ниже.",
    ["Recover the Haranir journal entries listed below. x/y marked."] = "Найдите записи журнала Харанир, перечисленные ниже. x/y отмечены.",
    ["Legends Never Die"] = "Легенды не умирают",
    ["This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete."] = "Это связано с еженедельным заданием для учетной записи 'Легенды Харанир'. Если у вас ещё нет прогресса, на выполнение уйдёт примерно 7 недель.",
    ["Defend each Haranir legend location listed below."] = "Защитите каждое место легенд Харанир, указанное ниже.",
    ["Protect each Haranir legend location listed below. x/y marked."] = "Защитите каждое место легенд Харанир, указанное ниже. x/y отмечены.",
    ["Dust 'Em Off"] = "Смахните пыль",
    ["Find all of the Glowing Moths hiding in Harandar. x/y found."] = "Найдите всех Светящихся мотыльков, скрывающихся в Harandar. x/y найдены.",
    ["Coordinate groups have not been added yet."] = "Группы координат ещё не добавлены.",
    ["This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable."] = "Этот отслеживатель разделён на 3 группы по 40 координат, чтобы маршруты мотыльков оставались удобными.",
    ["Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2."] = "Мотыльки 1-40 появляются на известности Hara'ti 1, отслеживание доступно на известности 2.",
    ["Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6."] = "Мотыльки 41-80 появляются на известности Hara'ti 4, отслеживание доступно на известности 6.",
    ["Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11."] = "Мотыльки 81-120 появляются на известности Hara'ti 9, отслеживание доступно на известности 11.",
    ["LiteVault routing assumes you already have Hara'ti Renown 11 unlocked."] = "Маршрутизация LiteVault предполагает, что у вас уже открыта известность Hara'ti 11.",
    ["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s содержит %d координат мотыльков. Щёлкните по мотыльку, чтобы установить точку маршрута.",
    ["Group 1"] = "Группа 1",
    ["Group 2"] = "Группа 2",
    ["Group 3"] = "Группа 3",
    ["Moths"] = "Мотыльки",
    ["A Singular Problem"] = "Сингулярная проблема",
    ["Complete all three waves of the Stormarion Assault. x/y marked."] = "Завершите все три волны Штурма Стормариона. x/y отмечены.",
    ["Tracked entries for A Singular Problem have not been added yet."] = "Отслеживаемые записи для Сингулярная проблема ещё не добавлены.",
    ["Abundance: Prosperous Plentitude!"] = "Изобилие: Процветающая полнота!",
    ["Complete an Abundant Harvest cave run in each location. x/y marked."] = "Завершите прохождение пещеры Изобильного урожая в каждом месте. x/y отмечены.",
    ["You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough."] = "Чтобы получить зачёт, нужно завершить прохождение пещеры Изобильного урожая в каждом месте. Просто посетить пещеру недостаточно.",
    ["Tracked entries for Abundance: Prosperous Plentitude! have not been added yet."] = "Отслеживаемые записи для Изобилие: Процветающая полнота! ещё не добавлены.",
    ["Altar of Blessings"] = "Алтарь благословений",
    ["Trigger each listed blessing effect for credit."] = "Активируйте каждый указанный эффект благословения для получения зачёта.",
    ["Trigger each listed blessing effect. x/y marked."] = "Активируйте каждый указанный эффект благословения. x/y отмечены.",
    ["Meta achievement summaries"] = "Сводки мета-достижений",
    ["Complete the Eversong Woods achievements listed below. x/y done."] = "Завершите достижения Eversong Woods, перечисленные ниже. x/y выполнено.",
    ["Complete all of the Voidstorm achievements listed below. x/y done."] = "Завершите все достижения Voidstorm, перечисленные ниже. x/y выполнено.",
    ["Complete all of the Zul'Aman achievements listed below. x/y done."] = "Завершите все достижения Zul'Aman, перечисленные ниже. x/y выполнено.",
    ["Aid the Hara'ti by completing the achievements below. x/y done."] = "Помогите Hara'ti, выполнив достижения ниже. x/y выполнено.",
    ["Rally your forces against Xal'atath by completing the achievements below. x/y done."] = "Соберите силы против Xal'atath, выполнив достижения ниже. x/y выполнено.",
    ["Tracked entries for Making an Amani Out of You have not been added yet."] = "Отслеживаемые записи для Making an Amani Out of You ещё не добавлены.",
    ["Tracked entries for That's Aln, Folks! have not been added yet."] = "Отслеживаемые записи для That's Aln, Folks! ещё не добавлены.",
    ["Tracked entries for Forever Song have not been added yet."] = "Отслеживаемые записи для Forever Song ещё не добавлены.",
    ["Tracked entries for Yelling into the Voidstorm have not been added yet."] = "Отслеживаемые записи для Yelling into the Voidstorm ещё не добавлены.",
    ["Tracked entries for Light Up the Night have not been added yet."] = "Отслеживаемые записи для Light Up the Night ещё не добавлены.",
    ["Mount: Brilliant Petalwing"] = "Транспорт: Сияющий лепесткокрыл",
    ["Housing Decor: On'ohia's Call"] = "Декор для дома: Зов Он'охии",
    ["Title: \"Dustlord\""] = "Титул: \"Пылевладыка\"",
    ["Title: \"Chronicler of the Haranir\""] = "Титул: \"Летописец Харанир\"",
    ["home reward labels:"] = "Подписи домашних наград:",
}

L["Raid resync unavailable."] = "Повторная синхронизация рейда недоступна."
L["Time played messages will be suppressed."] = "Сообщения об игровом времени будут скрыты."
L["Time played messages restored."] = "Сообщения об игровом времени восстановлены."
L["%dm %02ds"] = "%d мин %02d сек"
L["Crests:"] = "Гребни:"
L["Mount Drops"] = "Трофеи: транспорт"
L["(Collected)"] = "(Собрано)"
L["(Uncollected)"] = "(Не собрано)"
L["Mounts: %d/%d"] = "Средства передвижения: %d/%d"
L["LABEL_MOUNTS_FMT"] = "Средства передвижения: %d/%d"
L["The Voidspire"] = "Шпиль Бездны"
L["The Dreamrift"] = "Разлом Сна"
L["March of Quel'Danas"] = "Поход на Кель'Данас"
L["Raid Progression"] = "Прогресс рейда"
L["Lady Liadrin Weekly"] = "Еженедельное задание леди Лиадрин"
L["Change Log"] = "Журнал изменений"
L["Back"] = "Назад"
L["Warband Bank"] = "Банк отряда"
L["Treatise"] = "Трактат"
L["Artisan"] = "Ремесленник"
L["Catch-up"] = "Навёрстывание"
L["LiteVault Update Summary"] = "Сводка обновления LiteVault"
L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] = "Мы обновили несколько ключевых элементов интерфейса, включая значок валюты, значок рейда, панель профессий и отслеживание Великого хранилища."
L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] = "Отображение уровня предметов в хранилище было обновлено, чтобы оно больше соответствовало стандартному виду Великого хранилища Blizzard."
L["Added a large batch of new translations across supported locales."] = "Мы добавили большой пакет новых переводов для поддерживаемых языков."
L["Improved localized text rendering and refresh behavior throughout the addon."] = "Мы улучшили отображение и обновление локализованного текста во всем аддоне."
L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] = "Мы обновили поддержку локализации для кнопок, вкладок сумок, еженедельного текста и других элементов интерфейса."
L["Fixed multiple localization-related layout issues."] = "Мы исправили несколько проблем с компоновкой, связанных с локализацией."
L["Fixed several localization-related crash issues."] = "Мы исправили несколько сбоев, связанных с локализацией."

-- Register this locale
lv.RegisterLocale("ruRU", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["ruRU"] = L




