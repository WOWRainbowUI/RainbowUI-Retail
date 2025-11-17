if (GetLocale() ~= "frFR") then
	return;
end
-- à = \195\160
-- â = \195\162
-- æ = \195\166
-- ç = \195\167
-- è = \195\168
-- é = \195\169
-- ê = \195\170
-- ï = \195\175
-- î = \195\174
-- ô = \195\180
-- ù = \195\185
-- Œ = \197\146
-- œ = \197\147
-- É = \195\137
-- À = \195\128
-- @EXACT = true: Translation has to be the exact(!) match in the clients language,
--                beacause it carries technical semantics
-- @EXACT = false: Translation can be done freely, because text is only descriptive
-- Class Names
-- @EXACT = false
VUHDO_I18N_WARRIORS="Guerriers"
VUHDO_I18N_ROGUES = "Voleurs";
VUHDO_I18N_HUNTERS = "Chasseurs";
VUHDO_I18N_PALADINS = "Paladins";
VUHDO_I18N_MAGES = "Mages";
VUHDO_I18N_WARLOCKS = "D\195\169monistes";
VUHDO_I18N_SHAMANS = "Shamans";
VUHDO_I18N_DRUIDS = "Druides";
VUHDO_I18N_PRIESTS = "Pr\195\170tres";
VUHDO_I18N_DEATH_KNIGHT = "Chevaliers de la Mort";
VUHDO_I18N_MONKS = "Monks";
-- Group Model Names
-- @EXACT = false
VUHDO_I18N_GROUP = "Groupe";
VUHDO_I18N_OWN_GROUP = "Mon Groupe";
-- Special Model Names
-- @EXACT = false
VUHDO_I18N_PETS = "Familiers";
VUHDO_I18N_MAINTANKS = "Tanks \nprincipaux";
VUHDO_I18N_PRIVATE_TANKS = "Cibles personalis\195\169es";
-- General Labels
-- @EXACT = false
VUHDO_I18N_OKAY = "Valider";
VUHDO_I18N_CLASS = "Classe";
VUHDO_I18N_PLAYER = "Joueur";
-- VuhDoTooltip.lua
-- @EXACT = false
VUHDO_I18N_TT_POSITION = "|cffffb233Position:|r";
VUHDO_I18N_TT_GHOST = "<GHOST>";
VUHDO_I18N_TT_DEAD = "<DEAD>";
VUHDO_I18N_TT_AFK = "<AFK>";
VUHDO_I18N_TT_DND = "<DND>";
VUHDO_I18N_TT_LIFE = "|cffffb233Vie:|r ";
VUHDO_I18N_TT_MANA = "|cffffb233Mana:|r ";
VUHDO_I18N_TT_LEVEL = "Niveau ";
-- VuhDoPanel.lua
-- @EXACT = false
VUHDO_I18N_CHOOSE = "Choisir";
VUHDO_I18N_DRAG = "Glisser";
VUHDO_I18N_REMOVE = "Supprimer";
VUHDO_I18N_ME = "moi!";
VUHDO_I18N_TYPE = "Type";
VUHDO_I18N_VALUE = "Valeur";
VUHDO_I18N_SPECIAL = "Special";
VUHDO_I18N_BUFF_ALL = "tous";
VUHDO_I18N_SHOW_BUFF_WATCH = "Montrer le suivi des buffs";
-- Heal Spell Names
-- @EXACT = true
--
-- Chat messages
-- @EXACT = false
VUHDO_I18N_COMMAND_LIST = "\n|cffffe566 - [ Commandes VuhDo ] -|r\n" ..
"|cffffe566opt|r[ions] - Options de VuhDo\n" ..
"|cffffe566res|r[et] - R\\195\\169initialiser la position des panneaux\n" ..
"|cffffe566lock|r - Verrouiller/D\\195\\169verrouiller les panneaux\n" ..
"|cffffe566mm, map, minimap|r - Afficher/Masquer l'ic\\195\\180ne de la minicarte\n" ..
"|cffffe566compart|r[ment] - Afficher/Masquer l'ic\\195\\180ne du compartiment d'addon\n" ..
"|cffffe566show, hide, toggle|r - Afficher/Masquer les panneaux\n" ..
"|cffffe566load|r - [Profil],[Assignation de touche]\n" ..
"[broad]|cffffe566cast, mt|r[s] - Annoncer les tanks principaux\n" ..
"|cffffe566role|r - R\\195\\169initialiser les r\\195\\180les des joueurs\n" ..
"|cffffe566ab|r[out] - A propos de cet addon\n" ..
"|cffffe566help,?|r - Liste des commandes\n";
VUHDO_I18N_BAD_COMMAND = "Commande inconnue! Taper '/vuhdo help' or '/vd ?' pour la liste des commandes.";
VUHDO_I18N_CHAT_SHOWN = "|cffffe566visible|r.";
VUHDO_I18N_CHAT_HIDDEN = "|cffffe566cach\195\169|r.";
VUHDO_I18N_MM_ICON = "L'ic\195\180ne sur la minimap est maintenant ";
VUHDO_I18N_MTS_BROADCASTED = "Les tanks principaux ont \195\169t\195\169 diffus\195\169s \195\160 l'ensemble du raid";
VUHDO_I18N_PANELS_SHOWN = "Les panneaux de soins sont maintenant |cffffe566shown|r.";
VUHDO_I18N_PANELS_HIDDEN = "Les panneaux de soins sont maintenant |cffffe566hidden|r.";
VUHDO_I18N_LOCK_PANELS_PRE = "La position des panneaux est maintenant ";
VUHDO_I18N_LOCK_PANELS_LOCKED = "|cffffe566v\195\169rouill\195\169|r.";
VUHDO_I18N_LOCK_PANELS_UNLOCKED = "|cffffe566d\195\169v\195\169rouill\195\169|r.";
VUHDO_I18N_PANELS_RESET = "La position des panneaux a \195\169t\195\169 r\195\169initialis\195\169e.";
-- Config Pop-Up
-- @EXACT = false
VUHDO_I18N_ROLE = "R\195\180le";
VUHDO_I18N_PRIVATE_TANK = "Cibles personalis\195\169es";
VUHDO_I18N_SET_BUFF = "D\195\169finir les buff";
-- Minimap
-- @EXACT = false
VUHDO_I18N_VUHDO_OPTIONS = "Options de VuhDo";
VUHDO_I18N_PANEL_SETUP = "Options";
VUHDO_I18N_MM_TOOLTIP = "Gauche: D\195\169finition des Panneaux\nDroite: Menu";
VUHDO_I18N_TOGGLES = "Etats";
VUHDO_I18N_LOCK_PANELS = "V\195\169rouiller Panels";
VUHDO_I18N_SHOW_PANELS = "Afficher les panneaux";
VUHDO_I18N_MM_BUTTON = "Bouton de la minimap";
VUHDO_I18N_CLOSE = "Fermer";
VUHDO_I18N_BROADCAST_MTS = "Diffuser les MTs";
-- Buff categories
-- @EXACT = false
-- Priest
-- Shaman
VUHDO_I18N_BUFFC_FIRE_TOTEM = "Totem de feu";
VUHDO_I18N_BUFFC_AIR_TOTEM = "Totem d'air";
VUHDO_I18N_BUFFC_EARTH_TOTEM = "Totem de terre";
VUHDO_I18N_BUFFC_WATER_TOTEM = "Totem d'eau";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT = "Enchantement d'arme";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_2 = "Enchantement d'arme 2";
VUHDO_I18N_BUFFC_SHIELDS = "Boucliers";
-- Paladin
VUHDO_I18N_BUFFC_BLESSING = "B\195\169n\195\169diction";
VUHDO_I18N_BUFFC_SEAL = "Sceau";
-- Druids
-- Warlock
VUHDO_I18N_BUFFC_SKIN = "Peau";
-- Mage
VUHDO_I18N_BUFFC_ARMOR_MAGE = "Armure";
-- Death Knight
VUHDO_BUFFC_PRESENCE    = "Pr\195\169sence";
-- Warrior
VUHDO_I18N_BUFFC_SHOUT = "Cri";
-- Hunter
VUHDO_I18N_BUFFC_ASPECT = "Aspect";
-- Monk
VUHDO_I18N_BUFFC_STANCE = "Stance";

