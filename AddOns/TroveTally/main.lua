local _,db = ...
local tocversion = select(4,GetBuildInfo())
local function tn(arg) return arg and 1 or 0 end
local userFrames = {}
local lastUserFrameSelected = nil
local colors = {
	none = {1,1,1,0},
  white = {1,1,1,1},
  gold = {1,0.7529,0,1},
	green = {ITEM_QUALITY_COLORS[2].color:GetRGBA()}
}
local ci = {
  4638724,1508519,4696085,
  135453,132858,133784,
  135441,135263,2065578,
  236570,4638431,4549242,
  4549287,4615906,4549111,
  4632799,463487,236697,
  4554372,4555553,4555554,
  4555555,4555556,4555557,
  4559245,1387373,3586015,
  3586022,133786,133788,
  134388,1693994,463562,
  876371,3386337,1686583,
  1064188,4559256,3015740,
  458224,2967113,133858,
  4638504,6215517,6255014,
  132808,1500867,237396,
  1394961,4554438,1686572
}
local scroll = 0
--215745,"Kun-Lai Summit, Isle of Giants, Isle of Thunder, Timeless Isle"
--216450,"NOTHING",
--216452,"NOTHING",
--216454,"NOTHING",
--216457,"NOTHING",
--216456,"NOTHING",
--216455,"NOTHING",
--215903,"NOTHING",
local src = {
  JADE = "翠玉林",
  VALLEY = "四風峽",
  VALE = "恆春谷",
  KUNLAI = "崑萊峰",
  TOWNLONG = "螳螂荒原",
  KRASARANG = "喀撒朗蠻荒",
  DREAD = "悚然荒野",
  THUNDER = "雷王島",
  GIANTS = "巨獸島",
  TIMELESS = "永恆之島",
  SCENARIOS_N = "事件 (普通)",
  SCENARIOS_NH = "事件 (普通/英雄)",
  SCENARIOS_H = "事件 (英雄)",
  DUNGEONS_N = "地城 (普通)",
  DUNGEONS_H = "地城 (英雄)",
  SIEGE_LFR = "圍攻奧格瑪 (團隊搜尋器)",
  SIEGE_N = "圍攻奧格瑪 (普通)",
  SIEGE_H = "圍攻奧格瑪 (英雄)",
  SIEGE_M = "圍攻奧格瑪 (傳奇)",
  THRONE_LFR = "雷霆王座 (團隊搜尋器)",
  THRONE_N = "雷霆王座 (普通)",
  THRONE_H = "雷霆王座 (英雄)",
  T14_LFR = "T14 團隊副本 (團隊搜尋器)",
  T14_N = "T14 團隊副本 (普通)",
  T14_H = "T14 團隊副本 (英雄)",
  PYTHAGORUS = "Pythagorus",
  DURUS = "Durus",
  AEONICUS = "Aeonicus",
  ARTUROS = "Arturos",
  LARAH = "Larah Treebender",
  JAKKUS = "Grandmaster Jakkus",
  HEMET = "赫米特·奈辛瓦里十七世",
  HOROS = "Horos",
  ERUS = "Erus",
  AMUUL = "Remembrancer Amuul",
  BONUS = "額外目標 (等級 < 70)",
  OSIDION = "Osidion",
  TRAEYA = "Traeya",
  ARGAROM = "Argarom",
  AILENDA = "Ailenda Hedgemyr",
  HOODED = "Hooded Purveyor",
  SOWEEZI = "Soweezi",
  TALJORI = "Taljori",
  CRATE = "Crate of Bygone Riches",
  PSMOUNTS = "Plunderstore: 坐騎",
  PSPETS = "Plunderstore: 寵物",
  PSWEAPONS = "Plunderstore: 武器",
  PSGUNS = "Plunderstore: 槍械",
  PSSWABBIE = "Plunderstore: Swabbie",
  PSSNAZZY = "Plunderstore: Snazzy",
  PSSTRAPPING = "Plunderstore: Strapping",
  PSSTORMRIDDEN = "Plunderstore: Stormridden",
  PSHEAD = "Plunderstore: 頭部",
  PSBACK = "Plunderstore: 背部",
  ROCCO = "Rocco Razzboom",
  LAB = "Lab Assistant Laszly",
  BOATSWAIN = "Boatswain Hardee",
  SHREDZ = "Shredz the Scrapper",
  WARP = "織法者 哈舒姆",
  UNICUS = "Unicus",
  SACERDORMU = "Sacerdormu",
  AGOS = "Agos the Silent",
  FREDDIE = "Freddie Threads"
}
local function srcs(...) return table.concat({...},", ") end
local data = {
  216558,src.SIEGE_M,
  215527,src.SIEGE_M,
  215472,src.SIEGE_M,
  215476,src.SIEGE_M,
  215580,src.SIEGE_M,
  215718,src.SIEGE_M,
  215670,src.SIEGE_M,
  215830,src.SIEGE_M,
  215826,src.SIEGE_M,
  215920,src.SIEGE_M,
  215912,src.SIEGE_M,
  215480,src.SIEGE_M,
  215996,src.SIEGE_M,
  215522,src.SIEGE_H,
  215691,src.SIEGE_H,
  215915,src.SIEGE_H,
  215995,src.SIEGE_H,
  215994,src.SIEGE_N,
  215554,src.SIEGE_N,
  215629,src.SIEGE_N,
  215712,src.SIEGE_N,
  215922,src.SIEGE_N,
  215836,src.SIEGE_N,
  215818,src.SIEGE_N,
  215501,src.SIEGE_LFR,
  215572,src.SIEGE_LFR,
  215663,src.SIEGE_LFR,
  215971,src.SIEGE_LFR,
  215835,src.SIEGE_LFR,
  215831,src.SIEGE_LFR,
  210643,src.SIEGE_LFR,

  215710,src.THRONE_H,
  216402,src.THRONE_H,
  215898,src.THRONE_H,
  216468,src.THRONE_H,
  216432,src.THRONE_H,
  216436,src.THRONE_H,
  215789,src.THRONE_H,
  215497,src.THRONE_H,
  215624,src.THRONE_H,
  216585,src.THRONE_H,
  215653,src.THRONE_N,
  215547,src.THRONE_N,
  215562,src.THRONE_N,
  215626,src.THRONE_N,
  216596,src.THRONE_N,
  215499,src.THRONE_N,
  216015,src.THRONE_N,
  216413,src.THRONE_N,
  216405,src.THRONE_N,
  215767,src.THRONE_N,
  215770,src.THRONE_N,
  215688,src.THRONE_N,
  215887,src.THRONE_N,
  216459,src.THRONE_N,
  216464,src.THRONE_N,
  216435,src.THRONE_N,
  215788,src.THRONE_N,
  215966,src.THRONE_N,
  216447,src.THRONE_N,
  216011,src.THRONE_N,
  215774,src.THRONE_N,
  215625,src.THRONE_LFR,
  215517,src.THRONE_LFR,
  215542,src.THRONE_LFR,
  215627,src.THRONE_LFR,
  216425,src.THRONE_LFR,
  215766,src.THRONE_LFR,
  216437,src.THRONE_LFR,
  215814,src.THRONE_LFR,
  215768,src.THRONE_LFR,
  215964,src.THRONE_LFR,
  216434,src.THRONE_LFR,
  216412,src.THRONE_LFR,
  215787,src.THRONE_LFR,
  215500,src.THRONE_LFR,
  215965,src.THRONE_LFR,
  216446,src.THRONE_LFR,
  216449,src.THRONE_LFR,

  215695,src.T14_H,
  215530,src.T14_H,
  215557,src.T14_H,
  215589,src.T14_H,
  215841,src.T14_H,
  215849,src.T14_H,
  215845,src.T14_H,
  215933,src.T14_H,
  215800,src.T14_H,
  215977,src.T14_H,
  215999,src.T14_H,
  215848,src.T14_N,
  215844,src.T14_N,
  215976,src.T14_N,
  215791,src.T14_N,
  215840,src.T14_N,
  215506,src.T14_N,
  215556,src.T14_N,
  215998,src.T14_N,
  215588,src.T14_LFR,
  215584,src.T14_LFR,
  215798,src.T14_LFR,
  216566,src.T14_LFR,
  215636,src.T14_LFR,
  215857,src.T14_LFR,
  215975,src.T14_LFR,
  216562,src.T14_LFR,
  216000,src.T14_LFR,
  215839,src.T14_LFR,
  215842,src.T14_LFR,
  215843,src.T14_LFR,
  215850,src.T14_LFR,
  215730,src.T14_LFR,
  215847,src.T14_LFR,

  215684,src.DUNGEONS_H,
  215646,src.DUNGEONS_H,
  215878,src.DUNGEONS_H,
  215983,src.DUNGEONS_H,
  216006,src.DUNGEONS_H,
  215612,src.DUNGEONS_N,
  215604,src.DUNGEONS_N,
  215609,src.DUNGEONS_N,
  215682,src.DUNGEONS_N,
  215874,src.DUNGEONS_N,
  215645,src.DUNGEONS_N,
  216581,src.DUNGEONS_N,
  215783,src.DUNGEONS_N,

  215615,src.SCENARIOS_H,
  215611,src.SCENARIOS_H,
  215757,src.SCENARIOS_H,
  215809,src.SCENARIOS_H,
  215986,src.SCENARIOS_H,
  216008,src.SCENARIOS_H,
  215648,src.SCENARIOS_H,
  215607,src.SCENARIOS_NH,
  215537,src.SCENARIOS_N,
  215614,src.SCENARIOS_N,
  215610,src.SCENARIOS_N,
  215808,src.SCENARIOS_N,
  216583,src.SCENARIOS_N,
  216007,src.SCENARIOS_N,
  215706,src.SCENARIOS_N,

  216540,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215761,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  216601,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  216530,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215897,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215960,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215515,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215550,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215623,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215619,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215893,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215776,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  216535,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  215908,srcs(src.THUNDER,src.GIANTS,src.TIMELESS),
  216600,srcs(src.THUNDER,src.TIMELESS),
  215970,srcs(src.THUNDER,src.TIMELESS),
  215496,src.DREAD,
  215513,src.DREAD,
  215541,src.DREAD,
  215622,src.DREAD,
  215617,src.DREAD,
  215649,src.DREAD,
  215762,src.DREAD,
  215759,src.DREAD,
  216536,src.DREAD,
  216538,src.DREAD,
  215895,src.DREAD,
  215958,src.DREAD,
  215988,src.DREAD,
  216439,src.KRASARANG,
  216541,src.KRASARANG,
  215495,src.TOWNLONG,
  215512,src.TOWNLONG,
  215540,src.TOWNLONG,
  215621,src.TOWNLONG,
  215616,src.TOWNLONG,
  215650,src.TOWNLONG,
  215763,src.TOWNLONG,
  215758,src.TOWNLONG,
  215657,src.TOWNLONG,
  216537,src.TOWNLONG,
  215894,src.TOWNLONG,
  215957,src.TOWNLONG,
  215987,src.TOWNLONG,
  216534,src.TOWNLONG,
  215890,src.TOWNLONG,
  215644,srcs(src.KUNLAI,src.THUNDER,src.GIANTS,src.TIMELESS),
  215703,srcs(src.KUNLAI,src.THUNDER,src.GIANTS,src.TIMELESS),
  215678,srcs(src.KUNLAI,src.THUNDER,src.TIMELESS),
  216482,src.KUNLAI,
  216473,src.KUNLAI,
  216440,src.KUNLAI,
  216445,src.KUNLAI,
  216021,src.KUNLAI,
  216022,src.KUNLAI,
  216614,src.KUNLAI,
  216421,src.KUNLAI,
  215872,srcs(src.VALE,src.KRASARANG),
  215865,srcs(src.VALE,src.KRASARANG),
  215602,srcs(src.VALE,src.KRASARANG),
  215680,srcs(src.VALE,src.KRASARANG),
  216533,src.VALE,
  215494,src.VALE,
  215514,src.VALE,
  215539,src.VALE,
  215620,src.VALE,
  215618,src.VALE,
  215651,src.VALE,
  215764,src.VALE,
  216539,src.VALE,
  215896,src.VALE,
  215959,src.VALE,
  215989,src.VALE,
  215760,src.VALE,
  215892,src.VALE,
  216002,srcs(src.VALLEY,src.DREAD),
  216480,src.VALLEY,
  216476,src.VALLEY,
  216025,src.VALLEY,
  216443,src.VALLEY,
  216001,srcs(src.JADE,src.TOWNLONG),
  215871,srcs(src.JADE,src.TOWNLONG),
  215738,srcs(src.JADE,src.TOWNLONG),
  215679,srcs(src.JADE,src.TOWNLONG),
  215658,srcs(src.JADE,src.VALE),
  216024,src.JADE,
  216423,src.JADE,
  216542,src.JADE,
  216475,src.JADE,
  216438,src.JADE,
  216442,src.JADE,
  216611,src.JADE
}
local data2 = {
  215345,{src.PYTHAGORUS,"5,000",ci[1]},
  215336,{src.PYTHAGORUS,"5,000",ci[1]},
  215328,{src.PYTHAGORUS,"5,000",ci[1]},
  215305,{src.PYTHAGORUS,"5,000",ci[1]},
  215296,{src.PYTHAGORUS,"5,000",ci[1]},
  215268,{src.PYTHAGORUS,"5,000",ci[1]},
  215259,{src.PYTHAGORUS,"5,000",ci[1]},
  215248,{src.PYTHAGORUS,"5,000",ci[1]},
  215213,{src.PYTHAGORUS,"5,000",ci[1]},
  215205,{src.PYTHAGORUS,"5,000",ci[1]},
  215195,{src.PYTHAGORUS,"5,000",ci[1]},
  215342,{src.PYTHAGORUS,"5,000",ci[1]},
  215340,{src.PYTHAGORUS,"5,000",ci[1]},
  215333,{src.PYTHAGORUS,"5,000",ci[1]},
  215331,{src.PYTHAGORUS,"5,000",ci[1]},
  215323,{src.PYTHAGORUS,"5,000",ci[1]},
  215322,{src.PYTHAGORUS,"5,000",ci[1]},
  215301,{src.PYTHAGORUS,"5,000",ci[1]},
  215299,{src.PYTHAGORUS,"5,000",ci[1]},
  215291,{src.PYTHAGORUS,"5,000",ci[1]},
  215290,{src.PYTHAGORUS,"5,000",ci[1]},
  215265,{src.PYTHAGORUS,"5,000",ci[1]},
  215262,{src.PYTHAGORUS,"5,000",ci[1]},
  215254,{src.PYTHAGORUS,"5,000",ci[1]},
  215250,{src.PYTHAGORUS,"5,000",ci[1]},
  215244,{src.PYTHAGORUS,"5,000",ci[1]},
  215242,{src.PYTHAGORUS,"5,000",ci[1]},
  215211,{src.PYTHAGORUS,"5,000",ci[1]},
  215207,{src.PYTHAGORUS,"5,000",ci[1]},
  215203,{src.PYTHAGORUS,"5,000",ci[1]},
  215200,{src.PYTHAGORUS,"5,000",ci[1]},
  215192,{src.PYTHAGORUS,"5,000",ci[1]},
  215190,{src.PYTHAGORUS,"5,000",ci[1]},

  215347,{src.DURUS,"5,000",ci[1]},
  215344,{src.DURUS,"5,000",ci[1]},
  215338,{src.DURUS,"5,000",ci[1]},
  215341,{src.DURUS,"5,000",ci[1]},
  215337,{src.DURUS,"5,000",ci[1]},
  215332,{src.DURUS,"5,000",ci[1]},
  215329,{src.DURUS,"5,000",ci[1]},
  215326,{src.DURUS,"5,000",ci[1]},
  215325,{src.DURUS,"5,000",ci[1]},
  215321,{src.DURUS,"5,000",ci[1]},
  215303,{src.DURUS,"5,000",ci[1]},
  215300,{src.DURUS,"5,000",ci[1]},
  215297,{src.DURUS,"5,000",ci[1]},
  215294,{src.DURUS,"5,000",ci[1]},
  215292,{src.DURUS,"5,000",ci[1]},
  215288,{src.DURUS,"5,000",ci[1]},
  215266,{src.DURUS,"5,000",ci[1]},
  215263,{src.DURUS,"5,000",ci[1]},
  215260,{src.DURUS,"5,000",ci[1]},
  215258,{src.DURUS,"5,000",ci[1]},
  215253,{src.DURUS,"5,000",ci[1]},
  215251,{src.DURUS,"5,000",ci[1]},
  215249,{src.DURUS,"5,000",ci[1]},
  215246,{src.DURUS,"5,000",ci[1]},
  215243,{src.DURUS,"5,000",ci[1]},
  215215,{src.DURUS,"5,000",ci[1]},
  215212,{src.DURUS,"5,000",ci[1]},
  215209,{src.DURUS,"5,000",ci[1]},
  215206,{src.DURUS,"5,000",ci[1]},
  215202,{src.DURUS,"5,000",ci[1]},
  215198,{src.DURUS,"5,000",ci[1]},
  215197,{src.DURUS,"5,000",ci[1]},
  215194,{src.DURUS,"5,000",ci[1]},
  215191,{src.DURUS,"5,000",ci[1]},

  215346,{src.AEONICUS,"5,000",ci[1]},
  215343,{src.AEONICUS,"5,000",ci[1]},
  215339,{src.AEONICUS,"5,000",ci[1]},
  215335,{src.AEONICUS,"5,000",ci[1]},
  215334,{src.AEONICUS,"5,000",ci[1]},
  215330,{src.AEONICUS,"5,000",ci[1]},
  215327,{src.AEONICUS,"5,000",ci[1]},
  215324,{src.AEONICUS,"5,000",ci[1]},
  215320,{src.AEONICUS,"5,000",ci[1]},
  215304,{src.AEONICUS,"5,000",ci[1]},
  215302,{src.AEONICUS,"5,000",ci[1]},
  215298,{src.AEONICUS,"5,000",ci[1]},
  215295,{src.AEONICUS,"5,000",ci[1]},
  215293,{src.AEONICUS,"5,000",ci[1]},
  215289,{src.AEONICUS,"5,000",ci[1]},
  215267,{src.AEONICUS,"5,000",ci[1]},
  215264,{src.AEONICUS,"5,000",ci[1]},
  215261,{src.AEONICUS,"5,000",ci[1]},
  215255,{src.AEONICUS,"5,000",ci[1]},
  215256,{src.AEONICUS,"5,000",ci[1]},
  215252,{src.AEONICUS,"5,000",ci[1]},
  215247,{src.AEONICUS,"5,000",ci[1]},
  215245,{src.AEONICUS,"5,000",ci[1]},
  215241,{src.AEONICUS,"5,000",ci[1]},
  215214,{src.AEONICUS,"5,000",ci[1]},
  215210,{src.AEONICUS,"5,000",ci[1]},
  215208,{src.AEONICUS,"5,000",ci[1]},
  215204,{src.AEONICUS,"5,000",ci[1]},
  215201,{src.AEONICUS,"5,000",ci[1]},
  215199,{src.AEONICUS,"5,000",ci[1]},
  215196,{src.AEONICUS,"5,000",ci[1]},
  215193,{src.AEONICUS,"5,000",ci[1]},
  215189,{src.AEONICUS,"5,000",ci[1]},

  215312,{src.ARTUROS,"2,500",ci[1]},
  215311,{src.ARTUROS,"2,500",ci[1]},
  215310,{src.ARTUROS,"2,500",ci[1]},
  215274,{src.ARTUROS,"2,500",ci[1]},
  215273,{src.ARTUROS,"2,500",ci[1]},
  215272,{src.ARTUROS,"2,500",ci[1]},
  215224,{src.ARTUROS,"2,500",ci[1]},
  215223,{src.ARTUROS,"2,500",ci[1]},
  215222,{src.ARTUROS,"2,500",ci[1]},
  215221,{src.ARTUROS,"2,500",ci[1]},
  215182,{src.ARTUROS,"2,500",ci[1]},
  215181,{src.ARTUROS,"2,500",ci[1]},
  215176,{src.ARTUROS,"2,500",ci[1]},

  215351,{src.LARAH,"2,000",ci[1]},
  215350,{src.LARAH,"2,000",ci[1]},
  215349,{src.LARAH,"2,000",ci[1]},
  215348,{src.LARAH,"2,000",ci[1]},
  215309,{src.LARAH,"2,000",ci[1]},
  215308,{src.LARAH,"2,000",ci[1]},
  215307,{src.LARAH,"2,000",ci[1]},
  215306,{src.LARAH,"2,000",ci[1]},
  215271,{src.LARAH,"2,000",ci[1]},
  215270,{src.LARAH,"2,000",ci[1]},
  215269,{src.LARAH,"2,000",ci[1]},
  215218,{src.LARAH,"2,000",ci[1]},
  215217,{src.LARAH,"2,000",ci[1]},
  215216,{src.LARAH,"2,000",ci[1]},
  215319,{src.LARAH,"750",ci[1]},
  215318,{src.LARAH,"750",ci[1]},
  215317,{src.LARAH,"750",ci[1]},
  215316,{src.LARAH,"750",ci[1]},
  215284,{src.LARAH,"750",ci[1]},
  215283,{src.LARAH,"750",ci[1]},
  215282,{src.LARAH,"750",ci[1]},
  215232,{src.LARAH,"750",ci[1]},
  215231,{src.LARAH,"750",ci[1]},
  215230,{src.LARAH,"750",ci[1]},
  215229,{src.LARAH,"750",ci[1]},
  215188,{src.LARAH,"750",ci[1]},
  215187,{src.LARAH,"750",ci[1]},
  215186,{src.LARAH,"750",ci[1]},
  215315,{src.LARAH,"750",ci[1]},
  215314,{src.LARAH,"750",ci[1]},
  215313,{src.LARAH,"750",ci[1]},
  215281,{src.LARAH,"750",ci[1]},
  215280,{src.LARAH,"750",ci[1]},
  215279,{src.LARAH,"750",ci[1]},
  215278,{src.LARAH,"750",ci[1]},
  215228,{src.LARAH,"750",ci[1]},
  215227,{src.LARAH,"750",ci[1]},
  215226,{src.LARAH,"750",ci[1]},
  215225,{src.LARAH,"750",ci[1]},
  215185,{src.LARAH,"750",ci[1]},
  215184,{src.LARAH,"750",ci[1]},
  215183,{src.LARAH,"750",ci[1]},
  215358,{src.LARAH,"1,250",ci[1]},
  215357,{src.LARAH,"1,250",ci[1]},
  215356,{src.LARAH,"1,250",ci[1]},
  215287,{src.LARAH,"1,250",ci[1]},
  215286,{src.LARAH,"1,250",ci[1]},
  215285,{src.LARAH,"1,250",ci[1]},
  215240,{src.LARAH,"1,250",ci[1]},
  215239,{src.LARAH,"1,250",ci[1]},
  215238,{src.LARAH,"1,250",ci[1]},
  215355,{src.LARAH,"1,250",ci[1]},
  215354,{src.LARAH,"1,250",ci[1]},
  215353,{src.LARAH,"1,250",ci[1]},
  215352,{src.LARAH,"1,250",ci[1]},
  215277,{src.LARAH,"2,500",ci[1]},
  215276,{src.LARAH,"2,500",ci[1]},
  215275,{src.LARAH,"2,500",ci[1]},
  215220,{src.LARAH,"2,500",ci[1]},
  215219,{src.LARAH,"2,500",ci[1]},

  217838,{src.JAKKUS,"4,000",ci[1]},
  217839,{src.JAKKUS,"4,000",ci[1]},
  217833,{src.JAKKUS,"4,000",ci[1]},
  217844,{src.JAKKUS,"4,000",ci[1]},
  217845,{src.JAKKUS,"4,000",ci[1]},
  217846,{src.JAKKUS,"4,000",ci[1]},
  217841,{src.JAKKUS,"4,000",ci[1]},
  217836,{src.JAKKUS,"4,000",ci[1]},
  217834,{src.JAKKUS,"4,000",ci[1]},
  217835,{src.JAKKUS,"4,000",ci[1]},
  217842,{src.JAKKUS,"4,000",ci[1]},
  217843,{src.JAKKUS,"4,000",ci[1]},
  217837,{src.JAKKUS,"4,000",ci[1]},
  217825,{src.JAKKUS,"3,000",ci[1]},
  217826,{src.JAKKUS,"3,000",ci[1]},
  217819,{src.JAKKUS,"3,000",ci[1]},
  217830,{src.JAKKUS,"3,000",ci[1]},
  217831,{src.JAKKUS,"3,000",ci[1]},
  217832,{src.JAKKUS,"3,000",ci[1]},
  217827,{src.JAKKUS,"3,000",ci[1]},
  217823,{src.JAKKUS,"3,000",ci[1]},
  217820,{src.JAKKUS,"3,000",ci[1]},
  217821,{src.JAKKUS,"3,000",ci[1]},
  217829,{src.JAKKUS,"3,000",ci[1]},
  217828,{src.JAKKUS,"3,000",ci[1]},
  217824,{src.JAKKUS,"3,000",ci[1]}
}
local data3 = {
  104253,{src.HEMET,"38,500",ci[1]},
  224374,{src.HEMET,"38,500",ci[1]},
  95057,{src.HEMET,"38,500",ci[1]},
  87771,{src.HEMET,"38,500",ci[1]},
  104269,{src.HEMET,"38,500",ci[1]},
  87777,{src.HEMET,"18,700",ci[1]},
  95059,{src.HEMET,"38,500",ci[1]},
  93666,{src.HEMET,"38,500",ci[1]},
  89783,{src.HEMET,"38,500",ci[1]},
  94228,{src.HEMET,"38,500",ci[1]},
  94229,{src.HEMET,"18,700",ci[1]},
  94231,{src.HEMET,"18,700",ci[1]},
  94230,{src.HEMET,"18,700",ci[1]},
  213596,{src.HEMET,"6,600",ci[1]},
  213597,{src.HEMET,"6,600",ci[1]},
  213598,{src.HEMET,"6,600",ci[1]},
  213601,{src.HEMET,"6,600",ci[1]},
  213600,{src.HEMET,"6,600",ci[1]},
  218111,{src.HEMET,"4,400",ci[1]},
  213621,{src.HEMET,"4,400",ci[1]},
  213622,{src.HEMET,"4,400",ci[1]},
  213623,{src.HEMET,"4,400",ci[1]},
  213625,{src.HEMET,"4,400",ci[1]},
  213624,{src.HEMET,"4,400",ci[1]},
  213626,{src.HEMET,"4,400",ci[1]},
  84753,{src.HEMET,"2,200",ci[1]},
  87787,{src.HEMET,"2,200",ci[1]},
  87786,{src.HEMET,"2,200",ci[1]},
  213627,{src.HEMET,"2,200",ci[1]},
  213628,{src.HEMET,"2,200",ci[1]},
  213609,{src.HEMET,"2,200",ci[1]},
  213608,{src.HEMET,"2,200",ci[1]},
  213604,{src.HEMET,"2,200",ci[1]},
  213607,{src.HEMET,"2,200",ci[1]},
  213606,{src.HEMET,"2,200",ci[1]},
  213605,{src.HEMET,"2,200",ci[1]},
  213603,{src.HEMET,"2,200",ci[1]},
  213602,{src.HEMET,"2,200",ci[1]},
  87784,{src.HEMET,"2,200",ci[1]},
  213595,{src.HEMET,"2,200",ci[1]},
  213584,{src.HEMET,"2,200",ci[1]},
  213576,{src.HEMET,"2,200",ci[1]},
  213582,{src.HEMET,"2,200",ci[1]}
}
local data4 = {
  104309,{src.HOROS,"50,000",ci[1]},
  98136,{src.HOROS,"50,000",ci[1]},
  104331,{src.HOROS,"38,500",ci[1]},
  104302,{src.HOROS,"38,500",ci[1]},
  86588,{src.HOROS,"7,700",ci[1]},
  86568,{src.HOROS,"7,700",ci[1]},
  86582,{src.HOROS,"7,700",ci[1]},
  86573,{src.HOROS,"4,950",ci[1]},
  86583,{src.HOROS,"4,950",ci[1]},
  86586,{src.HOROS,"4,950",ci[1]},
  86593,{src.HOROS,"4,950",ci[1]},
  86581,{src.HOROS,"4,950",ci[1]},
  86578,{src.HOROS,"4,950",ci[1]},
  86589,{src.HOROS,"4,950",ci[1]},
  86571,{src.HOROS,"3,850",ci[1]},
  86594,{src.HOROS,"3,850",ci[1]},
  86590,{src.HOROS,"3,850",ci[1]},
  86575,{src.HOROS,"3,850",ci[1]},
  134023,{src.HOROS,"3,850",ci[1]},
  86565,{src.HOROS,"3,850",ci[1]},
  104262,{src.HOROS,"2,200",ci[1]},
  89205,{src.HOROS,"500",ci[1]}
}
local data5 = {
  89196,{src.HOROS,"500",ci[1]},
  226127,{src.LARAH,"5",ci[1]},
  224459,{src.PYTHAGORUS,"38,500",ci[1],"20",ci[2]},
  104404,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104402,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104401,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104400,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104409,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104407,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104399,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104408,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104406,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104405,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  104403,{src.PYTHAGORUS,"8,000",ci[1],"2",ci[2]},
  224081,{src.ERUS,"20",ci[1]},
  224078,{src.ERUS,"20",ci[1]},
  224077,{src.ERUS,"20",ci[1]},
  224076,{src.ERUS,"20",ci[1]},
  224075,{src.ERUS,"20",ci[1]},
  224080,{src.ERUS,"20",ci[1]},
  224079,{src.ERUS,"20",ci[1]}
}

