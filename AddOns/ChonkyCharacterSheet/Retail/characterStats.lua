local addonName, ns = ...
local CCS = ns.CCS

if CCS.GetCurrentVersion() ~= CCS.RETAIL then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table
local module = {
    Name = "characterStats",
    CompatibleVersions = { CCS.RETAIL },
}

CCS.Modules[module.Name] = module

local rowWidth, rowHeight, rowSpacing = 234, 23, 2
local fontsize = 10

local function UpdateMoveSpeed() 
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

-- Blizzard's official DR brackets (percent caps + multipliers)  This is from Blizzard and wowhead.
-- https://www.wowhead.com/guide/diminishing-returns-on-secondary-stats-in-world-of-warcraft
local DR_BRACKETS = {
    {30, 1.00},  -- 0% penalty
    {39, 0.90},  -- 10% penalty
    {47, 0.80},  -- 20% penalty
    {54, 0.70},  -- 30% penalty
    {66, 0.60},  -- 40% penalty
    {126, 0.50}, -- 50% penalty
}

-- Apply diminishing returns to a raw percent value
local function ApplySecondaryDR(rawPercent)
    local remaining = rawPercent
    local effective = 0
    local lastCap = 0

    for _, bracket in ipairs(DR_BRACKETS) do
        if remaining <= 0 then break end

        local cap, mult = bracket[1], bracket[2]
        local slice = math.min(remaining, cap - lastCap)

        effective = effective + slice * mult
        remaining = remaining - slice
        lastCap = cap
    end

    local percentLost = rawPercent - effective
    return effective, percentLost
end

-- Main DR info function
local function GetStatDRInfo(ratingID)
    local rawRating = GetCombatRating(ratingID)

    -- If no rating, no DR applies
    if rawRating <= 0 then
        return {
            rawRating = 0,
            rawPercent1 = 0,
            rawPercent2 = 0,
            effectivePercent1 = 0,
            effectivePercent2 = 0,
            percentLost1 = 0,
            percentLost2 = 0,
            ratingLost = 0,
            effectiveRating = 0,
        }
    end

    local rawPercent1, rawPercent2 = 0, 0
    local ratingPercent1, ratingPercent2 = 0, 0
    local effectivePercent1, effectivePercent2 = 0, 0
    local percentLost1, percentLost2 = 0, 0

    -- Versatility: two bonuses
    if ratingID == CR_VERSATILITY_DAMAGE_DONE then
        -- Rating-derived %
        ratingPercent1 = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
        ratingPercent2 = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN)

        -- Total raw % (rating + buffs)
        rawPercent1 = ratingPercent1 + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
        rawPercent2 = ratingPercent2 + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)

        -- Apply DR to raw %
        effectivePercent1, percentLost1 = ApplySecondaryDR(rawPercent1)
        effectivePercent2, percentLost2 = ApplySecondaryDR(rawPercent2)

    else
        -- Normal secondary stat
        ratingPercent1 = GetCombatRatingBonus(ratingID)
        rawPercent1 = ratingPercent1

        effectivePercent1, percentLost1 = ApplySecondaryDR(rawPercent1)
    end

    -- Convert % lost → rating lost (must use rating-derived % only)
    local percentPerRating = ratingPercent1 / rawRating
    local ratingLost = percentLost1 / percentPerRating
    local effectiveRating = rawRating - ratingLost

    return {
        rawRating = rawRating,
        rawPercent1 = rawPercent1,
        rawPercent2 = rawPercent2,
        effectivePercent1 = effectivePercent1,
        effectivePercent2 = effectivePercent2,
        percentLost1 = percentLost1,
        percentLost2 = percentLost2,
        ratingLost = ratingLost,
        effectiveRating = effectiveRating,
    }
end

local function GetDRBracketProgress(rawPercent, ratingPerPercent)
    local lastCap = 0
    for _, bracket in ipairs(DR_BRACKETS) do
        local cap = bracket[1]
        if rawPercent <= cap then
            local startP = lastCap
            local endP = cap

            local startR = startP * ratingPerPercent
            local endR   = endP * ratingPerPercent
            local currentR = rawPercent * ratingPerPercent

            return {
                bracketStartPercent = startP,
                bracketEndPercent   = endP,
                bracketStartRating  = startR,
                bracketEndRating    = endR,
                ratingIntoBracket   = currentR - startR,
                ratingRemaining     = endR - currentR,
            }
        end
        lastCap = cap
    end
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

