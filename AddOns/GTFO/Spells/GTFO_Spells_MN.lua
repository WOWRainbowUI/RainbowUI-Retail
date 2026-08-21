--------------------------------------------------------------------------
-- GTFO_Spells_MN.lua 
--------------------------------------------------------------------------
--[[
GTFO Spell List - Midnight
]]--

if (GTFO.RetailMode) then

--- ********************
--- * Midnight (World) *
--- ********************

GTFO.SpellID["1225385"] = {
  --desc = "Grasping Shadows (Voidgorged Reserve)";
  sound = 1;
  instance = 2858; 
};

GTFO.SpellID["1243988"] = {
  --desc = "Blinding Fissure (Lu'ashal)";
  encounter = 3454;
  sound = 1;
};

GTFO.SpellID["1270862"] = {
  --desc = "Ruptured Ground (The Hundred Thunders)";
  map = 2437; -- Zul'Aman
  sound = 1;
  tankSound = 2;
};

GTFO.SpellID["1284716"] = {
  --desc = "Mana Pool (Nexus-Captain Leth'ir)";
  map = 2600; -- Naigtal
  sound = 1;
};

GTFO.SpellID["1295990"] = {
  --desc = "Arcane Dissolution (Nexus-Captain Leth'ir)";
  map = 2600; -- Naigtal
  sound = 1;
};

GTFO.SpellID["1270524"] = {
  --desc = "Alchemical Sludge (Ash'an the Empowered)";
  map = 2437; -- Zul'Aman
  sound = 1;
};

GTFO.SpellID["1276517"] = {
  --desc = "Ancient Seeds (Cragpine)";
  map = 2437; -- Zul'Aman
  sound = 1;
};

GTFO.SpellID["1297422"] = {
  desc = "Deadly Venom (Environment)";
  maps = { 2512, 2588 }; -- The Coiled Isle, Altar of Fangs
  sound = 1;
};

GTFO.SpellID["1298887"] = {
	--desc = "Noxious Venom (Azta'rec)";
	instance = 3079; -- Venomfall Deeps
	sound = 1;
};

GTFO.SpellID["1285733"] = {
  --desc = "Brambles";
  map = 2512; -- The Coiled Isle
  sound = 2;
};

GTFO.SpellID["1285145"] = {
  --desc = "Water Hazard";
  map = 2512; -- The Coiled Isle
  sound = 2;
};

GTFO.SpellID["1285890"] = {
  --desc = "Return To The Track!";
  map = 2512; -- The Coiled Isle
  sound = 1;
};



--- *******************
--- * Midnight (Prey) *
--- *******************

GTFO.SpellID["1253237"] = {
  --desc = "Null-Magic Missiles (L-N-0R the Recycler)";
  map = 2395; -- Eversong Woods
  sound = 1;
};

GTFO.SpellID["1256357"] = {
  --desc = "Undead Eruption (Knight-Errant Bloodshatter)";
  map = 2437; -- Zul'Aman
  sound = 1;
};

--- *********************
--- * Midnight (Delves) *
--- *********************

GTFO.SpellID["1287680"] = {
	--desc = "Snake Eater (Graka Snake-Eater)";
	instance = 3038; -- Gnarldor Isle
	encounter = 3512;
	sound = 1;
};

GTFO.SpellID["1301863"] = {
	--desc = "Spirit Tear (Drakta)";
	instance = 3077; -- The Ring of Glory
	encounter = 3535;
	sound = 1;
};

GTFO.SpellID["1280182"] = {
  --desc = "Ula'tek Poison Pool";
  instance = 2963; -- The Grudge Pit
  sound = 1;
};

--- *****************************
--- * Magister's Terrace (2811) *
--- *****************************

GTFO.SpellID["1214089"] = {
  --desc = "Arcane Residue (Arcanotron Custos)";
  sound = 1;
  instance = 2811; 
};

--- *************************
--- * Voidscar Arena (2923) *
--- *************************

GTFO.SpellID["1234833"] = {
  --desc = "Ravenous Swarm (Chitigoth)";
  instance = 2923;
  sound = 1;
};

-- Toxic Sludge is in GTFO_Spells_TWW.lua because it is used in multiple instances.

