local IncomingCombat = {}
IncomingCombat.__index = IncomingCombat

local RestrictedValue = MikSBT.API.RestrictedValue

local damageSourceMap = {
	FALLING = "falling",
	DROWNING = "drowning",
	FIRE = "fire",
	LAVA = "lava",
	SLIME = "slime",
	EXHAUSTION = "fatigue",
}

local ignoredDamageFlags = {
	CRITICAL = true,
	CRUSHING = true,
	GLANCING = true,
	BLOCK = true,
	ABSORB = true,
	RESIST = true,
}

function IncomingCombat:New(config)
	return setmetatable({
		config = config,
		damageBatches = {},
		healBatches = {},
	}, self)
end

local function ClearTable(target)
	for key in pairs(target) do
		target[key] = nil
	end
end

function IncomingCombat:ResetDamage()
	ClearTable(self.damageBatches)
end

function IncomingCombat:Reset()
	self:ResetDamage()
	ClearTable(self.healBatches)
end

local function StripRealm(name, unknown)
	if not name then
		return unknown
	end
	if string.find(name, "-", 1, true) then
		return string.gsub(name, "(.-)%-.*", "%1")
	end
	return name
end

local function BuildHitSummary(hitCount)
	if hitCount and hitCount > 1 then
		local translations = MikSBT.translations
		return string.format(" [%d %s]", hitCount, translations and translations.MSG_HITS or "Hits")
	end
	return nil
end

local function BuildDamageLine(self, settings, batch)
	local message = self.config.buildActionMessage(settings, batch.totalAmount)
	if not message or message == "" then
		return nil
	end

	local summary = BuildHitSummary(batch.hitCount)
	if summary then
		message = message .. summary
	end
	if batch.damageSource and batch.damageSource ~= "" then
		message = string.format("%s - %s", message, batch.damageSource)
	end
	return message
end

local function BuildHealSummary(hitCount, critCount)
	if critCount and critCount > 0 then
		if hitCount == 1 and critCount == 1 then
			return " (Crit)"
		end
		local hitsWord = hitCount == 1 and "hit" or "hits"
		local critWord = critCount == 1 and "Crit" or "Crits"
		return string.format(
			" (%d %s, %d %s)",
			hitCount,
			hitsWord,
			critCount,
			critWord
		)
	end
	return BuildHitSummary(hitCount)
end

local function BuildHealLine(self, settings, batch, amount, hits, crits, overheal)
	if overheal and overheal >= amount
		and self.config.getProfile().hideFullOverheals then
		return nil
	end
	local message = self.config.buildActionMessage(
		settings,
		amount,
		overheal,
		batch.effectName
	)
	if not message or message == "" then
		return nil
	end

	local summary = BuildHealSummary(hits, crits)
	if summary then
		message = message .. summary
	end
	if batch.healSourceLabel and batch.healSourceLabel ~= "" then
		message = string.format("%s [%s]", message, batch.healSourceLabel)
	end
	return message
end

local function GetDamageSource(flagText, schoolMask)
	if flagText and damageSourceMap[flagText] then
		return damageSourceMap[flagText]
	end
	if flagText and not ignoredDamageFlags[flagText] then
		return string.lower(flagText)
	end
	if type(schoolMask) == "string" and schoolMask ~= "" then
		return string.lower(schoolMask)
	end
	return nil
end

local function GetHealSourceLabel(flagText, schoolMask)
	local flag = flagText and string.upper(tostring(flagText)) or ""
	local school = schoolMask and string.upper(tostring(schoolMask)) or ""
	if string.find(flag, "LEECH", 1, true)
		or string.find(school, "LEECH", 1, true) then
		return "Leech"
	end
	return nil
end

local function DisplayDamageBatch(self, batchKey)
	local batch = self.damageBatches[batchKey]
	if not batch then
		return
	end
	self.damageBatches[batchKey] = nil

	local profile = self.config.getProfile()
	local settings = profile.events.INCOMING_DAMAGE
	if not settings or settings.disabled then
		return
	end
	local critSettings = profile.events.INCOMING_DAMAGE_CRIT
	local critCount = batch.isCrit and batch.hitCount or 0
	local messageSettings = settings
	if self.config.shouldSplitCritBatch(settings, critSettings, critCount) then
		messageSettings = critSettings
	end

	local message = BuildDamageLine(self, messageSettings, batch)
	if message then
		local displaySettings = self.config.resolveBatchDisplaySettings(
			settings,
			critSettings,
			batch.hitCount,
			critCount
		)
		self.config.display(displaySettings, message)
	end
end

