
if (GetLocale() ~= "deDE") then return end

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
	"Usage: " .. MikSBT.COMMAND .. " <Befehl> [Parameter]",
	" Befehle:",
	"  " .. L.COMMAND_RESET .. " - Das aktuelle Profil auf Standardwerte zurücksetzen.",
	"  " .. L.COMMAND_DISABLE .. " - Das Addon deaktivieren.",
	"  " .. L.COMMAND_ENABLE .. " - Das Addon aktivieren.",
	"  " .. L.COMMAND_SHOWVER .. " - Die aktuelle Version anzeigen.",
	"  " .. L.COMMAND_HELP .. " - Hilfe anzeigen.",
}

L.MSG_DISABLE				= "Addon deaktiviert."
L.MSG_ENABLE				= "Addon aktiviert."
L.MSG_PROFILE_RESET			= "Profil zurückgesetzt."
L.MSG_HITS					= "Treffer"
L.MSG_CRIT					= "Krit"
L.MSG_CRITS					= "Krits"
L.MSG_MULTIPLE_TARGETS		= "Mehrere"
L.MSG_READY_NOW				= "verfügbar"

L.MSG_INCOMING			= "Eingehend"
L.MSG_OUTGOING			= "Ausgehend"
L.MSG_NOTIFICATION		= "Benachrichtigung"
L.MSG_STATIC			= "Statisch"

L.MSG_COMBAT					= "Kampf"
L.MSG_DISPEL					= "Dispel"


L.MSG_KILLING_BLOW				= "Todesstoß"
L.MSG_TRIGGER_LOW_HEALTH		= "Wenig Gesundheit"
L.MSG_TRIGGER_LOW_MANA			= "Wenig Mana"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "Wenig Begleiter Gesundheit"

-- Recent feature translations (2026-11-13).
L.COSMIC = "Kosmisch"
L.CP_FULL = "Mach ihn fertig!"
L.COMBO_POINT = "Combopunkt"
L.COMBO_POINTS = "Combopunkte"
L.SETUP_RELOAD_PROMPT = "Damit MSBT starten kann, muss die Benutzeroberfläche neu geladen " ..
    "werden."
L.RESOURCE_NAMES = {
    MANA = "Mana",
    RAGE = "Wut",
    FOCUS = "Fokus",
    ENERGY = "Energie",
    COMBO_POINTS = "Combopunkt",
    RUNES = "Runen",
    RUNIC_POWER = "Runenmacht",
    SOUL_SHARDS = "Seelensplitter",
    LUNAR_POWER = "Astrale Macht",
    HOLY_POWER = "Heilige Kraft",
    ALTERNATE_POWER = "Alternative Ressource",
    MAELSTROM = "Mahlstrom",
    CHI = "Chi",
    INSANITY = "Wahnsinn",
    BURNING_EMBERS = "Instabile Funken",
    DEMONIC_FURY = "Dämonischer Furor",
    ARCANE_CHARGES = "Arkane Aufladungen",
    FURY = "Jähzorn",
    PAIN = "Schmerz",
    ESSENCE = "Essenz",
    RUNE_BLOOD = "Blutrune",
    RUNE_FROST = "Frostrune",
    RUNE_UNHOLY = "Unheilige Rune",
    ALTERNATE_QUEST_POWER = "Questressource",
    ALTERNATE_ENCOUNTER_POWER = "Begegnungsressource",
    ALTERNATE_MOUNT_POWER = "Reittierressource",
    BALANCE = "Gleichgewicht",
    HAPPINESS = "Zufriedenheit",
    SHADOW_ORBS = "Schattenkugeln",
    RUNE_CHROMATIC = "Chromatische Rune",
}