local StatOrder = {"CriticalStrike","Haste","Mastery","Versatility"}

local StatMap = {
    Mastery       = {name=ITEM_MOD_MASTERY_RATING_SHORT, rating=CR_MASTERY},
    CriticalStrike= {name=ITEM_MOD_CRIT_RATING_SHORT,    rating=CR_CRIT_SPELL},
    Haste         = {name=ITEM_MOD_HASTE_RATING_SHORT,   rating=CR_HASTE_SPELL},
    Versatility   = {name=STAT_VERSATILITY,              rating=CR_VERSATILITY_DAMAGE_DONE},
}

local cachedPriorityLookup = {
    Mastery = 1,
    CriticalStrike = 2,
    Haste = 3,
    Versatility = 4,
}

local function GetSortedStats(classID, specID, heroID)
    if not classID or not specID or not heroID or not option("show_secondarypriority") then
        -- return default order with dummy priorities
        local fallback = {}
        for i,stat in ipairs(StatOrder) do
            table.insert(fallback, {
                stat   = stat,
                prio   = i,
                tie    = i,
                name   = StatMap[stat].name,
                rating = StatMap[stat].rating,
            })
        end
        return fallback
    end

    local classTable = CCS.ClassSpecStatPriority[classID]
    if not classTable then return StatOrder end

    local specTable = classTable[specID]
    if not specTable then return StatOrder end

    local priorities = specTable[heroID]
    if not priorities then return StatOrder end

    -- build array of {statName, priority, tieIndex, localized name, rating constant}
    local stats = {
        {stat="Mastery",        prio=priorities[1], tie=1, name=StatMap.Mastery.name,        rating=StatMap.Mastery.rating},
        {stat="CriticalStrike", prio=priorities[2], tie=2, name=StatMap.CriticalStrike.name, rating=StatMap.CriticalStrike.rating},
        {stat="Haste",          prio=priorities[3], tie=3, name=StatMap.Haste.name,          rating=StatMap.Haste.rating},
        {stat="Versatility",    prio=priorities[4], tie=4, name=StatMap.Versatility.name,    rating=StatMap.Versatility.rating},
    }

    table.sort(stats, function(a,b)
        if a.prio == b.prio then
            return a.tie < b.tie
        else
            return a.prio < b.prio
        end
    end)

    -- update the cached lookup table
    cachedPriorityLookup = {
        [stats[1].stat] = stats[1].prio,
        [stats[2].stat] = stats[2].prio,
        [stats[3].stat] = stats[3].prio,
        [stats[4].stat] = stats[4].prio,
    }

    return stats
end

local function BuildDRTooltip(DRtable)
    if not DRtable or option("show_diminishing_returns") ~= true then
        return ""
    end

    local out = {}

    -- Effective rating and percent
    table.insert(out, format("\n   %s%s: %d [+%.2f%%]|r",
        "|cff68ccef", L["STAT_DR_EFFECTIVE"] or "Effective",
        BreakUpLargeNumbers(DRtable.effectiveRating),
        DRtable.effectivePercent1))

    -- Lost rating and percent
    table.insert(out, format("\n   %s%s: %d [+%.2f%%]|r",
        "|cffff5555", L["LOST"] or "Lost",
        BreakUpLargeNumbers(DRtable.ratingLost),
        DRtable.percentLost1))

    -- Label
    table.insert(out, format("\n   %s(%s)|r",
        "|cff9d9d9d", L["STAT_DR_LABEL"] or "After diminishing returns"))

    -- Bracket progress
    local ratingPerPercent = DRtable.rawRating / DRtable.rawPercent1
    if DRtable.rawRating > 0 and ratingPerPercent < math.huge then
        local bracket = GetDRBracketProgress(DRtable.rawPercent1, ratingPerPercent)

        if bracket then
            table.insert(out, "\n\n|cffffd100"..(L["Diminishing Returns Bracket"] or "Diminishing Returns Bracket").."|r")

            table.insert(out, format("\n  %s%.2f%% – %.2f%%|r",
                "|cffbbbbbb", bracket.bracketStartPercent, bracket.bracketEndPercent))

            table.insert(out, format("\n  %s%s: %d – %d|r",
                "|cffcccccc", L["Rating range"] or "Rating range",
                BreakUpLargeNumbers(bracket.bracketStartRating),
                BreakUpLargeNumbers(bracket.bracketEndRating)))

            table.insert(out, format("\n  %s%s: %d %s|r",
                "|cff00d100", L["Into bracket"] or "Into bracket",
                BreakUpLargeNumbers(bracket.ratingIntoBracket), L["rating"] or "rating"))

            table.insert(out, format("\n  %s%s: %d %s|r",
                "|cffffa040", L["Until next bracket"] or "Until next bracket",
                BreakUpLargeNumbers(bracket.ratingRemaining), L["rating"] or "rating"))
        end
    end

    return table.concat(out)
