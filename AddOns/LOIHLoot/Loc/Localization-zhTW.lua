----------------------------------------------------------------------
--	Traditional Chinese Localization

if GetLocale() ~= "zhTW" then return end
local ADDON_NAME, private = ...

local L = private.L

L = L or {}
L["BUTTON_SYNC"] = "同步"
L["CMD_DEBUGOFF"] = "debugoff"
L["CMD_DEBUGON"] = "debugon"
L["CMD_DUMP"] = "bossdump"
L["CMD_HELP"] = "help"
L["CMD_HIDE"] = "hide"
L["CMD_LIST"] = "/loihloot ( %s | %s | %s | %s | %s )"
L["CMD_RESET"] = "reset"
L["CMD_SAVENAMES"] = "savenames"
L["CMD_SHOW"] = "show"
L["CMD_STATUS"] = "status"
L["DISABLED"] = "停用"
L["DONT_NEED_LOOT_FROM_BOSS"] = "不需要此首領裝備的人:"
L["ENABLED"] = "啟用"
L["HELP_TEXT1"] = "輸入 /loihloot 或 /lloot 加上下面的參數:"
L["HELP_TEXT2"] = " - 顯示戰利品願望清單視窗"
L["HELP_TEXT3"] = " - 隱藏戰利品願望清單視窗"
L["HELP_TEXT4"] = " - 重置目前角色的願望清單"
L["HELP_TEXT5"] = " - 報告戰利品願望清單的狀態"
L["HELP_TEXT6"] = " - 啟用/停用戰利品願望視窗每個首領分別儲存玩家名字"
L["HELP_TEXT7"] = " - 顯示說明訊息"
L["HELP_TEXT8"] = "輸入指令但沒有附加參數時，會打開戰利品願望清單視窗。"
L["LONG_MAINSPEC"] = "主要專精"
L["LONG_OFFSPEC"] = "次要專精"
L["LONG_VANITY"] = "想要"
L["MAINTOOLTIP"] = "主要專精物品"
L["NEED_LOOT_FROM_BOSS"] = "需要此首領裝備的人:"
L["NEVER"] = "從未"
L["OFFTOOLTIP"] = "次要專精物品"
L["PRT_DEBUG_FALSE"] = "%s 已關閉除錯。"
L["PRT_DEBUG_TRUE"] = "%s 已開啟除錯。"
L["PRT_RESET_DONE"] = "已重置角色的願望清單。"
L["PRT_SAVENAMES"] = "每個首領分別儲存名字: %s"
L["PRT_STATUS"] = "%s 使用 %.0fkB 記憶體。"
L["PRT_UNKOWN_DIFFICULTY"] = "錯誤 - 未知的團隊副本難度! 不會傳送同步請求"
L["REMINDER"] = "請記得在冒險指南中將你的角色需求的裝備加入願望清單 (在戰利品標籤頁面中勾選)"
L["SENDING_SYNC"] = [=[正在傳送同步要求...
停用同步按鈕會顯示 15 秒。]=]
L["SHORT_MAINSPEC"] = "主要"
L["SHORT_OFFSPEC"] = "次要"
L["SHORT_SYNC_LINE"] = "上次同步: %s"
L["SHORT_VANITY"] = "貪"
L["SYNC_LINE"] = "上次同步 (%s): %s (%d/%d 個團隊成員回應)"
L["SYNCSTATUS_INCOMPLETE"] = "上次同步後成員已改變!"
L["SYNCSTATUS_MISSING"] = "尚未同步!"
L["SYNCSTATUS_OK"] = "同步完成"
L["TAB_WISHLIST"] = "願望清單"
L["TOOLTIP_WISHLIST_ADD"] = "加入願望清單。"
L["TOOLTIP_WISHLIST_HIGHER"] = [=[降低到這個難度。
願望清單中已有來自更高難度的。]=]
L["TOOLTIP_WISHLIST_LOWER"] = [=[升級到這個難度。
願望清單中已有來自較低難度的。]=]
L["TOOLTIP_WISHLIST_REM"] = "從願望清單中移除。"
L["UNKNOWN"] = "未知"
L["VANITYTOOLTIP"] = "想要物品"
L["WISHLIST"] = "願望清單"

-- 自行加入
L["LOIHLoot"] = "願望清單"
L["LOIHLOOT"] = "戰利品願望清單"
L.HELP_TEXT = {
	L.HELP_TEXT1,
	"   " .. L.CMD_SHOW    .. L.HELP_TEXT2,
	"   " .. L.CMD_HIDE    .. L.HELP_TEXT3,
	"   " .. L.CMD_RESET    .. L.HELP_TEXT4,
	"   " .. L.CMD_STATUS  .. L.HELP_TEXT5,
	"   " .. L.CMD_SAVENAMES .. L.HELP_TEXT6,
	"   " .. L.CMD_HELP .. L.HELP_TEXT7,
	L.HELP_TEXT8,
}

