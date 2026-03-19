
if (GetLocale() ~= "zhTW") then return end

local L = MikSBT.translations

L.FONT_FILES["MSBT bKAI00M"] = "Fonts\\bKAI00M.TTF"

L.DEFAULT_FONT_NAME = "MSBT bKAI00M"

L.COMMAND_USAGE = {
	"ä½¿ç”¨æ–¹æ³•: " .. MikSBT.COMMAND .. " <æŒ‡ä»¤> [åƒæ•¸]",
	" æŒ‡ä»¤:",
	"  " .. L.COMMAND_RESET .. " - é‡ç½®",
	"  " .. L.COMMAND_DISABLE .. " - åœç”¨",
	"  " .. L.COMMAND_ENABLE .. " - å•Ÿç”¨",
	"  " .. L.COMMAND_SHOWVER .. " - é¡¯ç¤ºç›®å‰ç‰ˆæœ¬",
	"  " .. L.COMMAND_HELP .. " - å¹«åŠ©",
}

L.MSG_DISABLE				= "åœç”¨æ’ä»¶."
L.MSG_ENABLE				= "å•Ÿç”¨æ’ä»¶."
L.MSG_PROFILE_RESET			= "é‡ç½®è¨­å®š"
L.MSG_HITS					= "æ“Šä¸­"
L.MSG_CRIT					= "çˆ†æ“Š"
L.MSG_CRITS					= "çˆ†æ“Š"
L.MSG_MULTIPLE_TARGETS		= "å¤šæ•¸ç›®æ¨™"
L.MSG_READY_NOW				= "æº–å‚™å®Œç•¢"

L.MSG_INCOMING			= "æ‰¿å—å‚·å®³"
L.MSG_OUTGOING			= "è¼¸å‡ºå‚·å®³"
L.MSG_NOTIFICATION		= "é€šçŸ¥è¨Šæ¯"
L.MSG_STATIC			= "éœæ…‹è¨Šæ¯"

L.MSG_COMBAT					= "æˆ°é¬¥"
L.MSG_DISPEL					= "é©…æ•£é­”æ³•"

L.MSG_CP						= "é€£æ“Šé»ž"
L.MSG_CP_FULL					= "çµ‚çµæŠ€"
L.MSG_HOLY_POWER_FULL			= "æ»¿è–èƒ½"

L.MSG_KILLING_BLOW				= "æ“Šæ®º"
L.MSG_TRIGGER_LOW_HEALTH		= "ç”Ÿå‘½å€¼åä½Ž"
L.MSG_TRIGGER_LOW_MANA			= "æ³•åŠ›å€¼åä½Ž"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "å¯µç‰©ç”Ÿå‘½åä½Ž"

