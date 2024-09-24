local L = LibStub("AceLocale-3.0"):NewLocale("EasyFrames", "zhCN")
if not L then return end

-- 主选项
L["Main options"] = "主选项"
L["In main options you can set the global options like colored frames, buffs settings, etc"] = "在主选项中你可以设置全局选项，如框架着色，光环效果...等"
L["Frames"] = "框架"
L["Setting for unit frames"] = "单位框架设置"
L["Use the Easy Frames style"] = "使用经典头像样式"
L["Otherwise, use the standard Blizzard style and textures that they introduced in version 10 (Dragonflight), but with the Easy Frames features applied."] = "否则会使用 10 版本 (巨龙时代) 新的暴雪头像样式和材质，但是仍然可以使用插件的功能。"
L["When you change this option you need to reload your UI.\n\n Do you want to reload the UI?"] = "更改此选项时需要重新载入界面\n\n是否需要重新载入?"
L["Class colored healthbars"] = "生命条使用职业颜色"
L["If checked frames becomes class colored.\n\nThis option excludes the option 'Healthbar color is based on the current health value'"] = "启用这个选项会禁用 '生命条颜色按生命值变化' 选项。"
L["Healthbar color is based on the current health value"] = "生命条颜色按生命值变化"
L["Healthbar color is based on the current health value.\n\nThis option excludes the option 'Class colored healthbars'"] = "启用这个选项会禁用 '生命条使用职业颜色' 选项。"
L["Hide frames out of combat"] = "不在战斗时渐隐框体"
L["Hide frames out of combat (for example in resting)"] = "非战斗中隐藏框架 (例如休息时)。"
L["Opacity of frames"] = "框架不透明度"
L["Opacity of frames when frames is hidden (in out of combat)"] = "框架隐藏时的不透明度 (非战斗中)。"
L["Texture"] = "材质"
L["Set the frames bar Texture"] = "设置状态条材质。"
L["Use a light texture"] = "使用亮色的材质"
L["Use a brighter texture (like Blizzard's default texture)"] = "使用较明亮的材质 (比如暴雪默认的材质)。"
L["Bright frames border"] = "框架边框明暗度"
L["You can set frames border bright/dark color. From bright to dark. 0 - dark, 100 - bright"] = "设置框架边框显示较亮或较暗的颜色， 0 - 暗，100 - 亮。"
L["Buffs"] = "光环效果"
L["Buffs settings (like custom buffsize, max buffs count, etc)"] = "光环效果设置 (例如自定义光环尺寸、最大显示光环数量...等)"
L["Turn on custom buffsize"] = "设置增益效果尺寸"
L["Turn on custom target and focus frames buffsize"] = "设置目标和焦点目标框架的增益效果尺寸。"
L["Buffsize"] = "增益效果大小"
L["Self buffsize"] = "自己的增益效果大小"
L["Buffsize that you create"] = "自己施放的增益效果大小。"
L["Show only my debuffs"] = "只显示自己施放的减益效果"
L["When you change this option you need to reload your UI (because it's Blizzard config variable). \n\nCommand /reload"] = "更改这个选项需要重新载入界面 (因为这是暴雪的游戏参数)\n\n输入命令 /reload"
L["Max buffs count"] = "增益效果最大数量"
L["How many buffs you can see on target/focus frames"] = "你可以在目标和焦点框架上看到多少个增益效果"
L["Max debuffs count"] = "减益效果最大数量"
L["How many debuffs you can see on target/focus frames"] = "你可以在目标和焦点框架上看到多少个减益效果"
L["Frames colors"] = "框架颜色"
L["In this section you can set the default colors for friendly, enemy and neutral frames"] = "设置友方、敌方和中立框架的默认颜色。"
L["Set default friendly healthbar color"] = "设置友方生命条颜色"
L["You can set the default friendly healthbar color for frames"] = "设置友方框架默认的生命条颜色。"
L["Set default enemy healthbar color"] = "设置敌方生命条颜色"
L["You can set the default enemy healthbar color for frames"] = "设置敌方框架默认的生命条颜色。"
L["Set default neutral healthbar color"] = "设置中立生命条颜色"
L["You can set the default neutral healthbar color for frames"] = "设置中立框架默认的生命条颜色。"
L["Other"] = "其他"
L["In this section you can set the settings like 'show welcome message' etc"] = "在这里你可以设置 '显示欢迎信息' 等设置"
L["Show welcome message"] = "显示欢迎信息"
L["Show welcome message when addon is loaded"] = "插件载入时显示欢迎信息。"
L["Save positions of frames to current profile"] = "将框架的位置保存到当前配置文件"
L["Saved"] = "保存"
L["Restore positions of frames from current profile"] = "从当前配置文件恢复框架的位置"
L["Restored"] = "恢复"
L["Frame"] = "框架"
L["Select the frame you want to set the position"] = "选择要设置的框架"
L["X"] = "水平坐标"
L["X coordinate"] = "水平坐标"
L["Y"] = "垂直坐标"
L["Y coordinate"] = "垂直坐标"

