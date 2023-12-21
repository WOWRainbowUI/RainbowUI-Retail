local addonName, addon = ...

local L = setmetatable({}, {
	__index = function(self, key)
		if key then
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

local locale = GetLocale()

if locale == "enUS" then
L["Battle Pet Items"] = true
L["Items that are connected to Battle Pets and not actual pets."] = true
L["Miscellaneous Items"] = true
L["Items that dont fall into any other category"] = true
L["Battle Pet Currency Items"] = true
L["Items used to buy Battle Pet related Items"] = true
L["Drop Battle Pet containers"] = true
L["Items that drop that can contain Battle Pets"] = true
L["Bags and Supplies"] = true
L["Bags that are obtained that contain Battle Pet Items"] = true
L["Rarity Stones"] = true
L["Items that increase rarity of Battle Pets"] = true
L["Training Stones"] = true
L["Items that add levels to Battle Pets"] = true
L["Pet Toys"] = true
L["Toys usable with all Battle Pets"] = true
L["Pug Costumes"] = true
L["All items for your Perky Pugs"] = true
elseif locale == "zhCN" then
--Translation missing
elseif locale == "zhTW" then
L["Battle Pet Items"] = "戰寵用品"
L["Items that are connected to Battle Pets and not actual pets."] = "和戰寵有關的物品，不是實際的戰寵。"
L["Miscellaneous Items"] = "其他物品"
L["Items that dont fall into any other category"] = "不屬於其他任何類別的物品"
L["Battle Pet Currency Items"] = "戰寵貨幣物品"
L["Items used to buy Battle Pet related Items"] = "用來購買戰寵相關物品的物品"
L["Drop Battle Pet containers"] = "掉落的戰寵"
L["Items that drop that can contain Battle Pets"] = "內含戰寵的掉落物品"
L["Bags and Supplies"] = "袋子和補給品"
L["Bags that are obtained that contain Battle Pet Items"] = "獲得的裝有戰寵物品的袋子"
L["Rarity Stones"] = "稀有石頭"
L["Items that increase rarity of Battle Pets"] = "升級戰寵稀有度的物品"
L["Training Stones"] = "訓練石頭"
L["Items that add levels to Battle Pets"] = "提升戰寵等級的物品"
L["Pet Toys"] = "寵物玩具"
L["Toys usable with all Battle Pets"] = "適用於所有戰寵的玩具"
L["Pug Costumes"] = "地雷犬服裝"
L["All items for your Perky Pugs"] = "給活潑的地雷犬用的所有東西"
end

-- Replace remaining true values by their key
for k,v in pairs(L) do
	if v == true then
		L[k] = k
	end
end
