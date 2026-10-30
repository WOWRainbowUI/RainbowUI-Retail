local L = LibStub("AceLocale-3.0"):NewLocale("AutoPotion", "zhCN")
if not L then return end

-- InterfaceOptionsFrame
L["Addon Behaviour"] = "插件功能"
L["Auto Potion Settings"] = "Auto Potion 设置"
L["Cavedweller's Delight"] = "洞穴住民的挚爱"
L["Refreshing Serum"] = "复苏血清"
L["Class/Racial Spells"] = "职业/种族技能"
L["Configure the behavior of the addon. IE: if you want to include class spells"] = "您可以在此设置技能。例如：是否包含职业/种族回血技能"
L["Current Priority"] = "当前优先级"
L["Bandage Priority"] = "绷带优先级"
L["Use Rapid Regeneration (Troll racial) before bandages"] = "在绷带之前使用快速再生（巨魔种族技能）"
L["Food Priority"] = "食物优先级"
L["Drink Priority"] = "饮料优先级"
L["Mana Potion Priority"] = "法力药水优先级"
L["Include Rejuvenation Potions"] = "包含复原药水"
L["Also use potions that restore health and mana (Rejuvenation potions, Cavedweller's Delight, Refreshing Serum, ...). They are sorted by the amount of mana they restore."] = "同时使用可恢复生命值和法力值的药水（复原药水、洞穴住民的挚爱、复苏血清等），并按恢复的法力值多少排序。"
L["Shows the mana potion that will currently be used, based on what is in your bags."] = "根据背包内的物品，显示当前将被使用的法力药水。"
L["Include Buff Food"] = "包含增益食物"
L["Include \"Well Fed\"/\"Relaxed\" buff food and drink items (with situational secondary-stat bonuses) in the food and drink priority lists."] = "将\"进食充分\"/\"悠闲\"增益食物和饮料（含情境性副属性加成）纳入食物和饮料优先级列表。"
L["Only when the buff is missing"] = "仅在缺少增益时优先使用"
L["Eat buff food first while you don't have its buff (\"Well Fed\" for food, \"Relaxed\" for drinks), even before conjured food. While you have it, buff food comes last and is only eaten when nothing else is left."] = "缺少食物的“进食充分”或饮品的“放松”增益时，优先使用增益食物或饮品，顺序排在魔法制造的食物之前。已有增益时，增益食物会排在最后，仅在没有其他选择时使用。"
L["Go back to your first heal once its cooldown is over"] = "第一个治疗冷却结束后，重新从它开始"
L["If you don't press the macro for as long as your first heal's cooldown (talents included), the macro starts over with it. Works when the first heal is a spell or a Healthstone. A later heal with a longer cooldown can still make the macro wait."] = "若未按下宏的时间达到第一个治疗的冷却时间（包含天赋效果），宏就会重新从它开始。第一个治疗为法术或治疗石时适用。后续治疗若有更长的冷却时间，仍可能让宏等待。"
L["Heartseeking Health Injector (tinker)"] = "觅心生命注射器（匠械）"
L["Include /stopcasting in the macro"] = "添加停止施法（/stopcasting）到宏内（需重载界面）"
L["Invalid option: "] = "无效选项："
L["Items"] = "物品"
L["Soulburn Healthstone"] = "灵魂燃烧治疗石"
L["Casts Soulburn right before the macro in combat to empower your Healthstone. Costs a Soul Shard every time Soulburn is off cooldown, also on presses that use a potion or spell."] = "战斗中在宏前施放灵魂燃烧，强化你的治疗石。灵魂燃烧冷却完毕时，每次按下都会消耗一个灵魂碎片，即使该次使用的是药水或法术也一样。"
L["Low Priority Healthstones"] = "降低治疗石使用优先级"
L["Other / Racial"] = "其他 / 种族"
L["Potion of Withering Dreams"] = "凋零梦境药水"
L["Potion of Withering Vitality"] = "枯萎活力药水"
L["Prioritize health potions over a healthstone."] = "治疗药水优先于治疗石使用。"
L["Reset successful!"] = "重置成功！"
L["Reset to Default"] = "重置为默认"
L["Shows the bandage that will currently be used, based on what is in your bags."] = "显示当前将使用的绷带（依据背包物品）。"
L["Shows the food that will currently be used, based on what is in your bags."] = "显示当前将使用的食物（依据背包物品）。"
L["Shows the drink that will currently be used, based on what is in your bags."] = "显示当前将使用的饮料（依据背包物品）"
L["Useful for casters."] = "对施法职业有用。"

-- InfoOptionsFrame
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
L["Small quality of life features in one addon: a smaller viewport, junk selling and repairs, quests accepted and turned in for you, IDs and vendor prices in tooltips, a square minimap and dungeons on the world map."] = "整合多项便捷功能：缩小游戏视野、出售垃圾与修理、自动接受及交付任务、提示信息显示 ID 与售价、方形小地图，以及世界地图上的副本。"
L["Installed"] = "已安装"
L["Click and press %s to copy"] = "点击后按 %s 复制"
L["Ctrl+C"] = "Ctrl+C"

-- DO NOT TRANSLATE
L["AutoPotion"] = "AutoPotion"   -- DO NOT TRANSLATE
L["AutoBandage"] = "AutoBandage" -- DO NOT TRANSLATE
L["AutoFood"] = "AutoFood"       -- DO NOT TRANSLATE
L["AutoDrink"] = "AutoDrink"     -- DO NOT TRANSLATE
L["AutoManaPotion"] = "AutoManaPotion" -- DO NOT TRANSLATE

-- code.lua
L["Couldn't create the %s macro: your general macros are full. Delete one of them and it will be created."] = "无法创建 %s 宏：通用宏栏位已满。删除一个宏后便会自动创建。"


L["AutoFood Settings"] = "AutoFood"

L["AutoDrink Settings"] = "AutoDrink"

L["AutoManaPotion Settings"] = "自动法力药水"

L["AutoBandage Settings"] = "AutoBandage"
