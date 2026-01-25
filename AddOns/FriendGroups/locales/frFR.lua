local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT FR ]] --
if GetLocale() ~= "frFR" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "Taille de la liste"
L["SETTINGS_FILTER"]     = "Filtre"
L["SETTINGS_APPEARANCE"] = "Apparence"
L["SETTINGS_BEHAVIOR"]   = "Comportement"
L["SETTINGS_AUTOMATION"] = "Automatisation"
L["SETTINGS_RESET"]      = "|cffff0000Réinitialiser|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "Petit (Défaut)"
L["SET_SIZE_MEDIUM"]     = "Moyen"
L["SET_SIZE_LARGE"]      = "Grand"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "Cacher les hors ligne"
L["SET_HIDE_AFK"]        = "Cacher les absents (AFK)"
L["SET_MOBILE_AFK"]      = "Marquer Mobile comme absent"
L["SET_HIDE_EMPTY"]      = "Cacher les groupes vides"
L["SET_INGAME_ONLY"]     = "Seulement amis en jeu"
L["SET_RETAIL_ONLY"]     = "Seulement amis Retail"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "Afficher drapeaux de royaume"
L["SET_SHOW_REALM"]      = "Afficher nom du royaume"
L["SET_CLASS_COLOR"]     = "Couleurs de classe"
L["SET_FACTION_ICONS"]   = "Icônes de faction"
L["SET_GRAY_FACTION"]    = "Griser faction opposée"
L["SET_SHOW_BTAG"]       = "Afficher BattleTag seul"
L["SET_HIDE_MAX_LEVEL"]  = "Cacher niveau max"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "Activer groupe favoris"
L["SET_COLLAPSE"]        = "Fermer groupes auto"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "Accepter invit. groupe auto"
L["SET_AUTO_PARTY_SYNC"] = "Accepter Sync. groupe auto"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "Renommer le groupe"
L["MENU_REMOVE"]         = "Supprimer le groupe"
L["MENU_INVITE"]         = "Inviter le groupe"
L["MENU_MAX_40"]         = " (Max 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "Copier Nom-Royaume"
L["DROP_COPY_BTAG"]      = "Copier BattleTag"
L["DROP_CREATE"]         = "Créer un nouveau groupe"
L["DROP_ADD"]            = "Ajouter au groupe"
L["DROP_REMOVE"]         = "Retirer du groupe"
L["DROP_CANCEL"]         = "Annuler"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "Entrez le nom du groupe"
L["POPUP_COPY"]          = "Ctrl+C pour copier :"

L["SEARCH_PLACEHOLDER"]  = "Recherche FriendGroups"
L["SEARCH_TOOLTIP"]      = "FriendGroups : Cherchez n'importe qui ! Nom, Royaume, Classe et même Notes"

L["MSG_WELCOME"]         = "Version %s mise à jour pour le patch 12.0 par Osiris the Kiwi"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r : Paramètres réinitialisés."
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r : Bug API Bnet détecté. Votre liste d'amis vide est causée par un bug du client WoW. Veuillez redémarrer le jeu. (Pas de solution garantie)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[Favoris]"
L["GROUP_NONE"]          = "[Aucun groupe]"
L["GROUP_EMPTY"]         = "La liste d'amis est vide"
L["STATUS_MOBILE"]       = "Mobile"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "Recharger FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Recharger FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Recharge l'interface pour restaurer FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups est Actif|r\n\nEn raison des restrictions Blizzard,\nvous devez recharger pour voir les maisons."
L["SHIELD_BTN_TEXT"]      = "Recharger pour voir les maisons"
L["SAFE_MODE_WARNING"]    = "|cffFF0000LOGEMENT :|r FriendGroups désactivé pour voir les maisons. Recharger pour activer."