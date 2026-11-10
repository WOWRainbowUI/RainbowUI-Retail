local addonName, ns = ...
local CCS = ns.CCS

if CCS.CurrentVersion ~= CCS.FOREVER then -- CCS.MOP then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table
local module = {
    Name = "ClassicStatsFunc",
    CompatibleVersions = { CCS.ALL },
}

local BLOCK_VALUE_PER_STRENGTH = 20;
local ARMOR_PER_AGILITY = 2;
local BASE_ENEMY_MISS_CHANCE = 5.0;
local BASE_ENEMY_CRIT_CHANCE = 5.0;
local CRUSHING_BLOW_MIN_SKILL_DIFF = 15;
local SKILL_RANKS_PER_SKILL_LEVEL = 5;


local WEAPON_SUBCLASS_TO_SKILL_ID = {
	[Enum.ItemWeaponSubclass.Sword1H]	= 43,	-- Swords
	[Enum.ItemWeaponSubclass.Axe1H]		= 44,	-- Axes
	[Enum.ItemWeaponSubclass.Bows]		= 45,	-- Bows
	[Enum.ItemWeaponSubclass.Guns]		= 46,	-- Guns
	[Enum.ItemWeaponSubclass.Mace1H]	= 54,	-- Maces
	[Enum.ItemWeaponSubclass.Sword2H]	= 55,	-- Two-Handed Swords
	[Enum.ItemWeaponSubclass.Staff]		= 136,	-- Staves
	[Enum.ItemWeaponSubclass.Mace2H]	= 160,	-- Two-Handed Maces
	[Enum.ItemWeaponSubclass.Axe2H]		= 172,	-- Two-Handed Axes
	[Enum.ItemWeaponSubclass.Dagger]	= 173,	-- Daggers
	[Enum.ItemWeaponSubclass.Thrown]	= 176,	-- Thrown
	[Enum.ItemWeaponSubclass.Crossbow]	= 226,	-- Crossbows
	[Enum.ItemWeaponSubclass.Wand]		= 228,	-- Wands
	[Enum.ItemWeaponSubclass.Polearm]	= 229,	-- Polearms
	[Enum.ItemWeaponSubclass.Unarmed]	= 162,	-- Fist Weapons
};
local FERAL_WEAPON_SKILL = 3014;

local function PaperDollFrame_CalculateDPS(minDamage, maxDamage, speed)
	minDamage = minDamage or 0;
	maxDamage = maxDamage or 0;
	speed = speed or 1;

	return (minDamage + maxDamage) / (2.0 * speed);
end

local function GetEffectiveDefenseSkill(unit)
	local baseDefenseSkill, defenseModifier = UnitDefenseSkill(unit);
	return math.max(0, baseDefenseSkill + defenseModifier), baseDefenseSkill, defenseModifier;
end

