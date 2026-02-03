local L = LibStub("AceLocale-3.0"):NewLocale("Spy", "ruRU")
if not L then return end
-- TOC Note: Обнаруживает и предупреждает вас о присутствии ближайших вражеских игроков.

-- Configuration
L["Spy"] = "Spy"
L["Version"] = "Версия"
L["Spy Option"] = "Spy"
L["Profiles"] = "Профили"

-- About
L["About"] = "Info"
L["SpyDescription1"] = [[
SPY - это аддон, который оповещает вас о присутствии вражеских игроков поблизости.

]]

L["SpyDescription2"] = [[
|cffffd000 Список Поблизости |cffffffff
Отображает вражеских игроков, обнаруженных поблизости. Игроки удаляются из списка, если они не были обнаружены в течение определённого периода времени.
 
|cffffd000 Список за Последний Час |cffffffff
Отображает всех врагов, обнаруженных за последний час.

|cffffd000 Черный список |cffffffff
Игроки, добавленные в список Черный Список, не будут отображаться в SPY. Вы можете добавлять и удалять игроков из этого списка, используя выпадающее меню кнопки или удерживая клавишу Ctrl при клике по кнопке.

|cffffd000 Список Kill On Sight |cffffffff
Игроки из вашего списка Kill On Sight вызывают звуковое оповещение при обнаружении. Вы можете добавлять и удалять игроков из этого списка, используя выпадающее меню кнопки или удерживая клавишу Shift при клике по кнопке. Выпадающее меню также позволяет указать причины, по которым вы добавили кого-то в список Kill On Sight. Если вы хотите ввести свою конкретную причину, которой нет в списке, используйте пункт "Указать свою причину..." в разделе "Другое".

]]

L["SpyDescription3"] = [[
|cffffd000 Окно Статистики |cffffffff
Окно статистики содержит список всех встреченных врагов. По умолчанию он отсортирован по времени последнего обнаружения врага. Его можно отсортировать по имени, уровню, гильдии, количеству побед и поражений. Окно статистики также позволяет искать конкретного врага по имени или гильдии, а также имеет фильтры для отображения врагов, помеченных как «Kill On Sight», с отмеченными победами/поражениями или внесёнными причинами.

|cffffd000 Кнопка Kill On Sight |cffffffff
Если включено, эта кнопка появится на рамке цели вражеского игрока. Нажатие кнопки добавит/удалит цель врага в/из списка Kill On Sight. Клик ПКМ по кнопке позволит ввести причину для Kill On Sight.

|cffffd000 автор:|cffffffff Slipjack
]]

-- General Settings
L["GeneralSettings"] = "Основные Настройки"
L["GeneralSettingsDescription"] = [[
Настройки для включённого и отключённого состояния Spy.
]]
L["EnableSpy"] = "Включить Spy"
L["EnableSpyDescription"] = "Включает или отключает SPY."
L["EnabledInBattlegrounds"] = "Включить Spy на полях боя"
L["EnabledInBattlegroundsDescription"] = "Включает или отключает SPY, когда вы находитесь на полях боя."
L["EnabledInArenas"] = "Включить Spy на аренах"
L["EnabledInArenasDescription"] = "Включает или отключает SPY, когда вы находитесь на арене."
L["EnabledInWintergrasp"] = "Активировать Spy в PvP-зонах открытого мира"
L["EnabledInWintergraspDescription"] = "Включает или отключает SPY при нахождении в PvP-зонах открытого мира, таких как Озеро Ледяных Оков в Нордсколе."
L["EnabledInSanctuaries"] = "Включить Spy в святилищах"
L["EnabledInSanctuariesDescription"] = "Включает или отключает Spy, когда Вы находитесь в святилище."
L["DisableWhenPVPUnflagged"] = "Отключать SPY, когда PvP-флаг не активен"
L["DisableWhenPVPUnflaggedDescription"] = "Включает или отключает SPY в зависимости от вашего PvP-статуса."
L["DisabledInZones"] = "Отключать Spy в этих локациях"
L["DisabledInZonesDescription"]	= "Выбрать локации, где Spy будет отключен."
L["Booty Bay"] = "Пиратская Бухта"
L["Everlook"] = "Круговзор"						
L["Gadgetzan"] = "Прибамбасск"
L["Ratchet"] = "Кабестан"
L["The Salty Sailor Tavern"] = "Таверна \"Старый моряк\""
L["Cenarion Hold"] = "Крепость Кенария"
L["Shattrath City"] = "Шаттрат"
L["Area 52"] = "Зона 52"
L["Dalaran"] = "Даларан"
L["Bogpaddle"] = "Веслотопь"
L["The Vindicaar"] = "Виндикар"
L["Krasus' Landing"] = "Площадка Краса"
L["The Violet Gate"] = "Аметистовые врата"
L["Magni's Encampment"] = "Лагерь Магни"
L["Silithus"] = "Силитус"
L["Chamber of Heart"] = "Зал Сердца"
L["Hall of Ancient Paths"] = "Зал Древних Путей"
L["Sanctum of the Sages"] = "Святилище жрецов"
L["Rustbolt"] = "Ржавый болт"
L["Oribos"] = "Орибос"
L["Valdrakken"] = "Вальдраккен"
L["The Roasted Ram"] = "Жареный барашек"
L["Dornogal"] = "Дорногал"
L["Stonelight Rest"] = "Приют Каменного Света"
L["Delver's Headquarters"] = "Штаб исследователей"

