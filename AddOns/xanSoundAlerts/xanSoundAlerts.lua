--Simple addon that plays a sound if health and or mana is low, based on predefined threshold levels

local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		if event == "ADDON_LOADED" then
			local arg1 = ...
			if arg1 and arg1 == ADDON_NAME then
				self:UnregisterEvent("ADDON_LOADED")
				self:RegisterEvent("PLAYER_LOGIN")
			end
			return
		end
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if self[event] then
		return self[event](self, event, ...)
	end
end)

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

--only play the sound once during low health/mana then reset
local lowHealth = false
local lowMana = true

--edit these to your liking
local lowHealthThreshold = 0.35 --set the percentage threshold for low health
local lowManaThreshold = 0.35 --set the percentage threshold for low mana
local lowOtherThreshold = 0.35 --set the percentage threshold

----------------------
--      Enable      --
----------------------

addon.allowedOtherTypes = {
	["RAGE"] = true,
	["FOCUS"] = true,
	["ENERGY"] = true,
	["RUNIC_POWER"] = true,
	["LUNAR_POWER"] = true,
	["MAELSTROM"] = true,
	["FURY"] = true,
	["PAIN"] = true,
}

addon.powerTypes = {
	["MANA"] = 0,
	["RAGE"] = 1,
	["FOCUS"] = 2,
	["ENERGY"] = 3,
	["RUNIC_POWER"] = 6,
	["LUNAR_POWER"] = 8,
	["MAELSTROM"] = 11,
	["FURY"] = 17,
	["PAIN"] = 18,
}

addon.soundAlertSwitch = {
	["MANA"] = false,
	["RAGE"] = false,
	["FOCUS"] = false,
	["ENERGY"] = false,
	["RUNIC_POWER"] = false,
	["LUNAR_POWER"] = false,
	["MAELSTROM"] = false,
	["FURY"] = false,
	["PAIN"] = false,
}

addon.orderIndex = {
	[1] = "ENERGY",
	[2] = "FOCUS",
	[3] = "FURY",
	[4] = "LUNAR_POWER",
	[5] = "MAELSTROM",
	[6] = "PAIN",
	[7] = "RAGE",
	[8] = "RUNIC_POWER",
}

function addon:EnableAddon()

	if not XanSA_DB then XanSA_DB = {} end
	if XanSA_DB.allowHealth == nil then XanSA_DB.allowHealth = true end
	if XanSA_DB.allowMana == nil then XanSA_DB.allowMana = true end

	for k, v in pairs(addon.allowedOtherTypes) do
		if not XanSA_DB["allow"..k] then XanSA_DB["allow"..k] = false end
	end

	--have a short delay when logging in to prevent Mana and Health alerts firing prematurely
	C_Timer.After(5, function()
		addon:RegisterEvent("UNIT_HEALTH")
		addon:RegisterEvent("UNIT_POWER_UPDATE")
	end)

	SLASH_XANSOUNDALERTS1 = "/xsa";
	SlashCmdList["XANSOUNDALERTS"] = function()
		if not IsRetail and InterfaceOptionsFrame then
			InterfaceOptionsFrame:Show() --has to be here to load the about frame onLoad
		end
		InterfaceOptionsFrame_OpenToCategory(addon.aboutPanel) --force the panel to show
	end

	if addon.configFrame then addon.configFrame:EnableConfig() end

	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xsa", ADDON_NAME, ver or "1.0"))
end

function addon:UNIT_HEALTH()
	if not XanSA_DB or not XanSA_DB.allowHealth then return end
	if ((UnitHealth("player") / UnitHealthMax("player")) <= lowHealthThreshold) then
		if (not lowHealth) then
			PlaySoundFile("Interface\\AddOns\\xanSoundAlerts\\sounds\\LowHealth.ogg", "Master")
			lowHealth = true
		end
	else
		lowHealth = false
	end
end