function IncomingCombat:QueueDamage(amount, isCrit, damageSource)
	local batchKey = isCrit and "incoming_damage:crit" or "incoming_damage"
	local batch = self.damageBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			isCrit = not not isCrit,
			totalAmount = 0,
			damageSource = damageSource,
		}
		self.damageBatches[batchKey] = batch
		self.config.after(self.config.groupDelay, function()
			if self.damageBatches[batchKey] == batch then
				DisplayDamageBatch(self, batchKey)
			end
		end)
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + amount
	if damageSource and damageSource ~= "" then
		if batch.damageSource and batch.damageSource ~= damageSource then
			batch.damageSource = "mixed"
		elseif not batch.damageSource then
			batch.damageSource = damageSource
		end
	end
end

local DIRECT_HEAL_ICON_WINDOW = 1.5

local function GetHealSpell(self, isSelfHeal, healTime)
	local spellID, spellTime = self.config.getLastPlayerSpell()
	if not spellID or self.config.isAutoAttackSpellID(spellID)
		or not self.config.isHelpfulSpell(spellID) then
		return nil
	end
	local elapsed = (healTime or self.config.getTime()) - spellTime
	if elapsed < 0 then
		return nil
	end
	local isAttributed = elapsed <= DIRECT_HEAL_ICON_WINDOW
		or (isSelfHeal and elapsed <= self.config.selfHealIconWindow
			and self.config.playerHasAura(spellID))
	if isAttributed then
		local name, _, texture = self.config.getSpellInfo(spellID)
		return name, texture
	end
end

local function InsertSpellName(message, spellName)
	if not message or not spellName then
		return message
	end
	return (string.gsub(message, "%%sl?", (string.gsub(spellName, "%%", "%%%%"))))
end

local function DisplayHealBatch(self, batchKey)
	local batch = self.healBatches[batchKey]
	if not batch then
		return
	end
	self.healBatches[batchKey] = nil
	batch.effectName, batch.effectTexture =
		GetHealSpell(self, batch.isSelfHeal, batch.healTime)

	local profile = self.config.getProfile()
	local settings = profile.events[batch.baseEventKey]
	local critSettings = profile.events[batch.critEventKey]
	local normalEnabled = settings and not settings.disabled
	local critEnabled = critSettings and not critSettings.disabled
	if not normalEnabled and not critEnabled then
		return
	end

	local critCount = batch.critCount or 0
	local critAmount = math.min(batch.critAmount or 0, batch.totalAmount)
	local critOverheal = math.min(batch.critOverheal, critAmount)
	if not normalEnabled then
		if critEnabled and critCount > 0 and critAmount > 0 then
			local message = BuildHealLine(
				self,
				critSettings,
				batch,
				critAmount,
				critCount,
				critCount,
				critOverheal
			)
			if message then
				self.config.display(critSettings, message, batch.effectTexture)
			end
		end
		return
	end

	if self.config.shouldSplitCritBatch(settings, critSettings, critCount) then
		local normalCount = batch.hitCount - critCount
		local normalAmount = batch.totalAmount - critAmount
		if normalCount > 0 and normalAmount > 0 then
			local message = BuildHealLine(
				self,
				settings,
				batch,
				normalAmount,
				normalCount,
				0,
				batch.totalOverheal - critOverheal
			)
			if message then
				self.config.display(settings, message, batch.effectTexture)
			end
		end

		local message = BuildHealLine(
			self,
			critSettings,
			batch,
			critAmount,
			critCount,
			critCount,
			critOverheal
		)
		if message then
			self.config.display(critSettings, message, batch.effectTexture)
		end
		return
	end

	local message = BuildHealLine(
		self,
		settings,
		batch,
		batch.totalAmount,
		batch.hitCount,
		critCount,
		batch.totalOverheal
	)
	if message then
		local displaySettings = self.config.resolveBatchDisplaySettings(
			settings,
			critSettings,
			batch.hitCount,
			critCount
		)
		self.config.display(displaySettings, message, batch.effectTexture)
	end
end

function IncomingCombat:HandleHealthUpdate(unitID)
	if unitID ~= "player" then
		return
	end
	local health = RestrictedValue:Number(self.config.unitHealth("player"))
	if not health then
		return
	end
	self.previousHealth = self.lastHealth
	self.lastHealth = health
	self.lastHealthTime = self.config.getTime()
end

function IncomingCombat:GetOverheal(amount)
	local health = RestrictedValue:Number(self.config.unitHealth("player"))
	local maxHealth = RestrictedValue:Number(self.config.unitHealthMax("player"))
	if not health or not maxHealth or maxHealth <= 0 then
		return 0
	end
	local healthBefore = health
	if self.lastHealthTime == self.config.getTime()
		and self.lastHealth == health and self.previousHealth then
		healthBefore = self.previousHealth
	end
	local effective = math.max(0, math.min(amount, maxHealth - healthBefore))
	return amount - effective