-- Display
L["DisplayOptions"] = "Отображение"
L["DisplayOptionsDescription"] = [[
Настройки окна SPY и всплывающих подсказок.
]]
L["ShowOnDetection"] = "Отображать Spy при обнаружении вражеских игроков"
L["ShowOnDetectionDescription"] = "Отметьте эту опцию, чтобы показывать список Поблизости, если он ещё не отображается, при обнаружении вражеских игроков."
L["HideSpy"] = "Скрывать SPY, когда не обнаружено вражеских игроков"
L["HideSpyDescription"] = "Отметьте эту опцию, чтобы скрывать окно SPY, когда отображается список Поблизости и он становится пустым. При этом SPY не будет скрываться, если вы очистите список вручную."
L["ShowOnlyPvPFlagged"] = "Отображать только врагов с включённым PvP-статусом"
L["ShowOnlyPvPFlaggedDescription"] = "Отметьте эту опцию, чтобы показывать в списке Поблизости только врагов с включённым PvP-статусом."
L["ShowKoSButton"] = "Показывать кнопку KOS на рамке цели врага"
L["ShowKoSButtonDescription"] = "Отметьте эту опцию, чтобы показывать кнопку KOS на рамке цели врага."
L["Alpha"] = "прозрачность"
L["AlphaDescription"] = "Установите прозрачность окна Spy."
L["AlphaBG"] = "Прозрачность на полях сражений"
L["AlphaBGDescription"] = "Установите прозрачность окна Spy на полях сражений."
L["LockSpy"] = "Зафиксировать окно Spy"
L["LockSpyDescription"] = "Фиксирует окно SPY, чтобы оно не перемещалось."
L["ClampToScreen"] = "Закрепить окно в пределах Экрана"
L["ClampToScreenDescription"] = "Определяет, можно ли перемещать окно Spy за пределы экрана."
L["InvertSpy"] = "Инвертировать окно Spy"
L["InvertSpyDescription"] = "Переворачивает окно SPY вверх ногами."
L["Reload"] = "Перезагрузить Интерфейс"
L["ReloadDescription"] = "Требуется при изменении окна Spy."
L["ResizeSpy"] = "Автоматическое масштабирование окна SPY"
L["ResizeSpyDescription"] = "Отметьте эту опцию, чтобы автоматически изменять размер окна SPY при добавлении и удалении врагов."
L["ResizeSpyLimit"] = "Максимум в списке"
L["ResizeSpyLimitDescription"] = "Ограничить количество вражеских игроков в окне SPY."
L["DisplayTooltipNearSpyWindow"] = "Показывать всплывающую подсказку рядом с окном SPY"
L["DisplayTooltipNearSpyWindowDescription"] = "Отметьте эту опцию, чтобы отображать всплывающие подсказки рядом с окном SPY."
L["SelectTooltipAnchor"] = "Точка привязки всплывающей подсказки"
L["SelectTooltipAnchorDescription"] = "Выбрать точку закрепления для всплывающей подсказки, если вышеуказанная опция включена."
L["ANCHOR_CURSOR"] = "Курсор"
L["ANCHOR_TOP"] = "Сверху"
L["ANCHOR_BOTTOM"] = "Снизу"
L["ANCHOR_LEFT"] = "Слева"			
L["ANCHOR_RIGHT"] = "Справа"
L["TooltipDisplayWinLoss"] = "Отображает статистику побед/поражений во всплывающей подсказке"
L["TooltipDisplayWinLossDescription"] = "Установите этот параметр, чтобы отображать статистику побед/поражений игрока во всплывающей подсказке."
L["TooltipDisplayKOSReason"] = "Отображать причины Kill On Sight во всплывающей подсказке"
L["TooltipDisplayKOSReasonDescription"] = "Отметьте эту опцию, чтобы отображать причины внесения игрока в список Kill On Sight во всплывающей подсказке игрока."
L["TooltipDisplayLastSeen"] = "Показывать информацию о последнем обнаружении во всплывающей подсказке"
L["TooltipDisplayLastSeenDescription"] = "Отметьте эту опцию, чтобы отображать во всплывающей подсказке игрока время и место последнего обнаружения этого игрока."
L["DisplayListData"] = "Выберите данные противника для отображения"
L["Name"] = "имя"
L["Class"] = "Класс"
L["Rank"] = "Звание"
L["SelectFont"] = "Выбрать шрифт"
L["SelectFontDescription"] = "Выбрать шрифт для окна Spy."
L["RowHeight"] = "Выбрать Высоту Строки"
L["RowHeightDescription"] = "Выбрать Высоту Строки для окна SPY"
L["Texture"] = "Текстура"
L["TextureDescription"] = "Выбрать текстуру для окна Spy."

