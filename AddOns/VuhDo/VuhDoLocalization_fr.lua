if (GetLocale() ~= "frFR") then
	return;
end
-- à = \195\160
-- â = \195\162
-- æ = \195\166
-- ç = \195\167
-- è = \195\168
-- é = \195\169
-- è = \195\170
-- ï = \195\175
-- ô = \195\180
-- ù = \195\185
-- Œ = \197\146
-- œ = \197\147
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
VUHDO_I18N_MAINTANKS = "Tanks principaux";
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
VUHDO_I18N_ROLE_OVERRIDE = "Role override";
VUHDO_I18N_MELEE_TANK = "Melee - Tank";
VUHDO_I18N_MELEE_DPS = "Melee - DPS";
VUHDO_I18N_RANGED_DPS = "Ranged - DPS";
VUHDO_I18N_RANGED_HEALERS = "Ranged - Healer";
VUHDO_I18N_AUTO_DETECT = "<auto detect>";
VUHDO_I18N_PROMOTE_ASSIST_MSG_1 = "Promoted |cffffe566";
VUHDO_I18N_PROMOTE_ASSIST_MSG_2 = "|r to assistant.";
VUHDO_I18N_DEMOTE_ASSIST_MSG_1 = "Demoted |cffffe566";
VUHDO_I18N_DEMOTE_ASSIST_MSG_2 = "|r from assistant.";
VUHDO_I18N_RESET_ROLES = "Reset Roles";
VUHDO_I18N_LOAD_KEY_SETUP = "Load Key Setup";
VUHDO_I18N_BUFF_ASSIGN_1 = "Buff |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_2 = "|r has been assigned to |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_3 = "|r";
VUHDO_I18N_MACRO_KEY_ERR_1 = "ERROR: Keyboard mouse-over macro size exceeds limit for spell: ";
VUHDO_I18N_MACRO_KEY_ERR_2 = "/256 Characters). Try reducing auto fire options!!!";
VUHDO_I18N_MACRO_NUM_ERR = "Maximum number of macros per character exceeded! Can't create mouse over macro for: ";
VUHDO_I18N_SMARTBUFF_ERR_1 = "VuhDo: Unable to smart buff in combat!";
VUHDO_I18N_SMARTBUFF_ERR_2 = "VuhDo: No buff target available for ";
VUHDO_I18N_SMARTBUFF_ERR_3 = " players out of range for ";
VUHDO_I18N_SMARTBUFF_ERR_4 = "VuhDo: No buff to cast.";
VUHDO_I18N_SMARTBUFF_OKAY_1 = "VuhDo: Buffing |cffffffff";
VUHDO_I18N_SMARTBUFF_OKAY_2 = "|r on ";
-- #+v1.189
VUHDO_I18N_UNKNOWN = "unknown";
VUHDO_I18N_SELF = "Self";
VUHDO_I18N_MELEES = "Melees";
VUHDO_I18N_RANGED = "Ranged";
VUHDO_I18N_OPTIONS_NOT_LOADED = ">>> VuhDo Options plugin not loaded! <<<";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 = "Error: Spell layout \"";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2 = "\" doesn't exist.";
VUHDO_I18N_AUTO_ARRANG_1 = "Number of Party members has changed to ";
VUHDO_I18N_AUTO_ARRANG_2 = ". Auto-engaging arrangement: \"";
-- #+1.209
VUHDO_I18N_TRACK_BUFFS_FOR = "Track buff for ...";
VUHDO_I18N_OWN_GROUP_LONG = "Own Group";
VUHDO_I18N_NO_FOCUS = "[no focus]";
VUHDO_I18N_NOT_AVAILABLE = "[ N/A ]";
-- #+1.237
VUHDO_I18N_TT_DISTANCE = "|cffffb233Distance:|r";
VUHDO_I18N_TT_OF = " of ";
VUHDO_I18N_YARDS = "yards";
-- #+1.252
VUHDO_I18N_PANEL = "Panel";
VUHDO_I18N_BOUQUET_AGGRO = "Flag: Aggro";
VUHDO_I18N_BOUQUET_OUT_OF_RANGE = "Flag: Range, out of";
VUHDO_I18N_BOUQUET_IN_RANGE = "Flag: Range, in";
VUHDO_I18N_BOUQUET_IN_YARDS = "Flag: Distance < yards";
VUHDO_I18N_BOUQUET_OTHER_HOTS = "Flag: Other Player's HoTs";
VUHDO_I18N_BOUQUET_DEBUFF_MAGIC = "Flag: Debuff Magic";
VUHDO_I18N_BOUQUET_DEBUFF_DISEASE = "Flag: Debuff Disease";
VUHDO_I18N_BOUQUET_DEBUFF_POISON = "Flag: Debuff Poison";
VUHDO_I18N_BOUQUET_DEBUFF_CURSE = "Flag: Debuff Curse";
VUHDO_I18N_BOUQUET_CHARMED = "Flag: Charmed";
VUHDO_I18N_BOUQUET_DEAD = "Flag: Dead";
VUHDO_I18N_BOUQUET_DISCONNECTED = "Flag: Disconnected";
VUHDO_I18N_BOUQUET_AFK = "Flag: AFK";
VUHDO_I18N_BOUQUET_PLAYER_TARGET = "Flag: Player Target";
VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET = "Flag: Mouseover Single";
VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP = "Flag: Mouseover Group";
VUHDO_I18N_BOUQUET_HEALTH_BELOW = "Flag: Health < %";
VUHDO_I18N_BOUQUET_MANA_BELOW = "Flag: Mana < %";
VUHDO_I18N_BOUQUET_THREAT_ABOVE = "Flag: Threat > %";
VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER = "Flag: Cluster >= players";
VUHDO_I18N_BOUQUET_CLASS_COLOR = "Flag: Always Class Color";
VUHDO_I18N_BOUQUET_ALWAYS = "Flag: Always Solid";
VUHDO_I18N_SWIFTMEND_POSSIBLE = "Flag: Swiftmend possible";
VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER = "Flag: Cluster, Mouseover";
VUHDO_I18N_THREAT_LEVEL_MEDIUM = "Flag: Threat, High";
VUHDO_I18N_THREAT_LEVEL_HIGH = "Flag: Threat, Overnuke";
VUHDO_I18N_BOUQUET_STATUS_HEALTH = "Statusbar: Health %";
VUHDO_I18N_BOUQUET_STATUS_MANA = "Statusbar: Mana %";
VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS = "Statusbar: non-Mana %";
VUHDO_I18N_BOUQUET_STATUS_INCOMING = "Statusbar: Inc. Heals %";
VUHDO_I18N_BOUQUET_STATUS_THREAT = "Statusbar: Threat %";
VUHDO_I18N_BOUQUET_NEW_ITEM_NAME = "-- enter (de)buff here --";
VUHDO_I18N_DEF_BOUQUET_TANK_COOLDOWNS = "Tank Cooldowns";
VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL = "PW:S & Weakened Soul";
VUHDO_I18N_DEF_BOUQUET_MONK_STAGGER = "Report du moine";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI_AGGRO = "Border: Multi + Aggro";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI = "Border: Multi";
VUHDO_I18N_DEF_BOUQUET_BORDER_SIMPLE = "Border: Simple";
VUHDO_I18N_DEF_BOUQUET_SWIFTMENDABLE = "Swiftmendable";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_SINGLE = "Mouseover: Single";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_MULTI = "Mouseover: Multi";
VUHDO_I18N_DEF_BOUQUET_AGGRO_INDICATOR = "Aggro Indicator";
VUHDO_I18N_DEF_BOUQUET_CLUSTER_MOUSE_HOVER = "Cluster: Mouse Hover";
VUHDO_I18N_DEF_BOUQUET_THREAT_MARKS = "Threat: Marks";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ALL = "Manabars: All Powers";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ONLY = "Manabars: Mana only";
VUHDO_I18N_DEF_BOUQUET_BAR_THREAT = "Threat: Status Bar";
VUHDO_I18N_CUSTOM_ICON_NONE = "- None / Default -";
VUHDO_I18N_CUSTOM_ICON_GLOSSY = "Glossy";
VUHDO_I18N_CUSTOM_ICON_MOSAIC = "Mosaic";
VUHDO_I18N_CUSTOM_ICON_CLUSTER = "Cluster";
VUHDO_I18N_CUSTOM_ICON_FLAT = "Flat";
VUHDO_I18N_CUSTOM_ICON_SPOT = "Spot";
VUHDO_I18N_CUSTOM_ICON_CIRCLE = "Circle";
VUHDO_I18N_CUSTOM_ICON_SKETCHED = "Sketched";
VUHDO_I18N_CUSTOM_ICON_RHOMB = "Rhomb";
VUHDO_I18N_ERROR_NO_PROFILE = "Error: No profile named: ";
VUHDO_I18N_PROFILE_LOADED = "Profile successfully loaded: ";
VUHDO_I18N_PROFILE_SAVED = "Successfully saved profile: ";
VUHDO_I18N_PROFILE_OVERWRITE_1 = "Profile";
VUHDO_I18N_PROFILE_OVERWRITE_2 = "is currently owned by\nanother toon";
VUHDO_I18N_PROFILE_OVERWRITE_3 = "\n- Overwrite: Existing profile will be overwritten.\n- Copy: Create and save a copy. Keep existing profile.";
VUHDO_I18N_COPY = "Copy";
VUHDO_I18N_OVERWRITE = "Overwrite";
VUHDO_I18N_DISCARD = "Discard";
-- 2.0, alpha #2
VUHDO_I18N_DEF_BAR_BACKGROUND_SOLID = "Background: Solid";
VUHDO_I18N_DEF_BAR_BACKGROUND_CLASS_COLOR = "Background: Class Color";
-- 2.0 alpha #9
VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR = "Flag: Debuff, configured";
-- 2.0 alpha #11
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH = "Health Bar: (auto)";
VUHDO_I18N_UPDATE_RAID_TARGET = "Flag: Raid target color";
VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT = "Color: Overheal Highlighter";
VUHDO_I18N_BOUQUET_EMERGENCY_COLOR = "Color: Emergency";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE = "Flag: Health > %";
VUHDO_I18N_BOUQUET_RESURRECTION = "Flag: Resurrection";
VUHDO_I18N_BOUQUET_STACKS_COLOR = "Color: #Stacks";
-- 2.1
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_SOLID = "Health: (generic, solid)";
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_CLASS_COLOR = "Health: (generic, class col)";
-- 2.9
VUHDO_I18N_NO_TARGET = "[no target]";
VUHDO_I18N_TT_LEFT = " Left: ";
VUHDO_I18N_TT_RIGHT = " Right: ";
VUHDO_I18N_TT_MIDDLE = " Middle: ";
VUHDO_I18N_TT_BTN_4 = " Button 4: ";
VUHDO_I18N_TT_BTN_5 = " Button 5: ";
VUHDO_I18N_TT_WHEEL_UP = " Wheel up: ";
VUHDO_I18N_TT_WHEEL_DOWN = " Wheel down: ";
-- 2.13
VUHDO_I18N_BOUQUET_CLASS_ICON = "Icon: Class";
VUHDO_I18N_BOUQUET_RAID_ICON = "Icon: Raid Symbol";
VUHDO_I18N_BOUQUET_ROLE_ICON = "Icon: Role";
-- 2.18
VUHDO_I18N_LOAD_PROFILE = "Load Profile";
-- 2.20
VUHDO_I18N_DC_SHIELD_NO_MACROS = "No free macro slots for this toon... d/c shield temporarily disabled.";
VUHDO_I18N_BROKER_TOOLTIP_1 = "|cffffff00Left Click|r to show options menu";
VUHDO_I18N_BROKER_TOOLTIP_2 = "|cffffff00Right Click|r to show popup menu";
-- 2.54
VUHDO_I18N_HOURS = "hours";
VUHDO_I18N_MINS = "mins";
VUHDO_I18N_SECS = "secs";
-- 2.65
VUHDO_I18N_BOUQUET_CUSTOM_DEBUFF = "Icon: Custom Debuff";
-- 2.66
VUHDO_I18N_OFF = "off";
VUHDO_I18N_GHOST = "ghost";
VUHDO_I18N_RIP = "rip";
VUHDO_I18N_DC = "d/c";
VUHDO_I18N_FOC = "foc";
VUHDO_I18N_TAR = "tar";
VUHDO_I18N_VEHICLE = "O-O";
-- 2.67
VUHDO_I18N_BUFF_WATCH = "BuffWatch";
VUHDO_I18N_HOTS = "HoTs";
VUHDO_I18N_DEBUFFS = "Debuffs";
VUHDO_I18N_BOUQUET_PLAYER_FOCUS = "Flag: Player Focus";
-- 2.69
VUHDO_I18N_SIDE_BAR_LEFT = "Side Left";
VUHDO_I18N_SIDE_BAR_RIGHT = "Side Right";
VUHDO_I18N_OWN_PET = "Own Pet";
-- 2.72
VUHDO_I18N_SPELL = "Spell";
VUHDO_I18N_COMMAND = "Command";
VUHDO_I18N_MACRO = "Macro";
VUHDO_I18N_ITEM = "Item";
-- 2.75
VUHDO_I18N_ERR_NO_BOUQUET = "\"%s\" tries to hook to bouquet \"%s\" which doesn't exist!";
VUHDO_I18N_BOUQUET_HEALTH_BELOW_ABS = "Flag: Health < k";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE_ABS = "Flag: Health > k";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST = "Spell layout \"%s\" doesn't exist.";

