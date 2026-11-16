
if (GetLocale() ~= "frFR") then return end

local L = MikSBT.translations

L.FONT_FILES = {
	["MSBT Adventure"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\adventure.ttf",
	["MSBT Bazooka"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\bazooka.ttf",
	["MSBT Cooline"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\cooline.ttf",
	["MSBT Diogenes"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\diogenes.ttf",
	["MSBT Ginko"]			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\ginko.ttf",
	["MSBT Heroic"]			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\heroic.ttf",
	["MSBT Porky"]			= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\porky.ttf",
	["MSBT Talisman"]		= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\talisman.ttf",
	["MSBT Transformers"]	= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\transformers.ttf",
	["MSBT Yellowjacket"]	= "Interface\\Addons\\MikScrollingBattleText\\Fonts\\yellowjacket.ttf",
}

L.DEFAULT_FONT_NAME = "MSBT Porky"

L.COMMAND_USAGE = {
	"Usage: " .. MikSBT.COMMAND .. " <command> [params]",
	" Commande:",
	"  " .. L.COMMAND_RESET .. " - Restaure les paramètres par défaut.",
	"  " .. L.COMMAND_DISABLE .. " - Désactive l'addon.",
	"  " .. L.COMMAND_ENABLE .. " - Active l'addon.",
	"  " .. L.COMMAND_SHOWVER .. " - Affiche la version actuelle.",
	"  " .. L.COMMAND_HELP .. " - Affiche l'aide des commandes.",
}

L.MSG_DISABLE				= "Addon désactivé."
L.MSG_ENABLE				= "Addon activé."
L.MSG_PROFILE_RESET			= "Profil réinitialisé"
L.MSG_HITS					= "Coups"
L.MSG_CRIT					= "Crit"
L.MSG_CRITS					= "Crits"
L.MSG_MULTIPLE_TARGETS		= "Multiples"
L.MSG_READY_NOW				= "Disponible"

L.MSG_INCOMING			= "Entrant"
L.MSG_OUTGOING			= "Sortant"
L.MSG_NOTIFICATION		= "Alertes"
L.MSG_STATIC			= "Statique"

L.MSG_COMBAT					= "Combat"
L.MSG_DISPEL					= "Dissiper"

L.CP_FULL						= "Finissez-le"

L.MSG_KILLING_BLOW				= "Coup Fatal"
L.MSG_TRIGGER_LOW_HEALTH		= "Vie Faible"
L.MSG_TRIGGER_LOW_MANA			= "Mana Faible"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "Vie du familier faible"

-- Recent feature translations (2026-11-13).
L.COSMIC = "Cosmique"
L.CP_FULL = "Achève-le !"
L.COMBO_POINT = "Point de combo"
L.COMBO_POINTS = "Points de combo"
L.SETUP_RELOAD_PROMPT = "Pour démarrer MSBT, vous devez recharger l'interface."
L.RESOURCE_NAMES = {
    MANA = "Mana",
    RAGE = "Rage",
    FOCUS = "Focalisation",
    ENERGY = "Énergie",
    COMBO_POINTS = "Point de combo",
    RUNES = "Runes",
    RUNIC_POWER = "Puissance runique",
    SOUL_SHARDS = "Éclats d'âme",
    LUNAR_POWER = "Puissance astrale",
    HOLY_POWER = "Puissance sacrée",
    ALTERNATE_POWER = "Ressource alternative",
    MAELSTROM = "Maelström",
    CHI = "Chi",
    INSANITY = "Insanité",
    BURNING_EMBERS = "Braises ardentes",
    DEMONIC_FURY = "Fureur démoniaque",
    ARCANE_CHARGES = "Charges arcaniques",
    FURY = "Fureur",
    PAIN = "Douleur",
    ESSENCE = "Essence",
    RUNE_BLOOD = "Rune de sang",
    RUNE_FROST = "Rune de givre",
    RUNE_UNHOLY = "Rune impie",
    ALTERNATE_QUEST_POWER = "Ressource de quête",
    ALTERNATE_ENCOUNTER_POWER = "Ressource de rencontre",
    ALTERNATE_MOUNT_POWER = "Ressource de monture",
    BALANCE = "Équilibre",
    HAPPINESS = "Bonheur",
    SHADOW_ORBS = "Orbes d'ombre",
    RUNE_CHROMATIC = "Rune chromatique",
}
