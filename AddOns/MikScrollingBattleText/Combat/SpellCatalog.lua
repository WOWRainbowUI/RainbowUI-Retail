-- Adapted from NameplateSCT Reforged (Justwait, KidMoxie; MIT).
-- See Combat/LICENSE-NameplateSCTReforged.
-- Source: https://github.com/dbspringer/nameplatesct-reforged
-- Revision: e678a89bb7fe15232e0425c81735779da13d5111
-- Data build: WoW: Forever 1.60.1.70888, interface 16001.
-- These records describe cast IDs, not every triggered damage spell.
local engine = MikSBT.CombatEngine
local source = {}

-- Upstream DirectSpells.lua
do
local ns = source
-- The spells that hit directly, by the spell ID of their cast: a direct hit,
-- a weapon strike, a leech such as Death Coil, or a ranged attack, whose Hits
-- come with shot Log Lines. For each, the school its Hit reports, or that it
-- learns its school from its Hits, as a wand sets Shoot's. Which casts can
-- be a Hit's spell is decided in Identity's canHit (ADR 0004); a cast of a
-- spell in neither table, such as a buff or a Voidwalker's Torment, is never
-- one. The pets' spells are here so that they compete with the player's,
-- though they never win. Spells that also tick are in TickSpells.lua.
--
-- From Forever's spell data (wago.tools DB2, build 1.60.1.70888: SpellEffect
-- school damage, health leech and weapon damage effects, SpellMisc school),
-- for the cast of every spell in a class or pet skill line or a talent
-- (TraitDefinition), also where no trainer or talent is known to teach it,
-- and the ranged attacks; the Classic spells' schools agree with the Classic
-- Era data. Left out, among others: spells whose damage comes from another
-- spell (Arcane Missiles, Hellfire, Execute), procs (poisons, weapon enchants;
-- a Seal Proc has its own rule, see ns.Seals), totems, and Mana Burn. Holy
-- Shock, whose damage a script makes, is in, so that its Hit on an enemy gets its icon; the cost is
-- that its cast on a friend, which heals, competes with the casts that could
-- have made a Holy Hit.
--
-- Build 70888 took some IDs out of the skill lines (Primal Bite 1238073, Frost
-- Blast, and Forever's Lava Burst ranks). They stay, as a cast that no player
-- makes costs nothing.

local PHYSICAL, HOLY, FIRE, NATURE, FROST, SHADOW, ARCANE = 1, 2, 4, 8, 16, 32, 64

local spells = {}
ns.DirectSpells = spells

-- The ranks of a spell share one table, as nothing changes an entry.
local function addSpell(spell, ids)
	for _, id in ipairs(ids) do
		spells[id] = spell
	end
end

local function hits(school, ids)
	addSpell({ school = school }, ids)
end

-- A ranged attack: its Hits come with shot Log Lines, not direct ones.
local function shoots(school, ids)
	addSpell({ school = school, shot = true }, ids)
end

-- How long after its cast a Judgement's Hit can come. A live Paladin's 11 Hits and
-- misses came up to 0.166 s after it, and other players' 34 within 0.1 s. Its
-- damage is another spell, so only this nearness ties it to the cast.
local JUDGEMENT_WINDOW = 0.2

local function judges(ids)
	addSpell({ school = HOLY, window = JUDGEMENT_WINDOW }, ids)
end

-- The Seals, by the spell ID of their cast, from Forever's spell data, each with
-- whether its Seal Proc gets an icon (see Identity's sealProc). Any Seal's cast
-- replaces the Active Seal. Seal of Martyrdom also procs Holy damage, but no
-- Trace has it, so it only replaces the last Seal.
local seals = {}
ns.Seals = seals

local function sealsWith(proc, ids)
	for _, id in ipairs(ids) do
		seals[id] = proc
	end
end

sealsWith(true, { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, 21084 }) -- Righteousness
sealsWith(true, { 20375, 20915, 20918, 20919, 20920 }) -- Command
sealsWith(true, { 20163, 20419, 20421, 20422, 20423, 1311649, 1311656 }) -- Fury, Forever only
sealsWith(false, { 20164 }) -- Justice
sealsWith(false, { 20165, 20347, 20348, 20349 }) -- Light
sealsWith(false, { 20166, 20356, 20357 }) -- Wisdom
sealsWith(false, { 20162, 20305, 20306, 20307, 20308, 21082 }) -- the Crusader
sealsWith(false, { 407798 }) -- Martyrdom

-- Consecration's casts. Its ticks are direct Holy Hits with no cast of their
-- own, so during it they cannot be told from a Seal Proc (see Identity).
ns.ConsecrationSpells = { [20116] = true, [20922] = true, [20923] = true, [20924] = true, [26573] = true }

-- A Next-Swing Ability: its frame has an Empty Report before the real Hit (see
-- Pairing.New). Seen on Heroic Strike in the Warrior Trace and on other
-- players' Heroic Strikes in the open-world Traces. Unverified on Maul, Raptor
-- Strike, and Cleave, which replace a swing in the same way.
local function replacesSwing(ids)
	addSpell({ school = PHYSICAL, nextSwing = true }, ids)
end

do
	-- Ranged attacks
	spells[5019] = { learns = true, shot = true } -- Shoot, whose school its wand sets
	shoots(PHYSICAL, { 75 }) -- Auto Shot
	shoots(PHYSICAL, { 2480, 7918, 7919 }) -- Shoot Bow, Shoot Gun, Shoot Crossbow
	shoots(PHYSICAL, { 2764 }) -- Throw
	-- Druid
	hits(PHYSICAL, { 769, 779, 780, 9754, 9908 }) -- Swipe
	hits(ARCANE, { 2912, 8949, 8950, 8951, 9875, 9876, 25298 }) -- Starfire
	hits(PHYSICAL, { 1082, 3029, 5201, 9849, 9850 }) -- Claw
	hits(NATURE, { 5176, 5177, 5178, 5179, 5180, 6780, 8905, 9912 }) -- Wrath
	hits(PHYSICAL, { 5221, 6800, 8992, 9829, 9830 }) -- Shred
	hits(PHYSICAL, { 6785, 6787, 9866, 9867 }) -- Ravage
	replacesSwing({ 6807, 6808, 6809, 8972, 9745, 9880, 9881 }) -- Maul
	hits(PHYSICAL, { 22568, 22827, 22828, 22829, 31018 }) -- Ferocious Bite
	hits(PHYSICAL, { 1328618 }) -- Ferocious Bite, Forever only (a Druid's cast in the BFD group Trace)
	hits(PHYSICAL, { 407995, 1238069, 1238070, 1238073 }) -- Primal Bite, Forever only (the first rank is Mangle's ID)

	-- Hunter
	hits(PHYSICAL, { 1495, 14269, 14270, 14271 }) -- Mongoose Bite
	hits(PHYSICAL, { 2643 }) -- Multi-Shot
	hits(PHYSICAL, { 2974, 14267, 14268, 27633 }) -- Wing Clip
	hits(ARCANE, { 3044, 14281, 14282, 14283, 14284, 14285, 14286, 14287 }) -- Arcane Shot
	replacesSwing({ 2973, 14260, 14261, 14262, 14263, 14264, 14265, 14266 }) -- Raptor Strike
	hits(PHYSICAL, { 19306, 20909, 20910 }) -- Counterattack
	hits(PHYSICAL, { 19434, 20900, 20901, 20902, 20903, 20904, 27632 }) -- Aimed Shot
	hits(PHYSICAL, { 19503 }) -- Scatter Shot
	hits(PHYSICAL, { 1242634 }) -- Counterattack, Forever's rank
	hits(PHYSICAL, { 1310687, 1310785, 1310786 }) -- Sniper Shot, Forever only
	hits(PHYSICAL, { 1317257 }) -- Strider Kick, Forever only
	-- The cast's own hit; the hawk's attacks after it are not the player's.
	hits(PHYSICAL, { 1293241, 1293525, 1293526, 1293527 }) -- Summon Hawk, Forever only

	-- Mage
	hits(FROST, { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 }) -- Frostbolt
	hits(FROST, { 120, 8492, 10159, 10160, 10161 }) -- Cone of Cold
	hits(FROST, { 122, 865, 6131, 10230 }) -- Frost Nova
	hits(ARCANE, { 1449, 8437, 8438, 8439, 10201, 10202 }) -- Arcane Explosion
	hits(FIRE, { 2136, 2137, 2138, 8412, 8413, 10197, 10199 }) -- Fire Blast
	hits(FIRE, { 2948, 8444, 8445, 8446, 10205, 10206, 10207 }) -- Scorch
	hits(FIRE, { 11113, 13018, 13019, 13020, 13021 }) -- Blast Wave
	hits(FIRE, { 2120, 2121, 8422, 8423, 10215, 10216 }) -- Flamestrike; its DoT is left out (TickSpells.lua)
	hits(FIRE, { 24530 }) -- Felfire
	hits(ARCANE, { 400574 }) -- Arcane Blast
	hits(FROST, { 400640 }) -- Ice Lance
	hits(ARCANE, { 1239696, 1239697, 1239699, 1239700 }) -- Arcane Blast, Forever's ranks
	hits(FROST, { 1240044, 1240045, 1240046, 1240047, 1312002 }) -- Ice Lance, Forever's ranks
	hits(FROST, { 1326053, 1326054, 1326055 }) -- Frost Blast, Forever only
	hits(ARCANE, { 1326079, 1326080, 1326081, 1326082 }) -- Arcane Wrath, Forever only

	-- Paladin
	hits(HOLY, { 879, 5614, 5615, 10312, 10313, 10314 }) -- Exorcism
	hits(HOLY, { 2812, 10318 }) -- Holy Wrath
	hits(HOLY, { 24239, 24274, 24275 }) -- Hammer of Wrath
	-- Weapon damage plus Holy damage; which school the Hit reports is untested.
	hits(HOLY, { 678, 679, 680, 1866, 2495, 5569, 10332, 10333 }) -- Holy Strike, Forever only
	hits(HOLY, { 1311606, 20473, 20929, 20930 }) -- Holy Shock; Forever's first rank, then the Classic ranks
	hits(HOLY, { 407632 }) -- Hammer of the Righteous
	judges({ 20271 }) -- Judgement

	-- Priest
	hits(HOLY, { 585, 591, 598, 984, 1004, 6060, 10933, 10934 }) -- Smite
	hits(SHADOW, { 8092, 8102, 8103, 8104, 8105, 8106, 10945, 10946, 10947 }) -- Mind Blast
	hits(HOLY, { 15237, 15430, 15431, 27799, 27800, 27801 }) -- Holy Nova
	hits(HOLY, { 1277331, 1277332, 1277333, 1277334, 1277335 }) -- Chastise, Forever only
	hits(SHADOW, { 1309595, 1309633, 1309635, 1309636 }) -- Shadow Word: Death, Forever only

	-- Rogue
	hits(PHYSICAL, { 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300 }) -- Backstab
	hits(PHYSICAL, { 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294 }) -- Sinister Strike
	hits(PHYSICAL, { 1766, 1767, 1768, 1769 }) -- Kick
	hits(PHYSICAL, { 1776, 1777, 8629, 11285, 11286 }) -- Gouge
	hits(PHYSICAL, { 2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016 }) -- Eviscerate
	hits(PHYSICAL, { 8676, 8724, 8725, 11267, 11268, 11269 }) -- Ambush
	hits(PHYSICAL, { 14251 }) -- Riposte
	hits(PHYSICAL, { 14278 }) -- Ghostly Strike
	hits(PHYSICAL, { 16511 }) -- Hemorrhage
	hits(PHYSICAL, { 1329283, 1329549 }) -- Shank, Forever only
	-- The casts. Each one makes two Hits, a main-hand and an off-hand strike
	-- (untested), and a cast gives its spell to one Hit, so only the first
	-- gets the icon.
	hits(PHYSICAL, { 1310707, 399956, 1241582, 1241584 }) -- Mutilate, Forever only

	-- Shaman
	hits(NATURE, { 403, 529, 548, 915, 943, 6041, 10391, 10392, 15207, 15208 }) -- Lightning Bolt
	hits(NATURE, { 421, 930, 2860, 10605 }) -- Chain Lightning
	hits(NATURE, { 8042, 8044, 8045, 8046, 10412, 10413, 10414 }) -- Earth Shock
	hits(FROST, { 8056, 8058, 10472, 10473 }) -- Frost Shock
	hits(PHYSICAL, { 17364 }) -- Stormstrike
	hits(FIRE, { 408490 }) -- Lava Burst
	hits(FIRE, { 1238299, 1238300, 1326047 }) -- Lava Burst, Forever's ranks

	-- Warlock
	hits(SHADOW, { 686, 695, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307 }) -- Shadow Bolt
	hits(FIRE, { 5676, 17919, 17920, 17921, 17922, 17923 }) -- Searing Pain
	hits(FIRE, { 6353, 17924 }) -- Soul Fire
	hits(SHADOW, { 6789, 17925, 17926 }) -- Death Coil
	hits(SHADOW, { 17877, 18867, 18868, 18869, 18870, 18871 }) -- Shadowburn
	hits(FIRE, { 17962, 18930, 18931, 18932 }) -- Conflagrate
	hits(FIRE, { 412758 }) -- Incinerate
	hits(FIRE, { 1293812, 1293813 }) -- Incinerate, Forever's ranks
	hits(FIRE, { 1293817, 1293818 }) -- Conflagrate, Forever's ranks

	-- Warrior
	hits(PHYSICAL, { 72, 1671, 1672 }) -- Shield Bash
	replacesSwing({ 78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286, 25712 }) -- Heroic Strike
	hits(PHYSICAL, { 694, 7400, 7402, 20559, 20560 }) -- Mocking Blow
	replacesSwing({ 845, 7369, 11608, 11609, 20569 }) -- Cleave
	hits(PHYSICAL, { 1464, 8820, 11604, 11605 }) -- Slam
	hits(PHYSICAL, { 1680 }) -- Whirlwind
	hits(PHYSICAL, { 1715, 7372, 7373, 27584 }) -- Hamstring
	hits(PHYSICAL, { 6343, 8198, 8204, 8205, 11580, 11581 }) -- Thunder Clap
	hits(PHYSICAL, { 6552, 6554 }) -- Pummel
	hits(PHYSICAL, { 6572, 6574, 7379, 11600, 11601, 25288 }) -- Revenge
	hits(PHYSICAL, { 7384, 7887, 11584, 11585 }) -- Overpower
	hits(PHYSICAL, { 12294, 21551, 21552, 21553, 27580 }) -- Mortal Strike
	hits(PHYSICAL, { 23881, 23892, 23893, 23894 }) -- Bloodthirst
	hits(PHYSICAL, { 23922, 23923, 23924, 23925 }) -- Shield Slam
	hits(PHYSICAL, { 402927 }) -- Victory Rush
	hits(PHYSICAL, { 1240193 }) -- Slam, Forever's rank
	hits(PHYSICAL, { 1310222 }) -- Spearing Strike, Forever only

	-- Pets
	hits(FIRE, { 3110, 7799, 7800, 7801, 7802, 9057, 11762, 11763, 15598, 18187 }) -- Firebolt, the Imp's
	hits(SHADOW, { 7814, 7815, 7816, 11778, 11779, 11780 }) -- Lash of Pain, the Succubus's
	hits(PHYSICAL, { 3009, 3010, 16827, 16828, 16829, 16830, 16831, 16832 }) -- Claw
	hits(PHYSICAL, { 17253, 17255, 17256, 17257, 17258, 17259, 17260, 17261 }) -- Bite
	hits(NATURE, { 24844, 25008, 25009, 25010, 25011, 25012 }) -- Lightning Breath
	hits(PHYSICAL, { 24423, 24577, 24578, 24579 }) -- Demoralizing Screech (Screech in Classic)
	hits(NATURE, { 26090, 26187, 26188, 1264455 }) -- Thunderstomp
	hits(FIRE, { 444678, 444681 }) -- Lava Breath
	hits(NATURE, { 1264478, 1264479, 1264480, 1264481, 1264482 }) -- Sonic Blast, Forever only
	hits(PHYSICAL, { 1264494, 1264497, 1264498, 1264501, 1264502 }) -- Swipe, Forever only
	hits(PHYSICAL, { 1264735, 1264736, 1264739, 1264741, 1264742 }) -- Pinch, Forever only
	hits(PHYSICAL, { 1264758, 1264927, 1264929, 1264930, 1264933 }) -- Dismember, Forever only
	hits(PHYSICAL, { 1265054, 1265055, 1265056, 1265057, 1265058 }) -- Mine!, Forever only
end

end

-- Upstream TickSpells.lua
do
local ns = source
-- The damage spells that tick, by the spell ID of their cast. For each: the
-- time between ticks, and the longest time any rank ticks for with its
-- talents, in seconds; the school of its ticks, which is also the school of
-- its direct hit (a spell in this table needs no Spell Facts); whether its
-- cast also hits; whether it travels to its target first; and whether it is
-- an area spell, whose ticks come as direct Log Lines. Spell Identity reads
-- ticks only from this table (ADR 0004).
--
-- From Forever's spell data (wago.tools DB2, build 1.60.1.70888: SpellEffect
-- periodic damage and leech auras and school damage effects, SpellMisc school
-- and missile speed, SpellDuration), for the cast of every spell in a class
-- or pet skill line or a talent (TraitDefinition), also where no trainer or
-- talent is known to teach it; the Classic spells' values agree with the
-- Classic Era data. Left out: ticks with no cast of their own (Ignite, Deep
-- Wounds, Deadly Poison), traps, totems (the totem is the source), Hellfire
-- and Arcane Missiles (their damage hits rather than ticks), Wyvern Sting,
-- Curse of Doom (Bane of Doom on Forever; one tick at 60 s), and the area
-- spells that are not channels (Consecration, Flamestrike's DoT). Corruption,
-- Bane of Agony, Immolate, Drain Life and Drain Soul are checked against the
-- Warlock Traces.
--
-- On Forever the area spells tick from an area trigger, not Classic's area
-- aura, at the same interval, and each tick is a direct hit of another spell
-- ID: Rain of Fire's in the Rain of Fire Trace, the others untested. Only the
-- channelled ones are here (Blizzard, Hurricane, Rain of Fire, Volley): the
-- player can neither swing nor cast while channelling, and the channel's stop
-- ends the ticks, so a proc with no cast, such as a seal's, seldom lands on
-- the tick grid. During Consecration such procs would take its icon.
--
-- Ticks come only from the player's casts. The pets' spells are here so that
-- a pet's missed application competes with the player's casts, as in
-- DirectSpells.lua.

local PHYSICAL, HOLY, FIRE, NATURE, FROST, SHADOW, ARCANE = 1, 2, 4, 8, 16, 32, 64

local spells = {}
ns.TickSpells = spells

-- The ranks of a spell share one table, as nothing changes an entry.
local function ticks(interval, school, duration, kind, ids)
	local spell = {
		interval = interval,
		school = school,
		duration = duration,
		hits = kind.hits == true,
		travels = kind.travels == true,
		area = kind.area == true,
	}
	for _, id in ipairs(ids) do
		spells[id] = spell
	end
end

do
	-- Druid
	ticks(3, NATURE, 27, {}, { 339, 1062, 5195, 5196, 9852, 9853 }) -- Entangling Roots
	ticks(2, PHYSICAL, 12, {}, { 1079, 9492, 9493, 9752, 9894, 9896 }) -- Rip
	ticks(3, PHYSICAL, 9, { hits = true }, { 1822, 1823, 1824, 9904 }) -- Rake
	ticks(2, NATURE, 12, {}, { 5570, 24974, 24975, 24976, 24977 }) -- Insect Swarm
	ticks(3, ARCANE, 12, { hits = true }, { 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835 }) -- Moonfire
	ticks(1, NATURE, 10, { area = true }, { 16914, 17401, 17402 }) -- Hurricane
	ticks(3, PHYSICAL, 15, {}, { 414644 }) -- Lacerate
	ticks(3, PHYSICAL, 18, {}, { 9005, 9823, 9827 }) -- Pounce; its ticks are Pounce Bleed's
	ticks(3, PHYSICAL, 15, {}, { 1235826, 1235827, 1328616, 1328617 }) -- Lacerate, Forever's ranks (interval untested)

	-- Hunter
	ticks(1, ARCANE, 6, { travels = true, area = true }, { 1510, 14294, 14295 }) -- Volley
	ticks(3, NATURE, 15, { travels = true }, { 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 }) -- Serpent Sting
	ticks(2, SHADOW, 30, { travels = true }, { 3674, 14296 }) -- Black Arrow
	ticks(3, PHYSICAL, 21, {}, { 24118, 24119, 24120, 1299332 }) -- Lacerate, the Hunter's

	-- Mage
	ticks(1, FROST, 8, { area = true }, { 10, 6141, 8427, 10185, 10186, 10187 }) -- Blizzard
	ticks(2, FIRE, 8, { hits = true, travels = true }, { 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 }) -- Fireball
	ticks(3, FIRE, 12, { hits = true, travels = true }, { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 }) -- Pyroblast
	ticks(3, FIRE + FROST, 9, { hits = true, travels = true }, { 401502 }) -- Frostfire Bolt
	ticks(3, FIRE + FROST, 9, { hits = true, travels = true }, { 1237312, 1237313 }) -- Frostfire Bolt, Forever's ranks (interval untested)

	-- Priest
	-- Shadow Word: Pain lasts 18 s, and Improved Shadow Word: Pain adds 6.
	ticks(3, SHADOW, 24, {}, { 589, 594, 970, 992, 2767, 10892, 10893, 10894 }) -- Shadow Word: Pain
	ticks(3, SHADOW, 24, {}, { 2944, 19276, 19277, 19278, 19279, 19280 }) -- Devouring Plague
	ticks(1, ARCANE, 6, {}, { 10797, 19296, 19299, 19302, 19303, 19304, 19305 }) -- Starshards
	ticks(2, HOLY, 10, { hits = true }, { 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267 }) -- Holy Fire
	ticks(1, SHADOW, 3, {}, { 15407, 17311, 17312, 17313, 17314, 18807 }) -- Mind Flay
	ticks(1, HOLY, 2, { hits = true }, { 402174, 1240720, 1240721, 1316995 }) -- Penance, Forever only (untested; may hit, not tick)

	-- Rogue
	ticks(3, PHYSICAL, 18, {}, { 703, 8631, 8632, 8633, 11289, 11290 }) -- Garrote
	ticks(2, PHYSICAL, 16, {}, { 1943, 8639, 8640, 11273, 11274, 11275 }) -- Rupture
	ticks(6, PHYSICAL, 6, {}, { 1316709, 1325756, 1325757, 1325758 }) -- Death Mark, Forever only (one tick as it ends; untested)

	-- Shaman
	ticks(3, FIRE, 12, { hits = true }, { 8050, 8052, 8053, 10447, 10448, 29228 }) -- Flame Shock

	-- Warlock
	ticks(3, SHADOW, 18, {}, { 172, 6222, 6223, 7648, 11671, 11672, 25311 }) -- Corruption
	ticks(3, FIRE, 15, { hits = true }, { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 }) -- Immolate
	ticks(1, SHADOW, 5, {}, { 689, 699, 709, 7651, 11699, 11700 }) -- Drain Life
	ticks(2, SHADOW, 24, {}, { 980, 1014, 6217, 11711, 11712, 11713 }) -- Curse of Agony; Bane of Agony on Forever
	ticks(3, SHADOW, 15, {}, { 1120, 8288, 8289, 11675 }) -- Drain Soul
	ticks(2, FIRE, 8, { area = true }, { 5740, 6219, 11677, 11678 }) -- Rain of Fire
	ticks(3, SHADOW, 30, {}, { 18265, 18879, 18880, 18881 }) -- Siphon Life
	ticks(1, SHADOW, 6, {}, { 1316697 }) -- Wrack, Forever only (a channel)

	-- Warrior
	ticks(3, PHYSICAL, 21, {}, { 772, 6546, 6547, 6548, 11572, 11573, 11574 }) -- Rend

	-- Pets
	ticks(2, NATURE, 10, {}, { 24583, 24586, 24587, 24640 }) -- Scorpid Poison
	ticks(3, PHYSICAL, 9, {}, { 1265038, 1265039, 1265040, 1265041, 1265042 }) -- Tendon Rip, Forever only
	ticks(3, PHYSICAL, 18, {}, { 1265065, 1265066, 1265067, 1265068, 1265069 }) -- Savage Rend, Forever only
	ticks(1, NATURE, 4, {}, { 1265843, 1265878, 1265880, 1265881, 1265883 }) -- Web, Forever only
end

end

-- Return a fresh normalized record: source ranks share immutable tables.
-- Unconstrained direct casts keep MSBT's existing three-second flight policy:
-- upstream Identity's 1.5 seconds is an inference window, not spell metadata.
-- Explicit per-spell windows and Pairing's 2.5-second shot window are retained.
-- A nil school is deliberate for Shoot, whose wand sets its school.
function engine.CatalogSpellFacts(spellID)
    local direct = source.DirectSpells[spellID]
    local ticking = source.TickSpells[spellID]
    local spell = ticking or direct
    if not spell then return nil end
    return {
        damages = true,
        school = spell.school,
        direct = direct ~= nil or spell.hits == true,
        ticks = ticking ~= nil,
        period = ticking and ticking.interval or nil,
        duration = ticking and ticking.duration or nil,
        travels = spell.travels == true,
        area = spell.area == true,
        shot = spell.shot == true,
        nextSwing = spell.nextSwing == true,
        window = spell.window or (spell.shot and 2.5 or 3),
        learnsSchool = spell.learns == true,
        source = "nameplatesct-reforged",
        sourceBuild = "1.60.1.70888",
    }
end
