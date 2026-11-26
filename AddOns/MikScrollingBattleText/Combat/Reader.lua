-- Adapted from Forever Combat Text 0.6.8 (Tarolg, MIT).
-- See Combat/LICENSE-ForeverCombatText. MSBT uses its own presentation.
local ns = MikSBT.CombatEngine
local C_Timer = ns.Timer
local GearProcs = ns.GearProcs

local LOG_PAIR = 0.1  -- a line and a hit this close together may be one event
local LOG_WAIT = 0.15 -- a line waits this long for its hit before it is drawn

-- Read hits, casts, swings, auras, and combat-log timing. MSBT owns
-- presentation and its dedicated loot, gain, and cooldown sources.

local reader = {
    epoch = 0, plateGeneration = 0, plates = {}, held = {},
    lastGlow = {}, lastCC = {}, swingTimes = {}, castTargets = {},
    windfuryCasts = {},
    windfuryCooldownFrames = {},
    extraAttackCasts = {}, extraAttackGUIDs = {},
    pendingHits = setmetatable({}, { __mode = "k" }),
}
ns.reader = reader

local function Now() return GetTime() end

local DEPARTED_TARGET_WINDOW = 0.5

local function RememberDepartedTarget()
    if not reader.targetKey then return end
    reader.departedTargetKey = reader.targetKey
    reader.departedTargetAt = Now()
    reader.targetKey = nil
end

local function DepartedTargetKey()
    if reader.departedTargetAt
        and Now() - reader.departedTargetAt <= DEPARTED_TARGET_WINDOW then
        return reader.departedTargetKey
    end
    reader.departedTargetKey, reader.departedTargetAt = nil, nil
end

-- Unit keys -----------------------------------------------------------------------
-- Tokens are reusable. Evidence belongs to one visible lifetime of a token.
local function PlateKey(token)
    local generation = token and reader.plates[token]
    if generation == nil then return nil end
    return token .. ":" .. tostring(generation)
end

local function RekeyTarget(old, new)
    if not old or not new or old == new then return end
    ns.mine:Rekey(old, new)
    if ns.windfuryInference then ns.windfuryInference:Rekey(old, new) end
    ns.RekeyHealing(old, new)
    local function Move(entry)
        if entry.key == old then entry.key = new end
        if entry.victimKey == old then entry.victimKey = new end
        if entry.record and entry.record.victimKey == old then
            entry.record.victimKey = new
        end
        local accounting = entry.record and entry.record.accounting
        if accounting then
            if accounting.key == old then accounting.key = new end
            local receipt = accounting.receipt
            if receipt then
                if receipt.key == old then receipt.key = new end
                if receipt.sourceKey == old then receipt.sourceKey = new end
            end
            local evidence = accounting.evidence
            if evidence and evidence.targetContext == old then
                evidence.targetContext = new
            end
        end
        if entry.held and entry.held.key == old then entry.held.key = new end
    end
    for _, field in ipairs({ "swingTimes", "swingHits", "frameHits",
        "held", "yourHits", "castTargets" }) do
        for _, entry in ipairs(reader[field] or {}) do Move(entry) end
    end
    for hit in pairs(reader.pendingHits or {}) do Move(hit) end
    for _, line in ipairs(reader.logLines or {}) do
        if line.targetContext == old then line.targetContext = new end
        if line.hit then Move(line.hit) end
    end
    if reader.lastCastTarget then Move(reader.lastCastTarget) end
    if reader.targetKey == old then reader.targetKey = new end
    if reader.departedTargetKey == old then reader.departedTargetKey = new end
    if reader.strangers[old] then
        reader.strangers[new], reader.strangers[old] = reader.strangers[old], nil
    end
    if ns.traceCombat then
        ns.traceCombat("rekey", nil, { old = old, new = new })
    end
end

local function FindTargetPlate()
    reader.targetPlate = nil
    if not UnitExists("target") then return end
    for token in pairs(reader.plates) do
        local same = UnitIsUnit(token, "target")
        if ns.Bool(same) and same then reader.targetPlate = token return end
    end
end
function ns.TargetKey()
    local exists = UnitExists("target")
    if not (ns.Bool(exists) and exists) then
        RememberDepartedTarget()
        return nil
    end
    reader.departedTargetKey, reader.departedTargetAt = nil, nil
    local self = UnitIsUnit("target", "player")
    if ns.Bool(self) and self then
        reader.targetKey = nil
        return nil
    end
    reader.targetKey = PlateKey(reader.targetPlate) or reader.targetKey
        or ("target" .. reader.epoch)
    return reader.targetKey
end

local function UnitFlag(getter, unit)
    if type(getter) ~= "function" then return end
    local ok, value = pcall(getter, unit)
    if ok and ns.Bool(value) then return value end
end

local function CaptureVictim(unit, key)
    if not key or UnitFlag(UnitExists, unit) ~= true then return end
    local player = UnitFlag(UnitIsPlayer, unit)
    if player == nil then return end
    return { isPlayer = player }
end

local function PetAttacking(token)
    local exists = UnitExists("pet")
    if not (ns.Bool(exists) and exists) then return false end
    local same = UnitIsUnit("pettarget", token)
    return ns.Bool(same) and same
end
-- The router and engine -------------------------------------------------------------
local function Router() return ns.liveRouter end

-- A combat log line's kind, when its colour says it (0.3.48; LineSource,
-- below, and Setup.lua's KINDS). What a line of this kind can come with
-- ("damage", "miss", "heal"), nil for a kind that comes with no hit (an
-- interrupt, a mana gain).
local function LineClass(line)
    local info = line.kind and ns.LINE_KINDS and ns.LINE_KINDS[line.kind]
    return info and info.class
end
local function LineRestrict(line)
    local info = line.kind and ns.LINE_KINDS and ns.LINE_KINDS[line.kind]
    return info and info.restrict
end
local EARLY_LINE, LATE_LINE = 0.35, 0.12

local function FindLocalHealLine(at)
    local best, distance
    for _, line in ipairs(reader.logLines or {}) do
        local gap = line.at - at
        if line.source == "mine" and LineClass(line) == "heal"
            and not line.claimed and not line.hit
            and gap >= -EARLY_LINE and gap <= LATE_LINE
            and (not distance or math.abs(gap) < distance) then
            best, distance = line, math.abs(gap)
        end
    end
    return best
end

local function SendOutgoingLocalHeal(live, record, at, result, line, tick)
    if not result then return end
    local outgoing = {}
    for field, value in pairs(record) do outgoing[field] = value end
    -- Pet here describes the recipient, not the caster.
    outgoing.pet, outgoing.selfHeal = nil, nil
    outgoing.tick = tick
    outgoing.result = { who = result.who, spell = result.spell, tick = tick }
    if line then
        line.claimed, line.hit = true, { at = at, record = outgoing }
    end
    live:Out(outgoing)
end

local function OutgoingLocalHeal(record, unit, at, result)
    local line = FindLocalHealLine(at)
    if not line and ns.EventAvailable("COMBAT_LOG_MESSAGE") then return end
    local tick = record.tick
    if line then tick = LineRestrict(line) == "tick" end
    result = result or ns.MatchHealing(unit, at, tick, true)
    local live = Router()
    if live then SendOutgoingLocalHeal(live, record, at, result, line, tick) end
end

local function PresentForeverLocalHeal(live, record, unit, at)
    local line = FindLocalHealLine(at)
    local inferredTick = record.tick
    if line then record.tick = LineRestrict(line) == "tick" end
    local result = ns.TagIncomingHeal(record, unit, at, line and true)
    if not result then record.tick = inferredTick end
    live:In(record)
    if line then SendOutgoingLocalHeal(live, record, at, result, line, record.tick) end
end

local function RecordClass(record) return record and (record.event == "miss" and "miss" or record.event) end
-- Whether a line of yours may be the one of this hit (any hit without one):
-- a grey line (no kinds) any; a coloured one only a hit of its class.
local function Pairs(line, record)
    if line.source ~= "mine" and line.source ~= "unknown" then return false end
    if not line.kind then return true end
    local class = LineClass(line)
    if not class then return false end
    return record == nil or class == RecordClass(record)
end

-- A hit no cast or swing explains waits LATE_SWING for a swing reported
-- after it; then it goes out as someone else's, unless a combat log line of
-- yours came with it.
local LinesRunning, DecideGroup
local WeaponProcTrigger
local SettleSharedName
local function TagProcCandidate(result, at, school, key)
    if result.ambiguous or not result.proc or result.spell
        or result.drain then return end
    local candidate = ns.ProcCandidate and ns.ProcCandidate(at, school, key)
    result.procCandidate = candidate ~= nil
    result.candidateSpell = candidate
end