-- Alerts
L["AlertOptions"] = "Оповещения"
L["AlertOptionsDescription"] = [[
Настройки оповещений, уведомлений и предупреждений при обнаружении врагов.
]]
L["SoundChannel"] = "Выбрать Звуковой Канал"
L["Master"] = "Общая громкость"
L["SFX"] = "Звуковые эффекты"
L["Music"] = "Музыка"
L["Ambience"] = "Фон"
L["Announce"] = "Отправлять оповещения в:"
L["None"] = "Нет"
L["NoneDescription"] = "Не оповещать при обнаружении вражеских игроков."
L["Self"] = "Себе"
L["SelfDescription"] = "Объявлять для себя при обнаружении врагов."
L["Party"] = "Группа"
L["PartyDescription"] = "Объявлять группе при обнаружении вражеских игроков."
L["Guild"] = "Гильдия"
L["GuildDescription"] = "Объявлять гильдии при обнаружении вражеских игроков."
L["Raid"] = "Рейд"
L["RaidDescription"] = "Объявлять рейду при обнаружении вражеских игроков."
L["LocalDefense"] = "Оборона"
L["LocalDefenseDescription"] = "Объявлять в канал «ОборонаЛокальный», при обнаружении вражеских игроков."
L["OnlyAnnounceKoS"] = "Оповещать только Kill On Sight игроков"
L["OnlyAnnounceKoSDescription"] = "Отметьте эту опцию, чтобы отправлять оповещения только о врагах из вашего списка Kill On Sight."
L["WarnOnStealth"] = "Предупреждать при обнаружении невидимости" 
L["WarnOnStealthDescription"] = "Отметьте эту опцию, чтобы показывать предупреждение и издавать звуковое оповещение при заходе врага в невидимость."
L["WarnOnKOS"] = "Предупреждать при обнаружении Kill On Sight игрока"
L["WarnOnKOSDescription"] = "Отметьте эту опцию, чтобы показывать предупреждение и издавать звуковое оповещение при обнаружении врага из вашего списка Kill On Sight."
L["WarnOnKOSGuild"] = "Предупреждать при обнаружении Kill On Sight гильдии"
L["WarnOnKOSGuildDescription"] = "Отметьте эту опцию, чтобы показывать предупреждение и издавать звуковое оповещение при обнаружении врага из той же гильдии, что и кто-то из вашего списка Kill On Sight."
L["WarnOnRace"] = "Предупреждать при обнаружении Расы"
L["WarnOnRaceDescription"] = "Включите, чтобы проигрывалось звуковое оповещение при обнаружении выбранной расы."
L["SelectWarnRace"] = "Выбрать расу для обнаружения"
L["SelectWarnRaceDescription"] = "Выбрать расу для звукового оповещения."
L["WarnRaceNote"] = "Примечание: Вы должны хотя бы один раз выбрать вражескую цель, чтобы их Раса была добавлена в базу данных. При следующем обнаружении прозвучит звуковое оповещение. Это работает иначе, чем обнаружение врагов поблизости в бою."
L["DisplayWarningsInErrorsFrame"] = "Показывать предупреждения в окне ошибок"
L["DisplayWarningsInErrorsFrameDescription"] = "Отметьте эту опцию, чтобы отображать предупреждения во окне ошибок вместо графических всплывающих окон."
L["DisplayWarnings"] = "Выбор места отображения предупреждающих сообщений"
L["Default"] = "умолчанию"
L["ErrorFrame"] = "Ошибка кадра"
L["Moveable"] = "подвижной"
L["EnableSound"] = "Включить звуковые оповещения"
L["EnableSoundDescription"] = "Отметьте эту опцию, чтобы активировать звуковые оповещения при обнаружении врагов. При этом будут звучать разные сигналы, если враг использует невидимость или если он находится в вашем списке Kill On Sight."
L["OnlySoundKoS"] = "Воспроизводить звуковые оповещения только при обнаружении игроков из списка Kill On Sight."
L["OnlySoundKoSDescription"] = "Отметьте эту опцию, чтобы проигрывать звуковые оповещения только при обнаружении врагов из списка Kill On Sight."
L["StopAlertsOnTaxi"] = "отключить оповещения, когда на пути полета"
L["StopAlertsOnTaxiDescription"] = "Остановить всё уведомления и предупреждения при перелёте."

