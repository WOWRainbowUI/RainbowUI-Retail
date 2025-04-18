VUHDO_COMMS_VERSION = 1;

local sReceiveMode = 1;

local sMaxPacketSize = 254;
local sTrivialTimeout = 3;
local sUserDialogTimeout = 15;
local sMaxReceiveSize = 100000;

local sFieldSeparator = "!";
local sCommandSeparator = "?";

local sPrefixCommand = "cmd";
local sPrefixRequest = "rqu";
local sPrefixReply   = "rpy";

local sCmdAbortComms = sPrefixCommand .. "ABORT";

local sCmdVersionRequest = sPrefixRequest .. "VERSION";
local sCmdVersionReply   = sPrefixReply   .. "VERSION"; -- CommsVersion, VuhDo version, locale

local sCmdUserYesNoRequest = sPrefixRequest .. "YESNO";
local sCmdUserYesNoReply   = sPrefixReply   .. "YESNO";

VUHDO_sCmdProfileDataChunk = sPrefixCommand .. "P_DAT";
VUHDO_sCmdProfileDataEnd   = sPrefixCommand .. "P_END";

VUHDO_sCmdKeyLayoutDataChunk = sPrefixCommand .. "K_DAT";
VUHDO_sCmdKeyLayoutDataEnd   = sPrefixCommand .. "K_END";

local sRequestsInProgress = { --[[ [unitName][replyType] = { endTime, aResumable } ]] };
local sRepliesReceived = { --[[ [unitName][replyType] = replyString ]] };
local sUserData = { --[[ [unitName][requestType] = userData ]] };
local sBlockedSenders = { --[[ [unitName] = true ]] };

local sBusyUnitName = nil;
local sNumChunks = 0;

local sCurrentChunkTag = nil;
local sCurrentEndTag = nil;
local sCurrentQuestionText = nil;

--
function VUHDO_commsSetReceiveModeEnabled(aFlag)
	sReceiveMode = aFlag and -1 or 1;
end



--
local function VUHDO_setUserData(aUnitName, aTag, someData)
	if (sUserData[aUnitName] == nil) then
		sUserData[aUnitName] = {};
	end

	sUserData[aUnitName][aTag] = someData;
end



--
local function VUHDO_getUserData(aUnitName, aTag)
	return (sUserData[aUnitName] or {})[aTag];
end



--
local function VUHDO_setRequestInfo(aUnitName, aReplyType, aTimeout, aResumable)
	if (sRequestsInProgress[aUnitName] == nil) then
		sRequestsInProgress[aUnitName] = {};
	end

	if ((aTimeout or 0) > 0) then
		sRequestsInProgress[aUnitName][aReplyType] = { GetTime() + aTimeout, aResumable };
	else
		sRequestsInProgress[aUnitName][aReplyType] = nil;
	end
end



--
local function VUHDO_setReplyData(aUnitName, aReplyType, someData)
	if (sRepliesReceived[aUnitName] == nil) then
		sRepliesReceived[aUnitName] = { };
	end

	sRepliesReceived[aUnitName][aReplyType] = someData;
end



--
local function VUHDO_getReplyData(aUnitName, aReplyType)
	if (sRepliesReceived[aUnitName] == nil) then
		return nil;
	end

	return sRepliesReceived[aUnitName][aReplyType];
end



--
function VUHDO_removeCommsData(aUnitName)
	if (aUnitName ~= nil) then
		sUserData[aUnitName] = nil;
		sRequestsInProgress[aUnitName] = nil;
		sRepliesReceived[aUnitName] = nil;
		if (sBusyUnitName == aUnitName) then
			sBusyUnitName = nil;
			sNumChunks = 0;
		end
	else
		table.wipe(sUserData);
		table.wipe(sRequestsInProgress);
		table.wipe(sRepliesReceived);
		sBusyUnitName = nil;
		sNumChunks = 0;
	end
end