--https://wowpedia.fandom.com/wiki/Enum.PowerType
-- SPELL_POWER_MANA            0       "MANA"
-- SPELL_POWER_RAGE            1       "RAGE"
-- SPELL_POWER_FOCUS           2       "FOCUS"
-- SPELL_POWER_ENERGY          3       "ENERGY"
-- SPELL_POWER_COMBO_POINTS    4       "COMBO_POINTS"
-- SPELL_POWER_RUNES           5       "RUNES"
-- SPELL_POWER_RUNIC_POWER     6       "RUNIC_POWER"
-- SPELL_POWER_SOUL_SHARDS     7       "SOUL_SHARDS"
-- SPELL_POWER_LUNAR_POWER     8       "LUNAR_POWER"
-- SPELL_POWER_HOLY_POWER      9       "HOLY_POWER"
-- SPELL_POWER_ALTERNATE_POWER 10      ???
-- SPELL_POWER_MAELSTROM       11      "MAELSTROM"
-- SPELL_POWER_CHI             12      "CHI"
-- SPELL_POWER_INSANITY        13      "INSANITY"
-- SPELL_POWER_OBSOLETE        14      ???
-- SPELL_POWER_OBSOLETE2       15      ???
-- SPELL_POWER_ARCANE_CHARGES  16      "ARCANE_CHARGES"
-- SPELL_POWER_FURY            17      "FURY"
-- SPELL_POWER_PAIN            18      "PAIN"
-- 19	Essence	Added in 10.0.0
-- 20	RuneBlood	Added in 10.0.0
-- 21	RuneFrost	Added in 10.0.0
-- 22	RuneUnholy	Added in 10.0.0

-- local powerTypeToStringLookup =
-- {
	-- [Enum.PowerType.Mana] = MANA,
	-- [Enum.PowerType.Rage] = RAGE,
	-- [Enum.PowerType.Focus] = FOCUS,
	-- [Enum.PowerType.Energy] = ENERGY,
	-- [Enum.PowerType.ComboPoints] = COMBO_POINTS,
	-- [Enum.PowerType.Runes] = RUNES,
	-- [Enum.PowerType.RunicPower] = RUNIC_POWER,
	-- [Enum.PowerType.SoulShards] = SOUL_SHARDS,
	-- [Enum.PowerType.LunarPower] = LUNAR_POWER,
	-- [Enum.PowerType.HolyPower] = HOLY_POWER,
	-- [Enum.PowerType.Maelstrom] = MAELSTROM_POWER,
	-- [Enum.PowerType.Chi] = CHI_POWER,
	-- [Enum.PowerType.Insanity] = INSANITY_POWER,
	-- [Enum.PowerType.ArcaneCharges] = ARCANE_CHARGES_POWER,
	-- [Enum.PowerType.Fury] = FURY,
	-- [Enum.PowerType.Pain] = PAIN,
	-- [Enum.PowerType.Essence] = POWER_TYPE_ESSENCE,
-- };

function addon:UNIT_POWER_UPDATE(event, unit, powerType)
	if not XanSA_DB then return end
	if unit ~= "player" then return end

	if XanSA_DB.allowMana and powerType == "MANA" then
		if ((UnitPower("player", addon.powerTypes[powerType]) / UnitPowerMax("player", addon.powerTypes[powerType])) <= lowManaThreshold) then
			if (not addon.soundAlertSwitch[powerType]) then
				PlaySoundFile("Interface\\AddOns\\xanSoundAlerts\\sounds\\LowMana.ogg", "Master")
				addon.soundAlertSwitch[powerType] = true
				return
			end
		else
			addon.soundAlertSwitch[powerType] = false
		end
	end

	if IsRetail then
		if not powerType or not addon.allowedOtherTypes[powerType] then return end

		if XanSA_DB["allow"..powerType] and UnitPower("player", addon.powerTypes[powerType]) > 0 then
			if ((UnitPower("player", addon.powerTypes[powerType]) / UnitPowerMax("player", addon.powerTypes[powerType])) <= lowOtherThreshold) then
				if (not addon.soundAlertSwitch[powerType]) then
					PlaySoundFile("Interface\\AddOns\\xanSoundAlerts\\sounds\\LowMana.ogg", "Master")
					addon.soundAlertSwitch[powerType] = true
					return
				end
			else
				addon.soundAlertSwitch[powerType] = false
			end
		end
	end
end
