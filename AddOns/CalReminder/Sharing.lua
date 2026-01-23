local L = LibStub("AceLocale-3.0"):GetLocale("CalReminder", true);
local XITK = LibStub("XamInsightToolKit")

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
					if XITK.countTableElements(dataToSend.events[event][player]) == 0 then
						dataToSend.events[event][player] = nil
					end
				end
			end
			if XITK.countTableElements(dataToSend.events[event]) == 0 then
				dataToSend.events[event] = nil
			end
		end
	end
	if XITK.countTableElements(dataToSend.events) == 0 then
		dataToSend = nil
	end
	return dataToSend
end

-- Sends reminder-related data to all invitees who are still associated with
-- future or valid events. Also purges expired events and marks recent past 
-- events as "obsolete" so that they are not shared again.
function CalReminder_shareDataWithInvitees(onlyCall)

	local currentTime = time()

	-- Will collect all player GUIDs that should receive data
	local playersForSharing = {}

	---------------------------------------------------------------------
	-- PASS 1 : Iterate over all stored events in CalReminderData.events.
	--          Depending on their date, either:
	--            * purge them (too old),
	--            * mark them obsolete (past but recent),
	--            * or collect their invitees for sharing (future ones).
	---------------------------------------------------------------------
	for eventID, data in pairs(CalReminderData.events) do

		-- Retrieve stored event date (day/month/year)
		local eventDay   = getCalReminderData(eventID, "day")
		local eventMonth = getCalReminderData(eventID, "month")
		local eventYear  = getCalReminderData(eventID, "year")

		-- If the event has a valid date, process it
		if eventDay and eventMonth and eventYear then

			-- Convert event date into a comparable timestamp
			local eventTimestamp = XITK.dateToTimestamp(eventDay, eventMonth, eventYear)

			-- Determine how far in the past or future the event is
			if (currentTime - eventTimestamp) > (daysThreshold * secondsInDay) then
				-- Event is too old → remove it entirely
				CalReminderData.events[eventID] = nil

			elseif (currentTime - eventTimestamp) > 0 then
				-- Event is in the past but not too old → mark as obsolete
				CalReminderData.events[eventID].obsolete = true

			else
				-- Event is in the future → store all invitees (player GUID keys)
				for playerGUID in pairs(data.players) do
					playersForSharing[playerGUID] = true
				end
			end
		end
	end


	---------------------------------------------------------------------
	-- PASS 2 : For each collected invitee, either send a "data call"
	--          (meaning: "please send me your data") or send the full
	--          CalReminder filtered dataset to them.
	---------------------------------------------------------------------

	local dataToSend

	for playerGUID in pairs(playersForSharing) do

		-- Extract character name and realm from the player's GUID
		local _, _, _, _, _, name, server = GetPlayerInfoByGUID(playerGUID)

		-- SAFETY: name may be nil transiently; skip such cases (same behavior as original)
		if name then
			
			-- Convert to full player name ("Name-Realm")
			local target = XITK.addRealm(name, server)

			-- Do not send anything to the player themselves
			if not XITK.isPlayerCharacter(target) then

				-- If onlyCall = true, request data instead of sending data
				if onlyCall then
					CalReminder_SendCommMessage(MESSAGE_TYPE_DATA_CALL, target, MESSAGE_TYPE_DATA_CALL)

				else
					-- Otherwise, send our full filtered dataset to the invitee
					if not dataToSend then
						-- Build the dataset once (lazy creation)
						dataToSend = CalReminder_filterCalReminderData()
					end

					if dataToSend then
						encodeAndSendData(dataToSend, target, MESSAGE_TYPE_FULL_DATA)
					end
				end
			end
		end
	end
end

