--=====================================================================================
-- RGX | Simple Quest Plates! - zhTW.lua
-- Version: 1.0.0
-- Author: 彩虹ui
-- Description: Traditional Chinese localization
--=====================================================================================

local addonName, SQP = ...
local locale = GetLocale()

if locale ~= "zhTW" then return end

local L = SQP.L or {}


-- Options Panel
L["OPTIONS_ENABLE"] = "啟用任務怪提示"
L["OPTIONS_DISPLAY"] = "顯示設定"
L["OPTIONS_SCALE"] = "圖示縮放"
L["OPTIONS_OFFSET_X"] = "水平偏移"
L["OPTIONS_OFFSET_Y"] = "垂直偏移"
L["OPTIONS_ANCHOR"] = "在名條的哪一側"
L["OPTIONS_TEST"] = "測試偵測"
L["OPTIONS_RESET"] = "重置所有設定"
L["OPTIONS_RESET_FONT"] = "重置字體設定"
L["OPTIONS_RESET_ICON"] = "重置圖示設定"
L["OPTIONS_FONT_SIZE"] = "文字大小"
L["OPTIONS_FONT_FAMILY"] = "字型"
L["OPTIONS_GLOBAL_SCALE"] = "整體縮放"
L["OPTIONS_FONT_OUTLINE"] = "文字描邊"
L["OPTIONS_CUSTOM_COLORS"] = "使用自訂顏色"
L["OPTIONS_COLORS"] = "顏色"
L["OPTIONS_COLOR_KILL"] = "擊殺任務"
L["OPTIONS_COLOR_ITEM"] = "拾取物品任務"
L["OPTIONS_COLOR_PERCENT"] = "進度%任務"
L["OPTIONS_ICON_STYLE"] = "圖示風格"
L["OPTIONS_ICON_TINT"] = "啟用圖示顏色"
L["OPTIONS_ICON_COLOR"] = "圖示顏色"
L["OPTIONS_SIZE"] = "大小"
L["OPTIONS_POSITION"] = "位置"

-- Commands
L["CMD_ENABLED"] = "現在已 |cff00ff00啟用|r"
L["CMD_DISABLED"] = "現在已 |cffff0000停用|r"
L["CMD_VERSION"] = "Simple Quest Plates 版本: |cff58be81%s|r"
L["CMD_SCALE_SET"] = "圖示縮放已設定為: |cff58be81%.1f|r"
L["CMD_SCALE_INVALID"] = "|cffff0000無效的縮放值。請使用 0.5 到 2.0 之間的數字|r"
L["CMD_OFFSET_SET"] = "圖示偏移已設定為: |cff58be81X=%d Y=%d|r"
L["CMD_OFFSET_INVALID"] = "|cffff0000無效的偏移值。請使用 -50 到 50 之間的數字|r"
L["CMD_RESET"] = "|cff58be81所有設定已重置為預設值|r"
L["CMD_STATUS"] = "|cff58be81Simple Quest Plates 狀態:|r"
L["CMD_STATUS_STATE"] = "  狀態: %s"
L["CMD_STATUS_SCALE"] = "  縮放: |cff58be81%.1f|r"
L["CMD_STATUS_OFFSET"] = "  偏移: |cff58be81X=%d Y=%d|r"
L["CMD_STATUS_ANCHOR"] = "  位置: |cff58be81%s|r"
L["CMD_HELP_HEADER"] = "|cff58be81Simple Quest Plates 指令:|r"
L["CMD_HELP_ENABLE"] = "  |cfffff569/sqp on|r - 啟用插件"
L["CMD_HELP_DISABLE"] = "  |cfffff569/sqp off|r - 停用插件"
L["CMD_HELP_SCALE"] = "  |cfffff569/sqp scale <0.5-2.0>|r - 設定圖示縮放"
L["CMD_HELP_OFFSET"] = "  |cfffff569/sqp offset <x> <y>|r - 設定圖示偏移 (-50 到 50)"
L["CMD_HELP_OPTIONS"] = "  |cfffff569/sqp options|r - 開啟設定面板"
L["CMD_HELP_TEST"] = "  |cfffff569/sqp test|r - 測試任務偵測"
L["CMD_HELP_STATUS"] = "  |cfffff569/sqp status|r - 顯示目前設定"
L["CMD_HELP_RESET"] = "  |cfffff569/sqp reset|r - 重置所有設定"
L["CMD_HELP_VERSION"] = "  |cfffff569/sqp version|r - 顯示插件版本"
L["CMD_HELP_HELP"] = "  |cfffff569/sqp help|r - 顯示此說明選單"
L["CMD_TEST"] = "正在測試任務偵測..."
L["CMD_OPTIONS_OPENED"] = "設定面板已開啟"

-- Quest Detection
L["QUEST_PROGRESS_KILL"] = "擊殺: %d/%d"
L["QUEST_PROGRESS_ITEM"] = "收集: %d/%d"
L["QUEST_TEST_ACTIVE"] = "找到進行中的任務目標: %d"
L["QUEST_TEST_NONE"] = "未找到進行中的任務目標"
L["TEST_FOUND_QUESTS"] = "找到 %d 個單位有任務目標"
L["TEST_NO_QUESTS"] = "在可見的名條上未找到任務目標"

-- Messages
L["MSG_LOADED"] = "v%s 載入成功。輸入 |cfffff569/sqp help|r 查看指令。"
L["MSG_DISCORD"] = "加入我們的 Discord: |cff58be81discord.gg/N7kdKAHVVF|r"

-- 自行加入
-- General
L["OPTIONS_GENERAL"] = "一般設定"
L["OPTIONS_DEBUG"] = "啟用除錯模式"
L["OPTIONS_CHAT_MESSAGES"] = "顯示聊天訊息"
L["OPTIONS_COMBAT"] = "戰鬥設定"
L["OPTIONS_HIDE_COMBAT"] = "戰鬥中隱藏圖示"
L["OPTIONS_HIDE_INSTANCE"] = "副本中隱藏圖示"

-- Font
L["OPTIONS_FONT_SETTINGS"] = "文字設定"
L["OPTIONS_OUTLINE_WIDTH"] = "文字外框"
L["None"] = "無"
L["Normal"] = "一般"
L["Thick"] = "粗"
L["OPTIONS_TEXT_COLORS"] = "文字顏色"
L["Reset"] = "重置"

-- Icon
L["OPTIONS_ICON_POSITION"] = "圖示位置"
L["Left Side"] = "左側"
L["Right Side"] = "右側"
