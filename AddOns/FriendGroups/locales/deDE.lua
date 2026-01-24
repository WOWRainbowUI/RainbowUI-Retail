local addonName, addonTable = ...
if GetLocale() ~= "deDE" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "Filter"
L["SETTINGS_APPEARANCE"] = "Aussehen"
L["SETTINGS_BEHAVIOR"] = "Gruppenverhalten"
L["SETTINGS_AUTOMATION"] = "Automatisierung"
L["SETTINGS_RESET"] = "|cffff0000Auf Standard zurücksetzen|r"

L["SET_HIDE_OFFLINE"] = "Alle Offline verbergen"
L["SET_HIDE_AFK"] = "Alle AFK verbergen"
L["SET_HIDE_EMPTY"] = "Leere Gruppen verbergen"
L["SET_INGAME_ONLY"] = "Nur Freunde im Spiel zeigen"
L["SET_RETAIL_ONLY"] = "Nur Retail-Freunde zeigen"
L["SET_CLASS_COLOR"] = "Klassenfarben für Namen nutzen"
L["SET_FACTION_ICONS"] = "Fraktions-Icons anzeigen"
L["SET_GRAY_FACTION"] = "Gegnerische Fraktion dimmen"
L["SET_SHOW_REALM"] = "Realm anzeigen"
L["SET_SHOW_BTAG"] = "Nur BattleTag anzeigen"
L["SET_HIDE_MAX_LEVEL"] = "Maximalstufe verbergen"
L["SET_MOBILE_AFK"] = "Mobile als AFK markieren"
L["SET_FAV_GROUP"] = "Favoritengruppe aktivieren"
L["SET_COLLAPSE"] = "Gruppen automatisch einklappen"
L["SET_AUTO_ACCEPT"] = "Gruppeneinladung auto-akzeptieren"

L["MENU_RENAME"] = "Gruppe umbenennen"
L["MENU_REMOVE"] = "Gruppe entfernen"
L["MENU_INVITE"] = "Gruppe einladen"
L["MENU_MAX_40"] = " (Max 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Name-Realm kopieren"
L["DROP_COPY_BTAG"] = "BattleTag kopieren"
L["DROP_CREATE"] = "Neue Gruppe erstellen"
L["DROP_ADD"] = "Zur Gruppe hinzufügen"
L["DROP_REMOVE"] = "Aus Gruppe entfernen"
L["DROP_CANCEL"] = "Abbrechen"

L["POPUP_ENTER_NAME"] = "Neuen Gruppennamen eingeben"
L["POPUP_COPY"] = "Drücke Strg+C zum Kopieren:"

L["GROUP_FAVORITES"] = "[Favoriten]"
L["GROUP_NONE"] = "[Keine Gruppe]"
L["GROUP_EMPTY"] = "Freundesliste ist leer"

L["STATUS_MOBILE"] = "Mobil"
L["SEARCH_PLACEHOLDER"] = "FriendGroups Suche"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Einstellungen zurückgesetzt."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Bnet API Fehler erkannt. Leere Freundesliste durch WoW Client Bug. Bitte Spiel neu starten."
L["MSG_WELCOME"] = "Version %s aktualisiert für Patch 12.0 von Osiris the Kiwi"

L["SEARCH_TOOLTIP"] = "FriendGroups: Suche nach allem! Name, Realm, Klasse und Notizen"

L["RELOAD_BTN_TEXT"]      = "FriendGroups neu laden"
L["RELOAD_TOOLTIP_TITLE"] = "FriendGroups neu laden"
L["RELOAD_TOOLTIP_DESC"]  = "Lädt das Interface neu, um FriendGroups wiederherzustellen."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups ist aktiv|r\n\nWegen Blizzard-Sicherheitsbeschränkungen\nmusst du neu laden, um Häuser zu sehen."
L["SHIELD_BTN_TEXT"]      = "Neu laden für Häuser"
L["SAFE_MODE_WARNING"]    = "|cffFF0000HÄUSER ANSEHEN:|r FriendGroups deaktiviert. Neu laden zum Aktivieren."