-- Key Binding Headers/Names
-- @EXACT = false
BINDING_HEADER_VUHDO_TITLE = "VuhDo - Raid Frames";
BINDING_NAME_VUHDO_KEY_ASSIGN_1 = "Mouse over - Sort 1";
BINDING_NAME_VUHDO_KEY_ASSIGN_2 = "Mouse over - Sort 2";
BINDING_NAME_VUHDO_KEY_ASSIGN_3 = "Mouse over - Sort 3";
BINDING_NAME_VUHDO_KEY_ASSIGN_4 = "Mouse over - Sort 4";
BINDING_NAME_VUHDO_KEY_ASSIGN_5 = "Mouse over - Sort 5";
BINDING_NAME_VUHDO_KEY_ASSIGN_6 = "Mouse over - Sort 6";
BINDING_NAME_VUHDO_KEY_ASSIGN_7 = "Mouse over - Sort 7";
BINDING_NAME_VUHDO_KEY_ASSIGN_8 = "Mouse over - Sort 8";
BINDING_NAME_VUHDO_KEY_ASSIGN_9 = "Mouse over - Sort 9";
BINDING_NAME_VUHDO_KEY_ASSIGN_10 = "Mouse over - Sort 10";
BINDING_NAME_VUHDO_KEY_ASSIGN_11 = "Mouse over - Sort 11";
BINDING_NAME_VUHDO_KEY_ASSIGN_12 = "Mouse over - Sort 12";
BINDING_NAME_VUHDO_KEY_ASSIGN_13 = "Mouse over - Sort 13";
BINDING_NAME_VUHDO_KEY_ASSIGN_14 = "Mouse over - Sort 14";
BINDING_NAME_VUHDO_KEY_ASSIGN_15 = "Mouse over - Sort 15";
BINDING_NAME_VUHDO_KEY_ASSIGN_16 = "Mouse over - Sort 16";
BINDING_NAME_VUHDO_KEY_ASSIGN_SMART_BUFF = "Buff Intelligent";
VUHDO_I18N_MOUSE_OVER_BINDING = "Raccourcis clavier";
VUHDO_I18N_UNASSIGNED = "(non assign\195\169)";
-- #+V1.89
VUHDO_I18N_NO = "No";
VUHDO_I18N_UP = "up";
VUHDO_I18N_VEHICLES = "Vehicles";
-- #+v1.94
VUHDO_I18N_DEFAULT_RES_ANNOUNCE = "Come to life, vuhdo, you b00n!";
-- #v+1.151
VUHDO_I18N_MAIN_ASSISTS = "Main Assists";
-- #+v1.184
VUHDO_I18N_BW_CD = "CD";
VUHDO_I18N_BW_GO = "GO!";
VUHDO_I18N_BW_LOW = "LOW";
VUHDO_I18N_BW_N_A = "|cffff0000N/A|r";
VUHDO_I18N_BW_RNG_RED = "|cffff0000RNG|r";
VUHDO_I18N_BW_OK = "OK";
VUHDO_I18N_BW_RNG_YELLOW = "|cffffff00RNG|r";
VUHDO_I18N_PROMOTE_RAID_LEADER = "Promote to Raid Leader";
VUHDO_I18N_PROMOTE_ASSISTANT = "Promote to Assistant";
VUHDO_I18N_DEMOTE_ASSISTANT = "Demote from Assistant";
VUHDO_I18N_PROMOTE_MASTER_LOOTER = "Promote to Master Looter";
VUHDO_I18N_MT_NUMBER = "MT #";
VUHDO_I18N_ROLE_OVERRIDE = "Remplacement de rôle";
VUHDO_I18N_MELEE_TANK = "M\195\169l\195\169e - Tank";
VUHDO_I18N_MELEE_DPS = "M\195\169l\195\169e - DPS";
VUHDO_I18N_RANGED_DPS = "\195\128 distance - DPS";
VUHDO_I18N_RANGED_HEALERS = "\195\128 distance - Soigneur";
VUHDO_I18N_AUTO_DETECT = "<auto detect>";
VUHDO_I18N_PROMOTE_ASSIST_MSG_1 = "Promoted |cffffe566";
VUHDO_I18N_PROMOTE_ASSIST_MSG_2 = "|r to assistant.";
VUHDO_I18N_DEMOTE_ASSIST_MSG_1 = "Demoted |cffffe566";
VUHDO_I18N_DEMOTE_ASSIST_MSG_2 = "|r from assistant.";
VUHDO_I18N_RESET_ROLES = "R\195\169initialiser les r\195\180les";
VUHDO_I18N_LOAD_KEY_SETUP = "Charger la configuration des touches";
VUHDO_I18N_BUFF_ASSIGN_1 = "Buff |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_2 = "|r a \195\169t\195\169 assign\195\169 \195\160 |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_3 = "|r";
VUHDO_I18N_MACRO_KEY_ERR_1 = "ERREUR : La taille de la macro souris-clavier d\195\169passe la limite pour le sort : ";
VUHDO_I18N_MACRO_KEY_ERR_2 = "/256 caract\195\168res). Essayez de r\195\169duire les options de tir automatique !!!";
VUHDO_I18N_MACRO_NUM_ERR = "Nombre maximum de macros par personnage d\195\169pass\195\169 ! Impossible de cr\195\169er une macro souris pour : ";
VUHDO_I18N_SMARTBUFF_ERR_1 = "VuhDo : Impossible d'appliquer un buff intelligent en combat !";
VUHDO_I18N_SMARTBUFF_ERR_2 = "VuhDo : Aucune cible de buff disponible pour ";
VUHDO_I18N_SMARTBUFF_ERR_3 = " joueurs hors de port\195\169e pour ";
VUHDO_I18N_SMARTBUFF_ERR_4 = "VuhDo : Aucun buff \195\160 lancer.";
VUHDO_I18N_SMARTBUFF_OKAY_1 = "VuhDo : Application d'un buff sur |cffffffff";
VUHDO_I18N_SMARTBUFF_OKAY_2 = "|r sur ";
-- #+v1.189
VUHDO_I18N_UNKNOWN = "inconnu";
VUHDO_I18N_SELF = "Soi-m\195\170me";
VUHDO_I18N_MELEES = "M\195\169l\195\169es";
VUHDO_I18N_RANGED = "\195\137 distance";
VUHDO_I18N_OPTIONS_NOT_LOADED = ">>> Le plugin Options de VuhDo n'est pas charg\195\169 ! <<<";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 = "Erreur : La disposition de sort \"";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2 = "\" n'existe pas.";
VUHDO_I18N_AUTO_ARRANG_1 = "Le nombre de membres du groupe est pass\195\169 \195\160 ";
VUHDO_I18N_AUTO_ARRANG_2 = ". Engagement automatique de l'arrangement : \"";
VUHDO_I18N_TRACK_BUFFS_FOR = "Suivre les buffs pour ...";
VUHDO_I18N_OWN_GROUP_LONG = "Mon groupe";
VUHDO_I18N_NO_FOCUS = "[pas de focus]";
VUHDO_I18N_NOT_AVAILABLE = "[ N/A ]";
VUHDO_I18N_TT_DISTANCE = "|cffffb233Distance :|r";
VUHDO_I18N_TT_OF = " de ";
VUHDO_I18N_YARDS = "yards";
-- #+1.252
VUHDO_I18N_PANEL = "Panneau";
VUHDO_I18N_BOUQUET_AGGRO = "Drapeau : Aggro";
VUHDO_I18N_BOUQUET_OUT_OF_RANGE = "Drapeau : Port\195\169e, hors de";
VUHDO_I18N_BOUQUET_IN_RANGE = "Drapeau : Port\195\169e, dans";
VUHDO_I18N_BOUQUET_IN_YARDS = "Drapeau : Distance < yards";
VUHDO_I18N_BOUQUET_OTHER_HOTS = "Drapeau : HoTs d'autres joueurs";
VUHDO_I18N_BOUQUET_DEBUFF_MAGIC = "Drapeau : D\195\169buff Magie";
VUHDO_I18N_BOUQUET_DEBUFF_DISEASE = "Drapeau : D\195\169buff Maladie";
VUHDO_I18N_BOUQUET_DEBUFF_POISON = "Drapeau : D\195\169buff Poison";
VUHDO_I18N_BOUQUET_DEBUFF_CURSE = "Drapeau : D\195\169buff Mal\195\169diction";
VUHDO_I18N_BOUQUET_CHARMED = "Drapeau : Charm\195\169";
VUHDO_I18N_BOUQUET_DEAD = "Drapeau : Mort";
VUHDO_I18N_BOUQUET_DISCONNECTED = "Drapeau : D\195\169connect\195\169";
VUHDO_I18N_BOUQUET_AFK = "Drapeau : AFK";
VUHDO_I18N_BOUQUET_PLAYER_TARGET = "Drapeau : Cible du joueur";
VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET = "Drapeau : Survol de souris, unique";
VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP = "Drapeau : Survol de souris, groupe";
VUHDO_I18N_BOUQUET_HEALTH_BELOW = "Drapeau : Sant\195\169 < %";
VUHDO_I18N_BOUQUET_MANA_BELOW = "Drapeau : Mana < %";
VUHDO_I18N_BOUQUET_THREAT_ABOVE = "Drapeau : Menace > %";
VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER = "Drapeau : Groupe >= joueurs";
VUHDO_I18N_BOUQUET_CLASS_COLOR = "Drapeau : Toujours couleur de classe";
VUHDO_I18N_BOUQUET_ALWAYS = "Drapeau : Toujours plein";
VUHDO_I18N_SWIFTMEND_POSSIBLE = "Drapeau : Soin rapide possible";
VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER = "Drapeau : Groupe, survol de souris";
VUHDO_I18N_THREAT_LEVEL_MEDIUM = "Drapeau : Menace, \195\169lev\195\169e";
VUHDO_I18N_THREAT_LEVEL_HIGH = "Drapeau : Menace, surpuissance";
VUHDO_I18N_BOUQUET_STATUS_HEALTH = "Barre d'\195\169tat : Sant\195\169 %";
VUHDO_I18N_BOUQUET_STATUS_MANA = "Barre d'\195\169tat : Mana %";
VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS = "Barre d'\195\169tat : non-Mana %";
VUHDO_I18N_BOUQUET_STATUS_INCOMING = "Barre d'\195\169tat : Soins entrants %";
VUHDO_I18N_BOUQUET_STATUS_THREAT = "Barre d'\195\169tat : Menace %";
VUHDO_I18N_BOUQUET_NEW_ITEM_NAME = "-- entrer (d\195\169)buff ici --";
VUHDO_I18N_DEF_BOUQUET_TANK_COOLDOWNS = "Temps de recharge du tank";
VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL = "PW:S & \195\130me affaiblie";
VUHDO_I18N_DEF_BOUQUET_MONK_STAGGER = "Report du moine";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI_AGGRO = "Bordure : Multi + Aggro";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI = "Bordure : Multi";
VUHDO_I18N_DEF_BOUQUET_BORDER_SIMPLE = "Bordure : Simple";
VUHDO_I18N_DEF_BOUQUET_SWIFTMENDABLE = "Soin rapide possible";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_SINGLE = "Survol de souris : Unique";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_MULTI = "Survol de souris : Multi";
VUHDO_I18N_DEF_BOUQUET_AGGRO_INDICATOR = "Indicateur d'aggro";
VUHDO_I18N_DEF_BOUQUET_CLUSTER_MOUSE_HOVER = "Groupe : Survol de souris";
VUHDO_I18N_DEF_BOUQUET_THREAT_MARKS = "Menace : Marques";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ALL = "Barres de mana : Toutes les puissances";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ONLY = "Barres de mana : Mana seulement";
VUHDO_I18N_DEF_BOUQUET_BAR_THREAT = "Menace : Barre d'\195\169tat";
VUHDO_I18N_CUSTOM_ICON_NONE = "- Aucun / D\195\169faut -";
VUHDO_I18N_CUSTOM_ICON_GLOSSY = "Brillant";
VUHDO_I18N_CUSTOM_ICON_MOSAIC = "Mosa\195\174que";
VUHDO_I18N_CUSTOM_ICON_CLUSTER = "Groupe";
VUHDO_I18N_CUSTOM_ICON_FLAT = "Plat";
VUHDO_I18N_CUSTOM_ICON_SPOT = "Point";
VUHDO_I18N_CUSTOM_ICON_CIRCLE = "Cercle";
VUHDO_I18N_CUSTOM_ICON_SKETCHED = "Esquiss\195\169";
VUHDO_I18N_CUSTOM_ICON_RHOMB = "Losange";
VUHDO_I18N_ERROR_NO_PROFILE = "Erreur : Aucun profil nomm\195\169 : ";
VUHDO_I18N_PROFILE_LOADED = "Profil charg\195\169 avec succ\195\168s : ";
VUHDO_I18N_PROFILE_SAVED = "Profil enregistr\195\169 avec succ\195\168s : ";
VUHDO_I18N_PROFILE_OVERWRITE_1 = "Profil";
VUHDO_I18N_PROFILE_OVERWRITE_2 = "est actuellement poss\195\169d\195\169 par\nun autre personnage";
VUHDO_I18N_PROFILE_OVERWRITE_3 = "\n- \195\130craser : Le profil existant sera \195\169cras\195\169.\n- Copier : Cr\195\169er et enregistrer une copie. Conserver le profil existant.";
VUHDO_I18N_COPY = "Copier";
VUHDO_I18N_OVERWRITE = "\195\130craser";
VUHDO_I18N_DISCARD = "Abandonner";
-- 2.0, alpha #2
VUHDO_I18N_DEF_BAR_BACKGROUND_SOLID = "Arri\195\168re-plan : Plein";
VUHDO_I18N_DEF_BAR_BACKGROUND_CLASS_COLOR = "Arri\195\168re-plan : Couleur de classe";
-- 2.0 alpha #9
VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR = "Drapeau : D\195\169buff, configur\195\169";
-- 2.0 alpha #11
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH = "Barre de sant\195\169 : (auto)";
VUHDO_I18N_UPDATE_RAID_TARGET = "Drapeau : Couleur de cible de raid";
VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT = "Couleur : Surbrillance de sursoin";
VUHDO_I18N_BOUQUET_EMERGENCY_COLOR = "Couleur : Urgence";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE = "Drapeau : Sant\195\169 > %";
VUHDO_I18N_BOUQUET_RESURRECTION = "Drapeau : R\195\169surrection";
VUHDO_I18N_BOUQUET_STACKS_COLOR = "Couleur : #Cumuls";
-- 2.1
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_SOLID = "Sant\195\169 : (g\195\169n\195\169rique, plein)";
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_CLASS_COLOR = "Sant\195\169 : (g\195\169n\195\169rique, couleur de classe)";
-- 2.9
VUHDO_I18N_NO_TARGET = "[pas de cible]";
VUHDO_I18N_TT_LEFT = " Gauche : ";
VUHDO_I18N_TT_RIGHT = " Droite : ";
VUHDO_I18N_TT_MIDDLE = " Milieu : ";
VUHDO_I18N_TT_BTN_4 = " Bouton 4 : ";
VUHDO_I18N_TT_BTN_5 = " Bouton 5 : ";
VUHDO_I18N_TT_WHEEL_UP = " Roulette vers le haut : ";
VUHDO_I18N_TT_WHEEL_DOWN = " Roulette vers le bas : ";
-- 2.13
VUHDO_I18N_BOUQUET_CLASS_ICON = "Ic\195\180ne : Classe";
VUHDO_I18N_BOUQUET_RAID_ICON = "Ic\195\180ne : Symbole de raid";
VUHDO_I18N_BOUQUET_ROLE_ICON = "Ic\195\180ne : R\195\180le";
-- 2.18
VUHDO_I18N_LOAD_PROFILE = "Charger le profil";
-- 2.20
VUHDO_I18N_DC_SHIELD_NO_MACROS = "Pas d'emplacements de macro libres pour ce personnage... le bouclier d/c est d\195\169sactiv\195\169 temporairement.";
VUHDO_I18N_BROKER_TOOLTIP_1 = "|cffffff00Clic gauche|r pour afficher le menu des options";
VUHDO_I18N_BROKER_TOOLTIP_2 = "|cffffff00Clic droit|r pour afficher le menu contextuel";
-- 2.54
VUHDO_I18N_HOURS = "heures";
VUHDO_I18N_MINS = "mins";
VUHDO_I18N_SECS = "secs";
-- 2.65
VUHDO_I18N_BOUQUET_CUSTOM_DEBUFF = "Ic\195\180ne : D\195\169buff personnalis\195\169";
-- 2.66
VUHDO_I18N_OFF = "d\195\169sactiv\195\169";
VUHDO_I18N_GHOST = "fant\195\180me";
VUHDO_I18N_RIP = "rip";
VUHDO_I18N_DC = "d/c";
VUHDO_I18N_FOC = "foc";
VUHDO_I18N_TAR = "tar";
VUHDO_I18N_VEHICLE = "O-O";
-- 2.67
VUHDO_I18N_BUFF_WATCH = "Surveillance des buffs";
VUHDO_I18N_HOTS = "HoTs";
VUHDO_I18N_DEBUFFS = "D\195\169buffs";
VUHDO_I18N_BOUQUET_PLAYER_FOCUS = "Drapeau : Focus du joueur";
-- 2.69
VUHDO_I18N_SIDE_BAR_LEFT = "Barre lat\195\169rale gauche";
VUHDO_I18N_SIDE_BAR_RIGHT = "Barre lat\195\169rale droite";
VUHDO_I18N_OWN_PET = "Familier personnel";
-- 2.72
VUHDO_I18N_SPELL = "Sort";
VUHDO_I18N_COMMAND = "Commande";
VUHDO_I18N_MACRO = "Macro";
VUHDO_I18N_ITEM = "Objet";
-- 2.75
VUHDO_I18N_ERR_NO_BOUQUET = "\"%s\" essaie de se lier au bouquet \"%s\" qui n'existe pas !";

