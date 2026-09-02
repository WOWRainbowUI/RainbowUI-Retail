local ParserNotifications = {}
ParserNotifications.__index = ParserNotifications

function ParserNotifications:New(config)
	return setmetatable({
		config = config,
	}, self)
end

function ParserNotifications:HandlePower(event, profile)
	if self.config.uniquePowerTypes[event.powerType] ~= nil
		or profile.showAllPowerGains then
		return nil
	end

	local amount
	if event.isLeech then
		if event.sourceUnit ~= "player" then
			return nil
		end
		amount = event.extraAmount
	else
		if event.recipientUnit ~= "player" then
			return nil
		end
		amount = event.amount
	end
	if amount == 0 then
		return nil
	end
	if amount and math.abs(amount) < profile.powerThreshold then
		return nil
	end

	local prefix = event.powerType == self.config.alternatePowerType
		and "NOTIFICATION_ALT_POWER_"
		or "NOTIFICATION_POWER_"
	local eventType = prefix .. (event.isDrain and "LOSS" or "GAIN")
	return eventType, event.skillName, nil, nil, true
end

function ParserNotifications:HandleKill(event)
	if event.sourceUnit ~= "player" then
		return nil
	end
	if self.config.testFlagsAll(
		event.recipientFlags,
		self.config.guardianHumanMask
	) then
		return nil
	end
	if event.recipientUnit == "pet" then
		return nil
	end

	local targetType = self.config.testFlagsAll(
		event.recipientFlags,
		self.config.serverControlMask
	) and "NPC" or "PC"
	return "NOTIFICATION_" .. targetType .. "_KILLING_BLOW",
		nil,
		event.recipientName,
		self.config.classMap[event.recipientGUID]
end

function ParserNotifications:HandleHonor(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_HONOR_GAIN"
	end
	return nil
end

function ParserNotifications:HandleReputation(event)
	if event.recipientUnit ~= "player" then
		return nil
	end
	return "NOTIFICATION_REP_" .. (event.isLoss and "LOSS" or "GAIN"),
		event.factionName
end

function ParserNotifications:HandleProficiency(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_SKILL_GAIN", event.skillName
	end
	return nil
end

function ParserNotifications:HandleExperience(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_EXPERIENCE_GAIN"
	end
	return nil
end

function ParserNotifications:HandleExtraAttacks(event)
	if event.sourceUnit == "player" then
		return "NOTIFICATION_EXTRA_ATTACK", event.skillName
	end
	return nil
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.ParserNotifications = ParserNotifications

return ParserNotifications
