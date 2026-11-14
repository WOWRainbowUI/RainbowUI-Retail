local ResourcePolicy = {}
local RestrictedValue = MikSBT.API.RestrictedValue
local ARCANE_MAGE = 62
local BREWMASTER_MONK, WINDWALKER_MONK, MISTWEAVER_MONK = 268, 269, 270
local CAT_FORM_ID, BEAR_FORM_ID, DIRE_BEAR_FORM_ID, MOONKIN_FORM_ID = 1, 5, 8, 31
local POWER_TOKENS = {
	[0] = "MANA", [1] = "RAGE", [2] = "FOCUS", [3] = "ENERGY",
	[6] = "RUNIC_POWER", [8] = "LUNAR_POWER", [11] = "MAELSTROM",
	[13] = "INSANITY", [17] = "FURY", [18] = "PAIN",
}
local RESOURCES = {
	MANA = { MANA = true },
	RAGE = { RAGE = true },
	FOCUS = { FOCUS = true },
	ENERGY = { ENERGY = true },
	LUNAR_POWER = { LUNAR_POWER = true },
	INSANITY = { INSANITY = true },
	MAELSTROM = { MAELSTROM = true },
	FURY = { FURY = true },
	PAIN = { PAIN = true },
	CAT = { ENERGY = true, COMBO_POINTS = true },
	ARCANE = { MANA = true, ARCANE_CHARGES = true },
	WARLOCK = { MANA = true, SOUL_SHARDS = true },
	PALADIN = { MANA = true, HOLY_POWER = true },
	WINDWALKER = { ENERGY = true, CHI = true },
	DEATHKNIGHT = { RUNES = true, RUNIC_POWER = true },
	EVOKER = { MANA = true, ESSENCE = true },
}
-- Broader class-only fallbacks are used when form/spec context is unreadable.
local CLASS_RESOURCES = {
	WARRIOR = RESOURCES.RAGE,
	ROGUE = RESOURCES.CAT,
	HUNTER = { MANA = true, FOCUS = true },
	MAGE = RESOURCES.MANA,
	WARLOCK = RESOURCES.WARLOCK,
	PRIEST = { MANA = true, INSANITY = true },
	PALADIN = RESOURCES.PALADIN,
	SHAMAN = { MANA = true, MAELSTROM = true },
	MONK = { MANA = true, ENERGY = true },
	DEATHKNIGHT = RESOURCES.DEATHKNIGHT,
	DEMONHUNTER = { FURY = true, PAIN = true },
	EVOKER = RESOURCES.EVOKER,
	DRUID = {
		MANA = true, ENERGY = true, COMBO_POINTS = true,
		RAGE = true, LUNAR_POWER = true,
	},
}

local function PrimaryPower()
	if type(UnitPowerType) ~= "function" then return end
	local ok, power, token = pcall(UnitPowerType, "player")
	if not ok then return end
	local name = RestrictedValue:String(token)
	return name or POWER_TOKENS[RestrictedValue:Number(power)]
end

local function SpecializationID()
	local api = C_SpecializationInfo or {}
	local getSpec = api.GetSpecialization or GetSpecialization
	local getInfo = api.GetSpecializationInfo or GetSpecializationInfo
	if type(getSpec) ~= "function" or type(getInfo) ~= "function" then return end
	local ok, index = pcall(getSpec)
	index = ok and RestrictedValue:Number(index)
	if not index or index < 1 then return end
	local infoOK, id = pcall(getInfo, index)
	id = infoOK and RestrictedValue:Number(id)
	if id and id > 0 then return id end
end

local function DruidResources(primary)
	if type(GetShapeshiftFormID) == "function" then
		local ok, form = pcall(GetShapeshiftFormID)
		if ok and RestrictedValue:CanAccess(form) then
			if form == nil or form == 0 then return RESOURCES.MANA end
			if form == CAT_FORM_ID then return RESOURCES.CAT end
			if form == BEAR_FORM_ID or form == DIRE_BEAR_FORM_ID then
				return RESOURCES.RAGE
			end
			if form == MOONKIN_FORM_ID then return RESOURCES.LUNAR_POWER end
			-- Travel, aquatic, flight, and tree forms use the mana policy.
			if type(form) == "number" then return RESOURCES.MANA end
		end
	end
	if primary == "ENERGY" then return RESOURCES.CAT end
	if primary == "MANA" or primary == "RAGE" or primary == "LUNAR_POWER" then
		return RESOURCES[primary]
	end
	return CLASS_RESOURCES.DRUID
end

function ResourcePolicy:Allowed()
	if type(UnitClass) ~= "function" then return end
	local ok, _, class = pcall(UnitClass, "player")
	class = ok and RestrictedValue:String(class)
	local fallback = class and CLASS_RESOURCES[class]
	if not fallback then return end
	local primary = PrimaryPower()
	local client = MikSBT.Compatibility and MikSBT.Compatibility.Client or {}
	local usesVanillaResources = client.isForever or client.isVanillaContent
	if class == "DRUID" then return DruidResources(primary) end
	if class == "MAGE" then
		local spec = SpecializationID()
		if usesVanillaResources or spec ~= ARCANE_MAGE then
			return RESOURCES.MANA
		end
		return RESOURCES.ARCANE
	end
	if class == "WARLOCK" or class == "PALADIN" then
		return usesVanillaResources and RESOURCES.MANA or fallback
	end
	if class == "MONK" then
		local spec = SpecializationID()
		if spec == BREWMASTER_MONK then return RESOURCES.ENERGY end
		if spec == WINDWALKER_MONK then return RESOURCES.WINDWALKER end
		if spec == MISTWEAVER_MONK or primary == "MANA" then
			return RESOURCES.MANA
		end
		if primary == "ENERGY" then return RESOURCES.ENERGY end
	end
	if class == "HUNTER" or class == "PRIEST" or class == "SHAMAN"
		or class == "DEMONHUNTER" then
		if primary and fallback[primary] then return RESOURCES[primary] end
	end
	return fallback
end

MikSBT.Configuration.ResourcePolicy = ResourcePolicy
return ResourcePolicy
