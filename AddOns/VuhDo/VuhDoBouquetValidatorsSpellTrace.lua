local _;

local GetTime = GetTime;

local VUHDO_getSpellTraceForUnit;
local VUHDO_getSpellTraceIncomingForUnit;
local VUHDO_getSpellTraceHealForUnit;
local VUHDO_getSpellTraceTrailOfLightForUnit;
local VUHDO_isSpellTraceTrailOfLightNextUnit;
local VUHDO_getAoeAdviceForUnit;


----------------------------------------------------------



function VUHDO_bouquetValidatorsSpellTraceInitLocalOverrides()

	VUHDO_getSpellTraceForUnit = _G["VUHDO_getSpellTraceForUnit"];
	VUHDO_getSpellTraceIncomingForUnit = _G["VUHDO_getSpellTraceIncomingForUnit"];
	VUHDO_getSpellTraceHealForUnit = _G["VUHDO_getSpellTraceHealForUnit"];
	VUHDO_getSpellTraceTrailOfLightForUnit = _G["VUHDO_getSpellTraceTrailOfLightForUnit"];
	VUHDO_isSpellTraceTrailOfLightNextUnit = _G["VUHDO_isSpellTraceTrailOfLightNextUnit"];
	VUHDO_getAoeAdviceForUnit = _G["VUHDO_getAoeAdviceForUnit"];

end



----------------------------------------------------------



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom



--
local tInfo;
local function VUHDO_spellTraceValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceForUnit(anInfo["unit"]);

	if tInfo then
		if tInfo["startTime"] then
			local tCurrentTime = GetTime();
			local tDuration;
			
			if tInfo["isIncoming"] then
				-- castTime is in ms, convert to seconds
				tDuration = tInfo["castTime"] / 1000;
				local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

				if tRemaining > 0 then
					return true, tInfo["icon"], tRemaining, -1, tDuration;
				else
					return false, nil, -1, -1, -1;
				end
			else
				-- non-incoming spell traces - no duration tracking
				--[[
				local tSpellId = tInfo["spellId"];
				if tSpellId and sSpellTraceStoredSettings[tSpellId] then
					tDuration = tonumber(sSpellTraceStoredSettings[tSpellId]["duration"] or sSpellTraceDefaultDuration) or sSpellTraceDefaultDuration;
				else
					tDuration = sSpellTraceDefaultDuration;
				end

				local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

				if tRemaining > 0 then
					return true, tInfo["icon"], tRemaining, -1, tDuration;
				else
					return false, nil, -1, -1, -1;
				end
				--]]
				return true, tInfo["icon"], 0, -1, 0;
			end
		else
			return true, tInfo["icon"], -1, -1, -1;
		end
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tInfo;
local function VUHDO_spellTraceIncomingValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceIncomingForUnit(anInfo["unit"]);

	if tInfo then
		if tInfo["isIncoming"] and tInfo["castTime"] and tInfo["startTime"] then
			local tCurrentTime = GetTime();
			local tDuration = tInfo["castTime"] / 1000; -- castTime is in ms, convert to seconds
			local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

			if tRemaining > 0 then
				return true, tInfo["icon"], tRemaining, -1, tDuration;
			else
				return false, nil, -1, -1, -1;
			end
		else
			return true, tInfo["icon"], -1, -1, -1;
		end
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tInfo;
local function VUHDO_spellTraceHealValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceHealForUnit(anInfo["unit"]);

	if tInfo then
		if tInfo["startTime"] then
			local tCurrentTime = GetTime();
			local tDuration;
			
			if tInfo["isIncoming"] then
				-- castTime is in ms, convert to seconds
				tDuration = tInfo["castTime"] / 1000;
				local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

				if tRemaining > 0 then
					return true, tInfo["icon"], tRemaining, -1, tDuration;
				else
					return false, nil, -1, -1, -1;
				end
			else
				-- non-incoming spell traces - no duration tracking
				--[[
				local tSpellId = tInfo["spellId"];
				if tSpellId and sSpellTraceStoredSettings[tSpellId] then
					tDuration = tonumber(sSpellTraceStoredSettings[tSpellId]["duration"] or sSpellTraceDefaultDuration) or sSpellTraceDefaultDuration;
				else
					tDuration = sSpellTraceDefaultDuration;
				end

				local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

				if tRemaining > 0 then
					return true, tInfo["icon"], tRemaining, -1, tDuration;
				else
					return false, nil, -1, -1, -1;
				end
				--]]
				return true, tInfo["icon"], 0, -1, 0;
			end
		else
			return true, tInfo["icon"], -1, -1, -1;
		end
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tInfo;
local function VUHDO_spellTraceSingleValidator(anInfo, aCustom)

	if aCustom and aCustom["custom"] and aCustom["custom"]["spellTrace"] and aCustom["custom"]["spellTrace"] ~= "" then
		tInfo = VUHDO_getSpellTraceForUnit(anInfo["unit"], aCustom["custom"]["spellTrace"]);

		if tInfo then
			if tInfo["startTime"] then
				local tCurrentTime = GetTime();
				local tDuration;
				
				if tInfo["isIncoming"] then
					-- castTime is in ms, convert to seconds
					tDuration = tInfo["castTime"] / 1000;
					local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

					if tRemaining > 0 then
						return true, tInfo["icon"], tRemaining, -1, tDuration;
					else
						return false, nil, -1, -1, -1;
					end
				else
					-- non-incoming spell traces - no duration tracking
					--[[
					local tSpellId = tInfo["spellId"];
					if tSpellId and sSpellTraceStoredSettings[tSpellId] then
						tDuration = tonumber(sSpellTraceStoredSettings[tSpellId]["duration"] or sSpellTraceDefaultDuration) or sSpellTraceDefaultDuration;
					else
						tDuration = sSpellTraceDefaultDuration;
					end

					local tRemaining = tDuration - (tCurrentTime - tInfo["startTime"]);

					if tRemaining > 0 then
						return true, tInfo["icon"], tRemaining, -1, tDuration;
					else
						return false, nil, -1, -1, -1;
					end
					--]]
					return true, tInfo["icon"], 0, -1, 0;
				end
			else
				return true, tInfo["icon"], -1, -1, -1;
			end
		end
	end

	return false, nil, -1, -1, -1;

