-- ruRU.lua (Russian)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "ruRU")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Невозможно открыть настройки в бою."
L["MiniCC test command is unavailable."] = "Команда теста MiniCC недоступна."

-- Category Names
L["Action Bars"] = "Панели действий"
L["Nameplates"] = "Таблички имен"
L["Unit Frames"] = "Фреймы юнитов"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "Прочее"

-- Group Headers
L["General"] = "Общее"
L["Typography (Cooldown Numbers)"] = "Типографика (числа перезарядки)"
L["Swipe Animation"] = "Анимация заполнения"
L["Stack Counters / Charges"] = "Счётчики стаков / зарядов"
L["Maintenance"] = "Обслуживание"
L["Danger Zone"] = "Опасная зона"
L["Style"] = "Стиль"
L["Positioning"] = "Положение"
L["CooldownManager Viewers"] = "Просмотрщики CooldownManager"
L["MiniCC Frame Types"] = "Типы рамок MiniCC"

-- Toggles & Settings
L["Enable %s"] = "Включить %s"
L["Toggle styling for this category."] = "Переключает оформление этой категории."
L["Font Face"] = "Шрифт"
L["Font"] = "Шрифт"
L["Size"] = "Размер"
L["Outline"] = "Обводка"
L["Color"] = "Цвет"
L["Hide Numbers"] = "Скрыть числа"
L["Compact Party / Raid Aura Text"] = "Текст аур компактных группы/рейда"
L["Enable Party Aura Text"] = "Включить текст аур группы"
L["Enable Raid Aura Text"] = "Включить текст аур рейда"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Полностью скрывает текст (полезно, если вам нужна только линия заполнения или стаки)."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Показывает стилизованный текст обратного отсчёта на иконках баффов и дебаффов Blizzard CompactPartyFrame. Если отключить, текст аур на рамках группы будет скрыт."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Показывает стилизованный текст обратного отсчёта на иконках баффов и дебаффов Blizzard CompactRaidFrame. Если отключить, текст аур на рамках рейда будет скрыт."
L["Anchor Point"] = "Точка привязки"
L["Offset X"] = "Смещение X"
L["Offset Y"] = "Смещение Y"
L["Essential Viewer Size"] = "Размер просмотрщика Essential"
L["Utility Viewer Size"] = "Размер просмотрщика Utility"
L["Buff Icon Viewer Size"] = "Размер просмотрщика иконок баффов"
L["CC Text Size"] = "Размер текста КК"
L["Nameplates Text Size"] = "Размер текста табличек имен"
L["Portraits Text Size"] = "Размер текста портретов"
L["Alerts / Overlay Text Size"] = "Размер текста оповещений / оверлеев"
L["Toggle Test Icons"] = "Переключить тестовые иконки"
L["Show Swipe Edge"] = "Показывать край заполнения"
L["Shows the white line indicating cooldown progress."] = "Показывает белую линию, обозначающую ход перезарядки."
L["Edge Thickness"] = "Толщина края"
L["Scale of the swipe line (1.0 = Default)."] = "Масштаб линии заполнения (1.0 = по умолчанию)."
L["Customize Stack Text"] = "Настроить текст стаков"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Управляйте счётчиком зарядов (например, 2 заряда Поджигания)."
L["Reset %s"] = "Сбросить %s"
L["Revert this category to default settings."] = "Возвращает эту категорию к настройкам по умолчанию."
L["Toggle MiniCC's built-in test icons using /minicc test."] = "Включает или выключает встроенные тестовые иконки MiniCC через /minicc test."

-- Outline Values
L["None"] = "Нет"
L["Thick"] = "Толстая"
L["Mono"] = "Моно"

-- Anchor Point Values
L["Bottom Right"] = "Снизу справа"
L["Bottom Left"] = "Снизу слева"
L["Top Right"] = "Сверху справа"
L["Top Left"] = "Сверху слева"
L["Center"] = "Центр"

-- General Tab
L["Factory Reset (All)"] = "Сброс к заводским (всё)"
L["Resets the entire profile to default values and reloads the UI."] = "Сбрасывает весь профиль к значениям по умолчанию и перезагружает интерфейс."
L["Import / Export"] = "Импорт / экспорт"
L["PROFILE_IMPORT_EXPORT_DESC"] = "Экспортирует активный профиль AceDB в строку для обмена или импортирует строку, заменяя текущие настройки профиля."
L["Export current profile"] = "Экспортировать текущий профиль"
L["Generate export"] = "Создать экспорт"
L["Export code"] = "Код экспорта"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "Создайте строку экспорта, затем щёлкните по этому полю и скопируйте её с помощью Ctrl+C."
L["Import profile"] = "Импортировать профиль"
L["Import code"] = "Код импорта"
L["Paste an exported string here, then click Import."] = "Вставьте сюда экспортированную строку и нажмите «Импорт»."
L["Import"] = "Импорт"
L["Importing will overwrite the current profile settings. Continue?"] = "Импорт перезапишет текущие настройки профиля. Продолжить?"
L["Export string generated. Copy it with Ctrl+C."] = "Строка экспорта создана. Скопируйте её с помощью Ctrl+C."
L["Profile import completed."] = "Импорт профиля завершён."
L["No active profile available."] = "Активный профиль недоступен."
L["Failed to encode export string."] = "Не удалось закодировать строку экспорта."
L["Paste an import string first."] = "Сначала вставьте строку импорта."
L["Invalid import string format."] = "Неверный формат строки импорта."
L["Failed to decode import string."] = "Не удалось декодировать строку импорта."
L["Failed to decompress import string."] = "Не удалось распаковать строку импорта."
L["Failed to deserialize import string."] = "Не удалось десериализовать строку импорта."