local data6 = {
  212525,"?", --ok
  170197,"Keg Leg 的船員（名望 16）", --ok
  200116,"攻打龍禍要塞", --ok
  208704,"促銷", --ok
  208883,"促銷", --ok
  210467,"遊戲內商店", --ok
  218128,"魔獸世界電競：巨龍崛起第 4 賽季", --ok (event)
  211424,"魔獸世界電競：巨龍崛起第 3 賽季", --ok (event)
  208057,"魔獸世界電競：巨龍崛起第 2 賽季", --ok (event)
  203716,"魔獸世界電競：巨龍崛起第 1 賽季", --ok (event)
  210042,"BlizzCon 2023", --ok (event)
  192443,"工程學", --ok
  192495,"工程學", --ok
  198156,"工程學", --ok
  198173,"工程學", --ok
  198206,"工程學", --ok
  198227,"工程學", --ok
  198264,"工程學", --ok
  199554,"工程學", --ok
  201930,"工程學", --ok
  202309,"工程學", --ok
  202360,"工程學", --ok
  204818,"工程學", --ok
  207092,"工程學", --ok
  193032,"珠寶設計", --ok
  193033,"珠寶設計", --ok
  205045,"珠寶設計", --ok
  193476,"製皮", --ok
  193478,"製皮", --ok
  197719,"製皮", --ok
  194052,"裁縫", --ok
  194056,"裁縫", --ok
  194057,"裁縫", --ok
  194058,"裁縫", --ok
  194059,"裁縫", --ok
  194060,"裁縫", --ok
  200469,"附魔", --ok
  200636,"洪荒祈喚萃取物", --ok (right-click to use)
  201931,"Rumble 獎勵箱", --ok (right-click to use)
  202261,"Rumble 獎勵箱", --ok (right-click to use)
  202851,"Rumble 獎勵箱", --ok (right-click to use)
  202856,"Rumble 獎勵箱", --ok (right-click to use)
  202859,"Rumble 獎勵箱", --ok (right-click to use)
  202862,"Rumble 獎勵箱", --ok (right-click to use)
  202865,"Rumble 獎勵箱", --ok (right-click to use)
  201815,"暮光儲藏箱, 暮光保險箱", --ok (right-click to open)
  202042,"無瑕的斯沃格珍寶袋", --ok (right-click to open)
  208825,"冬幕節禮物", --ok (right-click to open)
  209859,"被偷走的禮物", --ok (right-click to open)
  210656,"輕輕搖晃過的禮物", --ok (right-click to open)
  200869,"半人馬號角", --ok (treasure)
  201927,"被遺忘的珠寶盒", --ok (treasure)
  201933,"遺失的黑曜儲藏箱", --ok (treasure)
  202019,"金龍酒杯", --ok (treasure)
  202022,"耶努的風箏", --ok (treasure)
  202711,"遺失的羅盤", --ok (treasure)
  203757,"瘋狂火盆", --ok (treasure)
  203852,"孢子綁定精華", --ok (treasure)
  204256,"歌劇寶箱", --ok (treasure)
  204257,"歌劇寶箱", --ok (treasure)
  204262,"歌劇寶箱", --ok (treasure)
  204687,"茲凱拉金庫", --ok (treasure)
  205418,"熾炎暗焰寶箱", --ok (treasure)
  208096,"熟悉的日誌", --ok (treasure)
  210411,"松鼩鼱堆", --ok (treasure)
  210725,"隱藏的梟獸藏匿處", --ok (treasure)
  211788,"追思花束", --ok (treasure)
  200148,"稀有怪（薩爪祖斯）", --ok (drop)
  198409,"稀有怪", --ok (drop)
  200198,"稀有怪", --ok (drop)
  200249,"稀有怪", --ok (drop)
  199337,"Gaelzion, Karantun, Pipspark Thundersnap, Voraazka", --ok (drop)
  200160,"Gutrot Slime", --ok (drop)
  200178,"Blightfur, Blightpaw the Depraved, High Shaman Rotknuckle", --ok (drop)
  200857,"黑曜城塞", --ok (drop)
  200999,"The Great Shellkhan", --ok (drop)
  205419,"Dinn", --ok (drop)
  205463,"熔縛者的門徒", --ok (drop)
  205796,"Invoq", --ok (drop)
  206008,"寶藏哥布林", --ok (drop)
  206043,"Kretchenwrath, Shadeisethal", --ok (drop)
  206993,"時光調查員", --ok (drop)
  209035,"火焰看守者 拉羅達爾", --ok (drop)
  212337,"砰砰博士", --ok (drop)
  198402,{"軍需官胡森格","100",ci[9],"2",ci[14]}, --ok
  200550,{"軍需官胡森格","100",ci[9],"2",ci[38]}, --ok
  200551,{"軍需官胡森格","100",ci[9],"2",ci[38]}, --ok
  198646,{"Emilia Bellocq","200",ci[6]}, --ok
  199900,{"Emilia Bellocq","5",ci[6]}, --ok
  198720,{"商人","100",ci[9],"20",ci[12],"2",ci[13]}, --ok
  198721,{"商人","100",ci[9],"20",ci[12],"2",ci[13]}, --ok
  198722,{"商人","100",ci[9],"20",ci[12],"2",ci[13]}, --ok
  200640,{"商人","100",ci[9],"1",ci[35],"1",ci[27]}, --ok
  198728,{"目錄管理員傑克斯","150",ci[9],"20",ci[12]}, --ok
  198729,{"目錄管理員傑克斯","150",ci[9],"20",ci[12]}, --ok
  198827,{"Kiopo, Murik","400",ci[9],"5",ci[15],"5",ci[16]}, --ok
  199899,{"Kiopo, Murik","400",ci[9],"5",ci[16],"2",ci[18]}, --ok
  199649,{"Erugosa, Unatos","100",ci[9],"3",ci[14]}, --ok
  199650,{"Lil Ki, Murik","100",ci[9],"1",ci[17]}, --ok
  199892,{"Lil Ki, Murik","100",ci[9],"2",ci[14]}, --ok
  199767,{"Unatos","150",ci[9],"20",ci[12],"1",ci[24]}, --ok
  199768,{"Unatos","150",ci[9],"20",ci[12],"1",ci[20]}, --ok
  199769,{"Unatos","150",ci[9],"20",ci[12],"1",ci[21]}, --ok
  199770,{"Unatos","150",ci[9],"20",ci[12],"1",ci[22]}, --ok
  199771,{"Unatos","150",ci[9],"20",ci[12],"1",ci[23]}, --ok
  199894,{"Murik, Nunvuq","400",ci[9],"10",ci[26],"5",ci[28]}, --ok
  199896,{"Murik, Nunvuq","400",ci[9],"10",ci[34],"5",ci[19]}, --ok
  199897,{"Lontupit, Murik","100",ci[9],"10",ci[25],"10",ci[34]}, --ok
  200707,{"Atticus Belle, Lorena Belle","100",ci[9],"20",ci[12]}, --ok
  201435,{"Usodormu","3",ci[6],"75",ci[29]}, --ok
  202020,{"Brendormi","1,200",ci[31],"75",ci[33]}, --ok
  202021,{"Warkeeper Gresh","1,500",ci[11]}, --ok
  203734,{"Kazzi","200",ci[9]}, --ok
  204675,{"貴族花園商人, 貴族花園商販","200",ci[10]}, --ok
  205936,{"Boragg, Bottles, Chigoe, Floressa, Lyssa","1",ci[30]}, --ok
  205963,{"Harlowe Marl","200",ci[9]}, --ok
  206038,{"仲夏節慶商人, 仲夏節慶供應商","500",ci[8]}, --ok
  206195,{"Gaal","900",ci[37],"90",ci[32],"90",ci[36]}, --ok
  206268,{"貿易站","500",ci[3]}, --ok
  206347,{"貿易站","10",ci[3]}, --ok
  212500,{"貿易站","200",ci[3]}, --ok
  212523,{"貿易站","200",ci[3]}, --ok
  212524,{"貿易站","200",ci[3]}, --ok
  218112,{"貿易站","200",ci[3]}, --ok
  220692,{"貿易站","350",ci[3]}, --ok
  206565,{"Zackett Skullsmash","15",ci[7]}, --ok
  209052,{"Belbi Quikswitch, Blix Fixwidget, Bragdur Battlebrew","200",ci[6]}, --ok
  209858,{"Celestine of the Harvest","500",ci[5]}, --ok
  209944,{"Celestine of the Harvest","500",ci[5]}, --ok
  210974,{"Kiera Torres, Lythianne Morningspear","40",ci[4]}, --ok
  210975,{"Kiera Torres, Lythianne Morningspear","100",ci[4]}, --ok
  211864,{"Kiera Torres, Lythianne Morningspear","270",ci[4]}, --ok
  212518,{"Dathendrash, Maztha","40",ci[1]}, --ok
  197961,"成就：托兒所大賽", --ok
  197986,"成就：玩具的喜悅", --ok
  198428,"成就：急流駕馭者", --ok
  200630,"成就：向先祖致敬", --ok
  200631,"成就：素食飲食", --ok
  202207,"成就：Discombobberlated", --ok
  205904,"成就：洞穴爪擊", --ok
  211869,"成就：傳奇：巨龍崛起第 4 賽季", --ok
  210497,"成就：傳奇：巨龍崛起第 3 賽季", --ok
  206267,"成就：傳奇：巨龍崛起第 2 賽季", --ok
  206343,"成就：傳奇：巨龍崛起第 1 賽季", --ok
  207099,"成就：好多箱子，好多石頭", --ok
  208186,"成就：時間收購專家", --ok
  208421,"成就：最佳星辰", --ok
  208433,"成就：飛龍騎術挑戰：巨龍群島：銅牌", --ok
  211946,"成就：爐石初學者", --ok
  217723,"成就：無窮能量 XII", --ok
  217724,"成就：無窮能量 XII", --ok
  217725,"成就：無窮能量 XII", --ok
  217726,"成就：無窮能量 XII", --ok
  220777,"成就：翠玉林", --ok
  191891,"任務：翹首以盼的蛋爆炸", --ok
  194885,"任務：與風與雙翼交友", --ok
  198039,"任務：情感支援夥伴", --ok
  198090,"任務：壞蘋果", --ok
  198474,"任務：快樂的小意外", --ok
  198537,"任務：泰凡的使命", --ok
  198857,"任務：療癒中的朋友", --ok
  199830,"任務：測試海象武庫", --ok
  199902,"任務：探路者的羅盤", --ok
  200597,"任務：合我奧恩心意", --ok
  200628,"任務：伸出援爪", --ok
  200878,"任務：歸還耶努的玩具小船", --ok
  200926,"任務：為了他人的愛", --ok
  200960,"任務：帷幕之外的形體", --ok
  202253,"任務：冬裘勇士", --ok
  202283,"任務：擊垮他", --ok
  203725,"任務：最後的話語", --ok
  204170,"任務：Aka'magosh", --ok
  204220,"任務：赫拉克西安的不屈意志", --ok
  204389,"任務：王子的耐心", --ok
  204686,"任務：一縷銀光", --ok
  205255,"任務：像尼芬那樣做", --ok
  205688,"任務：閃閃發光的一切", --ok
  205908,"任務：平和的道別", --ok
  206696,"任務：未完成的思考帽", --ok
  207730,"任務：手中的神像", --ok
  208058,"任務：可預見的友誼", --ok
  208092,"任務：神器已確保", --ok
  208415,"任務：無盡黎明：時光領主戴奧斯", --ok
  208658,"任務：證據與承諾", --ok
  208798,"任務：圓盤遞送", --ok
  210455,"任務：我們前進的道路", --ok
  210864,"任務：翡翠夢境中的睏倦德魯伊", --ok
  216881,"任務：搖搖擺擺走開就好", --ok
  223146,"任務：姐妹之罪" --ok
}

