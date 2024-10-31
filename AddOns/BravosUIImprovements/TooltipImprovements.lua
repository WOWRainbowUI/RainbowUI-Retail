local enabled = nil

-- Several items are wrongly reported as Classic items, use
-- this table to correct them
local overrideTable = {
	[23500] = "燃燒的遠征", -- Saltheril's Haven Party Invitation
	[31404] = "燃燒的遠征", -- Green Trophy Tabard of the Illidari
	[31405] = "燃燒的遠征", -- Purple Trophy Tabard of the Illidari
	[31774] = "燃燒的遠征", -- Kurenai Tabard
	[31780] = "燃燒的遠征", -- Scryers Tabard
	[31804] = "燃燒的遠征", -- Cenarion Expedition Tabard
	[32445] = "燃燒的遠征", -- Skyguard Tabard
	[32572] = "燃燒的遠征", -- Apexis Crystal
	[33292] = "燃燒的遠征", -- Hallowed Helm
	[35221] = "燃燒的遠征", -- Tabard of the Shattered Sun
	[36941] = "燃燒的遠征", -- Competitor's Tabard
	[37863] = "燃燒的遠征", -- Direbrew's Remote
	[38682] = "巫妖王之怒", -- Enchanting Vellum
	[40643] = "巫妖王之怒", -- Tabard of the Achiever
	[43345] = "巫妖王之怒", -- Dragon Hide Bag
	[43348] = "巫妖王之怒", -- Tabard of the Explorer
	[43349] = "巫妖王之怒", -- Tabard of Brute Force
	[43876] = "巫妖王之怒", -- A Guide to Northern Cloth Scavenging
	[45574] = "巫妖王之怒", -- Stormwind Tabard
	[45577] = "巫妖王之怒", -- Ironforge Tabard
	[45578] = "巫妖王之怒", -- Gnomeregan Tabard
	[45579] = "巫妖王之怒", -- Darnassus Tabard
	[45580] = "巫妖王之怒", -- Exodar Tabard
	[45798] = "巫妖王之怒", -- Heroic Celestial Planetarium Key
	[45858] = "巫妖王之怒", -- Nat's Lucky Fishing Pole
	[52723] = "浩劫與重生", -- Runed Elementium Rod
	[64398] = "浩劫與重生", -- Standard of Unity
	[64882] = "浩劫與重生", -- Gilneas Tabard
	[69748] = "浩劫與重生", -- Tattered Hexcloth Bag
	[71083] = "浩劫與重生", -- Darkmoon Game Token
	[71634] = "浩劫與重生", -- Darkmoon Adventurer's Guide
	[71638] = "浩劫與重生", -- Ornate Weapon
	[81055] = "潘達利亞之謎", -- Darkmoon Ride Ticket
	[86566] = "潘達利亞之謎", -- Forager's Gloves
	[89795] = "潘達利亞之謎", -- Lorewalkers Tabard
	[89880] = "潘達利亞之謎", -- Dented Shovel
	[89911] = "潘達利亞之謎", -- Alliance Firework
	[103533] = "潘達利亞之謎", -- Vicious Saddle
	[104105] = "潘達利亞之謎", -- Glyph of Evaporation
	[113991] = "德拉諾之霸", -- Iron Trap
	[116374] = "德拉諾之霸", -- Beast Battle-Training Stone
	[116416] = "德拉諾之霸", -- Humanoid Battle-Training Stone
	[116417] = "德拉諾之霸", -- Mechanical Battle-Training Stone
	[116418] = "德拉諾之霸", -- Critter Battle-Training Stone
	[116419] = "德拉諾之霸", -- Dragonkin Battle-Training Stone
	[116424] = "德拉諾之霸", -- Aquatic Battle-Training Stone
	[116420] = "德拉諾之霸", -- Elemental Battle-Training Stone
	[116421] = "德拉諾之霸", -- Flying Battle-Training Stone
	[116422] = "德拉諾之霸", -- Magic Battle-Training Stone
	[116423] = "德拉諾之霸", -- Undead Battle-Training Stone
	[116429] = "德拉諾之霸", -- Flawless Battle-Training Stone
	[122457] = "德拉諾之霸", -- Ultimate Battle-Training Stone
	[127768] = "軍臨天下", -- Fel Petal
	[138478] = "軍臨天下", -- Feast of Rib
	[138479] = "軍臨天下", -- Potato Stew Feast
	[141605] = "軍臨天下", -- Flight Master's Whistle
	[153123] = "軍臨天下", -- Cracked Radinax Control Gem
	[156724] = "決戰艾澤拉斯", -- Blue Crystal Monocle
	[156725] = "決戰艾澤拉斯", -- Red Crystal Monocle
	[156726] = "決戰艾澤拉斯", -- Yellow Crystal Monocle
	[156727] = "決戰艾澤拉斯", -- Green Crystal Monocle
	[163604] = "決戰艾澤拉斯", -- Net-o-Matic 5000
	[177223] = "暗影之境", -- Scorched Crypt Key
	[184652] = "暗影之境", -- Phantasmic Infuser
	[203708] = "巨龍崛起", -- Conch Whistle
	[210469] = "巨龍崛起", -- Personal Tabard
}