local function FlushHeld()
    local now = Now()
    local keep = {}
    for _, entry in ipairs(reader.held) do
        if entry.held.claimed then
            -- Sent already, by the swing that claimed it.
        elseif now - entry.at >= ns.LATE_SWING then
            -- 0.3.26 (the user agreed): a hit nothing places stays someone
            -- else's even when a line of yours came in its frame. Wand bolts
            -- and lost DoTs, which this used to catch, have their own rules
            -- now; with every message type in the filter, what was left was
            -- mostly a teammate's hit beside one of your aura or honour
            -- lines (a 541 Physical crit shown as a warlock's, 1.60.1.70374).
            -- 0.3.33: except a proc riding on a hit of yours (below).
            if entry.proc then
                entry.record.result = { who = "you", proc = true }
                TagProcCandidate(entry.record.result, entry.at,
                    entry.record.school, entry.held.key)
            end
            local router = Router()
            if router then router:Out(entry.record) end
        else
            keep[#keep + 1] = entry
        end
    end
    reader.held = keep
    if #keep > 0 then C_Timer.After(0.1, FlushHeld) end
end

local FEEDBACK = { MISS = true, DODGE = true, PARRY = true, BLOCK = true, RESIST = true, EVADE = true, IMMUNE = true,
    DEFLECT = true, ABSORB = true, REFLECT = true }

-- One UNIT_COMBAT report as a record: its kind, amount, school and flags.
local function Describe(event, flag, amount, school)
    if not ns.Text(event) then return nil end
    flag = ns.Text(flag) and flag or ""
    school = ns.Number(school, 1, 255) and school or nil
    -- avoid keeps the game's own word ("PARRY") so the engine can tell which
    -- of your actions could have been avoided so (Mine.lua, CastTakesMiss).
    if event == "WOUND" then
        if ns.Number(amount) and amount == 0 then
            if flag == "ABSORB" or flag == "BLOCK" or flag == "RESIST" then
                return { event = "miss", missWord = ns.MissWord(flag), school = school, avoid = flag }
            end
            return { event = "miss", missWord = ns.MissWord("MISS"), school = school, avoid = "MISS" }
        end
        return {
            event = "damage", amount = amount, school = school,
            crit = flag == "CRITICAL",
        }
    elseif event == "HEAL" then
        return { event = "heal", amount = amount, school = school, crit = flag == "CRITICAL" }
    elseif FEEDBACK[event] then
        return { event = "miss", missWord = ns.MissWord(event), school = school, avoid = event }
    end
end
ns.DescribeCombat = Describe

-- A partly blocked hit on you (WOUND with flag BLOCK_REDUCED) reports only
-- the damage taken. A partial block always stops exactly your shield block
-- value (a hit it would stop whole is a full Block instead), so that is the
-- amount blocked. GetShieldBlock is hidden in combat: the last value read
-- out of combat is kept (at login, gear changes and the end of a fight).
local SHIELD_BLOCK_SETTLE = 1 -- stats settle a moment after a gear change
local function ReadShieldBlock()
    -- Retail exposes block armor, not a flat amount of damage blocked.
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not client or not client.isForever then
        reader.shieldBlock = nil
        return
    end
    if type(GetShieldBlock) ~= "function" then return end
    local ok, value = pcall(GetShieldBlock)
    if ok and ns.Number(value) then
        reader.shieldBlock = value >= 1 and math.floor(value + 0.5) or nil
    end
end

-- Ticks on you: a steady beat of one school and kind.
local beats = {}
local function Beat(kind, school, now)
    local key = kind .. ":" .. tostring(school)
    local beat = beats[key]
    local tick = false
    if beat then
        local gap = now - beat.last
        if beat.interval and math.abs(gap - beat.interval) <= 0.35 and gap >= 0.9 and gap <= 3.3 then tick = true end
        beat.interval, beat.last = gap, now
    else
        beats[key] = { last = now }
    end
    return tick
end

local function OnUnitCombat(unit, event, flag, amount, school)
    if not ns.Text(unit) then return end
    local record = Describe(event, flag, amount, school)
    if not record then return end
    local router = Router()
    if not router then return end
    local now = Now()
    if unit == "player" or unit == "pet" then
        if unit == "pet" then record.pet = true end
        -- 0.3.49: heals on you, so a hit that gave you its amount in the
        -- same moment reads as a drain (ns.DecideHit).
        if unit == "player" and record.event == "heal" and ns.Number(amount, 1) then
            local heals = reader.playerHeals
            while heals[1] and (now - heals[1].at > 1 or #heals > 16) do table.remove(heals, 1) end
            heals[#heals + 1] = { at = now, amount = amount }
        end
        if record.event == "damage" or record.event == "heal" then
            record.tick = Beat((unit == "pet" and "pet" or "") .. record.event, record.school, now)
        end
        if unit == "player" and record.event == "damage"
            and ns.Text(flag) and flag == "BLOCK_REDUCED" then
            ReadShieldBlock()
            record.blocked, record.blockedAmount = true, reader.shieldBlock
        end
        if record.event == "heal" then
            local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
            if client and client.isForever and ns.HEAL_SPELLS
                and ns.EventAvailable("COMBAT_LOG_MESSAGE") then
                -- The first tick has no cadence yet. Wait for a log line
                -- so both displays can use its classification and spell.
                ns.Timer.After(LATE_LINE, function()
                    PresentForeverLocalHeal(router, record, unit, now)
                end)
                return
            end
            -- A heal can arrive before its cast succeeds in the same frame.
            -- Resolve the spell before presentation copies the record.
            C_Timer.After(0, function()
                local result = ns.TagIncomingHeal(record, unit, now)
                local live = Router()
                if live then
                    live:In(record)
                    C_Timer.After(LATE_LINE, function()
                        OutgoingLocalHeal(record, unit, now, result)
                    end)
                end
            end)
        else
            router:In(record)
        end
        return
    end
    local key, token
    if unit == "target" then
        if record.event == "heal" then
            local pet = UnitIsUnit("target", "pet")
            if ns.Bool(pet) and pet then return end
        end
        key, token = ns.TargetKey(), "target"
        -- Death can remove the target before its final damage report.
        -- Keep this fallback out of TargetKey so new casts cannot use it.
        if not key and record.event == "damage" then
            key = DepartedTargetKey()
        end
        if not key then return end
    elseif unit:match("^nameplate%d+$") then
        if not reader.plates[unit] or unit == reader.targetPlate then return end
        -- 0.6.3: your pet's own plate (a Succubus's): its hits come as
        -- "pet" too, and a miss on it had taken your swing's line.
        local pet = UnitIsUnit(unit, "pet")
        if ns.Bool(pet) and pet then return end
        key, token = PlateKey(unit), unit
        record.plate = unit
    else
        return
    end
    if record.event == "damage" then
        record.victimKey, record.victim = key, CaptureVictim(unit, key)
    end
    -- A partly blocked hit on this unit. How much it blocked is not told, so
    -- its trailer names no amount.
    if record.event == "damage" and ns.Text(flag) and flag == "BLOCK_REDUCED" then
        record.blocked = true
    end
    local hit = { record = record, key = key, at = now, unit = unit,
        petOn = PetAttacking(token) }
    reader.pendingHits[hit] = true
    if ns.traceCombat then ns.traceCombat("report", hit) end
    -- 0.3.8: while lines of yours come, a hit is decided at the end of its
    -- frame, once every line of that frame has come (the game sends a hit
    -- and its line in the same frame, either one first; 1.60.1.70374).
    if LinesRunning and LinesRunning() then
        reader.frameHits[#reader.frameHits + 1] = hit
        if #reader.frameHits == 1 then C_Timer.After(0, ns.DecideFrame) end
        return
    end
    ns.DecideHit(hit, nil)
end

-- line: true when a line of yours came in the hit's frame, false when none
-- did, nil when unknown (Mine.lua). restrict (0.3.48): what made the hit,
-- from the line's colour ("direct", "tick", "swing", "shot"), or nil.
-- 0.3.49: a hit that healed you for its own amount in the same moment (a
-- Drain Life tick, Touch of the Grave): both amounts are plain numbers, and
-- the heal on you came in the hit's frame in every recorded case
-- (1.60.1.70374). True when one matched, nil otherwise.
reader.playerHeals = {}
local function Leech(hit)
    local record = hit.record
    if record.event ~= "damage" or not ns.Number(record.amount, 1) then return nil end
    for _, heal in ipairs(reader.playerHeals) do
        if math.abs(heal.at - hit.at) <= 0.01 and heal.amount == record.amount then return true end
    end
end

-- 0.6.7 (the user, 19 October 2026): a proc on your swing takes the icon and
-- name of the seal or poison you last applied, while it can still be on: a
-- seal lasts 30 s on Forever (SpellDuration, 1.60.1.70450), a poison an hour
-- at most. The game never says which spell a proc was.
-- 0.6.8: an oil lasts 30 minutes and an enchant stays; several can be on at
-- once (a seal and an enchant), so a hit takes the newest one of its school,
-- and none when no source of its school is on (Thunderfury beside a seal).
local PROC_KEEP = { seal = 35, poison = 3660, oil = 1860, enchant = math.huge }
local windfuryWeapon = ns.WindfuryWeapon or {}
local MELEE_WEAPON_SLOTS = { 16, 17 }

local function ActiveWindfurySpell(school)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not windfuryWeapon.enchants or not client or not client.isForever
        or school ~= ns.SCHOOL_PHYSICAL then
        return nil
    end
    local getEnchant = C_PaperDollInfo
        and C_PaperDollInfo.GetTemporaryEnchantmentInfo
    if type(getEnchant) == "function" then
        for _, slot in ipairs(MELEE_WEAPON_SLOTS) do
            local ok, info = pcall(getEnchant, slot)
            if not ok then return nil end
            if type(info) == "table" and ns.Public(info)
                and ns.Number(info.enchantID, 1)
                and windfuryWeapon.enchants[info.enchantID] then
                return windfuryWeapon.iconSpell
            end
        end
        return nil
    end
    if type(GetWeaponEnchantInfo) ~= "function" then return nil end
    local ok, hasMain, mainTime, mainCharges, mainID,
        hasOff, offTime, offCharges, offID = pcall(GetWeaponEnchantInfo)
    if not ok then return nil end
    if ns.Bool(hasMain) and hasMain and ns.Number(mainID, 1)
        and windfuryWeapon.enchants[mainID] then return windfuryWeapon.iconSpell end
    if ns.Bool(hasOff) and hasOff and ns.Number(offID, 1)
        and windfuryWeapon.enchants[offID] then return windfuryWeapon.iconSpell end
end
ns.ActiveWindfurySpell = ActiveWindfurySpell

-- A damage shield's hit (Thorns, Retribution Aura, an item's) comes with a
-- line of its own kind, but nothing in a fight says which shield struck,
-- and no call tells a damage shield from another buff. The client's spell
-- data lists the damage shields with their school (DamageShields.lua), and
-- your buffs are read out of combat (reader.auras, below): a hit takes the
-- one shield of its school you have on, none when there are several
-- (predicted, not yet seen in client). Only a hit whose frame brought
-- shield lines alone is a shield's (Mine.lua, Hit): beside a line of
-- another kind either line can be the hit's, and it stays unnamed. A shield
-- counts as on where its end was read (0 for never) and is not past, or
-- where your cast of it on yourself explained a hidden change of your auras
-- since the last scan (below); a shield of the hit's school whose end could
-- not be read leaves the hit unnamed. While a change of your auras that
-- could not be read and may have added an aura waits half a second for an
-- explanation, and after one that found none until a scan reads all your
-- buffs, no hit is named (reader.auraChanges, reader.aurasUnsure, below).
local function ShieldSpell(at, school)
    if reader.aurasUnsure or #reader.auraChanges > 0 then return nil end
    local shields, found = MikSBT.DAMAGE_SHIELDS or {}
    for _, entry in pairs(reader.auras or {}) do
        local shieldSchool = entry.spell and shields[entry.spell]
        if shieldSchool and shieldSchool == school then
            local expires = entry.expires
            if expires == nil and not entry.learned then return nil end
            if entry.learned or expires == 0 or expires > at then
                if found and found ~= entry.spell then return nil end
                found = entry.spell
            end
        end
    end
    return found
end

reader.procSources = {}
local PERIODIC_PROC_AMBIGUITY_WINDOW = 0.5

local function PeriodicProcCast(at, school, key)
    if not key then return false end
    for spell, casts in pairs(ns.mine.casts) do
        local facts = ns.SpellFacts(spell)
        if facts and facts.ticks == true and facts.direct == false
            and facts.school == school then
            for _, cast in ipairs(casts) do
                local age = at - cast.at
                if cast.caster == "you" and cast.key == key
                    and age >= 0 and age <= PERIODIC_PROC_AMBIGUITY_WINDOW then
                    return true
                end
            end
        end
    end
    return false
end

local function ProcCandidate(at, school, key)
    -- Active effects support candidate diagnostics and grouping, not identity.
    local windfury = ActiveWindfurySpell(school)
    if windfury then
        -- A bleed application can share the swing's direct confirmations.
        -- Keep this candidate separate from the known periodic effect.
        if PeriodicProcCast(at, school, key) then return nil end
        local rules = ns.PlayerClassRules()
        if rules and rules.windfuryWeapon then return windfury end
        return nil
    end
    local best
    for kind, source in pairs(reader.procSources) do
        local fresh = at - source.at <= (PROC_KEEP[kind] or 0)
        local fits = school == nil or source.school == nil or source.school == school
        if fresh and fits and (not best or source.at > best.at) then best = source end
    end
    return best and best.spell or nil
end
ns.ProcCandidate = ProcCandidate
-- Compatibility boundary: active effects cannot prove a damage spell's ID.
ns.ProcSpell = function() return nil end

local function TracksOutcomes()
    return ns.mine and (ns.mine.accountingEnabled == true
        or ns.mine.inferredWindfuryEnabled == true)
end

local function ConfirmingEvidence(hit, evidence, shared)
    hit.confirmation = evidence or false
    hit.sharedConfirmation = shared == true
    if not TracksOutcomes() then return end
    hit.accountingEvidence = nil
    if not evidence then return end
    if not shared then
        hit.accountingEvidence = {
            at = evidence.at, source = evidence.source, kind = evidence.kind,
            targetContext = evidence.targetContext, shared = false, capacity = 1,
        }
        return
    end
    local first = evidence[1]
    if not first then return end
    local info = { at = first.at, source = first.source, kind = first.kind,
        shared = true, capacity = #evidence }
    for _, line in ipairs(evidence) do
        if line.at ~= info.at or line.source ~= info.source then
            info.at, info.source, info.ambiguous = nil, nil, true
            break
        end
        if line.kind ~= info.kind then info.kind = nil end
    end
    hit.accountingEvidence = info
end

-- Whether nobody else is seen to strike this unit: you are in no party or
-- raid, your pet is at nothing, and for STRANGER_QUIET no report on the unit
-- went without a line of yours (ns.DecideHit). It cannot see the first
-- strike of someone who joins.
local STRANGER_QUIET = 5
reader.strangers = {}
reader.unmatchedDamage = {}
local function NoteStranger(key, at)
    for other, seen in pairs(reader.strangers) do
        if at - seen > STRANGER_QUIET then reader.strangers[other] = nil end
    end
    reader.strangers[key] = math.max(reader.strangers[key] or at, at)
end
local function Alone(key, at)
    local party, raid = IsInGroup and IsInGroup(), IsInRaid and IsInRaid()
    if not ns.Bool(party) or party or (ns.Bool(raid) and raid) or ns.mine.petOut then return false end
    local seen = reader.strangers[key]
    return not seen or at - seen > STRANGER_QUIET
end

function ns.DecideHit(hit, line, restrict)
    local router = Router()
    if not router then return end
    local record = hit.record
    local kind = record.event == "miss" and "miss" or record.event
    if line == true then SettleSharedName(hit, kind, restrict) end
    local swingChecks = ns.mine and ns.mine.accountingEnabled
        and (kind == "damage" or kind == "miss")
        and ns.mine:AccountingSwingChecks(hit.key, hit.at) or nil
    local leech = Leech(hit)
    local result
    if hit.unidentified then
        result = ns.mine:ConfirmUnidentified(hit.key, record.school, hit.at)
    elseif kind == "heal" then
        result = ns.MatchHealing(hit.key, hit.at, restrict == "tick", line)
            or { who = "other" }
    else
        result = ns.mine:Hit(hit.key, kind, record.school, hit.at, hit.petOn, line,
            ns.Number(record.amount) and record.amount or nil, record.crit,
            restrict, leech, record.avoid, hit.isolatedDirectSpell)
    end
    if line == true and restrict == "direct" and result.who == "you"
        and not result.ambiguous
        and not result.spell and not result.melee and not result.tick
        and windfuryWeapon.iconSpell and WeaponProcTrigger(hit.at, hit.key)
        and ProcCandidate(hit.at, record.school, hit.key)
            == windfuryWeapon.iconSpell then
        result.proc = true
    end
    -- A shield's miss is reported as Physical whatever shield caused it, so
    -- only a shield's damage is named after its school's shield.
    if result.shield and record.event == "damage" then
        result.procSpell = ShieldSpell(hit.at, record.school)
    end
    TagProcCandidate(result, hit.at, record.school, hit.key)
    record.result = result
    local confirmation
    if line == true then confirmation = hit.confirmation or false end
    if TracksOutcomes() then
        record.accounting = {
            at = hit.at, key = hit.key, confirmed = line == true,
            restrict = restrict,
            evidence = line == true and hit.accountingEvidence or nil,
            receipt = kind ~= "heal" and not result.ambiguous
                and ns.mine.lastOutcomeReceipt or nil,
            swingChecks = swingChecks,
        }
    end
    if line == false and (kind == "damage" or kind == "miss") then
        NoteStranger(hit.key, hit.at)
        if kind == "damage" then
            local damage = reader.unmatchedDamage
            local cutoff = Now() - STRANGER_QUIET
            for at in pairs(damage) do
                if at < cutoff then damage[at] = nil end
            end
            damage[hit.at] = true
        end
    end
    reader.pendingHits[hit] = nil
    if ns.traceCombat then
        ns.traceCombat("decision", hit, { stage = "decision",
            confirmed = line, restrict = restrict })
    end
    if result.hold then
        local entry = { record = record, held = result.held, at = hit.at,
            line = line, confirmation = confirmation,
            sharedConfirmation = hit.sharedConfirmation }
        reader.held[#reader.held + 1] = entry
        if #reader.held == 1 then C_Timer.After(ns.LATE_SWING + 0.02, FlushHeld) end
        return result, entry
    end
    if ns.OnYourHit and (result.who == "you" or result.who == "pet") then
        ns.OnYourHit(record, hit.at, confirmation, hit.sharedConfirmation)
    end
    router:Out(record)
    return result
end

-- A proc riding on a hit of yours (0.3.33, best guess for classes not yet
-- played with the addon: poisons, seals, Windfury, Ignite): it comes with
-- no cast, so nothing names its spell, but it lands in the same frame as
-- the hit that set it off, with a line of its own. A hit with a line that
-- nothing placed, in a frame where another hit was placed as yours or your
-- pet's, is shown as yours, without an icon.
local function MarkProcs(decided, swingFrame)
    -- 0.6.5: a frame with your swing in it counts too: a proc reported at
    -- once lands there, while the swing's own hit comes later.
    local placed = swingFrame == true
    for _, item in ipairs(decided) do
        local who = item.result and item.result.who
        if who == "you" or who == "pet" then placed = true break end
    end
    if not placed then return end
    for _, item in ipairs(decided) do
        if item.entry and item.entry.line == true then item.entry.proc = true end
    end
end

-- The hits of a frame against the lines of yours that came in it
-- (DecideGroup, below).
reader.frameHits = {}
local MISS_SETTLE = 0.03 -- a miss with its line waits this for its cast (DecideGroup)
-- Melee swing lines (0.6.1 to 0.6.3, 1.60.1.70450, 19 October 2026,
-- laptop). A melee blow is reported a while after its combat log line, never
-- in the line's frame: your swing's hit 0.45 s after it with a one-hander, a
-- staff's 0.66 to 0.74 s; an enemy's blow on you 0.27 to 0.35 s (a boar) or
-- 1.5 s (an Ashenvale mob) after its line; a Succubus's 0.57 to 1.0 s. So no
-- hit takes a melee line from its own frame (MeleeLine), and each melee line
-- gets one role once its frame is over (Role):
--   "swing"  your swing's: PLAYER_SWING came in its frame, one per swing
--            (SwingLine);
--   "orphan" neither: your pet's swing or an extra attack of yours, which
--            send no PLAYER_SWING (OrphanSwingLine).
local SWING_FRAME = 0.001 -- one frame: its events share one GetTime
local function MeleeLine(line)
    return line.kind ~= nil and LineRestrict(line) == "swing"
end
local function FrameRoles(at)
    local swings = 0
    for _, swing in ipairs(reader.swingTimes) do
        if not swing.ranged and not swing.strike and math.abs(swing.at - at) <= SWING_FRAME then
            swings = swings + 1
        end
    end
    for _, line in ipairs(reader.logLines or {}) do
        if MeleeLine(line) and math.abs(line.at - at) <= SWING_FRAME then
            if swings > 0 then
                line.role, swings = "swing", swings - 1
            else
                line.role = "orphan"
            end
        end
    end
end

local function Role(line)
    if not line.role then FrameRoles(line.at) end
    return line.role
end
-- Whether a melee swing of yours came in this frame, or (within) seconds
-- before it.
local function SwingFrame(at, within)
    for _, swing in ipairs(reader.swingTimes) do
        if not swing.ranged and swing.at <= at + SWING_FRAME and at - swing.at <= (within or SWING_FRAME) then return true end
    end
    return false
end
-- 0.6.8: a proc that flies (Frost Oil's Frostbolt): its line came in the
-- swing's frame or a frame or two after it, and its hit 0.06 to 0.1 s after
-- the swing (a warlock's staff, 1.60.1.70450, laptop; both had been taken
-- for someone else's).
local PROC_FLIGHT = 0.5
local function PeriodicLine(line)
    return line.source == "mine" and LineClass(line) == "damage" and LineRestrict(line) == "tick"
end

local function TickFit(hit)
    local record = hit.record
    if record.event ~= "damage" then return nil end
    local amount = ns.Number(record.amount) and record.amount or nil
    return ns.mine:TickFit(hit.key, record.school, hit.at, amount, Leech(hit))
end
local NonPeriodicPair

local function DecideReports(group, at, settled)
    -- The units this moment's reports landed on (SettleSharedName).
    local landed = {}
    for _, hit in ipairs(group) do landed[hit.key], hit.landed = true, landed end
    local frameLines, kinded = {}, false
    for _, line in ipairs(reader.logLines or {}) do
        local gap = line.at - at
        local nearbyTick = settled and PeriodicLine(line) and not line.hit
            and gap >= -EARLY_LINE and gap <= LATE_LINE
        if (line.at == at or nearbyTick) and Pairs(line) and not line.claimed and not MeleeLine(line) then
            frameLines[#frameLines + 1] = line
            if line.kind then kinded = true end
        end
    end
    local decided = {}
    if not kinded then
        DecideGroup(group, frameLines, decided, settled)
    else
        local byClass, wild = { damage = {}, miss = {}, heal = {} }, {}
        for _, line in ipairs(frameLines) do
            local class = LineClass(line)
            if class then table.insert(byClass[class], line) else wild[#wild + 1] = line end
        end
        for _, class in ipairs({ "damage", "miss", "heal" }) do
            local hitsOf = {}
            for _, hit in ipairs(group) do
                if RecordClass(hit.record) == class then hitsOf[#hitsOf + 1] = hit end
            end
            if #hitsOf > 0 then
                local pool = {}
                for _, line in ipairs(byClass[class]) do pool[#pool + 1] = line end
                for _, line in ipairs(wild) do
                    if not line.claimed then pool[#pool + 1] = line end
                end
                DecideGroup(hitsOf, pool, decided, settled)
            end
        end
    end
    MarkProcs(decided, SwingFrame(at, PROC_FLIGHT))
end

function ns.DecideFrame()
    local hits = reader.frameHits
    reader.frameHits = {}
    ns.mine.petLines = ns.PetLinesInFilter and ns.PetLinesInFilter()
    -- Out and attacking something (0.3.28): which unit it attacks is
    -- secret in battlegrounds, but whether it has a target is not, and a
    -- teammate's 397 crit beside your lines went to a pet with none.
    local petOut, petTarget = UnitExists("pet"), UnitExists("pettarget")
    ns.mine.petOut = ns.Bool(petOut) and petOut and ns.Bool(petTarget) and petTarget
    local byTime, order = {}, {}
    for _, hit in ipairs(hits) do
        if not byTime[hit.at] then byTime[hit.at] = {}; order[#order + 1] = hit.at end
        table.insert(byTime[hit.at], hit)
    end
    table.sort(order)
    for _, at in ipairs(order) do
        local group = byTime[at]
        local waitForTick = false
        for _, hit in ipairs(group) do
            local fit, onBeat = TickFit(hit)
            if fit ~= nil and (onBeat or not NonPeriodicPair(hit)) then
                waitForTick = true
                ns.mine:BufferTicks(hit.key, hit.record.school, hit.at, Now() + LATE_LINE)
            end
        end
        if waitForTick then
            -- A periodic confirmation may precede or follow UNIT_COMBAT in
            -- another frame. Never substitute a coincident shot/spell line.
            -- Each hit keeps one line of its class from its own frame while
            -- it waits: a teammate's blow a frame before a strike had taken
            -- the strike's line looking for a bolt's (DecideLate), and the
            -- strike went to someone else. A tick's line stays free for a
            -- tick reported a frame earlier (predicted, not yet seen in
            -- client).
            local own = {}
            for _, hit in ipairs(group) do
                for _, line in ipairs(reader.logLines or {}) do
                    if line.at == at and not line.claimed and not MeleeLine(line)
                        and not PeriodicLine(line) and Pairs(line, hit.record) then
                        line.claimed, own[#own + 1] = true, line
                        break
                    end
                end
            end
            C_Timer.After(LATE_LINE, function()
                for _, line in ipairs(own) do line.claimed = nil end
                DecideReports(group, at, true)
            end)
        else
            DecideReports(group, at, false)
        end
    end
end

-- The kind lines of yours tell what made a hit (Setup.lua's restrict:
-- "direct", "tick", "swing", "shot"), when the first count of them agree;
-- nil when they do not, or when none is coloured by kind.
local function SharedRestrict(lines, count)
    local restrict
    for index = 1, math.min(count, #lines) do
        local value = LineRestrict(lines[index])
        if not value then return nil end
        if restrict and value ~= restrict then return nil end
        restrict = value
    end
    return restrict
end

-- 0.6.1: a melee swing's line comes in the frame of the swing itself
-- (PLAYER_SWING), and its hit report about 0.45 s later in a frame with no
-- line (a hunter's 21 swings on a boar, every one 0.446 to 0.453 s after
-- its swing and line; 1.60.1.70450, 19 October 2026, laptop). Every auto
-- attack and its misses had been taken for someone else's since 0.3.8. A hit
-- with no line in its frame takes the spare line that came in the frame of a
-- swing of yours on its unit just before, when that line can be a swing's:
-- a melee line of its class with the "swing" role (0.6.3: never an enemy's
-- blow on you in the same frame), or one of no known kind. With stray, the
-- swing may be one whose hit comes at neither of its times (Mine:SwingsBefore).
local function SwingLine(hit, stray)
    local record = hit.record
    if record.event ~= "damage" and record.event ~= "miss" then return nil end
    -- A melee swing's hit is physical (Mine.lua, Yours), so a hit whose school
    -- reads otherwise leaves a melee line to the swing's own hit: a teammate's
    -- spell landing between a swing and its hit had taken the line, was shown
    -- as a proc of yours, and the swing's hit went unshown (predicted, not
    -- yet seen in client).
    local otherSchool = record.event == "damage" and record.school ~= nil and record.school ~= ns.SCHOOL_PHYSICAL
    for _, swing in ipairs(ns.mine:SwingsBefore(hit.key, hit.at, stray)) do
        for _, line in ipairs(reader.logLines or {}) do
            if not line.claimed and not line.hit and Pairs(line, record) and math.abs(line.at - swing.at) <= SWING_FRAME then
                if line.kind == nil and swing.hand ~= "ranged" then return line, swing end
                if MeleeLine(line) and Role(line) == "swing" and not otherSchool then return line, swing end
            end
        end
    end
end

-- 0.6.2 (predicted, not yet seen in client): a swing line with no hit of
-- its own and no swing of yours in its frame is an extra attack of yours
-- (Windfury, Sword Specialization) or your pet's swing, neither of which
-- sends PLAYER_SWING; its hit should come as late as a swing's. A physical
-- hit or a miss on your target with no line in its frame takes it when it
-- came within the delay your swings' hits come after (Mine:MeleeWindow), or
-- up to PET_LATE while your pet is out (0.6.3: a Succubus's blows came 0.57
-- to 1.0 s after its lines). Only the "orphan" role: an enemy's blow on you
-- came with a notice. Only on your target: a pet's or an extra swing is at it.
local ORPHAN_MIN = 0.38 -- above the 0.35 s a boar's blow on you came after its line
local PET_LATE = 1.2
local function OrphanSwingLine(hit)
    local record = hit.record
    if record.event ~= "damage" and record.event ~= "miss" then return nil end
    if record.event == "damage" and record.school ~= nil and record.school ~= ns.SCHOOL_PHYSICAL then return nil end
    if hit.unit ~= "target" then return nil end
    local early, late = ns.mine:MeleeWindow()
    if ns.mine.petOut then late = math.max(late, PET_LATE) end
    for _, line in ipairs(reader.logLines or {}) do
        local gap = hit.at - line.at
        if not line.claimed and not line.hit and MeleeLine(line) and Pairs(line, record)
            and line.targetContext == hit.key
            and gap >= math.max(early, ORPHAN_MIN) and gap <= late and Role(line) == "orphan" then
            return line
        end
    end
end

-- A proc's confirmation can share the swing's frame even when its damage
-- arrives in another frame. Each proc consumes a separate unused damage
-- line from that swing, with a longer delay for physical procs on Forever.
reader.swingHits = {}
local LATE_PHYSICAL_PROC = 1.0
local WEAPON_PROC_TRIGGER_WINDOW = 0.15
local WEAPON_PROC_REPORT_WINDOW = 1.45

WeaponProcTrigger = function(at, key)
    for _, swing in ipairs(reader.swingTimes) do
        local age = at - swing.at
        if not swing.ranged and swing.key == key
            and age >= 0 and age <= WEAPON_PROC_TRIGGER_WINDOW then
            return true
        end
    end
    for spell, casts in pairs(ns.mine.casts) do
        local facts = ns.SpellFacts(spell)
        if facts and facts.direct == true and facts.school == ns.SCHOOL_PHYSICAL
            and facts.helpful ~= true and not facts.weaponProc then
            for _, cast in ipairs(casts) do
                local age = at - cast.at
                if cast.caster == "you" and cast.key == key
                    and age >= 0 and age <= WEAPON_PROC_TRIGGER_WINDOW then
                    return true
                end
            end
        end
    end
    return false
end

local function WeaponProcLine(hit)
    local record = hit.record
    if record.event ~= "damage" or record.school ~= ns.SCHOOL_PHYSICAL
        or not ActiveWindfurySpell(record.school) then
        return nil
    end
    -- Keep the delay relative to the confirmation, including procs triggered
    -- by a physical ability between native swings. Each line is consumed once.
    for _, line in ipairs(reader.logLines or {}) do
        local age = hit.at - line.at
        if not line.claimed and not line.hit and Pairs(line, record)
            and LineRestrict(line) == "direct" and not MeleeLine(line)
            and age >= 0 and age <= WEAPON_PROC_REPORT_WINDOW
            and WeaponProcTrigger(line.at, hit.key) then
            return line
        end
    end
end

local function ProcLine(hit)
    local record = hit.record
    if record.event ~= "damage" and record.event ~= "miss" then return nil end
    local weaponLine = WeaponProcLine(hit)
    if weaponLine then return weaponLine end
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    for _, paired in ipairs(reader.swingHits) do
        local since = hit.at - paired.at
        local nearby = math.abs(since) <= 0.05
        -- Observed Windfury reports follow the ordinary hit by up to
        -- 0.873 s. Their confirmations can also follow the native swing,
        -- so use its existing proc-line window rather than exact frames.
        local delayed = client and client.isForever
            and record.event == "damage"
            and record.school == ns.SCHOOL_PHYSICAL
            and paired.key == hit.key and since >= 0
            and since <= LATE_PHYSICAL_PROC
        if ns.traceCombat then
            ns.traceCombat("candidate", hit, { stage = "pair",
                pairedKey = paired.key, pairAge = since,
                nearby = nearby, delayed = not not delayed })
        end
        if nearby or delayed then
            for _, line in ipairs(reader.logLines or {}) do
                local lineGap = line.at - paired.lineAt
                local sameFrame = math.abs(lineGap) <= SWING_FRAME
                local followsSwing = delayed and LineRestrict(line) == "direct"
                    and lineGap >= -SWING_FRAME and lineGap <= PROC_FLIGHT
                if ns.traceCombat then
                    ns.traceCombat("candidate", hit, { stage = "line",
                        lineGap = lineGap, kind = line.kind,
                        source = line.source, claimed = not not line.claimed,
                        hasHit = not not line.hit, pairs = not not Pairs(line, record),
                        sameFrame = sameFrame, followsSwing = not not followsSwing })
                end
                if not line.claimed and not line.hit and line.kind and not MeleeLine(line) and not PeriodicLine(line) and Pairs(line, record)
                    and ((nearby and sameFrame) or followsSwing) then
                    return line
                end
            end
        end
    end
end
-- A flying proc's hit with no line in its frame: a spare spell line of
-- yours from the moment of a swing of yours up to the hit.
local function FlightProcLine(hit)
    local record = hit.record
    if record.event ~= "damage" and record.event ~= "miss" then return nil end
    for _, line in ipairs(reader.logLines or {}) do
        local gap = hit.at - line.at
        if not line.claimed and not line.hit and line.kind and not MeleeLine(line) and not PeriodicLine(line) and Pairs(line, record)
            and gap >= 0 and gap <= 0.3 and SwingFrame(line.at, PROC_FLIGHT) then
            return line
        end
    end
end
NonPeriodicPair = function(hit)
    if SwingLine(hit) or OrphanSwingLine(hit) or ProcLine(hit) or FlightProcLine(hit) then return true end
    for _, line in ipairs(reader.logLines or {}) do
        if line.at == hit.at and not line.claimed and not line.hit and Pairs(line, hit.record)
            and LineRestrict(line) == "direct" then
            for _, entry in ipairs(ns.mine.pending) do
                local facts = ns.mine.facts(entry.spell)
                if not entry.used and entry.key == hit.key and entry.school == hit.record.school
                    and type(facts) == "table" and facts.direct == true and facts.ticks == false
                    and ns.Number(hit.record.amount) and facts.low and hit.record.amount >= facts.low then
                    return true
                end
            end
        end
    end
end
local function NoteSwingHit(hit, line)
    local list = reader.swingHits
    list[#list + 1] = { at = hit.at, lineAt = line.at, key = hit.key }
    while list[1] and (hit.at - list[1].at > 2 or #list > 16) do table.remove(list, 1) end
end

-- A swing's hit that comes at none of its swing's times (Mine:SwingsBefore,
-- stray). Looked for last, once no line, no swing in its time, no proc and
-- no bolt in flight placed the hit, and only while Alone. Not for a hit that
-- tied with others for a line: which of them the swing's is stays open.
local function StraySwingLine(hit)
    if hit.tied or not Alone(hit.key, hit.at) then return nil end
    return SwingLine(hit, true)
end
local function TakeSwing(hit, line, swing)
    NoteSwingHit(hit, line)
    line.claimed, line.hit = true, { at = hit.at, record = hit.record }
    ns.mine.pairedSwing = swing
end

local function StraySwingDeadline(swing)
    return ns.mine:SwingMatchDeadline(swing) + LATE_LINE + MISS_SETTLE
end

-- Let an in-window report spend the swing before committing a fallback.
local function DeferStraySwing(hit)
    local line, swing = StraySwingLine(hit)
    if not line then return false end
    local deadline = StraySwingDeadline(swing)
    C_Timer.After(math.max(0, deadline - Now()), function()
        if not reader.pendingHits[hit] then return end
        local availableLine, availableSwing = SwingLine(hit, true)
        if availableLine == line and availableSwing == swing and Alone(hit.key, Now()) then
            TakeSwing(hit, line, swing)
            ConfirmingEvidence(hit, line)
            ns.DecideHit(hit, true, LineRestrict(line))
        else
            ns.DecideHit(hit, false)
        end
    end)
    return true
end

-- Hits that fit a line of yours equally well, with fewer such lines than
-- hits: the others are yours too where a swing of yours with no hit yet
-- covers each of them, while Alone. A swing's hit held back one more
-- animation comes with the next swing and with what you cast on that swing:
-- a druid's Rake and the swing before it were both taken for someone else's
-- (1.60.1.70959). Which hit is which stays open, so none is named
-- (Mine:ConfirmUnidentified).
local function SettleTie(hits, lines, Decide)
    local need, matches, swings, deadline = #hits - lines, {}, {}, Now()
    for _, hit in ipairs(hits) do
        if #matches < need and Alone(hit.key, hit.at) then
            local line, swing = SwingLine(hit, true)
            if line and not swings[swing] then
                line.claimed = true
                swings[swing] = true
                matches[#matches + 1] = { hit = hit, line = line, swing = swing }
                deadline = math.max(deadline, StraySwingDeadline(swing))
            end
        end
    end
    for _, match in ipairs(matches) do match.line.claimed = nil end
    if #matches < need then return false end

    for _, hit in ipairs(hits) do hit.unidentified = true end
    local function DecideTie()
        if not reader.pendingHits[hits[1]] then return end
        local confirmed = true
        for _, match in ipairs(matches) do
            local hit, line, swing = match.hit, match.line, match.swing
            if line.claimed or line.hit or swing.used or swing.key ~= hit.key
                or not Alone(hit.key, Now()) then
                confirmed = false
                break
            end
        end
        if confirmed then
            for _, match in ipairs(matches) do
                match.line.claimed, match.swing.used = true, true
            end
        end
        for _, hit in ipairs(hits) do
            hit.unidentified = confirmed
            Decide(hit, confirmed)
        end
    end
    if deadline > Now() then
        C_Timer.After(deadline - Now(), DecideTie)
    else
        DecideTie()
    end
    return true
end

local queuedStrikes = {}
for _, rules in pairs(ns.classRules or {}) do
    if rules.queuedStrikes then
        for spell, enabled in pairs(rules.queuedStrikes) do
            queuedStrikes[spell] = enabled
        end
    end
end

local function PreferQueuedStrikeHit(group, lines, restrict)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not client or not client.isForever or #group ~= 2
        or lines ~= 1 or restrict ~= "direct" then return false end
    local first, last = group[1], group[2]
    if first.key ~= last.key or first.at ~= last.at
        or first.record.event ~= "damage" or last.record.event ~= "damage"
        or first.record.school ~= ns.SCHOOL_PHYSICAL
        or last.record.school ~= ns.SCHOOL_PHYSICAL then return false end
    for _, cast in ipairs(ns.mine.pending) do
        local facts = ns.SpellFacts(cast.spell)
        local nextSwing = queuedStrikes[cast.spell]
            or (facts and facts.nextSwing == true)
        if not cast.used and cast.caster == "you" and cast.key == first.key
            and cast.at == first.at and nextSwing then
            return true
        end
    end
    return false
end

local function MixedFrameDirectHit(first, second, directLine, tickLine)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not client or not client.isForever then return nil end
    local key, at = first.key, first.at
    if key ~= second.key or at ~= second.at or directLine.at ~= at
        or tickLine.at ~= at or directLine.hit or tickLine.hit
        or directLine.source ~= "mine"
        or directLine.targetContext ~= key or tickLine.targetContext ~= key
        or LineRestrict(directLine) ~= "direct" or not Alone(key, at) then
        return nil
    end
    local firstSchool, secondSchool = first.record.school, second.record.school
    if not firstSchool or not secondSchool or firstSchool == secondSchool
        or firstSchool == ns.SCHOOL_PHYSICAL or secondSchool == ns.SCHOOL_PHYSICAL then
        return nil
    end
    local school = ns.mine:MixedFrameDirectSchool(key, firstSchool, secondSchool, at)
    if school == firstSchool then return first, second end
    if school == secondSchool then return second, first end
end

local function UntargetedDirectInstance(hit)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not client or not client.isForever or not IsInInstance
        or hit.record.event ~= "damage" or hit.unit ~= "target" then return end
    local _, instance = IsInInstance()
    if ns.Text(instance) then return instance end
end

local function UntargetedDirectLine(hit, line)
    return line.kind == "spell" and line.source == "mine" and not line.hit
        and line.targetContext == hit.key
end

local function IsolatedDirectInstance(hit, line)
    if not UntargetedDirectLine(hit, line) or line.at ~= hit.at then return false end
    local instance = UntargetedDirectInstance(hit)
    if instance ~= "pvp" and instance ~= "party" then return end
    if hit.record.school ~= ns.SCHOOL_PHYSICAL
        or not (SwingLine(hit) or OrphanSwingLine(hit)
            or SwingFrame(hit.at, WEAPON_PROC_TRIGGER_WINDOW)) then
        return instance
    end
end

local function DecideDungeonDirect(hit)
    if not reader.pendingHits[hit] then return end
    local best
    for _, line in ipairs(reader.logLines) do
        if not line.claimed and UntargetedDirectLine(hit, line)
            and math.abs(line.at - hit.at) <= LATE_LINE then
            for other in pairs(reader.pendingHits) do
                if other ~= hit and other.record.event == "damage"
                    and math.abs(line.at - other.at) <= LATE_LINE then
                    line.dungeonContested = true
                    break
                end
            end
            for at in pairs(reader.unmatchedDamage) do
                if math.abs(line.at - at) <= LATE_LINE then
                    line.dungeonContested = true
                    break
                end
            end
            if best or line.dungeonContested then
                best = nil
                break
            end
            best = line
        end
    end
    if best then
        -- A line after the hit can still match reports after the hit's timer.
        local remaining = best.at + LATE_LINE - Now()
        if remaining >= 0 then
            C_Timer.After(remaining + 0.001, function() DecideDungeonDirect(hit) end)
            return
        end
    end
    if best and ns.mine:UntargetedDirectCandidate(
        hit.key, hit.record.school, hit.at, Leech(hit), true) then
        best.claimed = true
        hit.isolatedDirectSpell = "party"
        ConfirmingEvidence(hit, best)
        ns.DecideHit(hit, true, "direct")
    else
        ns.DecideHit(hit, false)
    end
end

-- One frame's hits (of one class, with lines by kind) against the lines of
-- yours that may be theirs: as many lines as hits (or more: a DoT of yours
-- on an enemy without a plate also sends one) and every hit is yours; none
-- and none is; fewer, and the engine decides as it would without lines.
function DecideGroup(group, frameLines, decided, settled)
    if #group == 1 and #frameLines == 1 then
        group[1].isolatedDirectSpell = IsolatedDirectInstance(group[1], frameLines[1])
    end
    local reportsBySchool, periodicConfirmations = {}, 0
    for _, line in ipairs(frameLines) do
        if PeriodicLine(line) then periodicConfirmations = periodicConfirmations + 1 end
    end
    for _, hit in ipairs(group) do
        local school = hit.record.school or false
        reportsBySchool[school] = reportsBySchool[school] or {}
        reportsBySchool[school][hit.key] = true
    end
    local function CompetingPeriodic(hit)
        return ns.mine.OffscreenTickFit and ns.mine:OffscreenTickFit(
            hit.key, hit.record.school, hit.at,
            periodicConfirmations >= #group
                and reportsBySchool[hit.record.school or false] or nil)
    end
    local function Claim(count)
        for index = 1, math.min(count, #frameLines) do frameLines[index].claimed = true end
    end
    local function Decide(hit, flag, restrict, evidence)
        if flag == true then
            ConfirmingEvidence(hit, evidence or frameLines, evidence == nil)
        end
        local result, entry = ns.DecideHit(hit, flag, flag == true and restrict or nil)
        decided[#decided + 1] = { result = result, entry = entry }
    end
    local remaining, ordinary = {}, {}
    for _, hit in ipairs(group) do remaining[#remaining + 1] = hit end
    for _, line in ipairs(frameLines) do
        if not PeriodicLine(line) then ordinary[#ordinary + 1] = line end
    end
    for _, line in ipairs(frameLines) do
        if PeriodicLine(line) and not line.claimed then
            local best, score, tied, tie
            for index, hit in ipairs(remaining) do
                local fit
                if not CompetingPeriodic(hit) then fit = TickFit(hit) end
                if fit ~= nil and #frameLines > #group then
                    for _, other in ipairs(ordinary) do
                        local restrict = LineRestrict(other)
                        if restrict and LineClass(other) == "damage" then
                            local amount = ns.Number(hit.record.amount) and hit.record.amount or nil
                            local direct = ns.mine:Fit(hit.key, "damage", hit.record.school, hit.at, amount, restrict)
                            if direct and direct < fit then fit = nil break end
                        end
                    end
                end
                if fit ~= nil and (not score or fit < score) then
                    best, score, tied, tie = index, fit, false, { hit }
                elseif fit ~= nil and fit == score then
                    tied = true
                    tie[#tie + 1] = hit
                end
            end
            if tied and #frameLines >= #group and #ordinary > 0 then
                if #group == 2 and #remaining == 2 and #frameLines == 2 then
                    local directLine = ordinary[1]
                    local direct, tick = MixedFrameDirectHit(
                        remaining[1], remaining[2], directLine, line)
                    if direct then
                        directLine.claimed, line.claimed = true, true
                        Decide(direct, true, "direct", directLine)
                        Decide(tick, true, "tick", line)
                        return
                    end
                end
                -- All amounts are confirmed, but the periodic/direct roles
                -- cannot be assigned. Preserve numbers without spending a
                -- guessed spell or teaching a false rhythm.
                for _, ownLine in ipairs(frameLines) do ownLine.claimed = true end
                for _, hit in ipairs(remaining) do
                    hit.unidentified = true
                    Decide(hit, true)
                end
                return
            elseif tied and periodicConfirmations < #group then
                line.claimed, best = true, nil
                local tickLines = { line }
                if #tie == #remaining then
                    for _, spare in ipairs(frameLines) do
                        if #tickLines < #tie and not spare.claimed and PeriodicLine(spare) then
                            tickLines[#tickLines + 1] = spare
                        end
                    end
                end
                for _, hit in ipairs(tie) do hit.tied = true end
                if SettleTie(tie, #tickLines, Decide) then
                    for _, ownLine in ipairs(tickLines) do ownLine.claimed = true end
                    for _, hit in ipairs(tie) do
                        for index = #remaining, 1, -1 do
                            if remaining[index] == hit then table.remove(remaining, index) end
                        end
                    end
                end
            end
            -- Spell identity is optional when the typed confirmations cover
            -- every report. A known offscreen tick remains a competing source.
            if not best and #ordinary == 0 and #frameLines >= #group then
                for index, hit in ipairs(remaining) do
                    if not CompetingPeriodic(hit) then best = index break end
                end
            end
            if best then
                line.claimed = true
                Decide(table.remove(remaining, best), true, "tick", line)
            end
        end
    end
    -- Typed periodic lines are reserved for matching ticks, not counted as
    -- generic spell/proc confirmations when several damage kinds coincide.
    group, frameLines = remaining, ordinary
    if #group == 0 then return end
    local lines = #frameLines
    if lines >= #group then
        -- Lines of one kind say what each hit is; of several kinds, the
        -- engine sorts them out as before.
        local restrict = SharedRestrict(frameLines, lines)
        Claim(#group)
        for _, hit in ipairs(group) do
            if hit.record.event == "miss" then
                -- 0.3.50: a miss is decided a moment later, so the cast it
                -- answers is known: an instant Curse of Exhaustion's cast came
                -- after its Immune report in the same frame, and the miss took
                -- an older cast's icon (1.60.1.70374).
                ConfirmingEvidence(hit, frameLines, true)
                C_Timer.After(MISS_SETTLE, function() ns.DecideHit(hit, true, restrict) end)
            else
                Decide(hit, true, restrict)
            end
        end
    elseif lines == 0 then
        -- No line of yours in this frame. A hit that fits a bolt of
        -- yours in flight waits a moment for a spare line (DecideLate).
        -- Swings first, so a proc landing with a swing's hit finds it.
        local rest = {}
        for _, hit in ipairs(group) do
            local record = hit.record
            local swingLine, swing = SwingLine(hit)
            local orphan = not swingLine and OrphanSwingLine(hit)
            if swingLine then
                NoteSwingHit(hit, swingLine)
            end
            if not swingLine and not orphan then
                rest[#rest + 1] = hit
            elseif swingLine then
                -- Held on the hit's record for the Combat Feed (Bend 1).
                swingLine.claimed, swingLine.hit = true, { at = hit.at, record = record }

                ns.mine.pairedSwing = swing
                Decide(hit, true, LineRestrict(swingLine), swingLine)
            elseif orphan then
                orphan.claimed, orphan.hit = true, { at = hit.at, record = record }

                ns.mine.orphanSwing = true
                Decide(hit, true, LineRestrict(orphan), orphan)
            end
        end
        for _, hit in ipairs(rest) do
            local record = hit.record
            local procLine = ProcLine(hit)
            local dungeonCandidate
            if not procLine and record.school ~= ns.SCHOOL_PHYSICAL
                and UntargetedDirectInstance(hit) == "party" then
                dungeonCandidate = ns.mine:UntargetedDirectCandidate(
                    hit.key, record.school, hit.at, nil, true)
            end
            if procLine then
                procLine.claimed, procLine.hit = true, { at = hit.at, record = record }

                ns.mine.procSwing = true
                Decide(hit, true, LineRestrict(procLine), procLine)
            elseif not dungeonCandidate and record.event == "damage"
                and ns.mine:InFlight(hit.key, record.school, hit.at) then
                if settled then
                    -- Periodic matching already waited for this hit's line.
                    ns.DecideLate(hit)
                else
                    C_Timer.After(LATE_LINE, function() ns.DecideLate(hit) end)
                end
            elseif FlightProcLine(hit) then
                local flight = FlightProcLine(hit)
                flight.claimed, flight.hit = true, { at = hit.at, record = record }

                ns.mine.procSwing = true
                Decide(hit, true, LineRestrict(flight), flight)
            elseif #group == 1 and dungeonCandidate then
                if settled then
                    DecideDungeonDirect(hit)
                else
                    C_Timer.After(LATE_LINE, function() DecideDungeonDirect(hit) end)
                end
            elseif record.event == "miss" and ns.LineKindsActive and ns.LineKindsActive() then
                -- 0.3.49: a miss's report can come a frame after its line
                -- (DecideLateMiss).
                C_Timer.After(LATE_LINE, function() ns.DecideLateMiss(hit) end)
            elseif not DeferStraySwing(hit) then
                Decide(hit, false)
            end
        end
    else
        local restrict = SharedRestrict(frameLines, lines)
        Claim(lines)
        -- Fewer lines than hits (0.3.32, for raid bosses struck by many
        -- at once): the lines go to the hits that best fit something of
        -- yours (of the lines' kind, 0.3.48), the rest are someone else's.
        local ranked = {}
        for index, hit in ipairs(group) do
            local record = hit.record
            local kind = record.event == "miss" and "miss" or record.event
            local amount = ns.Number(record.amount) and record.amount or nil
            ranked[#ranked + 1] = { hit = hit, index = index,
                fit = ns.mine:Fit(hit.key, kind, record.school, hit.at,
                    amount, restrict, record.crit, record.avoid, hit.petOn) }
        end
        -- Observed on Forever: a queued strike reports zero before its
        -- physical hit in the cast's frame, with one spell confirmation.
        -- Both amounts are opaque and their school/flags are identical.
        -- Only this two-report pattern favors the later hit on a fit tie.
        local preferQueuedHit = PreferQueuedStrikeHit(group, lines, restrict)
        table.sort(ranked, function(a, b)
            if (a.fit ~= nil) ~= (b.fit ~= nil) then return a.fit ~= nil end
            if a.fit and b.fit and a.fit ~= b.fit then return a.fit < b.fit end
            if preferQueuedHit then return a.index > b.index end
            return a.index < b.index
        end)
        local flags = {}
        local cutoff = ranked[lines] and ranked[lines].fit
        local contested = not preferQueuedHit and cutoff ~= nil
            and ranked[lines + 1] and ranked[lines + 1].fit == cutoff
        for rank, entry in ipairs(ranked) do
            flags[entry.hit] = rank <= lines and entry.fit ~= nil
                and not (contested and entry.fit == cutoff)
        end
        -- The hits that tie for the lines no hit took (SettleTie): a cast's
        -- own frame gives no hit a fit. Any other hit the lines leave out
        -- may be a late swing's.
        local tie, named = {}, 0
        for _, entry in ipairs(ranked) do
            if flags[entry.hit] then
                named = named + 1
            elseif entry.fit == cutoff then
                tie[#tie + 1], entry.hit.tied = entry.hit, true
            end
        end
        if named < lines then SettleTie(tie, lines - named, Decide) end
        for _, hit in ipairs(group) do
            if not hit.unidentified and (flags[hit] or not DeferStraySwing(hit)) then
                Decide(hit, flags[hit], restrict)
            end
        end
    end
end

-- A bolt's line need not share its hit's frame (0.3.36, the user: "felt like
-- i was missing a lot of my shadowbolts"): in the recorded battlegrounds every
-- Shadow Bolt's line came 30 to 270 ms before its hit report, in another
-- frame, so every bolt had been taken for someone else's since 0.3.8. A hit
-- that fits a bolt of yours in flight takes the nearest spare line of yours
-- (one no hit of its own frame used) from EARLY_LINE before it to LATE_LINE
-- after it; each line serves once.
-- 0.3.48: with lines by kind, only a spell's hit or a shot's line (or one of
-- no known kind) can be a bolt's: a DoT tick of yours on another enemy no
-- longer serves as a teammate's bolt's.
local function BoltLine(line, record)
    if not Pairs(line, record) then return false end
    local restrict = LineRestrict(line)
    return line.kind == nil or restrict == "direct" or restrict == "shot"
end
-- 0.6.5 (predicted, not yet seen in client): a weapon strike (Sinister
-- Strike, Mortal Strike) may be reported as late after its line as a swing
-- is (0.45 s and more), so a physical hit looks back further.
local EARLY_STRIKE = 0.8
function ns.DecideLate(hit)
    local best, bestGap
    local early = hit.record.school == ns.SCHOOL_PHYSICAL and EARLY_STRIKE or EARLY_LINE
    for _, line in ipairs(reader.logLines or {}) do
        local gap = line.at - hit.at
        if not line.claimed and BoltLine(line, hit.record) and gap >= -early and gap <= LATE_LINE
            and (not bestGap or math.abs(gap) < bestGap) then
            best, bestGap = line, math.abs(gap)
        end
    end
    if not best and DeferStraySwing(hit) then return end
    if best then best.claimed = true end
    ConfirmingEvidence(hit, best)
    ns.DecideHit(hit, best ~= nil, best and LineRestrict(best) or nil)
end

-- 0.3.49: a miss of yours whose report came a frame after its line. Your
-- DoT ticks on a paladin under Divine Shield sent their miss lines about
-- 50 ms before the game's Immune reports, in the frame before, so each was
-- taken for someone else's (1.60.1.70374). Only a line coloured as a miss
-- serves, from EARLY_MISS before the report to LATE_LINE after it.
local EARLY_MISS = 0.12
function ns.DecideLateMiss(hit)
    local best, bestGap
    for _, line in ipairs(reader.logLines or {}) do
        local gap = line.at - hit.at
        if not line.claimed and line.kind and not MeleeLine(line) and Pairs(line, hit.record) and gap >= -EARLY_MISS
            and gap <= LATE_LINE
            and (not bestGap or math.abs(gap) < bestGap) then
            best, bestGap = line, math.abs(gap)
        end
    end
    if not best and DeferStraySwing(hit) then return end
    if best then best.claimed = true end
    ConfirmingEvidence(hit, best)
    ns.DecideHit(hit, best ~= nil, best and LineRestrict(best) or nil)
end

-- Your casts and swings -----------------------------------------------------------
local CAST_TARGET_KEEP, MAX_CAST_TARGETS = 30, 64

-- A unit's name as the game writes it in what it sends, from the two values
-- of UnitName. Forever gives a player a surname as the second value, where
-- other clients give the realm, and joins the two with its own separator.
-- Without a readable surname or separator the name comes back as it is.
local function WrittenName(name, surname)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    local separators = Constants and Constants.CharacterNameSeparatorConsts
    local separator = separators and separators.CHARACTERNAME_SURNAME_SEPARATOR
    if client and client.isForever and ns.Text(name) and ns.Text(surname) and ns.Text(separator) then
        return name .. separator .. surname
    end
    return name
end

local function RecipientKey(unit)
    local same = UnitIsUnit(unit, "target")
    if ns.Bool(same) and same then return ns.TargetKey() end
    for token in pairs(reader.plates) do
        same = UnitIsUnit(unit, token)
        if ns.Bool(same) and same then return PlateKey(token) end
    end
end

local function NamedRecipient(target)
    if type(UnitName) ~= "function" then return nil, true end
    local key, uncertain, unkeyed
    local candidates = {}
    local tokens = { "target", "focus", "mouseover" }
    for token in pairs(reader.plates) do tokens[#tokens + 1] = token end
    for _, token in ipairs(tokens) do
        local ok, name, realm = pcall(UnitName, token)
        if ok and ns.Text(name) and (target == name
            or (ns.Text(realm) and target == name .. "-" .. realm)
            or target == WrittenName(name, realm)) then
            local candidate = RecipientKey(token)
            if candidate then
                if key and key ~= candidate then uncertain = true end
                key, candidates[candidate] = candidate, true
            else
                uncertain, unkeyed = true, true
            end
        end
    end
    -- Several units with keys carry the name: a report of the cast's own
    -- frame may still show which one took it (SettleSharedName).
    if uncertain then return nil, true, not unkeyed and candidates or nil end
    return key, key == nil
end

-- A confirmed direct report can resolve a shared name when only one cast
-- could have produced it and no other candidate unit received a report.
SettleSharedName = function(hit, kind, restrict)
    local landed = hit.landed
    if not landed or hit.unidentified or (kind ~= "damage" and kind ~= "miss")
        or (restrict ~= nil and restrict ~= "direct") then return end

    local match
    for _, casts in pairs(ns.mine.casts) do
        for _, cast in ipairs(casts) do
            local candidates = cast.candidates
            local canReach = cast.key == hit.key or (candidates and candidates[hit.key])
                or (cast.targetUncertain and not candidates)
            if canReach and math.abs(cast.at - hit.at) <= SWING_FRAME
                and ns.mine:CanSettle(cast, hit.key, kind, hit.record.school, hit.at) then
                if match then return end
                match = cast
            end
        end
    end
    local candidates = match and match.candidates
    if not candidates then return end
    for key in pairs(candidates) do
        if key ~= hit.key and landed[key] then return end
    end
    ns.mine:Settle(match, hit.key)
end

local function NoteCastTarget(unit, target, guid, spell, now)
    if (unit ~= "player" and unit ~= "pet")
        or not ns.Number(spell, 1) then return end
    local key, uncertain, candidates
    if not ns.Public(target) then
        uncertain = true
    elseif ns.Text(target) then
        key, uncertain, candidates = NamedRecipient(target)
    elseif target == nil or target == "" then
        -- Older clients omit the recipient name. Keep the start snapshot;
        -- selecting another target before success must not move the cast.
        key = unit == "player" and ns.TargetKey()
            or (PetAttacking("target") and ns.TargetKey() or nil)
    else
        uncertain = true
    end
    local targets = reader.castTargets
    for index = #targets, 1, -1 do
        if now - targets[index].at > CAST_TARGET_KEEP then
            table.remove(targets, index)
        end
    end
    targets[#targets + 1] = { unit = unit, spell = spell, at = now,
        guid = ns.Text(guid) and guid or nil, key = key,
        uncertain = uncertain == true or not ns.Text(guid),
        candidates = candidates }
    while #targets > MAX_CAST_TARGETS do table.remove(targets, 1) end
end

local function CastTarget(unit, spell, guid, now, consume)
    local found, count
    count = 0
    for index, entry in ipairs(reader.castTargets) do
        if entry.unit == unit and entry.spell == spell
            and now >= entry.at and now - entry.at <= CAST_TARGET_KEEP then
            if ns.Text(guid) and entry.guid == guid then
                found, count = index, 1
                break
            elseif not ns.Text(guid) or not entry.guid then
                found, count = index, count + 1
            end
        end
    end
    if found then
        local entry = reader.castTargets[found]
        if consume then table.remove(reader.castTargets, found) end
        if entry.uncertain or count > 1 then
            -- A shared name's units pass on only when the cast's GUID pairs
            -- it with this send.
            return nil, true, true,
                ns.Text(guid) and entry.guid == guid and entry.candidates or nil
        end
        return entry.key, false, true
    end
    local recent = reader.lastCastTarget
    if not consume and recent and recent.unit == unit and recent.spell == spell
        and (not ns.Text(guid) or recent.guid == guid)
        and now - recent.at <= 0.05 then
        return recent.key, recent.uncertain, true
    end
end

local lastCast
local queuedStrike
local WINDFURY_TOTEM_ATTACK_SPELL_ID = 10610
local MAX_WINDFURY_CASTS = 16

local function FirstWindfuryCast(guid)
    if not ns.Text(guid) then return true end
    local recent = reader.windfuryCasts
    for _, seen in ipairs(recent) do
        if seen == guid then return false end
    end
    recent[#recent + 1] = guid
    if #recent > MAX_WINDFURY_CASTS then table.remove(recent, 1) end
    return true
end

local function WindfuryNotice(spell, now)
    if reader.windfuryNoticeAt
        and now <= reader.windfuryNoticeAt + SWING_FRAME then return end
    reader.windfuryNoticeAt = now

    local router = Router()
    if router then
        local fallbackSpell = spell == windfuryWeapon.procSpell
            and windfuryWeapon.iconSpell
        router:Alert({ kind = "proc",
            text = ns.SpellName(spell)
                or (fallbackSpell and ns.SpellName(fallbackSpell)) or "Windfury",
            icon = ns.SpellIcon(spell)
                or (fallbackSpell and ns.SpellIcon(fallbackSpell)) or nil })
    end
end

local function WindfuryTotemTriggerAt(at)
    for _, swing in ipairs(reader.swingTimes) do
        if swing.hand == "main" and not swing.strike
            and math.abs(swing.at - at) <= SWING_FRAME then return true end
    end
    local rules = ns.PlayerClassRules()
    local triggers = rules and rules.windfuryTotemTriggers
    if not triggers then return false end
    for spell in pairs(triggers) do
        for _, cast in ipairs(ns.mine.casts[spell] or {}) do
            if cast.caster == "you"
                and math.abs(cast.at - at) <= SWING_FRAME then return true end
        end
    end
    return false
end

local function WindfuryTriggerAt(at)
    for _, swing in ipairs(reader.swingTimes) do
        if not swing.ranged and math.abs(swing.at - at) <= SWING_FRAME then
            return true
        end
    end
    local rules = ns.PlayerClassRules()
    local spellReach = rules and rules.spellReach
    for spell, casts in pairs(ns.mine.casts) do
        local facts = ns.SpellFacts(spell)
        local knownReach = spellReach and spellReach[spell]
        if facts and facts.direct == true and facts.school == ns.SCHOOL_PHYSICAL
            and facts.helpful ~= true and not facts.weaponProc
            and (knownReach or ns.SpellReach(spell)) == "melee" then
            for _, cast in ipairs(casts) do
                if cast.caster == "you"
                    and math.abs(cast.at - at) <= SWING_FRAME then return true end
            end
        end
    end
    return false
end

local function WindfuryCooldown(spell)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not (client and client.isForever) or not ns.Number(spell, 1)
        or (spell ~= windfuryWeapon.procSpell
            and spell ~= WINDFURY_TOTEM_ATTACK_SPELL_ID) then return end
    local at = Now()
    local triggerAt = spell == WINDFURY_TOTEM_ATTACK_SPELL_ID
        and WindfuryTotemTriggerAt or WindfuryTriggerAt
    local pending = reader.windfuryCooldownFrames[spell]
    if pending and math.abs(pending.at - at) <= SWING_FRAME then return end
    pending = { at = at }
    reader.windfuryCooldownFrames[spell] = pending

    -- Recorded Forever frames expose this update beside the melee trigger
    -- and direct lines, without a cast event. Evaluate after all arrive.
    -- This correlation is an activity cue, not a hit identity or proc count.
    C_Timer.After(0, function()
        if reader.windfuryCooldownFrames[spell] ~= pending
            or not (ns.LineKindsReady and ns.LineKindsReady())
            or not triggerAt(at) then return end
        for _, line in ipairs(reader.logLines) do
            if line.source == "mine" and math.abs(line.at - at) <= SWING_FRAME
                and (line.kind == "spell" or line.kind == "spellMiss") then
                WindfuryNotice(spell, at)
                return
            end
        end
    end)
end

local function RememberExtraAttackCast(spell, guid, now, gear)
    if ns.Text(guid) then
        if reader.extraAttackGUIDs[spell] == guid then return end
        reader.extraAttackGUIDs[spell] = guid
    end
    local casts = reader.extraAttackCasts
    while casts[1] and now - casts[1].at > LOG_WAIT + LOG_PAIR do
        table.remove(casts, 1)
    end
    casts[#casts + 1] = { at = now, spell = spell, gear = gear }
end

local function OnCast(unit, spell, guid)
    if not ns.Number(spell, 1) then return end
    local now = Now()
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if unit == "player" and client and client.isForever then
        local gear = GearProcs and GearProcs.bySpell[spell]
        local rules = ns.PlayerClassRules()
        if gear or (rules and rules.extraAttackSpells and rules.extraAttackSpells[spell]) then
            if not gear or GearProcs.IsEquipped(gear) then
                RememberExtraAttackCast(spell, guid, now, gear)
            end
            return
        end
        if spell == windfuryWeapon.procSpell then
            if FirstWindfuryCast(guid) then
                -- Let the proc corroborate the burst without reserving a normal hit.
                if ns.windfuryInference then
                    ns.windfuryInference:Signal(now, spell)
                end
                WindfuryNotice(spell, now)
            end
            if ns.windfuryInference then return end
        end
    end
    local key, uncertain, observed, candidates =
        CastTarget(unit, spell, guid, now, true)
    if not observed and unit == "player" then
        key = ns.TargetKey()
    elseif not observed and unit == "pet" then
        -- Its target is hidden in battlegrounds; with its lines coming, a
        -- cast is taken to be at your target and its line decides (0.3.18).
        if PetAttacking("target") or (ns.mine.petLines and LinesRunning and LinesRunning()) then key = ns.TargetKey() end
    end
    if ns.NoteHealCast then ns.NoteHealCast(unit, spell, key, now, guid) end
    reader.lastCastTarget = { unit = unit, spell = spell, key = key,
        guid = ns.Text(guid) and guid or nil,
        uncertain = uncertain, at = now }
    if TracksOutcomes() then
        reader.lastCastTarget.observed = observed == true
    end
    ns.mine:Cast(unit, spell, key, now, uncertain)
    local facts = ns.SpellFacts and ns.SpellFacts(spell)
    if ns.windfuryInference and unit == "player" then
        local certain = observed == true and uncertain ~= true
        local conflict = spell ~= windfuryWeapon.triggerSpell
            and spell ~= windfuryWeapon.procSpell
            and (not facts or (facts.school == ns.SCHOOL_PHYSICAL
                and facts.damages ~= false))
        ns.windfuryInference:Cast({ at = now, key = certain and key or nil,
            spell = spell, guid = ns.Text(guid) and guid or nil,
            uncertain = not certain, conflict = conflict == true })
    end
    -- A cast sent to a name several units carry keeps their keys on its
    -- record, for its own report to settle (SettleSharedName).
    local recorded = candidates and ns.mine.casts[spell]
    recorded = recorded and recorded[#recorded]
    if recorded and recorded.at == now then recorded.candidates = candidates end
    -- Your pet's casts and your own with no target to hit (Life Tap) are
    -- written too (0.3.16).
    lastCast = { at = now, spell = spell, unit = unit }
    -- A queued strike of yours is kept apart from lastCast: a pet cast in the
    -- same frame must not hide that the next main-hand swing is the strike's.
    if unit == "player" and queuedStrikes[spell] then queuedStrike = { at = now, spell = spell } end
    if unit == "player" and facts and facts.weaponProc then
        reader.procSources[facts.weaponProc] = { spell = spell, at = now, kind = facts.weaponProc, school = facts.procSchool }
    end
    -- A health cost the game reports nowhere (Life Tap), from the spell's
    -- own description (0.3.19).
    if unit == "player" and facts and facts.healthCost then
        local router = Router()
        if router then
            router:In({ event = "damage", amount = facts.healthCost, icon = ns.SpellIcon(spell), name = ns.SpellName(spell) })
        end
    end
    if unit == "player" and ns.OnBuffCast then ns.OnBuffCast(spell) end
end

local SWING_HANDS
local function OnSwing(swingType, swingDuration)
    if not SWING_HANDS then
        SWING_HANDS = {}
        local kinds = Enum and Enum.PlayerSwingType
        if kinds then
            if kinds.MainHand then SWING_HANDS[kinds.MainHand] = "main" end
            if kinds.OffHand then SWING_HANDS[kinds.OffHand] = "off" end
            if kinds.Ranged then SWING_HANDS[kinds.Ranged] = "ranged" end
        end
    end
    if not ns.Number(swingType) then return end
    local hand = SWING_HANDS[swingType]
    if not hand then return end
    local times = reader.swingTimes
    local key = ns.TargetKey()
    if ns.windfuryInference then ns.windfuryInference:Swing(Now(), key, hand) end
    -- A queued strike (Raptor Strike) replaces the main hand's swing and sends
    -- it in its cast's frame on Forever; its hit is the strike's. Kept as a
    -- swing of yours, it took the pet's next blow in its window as your Auto
    -- Attack. Only that one swing is the strike's: an off-hand swing in the
    -- same frame is a real one.
    local strike
    if hand == "main" and queuedStrike and math.abs(queuedStrike.at - Now()) <= SWING_FRAME then
        strike, queuedStrike = true, nil
    end
    times[#times + 1] = { at = Now(), hand = hand, ranged = hand == "ranged",
        strike = strike, key = key, victim = CaptureVictim("target", key) }
    while times[1] and (Now() - times[1].at > 3 or #times > 16) do table.remove(times, 1) end
    if strike then return end
    local claimed = ns.mine:Swing(hand, key, Now(), ns.Number(swingDuration) and swingDuration or nil)
    if not claimed then return end
    for _, entry in ipairs(reader.held) do
        if entry.held == claimed then
            entry.record.result = { who = "you", melee = true, hand = hand, missed = entry.record.event == "miss" }
            if entry.record.accounting then
                entry.record.accounting.receipt = claimed.accountingReceipt
            end
            if ns.OnYourHit then
                ns.OnYourHit(entry.record, entry.at,
                    entry.confirmation or false, entry.sharedConfirmation)
            end
            local router = Router()
            if router then router:Out(entry.record) end
            return
        end
    end
end

-- Interrupts you land -----------------------------------------------------------------
local lastInterrupt = 0
local function OnInterrupted(unit, interruptedBy)
    if not ns.Text(unit) then return end
    if unit ~= "target" and unit ~= "focus" and not unit:match("^nameplate%d+$") then return end
    local now = Now()
    if now - lastInterrupt < 0.5 then return end
    -- The interrupter's GUID, when readable, settles it; else your or your
    -- pet's cast just before.
    local mine
    if ns.Text(interruptedBy) then
        local player, pet = UnitGUID("player"), UnitGUID("pet")
        mine = (ns.Text(player) and interruptedBy == player) or (ns.Text(pet) and interruptedBy == pet)
        if not mine then return end
    elseif ns.LineKindsReady and ns.LineKindsReady() and LinesRunning and LinesRunning() then
        -- 0.3.48: your interrupts come as combat log lines of their own
        -- colour, so the line settles it (KindAlert) and this only lends it
        -- the enemy's name; a teammate's interrupt sends none.
        local name = WrittenName(UnitName(unit))
        reader.interruptHeld = { at = now, name = ns.Text(name) and name or nil }
        return
    else
        mine = lastCast and now - lastCast.at <= 0.4
    end
    if not mine or not lastCast then return end
    lastInterrupt = now
    local name = WrittenName(UnitName(unit))
    local router = Router()
    if router then
        router:Alert({ kind = "interrupt", icon = ns.SpellIcon(lastCast.spell), text = INTERRUPTED or "Interrupted",
            sub = ns.Text(name) and name or nil })
    end
end

-- Crowd control on you --------------------------------------------------------------------
local function OnLossOfControl(unit, index)
    if unit ~= "player" or not ns.Number(index, 1) or not C_LossOfControl then return end
    local data = C_LossOfControl.GetActiveLossOfControlData(index)
    if type(data) ~= "table" or not ns.Public(data) then return end
    local text = ns.Text(data.displayText) and data.displayText or nil
    if not text then return end
    -- A kick locks a school: "Shadow Locked", as LossOfControlFrame.lua
    -- writes it (LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, C_Spell.GetSchoolString).
    if data.locType == "SCHOOL_INTERRUPT" and ns.Number(data.lockoutSchool, 1) and C_Spell and C_Spell.GetSchoolString then
        local school = C_Spell.GetSchoolString(data.lockoutSchool)
        if ns.Text(school) then
            local format = ns.Text(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL) and LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL or "%s Locked"
            text = string.format(format, school)
        end
    end
    local now = Now()
    local spell = ns.Number(data.spellID) and data.spellID or text
    if reader.lastCC[spell] and now - reader.lastCC[spell] < 0.3 then return end
    reader.lastCC[spell] = now
    local icon = ns.Number(data.iconTexture) and data.iconTexture or ns.SpellIcon(data.spellID)
    local router = Router()
    if router then router:Alert({ kind = "cc", icon = icon, text = text }) end
end

-- Procs and reactive abilities ------------------------------------------------------------
local function OnGlow(spell)
    if not ns.Number(spell, 1) then return end
    local now = Now()
    if reader.lastGlow[spell] and now - reader.lastGlow[spell] < 3 then return end
    reader.lastGlow[spell] = now
    reader.anyGlow = now
    local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spell)
    if not ns.Text(name) then return end
    local router = Router()
    if router then router:Alert({ kind = "proc", icon = ns.SpellIcon(spell), text = name }) end
end

-- Your own buffs and debuffs ------------------------------------------------------
-- 0.1.5 (the user: buffs and debuffs by their icon). Out of combat your own
-- UNIT_AURA payload is readable (AGENTS.md; unreadable in combat on
-- 1.60.1.70205): what was added comes with its name and icon, what was
-- removed by its instance, looked up in a cache of what you have. In combat
-- the combat text notice stands in, a moment later, unless a readable
-- payload or a recast of one of your buffs (below) already told it: its name
-- is secret and is drawn as text. 0.1.5 turned the secret name into an icon
-- with C_Spell.GetSpellTexture, documented SecretArguments AllowedWhenTainted,
-- but the client refused it ("bad argument #1", 1.60.1.70338, 13 October
-- 2026, laptop, in combat in The Barrens): no lookup takes a secret name.
local MAX_AURAS = 80
local function AuraEntry(aura)
    if type(aura) ~= "table" or not ns.Public(aura) then return nil end
    local id, harmful = aura.auraInstanceID, aura.isHarmful
    if not ns.Number(id) or not ns.Bool(harmful) then return nil end
    local icon, name, spell, expires = aura.icon, aura.name, aura.spellId, aura.expirationTime
    local entry = { icon = ns.Public(icon) and icon or nil, name = ns.Text(name) and name or nil, harmful = harmful,
        spell = ns.Number(spell, 1) and spell or nil, expires = ns.Number(expires) and expires or nil }
    -- Your buffs by spell, for a recast in combat (0.1.6).
    if entry.spell and not harmful and entry.icon then
        reader.buffSpells = reader.buffSpells or {}
        reader.buffSpells[entry.spell] = entry
    end
    return id, entry
end

-- Recasting a buff you have refreshes it: no aura is added (0.1.6; the
-- user: "when i rebuff myself with a spell i already have it should show the
-- icon again"). Out of combat an updated aura whose time left jumped by more
-- than two seconds is shown again. In combat, where the payload cannot be
-- read, a cast of a spell seen as one of your buffs, with an aura update for
-- you within half a second of it (either first), shows that buff's icon.
local REFRESH_GAIN, PAIR = 2, 0.5
local function ShowBuff(entry)
    local router = Router()
    if router then router:Aura(true, entry.harmful, entry.name, entry.icon, entry.spell) end
    reader.auraReadAt = Now()
end
local function Recast()
    local cast, update = reader.buffCast, reader.unreadAuraAt
    if not cast or not update or math.abs(cast.at - update) > PAIR then return end
    reader.buffCast = nil
    local entry = reader.buffSpells and reader.buffSpells[cast.spell]
    if entry then ShowBuff(entry) end
end

-- A change of your auras that could not be read may have taken a damage
-- shield off you and put another on, unseen by the cache: shield hits are
-- named again only after a scan reads all your buffs (a full update, or
-- the end of the fight), unless within half a second the change is
-- explained. The combat text's kind can be read, and its aura notices come
-- in the frame of the change, before or after it: when the notices from
-- that frame to the end of the half second are of a debuff only, no shield
-- was put on you. A damage shield you cast on yourself in the moment of the
-- change, before or after it in that frame, explains it, and is learned
-- until the next scan; a cast of another moment may be another change's.
local AURA_PAIR = 0.5
reader.auraChanges = {}
local function LearnShield(change, spell)
    change.explained = true
    reader.auras = reader.auras or {}
    reader.auras["cast" .. spell] = { spell = spell, learned = true }
end
local function SettleAuraChange(change)
    for index, waiting in ipairs(reader.auraChanges) do
        if waiting == change then
            table.remove(reader.auraChanges, index)
            if not (change.explained or (change.harmful and not change.helpful)) then reader.aurasUnsure = true end
            return
        end
    end
end
local function HiddenAuraChange()
    local change, cast, notice = { at = Now() }, reader.shieldCast, reader.auraNotice
    if cast and cast.at == change.at then LearnShield(change, cast.spell) end
    if notice and notice.at == change.at then change.harmful, change.helpful = notice.harmful, notice.helpful end
    reader.auraChanges[#reader.auraChanges + 1] = change
    C_Timer.After(AURA_PAIR, function() SettleAuraChange(change) end)
end

function ns.OnBuffCast(spell)
    local shield = MikSBT.DAMAGE_SHIELDS and MikSBT.DAMAGE_SHIELDS[spell]
    if not (shield or reader.buffSpells and reader.buffSpells[spell]) then return end
    -- Cast on a friend you target, it is theirs, not yours.
    local exists, assist, self = UnitExists("target"), UnitCanAssist("player", "target"), UnitIsUnit("target", "player")
    if ns.Bool(exists) and exists and ns.Bool(assist) and assist and not (ns.Bool(self) and self) then return end
    if shield then
        reader.shieldCast = { spell = spell, at = Now() }
        for _, change in ipairs(reader.auraChanges) do if change.at == Now() then LearnShield(change, spell) end end
    end
    if not (reader.buffSpells and reader.buffSpells[spell]) then return end
    reader.buffCast = { spell = spell, at = Now() }
    Recast()
end
-- Your own auras can be hidden out of combat too: in a battleground
-- GetAuraDataByIndex (RequiresUnitAuraAccess) errored "Auras cannot be
-- accessed when secret while tainted" right after a /reload (1.60.1.70374,
-- 14 October 2026, laptop, Darkspear Islands). C_Secrets says first whether
-- an aura would be secret (SecretPredicateAPIDocumentation); a hidden one is
-- skipped, and the combat text notices stand in for it as in combat.
local function AuraSecret(check, ...)
    if not C_Secrets then return false end
    -- Individual predicates do not establish general aura access.
    if C_Secrets.ShouldAurasBeSecret then
        local secret = C_Secrets.ShouldAurasBeSecret()
        if not ns.Bool(secret) or secret then return true end
    end
    if not C_Secrets[check] then return true end
    local secret = C_Secrets[check](...)
    return not ns.Bool(secret) or secret
end
ns.AuraSecret = AuraSecret
-- Only a scan that read every buff, its spell too, settles the changes that
-- could not be read; a debuff is no damage shield.
local function RebuildAuras()
    reader.auras = {}
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
    local hidden = false
    for _, filter in ipairs({ "HELPFUL", "HARMFUL" }) do
        local buffs = filter == "HELPFUL"
        for index = 1, 40 do
            if AuraSecret("ShouldUnitAuraIndexBeSecret", "player", index, filter) then hidden = hidden or buffs break end
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, filter)
            if not ns.Public(aura) then hidden = hidden or buffs break end
            if aura == nil then break end
            local id, entry = AuraEntry(aura)
            if id then reader.auras[id] = entry end
            if not (id and entry.spell) then hidden = hidden or buffs end
        end
    end
    reader.aurasUnsure = hidden or nil
    if not hidden then reader.auraChanges = {} end
end
local function RemovePlayerAuras(removed, router)
    if not ns.Public(removed) then
        reader.aurasUnsure = true
        return false
    end
    if type(removed) ~= "table" then return false end
    local any = false
    for _, id in ipairs(removed) do
        if not ns.Number(id) then
            reader.aurasUnsure = true
        else
            local entry = reader.auras[id]
            if entry then
                any = true
                reader.auras[id] = nil
                if entry.spell then reader.auras["cast" .. entry.spell] = nil end
                if router then router:Aura(false, entry.harmful, entry.name, entry.icon, entry.spell) end
            else
                -- A shield learned from a cast has no aura instance ID.
                for key, cached in pairs(reader.auras) do
                    if cached.learned then reader.auras[key] = nil end
                end
            end
        end
    end
    return any
end

local function OnPlayerAura(info)
    if type(info) ~= "table" or not ns.Public(info) then
        reader.unreadAuraAt = Now()
        HiddenAuraChange()
        Recast()
        return
    end
    reader.auras = reader.auras or {}
    local full = info.isFullUpdate
    if not ns.Bool(full) then
        -- A delta can still identify a removal when the full flag is hidden.
        -- A payload with no list at all may be a full update.
        local added, removed, updated = info.addedAuras, info.removedAuraInstanceIDs, info.updatedAuraInstanceIDs
        RemovePlayerAuras(removed)
        local other = not ns.Public(removed) or removed ~= nil or not ns.Public(updated) or updated ~= nil
        if not ns.Public(added) or added ~= nil or not other then HiddenAuraChange() end
        return
    end
    if full then RebuildAuras() return end
    local router = Router()
    local any = false
    local added, removed = info.addedAuras, info.removedAuraInstanceIDs
    local hidden = not ns.Public(added)
    if type(added) == "table" and ns.Public(added) then
        for _, aura in ipairs(added) do
            local id, entry = AuraEntry(aura)
            if id then
                any = true
                local count = 0
                for _ in pairs(reader.auras) do count = count + 1 end
                if count < MAX_AURAS then reader.auras[id] = entry end
                if router then router:Aura(true, entry.harmful, entry.name, entry.icon, entry.spell) end
                -- A buff whose spell is hidden may be a damage shield.
                if not (entry.spell or entry.harmful) then hidden = true end
            else
                hidden = true
            end
        end
    end
    if hidden then HiddenAuraChange() end
    local updated = info.updatedAuraInstanceIDs
    if type(updated) == "table" and ns.Public(updated) and C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID then
        for _, id in ipairs(updated) do
            local entry = ns.Number(id) and reader.auras[id]
            if entry and not AuraSecret("ShouldUnitAuraInstanceBeSecret", "player", id) then
                local aura = C_UnitAuras.GetAuraDataByAuraInstanceID("player", id)
                local expires = type(aura) == "table" and ns.Public(aura) and aura.expirationTime
                if ns.Number(expires) then
                    if entry.expires and expires > entry.expires + REFRESH_GAIN then
                        any = true
                        if router then router:Aura(true, entry.harmful, entry.name, entry.icon, entry.spell) end
                    end
                    entry.expires = expires
                end
            end
        end
    end
    if RemovePlayerAuras(removed, router) or any then reader.auraReadAt = Now() end
end

-- A spell of yours cast in the same frame as at, and its icon (0.3.19:
-- Life Tap's mana with Life Tap's icon). 0.3.30: the window was 0.4 s; in
-- the recorded battlegrounds Life Tap's mana notice and Demon Armor's buff
-- notice came in the very frame of their cast, 27 times of 27, so a
-- teammate's buff a moment later no longer takes your spell's icon.
local SAME_FRAME = 0.005
function ns.CastSpell(at)
    if lastCast and lastCast.unit == "player" and math.abs(lastCast.at - at) <= SAME_FRAME then return lastCast.spell end
end

-- Your wand's (or bow's, gun's) school, from its tooltip (0.3.21, the user:
-- "we want a fix for all wands not just fire wands"): the damage line,
-- "33 - 62 Fire Damage", or "41 - 77 Damage" for a physical one. English
-- clients only; elsewhere, and while the tooltip is not loaded, the engine
-- learns it from your first shots (Mine.lua). Read again whenever the
-- ranged slot changes (PLAYER_EQUIPMENT_CHANGED).
local SCHOOL_WORDS = { holy = 2, fire = 4, nature = 8, frost = 16, shadow = 32, arcane = 64 }
local RANGED_SLOT = INVSLOT_RANGED or 18
function ns.ReadWandSchool()
    if not (C_TooltipInfo and C_TooltipInfo.GetInventoryItem) then return nil end
    local data = C_TooltipInfo.GetInventoryItem("player", RANGED_SLOT)
    if type(data) ~= "table" or not ns.Public(data) or type(data.lines) ~= "table" then return nil end
    for index = 1, math.min(#data.lines, 30) do
        local line = data.lines[index]
        local text = type(line) == "table" and ns.Public(line) and line.leftText
        if ns.Text(text) then
            local lower = text:lower()
            local low, high, word = lower:match("^(%d+) %- (%d+) (%a+) damage$")
            if low and SCHOOL_WORDS[word] then return SCHOOL_WORDS[word] end
            if lower:match("^%d+ %- %d+ damage$") then return ns.SCHOOL_PHYSICAL end
        end
    end
    return nil
end
local function UpdateWand()
    if not ns.mine then return end
    ns.mine.wandSchool, ns.mine.wandVotes = ns.ReadWandSchool(), nil
    ns.mine.wandRead = ns.mine.wandSchool ~= nil
end
ns.UpdateWand = UpdateWand

local function OnCombatText(kind)
    if not ns.Text(kind) then return end
    -- The kind of an aura gained, for the changes that could not be read:
    -- those waiting, and one still to come in this frame.
    local gained = kind == "SPELL_AURA_START" and "helpful" or kind == "SPELL_AURA_START_HARMFUL" and "harmful"
    if gained then
        if not (reader.auraNotice and reader.auraNotice.at == Now()) then reader.auraNotice = { at = Now() } end
        reader.auraNotice[gained] = true
        for _, change in ipairs(reader.auraChanges) do change[gained] = true end
    end
    if not C_CombatText or not C_CombatText.GetCurrentEventInfo then return end
    local router = Router()
    if not router then return end
    if kind == "SPELL_AURA_START" or kind == "SPELL_AURA_START_HARMFUL" or kind == "SPELL_AURA_END"
        or kind == "SPELL_AURA_END_HARMFUL" then
        local name = C_CombatText.GetCurrentEventInfo()
        if ns.Public(name) and name == nil then return end
        local at = Now()
        C_Timer.After(0.15, function()
            if reader.auraReadAt and reader.auraReadAt >= at - 0.2 then return end
            local live = Router()
            if not live then return end
            -- A buff you gain right after casting a helpful spell of your own
            -- (Demon Armor) is that spell's, and takes its icon (0.3.29, the
            -- user: an aura "should have an icon as well as the text"): the
            -- notice's name is hidden in battlegrounds and in combat, and a
            -- hidden name cannot be turned into an icon, but the cast's spell
            -- can.
            local icon
            if kind == "SPELL_AURA_START" then
                local spell = ns.CastSpell(at)
                local helpful = spell and C_Spell and C_Spell.IsSpellHelpful and C_Spell.IsSpellHelpful(spell)
                if ns.Bool(helpful) and helpful then icon = ns.SpellIcon(spell) end
            end
            live:Aura(kind:find("START") ~= nil, kind:find("HARMFUL") ~= nil, name, icon)
        end)
    elseif kind == "HEAL" or kind == "HEAL_CRIT" or kind == "HEAL_ABSORB" or kind == "HEAL_CRIT_ABSORB"
        or kind == "PERIODIC_HEAL_ABSORB" then
        -- The first detail is the healer; the amount comes from UNIT_COMBAT.
        local name = C_CombatText.GetCurrentEventInfo()
        if kind == "PERIODIC_HEAL_ABSORB" then return end
        if ns.Public(name) and name == nil then return end
        -- Your own heals carry your name: a heal right after a cast of yours
        -- that is not harmful is yours (potions and bandages too).
        if lastCast and Now() - lastCast.at <= 0.6 and lastCast.unit == "player" then
            local harmful = C_Spell and C_Spell.IsSpellHarmful and C_Spell.IsSpellHarmful(lastCast.spell)
            if ns.Bool(harmful) and not harmful then return end
        end
        router:Healer(name)
    elseif kind == "ENERGIZE" or kind == "PERIODIC_ENERGIZE" then
        local amount, powerToken = C_CombatText.GetCurrentEventInfo()
        router:Resource(amount, powerToken, reader.comboTotals)
    elseif kind == "SPELL_ACTIVE" then
        if reader.anyGlow and Now() - reader.anyGlow < 0.5 then return end
        local name = C_CombatText.GetCurrentEventInfo()
        if ns.Public(name) and name == nil then return end
        router:Alert({ kind = "reactive", format = "<%s>", args = { name } })
    end
end

local function OnComboPoints(unit, token)
    if not reader.comboTotals or not ns.Text(unit) or unit ~= "player"
        or not ns.Text(token) or token ~= "COMBO_POINTS" then return end
    local power = Enum and Enum.PowerType and Enum.PowerType.ComboPoints or 4
    local ok, count = pcall(UnitPower, "player", power)
    local maxOK, maximum = pcall(UnitPowerMax, "player", power)
    if not ok or not maxOK then return end
    if ns.Public(count) and not ns.Number(count, 0) then return end
    if ns.Public(maximum) and not ns.Number(maximum, 1) then return end
    if ns.Number(count, 0) and ns.Number(maximum, 1) then
        if count == reader.comboCount and maximum == reader.comboMaximum then return end
        reader.comboCount, reader.comboMaximum = count, maximum
    else
        reader.comboCount, reader.comboMaximum = nil, nil
    end
    local router = Router()
    if router then router:ComboPoints(count, maximum) end
end

-- Combat-state notifications use MSBT's configured events.
local function OnCombat(entering)
    local router = Router()
    if router then router:Alert({ kind = "combat", entering = entering }) end
end

-- Blizzard's combat log lines --------------------------------------------------------------
-- The game sends COMBAT_LOG_MESSAGE (CombatLogSecureDocumentation, no
-- restriction) only while its combat log's filtered events are on, which
-- Blizzard_CombatLog turns on and off as its chat window shows and hides
-- (Mainline/Blizzard_CombatLog.lua). While the Combat log lane shows, the
-- addon keeps them on (C_CombatLog.SetFilteredEventsEnabled, a plain
-- argument) and checks every two seconds; when the lane goes it turns them
-- off again if it turned them on and Blizzard's window is not showing.
-- Which lines come is Blizzard's combat log filter, set in its chat tab.
-- Lines refilled into Blizzard's window (order Oldest) are not shown.
local logTicker, logEnabledByUs
local function LogWindowShown()
    local window = _G.COMBATLOG
    if type(window) ~= "table" or type(window.IsShown) ~= "function" then return false end
    local shown = window:IsShown()
    return ns.Bool(shown) and shown
end
local function KeepLog()
    if not (C_CombatLog and C_CombatLog.SetFilteredEventsEnabled and C_CombatLog.AreFilteredEventsEnabled) then return end
    local enabled = C_CombatLog.AreFilteredEventsEnabled()
    if ns.Bool(enabled) and not enabled then
        C_CombatLog.SetFilteredEventsEnabled(true)
        logEnabledByUs = true
    end
end
function ns.KeepCombatLog(on)
    if on then
        KeepLog()
        if not logTicker and C_Timer and C_Timer.NewTicker then logTicker = C_Timer.NewTicker(2, KeepLog) end
        return
    end
    if logTicker then logTicker:Cancel(); logTicker = nil end
    if logEnabledByUs and not LogWindowShown() and C_CombatLog and C_CombatLog.SetFilteredEventsEnabled then
        C_CombatLog.SetFilteredEventsEnabled(false)
    end
    logEnabledByUs = false
end
-- What a line's arrival tells -----------------------------------------------------
-- 0.3.0 (the user, 13 October 2026, allowing it: AGENTS.md's combat log
-- rule). A line is never read: only when it came, and its colour when the
-- game hands that over plainly. Blizzard's filter My actions sends only
-- what you and your pet did, and its default colours paint those lines
-- grey (COMBATLOG_DEFAULT_COLORS.unitColoring[COMBATLOG_FILTER_MINE], 0.70)
-- and a killing blow of yours white (PARTY_KILL is a highlightedEvent,
-- HighlightColor multiplies by 1.5, capped at 1; CombatLogUtil.lua). So:
--   a hit on your target or a plate that came in the same moment as a line
--   of yours, and that no cast or swing explained, was yours;
--   a white line, once grey ones have shown the colours are the default,
--   was your killing blow, with the icon of the hit that came with it;
--   a line takes the icon of the hit or cast of yours that came with it.
-- One line confirms one hit, and a hit already known to be yours takes its
-- line first, so a teammate's blow landing in the same moment stays theirs.
-- Worked out, not read: the settings page says so, and the in-client check
-- fct-log-timing measures it.
local LOG_KEEP = 2.5 -- 0.6.3: an enemy's blow on you came 1.5 s after its line
reader.logLines, reader.yourHits = {}, {}
-- Blizzard's combat log filter, from its own saved table (read only).
-- True when the filter sends your own damage: Blizzard's My actions, or
-- (0.3.20, the user: "we should have all of the settings on blizzard log and
-- then hide them on screen") any filter, edited or the player's own, with a
-- part whose sources include you and whose messages include your melee,
-- spell and DoT damage. Every line of yours is then sure to come, so a hit
-- without one is not yours; other players' lines are told apart by colour.
local DAMAGE_EVENTS = { "SWING_DAMAGE", "SPELL_DAMAGE", "SPELL_PERIODIC_DAMAGE" }
local function MyActionsFilter()
    local saved = _G.Blizzard_CombatLog_Filters
    if type(saved) ~= "table" or type(saved.filters) ~= "table" then return false end
    local current = saved.currentFilter
    if not ns.Number(current, 1) then return false end
    local filter = saved.filters[current]
    if type(filter) ~= "table" then return false end
    local name = filter.name
    if ns.Text(name) and ns.Text(QUICKBUTTON_NAME_MY_ACTIONS) and name == QUICKBUTTON_NAME_MY_ACTIONS then return true end
    if COMBATLOG_FILTER_MINE == nil or type(filter.filters) ~= "table" then return false end
    for _, part in ipairs(filter.filters) do
        local sources, events = type(part) == "table" and part.sourceFlags, type(part) == "table" and part.eventList
        if type(sources) == "table" and sources[COMBATLOG_FILTER_MINE] == true and type(events) == "table" then
            local all = true
            for _, event in ipairs(DAMAGE_EVENTS) do
                if events[event] ~= true then all = false break end
            end
            if all then return true end
        end
    end
    return false
end
ns.MyActionsFilter = MyActionsFilter

-- Whether that filter also sends your pet's lines (0.3.18): Blizzard's own
-- My actions sends only yours (its first part's sources are
-- COMBATLOG_FILTER_MINE), and in battlegrounds UnitIsUnit("pettarget",
-- "target") came back secret (1.60.1.70374, 14 October 2026), so without
-- them nothing tells your pet's hits from a teammate's. A player who adds
-- My pet to the filter's sources in Blizzard's combat log settings gets them.
local function PetLinesInFilter()
    if not MyActionsFilter() or COMBATLOG_FILTER_MY_PET == nil then return false end
    local saved = _G.Blizzard_CombatLog_Filters
    local filter = saved.filters[saved.currentFilter]
    if type(filter.filters) ~= "table" then return false end
    for _, part in ipairs(filter.filters) do
        local sources = type(part) == "table" and part.sourceFlags
        if type(sources) == "table" and sources[COMBATLOG_FILTER_MY_PET] == true then return true end
    end
    return false
end
ns.PetLinesInFilter = PetLinesInFilter

local function Near(value, target) return math.abs(value - target) <= 0.02 end
-- "mine" (grey), "kill" (white), "other" (any other colour) or "unknown"
-- (the colour was not handed over plainly), and the line's kind when its
-- colour says it.
-- 0.3.48 (the user, 14 October 2026: "do them as visible colours"): with Set
-- these for me, Blizzard's combat log colours each line by its event, a colour
-- for each kind (Setup.lua, KIND_COLOURS): your spell hit, DoT tick, swing,
-- shot, a miss of each, a heal, power, an interrupt, a dispel, crowd control
-- you broke, your killing blow. Read only from the colour, as before. Such a
-- line is yours while the filter's Done By is only you and your pet; with
-- others in it their lines would look the same, so none counts. A line of an
-- event the colours leave out comes in Blizzard's default 0.5 grey: it
-- cannot confirm damage while typed damage colours are active.
local function LineSource(r, g, b)
    local active, ours = false, false
    if ns.LineKindsActive then active, ours = ns.LineKindsActive() end
    if not (ns.Number(r, 0, 1) and ns.Number(g, 0, 1) and ns.Number(b, 0, 1)) then
        return "unknown", active and "other" or nil
    end
    if active then
        local kind = ns.LineKind and ns.LineKind(r, g, b)
        if kind == "kill" then return "kill", kind end
        if kind then return ours and "mine" or "other", kind end
        -- With typed damage colours active, an untyped line (for example a
        -- buff) is never a damage confirmation, even if its source is ours.
        if Near(r, 0.5) and Near(g, 0.5) and Near(b, 0.5) then return ours and "mine" or "other", "other" end
        -- Your death's line keeps your old grey whatever the colours
        -- (GenerateMessage returns the death recap link in it): no hit.
        if Near(r, 0.7) and Near(g, 0.7) and Near(b, 0.7) then return ours and "mine" or "other", "other" end
    end
    if Near(r, 0.7) and Near(g, 0.7) and Near(b, 0.7) then return "mine" end
    if r >= 0.99 and g >= 0.99 and b >= 0.99 then return "kill" end
    return "other"
end
ns.LineSource = LineSource

local function Prune(list, now)
    local keep = {}
    for _, entry in ipairs(list) do
        if now - entry.at <= LOG_KEEP then keep[#keep + 1] = entry end
    end
    return keep
end
local function FreeLine(at, window, record)
    for _, line in ipairs(reader.logLines) do
        local restrict, result = LineRestrict(line), record and record.result
        local fits = restrict == nil or result == nil or ((restrict == "tick") == (result.tick == true))
        if not line.hit and fits and not MeleeLine(line) and Pairs(line, record) and math.abs(line.at - at) <= (window or LOG_PAIR) then
            return line
        end
    end
end

-- How close a line comes to its own hit, measured (0.3.6). With your DoTs
-- ticking on several enemies, lines of yours come several times a second,
-- and within a tenth of a second of a teammate's hit far too often: such
-- hits were shown as yours with no icon. The gap between a line and a hit
-- the engine tied to one of your spells is sampled, and once there are
-- enough, confirming a hit or keeping a guessed school needs a line within
-- twice the middle gap (at least 4 ms, at most LOG_PAIR). If the game sends
-- both in the same moment, that is about one frame.
local SAMPLES, MIN_SAMPLES = 30, 8
reader.gaps = {}
local function SampleGap(record, gap)
    local result = record.result
    if not result or not result.spell or result.guess or result.logged then return end
    local gaps = reader.gaps
    gaps[#gaps + 1] = gap
    if #gaps > SAMPLES then table.remove(gaps, 1) end
    reader.pairWindow = nil
end
local function PairWindow()
    local gaps = reader.gaps
    if #gaps < MIN_SAMPLES then return LOG_PAIR end
    if reader.pairWindow then return reader.pairWindow end
    local sorted = {}
    for index, gap in ipairs(gaps) do sorted[index] = gap end
    table.sort(sorted)
    local middle = sorted[math.ceil(#sorted / 2)]
    reader.pairWindow = math.min(LOG_PAIR, math.max(0.004, middle * 2 + 0.004))
    return reader.pairWindow
end
ns.PairWindow = PairWindow
local function Close(hit)
    return (hit.line ~= nil or hit.confirmed == true)
        and hit.gap ~= nil and hit.gap <= PairWindow()
end

-- A ready Forever filter requires confirmation even before its first line.
-- A recent cast alone cannot establish that an enemy's damage report is ours.
function LinesRunning()
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    local ready = client and client.isForever
        and ns.LineKindsReady and ns.LineKindsReady()
    return MyActionsFilter() and (reader.sawGrey == true or ready)
end

-- Shared ownership supplies timing only when claimed lines share one time.
local function SharedConfirmationGap(lines, at)
    local confirmedAt
    for _, line in ipairs(lines) do
        if line.claimed then
            if confirmedAt and line.at ~= confirmedAt then return nil end
            confirmedAt = line.at
        end
    end
    return confirmedAt and math.abs(confirmedAt - at) or nil
end

-- A known hit reuses its confirmation instead of reserving another line.
-- Guessed schools use the original timing; omitted context keeps legacy pairing.
function ns.OnYourHit(record, at, confirmation, shared)
    local now = Now()
    reader.yourHits = Prune(reader.yourHits, now)
    local hit = { at = at, record = record,
        pairingResolved = confirmation ~= nil,
        confirmed = confirmation ~= nil and confirmation ~= false }
    reader.yourHits[#reader.yourHits + 1] = hit
    local line
    if confirmation and shared then
        hit.gap = SharedConfirmationGap(confirmation, at)
    elseif confirmation then
        line = confirmation
    elseif confirmation == nil then
        line = FreeLine(at, nil, record)
    end
    if line and (not line.hit or line.hit.record == record) then
        line.hit, hit.line, hit.gap = hit, line, math.abs(line.at - at)
    end
    if hit.gap and hit.gap <= LOG_PAIR then
        SampleGap(record, hit.gap)
    end
    local guess = record.result and record.result.guess
    local mine = ns.mine
    if not guess or not mine then return end
    C_Timer.After(LOG_WAIT, function()
        if Close(hit) then
            mine:Trust(guess)
        elseif guess.caster == "you" and LinesRunning() then
            mine:Doubt(guess)
        end
    end)
end

local function HitIcon(record)
    if not record then return nil end
    if record.icon then return record.icon end
    local result = record.result or {}
    if result.spell then return ns.SpellIcon(result.spell) end
    if result.melee and ns.MeleeIcon then return ns.MeleeIcon(result.hand) end
end
-- The killing blow's hit: the newest of yours up to half a second before.
local function KillIcon(line)
    local best
    for _, hit in ipairs(reader.yourHits) do
        if hit.at <= line.at + LOG_PAIR and line.at - hit.at <= 0.5 and (not best or hit.at >= best.at) then best = hit end
    end
    return best and HitIcon(best.record)
end

local KILL_VICTIM_WINDOW = 0.5
local function NearKillVictim(at, line)
    local gap = line.at - at
    return gap >= -LOG_PAIR and gap <= KILL_VICTIM_WINDOW
end

local function ResolveKillVictim(line)
    if line.victimResolved then return line.victimIsPlayer end
    line.victimResolved = true
    -- Nearby kills cannot safely share the same recent victim evidence.
    for _, other in ipairs(reader.logLines or {}) do
        if other ~= line and other.source == "kill"
            and math.abs(other.at - line.at) <= KILL_VICTIM_WINDOW then return end
    end
    local key, victim
    local function Add(candidateKey, candidate)
        if not candidateKey or (key and key ~= candidateKey) then return false end
        key = candidateKey
        if candidate then
            if victim and victim.isPlayer ~= candidate.isPlayer then return false end
            victim = candidate
        end
        return true
    end
    for _, hit in ipairs(reader.yourHits) do
        if hit.record.event == "damage"
            and NearKillVictim(hit.at, line) then
            if not Add(hit.record.victimKey, hit.record.victim) then return end
        end
    end
    for _, swing in ipairs(reader.swingTimes) do
        if not swing.ranged and NearKillVictim(swing.at, line) then
            local confirmed = false
            for _, swingLine in ipairs(reader.logLines or {}) do
                if math.abs(swingLine.at - swing.at) <= SWING_FRAME
                    and MeleeLine(swingLine) and LineClass(swingLine) == "damage"
                    and Role(swingLine) == "swing" then
                    confirmed = true
                    break
                end
            end
            if confirmed and not Add(swing.key, swing.victim) then return end
        end
    end
    if not victim then return end
    -- The kill line supplies the death; the hit supplies the victim's type.
    line.victimIsPlayer = victim.isPlayer
    return line.victimIsPlayer
end

-- What a line of its own kind tells (0.3.48): your or your pet's dispel, and
-- crowd control your hit broke. The game's event says what happened; which
-- spell did it is the cast or hit of yours in that moment.
local KIND_ALERTS = {
    purge = { kind = "dispel", text = "Purged" }, cleanse = { kind = "dispel", text = "Cleansed" },
    steal = { kind = "dispel", text = "Stolen" }, dispelFailed = { kind = "dispel", text = "Dispel failed" },
    broke = { kind = "broke", text = "Broke crowd control" },
}
ns.KIND_ALERTS = KIND_ALERTS
local CAST_BEFORE = 1.0 -- a dispel's or interrupt's line comes within this of its cast
local function CastIcon(at)
    if lastCast and lastCast.at <= at + LOG_PAIR and at - lastCast.at <= CAST_BEFORE then return ns.SpellIcon(lastCast.spell) end
end
local function TakeExtraAttackCast(at)
    for index, cast in ipairs(reader.extraAttackCasts) do
        if math.abs(cast.at - at) <= LOG_PAIR
            and (not cast.gear or GearProcs.IsEquipped(cast.gear)) then
            return table.remove(reader.extraAttackCasts, index)
        end
    end
end

local function KindAlert(router, line)
    if line.source == "mine" and line.kind == "extra" then
        local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
        if client and client.isForever then
            -- A nearby public cast can name one grant without reading the log text.
            local text = (MikSBT.translations or {}).MSG_EXTRA_ATTACK or "Extra attack"
            local cast = TakeExtraAttackCast(line.at)
            local icon
            if cast and cast.gear then
                text = GearProcs.Name(cast.gear)
                icon = ns.SpellIcon(cast.spell)
            elseif cast then
                local name = ns.SpellName(cast.spell)
                if name then text, icon = name, ns.SpellIcon(cast.spell) end
            end
            router:Alert({ kind = "extraAttack", text = text, icon = icon })
        end
        return
    end
    local alert = line.source == "mine" and KIND_ALERTS[line.kind]
    if line.source == "mine" and line.kind == "interrupt" then
        -- Shown once: by UNIT_SPELLCAST_INTERRUPTED when the interrupter
        -- could be read, else here, with the name it held for this line.
        local held = reader.interruptHeld
        if held and math.abs(held.at - line.at) > 0.3 then held = nil end
        if Now() - lastInterrupt < 0.5 and not held then return end
        reader.interruptHeld = nil
        lastInterrupt = Now()
        local record = { kind = "interrupt", icon = CastIcon(line.at), text = INTERRUPTED or "Interrupted",
            sub = held and held.name or nil }

        router:Alert(record)
        return
    end
    if not alert then return end
    local icon
    if alert.kind == "broke" then icon = KillIcon(line) end
    local record = { kind = alert.kind, icon = icon or CastIcon(line.at), text = alert.text }

    router:Alert(record)
end

local function DrawLine(line)
    local router = Router()
    if not router then return end
    local mine = MyActionsFilter()
    if line.source == "kill" and mine and reader.sawGrey
        and not line.killNotified then
        local record = { kind = "kill", icon = KillIcon(line), text = "Killing blow",
            victimIsPlayer = ResolveKillVictim(line) }

        line.killNotified = true
        router:Alert(record)
    end
    if line.kind and mine then KindAlert(router, line) end
end

-- 0.6.4 (the user, 19 October 2026, option B): a swing of yours that kills
-- sends its line and the kill line in the frame of the swing, and its hit is
-- never reported, the enemy being gone (9 of 10 kills, a hunter,
-- 1.60.1.70450, laptop; the tenth came because the corpse was targeted at
-- once). When that swing's line is still unpaired once its hit would have
-- come (Mine:MeleeWindow), the Auto Attack icon shows with "Killing blow"
-- in place of its number; if the hit does come, its number shows instead.
function ns.WatchKillingSwing(at, killingLine)
    for _, line in ipairs(reader.logLines or {}) do
        if math.abs(line.at - at) <= SWING_FRAME and MeleeLine(line) and LineClass(line) == "damage"
            and Role(line) == "swing" and not line.claimed and not line.hit then
            local _, late = ns.mine:MeleeWindow()
            C_Timer.After(late + 0.05, function()
                if line.claimed or line.hit then return end
                line.claimed = true
                local record = { event = "killed",
                    victimIsPlayer = killingLine and ResolveKillVictim(killingLine),
                    result = { who = "you", melee = true, hand = "main" } }
                line.hit = { at = Now(), record = record }

                local router = Router()
                if router and not (killingLine and killingLine.killNotified) then
                    if killingLine then killingLine.killNotified = true end
                    router:Out(record)
                end
            end)
            return
        end
    end
end

local function OnLogMessage(text, r, g, b, order)
    local oldest = Enum.CombatLogMessageOrder and Enum.CombatLogMessageOrder.Oldest
    if ns.Public(order) and oldest ~= nil and order == oldest then return end
    if ns.Public(text) and text == nil then return end
    local now = Now()
    local source, kind = LineSource(r, g, b)
    local line = { at = now, source = source, kind = kind,
        targetContext = ns.TargetKey() }
    if line.source == "mine" then reader.sawGrey = true end
    reader.logLines = Prune(reader.logLines, now)
    reader.logLines[#reader.logLines + 1] = line
    if ns.windfuryInference then
        ns.windfuryInference:Line(line.at, line.targetContext, source, kind)
    end
    if Pairs(line) and not MeleeLine(line) then
        for _, hit in ipairs(reader.yourHits) do
            if not hit.pairingResolved and not hit.line and Pairs(line, hit.record)
                and math.abs(hit.at - now) <= LOG_PAIR then
                line.hit, hit.line, hit.gap = hit, line, math.abs(hit.at - now)
                SampleGap(hit.record, hit.gap)
                break
            end
        end
    end
    if line.source == "kill" then C_Timer.After(0, function() ns.WatchKillingSwing(line.at, line) end) end
    C_Timer.After(LOG_WAIT, function() DrawLine(line) end)
end

-- Events -------------------------------------------------------------------------------------------------
local EVENTS = {
    "UNIT_COMBAT", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_INTERRUPTED", "PLAYER_SWING", "PLAYER_TARGET_CHANGED",
    "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "LOSS_OF_CONTROL_ADDED", "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW",
    "COMBAT_TEXT_UPDATE",
    "UNIT_SPELLCAST_SENT",
    "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
    "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "PLAYER_ENTERING_WORLD", "COMBAT_LOG_MESSAGE", "SPELL_TEXT_UPDATE",
    "PLAYER_EQUIPMENT_CHANGED",
}
ns.READER_EVENTS = EVENTS

local function OnEvent(_, event, ...)
    if event == "UNIT_COMBAT" then
        OnUnitCombat(...)
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        local spell = ...
        if ns.windfuryInference and ns.Number(spell, 1)
            and (spell == WINDFURY_TOTEM_ATTACK_SPELL_ID
                or (spell == windfuryWeapon.procSpell
                    and ActiveWindfurySpell(ns.SCHOOL_PHYSICAL))) then
            local target = spell == windfuryWeapon.procSpell and ns.TargetKey() or nil
            ns.windfuryInference:Signal(Now(), spell, target)
        end
        WindfuryCooldown(...)
    elseif event == "UNIT_SPELLCAST_SENT" then
        local unit, target, guid, spell = ...
        ns.NoteHealTarget(unit, target, guid, spell, Now())
        NoteCastTarget(unit, target, guid, spell, Now())
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, guid, spell = ...
        if ns.Text(unit) and (unit == "player" or unit == "pet") then
            OnCast(unit, spell, guid)
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit, guid, spell = ...
        if (unit == "player" or unit == "pet") and ns.Number(spell, 1) then
            local key, uncertain, observed =
                CastTarget(unit, spell, guid, Now(), false)
            if not observed then key = ns.TargetKey() end
            ns.mine:StartChannel(unit, spell, key, Now(), uncertain)
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unit, _, spell = ...
        if unit == "player" or unit == "pet" then
            ns.mine:StopChannel(unit, ns.Number(spell, 1) and spell or nil, Now())
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, _, _, interruptedBy = ...
        OnInterrupted(unit, interruptedBy)
    elseif event == "PLAYER_SWING" then
        local swingDuration, swingType = ...
        OnSwing(swingType, swingDuration)
    elseif event == "PLAYER_TARGET_CHANGED" then
        local exists = UnitExists("target")
        if ns.Bool(exists) and not exists then
            RememberDepartedTarget()
        else
            reader.targetKey = nil
            reader.departedTargetKey, reader.departedTargetAt = nil, nil
        end
        reader.epoch = reader.epoch + 1
        FindTargetPlate()
        ns.TargetKey()
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local token = ...
        if ns.Text(token) then
            reader.plateGeneration = reader.plateGeneration + 1
            reader.plates[token] = reader.plateGeneration
            local same = UnitIsUnit(token, "target")
            if ns.Bool(same) and same and reader.targetPlate ~= token then
                -- Casts made while your target had no plate follow it.
                RekeyTarget(reader.targetKey or ("target" .. reader.epoch),
                    PlateKey(token))
                reader.targetPlate = token
            end
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local token = ...
        if ns.Text(token) then
            local old = PlateKey(token)
            reader.plates[token] = nil
            -- A dying target can lose its plate before its final hit arrives.
            -- Preserve its lifetime through the selected/departed target.
            if token == reader.targetPlate then
                -- Keep the same lifetime for the still-selected or departed
                -- target. A later creature reusing this token gets a new key.
                reader.targetKey = reader.targetKey or old
            elseif old and old ~= DepartedTargetKey() then
                ns.mine:Forget(old)
                ns.ForgetHealing(old)
            end
            if reader.targetPlate == token then
                reader.targetPlate = nil
            end
        end
    elseif event == "LOSS_OF_CONTROL_ADDED" then
        OnLossOfControl(...)
    elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
        OnGlow(...)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = ...
        if ns.Number(slot) and slot == RANGED_SLOT then UpdateWand() end
        ReadShieldBlock()
        C_Timer.After(SHIELD_BLOCK_SETTLE, ReadShieldBlock)
    elseif event == "SPELL_TEXT_UPDATE" then
        local spell = ...
        if ns.Number(spell) then ns.ForgetSpellFacts(spell) end
    elseif event == "COMBAT_LOG_MESSAGE" then
        OnLogMessage(...)
    elseif event == "UNIT_AURA" then
        local unit, info = ...
        if unit == "player" then
            OnPlayerAura(info)
        end
    elseif event == "COMBAT_TEXT_UPDATE" then
        OnCombatText(...)
    elseif event == "UNIT_POWER_UPDATE" then
        OnComboPoints(...)
    elseif event == "PLAYER_REGEN_DISABLED" then
        OnCombat(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        OnCombat(false)
        ReadShieldBlock()
        -- Your auras are read again once the fight is over, a frame later.
        C_Timer.After(0, RebuildAuras)
    elseif event == "PLAYER_ENTERING_WORLD" then
        RebuildAuras()
        reader.windfuryCooldownFrames, reader.windfuryNoticeAt = {}, nil
        reader.windfuryCasts = {}
        reader.extraAttackCasts, reader.extraAttackGUIDs = {}, {}
        reader.plates, reader.targetPlate, reader.held = {}, nil, {}
        reader.castTargets, reader.lastCastTarget = {}, nil
        reader.pendingHits = setmetatable({}, { __mode = "k" })
        reader.unmatchedDamage = {}
        reader.targetKey = nil
        reader.departedTargetKey, reader.departedTargetAt = nil, nil
        reader.epoch = reader.epoch + 1
        ns.mine = ns.NewMine(ns.Learned, ns.Learn, ns.SpellFacts)
        ns.ResetHealing()
        UpdateWand()
        ReadShieldBlock()
        FindTargetPlate()
    end
end
ns.ReaderEvent = OnEvent

local initialReader = {}
for key, value in pairs(reader) do initialReader[key] = value end

local function ResetReader()
    if ns.ResetHealing then ns.ResetHealing() end
    local frame = reader.frame
    for key in pairs(reader) do reader[key] = nil end
    for key, value in pairs(initialReader) do
        reader[key] = type(value) == "table" and {} or value
    end
    reader.frame = frame
    -- Delayed groups retain their hits after frameHits has been drained.
    -- Weak keys let those live callbacks participate in target rekeying.
    reader.pendingHits = setmetatable({}, { __mode = "k" })
    lastCast, lastInterrupt, queuedStrike = nil, 0, nil
    beats = {}
end

function ns.StartReader()
    ResetReader()
    ReadShieldBlock()
    ns.mine = ns.NewMine(ns.Learned, ns.Learn, ns.SpellFacts)
    local frame = reader.frame or CreateFrame("Frame")
    -- Event availability differs between Retail and Classic clients.
    for _, event in ipairs(EVENTS) do
        if ns.EventAvailable(event) then
            frame:RegisterEvent(event)
        end
    end
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if client and client.isForever and C_EventUtils
        and type(C_EventUtils.IsEventValid) == "function" then
        local ok, supported = pcall(ns.EventAvailable, "SPELL_UPDATE_COOLDOWN")
        if ok and ns.Bool(supported) and supported then
            frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end
    end
    if ns.EventAvailable("UNIT_AURA") then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    end
    local presentation = MikSBT.Components.CombatPresentation
    reader.comboTotals = type(UnitPower) == "function"
        and type(UnitPowerMax) == "function"
        and ns.EventAvailable("UNIT_POWER_UPDATE")
        and presentation and presentation:CanTrackComboPoints() or false
    if reader.comboTotals then
        frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    end
    reader.auras = {}
    frame:SetScript("OnEvent", function(_, event, ...)
        ns.Dispatch(event, ...)
    end)
    reader.frame = frame
end

-- MSBT owns enable/disable and invalidates all delayed work in Context.lua.
function ns.StopReader()
    if reader.frame then
        reader.frame:UnregisterAllEvents()
        reader.frame:SetScript("OnEvent", nil)
    end
    ns.KeepCombatLog(false)
    ResetReader()
    ns.mine = nil
end