-------------------------------------------------
-- BASE STATS - FOREVER
-------------------------------------------------
function CCS.GetStatPrimaryClassic(statIndex)
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil
	
	if statIndex == nil then return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable end
	
	local _, classFileName = UnitClass("player");
	local statName = CCS.PRIMARY_STAT_MAP[statIndex]

	local classStatText = _G[strupper(classFileName).."_"..strupper(statName).."_".."TOOLTIP"];
	local tmp_stat_name = {ITEM_MOD_STRENGTH_SHORT, ITEM_MOD_AGILITY_SHORT, ITEM_MOD_STAMINA_SHORT, ITEM_MOD_INTELLECT_SHORT, ITEM_MOD_SPIRIT_SHORT};
	local tmp_stat_value= 0
	local effectiveStat, posBuff, negBuff

	if ( not classStatText ) then
		classStatText = _G["DEFAULT".."_"..strupper(statName).."_".."TOOLTIP"];
	end

	tmp_stat_value, effectiveStat, posBuff, negBuff  = UnitStat("player", statIndex)
	tt_desc = classStatText

	if CCS.AreSecretsDisabled() then
		isZero = false
	else
		isZero = (tmp_stat_value == 0)
	end

	local targetValue = CCS.GetBlizzardStatValue(tmp_stat_name[statIndex])
	
	leftText=tmp_stat_name[statIndex]
	rightText=targetValue or BreakUpLargeNumbers(tmp_stat_value)
	
	local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);

	-- Strength
	if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
		if not CCS.AreSecretsDisabled() then
			tt_desc = string.format(classStatText, tmp_stat_value, math.floor(effectiveStat / BLOCK_VALUE_PER_STRENGTH));
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[statIndex]).." "..tt_name;
	-- Agility
	elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
		if not CCS.AreSecretsDisabled() then
			local increasedDodgeChance = GetDodgeChanceFromAttribute() * 100.0;
			local increasedArmor = effectiveStat * ARMOR_PER_AGILITY;
			local increasedMeleeCritChance = GetCritChanceFromStat(statIndex, effectiveStat) * 100.0;
			local increasedRangedCritChance = increasedMeleeCritChance;
			local increasedAttackPower = GetAttackPowerForStat(statIndex, effectiveStat);
			local increasedRangedAttackPower = GetRangedAttackPowerForStat(statIndex, effectiveStat);

			if classFileName == "ROGUE" then
				tt_desc = string.format(tt_desc, increasedMeleeCritChance, increasedAttackPower, increasedRangedAttackPower, increasedArmor, increasedDodgeChance);
			elseif classFileName == "HUNTER" then
				tt_desc = string.format(tt_desc, increasedRangedCritChance, increasedAttackPower, increasedRangedAttackPower, increasedArmor, increasedDodgeChance);
			elseif classFileName == "DRUID" then
				local catFormAgility = effectiveStat;
				tt_desc = string.format(tt_desc, increasedMeleeCritChance, catFormAgility, increasedArmor, increasedDodgeChance);
			elseif classFileName == "WARRIOR" then
				tt_desc = string.format(tt_desc, increasedRangedCritChance, increasedRangedAttackPower, increasedArmor, increasedDodgeChance);
			else
				tt_desc = string.format(tt_desc, increasedMeleeCritChance, increasedArmor, increasedDodgeChance);
			end	
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[statIndex]).." "..tt_name;

	-- Stamina
	elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
		if not CCS.AreSecretsDisabled() then
			local bonus = math.min(STAMINA_BREAK, effectiveStat);
			local perStaminaBonus = (math.max(STAMINA_BREAK, effectiveStat) - STAMINA_BREAK) * UnitHPPerStamina("player");
			bonus = bonus + perStaminaBonus;
			tt_desc = string.format(tt_desc, tostring(bonus));
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[statIndex]).." "..tt_name;

	-- Intellect
	elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
		if not CCS.AreSecretsDisabled() then		
			local spellCrit = GetSpellCritChanceFromStat(statIndex, effectiveStat) * 100.0;

			if classFileName == "WARRIOR" or classFileName == "ROGUE" then
				tt_desc = string.format(tt_desc, spellCrit);
			else
				local manaBonus = math.min(INTELLECT_BREAK, effectiveStat);
				manaBonus = manaBonus + (math.max(INTELLECT_BREAK, effectiveStat) - INTELLECT_BREAK) * MANA_PER_INTELLECT;

				tt_desc = string.format(tt_desc, tostring(manaBonus), spellCrit);
			end
		end
		
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[statIndex]).." "..tt_name;

	-- Spirit 
	elseif ( statIndex == LE_UNIT_STAT_SPIRIT ) then
		if not CCS.AreSecretsDisabled() then
			local spiritStandingPenalty = 0.75;
			local healthRegenFromSpirit = GetHealthRegenFromSpirit() * spiritStandingPenalty; -- Assume player is standing
			local manaRegenFromSpirit = GetManaRegenFromSpirit();

			local healthRegen = GetHealthRegen();
			local manaRegen = GetManaRegen();

			if classFileName == "WARRIOR" or classFileName == "ROGUE" then
				tt_desc = string.format(tt_desc, healthRegenFromSpirit * 5, healthRegen * 5);
			else
				tt_desc = string.format(tt_desc, healthRegenFromSpirit * 5, manaRegenFromSpirit * 5, healthRegen * 5, manaRegen * 5);
			end

			tt_desc = string.format("%s\n\n%s", tt_desc, SPIRIT_STANDING_WARNING);
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[statIndex]).." "..tt_name;

	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