--VUHDO_I18N_ADDON_WARNING = "WARNING: Addon |cffffffff\"%s\"|r is enabled along with VuhDo, which may be problematic. Reason: %s";
--VUHDO_I18N_MAY_CAUSE_LAGS = "May cause severe lags.";

VUHDO_I18N_DISABLE_BY_MIN_VERSION = "!!! VUHDO IS DISABLED !!! This version (%s) is for client versions %d and above only !!!"
VUHDO_I18N_DISABLE_BY_MAX_VERSION = "!!! VUHDO IS DISABLED !!! This version (%s) is for client versions %d and below only !!!"

VUHDO_I18N_BOUQUET_STATUS_ALTERNATE_POWERS = "Statusbar: Alternate Power %"
VUHDO_I18N_BOUQUET_ALTERNATE_POWERS_ABOVE = "Flag: Alternate Power > %";
VUHDO_I18N_DEF_ALTERNATE_POWERS = "Alternative Powers";
VUHDO_I18N_DEF_TANK_CDS_EXTENDED = "Tank Cooldowns extd";
VUHDO_I18N_BOUQUET_HOLY_POWER_EQUALS = "Flag: Own Holy Power ==";
VUHDO_I18N_DEF_PLAYER_HOLY_POWER = "Player Holy Power";
VUHDO_I18N_CUSTOM_ICON_ONE_THIRD = "Thirds: One";
VUHDO_I18N_CUSTOM_ICON_TWO_THIRDS = "Thirds: Two"
VUHDO_I18N_CUSTOM_ICON_THREE_THIRDS = "Thirds: Three";
VUHDO_I18N_DEF_ROLE_ICON = "Role Icon";
VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH = "Health (generic, target)";
VUHDO_I18N_TAPPED_COLOR = "Flag: Tapped";
VUHDO_I18N_ENEMY_STATE_COLOR = "Color: Friend/Foe";
VUHDO_I18N_FRIEND_STATUS = "Flag: Ami";
VUHDO_I18N_FOE_STATUS = "Flag: Ennemi";
VUHDO_I18N_BOUQUET_STATUS_ALWAYS_FULL = "Statusbar: always full";
VUHDO_I18N_BOUQUET_STATUS_FULL_IF_ACTIVE = "Statusbar: full if active";
VUHDO_I18N_AOE_ADVICE = "Icon: AOE Advice";
VUHDO_I18N_DEF_AOE_ADVICE = "AOE Advice";
VUHDO_I18N_BOUQUET_DURATION_ABOVE = "Flag: Duration > sec";
VUHDO_I18N_BOUQUET_DURATION_BELOW = "Flag: Duration < sec";
VUHDO_I18N_DEF_WRACK = "Sinestra: Wrack";
VUHDO_I18N_DEF_DIRECTION_ARROW = "Direction Arrow";
VUHDO_I18N_BOUQUET_DIRECTION_ARROW = "Direction Arrow";
VUHDO_I18N_DEF_RAID_LEADER = "Icon: Raid leader";
VUHDO_I18N_DEF_RAID_ASSIST = "Icon: Raid assist";
VUHDO_I18N_DEF_MASTER_LOOTER = "Icon: Master looter";
VUHDO_I18N_DEF_PVP_STATUS = "Icon: PvP Status";