local function checkForItemOverride(item)
	for key, val in pairs(overrideTable) do
		if key == item then
			return val
		end
	end

	return nil
end

local function addCurrentSeasonLine(tooltip)
	if GetServerExpansionLevel() == 9 then
		tooltip:AddLine("巨龍崛起", 0, 1, 0.6)
	else
		tooltip:AddLine("地心之戰", 1, 0.4, 0)
	end
end

local function addColoredExpLine(name, tooltip)
	if name == "艾澤拉斯" then
		tooltip:AddLine(name, 1, 1, 1)
	elseif name == "燃燒的遠征" then
		tooltip:AddLine(name, 0, 1, 0)
	elseif name == "巫妖王之怒" then
		tooltip:AddLine(name, 0, 0.8, 1)
	elseif name == "浩劫與重生" then
		tooltip:AddLine(name, 0.8, 0.2, 0)
	elseif name == "潘達利亞之謎" then
		tooltip:AddLine(name, 0, 1, 0.6)
	elseif name == "德拉諾之霸" then
		tooltip:AddLine(name, 0.78, 0.61, 0.43)
	elseif name == "軍臨天下" then
		tooltip:AddLine(name, 0, 0.8, 0)
	elseif name == "決戰艾澤拉斯" then
		tooltip:AddLine(name, 0.20, 0.39, 0.67)
	elseif name == "暗影之境" then
		tooltip:AddLine(name, 0.6, 0.8, 1)
	elseif name == "巨龍崛起" then
		tooltip:AddLine(name, 0, 1, 0.6)
	elseif name == "地心之戰" then
		tooltip:AddLine(name, 1, 0.4, 0)
	elseif name == "當前賽季" then
    		-- Blizz seems to have added a Current Season tag in 10.2.7
    		-- to have the same behaviour as before the patch make it Dragonflight
    		addCurrentSeasonLine(tooltip)
	else
		print("缺少資料片: " .. name)
	end
end

local function BUII_TooltipImprovements_OnTooltipSetItem(tooltip, data)
	if enabled then
		if tooltip == GameTooltip or tooltip == ItemRefTooltip then
			local item = select(3, tooltip:GetItem())
			if item then
				local expansionID = select(15, C_Item.GetItemInfo(item))

				if expansionID then
					local expansionName = checkForItemOverride(item)

					if not expansionName then
						-- EJ_GetTierInfo needs expansionID + 1 to get the correct expansion
						expansionName = EJ_GetTierInfo(expansionID + 1)
					end

					addColoredExpLine(expansionName, tooltip)
				end
			end
		end
	end
end

function BUII_TooltipImprovements_Enabled()
	if enabled == nil then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, BUII_TooltipImprovements_OnTooltipSetItem)
		enabled = true
	end
end

function BUII_TooltipImprovements_Disable()
	enabled = false
end
