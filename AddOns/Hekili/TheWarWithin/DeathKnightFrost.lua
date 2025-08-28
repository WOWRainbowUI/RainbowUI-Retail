-- DeathKnightFrost.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end


local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 251 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, min, sqrt = math.abs, math.ceil, math.floor, math.max, math.min, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell
local NewTimer = C_Timer.NewTimer

-- Specialization-specific local functions (if any)

spec:RegisterResource( Enum.PowerType.Runes, {
    rune_regen = {
        last = function () return state.query_time end,
        stop = function( x ) return x == 6 end,

        interval = function( time, val )
            val = floor( val )
            if val == 6 then return -1 end
            return state.runes.expiry[ val + 1 ] - time
        end,
        value = 1,
    },

}, setmetatable( {
    expiry = { 0, 0, 0, 0, 0, 0 },
    cooldown = 10,
    regen = 0,
    max = 6,
    forecast = {},
    fcount = 0,
    times = {},
    values = {},
    resource = "runes",

    reset = function()
        local t = state.runes
        for i = 1, 6 do
            local start, duration, ready = GetRuneCooldown( i )
            start = start or 0
            duration = duration or ( 10 * state.haste )
            t.expiry[ i ] = ready and 0 or ( start + duration )
            t.cooldown = duration
        end
        table.sort( t.expiry )
        t.actual = nil -- Reset actual to force recalculation
    end,

    gain = function( amount )
        local t = state.runes
        for i = 1, amount do
            table.insert( t.expiry, 0 )
            t.expiry[ 7 ] = nil
        end
        table.sort( t.expiry )
        t.actual = nil
    end,

    spend = function( amount )
        local t = state.runes
        for i = 1, amount do
            local nextReady = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
            table.remove( t.expiry, 1 )
            table.insert( t.expiry, nextReady )
        end

        state.gain( amount * 10, "runic_power" )

        if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
            state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.runes, x )
    end,
}, {
    __index = function( t, k )
        if k == "actual" then
            -- Calculate the number of runes available based on `expiry`.
            local amount = 0
            for i = 1, 6 do
                if t.expiry[ i ] <= state.query_time then
                    amount = amount + 1
                end
            end
            return amount

        elseif k == "current" then
            -- If this is a modeled resource, use our lookup system.
            if t.forecast and t.fcount > 0 then
                local q = state.query_time
                local index, slice

                if t.values[ q ] then return t.values[ q ] end

                for i = 1, t.fcount do
                    local v = t.forecast[ i ]
                    if v.t <= q and v.v ~= nil then
                        index = i
                        slice = v
                    else
                        break
                    end
                end

                -- We have a slice.
                if index and slice and slice.v then
                    t.values[ q ] = max( 0, min( t.max, slice.v ) )
                    return t.values[ q ]
                end
            end

            return t.actual

        elseif k == "deficit" then
            return t.max - t.current

        elseif k == "time_to_next" then
            return t[ "time_to_" .. t.current + 1 ]

        elseif k == "time_to_max" then
            return t.current == t.max and 0 or max( 0, t.expiry[ 6 ] - state.query_time )

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )
            if amount then return t.timeTo( amount ) end
        end
    end
}))

spec:RegisterResource( Enum.PowerType.RunicPower, {

    swarming_mist = {
        aura = "swarming_mist",

        last = function ()
            return state.buff.swarming_mist.applied + floor( state.query_time - state.buff.swarming_mist.applied )
        end,

        interval = 1,
        value = function () return min( 15, state.true_active_enemies * 3 ) end,
    },

} )