VUHDO_I18N_GRID_MOUSEOVER_SINGLE = "Grid: Mouseover Single";
VUHDO_I18N_GRID_BACKGROUND_BAR = "Grid: Background Bar";
VUHDO_I18N_DEF_BIT_O_GRID = "Bit'o'Grid";
VUHDO_I18N_DEF_VUHDO_ESQUE = "Vuhdo'esque";


VUHDO_I18N_DEF_ROLE_COLOR = "Role Color";
VUHDO_I18N_BOUQUET_ROLE_TANK = "Flag: Role Tank";
VUHDO_I18N_BOUQUET_ROLE_DAMAGE = "Flag: Role Damager";
VUHDO_I18N_BOUQUET_ROLE_HEALER = "Flag: Role Healer";

VUHDO_I18N_BOUQUET_STACKS = "Flag: Stacks >";
VUHDO_I18N_DEF_PLAYER_CHI = "Player Chi";

VUHDO_I18N_BOUQUET_TARGET_RAID_ICON = "Icon: Target's Raid Symbol";
VUHDO_I18N_BOUQUET_OWN_CHI_EQUALS = "Flag: Own Chi ==";
VUHDO_I18N_CUSTOM_ICON_FOUR_THIRDS = "Thirds: Four";
VUHDO_I18N_CUSTOM_ICON_FIVE_THIRDS = "Thirds: Five";
VUHDO_I18N_DEF_RAID_CDS = "Raid Cooldowns";
VUHDO_I18N_BOUQUET_STATUS_CLASS_COLOR_IF_ACTIVE = "Flag: Class Color if active";

