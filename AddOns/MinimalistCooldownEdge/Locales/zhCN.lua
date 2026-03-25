-- zhCN.lua (Simplified Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhCN")
if not L then return end

-- Core
L["Cannot open options in combat."] = "战斗中无法打开选项。"
L["MiniCC test command is unavailable."] = "MiniCC 测试命令不可用。"

-- Category Names
L["Action Bars"] = "动作条"
L["Nameplates"] = "姓名板"
L["Unit Frames"] = "单位框体"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "其他"

-- Group Headers
L["General"] = "常规"
L["Typography (Cooldown Numbers)"] = "字体排版（冷却数字）"
L["Swipe Animation"] = "扫动动画"
L["Stack Counters / Charges"] = "层数计数 / 充能"
L["Maintenance"] = "维护"
L["Danger Zone"] = "危险区域"
L["Style"] = "样式"
L["Positioning"] = "定位"
L["CooldownManager Viewers"] = "CooldownManager 查看器"
L["MiniCC Frame Types"] = "MiniCC 框体类型"

-- Toggles & Settings
L["Enable %s"] = "启用 %s"
L["Toggle styling for this category."] = "切换此分类的样式。"
L["Font Face"] = "字体"
L["Font"] = "字体"
L["Size"] = "大小"
L["Outline"] = "描边"
L["Color"] = "颜色"
L["Hide Numbers"] = "隐藏数字"
L["Compact Party / Raid Aura Text"] = "紧凑小队/团队光环文字"
L["Enable Party Aura Text"] = "启用小队光环文字"
L["Enable Raid Aura Text"] = "启用团队光环文字"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "完全隐藏文字（如果你只想保留扫动边缘或层数，这会很有用）。"
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "在 Blizzard CompactPartyFrame 的增益和减益图标上显示带样式的倒计时文字。禁用后会隐藏小队框体上的光环倒计时文字。"
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "在 Blizzard CompactRaidFrame 的增益和减益图标上显示带样式的倒计时文字。禁用后会隐藏团队框体上的光环倒计时文字。"
L["Anchor Point"] = "锚点"
L["Offset X"] = "X 偏移"
L["Offset Y"] = "Y 偏移"
L["Essential Viewer Size"] = "Essential 查看器大小"
L["Utility Viewer Size"] = "Utility 查看器大小"
L["Buff Icon Viewer Size"] = "增益图标查看器大小"
L["CC Text Size"] = "CC 文字大小"
L["Nameplates Text Size"] = "姓名板文字大小"
L["Portraits Text Size"] = "头像文字大小"
L["Alerts / Overlay Text Size"] = "警报 / 覆盖层文字大小"
L["Toggle Test Icons"] = "切换测试图标"
L["Show Swipe Edge"] = "显示扫动边缘"
L["Shows the white line indicating cooldown progress."] = "显示表示冷却进度的白色线条。"
L["Edge Thickness"] = "边缘厚度"
L["Scale of the swipe line (1.0 = Default)."] = "扫动线条的缩放（1.0 = 默认）。"
L["Customize Stack Text"] = "自定义层数文字"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "接管充能计数器（例如：燃烧的 2 层充能）。"
L["Reset %s"] = "重置 %s"
L["Revert this category to default settings."] = "将此分类恢复为默认设置。"
L["Toggle MiniCC's built-in test icons using /minicc test."] = "使用 /minicc test 切换 MiniCC 内置测试图标。"

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
L["Factory Reset (All)"] = "恢复出厂设置（全部）"
L["Resets the entire profile to default values and reloads the UI."] = "将整个配置文件重置为默认值并重新加载界面。"
L["Import / Export"] = "导入 / 导出"
L["PROFILE_IMPORT_EXPORT_DESC"] = "将当前 AceDB 配置文件导出为可分享的字符串，或导入字符串以替换当前配置文件设置。"
L["Export current profile"] = "导出当前配置文件"
L["Generate export"] = "生成导出"
L["Export code"] = "导出代码"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "生成导出字符串后，点击此框并使用 Ctrl+C 复制。"
L["Import profile"] = "导入配置文件"
L["Import code"] = "导入代码"
L["Paste an exported string here, then click Import."] = "在此粘贴导出的字符串，然后点击导入。"
L["Import"] = "导入"
L["Importing will overwrite the current profile settings. Continue?"] = "导入将覆盖当前配置文件设置。是否继续？"
L["Export string generated. Copy it with Ctrl+C."] = "导出字符串已生成。请使用 Ctrl+C 复制。"
L["Profile import completed."] = "配置文件导入完成。"
L["No active profile available."] = "当前没有可用的活动配置文件。"
L["Failed to encode export string."] = "导出字符串编码失败。"
L["Paste an import string first."] = "请先粘贴导入字符串。"
L["Invalid import string format."] = "导入字符串格式无效。"
L["Failed to decode import string."] = "导入字符串解码失败。"
L["Failed to decompress import string."] = "导入字符串解压失败。"
L["Failed to deserialize import string."] = "导入字符串反序列化失败。"

-- Banner
L["BANNER_DESC"] = "为你的冷却提供极简配置。选择左侧的分类即可开始。"

-- Chat Messages
L["%s settings reset."] = "%s 设置已重置。"
L["Profile reset. Reloading UI..."] = "配置文件已重置。正在重新加载界面..."

-- Status Indicators
L["ON"] = "开"
L["OFF"] = "关"

-- General Dashboard
L["Enable categories styling"] = "启用分类样式"
L["LIVE_CONTROLS_DESC"] = "更改会立即生效。只启用你真正会用到的分类，让界面更简洁。"
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "在 Blizzard CompactPartyFrame 和 CompactRaidFrame 的增益与减益图标上显示带样式的倒计时文字。小队和团队可分别切换。此功能独立于“其他”分类。"

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "复制此链接即可在浏览器中打开 CurseForge 项目页面。"
L["Copy this link to view other projects from Anahkas on CurseForge."] = "复制此链接即可查看 Anahkas 在 CurseForge 上的其他项目。"

-- Help
L["Help & Support"] = "帮助与支持"
L["Project"] = "项目"
L["Useful Addons"] = "实用插件"
L["Support & Feedback"] = "支持与反馈"
L["MCE_HELP_INTRO"] = "这里有项目的快捷链接，以及几个值得一试的插件。"
L["HELP_SUPPORT_DESC"] = "欢迎随时提出建议和反馈。\n\n如果你发现了错误或有功能想法，欢迎在 CurseForge 留言或发送私信。"
L["HELP_COMPANION_DESC"] = "几款与 MiniCE 搭配很合适的简洁插件。"
L["HELP_MINICC_DESC"] = "紧凑型控制效果追踪器。MiniCE 也能美化它的文字。"
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "复制此链接即可在浏览器中打开 MiniCC 的 CurseForge 页面。"
L["HELP_PVPTAB_DESC"] = "让 TAB 在 PvP 中只选中玩家。非常适合竞技场和战场。"
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "复制此链接即可打开 Smart PvP Tab Targeting 的 CurseForge 页面。"

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "在一个地方切换你的主要冷却分类。"

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "此操作无法撤销。你的配置文件将被完全重置，并重新加载界面。"
L["MAINTENANCE_DESC"] = "将此分类恢复为出厂默认设置。其他分类不受影响。"

-- Category Descriptions
L["ACTIONBAR_DESC"] = "自定义主动作条上的冷却，包括 Bartender4 和 Dominos。"
L["NAMEPLATE_DESC"] = "设置敌对和友方姓名板上显示的冷却样式（Plater、KuiNameplates 等）。"
L["UNITFRAME_DESC"] = "调整玩家、目标和焦点单位框体上的冷却样式。"
L["COOLDOWNMANAGER_DESC"] = "为 CooldownManager 查看器提供统一的图标样式。倒计时文字大小可分别为 Essential、Utility 和增益图标查看器单独设置。"
L["MINICC_DESC"] = "MiniCC 冷却图标的专用样式。加载 MiniCC 时，可支持其控制效果图标、姓名板、头像和覆盖层模块。"
L["OTHERS_DESC"] = "用于不属于其他分类的冷却的汇总分类（背包、菜单、杂项插件）。"

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "动态文字颜色"
L["Color by Remaining Time"] = "按剩余时间着色"
L["Dynamically colors the countdown text based on how much time is left."] = "根据剩余时间动态改变倒计时文字颜色。"
L["DYNAMIC_COLORS_DESC"] = "根据剩余冷却时长改变文字颜色。启用后会覆盖上方的静态颜色。"
L["DYNAMIC_COLORS_GENERAL_DESC"] = "将相同的剩余时间阈值应用到所有已启用的 MiniCE 分类，包括紧凑小队/团队光环文字。即使 Blizzard 提供的是隐藏数值，跨越午夜时也能安全处理持续时间。"
L["Expiring Soon"] = "即将结束"
L["Short Duration"] = "短持续时间"
L["Long Duration"] = "长持续时间"
L["Beyond Thresholds"] = "超过阈值"
L["Threshold (seconds)"] = "阈值（秒）"
L["Default Color"] = "默认颜色"
L["Color used when the remaining time exceeds all thresholds."] = "当剩余时间超过所有阈值时使用的颜色。"

-- Abbreviation
L["Abbreviate Above"] = "缩写阈值"
L["Abbreviate Above (seconds)"] = "缩写阈值（秒）"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "超过此阈值的冷却数字将被缩写（例如显示5m而不是300）。"
L["ABBREV_THRESHOLD_DESC"] = "控制冷却数字何时切换为缩写格式。超过此阈值的计时器将显示缩写值，如5m或1h。"
