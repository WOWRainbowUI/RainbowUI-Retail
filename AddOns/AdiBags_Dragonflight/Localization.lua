--[[
AdiBags - Dragonflight - Localization
by Zottelchen
version: 2.3.30
This file contains translations for this filter.
]]
local addonName, addon = ...

--<GLOBALS
local _G = _G
local GetLocale = _G.GetLocale
local pairs = _G.pairs
local rawset = _G.rawset
local setmetatable = _G.setmetatable
local tostring = _G.tostring
--GLOBALS>

local L = setmetatable({}, {
  __index = function(self, key)
    if key ~= nil then
      rawset(self, key, tostring(key))
    end
    return tostring(key)
  end,
})
addon.L = L

L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] =
  true
L["Colored Categories"] = true
L["Colored Prefix"] = true
L["Custom Prefix"] = true
L["Enter a custom prefix for the categories."] = true
L["Filter version"] = true
L["General Settings"] = true
L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = true
L["None"] = true
L["Prefix Categories"] = true
L["Prefix Color"] = true
L["Select a color for the prefix."] = true
L["Select a prefix for the categories, if you like."] = true
L["Settings affecting all categories."] = true
L["Should Categories be colored?"] = true
L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = true
L["These settings affect all categories of this filter."] = true
--
L["%sMerge %s%s"] = true
L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] =
  true
L["Achievements & Unlockables"] = true
L["Alchemy Flasks"] = true
L["Artifacts"] = true
L["Artisan Curious"] = true
L["Awakened Elementals"] = true
L["Awakened and Rousing Elemental Trade Goods"] = true
L["Baits to attract skinnable creatures"] = true
L["Bandages"] = true
L["Bandages, to patch up your broken friends :)"] = true
L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] =
  true
L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = true
L["Catch-Up Weapon."] = true
L["Cauldrons"] = true
L["Cauldrons, to share your soup with friends :)"] = true
L["Cavern Clawbering (Achievement)"] = true
L["Cavern Currencies"] = true
L["Chip (Pet)"] = true
L["Cloth"] = true
L["Cloth Catch-Up Gear."] = true
L["Color"] = true
L["Consumables"] = true
L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] =
  true
L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = true
L["Contains runes & vantus runes which improving your combat ability."] = true
L["Contains various tools, helpful in the Dragon Isles."] = true
L["Contracts"] = true
L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = true
L["Cooking"] = true
L["Crafting Potions"] = true
L["Crafting Reagents categorically belonging to Alchemy"] = true
L["Crafting Reagents categorically belonging to Cloth"] = true
L["Crafting Reagents categorically belonging to Cooking"] = true
L["Crafting Reagents categorically belonging to Enchanting"] = true
L["Crafting Reagents categorically belonging to Engineering"] = true
L["Crafting Reagents categorically belonging to Herbs"] = true
L["Crafting Reagents categorically belonging to Inscription"] = true
L["Crafting Reagents categorically belonging to Jewelcrafting"] = true
L["Crafting Reagents categorically belonging to Leather"] = true
L["Crafting Reagents categorically belonging to Mining"] = true
L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = true
L["Darkmoon Cards"] = true
L["Dragonflight"] = true
L["Drakewatcher Manuscripts"] = true
L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = true
L["Dreambound Armor"] = true
L["Dreambound armor is the catch-up gear of 10.1.7."] = true
L["Dreaming Crests"] = true
L["Dreamseeds"] = true
L["Dreamsurge"] = true
L["Dreamsurges are the part of the content of 10.1.7."] = true
L["Elemental Trade Goods"] = true
L["Embellishments"] = true
L["Embers of Neltharion (10.1)"] = true
L["Emerald Bounties are triggered once you plant any dreamseeds at Emerald Bounty mud piles located around the Emerald Dream."] =
  true