-- Talents
spec:RegisterTalents( {

    -- Death Knight
    antimagic_barrier              = {  76046,  205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by $s1 sec and increases its duration and amount absorbed by $s2%
    antimagic_zone                 = {  76065,   51052, 1 }, -- Places an Anti-Magic Zone for $s1 sec, reducing the magic damage taken by party or raid members by $s2%
    asphyxiate                     = {  76064,  221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $s1 sec
    assimilation                   = {  76048,  374383, 1 }, -- The cooldown of Anti-Magic Zone is reduced by $s1 sec and its duration is increased by $s2 sec
    blinding_sleet                 = {  76044,  207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for $s1 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by $s2% for $s3 sec
    blood_draw                     = {  76056,  374598, 1 }, -- When you fall below $s1% health you drain $s2 health from nearby enemies, the damage you take is reduced by $s3% and your Death Strike cost is reduced by $s4 for $s5 sec. Can only occur every $s6 min
    blood_scent                    = {  76078,  374030, 1 }, -- Increases Leech by $s1%
    brittle                        = {  76061,  374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal $s1% increased damage for $s2 sec
    cleaving_strikes               = {  76073,  316916, 1 }, -- Frostscythe deals $s1% increased damage during Remorseless Winter
    coldthirst                     = {  76083,  378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants $s1 Runic Power and reduces its cooldown by $s2 sec
    control_undead                 = {  76059,  111673, 1 }, -- Dominates the target undead creature up to level $s1, forcing it to do your bidding for $s2 min
    death_pact                     = {  76075,   48743, 1 }, -- Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s2% of your max health for $s3 sec
    death_strike                   = {  76071,   49998, 1 }, -- Focuses dark power into a strike with both weapons, that deals a total of $s$s2 Physical damage and heals you for $s3% of all damage taken in the last $s4 sec, minimum $s5% of maximum health
    deaths_echo                    = { 102007,  356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have $s1 additional charge
    deaths_reach                   = { 102006,  276079, 1 }, -- Increases the range of Death Grip by $s1 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip
    enfeeble                       = {  76060,  392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by $s1% and the damage they deal to you by $s2% for $s3 sec
    gloom_ward                     = {  76052,  391571, 1 }, -- Absorbs are $s1% more effective on you
    grip_of_the_dead               = {  76057,  273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by $s1%, decaying by $s2% every sec
    ice_prison                     = {  76086,  454786, 1 }, -- Chains of Ice now also roots enemies for $s1 sec but its cooldown is increased to $s2 sec
    icebound_fortitude             = {  76081,   48792, 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s1% for $s2 sec
    icy_talons                     = {  76085,  194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by $s1% for $s2 sec, stacking up to $s3 times
    improved_death_strike          = {  76067,  374277, 1 }, -- Death Strike's cost is reduced by $s1, and its healing is increased by $s2%
    insidious_chill                = {  76051,  391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by $s1% for $s2 sec, stacking up to $s3 times
    march_of_darkness              = {  76074,  391546, 1 }, -- Death's Advance grants an additional $s1% movement speed over the first $s2 sec
    mind_freeze                    = {  76084,   47528, 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $s1 sec
    null_magic                     = { 102008,  454842, 1 }, -- Magic damage taken is reduced by $s1% and the duration of harmful Magic effects against you are reduced by $s2%
    osmosis                        = {  76088,  454835, 1 }, -- Anti-Magic Shell increases healing received by $s1%
    permafrost                     = {  76066,  207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to $s1% of the damage dealt
    proliferating_chill            = { 101708,  373930, 1 }, -- Chains of Ice affects $s1 additional nearby enemy
    raise_dead                     = {  76072,   46585, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts $s1 min
    rune_mastery                   = {  76079,  374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by $s1% for $s2 sec
    runic_attenuation              = {  76045,  207104, 1 }, -- Auto attacks have a chance to generate $s1 Runic Power
    runic_protection               = {  76055,  454788, 1 }, -- Your chance to be critically struck is reduced by $s1% and your Armor is increased by $s2%
    sacrificial_pact               = {  76060,  327574, 1 }, -- Sacrifice your ghoul to deal $s$s2 Shadow damage to all nearby enemies and heal for $s3% of your maximum health. Deals reduced damage beyond $s4 targets
    soul_reaper                    = {  76063,  343294, 1 }, -- Strike an enemy for $s$s3 Shadowfrost damage and afflict the enemy with Soul Reaper. After $s4 sec, if the target is below $s5% health this effect will explode dealing an additional $s$s6 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption
    subduing_grasp                 = {  76080,  454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by $s1% for $s2 sec
    suppression                    = {  76087,  374049, 1 }, -- Damage taken from area of effect attacks reduced by $s1%. When suffering a loss of control effect, this bonus is increased by an additional $s2% for $s3 sec
    unholy_bond                    = {  76076,  374261, 1 }, -- Increases the effectiveness of your Runeforge effects by $s1%
    unholy_endurance               = {  76058,  389682, 1 }, -- Increases Lichborne duration by $s1 sec and while active damage taken is reduced by $s2%
    unholy_momentum                = {  76069,  374265, 1 }, -- Increases Haste by $s1%
    unyielding_will                = {  76050,  457574, 1 }, -- Anti-Magic Shell now removes all harmful magical effects when activated, but its cooldown is increased by $s1 sec
    vestigial_shell                = {  76053,  454851, 1 }, -- Casting Anti-Magic Shell grants $s2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to $s$s3 magic damage and reduces the duration of harmful Magic effects against them by $s4%
    veteran_of_the_third_war       = {  76068,   48263, 1 }, -- Stamina increased by $s1%
    will_of_the_necropolis         = {  76054,  206967, 2 }, -- Damage taken below $s1% Health is reduced by $s2%
    wraith_walk                    = {  76077,  212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $s2 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below $s3%

    -- Frost
    arctic_assault                 = {  76118,  456230, 1 }, -- Consuming Killing Machine fires a Glacial Advance through your target at $s1% effectiveness
    avalanche                      = {  76105,  207142, 1 }, -- Casting Howling Blast with Rime active causes jagged icicles to fall on enemies nearby your target, applying Razorice and dealing $s$s2 Frost damage
    biting_cold                    = {  76112,  377056, 1 }, -- Remorseless Winter damage is increased by $s1%. The first time Remorseless Winter deals damage to $s2 different enemies, you gain Rime
    bonegrinder                    = {  76122,  377098, 2 }, -- Consuming Killing Machine grants $s1% critical strike chance for $s2 sec, stacking up to $s3 times. At $s4 stacks your next Killing Machine consumes the stacks and grants you $s5% increased Frost damage for $s6 sec
    breath_of_sindragosa           = {  76093, 1249658, 1 }, -- Call upon Sindragosa's aid in battle for $s2 sec, continuously dealing $s$s3 Frost damage every $s4 sec to enemies in a cone in front of you. Consuming Killing Machine or Rime increases the duration by $s5 sec. Deals reduced damage to secondary targets. Grants a charge of Empower Rune Weapon at the start and $s6 Runes at the end
    cryogenic_chamber              = { 106790,  456237, 1 }, -- When Howling Blast consumes Rime, $s1% of the damage it deals is gathered into the next cast of Remorseless Winter, up to $s2 times
    empower_rune_weapon            = {  76096,   47568, 1 }, -- Drain the will of your enemy to empower your rune weapon, dealing $s$s2 Shadowfrost damage and reduced damage to enemies nearby, gaining $s3 Runic Power, and grants you Killing Machine
    enduring_strength              = { 101930,  377190, 1 }, -- When Pillar of Frost expires, your Strength is increased by $s1% for $s2 sec. This effect lasts $s3 sec longer, up to $s4 sec, for each Obliterate and Frostscythe critical strike during Pillar of Frost
    everfrost                      = {  76099,  376938, 1 }, -- Rime empowered Howling Blast deals $s1% increased damage to secondary targets. Remorseless Winter deals $s2% increased damage to enemies it hits, stacking up to $s3 times
    frigid_executioner             = {  76092,  377073, 1 }, -- Runic Empowerment has a $s1% chance to refund $s2 additional Rune
    frost_strike                   = {  76115,   49143, 1 }, -- Chill your weapon with icy power and quickly strike the enemy, dealing $s$s2 Frost damage
    frostbane                      = {  76094,  455993, 1 }, -- Each foe struck with Glacial Advance has a chance to transform your next Frost Strike into Frostbane. The chance increases with the number of Razorice stacks on the target. Frostbane Start a frozen onslaught that strikes twice, unleashing the chilling essence of winter, dealing $s$s4 Frost damage to all enemies caught in its wake with each strike. Each enemy struck reduces the damage dealt to the next foe by $s5%, down to $s6%
    frostbound_will                = { 107994, 1238680, 1 }, -- Consuming Rime reduces the cooldown of Empower Rune Weapon by $s1 sec
    frostreaper                    = {  76098, 1230301, 1 }, -- Obliterate deals $s2% increased damage and has a chance to tether the souls of its target and a nearby enemy to yours. Frost Strike severs the tethers, dealing $s$s3 Shadowfrost damage to both foes
    frostscythe                    = {  76113,  207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for $s$s2 Frost damage. Deals reduced damage beyond $s3 targets. Consumes Killing Machine to have its critical strikes deal $s4 times the normal damage
    frostwyrms_fury                = {  76106,  279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within $s2 yd in front of you, dealing $s$s3 Frost damage, stunning enemies for $s4 sec, and slowing movement speed by $s5% for $s6 sec
    frozen_dominion                = { 102009,  377226, 1 }, -- Pillar of Frost now summons a Remorseless Winter that lasts $s1 sec longer. Each enemy Remorseless Winter damages grants you $s2% Mastery, up to $s3% for $s4 sec
    gathering_storm                = {  76110,  194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by $s1%, and extends its duration by $s2 sec
    howling_blades                 = {  76121, 1230223, 1 }, -- Rime empowered Howling Blast unleashes $s2 icy blades at its target that deal $s$s3 Frost damage and have $s4% chance to grant Killing Machine
    howling_blast                  = {  76114,   49184, 1 }, -- Blast the target with a frigid wind, dealing $s$s3 Frost damage to that foe, and reduced damage to all other enemies within $s4 yards, infecting all targets with Frost Fever.  Frost Fever A disease that deals $s$s7 Frost damage over $s8 sec and has a chance to grant the Death Knight $s9 Runic Power each time it deals damage
    hyperpyrexia                   = {  76108,  456238, 1 }, -- Your Runic Power spending abilities have a chance to additionally deal $s1% of the damage dealt over $s2 sec
    icebreaker                     = {  76033,  392950, 2 }, -- When empowered by Rime, Howling Blast deals $s1% increased damage to your primary target
    icy_death_torrent              = { 101933,  435010, 1 }, -- Your auto attack critical strikes have a chance to send out a torrent of ice dealing $s$s2 Frost damage to enemies in front of you
    icy_onslaught                  = { 106791, 1230272, 1 }, -- Frost Strike and Glacial Advance now cause your next Frost Strike and Glacial Advance to deal $s1% increased damage and cost $s2 more Runic Power. This effect stacks until the next Runic Empowerment
    inexorable_assault             = {  76100,  253593, 1 }, -- Gain Inexorable Assault every $s2 sec, stacking up to $s3 times. Obliterate and Frostscythe consume up to $s4 stacks, dealing an additional $s$s5 Frost damage for each stack consumed
    killing_machine                = {  76117,   51128, 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate deal Frost damage and critically strike, or make your next Frostscythe critically strike for $s1 times the normal damage
    killing_streak                 = {  76091, 1230153, 1 }, -- Obliterate and Frostscythe consume all Killing Machines to deal $s1% increased critical strike damage and grant $s2% Haste for $s3 sec for each stack consumed. Multiple applications may overlap
    murderous_efficiency           = {  76037,  207061, 1 }, -- Consuming the Killing Machine effect has a $s1% chance to grant you $s2 Rune
    northwinds                     = {  76109, 1230284, 1 }, -- Howling Blast now hits an additional target with maximum effectiveness. Rime increases Howling Blast damage done by an additional $s1%
    obliterate                     = {  76116,   49020, 1 }, -- A brutal attack that deals $s$s2 Physical damage
    obliteration                   = {  76123,  281238, 1 }, -- During Pillar of Frost, Frost Strike, Glacial Advance, and Howling Blast always grant Killing Machine and have a $s1% chance to generate a Rune. Additionally during Pillar of Frost, Empower Rune Weapon causes your next Obliterate or Frostscythe to cost no Runes
    pillar_of_frost                = { 101929,   51271, 1 }, -- The power of frost increases your Strength by $s1% for $s2 sec
    rage_of_the_frozen_champion    = { 101931,  377076, 1 }, -- Frost Strike and Glacial Advance have a $s1% increased chance to trigger Rime and Howling Blast generates $s2 Runic Power while Rime is active
    runic_command                  = {  76102,  376251, 2 }, -- Increases your maximum Runic Power by $s1. Increases Rune regeneration rate by $s2%
    runic_overflow                 = {  76103,  316803, 2 }, -- Increases Frost Strike and Glacial Advance damage by $s1%
    shattering_blade               = {  76095,  207057, 1 }, -- When Frost Strike damages an enemy with $s1 stacks of Razorice it will consume them to deal an additional $s2% damage
    smothering_offense             = {  76101,  435005, 1 }, -- Your auto attack damage is increased by $s1%. This amount is increased for each stack of Icy Talons you have and it can stack up to $s2 additional times
    the_long_winter                = { 101932,  456240, 1 }, -- While Pillar of Frost is active your auto-attack critical strikes increase its duration by $s1 sec, up to a maximum of $s2 sec

    -- Deathbringer
    bind_in_darkness               = {  95043,  440031, 1 }, -- Rime empowered Howling Blast deals $s2% increased damage to its main target, and is now Shadowfrost$s$s3 Shadowfrost damage applies $s4 stacks to Reaper's Mark and $s5 stacks when it is a critical strike
    dark_talons                    = {  95057,  436687, 1 }, -- Consuming Killing Machine or Rime has a $s1% chance to grant $s2 stacks of Icy Talons and increase its maximum stacks by the same amount for $s3 sec. Runic Power spending abilities count as Shadowfrost while Icy Talons is active
    deaths_messenger               = {  95049,  437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by $s1 sec
    expelling_shield               = {  95049,  439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by $s1% for $s2 sec
    exterminate                    = {  95068,  441378, 1 }, -- After Reaper's Mark explodes, your next $s3 Obliterate or Frostscythe cost $s4 Rune and summon $s5 scythes to strike your enemies. The first scythe strikes your target for $s$s6 Shadowfrost damage and has a $s7% chance to grant Killing Machine, the second scythe strikes all enemies around your target for $s$s8 Shadowfrost damage and applies Frost Fever. Deals reduced damage beyond $s9 targets
    grim_reaper                    = {  95034,  434905, 1 }, -- Reaper's Mark initial strike grants Killing Machine. Reaper's Mark explosion deals up to $s1% increased damage based on your target's missing health
    pact_of_the_deathbringer       = {  95035,  440476, 1 }, -- When you suffer a damaging effect equal to $s1% of your maximum health, you instantly cast Death Pact at $s2% effectiveness. May only occur every $s3 min. When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by $s4 sec
    reaper_of_souls                = {  95034,  440002, 1 }, -- When you apply Reaper's Mark, the cooldown of Soul Reaper is reset, your next Soul Reaper costs no runes, and it explodes on the target regardless of their health. Soul Reaper damage is increased by $s1%
    reapers_mark                   = {  95062,  439843, 1 }, -- Viciously slice into the soul of your enemy, dealing $s$s2 Shadowfrost damage and applying Reaper's Mark. Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $s3 sec or reaching $s4 stacks, the mark explodes, dealing $s5 damage per stack. Reaper's Mark travels to an unmarked enemy nearby if the target dies
    reapers_onslaught              = {  95057,  469870, 1 }, -- Reduces the cooldown of Reaper's Mark by $s1 sec, but the amount of Obliterates and Frostscythes empowered by Exterminate is reduced by $s2
    rune_carved_plates             = {  95035,  440282, 1 }, -- Each Rune spent reduces the magic damage you take by $s1% and each Rune generated reduces the physical damage you take by $s2% for $s3 sec, up to $s4 times
    soul_rupture                   = {  95061,  437161, 1 }, -- When Reaper's Mark explodes, it deals $s1% of the damage dealt to nearby enemies and causes them to deal $s2% reduced Physical damage to you for $s3 sec
    swift_and_painful              = {  95032,  443560, 1 }, -- If no enemies are struck by Soul Rupture, you gain $s1% Strength for $s2 sec. Wave of Souls is $s3% more effective on the main target of your Reaper's Mark
    wave_of_souls                  = {  95036,  439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing $s$s2 Shadowfrost damage both ways to all enemies caught in its path. Wave of Souls critical strikes cause enemies to take $s3% increased Shadowfrost damage for $s4 sec, stacking up to $s5 times, and it is always a critical strike on its way back
    wither_away                    = {  95058,  441894, 1 }, -- Frost Fever deals its damage $s1% faster, and the second scythe of Exterminate applies Frost Fever

    -- Rider Of The Apocalypse
    a_feast_of_souls               = {  95042,  444072, 1 }, -- While you have $s1 or more Horsemen aiding you, your Runic Power spending abilities deal $s2% increased damage
    apocalypse_now                 = {  95041,  444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all $s1 Horsemen to aid you for $s2 sec
    death_charge                   = {  95060,  444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects. For $s1 sec, while upon your Death Charger your movement speed is increased by $s2%, you cannot be slowed below $s3% of normal speed, and you are immune to forced movement effects and knockbacks
    fury_of_the_horsemen           = {  95042,  444069, 1 }, -- Every $s1 Runic Power you spend extends the duration of the Horsemen's aid in combat by $s2 sec, up to $s3 sec
    horsemens_aid                  = {  95037,  444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at $s1% effectiveness. You may only benefit from this effect every $s2 sec
    hungering_thirst               = {  95044,  444037, 1 }, -- The damage of your diseases and Frost Strike are increased by $s1%
    mawsworn_menace                = {  95054,  444099, 1 }, -- Obliterate deals $s1% increased damage and your Remorseless Winter lasts $s2 sec longer
    mograines_might                = {  95067,  444047, 1 }, -- Your damage is increased by $s1% and you gain $s2% critical strike chance while inside Mograine's Death and Decay
    nazgrims_conquest              = {  95059,  444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by $s1%. Additionally, each Rune you spend increase its value by $s2%
    on_a_paler_horse               = {  95060,  444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat
    pact_of_the_apocalypse         = {  95037,  444083, 1 }, -- When you take damage, $s1% of the damage is redirected to each active horsemen
    riders_champion                = {  95066,  444005, 1 }, -- Spending Runes has a chance to call forth the aid of a Horsemen for $s2 sec. Mograine Casts Death and Decay at his location that follows his position. Whitemane Casts Undeath on your target dealing $s$s3 Shadowfrost damage per stack every $s4 sec, for $s5 sec. Each time Undeath deals damage it gains a stack. Cannot be refreshed. Trollbane Casts Chains of Ice on your target slowing their movement speed by $s6% and increasing the damage they take from you by $s7% for $s8 sec. Nazgrim While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by $s9%
    trollbanes_icy_fury            = {  95063,  444097, 1 }, -- Obliterate and Frostscythe shatter Trollbane's Chains of Ice when hit, dealing $s$s2 Shadowfrost damage to nearby enemies, and slowing them by $s3% for $s4 sec. Deals reduced damage beyond $s5 targets
    whitemanes_famine              = {  95047,  444033, 1 }, -- When Obliterate or Frostscythe damages an enemy affected by Undeath it gains $s1 stack and infects another nearby enemy
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill                   = 5435, -- (356470) Chains of Ice reduces the target's Haste by $s1%. Frost Strike refreshes the duration of Chains of Ice
    bloodforged_armor              = 5586, -- (410301) Death Strike reduces all Physical damage taken by $s1% for $s2 sec
    dark_simulacrum                = 3512, -- (77606) Places a dark ward on an enemy player that persists for $s1 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell
    deathchill                     =  701, -- (204080) Your Remorseless Winter and Chains of Ice apply Deathchill, rooting the target in place for $s1 sec. Remorseless Winter All targets within $s2 yards are afflicted with Deathchill when Remorseless Winter is cast. Chains of Ice When you Chains of Ice a target already afflicted by your Chains of Ice they will be afflicted by Deathchill
    deaths_cold_embrace            = 5693, -- (1218603) Pillar of Frost grants you Remorseless Winter and increases its damage by $s1% and its radius by $s2%, but your movement speed is heavily reduced for its duration. Pillar of Frost's cooldown is increased by $s3 sec
    delirium                       =  702, -- (233396) Howling Blast applies Delirium, reducing the cooldown recovery rate of movement enhancing abilities by $s1% for $s2 sec
    rot_and_wither                 = 5510, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to $s1% of damage dealt
    shroud_of_winter               = 3439, -- (199719) Enemies within $s1 yards of you become shrouded in winter, reducing the range of their spells and abilities by $s2%
    spellwarden                    = 5591, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by $s1 sec
    strangulate                    = 5429, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for $s1 sec
} )

-- Auras
spec:RegisterAuras( {
    -- Your Runic Power spending abilities deal $w1% increased damage.
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Absorbing up to $w1 magic damage.  Immune to harmful magic effects.
    -- https://wowhead.com/beta/spell=48707
    antimagic_shell = {
        id = 48707,
        duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * 5 + ( conduit.reinforced_shell.mod * 0.001 ) end,
        max_stack = 1
    },
    antimagic_zone = {
        id = 145629,
        duration = function () return 6 + ( 2 * talent.assimilation.rank ) end,
        max_stack = 1
    },
    asphyxiate = {
        id = 108194,
        duration = 4,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Next Howling Blast deals Shadowfrost damage.
    bind_in_darkness = {
        id = 443532,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=207167
    blinding_sleet = {
        id = 207167,
        duration = 5,
        mechanic = "disorient",
        type = "Magic",
        max_stack = 1
    },
    blood_draw = {
        id = 454871,
        duration = 8,
        max_stack = 1
    },
    -- You may not benefit from the effects of Blood Draw.
    -- https://wowhead.com/beta/spell=374609
    blood_draw_cd = {
        id = 374609,
        duration = 120,
        max_stack = 1
    },
    -- Draining $w1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=55078
    blood_plague = {
        id = 55078,
        duration = function() return 24 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
        max_stack = 1
    },
    -- Draining $s1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=206931
    blooddrinker = {
        id = 206931,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    bonegrinder_crit = {
        id = 377101,
        duration = 10,
        max_stack = 5
    },
    -- Talent: Frost damage increased by $s1%.
    -- https://wowhead.com/beta/spell=377103
    bonegrinder_frost = {
        id = 377103,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Continuously dealing Frost damage every $t1 sec to enemies in a cone in front of you.
    -- https://wowhead.com/beta/spell=152279
    breath_of_sindragosa = {
        id = 1249658,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    -- Talent: Movement slowed $w1% $?$w5!=0[and Haste reduced $w5% ][]by frozen chains.
    -- https://wowhead.com/beta/spell=45524
    chains_of_ice = {
        id = 45524,
        duration = 8,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    chilled = {
        id = 204206,
        duration = 4,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    cold_heart = {
        id = 235599,
        duration = 3600,
        max_stack = 20
    },
    -- Talent: Controlled.
    -- https://wowhead.com/beta/spell=111673
    control_undead = {
        id = 111673,
        duration = 300,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    cryogenic_chamber = {
        id = 456370,
        duration = 30,
        max_stack = 20
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=56222
    dark_command = {
        id = 56222,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    dark_succor = {
        id = 101568,
        duration = 20,
        max_stack = 1
    },
    -- Reduces healing done by $m1%.
    -- https://wowhead.com/beta/spell=327095
    death = {
        id = 327095,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    death_and_decay = { -- Buff.
        id = 188290,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    -- [444347] $@spelldesc444010
    death_charge = {
        id = 444347,
        duration = 10,
        max_stack = 1
    },
    -- Talent: The next $w2 healing received will be absorbed.
    -- https://wowhead.com/beta/spell=48743
    death_pact = {
        id = 48743,
        duration = 15,
        max_stack = 1
    },
    -- Your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.
    -- https://wowhead.com/beta/spell=48265
    deaths_advance = {
        id = 48265,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: When Pillar of Frost expires, you will gain $s1% Strength for $<duration> sec.
    -- https://wowhead.com/beta/spell=377192
    enduring_strength = {
        id = 377192,
        duration = 20,
        max_stack = 20
    },
    -- Talent: Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=377195
    enduring_strength_buff = {
        id = 377195,
        duration = function() return 6 + 2 * buff.enduring_strength.stack end,
        max_stack = 1
    },
    everfrost = {
        id = 376974,
        duration = 8,
        max_stack = 10
    },
    -- Casting speed reduced by $w1%.
    expelling_shield = {
        id = 440739,
        duration = 6.0,
        max_stack = 1
    },
    -- Your next 2 Obliterate or Frostscythe cost 1 Rune and summon 2 scythes to strike your enemies.
    exterminate = {
        id = 441416,
        duration = 30,
        max_stack = function() return ( talent.reapers_onslaught.enabled and 1 or 2 ) + ( set_bonus.tww3 > 1 and 1 or 0 ) end,
    },
    -- Reduces damage dealt to $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327092
    famine = {
        id = 327092,
        duration = 6,
        max_stack = 3
    },
    -- Frostbane Your Frost Strike has become Frostbane. $s1 seconds remaining
    -- https://www.wowhead.com/spell=1229310
    frostbane = {
        id = 1229310,
        duration = 30
    },
    -- https://www.wowhead.com/spell=1233351
    frostreaper = {
        id = 1233351,
        duration = 8
    },
    -- Suffering $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=55095
    frost_fever = {
        id = 55095,
        duration = function() return 24 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Frozen Dominion Grants $s1% Mastery. $s2 seconds remaining
    -- https://www.wowhead.com/spell=377253
    frozen_dominion = {
        id = 377253,
        duration = 15,
        max_stack = 5
    },
    frozen_pulse = {
        -- Pseudo aura for legacy talent.
        name = "Frozen Pulse",
        meta = {
            up = function () return runes.current < 3 end,
            down = function () return runes.current >= 3 end,
            stack = function () return runes.current < 3 and 1 or 0 end,
            duration = 15,
            remains = function () return runes.time_to_3 end,
            applied = function () return runes.current < 3 and query_time or 0 end,
            expires = function () return runes.current < 3 and ( runes.time_to_3 + query_time ) or 0 end,
        }
    },
    -- Dealing $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=274074
    glacial_contagion = {
        id = 274074,
        duration = 14,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Dealing $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=275931
    harrowing_decay = {
        id = 275931,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Deals $s1 Fire damage.
    -- https://wowhead.com/beta/spell=286979
    helchains = {
        id = 286979,
        duration = 15,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Rooted.
    ice_prison = {
        id = 454787,
        duration = 4.0,
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/beta/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        tick_time = 1.0,
        max_stack = 1
    },
    -- Icy Onslaught Damage of Frost Strike and Glacial Advance increased by $s1% and their cost by $s2 Runic Power. $s3 seconds remaining
    -- https://www.wowhead.com/spell=1230273
    icy_onslaught = {
        id = 1230273,
        duration = 30,
        max_stack = 5
    },
    icy_talons = {
        id = 194879,
        duration = 10,
        max_stack = function() return ( talent.smothering_offense.enabled and 5 or 3 ) + ( talent.dark_talons.enabled and 3 or 0 ) end
    },
    inexorable_assault = {
        id = 253595,
        duration = 3600,
        max_stack = 5
    },
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    -- Talent: Guaranteed critical strike on your next Obliterate$?s207230[ or Frostscythe][].
    -- https://wowhead.com/beta/spell=51124
    killing_machine = {
        id = 51124,
        duration = 10,
        max_stack = 2
    },
    -- Killing Streak Haste increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=1230916
    killing_streak = {
        id = 1230916,
        duration = 8,
        max_stack = 10
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( talent.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1
    },
    -- Casting speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=326868
    lethargy = {
        id = 326868,
        duration = 6,
        max_stack = 1
    },
    -- Leech increased by $s1%$?a389682[, damage taken reduced by $s8%][] and immune to Charm, Fear and Sleep. Undead.
    -- https://wowhead.com/beta/spell=49039
    lichborne = {
        id = 49039,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    march_of_darkness = {
        id = 391547,
        duration = 3,
        max_stack = 1
    },
    -- Talent: $@spellaura281238
    -- https://wowhead.com/beta/spell=207256
    obliteration = {
        id = 207256,
        duration = 9,
        max_stack = 1
    },
    -- Grants the ability to walk across water.
    -- https://wowhead.com/beta/spell=3714
    path_of_frost = {
        id = 3714,
        duration = 600,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Suffering $o1 shadow damage over $d and slowed by $m2%.
    -- https://wowhead.com/beta/spell=327093
    pestilence = {
        id = 327093,
        duration = 6,
        tick_time = 1,
        type = "Magic",
        max_stack = 3
    },
    -- Talent: Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=51271
    pillar_of_frost = {
        id = 51271,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Frost damage taken from the Death Knight's abilities increased by $s1%.
    -- https://wowhead.com/beta/spell=51714
    razorice = {
        id = 51714,
        duration = 20,
        tick_time = 1,
        type = "Magic",
        max_stack = 5
    },
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = function() return set_bonus.tww3 >= 4 and 55 or 40 end,
        copy = "reapers_mark_debuff",

        onRemove = function()
            -- 4-piece tier set: 10% crit chance after explosion
            if set_bonus.tww3 >= 4 then
                applyBuff( "empowered_soul" )
            end
            if talent.exterminate.enabled then
                local stacks = talent.reapers_onslaught.enabled and 1 or 2
                applyBuff( "exterminate", nil, stacks )
            end
            -- Wave of Souls: Damage amplification debuff
            if talent.wave_of_souls.enabled then
                applyDebuff( "target", "wave_of_souls_debuff" )
                active_dot.wave_of_souls_debuff = max( active_dot.wave_of_souls_debuff, active_enemies )
            end
            -- Swift and Painful: Strength buff if no enemies struck (single target optimization)
            if talent.swift_and_painful.enabled and active_enemies == 1 then
                applyBuff( "swift_and_painful_strength" )
            end
        end,
    },
    -- Talent: Dealing $196771s1 Frost damage to enemies within $196771A1 yards each second.
    -- https://wowhead.com/beta/spell=196770
    remorseless_winter = {
        id = 196770,
        duration = function() return 8 + ( talent.frozen_dominion.enabled and 4 or 0 ) + ( talent.mawsworn_menace.enabled and 2 or 0 ) end,
        tick_time = 1,
        max_stack = 1,
        copy = { 196770, 1233152 } -- talent.frozen_dominion changes the ID
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=211793
    remorseless_winter_snare = {
        id = 211793,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Howling Blast will consume no Runes, generate no Runic Power, and deals $s2% additional damage.
    -- https://wowhead.com/beta/spell=59052
    rime = {
        id = 59052,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Magical damage taken reduced by $w1%.
    rune_carved_plates = {
        id = 440290,
        duration = 5.0,
        max_stack = 1
    },
    -- Talent: Strength increased by $w1%
    -- https://wowhead.com/beta/spell=374585
    rune_mastery = {
        id = 374585,
        duration = 8,
        max_stack = 1
    },
    -- Runic Power generation increased by $s1%.
    -- https://wowhead.com/beta/spell=326918
    rune_of_hysteria = {
        id = 326918,
        duration = 8,
        max_stack = 1
    },
    -- Healing for $s1% of your maximum health every $t sec.
    -- https://wowhead.com/beta/spell=326808
    rune_of_sanguination = {
        id = 326808,
        duration = 8,
        max_stack = 1
    },
    -- Absorbs $w1 magic damage.    When an enemy damages the shield, their cast speed is reduced by $w2% for $326868d.
    -- https://wowhead.com/beta/spell=326867
    rune_of_spellwarding = {
        id = 326867,
        duration = 8,
        max_stack = 1
    },
    -- Haste and Movement Speed increased by $s1%.
    -- https://wowhead.com/beta/spell=326984
    rune_of_unending_thirst = {
        id = 326984,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/beta/spell=448229
    soul_reaper = {
        id = 448229,
        duration = 5,
        tick_time = 5,
        max_stack = 1
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 5.0,
        max_stack = 1
    },
    -- Damage dealt to $@auracaster reduced by $w1%.
    subduing_grasp = {
        id = 454824,
        duration = 6.0,
        max_stack = 1
    },
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
        max_stack = 1
    },
    -- Deals $s1 Fire damage.
    -- https://wowhead.com/beta/spell=319245
    unholy_pact = {
        id = 319245,
        duration = 15,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Strength increased by 0%
    unleashed_frenzy = {
        id = 376907,
        duration = 10, -- 20230206 Hotfix
        max_stack = 3
    },
    -- The touch of the spirit realm lingers....
    -- https://wowhead.com/beta/spell=97821
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
    },
    -- Increases damage taken from $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327096
    war = {
        id = 327096,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    -- Talent: Movement speed increased by $w1%.  Cannot be slowed below $s2% of normal movement speed.  Cannot attack.
    -- https://wowhead.com/beta/spell=212552
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },

    -- PvP Talents
    -- Your next spell with a mana cost will be copied by the Death Knight's runeblade.
    dark_simulacrum = {
        id = 77606,
        duration = 12,
        max_stack = 1
    },
    -- Your runeblade contains trapped magical energies, ready to be unleashed.
    dark_simulacrum_buff = {
        id = 77616,
        duration = 12,
        max_stack = 1
    },
    dead_of_winter = {
        id = 289959,
        duration = 4,
        max_stack = 5
    },
    deathchill = {
        id = 204085,
        duration = 4,
        max_stack = 1
    },
    delirium = {
        id = 233396,
        duration = 15,
        max_stack = 1
    },
    shroud_of_winter = {
        id = 199719,
        duration = 3600,
        max_stack = 1
    },

    -- Legendary
    absolute_zero = {
        id = 334693,
        duration = 3,
        max_stack = 1
    },

    -- Azerite Powers
    cold_hearted = {
        id = 288426,
        duration = 8,
        max_stack = 1
    },
    frostwhelps_indignation = {
        id = 287338,
        duration = 6,
        max_stack = 1
    },
    -- Swift and Painful Strength
    swift_and_painful_strength = {
        id = 469169,
        duration = 8,
        max_stack = 1
    },
} )

spec:RegisterTotem( "ghoul", 1100170 )

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237631, 237629, 237627, 237628, 237626 },
        auras = {
            -- Deathbringer
            -- Crit Buff
            empowered_soul = {
                id = 1236996,
                duration = 8,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229253, 229251, 229256, 229254, 229252 },
        auras = {
            -- https://www.wowhead.com/spell=1216813
            winning_streak = {
                id = 1217897,
                duration = 3600,
                max_stack = 6
            },
            -- https://www.wowhead.com/spell=1222698
            murderous_frenzy = {
                id = 1222698,
                duration = 6,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207198, 207199, 207200, 207201, 207203 },
        auras = {
            chilling_rage = {
                id = 424165,
                duration = 12,
                max_stack = 5
            }
        }
    },
    tier30 = {
        items = { 202464, 202462, 202461, 202460, 202459, 217223, 217225, 217221, 217222, 217224 },
        auras = {
            wrath_of_the_frostwyrm = {
                id = 408368,
                duration = 30,
                max_stack = 10
            },
            lingering_chill = {
                id = 410879,
                duration = 12,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200405, 200407, 200408, 200409, 200410 }
    }
} )

local spendHook = function( amt, resource )
    -- Runic Power
    if amt > 0 and resource == "runic_power" then
        if talent.icy_talons.enabled then addStack( "icy_talons", nil, 1 ) end
        if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy") end
    end
    -- Runes
    if resource == "rune" and amt > 0 then
        if active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end

        if talent.rune_carved_plates.enabled then
            addStack( "rune_carved_plates", nil, amt )
        end

        -- Nazgrim's Conquest: Each Rune spent increases Apocalyptic Conquest Strength by 1%
        if talent.nazgrims_conquest.enabled and buff.apocalyptic_conquest.up then
            addStack( "apocalyptic_conquest", nil, amt )
        end
    end
end

spec:RegisterHook( "spend", spendHook )

spec:RegisterHook( "TALENTS_UPDATED", function()
    class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any " .. class.abilities.death_and_decay.name .. "]|r"
    class.abilities.any_dnd = class.abilities.death_and_decay_actual
    rawset( cooldown, "any_dnd", nil )
    rawset( cooldown, "death_and_decay", nil )
    rawset( cooldown, "any_dnd", cooldown.death_and_decay )
end )


local PendingKillingMachine = 0
local PendingObliteration, ObliterationTimer = 0

local function ExpireObliteration()
    if PendingObliteration == 0 then return end

    -- local now = GetTime()
    -- local duration = 10 + now - PendingObliteration
    -- print( strformat( "%6.3f - Obliteration: Discount expired after %.3f; overlayed: %s.", now, duration, IsSpellOverlayed( 49020 ) and "YES" or "NO" ) )

    PendingObliteration = 0
end

spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= state.GUID then return end

    local now = GetTime()

    -- ERW -> KM often has a delay, but no more than 1s.
    if subtype == "SPELL_CAST_SUCCESS" then
        if spellID == 47568 then
            PendingKillingMachine = now + 1
            -- print( strformat( "%6.3f - ERW Cast; Virtual KM expected within 1s.", now ) )
        end

        if state.talent.obliteration.enabled and GetPlayerAuraBySpellID( 51271 ) then
            -- Frost Strike, Glacial Advance, and Howling Blast
            if spellID == 49143 or spellID == 194913 or spellID == 49184 then
                PendingKillingMachine = now + 1
                -- print( strformat( "%6.3f - %s during PoF; Virtual KM expected within 1s.", now, spellName ) )

            elseif spellID == 47568 then
                PendingObliteration = now + 10
                ObliterationTimer = NewTimer( 10, ExpireObliteration )
                -- print( strformat( "%6.3f - ERW during PoF; next Obliterate or Frostscythe within ~10s is free.", now ) )
            end
        end

        if spellID == 207230 or spellID == 49020 then
            if PendingObliteration > 0 then
                ObliterationTimer:Cancel()
                ExpireObliteration()
            end

            if state.talent.exterminate.enabled and GetPlayerAuraBySpellID( 441416 ) then
                -- We don't really need to care why KM is pending, just that it's pending.
                PendingKillingMachine = now + 1
                -- print( strformat( "%6.3f - Virtual KM from Exterminate %s expected within 1s.", now, spellName ) )
            end
        end

        -- All SPELL_CAST_SUCCESS events completed.
        return
    end

    if spellID == 51124 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REFRESH" ) then
        if PendingKillingMachine > 0 then
            PendingKillingMachine = 0
            -- print( strformat( "%6.3f - Virtual KM consumed.", now ) )
        end
    end
end )

local BreathOfSindragosaExpire = setfenv( function()
    gain( 2, "runes" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    local control_expires = action.control_undead.lastCast + 300
    if talent.control_undead.enabled and control_expires > now and pet.up then
        summonPet( "controlled_undead", control_expires - now )
    end

    -- Reset CDs on any Rune abilities that do not have an actual cooldown.
    for action in pairs( class.abilityList ) do
        local data = class.abilities[ action ]
        if data and data.cooldown == 0 and data.spendType == "runes" then
            setCooldown( action, 0 )
        end
    end

    -- Queue aura event for Breath of Sindragosa rune generation
    if buff.breath_of_sindragosa.up then
        state:QueueAuraEvent( "breath_of_sindragosa", BreathOfSindragosaExpire, buff.breath_of_sindragosa.expires, "AURA_EXPIRATION" )
    end

    if PendingKillingMachine > 0 then
        if PendingKillingMachine > now then
            addStack( "killing_machine" )
            if Hekili.ActiveDebug then Hekili:Debug( "Applied virtual KM.", now ) end
        else
            PendingKillingMachine = 0
            if Hekili.ActiveDebug then Hekili:Debug( "Virtual KM expired.", now ) end
        end
    end

    if PendingObliteration > 0 then
        applyBuff( "obliteration", nil, PendingObliteration - now )
        if Hekili.ActiveDebug then Hekili:Debug( "Applied virtual 'Obliteration' (%.2f) discount for Oblit / Frostscythe.", buff.obliteration.remains ) end
    end
end )



local KillingMachineConsumer = setfenv( function ()
    local stacksConsumed = 1

    -- Killing Streak
    if talent.killing_streak.enabled then
        stacksConsumed = buff.killing_machine.stack
        removeBuff( "killing_machine" )
        addStack( "killing_streak", buff.killing_machine.stack )
    else
        removeStack( "killing_machine" )
    end

    -- Bonegrinder
    if talent.bonegrinder.enabled then
        local current = buff.bonegrinder_crit.stack or 0
        local totalStacks = current + stacksConsumed
        if totalStacks >= 5 then
            removeBuff( "bonegrinder_crit" )
            applyBuff( "bonegrinder_frost" )

            -- Handle overflow: if we added 2 but only needed 1 to cap
            local overflow = totalStacks - 5
            if overflow > 0 then applyBuff( "bonegrinder_crit", nil, overflow ) end
        else
            addStack( "bonegrinder_crit", stacksConsumed )
        end
    end

    -- Breath of Sindragosa
    if buff.breath_of_sindragosa.up then buff.breath_of_sindragosa.expires = buff.breath_of_sindragosa.expires + 0.8 * stacksConsumed end

    -- Arctic Assault - fires Glacial Advance through target
    if talent.arctic_assault.enabled then
        -- This would trigger the glacial advance effect in the game
        -- For simulation purposes, we can apply Razorice stacks to represent the effect
        spec.abilities.glacial_advance.handler()
    end

end, state )

-- Abilities
spec:RegisterAbilities( {
    -- Talent: Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic damage and preventing application of harmful magical effects.$?s207188[][ Damage absorbed generates Runic Power.]
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = function() return 60 - ( talent.antimagic_barrier.enabled and 15 or 0 ) - ( talent.unyielding_will.enabled and -20 or 0 ) - ( pvptalent.spellwarden.enabled and 10 or 0 ) end,
        gcd = "off",

        startsCombat = false,

        toggle = function()
            if settings.ams_usage == "defensives" or settings.ams_usage == "both" then return "defensives" end
        end,

        usable = function()
            if settings.ams_usage == "damage" or settings.ams_usage == "both" then return incoming_magic_3s > 0, "settings require magic damage taken in the past 3 seconds" end
        end,

        handler = function ()
            applyBuff( "antimagic_shell" )
            if talent.unyielding_will.enabled then removeBuff( "dispellable_magic" ) end
        end,
    },

    -- Talent: Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by $145629m1%. The Anti-Magic Zone lasts for $d or until it absorbs $?a374383[${$<absorb>*1.1}][$<absorb>] damage.
    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = function() return 240 - ( talent.assimilation.enabled and 60 or 0 ) end,
        gcd = "spell",

        talent = "antimagic_zone",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "antimagic_zone" )
        end,
    },

    -- Talent: Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $d.
    asphyxiate = {
        id = 221562,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "asphyxiate",
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            applyDebuff( "target", "asphyxiate" )
            interrupt()
        end,
    },

    -- Talent: Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.    When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "blinding_sleet" )
            active_dot.blinding_sleet = max( active_dot.blinding_sleet, active_enemies )
        end,
    },

    -- Talent: Continuously deal ${$155166s2*$<CAP>/$AP} Frost damage every $t1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets.    |cFFFFFFFFGenerates $303753s1 $lRune:Runes; at the start and end.|r
    breath_of_sindragosa = {
        id = 1249658,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 60,
        spendType = "runic_power",

        talent = "breath_of_sindragosa",
        startsCombat = true,
        texture = 1029007,

        toggle = "cooldowns",

        handler = function ()
            gainCharges( "empower_rune_weapon", 1 )
            applyBuff( "breath_of_sindragosa", 8 )
        end,
    },

    -- Talent: Shackles the target $?a373930[and $373930s1 nearby enemy ][]with frozen chains, reducing movement speed by $s1% for $d.
    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = function() return 0 + ( talent.ice_prison.enabled and 12 or 0 ) end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            if talent.ice_prison.enabled then applyDebuff( "target", "ice_prison" ) end
            removeBuff( "cold_heart" )
        end,
    },

    -- Talent: Dominates the target undead creature up to level $s1, forcing it to do your bidding for $d.
    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "control_undead",
        startsCombat = false,

        usable = function () return target.is_undead and target.level <= level + 1, "requires undead target up to 1 level above player" end,
        handler = function ()
            summonPet( "controlled_undead", 300 )
        end,
    },

    -- Command the target to attack you.
    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dark_command" )
        end,
    },


    dark_simulacrum = {
        id = 77606,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        startsCombat = true,
        texture = 135888,

        pvptalent = "dark_simulacrum",

        usable = function ()
            if not target.is_player then return false, "target is not a player" end
            return true
        end,
        handler = function ()
            applyDebuff( "target", "dark_simulacrum" )
        end,
    },

    -- Corrupts the targeted ground, causing ${$52212m1*11} Shadow damage over $d to...
    death_and_decay = {
        id = 43265,
        noOverride = 324128,
        cast = 0,
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 30,
        recharge = function () if talent.deaths_echo.enabled then return 30 end end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        notalent = "defile",

        usable = function () return ( settings.dnd_while_moving or not moving ), "cannot cast while moving" end,

        handler = function ()
            applyBuff( "death_and_decay" )
            applyDebuff( "target", "death_and_decay" )
            if talent.grip_of_the_dead.enabled then applyDebuff( "target", "grip_of_the_dead" ) end
        end,

        bind = "any_dnd",
        copy = { "death_and_decay_actual", "any_dnd" }
    },

    -- Fires a blast of unholy energy at the target$?a377580[ and $377580s2 additional nearby target][], causing $47632s1 Shadow damage to an enemy or healing an Undead ally for $47633s1 health.$?s390268[    Increases the duration of Dark Transformation by $390268s1 sec.][]
    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "runic_power",

        startsCombat = true,

        handler = function ()
            if buff.dark_transformation.up then buff.dark_transformation.up.expires = buff.dark_transformation.expires + 1 end
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
        end,
    },

    -- Opens a gate which you can use to return to Ebon Hold.    Using a Death Gate while in Ebon Hold will return you back to near your departure point.
    death_gate = {
        id = 50977,
        cast = 4,
        cooldown = 60,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Harnesses the energy that surrounds and binds all matter, drawing the target toward you$?a389679[ and slowing their movement speed by $389681s1% for $389681d][]$?s137008[ and forcing the enemy to attack you][].
    death_grip = {
        id = 49576,
        cast = 0,
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 15,
        recharge = function() if talent.deaths_echo.enabled then return 15 end end,

        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "death_grip" )
            setDistance( 5 )
            if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
        end,
    },

    -- Talent: Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s3% of your max health for $d.
    death_pact = {
        id = 48743,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "death_pact",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            gain( health.max * 0.5, "health" )
            applyDebuff( "player", "death_pact" )
        end,
    },

    -- Talent: Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.dark_succor.up then return 0 end
            return ( talent.improved_death_strike.enabled and 40 or 50 ) - ( buff.blood_draw.up and 10 or 0 )
        end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()
            removeBuff( "dark_succor" )
            gain( health.max * 0.10, "health" )
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
        end,
    },

    -- For $d, your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.    |cFFFFFFFFPassive:|r You cannot be slowed below $124285s1% of normal speed.
    deaths_advance = {
        id = 48265,
        cast = 0,
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 45,
        recharge = function() if talent.deaths_echo.enabled then return 45 end end,

        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyBuff( "deaths_advance" )
            if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
        end,
    },

    -- Talent: Empower your rune weapon, gaining $s3% Haste and generating $s1 $LRune:Runes; and ${$m2/10} Runic Power instantly and every $t1 sec for $d.  $?s137006[  If you already know $@spellname47568, instead gain $392714s1 additional $Lcharge:charges; of $@spellname47568.][]
    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        cooldown = 30,
        charges = 2,
        recharge = 30,

        gcd = "off",
        school = "shadowfrost",

        talent = "empower_rune_weapon",
        startsCombat = false,

        handler = function ()
            gain( 40, "runic_power" )
            addStack( "killing_machine" )
        end,

    },

    -- Talent: Chill your $?$owb==0[weapon with icy power and quickly strike the enemy, dealing $<2hDamage> Frost damage.][weapons with icy power and quickly strike the enemy with both, dealing a total of $<dualWieldDamage> Frost damage.]
    frost_strike = {
        id = function() return buff.frostbane.up and 1228433 or 49143 end,
        texture = function() return buff.frostbane.up and 1273742 or 237520 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "runic_power",
        school = function() if talent.dark_talons.enabled and buff.icy_talons.up then return "shadowfrost" end return "frost" end,

        talent = "frost_strike",
        startsCombat = true,

        cycle = function ()
            if debuff.mark_of_fyralath.up then return "mark_of_fyralath" end
            if talent.shattering_blade.disabled and debuff.razorice.at_max_stacks then return "razorice" end
        end,

        handler = function ()

            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
            if talent.shattering_blade.enabled and debuff.razorice.at_max_stacks then removeDebuff( "target", "razorice" ) end
            -- if debuff.razorice.stack > 5 then applyDebuff( "target", "razorice", nil, debuff.razorice.stack - 5 ) end
            if talent.icy_onslaught.enabled then addStack( "icy_onslaught" ) end
            removeBuff( "frostbane" )
            if death_knight.runeforge.razorice then applyDebuff( "target", "razorice", nil, min( 5, debuff.razorice.stack + 1 ) ) end
            if talent.frostreaper.enabled then removeBuff( "frostreaper" ) end
            -- Legacy / PvP
            if pvptalent.bitter_chill.enabled and debuff.chains_of_ice.up then
                applyDebuff( "target", "chains_of_ice" )
            end

            if conduit.eradicating_blow.enabled then removeBuff( "eradicating_blow" ) end

        end,

        auras = {
            unleashed_frenzy = {
                id = 338501,
                duration = 6,
                max_stack = 5,
            }
        },

        copy = { 1228433, 49143 },
        bind = "frost_strike",
    },

    -- A sweeping attack that strikes all enemies in front of you for $s2 Frost damage. This attack always critically strikes and critical strikes with Frostscythe deal $s3 times normal damage. Deals reduced damage beyond $s5 targets. ; Consuming Killing Machine reduces the cooldown of Frostscythe by ${$s1/1000}.1 sec.
    frostscythe = {
        id = 207230,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if buff.obliteration.up then return 0 end
            if buff.exterminate.up  then return 1 end
            return 2
        end,
        spendType = "runes",

        talent = "frostscythe",
        startsCombat = true,

        range = 7,

        handler = function ()
            removeStack( "inexorable_assault", 3 )
            removeBuff( "obliteration" )

            -- Handle KM and Exterminate atomically to prevent flickering
            if buff.exterminate.up then
                if buff.killing_machine.up then KillingMachineConsumer() end

                addStack( "killing_machine" )
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = max ( active_dot.frost_fever, active_enemies )

                removeStack( "exterminate" )
            elseif buff.killing_machine.up then KillingMachineConsumer() end

            -- Horsemen interactions
            if talent.trollbanes_icy_fury.enabled and ( debuff.chains_of_ice_trollbane_slow.up or debuff.chains_of_ice_trollbane_damage.up ) then
                removeDebuff( "target", "chains_of_ice_trollbane_slow" )
                removeDebuff( "target", "chains_of_ice_trollbane_damage" )
                -- Apply AoE damage and slow to nearby enemies
                if active_enemies > 1 then
                    active_dot.chains_of_ice_trollbane_slow = min( active_dot.chains_of_ice_trollbane_slow, active_enemies )
                end
            end

            if talent.whitemanes_famine.enabled and debuff.undeath.up then
                addStack( "undeath" )
                -- Infect another nearby enemy
                active_dot.undeath = min( active_dot.undeath + 1, active_enemies )
            end
        end,
    },

    -- Talent: Summons a frostwyrm who breathes on all enemies within $s1 yd in front of you, dealing $279303s1 Frost damage and slowing movement speed by $279303s2% for $279303d.
    frostwyrms_fury = {
        id = 279302,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "frostwyrms_fury",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            -- Apocalypse Now: Frostwyrm's Fury calls upon all 4 Horsemen for 20 sec
            if talent.apocalypse_now.enabled then
                -- Summon all 4 Horsemen
                applyBuff( "mograines_might" )           -- Mograine
                applyDebuff( "target", "undeath" )       -- Whitemane
                applyDebuff( "target", "chains_of_ice_trollbane_slow" )   -- Trollbane
                applyDebuff( "target", "chains_of_ice_trollbane_damage" ) -- Trollbane
                applyBuff( "apocalyptic_conquest" )      -- Nazgrim
            end
            applyDebuff( "target", "frostwyrms_fury" )
            if set_bonus.tier30_4pc > 0 then applyDebuff( "target", "lingering_chill" ) end
            if legendary.absolute_zero.enabled then applyDebuff( "target", "absolute_zero" ) end
        end,
    },

    -- Talent: Summon glacial spikes from the ground that advance forward, each dealing ${$195975s1*$<CAP>/$AP} Frost damage and applying Razorice to enemies near their eruption point.
    glacial_advance = {
        id = 194913,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "runic_power",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "razorice", nil, min( 5, debuff.razorice.stack + 1 ) )
            if active_enemies > 1 then active_dot.razorice = active_enemies end
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
            if talent.icy_onslaught.enabled then addStack( "icy_onslaught" ) end
        end,
    },

    -- Talent: Blast the target with a frigid wind, dealing ${$s1*$<CAP>/$AP} $?s204088[Frost damage and applying Frost Fever to the target.][Frost damage to that foe, and reduced damage to all other enemies within $237680A1 yards, infecting all targets with Frost Fever.]    |Tinterface\icons\spell_deathknight_frostfever.blp:24|t |cFFFFFFFFFrost Fever|r  $@spelldesc55095
    howling_blast = {
        id = 49184,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = function() return talent.bind_in_darkness.enabled and buff.rime.up and "shadowfrost" or "frost" end,

        spend = function () return buff.rime.up and 0 or 1 end,
        spendType = "runes",

        talent = "howling_blast",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "frost_fever" )
            active_dot.frost_fever = max( active_dot.frost_fever, active_enemies )

            if talent.bind_in_darkness.enabled and debuff.reapers_mark.up then applyDebuff( "target", "reapers_mark", nil, debuff.reapers_mark.stack + 2 ) end
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end

            if buff.rime.up then
                removeBuff( "rime" )
                if talent.rage_of_the_frozen_champion.enabled then gain( 8, "runic_power") end
                if talent.avalanche.enabled then applyDebuff( "target", "razorice", nil, min( 5, debuff.razorice.stack + 1 ) ) end
                if legendary.rage_of_the_frozen_champion.enabled then gain( 8, "runic_power" ) end
                if set_bonus.tier30_2pc > 0 then addStack( "wrath_of_the_frostwyrm" ) end
                if talent.frostbound_will.enabled then reduceCooldown( "empower_rune_weapon", 6 ) end
                if buff.breath_of_sindragosa.up then buff.breath_of_sindragosa.expires = buff.breath_of_sindragosa.expires + 0.8 end
                if talent.cryogenic_chamber.enabled then addStack( "cryogenic_chamber" ) end
            end

            if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end
        end,
    },

    -- Talent: Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s3% for $d.
    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = function () return 120 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
        gcd = "off",

        talent = "icebound_fortitude",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "icebound_fortitude" )
        end,
    },

    -- Draw upon unholy energy to become Undead for $d, increasing Leech by $s1%$?a389682[, reducing damage taken by $s8%][], and making you immune to Charm, Fear, and Sleep.
    lichborne = {
        id = 49039,
        cast = 0,
        cooldown = function() return 120 - ( talent.deaths_messenger.enabled and 30 or 0 ) end,
        gcd = "off",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "lichborne" )
            if conduit.hardened_bones.enabled then applyBuff( "hardened_bones" ) end
        end,
    },

    -- Talent: Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    mind_freeze = {
        id = 47528,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "mind_freeze",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if conduit.spirit_drain.enabled then gain( conduit.spirit_drain.mod * 0.1, "runic_power" ) end
            if talent.coldthirst.enabled then
                gain( 10, "runic_power" )
                reduceCooldown( "mind_freeze", 3 )
            end
            interrupt()
        end,
    },

    -- Talent: A brutal attack $?$owb==0[that deals $<2hDamage> Physical damage.][with both weapons that deals a total of $<dualWieldDamage> Physical damage.]
    obliterate = {
        id = 49020,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if buff.obliteration.up then return 0 end
            if buff.exterminate.up then return 1 end
            return 2
        end,
        spendType = "runes",

        talent = "obliterate",
        startsCombat = true,
        school = function() if buff.killing_machine.up then return "frost" end return "physical" end,

        cycle = function ()
            if hero_tree.rider_of_the_apocalypse then return "chains_of_ice_trollbane_slow" end
        end,
        cycle_to = true,

        handler = function ()
            if talent.inexorable_assault.enabled then removeStack( "inexorable_assault", 3 ) end
            removeBuff( "obliteration" )

            -- Handle KM and Exterminate atomically to prevent flickering
            if buff.exterminate.up then
                if buff.killing_machine.up then KillingMachineConsumer() end

                addStack( "killing_machine" )
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = max ( active_dot.frost_fever, active_enemies )

                removeStack( "exterminate" )
            elseif buff.killing_machine.up then KillingMachineConsumer() end

            -- Horsemen interactions
            if talent.trollbanes_icy_fury.enabled and ( debuff.chains_of_ice_trollbane_slow.up or debuff.chains_of_ice_trollbane_damage.up ) then
                removeDebuff( "target", "chains_of_ice_trollbane_slow" )
                removeDebuff( "target", "chains_of_ice_trollbane_damage" )
                -- Apply AoE damage and slow to nearby enemies (simulated)
                if active_enemies > 1 then
                    active_dot.chains_of_ice_trollbane_slow = min( active_dot.chains_of_ice_trollbane_slow, active_enemies )
                end
            end

            if talent.whitemanes_famine.enabled and debuff.undeath.up then
                addStack( "undeath" )
                -- Infect another nearby enemy (simulated by expanding the debuff)
                active_dot.undeath = min( active_dot.undeath + 1, active_enemies )
            end
            -- Koltira's Favor is not predictable.
            if conduit.eradicating_blow.enabled then addStack( "eradicating_blow", nil, 1 ) end
        end,

        auras = {
            -- Conduit
            eradicating_blow = {
                id = 337936,
                duration = 10,
                max_stack = 2
            }
        }
    },

    -- Activates a freezing aura for $d that creates ice beneath your feet, allowing party or raid members within $a1 yards to walk on water.    Usable while mounted, but being attacked or damaged will cancel the effect.
    path_of_frost = {
        id = 3714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,

        handler = function ()
            applyBuff( "path_of_frost" )
        end,
    },

    -- The power of frost increases your Strength by $s1% for $d.
    pillar_of_frost = {
        id = 51271,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "pillar_of_frost",
        startsCombat = false,

        handler = function ()
            applyBuff( "pillar_of_frost" )
            -- Delay by 0.1s to help match trinket usage to simulation.
            buff.pillar_of_frost.applied = buff.pillar_of_frost.applied + 0.1

            if talent.frozen_dominion.enabled then spec.abilities.remorseless_winter.handler() end

            -- 2-piece tier set: Pillar of Frost summons Trollbane for 10 sec
            if hero_tree.rider_of_the_apocalypse and set_bonus.tww3_rider_of_the_apocalypse >= 2 then
                applyDebuff( "target", "chains_of_ice_trollbane_slow" )
                applyDebuff( "target", "chains_of_ice_trollbane_damage" )
            end

            -- Legacy
            if set_bonus.tier30_2pc > 0 then
                applyDebuff( "target", "frostwyrms_fury" )
                applyDebuff( "target", "lingering_chill" )
            end
            if azerite.frostwhelps_indignation.enabled then applyBuff( "frostwhelps_indignation" ) end
            virtual_rp_spent_since_pof = 0
        end,
    },

    --[[ Pours dark energy into a dead target, reuniting spirit and body to allow the target to reenter battle with $s2% health and at least $s1% mana.
    raise_ally = {
        id = 61999,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            -- trigger voidtouched [97821]
        end,
    }, ]]

    -- Talent: Raises a $?s58640[geist][ghoul] to fight by your side.  You can have a maximum of one $?s58640[geist][ghoul] at a time.  Lasts $46585d.
    raise_dead = {
        id = 46585,
        cast = 0,
        cooldown = function() return 120 - ( talent.deaths_messenger.enabled and 30 or 0 ) end,
        gcd = "off",

        talent = "raise_dead",
        startsCombat = true,

        usable = function () return not pet.alive, "cannot have an active pet" end,

        handler = function ()
            summonPet( "ghoul" )
        end,
    },

    -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage,
    reapers_mark = {
        id = 439843,
        cast = 0.0,
        cooldown = function() return 60.0 - ( 15 * talent.reapers_onslaught.rank ) end,
        gcd = "spell",

        spend = 2,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        cycle = "reapers_mark",

        handler = function()
            applyDebuff( "target", "reapers_mark" )

            if talent.grim_reaper.enabled then
                addStack( "killing_machine" )
            end

            if talent.reaper_of_souls.enabled then
                setCooldown( "soul_reaper", 0 )
                applyBuff( "reaper_of_souls" )
            end

            -- 2-Set bonus: Casting Reaper's Mark grants 1 stack of Exterminate
            if talent.exterminate.enabled and set_bonus.tww3 >= 2 then
                applyBuff( "exterminate", nil, 1 )
            end
        end,

    },

    -- Talent: Drain the warmth of life from all nearby enemies within $196771A1 yards, dealing ${9*$196771s1*$<CAP>/$AP} Frost damage over $d and reducing their movement speed by $211793s1%.
    remorseless_winter = {
        id = 196770,
        cast = 0,
        cooldown = function () return pvptalent.dead_of_winter.enabled and 45 or 20 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        notalent = "frozen_dominion",

        handler = function ()
            applyBuff( "remorseless_winter" )
            removeBuff( "cryogenic_chamber" )

            if active_enemies > 2 and legendary.biting_cold.enabled then
                applyBuff( "rime" )
            end
            if active_enemies > 2 and talent.biting_cold.enabled then
                applyBuff( "rime" )
            end

            if conduit.biting_cold.enabled then applyDebuff( "target", "biting_cold" ) end
            -- if pvptalent.deathchill.enabled then applyDebuff( "target", "deathchill" ) end
        end,

        auras = {
            -- Conduit
            biting_cold = {
                id = 337989,
                duration = 8,
                max_stack = 10
            }
        }
    },

    -- Talent: Sacrifice your ghoul to deal $327611s1 Shadow damage to all nearby enemies and heal for $s1% of your maximum health. Deals reduced damage beyond $327611s2 targets.
    sacrificial_pact = {
        id = 327574,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 20,
        spendType = "runic_power",

        talent = "sacrificial_pact",
        startsCombat = false,

        toggle = "defensives",

        usable = function () return pet.alive, "requires an undead pet" end,

        handler = function ()
            dismissPet( "ghoul" )
            gain( 0.25 * health.max, "health" )

            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
        end,
    },

    -- Talent: Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper.     After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() if talent.reaper_of_souls.enabled and buff.reaper_of_souls.up then return 0 end return 1 end,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "soul_reaper" )
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
        end,
    },

    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0,
        spendType = "runes",

        pvptalent = "strangulate",
        startsCombat = false,
        texture = 136214,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "strangulate" )
        end,
    },

    -- Talent: Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.    While active, your movement speed cannot be reduced below $m2%.
    wraith_walk = {
        id = 212552,
        cast = 4,
        fixedCast = true,
        channeled = true,
        cooldown = 60,
        gcd = "spell",

        talent = "wraith_walk",
        startsCombat = false,

        start = function ()
            applyBuff( "wraith_walk" )
        end,
    },

    -- Stub.
    any_dnd = {
        name = function() return "|T136144:0|t |cff00ccff[Any " .. ( class.abilities.death_and_decay and class.abilities.death_and_decay.name or "Death and Decay" ) .. "]|r" end,
        cast = 0,
        cooldown = 0,
        copy = "any_dnd_stub"
    }
} )

spec:RegisterRanges( "frost_strike", "mind_freeze", "death_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Frost DK",
} )

--[[ Estimation of whether or not random RP gains can happen, in an attempt to smooth out changing recommendations
spec:RegisterStateExpr( "breath_possible_gains", function ()
    -- Initialize possible gains
    local possible_gains = 0

    -- Check for weapon swing before next GCD
    if state.nextMH and state.nextMH > 0 and state.nextMH <= ( state.now + state.gcd.remains ) then
        possible_gains = possible_gains + 5
    end

    -- Calculate next Frost Fever tick dynamically
    if state.debuff.frost_fever.up then
        local tick_time = state.debuff.frost_fever.tick_time or 3 -- Default tick time if unavailable
        local last_tick = state.debuff.frost_fever.last_tick or state.debuff.frost_fever.applied
        local next_tick = last_tick + tick_time

        -- Check if Frost Fever will tick before the next GCD ends
        if next_tick <= ( state.now + state.gcd.remains ) then
            possible_gains = possible_gains + ( active_dot.frost_fever * 3 )
        end
    end

    return possible_gains
end )--]]

spec:RegisterSetting( "dnd_while_moving", true, {
    name = strformat( "Allow %s while moving", Hekili:GetSpellLinkWithTexture( spec.abilities.death_and_decay.id ) ),
    desc = strformat( "If checked, then allow recommending %s while the player is moving otherwise only recommend it if the player is standing still.", Hekili:GetSpellLinkWithTexture( spec.abilities.death_and_decay.id ) ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "ams_usage", "damage", {
    name = strformat( "%s Requirements", Hekili:GetSpellLinkWithTexture( spec.abilities.antimagic_shell.id ) ),
    desc = strformat( "The default priority uses |W%s|w to generate |W%s|w regardless of whether there is incoming magic damage. "
        .. "You can specify additional conditions for |W%s|w usage here.\n\n"
        .. "|cFFFFD100Damage|r:\nRequires incoming magic damage within the past 3 seconds.\n\n"
        .. "|cFFFFD100Defensives|r:\nRequires the Defensives toggle to be active.\n\n"
        .. "|cFFFFD100Defensives + Damage|r:\nRequires both of the above.\n\n"
        .. "|cFFFFD100None|r:\nUse on cooldown if priority conditions are met.",
        spec.abilities.antimagic_shell.name, _G.RUNIC_POWER, _G.RUNIC_POWER,
        spec.abilities.antimagic_shell.name ),
    type = "select",
    width = "full",
    values = {
        ["damage"] = "Damage",
        ["defensives"] = "Defensives",
        ["both"] = "Defensives + Damage",
        ["none"] = "None"
    },
    sorting = { "damage", "defensives", "both", "none" }
} )

spec:RegisterPack( "Frost DK", 20250826, [[Hekili:L3ZFVTnUs(zj4H6ANM4yjhNTBrCa6139WT92BVfB2hU)4WfzAz5yDrwYpj54Mhm8N9Bgs9dsjskAB5KwCal62ksnC(nNz4yXhSE4pF4(zKuVh(n7b2Jg8r7B6Bn06Mb)8d3N(YkVhUFfX9jYJWFjKSe(Z)wCus6Uj)1)DCKxcIiZqiKeTo2fgDrA6QKpD1vp6NUy90(UrlVkXF56asQFuOBmzEk(VDVAAq00Rsx4THeVbMQF4vF2fNYVh7hf7N(YV6NKMC1mV5K1bPW)NKU4Pq)hxK6mhx)(iqE4(PR9ds)LWhMkJegD9WhUNSoDru8d3FV)YVayN)SzESP7LaV)LxUBYFUWB3K)lsm8huez3K79ijrW)F4UVIW7YbF8s7B(0UjF(3)vyWxcD3nbEVpsixpB6pxohRFcMZF4DzS3Z(jamtjXp6bCQKnKvjCtZUgOSTNoWD0SY5maxUFj0p1NeqN8d3hGmeKttI8G)3VrLBEHKPbEZE4FbEmL99W9u2tI7laVLrLX(RyJ85iaP(JOuc7FcdK6f7tE4(U7MmD9859FYpiWp8rNLexGp41pjfK87MmgqWDt2UD3evtC9QDt6SBs86qyfUBmY5M0J(FWtre7zphVqVL(EjSXFMalmG595WwNvGO)HuqgQGYIMgGymkN5q(taMdG)f3aphMamb51aAnScAvbfI9xwaUusGxykJ4MgToCMZgyD7N9Ymm6SDtMfLnhN5Ep7f3p139ja5kP4frBOy70asskIdxRtO7KKg7)KaZzMhd3i)tWOYLNVmIIO0rzOjHYnKt6JA5LnJ)KSGKIVbJcN5vYGKO2CB(lFgN6t8kNvrripkFibwpst5OTuc7g9YufAlcyaO5iGd7N6UuZwaX(PJ3gObKvod5JgPKRrd9Nvca5YTsq9yaXfC35qM9mj0LYfSgyg0QkdoJAWNPkuWYGvrqdJsrRaUgj2jAE2(kix7q8BPsqAPYpTCj5jLSKlYTQ6VvaB0PADKiJkDOuiAc4FxGO62TJNlkSz39uia7UNTjSS99ofBDiz)RdEJcnMzv3m61WJSkdyzkvv3OAV9JuDlhbLYdhBZfz(UWt2a75cry676Ns3Fz4afmYwFNcPkWsC7BU3ZQ4RAh5NyxmYjmTBl824Jjl3IcVl5tDPpygop2Z7F6XJYsmSJaf4eW)uXRMZxX)wWApAK1zyFv8ZmcOiuXMGcoT500JI9ws8dzbmzpGItoSe3Cb58SOnHoUl8CFsMxeJiiPyl)Q(O7S(ljFt0756WfrbVGkOEHpMUix8kDmPaRxb8Y4ftJc9Eem(NbwXXKWcF25qLBCowQ6rvTQ9Y1dRfqWUjwmKsR3vCcn6WQhVGA(M5oiatK5jTzz0cV4ihGx61NM28uC98IPurUkaqSKvEXjG1w8tcu(nCBQHUe5Xlbpys8r3mQLl6Ired1EGn6NftEmkHiyruGNsNjp(E9UjNZjVe9UZOOb7M8bQaC4i6FBe9vOsmF3xCIctciRbtNCtUlPt2AaDAmoHG4HZ9RKngkycLU4G)PdOVToPF6MndDI9rLoGKWGhjRICjbVSkXZ56vUuLQb19edBWsEgvByo4tQ7(a4jrXjEbEjjqmeHWkN7cuiSO)wz0P7M4dSqV)XASedKuA8lzBIFb88V56TcEiwCgi6jeLbMnIHBw47cpIQwba4)SWp)Ujlapq48OqdaY6qeFaXzg6VBsg(ZwBmaaoTELHuxrnYXlib(7dl0QUw2wNTNYyxJ1hVdD5w4Ns)lvg(yP2kgfzxMg7LmqbAGQmNzUMe0mLTqLE7RgsqoJzD4l(EbZq1RqpG7hdC)KL1cXjaeXHPO7V4hFj3fhqXFu9EyfmggxSCFm98CK)XCsRLB3lVIKkiajHDKtYGwy4tEPwvJRK94(Pw9DH4eCsHWu5mjlcBkBEowm301c1RC8LKqQ91EWHYXb7(lijo5krz7JuoiNR8mqGtOgkSkREQ0DJSOmTKGOuowGS8SRWNSvXNSnJpz3aFY(y4tw64twheFYUoFYwBY8L6tvyUC8TguUQj99t6lxXMZarQn5TuBYECqT0fII9EyGSGvr55BEjEzIZ81XVWzY1c2bfRIUyiLZS2F3ifOIAxJISQtT5NI5z5mBnl1g2UacXYxzp8VSGeg6rjrKTxGwj4U1batEkWQwNqh3BEuSxjpprAbF0zT3GPEnBXFG0A3lVs7NwR9BLw7jYzOI5zRxRvIduv1TYehOY9SShEE6YnHzKLKh9CuzNMfc3r5qGp3XUngCXEQICMUqKklI9zAQUqEPf0Gx86yQTFeScvAFKfCS510ONQYAynQIhXFbCcgfg8c(NE4Fq9)vqA7MSko6zWhc86egd5I8zG5bfLsZAbFTcYasSbEKpa4qpF24ndTPryYscWHQ1R6y7K5WvlN2epvMQLBlvlFVDGOslx7(fVHA5sWlTA5wVLA5s8GQ6SyXx0bImywTe3uXv62eZ1OT9kRlNwNZA1P72Go2TMGin6p2iO0ZqYwuoRt6vkyqXN6ZrOGdjwNwvlG9Osz)QOSm5t8auDUZJUZYpCp1NOqxDv0mtR9rc66Jv4PO4L10AZvHQoVYcGAnOmPoj1Okwrrx7uJKrCJ78zQdlk5Q(ypmiAYof0nxv5cJ2OSAqgxfCzLMNZ5Lb(dRCspLH5sjB1hVY3TKTb0mDE1kq2nvpLorEHT2EgW0vTAgiILEdPTYZ91wJBaBoKTcBJISvlOaxIxgIPgLRWbqr6X7M7zaD7Q0TH9RvO3uIsYaUm3F2QY3G)8pmEdZMnaUR4eFKRki7OYTvFw5NzILzvN4SeyY2v9io8rbxtYp8vZdXPqbmM4pZX7zknnBwsFVVH91yMcyLXWEX8onj4xM85hQ)YLdwj9)ItxtLGAOE)lM0zc7H46UItT8iLxY4G5C3o1hk)8hKWZnkqPlL)UsECZsc9mC1HmzedVP2h4iz7mZKIG86BVqm1ffVJ4lyuiN7L1Mm193uJq9YyAyQv8Fx6SM4dJaBynRAdzOoCVmUeZppDJIO1bsp3uXjW3JakAnm0xEjYHVMddkuusDOyD5oxDBrLezn)sV6H)CBXzyxQ0kEe2f0N8t4oJcoNUnfBbWa249(nOpxIfElPRSd9K)3aeP8SmgQoMRc9gjGQ)81biVZDbUHywk53ooVjeAqgyLZiSOeug7iF(yZKqEQQvrRqSQJztrkCCXTeefnJP1ldYQJQQzidrZ4fZAFCjqwDZR3iKjXUeSVpwJN6ocl1XR0iScWnBtC(Fxp7XLG0Ico17N2i4W(ege0KahW5FGucFVZ3MZpLFShvGjfWQtSUPnCAyNb6y1Bxkorn5r8LsJ9DFIEGod12SFnHo6WLUkrh1OQ0SbpN2EjOlpPlNM3PNocxTZwzHzbb2H9FIBQ4UlRdDy)Dh83yd7xAtwdvG)wBGzFTQZhx37k2dZ0woCf4RlA5uI0wAoRHv8Nxc(Cvu(E8OS4AjVe6Q4aMXA4I6SiZEpcYz)sqwwj7k3W)DAcPPCwJZlalxrNmzTlaT0jlGf6rZceONy3fr3ziRrHyPPDCIlB1Il7xzXL9pgIlPOPXIR9V1wvEeiDQEcj(quXlPhcuI3mNepY8Oy)1lDwrCb)ypL1RLIwiII4kNQYB)G9K7IHLDw6H0fQvuVvYoTpa2zvlMkL()TFqPSt7s25b05SLsoekfh8UC5wXOPAAq1Mxl7MxlBH1srtyAQtY8ZNSPZd9GoyjzNFVUt(uDtpia)g9SEvdnorpAKoyEm9z52PwRkFMsGxc93sCjSYtose98dEoGwJgEVz0N1JIOwdY8Us)V7QbbPBHkJaTmIaR5fsjbAzebAjHaTvsGI7GyvO(tpN1QHuBOMSIdCFFuOLnoVoxnkddTTclqlPvnO59WHGM(7sUJiwFjqpJQQXqVhlRMMHuUpPILLg29ZqUX4kK91bW6NF4(nK4qS)1F4E6p)Fy)NO40DtGDE2n59z)YGE)UjXE)J1qwGqCmjryXjiRtJwssXh4UGe(Oxs)DF9x9XI68ZFA3KVefcRfD43NJ8CDvdaW0iUHsfhRR1361i4e9IvdI1g2qGwywNLjMealzkNqGxawRbQHRsgRTAgRs4zPNZwBytHAJuV0PCkHEjCTAxLwLWtJbSezNU5A261(4)ry1PbQnk9A2SRLHEjCTBz7ovWtZEksKDMRB86H)hJFd1qTrPNb(nAxOxc3HNe7e1qTrS1a7K2f6nd3d1huBdVRpj6TQHAJCtd0BBxO3mCpuFcTn8g1Q09Pf6nd3dZYYuS(WGoa3DFvsm)fLM)97vu)QdaHpZwfgxCdlsYnlNYZUwNGIBoNuWFYa8BeEhTk7yYG8TXUFqLyRtx91OVZzguHCaiAWX39UIhPQO8Jh0B7wJwOcqPTi8V7D6qiy161G28RbB51NR0itPqBsDCNADjuBybDFnbZ2OUV85Csb)jdWVr4TAxc2NuDFj44BRlbjiKuxcV(SLxFUsJmLcTj1H0FeHGRgOnEGAswjtEhdx(JiYh9afFJ(59zIcixDoTm4pceFje1Vx8l6W7YP0Ua)iWAySeqJoWpvlMloT2FrockybYA0H75tOnb8rGV4jfPdDZgVfbRkKvD2TADBPVkpQbQjUGQUsM8ogU8ADBPp6m9avVFf5ZPLb)rG4Q8SiDkTlWpcSwNhfLtR9xKJGcK7DrYeAtaFe4Ru)l1hVfbRkKvDzUahfU9jHV4mBvIUAfOAET8YGiVJkWFJsEJzGx98A5Lrlv8tNITqub0JkCA1y6HLk5jg8gayt3Cq7Ephp4vzMQgYyhSibyzp2iGyjhiw7jqAw2yqDlBBWBaGBw2yq2shp43xrFRi1og9NA155mvTQvhv9OLqzk4D4SD7zkCf1B7w1qtFvp00zH9oVRv)rFqH1imQIUieFVpiSSiJ7YksJEVZAWGE96Dxx9vQvtNbwfbTAebTKIGwvqqBbemxr47Cj5vVDsYRmsswhbF1KKziyPJVp2gM(QaYE5esDx)DAAQf1ndN5RNrnyf9isNhfeeTH(H7LaIAWP4gp8Zj4A6hxq0bj97NfRbo3nb)XpH)aVsZNxye98vxhkm7zZWjpJKsMss8(0UVsByxmqF8Sz)f6XYIW)AriJh6k(tOkAUp2JO)L)YUjVMx2u7(kUI3xa(VGGhfglxIxFa4D50N4UuOWj)xjPa5nP8oKcPpCG)1V55UMsJLFGgXZEg)3p6hcu6Kp7IF)LtqEy4LliXlNVoiNFKW(AN1pdyy3YcRuc9ZrwMuoP83CZfaV2h)ELHl3l7MWQpoaI5GSbjp8R98YSFHXSFGYSF8RWZXJgNveC28lld(7te(yPHFb2Ge1sWExoynaIfekUJhMoEW70pF0XEPRJbPPfUIb4NEM8NmO)iGAYOU(fNf)hgx415cSfFhl6(4IOvJP9K9f0fDS1fLD98yaKx4gfoZhH54s7sEptQoxcTNhr52cNMdS14ZF4DAWd88h2hgQ9HYqTBtg6P54U2FgQId0zFyOzbxKXifv)YbENZe2UqFHm5v74z5aPl8CH4YLoywr3KogxjTKo(c8DLoc6)EV4q2s5q2k4qguQxE9i5CijjTkDWACi5f9t64v4q2hbhQmaRAQrsloZ(aBBvWwrHFUyFaE(p7LQ(tS59NyX5n5ycoxzS5hsO5hxows0Vmo68kbNRmlRJljlj(imo88krNlMMLjQhk(Xr1cAj1hjx0kIT3nwKymbRlxl2VQOA2IQ)KxVhq3wo019zGVwWK4LijeGh77OsEK5yiC4LTb5zIFaLfvGwJ5UQJyW6llIIW4Y(Sqe9y6dqGHSP8F)V59e497)bVQtxg9mMnqyONRxscbx8cPf7M)yAmj0DbgBkcKeco)V87)DgsMfaBg2aSg8R4b)3tbglkNHLufb(ZfiHrjUGnKxsOj5SgpBJPEUK1fFFFZZ4iYlj890VFVEZ8DtzFUIOSTqA2fCiZyrPucOTgqcXFYy6JrItBfHu5xGIXwD6EM8V7sGlR6F0L2UT(ZUZAupD8GKOsobYiAb(qn9vevY(APLXaePZ7gBBiHUAnEt3rhOt15N1TU3nsGnO7naUJ9G3CUtIxi1m1DwECnL(w50H42kIJFw6dTgCZD5Z(e1KdAfXAt9Ux)d6spCRrPVX2TcFe8U1EGAmP4ZjwosiD1YHu23YLTBztR(NrMosFELxhW8CAT6L(fOTrHGSl7lvJuf6960TIoS12TsVsVgpQirJQxLx90RyWF1zLX5K)P4StXU7XsUIUU9MoiKUDyzCrCQCQLAT9Y3aXUQYAPl5m95MLVWxFEM0Qd3heTBVzWh6oC0hgDovwv9Y8Q3LDTgCoIW92x213DeaWW3n57SlVR6XdqtnJTv)C)VLJryqbRdXIBrOdJEzbKPbxPZljwAKIzsIHFOR15Dn)gvRZz5UoQEhQXCpel7EtJpEwtrSR5JdyixCaMJR3n4WWw14Q6VjWgOy3qztY3J2Ea4Ew)ubFXCA93nU7ndU0EW5YDbrz(MfzywuYLwYJXC(bn6LSXLh48f(Zht5MsUhAU7JY3(mJyHqB0WX2ULTJJgULGSQazXpu85eJfIEC5Ww8Jfd0o2J8FYZwPrYjwEw0ssio7LKKhDEMCJTAM(SfOpB90NTM872p6Zsb9v)h2Mo6ZM5i(yUbMQQzRqjaFC2xCWXuvc5AeDpRXpW7B3wqHuMt9BiPEhKILY6YMVLNemUj7NIvtTJl57LFc0KLmAzzvUBS43n6M061kcniz)mxls8yD7h79)l1cERf4gyfBR2k2(vXk2a3Ngl)SBz5xdwXTL)APv99qTIT1jclXWVZSI)Ewl4TwG)xyhD93PxEynQqYcw8q8BxwxkfvLFSfew)b4JflNsxjo9z2i6uyotD0ZqsoDotrDTeoXhULdvUuzlWzhPqJhRMOYcM1RAfZSg1OOYwUOYaJZMfv28IkZnKeev1CNDAfv2nkQSE9fv4mOxkdfPikJg6QJ4B0vkwmtLgSkvpKD8F5uutROoR1gF5Ensqm2FDMSzPWJvDIQiNnKyKv8NqfDVxAbL6NvCwudc2HTFEPO(7OB0Bb3QlI9Mp(95Dh2MnB6VjAZcpYmwlITYliyS1Gb3m4kAbjU0pC(A8le47V73zTb1VK9GBVIChTOzb7bKhzz)twxX4wxgn)sk3canxFxrRKhd481sRKz5h(C0tEoEFl1loKeq1cymm2DuqogJmLcLMCjv2T(uTYZLDzq95)J73nji6r)6LGJecgKeyeNKfaPGqNRWnaFFUVRF6DxpOdTInoSUKR)C)yWwMaHIGIKBPhaPHYFU8IZL5SBZU6XoRGoRD6fJQUYX1QAMa4ecaT(jbK5xPYvCxVC)asV67aTlLfSlhpZp(HocO)Dwch(ICu)7dSuKjxjEuenBmC2ozyT4T3JIudAYpu5Hnv90S6PT9Z4z3TirCcX3FGy86QVSqjHVzW3JYH9c9fflvwnwvp1aof5dlVg5B3INk0D00D0D2T7lsCyRxJe(Et3gK7Ob4AdCcJWQwdbKbO67XPnW6oYpSDmM0AQUIBIuEuUxiCfeYwuLqTjthS)m0P(jXm(m5wPIBOHnlJ8W5v1CdfEm5VMBuNuGMwursJLOSMl5Lv4dQU3Z4QgtrJtuLLnSn4y02Uz)yz1jvfTwdE6D1yknM4WL1FNApshB6W4ks0c2x(sNZksdSV9I8CDLmp(P1ywsA0fRt7VAQNcEjkUL9eDlXphUl7oopOXI3HE5Xuw9I1J9CPxOB3AZVksUi2Q7PSlTtuSZLp1Vb96j0Pfdh9HC9aH2SqwNxqrPZh1Rd31f3Td6pAVXXcjJzx(D3o(gD8ilS1hYObXR5ojyQzzFftC9jbC5EvEb1zC(xcBYvCl0DqVo)vnNHVsLBuodFlXloUdcxlUD4oO3w4QmJZusWXLspp0Nl5ozt3ciBdsLUap42178HzNXHMGTpFiTbp488iElQL1OPrExWUT2ym1Q73nSriaXovEbSrTi2n5ZrE7M8hrPv(9salgFF9q9VO2sKwVvfED6WI9ByVE12HU0pF5krl9LGTkIlafviM8UGraoaobzP8PUnNiuE5XwGCCCCFxSOXrbbtrZRKGOnO)XIq)oCIuGdkI1QIZS9wSfrBOtDAaHfqpBFhSXYH3ktDNYRNI)euDWwZa2Uywu2tDMJnmF)uWcbaJmHaBASoWQQyid(v7d0okACuk3wXymRkgMsy3(RFvdIiHZ(QdyvuVOo)TJ4oxJYMQSiy9cmtkAvAlQsZGd4Cn46pUgEkjPwWoZyyR1SQ6KFmGgbHdz2Z4EQ0nAKiXBq(Qqow0mKMSN1pg(BBfkD)0gojlznLevrH3zpxg6U03t35E3K)mR)HRVHTWE7J5yaT52mclstwgk2Wrn0ABxV6T72lAXqKMlQsJWMosolPBhoq9QzGC1a3Ansd7fJteNAzJRgLsTJz2d3NSYZ9HFZEKf9gs7H)Vp]] )
