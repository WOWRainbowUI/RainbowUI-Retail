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
L["OPTIONS_ENABLE"] = "啟用"
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
L["OPTIONS_COLOR_OUTLINE"] = "外框顏色"
L["OPTIONS_ICON_STYLE"] = "圖示風格"
L["OPTIONS_ICON_TINT"] = "啟用圖示顏色"
L["OPTIONS_ICON_COLOR"] = "圖示顏色"
L["OPTIONS_ICON_TINT_MAIN"] = "啟用主圖示顏色"
L["OPTIONS_ICON_COLOR_MAIN"] = "主圖示顏色"
L["OPTIONS_ICON_TINT_QUEST"] = "啟用任務圖示"
L["OPTIONS_ICON_COLOR_QUEST"] = "任務圖示顏色"
L["OPTIONS_SHOW_KILL_ICON"] = "顯示擊殺圖示"
L["OPTIONS_SHOW_LOOT_ICON"] = "顯示拾取圖示"
L["OPTIONS_QUEST_TYPE_ICONS"] = "任務類型圖示"
L["OPTIONS_ICON_OFFSETS"] = "任務類型圖示偏移"
L["OPTIONS_ANIMATE_ICON"] = "主圖示動畫效果"
L["OPTIONS_RESET_MAIN_ICON"] = "重置主圖示設定"
L["OPTIONS_RESET_QUEST_ICONS"] = "重置任務圖示設定"
L["OPTIONS_KILL_ICON_OFFSET_X"] = "擊殺 X"
L["OPTIONS_KILL_ICON_OFFSET_Y"] = "擊殺 Y"
L["OPTIONS_LOOT_ICON_OFFSET_X"] = "拾取 X"
L["OPTIONS_LOOT_ICON_OFFSET_Y"] = "拾取 Y"
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
L["SETTINGS_RESET"] = "|cff58be81所有設定都已重置成預設值|r"

-- 自行加入
-- Core
L["PANEL_NAME"] = "任務-提示"
L["RESET_CONFIRM"] = "|cff58be81任務怪提示|r\n\n是否確定要將所有設定重置成預設值?"

-- General
L["OPTIONS_ADDON_STATE"] = "插件狀態"
L["OPTIONS_DISABLE"] = "停用"
L["OPTIONS_GENERAL"] = "一般設定"
L["OPTIONS_DEBUG"] = "啟用除錯模式"
L["OPTIONS_CHAT_MESSAGES"] = "顯示聊天訊息"
L["|cff58be81Animation|r"] = "動畫"
L["Use Global Animation Override"] = "使用整體動畫覆蓋"
L["Enable All Animations"] = "啟用所有動畫"
L["Animate When"] = "動畫觸發時機"
L["Always"] = "總是"
L["Combat"] = "戰鬥中"
L["No Combat"] = "非戰鬥中"
L["Global Intensity: %d%%"] = "整體顯著程度：%d%%"
L["OPTIONS_COMBAT"] = "戰鬥設定"
L["OPTIONS_HIDE_COMBAT"] = "戰鬥中隱藏圖示"
L["OPTIONS_HIDE_INSTANCE"] = "副本中隱藏圖示"
L["|cff58be81Position & Scale|r"] = "|cff58be81位置與縮放|r"
L["Scale: %.1f"] = "縮放比例: %.1f"
L["Scale: 1.1"] = "縮放比例: 1.1"
L["Scale: %.1f"] = "縮放比例: %.1f"
L["Offset X: %d"] = "水平偏移 (X): %d"
L["Offset X: 0"] = "水平偏移 (X): 0"
L["Offset X: %d"] = "水平偏移 (X): %d"
L["Offset Y: %d"] = "垂直偏移 (Y): %d"
L["Offset Y: 3"] = "垂直偏移 (Y): 3"
L["Offset Y: %d"] = "垂直偏移 (Y): %d"
L["Nameplate Side"] = "名條旁邊"
L["Left Side"] = "左側"
L["Right Side"] = "右側"

