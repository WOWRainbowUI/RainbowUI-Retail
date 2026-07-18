-- [[ REALM FLAGS DATABASE ]] --
-- GENERATED FILE - regenerate with RealmUpdater\Update-Realms.ps1 (Blizzard Game Data API).
-- Data pulled: 2026-07-12 UTC. Do not hand-edit except the CN section (no public API for CN).
--
-- Tables are region-scoped (picked by gameAccountInfo.regionID via FriendGroups_GetRealmDatabase):
--   1 = Americas/Oceania, 2 = Korea, 3 = Europe/Russia, 4 = Taiwan, 5 = China.
-- Keys have ASCII spaces/punctuation stripped (must match FriendGroups_CleanRealmName).
-- `classic = true` marks Classic-family realms (progression / Era / SoD / HC / Anniversary).
-- Realm names are unique per game mode within a region (the generator asserts this), which is
-- what lets the game-icon tint tell retail from Classic friends when the API omits
-- wowProjectID (Compat.ResolveFriendFlavor). Untagged = retail.
-- Entries marked "native name of X" are alias keys so non-English clients resolve realms too.
-- [[ REGION 1: AMERICAS & OCEANIA ]] --
FriendGroups_RealmData = {
    -- [[ BRAZIL (FlagBR.tga) ]] --
    ["Azralon"] = {icon = "FlagBR.tga", region = "Brazil"},
    ["Gallywix"] = {icon = "FlagBR.tga", region = "Brazil"},
    ["Goldrinn"] = {icon = "FlagBR.tga", region = "Brazil"},
    ["Nemesis"] = {icon = "FlagBR.tga", region = "Brazil"},
    ["TolBarad"] = {icon = "FlagBR.tga", region = "Brazil"},

    -- [[ BRAZIL (FlagBR.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Sulthraze"] = {icon = "FlagBR.tga", region = "Brazil", classic = true},

    -- [[ LATIN AMERICA (FlagMX.tga) ]] --
    ["Drakkari"] = {icon = "FlagMX.tga", region = "Latin America"},
    ["QuelThalas"] = {icon = "FlagMX.tga", region = "Latin America"},
    ["Ragnaros"] = {icon = "FlagMX.tga", region = "Latin America"},

    -- [[ LATIN AMERICA (FlagMX.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Loatheb"] = {icon = "FlagMX.tga", region = "Latin America", classic = true},

    -- [[ OCEANIA (FlagAU.tga) ]] --
    ["AmanThul"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Barthilas"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Caelestrasz"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["DathRemar"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Dreadmaul"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Frostmourne"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Gundrak"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["JubeiThos"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Khazgoroth"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Nagrand"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Saurfang"] = {icon = "FlagAU.tga", region = "Oceania"},
    ["Thaurissan"] = {icon = "FlagAU.tga", region = "Oceania"},

    -- [[ OCEANIA (FlagAU.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Arugal"] = {icon = "FlagAU.tga", region = "Oceania", classic = true},
    ["Felstriker"] = {icon = "FlagAU.tga", region = "Oceania", classic = true},
    ["Penance"] = {icon = "FlagAU.tga", region = "Oceania", classic = true},
    ["Remulos"] = {icon = "FlagAU.tga", region = "Oceania", classic = true},
    ["Shadowstrike"] = {icon = "FlagAU.tga", region = "Oceania", classic = true},
    ["Yojamba"] = {icon = "FlagAU.tga", region = "Oceania", classic = true},

    -- [[ US (FlagUS.tga) ]] --
    ["Aegwynn"] = {icon = "FlagUS.tga", region = "US"},
    ["AeriePeak"] = {icon = "FlagUS.tga", region = "US"},
    ["Agamaggan"] = {icon = "FlagUS.tga", region = "US"},
    ["Aggramar"] = {icon = "FlagUS.tga", region = "US"},
    ["Akama"] = {icon = "FlagUS.tga", region = "US"},
    ["Alexstrasza"] = {icon = "FlagUS.tga", region = "US"},
    ["Alleria"] = {icon = "FlagUS.tga", region = "US"},
    ["AltarofStorms"] = {icon = "FlagUS.tga", region = "US"},
    ["AlteracMountains"] = {icon = "FlagUS.tga", region = "US"},
    ["Andorhal"] = {icon = "FlagUS.tga", region = "US"},
    ["Anetheron"] = {icon = "FlagUS.tga", region = "US"},
    ["Antonidas"] = {icon = "FlagUS.tga", region = "US"},
    ["Anubarak"] = {icon = "FlagUS.tga", region = "US"},
    ["Anvilmar"] = {icon = "FlagUS.tga", region = "US"},
    ["Arathor"] = {icon = "FlagUS.tga", region = "US"},
    ["Archimonde"] = {icon = "FlagUS.tga", region = "US"},
    ["Area52"] = {icon = "FlagUS.tga", region = "US"},
    ["ArgentDawn"] = {icon = "FlagUS.tga", region = "US"},
    ["Arthas"] = {icon = "FlagUS.tga", region = "US"},
    ["Arygos"] = {icon = "FlagUS.tga", region = "US"},
    ["Auchindoun"] = {icon = "FlagUS.tga", region = "US"},
    ["Azgalor"] = {icon = "FlagUS.tga", region = "US"},
    ["AzjolNerub"] = {icon = "FlagUS.tga", region = "US"},
    ["Azshara"] = {icon = "FlagUS.tga", region = "US"},
    ["Azuremyst"] = {icon = "FlagUS.tga", region = "US"},
    ["Baelgun"] = {icon = "FlagUS.tga", region = "US"},
    ["Balnazzar"] = {icon = "FlagUS.tga", region = "US"},
    ["BlackDragonflight"] = {icon = "FlagUS.tga", region = "US"},
    ["Blackhand"] = {icon = "FlagUS.tga", region = "US"},
    ["Blackrock"] = {icon = "FlagUS.tga", region = "US"},
    ["BlackwaterRaiders"] = {icon = "FlagUS.tga", region = "US"},
    ["BlackwingLair"] = {icon = "FlagUS.tga", region = "US"},
    ["Bladefist"] = {icon = "FlagUS.tga", region = "US"},
    ["BladesEdge"] = {icon = "FlagUS.tga", region = "US"},
    ["BleedingHollow"] = {icon = "FlagUS.tga", region = "US"},
    ["BloodFurnace"] = {icon = "FlagUS.tga", region = "US"},
    ["Bloodhoof"] = {icon = "FlagUS.tga", region = "US"},
    ["Bloodscalp"] = {icon = "FlagUS.tga", region = "US"},
    ["Bonechewer"] = {icon = "FlagUS.tga", region = "US"},
    ["BoreanTundra"] = {icon = "FlagUS.tga", region = "US"},
    ["Boulderfist"] = {icon = "FlagUS.tga", region = "US"},
    ["Bronzebeard"] = {icon = "FlagUS.tga", region = "US"},
    ["BurningBlade"] = {icon = "FlagUS.tga", region = "US"},
    ["BurningLegion"] = {icon = "FlagUS.tga", region = "US"},
    ["Cairne"] = {icon = "FlagUS.tga", region = "US"},
    ["CenarionCircle"] = {icon = "FlagUS.tga", region = "US"},
    ["Cenarius"] = {icon = "FlagUS.tga", region = "US"},
    ["Chogall"] = {icon = "FlagUS.tga", region = "US"},
    ["Chromaggus"] = {icon = "FlagUS.tga", region = "US"},
    ["Coilfang"] = {icon = "FlagUS.tga", region = "US"},
    ["Crushridge"] = {icon = "FlagUS.tga", region = "US"},
    ["Daggerspine"] = {icon = "FlagUS.tga", region = "US"},
    ["Dalaran"] = {icon = "FlagUS.tga", region = "US"},
    ["Dalvengyr"] = {icon = "FlagUS.tga", region = "US"},
    ["DarkIron"] = {icon = "FlagUS.tga", region = "US"},
    ["Darkspear"] = {icon = "FlagUS.tga", region = "US"},
    ["Darrowmere"] = {icon = "FlagUS.tga", region = "US"},
    ["Dawnbringer"] = {icon = "FlagUS.tga", region = "US"},
    ["Deathwing"] = {icon = "FlagUS.tga", region = "US"},
    ["DemonSoul"] = {icon = "FlagUS.tga", region = "US"},
    ["Dentarg"] = {icon = "FlagUS.tga", region = "US"},
    ["Destromath"] = {icon = "FlagUS.tga", region = "US"},
    ["Dethecus"] = {icon = "FlagUS.tga", region = "US"},
    ["Detheroc"] = {icon = "FlagUS.tga", region = "US"},
    ["Doomhammer"] = {icon = "FlagUS.tga", region = "US"},
    ["Draenor"] = {icon = "FlagUS.tga", region = "US"},
    ["Dragonblight"] = {icon = "FlagUS.tga", region = "US"},
    ["Dragonmaw"] = {icon = "FlagUS.tga", region = "US"},
    ["Draka"] = {icon = "FlagUS.tga", region = "US"},
    ["DrakTharon"] = {icon = "FlagUS.tga", region = "US"},
    ["Drakthul"] = {icon = "FlagUS.tga", region = "US"},
    ["Drenden"] = {icon = "FlagUS.tga", region = "US"},
    ["Dunemaul"] = {icon = "FlagUS.tga", region = "US"},
    ["Durotan"] = {icon = "FlagUS.tga", region = "US"},
    ["Duskwood"] = {icon = "FlagUS.tga", region = "US"},
    ["EarthenRing"] = {icon = "FlagUS.tga", region = "US"},
    ["EchoIsles"] = {icon = "FlagUS.tga", region = "US"},
    ["Eitrigg"] = {icon = "FlagUS.tga", region = "US"},
    ["EldreThalas"] = {icon = "FlagUS.tga", region = "US"},
    ["Elune"] = {icon = "FlagUS.tga", region = "US"},
    ["EmeraldDream"] = {icon = "FlagUS.tga", region = "US"},
    ["Eonar"] = {icon = "FlagUS.tga", region = "US"},
    ["Eredar"] = {icon = "FlagUS.tga", region = "US"},
    ["Executus"] = {icon = "FlagUS.tga", region = "US"},
    ["Exodar"] = {icon = "FlagUS.tga", region = "US"},
    ["Farstriders"] = {icon = "FlagUS.tga", region = "US"},
    ["Feathermoon"] = {icon = "FlagUS.tga", region = "US"},
    ["Fenris"] = {icon = "FlagUS.tga", region = "US"},
    ["Firetree"] = {icon = "FlagUS.tga", region = "US"},
    ["Fizzcrank"] = {icon = "FlagUS.tga", region = "US"},
    ["Frostmane"] = {icon = "FlagUS.tga", region = "US"},
    ["Frostwolf"] = {icon = "FlagUS.tga", region = "US"},
    ["Galakrond"] = {icon = "FlagUS.tga", region = "US"},
    ["Garithos"] = {icon = "FlagUS.tga", region = "US"},
    ["Garona"] = {icon = "FlagUS.tga", region = "US"},
    ["Garrosh"] = {icon = "FlagUS.tga", region = "US"},
    ["Ghostlands"] = {icon = "FlagUS.tga", region = "US"},
    ["Gilneas"] = {icon = "FlagUS.tga", region = "US"},
    ["Gnomeregan"] = {icon = "FlagUS.tga", region = "US"},
    ["Gorefiend"] = {icon = "FlagUS.tga", region = "US"},
    ["Gorgonnash"] = {icon = "FlagUS.tga", region = "US"},
    ["Greymane"] = {icon = "FlagUS.tga", region = "US"},
    ["GrizzlyHills"] = {icon = "FlagUS.tga", region = "US"},
    ["Guldan"] = {icon = "FlagUS.tga", region = "US"},
    ["Gurubashi"] = {icon = "FlagUS.tga", region = "US"},
    ["Hakkar"] = {icon = "FlagUS.tga", region = "US"},
    ["Haomarush"] = {icon = "FlagUS.tga", region = "US"},
    ["Hellscream"] = {icon = "FlagUS.tga", region = "US"},
    ["Hydraxis"] = {icon = "FlagUS.tga", region = "US"},
    ["Hyjal"] = {icon = "FlagUS.tga", region = "US"},
    ["Icecrown"] = {icon = "FlagUS.tga", region = "US"},
    ["Illidan"] = {icon = "FlagUS.tga", region = "US"},
    ["Jaedenar"] = {icon = "FlagUS.tga", region = "US"},
    ["Kaelthas"] = {icon = "FlagUS.tga", region = "US"},
    ["Kalecgos"] = {icon = "FlagUS.tga", region = "US"},
    ["Kargath"] = {icon = "FlagUS.tga", region = "US"},
    ["KelThuzad"] = {icon = "FlagUS.tga", region = "US"},
    ["Khadgar"] = {icon = "FlagUS.tga", region = "US"},
    ["KhazModan"] = {icon = "FlagUS.tga", region = "US"},
    ["Kiljaeden"] = {icon = "FlagUS.tga", region = "US"},
    ["Kilrogg"] = {icon = "FlagUS.tga", region = "US"},
    ["KirinTor"] = {icon = "FlagUS.tga", region = "US"},
    ["Korgath"] = {icon = "FlagUS.tga", region = "US"},
    ["Korialstrasz"] = {icon = "FlagUS.tga", region = "US"},
    ["KulTiras"] = {icon = "FlagUS.tga", region = "US"},
    ["LaughingSkull"] = {icon = "FlagUS.tga", region = "US"},
    ["Lethon"] = {icon = "FlagUS.tga", region = "US"},
    ["Lightbringer"] = {icon = "FlagUS.tga", region = "US"},
    ["Lightninghoof"] = {icon = "FlagUS.tga", region = "US"},
    ["LightningsBlade"] = {icon = "FlagUS.tga", region = "US"},
    ["Llane"] = {icon = "FlagUS.tga", region = "US"},
    ["Lothar"] = {icon = "FlagUS.tga", region = "US"},
    ["Madoran"] = {icon = "FlagUS.tga", region = "US"},
    ["Maelstrom"] = {icon = "FlagUS.tga", region = "US"},
    ["Magtheridon"] = {icon = "FlagUS.tga", region = "US"},
    ["Maiev"] = {icon = "FlagUS.tga", region = "US"},
    ["Malfurion"] = {icon = "FlagUS.tga", region = "US"},
    ["MalGanis"] = {icon = "FlagUS.tga", region = "US"},
    ["Malorne"] = {icon = "FlagUS.tga", region = "US"},
    ["Malygos"] = {icon = "FlagUS.tga", region = "US"},
    ["Mannoroth"] = {icon = "FlagUS.tga", region = "US"},
    ["Medivh"] = {icon = "FlagUS.tga", region = "US"},
    ["Misha"] = {icon = "FlagUS.tga", region = "US"},
    ["MokNathal"] = {icon = "FlagUS.tga", region = "US"},
    ["MoonGuard"] = {icon = "FlagUS.tga", region = "US"},
    ["Moonrunner"] = {icon = "FlagUS.tga", region = "US"},
    ["Mugthol"] = {icon = "FlagUS.tga", region = "US"},
    ["Muradin"] = {icon = "FlagUS.tga", region = "US"},
    ["Nathrezim"] = {icon = "FlagUS.tga", region = "US"},
    ["Nazgrel"] = {icon = "FlagUS.tga", region = "US"},
    ["Nazjatar"] = {icon = "FlagUS.tga", region = "US"},
    ["Nerzhul"] = {icon = "FlagUS.tga", region = "US"},
    ["Nesingwary"] = {icon = "FlagUS.tga", region = "US"},
    ["Nordrassil"] = {icon = "FlagUS.tga", region = "US"},
    ["Norgannon"] = {icon = "FlagUS.tga", region = "US"},
    ["Onyxia"] = {icon = "FlagUS.tga", region = "US"},
    ["Perenolde"] = {icon = "FlagUS.tga", region = "US"},
    ["Proudmoore"] = {icon = "FlagUS.tga", region = "US"},
    ["Queldorei"] = {icon = "FlagUS.tga", region = "US"},
    ["Ravencrest"] = {icon = "FlagUS.tga", region = "US"},
    ["Ravenholdt"] = {icon = "FlagUS.tga", region = "US"},
    ["Rexxar"] = {icon = "FlagUS.tga", region = "US"},
    ["Rivendare"] = {icon = "FlagUS.tga", region = "US"},
    ["Runetotem"] = {icon = "FlagUS.tga", region = "US"},
    ["Sargeras"] = {icon = "FlagUS.tga", region = "US"},
    ["ScarletCrusade"] = {icon = "FlagUS.tga", region = "US"},
    ["Scilla"] = {icon = "FlagUS.tga", region = "US"},
    ["Senjin"] = {icon = "FlagUS.tga", region = "US"},
    ["Sentinels"] = {icon = "FlagUS.tga", region = "US"},
    ["ShadowCouncil"] = {icon = "FlagUS.tga", region = "US"},
    ["Shadowmoon"] = {icon = "FlagUS.tga", region = "US"},
    ["Shadowsong"] = {icon = "FlagUS.tga", region = "US"},
    ["Shandris"] = {icon = "FlagUS.tga", region = "US"},
    ["ShatteredHalls"] = {icon = "FlagUS.tga", region = "US"},
    ["ShatteredHand"] = {icon = "FlagUS.tga", region = "US"},
    ["Shuhalo"] = {icon = "FlagUS.tga", region = "US"},
    ["SilverHand"] = {icon = "FlagUS.tga", region = "US"},
    ["Silvermoon"] = {icon = "FlagUS.tga", region = "US"},
    ["SistersofElune"] = {icon = "FlagUS.tga", region = "US"},
    ["Skullcrusher"] = {icon = "FlagUS.tga", region = "US"},
    ["Skywall"] = {icon = "FlagUS.tga", region = "US"},
    ["Smolderthorn"] = {icon = "FlagUS.tga", region = "US"},
    ["Spinebreaker"] = {icon = "FlagUS.tga", region = "US"},
    ["Spirestone"] = {icon = "FlagUS.tga", region = "US"},
    ["Staghelm"] = {icon = "FlagUS.tga", region = "US"},
    ["SteamwheedleCartel"] = {icon = "FlagUS.tga", region = "US"},
    ["Stonemaul"] = {icon = "FlagUS.tga", region = "US"},
    ["Stormrage"] = {icon = "FlagUS.tga", region = "US"},
    ["Stormreaver"] = {icon = "FlagUS.tga", region = "US"},
    ["Stormscale"] = {icon = "FlagUS.tga", region = "US"},
    ["Suramar"] = {icon = "FlagUS.tga", region = "US"},
    ["Tanaris"] = {icon = "FlagUS.tga", region = "US"},
    ["Terenas"] = {icon = "FlagUS.tga", region = "US"},
    ["Terokkar"] = {icon = "FlagUS.tga", region = "US"},
    ["TheForgottenCoast"] = {icon = "FlagUS.tga", region = "US"},
    ["TheScryers"] = {icon = "FlagUS.tga", region = "US"},
    ["TheUnderbog"] = {icon = "FlagUS.tga", region = "US"},
    ["TheVentureCo"] = {icon = "FlagUS.tga", region = "US"},
    ["ThoriumBrotherhood"] = {icon = "FlagUS.tga", region = "US"},
    ["Thrall"] = {icon = "FlagUS.tga", region = "US"},
    ["Thunderhorn"] = {icon = "FlagUS.tga", region = "US"},
    ["Thunderlord"] = {icon = "FlagUS.tga", region = "US"},
    ["Tichondrius"] = {icon = "FlagUS.tga", region = "US"},
    ["Tortheldrin"] = {icon = "FlagUS.tga", region = "US"},
    ["Trollbane"] = {icon = "FlagUS.tga", region = "US"},
    ["Turalyon"] = {icon = "FlagUS.tga", region = "US"},
    ["TwistingNether"] = {icon = "FlagUS.tga", region = "US"},
    ["Uldaman"] = {icon = "FlagUS.tga", region = "US"},
    ["Uldum"] = {icon = "FlagUS.tga", region = "US"},
    ["Undermine"] = {icon = "FlagUS.tga", region = "US"},
    ["Ursin"] = {icon = "FlagUS.tga", region = "US"},
    ["Uther"] = {icon = "FlagUS.tga", region = "US"},
    ["Vashj"] = {icon = "FlagUS.tga", region = "US"},
    ["Veknilash"] = {icon = "FlagUS.tga", region = "US"},
    ["Velen"] = {icon = "FlagUS.tga", region = "US"},
    ["Warsong"] = {icon = "FlagUS.tga", region = "US"},
    ["Whisperwind"] = {icon = "FlagUS.tga", region = "US"},
    ["Wildhammer"] = {icon = "FlagUS.tga", region = "US"},
    ["Windrunner"] = {icon = "FlagUS.tga", region = "US"},
    ["Winterhoof"] = {icon = "FlagUS.tga", region = "US"},
    ["WyrmrestAccord"] = {icon = "FlagUS.tga", region = "US"},
    ["Ysera"] = {icon = "FlagUS.tga", region = "US"},
    ["Ysondre"] = {icon = "FlagUS.tga", region = "US"},
    ["Zangarmarsh"] = {icon = "FlagUS.tga", region = "US"},
    ["Zuljin"] = {icon = "FlagUS.tga", region = "US"},
    ["Zuluhed"] = {icon = "FlagUS.tga", region = "US"},

    -- [[ US (FlagUS.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Anathema"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Angerforge"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["ArcaniteReaper"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Ashkandi"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Atiesh"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Azuresong"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Benediction"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Bigglesworth"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Blaumeux"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["BloodsailBuccaneers"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["ChaosBolt"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["CrusaderStrike"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["DefiasPillager"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["DeviateDelight"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Doomhowl"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Dreamscythe"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Earthfury"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Eranikus"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Faerlina"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Fairbanks"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Galakras"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Grobbulus"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Heartseeker"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Herod"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Immerseus"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Incendius"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Kirtonos"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Kromcrush"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Kurinnaxx"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["LavaLash"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["LeiShen"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["LivingFlame"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["LoneWolf"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Maladath"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Mankrik"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Myzrael"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Nazgrim"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Netherwind"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Nightslayer"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["OldBlanchy"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Pagle"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Raden"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Rattlegore"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Skeram"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["SkullRock"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Skyfury"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Smolderweb"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Stalagg"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Sulfuras"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Thalnos"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Thunderfury"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Westfall"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Whitemane"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["WildGrowth"] = {icon = "FlagUS.tga", region = "US", classic = true},
    ["Windseeker"] = {icon = "FlagUS.tga", region = "US", classic = true},
}

-- [[ REGION 3: EUROPE & RUSSIA ]] --
FriendGroups_RealmDataEU = {
    -- [[ EU (FlagGB.tga) ]] --
    ["AeriePeak"] = {icon = "FlagGB.tga", region = "EU"},
    ["Agamaggan"] = {icon = "FlagGB.tga", region = "EU"},
    ["Aggramar"] = {icon = "FlagGB.tga", region = "EU"},
    ["AhnQiraj"] = {icon = "FlagGB.tga", region = "EU"},
    ["AlAkir"] = {icon = "FlagGB.tga", region = "EU"},
    ["Alonsus"] = {icon = "FlagGB.tga", region = "EU"},
    ["Anachronos"] = {icon = "FlagGB.tga", region = "EU"},
    ["Arathor"] = {icon = "FlagGB.tga", region = "EU"},
    ["ArgentDawn"] = {icon = "FlagGB.tga", region = "EU"},
    ["Aszune"] = {icon = "FlagGB.tga", region = "EU"},
    ["Auchindoun"] = {icon = "FlagGB.tga", region = "EU"},
    ["AzjolNerub"] = {icon = "FlagGB.tga", region = "EU"},
    ["Azuremyst"] = {icon = "FlagGB.tga", region = "EU"},
    ["Balnazzar"] = {icon = "FlagGB.tga", region = "EU"},
    ["Bladefist"] = {icon = "FlagGB.tga", region = "EU"},
    ["BladesEdge"] = {icon = "FlagGB.tga", region = "EU"},
    ["Bloodfeather"] = {icon = "FlagGB.tga", region = "EU"},
    ["Bloodhoof"] = {icon = "FlagGB.tga", region = "EU"},
    ["Bloodscalp"] = {icon = "FlagGB.tga", region = "EU"},
    ["Boulderfist"] = {icon = "FlagGB.tga", region = "EU"},
    ["Bronzebeard"] = {icon = "FlagGB.tga", region = "EU"},
    ["BronzeDragonflight"] = {icon = "FlagGB.tga", region = "EU"},
    ["BurningBlade"] = {icon = "FlagGB.tga", region = "EU"},
    ["BurningLegion"] = {icon = "FlagGB.tga", region = "EU"},
    ["BurningSteppes"] = {icon = "FlagGB.tga", region = "EU"},
    ["ChamberofAspects"] = {icon = "FlagGB.tga", region = "EU"},
    ["Chromaggus"] = {icon = "FlagGB.tga", region = "EU"},
    ["Crushridge"] = {icon = "FlagGB.tga", region = "EU"},
    ["Daggerspine"] = {icon = "FlagGB.tga", region = "EU"},
    ["DarkmoonFaire"] = {icon = "FlagGB.tga", region = "EU"},
    ["Darksorrow"] = {icon = "FlagGB.tga", region = "EU"},
    ["Darkspear"] = {icon = "FlagGB.tga", region = "EU"},
    ["Deathwing"] = {icon = "FlagGB.tga", region = "EU"},
    ["DefiasBrotherhood"] = {icon = "FlagGB.tga", region = "EU"},
    ["Dentarg"] = {icon = "FlagGB.tga", region = "EU"},
    ["Doomhammer"] = {icon = "FlagGB.tga", region = "EU"},
    ["Draenor"] = {icon = "FlagGB.tga", region = "EU"},
    ["Dragonblight"] = {icon = "FlagGB.tga", region = "EU"},
    ["Dragonmaw"] = {icon = "FlagGB.tga", region = "EU"},
    ["Drakthul"] = {icon = "FlagGB.tga", region = "EU"},
    ["Dunemaul"] = {icon = "FlagGB.tga", region = "EU"},
    ["EarthenRing"] = {icon = "FlagGB.tga", region = "EU"},
    ["EmeraldDream"] = {icon = "FlagGB.tga", region = "EU"},
    ["Emeriss"] = {icon = "FlagGB.tga", region = "EU"},
    ["Eonar"] = {icon = "FlagGB.tga", region = "EU"},
    ["Executus"] = {icon = "FlagGB.tga", region = "EU"},
    ["Frostmane"] = {icon = "FlagGB.tga", region = "EU"},
    ["Frostwhisper"] = {icon = "FlagGB.tga", region = "EU"},
    ["Genjuros"] = {icon = "FlagGB.tga", region = "EU"},
    ["Ghostlands"] = {icon = "FlagGB.tga", region = "EU"},
    ["GrimBatol"] = {icon = "FlagGB.tga", region = "EU"},
    ["Hakkar"] = {icon = "FlagGB.tga", region = "EU"},
    ["Haomarush"] = {icon = "FlagGB.tga", region = "EU"},
    ["Hellfire"] = {icon = "FlagGB.tga", region = "EU"},
    ["Hellscream"] = {icon = "FlagGB.tga", region = "EU"},
    ["Jaedenar"] = {icon = "FlagGB.tga", region = "EU"},
    ["Karazhan"] = {icon = "FlagGB.tga", region = "EU"},
    ["Kazzak"] = {icon = "FlagGB.tga", region = "EU"},
    ["Khadgar"] = {icon = "FlagGB.tga", region = "EU"},
    ["Kilrogg"] = {icon = "FlagGB.tga", region = "EU"},
    ["Korgall"] = {icon = "FlagGB.tga", region = "EU"},
    ["KulTiras"] = {icon = "FlagGB.tga", region = "EU"},
    ["LaughingSkull"] = {icon = "FlagGB.tga", region = "EU"},
    ["Lightbringer"] = {icon = "FlagGB.tga", region = "EU"},
    ["LightningsBlade"] = {icon = "FlagGB.tga", region = "EU"},
    ["Magtheridon"] = {icon = "FlagGB.tga", region = "EU"},
    ["Mazrigos"] = {icon = "FlagGB.tga", region = "EU"},
    ["Moonglade"] = {icon = "FlagGB.tga", region = "EU"},
    ["Nagrand"] = {icon = "FlagGB.tga", region = "EU"},
    ["Neptulon"] = {icon = "FlagGB.tga", region = "EU"},
    ["Nordrassil"] = {icon = "FlagGB.tga", region = "EU"},
    ["Outland"] = {icon = "FlagGB.tga", region = "EU"},
    ["QuelThalas"] = {icon = "FlagGB.tga", region = "EU"},
    ["Ragnaros"] = {icon = "FlagGB.tga", region = "EU"},
    ["Ravencrest"] = {icon = "FlagGB.tga", region = "EU"},
    ["Ravenholdt"] = {icon = "FlagGB.tga", region = "EU"},
    ["Runetotem"] = {icon = "FlagGB.tga", region = "EU"},
    ["Saurfang"] = {icon = "FlagGB.tga", region = "EU"},
    ["ScarshieldLegion"] = {icon = "FlagGB.tga", region = "EU"},
    ["Shadowsong"] = {icon = "FlagGB.tga", region = "EU"},
    ["ShatteredHalls"] = {icon = "FlagGB.tga", region = "EU"},
    ["ShatteredHand"] = {icon = "FlagGB.tga", region = "EU"},
    ["Silvermoon"] = {icon = "FlagGB.tga", region = "EU"},
    ["Skullcrusher"] = {icon = "FlagGB.tga", region = "EU"},
    ["Spinebreaker"] = {icon = "FlagGB.tga", region = "EU"},
    ["Sporeggar"] = {icon = "FlagGB.tga", region = "EU"},
    ["SteamwheedleCartel"] = {icon = "FlagGB.tga", region = "EU"},
    ["Stormrage"] = {icon = "FlagGB.tga", region = "EU"},
    ["Stormreaver"] = {icon = "FlagGB.tga", region = "EU"},
    ["Stormscale"] = {icon = "FlagGB.tga", region = "EU"},
    ["Sunstrider"] = {icon = "FlagGB.tga", region = "EU"},
    ["Sylvanas"] = {icon = "FlagGB.tga", region = "EU"},
    ["Talnivarr"] = {icon = "FlagGB.tga", region = "EU"},
    ["TarrenMill"] = {icon = "FlagGB.tga", region = "EU"},
    ["Terenas"] = {icon = "FlagGB.tga", region = "EU"},
    ["Terokkar"] = {icon = "FlagGB.tga", region = "EU"},
    ["TheMaelstrom"] = {icon = "FlagGB.tga", region = "EU"},
    ["TheShatar"] = {icon = "FlagGB.tga", region = "EU"},
    ["TheVentureCo"] = {icon = "FlagGB.tga", region = "EU"},
    ["Thunderhorn"] = {icon = "FlagGB.tga", region = "EU"},
    ["Trollbane"] = {icon = "FlagGB.tga", region = "EU"},
    ["Turalyon"] = {icon = "FlagGB.tga", region = "EU"},
    ["TwilightsHammer"] = {icon = "FlagGB.tga", region = "EU"},
    ["TwistingNether"] = {icon = "FlagGB.tga", region = "EU"},
    ["Vashj"] = {icon = "FlagGB.tga", region = "EU"},
    ["Veknilash"] = {icon = "FlagGB.tga", region = "EU"},
    ["Wildhammer"] = {icon = "FlagGB.tga", region = "EU"},
    ["Xavius"] = {icon = "FlagGB.tga", region = "EU"},
    ["Zenedar"] = {icon = "FlagGB.tga", region = "EU"},

    -- [[ EU (FlagGB.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Ashbringer"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Bloodfang"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["ChaosBolt"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["CrusaderStrike"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Dragonfang"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Dreadmist"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Earthshaker"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Firemaw"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Flamelash"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Gandling"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Garalon"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Gehennas"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Giantstalker"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Golemagg"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Hoptallus"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["HydraxianWaterlords"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Jindo"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Judgement"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["LavaLash"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["LivingFlame"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["LoneWolf"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["MirageRaceway"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Mograine"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["NekRosh"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["NethergardeKeep"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Noggenfogger"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Norushen"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["PyrewoodVillage"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Razorgore"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Shazzrah"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Shekzeer"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Skullflame"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Soulseeker"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Spineshatter"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Stitches"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Stonespine"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["TenStorms"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Thekal"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["Thunderstrike"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["WildGrowth"] = {icon = "FlagGB.tga", region = "EU", classic = true},
    ["ZandalarTribe"] = {icon = "FlagGB.tga", region = "EU", classic = true},

    -- [[ FRANCE (FlagFR.tga) ]] --
    ["Arakarahm"] = {icon = "FlagFR.tga", region = "France"},
    ["Arathi"] = {icon = "FlagFR.tga", region = "France"},
    ["Archimonde"] = {icon = "FlagFR.tga", region = "France"},
    ["Chantséternels"] = {icon = "FlagFR.tga", region = "France"},
    ["Chogall"] = {icon = "FlagFR.tga", region = "France"},
    ["ConfrérieduThorium"] = {icon = "FlagFR.tga", region = "France"},
    ["ConseildesOmbres"] = {icon = "FlagFR.tga", region = "France"},
    ["CultedelaRivenoire"] = {icon = "FlagFR.tga", region = "France"},
    ["Dalaran"] = {icon = "FlagFR.tga", region = "France"},
    ["DrekThar"] = {icon = "FlagFR.tga", region = "France"},
    ["Eitrigg"] = {icon = "FlagFR.tga", region = "France"},
    ["EldreThalas"] = {icon = "FlagFR.tga", region = "France"},
    ["Elune"] = {icon = "FlagFR.tga", region = "France"},
    ["Garona"] = {icon = "FlagFR.tga", region = "France"},
    ["Hyjal"] = {icon = "FlagFR.tga", region = "France"},
    ["Illidan"] = {icon = "FlagFR.tga", region = "France"},
    ["Kaelthas"] = {icon = "FlagFR.tga", region = "France"},
    ["KhazModan"] = {icon = "FlagFR.tga", region = "France"},
    ["KirinTor"] = {icon = "FlagFR.tga", region = "France"},
    ["Krasus"] = {icon = "FlagFR.tga", region = "France"},
    ["LaCroisadeécarlate"] = {icon = "FlagFR.tga", region = "France"},
    ["LesClairvoyants"] = {icon = "FlagFR.tga", region = "France"},
    ["LesSentinelles"] = {icon = "FlagFR.tga", region = "France"},
    ["MarécagedeZangar"] = {icon = "FlagFR.tga", region = "France"},
    ["Medivh"] = {icon = "FlagFR.tga", region = "France"},
    ["Naxxramas"] = {icon = "FlagFR.tga", region = "France"},
    ["Nerzhul"] = {icon = "FlagFR.tga", region = "France"},
    ["Rashgarroth"] = {icon = "FlagFR.tga", region = "France"},
    ["Sargeras"] = {icon = "FlagFR.tga", region = "France"},
    ["Sinstralis"] = {icon = "FlagFR.tga", region = "France"},
    ["Suramar"] = {icon = "FlagFR.tga", region = "France"},
    ["Templenoir"] = {icon = "FlagFR.tga", region = "France"},
    ["ThrokFeroth"] = {icon = "FlagFR.tga", region = "France"},
    ["Uldaman"] = {icon = "FlagFR.tga", region = "France"},
    ["Varimathras"] = {icon = "FlagFR.tga", region = "France"},
    ["Voljin"] = {icon = "FlagFR.tga", region = "France"},
    ["Ysondre"] = {icon = "FlagFR.tga", region = "France"},

    -- [[ FRANCE (FlagFR.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Amnennar"] = {icon = "FlagFR.tga", region = "France", classic = true},
    ["Auberdine"] = {icon = "FlagFR.tga", region = "France", classic = true},
    ["Finkle"] = {icon = "FlagFR.tga", region = "France", classic = true},
    ["Sulfuron"] = {icon = "FlagFR.tga", region = "France", classic = true},

    -- [[ GERMANY (FlagDE.tga) ]] --
    ["Aegwynn"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Alexstrasza"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Alleria"] = {icon = "FlagDE.tga", region = "Germany"},
    ["AmanThul"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Ambossar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Anetheron"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Antonidas"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Anubarak"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Area52"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Arthas"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Arygos"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Azshara"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Baelgun"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Blackhand"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Blackmoore"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Blackrock"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Blutkessel"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Dalvengyr"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DasKonsortium"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DasSyndikat"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DerabyssischeRat"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DerMithrilorden"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DerRatvonDalaran"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Destromath"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Dethecus"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DieAldor"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DieArguswacht"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DieewigeWacht"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DieNachtwache"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DieSilberneHand"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DieTodeskrallen"] = {icon = "FlagDE.tga", region = "Germany"},
    ["DunMorogh"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Durotan"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Echsenkessel"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Eredar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["FestungderStürme"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Forscherliga"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Frostmourne"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Frostwolf"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Garrosh"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Gilneas"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Gorgonnash"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Guldan"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Kargath"] = {icon = "FlagDE.tga", region = "Germany"},
    ["KelThuzad"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Khazgoroth"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Kiljaeden"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Kragjin"] = {icon = "FlagDE.tga", region = "Germany"},
    ["KultderVerdammten"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Lordaeron"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Lothar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Madmortem"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Malfurion"] = {icon = "FlagDE.tga", region = "Germany"},
    ["MalGanis"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Malorne"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Malygos"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Mannoroth"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Mugthol"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Nathrezim"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Nazjatar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Nefarian"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Nerathor"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Nethersturm"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Norgannon"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Nozdormu"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Onyxia"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Perenolde"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Proudmoore"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Rajaxx"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Rexxar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Senjin"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Shattrath"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Taerar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Teldrassil"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Terrordar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Theradras"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Thrall"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Tichondrius"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Tirion"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Todeswache"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Ulduar"] = {icon = "FlagDE.tga", region = "Germany"},
    ["UnGoro"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Veklor"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Wrathbringer"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Ysera"] = {icon = "FlagDE.tga", region = "Germany"},
    ["ZirkeldesCenarius"] = {icon = "FlagDE.tga", region = "Germany"},
    ["Zuluhed"] = {icon = "FlagDE.tga", region = "Germany"},

    -- [[ GERMANY (FlagDE.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Celebras"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["DragonsCall"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Everlook"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Heartstriker"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Lakeshire"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Lucifron"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["OokOok"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Patchwerk"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Razorfen"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Transcendence"] = {icon = "FlagDE.tga", region = "Germany", classic = true},
    ["Venoxis"] = {icon = "FlagDE.tga", region = "Germany", classic = true},

    -- [[ ITALY (FlagIT.tga) ]] --
    ["Nemesis"] = {icon = "FlagIT.tga", region = "Italy"},
    ["PozzodellEternità"] = {icon = "FlagIT.tga", region = "Italy"},

    -- [[ PORTUGAL (FlagPT.tga) ]] --
    ["Aggra"] = {icon = "FlagPT.tga", region = "Portugal"},

    -- [[ RUSSIA (FlagRU.tga) ]] --
    ["Ashenvale"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Azuregos"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Blackscar"] = {icon = "FlagRU.tga", region = "Russia"},
    ["BootyBay"] = {icon = "FlagRU.tga", region = "Russia"},
    ["BoreanTundra"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Deathguard"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Deathweaver"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Deepholm"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Eversong"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Fordragon"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Galakrond"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Goldrinn"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Gordunni"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Greymane"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Grom"] = {icon = "FlagRU.tga", region = "Russia"},
    ["HowlingFjord"] = {icon = "FlagRU.tga", region = "Russia"},
    ["LichKing"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Razuvious"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Soulflayer"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Thermaplugg"] = {icon = "FlagRU.tga", region = "Russia"},
    ["Азурегос"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Azuregos
    ["Борейскаятундра"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Borean Tundra
    ["ВечнаяПесня"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Eversong
    ["Галакронд"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Galakrond
    ["Голдринн"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Goldrinn
    ["Гордунни"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Gordunni
    ["Гром"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Grom
    ["Дракономор"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Fordragon
    ["Корольлич"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Lich King
    ["ПиратскаяБухта"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Booty Bay
    ["Подземье"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Deepholm
    ["Разувий"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Razuvious
    ["Ревущийфьорд"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Howling Fjord
    ["СвежевательДуш"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Soulflayer
    ["Седогрив"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Greymane
    ["СтражСмерти"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Deathguard
    ["Термоштепсель"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Thermaplugg
    ["ТкачСмерти"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Deathweaver
    ["ЧерныйШрам"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Blackscar
    ["Ясеневыйлес"] = {icon = "FlagRU.tga", region = "Russia"}, -- native name of Ashenvale

    -- [[ RUSSIA (FlagRU.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Anniversary"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["Chromie"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["Flamegor"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["HarbingerofDoom"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["Penance"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["Rhokdelar"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["Shadowstrike"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["Wyrmthalak"] = {icon = "FlagRU.tga", region = "Russia", classic = true},
    ["ВестникРока"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Harbinger of Doom
    ["Годовщина"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Anniversary
    ["Змейталак"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Wyrmthalak
    ["Исповедь"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Penance
    ["Пламегор"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Flamegor
    ["РокДелар"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Rhok'delar
    ["УдарТьмы"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Shadowstrike
    ["Хроми"] = {icon = "FlagRU.tga", region = "Russia", classic = true}, -- native name of Chromie

    -- [[ SPAIN (FlagES.tga) ]] --
    ["ColinasPardas"] = {icon = "FlagES.tga", region = "Spain"},
    ["CThun"] = {icon = "FlagES.tga", region = "Spain"},
    ["DunModr"] = {icon = "FlagES.tga", region = "Spain"},
    ["Exodar"] = {icon = "FlagES.tga", region = "Spain"},
    ["LosErrantes"] = {icon = "FlagES.tga", region = "Spain"},
    ["Minahonda"] = {icon = "FlagES.tga", region = "Spain"},
    ["Sanguino"] = {icon = "FlagES.tga", region = "Spain"},
    ["Shendralar"] = {icon = "FlagES.tga", region = "Spain"},
    ["Tyrande"] = {icon = "FlagES.tga", region = "Spain"},
    ["Uldum"] = {icon = "FlagES.tga", region = "Spain"},
    ["Zuljin"] = {icon = "FlagES.tga", region = "Spain"},

    -- [[ SPAIN (FlagES.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["Mandokir"] = {icon = "FlagES.tga", region = "Spain", classic = true},
}

-- [[ REGION 2: KOREA ]] --
FriendGroups_RealmDataKR = {
    -- [[ KOREA (FlagKR.tga) ]] --
    ["Alexstrasza"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Azshara"] = {icon = "FlagKR.tga", region = "Korea"},
    ["BurningLegion"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Cenarius"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Dalaran"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Deathwing"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Durotan"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Garona"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Guldan"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Hellscream"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Hyjal"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Malfurion"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Norgannon"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Rexxar"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Stormrage"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Wildhammer"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Windrunner"] = {icon = "FlagKR.tga", region = "Korea"},
    ["Zuljin"] = {icon = "FlagKR.tga", region = "Korea"},
    ["가로나"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Garona
    ["굴단"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Gul'dan
    ["노르간논"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Norgannon
    ["달라란"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Dalaran
    ["데스윙"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Deathwing
    ["듀로탄"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Durotan
    ["렉사르"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Rexxar
    ["말퓨리온"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Malfurion
    ["불타는군단"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Burning Legion
    ["세나리우스"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Cenarius
    ["스톰레이지"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Stormrage
    ["아즈샤라"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Azshara
    ["알렉스트라자"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Alexstrasza
    ["와일드해머"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Wildhammer
    ["윈드러너"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Windrunner
    ["줄진"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Zul'jin
    ["하이잘"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Hyjal
    ["헬스크림"] = {icon = "FlagKR.tga", region = "Korea"}, -- native name of Hellscream

    -- [[ KOREA (FlagKR.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["FengusFerocity"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["Frostmourne"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["Hillsbrad"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["Iceblood"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["Lokholar"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["LoneWolf"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["Makgora"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["MoldarsMoxie"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["Ragnaros"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["ShimmeringFlats"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["SlipkiksSavvy"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["WildGrowth"] = {icon = "FlagKR.tga", region = "Korea", classic = true},
    ["고독한늑대"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Lone Wolf
    ["급속성장"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Wild Growth
    ["라그나로스"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Ragnaros
    ["로크홀라"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Lokholar
    ["막고라"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Mak'gora
    ["몰다르의투지"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Mol'dar's Moxie
    ["서리한"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Frostmourne
    ["소금평원"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Shimmering Flats
    ["슬립킥의손재주"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Slip'kik's Savvy
    ["얼음피"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Iceblood
    ["펜구스의흉포"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Fengus' Ferocity
    ["힐스브래드"] = {icon = "FlagKR.tga", region = "Korea", classic = true}, -- native name of Hillsbrad
}

-- [[ REGION 4: TAIWAN ]] --
FriendGroups_RealmDataTW = {
    -- [[ TAIWAN (FlagTW.tga) ]] --
    ["Arthas"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Arygos"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["BleedingHollow"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["ChillwindPoint"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["CrystalpineStinger"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["DemonFallCanyon"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Dragonmaw"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Frostmane"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Hellscream"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Icecrown"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["KrolBlade"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["LightsHope"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Menethil"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Nightsong"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["OldBlanchy"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["OrderoftheCloudSerpent"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Queldorei"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Shadowmoon"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["SilverwingHold"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Skywall"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Spirestone"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Stormscale"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["SundownMarsh"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Whisperwind"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["WorldTree"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["Wrathbringer"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["ZealotBlade"] = {icon = "FlagTW.tga", region = "Taiwan"},
    ["世界之樹"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of World Tree
    ["亞雷戈斯"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Arygos
    ["克羅之刃"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Krol Blade
    ["冰霜之刺"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Frostmane
    ["冰風崗哨"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Chillwind Point
    ["地獄吼"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Hellscream
    ["夜空之歌"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Nightsong
    ["天空之牆"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Skywall
    ["寒冰皇冠"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Icecrown
    ["尖石"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Spirestone
    ["屠魔山谷"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Demon Fall Canyon
    ["巨龍之喉"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Dragonmaw
    ["憤怒使者"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Wrathbringer
    ["日落沼澤"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Sundown Marsh
    ["暗影之月"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Shadowmoon
    ["水晶之刺"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Crystalpine Stinger
    ["狂熱之刃"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Zealot Blade
    ["眾星之子"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Quel'dorei
    ["米奈希爾"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Menethil
    ["老馬布蘭契"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Old Blanchy
    ["聖光之願"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Light's Hope
    ["血之谷"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Bleeding Hollow
    ["語風"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Whisperwind
    ["銀翼要塞"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Silverwing Hold
    ["阿薩斯"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Arthas
    ["雲蛟衛"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Order of the Cloud Serpent
    ["雷鱗"] = {icon = "FlagTW.tga", region = "Taiwan"}, -- native name of Stormscale

    -- [[ TAIWAN (FlagTW.tga) - CLASSIC (progression / era / seasonal) ]] --
    ["ArathiBasin"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["CrusaderStrike"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["FengusFerocity"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Golemagg"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Ivus"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["LivingFlame"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["LoneWolf"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Maraudon"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["MoldarsMoxie"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Murloc"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["SlipkiksSavvy"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Teremus"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Voidwalker"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["WildGrowth"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Windseeker"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Wushoolay"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["Zeliek"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true},
    ["伊弗斯"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Ivus
    ["十字軍聖擊"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Crusader Strike
    ["古雷曼格"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Golemagg
    ["孤狼"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Lone Wolf
    ["摩爾達的勇氣"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Mol'dar's Moxie
    ["斯里基克的機智"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Slip'kik's Savvy
    ["札里克"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Zeliek
    ["烏蘇雷"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Wushoolay
    ["特雷姆斯"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Teremus
    ["瑪拉頓"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Maraudon
    ["生命烈焰"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Living Flame
    ["芬古斯的狂暴"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Fengus' Ferocity
    ["虛無行者"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Voidwalker
    ["逐風者"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Windseeker
    ["野性痊癒"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Wild Growth
    ["阿拉希盆地"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Arathi Basin
    ["魚人"] = {icon = "FlagTW.tga", region = "Taiwan", classic = true}, -- native name of Murloc
}

-- [[ REGION 5: CHINA - hand-maintained, no public API ]] --
FriendGroups_RealmDataCN = {
    ["AbyssalMaw"] = {icon = "FlagCN.tga", region = "China"},
    ["AeriePeak"] = {icon = "FlagCN.tga", region = "China"},
    ["Akilzon"] = {icon = "FlagCN.tga", region = "China"},
    ["Algalon"] = {icon = "FlagCN.tga", region = "China"},
    ["Chronos"] = {icon = "FlagCN.tga", region = "China"},
    ["Goldshire"] = {icon = "FlagCN.tga", region = "China"},
    ["LichKing"] = {icon = "FlagCN.tga", region = "China"},
    ["Onyxia"] = {icon = "FlagCN.tga", region = "China"},
    ["SilverHand"] = {icon = "FlagCN.tga", region = "China"},
    ["Silvermoon"] = {icon = "FlagCN.tga", region = "China"},
    ["TitanReforged"] = {icon = "FlagCN.tga", region = "China"},
}

-- Single source of truth for regionID -> realm table (used by lookup + search paths).
function FriendGroups_GetRealmDatabase(regionID)
    if regionID == 3 then return FriendGroups_RealmDataEU end
    if regionID == 2 then return FriendGroups_RealmDataKR end
    if regionID == 4 then return FriendGroups_RealmDataTW end
    if regionID == 5 then return FriendGroups_RealmDataCN end
    return FriendGroups_RealmData -- default: region 1 (Americas/Oceania)
end