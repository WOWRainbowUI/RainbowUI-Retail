local OutgoingCombat = {}
OutgoingCombat.__index = OutgoingCombat

local RestrictedValue = MikSBT.API.RestrictedValue

local PET_MIN_SWING_FRACTION = 0.45

function OutgoingCombat:New(config)
	return setmetatable({
		config = config,
		lastSpellID = nil,
		lastSpellTime = 0,
		lastSpellConsumed = false,
		lastPetSpellID = nil,
		lastPetSpellTime = 0,
		petSpellConsumed = false,
		lastPetMeleeTime = 0,
		dotSpellID = nil,
		dotAuraIDs = nil,
		dotRequiresAura = true,
		dotExpires = 0,
		lastAutoAttackTime = 0,
	}, self)
end

function OutgoingCombat:GetLastSpell()
	return self.lastSpellID, self.lastSpellTime
end

function OutgoingCombat:Reset()
	self:ResetCombatState()
	self.config.batcher:Reset()
end

function OutgoingCombat:ResetCombatState()
	self.dotSpellID = nil
	self.dotAuraIDs = nil
	self.dotRequiresAura = true
	self.dotExpires = 0
	self.lastAutoAttackTime = 0
	self.lastPetMeleeTime = 0
	if self.config.damageMeter then
		self.config.damageMeter:Reset()
	end
end

function OutgoingCombat:Start()
	if self.config.damageMeter then
		self.config.damageMeter:Start()
	end
end

function OutgoingCombat:Stop()
	if self.config.damageMeter then
		self.config.damageMeter:Stop()
	end
end

function OutgoingCombat:HandleSpellcastSucceeded(unitID, spellID)
	if unitID == "pet" and spellID then
		self.lastPetSpellID = spellID
		self.lastPetSpellTime = self.config.getTime()
		self.petSpellConsumed = false
		return true
	end
	if unitID ~= "player" or not spellID then
		return false
	end

	self.lastSpellID = spellID
	self.lastSpellTime = self.config.getTime()
	self.lastSpellConsumed = false
	local timedDuration = self.config.timedDotSpells[spellID]
	if timedDuration then
		self.dotSpellID = spellID
		self.dotAuraIDs = nil
		self.dotRequiresAura = false
		self.dotExpires = self.lastSpellTime + timedDuration
		return true
	end

	local auraIDs = self.config.dotSpells[spellID]
	if auraIDs then
		self.dotSpellID = spellID
		self.dotAuraIDs = auraIDs
		self.dotRequiresAura = true
		self.dotExpires = self.lastSpellTime + self.config.dotDuration
	end
	return true
end

function OutgoingCombat:IsDotFallbackActive(now)
	if not self.dotSpellID or now > self.dotExpires then
		return false
	end
	if not self.dotRequiresAura then
		return true
	end
	return self.config.hasPlayerDebuff(self.dotAuraIDs)
end

function OutgoingCombat:HasRecentSignal(now, schoolMask)
	if self.lastSpellID
		and now - self.lastSpellTime <= self.config.signalWindow then
		return true
	end
	if self:IsDotFallbackActive(now) then
		return true
	end
	if self.config.isLikelySpellSchool(schoolMask)
		and self.config.isPlayerSolo() then
		return true
	end
	if not self.config.isLikelySpellSchool(schoolMask) then
		return self.config.canUseAutoAttackFallback(
			now,
			self.lastAutoAttackTime
		)
	end
	return false
end

function OutgoingCombat:ResolveAttribution(now, isDamage, schoolMask)
	local spellID
	local texture
	local canBeDotTick = isDamage
		and self.config.isLikelySpellSchool(schoolMask)
		and self.config.isPlayerSolo()
	local castLanded = canBeDotTick and self.lastSpellConsumed
	if not castLanded and self.lastSpellID
		and now - self.lastSpellTime
			<= self.config.fallbackAttributionWindow then
		spellID = self.lastSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	if not texture and not castLanded and isDamage and self.lastSpellID
		and not self.config.isAutoAttack(self.lastSpellID)
		and now - self.lastSpellTime
			<= self.config.delayedAttributionWindow then
		spellID = self.lastSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	if not texture and isDamage and self:IsDotFallbackActive(now) then
		spellID = self.dotSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	if not texture and canBeDotTick then
		return nil, nil, true
	end
	if not texture then
		if not isDamage then
			return nil
		end
		if not self.config.canUseAutoAttackFallback(
			now,
			self.lastAutoAttackTime
		) then
			return nil
		end
		spellID = self.config.autoAttackSpellID
		texture = self.config.getSpellTexture(spellID)
	end
	return spellID, texture
end