local data7 = {
  219229,{src.AMUUL,"4,000",ci[39]},
  219230,{src.AMUUL,"5,000",ci[39]},
  219231,{src.AMUUL,"4,000",ci[39]},
  219232,{src.AMUUL,"8,000",ci[39]},
  219234,{src.AMUUL,"5,000",ci[39]},
  219235,{src.AMUUL,"4,000",ci[39]},
  219236,{src.AMUUL,"3,000",ci[39]},
  219237,{src.AMUUL,"8,000",ci[39]},
  219238,{src.AMUUL,"8,000",ci[39]},
  219239,{src.AMUUL,"8,000",ci[39]},
  219240,{src.AMUUL,"8,000",ci[39]},
  219241,{src.AMUUL,"8,000",ci[39]},
  219242,{src.AMUUL,"8,000",ci[39]},
  219244,{src.AMUUL,"3,000",ci[39]},
  219245,{src.AMUUL,"8,000",ci[39]},
  219246,{src.AMUUL,"8,000",ci[39]},
  219247,{src.AMUUL,"5,000",ci[39]},
  219248,{src.AMUUL,"4,000",ci[39]},
  219249,{src.AMUUL,"4,000",ci[39]},
  219250,{src.AMUUL,"5,000",ci[39]},
  219251,{src.AMUUL,"4,000",ci[39]},
  219252,{src.AMUUL,"5,000",ci[39]},
  219253,{src.AMUUL,"4,000",ci[39]},
  218057,{src.AMUUL,"5,000",ci[39]},
  218050,{src.AMUUL,"5,000",ci[39]},
  218073,{src.AMUUL,"5,000",ci[39]},
  218063,{src.AMUUL,"5,000",ci[39]},
  218075,{src.AMUUL,"3,500",ci[39]},
  218067,{src.AMUUL,"3,500",ci[39]},
  218062,{src.AMUUL,"3,500",ci[39]},
  218054,{src.AMUUL,"3,500",ci[39]},
  218047,{src.AMUUL,"5,000",ci[39]},
  218061,{src.AMUUL,"5,000",ci[39]},
  218070,{src.AMUUL,"5,000",ci[39]},
  218064,{src.AMUUL,"5,000",ci[39]},
  218051,{src.AMUUL,"5,000",ci[39]},
  218058,{src.AMUUL,"5,000",ci[39]},
  218074,{src.AMUUL,"5,000",ci[39]},
  218006,{src.AMUUL,"5,000",ci[39]},
  218071,{src.AMUUL,"3,500",ci[39]},
  218055,{src.AMUUL,"3,500",ci[39]},
  218048,{src.AMUUL,"3,500",ci[39]},
  218065,{src.AMUUL,"3,500",ci[39]},
  218066,{src.AMUUL,"3,500",ci[39]},
  218049,{src.AMUUL,"3,500",ci[39]},
  218072,{src.AMUUL,"3,500",ci[39]},
  218056,{src.AMUUL,"3,500",ci[39]},
  218077,{src.AMUUL,"2,000",ci[39]},
  218053,{src.AMUUL,"2,000",ci[39]},
  218060,{src.AMUUL,"2,000",ci[39]},
  218069,{src.AMUUL,"2,000",ci[39]},
  218076,{src.AMUUL,"3,500",ci[39]},
  218059,{src.AMUUL,"3,500",ci[39]},
  218052,{src.AMUUL,"3,500",ci[39]},
  218068,{src.AMUUL,"3,500",ci[39]},
  218078,{src.AMUUL,"2,000",ci[39]},
  218080,{src.AMUUL,"2,000",ci[39]},
  218081,{src.AMUUL,"2,000",ci[39]},
  218079,{src.AMUUL,"2,000",ci[39]},
  218086,{src.AMUUL,"10,000",ci[39]},
  218245,{src.AMUUL,"10,000",ci[39]},
  218246,{src.AMUUL,"10,000",ci[39]},
  217987,{src.AMUUL,"20,000",ci[39]},
  217985,{src.AMUUL,"20,000",ci[39]},
  219325,"Lifeless Stone Ring"
}
local data8 = {
  218330,src.BONUS,
  218318,src.BONUS,
  218324,src.BONUS,
  218312,src.BONUS,
  218313,src.BONUS,
  218325,src.BONUS,
  218329,src.BONUS,
  218317,src.BONUS,
  218327,src.BONUS,
  218315,src.BONUS,
  218332,src.BONUS,
  218320,src.BONUS,
  218334,src.BONUS,
  218322,src.BONUS,
  218328,src.BONUS,
  218316,src.BONUS,
  218331,src.BONUS,
  218319,src.BONUS,
  218333,src.BONUS,
  218321,src.BONUS,
  218335,src.BONUS,
  218323,src.BONUS,
  218326,src.BONUS,
  218314,src.BONUS,
  218035,src.BONUS,
  218026,src.BONUS,
  218260,src.BONUS,
  218251,src.BONUS,
  218281,src.BONUS,
  218272,src.BONUS,
  218299,src.BONUS,
  218290,src.BONUS,
  217991,src.BONUS,
  218024,src.BONUS,
  218263,src.BONUS,
  218254,src.BONUS,
  218284,src.BONUS,
  218275,src.BONUS,
  218302,src.BONUS,
  218293,src.BONUS,
  218039,src.BONUS,
  218030,src.BONUS,
  218265,src.BONUS,
  218256,src.BONUS,
  218286,src.BONUS,
  218277,src.BONUS,
  218304,src.BONUS,
  218295,src.BONUS,
  218036,src.BONUS,
  218027,src.BONUS,
  218261,src.BONUS,
  218252,src.BONUS,
  218282,src.BONUS,
  218273,src.BONUS,
  218300,src.BONUS,
  218291,src.BONUS,
  218040,src.BONUS,
  218031,src.BONUS,
  218266,src.BONUS,
  218257,src.BONUS,
  218287,src.BONUS,
  218278,src.BONUS,
  218305,src.BONUS,
  218296,src.BONUS,
  218034,src.BONUS,
  218025,src.BONUS,
  218259,src.BONUS,
  218250,src.BONUS,
  218280,src.BONUS,
  218271,src.BONUS,
  218298,src.BONUS,
  218289,src.BONUS,
  218306,src.BONUS,
  218297,src.BONUS,
  218267,src.BONUS,
  218258,src.BONUS,
  218288,src.BONUS,
  218279,src.BONUS,
  218041,src.BONUS,
  218032,src.BONUS,
  218038,src.BONUS,
  218029,src.BONUS,
  218264,src.BONUS,
  218255,src.BONUS,
  218285,src.BONUS,
  218276,src.BONUS,
  218303,src.BONUS,
  218294,src.BONUS,
  218037,src.BONUS,
  218028,src.BONUS,
  218262,src.BONUS,
  218253,src.BONUS,
  218283,src.BONUS,
  218274,src.BONUS,
  218301,src.BONUS,
  218292,src.BONUS
}
local data9 = {
  219100,{src.OSIDION,"9,750",ci[41]},
  219101,{src.OSIDION,"9,750",ci[41]},
  219102,{src.OSIDION,"9,750",ci[41]},
  219103,{src.OSIDION,"9,750",ci[41]},
  219104,{src.OSIDION,"9,750",ci[41]},
  219106,{src.OSIDION,"9,750",ci[41]},
  219107,{src.OSIDION,"9,750",ci[41]},
  219108,{src.OSIDION,"9,750",ci[41]},
  219109,{src.OSIDION,"9,750",ci[41]},
  219111,{src.OSIDION,"9,750",ci[41]},
  219112,{src.OSIDION,"9,750",ci[41]},
  219113,{src.OSIDION,"9,750",ci[41]},
  219114,{src.OSIDION,"9,750",ci[41]},
  219116,{src.OSIDION,"9,750",ci[41]},
  219117,{src.OSIDION,"9,750",ci[41]},
  219118,{src.OSIDION,"9,750",ci[41]},
  219119,{src.OSIDION,"9,750",ci[41]},
  219120,{src.OSIDION,"9,750",ci[41]},
  219121,{src.OSIDION,"9,750",ci[41]},
  219122,{src.OSIDION,"9,750",ci[41]},
  219123,{src.OSIDION,"9,750",ci[41]},
  219124,{src.OSIDION,"9,750",ci[41]},
  219126,{src.OSIDION,"9,750",ci[41]},
  219127,{src.OSIDION,"9,750",ci[41]},
  219128,{src.OSIDION,"9,750",ci[41]},
  219129,{src.OSIDION,"9,750",ci[41]},
  219130,{src.OSIDION,"9,750",ci[41]},
  219131,{src.OSIDION,"9,750",ci[41]},
  219133,{src.OSIDION,"9,750",ci[41]},
  219134,{src.OSIDION,"9,750",ci[41]}
}
local data10 = {
  225542,"Achievement: Let Me Solo Him",
  224770,{"Sir Finley Mrrgglton","2500",ci[42]},
  224768,{"Sir Finley Mrrgglton","2500",ci[42]},
  224769,{"Sir Finley Mrrgglton","3000",ci[42]},
  224771,{"Sir Finley Mrrgglton","2000",ci[42]},
  224981,{"Season 1 Delver's Journey","10",ci[41]},
  224979,{"Season 1 Delver's Journey","10",ci[41]},
  224980,{"Season 1 Delver's Journey","10",ci[41]},
  224982,{"Season 1 Delver's Journey","10",ci[41]},
  224960,{"Season 1 Delver's Journey","10",ci[41]},
  219391,"Quest: Ship It!"
}
local data11 = {
  228197,{src.TRAEYA,"60",ci[43]},
  228209,{src.TRAEYA,"60",ci[43]},
  228203,{src.TRAEYA,"60",ci[43]},
  228202,{src.TRAEYA,"60",ci[43]},
  228204,{src.TRAEYA,"60",ci[43]},
  228198,{src.TRAEYA,"60",ci[43]},
  228208,{src.TRAEYA,"60",ci[43]},
  228201,{src.TRAEYA,"60",ci[43]},
  228200,{src.TRAEYA,"60",ci[43]},
  228207,{src.TRAEYA,"60",ci[43]},
  228199,{src.TRAEYA,"60",ci[43]},
  228206,{src.TRAEYA,"60",ci[43]},
  228205,{src.TRAEYA,"60",ci[43]}
}
local dbData = {[18] = {
  232639,"Quest: Thrayir, Eyes of the Siren",{t=1},
  233489,"Quest: A Loyal Friend",{t=1},
  232991,"Achievement: Isle Remember You",{t=1},
  233058,{src.SOWEEZI,"10,000",ci[44]},{t=1},
  235017,"Gunnlod the Sea-Drinker, Ksvir the Forgotten, Shardsong",{t=3},
  233486,{src.AILENDA,"750",ci[44]},{t=3},
  235015,{src.HOODED,"750",ci[44]},{t=3},
  234473,{src.SOWEEZI,"750",ci[44]},{t=3},
  233056,"Quest: Homeward Bound to Safer Shores",{t=5},
  234379,"Stormtouched Pridetalon, Tempest Talon",{t=5},
  234395,{src.SOWEEZI,"750",ci[44]},{t=5},
  234518,{src.AILENDA,"3,000",ci[44]},{t=2},
  234517,{src.AILENDA,"3,000",ci[44]},{t=2},
  234524,{src.HOODED,"3,000",ci[44]},{t=2},
  221543,{src.SOWEEZI,"4,500",ci[44]},{t=2},
  222960,{src.SOWEEZI,"4,500",ci[44]},{t=2},
  234523,{src.SOWEEZI,"2,000",ci[44]},{t=2},
  234522,{src.SOWEEZI,"2,000",ci[44]},{t=2},
  234521,{src.SOWEEZI,"2,000",ci[44]},{t=2},
  234520,{src.SOWEEZI,"1,500",ci[44]},{t=2},
  234519,{src.SOWEEZI,"2,000",ci[44]},{t=2},
  234536,{src.TALJORI,"3,000",ci[44]},{t=2},
  234537,{src.TALJORI,"3,000",ci[44]},{t=2},
  234538,{src.TALJORI,"3,000",ci[44]},{t=2},
  234513,{src.TALJORI,"3,000",ci[44]},{t=2},
  234514,{src.TALJORI,"3,000",ci[44]},{t=2},
  234515,{src.TALJORI,"3,000",ci[44]},{t=2},
  234516,{src.TALJORI,"3,000",ci[44]},{t=2},
  229181,"Pilfered Earthen Chest",{},
  233831,"Minnow's Favorite Blade",{},
  233834,"Stone Carver's Scramseax",{},
  233910,"Barnacle-Encrusted Chest",{},
  233916,"Ashvane Issued Workboots",{},
  233955,"Iron Mining Pick",{},
  233957,"Kul Tiran Lumberer's Hatchet",{},
  233814,src.CRATE,{},
  233815,src.CRATE,{},
  233820,src.CRATE,{},
  233821,src.CRATE,{},
  233825,src.CRATE,{},
  233827,src.CRATE,{},
  233914,src.CRATE,{},
  233915,src.CRATE,{},
  233925,{src.AILENDA,"350",ci[44]},{},
  233922,{src.AILENDA,"350",ci[44]},{},
  233917,{src.AILENDA,"350",ci[44]},{},
  233924,{src.AILENDA,"350",ci[44]},{},
  233921,{src.AILENDA,"350",ci[44]},{},
  233918,{src.AILENDA,"350",ci[44]},{},
  233923,{src.AILENDA,"350",ci[44]},{},
  233920,{src.AILENDA,"350",ci[44]},{},
  233919,{src.AILENDA,"350",ci[44]},{},
  233812,{src.AILENDA,"350",ci[44]},{},
  233823,{src.AILENDA,"350",ci[44]},{},
  235412,{src.AILENDA,"200",ci[44]},{},
  233836,{src.AILENDA,"350",ci[44]},{},
  233835,{src.AILENDA,"200",ci[44]},{},
  233828,{src.AILENDA,"200",ci[44]},{},
  229190,{src.ARGAROM,"350",ci[44]},{},
  229191,{src.ARGAROM,"350",ci[44]},{},
  229189,{src.ARGAROM,"350",ci[44]},{},
  229176,{src.ARGAROM,"350",ci[44]},{},
  229171,{src.ARGAROM,"350",ci[44]},{},
  229177,{src.ARGAROM,"350",ci[44]},{},
  229180,{src.ARGAROM,"350",ci[44]},{},
  229173,{src.ARGAROM,"350",ci[44]},{},
  229172,{src.ARGAROM,"350",ci[44]},{},
  229186,{src.ARGAROM,"350",ci[44]},{},
  229187,{src.ARGAROM,"350",ci[44]},{},
  229185,{src.ARGAROM,"175",ci[44]},{},
  229169,{src.ARGAROM,"175",ci[44]},{},
  229170,{src.ARGAROM,"175",ci[44]},{},
  229178,{src.ARGAROM,"175",ci[44]},{},
  229179,{src.ARGAROM,"175",ci[44]},{},
  229184,{src.ARGAROM,"175",ci[44]},{},
  229192,{src.ARGAROM,"175",ci[44]},{},
  229183,{src.ARGAROM,"175",ci[44]},{},
  229182,{src.ARGAROM,"175",ci[44]},{},
  229168,{src.ARGAROM,"175",ci[44]},{},
  229167,{src.ARGAROM,"175",ci[44]},{},
  229174,{src.ARGAROM,"175",ci[44]},{},
  229175,{src.ARGAROM,"175",ci[44]},{},
  229188,{src.ARGAROM,"175",ci[44]},{},
  229044,{src.ARGAROM,"105",ci[44]},{},
  229043,{src.ARGAROM,"140",ci[44]},{},
  229042,{src.ARGAROM,"140",ci[44]},{},
  229041,{src.ARGAROM,"175",ci[44]},{},
  229040,{src.ARGAROM,"175",ci[44]},{},
  229039,{src.ARGAROM,"140",ci[44]},{},
  229038,{src.ARGAROM,"140",ci[44]},{},
  229037,{src.ARGAROM,"175",ci[44]},{},
  229035,{src.ARGAROM,"105",ci[44]},{},
  229034,{src.ARGAROM,"140",ci[44]},{},
  229033,{src.ARGAROM,"140",ci[44]},{},
  229032,{src.ARGAROM,"175",ci[44]},{},
  229031,{src.ARGAROM,"175",ci[44]},{},
  229030,{src.ARGAROM,"140",ci[44]},{},
  229029,{src.ARGAROM,"140",ci[44]},{},
  229028,{src.ARGAROM,"175",ci[44]},{},
  229026,{src.ARGAROM,"105",ci[44]},{},
  229025,{src.ARGAROM,"140",ci[44]},{},
  229024,{src.ARGAROM,"140",ci[44]},{},
  229023,{src.ARGAROM,"175",ci[44]},{},
  229045,{src.ARGAROM,"175",ci[44]},{},
  229022,{src.ARGAROM,"140",ci[44]},{},
  229021,{src.ARGAROM,"140",ci[44]},{},
  229020,{src.ARGAROM,"175",ci[44]},{},
  229018,{src.ARGAROM,"105",ci[44]},{},
  229017,{src.ARGAROM,"140",ci[44]},{},
  229016,{src.ARGAROM,"140",ci[44]},{},
  229015,{src.ARGAROM,"175",ci[44]},{},
  229014,{src.ARGAROM,"175",ci[44]},{},
  229013,{src.ARGAROM,"140",ci[44]},{},
  229012,{src.ARGAROM,"140",ci[44]},{},
  229011,{src.ARGAROM,"175",ci[44]},{},
  229036,{src.ARGAROM,"105",ci[44]},{},
  229027,{src.ARGAROM,"105",ci[44]},{},
  229019,{src.ARGAROM,"105",ci[44]},{},
  229010,{src.ARGAROM,"105",ci[44]},{},
  224167,{src.HOODED,"500",ci[44]},{},
  224165,{src.HOODED,"500",ci[44]},{},
  224168,{src.HOODED,"500",ci[44]},{},
  233978,{src.HOODED,"500",ci[44]},{},
  233979,{src.HOODED,"500",ci[44]},{},
  233980,{src.HOODED,"500",ci[44]},{},
  233981,{src.HOODED,"500",ci[44]},{},
  235297,{src.HOODED,"350",ci[44]},{},
  233829,{src.HOODED,"200",ci[44]},{},
  235298,{src.HOODED,"350",ci[44]},{},
  233824,{src.HOODED,"200",ci[44]},{},
  235299,{src.HOODED,"350",ci[44]},{},
  233822,{src.HOODED,"200",ci[44]},{},
  220655,{src.SOWEEZI,"1,000",ci[44]},{},
  233845,{src.TALJORI,"350",ci[44]},{},
  233844,{src.TALJORI,"350",ci[44]},{},
  233912,{src.TALJORI,"350",ci[44]},{},
  233903,{src.TALJORI,"350",ci[44]},{},
  233902,{src.TALJORI,"350",ci[44]},{},
  233911,{src.TALJORI,"350",ci[44]},{},
  233892,{src.TALJORI,"200",ci[44]},{},
  234414,{src.TALJORI,"500",ci[44]},{},
  233818,{src.TALJORI,"350",ci[44]},{},
  233819,{src.TALJORI,"350",ci[44]},{},
  233807,{src.TALJORI,"350",ci[44]},{},
  233806,{src.TALJORI,"350",ci[44]},{},
  233857,{src.TALJORI,"350",ci[44]},{},
  233856,{src.TALJORI,"350",ci[44]},{},
  233961,{src.TALJORI,"350",ci[44]},{},
  233805,{src.TALJORI,"350",ci[44]},{},
  233832,{src.TALJORI,"350",ci[44]},{},
  233809,{src.TALJORI,"350",ci[44]},{},
  233810,{src.TALJORI,"350",ci[44]},{},
  233830,{src.TALJORI,"350",ci[44]},{},
  233982,{src.TALJORI,"350",ci[44]},{},
  233963,{src.TALJORI,"350",ci[44]},{},
  233817,{src.TALJORI,"350",ci[44]},{},
  233816,{src.TALJORI,"350",ci[44]},{}
},[19] = {
  233243,{src.PSMOUNTS,"1,500",ci[45]},{t=1},
  233242,{src.PSMOUNTS,"5,000",ci[45]},{t=1},
  233240,{src.PSMOUNTS,"5,000",ci[45]},{t=1},
  226042,{src.PSMOUNTS,"5,000",ci[45]},{t=1},
  233241,{src.PSMOUNTS,"5,000",ci[45]},{t=1},
  170197,{"Plunderstore: Toys","500",ci[45]},{t=3},
  233252,{src.PSPETS,"250",ci[45]},{t=5},
  233251,{src.PSPETS,"500",ci[45]},{t=5},
  233248,{src.PSPETS,"1,000",ci[45]},{t=5},
  233247,{src.PSPETS,"2,000",ci[45]},{t=5},
  235989,{src.PSPETS,"2,000",ci[45]},{t=5},
  216775,{src.PSWEAPONS,"250",ci[45]},{},
  216777,{src.PSWEAPONS,"250",ci[45]},{},
  216778,{src.PSWEAPONS,"250",ci[45]},{},
  216776,{src.PSWEAPONS,"250",ci[45]},{},
  232595,{src.PSWEAPONS,"1,000",ci[45]},{},
  232596,{src.PSWEAPONS,"1,000",ci[45]},{},
  216765,{src.PSWEAPONS,"1,000",ci[45]},{},
  216756,{src.PSWEAPONS,"1,000",ci[45]},{},
  216763,{src.PSWEAPONS,"1,000",ci[45]},{},
  216755,{src.PSWEAPONS,"1,000",ci[45]},{},
  232579,{src.PSWEAPONS,"1,500",ci[45]},{},
  232580,{src.PSWEAPONS,"1,500",ci[45]},{},
  232581,{src.PSWEAPONS,"1,500",ci[45]},{},
  232582,{src.PSWEAPONS,"1,500",ci[45]},{},
  216779,{src.PSGUNS,"250",ci[45]},{},
  216780,{src.PSGUNS,"500",ci[45]},{},
  216774,{src.PSGUNS,"1,000",ci[45]},{},
  232583,{src.PSGUNS,"1,500",ci[45]},{},
  216988,{src.PSSWABBIE,"250",ci[45]},{},
  216989,{src.PSSWABBIE,"250",ci[45]},{},
  216987,{src.PSSWABBIE,"250",ci[45]},{},
  216991,{src.PSSWABBIE,"250",ci[45]},{},
  213436,{src.PSSNAZZY,"250",ci[45]},{},
  216990,{src.PSSNAZZY,"250",ci[45]},{},
  216986,{src.PSSNAZZY,"250",ci[45]},{},
  216992,{src.PSSNAZZY,"250",ci[45]},{},
  216734,{src.PSSTRAPPING,"250",ci[45]},{},
  216727,{src.PSSTRAPPING,"250",ci[45]},{},
  216735,{src.PSSTRAPPING,"250",ci[45]},{},
  216729,{src.PSSTRAPPING,"250",ci[45]},{},
  216730,{src.PSSTRAPPING,"250",ci[45]},{},
  216732,{src.PSSTRAPPING,"250",ci[45]},{},
  216731,{src.PSSTRAPPING,"250",ci[45]},{},
  216733,{src.PSSTRAPPING,"250",ci[45]},{},
  232430,{src.PSSTORMRIDDEN,"1,000",ci[45]},{},
  232587,{src.PSSTORMRIDDEN,"1,000",ci[45]},{},
  232589,{src.PSSTORMRIDDEN,"1,000",ci[45]},{},
  232592,{src.PSSTORMRIDDEN,"500",ci[45]},{},
  232584,{src.PSSTORMRIDDEN,"250",ci[45]},{},
  232591,{src.PSSTORMRIDDEN,"250",ci[45]},{},
  232590,{src.PSSTORMRIDDEN,"250",ci[45]},{},
  232593,{src.PSSTORMRIDDEN,"250",ci[45]},{},
  216994,{src.PSHEAD,"250",ci[45]},{},
  216993,{src.PSHEAD,"250",ci[45]},{},
  232431,{src.PSHEAD,"1,000",ci[45]},{},
  232594,{src.PSHEAD,"1,000",ci[45]},{},
  232585,{src.PSHEAD,"2,000",ci[45]},{},
  232586,{src.PSHEAD,"2,000",ci[45]},{},
  219348,{src.PSHEAD,"500",ci[45]},{},
  219349,{"Plunderstore: Tabard","5,000",ci[45]},{},
  216985,{src.PSBACK,"250",ci[45]},{},
  216984,{src.PSBACK,"250",ci[45]},{},
  216728,{src.PSBACK,"500",ci[45]},{},
  232588,{src.PSBACK,"1,000",ci[45]},{}
},[20] = {
  235388,{src.ROCCO,"1,350",ci[41]},{t=7,que=86773},
  235389,{src.LAB,"1,350",ci[41]},{t=7,que=86772},
  235390,{src.BOATSWAIN,"1,350",ci[41]},{t=7,que=86771},
  235391,{src.SHREDZ,"1,350",ci[41]},{t=7,que=86774},
  232981,{"Smaks Topskimmer","2,600",ci[41]},{t=7,que=85776},
  232982,"Achievement: Undermine Breaknecking: Bronze",{t=7,que=85775},
  232985,"Engineering",{t=7,que=85782},
  232986,{"Angelo Rustbin","1",ci[46]},{t=7,que=85781},
  232983,"Combine Steamboil items",{t=7,que=85783},
  232984,"Combine Handcrank items",{t=7,que=85784},
  236672,{src.ROCCO,"975",ci[41]},{t=7,que=85785},
  236670,{src.LAB,"975",ci[41]},{t=7,que=85787},
  236671,{src.BOATSWAIN,"975",ci[41]},{t=7,que=85786},
  236669,{src.SHREDZ,"975",ci[41]},{t=7,que=85788}
},[21] = {
  168058,{src.WARP,"60",ci[47]},{t=2},
  168059,{src.WARP,"60",ci[47]},{t=2},
  168060,{src.WARP,"60",ci[47]},{t=2},
  168061,{src.WARP,"60",ci[47]},{t=2},
  157573,{src.WARP,"60",ci[47]},{t=2},
  157574,{src.WARP,"60",ci[47]},{t=2},
  157576,{src.WARP,"60",ci[47]},{t=2},
  157577,{src.WARP,"60",ci[47]},{t=2},
  151117,{src.WARP,"60",ci[47]},{t=2},
  151118,{src.WARP,"60",ci[47]},{t=2},
  151119,{src.WARP,"60",ci[47]},{t=2},
  151120,{src.WARP,"60",ci[47]},{t=2},
  151116,{src.WARP,"1",ci[47]},{},
  188236,{src.WARP,"7",ci[47]},{},
  188237,{src.WARP,"7",ci[47]},{},
  188243,{src.WARP,"10",ci[47]},{},
  188244,{src.WARP,"10",ci[47]},{},
  188248,{src.WARP,"15",ci[47]},{},
  188249,{src.WARP,"15",ci[47]},{},
  189870,{src.WARP,"15",ci[47]},{},
  190064,{src.WARP,"15",ci[47]},{},
  190167,{src.WARP,"15",ci[47]},{},
  190202,{src.WARP,"15",ci[47]},{},
  190429,{src.WARP,"15",ci[47]},{},
  190544,{src.WARP,"15",ci[47]},{},
  190673,{src.WARP,"15",ci[47]},{},
  190686,{src.WARP,"50",ci[47]},{},
  190697,{src.WARP,"15",ci[47]},{},
  190803,{src.WARP,"15",ci[47]},{},
  190830,{src.WARP,"15",ci[47]},{},
  190858,{src.WARP,"15",ci[47]},{},
  190888,{src.WARP,"15",ci[47]},{},
  202295,{src.WARP,"50",ci[47]},{},
  202296,{src.WARP,"50",ci[47]},{},
  202297,{src.WARP,"50",ci[47]},{},
  202298,{src.WARP,"25",ci[47]},{},
  202300,{src.WARP,"50",ci[47]},{},
  202301,{src.WARP,"50",ci[47]},{},
  202303,{src.WARP,"25",ci[47]},{},
  202304,{src.WARP,"25",ci[47]},{},
  202305,{src.WARP,"25",ci[47]},{},
  202306,{src.WARP,"25",ci[47]},{},
  202307,{src.WARP,"25",ci[47]},{},
  202308,{src.WARP,"25",ci[47]},{},
  213431,{src.WARP,"25",ci[47]},{},
  213432,{src.WARP,"25",ci[47]},{},
  213433,{src.WARP,"25",ci[47]},{},
  213434,{src.WARP,"25",ci[47]},{},
  213435,{src.WARP,"25",ci[47]},{},
  213437,{src.WARP,"25",ci[47]},{},
  213430,{src.WARP,"25",ci[47]},{},
  213441,{src.WARP,"25",ci[47]},{},
  213518,{src.WARP,"25",ci[47]},{},
  212626,{src.WARP,"25",ci[47]},{},
  210850,{src.WARP,"25",ci[47]},{},
  230166,{src.WARP,"60",ci[47]},{t=2},
  230035,{src.WARP,"25",ci[47]},{},
  235021,{src.WARP,"25",ci[47]},{},
  233137,{src.WARP,"50",ci[47]},{},
  233098,{src.WARP,"25",ci[47]},{},
  233120,{src.WARP,"50",ci[47]},{},
  233081,{src.WARP,"25",ci[47]},{},
  233171,{src.WARP,"15",ci[47]},{},
  237240,{src.WARP,"15",ci[47]},{},
  233154,{src.WARP,"25",ci[47]},{},
  237243,{src.WARP,"15",ci[47]},{},
  237254,{src.WARP,"15",ci[47]},{},
  237250,{src.WARP,"15",ci[47]},{},
  237251,{src.WARP,"15",ci[47]},{},
  237247,{src.WARP,"15",ci[47]},{},
  237253,{src.WARP,"15",ci[47]},{},
  237256,{src.WARP,"15",ci[47]},{},
  237252,{src.WARP,"15",ci[47]},{},
  237248,{src.WARP,"15",ci[47]},{},
  237257,{src.WARP,"15",ci[47]},{},
  237249,{src.WARP,"15",ci[47]},{},
  237255,{src.WARP,"15",ci[47]},{},
  237245,{src.WARP,"15",ci[47]},{},
  237246,{src.WARP,"15",ci[47]},{},
  237242,{src.WARP,"15",ci[47]},{},
  237241,{src.WARP,"15",ci[47]},{},
  237244,{src.WARP,"15",ci[47]},{}
},[23] = {
  242368,{src.PYTHAGORUS,"30,000",ci[1],"20",ci[48]},{},
  151524,{src.PYTHAGORUS,"30,000",ci[1],"20",ci[49]},{},
  255006,{src.PYTHAGORUS,"30,000",ci[1],"20",ci[50]},{t=2},
  253273,{src.PYTHAGORUS,"30,000",ci[1],"20",ci[51]},{t=2}
},[24] = {
  252954,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253013,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253024,{src.JAKKUS,"20,000",ci[1]},{t=7,que=92638},
  253025,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253026,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253027,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253028,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253029,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253030,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253031,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253032,{src.JAKKUS,"20,000",ci[1]},{t=1},
  253033,{src.JAKKUS,"20,000",ci[1]},{t=1}
},[25] = {
  250428,{src.HEMET,"10,000",ci[1]},{t=1},
  250427,{src.HEMET,"10,000",ci[1]},{t=1},
  250429,{src.HEMET,"10,000",ci[1]},{t=1},
  250723,{src.HEMET,"10,000",ci[1]},{t=1},
  250721,{src.HEMET,"10,000",ci[1]},{t=1},
  239687,{src.HEMET,"10,000",ci[1]},{t=1},
  239667,{src.HEMET,"10,000",ci[1]},{t=1},
  239665,{src.HEMET,"10,000",ci[1]},{t=1},
  250757,{src.HEMET,"10,000",ci[1]},{t=1},
  250756,{src.HEMET,"10,000",ci[1]},{t=1},
  250752,{src.HEMET,"10,000",ci[1]},{t=1},
  250751,{src.HEMET,"10,000",ci[1]},{t=1},
  251795,{src.HEMET,"10,000",ci[1]},{t=1},
  251796,{src.HEMET,"10,000",ci[1]},{t=1},
  250424,{src.HEMET,"10,000",ci[1]},{t=1},
  250425,{src.HEMET,"10,000",ci[1]},{t=1},
  250423,{src.HEMET,"10,000",ci[1]},{t=1},
  250426,{src.HEMET,"10,000",ci[1]},{t=1},
  138258,{src.HEMET,"20,000",ci[1]},{t=1},
  131734,{src.HEMET,"40,000",ci[1]},{t=1},
  138201,{src.HEMET,"20,000",ci[1]},{t=1},
  141713,{src.HEMET,"100,000",ci[1]},{t=1},
  250728,{src.HEMET,"10,000",ci[1]},{t=1},
  250761,{src.HEMET,"10,000",ci[1]},{t=1},
  250760,{src.HEMET,"10,000",ci[1]},{t=1},
  250759,{src.HEMET,"10,000",ci[1]},{t=1},
  250758,{src.HEMET,"10,000",ci[1]},{t=1},
  142236,{src.HEMET,"100,000",ci[1]},{t=1},
  137574,{src.HEMET,"100,000",ci[1]},{t=1},
  137575,{src.HEMET,"100,000",ci[1]},{t=1},
  147806,{src.HEMET,"20,000",ci[1]},{t=1},
  147807,{src.HEMET,"20,000",ci[1]},{t=1},
  143764,{src.HEMET,"20,000",ci[1]},{t=1},
  147805,{src.HEMET,"20,000",ci[1]},{t=1},
  147804,{src.HEMET,"20,000",ci[1]},{t=1},
  143643,{src.HEMET,"100,000",ci[1]},{t=1},
  250192,{src.HEMET,"10,000",ci[1]},{t=1},
  250748,{src.HEMET,"10,000",ci[1]},{t=1},
  250747,{src.HEMET,"10,000",ci[1]},{t=1},
  250746,{src.HEMET,"10,000",ci[1]},{t=1},
  250745,{src.HEMET,"10,000",ci[1]},{t=1},
  250803,{src.HEMET,"10,000",ci[1]},{t=1},
  250806,{src.HEMET,"10,000",ci[1]},{t=1},
  250805,{src.HEMET,"10,000",ci[1]},{t=1},
  250804,{src.HEMET,"10,000",ci[1]},{t=1},
  250802,{src.HEMET,"10,000",ci[1]},{t=1},
  152816,{src.HEMET,"100,000",ci[1]},{t=1},
  152903,{src.HEMET,"40,000",ci[1]},{t=1},
  152904,{src.HEMET,"40,000",ci[1]},{t=1},
  152905,{src.HEMET,"40,000",ci[1]},{t=1},
  153043,{src.HEMET,"20,000",ci[1]},{t=1},
  153044,{src.HEMET,"20,000",ci[1]},{t=1},
  153042,{src.HEMET,"20,000",ci[1]},{t=1},
  152790,{src.HEMET,"40,000",ci[1]},{t=1},
  152843,{src.HEMET,"40,000",ci[1]},{t=1},
  152844,{src.HEMET,"40,000",ci[1]},{t=1},
  152841,{src.HEMET,"40,000",ci[1]},{t=1},
  152840,{src.HEMET,"40,000",ci[1]},{t=1},
  152842,{src.HEMET,"40,000",ci[1]},{t=1},
  152814,{src.HEMET,"40,000",ci[1]},{t=1},
  152789,{src.HEMET,"100,000",ci[1]},{t=1}
},[26] = {
  239705,{src.HOROS,"5,000",ci[1]},{t=5},
  239699,{src.HOROS,"5,000",ci[1]},{t=5},
  129108,{src.HOROS,"5,000",ci[1]},{t=5},
  140261,{src.HOROS,"10,000",ci[1]},{t=5},
  140320,{src.HOROS,"10,000",ci[1]},{t=5},
  136901,{src.HOROS,"100,000",ci[1]},{t=5},
  140316,{src.HOROS,"10,000",ci[1]},{t=5},
  136900,{src.HOROS,"35,000",ci[1]},{t=5},
  136903,{src.HOROS,"80,000",ci[1]},{t=5},
  136922,{src.HOROS,"10,000",ci[1]},{t=5},
  130167,{src.HOROS,"100,000",ci[1]},{t=5},
  153252,{src.HOROS,"35,000",ci[1]},{t=5},
  131724,{src.HOROS,"10,000",ci[1]},{t=3},
  131717,{src.HOROS,"10,000",ci[1]},{t=3},
  129165,{src.HOROS,"10,000",ci[1]},{t=3},
  130169,{src.HOROS,"10,000",ci[1]},{t=3},
  140363,{src.HOROS,"20,000",ci[1]},{t=3},
  141862,{src.HOROS,"25,000",ci[1]},{t=3},
  140160,{src.HOROS,"80,000",ci[1]},{t=3},
  144394,{src.HOROS,"35,000",ci[1]},{t=5},
  142265,{src.HOROS,"35,000",ci[1]},{t=3},
  142530,{src.HOROS,"10,000",ci[1]},{t=3},
  142529,{src.HOROS,"10,000",ci[1]},{t=3},
  142528,{src.HOROS,"10,000",ci[1]},{t=3},
  143662,{src.HOROS,"10,000",ci[1]},{t=3},
  119211,{src.HOROS,"100,000",ci[1]},{t=3},
  146953,{src.HOROS,"80,000",ci[1]},{t=5},
  147841,{src.HOROS,"35,000",ci[1]},{t=5},
  151828,{src.HOROS,"80,000",ci[1]},{t=5},
  151829,{src.HOROS,"80,000",ci[1]},{t=5},
  147843,{src.HOROS,"35,000",ci[1]},{t=3},
  147867,{src.HOROS,"35,000",ci[1]},{t=3},
  153195,{src.HOROS,"35,000",ci[1]},{t=5},
  153055,{src.HOROS,"35,000",ci[1]},{t=5},
  153054,{src.HOROS,"35,000",ci[1]},{t=5},
  153026,{src.HOROS,"35,000",ci[1]},{t=5},
  153056,{src.HOROS,"35,000",ci[1]},{t=5},
  153204,{src.HOROS,"35,000",ci[1]},{t=3},
  153193,{src.HOROS,"35,000",ci[1]},{t=3},
  153183,{src.HOROS,"35,000",ci[1]},{t=3},
  153124,{src.HOROS,"35,000",ci[1]},{t=3},
  153293,{src.HOROS,"35,000",ci[1]},{t=3},
  153179,{src.HOROS,"35,000",ci[1]},{t=3},
  153181,{src.HOROS,"35,000",ci[1]},{t=3},
  153180,{src.HOROS,"35,000",ci[1]},{t=3},
  153253,{src.HOROS,"35,000",ci[1]},{t=3},
  153182,{src.HOROS,"35,000",ci[1]},{t=3},
  153126,{src.HOROS,"35,000",ci[1]},{t=3},
  152982,{src.HOROS,"35,000",ci[1]},{t=3},
  153004,{src.HOROS,"35,000",ci[1]},{t=3},
  153194,{src.HOROS,"35,000",ci[1]},{t=3}
},[27] = {
  253382,{src.UNICUS,"7,500",ci[1]},{t=2},
  255156,{src.UNICUS,"7,500",ci[1]},{t=2},
  253379,{src.UNICUS,"7,500",ci[1]},{t=2},
  241416,{src.UNICUS,"7,500",ci[1]},{t=2},
  241415,{src.UNICUS,"7,500",ci[1]},{t=2},
  241414,{src.UNICUS,"7,500",ci[1]},{t=2},
  241413,{src.UNICUS,"7,500",ci[1]},{t=2},
  241412,{src.UNICUS,"7,500",ci[1]},{t=2},
  241411,{src.UNICUS,"7,500",ci[1]},{t=2},
  241410,{src.UNICUS,"7,500",ci[1]},{t=2},
  241409,{src.UNICUS,"7,500",ci[1]},{t=2},
  241408,{src.UNICUS,"7,500",ci[1]},{t=2},
  241407,{src.UNICUS,"7,500",ci[1]},{t=2},
  241406,{src.UNICUS,"7,500",ci[1]},{t=2},
  241403,{src.UNICUS,"7,500",ci[1]},{t=2},
  241402,{src.UNICUS,"7,500",ci[1]},{t=2},
  241400,{src.UNICUS,"7,500",ci[1]},{t=2},
  241399,{src.UNICUS,"7,500",ci[1]},{t=2},
  241397,{src.UNICUS,"7,500",ci[1]},{t=2},
  241396,{src.UNICUS,"7,500",ci[1]},{t=2},
  241395,{src.UNICUS,"7,500",ci[1]},{t=2},
  241358,{src.UNICUS,"7,500",ci[1]},{t=2},
  190772,{src.UNICUS,"7,500",ci[1]},{t=2},
  241356,{src.UNICUS,"7,500",ci[1]},{t=2},
  241355,{src.UNICUS,"7,500",ci[1]},{t=2},
  251271,{src.UNICUS,"7,500",ci[1]},{t=2},
  253385,{src.UNICUS,"2,500",ci[1]},{t=2},
  253358,{src.UNICUS,"2,500",ci[1]},{t=2},
  253551,{src.UNICUS,"2,500",ci[1]},{t=2},
  253556,{src.UNICUS,"2,500",ci[1]},{t=2},
  253561,{src.UNICUS,"2,500",ci[1]},{t=2},
  253565,{src.UNICUS,"2,500",ci[1]},{t=2},
  253569,{src.UNICUS,"2,500",ci[1]},{t=2},
  241360,{src.UNICUS,"7,500",ci[1]},{t=2},
  241392,{src.UNICUS,"7,500",ci[1]},{t=2},
  241390,{src.UNICUS,"7,500",ci[1]},{t=2},
  241389,{src.UNICUS,"7,500",ci[1]},{t=2},
  241388,{src.UNICUS,"7,500",ci[1]},{t=2},
  241387,{src.UNICUS,"7,500",ci[1]},{t=2},
  241386,{src.UNICUS,"7,500",ci[1]},{t=2},
  241385,{src.UNICUS,"7,500",ci[1]},{t=2}
},[28] = {
  139170,{src.LARAH,"15,000",ci[1]},{t=2},
  139169,{src.LARAH,"15,000",ci[1]},{t=2},
  139168,{src.LARAH,"15,000",ci[1]},{t=2},
  139167,{src.LARAH,"15,000",ci[1]},{t=2},
  241440,{src.LARAH,"15,000",ci[1]},{t=2},
  241438,{src.LARAH,"15,000",ci[1]},{t=2},
  241437,{src.LARAH,"15,000",ci[1]},{t=2},
  241435,{src.LARAH,"15,000",ci[1]},{t=2},
  241433,{src.LARAH,"15,000",ci[1]},{t=2},
  241432,{src.LARAH,"15,000",ci[1]},{t=2},
  241430,{src.LARAH,"15,000",ci[1]},{t=2},
  241429,{src.LARAH,"15,000",ci[1]},{t=2},
  241384,{src.LARAH,"15,000",ci[1]},{t=2},
  241383,{src.LARAH,"15,000",ci[1]},{t=2},
  241382,{src.LARAH,"15,000",ci[1]},{t=2},
  241381,{src.LARAH,"15,000",ci[1]},{t=2},
  241380,{src.LARAH,"15,000",ci[1]},{t=2},
  241379,{src.LARAH,"15,000",ci[1]},{t=2},
  241378,{src.LARAH,"15,000",ci[1]},{t=2},
  241377,{src.LARAH,"15,000",ci[1]},{t=2},
  241376,{src.LARAH,"15,000",ci[1]},{t=2},
  241375,{src.LARAH,"15,000",ci[1]},{t=2},
  241374,{src.LARAH,"15,000",ci[1]},{t=2},
  241373,{src.LARAH,"15,000",ci[1]},{t=2},
  241372,{src.LARAH,"15,000",ci[1]},{t=2},
  241371,{src.LARAH,"15,000",ci[1]},{t=2},
  241370,{src.LARAH,"15,000",ci[1]},{t=2},
  241369,{src.LARAH,"15,000",ci[1]},{t=2},
  241364,{src.LARAH,"15,000",ci[1]},{t=2},
  241363,{src.LARAH,"15,000",ci[1]},{t=2},
  241362,{src.LARAH,"15,000",ci[1]},{t=2},
  241361,{src.LARAH,"15,000",ci[1]},{t=2},
  241444,{src.LARAH,"15,000",ci[1]},{t=2},
  241443,{src.LARAH,"15,000",ci[1]},{t=2},
  241442,{src.LARAH,"15,000",ci[1]},{t=2},
  241441,{src.LARAH,"15,000",ci[1]},{t=2},
  241359,{src.LARAH,"15,000",ci[1]},{t=2},
  241368,{src.LARAH,"15,000",ci[1]},{t=2},
  241367,{src.LARAH,"15,000",ci[1]},{t=2},
  241366,{src.LARAH,"15,000",ci[1]},{t=2},
  241365,{src.LARAH,"15,000",ci[1]},{t=2},
  241391,{src.LARAH,"15,000",ci[1]},{t=2},
  253594,{src.LARAH,"15,000",ci[1]},{t=2},
  253588,{src.LARAH,"15,000",ci[1]},{t=2},
  254753,{src.LARAH,"15,000",ci[1]},{t=2},
  254754,{src.LARAH,"15,000",ci[1]},{t=2},
  254752,{src.LARAH,"15,000",ci[1]},{t=2}
},[29] = {
  241439,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241436,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241434,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241431,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241428,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241427,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241425,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241424,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241422,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241421,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241419,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241418,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241417,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241426,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241423,{src.ARTUROS,"15,000",ci[1]},{t=2},
  241420,{src.ARTUROS,"15,000",ci[1]},{t=2}
},[30] = {
  241587,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241583,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241579,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241575,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241571,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241568,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241563,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241559,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241556,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241551,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241548,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241544,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241597,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241601,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241604,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241607,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241539,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241535,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241531,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241527,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241523,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241518,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241515,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241510,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241507,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241503,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241499,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241494,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241490,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241486,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241482,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241480,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241476,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241472,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241466,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241463,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241458,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241456,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241452,{src.ARTUROS,"20,000",ci[1]},{t=2},
  241447,{src.ARTUROS,"20,000",ci[1]},{t=2}
},[31] = {
  241588,{src.DURUS,"20,000",ci[1]},{t=2},
  241584,{src.DURUS,"20,000",ci[1]},{t=2},
  241580,{src.DURUS,"20,000",ci[1]},{t=2},
  241577,{src.DURUS,"20,000",ci[1]},{t=2},
  241572,{src.DURUS,"20,000",ci[1]},{t=2},
  241567,{src.DURUS,"20,000",ci[1]},{t=2},
  241564,{src.DURUS,"20,000",ci[1]},{t=2},
  241561,{src.DURUS,"20,000",ci[1]},{t=2},
  241554,{src.DURUS,"20,000",ci[1]},{t=2},
  241550,{src.DURUS,"20,000",ci[1]},{t=2},
  241546,{src.DURUS,"20,000",ci[1]},{t=2},
  241542,{src.DURUS,"20,000",ci[1]},{t=2},
  241538,{src.DURUS,"20,000",ci[1]},{t=2},
  241536,{src.DURUS,"20,000",ci[1]},{t=2},
  241530,{src.DURUS,"20,000",ci[1]},{t=2},
  241528,{src.DURUS,"20,000",ci[1]},{t=2},
  241522,{src.DURUS,"20,000",ci[1]},{t=2},
  241520,{src.DURUS,"20,000",ci[1]},{t=2},
  241514,{src.DURUS,"20,000",ci[1]},{t=2},
  241511,{src.DURUS,"20,000",ci[1]},{t=2},
  241508,{src.DURUS,"20,000",ci[1]},{t=2},
  241504,{src.DURUS,"20,000",ci[1]},{t=2},
  241498,{src.DURUS,"20,000",ci[1]},{t=2},
  241496,{src.DURUS,"20,000",ci[1]},{t=2},
  241492,{src.DURUS,"20,000",ci[1]},{t=2},
  241488,{src.DURUS,"20,000",ci[1]},{t=2},
  241483,{src.DURUS,"20,000",ci[1]},{t=2},
  241478,{src.DURUS,"20,000",ci[1]},{t=2},
  241474,{src.DURUS,"20,000",ci[1]},{t=2},
  241471,{src.DURUS,"20,000",ci[1]},{t=2},
  241467,{src.DURUS,"20,000",ci[1]},{t=2},
  241462,{src.DURUS,"20,000",ci[1]},{t=2},
  241460,{src.DURUS,"20,000",ci[1]},{t=2},
  241455,{src.DURUS,"20,000",ci[1]},{t=2},
  241450,{src.DURUS,"20,000",ci[1]},{t=2},
  241448,{src.DURUS,"20,000",ci[1]},{t=2}
},[32] = {
  241589,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241585,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241581,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241576,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241573,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241569,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241565,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241560,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241557,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241555,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241552,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241547,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241543,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241540,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241534,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241532,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241526,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241524,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241519,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241516,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241512,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241506,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241502,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241500,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241495,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241491,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241487,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241484,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241479,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241475,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241470,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241468,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241464,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241457,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241454,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241451,{src.SACERDORMU,"20,000",ci[1]},{t=2},
  241446,{src.SACERDORMU,"20,000",ci[1]},{t=2}
},[33] = {
  241586,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241582,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241578,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241574,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241570,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241566,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241562,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241558,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241553,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241549,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241545,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241541,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241537,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241533,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241529,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241525,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241521,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241517,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241513,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241509,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241505,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241501,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241497,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241493,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241489,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241485,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241481,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241477,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241473,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241469,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241465,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241461,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241459,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241453,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241449,{src.PYTHAGORUS,"30,000",ci[1]},{t=2},
  241445,{src.PYTHAGORUS,"30,000",ci[1]},{t=2}
},[34] = {
  241405,{src.AGOS,"15,000",ci[1]},{t=2},
  241404,{src.AGOS,"15,000",ci[1]},{t=2},
  241401,{src.AGOS,"15,000",ci[1]},{t=2},
  241398,{src.AGOS,"15,000",ci[1]},{t=2},
  241394,{src.AGOS,"15,000",ci[1]},{t=2},
  241393,{src.AGOS,"15,000",ci[1]},{t=2},
  241354,{src.AGOS,"15,000",ci[1]},{t=2}
},[35] = {
  235630,{src.FREDDIE,"4,000",ci[1]},{t=2},
  241591,{src.FREDDIE,"6,000",ci[1]},{t=2},
  241590,{src.FREDDIE,"4,000",ci[1]},{t=2},
  242240,{src.FREDDIE,"4,000",ci[1]},{t=2},
  242234,{src.FREDDIE,"6,000",ci[1]},{t=2},
  242233,{src.FREDDIE,"6,000",ci[1]},{t=2},
  242232,{src.FREDDIE,"8,000",ci[1]},{t=2},
  242231,{src.FREDDIE,"2,000",ci[1]},{t=2},
  242230,{src.FREDDIE,"8,000",ci[1]},{t=2},
  242229,{src.FREDDIE,"2,000",ci[1]},{t=2},
  242228,{src.FREDDIE,"8,000",ci[1]},{t=2},
  241593,{src.FREDDIE,"4,000",ci[1]},{t=2},
  241592,{src.FREDDIE,"8,000",ci[1]},{t=2},
  242235,{src.FREDDIE,"6,000",ci[1]},{t=2},
  242239,{src.FREDDIE,"6,000",ci[1]},{t=2},
  242238,{src.FREDDIE,"8,000",ci[1]},{t=2},
  242237,{src.FREDDIE,"6,000",ci[1]},{t=2},
  242236,{src.FREDDIE,"6,000",ci[1]},{t=2}
}}

