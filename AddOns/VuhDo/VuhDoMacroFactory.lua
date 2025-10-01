VUHDO_IS_SFX_ENABLED = true;
VUHDO_IS_SOUND_ERRORSPEECH_ENABLED = true;

local VUHDO_RAID;
local VUHDO_SPELL_CONFIG;
local VUHDO_SPELLS;

local GetMacroIndexByName = GetMacroIndexByName;
local GetMacroInfo = GetMacroInfo;
local GetSpellName = C_Spell.GetSpellName;
local VUHDO_replaceMacroTemplates;
local twipe = table.wipe;
local format = format;
local sEmpty = { };
local sIsAnyAutoFireConfigured;
local _;

CreateFrame("Button", "VDSTB", nil, "SecureActionButtonTemplate"):SetAttribute("type", "stop"); -- Calls SpellStopTargeting
local sStopTargetText = "/click VDSTB LeftButton\n";


function VUHDO_macroFactoryInitLocalOverrides()
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_SPELL_CONFIG = _G["VUHDO_SPELL_CONFIG"];
	VUHDO_SPELLS = _G["VUHDO_SPELLS"];

	VUHDO_replaceMacroTemplates = _G["VUHDO_replaceMacroTemplates"];
	sIsAnyAutoFireConfigured = VUHDO_SPELL_CONFIG["IS_AUTO_FIRE"]	and (
		VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_1"]
		or VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_2"]
		or VUHDO_SPELL_CONFIG["IS_FIRE_GLOVES"]
		or (VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_1"] and not VUHDO_strempty(VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"]))
		or (VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_2"] and not VUHDO_strempty(VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"]))
	);
end



local VUHDO_RAID_MACRO_CACHE = { };
local VUHDO_TARGET_MACRO_CACHE = { };
local sFireText = nil;



--
function VUHDO_resetMacroCaches()
	twipe(VUHDO_RAID_MACRO_CACHE);
	twipe(VUHDO_TARGET_MACRO_CACHE);
	sFireText = nil;
end



--
local function VUHDO_isFireSomething(anAction)
	return sIsAnyAutoFireConfigured and (VUHDO_SPELL_CONFIG["IS_FIRE_HOT"] or not (VUHDO_SPELLS[anAction] or sEmpty)["isHot"]);
end



--
local tInstant, tModi2, tCustomUnit;
local function VUHDO_getInstantFireText(aSlotNum)
	tInstant = VUHDO_SPELL_CONFIG["FIRE_CUSTOM_" .. aSlotNum .. "_SPELL"];
	if VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_" .. aSlotNum] and not VUHDO_strempty(tInstant) then

		tCustomUnit = VUHDO_SPELL_CONFIG["custom" .. aSlotNum .. "Unit"] or ""

		if VUHDO_SPELL_CONFIG["IS_FIRE_OUT_FIGHT"] then
			if (VUHDO_SPELLS[tInstant] or sEmpty)["noselftarget"] then
				tModi2 = " ";
			else
				tModi2 = " " .. "[" .. tCustomUnit .. ",exists]" .. " ";
			end
		else
			if (VUHDO_SPELLS[tInstant] or sEmpty)["noselftarget"] then
				tModi2 = " [combat] ";
			else
				tModi2 = " " .. "[combat," .. tCustomUnit .. ",exists]" .. " ";
			end
		end

		return "/use" .. tModi2 .. tInstant .. "\n";
	else
		return "";
	end
end



