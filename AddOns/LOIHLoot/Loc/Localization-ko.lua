----------------------------------------------------------------------
--	Korean Localization

if GetLocale() ~= "koKR" then return end
local ADDON_NAME, private = ...

local L = private.L

L = L or {}
L["BUTTON_SYNC"] = "동기화"
L["CMD_DEBUGOFF"] = "debugoff"
L["CMD_DEBUGON"] = "debugon"
L["CMD_DUMP"] = "bossdump"
L["CMD_HELP"] = "help"
L["CMD_HIDE"] = "hide"
L["CMD_LIST"] = "/lloot ( %s | %s | %s | %s | %s )"
L["CMD_RESET"] = "reset"
--[[Translation missing --]]
L["CMD_SAVENAMES"] = "savenames"
L["CMD_SHOW"] = "show"
L["CMD_STATUS"] = "status"
--[[Translation missing --]]
L["DISABLED"] = "Disabled"
--[[Translation missing --]]
L["DONT_NEED_LOOT_FROM_BOSS"] = "Don't need loot from this boss:"
--[[Translation missing --]]
L["ENABLED"] = "Enabled"
L["HELP_TEXT1"] = "다음 명령어와 함께 /loihloot 또는 /lloot를 사용하세요:"
L["HELP_TEXT2"] = " - LOIHLoot 창 표시"
L["HELP_TEXT3"] = " - LOIHLoot 창 숨김"
L["HELP_TEXT4"] = " - 현재 캐릭터의 희망 목록 초기화"
L["HELP_TEXT5"] = " - LOIHLoot 상태 보고"
--[[Translation missing --]]
L["HELP_TEXT6"] = " - enable/disable saving player names per boss for LOIHLoot window"
L["HELP_TEXT7"] = " - 이 도움말 메시지 표시"
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
L["PRT_RESET_DONE"] = "캐릭터 희망 목록이 초기화되었습니다."
--[[Translation missing --]]
L["PRT_SAVENAMES"] = "Save names per boss: %s"
L["PRT_STATUS"] = "%s|1은;는; %.0fkB 메모리를 사용 중입니다."
L["PRT_UNKOWN_DIFFICULTY"] = "오류 - 알 수 없는 공격대 난이도! SyncRequest 전송 안 함"
--[[Translation missing --]]
L["REMINDER"] = "Remember to fill your character's wishlist at Encounter Journal (Check the Loot-tab for wishlist-buttons)."
L["SENDING_SYNC"] = [=[동기화 요청 전송 중...
동기화 버튼을 15초 동안 사용 중지합니다.]=]
--[[Translation missing --]]
L["SHORT_MAINSPEC"] = "M"
--[[Translation missing --]]
L["SHORT_OFFSPEC"] = "O"
L["SHORT_SYNC_LINE"] = "마지막 동기화: %s"
--[[Translation missing --]]
L["SHORT_VANITY"] = "V"
--[[Translation missing --]]
L["SYNC_LINE"] = "Last sync (%s): %s (%d/%d in raid replied)"
L["SYNCSTATUS_INCOMPLETE"] = "최근 동기화 이후로 목록 변경됨!"
L["SYNCSTATUS_MISSING"] = "동기화 안 함!"
L["SYNCSTATUS_OK"] = "동기화 OK"
L["TAB_WISHLIST"] = "희망 목록"
L["TOOLTIP_WISHLIST_ADD"] = "희망 목록에 추가합니다."
L["TOOLTIP_WISHLIST_HIGHER"] = [=[이 난이도로 내립니다.
이미 더 높은 난이도의 희망 목록에 있습니다.]=]
L["TOOLTIP_WISHLIST_LOWER"] = [=[이 난이도로 올립니다.
이미 더 낮은 난이도의 희망 목록에 있습니다.]=]
L["TOOLTIP_WISHLIST_REM"] = "희망 목록에서 제거합니다."
--[[Translation missing --]]
L["UNKNOWN"] = "Unknown"
--[[Translation missing --]]
L["VANITYTOOLTIP"] = "Vanity items"
L["WISHLIST"] = "희망 목록"