-- 玩家
L["Player"] = "玩家"
L["In player options you can set scale player frame, healthbar text format, etc"] = "在玩家选项中可以设置玩家框架的缩放尺寸、生命条的文本样式...等。"
L["Set the player's portrait"] = "设置玩家的头像"
L["Player healthbar text format"] = "玩家生命条文本样式"
L["Set the player healthbar text format"] = "设置玩家生命条的文本样式"
L["Player manabar text format"] = "玩家能量条文本样式"
L["Set the player manabar text format"] = "设置玩家能量条的文本样式。"
L["Player name"] = "玩家名字"
L["Show player name"] = "显示玩家名字"
L["Show player name inside the frame"] = "玩家名字在框架內侧"
L["Player name font style"] = "玩家名字样式"
L["Player name font family"] = "玩家名字字体"
L["Player name font size"] = "玩家名字大小"
L["Player name color"] = "玩家名字颜色"
L["Enable hit indicators"] = "启用战斗文本"
L["Show or hide the damage/heal which you take on your unit frame"] = "在你的框架中显示或隐藏你受到的伤害和治疗。"
L["Show player specialbar"] = "显示职业特殊能量条"
L["Show or hide the player specialbar, like Paladin's holy power, Priest's orbs, Monk's harmony or Warlock's soul shards"] = "显示或隐藏玩家的职业特殊能量条，如圣骑士的圣能、牧师的狂乱值、武僧的气或术士的灵魂碎片。"
L["Show player resting icon"] = "显示玩家休息图标"
L["Show or hide player resting icon when player is resting (e.g. in the tavern or in the capital)"] = "显示或隐藏玩家休息时的图标 (例如在旅店或主城中时)。"
L["Show player status texture (inside the frame)"] = "显示玩家状态材质 (框架內)"
L["Show or hide player status texture (blinking glow inside the frame when player is resting or in combat)"] = "显示或隐藏玩家的状态材质 (当玩家正在休息或战斗中框架会闪烁发光)。"
L["Show player combat texture (outside the frame)"] = "显示玩家战斗材质 (框架外)"
L["Show or hide player red background texture (blinking red glow outside the frame in combat)"] = "显示或隐藏玩家的红色背景材质 (战斗中框架外侧会闪红光)。"
L["Show player group number"] = "显示玩家队伍编号"
L["Show or hide player group number when player is in a raid group (over portrait)"] = "当玩家在团队中时，显示或隐藏玩家的小队编号 (在头像上)。"
L["Show player role icon"] = "显示玩家角色图标"
L["Show or hide player role icon when player is in a group"] = "当玩家在队伍中时，显示或隐藏玩家担任的角色图标。"
L["Show player PVP icon"] = "显示玩家PVP图标"
L["Show or hide player PVP icon"] = "显示或隐藏玩家的PVP图标。"
L["Allow Easy Frames to fix the position of the specialbar frame"] = "修复职业能量条的位置"
L["If the setting is enabled, Easy Frames will change the position of the specialbar and set it closer to the PlayerFrame. Otherwise, the position can be changed by other addons and Easy Frames will not block its change.\n\nWhen you change this option you need to reload your UI. \n\nCommand /reload"] = "启用时Easy Frames将会改变职业能量条的位置，并将其设置得更靠近玩家框架。否则，位置可以被其他插件更改，并且Easy Frames不会阻止其更改。当你改变这个选项时，你需要重新加载你的界面。\n\n命令： /reload"
L["Reverse the direction of losing health/mana"] = "反向显示损失的生命和能量"
L["By default direction starting from right to left. If checked direction of losing health/mana will be from left to right"] = "默认的方向是从右到左，勾选时损失生命值和能量的方向会从左到右。"

