local mod	= DBM:NewMod(649, "DBM-Party-MoP", 4, 303)
local L		= mod:GetLocalizedStrings()

if DBM:IsRetail() then
	mod.statTypes = "normal,heroic,challenge,timewalker"
end

mod:SetRevision("20250915043254")
mod:SetCreatureID(56877)
mod:SetEncounterID(1419)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 107146 111723 111600",
	"SPELL_AURA_REMOVED 111723 111600",
	"SPELL_CAST_START 111668 111728"
)

local warnHeadbutt				= mod:NewSpellAnnounce(111668, 2)
local warnScreechingSwarm		= mod:NewTargetNoFilterAnnounce(111600, 4, nil, false)--Can be spam if adds not die.
local warnBrokenCarapace		= mod:NewSpellAnnounce(107146, 1)--Phase 2
local warnFixate				= mod:NewTargetNoFilterAnnounce(111723, 4)
local warnStomp					= mod:NewCountAnnounce(111728, 3)

local timerHeadbuttCD			= mod:NewNextTimer(33, 111668, nil, nil, nil, 3)
local timerScreechingSwarm		= mod:NewTargetTimer(10, 111600, nil, nil, nil, 5)
local timerFixate				= mod:NewTargetTimer(15, 111723, nil, nil, nil, 5)
local timerFixateCD				= mod:NewNextTimer(20.5, 111723, nil, nil, nil, 3)
local timerStompCD				= mod:NewNextCountTimer(20.5, 111728, nil, nil, nil, 2)

mod.vb.stompcount = 0

function mod:OnCombatStart(delay)
	self.vb.stompcount = 0
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 107146 then
		warnBrokenCarapace:Show()
		timerHeadbuttCD:Cancel()
		timerFixateCD:Start(5.5)--Timing for target pick, not cast start.
		timerStompCD:Start(20.5, 1)
	elseif args.spellId == 111723 then
		warnFixate:Show(args.destName)
		timerFixate:Start(args.destName)
		timerFixateCD:Start()
	elseif args.spellId == 111600 then
		warnScreechingSwarm:Show(args.destName)
		timerScreechingSwarm:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 111723 then
		timerFixate:Cancel(args.destName)
	elseif args.spellId == 111600 then
		timerScreechingSwarm:Cancel(args.destName)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 111668 then
		warnHeadbutt:Show()
		timerHeadbuttCD:Start()
	elseif args.spellId == 111728 then
		self.vb.stompcount = self.vb.stompcount + 1
		warnStomp:Show(self.vb.stompcount)
		timerStompCD:Start(20.5, self.vb.stompcount+1)
	end
end