end



--
local tInfo;
local function VUHDO_trailOfLightValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceTrailOfLightForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local function VUHDO_trailOfLightNextValidator(anInfo, _)

	return VUHDO_isSpellTraceTrailOfLightNextUnit(anInfo["unit"]), nil, -1, -1, -1;

end



--
local tInfo;
local function VUHDO_aoeAdviceValidator(anInfo, _)
	tInfo = VUHDO_getAoeAdviceForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local VUHDO_BOUQUET_BUFFS_SPECIAL_SPELL_TRACE = {
	["SPELL_TRACE"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE,
		["validator"] = VUHDO_spellTraceValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["SPELL_TRACE_INCOMING"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE_INCOMING,
		["validator"] = VUHDO_spellTraceIncomingValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["SPELL_TRACE_HEAL"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE_HEAL,
		["validator"] = VUHDO_spellTraceHealValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["SPELL_TRACE_SINGLE"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE_SINGLE,
		["validator"] = VUHDO_spellTraceSingleValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_SPELL_TRACE,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["TRAIL_OF_LIGHT"] = {
		["displayName"] = VUHDO_I18N_TRAIL_OF_LIGHT,
		["validator"] = VUHDO_trailOfLightValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["TRAIL_OF_LIGHT_NEXT"] = {
		["displayName"] = VUHDO_I18N_TRAIL_OF_LIGHT_NEXT,
		["validator"] = VUHDO_trailOfLightNextValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["AOE_ADVICE"] = {
		["displayName"] = VUHDO_I18N_AOE_ADVICE,
		["validator"] = VUHDO_aoeAdviceValidator,
		["interests"] = { VUHDO_UPDATE_AOE_ADVICE },
	},
};



--
function VUHDO_mergeSpellTraceValidators()

	if VUHDO_BOUQUET_BUFFS_SPECIAL then
		for tKey, tValue in pairs(VUHDO_BOUQUET_BUFFS_SPECIAL_SPELL_TRACE) do
			VUHDO_BOUQUET_BUFFS_SPECIAL[tKey] = tValue;
		end
	end

	return;

end
