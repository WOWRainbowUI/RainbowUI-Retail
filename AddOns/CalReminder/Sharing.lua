local L = LibStub("AceLocale-3.0"):GetLocale("CalReminder", true);

-- Number of seconds in a day (86400 seconds = 1 day)
local secondsInDay = 86400
-- Number of days to treshold data
local daysThreshold = 62

local MESSAGE_TYPE_DATA_CALL = "DataCall"
local MESSAGE_TYPE_FULL_DATA = "FullData"
local MESSAGE_TYPE_DATA_FIX  = "FixedObloleteData"

local lastSentMessage = {}
lastSentMessage[MESSAGE_TYPE_DATA_CALL] = {}
lastSentMessage[MESSAGE_TYPE_FULL_DATA] = {}

local function CalReminder_SendCommMessage(text, target, messageType)
	if target and messageType then
		local now = GetTime()
		if (not lastSentMessage[messageType] or not lastSentMessage[messageType][target] or lastSentMessage[messageType][target] + 60 < now) then
			lastCalReminderSendCommMessage = now
			if lastSentMessage[messageType] then
				lastSentMessage[messageType][target] = lastCalReminderSendCommMessage
			end
			CalReminder:SendCommMessage(CalReminderGlobal_CommPrefix, text, "WHISPER", target, nil,
				function()
					lastCalReminderSendCommMessage = GetTime()
				end)
		end
	end
end

local function encodeAndSendData(data, target, messageType)
	local s = CalReminder:Serialize(data)
	local text = messageType.."#"..s
	CalReminder_SendCommMessage(text, target, messageType)
end

local function CalReminder_filterCalReminderData()
	local dataToSend = {}
	dataToSend.events = {}
	dataToSend["version"] = C_AddOns.GetAddOnMetadata("CalReminder", "Version")
	for event, eventData in pairs(CalReminderData.events) do
		if not eventData.obsolete and not eventData.deleted then
			dataToSend.events[event] = {}
			for player, playerData in pairs(eventData.players) do
				local playerStatus = getCalReminderData(event, "status", player)
				if playerStatus and playerStatus == tostring(Enum.CalendarStatus.Tentative) then
					--local playerReason = getCalReminderData(event, "reason", player)
					--local playerReasonText = getCalReminderData(event, "reasonText", player)
					dataToSend.events[event][player] = {}
					dataToSend.events[event][player].reason     = eventData.players[player].reason
					dataToSend.events[event][player].reasonText = eventData.players[player].reasonText
					if CalReminder_countTableElements(dataToSend.events[event][player]) == 0 then
						dataToSend.events[event][player] = nil
					end
				end
			end
			if CalReminder_countTableElements(dataToSend.events[event]) == 0 then
				dataToSend.events[event] = nil
			end
		end
	end
	if CalReminder_countTableElements(dataToSend.events) == 0 then
		dataToSend = nil
	end
	return dataToSend
end

function CalReminder_shareDataWithInvitees(onlyCall)
	local currentTime = time()
	local playersForSharing = {}
	for eventID, data in pairs(CalReminderData.events) do
		local eventDay   = getCalReminderData(eventID, "day")
		local eventMonth = getCalReminderData(eventID, "month")
		local eventYear  = getCalReminderData(eventID, "year")
		if eventDay and eventMonth and eventYear then
			local eventTimeStamp = CalReminder_dateToTimestamp(eventDay, eventMonth, eventYear)
			
			if (currentTime - eventTimeStamp) > (daysThreshold * secondsInDay) then
				CalReminderData.events[eventID] = nil
			elseif (currentTime - eventTimeStamp) > 0 then
				CalReminderData.events[eventID].obsolete = true
			else
				for player, playerData in pairs(data.players) do
					playersForSharing[player] = true
				end
			end
		end
	end
	
	local dataToSend
	for player, data in pairs(playersForSharing) do
		local _, _, _, _, _, name, server = GetPlayerInfoByGUID(player)
		local target = CalReminder_addRealm(name, server)
		if not CalReminder_isPlayerCharacter(target) then
			if onlyCall then
				CalReminder_SendCommMessage(MESSAGE_TYPE_DATA_CALL, target, MESSAGE_TYPE_DATA_CALL)
			else
				if not dataToSend then
					dataToSend = CalReminder_filterCalReminderData()
				end
				if dataToSend then
					encodeAndSendData(dataToSend, target, MESSAGE_TYPE_FULL_DATA)
				end
			end
		end
	end
end

function CalReminder:ReceiveData(prefix, message, distribution, sender)
	if prefix == CalReminderGlobal_CommPrefix and not CalReminder_isPlayerCharacter(sender) then
		local senderFullName = CalReminder_addRealm(sender)
		--CalReminder:Print(time().." - Received message from "..sender..".")
		local messageType, messageMessage = strsplit("#", message, 2)
		--if not isPlayerCharacter(sender) then
		if messageType == MESSAGE_TYPE_FULL_DATA or messageType == MESSAGE_TYPE_DATA_FIX then
			local success, o = self:Deserialize(messageMessage)
			if success == false then
				CalReminder:Print(time().." - Received corrupted data from "..sender..".")
			else
				if o and o.events then
					local fixedObsoleteSentValues = {}
					fixedObsoleteSentValues.events = {}
					for eventID, eventData in pairs(o.events) do
						if CalReminderData.events[eventID] and CalReminderData.events[eventID].deleted then
							if not fixedObsoleteSentValues.events[eventID] then
								fixedObsoleteSentValues.events[eventID] = {}
							end
							fixedObsoleteSentValues.events[eventID].deleted = true
						elseif eventData.deleted then
							CalReminderData.events[eventID] = {}
							CalReminderData.events[eventID].deleted = true
						else
							for player, playerData in pairs(eventData) do
								for data, value in pairs(playerData) do
									local actualValue, actualValueTime = getCalReminderData(eventID, data, player)
									local newValue, newValueTime = strsplit("|", value, 2)
									if newValue == "nil" then
										newValue = nil
									end
									if actualValue ~= newValue then
										if not actualValueTime or (newValueTime and newValueTime > actualValueTime) then
											setCalReminderData(eventID, data, newValue, player)
										else
											if not fixedObsoleteSentValues.events[eventID] then
												fixedObsoleteSentValues.events[eventID] = {}
											end
											if not fixedObsoleteSentValues.events[eventID] then
												fixedObsoleteSentValues.events[eventID] = {}
											end
											fixedObsoleteSentValues.events[eventID][player] = CalReminderData.events[eventID].players[player]
										end
									end
								end
							end
						end
					end
					if messageType == MESSAGE_TYPE_FULL_DATA and CalReminder_countTableElements(fixedObsoleteSentValues.events) > 0 then
						encodeAndSendData(fixedObsoleteSentValues, senderFullName, MESSAGE_TYPE_DATA_FIX)
					end
				end
			end
		elseif messageType == MESSAGE_TYPE_DATA_CALL then
			local dataToSend = CalReminder_filterCalReminderData()
			if dataToSend then
				encodeAndSendData(dataToSend, senderFullName, MESSAGE_TYPE_FULL_DATA)
			end
		end
	end
end
