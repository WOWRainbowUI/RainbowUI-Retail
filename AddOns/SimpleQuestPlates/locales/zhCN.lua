--=====================================================================================
-- RGX | Simple Quest Plates! - zhCN.lua
-- Version: 1.0.0
-- Author: 任昊天
-- Description: Simplified Chinese localization
--=====================================================================================

local addonName, SQP = ...
local locale = GetLocale()

if locale ~= "zhCN" then return end

local L = SQP.L or {}

-- Simplified Chinese translations
L["OPTIONS_ENABLE"] = "启用简易任务面板"
L["OPTIONS_DISPLAY"] = "显示设置"
L["OPTIONS_SCALE"] = "图标缩放"
L["OPTIONS_OFFSET_X"] = "水平偏移"
L["OPTIONS_OFFSET_Y"] = "垂直偏移"
L["OPTIONS_ANCHOR"] = "图标位置"
L["OPTIONS_TEST"] = "测试检测"
L["OPTIONS_RESET"] = "重置所有设置"
L["OPTIONS_RESET_FONT"] = "重置字体设置"
L["OPTIONS_RESET_ICON"] = "重置图标设置"
L["OPTIONS_FONT_SIZE"] = "字体大小"
L["OPTIONS_FONT_FAMILY"] = "字体"
L["OPTIONS_GLOBAL_SCALE"] = "整体缩放"
L["OPTIONS_FONT_OUTLINE"] = "文本轮廓"
L["OPTIONS_CUSTOM_COLORS"] = "使用自定义颜色"
L["OPTIONS_COLORS"] = "颜色"
L["OPTIONS_COLOR_KILL"] = "击杀任务"
L["OPTIONS_COLOR_ITEM"] = "物品任务"
L["OPTIONS_COLOR_PERCENT"] = "进度任务"
L["OPTIONS_ICON_STYLE"] = "图标风格"
L["OPTIONS_ICON_TINT"] = "启用图标着色"
L["OPTIONS_ICON_COLOR"] = "图标色调颜色"
L["OPTIONS_SIZE"] = "大小"
L["OPTIONS_POSITION"] = "位置"

-- Commands
L["CMD_ENABLED"] = "|cff00ff00已启用|r"
L["CMD_DISABLED"] = "|cffff0000已禁用|r"
L["CMD_VERSION"] = "Simple Quest Plates 版本: |cff58be81%s|r"
L["CMD_SCALE_SET"] = "图标缩放设置为: |cff58be81%.1f|r"
L["CMD_SCALE_INVALID"] = "|cffff0000无效的缩放值。请使用介于0.5到2.0之间的数字。|r"
L["CMD_OFFSET_SET"] = "图标偏移量设置为: |cff58be81X=%d, Y=%d|r"
L["CMD_OFFSET_INVALID"] = "|cffff0000偏移值无效。请使用介于-50和50之间的数字。|r"
L["CMD_RESET"] = "|cff58be81所有设置已重置为默认值|r"
L["CMD_STATUS"] = "|cff58be81Simple Quest Plates 状态:|r"
L["CMD_STATUS_STATE"] = " 状态: %s"
L["CMD_STATUS_SCALE"] = " 缩放: |cff58be81%.1f|r"
L["CMD_STATUS_OFFSET"] = " 偏移量: |cff58be81X=%d, Y=%d|r"
L["CMD_STATUS_ANCHOR"] = " 位置: |cff58be81%s|r"
L["CMD_HELP_HEADER"] = "|cff58be81Simple Quest Plates 命令:|r"
L["CMD_HELP_ENABLE"] = " |cfffff569/sqp on|r - 启用插件"
L["CMD_HELP_DISABLE"] = " |cfffff569/sqp off|r - 禁用插件"
L["CMD_HELP_SCALE"] = " |cfffff569/sqp scale <0.5-2.0>|r - 设置图标缩放"
L["CMD_HELP_OFFSET"] = " |cfffff569/sqp offset |r - 设置偏移值 (-50 到 50)"
L["CMD_HELP_OPTIONS"] = " |cfffff569/sqp options|r - 打开设置面板"
L["CMD_HELP_TEST"] = " |cfffff569/sqp test|r - 测试任务检测"
L["CMD_HELP_STATUS"] = " |cfffff569/sqp status|r - 显示当前设置"
L["CMD_HELP_RESET"] = " |cfffff569/sqp reset|r - 重置所有设置"
L["CMD_HELP_VERSION"] = " |cfffff569/sqp version|r - 显示插件版本"
L["CMD_HELP_HELP"] = " |cfffff569/sqp help|r - 显示这个帮助菜单"
L["CMD_TEST"] = "开始测试任务检测..."
L["CMD_OPTIONS_OPENED"] = "设置面板已打开"

-- Quest Detection
L["QUEST_PROGRESS_KILL"] = "击杀: %d/%d"
L["QUEST_PROGRESS_ITEM"] = "收集: %d/%d"
L["QUEST_TEST_ACTIVE"] = "发现任务物品: %d"
L["QUEST_TEST_NONE"] = "未发现任务物品"
L["TEST_FOUND_QUESTS"] = "发现 %d 个带有任务目标的单位"
L["TEST_NO_QUESTS"] = "可见姓名板上未找到任务目标"

-- Messages
L["MSG_LOADED"] = "v%s 读取成功. 输入 |cfffff569/sqp help|r 获取命令帮助."
L["MSG_DISCORD"] = "加入我们的Discord: |cff58be81discord.gg/N7kdKAHVVF|r"