
if (GetLocale() ~= "itIT") then return end

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

L.COMMAND_RESET		= "reset"
L.COMMAND_DISABLE	= "disabilita"
L.COMMAND_ENABLE	= "abilita"
L.COMMAND_SHOWVER	= "versione"
L.COMMAND_HELP		= "aiuto"

L.COMMAND_USAGE = {
	"Usage: " .. MikSBT.COMMAND .. " <command> [params]",
	" Commands:",
	"  " .. L.COMMAND_RESET .. " - REimposta il profilo corrente alle impostazioni di base.",
	"  " .. L.COMMAND_DISABLE .. " - Disabilita l'addon.",
	"  " .. L.COMMAND_ENABLE .. " - Abilita l'addon.",
	"  " .. L.COMMAND_SHOWVER .. " - Mostra la versione corrente.",
	"  " .. L.COMMAND_HELP .. " - Mostra come usare i comandi.",
}

L.MSG_DISABLE				= "Addon Disabilitato."
L.MSG_ENABLE				= "Addon Abilitato."
L.MSG_PROFILE_RESET			= "Profilo Reimpostato"
L.MSG_HITS					= "Colpi"
L.MSG_CRIT					= "Critico"
L.MSG_CRITS					= "Critici"
L.MSG_MULTIPLE_TARGETS		= "Multipli"
L.MSG_READY_NOW				= "Pronto Ora"

L.MSG_INCOMING			= "In Arrivo"
L.MSG_OUTGOING			= "In Uscita"
L.MSG_NOTIFICATION		= "Notifiche"
L.MSG_STATIC			= "Statico"

L.MSG_COMBAT					= "Combattimento"
L.MSG_DISPEL					= "Dissipare"


L.MSG_KILLING_BLOW				= "Colpo Mortale"
L.MSG_TRIGGER_LOW_HEALTH		= "Vita Bassa"
L.MSG_TRIGGER_LOW_MANA			= "Mana Basso"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "Vita Famiglio Bassa"

-- Recent feature translations (2026-11-13).
L.COSMIC = "Cosmico"
L.CP_FULL = "Finiscilo!"
L.COMBO_POINT = "Punto combo"
L.COMBO_POINTS = "Punti combo"
L.SETUP_RELOAD_PROMPT = "Per avviare MSBT devi ricaricare l'interfaccia."
L.RESOURCE_NAMES = {
    MANA = "Mana",
    RAGE = "Rabbia",
    FOCUS = "Focus",
    ENERGY = "Energia",
    COMBO_POINTS = "Punto combo",
    RUNES = "Rune",
    RUNIC_POWER = "Potenza runica",
    SOUL_SHARDS = "Frammenti d'anima",
    LUNAR_POWER = "Potere astrale",
    HOLY_POWER = "Potere sacro",
    ALTERNATE_POWER = "Risorsa alternativa",
    MAELSTROM = "Maelstrom",
    CHI = "Chi",
    INSANITY = "Insanità",
    BURNING_EMBERS = "Braci ardenti",
    DEMONIC_FURY = "Furia demoniaca",
    ARCANE_CHARGES = "Cariche arcane",
    FURY = "Furia",
    PAIN = "Dolore",
    ESSENCE = "Essenza",
    RUNE_BLOOD = "Runa del Sangue",
    RUNE_FROST = "Runa del Gelo",
    RUNE_UNHOLY = "Runa Empia",
    ALTERNATE_QUEST_POWER = "Risorsa della missione",
    ALTERNATE_ENCOUNTER_POWER = "Risorsa dello scontro",
    ALTERNATE_MOUNT_POWER = "Risorsa della cavalcatura",
    BALANCE = "Equilibrio",
    HAPPINESS = "Felicità",
    SHADOW_ORBS = "Globi d'ombra",
    RUNE_CHROMATIC = "Runa cromatica",
}