-- Nearby List
L["ListOptions"] = "Список Поблизости"
L["ListOptionsDescription"] = [[
Настройки добавления и удаления вражеских игроков.
]]
L["RemoveUndetected"] = "Удалить вражеских игроков из списка Поблизости после:"
L["1Min"] = "1 минута"
L["1MinDescription"] = "Удалять врага, если он не обнаруживался более 1 минуты."
L["2Min"] = "2 минут"
L["2MinDescription"] = "Удалять врага, если он не обнаруживался более 2 минут."
L["5Min"] = "5 минут"
L["5MinDescription"] = "Удалять врага, если он не обнаруживался более 5 минут."
L["10Min"] = "10 минут"
L["10MinDescription"] = "Удалять врага, если он не обнаруживался более 10 минут."
L["15Min"] = "15 минут"
L["15MinDescription"] = "Удалять врага, если он не обнаруживался более 15 минут."
L["Never"] = "Никогда не удалять"
L["NeverDescription"] = "Никогда не удалять вражеских игроков. Список Поблизости всё еще может быть очищен вручную."
L["ShowNearbyList"] = "Переключаться на список Ближайших при обнаружении врага"
L["ShowNearbyListDescription"] = "Отметьте эту опцию, чтобы показывать список Поблизости, если он ещё не отображается, при обнаружении вражеских игроков."
L["PrioritiseKoS"] = "Отдавать приоритет игрокам из списка Kill On Sight в списке Поблизости"
L["PrioritiseKoSDescription"] = "Отметьте эту опцию, чтобы всегда показывать врагов из списка Kill On Sight первыми в списке Поблизости."

