-- Please use the Localization App on CurseForge to Update this
-- https://legacy.curseforge.com/wow/addons/mythicpluspullreestimated/localization
local name, _ = ...

local L = LibStub("AceLocale-3.0"):NewLocale(name, "zhCN")
if not L then return end

-- MythicPlusPullReEstimated
--[[Translation missing --]]
L["A long way of writing 100%%."] = "A long way of writing 100%%."
L["Adds percentage info to the unit tooltip"] = "在鼠标提示显进度百分比"
L["Adds the % info to the enemy nameplates"] = "在敌方姓名板显示进度百分比"
L["Allows addons and WAs that use MythicDungeonTools for % info to work with this addon instead."] = "允许调用 MDT 进度数据的插件或 WA 以此插件代替。"
L["Are you sure you want to reset the NPC data to the defaults?"] = "确定要将所有数据重置回默认？"
L["Are you sure you want to wipe all data?"] = "确定要清除所有数据？"
L["Color of the text on the enemy nameplates"] = "敌方姓名板上的进度文本颜色"
L["CTRL-C to copy"] = "CTRL-C 复制"
L["Current pull:"] = "当前进度："
L["Debug"] = "偵錯"
--[[Translation missing --]]
L["Debug Criteria Events"] = "Debug Criteria Events"
L["Debug New NPC Scores"] = "Debug 新 NPC 分数"
L["Developer Options"] = "开发者选项"
L["Disabled when MythicDungeonTools is loaded"] = "若 MDT 已载入则停用"
L["Display a frame with current pull information"] = "在屏幕上显示一个计算当前拉怪进度的框架"
L["Enable Current Pull frame"] = "启用当前进度框架"
L["Enable MDT Emulation"] = "启用 MDT 模拟"
L["Enable Nameplate Text"] = "启用姓名板文本"
L["Enable Tooltip"] = "启用鼠标提示"
L["Enable/Disable debug prints"] = "启用/停用 debug 信息打印"
--[[Translation missing --]]
L["Enable/Disable debug prints for criteria events, ignores the Debug Print setting"] = "Enable/Disable debug prints for criteria events, ignores the Debug Print setting"
L["Enable/Disable debug prints for new NPC scores"] = "启用/停用 debug 信息打印新的 NPC 分数"
L["Enable/Disable Simulation Mode"] = "启用/停用模拟模式"
L["Enable/Disable the addon"] = "启用/停用本插件"
L["Enabled"] = "启用"
L["Experimental"] = "实验性"
L["Export NPC data"] = "导出 NPC 数据"
L["Export only data that is different from the default values"] = "只导出与默认值不同的数据"
L["Export updated NPC data"] = "导出更新的 NPC 数据"
L["Horizontal offset ( <-> )"] = "水平偏移 ( <-> )"
L["Horizontal offset of the nameplate text"] = "姓名板文本的水平位置偏移"
L["Include Count"] = "包含分数"
L["Include the raw count value in the tooltip, as well as the percentage"] = "在鼠标提示中同时显示原始进度分数和进度百分比"
L["Lock frame"] = "锁定框架"
L["Lock the frame in place"] = "锁定框架位置"
L["M+Progress:"] = "大密进度："
L["Main Options"] = "主要选项"
L["MDT Emulation"] = "MDT 模拟"
L["MPP attempted to get missing setting:"] = "MPP 尝试取得丢失的设置："
L["MPP attempted to set missing setting:"] = "MPP 尝试重置丢失的设置："
L["MPP String Uninitialized."] = "MPP 字符串尚未初始化。"
L["Mythic Plus Progress"] = "Mythic Plus Progress 大秘进度"
L["Mythic Plus Progress tracker"] = "大秘进度追踪器"
L["Nameplate"] = "姓名板"
L["Nameplate Text Color"] = "姓名板文本颜色"
L["No Progress."] = "没有进度。"
L["No record."] = "没有纪录。"
L["No recorded mobs pulled or nameplates inactive."] = "没有拉怪，或姓名板未开启。"
L["NPC data patch version: %s, build %d (ts %d)"] = "NPC 数据版本：%s, build %d (ts %d)"
L["Only in combat"] = "只在战斗中"
L["Only show the frame when you are in combat"] = "只在战斗中显示进度预估框架"
L["Opens a popup which allows copying the data"] = "打开弹窗以复制数据"
L["Pull Estimate frame"] = "拉怪进度预估框架"
L["Reset NPC data"] = "重置 NPC 数据"
L["Reset position"] = "重置位置"
L["Reset position of Current Pull frame to the default"] = "将当前进度框架重置回默认位置"
L["Reset Settings to default"] = "重设回默认值"
L["Reset the NPC data to the default values"] = "将 NPC 数据重置为默认值"
L["Running first time setup. This should only happen once. Enjoy! ;)"] = "进行初始设置，这只会有一次。祝你玩得愉快！"
L["Simulated number of 'points' currently earned"] = "模拟目前获得的分数"
L["Simulated number of 'points' required to complete the run"] = "模拟通关副本需要的分数"
L["Simulation Current Points"] = "模拟当前分数"
L["Simulation Mode"] = "模拟模式"
L["Simulation Required Points"] = "模拟所需分数"
--[[Translation missing --]]
L["Text Format"] = "Text Format"
--[[Translation missing --]]
L["The count of mobs pulled."] = "The count of mobs pulled."
--[[Translation missing --]]
L["The current count of mobs killed."] = "The current count of mobs killed."
--[[Translation missing --]]
L["The current percentage of mobs killed."] = "The current percentage of mobs killed."
--[[Translation missing --]]
L["The estimated count after all pulled mobs are killed."] = "The estimated count after all pulled mobs are killed."
--[[Translation missing --]]
L["The estimated percentage after all pulled mobs are killed."] = "The estimated percentage after all pulled mobs are killed."
--[[Translation missing --]]
L["The following placeholders are available:"] = "The following placeholders are available:"
--[[Translation missing --]]
L["The percentage of mobs pulled."] = "The percentage of mobs pulled."
--[[Translation missing --]]
L["The percentage the mob gives."] = "The percentage the mob gives."
--[[Translation missing --]]
L["The raw count the mob gives."] = "The raw count the mob gives."
--[[Translation missing --]]
L["The required count of mobs to reach 100%%."] = "The required count of mobs to reach 100%%."
--[[Translation missing --]]
L["The text format of the nameplate text. Use placeholders to display information."] = "The text format of the nameplate text. Use placeholders to display information."
--[[Translation missing --]]
L["The text format of the pull frame. Use placeholders to display information."] = "The text format of the pull frame. Use placeholders to display information."
L["These options are experimental and may not work as intended."] = "下列设置仍是实验性的，有可能不按预期方式运作。"
L["Tooltip"] = "鼠标提示"
L["Version:"] = "版本："
L["Vertical Offset ( | )"] = "垂直偏移 ( | )"
L["Vertical offset of the nameplate text"] = "姓名板文本的垂值位置偏移"
L["Wipe all data"] = "清除所有数据"
L["Wipe All Data"] = "清除所有数据"

