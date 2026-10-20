-- Adapted from Forever Combat Text 0.6.8 (Tarolg, MIT).
-- See Combat/LICENSE-ForeverCombatText. MSBT uses its own presentation.
local ns = MikSBT.CombatEngine
local C_Timer = ns.Timer

-- Read hits, casts, swings, auras, and combat-log timing. MSBT owns
-- presentation and its dedicated loot, gain, and cooldown sources.

local reader = { epoch = 0, plates = {}, held = {}, lastGlow = {}, lastCC = {},
    swingTimes = {} }
ns.reader = reader

local function Now() return GetTime() end

-- Unit keys -----------------------------------------------------------------------
-- A unit is known by its nameplate token while it has one, so a DoT followed
-- on your target is still followed once you target something else; without a
-- plate, by "target" and how many times the target has changed.
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
    if not (ns.Bool(exists) and exists) then return nil end
    local self = UnitIsUnit("target", "player")
    if ns.Bool(self) and self then return nil end
    return reader.targetPlate or ("target" .. reader.epoch)
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
                entry.record.result = { who = "you", proc = true,
                    procSpell = ns.ProcSpell and ns.ProcSpell(entry.at, entry.record.school) }
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
    if event == "WOUND" then
        if ns.Number(amount) and amount == 0 then
            if flag == "ABSORB" or flag == "BLOCK" or flag == "RESIST" then
                return { event = "miss", missWord = ns.MissWord(flag), school = school }
            end
            return { event = "miss", missWord = ns.MissWord("MISS"), school = school }
        end
        return {
            event = "damage", amount = amount, school = school,
            crit = flag == "CRITICAL",
        }
    elseif event == "HEAL" then
        return { event = "heal", amount = amount, school = school, crit = flag == "CRITICAL" }
    elseif FEEDBACK[event] then
        return { event = "miss", missWord = ns.MissWord(event), school = school }
    end
end
ns.DescribeCombat = Describe

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
        if record.event == "heal" then
            -- A heal can arrive before its cast succeeds in the same frame.
            -- Resolve the spell before presentation copies the record.
            C_Timer.After(0, function()
                ns.TagIncomingHeal(record, unit, now)
                local live = Router()
                if live then live:In(record) end
            end)
        else
            router:In(record)
        end
        return
    end
    local key, token
    if unit == "target" then
        key, token = ns.TargetKey(), "target"
        if not key then return end
    elseif unit:match("^nameplate%d+$") then
        if not reader.plates[unit] or unit == reader.targetPlate then return end
        -- 0.6.3: your pet's own plate (a Succubus's): its hits come as
        -- "pet" too, and a miss on it had taken your swing's line.
        local pet = UnitIsUnit(unit, "pet")
        if ns.Bool(pet) and pet then return end
        key, token = unit, unit
        record.plate = unit
    else
        return
    end
    local hit = { record = record, key = key, at = now, unit = unit,
        petOn = PetAttacking(token) }
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
reader.procSources = {}
local function ProcSpell(at, school)
    local best
    for kind, source in pairs(reader.procSources) do
        local fresh = at - source.at <= (PROC_KEEP[kind] or 0)
        local fits = school == nil or source.school == nil or source.school == school
        if fresh and fits and (not best or source.at > best.at) then best = source end
    end
    return best and best.spell or nil
end
ns.ProcSpell = ProcSpell