-- Map
L["MapOptions"] = "Карта"
L["MapOptionsDescription"] = [[
Настройки мировой карты и миникарты, включая иконки и всплывающие подсказки.
]]
L["MinimapDetection"] = "Включить обнаружение на миникарте"
L["MinimapDetectionDescription"] = "Наведение курсора на известных вражеских игроков, обнаруженных на миникарте, добавляет их в список Поблизости."
L["MinimapNote"] = "          Внимание: Действует только для игроков с умением 'Выслеживание гуманоидов'."
L["MinimapDetails"] = "Отображать информацию об уровне/классе во всплывающих подсказках"
L["MinimapDetailsDescription"] = "Отметьте эту опцию, чтобы обновлять всплывающие подсказки на карте и отображать рядом с именами врагов информацию об уровне и классе."
L["DisplayOnMap"] = "Отображать иконки на карте"
L["DisplayOnMapDescription"] = "Отображать иконки на карте с местоположением других пользователей Spy из вашей группы, рейда и гильдии при обнаружении ими врагов."
L["SwitchToZone"] = "Переключиться на карту текущей зоны при обнаружении вражеского игрока"
L["SwitchToZoneDescription"] = "Сменить карту на текущую карту зоны игроков, когда обнаружены враги."
L["MapDisplayLimit"] = "Ограничить отображение иконок на карте:"
L["LimitNone"] = "Везде"
L["LimitNoneDescription"] = "Отображать всех обнаруженных врагов на карте независимо от вашего текущего местоположения."
L["LimitSameZone"] = "В пределах зоны"
L["LimitSameZoneDescription"] = "Отображать обнаруженных врагов на карте только если вы находитесь в той же зоне."
L["LimitSameContinent"] = "В пределах континента"
L["LimitSameContinentDescription"] = "Отображать обнаруженных врагов на карте только если вы находитесь на том же континенте."

-- Data Management
L["DataOptions"] = "Управление Данными"
L["DataOptionsDescription"] = [[

Настройки способов сбора и хранения данных в Spy.
]]
L["PurgeData"] = "Очистка данных о не обнаруженных врагах спустя:"
L["OneDay"] = "1 день"
L["OneDayDescription"] = "Очистить данные о не обнаруженных врагах, отсутствующих более 1 дня."
L["FiveDays"] = "5 дней"
L["FiveDaysDescription"] = "Очистить данные о не обнаруженных врагах, отсутствующих более 5 дней."
L["TenDays"] = "10 дней"
L["TenDaysDescription"] = "Очистить данные о не обнаруженных врагах, отсутствующих более 10 дней."
L["ThirtyDays"] = "30 дней"
L["ThirtyDaysDescription"] = "Очистить данные о не обнаруженных врагах, отсутствующих более 30 дней."
L["SixtyDays"] = "60 дней"
L["SixtyDaysDescription"] = "Очистить данные о не обнаруженных врагах, отсутствующих более 60 дней."
L["NinetyDays"] = "90 дней"
L["NinetyDaysDescription"] = "Очистить данные о не обнаруженных врагах, отсутствующих более 90 дней."
L["PurgeKoS"] = "Удалять KoS-игроков, не обнаруженных в течение заданного времени"
L["PurgeKoSDescription"] = "Отметьте эту опцию, чтобы автоматически удалять из списка Kill On Sight игроков, которые долгое время не были обнаружены, согласно настройкам времени для необнаруженных игроков."
L["PurgeWinLossData"] = "Очистка статистики побед/поражений по игрокам, не обнаруженным в течение заданного времени."
L["PurgeWinLossDataDescription"] = "Отметьте эту опцию, чтобы автоматически удалять данные о победах/поражениях сражений с врагами, которые долгое время не были обнаружены, согласно настройкам времени для необнаруженных игроков."
L["ShareData"] = "Делиться данными с другими пользователями аддона Spy"
L["ShareDataDescription"] = "Отметьте эту опцию, чтобы автоматически делиться информацией о встречах с вражескими игроками с другими пользователями Spy в вашей группе, рейде и гильдии."
L["UseData"] = "Использовать данные других пользователей аддона Spy"
L["UseDataDescription"] = "Отметьте эту опцию, чтобы использовать данные, собранные другими пользователями Spy в вашей группе, рейде и гильдии."
L["ShareKOSBetweenCharacters"] = "Синхронизировать список Kill On Sight между персонажами"
L["ShareKOSBetweenCharactersDescription"] = "Check this option to automatically sync the list of players you've marked as Kill On Sight across all your characters on the same server and faction."

