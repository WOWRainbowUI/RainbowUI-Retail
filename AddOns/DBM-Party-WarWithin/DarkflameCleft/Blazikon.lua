local mod	= DBM:NewMod(2559, "DBM-Party-WarWithin", 1, 1210)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250513082122")
mod:SetCreatureID(208743)
mod:SetEncounterID(2826)
mod:SetHotfixNoticeRev(20250222000000)
mod:SetMinSyncRevision(20250222000000)
mod:SetZone(2651)
mod:SetUsedIcons(1, 2, 3)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 421817 424212 421910 423109 425394 443835",
	"SPELL_AURA_APPLIED 421817",--423080
	"SPELL_AURA_REMOVED 421817"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
)

--[[
(ability.id = 421817 or ability.id = 424212 or ability.id = 421910 or ability.id = 423109 or ability.id = 425394 or ability.id = 443835) and type = "begincast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (ability.id = 423080 or ability.id = 421817) and type = "applydebuff"
--]]
local warnWicklighterBarrage				= mod:NewTargetNoFilterAnnounce(421817, 2)
local warnExtinguishingGust					= mod:NewIncomingCountAnnounce(421910, 2)
local warnEnkindlingInferno					= mod:NewCountAnnounce(423109, 3)
local warnDousingBreath						= mod:NewCountAnnounce(425394, 3)
local warnBlazingStorms						= mod:NewSpellAnnounce(443835, 3)

local specWarnWicklighterBarrage			= mod:NewSpecialWarningYou(421817, nil, nil, nil, 1, 2)
local yellWicklighterBarrage				= mod:NewShortPosYell(421817)
local specWarnInciteFlames					= mod:NewSpecialWarningCount(424212, nil, nil, nil, 2, 2)
--local specWarnExtinguishingGust			= mod:NewSpecialWarningYou(429113, nil, nil, nil, 1, 2)
--local yellExtinguishingGust				= mod:NewShortYell(429113)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerWicklighterBarrageCD				= mod:NewNextCountTimer(60.3, 421817, nil, nil, nil, 3)
local timerInciteFlamesCD					= mod:NewNextCountTimer(60.3, 424212, nil, nil, nil, 2)
local timerExtinguishingGustCD				= mod:NewNextCountTimer(60.3, 421910, nil, nil, nil, 3, nil, DBM_COMMON_L.MYTHIC_ICON)
local timerEnkindlingInfernoCD				= mod:NewNextCountTimer(30.3, 423109, nil, nil, nil, 2)
local timerDousingBreathCD					= mod:NewNextCountTimer(60.3, 425394, nil, nil, nil, 2)

mod:AddSetIconOption("IconOnWick", 421817, true, 0, {1, 2, 3})
mod:AddPrivateAuraSoundOption(423080, true, 429113, 1)

mod.vb.debuffIcon = 1
mod.vb.wickCount = 0
mod.vb.inciteCount = 0
mod.vb.gustCount = 0
mod.vb.infernoCount = 0
mod.vb.breathCount = 0

function mod:OnCombatStart(delay)
	self.vb.debuffIcon = 1
	self.vb.wickCount = 0
	self.vb.inciteCount = 0
	self.vb.gustCount = 0
	self.vb.infernoCount = 0
	self.vb.breathCount = 0
	timerDousingBreathCD:Start(3.4-delay, 1)
	timerWicklighterBarrageCD:Start(7.0-delay, 1)
	timerEnkindlingInfernoCD:Start(20.5-delay, 1)
	timerExtinguishingGustCD:Start(25.5-delay, 1)
	timerInciteFlamesCD:Start(37.6-delay, 1)
	self:EnablePrivateAuraSound(423080, "targetyou", 2)
end

--function mod:OnCombatEnd()

--end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 421817 then
		self.vb.debuffIcon = 1
		self.vb.wickCount = self.vb.wickCount + 1
		timerWicklighterBarrageCD:Start(nil, self.vb.wickCount+1)
	elseif spellId == 424212 then
		self.vb.inciteCount = self.vb.inciteCount + 1
		specWarnInciteFlames:Show(self.vb.inciteCount)
		specWarnInciteFlames:Play("aesoon")
		timerInciteFlamesCD:Start(nil, self.vb.inciteCount+1)
	elseif spellId == 421910 then
		self.vb.gustCount = self.vb.gustCount + 1
		warnExtinguishingGust:Show(self.vb.gustCount)
		timerExtinguishingGustCD:Start(nil, self.vb.gustCount+1)
	elseif spellId == 423109 then
		self.vb.infernoCount = self.vb.infernoCount + 1
		warnEnkindlingInferno:Show(self.vb.infernoCount)
		timerEnkindlingInfernoCD:Start(nil, self.vb.infernoCount+1)
	elseif spellId == 425394 then
		self.vb.breathCount = self.vb.breathCount + 1
		warnDousingBreath:Show(self.vb.breathCount)
		timerDousingBreathCD:Start((self.vb.breathCount == 1) and 55.8 or 60.7, self.vb.breathCount+1)
	elseif spellId == 443835 then
		warnBlazingStorms:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 421817 then
		warnWicklighterBarrage:PreciseShow(3, args.destName)
		if args:IsPlayer() then
			specWarnWicklighterBarrage:Show()
			specWarnWicklighterBarrage:Play("targetyou")
			yellWicklighterBarrage:Yell(self.vb.debuffIcon, self.vb.debuffIcon)
		end
		if self.Options.IconOnWick then
			self:SetIcon(args.destName, self.vb.debuffIcon)
		end
		self.vb.debuffIcon = self.vb.debuffIcon + 1
	--elseif spellId == 423080 then
	--	warnExtinguishingGust:CombinedShow(0.5, args.destName)--Change to PreciseShow once we confirm if it's 2 or 4 targets
	--	if args:IsPlayer() then
	--		specWarnExtinguishingGust:Show()
	--		specWarnExtinguishingGust:Play("targetyou")
	--		yellExtinguishingGust:Yell()
	--	end
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 421817 then
		if self.Options.IconOnWick then
			self:SetIcon(args.destName, 0)
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]
