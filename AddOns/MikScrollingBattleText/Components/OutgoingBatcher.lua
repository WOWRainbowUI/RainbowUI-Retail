local OutgoingBatcher = {}
OutgoingBatcher.__index = OutgoingBatcher
local WINDFURY_WEAPON_SPELL_ID = 8232
local WINDFURY_GROUP_DELAY = 1

function OutgoingBatcher:New(config)
	return setmetatable({
		config = config,
		batches = {},
	}, self)
end

function OutgoingBatcher:Reset()
	for key in pairs(self.batches) do
		self.batches[key] = nil
	end
end

function OutgoingBatcher:ShouldStackWindfury(spellID, isPet, isDot)
	return spellID == WINDFURY_WEAPON_SPELL_ID and not isPet and not isDot
		and self.config.getProfile().stackSimilarHits
end

function OutgoingBatcher:BuildMessage(amount, hitCount, batch, settings)
	local profile = self.config.getProfile()
	local school = batch and batch.school
	if settings.attackColorOverride then school = nil end
	local formattedAmount
	if batch and (batch.isPet or batch.eventKey) then
		formattedAmount = self.config.formatEventMessage(
			settings, amount, batch.spellID, school
		)
	else
		formattedAmount = self.config.formatAmount(
			amount, profile, school
		)
	end
	if not profile.stackSimilarHits then
		return formattedAmount
	end
	if hitCount == 1 then
		return formattedAmount
	end

	local translations = MikSBT.translations
	return string.format("%s [%d %s]", formattedAmount, hitCount,
		translations and translations.MSG_HITS or "Hits")
end

function OutgoingBatcher:DamageSettings(settings, isSpell, isDot, school)
	if isDot or (isSpell and school ~= 1) then return settings end
	-- Use attack colors without changing the user's saved event settings.
	return setmetatable({
		colorR = 1, colorG = 1, colorB = isSpell and 0 or 1,
		attackColorOverride = true,
	}, { __index = settings })
end

-- Finds the event settings to use.
-- For critical hits, check the _CRIT event first; if disabled or absent,
-- fall back to the normal base event.
local function ResolveEventSettings(events, baseKey, isCrit)
	if isCrit then
		local critKey = baseKey .. "_CRIT"
		local critSettings = events[critKey]
		if critSettings and not critSettings.disabled then
			return critKey, critSettings
		end
	end
	local settings = events[baseKey]
	if settings and not settings.disabled then
		return baseKey, settings
	end
	return nil
end

function OutgoingBatcher:ResolveSettings(isSpell, isPet, isDot, eventKey, isCrit)
	local events = self.config.getProfile().events
	-- Use explicit event key if provided.
	if eventKey then
		return ResolveEventSettings(events, eventKey, isCrit)
	end
	local prefix = isPet and "PET_" or ""
	-- Check DoT event settings.
	if isDot then
		local resolvedKey, dotSettings = ResolveEventSettings(
			events, prefix .. "OUTGOING_SPELL_DOT", isCrit
		)
		if dotSettings then
			return resolvedKey, dotSettings
		end
	end
	-- Check primary damage event (spell vs melee).
	local primaryKey = prefix .. (isSpell
		and "OUTGOING_SPELL_DAMAGE"
		or "OUTGOING_DAMAGE")
	local resolvedKey, settings = ResolveEventSettings(events, primaryKey, isCrit)
	if settings then
		return resolvedKey, settings
	end

	-- Fall back to secondary damage event if primary is disabled.
	local secondaryKey = prefix .. (isSpell
		and "OUTGOING_DAMAGE"
		or "OUTGOING_SPELL_DAMAGE")
	return ResolveEventSettings(events, secondaryKey, isCrit)
end