-- 目标
L["Target"] = "目标"
L["In target options you can set scale target frame, healthbar text format, etc"] = "在目标选项中可以设置玩家框架的缩放尺寸、生命条的文本样式...等。"
L["Set the target's portrait"] = "设置目标的头像"
L["Target healthbar text format"] = "目标生命条文本样式"
L["Set the target healthbar text format"] = "设置目标生命条的文本样式。"
L["Target manabar text format"] = "目标能量条文本样式"
L["Set the target manabar text format"] = "设置目标能量条的文本样式。"
L["Target name"] = "目标名字"
L["Show target name"] = "显示目标名字"
L["Show target name inside the frame"] = "目标名字在框架內侧"
L["Target name font style"] = "目标名字字体样式"
L["Target name font family"] = "目标名字字体"
L["Target name font size"] = "目标名字字体大小"
L["Target name color"] = "目标名字颜色"
L["Show target of target frame"] = "显示目标的目标框架"
L["Show blizzard's target castbar"] = "显示暴雪的目标施法条"
L["Show target combat texture (outside the frame)"] = "显示目标战斗材质 (框架外)"
L["Show or hide target red background texture (blinking red glow outside the frame in combat)"] = "显示或隐藏目标的红色背景材质 (战斗中框架外侧会闪红光)。"
L["Show target PVP icon"] = "显示目标框架PVP图标"
L["Show or hide target PVP icon"] = "显示或隐藏目标框架的PVP图标"

-- 焦点
L["Focus"] = "焦点"
L["In focus options you can set scale focus frame, healthbar text format, etc"] = "在焦点选项中可以设置玩家框架的缩放尺寸、生命条的文本样式...等。"
L["Set the focus's portrait"] = "设置焦点目标的头像"
L["Focus healthbar text format"] = "焦点目标生命条文本样式"
L["Set the focus healthbar text format"] = "设置焦点目标生命条的文本样式。"
L["Focus manabar text format"] = "焦点目标能量条文本样式"
L["Set the focus manabar text format"] = "设置焦点目标能量条的文本样式。"
L["Focus name"] = "焦点目标名字"
L["Show name of focus frame"] = "显示焦点目标名字"
L["Show name of focus frame inside the frame"] = "焦点名字在框架内侧"
L["Focus name font style"] = "焦点目标名字字体样式"
L["Focus name font family"] = "焦点目标名字字体"
L["Focus name font size"] = "焦点目标名字字体大小"
L["Focus name color"] = "焦点名字颜色"
L["Show target of focus frame"] = "显示焦点目标的目标框架"
L["Show focus combat texture (outside the frame)"] = "显示焦点目标战斗材质 (框架外)"
L["Show or hide focus red background texture (blinking red glow outside the frame in combat)"] = "显示或隐藏焦点目标的红色背景材质 (战斗中框架外侧会闪红光)。"
L["Show focus PVP icon"] = "显示焦点框架PVP图标"
L["Show or hide focus PVP icon"] = "显示或隐藏焦点框架的PVP图标"

