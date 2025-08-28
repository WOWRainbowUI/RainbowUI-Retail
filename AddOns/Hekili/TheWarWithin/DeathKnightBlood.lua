-- DeathKnightBlood.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 250 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local ForEachAura = AuraUtil.ForEachAura
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID

spec:RegisterResource( Enum.PowerType.Runes, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.runes
            val = math.floor( val )

            if val == 6 then return -1 end
            return r.expiry[ val + 1 ] - time
        end,

        stop = function( x )
            return x == 6
        end,

        value = 1
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
            t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end

        local rpGainMultiplier = state.buff.rune_of_hysteria.up and 1.2 or 1
        state.gain( amount * 10 * rpGainMultiplier, "runic_power" )

        if state.talent.rune_strike.enabled then
            state.gainChargeTime( "rune_strike", amount )
        end

        -- Handle Eternal Rune Weapon interactions (Dancing Rune Weapon synergy).
        if state.buff.dancing_rune_weapon.up and state.azerite.eternal_rune_weapon.enabled then
            local maxExtension = state.buff.dancing_rune_weapon.duration + 5
            if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < maxExtension then
                state.buff.eternal_rune_weapon.expires = min(
                    state.buff.dancing_rune_weapon.applied + maxExtension,
                    state.buff.dancing_rune_weapon.expires + ( 0.5 * amount )
                )
            end
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
            return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

        elseif k == "add" then
            return t.gain

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )

spec:RegisterResource( Enum.PowerType.RunicPower, {
    swarming_mist = {
        aura = "swarming_mist",

        last = function ()
            local app = state.buff.swarming_mist.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.swarming_mist.tick_time ) * class.auras.swarming_mist.tick_time
        end,

        interval = function () return class.auras.swarming_mist.tick_time end,
        value = function () return min( 15, state.true_active_enemies * 3 ) end,
    },
    -- TODO: Add blooddrinker
} )

local spendHook = function( amt, resource )
    -- Runic Power
    if amt > 0 and resource == "runic_power" then
        if talent.red_thirst.enabled then reduceCooldown( "vampiric_blood", floor( amt / 5 ) ) end -- it seems to reduce it by intervals of 5, not 10
        if talent.icy_talons.enabled then addStack( "icy_talons", nil, 1 ) end
    end
    -- Runes
    if resource == "rune" and amt > 0 then
        if active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end

        if talent.rune_carved_plates.enabled then
            addStack( "rune_carved_plates" )
        end
    end

end

local bpUnits = {}

local myName = UnitName( "player" )
local myRuneWeapon = 0x2111

local matchThreshold = 0.02
local MINE = 1
local RUNE_WEAPON = 2

local dnd_damage_ids = {
    [52212] = "death_and_decay",
    [156000] = "defile"
}

local dmg_events = {
    SPELL_DAMAGE = 1,
    SPELL_PERIODIC_DAMAGE = 1
}

local last_dnd_tick, dnd_spell = 0, "death_and_decay"

spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName )
    if spellID == 55078 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) then
        local source

        if sourceName == myName then source = MINE
        elseif sourceFlags == myRuneWeapon then source = RUNE_WEAPON end

        if not source then return end

        local unit = UnitTokenFromGUID( destGUID )
        if not unit then return end

        local storage = bpUnits[ destGUID ] or {}

        ForEachAura( unit, "HARMFUL", nil, function( info )
            if info.spellId ~= 55078 then return end

            if storage[ info.auraInstanceID ] then
                return
            end

            -- May require tuning.
            local tOffset = math.abs( info.expirationTime - info.duration - GetTime() )
            if tOffset < matchThreshold then
                insert( storage, info.auraInstanceID )
                while( #storage > 3 ) do storage[ remove( storage, 1 ) ] = nil end

                storage[ info.auraInstanceID ] = source
                return true
            end
        end, true )

        bpUnits[ destGUID ] = storage
    end

    if sourceGUID == state.GUID and dnd_damage_ids[ spellID ] and dmg_events[ subtype ] then
        last_dnd_tick = GetTime()
        dnd_spell = dnd_damage_ids[ spellID ]
        return
    end
end )

local dnd_model = setmetatable( {}, {
    __index = function( t, k )
        if k == "ticking" then
            -- Disabled
            -- if state.query_time - class.abilities.any_dnd.lastCast < 10 then return true end
            return debuff.death_and_decay.up

        elseif k == "remains" then
            return debuff.death_and_decay.remains

        end

        return false
    end
} )

spec:RegisterStateTable( "death_and_decay", dnd_model )
spec:RegisterStateTable( "defile", dnd_model )

spec:RegisterStateExpr( "dnd_ticking", function ()
    return death_and_decay.ticking
end )

spec:RegisterStateExpr( "dnd_remains", function ()
    return death_and_decay.remains
end )