-- Commands
L["SlashCommand"] = "Слэш-команды"
L["SpySlashDescription"] = "Эти кнопки выполняют те же функции, что и слэш-команды /SPY"
L["Enable"] = "Включить"
L["EnableDescription"] = "Включает Spy и показывает Главное Окно"
L["Show"] = "Показать"
L["ShowDescription"] = "Показывает Главное Окно."
L["Hide"] = "Спрятать"
L["HideDescription"] = "Скрывает главное окно."
L["Reset"] = "Сбросить"
L["ResetDescription"] = "Сбрасывает положение и оформление Главного Окна."
L["ClearSlash"] = "Очистить"
L["ClearSlashDescription"] = "Очищает список обнаруженных игроков."
L["Config"] = "Настройки"
L["ConfigDescription"] = "Открыть окно настройки аддона Spy в 'Параметры-Модификации'."
L["KOS"] = "KOS"
L["KOSDescription"] = "Добавить/удалить игрока в/из Kill On Sight списка."
L["InvalidInput"] = "Некорректный ввод"
L["Ignore"] = "Игнорировать"
L["IgnoreDescription"] = "Добавить/удалить игрока из Черного списка"
L["Test"] = "Тестовое"
L["TestDescription"] = "Отображает предупреждение, чтобы вы могли изменить его положение."
L["Sanctuary"] = "Святилище"
L["SanctuaryDescription"] = "Показать/Скрыть Spy на территории Святилища."

-- Lists
L["Nearby"] = "Поблизости"
L["LastHour"] = "Последний час"
L["Ignore"] = "Игнорировать"
L["KillOnSight"] = "Kill On Sight"

--Stats
L["Won"] = "Побед"
L["Lost"] = "Поражений"
L["Time"] = "Время"	
L["List"] = "Список"
L["Filter"] = "Фильтр"
L["Show Only"] = "Показывать только"
L["Realm"] = "Игровой мир"
L["KOS"] = "KOS"
L["Won/Lost"] = "Побед/Поражений"
L["Reason"] = "Причина"	 
L["HonorKills"] = "Почетные Победы"
L["PvPDeaths"] = "PvP Смерти"

