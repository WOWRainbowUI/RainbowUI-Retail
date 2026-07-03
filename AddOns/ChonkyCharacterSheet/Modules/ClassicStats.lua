local addonName, ns = ...
local CCS = ns.CCS

if CCS.CurrentVersion ~= CCS.MOP then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table
local module = {
    Name = "ClassicStats",
    CompatibleVersions = { CCS.MOP },
}

CCS.Modules[module.Name] = module

local rowWidth, rowHeight, rowSpacing = 234, 23, 2
local fontsize = 10

local function UpdateMoveSpeed() 
	if CCS.AreSecretsDisabled() then return end
	local rowFrame = _G["CCS_Row_general_movespeed"]

    if not rowFrame or not option("showcharacterstats") then return end
    
    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player");
    runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
    flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
    swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;
    currentSpeed = currentSpeed/BASE_MOVEMENT_SPEED*100;
    local speed = runSpeed;
    
    if (UnitInVehicle("player")) then
        local vehicleSpeed = GetUnitSpeed("Vehicle")/BASE_MOVEMENT_SPEED*100;
        speed = vehicleSpeed
    elseif IsSwimming("player") then speed = swimSpeed;
    elseif UnitOnTaxi("player") then speed = currentSpeed;
    elseif IsFlying("player") then speed = flightSpeed;
    end

	local speedtext = string.format("%.0f%%", speed)
    rowFrame.rightText:SetText(speedtext)

	return speedtext

end

function CCS:RestoreCharacterStatsPane()
    CharacterStatsPane.ItemLevelCategory:SetPoint("TOP", CharacterStatsPane, "TOP", -3, 2)
    CharacterStatsPane.ClassBackground:SetAlpha(1)

    -- Re-register default events
    CharacterStatsPane:RegisterUnitEvent("UNIT_STATS", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_RESISTANCES", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_ATTACK_POWER", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_RANGED_ATTACK_POWER", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_DAMAGE", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_AURA", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

    CharacterStatsPane:RegisterEvent("PLAYER_LEVEL_UP")
    CharacterStatsPane:RegisterEvent("PLAYER_ENTERING_WORLD")
    CharacterStatsPane:RegisterEvent("COMBAT_RATING_UPDATE")
    CharacterStatsPane:RegisterEvent("MASTERY_UPDATE")
    CharacterStatsPane:RegisterEvent("SPEED_UPDATE")
    CharacterStatsPane:RegisterEvent("LIFESTEAL_UPDATE")
    CharacterStatsPane:RegisterEvent("AVOIDANCE_UPDATE")
    CharacterStatsPane:RegisterEvent("PLAYER_TALENT_UPDATE")
    CharacterStatsPane:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    CharacterStatsPane:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
    CharacterStatsPane:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    CharacterStatsPane:RegisterEvent("UNIT_MODEL_CHANGED")
    if _G["CCS_stat_sf"] then _G["CCS_stat_sf"]:Hide() end
end

-------------------------------------------------
-- ATTRIBUTE STAT FUNCTIONS
-------------------------------------------------
local function GetStatPrimary(rowData) 
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local spec = GetSpecialization()
	local _, _, _, _, _, primaryStat = GetSpecializationInfo(spec)
	local role = GetSpecializationRole(spec);
	local tmp_stat_name = {ITEM_MOD_STRENGTH_SHORT, ITEM_MOD_AGILITY_SHORT, ITEM_MOD_STAMINA_SHORT, ITEM_MOD_INTELLECT_SHORT, ITEM_MOD_SPIRIT_SHORT};
	local tmp_stat_value= 0
	local statIndex
	local stat, effectiveStat, posBuff, negBuff
	
	if primaryStat == 1 then 
		tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", 1);
		tt_desc = DEFAULT_STAT1_TOOLTIP;
	elseif primaryStat == 2 then 
		tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", 2);
		tt_desc = DEFAULT_STAT2_TOOLTIP;
	else 
		tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", 4);
		tt_desc = DEFAULT_STAT4_TOOLTIP;
	end

	if CCS.AreSecretsDisabled() then
		isZero = false
	else
		isZero = (tmp_stat_value == 0)
	end
	
	leftText=tmp_stat_name[primaryStat]
	rightText=BreakUpLargeNumbers(tmp_stat_value)
	
	stat = tmp_stat_value;
	
	local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
	statIndex = primaryStat;
	-- Set the tooltip text
	
	local tooltipText = ""

	-- Strength
	if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
		local attackPower = tmp_stat_value --GetAttackPowerForStat(statIndex,tmp_stat_value);
		if (HasAPEffectsSpellPower()) then
			tt_desc = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
			tt_desc = format(tt_desc, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) and not CCS.AreSecretsDisabled() then
				local increasedParryChance = GetParryChanceFromAttribute();
				if ( increasedParryChance > 0 ) then
					tt_desc = tt_desc.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
				end
			end
		else
			tt_desc = STAT_NO_BENEFIT_TOOLTIP;
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[primaryStat]).." "..tt_name;
	-- Agility
	elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
		local attackPower = tmp_stat_value -- GetAttackPowerForStat(statIndex,tmp_stat_value);
		local tooltip4 = STAT_TOOLTIP_BONUS_AP;
		if (HasAPEffectsSpellPower()) then
			tooltip4 = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
			tt_desc = format(tooltip4, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) and not CCS.AreSecretsDisabled() then
				local increasedDodgeChance = GetDodgeChanceFromAttribute();
				if ( increasedDodgeChance > 0 ) then
					tt_desc = tt_desc.."|n|n"..format(CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
				end
			end
		else
			tt_desc = STAT_NO_BENEFIT_TOOLTIP;
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[primaryStat]).." "..tt_name;
	-- Intellect
	elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
		if ( CCS.UnitHasMana("player") ) then
			if (HasAPEffectsSpellPower()) then
				tt_desc = STAT_NO_BENEFIT_TOOLTIP;
			else
				local result, druid = HasSPEffectsAttackPower();
				if (result and druid) then
					tt_desc = format(STAT_TOOLTIP_SP_AP_DRUID, effectiveStat, effectiveStat);
				elseif (result) then
					tt_desc = format(STAT_TOOLTIP_BONUS_AP_SP, effectiveStat);
				elseif (not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT) then
					tt_desc = format(tt_desc, effectiveStat);
				else
					tt_desc = STAT_NO_BENEFIT_TOOLTIP;
				end
			end
		else
			tt_desc = STAT_NO_BENEFIT_TOOLTIP;
		end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, tmp_stat_name[primaryStat]).." "..tt_name;
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatStamina(rowData) 
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local statIndex = 3 -- Stamina
	local tmp_stat_value, effectiveStat = UnitStat("player", statIndex);

	leftText=format("%s", ITEM_MOD_STAMINA_SHORT)
	rightText=BreakUpLargeNumbers(tmp_stat_value)
	
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	local hpperstam = 20
	local maxhealthmod = 1
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;

	if not CCS.AreSecretsDisabled() then
		isZero = (tmp_stat_value == 0)
		tt_desc = tt_desc .. format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], BreakUpLargeNumbers(((effectiveStat*hpperstam))*maxhealthmod));                
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatHealth(rowData) 
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local health = UnitHealthMax("player");
	local healthText = BreakUpLargeNumbers(health);

	if not CCS.AreSecretsDisabled() then
		isZero = (health == 0)
	end

	leftText=HEALTH
	rightText=healthText
		
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
	tt_desc = STAT_HEALTH_TOOLTIP;

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatPower(rowData)
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local powerType, powerToken, altR, altG, altB = UnitPowerType("player")
	local power = UnitPowerMax("player") or 0;
	local powerText = BreakUpLargeNumbers(power);

	if not CCS.AreSecretsDisabled() then
		isZero = (power == 0)
	end

	leftText=CCS.POWER_TYPES_TABLE[powerType]
	rightText=powerText
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, (leftText or "")).." "..(powerText or "") .. FONT_COLOR_CODE_CLOSE;
	tt_desc = _G["STAT_"..(powerToken or "") .."_TOOLTIP"];
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatGCD(rowData)
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil

	if CCS.AreSecretsDisabled() then return leftText, rightText, tt_name, tt_desc, link, isZero end

	local gcd = max(0.75, 1.5 * 100 / (100+GetHaste()))
	local _, _, _, _, _, primaryStat = GetSpecializationInfo(GetSpecialization())
	local _, class = UnitClass("player")
	
	leftText = "GCD"
	
	if (class == "DRUID") then 
		if GetShapeshiftFormID() == 1 then gcd = 1 end
	elseif (primaryStat == LE_UNIT_STAT_INTELLECT) or (primaryStat == LE_UNIT_STAT_STRENGTH) or (class == "DEMONHUNTER") or (class == "HUNTER") or (class == "SHAMAN") then 
		gcd = gcd
	else gcd = 1
	end

	rightText = format("%.2fs", gcd)
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