spec:RegisterHook( "spend", spendHook )

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
    cleaving_strikes               = {  76073,  316916, 1 }, -- Heart Strike hits up to $s1 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for $s2 sec
    coldthirst                     = {  76083,  378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants $s1 Runic Power and reduces its cooldown by $s2 sec
    control_undead                 = {  76059,  111673, 1 }, -- Dominates the target undead creature up to level $s1, forcing it to do your bidding for $s2 min
    death_pact                     = {  76075,   48743, 1 }, -- Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s2% of your max health for $s3 sec
    death_strike                   = {  76071,   49998, 1 }, -- Focuses dark power into a strike that deals $s$s2 Physical damage and heals you for $s3% of all damage taken in the last $s4 sec, minimum $s5% of maximum health
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

    -- Blood
    blood_boil                     = {  76170,   50842, 1 }, -- Deals $s$s2 Shadow damage and infects all enemies within $s3 yds with Blood Plague.  Blood Plague A shadowy disease that drains $s6 health from the target over $s7 sec
    blood_feast                    = { 102243,  391386, 1 }, -- Anti-Magic Shell heals you for $s1% of the damage it absorbs
    blood_tap                      = {  76039,  221699, 1 }, -- Consume the essence around you to generate $s1 Rune. Recharge time reduced by $s2 sec whenever a Bone Shield charge is consumed
    blooddrinker                   = { 102244,  206931, 1 }, -- Drains $s2 health from the target over $s3 sec$s$s4 The damage they deal to you is reduced by $s5% for the duration and $s6 sec after channeling it fully. You can move, parry, dodge, and use defensive abilities while channeling this ability. Generates $s7 additional Runic Power over the duration
    bloodied_blade                 = { 102242,  458753, 1 }, -- Parrying an attack grants you a charge of Bloodied Blade, increasing your Strength by $s1%, up to $s2% for $s3 sec. At $s4 stacks, your next parry consumes all charges to unleash a Heart Strike at $s5% effectiveness, and increases your Strength by $s6% for $s7 sec
    bloodshot                      = {  76125,  391398, 1 }, -- While Blood Shield is active, you deal $s1% increased Physical damage
    bloodworms                     = {  76174,  195679, 1 }, -- Your auto attacks have a chance to summon a Bloodworm. Bloodworms deal minor damage to your target for $s1 sec and then burst, healing you for $s2% of your missing health. If you drop below $s3% health, your Bloodworms will immediately burst and heal you
    bone_collector                 = {  76171,  458572, 1 }, -- When you would pull an enemy generate $s1 charge of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by $s4. Each melee attack against you consumes a charge. Lasts $s5 sec or until all charges are consumed
    bonestorm                      = {  76127,  194844, 1 }, -- Consume up to $s2 Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing $s$s3 Shadow damage every $s4 sec, and healing you for $s5% of your maximum health every time it deals damage (up to $s6%). Deals reduced damage beyond $s7 targets. Lasts $s8 sec per Bone Shield charge spent and rapidly regenerates a Bone Shield every $s9 sec
    carnage                        = { 102245,  458752, 1 }, -- Blooddrinker and Consumption now contribute to your Mastery: Blood Shield. Each time an enemy strikes your Blood Shield, the cooldowns of Blooddrinker and Consumption have a chance to be reset
    coagulopathy                   = {  76038,  391477, 1 }, -- Enemies affected by Blood Plague take $s1% increased damage from you and Death Strike increases the damage of your Blood Plague by $s2% for $s3 sec, stacking up to $s4 times
    consumption                    = { 102244,  274156, 1 }, -- Strikes all enemies in front of you with a hungering attack that deals $s$s2 Physical damage and heals you for $s3% of that damage. Deals reduced damage beyond $s4 targets. Causes your Blood Plague damage to occur $s5% more quickly for $s6 sec. Generates $s7 Runes
    dancing_rune_weapon            = {  76138,   49028, 1 }, -- Summons a rune weapon for $s1 sec that mirrors your melee attacks and bolsters your defenses. While active, you gain $s2% parry chance
    everlasting_bond               = {  76130,  377668, 1 }, -- Summons $s1 additional copy of Dancing Rune Weapon and increases its duration by $s2 sec
    foul_bulwark                   = {  76167,  206974, 1 }, -- Each charge of Bone Shield increases your maximum health by $s1%
    gorefiends_grasp               = {  76042,  108199, 1 }, -- Shadowy tendrils coil around all enemies within $s1 yards of a hostile or friendly target, pulling them to the target's location
    heart_strike                   = {  76169,  206930, 1 }, -- Instantly strike the target and $s2 other nearby enemy, causing $s$s3 Physical damage, and reducing enemies' movement speed by $s4% for $s5 sec, plus $s6 Runic Power per additional enemy struck
    heartbreaker                   = {  76135,  221536, 1 }, -- Heart Strike generates $s1 additional Runic Power per target hit
    heartrend                      = {  76131,  377655, 1 }, -- Heart Strike has a chance to increase the damage of your next Death Strike by $s1%
    hemostasis                     = {  76137,  273946, 1 }, -- Each enemy hit by Blood Boil increases the damage and healing done by your next Death Strike by $s1%, stacking up to $s2 times
    improved_bone_shield           = {  76142,  374715, 1 }, -- Bone Shield increases your Haste by $s1%
    improved_heart_strike          = {  76126,  374717, 2 }, -- Heart Strike damage increased by $s1%
    improved_vampiric_blood        = {  76140,  317133, 2 }, -- Vampiric Blood's healing and absorb amount is increased by $s1% and duration by $s2 sec
    insatiable_blade               = {  76129,  377637, 1 }, -- Dancing Rune Weapon generates $s1 Bone Shield charges. When a charge of Bone Shield is consumed, the cooldown of Dancing Rune Weapon is reduced by $s2 sec
    iron_heart                     = {  76172,  391395, 1 }, -- Blood Shield's duration is increased by $s1 sec and it absorbs $s2% more damage
    leeching_strike                = {  76145,  377629, 1 }, -- Heart Strike heals you for $s1% health for each enemy hit while affected by Blood Plague
    mark_of_blood                  = {  76139,  206940, 1 }, -- Places a Mark of Blood on an enemy for $s1 sec. The enemy's damaging auto attacks will also heal their victim for $s2% of the victim's maximum health
    marrowrend                     = {  76168,  195182, 1 }, -- Smash the target, dealing $s$s2 Physical damage and generating $s3 charges of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by $s6. Each melee attack against you consumes a charge. Lasts $s7 sec or until all charges are consumed
    ossified_vitriol               = {  76146,  458744, 1 }, -- When you lose a Bone Shield charge the damage of your next Marrowrend is increased by $s1%, stacking up to $s2%
    ossuary                        = {  76144,  219786, 1 }, -- While you have at least $s1 Bone Shield charges, the cost of Death Strike is reduced by $s2 Runic Power. Additionally, your maximum Runic Power is increased by $s3
    perseverance_of_the_ebon_blade = {  76124,  374747, 1 }, -- When Crimson Scourge is consumed, you gain $s1% Versatility for $s2 sec
    purgatory                      = {  76133,  114556, 1 }, -- An unholy pact that prevents fatal damage, instead absorbing incoming healing equal to the damage prevented, lasting $s1 sec. If any healing absorption remains when this effect expires, you will die. This effect may only occur every $s2 min
    rapid_decomposition            = {  76141,  194662, 1 }, -- Your Blood Plague and Death and Decay deal damage $s1% more often. Additionally, your Blood Plague leeches $s2% more Health
    red_thirst                     = {  76132,  205723, 1 }, -- Reduces the cooldown on Vampiric Blood by $s1 sec per $s2 Runic Power spent
    reinforced_bones               = {  76143,  374737, 1 }, -- Increases Armor gained from Bone Shield by $s1% and it can stack $s2 additional times
    relish_in_blood                = {  76147,  317610, 1 }, -- While Crimson Scourge is active, your next Death and Decay heals you for $s1 health per Bone Shield charge and you immediately gain $s2 Runic Power
    rune_tap                       = {  76166,  194679, 1 }, -- Reduces all damage taken by $s1% for $s2 sec
    sanguine_ground                = {  76041,  391458, 1 }, -- You deal $s1% more damage and receive $s2% more healing while standing in your Death and Decay
    shattering_bone                = {  76128,  377640, 1 }, -- When Bone Shield is consumed it shatters dealing $s$s3 Shadow damage to nearby enemies$s$s4 This damage is tripled while you are within your Death and Decay
    tightening_grasp               = {  76165,  206970, 1 }, -- Gorefiend's Grasp cooldown is reduced by $s1 sec and it now also Silences enemies for $s2 sec
    tombstone                      = {  76139,  219809, 1 }, -- Consume up to $s1 Bone Shield charges. For each charge consumed, you gain $s2 Runic Power and absorb damage equal to $s3% of your maximum health for $s4 sec
    umbilicus_eternus              = {  76040,  391517, 1 }, -- After Vampiric Blood expires, you absorb damage equal to $s1 times the damage your Blood Plague dealt during Vampiric Blood
    vampiric_blood                 = {  76173,   55233, 1 }, -- Embrace your undeath, increasing your maximum health by $s1% and increasing all healing and absorbs received by $s2% for $s3 sec
    voracious                      = {  76043,  273953, 1 }, -- Death Strike's healing is increased by $s1% and grants you $s2% Leech for $s3 sec

    -- Deathbringer
    bind_in_darkness               = {  95043,  440031, 1 }, -- Blood Boil deals $s2% increased damage, and is now Shadowfrost$s$s3 Shadowfrost damage applies $s4 stacks to Reaper's Mark and $s5 stacks when it is a critical strike
    dark_talons                    = {  95057,  436687, 1 }, -- Marrowrend and Heart Strike have a $s1% chance to grant $s2 stacks of Icy Talons and increase its maximum stacks by the same amount for $s3 sec. Runic Power spending abilities count as Shadowfrost while Icy Talons is active
    deaths_messenger               = {  95049,  437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by $s1 sec
    expelling_shield               = {  95049,  439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by $s1% for $s2 sec
    exterminate                    = {  95068,  441378, 1 }, -- After Reaper's Mark explodes, your next $s3 Marrowrends cost $s4 Rune and summon $s5 scythes to strike your enemies. The first scythe strikes your target for $s$s6 Shadowfrost damage and has a $s7% chance to reap a Bonestorm for $s8 sec, the second scythe strikes all enemies around your target for $s$s9 Shadowfrost damage. Deals reduced damage beyond $s10 targets
    grim_reaper                    = {  95034,  434905, 1 }, -- Reaper's Mark initial strike grants $s1 charges of Bone Shield. Reaper's Mark explosion deals up to $s2% increased damage based on your target's missing health
    pact_of_the_deathbringer       = {  95035,  440476, 1 }, -- When you suffer a damaging effect equal to $s1% of your maximum health, you instantly cast Death Pact at $s2% effectiveness. May only occur every $s3 min. When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by $s4 sec
    reaper_of_souls                = {  95034,  440002, 1 }, -- When you apply Reaper's Mark, the cooldown of Soul Reaper is reset, your next Soul Reaper costs no runes, and it explodes on the target regardless of their health. Soul Reaper damage is increased by $s1%
    reapers_mark                   = {  95062,  439843, 1 }, -- Viciously slice into the soul of your enemy, dealing $s$s2 Shadowfrost damage and applying Reaper's Mark. Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $s3 sec or reaching $s4 stacks, the mark explodes, dealing $s5 damage per stack. Reaper's Mark travels to an unmarked enemy nearby if the target dies
    reapers_onslaught              = {  95057,  469870, 1 }, -- Reduces the cooldown of Reaper's Mark by $s1 sec, but the amount of Marrowrends empowered by Exterminate is reduced by $s2
    rune_carved_plates             = {  95035,  440282, 1 }, -- Each Rune spent reduces the magic damage you take by $s1% and each Rune generated reduces the physical damage you take by $s2% for $s3 sec, up to $s4 times
    soul_rupture                   = {  95061,  437161, 1 }, -- When Reaper's Mark explodes, it deals $s1% of the damage dealt to nearby enemies and causes them to deal $s2% reduced Physical damage to you for $s3 sec
    swift_and_painful              = {  95032,  443560, 1 }, -- If no enemies are struck by Soul Rupture, you gain $s1% Strength for $s2 sec. Wave of Souls is $s3% more effective on the main target of your Reaper's Mark
    wave_of_souls                  = {  95036,  439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing $s$s2 Shadowfrost damage both ways to all enemies caught in its path. Wave of Souls critical strikes cause enemies to take $s3% increased Shadowfrost damage for $s4 sec, stacking up to $s5 times, and it is always a critical strike on its way back
    wither_away                    = {  95058,  441894, 1 }, -- Blood Plague deals its damage $s1% faster, and the second scythe of Exterminate applies Blood Plague

    -- Sanlayn
    bloodsoaked_ground             = {  95048,  434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by $s1% and your chance to gain Vampiric Strike is increased by $s2%
    bloody_fortitude               = {  95056,  434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional $s1% based on your missing health. Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by $s2 sec
    frenzied_bloodthirst           = {  95065,  434075, 1 }, -- Essence of the Blood Queen stacks $s1 additional times and increases the damage of your Death Coil and Death Strike by $s2% per stack
    gift_of_the_sanlayn            = {  95053,  434152, 1 }, -- While Dancing Rune Weapon is active you gain Gift of the San'layn. Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by $s1%, and Vampiric Strike replaces your Heart Strike for the duration
    incite_terror                  = {  95040,  434151, 1 }, -- Vampiric Strike and Heart Strike cause your targets to take $s1% increased Shadow damage, up to $s2% for $s3 sec. Vampiric Strike benefits from Incite Terror at $s4% effectiveness
    infliction_of_sorrow           = {  95033,  434143, 1 }, -- When Vampiric Strike damages an enemy affected by your Blood Plague, it extends the duration of the disease by $s1 sec, and deals $s2% of the remaining damage to the enemy. After Gift of the San'layn ends, you gain a charge of Death and Decay, and your next Heart Strike consumes the disease to deal $s3% of their remaining damage to the target
    newly_turned                   = {  95064,  433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to $s1% of your maximum health
    pact_of_the_sanlayn            = {  95055,  434261, 1 }, -- You store $s1% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires
    sanguine_scent                 = {  95055,  434263, 1 }, -- Your Death Coil and Death Strike have a $s1% increased chance to trigger Vampiric Strike when damaging enemies below $s2% health
    the_blood_is_life              = {  95046,  434260, 1 }, -- Dancing Rune Weapon summons a Blood Beast to attack your enemy for $s1 sec. Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing $s2% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount. Deals reduced damage beyond $s3 targets
    vampiric_aura                  = {  95056,  434100, 1 }, -- Your Leech is increased by $s1%. While Lichborne is active, the Leech bonus of this effect is increased by $s2%, and it affects $s3 allies within $s4 yds
    vampiric_speed                 = {  95064,  434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by $s1%. Activating Death's Advance or Wraith Walk increases $s2 nearby allies movement speed by $s3% for $s4 sec
    vampiric_strike                = {  95051,  433901, 1 }, -- Your Death Coil and Death Strike have a $s1% chance to make your next Heart Strike become Vampiric Strike. Vampiric Strike heals you for $s2% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by $s3%, up to $s4% for $s5 sec
    visceral_strength              = {  95045,  434157, 1 }, -- When Crimson Scourge is consumed, you gain $s1% Strength for $s2 sec. When Blood Boil hits $s3 or more targets, it generates $s4 charge of Bone Shield
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor              = 5587, -- (410301) Death Strike reduces all Physical damage taken by $s1% for $s2 sec
    dark_simulacrum                = 3511, -- (77606) Places a dark ward on an enemy player that persists for $s1 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell
    death_chain                    =  609, -- (203173) Chains $s2 enemies together, dealing $s$s3 Shadow damage and causing $s4% of all damage taken to also be received by the others in the chain. Lasts for $s5 sec
    decomposing_aura               = 3441, -- (199720) All enemies within $s1 yards slowly decay, losing up to $s2% of their max health every $s3 sec. Max $s4 stacks. Lasts $s5 sec
    last_dance                     =  608, -- (233412) Reduces the cooldown of Dancing Rune Weapon by $s1% and its duration by $s2%
    murderous_intent               =  841, -- (207018) You focus the assault on this target, increasing their damage taken by $s1% for $s2 sec. Each unique player that attacks the target increases the damage taken by an additional $s3%, stacking up to $s4 times. Your melee attacks refresh the duration of Focused Assault
    price_of_progress              = 5712, -- (1233429) You sacrifice $s1% of your health every $s2 sec and in exchange you cannot be slowed below $s3% of normal speed, and you are immune to forced movement effects and knockbacks. Lasts until canceled
    rot_and_wither                 =  204, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to $s1% of damage dealt
    spellwarden                    = 5592, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by $s1 sec
    strangulate                    =  206, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for $s1 sec
} )

-- Auras
spec:RegisterAuras( {
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1
    },
    -- Pulling enemies to your location and dealing $323798s1 Shadow damage to nearby enemies every $t1 sec.
    -- https://wowhead.com/beta/spell=315443
    abomination_limb = {
        id = 315443,
        duration = function () return legendary.abominations_frenzy.enabled and 16 or 12 end,
        tick_time = 1,
        max_stack = 1
    },
    -- Talent: Recently pulled  by Abomination Limb and can't be pulled again.
    -- https://wowhead.com/beta/spell=323710
    abomination_limb_immune = {
        id = 323710,
        duration = 4,
        type = "Magic",
        copy = 383312
    },
    -- Talent: Absorbing up to $w1 magic damage.  Immune to harmful magic effects.
    -- https://wowhead.com/beta/spell=48707
    antimagic_shell = {
        id = 48707,
        duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * ( ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 7 or 5 ) ) + ( conduit.reinforced_shell.mod * 0.001 ) end,
        max_stack = 1
    },
    antimagic_zone = {
        id = 145629,
        duration = function () return 6 + ( 2 * talent.assimilation.rank ) end,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=221562
    asphyxiate = {
        id = 221562,
        duration = 5,
        mechanic = "stun",
        type = "Magic",
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
    -- Next Howling Blast deals Shadowfrost damage.
    bind_in_darkness = {
        id = 443532,
        duration = 3600,
        max_stack = 1,
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
        duration = function() return 24 * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.85 or 1 ) * ( buff.consumption.up and 0.7 or 1 ) * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        type = "Disease",
        max_stack = 1
    },
    drw_blood_plague_1 = {
        duration = function() return 24 * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.85 or 1 ) * ( buff.consumption.up and 0.7 or 1 ) * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        type = "Disease",
    },
    drw_blood_plague_2 = {
        duration = function() return 24 * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.85 or 1 ) * ( buff.consumption.up and 0.7 or 1 ) * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        type = "Disease",
    },
    drw_blood_plague = {
        alias = { "drw_blood_plague_1", "drw_blood_plague_2" },
        aliasType = "debuff",
        aliasMode = "longest",
        duration = function() return 24 * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.85 or 1 ) * ( buff.consumption.up and 0.7 or 1 ) * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        max_stack = 2,
        type = "Disease",
    },
    -- Absorbs $w1 Physical damage$?a391398 [ and Physical damage increased by $s2%][].
    -- https://wowhead.com/beta/spell=77535
    blood_shield = {
        id = 77535,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Draining $s1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=206931
    blooddrinker = {
        id = 206931,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    blooddrinker_debuff = {
        id = 458687,
        duration = 5.0,
        max_stack = 1,
    },
    -- Strength increased by ${$W1}.1%.
    bloodied_blade = {
        id = 460499,
        duration = 15.0,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $s1%.; Chance to gain Vampiric Strike increased by $434033s2%.
    bloodsoaked_ground = {
        id = 434034,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by ${$w1*$STR/100}.; $?a374715[Haste increased by $w4%.][]
    bone_shield = {
        id = 195181,
        duration = 30.0,
        max_stack = function() return talent.reinforced_bones.enabled and 12 or 10 end,

        -- Affected by:
        -- foul_bulwark[206974] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_bone_shield[374715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- reinforced_bones[374737] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- reinforced_bones[374737] #1: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'value': 37, 'schools': ['physical', 'fire', 'shadow'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Talent: Dealing $196528s1 Shadow damage to nearby enemies every $t3 sec, and healing for $196545s1% of maximum health for each target hit (up to ${$s1*$s4}%).
    -- https://wowhead.com/beta/spell=194844
    bonestorm = {
        id = 194844,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    brittle = {
        id = 374557,
        duration = 5,
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
    coagulating_blood = PTR and {
        id = 463730,
        duration = 3600,
        max_stack = 100
    } or {},
    -- Talent: Blood Plague damage is increased by $s1%.
    -- https://wowhead.com/beta/spell=391481
    coagulopathy = {
        id = 391481,
        duration = 8,
        max_stack = 5
    },
    -- Your next Chains of Ice will deal $281210s1 Frost damage.
    -- https://wowhead.com/beta/spell=281209
    cold_heart = {
        id = 281209,
        duration = 3600,
        max_stack = 20
    },
    -- Your Blood Plague deals damage $w5% more often.
    consumption = {
        id = 274156,
        duration = 6,
        max_stack = 1,
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
    -- Your next Death and Decay costs no Runes and generates no Runic Power.
    -- https://wowhead.com/beta/spell=81141
    crimson_scourge = {
        id = 81141,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Parry chance increased by $s1%.
    -- https://wowhead.com/beta/spell=81256
    dancing_rune_weapon = {
        id = 81256,
        duration = function () return ( pvptalent.last_dance.enabled and 6 or 8 ) + ( talent.everlasting_bond.enabled and 6 or 0 ) end,
        type = "Magic",
        max_stack = 1,
        active_weapons = function() return
            buff.dancing_rune_weapon.up and 1 + talent.everlasting_bond.rank or 0
        end
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=56222
    dark_command = {
        id = 56222,
        duration = 3,
        mechanic = "taunt",
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
    -- $?s206930[Heart Strike will hit up to ${$m3+2} targets.]?s207311[Clawing Shadows will hit ${$55090s4-1} enemies near the target.]?s55090[Scourge Strike will hit ${$55090s4-1} enemies near the target.][Dealing Shadow damage to enemies inside Death and Decay.]
    -- https://wowhead.com/beta/spell=188290
    death_and_decay = {
        id = 188290,
        duration = 10,
        tick_time = function() return talent.rapid_decomposition.enabled and 0.85 or 1 end,
        max_stack = 1,
        copy = "death_and_decay_actual"
    },
    deaths_due = {
        id = 324165,
        duration = function () return legendary.rampant_transference.enabled and 12 or 10 end,
        max_stack = 1,
        copy = "deaths_due_buff"
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
    -- Weakened by Death's Due, damage dealt to $@auracaster reduced by $s1%.$?a333388[    Toxins accumulate, increasing Death's Due damage by $s3%.][]
    -- https://wowhead.com/beta/spell=324164
    deaths_due_zone = {
        id = 324164,
        duration = 12,
        max_stack = 4
    },
    -- Casting speed reduced by $w1%.
    expelling_shield = {
        id = 440739,
        duration = 6.0,
        max_stack = 1,
    },
    exterminate = {
        id = 441416,
        duration = 30,
        max_stack = function () return talent.reapers_onslaught.enabled and 1 or 2 end,
        copy = { 447954, "exterminate_painful_death" }
    },
    -- Reduces damage dealt to $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327092
    famine = {
        id = 327092,
        duration = 6,
        max_stack = 3
    },
    -- Suffering $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=55095
    frost_fever = {
        id = 55095,
        duration = function() return 24 * ( state.spec.frost and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( state.spec.frost and talent.wither_away.enabled and 0.5 or 1 ) end,
        max_stack = 1
    },
    -- Absorbs damage.
    -- https://wowhead.com/beta/spell=207203
    frost_shield = {
        id = 207203,
        duration = 10,
        max_stack = 1
    },
    -- Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Movement speed reduced by $s5%.
    -- https://wowhead.com/beta/spell=206930
    heart_strike_206930 = {
        id = 206930,
        duration = 8,
        max_stack = 1,
        copy = 228645
    },
    heart_strike_228645 = {
        id = 228645,
        duration = 8,
        max_stack = 1
    },
    heart_strike = {
        alias = { "heart_strike_206930", "heart_strike_228645" },
        aliasMode = "first",
        aliasType = "debuff",
        duration = 8
    },
    -- Talent: Your next Death Strike deals an additional $s2% damage.
    -- https://wowhead.com/beta/spell=377656
    heartrend = {
        id = 377656,
        duration = 20,
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
    -- Talent: Damage and healing done by your next Death Strike increased by $s1%.
    -- https://wowhead.com/beta/spell=273947
    hemostasis = {
        id = 273947,
        duration = 15,
        max_stack = 5,
        copy = "haemostasis"
    },
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/beta/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
     -- Rooted.
    ice_prison = {
        id = 454787,
        duration = 4.0,
        max_stack = 1,
    },
    -- Attack speed increased by $w1%$?a436687[, and Runic Power spending abilities deal Shadowfrost damage.][.]
    icy_talons = {
        id = 194879,
        duration = 10.0,
        max_stack = function() return talent.dark_talons.enabled and 3 or 1 end,
        copy = { 443586, 436687, 443586, "dark_talons_icy_talons", "dark_talons_shadowfrost" }
    },
    -- Taking $w1% increased Shadow damage from $@auracaster.
    incite_terror = {
        id = 458478,
        duration = 15.0,
        max_stack = 5,
    },
    infliction_of_sorrow = {
        id = 460049,
        duration = 30,
        max_stack = 1
    },
    -- Time between auto-attacks increased by $w1%.
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4,
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( talent.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1,
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
        duration = function() return talent.unholy_endurance.enabled and 12 or 10 end,
        tick_time = 1,
        max_stack = 1
    },
    -- Death's Advance movement speed increase by 25%.
    -- https://wowhead.com/beta/spell=391547
    march_of_darkness = {
        id = 391547,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: Auto attacks will heal the victim for $206940s1% of their maximum health.
    -- https://wowhead.com/beta/spell=206940
    mark_of_blood = {
        id = 206940,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    mograines_might = {
        id = 444505,
        duration = 3600,
        max_stack = 1
    },
    -- $@spellaura281238
    -- https://wowhead.com/beta/spell=207256
    obliteration = {
        id = 207256,
        duration = 3600,
        max_stack = 1
    },
    ossified_vitriol = {
        id = 458745,
        duration = 8,
        max_stack = 5
    },
    ossuary = {
        id = 219788,
        duration = 3600,
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
    -- Talent: Versatility increased by $w1%
    -- https://wowhead.com/beta/spell=374748
    perseverance_of_the_ebon_blade = {
        id = 374748,
        duration = 6,
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
    -- Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=51271
    pillar_of_frost = {
        id = 51271,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    reaper_of_souls = {
        id = 469172,
        duration = 12,
        max_stack = 1
    },
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = function() if set_bonus.tww3 >= 4 then return 55 else
            return 40 end end,
        copy = "reapers_mark_debuff",
        onRemove = function()
            if set_bonus.tww3 >= 4 then
                applyBuff( "empowered_soul" )
            end
        end,
    },
    -- Magical damage taken reduced by $w1%.
    rune_carved_plates = {
        id = 440290,
        duration = 5.0,
        max_stack = 5
    },
    -- Absorb...
    -- https://wowhead.com/beta/spell=116888
    shroud_of_purgatory = {
        id = 116888,
        duration = 3,
        max_stack = 1,
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
    -- Talent: Damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=194679
    rune_tap = {
        id = 194679,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/beta/spell=343294
    soul_reaper = {
        id = 343294,
        duration = 5,
        tick_time = 5,
        max_stack = 1,
    },
    grim_reaper_soul_reaper = {
        id = 448229,
        duration = 5,
        tick_time = 5,
        max_stack = 1
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage dealt to $@auracaster reduced by $w1%.
    subduing_grasp = {
        id = 454824,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
        max_stack = 1,
    },
    -- Covenant: Surrounded by a mist of Anima, increasing your chance to Dodge by $s2% and dealing $311730s1 Shadow damage every $t1 sec to nearby enemies.
    -- https://wowhead.com/beta/spell=311648
    swarming_mist = {
        id = 311648,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    swift_and_painful = {
        id = 443560,
        duration =  8,
        max_stack = 1
    },
    -- Silenced.
    tightening_grasp = {
        id = 374776,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbing $w1 damage.
    -- https://wowhead.com/beta/spell=219809
    tombstone = {
        id = 219809,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Absorbing damage dealt by Blood Plague.
    -- https://wowhead.com/beta/spell=391519
    umbilicus_eternus = {
        id = 391519,
        duration = 10,
        max_stack = 1
    },
    -- Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=207289
    unholy_assault = {
        id = 207289,
        duration = 20,
        type = "Magic",
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
    -- Strength increased by $s1%.
    -- https://wowhead.com/beta/spell=53365
    unholy_strength = {
        id = 53365,
        duration = 15,
        max_stack = 1
    },
    -- Vampiric Aura's Leech amount increased by $s1% and is affecting $s2 nearby allies.
    vampiric_aura = {
        id = 434105,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Maximum health increased by $s4%. Healing and absorbs received increased by $s1%.
    -- https://wowhead.com/beta/spell=55233
    vampiric_blood = {
        id = 55233,
        duration = function () return 10 + ( talent.improved_vampiric_blood.rank * 2 ) + ( legendary.vampiric_aura.enabled and 3 or 0 ) end,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    vampiric_speed = {
        id = 434029,
        duration = 5.0,
        max_stack = 1,
    },
    vampiric_strike = {
        id = 433899,
        duration = 3600,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.  Erupts for $191685s1 damage split among all nearby enemies when the infected dies.
    -- https://wowhead.com/beta/spell=191587
    virulent_plague = {
        id = 191587,
        duration = 27,
        tick_time = 3,
        max_stack = 1
    },
    -- The touch of the spirit realm lingers....
    -- https://wowhead.com/beta/spell=97821
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
    },
    -- Leech increased by 15%.
    -- https://wowhead.com/beta/spell=274009
    voracious = {
        id = 274009,
        duration = 8,
        max_stack = 1,
    },
    -- Increases damage taken from $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327096
    war = {
        id = 327096,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    wave_of_souls = {
        id = 443404,
        duration = 15,
        max_stack = 2,
    },
    -- Talent: Movement speed increased by $w1%.  Cannot be slowed below $s2% of normal movement speed.  Cannot attack.
    -- https://wowhead.com/beta/spell=212552
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },
} )

-- Pets
spec:RegisterPets({
    blood_beast = {
        id = 217228,
        spell = "dancing_rune_weapon",
        duration = 12,
    },
    ghoul = {
        id = 26125,
        spell = "raise_dead",
        duration = 60
    },
})

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
            luck_of_the_draw = {
                id = 1218601,
                duration = function()
                    if set_bonus.tww2 >= 4 then return 12 end
                    return 10
                end,
                max_stack = 1
            },
            murderous_frenzy = {
                id = 1222698,
                duration = 6,
                max_stack = 1
            }
        }
    },
    tww1 = {
        items = { 212005, 212003, 212002, 212001, 212000 },
        auras = {
            unbreakable = {
                id = 457468,
                duration = 3600,
                max_stack = 1
            },
            unbroken = {
                id = 457473,
                duration = 6,
                max_stack = 1
            },
            piledriver = {
                id = 457506,
                duration = 3600,
                max_stack = 10
            },
            icy_vigor = {
                id = 457189,
                duration = 8,
                max_stack = 1
            },
            unholy_commander = {
                id = 456698,
                duration = 8,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207198, 207199, 207200, 207201, 207203 },
        auras = {
            ashen_decay_proc = {
                id = 425721,
                duration = 20,
                max_stack = 1
            },
            ashen_decay = {
                id = 425719,
                duration = 8,
                max_stack = 1,
                copy = "ashen_decay_debuff"
            }
        }
    },
    tier30 = {
        items = { 202464, 202462, 202461, 202460, 202459, 217223, 217225, 217221, 217222, 217224 },
        auras = {
            vampiric_strength = {
                id = 408356,
                duration = 5,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200405, 200407, 200408, 200409, 200410 },
        auras = {
            vigorous_lifeblood = {
                id = 394570,
                duration = 10,
                max_stack = 1
            }
        }
    },
    -- Legacy
    acherus_drapes = { items = { 132376 } },
    cold_heart = { items = { 151796 } }, -- chilled_heart stacks NYI
    consorts_cold_core = { items = { 144293 } },
    death_march = { items = { 144280 } },
    draugr_girdle_of_the_everlasting_king = { items = { 132441 } },
    koltiras_newfound_will = { items = { 132366 } },
    lanathels_lament = { items = { 133974 } },
    perseverance_of_the_ebon_martyr = { items = { 132459 } },
    rethus_incessant_courage = { items = { 146667 } },
    seal_of_necrofantasia = { items = { 137223 } },
    service_of_gorefiend = { items = { 132367 } },
    shackles_of_bryndaor = { items = { 132365 } }, -- NYI (Death Strike heals refund RP...)
    skullflowers_haemostasis = {
        items = { 144281 },
        auras = {
            haemostasis = {
                id = 235559,
                duration = 3600,
                max_stack = 5
            }
        }
    },
    soul_of_the_deathlord = { items = { 151740 } },
    soulflayers_corruption = { items = { 151795 } },
    the_instructors_fourth_lesson = { items = { 132448 } },
    toravons_whiteout_bindings = { items = { 132458 } },
    uvanimor_the_unbeautiful = { items = { 137037 } }
} )

spec:RegisterTotem( "ghoul", 1100170 ) -- Texture ID

spec:RegisterHook( "TALENTS_UPDATED", function()
    class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any " .. class.abilities.death_and_decay.name .. "]|r"
    local dnd = talent.defile.enabled and "defile" or "death_and_decay"

    class.abilities.any_dnd = class.abilities[ dnd ]
    rawset( cooldown, "any_dnd", nil )
    rawset( cooldown, "death_and_decay", nil )
    rawset( cooldown, "defile", nil )

    if dnd == "defile" then rawset( cooldown, "death_and_decay", cooldown.defile )
    else rawset( cooldown, "defile", cooldown.death_and_decay ) end
end )

local TriggerInflictionOfSorrow = setfenv( function ()
    applyBuff( "infliction_of_sorrow" )
    gainCharges( "death_and_decay", 1 )
end, state )

local TriggerUmbilicusEternus = setfenv( function()
    applyBuff( "umbilicus_eternus" )
end, state )

local BonestormShield = setfenv( function()
    addStack( "bone_shield" )
    gain( min( 0.1, 0.02 * active_enemies ) * health.max, "health" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if UnitExists( "pet" ) then
        for i = 1, 40 do
            local expires, _, _, _, id = select( 6, UnitDebuff( "pet", i ) )

            if not expires then break end

            if id == 111673 then
                summonPet( "controlled_undead", expires - now )
                break
            end
        end
    end

    -- Reset CDs on any Rune abilities that do not have an actual cooldown.
    for action in pairs( class.abilityList ) do
        local data = class.abilities[ action ]
        if data and data.cooldown == 0 and data.spendType == "runes" then
            setCooldown( action, 0 )
        end
    end

    if talent.umbilicus_eternus.enabled and buff.vampiric_blood.up then
        state:QueueAuraExpiration( "vampiric_blood", TriggerUmbilicusEternus, buff.vampiric_blood.expires )
    end

    if talent.infliction_of_sorrow.enabled and buff.gift_of_the_sanlayn.up then
        state:QueueAuraExpiration( "gift_of_the_sanlayn", TriggerInflictionOfSorrow, buff.gift_of_the_sanlayn.expires )
    end

    if IsActiveSpell( 433895 ) then applyBuff( "vampiric_strike" ) end

    if buff.bonestorm.up then
        local tick_time = buff.bonestorm.expires
        state:QueueAuraExpiration( "bonestorm", BonestormShield, tick_time )
        tick_time = tick_time - 1

        while( tick_time > query_time ) do
            state:QueueAuraEvent( "bonestorm", BonestormShield, tick_time, "AURA_TICK" )
            tick_time = tick_time - 1
        end
    end

    if debuff.blood_plague.up and bpUnits[ target.unit ] then
        -- Target has at least 1 Blood Plague, but we don't know whose it is.
        removeDebuff( "target", "blood_plague" )

        for id, caster in pairs( bpUnits[ target.unit ] ) do
            -- Index 1 - 3 used for caps.
            if id > 3 then
                local aura = "blood_plague"

                if caster == RUNE_WEAPON then
                    if debuff.drw_blood_plague_1.down then aura = "drw_blood_plague_1"
                    elseif debuff.drw_blood_plague_2.down then aura = "drw_blood_plague_2"
                    else break end
                end

                local info = GetAuraDataByAuraInstanceID( "target", id )
                if info then
                    applyDebuff( "target", aura, info.expirationTime - state.query_time )
                    debuff[ aura ].duration = info.duration
                    debuff[ aura ].applied = info.expirationTime - info.duration
                end
            end
        end
    end

    if buff.death_and_decay.up and buff.death_and_decay.duration > 4 then
        -- Extend by 4 to support on-leave effect.
        buff.death_and_decay.expires = buff.death_and_decay.expires + 4
    end

    -- Death and Decay tick time is 1s; if we haven't seen a tick in 2 seconds, it's not ticking.
    local last_dnd = action[ dnd_spell ].lastCast
    local dnd_expires = last_dnd + 10
    if now - last_dnd_tick < 2 and dnd_expires > now then
        applyDebuff( "target", "death_and_decay", dnd_expires - now )
        debuff.death_and_decay.duration = 10
        debuff.death_and_decay.applied = debuff.death_and_decay.expires - 10
    end
end )

spec:RegisterStateExpr( "save_blood_shield", function ()
    return ( settings.save_blood_shield or false )
end )

spec:RegisterStateExpr( "ibf_damage", function ()
    return health.max * ( settings.ibf_damage or 0 ) * 0.01
end )

spec:RegisterStateExpr( "rt_damage", function ()
    return health.max * ( settings.rt_damage or 0 ) * 0.01
end )

spec:RegisterStateExpr( "vb_damage", function ()
    return health.max * ( settings.vb_damage or 0 ) * 0.01
end )

spec:RegisterStateTable( "death_and_decay", setmetatable(
{ onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        return buff.death_and_decay.up

    elseif k == "remains" then
        return buff.death_and_decay.remains

    end

    return false
end } ) )

spec:RegisterStateFunction( "applyRunePlagues", function()
    -- Should only reach here when DRW is active.
    local num = min( 2, buff.dancing_rune_weapon.active_weapons )
    if num == 0 then return end

    for i = 1, num do
        if buff.drw_blood_plague_1.down then
            applyDebuff( "target", "drw_blood_plague_1" )
            if this_action == "blood_boil" then active_dot.drw_blood_plague_1 = true_active_enemies end
        elseif buff.drw_blood_plague_2.down then
            applyDebuff( "target", "drw_blood_plague_2" )
            if this_action == "blood_boil" then active_dot.drw_blood_plague_2 = true_active_enemies end
            return
        end
    end
end )

spec:RegisterStateTable( "drw", setmetatable(
{ onReset = function( self ) end },
{ __index = function( t, k )
    if k == "bp_ticking" then
        return buff.drw_blood_plague.up
    end

    return false
end } ) )

-- Abilities
spec:RegisterAbilities( {
    -- Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to all nearby enemies. Deals reduced damage beyond $s5 targets. Every $t1 sec, an enemy is pulled to your location if they are further than $383312s3 yds from you. The same enemy can only be pulled once every $383312d.
    abomination_limb = {
        id = 315443,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "abomination_limb" )
            if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
        end,

    },

    -- Talent: Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic damage and preventing application of harmful magical effects.$?s207188[][ Damage absorbed generates Runic Power.]
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = function () return talent.osmosis.enabled and 40 or 60 end,
        gcd = "off",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "antimagic_shell" )
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
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "asphyxiate" )
        end,
    },

    -- Talent: Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.    When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blinding_sleet" )
        end,
    },

    -- Talent: Deals $s1 Shadow damage$?s212744[ to all enemies within $A1 yds.][ and infects all enemies within $A1 yds with Blood Plague.    |Tinterface\icons\spell_deathknight_bloodplague.blp:24|t |cFFFFFFFFBlood Plague|r  $@spelldesc55078]
    blood_boil = {
        id = 50842,
        cast = 0,
        charges = 2,
        cooldown = 7.5,
        recharge = 7.5,
        hasteCD = true,
        school = function() return talent.bind_in_darkness.enabled and "shadowfrost" or "physical" end,
        gcd = "spell",

        talent = "blood_boil",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blood_plague" )
            active_dot.blood_plague = active_enemies
            if buff.dancing_rune_weapon.up then applyRunePlagues() end

            if talent.bind_in_darkness.enabled and debuff.reapers_mark.up then applyDebuff( "target", "reapers_mark", nil, debuff.reapers_mark.stack + 2 ) end

            if talent.visceral_strength.enabled and true_active_enemies > 1 then addStack( "bone_shield", 1 ) end

            if talent.hemostasis.enabled then
                addStack( "hemostasis", nil, min( 5, active_enemies ) )
            end

            if set_bonus.tier31_4pc > 0 and debuff.ashen_decay.up then
                debuff.ashen_decay.expires = debuff.ashen_decay.expires + 1
            end

            -- Legacy
            if legendary.superstrain.enabled then
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = active_enemies

                applyDebuff( "target", "virulent_plague" )
                active_dot.virulent_plague = active_enemies
            end
            if set_bonus.tier30_4pc > 0 and buff.vampiric_strength.up then buff.vampiric_strength.expires = buff.vampiric_strength.expires + 0.5 end
            if conduit.debilitating_malady.enabled then
                addStack( "debilitating_malady", nil, 1 )
            end
        end,

        auras = {
            -- Conduit
            debilitating_malady = {
                id = 338523,
                duration = 6,
                max_stack = 3
            }
        }
    },

    -- Talent: Consume the essence around you to generate $s1 Rune.    Recharge time reduced by $s2 sec whenever a Bone Shield charge is consumed.
    blood_tap = {
        id = 221699,
        cast = 0,
        charges = 2,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "blood_tap",
        startsCombat = false,

        handler = function ()
            gain( 1, "runes" )
        end
    },

    -- Drains $o1 health from the target over $d. The damage they deal to you is reduced by $s2% for the duration and $458687d after channeling it fully.; You can move, parry, dodge, and use defensive abilities while channeling this ability.; Generates ${$s3*4/10} additional Runic Power over the duration.
    blooddrinker = {
        id = 206931,
        cast = 3,
        channeled = true,
        cooldown = 30,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "blooddrinker",
        startsCombat = true,

        start = function ()
            applyDebuff( "target", "blooddrinker" )
        end,
    },

    -- Consume your Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing $196528s1 Shadow damage every $t3 sec, and healing you for $196545s1% of your maximum health every time it deals damage (up to ${$s1*$s4}%). Deals reduced damage beyond $196528s2 targets.; Lasts $d per Bone Shield charge spent and rapidly regenerates a Bone Shield every $t3 sec.
    bonestorm = {
        id = 194844,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "bonestorm",
        startsCombat = true,

        buff = "bone_shield",

        handler = function ()
            local consume = min( 5, buff.bone_shield.stack )
            gain( consume * 0.02 * health.max, "health" )

            local dur = 2 * consume
            applyBuff( "bonestorm", dur )
            removeStack( "bone_shield", consume )

            for i = 1, dur do
                state:QueueAuraEvent( "bonestorm", BonestormShield, query_time + i, i == dur and "AURA_EXPIRATION" or "AURA_TICK" )
            end

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end
        end,

        -- TODO Bone Shield regeneration (1 per sec.)
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 196528, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Talent: Shackles the target $?a373930[and $373930s1 nearby enemy ][]with frozen chains, reducing movement speed by $s1% for $d.
    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = function() return talent.ice_prison.enabled and 12 or 0 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        max_targets = function () return talent.proliferating_chill.enabled and 2 or 1 end,

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            if talent.ice_prison.enabled then applyDebuff( "target", "ice_prison" ) end
            if talent.proliferating_chill.enabled then active_dot.chains_of_ice = min( true_active_enemies, active_dot.chains_of_ice + 1 ) end
        end,
    },

    -- Strikes all enemies in front of you with a hungering attack that deals $sw1 Physical damage and heals you for ${$e1*100}% of that damage. Deals reduced damage beyond $s3 targets.; Causes your Blood Plague damage to occur $s5% more quickly for $d. ; Generates $s4 Runes.
    consumption = {
        id = 274156,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "consumption",
        startsCombat = true,

        handler = function ()
            gain( 2, "runes" )
            applyBuff( "consumption" )
            if talent.carnage.enabled then applyBuff( "blood_shield" ) end
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

        usable = function () return target.is_undead, "requires undead target" end,

        handler = function ()
            summonPet( "controlled_undead" )
        end,
    },

    -- Talent: Summons a rune weapon for $81256d that mirrors your melee attacks and bolsters your defenses.    While active, you gain $81256s1% parry chance.
    dancing_rune_weapon = {
        id = 49028,
        cast = 0,
        cooldown = function () return pvptalent.last_dance.enabled and 60 or 120 end,
        gcd = "spell",

        talent = "dancing_rune_weapon",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "dancing_rune_weapon" )
            if talent.gift_of_the_sanlayn.enabled then applyBuff( "gift_of_the_sanlayn", buff.dancing_rune_weapon.remains ) end
            if talent.insatiable_blade.enabled then addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 10 or 5 ) end
            if talent.the_blood_is_life.enabled then summonPet( "blood_beast" ) end

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end

            -- legacy
            if azerite.eternal_rune_weapon.enabled then applyBuff( "dancing_rune_weapon" ) end
            if legendary.crimson_rune_weapon.enabled then addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 10 or 5 ) end
        end,
    },

    -- Command the target to attack you.
    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,

        nopvptalent = "murderous_intent",

        handler = function ()
            applyDebuff( "target", "dark_command" )
        end,
    },


    dark_simulacrum = {
        id = 77606,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0,
        spendType = "runic_power",

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

    -- Corrupts the targeted ground, causing ${$341340m1*11} Shadow damage over $d to targets within the area.$?!c2[; While you remain within the area, your ][]$?s223829&!c2[Necrotic Strike and ][]$?c1[Heart Strike will hit up to $188290m3 additional targets.]?s207311&!c2[Clawing Shadows will hit up to ${$55090s4-1} enemies near the target.]?!c2[Scourge Strike will hit up to ${$55090s4-1} enemies near the target.][; While you remain within the area, your Obliterate will hit up to $316916M2 additional $Ltarget:targets;.]
    death_and_decay = {
        id = 43265,
        noOverride = 324128,
        cast = 0,
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 15,
        recharge = function () if talent.deaths_echo.enabled then return 15 end end,
        gcd = "spell",

        spend = function () return buff.crimson_scourge.up and 0 or 1 end,
        spendType = "runes",

        startsCombat = true,

        usable = function () return ( settings.dnd_while_moving or not moving ), "cannot cast while moving" end,

        handler = function ()
            if buff.crimson_scourge.up then
                if talent.perseverance_of_the_ebon_blade.enabled then applyBuff( "perseverance_of_the_ebon_blade" ) end
                removeBuff( "crimson_scourge" )
                if talent.relish_in_blood.enabled then
                    gain( 10, "runic_power" )
                    gain( 0.25 * buff.bone_shield.stack, "health" )
                end
            end

            if legendary.phearomones.enabled and buff.death_and_decay.down then
                stat.haste = stat.haste + ( state.spec.blood and 0.1 or 0.15 )
            end

            applyBuff( "death_and_decay_actual" )
        end,
    },


    death_chain = {
        id = 203173,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 1390941,

        pvptalent = "death_chain",

        handler = function ()
            applyDebuff( "target", "death_chain" )
            active_dot.death_chain = min( 3, active_enemies )
        end,
    },

    -- Fires a blast of unholy energy at the target$?a377580[ and $377580s2 additional nearby target][], causing $47632s1 Shadow damage to an enemy or healing an Undead ally for $47633s1 health.$?s390268[    Increases the duration of Dark Transformation by $390268s1 sec.][]
    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = false,

        handler = function ()
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
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 15,
        recharge = function () if talent.deaths_echo.enabled then return 15 end end,
        gcd = "off",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "death_grip" )
            setDistance( 5 )

            if legendary.grip_of_the_everlasting.enabled and buff.grip_of_the_everlasting.down then
                applyBuff( "grip_of_the_everlasting" )
            else
                removeBuff( "grip_of_the_everlasting" )
            end

            if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
        end,

        auras = {
            unending_grip = {
                id = 338311,
                duration = 5,
                max_stack = 1
            }
        }
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
            applyDebuff( "target", "death_pact" )
        end,
    },

    -- Talent: Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( ( talent.ossuary.enabled and buff.bone_shield.stack >= 5 ) and 40 or 45 )
                - ( talent.improved_death_strike.enabled and 5 or 0 )
                - ( buff.blood_draw.up and 10 or 0 )
                - ( set_bonus.tww2 >= 4 and buff.luck_of_the_draw.up and 10 or 0 )
                end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()

            applyBuff( "blood_shield" ) -- gain absorb shield
            gain( health.max * max( 0.074,  0.01 * buff.coagulating_blood.stack * 0.25 ) * ( talent.voracious.enabled and 1.15 or 1 ) * ( talent.improved_death_strike.enabled and 1.05 or 1 ) * ( talent.hemostasis.enabled and ( 1.08 * buff.hemostasis.stack ) or 1 ), "health" )
            removeBuff( "coagulating_blood" )

            if talent.hemostasis.enabled then removeBuff( "hemostasis" ) end
            if talent.coagulopathy.enabled then addStack( "coagulopathy" ) end
            if talent.voracious.enabled then applyBuff( "voracious" ) end
            if talent.heartrend.enabled then removeBuff( "heartrend" ) end
        end,
    },

    -- For $d, your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.    |cFFFFFFFFPassive:|r You cannot be slowed below $124285s1% of normal speed.
    deaths_advance = {
        id = 48265,
        cast = 0,
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = function () return azerite.march_of_the_damned.enabled and 40 or 45 end,
        recharge = function () if talent.deaths_echo.enabled then return ( azerite.march_of_the_damned.enabled and 40 or 45 ) end end,
        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyBuff( "deaths_advance" )
            if talent.march_of_darkness.enabled then applyBuff( "march_of_darkness" ) end
            if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
        end,

        auras = {
            -- Conduit
            fleeting_wind = {
                id = 338093,
                duration = 3,
                max_stack = 1
            }
        }
    },

    -- Talent: Reach out with necrotic tendrils, dealing $s1 Shadow damage and applying Blood Plague to your target and generating $s3 Bone Shield charges.    |Tinterface\icons\spell_deathknight_bloodplague.blp:24|t |cFFFFFFFFBlood Plague|r  $@spelldesc55078
    deaths_caress = {
        id = 195292,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blood_plague" )
            if buff.dancing_rune_weapon.up then applyRunePlagues() end

            local RWStrikes = 1 + buff.dancing_rune_weapon.active_weapons -- the 1 is your actual spell hit
            addStack( "bone_shield", nil, ( 2 * RWStrikes ) )

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end
        end,
    },

    -- Talent: Shadowy tendrils coil around all enemies within $A2 yards of a hostile or friendly target, pulling them to the target's location.
    gorefiends_grasp = {
        id = 108199,
        cast = 0,
        cooldown = function () return talent.tightening_grasp.enabled and 90 or 120 end,
        gcd = "spell",

        talent = "gorefiends_grasp",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            if talent.tightening_grasp.enabled then applyDebuff( "target", "tightening_grasp" ) end
        end,
    },

    -- Talent: Instantly strike the target and 1 other nearby enemy, causing $s2 Physical damage, and reducing enemies' movement speed by $s5% for $d$?s316575[    |cFFFFFFFFGenerates $s3 bonus Runic Power][]$?s221536[, plus ${$210738s1/10} Runic Power per additional enemy struck][].|r
    heart_strike = {
        id = function () return ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) and 433895 or 206930 end,
        known = 206930,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "heart_strike",
        texture = function () return ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) and 5927645 or 135675 end,
        startsCombat = true,

        max_targets = function () return buff.death_and_decay.up and talent.cleaving_strikes.enabled and 5 or 2 end,

        handler = function ()
            local strikes = 1 + buff.dancing_rune_weapon.active_weapons
            if talent.heartbreaker.enabled then
                gain( 15 + ( talent.heartbreaker.enabled and ( 2 * min( action.heart_strike.max_targets, true_active_enemies ) ) or 0 ) + 3 * buff.dancing_rune_weapon.active_weapons, "runic_power" )
            end

            -- San'Layn stuff
            if buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up then
                gain( 0.02 * health.max, "health" )
                addStack( "essence_of_the_blood_queen" ) -- TODO: mod haste

                if talent.infliction_of_sorrow.enabled and dot.blood_plague.ticking then
                    dot.blood_plague.expires = dot.blood_plague.expires + 3
                end

                removeBuff( "vampiric_strike" )
            else
                applyDebuff( "target", "heart_strike" )
                active_dot.heart_strike = min( true_active_enemies, active_dot.heart_strike + action.heart_strike.max_targets )

            end

            if talent.infliction_of_sorrow.enabled and buff.infliction_of_sorrow.up then
                removeDebuff( "target", "blood_plague" )
                removeBuff( "infliction_of_sorrow" )
            end
            if talent.incite_terror.enabled then applyDebuff( "target", "incite_terror", nil, min( debuff.incite_terror.stack + 1, debuff.incite_terror.max_stack ) ) end

            -- PvP
            if pvptalent.blood_for_blood.enabled then
                health.current = health.current - 0.03 * health.max
            end

            --- Legacy
            if set_bonus.tier31_4pc > 0 and debuff.ashen_decay.up and set_bonus.tier31_4pc > 0 then debuff.ashen_decay.expires = debuff.ashen_decay.expires + 1 end
            if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end
            if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then gainChargeTime( "vampiric_blood", 2 ) end
            if set_bonus.tier31_4pc > 0 and buff.ashen_decay_proc.up then
                applyDebuff( "target", "ashen_decay" )
                removeBuff( "ashen_decay_proc" )
            end
            if set_bonus.tier30_4pc > 0 and  buff.vampiric_strength.up then buff.vampiric_strength.expires = buff.vampiric_strength.expires + 0.5 end
        end,


        bind = "vampiric_strike",
        copy = { 206930, "vampiric_strike", 433895 }
    },

    -- Talent: Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s3% for $d.
    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = function () return 180 - ( talent.acclimation.enabled and 60 or 0 ) - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
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

        auras = {
            -- Conduit
            hardened_bones = {
                id = 337973,
                duration = 10,
                max_stack = 1
            }
        }

        -- deaths_messenger[437122] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Talent: Places a Mark of Blood on an enemy for $d. The enemy's damaging auto attacks will also heal their victim for $206940s1% of the victim's maximum health.
    mark_of_blood = {
        id = 206940,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        talent = "mark_of_blood",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mark_of_blood" )
        end,
    },

    -- Talent: Smash the target, dealing $s2 Physical damage and generating $s3 charges of Bone Shield.    |Tinterface\icons\ability_deathknight_boneshield.blp:24|t |cFFFFFFFFBone Shield|r  $@spelldesc195181
    marrowrend = {
        id = 195182,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return talent.exterminate.enabled and buff.exterminate.up and 1 or 2 end,
        spendType = "runes",

        talent = "marrowrend",
        startsCombat = true,

        handler = function ()
            local RWStrikes = 1 + buff.dancing_rune_weapon.active_weapons -- the 1 is your actual spell hit
            addStack( "bone_shield", 30, buff.bone_shield.stack + 3 * RWStrikes )

            if talent.exterminate.enabled and buff.exterminate.up then
                removeStack( "exterminate" )
                applyDebuff( "target", "blood_plague" )
                if buff.dancing_rune_weapon.up then applyRunePlagues() end
                applyBuff( "bonestorm", 2 )
            end

            if talent.ossified_vitriol.enabled then removeBuff( "ossified_vitriol" ) end

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end

            -- Legacy

            if azerite.bones_of_the_damned.enabled then applyBuff( "bones_of_the_damned" ) end
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


    murderous_intent = {
        id = 207018,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        startsCombat = true,
        texture = 136088,

        pvptalent = "murderous_intent",

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end,
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
        cooldown = 120,
        gcd = "off",

        talent = "raise_dead",
        startsCombat = false,

        toggle = "cooldowns",

        usable = function () return not pet.alive, "cannot have an active pet" end,

        handler = function()
            summonPet( "ghoul" )
        end,
    },

    -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $434765d or reaching $434765u stacks, the mark explodes, dealing $?a137008[$436304s1][$436304s2] damage per stack.; Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for $443761d.
    reapers_mark = {
        id = 439843,
        cast = 0.0,
        cooldown = function() return 60.0 - ( 15 * talent.reapers_onslaught.rank ) end,
        gcd = "spell",

        spend = 2,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "reapers_mark" )
            if talent.grim_reaper.enabled then
                addStack( "bone_shield", nil,  3 )
            end
            if talent.reaper_of_souls.enabled then
                setCooldown( "soul_reaper", 0 )
                applyBuff( "reaper_of_souls" )
            end
            if set_bonus.tww3 >= 2 then addStack( "exterminate", 2 ) end
        end,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 0.8, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434765, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #3: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Strike the target for $s1 Physical damage. This attack cannot be dodged, blocked, or parried.
    rune_strike = {
        id = 316239,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        notalent = "heart_strike",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Reduces all damage taken by $s1% for $d.
    rune_tap = {
        id = 194679,
        cast = 0,
        charges = function () if level > 43 then return 2 end end,
        cooldown = 25,
        recharge = function () if level > 43 then return 25 end end,
        gcd = "off",

        spend = 1,
        spendType = "runes",

        talent = "rune_tap",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "rune_tap" )
        end,
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

        usable = function () return pet.ghoul.alive, "requires an undead pet" end,

        handler = function ()
            gain( 0.25 * health.max, "health" )
            pet.ghoul.expires = query_time - 0.01
        end,
    },

    -- Talent: Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper.     After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return buff.reaper_of_souls.up and 0 or 1 end,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = true,

        handler = function ()
            if buff.reaper_of_souls.up then removeBuff( "reaper_of_souls" ) end
            applyBuff( "soul_reaper" )
        end,
    },


    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0,
        spendType = "runes",

        toggle = "interrupts",
        pvptalent = "strangulate",
        interrupt = true,

        startsCombat = true,
        texture = 136214,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "strangulate" )
        end,
    },

    -- Talent: Consume up to $s5 Bone Shield charges. For each charge consumed, you gain $s3 Runic Power and absorb damage equal to $s4% of your maximum health for $d.
    tombstone = {
        id = 219809,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "tombstone",
        startsCombat = true,

        buff = "bone_shield",

        handler = function ()
            local bs = min( 5, buff.bone_shield.stack )


            if talent.insatiable_blade.enabled then reduceCooldown( "dancing_rune_weapon", bs * 5 ) end
            if talent.blood_tap.enabled then  gainChargeTime( "blood_tap", bs * 2 ) end
            removeStack( "bone_shield", bs )
            gain( 6 * bs, "runic_power" )

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end

            applyBuff( "tombstone" )

            -- Legacy
            if set_bonus.tier21_2pc == 1 then
                cooldown.dancing_rune_weapon.expires = max( 0, cooldown.dancing_rune_weapon.expires - ( 3 * bs ) )
            end

        end,
    },

    -- Talent: Embrace your undeath, increasing your maximum health by $s4% and increasing all healing and absorbs received by $s1% for $d.
    vampiric_blood = {
        id = 55233,
        cast = 0,
        cooldown = function () return 90 * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",

        talent = "vampiric_blood",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_blood" )
            if set_bonus.tier30_4pc > 0 then applyBuff( "vampiric_strength" ) end
            if legendary.gorefiends_domination.enabled then gain( 45, "runic_power" ) end
            if talent.umbilicus_eternus.enabled then state:QueueAuraExpiration( "vampiric_blood", TriggerUmbilicusEternus, buff.vampiric_blood.expires ) end
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
} )

spec:RegisterRanges( "death_strike", "mind_freeze", "death_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Blood",
} )

spec:RegisterSetting( "dnd_while_moving", true, {
    name = strformat( "Allow %s while moving", Hekili:GetSpellLinkWithTexture( spec.abilities.death_and_decay.id ) ),
    desc = strformat( "If checked, then allow recommending %s while the player is moving otherwise only recommend it if the player is standing still.", Hekili:GetSpellLinkWithTexture( spec.abilities.death_and_decay.id ) ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "save_blood_shield", true, {
    name = strformat( "Save %s", Hekili:GetSpellLinkWithTexture( spec.auras.blood_shield.id ) ),
    desc = strformat( "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your %s fall off during "
        .. "lulls in damage.", Hekili:GetSpellLinkWithTexture( spec.auras.blood_shield.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "death_strike_pool_amount", 65, {
    name = strformat( "%s %s", Hekili:GetSpellLinkWithTexture( spec.abilities.death_strike.id ), _G.POWER_TYPE_RUNIC_POWER ),
    desc = strformat( "The default priority will (usually) avoid spending %s on %s unless you have pooled at least this much.", _G.POWER_TYPE_RUNIC_POWER, Hekili:GetSpellLinkWithTexture( spec.abilities.death_strike.id ) ),
    type = "range",
    min = 40,
    max = 125,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "ibf_damage", 40, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.icebound_fortitude.id ) ),
    desc = strformat( "When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n"
        .. "|W%s|w also requires the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.icebound_fortitude.id ),
        spec.abilities.icebound_fortitude.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rt_damage", 30, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.rune_tap.id ) ),
    desc = strformat( "When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n"
        .. "|W%s|w also requires the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.rune_tap.id ), spec.abilities.rune_tap.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "vb_damage", 50, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.vampiric_blood.id ) ),
    desc = strformat( "When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n"
        .. "|W%s|w also requires the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.vampiric_blood.id ),
        spec.abilities.vampiric_blood.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterPack( "Blood", 20250826, [[Hekili:fR12Unoos0VLGbWWojTJLDBN0nInWm9(shmyWG1dW(MLPLOJjIUTuujtweOV9TkQBusKsYP7E6xsITiRQiRBN6OSZA3FTBRlrq39hZNnF5S7MVAQ1cRflUD3wXRr0DBJioprEe(JaIp8ZFZlm0f)2x9cjU4UJdt4oWtojerXF(MBEKjoLCyQtO)nXm)epIGfg4Wjhf4NDU5Gx4HBeNOVq4ValLfCZV6Gl5p5Sqot86VZIfX34spss8eWVjItpfWE8KW(aQ7POq2T9qcZt81GDh0A(Zxc2ve1b(6LZatJ56sZwlng28h(q6()6enD))HWHFiTI09BPK4q43lsFaf2hMD3hMV6ZP7)1)83Hh(AGt6EyF3E3T3s)Kv1AMHR5RbmbJ4LT4hsFOBnmVy3F8dZ)eS7)nnwkE8(awfZ)l726HxdY7xsGh51a4p)dP3Igqo4rD39B726a3xuoJSB7409xKU)qYXJtpegqTJpXOEUttIs3)2BAEaN6tybXP7VpDV10LgwvSaC(WAwdlkD)K09Js3taN1ZuBAa1NrbbSbE48DBjsFi4xqFK9HqM3obC7B0G)bBTvgKmak22HWPXXOnTWOn5gkMMz)rEKhtO107ctNXp2LtrAKGIPbou7WJ2qCFwyS9)nHsdAFYgDg7PyTpt8JyCMJDSGZEsXSNuzZNOeUiFbOvV0OvB6EfD0zgyX5sE1AtcCTDPoKxR0l6EAgNGULf1mjuhXIqUpApRmAp8Ka4Off(cLdA8iZHjKxxZN1WjRC6U9SpDGaxjpCqGPmoOW4MkyopXcESsz(eop8fonWfv1DDRkwWrpMCJORmoe3QmqFKHlXKOkn5egeN4hj)aOQp1BKMrTvMW0mwbF4KHznndHSMz0E058Nl1IGWFKkGlvFQTi0oYryVyP86FPUN7YGAOBKHCOxb614zZPKiiwOmA7k5EvcSuwL0onx28DhnC(LcTmxl8DBfDuLZYCzUUsWx9TNGlLGtyONB4lbtDjboGLAdzXu7xaFsOsbm5f2YQtHi0)aCadYcV6SWQbTxehdR1hA1Ah7aOtEuTKyMXRrcBkeWf9D6vc1ibVA7MviWYCjvZPdzgBi0TXlmcuNIw20UNJlNf8uEqT5cMgYZ7irwwUuBTufnGl0CXo0)2kdOLI(KQIuRUvxpZNPUoL8OglZsDz1uwTfkWdLeozjiQYA5mW9EKtP)VMN1MPRkXOYUYEiK0yi045WShKeJF)r7hDCrLKJx24YB1NiGYHIwXmpg24hDyAaRuyfjbVIPUyMvafaiWJ4SyFtgHPvxzddlF9EjoqzVKW4maihLiZRwXAzJ5cyrLMlywGQ8JBCj3mLP0Ld15a55fcqGZpd1(QghZoXpKLlR5yPMsKfJDmH)6aGp0RWO8ykxwGUFac9jm4XWjNt8GI7EEDddyqc8iJtLh3E6HpiHffwaoPJUScsqzptwamyikrxIpmwP9Y82apFi)Bkkbx2dsRfOGOH5qpeMGPXHCbtK4MdQPYilRfwDSBMDhcNPyQqDpGPdpf)lVe4xwlLinaZYAw6(lrKkE0abKCatQDYMfKpEAUqLDAYw)IAlxIMLie0Ge5KXA2am5QNNDgsO4PQ11uLK87paWCGocvc5szNLjYdGDwMdpYoh3mmkbuH5eKQxbrOzfJIlaoHbpbAg42SjqN9LZ6du1Gd)CjAUfYUAGMM6t(7mCcNWtzmucotV4i0y4G107QpRGm)uqI6PtBnlWQxlWOg6PCIPHtlf8L16d2gDwpvyQHiqDAb9qfWdBUQn0hV7M3Mq8uVoufshZvG6CeAd3onOmOwVFnz)AbbO1yGgDH2cO5E2b7aGE6ra90w8oXrulAhRTAN9bBK5Lm(xYtGQTBuLMHYxPYCABugTYqP0Z1AabB7YFrAiMb53YqExksUrjaQiofkCFG0gcv9G7Ubr1Fz2BvRCPKMbqmoI1USZwxoOof)sN0JLJonD)hvkWH(H889ZF2Sk2q6AwbLGCvYom72mr2rX90uDfZlhPPZgMzLc1k9X9QGRKJgoPwfZMfym3xa3rhZ)KnQEgJfjEXfw7paQaEpJO9tGXIvQ5xzFDSTpH)uJ0R3fo1sgf4Vm9qKDlQeQxo(BRPrJNna0R0)g(eaqKiOLW8g3bzVfEbZe1OCnxN5oRzTkJzyS3ZNajS8WD9wE47gvj9ZZEhXc9KD(UyNyH6vR5b9TQnLOXb97aWxBtujYOs0TyIOwkMzQd6fPw7AxgZQ7M9K2fM3uNJBc3HGDSc5qaSiRdybwGoB(LLxnG3NW5)oimFb)o7O(DRH5IvVNgvdUSyNtGOlH6Nl3KdnAFOebE3WsV)0qYULbYpdD4WvL)ACNbEVxi8aWdaXyF1pcgThNUDz2vd(ouLVF0PPpakirCkeG1N9EtJ4HhziGYF5xs3)p57Ko9buJBlf)xqXNU)lH((ymj(cK)SYRpgx8)c6Y9zmlV4TnJV640hYoIXtlXCF16BQHYw)skGWDncEETrSZxl)56Bv0eSzfIqv)6cI7YKPbYmVMDCTjsmVwHFH1wMfTEkkrjpK(J3B92BiLKJQrh59RNpRF9hB2Ou4C0SCQOoS8EWqZw1nvsr4zSP6ubEgBSKYVZypr1DT9VH6SSHBmN3VrT58BZ6s((gDX4oua4wnYX3K6Axn4x3qm5X9wlVAS1Sl7M9UjxnEXL9XyhSiZm1DzhS0D58AMEftB9fKbtRI3RJX7ii4EuDQT2a7AuBc12S2A6Dt6tywAewTnvRauzyHgIWUpNMNlN3A753nL7UbnxJmI38(1GqRNki7THs6cdtH0(eJ9EWDyIKkdwE7at1h3KcLSaqvQjUoJ4L1wOU1Zjv)cmhPNbzLtvZObMQAufOq6wfQ9NupbyCCoHk4(W)EZhnU0sWDAdKKac3SE5OoH6ys2nJ00Gq8(oz74T36QI0iDYBCNc8QvtMy0CvgsaTwCvvi)WKCdJzmQnVdBgBGXHRw(nOFT8FC)YVx6xLEdZXl1YF7Y7CrD879eLugvnOcjnLrfDcLwvD6lkIKAfCdxFxOLUcZ3tQH1gxujRaDLxDxN5vJgcERnRNVSBNvozak3R69xgI311eyZcJQuzeKbedzCjQnW13Kk37nijm0uodj4g3EDIamuIBZ8zQLQZBFy6m2)K(3BnnVEC)RvNAhwfFD7Ci1ZxSsRoRv1WyLHQnOGQyCZaZfJ6A49jqQE9DSzXi9fuk2rFoN(Ul09CT5b6UqAeBGD2BDHn(Iw(Psa56W9briAEAwgZARjns1Hsi6mHwWm)UAe9FOnInCHU92mzA8aZqoNSPS1z4)X3jAprdkxB04UcpF7TwjaA11qYoXsrT3PMUNTDzRm0NuNavc(lLOH)Hy13buTMBF(ydcop2R9)9Dtohv(poMmtzdNPx5DMIFMArNmheWNvNFi)7anuLr9ZRDIQZubjw7aPbb2YCUGHG9(kumerlNGuFaKPUCTcH7tpsUN39))]] )