VUHDO_I18N_BOUQUET_HEALTH_BELOW_ABS = "Drapeau : Sant\195\169 < k";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE_ABS = "Drapeau : Sant\195\169 > k";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST = "La disposition de sort \"%s\" n'existe pas.";

--VUHDO_I18N_ADDON_WARNING = "AVERTISSEMENT : L'addon |cffffffff\"%s\"|r est activ\195\169 avec VuhDo, ce qui peut \195\170tre probl\195\169matique. Raison : %s";
--VUHDO_I18N_MAY_CAUSE_LAGS = "Peut causer des lags s\195\169v\195\168res.";

VUHDO_I18N_DISABLE_BY_MIN_VERSION = "!!! VUHDO EST D\195\137SACTIV\195\137 !!! Cette version (%s) est pour les versions de client %d et sup\195\169rieures seulement !!!"
VUHDO_I18N_DISABLE_BY_MAX_VERSION = "!!! VUHDO EST D\195\137SACTIV\195\137 !!! Cette version (%s) est pour les versions de client %d et inf\195\169rieures seulement !!!"

VUHDO_I18N_BOUQUET_STATUS_ALTERNATE_POWERS = "Barre d'\195\169tat : Puissance alternative %"
VUHDO_I18N_BOUQUET_ALTERNATE_POWERS_ABOVE = "Drapeau : Puissance alternative > %";
VUHDO_I18N_DEF_ALTERNATE_POWERS = "Pouvoirs alternatifs";
VUHDO_I18N_DEF_TANK_CDS_EXTENDED = "Temps de recharge du tank \195\169tendus";
VUHDO_I18N_BOUQUET_HOLY_POWER_EQUALS = "Drapeau : Pouvoir sacr\195\169 personnel ==";
VUHDO_I18N_DEF_PLAYER_HOLY_POWER = "Pouvoir sacr\195\169 du joueur";
VUHDO_I18N_CUSTOM_ICON_ONE_THIRD = "Tiers : Un";
VUHDO_I18N_CUSTOM_ICON_TWO_THIRDS = "Tiers : Deux";
VUHDO_I18N_CUSTOM_ICON_THREE_THIRDS = "Tiers : Trois";
VUHDO_I18N_DEF_ROLE_ICON = "Ic\195\180ne de r\195\180le";

VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH = "Sant\195\169 (g\195\169n\195\169rique, cible)";

VUHDO_I18N_TAPPED_COLOR = "Drapeau : Cible d\195\169j\195\160 engag\195\169e";
VUHDO_I18N_ENEMY_STATE_COLOR = "Couleur : Ami/Ennemi";
VUHDO_I18N_FRIEND_STATUS = "Drapeau : Ami";
VUHDO_I18N_FOE_STATUS = "Drapeau : Ennemi";
VUHDO_I18N_BOUQUET_STATUS_ALWAYS_FULL = "Barre d'\195\169tat : toujours pleine";
VUHDO_I18N_BOUQUET_STATUS_FULL_IF_ACTIVE = "Barre d'\195\169tat : pleine si active";
VUHDO_I18N_AOE_ADVICE = "Ic\195\180ne : Conseil de zone";
VUHDO_I18N_DEF_AOE_ADVICE = "Conseil de zone";

VUHDO_I18N_BOUQUET_DURATION_ABOVE = "Drapeau : Dur\195\169e > sec";
VUHDO_I18N_BOUQUET_DURATION_BELOW = "Drapeau : Dur\195\169e < sec";
VUHDO_I18N_DEF_WRACK = "Sinestra : Tourment";

VUHDO_I18N_DEF_DIRECTION_ARROW = "Fl\195\168che directionnelle";
VUHDO_I18N_BOUQUET_DIRECTION_ARROW = "Fl\195\168che directionnelle";
VUHDO_I18N_DEF_RAID_LEADER = "Ic\195\180ne : Chef de raid";
VUHDO_I18N_DEF_RAID_ASSIST = "Ic\195\180ne : Assistant de raid";
VUHDO_I18N_DEF_MASTER_LOOTER = "Ic\195\180ne : Ma\195\174tre du butin";
VUHDO_I18N_DEF_PVP_STATUS = "Ic\195\180ne : Statut JcJ";