--
local tModi;
local function VUHDO_getFireText(anAction)

	if VUHDO_isFireSomething(anAction) then
		if not sFireText then
			sFireText = "";

			-- FIXME: Patch 10.0.0 is causing game stutters when console commands are run
			if VUHDO_IS_SFX_ENABLED then
				--sFireText = sFireText .. "/console Sound_EnableSFX 0\n";
			end

			-- FIXME: Patch 10.0.0 is causing game stutters when console commands are run
			if VUHDO_IS_SOUND_ERRORSPEECH_ENABLED then
				--sFireText = sFireText .. "/console Sound_EnableErrorSpeech 0\n";
			end

			tModi = VUHDO_SPELL_CONFIG["IS_FIRE_OUT_FIGHT"] and " " or " [combat] ";

			if VUHDO_SPELL_CONFIG["IS_FIRE_GLOVES"] then
				sFireText = sFireText .. "/use".. tModi .."10\n";
			end

			if VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_1"] then
				sFireText = sFireText .. "/use".. tModi .."13\n";
			end

			if VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_2"] then
				sFireText = sFireText .. "/use".. tModi .."14\n";
			end

			-- Instant 1
			sFireText = sFireText .. VUHDO_getInstantFireText(1);
			-- Instant 2
			sFireText = sFireText .. VUHDO_getInstantFireText(2);

			-- Ton wieder an
			-- FIXME: Patch 10.0.0 is causing game stutters when console commands are run
			if VUHDO_IS_SOUND_ERRORSPEECH_ENABLED then
				--sFireText = sFireText .. "/console Sound_EnableErrorSpeech 1\n";
			end

			-- FIXME: Patch 10.0.0 is causing game stutters when console commands are run
			if VUHDO_IS_SFX_ENABLED then
				--sFireText = sFireText .. "/console Sound_EnableSFX 1\n";
			end

			sFireText = sFireText .. "/run UIErrorsFrame:Clear()\n";
		end

		return sFireText;
	else
		return "";
	end

end



--
local function VUHDO_getMacroPetUnit(aTarget)
	if VUHDO_RAID[aTarget] and not VUHDO_RAID[aTarget]["isPet"] then
		return VUHDO_RAID[aTarget]["petUnit"];
	else
		return nil;
	end
end



--
local tFriendText;
local tEnemyText;
local tModiSpell;
local tMacroId, tMacroText;
local tLowerFriendly, tLowerHostile, tStopText;
local tIsNoHelp;
local function VUHDO_generateTargetMacroText(aTarget, aFriendlyAction, aHostileAction)
	if not aFriendlyAction or not aHostileAction then	return ""; end

	tMacroId = GetMacroIndexByName(aHostileAction);
	if tMacroId == 0 then
		tMacroId = GetMacroIndexByName(aFriendlyAction);
	end

	if (tMacroId ~= 0) then
		_, _, tMacroText = GetMacroInfo(tMacroId);
		return tMacroText;
	end

	if VUHDO_SPELL_CONFIG["IS_CANCEL_CURRENT"] then
		tStopText = "/stopcasting\n";
	else
		tStopText = "";
	end

	tLowerFriendly = strlower(aFriendlyAction);
	tIsNoHelp = false;

	if "target" == tLowerFriendly then
		tFriendText = "/tar [noharm,@vuhdo]\n";
	elseif "focus" == tLowerFriendly then
		tFriendText = "/focus [noharm,@vuhdo]\n";
	elseif "assist" == tLowerFriendly then
		tFriendText = "/assist [noharm,@vuhdo]\n";
	elseif VUHDO_SPELL_KEY_PING == tLowerFriendly then
		tFriendText = "/ping [help,@vuhdo]Assist;[harm,@vuhdo]Attack;[exists,@vuhdo]Ping\n";
	elseif #aFriendlyAction > 0 and GetSpellName(aFriendlyAction) then
		if (VUHDO_SPELLS[aFriendlyAction] or sEmpty)["nohelp"] then
			tModiSpell = "[@vuhdo] ";
			tIsNoHelp = true;
		else
			tModiSpell = "[noharm,@vuhdo] ";
		end

		-- Legion introduced an Order Hall follower for Shamans which yields a mission reward
		-- This reward is an item ambiguously named 'Healing Stream Totem'
		-- Explicitly use '/cast' so that the 'Healing Stream Totem' spell is used instead
		if tLowerFriendly == strlower(VUHDO_SPELL_ID.BUFF_HEALING_STREAM_TOTEM) then
			tFriendText = "/cast ";
		else
			tFriendText = "/use ";
		end

		tFriendText = tFriendText .. tModiSpell .. aFriendlyAction .. "\n";

		if VUHDO_SPELL_CONFIG["IS_AUTO_TARGET"] then
			tFriendText = tFriendText .. "/tar [@vuhdo]\n";
		end
	else
		tFriendText = "";
	end

	tLowerHostile = strlower(aHostileAction);
	if tIsNoHelp then
		tEnemyText = "";
	elseif "target" == tLowerHostile then
		tEnemyText = "/tar [harm,@vuhdo]";
	elseif "focus" == tLowerHostile then
		tEnemyText = "/focus [harm,@vuhdo]";
	elseif "assist" == tLowerHostile then
		tEnemyText = "/assist [harm,@vuhdo]";
	elseif #aHostileAction > 0 and GetSpellName(aHostileAction) then
		tEnemyText = "/use [harm,@vuhdo] " .. aHostileAction;
	else
		tEnemyText = "";
	end

	return sStopTargetText .. tStopText .. VUHDO_getFireText(aFriendlyAction) .. tFriendText .. tEnemyText;
