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

L["Mana Potion Priority"] = "法力藥水優先順序"
L["Include Rejuvenation Potions"] = "包含恢復藥水"
L["Also use potions that restore health and mana (Rejuvenation potions, Cavedweller's Delight, Refreshing Serum, ...). They are sorted by the amount of mana they restore."] = "也使用能恢復生命力和法力的藥水（恢復藥水、洞穴住民的喜悅、復甦血清等），並依恢復的法力數量排序。"
L["Shows the mana potion that will currently be used, based on what is in your bags."] = "依照背包內的物品，顯示目前將使用的法力藥水。"
L["AutoManaPotion"] = "AutoManaPotion"
L["AutoManaPotion Settings"] = "自動法力藥水"

-- Information page display strings.
L["AutoPotion keeps your macros up to date, so one key always uses the best you have right now: healing spells, potions, food, drink and bandages."] = "AutoPotion 會持續更新巨集，讓同一個按鍵隨時使用目前最合適的治療法術、藥水、食物、飲品及繃帶。"
L["Version %s"] = "版本 %s"
L["How it works"] = "使用方式"
L["AutoPotion creates the macros listed below. You find them under General Macros (/macro)."] = "AutoPotion 會建立下列巨集，可在一般巨集（/macro）中找到。"
L["Drag the macros you want onto your action bars and bind a key."] = "將需要的巨集拖到快捷列，並設定快速鍵。"
L["That's it. The macros update themselves out of combat whenever your bags, talents or gear change. You still press the key yourself - AutoPotion never casts anything for you."] = "設定完成！背包、天賦或裝備變動時，巨集會在非戰鬥狀態下自動更新。仍需自行按下按鍵，AutoPotion 不會自動替你施放法術。"
L["Each macro has its own settings page in the list on the left."] = "每個巨集都在左側清單中有專屬的設定頁。"
L["Macros"] = "巨集"
L["Healthstones, healing potions and class/racial self-heals."] = "治療石、治療藥水及職業／種族的自我治療技能。"
L["The mana potion that restores the most mana."] = "恢復最多法力的法力藥水。"
L["The best food in your bags."] = "背包中最合適的食物。"
L["The best drink in your bags."] = "背包中最合適的飲品。"
L["Your strongest bandage, including battleground bandages."] = "效果最強的繃帶，包含戰場繃帶。"
L["Commands"] = "指令"
L["Opens these settings."] = "開啟此設定頁。"
L["Toggles debug messages in the chat."] = "切換聊天視窗中的除錯訊息。"
L["More addons by %s"] = "%s 的其他插件"
L["Applies the right Edit Mode layout, UI scale and AddOn set for your screen resolution. Made for switching between PC, laptop and Steam Deck."] = "依螢幕解析度套用適合的編輯模式配置、介面縮放及插件組合，方便在桌上型電腦、筆記型電腦與 Steam Deck 之間切換。"
L["An automatic journal of your adventures: level ups, dungeon runs, first boss kills, professions and your routes on the world map."] = "自動記錄冒險歷程：升級、地城挑戰、首次擊敗首領、專業技能，以及世界地圖上的行進路線。"
L["Installed"] = "已安裝"
L["Click and press %s to copy"] = "點擊後按 %s 複製"
L["Ctrl+C"] = "Ctrl+C"