--
function VUHDO_getCommsData(aUnitName)

	if (aUnitName ~= nil) then
		VUHDO_xMsg("Dumping comms data for", aUnitName);
		VUHDO_xMsg("sUserData", VUHDO_tableToString(sUserData[aUnitName]));
		VUHDO_xMsg("sRequestsInProgress", VUHDO_tableToString(sRequestsInProgress[aUnitName]));
		VUHDO_xMsg("sRepliesReceived", VUHDO_tableToString(sRepliesReceived[aUnitName]));
		if (sBusyUnitName == aUnitName) then
			VUHDO_xMsg("sBusyUnitName", sBusyUnitName);
			VUHDO_xMsg("sNumChunks", sNumChunks);
		end
	else
		VUHDO_xMsg("Dumping comms data");
		VUHDO_xMsg("sUserData", (sUserData));
		VUHDO_xMsg("sRequestsInProgress", VUHDO_tableToString(sRequestsInProgress));
		VUHDO_xMsg("sRepliesReceived", VUHDO_tableToString(sRepliesReceived));
		if (sBusyUnitName == aUnitName) then
			VUHDO_xMsg("sBusyUnitName", sBusyUnitName);
			VUHDO_xMsg("sNumChunks", sNumChunks);
		end
	end

end



--
local function VUHDO_getFieldsFromReply(aUnitName, aReplyType)
	local tUnitReplies = sRepliesReceived[aUnitName];

	if (tUnitReplies == nil) then
		return nil;
	end

	local tReply = tUnitReplies[aReplyType];
	if (tReply == nil) then
		return nil;
	end

	return strsplit(sFieldSeparator, tReply);
end



--
local function VUHDO_sendMessage(aUnitName, aMessage, aCallbackFn, aCallbackArg)
	ChatThrottleLib:SendAddonMessage("BULK", VUHDO_COMMS_PREFIX, aMessage, "WHISPER", aUnitName, nil, aCallbackFn, aCallbackArg);
end



--
local function VUHDO_sendDirectMessage(aUnitName, aMessage)
	C_ChatInfo.SendAddonMessage(VUHDO_COMMS_PREFIX, aMessage, "WHISPER", aUnitName);
end



--
function VUHDO_sendAbortMessage(aUnitName)
	VUHDO_sendDirectMessage(aUnitName, sCmdAbortComms);
end



--
local function VUHDO_trivialRequest(aUnitName, aRequest, aReplyType, aTimeout, aResumable)
	VUHDO_sendMessage(aUnitName, aRequest, nil);
	VUHDO_setRequestInfo(aUnitName, aReplyType, aTimeout, aResumable);
end



--
local function VUHDO_buildMessage(aCommand, ...)
	local tData = aCommand .. sCommandSeparator;

	for tCnt = 1, select('#', ...) do
		tData = tData .. select(tCnt, ...) .. (tCnt < select('#', ...) and sFieldSeparator or "");
	end

	return tData;
end



--
local function VUHDO_allDataSentCallback()
	VUHDO_Msg("完成。現在可以再次傳送給這位玩家。");
	VuhDoLnfShareDialog:Hide();
end



--
local function VUHDO_dataChunkCallback(aProgress)
	VuhDoLnfShareDialogTransmitPaneProgressBar:SetProgress(aProgress[1], aProgress[2]);
end