L["Enchanting"] = true
L["Enchanting - Insight of the Blue"] = true
L["Engineering"] = true
L["Fishing Lures"] = true
L["Fishing Lures for catching specific fish"] = true
L["Food"] = true
L["Food added in the Dragonflight expansion"] = true
L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = true
L["Forbidden Reach (10.0.7)"] = true
L["Fortune Cards"] = true
L["Fyrak Assault"] = true
L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = true
L["Gems"] = true
L["General Crafting Reagents"] = true
L["General Crafting Reagents, used by multiple professions"] = true
L["General Profession Items"] = true
L["Guardians of the Dream (10.2)"] = true
L["Herbs"] = true
L["Herbs - Seeds"] = true
L["Honor Our Ancestors"] = true
L["Incense"] = true
L["Incense to improve crafting ability or just for a nice smell"] = true
L["Inscription"] = true
L["Item Level Upgrades"] = true
L["Items found or used in the Zskera Vault."] = true
L["Items from the Dragonflight Pre-Event."] = true
L["Items from the Dragonflight expansion."] = true
L["Items in professions"] = true
L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = true
L["Items that provide embellishments to crafted items."] = true
L["Items that provide profession knowledge"] = true
L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] =
  true
L["Items which are used in multiple professions."] = true
L["Items which can be found and used in the Emerald Dream and related zones."] = true
L["Items which can be found and used in the Forbidden Reach."] = true
L["Items which can be found and used in the Zaralek Cavern."] = true
L["Items which upgrade the item level of crafted gear."] = true
L["Items you can eat or use to improve yourself"] = true
L["Jewelcrafting"] = true
L["Leather"] = true
L["Leather - Bait"] = true
L["Leather Catch-Up Gear."] = true
L["Leftover Elemental Slime"] = true
L["Librarian of the Reach (Achievement)"] = true
L["Lizis Reins (Mount)"] = true
L["Magmashell (Mount)"] = true
L["Mail Catch-Up Gear."] = true
L["Maps to Treasure found in the Dragon Isles"] = true
L["Merge all %s into a single category."] = true
L["Mining"] = true
L["Mossy Mammoth"] = true
L["Other Items"] = true
L["Other items not really fitting in another category."] = true
L["Otto (Mount)"] = true
L["Permanent Enhancements"] = true
L["Phials"] = true
L["Phials added in the Dragonflight expansion"] = true
L["Phoenix Wishwing (Pet)"] = true
L["Plate Catch-Up Gear."] = true
L["Potions"] = true
L["Potions added in the Dragonflight expansion"] = true
L["Potions which improve crafting or collecting"] = true
L["PreEvent"] = true
L["PreEvent Currency"] = true
L["PreEvent Gear"] = true
L["Primalist Accessories"] = true
L["Primalist Cloth"] = true
L["Primalist Gear Tokens"] = true
L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = true
L["Primalist Leather"] = true
L["Primalist Mail"] = true
L["Primalist Plate"] = true
L["Primalist Weapon"] = true
L["Primordial Stones & Onyx Annulet"] = true
L["Profession Gear"] = true
L["Profession Knowledge"] = true
L["Professions"] = true
L["Recipes"] = true
L["Recipes teach you new ways to craft items."] = true
L["Reputation Items"] = true
L["Rousing Elementals"] = true
L["Ruby Feast"] = true
L["Runes"] = true
L["Scrappy Worldsnail (Mount)"] = true
L["Seeds to plant into Rich Soil which in return grants some herbs"] = true
L["Select a color for %s."] = true
L["Select a color for the merged %s category."] = true
L["Shadowflame Crests"] = true
L["Specialized gear which improves your profession"] = true
L["Statues"] = true
L["Statues crafted by Jewelcrafters. They improve various things."] = true
L["Temperamental Skyclaw (Mount)"] = true
L["Temporary & Permanent Enhancements"] = true
L["Temporary Enhancements"] = true
L["Tetrachromancer (Achievement)"] = true
L["These are gems that you can typically apply to armor to improve it."] = true
L["These are permanent enhancements that you can typically apply to armor to improve it."] = true
L["These are temporary enhancements that you can typically apply to armor to improve it."] = true
L["These artifacts can be traded in Morqut Village."] = true
L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = true
L["These items can be used to summon a rare mob in the Forbidden Reach."] = true
L["This category contains Dreaming Crests, which can be used to upgrade gear."] = true
L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] =
  true