-------------------------------------------------
-- ENHANCEMENTS - FOREVER
-------------------------------------------------
function CCS.GetStatCritForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local _, classFileName = UnitClass("player");
	local isRangedClass = classFileName == "WARRIOR" or classFileName == "HUNTER" or classFileName == "ROGUE";
	local critBonusTooltip = _G["STAT_" .. classFileName .. "_CRIT_BONUS"] or STAT_CRIT_BONUS;
	local spellCrit = GetSpellCritChance();
	local rangedCrit = GetRangedCritChance();
	local meleeCrit = GetCritChance();
	local critChance

	if isRangedClass then 
		critChance = rangedCrit 
	else
		critChance = spellCrit
	end

	leftText = STAT_CRITICAL_STRIKE
	rightText = format('%s%%', CCS.round(critChance))

	if not CCS.AreSecretsDisabled() then

		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2F%%", critChance)..FONT_COLOR_CODE_CLOSE;
		isZero = (critChance == 0)
		tt_desc = tt_desc .. format(STAT_CRIT_MELEE, meleeCrit) .. "\n"
	
		if isRangedClass then
			tt_desc = tt_desc .. format(STAT_CRIT_RANGED, rangedCrit) .. "\n"
		end

		tt_desc = tt_desc .. format(STAT_CRIT_SPELL, spellCrit) .. "\n"
		tt_desc = tt_desc .. format(critBonusTooltip) .. "\n"
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatHasteForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local targetValue = CCS.GetBlizzardStatValue(STAT_HASTE)

	local _, classFileName = UnitClass("player");
	local classType = CCS.ClassType()
	local hastevalue, maxHaste
	local meleeHaste = GetMeleeHaste();
	local baseRangedHaste, ammoHaste = GetRangedHaste();
	local spellHaste = UnitSpellHaste("player");

	local isRangedClass = classFileName == "WARRIOR" or classFileName == "HUNTER" or classFileName == "ROGUE";

	if not CCS.AreSecretsDisabled() then

		local rangedHaste = baseRangedHaste + ammoHaste;
		maxHaste = max(meleeHaste, rangedHaste, spellHaste);

		isZero = (maxHaste == 0)

		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE).." "..format("%.1F%%", maxHaste)..FONT_COLOR_CODE_CLOSE;

		tt_desc = function()
			if meleeHaste >= 0 then
				GameTooltip:AddLine(format(CR_HASTE_MELEE_TOOLTIP, meleeHaste), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
			end
			if rangedHaste >= 0 and isRangedClass then
				GameTooltip:AddLine(format(CR_HASTE_RANGED_TOOLTIP, rangedHaste), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
			end
			if spellHaste >= 0 then
				GameTooltip:AddLine(format(CR_HASTE_SPELL_TOOLTIP, spellHaste), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
			end
		end

	end
	
	leftText = STAT_HASTE
	if not CCS.AreSecretsDisabled() then
		rightText = targetValue or format('%s%%', CCS.round(maxHaste))
	else
		rightText = targetValue or format('%s%%', CCS.round(0))
	end

		
	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatArmorPenetrationForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local targetValue = CCS.GetBlizzardStatValue(STAT_ARMOR_PENETRATION)
	if targetValue == nil and CCS.ClassType() == "CASTER" then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local armorPenetration = GetArmorPenetration();

	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ARMOR_PENETRATION).." "..format("%d", armorPenetration)..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(ARMOR_PENETRATION_TOOLTIP, armorPenetration);
	
	leftText = STAT_ARMOR_PENETRATION
	rightText = targetValue or format('%s', armorPenetration)
	
	if not CCS.AreSecretsDisabled() then
		isZero = (armorPenetration == 0)
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end


-------------------------------------------------
-- ATTACK - FOREVER
-------------------------------------------------
function CCS.GetStatAttackPowerForever(rangedWeapon)
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local base, posBuff, negBuff;
	local _, classFileName = UnitClass("player");

	local extraFormatNumber;
	local tag, tooltip;

	-- Since we cannot do calculations due to "secrets", we will just steal the information directly from Blizzard's frame.
	local targetValue

	if ( rangedWeapon == true) then
		base, posBuff, negBuff = UnitRangedAttackPower("player");
		tag, tooltip = RANGED_ATTACK_POWER, RANGED_ATTACK_POWER_TOOLTIP;

		targetValue = CCS.GetBlizzardStatValue(RANGED_ATTACK_POWER)
	else
		base, posBuff, negBuff = UnitAttackPower("player");
		tag, tooltip = MELEE_ATTACK_POWER, _G[classFileName.."_MELEE_ATTACK_POWER_TOOLTIP"] or MELEE_ATTACK_POWER_TOOLTIP;
		targetValue = CCS.GetBlizzardStatValue(STAT_ATTACK_POWER)		
	end

	local label = rangedWeapon and RANGED_ATTACK_POWER or STAT_ATTACK_POWER;
			
	if not CCS.AreSecretsDisabled() then
		local damageBonus =  BreakUpLargeNumbers(max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
		local spellPower = 0;
		local value, valueText, tooltipText;
		
		if (GetOverrideAPBySpellPower() > 0) then
			local holySchool = 2;
			spellPower = GetSpellBonusDamage(holySchool);
			for i=(holySchool+1), MAX_SPELL_SCHOOLS do
				spellPower = min(spellPower, GetSpellBonusDamage(i));
			end
			spellPower = min(spellPower, GetSpellBonusHealing()) * GetOverrideAPBySpellPower();

			value = spellPower;
			valueText, tooltipText = PaperDollFormatStat(tag, spellPower, 0, 0);
			damageBonus = BreakUpLargeNumbers(spellPower / ATTACK_POWER_MAGIC_NUMBER);
		else
			value = base;
			valueText, tooltipText = PaperDollFormatStat(tag, base, posBuff, negBuff);
		end

		tt_name = tooltipText;

		local effectiveAP = max(0,base + posBuff + negBuff);
		if (GetOverrideSpellPowerByAP() > 0 ) then
			tt_desc = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5));
		else
			tt_desc  = format(tooltip, damageBonus, extraFormatNumber);
		end

		isZero = (value == 0)
	end

	leftText = label
	rightText = targetValue or base

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatAttackSpeedForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed("player");

	local displaySpeed = format("%.2F", speed);
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2F", offhandSpeed);
	end
	if ( offhandSpeed ) then
		displaySpeed =  displaySpeed.." / ".. offhandSpeed
	end

	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));

	leftText = WEAPON_SPEED
	rightText = format('%s', CCS.round(speed))
	if not CCS.AreSecretsDisabled() then
		isZero = (speed == 0)
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatEnergyRegenForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,false
	local link = nil	

	local powerType, powerToken = UnitPowerType("player");
	
	if (powerToken == "ENERGY") then
		local regenRate = GetPowerRegen();
		local regenRateText = BreakUpLargeNumbers(regenRate);
		
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		tt_desc = STAT_ENERGY_REGEN_TOOLTIP;

		leftText = STAT_ENERGY_REGEN
		rightText = format('%s', CCS.round(regenRate))
		isZero = (regenRate == 0)
		isApplicable = true
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatMainhandDamageForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	
	
	local displayName = INVTYPE_WEAPONMAINHAND;
	local targetValue = CCS.GetBlizzardStatValue(INVTYPE_WEAPONMAINHAND)
	local valueString, displayMin, displayMax, damageTooltip, speed, dps_string

	if not CCS.AreSecretsDisabled() then
		valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage("player", UnitDamage, INVTYPE_WEAPONMAINHAND);
		dps_string = string.format("%.1f", PaperDollFrame_CalculateDPS(displayMin, displayMax, speed));

		-- Main hand weapon
		local tooltipLabel = INVTYPE_WEAPONMAINHAND;
		tt_name = INVTYPE_WEAPONMAINHAND
		
		local OHvalueString, OHdisplayMin, OHdisplayMax, OHdamageTooltip, OHspeed, OHdps

		if IsDualWielding() and OHvalueString ~= nil then
			OHvalueString, OHdisplayMin, OHdisplayMax, OHdamageTooltip, OHspeed = PaperDollFrame_GetDamage("player", UnitDamage, INVTYPE_WEAPONOFFHAND);
			OHdps = string.format("%.1f", PaperDollFrame_CalculateDPS(OHdisplayMin, OHdisplayMax, OHspeed));

		end
		
		tt_desc = function()
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", speed or 1.5), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), damageTooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, STAT_DPS_SHORT), dps_string, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

			-- Check for offhand weapon
			if IsDualWielding() and OHvalueString ~= nil then
				GameTooltip:AddLine("\n");
				GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", OHspeed or 1.5), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), OHvalueString, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				GameTooltip:AddDoubleLine(format(STAT_FORMAT, STAT_DPS_SHORT), OHdps, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

			end

		end
		isZero = (displayMax == 0)
		
	end
	
	leftText = displayName
	rightText = targetValue or valueString


	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatOffhandDamageForever() 
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	if not IsDualWielding() then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end
	
	local targetValue = CCS.GetBlizzardStatValue(INVTYPE_WEAPONOFFHAND)
	local valueString, displayMin, displayMax, damageTooltip, speed, dps_string
	
	if not CCS.AreSecretsDisabled() then
		valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage("player", UnitDamage, INVTYPE_WEAPONOFFHAND);
		dps_string = string.format("%.1f", PaperDollFrame_CalculateDPS(displayMin, displayMax, speed));

		tt_name = INVTYPE_WEAPONOFFHAND

		tt_desc = function()
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", speed or 1.5), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), damageTooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, STAT_DPS_SHORT), dps_string, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end	
		isZero = (displayMax == 0)
	end

	leftText = INVTYPE_WEAPONOFFHAND
	rightText = targetValue or valueString

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end
 
