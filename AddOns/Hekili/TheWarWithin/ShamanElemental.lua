-- ShamanElemental.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 262 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
local NewTimer = C_Timer.NewTimer
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetSpellPowerCost = C_Spell.GetSpellPowerCost
spec:RegisterResource( Enum.PowerType.Maelstrom )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {

    -- Shaman
    ancestral_wolf_affinity        = { 103610,  382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf
    arctic_snowstorm               = { 103619,  462764, 1 }, -- Enemies within $s1 yds of your Frost Shock are snared by $s2%
    ascending_air                  = { 103607,  462791, 1 }, -- Wind Rush Totem's cooldown is reduced by $s1 sec and its movement speed effect lasts an additional $s2 sec
    astral_bulwark                 = { 103611,  377933, 1 }, -- Astral Shift reduces damage taken by an additional $s1%
    astral_shift                   = { 103616,  108271, 1 }, -- Shift partially into the elemental planes, taking $s1% less damage for $s2 sec
    brimming_with_life             = { 103582,  381689, 1 }, -- Maximum health increased by $s1%, and while you are at full health, Reincarnation cools down $s2% faster
    call_of_the_elements           = { 103592,  383011, 1 }, -- Reduces the cooldown of Totemic Recall by $s1 sec
    capacitor_totem                = { 103579,  192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s1 sec, stunning all enemies within $s2 yards for $s3 sec
    chain_heal                     = { 103588,    1064, 1 }, -- Heals the friendly target for $s1, then jumps up to $s2 yards to heal the $s3 most injured nearby allies. Healing is reduced by $s4% with each jump
    chain_lightning                = { 103583,  188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing $s$s2 Nature damage and then jumping to additional nearby enemies. Affects $s3 total targets. Generates $s4 Maelstrom per target hit
    cleanse_spirit                 = { 103608,   51886, 1 }, -- Removes all Curse effects from a friendly target
    creation_core                  = { 103592,  383012, 1 }, -- Totemic Recall affects an additional totem
    earth_elemental                = { 103585,  198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for $s1 min. While this elemental is active, your maximum health is increased by $s2%
    earth_shield                   = { 103596,     974, 1 }, -- Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for $s2 when they take damage. This heal can only occur once every $s3 sec. Maximum $s4 charges. Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman
    earthgrab_totem                = { 103617,   51485, 1 }, -- Summons a totem at the target location for $s1 sec. The totem pulses every $s2 sec, rooting all enemies within $s3 yards for $s4 sec. Enemies previously rooted by the totem instead suffer $s5% movement speed reduction
    elemental_orbit                = { 103602,  383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by $s1. You can have Earth Shield on yourself and one ally at the same time
    elemental_resistance           = { 103601,  462368, 1 }, -- Healing from Healing Stream Totem reduces Fire, Frost, and Nature damage taken by $s1% for $s2 sec
    elemental_warding              = { 103597,  381650, 1 }, -- Reduces all magic damage taken by $s1%
    encasing_cold                  = { 103619,  462762, 1 }, -- Frost Shock snares its targets by an additional $s1% and its duration is increased by $s2 sec
    enhanced_imbues                = { 103606,  462796, 1 }, -- The effects of your weapon and shield imbues are increased by $s1%
    fire_and_ice                   = { 103605,  382886, 1 }, -- Increases all Fire and Frost damage you deal by $s1%
    frost_shock                    = { 103604,  196840, 1 }, -- Chills the target with frost, causing $s$s2 Frost damage and reducing the target's movement speed by $s3% for $s4 sec. Generates $s5 Maelstrom
    graceful_spirit                = { 103626,  192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by $s1 sec and increases your movement speed by $s2% while it is active
    greater_purge                  = { 103624,  378773, 1 }, -- Purges the enemy target, removing $s1 beneficial Magic effects
    guardians_cudgel               = { 103618,  381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place
    gust_of_wind                   = { 103591,  192063, 1 }, -- A gust of wind hurls you forward
    healing_stream_totem           = { 103590,    5394, 1 }, -- Summons a totem at your feet for $s1 sec that heals an injured party or raid member within $s2 yards for $s3 every $s4 sec. If you already know Healing Stream Totem, instead gain $s5 additional charge of Healing Stream Totem
    hex                            = { 103623,   51514, 1 }, -- Transforms the enemy into a frog for $s1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit $s2. Only works on Humanoids and Beasts
    jet_stream                     = { 103607,  462817, 1 }, -- Wind Rush Totem's movement speed bonus is increased by $s1% and now removes snares
    lava_burst                     = { 103598,   51505, 1 }, -- Hurls molten lava at the target, dealing $s$s2 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock. Generates $s3 Maelstrom
    lightning_lasso                = { 103589,  305483, 1 }, -- Grips the target in lightning, stunning and dealing $s$s2 Nature damage over $s3 sec while the target is lassoed. Can move while channeling
    mana_spring                    = { 103587,  381930, 1 }, -- Your Lava Burst casts restore $s1 mana to you and $s2 allies nearest to you within $s3 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers
    natures_fury                   = { 103622,  381655, 1 }, -- Increases the critical strike chance of your Nature spells and abilities by $s1%
    natures_guardian               = { 103613,   30884, 1 }, -- When your health is brought below $s1%, you instantly heal for $s2% of your maximum health. Cannot occur more than once every $s3 sec
    natures_swiftness              = { 103620,  378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana
    planes_traveler                = { 103611,  381647, 1 }, -- Reduces the cooldown of Astral Shift by $s1 sec
    poison_cleansing_totem         = { 103609,  383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within $s1 yards every $s2 sec for $s3 sec
    primordial_bond                = { 103612,  381764, 1 }, -- While you have an elemental active, your damage taken is reduced by $s1%
    purge                          = { 103624,     370, 1 }, -- Purges the enemy target, removing $s1 beneficial Magic effect
    refreshing_waters              = { 103594,  378211, 1 }, -- Your Healing Surge is $s1% more effective on yourself
    seasoned_winds                 = { 103628,  355630, 1 }, -- Interrupting a spell with Wind Shear decreases your damage taken from that spell school by $s1% for $s2 sec. Stacks up to $s3 times
    spirit_walk                    = { 103591,   58875, 1 }, -- Removes all movement impairing effects and increases your movement speed by $s1% for $s2 sec
    spirit_wolf                    = { 103581,  260878, 1 }, -- While transformed into a Ghost Wolf, you gain $s1% increased movement speed and $s2% damage reduction every $s3 sec, stacking up to $s4 times
    spiritwalkers_aegis            = { 103626,  378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for $s1 sec
    spiritwalkers_grace            = { 103584,   79206, 1 }, -- Calls upon the guidance of the spirits for $s1 sec, permitting movement while casting Shaman spells. Castable while casting. Increases movement speed by $s2%
    static_charge                  = { 103618,  265046, 1 }, -- Reduces the cooldown of Capacitor Totem by $s1 sec for each enemy it stuns, up to a maximum reduction of $s2 sec
    stone_bulwark_totem            = { 103629,  108270, 1 }, -- Summons a totem at your feet that grants you an absorb shield preventing $s$s2 million damage for $s3 sec, and an additional $s4 every $s5 sec for $s6 sec
    thunderous_paws                = { 103581,  378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional $s1% for the first $s2 sec. May only occur once every $s3 sec
    thundershock                   = { 103621,  378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by $s1 sec
    thunderstorm                   = { 103603,   51490, 1 }, -- Calls down a bolt of lightning, dealing $s$s2 Nature damage to all enemies within $s3 yards, reducing their movement speed by $s4% for $s5 sec, and knocking them upward. Usable while stunned
    totemic_focus                  = { 103625,  382201, 1 }, -- Increases the radius of your totem effects by $s1%. Increases the duration of your Earthbind and Earthgrab Totems by $s2 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, and Wind Rush Totems by $s3 sec
    totemic_projection             = { 103586,  108287, 1 }, -- Relocates your active totems to the specified location
    totemic_recall                 = { 103595,  108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than $s1 minutes
    totemic_surge                  = { 103599,  381867, 1 }, -- Reduces the cooldown of your totems by $s1 sec
    traveling_storms               = { 103621,  204403, 1 }, -- Thunderstorm now can be cast on allies within $s1 yards, reduces enemies movement speed by $s2%, and knocks enemies $s3% further
    tremor_totem                   = { 103593,    8143, 1 }, -- Summons a totem at your feet that shakes the ground around it for $s1 sec, removing Fear, Charm and Sleep effects from party and raid members within $s2 yards
    voodoo_mastery                 = { 103600,  204268, 1 }, -- Your Hex target is slowed by $s1% during Hex and for $s2 sec after it ends. Reduces the cooldown of Hex by $s3 sec
    wind_rush_totem                = { 103627,  192077, 1 }, -- Summons a totem at the target location for $s1 sec, continually granting all allies who pass within $s2 yards $s3% increased movement speed for $s4 sec
    wind_shear                     = { 103615,   57994, 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $s1 sec
    winds_of_alakir                = { 103614,  382215, 1 }, -- Increases the movement speed bonus of Ghost Wolf by $s1%. When you have $s2 or more totems active, your movement speed is increased by $s3%

    -- Elemental
    aftershock                     = {  81000,  273221, 1 }, -- Earth Shock, Elemental Blast, and Earthquake have a $s1% chance to refund all Maelstrom spent
    ascendance                     = {  80989,  114050, 1 }, -- Transform into a Flame Ascendant for $s1 sec, instantly casting a Flame Shock and a $s2% effectiveness Lava Burst at up to $s3 nearby enemies. While ascended, Elemental Overload damage is increased by $s4% and spells affected by your Mastery: Elemental Overload cause $s5 additional Elemental Overload
    charged_conduit                = {  80991,  468625, 1 }, -- Increases the duration of Lightning Rod by $s1 sec and its damage bonus by $s2%
    deeply_rooted_elements         = {  80992,  378270, 1 }, -- Each Maelstrom spent has a $s1% chance to activate Ascendance for $s2 sec.  Ascendance Transform into a Flame Ascendant for $s5 sec, instantly casting a Flame Shock and a $s6% effectiveness Lava Burst at up to $s7 nearby enemies. While ascended, Elemental Overload damage is increased by $s8% and spells affected by your Mastery: Elemental Overload cause $s9 additional Elemental Overload
    earth_shock                    = {  80984,    8042, 1 }, -- Instantly shocks the target with concussive force, causing $s$s2 Nature damage
    earthen_rage                   = { 103634,  170374, 1 }, -- Your damaging spells incite the earth around you to come to your aid for $s2 sec, repeatedly dealing $s$s3 Nature damage to your most recently attacked target
    earthquake_ground              = {  80985,   61882, 1 }, -- Causes the earth within $s2 yards of the target location to tremble and break, dealing $s$s3 Physical damage over $s4 sec and has a $s5% chance to knock the enemy down. Multiple uses of Earthquake may overlap. This spell is cast at a selected location
    earthquake_targeted            = {  80985,  462620, 1 }, -- Causes the earth within $s2 yards of the target location to tremble and break, dealing $s$s3 Physical damage over $s4 sec and has a $s5% chance to knock the enemy down. Multiple uses of Earthquake may overlap. This spell is cast at a selected location
    earthshatter                   = {  80995,  468626, 1 }, -- Increases Earth Shock and Earthquake damage by $s1% and the stat bonuses granted by Elemental Blast by $s2%
    echo_chamber                   = {  81013,  382032, 1 }, -- Increases the damage dealt by your Elemental Overloads by $s1%
    echo_of_the_elementals         = {  81008,  462864, 1 }, -- When your Storm Elemental or Fire Elemental expires, it leaves behind a lesser Elemental to continue attacking your enemies for $s1 sec
    echo_of_the_elements           = {  80999,  333919, 1 }, -- Lava Burst has an additional charge
    echoes_of_great_sundering      = { 103641,  384087, 1 }, -- After casting Earth Shock, your next Earthquake deals $s1% additional damage. After casting Elemental Blast, your next Earthquake deals $s2% additional damage
    elemental_blast                = {  80984,  117014, 1 }, -- Harnesses the raw power of the elements, dealing $s1 million Elemental damage and increasing your Critical Strike or Haste by $s2% or Mastery by $s3% for $s4 sec
    elemental_equilibrium          = {  80993,  378271, 1 }, -- Dealing direct Fire, Frost, and Nature damage within $s1 sec will increase all damage dealt by $s2% for $s3 sec. This can only occur once every $s4 sec
    elemental_fury                 = {  80983,   60188, 1 }, -- Your damaging critical strikes deal $s1% damage instead of the usual $s2%
    elemental_unity                = { 103630,  462866, 1 }, -- While a Storm Elemental is active, your Nature damage dealt is increased by $s1%. While a Fire Elemental is active, your Fire damage dealt is increased by $s2%
    erupting_lava                  = {  81006,  468574, 1 }, -- Increases the duration of Flame Shock by $s1 sec and its damage by $s2%. Lava Burst consumes up to $s3 sec of Flame Shock, instantly dealing that damage. Lava Burst overloads benefit at $s4% effectiveness
    everlasting_elements           = { 103633,  462867, 1 }, -- Increases the duration of your Elementals by $s1%
    eye_of_the_storm               = {  81003,  381708, 1 }, -- Reduces the Maelstrom cost of Earth Shock and Earthquake by $s1. Reduces the Maelstrom cost of Elemental Blast by $s2
    fire_elemental                 = {  80981,  198067, 1 }, -- Calls forth a Greater Fire Elemental to rain destruction on your enemies for $s1 sec. While the Fire Elemental is active, Flame Shock deals damage $s2% faster, and newly applied Flame Shocks last $s3% longer
    first_ascendant                = { 103640,  462440, 1 }, -- The cooldown of Ascendance is reduced by $s1 sec
    flames_of_the_cauldron         = {  81010,  378266, 1 }, -- Reduces the cooldown of Flame Shock by $s1 sec and Flame Shock deals damage $s2% faster
    flash_of_lightning             = {  80990,  381936, 1 }, -- Increases the critical strike chance of Lightning Bolt and Chain Lightning by $s1%
    flux_melting                   = {  80996,  381776, 1 }, -- Casting Frost Shock or Icefury increases the damage of your next Lava Burst by $s1%
    fury_of_the_storms             = {  80998,  191717, 1 }, -- Casting Stormkeeper summons a powerful Lightning Elemental to fight by your side for $s1 sec
    fusion_of_elements             = { 103638,  462840, 1 }, -- After casting Icefury, the next time you cast a damaging Nature and Fire spell, you additionally cast an Elemental Blast at your target at $s1% effectiveness
    herald_of_the_storms           = {  80998,  468571, 1 }, -- Casting Lightning Bolt or Chain Lightning reduces the cooldown of Stormkeeper by $s1 sec
    icefury                        = {  80997,  462816, 1 }, -- Casting Lightning Bolt, Lava Burst, or Chain Lightning has a chance to replace your next Frost Shock with Icefury, stacking up to $s2 times.  Icefury Hurls frigid ice at the target, dealing $s$s5 Frost damage and causing your next Frost Shock to deal $s6% increased damage, damage $s7 additional targets, and generate $s8 additional Maelstrom. Generates $s9 Maelstrom
    improved_flametongue_weapon    = {  81009,  382027, 1 }, -- Imbuing your weapon with Flametongue increases your Fire spell damage by $s1% for $s2 |$s3hour:hrs;
    lightning_capacitor            = { 103631,  462862, 1 }, -- While Lightning Shield is active, your Nature damage dealt is increased by $s1%
    lightning_rod                  = {  81012,  210689, 1 }, -- Earth Shock, Elemental Blast, and Earthquake make your target a Lightning Rod for $s1 sec. Lightning Rods take $s2% of all damage you deal with Lightning Bolt and Chain Lightning
    liquid_magma_totem             = { 103637,  192222, 1 }, -- Summons a totem at the target location that erupts dealing $s$s3 Fire damage and applying Flame Shock to $s4 enemies within $s5 yards. Continues hurling liquid magma at a random nearby target every $s6 sec for $s7 sec, dealing $s$s8 Fire damage to all enemies within $s9 yards. Generates $s10 Maelstrom
    magma_chamber                  = {  81007,  381932, 1 }, -- Flame Shock damage increases the damage of your next Earth Shock, Elemental Blast, or Earthquake by $s1%, stacking up to $s2 times
    master_of_the_elements         = {  81004,   16166, 1 }, -- Casting Lava Burst increases the damage or healing of your next Nature, Physical, or Frost spell by $s1%
    mountains_will_fall            = {  81002,  381726, 1 }, -- Earth Shock, Elemental Blast, and Earthquake can trigger your Mastery: Elemental Overload at $s1% effectiveness. Overloaded Earthquakes do not knock enemies down
    power_of_the_maelstrom         = {  81015,  191861, 1 }, -- Casting Lava Burst has a $s1% chance to cause your next Lightning Bolt or Chain Lightning cast to trigger Elemental Overload an additional time, stacking up to $s2 times
    preeminence                    = { 103640,  462443, 1 }, -- Your haste is increased by $s1% while Ascendance is active and its duration is increased by $s2 sec
    primal_elementalist            = { 103632,  117013, 1 }, -- Your Earth, Fire, and Storm Elementals are drawn from primal elementals $s1% more powerful than regular elementals, with additional abilities, and you gain direct control over them
    primordial_fury                = { 103639,  378193, 1 }, -- Elemental Fury increases critical strike damage by an additional $s1%
    primordial_wave                = {  81014,  375982, 1 }, -- Blast all targets affected by your Flame Shock within $s2 yards with a Primordial Wave, dealing $s$s3 Elemental damage, and granting you Lava Surge. Generates $s4 Maelstrom
    searing_flames                 = {  81005,  381782, 1 }, -- Flame Shock damage has a chance to generate $s1 Maelstrom
    splintered_elements            = {  80978,  382042, 1 }, -- Primordial Wave grants you $s1% Haste plus $s2% for each additional targets blasted by Primordial Wave for $s3 sec
    storm_elemental                = {  80981,  192249, 1 }, -- Calls forth a Greater Storm Elemental to hurl gusts of wind at your enemies for $s1 sec. While the Storm Elemental is active, casting Lightning Bolt or Chain Lightning increases your haste by $s2%, stacking up to $s3 times
    storm_frenzy                   = { 103635,  462695, 1 }, -- Your next Chain Lightning or Lightning Bolt has $s1% reduced cast time after casting Earth Shock, Elemental Blast, or Earthquake. Can accumulate up to $s2 charges
    stormkeeper                    = {  80988,  191634, 1 }, -- Charge yourself with lightning, causing your next $s1 Lightning Bolts to deal $s2% more damage, and also causes your next $s3 Lightning Bolts or Chain Lightnings to be instant cast and trigger an Elemental Overload on every target
    surge_of_power                 = {  81000,  262303, 1 }, -- Earth Shock, Elemental Blast, and Earthquake enhance your next spell cast within $s1 sec: Flame Shock: The next cast also applies Flame Shock to $s2 additional target within $s3 yards of the target. Lightning Bolt: Your next cast will cause $s4 additional Elemental Overload. Chain Lightning: Your next cast will chain to $s5 additional target. Lava Burst: Reduces the cooldown of your Fire and Storm Elemental by $s6 sec. Frost Shock: Freezes the target in place for $s7 sec
    swelling_maelstrom             = {  81016,  381707, 1 }, -- Increases your maximum Maelstrom by $s1. Increases Earth Shock, Elemental Blast, and Earthquake damage by $s2%
    thunderstrike_ward             = { 103636,  462757, 1 }, -- Imbue your shield with the element of Lightning for $s2 |$s3hour:hrs;, giving Lightning Bolt and Chain Lightning a chance to call down $s4 Thunderstrikes on your target for $s$s5 Nature damage

    -- Farseer
    ancestral_swiftness            = {  94894,  443454, 1 }, -- Your next healing or damaging spell is instant, costs no mana, and deals $s1% increased damage and healing. If you know Nature's Swiftness, it is replaced by Ancestral Swiftness and causes Ancestral Swiftness to call an Ancestor to your side for $s2 sec
    ancient_fellowship             = {  94862,  443423, 1 }, -- Ancestors have a $s1% chance to call another Ancestor for $s2 sec when they depart
    call_of_the_ancestors          = {  94888,  443450, 1 }, -- Primordial Wave calls an Ancestor to your side for $s1 sec. Whenever you cast a healing or damaging spell, the Ancestor will cast a similar spell
    earthen_communion              = {  94858,  443441, 1 }, -- Earth Shield has an additional $s1 charges and heals you for $s2% more
    elemental_reverb               = {  94869,  443418, 1 }, -- Lava Burst gains an additional charge and deals $s1% increased damage
    final_calling                  = {  94875,  443446, 1 }, -- When an Ancestor departs, they cast Elemental Blast at a nearby enemy
    heed_my_call                   = {  94884,  443444, 1 }, -- Ancestors last an additional $s1 sec
    latent_wisdom                  = {  94862,  443449, 1 }, -- Your Ancestors' spells are $s1% more powerful
    maelstrom_supremacy            = {  94883,  443447, 1 }, -- Increases the damage of Earth Shock, Elemental Blast, and Earthquake by $s1%. Increases the healing of Healing Surge and Chain Heal by $s2%
    natural_harmony                = {  94858,  443442, 1 }, -- Reduces the cooldown of Nature's Guardian by $s1 sec and causes it to heal for an additional $s2% of your maximum health
    offering_from_beyond           = {  94887,  443451, 1 }, -- When an Ancestor is called, they reduce the cooldown of Fire Elemental and Storm Elemental by $s1 sec
    primordial_capacity            = {  94860,  443448, 1 }, -- Increases your maximum Maelstrom by $s1
    routine_communication          = {  94884,  443445, 1 }, -- Lightning Bolt, Lava Burst, Chain Lightning, Icefury, and Frost Shock casts have a $s1% chance to call an Ancestor to your side for $s2 sec
    spiritwalkers_momentum         = {  94861,  443425, 1 }, -- Using spells with a cast time increases the duration of Spiritwalker's Grace and Spiritwalker's Aegis by $s1 sec, up to a maximum of $s2 sec

    -- Stormbringer
    arc_discharge                  = {  94885,  455096, 1 }, -- Tempest causes your next $s1 Chain Lightning or Lightning Bolt spells to be instant cast and deal $s2% increased damage. Can accumulate up to $s3 charges
    awakening_storms               = {  94867,  455129, 1 }, -- Lightning Bolt and Chain Lightning have a chance to strike your target for $s$s2 Nature damage. Every $s3 times this occurs, your next Lightning Bolt is replaced by Tempest
    conductive_energy              = {  94868,  455123, 1 }, -- Lightning Rod targets now also take $s1% of the damage that Tempest deals, and Tempest also applies Lightning Rod effect
    electroshock                   = {  94863,  454022, 1 }, -- Tempest increases your movement speed by $s1% for $s2 sec
    lightning_conduit              = {  94863,  467778, 1 }, -- You have a chance to get struck by lightning, increasing your movement speed by $s1% for $s2 sec. The effectiveness is increased to $s3% in outdoor areas. You call down a Thunderstorm when you Reincarnate
    natures_protection             = {  94880,  454027, 1 }, -- Lightning Shield reduces the damage you take by $s1%
    rolling_thunder                = {  94889,  454026, 1 }, -- Gain one stack of Stormkeeper every $s1 sec
    storm_swell                    = {  94873,  455088, 1 }, -- Tempest grants $s1% Mastery for $s2 sec
    stormcaller                    = {  94893,  454021, 1 }, -- Increases the critical strike chance of your Nature damage spells by $s1% and the critical strike damage of your Nature spells by $s2%
    supercharge                    = {  94873,  455110, 1 }, -- Lightning Bolt, Tempest, and Chain Lightning have a $s1% chance to cause an additional Elemental Overload
    surging_currents               = {  94880,  454372, 1 }, -- When you cast Tempest you gain Surging Currents, increasing the effectiveness of your next Chain Heal or Healing Surge by $s1%, up to $s2%
    tempest                        = {  94892,  454009, 1 }, -- Every $s1 Maelstrom spent replaces your next Lightning Bolt with Tempest
    unlimited_power                = {  94886,  454391, 1 }, -- Spending Maelstrom grants you $s1% haste for $s2 sec. Multiple applications may overlap
    voltaic_surge                  = {  94870,  454919, 1 }, -- Earthquake and Chain Lightning damage increased by $s1%
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    burrow                         = 5574, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by $s2% for $s3 sec. When the effect ends, enemies within $s4 yards are knocked in the air and take $s$s5 Physical damage
    counterstrike_totem            = 3490, -- (204331) Summons a totem at your feet for $s1 sec. Whenever enemies within $s2 yards of the totem deal direct damage, the totem will deal $s3% of the damage dealt back to attacker
    electrocute                    = 5659, -- (206642) When you successfully Purge a beneficial effect, the enemy suffers $s$s2 Nature damage over $s3 sec
    grounding_totem                = 3620, -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within $s1 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts $s2 sec
    shamanism                      = 5660, -- (193876) Your Bloodlust spell now has a $s1 sec. cooldown, but increases Haste by $s2%, and only affects you and your friendly target when cast for $s3 sec. In addition, Bloodlust is no longer affected by Sated
    static_field_totem             =  727, -- (355580) Summons a totem with $s1% of your health at the target location for $s2 sec that forms a circuit of electricity that enemies cannot pass through
    storm_conduit                  = 5681, -- (1217092) Casting Lightning Bolt or Chain Lightning reduces the cooldown of Astral Shift, Gust of Wind, Wind Shear, and Nature Totems by $s1 sec. Interrupt duration reduced by $s2% on Lightning Bolt and Chain Lightning casts
    totem_of_wrath                 = 3488, -- (460697) Primordial Wave summons a totem at your feet for $s1 sec that increases the critical effect of damage and healing spells of all nearby allies within $s2 yards by $s3% for $s4 sec
    unleash_shield                 = 3491, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for $s5 sec. Water Shield: Summons a whirlpool for $s8 sec, reducing damage and healing by $s9% while they stand within it
} )

spec:RegisterHook( "TALENTS_UPDATED", function()
    talent.earthquake = talent.earthquake_targeted.enabled and talent.earthquake_targeted or talent.earthquake_ground
end )

-- Auras
spec:RegisterAuras( {
    -- Talent: A percentage of damage or healing dealt is copied as healing to up to 3 nearby injured party or raid members.
    -- https://wowhead.com/beta/spell=108281
    --[[ancestral_guidance = {
        id = 108281,
        duration = 10,
        tick_time = 0.5,
        max_stack = 1
    },--]]
    -- Health increased by $s1%.    If you die, the protection of the ancestors will allow you to return to life.
    -- https://wowhead.com/beta/spell=207498
    ancestral_protection = {
        id = 207498,
        duration = 30,
        max_stack = 1
    },
    -- Your next healing or damaging spell is instant, costs no mana, and deals $s6% increased damage and healing.
    ancestral_swiftness = {
        id = 443454,
        duration = 3600,
        max_stack = 1,
        onRemove = function( t )
            setCooldown( "ancestral_swiftness", action.ancestral_swiftness.cooldown )
        end
    },
    -- Your next $s3 Chain Lightning or Lightning Bolt spells are instant cast and will deal $s2% increased damage.
    arc_discharge = {
        id = 455097,
        duration = 15.0,
        max_stack = 2
    },
    -- Movement speed reduced by $w1%.
    arctic_snowstorm = {
        id = 462765,
        duration = 8.0,
        max_stack = 1
    },
    -- Talent: Transformed into a powerful Fire ascendant. Chain Lightning is transformed into Lava Beam.
    -- https://wowhead.com/beta/spell=114050
    ascendance = {
        id = 1219480,
        duration = function() return 15 + 3 * talent.preeminence.rank end,
        max_stack = 1,
        copy = { 114051, 114052, 114050 }
    },
    -- Talent: Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=108271
    astral_shift = {
        id = 108271,
        duration = 12,
        max_stack = 1
    },
    -- Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=2825
    bloodlust = {
        id = 2825,
        duration = function() return pvptalent.shamanism.enabled and 10 or 40 end,
        max_stack = 1,
        shared = "player",
        copy = { 32182, 204361, "heroism" }
    },
    call_of_the_ancestors = {
        id = 447244,
        duration = 6,
        max_stack = 1
    },
    -- When you deal damage, $w1% is dealt to your lowest health ally within $204331m2 yards.
    counterstrike_totem = {
        id = 208997,
        duration = 15.0,
        max_stack = 1
    },
    -- Chance to activate Windfury Weapon increased to ${$319773h}.1%.  Damage dealt by Windfury Weapon increased by $s2%.
    -- https://wowhead.com/beta/spell=384352
    doom_winds = {
        id = 384352,
        duration = 8,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=198103
    earth_elemental = {
        id = 198103,
        duration = function() return 60 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Heals for ${$w2*(1+$w1/100)} upon taking damage.
    -- https://wowhead.com/beta/spell=974
    earth_shield = {
        id = function () return talent.elemental_orbit.enabled and 383648 or 974 end,
        duration = 600,
        type = "Magic",
        max_stack = function() return 9 + 3 * talent.earthen_communion.rank end,
        dot = "buff",
        friendly = true,
        shared = "player",
        copy = { 383648, 974 }
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=3600
    earthbind = {
        id = 3600,
        duration = 5,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Rooted.
    -- https://wowhead.com/beta/spell=64695
    earthgrab = {
        id = 64695,
        duration = 8,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Heals $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=382024
    earthliving_weapon = {
        id = 382024,
        duration = 12,
        max_stack = 1
    },
    echoes_of_great_sundering_eb = {
        id = 384088,
        duration = 25,
        max_stack = 1
    },
    echoes_of_great_sundering_es = {
        id = 336217,
        duration = 25,
        max_stack = 1
    },
    echoes_of_great_sundering = {
        alias = { "echoes_of_great_sundering_eb", "echoes_of_great_sundering_es" },
        aliasType = "buff",
        aliasMode = "first",
        duration = 25
    },
    -- Your next damage or healing spell will be cast a second time ${$s2/1000}.1 sec later for free.
    -- https://wowhead.com/beta/spell=320125
    echoing_shock = {
        id = 320125,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- $w1 Nature damage every $t1 sec.
    electrocute = {
        id = 206647,
        duration = 3.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    electroshock = {
        id = 454025,
        duration = 5.0,
        max_stack = 1
    },
    elemental_blast = {
        alias = { "elemental_blast_critical_strike", "elemental_blast_haste", "elemental_blast_mastery" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff"
    },
    electrified_shocks = {
        id = 382089,
        duration = 9,
        type = "Magic",
        max_stack = 1
    },
    elemental_blast_critical_strike = {
        id = 118522,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1
    },
    elemental_blast_haste = {
        id = 173183,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1
    },
    elemental_blast_mastery = {
        id = 173184,
        duration = 10,
        type = "Magic",
        pandemic = true,
        max_stack = 1
    },
    -- Talent: Damage dealt increased by $s1%.
    -- https://wowhead.com/beta/spell=378275
    elemental_equilibrium = {
        id = 378275,
        duration = 10,
        max_stack = 1,
        copy = 347348
    },
    elemental_equilibrium_debuff = {
        id = 378277,
        duration = 30,
        max_stack = 1,
        copy = 347349
    },
    -- Fire, Frost, and Nature damage taken reduced by $w1%.
    elemental_resistance = {
        id = 462568,
        duration = 3.0,
        pandemic = true,
        max_stack = 1
    },
    enfeeblement = {
        id = 378080,
        duration = 6,
        max_stack = 1
    },
    -- Cannot move while using Far Sight.
    -- https://wowhead.com/beta/spell=6196
    far_sight = {
        id = 6196,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $188592s2%
    -- https://wowhead.com/beta/spell=198067
    fire_elemental = {
        id = 188592,
        duration = function() return 20 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    fury_of_the_storms = {
        id = 191716,
        duration = function() return 10 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1,
        copy = "fury_of_storms",
        generate = function( t )
            if action.stormkeeper.time_since < t.duration then
                t.applied = action.stormkeeper.time_since
                t.expires = action.stormkeeper.lastCast + t.duration
                t.stack = 1
                t.caster = "player"
                return
            end

            t.applied = 0
            t.expires = 0
            t.stack = 0
            t.caster = nil
        end
    },
    lesser_fire_elemental = {
        id = 462992,
        duration = 15,
        max_stack = 1
    },
    -- Suffering $w2 Fire damage every $t2 sec.
    -- https://wowhead.com/beta/spell=188389
    flame_shock = {
        id = 188389,
        duration = function() return ( 18 + 6 * talent.erupting_lava.rank ) * ( buff.fire_elemental.up and 2 or 1 ) * ( buff.lesser_fire_elemental.up and 2 or 1 ) end,
        tick_time = function() return 2 * haste * ( talent.flame_of_the_cauldron.enabled and 0.85 or 1 ) * ( buff.fire_elemental.up and 0.75 or 1 ) * ( buff.lesser_fire_elemental.up and 0.75 or 1 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Each of your weapon attacks causes up to ${$max(($<coeff>*$AP),1)} additional Fire damage.
    -- https://wowhead.com/beta/spell=319778
    flametongue_weapon = {
        id = 319778,
        duration = 3600,
        max_stack = 1
    },
    improved_flametongue_weapon = {
        id = 382028,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Your next Lava Burst will deal $s1% increased damage.
    -- https://wowhead.com/beta/spell=381777
    flux_melting = {
        id = 381777,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=196840
    frost_shock = {
        id = 196840,
        duration = function() return 6 + 2 * talent.encasing_cold.rank end,
        type = "Magic",
        max_stack = 1
    },
    -- After casting a damaging Fire$?a462841[ and a Nature][] spell, you additionally cast an Elemental Blast at your target.
    fusion_of_elements_fire = {
        id = 462843,
        duration = 20.0,
        max_stack = 1
    },
    fusion_of_elements_nature = {
        id = 462841,
        duration = 20.0,
        max_stack = 1
    },
    -- Increases movement speed by $?s382215[${$382216s1+$w2}][$w2]%.$?$w3!=0[  Less hindered by effects that reduce movement speed.][]
    -- https://wowhead.com/beta/spell=2645
    ghost_wolf = {
        id = 2645,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Your next Frost Shock will deal $s1% additional damage, and hit up to ${$334195s1/$s2} additional $Ltarget:targets;.
    -- https://wowhead.com/beta/spell=334196
    hailstorm = {
        id = 334196,
        duration = 20,
        max_stack = 5
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/beta/spell=73920
    healing_rain = {
        id = 73920,
        duration = 10,
        max_stack = 1
    },
    -- Healing $?s147074[two injured party or raid members][an injured party or raid member] every $t1 sec.
    -- https://wowhead.com/beta/spell=5672
    healing_stream = {
        id = 5672,
        duration = 15,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=51514
    hex = {
        id = 51514,
        duration = 60,
        mechanic = "polymorph",
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=342240
    ice_strike = {
        id = 342240,
        duration = 6,
        max_stack = 1
    },
    icefury = {
        id = 462818,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Frost Shock damage increased by $w2%.
    -- https://wowhead.com/beta/spell=210714
    icefury_dmg = {
        id = 210714,
        duration = 25,
        type = "Magic",
        max_stack = 4,
        copy = "icefury_dmg"
    },
    -- Fire damage inflicted every $t2 sec.
    -- https://wowhead.com/beta/spell=118297
    immolate = {
        id = 118297,
        duration = 21,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Lava Burst casts instantly.
    -- https://wowhead.com/beta/spell=77762
    lava_surge = {
        id = 77762,
        duration = 10,
        max_stack = 1
    },
    lightning_conduit = {
        id = 468226,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Stunned. Suffering $w1 Nature damage every $t1 sec.
    -- https://wowhead.com/beta/spell=305485
    lightning_lasso = {
        id = 305485,
        duration = 5,
        tick_time = 1,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    lightning_rod = {
        id = 197209,
        duration = function() return talent.charged_conduit.enabled and 12 or 8 end,
        max_stack = 1
    },
    -- Chance to deal $192109s1 Nature damage when you take melee damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].
    -- https://wowhead.com/beta/spell=192106
    lightning_shield = {
        id = 192106,
        duration = 1800,
        max_stack = 1
    },
    maelstrom_surge = { -- TWW Tier 1 4pc
        id = 457727,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Flame Shock damage increases the damage of your next Earth Shock, Elemental Blast, or Earthquake by 0.8%, stacking up to 20 times.
    -- https://www.wowhead.com/beta/spell=381933
    magma_chamber = {
        id = 381933,
        duration = 20,
        type = "magic",
        max_stack = 20
    },
    -- Talent: Your next Nature, Physical, or Frost spell will deal $s1% increased damage or healing.
    -- https://wowhead.com/beta/spell=260734
    master_of_the_elements = {
        id = 260734,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    -- https://wowhead.com/beta/spell=378081
    natures_swiftness = {
        id = 378081,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        onRemove = function( t )
            setCooldown( "natures_swiftness", action.natures_swiftness.cooldown )
        end
    },
    -- Heals $w1 damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=280205
    pack_spirit = {
        id = 280205,
        duration = 3600,
        max_stack = 1
    },
    -- Cleansing $383015s1 poison effect from a nearby party or raid member every $t1 sec.
    -- https://wowhead.com/beta/spell=383014
    poison_cleansing = {
        id = 383014,
        duration = 6,
        tick_time = 1.5,
        type = "Magic",
        max_stack = 1
    },
    -- Lightning Bolt$?a454009[, Tempest,][] and Chain Lightning will trigger Elemental Overload an additional time.
    -- https://wowhead.com/beta/spell=191877
    power_of_the_maelstrom = {
        id = 191877,
        duration = 20,
        max_stack = 2
    },
    -- Heals $w2 every $t2 seconds.
    -- https://wowhead.com/beta/spell=61295
    riptide = {
        id = 61295,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    spirit_wolf = {
        id = 260881,
        duration = 3600,
        max_stack = 4
    },
    -- Talent: Increases movement speed by $s1%.
    -- https://wowhead.com/beta/spell=58875
    spirit_walk = {
        id = 58875,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Immune to Silence/Interrupt.
    -- https://wowhead.com/beta/spell=378078
    spiritwalkers_aegis = {
        id = 378078,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Able to move while casting all Shaman spells.
    -- https://wowhead.com/beta/spell=79206
    spiritwalkers_grace = {
        id = 79206,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent
    splintered_elements = {
        id = 382043,
        duration = 12,
        max_stack = 10,
        copy = { 382042, 354648 } -- Old spell ID, just in case.
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=118905
    static_charge = {
        id = 118905,
        duration = 3,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    stoneskin = {
        id = 383018,
        duration = 15,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=192249
    storm_elemental = {
        id = 192249,
        duration = function() return 30 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    lesser_storm_elemental = {
        id = 192249,
        duration = function() return 15 * ( 1 + 0.2 * talent.everlasting_elements.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    storm_frenzy = {
        id = 462725,
        duration = 12,
        max_stack = 2
    },
    -- Mastery increased by $w1%.
    storm_swell = {
        id = 455089,
        duration = 6.0,
        max_stack = 1
    },
    -- Stormstrike cooldown has been reset$?$?a319930[ and will deal $319930w1% additional damage as Nature][].
    -- https://wowhead.com/beta/spell=201846
    stormbringer = {
        id = 201846,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Your next Chain Lightning will deal $s2% increased damage and be instant cast.
    -- https://wowhead.com/beta/spell=320137
    stormkeeper = {
        -- Elemental: 191634
        -- Enhancement: 320137
        -- Restoration: 383009
        id = 191634,
        duration = 15,
        type = "Magic",
        max_stack = 2,
        copy = { 320137, 383009 }
    },
    -- Incapacitated.
    -- https://wowhead.com/beta/spell=197214
    sundering = {
        id = 197214,
        duration = 2,
        max_stack = 1
    },
    -- Talent: Your next spell cast will be enhanced.
    -- https://wowhead.com/beta/spell=285514
    surge_of_power = {
        id = 285514,
        duration = 15,
        max_stack = 1
    },
    surge_of_power_debuff = {
        id = 285515,
        duration = 6,
        max_stack = 1,
    },
    -- Your next Chain Heal or Healing Surge has $w1% increased effectiveness.
    surging_currents = {
        id = 454376,
        duration = 30.0,
        max_stack = 1
    },
    -- Talent: Your next Healing Surge$?s137039[, Healing Wave, or Riptide][] will be $w1% more effective.
    -- https://wowhead.com/beta/spell=378102
    swirling_currents = {
        id = 378102,
        duration = 15,
        type = "Magic",
        max_stack = 3,
        copy = 338340
    },
    tempest = {
        id = 454015,
        duration = 30,
        max_stack = 2,
        copy = { 454009, 452201 }
    },
    -- Talent: Movement speed increased by $378075s1%.
    -- https://wowhead.com/beta/spell=378076
    thunderous_paws = {
        id = 378076,
        duration = 3,
        max_stack = 1
    },
    thunderstrike_ward = {
        id = 462760,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s3%.
    -- https://wowhead.com/beta/spell=51490
    thunderstorm = {
        id = 51490,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    water_walking = {
        id = 546,
        duration = 600,
        max_stack = 1
    },
    wind_rush = {
        id = 192082,
        duration = 5,
        max_stack = 1
    },
    -- Haste increased by $w1%.
    wind_gust = {
        id = 263806,
        duration = 20,
        max_stack = 4
    },
    -- Talent: Lava Burst damage increased by $s1%.
    -- https://wowhead.com/beta/spell=378269
    windspeakers_lava_resurgence = {
        id = 378269,
        duration = 15,
        max_stack = 1,
        copy = 336065
    },

    -- Pet aura.
    call_lightning = {
        duration = 20,
        generate = function( t, db )
            if storm_elemental.up then
                local name, _, count, _, duration, expires = FindUnitBuffByID( "pet", 157348 )

                if name then
                    t.count = count
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = "pet"
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    -- Conduit
    vital_accretion = {
        id = 337984,
        duration = 60,
        max_stack = 1
    },
} )

spec:RegisterTotems( {
    greater_storm_elemental = {
        id = 1020304
    },
    greater_fire_elemental = {
        id = 135790
    },
    greater_earth_elemental = {
        id = 136024
    },
    liquid_magma_totem = {
        id = 971079
    },
    tremor_totem = {
        id = 136108
    },
    wind_rush_totem = {
        id = 538576
    },
    vesper_totem = {
        id = 3565451
    },
} )

-- Pets
spec:RegisterPets({
    primal_storm_elemental = {
        id = 77942,
        spell = "storm_elemental",
        duration = function()
            if not talent.primal_elementalist.enabled then return 0 end
            return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) )
        end
    },
    primal_fire_elemental = {
        id = 61029,
        spell = "fire_elemental",
        duration = function()
            if not talent.primal_elementalist.enabled then return 0 end
            return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) )
        end
    },
    primal_earth_elemental = {
        id = 61056,
        spell = "earth_elemental",
        duration = function()
            if not talent.primal_elementalist.enabled then return 0 end
            return 60
        end
    },
    risen_skulker = {
        id = 99541,
        spell = "raise_dead",
        duration = function() return talent.raise_dead_2.enabled and 3600 or 60 end,
    },
})

local elementals = {
    [77942] = { "primal_storm_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
    [61029] = { "primal_fire_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
    [61056] = { "primal_earth_elemental", function () return 60 end, false }
}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local summon = {}
local wipe = table.wipe

local vesper_heal = 0
local vesper_damage = 0
local vesper_used = 0

local vesper_expires = 0
local vesper_guid
local vesper_last_proc = 0

local recall_totems = {
    capacitor_totem = 1,
    earthbind_totem = 1,
    earthgrab_totem = 1,
    grounding_totem = 1,
    healing_stream_totem = 1,
    liquid_magma_totem = 1,
    poison_cleansing_totem = 1,
    stoneskin_totem = 1,
    tranquil_air_totem = 1,
    tremor_totem = 1,
    wind_rush_totem = 1,
}

local ancestral_wolf_affinity_spells = {
    cleanse_spirit = 1,
    wind_shear = 1,
    purge = 1,
    -- TODO: List totems?
}

local recallTotem1
local recallTotem2

local fireDamage, frostDamage, natureDamage, lastEEApplied = 0, 0, 0, 0
local stormkeeperCastStart, stormkeeperLastProc = 0, 0

local eeSchools = {
    "fire",
    "frost",
    "nature",
    "volcanic",
    "elemental"
}

spec:RegisterStateExpr( "recall_totem_1", function()
    return recallTotem1
end )

spec:RegisterStateExpr( "recall_totem_2", function()
    return recallTotem2
end )

spec:RegisterStateExpr( "lightning_rod", function()
    return active_dot.lightning_rod
end )


spec:RegisterHook( "runHandler", function( action )
    if buff.ghost_wolf.up then
        if talent.ancestral_wolf_affinity.enabled then
            local ability = class.abilities[ action ]
            if not ancestral_wolf_affinity_spells[ action ] and not ability.gcd == "totem" then
                removeBuff( "ghost_wolf" )
            end
        else
            removeBuff( "ghost_wolf" )
        end
    end

    if talent.totemic_recall.enabled and recall_totems[ action ] then
        recall_totem_2 = recall_totem_1
        recall_totem_1 = action
    end

    if talent.elemental_equilibrium.enabled and elemental_equilibrium.ready then
        local ability = class.abilities[ action ]
        if ability and ability.startsCombat and eeSchools[ ability.school ] then
            elemental_equilibrium.register_damage( ability.school )
        end
    end
end )

local further_beyond_duration_remains, fbSpells = 0, {
    earth_shock = 1,
    earthquake = 1,
    elemental_blast = 1,
    ascendance = 1
}
spec:RegisterStateExpr( "fb_extension_remaining", function()
    return further_beyond_duration_remains
end )

local filter_lvb = 0
local resetFilter = function() filter_lvb = 0 end


-- Tempest spend 300 tracking
local TempestMaelstromSpent, TempestProcs, TempestOneBuffRemoved, LastAscExpirationTime, NextTempestTime, ArcBugTime = 0, 0, 0, 0, 0, 0

local ElementalSpenders = {
  [117014] = true, -- Elemental Blast
  [8042]   = true, -- Earth Shock
  [61882]  = true, -- Earthquake
  [462620] = true  -- Earthquake (@target)
}

local FusionFire, FusionNature, FusionTimer = false, false, nil

local function ExpireFusion()
    FusionFire   = false
    FusionNature = false
    FusionTimer  = nil
end

local FusionFireSpells = {
    flame_shock = 1,
    lava_burst  = 1,
}

local FusionNatureSpells = {
    chain_lightning = 1,
    earth_shock     = 1,
    earthquake      = 1,
    flame_shock     = 1,
    lightning_bolt  = 1,
    tempest         = 1,
    lightning_lasso = 1,
    thunderstorm    = 1
}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, school )
    -- Deaths/despawns.
    if death_events[ subtype ] then
        if destGUID == summon.guid then
            wipe( summon )
        elseif destGUID == vesper_guid then
            vesper_guid = nil
        end
        return
    end

    if sourceGUID == state.GUID then
        -- Summons.
        if subtype == "SPELL_SUMMON" then
            local npcid = destGUID:match("(%d+)-%x-$")
            npcid = npcid and tonumber( npcid ) or -1
            local elem = elementals[ npcid ]

            if elem then
                summon.guid = destGUID
                summon.type = elem[1]
                summon.duration = elem[2]()
                summon.expires = GetTime() + summon.duration
                summon.extends = elem[3]
            end

            if spellID == 324386 then
                vesper_guid = destGUID
                vesper_expires = GetTime() + 30

                vesper_heal = 3
                vesper_damage = 3
                vesper_used = 0
            end

        elseif spellID == 191634 then
            -- Stormkeeper.
            if subtype == "SPELL_CAST_START" then stormkeeperCastStart = GetTime()
            elseif subtype == "SPELL_CAST_SUCCESS" or subtype == "SPELL_CAST_FAILED" then stormkeeperCastStart = 0
            elseif subtype == "SPELL_AURA_APPLIED" and stormkeeperCastStart == 0 then
                stormkeeperLastProc = GetTime()
            end

        -- Vesper Totem heal
        elseif spellID == 324522 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_heal = vesper_heal - 1
            end

        -- Vesper Totem damage; only fires on SPELL_DAMAGE...
        elseif spellID == 324520 then
            local now = GetTime()

            if vesper_last_proc + 0.75 < now then
                vesper_last_proc = now
                vesper_used = vesper_used + 1
                vesper_damage = vesper_damage - 1
            end
        end

        if subtype == "SPELL_CAST_SUCCESS" and state.talent.tempest.enabled and ElementalSpenders[ spellID ] then
            local costs = GetSpellPowerCost( spellID )
            local spent = 0
            for i = 1, #costs do
                if costs[ i ].type == 11 then -- Maelstrom
                    spent = costs[ i ].cost
                    break
                end
            end
            if InCombatLockdown() then
                TempestMaelstromSpent = ( TempestMaelstromSpent + spent ) % 300
            end

        -- Tempest actual proc - model after Enhance
        elseif spellID == 454015 and subtype == "SPELL_CAST_SUCCESS" and state.talent.tempest.enabled then
            local now = GetTime()

            -- Ascendance snapshot tier protection (Ele = 1219480)
            if state.set_bonus.tww3 >= 2 then
                local _, _, _, _, duration, expirationTime = GetPlayerAuraBySpellID( 1219480 )
                if duration and LastAscExpirationTime ~= expirationTime and ( duration - ( expirationTime - now ) <= 0.15 ) then
                    LastAscExpirationTime = expirationTime
                    return
                end
            end

            -- Arc bug suppression
            if ArcBugTime ~= 0 and ( now - ArcBugTime ) <= 1 then
                ArcBugTime = 0
                return
            end

            -- Prevent duplicate Tempest procs
            if TempestProcs == 0 and NextTempestTime ~= 0 and ( now - NextTempestTime ) <= 1 then
                NextTempestTime = 0
                return
            end

            -- Prevent overlapping refresh proc
            if subtype == "SPELL_AURA_REFRESH" and TempestOneBuffRemoved ~= 0 and ( now - TempestOneBuffRemoved ) <= 0.2 then
                TempestOneBuffRemoved = 0
                return
            end

            -- Safe to reset
            TempestMaelstromSpent = 0
        end

        -- Track removed dose event
        if subtype == "SPELL_AURA_REMOVED_DOSE" and spellID == 454015 and state.talent.tempest.enabled then
            TempestOneBuffRemoved = GetTime()
        end


        if spellID == spec.auras.ascendance.id and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) then
            filter_lvb = GetTime()
            C_Timer.After( 2, resetFilter )
        end

        if state.talent.elemental_equilibrium.enabled then
            if ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) then
                if bit.band( school, 4  ) > 0 then fireDamage   = GetTime() end
                if bit.band( school, 16 ) > 0 then frostDamage  = GetTime() end
                if bit.band( school, 8  ) > 0 then natureDamage = GetTime() end
            elseif subtype == "SPELL_AURA_APPLIED" and ( spellID == 378275 or spellID == 347348 ) then
                lastEEApplied = GetTime()
            end
        end

        if state.talent.fusion_of_elements.enabled and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == spec.abilities.icefury.id then
                FusionFire = true
                FusionNature = true

                if FusionTimer then FusionTimer:Cancel() end
                FusionTimer = NewTimer( 20, ExpireFusion )
                Hekili:ForceUpdate( "ICEFURY_FUSION_OF_ELEMENTS", true )

            elseif FusionFire or FusionNature then
                local ability = class.abilities[ spellID ]
                local key = ability.key

                if FusionFireSpells[ key ]   then FusionFire   = false end
                if FusionNatureSpells[ key ] then FusionNature = false end

                if not ( FusionFire or FusionNature ) and FusionTimer then
                    FusionTimer:Cancel()
                    FusionTimer = nil
                end
            end
        end
    end
end )

spec:RegisterStateExpr( "vesper_totem_heal_charges", function()
    return vesper_heal
end )

spec:RegisterStateExpr( "vesper_totem_dmg_charges", function ()
    return vesper_damage
end )

spec:RegisterStateExpr( "vesper_totem_used_charges", function ()
    return vesper_used
end )

spec:RegisterStateFunction( "trigger_vesper_heal", function ()
    if vesper_totem_heal_charges > 0 then
        vesper_totem_heal_charges = vesper_totem_heal_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterStateFunction( "trigger_vesper_damage", function ()
    if vesper_totem_dmg_charges > 0 then
        vesper_totem_dmg_charges = vesper_totem_dmg_charges - 1
        vesper_totem_used_charges = vesper_totem_used_charges + 1
    end
end )

spec:RegisterStateTable( "rolling_thunder", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if not talent.rolling_thunder.enabled and set_bonus.tier30_2pc == 0 then return 0 end

        if k == "next_tick" then
            return max( 0, t.last_tick + 50 - query_time )
        elseif k == "last_tick" then
            return 0
        end
    end, state )
} ) )

spec:RegisterStateExpr( "tempest_mael_count", function ()
    return TempestMaelstromSpent
end )


spec:RegisterStateExpr( "t30_2pc_timer", function()
    return rolling_thunder
end )

spec:RegisterStateExpr( "lightning_rod", function()
    return active_dot.lightning_rod
end )

spec:RegisterStateTable( "fire_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.fire_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "storm_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.storm_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "earth_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
    __index = function( t, k )
        if k == "cast_time" then
            t.cast_time = class.abilities.earth_elemental.lastCast or 0
            return t.cast_time
        end

        local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

        if k == "active" or k == "up" then
            return elem.up

        elseif k == "down" then
            return not elem.up

        elseif k == "remains" then
            return max( 0, elem.remains )

        end

        return false
    end
} ) )

spec:RegisterStateTable( "elemental_equilibrium", setmetatable( {
    last_application = 0,
    last_fire = 0,
    last_frost = 0,
    last_nature = 0,

    refresh_timers = setfenv( function()
        -- reset_precast function to sync with gamestate
        elemental_equilibrium.last_fire = fireDamage
        elemental_equilibrium.last_frost = frostDamage
        elemental_equilibrium.last_nature = natureDamage
        elemental_equilibrium.last_application = lastEEApplied

        if elemental_equilibrium.cooldown then
            applyDebuff( "player", "elemental_equilibrium_debuff", elemental_equilibrium.time_to_ready )
        else
            removeDebuff( "player", "elemental_equilibrium_debuff" )
        end

    end, state ),

    register_damage = setfenv( function( school )
        elemental_equilibrium.last_fire = ( school == "fire" or school == "volcanic" or school == "elemental" ) and query_time or elemental_equilibrium.last_fire
        elemental_equilibrium.last_frost = ( school == "frost" or school == "elemental" ) and query_time or elemental_equilibrium.last_frost
        elemental_equilibrium.last_nature = ( school == "nature" or school == "volcanic" or school == "elemental" ) and query_time or elemental_equilibrium.last_nature

        if max( elemental_equilibrium.last_fire, elemental_equilibrium.last_frost, elemental_equilibrium.last_nature ) - min( elemental_equilibrium.last_fire, elemental_equilibrium.last_frost, elemental_equilibrium.last_nature ) < 10 then
            applyBuff( "elemental_equilibrium" )
            applyDebuff( "player", "elemental_equilibrium_debuff" )
        end

    end, state ),
}, {
    __index = function( t, k )
        local ee_remains = buff.elemental_equilibrium.remains
        local cd_remains = max( 0, elemental_equilibrium.last_application + 30 - state.query_time )

        if k == "ready" then
            return cd_remains == 0
        elseif k == "active" then
            return ee_remains > 0
        elseif k == "active_remains" then
            return ee_remains
        elseif k == "cooldown" then
            return cd_remains > 0
        elseif k == "cooldown_remains" then
            return cd_remains
        elseif k == "needs_frost" then
            return cd_remains == 0 and ( query_time - elemental_equilibrium.last_frost > 10 )
        elseif k == "needs_fire" then
            return cd_remains == 0 and ( query_time - elemental_equilibrium.last_fire > 10 )
        elseif k == "needs_nature" then
            return cd_remains == 0 and ( query_time - elemental_equilibrium.last_nature > 10 )
        elseif k == "cycle_started" then
            return cd_remains == 0 and min( query_time - elemental_equilibrium.last_nature, query_time - elemental_equilibrium.last_fire, query_time - elemental_equilibrium.last_frost ) < 10
        end
    end
} ) )

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237640, 237536, 237637, 237636, 237638 },
        auras = {
            -- Stormbringer
            -- Elemental
            storms_eye = {
                id = 1239315,
                duration = 30,
                max_stack = 2
            },
            -- Farseer both specs
            ancestral_wisdom = {
                id = 1238279,
                duration = 8,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229260, 229261, 229262, 229263, 229265 },
        auras = {
            -- https://www.wowhead.com/spell=1218612
            jackpot = {
                id = 1218612,
                duration = 8,
                max_stack = 1
            }
        }
    },
    tww1 = {
        items = { 212014, 212012, 212011, 212010, 212009 },
        auras = {
            maelstrom_surge = {
                id = 457727,
                duration = 5,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207207, 207208, 207209, 207210, 207212, 217238, 217240, 217236, 217237, 217239 },
        auras = {
            molten_slag = {
                id = 426577,
                duration = 4,
                max_stack = 1
            },
            molten_charge = {
                id = 426578,
                duration = 20,
                max_stack = 1
            }
        }
    },
    tier30 = {
        items = { 202473, 202471, 202470, 202469, 202468 },
        auras = {
            primal_fracture = {
                id = 410018,
                duration = 8,
                max_stack = 1,
                copy = "t30_4pc_ele"
            }
        }
    },
    tier29 = {
        items = { 200396, 200398, 200400, 200401, 200399 },
        auras = {
            seismic_accumulation = {
                id = 394651,
                duration = 15,
                max_stack = 5
            },
            elemental_mastery = {
                id = 394670,
                duration = 5,
                max_stack = 1
            }
        }
    },
})

local TriggerHeatWave = setfenv( function()
    applyBuff( "lava_surge" )
end, state )

local TriggerStormkeeperRT = setfenv( function()
    addStack( "stormkeeper" )
    rolling_thunder.last_tick = query_time
end, state )

spec:RegisterHook( "reset_precast", function ()
    tempest_mael_count = nil

    local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end
    if oh and oh_enchant == 7587 then applyBuff( "thunderstrike_ward" ) end
    if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end
    if talent.thunderstrike_ward.enabled and buff.thunderstrike_ward.down and ( now - action.thunderstrike_ward.lastCast < 1 ) then applyBuff( "thunderstrike_ward" ) end

    if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
        applyBuff( "master_of_the_elements" )
    end

    if vesper_expires > 0 and now > vesper_expires then
        vesper_expires = 0
        vesper_heal = 0
        vesper_damage = 0
        vesper_used = 0
    end

    vesper_totem_heal_charges = nil
    vesper_totem_dmg_charges = nil
    vesper_totem_used_charges = nil

    recall_totem_1 = nil
    recall_totem_2 = nil

    if totem.vesper_totem.up then
        applyBuff( "vesper_totem", totem.vesper_totem.remains )
    end

    rawset( state.pet, "earth_elemental", talent.primal_elementalist.enabled and state.pet.primal_earth_elemental or state.pet.greater_earth_elemental )
    rawset( state.pet, "fire_elemental",  talent.primal_elementalist.enabled and state.pet.primal_fire_elemental  or state.pet.greater_fire_elemental  )
    rawset( state.pet, "storm_elemental", talent.primal_elementalist.enabled and state.pet.primal_storm_elemental or state.pet.greater_storm_elemental )

    if talent.primal_elementalist.enabled then
        dismissPet( "primal_fire_elemental" )
        dismissPet( "primal_storm_elemental" )
        dismissPet( "primal_earth_elemental" )

        if summon.expires then
            if summon.expires <= now then
                wipe( summon )
            else
                summonPet( summon.type, summon.expires - now )
            end
        end
    end

    if talent.primordial_surge.enabled and query_time - action.primordial_wave.lastCast < 12 then
        local expires = action.primordial_wave.lastCast + 12
        while expires > query_time do
            state:QueueAuraEvent( "primordial_surge", TriggerHeatWave, expires, "AURA_PERIODIC" )
            expires = expires - 3
        end
    end

    if talent.rolling_thunder.enabled or set_bonus.tier30_2pc > 0 then
        rolling_thunder.last_tick = stormkeeperLastProc
        if rolling_thunder.next_tick > 0 then
            state:QueueAuraEvent( "stormkeeper", TriggerStormkeeperRT, query_time + rolling_thunder.next_tick, "AURA_PERIODIC" )
        end
    end

    if buff.ascendance.down or not talent.further_beyond.enabled then
        fb_extension_remaining = 0
    end

    if talent.elemental_equilibrium.enabled then
        elemental_equilibrium.refresh_timers()
    end
    
    if talent.fusion_of_elements.enabled then
        local FusionDuration = 20 - action.icefury.time_since
        local FusionBoth = FusionDuration > 19.5 and not ( FusionFire or FusionNature )

        if ( FusionFire or FusionNature or FusionBoth ) and FusionDuration > 0 then
            if FusionBoth then
                applyBuff( "fusion_of_elements_fire",   FusionDuration )
                applyBuff( "fusion_of_elements_nature", FusionDuration )
            else
                if FusionFire   then applyBuff( "fusion_of_elements_fire"  , FusionDuration ) end
                if FusionNature then applyBuff( "fusion_of_elements_nature", FusionDuration ) end
            end
        end
    end
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "maelstrom" then
        if set_bonus.tww1_4pc > 0 then applyBuff( "maelstrom_surge" ) end
        if talent.tempest.enabled and tempest_mael_count + amt >= 300 then
            addStack( "tempest" )
            tempest_mael_count = 0
        end
    end
end )

spec:RegisterHook( "filter_target", function( id, time, mine, spellID )
    if filter_lvb > 0 then
        id = nil
    end
    return id, time, mine, spellID
end )

local fol_spells = {}

spec:RegisterStateFunction( "flash_of_lightning", function()
    if #fol_spells == 0 then
        for k, v in pairs( class.abilityList ) do
            if v.school == "nature" then table.insert( fol_spells, k ) end
        end
    end

    for _, spell in ipairs( fol_spells ) do
        reduceCooldown( spell, 1 )
    end
end )

spec:RegisterEvent( "CHALLENGE_MODE_START", function()
    TempestMaelstromSpent = 0
end)

spec:RegisterEvent( "ENCOUNTER_START", function()
    TempestMaelstromSpent = 0
end)

-- Abilities
spec:RegisterAbilities( {
    -- Talent: For the next $d, $s1% of your damage and healing is converted to healing on up to 3 nearby injured party or raid members.
    --[[ancestral_guidance = {
        id = 108281,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "nature",

        talent = "ancestral_guidance",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "ancestral_guidance" )
        end,
    },--]]

    ancestral_swiftness = {
        id = 443454,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        school = "nature",

        talent = "ancestral_swiftness",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "ancestral_swiftness",

        handler = function ()
            if talent.natures_swiftness.enabled then
                -- Summon an ancestor.
            end
            applyBuff( "ancestral_swiftness" )
            if set_bonus.tww3 >= 4 then applyBuff( "ancestral_wisdom" ) end
        end,
    },

    -- Transform into a Flame Ascendant for $d, instantly casting a Flame Shock and a $s10% effectiveness Lava Burst at up to $s7 nearby enemies.; While ascended, Elemental Overload damage is increased by $s8% and spells affected by your Mastery: Elemental Overload cause $s9 additional Elemental $LOverload:Overloads;.
    ascendance = {
        id = 114050,
        cast = 0,
        cooldown = function () return 180 - 60 * talent.first_ascendant.rank end,
        gcd = "spell",
        school = function()
            if spec.elemental then return "fire" end
            return "nature"
        end,
        talent = "ascendance",
        startsCombat = function()
            if state.spec.elemental and active_dot.flame_shock > 0 then return true end
            return false
        end,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ascendance" )
            spec.abilities.flame_shock.handler()
            spec.abilities.lava_burst.handler()
            active_dot.flame_shock = min( true_active_enemies, active_dot.flame_shock + 6 )
            if set_bonus.tww3_stormbringer >= 2 then
                addStack( "tempest" )
                if set_bonus.tww3 >= 4 then
                    applyBuff( "storms_eye", nil, 2 )
                end
            elseif set_bonus.tww2 >= 2 then
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental", 6 )
            end
        end,

    },


    astral_recall = {
        id = 556,
        cast = 10,
        cooldown = 600,
        gcd = "spell",

        startsCombat = false,
        texture = 136010,

        handler = function () end,
    },


    astral_shift = {
        id = 108271,
        cast = 0,
        cooldown = function () return talent.planes_traveler.enabled and 90 or 120 end,
        gcd = "off",
        school = "nature",

        talent = "astral_shift",
        startsCombat = false,
        nopvptalent = "ethereal_form",

        toggle = "defensives",

        handler = function ()
            applyBuff( "astral_shift" )
        end,
    },

    -- Increases haste by $s1% for all party and raid members for $d.    Allies receiving this effect will become Sated and unable to benefit from Bloodlust or Time Warp again for $57724d.
    bloodlust = {
        id = function() return state.faction == "Alliance" and 32182 or 2825 end,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "nature",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",
        nodebuff = "sated",

        handler = function ()
            applyBuff( "bloodlust" )
            applyDebuff( "player", "sated" )
            stat.haste = state.haste + 0.4
        end,

        copy = { 2825, "heroism" }
    },

    -- PvP Talent: Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by ${$s3-100}% for $d.; When the effect ends, enemies within $409304A1 yards are knocked in the air and take $<damage> Physical damage.
    burrow = {
        id = 409293,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        pvptalent = "burrow",

        handler = function()
            applyBuff( "burrow" )
            setCooldown( "global_cooldown", 5 )
        end,

        auras = {
            burrow = {
                id = 409293,
                duration = 5,
                max_stack = 1
            }
        }
    },

    -- Talent: Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after $s2 sec, stunning all enemies within $118905A1 yards for $118905d.
    capacitor_totem = {
        id = 192058,
        cast = 0,
        cooldown = function () return 60 - 3 * talent.totemic_surge.rank + conduit.totemic_surge.mod * 0.001 end,
        gcd = "totem",
        school = "nature",

        spend = 0.1,
        spendType = "mana",

        talent = "capacitor_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "capacitor_totem" )
        end,
    },

    -- Talent: Heals the friendly target for $s1, then jumps to heal the $<jumps> most injured nearby allies. Healing is reduced by $s2% with each jump.
    chain_heal = {
        id = 1064,
        cast = function ()
            if buff.chains_of_devastation_ch.up then return 0 end
            if buff.ancestral_swiftness.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            return 2.5 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.15 end,
        spendType = "mana",

        talent = "chain_heal",
        startsCombat = false,

        handler = function ()
            if buff.surging_currents.up then removeBuff( "surging_currents" ) end
            removeBuff( "chains_of_devastation_ch" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end -- TODO: Determine order of instant cast effect consumption.
            removeBuff( "echoing_shock" )

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_cl" )
            end

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Talent: Hurls a lightning bolt at the enemy, dealing $s1 Nature damage and then jumping to additional nearby enemies. Affects $x1 total targets.$?s187874[    If Chain Lightning hits more than 1 target, each target hit by your Chain Lightning increases the damage of your next Crash Lightning by $333964s1%.][]$?s187874[    Each target hit by Chain Lightning reduces the cooldown of Crash Lightning by ${$s3/1000}.1 sec.][]$?a343725[    |cFFFFFFFFGenerates $343725s5 Maelstrom per target hit.|r][]
    chain_lightning = {
        id = 188443,
        cast = function ()
            if buff.chains_of_devastation_cl.up then return 0 end
            if buff.ancestral_swiftness.up then return 0 end
            if buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,

        handler = function ()
            removeBuff( "chains_of_devastation_cl" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                if buff.fusion_of_elements_fire.down then class.abilities.elemental_blast.handler() end
            end

            if legendary.chains_of_devastation.enabled then
                applyBuff( "chains_of_devastation_ch" )
            end

            -- 2 MS per target, direct.
            -- 1 MS per target, overload.
            -- stormkeeper guarantees overload on every target hit
            -- power of the maelstrom guarantees 1 extra overload on the initial target
            -- surge of power adds 1 extra target to total potential enemies hit
            local amount = ( buff.stormkeeper.up and 3 or 2 )
                * min( ( level > 42 and 5 or 3 ) + ( buff.surge_of_power.up and 1 or 0 ), true_active_enemies )
                + ( buff.power_of_the_maelstrom.up and 1 or 0 )
            gain( amount, "maelstrom" )

            if buff.stormkeeper.up then
                removeStack( "stormkeeper" )
                if set_bonus.tier30_4pc > 0 then applyBuff( "primal_fracture" ) end
            end

            removeStack( "power_of_the_maelstrom" )
            removeBuff( "surge_of_power" )

            if pet.storm_elemental.up or buff.lesser_storm_elemental.up then
                addStack( "wind_gust" )
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if talent.conductive_energy.enabled then
                if debuff.lightning_rod.down then
                    applyDebuff( "target", "lightning_rod" )
                else
                    active_dot.lightning_rod = min( active_enemies, active_dot.lightning_rod + 1 )
                end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Removes all Curse effects from a friendly target.
    cleanse_spirit = {
        id = 51886,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "nature",

        spend = 0.10,
        spendType = "mana",

        talent = "cleanse_spirit",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_curse",

        handler = function ()
            removeBuff( "dispellable_curse" )
            if state.spec.elemental and time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },

    -- Summons a totem at your feet for $d.; Whenever enemies within $<radius> yards of the totem deal direct damage, the totem will deal $208997s1% of the damage dealt back to attacker.
    counterstrike_totem = {
        id = 204331,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "fire",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "counterstrike_totem",
        startsCombat = false,
        texture = 511726,

        handler = function ()
            summonTotem( "counterstrike_totem" )
        end,
    },

    -- Talent: Calls forth a Greater Earth Elemental to protect you and your allies for $188616d.    While this elemental is active, your maximum health is increased by $381755s1%.
    earth_elemental = {
        id = 198103,
        cast = 0,
        cooldown = function () return 300 * ( buff.deadened_earth.up and 0.6 or 1 ) end,
        gcd = "spell",
        school = "nature",

        talent = "earth_elemental",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 * ( 1 + 0.2 * talent.everlasting_elements.rank ) )
            if conduit.vital_accretion.enabled then
                applyBuff( "vital_accretion" )
                health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
            end
        end,

        usable = function ()
            if state.spec.restoration then return end
            return max( cooldown.fire_elemental.true_remains, cooldown.storm_elemental.true_remains ) > 0, "DPS elementals must be on CD first"
        end,

        timeToReady = function ()
            return max( pet.fire_elemental.remains, pet.storm_elemental.remains, pet.primal_fire_elemental.remains, pet.primal_storm_elemental.remains )
        end,
    },

    -- Talent: Protects the target with an earthen shield, increasing your healing on them by $s1% and healing them for ${$379s1*(1+$s1/100)} when they take damage. This heal can only occur once every few seconds. Maximum $n charges.    $?s383010[Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.][Earth Shield can only be placed on one target at a time. Only one Elemental Shield can be active on the Shaman.]
    earth_shield = {
        id = 974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.02,
        spendType = "mana",

        talent = "earth_shield",
        startsCombat = false,

        --This can be fine, as long as the APL doesn't recommend casting both unless elemental orbit is picked.
        handler = function ()
            applyBuff( "earth_shield", nil, class.auras.earth_shield.max_stack )
            if not talent.elemental_orbit.enabled then removeBuff( "lightning_shield" ) end
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
        end,
    },

    -- Talent: Instantly shocks the target with concussive force, causing $s1 Nature damage.$?a190493[    Earth Shock will consume all stacks of Fulmination to deal extra Nature damage to your target.][]
    earth_shock = {
        id = 8042,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 60 - 5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "earth_shock",
        notalent = "elemental_blast",
        startsCombat = true,
        cycle = function() if talent.lightning_rod.enabled then return "lightning_rod" end end,

        handler = function ()
            removeBuff( "master_of_the_elements" )
            removeBuff( "magma_chamber" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.echoes_of_great_sundering.enabled or runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering_es" )
            end

            if talent.windspeakers_lava_resurgence.enabled or runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.further_beyond.enabled and buff.ascendance.up then
                local extension = min( 2.5, fb_extension_remaining )
                buff.ascendance.expires = buff.ascendance.expires + extension
                fb_extension_remaining = fb_extension_remaining - extension
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if talent.storm_frenzy.enabled then
                addStack( "storm_frenzy", nil, 2 )
            end

            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Summons a totem at the target location for $d that slows the movement speed of enemies within $3600A1 yards by $3600s1%.
    earthbind_totem = {
        id = 2484,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        startsCombat = false,
        notalent = "earthgrab_totem",
        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthbind_totem" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d. The totem pulses every $116943t1 sec, rooting all enemies within $64695A1 yards for $64695d. Enemies previously rooted by the totem instead suffer $116947s1% movement speed reduction.
    earthgrab_totem = {
        id = 51485,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "spell",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "earthgrab_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "earthgrab_totem" )
        end,
    },

    -- Talent: Causes the earth within $a1 yards of the target location to tremble and break, dealing $<damage> Physical damage over $d and has a $?s381743[${$77478s2+$381743S1)}.1][$77478s2]% chance to knock the enemy down.
    earthquake = {
        id = function() return talent.earthquake_targeted.enabled and 462620 or 61882 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return 60 - 5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "earthquake",
        startsCombat = true,

        cycle = function() if talent.lightning_rod.enabled then return "lightning_rod" end end,

        handler = function ()
            removeBuff( "echoes_of_great_sundering" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "magma_chamber" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if talent.further_beyond.enabled and buff.ascendance.up then
                local extension = min( 2.5, fb_extension_remaining )
                buff.ascendance.expires = buff.ascendance.expires + extension
                fb_extension_remaining = fb_extension_remaining - extension
            end

            if talent.windspeakers_lava_resurgence.enabled then
                addStack( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.storm_frenzy.enabled then
                addStack( "storm_frenzy", nil, 2 )
            end

            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = { 462620, 61882 }
    },

    -- Shock the target for $s1 Elemental damage and create an ancestral echo, causing your next damage or healing spell to be cast a second time ${$s2/1000}.1 sec later for free.
    echoing_shock = {
        id = 320125,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        spend = 0.0325,
        spendType = 'mana',

        startsCombat = true,

        handler = function()
            applyBuff( "echoing_shock" )
        end,
    },

    -- Talent: Harnesses the raw power of the elements, dealing $s1 Elemental damage and increasing your Critical Strike or Haste by $118522s1% or Mastery by ${$173184s1*$168534bc1}% for $118522d.$?s137041[    If Lava Burst is known, Elemental Blast replaces Lava Burst and gains $394152s2 additional $Lcharge:charges;.][]
    elemental_blast = {
        id = 117014,
        cast = function ()
            if ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) then return 0 end
            return 2 * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
        end,
        gcd = "spell",
        school = "elemental",

        spend = function () return 90 - 7.5 * talent.eye_of_the_storm.rank end,
        spendType = "maelstrom",

        talent = "elemental_blast",
        startsCombat = true,
        cycle = function() if talent.lightning_rod.enabled then return "lightning_rod" end end,

        handler = function ()
            removeBuff( "master_of_the_elements" )
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "magma_chamber" )
            removeBuff( "echoing_shock" )

            applyBuff( "elemental_blast" )

            if talent.surge_of_power.enabled then
                applyBuff( "surge_of_power" )
            end

            if talent.echoes_of_great_sundering.enabled or runeforge.echoes_of_great_sundering.enabled then
                applyBuff( "echoes_of_great_sundering_eb" )
            end

            if talent.windspeakers_lava_resurgence.enabled or runeforge.windspeakers_lava_resurgence.enabled then
                applyBuff( "lava_surge" )
                gainCharges( "lava_burst", 1 )
                applyBuff( "windspeakers_lava_resurgence" )
            end

            if talent.further_beyond.enabled and buff.ascendance.up then
                local extension = min( 3.5, fb_extension_remaining )
                buff.ascendance.expires = buff.ascendance.expires + extension
                fb_extension_remaining = fb_extension_remaining - extension
            end

            if talent.storm_frenzy.enabled then
                addStack( "storm_frenzy", nil, 2 )
            end

            if set_bonus.tier29_2pc > 0 then
                removeBuff( "seismic_accumulation" )
            end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "elemental_mastery" )
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end
            if talent.further_beyond.enabled and buff.ascendance.up then buff.ascendance.expires = buff.ascendance.expires + 3.5 end
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end

        end,
    },

    -- Changes your viewpoint to the targeted location for $d.
    far_sight = {
        id = 6196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "far_sight" )
        end,
    },

    -- Talent: Calls forth a Greater Fire Elemental to rain destruction on your enemies for $188592d.     While the Fire Elemental is active, Flame Shock deals damage   ${100*(1/(1+$188592s2/100)-1)}% faster, and newly applied Flame Shocks last $188592s3% longer.
    fire_elemental = {
        id = 198067,
        cast = 0,
        charges = 1,
        cooldown = 150,
        recharge = 150,
        gcd = "spell",
        school = "fire",

        spend = 0.05,
        spendType = "mana",

        talent = "fire_elemental",
        startsCombat = false,

        toggle = "cooldowns",

        timeToReady = function ()
            return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.storm_elemental.remains, pet.primal_storm_elemental.remains )
        end,

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental" )
        end,
    },

    -- Sears the target with fire, causing $s1 Fire damage and then an additional $o2 Fire damage over $d.    Flame Shock can be applied to a maximum of $I targets.
    flame_shock = {
        id = 470411,
        cast = 0,
        cooldown = function () return talent.flames_of_the_cauldron.enabled and 4.5 or 6 end,
        gcd = "spell",
        school = "volcanic",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,

        cycle = "flame_shock",
        min_ttd = function () return debuff.flame_shock.duration * 0.3 end,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
            removeBuff( "echoing_shock" )

            if buff.fusion_of_elements_fire.up or buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_fire" )
                removeBuff( "fusion_of_elements_nature" )
                class.abilities.elemental_blast.handler()
            end

            if talent.magma_chamber.enabled then addStack( "magma_chamber" ) end

            if buff.surge_of_power.up then
                active_dot.surge_of_power_debuff = min( active_enemies, active_dot.flame_shock + 1 )
                removeBuff( "surge_of_power" )
            end

            -- TODO: should also gain on every tick of damage.
            if talent.searing_flames.enabled then gain( talent.searing_flames.rank, "maelstrom" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = 188389
    },

    -- Imbue your $?s33757[off-hand ][]weapon with the element of Fire for $319778d, causing each of your attacks to deal ${$max(($<coeff>*$AP),1)} additional Fire damage$?s382027[ and increasing the damage of your Fire spells by $382028s1%][].
    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        startsCombat = false,
        nobuff = "flametongue_weapon",

        handler = function ()
            applyBuff( "flametongue_weapon" )
            if talent.improved_flametongue_weapon.enabled then applyBuff( "improved_flametongue_weapon" ) end
        end,
    },

    -- Talent: Chills the target with frost, causing $s1 Frost damage and reducing the target's movement speed by $s2% for $d.
    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = true,
        nobuff = "icefury",
        texture = 135849,

        bind = "icefury",

        handler = function ()
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            applyDebuff( "target", "frost_shock" )

            if talent.encasing_cold.enabled then applyDebuff( "target", "encasing_cold" ) end

            if talent.flux_melting.enabled then applyBuff( "flux_melting" ) end

            if buff.icefury_dmg.up then
                gain( buff.primal_fracture.up and 15 or 10, "maelstrom" )
                removeStack( "icefury_dmg", 1 )

                if talent.electrified_shocks.enabled then
                    applyDebuff( "target", "electrified_shocks" )
                    active_dot.electrified_shocks = min( true_active_enemies, active_dot.electrified_shocks + 2 )
                end
            end

            if buff.surge_of_power.up then
                applyDebuff( "target", "surge_of_power_debuff" )
                removeBuff( "surge_of_power" )
            end

            if talent.flux_melting.enabled then
                applyBuff( "flux_melting" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Turn into a Ghost Wolf, increasing movement speed by $?s382215[${$s2+$382216s1}][$s2]% and preventing movement speed from being reduced below $s3%.
    ghost_wolf = {
        id = 2645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        startsCombat = false,

        handler = function ()
            applyBuff( "ghost_wolf" )
            if talent.spirit_wolf.enabled then applyBuff( "spirit_wolf" ) end
        end,
    },

    -- Talent: Purges the enemy target, removing $m1 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "nature",

        spend = 0.024,
        spendType = "mana",

        talent = "greater_purge",
        startsCombat = function()
            if talent.elemental_equilibrium.enabled then return false end
            return true
        end,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
        end,
    },


    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.06,
        spendType = "mana",

        pvptalent = "grounding_totem",
        startsCombat = false,
        texture = 136039,

        handler = function ()
            summonTotem( "grounding_totem" )
        end,
    },

    -- Talent: A gust of wind hurls you forward.
    gust_of_wind = {
        id = 192063,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "nature",

        talent = "gust_of_wind",
        startsCombat = false,

        toggle = "interrupts",

        handler = function () end,
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = 1,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        recharge = 30,
        gcd = "totem",

        spend = 0.05,
        spendType = "mana",

        talent = "healing_stream_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "healing_stream_totem" )
            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if conduit.swirling_currents.enabled or talent.swirling_currents.enabled then applyBuff( "swirling_currents" ) end
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up then return 0 end
            return 1.5 * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.surging_currents.up ) and 0 or 0.1 end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" )
            elseif buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            if buff.surging_currents.up then removeBuff( "surging_currents" ) end
            removeBuff( "echoing_shock" )

            if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            if buff.swirling_currents.up then removeStack( "swirling_currents" ) end
        end,
    },

    -- Talent: Transforms the enemy into a frog for $d. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    hex = {
        id = 51514,
        cast = 1.7,
        cooldown = function () return 30 - 15 * talent.voodoo_mastery.rank end,
        gcd = "spell",
        school = "nature",

        talent = "hex",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hex" )
            if talent.enfeeblement.enabled then applyDebuff( "target", "enfeeblement" ) end
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,

        copy = { 210873, 211004, 211010, 211015, 269352, 277778, 277784, 309328 }
    },

    -- Talent: Hurls frigid ice at the target, dealing $s1 Frost damage and causing your next $n Frost Shocks to deal $s2% increased damage and generate $343725s7 Maelstrom.    |cFFFFFFFFGenerates $343725s8 Maelstrom.|r
    icefury = {
        id = 210714,
        cast = 0,
        charges = function() if buff.icefury.up then return buff.icefury.stack end end,
        cooldown = 0,
        recharge = function() if buff.icefury.up then return 0 end end,
        gcd = "spell",
        school = "frost",

        spend = 0.03,
        spendType = "mana",

        talent = "icefury",
        startsCombat = true,
        buff = "icefury",
        texture = 135855,

        bind = "frost_shock",

        handler = function ()
            removeBuff( "icefury" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "echoing_shock" )
            applyBuff( "icefury_dmg", nil, 2 )
            gain( 25 * ( buff.primal_fracture.up and 1.5 or 1 ), "maelstrom" )

            if talent.fusion_of_elements.enabled then
                applyBuff( "fusion_of_elements_fire" )
                applyBuff( "fusion_of_elements_nature" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Hurls molten lava at the target, dealing $285452s1 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.$?a343725[    |cFFFFFFFFGenerates $343725s3 Maelstrom.|r][]
    lava_burst = {
        id = 51505,
        cast = function () return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up or buff.lava_surge.up ) and 0 or ( 2 * haste ) end,
        charges = function () return talent.echo_of_the_elements.enabled and 3 or 2 end,
        cooldown = function () return 8 * haste end,
        recharge = function () return 8 * haste end,
        gcd = "spell",
        school = "fire",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.025 end,
        spendType = "mana",

        talent = "lava_burst",
        notalent = function()
            if state.spec.enhancement then return "elemental_blast" end
        end,
        startsCombat = true,

        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeBuff( "windspeakers_lava_resurgence" )
            if buff.lava_surge.up then removeStack( "lava_surge" ) end
            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeBuff( "flux_melting" )
            removeStack( "molten_charge" )
            removeBuff( "echoing_shock" )

            gain( ( 8 + ( talent.flow_of_power.rank * 2 ) ) * ( buff.primal_fracture.up and 1.5 or 1 ), "maelstrom" )

            if talent.erupting_lava.enabled and debuff.flame_shock.up then
                if debuff.flame_shock.remains > 3 then
                    debuff.flame_shock.expires = debuff.flame_shock.expires - 3
                else
                    removeDebuff( "target", "flame_shock" )
                end
            end

            if buff.fusion_of_elements_fire.up then
                removeBuff( "fusion_of_elements_fire" )
                if buff.fusion_of_elements_nature.down then class.abilities.elemental_blast.handler() end
            end

            if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

            if talent.rolling_magma.enabled and talent.primordial_wave.enabled then
                reduceCooldown( "primordial_wave", 0.5 )
            end

            if talent.surge_of_power.enabled then
                gainChargeTime( "fire_elemental", 4 )
                gainChargeTime( "storm_elemental", 4 )
                removeBuff( "surge_of_power" )
            end

            if buff.primordial_wave.up then
                if state.spec.elemental and talent.splintered_elements.enabled then
                    if buff.splintered_elements.down then stat.haste = state.haste + 0.1 * active_dot.flame_shock end
                    applyBuff( "splintered_elements", nil, active_dot.flame_shock )
                end

                if set_bonus.tier31_4pc > 0 then
                    applyBuff( "molten_charge", nil, 2 )
                end

                removeBuff( "primordial_wave" )
            end

            if talent.rolling_magma.enabled then
                reduceCooldown( "primordial_wave", 0.2 * talent.rolling_magma.rank )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        impact = function ()
            if set_bonus.tier31_4pc > 0 then applyDebuff( "target", "molten_slag" ) end
        end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    lightning_bolt = {
        id = 188196,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            if buff.arc_discharge.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        nobuff = "tempest",
        texture = 136048,

        handler = function ()

            local ms = 6 + ( 2 * talent.flow_of_power.rank )
            local overload = 2

            ms = ms + ( buff.stormkeeper.up and overload or 0 ) + ( buff.surge_of_power.up and ( 2 * overload ) or 0 ) + ( buff.power_of_the_maelstrom.up and overload or 0 )
            ms = ms * ( buff.primal_fracture.up and 1.5 or 1 )

            gain( ms, "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeStack( "arc_discharge" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                if buff.fusion_of_elements_fire.down then class.abilities.elemental_blast.handler() end
            end

            if buff.stormkeeper.up then
                removeStack( "stormkeeper" )
                if set_bonus.tier30_4pc > 0 then applyBuff( "primal_fracture" ) end
            end

            if pet.storm_elemental.up or buff.lesser_storm_elemental.up then
                addStack( "wind_gust" )
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end

            if talent.arc_discharge.enabled and active_enemies > 1 then
                addStack( "arc_discharge", nil, 2 )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "tempest"
    },

    -- Hurls a bolt of lightning at the target, dealing $s1 Nature damage.$?a343725[    |cFFFFFFFFGenerates $343725s1 Maelstrom.|r][]
    tempest = {
        id = 452201,
        cast = function ()
            if buff.ancestral_swiftness.up or buff.natures_swiftness.up then return 0 end
            if buff.stormkeeper.up then return 0 end
            return ( talent.unrelenting_calamity.enabled and 1.75 or 2 )
                * ( 1 - 0.03 * min( 10, buff.wind_gust.stacks ) )
                * ( 1 - 0.2 * min( 5, buff.maelstrom_weapon.stack ) )
                * ( buff.storm_frenzy.up and 0.6 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "nature",
        known = function() return talent.tempest.enabled end,

        spend = function() return ( buff.ancestral_swiftness.up or buff.natures_swiftness.up ) and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,
        texture = 5927653,
        buff = "tempest",
        talent = "tempest",

        cycle = function() if talent.conductive_energy.enabled then return "lightning_rod" end end,

        handler = function ()
            removeStack( "tempest" )

            local ms = 6 + ( 2 * talent.flow_of_power.rank )
            local overload = 2

            ms = ms + ( buff.stormkeeper.up and overload or 0 ) + ( buff.surge_of_power.up and ( 2 * overload ) or 0 ) + ( buff.power_of_the_maelstrom.up and overload or 0 )
            ms = ms * ( buff.primal_fracture.up and 1.5 or 1 )

            gain( ms, "maelstrom" )

            if buff.ancestral_swiftness.up then removeBuff( "ancestral_swiftness" ) end
            if buff.natures_swiftness.up then removeBuff( "natures_swiftness" ) end
            removeStack( "arc_discharge" )
            removeBuff( "master_of_the_elements" )
            removeBuff( "surge_of_power" )
            removeStack( "power_of_the_maelstrom" )
            removeBuff( "echoing_shock" )
            removeStack( "storm_frenzy" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                if buff.fusion_of_elements_fire.down then class.abilities.elemental_blast.handler() end
            end

            if buff.stormkeeper.up then
                removeStack( "stormkeeper" )
                if set_bonus.tier30_4pc > 0 then applyBuff( "primal_fracture" ) end
            end

            if pet.storm_elemental.up or buff.lesser_storm_elemental.up then
                addStack( "wind_gust" )
            end

            if talent.flash_of_lightning.enabled then flash_of_lightning() end

            if talent.arc_discharge.enabled and active_enemies > 1 then
                addStack( "arc_discharge", nil, 2 )
            end

            if talent.lightning_rod.enabled then applyDebuff( "target", "lightning_rod" ) end

            if set_bonus.tier29_2pc > 0 then
                addStack( "seismic_accumulation" )
            end

            if set_bonus.tww3 >= 4 then removeStack( "storms_eye" ) end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        bind = "lightning_bolt",
        flash = 188196
    },

    -- Talent: Grips the target in lightning, stunning and dealing $305485o1 Nature damage over $305485d while the target is lassoed. Can move while channeling.
    lightning_lasso = {
        id = 305483,
        cast = 5,
        channeled = true,
        cooldown = 45,
        gcd = "spell",
        school = "nature",

        talent = "lightning_lasso",
        startsCombat = true,

        start = function ()
            applyDebuff( "target", "lightning_lasso" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                if buff.fusion_of_elements_fire.down then class.abilities.elemental_blast.handler() end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,

        copy = 305485
    },

    -- Surround yourself with a shield of lightning for $d.    Melee attackers have a $h% chance to suffer $192109s1 Nature damage$?a137041[ and have a $s3% chance to generate a stack of Maelstrom Weapon]?a137040[ and have a $s4% chance to generate $s5 Maelstrom][].    $?s383010[The Shaman can have up to two Elemental Shields active on them.][Only one Elemental Shield can be active on the Shaman at a time.]
    lightning_shield = {
        id = 192106,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        startsCombat = false,

        readyTime = function () return buff.lightning_shield.remains - 120 end,

        handler = function ()
            applyBuff( "lightning_shield" )
            if not talent.elemental_orbit.enabled then removeBuff( "earth_shield" ) end
        end,
    },

    -- Talent: Summons a totem at the target location that erupts dealing $383061s1 Fire damage and applying Flame Shock to $383061s2 enemies within $383061A1 yards. Continues hurling liquid magma at a random nearby target every $192226t1 sec for $d, dealing ${$192231s1*(1+($137040s3/100))} Fire damage to all enemies within $192223A1 yards.
    liquid_magma_totem = {
        id = 192222,
        cast = 0,
        cooldown = function () return 30 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "fire",

        spend = 0.035,
        spendType = "mana",

        talent = "liquid_magma_totem",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "liquid_magma_totem" )
            applyDebuff( "target", "flame_shock" )
            active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 2 )
            gain( 8, "maelstrom" )
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    --[[ Passive in 10.0.5 -- Talent: Summons a totem at your feet for $d that restores $381931s1 mana to you and $s1 allies nearest to the totem within $?s382201[${$s2*(1+$382201s3/100)}][$s2] yards when you cast $?!s137041[Lava Burst][]$?s137039[ or Riptide][]$?s137041[Stormstrike][].    Allies can only benefit from one Mana Spring Totem at a time, prioritizing healers.
    mana_spring_totem = {
        id = 381930,
        cast = 0,
        cooldown = function () return 45 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "mana_spring_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "mana_spring_totem" )
        end,
    }, ]]

    -- Talent: Your next healing or damaging Nature spell is instant cast and costs no mana.
    natures_swiftness = {
        id = 378081,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "nature",

        talent = "natures_swiftness",
        notalent = "ancestral_swiftness",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "natures_swiftness",

        handler = function ()
            applyBuff( "natures_swiftness" )
        end,
    },

    -- Talent: Summons a totem at your feet that removes $383015s1 poison effect from a nearby party or raid member within $383015a yards every $383014t1 sec for $d.
    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = function () return 45 - 6 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.025,
        spendType = "mana",

        talent = "poison_cleansing_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "poison_cleansing_totem" )
        end,
    },

    -- An instant weapon strike that causes $s1 Physical damage.
    primal_strike = {
        id = 73899,
        cast = 0,
        charges = 0,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",
        school = "physical",

        spend = 0.094,
        spendType = "mana",

        notalent = "stormstrike",
        startsCombat = true,

        handler = function ()
            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Blast your target with a Primordial Wave, dealing $375984s1 Shadow damage and apply Flame Shock to them.; Your next $?a137040[Lava Burst]?a137041[Lightning Bolt][Healing Wave] will also hit all targets affected by your $?a137040|a137041[Flame Shock][Riptide] for $?a137039[$s2%]?a137040[$s3%][$s4%] of normal $?a137039[healing][damage].$?s384405[; Primordial Wave generates $s5 stacks of Maelstrom Weapon.][]
    primordial_wave = {
        id = function() return talent.primordial_wave.enabled and 375982 or 326059 end,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "elemental",

        spend = 0.03,
        spendType = "mana",

        talent = function()
            if covenant.necrolord then return end
            return "primordial_wave"
        end,
        startsCombat = true,

        -- velocity = 30,

        usable = function()
            if active_dot.flame_shock < 1 then return false, "requires active flame_shock" end
        end,

        handler = function ()

            if talent.call_of_the_ancestors.enabled then
                applyBuff( "call_of_the_ancestors" )
            end
            gain_maelstrom( 12 )
            if talent.conductive_energy.enabled then active_dot.lightning_rod = min( active_enemies, max( active_dot.lightning_rod, active_dot.flame_shock ) ) end

            removeBuff( "echoing_shock" )
            if talent.splintered_elements.enabled then applyBuff( "splintered_elements" ) end

            if set_bonus.tier31_2pc > 0 and state.spec.elemental then
                applyBuff( "elemental_blast_critical_strike", 10 )
                applyBuff( "elemental_blast_haste", 10 )
                applyBuff( "elemental_blast_mastery", 10 )
            end
        end,

        copy = { 326059, 375982 }
    },

    -- Talent: Removes all movement impairing effects and increases your movement speed by $58875s1% for $58875d.
    spirit_walk = {
        id = 58875,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        school = "physical",

        talent = "spirit_walk",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spirit_walk" )
        end,
    },

    -- Talent: Calls upon the guidance of the spirits for $d, permitting movement while casting Shaman spells. Castable while casting.$?a192088[ Increases movement speed by $192088s2%.][]
    spiritwalkers_grace = {
        id = 79206,
        cast = 0,
        cooldown = function () return 120 - 30 * talent.graceful_spirit.rank end,
        gcd = "spell",
        school = "nature",

        spend = 0.141,
        spendType = "mana",

        talent = "spiritwalkers_grace",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "spiritwalkers_grace" )
        end,
    },

    -- Talent: Summons a totem at your feet for $d that grants $383018s1% physical damage reduction to you and the $s1 allies nearest to the totem within $?s382201[${$s2*(1+$382201s3/100)}][$s2] yards.
    stoneskin_totem = {
        id = 383017,
        cast = 0,
        cooldown = function () return 30 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.015,
        spendType = "mana",

        talent = "stoneskin_totem",
        startsCombat = false,

        handler = function ()
            summonTotem( "stoneskin_totem" )
            applyBuff( "stoneskin" )
        end,
    },

    -- Talent: Calls forth a Greater Storm Elemental to hurl gusts of wind that damage the Shaman's enemies for $157299d.    While the Storm Elemental is active, each time you cast Lightning Bolt or Chain Lightning, the cast time of Lightning Bolt and Chain Lightning is reduced by $263806s1%, stacking up to $263806u times.
    storm_elemental = {
        id = 192249,
        cast = 0,
        charges = 1,
        cooldown = 150,
        recharge = 150,
        gcd = "spell",
        school = "nature",

        talent = "storm_elemental",
        startsCombat = false,

        toggle = "cooldowns",

        timeToReady = function ()
            return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.fire_elemental.remains, pet.primal_fire_elemental.remains )
        end,

        handler = function ()
            summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )
        end,
    },

    -- Talent: Charge yourself with lightning, causing your next $n Chain Lightnings to deal $s2% more damage and be instant cast.
    stormkeeper = {
        id = 191634,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        talent = "stormkeeper",
        startsCombat = false,
        texture = 839977,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "stormkeeper", nil, 2 )

            if talent.fury_of_the_storms.enabled then
                applyBuff( "fury_of_storms" )
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )
            end
        end,
    },

    -- Imbue your shield with the element of Lightning for $d, giving Lightning Bolt and Chain Lightning a chance to call down $s1 Thunderstrikes on your target for $462763s1 Nature damage.
    thunderstrike_ward = {
        id = 462757,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        talent = "thunderstrike_ward",
        startsCombat = false,
        equipped = "shield",
        nobuff = "thunderstrike_ward",

        handler = function()
            -- TODO: Check if we need to use Imbue system instead.
            applyBuff( "thunderstrike_ward" )
        end,
    },

    -- Talent: Calls down a bolt of lightning, dealing $s1 Nature damage to all enemies within $A1 yards, reducing their movement speed by $s3% for $d, and knocking them $?s378779[upward][away from the Shaman]. Usable while stunned.
    thunderstorm = {
        id = 51490,
        cast = 0,
        cooldown = function () return 30 - 5 * talent.thundershock.rank end,
        gcd = "spell",
        school = "nature",

        talent = "thunderstorm",
        startsCombat = true,

        handler = function ()
            removeBuff( "echoing_shock" )
            applyDebuff( "target", "thunderstorm" )

            if buff.fusion_of_elements_nature.up then
                removeBuff( "fusion_of_elements_nature" )
                if buff.fusion_of_elements_fire.down then class.abilities.elemental_blast.handler() end
            end

            if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
        end,
    },

    -- Talent: Relocates your active totems to the specified location.
    totemic_projection = {
        id = 108287,
        cast = 0,
        cooldown = 10,
        gcd = "off",
        school = "nature",

        talent = "totemic_projection",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_recall = {
        id = 108285,
        cast = 0,
        cooldown = function() return talent.call_of_the_elements.enabled and 120 or 180 end,
        gcd = "spell",
        school = "nature",

        talent = "totemic_recall",
        startsCombat = false,

        usable = function() return recall_totem_1 ~= nil end,

        handler = function ()
            if recall_totem_1 then setCooldown( recall_totem_1, 0 ) end
            if talent.creation_core.enabled and recall_totem_2 then setCooldown( recall_totem_2, 0 ) end
        end,
    },

    -- Talent: Summons a totem at your feet that shakes the ground around it for $d, removing Fear, Charm and Sleep effects from party and raid members within $8146a1 yards.
    tremor_totem = {
        id = 8143,
        cast = 0,
        cooldown = function () return 60 - 6 * talent.totemic_surge.rank + ( conduit.totemic_surge.mod * 0.001 ) end,
        gcd = "totem",
        school = "nature",

        spend = 0.023,
        spendType = "mana",

        talent = "tremor_totem",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            summonTotem( "tremor_totem" )
        end,
    },

    -- Talent: Summons a totem at the target location for $d, continually granting all allies who pass within $192078s1 yards $192082s% increased movement speed for $192082d.
    wind_rush_totem = {
        id = 192077,
        cast = 0,
        cooldown = function () return 120 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",
        school = "nature",

        spend = 0.01,
        spendType = "mana",

        talent = "wind_rush_totem",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "wind_rush_totem" )
        end,
    },

    -- Talent: Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    wind_shear = {
        id = 57994,
        cast = 0,
        cooldown = 12,
        gcd = "off",
        school = "nature",

        talent = "wind_shear",
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if time > 0 and talent.inundate.enabled then gain( 8, "maelstrom" ) end
        end,
    },

    -- Pet Abilities
    meteor = {
        id = 117588,
        known = function () return talent.primal_elementalist.enabled and not talent.storm_elemental.enabled and fire_elemental.up end,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = true,
        texture = 1033911,

        talent = "primal_elementalist",

        usable = function () return fire_elemental.up end,
        handler = function () end,
    },

    tempest_pet = { -- TODO: Rename to Tempest (Pet) ?
        id = 157375,
        known = function () return talent.primal_elementalist.enabled and talent.storm_elemental.enabled and storm_elemental.up end,
        cast = 0,
        cooldown = 40,
        gcd = "off",

        startsCombat = true,

        talent = "primal_elementalist",

        usable = function () return storm_elemental.up end,
        handler = function () end,
    },
} )

spec:RegisterStateExpr( "funneling", function ()
    return false
    -- return active_enemies > 1 and settings.cycle and settings.funnel_damage
end )

spec:RegisterSetting( "stack_buffer", 1.1, {
    name = strformat( "%s and %s Padding", Hekili:GetSpellLinkWithTexture( spec.abilities.icefury.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.stormkeeper.id ) ),
    desc = strformat( "The default priority tries to avoid wasting %s and %s stacks with a grace period of 1.1 GCD per stack.\n\n" ..
            "Increasing this number will reduce the likelihood of wasted |W%s|w / |W%s|w stacks due to other procs taking priority, leaving you with more time to react.",
            Hekili:GetSpellLinkWithTexture( spec.abilities.icefury.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.stormkeeper.id ), spec.abilities.icefury.name,
            spec.abilities.stormkeeper.name ),
    type = "range",
    min = 1,
    max = 2,
    step = 0.01,
    width = "full"
} )

spec:RegisterSetting( "hostile_dispel", false, {
    name = strformat( "Use %s or %s", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    desc = strformat( "If checked, %s or %s can be recommended your target has a dispellable magic effect.\n\n"
        .. "These abilities are also on the Interrupts toggle by default.", Hekili:GetSpellLinkWithTexture( 370 ), Hekili:GetSpellLinkWithTexture( 378773 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "purge_icd", 12, {
    name = strformat( "%s Internal Cooldown", Hekili:GetSpellLinkWithTexture( 370 ) ),
    desc = strformat( "If set above zero, %s cannot be recommended again until time has passed since it was last used, even if there are more "
        .. "dispellable magic effects on your target.\n\nThis feature can prevent you from being encouraged to spam your dispel endlessly against enemies "
        .. "with rapidly stacking magic buffs.", Hekili:GetSpellLinkWithTexture( 370 ) ),
    type = "range",
    min = 0,
    max = 20,
    step = 1,
    width = "full"
} )

spec:RegisterRanges( "lightning_bolt", "flame_shock", "wind_shear", "primal_strike" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    canFunnel = true,
    funnel = false,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Elemental",
} )

spec:RegisterPack( "Elemental", 20250821, [[Hekili:T3ZAZTTTw(BXtNrrY2rrIYYX37ANm9MnD3KnTtMvDN(H7CLeffKfhtrYlFyhTRx9BFphaqsaqack5hXTB)qBKfabo48(feNoC6VoDYs3mY0FXzGZ4bx4mS)WZgF24lMojBBmz6KyxVBCVg(qO7g4))XaYgsyMBaoY2Gi3L4kKgLN4bJUollo9V(M3CTF268f99I28Mu)n5bUz(rHEjURYW)27nlcIw8MS1K7CtUdMQF4B(rpCkFnXpkXpB7x8tZsFZsYk38a4rw7UXnCgPyR7JRX0jlY9dY(u40f6pbNdGvmXd(6ZDaiZF5scBUKu4HX5(6bx8ANH)1DZ)j)VTBoCCJ2nhbh4Zj(H3qYs395DFUyMdElmZpf6N57gSB(p(1VayGKOv(bW5(h(HDZFgp77(mUHtkx9pGR(U5FiAZgF4FNSn0dG1ZxEHZfEe2K)xbme8Dvhg8ObF)hdtZtiW5M4ghfUBoj0BTBiSi(P7M7ghh4twc)XQDZ3gL)QBHzMcWIxg(TFAdGaUf)0pfamhzrHxNdt43Olv)DF2LEUs7hNqaSXc3StU6nRQM5m2EEQ)QRGdgC667ZxWz1NvFsO7IayV0UQP3SDvEYw9dg4F96Sq)WRNLU2NeyyjaIw4ssskq6Vb2u3edZJ4MKTMVsiOF0I8vR6l(T9ZJ7WpqLKTzrjlasJ2v8w3eF8SDkkHD1gxsWmp34tV1niNC1Wbdoz8GJ5Rx6DKGa8KGZca1On9tCdV5eNXfZioXFtuYsGhfxexpGHIoL2S1CU(zdNHNPuoe0L)19h2FTB6S8ucD47VV679t7VkpCDeogafP92NDZr)U5yy3CA7ULMfLS5gcjMKW51)uygjjjpg4UJagApxqqRInfEK78dxcerGyYLnqOD3CaHs))3sjMsprASpiZENBWnaRZSRtC9iNcteirxnuCEGqFeWwd8OuEgoXYn1JeU0n0JuWEF)9u2jHbYJV)EVOOGLr3fk(9jKnU(HPVB8aP9badsYnW(V)7J46SYpHqH59Fz2hWfhcyJPmRbbpf7fqg)fsEcQYgul6gNsq66ACEjIqcYm5Nr2W4ndPpYSu2tmJWFGtXzfTA1SR9wE1qeCvbPITEOtZG2qoObSOiOvzVrdeLgeLviTmSoi0TlfiqElyGzu2(ukUPaxwmey0HpSaWjiMiaD960TCgcQuUZ92QZGZ4QTqzo3FpEoUfXCKn(K03DLtVonIpG1AruAANvOY6z8V(sNH1P6vO4Ewrxo)j6scDjWYXmR2ahh(yZa((LAWHV8qHTaFzeXyLnsJu3rgmlchJJmAdJ8pZ9JJjl7Bq)IWmwa6fNbeaems71SYeNb3FVWEwo1QXRqog2zTZvcgeMrVdsWZeArcJP6JXZbgB4Zngt1H0sdjQd0hxuXNm0nd8wpDw6D(RYcjPPOZ9Gq9)fAw7Rr3b20aVCwLN6J(YJ)3hkanwyavlLF4TrGJUKVb(efcNpeayg)IX1bofSLrNvoBgEhjzKpoktCDOUveKNMrxMMmGQrd3OHuLy)9)DYn(b()dioSYh9nC6jeHce)ZU5brx779VSBEc5w)umiLSi8p8a34aS0DRja2XT00llGNC6epEbzf4Y3XIRUKxFYoYwb9Z4lwZEo3P6RtiUl3oRavk6sTgwYEss5AxrhJROw1c9SlGjOv2IGWvdeykSl00ZKORWoQvCsAFmkWHgk0J9pspouK(MKhoJ9xZcGOX5K5iYPy0HEzm9zkMShADbsbb7aGhXn5AGF7ZvrTaRm3L7Q48vhLA0SAyQvywONkJizhM4ToQWoC5ms71H9KvEFFNF6siwsHyae3wMTAH40xtGhAPrd8gmFFjykWO9BQy9KyK9LNobqoEDK3nGujimcA3OlLk8f4d8qlHWHVEJ7SSi0meIzSckJpUjGbmjXPUlJaNzqOzgfyUuHQ)6rLUUPoZUk8hVFKGrGcsE18p1BRxjZrkJdZ6PaodDoszJ7N57HX)1PB7818YRgzX3PbQGTYkkimOalQYiV)Cqfw5EvN2j5VwbTP(0S5RNk8wXNlA3u0kY)zPnczBiAmzOXEbZCHERffGq5qu(Zc3K9ta1xfJLD)9sg7a1ydu(QlVa(McRp9RB4byC3FxZzXfmjh48yjgH7ibEaXCmfEnyOmCjvEmpGEEzN8(7M)(3REsb6tmGT1XpZu6K4nBPFQ3ACeq5LliR4Wb7uegqGJ6cIeylpunjPkpNwefKvUzIHAKh3r)M0rMl9kh1fhGvFuroFl0O8)QZnS27dCoBvcj8)EldNCLth9h9oLP(7YsgHICg(6UdhFIMd(XYGRYF2RJoCfZebMwMcUfMyuus6bIZEbCsPC6uNL)I7TULm9XjrEPmPDp4iKJgFqZXWiUj8Sfw4unpv4y6drhidsHhI6)W8pI5a(FM7EdPOmc(z1nyb7l4VrIEjKc9AG8o8ym6c9jOyMswygSGikUr90zi4wr224McU1Ry5Ns36wIuF3yNxxM2yYwIKsbUaj6)aeUbmY1aeLbGbMJCK9LKwZrdTtShx7smjCPaYZfrUEbriPGI2DJpD38FMc2m8nakakLd5fOyQo3yycjIAB5fRyruEgB1iFlgrhQ4EsjbIQeUctuN9A4GJvmGFYWE8OvmIC1LHYogcW5YrAJVzCV2I5TnRfTJ(abFxRwflcGtyTCsn8e(e5A471Mm2CbacDtjzG6UW80(z3D3OzNf7vuFenwMbSCtegW1(AKvzaxNC1lwA9ldeiV4vgCd9prEYiVk1zOUMuEmlFPWuh4nzexv3VYKuy6RMiupkUImlAOkDaUWNHKOLDK(RlLr9fUrjzsKJS5sTn5u1lyvpJowv5ZbOf45gFUNYzp)GxHZqFYJqlFoLHgDgccbVihIRQScxJD1N9CcaFDpt6Cuxt(SWYMzfmB2TMQaYlJA9mbomv2hRSESZ(F351JY(hwCiK54XLUHBXE1463v4B3phL9rwkwHvbMkJs(O7VNn)54Nu9tOJksBKW5()5NCtsjKK)xoca80ValqHxPZFkQWJKKcoPn5)y2h(cpIWsfCnHty6cdJqNZOqlTJscXfxwP5EI8EyOMwk7uzn4ch0yNb)LfN4dZVAfLNYS2Gpx1iPDosRId(xQnaooxqjVFJK(gz9pugFB0oBHxAjZz8hxnDudSg(Kztsw1P0XM)YQEoWqVCXPUi688t6X8vqrUAs0xTfmJo2zvi6QZRXG3RZV7Cf4rWrGhxK1EAM)PDZxLeLMX38ICUWntpB5MRRmPi789r6aQUnPdrxEKTKeOMeIlAAkeOtiRsiPRPnFvdhVQ(SQAws1yPHIQOoVNTYRaQa(CokzNJkEfIjOVfG7zRim)yCCWw5AWWSG7Zt6n1sog8Y8uWip3lcqVvm1up1UoAibNoRZ58I2ehq(gyI5N)v8G7EnpRpz0CL5U8wxaXvK95kRu0o0J6CGd1dKGG0gWs6lfKXYJWPU1sgSnlt1cO0P5ak3xawfEfegoyywF5sCxUTbbhbzZNa0yvShFTKfC38Fd5bN7cu(n5ERzFkgI93hdc3mSwJl20e)UwiOAat7kj0HvTNskUOkDXEROHYb1IeR0uJyDWvtsSwsQiRIQkvwgbZfAPUyM(sU0(vO2M3(Ayu126LfEa1bsD)dmCUcvsc202iP2BtEaiEX09T3k8SR)ObDBnh0W(bi2zIotRRinv1NHdQzBTusUTAD(zyZZG)tNjUmL4t)i2T4ulqy0rnqluuxANiS3AmlVsbCqAggGLATveQOcQQcqzuGhdPGf0glMJISpo)Ns8HNnDTFmEZpwIhCwehFK6Pota(Fd9vhfP5oR3aAq13Bav0yYJh32mfx3vQo6hOWnhNgasb)Z)UcGhE63upscjI7rjDBQ1j9VHXXlcFgRuxt6REqzeGDSKsoMM01OjmgbJHvqqFw)haN4eg46g8UH9VO5S)pc7A02LNNJ7wgOQAkCozuvwKugQfwEpGsA0RwMhOrU5Mr0zNMPHyLuwiukFrtkaKYkbLAyj7aCcRfIOHOFlTyPNVzVuu99boK1f9Dbg4B3(7bvTiJzQ8O3IQRXg8L1DpNvtt3RHDebz6vheJOhyV496xuEwQ)solzR8J(XmJhn7)ZpG3u0GaukHgnkya9hdUZDl28b366hq1wu9Du9IlIYYq37c8dB6qiJIBNFgIPmP8YPT0hq6ai)UZV)EP8O8dYOAMtar5jvxSnSNxWtxlX1fB)0jGNgOLKIlG7G3oDYDUj4PjD6KFfXc(a9gBKgQALxXVBRVcdPc8CKYgKgHUI5MdilxQdy41qfuqdaZxau3U5dXlQ7hIcHnJo(R03EVVIPHRC0SAd3D436zFvDAEvRnCBxv1UWwZkRzkpLRE1668KGlmTQpm6M5v1koq7uEkx9Q198NeCH5vv(2aOzDRnH2UYhcE4PD1TVUpm(yZRQfSSMj02v2kEOfAlECxD7R7tdV8bs729zn2FkVL4VAVSa92NIdS5fv9AURzH1mfPf)IhxKPTf1keRDkLuQprjs4AEwXfvd9BIDj9NoH(j8hBe3ic8p)c9NUe20MorUoptNWt720)20mWTeCMvFZeVeFWbzF3Pt6UB(rSqE04n7U53FpD8gR2tzg(M3B38ovRNMmcubUkBgcKJmcKnuVNQnhbvBbpUB(L7MFT3sicHVPE4uFKcirgKzEkJG7zkGBX0QNlq2V4kj(XSjy)o(OqGA1PA8U5hVVNTckwxEaX16xayLVQCmEzo3n)17MpITdgFkX1S85E37PpiSN9qe4ydiqHvser0kSq55NXhAOMnfhAByhHJy5HariJkqC6lRehCEhOmFaa3Iz6bfAHJ(5gz1nHr1qgq055mGuKjX8LkIbsJvzo08ak8hwpMJROEkit80(wr9uAYpJIYQlmWxuT5kcupHfVsrsmtBjQKzyK6sxk6XzWaTdb8RxWhPHACjiKsvRwRwxQ0Z6f0sGEIi4)IbempniAyzfWcmv71Vct0JJJeKwVatkqQHkfbqPIgZdOwA4nZcpSGiOjznn5)Gc)Ma(o1LbbXshrv)I5WGU7dTjPxjoFfvC24(xTnknvcDFmBHxW2Uyb7yWEHIsleeysLz9LsORLAyQvHUm1lNi6qHaQ9464pnFvpbCqDAtHZfMUwwhgvYSRh)Ud71mBIrNwkRlqZs)fwcyTRBfLsQQevFT5cSirmnxUsU6eb0hOpDSdfFX84Xq5hKW(fkKS0mF6C3v70LSpQQS6z9Y1rjQMCKQQue18a97WDrtXuQmjvVeXWbusSgxjbHKHuSpsXSXdvohP8FxXLQZRMll9XfV6n05w369yvBZTIbZ2mxCySImWq4rKlWtZE1(ok(8KYhUOamsm6f7HDpXHL7IYJqx8xmr1Y1rxlZLStAJX1PnSlod4o4mu1)6sjczCYFWzjFztN0gy0W32KUS6bf(NuTxeuntHSzZceAE4bD9b1KLiPlbIK6rPrO4DvUbXGxuC)QK2xvB6whoZFWSrms0XlTwkOmfMcZSbLWVCjH6z8DudU0I6QF3D(udFT48XBVaDU(22E5sdEPE4csiNJetcI5M7sar0u8hQP(ukdFNvt4QjjL9sgKkC4OgV(txGyTlilo8BysIubDORrQzK7j4ELsrBQbQVVOThBKXElkkBP9chr3tSgkB9f4PiuyT2wmX(xgxGw2IcgqR694tqFwDkO364XEbEhEPmQp0eT0ogv9j6sbn9OEjxPhU9SYnCOuxnnguP5YsUIAVFl7L2ynir7XcBWyPXOoBHxWmIqBVkSkHazslKUd3vLfnQM(PEIII))fNzT5gRJXisBmxcpt0ddCIngpM2OO)(cVQHkOK)D5MzvYRM6rIFK5dt32zOrphtrHFfu3v1lO0(xyGyDovZ(UCnohP6yn7JZyTuQmkqOjwnOQL)umK5iQRLvFv9Lwh8lbEaZSuFVo9p(nBI0u5n5HSYAdxAznHX89PpvEiTKYl7B8SIFrn1uhLSxAREB7CQsBs1C2NKQnvt3TuDeA4QX9ODg03XgUl32itrJDMYtlMxVMTIMhraGQNWHwF)PR2dnnPYfI63S3KkMsU1VtAsLhE)MuYHjANvQPGCu1C1yJPuSN2vnIDutTMyYChUnvxtGuqUkB5LhC)M8(3xZTL6TWrZDeIHhQPgx4PSTpQJL01QeT2gZbD3Vpe9Mw1U3gFaNQRBjQN(TM5spZIRQTPRqgoWGFoIx772D(TP73yJei5SPer9bCvYpes7bACr0YT0ThxIA36IgBQxkEEU75I4T2u3UIg(0gkQCoACLMIa1pOOhRot1vc3xWGR2aJBQGMpY194Oh3kAmTPYU94M5XcWwPEdgZ7T2qYL8JOXRMoZJI(xOlh465JgX7S2ADiW(LYCwxdiLQOMYf(jSn(4wn59WHNhX693ClRTh)ohm1AbqTKZtAgwEaxc)AU7ynhJcmUTIbTfz0sXPIMRz0uD1uTEE4((aBgn4PRELV8aAzn4SkfwZnFPy4QvKgTEplNJQcdlkxXFQ9KZAYvDZfnrmlCgnRCa)Gb8KLg126)CTcIiD6Ey)qc0iQw1de2h1MC1A)Sbqv3YZW9EM51APDV2(kJaA5pgbgyve3AQtP0FsbktvRj0U2xbWvBr1layDPYT5dKH3wWcjxT(7ky1Kx3u6NkmWvXRwQYOYBqzgzjpmmC7LgpOccRElfRlFQpmOryxkFhf3CMcpKDz)pZLVPJTM)VNbGPY7fu9IUeawmtdVG9MobVzT837MuxBzV2(noDfLKMUIBoT7SG34pjHcJV7Llt6OMZgpvCaWJVw)e)B1dNKDylPSRDzIRDj3BW(6b7EKYoCAuFdvQ7OtXEALiuedP5oU1zOEEwvAUQRYQVVQBkxW854OqfD(tQ4ZpvSPKaJZL(EEUGqj8fnsP(JazApPfnIOniRWFrBRn73penESOHn8ZmHaktzEkV1tPNlBVeyvML0lD1DfDrVnKOtvkjA4hyKYPkswS82Kv7ZO9ndB5mlBtBtDI6HO9YcM2efrLY9DLIu)hwNNBkILBJQ23r26IhInCvLmk9Cs9DOTsCX1QdGcai((RUnQfSQgF0WkGJ9UYwBc5JaxOtjzvZTiZF4NcYjSQFAIPQJ0yY)GeXGW2Wc0tNiS5ns9x(iLnQbP)ETvmqXSGv(swxxkjDy9zmatkcDkqIbUDn7Vv5IcBznqBpYifXyH4T8Mt)0hT3C6uo1zS4qQxWDlfnPMpuGif2Ns47HBQ63cPbLx52SFVGk21isJ11OPNvUvWOjBO83pkDPBqkrjzrHxNtMXCbOw(csZXmfWgeRbg(dofhD6ghh4twwElLFf2yhPKaIhTKIFAtCcqnwYl8iBB2n)3OlLUMYYN)aZQdws5Ssurz6nBzv7rs9OuMfRPTvEUs6DZwtZhns6Ub2B3e1z3yMaO6ylYYjvVVsHnlZABuYc)mZziTWOW(REDi(dzYjya7IL4i9osqaIbkRZs)e3WBOZ0rQmlcoH65g765NTLovr5JII4Ol0F7qOnVkegu9hIlASEvWbFMZgsF6uDrRVFGJo3ofgSLGJtf48xKyvf7BrrMkQ8QBE26iyGj(BYdCXN4djURydo9)7p]] )