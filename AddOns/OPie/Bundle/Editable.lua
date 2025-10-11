local COMPAT, _, T = select(4,GetBuildInfo()), ...
local L, R = T.L, OPie.CustomRings
if not (R and R.AddDefaultRing) then return end
local MODERN, CF_WRATH, CF_CATA = COMPAT > 10e4 or nil, COMPAT < 10e4 and COMPAT > 3e4 or nil, COMPAT < 10e4 and COMPAT > 4e4 or nil

R:AddDefaultRing("RaidSymbols", {
	{"raidmark", 1, _u="y"}, -- yellow star
	{"raidmark", 2, _u="o"}, -- orange circle
	{"raidmark", 3, _u="p"}, -- purple diamond
	{"raidmark", 4, _u="g"}, -- green triangle
	{"raidmark", 5, _u="s"}, -- silver moon
	{"raidmark", 6, _u="b"}, -- blue square
	{"raidmark", 7, _u="r"}, -- red cross
	{"raidmark", 8, _u="w"}, -- white skull
	{"raidmark", 0, _u="c"}, -- clear all
	name=L"Target Markers", hotkey="ALT-R", _u="OPCRS", v=1
})
do
	local nodeOverload = MODERN and "/cast [in:df,nomod,near:%1$s-overload][in:df,mod,nonear:%1$s-overload] {{spell:%2$d}}; [in:tww,nomod,near:tww-%1$s-overload][in:tww,mod,nonear:tww-%1$s-overload] {{spell:%3$d}}; {{spell:%4$d}}"
	local firstAid = {id="/cast {{spell:3273}}", _u="f"}
	R:AddDefaultRing("CommonTrades", {
		{id="/cast {{spell:3908/51309}}", _u="t"}, -- tailoring
		{id="/cast {{spell:2108/51302}}", _u="l"}, -- leatherworking
		{id="/cast {{spell:2018/51300}}", _u="b"}, -- blacksmithing
		{id="/cast [mod] {{spell:13262}}; {{spell:7411/51313}}", _u="e"}, -- enchanting/disenchanting
		{id="/cast {{spell:2259/51304}}", _u="a"}, -- alchemy
		{id="/cast [mod] {{spell:818}}; {{spell:2550/51296}}; {{spell:818}}", _u="c"}, -- cooking/campfire
		{id="/cast {{spell:4036/51306}}", _u="g"}, -- engineering
		{id=MODERN and nodeOverload:format("mine", 388213, 423394, 2656) or 2656, _u="m"}, -- smelting/mining journal
		(MODERN or CF_WRATH) and {id="/cast [mod] {{spell:31252}}; {{spell:25229/51311}}", _u="j"} -- jewelcrafting/prospecting
		        or firstAid,
		(MODERN or CF_WRATH) and {id="/cast [mod] {{spell:51005}}; {{spell:45357/45363}}", _u="i"}, -- inscription/milling
		(MODERN or CF_WRATH) and {id=53428, _u="u"}, -- runeforging
		(MODERN or CF_CATA) and {id="/cast [mod] {{spell:80451}}; {{spell:78670/89722}}", _u="r"} -- archaeology
		        or CF_WRATH and firstAid,
		MODERN and {id="/cast [mod] {{spell:131474}}; {{spell:271990}}; {{spell:131474}}", _u="fj"} -- fish journal
		        or CF_CATA and firstAid,
		MODERN and {id=194174, _u ="sj"}, -- skinning journal
		MODERN and {id=nodeOverload:format("herb", 390392, 423395, 193290), _u="hj"}, -- herbalism journal
		MODERN and {id=439871, show="[in:tww]", _u="ht"}, -- green thumb
		MODERN and {id=440977, show="[in:tww]", _u="sk"}, -- sharpen your knife
		MODERN and {id=442615, show="[in:tww]", _u="sm"}, -- carve meat
		name=L"Trade Skills", hotkey="ALT-T", _u="OPCCT", v=5
	})