function OutgoingBatcher:Flush(batchKey)
	local batch = self.batches[batchKey]
	if not batch then
		return
	end
	self.batches[batchKey] = nil

	local _, displaySettings = self:ResolveSettings(
		batch.isSpell, batch.isPet, batch.isDot, batch.eventKey, batch.isCrit
	)
	if not displaySettings then
		return
	end
	displaySettings = self:DamageSettings(displaySettings,
		batch.isSpell, batch.isDot, batch.school)
	local school = batch.school
	if displaySettings.attackColorOverride then school = nil end
	if batch.hasRestricted then
		if batch.hitCount == 1 then
			self.config.displayRestricted(displaySettings, batch.amounts[1],
				batch.effectTexture, "%a", nil, school)
		else
			self.config.displayRestrictedGroup(displaySettings, batch.amounts,
				batch.effectTexture, school)
		end
		return
	end
	self.config.display(
		displaySettings,
		self:BuildMessage(batch.totalAmount, batch.hitCount, batch, displaySettings),
		batch.effectTexture
	)
end

function OutgoingBatcher:DisplayRestricted(
	spellID,
	amount,
	isCrit,
	effectTexture,
	forceIsSpell,
	isPet,
	isDot,
	eventKey,
	school
)
	if self:ShouldStackWindfury(spellID, isPet, isDot) then
		self:Queue(spellID, amount, isCrit, effectTexture, forceIsSpell,
			isPet, isDot, eventKey, true, school)
		return
	end
	if not effectTexture and not isDot and not eventKey then
		spellID = spellID or self.config.autoAttackSpellID
		effectTexture = self.config.getSpellTexture(spellID)
	end
	local isSpell = isDot or forceIsSpell or not self.config.isAutoAttack(spellID)
	local _, settings = self:ResolveSettings(isSpell, isPet, isDot, eventKey, isCrit)
	if not settings then
		return
	end
	settings = self:DamageSettings(settings, isSpell, isDot, school)
	if settings.attackColorOverride then school = nil end
	local message = not eventKey and not isPet and "%a" or nil
	self.config.displayRestricted(settings, amount, effectTexture,
		message, nil, school)
end

function OutgoingBatcher:Queue(
	spellID,
	amount,
	isCrit,
	effectTexture,
	forceIsSpell,
	isPet,
	isDot,
	eventKey,
	isRestricted,
	school
)
	if not isRestricted and (not amount or amount <= 0) then
		return
	end

	if not effectTexture and (spellID or (not isDot and not eventKey)) then
		effectTexture = self.config.getSpellTexture(
			spellID or self.config.autoAttackSpellID
		)
	end
	if not effectTexture and not isDot and not eventKey then
		spellID = self.config.autoAttackSpellID
		effectTexture = self.config.getSpellTexture(spellID)
	end

	local stackWindfury = self:ShouldStackWindfury(spellID, isPet, isDot)
	local batchKey = (isPet and "pet:" or "") .. (isDot and "dot:" or "")
		.. tostring(spellID or 0) .. (isCrit and ":crit" or "")
	if stackWindfury then batchKey = batchKey .. ":stacked" end
	if eventKey then batchKey = eventKey .. ":" .. batchKey end
	if school then batchKey = batchKey .. ":school:" .. school end
	local batch = self.batches[batchKey]
	if not batch then
		local isSpell = forceIsSpell or isDot
		if isSpell == nil then
			isSpell = not self.config.isAutoAttack(spellID)
		end
		batch = {
			hitCount = 0,
			isCrit = not not isCrit,
			totalAmount = 0,
			spellID = spellID,
			school = school,
			isSpell = isSpell,
			isPet = isPet,
			isDot = isDot,
			eventKey = eventKey,
			effectTexture = effectTexture,
			amounts = stackWindfury and {} or nil,
		}
		self.batches[batchKey] = batch
		local delay = stackWindfury and WINDFURY_GROUP_DELAY or self.config.delay
		self.config.after(delay, function()
			if self.batches[batchKey] == batch then
				self:Flush(batchKey)
			end
		end)
	end
	if forceIsSpell then
		batch.isSpell = true
	end

	batch.hitCount = batch.hitCount + 1
	if batch.amounts then
		batch.amounts[#batch.amounts + 1] = amount
	end
	if isRestricted then
		batch.hasRestricted = true
	else
		batch.totalAmount = batch.totalAmount + amount
	end
	if effectTexture and not batch.effectTexture then
		batch.effectTexture = effectTexture
	end
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.OutgoingBatcher = OutgoingBatcher

return OutgoingBatcher
