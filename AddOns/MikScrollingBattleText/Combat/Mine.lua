-- Adapted from Forever Combat Text 0.6.8 (Tarolg, MIT).
-- See Combat/LICENSE-ForeverCombatText. MSBT uses its own presentation.
local ns = MikSBT.CombatEngine

-- Which hits are yours, worked out (AGENTS.md: inferring by public means is
-- wanted once proven in game; it is labelled "worked out" on the settings
-- page). The game reports a hit on a unit (UNIT_COMBAT: amount, school,
-- flags) but never who made it or with what, and the combat log is closed.
-- What it does tell, readably, is everything you and your pet do:
--   * your and your pet's casts, with the spell (UNIT_SPELLCAST_SUCCEEDED,
--     public for player and pet);
--   * each of your weapon swings, melee and ranged (PLAYER_SWING,
--     SwingTimerDocumentation, no secrecy rule).
-- So a hit on a unit is matched to them by time and school:
--   1. the next tick of a DoT of yours, on its rhythm;
--   2. the first hit after one of your casts of the hit's school, within a
--      few seconds (a bolt in flight), oldest first as bolts land in order;
--   3. the first tick of a spell that may tick: 1, 1.5, 2 or 3 seconds
--      after its cast, or as long after its first matched hit as that hit
--      came after the cast (a first tick taken for a hit);
--   4. the first hit after the newest cast whose school is still unknown;
--   5. a physical hit or a miss right after one of your swings;
--   6. a physical hit while your pet is attacking that unit, at most one a
--      second (a pet's swings are not reported);
--   7. otherwise someone else's: a teammate's, or a DoT whose cast was not
--      seen (a steady rhythm of one school still marks it as ticks).
-- What it learns about each spell is kept (Store.lua's learned cache): its
-- school; whether it hits at once, ticks, or both; and its tick interval.
-- A spell seen twice hitting at once with no tick after is not waited on
-- for ticks again, and one seen ticking with no hit at its cast is not
-- matched to the next hit after it, so a Corruption cast never takes a
-- Shadow Bolt's hit and a Shadow Bolt never reads as ticking.
-- A school read off one hit is a guess until it is trusted (0.3.3): in a
-- battleground a teammate's Frostbolt landing just after your first
-- Corruption taught "Corruption is Frost and never ticks", and every real
-- tick was then hidden as someone else's (1.60.1.70374, 14 October 2026).
-- A guess serves its own cast at once and is kept only when a combat log
-- line of yours came with the hit (Trust, from Reader.lua), or when three
-- casts agree; a hit that came without one while the log is running was not
-- yours (Doubt), and the guess is taken back. A DoT's school is kept once
-- two of its ticks land on time, and "hits at once, never ticks" only for a
-- spell whose school is kept.
-- What a spell's own description says (Spells.lua, 0.3.5) comes before any
-- of that: a spell that deals no damage (a curse, Fear, a buff) never takes a
-- hit, only a miss (resisted, immune); its school and whether it hits at
-- once, ticks or both are known from its first cast.
-- A swing reported just after its hit still claims it (the order of the two
-- events is not fixed): such hits are held a moment (Reader.lua).
-- Units are told apart by keys the reader gives; the engine never touches
-- the game, so the tests drive it directly.

-- A cast's first hit comes within this: bolts flew up to 2.37 s in the
-- recorded battlegrounds; 3 s leaves room for latency (0.3.31). A hit must
-- have your combat log line to be yours, so this only picks among your own
-- spells.
local DIRECT_WINDOW = 3.0
-- A spell that hits every enemy near lands in its cast's own frame: every
-- recorded Frost Nova, Arcane Explosion and Flamestrike hit at once did (0.3.42,
-- 1.60.1.70374). A little room for the cast's event coming a frame late.
local AREA_MOMENT = 0.2
-- How long a new spell's cast waits for a hit of its own before its DoT's
-- first tick may count: kept at 2.5 s, below Corruption's 3 s first tick.
local FIRST_HIT_WAIT = 2.5
local SWING_WINDOW = 0.5      -- a swing's hit comes within this
-- A wand's or bow's shot flies: its hit came 0.58 to 0.66 s after the shot
-- in a battleground (0.3.13, 1.60.1.70374). The longer window holds when
-- a line of yours came with the hit.
-- 0.3.34: two bolts landed 1.50 s after their shots in a battleground (long
-- range), just past the 1.5 s window, and were dropped; 2 s leaves room.
local RANGED_WINDOW, RANGED_UNSURE = 2.0, 1.5
local function SwingWindow(swing, line)
    if swing.hand ~= "ranged" then return SWING_WINDOW end
    return line == true and RANGED_WINDOW or RANGED_UNSURE
end
-- 0.6.1: a melee swing's hit report comes about 0.45 s after the swing and
-- its combat log line, which come in one frame (a hunter's 21 swings on a
-- boar: 0.446 to 0.453 s, 1.60.1.70450, 19 October 2026, laptop). A hit the
-- reader pairs with the line of a swing's own frame (SwingBefore, below)
-- may come this long after that swing, so a slower animation still fits.
-- Before any is learned, 0.25 to 0.9 s: no recorded swing's hit came sooner
-- than 0.44 s, and a two-hander's slower animation may come later (0.6.2,
-- not yet seen in client). Once three of your swings' hits are paired, the
-- window closes round their middle delay (SWING_EARLY before, SWING_LATE
-- after), so a teammate's blow landing just after your swing does not take
-- your swing's line before your own hit comes.
local SWING_MIN, SWING_LINED = 0.25, 0.9
-- 0.6.5: tighter, from the spread seen (each recorded hit within 0.04 s of
-- its hand's middle delay: 0.417 to 0.473 s, 0.661 to 0.741 s).
local SWING_EARLY, SWING_LATE = 0.10, 0.15
local LAG_SAMPLES = 9
-- 0.6.6: a swing's hit is sometimes held back one more animation: a rogue's
-- came 0.98 to 1.01 s after the swing instead of 0.49 s, 27 of 180 times,
-- 22 of them with a Sinister Strike between the swing and its hit (and up to
-- 1.31 s; 1.60.1.70450, 19 October 2026, laptop). So a swing may also take
-- a hit DELAYED_FROM to DELAYED_TO after its usual delay. Hits in that
-- window do not teach the delay.
local DELAYED_FROM, DELAYED_TO = 0.25, 0.9
local USUAL_DELAY = 0.45 -- before one is learned
local function PairedWindow(swing)
    return swing.hand == "ranged" and RANGED_WINDOW or 2.0
end
local LATE_SWING = 0.35       -- a swing may follow its hit by this much
-- A tick may be this early or late. Recorded in battlegrounds (0.3.15,
-- 1.60.1.70374): Corruption's ticks 3.00 s and 6.00 s after its cast within
-- 0.03 s, Agony's 2.00 s and 4.00 s within 0.02 s; at 0.45 an Agony tick
-- 1.5 s after a Corruption was taken as its first tick.
local TICK_SLACK = 0.15
local FIRST_TICKS = { 1, 1.5, 2, 3 }
local FIRST_WAIT = 3.6        -- a possible DoT with no tick by then is dropped
local PET_GAP = 1.0           -- a pet swings at most this often
local RHYTHM_SLACK = 0.15
local VOTES = 3               -- casts that must agree on an untrusted school
local MAX = 32                -- of each list
ns.LATE_SWING = LATE_SWING

-- learned "direct": what a spell does.
local DIRECT_ONLY, TICKS_ONLY, BOTH = 1, 2, 3
ns.SPELL_KINDS = { directOnly = DIRECT_ONLY, ticksOnly = TICKS_ONLY, both = BOTH }

local PHYSICAL = 1
ns.SCHOOL_PHYSICAL = PHYSICAL

local Mine = {}
Mine.__index = Mine

-- 0.6.5: learned per hand ("main", "off"; a dual wielder's two weapons
-- swing at different speeds and may land after different delays, and one
-- shared speed would have dropped what was learned at every other swing).
function Mine:SwingDelay(hand)
    local lags = self.swingLags and self.swingLags[hand or "main"]
    if not lags or #lags < 3 then return nil end
    local sorted = {}
    for index, lag in ipairs(lags) do sorted[index] = lag end
    table.sort(sorted)
    return sorted[math.floor((#sorted + 1) / 2)]
end
-- The delays a melee hit with a swing's line may come after it: for a hand,
-- or with no hand (an extra attack, a killing swing) any hand's.
function Mine:MeleeWindow(hand)
    if hand then
        local lag = self:SwingDelay(hand)
        if not lag then return SWING_MIN, SWING_LINED end
        return math.max(0.05, lag - SWING_EARLY), lag + SWING_LATE
    end
    local early, late
    for _, each in ipairs({ "main", "off" }) do
        local lag = self:SwingDelay(each)
        if lag then
            early = math.min(early or 99, math.max(0.05, lag - SWING_EARLY))
            late = math.max(late or 0, lag + SWING_LATE)
        end
    end
    if not early then return SWING_MIN, SWING_LINED end
    return early, late
end

-- learned(field, id) and learn(field, id, value): the saved cache (Store.lua);
-- facts(id): what the spell's description says (Spells.lua), or nil.
function ns.NewMine(learned, learn, facts)
    return setmetatable({ pending = {}, dots = {}, swings = {}, held = {}, rhythm = {}, petLast = {}, evidence = {}, votes = {},
        casts = {}, amounts = {},
        learned = learned or function() end, learn = learn or function() end, facts = facts or function() end }, Mine)
end

local function Prune(list, keep)
    for index = #list, 1, -1 do
        if not keep(list[index]) then table.remove(list, index) end
    end
    while #list > MAX do table.remove(list, 1) end
end

function Mine:Tidy(now)
    Prune(self.pending, function(entry) return not entry.used and now - entry.at <= DIRECT_WINDOW end)
    Prune(self.swings, function(entry) return not entry.used and now - entry.at <= PairedWindow(entry) end)
    Prune(self.held, function(entry) return not entry.claimed and now - entry.at <= LATE_SWING end)
    Prune(self.dots, function(dot)
        if dot.period then
            -- A tick that did not come (out of sight, a wrong interval kept
            -- from earlier fights): the next is expected an interval later,
            -- up to three times (0.3.9: Corruption kept as 1.5 s was dropped
            -- at 2 s and its real tick at 3 s matched nothing).
            while now > dot.next + TICK_SLACK and (dot.skipped or 0) < 3 do
                dot.next, dot.skipped = dot.next + dot.period, (dot.skipped or 0) + 1
            end
            return now <= dot.next + TICK_SLACK + 0.3
        end
        if now - dot.castAt <= FIRST_WAIT then return true end
        -- Still waiting to re-time a first tick taken for a hit, or to
        -- confirm a first tick.
        if dot.directAt and now - dot.directAt <= FIRST_WAIT then return true end
        if dot.candidate and now <= dot.candidate.at + dot.candidate.period + TICK_SLACK then return true end
        -- It hit at once and never ticked: twice so, and it is a direct spell.
        if dot.direct and self.learned("period", dot.spell) == nil and self.learned("school", dot.spell) ~= nil then
            local seen = (self.evidence[dot.spell] or 0) + 1
            self.evidence[dot.spell] = seen
            if seen >= 2 then self.learn("direct", dot.spell, DIRECT_ONLY) end
        end
        return false
    end)
end

local function SchoolFits(known, school)
    return known == nil or school == nil or known == school
end

local function LearnSchool(self, spell, school)
    if not school or not spell then return end
    self.learn("school", spell, school)
    for _, dot in ipairs(self.dots) do
        if dot.spell == spell and not dot.school then dot.school = school end
    end
    for _, entry in ipairs(self.pending) do
        if entry.spell == spell and not entry.school then entry.school = school end
    end
end

-- A school read off the first hit after a cast of a spell whose school is
-- not kept: used for this cast at once, kept once VOTES casts agree with
-- nothing against them, or once trusted. Returns the guess, or nil when
-- it is kept already.
-- Another DoT of yours on that unit, of a school the hit fits, could as well
-- have made it: then the hit proves nothing about this spell's school.
local function Explained(self, entry, school)
    for _, dot in ipairs(self.dots) do
        if dot ~= entry.dot and dot.key == entry.key and SchoolFits(dot.school, school) then return true end
    end
    return false
end

local function Guess(self, entry, school)
    local spell = entry.spell
    entry.school = school
    if entry.dot and not entry.dot.school then entry.dot.school = school end
    if Explained(self, entry, school) then return { spell = spell, school = school, caster = entry.caster, entry = entry, unsure = true } end
    local votes = self.votes[spell] or {}
    self.votes[spell] = votes
    votes[school] = (votes[school] or 0) + 1
    local against = 0
    for other, count in pairs(votes) do if other ~= school then against = against + count end end
    if votes[school] >= VOTES and against == 0 then
        LearnSchool(self, spell, school)
        return nil
    end
    return { spell = spell, school = school, caster = entry.caster, entry = entry }
end

-- A combat log line of yours came with the guessed hit: keep the school.
function Mine:Trust(guess)
    if not guess or guess.done then return end
    guess.done = true
    if guess.unsure then return end
    LearnSchool(self, guess.spell, guess.school)
end

-- No line came with it while the log runs: someone else's hit. The cast
-- forgets the school and is no longer taken to have hit at once.
function Mine:Doubt(guess)
    if not guess or guess.done then return end
    guess.done = true
    local votes = self.votes[guess.spell]
    if votes and votes[guess.school] and not guess.unsure then votes[guess.school] = votes[guess.school] - 1 end
    local entry = guess.entry
    if entry.school == guess.school then entry.school = nil end
    local dot = entry.dot
    if dot and dot.school == guess.school and dot.ticks == 0 then
        dot.school, dot.direct, dot.directAt = nil, nil, nil
    end
end

-- A cast of yours or your pet's on the unit keyed key (nil: no unit to
-- match against).
function Mine:Cast(caster, spell, key, now)
    if type(spell) ~= "number" then return end
    caster = caster == "pet" and "pet" or "you"
    local facts = self.facts(spell)
    -- With no unit, only a spell of yours whose description says it deals
    -- damage counts (opening a chest is a cast with no target too).
    if not key and (caster ~= "you" or type(facts) ~= "table" or facts.damages ~= true) then return end
    self:Tidy(now)
    local school, kind, period = self.learned("school", spell), self.learned("direct", spell), self.learned("period", spell)
    -- The last few casts of each spell (0.3.11: a fresh Agony on one enemy
    -- hid the one still ticking on another).
    local list = self.casts[spell] or {}
    self.casts[spell] = list
    list[#list + 1] = { at = now, caster = caster }
    while #list > 6 or (list[1] and now - list[1].at > 30) do table.remove(list, 1) end
    -- 0.3.42: a cast of yours with nothing targeted (an Arcane Explosion)
    -- has no unit to wait on, but stays in that list, so a hit or resist
    -- of yours on any enemy in its moment is its (Likeliest, and a miss in
    -- Hit); it had been forgotten, and its hits shown as someone else's
    -- or its resist with an earlier wand shot's icon (1.60.1.70374).
    if not key then return end
    if type(facts) == "table" then
        if facts.damages == false then
            -- No damage at all: only a resist or immune can be its. 0.3.50:
            -- none at all for a spell cast on yourself (Life Tap).
            if facts.healthCost ~= nil or facts.helpful == true then return end
            self.pending[#self.pending + 1] = { caster = caster, spell = spell, key = key, at = now, missOnly = true }
            while #self.pending > MAX do table.remove(self.pending, 1) end
            return
        end
        -- The description wins over anything learned from hits (0.3.6: a
        -- Curse of Agony learned as Physical from a pet's swings).
        school = facts.school or school
        if facts.direct ~= nil then
            kind = (facts.direct and facts.ticks and BOTH) or (facts.ticks and TICKS_ONLY) or (facts.direct and DIRECT_ONLY) or kind
        end
    end
    -- A recast refreshes its DoT: the ticks start again from now.
    for index = #self.dots, 1, -1 do
        local dot = self.dots[index]
        if dot.spell == spell and dot.key == key then table.remove(self.dots, index) end
    end
    local dot
    if kind ~= DIRECT_ONLY or period then
        dot = { caster = caster, spell = spell, key = key, castAt = now, school = school, period = period,
            next = period and (now + period) or nil, ticks = 0, known = period ~= nil }
        self.dots[#self.dots + 1] = dot
    end
    if kind ~= TICKS_ONLY then
        local entry = { caster = caster, spell = spell, key = key, at = now, school = school, dot = dot }
        self.pending[#self.pending + 1] = entry
        if dot then dot.pending = entry end
    end
    while #self.pending > MAX do table.remove(self.pending, 1) end
    while #self.dots > MAX do table.remove(self.dots, 1) end
end

-- One of your swings (hand: "main", "off" or "ranged"). Returns a held hit
-- it claims, if one came just before it.
function Mine:Swing(hand, key, now, duration)
    self:Tidy(now)
    -- 0.6.2: another weapon (or a big change of attack speed) may swing with
    -- another delay to its hit: what was learned is dropped.
    if hand ~= "ranged" and type(duration) == "number" then
        self.swingSpeed, self.swingLags = self.swingSpeed or {}, self.swingLags or {}
        local speed = self.swingSpeed[hand]
        if speed and math.abs(duration - speed) > 0.3 then self.swingLags[hand] = nil end
        self.swingSpeed[hand] = duration
    end
    for _, hit in ipairs(self.held) do
        -- A ranged shot flies, so it never claims a hit from before it (0.3.13).
        if hand ~= "ranged" and not hit.claimed and hit.key == key and (hit.kind == "miss" or SchoolFits(PHYSICAL, hit.school)) then
            hit.claimed = true
            return hit
        end
    end
    if key then self.swings[#self.swings + 1] = { hand = hand, key = key, at = now } end
end

-- 0.6.1: the swings of yours on this unit a hit reported now may be from,
-- not yet used, oldest first: melee 0.05 to SWING_LINED before it, a shot up
-- to RANGED_WINDOW before it. Nothing is changed; the reader looks for the
-- line that came with one (Reader.lua, SwingLine) and hands it back as
-- self.pairedSwing for the hit's decision.
function Mine:SwingsBefore(key, now)
    local found = {}
    if not key then return found end
    for _, swing in ipairs(self.swings) do
        local since = now - swing.at
        local fits
        if swing.hand == "ranged" then
            fits = since >= 0.05 and since <= RANGED_WINDOW
        else
            local early, late = self:MeleeWindow(swing.hand)
            local lag = self:SwingDelay(swing.hand) or USUAL_DELAY
            fits = (since >= early and since <= late) or (since >= lag + DELAYED_FROM and since <= lag + DELAYED_TO)
        end
        if not swing.used and swing.key == key and fits then found[#found + 1] = swing end
    end
    return found
end

-- A unit known by another key now: your target's nameplate went (a dying
-- enemy's plate goes before the report of the blow that killed it) or came.
function Mine:Rekey(old, new)
    if not old or not new or old == new then return end
    for _, list in ipairs({ self.pending, self.dots, self.swings, self.held }) do
        for _, entry in ipairs(list) do
            if entry.key == old then entry.key = new end
        end
    end
    self.rhythm[new], self.rhythm[old] = self.rhythm[old], nil
    self.petLast[new], self.petLast[old] = self.petLast[old], nil
end

-- Forget a unit (its nameplate went).
-- A DoT with a known rhythm is not forgotten with its plate (0.3.9): it is
-- kept unkeyed (key false) while it would still tick, and a tick of yours on
-- another plate in its moment takes it back (Adopt). An enemy that leaves
-- sight comes back with a new plate token, and battlegrounds hide who it is.
-- Returns how many casts, DoTs, swings and held hits it touched.
function Mine:Forget(key)
    local touched = 0
    for _, list in ipairs({ self.pending, self.dots, self.swings, self.held }) do
        for index = #list, 1, -1 do
            local entry = list[index]
            if entry.key == key then
                touched = touched + 1
                if list == self.dots and entry.period then entry.key = false else table.remove(list, index) end
            end
        end
    end
    self.rhythm[key], self.petLast[key] = nil, nil
    return touched
end

local function Result(who, spell, tick, extra)
    local result = { who = who, spell = spell, tick = tick == true }
    if extra then for k, v in pairs(extra) do result[k] = v end end
    return result
end

-- A tick claimed by dot: what it teaches. A rhythm found from this
-- session's first tick, and whether the spell also hits at once, are kept
-- only once a second tick lands on time.
-- How well a hit's amount fits a spell (0.3.9): Corruption and Curse of
-- Agony are both Shadow and both tick on a 6-second beat, but a DoT's tick
-- barely varies (Corruption 47 every time, Agony 21, 28, 35, 42). 0 for an
-- amount this spell has ticked for in a line-verified tick this session,
-- else from what its description says the ticks add up to (total over
-- duration, times its interval), else 0.5. Lower is better.
local function AmountFit(self, spell, amount, period)
    if type(amount) ~= "number" or amount <= 0 then return 0.5 end
    local seen = self.amounts[spell]
    if seen and seen[amount] then return 0 end
    -- Near an amount it has ticked for (a partial resist, a rank's step).
    local near
    if seen then
        for value in pairs(seen) do
            if type(value) == "number" then
                local err = math.abs(amount - value) / value
                if not near or err < near then near = err end
            end
        end
    end
    local facts = self.facts(spell)
    if type(facts) == "table" and facts.total and facts.duration and facts.duration > 0 and period then
        local expected = facts.total / facts.duration * period
        local err = math.min(1, math.abs(amount - expected) / expected)
        if near and near < err then err = near end
        return 0.15 + err * 0.85
    end
    if near then return 0.15 + math.min(1, near) * 0.85 end
    return 0.5
end
-- How well a hit's amount fits a spell's hit at once, from the damage its
-- description gives (Spells.lua, 0.3.40): 0 within it; above it by how far,
-- as spell power adds to it; below it twice as far, as only a partial resist
-- makes a hit smaller. A crit is compared at half and two thirds. 0.5 when
-- the amount or the spell's damage is unknown. Lower is better.
local function DirectFit(self, spell, amount, crit)
    local facts = self.facts(spell)
    if type(amount) ~= "number" or amount <= 0 or type(facts) ~= "table" or not facts.low or facts.low <= 0 then return 0.5 end
    local function Score(value)
        if value < facts.low then return 2 * math.log(facts.low / value) end
        if value > facts.high then return math.log(value / facts.high) end
        return 0
    end
    if crit then return math.min(Score(amount / 2), Score(amount / 1.5)) end
    return Score(amount)
end

local function RememberAmount(self, spell)
    local amount = self.amountNow
    if self.lineNow ~= true or self.ambiguous or type(amount) ~= "number" or amount <= 0 then return end
    local seen = self.amounts[spell] or { n = 0 }
    self.amounts[spell] = seen
    if not seen[amount] and seen.n < 24 then seen[amount], seen.n = true, seen.n + 1 end
end

local function Ticked(self, dot, school, now)
    dot.ticks, dot.next, dot.skipped = dot.ticks + 1, now + dot.period, 0
    RememberAmount(self, dot.spell)
    if school and not dot.school then dot.school = school end
    if not dot.known and dot.ticks >= 2 then
        dot.known = true
        if dot.school and self.learned("school", dot.spell) == nil then LearnSchool(self, dot.spell, dot.school) end
        self.learn("period", dot.spell, dot.period)
        if self.learned("direct", dot.spell) ~= BOTH then
            self.learn("direct", dot.spell, dot.direct and BOTH or TICKS_ONLY)
        end
    end
    -- 0.5.0: the application itself, whose usual tick a reduced one is
    -- measured against (Reduced.lua).
    return Result(dot.caster, dot.spell, true, { dot = dot })
end

-- Whether a DoT that has not ticked yet may be waiting for this hit as its
-- first tick: 1, 1.5, 2 or 3 seconds after its cast (2 or 3 for a spell that
-- also hit at once, as Immolate does); or, when the hit matched to its cast
-- came well after it (a first tick taken for a hit), at that same gap again.
local LATER_TICKS = { 2, 3 }
local RETIME_GAP = 1.75
local function FirstTick(dot, now)
    local since = now - dot.castAt
    for _, offset in ipairs(dot.direct and LATER_TICKS or FIRST_TICKS) do
        if math.abs(since - offset) <= TICK_SLACK then return offset, false end
    end
    if dot.directAt then
        local gap = dot.directAt - dot.castAt
        if gap >= RETIME_GAP and math.abs((now - dot.directAt) - gap) <= TICK_SLACK then return gap, true end
    end
end

-- Steps 1 to 5: a hit of yours, or nil.
-- Whether one of your DoTs with a known rhythm is due to tick now, on any
-- unit or on one whose plate went (0.3.23, the user: a check that only
-- works for some wands "will just fail later"). Ticks land within 0.03 s of
-- their beat, a wand's bolt whenever its flight ends, so a hit on a beat is
-- the DoT's, never the wand's, whatever their schools.
local function DotDue(self, school, now)
    for _, dot in ipairs(self.dots) do
        if dot.period and dot.next and SchoolFits(dot.school, school) and math.abs(now - dot.next) <= TICK_SLACK then
            return true
        end
    end
    return false
end

-- 0.3.48: what made a hit, when the colour of its combat log line says it
-- (Reader.lua, Setup.lua's line kinds): "direct" a spell's hit at once (or a
-- channel's: the game reports Arcane Missiles and the like as spell hits, so
-- ticks stay open to it), "tick" a DoT's or HoT's tick, "swing" melee,
-- "shot" a wand or bow; nil: unknown. Each opens only the steps below that
-- can make such a hit.
local function Allowed(restrict)
    return {
        ticks = restrict == nil or restrict == "tick" or restrict == "direct",
        casts = restrict == nil or restrict == "direct",
        melee = restrict == nil or restrict == "swing",
        ranged = restrict == nil or restrict == "shot",
    }
end

-- Whether a spell gives you the health its hits take (Spells.lua, leech).
local function Leeches(self, spell)
    local facts = self.facts(spell)
    return type(facts) == "table" and facts.leech == true
end

local function Yours(self, key, kind, school, now)
    local allowed, sure = Allowed(self.restrictNow), self.restrictNow == "tick"
    -- 1. A DoT's next tick; of several due now, the one whose time and
    -- amount fit best. 0.3.49: a tick that healed you for its amount in the
    -- same moment (leechNow, from the reader) is a draining DoT's, one that
    -- did not is not (a Drain Life tick and a Corruption tick 0.1 s apart had
    -- swapped icons, 1.60.1.70374).
    local function DueTick()
        if kind == "miss" or not allowed.ticks then return nil end
        local best, bestScore, count = nil, nil, 0
        for _, dot in ipairs(self.dots) do
            if dot.key == key and dot.period and dot.next and SchoolFits(dot.school, school)
                and math.abs(now - dot.next) <= TICK_SLACK then
                count = count + 1
                local score = math.abs(now - dot.next) / TICK_SLACK * 0.3 + AmountFit(self, dot.spell, self.amountNow, dot.period)
                if self.leechNow ~= nil and Leeches(self, dot.spell) ~= self.leechNow then score = score + 1 end
                if not bestScore or score < bestScore then best, bestScore = dot, score end
            end
        end
        -- Only a tick no other DoT could have made teaches its amount.
        self.ambiguous = count > 1
        if best then return Ticked(self, best, school, now) end
    end
    -- 0.3.49: a spell hit's line (restrict "direct") tries your and your
    -- pet's casts in flight first, and a DoT due in that moment after them
    -- (a Succubus's Lash of Pain had gone to a Drain Life tick due then).
    local castsFirst = self.restrictNow == "direct"
    if not castsFirst then
        local tick = DueTick()
        if tick then return tick end
    end
    -- 2. The first hit after a cast of its school (any cast for a miss),
    -- oldest first: bolts land in the order they were cast. Of casts of
    -- different spells, the one whose damage fits the hit's amount clearly
    -- better takes it (0.3.40: a Frost Nova's 23 had gone to the Frostbolt
    -- cast before it, still in flight, and the bolt's 60 to the Nova).
    local exact, exactFit, unknown
    for _, entry in ipairs(allowed.casts and self.pending or {}) do
        if not entry.used and entry.key == key and now >= entry.at and now - entry.at <= DIRECT_WINDOW then
            if entry.missOnly then
                if kind == "miss" then exact = exact or entry end
            elseif kind == "miss" then
                exact = exact or entry
            elseif entry.school and entry.school == school then
                local fit = DirectFit(self, entry.spell, self.amountNow, self.critNow)
                if not exact then
                    exact, exactFit = entry, fit
                elseif entry.spell ~= exact.spell and fit < exactFit - 0.1 then
                    exact, exactFit = entry, fit
                end
            elseif entry.school == nil then
                unknown = entry
            end
        end
    end
    local function Direct(entry)
        entry.used = true
        if entry.dot then entry.dot.direct, entry.dot.directAt = true, now end
        local guess
        if kind ~= "miss" and school and not entry.school then guess = Guess(self, entry, school) end
        local result = Result(entry.caster, entry.spell, false, kind == "miss" and { missed = true } or nil)
        result.guess = guess
        return result
    end
    if exact then return Direct(exact) end
    if castsFirst then
        local tick = DueTick()
        if tick then return tick end
    end
    -- 3. The first tick of a DoT that has not ticked yet. One whose own cast
    -- is still waiting for a first hit of a school not yet learned is left
    -- to step 4, where that cast takes it: a new spell's first hit is read
    -- as a hit until its rhythm shows.
    if kind ~= "miss" and allowed.ticks then
        for _, dot in ipairs(self.dots) do
            -- A hit whose line says it is a tick is never its cast's hit at
            -- once, so a new spell's cast need not wait for one.
            local waiting = not sure and dot.pending and not dot.pending.used and dot.pending.school == nil
                and now - dot.pending.at <= FIRST_HIT_WAIT
            if dot.key == key and not dot.period and not waiting and SchoolFits(dot.school, school) then
                local candidate = dot.candidate
                if candidate and math.abs(now - (candidate.at + candidate.period)) <= TICK_SLACK then
                    -- The tick it was waiting to confirm, on time.
                    dot.period, dot.candidate = candidate.period, nil
                    return Ticked(self, dot, school, now)
                end
                local period, retimed = FirstTick(dot, now)
                -- A spell that hit at once may tick too: with a line saying
                -- this is a tick of yours, it is one at once.
                if period and dot.direct and not retimed and not sure then
                    -- A spell that hit at once may still tick, but a hit a
                    -- few seconds later could as well be a teammate's: it
                    -- counts once a second tick lands on time after it.
                    if not candidate then dot.candidate = { period = period, at = now } end
                elseif period then
                    dot.period = period
                    -- Its first "hit" was its first tick.
                    if retimed then dot.direct = false end
                    return Ticked(self, dot, school, now)
                end
            end
        end
    end
    -- 4. The first hit after a cast whose school is still unknown: the
    -- newest, which teaches it.
    if unknown then return Direct(unknown) end
    -- 5. Your swing just before it. A wand's bolt is of the wand's school,
    -- read from its tooltip by the reader (0.3.21), else learned from its
    -- first shots this session (0.3.15: a shot took your Shadow DoT's tick in
    -- its window, the wand's being Fire), and needs a moment to fly.
    if kind == "miss" or kind == "damage" then
        for _, swing in ipairs(self.swings) do
            local ranged = swing.hand == "ranged"
            local since = now - swing.at
            local paired = self.pairedNow == swing
            if not swing.used and swing.key == key and (paired or since <= SwingWindow(swing, self.lineNow))
                and (self.pairedNow == nil or paired)
                and (ranged and allowed.ranged or not ranged and allowed.melee)
                and (kind == "miss" or (ranged and since >= 0.1 and not DotDue(self, school, now)
                        and SchoolFits(self.wandSchool, school))
                    or (not ranged and SchoolFits(PHYSICAL, school))) then
                swing.used = true
                -- 0.6.2: the delay of a melee hit paired by its swing's line.
                local _, usualLate = self:MeleeWindow(swing.hand)
                if paired and not ranged and since <= usualLate then
                    self.swingLags = self.swingLags or {}
                    local lags = self.swingLags[swing.hand] or {}
                    self.swingLags[swing.hand] = lags
                    table.insert(lags, since)
                    while #lags > LAG_SAMPLES do table.remove(lags, 1) end
                end
                if ranged and kind == "damage" and school and not self.wandSchool and not self.wandRead and self.lineNow == true then
                    self.wandVotes = self.wandVotes or {}
                    self.wandVotes[school] = (self.wandVotes[school] or 0) + 1
                    if self.wandVotes[school] >= 2 then self.wandSchool = school end
                end
                return Result("you", nil, false, { melee = true, hand = swing.hand, missed = kind == "miss" })
            end
        end
    end
end

-- How well a hit fits something of yours, without changing anything: lower
-- is better, nil when nothing of yours fits (0.3.32). The reader uses it
-- when a frame holds fewer lines of yours than hits (a raid boss struck by
-- many at once): only that many hits can be yours, and they are the ones
-- that fit a DoT on its beat, a cast in flight of their school, a swing or
-- a shot, or your pet; the rest are someone else's.
-- Whether a cast of yours that hits at once, of this hit's school, is in
-- flight to this unit: cast at least FLIGHT_MIN ago and within
-- DIRECT_WINDOW, not yet matched (0.3.36: the reader then looks for a
-- spare line of yours a moment before or after the hit, since a Shadow
-- Bolt's line came 30 to 270 ms before its hit report in the recordings).
-- 0.3.40: 0.2 s let point-blank Frostbolts through, which landed 0.09 to
-- 0.2 s after their casts; each was hidden, and its cast then took the next
-- Frost hit (a Frost Nova showed Frostbolt's icon).
local FLIGHT_MIN = 0.05
function Mine:InFlight(key, school, now)
    for _, entry in ipairs(self.pending) do
        local since = now - entry.at
        if not entry.used and not entry.missOnly and entry.key == key and since >= FLIGHT_MIN
            and since <= DIRECT_WINDOW and SchoolFits(entry.school, school) then
            return true
        end
    end
    -- A wand's bolt in flight too (0.3.37: its line also came in another
    -- frame than its hit; 16 of 25 bolts were hidden), unless a DoT of yours
    -- is due to tick on this very beat.
    for _, swing in ipairs(self.swings) do
        local since = now - swing.at
        if swing.hand == "ranged" and not swing.used and swing.key == key and since >= 0.1 and since <= RANGED_WINDOW
            and SchoolFits(self.wandSchool, school) and not DotDue(self, school, now) then
            return true
        end
    end
    return false
end

-- restrict (0.3.48): what the frame's lines say made their hits; only what
-- could have made such a hit counts.
function Mine:Fit(key, kind, school, now, amount, restrict)
    local best
    -- A damage shield's line fits any hit on an enemy (0.3.49).
    if restrict == "shield" then return (kind == "damage" or kind == "miss") and 0.7 or nil end
    local allowed = Allowed(restrict)
    local function Take(score) if not best or score < best then best = score end end
    for _, entry in ipairs(allowed.casts and self.pending or {}) do
        if not entry.used and entry.key == key and now >= entry.at - 0.05 and now - entry.at <= DIRECT_WINDOW then
            if kind == "miss" then Take(0.5)
            elseif not entry.missOnly and SchoolFits(entry.school, school) then Take(0.3 + AmountFit(self, entry.spell, amount, nil)) end
        end
    end
    if kind == "miss" and restrict == "tick" then
        for _, dot in ipairs(self.dots) do
            if dot.key == key then Take(0.5) end
        end
    end
    if kind ~= "miss" and allowed.ticks then
        for _, dot in ipairs(self.dots) do
            if dot.key == key and dot.period and dot.next and SchoolFits(dot.school, school) and math.abs(now - dot.next) <= TICK_SLACK then
                Take(AmountFit(self, dot.spell, amount, dot.period))
            end
        end
        if DotDue(self, school, now) then Take(0.9) end
    end
    for _, swing in ipairs(self.swings) do
        if not swing.used and swing.key == key then
            local since = now - swing.at
            if swing.hand == "ranged" then
                if allowed.ranged and since >= 0.1 and since <= RANGED_WINDOW and SchoolFits(self.wandSchool, school) then Take(0.6) end
            elseif allowed.melee and since <= SWING_WINDOW and (kind == "miss" or SchoolFits(PHYSICAL, school)) then
                Take(0.6)
            end
        end
    end
    if allowed.melee and self.petLines and self.petOut and (school == nil or school == PHYSICAL) then Take(0.8) end
    -- 0.3.42: a spell of yours that hits every enemy near (Flamestrike,
    -- Arcane Explosion) is cast at one unit or none, and lands on the others
    -- in its own moment. Their hits fit it too, after anything aimed at
    -- them, so in a frame with fewer lines than hits a spare line is not
    -- left over while they go to someone else (a Flamestrike on four
    -- enemies beside a teammate's tick had kept one of its four hits,
    -- 1.60.1.70374). Only a damaging hit of a spell's known school, and
    -- only in its cast's moment, so a teammate's hit seconds later never
    -- takes one. Not a miss: the game reports a resist as Physical whatever
    -- the spell, and a teammate's fully absorbed swing took a spare line as
    -- one in the replay.
    if kind ~= "miss" and school and allowed.casts then
        for spell, list in pairs(self.casts) do
            local facts = self.facts(spell)
            local known = (type(facts) == "table" and facts.school) or self.learned("school", spell)
            local harmful = not (type(facts) == "table" and (facts.damages == false or facts.helpful == true))
            local ticksOnly = type(facts) == "table" and facts.direct == false and facts.ticks == true
            if known == school and harmful and not ticksOnly then
                for _, cast in ipairs(list) do
                    local since = now - cast.at
                    if cast.caster == "you" and since >= -0.05 and since <= AREA_MOMENT then
                        Take(1 + DirectFit(self, spell, amount, nil))
                    end
                end
            end
        end
    end
    return best
end

-- A hit known to be yours (its line came) that nothing else placed: the
-- spell of yours whose timing fits it best, whatever unit it was cast on
-- (0.3.9: DoTs cast while another enemy was targeted, or followed under a
-- plate that went before their rhythm was known). Over the last 30 seconds,
-- a spell of the hit's school that ticks scores how far the hit is from a
-- whole number of its intervals after the cast; one that hits at once, how
-- long ago it was cast, if within DIRECT_WINDOW. Unknown intervals score
-- after known ones; nil when no cast fits.
-- restrict "tick" (0.3.48, its line says so): only a spell that ticks.
function Mine:Likeliest(school, now, restrict)
    local best, bestScore
    for spell, list in pairs(self.casts) do
      for _, cast in ipairs(list) do
        local since = now - cast.at
        if since >= 0 and since <= 30 then
            local facts = self.facts(spell)
            local known = (type(facts) == "table" and facts.school) or self.learned("school", spell)
            local damages = not (type(facts) == "table" and facts.damages == false)
            if damages and SchoolFits(known, school) then
                local kind = self.learned("direct", spell)
                if type(facts) == "table" and facts.direct ~= nil then
                    kind = (facts.direct and facts.ticks and BOTH) or (facts.ticks and TICKS_ONLY) or (facts.direct and DIRECT_ONLY) or kind
                end
                local period = self.learned("period", spell)
                local score
                if kind ~= DIRECT_ONLY and period and since >= period - TICK_SLACK then
                    -- Only the latest cast's moment is known (the same DoT
                    -- may be on several enemies), so the amount decides and
                    -- the moment only breaks ties.
                    local off = since % period
                    off = math.min(off, period - off)
                    score = AmountFit(self, spell, self.amountNow, period) + math.min(off, 1) * 0.1
                elseif kind ~= DIRECT_ONLY and not period and since >= 0.8 then
                    score = 1 + since / 30
                end
                if kind ~= TICKS_ONLY and since <= DIRECT_WINDOW and restrict ~= "tick" then
                    local direct = 0.5 + since / 10
                    if not score or direct < score then score = direct end
                end
                if score and (not bestScore or score < bestScore) then
                    best, bestScore = { spell = spell, caster = cast.caster,
                        tick = restrict == "tick" or (kind ~= DIRECT_ONLY and since > DIRECT_WINDOW) }, score
                end
            end
        end
      end
    end
    if not best then return nil end
    return Result(best.caster, best.spell, best.tick, { likely = true })
end

-- A hit (kind "damage" or "heal") or a miss (kind "miss") on the unit keyed
-- key; school is its school mask or nil when unreadable. petAttacking: your
-- pet is attacking that unit now. amount and crit: the hit's, when readable.
-- Returns who made it: { who = "you" | "pet"
-- | "other", spell, tick, melee, missed }. An "other" damage or miss is held
-- (hold = true, held = its entry) for a swing reported a moment later.
-- restrict (0.3.48): what made it, from its line's colour (Allowed, above).
-- leech (0.3.49): true when a heal on you of the hit's amount came in its
-- moment, false when heals on you were read and none matched, nil unknown.
function Mine:Hit(key, kind, school, now, petAttacking, line, amount, crit, restrict, leech)
    self:Tidy(now)
    self.amountNow, self.lineNow, self.ambiguous, self.critNow = amount, line, false, crit == true
    -- 0.6.1: the swing whose own line the reader paired with this hit.
    self.pairedNow, self.pairedSwing = line == true and self.pairedSwing or nil, nil
    -- 0.6.2: a swing line of yours with no swing of yours in its frame,
    -- paired by the reader (an extra attack, or your pet's swing).
    local orphan = line == true and self.orphanSwing
    self.orphanSwing = nil
    -- 0.6.5 (predicted, not yet seen in client): a proc riding on your swing
    -- (a seal, a poison, Windfury's damage), whose line came in the frame of
    -- a swing of yours whose hit lands with it (Reader.lua, ProcLine).
    local procSwing = line == true and self.procSwing
    self.procSwing = nil
    if procSwing and (kind == "damage" or kind == "miss") then
        return Result("you", nil, false, { proc = true, missed = kind == "miss" })
    end
    self.restrictNow = line == true and restrict or nil
    self.leechNow = kind == "damage" and leech or nil
    local allowed = Allowed(self.restrictNow)
    -- 0.3.49: a damage shield's line (Thorns on you, an item): the hit on
    -- the enemy that struck you is yours, whatever cast or swing came before
    -- (four were left out in a battleground, 1.60.1.70374).
    if self.restrictNow == "shield" and (kind == "damage" or kind == "miss") then
        return Result("you", nil, false, { shield = true, missed = kind == "miss" })
    end
    -- line (0.3.8): whether a combat log line of yours came in the same
    -- frame as the hit; nil when lines are not coming or one frame held
    -- fewer lines than hits. A hit with none is never yours: it cannot take
    -- a cast, a swing or a DoT's tick, nor teach anything (a teammate's
    -- Shadow hit 0.66 s after a Corruption had become its "first tick",
    -- and the real ticks were then dropped, 1.60.1.70374).
    if line ~= false then
        local result = Yours(self, key, kind, school, now)
        if result then return result end
    end
    -- 6a (before the DoT fallbacks: a pet's swing is never a tick). With your pet's lines coming too (petLines, set by the reader from
    -- Blizzard's filter), a physical hit with a line that no swing of yours
    -- explains is your pet's (0.3.18).
    -- 0.3.24: a miss of yours (its line came) within a moment of a cast of
    -- yours is that spell's, whichever plate it shows on (a Curse of
    -- Exhaustion resisted had gone to the pet); and the pet only while it
    -- is out (petOut, set by the reader).
    -- 0.3.48: a tick of yours that missed (its line says so: a resisted
    -- Corruption tick) is the DoT due on that unit, or one on it, never the
    -- cast just before.
    if line == true and kind == "miss" and self.restrictNow == "tick" then
        local best, bestOff
        for _, dot in ipairs(self.dots) do
            if dot.key == key then
                local off = dot.next and math.abs(now - dot.next) or 99
                if not bestOff or off < bestOff then best, bestOff = dot, off end
            end
        end
        if best and best.next and bestOff <= TICK_SLACK then best.next, best.skipped = now + best.period, 0 end
        if best then return Result(best.caster, best.spell, true, { missed = true }) end
        -- 0.3.49: none followed on this plate (a DoT cast while another enemy
        -- was targeted): the DoT of yours whose rhythm fits, as for a tick
        -- that landed (absorbed ticks had shown with no icon).
        local guess = self:Likeliest(nil, now, "tick")
        if guess then
            guess.missed = true
            return guess
        end
        return Result("you", nil, true, { missed = true })
    end
    if line == true and kind == "miss" and allowed.casts then
        local best, bestSince
        for spell, list in pairs(self.casts) do
            local facts = self.facts(spell)
            -- 0.3.50: nor a spell cast on yourself (Life Tap, which costs
            -- health): an Immune on an enemy had taken its icon, cast 1.5 s
            -- before the Curse of Exhaustion that was immune (1.60.1.70374).
            local helpful = type(facts) == "table" and (facts.helpful == true or facts.healthCost ~= nil)
            for _, cast in ipairs(list) do
                local since = now - cast.at
                if not helpful and since >= -0.05 and since <= DIRECT_WINDOW and (not bestSince or since < bestSince) then
                    best, bestSince = { spell = spell, caster = cast.caster }, since
                end
            end
        end
        if best then return Result(best.caster, best.spell, false, { missed = true }) end
    end
    if line == true and self.petLines and self.petOut and (kind == "damage" or kind == "miss") and allowed.melee
        and (school == nil or school == PHYSICAL) then
        return Result("pet", nil, false, { melee = true, missed = kind == "miss" })
    end
    -- 0.6.2 (predicted, not yet seen in client): a swing line with no swing
    -- of yours in its frame and no pet out is an extra attack of yours
    -- (Windfury, Sword Specialization, a proc that swings again).
    if orphan and (kind == "damage" or kind == "miss") and (school == nil or school == PHYSICAL) then
        return Result("you", nil, false, { melee = true, hand = "main", missed = kind == "miss", extra = true })
    end
    -- A tick of yours (its line came) that nothing here explains, in the
    -- moment a DoT whose plate went is due: that DoT, now on this plate.
    if line == true and kind == "damage" and allowed.ticks then
        for _, dot in ipairs(self.dots) do
            if dot.key == false and dot.next and SchoolFits(dot.school, school) and math.abs(now - dot.next) <= TICK_SLACK then
                dot.key = key
                return Ticked(self, dot, school, now)
            end
        end
        local guess = self:Likeliest(school, now, self.restrictNow)
        -- A hit that healed you is a drain's: never a spell that does not drain.
        if guess and not (self.leechNow == true and not Leeches(self, guess.spell)) then return guess end
    end
    -- 0.3.49: a hit of yours (its line came) that healed you for its amount
    -- and that nothing above placed is a drain no cast of yours explains:
    -- the Undead's Touch of the Grave on Forever, landing as you cast. Yours;
    -- from 0.3.51 marked as a drain, so the router gives it its own icon.
    if line == true and kind == "damage" and self.leechNow == true and allowed.casts then
        return Result("you", nil, false, { proc = true, drain = true })
    end
    -- 6. Your pet's swing.
    if (kind == "damage" or kind == "miss") and petAttacking and allowed.melee and (school == nil or school == PHYSICAL) then
        local last = self.petLast[key]
        if not last or now - last >= PET_GAP then
            self.petLast[key] = now
            return Result("pet", nil, false, { melee = true, missed = kind == "miss" })
        end
    end
    -- 7. Someone else's: a steady rhythm of one school is still ticks.
    local tick = false
    if kind ~= "miss" and school then
        self.rhythm[key] = self.rhythm[key] or {}
        local beat = self.rhythm[key][school]
        if beat then
            local gap = now - beat.last
            if beat.interval and math.abs(gap - beat.interval) <= RHYTHM_SLACK and gap >= 0.9 and gap <= 3.3 then tick = true end
            beat.interval, beat.last = gap, now
        else
            self.rhythm[key][school] = { last = now }
        end
    end
    local result = Result("other", nil, tick)
    if line ~= false and (kind == "miss" or kind == "damage") then
        local held = { key = key, kind = kind, school = school, at = now }
        self.held[#self.held + 1] = held
        result.hold, result.held = true, held
    end
    return result
end

-- The DoTs the engine is following, for the tests.
function Mine:Dots() return self.dots end
