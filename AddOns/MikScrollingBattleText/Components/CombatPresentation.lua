local Presentation = {}
Presentation.__index = Presentation

local RestrictedValue = MikSBT.API.RestrictedValue
local HEALER_PAIR_WINDOW = 0.2
local MISS_TYPES = {
	"MISS", "DODGE", "PARRY", "BLOCK", "RESIST", "EVADE",
	"IMMUNE", "DEFLECT", "ABSORB", "REFLECT",
}

local function MissAction(word)
	for _, action in ipairs(MISS_TYPES) do
		if word == action or word == _G[action]
			or (type(word) == "string" and word:upper() == action) then
			return action
		end
	end
	return "MISS"
end

function Presentation:New(config)
	return setmetatable({
		config = config, batches = {}, generation = 0,
	}, self)
end

function Presentation:Reset()
	self.generation = self.generation + 1
	self.batches = {}
	self.lastIncomingHeal = nil
	self.waitingHealer = nil
end

function Presentation:Settings(key, crit)
	local events = self.config.getProfile().events
	local settings = crit and events[key .. "_CRIT"] or events[key]
	if not settings then settings = events[key] end
	if settings and not settings.disabled then return settings end
end

function Presentation:Emit(key, record, eventSettings)
	local settings = eventSettings or self:Settings(key, record.crit)
	if not settings then return end
	local icon = record.icon or (record.spell
		and self.config.getSpellTexture(record.spell))
	if RestrictedValue:IsRestricted(record.amount) then
		self.config.displayRestricted(settings, record.amount, icon, record.message)
		return
	end
	local message
	if record.event == "miss" and record.amount == nil
		and MissAction(record.missWord) == "ABSORB" then
		message = (_G.ABSORB or "Absorb") .. "!"
	else
		message = self.config.formatMessage(settings, record, record.message)
	end
	if message and message ~= "" then
		self.config.display(settings, message, icon)
	end
end

function Presentation:Resource(amount, powerToken)
	local settings = self:Settings("NOTIFICATION_RESOURCE_GAIN")
	if not settings then return end
	if not RestrictedValue:IsRestricted(amount) then
		local amountText = RestrictedValue:String(amount)
		local readableAmount = RestrictedValue:Number(amount) or tonumber(amountText)
		if not readableAmount or readableAmount <= 0 then return end
	end
	self.config.displayResource(settings, amount, powerToken)
end

function Presentation:RememberIncomingHeal(record)
	local now = self.config.getTime()
	record.healerTime = now
	self.lastIncomingHeal = record
	local waiting = self.waitingHealer
	self.waitingHealer = nil
	if waiting and now - waiting.at <= HEALER_PAIR_WINDOW then
		record.sourceName = waiting.name
	end
end

function Presentation:EmitIncomingHeal(key, record)
	local remaining = HEALER_PAIR_WINDOW
		- (self.config.getTime() - record.healerTime)
	local generation = self.generation
	self.config.after(math.max(0, remaining), function()
		if generation ~= self.generation then return end
		self:Emit(key, record)
	end)
end

function Presentation:Queue(key, record, incomingHeal)
	if not self.config.after then
		self:Emit(key, record)
		return
	end
	if not RestrictedValue:Number(record.amount) then
		if incomingHeal then
			local pending = {}
			for field, value in pairs(record) do pending[field] = value end
			self:RememberIncomingHeal(pending)
			self:EmitIncomingHeal(key, pending)
		else
			self:Emit(key, record)
		end
		return
	end
	local batchKey = key .. (record.crit and ":crit" or "")
		.. ":" .. tostring(record.spell or record.icon or "")
	local batch = self.batches[batchKey]
	if batch then
		batch.amount = batch.amount + record.amount
		batch.hitCount = batch.hitCount + 1
		if incomingHeal then self:RememberIncomingHeal(batch) end
		return
	end
	batch = {}
	for field, value in pairs(record) do batch[field] = value end
	batch.hitCount = 1
	if incomingHeal then self:RememberIncomingHeal(batch) end
	self.batches[batchKey] = batch
	local generation = self.generation
	local delay = self.config.delay or 0.12
	if record.event == "damage" then
		delay = self.config.damageDelay or delay
	end
	self.config.after(delay, function()
		if generation ~= self.generation then return end
		self.batches[batchKey] = nil
		if incomingHeal then
			self:EmitIncomingHeal(key, batch)
		else
			self:Emit(key, batch)
		end
	end)
end