VUHDO_I18N_LETHAL_POISONS = "Lethal Poisons";
VUHDO_I18N_NON_LETHAL_POISONS = "Non-lethal Poisons";
VUHDO_I18N_DEF_COUNTER_SHIELD_ABSORB = "Counter: All Shield Absorb #k";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_OFF = "Weapon Enchant (offhand)";

VUHDO_I18N_DEF_PVP_FLAGS="PvP Flag Carriers";
VUHDO_I18N_DEF_STATUS_SHIELD = "Statusbar: Shield";

VUHDO_I18N_TARGET = "Target";
VUHDO_I18N_FOCUS = "Focus";
VUHDO_I18N_DEF_STATUS_OVERSHIELDED = "Statusbar: Overshielded";

-- 3.65
VUHDO_I18N_BOUQUET_OUTSIDE_ZONE = "Flag: Player Zone, outside";
VUHDO_I18N_BOUQUET_INSIDE_ZONE = "Flag: Player Zone, inside";
VUHDO_I18N_BOUQUET_WARRIOR_TANK = "Flag: Role Tank, Warrior";
VUHDO_I18N_BOUQUET_PALADIN_TANK = "Flag: Role Tank, Paladin";
VUHDO_I18N_BOUQUET_DK_TANK = "Flag: Role Tank, Death Knight";
VUHDO_I18N_BOUQUET_MONK_TANK = "Flag: Role Tank, Monk";
VUHDO_I18N_BOUQUET_DRUID_TANK = "Flag: Role Tank, Druid";

