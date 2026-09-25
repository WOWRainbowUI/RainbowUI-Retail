--------------------------------------------------------------------------
-- SmartQuest.lua 
--------------------------------------------------------------------------
--[[
SmartQuest
Author: Zensunim of Dragonblight

Macro Commands:
	/sq options - Display options window
	/sq status - Display SmartQuest status
	/sq monitor - Monitors party's quests
	/sq self - Monitors own quests
	/sq sound - Turns on/off sound

]]--

SmartQuest = {
	DefaultSetting = {
		Sound = true;
		MySound = true;
		PartySound = true;
		Monitor = true;
		SelfMonitor = false;
		SoundIgnore = 1.0;
		ChatFrameId = 1;
		TextColor = 
			{
				R = 1.0;
				G = .78;
				B = 1.0;
			};		
	};

	-- **********************************************************************************************
	--
	-- DON'T EDIT BELOW THIS LINE (unless you know what you're doing!)
	--
	-- **********************************************************************************************

	Version = "1.33";
	ModCode = "KSQ";
	DataCode = "1";
	Quest = { };
	Setting = { };
	UIRendered = nil;
	DebugMode = nil;

	Data = {
		Me = UnitName("player");
		Realm = gsub(GetRealmName(), "%s", "");
		MeFull = UnitName("player").."-"..gsub(GetRealmName(), "%s", "");
		SoundTimers = { },
		TimerQuestIgnore = GetTime() + 3.0;
	};
	
	Sound = { 
		["objective"] = "Interface\\AddOns\\SmartQuest\\Sounds\\objective.ogg",
		["objective_group"] = "Interface\\AddOns\\SmartQuest\\Sounds\\objective_group.ogg",
		["item_group"] = "Interface\\AddOns\\SmartQuest\\Sounds\\item_group.ogg",
		["item"] = "Interface\\AddOns\\SmartQuest\\Sounds\\item_you.ogg",
		["quest_done"] = "Interface\\AddOns\\SmartQuest\\Sounds\\quest_done_all.ogg",
		["quest_done_group"] = "Interface\\AddOns\\SmartQuest\\Sounds\\quest_done.ogg",
		["quest_failed"] = "Interface\\AddOns\\SmartQuest\\Sounds\\quest_failed.ogg",
		["quest_failed_group"] = "Interface\\AddOns\\SmartQuest\\Sounds\\quest_failed_group.ogg",
	};
};

SmartQuestOptions = { };

function SmartQuest.ResetDefaults()
	SmartQuest.Setting.MySound = SmartQuest.DefaultSetting.MySound;
	SmartQuest.Setting.PartySound = SmartQuest.DefaultSetting.PartySound;

	SmartQuest.Setting.MySoundObjective = SmartQuest.DefaultSetting.MySound;
	SmartQuest.Setting.MySoundItem = SmartQuest.DefaultSetting.MySound;
	SmartQuest.Setting.MySoundDone = SmartQuest.DefaultSetting.MySound;
	SmartQuest.Setting.MySoundFailed = SmartQuest.DefaultSetting.MySound;
	SmartQuest.Setting.PartySoundObjective = SmartQuest.DefaultSetting.PartySound;
	SmartQuest.Setting.PartySoundItem = SmartQuest.DefaultSetting.PartySound;
	SmartQuest.Setting.PartySoundDone = SmartQuest.DefaultSetting.PartySound;
	SmartQuest.Setting.PartySoundFailed = SmartQuest.DefaultSetting.PartySound;

	SmartQuest.Setting.Monitor = SmartQuest.DefaultSetting.Monitor;
	SmartQuest.Setting.SoundIgnore = SmartQuest.DefaultSetting.SoundIgnore;
	SmartQuest.Setting.TextColor = { };
	SmartQuest.Setting.TextColor.R = SmartQuest.DefaultSetting.TextColor.R;
	SmartQuest.Setting.TextColor.G = SmartQuest.DefaultSetting.TextColor.G;
	SmartQuest.Setting.TextColor.B = SmartQuest.DefaultSetting.TextColor.B;
	SmartQuest.Setting.ChatFrameId = SmartQuest.DefaultSetting.ChatFrameId;
	SmartQuest.Setting.SelfMonitor = SmartQuest.DefaultSetting.SelfMonitor;
	if (SmartQuest.UIRendered) then
		getglobal("SmartQuest_ChatFrameIdSlider"):SetValue(SmartQuest.DefaultSetting.ChatFrameId);
	end
end

SmartQuest.ResetDefaults();

