----------------------------------------------------------------------
--	Russian Localization

if GetLocale() ~= "ruRU" then return end
local ADDON_NAME, private = ...

local L = private.L

L = L or {}
L["BUTTON_SYNC"] = "Синхронизация"
L["CMD_DEBUGOFF"] = "отладчик_выкл"
L["CMD_DEBUGON"] = "отладчик_вкл"
L["CMD_DUMP"] = "дамп_босса"
L["CMD_HELP"] = "помощь"
L["CMD_HIDE"] = "скрыть"
L["CMD_LIST"] = "/loihloot ( %s | %s | %s | %s | %s )"
L["CMD_RESET"] = "сброс"
--[[Translation missing --]]
L["CMD_SAVENAMES"] = "savenames"
L["CMD_SHOW"] = "показать"
L["CMD_STATUS"] = "статус"
--[[Translation missing --]]
L["DISABLED"] = "Disabled"
--[[Translation missing --]]
L["DONT_NEED_LOOT_FROM_BOSS"] = "Don't need loot from this boss:"
--[[Translation missing --]]
L["ENABLED"] = "Enabled"
L["HELP_TEXT1"] = "Используйте /loihloot или /lloot со следующими командами:"
L["HELP_TEXT2"] = "- Показать окно LOIHLoot"
L["HELP_TEXT3"] = "- Скрыть окно LOIHLoot"
L["HELP_TEXT4"] = "- сбросить вишлист текущего персонажа"
L["HELP_TEXT5"] = "- показать статус LOIHLoot"
--[[Translation missing --]]
L["HELP_TEXT6"] = " - enable/disable saving player names per boss for LOIHLoot window"
L["HELP_TEXT7"] = "- показать помощь"
L["HELP_TEXT8"] = "Используйте команду без параметров чтобы показать/скрыть окно LOIHLoot."
L["LONG_MAINSPEC"] = "Основной спек"
L["LONG_OFFSPEC"] = "Дополнительный спек"
L["LONG_VANITY"] = "Декоративный предмет"
L["MAINTOOLTIP"] = "Предмет для основной специализации"
--[[Translation missing --]]
L["NEED_LOOT_FROM_BOSS"] = "Need loot from this boss:"
L["NEVER"] = "Никогда"
L["OFFTOOLTIP"] = "Предмет для дополнительной специализации"
L["PRT_DEBUG_FALSE"] = "%s отладчик выключен."
L["PRT_DEBUG_TRUE"] = "%s отладчик включён."
L["PRT_RESET_DONE"] = "Вишлист персонажа очищен."
--[[Translation missing --]]
L["PRT_SAVENAMES"] = "Save names per boss: %s"
L["PRT_STATUS"] = "%s использует %.0fКб оперативной памяти."
L["PRT_UNKOWN_DIFFICULTY"] = "ОШИБКА - Неопознаная сложность рейда! Запрос на синхронизацию не отправлен"
L["REMINDER"] = "Не забудьте наполнить вишлист персонажа из Путеводителя по приключениям (Используйте кнопки во вкладке \"Добыча\")."
L["SENDING_SYNC"] = "Попытка отправить зпрос на синхронизацию... Кнопка \"Синхронизация\" не активна 15 секунд."
L["SHORT_MAINSPEC"] = "О"
L["SHORT_OFFSPEC"] = "Д"
L["SHORT_SYNC_LINE"] = "Последняя синхронизация: %s"
L["SHORT_VANITY"] = "К"
L["SYNC_LINE"] = "Последняя синхронизация  (%s): %s (%d/%d членов рейда ответили)"
L["SYNCSTATUS_INCOMPLETE"] = "Состав рейда изменился с последней синхронизации!"
L["SYNCSTATUS_MISSING"] = "НЕТ синхронизации!"
L["SYNCSTATUS_OK"] = "Синхронизация УСПЕШНА!"
L["TAB_WISHLIST"] = "Вишлист"
L["TOOLTIP_WISHLIST_ADD"] = "Добавить в вишлист."
L["TOOLTIP_WISHLIST_HIGHER"] = "Понизить до этой сложности. В вишлисте уже есть этот предмет из большей сложности."
L["TOOLTIP_WISHLIST_LOWER"] = "Повысить до этой сложности. В вишлисте уже есть этот предмет из меньшей сложности."
L["TOOLTIP_WISHLIST_REM"] = "Удалить из вишлиста."
L["UNKNOWN"] = "Неизвестно"
L["VANITYTOOLTIP"] = "Декоративный предмет"
L["WISHLIST"] = "Вишлист"