end

function IncomingCombat:QueueHeal(
	amount,
	isCrit,
	isSelfHeal,
	sourceName,
	healSourceLabel,
	baseEventKey,
	critEventKey,
	overheal
)
	baseEventKey = baseEventKey or "INCOMING_HEAL"
	critEventKey = critEventKey or baseEventKey .. "_CRIT"
	local batchKey = "incoming_heal:" .. baseEventKey
	local batch = self.healBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			critCount = 0,
			critAmount = 0,
			totalAmount = 0,
			critOverheal = 0,
			totalOverheal = 0,
			healTime = self.config.getTime(),
			isSelfHeal = isSelfHeal,
			sourceName = sourceName,
			healSourceLabel = healSourceLabel,
			baseEventKey = baseEventKey,
			critEventKey = critEventKey,
		}
		self.healBatches[batchKey] = batch
		self.config.after(self.config.groupDelay, function()
			if self.healBatches[batchKey] == batch then
				DisplayHealBatch(self, batchKey)
			end
		end)
	end

	overheal = overheal or 0
	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + amount
	batch.totalOverheal = batch.totalOverheal + overheal
	if isCrit then
		batch.critCount = batch.critCount + 1
		batch.critAmount = batch.critAmount + amount
		batch.critOverheal = batch.critOverheal + overheal
	end
	if healSourceLabel and healSourceLabel ~= "" then
		batch.healSourceLabel = healSourceLabel
	end
end

local function GetLikelyHealSource(self)
	local config = self.config
	if config.unitCastingInfo("player") or config.unitChannelInfo("player") then
		return config.unitName("player") or config.unknown
	end
	if not config.safeUnitBoolean(UnitExists, "target") then
		return config.unitName("player") or config.unknown
	end
	if config.safeUnitBoolean(UnitCanAssist, "player", "target")
		and config.safeUnitBoolean(UnitExists, "targettarget")
		and config.safeUnitBoolean(UnitIsUnit, "targettarget", "player") then
		return config.unitName("target") or config.unknown
	end
	if config.safeUnitBoolean(UnitExists, "focus")
		and config.safeUnitBoolean(UnitCanAssist, "player", "focus")
		and config.safeUnitBoolean(UnitExists, "focustarget")
		and config.safeUnitBoolean(UnitIsUnit, "focustarget", "player") then
		return config.unitName("focus") or config.unknown
	end
	return config.unknown
end

local function ResolveHealKeys(self)
	local sourceName = StripRealm(
		GetLikelyHealSource(self),
		self.config.unknown
	)
	local playerName = StripRealm(
		self.config.unitName("player"),
		self.config.unknown
	)
	local isSelfHeal = sourceName == playerName
	local baseKey = isSelfHeal and "SELF_HEAL" or "INCOMING_HEAL"
	local critKey = isSelfHeal and "SELF_HEAL_CRIT" or "INCOMING_HEAL_CRIT"
	return baseKey, critKey, isSelfHeal, sourceName
end

function IncomingCombat:DisplayRestricted(action, isCrit, amount, flagText, schoolMask, healTime)
	local profile = self.config.getProfile()
	local baseKey, critKey, texture, suffix, spellName
	if action == "WOUND" then
		baseKey, critKey = "INCOMING_DAMAGE", "INCOMING_DAMAGE_CRIT"
		local damageSource = GetDamageSource(flagText, schoolMask)
		if damageSource and damageSource ~= "" then
			suffix = " - " .. damageSource
		end
	else
		local isSelfHeal
		baseKey, critKey, isSelfHeal = ResolveHealKeys(self)
		spellName, texture = GetHealSpell(self, isSelfHeal, healTime)
		local label = GetHealSourceLabel(flagText, schoolMask)
		if label then
			suffix = " [" .. label .. "]"
		end
	end

	local settings = profile.events[baseKey]
	local critSettings = profile.events[critKey]
	if isCrit and critSettings and not critSettings.disabled then
		settings = critSettings
	end
	if not settings or settings.disabled then
		return
	end
	self.config.displayRestricted(
		settings,
		amount,
		texture,
		InsertSpellName(settings.message, spellName),
		suffix
	)
end