function SmartQuest.OnEvent(self, event, ...)
	if (event == "VARIABLES_LOADED") then
		SmartQuest.QuestScan(false);
		C_ChatInfo.RegisterAddonMessagePrefix(SmartQuest.ModCode);
		SmartQuest.DebugPrint("SmartQuest Variables loaded.");
		SmartQuestTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		SmartQuestFrame:RegisterEvent("CHAT_MSG_ADDON");
		SmartQuestFrame:RegisterEvent("UI_INFO_MESSAGE");
		--SmartQuestFrame:RegisterEvent("GROUP_ROSTER_UPDATE"); -- TODO: Implement quest caching and requesting
		SmartQuestFrame:RegisterEvent("QUEST_LOG_UPDATE");
		SmartQuestFrame:RegisterEvent("QUEST_TURNED_IN");
		SmartQuestFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
		SmartQuestFrame:RegisterEvent("PLAYER_LEAVING_WORLD");
		
		if (SmartQuestOptions.Setting and SmartQuestOptions.Setting[SmartQuest.Data.Me]) then
			-- Migrate and delete old settings
			SmartQuest.ErrorPrint("Migrating old profile settings to new system.");
			SmartQuestOptions.Setting[SmartQuest.Data.MeFull] = SmartQuestOptions.Setting[SmartQuest.Data.Me];
			SmartQuestOptions.Setting[SmartQuest.Data.Me] = nil;
		end
		
		if (SmartQuestOptions.DataCode ~= SmartQuest.DataCode or not (SmartQuestOptions.Setting)) then
			SmartQuestOptions = { };
			SmartQuestOptions.DataCode = SmartQuest.DataCode;
			SmartQuestOptions.Setting = { };
			SmartQuestOptions.Setting[SmartQuest.Data.MeFull] = { };
			SmartQuest.ErrorPrint("New database detected. Clearing settings.");
		elseif (SmartQuestOptions.Setting[SmartQuest.Data.MeFull]) then
			if (SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Sound) then
				SmartQuest.Setting.MySound = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Sound;
				SmartQuest.Setting.PartySound = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Sound;
				SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Sound = nil;
			else
				SmartQuest.Setting.MySound = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound;
				SmartQuest.Setting.PartySound = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound;
			end
			
			if (SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundObjective ~= nil) then
				-- Current support
				SmartQuest.Setting.MySoundObjective = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundObjective;
				SmartQuest.Setting.MySoundItem = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundItem;
				SmartQuest.Setting.MySoundDone = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundDone;
				SmartQuest.Setting.MySoundFailed = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundFailed;
				SmartQuest.Setting.PartySoundObjective = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundObjective;
				SmartQuest.Setting.PartySoundItem = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundItem;
				SmartQuest.Setting.PartySoundDone = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundDone;
				SmartQuest.Setting.PartySoundFailed = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundFailed;
			else
				-- Legacy support, import old settings
				SmartQuest.Setting.MySoundObjective = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound;
				SmartQuest.Setting.MySoundItem = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound;
				SmartQuest.Setting.MySoundDone = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound;
				SmartQuest.Setting.MySoundFailed = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound;
				SmartQuest.Setting.PartySoundObjective = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound;
				SmartQuest.Setting.PartySoundItem = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound;
				SmartQuest.Setting.PartySoundDone = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound;
				SmartQuest.Setting.PartySoundFailed = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound;
			end
			
			SmartQuest.Setting.Monitor = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Monitor;
			SmartQuest.Setting.SelfMonitor = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].SelfMonitor;
			if (SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor) then
				SmartQuest.Setting.TextColor = { };
				SmartQuest.Setting.TextColor.R = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor.R;
				SmartQuest.Setting.TextColor.G = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor.G;
				SmartQuest.Setting.TextColor.B = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor.B;
			end
			SmartQuest.Setting.ChatFrameId = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].ChatFrameId or SmartQuest.DefaultSetting.ChatFrameId;
		else
			SmartQuest.ErrorPrint("New player detected. Setting defaults.");
			SmartQuestOptions.Setting[SmartQuest.Data.MeFull] = { };
		end

		SmartQuest.RenderOptions();
		SmartQuest.SaveSettings();
		return;
	end
	if (event == "UI_INFO_MESSAGE") then
		local messageId, message;
		messageId, message = ...;
		SmartQuest.DebugPrint(tostring(messageId)..": "..tostring(message));
		if (messageId == LE_GAME_ERR_QUEST_UNKNOWN_COMPLETE) then
			-- Bonus quest complete
			SmartQuest.PlayMySound("quest_done");
			return;
		end
		if (messageId ~= LE_GAME_ERR_QUEST_ADD_KILL_SII and messageId ~= LE_GAME_ERR_QUEST_ADD_FOUND_SII and messageId ~= LE_GAME_ERR_QUEST_ADD_ITEM_SII and messageId ~= LE_GAME_ERR_QUEST_ADD_PLAYER_KILL_SII) then
			return;
		end
		local questText = gsub(message,"(.*):%s*([-%d]+)%s*/%s*([-%d]+)%s*$","%1",1)
		if (questText ~= message) then
			local ii, jj, strItemName, iNumItems, iNumNeeded = string.find(message, "(.*):%s*([-%d]+)%s*/%s*([-%d]+)%s*$");
			local stillneeded = iNumNeeded - iNumItems;

			if (stillneeded > 0) then
				SmartQuest.PlayMySound("item")
				SmartQuest.SendComm("I///"..message);
			else
				SmartQuest.PlayMySound("objective")
				SmartQuest.SendComm("O///"..message);
			end
		end
		return;
	end
	if (event == "GROUP_ROSTER_UPDATE") then
		-- Get current quest data
	end
	if (event == "QUEST_LOG_UPDATE") then
		SmartQuest.DebugPrint("Quest Log Update");
		SmartQuest.QuestScan(true);
		return;
		-- Quest Log
	end
	if (event == "PLAYER_ENTERING_WORLD") then
		SmartQuest.QuestScan(false);
		SmartQuestFrame:RegisterEvent("QUEST_LOG_UPDATE");
		return;
	end
	if (event == "PLAYER_LEAVING_WORLD") then
		SmartQuestFrame:UnregisterEvent("QUEST_LOG_UPDATE");
		return;
	end
	if (event == "QUEST_TURNED_IN") then
		local message = "";
		local useModernTurnIn = C_QuestLog and C_QuestLog.GetQuestDifficultyLevel and C_QuestLog.GetTitleForQuestID;
		if (not useModernTurnIn) then
			local questText = GetTitleText();
			if (SmartQuest.Quest[questText] and SmartQuest.Quest[questText].link) then
				if (SmartQuest.Quest[questText].level and tonumber(SmartQuest.Quest[questText].level) > 0) then
					message = "["..SmartQuest.Quest[questText].level.."] ";
				end
				if (SmartQuest.Quest[questText].link) then
					message = message..SmartQuest.Quest[questText].link;
				else
					message = message..questText;
				end
			else
				message = questText;
			end
		else
			local questId, questXp, questMoney = ...;
			local level = tonumber(C_QuestLog.GetQuestDifficultyLevel(questId) or 0);
			local link = GetQuestLink(questId) or C_QuestLog.GetTitleForQuestID(questId) or GetTitleText();
			
			if (level > 0) then
				message = "["..level.."] ";
			end
			message = message..link;
		end
		SmartQuest.SendComm("T///"..message);
		return;
	end
	if (event == "CHAT_MSG_ADDON") then
		local msgPrefix, msgMessage, msgType, msgSender = ...;
		if ( msgSender ~= SmartQuest.Data.MeFull ) then
			if ( msgPrefix == SmartQuest.ModCode) then
				SmartQuest.ReceiveComm(msgMessage, msgSender);
			end
		end
		return;
	end
end

