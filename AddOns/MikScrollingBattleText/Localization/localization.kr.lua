
if (GetLocale() ~= "koKR") then return end

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
	["[WoW] ê¸°ë³¸ ê¸€ê¼´"]		= "Fonts\\2002.TTF",
	["[WoW] íƒ€ì´í‹€ ê¸€ê¼´"]		= "Fonts\\2002B.TTF",
	["[WoW] ë°ë¯¸ì§€ ê¸€ê¼´"]		= "Fonts\\K_Damage.TTF",
}

L.DEFAULT_FONT_NAME = "[WoW] ê¸°ë³¸ ê¸€ê¼´"

L.COMMAND_USAGE = {
	"ì‚¬ìš©ë²•: " .. MikSBT.COMMAND .. " <ëª…ë ¹ì–´> [ì˜µì…˜]",
	" ëª…ë ¹ì–´:",
	"  " .. L.COMMAND_RESET .. " - í˜„ìž¬ í”„ë¡œí•„ì„ ê¸°ë³¸ ì„¤ì •ìœ¼ë¡œ ì´ˆê¸°í™”í•©ë‹ˆë‹¤.",
	"  " .. L.COMMAND_DISABLE .. " - ì• ë“œì˜¨ì˜ ì‚¬ìš©ì„ ì¤‘ì§€í•©ë‹ˆë‹¤.",
	"  " .. L.COMMAND_ENABLE .. " - ì• ë“œì˜¨ì„ ì‚¬ìš©í•©ë‹ˆë‹¤.",
	"  " .. L.COMMAND_SHOWVER .. " - í˜„ìž¬ ë²„ì „ì„ í‘œì‹œí•©ë‹ˆë‹¤.",
	"  " .. L.COMMAND_HELP .. " - ëª…ë ¹ì–´ ì‚¬ìš©ë²•ì„ í‘œì‹œí•©ë‹ˆë‹¤.",
}

L.MSG_DISABLE				= "ì• ë“œì˜¨ì˜ ì‚¬ìš©ì„ ì¤‘ì§€í•©ë‹ˆë‹¤."
L.MSG_ENABLE				= "ì• ë“œì˜¨ì„ ì‚¬ìš©í•©ë‹ˆë‹¤."
L.MSG_PROFILE_RESET			= "í”„ë¡œí•„ì´ ì´ˆê¸°í™” ë˜ì—ˆìŠµë‹ˆë‹¤."
L.MSG_HITS					= "íšŒ"
L.MSG_CRIT					= "ì¹˜ëª…íƒ€"
L.MSG_CRITS					= "xì¹˜ëª…íƒ€"
L.MSG_MULTIPLE_TARGETS		= "ë‹¤ìˆ˜"
L.MSG_READY_NOW				= "[ëŒ€ê¸°ì™„ë£Œ]"

L.MSG_INCOMING			= "ìžì‹ ì´ ë°›ì€ ë©”ì„¸ì§€"
L.MSG_OUTGOING			= "ëŒ€ìƒì´ ë°›ì€ ë©”ì„¸ì§€"
L.MSG_NOTIFICATION		= "ì•Œë¦¼ ë©”ì„¸ì§€"
L.MSG_STATIC			= "ì •ì  ë©”ì‹œì§€"

L.MSG_COMBAT					= "ì „íˆ¬ ìƒíƒœ"
L.MSG_DISPEL					= "í•´ì œ"
L.MSG_AC						= "ë¹„ì „ ì¶©ì „ë¬¼"
L.MSG_AC_FULL					= "ë¹„ì „ ì¶©ì „ë¬¼ ìµœëŒ€"

L.MSG_CP						= "ì—°ê³„ ì ìˆ˜"
L.MSG_CP_FULL					= "ë§ˆë¬´ë¦¬ ê³µê²©"
L.MSG_HOLY_POWER_FULL			= "ì‹ ì„±í•œ íž˜ ìµœëŒ€"

L.MSG_ESSENCE					= "ì •ìˆ˜"
L.MSG_ESSENCE_FULL				= "ì •ìˆ˜ ìµœëŒ€"
L.MSG_KILLING_BLOW				= "ê²°ì •íƒ€"
L.MSG_TRIGGER_LOW_HEALTH		= "ìƒëª…ë ¥ ë‚®ìŒ"
L.MSG_TRIGGER_LOW_MANA			= "ë§ˆë‚˜ ë‚®ìŒ"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "ì†Œí™˜ìˆ˜ ìƒëª…ë ¥ ë‚®ìŒ"