L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = true
L["This category contains currencies, used in the Zaralek Cavern."] = true
L["This category contains fragments, used during the Fyrak Assault event."] = true
L["This category contains hunting companion colors needed for the achievement."] = true
L["This category contains the books looted for the Librarian of the Reach achievement."] = true
L["This category contains the item needed to get the Cavern Clawbering achievement."] = true
L["This category contains the items needed to get the Chip pet."] = true
L["This category contains the items needed to get the Phoenix Wishwing pet."] = true
L["This category contains the quest items looted for the While We Were Sleeping achievement."] = true
L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = true
L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] =
  true
L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = true
L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = true
L["Time Rifts"] = true
L["Time Rifts are the part of the content of 10.1.5."] = true
L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] =
  true
L["Tools"] = true
L["Treasure Maps"] = true
L["Treasure Sacks"] = true
L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = true
L["Untapped Forbidden Knowledge"] = true
L["Use these for a powerup!"] = true
L["While We Were Sleeping (Achievement)"] = true
L["Zskera Vault"] = true

local locale = GetLocale()
if locale == "zhTW" then
L["%sMerge %s%s"] = "%s合併%s%s"
--[[Translation missing --]]
--[[ L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = "A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."--]] 
L["Achievements & Unlockables"] = "成就 & 解鎖用"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags 從來沒有打算使用圖示，所以這只是小故障。如果你使用圖示，請確保已停用彩色前置文字。"
L["Alchemy Flasks"] = "煉金瓶"
L["Artifacts"] = "文物"
L["Artisan Curious"] = "工匠珍品"
L["Awakened and Rousing Elemental Trade Goods"] = "製造材料喚醒元素和覺醒元素"
L["Awakened Elementals"] = "覺醒元素"
L["Baits to attract skinnable creatures"] = "用來吸引一些可剝皮生物的餌"
L["Bandages"] = "繃帶"
L["Bandages, to patch up your broken friends :)"] = "繃帶, 幫你受傷的朋友包紮"
L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = "追趕機制飾品 - 包括戒指、項鍊、飾品和披風。"
L["Catch-Up Weapon."] = "追趕機制武器。"
L["Cauldrons"] = "大鍋"
L["Cauldrons, to share your soup with friends :)"] = "大鍋, 分享湯給你的朋友"
L["Cavern Clawbering (Achievement)"] = "響動爪 (成就)"
L["Cavern Currencies"] = "洞窟通貨"
L["Chip (Pet)"] = "小鑿 (寵物)"
L["Cloth"] = "布料"
L["Cloth Catch-Up Gear."] = "追趕機制布甲。"
L["Color"] = "顏色"
L["Colored Categories"] = "彩色類別名稱"
L["Colored Prefix"] = "彩色前置文字"
L["Consumables"] = "消耗品"
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = "CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."--]] 
L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = "包含直接用來繳交聲望/名望的物品，以及交給怒西昂和賽柏利安的物品。"
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = "Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"--]] 
L["Contains runes & vantus runes which improving your combat ability."] = "包含符文 & 梵陀符文，可用來強化你的戰鬥能力。"
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = "Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."--]] 
L["Contains various tools, helpful in the Dragon Isles."] = "包含各種在巨龍群島有用的工具。"
L["Contracts"] = "合約"
L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = "合約在你完成巨龍群島的世界任務時會給予你額外的聲望"
L["Cooking"] = "烹飪"
L["Crafting Potions"] = "加工藥水"
L["Crafting Reagents categorically belonging to Alchemy"] = "煉金術相關的製造材料"
L["Crafting Reagents categorically belonging to Cloth"] = "裁縫相關的製造材料"
L["Crafting Reagents categorically belonging to Cooking"] = "烹飪相關的製造材料"
L["Crafting Reagents categorically belonging to Enchanting"] = "附魔相關的製造材料"
L["Crafting Reagents categorically belonging to Engineering"] = "工程學相關的製造材料"
L["Crafting Reagents categorically belonging to Herbs"] = "草藥學"
L["Crafting Reagents categorically belonging to Inscription"] = "銘文學相關的製造材料"
L["Crafting Reagents categorically belonging to Jewelcrafting"] = "珠寶學相關的製造材料"
L["Crafting Reagents categorically belonging to Leather"] = "製皮相關的製造材料"
L["Crafting Reagents categorically belonging to Mining"] = "採礦相關的製造材料"
L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = "巨龍崛起前夕事件掉落的，類似貨幣的物品。"
L["Custom Prefix"] = "自訂前置文字"
L["Darkmoon Cards"] = "暗月卡"
L["Dragonflight"] = "巨龍崛起"
L["Drakewatcher Manuscripts"] = "飛龍觀察者手稿"
L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = "學習飛龍騎術坐騎新外觀的飛龍觀察者手稿"
L["Elemental Trade Goods"] = "元素"
L["Embellishments"] = "裝飾"
L["Embers of Neltharion (10.1)"] = "奈薩里奧的餘燼 (10.1)"
L["Enchanting"] = "附魔"
L["Enchanting - Insight of the Blue"] = "附魔 - 藍龍洞察力"
L["Engineering"] = "工程學"
L["Enter a custom prefix for the categories."] = "輸入類別的自訂前置文字。"
L["Filter version"] = "版本"
L["Fishing Lures"] = "魚餌"
L["Fishing Lures for catching specific fish"] = "用來釣特定魚的餌"
L["Food"] = "食物"
L["Food added in the Dragonflight expansion"] = "巨龍崛起版本的食物"
L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = "晶紅盛宴的食物 - 只有裝飾效果能在開放地圖外使用"
L["Forbidden Reach (10.0.7)"] = "禁忌之境 (10.0.7)"
L["Fortune Cards"] = "命運卡片"
L["Fyrak Assault"] = "菲拉克入侵"
L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = "巨龍崛起前夕事件掉落的或購買的裝備"
L["Gems"] = "寶石"
L["General Crafting Reagents"] = "通用材料"
L["General Crafting Reagents, used by multiple professions"] = "通用的製造材料，多種專業都會用到。"
L["General Profession Items"] = "通用專業物品"
L["General Settings"] = "一般設定"
L["Herbs"] = "草藥"
L["Herbs - Seeds"] = "草藥 - 種子"
L["Honor Our Ancestors"] = "光宗耀祖"
L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = "取代前置文字或類別顏色時，需要開關顏色設定兩次，或是重新載入介面。"
L["Incense"] = "薰香"
L["Incense to improve crafting ability or just for a nice smell"] = "薰香可以增加你製造的能力或是只是好聞的味道"
L["Inscription"] = "銘文學"
L["Item Level Upgrades"] = "提升物品等級"
L["Items found or used in the Zskera Vault."] = "在澤斯克拉密庫找到和使用物品。"
L["Items from the Dragonflight expansion."] = "巨龍崛起資料片的物品。"
L["Items from the Dragonflight Pre-Event."] = "巨龍崛起前夕事件的物品。"
L["Items in professions"] = "專業物品"
L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = "當附魔專精 '藍龍洞察力' 有點的時候可以找到並分解的物品"
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = "Items that provide embellishments to crafted items."--]] 
L["Items that provide profession knowledge"] = "提供專業知識的物品"
L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = "用於成就或可用來解鎖坐騎的物品，一旦成就或坐騎解鎖後，這些物品就沒有價值了。"
L["Items which are used in multiple professions."] = "多種專業都會用到的物品。"
L["Items which can be found and used in the Forbidden Reach."] = "在禁忌之境找到和使用物品。"
L["Items which can be found and used in the Zaralek Cavern."] = "在札拉萊克洞窟找到和使用物品。"
L["Items which upgrade the item level of crafted gear."] = "用來升級製作裝備等級的物品。"
L["Items you can eat or use to improve yourself"] = "可以吃或使用，用來強化自己的物品。"
L["Jewelcrafting"] = "珠寶加工"
L["Leather"] = "皮革"
L["Leather - Bait"] = "皮革 - 誘餌"
L["Leather Catch-Up Gear."] = "追趕機制皮甲。"
L["Leftover Elemental Slime"] = "殘留的元素黏液"
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = "Librarian of the Reach (Achievement)"--]] 
L["Lizis Reins (Mount)"] = "莉茲 (坐騎)"
L["Magmashell (Mount)"] = "熔殼蝸牛 (坐騎)"
L["Mail Catch-Up Gear."] = "追趕機制鎖甲。"
L["Maps to Treasure found in the Dragon Isles"] = "巨龍群島的藏寶圖"
L["Merge all %s into a single category."] = "將所有%s都合併成單一類別"
L["Mining"] = "採礦"
L["Mossy Mammoth"] = "青苔猛瑪象"
L["None"] = "無"
L["Other Items"] = "其他物品"
L["Other items not really fitting in another category."] = "不屬於任何現有類別的其他物品。"
L["Otto (Mount)"] = "奧圖 (坐騎)"
L["Permanent Enhancements"] = "永久性強化"
L["Phials"] = "藥瓶"
L["Phials added in the Dragonflight expansion"] = "巨龍崛起資料片新增的藥瓶"
L["Phoenix Wishwing (Pet)"] = "鳳凰希翼 (寵物)"
L["Plate Catch-Up Gear."] = "追趕機制板甲。"
L["Potions"] = "藥水"
L["Potions & Elixirs"] = "藥水 & 精煉"
L["Potions added in the Dragonflight expansion"] = "巨龍崛起資料片的藥水"
L["Potions which improve crafting"] = "強化專業製造的藥水"
L["Potions which improve crafting or collecting"] = "強化專業製造或採集力的藥水"
L["PreEvent"] = "前夕事件"
L["PreEvent Currency"] = "前夕事件貨幣"
L["PreEvent Gear"] = "前夕事件裝備"
L["Prefix Categories"] = "類別前置文字/圖示"
L["Prefix Color"] = "前置文字顏色"
L["Primalist Accessories"] = "洪荒飾品"
L["Primalist Cloth"] = "洪荒布甲"
L["Primalist Gear Tokens"] = "洪荒裝備代幣"
L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = "洪荒裝備代幣是帳號綁定的追趕機制裝備。"
L["Primalist Leather"] = "洪荒皮甲"
L["Primalist Mail"] = "洪荒鎖甲"
L["Primalist Plate"] = "洪荒鎧甲"
L["Primalist Weapon"] = "洪荒武器"
L["Primordial Stones & Onyx Annulet"] = "原初之石&瑪瑙環飾"
L["Profession Gear"] = "專業裝備"
L["Profession Knowledge"] = "專業知識"
L["Professions"] = "專業"
L["Reputation Items"] = "聲望物品"
L["Rousing Elementals"] = "喚醒元素"
L["Ruby Feast"] = "晶紅盛宴"
L["Runes"] = "符文"
L["Scrappy Worldsnail (Mount)"] = "好鬥的天體蝸牛"
L["Seeds to plant into Rich Soil which in return grants some herbs"] = "將種子種在肥沃的土壤中，會穫得一些草藥。"
L["Select a color for %s."] = "選擇%s的顏色。"
L["Select a color for the merged %s category."] = "選擇合併的%s類別顏色。"
L["Select a color for the prefix."] = "選擇前置文字的顏色。"
L["Select a prefix for the categories, if you like."] = "如果你想的話，可以幫類別選擇前置文字/圖案。"
L["Settings affecting all categories."] = "會影響所有類別的設定。"
L["Shadowflame Crests"] = "暗焰紋章"
L["Should Categories be colored?"] = "類別是否要彩色的?"
L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = "前置文字是否要彩色的，以便篩選顏色? (很明顯的只適用於文字)"
L["Specialized gear which improves your profession"] = "強化專業的特殊裝備"
L["Statues"] = "雕像"
L["Statues crafted by Jewelcrafters. They improve various things."] = "珠寶製造的雕像. 有不同的效果"
L["Temperamental Skyclaw (Mount)"] = "暴躁的天爪 (坐騎)"
L["Temporary & Permanent Enhancements"] = "暫時 & 永久性強化"
L["Temporary Enhancements"] = "暫時性強化"
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = "Tetrachromancer (Achievement)"--]] 
L["These are gems that you can typically apply to armor to improve it."] = "這些是通常用在護甲上以獲得提升的寶石。"
L["These are permanent enhancements that you can typically apply to armor to improve it."] = "這些是通常用在護甲上以獲得提升的永久性強化。"
L["These are temporary enhancements that you can typically apply to armor to improve it."] = "這些是通常用在護甲上以獲得提升的暫時性強化。"
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = "These artifacts can be traded in Morqut Village."--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = "These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."--]] 
L["These items can be used to summon a rare mob in the Forbidden Reach."] = "這些物品可以用來召喚禁忌之境的稀有物。"
L["These settings affect all categories of this filter."] = "這些設定會影響這個過濾程式中的所有類別。"
L["This category contains currencies, used in the Zaralek Cavern."] = "此類別包含在札拉萊克洞窟使用的貨幣。"
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = "This category contains fragments, used during the Fyrak Assault event."--]] 
L["This category contains hunting companion colors needed for the achievement."] = "此類別包含達成成就所需的狩獵夥伴顏色。"
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = "This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = "This category contains Shadowflame Crests, which can be used to upgrade gear."--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = "This category contains the books looted for the Librarian of the Reach achievement."--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = "This category contains the item needed to get the Cavern Clawbering achievement."--]] 
L["This category contains the items needed to get the Chip pet."] = "此類別包含獲得寵物小鑿所需的物品。"
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = "This category contains the items needed to get the Phoenix Wishwing pet."--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = "This category contains the quest items looted for the While We Were Sleeping achievement."--]] 
L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = "此類別只包含在甦醒海岸取得熔殼蝸牛坐騎所需的空熔岩外殼。"
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = "This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = "This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = "This section contains items which are needed to unlock Otto, the fishing ottusk mount."--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = "To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."--]] 
L["Tools"] = "工具"
L["Treasure Maps"] = "藏寶圖"
L["Treasure Sacks"] = "珍寶囊"
L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = "所有龍族的救世主，大史瓦格蛙給的珍寶囊。"
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = "Untapped Forbidden Knowledge"--]] 
L["Use these for a powerup!"] = "使用這些來增強能力!"
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = "While We Were Sleeping (Achievement)"--]] 
L["Zskera Vault"] = "澤斯克拉密庫"