local canLearn = {
  {[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1,[9]=1,[11]=1,[12]=1,[13]=1,[14]=1,[16]=1,[20]=1,[21]=1,[22]=1}, --WARRIOR
  {[1]=1,[2]=1,[5]=1,[6]=1,[7]=1,[8]=1,[9]=1,[16]=1,[20]=1,[21]=1,[22]=1}, --PALADIN
  {[1]=1,[2]=1,[3]=1,[4]=1,[7]=1,[8]=1,[9]=1,[11]=1,[12]=1,[13]=1,[14]=1,[16]=1,[19]=1,[21]=1}, --HUNTER
  {[1]=1,[3]=1,[4]=1,[5]=1,[8]=1,[12]=1,[13]=1,[14]=1,[16]=1,[18]=1,[21]=1}, --ROGUE
  {[5]=1,[11]=1,[13]=1,[15]=1,[16]=1,[17]=1,[21]=1}, --PRIEST
  {[1]=1,[2]=1,[5]=1,[6]=1,[7]=1,[8]=1,[9]=1,[16]=1,[20]=1,[21]=1}, --DEATHKNIGHT
  {[1]=1,[2]=1,[5]=1,[6]=1,[11]=1,[13]=1,[16]=1,[19]=1,[21]=1,[22]=1}, --SHAMAN
  {[8]=1,[11]=1,[13]=1,[15]=1,[16]=1,[17]=1,[21]=1}, --MAGE
  {[8]=1,[11]=1,[13]=1,[15]=1,[16]=1,[17]=1,[21]=1}, --WARLOCK
  {[1]=1,[5]=1,[7]=1,[8]=1,[11]=1,[12]=1,[16]=1,[18]=1,[21]=1}, --MONK
  {[5]=1,[6]=1,[7]=1,[11]=1,[12]=1,[13]=1,[16]=1,[18]=1,[21]=1}, --DRUID
  {[1]=1,[8]=1,[10]=1,[12]=1,[16]=1,[18]=1,[21]=1}, --DEMONHUNTER
  {[1]=1,[2]=1,[5]=1,[6]=1,[8]=1,[9]=1,[11]=1,[12]=1,[13]=1,[16]=1,[19]=1,[21]=1}, --EVOKER
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1} --WARBAND
}