VUHDO_I18N_GRID_MOUSEOVER_SINGLE = "Grille : Survol de souris unique";
VUHDO_I18N_GRID_BACKGROUND_BAR = "Grille : Barre d'arri\195\168re-plan";
VUHDO_I18N_DEF_BIT_O_GRID = "Bit'o'Grid";
VUHDO_I18N_DEF_VUHDO_ESQUE = "Vuhdo'esque";

VUHDO_I18N_DEF_ROLE_COLOR = "Couleur de r\195\180le";
VUHDO_I18N_BOUQUET_ROLE_TANK = "Drapeau : R\195\180le Tank";
VUHDO_I18N_BOUQUET_ROLE_DAMAGE = "Drapeau : R\195\180le D\195\169g\195\162ts";
VUHDO_I18N_BOUQUET_ROLE_HEALER = "Drapeau : R\195\180le Soigneur";

VUHDO_I18N_BOUQUET_STACKS = "Drapeau : Cumuls >";
VUHDO_I18N_DEF_PLAYER_CHI = "\195\130nergie du joueur";

VUHDO_I18N_BOUQUET_TARGET_RAID_ICON = "Ic\195\180ne : Symbole de raid de la cible";
VUHDO_I18N_BOUQUET_OWN_CHI_EQUALS = "Drapeau : \195\130nergie personnelle ==";
VUHDO_I18N_CUSTOM_ICON_FOUR_THIRDS = "Tiers : Quatre";
VUHDO_I18N_CUSTOM_ICON_FIVE_THIRDS = "Tiers : Cinq";
VUHDO_I18N_DEF_RAID_CDS = "Temps de recharge de raid";
VUHDO_I18N_BOUQUET_STATUS_CLASS_COLOR_IF_ACTIVE = "Drapeau : Couleur de classe si actif";

