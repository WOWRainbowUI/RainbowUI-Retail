local MAJOR, MINOR = "EZBlizzardUiPopups_Data", 4
local EZBUP_DATA = LibStub:NewLibrary(MAJOR, MINOR)
if not EZBUP_DATA then
    -- A newer version is already loaded
    return
end

EZBUP_DATA.SoundFileIDBank = {
	[203314] = { soundQuotes = { 2416552, 2416540, 2416542, 2416543 } }, -- Baine Bloodhoof
	[177114] = { soundQuotes = { 1801002, 1801005, 1800995, 561301 } }, -- Sylvanas Windrunner
	[230055] = { soundQuotes = { 5725623, 5725624, 5725625, 5725634, 5725619, 5725620, 5725630 } }, -- Anduin Wrynn
	[49587]  = { soundQuotes = { 552227, 552221 } }, -- Guild Herald
	[29611]  = { soundQuotes = { 563552, 563519, 563537, 563479 } }, -- King Varian Wrynn
	[191205] = { soundQuotes = { 1486698, 1486699, 1486701, 1486702, 1486703, 1486704 } }, -- Hemet Nesingwary
	[229150] = { soundQuotes = { 1388284, 1388286, 1388282 } }, -- Lord Jorach Ravenholdt
	[185157] = { soundQuotes = { 3597128, 3597129, 563239 } }, -- Uther
	[210670] = { soundQuotes = { 1055403, 1055404, 1055405, 1055406, 1055399, 1055400, 1055402 } }, -- Prophet Velen
	[212343] = { soundQuotes = { 1373762, 1373763, 1373756, 1373757, 1373758, 1373759 } }, -- Farseer Nobundo
	[241743] = { soundQuotes = { 4639084, 4639095, 4639096, 4639097, 4639090 } }, -- Archmage Khadgar
	[81822]  = { soundQuotes = { 546172, 546153, 546103, 546166 } }, -- Cho'gall
	[250594] = { soundQuotes = { 634292, 634296, 634290, 634294 } }, -- Chen Stormstout
	[216069] = { soundQuotes = { 2468393, 2468394, 2468396, 2468397 } }, -- Malfurion Stormrage
	[129114] = { soundQuotes = { 552503, 552514, 1689235, 1689238, 1689239, 1689240, 1689241, 1699667 } }, -- Illidan Stormrage
	[36597]  = { soundQuotes = { 554123, 554181, 553997, 554089, 554172, 554085 } }, -- The Lich King
	[49590]  = { soundQuotes = { 557802, 557807, 557801, 557804, 557800, 557809, 557799, 557806, 557814 } }, -- Guild Herald
	[229321] = { soundQuotes = { 5758117, 5758118, 5758119, 5758114, 5758115, 5758116, 2922115 } }, -- Thrall
	[136683] = { soundQuotes = { 1860609, 1860611, 1860613, 1860622, 1860626 } }, -- Trade Prince Gallywix
	[216682] = { soundQuotes = { 5482269, 4288146, 4288143 } }, -- Shandris Feathermoon
	[216115] = { soundQuotes = { 1388445, 1388442, 1388449, 1388451 } }, -- Master Mathias Shaw
	[172181] = { soundQuotes = { 897314, 897322, 897324 } }, -- Gamon
	[200648] = { soundQuotes = { 2011278, 2011283, 2011276, 2011282 } }, -- Rexxar
	[229128] = { soundQuotes = { 1388604, 1388606, 1388608 } }, -- Valeera Sanguinar
	[216168] = { soundQuotes = { 2012996, 2012998, 2012999, 2013000, 2013002, 5828671, 5828672, 2012993, 2012994 } }, -- Lady Jaina Proudmoore
	[107025] = { soundQuotes = { 1388273, 1388275, 1388276, 1388278 } }, -- Archdruid Hamuul Runetotem
	[156180] = { soundQuotes = { 2012223, 2012224, 2012212, 2012213, 2012214, 2012216, 2012217, 2012226 } }, -- Varok Saurfang
	[118618] = { soundQuotes = { 1581925, 1581926, 1581927 } }, -- Kanrethad Ebonlocke
	[143425] = { soundQuotes = { 549620, 896000, 896028, 896036 } }, -- Echo of Garrosh Hellscream
	[226656] = { soundQuotes = { 1388292, 1388295, 1388297, 1388298 } }, -- Lady Liadrin
	[186182] = { soundQuotes = { 1388191, 1388193, 1388189, 1388196 } }, -- Alonsus Faol
	[177216] = { soundQuotes = { 3620551, 3620554, 558296 } }, -- Kael'thas Sunstrider
	[164079] = { soundQuotes = { 3698917, 3698918, 3698920, 3698921, 3698922, 3698912, 3698913, 3698914 } }, -- Highlord Bolvar Fordragon
	[223205] = { soundQuotes = { 4659345, 4659349, 4659346, 4659338 } }, -- High Exarch Turalyon
	[230062] = { soundQuotes = { 5725989, 5725999, 5725985, 5725991, 5726000 } }, -- Alleria Windrunner
	[181056] = { soundQuotes = { 4659468, 4659471, 4659467 } }, -- Scalecommander Azurathel
	[181055] = { soundQuotes = { 4661200, 4661197, 4661198, 4661203 } }, -- Scalecommander Cindrethresh
	[206533] = { soundQuotes = { 5725530, 5725538, 5725546, 5725413 } }, -- Chef Dinaire
	[250382] = { soundQuotes = { 1388723, 1388707, 1388710, 1388737 } }, -- Vereesa Windrunner
	[224220] = { soundQuotes = { 6023950 } }, -- Abigail Cyrildotr
	[235448] = { soundQuotes = { 6708204, 2530795 } }, -- Xal'atath
	[215113] = { soundQuotes = { 5722457 } }, -- Orweyna
	[225585] = { soundQuotes = { 5722458 } }, -- Widow Arak'nai
	[256078] = { soundQuotes = { 7235360, 7235353, 7235356 } }, -- Lyssabel Dawnpetal
	[233062] = { soundQuotes = { 7235436, 7235389 } }, -- Tocho Cloudhide
	[255283] = { soundQuotes = { 1800449, 1800441 } }, -- Magister Umbric
	[250395] = { soundQuotes = { 1801067, 1801060 } }, -- Grand Magister Rommath
	--Lor’themar Theron
	[253366] = { soundQuotes = { 7354186, 7354217, 7354188, 7354214, 7354215 } }, -- Arator
	[249488] = { soundQuotes = { 7273906, 7273907 } }, -- Dundun
	[243708] = { soundQuotes = { 7303106, 7325673 } }, -- Decimus
	[259222] = { soundQuotes = { 7271257, 7271235 } }, -- Zul'jarra
}

