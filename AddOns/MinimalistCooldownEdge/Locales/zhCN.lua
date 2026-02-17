-- zhCN.lua (Simplified Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhCN")
if not L then return end

-- Core
L["Cannot open options in combat."] = "战斗中无法打开选项。"

-- Category Names
L["Action Bars"] = "动作条"
L["Nameplates"] = "姓名板"
L["Unit Frames"] = "单位框体"
L["CD Manager & Others"] = "冷却管理器及其他"

-- Group Headers
L["General"] = "常规"
L["State"] = "状态"
L["Typography (Cooldown Numbers)"] = "字体排版（冷却数字）"
L["Swipe Animation"] = "扫动动画"
L["Stack Counters / Charges"] = "堆叠计数 / 充能"
L["Maintenance"] = "维护"
L["Performance & Detection"] = "性能与检测"
L["Danger Zone"] = "危险区域"
L["Style"] = "样式"
L["Positioning"] = "定位"

-- Toggles & Settings
L["Enable %s"] = "启用 %s"
L["Toggle styling for this category."] = "切换此分类的样式。"
L["Font Face"] = "字体"
L["Game Default"] = "游戏默认"
L["Font"] = "字体"
L["Size"] = "大小"
L["Outline"] = "描边"
L["Color"] = "颜色"
L["Hide Numbers"] = "隐藏数字"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "完全隐藏文字（仅需扫动边缘或堆叠时有用）。"
L["Anchor Point"] = "锚点"
L["Offset X"] = "X 偏移"
L["Offset Y"] = "Y 偏移"
L["Show Swipe Edge"] = "显示扫动边缘"
L["Shows the white line indicating cooldown progress."] = "显示表示冷却进度的白色线条。"
L["Edge Thickness"] = "边缘厚度"
L["Scale of the swipe line (1.0 = Default)."] = "扫动线条的缩放（1.0 = 默认）。"
L["Customize Stack Text"] = "自定义堆叠文字"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "控制充能计数器（例如：2 层燃烧）。"
L["Reset %s"] = "重置 %s"
L["Revert this category to default settings."] = "将此分类恢复为默认设置。"

-- Outline Values
L["None"] = "无"
L["Thick"] = "粗"
L["Mono"] = "单色"

-- Anchor Point Values
L["Bottom Right"] = "右下"
L["Bottom Left"] = "左下"
L["Top Right"] = "右上"
L["Top Left"] = "左上"
L["Center"] = "居中"

-- General Tab
L["Scan Depth"] = "扫描深度"
L["How deep the addon looks into UI frames to find cooldowns."] = "插件在界面框体中搜索冷却的深度。"
L["Factory Reset (All)"] = "恢复出厂设置（全部）"
L["Resets the entire profile to default values and reloads the UI."] = "将整个配置文件重置为默认值并重新加载界面。"

-- Banner
L["BANNER_DESC"] = "极简的冷却配置。选择左侧的分类开始设置。"

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r：高效（默认界面）\n|cfffff56910 - 15|r：适中（Bartender、Dominos）\n|cffffa500> 15|r：较重（ElvUI、复杂框体）"

-- Chat Messages
L["%s settings reset."] = "%s 设置已重置。"
L["Profile reset. Reloading UI..."] = "配置文件已重置。正在重新加载界面..."
L["Global Scan Depth changed. A /reload is recommended."] = "全局扫描深度已更改。建议执行 /reload。"