function SmartQuest.QuestScan(sendAlerts)
	local useModernQuestLog = C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo and C_QuestLog.IsComplete and C_QuestLog.IsFailed;
	local iNumEntries, iNumQuests;
	if (not useModernQuestLog) then
		iNumEntries, iNumQuests = GetNumQuestLogEntries();
	else
		iNumEntries, iNumQuests = C_QuestLog.GetNumQuestLogEntries();
	end
		
	for i = 1, iNumEntries, 1 do
		local strQuestLogTitleText, strQuestLevel, strSuggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId;
		if (not useModernQuestLog) then
			strQuestLogTitleText, strQuestLevel, strSuggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId = GetQuestLogTitle(i);
			isHeader = (isHeader == 1);
		else
			local questInfo = C_QuestLog.GetInfo(i);
			if (questInfo) then
				strQuestLogTitleText = questInfo.title;
				strQuestLevel = questInfo.difficultyLevel;
				strSuggestedGroup = questInfo.suggestedGroup;
				isHeader = questInfo.isHeader;
				isCollapsed = questInfo.isCollapsed;
				frequency = questInfo.frequency;
				questId = questInfo.questID;
				if (C_QuestLog.IsComplete(questId)) then
					isComplete = 1;
				elseif (C_QuestLog.IsFailed(questId)) then
					isComplete = -1;
				end
			end
		end

		if (strQuestLevel and strQuestLevel > 0 and not isHeader) then
			if (SmartQuest.Quest[questId]) then
				SmartQuest.DebugPrint("Updating "..questId);
				SmartQuest.ScanQuestProgress(questId, sendAlerts);
				if (SmartQuest.Quest[questId].complete ~= isComplete) and (isComplete) then
					SmartQuest.Quest[questId].complete = isComplete;
					--SmartQuest.SendComm("U///"..questId.."///"..isComplete);
					if (isComplete == -1) then
						if (sendAlerts) then
							SmartQuest.PlayMySound("quest_failed");
							SmartQuest.SendComm("F///["..strQuestLevel.."] "..SmartQuest.Quest[questId].link);
						end
					elseif (UnitExists("party1")) then
						if (sendAlerts) then
							SmartQuest.PlayMySound("quest_done");
							SmartQuest.SendComm("C///["..strQuestLevel.."] "..SmartQuest.Quest[questId].link);
						end
					else
						if (sendAlerts) then
							SmartQuest.PlayMySound("quest_done");
						end
					end
					SmartQuest.DebugPrint("You're done! "..isComplete);
				elseif (SmartQuest.Quest[questId].complete ~= isComplete) and not (isComplete) then
					SmartQuest.DebugPrint("You were done, but now you're not!");
					SmartQuest.Quest[questId].complete = isComplete;
					--SmartQuest.SendComm("U///"..questId.."///0");
				else
					SmartQuest.Quest[questId].complete = isComplete;
					if (isComplete) then
						SmartQuest.DebugPrint("You're already done!");
					else
						SmartQuest.DebugPrint("You're not done! ");
					end
				end
			else
				SmartQuest.DebugPrint("Adding "..questId);
				SmartQuest.Quest[questId] = {
					level = strQuestLevel;
					complete = isComplete;
					code = SmartQuest.Code(i);
				};
				if (not useModernQuestLog) then
					SelectQuestLogEntry(i);
					SmartQuest.Quest[questId].link = strQuestLogTitleText;
				else
					SmartQuest.Quest[questId].link = GetQuestLink(questId);
					local progress = SmartQuest.GetQuestProgress(questId);
					if (progress) then
						SmartQuest.Quest[questId].currentProgress = progress;
					end
				end
				
				if not (SmartQuest.Quest[questId].party) then
					SmartQuest.Quest[questId].party = { };
				end				
				if (sendAlerts) then
					if (SmartQuest.Quest[questId].link) then
						SmartQuest.SendComm("A///["..strQuestLevel.."] "..SmartQuest.Quest[questId].link);
					else
						SmartQuest.SendComm("A///["..strQuestLevel.."] "..strQuestLogTitleText);
					end
				end
			end
		end
	end
end

function SmartQuest.Code(iQuest)
	local useModernSelection = C_QuestLog and C_QuestLog.SetSelectedQuest and C_QuestLog.GetQuestIDForLogIndex;
	if (not useModernSelection) then
		SelectQuestLogEntry(iQuest);
	else
		C_QuestLog.SetSelectedQuest(C_QuestLog.GetQuestIDForLogIndex(iQuest))
	end

	local strText1, strText2 = GetQuestLogQuestText();
	if (strText2) then
		local code = string.gsub(strText2,"%s","");
		code = string.gsub(code,"%/","");
		local code2 = code;
		code = string.gsub(code,"%a","");
		code2 = string.gsub(code2,"(.)(.)","%2");
		if (string.len(code2) > 25) then
			code2 = string.sub(code2, 1, 25);
		end
		return (code..code2);
	end
end

function SmartQuest.GetQuestProgress(questId)
	if (C_QuestLog and C_QuestLog.GetQuestObjectives) then
		local objectives = C_QuestLog.GetQuestObjectives(questId);
		if (objectives) then
			for i, objective in pairs(objectives) do
				if (objective.type == "progressbar") then
					return objective.text;
				end
			end
		end
	end
	return nil;
end

function SmartQuest.ScanQuestProgress(questId, sendAlerts)
	local progress = SmartQuest.GetQuestProgress(questId);
	if (progress and progress ~= SmartQuest.Quest[questId].currentProgress) then
		SmartQuest.Quest[questId].currentProgress = progress;
		if (sendAlerts) then
			if (string.find(progress, "(100%%)")) then
				SmartQuest.PlayMySound("objective")
				SmartQuest.SendComm("O///"..progress);
			else
				SmartQuest.PlayMySound("item")
				SmartQuest.SendComm("I///"..progress);
			end
		end
	end
end

function SmartQuest.Test()
	SmartQuest.ChatPrint("Quest Test:");
	local iNumEntries, iNumQuests = GetNumQuestLogEntries();
	for i = 1, iNumEntries, 1 do
		SelectQuestLogEntry(i);
		local strText1, strText2 = GetQuestLogQuestText();
		if (strText2) then
			local code = string.gsub(strText2,"%s","");
			code = string.gsub(code,"%/","");
			local code2 = code;
			code = string.gsub(code,"%a","");
			code2 = string.gsub(code2,"(.)(.)","%2");
			if (string.len(code2) > 25) then
				code2 = string.sub(code2, 1, 25);
			end
			SmartQuest.ChatPrint(code..code2);
		end
	end
end

function SmartQuest.OnLoad()
	SmartQuestFrame:RegisterEvent("CHAT_MSG_ADDON");
	SmartQuestFrame:RegisterEvent("VARIABLES_LOADED");
	SmartQuest.ChatPrint("SmartQuest v"..SmartQuest.Version.." loaded.");

	SlashCmdList["SQ"] = SmartQuest.Command;
	SLASH_SQ1 = "/SQ";

	SlashCmdList["SMARTQUEST"] = SmartQuest.Command;
	SLASH_SMARTQUEST1 = "/SMARTQUEST";
end

function SmartQuest.ChatPrint(str)
	if (str and _G["ChatFrame"..SmartQuest.Setting.ChatFrameId]) then
		_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]:AddMessage("[SmartQuest] "..tostring(str), 0.25, 1.0, 0.25);
	end
end

function SmartQuest.ErrorPrint(str)
	if (str and _G["ChatFrame"..SmartQuest.Setting.ChatFrameId]) then
		_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]:AddMessage("[SmartQuest] "..tostring(str), 1.0, 0.5, 0.5);
	end
end

function SmartQuest.DebugPrint(str)
	if (SmartQuest.DebugMode and str and _G["ChatFrame"..SmartQuest.Setting.ChatFrameId]) then
		_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]:AddMessage("[SQ] "..tostring(str), 0.75, 1.0, 0.25);
	end
end

