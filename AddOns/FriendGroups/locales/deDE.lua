local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT DE ]] --
if GetLocale() ~= "deDE" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "Kontaktlistengröße"
L["SETTINGS_FILTER"]     = "Filter"
L["SETTINGS_APPEARANCE"] = "Aussehen"
L["SETTINGS_BEHAVIOR"]   = "Gruppenverhalten"
L["SETTINGS_AUTOMATION"] = "Automatisierung"
L["SETTINGS_RESET"]      = "|cffff0000Standard wiederherstellen|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "Klein (WoW Standard)"
L["SET_SIZE_MEDIUM"]     = "Mittel"
L["SET_SIZE_LARGE"]      = "Groß"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "Alle Offline verstecken"
L["SET_HIDE_AFK"]        = "Alle AFK verstecken"
L["SET_MOBILE_AFK"]      = "Mobil als AFK markieren"
L["SET_HIDE_EMPTY"]      = "Leere Gruppen verstecken"
L["SET_INGAME_ONLY"]     = "Nur Freunde im Spiel zeigen"
L["SET_RETAIL_ONLY"]     = "Nur Retail-Freunde zeigen"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "Realm-Flaggen anzeigen"
L["SET_SHOW_REALM"]      = "Realm-Namen anzeigen"
L["SET_CLASS_COLOR"]     = "Klassenfarben verwenden"
L["SET_FACTION_ICONS"]   = "Fraktionssymbole anzeigen"
L["SET_GRAY_FACTION"]    = "Gegnerische Fraktion ausgrauen"
L["SET_SHOW_BTAG"]       = "Nur BattleTag anzeigen"
L["SET_HIDE_MAX_LEVEL"]  = "Max-Level verstecken"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "Favoritengruppe aktivieren"
L["SET_COLLAPSE"]        = "Gruppen auto-einklappen"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "Gruppeneinladung auto-annehmen"
L["SET_AUTO_PARTY_SYNC"] = "Party-Sync auto-annehmen"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "Gruppe umbenennen"
L["MENU_REMOVE"]         = "Gruppe entfernen"
L["MENU_INVITE"]         = "Gruppe einladen"
L["MENU_MAX_40"]         = " (Max 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "Name-Realm kopieren"
L["DROP_COPY_BTAG"]      = "BattleTag kopieren"
L["DROP_CREATE"]         = "Neue Gruppe erstellen"
L["DROP_ADD"]            = "Zur Gruppe hinzufügen"
L["DROP_REMOVE"]         = "Aus Gruppe entfernen"
L["DROP_CANCEL"]         = "Abbrechen"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "Neuen Gruppennamen eingeben"
L["POPUP_COPY"]          = "Drücke Strg+C zum Kopieren:"

L["SEARCH_PLACEHOLDER"]  = "FriendGroups Suche"
L["SEARCH_TOOLTIP"]      = "FriendGroups: Suche nach allem! Name, Realm, Klasse und sogar Notizen"

L["MSG_WELCOME"]         = "Version %s aktualisiert für Patch 12.0 von Osiris the Kiwi"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: Einstellungen zurückgesetzt."
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: Bnet API Bug erkannt. Deine leere Freundesliste wird durch einen WoW-Client-Fehler verursacht. Bitte starte das Spiel neu. (Keine garantierte Lösung)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[Favoriten]"
L["GROUP_NONE"]          = "[Keine Gruppe]"
L["GROUP_EMPTY"]         = "Freundesliste ist leer"
L["STATUS_MOBILE"]       = "Mobil"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "FriendGroups neu laden"
L["RELOAD_TOOLTIP_TITLE"] = "FriendGroups neu laden"
L["RELOAD_TOOLTIP_DESC"]  = "Lädt das UI neu, um FriendGroups wiederherzustellen."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups ist aktiv|r\n\nAufgrund von Blizzard-Sicherheitsbeschränkungen\nmust du neu laden, um Häuser zu sehen."
L["SHIELD_BTN_TEXT"]      = "Neu laden für Hausansicht"
L["SAFE_MODE_WARNING"]    = "|cffFF0000HÄUSER:|r FriendGroups für Hausansicht deaktiviert. Zum Aktivieren neu laden."