EZBUP_DATA.CreaturexCameraID = {
	[29611] = { cameraID = 82, displayInfo = 28127, }, -- King Varian Wrynn
	[49587] = { cameraID = 82, displayInfo = 37198, }, -- Guild Herald
	[49590] = { cameraID = 141, displayInfo = 37196, }, -- Guild Herald
	[143425] = { cameraID = 86, displayInfo = 87839, }, -- Echo of Garrosh Hellscream
	[156180] = { cameraID = 109, displayInfo = 93468, }, -- Varok Saurfang
	[164079] = { cameraID = 82, displayInfo = 95194, }, -- Highlord Bolvar Fordragon
	[172181] = { cameraID = 126, displayInfo = 64797, }, -- Gamon
	[177114] = { cameraID = 84, displayInfo = 95032, }, -- Sylvanas Windrunner
	[181055] = { cameraID = 146, displayInfo = 102033, }, -- Scalecommander Cindrethresh
	[181056] = { cameraID = 146, displayInfo = 102032, }, -- Scalecommander Azurathel
	[185157] = { cameraID = 1079, displayInfo = 105509, }, -- Uther
	[191205] = { cameraID = 90, displayInfo = 107387, }, -- Hemet Nesingwary
	[203314] = { cameraID = 141, displayInfo = 111901, }, -- Baine Bloodhoof
	[212343] = { cameraID = 268, displayInfo = 71623, }, -- Farseer Nobundo
	[215113] = { cameraID = 1849, displayInfo = 117116, }, -- Orweyna
	[216115] = { cameraID = 82, displayInfo = 72253, }, -- Master Mathias Shaw
	[216168] = { cameraID = 84, displayInfo = 88316, }, -- Lady Jaina Proudmoore
	[216682] = { cameraID = 101, displayInfo = 116646, }, -- Shandris Feathermoon
	[225585] = { cameraID = 1797, displayInfo = 116208, }, -- Widow Arak'nai
	[229150] = { cameraID = 82, displayInfo = 69542, }, -- Lord Jorach Ravenholdt
	[233062] = { cameraID = 126, displayInfo = 131513, }, -- Tocho Cloudhide
	[241743] = { cameraID = 82, displayInfo = 64045, }, -- Archmage Khadgar
	[243708] = { cameraID = 1890, displayInfo = 130002, }, -- Decimus
	[249488] = { cameraID = 1888, displayInfo = 128490, }, -- Dundun
	[250382] = { cameraID = 120, displayInfo = 28222, }, -- Vereesa Windrunner
	[250594] = { cameraID = 144, displayInfo = 40962, }, -- Chen Stormstout
	[81822] = { cameraID = 815, displayInfo = 59707, }, -- Cho'gall
	[229128] = { cameraID = 84, displayInfo = 26365, }, -- Valeera Sanguinar
	[107025] = { cameraID = 126, displayInfo = 31605, }, -- Archdruid Hamuul Runetotem
	[186182] = { cameraID = 130, displayInfo = 67043, }, -- Alonsus Faol
	[118618] = { cameraID = 82, displayInfo = 46573, }, -- Kanrethad Ebonlocke
	[136683] = { cameraID = 1247, displayInfo = 75730, }, -- Trade Prince Gallywix
	[129114] = { cameraID = 296, displayInfo = 74146, }, -- Illidan Stormrage
	[210670] = { cameraID = 106, displayInfo = 17822, }, -- Prophet Velen
	[200648] = { cameraID = 142, displayInfo = 60766, }, -- Rexxar
	[216069] = { cameraID = 575, displayInfo = 88958, }, -- Malfurion Stormrage
	[226656] = { cameraID = 120, displayInfo = 85924, }, -- Lady Liadrin
	[177216] = { cameraID = 119, displayInfo = 94481, }, -- Kael'thas Sunstrider
	[223205] = { cameraID = 82, displayInfo = 100074, }, -- High Exarch Turalyon
	[230062] = { cameraID = 120, displayInfo = 118072, }, -- Alleria Windrunner
	[230055] = { cameraID = 82, displayInfo = 115995, }, -- Anduin Wrynn
	[229321] = { cameraID = 109, displayInfo = 115495, }, -- Thrall
	[235448] = { cameraID = 120, displayInfo = 131474, }, -- Xal'atath
	[255283] = { cameraID = 1209, displayInfo = 128688, }, -- Magister Umbric
	[250395] = { cameraID = 118, displayInfo = 63775, }, -- Grand Magister Rommath
	[253366] = { cameraID = 1885, displayInfo = 124777, }, -- Arator
	[259222] = { cameraID = 1879, displayInfo = 125149, }, -- Zul'jarra
	[36597] = { cameraID = 88 }, -- The Lich King
	[206533] = { cameraID = 82 }, -- Chef Dinaire
	[224220] = { cameraID = 84 }, -- Abigail Cyrildotr
	[256078] = { cameraID = 101 }, -- Lyssabel Dawnpetal
}