--- ***************************
--- * Windrunner Spire (2805) *
--- ***************************

GTFO.SpellID["473784"] = {
  --desc = "Fetid Spew (Flesh Behemoth)";
  sound = 1;
  instance = 2805; 
};

GTFO.SpellID["472118"] = {
  --desc = "Ignited Embers (Emberdawn)";
  sound = 1;
  instance = 2805; 
  test = true;
};

GTFO.SpellID["468924"] = {
  --desc = "Bladestorm (Commander Kroluk)";
  sound = 1;
  instance = 2805; 
};

GTFO.SpellID["472777"] = {
  --desc = "Gunk Splatter (Latch)";
  sound = 1;
  instance = 2805; 
};

--- ************************
--- * The Dreamrift (2939) *
--- ************************


GTFO.SpellID["1245919"] = {
  --desc = "Alndust Essence (Chimaerus)";
  sound = 1;
  instance = 2939;
  --encounter = 3306;
};


--- ****************************
--- * Nexus-Point Xenas (2915) *
--- ****************************

GTFO.SpellID["1277597"] = {
  --desc = "Radiant Scar";
  sound = 1;
  instance = 2915;
};


--- ************************
--- * The Voidspire (2912) *
--- ************************

GTFO.SpellID["1284786"] = {
  --desc = "Shadow Phalanx (Imperator Averzian)";
  sound = 1;
  instance = 2912;
  --encounter = 3306;
};

GTFO.SpellID["1280101"] = {
  --desc = "Void Breath (Vorasius)";
  sound = 1;
  instance = 2912; 
  --encounter = 3177;
};

GTFO.SpellID["1251213"] = {
  --desc = "Twilight Spikes (Fallen-King Salhadaar)";
  sound = 1;
  instance = 2912; 
  --encounter = 3179;
};

GTFO.SpellID["1245592"] = {
  --desc = "Torturous Extract (Fallen-King Salhadaar)";
  sound = 1;
  instance = 2912; 
  --encounter = 3179;
};

GTFO.SpellID["1260030"] = {
  --desc = "Umbral Beams (Fallen-King Salhadaar)";
  sound = 1;
  instance = 2912; 
  --encounter = 3179;
};

GTFO.SpellID["1244672"] = {
  --desc = "Nullzone (Vaelgor)";
  sound = 1;
  instance = 2912; 
  --encounter = 3178;
};

GTFO.SpellID["1245421"] = {
  --desc = "Gloomfield (Ezzorak)";
  sound = 1;
  instance = 2912; 
  --encounter = 3178;
};

GTFO.SpellID["1276982"] = {
  --desc = "Divine Consecration (General Amias Bellamy)";
  sound = 1;
  instance = 2912; 
  --encounter = 3180;
};

GTFO.SpellID["1246158"] = {
  --desc = "Consecration (General Amias Bellamy)";
  sound = 1;
  instance = 2912; 
  --encounter = 3180;
};

GTFO.SpellID["1272324"] = {
  --desc = "Divine Tempest (Commander Venel Lightblood)";
  sound = 1;
  instance = 2912; 
  --encounter = 3180;
};

GTFO.SpellID["1238206"] = {
  --desc = "Volatile Fissure (Alleria Windrunner)";
  sound = 1;
  instance = 2912; 
  --encounter = 3181;
};

GTFO.SpellID["1242553"] = {
  --desc = "Void Remnants (Alleria Windrunner)";
  sound = 1;
  instance = 2912; 
  --encounter = 3181;
};


--- ******************************
--- * March on Quel'Danas (2913) *
--- ******************************

GTFO.SpellID["1241840"] = {
  --desc = "Light Patch (Belo'ren)";
  sound = 1;
  instance = 2913; 
  --encounter = 3182;
};

GTFO.SpellID["1241841"] = {
  --desc = "Void Patch (Belo'ren)";
  sound = 1;
  instance = 2913; 
  --encounter = 3182;
};

GTFO.SpellID["1242803"] = {
  --desc = "Light Flames (Belo'ren)";
  sound = 1;
  instance = 2913; 
  --encounter = 3182;
};

