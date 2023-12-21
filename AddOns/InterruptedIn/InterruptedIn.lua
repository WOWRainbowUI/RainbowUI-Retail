local InterruptedInFrame;
local IIN_StartTime = 0;
local IIN_TempList = { };
local IIN_RunningList = { };

-- Configuration Parameters
local IIN_Yell = true;						-- when player isn't in party/raid, use 'yell' to announce
local IIN_Say = false;						-- as above, use 'say'. set both INN_Yell and INN_Say to false will not announce in solo.
local IIN_SetAltArrowKeyMode = false;		-- Must or not to use the alt key to move arrow in ChatFrameEditBox.
--local IIN_HideMainBarLeftEndCap = true;		-- Hide the Left Cap in MainBar
--local IIN_HideMainBarRightEndCap = true;	-- Hide the Right Cap in MainBar
--local IIN_CameraDistanceMax = 25;			-- The CameraDistance. Default value is 15(yards), Max valuse is 50.


function InterruptedIn_OnLoad(self)
	if not IIN_SetAltArrowKeyMode then DEFAULT_CHAT_FRAME.editBox:SetAltArrowKeyMode(false) end;
	if IIN_HideMainBarLeftEndCap then MainMenuBarLeftEndCap:Hide() end;
	if IIN_HideMainBarRightEndCap then MainMenuBarRightEndCap:Hide() end;
	--SetCVar("CameraDistanceMax", IIN_CameraDistanceMax);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_DEAD");
	self:RegisterEvent("ADDON_LOADED");

	SlashCmdList["INTERRUPTEDIN"] = InterruptedIn_SlashHandler;
	SLASH_INTERRUPTEDIN1 = "/iin";
end