-- 宠物
L["Pet"] = "宠物"
L["In pet options you can set scale pet frame, show/hide pet name, enable/disable pet hit indicators, etc"] = "在宠物选项中可以设置玩家框架的缩放尺寸、显示和隐藏宠物名字、启用和禁用宠物命中指示器等。"
L["Pet healthbar text format"] = "宠物生命条文本样式"
L["Set the pet healthbar text format"] = "设置宠物生命条的文本样式。"
L["Pet manabar text format"] = "宠物能量条文本样式"
L["Set the pet manabar text format"] = "设置宠物能量条的文本样式。"
L["Pet name"] = "宠物名字"
L["Show pet name"] = "显示宠物名字"
L["Pet name font style"] = "宠物名字字体样式"
L["Pet name font family"] = "宠物名字字体"
L["Pet name font size"] = "宠物名字字体大小"
L["Pet name color"] = "宠物名字颜色"
L["Show or hide the damage/heal which your pet take on pet unit frame"] = "在宠物框架中显示或隐藏宠物受到的伤害和治疗。"
L["Show pet combat texture (inside the frame)"] = "显示宠物战斗材质 (框架內)"
L["Show or hide pet red background texture (blinking red glow inside the frame in combat)"] = "显示或隐藏宠物的红色背景材质 (战斗中框架內侧会闪红光)。"
L["Show pet combat texture (outside the frame)"] = "显示宠物战斗材质 (框架外)"
L["Show or hide pet red background texture (blinking red glow outside the frame in combat)"] = "显示或隐藏宠物的红色背景材质 (战斗中框架外侧会闪红光)。"

-- 队伍
L["Party"] = "队伍"
L["In party options you can set scale party frames, healthbar text format, etc"] = "在队伍选项中你可以设置队伍框架的缩放大小、生命条文本样式...等。"
L["Party frames scale"] = "队伍框架缩放大小"
L["Scale of party unit frames"] = "队伍框架的缩放大小。"
L["Party healthbar text format"] = "队伍生命条文本样式"
L["Set the party healthbar text format"] = "设置队伍生命条的文本样式。"
L["Party manabar text format"] = "队伍能量条文本样式"
L["Set the party manabar text format"] = "设置队伍能量条的文本样式。"
L["Party frames names"] = "队伍框架名字"
L["Show names of party frames"] = "显示队伍框架名字"
L["Party names font style"] = "队伍名字字体样式"
L["Party names font family"] = "队伍名字字体"
L["Party names font size"] = "队伍名字字体大小"
L["Party names color"] = "队伍名字颜色"

-- 首领
L["Boss"] = "首领"
L["In boss options you can set scale boss frames, healthbar text format, etc"] = "在首领选项中你可以设置队伍框架的缩放大小、生命条文本样式...等。"
L["Boss frames scale"] = "首领框架缩放大小"
L["Scale of boss unit frames"] = "首领框架的缩放大小"

L["Set the offset of the Objective Tracker frame"] = "设置任务追踪框架位置"
L["When the scale of the boss frame is greater than 0.75 (this is the default Blizzard UI scale), the boss frame will be 'covered' by the Objective Tracker frame (the frame with quests under the boss frame). " ..
    "This setting creates an offset based on the Boss frames scale settings. \n\n" ..
    "If you see strange behavior with the boss frame and Objective Tracker frame it is recommended to turn this setting off. \n\n" ..
    "When you change this option you need to reload your UI. \n\nCommand /reload"] = "当首领框架的缩放大小大于 0.75 (游戏默认的缩放大小)，首领框架会和任务追踪框架重叠 (任务追踪框架会在首领框架底下)。这个选项会根据首领框架的缩放大小來移动位置。\n\n如果移动后任务追踪框架或首领框架的功能变得很奇怪，请关闭这个选项。\n\n更改这个选项需要重新载入界面。\n\n命令： /reload\n\n特別注意: 使用 \"任务追踪框架增强\" 插件时请勿启用这个选项，请在 \"任务追踪框架增强\" 插件的设置中调整任务追踪框架的位置。"
L["Scale of boss unit frames"] = "首领框架的缩放大小。"
L["Boss healthbar text format"] = "首领生命条文字样式"
L["Set the boss healthbar text format"] = "设置首领生命条的文字样式。"
L["Boss manabar text format"] = "首领能量条文字样式"
L["Set the boss manabar text format"] = "设置首领能量条的文字样式。"
L["Boss frames names"] = "首领框架名字"
L["Show names of boss frames"] = "显示首领框架名字"
L["Boss names font style"] = "首领名字样式"
L["Boss names font family"] = "首领名字字体"
L["Boss names font size"] = "首领名字大小"
L["Boss names color"] = "首领名字颜色"
L["Show names of boss frames inside the frame"] = "名字在框架內側"
L["Show indicator of threat"] = "显示仇恨指示器"

