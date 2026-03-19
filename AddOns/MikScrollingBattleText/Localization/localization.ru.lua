
if (GetLocale() ~= "ruRU") then return end

local L = MikSBT.translations

L.FONT_FILES = {
	["MSBT Morpheus"]		= "Fonts\\MORPHEUS.TTF",
	["MSBT Nim"]			= "Fonts\\NIM_____.ttf",
	["MSBT Skurri"]			= "Fonts\\SKURRI.TTF",
}

L.DEFAULT_FONT_NAME = "MSBT Nim"

L.COMMAND_USAGE = {
	"Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·ÑƒÐ¹Ñ‚Ðµ: " .. MikSBT.COMMAND .. " <ÐºÐ¾Ð¼Ð°Ð½Ð´Ð°> [Ð¿Ð°Ñ€Ð°Ð¼ÐµÑ‚Ñ€]",
	" ÐšÐ¾Ð¼Ð°Ð½Ð´Ñ‹:",
	"  " .. L.COMMAND_RESET .. " - Ð¡Ð±Ñ€Ð¾Ñ Ñ‚ÐµÐºÑƒÑ‰ÐµÐ³Ð¾ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ñ Ð½Ð° ÑÑ‚Ð°Ð½Ð´Ð°Ñ€Ñ‚Ð½Ñ‹Ðµ Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸.",
	"  " .. L.COMMAND_DISABLE .. " - ÐžÑ‚ÐºÐ»ÑŽÑ‡Ð¸Ñ‚ÑŒ Ð´Ð°Ð½Ð½Ñ‹Ð¹ Ð¼Ð¾Ð´.",
	"  " .. L.COMMAND_ENABLE .. " - Ð’ÐºÐ»ÑŽÑ‡Ð¸Ñ‚ÑŒ Ð´Ð°Ð½Ð½Ñ‹Ð¹ Ð¼Ð¾Ð´.",
	"  " .. L.COMMAND_SHOWVER .. " - ÐŸÐ¾ÐºÐ°Ð·Ð°Ñ‚ÑŒ Ñ‚ÐµÐºÑƒÑ‰ÑƒÑŽ Ð²ÐµÑ€ÑÐ¸ÑŽ.",
	"  " .. L.COMMAND_HELP .. " - ÐŸÐ¾ÐºÐ°Ð·Ð°Ñ‚ÑŒ Ð´Ð¾ÑÑ‚ÑƒÐ¿Ð½Ñ‹Ðµ ÐºÐ¾Ð¼Ð°Ð½Ð´Ñ‹.",
}

L.MSG_DISABLE					= "ÐœÐ¾Ð´ Ð¾Ñ‚ÐºÐ»ÑŽÑ‡ÐµÐ½."
L.MSG_ENABLE					= "ÐœÐ¾Ð´ Ð²ÐºÐ»ÑŽÑ‡ÐµÐ½."
L.MSG_PROFILE_RESET				= "Ð¡Ð±Ñ€Ð¾Ñ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ñ"
L.MSG_HITS						= "ÐŸÐ¾Ð¿Ð°Ð´Ð°Ð½Ð¸Ñ"
L.MSG_CRIT						= "ÐšÑ€Ð¸Ñ‚"
L.MSG_CRITS						= "ÐšÑ€Ð¸Ñ‚Ð¾Ð²"
L.MSG_MULTIPLE_TARGETS			= "ÐÐµÑÐºÐ¾Ð»ÑŒÐºÐ¾"
L.MSG_READY_NOW					= "Ð“Ð¾Ñ‚Ð¾Ð²"

L.MSG_INCOMING			= "Ð’Ñ…Ð¾Ð´ÑÑ‰Ð¸Ð¹"
L.MSG_OUTGOING			= "Ð˜ÑÑ…Ð¾Ð´ÑÑ‰Ð¸Ð¹"
L.MSG_NOTIFICATION		= "Ð˜Ð·Ð²ÐµÑ‰ÐµÐ½Ð¸Ñ"
L.MSG_STATIC			= "Ð¡Ñ‚Ð°Ñ‚Ð¸Ñ‡ÐµÑÐºÐ¸Ð¹"

L.MSG_COMBAT					= "Ð‘Ð¾Ð¹"
L.MSG_DISPEL					= "Ð Ð°ÑÑÐµÑÐ½Ð¾"

L.MSG_CP						= "ÐŸÑ€Ð¸Ñ‘Ð¼ Ð² Ð¡ÐµÑ€Ð¸Ð¸"
L.MSG_CP_FULL					= "ÐŸÑ€Ð¸ÐºÐ¾Ð½Ñ‡Ð¸!"
L.MSG_HOLY_POWER_FULL			= "Ð­Ð½ÐµÑ€Ð³Ð¸Ñ Ð¡Ð²ÐµÑ‚Ð° Ð¿Ð¾Ð»Ð½Ð°"

L.MSG_KILLING_BLOW				= "ÐŸÐ¾Ð±ÐµÐ´Ð½Ñ‹Ð¹ ÑƒÐ´Ð°Ñ€!"
L.MSG_TRIGGER_LOW_HEALTH		= "ÐœÐ°Ð»Ñ‹Ð¹ Ð·Ð°Ð¿Ð°Ñ Ð·Ð´Ð¾Ñ€Ð¾Ð²ÑŒÑ"
L.MSG_TRIGGER_LOW_MANA			= "ÐœÐ°Ð»Ñ‹Ð¹ Ð·Ð°Ð¿Ð°Ñ Ð¼Ð°Ð½Ñ‹"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "ÐœÐ°Ð»Ñ‹Ð¹ Ð·Ð°Ð¿Ð°Ñ Ð·Ð´Ð¾Ñ€Ð¾Ð²ÑŒÑ Ð¿Ð¸Ñ‚Ð¾Ð¼Ñ†Ð°"