function CCS.GetStatRangedDamageForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	if not IsRangedWeapon() then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end
	local targetValue = CCS.GetBlizzardStatValue(INVTYPE_RANGED)
	local valueString, displayMin, displayMax, damageTooltip, speed, dps_string
	
	if not CCS.AreSecretsDisabled() then
		valueString, displayMin, displayMax, damageTooltip, speed = PaperDollFrame_GetDamage("player", CCS.GetRangedDamage, INVTYPE_RANGED);
		dps_string = string.format("%.1f", PaperDollFrame_CalculateDPS(displayMin, displayMax, speed));

		tt_name = INVTYPE_RANGED
		tt_desc = function()
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", speed or 1.5), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), damageTooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			GameTooltip:AddDoubleLine(format(STAT_FORMAT, STAT_DPS_SHORT), dps_string, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end	
		isZero = (displayMax == 0)
	end

	leftText = INVTYPE_RANGED
	rightText = targetValue or valueString

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatExpertiseForever() 
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local targetValue = CCS.GetBlizzardStatValue(STAT_EXPERTISE)
	
	if targetValue == nil and CCS.ClassType() == "CASTER" then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local expertise, offhandExpertise, rangedExpertise = GetExpertise();
	local maxExpertise
	local _, classFileName = UnitClass("player");
	
	if classFileName == "HUNTER" then 
		maxExpertise = rangedExpertise
	else
		maxExpertise = expertise
	end

	if not CCS.AreSecretsDisabled() then
		maxExpertise = max(expertise, offhandExpertise, rangedExpertise);
		expertise = format("%.1F%%", expertise);
		offhandExpertise = format("%.1F%%", offhandExpertise);
		rangedExpertise = format("%.1F%%", rangedExpertise);

		local expertiseDisplay;
		if (IsDualWielding()) then
			expertiseDisplay = expertise.." / "..offhandExpertise;
		else
			expertiseDisplay = expertise;
		end

		tt_name = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["COMBAT_RATING_NAME"..CR_EXPERTISE]).." "..expertiseDisplay;

		local expertiseTooltip = (category == "MELEE") and CR_EXPERTISE_TOOLTIP or CR_RANGED_EXPERTISE_TOOLTIP;
		tt_desc = format(expertiseTooltip, expertiseDisplay)

		isZero = (maxExpertise == 0)
	end

	leftText = STAT_EXPERTISE
	rightText = targetValue or format('%s%%', CCS.round(maxExpertise))

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatHitChanceForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local targetValue = CCS.GetBlizzardStatValue(STAT_HIT_CHANCE)
	local meleeHit, rangedHit, spellHit;
	local maxHit
	
	if not CCS.AreSecretsDisabled() then 

		meleeHit = GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier();
		rangedHit = GetCombatRatingBonus(CR_HIT_RANGED) + GetRangedHitModifier();
		spellHit = GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier();
	
		maxHit = max(meleeHit, rangedHit, spellHit);

		tt_name = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..format("%.1F%%", maxHit)

		tt_desc = function()
			local meleeMissChances = { 5.0, 5.2, 5.4, 9.0 };
			local spellMissChances = { 4.0, 5.0, 6.0, 17.0 };
			local playerLevel = UnitLevel("player");
			local _, classFileName = UnitClass("player");
			local usesRangedHit = classFileName == "WARRIOR" or classFileName == "HUNTER" or classFileName == "ROGUE";

			if meleeHit > 0 then
				GameTooltip:AddLine(format(CR_HIT_MELEE_TOOLTIP, meleeHit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
			end
			if rangedHit > 0 and usesRangedHit then
				GameTooltip:AddLine(format(CR_HIT_RANGED_TOOLTIP, rangedHit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
			end
			if spellHit > 0 then
				GameTooltip:AddLine(format(CR_HIT_SPELL_TOOLTIP, spellHit), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, false);
			end

			local hitCapTooltip = _G["CR_" .. classFileName .. "_HIT_CAP_TOOLTIP"] or CR_DEFAULT_HIT_CAP_TOOLTIP;

			GameTooltip:AddLine(format(hitCapTooltip, playerLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
		isZero = (maxHit == 0)
	end
	
	leftText = STAT_HIT_CHANCE
	if not CCS.AreSecretsDisabled() then
		rightText = targetValue or format('%s%%', CCS.round(maxHit))
	else
		rightText = targetValue or format('%s%%', CCS.round(0))
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

-------------------------------------------------
-- SPELL - FOREVER
-------------------------------------------------

function CCS.GetStatSpellPowerForever() 
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	if not CCS.ClassType() == "CASTER" then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local _, className = UnitClass("player");
	local targetValue = CCS.GetBlizzardStatValue(STAT_SPELLPOWER)
	
	if targetValue == nil and CCS.ClassType() ~= "CASTER" then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local holySchool = 2; 	-- Start at 2 to skip physical damage
	local minModifier = GetSpellBonusDamage(holySchool);
	local maxModifier = 0;
	local bonusDamage = {}

	if not CCS.AreSecretsDisabled() then
		bonusDamage[holySchool] = minModifier;

		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			local schoolBonusDamage = GetSpellBonusDamage(i);
			minModifier = min(minModifier, schoolBonusDamage);
			maxModifier = max(maxModifier, schoolBonusDamage);
			bonusDamage[i] = schoolBonusDamage;
		end
	
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELLPOWER).." "..BreakUpLargeNumbers(minModifier)..FONT_COLOR_CODE_CLOSE
		tt_desc = function()

			GameTooltip:AddLine(string.format(STAT_SPELLPOWER_TOOLTIP, maxModifier), nil, nil, nil, true );
			GameTooltip:AddLine("\n", nil, nil, nil, true );
			
			for i=2, MAX_SPELL_SCHOOLS do
					GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["DAMAGE_SCHOOL"..i]).." "..bonusDamage[i]..FONT_COLOR_CODE_CLOSE, nil, nil, nil, true );
					GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
			end

			if className == "WARLOCK" then
				GameTooltip:AddLine("\n", nil, nil, nil, true );
				GameTooltip:AddLine(string.format(STAT_SPELLPOWER_PET_TOOLTIP, maxModifier), nil, nil, nil, true );

				local petStr, damage;
				if (bonusDamage[6] == minModifier and bonusDamage[3] == minModifier) then
					petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG;
					damage = minModifier;
				elseif( bonusDamage[6] > bonusDamage[3] ) then
					petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_SHADOW;
					damage = bonusDamage[6];
				else
					petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_FIRE;
					damage = bonusDamage[3];
				end

				local petBonusAP = math.floor(ComputePetBonus("PET_BONUS_SPELLDMG_TO_AP", damage ));
				local petBonusDmg = math.floor(ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", damage ));
				if( petBonusAP > 0 or petBonusDmg > 0 ) then
					GameTooltip:AddLine(format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, true );
				end
			end
		end
		
		isZero = (minModifier == 0)
	end

	leftText = STAT_SPELLPOWER
	rightText = targetValue or format('%s', minModifier)

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatSpellHealingForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	if CCS.ClassType() ~= "CASTER" then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local bonusHealing = GetSpellBonusHealing();

	tt_name = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELLHEALING).." "..BreakUpLargeNumbers(bonusHealing)
	tt_desc = string.format(STAT_SPELLHEALING_TOOLTIP, bonusHealing);

	leftText = STAT_SPELLHEALING
	rightText = format('%s', BreakUpLargeNumbers(bonusHealing))
	
	if not CCS.AreSecretsDisabled() then
		isZero = (bonusHealing == 0)
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatHealthRegenForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local base, combat = GetHealthRegen()
	-- All mana regen stats are displayed as mana/5 sec.
	base = floor(base * 5.0);
	combat = floor(combat * 5.0);
	
	local baseText = BreakUpLargeNumbers(base);
	local combatText = BreakUpLargeNumbers(combat);
	
		tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ITEM_MOD_HEALTH_REGENERATION_SHORT) .. FONT_COLOR_CODE_CLOSE;
	-- Base (out of combat) regen is displayed only in the subtext of the tooltip
	tt_desc = tt_desc.."\n" .. format(ITEM_MOD_HEALTH_REGEN, baseText) .. "\n"
	tt_desc = tt_desc.."\n" .. COMBAT..": "..format(ITEM_MOD_HEALTH_REGEN, combatText) .. "\n"

	leftText = L["HP Regen"] or "HP Regen"
	rightText = format('%s / %s', combatText, baseText)
	isZero = (base == 0)

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatManaRegenForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	if ( UnitPowerMax("player", Enum.PowerType.Mana) <= 0 ) then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local base, combat = GetManaRegenFromSpirit() --GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	base = floor(base * 5.0);
	combat = floor(combat * 5.0);
	
	local baseText = BreakUpLargeNumbers(base);
	local combatText = BreakUpLargeNumbers(combat);
	
	-- Combat mana regen is most important to the player, so we display it as the main value

	leftText = MANA_REGEN

	if not CCS.AreSecretsDisabled() then
		base, combat = GetManaRegen();

		base = floor(base * 5.0);
		combat = floor(combat * 5.0);

		baseText = BreakUpLargeNumbers(base);
		combatText = BreakUpLargeNumbers(combat);
		
		rightText = format('%s / %s', combatText, baseText)
		isZero = (base == 0)
	else
		rightText =  format('%s / %s', combatText, baseText)
	
	end

	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MANA_REGEN) .. FONT_COLOR_CODE_CLOSE;
	-- Base (out of combat) regen is displayed only in the subtext of the tooltip
	tt_desc = tt_desc.."\n" .. baseText.." "..ITEM_MOD_MANA_REGENERATION_SHORT.."\n"
	tt_desc = tt_desc.."\n" .. format(MANA_REGEN_FROM_SPIRIT, combatText) .. "\n"

	
	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatSpellPenetrationForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	-- Since we cannot do calculations due to "secrets", we will just steal the information directly from Blizzard's frame.
	local targetValue = CCS.GetBlizzardStatValue(STAT_SPELL_PENETRATION)
	if targetValue == nil and CCS.ClassType() ~= "CASTER" then
		isApplicable = false
		return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
	end

	local _, className = UnitClass("player");
	local spellPen = GetSpellPenetration();

	leftText = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELL_PENETRATION)
	rightText = targetValue or spellPen or 0

	if not CCS.AreSecretsDisabled() then
		local resistanceAverage = GetSpellPenetration() * 0.75 / (UnitLevel("player") * 5);
		local negativeResistanceAverage = resistanceAverage / 2.0;

		tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPELL_PENETRATION .. " " .. spellPen) .. FONT_COLOR_CODE_CLOSE;
		tt_desc = string.format(SPELL_PENETRATION_TOOLTIP, spellPen, resistanceAverage, negativeResistanceAverage);

		isZero = (spellPen == 0)
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