GTFO.SpellID["1242815"] = {
  --desc = "Void Flames (Belo'ren)";
  sound = 1;
  instance = 2913; 
  --encounter = 3182;
};

GTFO.SpellID["1282470"] = {
  --desc = "Dark Quasar (L'ura)";
  sound = 1;
  instance = 2913; 
  --encounter = 3183;
};

--- *************
--- * Sporefall *
--- *************

GTFO.SpellID["1222306"] = {
  --desc = "Sporecloud (Mucky Sporeleader)";
  instance = 1592;
  sound = 1;
};

GTFO.SpellID["1222129"] = {
  --desc = "Writhing Vines (Rotmire)";
  sound = 1;
  instance = 1592; 
  --encounter = 3159;
};

--- *************************
--- * Altar of Fangs (2993) *
--- *************************

GTFO.SpellID["1306232"] = {
  --desc = "Septic Spatter (Venom Leech)";
  instance = 2993;
  sound = 1;
};

GTFO.SpellID["1306669"] = {
  --desc = "Toxic Breath (Twinfang Harrower)";
  instance = 2993;
  sound = 1;
};

GTFO.SpellID["1307573"] = {
  --desc = "Triple Shot (Rav'i)";
  --instance = 2993;
  --encounter = 3456;
  sound = 4;
  test = true; -- Unverified
};

GTFO.SpellID["1307531"] = {
  --desc = "Bloodletting (Bloodletter)";
  instance = 2993;
  sound = 1;
};

GTFO.SpellID["1309416"] = {
  --desc = "Virulent Twister (Ascendant Serpent)";
  instance = 2993;
  sound = 1;
};

GTFO.SpellID["1301231"] = {
  --desc = "Bloodletting (Zul'jan)";
  instance = 2993;
  encounter = 3458;
  sound = 1;
};

--- **************************
--- * Maisara Caverns (2874) *
--- **************************

GTFO.SpellID["1257782"] = {
  --desc = "Shredding Talons (Hexbound Eagle)";
  instance = 2874;
  sound = 1;
};

GTFO.SpellID["1243752"] = {
  --desc = "Icy Slick (Muro'jin)";
  instance = 2874;
  encounter = 3212;
  sound = 1;
};

GTFO.SpellID["1251833"] = {
  --desc = "Soulrot (Unstable Phantom)";
  instance = 2874;
  encounter = 3213;
  sound = 1;
};

GTFO.SpellID["1252130"] = {
  --desc = "Unmake (Vordaza)";
  instance = 2874;
  encounter = 3213;
  sound = 1;
};

GTFO.SpellID["1257898"] = {
  --desc = "Ancestral Crush (Restless Gnarldin)";
  instance = 2874;
  sound = 1;
};

GTFO.SpellID["1259777"] = {
  --desc = "Umbral Vortex (Rokh'zal)";
  instance = 2874;
  sound = 1;
};

GTFO.SpellID["1252816"] = {
  --desc = "Chill of Death (Soulbind Totem)";
  instance = 2874;
  encounter = 3214;
  sound = 1;
};

GTFO.SpellID["1253779"] = {
  --desc = "Spectral Decay (Rak'tul)";
  instance = 2874;
  encounter = 3214;
  sound = 1;
};

GTFO.SpellID["1254043"] = {
  --desc = "Eternal Suffering (Malignant Soul)";
  instance = 2874;
  encounter = 3214;
  sound = 2;
};

--- ***************************
--- * Tidebound Grotto (2987) *
--- ***************************

GTFO.SpellID["1257654"] = {
  --desc = "Lingering Frost (Nymrissa Wavecaller)";
  instance = 2987;
  encounter = 3379;
  sound = 1;
};

GTFO.SpellID["1265425"] = {
  --desc = "Wild Bite (Environment)";
  instance = 2987;
  sound = 1;
  stackSound = 1;
  applicationOnly = true;
};

GTFO.SpellID["1281341"] = {
  --desc = "Wild Bite (Environment)";
  instance = 2987;
  sound = 1;
  stackSound = 1;
  applicationOnly = true;
};

