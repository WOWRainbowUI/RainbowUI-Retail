local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_random = _G.math.random
local s_lower = _G.string.lower
local s_split = _G.string.split
local tonumber = _G.tonumber

-- Mine
local ROLL_TEMPLATE = "%s|A:lootroll-icon-%s:0:0:0:0|a"

local rollTypes = {
	[1] = "need",
	[2] = "greed",
	[3] = "disenchant",
	[4] = "transmog",
}

local function Toast_OnClick(self)
	if self._data.link and IsModifiedClick("DRESSUP") then
		DressUpLink(self._data.link)
	elseif self._data.item_id then
		local slot = SearchBagsForItem(self._data.item_id)
		if slot >= 0 then
			OpenBag(slot)
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		if self._data.tooltip_link:find("item") then
			GameTooltip:SetHyperlink(self._data.tooltip_link)
			GameTooltip:Show()
		elseif self._data.tooltip_link:find("battlepet") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed = s_split(":", self._data.tooltip_link)
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
		end
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or value)
end

local function Toast_SetUp(event, link, quantity, factionGroup, lessAwesome, isUpgraded, baseQuality, isLegendary, isAzerite, isCorrupted, rollType, roll)
	if link then
		local sanitizedLink, originalLink, _, itemID = E:SanitizeLink(link)
		local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)
		if isNew then
			local name, _, quality, _, _, _, _, _, equipLoc, icon, _, classID, subClassID, _, expansionID = C_Item.GetItemInfo(originalLink)
			local isLegacyEquipment = ((equipLoc and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE") or (classID == 3 and subClassID == 11))
				and (expansionID or 0) < GetExpansionLevel() -- legacy gear and relics

			if not name
			or not (quality and quality >= C.db.profile.types.loot_special.threshold and quality <= 5)
			or (isLegacyEquipment and not C.db.profile.types.loot_special.legacy_equipment) then
				toast:Release()

				return
			end

			local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
			local title = L["YOU_RECEIVED"]
			local soundFile = 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
			local bgTexture

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if lessAwesome then
				soundFile = 51402 -- SOUNDKIT.UI_RAID_LOOT_TOAST_LESSER_ITEM_WON
			elseif isUpgraded then
				if baseQuality and baseQuality < quality then
					title = L["ITEM_UPGRADED_FORMAT"]:format(color.hex, _G["ITEM_QUALITY" .. quality .. "_DESC"])
				else
					title = L["ITEM_UPGRADED"]
				end

				soundFile = 51561 -- SOUNDKIT.UI_WARFORGED_ITEM_LOOT_TOAST
				bgTexture = "upgrade"

				local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]

				for i = 1, 5 do
					toast["Arrow" .. i]:SetAtlas(upgradeTexture.arrow, true)
				end
			elseif isLegendary then
				title = L["ITEM_LEGENDARY"]
				soundFile = 63971 -- SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
				bgTexture = "legendary"

				if not toast.Dragon.isHidden then
					toast.Dragon:Show()
				end
			elseif isAzerite then
				title = L["ITEM_AZERITE_EMPOWERED"]
				soundFile = 118238 -- SOUNDKIT.UI_AZERITE_EMPOWERED_ITEM_LOOT_TOAST
				bgTexture = "azerite"
			elseif isCorrupted then
				title = L["ITEM_CORRUPTED"]
				soundFile = 147833 -- SOUNDKIT.UI_CORRUPTED_ITEM_LOOT_TOAST
			end

			if rollType then
				rollType = rollTypes[rollType]
				if rollType then
					toast.IconText3:SetFormattedText(ROLL_TEMPLATE, roll, rollType)
					toast.IconText3BG:Show()
				end
			end

			if factionGroup then
				bgTexture = s_lower(factionGroup)
			end

			if quality >= C.db.profile.colors.threshold then
				if C.db.profile.colors.name then
					name = color.hex .. name .. "|r"
				end

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end
			end

			if C.db.profile.types.loot_special.ilvl then
				local iLevel = E:GetItemLevel(originalLink)

				if iLevel > 0 then
					name = "[" .. color.hex .. iLevel .. "|r] " .. name
				end
			end

			if bgTexture then
				toast:SetBackground(bgTexture)
			end

			toast.Title:SetText(title)
			toast.Text:SetText(name)
			toast.Icon:SetTexture(icon)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
			toast._data.event = event
			toast._data.item_id = itemID
			toast._data.link = sanitizedLink
			toast._data.show_arrows = isUpgraded
			toast._data.sound_file = C.db.profile.types.loot_special.sfx and soundFile
			toast._data.tooltip_link = originalLink

			if C.db.profile.types.loot_special.tooltip then
				toast:HookScript("OnEnter", Toast_OnEnter)
			end

			toast:HookScript("OnClick", Toast_OnClick)
			toast:Spawn(C.db.profile.types.loot_special.anchor, C.db.profile.types.loot_special.dnd)
		else
			toast._data.count = toast._data.count + quantity

			if isQueued then
				toast.IconText1:SetAnimatedValue(toast._data.count, true)
			else
				toast.IconText1:SetAnimatedValue(toast._data.count)

				toast.IconText2:SetText("+" .. quantity)
				toast.IconText2.Blink:Stop()
				toast.IconText2.Blink:Play()

				toast.AnimOut:Stop()
				toast.AnimOut:Play()
			end
		end
	end
end

local function AZERITE_EMPOWERED_ITEM_LOOTED(link)
	Toast_SetUp("AZERITE_EMPOWERED_ITEM_LOOTED", link, 1, nil, nil, nil, nil, nil, nil, true)
end

local function LOOT_ITEM_ROLL_WON(link, quantity, rollType, roll, isUpgraded)
	Toast_SetUp("LOOT_ITEM_ROLL_WON", link, quantity, nil, nil, isUpgraded, nil, nil, nil, nil, rollType, roll)
end

local function SHOW_LOOT_TOAST(typeID, link, quantity, _, _, _, _, lessAwesome, isUpgraded, isCorrupted)
	if typeID == "item" then
		Toast_SetUp("SHOW_LOOT_TOAST", link, quantity, nil, lessAwesome, isUpgraded, nil, nil, nil, isCorrupted)
	end
end

local function SHOW_LOOT_TOAST_UPGRADE(link, quantity, _, _, baseQuality)
	Toast_SetUp("SHOW_LOOT_TOAST_UPGRADE", link, quantity, nil, nil, true, baseQuality)
end

local function SHOW_PVP_FACTION_LOOT_TOAST(typeID, link, quantity, _, _, _, lessAwesome)
	if typeID == "item" then
		local factionGroup = UnitFactionGroup("player")
		factionGroup = factionGroup ~= "Neutral" and factionGroup or nil

		Toast_SetUp("SHOW_PVP_FACTION_LOOT_TOAST", link, quantity, factionGroup, lessAwesome)
	end
end

local function SHOW_RATED_PVP_REWARD_TOAST(typeID, link, quantity, _, _, _, lessAwesome)
	if typeID == "item" then
		local factionGroup = UnitFactionGroup("player")
		factionGroup = factionGroup ~= "Neutral" and factionGroup or nil

		Toast_SetUp("SHOW_RATED_PVP_REWARD_TOAST", link, quantity, factionGroup, lessAwesome)
	end
end

local function SHOW_LOOT_TOAST_LEGENDARY_LOOTED(link)
	Toast_SetUp("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", link, 1, nil, nil, nil, nil, true)
end

local function BonusRollFrame_FinishedFading_Disabled(self)
	GroupLootContainer_RemoveFrame(GroupLootContainer, self:GetParent())
end

local function BonusRollFrame_FinishedFading_Enabled(self)
	local frame = self:GetParent()
	if frame.rewardType == "item" then
		Toast_SetUp("LOOT_ITEM_BONUS_ROLL_WON", frame.rewardLink, frame.rewardQuantity)
	end

	GroupLootContainer_RemoveFrame(GroupLootContainer, frame)
end

local function Enable()
	if C.db.profile.types.loot_special.enabled then
		E:RegisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED", AZERITE_EMPOWERED_ITEM_LOOTED)
		E:RegisterEvent("LOOT_ITEM_ROLL_WON", LOOT_ITEM_ROLL_WON)
		E:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", SHOW_LOOT_TOAST_LEGENDARY_LOOTED)
		E:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE", SHOW_LOOT_TOAST_UPGRADE)
		E:RegisterEvent("SHOW_LOOT_TOAST", SHOW_LOOT_TOAST)
		E:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST", SHOW_PVP_FACTION_LOOT_TOAST)
		E:RegisterEvent("SHOW_RATED_PVP_REWARD_TOAST", SHOW_RATED_PVP_REWARD_TOAST)

		BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Enabled)
	else
		BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
	end