-- 3.66
VUHDO_I18N_BOUQUET_PALADIN_BEACON = "Paladin Beacon";
VUHDO_I18N_BOUQUET_STATUS_EXCESS_ABSORB = "Statusbar: Excess Absorption %";
VUHDO_I18N_BOUQUET_STATUS_TOTAL_ABSORB = "Statusbar: Total Absorption %";

-- 3.67
VUHDO_I18N_NO_BOSS = "[no NPC]";
VUHDO_I18N_BOSSES = "NPCs";

-- 3.71
VUHDO_I18N_BOUQUET_CUSTOM_FLAG = "Custom Flag";
VUHDO_I18N_ERROR_CUSTOM_FLAG_LOAD = "{VuhDo} Error: Your custom flag validator did not load:";
VUHDO_I18N_ERROR_CUSTOM_FLAG_EXECUTE = "{VuhDo} Error: Your custom flag validator did not execute:";
VUHDO_I18N_ERROR_CUSTOM_FLAG_BLOCKED = "{VuhDo} Error: A custom flag of this bouquet tried to call a forbidden function but has been blocked from doing so. Remember only to import strings from trusted sources.";
VUHDO_I18N_ERROR_INVALID_VALIDATOR = "{VuhDo} Error: Invalid validator:";

-- 3.72
VUHDO_I18N_BOUQUET_DEMON_HUNTER_TANK = "Flag: Role Tank, Demon Hunter";
VUHDO_I18N_DEMON_HUNTERS = "Demon Hunters";