end
R:AddDefaultRing("OPieAutoQuest", {
	{"extrabutton", 1, _u="EB", fastClick=true},
	{"opie.ext", "xact", _u="CX"},
	{"zoneability", 0, _u="ZA"},
	{"opie.autoquest", 1, _u="AC"},
	name=L"Quest Items", hotkey="ALT-Q", _u="OPbQI", v=3
})
if MODERN or CF_CATA then
	local clearMark = {"worldmark", 0, c="ccd8e5", _u="c"}
	local FULL_WORLD_MARKERS = MODERN or NUM_WORLD_RAID_MARKERS_CATA ~= 5
	R:AddDefaultRing("WorldMarkers", {
		{"worldmark", 1, _u="b"},
		{"worldmark", 2, _u="g"},
		{"worldmark", 3, _u="p"},
		{"worldmark", 4, _u="r"},
		{"worldmark", 5, _u="y"},
		FULL_WORLD_MARKERS and {"worldmark", 6, _u="o"} or clearMark,
		FULL_WORLD_MARKERS and {"worldmark", 7, _u="s"},
		FULL_WORLD_MARKERS and {"worldmark", 8, _u="w"},
		FULL_WORLD_MARKERS and clearMark,
		name=L"World Markers", hotkey="[group] ALT-Y", _u="OPCWM", v=2
	})
end

if not MODERN then return end

R:AddDefaultRing("DruidShift", {
	{id="/cancelform [noflying,noform:moonkin]\n/changeactionbar [anyflyable,advflyable,nocombat,outdoors,nobonusbar:5][encount:ff-mount,nomod] 1\n#imp critical\n/cast [encount:ff-mount,nomod] {{mount:air}}; [combat][nooutdoors][anyflyable,noswimming,nomod,noform:stag] {{spell:783}}; [outpost:corral,nomod,nospec:103/104] {{spell:161691}}; [in:undermine,nomod,noswimming,nocombat] {{spell:460013}}; [swimming,nomod][nomod,noform:stag] {{spell:783}}; [anyflyable,nomod:alt] {{mount:air}}; [noanyflyable,nomod:alt] {{mount:ground}}; {{spell:783}}", fastClick=true, _u="f"}, -- Travel
	{id=24858, c="c74cff", _u="k"}, -- Moonkin
	{id=768, c="fff04d", _u="c"}, -- Cat
	{id=5487, c="ff0000", _u="b"}, -- Bear
	{id="/cancelform [noform:moonkin,noflying]\n#imp critical\n/cast [nomod,noform:travel] {{spell:210053}}; {{mount:ground}}; {{spell:210053}}", show="[advflyable,anyflyable]", fastClick=true, _u="m"}, -- Mount
	name=L"Shapeshifts", hotkey="BUTTON4", limit="DRUID", _u="OPCDS", v=7
})
R:AddDefaultRing("DruidUtility", {
	{id="/cast [combat][mod,nomod:alt] {{spell:20484}}; [@target,dead,help,noraid,nomod] {{spell:50769}}; [group] {{spell:212040}}; {{spell:50769}}", _u="r"}, -- rebirth/revit/revive
	{id="/cast [mod] {{spell:16914}}; {{spell:740/16914}}", _u="t"}, -- hurricane/tranq
	{id="/cast [nomod] {{spell:22812}}; {{spell:61336/22812}}", _u="b"}, -- bark/survival
	{id="/cast {{spell:33891/102560}}", _u="i"}, -- Incarnation
	{id="/cast [mod][@target,cleanse,nomod][@player,cleanse][+cleanse] {{spell:88423/2782}}; {{spell:18960/193753}}", _u="p"}, -- moonglade/cleanse
	{id=29166, _u="v"}, -- innervate
	{id=2908, _u="s"}, -- soothe
	{id="/cast [@target,help][@player,nomod][] {{spell:1126}}", _u="w"}, -- motw
	name=L"Utility", hotkey="[noform:bear/cat] BUTTON5; ALT-BUTTON5", limit="DRUID", _u="OPCDU", v=2
})
R:AddDefaultRing("DruidFeral", {
	{id=106951, _u="k"}, -- berserk
	{id="/cast [noform:bear] {{spell:5217}}; {{spell:22842}}; {{spell:5217}}", _u="e"}, -- frenzied / tiger's fury
	{id="/cast [mod] {{spell:1850}}; [form:bear] {{spell:77761}}; {{spell:77764}}; {{spell:1850}}", _u="r"}, -- dash / stampeding roar
	{id=106839, _u="s"}, -- skull bash
	{id=22812, _u="b"}, -- barkskin
	{id=61336, _u="i"}, -- survival instincts
	{id=102401, _u="c"}, -- feral charge
	{id="/cast {{spell:102543/102558}}", _u="n"}, -- Incarnation
	{id="/cast [@player,nomod][@target,help,nodead][@none] {{spell:8936}}", show="[spec:102/104/105] hide;", _u="h"}, -- Regrowth
	name=L"Feral", hotkey="[form:bear/cat] BUTTON5; ALT-BUTTON5", limit="DRUID", _u="OPCDF", v=4
})