-- Output messages
L["VersionCheck"] = "|cffc41e3aВнимание: Установлена неправильная версия Spy. Удалите эту версию и установите ту, которая соответствует текущей версии игры."
L["SpyEnabled"] = "|cff9933ffАддон SPY активирован."
L["SpyDisabled"] = "|cff9933ffАддон SPY отключён. Введите |cffffffff/spy show|cff9933ff чтобы включить."
L["UpgradeAvailable"] = "|cff9933ffДоступна новая версия Spy. Скачать её можно по адресу: \n|cffffffffhttps://www.curseforge.com/wow/addons/spy"
L["AlertStealthTitle"] = "Обнаружен невидимый игрок!"
L["AlertKOSTitle"] = "Обнаружен игрок Kill On Sight!"
L["AlertKOSGuildTitle"] = "Обнаружена гильдия игрока Kill On Sight!"
L["AlertTitle_kosaway"] = "Игрок Kill On Sight обнаружен с помощью "
L["AlertTitle_kosguildaway"] = "Гильдия игрока Kill On Sight обнаружена с помощью "
L["StealthWarning"] = "|cff9933ffОбнаружен невидимый игрок: |cffffffff"
L["KOSWarning"] = "|cffff0000Обнаружен игрок Kill On Sight: |cffffffff"
L["KOSGuildWarning"] = "|cffff0000Обнаружена гильдия игрока Kill On Sight: |cffffffff"
L["SpySignatureColored"] = "|cff9933ff[Spy] "
L["PlayerDetectedColored"] = "Обнаруженный игрок: |cffffffff"
L["PlayersDetectedColored"] = "Обнаруженные игроки: |cffffffff"
L["KillOnSightDetectedColored"] = "Обнаружен игрок Kill On Sight: |cffffffff"
L["PlayerAddedToIgnoreColored"] = "Игрок добавлен в Черный список: |cffffffff"
L["PlayerRemovedFromIgnoreColored"] = "Игрок удален из Черного Списка: |cffffffff"
L["PlayerAddedToKOSColored"] = "Игрок добавлен в список Kill On Sight: |cffffffff"
L["PlayerRemovedFromKOSColored"] = "Игрок удален из списка Kill On Sight: |cffffffff"
L["PlayerDetected"] = "[Spy] Обнаруженный игрок: "
L["KillOnSightDetected"] = "[Spy] Обнаружен игрок Kill On Sight: "
L["Level"] = "Уровень"
L["LastSeen"] = "Последнее обнаружение"
L["LessThanOneMinuteAgo"] = "меньше минуты назад"
L["MinutesAgo"] = "минут назад"
L["HoursAgo"] = "часов назад"
L["DaysAgo"] = "дней назад"
L["Close"] = "Закрыть"
L["CloseDescription"] = "|cffffffffСкрывает окно Spy. По умолчанию окно снова появится при обнаружении следующего вражеского игрока."
L["Left/Right"] = "Слева/Справа"
L["Left/RightDescription"] = "|cffffffffПерещает между списками Nearby, Встреченно за последний час, Игнорирования и Kill On Sight."
L["Clear"] = "Очистить"
L["ClearDescription"] = "|cffffffffОчищает список обнаруженных игроков. Нажатие Ctrl + клик включает/выключает Spy. Нажатие Shift + клик включает/выключает весь звук."
L["SoundEnabled"] = "Звуковые оповещения включены"
L["SoundDisabled"] = "Звуковые оповещения отключены"
L["NearbyCount"] = "Количество Поблизости"
L["NearbyCountDescription"] = "|cffffffffЧисло врагов поблизости."
L["Statistics"] = "Статистика"
L["StatsDescription"] = "|cffffffffПоказывает список встреченных вражеских игроков, их статистику побед/поражений и место последнего обнаружения."
L["AddToIgnoreList"] = "Добавить в Черный список"
L["AddToKOSList"] = "Добавить в список Kill On Sight"
L["RemoveFromIgnoreList"] = "Удалить из Черного Списка"
L["RemoveFromKOSList"] = "Удалить из списка Kill On Sight"
L["RemoveFromStatsList"] = "Удалить из списка 'Статистика'"   
L["AnnounceDropDownMenu"] = "Объявить"
L["KOSReasonDropDownMenu"] = "Установить причину Kill On Sight"
L["PartyDropDownMenu"] = "Группу"
L["RaidDropDownMenu"] = "Рейд"
L["GuildDropDownMenu"] = "Гильдия"
L["LocalDefenseDropDownMenu"] = "Локальную Оборону"
L["Player"] = " (Игрок)"
L["KOSReason"] = "Kill On Sight"
L["KOSReasonIndent"] = "    "
L["KOSReasonOther"] = "Указать свою причину..."
L["EnterKOSReason"] = "Введите причину Kill on Sight для %s"
L["KOSReasonClear"] = "Очистить"
L["StatsWins"] = "|cff40ff00Побед: "
L["StatsSeparator"] = "  "
L["StatsLoses"] = "|cff0070ddПоражений: "
L["Located"] = "обнаружен:"
L["DistanceUnit"] = "метры"
L["LocalDefenseChannelName"] = "ОборонаЛокальный" 

Spy_KOSReasonListLength = 6
Spy_KOSReasonList = {
	[1] = {
		["title"] = "Начал бой";
		["content"] = {
			"Атаковал меня без причины",
			"Атаковал меня возле мастера заданий", 
			"Атаковал меня, пока я сражался с НПС",
			"Атаковал меня возле подземелья",
			"Атаковал меня когда я был АФК",
			"Атаковал меня, пока я был верхом/в полётее",
			"Атаковал меня при низком уровне здоровья/маны",
		};
	},
	[2] = {
		["title"] = "Стиль боя";
		["content"] = {
			"Устроил засаду на меня",
			"Всегда атакует при встрече",
			"Убил меня персонажем более высокого уровня",
			"Убил меня с группой врагов",
			"Не атакует без поддержки",
			"Всегда зовет подмогу",
			"Злоупотребляет контролем (CC)",
		};
	},
	[3] = {
		["title"] = "Кемпит";
		["content"] = {
			"Кемпил меня",
			"Кемпил альта",
			"Кемпил низкоуровневых игроков",
			"Кемпил из невидимости",
			"Кемпил согильдийцев",
			"Кемпил игровых персонажей/ключевые точки",
			"Кемпил город/полетки",
		};
	},
	[4] = {
		["title"] = "Выполнение заданий";
		["content"] = {
			"Атаковал меня, пока я выполнял квесты",
			"Атаковал меня после того как я помог с заданием",
			"Помешал с выполнением цели задания",
			"Взял задание, которое мне нужно",
			"Убил NPC моей фракции",
			"Убил мастера заданий",
		};
	},
	[5] = {
		["title"] = "Украл ресурсы";
		["content"] = {
			"Собрал нужную мне траву",
			"Собрал нужную мне руду",
			"Собрал мои ресурсы",
			"Убил меня и украл мою цель или редкого НПС",
			"Снял шкуру с моей добычи",
			"Забрал мою награду",
			"Рыбачил в моей лунке",
		};
	},
	[6] = {
		["title"] = "Другое";
		["content"] = {
			"Ввел в режим PvP",
			"Сбросил меня с обрыва",
			"Использует инженерные хитрости",
			"Всегда умудряется сбежать",
			"Использует предметы и навыки, чтобы сбежать",
			"Использует уязвимости игровых механик",
			"Указать свою причину...",
		};
	},
}

