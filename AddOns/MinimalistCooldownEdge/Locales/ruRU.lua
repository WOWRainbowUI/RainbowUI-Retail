-- ruRU.lua (Russian)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "ruRU")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "Цветами порогов таймера управляет MiniAuras. Настройте их в MiniAuras > Misc > Countdown Colours."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% — прозрачно, 100% — полностью темно. Применяется ко всем группам модулей MiniAuras; 80% соответствует заливке, которую рисует сам MiniAuras."

-- Core
L["MiniAuras test command is unavailable."] = "Команда теста MiniAuras недоступна."

-- Category Names
L["Action Bars"] = "Панели действий"
L["Nameplates"] = "Таблички имен"
L["Unit Frames"] = "Фреймы юнитов"
L["Party / Raid Frames"] = "Фреймы группы/рейда"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "Типы рамок MiniAuras"

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
L["Essential Viewer Stack Size"] = "Размер стаков просмотрщика Essential"
L["Utility Viewer Stack Size"] = "Размер стаков просмотрщика Utility"
L["Buff Icon Viewer Stack Size"] = "Размер стаков просмотрщика иконок баффов"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "Включает или выключает встроенные тестовые иконки MiniAuras через /miniauras test."

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
L["Top"] = "Сверху"
L["Bottom"] = "Снизу"
L["Left"] = "Слева"
L["Right"] = "Справа"

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
L["Retired"] = "Не поддерживается"

-- General Dashboard
L["Enable categories styling"] = "Включить стили категорий"
L["LIVE_CONTROLS_DESC"] = "Изменения применяются мгновенно. Оставьте включёнными только те категории, которыми вы действительно пользуетесь, чтобы интерфейс оставался чище."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Включение категории «Фреймы группы/рейда» служит главным переключателем для этой категории. Включение текста аур рейда распространяет тот же стиль на рейдовые фреймы Blizzard."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "Поддержка фреймов группы/рейда прекращена. Начиная с патча Blizzard 12.0.5 MiniCE больше не подключается к компактным фреймам группы и рейда и не изменяет их стиль."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "Новый аддон в разработке: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras уже доступен на CurseForge. Он остаётся отдельным от MiniCE, потому что использует собственные фреймы-накладки вместо стилизации существующих значков Blizzard, поэтому он лучше подходит как самостоятельный аддон."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Скопируйте эту ссылку, чтобы открыть страницу проекта на CurseForge в браузере."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "Скопируйте эту ссылку, чтобы открыть Raid Frame Auras на CurseForge."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Скопируйте эту ссылку, чтобы посмотреть другие проекты Anahkas на CurseForge."

-- Help
L["Help & Support"] = "Помощь и поддержка"
L["Project"] = "Проект"
L["Useful Addons"] = "Полезные аддоны"
L["Support & Feedback"] = "Поддержка и отзывы"
L["MCE_HELP_INTRO"] = "Быстрые ссылки по проекту и пара аддонов, которые стоит попробовать."
L["HELP_SUPPORT_DESC"] = "Предложения и отзывы всегда приветствуются.\n\nЕсли вы нашли ошибку или у вас есть идея функции, не стесняйтесь оставить комментарий или личное сообщение на CurseForge."
L["HELP_COMPANION_DESC"] = "Аккуратные аддоны, которые хорошо сочетаются с MiniCE."
L["HELP_MINIAURAS_DESC"] = "Набор настраиваемых индикаторов аур, контроля, перезарядок и PvP. MiniCE также может оформлять текст перезарядки."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "Скопируйте эту ссылку, чтобы открыть страницу MiniAuras на CurseForge в браузере."
L["HELP_PVPTAB_DESC"] = "Заставляет TAB выбирать в PvP только игроков. Отлично подходит для арен и полей боя."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Скопируйте эту ссылку, чтобы открыть Smart PvP Tab Targeting на CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Переключайте основные категории кулдаунов в одном месте."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Это действие нельзя отменить. Ваш профиль будет полностью сброшен, а интерфейс перезагружен."
L["MAINTENANCE_DESC"] = "Возвращает эту категорию к заводским настройкам. Остальные категории не затрагиваются."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Оформляйте перезарядки на ваших панелях действий."
L["NAMEPLATE_DESC"] = "Оформляйте перезарядки на вражеских и союзных табличках имен."
L["UNITFRAME_DESC"] = "Оформляйте перезарядки аур на рамках цели, фокуса и других поддерживаемых рамках."
L["COOLDOWNMANAGER_DESC"] = "Оформляйте перезарядки иконок CooldownManager."
L["MINIAURAS_DESC"] = "Оформляйте иконки перезарядки MiniAuras."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Динамические цвета текста"
L["Color by Remaining Time"] = "Цвет по оставшемуся времени"
L["Dynamically colors the countdown text based on how much time is left."] = "Динамически меняет цвет текста таймера в зависимости от оставшегося времени."
L["DYNAMIC_COLORS_DESC"] = "Меняет цвет текста в зависимости от оставшейся длительности перезарядки. При включении заменяет статический цвет выше."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Пороги оставшегося времени можно разрешить или заблокировать для каждой активной категории MiniCE. Обработка длительности остаётся корректной даже на смене суток, когда Blizzard отдаёт скрытые значения."
L["Expiring Soon"] = "Скоро закончится"
L["Short Duration"] = "Короткая длительность"
L["Long Duration"] = "Длинная длительность"
L["Threshold (seconds)"] = "Порог (секунды)"
L["Default Color"] = "Цвет по умолчанию"
L["Color used when the remaining time exceeds all thresholds."] = "Цвет, используемый, когда оставшееся время превышает все пороги."