-------------------------------------------------
-- DEFENSE - FOREVER
-------------------------------------------------
function CCS.GetStatDefenseForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	-- Since we cannot do calculations due to "secrets", we will just steal the information directly from Blizzard's frame.
	local targetValue = CCS.GetBlizzardStatValue(DEFENSE)

	if not CCS.AreSecretsDisabled() then
		-- As long as we are not in a secret state, we can actually do something useful.
		local maxDefense = UnitLevel("player") * SKILL_RANKS_PER_SKILL_LEVEL;
		local STAT_PER_DEFENSE = 0.04;
		local effectiveDefenseSkill, baseDefenseSkill, defenseModifier = GetEffectiveDefenseSkill("player");
		local posBuff = 0;
		local negBuff = 0;

		if ( defenseModifier > 0 ) then
			posBuff = defenseModifier;
		elseif ( defenseModifier < 0 ) then
			negBuff = defenseModifier;
		end

		local effectiveDefense = math.max(effectiveDefenseSkill - maxDefense, 0);

		local valueText, tooltipText = PaperDollFormatStat(DEFENSE, baseDefenseSkill, posBuff, negBuff);
		tt_name = tooltipText;
		tt_desc = format(DEFAULT_STATDEFENSE_TOOLTIP, effectiveDefense * STAT_PER_DEFENSE, effectiveDefense * STAT_PER_DEFENSE);
		isZero = (effectiveDefenseSkill == 0)
	end
	
	leftText = DEFENSE
	--rightText = format('%s', valueText .. " / " .. maxDefense)
	rightText = targetValue

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatArmorForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local targetValue = CCS.GetBlizzardStatValue(STAT_ARMOR)

	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor("player");

	if not CCS.AreSecretsDisabled() then
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel("player"));
		local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..BreakUpLargeNumbers(effectiveArmor)..FONT_COLOR_CODE_CLOSE;
		tt_desc = format(STAT_ARMOR_TOOLTIP, armorReduction);

		if (armorReductionAgainstTarget) then
			tt_desc = tt_desc .. format(STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget);
		end
		
		tt_desc = tt_desc .. format(ARMOR_MAX_EFFECTIVENESS_TOOLTIP);
		isZero = (effectiveArmor == 0)
	end
	
	leftText = STAT_ARMOR
	rightText = targetValue or format('%s', effectiveArmor)


	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatDodgeForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local chance = GetDodgeChance();

	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.1F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_DODGE_BASE_STAT_TOOLTIP, chance);

	leftText = STAT_DODGE
	rightText = format('%s%%', CCS.round(chance))
	
	if not CCS.AreSecretsDisabled() then
		isZero = (chance == 0)
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatParryForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local chance = GetParryChance();
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.1F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_PARRY_BASE_STAT_TOOLTIP, chance);

	leftText = STAT_PARRY
	rightText = format('%s%%', CCS.round(chance))

	if not CCS.AreSecretsDisabled() then
		isZero = (chance == 0)
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

