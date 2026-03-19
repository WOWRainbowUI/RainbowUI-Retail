
if (GetLocale() ~= "zhCN") then return end

local L = MikSBT.translations

L.FONT_FILES["MSBT ARKai_C"] = "Fonts\\ARKai_C.TTF"

L.DEFAULT_FONT_NAME = "MSBT ARKai_C"

L.COMMAND_USAGE = {
	"ä½¿ç”¨æ–¹æ³•: " .. MikSBT.COMMAND .. " <å‘½ä»¤> [å‚æ•°]",
	" å‘½ä»¤:",
	"  " .. L.COMMAND_RESET .. " - é‡ç½®",
	"  " .. L.COMMAND_DISABLE .. " - ç¦ç”¨",
	"  " .. L.COMMAND_ENABLE .. " - å¯ç”¨",
	"  " .. L.COMMAND_SHOWVER .. " - æ˜¾ç¤ºå½“å‰ç‰ˆæœ¬",
	"  " .. L.COMMAND_HELP .. " - å¸®åŠ©",
}

L.MSG_DISABLE				= "ç¦ç”¨æ’ä»¶."
L.MSG_ENABLE				= "å¯ç”¨æ’ä»¶."
L.MSG_PROFILE_RESET			= "é‡ç½®é…ç½®"
L.MSG_HITS					= "å‡»ä¸­"
L.MSG_CRIT					= "çˆ†å‡»"
L.MSG_CRITS					= "çˆ†å‡»"
L.MSG_MULTIPLE_TARGETS		= "å¤šä¸ªç›®æ ‡"
L.MSG_READY_NOW				= "å‡†å¤‡å®Œæ¯•"

L.MSG_INCOMING			= "æ‰¿å—ä¼¤å®³"
L.MSG_OUTGOING			= "è¾“å‡ºä¼¤å®³"
L.MSG_NOTIFICATION		= "é€šå‘Šä¿¡æ¯"
L.MSG_STATIC			= "é™æ€ä¿¡æ¯"

L.MSG_COMBAT					= "æˆ˜æ–—"
L.MSG_DISPEL					= "é©±æ•£"

L.MSG_CP_FULL					= "ç»ˆç»“æŠ€"
L.MSG_HOLY_POWER_FULL			= "æ»¡åœ£èƒ½"

L.MSG_KILLING_BLOW				= "å‡»æ€"
L.MSG_TRIGGER_LOW_HEALTH		= "ç”Ÿå‘½å€¼ä½Ž"
L.MSG_TRIGGER_LOW_MANA			= "é­”æ³•å€¼ä½Ž"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "å® ç‰©ç”Ÿå‘½å€¼ä½Ž"

