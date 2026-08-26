--------------------------------------------------------------------------
-- GTFO_Retail.lua 
--------------------------------------------------------------------------
--[[
GTFO
Author: Zensunim of Dragonblight [Retail], Myzrael [Classic]

Usage: /GTFO or go to Interface->Add-ons->GTFO
]]--

-- Resolved once at load; nil on 12.0.7 since Enum.UnitAuraSoundTrigger doesn't exist without AddAuraSound
-- TODO: Remove once 12.1 goes live
GTFO.AuraSoundTrigger = C_UnitAuras.AddAuraSound and {
	Added = Enum.UnitAuraSoundTrigger.Added,
	ApplicationsIncreased = Enum.UnitAuraSoundTrigger.ApplicationsIncreased,
} or nil;

local AuraSoundRestrictionTypes = {
	{ Enum.AddOnRestrictionType.Combat, "Combat" },
	{ Enum.AddOnRestrictionType.Encounter, "Encounter" },
	{ Enum.AddOnRestrictionType.ChallengeMode, "ChallengeMode" },
	{ Enum.AddOnRestrictionType.PvPMatch, "PvPMatch" },
	--{ Enum.AddOnRestrictionType.Map, "Map" }, -- This doesn't work right now, reports false positives
};

function GTFO_OnEvent(self, event, ...)
	if (event == "VARIABLES_LOADED") then
		C_ChatInfo.RegisterAddonMessagePrefix("GTFO");
		if (GTFOData.DataCode ~= GTFO.DataCode) then
			GTFO_SetDefaults();
			GTFO_ChatPrint(string.format(GTFOLocal.Loading_NewDatabase, GTFO.Version));
			GTFO_DisplayConfigPopupMessage();
		end
		GTFO.Settings = {
			Active = GTFOData.Active;
			Sounds = { GTFOData.Sounds[1], GTFOData.Sounds[2], GTFOData.Sounds[3], GTFOData.Sounds[4] };
			ScanMode = GTFOData.ScanMode;
			AlertMode = GTFOData.AlertMode;
			DebugMode = GTFOData.DebugMode;
			TestMode = GTFOData.TestMode;
			UnmuteMode = GTFOData.UnmuteMode;
			TrivialMode = GTFOData.TrivialMode;
			NoVersionReminder = GTFOData.NoVersionReminder;
			EnableVibration = GTFOData.EnableVibration;
			Volume = GTFOData.Volume or 3;
			TrivialDamagePercent = GTFOData.TrivialDamagePercent or GTFO.DefaultSettings.TrivialDamagePercent;
			SoundChannel = GTFOData.SoundChannel or GTFO.DefaultSettings.SoundChannel;
			BrannMode = GTFOData.BrannMode;
			IgnoreTimeAmount = GTFOData.IgnoreTimeAmount;
			AFKAlertMode = GTFOData.AFKAlertMode;
			IgnoreOptions = { };
			SoundOverrides = { "", "", "", "" };
			IgnoreSpellList = { };
		};
		
		-- Load spell ignore options (player set)
		if (GTFOData.IgnoreOptions) then
			for key, option in pairs(GTFOData.IgnoreOptions) do
				GTFO.Settings.IgnoreOptions[key] = GTFOData.IgnoreOptions[key];
			end
		end
		
		-- Load default spell ignore options
		if (GTFO.IgnoreSpellCategory) then
			for key, option in pairs(GTFO.IgnoreSpellCategory) do
				if (GTFO.IgnoreSpellCategory[key].isDefault) then
					GTFO.DefaultSettings.IgnoreOptions[key] = true;
					if (GTFO.Settings.IgnoreOptions[key] == nil) then
						GTFO.Settings.IgnoreOptions[key] = true;
					end
				end
			end
		end
		
		if (GTFOData.SoundOverrides) then
			for key, option in pairs(GTFOData.SoundOverrides) do
				GTFO.Settings.SoundOverrides[key] = GTFOData.SoundOverrides[key] or "";
			end
		end
		
		if (GTFOData.IgnoreSpellList) then
			for i, spellId in pairs(GTFOData.IgnoreSpellList) do
				GTFO.AddUnique(GTFO.Settings.IgnoreSpellList, spellId);
			end
		end

		GTFO_RenderOptions();
		GTFO_SaveSettings();
		GTFO_AddEvent("RefreshOptions", .1, function() GTFO_RefreshOptions(); end);

		if (GTFO.Settings.Active) then
			--GTFO_ChatPrint(string.format(GTFOLocal.Loading_Loaded, GTFO.Version));
		else
			GTFO_ChatPrint(string.format(GTFOLocal.Loading_LoadedSuspended, GTFO.Version));
		end
		
		GTFO.Users[UnitName("player")] = GTFO.VersionNumber;
		GTFO_GetSounds();
		GTFO.TankMode = GTFO_CheckTankMode();
		GTFO_SendUpdateRequest();
	
		-- Load Encounter and Instance cache data
		GTFO.BuildIndexes();
		GTFO.UpdateAFKStatus();
	
		-- Display state errors meant for debuggers:
		if (GTFO.Settings.ScanMode) then
			GTFO_ErrorPrint("Scan (debugging) mode is currently on.");
			GTFO_ErrorPrint(" To turn this off, type: |cFFEEEE00/gtfo scan|r");
		end
		if (GTFO.Settings.AlertMode) then
			GTFO_ErrorPrint("Alert (debugging) mode is currently on.");
			GTFO_ErrorPrint(" To turn this off, type: |cFFEEEE00/gtfo alert|r");
		end
		if (GTFO.Settings.DebugMode) then
			GTFO_ErrorPrint("Debug mode is currently on.");
			GTFO_ErrorPrint(" To turn this off, type: |cFFEEEE00/gtfo debug|r");
		end
		
		GTFO_ActivateMod();
		return;
	end
	if (event == "PLAYER_ENTERING_WORLD") then
		-- Refresh mode status just in case
		GTFO.TankMode = GTFO_CheckTankMode();
		GTFO.HandleAFKAlert(event, ...);
		GTFO_ActivateMod();
		return;
	end
	if (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
		GTFO.RefreshRegisteredMapSounds();
		GTFO.RefreshRegisteredInstanceSounds();
		return;
	end
	if (event == "PLAYER_STARTED_MOVING") then
		GTFO.VariableStore.PlayerAFK = false;
		return;
	end
	if (event == "PLAYER_FLAGS_CHANGED") then
		GTFO.HandleAFKAlert(event, ...);
		return;
	end
	if (event == "PLAYER_REGEN_ENABLED") then
		GTFO.HandleAFKAlert(event, ...);
		return;
	end
	if (event == "PLAYER_REGEN_DISABLED") then
		GTFO.HandleAFKAlert(event, ...);
		return;
	end
	if (event == "MIRROR_TIMER_START") then
		-- Mirror timer warning
		local sType, iValue, iMaxValue, iScale, bPaused, sLabel = ...;
		if (sType == "EXHAUSTION" and iScale < 0) then
			if (GTFO.Settings.IgnoreOptions and GTFO.Settings.IgnoreOptions["Fatigue"]) then
				-- Fatigue being ignored
				--GTFO_DebugPrint("Won't alert FATIGUE - Manually ignored");
				return;
			end
			GTFO_PlaySound(1);
		elseif (sType == "BREATH") then
			GTFO.VariableStore.BreathTimerActive = true;
			GTFO.VariableStore.BreathTimerAlerted = nil;
			if (GTFO.VariableStore.BreathTimerTicker) then
				GTFO.VariableStore.BreathTimerTicker:Cancel();
				GTFO.VariableStore.BreathTimerTicker = nil;
			end
			GTFO.VariableStore.BreathTimerTicker = C_Timer.NewTicker(0.2, function()
				if (not GTFO.VariableStore.BreathTimerActive or GTFO.VariableStore.BreathTimerAlerted) then
					if (GTFO.VariableStore.BreathTimerTicker) then
						GTFO.VariableStore.BreathTimerTicker:Cancel();
						GTFO.VariableStore.BreathTimerTicker = nil;
					end
					return;
				end
				local breathValue = GetMirrorTimerProgress("BREATH");
				if (breathValue and breathValue <= 0) then
					if (GTFO.Settings.IgnoreOptions and GTFO.Settings.IgnoreOptions["Drowning"]) then
						-- Drowning being ignored
						GTFO.VariableStore.BreathTimerAlerted = true;
						return;
					end
					GTFO.VariableStore.BreathTimerAlerted = true;
					GTFO_PlaySound(1);
				end
			end);
		end
		return;
	end
	if (event == "MIRROR_TIMER_STOP") then
		local sType = ...;
		if (sType == "BREATH") then
			GTFO.VariableStore.BreathTimerActive = nil;
			GTFO.VariableStore.BreathTimerAlerted = nil;
			if (GTFO.VariableStore.BreathTimerTicker) then
				GTFO.VariableStore.BreathTimerTicker:Cancel();
				GTFO.VariableStore.BreathTimerTicker = nil;
			end
		end
		return;
	end
	if (event == "CHAT_MSG_ADDON") then
		local msgPrefix, msgMessage, msgType, msgSender = ...;
		if (msgPrefix == "GTFO" and msgMessage and msgMessage ~= "") then
			local iSlash = string.find(msgMessage,":",1);
			if (iSlash) then
				local sCommand = string.sub(msgMessage,1,iSlash - 1);
				local sValue = string.sub(msgMessage,iSlash + 1);
				if (sCommand == "V" and sValue) then
					-- Version update received
					--GTFO_DebugPrint(msgSender.." sent version info '"..sValue.."' to "..msgType);
					if (not GTFO.Users[msgSender]) then
						GTFO_SendUpdate(msgType);
					end
					GTFO.Users[msgSender] = sValue;
					if ((tonumber(sValue) > GTFO.VersionNumber) and not GTFO.UpdateFound) then
						GTFO.UpdateFound = GTFO_ParseVersionNumber(sValue);
						if (not GTFO.Settings.NoVersionReminder) then
							GTFO_ChatPrint(string.format(GTFOLocal.Loading_OutOfDate, GTFO.UpdateFound));
						end
					end
					return;
				elseif (sCommand == "U" and sValue) then
					-- Version Request
					--GTFO_DebugPrint(msgSender.." requested update to "..sValue);
					GTFO_SendUpdate(sValue);
					return;
				end
			end
		end
		return;
	end
	if (event == "GROUP_ROSTER_UPDATE") then
		--GTFO_DebugPrint("Group roster was updated");
		local sentUpdate = nil;
		GTFO_ScanGroupGUID();
		local PartyMembers = GetNumSubgroupMembers();
		if (PartyMembers > GTFO.PartyMembers and GTFO.RaidMembers == 0) then
			if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
				GTFO_SendUpdate("INSTANCE_CHAT");
			else
				GTFO_SendUpdate("PARTY");
			end
			sentUpdate = true;
		end
		GTFO.PartyMembers = PartyMembers;

		local RaidMembers = GetNumGroupMembers();		
		if (not IsInRaid()) then
			RaidMembers = 0
		end

		if (RaidMembers > GTFO.RaidMembers) then
			if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
				if (not sentUpdate) then
					GTFO_SendUpdate("INSTANCE_CHAT");
				end
			else
				GTFO_SendUpdate("RAID");
			end
		end
		GTFO.RaidMembers = RaidMembers;		

		local wasTankMode = GTFO.TankMode;
		GTFO.TankMode = GTFO_CheckTankMode();
		if (GTFO.TankMode ~= wasTankMode) then
			GTFO.RefreshRegisteredSounds();
		end
		return;
	end
	if (event == "PLAYER_SPECIALIZATION_CHANGED") then
		local msgUnit = ...;
		if (GTFO.SafeUnitIsUnit(msgUnit, "player")) then
			--GTFO_DebugPrint("Spec changed, check tank mode");
			local wasTankMode = GTFO.TankMode;
			GTFO.TankMode = GTFO_CheckTankMode();
			if (GTFO.TankMode ~= wasTankMode) then
				GTFO.RefreshRegisteredSounds();
			end
		end
		return;
	end
	if (event == "ENCOUNTER_START") then
		local encounterId, encounterName, difficultyID, groupSize = ...;
		GTFO.RegisterEncounter(encounterId);
		return;
	end
	if (event == "ENCOUNTER_END") then
		GTFO.CurrentEncounterId = nil;
		GTFO.PendingEncounterUnregister = true;
		GTFO.TryUnregisterEncounter();		
		return;
	end
	if (event == "ADDON_RESTRICTION_STATE_CHANGED") then
		local restrictionType, restrictionState = ...;

		if (restrictionState == Enum.AddOnRestrictionState.Inactive and not GTFO.IsAuraSoundRegistrationRestricted()) then
			if (GTFO.PendingEncounterUnregister) then
				GTFO.TryUnregisterEncounter();
			end
			if (GTFO.PendingSoundRefresh) then
				GTFO.PendingSoundRefresh = nil;
				GTFO.PendingMapRefresh = nil;
				GTFO.RefreshRegisteredSounds();
			elseif (GTFO.PendingMapRefresh) then
				GTFO.PendingMapRefresh = nil;
				GTFO.RefreshRegisteredMapSounds();
			end
		end
		return;
	end
end

function GTFO.IsAuraSoundRegistrationRestricted()
	local inactive = Enum.AddOnRestrictionState.Inactive;
	local isRestricted = false;
	local restricted;

	for _, restriction in ipairs(AuraSoundRestrictionTypes) do
		if (C_RestrictedActions.GetAddOnRestrictionState(restriction[1]) ~= inactive) then
			isRestricted = true;

			if (GTFO.Settings.DebugMode) then
				restricted = restricted or { };
				table.insert(restricted, restriction[2]);
			end
		end
	end

	if (restricted) then
		GTFO_DebugPrint("Addon restrictions active: "..table.concat(restricted, ", "));
	end

	return isRestricted;
end

-- Refresh currently registered instance/encounter/map aura sounds
function GTFO.RefreshRegisteredSounds()
	if (GTFO.IsAuraSoundRegistrationRestricted()) then
		GTFO.PendingSoundRefresh = true;
		return;
	end
	GTFO.PendingSoundRefresh = nil;
	GTFO_ActivateMod();
end

function GTFO.RefreshRegisteredMapSounds()
	if (not GTFO.Settings.Active) then
		return;
	end

	local currentMapId = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or nil;
	if (currentMapId == GTFO.CurrentMapId) then
		return;
	end

	if (GTFO.IsAuraSoundRegistrationRestricted()) then
		GTFO.PendingMapRefresh = true;
		return;
	end

	GTFO.UnregisterMap();
	GTFO.RegisterMap();
end

function GTFO.RefreshRegisteredInstanceSounds()
	if (not GTFO.Settings.Active) then
		return;
	end

	local _, _, _, _, _, _, _, currentInstanceId = GetInstanceInfo();
	currentInstanceId = currentInstanceId or 0;
	if (currentInstanceId == GTFO.CurrentInstanceId) then
		return;
	end

	if (GTFO.IsAuraSoundRegistrationRestricted()) then
		GTFO.PendingSoundRefresh = true;
		return;
	end

	GTFO.UnregisterInstance();
	GTFO.RegisterInstance();
end

function GTFO.SafeUnitIsUnit(unit1, unit2)
    if (not unit1 or not unit2) then
        return nil;
    end

    if (C_Secrets and C_Secrets.CanCompareUnitTokens) then
        if (not C_Secrets.CanCompareUnitTokens(unit1, unit2)) then
            return nil;
        end
    end

    local success, isSameUnit = pcall(UnitIsUnit, unit1, unit2);
    if (not success) then
        return nil;
    end

    if (issecretvalue and issecretvalue(isSameUnit)) then
        return nil;
    end

    return isSameUnit;
end

function GTFO.IsPlayerAFK()
    local success, isAFK = pcall(UnitIsAFK, "player");

    if (not success) then
        return nil;
    end

    if (issecretvalue and issecretvalue(isAFK)) then
        return nil;
    end

    return isAFK;
end

function GTFO.UpdateAFKStatus()
	local isAFK = GTFO.IsPlayerAFK();
	if (isAFK ~= nil) then
		GTFO.VariableStore.PlayerAFK = isAFK;
	end
end

function GTFO.HandleAFKAlert(event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		GTFO.UpdateAFKStatus();
		return;
	end
	if (event == "PLAYER_FLAGS_CHANGED") then
		local unit = ...;
		if (GTFO.SafeUnitIsUnit(unit, "player")) then
			C_Timer.After(0, function()
				GTFO.UpdateAFKStatus();
			end);
		end
		return;
	end
	if (event == "PLAYER_REGEN_ENABLED") then
		GTFO.UpdateAFKStatus();
		return;
	end
	if not (event == "PLAYER_REGEN_DISABLED" and GTFO.Settings.Active and GTFO.Settings.AFKAlertMode) then
		return;
	end

	local isAFK = GTFO.VariableStore.PlayerAFK;
	local currentAFK = GTFO.IsPlayerAFK();
	if (currentAFK ~= nil) then
		isAFK = currentAFK;
		GTFO.VariableStore.PlayerAFK = currentAFK;
	end

	if (isAFK == true) then
		GTFO_PlaySound(1);
	end
end

function GTFO.RegisterEncounter(encounterId)
	if (encounterId) then
		GTFO.CurrentEncounterId = encounterId;
		GTFO_DebugPrint("Register for encounter "..GTFO.CurrentEncounterId);
		local spells = GTFO.EncounterIndex[GTFO.CurrentEncounterId];
		if (spells and #spells > 0) then
			if (GTFO.IsAuraSoundRegistrationRestricted()) then
				-- Encounter is blocked, since you're probably in combat now, no point in retrying
				GTFO_ChatPrint(GTFOLocal.Help_EncounterRegistrationBlocked);
				return;
			end
			GTFO_DebugPrint("Found "..#spells.." spell(s) for "..GTFO.CurrentEncounterId);
			GTFO.RegisterSpellList(spells, GTFO.EncounterRegistration);
		end
	end
end

function GTFO.TryUnregisterEncounter()
	if (GTFO.IsAuraSoundRegistrationRestricted()) then
		GTFO.PendingEncounterUnregister = true;
		return;
	end

	GTFO.PendingEncounterUnregister = nil;
	GTFO.UnregisterEncounter();
end

function GTFO.UnregisterEncounter()
	for i, soundId in pairs(GTFO.EncounterRegistration.SoundIds) do
		GTFO.RemoveAuraSound(soundId);
		--GTFO_DebugPrint(tostring(GTFO.EncounterRegistration.SoundIds)..": Unregistering encounter aura sound");
	end
	GTFO.EncounterRegistration = { SoundIds = { }, SpellIds = { } };
	return;
end

function GTFO.RegisterInstance()
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
	GTFO.CurrentInstanceId = instanceID or 0;

	if (instanceID) then
		GTFO_DebugPrint("Register for instance "..tostring(instanceID));
		local spells = GTFO.InstanceIndex[instanceID];
		if (spells and #spells > 0) then
			GTFO_DebugPrint("Found "..#spells.." spell(s) for "..tostring(instanceID));
			GTFO.RegisterSpellList(spells, GTFO.InstanceRegistration);
		end
	end
end

function GTFO.UnregisterInstance()
	for i, soundId in pairs(GTFO.InstanceRegistration.SoundIds) do
		GTFO.RemoveAuraSound(soundId);
		--GTFO_DebugPrint(tostring(GTFO.InstanceRegistration.SoundIds)..": Unregistering instance aura sound");
	end
	GTFO.InstanceRegistration = { SoundIds = { }, SpellIds = { } };
	GTFO.CurrentInstanceId = nil;
	return;
end

function GTFO.RegisterMap()
	local currentMapId, mapChain = GTFO.GetCurrentMapChain();
	if (not currentMapId or not mapChain or #mapChain == 0) then
		return;
	end

	GTFO.CurrentMapId = currentMapId;
	GTFO_DebugPrint("Register for map "..tostring(currentMapId));

	local spells = { };
	local mapIds = { };
	for i, mapId in ipairs(mapChain) do
		local mapSpells = GTFO.MapIndex[mapId];
		if (mapSpells and #mapSpells > 0) then
			for j, spellId in ipairs(mapSpells) do
				local numericSpellId = tonumber(spellId);
				if (not tContains(spells, spellId)) then
					table.insert(spells, spellId);
					if (numericSpellId) then
						mapIds[numericSpellId] = mapId;
					end
				end
			end
		end
	end

	-- Global map registrations (map/maps entries using 0), lowest priority vs. the current map chain
	local globalSpells = GTFO.MapIndex[0];
	if (globalSpells and #globalSpells > 0) then
		for i, spellId in ipairs(globalSpells) do
			local numericSpellId = tonumber(spellId);
			if (not tContains(spells, spellId)) then
				table.insert(spells, spellId);
				if (numericSpellId) then
					mapIds[numericSpellId] = 0;
				end
			end
		end
	end

	if (#spells > 0) then
		GTFO_DebugPrint("Found "..#spells.." spell(s) for map "..tostring(currentMapId));
		GTFO.MapRegistration.MapIds = mapIds;
		GTFO.RegisterSpellList(spells, GTFO.MapRegistration);
	end
end

function GTFO.UnregisterMap()
	for i, soundId in pairs(GTFO.MapRegistration.SoundIds) do
		GTFO.RemoveAuraSound(soundId);
		--GTFO_DebugPrint(tostring(GTFO.MapRegistration.SoundIds)..": Unregistering map aura sound");
	end
	GTFO.MapRegistration = { SoundIds = { }, SpellIds = { }, MapIds = { } };
	GTFO.CurrentMapId = nil;
	return;
end

function GTFO.GetCurrentMapChain()
	if (not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetMapInfo) then
		return nil;
	end

	local currentMapId = C_Map.GetBestMapForUnit("player");
	if (not currentMapId) then
		return nil;
	end

	local mapChain = { };
	local visited = { };
	local mapId = currentMapId;
	while (mapId and not visited[mapId]) do
		visited[mapId] = true;
		table.insert(mapChain, mapId);
		local mapInfo = C_Map.GetMapInfo(mapId);
		if (not mapInfo or not mapInfo.parentMapID or mapInfo.parentMapID <= 0 or mapInfo.parentMapID == mapId) then
			break;
		end
		mapId = mapInfo.parentMapID;
	end

	return currentMapId, mapChain;
end

function GTFO.AddAuraSound(spellId, trigger, soundFileName, soundFileID, soundChannel)
	local soundInfo = {
		spellID = spellId,
		unitToken = "player",
		soundFileName = soundFileName,
		soundFileID = soundFileID,
		outputChannel = soundChannel
	};
	if (C_UnitAuras.AddAuraSound) then
		return C_UnitAuras.AddAuraSound(trigger or GTFO.AuraSoundTrigger.Added, soundInfo);
	end
	return C_UnitAuras.AddPrivateAuraAppliedSound(soundInfo);
end

function GTFO.RemoveAuraSound(soundId)
	if (C_UnitAuras.RemoveAuraSound) then
		C_UnitAuras.RemoveAuraSound(soundId);
	else
		C_UnitAuras.RemovePrivateAuraAppliedSound(soundId);
	end
end

function GTFO.RegisterAuraSoundTrigger(spellId, trigger, alertLevel, registration)
	local soundFileName, soundChannel, soundLevel, altSoundFileName = GTFO_GetSoundData(alertLevel);
	if (soundLevel and soundLevel > 0) then
		for i = 1, soundLevel do
			local soundFileId = tonumber(soundFileName);
			local soundId = GTFO.AddAuraSound(spellId, trigger, (soundFileId and nil or soundFileName), soundFileId, soundChannel);
			if (soundId) then
				GTFO.AddUnique(registration.SoundIds, soundId);
			end
			--GTFO_DebugPrint(tostring(registration.SoundIds)..": Registering aura sound "..tostring(soundFileId or soundFileName).." for "..GTFO.SpellTooltip(spellId));
			
			-- Alt sound support (Brann mode)
			if (altSoundFileName) then
				local altSoundFileId = tonumber(altSoundFileName);
				
				local altSoundId = GTFO.AddAuraSound(spellId, trigger, (altSoundFileId and nil or altSoundFileName), altSoundFileId, soundChannel);
				if (altSoundId) then
					GTFO.AddUnique(registration.SoundIds, altSoundId);
				end
				--GTFO_DebugPrint(tostring(registration.SoundIds)..": Registering aura sound "..tostring(altSoundFileId or altSoundFileName).." for "..GTFO.SpellTooltip(spellId));						
			end
		end
	else
		--GTFO_DebugPrint("Ignoring alert for "..tostring(spellId));
	end
end

function GTFO.IsTimewalking()
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, lfgDungeonID = GetInstanceInfo();
	if (lfgDungeonID and lfgDungeonID > 0 and GetLFGDungeonInfo) then
		local isTimeWalker = select(18, GetLFGDungeonInfo(lfgDungeonID));
		if (isTimeWalker ~= nil) then
			return (isTimeWalker == true);
		end
	end
	-- Check for Timewalking difficulty IDs as a fallback
	return (difficultyID == 24 or difficultyID == 33 or difficultyID == 151);
end

function GTFO.IsSeasonalMythicDungeon()
	local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo();
	if (difficultyID ~= 23 or not instanceID or not C_ChallengeMode or not C_ChallengeMode.GetMapTable or not C_ChallengeMode.GetMapUIInfo) then
		return nil;
	end

	local mapTable = C_ChallengeMode.GetMapTable();
	if (not mapTable) then
		return nil;
	end

	for _, challengeMapID in pairs(mapTable) do
		local _, _, _, _, _, uiMapID = C_ChallengeMode.GetMapUIInfo(challengeMapID);
		if (uiMapID and uiMapID == instanceID) then
			return true;
		end
	end

	return nil;
end

function GTFO.RegisterSpellList(spells, registration)
	-- 12.0 only supports private auras; 12.1's AddAuraSound also supports non-private auras
	local requirePrivateAura = (not C_UnitAuras.AddAuraSound);
	local isTimewalking = GTFO.IsTimewalking();
	local isSeasonalMythicDungeon = GTFO.IsSeasonalMythicDungeon();
	for i, spellIdText in pairs(spells) do
		local spell = GTFO.SpellID[spellIdText];
		local spellId = tonumber(spellIdText);
		if not (spellId) then
			-- Spell is not a valid number
			GTFO_ErrorPrint("Invalid Spell ID '"..tostring(spellId).."'");
		elseif (tContains(GTFO.Settings.IgnoreSpellList, spellId)) then
			-- Spell is on the custom ignore list
			--GTFO_DebugPrint("Won't alert "..GTFO.SpellTooltip(spellId).." - Player custom ignore option");
		elseif (spell.test and not GTFO.Settings.TestMode) then
			-- Experiemental/Beta option is off, ignore
			--GTFO_DebugPrint("Won't alert "..GTFO.SpellTooltip(spellId).." - Test mode off");
		elseif (requirePrivateAura and not C_UnitAuras.AuraIsPrivate(spellId)) then
			-- Blizzard changed this spell and it's no longer a private aura
			GTFO_DebugPrint("Error: Won't alert "..GTFO.SpellTooltip(spellId).." - This spell is no longer a private aura");
		elseif (isTimewalking and spell.excludeTimewalking == true) then
			-- Spell is excluded while Timewalking
			--GTFO_DebugPrint("Won't alert "..GTFO.SpellTooltip(spellId).." - Excluded during Timewalking");
		elseif (not isTimewalking and not isSeasonalMythicDungeon and spell.trivialLevel and not GTFO.Settings.TrivialMode and spell.trivialLevel <= UnitLevel("player")) then
			-- Spell is trivial for the player's level (trivialLevel is ignored while Timewalking and active seasonal Mythic dungeons)
			--GTFO_DebugPrint("Won't alert "..GTFO.SpellTooltip(spellId).." - Trivial level");
		else
			local alertLevel = GTFO_GetAlertID(spell);
			if (spell.test) then
				GTFO_ErrorPrint("TEST ALERT: Spell ID #"..spellId.." "..GTFO_GetSpellLink(spellId));
			end
			GTFO.AddUnique(registration.SpellIds, spellId);
			GTFO.RegisterAuraSoundTrigger(spellId, GTFO.AuraSoundTrigger and GTFO.AuraSoundTrigger.Added, alertLevel, registration);

			if (GTFO.AuraSoundTrigger) then
				local stackAlertLevel = GTFO_GetAlertID(spell, true);
				if (stackAlertLevel and stackAlertLevel > 0) then
					GTFO.RegisterAuraSoundTrigger(spellId, GTFO.AuraSoundTrigger.ApplicationsIncreased, stackAlertLevel, registration);
				end
			end
		end
	end
		
end

function GTFO_OnLoad()
	GTFOFrame:RegisterEvent("VARIABLES_LOADED");
	GTFOFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
	GTFOFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	GTFOFrame:RegisterEvent("CHAT_MSG_ADDON");
	GTFOFrame:RegisterEvent("MIRROR_TIMER_START");
	GTFOFrame:RegisterEvent("MIRROR_TIMER_STOP");
	GTFOFrame:RegisterEvent("ENCOUNTER_START");
	GTFOFrame:RegisterEvent("ENCOUNTER_END");
	GTFOFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	GTFOFrame:RegisterEvent("ZONE_CHANGED");
	GTFOFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
	GTFOFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	GTFOFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	GTFOFrame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED");
	SlashCmdList["GTFO"] = GTFO_Command;
	SLASH_GTFO1 = "/GTFO";
end

-- Create Addon Menu options and interface
function GTFO_RenderOptions()

	
	local ConfigurationPanel = CreateFrame("FRAME","GTFO_MainFrame");
	ConfigurationPanel.name = "GTFO";
	local category, layout = Settings.RegisterCanvasLayoutCategory(ConfigurationPanel, ConfigurationPanel.name);
	Settings.RegisterAddOnCategory(category);
	GTFO.SettingsCategoryId = category:GetID();

	local IntroMessageHeader = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormalLarge");
	IntroMessageHeader:SetPoint("TOPLEFT", 10, -10);
	IntroMessageHeader:SetText("GTFO "..GTFO.Version);

	local EnabledButton = CreateFrame("CheckButton", "GTFO_EnabledButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	EnabledButton:SetPoint("TOPLEFT", 10, -35)
	EnabledButton.tooltip = GTFOLocal.UI_EnabledDescription;
	getglobal(EnabledButton:GetName().."Text"):SetText(GTFOLocal.UI_Enabled);
	EnabledButton.optionKey = "Enabled";
	EnabledButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local HighSoundButton = CreateFrame("CheckButton", "GTFO_HighSoundButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	HighSoundButton:SetPoint("TOPLEFT", 10, -65)
	HighSoundButton.tooltip = GTFOLocal.UI_HighDamageDescription;
	getglobal(HighSoundButton:GetName().."Text"):SetText(GTFOLocal.UI_HighDamage);
	HighSoundButton.optionKey = "HighSound";
	HighSoundButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local LowSoundButton = CreateFrame("CheckButton", "GTFO_LowSoundButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	LowSoundButton:SetPoint("TOPLEFT", 10, -95)
	LowSoundButton.tooltip = GTFOLocal.UI_LowDamageDescription.."\n\n|cffff2020"..GTFOLocal.UI_BrokenPartialReason.."|r";
	getglobal(LowSoundButton:GetName().."Text"):SetText(GTFOLocal.UI_LowDamage2);
	LowSoundButton.optionKey = "LowSound";
	LowSoundButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local FailSoundButton = CreateFrame("CheckButton", "GTFO_FailSoundButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	FailSoundButton:SetPoint("TOPLEFT", 10, -125)
	FailSoundButton.tooltip = GTFOLocal.UI_FailDescription;
	getglobal(FailSoundButton:GetName().."Text"):SetText(GTFOLocal.UI_Fail);
	FailSoundButton.optionKey = "FailSound";
	FailSoundButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local FriendlyFireSoundButton = CreateFrame("CheckButton", "GTFO_FriendlyFireSoundButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	FriendlyFireSoundButton:SetPoint("TOPLEFT", 10, -155)
	FriendlyFireSoundButton.tooltip = GTFOLocal.UI_FriendlyFireDescription;
	getglobal(FriendlyFireSoundButton:GetName().."Text"):SetText(GTFOLocal.UI_FriendlyFire);
	FriendlyFireSoundButton.optionKey = "FriendlyFireSound";
	FriendlyFireSoundButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local HighTestButton = CreateFrame("Button", "GTFO_HighTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	HighTestButton:SetPoint("TOPLEFT", 300, -65);
	HighTestButton.tooltip = GTFOLocal.UI_TestDescription;
	HighTestButton:SetScript("OnClick",GTFO_Option_HighTest);
	getglobal(HighTestButton:GetName().."Text"):SetText(GTFOLocal.UI_Test);

	local LowTestButton = CreateFrame("Button", "GTFO_LowTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	LowTestButton:SetPoint("TOPLEFT", 300, -95);
	LowTestButton.tooltip = GTFOLocal.UI_TestDescription;
	LowTestButton:SetScript("OnClick",GTFO_Option_LowTest);
	getglobal(LowTestButton:GetName().."Text"):SetText(GTFOLocal.UI_Test);

	local FailTestButton = CreateFrame("Button", "GTFO_FailTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	FailTestButton:SetPoint("TOPLEFT", 300, -125);
	FailTestButton.tooltip = GTFOLocal.UI_TestDescription;
	FailTestButton:SetScript("OnClick",GTFO_Option_FailTest);
	getglobal(FailTestButton:GetName().."Text"):SetText(GTFOLocal.UI_Test);

	local FriendlyFireTestButton = CreateFrame("Button", "GTFO_FriendlyFireTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	FriendlyFireTestButton:SetPoint("TOPLEFT", 300, -155);
	FriendlyFireTestButton.tooltip = GTFOLocal.UI_TestDescription;
	FriendlyFireTestButton:SetScript("OnClick",GTFO_Option_FriendlyFireTest);
	getglobal(FriendlyFireTestButton:GetName().."Text"):SetText(GTFOLocal.UI_Test);

	local HighResetButton = CreateFrame("Button", "GTFO_HighResetButton", ConfigurationPanel, "UIPanelButtonTemplate");
	HighResetButton:SetPoint("TOPLEFT", 360, -65);
	HighResetButton.tooltip = GTFOLocal.UI_ResetCustomSounds;
	HighResetButton:SetScript("OnClick",GTFO_Option_HighReset);
	getglobal(HighResetButton:GetName().."Text"):SetText(GTFOLocal.UI_Reset);

	local LowResetButton = CreateFrame("Button", "GTFO_LowResetButton", ConfigurationPanel, "UIPanelButtonTemplate");
	LowResetButton:SetPoint("TOPLEFT", 360, -95);
	LowResetButton.tooltip = GTFOLocal.UI_ResetCustomSounds;
	LowResetButton:SetScript("OnClick",GTFO_Option_LowReset);
	getglobal(LowResetButton:GetName().."Text"):SetText(GTFOLocal.UI_Reset);

	local FailResetButton = CreateFrame("Button", "GTFO_FailResetButton", ConfigurationPanel, "UIPanelButtonTemplate");
	FailResetButton:SetPoint("TOPLEFT", 360, -125);
	FailResetButton.tooltip = GTFOLocal.UI_ResetCustomSounds;
	FailResetButton:SetScript("OnClick",GTFO_Option_FailReset);
	getglobal(FailResetButton:GetName().."Text"):SetText(GTFOLocal.UI_Reset);

	local FriendlyFireResetButton = CreateFrame("Button", "GTFO_FriendlyFireResetButton", ConfigurationPanel, "UIPanelButtonTemplate");
	FriendlyFireResetButton:SetPoint("TOPLEFT", 360, -155);
	FriendlyFireResetButton.tooltip = GTFOLocal.UI_ResetCustomSounds;
	FriendlyFireResetButton:SetScript("OnClick",GTFO_Option_FriendlyFireReset);
	getglobal(FriendlyFireResetButton:GetName().."Text"):SetText(GTFOLocal.UI_Reset);

	local VolumeText = ConfigurationPanel:CreateFontString("GTFO_VolumeText","ARTWORK","GameFontNormal");
	VolumeText:SetPoint("TOPLEFT", 170, -195);
	VolumeText:SetText("");

	local VolumeSlider = CreateFrame("Slider", "GTFO_VolumeSlider", ConfigurationPanel, "OptionsSliderTemplate");
	VolumeSlider:SetPoint("TOPLEFT", 12, -195);
	VolumeSlider.tooltip = GTFOLocal.UI_VolumeDescription;
	VolumeSlider:SetScript("OnValueChanged",GTFO_Option_SetVolume);
	if (getglobal(GTFO_VolumeSlider:GetName().."Text")) then
		getglobal(GTFO_VolumeSlider:GetName().."Text"):SetText(GTFOLocal.UI_Volume);
		getglobal(GTFO_VolumeSlider:GetName().."High"):SetText(GTFOLocal.UI_VolumeMax);
		getglobal(GTFO_VolumeSlider:GetName().."Low"):SetText(GTFOLocal.UI_VolumeMin);
	end
	VolumeSlider:SetMinMaxValues(1,5);
	VolumeSlider:SetValueStep(1);
	VolumeSlider:SetValue(GTFO.Settings.Volume);
	GTFO_Option_SetVolumeText(GTFO.Settings.Volume);
	
	local UnmuteButton = CreateFrame("CheckButton", "GTFO_UnmuteButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	UnmuteButton:SetPoint("TOPLEFT", 10, -240)
	UnmuteButton.tooltip = GTFOLocal.UI_UnmuteDescription.."\n\n("..GTFOLocal.UI_UnmuteDescription2..")";
	getglobal(UnmuteButton:GetName().."Text"):SetText(GTFOLocal.UI_Unmute);
	UnmuteButton.optionKey = "Unmute";
	UnmuteButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local TrivialButton = CreateFrame("CheckButton", "GTFO_TrivialButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	TrivialButton:SetPoint("TOPLEFT", 10, -270)
	TrivialButton.tooltip = GTFOLocal.UI_TrivialDescription.."\n\n"..GTFOLocal.UI_TrivialDescription2;
	getglobal(TrivialButton:GetName().."Text"):SetText(GTFOLocal.UI_Trivial);
	TrivialButton.optionKey = "Trivial";
	TrivialButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local TrivialDamageText = ConfigurationPanel:CreateFontString("GTFO_TrivialDamageText","ARTWORK","GameFontNormal");
	TrivialDamageText:SetPoint("TOPLEFT", 450, -270);
	TrivialDamageText:SetText("");

	local TrivialDamageSlider = CreateFrame("Slider", "GTFO_TrivialDamageSlider", ConfigurationPanel, "OptionsSliderTemplate");
	TrivialDamageSlider:SetPoint("TOPLEFT", 300, -270);
	TrivialDamageSlider.tooltip = GTFOLocal.UI_TrivialSlider;
	TrivialDamageSlider:SetScript("OnValueChanged",GTFO_Option_SetTrivialDamage);
	if (getglobal(GTFO_TrivialDamageSlider:GetName().."Text")) then
		getglobal(GTFO_TrivialDamageSlider:GetName().."Text"):SetText(GTFOLocal.UI_TrivialSlider);
		getglobal(GTFO_TrivialDamageSlider:GetName().."High"):SetText(" ");
		getglobal(GTFO_TrivialDamageSlider:GetName().."Low"):SetText(" ");
	end
	TrivialDamageSlider:SetMinMaxValues(.5,10);
	TrivialDamageSlider:SetValueStep(.5);
	TrivialDamageSlider:SetValue(GTFO.Settings.TrivialDamagePercent);
	GTFO_Option_SetTrivialDamageText(GTFO.Settings.TrivialDamagePercent);

	local TestModeButton = CreateFrame("CheckButton", "GTFO_TestModeButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	TestModeButton:SetPoint("TOPLEFT", 10, -300)
	TestModeButton.tooltip = GTFOLocal.UI_TestModeDescription.."\n\n"..string.format(GTFOLocal.UI_TestModeDescription2,"zensunim","gmail","com");
	getglobal(TestModeButton:GetName().."Text"):SetText(GTFOLocal.UI_TestMode);
	TestModeButton.optionKey = "TestMode";
	TestModeButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local ChannelText = ConfigurationPanel:CreateFontString("GTFO_ChannelText","ARTWORK","GameFontNormal");
	ChannelText:SetPoint("TOPLEFT", 170, -350);
	ChannelText:SetText("");

	local ChannelIdSlider = CreateFrame("Slider", "GTFO_ChannelIdSlider", ConfigurationPanel, "OptionsSliderTemplate");
	ChannelIdSlider:SetPoint("TOPLEFT", 12, -350);
	ChannelIdSlider:SetScript("OnValueChanged",GTFO_Option_SetChannel);
	ChannelIdSlider:SetMinMaxValues(1,5);
	ChannelIdSlider:SetValueStep(1);
	ChannelIdSlider:SetValue(GTFO_GetCurrentSoundChannelId(GTFO.Settings.SoundChannel));
	if (getglobal(GTFO_ChannelIdSlider:GetName().."Text")) then
		getglobal(GTFO_ChannelIdSlider:GetName().."Text"):SetText(GTFOLocal.UI_SoundChannel);
		getglobal(GTFO_ChannelIdSlider:GetName().."High"):SetText(" ");
		getglobal(GTFO_ChannelIdSlider:GetName().."Low"):SetText(" ");
	end
	GTFO_Option_SetChannelIdText(GTFO_GetCurrentSoundChannelId(GTFO.Settings.SoundChannel));
	
	local VibrationButton = CreateFrame("CheckButton", "GTFO_VibrationButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	VibrationButton:SetPoint("TOPLEFT", 10, -380)
	VibrationButton.tooltip = GTFOLocal.UI_VibrationDescription;
	getglobal(VibrationButton:GetName().."Text"):SetText(GTFOLocal.UI_Vibration);
	VibrationButton.optionKey = "Vibration";
	VibrationButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local BrannModeText = ConfigurationPanel:CreateFontString("GTFO_BrannModeText","ARTWORK","GameFontNormal");
	BrannModeText:SetPoint("TOPLEFT", 170, -420);
	BrannModeText:SetText("");

	local BrannModeSlider = CreateFrame("Slider", "GTFO_BrannModeSlider", ConfigurationPanel, "OptionsSliderTemplate");
	BrannModeSlider:SetPoint("TOPLEFT", 12, -420);
	BrannModeSlider:SetScript("OnValueChanged",GTFO_Option_SetBrannMode);
	BrannModeSlider:SetMinMaxValues(0,2);
	BrannModeSlider:SetValueStep(1);
	BrannModeSlider:SetValue(GTFO.Settings.BrannMode or GTFO.DefaultSettings.BrannMode);
	BrannModeSlider.tooltip = GTFOLocal.UI_BrannModeDescription;
	BrannModeSlider:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
	end);
	BrannModeSlider:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	if (getglobal(GTFO_BrannModeSlider:GetName().."Text")) then
		getglobal(GTFO_BrannModeSlider:GetName().."Text"):SetText(GTFOLocal.UI_BrannMode);
		getglobal(GTFO_BrannModeSlider:GetName().."High"):SetText(" ");
		getglobal(GTFO_BrannModeSlider:GetName().."Low"):SetText(" ");
	end
	BrannModeText:SetText(GTFO_GetCurrentBrannMode(GTFO.Settings.BrannMode));

	local IgnoreTimeSlider = CreateFrame("Slider", "GTFO_IgnoreTimeSlider", ConfigurationPanel, "OptionsSliderTemplate");
	IgnoreTimeSlider:SetPoint("TOPLEFT", 12, -460);
	IgnoreTimeSlider:SetScript("OnValueChanged",GTFO_Option_SetIgnoreTime);
	IgnoreTimeSlider:SetMinMaxValues(0,5);
	IgnoreTimeSlider:SetValueStep(0.1);
	IgnoreTimeSlider:SetValue(GTFO.Settings.IgnoreTimeAmount or GTFO.DefaultSettings.IgnoreTimeAmount);
	IgnoreTimeSlider.tooltip = GTFOLocal.UI_IgnoreTimeDescription;
	IgnoreTimeSlider:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
	end);
	IgnoreTimeSlider:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
	
	if (getglobal(GTFO_IgnoreTimeSlider:GetName().."Text")) then
		getglobal(GTFO_IgnoreTimeSlider:GetName().."Text"):SetText(GTFOLocal.UI_IgnoreTime);
		getglobal(GTFO_IgnoreTimeSlider:GetName().."High"):SetText(" ");
		getglobal(GTFO_IgnoreTimeSlider:GetName().."Low"):SetText(" ");
	end

	local AFKAlertButton = CreateFrame("CheckButton", "GTFO_AFKAlertButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	AFKAlertButton:SetPoint("TOPLEFT", 10, -490)
	AFKAlertButton.tooltip = GTFOLocal.UI_AFKAlertDescription_Retail;
	getglobal(AFKAlertButton:GetName().."Text"):SetText(GTFOLocal.UI_AFKAlert_Retail);
	AFKAlertButton.optionKey = "AFKAlert";
	AFKAlertButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);

	local RestrictionsBox = CreateFrame("Frame", "GTFO_BrokenExplanationBox", ConfigurationPanel, "BackdropTemplate");
	RestrictionsBox:SetPoint("TOPRIGHT", -12, -12);
	RestrictionsBox:SetSize(310, 50);

	RestrictionsBox:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	});
	RestrictionsBox:SetBackdropColor(0, 0, 0, 0.65);

	local icon = RestrictionsBox:CreateTexture(nil, "ARTWORK");
	icon:ClearAllPoints();
	icon:SetPoint("TOPLEFT", RestrictionsBox, "TOPLEFT", 12, -10);
	icon:SetSize(14, 14);
	icon:SetAtlas("communities-icon-lock", true);

	local title = RestrictionsBox:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title:ClearAllPoints();
	title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, -8);
	title:SetText(GTFOLocal.UI_BrokenExplanation_Header);
	title:SetTextColor(1, 0.82, 0);

	local body = RestrictionsBox:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
	body:ClearAllPoints();
	body:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -8);
	body:SetWidth(RestrictionsBox:GetWidth() - 24);
	body:SetJustifyH("LEFT");
	body:SetJustifyV("TOP");
	body:SetTextColor(0.9, 0.9, 0.9);
	body:SetText(GTFOLocal.UI_BrokenExplanation_Text);
	
	RestrictionsBox:SetScript("OnShow", function()
		local topPad = 10;
		local bottomPad = 12;
		local headerH = math.max(icon:GetHeight(), title:GetStringHeight());
		local bodyH = body:GetStringHeight();

		local neededH = topPad + headerH + 8 + bodyH + bottomPad;
		if (neededH < 80) then
			neededH = 80;
		end
		RestrictionsBox:SetHeight(neededH);
	end);

	-- Special Alerts frame
	local IgnoreOptionsPanel = CreateFrame("FRAME","GTFO_IgnoreOptionsFrame");
	IgnoreOptionsPanel.name = GTFOLocal.UI_SpecialAlerts;
	IgnoreOptionsPanel.parent = ConfigurationPanel.name;
	local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, IgnoreOptionsPanel, IgnoreOptionsPanel.name);
	Settings.RegisterAddOnCategory(subcategory);
	GTFO.SettingsSpecialAlertsCategoryId = subcategory:GetID();

	local IntroMessageHeader2 = IgnoreOptionsPanel:CreateFontString(nil, "ARTWORK","GameFontNormalLarge");
	IntroMessageHeader2:SetPoint("TOPLEFT", 10, -10);
	IntroMessageHeader2:SetText("GTFO "..GTFO.Version.." - "..GTFOLocal.UI_SpecialAlertsHeader);

	local yCount = -20;
	for key, option in pairs(GTFO.IgnoreSpellCategory) do
		if (GTFO.IgnoreSpellCategory[key].spellID) then
			yCount = yCount - 30;

			local IgnoreAlertButton = CreateFrame("CheckButton", "GTFO_IgnoreAlertButton_"..key, IgnoreOptionsPanel, "ChatConfigCheckButtonTemplate");
			IgnoreAlertButton:SetPoint("TOPLEFT", 10, yCount)
			getglobal(IgnoreAlertButton:GetName().."Text"):SetText(GTFO.IgnoreSpellCategory[key].desc);
			if (GTFO.IgnoreSpellCategory[key].tooltip) then
				_G["GTFO_IgnoreAlertButton_"..key].tooltip = GTFO.IgnoreSpellCategory[key].tooltip;
			end
			IgnoreAlertButton.optionKey = "Ignore"..key;
			IgnoreAlertButton:SetScript("OnClick", GTFO.ToggleCheckboxOption);
			
			if (GTFO.IgnoreSpellCategory[key].disabled) then
				GTFO.DisableBrokenCheckButton(IgnoreAlertButton, GTFOLocal.UI_BrokenReason);
			end
		end
	end

	GTFOSpellTooltip:ClearLines();

	if (AddonCompartmentFrame) then
		AddonCompartmentFrame:RegisterAddon({
			text = "GTFO",
			icon = "Interface\\Icons\\spell_fire_fire.blp",
			notCheckable = true,
			func = function(button, menuInputData, menu)
				Settings.OpenToCategory(GTFO.SettingsCategoryId);
			end,
			funcOnEnter = function(button)
				MenuUtil.ShowTooltip(button, function(tooltip)
					tooltip:SetText("GTFO "..GTFO.Version);
					tooltip:AddLine("|cFFFFFFFF"..GTFOLocal.Help_Options.."|r");
				end)
			end,
			funcOnLeave = function(button)
				MenuUtil.HideTooltip(button)
			end,
		});
	end
	
	GTFO.DisableBrokenCheckButton(GTFO_FriendlyFireSoundButton, GTFOLocal.UI_BrokenReason);
	GTFO.DisableBrokenCheckButton(GTFO_UnmuteButton, GTFOLocal.UI_BrokenReason);
	GTFO.DisableBrokenCheckButton(GTFO_VibrationButton, GTFOLocal.UI_BrokenReason);

	GTFO.DisableBrokenTestButton(GTFO_FriendlyFireTestButton);
	
	GTFO.DisableBrokenSlider(GTFO_TrivialDamageSlider, GTFOLocal.UI_BrokenReason);
	GTFO.DisableBrokenSlider(GTFO_IgnoreTimeSlider, GTFOLocal.UI_BrokenReason);

	GTFO.UIRendered = true;
end

function GTFO.ToggleCheckboxOption(self)
	local checked = self:GetChecked();
	local optionKey = self.optionKey;

	if (optionKey == "Enabled") then
		GTFO.Settings.Active = checked;
	elseif (optionKey == "HighSound") then
		GTFO.Settings.Sounds[1] = checked;
	elseif (optionKey == "LowSound") then
		GTFO.Settings.Sounds[2] = checked;
	elseif (optionKey == "FailSound") then
		GTFO.Settings.Sounds[3] = checked;
	elseif (optionKey == "FriendlyFireSound") then
		GTFO.Settings.Sounds[4] = checked;
	elseif (optionKey == "TestMode") then
		GTFO.Settings.TestMode = checked;
	elseif (optionKey == "Unmute") then
		GTFO.Settings.UnmuteMode = checked;
	elseif (optionKey == "Trivial") then
		GTFO.Settings.TrivialMode = checked;
	elseif (optionKey == "Vibration") then
		GTFO.Settings.EnableVibration = checked;
	elseif (optionKey == "AFKAlert") then
		GTFO.Settings.AFKAlertMode = checked;
	end
	
	for key, option in pairs(GTFO.IgnoreSpellCategory) do
		if (optionKey == "Ignore"..key) then
			GTFO.Settings.IgnoreOptions[key] = not checked;
		end
	end
	
	GTFO_SaveSettings();
end

function GTFO_ActivateMod()
	if (GTFO.CurrentEncounterId) then
		GTFO.UnregisterEncounter();
		if (GTFO.Settings.Active) then
			GTFO.RegisterEncounter(GTFO.CurrentEncounterId);
		end	
	end
	
	GTFO.UnregisterInstance();
	if (GTFO.Settings.Active) then
		GTFO.RegisterInstance()
	end	

	GTFO.UnregisterMap();
	if (GTFO.Settings.Active) then
		GTFO.RegisterMap();
	end

	if (GTFO.Settings.Active and GTFO.Settings.AFKAlertMode) then
		GTFOFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
		GTFOFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
		GTFOFrame:RegisterEvent("PLAYER_STARTED_MOVING");
		GTFO.UpdateAFKStatus();
	else
		GTFOFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
		GTFOFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
		GTFOFrame:UnregisterEvent("PLAYER_STARTED_MOVING");
	end
end

function GTFO_Command_Help()
	DEFAULT_CHAT_FRAME:AddMessage("[GTFO] "..string.format(GTFOLocal.Help_Intro, GTFO.Version), 0.25, 1.0, 0.25);
	if not (GTFO.Settings.Active) then
		DEFAULT_CHAT_FRAME:AddMessage(GTFOLocal.Help_Suspended, 1.0, 0.1, 0.1);		
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gtfo options|r -- "..GTFOLocal.Help_Options, 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gtfo standby|r -- "..GTFOLocal.Help_Suspend, 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gtfo version|r -- "..GTFOLocal.Help_Version, 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gtfo test|r -- "..GTFOLocal.Help_TestHigh, 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gtfo ignore|r -- "..GTFOLocal.Help_IgnoreSpell, 0.25, 1.0, 0.75);
end

function GTFO_Command_Report()
	local AlertTypeLabels = {
		[1] = GTFOLocal.AlertType_High,
		[2] = GTFOLocal.AlertType_Low,
		[3] = GTFOLocal.AlertType_Fail,
		[4] = GTFOLocal.AlertType_FriendlyFire,
	};
	local AlertTypeColors = {
		[1] = "ffff4040", -- High: red
		[2] = "ff99ffff", -- Low: light cyan
		[3] = "ff5588ff", -- Fail: pale blue
		[4] = "ff55ff55", -- Friendly Fire: green
	};

	local function PrintSpell(sourceLabel, spellId)
		local spell = GTFO.SpellID[tostring(spellId)];
		local alertLevel = spell and GTFO_GetAlertID(spell);
		local alertLabel = (alertLevel and AlertTypeLabels[alertLevel]) or GTFOLocal.Group_None;
		local alertColor = alertLevel and AlertTypeColors[alertLevel] or "ffcccccc";
		local coloredAlertLabel = "|c"..alertColor..alertLabel.."|r";
		local spellName = GTFO_GetSpellName(spellId) or tostring(spellId);
		DEFAULT_CHAT_FRAME:AddMessage("  ["..sourceLabel.."] "..GTFO.SpellTooltip(spellId, spellName).." (#"..spellId..") - "..coloredAlertLabel, 0.25, 1.0, 0.75);
	end

	local function FormatMapChain(mapChain)
		if (not mapChain or #mapChain == 0) then
			return "None";
		end

		local parts = { };
		for i, mapId in ipairs(mapChain) do
			local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapId) or nil;
			local mapName = (mapInfo and mapInfo.name) or "Unknown";
			parts[#parts + 1] = mapName.." (#"..tostring(mapId)..")";
		end

		return table.concat(parts, " > ");
	end

	local instanceId = select(8, GetInstanceInfo());
	local instanceText = instanceId and tostring(instanceId) or "0";
	local encounterText = GTFO.CurrentEncounterId and tostring(GTFO.CurrentEncounterId) or "0";
	local mapId, mapChain = GTFO.GetCurrentMapChain();
	local mapInfo = mapId and C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapId) or nil;
	local mapName = (mapInfo and mapInfo.name) or "None";
	local mapText = (mapId and mapId > 0) and (mapName.." (#"..tostring(mapId)..")") or "None";

	local encounterCount = #GTFO.EncounterRegistration.SpellIds;
	local instanceCount = #GTFO.InstanceRegistration.SpellIds;
	local mapCount = #GTFO.MapRegistration.SpellIds;
	GTFO_ChatPrint("Actively registered spell alerts (Map "..mapText..", Instance #"..instanceText..", Encounter #"..encounterText.."):");
	GTFO_ChatPrint("Map chain: "..FormatMapChain(mapChain));

	if (encounterCount == 0 and instanceCount == 0 and mapCount == 0) then
		GTFO_ErrorPrint("No spells are currently registered.");
		return;
	end

	for i, spellId in ipairs(GTFO.EncounterRegistration.SpellIds) do
		PrintSpell("Encounter #"..encounterText, spellId);
	end
	for i, spellId in ipairs(GTFO.InstanceRegistration.SpellIds) do
		PrintSpell("Instance #"..instanceText, spellId);
	end
	for i, spellId in ipairs(GTFO.MapRegistration.SpellIds) do
		local matchedMapId = GTFO.MapRegistration.MapIds and GTFO.MapRegistration.MapIds[spellId] or nil;
		local matchedMapText;
		if (matchedMapId == 0) then
			matchedMapText = "Global (#0)";
		else
			local matchedMapInfo = matchedMapId and C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(matchedMapId) or nil;
			local matchedMapName = (matchedMapInfo and matchedMapInfo.name) or "Unknown";
			matchedMapText = (matchedMapId and matchedMapId > 0) and (matchedMapName.." (#"..tostring(matchedMapId)..")") or mapText;
		end
		PrintSpell("Map "..matchedMapText, spellId);
	end
end

-- Save settings to persistant storage, refresh UI options
function GTFO_SaveSettings()
	--GTFO_DebugPrint("Saving settings");
	GTFOData.DataCode = GTFO.DataCode;
	GTFOData.Active = GTFO.Settings.Active;
	GTFOData.Sounds = { };
	GTFOData.Sounds[1] = GTFO.Settings.Sounds[1];
	GTFOData.Sounds[2] = GTFO.Settings.Sounds[2];
	GTFOData.Sounds[3] = GTFO.Settings.Sounds[3];
	GTFOData.Sounds[4] = GTFO.Settings.Sounds[4];
	GTFOData.Volume = GTFO.Settings.Volume;
	GTFOData.ScanMode = GTFO.Settings.ScanMode;
	GTFOData.AlertMode = GTFO.Settings.AlertMode;
	GTFOData.DebugMode = GTFO.Settings.DebugMode;
	GTFOData.TestMode = GTFO.Settings.TestMode;
	GTFOData.UnmuteMode = GTFO.Settings.UnmuteMode;
	GTFOData.TrivialMode = GTFO.Settings.TrivialMode;
	GTFOData.TrivialDamagePercent = GTFO.Settings.TrivialDamagePercent;
	GTFOData.NoVersionReminder = GTFO.Settings.NoVersionReminder;
	GTFOData.EnableVibration = GTFO.Settings.EnableVibration;
	GTFOData.SoundChannel = GTFO.Settings.SoundChannel;
	GTFOData.BrannMode = GTFO.Settings.BrannMode;
	GTFOData.IgnoreTimeAmount = GTFO.Settings.IgnoreTimeAmount;
	GTFOData.AFKAlertMode = GTFO.Settings.AFKAlertMode;
	GTFOData.IgnoreOptions = { };
	if (GTFO.Settings.IgnoreOptions) then
		for key, option in pairs(GTFO.Settings.IgnoreOptions) do
			GTFOData.IgnoreOptions[key] = GTFO.Settings.IgnoreOptions[key];
		end
	end
	GTFOData.SoundOverrides = { "", "", "", "" };
	GTFOData.IgnoreSpellList = { };
	
	if (not GTFO.ClassicMode and #GTFO.Settings.IgnoreSpellList > 0) then
		for i, spellId in pairs(GTFO.Settings.IgnoreSpellList) do
			GTFO.AddUnique(GTFOData.IgnoreSpellList, spellId);
		end
	end
	
	if (GTFO.UIRendered) then
		getglobal("GTFO_HighResetButton"):Hide();
		getglobal("GTFO_LowResetButton"):Hide();
		getglobal("GTFO_FailResetButton"):Hide();
		getglobal("GTFO_FriendlyFireResetButton"):Hide();
	end

	if (GTFO.Settings.SoundOverrides) then
		for key, option in pairs(GTFO.Settings.SoundOverrides) do
			GTFOData.SoundOverrides[key] = GTFO.Settings.SoundOverrides[key] or "";
			if (GTFOData.SoundOverrides[key] ~= "") then
				if (key == 1) then
					getglobal("GTFO_HighResetButton"):Show();
				end
				if (key == 2) then
					getglobal("GTFO_LowResetButton"):Show();
				end
				if (key == 3) then
					getglobal("GTFO_FailResetButton"):Show();
				end
				if (key == 4) then
					getglobal("GTFO_FriendlyFireResetButton"):Show();
				end
			end			
		end
	end
	
	if (not GTFO.ClassicMode and #GTFO.Settings.IgnoreSpellList > 0) then
		for i, spellId in pairs(GTFO.Settings.IgnoreSpellList) do
			GTFO.AddUnique(GTFOData.IgnoreSpellList, spellId);
		end
	end
	
	if (GTFO.UIRendered) then
		getglobal("GTFO_EnabledButton"):SetChecked(GTFO.Settings.Active);
		getglobal("GTFO_HighSoundButton"):SetChecked(GTFO.Settings.Sounds[1]);
		getglobal("GTFO_LowSoundButton"):SetChecked(GTFO.Settings.Sounds[2]);
		getglobal("GTFO_FailSoundButton"):SetChecked(GTFO.Settings.Sounds[3]);
		getglobal("GTFO_FriendlyFireSoundButton"):SetChecked(GTFO.Settings.Sounds[4]);
		getglobal("GTFO_TestModeButton"):SetChecked(GTFO.Settings.TestMode);
		getglobal("GTFO_UnmuteButton"):SetChecked(GTFO.Settings.UnmuteMode);
		getglobal("GTFO_TrivialButton"):SetChecked(GTFO.Settings.TrivialMode);
		getglobal("GTFO_VibrationButton"):SetChecked(GTFO.Settings.EnableVibration);
		getglobal("GTFO_AFKAlertButton"):SetChecked(GTFO.Settings.AFKAlertMode);

		for key, option in pairs(GTFO.IgnoreSpellCategory) do
			getglobal("GTFO_IgnoreAlertButton_"..key):SetChecked(not GTFO.Settings.IgnoreOptions[key]);
		end
	end
	
	GTFO_ActivateMod();
end

-- Reset all settings to default
function GTFO_SetDefaults()
	GTFO.Settings.Active = GTFO.DefaultSettings.Active;
	GTFO.Settings.Sounds = { };
	GTFO.Settings.Sounds[1] = GTFO.DefaultSettings.Sounds[1];
	GTFO.Settings.Sounds[2] = GTFO.DefaultSettings.Sounds[2];
	GTFO.Settings.Sounds[3] = GTFO.DefaultSettings.Sounds[3];
	GTFO.Settings.Sounds[4] = GTFO.DefaultSettings.Sounds[4];
	GTFO.Settings.Volume = GTFO.DefaultSettings.Volume;
	GTFO.Settings.ScanMode = GTFO.DefaultSettings.ScanMode;
	GTFO.Settings.AlertMode = GTFO.DefaultSettings.AlertMode;
	GTFO.Settings.DebugMode = GTFO.DefaultSettings.DebugMode;
	GTFO.Settings.TestMode = GTFO.DefaultSettings.TestMode;
	GTFO.Settings.UnmuteMode = GTFO.DefaultSettings.UnmuteMode;
	GTFO.Settings.TrivialMode = GTFO.DefaultSettings.TrivialMode;
	GTFO.Settings.NoVersionReminder = GTFO.DefaultSettings.NoVersionReminder;
	GTFO.Settings.EnableVibration = GTFO.DefaultSettings.EnableVibration;
	GTFO.Settings.TrivialDamagePercent = GTFO.DefaultSettings.TrivialDamagePercent;
	GTFO.Settings.SoundChannel = GTFO.DefaultSettings.SoundChannel;
	if (GTFO.UIRendered) then
		getglobal("GTFO_VolumeSlider"):SetValue(GTFO.DefaultSettings.Volume);
		getglobal("GTFO_TrivialDamageSlider"):SetValue(GTFO.DefaultSettings.TrivialDamagePercent);
		getglobal("GTFO_ChannelIdSlider"):SetValue(GTFO_GetCurrentSoundChannelId(GTFO.DefaultSettings.SoundChannel));
		getglobal("GTFO_BrannModeSlider"):SetValue(GTFO_GetCurrentBrannMode(GTFO.DefaultSettings.BrannMode));
		getglobal("GTFO_IgnoreTimeSlider"):SetValue(GTFO.DefaultSettings.IgnoreTimeAmount);
	end
	GTFO.Settings.IgnoreOptions = GTFO.DefaultSettings.IgnoreOptions;
	GTFO.Settings.SoundOverrides = GTFO.DefaultSettings.SoundOverrides;
	GTFO.Settings.IgnoreSpellList = GTFO.DefaultSettings.IgnoreSpellList;
	GTFO.Settings.BrannMode = GTFO.DefaultSettings.BrannMode;
	GTFO.Settings.IgnoreTimeAmount = GTFO.DefaultSettings.IgnoreTimeAmount;
	GTFO.Settings.AFKAlertMode = GTFO.DefaultSettings.AFKAlertMode;
	GTFO_SaveSettings();
end

function GTFO_GetAlertID(alert, useStackSound)
	local prefix = useStackSound and "stackSound" or "sound";
	local tankPrefix = useStackSound and "tankStackSound" or "tankSound";

	local alertLevel;
	local tankAlert = nil;

	if (alert[tankPrefix] or alert[tankPrefix.."LFR"] or alert[tankPrefix.."Challenge"] or alert[tankPrefix.."Mythic"] or alert[tankPrefix.."Heroic"]) then
		-- TankSound alert present, check for tank mode
		if (GTFO.TankMode or (GTFO.RaidMembers == 0 and GTFO.PartyMembers == 0)) then
			-- Tank or soloing
			tankAlert = true;
		end
	end
	
	if (tankAlert and alert[tankPrefix]) then
		alertLevel = alert[tankPrefix];
	else
		alertLevel = alert[prefix] or 0;
	end
	
	if ((alert[prefix.."LFR"] or (tankAlert and alert[tankPrefix.."LFR"])) and GTFO_IsInLFR()) then
		if (tankAlert and alert[tankPrefix.."LFR"]) then
			alertLevel = alert[tankPrefix.."LFR"];
		elseif (alert[prefix.."LFR"]) then
			alertLevel = alert[prefix.."LFR"];
		end
	elseif (alert[prefix.."Heroic"] or alert[prefix.."Mythic"] or alert[prefix.."Challenge"] or (tankAlert and (alert[tankPrefix.."Heroic"] or alert[tankPrefix.."Mythic"] or alert[tankPrefix.."Challenge"]))) then
		local isHeroic, isChallenge, isHeroicRaid, isMythic = select(3, GetDifficultyInfo(select(3, GetInstanceInfo())));
		if (isChallenge == true) then
			-- Mythic+/Challenge Mode
			local useAlert = true;
			if (alert[prefix.."ChallengeMinimumKeyLevel"]) then
				local currentKey, _ = C_ChallengeMode.GetActiveKeystoneInfo()
				useAlert = alert[prefix.."ChallengeMinimumKeyLevel"] <= tonumber(currentKey);
			end
			if (useAlert) then
				if (tankAlert and (alert[tankPrefix.."Challenge"] or alert[tankPrefix.."Mythic"] or alert[tankPrefix.."Heroic"])) then
					alertLevel = alert[tankPrefix.."Challenge"] or alert[tankPrefix.."Mythic"] or alert[tankPrefix.."Heroic"];
				elseif (alert[prefix.."Challenge"] or alert[prefix.."Mythic"] or alert[prefix.."Heroic"]) then
					alertLevel = alert[prefix.."Challenge"] or alert[prefix.."Mythic"] or alert[prefix.."Heroic"];
				end
			end
		elseif (isMythic == true) then
			-- Mythic Mode
			if (tankAlert and (alert[tankPrefix.."Mythic"] or alert[tankPrefix.."Heroic"])) then
				alertLevel = alert[tankPrefix.."Mythic"] or alert[tankPrefix.."Heroic"];
			elseif (alert[prefix.."Mythic"] or alert[prefix.."Heroic"]) then
				alertLevel = alert[prefix.."Mythic"] or alert[prefix.."Heroic"];
			end
		elseif (isHeroic == true or isHeroicRaid == true) then
			-- Heroic Mode
			if (tankAlert and alert[tankPrefix.."Heroic"]) then
				alertLevel = alert[tankPrefix.."Heroic"];
			elseif (alert[prefix.."Heroic"]) then
				alertLevel = alert[prefix.."Heroic"];
			end
		end
	end
	
	return alertLevel;
end

function GTFO_DisplayAura(alertTypeID)
   -- No visual displays available for now
end

function GTFO.DisableBrokenCheckButton(checkButton, reason)
	checkButton:SetChecked(false);
	checkButton:Disable();
	checkButton:SetScript("OnClick", nil);

	local label = _G[checkButton:GetName().."Text"];
	if (label) then
		label:SetTextColor(0.5, 0.5, 0.5);
	end

	if (reason) then
		checkButton.tooltip = (checkButton.tooltip or "").."\n\n|cffff2020"..reason.."|r";
	end
	
	if (not checkButton.GTFO_LockTexture) then
		local lock = checkButton:CreateTexture(nil, "OVERLAY");
		lock:SetPoint("CENTER", checkButton, "CENTER", 0, 0);
		lock:SetSize(14, 14);
		lock:SetAlpha(0.9);

		if (C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("communities-icon-lock")) then
			lock:SetAtlas("communities-icon-lock", true);
		else
			lock:SetTexture("Interface\\Common\\UI-LockIcon");
		end

		checkButton.GTFO_LockTexture = lock;
	end

	checkButton.GTFO_LockTexture:Show();
end

function GTFO.DisableBrokenTestButton(button)
	button:Disable();
	button:SetScript("OnClick", nil);

	local t = _G[button:GetName().."Text"];
	if (t) then
		t:SetTextColor(0.5, 0.5, 0.5);
	end
end

function GTFO.DisableBrokenSlider(slider, reason)
	slider:Disable();
	slider:SetEnabled(false);
	slider:EnableMouse(true);

	if (reason) then
		slider.tooltip = (slider.tooltip or "").."\n\n|cffff2020"..reason.."|r";
	end

	local name = slider:GetName();
	local text = _G[name.."Text"];
	local high = _G[name.."High"];
	local low = _G[name.."Low"];

	if (text) then
		text:SetTextColor(0.5, 0.5, 0.5);
	end
	if (high) then
		high:SetTextColor(0.5, 0.5, 0.5);
	end
	if (low) then
		low:SetTextColor(0.5, 0.5, 0.5);
	end

	if (slider.tooltip) then
		slider:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
		end);
		slider:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);
	end

	if (not slider.GTFO_LockTexture) then
		local lock = slider:CreateTexture(nil, "OVERLAY");
		lock:SetPoint("CENTER", slider, "CENTER", 0, 0);
		lock:SetSize(14, 14);
		lock:SetAlpha(0.9);

		if (C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("communities-icon-lock")) then
			lock:SetAtlas("communities-icon-lock", true);
		else
			lock:SetTexture("Interface\\Common\\UI-LockIcon");
		end

		slider.GTFO_LockTexture = lock;
	end

	slider.GTFO_LockTexture:Show();
end

function GTFO.SpellTooltip(spellId, text, color)
	return "|c"..tostring(color or "ff71d5ff").."|Hspell:"..spellId.."|h["..(tostring(text or spellId)).."]|h|r";
end


function GTFO.BuildIndexes()
	-- Intended for spells with instance/encounter/map identifiers
	local counter = 0;
	local excluded = 0;
	GTFO.EncounterIndex = { };
	GTFO.InstanceIndex = { };
	GTFO.MapIndex = { };
	for spellId, data in pairs(GTFO.SpellID) do
		if (data.encounter or data.instance or data.instances or data.encounters or data.map or data.maps) then
			if (data.instances and #data.instances > 0) then
				for i, instanceId in pairs(data.instances) do
					if (not GTFO.InstanceIndex[instanceId]) then
						GTFO.InstanceIndex[instanceId] = { };
					end
					GTFO.AddUnique(GTFO.InstanceIndex[instanceId], spellId);
					counter = counter + 1;
				end
			elseif (data.instance) then
				local instanceId = tonumber(data.instance);
				if (not GTFO.InstanceIndex[instanceId]) then
					GTFO.InstanceIndex[instanceId] = { };
				end
				GTFO.AddUnique(GTFO.InstanceIndex[instanceId], spellId);
				counter = counter + 1;
			elseif (data.maps and #data.maps > 0) then
				for i, mapId in pairs(data.maps) do
					mapId = tonumber(mapId);
					if (mapId) then
						if (not GTFO.MapIndex[mapId]) then
							GTFO.MapIndex[mapId] = { };
						end
						GTFO.AddUnique(GTFO.MapIndex[mapId], spellId);
						counter = counter + 1;
					end
				end
			elseif (data.map) then
				local mapId = tonumber(data.map);
				if (mapId) then
					if (not GTFO.MapIndex[mapId]) then
						GTFO.MapIndex[mapId] = { };
					end
					GTFO.AddUnique(GTFO.MapIndex[mapId], spellId);
					counter = counter + 1;
				end
			elseif (data.encounters and #data.encounters > 0) then
				for i, encounterId in pairs(data.encounters) do
					if (not GTFO.EncounterIndex[encounterId]) then
						GTFO.EncounterIndex[encounterId] = { };
					end
					GTFO.AddUnique(GTFO.EncounterIndex[encounterId], spellId);
					counter = counter + 1;
				end
			elseif (data.encounter) then
				local encounterId = tonumber(data.encounter);
				if (not GTFO.EncounterIndex[encounterId]) then
					GTFO.EncounterIndex[encounterId] = { };
				end
				GTFO.AddUnique(GTFO.EncounterIndex[encounterId], spellId);
				counter = counter + 1;
			end
		else
			if (not GTFO.Settings.ScanMode) then
				-- Scanner is not turned on, go ahead and remove spells that don't matter
				GTFO.SpellID[spellId] = nil;
			end
			excluded = excluded + 1;
		end
	end

	for _, i in pairs(GTFO.EncounterIndex) do
		table.sort(i);
	end
	for _, i in pairs(GTFO.InstanceIndex) do
		table.sort(i);
	end
	for _, i in pairs(GTFO.MapIndex) do
		table.sort(i);
	end
	GTFO_DebugPrint("Total spells indexed: "..counter);
	GTFO_DebugPrint("Total spells excluded: "..excluded);
end