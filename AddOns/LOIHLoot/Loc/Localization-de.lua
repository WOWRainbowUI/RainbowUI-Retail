----------------------------------------------------------------------
--	German Localization

if GetLocale() ~= "deDE" then return end
local ADDON_NAME, private = ...

local L = private.L

L = L or {}
L["BUTTON_SYNC"] = "Sync"
--[[Translation missing --]]
L["CMD_DEBUGOFF"] = "debugoff"
--[[Translation missing --]]
L["CMD_DEBUGON"] = "debugon"
--[[Translation missing --]]
L["CMD_DUMP"] = "bossdump"
L["CMD_HELP"] = "hilfe"
L["CMD_HIDE"] = "verstecken"
L["CMD_LIST"] = "/loihloot ( %s | %s | %s | %s | %s )"
L["CMD_RESET"] = "zurücksetzen"
--[[Translation missing --]]
L["CMD_SAVENAMES"] = "savenames"
L["CMD_SHOW"] = "zeigen"
L["CMD_STATUS"] = "status"
--[[Translation missing --]]
L["DISABLED"] = "Disabled"
--[[Translation missing --]]
L["DONT_NEED_LOOT_FROM_BOSS"] = "Don't need loot from this boss:"
--[[Translation missing --]]
L["ENABLED"] = "Enabled"
L["HELP_TEXT1"] = "Benutze /loihloot oder /lloot mit den folgenden Befehlen:"
L["HELP_TEXT2"] = "– Zeigt das LOIHLoot-Fenster"
L["HELP_TEXT3"] = "– Versteckt das LOIHLoot-Fenster"
L["HELP_TEXT4"] = "– Setzt die aktuelle Wunschliste des Charakters zurück"
L["HELP_TEXT5"] = "– Berichtet den Status von LOIHLoot"
--[[Translation missing --]]
L["HELP_TEXT6"] = " - enable/disable saving player names per boss for LOIHLoot window"
L["HELP_TEXT7"] = "– Zeigt diese Hilfenachricht"
L["HELP_TEXT8"] = "Benutze den Slash-Befehl ohne zusätzliche Befehle, um das LOIHLoot-Fenster zu zeigen."
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
L["PRT_DEBUG_FALSE"] = "%s Debugging ist AUS."
L["PRT_DEBUG_TRUE"] = "%s Debugging ist AN."
L["PRT_RESET_DONE"] = "Charakter-Wunschliste zurückgesetzt."
--[[Translation missing --]]
L["PRT_SAVENAMES"] = "Save names per boss: %s"
L["PRT_STATUS"] = "%s benutzt %.0fkB Speicher."
L["PRT_UNKOWN_DIFFICULTY"] = "FEHLER – Unbekannte Schlachtzugsschwierigkeit! Sende keine Syncanfrage"
L["REMINDER"] = "Vergesse nicht die Wunschliste deines Charakters im Abenteuerführer zu füllen (Du findest die Wunschlistentaste im Beutereiter)."
L["SENDING_SYNC"] = [=[Sende Synchronisierungsanfrage
Sync-Button für 15 Sekunden deaktiviert.]=]
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
L["TAB_WISHLIST"] = "Wunschliste"
L["TOOLTIP_WISHLIST_ADD"] = "Zur Wunschliste hinzufügen."
L["TOOLTIP_WISHLIST_HIGHER"] = [=[Verschlechtern auf diese Schwierigkeit.
Bereits auf deiner Wunschliste mit höherer Schwierigkeit.]=]
L["TOOLTIP_WISHLIST_LOWER"] = [=[Verbessern auf diese Schwierigkeit.
Bereits auf deiner Wunschliste mit niedrigerer Schwierigkeit.]=]
L["TOOLTIP_WISHLIST_REM"] = "Von Wunschliste entfernen."
L["UNKNOWN"] = "Unbekannt"
--[[Translation missing --]]
L["VANITYTOOLTIP"] = "Vanity items"
--[[Translation missing --]]
L["WISHLIST"] = "Wishlist"
