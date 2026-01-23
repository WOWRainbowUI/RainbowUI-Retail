local MAJOR, MINOR = "EZBlizzardUiPopups_Data", 1
local EZBUP_DATA = LibStub:NewLibrary(MAJOR, MINOR)
if not EZBUP_DATA then
    -- A newer version is already loaded
    return
end

EZBUP_DATA.SoundFileIDBank = {
	[203314] = { soundQuotes = { 2416552, 2416540, 2416542, 2416543 } }, -- Baine Bloodhoof
	[177114] = { soundQuotes = { 1801002, 1801005, 1800995, 561301 } },
	[230055] = { soundQuotes = { 5725623, 5725624, 5725625, 5725634, 5725619, 5725620, 5725630 } },
	[49587]  = { soundQuotes = { 552227, 552221 } },
	[29611]  = { soundQuotes = { 563552, 563519, 563537, 563479 } },
	[191205] = { soundQuotes = { 1486698, 1486699, 1486701, 1486702, 1486703, 1486704 } },
	[229150] = { soundQuotes = { 1388284, 1388286, 1388282 } },
	[185157] = { soundQuotes = { 3597128, 3597129, 563239 } }, -- Uther
	[210670] = { soundQuotes = { 1055403, 1055404, 1055405, 1055406, 1055399, 1055400, 1055402 } },
	[212343] = { soundQuotes = { 1373762, 1373763, 1373756, 1373757, 1373758, 1373759 } },
	[241743] = { soundQuotes = { 4639084, 4639095, 4639096, 4639097, 4639090 } }, -- Archmage Khadgar
	[81822]  = { soundQuotes = { 546172, 546153, 546103, 546166 } },
	[250594] = { soundQuotes = { 634292, 634296, 634290, 634294 } }, -- Chen Stormstout
	[216069] = { soundQuotes = { 2468393, 2468394, 2468396, 2468397 } }, -- Malfurion Stormrage
	[129114] = { soundQuotes = { 552503, 552514, 1689235, 1689238, 1689239, 1689240, 1689241, 1699667 } }, -- Illidan Stormrage
	[36597]  = { soundQuotes = { 554123, 554181, 553997, 554089, 554172, 554085 } },
	[49590]  = { soundQuotes = { 557802, 557807, 557801, 557804, 557800, 557809, 557799, 557806, 557814 } },
	[229321] = { soundQuotes = { 5758117, 5758118, 5758119, 5758114, 5758115, 5758116, 2922115 } },
	[136683] = { soundQuotes = { 1860609, 1860611, 1860613, 1860622, 1860626 } }, -- Trade Prince Gallywix
	[216682] = { soundQuotes = { 5482269, 4288146, 4288143 } }, -- Shandris Feathermoon
	[216115] = { soundQuotes = { 1388445, 1388442, 1388449, 1388451 } }, -- Master Mathias Shaw
	[172181] = { soundQuotes = { 897314, 897322, 897324 } }, -- Gamon
	[200648] = { soundQuotes = { 2011278, 2011283, 2011276, 2011282 } }, -- Rexxar
	[229128] = { soundQuotes = { 1388604, 1388606, 1388608 } },
	[216168] = { soundQuotes = { 2012996, 2012998, 2012999, 2013000, 2013002, 5828671, 5828672, 2012993, 2012994 } },
	[107025] = { soundQuotes = { 1388273, 1388275, 1388276, 1388278 } }, -- Archdruid Hamuul Runetotem
	[156180] = { soundQuotes = { 2012223, 2012224, 2012212, 2012213, 2012214, 2012216, 2012217, 2012226 } },
	[118618] = { soundQuotes = { 1581925, 1581926, 1581927 } }, -- Kanrethad Ebonlocke
	[143425] = { soundQuotes = { 549620, 896000, 896028, 896036 } },
	[226656] = { soundQuotes = { 1388292, 1388295, 1388297, 1388298 } },
	[186182] = { soundQuotes = { 1388191, 1388193, 1388189, 1388196 } },
	[177216] = { soundQuotes = { 3620551, 3620554, 558296 } }, -- Kael'thas Sunstrider
	[164079] = { soundQuotes = { 3698917, 3698918, 3698920, 3698921, 3698922, 3698912, 3698913, 3698914 } },
	[223205] = { soundQuotes = { 4659345, 4659349, 4659346, 4659338 } },
	[230062] = { soundQuotes = { 5725989, 5725999, 5725985, 5725991, 5726000 } },
	[181056] = { soundQuotes = { 4659468, 4659471, 4659467 } },
	[181055] = { soundQuotes = { 4661200, 4661197, 4661198, 4661203 } },
	[206533] = { soundQuotes = { 5725530, 5725538, 5725546, 5725413 } },
	[250382] = { soundQuotes = { 1388723, 1388707, 1388710, 1388737 } }, -- Vereesa Windrunner
	[224220] = { soundQuotes = { 6023950 } },
	[235448] = { soundQuotes = { 6708204, 2530795 } },
	[215113] = { soundQuotes = { 5722457 } }, -- Orweyna
	[207471] = { soundQuotes = { 5722458 } }, -- Widow Arak'nai
}