end

local function Disable()
	E:UnregisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED", AZERITE_EMPOWERED_ITEM_LOOTED)
	E:UnregisterEvent("LOOT_ITEM_ROLL_WON", LOOT_ITEM_ROLL_WON)
	E:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", SHOW_LOOT_TOAST_LEGENDARY_LOOTED)
	E:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE", SHOW_LOOT_TOAST_UPGRADE)
	E:UnregisterEvent("SHOW_LOOT_TOAST", SHOW_LOOT_TOAST)
	E:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST", SHOW_PVP_FACTION_LOOT_TOAST)
	E:UnregisterEvent("SHOW_RATED_PVP_REWARD_TOAST", SHOW_RATED_PVP_REWARD_TOAST)

	BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
end

local function Test()
	local factionGroup = UnitFactionGroup("player")
	factionGroup = factionGroup ~= "Neutral" and factionGroup or "Horde"

	-- pvp, Fearless Gladiator's Dreadplate Girdle
	local _, link = C_Item.GetItemInfo(142679)
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, factionGroup)
	end

	-- titanforged, Bonespeaker Bracers
	_, link = C_Item.GetItemInfo("item:134222::::::::110:63::36:4:3432:41:1527:3337:::")
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, true)
	end

	-- upgraded from uncommon to epic, Nightsfall Brestplate
	_, link = C_Item.GetItemInfo("item:139055::::::::110:70::36:3:3432:1507:3336:::")
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, true, 2)
	end

	-- legendary, Aman'Thul's Vision
	_, link = C_Item.GetItemInfo("item:154172::::::::110:64:::1:3571:::")
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, nil, true)
	end

	-- heirloom, Tattered Dreadmist Mask
	_, link = C_Item.GetItemInfo("item:122250::::::::70:64:::::::::")
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, nil, true)
	end

	-- azerite, Vest of the Champion
	_, link = C_Item.GetItemInfo("item:159906::::::::110:581::11::::")
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, nil, nil, true)
	end

	-- corrupted, Devastation's Hour
	_, link = C_Item.GetItemInfo("item:172187::::::::20:71::3:1:3524:::")
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, nil, nil, nil, true)
	end

	-- roll, Rhinestone Sunglasses
	_, link = C_Item.GetItemInfo(52489)
	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, nil, nil, nil, nil, m_random(1, 4), m_random(1, 100))
	end
