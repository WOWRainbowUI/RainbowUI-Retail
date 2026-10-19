local OutgoingBatcher = {}
OutgoingBatcher.__index = OutgoingBatcher

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

function OutgoingBatcher:BuildMessage(amount, hitCount, batch, settings)
	local profile = self.config.getProfile()
	local formattedAmount
	if batch and batch.isPet then
		formattedAmount = self.config.formatEventMessage(settings, amount, batch.spellID)
	else
		formattedAmount = self.config.formatAmount(amount, profile)
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

function OutgoingBatcher:ResolveSettings(isSpell, isPet, isDot)
	local profile = self.config.getProfile()
	local prefix = isPet and "PET_" or ""
	if isDot then
		local dotKey = prefix .. "OUTGOING_SPELL_DOT"
		local dotSettings = profile.events[dotKey]
		if dotSettings and not dotSettings.disabled then
			return dotKey, dotSettings
		end
	end
	local primaryKey = prefix .. (isSpell
		and "OUTGOING_SPELL_DAMAGE"
		or "OUTGOING_DAMAGE")
	local secondaryKey = prefix .. (isSpell
		and "OUTGOING_DAMAGE"
		or "OUTGOING_SPELL_DAMAGE")
	local settings = profile.events[primaryKey]
	if settings and not settings.disabled then
		return primaryKey, settings
	end

	settings = profile.events[secondaryKey]
	if settings and not settings.disabled then
		return secondaryKey, settings
	end
	return nil
end

function OutgoingBatcher:Flush(batchKey)
	local batch = self.batches[batchKey]
	if not batch then
		return
	end
	self.batches[batchKey] = nil

	local eventKey, settings = self:ResolveSettings(batch.isSpell, batch.isPet, batch.isDot)
	if not settings then
		return
	end
	local profile = self.config.getProfile()
	local critSettings = profile.events[eventKey .. "_CRIT"]
	local displaySettings = settings
	if batch.isCrit and critSettings and not critSettings.disabled then
		displaySettings = critSettings
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
	isDot
)
	if not effectTexture and not isDot then
		spellID = spellID or self.config.autoAttackSpellID
		effectTexture = self.config.getSpellTexture(spellID)
	end
	local isSpell = isDot or forceIsSpell or not self.config.isAutoAttack(spellID)
	local eventKey, settings = self:ResolveSettings(isSpell, isPet, isDot)
	if not settings then
		return
	end
	local critSettings = self.config.getProfile().events[eventKey .. "_CRIT"]
	if isCrit and critSettings and not critSettings.disabled then
		settings = critSettings
	end
	self.config.displayRestricted(settings, amount, effectTexture, not isPet and "%a" or nil)
end

function OutgoingBatcher:Queue(
	spellID,
	amount,
	isCrit,
	effectTexture,
	forceIsSpell,
	isPet,
	isDot
)
	if not amount or amount <= 0 then
		return
	end

	if not effectTexture and (spellID or not isDot) then
		effectTexture = self.config.getSpellTexture(
			spellID or self.config.autoAttackSpellID
		)
	end
	if not effectTexture and not isDot then
		spellID = self.config.autoAttackSpellID
		effectTexture = self.config.getSpellTexture(spellID)
	end

	local batchKey = (isPet and "pet:" or "") .. (isDot and "dot:" or "")
		.. tostring(spellID or 0) .. (isCrit and ":crit" or "")
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
			isSpell = isSpell,
			isPet = isPet,
			isDot = isDot,
			effectTexture = effectTexture,
		}
		self.batches[batchKey] = batch
		self.config.after(self.config.delay, function()
			if self.batches[batchKey] == batch then
				self:Flush(batchKey)
			end
		end)
	end
	if forceIsSpell then
		batch.isSpell = true
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + amount
	if effectTexture and not batch.effectTexture then
		batch.effectTexture = effectTexture
	end
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.OutgoingBatcher = OutgoingBatcher

return OutgoingBatcher