function SmartQuest.CommPrint(str, override)
	if (str) and (SmartQuest.Setting.Monitor or override) and (_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]) then
		_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]:AddMessage(str, SmartQuest.Setting.TextColor.R, SmartQuest.Setting.TextColor.G, SmartQuest.Setting.TextColor.B);
	end
end

function SmartQuest.CommandMonitor()
	if (SmartQuest.Setting.Monitor) then
		SmartQuest.Setting.Monitor = nil;
		SmartQuest.ChatPrint("Quest monitoring is off.");
	else
		SmartQuest.Setting.Monitor = true;
		SmartQuest.ChatPrint("Quest monitoring is on.");
	end
	SmartQuest.SaveSettings();
end

function SmartQuest.CommandSelfMonitor()
	if (SmartQuest.Setting.SelfMonitor) then
		SmartQuest.Setting.SelfMonitor = nil;
		SmartQuest.ChatPrint("Quest self monitoring is off.");
	else
		SmartQuest.Setting.SelfMonitor = true;
		SmartQuest.ChatPrint("Quest self monitoring is on.");
	end
	SmartQuest.SaveSettings();
end

function SmartQuest.CommandSound()
	if (SmartQuest.Setting.MySound) then
		SmartQuest.Setting.MySound = nil;
		SmartQuest.Setting.PartySound = nil;
		SmartQuest.ChatPrint("Sound effects are off.");
	else
		SmartQuest.Setting.MySound = true
		SmartQuest.Setting.PartySound = true;
		SmartQuest.ChatPrint("Sound effects are on.");
	end
	SmartQuest.SaveSettings();
end

function SmartQuest.PlayMySound(sSound)
	if (SmartQuest.Setting.MySound) then
		local playSound = nil;
		
		if (sSound == "objective" and SmartQuest.Setting.MySoundObjective) then
			playSound = true;
		end
		if (sSound == "item" and SmartQuest.Setting.MySoundItem) then
			playSound = true;
		end
		if (sSound == "quest_done" and SmartQuest.Setting.MySoundDone) then
			playSound = true;
		end
		if (sSound == "quest_failed" and SmartQuest.Setting.MySoundFailed) then
			playSound = true;
		end
	
		if (playSound) then
			local currentTime = GetTime();
			if ((SmartQuest.Data.SoundTimers[sSound] or 0) <= currentTime) then
				SmartQuest.Data.SoundTimers[sSound] = currentTime + SmartQuest.Setting.SoundIgnore;
				PlaySoundFile(SmartQuest.Sound[sSound], "Master");
			end
		end
	end
end

function SmartQuest.PlayPartySound(sSound)
	if (SmartQuest.Setting.PartySound) then
		local playSound = nil;
	
		if (sSound == "objective_group" and SmartQuest.Setting.PartySoundObjective) then
			playSound = true;
		end
		if (sSound == "item_group" and SmartQuest.Setting.PartySoundItem) then
			playSound = true;
		end
		if (sSound == "quest_done_group" and SmartQuest.Setting.PartySoundDone) then
			playSound = true;
		end
		if (sSound == "quest_failed_group" and SmartQuest.Setting.PartySoundFailed) then
			playSound = true;
		end
		
		if (playSound) then
			local currentTime = GetTime();
			if ((SmartQuest.Data.SoundTimers[sSound] or 0) <= currentTime) then
				SmartQuest.Data.SoundTimers[sSound] = currentTime + SmartQuest.Setting.SoundIgnore;
				PlaySoundFile(SmartQuest.Sound[sSound], "Master");
			end
		end
	end
end

function SmartQuest.SendComm(sNewMessage)
	if (SmartQuest.Data.TimerQuestIgnore < GetTime()) then
		local raidmembers = GetNumGroupMembers();
		local partymembers = GetNumSubgroupMembers();
		if (not IsInRaid()) then
			raidmembers = 0
		end
	
		if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
			C_ChatInfo.SendAddonMessage(SmartQuest.ModCode,sNewMessage,"INSTANCE_CHAT");
			return "INSTANCE_CHAT";
		elseif (raidmembers > 0) then
			C_ChatInfo.SendAddonMessage(SmartQuest.ModCode,sNewMessage,"RAID");
			return "RAID";
		elseif (partymembers > 0) then
			C_ChatInfo.SendAddonMessage(SmartQuest.ModCode,sNewMessage,"PARTY");
			return "PARTY";
		end
	end
	if (SmartQuest.Setting.SelfMonitor) then
		SmartQuest.CommPrint("[SQ] ["..SmartQuest.NameDecode(UnitName("player")).."]: "..SmartQuest.CommDecode(sNewMessage, false), true);
	end
	return;
end

function SmartQuest.ReceiveComm(sMessage, sSender)
	SmartQuest.CommPrint("[SQ] ["..SmartQuest.NameDecode(sSender).."]: "..SmartQuest.CommDecode(sMessage, true));
end

function SmartQuest.NameDecode(sText)
	local dash = string.find(sText,"-",1);
	if (dash) then
		local name = string.sub(sText,1,dash - 1);
		local server = string.sub(sText,dash + 1);
		if (server == gsub(GetRealmName(), "%s", "")) then
			return name;
		end;
	end
	return sText;
end

function SmartQuest.CommDecode(sText, bSound)
	if (sText == "") or not (sText) then
		return "";
	end
	
	local DecodedMessage;
	local Slash = string.find(sText,"///",1);
	local Slash2 = "";
	local Slash3 = "";
	local QuestName = "";
	local Order = "";
	local Data = "";
	local Data2 = "";
	
	if (Slash) then
		Order = string.sub(sText,1,Slash - 1);
		Slash2 = string.find(sText,"///",Slash + 3);
		if (Slash2) then
			QuestName = string.sub(sText,Slash + 3,Slash2 - 1);
			Slash3 = string.find(sText,"///",Slash2 + 3);
			if (Slash3) then
				Data = string.sub(sText,Slash2 + 3,Slash3 - 1);
				Data2 = string.sub(sText,Slash3 + 3);
			else
				Data = string.sub(sText,Slash2 + 3);
			end
		else
			QuestName = string.sub(sText,Slash + 3)
		end
	else
		Order = sText;
	end
	
	if (Order == "A") then
		DecodedMessage = "Picked up quest: "..QuestName;
	elseif (Order == "C") then
		DecodedMessage = "Completed quest: "..QuestName;
		if (bSound) then
			SmartQuest.PlayPartySound("quest_done_group");
		end
	elseif (Order == "F") then
		DecodedMessage = "Failed quest: "..QuestName;
		if (bSound) then
			SmartQuest.PlayPartySound("quest_failed_group");
		end
	elseif (Order == "O") then
		DecodedMessage = "Completed objective: "..QuestName;
		if (bSound) then
			SmartQuest.PlayPartySound("objective_group");
		end
	elseif (Order == "I") then
		DecodedMessage = "Progress: "..QuestName;
		if (bSound) then
			SmartQuest.PlayPartySound("item_group");
		end
	elseif (Order == "T") then
		DecodedMessage = "Turned in quest: "..QuestName;
	else
		DecodedMessage = sText;
	end
	
	return DecodedMessage;