-- Banner
L["BANNER_DESC"] = "Минималистичная настройка ваших перезарядок. Выберите категорию слева, чтобы начать."

-- Chat Messages
L["%s settings reset."] = "Настройки %s сброшены."
L["Profile reset. Reloading UI..."] = "Профиль сброшен. Перезагрузка интерфейса..."

-- Status Indicators
L["ON"] = "ВКЛ"
L["OFF"] = "ВЫКЛ"

-- General Dashboard
L["Enable categories styling"] = "Включить стили категорий"
L["LIVE_CONTROLS_DESC"] = "Изменения применяются мгновенно. Оставьте включёнными только те категории, которыми вы действительно пользуетесь, чтобы интерфейс оставался чище."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Показывает стилизованный текст обратного отсчёта на иконках баффов и дебаффов Blizzard CompactPartyFrame и CompactRaidFrame. Группу и рейд можно переключать отдельно. Это не связано с категорией «Прочее»."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Скопируйте эту ссылку, чтобы открыть страницу проекта на CurseForge в браузере."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Скопируйте эту ссылку, чтобы посмотреть другие проекты Anahkas на CurseForge."

-- Help
L["Help & Support"] = "Помощь и поддержка"
L["Project"] = "Проект"
L["Useful Addons"] = "Полезные аддоны"
L["Support & Feedback"] = "Поддержка и отзывы"
L["MCE_HELP_INTRO"] = "Быстрые ссылки по проекту и пара аддонов, которые стоит попробовать."
L["HELP_SUPPORT_DESC"] = "Предложения и отзывы всегда приветствуются.\n\nЕсли вы нашли ошибку или у вас есть идея функции, не стесняйтесь оставить комментарий или личное сообщение на CurseForge."
L["HELP_COMPANION_DESC"] = "Аккуратные аддоны, которые хорошо сочетаются с MiniCE."
L["HELP_MINICC_DESC"] = "Компактный трекер контроля. MiniCE тоже умеет оформлять его текст."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "Скопируйте эту ссылку, чтобы открыть страницу MiniCC на CurseForge в браузере."
L["HELP_PVPTAB_DESC"] = "Заставляет TAB выбирать в PvP только игроков. Отлично подходит для арен и полей боя."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Скопируйте эту ссылку, чтобы открыть Smart PvP Tab Targeting на CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Переключайте основные категории кулдаунов в одном месте."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Это действие нельзя отменить. Ваш профиль будет полностью сброшен, а интерфейс перезагружен."
L["MAINTENANCE_DESC"] = "Возвращает эту категорию к заводским настройкам. Остальные категории не затрагиваются."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Настраивайте перезарядки на основных панелях действий, включая Bartender4, Dominos и ElvUI."
L["NAMEPLATE_DESC"] = "Оформляйте перезарядки, отображаемые на вражеских и союзных табличках имен (Plater, KuiNameplates и т. д.)."
L["UNITFRAME_DESC"] = "Настраивайте оформление перезарядок на рамках игрока, цели и фокуса."
L["COOLDOWNMANAGER_DESC"] = "Общее оформление иконок для просмотрщиков CooldownManager. Размер текста обратного отсчёта можно задавать отдельно для просмотрщиков Essential, Utility и иконок баффов."
L["MINICC_DESC"] = "Отдельный стиль для иконок перезарядки MiniCC. Поддерживает иконки контроля MiniCC, таблички имен, портреты и модули в стиле наложения, если MiniCC загружен."
L["OTHERS_DESC"] = "Категория для всех перезарядок, которые не относятся к другим разделам (сумки, меню, прочие аддоны)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Динамические цвета текста"
L["Color by Remaining Time"] = "Цвет по оставшемуся времени"
L["Dynamically colors the countdown text based on how much time is left."] = "Динамически меняет цвет текста таймера в зависимости от оставшегося времени."
L["DYNAMIC_COLORS_DESC"] = "Меняет цвет текста в зависимости от оставшейся длительности перезарядки. При включении заменяет статический цвет выше."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Применяет одинаковые пороги оставшегося времени ко всем включённым категориям MiniCE, включая текст аур компактных группы/рейда. Обработка длительности остаётся корректной даже на смене суток, когда Blizzard отдаёт скрытые значения."
L["Expiring Soon"] = "Скоро закончится"
L["Short Duration"] = "Короткая длительность"
L["Long Duration"] = "Длинная длительность"
L["Beyond Thresholds"] = "Выше всех порогов"
L["Threshold (seconds)"] = "Порог (секунды)"
L["Default Color"] = "Цвет по умолчанию"
L["Color used when the remaining time exceeds all thresholds."] = "Цвет, используемый, когда оставшееся время превышает все пороги."

-- Abbreviation
L["Abbreviate Above"] = "Сокращать выше"
L["Abbreviate Above (seconds)"] = "Сокращать выше (секунды)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Числа перезарядки выше этого порога будут сокращены (например, 5м вместо 300)."
L["ABBREV_THRESHOLD_DESC"] = "Определяет, когда числа перезарядки переключаются на сокращённый формат. Таймеры выше этого порога отображают сокращённые значения, такие как 5м или 1ч."