function ns.DecideHit(hit, line, restrict)
    local router = Router()
    if not router then return end
    local record = hit.record
    local kind = record.event == "miss" and "miss" or record.event
    local leech = Leech(hit)
    local result
    if kind == "heal" then
        result = ns.MatchHealing(hit.key, hit.at, restrict == "tick", line)
            or { who = "other" }
    else
        result = ns.mine:Hit(hit.key, kind, record.school, hit.at, hit.petOn, line,
            ns.Number(record.amount) and record.amount or nil, record.crit, restrict, leech)
    end
    if result.proc and not result.drain and not result.spell then result.procSpell = ProcSpell(hit.at, record.school) end
    record.result = result
    if result.hold then
        local entry = { record = record, held = result.held, at = hit.at, line = line }
        reader.held[#reader.held + 1] = entry
        if #reader.held == 1 then C_Timer.After(ns.LATE_SWING + 0.02, FlushHeld) end
        return result, entry
    end
    if ns.OnYourHit and (result.who == "you" or result.who == "pet") then ns.OnYourHit(record, hit.at) end
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
-- How far a spare line of yours may be from a bolt's hit (ns.DecideLate).
local EARLY_LINE, LATE_LINE = 0.35, 0.12
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
        if not swing.ranged and math.abs(swing.at - at) <= SWING_FRAME then
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
        local frameLines, kinded = {}, false
        for _, line in ipairs(reader.logLines or {}) do
            if line.at == at and Pairs(line) and not line.claimed and not MeleeLine(line) then
                frameLines[#frameLines + 1] = line
                if line.kind then kinded = true end
            end
        end
        local decided = {}
        if not kinded then
            DecideGroup(group, frameLines, decided)
        else
            -- 0.3.48: lines coloured by kind serve only hits of their class
            -- (a heal or a miss of yours never makes a teammate's blow
            -- yours), damage first; a line of no known kind serves any.
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
                    DecideGroup(hitsOf, pool, decided)
                end
            end
        end
        MarkProcs(decided, SwingFrame(at, PROC_FLIGHT))
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
-- blow on you in the same frame), or one of no known kind.
local function SwingLine(hit)
    local record = hit.record
    if record.event ~= "damage" and record.event ~= "miss" then return nil end
    for _, swing in ipairs(ns.mine:SwingsBefore(hit.key, hit.at)) do
        for _, line in ipairs(reader.logLines or {}) do
            if not line.claimed and not line.hit and Pairs(line, record) and math.abs(line.at - swing.at) <= SWING_FRAME then
                if line.kind == nil and swing.hand ~= "ranged" then return line, swing end
                if MeleeLine(line) and Role(line) == "swing" then return line, swing end
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
            and gap >= math.max(early, ORPHAN_MIN) and gap <= late and Role(line) == "orphan" then
            return line
        end
    end
end

-- 0.6.5 (predicted, not yet seen in client): a proc riding on your swing (a
-- seal, a poison, Windfury's damage) reported late with the swing's hit,
-- its line back in the swing's frame like the swing's own. A hit with no
-- line in its frame, within a frame of a swing hit of yours just paired,
-- takes a spare line of its class that is no melee line from that swing's
-- frame.
reader.swingHits = {}
local function ProcLine(hit)
    local record = hit.record
    if record.event ~= "damage" and record.event ~= "miss" then return nil end
    for _, paired in ipairs(reader.swingHits) do
        if math.abs(paired.at - hit.at) <= 0.05 then
            for _, line in ipairs(reader.logLines or {}) do
                if not line.claimed and not line.hit and line.kind and not MeleeLine(line) and Pairs(line, record)
                    and math.abs(line.at - paired.lineAt) <= SWING_FRAME then
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
        if not line.claimed and not line.hit and line.kind and not MeleeLine(line) and Pairs(line, record)
            and gap >= 0 and gap <= 0.3 and SwingFrame(line.at, PROC_FLIGHT) then
            return line
        end
    end
end
local function NoteSwingHit(hit, line)
    local list = reader.swingHits
    list[#list + 1] = { at = hit.at, lineAt = line.at }
    while list[1] and (hit.at - list[1].at > 2 or #list > 16) do table.remove(list, 1) end
end

-- One frame's hits (of one class, with lines by kind) against the lines of
-- yours that may be theirs: as many lines as hits (or more: a DoT of yours
-- on an enemy without a plate also sends one) and every hit is yours; none
-- and none is; fewer, and the engine decides as it would without lines.
function DecideGroup(group, frameLines, decided)
    local lines = #frameLines
    local function Claim(count)
        for index = 1, math.min(count, #frameLines) do frameLines[index].claimed = true end
    end
    local function Decide(hit, flag, restrict)
        local result, entry = ns.DecideHit(hit, flag, flag == true and restrict or nil)
        decided[#decided + 1] = { result = result, entry = entry }
    end
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
                Decide(hit, true, LineRestrict(swingLine))
            elseif orphan then
                orphan.claimed, orphan.hit = true, { at = hit.at, record = record }

                ns.mine.orphanSwing = true
                Decide(hit, true, LineRestrict(orphan))
            end
        end
        for _, hit in ipairs(rest) do
            local record = hit.record
            local procLine = ProcLine(hit)
            if procLine then
                procLine.claimed, procLine.hit = true, { at = hit.at, record = record }

                ns.mine.procSwing = true
                Decide(hit, true, LineRestrict(procLine))
            elseif record.event == "damage" and ns.mine:InFlight(hit.key, record.school, hit.at) then
                C_Timer.After(LATE_LINE, function() ns.DecideLate(hit) end)
            elseif FlightProcLine(hit) then
                local flight = FlightProcLine(hit)
                flight.claimed, flight.hit = true, { at = hit.at, record = record }

                ns.mine.procSwing = true
                Decide(hit, true, LineRestrict(flight))
            elseif record.event == "miss" and ns.LineKindsActive and ns.LineKindsActive() then
                -- 0.3.49: a miss's report can come a frame after its line
                -- (DecideLateMiss).
                C_Timer.After(LATE_LINE, function() ns.DecideLateMiss(hit) end)
            else
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
                fit = ns.mine:Fit(hit.key, kind, record.school, hit.at, amount, restrict) }
        end
        table.sort(ranked, function(a, b)
            if (a.fit ~= nil) ~= (b.fit ~= nil) then return a.fit ~= nil end
            if a.fit and b.fit and a.fit ~= b.fit then return a.fit < b.fit end
            return a.index < b.index
        end)
        local flags = {}
        for rank, entry in ipairs(ranked) do flags[entry.hit] = rank <= lines and entry.fit ~= nil end
        for _, hit in ipairs(group) do Decide(hit, flags[hit], restrict) end
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
    if best then best.claimed = true end
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
    if best then best.claimed = true end
    ns.DecideHit(hit, best ~= nil, best and LineRestrict(best) or nil)
end

-- Your casts and swings -----------------------------------------------------------
local lastCast
local function OnCast(unit, spell)
    if not ns.Number(spell, 1) then return end
    local now = Now()
    local key
    if unit == "player" then
        key = ns.TargetKey()
    elseif unit == "pet" then
        -- Its target is hidden in battlegrounds; with its lines coming, a
        -- cast is taken to be at your target and its line decides (0.3.18).
        if PetAttacking("target") or (ns.mine.petLines and LinesRunning and LinesRunning()) then key = ns.TargetKey() end
    end
    if ns.NoteHealCast then ns.NoteHealCast(unit, spell, key, now) end
    ns.mine:Cast(unit, spell, key, now)
    local facts = ns.SpellFacts and ns.SpellFacts(spell)
    -- Your pet's casts and your own with no target to hit (Life Tap) are
    -- written too (0.3.16).
    lastCast = { at = now, spell = spell, unit = unit }
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
    times[#times + 1] = { at = Now(), ranged = hand == "ranged" }
    while times[1] and (Now() - times[1].at > 3 or #times > 16) do table.remove(times, 1) end
    local claimed = ns.mine:Swing(hand, ns.TargetKey(), Now(), ns.Number(swingDuration) and swingDuration or nil)
    if not claimed then return end
    for _, entry in ipairs(reader.held) do
        if entry.held == claimed then
            entry.record.result = { who = "you", melee = true, hand = hand, missed = entry.record.event == "miss" }
            if ns.OnYourHit then ns.OnYourHit(entry.record, entry.at) end
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
        local name = UnitName(unit)
        reader.interruptHeld = { at = now, name = ns.Text(name) and name or nil }
        return
    else
        mine = lastCast and now - lastCast.at <= 0.4
    end
    if not mine or not lastCast then return end
    lastInterrupt = now
    local name = UnitName(unit)
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
function ns.OnBuffCast(spell)
    if not (reader.buffSpells and reader.buffSpells[spell]) then return end
    -- Cast on a friend you target, it is theirs, not yours.
    local exists, assist, self = UnitExists("target"), UnitCanAssist("player", "target"), UnitIsUnit("target", "player")
    if ns.Bool(exists) and exists and ns.Bool(assist) and assist and not (ns.Bool(self) and self) then return end
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
    if not (C_Secrets and C_Secrets[check]) then return false end
    local secret = C_Secrets[check](...)
    return not ns.Bool(secret) or secret
end
ns.AuraSecret = AuraSecret
local function RebuildAuras()
    reader.auras = {}
    if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
    for _, filter in ipairs({ "HELPFUL", "HARMFUL" }) do
        for index = 1, 40 do
            if AuraSecret("ShouldUnitAuraIndexBeSecret", "player", index, filter) then break end
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, filter)
            if not ns.Public(aura) or aura == nil then break end
            local id, entry = AuraEntry(aura)
            if id then reader.auras[id] = entry end
        end
    end
end
local function OnPlayerAura(info)
    if type(info) ~= "table" or not ns.Public(info) then
        reader.unreadAuraAt = Now()
        Recast()
        return
    end
    local full = info.isFullUpdate
    if not ns.Bool(full) then return end
    reader.auras = reader.auras or {}
    if full then RebuildAuras() return end
    local router = Router()
    local any = false
    local added, removed = info.addedAuras, info.removedAuraInstanceIDs
    if type(added) == "table" and ns.Public(added) then
        for _, aura in ipairs(added) do
            local id, entry = AuraEntry(aura)
            if id then
                any = true
                local count = 0
                for _ in pairs(reader.auras) do count = count + 1 end
                if count < MAX_AURAS then reader.auras[id] = entry end
                if router then router:Aura(true, entry.harmful, entry.name, entry.icon, entry.spell) end
            end
        end
    end
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
    if type(removed) == "table" and ns.Public(removed) then
        for _, id in ipairs(removed) do
            local entry = ns.Number(id) and reader.auras[id]
            if entry then
                any = true
                reader.auras[id] = nil
                if router then router:Aura(false, entry.harmful, entry.name, entry.icon, entry.spell) end
            end
        end
    end
    if any then reader.auraReadAt = Now() end
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
    if not ns.Text(kind) or not C_CombatText or not C_CombatText.GetCurrentEventInfo then return end
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
    elseif kind == "SPELL_ACTIVE" then
        if reader.anyGlow and Now() - reader.anyGlow < 0.5 then return end
        local name = C_CombatText.GetCurrentEventInfo()
        if ns.Public(name) and name == nil then return end
        router:Alert({ kind = "reactive", format = "<%s>", args = { name } })
    end
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
local LOG_PAIR = 0.1  -- a line and a hit this close together may be one event
local LOG_WAIT = 0.15 -- a line waits this long for its hit before it is drawn
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
-- event the colours leave out comes in Blizzard's default 0.5 grey: yours,
-- kind unknown.
local function LineSource(r, g, b)
    if not (ns.Number(r, 0, 1) and ns.Number(g, 0, 1) and ns.Number(b, 0, 1)) then return "unknown" end
    local active, ours = false, false
    if ns.LineKindsActive then active, ours = ns.LineKindsActive() end
    if active then
        local kind = ns.LineKind and ns.LineKind(r, g, b)
        if kind == "kill" then return "kill", kind end
        if kind then return ours and "mine" or "other", kind end
        if Near(r, 0.5) and Near(g, 0.5) and Near(b, 0.5) then return ours and "mine" or "other" end
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
        if not line.hit and not MeleeLine(line) and Pairs(line, record) and math.abs(line.at - at) <= (window or LOG_PAIR) then
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
end
local function PairWindow()
    local gaps = reader.gaps
    if #gaps < MIN_SAMPLES then return LOG_PAIR end
    local sorted = {}
    for index, gap in ipairs(gaps) do sorted[index] = gap end
    table.sort(sorted)
    local middle = sorted[math.ceil(#sorted / 2)]
    return math.min(LOG_PAIR, math.max(0.004, middle * 2 + 0.004))
end
ns.PairWindow = PairWindow
local function Close(hit) return hit.line ~= nil and (hit.gap or 0) <= PairWindow() end

-- Whether lines of yours are coming: confirming is on, the filter is My
-- actions and grey lines have shown.
function LinesRunning()
    return MyActionsFilter() and reader.sawGrey == true
end

-- A hit known to be yours (or your pet's) takes the line that came with it.
-- When the engine read a spell's school off this hit (a guess, Mine.lua),
-- the line decides it: with one the school is kept, without one (while
-- lines of yours are coming) the hit was someone else's and the guess goes.
function ns.OnYourHit(record, at)
    local now = Now()
    reader.yourHits = Prune(reader.yourHits, now)
    local hit = { at = at, record = record }
    reader.yourHits[#reader.yourHits + 1] = hit
    local line = FreeLine(at, nil, record)
    if line then
        line.hit, hit.line, hit.gap = hit, line, math.abs(line.at - at)
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
local function KindAlert(router, line)
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
    if line.source == "kill" and mine and reader.sawGrey then
        local record = { kind = "kill", icon = KillIcon(line), text = "Killing blow" }

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
function ns.WatchKillingSwing(at)
    for _, line in ipairs(reader.logLines or {}) do
        if math.abs(line.at - at) <= SWING_FRAME and MeleeLine(line) and LineClass(line) == "damage"
            and Role(line) == "swing" and not line.claimed and not line.hit then
            local _, late = ns.mine:MeleeWindow()
            C_Timer.After(late + 0.05, function()
                if line.claimed or line.hit then return end
                line.claimed = true
                local record = { event = "killed", result = { who = "you", melee = true, hand = "main" } }
                line.hit = { at = Now(), record = record }

                local router = Router()
                if router then router:Out(record) end
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
    local line = { at = now, source = source, kind = kind }
    if line.source == "mine" then reader.sawGrey = true end
    reader.logLines = Prune(reader.logLines, now)
    reader.logLines[#reader.logLines + 1] = line
    if Pairs(line) and not MeleeLine(line) then
        for _, hit in ipairs(reader.yourHits) do
            if not hit.line and Pairs(line, hit.record) and math.abs(hit.at - now) <= LOG_PAIR then
                line.hit, hit.line, hit.gap = hit, line, math.abs(hit.at - now)
                SampleGap(hit.record, hit.gap)
                break
            end
        end
    end
    if line.source == "kill" then C_Timer.After(0, function() ns.WatchKillingSwing(line.at) end) end
    C_Timer.After(LOG_WAIT, function() DrawLine(line) end)
end

-- Events -------------------------------------------------------------------------------------------------
local EVENTS = {
    "UNIT_COMBAT", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_INTERRUPTED", "PLAYER_SWING", "PLAYER_TARGET_CHANGED",
    "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "LOSS_OF_CONTROL_ADDED", "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW",
    "COMBAT_TEXT_UPDATE",
    "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "PLAYER_ENTERING_WORLD", "COMBAT_LOG_MESSAGE", "SPELL_TEXT_UPDATE",
    "PLAYER_EQUIPMENT_CHANGED",
}
ns.READER_EVENTS = EVENTS

local function OnEvent(_, event, ...)
    if event == "UNIT_COMBAT" then
        OnUnitCombat(...)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spell = ...
        if unit == "player" or unit == "pet" then OnCast(unit, spell) end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, _, _, interruptedBy = ...
        OnInterrupted(unit, interruptedBy)
    elseif event == "PLAYER_SWING" then
        local swingDuration, swingType = ...
        OnSwing(swingType, swingDuration)
    elseif event == "PLAYER_TARGET_CHANGED" then
        reader.epoch = reader.epoch + 1
        FindTargetPlate()
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local token = ...
        if ns.Text(token) then
            reader.plates[token] = true
            local same = UnitIsUnit(token, "target")
            if ns.Bool(same) and same and reader.targetPlate ~= token then
                -- Casts made while your target had no plate follow it.
                ns.mine:Rekey("target" .. reader.epoch, token)
                ns.RekeyHealing("target" .. reader.epoch, token)
                reader.targetPlate = token
            end
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local token = ...
        if ns.Text(token) then
            reader.plates[token] = nil
            -- Your target's plate goes before the blow that killed it is
            -- reported (an Ice Lance that ended the fight showed nothing in
            -- 0.1.1, 13 October 2026): its casts carry on under "target".
            if token == reader.targetPlate then
                ns.mine:Rekey(token, "target" .. reader.epoch)
                ns.RekeyHealing(token, "target" .. reader.epoch)
            else
                ns.mine:Forget(token)
                ns.ForgetHealing(token)
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
    elseif event == "PLAYER_REGEN_DISABLED" then
        OnCombat(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        OnCombat(false)
    elseif event == "PLAYER_ENTERING_WORLD" then
        RebuildAuras()
        reader.plates, reader.targetPlate, reader.held = {}, nil, {}
        reader.epoch = reader.epoch + 1
        ns.mine = ns.NewMine(ns.Learned, ns.Learn, ns.SpellFacts)
        ns.ResetHealing()
        UpdateWand()
        FindTargetPlate()
    end
end
ns.ReaderEvent = OnEvent

local initialReader = {}
for key, value in pairs(reader) do initialReader[key] = value end

function ns.StartReader()
    if ns.ResetHealing then ns.ResetHealing() end
    local frame = reader.frame
    for key in pairs(reader) do reader[key] = nil end
    for key, value in pairs(initialReader) do
        reader[key] = type(value) == "table" and {} or value
    end
    reader.frame = frame
    lastCast, lastInterrupt = nil, 0
    beats = {}
    ns.mine = ns.NewMine(ns.Learned, ns.Learn, ns.SpellFacts)
    local frame = reader.frame or CreateFrame("Frame")
    -- Event availability differs between Retail and Classic clients.
    for _, event in ipairs(EVENTS) do
        if ns.EventAvailable(event) then
            frame:RegisterEvent(event)
        end
    end
    if ns.EventAvailable("UNIT_AURA") then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    end
    reader.auras = {}
    frame:SetScript("OnEvent", function(_, event, ...)
        ns.Dispatch(event, ...)
    end)
    reader.frame = frame
end

-- MSBT owns enable/disable and invalidates all delayed work in Context.lua.
function ns.StopReader()
    if reader.frame then reader.frame:UnregisterAllEvents() end
    ns.KeepCombatLog(false)
end