end



--
local tIndex;
function VUHDO_buildTargetButtonMacroText(aTarget, aFriendlyAction, aHostileAction)
	tIndex = aFriendlyAction .. "*" .. aHostileAction;

	if not VUHDO_TARGET_MACRO_CACHE[tIndex] then
		VUHDO_TARGET_MACRO_CACHE[tIndex] = VUHDO_generateTargetMacroText(aTarget, aFriendlyAction, aHostileAction);
	end

	return VUHDO_replaceMacroTemplates(VUHDO_TARGET_MACRO_CACHE[tIndex], aTarget);
end



--
local tPet;
function VUHDO_buildFocusMacroText(aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if tPet then
		return format("/focus [@%s,help][@%s,help][@%s]", aTarget, tPet, aTarget);
	else
		return "/focus [@" .. aTarget .. "]";
	end
end



--
local tPet;
function VUHDO_buildTargetMacroText(aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if tPet then
		return format("/tar [@%s,help][@%s,help][@%s]", aTarget, tPet, aTarget);
	else
		return "/tar [@" .. aTarget .. "]";
	end
end



--
local tPet;
function VUHDO_buildAssistMacroText(aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if tPet then
		return format("/assist [@%s,help][@%s,help][@%s]", aTarget, tPet, aTarget);
	else
		return "/assist [@" .. aTarget .. "]";
	end
end



--
function VUHDO_buildExtraActionButtonMacroText(aTarget)
	return "/tar [@" .. aTarget .. "]\n/click ExtraActionButton1 LeftButton\n/targetlasttarget";
end



--
function VUHDO_buildMouseLookMacroText()
	return "/run if IsMouselooking() then MouselookStop() else MouselookStart() end\n";
end



--
function VUHDO_buildPingMacroText(aTarget)

	return "/ping [@" .. aTarget .. ",harm] Attack;[@" .. aTarget .. ",help] Assist;[@" .. aTarget .. ",exists] Ping";

end



local VUHDO_PROHIBIT_HELP = {
	[VUHDO_SPELL_ID.REBIRTH] = true,
	[VUHDO_SPELL_ID.INTERCESSION] = true,
	[VUHDO_SPELL_ID.REDEMPTION] = true,
	[VUHDO_SPELL_ID.ABSOLUTION] = true,
	[VUHDO_SPELL_ID.ANCESTRAL_SPIRIT] = true,
	[VUHDO_SPELL_ID.ANCESTRAL_VISION] = true,
	[VUHDO_SPELL_ID.REVIVE] = true,
	[VUHDO_SPELL_ID.REVITALIZE] = true,
	[VUHDO_SPELL_ID.RESURRECTION] = true,
	[VUHDO_SPELL_ID.MASS_RESURRECTION] = true,
	[VUHDO_SPELL_ID.RESUSCITATE] = true,
	[VUHDO_SPELL_ID.REAWAKEN] = true,
	[VUHDO_SPELL_ID.RAISE_ALLY] = true,
	[VUHDO_SPELL_ID.RETURN] = true,
	[VUHDO_SPELL_ID.MASS_RETURN] = true,
}



--
local tRezText;
local function VUHDO_getAutoBattleRezText(anIsKeyboard)

	if ("DRUID" == VUHDO_PLAYER_CLASS or "PALADIN" == VUHDO_PLAYER_CLASS) and VUHDO_SPELL_CONFIG["autoBattleRez"] then
		tRezText = "/use [dead,combat,@" .. (anIsKeyboard and "mouseover" or "vuhdo");
		
		if VUHDO_SPELL_CONFIG["smartCastModi"] ~= "all" then
			tRezText = tRezText .. ",mod:" .. VUHDO_SPELL_CONFIG["smartCastModi"];
		end

		tRezText = tRezText .. "] ";

		if "DRUID" == VUHDO_PLAYER_CLASS then
			tRezText = tRezText .. VUHDO_SPELL_ID.REBIRTH .. "\n";
		elseif "PALADIN" == VUHDO_PLAYER_CLASS then
			tRezText = tRezText .. VUHDO_SPELL_ID.INTERCESSION .. "\n";
		end
	else
		tRezText = "";
	end

	return tRezText;

end



--
local tText;
local tModiSpell;
local tSpellPost;
local tVehicleCond;
local tStopText;
local tCastText;
local function VUHDO_generateRaidMacroTemplate(anAction, anIsKeyboard, aTarget, aPet)
	if VUHDO_SPELL_CONFIG["IS_CANCEL_CURRENT"] then
		tStopText = "/stopcasting\n";
	else
		tStopText = "";
	end

	tText = sStopTargetText .. tStopText .. VUHDO_getFireText(anAction);

	if (VUHDO_SPELLS[anAction] or sEmpty)["nohelp"] or VUHDO_PROHIBIT_HELP[anAction] then
		tModiSpell = "";
	else
		tModiSpell = "help,nodead,";
	end

	tSpellPost = VUHDO_getAutoBattleRezText(anIsKeyboard);

	-- Legion introduced an Order Hall follower for Shamans which yields a mission reward
	-- This reward is an item ambiguously named 'Healing Stream Totem'
	-- Explicitly use '/cast' so that the 'Healing Stream Totem' spell is used instead
	if strlower(anAction) == strlower(VUHDO_SPELL_ID.BUFF_HEALING_STREAM_TOTEM) then
		tCastText = "/cast ";
	else
		tCastText = "/use ";
	end

	if anIsKeyboard then
		tText = tText .. tCastText .. "[" .. tModiSpell .. "@mouseover] " .. anAction .. "\n";
		tText = tText .. tSpellPost;
	else
		if aPet and VUHDO_SPELL_ID.REBIRTH ~= anAction and VUHDO_SPELL_ID.INTERCESSION ~= anAction then
			tVehicleCond = "[nodead,help,@vdpet]";
		else
			tVehicleCond = "";
		end
		-- Blizzard has broken the way vehicles work for the Antoran High Command encounter
		-- For now just disable vehicle support (note: this breaks encounters like Malygos)
		--tText = tText .. tCastText .. "[" .. tModiSpell .. "nounithasvehicleui,@vuhdo]" .. tVehicleCond .. " " .. anAction .. "\n";
		tText = tText .. tCastText .. "[" .. tModiSpell .. "@vuhdo]" .. tVehicleCond .. " " .. anAction .. "\n";
		tText = tText .. tSpellPost;
		if aPet then
			tText = tText .. "/tar [unithasvehicleui,@vdpet]\n";
		end

		if VUHDO_SPELL_CONFIG["IS_AUTO_TARGET"] then
			tText = tText .. "/tar [@vuhdo]\n";
		else
			tText = tText .. "/tar [harm,@vuhdo]\n";
		end
	end
	return tText;
end



--
local tIndex;
local tPet;
local tText;
function VUHDO_buildMacroText(anAction, anIsKeyboard, aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if anIsKeyboard then
		tIndex = anAction .. (tPet and (anAction .. "X") or (anAction .. "K"));
	else
		tIndex = anAction .. (tPet and (anAction .. "P") or anAction);
	end

	if not VUHDO_RAID_MACRO_CACHE[tIndex] then
		VUHDO_RAID_MACRO_CACHE[tIndex] = VUHDO_generateRaidMacroTemplate(anAction, anIsKeyboard, aTarget, tPet);
	end

	tText = VUHDO_replaceMacroTemplates(VUHDO_RAID_MACRO_CACHE[tIndex], aTarget);
	--VUHDO_DEBUG[tIndex] = tText;
	if anIsKeyboard and #tText > 256 then
		VUHDO_Msg(VUHDO_I18N_MACRO_KEY_ERR_1 .. anAction .. " (" .. #tText .. VUHDO_I18N_MACRO_KEY_ERR_2, 1, 0.3, 0.3);
	end
	return tText;
end



--
local tText;
function VUHDO_buildPurgeMacroText(anAction, aTarget)
	tText = format("/use [@%s] %s\n", aTarget, anAction);

	if VUHDO_SPELL_CONFIG["IS_AUTO_TARGET"] then
		tText = format("%s/tar [@%s]\n", tText, aTarget);
	end
	return tText;
end



-- Catch players who have released spirit
local tText;
function VUHDO_buildRezMacroText(anAction, aTarget)
	tText = format("/tar [@%s]\n", aTarget);
	tText = format("%s/use %s\n", tText, anAction);
	if not VUHDO_SPELL_CONFIG["IS_AUTO_TARGET"] then
		tText = format("%s/targetlasttarget\n", tText);
	end

	return tText;
end



--
local tName;
local tIndex;
local tNumLocal;
local function VUHDO_createOrUpdateMacro(aMacroNum, aMacroText, aSpell)
	tName = "VuhDoAuto" .. aMacroNum;
	tIndex = GetMacroIndexByName(tName);
	if tIndex == 0 then
		_, tNumLocal = GetNumMacros();
		if tNumLocal >= 18 then
			VUHDO_Msg(VUHDO_I18N_MACRO_NUM_ERR .. aSpell, 1, 0.4, 0.4);
			return nil;
		end
		return CreateMacro(tName, "Spell_Holy_GreaterHeal", aMacroText, true, nil);
	else
		return EditMacro(tIndex, tName, "Spell_Holy_GreaterHeal", aMacroText, true, nil)
	end
end



--
function VUHDO_initKeyboardMacros()
	local tBindingName;
	local tMacroId;
	local tSpell;
	local tBody;
	local tKey1, tKey2;
	local tBindPrefix = "VUHDO_KEY_ASSIGN_";

	VUHDO_IS_SFX_ENABLED = tonumber(GetCVar("Sound_EnableSFX")) == 1;
	VUHDO_IS_SOUND_ERRORSPEECH_ENABLED = tonumber(GetCVar("Sound_EnableErrorSpeech")) == 1;

	if not VUHDO_SPELLS_KEYBOARD then return; end

	ClearOverrideBindings(VuhDo);
	for tCnt = 1, 16 do
		tSpell = VUHDO_SPELLS_KEYBOARD[format("SPELL%d", tCnt)];
		tBindingName = format("%s %d", VUHDO_I18N_MOUSE_OVER_BINDING, tCnt);

		if VUHDO_strempty(tSpell) then
			tBindingName = format("%s\n|cff505050%s|r", tBindingName, VUHDO_I18N_UNASSIGNED);
		else
			tBindingName = format("%s\n(|cff%s00%s|r)", tBindingName, VUHDO_isSpellKnown(tSpell) and "00ff" or "ff00", tSpell);
		end

		_G[format("BINDING_NAME_%s%d", tBindPrefix, tCnt)] = tBindingName;

		tKey1, tKey2 = GetBindingKey(tBindPrefix .. tCnt);
		if not VUHDO_strempty(tSpell) and (tKey1 or tKey2) then
			tBody = VUHDO_buildMacroText(tSpell, true, nil);
			tMacroId = VUHDO_createOrUpdateMacro(tCnt, tBody, tSpell);
			if tMacroId then
				if tKey1 then SetOverrideBindingMacro(VuhDo, true, tKey1, tMacroId); end
				if tKey2 then SetOverrideBindingMacro(VuhDo, true, tKey2, tMacroId); end
			end
		else
			DeleteMacro(format("VuhDoAuto%d", tCnt));
		end
	end

	-- Buff watch smart cast binding
	tKey1, tKey2 = GetBindingKey(tBindPrefix .. "SMART_BUFF");
	if tKey1 then SetOverrideBindingClick(VuhDo, true, tKey1, "VuhDoSmartCastGlassButton", "LeftButton"); end
	if tKey2 then SetOverrideBindingClick(VuhDo, true, tKey2, "VuhDoSmartCastGlassButton", "LeftButton"); end
end
