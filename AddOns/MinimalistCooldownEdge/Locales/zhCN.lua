-- zhCN.lua (Simplified Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhCN")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras 自行管理倒计时阈值颜色。请在 MiniAuras > Misc > Countdown Colours 中配置。"
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% = 完全透明，100% = 完全变暗。适用于所有 MiniAuras 模块分组；80% 与 MiniAuras 自身绘制的冷却遮罩一致。"

-- Core
L["MiniAuras test command is unavailable."] = "MiniAuras 测试命令不可用。"

-- Category Names
L["Action Bars"] = "动作条"
L["Nameplates"] = "姓名板"
L["Unit Frames"] = "单位框体"
L["Party / Raid Frames"] = "小队/团队框体"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "MiniAuras 框体类型"

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
L["Essential Viewer Stack Size"] = "Essential 查看器层数大小"
L["Utility Viewer Stack Size"] = "Utility 查看器层数大小"
L["Buff Icon Viewer Stack Size"] = "增益图标查看器层数大小"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "使用 /miniauras test 切换 MiniAuras 内置测试图标。"

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
L["Top"] = "上"
L["Bottom"] = "下"
L["Left"] = "左"
L["Right"] = "右"

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
L["Retired"] = "已移除"

-- General Dashboard
L["Enable categories styling"] = "启用分类样式"
L["LIVE_CONTROLS_DESC"] = "更改会立即生效。只启用你真正会用到的分类，让界面更简洁。"
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "启用小队/团队框体是此分类的总开关。启用团队光环文字会将同样的样式扩展到 Blizzard 团队框体。"
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "小队/团队框体支持已移除。自 Blizzard 12.0.5 补丁起，MiniCE 不再 hook 或美化紧凑小队与团队框体。"
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "正在开发的新插件：Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras 现已登陆 CurseForge。它之所以与 MiniCE 保持分离，是因为它使用自己的覆盖框体，而不是去美化 Blizzard 现有的图标，因此更适合作为独立插件。"

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "复制此链接即可在浏览器中打开 CurseForge 项目页面。"
L["Copy this link to open Raid Frame Auras on CurseForge."] = "复制此链接即可在 CurseForge 上打开 Raid Frame Auras。"
L["Copy this link to view other projects from Anahkas on CurseForge."] = "复制此链接即可查看 Anahkas 在 CurseForge 上的其他项目。"

-- Help
L["Help & Support"] = "帮助与支持"
L["Project"] = "项目"
L["Useful Addons"] = "实用插件"
L["Support & Feedback"] = "支持与反馈"
L["MCE_HELP_INTRO"] = "这里有项目的快捷链接，以及几个值得一试的插件。"
L["HELP_SUPPORT_DESC"] = "欢迎随时提出建议和反馈。\n\n如果你发现了错误或有功能想法，欢迎在 CurseForge 留言或发送私信。"
L["HELP_COMPANION_DESC"] = "几款与 MiniCE 搭配很合适的简洁插件。"
L["HELP_MINIAURAS_DESC"] = "自定义光环、控制效果、冷却和 PvP 显示套件。MiniCE 也能美化其冷却文字。"
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "复制此链接即可在浏览器中打开 MiniAuras 的 CurseForge 页面。"
L["HELP_PVPTAB_DESC"] = "让 TAB 在 PvP 中只选中玩家。非常适合竞技场和战场。"
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "复制此链接即可打开 Smart PvP Tab Targeting 的 CurseForge 页面。"

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "在一个地方切换你的主要冷却分类。"

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "此操作无法撤销。你的配置文件将被完全重置，并重新加载界面。"
L["MAINTENANCE_DESC"] = "将此分类恢复为出厂默认设置。其他分类不受影响。"

-- Category Descriptions
L["ACTIONBAR_DESC"] = "美化动作条上的冷却。"
L["NAMEPLATE_DESC"] = "美化敌对和友方姓名板上的冷却。"
L["UNITFRAME_DESC"] = "美化目标、焦点及其他受支持单位框体上的光环冷却。"
L["COOLDOWNMANAGER_DESC"] = "美化 CooldownManager 图标冷却。"
L["MINIAURAS_DESC"] = "美化 MiniAuras 冷却图标。"

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "动态文字颜色"
L["Color by Remaining Time"] = "按剩余时间着色"
L["Dynamically colors the countdown text based on how much time is left."] = "根据剩余时间动态改变倒计时文字颜色。"
L["DYNAMIC_COLORS_DESC"] = "根据剩余冷却时长改变文字颜色。启用后会覆盖上方的静态颜色。"
L["DYNAMIC_COLORS_GENERAL_DESC"] = "可按每个启用中的 MiniCE 分类允许或阻止剩余时间阈值。即使 Blizzard 提供的是隐藏数值，跨越午夜时也能安全处理持续时间。"
L["Expiring Soon"] = "即将结束"
L["Short Duration"] = "短持续时间"
L["Long Duration"] = "长持续时间"
L["Threshold (seconds)"] = "阈值（秒）"
L["Default Color"] = "默认颜色"
L["Color used when the remaining time exceeds all thresholds."] = "当剩余时间超过所有阈值时使用的颜色。"

-- Abbreviation
L["Abbreviate Above"] = "缩写阈值"
L["Abbreviate Above (seconds)"] = "缩写阈值（秒）"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "超过此阈值的冷却数字将被缩写（例如显示5m而不是300）。"
L["ABBREV_THRESHOLD_DESC"] = "控制冷却数字何时切换为缩写格式。超过此阈值的计时器将显示缩写值，如5m或1h。"

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% = 完全透明，100% = 完全变暗。在此分类启用期间，会替代 MyDRs 的 Cooldown Swipe Alpha 设置；100% 与 MyDRs 自身绘制的冷却遮罩一致。"
L["MyDRs test command is unavailable."] = "MyDRs 测试命令不可用。"
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "使用 /mydrs test 切换 MyDRs 内置测试图标。"
L["sArena slash command is unavailable."] = "sArena 斜杠命令不可用。"

-- Category Names
L["Player Auras"] = "玩家光环"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "配置"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "扫动边缘"
L["MiniAuras Module Groups"] = "MiniAuras 模块分组"
L["sArena Cooldown Types"] = "sArena 冷却类型"
L["Aura Targets"] = "光环目标"
L["Buff Styling"] = "增益样式"
L["Debuff Styling"] = "减益样式"
L["External Defensive Buffs Styling"] = "外部防御增益样式"

-- Toggles & Settings
L["Style Buffs"] = "美化增益"
L["Style Debuffs"] = "美化减益"
L["Style External Defensive Buffs"] = "美化外部防御增益"
L["Style Blizzard's default player buff buttons."] = "美化 Blizzard 默认的玩家增益图标。"
L["Style Blizzard's default player debuff buttons."] = "美化 Blizzard 默认的玩家减益图标。"
L["Style Blizzard's external defensive buff buttons."] = "美化 Blizzard 的外部防御增益图标。"
L["Timer Inside Icon"] = "图标内计时"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "将光环计时器置于图标中央，而不是 Blizzard 默认的外部位置。"
L["Hide Swipe"] = "隐藏扫动"
L["Only Mine (Timer Text)"] = "仅显示我的（计时文字）"
L["Aura Visibility"] = "光环可见性"
L["Only My Debuffs"] = "仅显示我的减益"
L["Only My Buffs"] = "仅显示我的增益"
L["Disable fading/blinking"] = "禁用淡入淡出/闪烁"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "在小队/团队框体上启用带样式的倒计时文字。禁用后，小队和团队光环文字样式都会关闭。"
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "同时将带样式的倒计时文字应用到 Blizzard CompactRaidFrame 的增益和减益图标。需要启用小队/团队框体。"
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "隐藏此框体分组的扫动动画（倒计时文字仍会显示）。"
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "仅在你自己的光环上显示冷却计时文字。使用 Blizzard 的大型光环启发式判断，而非直接检查 sourceUnit。"
L["UNITFRAME_ONLY_MINE_DESC"] = "仅在你自己施放的光环上显示计时文字。MiniCE 在 WoW 12.1 中的目标/焦点容器使用 Blizzard 的玩家过滤器；兼容插件和旧版框体则使用其分组元数据或大型光环回退方案。"
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "隐藏其他玩家在目标和焦点框体上施放的减益。MiniCE 在 WoW 12.1 中管理这些光环容器，因此 Blizzard 自身的减益过滤器不再对其生效。"
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "隐藏其他玩家在目标和焦点框体上施放的增益。MiniCE 在 WoW 12.1 中管理这些光环容器，因此 Blizzard 自身的增益过滤器不再对其生效。"
L["Cast Bar"] = "施法条"
L["Reposition Cast Bar"] = "重新定位施法条"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "将目标和焦点的施法条锚定在最后一行增益/减益之下。MiniCE 在 WoW 12.1 中管理这些光环容器，否则暴雪的施法条会紧贴框体并与光环重叠。"
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "当玩家光环图标即将到期时，保持其完全不透明。"
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "当 CooldownManager 插槽临时显示光环时间时，使用专用增益颜色，而非剩余时间阈值颜色。"
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "在插槽显示光环持续时间期间生效。光环结束、插槽切回冷却时间后，将恢复阈值颜色。"
L["Buff / Debuff Size"] = "增益/减益大小"
L["Defensive Buff Size"] = "防御增益大小"
L["Use Buff Color"] = "使用增益颜色"
L["Buff Color"] = "增益颜色"
L["Essential Viewer"] = "Essential 查看器"
L["Utility Viewer"] = "Utility 查看器"
L["Buff Icon Viewer"] = "增益图标查看器"
L["CC Frames Text Size"] = "CC 框体文字大小"
L["CC / Friendly Frames Text Size"] = "CC / 友方框体文字大小"
L["Raid Frame Auras Text Size"] = "团队框体光环文字大小"
L["Class Icon Text Size"] = "职业图标文字大小"
L["DR Cooldown Text Size"] = "DR 冷却文字大小"
L["Alerts / Trackers / Custom Auras Text Size"] = "警报/追踪器/自定义光环文字大小"
L["Trinket / Racial Text Size"] = "饰品/种族文字大小"
L["Show Test Frames"] = "显示测试框体"
L["Hide Test Frames"] = "隐藏测试框体"
L["Show Swipe Animation"] = "显示扫动动画"
L["Shows the dark overlay that sweeps during a cooldown."] = "显示冷却期间扫过的深色遮罩。"
L["Swipe Shade Alpha"] = "扫动遮罩不透明度"
L["0% = transparent, 100% = full dark."] = "0% = 完全透明，100% = 完全变暗。"
L["Reverse Swipe"] = "反转扫动"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "反转扫动方向，使遮罩向相反方向填充。"
L["Hide Charge Timers"] = "隐藏充能计时器"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "充能恢复期间隐藏计时器（仅在所有充能用尽时显示计时器）。"
L["Hide Stack Text"] = "隐藏层数文字"
L["Hide stacks and charges entirely."] = "完全隐藏层数和充能。"
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "MiniAuras 文字设置按模块系列分组，相似的组件共享相同的倒计时大小。"
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "适用于 MiniAuras CC 模块（敌方控制效果）。"
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "适用于 MiniAuras 的 CC、Friendly CDs 和 Friendly Indicators 模块。"
L["Applies to the MiniAuras Raid Frame Auras module."] = "适用于 MiniAuras 的 Raid Frame Auras 模块。"
L["Applies to MiniAuras portrait icons."] = "适用于 MiniAuras 头像图标。"
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "适用于 MiniAuras 的 Alerts、Healer CC、Kick Timer、Precognition、Trinkets 和 Custom Auras 模块。"
L["Show sArena test frames using /sarena test."] = "使用 /sarena test 显示 sArena 测试框体。"
L["Hide sArena test frames using /sarena hide."] = "使用 /sarena hide 隐藏 sArena 测试框体。"

-- Import / Export
L["Import string is too large."] = "导入字符串过大。"
L["Import profile contains invalid data."] = "导入的配置文件包含无效数据。"
L["Failed to apply imported profile."] = "无法应用导入的配置文件。"

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "部分更改需要重新加载界面才能完全生效。\n\n是否立即重新加载界面？"

-- Addon Integrations
L["Addon Integrations"] = "插件集成"
L["ADDON_INTEGRATIONS_DESC"] = "启用或禁用将外部冷却路由到 MiniCE 分类的可选插件桥接。"
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "通过单位框体分类路由 ShinyAuras 的冷却。如果你希望 ShinyAuras 保留其原生倒计时不变，请禁用此项。"
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "通过动作条分类路由受支持的 Dominos 动作条冷却。如果你希望 Dominos 保留其原生冷却样式不变，请禁用此项。"
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "通过动作条分类路由受支持的 Bartender4 动作条冷却。如果你希望 Bartender4 保留其原生冷却样式不变，请禁用此项。"
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "通过 MiniCE 分类路由受支持的 ElvUI 动作条、单位框体和姓名板冷却。如果你希望 ElvUI 保留其原生冷却样式不变，请禁用此项。"
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered 还会美化 %s。这可能会带来轻微的性能开销。如果你希望 MiniCE 是这些查看器计时器的唯一管理者，请禁用 CMC 计时字体。"

-- Help
L["HELP_ARENADR_DESC"] = "直接在竞技场姓名板上追踪敌方递减效果。"
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "复制此链接即可在 CurseForge 上打开 ArenaDR Nameplates。"

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames 已启用，因此 MiniCE 的单位框体样式已被禁用，以避免可能的冲突。专用的 BetterBlizzFrames 适配器即将推出。"
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates 已启用，因此 MiniCE 的姓名板样式已被禁用，以避免可能的冲突。"
L["PLAYERAURA_DESC"] = "美化 Blizzard 玩家增益和减益冷却。"
L["HEALERCC_DESC"] = "美化友方和敌方的 HealerCC 警报冷却。"
L["MYDRS_DESC"] = "美化 MyDRs 的递减效果图标冷却。MyDRs 保留其自身的 DR 状态标签（50% / IMM）。"
L["SARENA_DESC"] = "美化 sArena_Reloaded 的冷却计时器。"
L["TELLMEWHEN_DESC"] = "美化 TellMeWhen 的冷却文字和扫动边缘。"
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "计时器可见性、计时器文字、阴影方向和 GCD 显示仍由 TellMeWhen 控制。扫动边缘的可见性和厚度在此控制。"
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "在 MiniCE 启用后缩放 TellMeWhen 的扫动边缘。"

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "允许阈值颜色"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "允许全局的“按剩余时间着色”阈值覆盖此分类的静态文字颜色。"
L["Behavior"] = "行为"
L["Advanced Threshold Settings"] = "高级阈值设置"
L["Threshold Colors"] = "阈值颜色"
L["THRESHOLD_COLORS_DESC"] = "每个区段定义该剩余时间范围所使用的临界值和颜色。"
L["Threshold Transition Offset"] = "阈值过渡偏移"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "移动下一个颜色区段的起始点。负值会让切换提前一些。"
L["Beyond Thresholds Color"] = "超出阈值颜色"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "低于此值显示小数（秒）"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "低于此阈值的冷却数字将显示一位小数（例如 8.7）。设为 0 可禁用。"

-- Performance Warning
L["PERF_WARNING_DESC"] = "此功能可能影响性能并导致帧率下降，请仅在配置较高的设备上使用。"

-- Font Options
L["Game Default"] = "游戏默认"
