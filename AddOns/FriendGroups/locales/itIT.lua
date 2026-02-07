local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT IT ]] --
if GetLocale() ~= "itIT" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "Dimensione Lista"
L["SETTINGS_FILTER"]     = "Filtro"
L["SETTINGS_APPEARANCE"] = "Aspetto"
L["SETTINGS_BEHAVIOR"]   = "Comportamento"
L["SETTINGS_AUTOMATION"] = "Automazione"
L["SETTINGS_RESET"]      = "|cffff0000Reimposta Predefiniti|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "Piccolo (Default)"
L["SET_SIZE_MEDIUM"]     = "Medio"
L["SET_SIZE_LARGE"]      = "Grande"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "Nascondi Offline"
L["SET_HIDE_AFK"]        = "Nascondi AFK"
L["SET_MOBILE_AFK"]      = "Segna Mobile come AFK"
L["SET_HIDE_EMPTY"]      = "Nascondi Gruppi Vuoti"
L["SET_INGAME_ONLY"]     = "Solo Amici in Gioco"
L["SET_RETAIL_ONLY"]     = "Solo Amici Retail"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "Mostra Bandiere Reame"
L["SET_SHOW_REALM"]      = "Mostra Nome Reame"
L["SET_CLASS_COLOR"]     = "Usa Colori Classe"
L["SET_FACTION_ICONS"]   = "Mostra Icone Fazione"
L["SET_GRAY_FACTION"]    = "Oscura Fazione Opposta"
L["SET_SHOW_BTAG"]       = "Mostra Solo BattleTag"
L["SET_HIDE_MAX_LEVEL"]  = "Nascondi Livello Max"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "Abilita Gruppo Preferiti"
L["SET_COLLAPSE"]        = "Collassa Gruppi Auto"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "Accetta invito gruppo autom."
L["SET_AUTO_PARTY_SYNC"] = "Accetta Sincronia gruppo autom."
L["MSG_AUTO_INVITE"]     = "|cFF33FF99FriendGroups|r: %s ti invita in un gruppo. Accettazione autom. |cff00ff00ABILITATA|r"
L["MSG_AUTO_SYNC"]       = "|cFF33FF99FriendGroups|r: %s ti invita alla Sincronia. Accettazione autom. |cff00ff00ABILITATA|r"

-- Spirit Behavior Sub-Menu
L["SET_SPIRIT_HEADER"]   = "Comportamento Spirito"
L["SET_SPIRIT_NONE"]     = "Nessuno"
L["SET_SPIRIT_RES"]      = "Accetta resurrezione autom."
L["SET_SPIRIT_RELEASE"]  = "Rilascia Spirito autom."

L["MSG_AUTO_RES"]        = "|cFF33FF99FriendGroups|r: %s ti sta resuscitando. Accettazione autom. |cff00ff00ABILITATA|r"
L["MSG_AUTO_RELEASE"]    = "|cFF33FF99FriendGroups|r: Sei morto. Rilascio autom. |cff00ff00ABILITATO|r"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "Rinomina Gruppo"
L["MENU_REMOVE"]         = "Rimuovi Gruppo"
L["MENU_INVITE"]         = "Invita Gruppo"
L["MENU_MAX_40"]         = " (Max 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "Copia Nome-Reame"
L["DROP_COPY_BTAG"]      = "Copia BattleTag"
L["DROP_CREATE"]         = "Crea Nuovo Gruppo"
L["DROP_ADD"]            = "Aggiungi al Gruppo"
L["DROP_REMOVE"]         = "Rimuovi dal Gruppo"
L["DROP_CANCEL"]         = "Annulla"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "Inserisci nome gruppo"
L["POPUP_COPY"]          = "Premi Ctrl+C per copiare:"

L["SEARCH_PLACEHOLDER"]  = "Cerca FriendGroups"
L["SEARCH_TOOLTIP"]      = "FriendGroups: Cerca chiunque! Nome, Reame, Classe e anche Note"

L["MSG_WELCOME"]         = "Versione %s aggiornata per patch 12.0 da Osiris the Kiwi"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: Impostazioni ripristinate."
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: Bug API Bnet rilevato. La tua lista amici vuota è causata da un bug del client WoW. Riavvia il gioco. (Nessuna soluzione garantita)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[Preferiti]"
L["GROUP_NONE"]          = "[Nessun Gruppo]"
L["GROUP_EMPTY"]         = "La lista amici è vuota"
L["STATUS_MOBILE"]       = "Mobile"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "Ricarica FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Ricarica FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Ricarica l'UI per ripristinare FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups è Attivo|r\n\nA causa delle restrizioni di sicurezza Blizzard,\ndevi ricaricare per vedere le Case."
L["SHIELD_BTN_TEXT"]      = "Ricarica per vedere Case"
L["SAFE_MODE_WARNING"]    = "|cffFF0000ALLOGGI:|r FriendGroups disabilitato per vedere le Case. Ricarica per abilitare."