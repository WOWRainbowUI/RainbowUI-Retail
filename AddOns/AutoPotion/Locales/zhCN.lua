local L = LibStub("AceLocale-3.0"):NewLocale("AutoPotion", "zhCN")
if not L then return end

-- InterfaceOptionsFrame
L["Addon Behaviour"] = "插件功能"
L["Auto Potion Settings"] = "Auto Potion 设置"
L["Cavedweller's Delight"] = "洞穴住民的挚爱"
L["Refreshing Serum"] = "复苏血清"
L["Class/Racial Spells"] = "职业/种族技能"
L["Configure the behavior of the addon. IE: if you want to include class spells"] = 
"您可以在此设置技能。例如：是否包含职业/种族回血技能"
L["Current Priority"] = "当前优先级"
L["Bandage Priority"] = "绷带优先级"
L["Food Priority"] = "食物优先级"
L["Drink Priority"] = "饮料优先级"
L["Mana Potion Priority"] = "法力药水优先级"
L["Include Rejuvenation Potions"] = "包含复原药水"
L["Also use potions that restore health and mana (Rejuvenation potions, Cavedweller's Delight, Refreshing Serum, ...). They are sorted by the amount of mana they restore."] =
"同时使用可恢复生命值和法力值的药水（复原药水、洞穴住民的挚爱、复苏血清等），并按恢复的法力值多少排序。"
L["Shows the mana potion that will currently be used, based on what is in your bags."] =
"根据背包内的物品，显示当前将被使用的法力药水。"
L["Include Buff Food"] = "包含增益食物"
L["Include \"Well Fed\"/\"Relaxed\" buff food and drink items (with situational secondary-stat bonuses) in the food and drink priority lists."] =
"将\"进食充分\"/\"悠闲\"增益食物和饮料（含情境性副属性加成）纳入食物和饮料优先级列表。"
L["Heartseeking Health Injector (tinker)"] = "觅心生命注射器（匠械）"
L["Include /stopcasting in the macro"] = "添加停止施法（/stopcasting）到宏内（需重载界面）"
L["Includes the shortest Cooldown in the reset Condition of Castsequence. !!USE CAREFULLY!!"] =
"在队列施法（Castsequence）的重置条件中加入最短冷却时间|cffff0000!!请谨慎使用!!|r"
L["Invalid option: "] = "无效选项："
L["Items"] = "物品"
L["Low Priority Healthstones"] = "降低治疗石使用优先级"
L["Other / Racial"] = "其他 / 种族"
L["Potion of Withering Dreams"] = "凋零梦境药水"
L["Potion of Withering Vitality"] = "枯萎活力药水"
L["Prioritize health potions over a healthstone."] = "治疗药水优先于治疗石使用。"
L["Reset successful!"] = "重置成功！"
L["Reset to Default"] = "重置为默认"
L["Shows the bandage that will currently be used, based on what is in your bags."] = 
"显示当前将使用的绷带（依据背包物品）。"
L["Shows the food that will currently be used, based on what is in your bags."] =
"显示当前将使用的食物（依据背包物品）。"
L["Shows the drink that will currently be used, based on what is in your bags."] =
"显示当前将使用的饮料（依据背包物品）"
L["The Settings of AutoPotion were reset due to breaking changes."] = 
"由于插件结构变动，AutoPotion的设置已被重置。"
L["Useful for casters."] = "对施法职业有用。"

-- code
L["AutoPotion"] = "AutoPotion"   -- DO NOT TRANSLATE
L["AutoBandage"] = "AutoBandage" -- DO NOT TRANSLATE
L["AutoFood"] = "AutoFood"       -- DO NOT TRANSLATE
L["AutoDrink"] = "AutoDrink"     -- DO NOT TRANSLATE
L["AutoManaPotion"] = "AutoManaPotion" -- DO NOT TRANSLATE


L["Soulburn Healthstone"] = "灵魂燃烧治疗石"
L["Casts Soulburn right before the macro in combat to empower your Healthstone. Costs a Soul Shard every time Soulburn is off cooldown, also on presses that use a potion or spell."] = "战斗中在宏前施放灵魂燃烧，强化你的治疗石。灵魂燃烧冷却完毕时，每次按下都会消耗一个灵魂碎片，即使该次使用的是药水或法术也一样。"

-- Settings display labels; macro identifiers remain unchanged.
L["AutoBandage Settings"] = "AutoBandage"
L["AutoFood Settings"] = "AutoFood"
L["AutoDrink Settings"] = "AutoDrink"

L["AutoManaPotion Settings"] = "自动法力药水"

-- Information page display strings.
L["AutoPotion keeps your macros up to date, so one key always uses the best you have right now: healing spells, potions, food, drink and bandages."] = "AutoPotion 会持续更新宏，让同一个按键随时使用目前最合适的治疗法术、药水、食物、饮品及绷带。"
L["Version %s"] = "版本 %s"
L["How it works"] = "使用方式"
L["AutoPotion creates the macros listed below. You find them under General Macros (/macro)."] = "AutoPotion 会创建下列宏，可在通用宏（/macro）中找到。"
L["Drag the macros you want onto your action bars and bind a key."] = "将需要的宏拖到动作条，并设置快捷键。"
L["That's it. The macros update themselves out of combat whenever your bags, talents or gear change. You still press the key yourself - AutoPotion never casts anything for you."] = "设置完成！背包、天赋或装备变动时，宏会在非战斗状态下自动更新。仍需自行按下按键，AutoPotion 不会自动替你施放法术。"
L["Each macro has its own settings page in the list on the left."] = "每个宏都在左侧列表中有专属的设置页。"
L["Macros"] = "宏"
L["Healthstones, healing potions and class/racial self-heals."] = "治疗石、治疗药水及职业／种族的自我治疗技能。"
L["The mana potion that restores the most mana."] = "恢复最多法力的法力药水。"
L["The best food in your bags."] = "背包中最合适的食物。"
L["The best drink in your bags."] = "背包中最合适的饮品。"
L["Your strongest bandage, including battleground bandages."] = "效果最强的绷带，包括战场绷带。"
L["Commands"] = "命令"
L["Opens these settings."] = "打开此设置页。"
L["Toggles debug messages in the chat."] = "切换聊天窗口中的调试信息。"
L["More addons by %s"] = "%s 的其他插件"
L["Applies the right Edit Mode layout, UI scale and AddOn set for your screen resolution. Made for switching between PC, laptop and Steam Deck."] = "根据屏幕分辨率应用合适的编辑模式布局、界面缩放及插件组合，方便在台式电脑、笔记本电脑与 Steam Deck 之间切换。"
L["An automatic journal of your adventures: level ups, dungeon runs, first boss kills, professions and your routes on the world map."] = "自动记录冒险历程：升级、地下城挑战、首次击败首领、专业技能，以及世界地图上的行进路线。"
L["Installed"] = "已安装"
L["Click and press %s to copy"] = "点击后按 %s 复制"
L["Ctrl+C"] = "Ctrl+C"