end

function SmartQuest.CommandStatus()
	SmartQuest.ChatPrint("SmartQuest Status Report:");
	SmartQuest.ChatPrint("- Monitor: "..SmartQuest.Logic(SmartQuest.Setting.Monitor));
	SmartQuest.ChatPrint("- Self: "..SmartQuest.Logic(SmartQuest.Setting.SelfMonitor));
	SmartQuest.ChatPrint("- My Sounds: "..SmartQuest.Logic(SmartQuest.Setting.MySound));
	SmartQuest.ChatPrint("- Party Sounds: "..SmartQuest.Logic(SmartQuest.Setting.PartySound));
end

function SmartQuest.Command(arg1)
	local Command = string.upper(arg1);
	local DescriptionOffset = string.find(arg1,"%s",1);
	local Description = nil;
	
	if (DescriptionOffset) then
		Command = string.upper(string.sub(arg1, 1, DescriptionOffset - 1));
		Description = string.sub(arg1, DescriptionOffset + 1).."";
	end
	
	SmartQuest.DebugPrint("Command executed: "..Command);
	
	if (Command == "STATUS") then
		SmartQuest.CommandStatus();
	elseif (Command == "OPTION" or Command == "OPTIONS") then
		SmartQuest.CommandOptions();
	elseif (Command == "REPORT" or Command == "MONITOR") then
		SmartQuest.CommandMonitor();
	elseif (Command == "REPORT" or Command == "SELF") then
		SmartQuest.CommandSelfMonitor();
	elseif (Command == "SOUND") then
		SmartQuest.CommandSound();
	elseif (Command == "HELP") then
		SmartQuest.CommandHelp();
	else
		SmartQuest.CommandHelp();
	end
end

function SmartQuest.CommandOptions()
	if (not InterfaceOptions_AddCategory) then
		Settings.OpenToCategory(SmartQuest.SettingsCategoryId);
		Settings.OpenToCategory(SmartQuest.SettingsCategoryId);
	else
		InterfaceOptionsFrame_OpenToCategory("SmartQuest");
		InterfaceOptionsFrame_OpenToCategory("SmartQuest"); -- Do it twice because first time you load up, it doesn't work
	end
	SmartQuest.OptionSetChatFrameIdText(SmartQuest.Setting.ChatFrameId); -- Refresh title in case it changed or first logging in
end

function SmartQuest.CommandHelp()
	DEFAULT_CHAT_FRAME:AddMessage("[SQ] "..SmartQuest.Version.." (|cFFFFFFFFCommand List|r)", 0.25, 1.0, 0.25);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00Current Chat Window:|r -- "..SmartQuest.OptionGetChatFrameTitle(SmartQuest.Setting.ChatFrameId), 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/sq options|r -- Options", 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/sq status|r -- Status", 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/sq monitor|r -- Turn on/off group quest monitoring", 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/sq self|r -- Turn on/off self quest monitoring", 0.25, 1.0, 0.75);
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/sq sound|r -- Turn on/off sounds", 0.25, 1.0, 0.75);
end

function SmartQuest.ToggleCheckboxOption(self)
	local checked = self:GetChecked();
	local optionKey = self.optionKey;

	if (optionKey == "MySound") then
		SmartQuest.Setting.MySound = checked;
	elseif (optionKey == "PartySound") then
		SmartQuest.Setting.PartySound = checked;
	elseif (optionKey == "Monitor") then
		SmartQuest.Setting.Monitor = checked;
	elseif (optionKey == "SelfMonitor") then
		SmartQuest.Setting.SelfMonitor = checked;
	elseif (optionKey == "MySoundObjective") then
		SmartQuest.Setting.MySoundObjective = checked;
	elseif (optionKey == "MySoundItem") then
		SmartQuest.Setting.MySoundItem = checked;
	elseif (optionKey == "MySoundDone") then
		SmartQuest.Setting.MySoundDone = checked;
	elseif (optionKey == "MySoundFailed") then
		SmartQuest.Setting.MySoundFailed = checked;
	elseif (optionKey == "PartySoundObjective") then
		SmartQuest.Setting.PartySoundObjective = checked;
	elseif (optionKey == "PartySoundItem") then
		SmartQuest.Setting.PartySoundItem = checked;
	elseif (optionKey == "PartySoundDone") then
		SmartQuest.Setting.PartySoundDone = checked;
	elseif (optionKey == "PartySoundFailed") then
		SmartQuest.Setting.PartySoundFailed = checked;
	end
	SmartQuest.SaveSettings();
end

