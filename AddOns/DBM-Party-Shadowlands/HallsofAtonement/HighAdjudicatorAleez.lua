local mod	= DBM:NewMod(2411, "DBM-Party-Shadowlands", 4, 1185)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250821014351")
mod:SetCreatureID(165410)
mod:SetEncounterID(2403)
mod:SetHotfixNoticeRev(20250808000000)
--mod:SetMinSyncRevision(20211203000000)
mod:SetZone(2287)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 329340 323538",--323552
	"SPELL_CAST_SUCCESS 1236512",
	"SPELL_SUMMON 323597",
	"SPELL_AURA_APPLIED 323650 1236513",
	"SPELL_AURA_REMOVED 323650"
--	"SPELL_CAST_SUCCESS",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 323552 or ability.id = 329340) and type = "begincast"
 or ability.id = 1236512 and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or ability.id = 323597
 or ability.id = 323538 and type = "begincast"
--]]
local warnFixate					= mod:NewTargetNoFilterAnnounce(323650, 4)
--local warnUnstableAnima			= mod:NewTargetNoFilterAnnounce(1236512, 3, nil, "RemoveMagic")

local specWarnFixate				= mod:NewSpecialWarningYou(323650, nil, nil, nil, 3, 2)
local yellFixate					= mod:NewShortYell(323650, nil, false)
local specWarnUnstableAnima			= mod:NewSpecialWarningMoveAway(1236512, nil, nil, nil, 2, 2)
local yellUnstableAnima				= mod:NewShortYell(1236512)
local specWarnAnimaBolt				= mod:NewSpecialWarningInterrupt(323538, false, nil, nil, 1, 2)
--local specWarnVolleyofPower		= mod:NewSpecialWarningInterrupt(323552, "HasInterrupt", nil, nil, 1, 2)--Disabled in 11.2
local specWarnAnimaFountain			= mod:NewSpecialWarningDodgeCount(329340, nil, nil, nil, 2, 2)
--local specWarnGTFO				= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)

--local timerVolleyofPowerCD		= mod:NewCDTimer(10.9, 323552, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)--12-20
local timerSpectralProcessionCD		= mod:NewCDCountTimer(20.4, 323597, nil, nil, nil, 1)
local timerAnimaFountainCD			= mod:NewCDCountTimer(23, 329340, nil, nil, nil, 3)
local timerUnstableAnimaCD			= mod:NewCDCountTimer(15.7, 1236512, nil, nil, nil, 3)

mod:AddNamePlateOption("NPAuraOnFixate", 323650, true)

--local vesselName = DBM:GetSpellName(323848)
mod.vb.spectralCount = 0
mod.vb.animaFountainCount = 0
mod.vb.unstableAnimaCount = 0

function mod:OnCombatStart(delay)
	self.vb.spectralCount = 0
	self.vb.animaFountainCount = 0
	self.vb.unstableAnimaCount = 0
	timerUnstableAnimaCD:Start(10.6-delay, 1)
	timerSpectralProcessionCD:Start(15.6-delay, 1)
	timerAnimaFountainCD:Start(20.3-delay, 1)
	if self.Options.NPAuraOnFixate then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.NPAuraOnFixate then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 329340 then
		self.vb.animaFountainCount = self.vb.animaFountainCount + 1
		specWarnAnimaFountain:Show(self.vb.animaFountainCount)
		specWarnAnimaFountain:Play("watchstep")
		timerAnimaFountainCD:Start(nil, self.vb.animaFountainCount+1)
	elseif spellId == 323538 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnAnimaBolt:Show(args.sourceName)
			specWarnAnimaBolt:Play("kickcast")
		end
--	elseif spellId == 323552 then
--		timerVolleyofPowerCD:Start()
--		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
--			specWarnVolleyofPower:Show(args.sourceName)
--			specWarnVolleyofPower:Play("kickcast")
--		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 1236512 then
		self.vb.unstableAnimaCount = self.vb.unstableAnimaCount + 1
		timerUnstableAnimaCD:Start(nil, self.vb.unstableAnimaCount+1)
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 323597 then
		self.vb.spectralCount = self.vb.spectralCount + 1
		timerSpectralProcessionCD:Start(nil, self.vb.spectralCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 323650 then
		warnFixate:CombinedShow(1, args.destName)
		if args:IsPlayer() then
			if self:AntiSpam(3, 2) then
				specWarnFixate:Show()
				specWarnFixate:Play("targetyou")
				yellFixate:Yell()
			end
			if self.Options.NPAuraOnFixate then
				DBM.Nameplate:Show(true, args.sourceGUID, spellId)
			end
		end
	elseif spellId == 1236513 then
		--warnUnstableAnima:CombinedShow(0.5, args.destName)
		if args:IsPlayer() then
			specWarnUnstableAnima:Show()
			specWarnUnstableAnima:Play("scatter")
			yellUnstableAnima:Yell()
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 323650 then
		if self.Options.NPAuraOnFixate then
			DBM.Nameplate:Hide(true, args.sourceGUID, spellId)
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 309991 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 257453  then

	end
end
--]]