-------------------------------------------------
-- SECONDARY STAT FUNCTIONS
-------------------------------------------------
local function GetStatCrit(rowData) 
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil	
	local extraCritChance = GetCombatRatingBonus(CR_CRIT_SPELL)
	local extraCritRating = GetCombatRating(CR_CRIT_SPELL)
	local prio = cachedPriorityLookup["CriticalStrike"]

	if not CCS.AreSecretsDisabled() then
		isZero = (extraCritRating == 0)
	end

	if option("show_secondarypriority") == true then
		leftText=prio.." "..ITEM_MOD_CRIT_RATING_SHORT
	else
		leftText=ITEM_MOD_CRIT_RATING_SHORT	
	end
	rightText=format('(%s%%) %6.6s',
		CCS.round(GetSpellCritChance('player')),
		BreakUpLargeNumbers(GetCombatRating(CR_CRIT_SPELL)))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE)..FONT_COLOR_CODE_CLOSE
	
	if GetCritChanceProvidesParryEffect() and not CCS.AreSecretsDisabled() then
		tt_desc = format(CR_CRIT_PARRY_RATING_TOOLTIP,
			BreakUpLargeNumbers(extraCritRating),
			extraCritChance,
			GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)) .. "\n\n"
	end

	tt_desc = tt_desc..format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance)

    local DRtable = GetStatDRInfo(CR_CRIT_SPELL)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	if option("show_stathighlights") then
		tt_desc = tt_desc.."\n\n".."|cffffffff("..L["STATS_TOGGLE"]..")|r"
	end
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatHaste(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil	
	local _, class = UnitClass("player")
	local prio = cachedPriorityLookup["Haste"]
	local hasteRating = GetCombatRating(CR_HASTE_SPELL)
	local hasteBonus = UnitSpellHaste('player')

	if not CCS.AreSecretsDisabled() then
		isZero = (hasteRating == 0)
	end

	if option("show_secondarypriority") == true then
		leftText=prio.." "..ITEM_MOD_HASTE_RATING_SHORT
	else
		leftText=ITEM_MOD_HASTE_RATING_SHORT	
	end	

	rightText=format('(%s%%) %6.6s',
		CCS.round(hasteBonus),
		BreakUpLargeNumbers(hasteRating))
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE)..FONT_COLOR_CODE_CLOSE

	tt_desc = _G["STAT_HASTE_"..class.."_TOOLTIP"] or STAT_HASTE_TOOLTIP
	tt_desc = tt_desc .. format(STAT_HASTE_BASE_TOOLTIP,
		BreakUpLargeNumbers(hasteRating),
		GetCombatRatingBonus(CR_HASTE_SPELL))
		
	local DRtable = GetStatDRInfo(CR_HASTE_SPELL)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	if option("show_stathighlights") then
		tt_desc = tt_desc.."\n\n".."|cffffffff("..L["STATS_TOGGLE"]..")|r"
	end
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatMastery(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local _, class = UnitClass("player")
	local mastery, bonusCoeff = GetMasteryEffect()
	local masteryRating = GetCombatRating(CR_MASTERY)
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY)
	local primaryTalentTree = GetSpecialization()
	local prio = cachedPriorityLookup["Mastery"]

	if not CCS.AreSecretsDisabled() then
		isZero = (masteryRating == 0)
		masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff
	end

	if option("show_secondarypriority") == true then
		leftText=prio.." "..ITEM_MOD_MASTERY_RATING_SHORT
	else
		leftText=ITEM_MOD_MASTERY_RATING_SHORT	
	end	

	rightText=format('(%s%%) %6.6s',
		CCS.round(GetMasteryEffect('player')),
		BreakUpLargeNumbers(masteryRating))

	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY)..FONT_COLOR_CODE_CLOSE

	if primaryTalentTree then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree)
		if masterySpell then
			tt_desc = (C_Spell.GetSpellDescription(masterySpell) or "\n")
		end
		if masterySpell2 then
			tt_desc = (tt_desc or "") .. "\n" .. (C_Spell.GetSpellDescription(masterySpell2) or "\n")
		end
		tt_desc = (tt_desc or "") .. "\n" .. format(STAT_MASTERY_TOOLTIP,
			BreakUpLargeNumbers(masteryRating),
			masteryBonus)
	else
		tt_desc = format(STAT_MASTERY_TOOLTIP,
			BreakUpLargeNumbers(masteryRating),
			masteryBonus) .. "\n" .. STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC
	end

	local DRtable = GetStatDRInfo(CR_MASTERY)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	if option("show_stathighlights") then
		tt_desc = tt_desc.."\n\n".."|cffffffff("..L["STATS_TOGGLE"]..")|r"
	end
	return leftText, rightText, tt_name, tt_desc, link, isZero
end
local function GetStatVersatility(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN)
	local prio = cachedPriorityLookup["Versatility"]

	if not CCS.AreSecretsDisabled() then
		isZero = (versatility == 0)
		versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
		versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
	end


	if option("show_secondarypriority") == true then
		leftText=prio.." "..STAT_VERSATILITY
	else
		leftText=STAT_VERSATILITY	
	end	

	if option("secondary_versatility_display") == "All" then
		rightText=format('(%s%% / %s%%) %6.6s',	CCS.round(versatilityDamageBonus),	CCS.round(versatilityDamageTakenReduction),	BreakUpLargeNumbers(versatility))
	elseif option("secondary_versatility_display") == "Damage/Healing" then
		rightText=format('(%s%%) %6.6s', CCS.round(versatilityDamageBonus),	BreakUpLargeNumbers(versatility))
	else
		rightText=format('(%s%%) %6.6s', CCS.round(versatilityDamageTakenReduction), BreakUpLargeNumbers(versatility))	
	end
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_VERSATILITY)..FONT_COLOR_CODE_CLOSE
	tt_desc = format(CR_VERSATILITY_TOOLTIP,
		versatilityDamageBonus,
		versatilityDamageTakenReduction,
		BreakUpLargeNumbers(versatility),
		versatilityDamageBonus,
		versatilityDamageTakenReduction)
		
	local DRtable = GetStatDRInfo(CR_VERSATILITY_DAMAGE_DONE)
	if DRtable ~= nil and option("show_diminishing_returns") == true then 
		tt_desc = tt_desc..format("\n   %s%s: %d [+%.2f%%/%.2f%%]|r", "|cff68ccef", L["STAT_DR_EFFECTIVE"] or "Effective",BreakUpLargeNumbers(DRtable.effectiveRating), DRtable.effectivePercent1, DRtable.effectivePercent2)
		tt_desc = tt_desc..format("\n   %s%s: %d [+%.2f%%/%.2f%%]|r", "|cffff5555", L["LOST"] or "Lost",BreakUpLargeNumbers(DRtable.ratingLost), DRtable.percentLost1, DRtable.percentLost2)
		tt_desc = tt_desc..format("\n   %s(%s)|r", "|cff9d9d9d", L["STAT_DR_LABEL"] or "After diminishing returns")

		-- bracket progress in rating
		local ratingPerPercent = 0

		if DRtable.rawPercent1 ~= 0 then
			ratingPerPercent = DRtable.rawRating / DRtable.rawPercent1
		end
		
		if DRtable.rawRating > 0 and ratingPerPercent < math.huge then
			local bracket = GetDRBracketProgress(DRtable.rawPercent1, ratingPerPercent)

			if bracket then
				tt_desc = tt_desc.."\n\n|cffffd100"..(L["Diminishing Returns Bracket"] or "Diminishing Returns Bracket").."|r"
				tt_desc = tt_desc..format("\n  %s%.2f%% – %.2f%%|r",
					"|cffbbbbbb", bracket.bracketStartPercent, bracket.bracketEndPercent)

				tt_desc = tt_desc..format("\n  %s%s: %d – %d|r",
					"|cffcccccc", L["Rating range"] or "Rating range",
					BreakUpLargeNumbers(bracket.bracketStartRating),
					BreakUpLargeNumbers(bracket.bracketEndRating))

				tt_desc = tt_desc..format("\n  %s%s: %d %s|r",
					"|cff00d100", L["Into bracket"] or "Into bracket", BreakUpLargeNumbers(bracket.ratingIntoBracket), L["rating"] or "rating")

				tt_desc = tt_desc..format("\n  %s%s: %d %s|r",
					"|cffffa040", L["Until next bracket"] or "Until next bracket", BreakUpLargeNumbers(bracket.ratingRemaining), L["rating"] or "rating")
			end
		end

		
	end                        
	if option("show_stathighlights") then
		tt_desc = tt_desc.."\n\n".."|cffffffff("..L["STATS_TOGGLE"]..")|r"
	end
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

