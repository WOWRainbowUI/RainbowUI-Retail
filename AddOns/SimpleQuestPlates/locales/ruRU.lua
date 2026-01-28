--=====================================================================================
-- RGX | Simple Quest Plates! - ruRU.lua
-- Version: 1.4.3
-- Author: DonnieDice
-- Description: Russian localization
--=====================================================================================

local addonName, SQP = ...
local locale = GetLocale()

if locale ~= "ruRU" then return end

local L = SQP.L or {}

-- Russian translations
L["OPTIONS_ENABLE"] = "Включить Simple Quest Plates"
L["OPTIONS_DISPLAY"] = "Настройки отображения"
L["OPTIONS_SCALE"] = "Размер иконки"
L["OPTIONS_OFFSET_X"] = "Горизонтальное смещение"
L["OPTIONS_OFFSET_Y"] = "Вертикальное смещение"
L["OPTIONS_ANCHOR"] = "Позиция иконки"
L["OPTIONS_TEST"] = "Тест определения"
L["OPTIONS_RESET"] = "Сбросить все настройки"
L["OPTIONS_FONT_SIZE"] = "Размер шрифта"
L["OPTIONS_FONT_OUTLINE"] = "Обводка текста"
L["OPTIONS_CUSTOM_COLORS"] = "Использовать пользовательские цвета"
L["OPTIONS_COLORS"] = "Цвета"
L["OPTIONS_COLOR_KILL"] = "Задания на убийство"
L["OPTIONS_COLOR_ITEM"] = "Задания на предметы"
L["OPTIONS_COLOR_PERCENT"] = "Задания на прогресс"
L["OPTIONS_ICON_STYLE"] = "Стиль иконки"
L["OPTIONS_ICON_TINT"] = "Включить окраску иконки"
L["OPTIONS_ICON_COLOR"] = "Цвет окраски иконки"

-- Commands
L["CMD_ENABLED"] = "теперь |cff00ff00ВКЛЮЧЕН|r"
L["CMD_DISABLED"] = "теперь |cffff0000ВЫКЛЮЧЕН|r"
L["CMD_VERSION"] = "Версия Simple Quest Plates: |cff58be81%s|r"
L["CMD_SCALE_SET"] = "Размер иконки установлен: |cff58be81%.1f|r"
L["CMD_SCALE_INVALID"] = "|cffff0000Неверное значение размера. Используйте число от 0.5 до 2.0|r"
L["CMD_OFFSET_SET"] = "Смещение иконки установлено: |cff58be81X=%d, Y=%d|r"
L["CMD_OFFSET_INVALID"] = "|cffff0000Неверные значения смещения. Используйте числа от -50 до 50|r"
L["CMD_RESET"] = "|cff58be81Все настройки сброшены на стандартные|r"
L["CMD_STATUS"] = "|cff58be81Статус Simple Quest Plates:|r"
L["CMD_STATUS_STATE"] = "  Состояние: %s"
L["CMD_STATUS_SCALE"] = "  Размер: |cff58be81%.1f|r"
L["CMD_STATUS_OFFSET"] = "  Смещение: |cff58be81X=%d, Y=%d|r"
L["CMD_STATUS_ANCHOR"] = "  Позиция: |cff58be81%s|r"
L["CMD_HELP_HEADER"] = "|cff58be81Команды Simple Quest Plates:|r"
L["CMD_HELP_ENABLE"] = "  |cfffff569/sqp on|r - Включить аддон"
L["CMD_HELP_DISABLE"] = "  |cfffff569/sqp off|r - Выключить аддон"
L["CMD_HELP_SCALE"] = "  |cfffff569/sqp scale <0.5-2.0>|r - Установить размер иконки"
L["CMD_HELP_OFFSET"] = "  |cfffff569/sqp offset <x> <y>|r - Установить смещение (-50 до 50)"
L["CMD_HELP_OPTIONS"] = "  |cfffff569/sqp options|r - Открыть панель настроек"
L["CMD_HELP_TEST"] = "  |cfffff569/sqp test|r - Тест определения заданий"
L["CMD_HELP_STATUS"] = "  |cfffff569/sqp status|r - Показать текущие настройки"
L["CMD_HELP_RESET"] = "  |cfffff569/sqp reset|r - Сбросить все настройки"
L["CMD_HELP_VERSION"] = "  |cfffff569/sqp version|r - Показать версию аддона"
L["CMD_HELP_HELP"] = "  |cfffff569/sqp help|r - Показать это меню помощи"
L["CMD_TEST"] = "Тестирование определения заданий..."
L["CMD_OPTIONS_OPENED"] = "Панель настроек открыта"

-- Quest Detection
L["QUEST_PROGRESS_KILL"] = "Убить: %d/%d"
L["QUEST_PROGRESS_ITEM"] = "Собрать: %d/%d"
L["QUEST_TEST_ACTIVE"] = "Найдено активных целей заданий: %d"
L["QUEST_TEST_NONE"] = "Активные цели заданий не найдены"

-- Messages
L["MSG_LOADED"] = "v%s успешно загружен. Введите |cfffff569/sqp help|r для команд."
L["MSG_DISCORD"] = "Присоединяйтесь к нашему Discord: |cff58be81discord.gg/N7kdKAHVVF|r"