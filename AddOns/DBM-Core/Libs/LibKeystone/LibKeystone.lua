--@curseforge-project-slug: libkeystone@
if WOW_PROJECT_ID ~= 1 then return end -- Retail

local LKS = LibStub:NewLibrary("LibKeystone", 12)
if not LKS then return end -- No upgrade needed

LKS.callbackMap = LKS.callbackMap or {}
LKS.frame = LKS.frame or CreateFrame("Frame")
LKS.isGuildHidden = LKS.isGuildHidden or false
LKS.pendingRequest = LKS.pendingRequest or {}

local callbackMap = LKS.callbackMap
local type, error, tonumber = type, error, tonumber
local isReady = false

do
	local result = C_ChatInfo.RegisterAddonMessagePrefix("LibKS")
	-- 0=success, 1=duplicate, 2=invalid, 3=toomany
	if type(result) == "number" and result > 1 then
		error("LibKeystone: Failed to register the addon prefix.")
		return
	end
end

function LKS.Register(addon, func)
	if type(addon) ~= "table" or addon == LKS then
		error("LibKeystone: The function lib.Register expects your own unique table as the first arg.", 2)
	elseif type(func) == "function" then
		callbackMap[addon] = func
	else
		error("LibKeystone: The function lib.Register expects your own function as the second arg.", 2)
	end
end

function LKS.Unregister(addon)
	if type(addon) ~= "table" or addon == LKS then
		error("LibKeystone: The function lib.Unregister expects your own unique table.", 2)
	else
		callbackMap[addon] = nil
	end
end

function LKS.SetGuildHidden(isHidden)
	if type(isHidden) ~= "boolean" then
		error("LibKeystone: The function lib.SetGuildHidden expects a boolean value.", 2)
	else
		LKS.isGuildHidden = isHidden
	end
end

