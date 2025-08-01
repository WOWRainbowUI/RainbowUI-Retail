local mod	= DBM:NewMod("AtonementTrash", "DBM-Party-Shadowlands", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20250722005255")
mod:SetZone(2287)
mod:RegisterZoneCombat(2287)
--mod:SetModelID(47785)

mod.isTrashMod = true
mod.isTrashModBossFightAllowed = true

mod:RegisterEvents(
	"SPELL_CAST_START 326409 326450 325523 325700 325701 326607 326441",
	"SPELL_AURA_APPLIED 326450 326891",
--	"SPELL_AURA_REMOVED 326409",
	"UNIT_DIED"
)

--[[
(ability.id = 341902) and (type = "begincast" or type = "cast")
 or stoppedAbility.id = 341902
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (source.type = "NPC" and source.firstSeen = timestamp and source.id = 174197) or (target.type = "NPC" and target.firstSeen = timestamp and target.id = 174197)
--]]
--Notable Halkias Trash
local warnThrash						= mod:NewSpellAnnounce(326409, 3)
local warnLoyalBeasts					= mod:NewCastAnnounce(326450, 4)--Announce the cast, in case someone can stun it

--General
--local specWarnGTFO					= mod:NewSpecialWarningGTFO(257274, nil, nil, nil, 1, 8)
--Notable Halkias Trash
local specWarnSinQuake					= mod:NewSpecialWarningDodge(326441, nil, nil, nil, 2, 2)
local specWarnLoyalBeasts				= mod:NewSpecialWarningTarget(326450, "RemoveEnrage|Tank", nil, nil, 1, 2)--Target because it's hybrid warning
local specWarnDeadlyThrust				= mod:NewSpecialWarningDodge(325523, "Tank", nil, nil, 1, 2)
local specWarnCollectSins				= mod:NewSpecialWarningInterrupt(325700, "HasInterrupt", nil, nil, 1, 2)
local specWarnSiphonLife				= mod:NewSpecialWarningInterrupt(325701, "HasInterrupt", nil, nil, 1, 2)
--Notable Echelon Trash
local specWarnTurntoStone				= mod:NewSpecialWarningInterrupt(326607, "HasInterrupt", nil, nil, 1, 2)
local specWarnTurnToStoneOther			= mod:NewSpecialWarningDodge(326607, nil, nil, nil, 2, 2)

--Antispam IDs for this mod: 1 run away, 2 dodge, 3 dispel, 4 incoming damage, 5 you/role, 6 generalized

function mod:SPELL_CAST_START(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 326409 and self:AntiSpam(3, 4) then
		warnThrash:Show()
	elseif spellId == 326450 and self:AntiSpam(3, 6) then
		warnLoyalBeasts:Show()
	elseif spellId == 325523 and self:AntiSpam(3, 2) then
		specWarnDeadlyThrust:Show()
		specWarnDeadlyThrust:Play("shockwave")
	elseif spellId == 326441 and self:AntiSpam(3, 2) then
		specWarnSinQuake:Show()
		specWarnSinQuake:Play("watchstep")
	elseif spellId == 325700 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnCollectSins:Show(args.sourceName)
		specWarnCollectSins:Play("kickcast")
	elseif spellId == 325701 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnSiphonLife:Show(args.sourceName)
		specWarnSiphonLife:Play("kickcast")
	elseif spellId == 326607 then
		if self:CheckInterruptFilter(args.sourceGUID, false, true) then
			specWarnTurntoStone:Show(args.sourceName)
			specWarnTurntoStone:Play("kickcast")
		elseif self:AntiSpam(3, 2) then
			specWarnTurnToStoneOther:Show()
			specWarnTurnToStoneOther:Play("watchstep")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 326450 and self:AntiSpam(3, 5) then
		specWarnLoyalBeasts:Show(args.destName)
		specWarnLoyalBeasts:Play("enrage")
	end
end

--[[
--This is faster but in reality it's actually too fast. it results in almost 4-5 seconds before damage goes out.
--"<185.37 23:03:18> [CLEU] SPELL_AURA_REMOVED#Creature-0-2085-2287-9145-164557-000126FD07#Shard of Halkias#Creature-0-2085-2287-9145-164557-000126FD07#Shard of Halkias#326409#Thrash#BUFF#nil", -- [1273]
--"<186.29 23:03:19> [CLEU] SPELL_CAST_START#Creature-0-2085-2287-9145-164557-000126FD07#Shard of Halkias##nil#326441#Sin Quake#nil#nil", -- [1286]
function mod:SPELL_AURA_REMOVED(args)
	if not self.Options.Enabled then return end
	local spellId = args.spellId
	if spellId == 326409 then
		specWarnSinQuake:Show()
		specWarnSinQuake:Play("watchstep")
	end
end
--]]

function mod:UNIT_DIED(args)
	if not self.Options.Enabled then return end
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 0 then--???

	end
end

--All timers subject to a ~0.5 second clipping due to ScanEngagedUnits
function mod:StartEngageTimers(guid, cid, delay)
	if cid == 0 then--???

	end
end

--Abort timers when all players out of combat, so NP timers clear on a wipe
--Caveat, it won't call stop with GUIDs, so while it might terminate bar objects, it may leave lingering nameplate icons
function mod:LeavingZoneCombat()
	self:Stop(true)
end