--[[
TODO: Not enough data to determine what debuff is applied to players hit by Water Jet.

GTFO.SpellID["??????"] = {
  --desc = "Water Jet (Nymrissa Wavecaller)";
  instance = 2987;
  encounter = 3379;
  sound = 1;
  tankSound = 0;
  stackSound = 1;
  tankStackSound = 0;
};
]]--

--- *****************************
--- * The Venomous Abyss (3004) *
--- *****************************

GTFO.SpellID["1297338"] = {
  --desc = "Deadly Venom";
  instance = 3004;
  sound = 1;
};

GTFO.SpellID["1285623"] = {
  --desc = "Soulcoil Well (Nek'zali the Soulcoiler)";
  instance = 3004;
  encounter = 3470;
  sound = 1;
};

GTFO.SpellID["1288554"] = {
  --desc = "Latent Cultist (Latent Cultist)";
  instance = 3004;
  encounter = 3470;
  sound = 1;
};

GTFO.SpellID["1300239"] = {
  --desc = "Swirling Spirit";
  instance = 3004;
  encounter = 3470;
  sound = 1;
  stackSound = 1;
};

GTFO.SpellID["1284210"] = {
  --desc = "Blood Venom (Blood of Ula'tek)";
  instance = 3004;
  encounter = 3445;
  sound = 1;
};

GTFO.SpellID["1291461"] = {
  --desc = "Virulent Fumes (Vashnik)";
  instance = 3004;
  sound = 1;
};

GTFO.SpellID["1310500"] = {
  --desc = "Aftershock (First Mate Nama)";
  instance = 3004;
  encounter = 3497;
  sound = 1;
};

GTFO.SpellID["1297650"] = {
  --desc = "Spreading Flames (Trader Gebbo)";
  instance = 3004;
  encounter = 3497;
  sound = 1;
};

GTFO.SpellID["1296667"] = {
  --desc = "Caustic Residue (Sszorak)";
  instance = 3004;
  encounter = 3420;
  sound = 1;
};

GTFO.SpellID["1309471"] = {
  --desc = "Noxious Slick (The Twin Fangs)";
  instance = 3004;
  encounter = 3421;
  sound = 1;
};

GTFO.SpellID["1292552"] = {
  --desc = "Congealed Gore (The Twin Fangs)";
  instance = 3004;
  encounter = 3421;
  sound = 1;
};

GTFO.SpellID["1292807"] = {
  --desc = "Stir the Depths (The Twin Fangs)";
  instance = 3004;
  encounter = 3421;
  sound = 1;
};

GTFO.SpellID["1283290"] = {
  --desc = "Noxious Ground (Zul'jan)";
  instance = 3004;
  encounter = 3429;
  sound = 1;
};

GTFO.SpellID["1298591"] = {
  --desc = "Defiled Ground (Zul'jan)";
  instance = 3004;
  encounter = 3429;
  sound = 1;
};

GTFO.SpellID["1306858"] = {
  --desc = "Warden's Protection (Doomscale Warden)";
  instance = 3004;
  encounter = 3492;
  sound = 1;
};

--- *********************
--- * Murder Row (2813) *
--- *********************

GTFO.SpellID["1253813"] = {
  --desc = "Fel Spray (Nibbles)";
  instance = 2813;
  encounter = 3101;
  sound = 1;
};

GTFO.SpellID["474234"] = {
  --desc = "Burning Steps (Xathuux the Annihilator)";
  instance = 2813;
  encounter = 3103;
  sound = 1;
};

GTFO.SpellID["1216590"] = {
  --desc = "Heartstop Poison (Zaen's Viper)";
  instance = 2813;
  applicationOnly = true;
  sound = 2;
  stackSound = 2;
};

GTFO.SpellID["1215985"] = {
  --desc = "Fel Beam (Defiled Golem)";
  instance = 2813;
  sound = 1;
};

GTFO.SpellID["1294870"] = {
  --desc = "Fel-Scarred Earth";
  instance = 2813;
  sound = 1;
};

GTFO.SpellID["1215200"] = {
  --desc = "Rain of Felfire (Corrupted Warlock)";
  instance = 2813;
  sound = 1;
};

GTFO.SpellID["1216955"] = {
  --desc = "Eye Beam (Felmaster Lucsei)";
  instance = 2813;
  sound = 1;
};

