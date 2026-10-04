local L = LibStub("AceLocale-3.0"):NewLocale("AutoPotion", "zhTW")
if not L then return end

-- InterfaceOptionsFrame
L["Addon Behaviour"] = "插件功能"
L["Auto Potion Settings"] = "一鍵吃糖/喝紅水"
L["Cavedweller's Delight"] = "穴居者之喜"
L["Refreshing Serum"] = "提神藥水"
L["Class/Racial Spells"] = "職業/種族技能"
L["Configure the behavior of the addon. IE: if you want to include class spells"] = "這裡可以調整插件的功能，例如也能使用職業法術。"
L["Current Priority"] = "目前的優先順序"
L["Bandage Priority"] = "繃帶優先"
L["Heartseeking Health Injector (tinker)"] = "覓心生命注射器 (裝置)"
L["Include /stopcasting in the macro"] = "在巨集中包含停止施法"
L["Includes the shortest Cooldown in the reset Condition of Castsequence. !!USE CAREFULLY!!"] = "連續施放的重置條件使用最短的冷卻時間。!!請謹慎使用!!"
L["Invalid option: "] = "無效選項："
L["Items"] = "物品"
L["Low Priority Healthstones"] = "治療石的優先順序較低"
L["Potion of Withering Dreams"] = "枯萎夢境藥水"
L["Potion of Withering Vitality"] = "凋萎活力藥水"
L["Prioritize health potions over a healthstone."] = "將治療藥水優先於治療石。"
L["Reset successful!"] = "重置成功！"
L["Reset to Default"] = "重置為預設值"
L["The Settings of AutoPotion were reset due to breaking changes."] = "因為插件大改版的關係，一鍵吃糖/喝紅水的設定已被重置。"
L["Useful for casters."] = "對於需要唱法的職業很有用。"

-- code
L["AutoPotion"] = "治療"

-- 自行加入
L["Auto Potion"] = "一鍵吃糖"
L["Food Priority"] = "食物優先順序"
L["Drink Priority"] = "飲品優先順序"
L["Include Buff Food"] = "包含增益食物"
L["Include \"Well Fed\"/\"Relaxed\" buff food and drink items (with situational secondary-stat bonuses) in the food and drink priority lists."] = "將提供「充分進食」或「放鬆」增益的食物與飲品（可依情況增加次要屬性）納入食物和飲品的優先順序清單。"
L["Other / Racial"] = "其他/種族技能"
L["Shows the bandage that will currently be used, based on what is in your bags."] = "依照背包中的物品，顯示目前會使用的繃帶。"
L["Shows the food that will currently be used, based on what is in your bags."] = "依照背包中的物品，顯示目前會使用的食物。"
L["Shows the drink that will currently be used, based on what is in your bags."] = "依照背包中的物品，顯示目前會使用的飲品。"

-- 巨集識別名稱沿用作者設定，避免改變新功能的巨集名稱。
L["AutoBandage"] = "AutoBandage"
L["AutoFood"] = "AutoFood"
L["AutoDrink"] = "AutoDrink"

L["Soulburn Healthstone"] = "靈魂燃燒治療石"
L["Casts Soulburn right before the macro in combat to empower your Healthstone. Costs a Soul Shard every time Soulburn is off cooldown, also on presses that use a potion or spell."] = "戰鬥中在巨集前施放靈魂燃燒，強化你的治療石。靈魂燃燒冷卻完畢時，每次按下都會消耗一個靈魂裂片，即使該次使用的是藥水或法術也一樣。"

-- Settings display labels; macro identifiers remain unchanged.
L["AutoBandage Settings"] = "自動繃帶"
L["AutoFood Settings"] = "自動進食"
L["AutoDrink Settings"] = "自動喝水"