end

E:RegisterOptions("loot_special", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	tooltip = true,
	ilvl = true,
	legacy_equipment = true,
	threshold = 1,
}, {
	name = L["TYPE_LOOT_SPECIAL"],
	get = function(info)
		return C.db.profile.types.loot_special[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_special[info[#info]] = value
	end,
	args = {
		desc = {
			order = 1,
			type = "description",
			name = L["TYPE_LOOT_SPECIAL_DESC"],
		},
		enabled = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.loot_special.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
		},
		dnd = {
			order = 3,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		ilvl = {
			order = 5,
			type = "toggle",
			name = L["ILVL"],
		},
		threshold = {
			order = 6,
			type = "select",
			name = L["LOOT_THRESHOLD"],
			values = {
				[1] = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC .. "|r",
				[2] = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC .. "|r",
				[3] = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC .. "|r",
				[4] = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC .. "|r",
				[5] = ITEM_QUALITY_COLORS[5].hex .. ITEM_QUALITY5_DESC .. "|r",
			},
		},
		legacy_equipment = {
			order = 7,
			type = "toggle",
			name = L["LEGACY_EQUIPMENT"],
			desc = L["LEGACY_EQUIPMENT_DESC"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
	},
})

E:RegisterSystem("loot_special", Enable, Disable, Test)