-- 3.77
VUHDO_I18N_DEF_COUNTER_OVERFLOW_ABSORB = "Counter: Mythic+ Overflow Absorb #k";

-- 3.79
VUHDO_I18N_DEFAULT_RES_ANNOUNCE_MASS = "Casting mass resurrection!";

-- 3.81
VUHDO_I18N_BOUQUET_OVERFLOW_COUNTER = "Overflow Mythic+ Affix";

-- 3.82
VUHDO_I18N_SPELL_TRACE = "Icon: Spell Trace";
VUHDO_I18N_DEF_SPELL_TRACE = "Spell Trace";
VUHDO_I18N_TRAIL_OF_LIGHT = "Icon: Trail of Light";
VUHDO_I18N_DEF_TRAIL_OF_LIGHT = "Trail of Light";

-- 3.83
VUHDO_I18N_BOUQUET_STATUS_MANA_HEALER_ONLY = "Statusbar: Mana % (Healer Only)";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_HEALER_ONLY = "Manabars: Mana (Healer Only)";

-- 3.98
VUHDO_I18N_BOUQUET_HAS_SUMMON_ICON = "Icon: Has Summon";
VUHDO_I18N_DEF_BOUQUET_HAS_SUMMON = "Summon Status Icon";
VUHDO_I18N_DEF_BOUQUET_ROLE_AND_SUMMON = "Role & Summon Status Icon";

-- 3.99
VUHDO_I18N_BOUQUET_IS_PHASED = "Icon: Is Phased";
VUHDO_I18N_BOUQUET_IS_WAR_MODE_PHASED = "Icon: Is War Mode Phased";
VUHDO_I18N_DEF_BOUQUET_IS_PHASED = "Is Phased Icon";

-- 3.101
VUHDO_I18N_DEF_PLAYER_COMBO_POINTS = "Player Combo Points";
VUHDO_I18N_BOUQUET_OWN_COMBO_POINTS_EQUALS = "Flag: Own Combo Points ==";
VUHDO_I18N_DEF_PLAYER_SOUL_SHARDS = "Player Soul Shards";
VUHDO_I18N_BOUQUET_OWN_SOUL_SHARDS_EQUALS = "Flag: Own Soul Shards ==";
VUHDO_I18N_DEF_PLAYER_RUNES = "Player Runes";
VUHDO_I18N_BOUQUET_OWN_RUNES_EQUALS = "Flag: Own Runes ==";
VUHDO_I18N_DEF_PLAYER_ARCANE_CHARGES = "Player Arcane Charges";
VUHDO_I18N_BOUQUET_OWN_ARCANE_CHARGES_EQUALS = "Flag: Own Arcane Charges ==";
VUHDO_I18N_DEBUFF_BLACKLIST_ADDED = "Added \"[%s] %s\" to the debuff backlist.";

-- 3.104
VUHDO_I18N_PLAY_SOUND_FILE_ERR = "Could not play sound \"%s\": %s";
VUHDO_I18N_PLAY_SOUND_FILE_DEBUFF_ERR = "Could not play sound \"%s\" for standard debuff. Adjust your settings under 'VuhDo Options > Debuffs > Standard > Debuff Sound'.";
VUHDO_I18N_PLAY_SOUND_FILE_CUSTOM_DEBUFF_ERR = "Could not play sound \"%s\" for custom debuff \"%s\". Adjust your settings under 'VuhDo Options > Debuffs > Custom'.";

-- 3.122
VUHDO_I18N_BOUQUET_STATUS_POWER_TANK_ONLY = "Statusbar: Power % (Tank Only)";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_TANK_ONLY = "Manabars: Power (Tank Only)";

-- 3.131
VUHDO_I18N_DEF_COUNTER_HEAL_ABSORB = "Counter: All Heal Absorb #k";
VUHDO_I18N_DEF_STATUS_HEAL_ABSORB = "Statusbar: Heal Absorb";

