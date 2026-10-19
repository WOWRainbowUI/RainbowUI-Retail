local UtilityNotifications = {}
UtilityNotifications.__index = UtilityNotifications

function UtilityNotifications:New(config)
	return setmetatable({
		config = config,
		recentEmotes = {},
	}, self)
end

function UtilityNotifications:DisplayStatic(eventKey)
	local settings = self.config.getProfile().events[eventKey]
	if settings and not settings.disabled then
		self.config.display(settings, settings.message)
	end
end

function UtilityNotifications:HandleCombatEnter()
	self:DisplayStatic("NOTIFICATION_COMBAT_ENTER")
end

function UtilityNotifications:HandleCombatLeave()
	self:DisplayStatic("NOTIFICATION_COMBAT_LEAVE")
end

function UtilityNotifications:HandleMonsterEmote(message, sourceName)
	local targetName = self.config.unitName("target")
	local compareSucceeded, isTarget = pcall(function()
		return sourceName == targetName
	end)
	if not compareSucceeded or not isTarget then
		return
	end

	local formatSucceeded, emote = pcall(
		string.gsub,
		message,
		"%%s",
		sourceName
	)
	if not formatSucceeded then
		return
	end
	local settings = self.config.getProfile().events.NOTIFICATION_MONSTER_EMOTE
	if not settings or settings.disabled then
		return
	end

	local now = self.config.getTime()
	for recentEmote, expires in pairs(self.recentEmotes) do
		if now >= expires then
			self.recentEmotes[recentEmote] = nil
		end
	end
	if self.recentEmotes[emote] then
		return
	end

	self.config.display(
		settings,
		self.config.format(
			settings.message,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			nil,
			emote
		)
	)
	self.recentEmotes[emote] = now + self.config.emoteHoldTime
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.UtilityNotifications = UtilityNotifications

return UtilityNotifications