-- Icon
L["OPTIONS_ICON_POSITION"] = "圖示位置"
L["Left Side"] = "左側"
L["Right Side"] = "右側"
L["Display Style"] = "顯示樣式"
L["Icon"] = "圖示"
L["Text"] = "文字"
L["|cff58be81Main Icon Tinting|r"] = "|cff58be81主圖示顏色|r"
L["Enable Tinting"] = "啟用顏色"
L["Tint Color"] = "顏色"
L["|cff58be81Icon Tinting|r"] = "|cff58be81圖示顏色|r"

-- Kill
L["|cff58be81Kill Icon|r"] = "|cff58be81擊殺圖示|r"
L["Show Kill Icon"] = "顯示擊殺圖示"
L["|cff58be81Animate|r"] = "|cff58be81動畫效果|r"
L["Animate Task Icons"] = "工作列圖示顯示動畫"
L["Animate Main Icon"] = "主圖示顯示動畫"
L["Intensity: %d%%"] = "顯著程度: %d%%"
L["Intensity: 100%"] = "顯著程度: 100%"
L["|cff58be81Color|r"] = "|cff58be81顏色|r"
L["Kill Color"] = "擊殺顏色"
L["|cffaaaaaa(Shared with Loot tab)|r"] = "|cffaaaaaa(和拾取標籤頁共用)|r"
L["|cff58be81Size & Position|r"] = "|cff58be81大小與位置|r"
L["Size"] = "大小"
L["Offset X"] = "水平偏移"
L["Offset Y"] = "垂直偏移"
L["Reset Kill Settings"] = "重置擊殺設定"

-- Loot
L["|cff58be81Loot Icon|r"] = "|cff58be81拾取圖示|r"
L["Show Loot Icon"] = "顯示拾取圖示"
L["Loot Color"] = "拾取顏色"
L["|cffaaaaaa(Shared with Kill tab)|r"] = "|cffaaaaaa(和擊殺標籤頁共用)|r"
L["Reset Loot Settings"] = "重置拾取設定"

-- Percent
L["|cff58be81Percent Icon|r"] = "|cff58be81百分比圖示|r"
L["|cffaaaaaaShown for quests tracked by percentage (area/time).|r"] = "|cffaaaaaa用於按百分比 (區域/時間) 追蹤的任務。|r"
L["Show Percent Icon"] = "顯示百分比圖示"
L["Percent Color"] = "百分比顏色"
L["Reset Percent Settings"] = "重置百分比設定"
L["|cff58be81Position|r"] = "|cff58be81位置|r"

-- Preview
L["|cff58be81Live Preview|r"] = "|cff58be81即時預覽|r"
L["Murloc Warrior"] = "魚人戰士"
L["Level 15"] = "等級 15"
L["Kill Quest"] = "擊殺任務"
L["Loot Quest"] = "拾取任務"
L["% Quest"] = "% 任務"

-- Tabs
L["Global"]= "整體"
L["Main Icon"] = "主圖示"
L["Kill"] = "擊殺"
L["Loot"] = "拾取"
L["Percent"] = "百分比"
L["About"] = "關於"

-- header
L["|cff58be81S|r|cffffffffimple |cff58be81Q|r|cffffffffuest |cff58be81P|r|cfffffffflates|r|cff58be81!|r"] = "簡易任務怪提示 |cff58be81S|r|cffffffffimple |cff58be81Q|r|cffffffffuest |cff58be81P|r|cfffffffflates|r|cff58be81!|r"
L["Quest tracking overlay for enemy nameplates"] = "在怪物血條上顯示任務追蹤圖示"

-- widgets
L["|cff58be81Font|r"] = "|cff58be81文字|r"
L["Size: %d"] = "大小: %d"
L["Family"] = "字型"
L["|cff58be81Display Style|r"] = "|cff58be81顯示樣式|r"
L["Icon"] = "圖示"
L["Text"] = "文字"
L["Tint Kill Icon"] = "擊殺圖示顏色"
L["Tint Loot Icon"] = "拾取圖示顏色"
L["Tint Percent Sign"] = "百分比圖示顏色"