function InterruptedIn_OnEvent(self, event, ...)
	if (event == "ADDON_LOADED") then
		local arg1, arg2 = ...;
		if (arg1 == "InterruptedIn") then
			-- DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn LOADED ----");
			InterruptedInFrame = CreateFrame("FRAME", "IINFrame");
		end
	end

	if (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD") then
		-- DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn CLEARED ----");
		InterruptedInFrame:SetScript("OnUpdate", nil);
	end
end

function InterruptedIn_SlashHandler(msg)
	-- DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn SlashHandler ----");
	local sBtnClick = GetMouseButtonClicked();
	local btn_para1, btn_para2 = msg:match("^.*%[btn:(%d)%]%s+(.*)$");
	if btn_para1 ~= nil then
		if sBtnClick == "LeftButton" then sBtnClick = "Button1" end;
		if sBtnClick == "RightButton" then sBtnClick = "Button2" end;
		if sBtnClick == "MiddleButton" then sBtnClick = "Button3" end;
		btn_para1 = "Button"..tostring(btn_para1);
		if btn_para1 == sBtnClick then 
			msg = btn_para2;
		else
			msg = nil;
		end
	end

	if (msg ~= nil) then
		local cmd_para1, word_para2 = strsplit(" ", msg, 2);
		local sec_para1 = tonumber(cmd_para1);
		cmd_para1 = string.lower(cmd_para1);
		if (word_para2 == nil) then word_para2 = "nil" end;
		if (sec_para1 == nil) then sec_para1 = -1 end;
		-- DEFAULT_CHAT_FRAME:AddMessage("cmd_para1="..cmd_para1.." / word_para2="..word_para2);
		if (sec_para1 >= 0) then
			-- Add saying to list
			-- DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn Set Table ----");
			local ListItem = { Sec, Word, Target };
			ListItem.Sec = sec_para1;
			ListItem.Word = word_para2;
			ListItem.Target = "";
			local target_spara1, word_spara2 = word_para2:match("^%%([aefgitspwyAEFGITSPWY5-9])%s+(.*)$");
			if target_spara1 ~= nil then
				ListItem.Word = word_spara2;
				target_spara1 = string.lower(target_spara1);
				if (target_spara1 == "t") then
					ListItem.Target = UnitName("target");
					if ListItem.Target == nil then ListItem.Target = UnitName("player") end;
				elseif (target_spara1 == "f") then
					ListItem.Target = UnitName("focus");
					if ListItem.Target == nil then ListItem.Target = UnitName("player") end;
				elseif (target_spara1 == "w") then
					local target_sspara1, word_sspara2 = strsplit(" ", word_spara2, 2);
					ListItem.Target = target_sspara1;
					ListItem.Word = word_sspara2;
				else
					ListItem.Target = target_spara1;
				end
			end
			table.insert(IIN_TempList, ListItem);
			-- DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn Set Table End ----");
		elseif (cmd_para1 == "start") then
			-- Start to countdown the list
			InterruptedIn_Start();
		elseif (cmd_para1 == "stop") then
			-- Stop to countdown the list
			InterruptedIn_Stop();
		elseif (cmd_para1 == "nosolo") then
			IIN_Say = false;
			IIN_Yell = false;
		elseif (cmd_para1 == "yell") then
			IIN_Say = false;
			IIN_Yell = true;
		elseif (cmd_para1 == "say") then
			IIN_Say = true;
			IIN_Yell = false;
		elseif (cmd_para1 == "print") then
			InterruptedIn_PrintTable();
		elseif (cmd_para1 == "rcd") then
			-- local cond1_spara1, cond2_spara1, word_spara2 = word_para2:match("^%[(.*):(.*)%]%s+(.*)$");
			local RCD_SpellCD = "";
			local target_spara1, word_spara2 = word_para2:match("^%%([aefginrtspwyAEFGINRTSPWY5-9])%s+(.*)$");
			if target_spara1 ~= nil then
				target_spara1 = string.lower(target_spara1);
				local RCD_Target, RCD_Type = "", "";
				if (target_spara1 == "t") then
					RCD_Target = UnitName("target");
					RCD_Type = "whisper";
				elseif (target_spara1 == "e") then
					RCD_Target = target_spara1;
					RCD_Type = "emote";
				elseif (target_spara1 == "f") then
					RCD_Target = UnitName("focus");
					RCD_Type = "whisper";
				elseif (target_spara1 == "r") then
					RCD_Target = Sub_GetRaidLeader();
					RCD_Type = "whisper";
				elseif (target_spara1 == "w") then
					local target_sspara1, word_sspara2 = strsplit(" ", word_spara2, 2);
					word_spara2 = word_sspara2;
					RCD_Target = target_sspara1;
					RCD_Type = "whisper";
				elseif (target_spara1 == "i") then
					RCD_Target = "";
					DEFAULT_CHAT_FRAME:AddMessage(Sub_ReportCD(word_spara2), 1, 1, 0);
				elseif (target_spara1 == "s") then
					RCD_Target = target_spara1;
					RCD_Type = "say";
				elseif (target_spara1 == "y") then
					RCD_Target = target_spara1;
					RCD_Type = "yell";
				elseif (target_spara1 == "p") then
					RCD_Target = target_spara1;
					RCD_Type = "party";
				elseif (target_spara1 == "n") then
					RCD_Target = target_spara1;					
					RCD_Type = "instance_chat";
				elseif (target_spara1 == "a") then
					RCD_Target = target_spara1;
					RCD_Type = "raid";					
				elseif (target_spara1 == "g") then
					RCD_Target = target_spara1;
					RCD_Type = "guild";
				else
					RCD_Target = target_spara1;
					RCD_Type = "channel";
				end
				if (RCD_Target ~= "") then
					RCD_SpellCD = Sub_ReportCD(word_spara2);
					SendChatMessage(RCD_SpellCD, RCD_Type, nil, RCD_Target);
				end
			else
				RCD_SpellCD = Sub_ReportCD(word_para2);
				Sub_AutoSelectChannel(RCD_SpellCD);
			end
		elseif (cmd_para1 == "btn") then
			InterruptedIn_MouseButtonClicked(msg);
		else
			-- Show some help
			InterruptedIn_ShowHelp();
		end
	end
end

function InterruptedIn_PrintTable()
	DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn_PrintTable ----");
	table.foreach(IIN_TempList,
		function(i, v)
			DEFAULT_CHAT_FRAME:AddMessage("IIN_TempList["..i.."] Sec="..IIN_TempList[i].Sec.." / Word="..IIN_TempList[i].Word.." / Target="..IIN_TempList[i].Target);
		end
	)
end

function InterruptedIn_OnUpdate()
	local ListNum = #IIN_RunningList;
	local ListSec = 0;
	local SelChannel = 0;
	local SelChannelText = "";
	-- DEFAULT_CHAT_FRAME:AddMessage("ListNum="..ListNum);
	if ListNum > 0 then
		ListSec = tonumber(IIN_RunningList[1].Sec);
		if ListSec >= 0 then
			local TriggerTime = IIN_StartTime + ListSec;
			-- DEFAULT_CHAT_FRAME:AddMessage("IIN_StartTime="..IIN_StartTime.." / ListSec="..ListSec.." / TriggerTime="..TriggerTime.." / GetTime()="..GetTime());
			if TriggerTime <= GetTime() then
				SelChannel = tonumber(IIN_RunningList[1].Target);
				SelChannelText = IIN_RunningList[1].Target;
				if SelChannel == nil then SelChannel = 0 end;
				-- DEFAULT_CHAT_FRAME:AddMessage("RunningList[1].Target="..IIN_RunningList[1].Target.." / SelChannel="..SelChannel);
				
				-- Parse The LootSlot Item
				local sWord = IIN_RunningList[1].Word;
				local iStart = sWord:find("%%[lL]");
				if (iStart ~= nil) then
					-- DEFAULT_CHAT_FRAME:AddMessage("iStart = "..iStart);
					local linkstext = "";
					for index = 1, GetNumLootItems() do
						if (LootSlotHasItem(index)) then
							local iteminfo = GetLootSlotLink(index);
							if linkstext == nil then
								linkstext = "";
							else
								linkstext = linkstext..iteminfo;
								-- DEFAULT_CHAT_FRAME:AddMessage("linkstext = "..linkstext);
								break;
							end
						end
					end
					IIN_RunningList[1].Word = sWord:gsub("%%[lL]",linkstext);
					-- DEFAULT_CHAT_FRAME:AddMessage("sWord = "..IIN_RunningList[1].Word);
				end
				
				-- Parse The Container(Bags) Item
				local sWord = IIN_RunningList[1].Word;
				local iBag, iSlot = sWord:match("^.*%%[bB](%d)%-(%d+).*$");
				if (iBag ~= nil) then
					-- DEFAULT_CHAT_FRAME:AddMessage("iBag="..iBag.." / iSlot="..iSlot);
					local linkstext = C_Container.GetContainerItemLink(iBag, iSlot);
					if linkstext == nil then linkstext = "" end;
					-- DEFAULT_CHAT_FRAME:AddMessage("linkstext = "..linkstext);
					IIN_RunningList[1].Word = sWord:gsub("%%[bB]%d%-%d+",linkstext);
					-- DEFAULT_CHAT_FRAME:AddMessage("sWord = "..IIN_RunningList[1].Word);
				end

				
				if (IIN_RunningList[1].Target == "") then
					Sub_AutoSelectChannel(IIN_RunningList[1].Word);
				elseif (5 <= SelChannel and SelChannel <=9 ) then
					SendChatMessage(IIN_RunningList[1].Word, "channel", nil, IIN_RunningList[1].Target);
				elseif (SelChannelText == "e") then
					SendChatMessage(IIN_RunningList[1].Word, "emote");
				elseif (SelChannelText == "i") then
					DEFAULT_CHAT_FRAME:AddMessage(IIN_RunningList[1].Word, 1, 1, 0);
				elseif (SelChannelText == "s") then
					SendChatMessage(IIN_RunningList[1].Word, "say");
				elseif (SelChannelText == "y") then
					SendChatMessage(IIN_RunningList[1].Word, "yell");
				elseif (SelChannelText == "p") then
					SendChatMessage(IIN_RunningList[1].Word, "party");
				elseif (SelChannelText == "a") then
					SendChatMessage(IIN_RunningList[1].Word, "raid");
				elseif (SelChannelText == "n") then
					SendChatMessage(IIN_RunningList[1].Word, "instance_chat");
				elseif (SelChannelText == "g") then
					SendChatMessage(IIN_RunningList[1].Word, "guild");
				else
					SendChatMessage(IIN_RunningList[1].Word, "whisper", nil, IIN_RunningList[1].Target);
				end
				table.remove(IIN_RunningList, 1);
			end
		end
	else
		InterruptedInFrame:SetScript("OnUpdate", nil);
		IIN_RunningList = { };
	end 
end

function Sub_AutoSelectChannel(SayWords)
	local SelChannel = "";
	if IsInRaid() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then 
		SelChannel = "RAID_WARNING";
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then		
		SelChannel = "INSTANCE_CHAT";
	elseif IsInRaid() then		
		SelChannel = "RAID";
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SelChannel = "PARTY";
	elseif IIN_Yell then
		SelChannel = "YELL";
	elseif IIN_Say then
		SelChannel = "SAY";
	end
	if (SelChannel ~= "") then
		SendChatMessage(SayWords, SelChannel);
	end
end

function Sub_GetRaidLeader()
	local RaidLeader = "";
	if UnitInRaid("player") or IsInInstance() then
		local RaidMemberNum = GetNumGroupMembers();
		for i=1,RaidMemberNum do
			local raname, rarank = GetRaidRosterInfo(i);
			if (not raname) then break end;
			if (rarank == 2) then
				RaidLeader = raname;
				break;
			end
		end
	end
	print(RaidLeader)
	return RaidLeader;
end

function Sub_ReportCD(SpellNameWords)
	local SpellNames = { strsplit(";", SpellNameWords); };
	local CurrTime = GetTime();
	local RCD_SpellCD = "";
	for v in string.gmatch(SpellNameWords, "[^ ;]+") do
		if (v ~= nil and v ~= "") then
			local SecTime, DurTime = GetSpellCooldown(v);
			local RCD_SpellLink = GetSpellLink(v);
			if SecTime == nil then SecTime = 0 end;
			if RCD_SpellLink == nil then RCD_SpellLink = "nil" end;
			if (SecTime > 0) then
				if RCD_SpellCD ~= "" then RCD_SpellCD = RCD_SpellCD.." / " end;
				RCD_SpellCD = RCD_SpellCD..RCD_SpellLink.." CD,Time:"..SecondsToTime(SecTime+DurTime-CurrTime);
			else
				if RCD_SpellCD ~= "" then RCD_SpellCD = RCD_SpellCD.." / " end;
				RCD_SpellCD = RCD_SpellCD..RCD_SpellLink.." CD OK!";
			end
		end
	end
	return RCD_SpellCD;
end

function InterruptedIn_Start()
	-- DEFAULT_CHAT_FRAME:AddMessage(" SetScript(OnUpdate, nil); ");
	InterruptedInFrame:SetScript("OnUpdate", nil);
	IIN_StartTime = GetTime();
	IIN_RunningList = IIN_TempList;
	IIN_TempList = { };
	InterruptedInFrame:SetScript("OnUpdate", InterruptedIn_OnUpdate);
	-- DEFAULT_CHAT_FRAME:AddMessage(" SetScript(OnUpdate, InterruptedIn_OnUpdate); ");
end

function InterruptedIn_Stop()
	InterruptedInFrame:SetScript("OnUpdate", nil);
	IIN_RunningList = { };
	IIN_TempList = { };
end

function InterruptedIn_ShowHelp()
	-- DEFAULT_CHAT_FRAME:AddMessage("---- InterruptedIn_ShowHelp ----");
	local IIN_Ver = GetAddOnMetadata("InterruptedIn", "Version");
	DEFAULT_CHAT_FRAME:AddMessage(IIN_XCMD_CMDHELP.TITLE..IIN_Ver);
	for i, v in ipairs(IIN_XCMD_CMDHELP["HELP"]) do
		DEFAULT_CHAT_FRAME:AddMessage(v);
	end
end

function InterruptedIn_MouseButtonClicked(msg)
	local sBtnClick = GetMouseButtonClicked();
	DEFAULT_CHAT_FRAME:AddMessage("Clicked : "..sBtnClick.." / msg : "..msg);
	-- local btn_para1, btn_para2 = msg:match("^.*%[btn:(%d)%]%s+(.*)$");
	-- DEFAULT_CHAT_FRAME:AddMessage("btn_para1 : "..btn_para1.." / btn_para2 : "..btn_para2);
end