dbTT = {minimap = {hide = false}}
local buttonTT
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("TroveTally",{
  icon = "Interface\\AddOns\\TroveTally\\Assets\\icon",
  OnClick = function(self,button) if button == "LeftButton" then SlashCmdList["TROVE"]() end end,
  OnTooltipShow = function(tooltip)
    tooltip:AddLine("|cffffffff混搭收藏單")
    tooltip:AddLine("|cff1eff00<點一下左鍵打開>")
    tooltip:SetScale(GameTooltip:GetScale())
  end
})

local _uid = 0
local function uid()
  _uid = _uid + 1
  return _uid
end
local dataI = 1
local mI = 2
local orig = {mop = 1,ens = 5,inf = 6,mou = 7,toy = 8,oth = 9,dto = 10,rad = 11,rew = 12,rec = 13,leg = 14,osi = 15,del = 16,ann = 17,lemix = 22}
local memory = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
local playerClass = {}
playerClass.name,_,playerClass.index = UnitClass("player")
local playerSpecs = {}
local myGUID = nil
local lists = {
  [1] = " |cffFFC000| |r混搭再造：潘達利亞之謎",
  [2] = "",
  [4] = " |cffFFC000| |r設定",
  [5] = " |cffFFC000| |r軍火庫與塑形套裝",
  [6] = " |cffFFC000| |r無盡市集",
  [7] = " |cffFFC000| |r坐騎",
  [8] = " |cffFFC000| |r玩具",
  [9] = " |cffFFC000| |r其他",
  [10] = " |cffFFC000| |r巨龍崛起玩具",
  [11] = " |cffFFC000| |r璀璨回音",
  [12] = " |cffFFC000| |r獎勵",
  [13] = " |cffFFC000| |r新兵裝備",
  [14] = " |cffFFC000| |r舊版本",
  [15] = " |cffFFC000| |r黑曜石塑形套裝",
  [16] = " |cffFFC000| |r探究者飛艇",
  [17] = " |cffFFC000| |r塑形套裝",
  [18] = " |cffFFC000| |r海妖之嶼",
  [19] = " |cffFFC000| |r強襲風暴",
  [20] = " |cffFFC000| |rD.R.I.V.E.",
  [21] = " |cffFFC000| |r時尚大考驗",
  [22] = " |cffFFC000| |r混搭再造：軍臨天下",
  [23] = " |cffFFC000| |r超稀有外觀",
  [24] = " |cffFFC000| |r職業坐騎",
  [25] = " |cffFFC000| |r混搭再造坐騎",
  [26] = " |cffFFC000| |r混搭再造寵物與玩具",
  [27] = " |cffFFC000| |r獨家套裝",
  [28] = " |cffFFC000| |r開放世界套裝",
  [29] = " |cffFFC000| |r地城套裝",
  [30] = " |cffFFC000| |r團隊搜尋器套裝",
  [31] = " |cffFFC000| |r普通團隊套裝",
  [32] = " |cffFFC000| |r英雄團隊套裝",
  [33] = " |cffFFC000| |r傳奇團隊套裝",
  [34] = " |cffFFC000| |r失物招領服飾",
  [35] = " |cffFFC000| |r折扣披風套裝"
}