local GetInfo
do
	local savedKeyLevel, savedKeyChallengeMapID = 0, 0
	local savedResetTime = 0
	-- Normal APIs
	local GetOwnedKeystoneLevel, GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneLevel, C_MythicPlus.GetOwnedKeystoneChallengeMapID
	local GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
	local GetWeeklyResetStartTime = C_DateAndTime.GetWeeklyResetStartTime
	-- Timerunning APIs
	local GetContainerNumSlots, GetContainerItemID, GetContainerItemLink = C_Container.GetContainerNumSlots, C_Container.GetContainerItemID, C_Container.GetContainerItemLink
	local IsItemKeystoneByID, PlayerIsTimerunning = C_Item.IsItemKeystoneByID, PlayerIsTimerunning
	local strsplit = string.split
	function GetInfo()
		local resetStart = GetWeeklyResetStartTime()
		if type(resetStart) == "number" and resetStart > 0 and resetStart ~= savedResetTime then
			savedResetTime = resetStart
			savedKeyLevel, savedKeyChallengeMapID = 0, 0
		end

		-- Keystone level
		local keyLevel = GetOwnedKeystoneLevel()
		-- Keystone challenge ID [https://wago.tools/db2/MapChallengeMode]
		-- You can pass this ID into `C_ChallengeMode.GetMapUIInfo()` to get info like the name
		local keyChallengeMapID = GetOwnedKeystoneChallengeMapID()

		if not keyLevel and not keyChallengeMapID and PlayerIsTimerunning and PlayerIsTimerunning() then
			for currentBag = 0, 4 do -- 0=Backpack, 1/2/3/4=Bags
				local slots = GetContainerNumSlots(currentBag)
				for currentSlot = 1, slots do
					local itemID = GetContainerItemID(currentBag, currentSlot)
					if itemID and IsItemKeystoneByID(itemID) then
						local itemLink = GetContainerItemLink(currentBag, currentSlot)
						if type(itemLink) == "string" then
							local _, _, _, strChallengeMapID, strLevel = strsplit(":", itemLink)
							local challengeMapID = tonumber(strChallengeMapID)
							local level = tonumber(strLevel)
							if challengeMapID and level then
								keyChallengeMapID = challengeMapID
								keyLevel = level
								break
							end
						end
					end
				end
				if keyLevel then
					break
				end
			end
		end

		if type(keyLevel) == "number" and keyLevel > 0 and type(keyChallengeMapID) == "number" and keyChallengeMapID > 0 then
			savedKeyLevel = keyLevel
			savedKeyChallengeMapID = keyChallengeMapID
		end

		-- M+ rating
		local playerRatingSummary = GetPlayerMythicPlusRatingSummary("player")
		local playerRating = 0
		if type(playerRatingSummary) == "table" and type(playerRatingSummary.currentSeasonScore) == "number" then
			playerRating = playerRatingSummary.currentSeasonScore
		end
		return savedKeyLevel, savedKeyChallengeMapID, playerRating
	end
end

local SendAddonMessage, CTimerNewTimer = C_ChatInfo.SendAddonMessage, C_Timer.NewTimer
local InChatMessagingLockdown = C_ChatInfo.InChatMessagingLockdown
local IsInGroup, IsInGuild = IsInGroup, IsInGuild
local GetTime = GetTime
local next, securecallfunction = next, securecallfunction
local pName = UnitNameUnmodified("player")
local throttleTime = 3 -- Seconds
do
	local throttleTable = {
		GUILD = 0,
		PARTY = 0,
	}
	local timerTable = {}
	local functionTable
	local match, format = string.match, string.format
	local Ambiguate = Ambiguate

	do
		local retryCount = {
			GUILD = 0,
			PARTY = 0,
		}
		local function SendToParty()
			if timerTable.PARTY then
				timerTable.PARTY:Cancel()
				timerTable.PARTY = nil
			end
			if not InChatMessagingLockdown() and IsInGroup(1) then
				throttleTable.PARTY = GetTime()
				local keyLevel, keyChallengeMapID, playerRating = GetInfo()
				local result = SendAddonMessage("LibKS", format("%d,%d,%d", keyLevel, keyChallengeMapID, playerRating), "PARTY")
				if (result == 3 or result == 8 or result == 9) and retryCount.PARTY < 5 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
					retryCount.PARTY = retryCount.PARTY + 1
					timerTable.PARTY = CTimerNewTimer(throttleTime, SendToParty)
					return
				end
			end
			retryCount.PARTY = 0
		end
		local function SendToGuild()
			if timerTable.GUILD then
				timerTable.GUILD:Cancel()
				timerTable.GUILD = nil
			end
			if not InChatMessagingLockdown() and IsInGuild() then
				throttleTable.GUILD = GetTime()
				local keyLevel, keyChallengeMapID, playerRating = GetInfo()
				if keyLevel ~= 0 and LKS.isGuildHidden then
					keyLevel, keyChallengeMapID = -1, -1
				end
				local result = SendAddonMessage("LibKS", format("%d,%d,%d", keyLevel, keyChallengeMapID, playerRating), "GUILD")
				if (result == 3 or result == 8 or result == 9) and retryCount.GUILD < 5 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
					retryCount.GUILD = retryCount.GUILD + 1
					timerTable.GUILD = CTimerNewTimer(throttleTime, SendToGuild)
					return
				end
			end
			retryCount.GUILD = 0
		end
		functionTable = {
			PARTY = SendToParty,
			GUILD = SendToGuild,
		}
	end

	local currentLevel, currentMap = nil, nil
	local function DidKeystoneChange()
		local keyLevel, keyChallengeMapID, playerRating = GetInfo()
		if keyLevel ~= currentLevel or keyChallengeMapID ~= currentMap then
			currentLevel, currentMap = keyLevel, keyChallengeMapID
			for _,func in next, callbackMap do
				securecallfunction(func, keyLevel, keyChallengeMapID, playerRating, pName, "PARTY")
			end
			local t = GetTime()
			if t - throttleTable.PARTY > throttleTime then
				functionTable.PARTY()
			elseif not timerTable.PARTY then
				timerTable.PARTY = CTimerNewTimer((throttleTime+0.1)-(t-throttleTable.PARTY), functionTable.PARTY)
			end
		end
	end

	local function MarkReady()
		if not isReady then
			LKS.frame:UnregisterEvent("BAG_UPDATE_DELAYED")
			isReady = true
			GetInfo()
			local pending = LKS.pendingRequest
			LKS.pendingRequest = {}
			for k, v in next, pending do
				if v == 2 then
					LKS.Request(k)
				else
					functionTable[k]()
				end
			end
		end
	end

	LKS.frame:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
		if event == "CHAT_MSG_ADDON" then
			if prefix == "LibKS" and throttleTable[channel] then
				if msg == "R" then
					if not isReady then
						if not LKS.pendingRequest[channel] then
							LKS.pendingRequest[channel] = 1
						end
						return
					end
					local t = GetTime()
					if t - throttleTable[channel] > throttleTime then
						functionTable[channel]()
					elseif not timerTable[channel] then
						timerTable[channel] = CTimerNewTimer((throttleTime+0.1)-(t-throttleTable[channel]), functionTable[channel])
					end
					return
				end

				local keyLevelStr, keyChallengeMapIDStr, playerRatingStr = match(msg, "^(%-?%d+),(%-?%d+),(%d+)$")
				if keyLevelStr and keyChallengeMapIDStr and playerRatingStr then
					local keyLevel = tonumber(keyLevelStr)
					local keyChallengeMapID = tonumber(keyChallengeMapIDStr)
					local playerRating = tonumber(playerRatingStr)
					if keyLevel and keyChallengeMapID and playerRating and (
						(keyLevel == 0 and keyChallengeMapID == 0)
						or (keyLevel > 0 and keyChallengeMapID > 0)
						or (channel == "GUILD" and keyLevel == -1 and keyChallengeMapID == -1)
					) then
						local shortName = Ambiguate(sender, "none")
						for _,func in next, callbackMap do
							securecallfunction(func, keyLevel, keyChallengeMapID, playerRating, shortName, channel)
						end
					end
				end
			end
		elseif event == "CHALLENGE_MODE_COMPLETED" then -- We start listening to events at the end of a Mythic+ to check if a player gets a new keystone
			currentLevel, currentMap = GetInfo()
			self:RegisterEvent("BAG_UPDATE_DELAYED")
			self:RegisterEvent("PLAYER_LEAVING_WORLD")
		elseif event == "PLAYER_LEAVING_WORLD" then -- Stop listening to events when we leave the dungeon
			currentLevel, currentMap = nil, nil
			self:UnregisterEvent("BAG_UPDATE_DELAYED")
			self:UnregisterEvent(event)
		elseif event == "BAG_UPDATE_DELAYED" then
			if isReady then -- We automatically broadcast newly received keystones, but only at the end of a Mythic+
				-- Check if the player got a new keystone from the NPC or the chest
				DidKeystoneChange()
			else -- Delay all requests during login until after the first bag event, required for keystone data to work
				MarkReady()
			end
		end
	end)
	LKS.frame:RegisterEvent("CHAT_MSG_ADDON")
	LKS.frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	LKS.frame:RegisterEvent("BAG_UPDATE_DELAYED")
	if IsLoggedIn() then -- Compensate for library upgrades after logging in
		C_Timer.After(2, MarkReady)
	end