-- 3.135
VUHDO_I18N_TRINKET_1 = "Trinket 1";
VUHDO_I18N_TRINKET_2 = "Trinket 2";

-- 3.139
VUHDO_I18N_EVOKERS = "Evokers";

-- 3.143
VUHDO_I18N_BUFFC_EARTH_SHIELD = "Earth Shield (Self)";

-- 3.150
VUHDO_I18N_ADDON_COMPARTMENT_ICON = "AddOn Compartment Icon is now ";

-- 3.152
VUHDO_I18N_SPELL_TRACE_SINGLE = "Icon: Spell Trace (Single)";

-- 3.154
VUHDO_I18N_SPELL_TRACE_INCOMING = "Icon: Spell Trace (Incoming)";
VUHDO_I18N_SPELL_TRACE_HEAL = "Icon: Spell Trace (Heal)";

-- 3.157
VUHDO_I18N_TEXT_PROVIDER_OVERHEAL = "Overheal: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_OVERHEAL_PLUS = "Overheal: +<#n>k";
VUHDO_I18N_TEXT_PROVIDER_INCOMING_HEAL = "Incoming Heal: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_SHIELD_ABSORB = "Shield absorb total: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_HEAL_ABSORB = "Heal absorb total: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_THREAT = "Threat: <#n>%";
VUHDO_I18N_TEXT_PROVIDER_CHI = "Chi: <#n>";
VUHDO_I18N_TEXT_PROVIDER_HOLY_POWER = "Holy Power: <#n>";
VUHDO_I18N_TEXT_PROVIDER_COMBO_POINTS = "Combo Points: <#n>";
VUHDO_I18N_TEXT_PROVIDER_SOUL_SHARDS = "Soul Shards: <#n>";
VUHDO_I18N_TEXT_PROVIDER_RUNES = "Runes: <#n>";
VUHDO_I18N_TEXT_PROVIDER_ARCANE_CHARGES = "Arcane Charges: <#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT = "Mana: <#n>%";
VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT_TENTH = "Mana: <#n/10%>";
VUHDO_I18N_TEXT_PROVIDER_MANA_UNIT_OF = "Mana: <#n>/<#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_KILO_OF = "Mana: <#nk>/<#nk>";
VUHDO_I18N_TEXT_PROVIDER_MANA = "Mana: <#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_KILO = "Mana: <#nk>";
VUHDO_I18N_BOUQUET_STATUS_HEALTH_IF_ACTIVE = "Statusbar: Health % if active";

VUHDO_I18N_DEF_COUNTER_ACTIVE_AURAS = "Counter: Active Bouquet Auras #k";

VUHDO_I18N_BOUQUET_EVOKER_REVERSION = "Evoker Reversion (non-echo)";
VUHDO_I18N_BOUQUET_EVOKER_REVERSION_ECHO = "Evoker Reversion (echo)";
VUHDO_I18N_BOUQUET_EVOKER_DREAM_BREATH = "Evoker Dream Breath (non-echo)";
VUHDO_I18N_BOUQUET_EVOKER_DREAM_BREATH_ECHO = "Evoker Dream Breath (echo)";
VUHDO_I18N_BOUQUET_EVOKER_ALL_ECHO = "Evoker All HoT Echoes";

VUHDO_I18N_TRAIL_OF_LIGHT_NEXT = "Flag: Trail of Light (Next)";
VUHDO_I18N_DEF_TRAIL_OF_LIGHT_NEXT = "Trail of Light (Next)";
VUHDO_I18N_BOUQUET_DEBUFF_BLEED = "Flag: Debuff Bleed";

VUHDO_I18N_DEF_SPELL_TRACE_INCOMING = "Spell Trace (Incoming)";

VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_MINE = "Icon: Chi Harmony (Mine)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_MINE = "Chi Harmony (Mine)";
VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_OTHERS = "Icon: Chi Harmony (Others)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_OTHERS = "Chi Harmony (Others)";
VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_BOTH = "Icon: Chi Harmony (Both)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_BOTH = "Chi Harmony (Both)";

VUHDO_I18N_BOUQUET_DEBUFF_ENRAGE = "Flag: Debuff Enrage";