--
local function VUHDO_sendPacketedMessage(aUnitName, someData, aDataCommand, anEndCommand)
	local tIndex = 0;
	local tChunk;
	local tLength;
	local tPackets;
	local tCurPacket = 0;
	local tMaxLength = sMaxPacketSize - #VUHDO_COMMS_PREFIX - #aDataCommand - #sCommandSeparator;

	tPackets = floor(#someData / (tMaxLength + 1));
	VUHDO_Msg("正在傳送 " .. tPackets .. " 個封包給 " .. aUnitName .. "。");

	while (tIndex < #someData) do
		if (tIndex + tMaxLength < #someData) then
			tLength = tMaxLength;
		else
			tLength = #someData - tIndex;
		end

		tChunk = strsub(someData, tIndex + 1, tIndex + tLength);
		VUHDO_sendMessage(aUnitName, VUHDO_buildMessage(aDataCommand, tChunk), VUHDO_dataChunkCallback, { tCurPacket, tPackets });
		tIndex = tIndex + tLength;
		tCurPacket = tCurPacket + 1;
	end

	VUHDO_sendMessage(aUnitName, anEndCommand, VUHDO_allDataSentCallback);
end



--
local function VUHDO_requestVuhdoVersion(aUnitName, aResumable)
	VUHDO_trivialRequest(aUnitName, sCmdVersionRequest, sCmdVersionReply, sTrivialTimeout, aResumable);
end



--
local function VUHDO_isVersionCompatible(aUnitName)
	local tIsCompatible = true;
	local tCommsVersion, tVuhDoVersion, tLocale = VUHDO_getFieldsFromReply(aUnitName, sCmdVersionReply);

	if (tCommsVersion == nil or tVuhDoVersion == nil or tLocale == nil) then
		VUHDO_Msg("程序中止：版本檢查不通過。", 1, 0.4, 0.4);
		return false;
	end

	if (VUHDO_COMMS_VERSION ~= tonumber(tCommsVersion)) then
		VUHDO_Msg("程序中止：VuhDo 資料傳輸版本不符合! 請使用相同版本的 VuhDo。", 1, 0.4, 0.4);
		tIsCompatible = false;
	end

	local tMyVersion, tOtherVersion;
	if (tonumber(VUHDO_VERSION) ~= nil and tonumber(tVuhDoVersion) ~= nil) then
		tMyVersion, tOtherVersion = tonumber(VUHDO_VERSION), tonumber(tVuhDoVersion);
	else
		tMyVersion, tOtherVersion = tostring(VUHDO_VERSION), tostring(tVuhDoVersion);
	end

	if (tMyVersion ~= tOtherVersion) then
		VUHDO_Msg("程序中止：VuhDo 版本不符合。請使用相同版本的 VuhDo! (我的是：" .. tMyVersion .. " / 接收者的是：" .. tOtherVersion .. ")", 1, 0.4, 0.4);
		tIsCompatible = false;
	end

	if (GetLocale() ~= tLocale) then
		VUHDO_Msg("程序中止：介面語言不符合。傳送者的語言是 " .. tLocale, 1, 0.4, 0.4);
		tIsCompatible = false;
	end

	if (tIsCompatible) then
		VUHDO_Msg("-- " .. aUnitName .. " 的 VuhDo 是相容的版本。");
	else
		VuhDoLnfShareDialog:Hide();
	end

	return tIsCompatible;
end



--
local function VUHDO_requestUserYesNoQuestion(aUnitName, aQuestion, aResumable)
	local tRequest = VUHDO_buildMessage(sCmdUserYesNoRequest, aQuestion);
	VUHDO_trivialRequest(aUnitName, tRequest, sCmdUserYesNoReply, sUserDialogTimeout, aResumable);
end



--
local function VUHDO_confirmedUserYesNoQuestion(aUnitName)
	local tAnswer = VUHDO_getFieldsFromReply(aUnitName, sCmdUserYesNoReply);
	if (tostring(VUHDO_YES) == tAnswer) then
		VUHDO_Msg("-- 使用者 " .. aUnitName .. " 已同意傳送資料。");
		return true;
	else
		VUHDO_Msg("程序中止：使用者 " .. aUnitName .. " 已拒絕傳送資料。", 1, 0.4, 0.4);
		VuhDoLnfShareDialog:Hide();
		return false;
	end
end



--
function VUHDO_compressForSending(aTable)
	local compressedString = VUHDO_compressAndPackTable(aTable);
	local encodedString = VUHDO_LibCompressEncode:Encode(compressedString);

	return encodedString;
end



--
function VUHDO_decompressFromSending(aString)
	local decodedString = VUHDO_LibCompressEncode:Decode(aString);
	local decompressedTable = VUHDO_decompressIfCompressed(decodedString);

	return decompressedTable;
end



--
local function VUHDO_doShareResumeAcceptQuestion(aUnitName)
	if (not VUHDO_confirmedUserYesNoQuestion(aUnitName)) then
		VUHDO_removeCommsData(aUnitName);
		return;
	end

	local tData = VUHDO_getUserData(aUnitName, sCurrentChunkTag);
	VUHDO_sendPacketedMessage(aUnitName, VUHDO_compressForSending(tData), sCurrentChunkTag, sCurrentEndTag);
end



--
local function VUHDO_doShareResumeVersion(aUnitName)
	if (not VUHDO_isVersionCompatible(aUnitName)) then
		VUHDO_removeCommsData(aUnitName);
		return;
	end

	VUHDO_requestUserYesNoQuestion(aUnitName, sCurrentQuestionText, VUHDO_doShareResumeAcceptQuestion);
end




--
function VUHDO_startShare(aUnitName, aTable, aChunkTag, anEndTag, aQuestionText)
	sCurrentChunkTag = aChunkTag;
	sCurrentEndTag = anEndTag;
	sCurrentQuestionText = aQuestionText;

	VUHDO_setUserData(aUnitName, aChunkTag, aTable);
	VUHDO_requestVuhdoVersion(aUnitName, VUHDO_doShareResumeVersion);
end



--
local function VUHDO_addReplyData(aUnitName, aType, someNewData)
	local tReplyData = VUHDO_getReplyData(aUnitName, aType) or "";

	tReplyData = tReplyData .. someNewData;

	if (#tReplyData > sMaxReceiveSize) then
		VUHDO_Msg("程序中止：從使用者 " .. aUnitName .. " 接收的資料量已超出允許的最大上限!", 1, 0.4, 0.4);
		sBlockedSenders[aUnitName] = true;
		VUHDO_sendMessage(aUnitName, sCmdAbortComms, nil);
		VUHDO_removeCommsData(aUnitName);
		return;
	end

	VUHDO_setReplyData(aUnitName, aType, tReplyData);
end


--
local function VUHDO_handleCommandReceived(aSenderName, aCommand)
	local tCommandType, tData = strsplit(sCommandSeparator, aCommand, 2);

	if (sCmdAbortComms == tCommandType) then
		VUHDO_removeCommsData(aSenderName);
		VuhDoYesNoFrame:Hide();
		VUHDO_Msg("停止傳送資料，由 " .. aSenderName);
	else
		if(VUHDO_sCmdProfileDataChunk == tCommandType) then
			VUHDO_addReplyData(aSenderName, VUHDO_sCmdProfileDataChunk, tData);
			if (sNumChunks % 20 == 0) then
				VUHDO_Msg("正在接收設定檔資料：" .. strrep(".", sNumChunks / 20 + 1));
			end
			sNumChunks = sNumChunks + 1;

		elseif(VUHDO_sCmdProfileDataEnd == tCommandType) then
			local tProfile = VUHDO_decompressFromSending(VUHDO_getReplyData(aSenderName, VUHDO_sCmdProfileDataChunk));

			local tName = tProfile["NAME"];
			if (VUHDO_getProfileNamedCompressed(tName) ~= nil) then
				local tPos = strfind(tName, ": ", 1, true);
				if (tPos ~= nil) then
					tName = strsub(tName, tPos + 2);
				end

				tProfile["NAME"] = VUHDO_createNewProfileName(tName, aSenderName);
			end
			tinsert(VUHDO_PROFILES, tProfile);

			VUHDO_Msg("資料傳送完成。設定檔 \"" .. tProfile["NAME"] .. "\" 已加入。");
			VUHDO_removeCommsData(aSenderName);

		elseif(VUHDO_sCmdKeyLayoutDataChunk == tCommandType) then
			VUHDO_addReplyData(aSenderName, VUHDO_sCmdKeyLayoutDataChunk, tData);
		elseif(VUHDO_sCmdKeyLayoutDataEnd == tCommandType) then
			local tKeyLayout = VUHDO_decompressFromSending(VUHDO_getReplyData(aSenderName, VUHDO_sCmdKeyLayoutDataChunk));
			while (VUHDO_SPELL_LAYOUTS[tKeyLayout[1]] ~= nil) do
				tKeyLayout[1] = aSenderName .. ": " .. tKeyLayout[1];
			end
			VUHDO_Msg("資料傳送完成。按鍵配置 \"" .. tKeyLayout[1] .. "\" 已加入。");
			VUHDO_SPELL_LAYOUTS[tKeyLayout[1]] = tKeyLayout[2];
			VUHDO_removeCommsData(aSenderName);
		else
			VUHDO_Msg("已阻擋無效的 VuhDo 指令，來自於 " .. aSenderName .. "。");
			sBlockedSenders[aSenderName] = true;
		end
	end
end



--
local function VUHDO_yesNoCommsCallback(aDecision)
	local tMessage = VUHDO_buildMessage(sCmdUserYesNoReply, aDecision);
	VUHDO_sendMessage(VuhDoYesNoFrame:GetAttribute("senderName"), tMessage, nil);
end



--
local function VUHDO_handleRequestReceived(aSenderName, aRequest)
	local tRequestType, tData = strsplit(sCommandSeparator, aRequest, 2);

	if (sCmdVersionRequest == tRequestType) then
		local tMessage = VUHDO_buildMessage(sCmdVersionReply, VUHDO_COMMS_VERSION, VUHDO_VERSION, GetLocale());
		VUHDO_sendMessage(aSenderName, tMessage, nil);
	elseif(sCmdUserYesNoRequest == tRequestType) then
		VuhDoYesNoFrameText:SetText(tData);
		VuhDoYesNoFrame:SetAttribute("callback", VUHDO_yesNoCommsCallback);
		VuhDoYesNoFrame:SetAttribute("senderName", aSenderName);
		VuhDoYesNoFrame:Show();
	else
		VUHDO_xMsg("Unknown request ", aRequest, "from", aSenderName);
	end
end



--
local function VUHDO_handleReplyReceived(aSenderName, aMessage)
	local tReplyType, tData = strsplit(sCommandSeparator, aMessage, 2);

	if (tReplyType == nil or tData == nil) then
		VUHDO_xMsg("3. Invalid VuhDo message received from", aSenderName, aMessage);
		return;
	end

	if (sRequestsInProgress[aSenderName] == nil or sRequestsInProgress[aSenderName][tReplyType] == nil) then
		VUHDO_xMsg("No such reply expected from ", aSenderName, aMessage);
		return;
	end

	VUHDO_setReplyData(aSenderName, tReplyType, tData);
	local tResumable = sRequestsInProgress[aSenderName][tReplyType][2];
	sRequestsInProgress[aSenderName][tReplyType] = nil;
	if (tResumable ~= nil) then
		tResumable(aSenderName);
	end
end



--
function VUHDO_parseVuhDoMessage(aSenderName, aMessage)

	if (sBlockedSenders[aSenderName]) then
		if (sReceiveMode < 4) then
			VUHDO_Msg("阻擋來自於 " .. aSenderName .. " 的資料傳送。請輸入 /reload 來重置。", 1, 0.4, 0.4);
			sReceiveMode = 4;
		end

		return;
	end

	if (not VUHDO_CONFIG["IS_SHARE"]) then
		if (sReceiveMode > 0 and sReceiveMode < 4) then
			VUHDO_Msg("已阻擋來自於 " .. aSenderName .. "的資料傳送。VuhDo 設定選項 => 工具  => 分享被停用。");
			sReceiveMode = sReceiveMode + 1;
		end

		return;
	end

	if (sReceiveMode > 0 and sReceiveMode < 4) then
		VUHDO_Msg("已阻擋來自於 " .. aSenderName .. " 的資料傳送。VuhDo 設定選項視窗必須保持開啟。");
		sReceiveMode = sReceiveMode + 1;
		return;
	elseif(sReceiveMode > 0) then
	  return; -- Silently fail, no spamming
	end

	if (strlen(aMessage or "") < 4) then
		VUHDO_xMsg("1. Invalid VuhDo message received from", aSenderName, aMessage);
		return;
	end
	local tPrefix = strsub(aMessage, 1, 3);

	if ((sBusyUnitName or aSenderName) ~= aSenderName) then
		return;
	end

	sBusyUnitName = aSenderName;

	if (sPrefixCommand == tPrefix) then
		VUHDO_handleCommandReceived(aSenderName, aMessage);
	elseif(sPrefixRequest == tPrefix) then
		VUHDO_handleRequestReceived(aSenderName, aMessage);
	elseif(sPrefixReply == tPrefix) then
		VUHDO_handleReplyReceived(aSenderName, aMessage);
	else
		VUHDO_xMsg("2. Invalid VuhDo message received from", aSenderName, aMessage);
	end
end



--
function VUHDO_updateRequestsInProgress()
	for tReceiverName, tSomeUnitRequests in pairs(sRequestsInProgress) do
		for _, tSomeReplyInfos in pairs(tSomeUnitRequests) do
			if (GetTime() > tSomeReplyInfos[1]) then
				VUHDO_sendMessage(tReceiverName, sCmdAbortComms, nil);
				VUHDO_removeCommsData(tReceiverName);
				VUHDO_Msg("程序中止：向 " .. tReceiverName .. " 的請求已逾時。", 1, 0.4, 0.4);
				VuhDoLnfShareDialog:Hide();
			end
		end
	end
end