-- 配置
L["Profiles"] = "配置"

L["Reset color to default"] = "恢复默认的颜色"
L["loaded. Options:"] = "已载入，选项命令："
L["Portrait"] = "头像"
L["Default"] = "默认"
L["Class portraits"] = "职业头像"
L["HP and MP bars"] = "生命和能量条"
L["Percent"] = "百分比"
L["Current + Max"] = "当前 + 最大"
L["Current + Max + Percent"] = "当前 + 最大 + 百分比"
L["Current + Percent"] = "当前 + 百分比"
L["Custom format"] = "自定义样式"
L["Font style"] = "字体样式"
L["Monochrome"] = "单色"
L["None"] = "无"
L["Outline"] = "轮廓"
L["Thickoutline"] = "粗轮廓"
L["Font family"] = "字体"
L["Font size"] = "字体大小"
L["Smart"] = "智能"
L["Set the color of the frame name"] = "设置名字颜色"
L["Show or hide some elements of frame"] = "显示或隐藏框架的某些部分"
L["Opacity"] = "不透明度"
L["Opacity of combat texture"] = "战斗材质的不透明度。"
L["Healthbar font style"] = "生命条字体样式"
L["Healthbar font family"] = "生命条字体"
L["Healthbar font size"] = "生命条字体大小"
L["Manabar font style"] = "能量条字体样式"
L["Manabar font family"] = "能量条字体"
L["Manabar font size"] = "能量条字体大小"
L["Custom format of HP"] = "自定义生命值样式"
L["You can set custom HP format. More information about custom HP format you can read on project site.\n\n" ..
    "Formulas:"] = "可以自定义生命值样式，关于生命值样式的更多相关信息请浏览插件的官方网站。\n\n公式语法:"
L["Use full values of health"] = "使用完整的生命值数值"
L["Formula converts the original value to the specified value.\n\n" ..
    "Description: for example formula is '%.fM'.\n" ..
    "The first part '%.f' is the formula itself, the second part 'M' is the abbreviation\n\n" ..
    "Example, value is 150550. '%.f' will be converted to '151' and '%.1f' to '150.6'"] = "公式语法会將原始的数值转换成指定的数值。\n\n说明: 例如公式语法为 '%.fM'。\n第一个部分的 '%.f' 是公式本身，第二个部分的 'M' 是百万的单位缩写\n\n举例來说，当数值是 150550 时，'%.f' 会將其转换成 '151'，而 '%.1f' 会转换成 '150.6'"
L["Value greater than 1000"] = "数值大于 1000"
L["Value greater than 10 000"] = "数值大于 10000"
L["Value greater than 100 000"] = "数值大于 100000"
L["Value greater than 1 000 000"] = "数值大于 1000000"
L["Value greater than 10 000 000"] = "数值大于 10000000"
L["Value greater than 100 000 000"] = "数值大于 100000000"
L["Value greater than 1 000 000 000"] = "数值大于 1000000000"
L["By default all formulas use divider (for value eq 1000 and more it's 1000, for 1 000 000 and more it's 1 000 000, etc).\n\n" ..
    "If checked formulas will use full values of HP (without divider)"] = "所有公式默认都会使用千位分隔符号 (大于或等于 1000 的数值会是 1000，大于或等于 1 000 000 会是 1 000 000，以此类推)。\n\n勾选时，公式会使用完整的生命值数值 (沒有分隔符号)。"
L["Displayed HP by pattern"] = "使用样式显示生命值"
L["You can use patterns:\n\n" ..
    "%CURRENT% - return current health\n" ..
    "%MAX% - return maximum of health\n" ..
    "%PERCENT% - return percent of current/max health\n" ..
    "%PERCENT_DECIMAL% - return decimal percent of current/max health\n\n" ..
    "All values are returned from formulas. For set abbreviation use formulas' fields"] = "可以使用的样式有:\n\n%CURRENT% - 返回当前的生命值\n%MAX% - 返回最大生命值\n%PERCENT% - 返回当前生命值除以最大生命值的百分比\n\n所有数值都会通过公式返回，请使用公式的文本样式设置好单位缩写。"