local region = GetCurrentRegion()
local regionTime = {
  1722279640, --US
  1722470440, --KR
  1722290440, --EU
  1722488440, --TW
  1722488440 --CN
}

local function getTime()
  local time = date("*t",GetServerTime() - regionTime[region])
  local sec = time.hour * 3600 + time.min * 60 + time.sec
  local secLeft = math.ceil(sec / 3600) * 3600 - sec
  local hourNum = math.floor(secLeft / 3600)
  secLeft = secLeft % 3600
  local minNum = math.floor(secLeft / 60)
  local secNum = secLeft % 60
  return (hourNum > 0 and hourNum..":" or "")..string.format("%02d:%02d",minNum,secNum)
end

local state = {[false] = "已停用",[true] = "已啟用",[1] = "戰隊",[2] = playerClass.name}

local bigFrame = CreateFrame("Frame",nil,UIParent)
bigFrame:SetSize(516+24,336+34+26)
bigFrame:SetPoint("CENTER",0,0)
bigFrame:SetFrameStrata("DIALOG")
bigFrame:SetMovable(true)
bigFrame:SetScript("OnMouseDown",bigFrame.StartMoving)
bigFrame:SetScript("OnMouseUp",bigFrame.StopMovingOrSizing)
bigFrame:Hide()

local exFrame = CreateFrame("Frame",nil,bigFrame,"BackdropTemplate")
exFrame:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8"
})
exFrame:SetBackdropColor(0,0,0)
exFrame:SetClipsChildren(true)
exFrame:Hide()
exFrame:SetScript("OnHide",function(self) self:SetScript("OnUpdate",nil) end) --IF

local exIcons = {}
local function createExIcon(i)
  local exIcon = CreateFrame("Frame",nil,exFrame)
  exIcon:SetSize(20,20)
  exIcon:SetPoint("TOPLEFT",2,-2 - (i - 1) * 24)
  local exBg = exIcon:CreateTexture(nil,"ARTWORK")
  exBg:SetTexCoord(0.0625,0.9375,0.0625,0.9375)
  exBg:SetSize(17,17)
  exBg:SetPoint("CENTER")
  local exBorder = exIcon:CreateTexture(nil,"OVERLAY")
  exBorder:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\ex")
  exBorder:SetTexCoord(0,0.625,0,0.625)
  exBorder:SetAllPoints()
  local exText = exIcon:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  exText:SetTextColor(1,0.7529,0)
  exText:SetHeight(24)
  exText:SetPoint("LEFT",exIcon,"RIGHT",6,0)

  table.insert(exIcons,{icon = exIcon,bg = exBg,text = exText})
end
for i = 1,3 do createExIcon(i) end

local function resizeEx(userFrame)
  local width = 0
  local height = 0
  for _,exIcon in ipairs(exIcons) do
    if not exIcon.icon:IsShown() then break end
    local textWidth = exIcon.text:GetStringWidth()
    width = math.max(width,textWidth)
    height = height + 24
  end
  exFrame:SetSize(34 + width,height)
  exFrame:SetPoint("TOPLEFT",userFrame,"TOPRIGHT",24,0)
  exFrame:Show()
end

local itemIcon = CreateFrame("Frame",nil,bigFrame)
itemIcon:SetSize(60,60)
itemIcon:SetPoint("TOPLEFT",-64,0)
itemIcon:SetClipsChildren(true)
itemIcon.texture = itemIcon:CreateTexture(nil,"OVERLAY")
itemIcon.texture:SetTexture(133001)
itemIcon.texture:SetTexCoord(0.0625,0.9375,0.0625,0.9375)
itemIcon.texture:SetSize(56,56)
itemIcon.texture:SetPoint("CENTER")
itemIcon.mask = itemIcon:CreateMaskTexture()
itemIcon.mask:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\mask","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
itemIcon.mask:SetAllPoints(itemIcon.texture)
itemIcon.texture:AddMaskTexture(itemIcon.mask)
itemIcon.shadow = itemIcon:CreateTexture(nil,"OVERLAY")
itemIcon.shadow:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\bg")
itemIcon.shadow:SetTexCoord(0,0.9375,0,0.9375)
itemIcon.shadow:SetAllPoints()
itemIcon:Hide()

local function createRect(parent,w,h,color,x,y,c)
  local f = CreateFrame("Frame",nil,parent,"BackdropTemplate")
  f:SetSize(w,h)
  f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
  f:SetBackdropColor(unpack(color))
  f:SetPoint("TOPLEFT",x,y)
  if c then f:SetClipsChildren(true) end
  return f
end

local header = createRect(bigFrame,540,34,{0,0,0},0,0,true)
header:SetFrameLevel(20)
local headerLine = createRect(header,540,2,{1,0.7529,0},0,-32)
local mainFrame = createRect(bigFrame,540,336,{0,0,0},0,-34,true)
--bigFrame:SetScale(1.2)--SCALING
local footer = createRect(bigFrame,540,26,{0,0,0},0,-370,true)
footer:SetFrameLevel(20)
local footerLine = createRect(footer,540,2,{1,0.7529,0},0,0)

local mainFrameHeaderTitle = header:CreateFontString(nil,"OVERLAY","GameFontHighlightMedium")
mainFrameHeaderTitle:SetHeight(32)
mainFrameHeaderTitle:SetPoint("TOPLEFT",6,0)
mainFrameHeaderTitle:SetJustifyH("LEFT")
mainFrameHeaderTitle:SetJustifyV("MIDDLE")
mainFrameHeaderTitle:SetText("混搭收藏單")

local mainFrameEdit = CreateFrame("EditBox",nil,mainFrame)
mainFrameEdit:SetSize(240,24)
mainFrameEdit:SetFrameLevel(11)
mainFrameEdit:SetHighlightColor(0,0,0,0)
mainFrameEdit:SetFontObject(GameFontHighlight)
mainFrameEdit.block = CreateFrame("Frame",nil,mainFrameEdit)
mainFrameEdit.block:EnableMouse(true)
mainFrameEdit:Hide()

hooksecurefunc(mainFrameEdit,"ClearFocus",function()
  settings.custom = mainFrameEdit.custom or false
  local text = (settings.custom == false) and "已停用" or settings.custom
  memory[4][1].text = text
  mainFrameEdit.parent.userNote:SetText(text)
  mainFrameEdit:Hide()
end)
mainFrameEdit:SetScript("OnEscapePressed",function() mainFrameEdit:ClearFocus() end)
mainFrameEdit:SetScript("OnEnterPressed",function()
  mainFrameEdit.custom = mainFrameEdit:GetText()
  mainFrameEdit:ClearFocus()
end)

mainFrameEdit.block:SetScript("OnEnter",function()
  mainFrameEdit.parent:GetScript("OnEnter")()
end)
mainFrameEdit.block:SetScript("OnLeave",function()
  if lastUserFrameSelected ~= nil then
    lastUserFrameSelected.onLeave()
    lastUserFrameSelected = nil
  end
end)
mainFrameEdit.block:SetScript("OnMouseDown",function(self,button)
  mainFrameEdit.parent:GetScript("OnMouseDown")(self,button)
end)

local canInfo = true
local headerInfo = CreateFrame("Frame",nil,header)
headerInfo:SetAllPoints()
headerInfo.text = headerInfo:CreateFontString(nil,"OVERLAY","GameFontHighlight")
headerInfo.text:SetHeight(32)
headerInfo.text:SetPoint("TOPRIGHT",-2-28-2-8-7.875-8,0)
headerInfo.text:SetJustifyH("RIGHT")
headerInfo.text:SetJustifyV("MIDDLE")
headerInfo.text:SetText("點一下右鍵返回")
headerInfo.texture = headerInfo:CreateTexture(nil,"OVERLAY")
headerInfo.texture:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\i")
headerInfo.texture:SetTexCoord(0,0.5625,0,1)
headerInfo.texture:SetVertexColor(1,0.7529,0)
headerInfo.texture:SetSize(7.875,28)
headerInfo.texture:SetPoint("TOPLEFT",516-28-2+24-7.875-2-8,-2)
headerInfo.anim = headerInfo:CreateAnimationGroup()
headerInfo.animAlpha = headerInfo.anim:CreateAnimation("Alpha")
headerInfo.animAlpha:SetFromAlpha(1)
headerInfo.animAlpha:SetToAlpha(0)
headerInfo.animAlpha:SetStartDelay(4)
headerInfo.animAlpha:SetDuration(2)
headerInfo.animAlpha:SetSmoothing("IN_OUT")
headerInfo.anim:SetScript("OnFinished",function() headerInfo:Hide() end)
headerInfo:Hide()

local mainFrameExit = CreateFrame("Button",nil,header)
mainFrameExit:SetSize(28,28)
mainFrameExit:SetPoint("TOPLEFT",516-28-2+24,-2)
local mainFrameExitTexture = mainFrameExit:CreateTexture(nil,"OVERLAY")
mainFrameExitTexture:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\tools")
mainFrameExitTexture:SetTexCoord(0.5,1,0.5,1)
mainFrameExitTexture:SetVertexColor(0.9569,0.2627,0.2118)--RED
mainFrameExitTexture:SetAllPoints()
mainFrameExit:SetScript("OnEnter",function()
  mainFrameExitTexture:SetVertexColor(1,1,1)
end)
mainFrameExit:SetScript("OnLeave",function()
  mainFrameExitTexture:SetVertexColor(0.9569,0.2627,0.2118)--RED
end)
mainFrameExit:SetScript("OnClick",function()
  bigFrame:Hide()
end)

local mainFrameScrollHit = CreateFrame("Frame",nil,bigFrame,"BackdropTemplate")
mainFrameScrollHit:SetSize(24,336)
mainFrameScrollHit:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8"
})
local lastScrollPos = -1
local register = false
local mainFrameScrollHand,mainFrameScrollHandTexture
local function scrollDown()
  if #memory[mI] > 14 then
    register = true
    mainFrameScrollHandTexture:SetVertexColor(1,1,1)
  end
end
local function scrollUp()
  register = false
  lastScrollPos = -1
  if not MouseIsOver(mainFrameScrollHand) then
    mainFrameScrollHandTexture:SetVertexColor(1,0.7529,0)
  end
end
mainFrameScrollHit:SetPoint("TOPLEFT",492+24,-34)
mainFrameScrollHit:SetFrameLevel(mainFrame:GetFrameLevel() + 1)
mainFrameScrollHit:SetScript("OnMouseDown",scrollDown)
mainFrameScrollHit:SetScript("OnMouseUp",scrollUp)
mainFrameScrollHit:SetAlpha(0)

local mainFrameScrollBackground = CreateFrame("Frame",nil,bigFrame,"BackdropTemplate")
mainFrameScrollBackground:SetSize(4,336-8-8)
mainFrameScrollBackground:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8"
})
mainFrameScrollBackground:SetBackdropColor(0.3,0.3,0.3)
mainFrameScrollBackground:SetPoint("TOPLEFT",492+2+8+24,-8-34)

mainFrameScrollHand = CreateFrame("Button",nil,bigFrame)
mainFrameScrollHand:SetSize(12.25,21)
mainFrameScrollHand:SetPoint("TOPLEFT",492+5.875+24,-5.875-34)
--mainFrameScrollHand:SetPoint("TOPLEFT",492+5.875,-309.125)
mainFrameScrollHandTexture = mainFrameScrollHand:CreateTexture(nil,"OVERLAY")
mainFrameScrollHandTexture:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\hand")
mainFrameScrollHandTexture:SetTexCoord(0,0.875,0,0.75)
mainFrameScrollHandTexture:SetVertexColor(1,0.7529,0)
mainFrameScrollHandTexture:SetAllPoints()
mainFrameScrollHand:SetFrameLevel(mainFrameScrollHit:GetFrameLevel() + 1)
mainFrameScrollHand:SetScript("OnEnter",function()
  if #memory[mI] > 14 then
    mainFrameScrollHandTexture:SetVertexColor(1,1,1)
  end
end)
mainFrameScrollHand:SetScript("OnLeave",function()
  if not register then
    mainFrameScrollHandTexture:SetVertexColor(1,0.7529,0)
  end
end)
mainFrameScrollHand:SetScript("OnMouseDown",scrollDown)
mainFrameScrollHand:SetScript("OnMouseUp",scrollUp)

