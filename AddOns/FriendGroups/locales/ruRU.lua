local addonName, addonTable = ...
if GetLocale() ~= "ruRU" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "Фильтр"
L["SETTINGS_APPEARANCE"] = "Внешний вид"
L["SETTINGS_BEHAVIOR"] = "Поведение групп"
L["SETTINGS_AUTOMATION"] = "Автоматизация"
L["SETTINGS_RESET"] = "|cffff0000Сброс настроек|r"

L["SET_HIDE_OFFLINE"] = "Скрыть всех офлайн"
L["SET_HIDE_AFK"] = "Скрыть всех AFK"
L["SET_HIDE_EMPTY"] = "Скрыть пустые группы"
L["SET_INGAME_ONLY"] = "Только друзья в игре"
L["SET_RETAIL_ONLY"] = "Только друзья Retail"
L["SET_CLASS_COLOR"] = "Имена цветом класса"
L["SET_FACTION_ICONS"] = "Значки фракций"
L["SET_GRAY_FACTION"] = "Затенить вражд. фракцию"
L["SET_SHOW_REALM"] = "Показать игровой мир"
L["SET_SHOW_BTAG"] = "Только BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "Скрыть макс. уровень"
L["SET_MOBILE_AFK"] = "Пометить Mobile как AFK"
L["SET_FAV_GROUP"] = "Включить группу Избранное"
L["SET_COLLAPSE"] = "Автосворачивание групп"
L["SET_AUTO_ACCEPT"] = "Автоприем приглашений"

L["MENU_RENAME"] = "Переименовать группу"
L["MENU_REMOVE"] = "Удалить группу"
L["MENU_INVITE"] = "Пригласить группу"
L["MENU_MAX_40"] = " (Макс 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Копировать Имя-Сервер"
L["DROP_COPY_BTAG"] = "Копировать BattleTag"
L["DROP_CREATE"] = "Создать новую группу"
L["DROP_ADD"] = "Добавить в группу"
L["DROP_REMOVE"] = "Удалить из группы"
L["DROP_CANCEL"] = "Отмена"

L["POPUP_ENTER_NAME"] = "Введите имя группы"
L["POPUP_COPY"] = "Нажмите Ctrl+C для копирования:"

L["GROUP_FAVORITES"] = "[Избранное]"
L["GROUP_NONE"] = "[Без группы]"
L["GROUP_EMPTY"] = "Список друзей пуст"

L["STATUS_MOBILE"] = "Мобильный"
L["SEARCH_PLACEHOLDER"] = "Поиск FriendGroups"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Настройки сброшены."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Обнаружена ошибка Bnet API. Пожалуйста, перезапустите игру."
L["MSG_WELCOME"] = "Версия %s обновлена для патча 12.0 от Osiris the Kiwi"

L["SEARCH_TOOLTIP"] = "FriendGroups: Поиск по всем! Имя, Сервер, Класс и Заметки"

L["RELOAD_BTN_TEXT"]      = "Перезагрузить FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Перезагрузить FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Перезагружает интерфейс для восстановления FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups Активен|r\n\nИз-за ограничений Blizzard,\nнужно перезагрузить UI для просмотра домов."
L["SHIELD_BTN_TEXT"]      = "Перезагр. для просмотра домов"
L["SAFE_MODE_WARNING"]    = "|cffFF0000ДОМА:|r FriendGroups отключен для просмотра домов. Перезагрузите для включения."