end

do
	local throttleSendTable = {
		GUILD = 0,
		PARTY = 0,
	}
	local statusCheckTable = {
		GUILD = IsInGuild,
		PARTY = function() return IsInGroup(1) end,
	}
	local timers = {}
	local retryCount = {
		GUILD = 0,
		PARTY = 0,
	}
	local function SendRequestParty()
		if timers.PARTY then
			timers.PARTY:Cancel()
			timers.PARTY = nil
		end
		if not InChatMessagingLockdown() and IsInGroup(1) then
			throttleSendTable.PARTY = GetTime()
			local result = SendAddonMessage("LibKS", "R", "PARTY")
			if (result == 3 or result == 8 or result == 9) and retryCount.PARTY < 5 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
				retryCount.PARTY = retryCount.PARTY + 1
				timers.PARTY = CTimerNewTimer(throttleTime, SendRequestParty)
				return
			end
		end
		retryCount.PARTY = 0
	end
	local function SendRequestGuild()
		if timers.GUILD then
			timers.GUILD:Cancel()
			timers.GUILD = nil
		end
		if not InChatMessagingLockdown() and IsInGuild() then
			throttleSendTable.GUILD = GetTime()
			local result = SendAddonMessage("LibKS", "R", "GUILD")
			if (result == 3 or result == 8 or result == 9) and retryCount.GUILD < 5 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
				retryCount.GUILD = retryCount.GUILD + 1
				timers.GUILD = CTimerNewTimer(throttleTime, SendRequestGuild)
				return
			end
		end
		retryCount.GUILD = 0
	end
	local requestFunctionTable = {
		PARTY = SendRequestParty,
		GUILD = SendRequestGuild,
	}
	function LKS.Request(channel)
		if not throttleSendTable[channel] then
			error("LibKeystone: The function lib.Request expects a channel type of PARTY or GUILD.", 2)
		else
			if not isReady then
				LKS.pendingRequest[channel] = 2
				return
			end
			local keyLevel, keyChallengeMapID, playerRating = GetInfo()
			if keyLevel ~= 0 and LKS.isGuildHidden and channel == "GUILD" then
				keyLevel, keyChallengeMapID = -1, -1
			end
			for _,func in next, callbackMap do
				securecallfunction(func, keyLevel, keyChallengeMapID, playerRating, pName, channel) -- This allows us to show our own stats when not grouped or not in a guild
			end
			if not InChatMessagingLockdown() and statusCheckTable[channel]() then
				local t = GetTime()
				if t - throttleSendTable[channel] > throttleTime then
					requestFunctionTable[channel]()
				elseif not timers[channel] then
					timers[channel] = CTimerNewTimer((throttleTime+0.1)-(t-throttleSendTable[channel]), requestFunctionTable[channel])
				end
			end
		end
	end
end
