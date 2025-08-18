----------------------------------------------------------------------
--	Simplified Chinese Localization

if GetLocale() ~= "zhCN" then return end
local ADDON_NAME, private = ...

local L = private.L

L = L or {}
--[[Translation missing --]]
L["BUTTON_SYNC"] = "Sync"
--[[Translation missing --]]
L["CMD_DEBUGOFF"] = "debugoff"
--[[Translation missing --]]
L["CMD_DEBUGON"] = "debugon"
--[[Translation missing --]]
L["CMD_DUMP"] = "bossdump"
--[[Translation missing --]]
L["CMD_HELP"] = "help"
--[[Translation missing --]]
L["CMD_HIDE"] = "hide"
--[[Translation missing --]]
L["CMD_LIST"] = "/loihloot ( %s | %s | %s | %s | %s )"
--[[Translation missing --]]
L["CMD_RESET"] = "reset"
--[[Translation missing --]]
L["CMD_SAVENAMES"] = "savenames"
--[[Translation missing --]]
L["CMD_SHOW"] = "show"
--[[Translation missing --]]
L["CMD_STATUS"] = "status"
--[[Translation missing --]]
L["DISABLED"] = "Disabled"
--[[Translation missing --]]
L["DONT_NEED_LOOT_FROM_BOSS"] = "Don't need loot from this boss:"
--[[Translation missing --]]
L["ENABLED"] = "Enabled"
--[[Translation missing --]]
L["HELP_TEXT1"] = "Use /loihloot or /lloot with the following commands:"
--[[Translation missing --]]
L["HELP_TEXT2"] = " - show LOIHLoot window"
--[[Translation missing --]]
L["HELP_TEXT3"] = " - hide LOIHLoot window"
--[[Translation missing --]]
L["HELP_TEXT4"] = " - reset current character's wishlist"
--[[Translation missing --]]
L["HELP_TEXT5"] = " - report the status of LOIHLoot"
--[[Translation missing --]]
L["HELP_TEXT6"] = " - enable/disable saving player names per boss for LOIHLoot window"
--[[Translation missing --]]
L["HELP_TEXT7"] = " - show this help message"
--[[Translation missing --]]
L["HELP_TEXT8"] = "Use the slash command without any additional commands to toggle the LOIHLoot window."
--[[Translation missing --]]
L["LONG_MAINSPEC"] = "Mainspec"
--[[Translation missing --]]
L["LONG_OFFSPEC"] = "Offspec"
--[[Translation missing --]]
L["LONG_VANITY"] = "Vanity"
--[[Translation missing --]]
L["MAINTOOLTIP"] = "Mainspec items"
--[[Translation missing --]]
L["NEED_LOOT_FROM_BOSS"] = "Need loot from this boss:"
--[[Translation missing --]]
L["NEVER"] = "Never"
--[[Translation missing --]]
L["OFFTOOLTIP"] = "Offspec items"
--[[Translation missing --]]
L["PRT_DEBUG_FALSE"] = "%s debugging is OFF."
--[[Translation missing --]]
L["PRT_DEBUG_TRUE"] = "%s debugging is ON."
--[[Translation missing --]]
L["PRT_RESET_DONE"] = "Character wishlist reseted."
--[[Translation missing --]]
L["PRT_SAVENAMES"] = "Save names per boss: %s"
--[[Translation missing --]]
L["PRT_STATUS"] = "%s is using %.0fkB of memory."
--[[Translation missing --]]
L["PRT_UNKOWN_DIFFICULTY"] = "ERROR - Unknown raid difficulty! Not sending SyncRequest"
--[[Translation missing --]]
L["REMINDER"] = "Remember to fill your character's wishlist at Encounter Journal (Check the Loot-tab for wishlist-buttons)."
--[[Translation missing --]]
L["SENDING_SYNC"] = [=[Sending sync request...
Disabling Sync-button for 15 seconds.]=]
--[[Translation missing --]]
L["SHORT_MAINSPEC"] = "M"
--[[Translation missing --]]
L["SHORT_OFFSPEC"] = "O"
--[[Translation missing --]]
L["SHORT_SYNC_LINE"] = "Last sync: %s"
--[[Translation missing --]]
L["SHORT_VANITY"] = "V"
--[[Translation missing --]]
L["SYNC_LINE"] = "Last sync (%s): %s (%d/%d in raid replied)"
--[[Translation missing --]]
L["SYNCSTATUS_INCOMPLETE"] = "Roster changed since last sync!"
--[[Translation missing --]]
L["SYNCSTATUS_MISSING"] = "NO Sync!"
--[[Translation missing --]]
L["SYNCSTATUS_OK"] = "Sync OK"
--[[Translation missing --]]
L["TAB_WISHLIST"] = "Wishlist"
--[[Translation missing --]]
L["TOOLTIP_WISHLIST_ADD"] = "Add to wishlist."
--[[Translation missing --]]
L["TOOLTIP_WISHLIST_HIGHER"] = [=[Downgrade to this difficulty.
Already on wishlist from higher difficulty.]=]
--[[Translation missing --]]
L["TOOLTIP_WISHLIST_LOWER"] = [=[Upgrade to this difficulty.
Already on wishlist from lower difficulty.]=]
--[[Translation missing --]]
L["TOOLTIP_WISHLIST_REM"] = "Remove from wishlist."
--[[Translation missing --]]
L["UNKNOWN"] = "Unknown"
--[[Translation missing --]]
L["VANITYTOOLTIP"] = "Vanity items"
--[[Translation missing --]]
L["WISHLIST"] = "Wishlist"
