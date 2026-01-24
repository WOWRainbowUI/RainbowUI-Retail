local addonName, addonTable = ...
if GetLocale() ~= "itIT" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "Filtro"
L["SETTINGS_APPEARANCE"] = "Aspetto"
L["SETTINGS_BEHAVIOR"] = "Comportamento Gruppo"
L["SETTINGS_AUTOMATION"] = "Automazione"
L["SETTINGS_RESET"] = "|cffff0000Ripristina Default|r"

L["SET_HIDE_OFFLINE"] = "Nascondi Offline"
L["SET_HIDE_AFK"] = "Nascondi AFK"
L["SET_HIDE_EMPTY"] = "Nascondi Gruppi Vuoti"
L["SET_INGAME_ONLY"] = "Solo Amici in Gioco"
L["SET_RETAIL_ONLY"] = "Solo Amici Retail"
L["SET_CLASS_COLOR"] = "Usa Colori Classe"
L["SET_FACTION_ICONS"] = "Mostra Icone Fazione"
L["SET_GRAY_FACTION"] = "Oscura Fazione Opposta"
L["SET_SHOW_REALM"] = "Mostra Reame"
L["SET_SHOW_BTAG"] = "Mostra Solo BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "Nascondi Livello Max"
L["SET_MOBILE_AFK"] = "Segna Mobile come AFK"
L["SET_FAV_GROUP"] = "Abilita Gruppo Preferiti"
L["SET_COLLAPSE"] = "Chiudi Gruppi Automaticamente"
L["SET_AUTO_ACCEPT"] = "Accetta Inviti Automaticamente"

L["MENU_RENAME"] = "Rinomina Gruppo"
L["MENU_REMOVE"] = "Rimuovi Gruppo"
L["MENU_INVITE"] = "Invita Gruppo"
L["MENU_MAX_40"] = " (Max 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Copia Nome-Reame"
L["DROP_COPY_BTAG"] = "Copia BattleTag"
L["DROP_CREATE"] = "Crea Nuovo Gruppo"
L["DROP_ADD"] = "Aggiungi al Gruppo"
L["DROP_REMOVE"] = "Rimuovi dal Gruppo"
L["DROP_CANCEL"] = "Annulla"

L["POPUP_ENTER_NAME"] = "Inserisci nome gruppo"
L["POPUP_COPY"] = "Premi Ctrl+C per copiare:"

L["GROUP_FAVORITES"] = "[Preferiti]"
L["GROUP_NONE"] = "[Nessun Gruppo]"
L["GROUP_EMPTY"] = "Lista Amici vuota"

L["STATUS_MOBILE"] = "Mobile"
L["SEARCH_PLACEHOLDER"] = "Cerca FriendGroups"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Impostazioni ripristinate."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Bug API Bnet rilevato. Riavvia il gioco."
L["MSG_WELCOME"] = "Versione %s aggiornata per patch 12.0 da Osiris the Kiwi"

L["SEARCH_TOOLTIP"] = "FriendGroups: Cerca chiunque! Nome, Reame, Classe e Note"

L["RELOAD_BTN_TEXT"]      = "Ricarica FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Ricarica FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Ricarica l'UI per ripristinare FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups è Attivo|r\n\nA causa restrizioni Blizzard,\ndevi ricaricare per vedere le case."
L["SHIELD_BTN_TEXT"]      = "Ricarica per Case"
L["SAFE_MODE_WARNING"]    = "|cffFF0000VEDI CASE:|r FriendGroups disabilitato. Ricarica per abilitare."