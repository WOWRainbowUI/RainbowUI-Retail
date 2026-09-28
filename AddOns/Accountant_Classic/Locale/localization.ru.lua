-- $Id: localization.ru.lua 422 2026-09-19 09:20:34Z arithmandar $ 
-- Thanks to Narumar and unw1s3
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "ruRU", false)

if not L then return end

-- Header
L["Accountant Classic"] = "Accountant Classic"
L["A basic tool to track your monetary incomings and outgoings within WoW."] = "Основной инструмент для отслеживания ваших денежных доходах и расходах в WoW."
L[ [=[Left-Click to open Accountant Classic.
Right-Click for Accountant Classic options.
Left-click and drag to move this button.]=] ] = [=[[ЛКМ] для открытия Accountant Classic.
[ПКМ], чтобы открыть настройки Accountant Classic.
Держите [ЛКМ], чтобы двигать эту кнопку.]=]
L[ [=[Left-click and drag to move this button.
Right-Click to open Accountant Classic.]=] ] = [=[[ЛКМ] держите, чтобы переместить эту кнопку.
[ПКМ] для открытия Accountant Classic.]=]
L["Total Incomings"] = "Всего доходов"
L["Total Outgoings"] = "Всего расходов"
L["Net Profit / Loss"] = "Чистая прибыль / Убыток"
L["Net Loss"] = "Чистый убыток"
L["Net Profit"] = "Чистый доход"
L["Source"] = "Источник"
L["Incomings"] = "Доходы"
L["Outgoings"] = "Расходы"
L["Week Start"] = "Начало недели"
L["Sum Total"] = "Итого"
L["Character"] = "Персонаж"
L["Money"] = "Золото"
L["Updated"] = "Обновлено"

-- Section Labels
L["Quest Rewards"] = "Награда за задание"
L["Merchants"] = "Торговцы"
L["Trade Window"] = "Обмен"
L["Mail"] = "Почта"
L["Training Costs"] = "Расходы на обучение"
L["Taxi Fares"] = "Распорядитель полетов"
L["Unknown"] = "Неизвестно откуда"
L["Repair Costs"] = "Затраты на ремонт"
L["LFD, LFR and Scen."] = "LFD, LFR и Сцен."

-- Buttons
L["Reset"] = "Сбросить"
L["Options"] = "Параметры"
L["Exit"] = "Выход"

-- Tabs' name
L["This Session"] = "Эта сессия"
L["Today"] = "Cегодня"
L["Prv. Day"] = "Вчера"
L["This Week"] = "Эта неделя"
L["Prv. Week"] = "Пред. неделя"
L["This Month"] = "Этот месяц"
L["Prv. Month"] = "Пред. месяц"
L["This Year"] = "Этот год"
L["Prv. Year"] = "Пред. год"
L["Total"] = "Всего"
L["All Chars"] = "Все персонажи"

-- Tabs' tooltip
L["TT1"] = "Эта сессия"
L["TT2"] = "Сегодня"
L["TT3"] = "Вчера"
L["TT4"] = "Эта неделя"
L["TT5"] = "Пред. неделя"
L["TT6"] = "Этот месяц"
L["TT7"] = "Пред. месяц"
L["TT8"] = "Этот год"
L["TT9"] = "Пред. год"
L["TT10"] = "Всего"
L["TT11"] = "Все персонажи"