function IncomingCombat:HandleUnitCombat(
	unitTarget,
	action,
	flagText,
	amount,
	schoolMask
)
	if not RestrictedValue:Equals(unitTarget, "player") then
		return false
	end

	action = RestrictedValue:String(action)
	if not action then
		return true
	end
	flagText = RestrictedValue:String(flagText)
	schoolMask = RestrictedValue:Value(schoolMask)
	local isCrit = flagText == "CRITICAL"
	if (action == "WOUND" or action == "HEAL")
		and RestrictedValue:IsRestricted(amount) then
		if action == "HEAL" then
			local healTime = self.config.getTime()
			self.lastUnitCombatHealTime = healTime
			self.config.after(0, function()
				self:DisplayRestricted(action, isCrit, amount, flagText, schoolMask, healTime)
			end)
			return true
		end
		self:DisplayRestricted(action, isCrit, amount, flagText, schoolMask)
		return true
	end

	local normalizedAmount = self.config.normalizeNumber(amount)
	local profile = self.config.getProfile()
	if action == "WOUND" then
		if not normalizedAmount or normalizedAmount <= 0 then
			return true
		end
		local settings = profile.events.INCOMING_DAMAGE
		if not settings or settings.disabled then
			return true
		end
		self:QueueDamage(
			normalizedAmount,
			isCrit,
			GetDamageSource(flagText, schoolMask)
		)
		return true
	end

	if action == "HEAL" then
		if not normalizedAmount or normalizedAmount <= 0 then
			return true
		end
		self.lastUnitCombatHealTime = self.config.getTime()
		local baseKey, critKey, isSelfHeal, sourceName = ResolveHealKeys(self)
		local settings = profile.events[baseKey]
		local critSettings = profile.events[critKey]
		local normalEnabled = settings and not settings.disabled
		local critEnabled = critSettings and not critSettings.disabled
		if not normalEnabled and not (isCrit and critEnabled) then
			return true
		end

		self:QueueHeal(
			normalizedAmount,
			isCrit,
			isSelfHeal,
			sourceName,
			GetHealSourceLabel(flagText, schoolMask),
			baseKey,
			critKey,
			self:GetOverheal(normalizedAmount)
		)
		return true
	end

	local settings = profile.events["INCOMING_" .. action]
	if settings and not settings.disabled then
		local message = self.config.buildActionMessage(settings, normalizedAmount)
		if message and message ~= "" then
			self.config.display(settings, message)
		end
	end
	return true
end

local function DisplayCombatTextHeal(self, isPeriodic, isCrit, amount, healerName, healTime)
	local playerName = StripRealm(self.config.unitName("player"), self.config.unknown)
	healerName = healerName and StripRealm(healerName, self.config.unknown)
	local isSelfHeal = not healerName or healerName == playerName
	local baseKey = (isSelfHeal and "SELF_" or "INCOMING_")
		.. (isPeriodic and "HOT" or "HEAL")
	local profile = self.config.getProfile()
	local settings = profile.events[baseKey]
	local critSettings = profile.events[baseKey .. "_CRIT"]
	if isCrit and critSettings and not critSettings.disabled then
		settings = critSettings
	end
	if not settings or settings.disabled then
		return
	end

	local spellName, texture = GetHealSpell(self, isSelfHeal, healTime)
	if RestrictedValue:IsRestricted(amount) then
		self.config.displayRestricted(
			settings,
			amount,
			texture,
			InsertSpellName(settings.message, spellName)
		)
		return
	end
	local overheal = self:GetOverheal(amount)
	if overheal >= amount and profile.hideFullOverheals then
		return
	end
	local message = self.config.buildActionMessage(
		settings,
		amount,
		overheal,
		spellName
	)
	if message and message ~= "" then
		self.config.display(settings, message, texture)
	end
end

local COMBAT_TEXT_HEALS = {
	HEAL = { isPeriodic = false, isCrit = false },
	HEAL_CRIT = { isPeriodic = false, isCrit = true },
	PERIODIC_HEAL = { isPeriodic = true, isCrit = false },
	PERIODIC_HEAL_CRIT = { isPeriodic = true, isCrit = true },
}

function IncomingCombat:HandleCombatText(eventType, healerName, amount)
	local healType = COMBAT_TEXT_HEALS[eventType]
	if not healType then
		return
	end
	healerName = RestrictedValue:String(healerName)
	if not RestrictedValue:IsRestricted(amount) then
		amount = self.config.normalizeNumber(amount)
		if not amount or amount <= 0 then
			return
		end
	end

	local eventTime = self.config.getTime()
	self.config.after(0, function()
		if self.lastUnitCombatHealTime ~= eventTime then
			DisplayCombatTextHeal(
				self,
				healType.isPeriodic,
				healType.isCrit,
				amount,
				healerName,
				eventTime
			)
		end
	end)
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.IncomingCombat = IncomingCombat

return IncomingCombat