-- Abbreviation
L["Abbreviate Above"] = "Сокращать выше"
L["Abbreviate Above (seconds)"] = "Сокращать выше (секунды)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Числа перезарядки выше этого порога будут сокращены (например, 5м вместо 300)."
L["ABBREV_THRESHOLD_DESC"] = "Определяет, когда числа перезарядки переключаются на сокращённый формат. Таймеры выше этого порога отображают сокращённые значения, такие как 5м или 1ч."

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% — прозрачно, 100% — полностью темно. Заменяет настройку Cooldown Swipe Alpha аддона MyDRs, пока эта категория активна; 100% соответствует заливке, которую рисует сам MyDRs."
L["MyDRs test command is unavailable."] = "Команда теста MyDRs недоступна."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "Включает или выключает встроенные тестовые иконки MyDRs через /mydrs test."
L["sArena slash command is unavailable."] = "Слэш-команда sArena недоступна."

-- Category Names
L["Player Auras"] = "Ауры игрока"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "Профили"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "Край заполнения"
L["MiniAuras Module Groups"] = "Группы модулей MiniAuras"
L["sArena Cooldown Types"] = "Типы перезарядок sArena"
L["Aura Targets"] = "Цели аур"
L["Buff Styling"] = "Оформление баффов"
L["Debuff Styling"] = "Оформление дебаффов"
L["External Defensive Buffs Styling"] = "Оформление внешних защитных баффов"