EZBUP_DATA.CreaturexCameraID = {
	[1748] = { cameraID = 82, displayInfo = 5566, }, -- Highlord Bolvar Fordragon
	[4275] = { cameraID = 82, displayInfo = 2353, }, -- Archmage Arugal
	[11822] = { cameraID = 126, displayInfo = 11774, }, -- Moonglade Warden
	[16628] = { cameraID = 120, displayInfo = 16694, }, -- Auctioneer Caidori
	[17026] = { cameraID = 141, displayInfo = 21575, }, -- Grom Hellscream
	[18063] = { cameraID = 141, displayInfo = 17452, }, -- Garrosh
	[19935] = { cameraID = 120, displayInfo = 20222, }, -- Soridormi
	[20350] = { cameraID = 82, displayInfo = 19548, }, -- Kel'Thuzad
	[22522] = { cameraID = 141, displayInfo = 4527, }, -- Super Thrall
	[23159] = { cameraID = 268, displayInfo = 21345, }, -- Okuno
	[29611] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[32695] = { cameraID = 82, displayInfo = 28180, }, -- Donavan Bale
	[32697] = { cameraID = 141, displayInfo = 28181, }, -- Dak'hal the Black
	[32702] = { cameraID = 141, displayInfo = 28201, }, -- Drog Skullbreaker
	[32704] = { cameraID = 82, displayInfo = 28188, }, -- Danric the Bold
	[32706] = { cameraID = 120, displayInfo = 28189, }, -- Saedelin Whitedawn
	[32710] = { cameraID = 90, displayInfo = 28184, }, -- Garl Grimgrizzle
	[32714] = { cameraID = 109, displayInfo = 28190, }, -- Moon Priestess Nici
	[32717] = { cameraID = 130, displayInfo = 28193, }, -- Drool
	[35384] = { cameraID = 109, displayInfo = 29798, }, -- Disciple of Elune
	[38839] = { cameraID = 90, displayInfo = 7789, }, -- Dark Iron Guard
	[40920] = { cameraID = 120, displayInfo = 32199, }, -- Elendri Goldenbrow
	[42131] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[42783] = { cameraID = 90, displayInfo = 3524, }, -- Ironforge Guard
	[42928] = { cameraID = 90, displayInfo = 33140, }, -- Muradin Bronzebeard
	[45250] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[45774] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[46089] = { cameraID = 141, displayInfo = 34848, }, -- Rok'tar
	[46113] = { cameraID = 82, displayInfo = 34761, }, -- SI:7 Agent
	[49586] = { cameraID = 82, displayInfo = 37200, }, -- Guild Page
	[49587] = { cameraID = 82, displayInfo = 37198, }, -- Guild Herald
	[49588] = { cameraID = 141, displayInfo = 37199, }, -- Guild Page
	[49590] = { cameraID = 141, displayInfo = 37196, }, -- Guild Herald
	[51346] = { cameraID = 141, displayInfo = 37328, }, -- Orgrimmar Wind Rider
	[51468] = { cameraID = 90, displayInfo = 35028, }, -- Wildhammer Guard
	[55561] = { cameraID = 82, displayInfo = 31427, }, -- King Varian Wrynn
	[60149] = { cameraID = 141, displayInfo = 41490, }, -- General Nazgrim
	[60828] = { cameraID = 82, displayInfo = 41605, }, -- Admiral Taylor
	[60861] = { cameraID = 90, displayInfo = 38872, }, -- Sully "The Pickle" McLeary
	[61079] = { cameraID = 82, displayInfo = 41826, }, -- Player Clone (TEMP)
	[61682] = { cameraID = 141, displayInfo = 42562, }, -- General Nazgrim
	[61845] = { cameraID = 141, displayInfo = 32575, }, -- Hellscream's Vanguard
	[61846] = { cameraID = 141, displayInfo = 39047, }, -- Gorrok
	[62634] = { cameraID = 82, displayInfo = 42583, }, -- Alliance Crewman
	[62635] = { cameraID = 82, displayInfo = 42584, }, -- Alliance Captain
	[63194] = { cameraID = 82, displayInfo = 4438, }, -- Steven Lisbane
	[63381] = { cameraID = 144, displayInfo = 39698, }, -- Chen Stormstout
	[63394] = { cameraID = 126, displayInfo = 40006, }, -- Sunwalker Dezco
	[63395] = { cameraID = 109, displayInfo = 40263, }, -- Lyalia
	[63398] = { cameraID = 126, displayInfo = 40045, }, -- Thunder Cleft Brave
	[63399] = { cameraID = 109, displayInfo = 40282, }, -- Incursion Sentinel
	[63413] = { cameraID = 141, displayInfo = 42994, }, -- Orc 01
	[63414] = { cameraID = 141, displayInfo = 42995, }, -- Orc 02
	[63415] = { cameraID = 141, displayInfo = 42996, }, -- Orc 03
	[63417] = { cameraID = 141, displayInfo = 42998, }, -- Orc 04
	[63426] = { cameraID = 82, displayInfo = 43002, }, -- Human 01
	[63427] = { cameraID = 82, displayInfo = 43005, }, -- Human 02
	[63428] = { cameraID = 82, displayInfo = 43006, }, -- Human 03
	[63434] = { cameraID = 126, displayInfo = 43012, }, -- Tauren 01
	[63436] = { cameraID = 126, displayInfo = 43014, }, -- Tauren 02
	[63437] = { cameraID = 126, displayInfo = 43015, }, -- Tauren 03
	[63438] = { cameraID = 126, displayInfo = 43016, }, -- Tauren 04
	[63459] = { cameraID = 120, displayInfo = 43035, }, -- BloodElf Female 04
	[63460] = { cameraID = 120, displayInfo = 43038, }, -- BloodElf Female 05
	[63461] = { cameraID = 120, displayInfo = 43041, }, -- BloodElf Female 06
	[63462] = { cameraID = 120, displayInfo = 43042, }, -- BloodElf Female 07
	[63463] = { cameraID = 109, displayInfo = 43043, }, -- NightElf Female 08
	[64566] = { cameraID = 126, displayInfo = 40006, }, -- Sunwalker Dezco
	[64653] = { cameraID = 126, displayInfo = 43611, }, -- Tauren
	[64655] = { cameraID = 120, displayInfo = 43613, }, -- High Elf
	[64868] = { cameraID = 141, displayInfo = 14360, }, -- Kor'kron Dubs
	[64872] = { cameraID = 130, displayInfo = 45503, }, -- Sky Marshal Schwind
	[64874] = { cameraID = 130, displayInfo = 45501, }, -- Cannoneer Buczacki
	[65648] = { cameraID = 82, displayInfo = 44495, }, -- Old MacDonald
	[65656] = { cameraID = 82, displayInfo = 44500, }, -- Bill Buckler
	[66300] = { cameraID = 82, displayInfo = 44977, }, -- Skyfire Marine
	[66412] = { cameraID = 109, displayInfo = 45078, }, -- Elena Flutterfly
	[66460] = { cameraID = 82, displayInfo = 45156, }, -- Skyfire Gyrocopter Pilot
	[66478] = { cameraID = 130, displayInfo = 45186, }, -- David Kosse
	[66515] = { cameraID = 90, displayInfo = 45211, }, -- Kortas Darkhammer
	[66518] = { cameraID = 120, displayInfo = 45223, }, -- Everessa
	[66520] = { cameraID = 90, displayInfo = 45224, }, -- Durin Darkhammer
	[66552] = { cameraID = 141, displayInfo = 45232, }, -- Narrok
	[66553] = { cameraID = 268, displayInfo = 21344, }, -- Morulu The Elder
	[66636] = { cameraID = 130, displayInfo = 45260, }, -- Nearly Headless Jacob
	[66638] = { cameraID = 141, displayInfo = 45261, }, -- Okrut Dragonwaste
	[66641] = { cameraID = 82, displayInfo = 44977, }, -- Skyfire Marine
	[66656] = { cameraID = 141, displayInfo = 42562, }, -- General Nazgrim
	[66675] = { cameraID = 82, displayInfo = 45283, }, -- Major Payne
	[66796] = { cameraID = 82, displayInfo = 45057, }, -- Captain Doren
	[66815] = { cameraID = 90, displayInfo = 45375, }, -- Bordin Steadyfist
	[66819] = { cameraID = 126, displayInfo = 45379, }, -- Brok
	[66822] = { cameraID = 141, displayInfo = 45380, }, -- Goz Banefury
	[66913] = { cameraID = 82, displayInfo = 34004, }, -- Stormwind to Pandatia - Alliance intro Scene - CLIENT-SIDE - JSB
	[66915] = { cameraID = 141, displayInfo = 14360, }, -- Kor'kron Elite
	[66919] = { cameraID = 90, displayInfo = 38872, }, -- Sully "The Pickle" McLeary
	[67011] = { cameraID = 141, displayInfo = 45548, }, -- Garrosh'ar Grunt
	[67304] = { cameraID = 82, displayInfo = 46148, }, -- Shieldwall Footman
	[67334] = { cameraID = 141, displayInfo = 47197, }, -- Bloodhilt Honor Guard
	[67370] = { cameraID = 82, displayInfo = 46188, }, -- Jeremy Feasel
	[67461] = { cameraID = 141, displayInfo = 46247, }, -- Warlord Bloodhilt
	[67560] = { cameraID = 82, displayInfo = 47029, }, -- King Varian Wrynn
	[67765] = { cameraID = 82, displayInfo = 45156, }, -- Skyfire Gyrocopter Pilot
	[67801] = { cameraID = 90, displayInfo = 46911, }, -- High Marshal Twinbraid
	[68019] = { cameraID = 82, displayInfo = 46573, }, -- Kanrethad Ebonlocke
	[68098] = { cameraID = 268, displayInfo = 20422, }, -- Ashtongue Worker
	[68287] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[68305] = { cameraID = 126, displayInfo = 46739, }, -- Smash Hoofstomp
	[68474] = { cameraID = 141, displayInfo = 46813, }, -- Commander Scargash
	[68477] = { cameraID = 141, displayInfo = 46373, }, -- Kor'kron Sentry
	[68612] = { cameraID = 109, displayInfo = 47045, }, -- Skyglaive Sentinel
	[68690] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[68880] = { cameraID = 141, displayInfo = 46759, }, -- Kor'kron Slayer
	[68925] = { cameraID = 82, displayInfo = 47044, }, -- Young Varian Wrynn
	[69025] = { cameraID = 141, displayInfo = 46813, }, -- Commander Scargash
	[69045] = { cameraID = 141, displayInfo = 17452, }, -- Garrosh
	[70733] = { cameraID = 82, displayInfo = 48286, }, -- Tyson Sanders
	[70739] = { cameraID = 82, displayInfo = 48298, }, -- Doctor FIST
	[70879] = { cameraID = 141, displayInfo = 52019, }, -- Frostwolf Greyfur
	[70909] = { cameraID = 141, displayInfo = 49191, }, -- Ga'nar
	[70968] = { cameraID = 141, displayInfo = 14360, }, -- Kor'kron Warmonger
	[70986] = { cameraID = 141, displayInfo = 48518, }, -- Kor'kron Lieutenant
	[71008] = { cameraID = 141, displayInfo = 48537, }, -- Kor'kron Paratrooper
	[71113] = { cameraID = 141, displayInfo = 48611, }, -- Kor'kron Deadeye
	[71114] = { cameraID = 141, displayInfo = 48612, }, -- Kor'kron Visionary
	[71150] = { cameraID = 144, displayInfo = 39698, }, -- Chen Stormstout
	[71288] = { cameraID = 141, displayInfo = 48736, }, -- Kor'kron Augur
	[71345] = { cameraID = 144, displayInfo = 39698, }, -- Chen Stormstout
	[71510] = { cameraID = 141, displayInfo = 49107, }, -- Vragor
	[71669] = { cameraID = 141, displayInfo = 53072, }, -- Kur'ak the Binder
	[71794] = { cameraID = 82, displayInfo = 15093, }, -- Crafty the Clever
	[71865] = { cameraID = 86, displayInfo = 49585, }, -- Garrosh Hellscream
	[71879] = { cameraID = 141, displayInfo = 48480, }, -- Frostwolf Exile
	[71934] = { cameraID = 130, displayInfo = 47835, }, -- Dr. Ion Goldbloom
	[72240] = { cameraID = 141, displayInfo = 49100, }, -- Thunderlord Crag-Leaper
	[72316] = { cameraID = 82, displayInfo = 49609, }, -- Scout Igor Corti
	[72395] = { cameraID = 141, displayInfo = 50500, }, -- Iron Horde Bruiser
	[72397] = { cameraID = 141, displayInfo = 50229, }, -- Iron Horde Ragemonger
	[72546] = { cameraID = 141, displayInfo = 49049, }, -- Kor'kron Grunt
	[72623] = { cameraID = 109, displayInfo = 50541, }, -- Delas Moonfang
	[72774] = { cameraID = 82, displayInfo = 15093, }, -- Crafty the Vendor
	[72813] = { cameraID = 815, displayInfo = 59712, }, -- Image of Cho'gall
	[72837] = { cameraID = 141, displayInfo = 54104, }, -- Farseer Urquan
	[72874] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[72964] = { cameraID = 141, displayInfo = 51010, }, -- Goro'dan
	[72976] = { cameraID = 141, displayInfo = 49105, }, -- Outrider Urukag
	[72981] = { cameraID = 141, displayInfo = 51016, }, -- Aggron
	[73039] = { cameraID = 141, displayInfo = 54120, }, -- Throm'var Hunter
	[73098] = { cameraID = 141, displayInfo = 51078, }, -- Kor'kron Overseer
	[73225] = { cameraID = 141, displayInfo = 53593, }, -- Throm'var Villager
	[73324] = { cameraID = 109, displayInfo = 23850, }, -- Starfall Sentinel
	[73393] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[73480] = { cameraID = 82, displayInfo = 58813, }, -- Image of Archmage Khadgar
	[73592] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[73603] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[73678] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[73744] = { cameraID = 141, displayInfo = 51517, }, -- Skal the Trapper
	[73774] = { cameraID = 141, displayInfo = 50229, }, -- Warsong Ragemonger
	[73833] = { cameraID = 815, displayInfo = 59707, }, -- Cho'gall
	[73839] = { cameraID = 141, displayInfo = 56251, }, -- Commander Vorka
	[73876] = { cameraID = 141, displayInfo = 50369, }, -- Shadowmoon Shaman
	[73897] = { cameraID = 141, displayInfo = 52019, }, -- Frostwolf Shaman
	[73906] = { cameraID = 141, displayInfo = 51197, }, -- Shadowmoon Swiftclaw
	[73907] = { cameraID = 141, displayInfo = 50369, }, -- Shadowmoon Stormcaller
	[73979] = { cameraID = 141, displayInfo = 50356, }, -- Shadowmoon Voidreaver
	[73980] = { cameraID = 141, displayInfo = 51197, }, -- Shadowmoon Voidclaw
	[73981] = { cameraID = 141, displayInfo = 54894, }, -- Shadowmoon Voidaxe
	[74015] = { cameraID = 141, displayInfo = 51347, }, -- Commander Krog
	[74016] = { cameraID = 141, displayInfo = 51338, }, -- Gar Steelcrush
	[74018] = { cameraID = 141, displayInfo = 51349, }, -- Mokrik Blackfingers
	[74023] = { cameraID = 141, displayInfo = 51612, }, -- Commander Vorka
	[74029] = { cameraID = 141, displayInfo = 51639, }, -- Blackrock Warrior
	[74059] = { cameraID = 141, displayInfo = 51639, }, -- Blackrock Warrior
	[74122] = { cameraID = 141, displayInfo = 51767, }, -- Iron Grunt
	[74130] = { cameraID = 141, displayInfo = 51790, }, -- Garrosh
	[74197] = { cameraID = 141, displayInfo = 51821, }, -- Thunderlord Captive
	[74199] = { cameraID = 141, displayInfo = 51824, }, -- Kal'gor the Honorable
	[74253] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[74332] = { cameraID = 141, displayInfo = 51767, }, -- Iron Horde Grunt
	[74421] = { cameraID = 141, displayInfo = 61222, }, -- Frostwolf Rider
	[74426] = { cameraID = 141, displayInfo = 51999, }, -- Frostwolf Farseer
	[74611] = { cameraID = 141, displayInfo = 52201, }, -- Limbflayer
	[74715] = { cameraID = 141, displayInfo = 51612, }, -- Commander Vorka
	[74738] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[74807] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Stalker
	[74870] = { cameraID = 141, displayInfo = 52703, }, -- Frostwolf Warrior
	[74871] = { cameraID = 141, displayInfo = 51825, }, -- Thunderlord Warrior
	[74906] = { cameraID = 141, displayInfo = 51768, }, -- Iron Horde Shieldbearer
	[74925] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Warrior - Male Only
	[74954] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[74956] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Handler
	[75089] = { cameraID = 141, displayInfo = 51768, }, -- Grom'kar Shieldbearer
	[75091] = { cameraID = 141, displayInfo = 51767, }, -- Grom'kar Grunt
	[75121] = { cameraID = 120, displayInfo = 52434, }, -- Lady Liadrin
	[75136] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[75143] = { cameraID = 90, displayInfo = 52528, }, -- Hansel Heavyhands
	[75220] = { cameraID = 141, displayInfo = 52556, }, -- Possible Survivor
	[75269] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Rider
	[75326] = { cameraID = 141, displayInfo = 53674, }, -- Iron Front Commander
	[75328] = { cameraID = 141, displayInfo = 51767, }, -- Iron Shocktrooper
	[75330] = { cameraID = 141, displayInfo = 53669, }, -- Battlefield Grunt
	[75343] = { cameraID = 141, displayInfo = 52490, }, -- Kal'gor the Honorable
	[75345] = { cameraID = 141, displayInfo = 52557, }, -- Gol'kosh the Axe
	[75412] = { cameraID = 141, displayInfo = 52703, }, -- Frostwolf Peon
	[75502] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[75581] = { cameraID = 141, displayInfo = 51768, }, -- Iron Defender
	[75595] = { cameraID = 141, displayInfo = 52823, }, -- Prototype Engineer
	[75632] = { cameraID = 141, displayInfo = 52847, }, -- Iron Scarhide
	[75665] = { cameraID = 141, displayInfo = 52878, }, -- Chief Engineer Graktar
	[75707] = { cameraID = 141, displayInfo = 51767, }, -- Iron Horde Grunt
	[75720] = { cameraID = 141, displayInfo = 49332, }, -- Iron Crag-Leaper
	[75729] = { cameraID = 141, displayInfo = 52978, }, -- Restless Wanderer
	[75745] = { cameraID = 141, displayInfo = 56386, }, -- Warsong Overseer
	[75749] = { cameraID = 141, displayInfo = 51767, }, -- Grom'kar Deadeye
	[75750] = { cameraID = 141, displayInfo = 50959, }, -- Iron Darkcaster
	[75794] = { cameraID = 141, displayInfo = 53587, }, -- Burning Blademaster
	[75943] = { cameraID = 141, displayInfo = 59782, }, -- Grom'kar Deadeye
	[75945] = { cameraID = 141, displayInfo = 59787, }, -- Burning Blademaster
	[76045] = { cameraID = 141, displayInfo = 58351, }, -- Image of Teron'gor
	[76048] = { cameraID = 141, displayInfo = 51767, }, -- Slain Iron Grunt
	[76402] = { cameraID = 141, displayInfo = 51767, }, -- Iron Horde Grunt
	[76411] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[76549] = { cameraID = 141, displayInfo = 51998, }, -- Iron Grunt
	[76570] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[76571] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Field Medic
	[76584] = { cameraID = 141, displayInfo = 53288, }, -- Freed Frostwolf Slave
	[76606] = { cameraID = 141, displayInfo = 51767, }, -- Iron Horde Scout
	[76627] = { cameraID = 141, displayInfo = 51768, }, -- [UNUSED] Iron Warder
	[76630] = { cameraID = 141, displayInfo = 53569, }, -- Malgrim Stormhand
	[76719] = { cameraID = 141, displayInfo = 53380, }, -- Bonechewer Cannibal
	[76724] = { cameraID = 141, displayInfo = 51824, }, -- Kal'gor the Honorable
	[76730] = { cameraID = 141, displayInfo = 50704, }, -- Makar Stonebinder
	[76731] = { cameraID = 141, displayInfo = 49772, }, -- Karg Bloodfury
	[76771] = { cameraID = 141, displayInfo = 53438, }, -- Teron'gor
	[76772] = { cameraID = 141, displayInfo = 53954, }, -- Hurkan Skullsplinter
	[76924] = { cameraID = 141, displayInfo = 52910, }, -- Orgrim Doomhammer
	[76928] = { cameraID = 141, displayInfo = 53538, }, -- Kraank
	[76981] = { cameraID = 141, displayInfo = 53613, }, -- Blademaster Bralok
	[77047] = { cameraID = 141, displayInfo = 56371, }, -- Fireblade Invoker
	[77175] = { cameraID = 141, displayInfo = 51768, }, -- Overlord Blackhammer
	[77217] = { cameraID = 90, displayInfo = 47081, }, -- Jr. Surveyor Dorn
	[77257] = { cameraID = 141, displayInfo = 61159, }, -- Orgrim Doomhammer
	[77321] = { cameraID = 141, displayInfo = 52490, }, -- Kal'gor the Honorable
	[77388] = { cameraID = 141, displayInfo = 58352, }, -- Teron'gor
	[77501] = { cameraID = 120, displayInfo = 53926, }, -- Riasa Songbrook
	[77734] = { cameraID = 141, displayInfo = 54036, }, -- Teron'gor
	[77853] = { cameraID = 82, displayInfo = 19078, }, -- Image of Archmage Vargoth
	[77889] = { cameraID = 141, displayInfo = 54165, }, -- Grom'tash the Destructor
	[77915] = { cameraID = 141, displayInfo = 54180, }, -- Throm'var Villager
	[78009] = { cameraID = 141, displayInfo = 54150, }, -- Orc Male
	[78012] = { cameraID = 82, displayInfo = 53652, }, -- Human Male
	[78140] = { cameraID = 141, displayInfo = 54327, }, -- Iron Cavalry
	[78187] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[78223] = { cameraID = 141, displayInfo = 52026, }, -- Iron Berserker
	[78226] = { cameraID = 141, displayInfo = 52099, }, -- Iron Gladiator
	[78384] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[78423] = { cameraID = 82, displayInfo = 61871, }, -- Archmage Khadgar
	[78425] = { cameraID = 141, displayInfo = 18670, }, -- Warlord Dar'toon
	[78426] = { cameraID = 82, displayInfo = 16386, }, -- Watch Commander Relthorn Netherwane
	[78438] = { cameraID = 82, displayInfo = 32386, }, -- Alliance Portal-Sentry
	[78439] = { cameraID = 141, displayInfo = 32770, }, -- Horde Portal-Sentry
	[78467] = { cameraID = 141, displayInfo = 59253, }, -- Frostwall Peon
	[78502] = { cameraID = 130, displayInfo = 30823, }, -- Calder Gray
	[78507] = { cameraID = 141, displayInfo = 56742, }, -- Bleeding Hollow Savage
	[78555] = { cameraID = 90, displayInfo = 54258, }, -- Owynn Graddock
	[78556] = { cameraID = 141, displayInfo = 36185, }, -- Ariok
	[78568] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[78638] = { cameraID = 82, displayInfo = 19078, }, -- Image of Archmage Vargoth
	[78649] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[78667] = { cameraID = 141, displayInfo = 54639, }, -- Ironmarch Legionnaire
	[78670] = { cameraID = 141, displayInfo = 54646, }, -- Ironmarch Warcaster
	[78696] = { cameraID = 141, displayInfo = 54659, }, -- Ironmarch Champion
	[78775] = { cameraID = 141, displayInfo = 53689, }, -- Ironmarch Commander Tharbek
	[78883] = { cameraID = 141, displayInfo = 59613, }, -- Iron Grunt
	[78905] = { cameraID = 141, displayInfo = 54575, }, -- Battered Frostwolf Prisoner
	[78996] = { cameraID = 141, displayInfo = 54814, }, -- Farseer Drek'Thar
	[79056] = { cameraID = 130, displayInfo = 36497, }, -- Deathguard Darnell
	[79057] = { cameraID = 126, displayInfo = 56553, }, -- Pao'ka Swiftmountain
	[79060] = { cameraID = 90, displayInfo = 54863, }, -- Joren Ironstock
	[79062] = { cameraID = 82, displayInfo = 56548, }, -- Arnold Croman
	[79068] = { cameraID = 141, displayInfo = 54869, }, -- Iron Grunt
	[79140] = { cameraID = 82, displayInfo = 54891, }, -- Sergeant Mollins
	[79176] = { cameraID = 141, displayInfo = 54916, }, -- Foreman Grobash
	[79230] = { cameraID = 141, displayInfo = 54968, }, -- Gronnstalker Rokash
	[79265] = { cameraID = 141, displayInfo = 54373, }, -- Mulverick
	[79301] = { cameraID = 141, displayInfo = 59253, }, -- Horde Peon
	[79315] = { cameraID = 126, displayInfo = 55046, }, -- Olin Umberhide
	[79361] = { cameraID = 130, displayInfo = 47835, }, -- Undead Male
	[79366] = { cameraID = 109, displayInfo = 47075, }, -- Night Elf Female
	[79368] = { cameraID = 90, displayInfo = 48200, }, -- Dwarf Male
	[79370] = { cameraID = 105, displayInfo = 37446, }, -- Worgen Female
	[79371] = { cameraID = 126, displayInfo = 45379, }, -- Tauren Male
	[79376] = { cameraID = 120, displayInfo = 47508, }, -- Blood Elf Female
	[79437] = { cameraID = 141, displayInfo = 52556, }, -- Laughing Skull Orc
	[79534] = { cameraID = 141, displayInfo = 54304, }, -- Iron Grunt
	[79557] = { cameraID = 141, displayInfo = 51767, }, -- Iron Reinforcements
	[79578] = { cameraID = 141, displayInfo = 55369, }, -- Warsong Outrider
	[79599] = { cameraID = 126, displayInfo = 55046, }, -- Olin Umberhide
	[79611] = { cameraID = 109, displayInfo = 55047, }, -- Qiana Moonshadow
	[79631] = { cameraID = 141, displayInfo = 59201, }, -- Iron Shieldbearer
	[79632] = { cameraID = 141, displayInfo = 59200, }, -- Grom'kar Grunt
	[79633] = { cameraID = 141, displayInfo = 51767, }, -- Iron Boltblaster
	[79657] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[79674] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[79695] = { cameraID = 90, displayInfo = 57384, }, -- Borin Brewbelly
	[79731] = { cameraID = 141, displayInfo = 54304, }, -- Iron Grunt
	[79838] = { cameraID = 82, displayInfo = 1357, }, -- Baros Alexston
	[79896] = { cameraID = 141, displayInfo = 57352, }, -- Mokugg Lagerpounder
	[79917] = { cameraID = 141, displayInfo = 55736, }, -- Ga'nar
	[79922] = { cameraID = 141, displayInfo = 55406, }, -- Force Commander Bal'Gor
	[79954] = { cameraID = 90, displayInfo = 52528, }, -- Hansel Heavyhands
	[80061] = { cameraID = 141, displayInfo = 55492, }, -- Blackrock Peon
	[80140] = { cameraID = 141, displayInfo = 55530, }, -- Foreman Thazz'ril
	[80222] = { cameraID = 130, displayInfo = 43247, }, -- Mr. Pleeb
	[80229] = { cameraID = 141, displayInfo = 54952, }, -- Morketh Bladehowl
	[80290] = { cameraID = 141, displayInfo = 54575, }, -- Dying Prisoner
	[80303] = { cameraID = 141, displayInfo = 55641, }, -- Grom'kar Peon
	[80310] = { cameraID = 141, displayInfo = 55217, }, -- Frostwall Peon
	[80313] = { cameraID = 141, displayInfo = 55641, }, -- Peon
	[80402] = { cameraID = 141, displayInfo = 51998, }, -- Blackrock Grunt
	[80590] = { cameraID = 141, displayInfo = 61553, }, -- Aknor Steelbringer
	[80783] = { cameraID = 141, displayInfo = 54575, }, -- Liberated Frostwolf Prisoner
	[80803] = { cameraID = 141, displayInfo = 54575, }, -- Liberated Frostwolf Prisoner
	[80856] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[81014] = { cameraID = 141, displayInfo = 56413, }, -- Iron Grunt
	[81016] = { cameraID = 141, displayInfo = 58666, }, -- Liberated Frostwolf Prisoner
	[81042] = { cameraID = 82, displayInfo = 61582, }, -- Croman
	[81073] = { cameraID = 141, displayInfo = 54952, }, -- Morketh Bladehowl
	[81091] = { cameraID = 141, displayInfo = 54894, }, -- Shadowmoon Voidaxe
	[81202] = { cameraID = 141, displayInfo = 56278, }, -- Bony Xuk
	[81213] = { cameraID = 141, displayInfo = 57984, }, -- Corporal Thukmar
	[81372] = { cameraID = 141, displayInfo = 52202, }, -- Bruto
	[81428] = { cameraID = 82, displayInfo = 53840, }, -- Fort Wrynn Footman
	[81429] = { cameraID = 90, displayInfo = 53107, }, -- Fort Wrynn Rifleman
	[81437] = { cameraID = 109, displayInfo = 56185, }, -- Fort Wrynn Magus
	[81445] = { cameraID = 141, displayInfo = 56481, }, -- Drak'thiz
	[81446] = { cameraID = 126, displayInfo = 56482, }, -- Beran Grovetender
	[81450] = { cameraID = 130, displayInfo = 56513, }, -- Baron Deathshot
	[81451] = { cameraID = 120, displayInfo = 56514, }, -- Vala Kaliraan
	[81460] = { cameraID = 120, displayInfo = 28189, }, -- Selen Brightblade
	[81461] = { cameraID = 126, displayInfo = 46389, }, -- Bo Farplain
	[81468] = { cameraID = 82, displayInfo = 53840, }, -- Fort Wrynn Footman
	[81475] = { cameraID = 130, displayInfo = 57077, }, -- Matthew Younglove
	[81478] = { cameraID = 141, displayInfo = 57286, }, -- Garag Earthtongue
	[81482] = { cameraID = 120, displayInfo = 57342, }, -- Vera Voidheart
	[81483] = { cameraID = 141, displayInfo = 30008, }, -- Uruk the Black
	[81484] = { cameraID = 120, displayInfo = 18159, }, -- Calla Ebonlight
	[81485] = { cameraID = 126, displayInfo = 19022, }, -- Usha Plainstrider
	[81565] = { cameraID = 141, displayInfo = 54276, }, -- Thunderlord Windreader
	[81569] = { cameraID = 109, displayInfo = 56438, }, -- Daleera Moonfang
	[81672] = { cameraID = 109, displayInfo = 55047, }, -- Qiana Moonshadow
	[81695] = { cameraID = 815, displayInfo = 59707, }, -- Cho'gall
	[81696] = { cameraID = 141, displayInfo = 53438, }, -- Teron'gor
	[81699] = { cameraID = 141, displayInfo = 52910, }, -- Orgrim Doomhammer
	[81895] = { cameraID = 141, displayInfo = 56720, }, -- Bleeding Hollow Bloodchosen
	[81923] = { cameraID = 141, displayInfo = 56731, }, -- Iron Grunt
	[81990] = { cameraID = 82, displayInfo = 56772, }, -- Moriccalas
	[81996] = { cameraID = 105, displayInfo = 56782, }, -- Turkina
	[81997] = { cameraID = 82, displayInfo = 56785, }, -- Roague
	[81998] = { cameraID = 82, displayInfo = 56787, }, -- Anruin
	[82005] = { cameraID = 120, displayInfo = 56771, }, -- Challe Tebrilinde
	[82006] = { cameraID = 126, displayInfo = 56773, }, -- Pazo Stonehoof
	[82007] = { cameraID = 141, displayInfo = 56777, }, -- Tore
	[82010] = { cameraID = 141, displayInfo = 56783, }, -- Bonesaw
	[82011] = { cameraID = 130, displayInfo = 56784, }, -- Northpaul
	[82013] = { cameraID = 126, displayInfo = 56792, }, -- Plainsmender Darragh
	[82015] = { cameraID = 126, displayInfo = 56798, }, -- Moonalli
	[82016] = { cameraID = 126, displayInfo = 56799, }, -- Durphorn the Bullheaded
	[82017] = { cameraID = 120, displayInfo = 56800, }, -- Miserain Starsorrow
	[82025] = { cameraID = 109, displayInfo = 56776, }, -- Yoori
	[82075] = { cameraID = 120, displayInfo = 56826, }, -- Ryii the Shameless
	[82187] = { cameraID = 126, displayInfo = 56879, }, -- Etubrute
	[82188] = { cameraID = 141, displayInfo = 56880, }, -- Mumper
	[82191] = { cameraID = 130, displayInfo = 56883, }, -- High Warlord Shoju
	[82259] = { cameraID = 141, displayInfo = 56925, }, -- Thrend
	[82260] = { cameraID = 120, displayInfo = 56926, }, -- Rainiara the Kingslayer
	[82263] = { cameraID = 82, displayInfo = 56928, }, -- Agios Lumen
	[82364] = { cameraID = 90, displayInfo = 47399, }, -- Ritual Stalker
	[82413] = { cameraID = 141, displayInfo = 54296, }, -- Shadowmoon Reaver
	[82419] = { cameraID = 141, displayInfo = 57377, }, -- Darkun
	[82481] = { cameraID = 105, displayInfo = 34450, }, -- Fiona
	[82482] = { cameraID = 90, displayInfo = 34644, }, -- Gidwin Goldbraids
	[82490] = { cameraID = 82, displayInfo = 57037, }, -- Matthew Younglove
	[82577] = { cameraID = 109, displayInfo = 57119, }, -- Nihil Tel'alara
	[82630] = { cameraID = 109, displayInfo = 57155, }, -- Sylalleas Frostwind
	[82633] = { cameraID = 141, displayInfo = 57158, }, -- Theo'drosh Blindseyed
	[82641] = { cameraID = 90, displayInfo = 57161, }, -- Olren Sternbeard
	[82642] = { cameraID = 130, displayInfo = 57162, }, -- Grinfel Frostfinger
	[82653] = { cameraID = 120, displayInfo = 57172, }, -- Artemisia Azuregaze
	[82659] = { cameraID = 105, displayInfo = 57175, }, -- Sylva Darkhowl
	[82666] = { cameraID = 109, displayInfo = 57180, }, -- Rin Starsong
	[82674] = { cameraID = 109, displayInfo = 57186, }, -- Nuria Thornstorm
	[82679] = { cameraID = 126, displayInfo = 57191, }, -- Magrum Mistrunner
	[82693] = { cameraID = 126, displayInfo = 57195, }, -- Rizei Stormhoof
	[82696] = { cameraID = 120, displayInfo = 57199, }, -- Vella A'nar
	[82717] = { cameraID = 82, displayInfo = 57211, }, -- Soulare of Andorhal
	[82734] = { cameraID = 815, displayInfo = 59276, }, -- Cho'gall
	[82747] = { cameraID = 120, displayInfo = 57238, }, -- Seleria Dawncaller
	[82752] = { cameraID = 82, displayInfo = 57243, }, -- Joachim Demonsbane
	[82756] = { cameraID = 82, displayInfo = 57227, }, -- Leeroy Jenkins
	[82763] = { cameraID = 141, displayInfo = 57252, }, -- Lazrek
	[82787] = { cameraID = 82, displayInfo = 57271, }, -- Mirran Lichbane
	[82796] = { cameraID = 120, displayInfo = 57277, }, -- Arachni Bloodseeker
	[82808] = { cameraID = 90, displayInfo = 57284, }, -- Dramnur Doombrow
	[82810] = { cameraID = 90, displayInfo = 57285, }, -- Grum Boarsbane
	[82824] = { cameraID = 109, displayInfo = 57294, }, -- Denalea Meadowglaive
	[82859] = { cameraID = 130, displayInfo = 57335, }, -- Lamontague Ford
	[82863] = { cameraID = 82, displayInfo = 57338, }, -- Lamontague Ford
	[82869] = { cameraID = 109, displayInfo = 57345, }, -- Illenya
	[82907] = { cameraID = 90, displayInfo = 57378, }, -- Drammand Darkbrow
	[82956] = { cameraID = 109, displayInfo = 57418, }, -- Raevyn Sorrowblade
	[82961] = { cameraID = 130, displayInfo = 57421, }, -- Olaf Blightbearer
	[82965] = { cameraID = 82, displayInfo = 57424, }, -- Peter Toulios
	[82977] = { cameraID = 105, displayInfo = 57429, }, -- Sarah Schnau
	[82978] = { cameraID = 126, displayInfo = 57430, }, -- Karn Steelhoof
	[82980] = { cameraID = 82, displayInfo = 57432, }, -- Galadran Gath
	[83009] = { cameraID = 109, displayInfo = 57460, }, -- Ilaniel Pine
	[83012] = { cameraID = 109, displayInfo = 59263, }, -- Celadina
	[83118] = { cameraID = 141, displayInfo = 54267, }, -- Orc (Thunderlord) - Archer 1
	[83119] = { cameraID = 141, displayInfo = 54376, }, -- Orc (Thunderlord) - Shaman 2
	[83120] = { cameraID = 141, displayInfo = 54276, }, -- Orc (Thunderlord) - Shaman 1
	[83124] = { cameraID = 141, displayInfo = 54480, }, -- Orc (Blackrock) - Ranged 1
	[83127] = { cameraID = 141, displayInfo = 59200, }, -- Orc (Blackrock) - Warrior 2
	[83129] = { cameraID = 141, displayInfo = 55982, }, -- Orc (Shadowmoon) - Shaman 2
	[83130] = { cameraID = 141, displayInfo = 55493, }, -- Orc (Shadowmoon) - Shaman 1
	[83134] = { cameraID = 141, displayInfo = 54895, }, -- Orc (Shadowmoon) - Warrior 1
	[83135] = { cameraID = 141, displayInfo = 57422, }, -- Orc (Warsong) - Raider
	[83137] = { cameraID = 141, displayInfo = 57221, }, -- Orc (Warsong) - Warrior 3
	[83138] = { cameraID = 141, displayInfo = 56166, }, -- Orc (Warsong) - Caster
	[83145] = { cameraID = 141, displayInfo = 52100, }, -- Orc (Shaddered Hand) 5
	[83146] = { cameraID = 141, displayInfo = 52099, }, -- Orc (Shaddered Hand) 6
	[83180] = { cameraID = 141, displayInfo = 54993, }, -- Shadow Council - Melee 2
	[83181] = { cameraID = 141, displayInfo = 55003, }, -- Shadow Council - Melee 3
	[83182] = { cameraID = 141, displayInfo = 55016, }, -- Shadow Council - Caster 1
	[83422] = { cameraID = 90, displayInfo = 47399, }, -- Crow Stalker
	[83462] = { cameraID = 141, displayInfo = 53613, }, -- Orc (Burning Blade) 3
	[83538] = { cameraID = 141, displayInfo = 57780, }, -- Warsong Commander
	[83648] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[83651] = { cameraID = 141, displayInfo = 57853, }, -- Battered Frostwolf Prisoner
	[83802] = { cameraID = 141, displayInfo = 57960, }, -- Napp'agosh
	[83837] = { cameraID = 120, displayInfo = 57982, }, -- Cymre Brightblade
	[83865] = { cameraID = 141, displayInfo = 57993, }, -- Grom'kar Captive
	[83948] = { cameraID = 120, displayInfo = 56683, }, -- Portal Mage
	[83951] = { cameraID = 141, displayInfo = 4527, }, -- Interactive Super Thrall
	[84098] = { cameraID = 141, displayInfo = 58123, }, -- Commander Gar
	[84123] = { cameraID = 126, displayInfo = 58138, }, -- Tapa Swiftpaw
	[84127] = { cameraID = 109, displayInfo = 58141, }, -- Scarletleaf
	[84176] = { cameraID = 141, displayInfo = 58178, }, -- Ripfist
	[84324] = { cameraID = 90, displayInfo = 58281, }, -- Vidar Goldaim
	[84437] = { cameraID = 141, displayInfo = 58337, }, -- Rongar
	[84438] = { cameraID = 90, displayInfo = 58338, }, -- Conall Rainsinger
	[84477] = { cameraID = 120, displayInfo = 58362, }, -- Besandran Shatterfury
	[84478] = { cameraID = 109, displayInfo = 58363, }, -- Syverandin Yewshade
	[84481] = { cameraID = 126, displayInfo = 58365, }, -- Tama Skyhoof
	[84484] = { cameraID = 126, displayInfo = 58368, }, -- Goahn
	[84668] = { cameraID = 126, displayInfo = 31777, }, -- Tholo Whitehoof
	[84672] = { cameraID = 126, displayInfo = 58425, }, -- Guardian Atohi
	[84676] = { cameraID = 105, displayInfo = 58430, }, -- Ursila Hudsen
	[84678] = { cameraID = 126, displayInfo = 58432, }, -- Iye
	[84699] = { cameraID = 105, displayInfo = 58453, }, -- Ilspeth Hollander
	[84703] = { cameraID = 109, displayInfo = 58457, }, -- Kihra
	[84710] = { cameraID = 105, displayInfo = 58461, }, -- Seline Keihl
	[84715] = { cameraID = 105, displayInfo = 58464, }, -- Randee Wallyce
	[84721] = { cameraID = 126, displayInfo = 58466, }, -- Humak the Verdant
	[84747] = { cameraID = 141, displayInfo = 58477, }, -- Torag Stonefury
	[84786] = { cameraID = 120, displayInfo = 58498, }, -- Ruthia the Unchaste
	[84789] = { cameraID = 82, displayInfo = 58502, }, -- Arctic Whitemace
	[84844] = { cameraID = 141, displayInfo = 55556, }, -- Burning Flameseer
	[84847] = { cameraID = 141, displayInfo = 55277, }, -- General Kull'krosh
	[84850] = { cameraID = 141, displayInfo = 54304, }, -- Iron Guard
	[85053] = { cameraID = 82, displayInfo = 56418, }, -- Bodrick Grey
	[85145] = { cameraID = 141, displayInfo = 58666, }, -- Liberated Frostwolf Prisoner
	[85159] = { cameraID = 105, displayInfo = 59266, }, -- Permelia
	[85161] = { cameraID = 109, displayInfo = 58682, }, -- Zelena Moonbreak
	[85175] = { cameraID = 120, displayInfo = 58692, }, -- Magistrix Soulblaze
	[85178] = { cameraID = 90, displayInfo = 47399, }, -- Mole Machine
	[85234] = { cameraID = 82, displayInfo = 53840, }, -- Garrison Soldier
	[85237] = { cameraID = 90, displayInfo = 53107, }, -- Garrison Rifleman
	[85292] = { cameraID = 141, displayInfo = 58773, }, -- Murgtar
	[85293] = { cameraID = 90, displayInfo = 58774, }, -- Stigander Ironsnare
	[85295] = { cameraID = 120, displayInfo = 58775, }, -- Mychele Morrowsong
	[85298] = { cameraID = 109, displayInfo = 29172, }, -- Kathrena Winterwisp
	[85413] = { cameraID = 82, displayInfo = 10457, }, -- Weldon Barov
	[85414] = { cameraID = 130, displayInfo = 10456, }, -- Alexi Barov
	[85450] = { cameraID = 141, displayInfo = 58851, }, -- Grom'kar Deadeye
	[85454] = { cameraID = 141, displayInfo = 58867, }, -- Grom'kar Bulwark
	[85455] = { cameraID = 141, displayInfo = 58859, }, -- Grom'kar Punisher
	[85456] = { cameraID = 141, displayInfo = 58888, }, -- Grom'kar Blademaster
	[85519] = { cameraID = 82, displayInfo = 58931, }, -- Christoph VonFeasel
	[85581] = { cameraID = 130, displayInfo = 58987, }, -- Walsh Atkins
	[85620] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[85706] = { cameraID = 90, displayInfo = 53107, }, -- Garrison Rifleman
	[85719] = { cameraID = 120, displayInfo = 56180, }, -- Garrison Priest
	[85720] = { cameraID = 141, displayInfo = 55307, }, -- Garrison Grunt
	[85723] = { cameraID = 109, displayInfo = 56185, }, -- Garrison Priest
	[85768] = { cameraID = 120, displayInfo = 59874, }, -- Aeda Brightdawn
	[85769] = { cameraID = 141, displayInfo = 59097, }, -- Zato Blindfury
	[85860] = { cameraID = 141, displayInfo = 59183, }, -- Lok'rig Felthrall
	[85861] = { cameraID = 90, displayInfo = 59184, }, -- Cinad Darksummit
	[85862] = { cameraID = 141, displayInfo = 59185, }, -- Nor'gruk Rotskull
	[85865] = { cameraID = 82, displayInfo = 59186, }, -- Caleb Weber
	[85868] = { cameraID = 90, displayInfo = 59189, }, -- Alasdair Whitepeak
	[85871] = { cameraID = 130, displayInfo = 30823, }, -- Calder Gray
	[85878] = { cameraID = 109, displayInfo = 56438, }, -- Daleera Moonfang
	[85928] = { cameraID = 82, displayInfo = 53840, }, -- Knight-Lieutenant Marx
	[85943] = { cameraID = 141, displayInfo = 55307, }, -- Blood Guard Krul
	[85984] = { cameraID = 82, displayInfo = 13099, }, -- Nat Pagle
	[85985] = { cameraID = 82, displayInfo = 13099, }, -- Nat Pagle
	[86038] = { cameraID = 141, displayInfo = 52201, }, -- Limbflayer
	[86084] = { cameraID = 90, displayInfo = 59353, }, -- Delvar Ironfist
	[86162] = { cameraID = 90, displayInfo = 34116, }, -- Fargo Flintlocke
	[86164] = { cameraID = 82, displayInfo = 36767, }, -- "Doc" Schweitzer
	[86169] = { cameraID = 120, displayInfo = 61228, }, -- Cheri
	[86172] = { cameraID = 82, displayInfo = 30999, }, -- Maximillian of Northshire
	[86227] = { cameraID = 141, displayInfo = 55162, }, -- Nitrogg Thundertower
	[86231] = { cameraID = 141, displayInfo = 56017, }, -- Makogg Emberblade
	[86249] = { cameraID = 141, displayInfo = 53177, }, -- Orebender Gor'ashan
	[86251] = { cameraID = 141, displayInfo = 53689, }, -- Commander Tharbek
	[86280] = { cameraID = 141, displayInfo = 34848, }, -- Rok'tar
	[86284] = { cameraID = 90, displayInfo = 59433, }, -- Dilben Ironshot
	[86302] = { cameraID = 141, displayInfo = 59445, }, -- Kairoz
	[86380] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[86431] = { cameraID = 141, displayInfo = 52201, }, -- Laughing Skull Berserker
	[86468] = { cameraID = 141, displayInfo = 21588, }, -- Gul'dan
	[86484] = { cameraID = 90, displayInfo = 58509, }, -- Glirin
	[86510] = { cameraID = 141, displayInfo = 59265, }, -- Spirit of Bony Xuk
	[86588] = { cameraID = 130, displayInfo = 59710, }, -- Benjamin Gibb
	[86709] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[86787] = { cameraID = 105, displayInfo = 59933, }, -- Mina Harken
	[86788] = { cameraID = 130, displayInfo = 59934, }, -- Cyril Fogus
	[86790] = { cameraID = 90, displayInfo = 59935, }, -- Torin Coalheart
	[86805] = { cameraID = 141, displayInfo = 59949, }, -- Mukkral Blackvein
	[86822] = { cameraID = 120, displayInfo = 59972, }, -- Taela Shatterborne
	[86824] = { cameraID = 109, displayInfo = 59973, }, -- Reina Morningchill
	[86828] = { cameraID = 130, displayInfo = 59977, }, -- Gerard Loom
	[86830] = { cameraID = 90, displayInfo = 59980, }, -- Garvan Bitterstone
	[86866] = { cameraID = 109, displayInfo = 60008, }, -- Gwynlan Rainglow
	[86867] = { cameraID = 120, displayInfo = 60009, }, -- Auriel Brightsong
	[86878] = { cameraID = 109, displayInfo = 60017, }, -- Fasani
	[86880] = { cameraID = 82, displayInfo = 60018, }, -- Archibald Arlison
	[86881] = { cameraID = 82, displayInfo = 61057, }, -- "Doc" Schweitzer
	[86893] = { cameraID = 109, displayInfo = 60032, }, -- Mysandra Swiftarc
	[86896] = { cameraID = 130, displayInfo = 60034, }, -- Henry Wall
	[86897] = { cameraID = 82, displayInfo = 60035, }, -- Kristian Nairn
	[86898] = { cameraID = 120, displayInfo = 60036, }, -- Aila Dourblade
	[86944] = { cameraID = 126, displayInfo = 60073, }, -- Shappa
	[87233] = { cameraID = 120, displayInfo = 60206, }, -- Harley Soubrette
	[87363] = { cameraID = 141, displayInfo = 54120, }, -- Throm'var Hunter
	[87400] = { cameraID = 82, displayInfo = 19149, }, -- Johnny Castle
	[87402] = { cameraID = 141, displayInfo = 1324, }, -- Grol'kar
	[87404] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[87438] = { cameraID = 141, displayInfo = 58761, }, -- Iron Reinforcement
	[87440] = { cameraID = 141, displayInfo = 54327, }, -- Iron Warden
	[87451] = { cameraID = 141, displayInfo = 56351, }, -- Fleshrender Nok'gar
	[87457] = { cameraID = 120, displayInfo = 15522, }, -- Blood Elf Mage
	[87465] = { cameraID = 82, displayInfo = 27562, }, -- Orbaz Bloodbane
	[87466] = { cameraID = 82, displayInfo = 3282, }, -- Brother Benjamin
	[87468] = { cameraID = 109, displayInfo = 30813, }, -- Vassandra Stormclaw
	[87469] = { cameraID = 141, displayInfo = 26836, }, -- Ebon Blade Knight
	[87473] = { cameraID = 126, displayInfo = 2096, }, -- Sark Ragetotem
	[87475] = { cameraID = 130, displayInfo = 31253, }, -- Undead Priest
	[87476] = { cameraID = 130, displayInfo = 31258, }, -- Undead Warlock
	[87590] = { cameraID = 141, displayInfo = 54575, }, -- Battered Frostwolf Prisoner
	[87598] = { cameraID = 82, displayInfo = 27530, }, -- Filmore Patricks
	[87603] = { cameraID = 126, displayInfo = 25910, }, -- Tigar Frosthoof
	[87608] = { cameraID = 120, displayInfo = 61495, }, -- Sylvie Fallensong
	[87614] = { cameraID = 109, displayInfo = 61310, }, -- Arebia Wintercall
	[87623] = { cameraID = 141, displayInfo = 60400, }, -- Orog
	[87625] = { cameraID = 82, displayInfo = 60402, }, -- Daniel Montoy
	[87631] = { cameraID = 109, displayInfo = 60407, }, -- Kalandra Starhelm
	[87634] = { cameraID = 141, displayInfo = 60410, }, -- Lurst Ragebreak
	[87673] = { cameraID = 120, displayInfo = 60438, }, -- Opheron
	[87677] = { cameraID = 130, displayInfo = 61329, }, -- Enoch Fuller
	[87678] = { cameraID = 90, displayInfo = 61330, }, -- Tavid Blightsteel
	[87680] = { cameraID = 90, displayInfo = 60443, }, -- Ultan Blackgorge
	[87682] = { cameraID = 109, displayInfo = 61320, }, -- Lleanya Mourningsong
	[87686] = { cameraID = 120, displayInfo = 60449, }, -- Handel Shadereaver
	[87712] = { cameraID = 126, displayInfo = 60465, }, -- Yaalo
	[87715] = { cameraID = 82, displayInfo = 60468, }, -- Truman Weaver
	[87721] = { cameraID = 120, displayInfo = 60473, }, -- Ariiya Sunblood
	[87722] = { cameraID = 105, displayInfo = 60474, }, -- Claire "the Fox"
	[87726] = { cameraID = 130, displayInfo = 60478, }, -- Lawrence Sharp
	[87734] = { cameraID = 120, displayInfo = 60484, }, -- Vivalia Sundagger
	[87736] = { cameraID = 141, displayInfo = 60486, }, -- Omril Keenedge
	[87737] = { cameraID = 82, displayInfo = 60487, }, -- Antone Sula
	[87739] = { cameraID = 109, displayInfo = 60489, }, -- Caelvana Duskwalker
	[87740] = { cameraID = 141, displayInfo = 60490, }, -- Rendrol Goreslash
	[87752] = { cameraID = 90, displayInfo = 60498, }, -- Lorcan Flintedge
	[87753] = { cameraID = 141, displayInfo = 60499, }, -- Mograg
	[87754] = { cameraID = 90, displayInfo = 60500, }, -- Dag Stonecircle
	[87755] = { cameraID = 126, displayInfo = 60501, }, -- Tadi
	[87756] = { cameraID = 90, displayInfo = 60502, }, -- Orvar
	[87759] = { cameraID = 90, displayInfo = 60505, }, -- Colm Breakstorm
	[87767] = { cameraID = 141, displayInfo = 60516, }, -- Kel'rikor
	[87770] = { cameraID = 126, displayInfo = 60518, }, -- Lonan
	[87772] = { cameraID = 90, displayInfo = 60519, }, -- Fingall Flamehammer
	[87776] = { cameraID = 82, displayInfo = 60522, }, -- Eli Cannon
	[87784] = { cameraID = 141, displayInfo = 61333, }, -- Orgriz Crookmaw
	[87785] = { cameraID = 82, displayInfo = 33754, }, -- Kris Rey
	[87786] = { cameraID = 130, displayInfo = 60541, }, -- Nathaniel Beastbreaker
	[87797] = { cameraID = 105, displayInfo = 60537, }, -- Caeris Felwalker
	[87800] = { cameraID = 109, displayInfo = 60539, }, -- Lylnleath Featherfoot
	[87802] = { cameraID = 130, displayInfo = 60542, }, -- John Greer
	[87805] = { cameraID = 120, displayInfo = 60545, }, -- Nadia Darksun
	[87806] = { cameraID = 105, displayInfo = 60546, }, -- Leena Guant
	[87809] = { cameraID = 126, displayInfo = 60549, }, -- Maska
	[87816] = { cameraID = 109, displayInfo = 60551, }, -- Ilyanna Talongrasp
	[87826] = { cameraID = 126, displayInfo = 60556, }, -- Gaho
	[87828] = { cameraID = 82, displayInfo = 60557, }, -- Larry Copeland
	[87830] = { cameraID = 105, displayInfo = 60560, }, -- Eunna Young
	[87831] = { cameraID = 141, displayInfo = 60561, }, -- Brakk Shattershield
	[87850] = { cameraID = 90, displayInfo = 60591, }, -- Bren Swiftshot
	[87852] = { cameraID = 105, displayInfo = 60592, }, -- Bastiana Moran
	[87858] = { cameraID = 126, displayInfo = 61342, }, -- Kaama Arrowspring
	[87860] = { cameraID = 82, displayInfo = 61343, }, -- Leonard Schrick
	[87869] = { cameraID = 141, displayInfo = 51362, }, -- Dark Acolyte
	[87870] = { cameraID = 141, displayInfo = 51366, }, -- Gul'var Grunt
	[87873] = { cameraID = 141, displayInfo = 61346, }, -- Arcanist Druk'rog
	[87876] = { cameraID = 141, displayInfo = 59988, }, -- Terrorwing Commander
	[87883] = { cameraID = 120, displayInfo = 61353, }, -- Dawn Mercurus
	[87884] = { cameraID = 120, displayInfo = 61353, }, -- Caerania the Tempering
	[87885] = { cameraID = 141, displayInfo = 55641, }, -- Grom'kar Peon
	[87891] = { cameraID = 109, displayInfo = 61360, }, -- Danaeris Amberstar
	[87892] = { cameraID = 120, displayInfo = 61367, }, -- Magistrix Chillbreeze
	[87898] = { cameraID = 82, displayInfo = 61370, }, -- Matthew Deyling
	[87899] = { cameraID = 90, displayInfo = 61373, }, -- Domnall Icecrag
	[87901] = { cameraID = 90, displayInfo = 61371, }, -- Niall Frostdrift
	[87904] = { cameraID = 82, displayInfo = 60601, }, -- Saul Lee
	[87927] = { cameraID = 126, displayInfo = 61389, }, -- Toega
	[87928] = { cameraID = 82, displayInfo = 61390, }, -- Thurman Belva
	[87929] = { cameraID = 130, displayInfo = 61397, }, -- Charles Norris
	[87930] = { cameraID = 90, displayInfo = 61399, }, -- Brogan Threepints
	[87932] = { cameraID = 109, displayInfo = 61402, }, -- Evanra Cloudchant
	[87939] = { cameraID = 126, displayInfo = 61515, }, -- Lusio
	[87940] = { cameraID = 90, displayInfo = 61516, }, -- Osgar Smitehammer
	[87941] = { cameraID = 126, displayInfo = 61517, }, -- Skah
	[87942] = { cameraID = 90, displayInfo = 61518, }, -- Bernhard Hammerdown
	[87943] = { cameraID = 126, displayInfo = 61519, }, -- Sahale
	[87944] = { cameraID = 82, displayInfo = 61520, }, -- Noah Munck
	[87945] = { cameraID = 126, displayInfo = 61507, }, -- Kaiel
	[87950] = { cameraID = 126, displayInfo = 61505, }, -- Tawa
	[87951] = { cameraID = 90, displayInfo = 61506, }, -- Hereward Stonecleave
	[87955] = { cameraID = 82, displayInfo = 61405, }, -- Nicholas Divide
	[87963] = { cameraID = 105, displayInfo = 61409, }, -- Linda Meier
	[88016] = { cameraID = 141, displayInfo = 60944, }, -- Cacklebone
	[88098] = { cameraID = 109, displayInfo = 60731, }, -- Hestiah Ravenwood
	[88165] = { cameraID = 120, displayInfo = 57772, }, -- Dark Ranger Velonara
	[88293] = { cameraID = 141, displayInfo = 61554, }, -- Aknor Steelbringer
	[88299] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[88317] = { cameraID = 82, displayInfo = 13099, }, -- Nat Pagle
	[88334] = { cameraID = 82, displayInfo = 52593, }, -- Croman
	[88345] = { cameraID = 141, displayInfo = 54952, }, -- Morketh Bladehowl
	[88516] = { cameraID = 82, displayInfo = 60940, }, -- Malden
	[89352] = { cameraID = 109, displayInfo = 39153, }, -- Tyrande Whisperwind
	[90217] = { cameraID = 82, displayInfo = 23223, }, -- Normantis the Deposed
	[90223] = { cameraID = 82, displayInfo = 61143, }, -- Harrison Jones
	[90332] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90350] = { cameraID = 90, displayInfo = 61955, }, -- Silver Hand Knight
	[90443] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Footsoldier
	[90452] = { cameraID = 141, displayInfo = 63360, }, -- Wounded Grunt
	[90453] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90527] = { cameraID = 109, displayInfo = 63346, }, -- Lunarfall Priest
	[90530] = { cameraID = 90, displayInfo = 63352, }, -- Lunarfall Rifleman
	[90601] = { cameraID = 141, displayInfo = 62051, }, -- Skulltaker
	[90602] = { cameraID = 141, displayInfo = 62052, }, -- Vok Blacktongue
	[90604] = { cameraID = 141, displayInfo = 61977, }, -- Koros Soulsplinter
	[90664] = { cameraID = 141, displayInfo = 53499, }, -- Beastlord Darmac
	[90672] = { cameraID = 141, displayInfo = 53519, }, -- Operator Thogar
	[90710] = { cameraID = 141, displayInfo = 66086, }, -- Baine Bloodhoof
	[90750] = { cameraID = 141, displayInfo = 55307, }, -- Horde Grunt
	[90751] = { cameraID = 82, displayInfo = 53840, }, -- Alliance Soldier
	[90793] = { cameraID = 82, displayInfo = 22354, }, -- Harrison Jones
	[91042] = { cameraID = 625, displayInfo = 63641, }, -- Koda Steelclaw
	[91109] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[91242] = { cameraID = 141, displayInfo = 62361, }, -- Solog Roark
	[91305] = { cameraID = 141, displayInfo = 62388, }, -- Fel Iron Summoner
	[91502] = { cameraID = 130, displayInfo = 62477, }, -- Undercity Guard
	[91559] = { cameraID = 141, displayInfo = 56405, }, -- Peon Prisoner
	[91866] = { cameraID = 82, displayInfo = 62762, }, -- Lord Maxwell Tyrosus
	[92123] = { cameraID = 82, displayInfo = 3258, }, -- Stormwind Guard
	[92132] = { cameraID = 120, displayInfo = 62346, }, -- Blood Mender
	[92133] = { cameraID = 82, displayInfo = 62326, }, -- Silver Hand Mender
	[92139] = { cameraID = 120, displayInfo = 62155, }, -- Blood Knight
	[92145] = { cameraID = 82, displayInfo = 62790, }, -- Silver Hand Protector
	[92148] = { cameraID = 90, displayInfo = 62798, }, -- Silver Hand Protector
	[92174] = { cameraID = 126, displayInfo = 62306, }, -- Sunwalker Dezco
	[92176] = { cameraID = 126, displayInfo = 62777, }, -- Sunwalker Reha
	[92177] = { cameraID = 126, displayInfo = 62778, }, -- Sunwalker Atohmo
	[92228] = { cameraID = 141, displayInfo = 62854, }, -- Oronok Torn-heart
	[92346] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[92368] = { cameraID = 82, displayInfo = 63005, }, -- Brother Wilhelm
	[92369] = { cameraID = 82, displayInfo = 63006, }, -- Brother Sammuel
	[92371] = { cameraID = 90, displayInfo = 63007, }, -- Azar Stronghammer
	[92372] = { cameraID = 90, displayInfo = 63008, }, -- Bromos Grummner
	[92376] = { cameraID = 82, displayInfo = 63010, }, -- Arthur the Faithful
	[92378] = { cameraID = 82, displayInfo = 63011, }, -- Duthorian Rall
	[92591] = { cameraID = 130, displayInfo = 63163, }, -- Sinker
	[92626] = { cameraID = 130, displayInfo = 63196, }, -- Deathguard Adams
	[92987] = { cameraID = 109, displayInfo = 63393, }, -- Maiev Shadowsong
	[93437] = { cameraID = 82, displayInfo = 30869, }, -- Highlord Darion Mograine
	[93471] = { cameraID = 82, displayInfo = 63575, }, -- Knight of the Ebon Blade
	[93708] = { cameraID = 126, displayInfo = 73067, }, -- Thunder Bluff Brave
	[93745] = { cameraID = 90, displayInfo = 47399, }, -- Small Fire
	[93748] = { cameraID = 90, displayInfo = 47399, }, -- Medium Fire
	[93929] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94127] = { cameraID = 90, displayInfo = 61955, }, -- Silver Hand Knight
	[94129] = { cameraID = 82, displayInfo = 62326, }, -- Silver Hand Mender
	[94131] = { cameraID = 82, displayInfo = 62790, }, -- Silver Hand Protector
	[94135] = { cameraID = 90, displayInfo = 62798, }, -- Silver Hand Protector
	[94145] = { cameraID = 141, displayInfo = 55581, }, -- Vol'mar Grunt
	[94146] = { cameraID = 82, displayInfo = 53840, }, -- Lion's Watch Footman
	[94174] = { cameraID = 82, displayInfo = 66765, }, -- Lord Maxwell Tyrosus
	[94209] = { cameraID = 82, displayInfo = 73090, }, -- Stormwind Knight
	[94287] = { cameraID = 126, displayInfo = 65464, }, -- Oakin Ironbull
	[94354] = { cameraID = 141, displayInfo = 49191, }, -- Spirit of Ga'nar
	[94429] = { cameraID = 141, displayInfo = 62361, }, -- Solog Roark
	[94573] = { cameraID = 82, displayInfo = 30821, }, -- Uther The Lightbringer
	[94579] = { cameraID = 126, displayInfo = 63943, }, -- Highmountain Defender
	[94738] = { cameraID = 141, displayInfo = 36191, }, -- Eitrigg
	[94864] = { cameraID = 120, displayInfo = 57982, }, -- Cymre Brightblade
	[95063] = { cameraID = 120, displayInfo = 60079, }, -- Allari the Souleater
	[95096] = { cameraID = 120, displayInfo = 60079, }, -- Allari the Souleater
	[95221] = { cameraID = 82, displayInfo = 64327, }, -- Mad Henryk
	[95242] = { cameraID = 109, displayInfo = 61734, }, -- Falara Nightsong
	[95246] = { cameraID = 109, displayInfo = 60550, }, -- Izal Whitemoon
	[95446] = { cameraID = 268, displayInfo = 61903, }, -- Battlelord Gaardoun
	[95447] = { cameraID = 268, displayInfo = 67885, }, -- Ashtongue Warrior
	[95449] = { cameraID = 268, displayInfo = 67883, }, -- Ashtongue Mystic
	[95450] = { cameraID = 268, displayInfo = 67884, }, -- Ashtongue Stalker
	[95581] = { cameraID = 120, displayInfo = 64434, }, -- Mistress Synrae
	[95717] = { cameraID = 126, displayInfo = 65478, }, -- Skyhorn Interceptor
	[95771] = { cameraID = 109, displayInfo = 64539, }, -- Dreadsoul Ruiner
	[95904] = { cameraID = 90, displayInfo = 64615, }, -- Dagnar Stonebrow
	[96194] = { cameraID = 126, displayInfo = 64785, }, -- Cairne Bloodhoof
	[96199] = { cameraID = 141, displayInfo = 64894, }, -- Nazgrim
	[96202] = { cameraID = 82, displayInfo = 64792, }, -- Daelin Proudmoore
	[96209] = { cameraID = 82, displayInfo = 66833, }, -- General Marcus Jonathan
	[96219] = { cameraID = 90, displayInfo = 64890, }, -- Modimus Anvilmar
	[96318] = { cameraID = 126, displayInfo = 64845, }, -- Huln Highmountain
	[96554] = { cameraID = 90, displayInfo = 62307, }, -- Valgar Highforge
	[96555] = { cameraID = 82, displayInfo = 62304, }, -- Lord Grayson Shadowbreaker
	[96556] = { cameraID = 120, displayInfo = 62891, }, -- Archivist Seline
	[96557] = { cameraID = 82, displayInfo = 62890, }, -- Archivist Thomas
	[96559] = { cameraID = 82, displayInfo = 62938, }, -- Apprentice Sampson
	[96594] = { cameraID = 82, displayInfo = 73522, }, -- Crusade Commander Eligor Dawnbringer
	[96595] = { cameraID = 82, displayInfo = 22200, }, -- Lord Irulon Trueblade
	[96596] = { cameraID = 82, displayInfo = 73524, }, -- Crusader Lord Lantinga
	[96598] = { cameraID = 82, displayInfo = 73582, }, -- Crusade Commander Entari
	[96599] = { cameraID = 90, displayInfo = 73583, }, -- Crusader Lord Dalfors
	[96604] = { cameraID = 82, displayInfo = 19382, }, -- Jorad Mace
	[96621] = { cameraID = 126, displayInfo = 66107, }, -- Mellok, Son of Torok
	[96695] = { cameraID = 82, displayInfo = 61947, }, -- Silver Hand Knight
	[96699] = { cameraID = 126, displayInfo = 62768, }, -- Sunwalker Keeper
	[96702] = { cameraID = 120, displayInfo = 62346, }, -- Blood Mender
	[96703] = { cameraID = 82, displayInfo = 62326, }, -- Silver Hand Mender
	[96706] = { cameraID = 90, displayInfo = 62334, }, -- Silver Hand Mender
	[96708] = { cameraID = 120, displayInfo = 62155, }, -- Blood Knight
	[96709] = { cameraID = 82, displayInfo = 62790, }, -- Silver Hand Protector
	[96710] = { cameraID = 90, displayInfo = 62798, }, -- Silver Hand Protector
	[96713] = { cameraID = 120, displayInfo = 62155, }, -- Blood Guardian
	[96719] = { cameraID = 126, displayInfo = 62901, }, -- Sunwalker Dawnchaser
	[96738] = { cameraID = 82, displayInfo = 30869, }, -- Highlord Darion Mograine
	[96755] = { cameraID = 109, displayInfo = 65039, }, -- Lyanis Moonfall
	[97111] = { cameraID = 120, displayInfo = 65086, }, -- Illanna Dreadmoore
	[97134] = { cameraID = 82, displayInfo = 25459, }, -- Lord Thorval
	[97136] = { cameraID = 120, displayInfo = 25458, }, -- Lady Alistra
	[97164] = { cameraID = 126, displayInfo = 65107, }, -- Rantuko Grimtouch
	[97243] = { cameraID = 109, displayInfo = 24935, }, -- Siouxsie the Banshee
	[97313] = { cameraID = 109, displayInfo = 24349, }, -- Commander Lynore Windstryke
	[97314] = { cameraID = 141, displayInfo = 64784, }, -- Nazgrel
	[97317] = { cameraID = 141, displayInfo = 64784, }, -- Nazgrel
	[97428] = { cameraID = 82, displayInfo = 33911, }, -- Thassarian
	[97488] = { cameraID = 82, displayInfo = 65226, }, -- Donavan Bale
	[97489] = { cameraID = 90, displayInfo = 65227, }, -- Garl Grimgrizzle
	[97491] = { cameraID = 109, displayInfo = 65229, }, -- Moon Priestess Nici
	[97492] = { cameraID = 141, displayInfo = 65230, }, -- Dak'hal the Black
	[97498] = { cameraID = 126, displayInfo = 63943, }, -- Highmountain Warbrave
	[97505] = { cameraID = 130, displayInfo = 65236, }, -- Drool
	[97506] = { cameraID = 126, displayInfo = 65482, }, -- Rivermane Shaman
	[97514] = { cameraID = 82, displayInfo = 65244, }, -- Danric the Bold
	[97518] = { cameraID = 120, displayInfo = 65251, }, -- Saedelin Whitedawn
	[97520] = { cameraID = 141, displayInfo = 65252, }, -- Drog Skullbreaker
	[97526] = { cameraID = 130, displayInfo = 73054, }, -- Deathguard Elite
	[97666] = { cameraID = 126, displayInfo = 65455, }, -- Warbrave Oro
	[97692] = { cameraID = 82, displayInfo = 65354, }, -- Brother of the Light
	[97699] = { cameraID = 82, displayInfo = 65365, }, -- Grand Priest
	[97725] = { cameraID = 109, displayInfo = 65369, }, -- Priestess of Elune
	[97727] = { cameraID = 109, displayInfo = 65383, }, -- Grand Priestess of Elune
	[97728] = { cameraID = 120, displayInfo = 65385, }, -- Blood Elf Priestess
	[97744] = { cameraID = 120, displayInfo = 65400, }, -- Blood Elf Grand Priestess
	[97792] = { cameraID = 126, displayInfo = 65422, }, -- Sun Priest
	[97814] = { cameraID = 130, displayInfo = 65431, }, -- Shadow Priest
	[97817] = { cameraID = 126, displayInfo = 65465, }, -- Highmountain Survivalist
	[97819] = { cameraID = 90, displayInfo = 65437, }, -- Shadow Priest
	[97829] = { cameraID = 82, displayInfo = 65450, }, -- Onslaught Apostate
	[98075] = { cameraID = 296, displayInfo = 21135, }, -- Illidan Stormrage
	[98102] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[98157] = { cameraID = 109, displayInfo = 67019, }, -- Lyana Darksorrow
	[98158] = { cameraID = 109, displayInfo = 64447, }, -- Asha Ravensong
	[98169] = { cameraID = 296, displayInfo = 27571, }, -- Illidan
	[98290] = { cameraID = 109, displayInfo = 63986, }, -- Cyana Nightglaive
	[98292] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn
	[98650] = { cameraID = 268, displayInfo = 61903, }, -- Battlelord Gaardoun
	[98788] = { cameraID = 126, displayInfo = 65983, }, -- Ancestral Warbrave
	[98825] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[99182] = { cameraID = 82, displayInfo = 66099, }, -- Sir Galveston
	[99423] = { cameraID = 120, displayInfo = 65392, }, -- Zaria Shadowheart
	[99602] = { cameraID = 120, displayInfo = 62531, }, -- Illidari Enforcer
	[99926] = { cameraID = 126, displayInfo = 62306, }, -- Sunwalker Dezco
	[99958] = { cameraID = 126, displayInfo = 66408, }, -- Wuho Highmountain
	[100005] = { cameraID = 126, displayInfo = 72823, }, -- Dorro Highmountain
	[100070] = { cameraID = 82, displayInfo = 25222, }, -- Crusader Valus
	[100071] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[100073] = { cameraID = 120, displayInfo = 29131, }, -- Crusader Rhydalla
	[100074] = { cameraID = 82, displayInfo = 26428, }, -- Crusader MacKellar
	[100075] = { cameraID = 82, displayInfo = 25131, }, -- Crusader Jonathan
	[100076] = { cameraID = 82, displayInfo = 37385, }, -- Talren Highbeacon
	[100077] = { cameraID = 90, displayInfo = 34644, }, -- Gidwin Goldbraids
	[100081] = { cameraID = 82, displayInfo = 25063, }, -- Captain Brandon
	[100082] = { cameraID = 82, displayInfo = 28836, }, -- Eadric the Pure
	[100084] = { cameraID = 90, displayInfo = 62922, }, -- Brandur Ironhammer
	[100085] = { cameraID = 120, displayInfo = 46766, }, -- Aenea
	[100087] = { cameraID = 120, displayInfo = 19596, }, -- Champion Cyssa Dawnrose
	[100091] = { cameraID = 120, displayInfo = 16685, }, -- Noellene
	[100162] = { cameraID = 109, displayInfo = 66527, }, -- Priestess of Elune
	[100175] = { cameraID = 126, displayInfo = 66492, }, -- Huln Highmountain
	[100196] = { cameraID = 82, displayInfo = 28836, }, -- Eadric the Pure
	[100209] = { cameraID = 126, displayInfo = 66504, }, -- Rivermane Tauren
	[100219] = { cameraID = 126, displayInfo = 66519, }, -- Bloodtotem Tauren
	[100220] = { cameraID = 126, displayInfo = 66523, }, -- Tribeless Tauren
	[100303] = { cameraID = 120, displayInfo = 66607, }, -- Zenobia
	[100364] = { cameraID = 813, displayInfo = 66403, }, -- Spirit of Vengeance
	[100402] = { cameraID = 126, displayInfo = 63943, }, -- Highmountain Defender
	[100448] = { cameraID = 82, displayInfo = 67690, }, -- General Bret Hughes
	[100449] = { cameraID = 82, displayInfo = 34004, }, -- Stormwind Royal Guard
	[100520] = { cameraID = 126, displayInfo = 66142, }, -- Rivermane Tauren
	[100652] = { cameraID = 575, displayInfo = 71689, }, -- Malfurion Stormrage
	[100653] = { cameraID = 141, displayInfo = 65757, }, -- Eitrigg
	[100701] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[100852] = { cameraID = 141, displayInfo = 4259, }, -- Orgrimmar Grunt
	[100975] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[100977] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[100981] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[101064] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[101148] = { cameraID = 82, displayInfo = 67003, }, -- Twilight Deacon Farthing
	[101294] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[101314] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[101317] = { cameraID = 109, displayInfo = 67049, }, -- Illysanna Ravencrest
	[101450] = { cameraID = 82, displayInfo = 67195, }, -- Archmage Karlain
	[101451] = { cameraID = 82, displayInfo = 67193, }, -- Archmage Ansirem Runeweaver
	[101453] = { cameraID = 82, displayInfo = 67196, }, -- Archmage Vargoth
	[101606] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[101986] = { cameraID = 141, displayInfo = 65975, }, -- Ritssyn Flamescowl
	[102005] = { cameraID = 120, displayInfo = 65287, }, -- Underbelly Guard
	[102195] = { cameraID = 90, displayInfo = 34116, }, -- Fargo Flintlocke
	[102202] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[102358] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[102554] = { cameraID = 90, displayInfo = 62751, }, -- Muradin Bronzebeard
	[102645] = { cameraID = 82, displayInfo = 67770, }, -- Margrave Dhakar
	[102914] = { cameraID = 109, displayInfo = 66672, }, -- Emmarel Shadewarden
	[102969] = { cameraID = 795, displayInfo = 66269, }, -- Nightborne Saboteur
	[102988] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[102989] = { cameraID = 82, displayInfo = 67931, }, -- Shadow Image
	[102992] = { cameraID = 126, displayInfo = 67942, }, -- Highmountain Tracker
	[102994] = { cameraID = 126, displayInfo = 67945, }, -- Rivermane Shaman
	[103031] = { cameraID = 126, displayInfo = 67942, }, -- Skyhorn Windcaller
	[103039] = { cameraID = 126, displayInfo = 67945, }, -- Bloodtotem Warbrave
	[103138] = { cameraID = 144, displayInfo = 39698, }, -- Chen Stormstout
	[103141] = { cameraID = 126, displayInfo = 67945, }, -- Rivermane Tauren
	[103144] = { cameraID = 82, displayInfo = 68038, }, -- Thoradin
	[103276] = { cameraID = 109, displayInfo = 32255, }, -- Druid of the Talon
	[103291] = { cameraID = 105, displayInfo = 65563, }, -- Druid of the Claw
	[103293] = { cameraID = 126, displayInfo = 65553, }, -- Druid of the Claw
	[103294] = { cameraID = 126, displayInfo = 11774, }, -- Moonglade Warden
	[103531] = { cameraID = 126, displayInfo = 68234, }, -- Ironhorn Claimjumper
	[103737] = { cameraID = 109, displayInfo = 68345, }, -- Sana Bloodletter
	[103760] = { cameraID = 109, displayInfo = 68365, }, -- Ariana Fireheart
	[103823] = { cameraID = 109, displayInfo = 62317, }, -- Druid Champion 1
	[103824] = { cameraID = 126, displayInfo = 31605, }, -- Druid Champion 2
	[103986] = { cameraID = 109, displayInfo = 15477, }, -- Windcaller Yessendra
	[103988] = { cameraID = 109, displayInfo = 21136, }, -- Arthorn Windsong
	[103989] = { cameraID = 126, displayInfo = 16430, }, -- Mahuram Stouthoof
	[103990] = { cameraID = 126, displayInfo = 10254, }, -- Taronn Redfeather
	[103991] = { cameraID = 109, displayInfo = 10646, }, -- Ivy Leafrunner
	[103997] = { cameraID = 105, displayInfo = 68452, }, -- Bella Wilder
	[104046] = { cameraID = 109, displayInfo = 17275, }, -- Ysiel Windsinger
	[104052] = { cameraID = 109, displayInfo = 68584, }, -- Lea Stonepaw
	[104053] = { cameraID = 109, displayInfo = 65569, }, -- Perla Nightfang
	[104091] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardian
	[104247] = { cameraID = 795, displayInfo = 70563, }, -- Duskwatch Arcanist
	[104535] = { cameraID = 109, displayInfo = 68584, }, -- Lea Stonepaw
	[104573] = { cameraID = 109, displayInfo = 68636, }, -- Lyessa Bloomwatcher
	[104623] = { cameraID = 109, displayInfo = 68650, }, -- Sylara Steelsong
	[104628] = { cameraID = 109, displayInfo = 68636, }, -- Lyessa Bloomwatcher
	[104631] = { cameraID = 90, displayInfo = 68654, }, -- Angus Ironfist
	[104651] = { cameraID = 268, displayInfo = 17600, }, -- Farseer Nobundo
	[104652] = { cameraID = 141, displayInfo = 64946, }, -- Rehgar Earthfury
	[104654] = { cameraID = 126, displayInfo = 38658, }, -- Muln Earthfury
	[104659] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[104673] = { cameraID = 120, displayInfo = 65979, }, -- Shinfel Blightsworn
	[104794] = { cameraID = 126, displayInfo = 66142, }, -- Rivermane Shaman
	[104825] = { cameraID = 126, displayInfo = 63943, }, -- Highmountain Tracker
	[104849] = { cameraID = 126, displayInfo = 65479, }, -- Skyhorn Windcaller
	[104930] = { cameraID = 109, displayInfo = 62644, }, -- Black Rook Archer
	[104971] = { cameraID = 126, displayInfo = 68876, }, -- Injured Tian Pupil
	[104983] = { cameraID = 90, displayInfo = 47399, }, -- Entrance  Kill Credit B
	[105220] = { cameraID = 82, displayInfo = 85261, }, -- Tournament Announcer
	[105250] = { cameraID = 793, displayInfo = 70039, }, -- Aulier
	[105265] = { cameraID = 795, displayInfo = 66265, }, -- Nightborne Reclaimer
	[105266] = { cameraID = 795, displayInfo = 66257, }, -- Nightborne Infiltrator
	[105514] = { cameraID = 126, displayInfo = 69021, }, -- Ox Style Adept
	[105522] = { cameraID = 126, displayInfo = 69175, }, -- Ox Style Master
	[105523] = { cameraID = 130, displayInfo = 69182, }, -- Tiger Style Master
	[105674] = { cameraID = 793, displayInfo = 70048, }, -- Varenne
	[105689] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[105691] = { cameraID = 126, displayInfo = 29250, }, -- Tahu Sagewind
	[105769] = { cameraID = 130, displayInfo = 69288, }, -- Brother Larry
	[105836] = { cameraID = 793, displayInfo = 69992, }, -- Nightborne Socialite
	[105934] = { cameraID = 109, displayInfo = 69425, }, -- Sylendra Gladesong
	[105935] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[105995] = { cameraID = 126, displayInfo = 69535, }, -- Muln Earthfury
	[106144] = { cameraID = 105, displayInfo = 69502, }, -- Guardian of the Dream
	[106279] = { cameraID = 82, displayInfo = 72532, }, -- Black Harvest Acolytes
	[106377] = { cameraID = 120, displayInfo = 71053, }, -- Archmage Omniara
	[106389] = { cameraID = 82, displayInfo = 63575, }, -- Ebon Knights
	[106391] = { cameraID = 268, displayInfo = 64417, }, -- [UNUSED]Ashtongue Warrior
	[106392] = { cameraID = 120, displayInfo = 61911, }, -- Illidari Adepts
	[106398] = { cameraID = 120, displayInfo = 71234, }, -- Squad of Archers
	[106399] = { cameraID = 82, displayInfo = 71242, }, -- Band of Trackers
	[106402] = { cameraID = 82, displayInfo = 71012, }, -- Silver Hand Knights
	[106405] = { cameraID = 82, displayInfo = 72390, }, -- Netherlight Paragons
	[106406] = { cameraID = 82, displayInfo = 72412, }, -- Band of Zealots
	[106407] = { cameraID = 82, displayInfo = 71426, }, -- Gang of Bandits
	[106408] = { cameraID = 82, displayInfo = 71445, }, -- Defias Thieves
	[106412] = { cameraID = 90, displayInfo = 72511, }, -- Circle of Earthcallers
	[106420] = { cameraID = 795, displayInfo = 69517, }, -- Anarys Lunastre
	[106552] = { cameraID = 109, displayInfo = 61098, }, -- Nightwatcher Merayl
	[106588] = { cameraID = 109, displayInfo = 68517, }, -- Sentinel of Ursoc
	[106594] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[106598] = { cameraID = 105, displayInfo = 65532, }, -- Celestine of the Harvest
	[106602] = { cameraID = 109, displayInfo = 69425, }, -- Sylendra Gladesong
	[106775] = { cameraID = 120, displayInfo = 62670, }, -- Lyanae
	[107008] = { cameraID = 90, displayInfo = 69208, }, -- Fevered Explorer
	[107013] = { cameraID = 90, displayInfo = 69208, }, -- Gravely Wounded Soldier
	[107075] = { cameraID = 82, displayInfo = 68480, }, -- Gravely Wounded Kirin Tor Guardian
	[107289] = { cameraID = 120, displayInfo = 69904, }, -- Lanigosa
	[107389] = { cameraID = 109, displayInfo = 69946, }, -- Ashen Druid
	[107391] = { cameraID = 109, displayInfo = 69951, }, -- Ashen Druid
	[107632] = { cameraID = 795, displayInfo = 70210, }, -- Ly'leth Lunastre
	[107831] = { cameraID = 82, displayInfo = 70482, }, -- Melris Malagan
	[107838] = { cameraID = 296, displayInfo = 70471, }, -- Illidan Stormrage
	[108024] = { cameraID = 141, displayInfo = 37328, }, -- Orgrimmar Wind Rider
	[108058] = { cameraID = 82, displayInfo = 3167, }, -- Stormwind City Patroller
	[108139] = { cameraID = 141, displayInfo = 70415, }, -- Blacksail Keelhauler
	[108240] = { cameraID = 141, displayInfo = 37328, }, -- Orgrimmar Wind Rider
	[108311] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn
	[108326] = { cameraID = 109, displayInfo = 64447, }, -- Asha Ravensong
	[108380] = { cameraID = 120, displayInfo = 69626, }, -- Esara Verrinde
	[108525] = { cameraID = 82, displayInfo = 37310, }, -- Stormwind Gryphon Rider
	[108869] = { cameraID = 795, displayInfo = 70748, }, -- Vineyard Laborer
	[108872] = { cameraID = 795, displayInfo = 70745, }, -- Margaux
	[108880] = { cameraID = 82, displayInfo = 70775, }, -- Padawsen
	[108919] = { cameraID = 82, displayInfo = 30821, }, -- Uther the Lightbringer
	[108936] = { cameraID = 90, displayInfo = 47399, }, -- Demon Kill Credit
	[108943] = { cameraID = 795, displayInfo = 70752, }, -- Vineyard Attendant
	[108996] = { cameraID = 813, displayInfo = 70809, }, -- Specter of Vengeance
	[109026] = { cameraID = 82, displayInfo = 29960, }, -- Huntsman Blake
	[109032] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[109034] = { cameraID = 126, displayInfo = 69918, }, -- Loren Stormhoof
	[109035] = { cameraID = 82, displayInfo = 29960, }, -- Huntsman Blake
	[109036] = { cameraID = 90, displayInfo = 63995, }, -- Hemet Nesingwary
	[109102] = { cameraID = 109, displayInfo = 71930, }, -- Delas Moonfang
	[109222] = { cameraID = 130, displayInfo = 67760, }, -- Meryl Felstorm
	[109226] = { cameraID = 82, displayInfo = 62303, }, -- Archmage Vargoth
	[109290] = { cameraID = 82, displayInfo = 72550, }, -- Black Harvest Invokers
	[109367] = { cameraID = 82, displayInfo = 70422, }, -- Kirin Tor Invokers
	[109379] = { cameraID = 82, displayInfo = 71010, }, -- Shieldbearer Phalanx
	[109380] = { cameraID = 82, displayInfo = 71014, }, -- Silver Hand Templar
	[109500] = { cameraID = 82, displayInfo = 72159, }, -- Jak
	[109531] = { cameraID = 130, displayInfo = 69026, }, -- Tiger Adept
	[109533] = { cameraID = 126, displayInfo = 69021, }, -- Ox Adept
	[109589] = { cameraID = 130, displayInfo = 63603, }, -- Royal Dreadguard
	[109736] = { cameraID = 126, displayInfo = 64488, }, -- Summoner Morn
	[109784] = { cameraID = 82, displayInfo = 69281, }, -- Twilight Darkcaller
	[109857] = { cameraID = 120, displayInfo = 71238, }, -- Unseen Marksmen
	[109858] = { cameraID = 120, displayInfo = 71234, }, -- Archer
	[109859] = { cameraID = 120, displayInfo = 71238, }, -- Marksmen
	[109869] = { cameraID = 82, displayInfo = 71246, }, -- Pathfinders
	[109879] = { cameraID = 82, displayInfo = 71242, }, -- Trackers
	[109880] = { cameraID = 82, displayInfo = 71246, }, -- Rangers
	[109881] = { cameraID = 120, displayInfo = 70830, }, -- Lenara
	[109886] = { cameraID = 141, displayInfo = 70436, }, -- Nazgrim
	[109887] = { cameraID = 120, displayInfo = 70053, }, -- Apprentice
	[109888] = { cameraID = 82, displayInfo = 70422, }, -- Conjurer
	[109899] = { cameraID = 82, displayInfo = 70807, }, -- Thoras Trollbane
	[109902] = { cameraID = 82, displayInfo = 71008, }, -- Silver Hand Squire
	[109903] = { cameraID = 82, displayInfo = 71010, }, -- Silver Hand Phalanx
	[109904] = { cameraID = 82, displayInfo = 71012, }, -- Silver Hand Knight
	[109905] = { cameraID = 82, displayInfo = 71014, }, -- Silver Hand Champion
	[109971] = { cameraID = 268, displayInfo = 67885, }, -- Ashtongue Warriors
	[109974] = { cameraID = 268, displayInfo = 67885, }, -- Ashtongue Warrior
	[109976] = { cameraID = 120, displayInfo = 61909, }, -- Illidari Adept
	[110033] = { cameraID = 141, displayInfo = 25999, }, -- Ebon Ravagers
	[110057] = { cameraID = 82, displayInfo = 63575, }, -- Ebon Knights
	[110058] = { cameraID = 141, displayInfo = 25999, }, -- Ebon Champions
	[110113] = { cameraID = 625, displayInfo = 66686, }, -- Claws of Ursoc - Alt 1 - Base - Night Elf
	[110172] = { cameraID = 82, displayInfo = 69542, }, -- Lord Jorach Ravenholdt
	[110173] = { cameraID = 82, displayInfo = 67215, }, -- Fleet Admiral Tethys
	[110177] = { cameraID = 82, displayInfo = 83274, }, -- Master Mathias Shaw
	[110262] = { cameraID = 82, displayInfo = 71472, }, -- Crew of Pirates
	[110328] = { cameraID = 82, displayInfo = 71426, }, -- Theives
	[110330] = { cameraID = 82, displayInfo = 71445, }, -- Defias Bandits
	[110337] = { cameraID = 82, displayInfo = 71472, }, -- Pirates
	[110489] = { cameraID = 130, displayInfo = 67760, }, -- Meryl Felstorm
	[110490] = { cameraID = 82, displayInfo = 34761, }, -- SI:7 Agent A
	[110495] = { cameraID = 268, displayInfo = 64939, }, -- Farseer Nobundo
	[110544] = { cameraID = 82, displayInfo = 71107, }, -- Aspiring Shadow Council Enforcer
	[110568] = { cameraID = 82, displayInfo = 72435, }, -- Dark Zealots
	[110571] = { cameraID = 109, displayInfo = 50541, }, -- Delas Moonfang
	[110593] = { cameraID = 90, displayInfo = 65437, }, -- Zealot
	[110634] = { cameraID = 82, displayInfo = 73090, }, -- Stormwind Knight
	[110782] = { cameraID = 126, displayInfo = 41765, }, -- Mission McSmartypants
	[111041] = { cameraID = 130, displayInfo = 71784, }, -- Micah Belford
	[111269] = { cameraID = 109, displayInfo = 71930, }, -- Delas Moonfang
	[111339] = { cameraID = 82, displayInfo = 70807, }, -- King Thoras Trollbane
	[111340] = { cameraID = 82, displayInfo = 27466, }, -- Highlord Darion Mograine
	[111341] = { cameraID = 141, displayInfo = 70436, }, -- Nazgrim
	[111352] = { cameraID = 130, displayInfo = 69747, }, -- Felburned Scout
	[111445] = { cameraID = 795, displayInfo = 73519, }, -- Suramar Loyalist
	[111470] = { cameraID = 141, displayInfo = 69700, }, -- Gravely Wounded Soldier
	[111490] = { cameraID = 793, displayInfo = 71122, }, -- Loyalist Sycophant
	[111544] = { cameraID = 120, displayInfo = 69672, }, -- Fevered Explorer
	[111600] = { cameraID = 82, displayInfo = 34004, }, -- Stormwind Royal Guard
	[111618] = { cameraID = 795, displayInfo = 66278, }, -- Duskwatch Enforcer
	[111668] = { cameraID = 109, displayInfo = 67978, }, -- Emmoris, Mistress of Light
	[111713] = { cameraID = 82, displayInfo = 40765, }, -- Faralis the Fanatic
	[111715] = { cameraID = 82, displayInfo = 18039, }, -- The Concertmaster
	[111734] = { cameraID = 120, displayInfo = 70992, }, -- Conjurer Awlyn
	[111769] = { cameraID = 795, displayInfo = 73514, }, -- Menagerie Keeper
	[111772] = { cameraID = 82, displayInfo = 62326, }, -- Terric the Illuminator
	[111775] = { cameraID = 109, displayInfo = 62529, }, -- Evelune Soulreaver
	[111778] = { cameraID = 82, displayInfo = 33911, }, -- Thassarian
	[111779] = { cameraID = 141, displayInfo = 70436, }, -- Nazgrim
	[111797] = { cameraID = 120, displayInfo = 71915, }, -- Blood Knight
	[111799] = { cameraID = 109, displayInfo = 66672, }, -- Emmarel Shadewarden
	[111800] = { cameraID = 126, displayInfo = 69918, }, -- Loren Stormhoof
	[111803] = { cameraID = 144, displayInfo = 39698, }, -- Chen Stormstout
	[111806] = { cameraID = 82, displayInfo = 66765, }, -- Lord Maxwell Tyrosus
	[111815] = { cameraID = 141, displayInfo = 65975, }, -- Ritssyn Flamescowl
	[111835] = { cameraID = 126, displayInfo = 65883, }, -- Injured Adventurer
	[111836] = { cameraID = 126, displayInfo = 65884, }, -- Injured Adventurer
	[111837] = { cameraID = 126, displayInfo = 65996, }, -- Injured Adventurer
	[111930] = { cameraID = 90, displayInfo = 69208, }, -- Fevered Explorer
	[111943] = { cameraID = 109, displayInfo = 66957, }, -- Gravely Wounded Moonfall Defender
	[111949] = { cameraID = 109, displayInfo = 68533, }, -- Fevered Val'sharah Refugee
	[111950] = { cameraID = 109, displayInfo = 68534, }, -- Fevered Val'sharah Refugee
	[111951] = { cameraID = 109, displayInfo = 68535, }, -- Fevered Val'sharah Refugee
	[112060] = { cameraID = 82, displayInfo = 71950, }, -- Matthew Veiss
	[112079] = { cameraID = 82, displayInfo = 65450, }, -- Crimson Pilgrim
	[112115] = { cameraID = 795, displayInfo = 69529, }, -- Analys Featherfall
	[112117] = { cameraID = 82, displayInfo = 83274, }, -- Master Mathias Shaw
	[112130] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[112256] = { cameraID = 82, displayInfo = 24818, }, -- Goons
	[112261] = { cameraID = 109, displayInfo = 64539, }, -- Dreadsoul Corruptor
	[112264] = { cameraID = 296, displayInfo = 72011, }, -- Illidan Stormrage
	[112329] = { cameraID = 141, displayInfo = 72037, }, -- Velgrim
	[112335] = { cameraID = 141, displayInfo = 72040, }, -- Scarab Lord Ahzesh
	[112337] = { cameraID = 130, displayInfo = 72043, }, -- Nisstyr
	[112358] = { cameraID = 126, displayInfo = 72046, }, -- Scarab Lord Hamlet
	[112360] = { cameraID = 130, displayInfo = 72064, }, -- Guard
	[112363] = { cameraID = 126, displayInfo = 72565, }, -- Spoogledorf
	[112372] = { cameraID = 120, displayInfo = 72052, }, -- Wheatizzle
	[112373] = { cameraID = 126, displayInfo = 72053, }, -- Jarud
	[112386] = { cameraID = 130, displayInfo = 72054, }, -- Twirhp
	[112402] = { cameraID = 141, displayInfo = 72057, }, -- Oku
	[112405] = { cameraID = 130, displayInfo = 72058, }, -- Vhell
	[112406] = { cameraID = 120, displayInfo = 72059, }, -- Merciless Gladiator Saifu
	[112431] = { cameraID = 126, displayInfo = 72069, }, -- Airhorn
	[112463] = { cameraID = 793, displayInfo = 70750, }, -- Stablemaster Vorithal
	[112465] = { cameraID = 793, displayInfo = 70750, }, -- Stablemaster Orian
	[112466] = { cameraID = 82, displayInfo = 72080, }, -- Agent Smith
	[112467] = { cameraID = 82, displayInfo = 72081, }, -- Agent Jones
	[112471] = { cameraID = 793, displayInfo = 70027, }, -- Lord Nimrod
	[112473] = { cameraID = 795, displayInfo = 69995, }, -- Lady Dyana
	[112583] = { cameraID = 105, displayInfo = 69502, }, -- Fallen Guardian of the Dream
	[112695] = { cameraID = 82, displayInfo = 67600, }, -- Hooded Priest
	[112700] = { cameraID = 90, displayInfo = 72189, }, -- Silver Hand Templar
	[112702] = { cameraID = 126, displayInfo = 72191, }, -- Silver Hand Templar
	[112704] = { cameraID = 90, displayInfo = 72202, }, -- Shieldbearer Phalanx
	[112711] = { cameraID = 126, displayInfo = 72204, }, -- Shieldbearer Phalanx
	[112715] = { cameraID = 90, displayInfo = 72213, }, -- Silver Hand Knights
	[112722] = { cameraID = 82, displayInfo = 72670, }, -- Squad of Squires
	[112750] = { cameraID = 109, displayInfo = 72265, }, -- Ebon Knights
	[112753] = { cameraID = 130, displayInfo = 72270, }, -- Ebon Ravagers
	[112754] = { cameraID = 105, displayInfo = 72275, }, -- Ebon Ravagers
	[112755] = { cameraID = 109, displayInfo = 72278, }, -- Druids of the Claw
	[112780] = { cameraID = 109, displayInfo = 72288, }, -- Squad of Archers
	[112781] = { cameraID = 126, displayInfo = 72296, }, -- Squad of Archers
	[112790] = { cameraID = 105, displayInfo = 72321, }, -- Band of Trackers
	[112852] = { cameraID = 795, displayInfo = 71740, }, -- Magistrix Astroleth
	[112872] = { cameraID = 109, displayInfo = 72714, }, -- Group of Acolytes
	[112873] = { cameraID = 90, displayInfo = 72380, }, -- Group of Acolytes
	[112886] = { cameraID = 109, displayInfo = 72716, }, -- Band of Zealots
	[112901] = { cameraID = 82, displayInfo = 72435, }, -- Dark Zealots
	[112920] = { cameraID = 120, displayInfo = 73043, }, -- Dark Ranger
	[112958] = { cameraID = 82, displayInfo = 57211, }, -- Soulare of Andorhal
	[112971] = { cameraID = 90, displayInfo = 71468, }, -- Uncrowned Duelists
	[112975] = { cameraID = 141, displayInfo = 71132, }, -- Circle of Earthcallers
	[112981] = { cameraID = 126, displayInfo = 72512, }, -- Circle of Earthcallers
	[112984] = { cameraID = 141, displayInfo = 72520, }, -- Earthen Ring Geomancers
	[112989] = { cameraID = 130, displayInfo = 72538, }, -- Black Harvest Acolytes
	[112992] = { cameraID = 268, displayInfo = 64414, }, -- Seer Aleis
	[112993] = { cameraID = 105, displayInfo = 72537, }, -- Black Harvest Acolytes
	[112995] = { cameraID = 90, displayInfo = 72545, }, -- Black Harvest Acolytes
	[112999] = { cameraID = 90, displayInfo = 72561, }, -- Black Harvest Invokers
	[113003] = { cameraID = 82, displayInfo = 72569, }, -- Ox Initiates
	[113008] = { cameraID = 141, displayInfo = 69019, }, -- Ox Adepts
	[113009] = { cameraID = 82, displayInfo = 72581, }, -- Ox Adepts
	[113017] = { cameraID = 82, displayInfo = 72594, }, -- Ox Masters
	[113024] = { cameraID = 130, displayInfo = 69026, }, -- Tiger Adepts
	[113027] = { cameraID = 109, displayInfo = 69018, }, -- Tiger Adepts
	[113029] = { cameraID = 90, displayInfo = 72609, }, -- Tiger Adepts
	[113071] = { cameraID = 82, displayInfo = 83274, }, -- SI:7 Orders
	[113139] = { cameraID = 82, displayInfo = 71472, }, -- Pirate
	[113146] = { cameraID = 82, displayInfo = 71426, }, -- Bandit
	[113152] = { cameraID = 82, displayInfo = 71445, }, -- Defias Thief
	[113156] = { cameraID = 82, displayInfo = 72674, }, -- Shieldbearer Phalanx
	[113169] = { cameraID = 120, displayInfo = 72688, }, -- Illidari Adepts
	[113170] = { cameraID = 120, displayInfo = 61909, }, -- Illidari Adepts
	[113186] = { cameraID = 82, displayInfo = 71445, }, -- Defias Thief
	[113215] = { cameraID = 82, displayInfo = 72374, }, -- Acolyte
	[113218] = { cameraID = 90, displayInfo = 72408, }, -- Zealot
	[113220] = { cameraID = 82, displayInfo = 72435, }, -- Dark Zealot
	[113224] = { cameraID = 141, displayInfo = 25999, }, -- Ebon Ravager
	[113237] = { cameraID = 82, displayInfo = 71242, }, -- Tracker
	[113249] = { cameraID = 90, displayInfo = 72609, }, -- Tiger Adept
	[113251] = { cameraID = 120, displayInfo = 72220, }, -- Squire
	[113252] = { cameraID = 82, displayInfo = 71010, }, -- Shieldbearer
	[113254] = { cameraID = 82, displayInfo = 71014, }, -- Silver Hand Templar
	[113257] = { cameraID = 90, displayInfo = 72511, }, -- Earthcaller
	[113262] = { cameraID = 82, displayInfo = 72532, }, -- Black Harvest Acolyte
	[113263] = { cameraID = 90, displayInfo = 72561, }, -- Black Harvest Invoker
	[113355] = { cameraID = 141, displayInfo = 72769, }, -- Broxigar the Red
	[113357] = { cameraID = 82, displayInfo = 72770, }, -- Rhonin
	[113410] = { cameraID = 625, displayInfo = 66693, }, -- Claws of Ursoc - Alt 1 - Base - Tauren
	[113411] = { cameraID = 625, displayInfo = 66683, }, -- Claws of Ursoc - Alt 1 - Base - Troll
	[113412] = { cameraID = 625, displayInfo = 66685, }, -- Claws of Ursoc - Alt 1 - Base - Worgen
	[113424] = { cameraID = 109, displayInfo = 72825, }, -- Priestess of the Moon
	[113438] = { cameraID = 82, displayInfo = 71014, }, -- Silver Hand Templar
	[113456] = { cameraID = 795, displayInfo = 66279, }, -- Duskwatch Enforcer [Test Palette]
	[113474] = { cameraID = 795, displayInfo = 66259, }, -- Menagerie Keeper [Test Palette]
	[113511] = { cameraID = 130, displayInfo = 72839, }, -- Dark Zealot
	[113526] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[113608] = { cameraID = 82, displayInfo = 27215, }, -- Kirin Tor Guardian
	[113618] = { cameraID = 795, displayInfo = 70031, }, -- Suramar Loyalist
	[113632] = { cameraID = 82, displayInfo = 71014, }, -- Silver Hand Templar
	[113708] = { cameraID = 120, displayInfo = 61909, }, -- Illidari Rift Controller
	[113769] = { cameraID = 90, displayInfo = 72202, }, -- Silver Hand Shieldbearer
	[113835] = { cameraID = 141, displayInfo = 73361, }, -- Broxigar the Red
	[113979] = { cameraID = 109, displayInfo = 65229, }, -- Priestess of the Moon
	[113981] = { cameraID = 109, displayInfo = 29800, }, -- Lorlathil Villager
	[113989] = { cameraID = 82, displayInfo = 71426, }, -- Gang of Bandits
	[113990] = { cameraID = 109, displayInfo = 72453, }, -- Gang of Bandits
	[113992] = { cameraID = 105, displayInfo = 72462, }, -- Gang of Bandits
	[113996] = { cameraID = 120, displayInfo = 72477, }, -- Defias Thieves
	[114000] = { cameraID = 120, displayInfo = 72485, }, -- Crew of Pirates
	[114001] = { cameraID = 130, displayInfo = 72662, }, -- Crew of Pirates
	[114002] = { cameraID = 82, displayInfo = 71472, }, -- Crew of Pirates
	[114003] = { cameraID = 109, displayInfo = 72491, }, -- Crew of Pirates
	[114008] = { cameraID = 268, displayInfo = 67885, }, -- Ashtongue Warriors
	[114009] = { cameraID = 268, displayInfo = 67884, }, -- Ashtongue Warriors
	[114010] = { cameraID = 268, displayInfo = 67883, }, -- Ashtongue Warriors
	[114015] = { cameraID = 120, displayInfo = 61909, }, -- Illidari Adepts
	[114035] = { cameraID = 90, displayInfo = 72522, }, -- Earthen Ring Geomancers
	[114042] = { cameraID = 82, displayInfo = 70422, }, -- Kirin Tor Invokers
	[114043] = { cameraID = 120, displayInfo = 70992, }, -- Kirin Tor Invokers
	[114045] = { cameraID = 105, displayInfo = 72362, }, -- Kirin Tor Invokers
	[114046] = { cameraID = 120, displayInfo = 71234, }, -- Squad of Archers
	[114048] = { cameraID = 90, displayInfo = 73041, }, -- Squad of Archers
	[114050] = { cameraID = 120, displayInfo = 71238, }, -- Unseen Marksmen
	[114051] = { cameraID = 82, displayInfo = 71241, }, -- Unseen Marksmen
	[114053] = { cameraID = 130, displayInfo = 72311, }, -- Unseen Marksmen
	[114054] = { cameraID = 82, displayInfo = 71242, }, -- Band of Trackers
	[114058] = { cameraID = 82, displayInfo = 71246, }, -- Pathfinders
	[114066] = { cameraID = 141, displayInfo = 37328, }, -- Orgrimmar Wind Rider
	[114116] = { cameraID = 141, displayInfo = 69181, }, -- Tiger Masters
	[114117] = { cameraID = 120, displayInfo = 69183, }, -- Tiger Masters
	[114119] = { cameraID = 90, displayInfo = 72609, }, -- Tiger Adepts
	[114122] = { cameraID = 120, displayInfo = 69007, }, -- Tiger Adepts
	[114124] = { cameraID = 109, displayInfo = 72599, }, -- Tiger Initates
	[114127] = { cameraID = 82, displayInfo = 72594, }, -- Ox Masters
	[114139] = { cameraID = 82, displayInfo = 72581, }, -- Ox Adepts
	[114145] = { cameraID = 109, displayInfo = 72577, }, -- Ox Initiates
	[114150] = { cameraID = 109, displayInfo = 73135, }, -- Druids of the Claw
	[114155] = { cameraID = 82, displayInfo = 71008, }, -- Squad of Squires
	[114157] = { cameraID = 120, displayInfo = 72220, }, -- Squad of Squires
	[114163] = { cameraID = 120, displayInfo = 72209, }, -- Silver Hand Knights
	[114167] = { cameraID = 82, displayInfo = 71014, }, -- Silver Hand Templar
	[114177] = { cameraID = 120, displayInfo = 72399, }, -- Netherlight Paragons
	[114180] = { cameraID = 82, displayInfo = 72412, }, -- Band of Zealots
	[114184] = { cameraID = 130, displayInfo = 72433, }, -- Dark Zealots
	[114196] = { cameraID = 82, displayInfo = 63575, }, -- Ebon Knights
	[114198] = { cameraID = 109, displayInfo = 72265, }, -- Ebon Knights
	[114200] = { cameraID = 141, displayInfo = 25999, }, -- Ebon Ravagers
	[114203] = { cameraID = 105, displayInfo = 72275, }, -- Ebon Ravagers
	[114242] = { cameraID = 120, displayInfo = 62670, }, -- Helda the Breaker
	[114243] = { cameraID = 120, displayInfo = 62670, }, -- Kelissa Stilwell
	[114359] = { cameraID = 109, displayInfo = 73234, }, -- Tyrande Whisperwind
	[114480] = { cameraID = 795, displayInfo = 71601, }, -- Duskwatch Observer
	[114889] = { cameraID = 795, displayInfo = 70011, }, -- Shal'dorei Civilian
	[114897] = { cameraID = 109, displayInfo = 46522, }, -- Darnassus Sentinel
	[114908] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[114911] = { cameraID = 795, displayInfo = 73539, }, -- Duskwatch Warcaster
	[114955] = { cameraID = 82, displayInfo = 73579, }, -- Dole Dastardly
	[114963] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[114980] = { cameraID = 141, displayInfo = 73600, }, -- Steingardt
	[115078] = { cameraID = 795, displayInfo = 73864, }, -- Arluelle
	[115079] = { cameraID = 795, displayInfo = 73514, }, -- Victoire
	[115081] = { cameraID = 795, displayInfo = 69990, }, -- Deline
	[115092] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[115094] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[115262] = { cameraID = 82, displayInfo = 73731, }, -- Moroes
	[115278] = { cameraID = 82, displayInfo = 73957, }, -- Undead Steward
	[115292] = { cameraID = 90, displayInfo = 73758, }, -- Ulrich Forgeworth
	[115294] = { cameraID = 90, displayInfo = 73735, }, -- Altor Direvith
	[115298] = { cameraID = 82, displayInfo = 73812, }, -- Baron Rafe Dreuger
	[115299] = { cameraID = 82, displayInfo = 73814, }, -- Lord Crispin Ference
	[115322] = { cameraID = 795, displayInfo = 73514, }, -- Victoire
	[115366] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[115404] = { cameraID = 126, displayInfo = 65465, }, -- Huln Highmountain
	[115438] = { cameraID = 82, displayInfo = 73731, }, -- Moroes
	[115439] = { cameraID = 82, displayInfo = 73818, }, -- Baron Rafe Dreuger
	[115441] = { cameraID = 82, displayInfo = 73820, }, -- Lord Crispin Ference
	[115468] = { cameraID = 82, displayInfo = 61993, }, -- Archmage Karlain
	[115521] = { cameraID = 109, displayInfo = 46522, }, -- Sentinel Moonshade
	[115535] = { cameraID = 795, displayInfo = 73867, }, -- Skulking Assassin
	[115543] = { cameraID = 82, displayInfo = 73863, }, -- Archmage Xylem
	[115649] = { cameraID = 82, displayInfo = 73911, }, -- Dancer
	[115652] = { cameraID = 82, displayInfo = 73909, }, -- Dancer
	[115654] = { cameraID = 82, displayInfo = 73910, }, -- Dancer
	[115662] = { cameraID = 82, displayInfo = 73930, }, -- Dancer
	[115684] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Peacekeeper
	[115698] = { cameraID = 82, displayInfo = 73928, }, -- Dancer
	[115709] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[115712] = { cameraID = 82, displayInfo = 73933, }, -- Dancer
	[115717] = { cameraID = 82, displayInfo = 73935, }, -- Dancer
	[115736] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[115808] = { cameraID = 795, displayInfo = 74659, }, -- Ly'leth Lunastre
	[115833] = { cameraID = 90, displayInfo = 47399, }, -- Place or Remove Flag
	[115916] = { cameraID = 141, displayInfo = 63360, }, -- Horde Grunt
	[115921] = { cameraID = 90, displayInfo = 53107, }, -- Alliance Rifleman
	[116146] = { cameraID = 296, displayInfo = 27571, }, -- Illidan Stormrage
	[116364] = { cameraID = 109, displayInfo = 74170, }, -- Sentinel Petrai
	[116470] = { cameraID = 109, displayInfo = 74216, }, -- Felbound Spirit
	[116490] = { cameraID = 109, displayInfo = 74222, }, -- Kyra Lightblade
	[116621] = { cameraID = 109, displayInfo = 74266, }, -- Demissya Gladestrider
	[116697] = { cameraID = 296, displayInfo = 27571, }, -- Illidan Stormrage
	[116702] = { cameraID = 130, displayInfo = 74292, }, -- Roland Abernathy
	[116704] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn
	[116743] = { cameraID = 82, displayInfo = 74331, }, -- Shadowmaster Aameen
	[116829] = { cameraID = 141, displayInfo = 59487, }, -- Test NPC
	[117042] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[117044] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[117077] = { cameraID = 82, displayInfo = 74419, }, -- Bill the Janitor
	[117121] = { cameraID = 141, displayInfo = 66086, }, -- ArneTest - Baine Bloodhoof
	[117179] = { cameraID = 82, displayInfo = 74467, }, -- Strange Thing
	[117479] = { cameraID = 141, displayInfo = 65757, }, -- Eitrigg
	[117493] = { cameraID = 126, displayInfo = 32457, }, -- Grimtotem Warrior
	[117500] = { cameraID = 795, displayInfo = 66261, }, -- Nighthuntress Syrenne
	[117503] = { cameraID = 82, displayInfo = 46573, }, -- Kanrethad Ebonlocke
	[117508] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[117523] = { cameraID = 82, displayInfo = 73522, }, -- Eligor Dawnbringer
	[117524] = { cameraID = 82, displayInfo = 60700, }, -- Maximillian of Northshire
	[117694] = { cameraID = 90, displayInfo = 26353, }, -- Brann Bronzebeard
	[117759] = { cameraID = 90, displayInfo = 74595, }, -- Frost
	[117865] = { cameraID = 141, displayInfo = 65975, }, -- Ritssyn Flamescowl
	[117867] = { cameraID = 120, displayInfo = 65979, }, -- Shinfel Blightsworn
	[117873] = { cameraID = 296, displayInfo = 74146, }, -- Illidan Stormrage
	[117951] = { cameraID = 268, displayInfo = 74635, }, -- Nameless Mystic
	[117974] = { cameraID = 296, displayInfo = 27571, }, -- Illidan Stormrage
	[118010] = { cameraID = 82, displayInfo = 74489, }, -- Maximillian of Northshire
	[118052] = { cameraID = 106, displayInfo = 74655, }, -- Prophet Velen
	[118104] = { cameraID = 109, displayInfo = 2035, }, -- Shandris Feathermoon
	[118348] = { cameraID = 82, displayInfo = 71010, }, -- Injured Shieldbearer
	[118424] = { cameraID = 82, displayInfo = 71426, }, -- Injured Bandit
	[118425] = { cameraID = 120, displayInfo = 61909, }, -- Injured Adept
	[118429] = { cameraID = 120, displayInfo = 71234, }, -- Injured Archer
	[118433] = { cameraID = 82, displayInfo = 63575, }, -- Injured Ebon Knight
	[118506] = { cameraID = 120, displayInfo = 47522, }, -- Sunreaver Spellblade
	[118667] = { cameraID = 795, displayInfo = 66261, }, -- Nighthuntress Syrenne
	[118669] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[118772] = { cameraID = 795, displayInfo = 75511, }, -- Asrea Moonblade
	[118775] = { cameraID = 126, displayInfo = 74940, }, -- Omanawkwa Steelhoof
	[118795] = { cameraID = 795, displayInfo = 66261, }, -- Nighthuntress Syrenne
	[118796] = { cameraID = 126, displayInfo = 65482, }, -- Rivermane Shaman
	[118925] = { cameraID = 793, displayInfo = 70036, }, -- Felconsumed Victim
	[118938] = { cameraID = 82, displayInfo = 21256, }, -- Stranger
	[119053] = { cameraID = 82, displayInfo = 75038, }, -- Xorothian Cultist
	[119064] = { cameraID = 141, displayInfo = 60003, }, -- Warsong Warrior
	[119077] = { cameraID = 109, displayInfo = 73135, }, -- Dreamgrove Protector
	[119081] = { cameraID = 795, displayInfo = 66261, }, -- Nightborne Huntress
	[119090] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardians
	[119130] = { cameraID = 296, displayInfo = 76249, }, -- Illidan Stormrage
	[119209] = { cameraID = 109, displayInfo = 75447, }, -- Erelyn Moonfang
	[119273] = { cameraID = 141, displayInfo = 76330, }, -- Kor'kron Shock Force
	[119728] = { cameraID = 106, displayInfo = 75801, }, -- Prophet Velen
	[119729] = { cameraID = 296, displayInfo = 75059, }, -- Illidan Stormrage
	[119731] = { cameraID = 82, displayInfo = 65834, }, -- Khadgar
	[119751] = { cameraID = 1860, displayInfo = 76431, }, -- Shadowguard Voidcaster
	[119768] = { cameraID = 141, displayInfo = 74939, }, -- Legionfall Soldier
	[119773] = { cameraID = 120, displayInfo = 69189, }, -- Fel-Poisoned Initiate
	[119777] = { cameraID = 90, displayInfo = 75495, }, -- Durgan Stonestorm
	[119778] = { cameraID = 141, displayInfo = 64946, }, -- Rehgar (IGC)
	[119787] = { cameraID = 268, displayInfo = 71623, }, -- Farseer Nobundo (IGC)
	[119789] = { cameraID = 126, displayInfo = 69535, }, -- Muln Earthfury (IGC)
	[119935] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn (IGC)
	[119998] = { cameraID = 795, displayInfo = 66261, }, -- Nightborne Hunters
	[120001] = { cameraID = 141, displayInfo = 69153, }, -- Earthen Ring Protectors
	[120007] = { cameraID = 120, displayInfo = 62942, }, -- Silver Hand Crusaders
	[120172] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[120218] = { cameraID = 296, displayInfo = 74146, }, -- Illidan Stormrage
	[120514] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[120529] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[120533] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[120590] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[120753] = { cameraID = 120, displayInfo = 69196, }, -- Wounded Captive
	[120922] = { cameraID = 84, displayInfo = 87893, }, -- Lady Jaina Proudmoore
	[120942] = { cameraID = 126, displayInfo = 65996, }, -- Rivermane Shaman
	[121239] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[121276] = { cameraID = 109, displayInfo = 74962, }, -- Forgotten Echo
	[121361] = { cameraID = 141, displayInfo = 76292, }, -- Ebon Knight Frostreavers
	[121362] = { cameraID = 109, displayInfo = 76293, }, -- Ebon Knight Frostreavers
	[121363] = { cameraID = 82, displayInfo = 76295, }, -- Ebon Knight Frostreavers
	[121366] = { cameraID = 120, displayInfo = 47997, }, -- Kirin Tor Guardians
	[121374] = { cameraID = 82, displayInfo = 62326, }, -- Silver Hand Crusaders
	[121376] = { cameraID = 82, displayInfo = 67600, }, -- Hooded Priests
	[121377] = { cameraID = 130, displayInfo = 67601, }, -- Hooded Priests
	[121378] = { cameraID = 82, displayInfo = 76324, }, -- Ravenholdt Assassins
	[121380] = { cameraID = 82, displayInfo = 76326, }, -- Ravenholdt Assassins
	[121389] = { cameraID = 82, displayInfo = 62744, }, -- 7th Legion Shock Force
	[121416] = { cameraID = 82, displayInfo = 72550, }, -- Black Harvest Invoker
	[121486] = { cameraID = 795, displayInfo = 66261, }, -- Nightborne Hunters
	[121487] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardians
	[121489] = { cameraID = 120, displayInfo = 62942, }, -- Silver Hand Crusaders
	[121491] = { cameraID = 141, displayInfo = 69153, }, -- Earthen Ring Protectors
	[121492] = { cameraID = 141, displayInfo = 76330, }, -- Kor'kron Shock Force
	[121786] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[122032] = { cameraID = 84, displayInfo = 80015, }, -- Lady Jaina Proudmoore
	[122087] = { cameraID = 82, displayInfo = 61871, }, -- Archmage Khadgar
	[122452] = { cameraID = 82, displayInfo = 83315, }, -- Foundry Worker
	[122701] = { cameraID = 120, displayInfo = 81869, }, -- Examiner Alerinda
	[122702] = { cameraID = 120, displayInfo = 81830, }, -- Enchantress Quinni
	[124022] = { cameraID = 82, displayInfo = 85582, }, -- Ashvane Jailer
	[124072] = { cameraID = 82, displayInfo = 33908, }, -- Alliance Force-Commander
	[124074] = { cameraID = 130, displayInfo = 33907, }, -- Deathguard War-Captain
	[124232] = { cameraID = 82, displayInfo = 52400, }, -- Tol Dagor Inmate
	[124252] = { cameraID = 126, displayInfo = 83258, }, -- Spiritwalker Ebonhorn
	[124449] = { cameraID = 120, displayInfo = 90363, }, -- Lady Liadrin
	[124497] = { cameraID = 82, displayInfo = 78046, }, -- Fallhaven Villager
	[124503] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon (IGC)
	[124590] = { cameraID = 296, displayInfo = 27571, }, -- Lord Illidan Stormrage
	[124722] = { cameraID = 82, displayInfo = 79859, }, -- Commodore Calhoun
	[124787] = { cameraID = 84, displayInfo = 88348, }, -- Lady Jaina Proudmoore
	[124802] = { cameraID = 82, displayInfo = 78476, }, -- Lord Aldrius Norwington
	[124855] = { cameraID = 130, displayInfo = 87531, }, -- Sludge Guard
	[124875] = { cameraID = 1860, displayInfo = 76542, }, -- Shadowguard Subjugator (IGC)
	[125097] = { cameraID = 120, displayInfo = 78328, }, -- Dark Ranger
	[125134] = { cameraID = 82, displayInfo = 78342, }, -- Stormwind Lookout
	[125181] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[125513] = { cameraID = 106, displayInfo = 17822, }, -- Image of Prophet Velen
	[125682] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[125832] = { cameraID = 126, displayInfo = 81348, }, -- Huln Highmountain
	[125844] = { cameraID = 1860, displayInfo = 76423, }, -- Shadowguard Voidbender (IGC)
	[126305] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[126319] = { cameraID = 82, displayInfo = 78867, }, -- High Exarch Turalyon
	[126323] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[126472] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[126718] = { cameraID = 82, displayInfo = 79064, }, -- Freehold Porter
	[126719] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Cutthroat
	[126773] = { cameraID = 1860, displayInfo = 78749, }, -- Locus-Walker
	[126774] = { cameraID = 82, displayInfo = 79091, }, -- Irontide Trickshot
	[128467] = { cameraID = 82, displayInfo = 79948, }, -- Elijah Eggleton
	[128481] = { cameraID = 1208, displayInfo = 75083, }, -- PC - Void Elf Female
	[128483] = { cameraID = 795, displayInfo = 67345, }, -- PC - Nightborne Elf Female
	[128486] = { cameraID = 126, displayInfo = 65479, }, -- PC - Highmountain Tauren Male
	[128700] = { cameraID = 82, displayInfo = 79069, }, -- Irontide Recruiter
	[128704] = { cameraID = 82, displayInfo = 79064, }, -- Great Sea Vagrant
	[128705] = { cameraID = 82, displayInfo = 80087, }, -- Great Sea Privateer
	[128903] = { cameraID = 82, displayInfo = 80247, }, -- Carentan
	[129025] = { cameraID = 82, displayInfo = 80339, }, -- Cutwater Duelist
	[129067] = { cameraID = 82, displayInfo = 88457, }, -- Cutwater Card Shark
	[129097] = { cameraID = 90, displayInfo = 80380, }, -- Blacktooth Scrapper
	[129121] = { cameraID = 82, displayInfo = 80389, }, -- Blacktooth Brute
	[129211] = { cameraID = 109, displayInfo = 80441, }, -- Tyrande Whisperwind
	[129836] = { cameraID = 130, displayInfo = 85413, }, -- Spelltwister Moephus
	[129957] = { cameraID = 82, displayInfo = 78018, }, -- Clarence Page
	[130129] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[130134] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[130419] = { cameraID = 82, displayInfo = 81470, }, -- Cyril White
	[130521] = { cameraID = 82, displayInfo = 79064, }, -- Freehold Deckhand
	[130522] = { cameraID = 82, displayInfo = 80087, }, -- Freehold Shipmate
	[130695] = { cameraID = 82, displayInfo = 81351, }, -- Vigil Hill Marine
	[130704] = { cameraID = 82, displayInfo = 80996, }, -- Lord Stormsong
	[130719] = { cameraID = 82, displayInfo = 81362, }, -- Brennadam Citizen
	[130728] = { cameraID = 82, displayInfo = 81363, }, -- Brennadam Citizen
	[130729] = { cameraID = 82, displayInfo = 81364, }, -- Brennadam Citizen
	[130730] = { cameraID = 82, displayInfo = 81366, }, -- Brennadam Citizen
	[130768] = { cameraID = 82, displayInfo = 81302, }, -- Brother Pike
	[130810] = { cameraID = 82, displayInfo = 78867, }, -- High Exarch Turalyon
	[130879] = { cameraID = 82, displayInfo = 81458, }, -- Vigil Hill Refugee
	[130884] = { cameraID = 1208, displayInfo = 75083, }, -- NPC - Void Elf Female Civilian (Caster)
	[130885] = { cameraID = 1208, displayInfo = 75083, }, -- NPC - Void Elf Female Military (Melee/Guard)
	[130886] = { cameraID = 1208, displayInfo = 75083, }, -- NPC - Void Elf Female Noble (Leader)
	[130888] = { cameraID = 795, displayInfo = 67345, }, -- NPC - Nightborne Elf Female Civilian
	[130890] = { cameraID = 795, displayInfo = 67345, }, -- NPC - Nightborne Elf Female Military
	[130891] = { cameraID = 795, displayInfo = 67345, }, -- NPC - Nightborne Elf Female Noble
	[131137] = { cameraID = 82, displayInfo = 81610, }, -- SI:7 Operative
	[131216] = { cameraID = 130, displayInfo = 81649, }, -- Forsaken Battleguard
	[131234] = { cameraID = 82, displayInfo = 82164, }, -- Blacktooth Brute
	[131239] = { cameraID = 82, displayInfo = 82170, }, -- Irontide Pillager
	[131302] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Pillager
	[131307] = { cameraID = 82, displayInfo = 80389, }, -- Blacktooth Brute
	[131317] = { cameraID = 82, displayInfo = 81469, }, -- Samuel Williams
	[131357] = { cameraID = 84, displayInfo = 80016, }, -- Jaina Proudmoore
	[131358] = { cameraID = 84, displayInfo = 80015, }, -- Jaina Proudmoore
	[131443] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[131462] = { cameraID = 90, displayInfo = 80380, }, -- Blacktooth Guzzler
	[131526] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem (IGC)
	[131566] = { cameraID = 141, displayInfo = 81911, }, -- Peon
	[131736] = { cameraID = 105, displayInfo = 81612, }, -- Mirabelle
	[131972] = { cameraID = 82, displayInfo = 79064, }, -- Freehold Porter
	[132043] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Cannoneer
	[132180] = { cameraID = 82, displayInfo = 82295, }, -- Irontide Treasure Counter
	[132272] = { cameraID = 82, displayInfo = 82351, }, -- Great Sea Bird Trainer
	[132276] = { cameraID = 82, displayInfo = 82341, }, -- Harvey the Bird Man
	[132371] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[132387] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[132418] = { cameraID = 126, displayInfo = 65705, }, -- Injured Warbrave (IGC)
	[132642] = { cameraID = 82, displayInfo = 82545, }, -- Kul Tiran Noble
	[133080] = { cameraID = 82, displayInfo = 60699, }, -- Highlord Darion Mograine
	[133081] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn
	[133084] = { cameraID = 82, displayInfo = 62303, }, -- Archmage Vargoth
	[133086] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[133088] = { cameraID = 84, displayInfo = 67214, }, -- Valeera Sanguinar
	[133089] = { cameraID = 141, displayInfo = 64946, }, -- Rehgar Earthfury
	[133090] = { cameraID = 141, displayInfo = 65975, }, -- Ritssyn Flamescowl
	[133091] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[133105] = { cameraID = 82, displayInfo = 82701, }, -- Warren Ashton
	[133346] = { cameraID = 141, displayInfo = 4048, }, -- Gor'mul
	[133421] = { cameraID = 141, displayInfo = 4032, }, -- Hammerfall Grunt
	[133462] = { cameraID = 82, displayInfo = 56418, }, -- Bodrick Grey
	[133467] = { cameraID = 795, displayInfo = 82964, }, -- Anarys Lunastre
	[133526] = { cameraID = 105, displayInfo = 87525, }, -- Gilnean Mauler
	[133545] = { cameraID = 1208, displayInfo = 82403, }, -- Rift Warden (IGC)
	[133547] = { cameraID = 1208, displayInfo = 82400, }, -- Locus Researcher (IGC)
	[133600] = { cameraID = 82, displayInfo = 83037, }, -- Cutwater Sharpeye
	[133665] = { cameraID = 82, displayInfo = 81362, }, -- Keeneyed Watchman
	[133953] = { cameraID = 82, displayInfo = 81349, }, -- Sergeant Calvin
	[134037] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[134176] = { cameraID = 82, displayInfo = 81351, }, -- Bridgeport Guard
	[134192] = { cameraID = 105, displayInfo = 34518, }, -- Gilnean Battlemage
	[134201] = { cameraID = 84, displayInfo = 80016, }, -- Lady Jaina Proudmoore
	[134351] = { cameraID = 130, displayInfo = 78923, }, -- Royal Dreadguard
	[134352] = { cameraID = 130, displayInfo = 78923, }, -- Royal Cavalier
	[134755] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[134777] = { cameraID = 109, displayInfo = 2306, }, -- Darnassian Sentinels
	[134872] = { cameraID = 82, displayInfo = 62744, }, -- 7th Legion Shocktroopers
	[134957] = { cameraID = 130, displayInfo = 23937, }, -- Sludge Guard
	[134973] = { cameraID = 82, displayInfo = 33239, }, -- John J. Keeshan
	[134981] = { cameraID = 130, displayInfo = 81649, }, -- Forsaken Battleguard
	[135077] = { cameraID = 82, displayInfo = 53840, }, -- Fort Victory Footman
	[135603] = { cameraID = 82, displayInfo = 80180, }, -- Boralus Civilian
	[135675] = { cameraID = 82, displayInfo = 85767, }, -- 7th Legion Marine
	[135677] = { cameraID = 90, displayInfo = 53107, }, -- 7th Legion Rifleman
	[135792] = { cameraID = 82, displayInfo = 78480, }, -- Boralus Worker
	[136068] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[136202] = { cameraID = 120, displayInfo = 85924, }, -- Lady Liadrin
	[136766] = { cameraID = 82, displayInfo = 82795, }, -- Norwington Guard
	[136920] = { cameraID = 82, displayInfo = 83555, }, -- Marshal Everit Reade
	[136923] = { cameraID = 82, displayInfo = 81607, }, -- Inquisitor Yorrick
	[136928] = { cameraID = 82, displayInfo = 81604, }, -- Inquisitor Notley
	[137207] = { cameraID = 82, displayInfo = 22661, }, -- Maiden's Virtue Helmsman
	[137210] = { cameraID = 82, displayInfo = 81469, }, -- Samuel Williams
	[137216] = { cameraID = 82, displayInfo = 22663, }, -- Maiden's Virtue Sailor
	[137218] = { cameraID = 82, displayInfo = 22820, }, -- Enthralled Sailor
	[137222] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[137225] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[137227] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[137229] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[137268] = { cameraID = 105, displayInfo = 82026, }, -- Fenrae the Cunning
	[137297] = { cameraID = 1208, displayInfo = 83523, }, -- Shadeweaver Zarra
	[137314] = { cameraID = 90, displayInfo = 84174, }, -- Varigg
	[137460] = { cameraID = 82, displayInfo = 81362, }, -- Defiant Farmer
	[137476] = { cameraID = 82, displayInfo = 81362, }, -- Brennadam Citizen
	[137530] = { cameraID = 82, displayInfo = 85348, }, -- Daniel Poole
	[137534] = { cameraID = 126, displayInfo = 83326, }, -- Tauren Earthshakers
	[137558] = { cameraID = 130, displayInfo = 34172, }, -- Forsaken Dreadguards
	[137565] = { cameraID = 120, displayInfo = 78165, }, -- Silvermoon Sorceress
	[137569] = { cameraID = 141, displayInfo = 85151, }, -- Orc Raider
	[137699] = { cameraID = 90, displayInfo = 82021, }, -- Muradin Bronzebeard
	[137701] = { cameraID = 82, displayInfo = 84983, }, -- Danath Trollbane
	[137895] = { cameraID = 141, displayInfo = 84545, }, -- Warfang Grunt
	[138167] = { cameraID = 82, displayInfo = 79091, }, -- Irontide Trickshot
	[138170] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Cutthroat
	[138282] = { cameraID = 82, displayInfo = 79064, }, -- Great Sea Vagrant
	[138344] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Pillager
	[138345] = { cameraID = 82, displayInfo = 79091, }, -- Irontide Straightshooter
	[138360] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[138385] = { cameraID = 82, displayInfo = 81351, }, -- Bridgeport Guard
	[138542] = { cameraID = 82, displayInfo = 81351, }, -- Bridgeport Guard
	[138607] = { cameraID = 82, displayInfo = 81351, }, -- Bridgeport Guard
	[138738] = { cameraID = 82, displayInfo = 81351, }, -- Bridgeport Sentry
	[138755] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Slaver
	[138789] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Pillager
	[138865] = { cameraID = 82, displayInfo = 85585, }, -- Storm's Wake Footman
	[138951] = { cameraID = 120, displayInfo = 68558, }, -- Dark Ranger Denyelle
	[138961] = { cameraID = 82, displayInfo = 81717, }, -- Stranded Battalion Guard
	[139098] = { cameraID = 82, displayInfo = 86134, }, -- Thomas Zelling
	[139102] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[139489] = { cameraID = 82, displayInfo = 86314, }, -- Captain Hermes
	[139527] = { cameraID = 82, displayInfo = 81610, }, -- SI:7 Operative
	[139550] = { cameraID = 793, displayInfo = 86393, }, -- Associate Telemancer Burneth
	[139558] = { cameraID = 82, displayInfo = 82843, }, -- Ashvane Associate
	[139559] = { cameraID = 82, displayInfo = 84072, }, -- Proudmoore Guard
	[139561] = { cameraID = 141, displayInfo = 59949, }, -- Mukkral Blackvein
	[139916] = { cameraID = 141, displayInfo = 29263, }, -- Captain Tarkan
	[139917] = { cameraID = 141, displayInfo = 29095, }, -- Dockmaster Mugok
	[139918] = { cameraID = 141, displayInfo = 28584, }, -- Orux Thrice-Damned
	[139919] = { cameraID = 141, displayInfo = 32557, }, -- Blood Guard Aldo Rockrain
	[139921] = { cameraID = 109, displayInfo = 2182, }, -- Sentinel Thenysil
	[139922] = { cameraID = 109, displayInfo = 28540, }, -- Moon Priestess Maestra
	[139923] = { cameraID = 109, displayInfo = 28416, }, -- Dentaria Silverglade
	[139964] = { cameraID = 130, displayInfo = 86536, }, -- Thomas Zelling
	[140129] = { cameraID = 109, displayInfo = 65552, }, -- Master Shapeshifter Lyara
	[140178] = { cameraID = 126, displayInfo = 83326, }, -- Orgrimmar Raider
	[140213] = { cameraID = 130, displayInfo = 22632, }, -- Deathstalker Hayward
	[140214] = { cameraID = 130, displayInfo = 22535, }, -- Chief Plaguebringer Harris
	[140219] = { cameraID = 130, displayInfo = 3682, }, -- Magus Wordeen Voidglare
	[140220] = { cameraID = 141, displayInfo = 5730, }, -- Yelnagi Blackarm
	[140221] = { cameraID = 141, displayInfo = 3743, }, -- Tarshaw Jaggedscar
	[140222] = { cameraID = 141, displayInfo = 31147, }, -- Karga Rageroar
	[140223] = { cameraID = 141, displayInfo = 30825, }, -- Warlord Crawgol
	[140225] = { cameraID = 126, displayInfo = 1678, }, -- Maur Raincaller
	[140226] = { cameraID = 120, displayInfo = 16781, }, -- Magister Zaedana
	[140228] = { cameraID = 82, displayInfo = 34441, }, -- Master Sergeant Pietro Zaren
	[140231] = { cameraID = 82, displayInfo = 34441, }, -- Captain Pietro Zaren
	[140232] = { cameraID = 90, displayInfo = 19244, }, -- Grumbol Grimhammer
	[140234] = { cameraID = 90, displayInfo = 7007, }, -- Gryphon Master Talonaxe
	[140235] = { cameraID = 82, displayInfo = 46026, }, -- General Hammond Clay
	[140236] = { cameraID = 82, displayInfo = 31130, }, -- Thomas Paxton
	[140237] = { cameraID = 82, displayInfo = 33763, }, -- Keep Watcher Kerry
	[140239] = { cameraID = 90, displayInfo = 31297, }, -- Logan Talonstrike
	[140240] = { cameraID = 82, displayInfo = 1864, }, -- Cannoneer Whessan
	[140488] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[140529] = { cameraID = 120, displayInfo = 86752, }, -- Blood Marquess
	[140581] = { cameraID = 82, displayInfo = 81351, }, -- Vigil Hill Militia
	[140880] = { cameraID = 82, displayInfo = 86952, }, -- Michael Skarn
	[140913] = { cameraID = 82, displayInfo = 86966, }, -- Reed 'The Flirt' Fisc
	[140936] = { cameraID = 82, displayInfo = 86639, }, -- Kul Tiran Executioner
	[140937] = { cameraID = 82, displayInfo = 80087, }, -- Adoring Freebooter
	[140944] = { cameraID = 82, displayInfo = 83982, }, -- Kul Tiran Criminal
	[141004] = { cameraID = 82, displayInfo = 76992, }, -- Waycrest Guard
	[141019] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[141046] = { cameraID = 1208, displayInfo = 82884, }, -- Leana Darkwind
	[141070] = { cameraID = 82, displayInfo = 87031, }, -- Flynn Fairwind
	[141077] = { cameraID = 130, displayInfo = 77393, }, -- Kwint
	[141090] = { cameraID = 82, displayInfo = 81362, }, -- Mill Worker
	[141107] = { cameraID = 82, displayInfo = 87063, }, -- Burnsy the Blade
	[141187] = { cameraID = 90, displayInfo = 18815, }, -- Bron Goldhammer
	[141188] = { cameraID = 82, displayInfo = 70765, }, -- Commander Sharp
	[141190] = { cameraID = 109, displayInfo = 74955, }, -- Huntress Duskrunner
	[141192] = { cameraID = 82, displayInfo = 10151, }, -- Commander Ashlam Valorfist
	[141193] = { cameraID = 82, displayInfo = 5076, }, -- High Sorcerer Andromath
	[141213] = { cameraID = 82, displayInfo = 31202, }, -- Corporal Teegan
	[141214] = { cameraID = 109, displayInfo = 33224, }, -- Belysra Starbreeze
	[141216] = { cameraID = 90, displayInfo = 62922, }, -- Brandur Ironhammer
	[141224] = { cameraID = 109, displayInfo = 29194, }, -- Huntress Jalin
	[141228] = { cameraID = 82, displayInfo = 30041, }, -- Dockmaster Lewis
	[141230] = { cameraID = 82, displayInfo = 2048, }, -- Raleigh the Devout
	[141234] = { cameraID = 82, displayInfo = 33773, }, -- Quartermaster Lawson
	[141237] = { cameraID = 126, displayInfo = 29502, }, -- Ruk Warstomper
	[141242] = { cameraID = 141, displayInfo = 32559, }, -- Scout Utvoch
	[141245] = { cameraID = 141, displayInfo = 32558, }, -- Sergeant Dontrag
	[141246] = { cameraID = 130, displayInfo = 11466, }, -- Derek the Undying
	[141248] = { cameraID = 120, displayInfo = 30071, }, -- Dark Ranger Clea
	[141249] = { cameraID = 141, displayInfo = 35216, }, -- Blademaster Ronakada
	[141250] = { cameraID = 141, displayInfo = 3846, }, -- Gazrog
	[141251] = { cameraID = 141, displayInfo = 29173, }, -- Dagrun Ragehammer
	[141252] = { cameraID = 141, displayInfo = 12959, }, -- Mastok Wrilehiss
	[141255] = { cameraID = 130, displayInfo = 35686, }, -- Captain Keyton
	[141256] = { cameraID = 130, displayInfo = 3545, }, -- High Executor Hadrec
	[141259] = { cameraID = 130, displayInfo = 1680, }, -- Master Apothecary Faranell
	[141260] = { cameraID = 141, displayInfo = 29200, }, -- Captain Goggath
	[141262] = { cameraID = 141, displayInfo = 30544, }, -- Kilrok Gorehammer
	[141310] = { cameraID = 793, displayInfo = 86393, }, -- Associate Telemancer Rafcav
	[141337] = { cameraID = 105, displayInfo = 33551, }, -- Bloodfang Stalkers
	[141344] = { cameraID = 120, displayInfo = 78167, }, -- Silvermoon Sorceress
	[141479] = { cameraID = 82, displayInfo = 80754, }, -- Burly
	[141485] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Skyrider
	[141487] = { cameraID = 141, displayInfo = 87329, }, -- Lantresor of the Blade
	[141497] = { cameraID = 84, displayInfo = 80015, }, -- Jaina Proudmoore
	[141688] = { cameraID = 141, displayInfo = 87411, }, -- Shattered Hand Specialist
	[141703] = { cameraID = 82, displayInfo = 81470, }, -- Cyril White
	[141836] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Skyrider
	[141883] = { cameraID = 141, displayInfo = 59782, }, -- Mag'har Deadeye
	[141889] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[142146] = { cameraID = 82, displayInfo = 87585, }, -- Uther the Lightbringer
	[142292] = { cameraID = 82, displayInfo = 16024, }, -- Rhonin
	[142362] = { cameraID = 82, displayInfo = 81270, }, -- Hardened Mutineer
	[142367] = { cameraID = 141, displayInfo = 4464, }, -- Kildar
	[142369] = { cameraID = 82, displayInfo = 84440, }, -- 7th Legion Sailor
	[142372] = { cameraID = 109, displayInfo = 46525, }, -- Sentinel Aeolyn
	[142373] = { cameraID = 109, displayInfo = 46523, }, -- Sentinel Falia
	[142376] = { cameraID = 109, displayInfo = 1717, }, -- Leora
	[142377] = { cameraID = 82, displayInfo = 66991, }, -- Twilight Bladetwister
	[142379] = { cameraID = 82, displayInfo = 66979, }, -- Twilight Shadowcaster
	[142383] = { cameraID = 795, displayInfo = 66246, }, -- Nightborne Warpcasters
	[142384] = { cameraID = 126, displayInfo = 63943, }, -- Highmountain Warbraves
	[142386] = { cameraID = 90, displayInfo = 70954, }, -- Dark Iron Shadowcasters
	[142427] = { cameraID = 90, displayInfo = 87644, }, -- Thorgen Grimwatt
	[142484] = { cameraID = 82, displayInfo = 85767, }, -- 7th Legion Marine
	[142489] = { cameraID = 82, displayInfo = 81351, }, -- Vigil Hill Mercenary
	[142491] = { cameraID = 82, displayInfo = 76992, }, -- Waycrest Captain
	[142637] = { cameraID = 82, displayInfo = 83030, }, -- Master Gunner Line
	[142795] = { cameraID = 82, displayInfo = 79064, }, -- Whale's Belly Patron
	[142876] = { cameraID = 82, displayInfo = 79091, }, -- Irontide Trickshot
	[142893] = { cameraID = 82, displayInfo = 88692, }, -- Ranger Peppers
	[142897] = { cameraID = 82, displayInfo = 88199, }, -- Rodney
	[143382] = { cameraID = 82, displayInfo = 85758, }, -- Halford Wyrmbane
	[143383] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[143389] = { cameraID = 82, displayInfo = 73844, }, -- John J. Keeshan
	[143395] = { cameraID = 82, displayInfo = 81826, }, -- Warren Ashton
	[143425] = { cameraID = 86, displayInfo = 87839, }, -- Echo of Garrosh Hellscream
	[143466] = { cameraID = 141, displayInfo = 84545, }, -- Darkspear Hunter
	[143467] = { cameraID = 126, displayInfo = 86646, }, -- Darkspear Hunter
	[143589] = { cameraID = 82, displayInfo = 76670, }, -- Marshal Everit Reade
	[143636] = { cameraID = 82, displayInfo = 85495, }, -- Fogsail Pirate
	[143773] = { cameraID = 82, displayInfo = 4834, }, -- Theramore Citizen
	[143789] = { cameraID = 109, displayInfo = 2306, }, -- Darnassian Archer
	[143893] = { cameraID = 90, displayInfo = 85574, }, -- Master Engineer Hafren
	[143973] = { cameraID = 82, displayInfo = 39048, }, -- Alliance Bodyguard
	[143977] = { cameraID = 141, displayInfo = 78314, }, -- Orgrimmar Grunt
	[143981] = { cameraID = 109, displayInfo = 2306, }, -- Darnassus Sentinel
	[144031] = { cameraID = 141, displayInfo = 58928, }, -- Honorbound Sniper
	[144032] = { cameraID = 130, displayInfo = 87199, }, -- Honorbound Elites
	[144037] = { cameraID = 82, displayInfo = 47144, }, -- 7th Legion Champions
	[144117] = { cameraID = 90, displayInfo = 14666, }, -- Lokhtos Darkbargainer
	[144120] = { cameraID = 90, displayInfo = 5648, }, -- Onin MacHammar
	[144125] = { cameraID = 90, displayInfo = 8798, }, -- Shadowforge Citizen
	[144126] = { cameraID = 90, displayInfo = 8678, }, -- Guzzling Patron
	[144127] = { cameraID = 90, displayInfo = 8673, }, -- Grim Patron
	[144128] = { cameraID = 90, displayInfo = 21826, }, -- Dark Iron Brewer
	[144131] = { cameraID = 90, displayInfo = 8654, }, -- Private Rocknot
	[144134] = { cameraID = 90, displayInfo = 8793, }, -- Shadowforge Peasant
	[144150] = { cameraID = 84, displayInfo = 88316, }, -- Jaina Proudmoore
	[144163] = { cameraID = 90, displayInfo = 8681, }, -- Hammered Patron
	[144166] = { cameraID = 82, displayInfo = 78046, }, -- Fallhaven Villager
	[144185] = { cameraID = 109, displayInfo = 2306, }, -- Darnassus Sentinel
	[144201] = { cameraID = 126, displayInfo = 84591, }, -- Thunder Bluff Shaman
	[144241] = { cameraID = 82, displayInfo = 81729, }, -- Commander Kellam
	[144247] = { cameraID = 82, displayInfo = 78623, }, -- Outrigger Hunter
	[144250] = { cameraID = 82, displayInfo = 78623, }, -- Anglepoint Fisherman
	[144330] = { cameraID = 82, displayInfo = 85466, }, -- Awakened Conscript
	[144343] = { cameraID = 82, displayInfo = 78518, }, -- Brennadam Citizen
	[144348] = { cameraID = 82, displayInfo = 85582, }, -- Ashvane Jailer
	[144376] = { cameraID = 82, displayInfo = 52400, }, -- Tol Dagor Inmate
	[144382] = { cameraID = 82, displayInfo = 73176, }, -- Knight-Captain Emery
	[144431] = { cameraID = 141, displayInfo = 82967, }, -- Orgrimmar Grunt
	[144688] = { cameraID = 82, displayInfo = 88798, }, -- Phillip Carter Tracey
	[144743] = { cameraID = 82, displayInfo = 64696, }, -- Marcus
	[144860] = { cameraID = 813, displayInfo = 65183, }, -- Sira Moonwarden
	[145054] = { cameraID = 575, displayInfo = 88958, }, -- Malfurion Stormrage
	[145173] = { cameraID = 82, displayInfo = 21706, }, -- Samir
	[145174] = { cameraID = 82, displayInfo = 32235, }, -- Mack
	[145175] = { cameraID = 82, displayInfo = 21702, }, -- Budd
	[145227] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[145258] = { cameraID = 141, displayInfo = 21620, }, -- Turgore
	[145367] = { cameraID = 90, displayInfo = 21970, }, -- Harkor
	[145427] = { cameraID = 141, displayInfo = 89091, }, -- Horde Berserker
	[145747] = { cameraID = 82, displayInfo = 35779, }, -- Menacing Emissary
	[145748] = { cameraID = 82, displayInfo = 35778, }, -- Menacing Emissary
	[145876] = { cameraID = 82, displayInfo = 22354, }, -- Harrison Jones
	[145931] = { cameraID = 90, displayInfo = 26353, }, -- Brann Bronzebeard
	[145993] = { cameraID = 82, displayInfo = 88653, }, -- Tandred Proudmoore
	[146007] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[146307] = { cameraID = 109, displayInfo = 89902, }, -- Kaldorei Sentinel
	[146339] = { cameraID = 82, displayInfo = 34891, }, -- Burly Sea Trooper
	[146360] = { cameraID = 82, displayInfo = 35366, }, -- Unconscious Trooper
	[146403] = { cameraID = 1208, displayInfo = 89310, }, -- Xal'atath
	[146441] = { cameraID = 82, displayInfo = 89217, }, -- Footman
	[146523] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[146592] = { cameraID = 82, displayInfo = 36073, }, -- Schnottz Elite Trooper Corpse
	[146609] = { cameraID = 82, displayInfo = 14395, }, -- Highlord Demitrian
	[146753] = { cameraID = 82, displayInfo = 86025, }, -- Kul Tiran Marine
	[146761] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[146815] = { cameraID = 82, displayInfo = 36049, }, -- Schnottz Officer
	[146915] = { cameraID = 90, displayInfo = 87726, }, -- Falstad Wildhammer
	[147028] = { cameraID = 141, displayInfo = 89499, }, -- Trueshot Marksman
	[147066] = { cameraID = 141, displayInfo = 89545, }, -- Horde Berserker
	[147153] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[147415] = { cameraID = 82, displayInfo = 87371, }, -- Soldier
	[147488] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[147539] = { cameraID = 82, displayInfo = 89731, }, -- Foundry Worker
	[147565] = { cameraID = 109, displayInfo = 89902, }, -- Sentinel
	[147570] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[147630] = { cameraID = 82, displayInfo = 75910, }, -- Greyguard
	[147820] = { cameraID = 82, displayInfo = 82545, }, -- Kul Tiran Noble
	[147857] = { cameraID = 82, displayInfo = 88346, }, -- Cannonmaster Arlin
	[147858] = { cameraID = 82, displayInfo = 88344, }, -- Shipless Jimmy
	[147877] = { cameraID = 82, displayInfo = 89461, }, -- Grand Master Ulrich
	[147889] = { cameraID = 120, displayInfo = 85856, }, -- Dark Ranger Alina
	[148001] = { cameraID = 109, displayInfo = 88840, }, -- Kaldorei Huntress
	[148162] = { cameraID = 109, displayInfo = 89378, }, -- Kaldorei Sentinel
	[148179] = { cameraID = 141, displayInfo = 59634, }, -- Warbound Raider
	[148310] = { cameraID = 82, displayInfo = 86025, }, -- Carter Riptide
	[148311] = { cameraID = 82, displayInfo = 86026, }, -- Edward Nash
	[148469] = { cameraID = 141, displayInfo = 89499, }, -- Honorbound Skytearer
	[148587] = { cameraID = 82, displayInfo = 86026, }, -- Edward Nash
	[148775] = { cameraID = 120, displayInfo = 85856, }, -- Dark Ranger
	[148928] = { cameraID = 82, displayInfo = 86025, }, -- Kul Tiran Marine
	[148952] = { cameraID = 90, displayInfo = 86142, }, -- 7th Legion Rifleman
	[149125] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[149330] = { cameraID = 109, displayInfo = 90268, }, -- Nightwreathed Priestess
	[149332] = { cameraID = 109, displayInfo = 89378, }, -- Nightwreathed Sentinel
	[149369] = { cameraID = 109, displayInfo = 88840, }, -- Nightwreathed Huntress
	[149423] = { cameraID = 105, displayInfo = 33840, }, -- Celestine of the Harvest
	[149428] = { cameraID = 109, displayInfo = 88955, }, -- Sentinel Cordressa Briarbow
	[149429] = { cameraID = 109, displayInfo = 88953, }, -- Moon Priestess Lasara
	[149488] = { cameraID = 109, displayInfo = 88837, }, -- Kaldorei Archer
	[149490] = { cameraID = 109, displayInfo = 88840, }, -- Kaldorei Hunter
	[149491] = { cameraID = 109, displayInfo = 88827, }, -- Kaldorei Sentinel
	[149492] = { cameraID = 82, displayInfo = 89217, }, -- Gilnean Footman
	[149493] = { cameraID = 82, displayInfo = 89224, }, -- Gilnean Musketeer
	[149496] = { cameraID = 130, displayInfo = 88848, }, -- Forsaken Alchemist
	[149497] = { cameraID = 130, displayInfo = 88838, }, -- Forsaken Deadshot
	[149498] = { cameraID = 130, displayInfo = 88839, }, -- Forsaken Deathguard
	[149499] = { cameraID = 130, displayInfo = 88845, }, -- Forsaken Lancer
	[149699] = { cameraID = 141, displayInfo = 85151, }, -- Orc Warrior
	[149701] = { cameraID = 141, displayInfo = 90041, }, -- Orc Noobie
	[149745] = { cameraID = 1208, displayInfo = 88826, }, -- Xal'atath
	[149824] = { cameraID = 90, displayInfo = 26353, }, -- Brann Bronzebeard
	[149898] = { cameraID = 90, displayInfo = 91995, }, -- Bjorn Stouthands
	[150183] = { cameraID = 793, displayInfo = 90666, }, -- Image of Chief Telemancer Oculeth
	[150326] = { cameraID = 120, displayInfo = 85924, }, -- Lady Liadrin
	[150334] = { cameraID = 82, displayInfo = 80052, }, -- Outrigger Hunter
	[150650] = { cameraID = 105, displayInfo = 72537, }, -- Black Harvest Acolytes
	[150656] = { cameraID = 82, displayInfo = 90832, }, -- Warrior
	[150657] = { cameraID = 82, displayInfo = 90833, }, -- Warrior
	[150658] = { cameraID = 82, displayInfo = 90835, }, -- Rogue
	[150659] = { cameraID = 82, displayInfo = 90836, }, -- Priest
	[150660] = { cameraID = 82, displayInfo = 90837, }, -- Paladin
	[150661] = { cameraID = 82, displayInfo = 90838, }, -- Monk
	[150662] = { cameraID = 82, displayInfo = 90839, }, -- Mage
	[150663] = { cameraID = 82, displayInfo = 90840, }, -- Hunter
	[150677] = { cameraID = 130, displayInfo = 86536, }, -- Thomas Zelling
	[150798] = { cameraID = 82, displayInfo = 81302, }, -- Brother Pike
	[150803] = { cameraID = 130, displayInfo = 22632, }, -- Deathstalker Rotbreath
	[150869] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Brigand
	[150930] = { cameraID = 120, displayInfo = 90077, }, -- Dark Ranger Velonara
	[151105] = { cameraID = 82, displayInfo = 83301, }, -- Tidesage Doomspeaker
	[151117] = { cameraID = 105, displayInfo = 65532, }, -- Celestine of the Harvest
	[151210] = { cameraID = 82, displayInfo = 88262, }, -- Tradewinds Dockworker
	[151223] = { cameraID = 82, displayInfo = 84385, }, -- Ashvane Prisoner
	[151260] = { cameraID = 82, displayInfo = 78962, }, -- Concerned Citizen
	[151264] = { cameraID = 141, displayInfo = 84218, }, -- Seasoned Hunter
	[151265] = { cameraID = 141, displayInfo = 84222, }, -- Hardened Grunt
	[151268] = { cameraID = 130, displayInfo = 84396, }, -- Deathguard Shocktrooper
	[152184] = { cameraID = 141, displayInfo = 4259, }, -- Orgrimmar Grunt
	[152316] = { cameraID = 795, displayInfo = 91408, }, -- Image of Thalyssra
	[152333] = { cameraID = 120, displayInfo = 70830, }, -- Dark Ranger Lenara
	[152530] = { cameraID = 141, displayInfo = 81646, }, -- Baine Bloodhoof
	[152538] = { cameraID = 120, displayInfo = 90077, }, -- Dark Ranger Zanra
	[152594] = { cameraID = 1577, displayInfo = 93583, }, -- Broker Ve'ken
	[152729] = { cameraID = 109, displayInfo = 91569, }, -- Moon Priestess Liara
	[152908] = { cameraID = 141, displayInfo = 9133, }, -- Grunt Grimful
	[152909] = { cameraID = 141, displayInfo = 8000, }, -- Grunt Wabang
	[153035] = { cameraID = 141, displayInfo = 91670, }, -- Orc Berserker
	[153038] = { cameraID = 82, displayInfo = 89554, }, -- Alliance Warrior
	[153153] = { cameraID = 90, displayInfo = 90555, }, -- Archaeo-Tinkologist
	[153164] = { cameraID = 90, displayInfo = 78970, }, -- Trap
	[153210] = { cameraID = 82, displayInfo = 89554, }, -- Injured Soldier
	[153214] = { cameraID = 82, displayInfo = 89554, }, -- Recovered Soldier
	[153223] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[153279] = { cameraID = 82, displayInfo = 89554, }, -- Alliance Scout
	[153281] = { cameraID = 90, displayInfo = 86319, }, -- Scout Blackstone
	[153282] = { cameraID = 109, displayInfo = 89877, }, -- Scout Greenfen
	[153316] = { cameraID = 90, displayInfo = 97415, }, -- Bjorn Stouthands
	[153328] = { cameraID = 90, displayInfo = 78970, }, -- Trap Trigger
	[153562] = { cameraID = 90, displayInfo = 78970, }, -- Chest Trap Trigger
	[153565] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[153677] = { cameraID = 109, displayInfo = 91239, }, -- Merithra of the Dream
	[154021] = { cameraID = 120, displayInfo = 86752, }, -- Lady Zantessa
	[154149] = { cameraID = 141, displayInfo = 1387, }, -- Karolek
	[154157] = { cameraID = 141, displayInfo = 4386, }, -- Thund
	[154255] = { cameraID = 82, displayInfo = 89554, }, -- Alliance Warrior
	[154262] = { cameraID = 141, displayInfo = 91670, }, -- Horde Warrior
	[154300] = { cameraID = 90, displayInfo = 91995, }, -- Bjorn Stouthands
	[154341] = { cameraID = 141, displayInfo = 4259, }, -- Orgrimmar Grunt
	[154379] = { cameraID = 126, displayInfo = 2141, }, -- Orgrimmar Brave
	[154459] = { cameraID = 141, displayInfo = 82335, }, -- Horde Vanguard
	[154466] = { cameraID = 84, displayInfo = 87892, }, -- Jaina Proudmoore
	[154581] = { cameraID = 795, displayInfo = 67345, }, -- Nightborne Arcanist
	[154735] = { cameraID = 82, displayInfo = 30277, }, -- Scourgelord Tyrannus
	[154809] = { cameraID = 82, displayInfo = 34294, }, -- 7th Legion Guardsman
	[154866] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[154995] = { cameraID = 126, displayInfo = 34113, }, -- Rento
	[154996] = { cameraID = 126, displayInfo = 34111, }, -- Lonto
	[154999] = { cameraID = 126, displayInfo = 34107, }, -- Owato
	[155001] = { cameraID = 126, displayInfo = 34045, }, -- Nahu Ragehoof
	[155002] = { cameraID = 126, displayInfo = 34059, }, -- Nohi Plainswalker
	[155005] = { cameraID = 141, displayInfo = 1366, }, -- Godan
	[155117] = { cameraID = 130, displayInfo = 81785, }, -- Cutthroat Crew
	[155121] = { cameraID = 90, displayInfo = 21798, }, -- 7th Legion Cannoneer
	[155123] = { cameraID = 82, displayInfo = 26997, }, -- 7th Legion Marine
	[155147] = { cameraID = 105, displayInfo = 68561, }, -- Captain Razorclaw
	[155152] = { cameraID = 141, displayInfo = 89216, }, -- Captain Holgresh
	[155161] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[155163] = { cameraID = 141, displayInfo = 91670, }, -- Orc Wolf Rider
	[155326] = { cameraID = 109, displayInfo = 87626, }, -- Fellyia Wildsong
	[155327] = { cameraID = 109, displayInfo = 84614, }, -- 7th Legion Scout
	[155413] = { cameraID = 82, displayInfo = 10669, }, -- Postmaster Malown
	[155414] = { cameraID = 130, displayInfo = 10475, }, -- Ezra Grimm
	[155463] = { cameraID = 120, displayInfo = 91665, }, -- Elite Battlemage
	[155486] = { cameraID = 141, displayInfo = 99814, }, -- Gotri
	[155781] = { cameraID = 84, displayInfo = 80015, }, -- Jaina Proudmoore
	[155786] = { cameraID = 109, displayInfo = 93248, }, -- Varok Saurfang
	[155929] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[156025] = { cameraID = 90, displayInfo = 90555, }, -- Archaeo-Tinkologist
	[156027] = { cameraID = 82, displayInfo = 92590, }, -- Warrior
	[156032] = { cameraID = 109, displayInfo = 92593, }, -- Rogue
	[156180] = { cameraID = 109, displayInfo = 93468, }, -- Varok Saurfang
	[156280] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[156332] = { cameraID = 109, displayInfo = 12914, }, -- Ashenvale Assailant
	[156337] = { cameraID = 126, displayInfo = 65478, }, -- Highmountain Warrior
	[156342] = { cameraID = 82, displayInfo = 32020, }, -- Captain Taylor
	[156343] = { cameraID = 141, displayInfo = 32576, }, -- Legionnaire Nazgrim
	[156348] = { cameraID = 268, displayInfo = 30408, }, -- Erunak Stonespeaker
	[156697] = { cameraID = 126, displayInfo = 2141, }, -- Orgrimmar Brave
	[156801] = { cameraID = 82, displayInfo = 94939, }, -- Private Cole
	[156932] = { cameraID = 109, displayInfo = 91010, }, -- Ralia Dreamchaser
	[156935] = { cameraID = 82, displayInfo = 89752, }, -- 7th Legion Sergeant
	[157020] = { cameraID = 141, displayInfo = 4259, }, -- Orgrimmar Grunt
	[157040] = { cameraID = 84, displayInfo = 67214, }, -- Valeera Sanguinar
	[157049] = { cameraID = 82, displayInfo = 22661, }, -- Helmsman Lenard
	[157128] = { cameraID = 120, displayInfo = 85924, }, -- Liadrin
	[157129] = { cameraID = 141, displayInfo = 27336, }, -- Sky-Reaver Korm Blackscar
	[157544] = { cameraID = 141, displayInfo = 4384, }, -- Snang
	[157647] = { cameraID = 120, displayInfo = 93211, }, -- Heroic Onlookers
	[157723] = { cameraID = 109, displayInfo = 93248, }, -- Varok Saurfang
	[158176] = { cameraID = 120, displayInfo = 85924, }, -- Lady Liadrin
	[158313] = { cameraID = 82, displayInfo = 10535, }, -- Deatholme Acolyte
	[159004] = { cameraID = 141, displayInfo = 4261, }, -- Mor'shan Watchman
	[159064] = { cameraID = 90, displayInfo = 47399, }, -- Darkmoon Arcade
	[159422] = { cameraID = 141, displayInfo = 4259, }, -- Dead Civilian
	[159557] = { cameraID = 141, displayInfo = 4261, }, -- Mor'shan Watchman
	[160209] = { cameraID = 126, displayInfo = 94609, }, -- Horu Cloudwatcher
	[160635] = { cameraID = 90, displayInfo = 47399, }, -- Ice Stalker
	[160804] = { cameraID = 82, displayInfo = 94395, }, -- Prisoner
	[160964] = { cameraID = 82, displayInfo = 70300, }, -- Freed Expedition Member
	[161706] = { cameraID = 141, displayInfo = 70436, }, -- Nazgrim
	[161707] = { cameraID = 82, displayInfo = 70807, }, -- King Thoras Trollbane
	[161709] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[161711] = { cameraID = 82, displayInfo = 63575, }, -- Knight of the Ebon Blade
	[161777] = { cameraID = 141, displayInfo = 1375, }, -- Sorek
	[161988] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[162090] = { cameraID = 82, displayInfo = 92196, }, -- Arik Scorpidsting
	[162095] = { cameraID = 82, displayInfo = 92195, }, -- Wastewander Warrior
	[162217] = { cameraID = 90, displayInfo = 62751, }, -- Muradin Bronzebeard
	[162769] = { cameraID = 82, displayInfo = 63575, }, -- Knight of the Ebon Blade
	[162770] = { cameraID = 141, displayInfo = 63576, }, -- Knight of the Ebon Blade
	[162775] = { cameraID = 120, displayInfo = 72259, }, -- Knight of the Ebon Blade
	[162777] = { cameraID = 90, displayInfo = 72257, }, -- Knight of the Ebon Blade
	[162784] = { cameraID = 130, displayInfo = 72260, }, -- Knight of the Ebon Blade
	[162796] = { cameraID = 1208, displayInfo = 94663, }, -- Knight of the Ebon Blade
	[162970] = { cameraID = 82, displayInfo = 95033, }, -- Coulston Nereus
	[162972] = { cameraID = 82, displayInfo = 95034, }, -- Coulston Nereus
	[163137] = { cameraID = 82, displayInfo = 99178, }, -- First Expedition Recruit
	[163167] = { cameraID = 82, displayInfo = 70297, }, -- Expedition Recruit
	[163344] = { cameraID = 82, displayInfo = 95088, }, -- Stranded Spirit
	[163547] = { cameraID = 120, displayInfo = 78165, }, -- Silvermoon Sorceress (Contracted)
	[164079] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[164537] = { cameraID = 109, displayInfo = 95486, }, -- Night Elf Soul
	[164810] = { cameraID = 1577, displayInfo = 93584, }, -- Xil'azan
	[165143] = { cameraID = 141, displayInfo = 7889, }, -- Kadrak
	[165537] = { cameraID = 109, displayInfo = 11046, }, -- Eli the Brazen
	[165562] = { cameraID = 109, displayInfo = 11046, }, -- Anjali
	[165918] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[166776] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[167021] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[167179] = { cameraID = 120, displayInfo = 96418, }, -- Daelya Twilightsbane
	[167216] = { cameraID = 141, displayInfo = 91670, }, -- Grunt Throg
	[167244] = { cameraID = 141, displayInfo = 72784, }, -- Freed Expedition Member
	[167523] = { cameraID = 141, displayInfo = 96493, }, -- Stranded Spirit
	[167592] = { cameraID = 141, displayInfo = 99182, }, -- First Expedition Recruit
	[167621] = { cameraID = 1079, displayInfo = 94123, }, -- Uther
	[167670] = { cameraID = 141, displayInfo = 89545, }, -- Bruk'tor
	[167672] = { cameraID = 130, displayInfo = 96419, }, -- Herbert Gloomburst
	[167673] = { cameraID = 126, displayInfo = 96420, }, -- Warlord Mulgrin Thunderwalker
	[167886] = { cameraID = 82, displayInfo = 89859, }, -- Alliance Sailor
	[168162] = { cameraID = 141, displayInfo = 81646, }, -- Baine Bloodhoof
	[168340] = { cameraID = 82, displayInfo = 96801, }, -- Defiled Engineer
	[168419] = { cameraID = 82, displayInfo = 96013, }, -- Zealous Neophyte
	[168570] = { cameraID = 109, displayInfo = 3445, }, -- Tannysa
	[168608] = { cameraID = 90, displayInfo = 7383, }, -- Harggan
	[168611] = { cameraID = 109, displayInfo = 95596, }, -- Amaria Wildthorn
	[168649] = { cameraID = 105, displayInfo = 83350, }, -- Worgen Battlemage
	[170257] = { cameraID = 1577, displayInfo = 93583, }, -- Broker Ve'nott
	[170535] = { cameraID = 141, displayInfo = 25423, }, -- Death Knight Mage
	[170536] = { cameraID = 82, displayInfo = 25375, }, -- Death Knight Mage
	[170841] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[170904] = { cameraID = 90, displayInfo = 78970, }, -- Resonating Chest
	[171280] = { cameraID = 109, displayInfo = 97529, }, -- Night Elf Soul
	[171357] = { cameraID = 82, displayInfo = 87371, }, -- Stormwind Infantry
	[171359] = { cameraID = 82, displayInfo = 87371, }, -- Stormwind Infantry Captain
	[171435] = { cameraID = 90, displayInfo = 78970, }, -- Chains
	[171933] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[172181] = { cameraID = 126, displayInfo = 64797, }, -- Gamon
	[172201] = { cameraID = 126, displayInfo = 49770, }, -- Thunder Bluff Protector
	[172855] = { cameraID = 1577, displayInfo = 93583, }, -- Broker Ve'test
	[173147] = { cameraID = 84, displayInfo = 96935, }, -- Sylvanas Windrunner
	[173252] = { cameraID = 84, displayInfo = 80015, }, -- Lady Jaina Proudmoore
	[173364] = { cameraID = 1577, displayInfo = 99382, }, -- Security Specialist
	[173980] = { cameraID = 119, displayInfo = 94481, }, -- Kael'thas Sunstrider
	[174594] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[174852] = { cameraID = 82, displayInfo = 96328, }, -- Knight of the Ebon Blade
	[175137] = { cameraID = 82, displayInfo = 100074, }, -- High Exarch Turalyon
	[175332] = { cameraID = 141, displayInfo = 99518, }, -- Baine Bloodhoof
	[175578] = { cameraID = 82, displayInfo = 61582, }, -- Croman
	[175680] = { cameraID = 1577, displayInfo = 93578, }, -- Clandestine Operative
	[180175] = { cameraID = 1079, displayInfo = 101844, }, -- Uther
	[175909] = { cameraID = 1577, displayInfo = 100013, }, -- Ve'brax
	[176361] = { cameraID = 1079, displayInfo = 100392, }, -- Uther
	[176532] = { cameraID = 109, displayInfo = 101963, }, -- Thrall
	[176533] = { cameraID = 84, displayInfo = 101962, }, -- Lady Jaina Proudmoore
	[176740] = { cameraID = 82, displayInfo = 14890, }, -- Darkmoon Carnie
	[177112] = { cameraID = 1079, displayInfo = 101844, }, -- Uther the Lightbringer
	[177114] = { cameraID = 84, displayInfo = 95032, }, -- Sylvanas Windrunner
	[177191] = { cameraID = 625, displayInfo = 66682, }, -- Claws of Ursoc - Alt 1 - Base - Generic
	[177704] = { cameraID = 1577, displayInfo = 93599, }, -- Conflict Assessor
	[177705] = { cameraID = 1577, displayInfo = 93599, }, -- Military Purveyor
	[177774] = { cameraID = 1577, displayInfo = 95004, }, -- Ve'nari
	[177921] = { cameraID = 82, displayInfo = 100555, }, -- Korthian Protector
	[178081] = { cameraID = 82, displayInfo = 101964, }, -- Highlord Bolvar Fordragon
	[178184] = { cameraID = 82, displayInfo = 3167, }, -- Stormwind Guard
	[178186] = { cameraID = 82, displayInfo = 31604, }, -- Captain Taylor
	[178293] = { cameraID = 82, displayInfo = 83127, }, -- Mosher
	[178399] = { cameraID = 84, displayInfo = 100591, }, -- Sylvanas Windrunner
	[178652] = { cameraID = 109, displayInfo = 99128, }, -- Shandris Feathermoon
	[178689] = { cameraID = 82, displayInfo = 100760, }, -- Protector Kah-Rev
	[178922] = { cameraID = 86, displayInfo = 87839, }, -- Garrosh Hellscream
	[179151] = { cameraID = 109, displayInfo = 100684, }, -- Thrall
	[179213] = { cameraID = 84, displayInfo = 80015, }, -- Lady Jaina Proudmoore
	[179225] = { cameraID = 109, displayInfo = 100684, }, -- Thrall
	[179297] = { cameraID = 126, displayInfo = 65107, }, -- Rantuko Grimtouch
	[179321] = { cameraID = 120, displayInfo = 28039, }, -- Duchess Mynx
	[179520] = { cameraID = 1577, displayInfo = 93583, }, -- Broker Ve'kot
	[179598] = { cameraID = 1577, displayInfo = 101355, }, -- Ve'nish
	[179620] = { cameraID = 126, displayInfo = 97408, }, -- Huln Highmountain
	[179910] = { cameraID = 84, displayInfo = 101311, }, -- Sylvanas Windrunner
	[180102] = { cameraID = 82, displayInfo = 94902, }, -- Ben Howell
	[180114] = { cameraID = 1577, displayInfo = 93583, }, -- Fruit Vendor
	[180117] = { cameraID = 1577, displayInfo = 93594, }, -- Meat Vendor
	[180129] = { cameraID = 1577, displayInfo = 93579, }, -- Toy Vendor
	[180130] = { cameraID = 1577, displayInfo = 93587, }, -- Antique Vendor
	[180218] = { cameraID = 84, displayInfo = 101311, }, -- Sylvanas Windrunner
	[180271] = { cameraID = 1577, displayInfo = 100872, }, -- Customs Shiftdodger
	[180272] = { cameraID = 1577, displayInfo = 100871, }, -- Security Specialist
	[180273] = { cameraID = 1577, displayInfo = 100873, }, -- Security Trainee
	[180274] = { cameraID = 1577, displayInfo = 93578, }, -- Bazaar Strongarm
	[180275] = { cameraID = 1577, displayInfo = 100874, }, -- Armored Overseer
	[180276] = { cameraID = 1577, displayInfo = 100876, }, -- Support Officer
	[180277] = { cameraID = 1577, displayInfo = 101542, }, -- Unruly Patron
	[180278] = { cameraID = 1577, displayInfo = 101543, }, -- Unruly Patron
	[180282] = { cameraID = 1577, displayInfo = 100877, }, -- Interrogation Specialist
	[180287] = { cameraID = 82, displayInfo = 101464, }, -- Corsair Scallywag
	[180288] = { cameraID = 82, displayInfo = 101459, }, -- Corsair Cannoneer
	[180733] = { cameraID = 1079, displayInfo = 100392, }, -- Uther
	[181055] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[181056] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[181097] = { cameraID = 82, displayInfo = 102044, }, -- Simon Sezdans
	[181127] = { cameraID = 82, displayInfo = 83127, }, -- Dance Enthusiast
	[181152] = { cameraID = 130, displayInfo = 102098, }, -- Jason Trost
	[181154] = { cameraID = 126, displayInfo = 102100, }, -- Haun Fleethoof
	[181156] = { cameraID = 90, displayInfo = 102103, }, -- Colum Bootbright
	[181159] = { cameraID = 109, displayInfo = 102087, }, -- Raith
	[181160] = { cameraID = 82, displayInfo = 102106, }, -- Anthony Volt
	[181162] = { cameraID = 120, displayInfo = 102109, }, -- Ginger Brightstep
	[181228] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[181232] = { cameraID = 109, displayInfo = 104820, }, -- Thrall
	[181378] = { cameraID = 126, displayInfo = 106792, }, -- Kurog Grimtotem
	[181494] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[181541] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[181597] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[181948] = { cameraID = 82, displayInfo = 105586, }, -- Highlord Bolvar Fordragon
	[182170] = { cameraID = 146, displayInfo = 102136, }, -- Dracthyr Talon
	[182349] = { cameraID = 146, displayInfo = 104834, }, -- Injured Talon
	[182611] = { cameraID = 146, displayInfo = 104904, }, -- Scalecommander Sarkareth
	[182878] = { cameraID = 1079, displayInfo = 105509, }, -- Uther the Lightbringer
	[183517] = { cameraID = 130, displayInfo = 69306, }, -- Boulder
	[183547] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[183549] = { cameraID = 146, displayInfo = 104839, }, -- Dark Talon
	[183550] = { cameraID = 146, displayInfo = 104727, }, -- Ebon Scale
	[183551] = { cameraID = 146, displayInfo = 104834, }, -- Talon Mender
	[183556] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[192110] = { cameraID = 120, displayInfo = 107704, }, -- Narsysix
	[183607] = { cameraID = 82, displayInfo = 96328, }, -- Knight of the Ebon Blade
	[183665] = { cameraID = 1079, displayInfo = 105509, }, -- Uther the Lightbringer
	[183794] = { cameraID = 146, displayInfo = 104726, }, -- Mage Talon
	[183821] = { cameraID = 146, displayInfo = 104861, }, -- Siaszerathel
	[183831] = { cameraID = 141, displayInfo = 13370, }, -- Great-father Winter
	[183860] = { cameraID = 120, displayInfo = 108314, }, -- Soridormi
	[183880] = { cameraID = 82, displayInfo = 95660, }, -- Attendant Protector
	[183887] = { cameraID = 109, displayInfo = 97529, }, -- Angry Soul
	[183922] = { cameraID = 82, displayInfo = 99389, }, -- Stormwind Footsoldier
	[183960] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[184283] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[184310] = { cameraID = 146, displayInfo = 104555, }, -- Scalecommander Viridia
	[184374] = { cameraID = 146, displayInfo = 105018, }, -- Umbrastrasz
	[184688] = { cameraID = 120, displayInfo = 104535, }, -- Sindragosa
	[184765] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[184870] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[185157] = { cameraID = 1079, displayInfo = 105509, }, -- Uther
	[185405] = { cameraID = 109, displayInfo = 105324, }, -- Niena Bladeleaf
	[185431] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[185514] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[185515] = { cameraID = 130, displayInfo = 90381, }, -- Deathstalker Commander Belmont
	[185516] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[185572] = { cameraID = 146, displayInfo = 105401, }, -- Vekkalis
	[185599] = { cameraID = 82, displayInfo = 105421, }, -- Masud the Wise
	[185845] = { cameraID = 105, displayInfo = 96331, }, -- Knight of the Ebon Blade
	[185876] = { cameraID = 146, displayInfo = 104834, }, -- Containment Field
	[185915] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[186092] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[186093] = { cameraID = 130, displayInfo = 90381, }, -- Deathstalker Commander Belmont
	[186094] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[186188] = { cameraID = 120, displayInfo = 104535, }, -- Sindragosa
	[186389] = { cameraID = 109, displayInfo = 105741, }, -- Night Elf Soul
	[186688] = { cameraID = 82, displayInfo = 106239, }, -- Archmage Khadgar
	[186743] = { cameraID = 120, displayInfo = 105843, }, -- Elynae Dawnbreaker
	[186747] = { cameraID = 120, displayInfo = 105847, }, -- Lialyn Summersong
	[187136] = { cameraID = 130, displayInfo = 106063, }, -- Examiner Rowe
	[187156] = { cameraID = 120, displayInfo = 106065, }, -- Aelnara
	[187223] = { cameraID = 146, displayInfo = 104821, }, -- Kodethi
	[187354] = { cameraID = 109, displayInfo = 33363, }, -- Night Elf Soul
	[187368] = { cameraID = 109, displayInfo = 36681, }, -- Night Elf Soul
	[187369] = { cameraID = 109, displayInfo = 33370, }, -- Night Elf Soul
	[187370] = { cameraID = 109, displayInfo = 33369, }, -- Night Elf Soul
	[187375] = { cameraID = 109, displayInfo = 74951, }, -- Night Elf Soul
	[187376] = { cameraID = 109, displayInfo = 2231, }, -- Night Elf Soul
	[187377] = { cameraID = 109, displayInfo = 7123, }, -- Night Elf Soul
	[187380] = { cameraID = 109, displayInfo = 2212, }, -- Night Elf Soul
	[187381] = { cameraID = 109, displayInfo = 2218, }, -- Night Elf Soul
	[187590] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[187718] = { cameraID = 82, displayInfo = 106239, }, -- Archmage Khadgar
	[187720] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[188201] = { cameraID = 146, displayInfo = 104834, }, -- Healing Wing
	[189324] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[189330] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[189386] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[189509] = { cameraID = 126, displayInfo = 108627, }, -- Primalist Ideologue
	[189518] = { cameraID = 109, displayInfo = 107111, }, -- Koroleth
	[189599] = { cameraID = 109, displayInfo = 91239, }, -- Merithra
	[190494] = { cameraID = 146, displayInfo = 104841, }, -- Dracthyr Talon
	[190529] = { cameraID = 146, displayInfo = 104834, }, -- Tactical Mender
	[190740] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[191205] = { cameraID = 90, displayInfo = 107387, }, -- Hemet Nesingwary
	[191504] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[192310] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[192355] = { cameraID = 146, displayInfo = 104841, }, -- Dark Talon
	[192403] = { cameraID = 120, displayInfo = 106009, }, -- Soridormi
	[192535] = { cameraID = 82, displayInfo = 3167, }, -- Stormwind City Guard
	[192545] = { cameraID = 82, displayInfo = 37310, }, -- Stormwind Gryphon Rider
	[192649] = { cameraID = 575, displayInfo = 70004, }, -- Malfurion Stormrage
	[192656] = { cameraID = 126, displayInfo = 106210, }, -- Somnikus
	[192974] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[192975] = { cameraID = 146, displayInfo = 104844, }, -- Obsidian Warder
	[192976] = { cameraID = 146, displayInfo = 104846, }, -- Obsidian Warder
	[193047] = { cameraID = 141, displayInfo = 4259, }, -- Orgrimmar Grunt
	[193048] = { cameraID = 141, displayInfo = 99452, }, -- Orgrimmar Grunt
	[193055] = { cameraID = 146, displayInfo = 104841, }, -- Dark Talon
	[193056] = { cameraID = 146, displayInfo = 104842, }, -- Dark Talon
	[193057] = { cameraID = 146, displayInfo = 104839, }, -- Dark Talon
	[193058] = { cameraID = 146, displayInfo = 104840, }, -- Dark Talon
	[193332] = { cameraID = 120, displayInfo = 107251, }, -- Vazallia
	[193878] = { cameraID = 146, displayInfo = 108356, }, -- Iristella
	[193879] = { cameraID = 146, displayInfo = 108358, }, -- Iristimat
	[194136] = { cameraID = 146, displayInfo = 108452, }, -- Eraleshk
	[194237] = { cameraID = 146, displayInfo = 108418, }, -- Malicia
	[194616] = { cameraID = 90, displayInfo = 108649, }, -- Crannog Wildhammer
	[194674] = { cameraID = 82, displayInfo = 84092, }, -- Expedition Provisioner
	[195350] = { cameraID = 146, displayInfo = 108879, }, -- Eager Freshscale
	[195589] = { cameraID = 109, displayInfo = 107111, }, -- Koroleth
	[195912] = { cameraID = 82, displayInfo = 71246, }, -- Storm Hunter William
	[196501] = { cameraID = 120, displayInfo = 106321, }, -- Alia Sunsoar
	[196633] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[196778] = { cameraID = 120, displayInfo = 106321, }, -- Alia Sunsoar
	[196804] = { cameraID = 146, displayInfo = 108356, }, -- Iristella
	[196942] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[197025] = { cameraID = 146, displayInfo = 109087, }, -- Telash Greywing
	[197201] = { cameraID = 146, displayInfo = 109424, }, -- Venderthvan
	[197304] = { cameraID = 146, displayInfo = 109503, }, -- Telash Greywing
	[197327] = { cameraID = 146, displayInfo = 109424, }, -- Vendie
	[197453] = { cameraID = 82, displayInfo = 71246, }, -- Storm Hunter William
	[197488] = { cameraID = 146, displayInfo = 104845, }, -- Obsidian Warder
	[197490] = { cameraID = 141, displayInfo = 107533, }, -- Baskilan
	[197492] = { cameraID = 82, displayInfo = 107875, }, -- Zepharion
	[197682] = { cameraID = 120, displayInfo = 81830, }, -- Enchantress Quinni
	[198158] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian & Wrathion
	[198626] = { cameraID = 90, displayInfo = 38872, }, -- Sully "The Pickle" McLeary
	[199177] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[199184] = { cameraID = 120, displayInfo = 110573, }, -- Lanigosa
	[199201] = { cameraID = 146, displayInfo = 104555, }, -- Scalecommander Viridia
	[199212] = { cameraID = 146, displayInfo = 110584, }, -- Talon Damos
	[199214] = { cameraID = 146, displayInfo = 110585, }, -- Talon Ekrati
	[199215] = { cameraID = 146, displayInfo = 110586, }, -- Talon Arrosh
	[199218] = { cameraID = 146, displayInfo = 110588, }, -- Talon Hermin
	[199244] = { cameraID = 141, displayInfo = 52910, }, -- Orgrim Doomhammer
	[199361] = { cameraID = 120, displayInfo = 111360, }, -- Kirygosa
	[199441] = { cameraID = 146, displayInfo = 104904, }, -- Scalecommander Sarkareth
	[199485] = { cameraID = 146, displayInfo = 110656, }, -- Sundered Fanatic
	[199520] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[199556] = { cameraID = 126, displayInfo = 111493, }, -- Bovan Windtotem
	[199742] = { cameraID = 146, displayInfo = 110856, }, -- Winglord Dezran
	[199761] = { cameraID = 130, displayInfo = 114139, }, -- Deathstalker Commander Belmont
	[199880] = { cameraID = 82, displayInfo = 113287, }, -- Scarlet Footsoldier
	[199965] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[200020] = { cameraID = 120, displayInfo = 19806, }, -- Haleh
	[200157] = { cameraID = 141, displayInfo = 11895, }, -- Captain Galvangar
	[200317] = { cameraID = 82, displayInfo = 110946, }, -- Duncon Ratsbon
	[200539] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[200643] = { cameraID = 141, displayInfo = 19247, }, -- Gargok
	[200645] = { cameraID = 141, displayInfo = 14812, }, -- Captain Shatterskull
	[200646] = { cameraID = 141, displayInfo = 31465, }, -- Blood Guard Torek
	[200649] = { cameraID = 141, displayInfo = 20928, }, -- Leoroxx
	[200650] = { cameraID = 141, displayInfo = 63276, }, -- High Warlord Cromush
	[200654] = { cameraID = 141, displayInfo = 20925, }, -- Rokaro
	[200655] = { cameraID = 141, displayInfo = 64946, }, -- Rehgar Earthfury
	[200659] = { cameraID = 141, displayInfo = 55629, }, -- Lantresor of the Blade
	[200662] = { cameraID = 141, displayInfo = 4514, }, -- Zor Lonetree
	[200667] = { cameraID = 141, displayInfo = 32529, }, -- Commander Thorak
	[200668] = { cameraID = 141, displayInfo = 4515, }, -- Holgar Stormaxe
	[200727] = { cameraID = 146, displayInfo = 111249, }, -- Volethi
	[200797] = { cameraID = 120, displayInfo = 110573, }, -- Lanigosa
	[201039] = { cameraID = 146, displayInfo = 108452, }, -- Injured Dracthyr
	[201065] = { cameraID = 90, displayInfo = 106900, }, -- Sonova Snowden
	[201173] = { cameraID = 126, displayInfo = 111354, }, -- Ebyssian
	[201323] = { cameraID = 141, displayInfo = 111866, }, -- Baine Bloodhoof
	[201522] = { cameraID = 126, displayInfo = 111112, }, -- Summitshaper Lorac
	[201620] = { cameraID = 109, displayInfo = 111871, }, -- Thrall
	[201621] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[202488] = { cameraID = 82, displayInfo = 110939, }, -- Defias Thief
	[202489] = { cameraID = 82, displayInfo = 110933, }, -- Defias Thief
	[202523] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[202648] = { cameraID = 82, displayInfo = 3167, }, -- Stormwind City Guard
	[202701] = { cameraID = 109, displayInfo = 112157, }, -- Arko'narin Starshade
	[202734] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[202761] = { cameraID = 146, displayInfo = 112223, }, -- Scalecommander Sarkareth
	[202762] = { cameraID = 146, displayInfo = 112222, }, -- Viridia
	[202957] = { cameraID = 82, displayInfo = 111762, }, -- Highlord Bolvar Fordragon
	[202960] = { cameraID = 82, displayInfo = 111763, }, -- Reginald Windsor
	[203078] = { cameraID = 82, displayInfo = 111795, }, -- Stormwind Merchant
	[203100] = { cameraID = 82, displayInfo = 111796, }, -- Stormwind Noble
	[203102] = { cameraID = 82, displayInfo = 111797, }, -- Town Crier
	[203106] = { cameraID = 82, displayInfo = 111798, }, -- Warren Fulton
	[203110] = { cameraID = 82, displayInfo = 111800, }, -- Scott Keenan
	[203114] = { cameraID = 82, displayInfo = 111801, }, -- Stormwind Dock Worker
	[203123] = { cameraID = 82, displayInfo = 111802, }, -- Gregory Ardus
	[203124] = { cameraID = 82, displayInfo = 111803, }, -- Kendor Kabonka
	[203129] = { cameraID = 82, displayInfo = 111806, }, -- Heinrich Stone
	[203130] = { cameraID = 82, displayInfo = 111807, }, -- Raylen Milburn
	[203131] = { cameraID = 82, displayInfo = 111808, }, -- Daniel Kinsey
	[203144] = { cameraID = 141, displayInfo = 111810, }, -- Warsong Battleguard
	[203154] = { cameraID = 141, displayInfo = 111817, }, -- Dragonmaw Guard
	[203205] = { cameraID = 82, displayInfo = 111839, }, -- Stormwind Guard
	[203314] = { cameraID = 141, displayInfo = 111901, }, -- Baine Bloodhoof
	[203315] = { cameraID = 126, displayInfo = 111902, }, -- Bovan Windtotem
	[203387] = { cameraID = 126, displayInfo = 111112, }, -- Mudleader Lorac
	[203597] = { cameraID = 146, displayInfo = 111986, }, -- Talon Damos
	[203613] = { cameraID = 146, displayInfo = 111993, }, -- Scalecommander Sarkareth
	[203637] = { cameraID = 146, displayInfo = 111935, }, -- Sundered Defender
	[204139] = { cameraID = 130, displayInfo = 113450, }, -- Royal Dreadguard
	[204287] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[204438] = { cameraID = 146, displayInfo = 104904, }, -- Vault Observation Executor
	[204450] = { cameraID = 120, displayInfo = 108314, }, -- Soridormi
	[204468] = { cameraID = 126, displayInfo = 72069, }, -- Airhorn
	[204475] = { cameraID = 120, displayInfo = 72059, }, -- Merciless Gladiator Saifu
	[204476] = { cameraID = 130, displayInfo = 72058, }, -- Vhell
	[204477] = { cameraID = 141, displayInfo = 72057, }, -- Oku
	[204480] = { cameraID = 130, displayInfo = 72054, }, -- Twirhp
	[204481] = { cameraID = 126, displayInfo = 72053, }, -- Jarud
	[204482] = { cameraID = 120, displayInfo = 72052, }, -- Wheatizzle
	[204488] = { cameraID = 126, displayInfo = 72565, }, -- Spoogledorf
	[204489] = { cameraID = 130, displayInfo = 72064, }, -- Guard
	[204490] = { cameraID = 126, displayInfo = 72046, }, -- Scarab Lord Hamlet
	[204492] = { cameraID = 130, displayInfo = 72043, }, -- Nisstyr
	[204493] = { cameraID = 141, displayInfo = 72040, }, -- Scarab Lord Ahzesh
	[204736] = { cameraID = 120, displayInfo = 112305, }, -- Sindragosa
	[204848] = { cameraID = 82, displayInfo = 112352, }, -- Sabellian
	[204849] = { cameraID = 126, displayInfo = 112353, }, -- Ebyssian
	[204947] = { cameraID = 146, displayInfo = 111693, }, -- Amythora
	[204949] = { cameraID = 146, displayInfo = 111694, }, -- Marithos
	[204953] = { cameraID = 120, displayInfo = 112435, }, -- Stellagosa
	[205145] = { cameraID = 82, displayInfo = 102044, }, -- Billy Brightly
	[205262] = { cameraID = 126, displayInfo = 112508, }, -- Ebyssian
	[205264] = { cameraID = 82, displayInfo = 112510, }, -- Sabellian
	[205280] = { cameraID = 82, displayInfo = 112516, }, -- Sabellian
	[205355] = { cameraID = 82, displayInfo = 112553, }, -- Sabellian
	[205356] = { cameraID = 126, displayInfo = 112554, }, -- Ebyssian
	[205386] = { cameraID = 146, displayInfo = 112571, }, -- Scalecommander Sarkareth
	[205389] = { cameraID = 126, displayInfo = 112568, }, -- Ebyssian
	[205391] = { cameraID = 82, displayInfo = 112569, }, -- Sabellian
	[205409] = { cameraID = 109, displayInfo = 91239, }, -- Merithra
	[205769] = { cameraID = 120, displayInfo = 108314, }, -- Soridormi
	[206017] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[206072] = { cameraID = 82, displayInfo = 19552, }, -- Nathanos Marris
	[206107] = { cameraID = 130, displayInfo = 112802, }, -- Eadweard Dalyngrigge
	[206167] = { cameraID = 82, displayInfo = 117898, }, -- Anxious Farmer
	[206168] = { cameraID = 82, displayInfo = 117896, }, -- Anxious Farmer
	[206182] = { cameraID = 126, displayInfo = 112831, }, -- Fel-Touched Shu'halo
	[206588] = { cameraID = 109, displayInfo = 113045, }, -- Belysra Starbreeze
	[206591] = { cameraID = 109, displayInfo = 113046, }, -- Priestess Alinya
	[206592] = { cameraID = 109, displayInfo = 113047, }, -- Priestess Kyleen Il'dinare
	[206849] = { cameraID = 109, displayInfo = 113795, }, -- Merithra of the Dream
	[206979] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[207266] = { cameraID = 82, displayInfo = 113204, }, -- Jimmy the Goose
	[207297] = { cameraID = 109, displayInfo = 113209, }, -- Ellemayne
	[207299] = { cameraID = 120, displayInfo = 108314, }, -- Soridormi
	[207578] = { cameraID = 82, displayInfo = 113292, }, -- Great Glorious Alliance Footman
	[207579] = { cameraID = 82, displayInfo = 113294, }, -- Great Glorious Alliance Paladin
	[207580] = { cameraID = 90, displayInfo = 113296, }, -- Great Glorious Alliance Musketeer
	[207581] = { cameraID = 82, displayInfo = 113298, }, -- Great Glorious Alliance Lieutenant
	[207582] = { cameraID = 141, displayInfo = 113301, }, -- Blood Horde Grunt
	[207583] = { cameraID = 141, displayInfo = 113303, }, -- Blood Horde Shaman
	[207586] = { cameraID = 141, displayInfo = 113309, }, -- Prisoner of War
	[207587] = { cameraID = 82, displayInfo = 113311, }, -- Prisoner of War
	[207594] = { cameraID = 120, displayInfo = 113316, }, -- High Interrogator Kilandrelle
	[207598] = { cameraID = 90, displayInfo = 113296, }, -- Great Glorious Alliance Cannoneer
	[207694] = { cameraID = 146, displayInfo = 113591, }, -- Abereth
	[207700] = { cameraID = 130, displayInfo = 113373, }, -- Forsaken Soldier
	[207702] = { cameraID = 120, displayInfo = 90536, }, -- Dark Ranger
	[207704] = { cameraID = 82, displayInfo = 113289, }, -- Scarlet Tracker
	[207707] = { cameraID = 82, displayInfo = 113326, }, -- Scarlet Confessor
	[207708] = { cameraID = 82, displayInfo = 113331, }, -- Scarlet Champion
	[207808] = { cameraID = 130, displayInfo = 113395, }, -- Rotted Gladiator
	[207816] = { cameraID = 120, displayInfo = 113423, }, -- Vereesa Windrunner
	[207818] = { cameraID = 82, displayInfo = 113411, }, -- Uther
	[207822] = { cameraID = 82, displayInfo = 113403, }, -- Lord Thassarian
	[207947] = { cameraID = 146, displayInfo = 110856, }, -- Winglord Dezran
	[208039] = { cameraID = 120, displayInfo = 114599, }, -- Dark Ranger
	[208051] = { cameraID = 90, displayInfo = 113296, }, -- Great Glorious Alliance Cannonneer
	[208098] = { cameraID = 141, displayInfo = 113301, }, -- Blood Horde Grunt
	[208100] = { cameraID = 82, displayInfo = 113487, }, -- Great Glorious Alliance Footman
	[208101] = { cameraID = 82, displayInfo = 113489, }, -- Great Glorious Alliance Paladin
	[208359] = { cameraID = 146, displayInfo = 113391, }, -- Sundered Skirmisher
	[208425] = { cameraID = 130, displayInfo = 112802, }, -- Eadweard Dalyngrigge
	[208694] = { cameraID = 130, displayInfo = 113374, }, -- Forsaken Soldier
	[208906] = { cameraID = 109, displayInfo = 113048, }, -- Moon Priestess Lasara
	[208918] = { cameraID = 82, displayInfo = 107041, }, -- Khadgar
	[209008] = { cameraID = 120, displayInfo = 90536, }, -- Dark Ranger
	[209593] = { cameraID = 120, displayInfo = 90536, }, -- Dark Ranger
	[209970] = { cameraID = 109, displayInfo = 113083, }, -- Norana Morninglight
	[210122] = { cameraID = 120, displayInfo = 102886, }, -- Primalist Flamewarden
	[210292] = { cameraID = 120, displayInfo = 102886, }, -- Primalist Flamewarden
	[210496] = { cameraID = 109, displayInfo = 108146, }, -- Otharia
	[210553] = { cameraID = 146, displayInfo = 113392, }, -- Sundered Skirmisher
	[210554] = { cameraID = 146, displayInfo = 110856, }, -- Winglord Dezran
	[210666] = { cameraID = 109, displayInfo = 102891, }, -- Primalist Flamewarden
	[210669] = { cameraID = 120, displayInfo = 102886, }, -- Primalist Flamewarden
	[210719] = { cameraID = 130, displayInfo = 114185, }, -- Lethnal
	[210916] = { cameraID = 82, displayInfo = 29960, }, -- Huntsman Blake
	[210968] = { cameraID = 82, displayInfo = 117055, }, -- Scarlet Champion
	[211144] = { cameraID = 130, displayInfo = 113373, }, -- Forsaken Soldier
	[211349] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[211351] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[211493] = { cameraID = 1208, displayInfo = 89310, }, -- Xal'atath
	[211499] = { cameraID = 1752, displayInfo = 114268, }, -- Executor Nizrek
	[211519] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[211888] = { cameraID = 1752, displayInfo = 114268, }, -- Executor Nizrek
	[212247] = { cameraID = 82, displayInfo = 116232, }, -- Travard
	[212343] = { cameraID = 268, displayInfo = 71623, }, -- Farseer Nobundo
	[212755] = { cameraID = 1799, displayInfo = 114662, }, -- Queensguard Zirix
	[212935] = { cameraID = 1799, displayInfo = 115010, }, -- Armored Subjugator
	[213632] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[213682] = { cameraID = 82, displayInfo = 115655, }, -- Ravenholdt Mini-Assassin
	[213748] = { cameraID = 82, displayInfo = 115013, }, -- Velhanite Citizen
	[213787] = { cameraID = 82, displayInfo = 115692, }, -- Duke Velhan
	[213886] = { cameraID = 141, displayInfo = 91671, }, -- Orc Wolf Rider
	[214193] = { cameraID = 268, displayInfo = 17560, }, -- Arechron
	[214194] = { cameraID = 268, displayInfo = 17705, }, -- Corki
	[214303] = { cameraID = 109, displayInfo = 116222, }, -- Priestess Alinya
	[214304] = { cameraID = 109, displayInfo = 116221, }, -- Belysra Starbreeze
	[214305] = { cameraID = 109, displayInfo = 116220, }, -- Priestess Kyleen Il'dinare
	[214306] = { cameraID = 109, displayInfo = 116219, }, -- Moon Priestess Lasara
	[214312] = { cameraID = 109, displayInfo = 112157, }, -- Arko'narin Starshade
	[214316] = { cameraID = 109, displayInfo = 89364, }, -- Delaryn Summermoon
	[214321] = { cameraID = 813, displayInfo = 64441, }, -- Drelanim Whisperwind
	[214323] = { cameraID = 109, displayInfo = 114045, }, -- Solarys Thorngale
	[214328] = { cameraID = 625, displayInfo = 63641, }, -- Koda Steelclaw
	[214329] = { cameraID = 109, displayInfo = 68584, }, -- Lea Stonepaw
	[214330] = { cameraID = 109, displayInfo = 105957, }, -- Lyessa Bloomwatcher
	[214333] = { cameraID = 813, displayInfo = 64432, }, -- Marin Bladewing
	[214335] = { cameraID = 813, displayInfo = 64443, }, -- Mirana Starlight
	[214337] = { cameraID = 109, displayInfo = 113049, }, -- Myara Nightsong
	[214340] = { cameraID = 109, displayInfo = 113050, }, -- Raene Wolfrunner
	[214344] = { cameraID = 109, displayInfo = 113051, }, -- Sentinel Cordressa Briarbow
	[214345] = { cameraID = 109, displayInfo = 112715, }, -- Shandris Feathermoon
	[214418] = { cameraID = 82, displayInfo = 115283, }, -- Aelric Leid
	[214449] = { cameraID = 82, displayInfo = 58289, }, -- Kirin Tor Mage
	[214616] = { cameraID = 82, displayInfo = 78867, }, -- Corrupted Memory of Turalyon
	[214851] = { cameraID = 126, displayInfo = 114680, }, -- Ebyssian
	[214856] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[214857] = { cameraID = 109, displayInfo = 113795, }, -- Merithra
	[214919] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[214941] = { cameraID = 1752, displayInfo = 115750, }, -- Kaheti Overseer
	[215244] = { cameraID = 141, displayInfo = 116317, }, -- Orc Invader
	[215533] = { cameraID = 105, displayInfo = 116367, }, -- Greyguard Elite
	[215534] = { cameraID = 109, displayInfo = 88837, }, -- 7th Legion Scout
	[215537] = { cameraID = 82, displayInfo = 83324, }, -- 7th Legion Battlemage
	[215840] = { cameraID = 82, displayInfo = 115995, }, -- Anduin
	[216067] = { cameraID = 109, displayInfo = 116646, }, -- Shandris Feathermoon
	[216101] = { cameraID = 90, displayInfo = 114786, }, -- Kill Target
	[216102] = { cameraID = 90, displayInfo = 114947, }, -- Monstrous Skardyn
	[216115] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[216159] = { cameraID = 1860, displayInfo = 78749, }, -- Locus-Walker
	[216168] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[216176] = { cameraID = 82, displayInfo = 115013, }, -- Arathi Farmer
	[216208] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[216252] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[216253] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[216468] = { cameraID = 141, displayInfo = 91670, }, -- Horde Wolfaxe
	[216682] = { cameraID = 109, displayInfo = 116646, }, -- Shandris Feathermoon
	[216835] = { cameraID = 1208, displayInfo = 86740, }, -- Rift Voidsinger
	[216840] = { cameraID = 795, displayInfo = 66275, }, -- Suramar Chronomancer
	[217032] = { cameraID = 109, displayInfo = 114501, }, -- Bel'ameth Huntress
	[217045] = { cameraID = 109, displayInfo = 38001, }, -- Aessa Silverdew
	[217174] = { cameraID = 109, displayInfo = 114228, }, -- Priestess of the Moon
	[217176] = { cameraID = 109, displayInfo = 30813, }, -- Vassandra Stormclaw
	[217181] = { cameraID = 105, displayInfo = 33840, }, -- Celestine of the Harvest
	[217234] = { cameraID = 126, displayInfo = 91041, }, -- Tauren Plainswalker
	[217236] = { cameraID = 130, displayInfo = 72563, }, -- Forsaken Warlock
	[217313] = { cameraID = 1799, displayInfo = 115730, }, -- Crypt Lord
	[217463] = { cameraID = 1799, displayInfo = 115010, }, -- Enraged Colossus
	[217569] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[217640] = { cameraID = 130, displayInfo = 117165, }, -- Albert
	[218255] = { cameraID = 1208, displayInfo = 117862, }, -- Riftwalker Eiteiri
	[218257] = { cameraID = 1208, displayInfo = 117864, }, -- Riftwalker Tarrowyn
	[218258] = { cameraID = 1208, displayInfo = 117854, }, -- Riftwalker Dellyn
	[218438] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[219172] = { cameraID = 1752, displayInfo = 114418, }, -- Vacuous Ritualist
	[219582] = { cameraID = 1752, displayInfo = 114418, }, -- Woven Ritualist
	[219583] = { cameraID = 1752, displayInfo = 114418, }, -- Defiled Ritualist
	[219613] = { cameraID = 1799, displayInfo = 114773, }, -- Kaheti Warshell
	[219614] = { cameraID = 1752, displayInfo = 114411, }, -- Web Priest
	[219665] = { cameraID = 1799, displayInfo = 119303, }, -- Queensguard An'Jak Shabtir
	[220558] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[220802] = { cameraID = 90, displayInfo = 118377, }, -- Kurdran Wildhammer
	[221228] = { cameraID = 82, displayInfo = 33757, }, -- Friendly Joe
	[221386] = { cameraID = 268, displayInfo = 120101, }, -- Aspiring Farseer
	[221545] = { cameraID = 90, displayInfo = 47399, }, -- [DNT] Rare 08 Stalker
	[221650] = { cameraID = 1208, displayInfo = 82403, }, -- Void Aspirant
	[221958] = { cameraID = 90, displayInfo = 47399, }, -- [DNT] Rare 15 Stalker
	[222806] = { cameraID = 120, displayInfo = 25674, }, -- Elizabeth Ross
	[222823] = { cameraID = 141, displayInfo = 108464, }, -- Horde Grunt
	[222829] = { cameraID = 82, displayInfo = 119057, }, -- Stromgarde Footman
	[222830] = { cameraID = 141, displayInfo = 65477, }, -- Bonegrim
	[222904] = { cameraID = 126, displayInfo = 119212, }, -- Horde Emmissary
	[222935] = { cameraID = 126, displayInfo = 73066, }, -- Horde Emmissary
	[222949] = { cameraID = 82, displayInfo = 118182, }, -- Arathi Aeroknight
	[223050] = { cameraID = 90, displayInfo = 118377, }, -- Kurdran Wildhammer
	[223466] = { cameraID = 1799, displayInfo = 114773, }, -- Kaheti Siegelord
	[223531] = { cameraID = 268, displayInfo = 119532, }, -- Valwar
	[223595] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Shield Master
	[223616] = { cameraID = 268, displayInfo = 113857, }, -- Soulspeaker Niir
	[223628] = { cameraID = 268, displayInfo = 119644, }, -- Tishamaat Celebrant
	[223629] = { cameraID = 268, displayInfo = 119639, }, -- Tishamaat Celebrant
	[223634] = { cameraID = 268, displayInfo = 119563, }, -- Tishamaat Celebrant
	[223722] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[224384] = { cameraID = 1752, displayInfo = 114414, }, -- Nerubian Priest, Dark
	[224787] = { cameraID = 82, displayInfo = 118182, }, -- Arathi Aeroknight
	[225404] = { cameraID = 90, displayInfo = 47399, }, -- Beledar's Spawn
	[225585] = { cameraID = 1797, displayInfo = 116208, }, -- Widow Arak'nai
	[226521] = { cameraID = 82, displayInfo = 117115, }, -- Archmage Drenden
	[226600] = { cameraID = 1799, displayInfo = 114768, }, -- Chitin Commander
	[227436] = { cameraID = 82, displayInfo = 125322, }, -- Archmage Khadgar
	[227466] = { cameraID = 82, displayInfo = 118182, }, -- Arathi Aeroknight
	[227492] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[227722] = { cameraID = 1208, displayInfo = 121284, }, -- Xal'atath
	[227762] = { cameraID = 120, displayInfo = 47997, }, -- Kirin Tor Portal Mage
	[229150] = { cameraID = 82, displayInfo = 69542, }, -- Lord Jorach Ravenholdt
	[229744] = { cameraID = 1752, displayInfo = 119884, }, -- Executor Nizrek
	[229795] = { cameraID = 1799, displayInfo = 119886, }, -- Anub'azal
	[229797] = { cameraID = 1797, displayInfo = 116358, }, -- Widow Arak'nai
	[229841] = { cameraID = 82, displayInfo = 100762, }, -- Turalyon
	[229842] = { cameraID = 1860, displayInfo = 78749, }, -- Locus Walker
	[229844] = { cameraID = 82, displayInfo = 123402, }, -- Archmage Khadgar
	[229951] = { cameraID = 82, displayInfo = 122768, }, -- Captain Roderick Brewston
	[230095] = { cameraID = 82, displayInfo = 122878, }, -- Aelric Leid
	[230405] = { cameraID = 120, displayInfo = 121978, }, -- Sunreaver Battlemage
	[230601] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[230602] = { cameraID = 120, displayInfo = 131474, }, -- Xal'atath
	[230603] = { cameraID = 1577, displayInfo = 122330, }, -- Om'resh
	[230609] = { cameraID = 120, displayInfo = 131464, }, -- Alleria Windrunner
	[230689] = { cameraID = 82, displayInfo = 122547, }, -- Warrior Champion
	[230868] = { cameraID = 90, displayInfo = 114755, }, -- High Speaker's Guard
	[231084] = { cameraID = 82, displayInfo = 35369, }, -- Neighborhood Local
	[231128] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[231436] = { cameraID = 146, displayInfo = 104843, }, -- Stasis-Locked Obsidian Warder
	[231522] = { cameraID = 120, displayInfo = 131464, }, -- Alleria Windrunner
	[231630] = { cameraID = 90, displayInfo = 122976, }, -- Trader Josef
	[231759] = { cameraID = 141, displayInfo = 128707, }, -- Eitrigg
	[231820] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[232048] = { cameraID = 82, displayInfo = 123262, }, -- Jeremy Feasel
	[232295] = { cameraID = 82, displayInfo = 124672, }, -- Almyr Sunhart
	[232356] = { cameraID = 1208, displayInfo = 123435, }, -- Kydrel Paledawn
	[232364] = { cameraID = 146, displayInfo = 123403, }, -- Tyl
	[232366] = { cameraID = 105, displayInfo = 123440, }, -- Keita Notleigh
	[233064] = { cameraID = 146, displayInfo = 123613, }, -- Vaeli
	[233071] = { cameraID = 146, displayInfo = 123616, }, -- Celden
	[233074] = { cameraID = 126, displayInfo = 123611, }, -- Ginde Dreamshift
	[233097] = { cameraID = 130, displayInfo = 123639, }, -- Javier Luxford
	[233123] = { cameraID = 120, displayInfo = 123641, }, -- Olanea Rosekind
	[233239] = { cameraID = 82, displayInfo = 123402, }, -- Archmage Khadgar
	[233242] = { cameraID = 114, displayInfo = 75730, }, -- Jastor Gallywix
	[233355] = { cameraID = 146, displayInfo = 123776, }, -- Hunter Champion
	[233530] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[234056] = { cameraID = 82, displayInfo = 124191, }, -- Lord Ibelin Redmoore
	[234126] = { cameraID = 141, displayInfo = 63441, }, -- Horde Soldier
	[234127] = { cameraID = 82, displayInfo = 94818, }, -- Hero of Azeroth
	[234128] = { cameraID = 120, displayInfo = 122903, }, -- Hero of Azeroth
	[234158] = { cameraID = 120, displayInfo = 121972, }, -- Silver Covenant Spellcaster
	[234271] = { cameraID = 120, displayInfo = 36905, }, -- Matron Ossela
	[234274] = { cameraID = 120, displayInfo = 65251, }, -- Saedelin Whitedawn
	[234355] = { cameraID = 90, displayInfo = 124367, }, -- Brann Bronzebeard
	[234745] = { cameraID = 90, displayInfo = 127693, }, -- Hemet Nesingwary
	[234793] = { cameraID = 120, displayInfo = 140186, }, -- Row Rat
	[235061] = { cameraID = 82, displayInfo = 124660, }, -- Sacredite Savant
	[235240] = { cameraID = 141, displayInfo = 124748, }, -- Orgrim Doomhammer
	[235994] = { cameraID = 1577, displayInfo = 131942, }, -- Om'rajula
	[236048] = { cameraID = 82, displayInfo = 121981, }, -- Kirin Tor Survivor
	[236134] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[236382] = { cameraID = 120, displayInfo = 126358, }, -- Soridormi
	[237293] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[237298] = { cameraID = 141, displayInfo = 126084, }, -- Horde Lieutenant
	[237299] = { cameraID = 141, displayInfo = 126083, }, -- Eitrigg
	[237351] = { cameraID = 82, displayInfo = 128039, }, -- Alliance Warrior
	[237352] = { cameraID = 82, displayInfo = 128248, }, -- Turalyon
	[237375] = { cameraID = 141, displayInfo = 128329, }, -- Orgrim Doomhammer
	[237381] = { cameraID = 141, displayInfo = 126111, }, -- Horde Warlord
	[237531] = { cameraID = 130, displayInfo = 141282, }, -- Alonsus Faol
	[239616] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[239618] = { cameraID = 1208, displayInfo = 136414, }, -- Riftblade Maella
	[239620] = { cameraID = 1208, displayInfo = 136423, }, -- Voidlight Everdawn
	[239677] = { cameraID = 90, displayInfo = 129865, }, -- Light's Vanguard
	[239678] = { cameraID = 82, displayInfo = 62976, }, -- Light's Vanguard
	[239883] = { cameraID = 126, displayInfo = 62778, }, -- Sunwalker Atohmo
	[239913] = { cameraID = 82, displayInfo = 120969, }, -- Guard
	[240240] = { cameraID = 130, displayInfo = 141282, }, -- Alonsus Faol
	[240283] = { cameraID = 120, displayInfo = 128683, }, -- Vereesa Windrunner
	[240717] = { cameraID = 109, displayInfo = 127666, }, -- Highborne Arcanist
	[240720] = { cameraID = 109, displayInfo = 127689, }, -- Night Elf Druid
	[240813] = { cameraID = 82, displayInfo = 127691, }, -- Uther Lightbringer
	[240820] = { cameraID = 120, displayInfo = 123088, }, -- Botanist Alaenra
	[240842] = { cameraID = 1208, displayInfo = 141322, }, -- Leona Darkstrider
	[240852] = { cameraID = 82, displayInfo = 128126, }, -- Lars Bronsmaelt
	[241029] = { cameraID = 120, displayInfo = 39910, }, -- Taryssa Lazuria
	[241030] = { cameraID = 120, displayInfo = 37088, }, -- Marith Lazuria
	[241076] = { cameraID = 1208, displayInfo = 117091, }, -- Riftblade Maella
	[241743] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[241759] = { cameraID = 120, displayInfo = 128064, }, -- High Elf Arcanist
	[241981] = { cameraID = 120, displayInfo = 128133, }, -- Quel'Thalas Mage
	[242095] = { cameraID = 120, displayInfo = 128177, }, -- Lady Liadrin
	[242281] = { cameraID = 82, displayInfo = 128261, }, -- Archmage Vargoth
	[242299] = { cameraID = 82, displayInfo = 106239, }, -- Archmage Khadgar
	[242398] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[242399] = { cameraID = 793, displayInfo = 107574, }, -- Telemancer Astrandis
	[242417] = { cameraID = 120, displayInfo = 121121, }, -- Fleeing Citizens
	[242583] = { cameraID = 82, displayInfo = 141437, }, -- Danath Trollbane
	[242817] = { cameraID = 82, displayInfo = 62976, }, -- Crusader Newbery
	[243111] = { cameraID = 120, displayInfo = 138919, }, -- Auctioneer Caidori
	[243115] = { cameraID = 141, displayInfo = 129395, }, -- Eitrigg
	[243117] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[243157] = { cameraID = 82, displayInfo = 128320, }, -- Light's Vanguard
	[243905] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[244081] = { cameraID = 795, displayInfo = 66275, }, -- Nightborne Arcanist
	[244540] = { cameraID = 120, displayInfo = 29611, }, -- Captain Elleane Wavecrest
	[245155] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[245161] = { cameraID = 1865, displayInfo = 124338, }, -- Om'talad
	[245301] = { cameraID = 1577, displayInfo = 101570, }, -- Market Patron
	[245302] = { cameraID = 1865, displayInfo = 101477, }, -- Tazavesh Enforcer
	[245306] = { cameraID = 1577, displayInfo = 124730, }, -- Tazavesh Security
	[245399] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[245519] = { cameraID = 90, displayInfo = 141212, }, -- Priest Grimmin
	[245536] = { cameraID = 1208, displayInfo = 141322, }, -- Leona Darkstrider
	[245588] = { cameraID = 82, displayInfo = 129720, }, -- High Exarch Turalyon
	[245852] = { cameraID = 1865, displayInfo = 122503, }, -- Om'en
	[245976] = { cameraID = 1208, displayInfo = 139855, }, -- Deminos Darktrance
	[246433] = { cameraID = 109, displayInfo = 91416, }, -- Kellara the Cunning
	[246435] = { cameraID = 126, displayInfo = 91447, }, -- Tuwavo Ravenwing
	[246548] = { cameraID = 126, displayInfo = 91458, }, -- Matumo Brighthoof
	[246627] = { cameraID = 90, displayInfo = 91439, }, -- Ulfrik Stoutarm
	[246628] = { cameraID = 130, displayInfo = 91471, }, -- Marco the Malodorous
	[246666] = { cameraID = 82, displayInfo = 91957, }, -- Renten Plaguebringer
	[246678] = { cameraID = 120, displayInfo = 91451, }, -- Nimisia Azuresong
	[246749] = { cameraID = 90, displayInfo = 91428, }, -- Bishop Broxast
	[246750] = { cameraID = 130, displayInfo = 91460, }, -- Grigori the Unrepentant
	[246758] = { cameraID = 1208, displayInfo = 91437, }, -- Savia "Anguish" Anguossa
	[246829] = { cameraID = 82, displayInfo = 91438, }, -- Pyrthel the Ghastly
	[246883] = { cameraID = 105, displayInfo = 91413, }, -- Riley Iceclaw
	[246904] = { cameraID = 126, displayInfo = 91442, }, -- Loqh'wa the Vengeful
	[246907] = { cameraID = 1208, displayInfo = 91967, }, -- Faedra the Sniper
	[246912] = { cameraID = 109, displayInfo = 91414, }, -- Nylaria the Haunted
	[246913] = { cameraID = 120, displayInfo = 91446, }, -- Celaryn the Frenzied
	[247124] = { cameraID = 82, displayInfo = 91970, }, -- Davin "Ashes" Ashton
	[247125] = { cameraID = 141, displayInfo = 91972, }, -- Kirok the Charred
	[247133] = { cameraID = 126, displayInfo = 91982, }, -- Caothun Suntouched
	[247137] = { cameraID = 120, displayInfo = 91983, }, -- "Don't Die" Dyona
	[247139] = { cameraID = 1208, displayInfo = 91431, }, -- Falania Nightsoul
	[247151] = { cameraID = 141, displayInfo = 91467, }, -- Ogros Blazeseer
	[247152] = { cameraID = 90, displayInfo = 91976, }, -- Damogath the Tenebrous
	[247153] = { cameraID = 130, displayInfo = 91978, }, -- Ignan Felfire
	[247154] = { cameraID = 105, displayInfo = 91977, }, -- Mistress Xyla
	[247155] = { cameraID = 120, displayInfo = 91979, }, -- Malys Feltouch
	[247238] = { cameraID = 146, displayInfo = 130452, }, -- Kozar Silverclaw
	[247239] = { cameraID = 146, displayInfo = 130453, }, -- Kazara Bloodtalon
	[247240] = { cameraID = 146, displayInfo = 130454, }, -- Trazen Swiftwing
	[247241] = { cameraID = 146, displayInfo = 130455, }, -- Zindroz Darkscale
	[247242] = { cameraID = 146, displayInfo = 130456, }, -- Nishana Greyscale
	[247243] = { cameraID = 146, displayInfo = 130457, }, -- Siatra Spellwing
	[248122] = { cameraID = 105, displayInfo = 131387, }, -- Stalker Kaylanna
	[248137] = { cameraID = 82, displayInfo = 131392, }, -- Rusty "Razor" Maddox
	[248272] = { cameraID = 90, displayInfo = 131451, }, -- Cainn Grimbeard
	[248300] = { cameraID = 120, displayInfo = 121123, }, -- Silvermoon Evacuee
	[248455] = { cameraID = 1208, displayInfo = 127391, }, -- Lucia Nightbreaker
	[248496] = { cameraID = 90, displayInfo = 131520, }, -- Brann Bronzebeard
	[249178] = { cameraID = 82, displayInfo = 122547, }, -- Warrior Champion
	[249184] = { cameraID = 146, displayInfo = 123776, }, -- Hunter Champion
	[249623] = { cameraID = 120, displayInfo = 30628, }, -- Sunwell Warden
	[249624] = { cameraID = 795, displayInfo = 66275, }, -- Nightborne Arcanist
	[249706] = { cameraID = 90, displayInfo = 139968, }, -- Bromos Grummner
	[250382] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[250394] = { cameraID = 109, displayInfo = 27168, }, -- Liandra
	[250398] = { cameraID = 120, displayInfo = 16732, }, -- Harassed Citizen
	[250400] = { cameraID = 130, displayInfo = 69306, }, -- Tehd Shoemaker
	[250402] = { cameraID = 90, displayInfo = 141280, }, -- Gidwin Goldbraids
	[250404] = { cameraID = 82, displayInfo = 141314, }, -- Archmage Timear
	[250405] = { cameraID = 109, displayInfo = 141312, }, -- Thisalee Crow
	[250409] = { cameraID = 126, displayInfo = 141315, }, -- Gamon
	[250584] = { cameraID = 120, displayInfo = 89420, }, -- Silvermooon Guard
	[250594] = { cameraID = 144, displayInfo = 40962, }, -- Chen Stormstout
	[252854] = { cameraID = 1208, displayInfo = 136314, }, -- Vanguard Scout
	[252999] = { cameraID = 1208, displayInfo = 127696, }, -- Leona Darkstrider
	[253160] = { cameraID = 90, displayInfo = 140998, }, -- Kurdran Wildhammer
	[253210] = { cameraID = 120, displayInfo = 140186, }, -- Row Rat
	[253948] = { cameraID = 1208, displayInfo = 140104, }, -- Leona Darkstrider
	[254404] = { cameraID = 1208, displayInfo = 119495, }, -- Lieutenant Verana
	[254616] = { cameraID = 130, displayInfo = 138285, }, -- Nelthius Shadestone
	[255011] = { cameraID = 120, displayInfo = 138590, }, -- Tactical Telemancer Seralia
	[255103] = { cameraID = 82, displayInfo = 122301, }, -- Reno Jackson
	[255219] = { cameraID = 82, displayInfo = 138025, }, -- Vanguard Scout
	[256017] = { cameraID = 1208, displayInfo = 140104, }, -- Leona Darkstrider
	[256041] = { cameraID = 90, displayInfo = 110635, }, -- Gidwin Goldbraids
	[256144] = { cameraID = 120, displayInfo = 139509, }, -- Deya Gloombringer
	[256543] = { cameraID = 82, displayInfo = 46188, }, -- Jeremy Feasel
	[256546] = { cameraID = 1577, displayInfo = 130405, }, -- Mind-Seeker Apprentice
	[256656] = { cameraID = 82, displayInfo = 139730, }, -- Aelric Leid
	[256719] = { cameraID = 82, displayInfo = 115283, }, -- Aelric Leid
	[256722] = { cameraID = 82, displayInfo = 115523, }, -- Glooming Disciple
	[256725] = { cameraID = 120, displayInfo = 131474, }, -- Xal'atath
	[257174] = { cameraID = 120, displayInfo = 139971, }, -- Dragonscale Researcher
	[258844] = { cameraID = 141, displayInfo = 141085, }, -- Mind-Seeker Apprentice
	[258948] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[259153] = { cameraID = 120, displayInfo = 141432, }, -- Soridormi
	[176681] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[176680] = { cameraID = 90, displayInfo = 33140, }, -- Muradin Bronzebeard
	[73604] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[100720] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[109143] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[61833] = { cameraID = 82, displayInfo = 41826, }, -- Player Clone (TEMP)
	[65247] = { cameraID = 82, displayInfo = 41826, }, -- Player Clone (TEMP)
	[71927] = { cameraID = 144, displayInfo = 39698, }, -- Chen Stormstout
	[66066] = { cameraID = 126, displayInfo = 40006, }, -- Sunwalker Dezco
	[71089] = { cameraID = 126, displayInfo = 40006, }, -- Sunwalker Dezco
	[66961] = { cameraID = 141, displayInfo = 42562, }, -- General Nazgrim
	[227270] = { cameraID = 126, displayInfo = 45379, }, -- Brok
	[67158] = { cameraID = 141, displayInfo = 14360, }, -- Kor'kron Elite
	[71929] = { cameraID = 90, displayInfo = 38872, }, -- Sully "The Pickle" McLeary
	[71151] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[71249] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[72394] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[100870] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[133240] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[141555] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[145191] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[145692] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[146971] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[189393] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[68921] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[69026] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[70799] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[142153] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[70938] = { cameraID = 141, displayInfo = 52019, }, -- Frostwolf Greyfur
	[71780] = { cameraID = 141, displayInfo = 52019, }, -- Frostwolf Greyfur
	[73624] = { cameraID = 141, displayInfo = 49191, }, -- Ga'nar
	[73996] = { cameraID = 141, displayInfo = 49191, }, -- Ga'nar
	[74000] = { cameraID = 141, displayInfo = 49191, }, -- Ga'nar
	[75346] = { cameraID = 141, displayInfo = 49191, }, -- Ga'nar
	[76486] = { cameraID = 141, displayInfo = 49191, }, -- Ga'nar
	[71717] = { cameraID = 141, displayInfo = 49107, }, -- Vragor
	[71769] = { cameraID = 141, displayInfo = 49107, }, -- Vragor
	[71777] = { cameraID = 141, displayInfo = 49107, }, -- Vragor
	[71783] = { cameraID = 141, displayInfo = 49107, }, -- Vragor
	[71819] = { cameraID = 141, displayInfo = 49107, }, -- Vragor
	[81562] = { cameraID = 141, displayInfo = 49100, }, -- Thunderlord Crag-Leaper
	[110866] = { cameraID = 109, displayInfo = 50541, }, -- Delas Moonfang
	[113299] = { cameraID = 109, displayInfo = 50541, }, -- Delas Moonfang
	[75805] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[77184] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78288] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78558] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78559] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78560] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78561] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78562] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78563] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[78813] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[80142] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[80146] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[81130] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[81191] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[81420] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[83823] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[83863] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[84702] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[85591] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[85616] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[90115] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[90137] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[90233] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[92213] = { cameraID = 82, displayInfo = 56765, }, -- Archmage Khadgar
	[82503] = { cameraID = 141, displayInfo = 54120, }, -- Throm'var Hunter
	[82506] = { cameraID = 109, displayInfo = 23850, }, -- Starfall Sentinel
	[76233] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[76492] = { cameraID = 141, displayInfo = 52012, }, -- Frostwolf Grunt
	[77417] = { cameraID = 82, displayInfo = 58813, }, -- Image of Archmage Khadgar
	[193964] = { cameraID = 141, displayInfo = 30272, }, -- Baine Bloodhoof
	[137154] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[155498] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[169818] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[73998] = { cameraID = 141, displayInfo = 51517, }, -- Skal the Trapper
	[73825] = { cameraID = 141, displayInfo = 50229, }, -- Warsong Ragemonger
	[73840] = { cameraID = 141, displayInfo = 50229, }, -- Warsong Ragemonger
	[73842] = { cameraID = 141, displayInfo = 50229, }, -- Warsong Ragemonger
	[81822] = { cameraID = 815, displayInfo = 59707, }, -- Cho'gall
	[74804] = { cameraID = 141, displayInfo = 52019, }, -- Frostwolf Shaman
	[74025] = { cameraID = 141, displayInfo = 50369, }, -- Shadowmoon Stormcaller
	[74890] = { cameraID = 141, displayInfo = 51767, }, -- Iron Grunt
	[76325] = { cameraID = 141, displayInfo = 51767, }, -- Iron Grunt
	[74223] = { cameraID = 141, displayInfo = 51824, }, -- Kal'gor the Honorable
	[74272] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[74595] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[75807] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[76489] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[77281] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[83657] = { cameraID = 141, displayInfo = 51767, }, -- Grom'kar Grunt
	[85709] = { cameraID = 141, displayInfo = 51767, }, -- Grom'kar Grunt
	[85781] = { cameraID = 141, displayInfo = 51767, }, -- Grom'kar Grunt
	[76804] = { cameraID = 120, displayInfo = 52434, }, -- Lady Liadrin
	[79675] = { cameraID = 120, displayInfo = 52434, }, -- Lady Liadrin
	[80415] = { cameraID = 120, displayInfo = 52434, }, -- Lady Liadrin
	[75154] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[76032] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[77161] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[77185] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[77829] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[80874] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[80919] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[81588] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[90178] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[90193] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[76031] = { cameraID = 90, displayInfo = 52528, }, -- Hansel Heavyhands
	[77160] = { cameraID = 90, displayInfo = 52528, }, -- Hansel Heavyhands
	[77311] = { cameraID = 90, displayInfo = 52528, }, -- Hansel Heavyhands
	[78569] = { cameraID = 90, displayInfo = 52528, }, -- Hansel Heavyhands
	[76728] = { cameraID = 141, displayInfo = 52557, }, -- Gol'kosh the Axe
	[77023] = { cameraID = 141, displayInfo = 51767, }, -- Grom'kar Deadeye
	[76453] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[76590] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[82070] = { cameraID = 141, displayInfo = 53609, }, -- Farseer Drek'Thar
	[76960] = { cameraID = 141, displayInfo = 51998, }, -- Iron Grunt
	[88011] = { cameraID = 141, displayInfo = 49772, }, -- Karg Bloodfury
	[86220] = { cameraID = 141, displayInfo = 54036, }, -- Teron'gor
	[78251] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[81901] = { cameraID = 141, displayInfo = 56742, }, -- Bleeding Hollow Savage
	[78642] = { cameraID = 90, displayInfo = 54258, }, -- Owynn Graddock
	[78950] = { cameraID = 141, displayInfo = 36185, }, -- Ariok
	[80521] = { cameraID = 90, displayInfo = 52540, }, -- Thaelin Darkanvil
	[88323] = { cameraID = 82, displayInfo = 19078, }, -- Image of Archmage Vargoth
	[88339] = { cameraID = 141, displayInfo = 54968, }, -- Gronnstalker Rokash
	[88353] = { cameraID = 141, displayInfo = 54373, }, -- Mulverick
	[85903] = { cameraID = 126, displayInfo = 55046, }, -- Olin Umberhide
	[88354] = { cameraID = 126, displayInfo = 55046, }, -- Olin Umberhide
	[88351] = { cameraID = 109, displayInfo = 55047, }, -- Qiana Moonshadow
	[82832] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[84131] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[86491] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[86097] = { cameraID = 141, displayInfo = 57984, }, -- Corporal Thukmar
	[88335] = { cameraID = 141, displayInfo = 52202, }, -- Bruto
	[81467] = { cameraID = 90, displayInfo = 53107, }, -- Fort Wrynn Rifleman
	[81438] = { cameraID = 109, displayInfo = 56185, }, -- Fort Wrynn Magus
	[81470] = { cameraID = 82, displayInfo = 53840, }, -- Fort Wrynn Footman
	[81471] = { cameraID = 82, displayInfo = 53840, }, -- Fort Wrynn Footman
	[88349] = { cameraID = 109, displayInfo = 56438, }, -- Daleera Moonfang
	[88343] = { cameraID = 141, displayInfo = 56659, }, -- Lantresor of the Blade
	[85895] = { cameraID = 141, displayInfo = 57377, }, -- Darkun
	[85879] = { cameraID = 105, displayInfo = 34450, }, -- Fiona
	[88331] = { cameraID = 105, displayInfo = 34450, }, -- Fiona
	[88333] = { cameraID = 82, displayInfo = 57227, }, -- Leeroy Jenkins
	[88372] = { cameraID = 109, displayInfo = 57345, }, -- Illenya
	[117656] = { cameraID = 90, displayInfo = 47399, }, -- General Purpose Stalker
	[84414] = { cameraID = 141, displayInfo = 57993, }, -- Grom'kar Captive
	[85135] = { cameraID = 82, displayInfo = 56418, }, -- Bodrick Grey
	[88313] = { cameraID = 82, displayInfo = 60858, }, -- Admiral Taylor
	[88475] = { cameraID = 90, displayInfo = 47399, }, -- Mole Machine
	[88477] = { cameraID = 90, displayInfo = 47399, }, -- Mole Machine
	[85654] = { cameraID = 82, displayInfo = 53840, }, -- Garrison Soldier
	[85778] = { cameraID = 82, displayInfo = 53840, }, -- Garrison Soldier
	[88319] = { cameraID = 82, displayInfo = 10457, }, -- Weldon Barov
	[88318] = { cameraID = 130, displayInfo = 10456, }, -- Alexi Barov
	[90399] = { cameraID = 141, displayInfo = 58851, }, -- Grom'kar Deadeye
	[90398] = { cameraID = 141, displayInfo = 58867, }, -- Grom'kar Bulwark
	[90397] = { cameraID = 141, displayInfo = 58859, }, -- Grom'kar Punisher
	[90396] = { cameraID = 141, displayInfo = 58888, }, -- Grom'kar Blademaster
	[85792] = { cameraID = 141, displayInfo = 55307, }, -- Garrison Grunt
	[88311] = { cameraID = 120, displayInfo = 59874, }, -- Aeda Brightdawn
	[102639] = { cameraID = 82, displayInfo = 13099, }, -- Nat Pagle
	[107804] = { cameraID = 82, displayInfo = 13099, }, -- Nat Pagle
	[114581] = { cameraID = 82, displayInfo = 13099, }, -- Nat Pagle
	[88301] = { cameraID = 90, displayInfo = 59353, }, -- Delvar Ironfist
	[89075] = { cameraID = 90, displayInfo = 59353, }, -- Delvar Ironfist
	[97296] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[97978] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[101159] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[114909] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[115039] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[115102] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[115367] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[115375] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[115464] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[115504] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[116740] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[88307] = { cameraID = 90, displayInfo = 58509, }, -- Glirin
	[88303] = { cameraID = 141, displayInfo = 59265, }, -- Spirit of Bony Xuk
	[88302] = { cameraID = 130, displayInfo = 59710, }, -- Benjamin Gibb
	[119803] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[120219] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[88291] = { cameraID = 120, displayInfo = 57772, }, -- Dark Ranger Velonara
	[90444] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90445] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90446] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90447] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90448] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90449] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90450] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90451] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90588] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90589] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90590] = { cameraID = 82, displayInfo = 53840, }, -- Wounded Soldier
	[90454] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90455] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90456] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90457] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90459] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90460] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90461] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90462] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[90587] = { cameraID = 141, displayInfo = 55307, }, -- Wounded Grunt
	[115915] = { cameraID = 82, displayInfo = 53840, }, -- Alliance Soldier
	[100387] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[100457] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[103875] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[104241] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[104764] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[116946] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[129116] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[92130] = { cameraID = 141, displayInfo = 62361, }, -- Solog Roark
	[100031] = { cameraID = 82, displayInfo = 62762, }, -- Lord Maxwell Tyrosus
	[103479] = { cameraID = 82, displayInfo = 62762, }, -- Lord Maxwell Tyrosus
	[108776] = { cameraID = 82, displayInfo = 62762, }, -- Lord Maxwell Tyrosus
	[110506] = { cameraID = 82, displayInfo = 62762, }, -- Lord Maxwell Tyrosus
	[111270] = { cameraID = 82, displayInfo = 62762, }, -- Lord Maxwell Tyrosus
	[93879] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[93994] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94000] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94003] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94011] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94023] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94103] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94111] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94119] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[94568] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[114841] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[115099] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[115326] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[115686] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[116738] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[121308] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[126062] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[126078] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[130133] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[131478] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[97908] = { cameraID = 82, displayInfo = 30869, }, -- Highlord Darion Mograine
	[112506] = { cameraID = 82, displayInfo = 30869, }, -- Highlord Darion Mograine
	[111794] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[111807] = { cameraID = 120, displayInfo = 61971, }, -- Lady Liadrin
	[96724] = { cameraID = 90, displayInfo = 61955, }, -- Silver Hand Knight
	[95238] = { cameraID = 120, displayInfo = 60079, }, -- Allari the Souleater
	[97965] = { cameraID = 120, displayInfo = 60079, }, -- Allari the Souleater
	[98227] = { cameraID = 120, displayInfo = 60079, }, -- Allari the Souleater
	[100873] = { cameraID = 120, displayInfo = 60079, }, -- Allari the Souleater
	[112407] = { cameraID = 109, displayInfo = 61734, }, -- Falara Nightsong
	[117447] = { cameraID = 126, displayInfo = 65478, }, -- Skyhorn Interceptor
	[119856] = { cameraID = 126, displayInfo = 65478, }, -- Skyhorn Interceptor
	[179294] = { cameraID = 90, displayInfo = 64615, }, -- Dagnar Stonebrow
	[108956] = { cameraID = 82, displayInfo = 61947, }, -- Silver Hand Knight
	[111728] = { cameraID = 82, displayInfo = 62790, }, -- Silver Hand Protector
	[200658] = { cameraID = 141, displayInfo = 64784, }, -- Nazgrel
	[111591] = { cameraID = 82, displayInfo = 33911, }, -- Thassarian
	[110175] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[229128] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[242099] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[242381] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[248750] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[248874] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[248982] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[250186] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[103007] = { cameraID = 109, displayInfo = 64447, }, -- Asha Ravensong
	[98713] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn
	[103010] = { cameraID = 109, displayInfo = 66159, }, -- Kor'vas Bloodthorn
	[105231] = { cameraID = 82, displayInfo = 66099, }, -- Sir Galveston
	[103015] = { cameraID = 120, displayInfo = 65392, }, -- Zaria Shadowheart
	[100222] = { cameraID = 126, displayInfo = 66408, }, -- Wuho Highmountain
	[100236] = { cameraID = 126, displayInfo = 66408, }, -- Wuho Highmountain
	[100197] = { cameraID = 90, displayInfo = 34644, }, -- Gidwin Goldbraids
	[100201] = { cameraID = 120, displayInfo = 46766, }, -- Aenea
	[100202] = { cameraID = 120, displayInfo = 16685, }, -- Noellene
	[162020] = { cameraID = 109, displayInfo = 66527, }, -- Priestess of Elune
	[118617] = { cameraID = 141, displayInfo = 65757, }, -- Eitrigg
	[118736] = { cameraID = 141, displayInfo = 65757, }, -- Eitrigg
	[133693] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[140877] = { cameraID = 575, displayInfo = 35095, }, -- Malfurion Stormrage
	[107025] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[102363] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[102655] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[110464] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[110498] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[103013] = { cameraID = 109, displayInfo = 67049, }, -- Illysanna Ravencrest
	[114098] = { cameraID = 82, displayInfo = 67195, }, -- Archmage Karlain
	[115466] = { cameraID = 82, displayInfo = 67193, }, -- Archmage Ansirem Runeweaver
	[117456] = { cameraID = 82, displayInfo = 67193, }, -- Archmage Ansirem Runeweaver
	[114101] = { cameraID = 82, displayInfo = 67196, }, -- Archmage Vargoth
	[133522] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[110488] = { cameraID = 141, displayInfo = 65975, }, -- Ritssyn Flamescowl
	[102196] = { cameraID = 90, displayInfo = 34116, }, -- Fargo Flintlocke
	[102197] = { cameraID = 90, displayInfo = 34116, }, -- Fargo Flintlocke
	[102198] = { cameraID = 90, displayInfo = 34116, }, -- Fargo Flintlocke
	[186182] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[231472] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[256002] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[110505] = { cameraID = 109, displayInfo = 66672, }, -- Emmarel Shadewarden
	[103142] = { cameraID = 126, displayInfo = 67945, }, -- Rivermane Tauren
	[104307] = { cameraID = 82, displayInfo = 68038, }, -- Thoradin
	[113605] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardian
	[118112] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardian
	[222476] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardian
	[227488] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardian
	[244262] = { cameraID = 82, displayInfo = 68480, }, -- Kirin Tor Guardian
	[104577] = { cameraID = 109, displayInfo = 68636, }, -- Lyessa Bloomwatcher
	[151115] = { cameraID = 109, displayInfo = 68636, }, -- Lyessa Bloomwatcher
	[105045] = { cameraID = 90, displayInfo = 68654, }, -- Angus Ironfist
	[105469] = { cameraID = 126, displayInfo = 38658, }, -- Muln Earthfury
	[106314] = { cameraID = 126, displayInfo = 38658, }, -- Muln Earthfury
	[106518] = { cameraID = 126, displayInfo = 38658, }, -- Muln Earthfury
	[117674] = { cameraID = 126, displayInfo = 38658, }, -- Muln Earthfury
	[105707] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[105724] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[105777] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[105813] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[105910] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[105911] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[108693] = { cameraID = 90, displayInfo = 24574, }, -- Orik Trueheart
	[105727] = { cameraID = 126, displayInfo = 29250, }, -- Tahu Sagewind
	[105776] = { cameraID = 126, displayInfo = 29250, }, -- Tahu Sagewind
	[106777] = { cameraID = 82, displayInfo = 69565, }, -- Travard
	[111561] = { cameraID = 90, displayInfo = 69208, }, -- Gravely Wounded Soldier
	[109144] = { cameraID = 795, displayInfo = 70210, }, -- Ly'leth Lunastre
	[115508] = { cameraID = 795, displayInfo = 70210, }, -- Ly'leth Lunastre
	[157769] = { cameraID = 141, displayInfo = 37328, }, -- Orgrimmar Wind Rider
	[111792] = { cameraID = 109, displayInfo = 64447, }, -- Asha Ravensong
	[116647] = { cameraID = 109, displayInfo = 71930, }, -- Delas Moonfang
	[214320] = { cameraID = 109, displayInfo = 71930, }, -- Delas Moonfang
	[112165] = { cameraID = 82, displayInfo = 62303, }, -- Archmage Vargoth
	[113227] = { cameraID = 268, displayInfo = 67885, }, -- Ashtongue Warrior
	[113228] = { cameraID = 120, displayInfo = 61909, }, -- Illidari Adept
	[112959] = { cameraID = 82, displayInfo = 67215, }, -- Fleet Admiral Tethys
	[113064] = { cameraID = 82, displayInfo = 67215, }, -- Fleet Admiral Tethys
	[118137] = { cameraID = 82, displayInfo = 67215, }, -- Fleet Admiral Tethys
	[110477] = { cameraID = 82, displayInfo = 83274, }, -- Master Mathias Shaw
	[111839] = { cameraID = 130, displayInfo = 69747, }, -- Felburned Scout
	[111564] = { cameraID = 141, displayInfo = 69700, }, -- Gravely Wounded Soldier
	[116714] = { cameraID = 141, displayInfo = 65975, }, -- Ritssyn Flamescowl
	[249947] = { cameraID = 82, displayInfo = 65450, }, -- Crimson Pilgrim
	[204495] = { cameraID = 141, displayInfo = 72037, }, -- Velgrim
	[113396] = { cameraID = 82, displayInfo = 71010, }, -- Shieldbearer
	[114286] = { cameraID = 109, displayInfo = 72825, }, -- Priestess of the Moon
	[119422] = { cameraID = 82, displayInfo = 27215, }, -- Kirin Tor Guardian
	[115095] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[115372] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[115798] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[130178] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[115104] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[121179] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[129872] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[115106] = { cameraID = 795, displayInfo = 73864, }, -- Arluelle
	[116372] = { cameraID = 795, displayInfo = 73864, }, -- Arluelle
	[115371] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[115503] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[115524] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[115693] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[115840] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[116087] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[116734] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[130200] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[115342] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[115374] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[115505] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[115710] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[116733] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[115506] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[131326] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[117030] = { cameraID = 130, displayInfo = 74292, }, -- Roland Abernathy
	[119532] = { cameraID = 130, displayInfo = 74292, }, -- Roland Abernathy
	[126307] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[120223] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[120372] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[120977] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[121157] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[121345] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[121617] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[122744] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[123232] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[125968] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[118882] = { cameraID = 141, displayInfo = 65757, }, -- Eitrigg
	[118449] = { cameraID = 82, displayInfo = 46573, }, -- Kanrethad Ebonlocke
	[118618] = { cameraID = 82, displayInfo = 46573, }, -- Kanrethad Ebonlocke
	[118476] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[121227] = { cameraID = 296, displayInfo = 27571, }, -- Illidan Stormrage
	[118871] = { cameraID = 795, displayInfo = 66261, }, -- Nighthuntress Syrenne
	[119055] = { cameraID = 109, displayInfo = 32254, }, -- Thisalee Crow
	[119065] = { cameraID = 141, displayInfo = 60003, }, -- Warsong Warrior
	[119078] = { cameraID = 109, displayInfo = 73135, }, -- Dreamgrove Protector
	[120036] = { cameraID = 109, displayInfo = 73135, }, -- Dreamgrove Protector
	[119082] = { cameraID = 795, displayInfo = 66261, }, -- Nightborne Huntress
	[121170] = { cameraID = 106, displayInfo = 75801, }, -- Prophet Velen
	[122800] = { cameraID = 106, displayInfo = 75801, }, -- Prophet Velen
	[121169] = { cameraID = 296, displayInfo = 75059, }, -- Illidan Stormrage
	[121880] = { cameraID = 296, displayInfo = 75059, }, -- Illidan Stormrage
	[122821] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[136683] = { cameraID = 114, displayInfo = 75730, }, -- Trade Prince Gallywix
	[129114] = { cameraID = 296, displayInfo = 74146, }, -- Illidan Stormrage
	[120738] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[120760] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[122378] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[122621] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[123687] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[124312] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[125512] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[126954] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[126950] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[128722] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[128725] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[128735] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[145580] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[146982] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[147494] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[147801] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[147842] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[147886] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[148177] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[148643] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[148798] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[149572] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[150574] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[150633] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[151866] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[152156] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[153461] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[153616] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[153822] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[165396] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[216207] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[218287] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[126620] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[130081] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[131290] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[132238] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[139293] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[140732] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[141136] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[177042] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[150542] = { cameraID = 82, displayInfo = 83315, }, -- Foundry Worker
	[133251] = { cameraID = 84, displayInfo = 88348, }, -- Lady Jaina Proudmoore
	[130444] = { cameraID = 130, displayInfo = 87531, }, -- Sludge Guard
	[130379] = { cameraID = 120, displayInfo = 78328, }, -- Dark Ranger
	[128949] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[131889] = { cameraID = 82, displayInfo = 78867, }, -- High Exarch Turalyon
	[137700] = { cameraID = 82, displayInfo = 78867, }, -- High Exarch Turalyon
	[146075] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[162235] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[208815] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[208837] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[208893] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[210390] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[210600] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[210605] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[210670] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[212202] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[212402] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[213996] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[214021] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[136725] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[142944] = { cameraID = 82, displayInfo = 79064, }, -- Freehold Porter
	[142873] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Cutthroat
	[145236] = { cameraID = 82, displayInfo = 79068, }, -- Irontide Cutthroat
	[142946] = { cameraID = 82, displayInfo = 79064, }, -- Great Sea Vagrant
	[142945] = { cameraID = 82, displayInfo = 80087, }, -- Great Sea Privateer
	[142899] = { cameraID = 82, displayInfo = 80339, }, -- Cutwater Duelist
	[176271] = { cameraID = 82, displayInfo = 80339, }, -- Cutwater Duelist
	[142894] = { cameraID = 90, displayInfo = 80380, }, -- Blacktooth Scrapper
	[142891] = { cameraID = 82, displayInfo = 80389, }, -- Blacktooth Brute
	[130532] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[131371] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[131479] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[141078] = { cameraID = 82, displayInfo = 81458, }, -- Vigil Hill Refugee
	[143552] = { cameraID = 130, displayInfo = 81649, }, -- Forsaken Battleguard
	[146965] = { cameraID = 130, displayInfo = 81649, }, -- Forsaken Battleguard
	[144498] = { cameraID = 82, displayInfo = 80389, }, -- Blacktooth Brute
	[143549] = { cameraID = 141, displayInfo = 81911, }, -- Peon
	[144388] = { cameraID = 82, displayInfo = 82545, }, -- Kul Tiran Noble
	[138714] = { cameraID = 105, displayInfo = 87525, }, -- Gilnean Mauler
	[139502] = { cameraID = 105, displayInfo = 87525, }, -- Gilnean Mauler
	[135435] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[155158] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[155614] = { cameraID = 795, displayInfo = 67345, }, -- First Arcanist Thalyssra
	[147724] = { cameraID = 82, displayInfo = 81351, }, -- Bridgeport Guard
	[144493] = { cameraID = 82, displayInfo = 85767, }, -- 7th Legion Marine
	[155119] = { cameraID = 90, displayInfo = 53107, }, -- 7th Legion Rifleman
	[139555] = { cameraID = 82, displayInfo = 78480, }, -- Boralus Worker
	[143386] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[150323] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[146969] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[164072] = { cameraID = 82, displayInfo = 75811, }, -- High Exarch Turalyon
	[146931] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[148910] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[200648] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[145423] = { cameraID = 130, displayInfo = 86536, }, -- Thomas Zelling
	[145564] = { cameraID = 130, displayInfo = 86536, }, -- Thomas Zelling
	[143530] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[150206] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[151851] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[153422] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[155241] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[195080] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[240265] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[245458] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[248842] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[251337] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[254396] = { cameraID = 793, displayInfo = 73853, }, -- Chief Telemancer Oculeth
	[140601] = { cameraID = 120, displayInfo = 86752, }, -- Blood Marquess
	[151085] = { cameraID = 82, displayInfo = 86639, }, -- Kul Tiran Executioner
	[224823] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[142486] = { cameraID = 84, displayInfo = 80015, }, -- Jaina Proudmoore
	[142422] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[157024] = { cameraID = 141, displayInfo = 82115, }, -- Eitrigg
	[145996] = { cameraID = 82, displayInfo = 85758, }, -- Halford Wyrmbane
	[147798] = { cameraID = 82, displayInfo = 85758, }, -- Halford Wyrmbane
	[147888] = { cameraID = 82, displayInfo = 85758, }, -- Halford Wyrmbane
	[146009] = { cameraID = 90, displayInfo = 32681, }, -- Falstad Wildhammer
	[146676] = { cameraID = 813, displayInfo = 65183, }, -- Sira Moonwarden
	[149126] = { cameraID = 813, displayInfo = 65183, }, -- Sira Moonwarden
	[216069] = { cameraID = 575, displayInfo = 88958, }, -- Malfurion Stormrage
	[146734] = { cameraID = 126, displayInfo = 63690, }, -- Spiritwalker Ebonhorn
	[145906] = { cameraID = 141, displayInfo = 89091, }, -- Horde Berserker
	[146535] = { cameraID = 141, displayInfo = 89091, }, -- Horde Berserker
	[147371] = { cameraID = 141, displayInfo = 89091, }, -- Horde Berserker
	[151867] = { cameraID = 82, displayInfo = 88653, }, -- Tandred Proudmoore
	[146775] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[147472] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[147800] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[147843] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[147887] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[148181] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[148286] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[148521] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[148629] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[148949] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[149049] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[150620] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[150640] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[152157] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[153466] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[155788] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[161459] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[162178] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[192203] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[198983] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[146629] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[184727] = { cameraID = 109, displayInfo = 86964, }, -- Shandris Feathermoon
	[148120] = { cameraID = 82, displayInfo = 86025, }, -- Kul Tiran Marine
	[147553] = { cameraID = 82, displayInfo = 76222, }, -- Flynn Fairwind
	[147306] = { cameraID = 141, displayInfo = 89545, }, -- Horde Berserker
	[147363] = { cameraID = 141, displayInfo = 89545, }, -- Horde Berserker
	[147992] = { cameraID = 141, displayInfo = 89545, }, -- Horde Berserker
	[148909] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[254400] = { cameraID = 795, displayInfo = 73854, }, -- Arcanist Valtrois
	[215634] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[218639] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[256008] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[206482] = { cameraID = 109, displayInfo = 88840, }, -- Kaldorei Huntress
	[148965] = { cameraID = 82, displayInfo = 86025, }, -- Kul Tiran Marine
	[156587] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[162208] = { cameraID = 84, displayInfo = 87892, }, -- Lady Jaina Proudmoore
	[149858] = { cameraID = 141, displayInfo = 85151, }, -- Orc Warrior
	[149868] = { cameraID = 90, displayInfo = 26353, }, -- Brann Bronzebeard
	[150144] = { cameraID = 90, displayInfo = 26353, }, -- Brann Bronzebeard
	[150865] = { cameraID = 90, displayInfo = 26353, }, -- Brann Bronzebeard
	[156609] = { cameraID = 90, displayInfo = 91995, }, -- Bjorn Stouthands
	[157044] = { cameraID = 90, displayInfo = 91995, }, -- Bjorn Stouthands
	[158320] = { cameraID = 120, displayInfo = 85924, }, -- Lady Liadrin
	[226656] = { cameraID = 120, displayInfo = 85924, }, -- Lady Liadrin
	[156425] = { cameraID = 120, displayInfo = 70830, }, -- Dark Ranger Lenara
	[153280] = { cameraID = 141, displayInfo = 81646, }, -- Baine Bloodhoof
	[182712] = { cameraID = 141, displayInfo = 81646, }, -- Baine Bloodhoof
	[184722] = { cameraID = 141, displayInfo = 81646, }, -- Baine Bloodhoof
	[180861] = { cameraID = 1577, displayInfo = 93583, }, -- Broker Ve'ken
	[155142] = { cameraID = 82, displayInfo = 89554, }, -- Alliance Warrior
	[153372] = { cameraID = 82, displayInfo = 89554, }, -- Injured Soldier
	[156611] = { cameraID = 82, displayInfo = 89554, }, -- Injured Soldier
	[154055] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[203522] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[206521] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[155197] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[156536] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[156833] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[156859] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[156887] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[156942] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[156962] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[245594] = { cameraID = 82, displayInfo = 92751, }, -- Henry Garrick
	[154264] = { cameraID = 82, displayInfo = 89554, }, -- Alliance Warrior
	[154613] = { cameraID = 90, displayInfo = 91995, }, -- Bjorn Stouthands
	[156891] = { cameraID = 90, displayInfo = 91995, }, -- Bjorn Stouthands
	[155156] = { cameraID = 84, displayInfo = 87892, }, -- Jaina Proudmoore
	[184097] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[156626] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[156807] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[156961] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[245397] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[245686] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[178284] = { cameraID = 268, displayInfo = 30408, }, -- Erunak Stonespeaker
	[160664] = { cameraID = 82, displayInfo = 94939, }, -- Private Cole
	[156944] = { cameraID = 109, displayInfo = 91010, }, -- Ralia Dreamchaser
	[156947] = { cameraID = 109, displayInfo = 91010, }, -- Ralia Dreamchaser
	[164907] = { cameraID = 109, displayInfo = 91010, }, -- Ralia Dreamchaser
	[158200] = { cameraID = 84, displayInfo = 67214, }, -- Valeera Sanguinar
	[170238] = { cameraID = 141, displayInfo = 70436, }, -- Nazgrim
	[162550] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[164551] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[164896] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[165199] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[165417] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[165795] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[165950] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[166634] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[171660] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[173627] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[173979] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[174253] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[174801] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[175065] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[175423] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[178035] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[178807] = { cameraID = 82, displayInfo = 94718, }, -- Alexandros Mograine
	[163024] = { cameraID = 82, displayInfo = 95034, }, -- Coulston Nereus
	[170468] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[177228] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[177230] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[178814] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[181183] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[181229] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[181280] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[181367] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[181379] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[181486] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[184601] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[184698] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[200644] = { cameraID = 141, displayInfo = 7889, }, -- Kadrak
	[169070] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[171035] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[176554] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[181883] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[182764] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[184726] = { cameraID = 82, displayInfo = 27153, }, -- Highlord Darion Mograine
	[167675] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[167926] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[171281] = { cameraID = 109, displayInfo = 97529, }, -- Night Elf Soul
	[171282] = { cameraID = 109, displayInfo = 97529, }, -- Night Elf Soul
	[174849] = { cameraID = 84, displayInfo = 80015, }, -- Lady Jaina Proudmoore
	[179152] = { cameraID = 84, displayInfo = 80015, }, -- Lady Jaina Proudmoore
	[184597] = { cameraID = 84, displayInfo = 80015, }, -- Lady Jaina Proudmoore
	[174287] = { cameraID = 119, displayInfo = 94481, }, -- Kael'thas Sunstrider
	[174414] = { cameraID = 119, displayInfo = 94481, }, -- Kael'thas Sunstrider
	[177216] = { cameraID = 119, displayInfo = 94481, }, -- Kael'thas Sunstrider
	[189600] = { cameraID = 82, displayInfo = 100074, }, -- High Exarch Turalyon
	[214277] = { cameraID = 82, displayInfo = 100074, }, -- High Exarch Turalyon
	[223205] = { cameraID = 82, displayInfo = 100074, }, -- High Exarch Turalyon
	[226650] = { cameraID = 82, displayInfo = 100074, }, -- High Exarch Turalyon
	[175649] = { cameraID = 82, displayInfo = 61582, }, -- Croman
	[179687] = { cameraID = 84, displayInfo = 95032, }, -- Sylvanas Windrunner
	[180828] = { cameraID = 84, displayInfo = 95032, }, -- Sylvanas Windrunner
	[177925] = { cameraID = 1577, displayInfo = 95004, }, -- Ve'nari
	[179398] = { cameraID = 84, displayInfo = 100591, }, -- Sylvanas Windrunner
	[184599] = { cameraID = 109, displayInfo = 100684, }, -- Thrall
	[181328] = { cameraID = 1577, displayInfo = 101355, }, -- Ve'nish
	[189389] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[216949] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[231544] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[181277] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[181390] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[181786] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[183664] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[183717] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[183724] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[184714] = { cameraID = 84, displayInfo = 104817, }, -- Lady Jaina Proudmoore
	[181282] = { cameraID = 109, displayInfo = 104820, }, -- Thrall
	[181394] = { cameraID = 109, displayInfo = 104820, }, -- Thrall
	[181785] = { cameraID = 109, displayInfo = 104820, }, -- Thrall
	[184099] = { cameraID = 109, displayInfo = 104820, }, -- Thrall
	[183766] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[184473] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[186210] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[186218] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[189325] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[189484] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[190236] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[190250] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[192246] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[193954] = { cameraID = 146, displayInfo = 102175, }, -- Dervishian
	[191685] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[191769] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[182274] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[183761] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[184309] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[199204] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[199339] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[188621] = { cameraID = 146, displayInfo = 104834, }, -- Injured Talon
	[184308] = { cameraID = 146, displayInfo = 104904, }, -- Scalecommander Sarkareth
	[193335] = { cameraID = 146, displayInfo = 104904, }, -- Scalecommander Sarkareth
	[183677] = { cameraID = 1079, displayInfo = 105509, }, -- Uther the Lightbringer
	[184802] = { cameraID = 1079, displayInfo = 105509, }, -- Uther the Lightbringer
	[185172] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[187167] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[192354] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[200554] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[187165] = { cameraID = 146, displayInfo = 104839, }, -- Dark Talon
	[192311] = { cameraID = 146, displayInfo = 104839, }, -- Dark Talon
	[189934] = { cameraID = 146, displayInfo = 104727, }, -- Ebon Scale
	[186301] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[191542] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[192091] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[193837] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[185145] = { cameraID = 1079, displayInfo = 105509, }, -- Uther the Lightbringer
	[197908] = { cameraID = 146, displayInfo = 104726, }, -- Mage Talon
	[192404] = { cameraID = 146, displayInfo = 104861, }, -- Siaszerathel
	[199608] = { cameraID = 146, displayInfo = 104861, }, -- Siaszerathel
	[206964] = { cameraID = 146, displayInfo = 104861, }, -- Siaszerathel
	[209020] = { cameraID = 146, displayInfo = 104861, }, -- Siaszerathel
	[193831] = { cameraID = 120, displayInfo = 108314, }, -- Soridormi
	[201022] = { cameraID = 120, displayInfo = 108314, }, -- Soridormi
	[190265] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[185419] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[186132] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[186145] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[197472] = { cameraID = 126, displayInfo = 63690, }, -- Ebyssian
	[189333] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[189502] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[193366] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[194126] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[226763] = { cameraID = 120, displayInfo = 105169, }, -- Naleidea Rivergleam
	[185792] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[185851] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[185850] = { cameraID = 130, displayInfo = 90381, }, -- Deathstalker Commander Belmont
	[185794] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[185831] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[185849] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[196219] = { cameraID = 82, displayInfo = 105421, }, -- Masud the Wise
	[185908] = { cameraID = 146, displayInfo = 104834, }, -- Containment Field
	[187344] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[187435] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[190842] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[191764] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[199609] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[203804] = { cameraID = 126, displayInfo = 105538, }, -- Andantenormu
	[199767] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[199894] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[199924] = { cameraID = 130, displayInfo = 90372, }, -- Master Apothecary Faranell
	[199768] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[199879] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[199886] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[199927] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[208247] = { cameraID = 120, displayInfo = 105389, }, -- Dark Ranger Velonara
	[197378] = { cameraID = 120, displayInfo = 104535, }, -- Sindragosa
	[200479] = { cameraID = 120, displayInfo = 104535, }, -- Sindragosa
	[200036] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[200099] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[200167] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[200264] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[200448] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[201167] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[203729] = { cameraID = 120, displayInfo = 61799, }, -- Stellagosa
	[186779] = { cameraID = 82, displayInfo = 106239, }, -- Archmage Khadgar
	[241740] = { cameraID = 82, displayInfo = 106239, }, -- Archmage Khadgar
	[204102] = { cameraID = 130, displayInfo = 106063, }, -- Examiner Rowe
	[206688] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[211214] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[213823] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[192322] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[197931] = { cameraID = 82, displayInfo = 107041, }, -- Archmage Khadgar
	[192474] = { cameraID = 82, displayInfo = 107875, }, -- Zepharion
	[196156] = { cameraID = 141, displayInfo = 107533, }, -- Baskilan
	[192241] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[231540] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[194198] = { cameraID = 109, displayInfo = 91239, }, -- Merithra
	[195153] = { cameraID = 109, displayInfo = 91239, }, -- Merithra
	[198365] = { cameraID = 109, displayInfo = 91239, }, -- Merithra
	[204057] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[203084] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[204698] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[196213] = { cameraID = 120, displayInfo = 107704, }, -- Narsysix
	[200556] = { cameraID = 146, displayInfo = 104841, }, -- Dark Talon
	[197486] = { cameraID = 146, displayInfo = 104843, }, -- Obsidian Warder
	[197487] = { cameraID = 146, displayInfo = 104844, }, -- Obsidian Warder
	[197489] = { cameraID = 146, displayInfo = 104846, }, -- Obsidian Warder
	[197483] = { cameraID = 146, displayInfo = 104841, }, -- Dark Talon
	[197484] = { cameraID = 146, displayInfo = 104842, }, -- Dark Talon
	[197481] = { cameraID = 146, displayInfo = 104839, }, -- Dark Talon
	[197482] = { cameraID = 146, displayInfo = 104840, }, -- Dark Talon
	[196797] = { cameraID = 146, displayInfo = 108358, }, -- Iristimat
	[196796] = { cameraID = 146, displayInfo = 108452, }, -- Eraleshk
	[195468] = { cameraID = 146, displayInfo = 108879, }, -- Eager Freshscale
	[200277] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[200590] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[201233] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[201238] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[201281] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[201366] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[199329] = { cameraID = 146, displayInfo = 104555, }, -- Scalecommander Viridia
	[208987] = { cameraID = 146, displayInfo = 104555, }, -- Scalecommander Viridia
	[200403] = { cameraID = 146, displayInfo = 110584, }, -- Talon Damos
	[200459] = { cameraID = 146, displayInfo = 110584, }, -- Talon Damos
	[200755] = { cameraID = 146, displayInfo = 110584, }, -- Talon Damos
	[202687] = { cameraID = 146, displayInfo = 110584, }, -- Talon Damos
	[205925] = { cameraID = 146, displayInfo = 110585, }, -- Talon Ekrati
	[203284] = { cameraID = 146, displayInfo = 104904, }, -- Scalecommander Sarkareth
	[204702] = { cameraID = 146, displayInfo = 104904, }, -- Scalecommander Sarkareth
	[199983] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[201677] = { cameraID = 146, displayInfo = 110856, }, -- Winglord Dezran
	[202671] = { cameraID = 146, displayInfo = 110856, }, -- Winglord Dezran
	[202721] = { cameraID = 146, displayInfo = 110856, }, -- Winglord Dezran
	[199885] = { cameraID = 130, displayInfo = 114139, }, -- Deathstalker Commander Belmont
	[199895] = { cameraID = 130, displayInfo = 114139, }, -- Deathstalker Commander Belmont
	[199925] = { cameraID = 130, displayInfo = 114139, }, -- Deathstalker Commander Belmont
	[208214] = { cameraID = 130, displayInfo = 114139, }, -- Deathstalker Commander Belmont
	[200795] = { cameraID = 120, displayInfo = 19806, }, -- Haleh
	[201169] = { cameraID = 120, displayInfo = 19806, }, -- Haleh
	[201240] = { cameraID = 146, displayInfo = 111249, }, -- Volethi
	[200882] = { cameraID = 120, displayInfo = 110573, }, -- Lanigosa
	[201172] = { cameraID = 120, displayInfo = 110573, }, -- Lanigosa
	[206960] = { cameraID = 90, displayInfo = 106900, }, -- Sonova Snowden
	[203087] = { cameraID = 126, displayInfo = 111354, }, -- Ebyssian
	[203285] = { cameraID = 126, displayInfo = 111354, }, -- Ebyssian
	[204697] = { cameraID = 126, displayInfo = 111354, }, -- Ebyssian
	[204700] = { cameraID = 126, displayInfo = 111354, }, -- Ebyssian
	[202995] = { cameraID = 126, displayInfo = 110926, }, -- Ebyssian
	[210555] = { cameraID = 146, displayInfo = 111693, }, -- Amythora
	[210557] = { cameraID = 146, displayInfo = 111694, }, -- Marithos
	[254592] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[255063] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[257541] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[210955] = { cameraID = 109, displayInfo = 113045, }, -- Belysra Starbreeze
	[217182] = { cameraID = 109, displayInfo = 113045, }, -- Belysra Starbreeze
	[209051] = { cameraID = 109, displayInfo = 113795, }, -- Merithra of the Dream
	[213128] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[214246] = { cameraID = 109, displayInfo = 113000, }, -- Merithra
	[208050] = { cameraID = 82, displayInfo = 113292, }, -- Great Glorious Alliance Footman
	[208224] = { cameraID = 82, displayInfo = 113292, }, -- Great Glorious Alliance Footman
	[208048] = { cameraID = 82, displayInfo = 113294, }, -- Great Glorious Alliance Paladin
	[208049] = { cameraID = 90, displayInfo = 113296, }, -- Great Glorious Alliance Musketeer
	[208085] = { cameraID = 141, displayInfo = 113301, }, -- Blood Horde Grunt
	[208225] = { cameraID = 141, displayInfo = 113301, }, -- Blood Horde Grunt
	[208087] = { cameraID = 141, displayInfo = 113303, }, -- Blood Horde Shaman
	[213819] = { cameraID = 109, displayInfo = 108146, }, -- Otharia
	[212325] = { cameraID = 120, displayInfo = 102886, }, -- Primalist Flamewarden
	[211375] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[211752] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[214402] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[215446] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[216148] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[216518] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[217282] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[217385] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[219252] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[220536] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[223256] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[223944] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[227758] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[228457] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[228493] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[230062] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[235609] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[235715] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[235726] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[239574] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[239826] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[245309] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[245523] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[247434] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[248866] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[249501] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[217386] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[219253] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[239473] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[242395] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[243992] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[246159] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[246675] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[249289] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[250261] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[251868] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[251946] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[253143] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[214355] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[214362] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[214377] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[215447] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[216147] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[216517] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[217886] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[220557] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[221866] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[222558] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[223982] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[225897] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[228454] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[229327] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[229843] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[230055] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[221387] = { cameraID = 268, displayInfo = 71623, }, -- Farseer Nobundo
	[229318] = { cameraID = 1799, displayInfo = 114662, }, -- Queensguard Zirix
	[230106] = { cameraID = 1799, displayInfo = 114662, }, -- Queensguard Zirix
	[228812] = { cameraID = 1799, displayInfo = 115010, }, -- Armored Subjugator
	[214908] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[215666] = { cameraID = 82, displayInfo = 115013, }, -- Velhanite Citizen
	[229453] = { cameraID = 82, displayInfo = 115283, }, -- Aelric Leid
	[230060] = { cameraID = 82, displayInfo = 115283, }, -- Aelric Leid
	[214983] = { cameraID = 82, displayInfo = 104559, }, -- Sabellian
	[216167] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[228456] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[229041] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[229321] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[217171] = { cameraID = 105, displayInfo = 116367, }, -- Greyguard Elite
	[245310] = { cameraID = 1860, displayInfo = 78749, }, -- Locus-Walker
	[245525] = { cameraID = 1860, displayInfo = 78749, }, -- Locus-Walker
	[247435] = { cameraID = 1860, displayInfo = 78749, }, -- Locus-Walker
	[249506] = { cameraID = 1860, displayInfo = 78749, }, -- Locus-Walker
	[223607] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[228963] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[229325] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[233237] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[235811] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[244655] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[244658] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[244667] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[244714] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[218281] = { cameraID = 82, displayInfo = 65834, }, -- Archmage Khadgar
	[216552] = { cameraID = 141, displayInfo = 91670, }, -- Horde Wolfaxe
	[229328] = { cameraID = 795, displayInfo = 66275, }, -- Suramar Chronomancer
	[229316] = { cameraID = 130, displayInfo = 72563, }, -- Forsaken Warlock
	[220805] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[241510] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[241912] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[218549] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[227136] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[232296] = { cameraID = 90, displayInfo = 115505, }, -- Brann Bronzebeard
	[227225] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[230155] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[231546] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[233231] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[245524] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[247433] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[258536] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[223051] = { cameraID = 82, displayInfo = 119057, }, -- Stromgarde Footman
	[242585] = { cameraID = 82, displayInfo = 125322, }, -- Archmage Khadgar
	[229448] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[235664] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[253361] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[230811] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[231524] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[236836] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[230658] = { cameraID = 120, displayInfo = 131474, }, -- Xal'atath
	[230825] = { cameraID = 120, displayInfo = 131474, }, -- Xal'atath
	[235448] = { cameraID = 120, displayInfo = 131474, }, -- Xal'atath
	[236835] = { cameraID = 1577, displayInfo = 122330, }, -- Om'resh
	[234602] = { cameraID = 120, displayInfo = 131464, }, -- Alleria Windrunner
	[243653] = { cameraID = 120, displayInfo = 131464, }, -- Alleria Windrunner
	[233706] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[242936] = { cameraID = 1860, displayInfo = 131473, }, -- Locus-Walker
	[241913] = { cameraID = 141, displayInfo = 128707, }, -- Eitrigg
	[235155] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[238757] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[240818] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[240859] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[241051] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[242538] = { cameraID = 1577, displayInfo = 130488, }, -- Ve'nari
	[239119] = { cameraID = 114, displayInfo = 75730, }, -- Jastor Gallywix
	[235290] = { cameraID = 90, displayInfo = 127693, }, -- Hemet Nesingwary
	[235353] = { cameraID = 90, displayInfo = 127693, }, -- Hemet Nesingwary
	[236846] = { cameraID = 90, displayInfo = 127693, }, -- Hemet Nesingwary
	[236890] = { cameraID = 90, displayInfo = 127693, }, -- Hemet Nesingwary
	[238541] = { cameraID = 90, displayInfo = 127693, }, -- Hemet Nesingwary
	[237225] = { cameraID = 141, displayInfo = 124748, }, -- Orgrim Doomhammer
	[236571] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[236778] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[239810] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[241046] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[256007] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[258952] = { cameraID = 82, displayInfo = 141146, }, -- High Exarch Turalyon
	[237601] = { cameraID = 130, displayInfo = 141282, }, -- Alonsus Faol
	[239722] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[241171] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[243441] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[244745] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[247664] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[247674] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[252461] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[257416] = { cameraID = 1208, displayInfo = 136415, }, -- Lady Darkglen
	[239659] = { cameraID = 1208, displayInfo = 136414, }, -- Riftblade Maella
	[239802] = { cameraID = 1208, displayInfo = 136414, }, -- Riftblade Maella
	[252460] = { cameraID = 1208, displayInfo = 136414, }, -- Riftblade Maella
	[253266] = { cameraID = 1208, displayInfo = 136414, }, -- Riftblade Maella
	[254403] = { cameraID = 1208, displayInfo = 136414, }, -- Riftblade Maella
	[248636] = { cameraID = 130, displayInfo = 141282, }, -- Alonsus Faol
	[253197] = { cameraID = 130, displayInfo = 141282, }, -- Alonsus Faol
	[242077] = { cameraID = 120, displayInfo = 128683, }, -- Vereesa Windrunner
	[250288] = { cameraID = 120, displayInfo = 128683, }, -- Vereesa Windrunner
	[244920] = { cameraID = 82, displayInfo = 119046, }, -- Danath Trollbane
	[252941] = { cameraID = 82, displayInfo = 128320, }, -- Light's Vanguard
	[254055] = { cameraID = 795, displayInfo = 66275, }, -- Nightborne Arcanist
	[254408] = { cameraID = 120, displayInfo = 29611, }, -- Captain Elleane Wavecrest
	[249504] = { cameraID = 120, displayInfo = 117121, }, -- Xal'atath
	[252282] = { cameraID = 82, displayInfo = 129720, }, -- High Exarch Turalyon
	[259041] = { cameraID = 82, displayInfo = 129720, }, -- High Exarch Turalyon
	[256440] = { cameraID = 90, displayInfo = 129865, }, -- Light's Vanguard
	[254316] = { cameraID = 1208, displayInfo = 140104, }, -- Leona Darkstrider
	[22917] = { cameraID = 296 }, -- Illidan Stormrage
	[30115] = { cameraID = 120 }, -- Vereesa Windrunner
	[36597] = { cameraID = 88 }, -- The Lich King
	[36648] = { cameraID = 141 }, -- Baine Bloodhoof
	[101605] = { cameraID = 114 }, -- Trade Prince Gallywix
	[118927] = { cameraID = 82 }, -- Kanrethad Ebonlocke
	[158588] = { cameraID = 126 }, -- Gamon
	[166619] = { cameraID = 1079 }, -- Uther
	[179475] = { cameraID = 119 }, -- Kael'thas Sunstrider
	[193211] = { cameraID = 575 }, -- Malfurion Stormrage
	[193459] = { cameraID = 82 }, -- Archmage Khadgar
	[198884] = { cameraID = 82 }, -- Master Mathias Shaw
	[203683] = { cameraID = 142 }, -- Rexxar
	[205067] = { cameraID = 109 }, -- Shandris Feathermoon
	[206533] = { cameraID = 82 }, -- Chef Dinaire
	[208649] = { cameraID = 126 }, -- Archdruid Hamuul Runetotem
	[209704] = { cameraID = 144 }, -- Chen Stormstout
	[224220] = { cameraID = 84 }, -- Abigail Cyrildotr
}