local function EventKey(direction, record, result)
	local pet = record.pet or (result and result.who == "pet")
	local prefix = (pet and "PET_" or "") .. direction .. "_"
	local tick = record.tick or (result and result.tick)
	if record.event == "heal" then
		if direction == "INCOMING" and record.selfHeal then
			return tick and "SELF_HOT" or "SELF_HEAL"
		end
		return prefix .. (tick and "HOT" or "HEAL")
	end
	local melee = result and result.melee and result.hand ~= "ranged"
	local spell = result and not melee or (not result and record.school
		and record.school ~= 1)
	if record.event == "miss" then
		return prefix .. (spell and "SPELL_" or "") .. MissAction(record.missWord)
	end
	if tick then return prefix .. "SPELL_DOT" end
	if result and result.shield then return prefix .. "SPELL_DAMAGE_SHIELD" end
	return prefix .. (spell and "SPELL_DAMAGE" or "DAMAGE")
end

function Presentation:Out(record)
	local result = record.result
	if not result or (result.who ~= "you" and result.who ~= "pet") then return end
	if record.event == "killed" then
		self:Alert({ kind = "kill", icon = record.icon })
		return
	end
	local key = EventKey("OUTGOING", record, result)
	local spell = result.spell or result.procSpell
	if result.melee then spell = result.hand == "ranged" and 5019 or 6603 end
	local icon = record.icon or (spell and self.config.getSpellTexture(spell))
	if record.event == "damage" then
		local isSpell = not result.melee or result.hand == "ranged"
		local method = RestrictedValue:IsRestricted(record.amount)
			and "DisplayRestricted" or "Queue"
		self.config.batcher[method](self.config.batcher,
			spell, record.amount, record.crit, icon, isSpell,
			result.who == "pet", result.tick, key)
		return
	end
	local displayRecord = {}
	for field, value in pairs(record) do displayRecord[field] = value end
	displayRecord.spell, displayRecord.icon = spell, icon
	self:Queue(key, displayRecord)
end

function Presentation:In(record)
	if record.event ~= "damage" and record.event ~= "heal"
		and record.event ~= "miss" then return end
	self:Queue(EventKey("INCOMING", record), record,
		record.event == "heal" and not record.pet)
end

function Presentation:Aura(gained, harmful, name, icon, spellID)
	local rules = self.config.getProfile().auraTracking
	if rules and not MikSBT.Configuration.AuraTracking:ShouldShow(
		rules, spellID, name) then return end
	local key = "NOTIFICATION_" .. (harmful and "DEBUFF" or "BUFF")
		.. (gained and "" or "_FADE")
	local settings = self:Settings(key)
	if not settings then return end
	if rules then
		local tracking = MikSBT.Configuration.AuraTracking
		local id = tracking:FindID(rules, spellID, name)
		if id and rules[id] ~= nil then
			settings = tracking:GetSettings(self.config.getProfile(), id, key)
		end
	end
	if RestrictedValue:IsRestricted(name) then
		local message = (settings.message or "%sl"):gsub("%%sl", "%%a")
		self.config.displayRestricted(settings, name, icon, message)
	else
		self:Emit(key, { name = name, icon = icon }, settings)
	end
end

local ALERT_EVENTS = {
	interrupt = "OUTGOING_SPELL_INTERRUPT",
	dispel = "OUTGOING_DISPEL",
	broke = "NOTIFICATION_CROWD_CONTROL",
	cc = "NOTIFICATION_CROWD_CONTROL",
	proc = "NOTIFICATION_PROC",
	reactive = "NOTIFICATION_REACTIVE",
	kill = "NOTIFICATION_NPC_KILLING_BLOW",
}
function Presentation:Alert(record)
	local key = ALERT_EVENTS[record.kind]
	if record.kind == "combat" then
		key = record.entering and "NOTIFICATION_COMBAT_ENTER"
			or "NOTIFICATION_COMBAT_LEAVE"
	end
	if not key then return end
	local displayRecord = { name = record.text, icon = record.icon }
	if record.args then
		local value = record.args[1]
		if RestrictedValue:IsRestricted(value) then
			local settings = self:Settings(key)
			if settings then
				self.config.displayRestricted(settings, value, record.icon, "%a")
			end
			return
		end
		if value ~= nil then displayRecord.name = value end
	end
	self:Emit(key, displayRecord)
end

-- Match the player's healer notice in either event order. Pet and outgoing
-- heals never consume these notices; opaque names are retained as supplied.
function Presentation:Healer(name)
	if not self.config.getTime then return end
	local now = self.config.getTime()
	local record = self.lastIncomingHeal
	if record and now - record.healerTime <= HEALER_PAIR_WINDOW then
		record.sourceName = name
	else
		self.waitingHealer = { name = name, at = now }
	end
end

MikSBT.Components.CombatPresentation = Presentation
return Presentation