GTFO.SpellID["1216074"] = {
  --desc = "Spill Zone (Selenar Sunshy)";
  instance = 2813;
  sound = 2;
};

--- *************************
--- * Voidscar Arena (2923) *
--- *************************

GTFO.SpellID["1249712"] = {
	--desc = "Venomous Spit (Lost Sethrak)";
	instance = 2923;
	sound = 1;
};

GTFO.SpellID["1228126"] = {
	--desc = "Macestorm (Brutal Overseer)";
	instance = 2923;
	sound = 1;
};

GTFO.SpellID["1299210"] = {
	--desc = "Aftershock (Aegyra the Unyielding)";
	instance = 2923;
	sound = 1;
};

GTFO.SpellID["1296967"] = {
	--desc = "Void Fissure (Taz'Rah)";
	instance = 2923;
	sound = 1;
};

GTFO.SpellID["1222484"] = {
	--desc = "Poison Pool (Atroxus)";
	instance = 2923;
	encounter = 3286;
	sound = 1;
};

GTFO.SpellID["1282892"] = {
	--desc = "Sickening Bite (Toxic Creeper)";
	instance = 2923;
	encounter = 3286;
	sound = 1;
	stackSound = 3;
};

-- Note: Toxic Sludge is reused from TWW (Undermine area)

GTFO.SpellID["1264188"] = {
	--desc = "Unstable Singularity - Follower dungeon (Charonus)";
	instance = 2923;
	encounter = 3287;
	sound = 1;
	applicationOnly = true;
};

GTFO.SpellID["1248130"] = {
	--desc = "Unstable Singularity - Other versions (Charonus)";
	instance = 2923;
	encounter = 3287;
	sound = 1;
	applicationOnly = true;
};

--- ****************************
--- * The Blinding Vale (2859) *
--- ****************************

GTFO.SpellID["1237858"] = {
	--desc = "Ruptured Earth (Vivid Grovekeeper)";
	instance = 2859;
	sound = 1;
};

GTFO.SpellID["1314885"] = {
	--desc = "Hunting Leap (Thorny Saptor)";
	instance = 2859;
	sound = 1;
};

GTFO.SpellID["1234802"] = {
	--desc = "Fertile Loam (Meittik)";
	instance = 2859;
	encounter = 3199;
	sound = 1;
};

GTFO.SpellID["1235828"] = {
	--desc = "Light-Scorched Earth (Kezkitt)";
	instance = 2859;
	encounter = 3199;
	sound = 1;
};

GTFO.SpellID["1251345"] = {
	--desc = "Blight Resin (Spineshield Beetle)";
	instance = 2859;
	sound = 1;
};


GTFO.SpellID["1246751"] = {
	--desc = "Concentrated Lightbeam (Ziekket)";
	instance = 2859;
	encounter = 3202;
	sound = 1;
};

GTFO.SpellID["1246753"] = {
	--desc = "Lightsap (Ziekket)";
	instance = 2859;
	encounter = 3202;
	sound = 1;
};

--- **************************
--- * Den of Nalorakk (2825) *
--- **************************

GTFO.SpellID["1297701"] = {
	--desc = "Rotten Ground (Thornclaw Gatherer)";
	instance = 2825;
	sound = 1;
};

GTFO.SpellID["1252825"] = {
	--desc = "Harsh Winds";
	instance = 2825;
	sound = 1;
};

GTFO.SpellID["1235405"] = {
	--desc = "Bonespiked (The Hoardmonger)";
	instance = 2825;
	encounter = 3207;
	sound = 1;
};

GTFO.SpellID["1236289"] = {
	--desc = "Blizzard's Wrath (Sentinel of Winter)";
	instance = 2825;
	encounter = 3208;
	sound = 1;
};

GTFO.SpellID["1297749"] = {
  --desc = "Frozen Tempest (Sentinel of Winter)";
  instance = 2825;
  encounter = 3208;
  sound = 1;
};

GTFO.SpellID["1247367"] = {
  --desc = "Earthquake (Loa Speaker Nanea)";
  instance = 2825;
  sound = 1;
};


end

