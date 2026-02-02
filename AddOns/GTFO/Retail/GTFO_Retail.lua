--------------------------------------------------------------------------
-- GTFO_Retail.lua 
--------------------------------------------------------------------------
--[[
GTFO
Author: Zensunim of Dragonblight [Retail], Myzrael [Classic]

Usage: /GTFO or go to Interface->Add-ons->GTFO
]]--

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
		GTFO.CanTank = GTFO_CanTankCheck();
		if (GTFO.CanTank) then
			GTFO_RegisterTankEvents();
		end
		GTFO.TankMode = GTFO_CheckTankMode();
		GTFO_SendUpdateRequest();
	
		-- Load Encounter and Instance cache data
		GTFO.BuildIndexes();
	
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
		GTFO_ActivateMod();
		return;
	end
	if (event == "MIRROR_TIMER_START") then
		-- Fatigue bar warning
		local sType, iValue, iMaxValue, iScale, bPaused, sLabel = ...;
		if (sType == "EXHAUSTION" and iScale < 0) then
			if (GTFO.Settings.IgnoreOptions and GTFO.Settings.IgnoreOptions["Fatigue"]) then
				-- Fatigue being ignored
				--GTFO_DebugPrint("Won't alert FATIGUE - Manually ignored");
				return;
			end
			GTFO_PlaySound(1);
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
		return;
	end
	if (event == "UNIT_INVENTORY_CHANGED") then
		local msgUnit = ...;
		if (UnitIsUnit(msgUnit, "PLAYER")) then
			--GTFO_DebugPrint("Inventory changed, check tank mode");
			GTFO.TankMode = GTFO_CheckTankMode();
		end
		return;
	end
	if (event == "UPDATE_SHAPESHIFT_FORM") then
		--GTFO_DebugPrint("Form changed, check tank mode");
		GTFO.TankMode = GTFO_CheckTankMode();
		return;
	end
	if (event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE") then
		--GTFO_DebugPrint("Spec changed, check tank/caster mode -- "..event);
		GTFO.TankMode = GTFO_CheckTankMode();
		GTFO.CasterMode = GTFO_CheckCasterMode();
		return;
	end
	if (event == "ENCOUNTER_START") then
		local encounterId, encounterName, difficultyID, groupSize = ...;
		GTFO.RegisterEncounter(encounterId);
		return;
	end
	if (event == "ENCOUNTER_END") then
		GTFO.CurrentEncounterId = nil;
		GTFO.UnregisterEncounter();		
		return;
	end
end

function GTFO.RegisterEncounter(encounterId)
	if (encounterId) then
		GTFO.CurrentEncounterId = encounterId;
		--GTFO_DebugPrint("Register for encounter "..GTFO.CurrentEncounterId);
		local spells = GTFO.EncounterIndex[GTFO.CurrentEncounterId];
		if (spells and #spells > 0) then
			--GTFO_DebugPrint("Found "..#spells.." spell(s) for "..GTFO.CurrentEncounterId);
			GTFO.RegisterSpellList(spells, GTFO.EncounterPrivateAuraSoundIds);
		end
	end
end

function GTFO.UnregisterEncounter()
	for i, soundId in pairs(GTFO.EncounterPrivateAuraSoundIds) do
		C_UnitAuras.RemovePrivateAuraAppliedSound(soundId)
		--GTFO_DebugPrint(tostring(GTFO.EncounterPrivateAuraSoundIds)..": Unregistering encounter private aura");
	end
	GTFO.EncounterPrivateAuraSoundIds = { };
	return;
end

function GTFO.RegisterInstance()
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
	if (instanceID) then
		--GTFO_DebugPrint("Register for instance "..tostring(instanceID));
		local spells = GTFO.InstanceIndex[instanceID];
		if (spells and #spells > 0) then
			--GTFO_DebugPrint("Found "..#spells.." spell(s) for "..tostring(instanceID));
			GTFO.RegisterSpellList(spells, GTFO.InstancePrivateAuraSoundIds);
		end
	end
end

function GTFO.UnregisterInstance()
	for i, soundId in pairs(GTFO.InstancePrivateAuraSoundIds) do
		C_UnitAuras.RemovePrivateAuraAppliedSound(soundId)
		--GTFO_DebugPrint(tostring(GTFO.InstancePrivateAuraSoundIds)..": Unregistering instance private aura");
	end
	GTFO.InstancePrivateAuraSoundIds = { };
	return;
end

function GTFO.RegisterSpellList(spells, registeredIdList)
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
		elseif (not C_UnitAuras.AuraIsPrivate(spellId)) then
			-- Blizzard changed this spell and it's no longer a private aura
			GTFO_DebugPrint("Error: Won't alert "..GTFO.SpellTooltip(spellId).." - This spell is no longer a private aura");
		else
			local alertLevel = GTFO_GetAlertID(spell);
			if (spell.test) then
				GTFO_ErrorPrint("TEST ALERT: Spell ID #"..spellId.." "..GTFO_GetSpellLink(spellId));
			end
			local soundFileName, soundChannel, soundLevel, altSoundFileName = GTFO_GetSoundData(alertLevel);
			if (soundLevel and soundLevel > 0) then
				for i = 1, soundLevel do
					local soundFileId = tonumber(soundFileName);
					local privateAuraSoundId = C_UnitAuras.AddPrivateAuraAppliedSound({
						spellID = spellId,
						unitToken = "player",
						soundFileName = (soundFileId and nil or soundFileName),
						soundFileID = soundFileId,
						outputChannel = soundChannel
					});
					GTFO.AddUnique(registeredIdList, privateAuraSoundId);
					--GTFO_DebugPrint(tostring(registeredIdList)..": Registering private aura sound "..tostring(soundFileId or soundFileName).." for "..GTFO.SpellTooltip(spellId));
					
					-- Alt sound support (Brann mode)
					if (altSoundFileName) then
						local altSoundFileId = tonumber(altSoundFileName);
						
						local privateAuraSoundIdAlt = C_UnitAuras.AddPrivateAuraAppliedSound({
							spellID = spellId,
							unitToken = "player",
							soundFileName = (altSoundFileId and nil or altSoundFileName),
							soundFileID = altSoundFileId,
							outputChannel = soundChannel
						});
						GTFO.AddUnique(registeredIdList, privateAuraSoundIdAlt);
						--GTFO_DebugPrint(tostring(registeredIdList)..": Registering private aura sound "..tostring(altSoundFileId or altSoundFileName).." for "..GTFO.SpellTooltip(spellId));						
					end
				end
			else
				--GTFO_DebugPrint("Ignoring alert for "..tostring(spellId));
			end
		end
	end
		
end

function GTFO_OnLoad()
	GTFOFrame:RegisterEvent("VARIABLES_LOADED");
	GTFOFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
	GTFOFrame:RegisterEvent("CHAT_MSG_ADDON");
	GTFOFrame:RegisterEvent("MIRROR_TIMER_START");
	GTFOFrame:RegisterEvent("ENCOUNTER_START");
	GTFOFrame:RegisterEvent("ENCOUNTER_END");
	GTFOFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
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
	GTFO.DisableBrokenCheckButton(GTFO_TrivialButton, GTFOLocal.UI_BrokenReason);
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
	GTFO_SaveSettings();
end

function GTFO_GetAlertID(alert)
	if (alert.soundFunctionRetail) then
		return alert:soundFunctionRetail();
	end	

	local alertLevel;
	local tankAlert = nil;

	if (alert.tankSound or alert.tankSoundLFR or alert.tankSoundChallenge or alert.tankSoundMythic or alert.tankSoundHeroic) then
		-- TankSound alert present, check for tanking mode
		if (GTFO.TankMode or (GTFO.RaidMembers == 0 and GTFO.PartyMembers == 0)) then
			-- Tank or soloing
			tankAlert = true;
		elseif (not GTFO.RetailMode and GTFO_IsTank()) then
			tankAlert = true;
		end
	end
	
	if (tankAlert and alert.tankSound) then
		alertLevel = alert.tankSound;
	else
		alertLevel = alert.sound or 0;
	end
	
	if ((alert.soundLFR or (tankAlert and alert.tankSoundLFR)) and GTFO_IsInLFR()) then
		if (tankAlert and alert.tankSoundLFR) then
			alertLevel = alert.tankSoundLFR;
		elseif (alert.soundLFR) then
			alertLevel = alert.soundLFR;
		end
	elseif (alert.soundHeroic or alert.soundMythic or alert.soundChallenge or (tankAlert and (alert.tankSoundHeroic or alert.tankSoundMythic or alert.tankSoundChallenge))) then
		local isHeroic, isChallenge, isHeroicRaid, isMythic = select(3, GetDifficultyInfo(select(3, GetInstanceInfo())));
		if (isChallenge == true) then
			-- Mythic+/Challenge Mode
			local useAlert = true;
			if (alert.soundChallengeMinimumLevel) then
				local currentKey, _ = C_ChallengeMode.GetActiveKeystoneInfo()
				useAlert = alert.soundChallengeMinimumLevel >= tonumber(currentKey);
			end
			if (useAlert) then
				if (tankAlert and (alert.tankSoundChallenge or alert.tankSoundMythic or alert.tankSoundHeroic)) then
					alertLevel = alert.tankSoundChallenge or alert.tankSoundMythic or alert.tankSoundHeroic;
				elseif (alert.soundChallenge or alert.soundMythic or alert.soundHeroic) then
					alertLevel = alert.soundChallenge or alert.soundMythic or alert.soundHeroic;
				end
			end
		elseif (isMythic == true) then
			-- Mythic Mode
			if (tankAlert and (alert.tankSoundMythic or alert.tankSoundHeroic)) then
				alertLevel = alert.tankSoundMythic or alert.tankSoundHeroic;
			elseif (alert.soundMythic or alert.soundHeroic) then
				alertLevel = alert.soundMythic or alert.soundHeroic;
			end
		elseif (isHeroic == true or isHeroicRaid == true) then
			-- Heroic Mode
			if (tankAlert and alert.tankSoundHeroic) then
				alertLevel = alert.tankSoundHeroic;
			elseif (alert.soundHeroic) then
				alertLevel = alert.soundHeroic;
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
	slider:EnableMouse(false);

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
end

-- Private, developer-only scan
-- /run GTFO.PrivateAuraScan()
function GTFO.PrivateAuraScan()
	if (not C_UnitAuras or not C_UnitAuras.AuraIsPrivate) then
		print("GTFO.PrivateAuraScan: C_UnitAuras.AuraIsPrivate not available.");
		return;
	end

	GTFO.PrivateAuraSpellID = GTFO.PrivateAuraSpellID or {};

	local function AddFromTable(tbl)
		if (not tbl) then
			return 0, 0;
		end

		local scanned = 0;
		local found = 0;

		for k, data in pairs(tbl) do
			local spellID = tonumber(k);
			if (spellID) then
				-- Skip spells already classified (any non-nil encounter/instance property)
				if (data and (data.encounter ~= nil or data.instance ~= nil or data.encounterId ~= nil or data.instanceId ~= nil)) then
					-- skip
				else
					scanned = scanned + 1;

					local ok, isPrivate = pcall(C_UnitAuras.AuraIsPrivate, spellID);
					if (ok and isPrivate) then
						found = found + 1;
						GTFO.PrivateAuraSpellID[tostring(spellID)] = true;
					end
				end
			end
		end

		return scanned, found;
	end

	local scanned1, found1 = AddFromTable(GTFO.SpellID);
	local scanned2, found2 = AddFromTable(GTFO.FFSpellID);

	-- Return a sorted list for quick copy/paste from chat frame output
	local list = {};
	for k in pairs(GTFO.PrivateAuraSpellID) do
		list[#list + 1] = tonumber(k) or k;
	end
	table.sort(list, function(a, b) return a < b; end);

	GTFO_ChatPrint("GTFO.PrivateAuraScan: scanned " .. (scanned1 + scanned2) .. " entries, found " .. (found1 + found2) .. " private-aura spellIDs.");

	for i = 1, #list do
		local spellID = list[i];
		local name;

		if (C_Spell and C_Spell.GetSpellInfo) then
			local info = C_Spell.GetSpellInfo(spellID);
			if (info and info.name) then
				name = info.name;
			end
		end

		if ((not name) and GetSpellInfo) then
			name = GetSpellInfo(spellID);
		end

		name = name or "Unknown";

		GTFO_ChatPrint("Missing Private Aura: "..name.." "..GTFO.SpellTooltip(spellID));
	end

	return list;
end

function GTFO.SpellTooltip(spellId, text, color)
	return "|c"..tostring(color or "ff71d5ff").."|Hspell:"..spellId.."|h["..(tostring(text or spellId)).."]|h|r";
end


function GTFO.BuildIndexes()
	-- Intended for spells with encounter identifiers
	GTFO.EncounterIndex = { };
	GTFO.InstanceIndex = { };
	for spellId, data in pairs(GTFO.SpellID) do
		if (data.encounter or data.instance) then
			if (data.instance) then
				local instanceId = tonumber(data.instance);
				if (not GTFO.InstanceIndex[instanceId]) then
					GTFO.InstanceIndex[instanceId] = { };
				end
				GTFO.AddUnique(GTFO.InstanceIndex[instanceId], spellId);
			elseif (data.encounter) then
				local encounterId = tonumber(data.encounter);
				if (not GTFO.EncounterIndex[encounterId]) then
					GTFO.EncounterIndex[encounterId] = { };
				end
				GTFO.AddUnique(GTFO.EncounterIndex[encounterId], spellId);
			end
		elseif (not GTFO.Settings.ScanMode) then
			-- Scanner is not turned on, go ahead and remove spells that don't matter
			GTFO.SpellID[spellId] = nil;
		end
	end

	for _, i in pairs(GTFO.EncounterIndex) do
		table.sort(i);
	end
	for _, i in pairs(GTFO.InstanceIndex) do
		table.sort(i);
	end
end