VUHDO_I18N_LETHAL_POISONS = "Poisons l\195\169taux";
VUHDO_I18N_NON_LETHAL_POISONS = "Poisons non l\195\169taux";
VUHDO_I18N_DEF_COUNTER_SHIELD_ABSORB = "Compteur : Toute absorption de bouclier #k";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_OFF = "Enchantement d'arme (main gauche)";

VUHDO_I18N_DEF_PVP_FLAGS = "Porteurs de drapeaux JcJ";
VUHDO_I18N_DEF_STATUS_SHIELD = "Barre d'\195\169tat : Bouclier";

VUHDO_I18N_TARGET = "Cible";
VUHDO_I18N_FOCUS = "Focus";
VUHDO_I18N_DEF_STATUS_OVERSHIELDED = "Barre d'\195\169tat : Sur-bouclier";

-- 3.65
VUHDO_I18N_BOUQUET_OUTSIDE_ZONE = "Drapeau : Zone du joueur, \195\160 l'ext\195\169rieur";
VUHDO_I18N_BOUQUET_INSIDE_ZONE = "Drapeau : Zone du joueur, \195\160 l'int\195\169rieur";
VUHDO_I18N_BOUQUET_WARRIOR_TANK = "Drapeau : R\195\180le Tank, Guerrier";
VUHDO_I18N_BOUQUET_PALADIN_TANK = "Drapeau : R\195\180le Tank, Paladin";
VUHDO_I18N_BOUQUET_DK_TANK = "Drapeau : R\195\180le Tank, Chevalier de la mort";
VUHDO_I18N_BOUQUET_MONK_TANK = "Drapeau : R\195\180le Tank, Moine";
VUHDO_I18N_BOUQUET_DRUID_TANK = "Drapeau : R\195\180le Tank, Druide";