-- 自行加入
L["Recipes"] = "配方"
L["Recipes teach you new ways to craft items."] = "配方會教你製作新的物品。"
L["Dreambound Armor"] = "縛夢護甲"
L["Dreambound armor is the catch-up gear of 10.1.7."] = "縛夢護甲是 10.1.7 追趕機制的裝備。"
L["Dreamsurge"] = "夢境湧現"
L["Dreamsurges are the part of the content of 10.1.7."] = "夢境湧現是 10.1.7 的內容之一。"
L["Dreaming Crests"] = "夢境紋章"
L["Guardians of the Dream (10.2)"] = "夢境守護者 (10.2)"
L["Items which can be found and used in the Emerald Dream and related zones."] = "在翡翠夢境找到和使用物品。"
L["This category contains Dreaming Crests, which can be used to upgrade gear."] = "此類別包含用來升級裝備的夢境紋章。"
L["Dreamseeds"] = "夢境種子"
L["Emerald Bounties are triggered once you plant any dreamseeds at Emerald Bounty mud piles located around the Emerald Dream."] =
  "只要在翡翠夢境區域內的翡翠恩惠土壤種下夢境種子，就會觸發翡翠恩惠的獎勵。"
L["Time Rifts"] = "時間裂隙"
L["Time Rifts are the part of the content of 10.1.5."] = "時間裂隙是 10.1.5 的內容之一。"

end

for k, v in pairs(L) do
  if v == true then
    L[k] = k
  end
end
