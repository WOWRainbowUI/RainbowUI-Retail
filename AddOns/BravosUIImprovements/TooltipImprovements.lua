local enabled = nil

-- Several items are wrongly reported as Classic items, use
-- this table to correct them
local overrideTable = {
	[23500] = "Burning Crusade", -- Saltheril's Haven Party Invitation
	[31404] = "Burning Crusade", -- Green Trophy Tabard of the Illidari
	[31405] = "Burning Crusade", -- Purple Trophy Tabard of the Illidari
	[31774] = "Burning Crusade", -- Kurenai Tabard
	[31780] = "Burning Crusade", -- Scryers Tabard
	[31804] = "Burning Crusade", -- Cenarion Expedition Tabard
	[32445] = "Burning Crusade", -- Skyguard Tabard
	[32572] = "Burning Crusade", -- Apexis Crystal
	[33292] = "Burning Crusade", -- Hallowed Helm
	[35221] = "Burning Crusade", -- Tabard of the Shattered Sun
	[36941] = "Burning Crusade", -- Competitor's Tabard
	[37863] = "Burning Crusade", -- Direbrew's Remote
	[38682] = "Wrath of the Lich King", -- Enchanting Vellum
	[40643] = "Wrath of the Lich King", -- Tabard of the Achiever
	[43345] = "Wrath of the Lich King", -- Dragon Hide Bag
	[43348] = "Wrath of the Lich King", -- Tabard of the Explorer
	[43349] = "Wrath of the Lich King", -- Tabard of Brute Force
	[43876] = "Wrath of the Lich King", -- A Guide to Northern Cloth Scavenging
	[45574] = "Wrath of the Lich King", -- Stormwind Tabard
	[45577] = "Wrath of the Lich King", -- Ironforge Tabard
	[45578] = "Wrath of the Lich King", -- Gnomeregan Tabard
	[45579] = "Wrath of the Lich King", -- Darnassus Tabard
	[45580] = "Wrath of the Lich King", -- Exodar Tabard
	[45798] = "Wrath of the Lich King", -- Heroic Celestial Planetarium Key
	[45858] = "Wrath of the Lich King", -- Nat's Lucky Fishing Pole
	[52723] = "Cataclysm", -- Runed Elementium Rod
	[64398] = "Cataclysm", -- Standard of Unity
	[64882] = "Cataclysm", -- Gilneas Tabard
	[69748] = "Cataclysm", -- Tattered Hexcloth Bag
	[71083] = "Cataclysm", -- Darkmoon Game Token
	[71634] = "Cataclysm", -- Darkmoon Adventurer's Guide
	[71638] = "Cataclysm", -- Ornate Weapon
	[81055] = "Mists of Pandaria", -- Darkmoon Ride Ticket
	[86566] = "Mists of Pandaria", -- Forager's Gloves
	[89795] = "Mists of Pandaria", -- Lorewalkers Tabard
	[89880] = "Mists of Pandaria", -- Dented Shovel
	[89911] = "Mists of Pandaria", -- Alliance Firework
	[103533] = "Mists of Pandaria", -- Vicious Saddle
	[104105] = "Mists of Pandaria", -- Glyph of Evaporation
	[113991] = "Warlords of Draenor", -- Iron Trap
	[116374] = "Warlords of Draenor", -- Beast Battle-Training Stone
	[116416] = "Warlords of Draenor", -- Humanoid Battle-Training Stone
	[116417] = "Warlords of Draenor", -- Mechanical Battle-Training Stone
	[116418] = "Warlords of Draenor", -- Critter Battle-Training Stone
	[116419] = "Warlords of Draenor", -- Dragonkin Battle-Training Stone
	[116424] = "Warlords of Draenor", -- Aquatic Battle-Training Stone
	[116420] = "Warlords of Draenor", -- Elemental Battle-Training Stone
	[116421] = "Warlords of Draenor", -- Flying Battle-Training Stone
	[116422] = "Warlords of Draenor", -- Magic Battle-Training Stone
	[116423] = "Warlords of Draenor", -- Undead Battle-Training Stone
	[116429] = "Warlords of Draenor", -- Flawless Battle-Training Stone
	[122457] = "Warlords of Draenor", -- Ultimate Battle-Training Stone
	[127768] = "Legion", -- Fel Petal
	[138478] = "Legion", -- Feast of Rib
	[138479] = "Legion", -- Potato Stew Feast
	[141605] = "Legion", -- Flight Master's Whistle
	[153123] = "Legion", -- Cracked Radinax Control Gem
	[156724] = "Battle for Azeroth", -- Blue Crystal Monocle
	[156725] = "Battle for Azeroth", -- Red Crystal Monocle
	[156726] = "Battle for Azeroth", -- Yellow Crystal Monocle
	[156727] = "Battle for Azeroth", -- Green Crystal Monocle
	[163604] = "Battle for Azeroth", -- Net-o-Matic 5000
	[177223] = "Shadowlands", -- Scorched Crypt Key
	[184652] = "Shadowlands", -- Phantasmic Infuser
	[203708] = "Dragonflight", -- Conch Whistle
	[210469] = "Dragonflight", -- Personal Tabard
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
		tooltip:AddLine("Dragonflight", 0, 1, 0.6)
	else
		tooltip:AddLine("The War Within", 1, 0.4, 0)
	end
end

local function addColoredExpLine(name, tooltip)
	if name == "Classic" then
		tooltip:AddLine(name, 1, 1, 1)
	elseif name == "Burning Crusade" then
		tooltip:AddLine(name, 0, 1, 0)
	elseif name == "Wrath of the Lich King" then
		tooltip:AddLine(name, 0, 0.8, 1)
	elseif name == "Cataclysm" then
		tooltip:AddLine(name, 0.8, 0.2, 0)
	elseif name == "Mists of Pandaria" then
		tooltip:AddLine(name, 0, 1, 0.6)
	elseif name == "Warlords of Draenor" then
		tooltip:AddLine(name, 0.78, 0.61, 0.43)
	elseif name == "Legion" then
		tooltip:AddLine(name, 0, 0.8, 0)
	elseif name == "Battle for Azeroth" then
		tooltip:AddLine(name, 0.20, 0.39, 0.67)
	elseif name == "Shadowlands" then
		tooltip:AddLine(name, 0.6, 0.8, 1)
	elseif name == "Dragonflight" then
		tooltip:AddLine(name, 0, 1, 0.6)
	elseif name == "The War Within" then
		tooltip:AddLine(name, 1, 0.4, 0)
	elseif name == "Current Season" then
    		-- Blizz seems to have added a Current Season tag in 10.2.7
    		-- to have the same behaviour as before the patch make it Dragonflight
    		addCurrentSeasonLine(tooltip)
	else
		print("Missing expansion: " .. name)
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