end


-------------------------------------------------
-- ATTRIBUTE STAT FUNCTIONS
-------------------------------------------------
local function GetStatPrimary(rowData) 
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
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

	isZero = (tmp_stat_value == 0)

	leftText=tmp_stat_name[primaryStat]
	rightText=BreakUpLargeNumbers(tmp_stat_value)
	
	stat = tmp_stat_value;
	
	local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
	statIndex = primaryStat;
	-- Set the tooltip text
	
	local tooltipText = ""
	
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		tt_name = tt_name..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		tt_name = tooltipText;
		
		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
		end
	end

	-- Strength
	if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
		local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
		if (HasAPEffectsSpellPower()) then
			tt_desc = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
			tt_desc = format(tt_desc, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) then
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
		local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
		local tooltip4 = STAT_TOOLTIP_BONUS_AP;
		if (HasAPEffectsSpellPower()) then
			tooltip4 = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
			tt_desc = format(tooltip4, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) then
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
		if ( UnitHasMana("player") ) then
			if (HasAPEffectsSpellPower()) then
				tt_desc = STAT_NO_BENEFIT_TOOLTIP;
			else
				local result, druid = HasSPEffectsAttackPower();
				if (result and druid) then
					tt_desc = format(STAT_TOOLTIP_SP_AP_DRUID, max(0, effectiveStat), max(0, effectiveStat));
				elseif (result) then
					tt_desc = format(STAT_TOOLTIP_BONUS_AP_SP, max(0, effectiveStat));
				elseif (not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT) then
					tt_desc = format(tt_desc, max(0, effectiveStat));
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local statIndex = 3 -- Stamina
	local tmp_stat_value, effectiveStat = UnitStat("player", statIndex);
					
	isZero = (tmp_stat_value == 0)
	
	leftText=format("%s", ITEM_MOD_STAMINA_SHORT)
	rightText=BreakUpLargeNumbers(tmp_stat_value)
	
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	local hpperstam = 20
	local maxhealthmod = 1
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;
	tt_desc = tt_desc .. format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], BreakUpLargeNumbers(((effectiveStat*hpperstam))*maxhealthmod));                
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatHealth(rowData) 
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local health = UnitHealthMax("player");
	local healthText = BreakUpLargeNumbers(health);

	isZero = (health == 0)

	leftText=HEALTH
	rightText=healthText
		
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
	tt_desc = STAT_HEALTH_TOOLTIP;

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatPower(rowData)
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local powerType, powerToken, altR, altG, altB = UnitPowerType("player")
	local power = UnitPowerMax("player") or 0;
	local powerText = BreakUpLargeNumbers(power);
	isZero = (power == 0)
	leftText=CCS.POWER_TYPES_TABLE[powerType]
	rightText=powerText
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, (powerToken or "")).." "..(powerText or "") .. FONT_COLOR_CODE_CLOSE;
	tt_desc = _G["STAT_"..(powerToken or "") .."_TOOLTIP"];
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatGCD(rowData)
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil

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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil	
	local extraCritChance = GetCombatRatingBonus(CR_CRIT_SPELL)
	local extraCritRating = GetCombatRating(CR_CRIT_SPELL)
	local prio = cachedPriorityLookup["CriticalStrike"]
	isZero = (extraCritRating == 0)
	if option("show_secondarypriority") == true then
		leftText=prio.." "..ITEM_MOD_CRIT_RATING_SHORT
	else
		leftText=ITEM_MOD_CRIT_RATING_SHORT	
	end
	rightText=format('(%s%%) %6.6s',
		CCS.round(GetSpellCritChance('player')),
		BreakUpLargeNumbers(GetCombatRating(CR_CRIT_SPELL)))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE)..FONT_COLOR_CODE_CLOSE
	
	if GetCritChanceProvidesParryEffect() then
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil	
	local _, class = UnitClass("player")
	local prio = cachedPriorityLookup["Haste"]
	local hasteRating = GetCombatRating(CR_HASTE_SPELL)
	local hasteBonus = UnitSpellHaste('player')
	isZero = (hasteRating == 0)

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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local _, class = UnitClass("player")
	local mastery, bonusCoeff = GetMasteryEffect()
	local masteryRating = GetCombatRating(CR_MASTERY)
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff
	local primaryTalentTree = GetSpecialization()
	local prio = cachedPriorityLookup["Mastery"]
	isZero = (masteryRating == 0)
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
	local prio = cachedPriorityLookup["Versatility"]
	isZero = (versatility == 0)
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
		local ratingPerPercent = DRtable.rawRating / DRtable.rawPercent1
		
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
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
	isZero = (base == 0)
	rightText = BreakUpLargeNumbers(base)
	
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed("player");
	local displaySpeed = format("%.2fs", speed);
	isZero = (speed == 0)
	if offhandSpeed then displaySpeed = format("%s / %.2fs", displaySpeed , offhandSpeed); end
	
	leftText = format("%s", STAT_ATTACK_SPEED)
	rightText = displaySpeed
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste));	
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatSpellPower(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local spellPower = GetSpellBonusDamage(2)
	isZero = (spellPower == 0)
	
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor("player");
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel("player"));
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);
	isZero = (effectiveArmor == 0)
	
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local chance = GetDodgeChance();
	isZero = (chance == 0)
	
	leftText=format("%s", ITEM_MOD_DODGE_RATING_SHORT)
	rightText=format("%s%%", CCS.round(chance))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatParry(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local chance = GetParryChance();
	isZero = (chance == 0)
		
	leftText=format("%s", ITEM_MOD_PARRY_RATING_SHORT)
	rightText=format("%s%%", CCS.round(chance))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatBlock(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local chance = GetBlockChance();
	local shieldBlockArmor = GetShieldBlock();
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel("player"));
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor);
	isZero = (chance == 0)
	
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
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage("player");
	isZero = (stagger == 0)
	
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
    local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
    local link = nil

    local percent, totalCost = GetTotalDurabilityAndRepairCost()
	isZero = (percent == 100)

    leftText = DURABILITY
	if totalCost > 0 then
		rightText = string.format("(%.2f%%) : %s", percent, FormatRepairCost(totalCost))
	else
		rightText = string.format("(%.2f%%)", percent)
	end
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatLeech(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local leechRating = GetCombatRating(CR_LIFESTEAL)
	local lifesteal = GetLifesteal();
	isZero = (lifesteal == 0)
	leftText=format("%s", ITEM_MOD_CR_LIFESTEAL_SHORT)
	rightText=format('(%s%%) %6.6s',CCS.round(GetLifesteal()), BreakUpLargeNumbers(leechRating))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2F%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(leechRating), GetCombatRatingBonus(CR_LIFESTEAL));
	local DRtable = GetStatDRInfo(CR_LIFESTEAL)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)

	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatAvoidance(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local avoidance = GetAvoidance();
	local avoidRating = GetCombatRating(CR_AVOIDANCE)
	isZero = (avoidRating == 0)
		
	leftText=format("%s", ITEM_MOD_CR_AVOIDANCE_SHORT)
	rightText=format('(%s%%) %6.6s',CCS.round(GetCombatRatingBonus(CR_AVOIDANCE)), BreakUpLargeNumbers(avoidRating))
	
	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2F%%", avoidance) .. FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(avoidRating), GetCombatRatingBonus(CR_AVOIDANCE));
	local DRtable = GetStatDRInfo(CR_AVOIDANCE)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatSpeed(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local speedRating = GetCombatRating(CR_SPEED)
	local speed = GetSpeed();
	isZero = (speedRating == 0)

	leftText=format("%s", ITEM_MOD_CR_SPEED_SHORT)
	rightText=format('(%s%%) %6.6s',CCS.round(GetCombatRatingBonus(CR_SPEED)), BreakUpLargeNumbers(speedRating))
	tt_name = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED) .. " " .. format("%.2F%%", speed) .. FONT_COLOR_CODE_CLOSE;
	tt_desc = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(speedRating), GetCombatRatingBonus(CR_SPEED));
	local DRtable = GetStatDRInfo(CR_SPEED)
    tt_desc = tt_desc .. BuildDRTooltip(DRtable)
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