-- Toggles & Settings
L["Style Buffs"] = "Оформлять баффы"
L["Style Debuffs"] = "Оформлять дебаффы"
L["Style External Defensive Buffs"] = "Оформлять внешние защитные баффы"
L["Style Blizzard's default player buff buttons."] = "Оформляет стандартные иконки баффов игрока Blizzard."
L["Style Blizzard's default player debuff buttons."] = "Оформляет стандартные иконки дебаффов игрока Blizzard."
L["Style Blizzard's external defensive buff buttons."] = "Оформляет иконки внешних защитных баффов Blizzard."
L["Timer Inside Icon"] = "Таймер внутри иконки"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Размещает таймер ауры по центру иконки вместо стандартной внешней позиции Blizzard."
L["Hide Swipe"] = "Скрыть заполнение"
L["Only Mine (Timer Text)"] = "Только мои (текст таймера)"
L["Aura Visibility"] = "Видимость аур"
L["Only My Debuffs"] = "Только мои дебаффы"
L["Only My Buffs"] = "Только мои баффы"
L["Disable fading/blinking"] = "Отключить затухание/мигание"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "Включает стилизованный текст обратного отсчёта на фреймах группы/рейда. При отключении оформление текста аур группы и рейда полностью выключается."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Также применяет стилизованный текст обратного отсчёта к иконкам баффов и дебаффов Blizzard CompactRaidFrame. Требует включённой категории «Фреймы группы/рейда»."
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "Скрывает анимацию заполнения для этой группы фреймов (текст обратного отсчёта остаётся видимым)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "Показывает текст таймера перезарядки только на ваших собственных аурах. Использует эвристику Blizzard для крупных аур вместо прямой проверки sourceUnit."
L["UNITFRAME_ONLY_MINE_DESC"] = "Показывает текст таймера только на аурах, наложенных вами. Контейнеры цели/фокуса MiniCE для WoW 12.1 используют фильтр игрока Blizzard; совместимые и устаревшие фреймы используют свои метаданные группы или резервную эвристику крупных аур."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Скрывает дебаффы, наложенные другими игроками, на рамках цели и фокуса. MiniCE управляет этими контейнерами аур в WoW 12.1, поэтому собственный фильтр дебаффов Blizzard больше их не затрагивает."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Скрывает баффы, наложенные другими игроками, на рамках цели и фокуса. MiniCE управляет этими контейнерами аур в WoW 12.1, поэтому собственный фильтр баффов Blizzard больше их не затрагивает."
L["Cast Bar"] = "Полоса заклинания"
L["Reposition Cast Bar"] = "Переместить полосу заклинания"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Привязывает полосы заклинания цели и фокуса под последний ряд баффов/дебаффов. MiniCE управляет этими контейнерами аур в WoW 12.1, иначе полоса Blizzard остаётся у рамки и перекрывает их."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "Сохраняет иконки аур игрока полностью непрозрачными, когда они близки к истечению."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "Использует отдельный цвет баффа вместо цветов порога оставшегося времени, когда слот CooldownManager временно показывает время ауры."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "Применяется, пока слот показывает длительность ауры. Когда аура заканчивается и слот возвращается к времени перезарядки, снова применяются пороговые цвета."
L["Buff / Debuff Size"] = "Размер баффа/дебаффа"
L["Defensive Buff Size"] = "Размер защитного баффа"
L["Use Buff Color"] = "Использовать цвет баффа"
L["Buff Color"] = "Цвет баффа"
L["Essential Viewer"] = "Просмотрщик Essential"
L["Utility Viewer"] = "Просмотрщик Utility"
L["Buff Icon Viewer"] = "Просмотрщик иконок баффов"
L["CC Frames Text Size"] = "Размер текста рамок КК"
L["CC / Friendly Frames Text Size"] = "Размер текста КК / дружественных рамок"
L["Raid Frame Auras Text Size"] = "Размер текста аур рамок рейда"
L["Class Icon Text Size"] = "Размер текста значка класса"
L["DR Cooldown Text Size"] = "Размер текста перезарядки DR"
L["Alerts / Trackers / Custom Auras Text Size"] = "Размер текста оповещений / трекеров / пользовательских аур"
L["Trinket / Racial Text Size"] = "Размер текста аксессуара / расовой способности"
L["Show Test Frames"] = "Показать тестовые рамки"
L["Hide Test Frames"] = "Скрыть тестовые рамки"
L["Show Swipe Animation"] = "Показывать анимацию заполнения"
L["Shows the dark overlay that sweeps during a cooldown."] = "Показывает тёмную накладку, проходящую во время перезарядки."
L["Swipe Shade Alpha"] = "Непрозрачность затемнения заполнения"
L["0% = transparent, 100% = full dark."] = "0% — прозрачно, 100% — полностью темно."
L["Reverse Swipe"] = "Обратное заполнение"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "Меняет направление заполнения, чтобы затемнение заполнялось в противоположную сторону."
L["Hide Charge Timers"] = "Скрыть таймеры зарядов"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "Скрывает таймеры, пока заряды восстанавливаются (таймер показывается только когда все заряды израсходованы)."
L["Hide Stack Text"] = "Скрыть текст стаков"
L["Hide stacks and charges entirely."] = "Полностью скрывает стаки и заряды."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "Настройки текста MiniAuras сгруппированы по семействам модулей, чтобы похожие виджеты использовали один размер обратного отсчёта."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "Применяется к модулю CC MiniAuras (вражеский контроль)."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "Применяется к модулям CC, Friendly CDs и Friendly Indicators MiniAuras."
L["Applies to the MiniAuras Raid Frame Auras module."] = "Применяется к модулю Raid Frame Auras MiniAuras."
L["Applies to MiniAuras portrait icons."] = "Применяется к иконкам портретов MiniAuras."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "Применяется к модулям Alerts, Healer CC, Kick Timer, Precognition, Trinkets и Custom Auras MiniAuras."
L["Show sArena test frames using /sarena test."] = "Показывает тестовые рамки sArena через /sarena test."
L["Hide sArena test frames using /sarena hide."] = "Скрывает тестовые рамки sArena через /sarena hide."