do -- Hunter Pets
	local m = "#showtooltip [@pet,exists,nodead,nopet:%d] {{spell:%d}}\n/cast [@pet,exists,nopet:%1$d,nodead] {{spell:2641}}\n/cast [@pet,noexists,nomod] {{spell:%2$d}}; [@pet,dead][@pet,noexists] {{spell:982}}; [@pet,help,nomod] {{spell:136}}; [@pet] {{spell:2641}}"
	R:AddDefaultRing("HunterPets", {
		{id=m:format(1,883), show="[havepet:1,known:883]", _u="1"},
		{id=m:format(2,83242), show="[havepet:2,known:83242]", _u="2"},
		{id=m:format(3,83243), show="[havepet:3,known:83243]", _u="3"},
		{id=m:format(4,83244), show="[havepet:4,known:83244]", _u="4"},
		{id=m:format(5,83245), show="[havepet:5,known:83245]", _u="5"},
		name=L"Pets", limit="HUNTER", _u="OPCHP", internal=true, v=3
	})
end
R:AddDefaultRing("HunterAspects", {
	{id="/cast [combat,nomounted][nooutdoors,nomounted][outdoors,mod:shift] {{spell:186257}}; [anyflyable][mod] {{mount:air}}; {{mount:ground}}", _u="c"}, -- cheetah/mount
	{id=186265, _u="t"}, -- turtle
	{id=186289, _u="ea"}, -- eagle
	{id=5384, _u="g"}, -- feign
	{id=147362, _u="i"}, -- counter
	{"ring", "HunterPets", _u="e", show="[nospec:2][known:1223323]"},
	{id=19801, _u="q"}, -- tranq
	{id=781, _u="d"}, -- disengage
	{id="/cast [@tank1,help,nodead][@tank2,help,nodead][@pet,help,nodead][] {{spell:34477}}", _u="m"}, --misdirection
	name=L"Utility", hotkey="BUTTON4", limit="HUNTER", _u="OPCHA", v=3
})