-- 3.66
VUHDO_I18N_BOUQUET_PALADIN_BEACON = "Phare du Paladin";
VUHDO_I18N_BOUQUET_STATUS_EXCESS_ABSORB = "Barre d'\195\169tat : Absorption exc\195\169dentaire %";
VUHDO_I18N_BOUQUET_STATUS_TOTAL_ABSORB = "Barre d'\195\169tat : Absorption totale %";

-- 3.67
VUHDO_I18N_NO_BOSS = "[pas de PNJ]";
VUHDO_I18N_BOSSES = "PNJs";

-- 3.71
VUHDO_I18N_BOUQUET_CUSTOM_FLAG = "Drapeau personnalis\195\169";
VUHDO_I18N_ERROR_CUSTOM_FLAG_LOAD = "{VuhDo} Erreur : Votre validateur de drapeau personnalis\195\169 n'a pas \195\169t\195\169 charg\195\169 :";
VUHDO_I18N_ERROR_CUSTOM_FLAG_EXECUTE = "{VuhDo} Erreur : Votre validateur de drapeau personnalis\195\169 n'a pas \195\169t\195\169 ex\195\169cut\195\169 :";
VUHDO_I18N_ERROR_CUSTOM_FLAG_BLOCKED = "{VuhDo} Erreur : Un drapeau personnalis\195\169 de ce bouquet a essay\195\169 d'appeler une fonction interdite mais a \195\169t\195\169 bloqu\195\169. Souvenez-vous d'importer des cha\195\174nes uniquement \195\160 partir de sources de confiance.";
VUHDO_I18N_ERROR_INVALID_VALIDATOR = "{VuhDo} Erreur : Validateur invalide :";

-- 3.72
VUHDO_I18N_BOUQUET_DEMON_HUNTER_TANK = "Drapeau : R\195\180le Tank, Chasseur de d\195\169mons";
VUHDO_I18N_DEMON_HUNTERS = "Chasseurs de d\195\169mons";

-- 3.77
VUHDO_I18N_DEF_COUNTER_OVERFLOW_ABSORB = "Compteur : Absorption de d\195\169bordement mythique+ #k";

-- 3.79
VUHDO_I18N_DEFAULT_RES_ANNOUNCE_MASS = "Lancement de la r\195\169surrection de masse !";

-- 3.81
VUHDO_I18N_BOUQUET_OVERFLOW_COUNTER = "Affix de d\195\169bordement mythique+";

-- 3.82
VUHDO_I18N_SPELL_TRACE = "Ic\195\180ne : Trace de sort";
VUHDO_I18N_DEF_SPELL_TRACE = "Trace de sort";
VUHDO_I18N_TRAIL_OF_LIGHT = "Ic\195\180ne : Tra\195\174n\195\169e de lumi\195\168re";
VUHDO_I18N_DEF_TRAIL_OF_LIGHT = "Tra\195\174n\195\169e de lumi\195\168re";

-- 3.83
VUHDO_I18N_BOUQUET_STATUS_MANA_HEALER_ONLY = "Barre d'\195\169tat : Mana % (Soigneur uniquement)";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_HEALER_ONLY = "Barres de mana : Mana (Soigneur uniquement)";

-- 3.98
VUHDO_I18N_BOUQUET_HAS_SUMMON_ICON = "Ic\195\180ne : A une invocation";
VUHDO_I18N_DEF_BOUQUET_HAS_SUMMON = "Ic\195\180ne d'\195\169tat d'invocation";
VUHDO_I18N_DEF_BOUQUET_ROLE_AND_SUMMON = "Ic\195\180ne d'\195\169tat de r\195\180le et d'invocation";

-- 3.99
VUHDO_I18N_BOUQUET_IS_PHASED = "Ic\195\180ne : Est phas\195\169";
VUHDO_I18N_BOUQUET_IS_WAR_MODE_PHASED = "Ic\195\180ne : Est phas\195\169 en mode guerre";
VUHDO_I18N_DEF_BOUQUET_IS_PHASED = "Ic\195\180ne Est phas\195\169";

-- 3.101
VUHDO_I18N_DEF_PLAYER_COMBO_POINTS = "Points de combo du joueur";
VUHDO_I18N_BOUQUET_OWN_COMBO_POINTS_EQUALS = "Drapeau : Points de combo personnels ==";
VUHDO_I18N_DEF_PLAYER_SOUL_SHARDS = "Fragments d'\195\130me du joueur";
VUHDO_I18N_BOUQUET_OWN_SOUL_SHARDS_EQUALS = "Drapeau : Fragments d'\195\130me personnels ==";
VUHDO_I18N_DEF_PLAYER_RUNES = "Runes du joueur";
VUHDO_I18N_BOUQUET_OWN_RUNES_EQUALS = "Drapeau : Runes personnelles ==";
VUHDO_I18N_DEF_PLAYER_ARCANE_CHARGES = "Charges arcaniques du joueur";
VUHDO_I18N_BOUQUET_OWN_ARCANE_CHARGES_EQUALS = "Drapeau : Charges arcaniques personnelles ==";
VUHDO_I18N_DEBUFF_BLACKLIST_ADDED = "Ajout de \"[%s] %s\" \195\160 la liste noire de d\195\169buffs.";

-- 3.104
VUHDO_I18N_PLAY_SOUND_FILE_ERR = "Impossible de jouer le son \"%s\" : %s";
VUHDO_I18N_PLAY_SOUND_FILE_DEBUFF_ERR = "Impossible de jouer le son \"%s\" pour le d\195\169buff standard. Ajustez vos param\195\168tres sous 'Options VuhDo > D\195\169buffs > Standard > Son de d\195\169buff'.";
VUHDO_I18N_PLAY_SOUND_FILE_CUSTOM_DEBUFF_ERR = "Impossible de jouer le son \"%s\" pour le d\195\169buff personnalis\195\169 \"%s\". Ajustez vos param\195\168tres sous 'Options VuhDo > D\195\169buffs > Personnalis\195\169'.";