-- Import / Export
L["Import string is too large."] = "Строка импорта слишком большая."
L["Import profile contains invalid data."] = "Импортированный профиль содержит недопустимые данные."
L["Failed to apply imported profile."] = "Не удалось применить импортированный профиль."

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "Некоторые изменения требуют перезагрузки интерфейса для полного применения.\n\nПерезагрузить интерфейс сейчас?"

-- Addon Integrations
L["Addon Integrations"] = "Интеграции аддонов"
L["ADDON_INTEGRATIONS_DESC"] = "Включает или отключает дополнительные мосты аддонов, которые перенаправляют внешние перезарядки в категории MiniCE."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "Перенаправляет перезарядки ShinyAuras через категорию «Фреймы юнитов». Отключите это, если хотите, чтобы ShinyAuras сохранял свои собственные обратные отсчёты без изменений."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "Перенаправляет поддерживаемые перезарядки панелей действий Dominos через категорию «Панели действий». Отключите это, если хотите, чтобы Dominos сохранял своё собственное оформление перезарядок без изменений."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "Перенаправляет поддерживаемые перезарядки панелей действий Bartender4 через категорию «Панели действий». Отключите это, если хотите, чтобы Bartender4 сохранял своё собственное оформление перезарядок без изменений."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "Перенаправляет поддерживаемые перезарядки панелей действий, фреймов юнитов и табличек имен ElvUI через категории MiniCE. Отключите это, если хотите, чтобы ElvUI сохранял своё собственное оформление перезарядок без изменений."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered также оформляет %s. Это может немного снизить производительность. Отключите шрифты таймера CMC, если хотите, чтобы MiniCE оставался единственным управляющим этими таймерами просмотрщиков."

-- Help
L["HELP_ARENADR_DESC"] = "Отслеживает вражеские накопительные штрафы прямо на табличках имен в Арене."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "Скопируйте эту ссылку, чтобы открыть ArenaDR Nameplates на CurseForge."

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames активен, поэтому оформление рамок юнитов MiniCE отключено во избежание возможных конфликтов. Специальный адаптер BetterBlizzFrames появится в ближайшее время."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates активен, поэтому оформление индикаторов здоровья MiniCE отключено во избежание возможных конфликтов."
L["PLAYERAURA_DESC"] = "Оформляйте перезарядки баффов и дебаффов игрока Blizzard."
L["HEALERCC_DESC"] = "Оформляйте перезарядки оповещений HealerCC для союзников и врагов."
L["MYDRS_DESC"] = "Оформляйте перезарядки иконок накопительных штрафов MyDRs. MyDRs сохраняет собственную метку состояния DR (50% / IMM)."
L["SARENA_DESC"] = "Оформляйте таймеры перезарядки sArena_Reloaded."
L["TELLMEWHEN_DESC"] = "Оформляйте текст перезарядки и края заполнения TellMeWhen."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "Видимость таймера, текст таймера, направление затемнения и отображение GCD по-прежнему контролируются TellMeWhen. Видимость и толщина края заполнения контролируются здесь."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Масштабирует край заполнения TellMeWhen, когда MiniCE его включил."

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "Разрешить пороговые цвета"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "Позволяет глобальным порогам «Цвет по оставшемуся времени» переопределять статический цвет текста этой категории."
L["Behavior"] = "Поведение"
L["Advanced Threshold Settings"] = "Расширенные настройки порогов"
L["Threshold Colors"] = "Пороговые цвета"
L["THRESHOLD_COLORS_DESC"] = "Каждая полоса определяет границу и цвет, используемые для этого диапазона оставшегося времени."
L["Threshold Transition Offset"] = "Смещение перехода порога"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "Сдвигает начало каждой следующей цветовой полосы. Отрицательные значения переключают немного раньше."
L["Beyond Thresholds Color"] = "Цвет выше всех порогов"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "Показывать десятые ниже (секунды)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "Числа перезарядки ниже этого порога будут показывать один десятичный знак (например, 8.7). Установите 0, чтобы отключить."

-- Performance Warning
L["PERF_WARNING_DESC"] = "Эта функция может повлиять на производительность и вызвать падение FPS. Используйте только на мощных системах."

-- Font Options
L["Game Default"] = "Стандартный шрифт игры"