-------------------------------------------------
-- ATTACK STAT FUNCTIONS
-------------------------------------------------
local function GetStatAttackPower(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil

	-- Attack Power
	local base, posBuff, negBuff;
	local tag, tooltip4;
	
	leftText = format("%s", STAT_ATTACK_POWER)
	
	if IsRangedWeapon() then 
		base, posBuff, negBuff = UnitRangedAttackPower("player");
		tag, tooltip4 = RANGED_ATTACK_POWER, RANGED_ATTACK_POWER_TOOLTIP;
	else
		base, posBuff, negBuff = UnitAttackPower("player");
		tag, tooltip4 = MELEE_ATTACK_POWER, MELEE_ATTACK_POWER_TOOLTIP;
	end


	rightText = BreakUpLargeNumbers(base)

	if not CCS.AreSecretsDisabled() then
		isZero = (base == 0)
	else
		return leftText, rightText, tt_name, tt_desc, link, isZero
	end
	
	local damageBonus =  BreakUpLargeNumbers(max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
	local spellPower = 0;
	local value, valueText, tooltipText;
	
	if (GetOverrideAPBySpellPower() ~= nil) then
		local holySchool = 2;
		-- Start at 2 to skip physical damage
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

	if (GetOverrideSpellPowerByAP() ~= nil) then
		tt_desc = format(MELEE_ATTACK_POWER_SPELL_POWER_TOOLTIP, damageBonus, BreakUpLargeNumbers(effectiveAP * GetOverrideSpellPowerByAP() + 0.5));
	else
		tt_desc = format(tooltip4, damageBonus);
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatAttackSpeed(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed("player");
	local displaySpeed = format("%.2fs", speed);

	if not CCS.AreSecretsDisabled() then
		isZero = (speed == 0)
	end
	
	if offhandSpeed then displaySpeed = format("%s / %.2fs", displaySpeed , offhandSpeed); end
	
	leftText = format("%s", STAT_ATTACK_SPEED)
	rightText = displaySpeed
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));	
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatSpellPower(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local spellPower = GetSpellBonusDamage(2)

	if not CCS.AreSecretsDisabled() then
		isZero = (spellPower == 0)
	end
	
	leftText = format("%s", ITEM_MOD_SPELL_POWER_SHORT)
	rightText = BreakUpLargeNumbers(spellPower)
	
	tt_name = STAT_SPELLPOWER;
	tt_desc = STAT_SPELLPOWER_TOOLTIP;
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

-------------------------------------------------
-- DEFENSE STAT FUNCTIONS
-------------------------------------------------
local function GetStatArmor(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor("player");
	local armorReduction = 0
	local armorReductionAgainstTarget = 0

	if not CCS.AreSecretsDisabled() then
		isZero = (effectiveArmor == 0)
		armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel("player"));
		armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

	end
	
	leftText=format("%s", ARMOR)
	rightText=BreakUpLargeNumbers(armor)
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..BreakUpLargeNumbers(effectiveArmor)..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(STAT_ARMOR_TOOLTIP, armorReduction);
	
	if (armorReductionAgainstTarget) then
		tt_desc = tt_desc .. "\n" .. format(STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget);
	end

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatDodge(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local chance = GetDodgeChance();

	if not CCS.AreSecretsDisabled() then
		isZero = (chance == 0)
	end
	
	leftText=format("%s", ITEM_MOD_DODGE_RATING_SHORT)
	rightText=format("%s%%", CCS.round(chance))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatParry(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local chance = GetParryChance();

	if not CCS.AreSecretsDisabled() then
		isZero = (chance == 0)
	end
	
	leftText=format("%s", ITEM_MOD_PARRY_RATING_SHORT)
	rightText=format("%s%%", CCS.round(chance))

	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatBlock(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local chance = GetBlockChance();
	local shieldBlockArmor = GetShieldBlock();
	local blockArmorReduction = 0
	local blockArmorReductionAgainstTarget = 0

	if not CCS.AreSecretsDisabled() then
		isZero = (chance == 0)
		blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel("player"));
		blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor);		
	end
	
	leftText=format("%s", BLOCK)
	rightText=format("%s%%", CCS.round(chance))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = CR_BLOCK_TOOLTIP:format(blockArmorReduction);
	if (blockArmorReductionAgainstTarget) then
		tt_desc = tt_desc .. "\n" .. format(STAT_BLOCK_TARGET_TOOLTIP, blockArmorReductionAgainstTarget);
	end                	
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatStagger(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage("player");

	if not CCS.AreSecretsDisabled() then
		isZero = (stagger == 0)
	end
	
	leftText=format("%s", STAGGER)
	rightText=format("%s%%", CCS.round(stagger))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAGGER).." "..string.format("%.2F%%",stagger)..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(STAT_STAGGER_TOOLTIP, stagger);

	if (staggerAgainstTarget) then
		tt_desc = tt_desc .. "\n" .. format(STAT_STAGGER_TARGET_TOOLTIP, staggerAgainstTarget);
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

-------------------------------------------------
-- GENERAL STAT FUNCTIONS
-------------------------------------------------
local function GetTotalDurabilityAndRepairCost()
    local totalCur, totalMax, totalCost = 0, 0, 0

    for slot = 1, 17 do
        -- Durability
        local cur, max = GetInventoryItemDurability(slot)
        if cur and max then
            totalCur = totalCur + cur
            totalMax = totalMax + max
        end

        -- Tooltip repair cost (only present in some contexts)
        local tip = C_TooltipInfo.GetInventoryItem("player", slot)
        if tip and tip.repairCost then
            totalCost = totalCost + tip.repairCost
        end
    end

    local percent = totalMax > 0 and (totalCur / totalMax) * 100 or 0
    return percent, totalCost
end

local function FormatRepairCost(cost)
    if not cost or cost <= 0 then
        return ""
    end

    local gold   = floor(cost / 10000)
    local silver = floor((cost % 10000) / 100)
    local copper = cost % 100

    local out = {}

    -- Gold: Blizzard gold color (|cffffd700)
    if gold > 0 then
        table.insert(out, string.format("|cffffd700%d|r|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:0:0|t", gold))
    end

    -- Silver: keep white (|cffffffff)
    if silver > 0 then
        table.insert(out, string.format("|cffffffff%d|r|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:0:0|t", silver))
    end

    -- Copper: copper color (|cffeda55f)
    if copper > 0 then
        table.insert(out, string.format("|cffeda55f%d|r|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:0:0|t", copper))
    end

    return table.concat(out, " ")
end

local function GetStatDurability(rowData)
    local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
    local link = nil

    local percent, totalCost = GetTotalDurabilityAndRepairCost()
	isZero = (percent == 100)

    leftText = DURABILITY
	if totalCost > 0 then
		rightText = string.format("(%.0f%%) : %s", percent, FormatRepairCost(totalCost))
	else
		rightText = string.format("(%.0f%%)", percent)
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatLeech(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local leechRating = GetCombatRating(CR_LIFESTEAL)
	local lifesteal = GetLifesteal();

	if not CCS.AreSecretsDisabled() then
		isZero = (lifesteal == 0)
	end
	
	leftText=format("%s", ITEM_MOD_CR_LIFESTEAL_SHORT)
	rightText=format('(%s%%) %6.6s',CCS.round(GetLifesteal()), BreakUpLargeNumbers(leechRating))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2F%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(leechRating), GetCombatRatingBonus(CR_LIFESTEAL));
	local DRtable = GetStatDRInfo(CR_LIFESTEAL)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatAvoidance(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local avoidance = GetAvoidance();
	local avoidRating = GetCombatRating(CR_AVOIDANCE)

	if not CCS.AreSecretsDisabled() then
		isZero = (avoidRating == 0)
	end
	
	leftText=format("%s", ITEM_MOD_CR_AVOIDANCE_SHORT)
	rightText=format('(%s%%) %6.6s',CCS.round(GetCombatRatingBonus(CR_AVOIDANCE)), BreakUpLargeNumbers(avoidRating))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2F%%", avoidance) .. FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(avoidRating), GetCombatRatingBonus(CR_AVOIDANCE));
	local DRtable = GetStatDRInfo(CR_AVOIDANCE)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatSpeed(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil
	local speedRating = GetCombatRating(CR_SPEED)
	local speed = GetSpeed();

	if not CCS.AreSecretsDisabled() then
		isZero = (speedRating == 0)
	end

	leftText=format("%s", ITEM_MOD_CR_SPEED_SHORT)
	rightText=format('(%s%%) %6.6s',CCS.round(GetCombatRatingBonus(CR_SPEED)), BreakUpLargeNumbers(speedRating))
	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED) .. " " .. format("%.2F%%", speed) .. FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(speedRating), GetCombatRatingBonus(CR_SPEED));
	local DRtable = GetStatDRInfo(CR_SPEED)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatMovespeed(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","|cffffd100<" .. L["Secret"] .. ">|r","","",false
	local link = nil

	leftText=format("%s", L["Movement"])

	if not CCS.AreSecretsDisabled() then
		rightText = UpdateMoveSpeed()
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

-------------------------------------------------
-- CURRENCY STAT FUNCTION (CRESTS + PVP)
-------------------------------------------------
CCS.CRESTS = {
    crests_myth = {
        { id = 3347, tocinfo = {120000, 120009} },
        { id = 3446, tocinfo = {120100, 120199} },
    },

    crests_hero = {
        { id = 3345, tocinfo = {120000, 120009} },
        { id = 3445, tocinfo = {120100, 120199} },
    },

    crests_champion = {
        { id = 3343, tocinfo = {120000, 120009} },
        { id = 3444, tocinfo = {120100, 120199} },
    },

    crests_veteran = {
        { id = 3341, tocinfo = {120000, 120009} },
        { id = 3443, tocinfo = {120100, 120199} },
    },

    crests_adventurer = {
        { id = 3383, tocinfo = {120000, 120009} },
        { id = 3442, tocinfo = {120100, 120199} },
    },

    crests_catalyst = {
        { id = 3378, tocinfo = {120000, 120009} },
        { id = 3465, tocinfo = {120100, 120199} },
    },

    crests_voidcore = {
        { id = 3418, tocinfo = {120000, 120009} },
        { id = 3418, tocinfo = {120100, 120199} }, -- same ID, new icon?
    },
}

local function GetCrestIDForRow(rowKey)
    local versions = CCS.CRESTS and CCS.CRESTS[rowKey]
    if not versions then
        return nil
    end

    local currentTOC = select(4, GetBuildInfo())
    local bestID = nil
    local bestMin = -1

    for idx, v in ipairs(versions) do
        local minTOC, maxTOC = v.tocinfo[1], v.tocinfo[2]
        minTOC = tonumber(minTOC)
        maxTOC = tonumber(maxTOC)

        if currentTOC >= minTOC and currentTOC <= maxTOC then
            if minTOC > bestMin then
                bestMin = minTOC
                bestID = v.id
            end
        end
    end

    return bestID
end


local function GetStatCurrency(rowData)
    local leftText, rightText, tt_name, tt_desc, isZero =
        "", "|cffffd100<" .. L["Secret"] .. ">|r", "", "", false
    local link = nil

    ---------------------------------------------------------
    -- Determine the correct currency ID
    ---------------------------------------------------------
    local id = rowData.id

    if id == -1 then
        id = GetCrestIDForRow(rowData.key)
        if not id then
            return rowData.name, "0", tt_name, tt_desc, nil, true
        end
    end

    ---------------------------------------------------------
    -- Fetch currency info
    ---------------------------------------------------------
    local currencyData
    if C_CurrencyInfo then
        currencyData = C_CurrencyInfo.GetCurrencyInfo(id)
        link = C_CurrencyInfo.GetCurrencyLink(id)
    else
        currencyData = GetCurrencyInfo(id)
        link = GetCurrencyLink(id)
    end

    if not currencyData then
        return rowData.name, "0", tt_name, tt_desc, nil, true
    end

    ---------------------------------------------------------
    -- Left text (label)
    ---------------------------------------------------------
    if id == 1586 or id == 1792 or id == 1602 then
        leftText = currencyData.name
    else
        leftText = rowData.name
    end

    ---------------------------------------------------------
    -- Right text (value formatting)
    ---------------------------------------------------------
    local qty = currencyData.quantity or 0
    local maxQty = currencyData.maxQuantity or 0
    local totalEarned = currencyData.totalEarned or 0

    if id == 1586 or id == 1602 or id == 2123 or id == 2797 then
        rightText = format("%8.8s", BreakUpLargeNumbers(qty))
    elseif id == 3008 or id == 1792 or id == 3378 then
        rightText = format("%s/%s",
            BreakUpLargeNumbers(qty),
            BreakUpLargeNumbers(maxQty))
    elseif maxQty == 0 then
        rightText = BreakUpLargeNumbers(qty)
    else
        rightText = format("%s (%s/%s)",
            BreakUpLargeNumbers(qty),
            BreakUpLargeNumbers(totalEarned),
            BreakUpLargeNumbers(maxQty))
    end

    return leftText, rightText, tt_name, tt_desc, link, isZero
end

local STAT_SECTIONS = {

    -------------------------------------------------
    -- ATTRIBUTES
    -------------------------------------------------
    {
        key         = "ATTRIBUTES",
        title       = L["Attributes"],
        showKey     = "show_attributes",
        collapseKey = "collapse_attributes",
        colorKey    = "attribute_color",
        color       = { r = 0.90, g = 0.70, b = 0.20 },

        rows = {
            { key="attribute_primary",   name=L["Primary Stat"]  or "Primary Stat",  id=10000, statFunc=GetStatPrimary, icon="Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\intellect.png" },
            { key="attribute_stamina",   name=L["Stamina"]       or "Stamina",       id=10000, statFunc=GetStatStamina, icon="Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\stamina.png" },
            { key="attribute_health",    name=L["Health"]        or "Health",        id=10000, statFunc=GetStatHealth, icon="Interface\\Icons\\inv_potion_54" },
            { key="attribute_power",     name=L["Power/Mana"]    or "Power/Mana",    id=10000, statFunc=GetStatPower, icon="Interface\\Icons\\inv_misc_gem_pearl_03" },
            { key="attribute_gcd",       name=L["GCD"]           or "GCD",           id=10000, statFunc=GetStatGCD, icon="Interface\\Icons\\inv_misc_pocketwatch_02.blp" },
        },
    },

    -------------------------------------------------
    -- SECONDARY
    -------------------------------------------------
    {
        key         = "SECONDARY",
        title       = L["Secondary"],
        showKey     = "show_secondary",
        collapseKey = "collapse_secondary",
        colorKey    = "secondary_stats_color",
        color       = { r = 0.40, g = 0.80, b = 0.40 },

        rows = {
            { key="secondary_crit",        name=L["Critical Strike"] or "Critical Strike", id=10000, statFunc=GetStatCrit, icon="Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\crit.png" },
            { key="secondary_haste",       name=L["Haste"]           or "Haste",           id=10000, statFunc=GetStatHaste, icon="Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\haste.png" },
            { key="secondary_mastery",     name=L["Mastery"]         or "Mastery",         id=10000, statFunc=GetStatMastery, icon="Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\mastery.png" },
            { key="secondary_versatility", name=L["Versatility"]     or "Versatility",     id=10000, statFunc=GetStatVersatility, icon="Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\versatility.png" },
        },
    },

    -------------------------------------------------
    -- ATTACK
    -------------------------------------------------
    {
        key         = "ATTACK",
        title       = L["Attack"],
        showKey     = "show_attack",
        collapseKey = "collapse_attack",
        colorKey    = "attack_stats_color",
        color       = { r = 0.80, g = 0.30, b = 0.30 },

        rows = {
            { key="attack_power", name=L["Attack Power"] or "Attack Power", id=10000, statFunc=GetStatAttackPower, icon="Interface\\Icons\\ability_warrior_offensivestance" },
            { key="attack_speed", name=L["Attack Speed"] or "Attack Speed", id=10000, statFunc=GetStatAttackSpeed, icon="Interface\\Icons\\inv_gauntlets_04" },
            { key="attack_spell", name=L["Spell Power"]  or "Spell Power",  id=10000, statFunc=GetStatSpellPower, icon="Interface\\Icons\\spell_fire_flamebolt" },
        },
    },

    -------------------------------------------------
    -- DEFENSE
    -------------------------------------------------
    {
        key         = "DEFENSE",
        title       = L["Defense"],
        showKey     = "show_defense",
        collapseKey = "collapse_defense",
        colorKey    = "defense_stats_color",
        color       = { r = 0.29, g = 0.46, b = 0.90 },

        rows = {
            { key="defense_armor",   name=L["Armor"]   or "Armor",   id=10000, statFunc=GetStatArmor, icon="Interface\\Icons\\inv_chest_chain" },
            { key="defense_dodge",   name=L["Dodge"]   or "Dodge",   id=10000, statFunc=GetStatDodge, icon="Interface\\Icons\\rogue_burstofspeed" },
            { key="defense_parry",   name=L["Parry"]   or "Parry",   id=10000, statFunc=GetStatParry, icon="Interface\\Icons\\ability_parry" },
            { key="defense_block",   name=L["Block"]   or "Block",   id=10000, statFunc=GetStatBlock, icon="Interface\\Icons\\ability_defend" },
            { key="defense_stagger", name=L["Stagger"] or "Stagger", id=10000, statFunc=GetStatStagger, icon="Interface\\Icons\\monk_stance_drunkenox" },
        },
    },

    -------------------------------------------------
    -- GENERAL
    -------------------------------------------------
    {
        key         = "GENERAL",
        title       = L["General"],
        showKey     = "show_general",
        collapseKey = "collapse_general",
        colorKey    = "general_color",
        color       = { r = 0.70, g = 0.70, b = 0.70 },

        rows = {
            { key="general_durability", name=L["Durability"]     or "Durability",     id=10000, statFunc=GetStatDurability, icon="Interface\\Cursor\\repairnpc" },
            { key="general_leech",      name=L["Leech"]          or "Leech",          id=10000, statFunc=GetStatLeech, icon="Interface\\Icons\\spell_shadow_lifedrain02" },
            { key="general_avoidance",  name=L["Avoidance"]      or "Avoidance",      id=10000, statFunc=GetStatAvoidance, icon="Interface\\Icons\\ability_rogue_quickrecovery" },
            { key="general_speed",      name=L["Speed"]          or "Speed",          id=10000, statFunc=GetStatSpeed, icon="Interface\\Icons\\ability_rogue_sprint" },
            { key="general_movespeed",  name=L["Movement Speed"] or "Movement Speed", id=10000, statFunc=GetStatMovespeed, icon="Interface\\Icons\\ability_mount_nightmarehorse" },
        },
    },

    -------------------------------------------------
    -- CRESTS
    -------------------------------------------------
    {
        key         = "CRESTS",
        title       = L["Crests"],
        showKey     = "show_crests",
        collapseKey = "collapse_crests",
        colorKey    = "crests_color",
        color       = { r = 0.85, g = 0.55, b = 1.00 },

        rows = {
         -- { key="crests_valorstone", name=L["Valorstones"] or "Valorstones", id=3008, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_valorstone_base" },
            { key="crests_myth",       name=L["Myth"]        or "Myth",        id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_myth" },
            { key="crests_hero",       name=L["Hero"]        or "Hero",        id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_hero" },
            { key="crests_champion",   name=L["Champion"]    or "Champion",    id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_champion" },
            { key="crests_veteran",    name=L["Veteran"]     or "Veteran",     id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_veteran" },
            { key="crests_adventurer", name=L["Adventurer"]  or "Adventurer",  id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_adventurer" },
            { key="crests_catalyst", name=L["Catalyst"]  or "Catalyst",  id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_adventurer" },
            { key="crests_voidcore", name=BONUS_LOOT_LABEL  or "Bonus Loot",  id=-1, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_adventurer" },
        },
    },

    -------------------------------------------------
    -- PVP
    -------------------------------------------------
    {
        key         = "PVP",
        title       = L["PvP"],
        showKey     = "show_pvp",
        collapseKey = "collapse_pvp",
        colorKey    = "pvp_color",
        color       = { r = 0.95, g = 0.25, b = 0.60 },

        rows = {
            { key="pvp_honorlevel", name=L["Honor Level"]     or "Honor Level",     id=1586, statFunc=GetStatCurrency, icon="Interface\\Icons\\achievement_legionpvptier1" },
            { key="pvp_honor", 		name=L["Honor"]     	  or "Honor",     		id=1792, statFunc=GetStatCurrency, icon="Interface\\Icons\\achievement_legionpvptier4" },
            { key="pvp_conquest",   name=L["Conquest"]        or "Conquest",        id=1602, statFunc=GetStatCurrency, icon="Interface\\Icons\\achievement_legionpvp2tier3" },
           -- { key="pvp_bloodtokens",name=L["Bloody Tokens"]   or "Bloody Tokens",   id=2123, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_10_dungeonjewelry_titan_trinket_2_color2" },
           -- { key="pvp_trophy",     name=L["Trophy of Strife"]or "Trophy of Strife",id=2797, statFunc=GetStatCurrency, icon="Interface\\Icons\\ability_bossfelorcs_necromancer_orange" },
        },
    },
}

STAT_SECTIONS_BY_KEY = {}
for _, sec in ipairs(STAT_SECTIONS) do
    STAT_SECTIONS_BY_KEY[sec.key] = sec
end

local SecondaryKeyToStat = {
    secondary_crit        = "CriticalStrike",
    secondary_haste       = "Haste",
    secondary_mastery     = "Mastery",
    secondary_versatility = "Versatility",
}

local function GetSortedSecondaryRows(section)
    if not ShouldShowPriority() then
        return section.rows
    end

	local _, _, classID = UnitClass("player")
	local specID = GetSpecialization()
	local heroID = (C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec and C_ClassTalents.GetActiveHeroTalentSpec()) or nil
	
    local sortedStats = GetSortedStats(classID, specID, heroID)

    -- Build lookup
    local rowByStat = {}
    for _, rowData in ipairs(section.rows) do
        local statName = SecondaryKeyToStat[rowData.key]
        if statName then
            rowByStat[statName] = rowData
        end
    end

    -- Build new ordered list
    local newRows = {}
    for _, statInfo in ipairs(sortedStats) do
        local row = rowByStat[statInfo.stat]
        if row then
            table.insert(newRows, row)
        end
    end

    return newRows
end

local function UpdateStatsScrollRange(scrollFrame)
    local sb    = scrollFrame.scrollBar
    local child = scrollFrame.scrollChild
    if not sb or not child then return end

    local frameH = scrollFrame:GetHeight() or 0
    local childH = child:GetHeight() or 0
    local range  = math.max(childH - frameH, 0)

    sb:SetMinMaxValues(0, range)

	local thumb = sb:GetThumbTexture()

	if range > 0 then
        sb:Show()
		thumb:Show()		
    else
        sb:Hide()
        sb:SetValue(0)
        scrollFrame:SetVerticalScroll(0)
		thumb:Hide()		
    end

end

local function UpdateLayout()

    if CCS.initall == true then 
        return 
	end
	
    local previousSection = nil
    local sectionSpacing = 7
    local rowSpacing = 2

    -------------------------------------------------
    -- We accumulate scrollable height as we lay out
    -------------------------------------------------
    local contentHeight = 0
    local firstVisible = true
	local orderedKeys = CCS:GetOrderedSections(STAT_SECTIONS)

    --for _, section in ipairs(STAT_SECTIONS) do
	for _, key in ipairs(orderedKeys) do
		local section = STAT_SECTIONS_BY_KEY[key]
        local sectionFrame = _G["CCS_Section_" .. section.key]
        local header       = _G["CCS_Header_" .. section.key]

        if sectionFrame and header then
            -------------------------------------------------
            -- SECTION HIDDEN ENTIRELY
            -------------------------------------------------
            if not option(section.showKey) then
                sectionFrame:Hide()

            else
                sectionFrame:Show()

                -------------------------------------------------
                -- ANCHOR SECTION IN VERTICAL CHAIN
                -------------------------------------------------
                sectionFrame:ClearAllPoints()
                if not previousSection then
                    sectionFrame:SetPoint("TOPLEFT", _G["CSPilvl"], "BOTTOMLEFT", 0, -sectionSpacing)
                else
                    sectionFrame:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -sectionSpacing)
                end

                -------------------------------------------------
                -- COLLAPSE STATE
                -------------------------------------------------
                local isCollapsed = header.isCollapsed == true
                local showHeader = isCollapsed or option("show_headers") ~= false

                local previousRow
                local totalHeight

                -------------------------------------------------
                -- HEADER VISIBILITY
                -------------------------------------------------
                if showHeader then
                    header:Show()
                    header:ClearAllPoints()
                    header:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)
                    previousRow = header
                    totalHeight = header:GetHeight()
                else
                    header:Hide()
                    previousRow = nil
                    totalHeight = 0
                end

                -------------------------------------------------
                -- ROW ORDER (SECONDARY STAT PRIORITY)
                -------------------------------------------------
                local rows = section.rows
                if section.key == "SECONDARY" then
                    rows = GetSortedSecondaryRows(section)

                    -- Refresh header text + toggle visibility
                    if header.headerText then
                        header.headerText:SetText(GetActiveModeDisplayName())
                    end
                    if header.prioToggle then
                        local numOpts = option("show_secondarypriority") and 1 or 0
                        local _sl = GetActiveSlots()
                        for _n = 1, #_sl do
                            if _sl[_n].enabled then numOpts = numOpts + 1 end
                        end
                        header.prioToggle:SetShown(numOpts > 1 and option("show_secondarypriority") == false)
                    end
                end

                -------------------------------------------------
                -- COLLAPSED SECTION
                -------------------------------------------------
                if isCollapsed then
                    for _, rowData in ipairs(rows) do
                        local row = _G["CCS_Row_" .. rowData.key]
                        if row then row:Hide() end
                    end

                    sectionFrame:SetHeight(totalHeight + 3)

                -------------------------------------------------
                -- EXPANDED SECTION
                -------------------------------------------------
                else
                    for _, rowData in ipairs(rows) do
                        local row = _G["CCS_Row_" .. rowData.key]
                        if row then
                            local shouldHide = (option("show_hide_zero_stats") == true) and (row.isZero == true)

                            -------------------------------------------------
                            -- ICON VISIBILITY
                            -------------------------------------------------
                            if option("show_stat_icons") == true then
                                row.leftText:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
                                row.icon:Show()
                            else
                                row.leftText:SetPoint("LEFT", row, "LEFT", 2, 0)
                                row.icon:Hide()
                            end

                            -------------------------------------------------
                            -- ROW VISIBILITY
                            -------------------------------------------------
                            if option(rowData.key) ~= false and not shouldHide then
                                row:Show()
                                row:ClearAllPoints()

                                if previousRow then
                                    row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", 0, -rowSpacing)
                                else
                                    row:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)
                                end

                                previousRow = row
                                totalHeight = totalHeight + row:GetHeight() + rowSpacing
                            else
                                row:Hide()
                            end
                        end
                    end

                    sectionFrame:SetHeight(totalHeight + 3)
                end

                -------------------------------------------------
                -- ACCUMULATE SCROLL HEIGHT
                -------------------------------------------------
                if not firstVisible then
                    contentHeight = contentHeight + sectionSpacing
                end

                contentHeight = contentHeight + sectionFrame:GetHeight()+7
                firstVisible = false

                previousSection = sectionFrame
            end
        end
    end

    -------------------------------------------------
    -- APPLY HEIGHT TO SCROLL CHILD
    -------------------------------------------------
    local scrollChild = _G["CCS_stat_sc"]
    if scrollChild then
        scrollChild:SetHeight(contentHeight)
    end

    -------------------------------------------------
    -- UPDATE SCROLLBAR RANGE
    -------------------------------------------------
    local scrollFrame = _G["CCS_stat_sf"]
    if scrollFrame then
        UpdateStatsScrollRange(scrollFrame)
    end
end

local UpdateAllStats

local function CreateHeaderRow(parent, frameName, section)
    -- Reuse if it already exists
    local row = _G[frameName] or CreateFrame("Frame", frameName, parent, "BackdropTemplate")
	local title = section.title
	local color = section.color
	local secColor_r, secColor_g, secColor_b, secColor_a = unpack(option(section.colorKey))
	color.r = secColor_r or color.r
	color.g = secColor_g or color.g
	color.b = secColor_b or color.b
	
    -- Extract section key from "CCS_Header_<key>"
    if not row.sectionKey then
        row.sectionKey = frameName:match("CCS_Header_(.+)")
    end

    -------------------------------------------------
    -- Collapse state
    -------------------------------------------------
    if row.isCollapsed == nil then
        row.isCollapsed = false   -- default expanded
    end

	row.isCollapsed = option(section.collapseKey)

    row:EnableMouse(true)

	-- Drag state.  Dress in Drag and do the Hula! Pumba style!
	row.isDragging = false
	row.dragGhost = nil
	row.dragTarget = nil
	row.dragInsertIndex = nil

    if not row.initializedClick then
		row:SetScript("OnMouseDown", function(self, button)

			-------------------------------------------------
			-- SHIFT + LEFT = begin drag
			-------------------------------------------------
			if IsShiftKeyDown() and button == "LeftButton" then
				self.isDragging = true

				-- Create ghost frame (outline only)
				if not self.dragGhost then
					local ghost = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
					ghost:SetSize(self:GetWidth(), self:GetHeight())
					ghost:SetBackdrop({
						edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
						edgeSize = 12,
					})
					ghost:SetBackdropBorderColor(1, 1, 0, 1) -- yellow outline
					ghost:SetFrameStrata("TOOLTIP")
					ghost:SetAlpha(0.8)
					self.dragGhost = ghost
				end

				-- Position ghost at cursor
				local x, y = GetCursorPosition()
				local scale = UIParent:GetEffectiveScale()
				self.dragGhost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/scale, y/scale)
				self.dragGhost:Show()

				-- Start tracking movement
				self:SetScript("OnUpdate", function(header)
					if not header.isDragging then return end

					-- Move ghost
					local cx, cy = GetCursorPosition()
					local scale = UIParent:GetEffectiveScale()
					header.dragGhost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx/scale, cy/scale)

					-------------------------------------------------
					-- Determine insertion index based on Y position
					-------------------------------------------------
					local orderedKeys = CCS:GetOrderedSections(STAT_SECTIONS)
					local headerList = {}

					for _, key in ipairs(orderedKeys) do
						local h = _G["CCS_Header_" .. key]
						if h then
							table.insert(headerList, { key = key, frame = h })
						end
					end

					-- Clear all highlights
					for _, info in ipairs(headerList) do
						info.frame.highlight:Hide()
					end

					-- Ghost Y
					local gx, gy = header.dragGhost:GetCenter()

					-- Default: insert at bottom
					local insertIndex = #headerList + 1

					-- Find first header below ghost
					for i, info in ipairs(headerList) do
						local hx, hy = info.frame:GetCenter()
						if gy > hy then
							insertIndex = i
							break
						end
					end

					header.dragInsertIndex = insertIndex

					-- Highlight the target header
					if headerList[insertIndex] then
						headerList[insertIndex].frame.highlight:Show()
					end
				end)

				return
			end

			-------------------------------------------------
			-- CTRL + LEFT = save collapse state
			-------------------------------------------------
			if IsControlKeyDown() and button == "LeftButton" then
				local def = CCS:GetOptionDefByKey(section.collapseKey)
				if def then
					CCS:UpdateOption(def, self.isCollapsed)
					C_Timer.After(.1, function() CCS:LoadOptions() end)
				end
				PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
				UpdateLayout()
				return
			end

			-------------------------------------------------
			-- NORMAL CLICK = collapse/expand
			-------------------------------------------------
			self.isCollapsed = not self.isCollapsed

			if self.chevron then
				if self.isCollapsed then
					self.chevron:SetTexCoord(0, 0.5, 0, 0.5)
					self.chevron:SetAlpha(1)
				else
					self.chevron:SetTexCoord(0.5, 1, 0, 0.5)
					self.chevron:SetAlpha(.3)
				end
			end

			PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
			UpdateLayout()
		end)

		row:SetScript("OnMouseUp", function(self, button)
			if self.isDragging then
				self.isDragging = false

				-- Hide ghost
				if self.dragGhost then
					self.dragGhost:Hide()
				end

				-- Clear highlights
				local orderedKeys = CCS:GetOrderedSections(STAT_SECTIONS)
				for _, key in ipairs(orderedKeys) do
					local h = _G["CCS_Header_" .. key]
					if h and h.highlight then
						h.highlight:Hide()
					end
				end

				-- Perform reorder
				if self.dragInsertIndex then
					local headerList = {}
					for _, key in ipairs(orderedKeys) do
						table.insert(headerList, key)
					end

					local dropKey = headerList[self.dragInsertIndex]
					CCS:ReorderSections(self.sectionKey, dropKey)
					UpdateLayout()
				end

				-- Stop tracking movement
				self:SetScript("OnUpdate", nil)
				return
			end
		end)

		-------------------------------------------------
		-- Tooltip Instructions
		-------------------------------------------------
		row:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip_SetTitle(GameTooltip, L["INSTRUCTIONS"]) -- don't really need a title

			-- Instructional lines
			GameTooltip_AddNormalLine(GameTooltip, "1) ".. L["CLICK_COL_EXP"].."\n\n")
			GameTooltip_AddNormalLine(GameTooltip, "2) "..L["CTRL_CLICK_COL_EXP"].."\n\n")
			GameTooltip_AddNormalLine(GameTooltip, "3) "..L["SHIFT_DRAG"])

			GameTooltip:Show()
		end)

		row:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

        row.initializedClick = true
    end

    -------------------------------------------------
    -- Size
    -------------------------------------------------
	local header_fontsize = option("fontsize_statheaders") or 14
    local rowH = rowHeight * (header_fontsize / 14)
    row:SetSize(rowWidth, rowH)

    -------------------------------------------------
    -- Expand/Collapse + Indicator
    -------------------------------------------------
    if not row.chevron then
        row.chevron = row:CreateTexture(nil, "ARTWORK")
        row.chevron:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
        row.chevron:SetSize(8, 8)
        row.chevron:SetPoint("LEFT", row, "LEFT", 2, 0)
		row.chevron:SetAlpha(.3)
    end

    -- Set collapse state
    if row.isCollapsed then
        row.chevron:SetTexCoord(0, 0.5, 0, 0.5)   -- right arrow
    else
        row.chevron:SetTexCoord(0.5, 1, 0, 0.5)   -- down arrow
    end

    -------------------------------------------------
    -- Header Text
    -------------------------------------------------
    if not row.headerText then
        row.headerText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    end
	row.headerText:SetPoint("CENTER")
	row.headerText:SetFont(option("fontname_statheaders") or "Fonts\\FRIZQT__.TTF", header_fontsize, CCS.textoutline)
	row.headerText:SetTextColor(
	option("fontcolor_statheaders")[1] or 1,
	option("fontcolor_statheaders")[2] or 1,
	option("fontcolor_statheaders")[3] or 1,
	option("fontcolor_statheaders")[4] or 1)
	
	if section.key == "SECONDARY" then
        -- Count enabled priority options for toggle visibility
        local numOptions = option("show_secondarypriority") and 1 or 0
        local _slots = GetActiveSlots()
        for n = 1, #_slots do
            if _slots[n].enabled then numOptions = numOptions + 1 end
        end

        if not row.prioToggle then
            row.prioToggle = CreateFrame("Button", nil, row)
            row.prioToggle:SetSize(16, 16)
            row.prioToggle:SetPoint("RIGHT", row, "RIGHT", 3, 0)

            row.prioToggle:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            row.prioToggle:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
            row.prioToggle:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

            row.prioToggle:SetScript("OnClick", function()
                if not CCS.CurrentProfile then return end
                local mode = GetActiveMode()
                local modeKey = GetActiveModeKey()

                -- Build ordered list of enabled modes from this spec's slots then wowhead
                local enabledModes = {}
                local _pslots = GetActiveSlots()
                for n = 1, #_pslots do
                    if _pslots[n].enabled then
                        table.insert(enabledModes, "slot_" .. n)
                    end
                end
                if option("show_secondarypriority") then
                    table.insert(enabledModes, "wowhead")
                end

                if #enabledModes > 1 then
                    -- Find current position and advance to next, wrapping around
                    local nextMode = enabledModes[1]
                    for i, m in ipairs(enabledModes) do
                        if m == mode then
                            nextMode = enabledModes[(i % #enabledModes) + 1]
                            break
                        end
                    end
                    CCS.CurrentProfile[modeKey] = nextMode
                end

                -- Refresh stats, layout, and header text
                if _G["CCS_stat_sc"] then
                    UpdateAllStats(_G["CCS_stat_sc"])
                    UpdateLayout()
                    local hrow = _G["CCS_Header_SECONDARY"]
                    if hrow then
                        hrow.headerText:SetText(GetActiveModeDisplayName())
                    end
                end
            end)
        end
		row.prioToggle:Hide()
        if option("show_secondarypriority") == true then
			row.prioToggle:Hide()
		elseif numOptions > 1 then
            row.prioToggle:Show()
        else
            row.prioToggle:Hide()
        end

        row.headerText:SetText(GetActiveModeDisplayName())
	else
        if row.prioToggle then row.prioToggle:Hide() end
		row.headerText:SetText(title or "HEADER")
	end

    -------------------------------------------------
    -- Gradient Colors
    -------------------------------------------------
    local r = color and color.r or 0.29
    local g = color and color.g or 0.46
    local b = color and color.b or 0.90

    local leftStart  = CreateColor(r, g, b, 0.20)
    local leftEnd    = CreateColor(r, g, b, 1.00)
    local rightStart = CreateColor(r, g, b, 1.00)
    local rightEnd   = CreateColor(r, g, b, 0.20)

    -------------------------------------------------
    -- Left Gradient Bar
    -------------------------------------------------
    if not row.leftTex then
        row.leftTex = row:CreateTexture(nil, "ARTWORK")
        row.leftTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        row.leftTex:SetTexCoord(1, 0, 0, 1)
        row.leftTex:SetHeight(1.3)
        row.leftTex:SetPoint("RIGHT", row.headerText, "LEFT", -6, 0)
        row.leftTex:SetPoint("LEFT", row, "LEFT", 0, 0)
    end
    row.leftTex:SetGradient("HORIZONTAL", leftStart, leftEnd)

    -------------------------------------------------
    -- Right Gradient Bar
    -------------------------------------------------
    if not row.rightTex then
        row.rightTex = row:CreateTexture(nil, "ARTWORK")
        row.rightTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        row.rightTex:SetHeight(1.3)
        row.rightTex:SetPoint("LEFT", row.headerText, "RIGHT", 6, 0)
        row.rightTex:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    end
    row.rightTex:SetGradient("HORIZONTAL", rightStart, rightEnd)

    -------------------------------------------------
    -- Background
    -------------------------------------------------
    if not row.bg then
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
    end
    row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.4)

	-- Highlight overlay (for drag target)
	if not row.highlight then
		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetColorTexture(1, 1, 0, 0.25) -- yellow tint
		row.highlight:SetAllPoints()
		row.highlight:Hide()
	end

    return row
end

local function TruncateWithEllipsis(fontString, text, maxWidth)
    fontString:SetText(text)

    if fontString:GetStringWidth() <= maxWidth then
        return text
    end

    local ellipsis = "..."
    local low, high = 1, #text

    -- Binary search for the longest substring that fits
    while low < high do
        local mid = math.floor((low + high) / 2)
        local candidate = text:sub(1, mid) .. ellipsis
        fontString:SetText(candidate)

        if fontString:GetStringWidth() > maxWidth then
            high = mid - 1
        else
            low = mid + 1
        end
    end

    return text:sub(1, high) .. ellipsis
end

local function CreateContentRow(parent, frameName, rowName, iconPath, color)
    -- Reuse if it already exists
    local row = _G[frameName] or CreateFrame("Frame", frameName, parent, "BackdropTemplate")

	local left_fontname = option("fontname_statname")
	local left_fontsize = option("fontsize_statname")
	local left_fontcolor = option("fontcolor_statname")
	local right_fontname = option("fontname_stats")
	local right_fontsize = option("fontsize_stats")
	local right_fontcolor = option("fontcolor_stats")

    local rowH = rowHeight / 1.5 * (math.max(left_fontsize, right_fontsize)) / 10
    row:SetSize(rowWidth, rowH)

    -------------------------------------------------
    -- Icon
    -------------------------------------------------
    if not row.icon then
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    end
    row.icon:SetSize(rowH, rowH)
    row.icon:SetTexture(iconPath)

    -------------------------------------------------
    -- Compute MAX_LABEL_WIDTH
    -------------------------------------------------
    local RESERVED_RIGHT_WIDTH = 60 -- safe space for rightText
    local MAX_LABEL_WIDTH = rowWidth - rowH - 2 - 6 - RESERVED_RIGHT_WIDTH - 6
    row.MAX_LABEL_WIDTH = MAX_LABEL_WIDTH  -- store for update logic

    -------------------------------------------------
    -- Left text (label)
    -------------------------------------------------
    if not row.leftText then
        row.leftText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    end
	row.leftText:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.leftText:SetFont(left_fontname or "Fonts\\FRIZQT__.TTF", left_fontsize or 10, CCS.textoutline)
	row.leftText:SetTextColor(
	option("fontcolor_statname")[1] or 1,
	option("fontcolor_statname")[2] or 1,
	option("fontcolor_statname")[3] or 1,
	option("fontcolor_statname")[4] or 1)
    row.leftText:SetWidth(MAX_LABEL_WIDTH)
	row.leftText:SetJustifyH("LEFT")
	row.leftText:SetJustifyV("MIDDLE")
    row.leftText:SetWordWrap(false)
    row.leftText:SetMaxLines(1)
    row.leftText:SetText(rowName or "")

    -------------------------------------------------
    -- Right text (value)
    -------------------------------------------------
    if not row.rightText then
        row.rightText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    end
    -- Placeholder until stat update logic runs
	row.rightText:SetPoint("RIGHT", -6, 0)
	row.rightText:SetFont(right_fontname or "Fonts\\FRIZQT__.TTF", right_fontsize or 10, CCS.textoutline)
	row.rightText:SetTextColor(
	option("fontcolor_stats")[1] or 1,
	option("fontcolor_stats")[2] or 1,
	option("fontcolor_stats")[3] or 1,
	option("fontcolor_stats")[4] or 1)
    row.rightText:SetText("Default")

    -------------------------------------------------
    -- Background
    -------------------------------------------------
    if not row.bg then
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
    end
    row.bg:SetColorTexture(.05, .05, .05, 0.6)

    -------------------------------------------------
    -- Highlight
    -------------------------------------------------
    if not row.highlight then
        row.highlight = row:CreateTexture(nil, "OVERLAY")
        row.highlight:SetAllPoints()
        row.highlight:Hide()

    end
	
    row.highlight:SetColorTexture(color.r, color.g, color.b, 0.3)
	row.isZero=false
    return row
end

local function CreateAndUpdateiLvlframe(parent)
	local btn = _G["CSPilvl"] or CreateFrame("Button", "CSPilvl", parent)
	local btnfont1
	local btnfontilvl = _G["CSPilvlfs1"] or btn:CreateFontString("CSPilvlfs1")
	local btntex = _G["CSPilvltex"] or btn:CreateTexture("CSPilvltex", "BACKGROUND", nil, 1)
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	local Color = "a336ed"
	local tt_name = ""
	local tt_desc = ""

	btn.fontString = btnfontilvl
	btn.texture = btntex
	
	btn:SetParent(parent)
	btn:ClearAllPoints()
	btn:SetSize(rowWidth, rowHeight*(option("fontsize_cilvl") or 20) /20)
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	btn:SetFrameStrata("HIGH")
	btn.throttle = 0;
	btn:Show()       
	
	btntex:ClearAllPoints()
	btntex:SetAllPoints()
	btntex:SetTexture("Interface\\Masks\\SquareMask.BLP")
	btntex:SetGradient("Vertical", CreateColor(0, 0, 0, .2), CreateColor(.1, .1, .1, .4)) -- Dark Gray
	btnfontilvl:SetPoint("CENTER", btn, "CENTER", 0 ,0)
	btnfontilvl:SetFont(option("fontname_cilvl") or CCS.fontname, (option("fontsize_cilvl") or 20), CCS.textoutline)
	if option("showfontshadow") == true then
		btnfontilvl:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfontilvl:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
	CCS.PreloadEquippedItemInfo("player")
	CCS.WaitForItemInfoReady("player", function()
		local color = CCS:GetAverageEquippedRarityHex("player")
		Color = color

		avgItemLevelEquipped = format("%s", CCS.round(avgItemLevelEquipped))
		avgItemLevelEquipped = format("%s", CCS.round(avgItemLevelEquipped))
		avgItemLevel = format("%s", CCS.round(avgItemLevel))
		avgItemLevelPvP = format("%s", CCS.round(avgItemLevelPvP))

	if option("show_inbag_ilvl") == true then
		btnfontilvl:SetText(format("|cFF%s%s / %s|r", Color, avgItemLevelEquipped, avgItemLevel))
	else
		btnfontilvl:SetText(format("|cFF%s%s|r", Color, avgItemLevelEquipped))            
	end
		tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel
		tt_name = tt_name .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped)
		tt_name = tt_name .. FONT_COLOR_CODE_CLOSE

		tt_desc = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
		tt_desc = tt_desc.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(avgItemLevelPvP)

		btn:SetScript("OnEnter", function(self)
			CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
			CCS.tooltip:AddDoubleLine(tt_name, nil, 1, 1, 1, 1, 1, 1)
			CCS.tooltip:AddLine(tt_desc, nil, nil, nil, true)
			CCS.tooltip:Show()
		end)
		btn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)

	end)
	return btn
end

local function TruncateToWidth(fs, text, maxWidth)
    fs:SetText(text)
    if fs:GetStringWidth() <= maxWidth then
        return text
    end

    local ellipsis = "…"
    local len = #text

    while len > 1 do
        len = len - 1
        local candidate = text:sub(1, len) .. ellipsis
        fs:SetText(candidate)
        if fs:GetStringWidth() <= maxWidth then
            return candidate
        end
    end

    return ellipsis
end

UpdateAllStats = function(parent)
    if CCS.initall == true then return end
    CreateAndUpdateiLvlframe(parent)

	if ShouldShowPriority() then
        local _, _, classID = UnitClass("player")
        local specID = GetSpecialization()
        local heroID = (C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec and C_ClassTalents.GetActiveHeroTalentSpec()) or nil
        GetSortedStats(classID, specID, heroID)  -- side-effect: updates cachedPriorityLookup
    end

    local mode = option("long_text_handling")  -- "Full Text", "Truncate", "Wrap Text"
	local orderedKeys = CCS:GetOrderedSections(STAT_SECTIONS)

	for _, key in ipairs(orderedKeys) do
	--for _, sectionData in ipairs(STAT_SECTIONS) do
		local sectionData = STAT_SECTIONS_BY_KEY[key]
        local sectionFrame = _G["CCS_Section_" .. sectionData.key]

        if sectionFrame ~= nil then

            for _, rowData in ipairs(sectionData.rows) do
                local rowFrame = _G["CCS_Row_" .. rowData.key]

                if rowFrame ~= nil then

                    -------------------------------------------------
                    -- Get stat values
                    -------------------------------------------------
                    local leftText, rightText, tt_name, tt_desc, link, isZero =
                        rowData.statFunc(rowData)

                    rowFrame.isZero = isZero

                    -------------------------------------------------
                    -- Update icon for currencies
                    -------------------------------------------------
					if rowData.statFunc == GetStatCurrency then
						-- Resolve crest ID if needed
						local id = rowData.id
						if id == -1 then
							id = GetCrestIDForRow(rowData.key)
						end

						local currencyData
						if id and C_CurrencyInfo then
							currencyData = C_CurrencyInfo.GetCurrencyInfo(id)
							link = C_CurrencyInfo.GetCurrencyLink(id)
						elseif id then
							currencyData = GetCurrencyInfo(id)
							link = GetCurrencyLink(id)
						end

						if currencyData and currencyData.iconFileID then
							rowFrame.icon:SetTexture(currencyData.iconFileID)
						end
					end

                    -------------------------------------------------
                    -- Update power color for attributes
                    -------------------------------------------------
                    if rowData.key == "attribute_power" then
                        local _, powerToken = UnitPowerType("player")
                        local info = PowerBarColor[powerToken]
                        local r, g, b = 1, 1, 1
                        if info then r, g, b = info.r, info.g, info.b end
                        rowFrame.icon:SetVertexColor(r, g, b)
                    end

                    -------------------------------------------------
                    -- Update right text
                    -------------------------------------------------
                    if rowFrame.rightText then
                        rowFrame.rightText:SetText(rightText or "")
                    end

                    -------------------------------------------------
                    -- LEFT TEXT HANDLING (the important part)
                    -------------------------------------------------
                    if rowFrame.leftText ~= nil then
                        local fs = rowFrame.leftText
                        local text = leftText or ""
						
						--if not CCS.AreSecretsDisabled() then 
							fs:SetText(text)
							-- Compute max label width
							local reservedRightWidth
							local MAX_LABEL_WIDTH
							
							if rowFrame.reservedRightWidth == nil then
								reservedRightWidth = 110 -- rowFrame.rightText:GetStringWidth()+4
								MAX_LABEL_WIDTH =
								rowFrame:GetWidth()
								- rowFrame.icon:GetWidth()
								- 2 - 6 - reservedRightWidth - 6
								rowFrame.reservedRightWidth = MAX_LABEL_WIDTH
							end
							
							local naturalWidth = fs:GetStringWidth()
							-- ALWAYS set width + justification first
							fs:SetWidth(rowFrame.reservedRightWidth)
							fs:SetJustifyH("LEFT")
							fs:SetJustifyV("MIDDLE")
							fs:SetNonSpaceWrap(true) 
							
							if mode == "Full Text" then
								fs:SetWidth(0)
								fs:SetWordWrap(false)
								fs:SetMaxLines(1)
								fs:SetText(text)
							elseif mode == "Truncate" then
								fs:SetWidth(rowFrame.reservedRightWidth)
								fs:SetWordWrap(false)
								fs:SetMaxLines(1)
								if naturalWidth > rowFrame.reservedRightWidth then
									fs:SetText(TruncateToWidth(fs, text, rowFrame.reservedRightWidth))
								end
							elseif mode == "Wrap Text" then
								fs:SetWidth(rowFrame.reservedRightWidth)
								fs:SetWordWrap(true)
								fs:SetMaxLines(2)
								fs:SetText(text)
								-- Increase row height for wrapped text
								local baseH = rowFrame:GetHeight()
								local neededH = fs:GetStringHeight() + 4
								rowFrame:SetHeight(math.max(baseH, neededH))
							end
								fs:SetJustifyH("LEFT")
								fs:SetJustifyV("MIDDLE")
								fs:SetNonSpaceWrap(true) 						
						--end	
                    end

                    -------------------------------------------------
                    -- Tooltip
                    -------------------------------------------------
					if not CCS.AreSecretsDisabled() then 
						rowFrame:SetScript("OnEnter", function(self)
							local rd = rowData

							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

							if link ~= nil then
								GameTooltip:SetHyperlink(link)
							elseif not CCS.AreSecretsDisabled() then 
								if tt_name and tt_name ~= "" then
									GameTooltip:AddLine(tt_name, 1, 1, 1, true)
								end
								if tt_desc and tt_desc ~= "" then
									GameTooltip:AddLine(tt_desc, nil, nil, nil, true)
								end
							end

							-- Only show hover highlights if NO stat row is currently clicked
							if not CCS.activeClickedRow and option("show_stathighlights") then
								if CCS.statKeyMap[rd.key] then
									CCS:ShowStatHighlights(rd)
								end
							end

							self.highlight:Show()
							GameTooltip:Show()
						end)

						rowFrame:SetScript("OnMouseDown", function(self)
							local rd = rowData

							if option("show_stathighlights") ~= true or not CCS.statKeyMap[rd.key] then return end

							-- If clicking the already-active row → unselect it
							if CCS.activeClickedRow == self then
								self.clicked = false
								CCS.activeClickedRow = nil
								self.highlight:Hide()
								CCS:HideAllStatHighlights()
								return
							end

							-- If another row was previously clicked, clear it
							if CCS.activeClickedRow then
								CCS.activeClickedRow.clicked = false
								CCS.activeClickedRow.highlight:Hide()
							end

							-- Activate this row
							self.clicked = true
							CCS.activeClickedRow = self

							-- Show highlight + stat overlays
							self.highlight:Show()
							CCS:ShowStatHighlights(rd)
						end)

						rowFrame:SetScript("OnLeave", function(self)
							-- Only hide the row highlight if this row is NOT the active clicked row
							if CCS.activeClickedRow ~= self then
								self.highlight:Hide()
							end

							GameTooltip:Hide()

							-- Only hide overlays if nothing is locked in
							if not CCS.activeClickedRow then
								CCS:HideAllStatHighlights()
							end
						end)
					end
                end
            end
        end
    end
end

-- Make this into a minimal scroll bar; like blizzard's since that is what we are mimic'ing.
local function SetupScrollBar()
    local sb = _G["CCS_stat_sfScrollBar"]
    if not sb then return end

    local up   = sb.ScrollUpButton
    local down = sb.ScrollDownButton

    -- thumb
    local thumb = sb:GetThumbTexture()
    thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    thumb:SetColorTexture(.4, .4, .4, 0.7)
    thumb:SetSize(12, 24)

    -- UP BUTTON
    up:SetSize(17, 11)
    up.Normal:SetAllPoints()
    up.Normal:SetAtlas("minimal-scrollbar-arrow-top", true)
    up.Highlight:SetAllPoints()
    up.Highlight:SetAtlas("minimal-scrollbar-arrow-top-over", true)
    up.Pushed:SetAllPoints()
    up.Pushed:SetAtlas("minimal-scrollbar-arrow-top-down", true)
    up.Disabled:SetAllPoints()
    up.Disabled:SetAtlas("minimal-scrollbar-arrow-top", true)

    -- DOWN BUTTON
    down:SetSize(17, 11)
    down.Normal:SetAllPoints()
    down.Normal:SetAtlas("minimal-scrollbar-arrow-bottom", true)
    down.Highlight:SetAllPoints()
    down.Highlight:SetAtlas("minimal-scrollbar-arrow-bottom-over", true)
    down.Pushed:SetAllPoints()
    down.Pushed:SetAtlas("minimal-scrollbar-arrow-bottom-down", true)
    down.Disabled:SetAllPoints()
    down.Disabled:SetAtlas("minimal-scrollbar-arrow-bottom", true)
end


local function CreateStatsScrollFrame(rowWidth)
    local scrollFrame = CCS_stat_sf
    if not scrollFrame then
        scrollFrame = CreateFrame("ScrollFrame", "CCS_stat_sf", CharacterStatsPane, "BackdropTemplate")
        scrollFrame:EnableMouse(true)
        scrollFrame:EnableMouseWheel(true)
        scrollFrame:SetClipsChildren(true)
    end

    scrollFrame:ClearAllPoints()
    scrollFrame:SetPoint("TOPLEFT", CharacterStatsPane, "TOPLEFT", 10, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", CharacterStatsPane, "BOTTOMRIGHT", -12, 5)
    scrollFrame:Show()

    local scrollChild = CCS_stat_sc
    if not scrollChild then
        scrollChild = CreateFrame("Frame", "CCS_stat_sc", scrollFrame)
        scrollFrame:SetScrollChild(scrollChild)
    end

    scrollChild:ClearAllPoints()
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollChild:SetWidth(rowWidth or scrollFrame:GetWidth())
    scrollChild:SetHeight(1) -- you’ll set this to total row height later

    scrollFrame.scrollChild = scrollChild
    return scrollFrame, scrollChild
end

local function CreateStatsScrollBar(scrollFrame)
    local sb = CCS_stat_sfScrollBar
    if not sb then
        sb = CreateFrame("Slider", "CCS_stat_sfScrollBar", CharacterStatsPane, "BackdropTemplate")
        sb:SetOrientation("VERTICAL")
        sb:SetMinMaxValues(0, 0)
        sb:SetValueStep(1)
        sb:SetObeyStepOnDrag(false)

        sb:SetWidth(18)
        sb:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -21)
        sb:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 6)

        -- Border frame
        sb.Border = CreateFrame("Frame", nil, sb, "BackdropTemplate")
        sb.Border:SetAllPoints()
        sb.Border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
        })
        sb.Border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

        -- Track background
        sb.Track = sb:CreateTexture(nil, "BACKGROUND")
        sb.Track:SetAllPoints()
        sb.Track:SetColorTexture(0, 0, 0, 0.25)

        -- UP button
        local up = CreateFrame("Button", "CCS_stat_sfScrollBarScrollUpButton", sb)
        up:SetPoint("BOTTOM", sb, "TOP", 0, 0)
        up:SetSize(17, 11)

        up.Normal    = up:CreateTexture(nil, "ARTWORK")
        up.Highlight = up:CreateTexture(nil, "HIGHLIGHT")
        up.Pushed    = up:CreateTexture(nil, "ARTWORK")
        up.Disabled  = up:CreateTexture(nil, "ARTWORK")

        up:SetNormalTexture(up.Normal)
        up:SetHighlightTexture(up.Highlight)
        up:SetPushedTexture(up.Pushed)
        up:SetDisabledTexture(up.Disabled)

        -- DOWN button
        local down = CreateFrame("Button", "CCS_stat_sfScrollBarScrollDownButton", sb)
        down:SetPoint("TOP", sb, "BOTTOM", 0, 0)
        down:SetSize(17, 11)

        down.Normal    = down:CreateTexture(nil, "ARTWORK")
        down.Highlight = down:CreateTexture(nil, "HIGHLIGHT")
        down.Pushed    = down:CreateTexture(nil, "ARTWORK")
        down.Disabled  = down:CreateTexture(nil, "ARTWORK")

        down:SetNormalTexture(down.Normal)
        down:SetHighlightTexture(down.Highlight)
        down:SetPushedTexture(down.Pushed)
        down:SetDisabledTexture(down.Disabled)

		up:SetScript("OnClick", function()
			local min, max = sb:GetMinMaxValues()
			local current = sb:GetValue()
			sb:SetValue(math.max(current - 20, min))
		end)

		down:SetScript("OnClick", function()
			local min, max = sb:GetMinMaxValues()
			local current = sb:GetValue()
			sb:SetValue(math.min(current + 20, max))
		end)

        -- Assign to scrollbar fields (required)
        sb.ScrollUpButton = up
        sb.ScrollDownButton = down

        -- Thumb
        local thumb = sb:GetThumbTexture() or sb:CreateTexture(nil, "OVERLAY")
        sb:SetThumbTexture(thumb)
        thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
        thumb:SetColorTexture(.8, .8, .8, 0.9)
        thumb:SetSize(12, 24)  -- minimum thumb height

        -- Scroll logic
        sb:SetScript("OnValueChanged", function(self, value)
            scrollFrame:SetVerticalScroll(value)
        end)

        scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            local min, max = sb:GetMinMaxValues()
            local current = sb:GetValue()
            local step = 20

            if delta > 0 then current = current - step
            else current = current + step end

            if current < min then current = min end
            if current > max then current = max end
            sb:SetValue(current)
        end)
    end

    scrollFrame.scrollBar = sb

    -- Apply minimal skin
    SetupScrollBar()

    return sb
end

local function ApplyStyle(self)
    -------------------------------------------------
    -- iLvl Frame
    -------------------------------------------------

    local btn = self.iLvlFrame
    if btn and btn.fontString then
        local fs = btn.fontString
        fs:SetFont(option("fontname_cilvl") or CCS.fontname,
                   option("fontsize_cilvl") or 20,
                   CCS.textoutline)

        if option("showfontshadow") then
            fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        else
            fs:SetShadowColor(0,0,0,0)
        end
    end

    -------------------------------------------------
    -- Sections
    -------------------------------------------------
    for key, section in pairs(self.sections or {}) do
        local frame  = section.frame
        local header = section.header
        local rows   = section.rows

        -------------------------------------------------
        -- Section background
        -------------------------------------------------
        local secColor = option(section.colorKey)
        if frame and frame.bg and secColor then
            frame.bg:SetColorTexture(secColor[1], secColor[2], secColor[3], 0.2)
        end

        -------------------------------------------------
        -- Header styling
        -------------------------------------------------
        if header then
            local headerFont = option("fontname_statheaders") or "Fonts\\FRIZQT__.TTF"
            local headerSize = option("fontsize_statheaders") or 14
            local headerColor = option("fontcolor_statheaders")

            header.headerText:SetFont(headerFont, headerSize, CCS.textoutline)
            header.headerText:SetTextColor(headerColor[1], headerColor[2], headerColor[3], headerColor[4])

            -- Gradient bars
            local r = secColor[1]
            local g = secColor[2]
            local b = secColor[3]

            local leftStart  = CreateColor(r, g, b, 0.20)
            local leftEnd    = CreateColor(r, g, b, 1.00)
            local rightStart = CreateColor(r, g, b, 1.00)
            local rightEnd   = CreateColor(r, g, b, 0.20)

            if header.leftTex then
                header.leftTex:SetGradient("HORIZONTAL", leftStart, leftEnd)
            end
            if header.rightTex then
                header.rightTex:SetGradient("HORIZONTAL", rightStart, rightEnd)
            end
        end

        -------------------------------------------------
        -- Content rows
        -------------------------------------------------
        for _, row in pairs(rows or {}) do
            -- Left text
            local lf = option("fontname_statname")
            local ls = option("fontsize_statname")
            local lc = option("fontcolor_statname")

            row.leftText:SetFont(lf, ls, CCS.textoutline)
            row.leftText:SetTextColor(lc[1], lc[2], lc[3], lc[4])

            -- Right text
            local rf = option("fontname_stats")
            local rs = option("fontsize_stats")
            local rc = option("fontcolor_stats")

            row.rightText:SetFont(rf, rs, CCS.textoutline)
            row.rightText:SetTextColor(rc[1], rc[2], rc[3], rc[4])

            -- Background
            row.bg:SetColorTexture(.05, .05, .05, 0.6)

            -- Highlight color (based on section color)
            if row.highlight then
                row.highlight:SetColorTexture(secColor[1], secColor[2], secColor[3], 0.3)
            end
        end
    end
end

function module:Initialize(onlyStyle)

    if CCS.AreSecretsDisabled() then 
        CCS.initall = true
        return 
    end
    if UnitLevel("player") < 10 then return end

    -------------------------------------------------
    -- STYLE-ONLY UPDATE
    -------------------------------------------------
    if onlyStyle == true and _G["CCS_stat_sf"] ~= nil then
        ApplyStyle(self)
        UpdateLayout()
        return
    end

    -------------------------------------------------
    -- FULL INITIALIZATION
    -------------------------------------------------
    if option("showcharacterstats") then

        -- Prepare cache tables
        self.sections = self.sections or {}
        self.iLvlFrame = self.iLvlFrame or nil

        CharacterStatsPane.ItemLevelCategory:SetPoint("TOP", CharacterStatsPane, "TOP", -3, -7000)
        CharacterStatsPane.ClassBackground:SetAlpha(0)
        CharacterStatsPane:UnregisterAllEvents()

        -------------------------------------------------
        -- Scroll Frame
        -------------------------------------------------
        local scrollFrame, scrollChild = CreateStatsScrollFrame(rowWidth)
        local sb = CreateStatsScrollBar(scrollFrame)

        self.scrollFrame = scrollFrame
        self.scrollChild = scrollChild

        -------------------------------------------------
        -- iLvl Frame
        -------------------------------------------------
        local btn = CreateAndUpdateiLvlframe(scrollChild)
        self.iLvlFrame = btn
        self.iLvlFrame.fontString = btn.fontString

        -------------------------------------------------
        -- Build Sections
        -------------------------------------------------
        local previousSection = nil
        local sectionSpacing = 7

		local orderedKeys = CCS:GetOrderedSections(STAT_SECTIONS)

		for _, key in ipairs(orderedKeys) do
        --for _, section in ipairs(STAT_SECTIONS) do
			local section = STAT_SECTIONS_BY_KEY[key]
            -------------------------------------------------
            -- Section Frame
            -------------------------------------------------
            local sectionFrameName = "CCS_Section_" .. section.key
            local sectionFrame = _G[sectionFrameName] or CreateFrame("Frame", sectionFrameName, scrollChild, "BackdropTemplate")

            -- Cache section entry
            self.sections[section.key] = self.sections[section.key] or {}
            self.sections[section.key].frame = sectionFrame
            self.sections[section.key].rows = self.sections[section.key].rows or {}
            self.sections[section.key].colorKey = section.colorKey

            local secColor_r, secColor_g, secColor_b = unpack(option(section.colorKey))
            sectionFrame:SetWidth(rowWidth + 4)

            if not previousSection then
                sectionFrame:SetPoint("TOPLEFT", _G["CSPilvl"], "BOTTOMLEFT", 0, -sectionSpacing)
            else
                sectionFrame:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -sectionSpacing)
            end

            if not sectionFrame.bg then
                sectionFrame.bg = sectionFrame:CreateTexture(nil, "BACKGROUND")
                sectionFrame.bg:SetAllPoints()
            end

            sectionFrame:SetBackdrop({
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                edgeSize = 6,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            sectionFrame:SetBackdropBorderColor(.6, .6, .6, 1)

            -------------------------------------------------
            -- Header Row
            -------------------------------------------------
            local headerName = "CCS_Header_" .. section.key
            local header = CreateHeaderRow(sectionFrame, headerName, section)
            header:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)

            -- Cache header
            self.sections[section.key].header = header

            -------------------------------------------------
            -- Content Rows
            -------------------------------------------------
            local previousRow = header
            local totalHeight = header:GetHeight()

            for _, rowData in ipairs(section.rows) do
                local rowFrameName = "CCS_Row_" .. rowData.key
                local row = CreateContentRow(
                    sectionFrame,
                    rowFrameName,
                    rowData.name,
                    rowData.icon,
                    {
                        r = secColor_r or section.color.r,
                        g = secColor_g or section.color.g,
                        b = secColor_b or section.color.b,
                    }
                )

                row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", 0, -rowSpacing)
                previousRow = row
                totalHeight = totalHeight + row:GetHeight() + rowSpacing

                -- Cache row
                self.sections[section.key].rows[rowData.key] = row
            end

            sectionFrame:SetHeight(totalHeight + 3)
            previousSection = sectionFrame
        end

        -------------------------------------------------
        -- Data + Layout
        -------------------------------------------------
        scrollChild:Show()
        UpdateAllStats(scrollChild)
        ApplyStyle(self)
        UpdateLayout()
    end
end

-- Event handler for character stats
function CCS.CharacterStatsEventHandler(event, ...)
    local arg1 = ...

    if CCS.CurrentVersion ~= CCS.RETAIL then return end

    if CCS.initall == true then return end

    if UnitLevel("player") < 10 then return end
    if UnitLevel("player") == 10 and InCombatLockdown() and event == "PLAYER_LEVEL_UP" then CCS.incombat = true return end

    if (event == "UNIT_DAMAGE" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_MAXHEALTH") and arg1 ~= "player" then return end

    if CharacterFrame and not CharacterFrame:IsVisible() 
        and event ~= "PLAYER_LOOT_SPEC_UPDATED" and event ~= "PLAYER_SPECIALIZATION_CHANGED" and event ~= "PLAYER_LOOT_SPEC_UPDATED" and event ~= "CCS_EVENT_CSHOW"
    then return end

    if event == "CCS_EVENT_OPTIONS" then
        if not option("showcharacterstats") then
            CCS:RestoreCharacterStatsPane()
        end
        module:Initialize()
        return true
    end

	if not option("showcharacterstats") then return end
    
    if event == "PLAYER_STARTED_LOOKING" or event == "PLAYER_STARTED_TURNING" or 
       event == "PLAYER_STOPPED_LOOKING" or event == "PLAYER_STOPPED_TURNING" then
        if not InCombatLockdown() and CharacterFrame:IsVisible() then
            UpdateMoveSpeed()
        end
        return
    end

    if not CCS.statsUpdatePending then
        CCS.statsUpdatePending = true
        C_Timer.After(0, function()
            CCS.statsUpdatePending = false
			if _G["CCS_stat_sf"] == nil then
			   module:Initialize()
			end
			UpdateAllStats(_G["CCS_stat_sc"])
			UpdateLayout()
            -- Rebuild the options panel priority slots section for the new spec.
            if event == "PLAYER_SPECIALIZATION_CHANGED" then
                local optFrame = _G["CCS_Options"]
                if optFrame and optFrame:IsShown() then
                    CCS:RefreshOptionsUI()
                end
            end
        end)
    end
end