function CCS.GetStatBlockForever()
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	

	local chance = GetBlockChance();
	local shieldBlockValue = GetShieldBlock();

	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.1F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = STAT_BLOCK_VALUE_FLAT_TOOLTIP:format(chance, shieldBlockValue);

	leftText = STAT_BLOCK
	rightText = format('%s%%', CCS.round(chance))
	if not CCS.AreSecretsDisabled() then
		isZero = (chance == 0)
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end

-------------------------------------------------
-- RESISTANCES - FOREVER
-------------------------------------------------
function CCS.GetResistance(resistType)
	local leftText, rightText, tt_name, tt_desc, isZero, isApplicable = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false,true
	local link = nil	
	local baseResistance, realResistance, effectiveResistance, bonusResistance = UnitResistance("player", resistType);
	local nameToken =  _G["DAMAGE_SCHOOL"..(resistType+1)];
	local resistName = _G["RESISTANCE"..(resistType).."_NAME"];
	local unitLevel = UnitLevel("player");
	local expectedResist = ExpectedSpellResistance(unitLevel, effectiveResistance);
	

	leftText = nameToken
	rightText = format('%s', effectiveResistance)
	
	if not CCS.AreSecretsDisabled() then	
		tt_name = HIGHLIGHT_FONT_COLOR_CODE .. resistName.." "..effectiveResistance .. FONT_COLOR_CODE_CLOSE;
		tt_desc = format(RESISTANCE_TOOLTIP_SUBTEXT, _G["RESISTANCE_TYPE"..resistType], unitLevel, math.floor(expectedResist * 100));

		isZero = (effectiveResistance == 0)
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero, isApplicable
end