-- Options
L["Accountant Classic Options"] = "Параметры Accountant Classic"
L["Show minimap button"] = "Показывать значок у мини-карты"
L["Show money"] = "Показать золото"
L["Show money on minimap button's tooltip"] = "Показывать золото в кнопки на мини-карте"
L["Show session info"] = "Показать информацию о сеансе"
L["Show session info on minimap button's tooltip"] = "Показать информация о сеансе в подсказке кнопки на мини-карты"
L["Show money on screen"] = "Показывать золото на экране"
L["Reset position"] = "Сброс позиции"
L["Reset money frame's position"] = "Cбросить положение рамки золота"
L["Minimap Button Settings"] = "Настройки кнопки мини-карты"
L["Minimap Button Position"] = "Позиция на мини-карте"
L["Start of Week"] = "Начало недели"
L["Done"] = "Готово"
L["Display Instruction Tips"] = "Показать советы по эксплуатации"
L["Toggle whether to display minimap button or floating money frame's operation tips."] = "Переключение, отображения кнопки на мини-карте или всплывающие подсказки для операций с плавающей рамкой золота."
L["Select the character to be removed:"] = "Выберите персонажа, который будет удален:"
L["The selected character's Accountant Classic data will be removed."] = "Выбранные в Accountant Classic персонажи, данные будут удалены."
L["|cffffffff\"%s - %s|cffffffff\" character's Accountant Classic data has been removed."] = "|cffffffff\"%s - %s|cffffffff\" данные персонажей Accountant Classic были удалены."
L["Select the date format:"] = "Выберите формат даты:"
L["Date format showing in \"All Chars\" and \"Week\" tabs"] = "Отображение формата даты в \"Все перс.\" и \"Неделя\" в вкладки"
L["Show net income / expanse on LDB"] = "Показывать чистый доход / расход на LDB"
L["Show current session's net income / expanse instead of total money on LDB"] = "Показать чистую прибыль / расходы, на текущею сессию, вместо общих денег на LDB"
L["Show all realms' characters info"] = "Показать информацию о персонажах всех миров"
L["Enable to show all characters' money info from all realms. Disable to only show current realm's character info."] = "Если включено, отображает информацию о золоте всех персонажей изо всех миров. Отключить, чтобы показывать только информацию о персонаже текущей мира."
L["Track location of incoming / outgoing money"] = "Отслеживание местоположения входящих / исходящих золотых"
L["Enable to track the location of each incoming / outgoing money and also show the breakdown info while mouse hover each of the expenditure."] = "Включить отслеживание расположения каждого входящего / исходящего золота, а также показать информацию о разбивке при наведении указателя мыши на каждый из расходов."
L["Also track subzone info"] = "Также отслеживать информацию о подзоне"
L["Enable to also track on the subzone info. For example: Suramar - Sanctum of Order"] = "Включить, чтобы также отслеживать информацию о подзоне. Для примера: Сурамар - Святилище Порядка"
L["Converts a number into a localized string, grouping digits as required."] = "Конвертирует числа в локализованную строку, группируя цифры по мере необходимости."
L["Accountant Classic Frame's Scale"] = "Рамка масштаба Accountant Classic"
L["Accountant Classic Frame's Transparency"] = "Рамка прозрачности Accountant Classic"
L["Accountant Classic Floating Info's Scale"] = "Масштаб Accountant Classic для плавающий информации"
L["Accountant Classic Floating Info's Transparency"] = "Прозрачность Accountant Classic для плавающий информации"
L["LDB Display Settings"] = "Настройки дисплея LDB"
L["LDB Display Type"] = "Тип дисплея LDB"
L["Data type to be displayed on LDB"] = "Тип данных, который будет отображаться на LDB"
L["General and Data Display Format Settings"] = "Общие настройки и формат отображения данных"
L["Main Frame's Scale and Alpha Settings"] = "Масштаб основной рамки и настройки прозрачности"
L["Onscreen Actionbar's Scale and Alpha Settings"] = "Масштаб на экране панели действий и настройки прозрачности"
L["Character Data's Removal"] = "Удаление данных персонажа"
L["Profile Options"] = "Параметры профиля"
L["Scale and Transparency"] = "Масштаб и прозрачность"
L["Remember character selected"] = "Запомнить выбранного персонажа"
L["Remember the latest character selection in dropdown menu."] = "Запомнить последнего, выбранного персонажа в раскрывающемся меню."
L["Show all factions' characters info"] = "Показать информацию персонажей всех фракций"
L["Enable to show all characters' money info from all factions. Disable to only show all characters' info from current faction."] = "Включить, чтобы показать информацию о всех персонажах всех фракций. Отключить отображение всех персонажей из текущей фракции."
L["Enhanced Tracking Options"] = "Расширенные параметры отслеживания"
L["All Factions"] = "Все фракции"
L["All Servers"] = "Все сервера"

-- Misc
L["Are you sure you want to reset the \"%s\" data?"] = "Вы уверены, что хотите сбросить данные \"%s\" ?"
L["New Accountant Classic profile created for %s"] = "Новый Accountant Classic профиль создан для %s"
L["Loaded Accountant Classic Profile for %s"] = "Загрузить профиль Accountant Classic для %s"
L["Accountant Classic loaded."] = "Accountant Classic загружен."
L["g "] = " зол. "
L["s "] = " сер. "
L["c"] = " м. "
L["About"] = "Об Аддоне"
L["Show All Characters"] = "Показать всех персонажей"
L["Show all characters' incoming and outgoing data."] = "Показывать входящие и исходящие данные всех персонажей."

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) Золота"
L["(%d+) Silver"] = "(%d+) Серебра"
L["(%d+) Copper"] = "(%d+) Меди"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Привязки Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Крепление Accountant Classic"