local function mainFrameScroll(adjustedValue,setScroll,update)
  local firstItem = floor(adjustedValue)
  local shift = adjustedValue - firstItem
  for i = 1,15 do
    local userFrame = userFrames[i]
    local offset = (shift * 24) + ((i - 1) * -24)
    userFrame:SetPoint("TOPLEFT",0,offset)
    
    if update and memory[mI][#memory[mI] - (firstItem + (i-1))] ~= nil then
      userFrame.update(firstItem + (i-1))
    end
  end
  if setScroll then scroll = firstItem * 24 + shift * 24 end
  local newHandPos
  if #memory[mI] < 15 then
    newHandPos = -5.875-34
  else
    newHandPos = -5.875-34 + (adjustedValue / (#memory[mI] - 14)) * -303.25
  end
  --mainFrameScrollHand:SetSize(12.25,21)
  --mainFrameScrollHand:SetPoint("TOPLEFT",492+5.875,-5.875)
  --mainFrameScrollHand:SetPoint("TOPLEFT",492+5.875,-309.125)

  mainFrameScrollHand:SetPoint("TOPLEFT",492+24+5.875,newHandPos)
end

mainFrame:SetScript("OnMouseWheel",function(_,delta)
  local maxUsers = #memory[mI] - 14
  if maxUsers > 0 then
    local maxScroll = maxUsers * 24
    scroll = scroll + delta * -32
    if scroll < 0 then
      scroll = 0
    elseif scroll > maxScroll then
      scroll = maxScroll
    end
    local adjustedValue = scroll / maxScroll * maxUsers
    mainFrameScroll(adjustedValue,false,true)
  end
end)

local history = {}
local titleH = {}
local function clean(index,ignore,alt,total,collected)
  if ignore == nil then table.insert(history,mI) end
  mI = index
  scroll = 0
  mainFrameScroll(0,false,false)
  for i = 1,15 do
    local userFrame = userFrames[i]
    if i == min(#memory[mI],i) then
      userFrame.update(i - 1)
      userFrame:Show()
    else userFrame:Hide() end
  end
  if alt ~= nil then index = alt end
  local title = string.format("混搭收藏單%s",lists[index])
  if total ~= nil then
    titleH = {title,collected,total}
    title = string.format("%s (%d/%d)",title,collected,total)
  end
  mainFrameHeaderTitle:SetText(title)
  if canInfo then
    headerInfo:Show()
    headerInfo.anim:Play()
    canInfo = false
  end
end

local selGroup
local function goBack()
  if #history > 0 then
    if mainFrameEdit:IsVisible() then
      userFrames[9].userNote:SetText("已停用")
      mainFrameEdit:Hide()
    end
    if GameTooltip:IsVisible() then
      itemIcon:Hide()
      GameTooltip:Hide()
    end
    if exFrame:IsVisible() then exFrame:Hide() end
    clean(history[#history],true)
    history[#history] = nil
    selGroup = nil
  end
end

mainFrame:SetScript("OnMouseDown",function(_,button)
  if button == "RightButton" then goBack() end
end)

flags = {item = {},mount = {},spell = {},pet = {}}
local flagType = {
  [1] = flags.mount,
  [2] = flags.spell,
  [5] = flags.pet,
  [7] = flags.spell
}

local function classLoot(specs)
  for i = 1,GetNumSpecializations() do
    local specID = GetSpecializationInfo(i)
    if specs[specID] ~= nil then return true end
  end
  return false
end

local function filter(filterID,key,ignore)
  memory[3] = {}
  local total,collected = 0,0
  for _,sel in ipairs(memory[key]) do
    local canLoot = true
    if sel.itemSpecs.s > 0 and sel.itemSpecs[-1] == nil then
      if filterID == -1 then canLoot = classLoot(sel.itemSpecs)
      elseif filterID >= 0 and sel.itemSpecs[filterID] == nil then canLoot = false end
    end
    --
    if canLoot then
      total = total + 1
      if sel.owned or settings.hideKnown and sel.known then collected = collected + 1 end
      if not (settings.hideOwned and (sel.owned or settings.hideKnown and sel.known) or settings.hideUnobt and sel.un) then
        table.insert(memory[3],{
          itemID = sel.itemID,
          text = sel.text,
          name = sel.name,
          owned = sel.owned,
          known = sel.known,
          spellID = sel.spellID,
          itemLink = sel.itemLink,
          t = sel.t,
          un = sel.un,
          s = sel.s,
          uid = sel.uid
        })
      end
    end
  end
  clean(3,ignore,key,total,collected)
end

local selSpecID = -2
local selBtn
local function createBtn(str,specID,offset,sel)
  local text = footer:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  text:SetText(str)
  local w = text:GetWidth() + 12
  local btn = createRect(footer,w,24,{0,0,0},offset or 0,-2)
  text:SetParent(btn); text:SetAllPoints()
  if sel then text:SetTextColor(1,0.7529,0); selBtn = text end
  btn:SetScript("OnEnter",function(self)
    self:SetBackdropColor(0.125,0.125,0.125)
    text:SetTextColor(1,0.7529,0)
  end)
  btn:SetScript("OnLeave",function(self)
    self:SetBackdropColor(0,0,0)
    if selSpecID ~= specID then text:SetTextColor(1,1,1) end
  end)
  btn:SetScript("OnMouseDown",function(self)
    if selBtn ~= text then
      selBtn:SetTextColor(1,1,1); selBtn = text
      selSpecID = specID
      if selGroup then filter(selSpecID,selGroup,true) end
    end
  end)
  return w
end

local function populateSpec()
  memory[2][1] = {itemID = nil,text = "開啟設定選項",name = "設定",specID = -3,uid = uid()}
  memory[2][2] = {itemID = nil,text = "只篩選舊版本物品",name = "舊版本",specID = -23,uid = uid()}
  memory[2][3] = {itemID = nil,text = "只篩選巨龍崛起玩具",name = "巨龍崛起玩具",specID = -15,uid = uid()}
  memory[2][4] = {itemID = nil,text = "只篩選黑曜石塑形套裝",name = "黑曜石塑形套裝",specID = -24,uid = uid()}
  memory[2][5] = {itemID = nil,text = "只篩選探究者飛艇",name = "探究者飛艇",specID = -25,uid = uid()}
  memory[2][6] = {itemID = nil,text = "只篩選20週年紀念塑形套裝",name = "20週年紀念塑形套裝",specID = -26,uid = uid()}
  memory[2][7] = {itemID = nil,text = "只篩選海妖之嶼物品",name = "海妖之嶼",specID = -27,uid = uid()}
  memory[2][8] = {itemID = nil,text = "只篩選強襲風暴物品",name = "強襲風暴",specID = -28,uid = uid()}
  memory[2][9] = {itemID = nil,text = "只篩選D.R.I.V.E.物品",name = "D.R.I.V.E.",specID = -29,uid = uid()}
  memory[2][10] = {itemID = nil,text = "只篩選時尚大考驗物品",name = "時尚大考驗",specID = -30,uid = uid()}
  memory[2][11] = {itemID = nil,text = (tocversion >= 110205) and "只篩選混搭再造：軍臨天下物品" or "將於 11.2.5 更新檔推出",name = "|cff58FF00混搭再造：軍臨天下",specID = -31,uid = uid()}
  local w = createBtn(playerClass.name,-1)
  for i = 1,GetNumSpecializations() do
    local specID, specName = GetSpecializationInfo(i)
    table.insert(playerSpecs,specID)
    w = w + createBtn(specName,specID,w)
  end
  w = w + createBtn("全部",-2,w,true)
  memory[6][1] = {itemID = nil,text = "篩選所有其他項目",name = "其他",specID = -14,uid = uid()}
  memory[6][2] = {itemID = nil,text = "只篩選玩具",name = "玩具",specID = -11,uid = uid()}
  memory[6][3] = {itemID = nil,text = "只篩選坐騎",name = "坐騎",specID = -10,uid = uid()}
  memory[6][4] = {itemID = nil,text = "只篩選軍火庫與塑形套裝",name = "軍火庫與塑形套裝",specID = -9,uid = uid()}
  memory[11][1] = {itemID = nil,text = "只篩選新兵裝備",name = "新兵裝備",specID = -21,uid = uid()}
  memory[11][2] = {itemID = nil,text = "只篩選獎勵",name = "獎勵",specID = -20,uid = uid()}
  memory[14][1] = {itemID = nil,text = "開啟光輝迴響群組",name = "光輝迴響",specID = -18,uid = uid()}
  memory[14][2] = {itemID = nil,text = "開啟無盡市集群組",name = "無盡市集",specID = -6,uid = uid()}
  memory[14][3] = {itemID = nil,text = "只篩選混搭再造：潘達利亞之謎物品",name = "混搭再造：潘達利亞之謎",specID = -19,uid = uid()}
  memory[22][10] = {itemID = nil,text = "開啟此分類",name = "超稀有外觀",specID = -32,uid = uid()}
  memory[22][9] = {itemID = nil,text = "開啟此分類",name = "職業大廳坐騎",specID = -33,uid = uid()}
  memory[22][8] = {itemID = nil,text = "開啟此分類",name = "混搭再造坐騎",specID = -34,uid = uid()}
  memory[22][7] = {itemID = nil,text = "開啟此分類",name = "混搭再造寵物與玩具",specID = -35,uid = uid()}
  memory[22][6] = {itemID = nil,text = "開啟此分類",name = "獨家套裝",specID = -36,uid = uid()}
  memory[22][5] = {itemID = nil,text = "開啟此分類",name = "開放世界套裝",specID = -37,uid = uid()}
  memory[22][4] = {itemID = nil,text = "開啟此分類",name = "地城套裝",specID = -38,uid = uid()}
  --memory[22][6] = {itemID = nil,text = "開啟此分類",name = "團隊搜尋器塑形套裝",specID = -39,uid = uid()}
  --memory[22][5] = {itemID = nil,text = "開啟此分類",name = "普通團隊塑形套裝",specID = -40,uid = uid()}
  --memory[22][4] = {itemID = nil,text = "開啟此分類",name = "英雄團隊塑形套裝",specID = -41,uid = uid()}
  memory[22][3] = {itemID = nil,text = "開啟此分類",name = "團隊套裝",specID = -42,uid = uid()}
  memory[22][2] = {itemID = nil,text = "開啟此分類",name = "失物招領服飾",specID = -43,uid = uid()}
  memory[22][1] = {itemID = nil,text = "開啟此分類",name = "折扣披風套裝",specID = -44,uid = uid()}
end

local function checkShopID(id)
  if id == nil or id == 226127 then return false end
  local m = flags.item[id]
  return m and m.owned or false
end

local function updateMerchantBtn(btn,i)
  local merchantButton = _G["MerchantItem"..btn]
  local itemName = _G["MerchantItem"..btn.."Name"]
  local itemButton = _G["MerchantItem"..btn.."ItemButton"]
  local altCurrency = _G["MerchantItem"..btn.."AltCurrencyFrame"]
  local function popItem()
    itemName:SetText("")
    itemButton:Hide()
    altCurrency:Hide()
    SetItemButtonSlotVertexColor(merchantButton,0.4,0.4,0.4)
  end
  if i == nil then popItem(); return end
  local name,texture,_,_,_,isPurchasable = GetMerchantItemInfo(i)
  if name == nil then popItem(); return end

  itemName:SetText(name)
  SetItemButtonTexture(itemButton,texture)
  MerchantFrame_UpdateAltCurrency(i,btn,CanAffordMerchantItem(i))
  altCurrency:Show()--test if needed
  local itemLink = GetMerchantItemLink(i)
  MerchantFrameItem_UpdateQuality(merchantButton,itemLink)
  local merchantItemID = GetMerchantItemID(i)
  local isHeirloom = merchantItemID and C_Heirloom.IsItemHeirloom(merchantItemID)
  local isKnownHeirloom = isHeirloom and C_Heirloom.PlayerHasHeirloom(merchantItemID)
  itemButton:SetID(i)
  itemButton:Show()
  itemButton.link = itemLink
  itemButton.texture = texture
  SetItemButtonDesaturated(itemButton,isKnownHeirloom)
  
  if isKnownHeirloom then
    SetItemButtonSlotVertexColor(merchantButton,0.5,0.5,0.5)
    SetItemButtonTextureVertexColor(itemButton,0.5,0.5,0.5)
    SetItemButtonNormalTextureVertexColor(itemButton,0.5,0.5,0.5)
  elseif not isPurchasable then
    SetItemButtonSlotVertexColor(merchantButton,1.0,0,0)
    SetItemButtonTextureVertexColor(itemButton,0.9,0,0)
    SetItemButtonNormalTextureVertexColor(itemButton,0.9,0,0)
  else
    SetItemButtonSlotVertexColor(merchantButton,1.0,1.0,1.0)
    SetItemButtonTextureVertexColor(itemButton,1.0,1.0,1.0)
    SetItemButtonNormalTextureVertexColor(itemButton,1.0,1.0,1.0)
  end
end

local vendor = {}

local validMerchants = {
  [219027] = true, --PYTHAGORUS
  [219028] = true, --DURUS
  [225269] = true, --DURUS2
  [219031] = true, --AEONICUS
  [219030] = true, --ARTUROS
  [219025] = true, --LARAH
  [220618] = true, --JAKKUS
  [220895] = true, --JAKKUS2
  [219032] = true, --HEMET
  [219331] = true, --HEMET2
  [217051] = true, --HOROS
  [219013] = true, --HOROS2
  [54442]=true,[54473]=true,[64573]=true,[67014]=true,[85289]=true, --WARP
  [85291]=true,[85961]=true,[86395]=true,[99867]=true,[131470]=true,
  [133196]=true,[142068]=true,[156663]=true,[185570]=true,[201312]=true,
  [201314]=true,[219053]=true,[221770]=true,[221848]=true,[225999]=true,
  --Legion
  [241167] = true, --HOROS
  [241168] = true, --PYTHAGORUS
  [241186] = true, --JAKKUS
  [241182] = true, --HEMET
  [246026] = true, --UNICUS
  [241191] = true, --LARAH
  [241147] = true, --ARTUROS
  [241184] = true, --AGOS
  [246030] = true --FREDDIE
}

local function isValidMerchant()
  if UnitGUID("npc") == nil then return false end
  local npcID = select(6,strsplit("-",UnitGUID("npc")))
  return validMerchants[tonumber(npcID)] or false
end

local function updateMerchant()
  if not settings.hideMerchant or not isValidMerchant() then return end
  local size = MERCHANT_ITEMS_PER_PAGE
  MerchantPageText:SetFormattedText(MERCHANT_PAGE_NUMBER,MerchantFrame.page,math.ceil(#vendor / size))
  if #vendor <= size then
    MerchantPageText:Hide()
		MerchantPrevPageButton:Hide()
		MerchantNextPageButton:Hide()
  elseif MerchantFrame.page == math.ceil(#vendor / size) then MerchantNextPageButton:Disable() end
  for i = 1,size do
    local index = (MerchantFrame.page - 1) * size + i
    updateMerchantBtn(i,vendor[index])
  end
end

local function openMerchant(force)
  if not settings.hideMerchant or not isValidMerchant() then return end
  vendor = {}
  for i = 1,GetMerchantNumItems() do
    local itemID = GetMerchantItemID(i)
    if not checkShopID(itemID) then table.insert(vendor,i) end
  end
  if force ~= nil then
    MerchantFrame.page = 1
    MerchantPrevPageButton:Disable()
    MerchantNextPageButton:Enable()
    updateMerchant()
  end
end

local function updateNote(arg,new1,new2)
  for i,u in ipairs(userFrames) do
    if not u:IsShown() then break end
    if arg.uid == u.uid then
      if new1 ~= nil then u.userNote:SetText(arg.text) end
      if new2 ~= nil then
        u.userMood.color(colors.green)
        u.userMood:SetTexCoord(0,0.5,0,0.5)
      end
      break
    end
  end
end

local default = "嗨，請問你剛拾取的 $ 有需要嗎？如果沒有的話，可以給我嗎？謝謝。"
local function openEdit(arg)
  for _,u in ipairs(userFrames) do
    if arg.uid == u.uid then
      mainFrameEdit.parent = u
      u.userNote:SetText("")
      mainFrameEdit:SetPoint("RIGHT",u,-24,0)
      mainFrameEdit.block:SetAllPoints(u)
      break
    end
  end
end

local options = {
  default = {[false] = true,[true] = false},
  special = {[false] = 1,[1] = 2,[2] = false}
}
local function switch(var,i,opt)
  settings[var] = options[opt or "default"][settings[var]]
  memory[4][i].text = state[settings[var]]
  updateNote(memory[4][i],true)
end

local actions = {
  [-3] = function() clean(4) end, --SETTINGS
  [-4] = function() switch("hideOwned",9) end,
  [-5] = function()
    buttonTT:SetShown(settings.hideIcon)
    dbTT.minimap.hide = not settings.hideIcon
    switch("hideIcon",5)
  end,
  [-6] = function() clean(orig["inf"]) end,--filter(-1,orig["inf"]) end, --ENSEMBLES
  [-7] = function()
    switch("hideMerchant",6)
    if MerchantFrame:IsVisible() then
      if settings.hideMerchant then openMerchant(true)
      else
        MerchantFrame.page = 1
        MerchantFrame_UpdateMerchantInfo()
      end
    end
  end,
  [-8] = function() switch("trade",4,"special") end,
  [-9] = function() filter(-1,orig["ens"]) end,
  [-10] = function() filter(-1,orig["mou"]) end,
  [-11] = function() filter(-1,orig["toy"]) end,
  [-12] = function() switch("instant",2) end,
  [-13] = function()
    if settings.custom == false then
      mainFrameEdit:Show()
      mainFrameEdit:SetText(default)
      mainFrameEdit:HighlightText()
      mainFrameEdit:SetCursorPosition(0)
      openEdit(memory[4][1])
    else
      settings.custom = false
      memory[4][1].text = "已停用"
      updateNote(memory[4][1],true)
      mainFrameEdit.custom = nil
    end
  end,
  [-14] = function() filter(-1,orig["oth"]) end,
  [-15] = function() filter(-1,orig["dto"]) end,
  [-16] = function() switch("hideUnobt",7) end,
  [-17] = function() switch("unlisted",3) end,
  [-18] = function() clean(orig["rad"]) end,
  [-19] = function() filter(selSpecID,orig["mop"]); selGroup = 1 end,
  [-20] = function() filter(-1,orig["rew"]) end,
  [-21] = function() filter(selSpecID,orig["rec"]); selGroup = 13 end,
  [-22] = function() switch("hideKnown",8) end,
  [-23] = function() clean(orig["leg"]) end,
  [-24] = function() filter(-1,orig["osi"]) end,
  [-25] = function() filter(-1,orig["del"]) end,
  [-26] = function() filter(-1,orig["ann"]) end,
  [-27] = function() if not memory[18].needToLoad then filter(selSpecID,18); selGroup = 18 end end,
  [-28] = function() if not memory[19].needToLoad then filter(selSpecID,19); selGroup = 19 end end,
  [-29] = function() if not memory[20].needToLoad then filter(selSpecID,20); selGroup = 20 end end,
  [-30] = function() if not memory[21].needToLoad then filter(selSpecID,21); selGroup = 21 end end,
  [-31] = function() if tocversion >= 110205 then clean(orig["lemix"]) end end,
  [-32] = function() if not memory[23].needToLoad then filter(selSpecID,23); selGroup = 23 end end,
  [-33] = function() if not memory[24].needToLoad then filter(selSpecID,24); selGroup = 24 end end,
  [-34] = function() if not memory[25].needToLoad then filter(selSpecID,25); selGroup = 25 end end,
  [-35] = function() if not memory[26].needToLoad then filter(selSpecID,26); selGroup = 26 end end,
  [-36] = function() if not memory[27].needToLoad then filter(selSpecID,27); selGroup = 27 end end,
  [-37] = function() if not memory[28].needToLoad then filter(selSpecID,28); selGroup = 28 end end,
  [-38] = function() if not memory[29].needToLoad then filter(selSpecID,29); selGroup = 29 end end,
  [-39] = function() if not memory[30].needToLoad then filter(selSpecID,30); selGroup = 30 end end,
  [-40] = function() if not memory[31].needToLoad then filter(selSpecID,31); selGroup = 31 end end,
  [-41] = function() if not memory[32].needToLoad then filter(selSpecID,32); selGroup = 32 end end,
  [-42] = function() if not memory[33].needToLoad then filter(selSpecID,33); selGroup = 33 end end,
  [-43] = function() if not memory[34].needToLoad then filter(selSpecID,34); selGroup = 34 end end,
  [-44] = function() if not memory[35].needToLoad then filter(selSpecID,35); selGroup = 35 end end
}

local function userFrameOnClick(button,parent)
  if button == "LeftButton" then
    if parent.itemID == nil then actions[parent.specID]()
    else
      if ACTIVE_CHAT_EDIT_BOX ~= nil and IsShiftKeyDown() then ChatEdit_InsertLink(parent.itemLink)
      elseif IsControlKeyDown() then
        if parent.t == 1 then DressUpMount(parent.spellID)
        elseif parent.t == 3 then C_ToyBox.PickupToyBoxItem(parent.itemID)
        elseif parent.t == 5 then
          local displayID = C_PetJournal.GetDisplayIDByIndex(parent.spellID,1)
          DressUpBattlePet(nil,displayID,parent.spellID)
        elseif parent.t ~= 4 then DressUpItemLink("item:"..parent.itemID) end
      end
    end
  elseif button == "RightButton" then goBack() end
end

local function createUserFrame(offset)
local userFrame = CreateFrame("Frame",nil,mainFrame,"BackdropTemplate")
userFrame:SetClipsChildren(true)
userFrame:SetSize(492+24,24)
userFrame:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8"
})
userFrame:SetBackdropColor(0,0,0)
userFrame:SetPoint("TOPLEFT",0,offset)
if #userFrames > 0 then
  userFrame:SetFrameLevel(userFrames[#userFrames]:GetFrameLevel() + 1)
end

local userName
userFrame.userMood = nil
userFrame.userNote = nil

userFrame.id = nil
userFrame.uid = 0
userFrame.name = ""
userFrame.text = ""
userFrame.itemID = nil
userFrame.specID = nil
userFrame.spellID = nil
userFrame.itemLink = nil
userFrame.t = nil
userFrame.un = nil
userFrame.s = nil

userFrame.onEnter = function()
  --print(userFrame.uid)
  if lastUserFrameSelected ~= nil then
    lastUserFrameSelected.onLeave()
  end
  lastUserFrameSelected = userFrame
  userName:SetTextColor(1,0.7529,0)
  userFrame.userNote:SetTextColor(1,0.7529,0)
  if userFrame.color == colors.white then
    userFrame.userMood.color(colors.gold)
  end
  userFrame:SetBackdropColor(0.125,0.125,0.125)

  userName:SetWordWrap(true)
  userFrame.userNote:SetWordWrap(true)
  if userFrame.itemID ~= nil then
    itemIcon.texture:SetTexture(GetItemIcon(userFrame.itemID))
    itemIcon:Show()
    GameTooltip:SetOwner(bigFrame,"ANCHOR_BOTTOMLEFT",-4,336+34-60-4+26)
    GameTooltip:SetHyperlink("item:"..userFrame.itemID)
    GameTooltip:Show()
  end

  if userFrame.cost then
    for i = 2,7,2 do
      local amount = userFrame.cost[i]
      if amount ~= nil then
        local text = exIcons[i / 2].text
        --[[if amount == "rad" then
          amount = getTime()
          exFrame:SetScript("OnUpdate",function() text:SetText(getTime()) end)
        end]]--
        exIcons[i / 2].bg:SetTexture(userFrame.cost[i + 1])
        text:SetText(amount)
        exIcons[i / 2].icon:Show()
      else exIcons[i / 2].icon:Hide() end
    end
    resizeEx(userFrame)
  end
end

userFrame.update = function(shift)
  userFrame.id = shift
  local memoryItem = memory[mI][#memory[mI] - shift]
  userFrame.uid = memoryItem.uid
  if userFrame.needUpdate ~= userFrame.uid then
    userFrame.needUpdate = userFrame.uid

    local moodColor = colors.none
    local moodIcon = {0,0.5,0,0.5}
    if memoryItem.owned or settings.hideKnown and memoryItem.known then moodColor = colors.green end
    if type(memoryItem.text) ~= "table" then
      userFrame.cost = nil
      userFrame.text = memoryItem.text
      if userFrame.uid == 10 then
        moodColor = colors.white
        moodIcon = {0,0.5,0.5,1}
      end
    else
      userFrame.cost = memoryItem.text
      userFrame.text = memoryItem.text[1]
      if moodColor[4] == 0 then
        moodColor = colors.white
        moodIcon = {0.5,1,0,0.5}
      end
    end

    userFrame.itemID = memoryItem.itemID
    userFrame.name = memoryItem.name
    userFrame.t = memoryItem.t
    userFrame.un = memoryItem.un
    userFrame.s = memoryItem.s
    if memoryItem.specID == nil then
      userFrame.specID = nil
    else
      userFrame.specID = memoryItem.specID
    end
    if memoryItem.spellID == nil then
      userFrame.spellID = nil
    else
      userFrame.spellID = memoryItem.spellID
    end
    if memoryItem.itemLink == nil then
      userFrame.itemLink = nil
    else
      userFrame.itemLink = memoryItem.itemLink
    end

    userName:SetText(userFrame.name)
    userFrame.userNote:SetText(userFrame.text)
    userFrame.userMood.color(moodColor)
    userFrame.userMood:SetTexCoord(unpack(moodIcon))

    if MouseIsOver(userFrame) and not selGroup then userFrame.onEnter() end
  end
end

userFrame:SetScript("OnEnter",userFrame.onEnter)
userFrame.onLeave = function()
  lastUserFrameSelected = nil
  userName:SetTextColor(1,1,1)
  userFrame.userNote:SetTextColor(1,1,1)
  if userFrame.color == colors.gold then
    userFrame.userMood.color(colors.white)
  end
  userFrame:SetBackdropColor(0,0,0)

  userName:SetWordWrap(false)
  userFrame.userNote:SetWordWrap(false)
  if userFrame.itemID ~= nil then
    itemIcon:Hide()
    GameTooltip:Hide()
  end
  if exFrame:IsVisible() then exFrame:Hide() end --userFrame.cost
end
userFrame:SetScript("OnMouseDown",function(self,button) userFrameOnClick(button,userFrame) end)
userFrame:SetScript("OnLeave",userFrame.onLeave)

local function createText(parent,w,h,x,y)
  local t = parent:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  t:SetSize(w,h)
  t:SetPoint("TOPLEFT",x,y)
  t:SetJustifyH("LEFT")
  t:SetWordWrap(false)
  return t
end

userName = createText(userFrame,240,26,6,1)
userName:SetText("z")
userFrame.userNote = createText(userFrame,240,26,6+240+6,1)
userFrame.userNote:SetText("y")

userFrame.userMood = userFrame:CreateTexture(nil,"OVERLAY")
userFrame.userMood:SetSize(14,14)
userFrame.userMood:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\done")
userFrame.userMood:SetPoint("TOPLEFT",492-14-5+24,-5)
userFrame.userMood.color = function(arg1)
  userFrame.color = arg1
  userFrame.userMood:SetVertexColor(unpack(arg1))
end

table.insert(userFrames,userFrame)
return userFrame
end

local main = CreateFrame("Frame")
main:SetScript('OnUpdate',function()
  if register then
    local x,y = GetCursorPosition()
    x = x / UIParent:GetEffectiveScale()
    y = y / UIParent:GetEffectiveScale()
    local cursorPosX,cursorPosY = mainFrameScrollHit:GetCenter()
    cursorPosX = x - cursorPosX
    cursorPosY = y - cursorPosY
    local scrollPos = abs(min(max(cursorPosY,-151.625),151.625) / 303.25 - 0.5)
    --print(scrollPos)
    if scrollPos ~= lastScrollPos then
      lastScrollPos = scrollPos
      local newHandPos = -5.875-34 + scrollPos * -303.25
      mainFrameScrollHand:SetPoint("TOPLEFT",492+5.875+24,newHandPos)

      local maxUsers = #memory[mI] - 14
      if maxUsers > 0 then
        local adjustedValue = maxUsers * scrollPos
        mainFrameScroll(adjustedValue,true,true)
      end
    end
  end
end)

SLASH_TROVE1 = "/trove"
SLASH_TROVE2 = "/tally"
SLASH_TROVE3 = "/trovetally"
SlashCmdList["TROVE"] = function() bigFrame:SetShown(not bigFrame:IsVisible()) end

local loading = {id = nil,i = 1}

local sets = {
  439,488,573,
  422,540,472,507,558,456,332,524,443,445,
  491,494,577,580,425,338,544,547,475,477,
  511,514,561,564,460,463,334,429,527,530,
  --PYTHAGORUS

  438,441,444,3440,
  487,490,493,572,575,578,421,424,427,539,
  542,545,471,474,478,506,510,513,557,560,
  563,455,458,461,331,310,336,523,526,529,
  --DURUS

  440,442,446,
  489,492,495,574,576,579,423,426,428,541,
  543,546,473,476,479,512,508,515,559,562,
  565,457,459,462,333,335,337,525,528,531,
  --AEONICUS

  3422,3421,3420,
  3402,3401,3400,3385,3384,3383,3382,3370,3369,3365,
  --ARTUROS

  3433,3432,
  3431,3430,3419,3418,3417,3416,3399,3398,3397,3379,
  3378,3377,3429,3428,3427,3426,3412,3411,3410,3393,
  3392,3391,3390,3376,3375,3374,3425,3424,3423,3409,
  3408,3407,3406,3389,3388,3387,3386,3373,3372,3371,
  3368,3438,3439,3415,3414,3413,3396,3395,3394,3437,
  3436,3435,3434,3405,3404,3403,3381,3380,
  --LARAH

  3500,3502,3490,3509,3510,3514,
  3504,3496,3492,3494,3506,3508,3498,3499,3501,3489,
  3511,3512,3513,3503,3495,3491,3493,3507,3505,3497,
  --JAKKUS

  3522,3523,3524,3525,3526,3528,3529,3530,3531,3533,
  3534,3535,3536,3538,3539,3540,3541,3542,3543,3544,
  3545,3546,3548,3549,3550,3551,3552,3553,3555,3556,
  --OSIDION

  3872,3873,3866,3867,3865,3871,3861,3868,3869,3862,
  3870,3863,3864
  --TRAEYA
}
local setI = 1

local function setOwned(transmogSet)
  local ids = C_TransmogSets.GetAllSourceIDs(transmogSet or sets[setI])
  setI = setI + 1
  for _,sourceID in ipairs(ids) do
    local info = C_TransmogCollection.GetSourceInfo(sourceID)
    if not info.isCollected then return false end
  end
  return true
end

local function addToList(page,id,text,t,un,s,n,q,specs,spell,link,spot,transmogSet,que)
  local hex = ITEM_QUALITY_COLORS[q].hex
  local owned = nil
  local known = nil
  if t == 1 then owned = select(11,C_MountJournal.GetMountInfoByID(spell)) --MOUNT
  elseif t == 3 then owned = PlayerHasToy(id) --TOY
  elseif t == 4 then owned = C_Heirloom.PlayerHasHeirloom(id) --HEIRLOOM
  elseif t == 5 then owned = C_PetJournal.GetNumCollectedInfo(spell) > 0 --PET
  elseif t == 6 then owned = C_QuestLog.IsQuestFlaggedCompleted(spell) --PET
  elseif t == 7 then owned = C_QuestLog.IsQuestFlaggedCompleted(que) --PET
  elseif specs.s > 0 then
    owned = C_TransmogCollection.PlayerHasTransmog(id)
    if q == 7 then elseif owned then known = owned else
      local transmogID = C_TransmogCollection.GetItemInfo(id)
      if transmogID then
        local sources = C_TransmogCollection.GetAllAppearanceSources(transmogID)
        if #sources > 1 then
          known = false
          for _,src in ipairs(sources) do
            if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(src) then
              known = true break
            end
          end
        end
      else known = false end
    end
  else owned = setOwned(transmogSet) end
  memory[page][spot or #memory[page] + 1] = {
    itemID = id,
    spellID = spell,
    text = text,
    name = hex.."["..n.."]",
    itemSpecs = specs,
    owned = owned,
    known = known,
    itemLink = spot and link or hex.."|Hitem:"..id..link.."|h["..n.."]|h|r",
    t = t,
    un = un,
    s = s,
    uid = uid()
  }
  flags.item[id] = memory[page][spot or #memory[page]]
  if flagType[t] then flagType[t][spell] = flags.item[id] end
end

local lang = 1
if GetLocale() == "esES" or GetLocale() == "esMX" then lang = 2
elseif GetLocale() == "ptBR" then lang = 3
elseif GetLocale() == "deDE" then lang = 4
elseif GetLocale() == "frFR" then lang = 5
elseif GetLocale() == "itIT" then lang = 6
elseif GetLocale() == "ruRU" then lang = 7
elseif GetLocale() == "koKR" then lang = 8
elseif GetLocale() == "zhCN" or GetLocale() == "zhTW" then lang = 9 end

local function loadDB(array,page,src)
  for i = 1,#array,2 do
    local id = array[i]
    local text = array[i + 1]
    local item = type(src[id]) == "table" and src[id] or src[src[id]]
    item.specs.s = -1 --COUNTS AS 0
    for _ in pairs(item.specs) do item.specs.s = item.specs.s + 1 end
    addToList(page,id,text,item.t,item.un,item.s,item.n[lang],item.q,item.specs,item.spell,item.link)
  end
end

local typeMap = {
  [2] = {
    [0]=1,[1]=2,[2]=3,[3]=4,[4]=5,[5]=6,[6]=7,[7]=8,[8]=9,[9]=10,
    [10]=11,[13]=12,[15]=13,[18]=14,[19]=15
  },
  [4] = {
    [0]=16,[1]=17,[2]=18,[3]=19,[4]=20,[5]=21,[6]=22
  }
}
local function getType(itemType,itemSubType)
  local check = typeMap[itemType]
  if check then return check[itemSubType] end
  return nil
end

local function loadDBNew(page)
  local array = dbData[page]
  memory[page].needToLoad = #array / 3
  local needToLoad = memory[page].needToLoad
  local tempSpot = #array / 3 + 1
  for i = 1,#array,3 do
    tempSpot = tempSpot - 1
    local spot = tempSpot
    local id,text,extra = array[i],array[i + 1],array[i + 2]
    local item = Item:CreateFromItemID(id)

    item:ContinueOnItemLoad(function()
      local info = {C_Item.GetItemInfo(id)}
      local data = {n=info[1],q=info[3],specs={s=-1},link=info[2]}
      if not extra.t then
        data.s = getType(info[12],info[13])
        data.specs.s = 1
        local specInfo = C_Item.GetItemSpecInfo(id)
        if specInfo then for _,spec in ipairs(specInfo) do data.specs[spec] = 1 end
        else data.specs[-1] = 1 end
      elseif extra.t == 1 then data.spell = C_MountJournal.GetMountFromItem(id)
      elseif extra.t == 2 then
        data.spell = select(2,C_Item.GetItemSpell(id))
        data.transmogSet = C_Item.GetItemLearnTransmogSet(id)
      elseif extra.t == 5 then data.spell = select(13,C_PetJournal.GetPetInfoByItemID(id))
      elseif extra.t == 7 then data.spell = select(2,C_Item.GetItemSpell(id)) end
      addToList(page,id,text,extra.t,extra.un,data.s,data.n,data.q,data.specs,data.spell,data.link,spot,data.transmogSet,extra.que)
      needToLoad = needToLoad - 1
      if needToLoad == 0 then memory[page].needToLoad = nil end
    end)
  end
end

local function removeAt(j)
  table.remove(memory[mI],j)
  local maxUsers = #memory[mI] - 14
  local maxScroll = maxUsers * 24
  if maxUsers <= 0 then
    scroll = 0
    mainFrameScroll(0,false,false)
    for i = 1,15 do
      local userFrame = userFrames[i]
      if i == min(#memory[mI],i) then
        userFrame.update(i - 1)
      else userFrame:Hide(); break end
    end
  else
    scroll = max(0,scroll - 24)
    local adjustedValue = scroll / maxScroll * maxUsers
    mainFrameScroll(adjustedValue,true,true)
  end
end

function checkID(m)
  if m then
    m.owned = true
    if mI == 3 then
      for j,child in ipairs(memory[3]) do
        if child.uid == m.uid then
          if settings.hideOwned then removeAt(j)
          else child.owned = m.owned; updateNote(child,nil,true) end
          titleH[2] = titleH[2] + 1
          local title = string.format("%s (%d/%d)",titleH[1],titleH[2],titleH[3])
          mainFrameHeaderTitle:SetText(title)
          break
        end
      end
    end
    print("|cffFFC000混搭收藏單: |cffFFFFFF你剛收集到了 "..m.itemLink)
    PlaySoundFile("Interface\\AddOns\\TroveTally\\Assets\\done.ogg","Master")
  end
end

local links = {}
links.i = 1
local function addLink(link)
  links[links.i] = link
  local i = links.i
  links.i = (links.i % 20) + 1
  return i
end

local firstTime = true
local main = CreateFrame("Frame")

local lootTimer = nil
local lootItems = {}
local function lootUpdate()
  local time = GetServerTime()
  if time >= lootTimer then
    for _,item in ipairs(lootItems) do print(item) end
    lootTimer = nil
    lootItems = {}
    main:SetScript("OnUpdate",nil)
  end
end

local needToLoad = {}
for i = 1,C_AddOns.GetNumAddOns() do
  local loaded,finished = C_AddOns.IsAddOnLoaded(i)
  if loaded and not finished then
    needToLoad[C_AddOns.GetAddOnInfo(i)] = true
  end
end

local function startLoading()
  myGUID = UnitGUID("player")
  populateSpec()
  loadDB(data,1,db.a)
  loadDB(data2,5,db.b)
  loadDB(data3,7,db.c)
  loadDB(data4,8,db.d)
  loadDB(data5,9,db.e)
  loadDB(data6,10,db.f)
  loadDB(data7,12,db.g)
  loadDB(data8,13,db.h)
  loadDB(data9,15,db.i)
  loadDB(data10,16,db.j)
  loadDB(data11,17,db.k)
  loadDBNew(18)
  loadDBNew(19)
  loadDBNew(20)
  loadDBNew(21)
  --Remix: Legion
  if tocversion >= 110205 then
    for i = 23, 35 do
      if i < 30 or i > 32 then loadDBNew(i) end
    end
  end

  for i = 1,15 do
    local userFrame = createUserFrame((i - 1) * -24)
    if i <= #memory[mI] then
      userFrame.update(i - 1)
    else
      userFrame:Hide()
    end
  end
  MerchantFrame:HookScript("OnShow",openMerchant)
  hooksecurefunc("SetMerchantFilter",openMerchant)
  hooksecurefunc("MerchantFrame_UpdateMerchantInfo",updateMerchant)
end

local function addNotification(arg1,arg2,m,id)
  local check = true
  local color = arg1:match("|c(.-)|")
  local link = arg1:match("|c.-|r")
  local sub,owned
  if m then sub = m.s; owned = m.owned
  else
    sub = C_TransmogCollection.GetItemInfo(id) and getType(select(12,C_Item.GetItemInfo(id))) or nil
    owned = C_TransmogCollection.PlayerHasTransmog(id)
  end
  if canLearn[settings.trade == 1 and 14 or playerClass.index][sub] ~= nil and not owned and (color == "ff0070dd" or color == "ffa335ee") then
    local whisper = "|cffFF80FF|Haddon:TroveTally:"..addLink(link)..":"..arg2.."|h[密他詢問是否願意交易?]|h|r"
    local message = "|cffFFC000混搭收藏單: |cffFFFFFF"..(arg2:match("(.-)%-") or arg2).." 已收集了未知塑形 "..link..". "..whisper
    if settings.instant then print(message)
    else
      if lootTimer == nil then
        lootTimer = GetServerTime() + 5
        check = false
        main:SetScript("OnUpdate",lootUpdate)
      end
      table.insert(lootItems,message)
    end
  end
  if check and lootTimer ~= nil then lootTimer = GetServerTime() + 5 end
end

main:RegisterEvent("ADDON_LOADED")
main:RegisterEvent("FIRST_FRAME_RENDERED")
main:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
main:RegisterEvent("GET_ITEM_INFO_RECEIVED")
main:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
main:RegisterEvent("NEW_MOUNT_ADDED")
main:RegisterEvent("NEW_TOY_ADDED")
main:RegisterEvent("HEIRLOOMS_UPDATED")
main:RegisterEvent("NEW_PET_ADDED")
main:RegisterEvent("CHAT_MSG_LOOT")
main:SetScript("OnEvent",function(self,event,arg1,arg2,arg3,...)
  if event == "ADDON_LOADED" and needToLoad[arg1] then
    if arg1 == "TroveTally" then
      iconDegrees = iconDegrees or 45
      settings = settings or {hideOwned = false,hideIcon = false,hideMerchant = true}
      if settings.hideMerchant == nil then settings.hideMerchant = true end
      if settings.trade == nil or settings.trade == true then settings.trade = 1 end
      if settings.instant == nil then settings.instant = false end
      if settings.custom == nil then settings.custom = false end
      if settings.hideUnobt == nil then settings.hideUnobt = false end
      if settings.unlisted == nil then settings.unlisted = false end
      if settings.hideKnown == nil then settings.hideKnown = false end
      --if settings.hideIcon then iconButton:Hide() end
      memory[4][1] = {itemID = nil,text = (settings.custom == false) and "已停用" or settings.custom,name = "自訂訊息",specID = -13,uid = uid()}
      memory[4][2] = {itemID = nil,text = state[settings.instant],name = "即時通知",specID = -12,uid = uid()}
      memory[4][3] = {itemID = nil,text = state[settings.unlisted],name = "通知未列出的物品",specID = -17,uid = uid()}
      memory[4][4] = {itemID = nil,text = state[settings.trade],name = "可交易拾取通知",specID = -8,uid = uid()}
      memory[4][5] = {itemID = nil,text = state[settings.hideIcon],name = "隱藏小地圖按鈕",specID = -5,uid = uid()}
      memory[4][6] = {itemID = nil,text = state[settings.hideMerchant],name = "在商人介面隱藏已收集",specID = -7,uid =uid()}
      memory[4][7] = {itemID = nil,text = state[settings.hideUnobt],name = "隱藏無法取得",specID = -16,uid = uid()}
      memory[4][8] = {itemID = nil,text = state[settings.hideKnown],name = "隱藏已知塑形",specID = -22,uid = uid()}
      memory[4][9] = {itemID = nil,text = state[settings.hideOwned],name = "隱藏已收集",specID = -4,uid = uid()}
      local LibDBIcon = LibStub("LibDBIcon-1.0")
      LibDBIcon:Register("TroveTally",LDB,dbTT.minimap)
      buttonTT = LibDBIcon:GetMinimapButton("TroveTally")
      for _,region in ipairs({buttonTT:GetRegions()}) do
        if region:GetObjectType() == "Texture" and region:GetTexture() ~= 136477 then region:Hide() end
      end
      buttonTT.texture = buttonTT:CreateTexture(nil,"BACKGROUND")
      buttonTT.texture:SetTexture("Interface\\AddOns\\TroveTally\\Assets\\icon")
      buttonTT.texture:SetSize(34,34)
      buttonTT.texture:SetTexCoord(0,0.625,0,0.625)
      buttonTT.texture:SetPoint("CENTER")
    end
    needToLoad[arg1] = nil
    if #needToLoad == 0 and not firstTime then startLoading() end
  elseif event == "FIRST_FRAME_RENDERED" and firstTime then
    firstTime = false
    if #needToLoad == 0 then startLoading() end
  elseif event == "TRANSMOG_COLLECTION_SOURCE_ADDED" then
    local sourceInfo = C_TransmogCollection.GetSourceInfo(arg1)
    if sourceInfo then checkID(flags.item[sourceInfo.itemID]) end
  --elseif event == "GET_ITEM_INFO_RECEIVED" then gotdata(arg1)
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then checkID(flags.spell[arg3])
  elseif event == "NEW_MOUNT_ADDED" then checkID(flags.mount[arg1])
  elseif event == "NEW_TOY_ADDED" then checkID(flags.item[arg1])
  elseif event == "HEIRLOOMS_UPDATED" and arg2 == "NEW" then checkID(flags.item[arg1])
  elseif event == "NEW_PET_ADDED" then
    local speciesID = C_PetJournal.GetPetInfoByPetID(arg1)
    if C_PetJournal.GetNumCollectedInfo(speciesID) == 1 then checkID(flags.pet[speciesID]) end
  elseif event == "CHAT_MSG_LOOT" then
    if settings.trade and select(9,...) ~= myGUID then
      local id = tonumber(arg1:match("item:(%d+):"))
      local m = flags.item[id]
      if m and m.s then addNotification(arg1,arg2,m); return end
      if not settings.unlisted then if lootTimer ~= nil then lootTimer = GetServerTime() + 5 end return end
      local item = Item:CreateFromItemID(id)
      item:ContinueOnItemLoad(function() addNotification(arg1,arg2,nil,id) end)
    end
  end
end)

hooksecurefunc("SetItemRef",function(link)
	local linkType,addon,i,player = strsplit(":",link)
	if linkType == "addon" and addon == "TroveTally" then
    local message = (settings.custom == false) and default or settings.custom
    SendChatMessage(string.gsub(message,"%$",links[tonumber(i)]),"WHISPER",nil,player)
	end
end)