-- Class descriptions
L["UNKNOWN"] = "Неизвестный"
L["DRUID"] = "Друид"
L["HUNTER"] = "Охотник"
L["MAGE"] = "Маг"
L["PALADIN"] = "Паладин"
L["PRIEST"] = "Жрец"
L["ROGUE"] = "Разбойник"
L["SHAMAN"] = "Шаман"
L["WARLOCK"] = "Чернокнижник"
L["WARRIOR"] = "Воин"
L["DEATHKNIGHT"] = "рыцарь смерти"
L["MONK"] = "Монах"
L["DEMONHUNTER"] = "Охотник на демонов"
L["EVOKER"] = "Пробудитель"

-- Race descriptions
L["Human"] = "Человек"
L["Orc"] = "Орк"
L["Dwarf"] = "Дворф"
L["Tauren"] = "Таурен"
L["Troll"] = "Тролль"
L["Night Elf"] = "Ночной эльф"
L["Undead"] = "Нежить"
L["Gnome"] = "Гном"
L["Blood Elf"] = "Эльф крови"
L["Draenei"] = "Дреней"
L["Goblin"] = "Гоблин"
L["Worgen"] = "Ворген"
L["Pandaren"] = "Пандарен"
L["Highmountain Tauren"] = "Таурен Крутогорья"
L["Lightforged Draenei"] = "Озаренный дреней"
L["Nightborne"] = "Ночнорожденный"
L["Void Elf"] = "Эльф Бездны"
L["Dark Iron Dwarf"] = "Дворф из клана Черного Железа"
L["Mag'har Orc"] = "Маг'хар"
L["Kul Tiran"] = "Култирасец"
L["Zandalari Troll"] = "Зандалар"
L["Mechagnome"] = "Механогном"
L["Vulpera"] = "Вульпера"
L["Dracthyr"] = "Драктир"
L["Earthen"] = "Земельник"

-- Stealth abilities
L["Stealth"] = "Незаметность"
L["Prowl"] = "Крадущийся зверь"
 
-- Minimap color codes
L["MinimapGuildText"] = "|cffffffff"
L["MinimapClassTextUNKNOWN"] = "|cff191919"
L["MinimapClassTextDRUID"] = "|cffff7c0a"
L["MinimapClassTextHUNTER"] = "|cffaad372"
L["MinimapClassTextMAGE"] = "|cff68ccef"
L["MinimapClassTextPALADIN"] = "|cfff48cba"
L["MinimapClassTextPRIEST"] = "|cffffffff"
L["MinimapClassTextROGUE"] = "|cfffff468"
L["MinimapClassTextSHAMAN"] = "|cff2359ff"
L["MinimapClassTextWARLOCK"] = "|cff9382c9"
L["MinimapClassTextWARRIOR"] = "|cffc69b6d"
L["MinimapClassTextDEATHKNIGHT"] = "|cffc41e3a"
L["MinimapClassTextMONK"] = "|cff00ff96"
L["MinimapClassTextDEMONHUNTER"] = "|cffa330c9"
L["MinimapClassTextEVOKER"] = "|cff33937f"

Spy_IgnoreList = {

};
 