-- 3.122
VUHDO_I18N_BOUQUET_STATUS_POWER_TANK_ONLY = "Barre d'\195\169tat : Puissance % (Tank uniquement)";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_TANK_ONLY = "Barres de mana : Puissance (Tank uniquement)";

-- 3.131
VUHDO_I18N_DEF_COUNTER_HEAL_ABSORB = "Compteur : Toute absorption de soin #k";
VUHDO_I18N_DEF_STATUS_HEAL_ABSORB = "Barre d'\195\169tat : Absorption de soin";

-- 3.135
VUHDO_I18N_TRINKET_1 = "Bijou 1";
VUHDO_I18N_TRINKET_2 = "Bijou 2";

-- 3.139
VUHDO_I18N_EVOKERS = "Evocateurs";

-- 3.143
VUHDO_I18N_BUFFC_EARTH_SHIELD = "Bouclier de terre (Soi)";

-- 3.150
VUHDO_I18N_ADDON_COMPARTMENT_ICON = "L'ic\195\180ne du compartiment d'addon est maintenant ";

-- 3.152
VUHDO_I18N_SPELL_TRACE_SINGLE = "Ic\195\180ne : Trace de sort (Unique)";

-- 3.154
VUHDO_I18N_SPELL_TRACE_INCOMING = "Ic\195\180ne : Trace de sort (Entrant)";
VUHDO_I18N_SPELL_TRACE_HEAL = "Ic\195\180ne : Trace de sort (Soin)";

-- 3.157
VUHDO_I18N_TEXT_PROVIDER_OVERHEAL = "Sursoin : <#nk>";
VUHDO_I18N_TEXT_PROVIDER_OVERHEAL_PLUS = "Sursoin : +<#n>k";
VUHDO_I18N_TEXT_PROVIDER_INCOMING_HEAL = "Soin entrant : <#nk>";
VUHDO_I18N_TEXT_PROVIDER_SHIELD_ABSORB = "Absorption de bouclier totale : <#nk>";
VUHDO_I18N_TEXT_PROVIDER_HEAL_ABSORB = "Absorption de soin totale : <#nk>";
VUHDO_I18N_TEXT_PROVIDER_THREAT = "Menace : <#n>%";
VUHDO_I18N_TEXT_PROVIDER_CHI = "\195\130nergie : <#n>";
VUHDO_I18N_TEXT_PROVIDER_HOLY_POWER = "Pouvoir sacr\195\169 : <#n>";
VUHDO_I18N_TEXT_PROVIDER_COMBO_POINTS = "Points de combo : <#n>";
VUHDO_I18N_TEXT_PROVIDER_SOUL_SHARDS = "Fragments d'\195\130me : <#n>";
VUHDO_I18N_TEXT_PROVIDER_RUNES = "Runes : <#n>";
VUHDO_I18N_TEXT_PROVIDER_ARCANE_CHARGES = "Charges arcaniques : <#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT = "Mana : <#n>%";
VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT_TENTH = "Mana : <#n/10%>";
VUHDO_I18N_TEXT_PROVIDER_MANA_UNIT_OF = "Mana : <#n>/<#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_KILO_OF = "Mana : <#nk>/<#nk>";
VUHDO_I18N_TEXT_PROVIDER_MANA = "Mana : <#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_KILO = "Mana : <#nk>";
VUHDO_I18N_BOUQUET_STATUS_HEALTH_IF_ACTIVE = "Barre d'\195\169tat : Sant\195\169 % si actif";

VUHDO_I18N_DEF_COUNTER_ACTIVE_AURAS = "Compteur : Auras de bouquet actives #k";

VUHDO_I18N_BOUQUET_EVOKER_REVERSION = "R\195\169version de l'\195\130vocateur (non-\195\169cho)";
VUHDO_I18N_BOUQUET_EVOKER_REVERSION_ECHO = "R\195\169version de l'\195\130vocateur (\195\169cho)";
VUHDO_I18N_BOUQUET_EVOKER_DREAM_BREATH = "Souffle de r\195\170ve de l'\195\130vocateur (non-\195\169cho)";
VUHDO_I18N_BOUQUET_EVOKER_DREAM_BREATH_ECHO = "Souffle de r\195\170ve de l'\195\130vocateur (\195\169cho)";
VUHDO_I18N_BOUQUET_EVOKER_ALL_ECHO = "Tous les \195\169chos de soins de l'\195\130vocateur";

VUHDO_I18N_TRAIL_OF_LIGHT_NEXT = "Drapeau : Tra\195\174n\195\169e de lumi\195\168re (Suivant)";
VUHDO_I18N_DEF_TRAIL_OF_LIGHT_NEXT = "Tra\195\174n\195\169e de lumi\195\168re (Suivant)";
VUHDO_I18N_BOUQUET_DEBUFF_BLEED = "Drapeau : D\195\169buff Saignement";

VUHDO_I18N_DEF_SPELL_TRACE_INCOMING = "Trace de sort (Entrant)";

VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_MINE = "Ic\195\180ne : Harmonie du Chi (Mien)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_MINE = "Harmonie du Chi (Mien)";
VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_OTHERS = "Ic\195\180ne : Harmonie du Chi (Autres)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_OTHERS = "Harmonie du Chi (Autres)";
VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_BOTH = "Ic\195\180ne : Harmonie du Chi (Les deux)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_BOTH = "Harmonie du Chi (Les deux)";

VUHDO_I18N_BOUQUET_DEBUFF_ENRAGE = "Drapeau : D\195\169buff Enrager";