L["Custom format of mana"] = "自定义能量样式"
L["You can set custom mana format. More information about custom mana format you can read on project site.\n\n" ..
    "Formulas:"] = "可以自定义能量样式，关于能量样式的更多相关信息请浏览官方网站。\n\n公式语法:"
L["Use full values of mana"] = "使用完整的能量数值"
L["By default all formulas use divider (for value eq 1000 and more it's 1000, for 1 000 000 and more it's 1 000 000, etc).\n\n" ..
    "If checked formulas will use full values of mana (without divider)"] = "所有公式默认都会使用千位分隔符号 (大于或等于 1000 的数值会是 1000，大于或等于 1 000 000 会是 1 000 000，以此类推)。\n\n勾选时，公式会使用完整的能量数值 (沒有分隔符号)。"
L["Displayed mana by pattern"] = "使用样式显示能量"
L["You can use patterns:\n\n" ..
    "%CURRENT% - return current mana\n" ..
    "%MAX% - return maximum of mana\n" ..
    "%PERCENT% - return percent of current/max mana\n\n" ..
    "All values are returned from formulas. For set abbreviation use formulas' fields"] = "可以使用的样式有:\n\n%CURRENT% - 返回当前的能量\n%MAX% - 返回最大能量\n%PERCENT% - 返回当前能量除以最大能量的百分比\n\n所有数值都会通过公式返回，请使用公式的文本样式设置好单位缩写。"
L["Use Chinese numerals format"] = "使用中文数字单位"
L["By default all formulas use divider (for value eq 1000 and more is 1000, for 1 000 000 and more is 1 000 000, etc).\n" ..
    "But with this option divider eq 10 000 and 100 000 000.\n\n" ..
    "The description of the formulas remains the same, so the description of the formulas is not correct with this parameter, but the formulas work correctly.\n\n" ..
    "Use these formulas for Chinese numerals:\n" ..
    "Value greater than 1000 -> '%.2f万', and '%.2f萬' for zhTW.\n" ..
    "Value greater than 100 000 -> '%.1f万', and '%.1f萬' for zhTW.\n" ..
    "Value greater than 1 000 000 -> '%.1f万', and '%.1f萬' for zhTW.\n" ..
    "Value greater than 10 000 000 -> '%.0f万', and '%.0f萬' for zhTW.\n" ..
    "Value greater than 100 000 000 -> '%.2f亿', and '%.2f億' for zhTW.\n" ..
    "Value greater than 1 000 000 000 -> '%.2f亿', and '%.2f億' for zhTW.\n\n" ..
    "More information about Chinese numerals format you can read on project site"] = "所有公式默认都会使用千位分隔符号 (大于或等于 1000 的数值会是 1000，大于或等于 1 000 000 会是 1 000 000，以此类推)。\n\n勾选时，会使用 10 000 和 100 000 000。\n\n公式的说明保持不变，所以这个参数对公式的描述是不正确的，但公式我正确的。\n\n启用中文数字格式化时建议使用以下公式:\n" ..
    "数值大于 1000 -> '%.2f万', 和 '%.2f萬' (台灣)。\n" ..
    "数值大于 100 000 -> '%.1f万', 和 '%.1f萬' (台灣)。\n" ..
    "数值大于 1 000 000 -> '%.1f万', 和 '%.1f萬' (台灣)。\n" ..
    "数值大于 10 000 000 -> '%.0f万', 和 '%.0f萬' (台灣)。\n" ..
    "数值大于 100 000 000 -> '%.2f亿', 和 '%.2f億' (台灣)。\n" ..
    "数值大于 1 000 000 000 -> '%.2f亿', 和 '%.2f億' (台灣)。\n\n" ..
    "有关中文数字格式的更多信息，请访问项目网站"