function CalReminder:ReceiveData(prefix, message, distribution, sender)

	-- Ignore messages not using our prefix, and ignore our own sent messages.
	if prefix == CalReminderGlobal_CommPrefix and not XITK.isPlayerCharacter(sender) then

		-- Normalize sender name into "Name-Realm"
		local senderFullName = XITK.addRealm(sender)

		-- Messages are formatted as: "<MessageType>#<SerializedPayload>"
		local messageType, rawPayload = strsplit("#", message, 2)

		-- ============================================================================
		-- CASE 1 : FULL DATA SYNC or DATA FIX
		-- The sender is sending either:
		--   * Full dataset (full synchronization)
		--   * A fix for obsolete values we previously told them about
		-- ============================================================================
		if messageType == MESSAGE_TYPE_FULL_DATA or messageType == MESSAGE_TYPE_DATA_FIX then

			-- Try to deserialize the payload
			local success, decoded = self:Deserialize(rawPayload)

			-- If deserialization fails, notify and stop.
			if success == false then
				CalReminder:Print(time().." - Received corrupted data from "..sender..".")
			else

				-- Valid sync data must contain an events table
				if decoded and decoded.events then

					-- Table used to send corrections back to the sender
					local fixedObsoleteSentValues = {}
					fixedObsoleteSentValues.events = {}

					-- Loop through all events provided by the sender
					for eventID, senderEventData in pairs(decoded.events) do

						-- Local event reference (may be nil)
						local localEvent = CalReminderData.events[eventID]

						-- ------------------------------------------------------------------
						-- CASE 1A : Locally deleted → Tell sender to delete as well
						-- ------------------------------------------------------------------
						if localEvent and localEvent.deleted then

							if not fixedObsoleteSentValues.events[eventID] then
								fixedObsoleteSentValues.events[eventID] = {}
							end
							fixedObsoleteSentValues.events[eventID].deleted = true

						-- ------------------------------------------------------------------
						-- CASE 1B : Sender says deleted → Mark as deleted locally
						-- ------------------------------------------------------------------
						elseif senderEventData.deleted then

							CalReminderData.events[eventID] = {}
							CalReminderData.events[eventID].deleted = true

						-- ------------------------------------------------------------------
						-- CASE 1C : Standard event data synchronization
						-- ------------------------------------------------------------------
						else
							for player, playerData in pairs(senderEventData) do
								for data, value in pairs(playerData) do

									-- Local stored value
									local actualValue, actualValueTime =
										getCalReminderData(eventID, data, player)

									-- Split "value|timestamp"
									local newValue, newValueTime = strsplit("|", value, 2)
									if newValue == "nil" then
										newValue = nil
									end

									-- Only act if values differ
									if actualValue ~= newValue then

										-- Accept remote value only if it is more recent
										if not actualValueTime or (newValueTime and newValueTime > actualValueTime) then

											setCalReminderData(eventID, data, newValue, player)

										else
											-- Local value is newer → add correction
											if not fixedObsoleteSentValues.events[eventID] then
												fixedObsoleteSentValues.events[eventID] = {}
											end

											fixedObsoleteSentValues.events[eventID][player] =
												CalReminderData.events[eventID].players[player]
										end
									end
								end
							end
						end
					end

					-- ----------------------------------------------------------------------
					-- If sender sent FULL DATA and we found outdated info on their side:
					--   → send corrections ("DATA_FIX") back to them
					-- ----------------------------------------------------------------------
					if messageType == MESSAGE_TYPE_FULL_DATA
						and XITK.countTableElements(fixedObsoleteSentValues.events) > 0 then

						encodeAndSendData(
							fixedObsoleteSentValues,
							senderFullName,
							MESSAGE_TYPE_DATA_FIX
						)
					end
				end
			end

		-- ============================================================================
		-- CASE 2 : DATA CALL  ("Please send me your data")
		-- ============================================================================
		elseif messageType == MESSAGE_TYPE_DATA_CALL then

			-- Sender is requesting our current data state.
			-- We compute our filtered dataset and send it back.
			local dataToSend = CalReminder_filterCalReminderData()
			if dataToSend then
				encodeAndSendData(dataToSend, senderFullName, MESSAGE_TYPE_FULL_DATA)
			end
		end
	end
end