function SmartQuest.RenderOptions()
	SmartQuest.UIRendered = true;
	local category, layout;
	
	local ConfigurationPanel = CreateFrame("FRAME","SmartQuest_MainFrame");
	ConfigurationPanel.name = "SmartQuest";
	if (not InterfaceOptions_AddCategory) then
		category, layout = Settings.RegisterCanvasLayoutCategory(ConfigurationPanel, ConfigurationPanel.name);
		Settings.RegisterAddOnCategory(category);
		SmartQuest.SettingsCategoryId = category:GetID();
	else
		InterfaceOptions_AddCategory(ConfigurationPanel);	
	end
	
	local IntroMessageHeader = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormalLarge");
	IntroMessageHeader:SetPoint("TOPLEFT", 10, -10);
	IntroMessageHeader:SetText("SmartQuest "..SmartQuest.Version);

	local MySoundButton = CreateFrame("CheckButton", "SmartQuest_MySoundButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	MySoundButton:SetPoint("TOPLEFT", 10, -35)
	MySoundButton.tooltip = "Enable SmartQuest sounds for my quests."
	getglobal(MySoundButton:GetName().."Text"):SetText(" Sound (My Quests)");
	MySoundButton.optionKey = "MySound";
	MySoundButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local MySoundItemButton = CreateFrame("CheckButton", "SmartQuest_MySoundItemButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	MySoundItemButton:SetPoint("TOPLEFT", 30, -65)
	MySoundItemButton.tooltip = "Hear a sound every time a quest item is collected."
	getglobal(MySoundItemButton:GetName().."Text"):SetText(" Item Collected");
	MySoundItemButton.optionKey = "MySoundItem";
	MySoundItemButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local MySoundItemTestButton = CreateFrame("Button", "SmartQuest_MySoundItemTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	MySoundItemTestButton:SetPoint("TOPLEFT", 300, -65);
	MySoundItemTestButton.tooltip = "Test";
	MySoundItemTestButton:SetScript("OnClick",SmartQuest.OptionMySoundItemTest);
	getglobal(MySoundItemTestButton:GetName().."Text"):SetText("Test");	

	local MySoundObjectiveButton = CreateFrame("CheckButton", "SmartQuest_MySoundObjectiveButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	MySoundObjectiveButton:SetPoint("TOPLEFT", 30, -95)
	MySoundObjectiveButton.tooltip = "Hear a sound every time a quest objective is completed."
	getglobal(MySoundObjectiveButton:GetName().."Text"):SetText(" Objective Complete");
	MySoundObjectiveButton.optionKey = "MySoundObjective";
	MySoundObjectiveButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local MySoundObjectiveTestButton = CreateFrame("Button", "SmartQuest_MySoundObjectiveTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	MySoundObjectiveTestButton:SetPoint("TOPLEFT", 300, -95);
	MySoundObjectiveTestButton.tooltip = "Test";
	MySoundObjectiveTestButton:SetScript("OnClick",SmartQuest.OptionMySoundObjectiveTest);
	getglobal(MySoundObjectiveTestButton:GetName().."Text"):SetText("Test");

	local MySoundDoneButton = CreateFrame("CheckButton", "SmartQuest_MySoundDoneButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	MySoundDoneButton:SetPoint("TOPLEFT", 30, -125)
	MySoundDoneButton.tooltip = "Hear a sound when completing all quest objectives."
	getglobal(MySoundDoneButton:GetName().."Text"):SetText(" Quest Complete");
	MySoundDoneButton.optionKey = "MySoundDone";
	MySoundDoneButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local MySoundDoneTestButton = CreateFrame("Button", "SmartQuest_MySoundDoneTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	MySoundDoneTestButton:SetPoint("TOPLEFT", 300, -125);
	MySoundDoneTestButton.tooltip = "Test";
	MySoundDoneTestButton:SetScript("OnClick",SmartQuest.OptionMySoundDoneTest);
	getglobal(MySoundDoneTestButton:GetName().."Text"):SetText("Test");

	local MySoundFailedButton = CreateFrame("CheckButton", "SmartQuest_MySoundFailedButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	MySoundFailedButton:SetPoint("TOPLEFT", 30, -155)
	MySoundFailedButton.tooltip = "Hear a sound when failing a quest."
	getglobal(MySoundFailedButton:GetName().."Text"):SetText(" Quest Failed");
	MySoundFailedButton.optionKey = "MySoundFailed";
	MySoundFailedButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local MySoundFailedTestButton = CreateFrame("Button", "SmartQuest_MySoundFailedTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	MySoundFailedTestButton:SetPoint("TOPLEFT", 300, -155);
	MySoundFailedTestButton.tooltip = "Test";
	MySoundFailedTestButton:SetScript("OnClick",SmartQuest.OptionMySoundFailedTest);
	getglobal(MySoundFailedTestButton:GetName().."Text"):SetText("Test");

	local PartySoundButton = CreateFrame("CheckButton", "SmartQuest_PartySoundButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	PartySoundButton:SetPoint("TOPLEFT", 10, -185)
	PartySoundButton.tooltip = "Enable SmartQuest sounds for my party's quests."
	getglobal(PartySoundButton:GetName().."Text"):SetText(" Sound (Party's Quests)");
	PartySoundButton.optionKey = "PartySound";
	PartySoundButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local PartySoundItemButton = CreateFrame("CheckButton", "SmartQuest_PartySoundItemButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	PartySoundItemButton:SetPoint("TOPLEFT", 30, -215)
	PartySoundItemButton.tooltip = "Hear a sound every time a quest item is collected by a party member."
	getglobal(PartySoundItemButton:GetName().."Text"):SetText(" Item Collected");
	PartySoundItemButton.optionKey = "PartySoundItem";
	PartySoundItemButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);
	
	local PartySoundItemTestButton = CreateFrame("Button", "SmartQuest_PartySoundItemTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	PartySoundItemTestButton:SetPoint("TOPLEFT", 300, -215);
	PartySoundItemTestButton.tooltip = "Test";
	PartySoundItemTestButton:SetScript("OnClick",SmartQuest.OptionPartySoundItemTest);
	getglobal(PartySoundItemTestButton:GetName().."Text"):SetText("Test");

	local PartySoundObjectiveButton = CreateFrame("CheckButton", "SmartQuest_PartySoundObjectiveButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	PartySoundObjectiveButton:SetPoint("TOPLEFT", 30, -245)
	PartySoundObjectiveButton.tooltip = "Hear a sound every time a quest objective is completed by a party member."
	getglobal(PartySoundObjectiveButton:GetName().."Text"):SetText(" Objective Complete");
	PartySoundObjectiveButton.optionKey = "PartySoundObjective";
	PartySoundObjectiveButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local PartySoundObjectiveTestButton = CreateFrame("Button", "SmartQuest_PartySoundObjectiveTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	PartySoundObjectiveTestButton:SetPoint("TOPLEFT", 300, -245);
	PartySoundObjectiveTestButton.tooltip = "Test";
	PartySoundObjectiveTestButton:SetScript("OnClick",SmartQuest.OptionPartySoundObjectiveTest);
	getglobal(PartySoundObjectiveTestButton:GetName().."Text"):SetText("Test");

	local PartySoundDoneButton = CreateFrame("CheckButton", "SmartQuest_PartySoundDoneButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	PartySoundDoneButton:SetPoint("TOPLEFT", 30, -275)
	PartySoundDoneButton.tooltip = "Hear a sound when a party member completes all quest objectives."
	getglobal(PartySoundDoneButton:GetName().."Text"):SetText(" Quest Complete");
	PartySoundDoneButton.optionKey = "PartySoundDone";
	PartySoundDoneButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);
	
	local PartySoundDoneTestButton = CreateFrame("Button", "SmartQuest_PartySoundDoneTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	PartySoundDoneTestButton:SetPoint("TOPLEFT", 300, -275);
	PartySoundDoneTestButton.tooltip = "Test";
	PartySoundDoneTestButton:SetScript("OnClick",SmartQuest.OptionPartySoundDoneTest);
	getglobal(PartySoundDoneTestButton:GetName().."Text"):SetText("Test");

	local PartySoundFailedButton = CreateFrame("CheckButton", "SmartQuest_PartySoundFailedButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	PartySoundFailedButton:SetPoint("TOPLEFT", 30, -305)
	PartySoundFailedButton.tooltip = "Hear a sound when a party member fails a quest."
	getglobal(PartySoundFailedButton:GetName().."Text"):SetText(" Quest Failed");
	PartySoundFailedButton.optionKey = "PartySoundFailed";
	PartySoundFailedButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local PartySoundFailedTestButton = CreateFrame("Button", "SmartQuest_PartySoundFailedTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	PartySoundFailedTestButton:SetPoint("TOPLEFT", 300, -305);
	PartySoundFailedTestButton.tooltip = "Test";
	PartySoundFailedTestButton:SetScript("OnClick",SmartQuest.OptionPartySoundFailedTest);
	getglobal(PartySoundFailedTestButton:GetName().."Text"):SetText("Test");

	local MonitorButton = CreateFrame("CheckButton", "SmartQuest_MonitorButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	MonitorButton:SetPoint("TOPLEFT", 10, -335)
	MonitorButton.tooltip = "Enable group quest monitoring text in the chat frame."
	getglobal(MonitorButton:GetName().."Text"):SetText(" Group Quest Monitoring");
	MonitorButton.optionKey = "Monitor";
	MonitorButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);
	
	local SelfMonitorButton = CreateFrame("CheckButton", "SmartQuest_SelfMonitorButton", ConfigurationPanel, "ChatConfigCheckButtonTemplate");
	SelfMonitorButton:SetPoint("TOPLEFT", 39, -365)
	SelfMonitorButton.tooltip = "Enable self quest monitoring text in the chat frame."
	getglobal(SelfMonitorButton:GetName().."Text"):SetText(" Self Quest Monitoring");
	SelfMonitorButton.optionKey = "SelfMonitor";
	SelfMonitorButton:SetScript("OnClick", SmartQuest.ToggleCheckboxOption);

	local TextColorButton = CreateFrame("Button", "SmartQuest_TextColorButton", ConfigurationPanel, "SmartQuestColorTemplate");
	TextColorButton:SetPoint("TOPLEFT", 39, -395)
	TextColorButton.tooltip = "Change the color of the monitoring text messages."

	local TextColorMessageHeader = ConfigurationPanel:CreateFontString(nil, "ARTWORK","GameFontNormal");
	TextColorMessageHeader:SetPoint("TOPLEFT", 60, -398);
	TextColorMessageHeader:SetTextColor(1.0, 1.0, 1.0);
	TextColorMessageHeader:SetText("Text color");

	local MonitorTextTestButton = CreateFrame("Button", "SmartQuest_MonitorTextTestButton", ConfigurationPanel, "UIPanelButtonTemplate");
	MonitorTextTestButton:SetPoint("TOPLEFT", 300, -335);
	MonitorTextTestButton.tooltip = "Test";
	MonitorTextTestButton:SetScript("OnClick",SmartQuest.OptionMonitorTextTest);
	getglobal(MonitorTextTestButton:GetName().."Text"):SetText("Test");
	
	local ChatFrameText = ConfigurationPanel:CreateFontString("SmartQuest_ChatFrameIdText","ARTWORK","GameFontNormal");
	ChatFrameText:SetPoint("TOPLEFT", 195, -435);
	ChatFrameText:SetText(" ");

	local ChatFrameIdSlider = CreateFrame("Slider", "SmartQuest_ChatFrameIdSlider", ConfigurationPanel, "OptionsSliderTemplate");
	ChatFrameIdSlider:SetPoint("TOPLEFT", 39, -435);
	ChatFrameIdSlider.tooltip = "Output Chat Window";
	ChatFrameIdSlider:SetScript("OnValueChanged",SmartQuest.OptionSetChatFrameId);
	getglobal(ChatFrameIdSlider:GetName().."Text"):SetText("Output Chat Window");
	getglobal(ChatFrameIdSlider:GetName().."High"):SetText(" ");
	getglobal(ChatFrameIdSlider:GetName().."Low"):SetText(" ");
	ChatFrameIdSlider:SetMinMaxValues(1,10);
	ChatFrameIdSlider:SetValueStep(1);
	ChatFrameIdSlider:SetValue(SmartQuest.Setting.ChatFrameId);
	SmartQuest.OptionSetChatFrameIdText(SmartQuest.Setting.ChatFrameId);

	ConfigurationPanel.okay =
		function (self)
			SmartQuest.Setting.MySound = MySoundButton:GetChecked();
			SmartQuest.Setting.PartySound = PartySoundButton:GetChecked();
			SmartQuest.Setting.Monitor = MonitorButton:GetChecked();
			SmartQuest.Setting.SelfMonitor = SelfMonitorButton:GetChecked();
			SmartQuest.Setting.MySoundObjective = MySoundObjectiveButton:GetChecked();
			SmartQuest.Setting.MySoundItem = MySoundItemButton:GetChecked();
			SmartQuest.Setting.MySoundDone = MySoundDoneButton:GetChecked();
			SmartQuest.Setting.MySoundFailed = MySoundFailedButton:GetChecked();
			SmartQuest.Setting.PartySoundObjective = PartySoundObjectiveButton:GetChecked();
			SmartQuest.Setting.PartySoundItem = PartySoundItemButton:GetChecked();
			SmartQuest.Setting.PartySoundDone = PartySoundDoneButton:GetChecked();
			SmartQuest.Setting.PartySoundFailed = PartySoundFailedButton:GetChecked();
			SmartQuest.Setting.TextColor = 
			{
				R = TextColorButton.r;
				G = TextColorButton.g;
				B = TextColorButton.b;
			};
			SmartQuest.Setting.ChatFrameId = ChatFrameIdSlider:GetValue();
			SmartQuest.SaveSettings();
		end
	ConfigurationPanel.cancel = 
		function (self)
			SmartQuest.Setting.MySound = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound;
			SmartQuest.Setting.PartySound = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound;
			SmartQuest.Setting.Monitor = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Monitor;
			SmartQuest.Setting.SelfMonitor = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].SelfMonitor;
			SmartQuest.Setting.MySoundObjective = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundObjective;
			SmartQuest.Setting.MySoundItem = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundItem;
			SmartQuest.Setting.MySoundDone = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundDone;
			SmartQuest.Setting.MySoundFailed = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundFailed;
			SmartQuest.Setting.PartySoundObjective = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundObjective;
			SmartQuest.Setting.PartySoundItem = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundItem;
			SmartQuest.Setting.PartySoundDone = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundDone;
			SmartQuest.Setting.PartySoundFailed = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundFailed;
			SmartQuest.Setting.TextColor = 
			{
				R = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor.R;
				G = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor.G;
				B = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor.B;
			};
			SmartQuest.Setting.ChatFrameId = SmartQuestOptions.Setting[SmartQuest.Data.MeFull].ChatFrameId or SmartQuest.DefaultSetting.ChatFrameId;
			SmartQuest.SaveSettings();
		end
	ConfigurationPanel.default = 
		function (self)
			SmartQuest.ResetDefaults();
			SmartQuest.SaveSettings();
		end
end

function SmartQuest.OptionSetChatFrameId()
	if (not SmartQuest.UIRendered) then
		return;
	end
	SmartQuest.Setting.ChatFrameId = getglobal("SmartQuest_ChatFrameIdSlider"):GetValue();
	getglobal("SmartQuest_ChatFrameIdSlider"):SetValue(SmartQuest.Setting.ChatFrameId);
	SmartQuest.OptionSetChatFrameIdText(SmartQuest.Setting.ChatFrameId)
	SmartQuest.SaveSettings();
end

function SmartQuest.OptionSetChatFrameIdText(iChatFrameId)
	if (not SmartQuest.UIRendered) then
		return;
	end
	getglobal("SmartQuest_ChatFrameIdText"):SetText(SmartQuest.OptionGetChatFrameTitle(iChatFrameId));
end

function SmartQuest.OptionGetChatFrameTitle(iChatFrameId)
	local result = "";
	if (iChatFrameId >= 1 and iChatFrameId <= 10) then
		result = GetChatWindowInfo(iChatFrameId);
	end
	if (string.len(tostring(result)) == 0) then
		result = "Unused Chat Window #"..iChatFrameId
	end
	return result;
end

function SmartQuest.OptionSetColor(button, r, g, b)
	button.r = r;
	button.g = g;
	button.b = b;
	getglobal(button:GetName().."NormalTexture"):SetVertexColor(r, g, b);
	SmartQuest.Setting.TextColor = 
	{
		R = r;
		G = g;
		B = b;
	};
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor = 
	{
		R = SmartQuest.Setting.TextColor.R;
		G = SmartQuest.Setting.TextColor.G;
		B = SmartQuest.Setting.TextColor.B;
	};
end

function SmartQuest.OpenColorPicker(button)
	CloseMenus()
	if (not button) then
	  button = self;
	end
	
	if (ColorPickerFrame) and (ColorPickerFrame.SetupColorPickerAndShow) then
		button.swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB();
			SmartQuest.OptionSetColor(button, r, g, b);
		end
		ColorPickerFrame:SetupColorPickerAndShow(button);
		return;
	end
	
	OpenColorPicker(button);
end

function SmartQuest.Logic(bValue)
	if (bValue) then
		if (bValue == false) then
			return "Off";
		else
			return "On";
		end
	else
		return "Off";
	end
end

function SmartQuest.SaveSettings()
	getglobal("SmartQuest_MySoundButton"):SetChecked(SmartQuest.Setting.MySound);
	getglobal("SmartQuest_PartySoundButton"):SetChecked(SmartQuest.Setting.PartySound);
	getglobal("SmartQuest_MonitorButton"):SetChecked(SmartQuest.Setting.Monitor);
	getglobal("SmartQuest_SelfMonitorButton"):SetChecked(SmartQuest.Setting.SelfMonitor);
	getglobal("SmartQuest_MySoundObjectiveButton"):SetChecked(SmartQuest.Setting.MySoundObjective);
	getglobal("SmartQuest_MySoundItemButton"):SetChecked(SmartQuest.Setting.MySoundItem);
	getglobal("SmartQuest_MySoundDoneButton"):SetChecked(SmartQuest.Setting.MySoundDone);
	getglobal("SmartQuest_MySoundFailedButton"):SetChecked(SmartQuest.Setting.MySoundFailed);
	getglobal("SmartQuest_PartySoundObjectiveButton"):SetChecked(SmartQuest.Setting.PartySoundObjective);
	getglobal("SmartQuest_PartySoundItemButton"):SetChecked(SmartQuest.Setting.PartySoundItem);
	getglobal("SmartQuest_PartySoundDoneButton"):SetChecked(SmartQuest.Setting.PartySoundDone);
	getglobal("SmartQuest_PartySoundFailedButton"):SetChecked(SmartQuest.Setting.PartySoundFailed);
	SmartQuest.OptionSetColor(getglobal("SmartQuest_TextColorButton"), SmartQuest.Setting.TextColor.R, SmartQuest.Setting.TextColor.G, SmartQuest.Setting.TextColor.B);	
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySound = SmartQuest.Setting.MySound;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySound = SmartQuest.Setting.PartySound;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].Monitor = SmartQuest.Setting.Monitor;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].SelfMonitor = SmartQuest.Setting.SelfMonitor;

	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundObjective = SmartQuest.Setting.MySoundObjective;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundItem = SmartQuest.Setting.MySoundItem;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundDone = SmartQuest.Setting.MySoundDone;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].MySoundFailed = SmartQuest.Setting.MySoundFailed;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundObjective = SmartQuest.Setting.PartySoundObjective;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundItem = SmartQuest.Setting.PartySoundItem;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundDone = SmartQuest.Setting.PartySoundDone;
	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].PartySoundFailed = SmartQuest.Setting.PartySoundFailed;

	SmartQuestOptions.Setting[SmartQuest.Data.MeFull].TextColor = 
	{
		R = SmartQuest.Setting.TextColor.R;
		G = SmartQuest.Setting.TextColor.G;
		B = SmartQuest.Setting.TextColor.B;
	};
	if (SmartQuest.UIRendered) then
		SmartQuestOptions.Setting[SmartQuest.Data.MeFull].ChatFrameId = SmartQuest.Setting.ChatFrameId;
	end
end

function SmartQuest.OptionMonitorTextTest()
	local button = getglobal("SmartQuest_TextColorButton");
	local message = "Test message #"..GetTime();
	if (_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]) then
		_G["ChatFrame"..SmartQuest.Setting.ChatFrameId]:AddMessage("[SQ] "..message, button.r, button.g, button.b);
	end
end

function SmartQuest.OptionMySoundItemTest()
	PlaySoundFile(SmartQuest.Sound["item"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: My Quest Item Collected");
end

function SmartQuest.OptionMySoundObjectiveTest()
	PlaySoundFile(SmartQuest.Sound["objective"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: My Quest Objective Completed");
end

function SmartQuest.OptionMySoundDoneTest()
	PlaySoundFile(SmartQuest.Sound["quest_done"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: My Quest Completed");
end

function SmartQuest.OptionMySoundFailedTest()
	PlaySoundFile(SmartQuest.Sound["quest_failed"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: My Quest Failed");
end

function SmartQuest.OptionPartySoundItemTest()
	PlaySoundFile(SmartQuest.Sound["item_group"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: Party Quest Item Collected");
end

function SmartQuest.OptionPartySoundObjectiveTest()
	PlaySoundFile(SmartQuest.Sound["objective_group"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: Party Quest Objective Completed");
end

function SmartQuest.OptionPartySoundDoneTest()
	PlaySoundFile(SmartQuest.Sound["quest_done_group"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: Party Quest Completed");
end

function SmartQuest.OptionPartySoundFailedTest()
	PlaySoundFile(SmartQuest.Sound["quest_failed_group"], "Master");
	SmartQuest.CommPrint("[SQ] Played sound: Party Quest Failed");
end
