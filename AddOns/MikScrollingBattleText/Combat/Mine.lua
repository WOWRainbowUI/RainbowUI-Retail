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
--   2. a direct cast whose target, school and readable damage fit the hit,
--      with a clear margin over other spell identities, or the one cast
--      made in the hit's frame;
--   3. the first tick of a spell that may tick: 1, 1.5, 2 or 3 seconds
--      after its cast, or as long after its first matched hit as that hit
--      came after the cast (a first tick taken for a hit);
--   4. an unknown-school cast, using the same comparison after known ticks;
--   5. a physical hit or a miss right after one of your swings;
--   6. a physical hit confirmed by your pet's enabled outgoing lines when
--      no player swing explains it (a pet's swings are not reported);
--   7. otherwise unknown: a teammate's hit, or a DoT whose cast was not
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
-- confirmed, unambiguous casts agree. Unconfirmed repetition never teaches
-- a school. A hit with no line while the log runs was not yours (Doubt),
-- and its guess is taken back. A DoT's school is kept once
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
-- Time breaks ties within one identity, but cannot by itself name a spell.
local DIRECT_MATCH_MARGIN = 0.1
local DIRECT_TIME_WEIGHT = 0.05
-- The frame of a cast can: a strike's report came with the timestamp of its
-- cast's event (seen on Forever with Rake and Claw, three of three; a
-- queued strike reports in its cast's frame too, Reader.lua). With amounts
-- hidden in a fight and no description read, two different casts waiting on
-- a unit left every hit without a name, and as such a hit uses up no cast,
-- the next was nameless again: after a taunt, seven strikes of seven, each
-- shown with a question mark. A cast made within SAME_FRAME of the hit leads
-- older casts by more than the margin; two casts of one frame still tie, and
-- a readable amount that fits another cast still outranks the frame.
local SAME_FRAME, SAME_FRAME_LEAD = 0.02, 0.2
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
local CAST_HISTORY_WINDOW = 30
local RHYTHM_WINDOW = 3.3
ns.LATE_SWING = LATE_SWING

-- learned "direct": what a spell does.
local DIRECT_ONLY, TICKS_ONLY, BOTH = 1, 2, 3
ns.SPELL_KINDS = { directOnly = DIRECT_ONLY, ticksOnly = TICKS_ONLY, both = BOTH }

local function SpellKind(facts, kind)
    if type(facts) ~= "table" then return kind end
    if facts.ticks == true then
        if facts.direct == true then return BOTH end
        if facts.direct == false then return TICKS_ONLY end
        if kind == DIRECT_ONLY then return nil end
    elseif facts.direct == true then
        if facts.ticks == false then return DIRECT_ONLY end
        if kind == TICKS_ONLY then return nil end
    end
    return kind
end

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
local function LearnedMeleeWindow(tracker, hand)
    local lag = tracker:SwingDelay(hand)
    if not lag then return end
    local early = math.max(0.05, lag - SWING_EARLY)
    local late = lag + SWING_LATE
    -- Variable two-hander delays can fall outside the median's window.
    -- Preserve the initial range when recent samples show that variation;
    -- stable hands stay tight so an earlier teammate hit cannot claim them.
    for _, delay in ipairs(tracker.swingLags[hand]) do
        if delay < early or delay > late then
            return math.min(SWING_MIN, early), math.max(SWING_LINED, late)
        end
    end
    return early, late
end

-- The delays a melee hit with a swing's line may come after it: for a hand,
-- or with no hand (an extra attack, a killing swing) any hand's.
function Mine:MeleeWindow(hand)
    if hand then
        local early, late = LearnedMeleeWindow(self, hand)
        return early or SWING_MIN, late or SWING_LINED
    end
    local early, late
    for _, each in ipairs({ "main", "off" }) do
        local handEarly, handLate = LearnedMeleeWindow(self, each)
        if handEarly then
            early = math.min(early or 99, handEarly)
            late = math.max(late or 0, handLate)
        end
    end
    if not early then return SWING_MIN, SWING_LINED end
    return early, late
end

-- learned(field, id) and learn(field, id, value): the saved cache (Store.lua);
-- facts(id): what the spell's description says (Spells.lua), or nil.
function ns.NewMine(learned, learn, facts)
    return setmetatable({ pending = {}, dots = {}, swings = {}, held = {}, rhythm = {}, petLast = {}, evidence = {}, votes = {},
        casts = {}, amounts = {}, channels = {}, retiredDots = {},
        retiredChannels = {},
        learned = learned or function() end, learn = learn or function() end, facts = facts or function() end }, Mine)
end

local function Prune(list, keep, now, tracker)
    for index = #list, 1, -1 do
        if not keep(list[index], now, tracker) then
            table.remove(list, index)
        end
    end
    while #list > MAX do table.remove(list, 1) end
end

local function DirectWindow(self, spell)
    local facts = self.facts(spell)
    return type(facts) == "table" and facts.window or DIRECT_WINDOW
end

local function KeepPending(entry, now, tracker)
    return not entry.used
        and now - entry.at <= DirectWindow(tracker, entry.spell)
end

local function KeepSwing(entry, now)
    return not entry.used and now - entry.at <= PairedWindow(entry)
end

local function KeepHeld(entry, now)
    return not entry.claimed and now - entry.at <= LATE_SWING
end

local function PeriodicExpired(facts, castAt, now, cast)
    if type(facts) ~= "table" or not facts.duration then return false end
    -- A catalog period starts at the cast. Tooltip-only projectiles can
    -- establish their application time from two actual observed ticks.
    local start = not facts.period and cast and cast.periodicAt or castAt
    return now - start > facts.duration + TICK_SLACK
end

local function KeepDot(dot, now, tracker)
    local facts = tracker.facts(dot.spell)
    if PeriodicExpired(facts, dot.castAt, now, dot.cast) then return false end
    if dot.bufferUntil then
        if now <= dot.bufferUntil then return true end
        dot.bufferUntil = nil
    end
    if dot.confirmedAt and not dot.period then return now - dot.confirmedAt <= CAST_HISTORY_WINDOW end
    if dot.period then
        -- Allow up to three skipped ticks before discarding a known rhythm.
        while now > dot.next + TICK_SLACK and (dot.skipped or 0) < 3 do
            dot.next = dot.next + dot.period
            dot.skipped = (dot.skipped or 0) + 1
        end
        return now <= dot.next + TICK_SLACK + 0.3
    end
    if now - dot.castAt <= FIRST_WAIT then return true end
    -- Keep a possible first tick until its timing can be confirmed.
    if dot.directAt and now - dot.directAt <= FIRST_WAIT then return true end
    if dot.candidate
        and now <= dot.candidate.at + dot.candidate.period + TICK_SLACK then
        return true
    end
    -- Two direct hits without a tick establish a direct-only spell.
    if dot.direct and tracker.learned("period", dot.spell) == nil
        and tracker.learned("school", dot.spell) ~= nil then
        local seen = (tracker.evidence[dot.spell] or 0) + 1
        tracker.evidence[dot.spell] = seen
        if seen >= 2 then tracker.learn("direct", dot.spell, DIRECT_ONLY) end
    end
    return false
end

local function ChannelExpired(channel, now)
    return (channel.endsAt and now > channel.endsAt + 0.5)
        or (not channel.endsAt and now - channel.at > CAST_HISTORY_WINDOW)
        or (channel.stoppedAt and now - channel.stoppedAt > 0.5)
end

function Mine:Tidy(now)
    for index = #self.retiredDots, 1, -1 do
        local dot = self.retiredDots[index]
        local facts = self.facts(dot.spell)
        local hasDuration = type(facts) == "table" and facts.duration ~= nil
        if (not hasDuration and now - dot.castAt > CAST_HISTORY_WINDOW)
            or PeriodicExpired(facts, dot.castAt, now, dot.cast) then
            table.remove(self.retiredDots, index)
        end
    end
    for index = #self.retiredChannels, 1, -1 do
        if ChannelExpired(self.retiredChannels[index], now) then
            table.remove(self.retiredChannels, index)
        end
    end
    for caster, channel in pairs(self.channels) do
        if ChannelExpired(channel, now) then self.channels[caster] = nil end
    end
    for key, schools in pairs(self.rhythm) do
        for school, beat in pairs(schools) do
            if now - beat.last > RHYTHM_WINDOW then schools[school] = nil end
        end
        if next(schools) == nil then self.rhythm[key] = nil end
    end
    for key, last in pairs(self.petLast) do
        if now - last >= PET_GAP then self.petLast[key] = nil end
    end
    for spell, casts in pairs(self.casts) do
        for index = #casts, 1, -1 do
            if now - casts[index].at > CAST_HISTORY_WINDOW then
                table.remove(casts, index)
            end
        end
        if #casts == 0 then self.casts[spell] = nil end
    end

    Prune(self.pending, KeepPending, now, self)
    Prune(self.swings, KeepSwing, now)
    Prune(self.held, KeepHeld, now)
    Prune(self.dots, KeepDot, now, self)
end

local function SchoolFits(known, school)
    if known == nil or school == nil or known == school then return true end
    -- Chaos tooltips cover all schools. Hits can omit Holy and Physical
    -- (124, including Chaos Bolt and Eye Beam), or just Physical (126).
    return known == 127 and (school == 124 or school == 126)
end

-- Every direct path spends the same target outcome. A nearby second target
-- preserves legacy area impacts; it never reopens an outcome on the first.
local function DirectAvailable(self, spell, cast, key, now, area)
    local age = now - cast.at
    if age < -0.05 or age > DirectWindow(self, spell) then return false end
    local facts = self.facts(spell)
    local areaSpell = type(facts) == "table" and facts.area == true
    if cast.key ~= key and not cast.targetUncertain and not (area and (areaSpell
        or age <= AREA_MOMENT)) then return false end
    local limit = type(facts) == "table" and facts.directHits or 1
    local count = cast.outcomes and cast.outcomes[key or false] or 0
    if key and cast.targetUncertain and cast.outcomes then
        count = count + (cast.outcomes[false] or 0)
    end
    return count < (limit or 1)
end

local function ApplicationFailed(self, spell, cast, key)
    local target = key or false
    local misses = cast.misses and cast.misses[target] or 0
    local outcomes = cast.outcomes and cast.outcomes[target] or 0
    local facts = self.facts(spell)
    local limit = type(facts) == "table" and facts.directHits or 1
    return misses >= (limit or 1) and misses == outcomes
end

local function TargetApplied(cast, key)
    local target = key or false
    local outcomes = cast.outcomes and cast.outcomes[target] or 0
    local misses = cast.misses and cast.misses[target] or 0
    return outcomes > misses
end

local function PeriodicAvailable(cast, key, now, period)
    local previous = cast and cast.periodicOutcomes
        and cast.periodicOutcomes[key or false]
    if previous == nil then return true end
    -- History shares the same minimum separation as ordinary candidates.
    if now - previous < 0.5 then return false end
    if not period then return true end
    -- Compare both reports on the current grid. A corrected learned period
    -- must not reinterpret a saved ordinal from an older, stale interval.
    local anchor = cast.periodicAt or cast.at
    local before = math.floor((previous - anchor) / period + 0.5)
    local current = math.floor((now - anchor) / period + 0.5)
    return current > before
end

local function SpendPeriodic(cast, key, now)
    if not cast then return end
    cast.periodicOutcomes = cast.periodicOutcomes or {}
    cast.periodicOutcomes[key or false] = now
end

local function SpendDirect(self, spell, cast, key, missed)
    cast.outcomes = cast.outcomes or {}
    local target = key or false
    cast.outcomes[target] = (cast.outcomes[target] or 0) + 1
    if (self.accountingEnabled == true or self.inferredWindfuryEnabled == true)
        and not cast.ambiguous then
        self.lastOutcomeReceipt = {
            kind = "cast", at = cast.at, key = key, sourceKey = cast.key,
            spell = spell, who = cast.caster, ordinal = cast.outcomes[target],
            uncertain = cast.targetUncertain == true,
        }
    end
    if missed then
        cast.misses = cast.misses or {}
        cast.misses[target] = (cast.misses[target] or 0) + 1
    end
    cast.directUsed = true
    if not missed then cast.direct = true end
    for _, entry in ipairs(self.pending) do
        if entry.cast == cast and entry.key == key then
            entry.used = not DirectAvailable(self, spell, cast, key, cast.at)
        end
    end
    if ApplicationFailed(self, spell, cast, key) then
        -- Periodic-only applications have no pending direct entry. Their
        -- cast link still lets a failed application remove only its own DoT.
        for index = #self.dots, 1, -1 do
            local dot = self.dots[index]
            if dot.cast == cast and dot.key == key then
                dot.missed, dot.pending = true, nil
                table.remove(self.dots, index)
            end
        end
    end
end

local function ChannelFits(channel, key, school, now)
    return (channel.key == key or channel.targetUncertain)
        and SchoolFits(channel.school, school)
        and now >= channel.at
        and (not channel.endsAt or now <= channel.endsAt)
        and (not channel.stoppedAt or now <= channel.stoppedAt)
end

function Mine:StartChannel(caster, spell, key, now, targetUncertain)
    caster = caster == "pet" and "pet" or "you"
    -- Beginning another channel also ends any retired channel of that caster.
    self:StopChannel(caster, nil, now)
    self.channels[caster] = nil
    local facts = self.facts(spell)
    if type(facts) ~= "table" or facts.damages ~= true then return end

    -- A channel's hits follow its lifecycle, not a guessed DoT interval.
    -- Remove its ordinary cast records so they cannot claim later damage.
    for _, list in ipairs({ self.pending, self.dots }) do
        for index = #list, 1, -1 do
            local entry = list[index]
            if entry.caster == caster and entry.spell == spell then
                table.remove(list, index)
            end
        end
    end
    local casts = self.casts[spell]
    if casts then
        for index = #casts, 1, -1 do
            if casts[index].caster == caster then table.remove(casts, index) end
        end
        if #casts == 0 then self.casts[spell] = nil end
    end
    self.channels[caster] = {
        caster = caster, spell = spell, key = key, at = now,
        targetUncertain = targetUncertain == true,
        school = facts.school or self.learned("school", spell),
        endsAt = facts.duration and now + facts.duration or nil,
    }
end

function Mine:StopChannel(caster, spell, now)
    caster = caster == "pet" and "pet" or "you"
    local function Stop(channel)
        if channel and channel.caster == caster
            and (spell == nil or channel.spell == spell) then
            -- Buffered hits retain their event time, including the final tick.
            channel.stoppedAt = math.min(channel.stoppedAt or now, now)
        end
    end
    Stop(self.channels[caster])
    for _, channel in ipairs(self.retiredChannels) do Stop(channel) end
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
    if self.lineNow ~= true then
        -- A delayed confirmation may trust this guess later; repetition alone
        -- must not turn unconfirmed ownership into persistent spell knowledge.
        return { spell = spell, school = school, caster = entry.caster,
            entry = entry }
    end
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
function Mine:Cast(caster, spell, key, now, targetUncertain)
    if type(spell) ~= "number" then return end
    caster = caster == "pet" and "pet" or "you"
    local channel = self.channels[caster]
    if channel and not channel.stoppedAt and channel.spell == spell then
        return
    end
    local facts = self.facts(spell)
    -- With no unit, only a spell of yours whose description says it deals
    -- damage counts (opening a chest is a cast with no target too).
    if not key and not targetUncertain and (caster ~= "you" or type(facts) ~= "table" or facts.damages ~= true) then return end
    self:Tidy(now)
    local school, kind, period = self.learned("school", spell), self.learned("direct", spell), self.learned("period", spell)
    -- The last few casts of each spell (0.3.11: a fresh Agony on one enemy
    -- hid the one still ticking on another).
    local list = self.casts[spell] or {}
    self.casts[spell] = list
    local cast = { at = now, caster = caster, key = key, spell = spell,
        targetUncertain = targetUncertain == true }
    list[#list + 1] = cast
    while #list > 6 do table.remove(list, 1) end
    -- 0.3.42: a cast of yours with nothing targeted (an Arcane Explosion)
    -- has no unit to wait on, but stays in that list, so a hit or resist
    -- of yours on any enemy in its moment is its (Likeliest, and a miss in
    -- Hit); it had been forgotten, and its hits shown as someone else's
    -- or its resist with an earlier wand shot's icon (1.60.1.70374).
    if not key and not targetUncertain then return end
    if type(facts) == "table" then
        if facts.damages == false then
            -- No damage at all: only a resist or immune can be its. 0.3.50:
            -- none at all for a spell cast on yourself (Life Tap).
            if facts.healthCost ~= nil or facts.helpful == true then return end
            self.pending[#self.pending + 1] = {
                caster = caster, spell = spell, key = key, at = now,
                missOnly = true, cast = cast,
                targetUncertain = targetUncertain == true,
            }
            while #self.pending > MAX do table.remove(self.pending, 1) end
            return
        end
        -- The description wins over anything learned from hits (0.3.6: a
        -- Curse of Agony learned as Physical from a pet's swings).
        school = facts.school or school
        kind = SpellKind(facts, kind)
        period = facts.period or period
    end
    -- A recast refreshes its DoT: the ticks start again from now.
    for index = #self.dots, 1, -1 do
        local dot = self.dots[index]
        if dot.spell == spell and dot.key == key then table.remove(self.dots, index) end
    end
    local dot
    if kind ~= DIRECT_ONLY or period then
        dot = { caster = caster, spell = spell, key = key, castAt = now,
            cast = cast, school = school, period = period,
            targetUncertain = targetUncertain == true,
            next = period and (now + period) or nil, ticks = 0, known = period ~= nil }
        self.dots[#self.dots + 1] = dot
    end
    if kind ~= TICKS_ONLY then
        local entry = {
            caster = caster, spell = spell, key = key, at = now,
            school = school, dot = dot, cast = cast,
            targetUncertain = targetUncertain == true,
        }
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
            if self.accountingEnabled == true or self.inferredWindfuryEnabled == true then
                hit.accountingReceipt = {
                    kind = "swing", at = now, key = key, hand = hand,
                    who = "you", ordinal = 1,
                }
            end
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
-- With stray, also a melee swing whose hit comes at neither of its times:
-- anywhere from SWING_MIN to the end of the delayed window. A druid's swings
-- in Cat Form were reported 0.43, 0.77 or 1.0 s after their lines; once 0.76 s
-- was learned, the first came before the window and the last between the two
-- (1.60.1.70959). The reader asks so only once nothing else placed the hit
-- and nobody else is seen to strike the unit (Reader.lua, StraySwingLine).
function Mine:SwingsBefore(key, now, stray)
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
                or (stray == true and since >= SWING_MIN and since <= lag + DELAYED_TO)
        end
        if not swing.used and swing.key == key and fits then found[#found + 1] = swing end
    end
    return found
end

function Mine:SwingMatchDeadline(swing)
    local _, usualLate = self:MeleeWindow(swing.hand)
    local lag = self:SwingDelay(swing.hand) or USUAL_DELAY
    return swing.at + math.max(usualLate, lag + DELAYED_TO)
end

-- Optional diagnostics observe the same windows without tidying or spending.
function Mine:AccountingSwingChecks(key, at)
    if self.accountingEnabled ~= true then return nil end
    local checks = {}
    for index = #self.swings, 1, -1 do
        local swing = self.swings[index]
        local age = at - swing.at
        if swing.key == key and swing.hand ~= "ranged"
            and age <= PairedWindow(swing) then
            local early, late = self:MeleeWindow(swing.hand)
            local lag = self:SwingDelay(swing.hand) or USUAL_DELAY
            local delayedEarly, delayedLate = lag + DELAYED_FROM,
                lag + DELAYED_TO
            local fits = (age >= early and age <= late)
                or (age >= delayedEarly and age <= delayedLate)
            local eligible = not swing.used and fits
            local reason
            if swing.used then reason = "used"
            elseif eligible then reason = "eligible"
            elseif age < early then reason = "before-window"
            else reason = "after-window" end
            checks[#checks + 1] = {
                at = swing.at, hand = swing.hand, age = age,
                early = early, late = late, delayedEarly = delayedEarly,
                delayedLate = delayedLate, used = swing.used == true,
                eligible = eligible, reason = reason,
            }
            if #checks == 8 then break end
        end
    end
    return checks
end

local function RekeyCast(cast, old, new, seen)
    if not cast or seen[cast] then return end
    seen[cast] = true
    if cast.key == old then cast.key = new end
    if cast.outcomes and cast.outcomes[old] then
        cast.outcomes[new] = math.max(cast.outcomes[new] or 0,
            cast.outcomes[old])
        cast.outcomes[old] = nil
    end
    if cast.misses and cast.misses[old] then
        cast.misses[new] = math.max(cast.misses[new] or 0,
            cast.misses[old])
        cast.misses[old] = nil
    end
    if cast.periodicOutcomes and cast.periodicOutcomes[old] then
        cast.periodicOutcomes[new] = math.max(
            cast.periodicOutcomes[new] or -math.huge,
            cast.periodicOutcomes[old])
        cast.periodicOutcomes[old] = nil
    end
end

-- A unit known by another key now: your target's nameplate went (a dying
-- enemy's plate goes before the report of the blow that killed it) or came.
function Mine:Rekey(old, new)
    if not old or not new or old == new then return end
    for _, channel in pairs(self.channels) do
        if channel.key == old then channel.key = new end
    end
    local seen = {}
    for _, casts in pairs(self.casts) do
        for _, cast in ipairs(casts) do
            RekeyCast(cast, old, new, seen)
        end
    end
    for _, list in ipairs({ self.pending, self.dots, self.swings, self.held }) do
        for _, entry in ipairs(list) do
            -- Live effects retain their cast ledger after history expires.
            RekeyCast(entry.cast, old, new, seen)
            if entry.key == old then entry.key = new end
        end
    end
    self.rhythm[new], self.rhythm[old] = self.rhythm[old], nil
    self.petLast[new], self.petLast[old] = self.petLast[old], nil
end

-- Forget a unit (its nameplate went).
-- A lost lifetime cannot be identified again from timing alone. Only Rekey
-- may move state when the reader has evidence that two keys are one unit.
-- Returns how many casts, DoTs, swings and held hits it touched.
function Mine:Forget(key)
    local touched = 0
    for spell, casts in pairs(self.casts) do
        for index = #casts, 1, -1 do
            if casts[index].key == key then table.remove(casts, index) end
        end
        if #casts == 0 then self.casts[spell] = nil end
    end
    for caster, channel in pairs(self.channels) do
        if channel.key == key then
            self.retiredChannels[#self.retiredChannels + 1] = channel
            while #self.retiredChannels > MAX do
                table.remove(self.retiredChannels, 1)
            end
            self.channels[caster] = nil
        end
    end
    for _, list in ipairs({ self.pending, self.dots, self.swings, self.held }) do
        for index = #list, 1, -1 do
            local entry = list[index]
            if entry.key == key then
                touched = touched + 1
                if list == self.dots then
                    self.retiredDots[#self.retiredDots + 1] = entry
                    while #self.retiredDots > MAX do
                        table.remove(self.retiredDots, 1)
                    end
                end
                table.remove(list, index)
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

-- A line confirms ownership, but close spell identities remain unnamed.
-- Mixed player/pet candidates cannot safely choose an individual owner.
local function AmbiguousResult(self, owner, mixedOwners, tick, missed)
    self.lastOutcomeReceipt = nil
    self.ambiguous = true
    if self.lineNow ~= true or mixedOwners then owner = "unknown" end
    return Result(owner, nil, tick,
        { ambiguous = true, missed = missed == true })
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

local function DirectCandidateScore(self, entry, key, school, now, amount, crit)
    local age = now - entry.at
    if entry.used or entry.missOnly
        or (entry.key ~= key and not entry.targetUncertain)
        or not DirectAvailable(self, entry.spell, entry.cast, key, now)
        or not SchoolFits(entry.school, school) then return nil end

    local facts = self.facts(entry.spell)
    if type(facts) == "table" and (facts.damages == false
        or facts.helpful == true or facts.healthCost ~= nil
        or (facts.direct == false and facts.ticks == true)) then
        return nil
    end

    local score = DirectFit(self, entry.spell, amount, crit)
        + math.max(0, age) / DirectWindow(self, entry.spell)
            * DIRECT_TIME_WEIGHT
    if age <= SAME_FRAME then score = score - SAME_FRAME_LEAD end
    return score
end

local function SameIdentity(first, second)
    return first.spell == second.spell and first.caster == second.caster
end

local function SelectDirectCandidate(self, key, school, now)
    local best, bestScore
    for _, entry in ipairs(self.pending) do
        local score = DirectCandidateScore(self, entry, key, school, now,
            self.amountNow, self.critNow)
        if score then
            if best and SameIdentity(entry, best) then
                -- Repeated casts share an identity; consume the oldest first.
                if entry.at < best.at then best = entry end
                bestScore = math.min(bestScore, score)
            elseif not bestScore or score < bestScore then
                best, bestScore = entry, score
            end
        end
    end
    if not best then return nil end

    -- Compare the winner with every other identity, not just the first cast.
    local ambiguous = false
    for _, entry in ipairs(self.pending) do
        local score = DirectCandidateScore(self, entry, key, school, now,
            self.amountNow, self.critNow)
        if score and score <= bestScore + DIRECT_MATCH_MARGIN
            and (entry.ambiguous or entry.targetUncertain
                or not SameIdentity(entry, best)) then
            ambiguous = true
        end
    end
    return best, bestScore, ambiguous
end

local function QuarantineDirect(entry)
    entry.ambiguous = true
    entry.cast.ambiguous = true
    if entry.dot and not entry.dot.period then
        entry.dot.ambiguousDirect = true
    end
end

local function AmbiguousDirectResult(self, key, school, now, bestScore)
    local owner, mixedOwners
    for _, entry in ipairs(self.pending) do
        local score = DirectCandidateScore(self, entry, key, school, now,
            self.amountNow, self.critNow)
        if score and score <= bestScore + DIRECT_MATCH_MARGIN then
            if owner and owner ~= entry.caster then mixedOwners = true end
            owner = owner or entry.caster
            if self.lineNow == true then
                -- Retain possible casts for ownership checks, but don't let a
                -- later fallback name or learn the spell from this ambiguity.
                QuarantineDirect(entry)
            end
        end
    end
    return AmbiguousResult(self, owner, mixedOwners, false)
end

-- A recipient can be settled only from a report the cast could produce.
-- A projectile cannot corroborate a recipient in its own cast frame.
function Mine:CanSettle(cast, key, kind, school, now)
    local facts = self.facts(cast.spell)
    if type(facts) == "table" and facts.travels then return false end
    for _, entry in ipairs(self.pending) do
        if entry.cast == cast and not entry.used
            and (kind == "miss" or DirectCandidateScore(self, entry, key, school, now)) then
            return true
        end
    end
    return false
end

function Mine:Settle(cast, key)
    cast.key, cast.targetUncertain, cast.candidates = key, false, nil
    for _, list in ipairs({ self.pending, self.dots }) do
        for _, entry in ipairs(list) do
            if entry.cast == cast then
                entry.key, entry.targetUncertain = key, false
            end
        end
    end
end

local function RememberAmount(self, spell)
    local amount = self.amountNow
    if self.lineNow ~= true or self.ambiguous or type(amount) ~= "number" or amount <= 0 then return end
    local seen = self.amounts[spell] or { n = 0 }
    self.amounts[spell] = seen
    if not seen[amount] and seen.n < 24 then seen[amount], seen.n = true, seen.n + 1 end
end

local function Ticked(self, dot, school, now)
    dot.bufferUntil = nil
    SpendPeriodic(dot.cast, dot.key, now)
    dot.ticks, dot.next, dot.skipped = dot.ticks + 1, now + dot.period, 0
    RememberAmount(self, dot.spell)
    if school and not dot.school then dot.school = school end
    if not dot.known and dot.ticks >= 2 and not self.ambiguous then
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

local function TickPeriod(dot, now, confirmed)
    if dot.period then
        if dot.next and math.abs(now - dot.next) <= TICK_SLACK then return dot.period end
        return nil
    end
    if not confirmed and dot.pending and not dot.pending.used
        and dot.pending.school == nil and now - dot.pending.at <= FIRST_HIT_WAIT then return nil end
    local candidate = dot.candidate
    if candidate and math.abs(now - candidate.at - candidate.period) <= TICK_SLACK then return candidate.period end
    return FirstTick(dot, now)
end

-- Typed periodic lines can recover a cast even when its tooltip is unavailable
-- or a learned school/kind/interval is stale. Fitting never changes the tracker.
local function PeriodicCandidate(self, key, school, now, amount, leech,
    visit, includeReserved)
    local best, bestScore
    local candidates = {}
    local dueDot, unknownDot, drainingDotScore = false, false, nil
    local function Consider(spell, cast, dot)
        local source = cast or (dot and dot.cast)
        if source and ApplicationFailed(self, spell, source, key) then return end
        local at = dot and dot.castAt or cast.at
        local since = now - at
        if since < 0.5 or (not dot and since > CAST_HISTORY_WINDOW) then return end
        if dot and dot.confirmedAt and now - dot.confirmedAt < 0.5 then return end
        local facts = self.facts(spell)
        if type(facts) == "table" then
            if facts.damages == false or facts.helpful or facts.healthCost
                or facts.ticks == false or not SchoolFits(facts.school, school) then return end
            if PeriodicExpired(facts, at, now, source) then return end
        end
        local known = dot and dot.school or self.learned("school", spell)
        local period = dot and dot.period or self.learned("period", spell)
        local interval = type(facts) == "table" and facts.period or period
        if not includeReserved
            and not PeriodicAvailable(source, key, now, interval) then return end
        local score = AmountFit(self, spell, amount, period)
        local drains = type(facts) == "table" and facts.leech == true
        if leech ~= nil and drains ~= leech then score = score + 1 end
        local onBeat = dot and dot.next
            and math.abs(now - dot.next) <= TICK_SLACK
        if type(facts) == "table" and facts.period and not onBeat then
            -- Public catalog timing cannot be retaught by another report.
            local offset = since % facts.period
            if dot or math.min(offset, facts.period - offset) > TICK_SLACK then
                return
            end
        end
        if onBeat then
            dueDot = true
            score = score + math.abs(now - dot.next) / TICK_SLACK * 0.3
        else
            if dot and not dot.period then unknownDot = true end
            score = score + 0.8
        end
        if not SchoolFits(known, school) then score = score + 2 end
        if self.learned("direct", spell) == DIRECT_ONLY then score = score + 1 end
        if onBeat and drains then
            drainingDotScore = math.min(drainingDotScore or math.huge, score)
        end
        local candidate = { spell = spell, cast = cast, dot = dot,
            caster = (dot or cast).caster, score = score,
            targetUncertain = (dot or cast).targetUncertain }
        candidates[#candidates + 1] = candidate
        if visit then visit(candidate) end
        if not bestScore or score < bestScore then
            best, bestScore = candidate, score
        end
    end
    for _, dot in ipairs(self.dots) do
        if dot.key == key or dot.targetUncertain then
            Consider(dot.spell, nil, dot)
        end
    end
    for spell, casts in pairs(self.casts) do
        local seen = {}
        for index = #casts, 1, -1 do
            local cast = casts[index]
            local target = cast.key or false
            if (cast.key == key or cast.targetUncertain
                or TargetApplied(cast, key)) and not seen[target] then
                seen[target] = true
                local tracked = false
                for _, dot in ipairs(self.dots) do
                    if dot.cast == cast then
                        tracked = true
                        break
                    end
                end
                if not tracked then Consider(spell, cast, nil) end
            end
        end
    end
    -- A heal may identify a drain channel, but Siphon Life also heals:
    -- keep a due draining DoT unless the channel's amount fits clearly better.
    -- Other channels follow due or not-yet-timed DoTs.
    local channelBest, channelScore
    local channelCandidates = {}
    for _, channel in pairs(self.channels) do
        local facts = self.facts(channel.spell)
        local drains = type(facts) == "table" and facts.leech == true
        local ticks = type(facts) == "table" and facts.ticks == true
        local healedChannel = drains and leech == true
        local fallback = not dueDot and not unknownDot
            and (drains or leech ~= true)
        if (ticks or drains) and ChannelFits(channel, key, school, now)
            and (healedChannel or fallback) then
            local score = AmountFit(self, channel.spell, amount, facts.period)
            if not drainingDotScore or score < drainingDotScore - 0.1 then
                local candidate = { channel = channel, spell = channel.spell,
                    caster = channel.caster, score = score,
                    targetUncertain = channel.targetUncertain }
                channelCandidates[#channelCandidates + 1] = candidate
                if visit then visit(candidate) end
                if not channelScore or score < channelScore then
                    channelBest, channelScore = candidate, score
                end
            end
        end
    end
    if channelBest then
        best, bestScore, candidates = channelBest, channelScore, channelCandidates
    end
    if not best then return nil end
    local ambiguous, mixedOwners = best.targetUncertain == true, false
    for _, candidate in ipairs(candidates) do
        if candidate.score <= bestScore + DIRECT_MATCH_MARGIN then
            if candidate.targetUncertain or not SameIdentity(candidate, best) then
                ambiguous = true
            end
            if candidate.caster ~= best.caster then mixedOwners = true end
        end
    end
    return best, bestScore, ambiguous and 2 or 1, mixedOwners
end

local function ConfirmTick(self, candidate, key, school, now)
    local dot = candidate.dot
    if not dot then
        local cast = candidate.cast
        local facts = self.facts(candidate.spell)
        local period = type(facts) == "table" and facts.period or nil
        dot = { caster = cast.caster, spell = candidate.spell, key = key, castAt = cast.at,
            ticks = 0, direct = cast.direct, cast = cast, period = period,
            known = period ~= nil }
        self.dots[#self.dots + 1] = dot
        for _, entry in ipairs(self.pending) do
            if entry.spell == dot.spell and entry.at == dot.castAt and entry.key == key then
                entry.used = true
            end
        end
    end
    dot.key = key
    if dot.pending then dot.pending.used = true end
    local previous, previousSchool = dot.confirmedAt, dot.confirmedSchool
    dot.confirmedAt, dot.confirmedSchool = now, school
    if school then dot.school = school end
    if previous then
        local gap = now - previous
        local skipped = dot.period and math.floor(gap / dot.period + 0.5)
        local facts = self.facts(dot.spell)
        local catalogued = type(facts) == "table" and facts.period ~= nil
        if not catalogued and not (skipped and skipped > 1 and math.abs(gap - skipped * dot.period) <= TICK_SLACK) then
            dot.period = gap
        end
        dot.known = catalogued
        if not catalogued and dot.cast and not dot.cast.periodicAt then
            dot.cast.periodicAt = previous - dot.period
        end
        if not catalogued and not self.ambiguous and school
            and school == previousSchool then LearnSchool(self, dot.spell, school) end
        return Ticked(self, dot, school, now)
    end
    -- Anchor on the actual impact; flight time must not become the interval.
    SpendPeriodic(dot.cast, key, now)
    dot.ticks = dot.ticks + 1
    dot.next = dot.period and now + dot.period or nil
    dot.skipped, dot.bufferUntil = 0, nil
    RememberAmount(self, dot.spell)
    return Result(dot.caster, dot.spell, true, { dot = dot })
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
-- Whether a miss on key can be this spell's answer. A spell that cannot be
-- dodged, parried or blocked (Spells.lua, SpellCanAvoid) never takes one;
-- and a magic spell without direct-spell confirmation never takes a plain
-- miss while your pet attacks that unit or a swing or shot could have missed.
-- Those are likelier (Hunter's Mark had shown your pet's parries and your Auto
-- Shot's misses as its own).
local function PhysicalSourceNear(self, key, now, pet)
    if pet then return true end
    for _, swing in ipairs(self.swings) do
        local since = now - swing.at
        if not swing.used and swing.key == key and since >= 0 and since <= SwingWindow(swing, self.lineNow) then
            return true
        end
    end
    return false
end
local function PeriodicApplicationConfirmed(self, spell, cast, key, now)
    local facts = self.facts(spell)
    if type(facts) ~= "table" or facts.direct ~= false
        or facts.ticks ~= true then return false end
    for _, dot in ipairs(self.dots) do
        if dot.cast == cast and dot.key == key and dot.confirmedAt
            and dot.confirmedAt <= now then return true end
    end
    return false
end

local function CastTakesMiss(self, spell, cast, key, now, avoid, pet, restrict)
    if PeriodicApplicationConfirmed(self, spell, cast, key, now) then
        return false
    end
    if not avoid then return true end
    if ns.SpellCanAvoid and not ns.SpellCanAvoid(spell, avoid) then return false end
    if restrict ~= "direct" and avoid == "MISS"
        and ns.SpellReach and ns.SpellReach(spell) == "spell"
        and PhysicalSourceNear(self, key, now, pet) then
        return false
    end
    return true
end

local function MatchDirectMiss(self, key, now)
    local best, ambiguous, mixedOwners, refused
    for spell, casts in pairs(self.casts) do
        local facts = self.facts(spell)
        local helpful = type(facts) == "table"
            and (facts.helpful == true or facts.healthCost ~= nil)
        for _, cast in ipairs(casts) do
            if not helpful and DirectAvailable(self, spell, cast, key, now, true) then
                if CastTakesMiss(self, spell, cast, key, now, self.avoidNow,
                    self.petNow, self.restrictNow) then
                    local candidate = { spell = spell, caster = cast.caster,
                        cast = cast }
                    if best and not SameIdentity(best, candidate) then
                        ambiguous = true
                        if best.caster ~= candidate.caster then
                            mixedOwners = true
                        end
                    end
                    if cast.ambiguous or cast.targetUncertain then
                        ambiguous = true
                    end
                    if not best or (SameIdentity(best, candidate)
                        and cast.at < best.cast.at) then best = candidate end
                else
                    refused = refused or cast.caster
                end
            end
        end
    end
    if best then
        if ambiguous then
            return AmbiguousResult(self, best.caster, mixedOwners, false, true)
        end
        SpendDirect(self, best.spell, best.cast, key, true)
        return Result(best.caster, best.spell, false, { missed = true })
    end
    if refused and self.restrictNow == "direct" then
        return Result(refused, nil, false, { missed = true })
    end
end

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
    if kind == "damage" and sure then
        local candidate, _, count, mixedOwners = PeriodicCandidate(self, key, school, now,
            self.amountNow, self.leechNow)
        if candidate then
            if count > 1 then
                return AmbiguousResult(self, candidate.caster, mixedOwners, true)
            end
            if candidate.channel then
                local channel = candidate.channel
                RememberAmount(self, channel.spell)
                return Result(channel.caster, channel.spell, true)
            end
            return ConfirmTick(self, candidate, key, school, now)
        end
        return nil
    end
    if kind == "damage" and allowed.casts then
        local best, bestScore, ambiguous, mixedOwners
        for _, channel in pairs(self.channels) do
            if ChannelFits(channel, key, school, now) then
                local score = DirectFit(self, channel.spell,
                    self.amountNow, self.critNow)
                if not bestScore or score < bestScore then
                    best, bestScore = channel, score
                end
            end
        end
        if best then
            for _, channel in pairs(self.channels) do
                if ChannelFits(channel, key, school, now)
                    and DirectFit(self, channel.spell, self.amountNow,
                        self.critNow) <= bestScore + DIRECT_MATCH_MARGIN then
                    if channel.targetUncertain
                        or not SameIdentity(best, channel) then ambiguous = true end
                    if best.caster ~= channel.caster then mixedOwners = true end
                end
            end
            local direct, directScore = SelectDirectCandidate(self, key, school, now)
            if direct and directScore < bestScore - DIRECT_MATCH_MARGIN then
                best = nil
            elseif direct and directScore <= bestScore + DIRECT_MATCH_MARGIN then
                if not SameIdentity(best, direct) or direct.targetUncertain then
                    ambiguous = true
                end
                if best.caster ~= direct.caster then mixedOwners = true end
            end
        end
        if best then
            if ambiguous then
                return AmbiguousResult(self, best.caster, mixedOwners, sure)
            end
            return Result(best.caster, best.spell, sure)
        end
    end
    -- 1. A DoT's next tick; of several due now, the one whose time and
    -- amount fit best. 0.3.49: a tick that healed you for its amount in the
    -- same moment (leechNow, from the reader) is a draining DoT's, one that
    -- did not is not (a Drain Life tick and a Corruption tick 0.1 s apart had
    -- swapped icons, 1.60.1.70374).
    local function DueTick()
        if kind == "miss" or not allowed.ticks then return nil end
        local best, bestScore
        local candidates = {}
        for _, dot in ipairs(self.dots) do
            if dot.key == key and dot.period and dot.next and SchoolFits(dot.school, school)
                and PeriodicAvailable(dot.cast, key, now, dot.period)
                and math.abs(now - dot.next) <= TICK_SLACK then
                local score = math.abs(now - dot.next) / TICK_SLACK * 0.3 + AmountFit(self, dot.spell, self.amountNow, dot.period)
                if self.leechNow ~= nil and Leeches(self, dot.spell) ~= self.leechNow then score = score + 1 end
                candidates[#candidates + 1] = { dot = dot, score = score }
                if not bestScore or score < bestScore then best, bestScore = dot, score end
            end
        end
        if best then
            local ambiguous, mixedOwners = best.targetUncertain, false
            for _, candidate in ipairs(candidates) do
                if candidate.score <= bestScore + DIRECT_MATCH_MARGIN then
                    if not SameIdentity(best, candidate.dot)
                        or candidate.dot.targetUncertain then ambiguous = true end
                    if candidate.dot.caster ~= best.caster then
                        mixedOwners = true
                    end
                end
            end
            if ambiguous then
                return AmbiguousResult(self, best.caster, mixedOwners, true)
            end
            return Ticked(self, best, school, now)
        end
    end
    -- 0.3.49: a spell hit's line (restrict "direct") tries your and your
    -- pet's casts in flight first, and a DoT due in that moment after them
    -- (a Succubus's Lash of Pain had gone to a Drain Life tick due then).
    local castsFirst = self.restrictNow == "direct"
    if not castsFirst then
        local tick = DueTick()
        if tick then return tick end
    end
    -- 2. Compare direct casts together; a miss has no readable amount that
    -- can distinguish overlapping spell identities.
    local exact, unknown
    local directScore, directAmbiguous
    if kind == "damage" and allowed.casts then
        local candidate
        candidate, directScore, directAmbiguous =
            SelectDirectCandidate(self, key, school, now)
        if candidate and candidate.school then exact = candidate
        else unknown = candidate end
    end
    if kind == "miss" and allowed.casts then
        local result = MatchDirectMiss(self, key, now)
        if result then return result end
    end
    local function Direct(entry)
        if directAmbiguous then
            return AmbiguousDirectResult(self, key, school, now, directScore)
        end
        SpendDirect(self, entry.spell, entry.cast, key, kind == "miss")
        if entry.dot and kind ~= "miss" then
            entry.dot.direct, entry.dot.directAt = true, now
        end
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
            if dot.key == key and not dot.period and not dot.confirmedAt
                and not waiting
                and PeriodicAvailable(dot.cast, key, now)
                and not dot.ambiguousDirect and SchoolFits(dot.school, school) then
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
    -- 4. Unknown-school candidates use the same comparison after known ticks.
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
                and not (ranged and self.avoidNow == "PARRY")
                and (ranged and allowed.ranged or not ranged and allowed.melee)
                and (kind == "miss" or (ranged and since >= 0.1 and not DotDue(self, school, now)
                        and SchoolFits(self.wandSchool, school))
                    or (not ranged and SchoolFits(PHYSICAL, school))) then
                swing.used = true
                if self.accountingEnabled == true or self.inferredWindfuryEnabled == true then
                    self.lastOutcomeReceipt = {
                        kind = "swing", at = swing.at, key = swing.key,
                        hand = swing.hand, who = "you", ordinal = 1,
                    }
                end
                -- 0.6.2: the delay of a melee hit paired by its swing's line. One
                -- paired before its swing's time (SwingsBefore, stray) teaches
                -- nothing: it would open the window to everyone's hits.
                local usualEarly, usualLate = self:MeleeWindow(swing.hand)
                if paired and not ranged and since >= usualEarly and since <= usualLate then
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
    -- Channel hits need the same cross-frame line pairing as bolts.
    for _, channel in pairs(self.channels) do
        if ChannelFits(channel, key, school, now) then return true end
    end
    for _, entry in ipairs(self.pending) do
        local since = now - entry.at
        if not entry.used and not entry.missOnly and entry.key == key and since >= FLIGHT_MIN
            and DirectAvailable(self, entry.spell, entry.cast, key, now)
            and SchoolFits(entry.school, school) then
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
function Mine:Fit(key, kind, school, now, amount, restrict, crit, avoid, pet)
    if kind == "damage" and restrict == "tick" then
        local score = self:TickFit(key, school, now, amount)
        return score
    end
    local best
    -- A damage shield's line fits any hit on an enemy (0.3.49).
    if restrict == "shield" then return (kind == "damage" or kind == "miss") and 0.7 or nil end
    local allowed = Allowed(restrict)
    local function Take(score) if not best or score < best then best = score end end
    if kind == "damage" and allowed.casts then
        for _, channel in pairs(self.channels) do
            if ChannelFits(channel, key, school, now) then Take(0.1) end
        end
    end
    for _, entry in ipairs(allowed.casts and self.pending or {}) do
        if not entry.used and entry.key == key
            and DirectAvailable(self, entry.spell, entry.cast, key, now) then
            if kind == "miss" then
                if CastTakesMiss(self, entry.spell, entry.cast, key, now,
                    avoid, pet, restrict) then Take(0.5)
                -- A spell's miss line still makes the miss yours (Hit).
                elseif restrict == "direct" then Take(0.9) end
            else
                local score = DirectCandidateScore(self, entry, key, school,
                    now, amount, crit)
                if score then Take(0.3 + score) end
            end
        end
    end
    if kind == "miss" and restrict == "tick" then
        for _, dot in ipairs(self.dots) do
            if dot.key == key then Take(0.5) end
        end
    end
    if kind ~= "miss" and allowed.ticks then
        for _, dot in ipairs(self.dots) do
            if dot.key == key and SchoolFits(dot.school, school) then
                local period = TickPeriod(dot, now, restrict == "tick")
                if period and PeriodicAvailable(dot.cast, key, now, period) then
                    Take((dot.period and 0 or 0.4) + AmountFit(self, dot.spell, amount, dot.period))
                end
            end
        end
        if DotDue(self, school, now) then Take(0.9) end
    end
    for _, swing in ipairs(self.swings) do
        if not swing.used and swing.key == key then
            local since = now - swing.at
            if swing.hand == "ranged" then
                if allowed.ranged and not (kind == "miss" and avoid == "PARRY")
                    and since >= 0.1 and since <= RANGED_WINDOW
                    and SchoolFits(self.wandSchool, school) then Take(0.6) end
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
            if known and SchoolFits(known, school)
                and harmful and not ticksOnly then
                for _, cast in ipairs(list) do
                    if cast.caster == "you"
                        and DirectAvailable(self, spell, cast, key, now, true) then
                        Take(1 + DirectFit(self, spell, amount, nil))
                    end
                end
            end
        end
    end
    return best
end

-- A hit known to be yours (its line came) that nothing else placed: the
-- spell of yours whose evidence fits it best. Periodic effects may follow
-- another unit; direct hits stay target-bound outside the area-impact window
-- (0.3.9: DoTs cast while another enemy was targeted, or followed under a
-- plate that went before their rhythm was known). Over the last 30 seconds,
-- a spell of the hit's school that ticks scores how far the hit is from a
-- whole number of its intervals after the cast; direct hits use readable
-- damage and timing within DIRECT_WINDOW. Unknown intervals score
-- after known ones; nil when no cast fits.
-- restrict "tick" (0.3.48, its line says so): only a spell that ticks.
local function HistoricalFit(self, spell, cast, school, now, restrict, key,
    includeAmbiguous)
    local age = now - cast.at
    if age < 0 or age > CAST_HISTORY_WINDOW
        or (cast.ambiguous and not includeAmbiguous) then return nil end
    local facts = self.facts(spell)
    local known = (type(facts) == "table" and facts.school)
        or self.learned("school", spell)
    if not SchoolFits(known, school) then return nil end
    if type(facts) == "table"
        and (facts.damages == false or facts.helpful == true) then return nil end
    if cast.targetUncertain then return nil end

    if restrict == "direct" and type(facts) == "table"
        and facts.direct == false and facts.ticks == true then return nil end

    local kind = SpellKind(facts, self.learned("direct", spell))
    local period = (type(facts) == "table" and facts.period)
        or self.learned("period", spell)
    local score, directSelected
    if kind ~= DIRECT_ONLY and period and age >= period - TICK_SLACK
        and restrict ~= "direct"
        and (cast.key == key or TargetApplied(cast, key))
        and PeriodicAvailable(cast, key, now, period)
        and not PeriodicExpired(facts, cast.at, now, cast)
        and not ApplicationFailed(self, spell, cast, key) then
        -- Keep the periodic fallback's established rhythm/amount behavior.
        local offset = age % period
        offset = math.min(offset, period - offset)
        if not (type(facts) == "table" and facts.period)
            or offset <= TICK_SLACK then
            score = AmountFit(self, spell, self.amountNow, period)
                + math.min(offset, 1) * 0.1
        end
    end
    if kind ~= TICKS_ONLY and restrict ~= "tick"
        and DirectAvailable(self, spell, cast, key, now, true) then
        local direct = 0.5 + DirectFit(self, spell, self.amountNow, self.critNow)
            + age / DirectWindow(self, spell) * DIRECT_TIME_WEIGHT
        if not score or direct < score then score, directSelected = direct, true end
    end
    local tick = restrict == "tick"
        or (kind ~= DIRECT_ONLY and age > DIRECT_WINDOW)
    return score, tick, directSelected
end

-- Test both schools before spending either outcome in a mixed frame.
function Mine:MixedFrameDirectSchool(key, firstSchool, secondSchool, now)
    for _, channel in pairs(self.channels) do
        if ChannelFits(channel, key, firstSchool, now)
            or ChannelFits(channel, key, secondSchool, now) then return nil end
    end

    local candidate
    for _, entry in ipairs(self.pending) do
        if DirectCandidateScore(self, entry, key, firstSchool, now)
            or DirectCandidateScore(self, entry, key, secondSchool, now) then
            if candidate then return nil end
            candidate = entry
        end
    end
    if not candidate or candidate.at ~= now or candidate.caster ~= "you"
        or candidate.targetUncertain or candidate.ambiguous
        or candidate.cast.ambiguous then return nil end
    local facts = self.facts(candidate.spell)
    if not facts or facts.direct ~= true or facts.area or facts.nextSwing
        or (facts.directHits or 1) ~= 1 or candidate.school ~= facts.school
        or (facts.school ~= firstSchool and facts.school ~= secondSchool) then
        return nil
    end

    -- History also holds casts with no pending entry for this target.
    for spell, casts in pairs(self.casts) do
        for _, cast in ipairs(casts) do
            if cast ~= candidate.cast then
                local _, _, first = HistoricalFit(
                    self, spell, cast, firstSchool, now, "direct", key, true)
                if first then return nil end
                local _, _, second = HistoricalFit(
                    self, spell, cast, secondSchool, now, "direct", key, true)
                if second then return nil end
            end
        end
    end
    return facts.school
end

-- A battleground spell line can identify a cast while its target stays hidden.
local function ConfirmUntargetedDirect(self, key, school, now)
    if not school or self.petOut then return nil end
    for _, channel in pairs(self.channels) do
        if ChannelFits(channel, key, school, now) then return nil end
    end

    local candidate
    for _, entry in ipairs(self.pending) do
        -- A spell line can come from an impact outside the selected target.
        if DirectCandidateScore(self, entry, entry.key or key, school, now) then
            if candidate then return nil end
            candidate = entry
        end
    end
    if not candidate or candidate.at > now or candidate.caster ~= "you"
        or not candidate.targetUncertain or candidate.key or candidate.cast.candidates
        or candidate.ambiguous or candidate.cast.ambiguous then return nil end
    local facts = self.facts(candidate.spell)
    if not facts or facts.direct ~= true or facts.ticks ~= false
        or facts.school ~= school or facts.area or facts.nextSwing or facts.shot
        or (facts.directHits or 1) ~= 1
        or (self.leechNow == true and not facts.leech) then return nil end

    for spell, casts in pairs(self.casts) do
        for _, cast in ipairs(casts) do
            if cast ~= candidate.cast then
                local _, _, direct = HistoricalFit(
                    self, spell, cast, school, now, "direct", key, true)
                if direct then return nil end
            end
        end
    end

    SpendDirect(self, candidate.spell, candidate.cast, nil, false)
    return Result("you", candidate.spell, false)
end

function Mine:Likeliest(school, now, restrict, key)
    local bestSpell, bestCast, bestScore, bestTick, bestDirect
    for spell, casts in pairs(self.casts) do
        for _, cast in ipairs(casts) do
            local score, tick, direct =
                HistoricalFit(self, spell, cast, school, now, restrict, key)
            if score and (not bestScore or score < bestScore) then
                bestSpell, bestCast, bestScore = spell, cast, score
                bestTick, bestDirect = tick, direct
            end
        end
    end
    if not bestCast then return nil end

    -- History must not put a speculative name back onto an ambiguous area hit.
    do
        local ambiguous, mixedOwners = false, false
        for spell, casts in pairs(self.casts) do
            for _, cast in ipairs(casts) do
                local score, _, direct =
                    HistoricalFit(self, spell, cast, school, now, restrict, key)
                if score and direct == bestDirect
                    and score <= bestScore + DIRECT_MATCH_MARGIN
                    and (spell ~= bestSpell or cast.caster ~= bestCast.caster) then
                    ambiguous = true
                    if cast.caster ~= bestCast.caster then mixedOwners = true end
                end
            end
        end
        if ambiguous then
            local owner = self.lineNow == true and not mixedOwners
                and bestCast.caster or "unknown"
            return AmbiguousResult(self, owner, mixedOwners, bestTick)
        end
    end
    if bestDirect then SpendDirect(self, bestSpell, bestCast, key, false)
    else SpendPeriodic(bestCast, key, now) end
    return Result(bestCast.caster, bestSpell, bestTick, { likely = true })
end

-- All amounts in a mixed group may be owned while their spell and event-kind
-- pairing remains unknown. Reserve compatible evidence without teaching facts
-- or advancing a guessed rhythm, so a later fallback cannot reuse the group.
function Mine:ConfirmUnidentified(key, school, now)
    self.lastOutcomeReceipt = nil
    self.amountNow, self.critNow, self.lineNow = nil, false, true
    self.restrictNow, self.ambiguous = nil, true
    local owner, mixedOwners
    local function TakeOwner(caster)
        if owner and owner ~= caster then mixedOwners = true end
        owner = owner or caster
    end
    local periodic = {}
    PeriodicCandidate(self, key, school, now, nil, nil, function(candidate)
        periodic[#periodic + 1] = candidate
    end, true)
    for _, candidate in ipairs(periodic) do
        TakeOwner(candidate.caster)
        local cast = candidate.cast or (candidate.dot and candidate.dot.cast)
        SpendPeriodic(cast, key, now)
    end
    for _, channel in pairs(self.channels) do
        if ChannelFits(channel, key, school, now) then
            TakeOwner(channel.caster)
        end
    end
    for _, entry in ipairs(self.pending) do
        if DirectCandidateScore(self, entry, key, school, now, nil, false) then
            TakeOwner(entry.caster)
            QuarantineDirect(entry)
        end
    end
    -- Area impacts can have no pending entry for this target. Their cast
    -- history must receive the same quarantine as ordinary direct matching.
    for spell, casts in pairs(self.casts) do
        for _, cast in ipairs(casts) do
            local _, _, direct =
                HistoricalFit(self, spell, cast, school, now, "direct", key, true)
            if direct then
                TakeOwner(cast.caster)
                cast.ambiguous = true
            end
        end
    end
    return AmbiguousResult(self, owner or "you", mixedOwners, false)
end

-- Read-only fit for a tick on this unit, including the first tick. A typed
-- periodic confirmation may bypass an unknown cast's wait for a direct hit.
function Mine:TickFit(key, school, now, amount, leech)
    local candidate, score =
        PeriodicCandidate(self, key, school, now, amount, leech)
    local dot = candidate and candidate.dot
    return score, dot and dot.next and math.abs(now - dot.next) <= TICK_SLACK
end

-- A lost creature may still produce your periodic line. This evidence may
-- reject an unrelated visible report, but can never provide its identity.
function Mine:OffscreenTickFit(key, school, now, reportedKeys)
    for _, channels in ipairs({ self.channels, self.retiredChannels }) do
        for _, channel in pairs(channels) do
            local represented = channels == self.channels
                and not channel.targetUncertain
                and reportedKeys and reportedKeys[channel.key]
            if (channel.key ~= key or channel.targetUncertain)
                and not represented
                and ChannelFits(channel, channel.key, school, now) then
                return true
            end
        end
    end
    for _, list in ipairs({ self.dots, self.retiredDots }) do
        for _, dot in ipairs(list) do
            local facts = self.facts(dot.spell)
            local hasDuration = type(facts) == "table" and facts.duration ~= nil
            local represented = list == self.dots and not dot.targetUncertain
                and reportedKeys and reportedKeys[dot.key]
            if (dot.key ~= key or dot.targetUncertain) and not represented
                and SchoolFits(dot.school, school)
                and now >= dot.castAt
                and (list == self.dots or hasDuration
                    or now - dot.castAt <= CAST_HISTORY_WINDOW)
                and not PeriodicExpired(facts, dot.castAt, now, dot.cast) then
                if not dot.period then return true end
                local anchor = dot.next or (dot.castAt + dot.period)
                local offset = (now - anchor) % dot.period
                if math.min(offset, dot.period - offset) <= TICK_SLACK then
                    return true
                end
            end
        end
    end
    return false
end

function Mine:BufferTicks(key, school, at, untilTime)
    for _, dot in ipairs(self.dots) do
        if (dot.key == key or dot.key == false) and dot.period and dot.next
            and SchoolFits(dot.school, school) and math.abs(at - dot.next) <= TICK_SLACK then
            dot.bufferUntil = math.max(dot.bufferUntil or 0, untilTime + TICK_SLACK)
        end
    end
end

-- A hit (kind "damage" or "heal") or a miss (kind "miss") on the unit keyed
-- key; school is its school mask or nil when unreadable. petAttacking: your
-- pet is attacking that unit now. amount and crit: the hit's, when readable.
-- Returns who made it: { who = "you" | "pet"
-- | "unknown", spell, tick, melee, missed }. An unknown damage or miss is held
-- (hold = true, held = its entry) for a swing reported a moment later.
-- restrict (0.3.48): what made it, from its line's colour (Allowed, above).
-- leech (0.3.49): true when a heal on you of the hit's amount came in its
-- moment, false when heals on you were read and none matched, nil unknown.
-- avoid: the game's word for a miss ("PARRY", "DODGE", "MISS", ...), nil unknown.
function Mine:Hit(key, kind, school, now, petAttacking, line, amount, crit,
    restrict, leech, avoid, isolatedBattlegroundSpell)
    self.lastOutcomeReceipt = nil
    self:Tidy(now)
    self.amountNow, self.lineNow, self.ambiguous, self.critNow = amount, line, false, crit == true
    -- Which avoid a miss was, and whether your pet attacks its unit (CastTakesMiss).
    self.avoidNow, self.petNow = kind == "miss" and avoid or nil, petAttacking == true
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
    if isolatedBattlegroundSpell and self.restrictNow == "direct" then
        local result = ConfirmUntargetedDirect(self, key, school, now)
        if result then return result end
    end
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
        local candidate, _, count, mixedOwners =
            PeriodicCandidate(self, key, nil, now, nil, nil)
        if candidate then
            if count > 1 then
                return AmbiguousResult(self, candidate.caster, mixedOwners,
                    true, true)
            end
            local dot = candidate.dot
            if dot and dot.next and math.abs(now - dot.next) <= TICK_SLACK then
                dot.next, dot.skipped = now + dot.period, 0
            end
            SpendPeriodic(candidate.cast or (dot and dot.cast), key, now)
            return Result(candidate.caster, candidate.spell, true,
                { missed = true })
        end
        return Result("you", nil, true, { missed = true })
    end
    if line == true and kind == "miss" and allowed.casts then
        local result = MatchDirectMiss(self, key, now)
        if result then return result end
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
    if line == true and kind == "damage" and allowed.ticks then
        local guess = self:Likeliest(school, now, self.restrictNow, key)
        -- A hit that healed you is a drain's: never a spell that does not drain.
        if guess and not (self.leechNow == true and not Leeches(self, guess.spell)) then return guess end
        self.lastOutcomeReceipt = nil
    end
    -- 0.3.49: a hit of yours (its line came) that healed you for its amount
    -- and that nothing above placed is a drain no cast of yours explains:
    -- the Undead's Touch of the Grave on Forever, landing as you cast. Yours;
    -- from 0.3.51 marked as a drain, so the router gives it its own icon.
    if line == true and kind == "damage" and self.leechNow == true and allowed.casts then
        return Result("you", nil, false, { proc = true, drain = true })
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
    -- An untyped line cannot override a rejected avoid, and a ranged attack
    -- cannot be parried. Typed spell misses still establish ownership even
    -- when no cast supplies a safe identity.
    local incompatibleMiss = kind == "miss"
        and (self.restrictNow == nil
            or (self.restrictNow == "shot" and avoid == "PARRY"))
    if line == true and not incompatibleMiss then
        return Result("you", nil, self.restrictNow == "tick",
            { missed = kind == "miss" })
    end
    local result = Result("unknown", nil, tick)
    if line ~= false and (kind == "miss" or kind == "damage") then
        local held = { key = key, kind = kind, school = school, at = now }
        self.held[#self.held + 1] = held
        result.hold, result.held = true, held
    end
    return result
end

-- The DoTs the engine is following, for the tests.
function Mine:Dots() return self.dots end