R:AddDefaultRing("MageCombat", {
	{id=45438, _u="b"}, -- ice block
	{id=30449, _u="s"}, -- spellsteal
	{id=55342, _u="m"}, -- mirror image
	{id=12051, _u="e"}, -- evocation
	{id=108839, _u="f"}, -- ice floes
	{id=80353, _u="t"}, -- time warp
	{id="/cast {{spell:11426}}; {{spell:235450}}; {{spell:235313}}", _u="i"}, -- barrier
	{id=190319, _u="c"}, -- combustion
	name=L"Combat", limit="MAGE", hotkey="BUTTON5", _u="OPCMC", v=1
})
R:AddDefaultRing("MageTools", {
	{id="#imp critical\n/cast [anyflyable,nomod] {{mount:air}}; {{mount:ground}}\n/changeactionbar [anyflyable,advflyable,nocombat,outdoors,nobonusbar:5] 1", fastClick=true, _u="m"},
	{id=42955, _u="f"}, -- food
	{id="/cast [nomod] {{spell:110959}}; {{spell:66}}; {{spell:110959}}", _u="i"}, -- (greater) invisibility
	{"ring", "MagePolymorph", _u="t"},
	{id=130, _u="s"}, -- slow fall
	{id="/cast [@target,help,nodead][@player,nomod][] {{spell:1459}}", _u="n"}, -- intellect
	name=L"Utility", limit="MAGE", hotkey="BUTTON4", _u="OPCMT", v=4
})
R:AddDefaultRing("MagePolymorph", {
	{id=118, _u="s"}, -- sheep
	{id=161353, _u="p"}, -- polar bear
	{id=61721, _u="r"}, -- rabbit
	{id=61305, _u="b"}, -- black cat
	{id=61780, _u="t"}, -- turkey
	{id=28271, _u="u"}, -- turtle
	{id=28272, _u="i"}, -- pig
	{id=161354, _u="m"}, -- monkey
	{id=161355, _u="e"}, -- penguin
	{id=126819, _u="o"}, -- porcupine
	{id=161372, _u="k"}, -- peacock
	name=L"Polymorphs", limit="MAGE", _u="OPCMP", internal=true, v=1
})
do -- MageTravel
	local m = "/cast [mod] {{spell:%s}}; {{spell:%s}}"
	R:AddDefaultRing("MageTravel", {
		{id=m:format(446534, 446540), _u="1"}, -- Dornogal
		{id=m:format(395289, 395277), _u="0"}, -- Valdrakken
		{id=m:format(344597, 344587), _u="9"}, -- Oribos
		{id=m:format("268969/281402", "281403/281404"), _u="8"}, -- Dazar'alor/Boralus
		{id=m:format(224871, 224869), _u="b"}, -- Dalaran (Broken Isles)
		{id=m:format("132620/132626", "132621/132627"), _u="v"}, -- Vale of Eternal Blossoms
		{id=m:format(53142, 53140), _u="r"}, -- Dalaran (Northrend)
		{id=m:format("35717/33691", 33690), _u="s"}, -- Shattrath
		{id=m:format(10059, 3561), _u="w"}, -- Stormwind
		{id=m:format(11417, 3567), _u="o"}, -- Orgrimmar
		{id=m:format(11419, 3565), _u="d"}, -- Darnassus
		{id=m:format(11420, 3566), _u="t"}, -- Thunder Bluff
		{id=m:format(11418, 3563), _u="u"}, -- Undercity
		{id=m:format(11416, 3562), _u="i"}, -- Ironforge
		{"ring", "ExtraPortals", _u="e"}, -- Extra Portals
		{id=m:format(32267, 32272), _u="l"}, -- Silvermoon
		{id=m:format(32266, 32271), _u="x"}, -- Exodar
		name=L"Portals and Teleports", hotkey="ALT-G", limit="MAGE", _u="OPCMV", v=2
	})
	R:AddDefaultRing("ExtraPortals", {
		{id=m:format(120146, 120145), _u="a"}, -- Ancient Dalaran
		{id=m:format(49360, 49359), _u="m"}, -- Theramore
		{id=m:format(49361, 49358), _u="n"}, -- Stonard
		{id=m:format("88346/88345", "88344/88342"), _u="b", c="99C5CC"}, -- Tol Barad
		{id=m:format("176246/176244", "176248/176242"), _u="h", c="ff4000"}, -- Ashran
		name=L"Extra Portals", limit="MAGE", _u="OPCME", internal=true, v=1
	})
end

R:AddDefaultRing("PaladinTools", {
	{id="#imp critical\n/cast [anyflyable,outdoors,nocombat,nomod][anyflyable,combat,mounted][anyflyable,nooutdoors,mounted] {{mount:air}}; [outdoors,nocombat,nomod:shift][combat,mounted][nooutdoors,mounted] {{mount:ground}}; {{spell:190784}}\n/changeactionbar [anyflyable,advflyable,nocombat,outdoors,nomod,nobonusbar:5] 1", fastClick=true, _u="s"}, --steed
	{id=465, _u="d"}, --devotion
	{id=317920, _u="c"}, --concentration
	{id=183435, _u="r"}, --retribution
	{id=31821, _u="m"}, --mastery
	{id=96231, _u="k"}, -- rebuke
	{id="/cast [help,dead,nocombat][nocombat,mod] {{spell:7328}}; [help,dead,combat] {{spell:391054}}; {{spell:213644}}; {{spell:7328}}", _u="l"}, -- cleanse/res
	name=L"Utility", limit="PALADIN", hotkey="BUTTON4", _u="OPCPT", v=5
})
R:AddDefaultRing("WarlockLTS", {
	{id="/cast [anyflyable,outdoors,nocombat,nomod] {{mount:air}}; [outdoors,nocombat,nomod:shift] {{mount:ground}}; {{spell:126}}", fastClick=true, _u="e"}, -- mount/eye
	{"ring", "WarlockDemons", _u="d"},
	{id="/cast [mod] {{spell:755}}; {{spell:119898}}; {{spell:755}}", _u="a"}, -- funnel/command
	{id="/cast [mod:alt] {{spell:20707}}; [group,nomod][nogroup,mod] {{spell:29893}}; {{spell:6201}}", _u="h"}, -- soul/health/well
	{id=111771, _u="w"}, -- gateway
	{id=1122, _u="i"}, -- infernal
	name=L"Utility", hotkey="BUTTON4", limit="WARLOCK", _u="OPCLS", v=4
})
R:AddDefaultRing("WarlockCombat", {
	{id="/cast [nomod] {{spell:48018}}; {{spell:48020}}", _u="t"}, -- demonic circle
	{id=1098, _u="e"}, -- enslave
	{id=710, _u="a"}, -- banish
	{id=111400, _u="m"}, -- burning rush
	{id=5782, _u="f"}, -- fear
	{id=5484, _u="h"}, -- howl
	name=L"Combat", hotkey="BUTTON5", limit="WARLOCK", _u="OPCLO", v=2
})
R:AddDefaultRing("WarlockDemons", {
	{id=30146, _u="f"}, -- felguard
	{id=697, _u="v"}, -- void
	{id=688, _u="i"}, -- imp
	{id=366222, _u="s"}, -- sayaad
	{id=691, _u="h"}, -- felhunter
	name=L"Demons", limit="WARLOCK", _u="OPCLD", internal=true, v=1
})