function OutgoingCombat:ResolvePetAttribution(now, isDamage, schoolMask)
	if not self.config.isPetEngaged() then
		return nil
	end
	local window = self.config.delayedAttributionWindow
	local petPending = self.lastPetSpellID and not self.petSpellConsumed
		and now - self.lastPetSpellTime <= window
	local playerPending = self.lastSpellID and not self.lastSpellConsumed
		and not self.config.isAutoAttack(self.lastSpellID)
		and not self.config.isHelpfulSpell(self.lastSpellID)
		and now - self.lastSpellTime <= window
	if petPending
		and (not playerPending or self.lastPetSpellTime <= self.lastSpellTime) then
		if isDamage then
			self.petSpellConsumed = true
		end
		return self.lastPetSpellID, true
	end
	if self.config.isLikelySpellSchool(schoolMask) then
		return nil
	end

	local petSpeed = self.config.getSwingSpeed("pet")
	local petElapsed = now - self.lastPetMeleeTime
	if petElapsed < petSpeed * PET_MIN_SWING_FRACTION then
		return nil
	end
	if playerPending then
		return nil
	end
	if self.config.isPlayerAutoAttacking() then
		local playerSpeed = self.config.getSwingSpeed("player")
		if (now - self.lastAutoAttackTime) / playerSpeed > petElapsed / petSpeed then
			return nil
		end
	end
	if isDamage then
		self.lastPetMeleeTime = now
	end
	return self.config.autoAttackSpellID, false
end

function OutgoingCombat:HandlePetHit(action, spellID, isSpell, isCrit, amount, normalizedAmount, now)
	local texture = isSpell and self.config.getSpellTexture(spellID) or nil
	if action ~= "WOUND" then
		local settings = self.config.getProfile().events["PET_OUTGOING_" .. action]
		if settings and not settings.disabled then
			local message = self.config.buildActionMessage(settings, normalizedAmount)
			if message and message ~= "" then
				self.config.display(settings, message, texture)
			end
		end
		return true
	end
	if RestrictedValue:IsRestricted(amount) then
		self.config.batcher:DisplayRestricted(spellID, amount, isCrit, texture, isSpell, true)
		return true
	end
	if not normalizedAmount or normalizedAmount <= 0 then
		return true
	end
	if self.config.damageMeter and self.config.damageMeter:IsActive()
		and self.config.damageMeter:IsDeltaFresh(now) then
		return true
	end
	self.config.batcher:Queue(spellID, normalizedAmount, isCrit, texture, isSpell, true)
	return true
end

function OutgoingCombat:QueueDamage(
	spellID,
	amount,
	isCrit,
	texture,
	schoolMask
)
	local forceIsSpell = spellID == self.config.autoAttackSpellID
		and self.config.isLikelySpellSchool(schoolMask)
		or nil
	if spellID == self.config.autoAttackSpellID then
		self.lastAutoAttackTime = self.config.getTime()
	end
	self.config.batcher:Queue(
		spellID,
		amount,
		isCrit,
		texture,
		forceIsSpell
	)
end

function OutgoingCombat:HandleUnitCombat(
	unitTarget,
	action,
	flagText,
	amount,
	schoolMask
)
	if not RestrictedValue:Equals(unitTarget, "target") then
		return false
	end
	if not self.config.inCombat() or not self.config.isTargetValid() then
		return true
	end

	action = RestrictedValue:String(action)
	if not action then
		return true
	end
	flagText = RestrictedValue:String(flagText)
	schoolMask = RestrictedValue:Value(schoolMask)
	local isDamage = action == "WOUND"
	local isCrit = flagText == "CRITICAL"
	local normalizedAmount = self.config.normalizeNumber(amount)
	local now = self.config.getTime()
	local petSpellID, petIsSpell = self:ResolvePetAttribution(now, isDamage, schoolMask)
	if petSpellID then
		return self:HandlePetHit(action, petSpellID, petIsSpell, isCrit, amount, normalizedAmount, now)
	end
	if isDamage and not self:HasRecentSignal(now, schoolMask) then
		return true
	end

	local spellID, texture, isDot = self:ResolveAttribution(now, isDamage, schoolMask)
	if isDot then
		if self.config.damageMeter and self.config.damageMeter:IsActive()
			and self.config.damageMeter:IsDeltaFresh(now) then
			return true
		end
		if RestrictedValue:IsRestricted(amount) then
			self.config.batcher:DisplayRestricted(spellID, amount, isCrit, texture, true, nil, true)
		elseif normalizedAmount and normalizedAmount > 0 then
			self.config.batcher:Queue(spellID, normalizedAmount, isCrit, texture, true, nil, true)
		end
		return true
	end
	if not spellID then
		return true
	end
	if isDamage and spellID == self.lastSpellID then
		self.lastSpellConsumed = true
	end
	if isDamage and RestrictedValue:IsRestricted(amount) then
		if spellID == self.config.autoAttackSpellID then
			self.lastAutoAttackTime = now
		end
		self.config.batcher:DisplayRestricted(
			spellID,
			amount,
			flagText == "CRITICAL",
			texture,
			spellID == self.config.autoAttackSpellID
				and self.config.isLikelySpellSchool(schoolMask)
				or nil
		)
		return true
	end
	if isDamage then
		if not normalizedAmount or normalizedAmount <= 0 then
			return true
		end
		if self.config.damageMeter and self.config.damageMeter:IsActive()
			and self.config.damageMeter:IsDeltaFresh(now)
			and spellID ~= self.dotSpellID then
			return true
		end
		self:QueueDamage(
			spellID,
			normalizedAmount,
			flagText == "CRITICAL",
			texture,
			schoolMask
		)
		return true
	end

	local profile = self.config.getProfile()
	local settings = profile.events["OUTGOING_" .. action]
	if settings and not settings.disabled then
		local message = self.config.buildActionMessage(settings, normalizedAmount)
		if message and message ~= "" then
			self.config.display(settings, message, texture)
		end
	end
	return true
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.OutgoingCombat = OutgoingCombat

return OutgoingCombat
