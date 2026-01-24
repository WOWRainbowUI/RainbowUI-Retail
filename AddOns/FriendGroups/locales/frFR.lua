local addonName, addonTable = ...
if GetLocale() ~= "frFR" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "Filtre"
L["SETTINGS_APPEARANCE"] = "Apparence"
L["SETTINGS_BEHAVIOR"] = "Comportement de groupe"
L["SETTINGS_AUTOMATION"] = "Automatisation"
L["SETTINGS_RESET"] = "|cffff0000Réinitialiser|r"

L["SET_HIDE_OFFLINE"] = "Masquer hors ligne"
L["SET_HIDE_AFK"] = "Masquer les AFK"
L["SET_HIDE_EMPTY"] = "Masquer groupes vides"
L["SET_INGAME_ONLY"] = "Seulement amis en jeu"
L["SET_RETAIL_ONLY"] = "Seulement amis Retail"
L["SET_CLASS_COLOR"] = "Couleur de classe pour les noms"
L["SET_FACTION_ICONS"] = "Icônes de faction"
L["SET_GRAY_FACTION"] = "Griser faction adverse"
L["SET_SHOW_REALM"] = "Afficher le royaume"
L["SET_SHOW_BTAG"] = "Afficher seulement BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "Masquer niveau max"
L["SET_MOBILE_AFK"] = "Marquer Mobile comme AFK"
L["SET_FAV_GROUP"] = "Activer le groupe Favoris"
L["SET_COLLAPSE"] = "Repli automatique des groupes"
L["SET_AUTO_ACCEPT"] = "Accepter auto les invitations"

L["MENU_RENAME"] = "Renommer le groupe"
L["MENU_REMOVE"] = "Supprimer le groupe"
L["MENU_INVITE"] = "Inviter le groupe"
L["MENU_MAX_40"] = " (Max 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Copier Nom-Royaume"
L["DROP_COPY_BTAG"] = "Copier BattleTag"
L["DROP_CREATE"] = "Créer un nouveau groupe"
L["DROP_ADD"] = "Ajouter au groupe"
L["DROP_REMOVE"] = "Retirer du groupe"
L["DROP_CANCEL"] = "Annuler"

L["POPUP_ENTER_NAME"] = "Entrez le nom du groupe"
L["POPUP_COPY"] = "Appuyez sur Ctrl+C pour copier :"

L["GROUP_FAVORITES"] = "[Favoris]"
L["GROUP_NONE"] = "[Aucun groupe]"
L["GROUP_EMPTY"] = "La liste d'amis est vide"

L["STATUS_MOBILE"] = "Mobile"
L["SEARCH_PLACEHOLDER"] = "Recherche FriendGroups"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Paramètres réinitialisés."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Bug API Bnet détecté. Veuillez redémarrer le jeu."
L["MSG_WELCOME"] = "Version %s mise à jour pour le patch 12.0 par Osiris the Kiwi"

L["SEARCH_TOOLTIP"] = "FriendGroups: Cherchez n'importe qui ! Nom, Royaume, Classe et Notes"

L["RELOAD_BTN_TEXT"]      = "Recharger FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Recharger FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Recharge l'interface pour restaurer FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups est Actif|r\n\nEn raison des restrictions Blizzard,\nvous devez recharger pour voir les maisons."
L["SHIELD_BTN_TEXT"]      = "Recharger pour voir les maisons"
L["SAFE_MODE_WARNING"]    = "|cffFF0000VOIR MAISONS :|r FriendGroups désactivé. Recharger pour activer."