local function GetStatMovespeed(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil

	leftText=format("%s", STAT_MOVEMENT_SPEED)
	rightText = UpdateMoveSpeed()
	
	return leftText, rightText, tt_name, tt_desc, link, isZero
end

-------------------------------------------------
-- CURRENCY STAT FUNCTION (CRESTS + PVP)
-------------------------------------------------
local function GetStatCurrency(rowData)  
	local leftText, rightText, tt_name, tt_desc, isZero = "","","","",false
	local link = nil
	local currencyData = nil
	
	if C_CurrencyInfo then 
		currencyData = C_CurrencyInfo.GetCurrencyInfo(rowData.id) 
		link = C_CurrencyInfo.GetCurrencyLink(rowData.id)		
	else
		currencyData = GetCurrencyInfo(rowData.id) 
		link = GetCurrencyLink(rowData.id)				
	end
	
	if currencyData ~= nil then
		leftText = currencyData.name
		--isZero = (currencyData.quantity == 0)
		--if currencyData.useTotalEarnedForMaxQty == true or 
		if rowData.id == 1586 or
			rowData.id == 1602 or
			rowData.id == 2123 or
			rowData.id == 2797
		then
				rightText = format("%8.8s", BreakUpLargeNumbers(currencyData.quantity))
		else
			if rowData.id == 3008 or rowData.id == 1792 or rowData.id == 3378 then
				rightText = format("%s/%s", BreakUpLargeNumbers(currencyData.quantity), BreakUpLargeNumbers(currencyData.maxQuantity))			
			elseif currencyData.maxQuantity == 0 then
				rightText = format("%s", BreakUpLargeNumbers(currencyData.quantity))
			else
				rightText = format("%s (%s/%s)", BreakUpLargeNumbers(currencyData.quantity), BreakUpLargeNumbers(currencyData.totalEarned), BreakUpLargeNumbers(currencyData.maxQuantity))			
			end
			
		end
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
            { key="crests_myth",       name=L["Myth"]        or "Myth",        id=3347, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_myth" },
            { key="crests_hero",       name=L["Hero"]        or "Hero",        id=3345, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_hero" },
            { key="crests_champion",   name=L["Champion"]    or "Champion",    id=3343, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_champion" },
            { key="crests_veteran",    name=L["Veteran"]     or "Veteran",     id=3341, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_veteran" },
            { key="crests_adventurer", name=L["Adventurer"]  or "Adventurer",  id=3383, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_adventurer" },
            { key="crests_catalyst", name=L["Catalyst"]  or "Catalyst",  id=3378, statFunc=GetStatCurrency, icon="Interface\\Icons\\inv_120_crest_adventurer" },
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

local SecondaryKeyToStat = {
    secondary_crit        = "CriticalStrike",
    secondary_haste       = "Haste",
    secondary_mastery     = "Mastery",
    secondary_versatility = "Versatility",
}

local function GetSortedSecondaryRows(section)
    if not option("show_secondarypriority") then
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

local function UpdateLayout()
    local previousSection = nil
    local sectionSpacing = 7
    local rowSpacing = 2

    for _, section in ipairs(STAT_SECTIONS) do
        local sectionFrame = _G["CCS_Section_" .. section.key]
        local header       = _G["CCS_Header_" .. section.key]
		if sectionFrame then
			-- Section hidden entirely
			if not option(section.showKey) then
				sectionFrame:Hide()

			else
				sectionFrame:Show()

				-------------------------------------------------
				-- Determine collapse state
				-------------------------------------------------
				local isCollapsed = header.isCollapsed == true

				-------------------------------------------------
				-- Anchor section in the vertical chain
				-------------------------------------------------
				sectionFrame:ClearAllPoints()
				if not previousSection then
					sectionFrame:SetPoint("TOPLEFT", _G["CSPilvl"], "BOTTOMLEFT", 0, -sectionSpacing)
				else
					sectionFrame:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -sectionSpacing)
				end

				-------------------------------------------------
				-- Determine header visibility (Option C)
				-------------------------------------------------
				local showHeader = isCollapsed or option("show_headers") ~= false

				local previousRow
				local totalHeight

				if showHeader then
					header:Show()
					header:ClearAllPoints()
					header:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)

					previousRow = header
					totalHeight = header:GetHeight()
				else
					header:Hide()

					-- First visible row will attach to sectionFrame TOPLEFT
					previousRow = nil
					totalHeight = 0
				end

				-------------------------------------------------
				-- Determine row order (secondary stat priority)
				-------------------------------------------------
				local rows = section.rows
				if section.key == "SECONDARY" then
					rows = GetSortedSecondaryRows(section)
				end

				-------------------------------------------------
				-- COLLAPSED SECTION
				-------------------------------------------------
				if isCollapsed then
					for _, rowData in ipairs(rows) do
						local row = _G["CCS_Row_" .. rowData.key]
						row:Hide()
					end

					sectionFrame:SetHeight(totalHeight + 3)
					previousSection = sectionFrame

				-------------------------------------------------
				-- EXPANDED SECTION
				-------------------------------------------------
				else
					for _, rowData in ipairs(rows) do
						local row = _G["CCS_Row_" .. rowData.key]
						local shouldHide = (option("show_hide_zero_stats") == true) and (row.isZero == true)
						
						-------------------------------------------------
						-- Icon visibility
						-------------------------------------------------
						if option("show_stat_icons") == true then
							row.leftText:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
							row.icon:Show()
						else
							row.leftText:SetPoint("LEFT", row, "LEFT", 2, 0)
							row.icon:Hide()
						end

						-------------------------------------------------
						-- Row visibility
						-------------------------------------------------
						if option(rowData.key) ~= false and not shouldHide then
							row:Show()
							row:ClearAllPoints()

							if previousRow then
								row:SetPoint("TOPLEFT", previousRow, "BOTTOMLEFT", 0, -rowSpacing)
							else
								-- First visible row in this section
								row:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)
							end

							previousRow = row
							totalHeight = totalHeight + row:GetHeight() + rowSpacing
						else
							row:Hide()
						end
					end

					sectionFrame:SetHeight(totalHeight + 3)
					previousSection = sectionFrame
				end
			end
		end
    end
	----------------------------------------------------------------------
	-- See if we need to show/hide the scrollbar after the layout changes.
	----------------------------------------------------------------------
	C_Timer.After(0, function()
			if 	_G["CCS_stat_sf"] ~= nil and 
				_G["CCS_stat_sfScrollBar"] ~= nil and 
				_G["CCS_stat_sf"]:GetVerticalScrollRange() > 0 
			then 
				_G["CCS_stat_sfScrollBar"]:Show() 
			elseif _G["CCS_stat_sfScrollBar"] ~= nil then
				_G["CCS_stat_sfScrollBar"]:Hide() 
			end	
	end)

end

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

    if not row.initializedClick then
        row:SetScript("OnMouseDown", function(self, button)
			if IsControlKeyDown() and button == "LeftButton" then
				local def = CCS:GetOptionDefByKey(section.collapseKey)
				if def then
					CCS:UpdateOption(def, self.isCollapsed)
					C_Timer.After(.1, function() CCS:LoadOptions() end)
				end

			else
				-- Toggle collapse state
				self.isCollapsed = not self.isCollapsed

				-- Update expand/collapse +
				if self.chevron then
					if self.isCollapsed then
						-- collapsed
						self.chevron:SetTexCoord(0, 0.5, 0, 0.5)
						self.chevron:SetAlpha(1)					
					else
						-- expanded
						self.chevron:SetTexCoord(0.5, 1, 0, 0.5)
						self.chevron:SetAlpha(.3)
					end
				end
				
			end
			PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
            -- Rebuild layout
            UpdateLayout()
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
	
	if option("show_secondarypriority") and section.key == "SECONDARY" then
		row.headerText:SetText(L["Secondary (Priority)"])
	else
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

		avgItemLevelEquipped = format("%.2f", avgItemLevelEquipped)
		avgItemLevel = format("%.2f", avgItemLevel)
		avgItemLevelPvP = format("%.2f", avgItemLevelPvP)

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

local function UpdateAllStats(parent)

    CreateAndUpdateiLvlframe(parent)

    local mode = option("long_text_handling")  -- "Full Text", "Truncate", "Wrap Text"

    for _, sectionData in ipairs(STAT_SECTIONS) do
        local sectionFrame = _G["CCS_Section_" .. sectionData.key]
        if sectionFrame then

            for _, rowData in ipairs(sectionData.rows) do
                local rowFrame = _G["CCS_Row_" .. rowData.key]
                if rowFrame then

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
                        local currencyData
                        if C_CurrencyInfo then
                            currencyData = C_CurrencyInfo.GetCurrencyInfo(rowData.id)
                            link = C_CurrencyInfo.GetCurrencyLink(rowData.id)
                        else
                            currencyData = GetCurrencyInfo(rowData.id)
                            link = GetCurrencyLink(rowData.id)
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
                    if rowFrame.leftText then
                        local fs = rowFrame.leftText
                        local text = leftText or ""
						
						-- Compute max label width
						local reservedRightWidth = rowFrame.rightText:GetStringWidth()+4
						local MAX_LABEL_WIDTH =
							rowFrame:GetWidth()
							- rowFrame.icon:GetWidth()
							- 2 - 6 - reservedRightWidth - 6
						fs:SetText(text)
						local naturalWidth = fs:GetStringWidth()
						-- ALWAYS set width + justification first
						fs:SetWidth(MAX_LABEL_WIDTH)
						fs:SetJustifyH("LEFT")
						fs:SetJustifyV("MIDDLE")
						fs:SetNonSpaceWrap(true) 
						
                        if mode == "Full Text" then
                            fs:SetWidth(0)
                            fs:SetWordWrap(false)
                            fs:SetMaxLines(1)
                            fs:SetText(text)
                        elseif mode == "Truncate" then
							fs:SetWidth(MAX_LABEL_WIDTH)
                            fs:SetWordWrap(false)
                            fs:SetMaxLines(1)
							if naturalWidth > MAX_LABEL_WIDTH then
								fs:SetText(TruncateToWidth(fs, text, MAX_LABEL_WIDTH))
							end
                        elseif mode == "Wrap Text" then
                            fs:SetWidth(MAX_LABEL_WIDTH)
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
						
                    end

                    -------------------------------------------------
                    -- Tooltip
                    -------------------------------------------------
					rowFrame:SetScript("OnEnter", function(self)
						local rd = rowData

						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

						if link then
							GameTooltip:SetHyperlink(link)
						else
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
------------------------------------------
-- Make this into a minimal scroll bar.
------------------------------------------
local function SetupScrollBar()		
		local sb =  _G["CCS_stat_sfScrollBar"]
		-- Hide the stepper buttons
		sb.ScrollUpButton:Hide()
		sb.ScrollDownButton:Hide()
		sb:SetWidth(10)
		sb:SetPoint("TOPLEFT", _G["CCS_stat_sf"], "TOPRIGHT", 2,-16)
		sb:SetPoint("BOTTOMLEFT", _G["CCS_stat_sf"], "BOTTOMRIGHT", 2,16)

		-- Hide background textures
		if sb.Background then sb.Background:Hide() end
		if sb.Track then sb.Track:Hide() end

		-- Minimal thumb
		local thumb = sb:GetThumbTexture()
		thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
		thumb:SetColorTexture(.4, .4, .4, 0.7)
		thumb:SetWidth(6)

		local up   = CCS_stat_sfScrollBarScrollUpButton
		local down = CCS_stat_sfScrollBarScrollDownButton

		-- UP BUTTON
		up:SetSize(17, 11)

		up.Normal:ClearAllPoints()
		up.Normal:SetAllPoints()
		up.Normal:SetTexCoord(0, 1, 0, 1)
		up.Normal:SetAtlas("minimal-scrollbar-arrow-top", true)

		up.Highlight:ClearAllPoints()
		up.Highlight:SetAllPoints()
		up.Highlight:SetTexCoord(0, 1, 0, 1)
		up.Highlight:SetAtlas("minimal-scrollbar-arrow-top-over", true)

		up.Pushed:ClearAllPoints()
		up.Pushed:SetAllPoints()
		up.Pushed:SetTexCoord(0, 1, 0, 1)
		up.Pushed:SetAtlas("minimal-scrollbar-arrow-top-down", true)

		up.Disabled:ClearAllPoints()
		up.Disabled:SetAllPoints()
		up.Disabled:SetTexCoord(0, 1, 0, 1)
		up.Disabled:SetAtlas("minimal-scrollbar-arrow-top", true)

		-- DOWN BUTTON
		down:SetSize(17, 11)

		down.Normal:ClearAllPoints()
		down.Normal:SetAllPoints()
		down.Normal:SetTexCoord(0, 1, 0, 1)
		down.Normal:SetAtlas("minimal-scrollbar-arrow-bottom", true)

		down.Highlight:ClearAllPoints()
		down.Highlight:SetAllPoints()
		down.Highlight:SetTexCoord(0, 1, 0, 1)
		down.Highlight:SetAtlas("minimal-scrollbar-arrow-bottom-over", true)

		down.Pushed:ClearAllPoints()
		down.Pushed:SetAllPoints()
		down.Pushed:SetTexCoord(0, 1, 0, 1)
		down.Pushed:SetAtlas("minimal-scrollbar-arrow-bottom-down", true)

		down.Disabled:ClearAllPoints()
		down.Disabled:SetAllPoints()
		down.Disabled:SetTexCoord(0, 1, 0, 1)
		down.Disabled:SetAtlas("minimal-scrollbar-arrow-bottom", true)
end

function module:Initialize()
    if UnitLevel("player") < 10 then return end
    
    if option("showcharacterstats") then
        CharacterStatsPane.ItemLevelCategory:SetPoint("TOP", CharacterStatsPane, "TOP", -3, -7000)
        CharacterStatsPane.ClassBackground:SetAlpha(0)
        CharacterStatsPane:UnregisterAllEvents()

        -- Just a little code to create a scrolling frame to house the stats.  That way we can scroll if we resize the character frame.
        local scrollFrame = _G["CCS_stat_sf"] or CreateFrame("ScrollFrame", "CCS_stat_sf", CharacterStatsPane, "UIPanelScrollFrameTemplate, BackdropTemplate")
        scrollFrame:ClearAllPoints()
        scrollFrame:SetPoint("TOPLEFT", CharacterStatsPane, "TOPLEFT", 10, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", CharacterStatsPane, "BOTTOMRIGHT", -12, 5)
        scrollFrame:Show()
        
        local scrollChild = _G["CCS_stat_sc"] or CreateFrame("Frame", "CCS_stat_sc", scrollFrame )
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetWidth(rowWidth)
        scrollChild:SetHeight(1)
        scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
        
		SetupScrollBar()
		
        if scrollFrame:GetVerticalScrollRange() > 0 then  CCS_stat_sfScrollBar:Show() else CCS_stat_sfScrollBar:Hide() end

		-------------------------------------------------
		-- Build iLvl Frame
		-------------------------------------------------
		CreateAndUpdateiLvlframe(scrollChild)

		-------------------------------------------------
		-- Build Sections
		-------------------------------------------------
		local previousSection = nil
		local sectionSpacing = 7

		for _, section in ipairs(STAT_SECTIONS) do
				-------------------------------------------------
				-- Section Frame
				-------------------------------------------------
				local sectionFrameName = "CCS_Section_" .. section.key
				local sectionFrame = _G[sectionFrameName] or CreateFrame("Frame", sectionFrameName, scrollChild, "BackdropTemplate")
				local secColor_r, secColor_g, secColor_b, secColor_a = unpack(option(section.colorKey))
				sectionFrame:SetWidth(rowWidth + 4)
				
				if not previousSection then
					sectionFrame:SetPoint("TOPLEFT", _G["CSPilvl"], "BOTTOMLEFT", 0, -sectionSpacing)
				else
					sectionFrame:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -sectionSpacing)
				end

				sectionFrame:SetBackdrop({
					edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
					edgeSize = 6,
					insets = { left = 2, right = 2, top = 2, bottom = 2 }
				})
				sectionFrame:SetBackdropBorderColor(.6, .6, .6, 1)

				if not sectionFrame.bg then
					sectionFrame.bg = sectionFrame:CreateTexture(nil, "BACKGROUND")
				end
				sectionFrame.bg:SetAllPoints()
				sectionFrame.bg:SetColorTexture(secColor_r or section.color.r, secColor_g or section.color.g, secColor_b or section.color.b, 0.2)

				-------------------------------------------------
				-- Header Row
				-------------------------------------------------
				local headerName = "CCS_Header_" .. section.key
				local header = CreateHeaderRow(sectionFrame, headerName, section)
				header:SetPoint("TOPLEFT", sectionFrame, "TOPLEFT", 0, 0)

				-------------------------------------------------
				-- Content Rows (Chained)
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
				end

				-------------------------------------------------
				-- Resize section frame to fit rows
				-------------------------------------------------
				sectionFrame:SetHeight(totalHeight + 3)

				previousSection = sectionFrame
		end
		
		scrollChild:Show()
		UpdateAllStats(scrollChild)
		UpdateLayout()

	end
end



-- Event handler for character stats
function CCS.CharacterStatsEventHandler(event, ...)
    local arg1 = ...

    if CCS.GetCurrentVersion() ~= CCS.RETAIL then return end
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
        end)
    end
end