R:AddDefaultRing("DKCombat", {
	{c="fff4b2", id=57330, _u="h"}, -- horn
	{c="5891ea", id=48792, _u="f"}, -- fortitude
	{c="bcf800", id=48707, _u="s"}, -- shell
	{c="3d63cc", id=51052, _u="z"}, -- Zone
	{c="b31500", id=55233, _u="b"}, -- blood
	{c="aef1ff", id=51271, _u="p"}, -- pillar of frost
	{c="d0d0d0", id=49039, _u="l"}, -- lich
	name=L"Combat", hotkey="BUTTON5", limit="DEATHKNIGHT", _u="OPCDC", v=1
})

R:AddDefaultRing("CommonHearth", {
	{"item", 6948, _u="h"},
	{"toy", 64488, _u="i"},
	{"toy", 54452, _u="e"},
	{"toy", 93672, _u="d"},
	{"toy", 142542, _u="t"},
	{"toy", 165669, _u="u"},
	{"toy", 165670, _u="v"},
	{"toy", 165802, _u="g"},
	{"toy", 166746, _u="f"},
	{"toy", 166747, _u="b"},
	{"toy", 163045, _u="l"},
	{"toy", 162973, _u="w"},
	{"toy", 168907, _u="m"},
	{"toy", 172179, _u="s"},
	{"toy", 182773, _u="n"},
	{"toy", 184353, _u="k"},
	{"toy", 180290, _u="nf"},
	{"toy", 183716, _u="ve"},
	{"toy", 188952, _u="do"},
	{"toy", 190196, _u="en"},
	{"toy", 190237, _u="bt"},
	{"toy", 193588, _u="tw"},
	{"toy", 200630, _u="ws"},
	{"toy", 206195, _u="pn"},
	{"toy", 208704, _u="dd"},
	{"toy", 209035, _u="df"},
	{"toy", 212337, _u="sh"},
	{"toy", 210455, _u="dh"},
	{"toy", 228940, _u="nt"},
	{"toy", 235016, _u="rm"},
	{"toy", 236687, _u="um"},
	{"toy", 245970, _u="pm"},
	{"toy", 246565, _u="co"},
	{"item", 250411, _u="lx"},
	name=L"Hearthstones", internal=true, _u="OPCHS", v=10
})
R:AddDefaultRing("SpecMenu", {
	{"specset", 1, _u="1"},
	{"specset", 2, _u="2"},
	{"specset", 3, _u="3"},
	{"specset", 4, _u="4"},
	{id="/cast {{spell:50977}}; {{spell:193753}}; {{spell:126892}}; {{spell:193759}}; {{spell:556}}", _u="c"},
	{"opie.ext", "mythport", show="[mythport]", _u="m"},
	{"toy", 110560, _u="g"},
	{"toy", 140192, _u="d"},
	{"item", 238727, _u="x"}, -- remix: nostwin's voucher
	{id=436854, _u="f", show="[level:20]"},
	{"ring", "CommonHearth", rotationMode="shuffle", _u="t"},
	{"item", 141605, _u="w", show="[in:broken isles/argus/bfa]"}, -- flight master's whistle
	name=L"Specializations and Travel", hotkey="ALT-H", _u="OPCTA", v=6
})