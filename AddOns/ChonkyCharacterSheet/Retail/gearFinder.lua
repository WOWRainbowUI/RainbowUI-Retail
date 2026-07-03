local addonName, ns = ...
local CCS = ns.CCS

if CCS.CurrentVersion ~= CCS.RETAIL then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

local module = {
    Name = "gearFinder",
    CompatibleVersions = { CCS.RETAIL },
}

CCS.Modules[module.Name] = module

-----------------------------------------
-- ITEM LEVEL DELTA BONUS IDS (so I don't lose them)
-- https://www.raidbots.com/static/data/live/bonuses.json
-- https://www.raidbots.com/static/data/ptr/bonuses.json
-----------------------------------------

CCS.AscendantVoidforgedBonusIDs = {
    [13653] = {tier = "Hero", icon = "Interface\\ICONS\\INV_1205_Voidforge_SovereignVoidcores_CosmicVoid.blp",},
    [13654] = {tier = "Myth", icon = "Interface\\ICONS\\INV_1205_Voidforge_SovereignVoidcores_CosmicVoid.blp",},
}

function CCS.GetAscendantVoidforgedTag(link)
    local parsed = CCS.parseItemLink(link)
    if not parsed or not parsed.bonusIDs then return nil end

    for _, bonusID in ipairs(parsed.bonusIDs) do
        local data = CCS.AscendantVoidforgedBonusIDs[bonusID]
        if data then
            return data.icon, data.tier
        end
    end

    return nil
end

-- We will likely change this over to a calculation instead of a static table.
CCS.iLvlDeltaBonusIDs = {
    [-100] = 1372, [-99] = 1373, [-98] = 1374, [-97] = 1375, [-96] = 1376, [-95] = 1377, [-94] = 1378, [-93] = 1379, [-92] = 1380, [-91] = 1381, [-90] = 1382, [-89] = 1383, [-88] = 1384, [-87] = 1385, [-86] = 1386, [-85] = 1387, [-84] = 1388, [-83] = 1389, [-82] = 1390, [-81] = 1391, [-80] = 1392, [-79] = 1393, [-78] = 1394, [-77] = 1395, [-76] = 1396, [-75] = 1397, [-74] = 1398, [-73] = 1399, [-72] = 1400, [-71] = 1401, [-70] = 1402, [-69] = 1403, [-68] = 1404, [-67] = 1405, [-66] = 1406, [-65] = 1407, [-64] = 1408, [-63] = 1409, [-62] = 1410, [-61] = 1411, [-60] = 1412, [-59] = 1413, [-58] = 1414, [-57] = 1415, [-56] = 1416, [-55] = 1417, [-54] = 1418, [-53] = 1419, [-52] = 1420, [-51] = 1421,
    [-50] = 1422, [-49] = 1423, [-48] = 1424, [-47] = 1425, [-46] = 1426, [-45] = 1427, [-44] = 1428, [-43] = 1429, [-42] = 1430, [-41] = 1431, [-40] = 1432, [-39] = 1433, [-38] = 1434, [-37] = 1435, [-36] = 1436, [-35] = 1437, [-34] = 1438, [-33] = 1439, [-32] = 1440, [-31] = 1441, [-30] = 1442, [-29] = 1443, [-28] = 1444, [-27] = 1445, [-26] = 1446, [-25] = 1447, [-24] = 1448, [-23] = 1449, [-22] = 1450, [-21] = 1451, [-20] = 1452, [-19] = 1453, [-18] = 1454, [-17] = 1455, [-16] = 1456, [-15] = 1457, [-14] = 1458, [-13] = 1459, [-12] = 1460, [-11] = 1461, [-10] = 1462, [-9] = 1463, [-8] = 1464, [-7] = 1465, [-6] = 1466, [-5] = 1467, [-4] = 1468, [-3] = 1469, [-2] = 1470, [-1] = 1471,
    [1] = 1473, [2] = 1474, [3] = 1475, [4] = 1476, [5] = 1477, [6] = 1478, [7] = 1479, [8] = 1480, [9] = 1481, [10] = 1482, [11] = 1483, [12] = 1484, [13] = 1485, [14] = 1486, [15] = 1487, [16] = 1488, [17] = 1489, [18] = 1490, [19] = 1491, [20] = 1492, [21] = 1493, [22] = 1494, [23] = 1495, [24] = 1496, [25] = 1497, [26] = 1498, [27] = 1499, [28] = 1500, [29] = 1501, [30] = 1502, [31] = 1503, [32] = 1504, [33] = 1505, [34] = 1506, [35] = 1507, [36] = 1508, [37] = 1509, [38] = 1510, [39] = 1511, [40] = 1512, [41] = 1513, [42] = 1514, [43] = 1515, [44] = 1516, [45] = 1517, [46] = 1518, [47] = 1519, [48] = 1520, [49] = 1521, [50] = 1522,
    [51] = 1523, [52] = 1524, [53] = 1525, [54] = 1526, [55] = 1527, [56] = 1528, [57] = 1529, [58] = 1530, [59] = 1531, [60] = 1532, [61] = 1533, [62] = 1534, [63] = 1535, [64] = 1536, [65] = 1537, [66] = 1538, [67] = 1539, [68] = 1540, [69] = 1541, [70] = 1542, [71] = 1543, [72] = 1544, [73] = 1545, [74] = 1546, [75] = 1547, [76] = 1548, [77] = 1549, [78] = 1550, [79] = 1551, [80] = 1552, [81] = 1553, [82] = 1554, [83] = 1555, [84] = 1556, [85] = 1557, [86] = 1558, [87] = 1559, [88] = 1560, [89] = 1561, [90] = 1562, [91] = 1563, [92] = 1564, [93] = 1565, [94] = 1566, [95] = 1567, [96] = 1568, [97] = 1569, [98] = 1570, [99] = 1571, [100] = 1572,
    [101] = 1573, [102] = 1574, [103] = 1575, [104] = 1576, [105] = 1577, [106] = 1578, [107] = 1579, [108] = 1580, [109] = 1581, [110] = 1582, [111] = 1583, [112] = 1584, [113] = 1585, [114] = 1586, [115] = 1587, [116] = 1588, [117] = 1589, [118] = 1590, [119] = 1591, [120] = 1592, [121] = 1593, [122] = 1594, [123] = 1595, [124] = 1596, [125] = 1597, [126] = 1598, [127] = 1599, [128] = 1600, [129] = 1601, [130] = 1602, [131] = 1603, [132] = 1604, [133] = 1605, [134] = 1606, [135] = 1607, [136] = 1608, [137] = 1609, [138] = 1610, [139] = 1611, [140] = 1612, [141] = 1613, [142] = 1614, [143] = 1615, [144] = 1616, [145] = 1617, [146] = 1618, [147] = 1619, [148] = 1620, [149] = 1621, [150] = 1622,
    [151] = 1623, [152] = 1624, [153] = 1625, [154] = 1626, [155] = 1627, [156] = 1628, [157] = 1629, [158] = 1630, [159] = 1631, [160] = 1632, [161] = 1633, [162] = 1634, [163] = 1635, [164] = 1636, [165] = 1637, [166] = 1638, [167] = 1639, [168] = 1640, [169] = 1641, [170] = 1642, [171] = 1643, [172] = 1644, [173] = 1645, [174] = 1646, [175] = 1647, [176] = 1648, [177] = 1649, [178] = 1650, [179] = 1651, [180] = 1652, [181] = 1653, [182] = 1654, [183] = 1655, [184] = 1656, [185] = 1657, [186] = 1658, [187] = 1659, [188] = 1660, [189] = 1661, [190] = 1662, [191] = 1663, [192] = 1664, [193] = 1665, [194] = 1666, [195] = 1667, [196] = 1668, [197] = 1669, [198] = 1670, [199] = 1671, [200] = 1672,
    [201] = 3130, [202] = 3131, [203] = 3132, [204] = 3133, [205] = 3134, [206] = 3135, [207] = 3136, [208] = 3137, [209] = 3138, [210] = 3139, [211] = 3140, [212] = 3141, [213] = 3142, [214] = 3143, [215] = 3144, [216] = 3145, [217] = 3146, [218] = 3147, [219] = 3148, [220] = 3149, [221] = 3150, [222] = 3151, [223] = 3152, [224] = 3153, [225] = 3154, [226] = 3155, [227] = 3156, [228] = 3157, [229] = 3158, [230] = 3159, [231] = 3160, [232] = 3161, [233] = 3162, [234] = 3163, [235] = 3164, [236] = 3165, [237] = 3166, [238] = 3167, [239] = 3168, [240] = 3169, [241] = 3170, [242] = 3171, [243] = 3172, [244] = 3173, [245] = 3174, [246] = 3175, [247] = 3176, [248] = 3177, [249] = 3178, [250] = 3179,
    [251] = 3180, [252] = 3181, [253] = 3182, [254] = 3183, [255] = 3184, [256] = 3185, [257] = 3186, [258] = 3187, [259] = 3188, [260] = 3189, [261] = 3190, [262] = 3191, [263] = 3192, [264] = 3193, [265] = 3194, [266] = 3195, [267] = 3196, [268] = 3197, [269] = 3198, [270] = 3199, [271] = 3200, [272] = 3201, [273] = 3202, [274] = 3203, [275] = 3204, [276] = 3205, [277] = 3206, [278] = 3207, [279] = 3208, [280] = 3209, [281] = 3210, [282] = 3211, [283] = 3212, [284] = 3213, [285] = 3214, [286] = 3215, [287] = 3216, [288] = 3217, [289] = 3218, [290] = 3219, [291] = 3220, [292] = 3221, [293] = 3222, [294] = 3223, [295] = 3224, [296] = 3225, [297] = 3226, [298] = 3227, [299] = 3228, [300] = 3229,
    [301] = 3230, [302] = 3231, [303] = 3232, [304] = 3233, [305] = 3234, [306] = 3235, [307] = 3236, [308] = 3237, [309] = 3238, [310] = 3239, [311] = 3240, [312] = 3241, [313] = 3242, [314] = 3243, [315] = 3244, [316] = 3245, [317] = 3246, [318] = 3247, [319] = 3248, [320] = 3249, [321] = 3250, [322] = 3251, [323] = 3252, [324] = 3253, [325] = 3254, [326] = 3255, [327] = 3256, [328] = 3257, [329] = 3258, [330] = 3259, [331] = 3260, [332] = 3261, [333] = 3262, [334] = 3263, [335] = 3264, [336] = 3265, [337] = 3266, [338] = 3267, [339] = 3268, [340] = 3269, [341] = 3270, [342] = 3271, [343] = 3272, [344] = 3273, [345] = 3274, [346] = 3275, [347] = 3276, [348] = 3277, [349] = 3278, [350] = 3279,
    [351] = 3280, [352] = 3281, [353] = 3282, [354] = 3283, [355] = 3284, [356] = 3285, [357] = 3286, [358] = 3287, [359] = 3288, [360] = 3289, [361] = 3290, [362] = 3291, [363] = 3292, [364] = 3293, [365] = 3294, [366] = 3295, [367] = 3296, [368] = 3297, [369] = 3298, [370] = 3299, [371] = 3300, [372] = 3301, [373] = 3302, [374] = 3303, [375] = 3304, [376] = 3305, [377] = 3306, [378] = 3307, [379] = 3308, [380] = 3309, [381] = 3310, [382] = 3311, [383] = 3312, [384] = 3313, [385] = 3314, [386] = 3315, [387] = 3316, [388] = 3317, [389] = 3318, [390] = 3319, [391] = 3320, [392] = 3321, [393] = 3322, [394] = 3323, [395] = 3324, [396] = 3325, [397] = 3326, [398] = 3327, [399] = 3328, [400] = 3329,
    [401] = 9455, [402] = 9456, [403] = 9457, [404] = 9458, [405] = 9459, [406] = 9460, [407] = 9461, [408] = 9464, [409] = 9465, [410] = 9466, [411] = 9834, [412] = 9835, [413] = 9836, [414] = 9837, [415] = 9838, [416] = 9839, [417] = 9840, [418] = 9841, [419] = 9842, [420] = 9843, [421] = 9844, [422] = 9845, [423] = 9846, [424] = 9847, [425] = 9848, [426] = 9849, [427] = 9850, [428] = 9851, [429] = 9852, [430] = 9853, [431] = 9874, [432] = 9875, [433] = 9876, [434] = 9877, [435] = 9878, [436] = 9879, [437] = 9880, [438] = 9881, [439] = 9882, [440] = 9883, [441] = 9884, [442] = 9885, [443] = 9886, [444] = 9887, [445] = 9888, [446] = 9889, [447] = 9890, [448] = 9891, [449] = 9892, [450] = 9893,
    [451] = 9918, [452] = 9919, [453] = 9920, [454] = 9921, [455] = 9922, [456] = 9923, [457] = 9924, [458] = 9925, [459] = 9926, [460] = 9927, [461] = 9928, [462] = 9929, [463] = 9930, [464] = 9931, [465] = 9932, [466] = 9933, [467] = 9934, [468] = 9935, [469] = 9936, [470] = 9937, [471] = 9938, [472] = 9939, [473] = 9940, [474] = 9941, [475] = 9942, [476] = 9943, [477] = 9944, [478] = 9945, [479] = 9946, [480] = 9947, [481] = 9948, [482] = 9949, [483] = 9950, [484] = 9951, [485] = 9952, [486] = 9953, [487] = 9954, [488] = 9955, [489] = 9956, [490] = 9957, [491] = 9958, [492] = 9959, [493] = 9960, [494] = 9961, [495] = 9962, [496] = 9963, [497] = 9964, [498] = 9965, [499] = 9966, [500] = 9967,
    [501] = 9968, [502] = 9969, [503] = 9970, [504] = 9971, [505] = 9972, [506] = 9973, [507] = 9974, [508] = 9975, [509] = 9976, [510] = 9977, [511] = 9978, [512] = 9979, [513] = 9980, [514] = 9981, [515] = 9982, [516] = 9983, [517] = 9984, [518] = 9985, [519] = 9986, [520] = 9987, [521] = 9988, [522] = 9989, [523] = 9990, [524] = 9991, [525] = 9992, [526] = 9993, [527] = 9994, [528] = 9995, [529] = 9996, [530] = 9997, [531] = 9998, [532] = 9999, [533] = 10000, [534] = 10001, [535] = 10002, [536] = 10003, [537] = 10004, [538] = 10005, [539] = 10006, [540] = 10007, [541] = 10008, [542] = 10009, [543] = 10010, [544] = 10011, [545] = 10012, [546] = 10013, [547] = 10014, [548] = 10015, [549] = 10016, [550] = 10017,
    [551] = 10018, [552] = 10019, [553] = 10020, [554] = 10021, [555] = 10022, [556] = 10023, [557] = 10024, [558] = 10025, [559] = 10026, [560] = 10027, [561] = 10028, [562] = 10029, [563] = 10030, [564] = 10031, [565] = 10032, [566] = 10033, [567] = 10034, [568] = 10035, [569] = 10036, [570] = 10037, [571] = 10038, [572] = 10039, [573] = 10040, [574] = 10041, [575] = 10042, [576] = 10043, [577] = 10044, [578] = 10045, [579] = 10046, [580] = 10047, [581] = 10048, [582] = 10049, [583] = 10050, [584] = 10051, [585] = 10052, [586] = 10053, [587] = 10054, [588] = 10055, [589] = 10056, [590] = 10057, [591] = 10058, [592] = 10059, [593] = 10060, [594] = 10061, [595] = 10062, [596] = 10063, [597] = 10064, [598] = 10065, [599] = 10066, [600] = 10067,
    [601] = 11341, [602] = 11342, [603] = 11343, [604] = 11344, [605] = 11345, [606] = 11346, [607] = 11347, [608] = 11348, [609] = 11349, [610] = 11350, [611] = 11351, [612] = 11352, [613] = 11353, [614] = 11354, [615] = 11355, [616] = 11356, [617] = 11357, [618] = 11358, [619] = 11359, [620] = 11360, [621] = 11361, [622] = 11362, [623] = 11363, [624] = 11364, [625] = 11365, [626] = 11366, [627] = 11367, [628] = 11368, [629] = 11369, [630] = 11370, [631] = 11371, [632] = 11372, [633] = 11373, [634] = 11374, [635] = 11375, [636] = 11376, [637] = 11377, [638] = 11378, [639] = 11379, [640] = 11380, [641] = 11381, [642] = 11382, [643] = 11383, [644] = 11384, [645] = 11385, [646] = 11386, [647] = 11387, [648] = 11388, [649] = 11389, [650] = 11390,
    [651] = 11391, [652] = 11392, [653] = 11393, [654] = 11394, [655] = 11395, [656] = 11396, [657] = 11397, [658] = 11398, [659] = 11399, [660] = 11400, [661] = 11401, [662] = 11402, [663] = 11403, [664] = 11404, [665] = 11405, [666] = 11406, [667] = 11407, [668] = 11408, [669] = 11409, [670] = 11410, [671] = 11411, [672] = 11412, [673] = 11413, [674] = 11414, [675] = 11415, [676] = 11416, [677] = 11417, [678] = 11418, [679] = 11419, [680] = 11420, [681] = 11421, [682] = 11422, [683] = 11423, [684] = 11424, [685] = 11425, [686] = 11426, [687] = 11427, [688] = 11428, [689] = 11429, [690] = 11430, [691] = 11431, [692] = 11432, [693] = 11433, [694] = 11434, [695] = 11435, [696] = 11436, [697] = 11437, [698] = 11438, [699] = 11439, [700] = 11440,
    [701] = 11441, [702] = 11442, [703] = 11443, [704] = 11444, [705] = 11445, [706] = 11446, [707] = 11447, [708] = 11448, [709] = 11449, [710] = 11450, [711] = 11451, [712] = 11452, [713] = 11453, [714] = 11454, [715] = 11455, [716] = 11456, [717] = 11457, [718] = 11458, [719] = 11459, [720] = 11460, [721] = 11461, [722] = 11462, [723] = 11463, [724] = 11464, [725] = 11465, [726] = 11466, [727] = 11467, [728] = 11468, [729] = 11469, [730] = 11470, [731] = 11471, [732] = 11472, [733] = 11473, [734] = 11474, [735] = 11475, [736] = 11476, [737] = 11477, [738] = 11478, [739] = 11479, [740] = 11480, [741] = 11481, [742] = 11482, [743] = 11483, [744] = 11484, [745] = 11485, [746] = 11486, [747] = 11487, [748] = 11488, [749] = 11489, [750] = 11490,
    [751] = 11491, [752] = 11492, [753] = 11493, [754] = 11494, [755] = 11495, [756] = 11496, [757] = 11497, [758] = 11498, [759] = 11499, [760] = 11500, [761] = 11501, [762] = 11502, [763] = 11503, [764] = 11504, [765] = 11505, [766] = 11506, [767] = 11507, [768] = 11508, [769] = 11509, [770] = 11510, [771] = 11511, [772] = 11512, [773] = 11513, [774] = 11514, [775] = 11515, [776] = 11516, [777] = 11517, [778] = 11518, [779] = 11519, [780] = 11520, [781] = 11521, [782] = 11522, [783] = 11523, [784] = 11524, [785] = 11525, [786] = 11526, [787] = 11527, [788] = 11528, [789] = 11529, [790] = 11530, [791] = 11531, [792] = 11532, [793] = 11533, [794] = 11534, [795] = 11535, [796] = 11536, [797] = 11537, [798] = 11538, [799] = 11539, [800] = 11540,
    [801] = 11541, [802] = 11542, [803] = 11543, [804] = 11544, [805] = 11545, [806] = 11546, [807] = 11547, [808] = 11548, [809] = 11549, [810] = 11550, [811] = 11551, [812] = 11552, [813] = 11553, [814] = 11554, [815] = 11555, [816] = 11556, [817] = 11557, [818] = 11558, [819] = 11559, [820] = 11560, [821] = 11561, [822] = 11562, [823] = 11563, [824] = 11564, [825] = 11565, [826] = 11566, [827] = 11567, [828] = 11568, [829] = 11569, [830] = 11570, [831] = 11571, [832] = 11572, [833] = 11573, [834] = 11574, [835] = 11575, [836] = 11576, [837] = 11577, [838] = 11578, [839] = 11579, [840] = 11580, [841] = 11581, [842] = 11582, [843] = 11583, [844] = 11584, [845] = 11585, [846] = 11586, [847] = 11587, [848] = 11588, [849] = 11589, [850] = 11590,
    [851] = 11591, [852] = 11592, [853] = 11593, [854] = 11594, [855] = 11595, [856] = 11596, [857] = 11597, [858] = 11598, [859] = 11599, [860] = 11600, [861] = 11601, [862] = 11602, [863] = 11603, [864] = 11604, [865] = 11605, [866] = 11606, [867] = 11607, [868] = 11608, [869] = 11609, [870] = 11610, [871] = 11611, [872] = 11612, [873] = 11613, [874] = 11614, [875] = 11615, [876] = 11616, [877] = 11617, [878] = 11618, [879] = 11619, [880] = 11620, [881] = 11621, [882] = 11622, [883] = 11623, [884] = 11624, [885] = 11625, [886] = 11626, [887] = 11627, [888] = 11628, [889] = 11629, [890] = 11630, [891] = 11631, [892] = 11632, [893] = 11633, [894] = 11634, [895] = 11635, [896] = 11636, [897] = 11637, [898] = 11638, [899] = 11639, [900] = 11640,
	-- Did Blizzard seriously not have a better way of doing this?
}

-----------------------------------------
-- Build the item string based on ID, track, and target ilvl
-- Allows us to show item links properly.
-- Explicitly not adding "Heroic", "Mythic", "LFR", "Mythic+" to the link.
-----------------------------------------

function CCS.BuilditemString(itemID, trackName, targetIlvl, bossID)
    if not itemID or not trackName or not targetIlvl or not bossID then
        return "item:5263"
    end

	local track = CCS.Season.upgradeTracks[trackName]

    if not track then
        return "item:" .. itemID
    end

    local bonusIds = {}
    local _, _, baseIlvl = C_Item.GetDetailedItemLevelInfo(itemID)

    if not baseIlvl then
        C_Item.RequestLoadItemDataByID(itemID)
        return nil
    end

    ---------------------------------------------------------
    -- Determine item class/subclass and equip location
    ---------------------------------------------------------
    local name, link, quality, ilvl, req, classStr, subclassStr, stack, equipLoc =
        C_Item.GetItemInfo(itemID)

    local itemClassID, itemSubClassID = select(12, GetItemInfo(itemID))

    -- Void-Ascended eligibility:
    -- Weapons OR Trinkets only
    local isVoidAscendedEligible =
        (itemClassID == 2) or (equipLoc == "INVTYPE_TRINKET")

    ---------------------------------------------------------
    -- Rotmire special rule: +9 ilvl bump
    ---------------------------------------------------------
    local originalTarget = targetIlvl

    if bossID == 2711 then
        targetIlvl = targetIlvl + 9
    end

    ---------------------------------------------------------
    -- If this ilvl corresponds to Void-Ascended tier
    -- but the item is NOT eligible → downgrade by 9
    ---------------------------------------------------------
    local isVoidAscendedTier = false
    if trackName == "Hero" and targetIlvl == 285 then
        isVoidAscendedTier = true
    elseif trackName == "Myth" and targetIlvl == 298 then
        isVoidAscendedTier = true
    end

    if isVoidAscendedTier and not isVoidAscendedEligible then
        targetIlvl = targetIlvl - 9
    end

    ---------------------------------------------------------
    -- Compute bonus IDs
    ---------------------------------------------------------
    local diff = targetIlvl - baseIlvl
    local levelBonus = CCS.iLvlDeltaBonusIDs[diff]
    local trackBonus = track.bonusByIlvl[targetIlvl]

    if levelBonus then table.insert(bonusIds, levelBonus) end
    if trackBonus then table.insert(bonusIds, trackBonus) end

    -- Epic quality bonus
    table.insert(bonusIds, 1674)

    ---------------------------------------------------------
    -- Rotmire Sporefused override (AFTER eligibility logic)
    ---------------------------------------------------------
    if bossID == 2711 then
        if trackName == "Myth" then
            table.insert(bonusIds, 13786)
        elseif trackName == "Hero" then
            table.insert(bonusIds, 13787)
        else
            table.insert(bonusIds, 13788)
        end
    end

    ---------------------------------------------------------
    -- Build final item string
    ---------------------------------------------------------
    local bonusString = table.concat(bonusIds, ":")
    local specID = GetSpecializationInfo(GetSpecialization())
    local itemstring = string.format(
        "item:%d:0:0:0:0:0:0:0:%d:%d:0:0:%d:%s:0",
        itemID, UnitLevel("player"), specID, #bonusIds, bonusString
    )
    return itemstring
end

-- ============================================================
--  Unified Stat Extractor for Season Gear
--  Returns primary + secondary stats for a given item link
-- ============================================================
local CCS_PrimaryScanTT

function CCS.ExtractPrimaryStats(link)
    if not CCS_PrimaryScanTT then
        CCS_PrimaryScanTT = CreateFrame("GameTooltip", "CCS_PrimaryScanTT", nil, "GameTooltipTemplate")
        CCS_PrimaryScanTT:SetOwner(UIParent, "ANCHOR_NONE")
    end

    local tt = CCS_PrimaryScanTT
    tt:ClearLines()
    tt:SetHyperlink(link)

    local out = { STR = 0, AGI = 0, INT = 0 }

    for i = 1, tt:NumLines() do
        local line = _G["CCS_PrimaryScanTTTextLeft"..i]
        if line then
            local text = line:GetText()
            if text then
                text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
                           :gsub("|r", "")
                           :gsub(",", "")
                           :gsub("%s+", " ")
                           :gsub("^%s+", "")
                           :gsub("%s+$", "")

                local value, keyword = text:match("^%+(%d+)%s+(.+)$")
                if value and keyword then
                    value = tonumber(value)

                    local mapped = CCS.PRIMARY_KEYWORDS[keyword]
                    if mapped then
                        out[mapped] = value
                    else
                        local lower = keyword:lower()
                        for k, v in pairs(CCS.PRIMARY_KEYWORDS) do
                            if lower:find(k:lower(), 1, true) then
                                out[v] = value
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return out
end

function CCS.GetItemSecondaryStats(itemID, link)
    if not link then
        -- Build a basic link if only itemID was provided
        link = "item:" .. itemID
    end

    ------------------------------------------------------------
    -- Primary Stats (via lightweight tooltip scan)
    ------------------------------------------------------------
    local prim = CCS.ExtractPrimaryStats(link)

    ------------------------------------------------------------
    -- Secondary Stats (via Blizzard API)
    ------------------------------------------------------------
    local sec = C_Item.GetItemStats(link) or {}
	
    local out = {
        STR = prim.STR or 0,
        AGI = prim.AGI or 0,
        INT = prim.INT or 0,

        CRIT = sec["ITEM_MOD_CRIT_RATING_SHORT"] or 0,
        HASTE = sec["ITEM_MOD_HASTE_RATING_SHORT"] or 0,
        MASTERY = sec["ITEM_MOD_MASTERY_RATING_SHORT"] or 0,
        VERS = sec["ITEM_MOD_VERSATILITY"] or 0,
    }

    return out
end

function CCS:CreateLootHeader(parent, rowWidth, rowHeight, primaryStatText)
    local headerName = "CCS_LootHeader"
    local header = _G[headerName]

    if header then
        return header
    end

    header = CreateFrame("Frame", headerName, parent)
    header:SetSize(rowWidth, rowHeight)

    -------------------------------------------------
    -- Helper: Create text label
    -------------------------------------------------
	local function CreateLabel(text, anchor, xOff, width, sortBy)
		local fs = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		fs:SetWidth(width)
		fs:SetJustifyH("LEFT")
		fs:SetText(text)

		fs:SetFont(option("fontname_gf_header") or CCS.fontname, option("fontsize_gf_header") or 14, CCS.textoutline)
		fs:SetTextColor(unpack(option("fontcolor_gf_header") or {1,1,1,1}))
		
		if option("showfontshadow") then
			fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end

		fs:EnableMouse(true)
		fs:SetScript("OnMouseDown", function()
			local currentSort = ccsgf_sf.currentSortBy or "NAME"
			local currentDir  = ccsgf_sf.currentDir    or "Descending"

			local newSortBy = sortBy
			local newDir

			if currentSort == newSortBy then
				-- toggle direction
				if currentDir == "Ascending" then
					newDir = "Descending"
				else
					newDir = "Ascending"
				end
			else
				-- new column → default direction
				newDir = "Descending"
			end

			ccsgf_sf.currentSortBy = newSortBy
			ccsgf_sf.currentDir    = newDir

			PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
			CCS:ApplyLootFilters(newSortBy, newDir)
		end)

		return fs
	end

    -------------------------------------------------
    -- Helper: Create icon header (for crit/haste/mastery/vers)
    -------------------------------------------------
	local function CreateIconHeader(texture, anchor, xOff, sortBy, tooltipText)
		local btn = CreateFrame("Button", nil, header)
		btn:SetSize(24, 24)

		local icon = btn:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetTexture(texture)

		btn:SetScript("OnMouseDown", function()
			local currentSort = ccsgf_sf.currentSortBy or "NAME"
			local currentDir  = ccsgf_sf.currentDir    or "Descending"

			local newSortBy = sortBy
			local newDir

			if currentSort == newSortBy then
				if currentDir == "Ascending" then
					newDir = "Descending"
				else
					newDir = "Ascending"
				end
			else
				newDir = "Descending"
			end

			ccsgf_sf.currentSortBy = newSortBy
			ccsgf_sf.currentDir    = newDir

			PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
			CCS:ApplyLootFilters(newSortBy, newDir)
		end)

		btn:SetScript("OnEnter", function(self)
			if tooltipText then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:AddLine(tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end
		end)

		btn:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		return btn
	end


    -------------------------------------------------
    -- Header Title
    -------------------------------------------------
    header.title = CreateLabel(string.format(EXPANSION_SEASON_NAME, EXPANSION_NAME11, CCS.CurrentSeasonNumber), header, 0, 20*rowHeight, "NAME")
	header.title:SetParent(ccsgf_sf)  -- move it to the shared side panel
	header.title:SetPoint("TOP", header, "TOP", 0, -20)
	header.title:SetJustifyH("CENTER")
    header.title:SetFont(option("fontname_gf_title") or CCS.fontname, option("fontsize_gf_title") or 18, CCS.textoutline)
	header.title:SetTextColor(unpack(option("fontcolor_gf_title") or {1,1,1,1}))
	header.title:EnableMouse(false)
	
    -------------------------------------------------
    -- Item label
    -------------------------------------------------
    header.item = CreateLabel(ITEMS, header, 4, 5*rowHeight, "NAME")
	--header.item:SetPoint("LEFT", header, "LEFT", 40, 0)

    -------------------------------------------------
    -- Primary stat label (text will be dynamic, based on what is selected)
	-- We are not really using this at the moment.  It is just laced in, in case I want it later.
    -------------------------------------------------
    header.primary = CreateLabel(primaryStatText or "Stat", header.item, 12, 35)
	header.primary:SetJustifyH("CENTER")
	header.primary:SetTextColor(0.1647, 0.9804, 0.7098, 1)
	header.primary:Hide()
    -------------------------------------------------
    -- Secondary stat icons
    -------------------------------------------------
    header.crit = CreateIconHeader("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\crit.png", header.primary, 7, "CRIT",ITEM_MOD_CRIT_RATING_SHORT)      -- Crit icon
    header.haste = CreateIconHeader("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\haste.png", header.crit, 7, "HASTE",ITEM_MOD_HASTE_RATING_SHORT)        -- Haste icon
    header.mastery = CreateIconHeader("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\mastery.png", header.haste, 7, "MASTERY",ITEM_MOD_MASTERY_RATING_SHORT)     -- Mastery icon
    header.vers = CreateIconHeader("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\versatility.png", header.mastery, 7, "VERS",STAT_VERSATILITY)      -- Vers icon
    -------------------------------------------------
    -- Source label (for raids/dungeons/etc.)
    -------------------------------------------------
    header.source = CreateLabel(L["Source"], header.vers, 10, 5 * rowHeight,"SOURCE")

    -------------------------------------------------
    -- Time to do some set points
    -------------------------------------------------
	header.item:SetPoint("BOTTOMLEFT", CCS_LootRow_1.iconFrame, "TOPRIGHT", 10, 15)
	header.primary:SetPoint("BOTTOM", CCS_LootRow_1.primary, "TOP", 0, 15)
	header.crit:SetPoint("BOTTOM", CCS_LootRow_1.crit, "TOP", 0, 15)
	header.haste:SetPoint("BOTTOM", CCS_LootRow_1.haste, "TOP", 0, 15)
	header.mastery:SetPoint("BOTTOM", CCS_LootRow_1.mastery, "TOP", 0, 15)
	header.vers:SetPoint("BOTTOM", CCS_LootRow_1.vers, "TOP", 0, 15)
	header.source:SetPoint("BOTTOMLEFT", CCS_LootRow_1.source, "TOPLEFT", 0, 15)

    return header
end

function CCS:CreateLootRow(index, parent, rowWidth, rowHeight)
    -- Unique global name for the row
    local rowName = "CCS_LootRow_" .. index

    -- Reuse if it already exists
    local row = _G[rowName]
    if row then
        return row
    end

    -------------------------------------------------
    -- Create the row frame
    -------------------------------------------------
    row = CreateFrame("Frame", rowName, parent)
    row:SetSize(rowWidth, rowHeight)

    -------------------------------------------------
    -- Alternating background (zebra striping)
    -------------------------------------------------
    row.bgAlt = row:CreateTexture(nil, "BACKGROUND", nil, 0)
    row.bgAlt:SetAllPoints()

    -- Even rows get a faint dark background
    if (index % 2 == 0) then
        row.bgAlt:SetColorTexture(.247, .247, .247, .6) 
    else
        row.bgAlt:SetColorTexture(.17, .17, .17, .4) 
    end

    -------------------------------------------------
    -- Hover highlight (on top of bgAlt)
    -------------------------------------------------
    row.bg = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.bg:SetAllPoints()
    row.bg:SetColorTexture(1, 1, 1, 0)

    row:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0.08)
    end)
    row:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0)
    end)

	-------------------------------------------------
	-- Item Icon
	-------------------------------------------------
	row.iconFrame = CreateFrame("Button", nil, row)
	row.iconFrame:SetSize(32, 32)
	row.iconFrame:SetPoint("LEFT", row, "LEFT", 4, 0)

	row.icon = row.iconFrame:CreateTexture(nil, "ARTWORK", nil, 5)
	row.icon:SetAllPoints()
	row.icon:SetTexture(134400)

	row.iconFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self:GetParent().hyperlink)
		GameTooltip:Show()
	end)

	row.iconFrame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	row.iconFrame:SetScript("OnMouseDown", function(self, button)
		local link = self:GetParent().hyperlink
		if not link then return end
		local _, itemLink = C_Item.GetItemInfo(link)

		if not itemLink then
			C_Item.RequestLoadItemDataByID(self:GetParent().itemID)
			return
		end
		if IsModifiedClick("CHATLINK") then
			ChatEdit_InsertLink(itemLink)
		elseif IsModifiedClick("DRESSUP") then
			DressUpItemLink(link)
		end
	end)


    -------------------------------------------------
    -- BIS Crown
    -------------------------------------------------
    row.bis = row.iconFrame:CreateTexture(nil, "ARTWORK", nil, 7)
    row.bis:SetSize(16, 16)
    row.bis:SetPoint("CENTER", row.iconFrame, "TOPLEFT", 5, 0)
    row.bis:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\bis_crown.png")
	row.bis:Show()
	
    -------------------------------------------------
    -- Item Name
    -------------------------------------------------
    row.name = row:CreateFontString()
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    row.name:SetPoint("TOP", row, "TOP", 0, -4)
    row.name:SetWidth(5*rowHeight)
    row.name:SetJustifyH("LEFT")
	row.name:SetFont(option("fontname_gf_itemname") or CCS.fontname, option("fontsize_gf_itemname") or 11, CCS.textoutline)	

    if option("showfontshadow") == true then
        row.name:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        row.name:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                    

    row.name:SetText("The Horseman’s Horrific Helm of the Headless Horseman")

    -------------------------------------------------
    -- Item Type, Slot, Sub-type.   (e.g. Leather Chest) or (Weapon One Hand) or Trinket/Ring/Necklace/Cloak
    -------------------------------------------------
    row.type = row:CreateFontString()
    row.type:SetPoint("TOP", row.name, "BOTTOM", 0, -8)
    row.type:SetWidth(5*rowHeight)
    row.type:SetJustifyH("LEFT")
	row.type:SetFont(option("fontname_gf_itemslot") or CCS.fontname, option("fontsize_gf_itemslot") or 10, CCS.textoutline)	
    if option("showfontshadow") == true then
        row.type:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        row.type:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                    

    row.type:SetTextColor(unpack(option("fontcolor_gf_itemslot") or {1,1,1,1}))
    row.type:SetText("Leather")

    -------------------------------------------------
    -- Primary Stat
    -------------------------------------------------

    row.primary = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.primary:SetPoint("LEFT", row.name, "RIGHT", 10, 0)
    row.primary:SetWidth(35)
    row.primary:SetJustifyH("CENTER")
    row.primary:SetText("I999")

    -------------------------------------------------
    -- Secondary Stats
    -------------------------------------------------
    local function CreateStatFS(anchor, label)
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("LEFT", anchor, "RIGHT", 7, 0)
        fs:SetWidth(35)
        fs:SetJustifyH("CENTER")
        fs:SetText(label)
		fs:SetFont(option("fontname_gf_stats") or CCS.fontname, option("fontsize_gf_stats") or 11, CCS.textoutline)	
        return fs
    end

    --row.crit    = CreateStatFS(row.primary, "C999")
	row.crit    = CreateStatFS(row.name, "C999")
    row.haste   = CreateStatFS(row.crit, "H999")
    row.mastery = CreateStatFS(row.haste, "M999")
    row.vers    = CreateStatFS(row.mastery, "V999")

    -------------------------------------------------
    -- Source Dungeon/Raid/PVP
    -------------------------------------------------
    row.source = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.source:SetPoint("TOPLEFT", row.vers, "TOPRIGHT", 17, 0)
    row.source:SetWidth(5*rowHeight)
    row.source:SetJustifyH("LEFT")
    row.source:SetText("Terrasse des Endlosen Frühlings")
	row.source:SetFont(option("fontname_gf_dungeon") or CCS.fontname, option("fontsize_gf_dungeon") or 11, CCS.textoutline)	
    row.source:SetTextColor(unpack(option("fontcolor_gf_dungeon") or {.6,.85,1,1}))
	
    -------------------------------------------------
    -- Source Boss
    -------------------------------------------------
    row.sourceboss = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.sourceboss:SetPoint("TOP", row.source, "BOTTOM", 0, -4)
    row.sourceboss:SetWidth(5*rowHeight)
    row.sourceboss:SetJustifyH("LEFT")
    row.sourceboss:SetText("Consejo de los Príncipes de Sangre")
	row.sourceboss:SetFont(option("fontname_gf_boss") or CCS.fontname, option("fontsize_gf_boss") or 11, CCS.textoutline)	
    row.sourceboss:SetTextColor(unpack(option("fontcolor_gf_boss") or {1,1,1,1}))

    -------------------------------------------------
    -- Data Setter
    -------------------------------------------------
    function row:SetData(data)
        if not data then
            self:Hide()
            return
        end

        self:Show()

        self.icon:SetTexture(data.icon or 134400)
		self.itemID = data.itemID or 0
        self.name:SetText(data.name or "")
        self.type:SetText(data.type or "")
        self.primary:SetText("" or data.primary or "")

        self.crit:SetText(data.crit or "")
        self.haste:SetText(data.haste or "")
        self.mastery:SetText(data.mastery or "")
        self.vers:SetText(data.vers or "")

        self.source:SetText(data.source or "")
        self.sourceboss:SetText(data.sourceboss or "")
		self.itemString = data.itemString
		self.hyperlink = data.hyperlink
		
        if data.isBIS then
            self.bis:Show()
        else
            self.bis:Hide()
        end
    end

    return row
end

function CCS:GetDisplayType(entry)
    local slot     = entry.slot or entry.equipLoc or ""
	local armor    = L[entry.armorType]
    local subclass = entry.subclass or ""

    -- Blizzard-localized slot name (e.g., "Two-Hand", "Main Hand", "Finger")
    local slotName = _G[slot] or slot or ""

    -------------------------------------------------
    -- Trinket, Finger, Neck, Cloak
    -------------------------------------------------
    if slot == "INVTYPE_TRINKET"
    or slot == "INVTYPE_FINGER"
    or slot == "INVTYPE_NECK"
    or slot == "INVTYPE_CLOAK" then
        return slotName
    end

    -------------------------------------------------
    -- Armor: Cloth/Leather/Mail/Plate (Slot)
    -------------------------------------------------
    if armor then
        return string.format("%s (%s)", armor, slotName)
    end

    -------------------------------------------------
    -- Weapons (all types)
    -------------------------------------------------
    local weaponSlots = {
        INVTYPE_2HWEAPON       = true,
        INVTYPE_WEAPON         = true,
        INVTYPE_WEAPONMAINHAND = true,
        INVTYPE_WEAPONOFFHAND  = true,
        INVTYPE_SHIELD         = true,
        INVTYPE_HOLDABLE       = true,
        INVTYPE_RANGED         = true,
        INVTYPE_RANGEDRIGHT    = true,
    }

    if weaponSlots[slot] then
        if slot == "INVTYPE_RANGEDRIGHT" then
			return string.format("%s (%s)", ENCHSLOT_WEAPON, INVTYPE_WEAPON)
        end

        if slot == "INVTYPE_SHIELD" then
			return string.format("%s (%s)", ENCHSLOT_WEAPON, SHIELDSLOT)
        end

        if subclass ~= "" then
            return string.format("%s (%s %s)", ENCHSLOT_WEAPON, slotName, subclass)
        else
            return string.format("%s (%s)", ENCHSLOT_WEAPON, slotName)
        end
    end

    -------------------------------------------------
    -- Just in case we missed something, we return the slotName
    -------------------------------------------------
    return slotName
end

local function ColorStat(value)
    if value > 0 then
        return string.format("|cff00ff00%d|r", value)  -- bright green
    else
        return string.format("|cff808080%d|r", value)  -- gray
    end
end


function CCS.UpdateLootScroll(results)
    local scrollFrame = _G["ccsgf_gf_scf"]
    if not scrollFrame or not CCS.LootRows then return end

    local totalRows  = #CCS.LootRows
    local rowHeight  = 46
    local offset     = FauxScrollFrame_GetOffset(scrollFrame)

    for i = 1, totalRows do
        local dataIndex = i + offset
        local data      = results[dataIndex]
        local row       = CCS.LootRows[i]

        if data then
            local entry = data.entry
            local rt    = entry.runtime.stats

            local qualityColor = select(4, C_Item.GetItemQualityColor(4))
            local itemName     = C_Item.GetItemNameByID(entry.itemID) or ("Item "..entry.itemID)
            local coloredName  = string.format("|c%s%s|r", qualityColor, itemName)

            local rowData = {
                icon = C_Item.GetItemIconByID(entry.itemID),
				itemID = entry.itemID,
                name = coloredName,
				type = CCS:GetDisplayType(entry),

                primary    = (rt.str > 0 and rt.str)
                           or (rt.agi > 0 and rt.agi)
                           or (rt.int > 0 and rt.int)
                           or 0,

				crit    = ColorStat(rt.crit),
				haste   = ColorStat(rt.haste),
				mastery = ColorStat(rt.mastery),
				vers    = ColorStat(rt.vers),

                source     = entry.source.instanceName or "",
                sourceboss = entry.source.bossName or "",

                isBIS      = entry.isBIS or false,
                itemString = data.itemString,
                hyperlink  = data.hyperlink, -- tooltip still uses hyperlink
            }

            row:SetData(rowData)
            row:Show()
        else
            row:Hide()
        end
    end
end
-- loot1
function CCS:ApplyLootFilters(sortBy, sortDir)

    if ccsgf_gf then
        CCS:UpdateFooterFiltersFromControls(ccsgf_gf)
    end

	local UNIVERSAL_SLOTS = {
		INVTYPE_TRINKET       = true,
		INVTYPE_FINGER        = true,
		INVTYPE_NECK          = true,
		INVTYPE_CLOAK         = true,

		-- All weapons
		INVTYPE_WEAPON        = true,
		INVTYPE_2HWEAPON      = true,
		INVTYPE_WEAPONMAINHAND = true,
		INVTYPE_WEAPONOFFHAND = true,
		INVTYPE_RANGED        = true,
		INVTYPE_RANGEDRIGHT   = true,

		-- Off-hand items
		INVTYPE_SHIELD        = true,
		INVTYPE_HOLDABLE      = true,
	}


    local results   = {}
    local allReady  = true

    local selectedSlot = CCS.FooterFilters.slot
    local selectedArmor = CCS.FooterFilters.armor	
    local targetIlvl   = CCS.FooterFilters.ilvl
    local trackName    = CCS.FooterFilters.track

	if sortBy == nil and ccsgf_sf.sortBy ~= nil then
		sortBy = ccsgf_sf.sortBy
	else
		sortBy = sortBy or "NAME"
	end
	sortDir = sortDir or "Ascending"
	
    ccsgf_sf.sortBy = sortBy

    local count = 0

    for itemID, entry in pairs(CCS.MasterLoot) do
        local skip = false

		-----------------------------------------------------
		-- SLOT FILTER (multi-select, weapon submenu aware)
		-----------------------------------------------------
		local selectedSlots = CCS.FooterFilters.selectedSlots  -- table of booleans

		-- Only apply slot filtering if at least one slot is selected
		if not skip and selectedSlots and next(selectedSlots) ~= nil then
			local slotID = tonumber(entry.slotID)
			local slotName = entry.slot  -- e.g. "INVTYPE_WEAPON", "INVTYPE_SHIELD"

			-------------------------------------------------
			-- Weapon subtype mapping (matches dropdown)
			-------------------------------------------------
			local WEAPON_MAP = {
				["weapon_1h"]      = { "INVTYPE_WEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_RANGEDRIGHT", }, -- includes wands
				["weapon_2h"]      = { "INVTYPE_2HWEAPON" },
				["weapon_ranged"]  = { "INVTYPE_RANGED"}, -- bows/guns/crossbows only
				["weapon_shield"]  = { "INVTYPE_SHIELD" },
				["weapon_offhand"] = { "INVTYPE_HOLDABLE", "INVTYPE_WEAPONOFFHAND" },
			}

			-------------------------------------------------
			-- Direct numeric slot match (non-weapons)
			-------------------------------------------------
			local function DirectSlotMatch()
				-- If the dropdown selected a numeric slotID, match it
				if selectedSlots[slotID] then
					return true
				end
				return false
			end

			-------------------------------------------------
			-- Weapon submenu match
			-------------------------------------------------
			local function WeaponMatch()
				for key, slotList in pairs(WEAPON_MAP) do
					if selectedSlots[key] then
						for _, invType in ipairs(slotList) do
							if slotName == invType then
								return true
							end
						end
					end
				end
				return false
			end

			-------------------------------------------------
			-- Final slot decision
			-------------------------------------------------
			local match = DirectSlotMatch() or WeaponMatch()

			if not match then
				skip = true
			end
		end

        -----------------------------------------------------
        -- ARMOR TYPE FILTER (Cloth/Leather/Mail/Plate)
        -- Only applies to actual armor pieces.
        -- Weapons, rings, trinkets, etc. are NOT filtered out.
        -----------------------------------------------------
		if not skip and selectedArmor and selectedArmor ~= "ALL" then
			-- Bypass for universal slots
			if not UNIVERSAL_SLOTS[entry.slot] then
				-- Only filter actual armor pieces
				if entry.armorType == nil or (entry.armorType and entry.armorType:upper() ~= selectedArmor) then
					skip = true
				end
			end
		end
	
        -----------------------------------------------------
        -- Build upgraded item link
        -----------------------------------------------------
        local itemString
        if not skip then
            itemString = CCS.BuilditemString(itemID, trackName, targetIlvl, entry.source.bossID)
            if not itemString then
                allReady = false
                skip = true
            end
        end

        local itemName, hyperlink, stats

        if not skip then
            itemName  = C_Item.GetItemNameByID(itemID) or ("Item "..itemID)
            hyperlink = string.format("|cffa335ee|H%s|h[%s]|h|r", itemString, itemName)
			
            -------------------------------------------------
            -- Extract runtime stats
            -------------------------------------------------
            stats = CCS.GetItemSecondaryStats(itemID, itemString)
            if not stats then
                allReady = false
                skip = true
            end
			-----------------------------------------------------
			-- PRIMARY STAT FILTER (Strength / Agility / Intellect)
			-----------------------------------------------------
			local selectedPrimary = CCS.FooterFilters.primary
			if not skip and selectedPrimary and selectedPrimary ~= "ALL" then
			-- If this is a universal slot, bypass the filter entirely
				if selectedPrimary == "STRENGTH" and (stats.STR or 0) <= 0 then
					skip = true
				elseif selectedPrimary == "AGILITY" and (stats.AGI or 0) <= 0 then
					skip = true
				elseif selectedPrimary == "INTELLECT" and (stats.INT or 0) <= 0 then
					skip = true
				end
			end
        end

		-----------------------------------------------------
		-- SECONDARY STAT FILTERS (Crit / Haste / Mastery / Vers)
		-- Only apply if at least one toggle is ON
		-----------------------------------------------------
		local sec = CCS.FooterFilters.secondaries
		local requireCrit    = sec.CRIT
		local requireHaste   = sec.HASTE
		local requireMastery = sec.MASTERY
		local requireVers    = sec.VERS

		-- If ANY toggle is ON, we filter by them
		if not skip and (requireCrit or requireHaste or requireMastery or requireVers) then
			if requireCrit    and (stats.CRIT    or 0) <= 0 then skip = true end
			if requireHaste   and (stats.HASTE   or 0) <= 0 then skip = true end
			if requireMastery and (stats.MASTERY or 0) <= 0 then skip = true end
			if requireVers    and (stats.VERS    or 0) <= 0 then skip = true end
		end

		-----------------------------------------------------
		-- SOURCE FILTER
		-----------------------------------------------------
		local includeDungeons  = CCS.FooterFilters.includeDungeons
		local includeRaids     = CCS.FooterFilters.includeRaids
		local includeClassSets = CCS.FooterFilters.includeClassSets

		local selectedDungeons = CCS.FooterFilters.selectedInstances
		local selectedBosses   = CCS.FooterFilters.selectedBosses

		-- TRUE when user has selected ANY specific source
		local anySelected =
			includeClassSets or
			next(selectedDungeons) ~= nil or
			next(selectedBosses) ~= nil

		-- TRUE when user has selected NOTHING (the "All" state)
		local nothingSelected = not anySelected

		if not skip then
			-- NOTHING SELECTED; allow everything
			if nothingSelected then

				-- Only apply global toggles
				if entry.source.type == "dungeon" and not includeDungeons then
					skip = true
				elseif entry.source.type == "raid" and not includeRaids then
					skip = true
				elseif entry.source.type == "classset" and not includeClassSets then
					skip = true
				end

			else
				-- CLASS SETS
				if entry.source.type == "classset" then
					if not includeClassSets then
						skip = true
					end

				-- DUNGEONS
				elseif entry.source.type == "dungeon" then
					if not includeDungeons then
						skip = true
					elseif not selectedDungeons[entry.source.ejID] then
						skip = true
					end

				-- RAIDS
				elseif entry.source.type == "raid" then
					if not includeRaids then
						skip = true
					elseif not selectedBosses[entry.source.bossID] then
						skip = true
					end
				end
			end
		end

		-----------------------------------------------------
		-- CLASS USABILITY FILTER (with debug)
		-----------------------------------------------------
		if not skip then
			local classID = CCS.FooterFilters.class  -- nil = ALL classes
			if classID then
				local rules = CCS.Classes[classID]

				-------------------------------------------------
				-- Class sets must match selected class
				-------------------------------------------------
				if entry.source and entry.source.type == "classset" then
					if entry.source.classID and entry.source.classID ~= classID then
						skip = true
					end
				end

				-------------------------------------------------
				-- Armor filtering (only for real armor slots)
				-------------------------------------------------
				if not skip and entry.itemClassID == 4 then  -- 4 = ARMOR
					local slot = entry.slot

					local isArmorSlot =
						slot == "INVTYPE_HEAD"     or
						slot == "INVTYPE_SHOULDER" or
						slot == "INVTYPE_CHEST"    or
						slot == "INVTYPE_ROBE"     or
						slot == "INVTYPE_WAIST"    or
						slot == "INVTYPE_LEGS"     or
						slot == "INVTYPE_FEET"     or
						slot == "INVTYPE_WRIST"    or
						slot == "INVTYPE_HAND"

					if isArmorSlot then
						local allowed = false
						if entry.armorType then
							for _, armorType in ipairs(rules.armor) do
								if armorType == entry.armorType then
									allowed = true
									break
								end
							end
						end

						if not allowed then
							skip = true
						end
					end
				end

				-------------------------------------------------
				-- Weapon filtering (subclass-based)
				-------------------------------------------------
				if not skip and entry.itemClassID == 2 then  -- 2 = WEAPON
					local allowedSub = rules.weapons[2]

					-- Normalize subclass ID
					local sub = tonumber(entry.itemSubClassID)

					-- Reject if class cannot use this weapon subclass
					if not (allowedSub and allowedSub[sub]) then
						skip = true
					end
				end


				-------------------------------------------------
				-- Shields
				-------------------------------------------------
				if not skip and entry.slot == "INVTYPE_SHIELD" then
					if not rules.weapons.shields then
						skip = true
					end
				end

				-------------------------------------------------
				-- Held in Off-hand
				-------------------------------------------------
				if not skip and entry.slot == "INVTYPE_HOLDABLE" then
					if not rules.weapons.offhands then
						skip = true
					end
				end
			end
		end

        if not skip then
            -------------------------------------------------
            -- Update runtime stats
            -------------------------------------------------
            entry.runtime.ilvl  = stats.ilvl or targetIlvl
            entry.runtime.track = trackName
            entry.runtime.rank  = stats.rank or 0

            entry.runtime.stats.str     = stats.STR or 0
            entry.runtime.stats.agi     = stats.AGI or 0
            entry.runtime.stats.int     = stats.INT or 0

            entry.runtime.stats.crit    = stats.CRIT or 0
            entry.runtime.stats.haste   = stats.HASTE or 0
            entry.runtime.stats.mastery = stats.MASTERY or 0
            entry.runtime.stats.vers    = stats.VERS or 0

            -------------------------------------------------
            -- Add to results
            -------------------------------------------------
            table.insert(results, {
                itemID     = itemID,
                entry      = entry,
                stats      = stats,
                itemString = itemString,
                hyperlink  = hyperlink,
            })

            count = count + 1
        end

		
    end

    -- If ANY item wasn’t ready, retry shortly and do NOT touch the UI yet
    if not allReady then
        C_Timer.After(0.1, function()
            CCS:ApplyLootFilters(sortBy, sortDir)
        end)
        return
    end

    ---------------------------------------------------------
    -- SORT RESULTS.  This is where the magic happens!
    ---------------------------------------------------------
    local function cmp(a, b)
        local av, bv

        if sortBy == "NAME" then
            av = a.entry.name or ""
            bv = b.entry.name or ""

        elseif sortBy == "ILVL" then
            av = a.stats.ilvl or 0
            bv = b.stats.ilvl or 0

        elseif sortBy == "CRIT" then
            av = a.stats.CRIT or 0
            bv = b.stats.CRIT or 0

        elseif sortBy == "HASTE" then
            av = a.stats.HASTE or 0
            bv = b.stats.HASTE or 0

        elseif sortBy == "MASTERY" then
            av = a.stats.MASTERY or 0
            bv = b.stats.MASTERY or 0

        elseif sortBy == "VERS" then
            av = a.stats.VERS or 0
            bv = b.stats.VERS or 0

        elseif sortBy == "SOURCE" then
            av = a.entry.source and a.entry.source.instanceName or ""
            bv = b.entry.source and b.entry.source.instanceName or ""
        end

        if sortDir == "Ascending" then
            return av < bv
        else
            return av > bv
        end
    end

    table.sort(results, cmp)

    CCS.CurrentResults = results

    local scrollFrame = _G["ccsgf_gf_scf"]
    if scrollFrame then
        FauxScrollFrame_Update(scrollFrame, #results, #CCS.LootRows, 46)
        scrollFrame:SetVerticalScroll(0)
    end

    CCS.UpdateLootScroll(results)
end

function CCS:UpdateFooterFiltersFromControls(parent)
    CCS.FooterFilters = CCS.FooterFilters or {}

    CCS.FooterFilters.slot    = parent.selectedSlot or "ALL"
    CCS.FooterFilters.class = parent.selectedClassID 
    CCS.FooterFilters.armor   = parent.selectedArmorType or "ALL"
    CCS.FooterFilters.primary = parent.selectedPrimaryStat or "ALL"

    CCS.FooterFilters.instanceID = parent.selectedInstanceID

    CCS.FooterFilters.includeDungeons = parent.includeDungeons:GetChecked()
    CCS.FooterFilters.includeRaids    = parent.includeRaids:GetChecked()

    CCS.FooterFilters.ilvl  = parent.selectedIlvl or CCS.seasonCap
    CCS.FooterFilters.track = parent.selectedTrack or "Myth"

    -- Secondary stats from the icon buttons
    CCS.FooterFilters.secondaries = {
        CRIT    = parent.statCrit.enabled    or false,
        HASTE   = parent.statHaste.enabled   or false,
        MASTERY = parent.statMastery.enabled or false,
        VERS    = parent.statVers.enabled    or false,
    }
end

local function UpdateArmorTypeForClass(parent, classID)
    local DEFAULT_ARMOR_BY_CLASS = {
        [1]="PLATE",[2]="PLATE",[3]="MAIL",[4]="LEATHER",[5]="CLOTH",
        [6]="PLATE",[7]="MAIL",[8]="CLOTH",[9]="CLOTH",[10]="LEATHER",
        [11]="LEATHER",[12]="LEATHER",[13]="MAIL"
    }

    local newArmor = DEFAULT_ARMOR_BY_CLASS[classID] or "ALL"
    parent.selectedArmorType = newArmor

    local display = (newArmor == "ALL") and ALL or L[newArmor:sub(1,1)..newArmor:sub(2):lower()]
    UIDropDownMenu_SetText(parent.armorTypeDrop, display)

    local dropName = parent.armorTypeDrop:GetName()
    local i = 1
    while true do
        local btn = _G[dropName.."Button"..i]
        if not btn then break end
        local val = btn.value
        if val then
            local checked = (val == newArmor)
            btn.checked = checked
            if btn.SetChecked then btn:SetChecked(checked) end
        end
        i = i + 1
    end
end

local function HookDropdownSubmenuRefresh()
    if DropDownList2._ccsGenericHooked then return end
    DropDownList2._ccsGenericHooked = true

    DropDownList2:HookScript("OnShow", function(self)
        self._ccsParent = self.dropdown
    end)

    DropDownList2:HookScript("OnHide", function(self)
        local parent = self._ccsParent
        if not parent or not parent._ccsRefreshOnSubmenuHide then
            return
        end

        -- Delay one frame to see if the submenu is reopening
        C_Timer.After(0, function()
            -- If DropDownList2 is visible again, it was just a rebuild
            if DropDownList2:IsShown() then
                return
            end

            -- Submenu is REALLY closing → refresh parent
            CloseDropDownMenus()
            ToggleDropDownMenu(1, nil, parent)
        end)
    end)
end

HookDropdownSubmenuRefresh()

function CCS:CreateLootFooter(parent)
    local footerName = "CCS_LootFooter"
    local footer = _G[footerName]

    if footer then
        return footer
    end

	-------------------------------------------------
	-- Create footer frame
	-------------------------------------------------
	footer = CreateFrame("Frame", footerName, parent, "BackdropTemplate")
	footer:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 17)
	footer:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 17)
	footer:SetHeight(65)

	footer:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = nil,
		tile = false,
		tileSize = 0,
		edgeSize = 0,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
    footer:SetBackdropColor(unpack(option("bgcolor_gearfinderfooter") or {0,0,0,0.85}))

	-- Start of Control Creation Helper Functions
    -------------------------------------------------
    -- Apply font/shadow
    -------------------------------------------------
    local function StyleFont(fs, size)
        fs:SetFont(CCS.fontname, size, CCS.textoutline)
        if option("showfontshadow") then
            fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        end
    end

	-------------------------------------------------
	-- Create dropdown function and skin it. 
	-- May need to make a controls.lua file later so we 
	-- can have common control creation functions.
	-------------------------------------------------
	local function CreateDropdown(name, width, parentFrame)
		-- Note: BackdropTemplate so SetBackdrop works
		local drop = CreateFrame("Frame", name, parentFrame, "UIDropDownMenuTemplate,BackdropTemplate")
		UIDropDownMenu_SetWidth(drop, width)

		-- Apply CCS skin
		CCS.SkinDropdown(drop, name)

		return drop
	end

    -------------------------------------------------
    -- Create checkbox function and skin it
    -------------------------------------------------
	local function CreateCheckbox(label, parentFrame)
		-- Create a clean checkbox with BackdropTemplate so CCS.SkinCheckbox works
		local cb = CreateFrame("CheckButton", nil, parentFrame, "BackdropTemplate")

		-- Force checkbox frame to be ONLY the checkbox square
		cb:SetSize(20, 20)
		cb:SetHitRectInsets(0, 0, 0, 0)

		-- Create label manually (so it doesn't expand the hitbox)
		local text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
		text:SetText(label)
		--StyleFont(text, 11)
		cb.Text = text

		-- Apply your CCS skin
		CCS.SkinCheckbox(cb)

		return cb
	end

	-------------------------------------------------
	-- Create secondary stat icon button
	-------------------------------------------------
	local function CreateStatButton(texture, parentFrame, tooltipText)
		local btn = CreateFrame("Button", nil, parentFrame)
		btn:SetSize(28, 28)

		local icon = btn:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetTexture(texture)
		btn.icon = icon

		local border = btn:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		border:SetAllPoints()
		border:SetVertexColor(1, 1, 1, 0.25)
		btn.border = border

		-------------------------------------------------
		-- Hover glow overlay
		-------------------------------------------------
		local glow = btn:CreateTexture(nil, "HIGHLIGHT")
		glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		glow:SetBlendMode("ADD")
		
		-- Make the glow bigger than the button so it wraps the icon
		glow:SetPoint("TOPLEFT", btn, "TOPLEFT", -10, 10)
		glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 10, -10)

		glow:SetVertexColor(unpack(CCS.StyleColor.highlight))
		glow:Hide()
		btn.glow = glow

		-------------------------------------------------
		-- Visual state update (enabled/disabled)
		-------------------------------------------------
		local function UpdateState(self)
			if self.enabled then
				self.icon:SetAlpha(1.0)
				self.border:SetAlpha(0.35)
			else
				self.icon:SetAlpha(0.35)
				self.border:SetAlpha(0.10)
			end
		end

		btn.enabled = false
		UpdateState(btn)

		-------------------------------------------------
		-- Click toggles enabled state
		-------------------------------------------------
		btn:SetScript("OnClick", function(self)
			PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
			self.enabled = not self.enabled
			UpdateState(self)
			CCS:ApplyLootFilters()
		end)

		-------------------------------------------------
		-- Hover scripts (show glow)
		-------------------------------------------------
		btn:SetScript("OnEnter", function(self)
			self.glow:Show()
			
			if tooltipText then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:AddLine(tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end

		end)

		btn:SetScript("OnLeave", function(self)
			self.glow:Hide()
			GameTooltip:Hide()
		end)

		return btn
	end

	-- End of Control Creation Helper Functions

	-------------------------------------------------
	-- Creation and SetPoints for all controls.  
    -- Makes adjustments easier to see them in one spot.
    -- We configure the controls later.
	-------------------------------------------------
	parent.classSpecDrop = CreateDropdown("CCS_ClassSpecDrop", 150, ccsgf_sf)
	parent.classSpecDrop:SetFrameLevel(parent:GetFrameLevel() + 50)
	parent.slotDrop      = CreateDropdown("CCS_SlotDrop", 150, footer)
	parent.instanceDrop = CreateDropdown("CCS_InstanceDrop", 150, footer)
    parent.primaryStatDrop = CreateDropdown("CCS_PrimaryStatDrop", 80, footer)
    parent.statCrit = CreateStatButton("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\crit.png", footer, ITEM_MOD_CRIT_RATING_SHORT)
    parent.statHaste = CreateStatButton("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\haste.png", footer, ITEM_MOD_HASTE_RATING_SHORT)
    parent.statMastery = CreateStatButton("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\mastery.png", footer, ITEM_MOD_MASTERY_RATING_SHORT)
    parent.statVers = CreateStatButton("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\versatility.png", footer, STAT_VERSATILITY)
    parent.includeDungeons = CreateCheckbox(DUNGEONS, footer)
    parent.includeRaids = CreateCheckbox(RAIDS, footer)
	parent.ilvlDrop = CreateDropdown("CCS_IlvlDrop", 80, footer)

	parent.classSpecDrop:SetPoint("BOTTOMLEFT", footer, "BOTTOMLEFT", 45, 2)
	parent.slotDrop:SetPoint("BOTTOMLEFT", parent.classSpecDrop, "TOPLEFT", 0, 1)
	parent.ilvlDrop:SetPoint("LEFT", parent.slotDrop, "RIGHT", 2, 0)
    parent.primaryStatDrop:SetPoint("LEFT", parent.ilvlDrop, "RIGHT", 2, 0)
    parent.statCrit:SetPoint("TOPLEFT", parent.primaryStatDrop, "BOTTOMLEFT", 7, -1)
    parent.statHaste:SetPoint("LEFT", parent.statCrit, "RIGHT", 2, 0)
    parent.statMastery:SetPoint("LEFT", parent.statHaste, "RIGHT", 2, 0)
	parent.statMastery:SetScale(.9)
    parent.statVers:SetPoint("LEFT", parent.statMastery, "RIGHT", 2, 0)

    parent.instanceDrop:SetPoint("LEFT", parent.primaryStatDrop, "RIGHT", 2, 0)
    parent.includeDungeons:SetPoint("TOPLEFT", parent.instanceDrop, "BOTTOMLEFT", 3, -1)
    parent.includeRaids:SetPoint("LEFT", parent.includeDungeons.Text, "RIGHT", 10, 0)
	
	-------------------------------------------------
	-- Class/Spec Dropdown Menu Creation
	-------------------------------------------------
	-- Get player's class and spec
	local _, playerClassFile, playerClassID = UnitClass("player")
	local currentSpecIndex = GetSpecialization()
	local className = GetClassInfo(playerClassID)

	if currentSpecIndex then
		local specID, specName = GetSpecializationInfo(currentSpecIndex)

		-- Detect "Initial" spec (no spec chosen)
		local noRealSpec = (specID == 0) or (specID >= 1400) or (specName == nil)

		if noRealSpec then
			parent.selectedClassID = playerClassID
			parent.selectedSpecID  = nil
			UIDropDownMenu_SetText(parent.classSpecDrop, className)
		else
			parent.selectedClassID = playerClassID
			parent.selectedSpecID  = specID
			UIDropDownMenu_SetText(parent.classSpecDrop, className .. " – " .. (specName or ""))
		end
	else
		-- No spec index at all
		parent.selectedClassID = playerClassID
		parent.selectedSpecID  = nil
		UIDropDownMenu_SetText(parent.classSpecDrop, className)
	end

	UIDropDownMenu_Initialize(parent.classSpecDrop, function(self, level)
		-------------------------------------------------
		-- LEVL 1 menu list: Class list
		-------------------------------------------------
		if level == 1 then
			-- "All"
			local info = UIDropDownMenu_CreateInfo()
			info.text = ALL
			info.checked = (parent.selectedClassID == nil)
			info.func = function()
				parent.selectedClassID = nil
				parent.selectedSpecID = nil
				UIDropDownMenu_SetText(parent.classSpecDrop, CLASS.." ("..ALL..")")
				UpdateArmorTypeForClass(parent, nil)
				CCS:ApplyLootFilters()
			end
			UIDropDownMenu_AddButton(info, level)

			-- Classes
			-------------------------------------------------
			-- Alphabetically sorted class dropdown
			-------------------------------------------------
			-- Build sortable class table
			local classes = {}
			for classID = 1, GetNumClasses() do
				local className, classFile = GetClassInfo(classID)
				table.insert(classes, {
					id = classID,
					name = className,
					file = classFile,
				})
			end

			-- Sort alphabetically by localized class name
			table.sort(classes, function(a, b)
				return a.name < b.name
			end)

			-- Add sorted classes to dropdown
			for _, class in ipairs(classes) do
				local color = RAID_CLASS_COLORS[class.file]
				local r, g, b = color.r, color.g, color.b

				local coloredName = string.format("|cff%02x%02x%02x%s|r",
					r * 255, g * 255, b * 255, class.name)

				local info = UIDropDownMenu_CreateInfo()
				info.text = coloredName
				info.hasArrow = true
				info.value = class.id
				info.menuList = class.id

				-- Check to see if any spec of the class is selected
				info.checked = (parent.selectedClassID == class.id)

				UIDropDownMenu_AddButton(info, level)
			end
		-------------------------------------------------
		-- LEVL 2 menu list: Spec list per class
		-------------------------------------------------
		elseif level == 2 then
			local classID = UIDROPDOWNMENU_MENU_VALUE
			local numSpecs = GetNumSpecializationsForClassID(classID)
			local className = GetClassInfo(classID)

			-- Build sortable spec table
			local specs = {}
			for i = 1, numSpecs do
				local specID, name = GetSpecializationInfoForClassID(classID, i)
				table.insert(specs, {
					id = specID,
					name = name,
				})
			end

			-- Sort alphabetically by localized spec name
			table.sort(specs, function(a, b)
				return a.name < b.name
			end)

			-- Add sorted specs to dropdown
			for _, spec in ipairs(specs) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = spec.name

				-- CHECK SPEC
				info.checked = (parent.selectedClassID == classID and parent.selectedSpecID == spec.id)

				info.func = function()
					parent.selectedClassID = classID
					parent.selectedSpecID = spec.id
					UIDropDownMenu_SetText(parent.classSpecDrop, className .. " – " .. (spec.name or ""))
					UpdateArmorTypeForClass(parent, classID)
					CCS:ApplyLootFilters()
					-- FORCE REFRESH SO CLASS GETS ITS DOT
					ToggleDropDownMenu(nil, nil, parent.classSpecDrop)
					ToggleDropDownMenu(1, nil, parent.classSpecDrop)
				end

				UIDropDownMenu_AddButton(info, level)
			end
		end
	end)

	-------------------------------------------------
	-- Item Slot Menu (multi-select, with Weapon submenu)
	-------------------------------------------------
	parent.slotDrop._ccsRefreshOnSubmenuHide = true
	UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..ALL)

	UIDropDownMenu_Initialize(parent.slotDrop, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()

		-------------------------------------------------
		-- Ensure tables exist
		-------------------------------------------------
		CCS.FooterFilters.selectedSlots = CCS.FooterFilters.selectedSlots or {}
		parent.selectedSlots = parent.selectedSlots or {}

		-------------------------------------------------
		-- LEVEL 1 MENU
		-------------------------------------------------
		if level == 1 then

			-------------------------------------------------
			-- "All" (clears all selections)
			-------------------------------------------------
			info.text = ALL
			info.isNotRadio = true
			info.keepShownOnClick = true
			info.checked = (next(CCS.FooterFilters.selectedSlots) == nil)

			info.func = function()
				wipe(CCS.FooterFilters.selectedSlots)
				wipe(parent.selectedSlots)

				UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..ALL)

				-- Uncheck all buttons
				local i = 2
				while true do
					local btn = _G[parent.slotDrop:GetName().."Button"..i]
					if not btn then break end
					btn.checked = false
					if btn.SetChecked then btn:SetChecked(false) end
					i = i + 1
				end

				local lvl = UIDROPDOWNMENU_MENU_LEVEL or 1
				CloseDropDownMenus()
				ToggleDropDownMenu(level, nil, parent.slotDrop)
				CCS:ApplyLootFilters()
			end

			UIDropDownMenu_AddButton(info, level)

			-------------------------------------------------
			-- Build unique slot groups (except Weapon)
			-------------------------------------------------
			local slotGroups = {}

			for _, slot in ipairs(CCS.AllSlots) do
				if slot.group ~= WEAPON then
					local key = slot.group or slot.name
					slotGroups[key] = slotGroups[key] or {}
					table.insert(slotGroups[key], slot.id)
				end
			end

			-------------------------------------------------
			-- Sort group names alphabetically
			-------------------------------------------------
			local sortedGroups = {}
			for groupName, idList in pairs(slotGroups) do
				table.insert(sortedGroups, { name = groupName, ids = idList })
			end

			table.sort(sortedGroups, function(a, b)
				return a.name < b.name
			end)

			-------------------------------------------------
			-- Add grouped slots (multi-select)
			-------------------------------------------------
			for _, group in ipairs(sortedGroups) do
				local groupName = group.name
				local idList = group.ids
				local slotID = idList[1]

				info = UIDropDownMenu_CreateInfo()
				info.text = groupName
				info.keepShownOnClick = true
				info.isNotRadio = true
				info.checked = CCS.FooterFilters.selectedSlots[slotID] == true

				info.func = function()
					if CCS.FooterFilters.selectedSlots[slotID] then
						CCS.FooterFilters.selectedSlots[slotID] = nil
						parent.selectedSlots[slotID] = nil
					else
						CCS.FooterFilters.selectedSlots[slotID] = true
						parent.selectedSlots[slotID] = true
					end

					-- Update display text
					local count = 0
					local lastName = nil
					for id in pairs(CCS.FooterFilters.selectedSlots) do
						count = count + 1
						lastName = groupName
					end

					if count == 0 then
						UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..ALL)
					elseif count == 1 then
						UIDropDownMenu_SetText(parent.slotDrop, lastName)
					else
						UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..L["Multiple"])
					end

					-- Uncheck "All"
					local allButton = _G[parent.slotDrop:GetName().."Button1"]
					if allButton then
						allButton.checked = false
						if allButton.SetChecked then allButton:SetChecked(false) end
					end

					CloseDropDownMenus()
					ToggleDropDownMenu(level, nil, parent.slotDrop)

					CCS:ApplyLootFilters()
				end

				UIDropDownMenu_AddButton(info, level)
			end

			-------------------------------------------------
			-- WEAPON GROUP (submenu + select-all / deselect-all)
			-------------------------------------------------
			local weapon1h      = CCS.FooterFilters.selectedSlots["weapon_1h"]
			local weapon2h      = CCS.FooterFilters.selectedSlots["weapon_2h"]
			local weaponRanged  = CCS.FooterFilters.selectedSlots["weapon_ranged"]
			local weaponShield  = CCS.FooterFilters.selectedSlots["weapon_shield"]
			local weaponOffhand = CCS.FooterFilters.selectedSlots["weapon_offhand"]

			local anyWeaponSelected =
				weapon1h or weapon2h or weaponRanged or weaponShield or weaponOffhand

			local allWeaponSelected =
				weapon1h and weapon2h and weaponRanged and weaponShield and weaponOffhand

			info = UIDropDownMenu_CreateInfo()
			info.text = WEAPON
			info.isNotRadio = true
			info.keepShownOnClick = true
			info.hasArrow = true
			info.menuList = "WEAPON"
			
			-- Level-1 checkmark if ANY Level-2 is selected
			info.checked = anyWeaponSelected

			info.func = function()
				-- Toggle all weapon types
				local newState = not allWeaponSelected

				CCS.FooterFilters.selectedSlots["weapon_1h"]      = newState or nil
				CCS.FooterFilters.selectedSlots["weapon_2h"]      = newState or nil
				CCS.FooterFilters.selectedSlots["weapon_ranged"]  = newState or nil
				CCS.FooterFilters.selectedSlots["weapon_shield"]  = newState or nil
				CCS.FooterFilters.selectedSlots["weapon_offhand"] = newState or nil

				-- Update dropdown text
				local count = 0
				for _ in pairs(CCS.FooterFilters.selectedSlots) do
					count = count + 1
				end

				if count == 0 then
					UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..ALL)
				elseif count == 1 then
					UIDropDownMenu_SetText(parent.slotDrop, L["Weapon"])
				else
					UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..L["Multiple"])
				end

				CloseDropDownMenus()
				ToggleDropDownMenu(level, nil, parent.slotDrop)
				CCS:ApplyLootFilters()
			end

			UIDropDownMenu_AddButton(info, level)

		-------------------------------------------------
		-- LEVEL 2 MENU (Weapon subtypes)
		-------------------------------------------------
		elseif level == 2 and menuList == "WEAPON" then

			local weaponTypes = {
				{ id = "weapon_1h",      label = INVTYPE_WEAPON },
				{ id = "weapon_2h",      label = INVTYPE_2HWEAPON },
				{ id = "weapon_ranged",  label = RANGEDSLOT },
				{ id = "weapon_shield",  label = SHIELDSLOT },
				{ id = "weapon_offhand", label = INVTYPE_WEAPONOFFHAND },
			}

			for _, entry in ipairs(weaponTypes) do
				info = UIDropDownMenu_CreateInfo()
				info.text = entry.label
				info.isNotRadio = true
				info.keepShownOnClick = true
				info.checked = CCS.FooterFilters.selectedSlots[entry.id] == true

				info.func = function()
					-- Toggle this subtype
					if CCS.FooterFilters.selectedSlots[entry.id] then
						CCS.FooterFilters.selectedSlots[entry.id] = nil
					else
						CCS.FooterFilters.selectedSlots[entry.id] = true
					end

					-- Recompute any/all weapon selection
					local w1 = CCS.FooterFilters.selectedSlots["weapon_1h"]
					local w2 = CCS.FooterFilters.selectedSlots["weapon_2h"]
					local wr = CCS.FooterFilters.selectedSlots["weapon_ranged"]
					local ws = CCS.FooterFilters.selectedSlots["weapon_shield"]
					local wo = CCS.FooterFilters.selectedSlots["weapon_offhand"]

					local any = w1 or w2 or wr or ws or wo

					-- Update Level Weapon checkmark
					local i = 1
					while true do
						local btn = _G[parent.slotDrop:GetName().."Button"..i]
						if not btn then break end
						if btn:GetText() == WEAPON then
							btn.checked = any
							if btn.SetChecked then btn:SetChecked(any) end
							break
						end
						i = i + 1
					end

					-- Update text
					local count = 0
					for _ in pairs(CCS.FooterFilters.selectedSlots) do
						count = count + 1
					end

					if count == 0 then
						UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..ALL)
					elseif count == 1 then
						UIDropDownMenu_SetText(parent.slotDrop, entry.label)
					else
						UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..L["Multiple"])
					end

					CCS:ApplyLootFilters()
				end

				UIDropDownMenu_AddButton(info, level)
			end
		end
	end)

	-------------------------------------------------
	-- Item Source Helper Functions
	-------------------------------------------------
	parent.instanceDrop._ccsRefreshOnSubmenuHide = true

	local function ResetInstanceDropdown(parent)
		parent.selectedInstanceID = nil
		parent.selectedBossID    = nil

		CCS.FooterFilters.selectedInstances = {}
		CCS.FooterFilters.selectedBosses    = {}
		CCS.FooterFilters.includeClassSets  = false

		UIDropDownMenu_SetText(parent.instanceDrop, DUNGEONS.."/"..RAIDS.." ("..ALL..")")

		CloseDropDownMenus()
	end

	-- Returns: allSelected, anySelected
	local function RaidBossSelectionState(raidID)
		local raid = CCS.Season.raids[raidID]
		local allSelected = true
		local anySelected = false

		for _, boss in ipairs(raid.bosses) do
			if CCS.FooterFilters.selectedBosses[boss.id] then
				anySelected = true
			else
				allSelected = false
			end
		end

		return allSelected, anySelected
	end

	local function UpdateRaidIndicators(parent)
		local dropName = parent.instanceDrop:GetName()

		for raidID, raid in pairs(CCS.Season.raids) do
			local allSelected, anySelected = RaidBossSelectionState(raidID)

			local i = 1
			while true do
				local btn = _G[dropName.."Button"..i]
				if not btn then break end

				if btn.menuList == raidID then
					-- Level-1 checkmark mirrors ANY boss selection (Weapon-style)
					btn.checked = anySelected
					if btn.SetChecked then
						btn:SetChecked(anySelected)
					end

					-- Text: full / partial / none
					if allSelected then
						btn.text:SetText(raid.name)
					elseif anySelected then
						btn.text:SetText("• "..raid.name)
					else
						btn.text:SetText(raid.name)
					end
				end

				i = i + 1
			end
		end
	end

	local function UpdateInstanceDropdownText(parent)
		local count = 0
		local lastName = nil

		-- Count raids (via boss selections)
		for raidID, raid in pairs(CCS.Season.raids) do
			local _, anySelected = RaidBossSelectionState(raidID)
			if anySelected then
				count = count + 1
				lastName = EJ_GetInstanceInfo(raidID)
			end
		end

		-- Count dungeons
		for id in pairs(CCS.FooterFilters.selectedInstances) do
			count = count + 1
			lastName = EJ_GetInstanceInfo(id)
		end

		-- Class Sets
		if CCS.FooterFilters.includeClassSets then
			count = count + 1
			lastName = L["Class Sets"]
		end

		if count == 0 then
			UIDropDownMenu_SetText(parent.instanceDrop, DUNGEONS.."/"..RAIDS.." ("..ALL..")")
			return
		end

		if count == 1 then
			UIDropDownMenu_SetText(parent.instanceDrop, lastName)
			return
		end

		UIDropDownMenu_SetText(parent.instanceDrop, CLUB_FINDER_MULTIPLE_CHECKED)
	end

	-------------------------------------------------
	-- Item Source Selector Menu
	-------------------------------------------------

	CCS.FooterFilters.selectedInstances = CCS.FooterFilters.selectedInstances or {}
	CCS.FooterFilters.selectedBosses    = CCS.FooterFilters.selectedBosses or {}

	UIDropDownMenu_SetText(parent.instanceDrop, DUNGEONS.."/"..RAIDS.." ("..ALL..")")

	UIDropDownMenu_Initialize(parent.instanceDrop, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()

		-------------------------------------------------
		-- LEVEL 1 MENU
		-------------------------------------------------
		if level == 1 then

			-------------------------------------------------
			-- "All"
			-------------------------------------------------
			info.text = ALL
			info.isNotRadio = true
			info.keepShownOnClick = true
			info.checked =
				not next(CCS.FooterFilters.selectedInstances)
				and not next(CCS.FooterFilters.selectedBosses)
				and not CCS.FooterFilters.includeClassSets

			info.func = function()
				ResetInstanceDropdown(parent)
				CloseDropDownMenus()
				ToggleDropDownMenu(level, nil, parent.instanceDrop)
				CCS:ApplyLootFilters()
			end
			UIDropDownMenu_AddButton(info, level)

			-------------------------------------------------
			-- Class Sets
			-------------------------------------------------
			info = UIDropDownMenu_CreateInfo()
			info.text = L["Class Sets"]
			info.isNotRadio = true
			info.keepShownOnClick = true
			info.checked = CCS.FooterFilters.includeClassSets

			info.func = function()
				CCS.FooterFilters.includeClassSets = not CCS.FooterFilters.includeClassSets

				UpdateRaidIndicators(parent)
				UpdateInstanceDropdownText(parent)
				CloseDropDownMenus()
				ToggleDropDownMenu(level, nil, parent.instanceDrop)
				CCS:ApplyLootFilters()
			end

			UIDropDownMenu_AddButton(info, level)

			-------------------------------------------------
			-- Raids Header
			-------------------------------------------------
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true
			info.notCheckable = true
			info.text = RAIDS
			UIDropDownMenu_AddButton(info, level)

			-------------------------------------------------
			-- Sorted Raids (Weapon-style: checkbox + flyout)
			-------------------------------------------------
			local raidList = {}
			for raidID in pairs(CCS.Season.raids) do
				local name = EJ_GetInstanceInfo(raidID)

				if name then
					table.insert(raidList, { id = raidID, name = name })
				else
					-- Skip it until EJ data exists
					-- print("Skipping raid", raidID, "(EJ not available yet)")
				end
			end
			table.sort(raidList, function(a, b) return a.name < b.name end)

			for _, entry in ipairs(raidList) do
				local raidID = entry.id
				local raid = CCS.Season.raids[raidID]
				local allSelected, anySelected = RaidBossSelectionState(raidID)

				info = UIDropDownMenu_CreateInfo()
				info.text = entry.name
				info.isNotRadio = true
				info.keepShownOnClick = true
				info.hasArrow = true
				info.menuList = raidID

				-- Level-1 checkmark if ANY boss is selected (Weapon-style)
				info.checked = anySelected

				info.func = function()
					-- Toggle all bosses in this raid (Weapon-style "toggle all")
					local newState = not allSelected

					for _, boss in ipairs(raid.bosses) do
						CCS.FooterFilters.selectedBosses[boss.id] = newState or nil
					end

					UpdateRaidIndicators(parent)
					UpdateInstanceDropdownText(parent)
					CloseDropDownMenus()
					ToggleDropDownMenu(level, nil, parent.instanceDrop)
					CCS:ApplyLootFilters()
				end

				UIDropDownMenu_AddButton(info, level)
			end

			-------------------------------------------------
			-- Dungeons Header
			-------------------------------------------------
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true
			info.notCheckable = true
			info.text = DUNGEONS
			UIDropDownMenu_AddButton(info, level)

			-------------------------------------------------
			-- Sorted Dungeons (checkboxes)
			-------------------------------------------------
			local dungeonList = {}
			for ejID in pairs(CCS.Season.dungeons) do
				table.insert(dungeonList, { id = ejID, name = EJ_GetInstanceInfo(ejID) })
			end
			table.sort(dungeonList, function(a, b) return a.name < b.name end)

			for _, entry in ipairs(dungeonList) do
				info = UIDropDownMenu_CreateInfo()
				info.text = entry.name
				info.isNotRadio = true
				info.keepShownOnClick = true
				info.checked = CCS.FooterFilters.selectedInstances[entry.id] == true

				info.func = function()
					CCS.FooterFilters.selectedInstances[entry.id] =
						not CCS.FooterFilters.selectedInstances[entry.id] or nil

					UpdateRaidIndicators(parent)
					UpdateInstanceDropdownText(parent)
					CloseDropDownMenus()
					ToggleDropDownMenu(level, nil, parent.instanceDrop)
					CCS:ApplyLootFilters()
				end

				UIDropDownMenu_AddButton(info, level)
			end

		-------------------------------------------------
		-- LEVEL 2 MENU (Bosses, Weapon-subtype-style)
		-------------------------------------------------
		elseif level == 2 then
			local raidID = menuList
			local raid = CCS.Season.raids[raidID]

			for _, boss in ipairs(raid.bosses) do
				local bossName = EJ_GetEncounterInfo(boss.id)

				info = UIDropDownMenu_CreateInfo()
				info.text = bossName
				info.isNotRadio = true
				info.keepShownOnClick = true
				info.checked = CCS.FooterFilters.selectedBosses[boss.id] == true

				info.func = function()
					-- Toggle this boss (Weapon-subtype-style)
					CCS.FooterFilters.selectedBosses[boss.id] =
						not CCS.FooterFilters.selectedBosses[boss.id] or nil

					-- Recompute any/all for this raid
					local allSelected, anySelected = RaidBossSelectionState(raidID)

					-- Update Level-1 raid checkmark + partial indicator (Weapon-style)
					local dropName = parent.instanceDrop:GetName()
					local i = 1
					while true do
						local btn = _G[dropName.."Button"..i]
						if not btn then break end

						if btn.menuList == raidID then
							btn.checked = anySelected
							if btn.SetChecked then
								btn:SetChecked(anySelected)
							end

							if allSelected then
								btn.text:SetText(raid.name)
							elseif anySelected then
								btn.text:SetText("• "..raid.name)
							else
								btn.text:SetText(raid.name)
							end

							break
						end

						i = i + 1
					end

					-- Update dropdown label
					UpdateRaidIndicators(parent)
					UpdateInstanceDropdownText(parent)

					CCS:ApplyLootFilters()
				end

				UIDropDownMenu_AddButton(info, level)
			end
		end
	end)


	-------------------------------------------------
	-- Primary Stat Menu
	-------------------------------------------------
	local primaryStats = {
		{ value = "ALL",       text = AGI.."/"..INT.."/"..STR },
		{ value = "AGILITY",   text = ITEM_MOD_AGILITY_SHORT },
		{ value = "INTELLECT", text = ITEM_MOD_INTELLECT_SHORT },
		{ value = "STRENGTH",  text = ITEM_MOD_STRENGTH_SHORT },
	}

	local _, _, _, _, _, primaryStat = GetSpecializationInfo(currentSpecIndex)

	local PRIMARY_STAT_MAP = {
		[1] = "STRENGTH",
		[2] = "AGILITY",
		[4] = "INTELLECT",
	}

	-- Set default selected value
	parent.selectedPrimaryStat = "ALL" -- PRIMARY_STAT_MAP[primaryStat]

	-- Set default display text
	for _, stat in ipairs(primaryStats) do
		if stat.value == parent.selectedPrimaryStat then
			UIDropDownMenu_SetText(parent.primaryStatDrop, stat.text)
			break
		end
	end

	UIDropDownMenu_Initialize(parent.primaryStatDrop, function(self, level)
		for _, stat in ipairs(primaryStats) do
			local info = UIDropDownMenu_CreateInfo()

			info.text  = stat.text
			info.value = stat.value

			info.checked = (parent.selectedPrimaryStat == stat.value)

			info.func = function()
				parent.selectedPrimaryStat = stat.value
				UIDropDownMenu_SetText(parent.primaryStatDrop, stat.text)
				CCS:ApplyLootFilters()
			end

			UIDropDownMenu_AddButton(info)
		end
	end)

    -------------------------------------------------
    -- Dungeons Checkbox
    -------------------------------------------------
    parent.includeDungeons:SetChecked(true)
    parent.includeDungeons:SetScript("OnClick", function()
        CCS:ApplyLootFilters()
    end)

    -------------------------------------------------
    -- Raids Checkbox
    -------------------------------------------------
    parent.includeRaids:SetChecked(true)
    parent.includeRaids:SetScript("OnClick", function()
		CCS:ApplyLootFilters()
    end)

	-------------------------------------------------
	-- Track Colors.  Need to move to tables.lua later.
	-------------------------------------------------
	local TRACK_COLORS = {
		Adventurer = {1.00, 1.00, 1.00}, -- White
		Veteran    = {0.12, 1.00, 0.00}, -- Bright Green
		Champion   = {0.00, 0.44, 0.87}, -- Blue
		Hero       = {1.00, 0.30, 1.00}, -- Purple
		Myth       = {1.00, 0.50, 0.00}, -- Orange
	}

	-------------------------------------------------
	-- Item Level Menu
	-------------------------------------------------
	UIDropDownMenu_SetText(parent.ilvlDrop, ITEM_LEVEL_ABBR..": "..tostring(CCS.seasonCap))
	parent.ilvlDrop.selectedIlvl = CCS.FooterFilters.ilvl
	parent.ilvlDrop.selectedTrack = CCS.FooterFilters.track

	UIDropDownMenu_Initialize(parent.ilvlDrop, function(self, level, menuList)
	local tracks = CCS.Season.upgradeTracks

	-------------------------------------------------
	-- LEVEL 1 menu list: Track List (sorted by track.id)
	-------------------------------------------------
	if level == 1 then
		-- Build sortable array
		local sortedTracks = {}
		for trackName, track in pairs(tracks) do
			table.insert(sortedTracks, {
				name = trackName,
				id   = track.id,
				data = track,
			})
		end

		table.sort(sortedTracks, function(a, b)
			return a.id < b.id
		end)

		for _, entry in ipairs(sortedTracks) do
			local trackName = entry.name
			local track = entry.data

			local color = TRACK_COLORS[trackName]
			local r, g, b = unpack(color)

			local coloredName = string.format("|cff%02x%02x%02x%s|r",
				r * 255, g * 255, b * 255, track.label)

			local info = UIDropDownMenu_CreateInfo()
			info.text = coloredName
			info.value = trackName
			info.hasArrow = true
			info.menuList = trackName

			-- ⭐ THIS IS THE FIX ⭐
			info.checked = (self.selectedTrack == trackName)
			--info.checked = (parent.ilvlDrop.selectedTrack == trackName)

			UIDropDownMenu_AddButton(info, level)
		end

		return
	end

		-------------------------------------------------
		-- LEVEL 2 menu list: ILVL List for Selected Track
		-------------------------------------------------
		if level == 2 then
		
			local track = tracks[menuList]
			local trackName = menuList
			-------------------------------------------------
			-- Build a sorted ilvl list from bonusByIlvl keys
			-------------------------------------------------
			local ilvls = {}
			for ilvl in pairs(track.bonusByIlvl) do
				table.insert(ilvls, ilvl)
			end
			table.sort(ilvls)

			local total = #ilvls

			for index, ilvl in ipairs(ilvls) do
				local info = UIDropDownMenu_CreateInfo()

				-- Display text: "259 (1/6)"
				if index <= 6 then -- A hack for the craziness of Midnight Season 1 (to handle Void Ascended, Sporefused, etc.)
					info.text = string.format("%d (%d/%d)", ilvl, index, math.min(6,total))
				else
					info.text = string.format("%d", ilvl)
				end
				-- Actual value: 259
				info.value = ilvl

				info.checked = (self.selectedIlvl == ilvl)

				info.func = function()
					self.selectedTrack = menuList
					self.selectedIlvl = ilvl
					parent.selectedTrack = menuList
					parent.selectedIlvl = ilvl
					
					UIDropDownMenu_SetText(parent.ilvlDrop, ITEM_LEVEL_ABBR..": "..tostring(ilvl))
					CloseDropDownMenus()
					CCS:ApplyLootFilters()
				end

				UIDropDownMenu_AddButton(info, level)
			end
		end



	end)

	-------------------------------------------------
	-- Armor Type Menu
	-------------------------------------------------
	parent.armorTypeDrop = CreateDropdown("CCS_ArmorTypeDrop", 80, footer)
	parent.armorTypeDrop:SetPoint("TOPLEFT", parent.ilvlDrop, "BOTTOMLEFT", 0, -2)

	-- Class default armor type mapping
	local DEFAULT_ARMOR_BY_CLASS = {
		[1]  = "PLATE",   -- Warrior
		[2]  = "PLATE",   -- Paladin
		[3]  = "MAIL",    -- Hunter
		[4]  = "LEATHER", -- Rogue
		[5]  = "CLOTH",   -- Priest
		[6]  = "PLATE",   -- Death Knight
		[7]  = "MAIL",    -- Shaman
		[8]  = "CLOTH",   -- Mage
		[9]  = "CLOTH",   -- Warlock
		[10] = "LEATHER", -- Monk
		[11] = "LEATHER", -- Druid
		[12] = "LEATHER", -- Demon Hunter
		[13] = "MAIL",    -- Evoker
	}

	-- Determine player's default armor type
	local _, _, playerClassID = UnitClass("player")
	local defaultArmor = DEFAULT_ARMOR_BY_CLASS[playerClassID] or "ALL"

	parent.selectedArmorType = defaultArmor

	-- Set dropdown text
	local displayText = (defaultArmor == "ALL") and ALL or L[defaultArmor:sub(1,1) .. defaultArmor:sub(2):lower()]
	UIDropDownMenu_SetText(parent.armorTypeDrop, displayText)

	-- Armor type list
	local ARMOR_TYPES = {
		{ value = "ALL",    text = ALL },
		{ value = "CLOTH",  text = L["Cloth"] },
		{ value = "LEATHER",text = L["Leather"] },
		{ value = "MAIL",   text = L["Mail"] },
		{ value = "PLATE",  text = L["Plate"] },
	}

	UIDropDownMenu_Initialize(parent.armorTypeDrop, function(self, level)
		if not level or level ~= 1 then return end

		for _, entry in ipairs(ARMOR_TYPES) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = entry.text
			info.value = entry.value
			info.checked = (parent.selectedArmorType == entry.value)

			info.func = function()
				parent.selectedArmorType = entry.value
				UIDropDownMenu_SetText(parent.armorTypeDrop, entry.text)
				CCS:ApplyLootFilters()
			end

			UIDropDownMenu_AddButton(info, level)
		end
	end)

	---------------------------------------------
	-- Reset Filters Button
	---------------------------------------------
	parent.resetFilters = CreateFrame("Button", nil, footer)
	parent.resetFilters:SetSize(24, 24)

	-- Icon
	local resetIcon = parent.resetFilters:CreateTexture(nil, "ARTWORK")
	resetIcon:SetAllPoints()
	resetIcon:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\remove_filter.png")
	parent.resetFilters.icon = resetIcon

	-- Normal border
	local resetBorder = parent.resetFilters:CreateTexture(nil, "OVERLAY")
	resetBorder:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	resetBorder:SetAllPoints()
	resetBorder:SetVertexColor(1, 1, 1, 0)
	parent.resetFilters.border = resetBorder

	-- Hover glow
	local glow = parent.resetFilters:CreateTexture(nil, "HIGHLIGHT")
	glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	glow:SetBlendMode("ADD")
	glow:SetPoint("TOPLEFT", parent.resetFilters, "TOPLEFT", -8, 8)
	glow:SetPoint("BOTTOMRIGHT", parent.resetFilters, "BOTTOMRIGHT", 8, -8)
	glow:SetVertexColor(unpack(CCS.StyleColor.highlight))
	glow:Hide()
	parent.resetFilters.glow = glow

	parent.resetFilters:SetScript("OnEnter", function(self)	
			self.glow:Show() 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(EVENTTRACE_APPLY_DEFAULT_FILTER)
			GameTooltip:Show()
	end)
	parent.resetFilters:SetScript("OnLeave", function(self)	
			self.glow:Hide()
			GameTooltip:Hide()
	end)

	parent.resetFilters:SetPoint("RIGHT", parent.slotDrop, "LEFT", -4, 0)

	-- Click: Reset all filters
	parent.resetFilters:SetScript("OnClick", function()
	PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)

	-------------------------------------------------
	-- Reset Class/Spec
	-------------------------------------------------
	local _, _, playerClassID = UnitClass("player")
	local currentSpecIndex = GetSpecialization()
	local className = GetClassInfo(playerClassID)

	local specID, specName = nil, nil

	if currentSpecIndex then
		local id, name = GetSpecializationInfo(currentSpecIndex)

		-- Detect invalid/Initial spec
		if id and name and id < 1400 then
			specID = id
			specName = name
		end
	end

	parent.selectedClassID = playerClassID
	parent.selectedSpecID  = specID   -- nil if no real spec

	if specName then
		UIDropDownMenu_SetText(parent.classSpecDrop, className .. " – " .. (specName or ""))
	else
		UIDropDownMenu_SetText(parent.classSpecDrop, className)
	end


		-------------------------------------------------
		-- Reset Slot
		-------------------------------------------------
		wipe(CCS.FooterFilters.selectedSlots)
		wipe(parent.selectedSlots)

		UIDropDownMenu_SetText(parent.slotDrop, L["Slot"]..": "..ALL)

		local dropName = parent.slotDrop:GetName()

		local allButton = _G[dropName.."Button1"]
		if allButton then
			allButton.checked = true
			if allButton.SetChecked then
				allButton:SetChecked(true)
			elseif allButton.Check then
				allButton.Check:Show()
			end
		end

		local i = 2
		while true do
			local btn = _G[dropName.."Button"..i]
			if not btn then break end
			btn.checked = false
			if btn.SetChecked then
				btn:SetChecked(false)
			elseif btn.Check then
				btn.Check:Hide()
			end
			i = i + 1
		end

		local level = UIDROPDOWNMENU_MENU_LEVEL or 1
		CloseDropDownMenus()

		-------------------------------------------------
		-- Reset Instance Sources (Raids, Bosses, Dungeons)
		-------------------------------------------------
		-- Clear all raid and boss selections
		wipe(CCS.FooterFilters.selectedBosses)
		wipe(CCS.FooterFilters.selectedInstances)

		-- Clear Class Sets
		CCS.FooterFilters.includeClassSets = false

		-- Reset dropdown text
		UIDropDownMenu_SetText(parent.instanceDrop, DUNGEONS.."/"..RAIDS.." ("..ALL..")")

		-- Update visual indicators (bullets, checkmarks)
		UpdateRaidIndicators(parent)
		UpdateInstanceDropdownText(parent)

		-- Close dropdown to avoid stale Level-2 menus
		CloseDropDownMenus()

		-------------------------------------------------
		-- Reset Primary Stat
		-------------------------------------------------
		local _, _, _, _, _, primaryStat = GetSpecializationInfo(currentSpecIndex)
		local PRIMARY_STAT_MAP = {
			[1] = "STRENGTH",
			[2] = "AGILITY",
			[4] = "INTELLECT",
		}
		parent.selectedPrimaryStat = "ALL" --PRIMARY_STAT_MAP[primaryStat]

		for _, stat in ipairs(primaryStats) do
			if stat.value == parent.selectedPrimaryStat then
				UIDropDownMenu_SetText(parent.primaryStatDrop, stat.text)
				break
			end
		end

		-------------------------------------------------
		-- Reset Secondary Stat Toggles
		-------------------------------------------------
		parent.statCrit.enabled = false
		parent.statHaste.enabled = false
		parent.statMastery.enabled = false
		parent.statVers.enabled = false

		parent.statCrit.icon:SetAlpha(0.35)
		parent.statCrit.border:SetAlpha(0.10)
		parent.statHaste.icon:SetAlpha(0.35)
		parent.statHaste.border:SetAlpha(0.10)
		parent.statMastery.icon:SetAlpha(0.35)
		parent.statMastery.border:SetAlpha(0.10)
		parent.statVers.icon:SetAlpha(0.35)
		parent.statVers.border:SetAlpha(0.10)

		-------------------------------------------------
		-- Reset Dungeon/Raid Checkboxes
		-------------------------------------------------
		parent.includeDungeons:SetChecked(true)
		parent.includeRaids:SetChecked(true)

		-------------------------------------------------
		-- Reset Item Level
		-------------------------------------------------
		parent.selectedIlvl = CCS.seasonCap
		UIDropDownMenu_SetText(parent.ilvlDrop, ITEM_LEVEL_ABBR..": "..CCS.seasonCap)

		-------------------------------------------------
		-- Reset Armor Type
		-------------------------------------------------
		local defaultArmor = DEFAULT_ARMOR_BY_CLASS[playerClassID] or "ALL"
		parent.selectedArmorType = defaultArmor

		local displayArmorText
		if defaultArmor == "ALL" then
			displayArmorText = ALL
		else
			local key = defaultArmor:sub(1,1) .. defaultArmor:sub(2):lower()
			displayArmorText = L[key]
		end

		UIDropDownMenu_SetText(parent.armorTypeDrop, displayArmorText)

		-------------------------------------------------
		-- Apply Filters
		-------------------------------------------------
		CCS:ApplyLootFilters()
	end)

    return footer
end

local function ApplyHeaderStyle(self)
    local header = self.header
    if not header then return end

    -------------------------------------------------
    -- Title
    -------------------------------------------------
    header.title:SetFont(
        option("fontname_gf_title"),
        option("fontsize_gf_title"),
        CCS.textoutline
    )
    header.title:SetTextColor(unpack(option("fontcolor_gf_title")))

    if option("showfontshadow") then
        header.title:SetShadowColor(unpack(option("fontshadowcolor")))
        header.title:SetShadowOffset(option("fontshadowx"), option("fontshadowy"))
    else
        header.title:SetShadowColor(0,0,0,0)
    end

    -------------------------------------------------
    -- Column Labels (Item, Primary, Source)
    -------------------------------------------------
    local labels = { header.item, header.primary, header.source }
    for _, fs in ipairs(labels) do
        fs:SetFont(
            option("fontname_gf_header"),
            option("fontsize_gf_header"),
            CCS.textoutline
        )
        fs:SetTextColor(unpack(option("fontcolor_gf_header")))

        if option("showfontshadow") then
            fs:SetShadowColor(unpack(option("fontshadowcolor")))
            fs:SetShadowOffset(option("fontshadowx"), option("fontshadowy"))
        else
            fs:SetShadowColor(0,0,0,0)
        end
    end
end

local function ApplyRowStyle(self)
    if not self.rows then return end

    local highlight   = option("row_highlight") or {1,1,1,0.08}
    local bgEven      = option("row_bg_even") or {.247,.247,.247,.6}
    local bgOdd       = option("row_bg_odd")  or {.17,.17,.17,.4}

    for index, row in ipairs(self.rows) do
        -------------------------------------------------
        -- Alternating background
        -------------------------------------------------
        if (index % 2 == 0) then
            row.bgAlt:SetColorTexture(unpack(bgEven))
        else
            row.bgAlt:SetColorTexture(unpack(bgOdd))
        end

        -------------------------------------------------
        -- Hover highlight
        -------------------------------------------------
        row:SetScript("OnEnter", function(self)
            self.bg:SetColorTexture(unpack(highlight))
        end)
        row:SetScript("OnLeave", function(self)
            self.bg:SetColorTexture(1,1,1,0)
        end)

        -------------------------------------------------
        -- Item Name
        -------------------------------------------------
        row.name:SetFont(
            option("fontname_gf_itemname") or CCS.fontname,
            option("fontsize_gf_itemname") or 11,
            CCS.textoutline
        )
        if option("showfontshadow") then
            row.name:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            row.name:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        else
            row.name:SetShadowColor(0,0,0,0)
        end

        -------------------------------------------------
        -- Item Type / Slot line
        -------------------------------------------------
        row.type:SetFont(
            option("fontname_gf_itemslot") or CCS.fontname,
            option("fontsize_gf_itemslot") or 10,
            CCS.textoutline
        )
        row.type:SetTextColor(unpack(option("fontcolor_gf_itemslot") or {1,1,1,1}))
        if option("showfontshadow") then
            row.type:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            row.type:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        else
            row.type:SetShadowColor(0,0,0,0)
        end

        -------------------------------------------------
        -- Secondary stats (crit/haste/mastery/vers)
        -------------------------------------------------
        local statFont  = option("fontname_gf_stats") or CCS.fontname
        local statSize  = option("fontsize_gf_stats") or 11

        local statFS = { row.crit, row.haste, row.mastery, row.vers }
        for _, fs in ipairs(statFS) do
            fs:SetFont(statFont, statSize, CCS.textoutline)
            if option("showfontshadow") then
                fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
            else
                fs:SetShadowColor(0,0,0,0)
            end
        end

        -------------------------------------------------
        -- Source (dungeon/raid)
        -------------------------------------------------
        row.source:SetFont(
            option("fontname_gf_dungeon") or CCS.fontname,
            option("fontsize_gf_dungeon") or 11,
            CCS.textoutline
        )
        row.source:SetTextColor(unpack(option("fontcolor_gf_dungeon") or {.6,.85,1,1}))

        -------------------------------------------------
        -- Source boss
        -------------------------------------------------
        row.sourceboss:SetFont(
            option("fontname_gf_boss") or CCS.fontname,
            option("fontsize_gf_boss") or 11,
            CCS.textoutline
        )
        row.sourceboss:SetTextColor(unpack(option("fontcolor_gf_boss") or {1,1,1,1}))
    end
end

local function ApplyFooterStyle(self)
    local footer = self.footer
    if not footer then return end

    -------------------------------------------------
    -- Footer background color
    -------------------------------------------------
    local bg = option("bgcolor_gearfinderfooter") or {0,0,0,0.85}
    footer:SetBackdropColor(unpack(bg))

    -------------------------------------------------
    -- Dropdowns (re-skin + text styling)
    -------------------------------------------------
    local dropdowns = {
        self.classSpecDrop,
        self.slotDrop,
        self.instanceDrop,
        self.primaryStatDrop,
        self.ilvlDrop,
        self.armorTypeDrop,
    }

    for _, drop in ipairs(dropdowns) do
        if drop then
            -------------------------------------------------
            -- Re-apply CCS dropdown skin
            -------------------------------------------------
            CCS.SkinDropdown(drop, drop:GetName())
        end
    end

    -------------------------------------------------
    -- Checkboxes (re-skin + label styling)
    -------------------------------------------------
    local checkboxes = {
        self.includeDungeons,
        self.includeRaids,
    }

    for _, cb in ipairs(checkboxes) do
        if cb then
            -------------------------------------------------
            -- Re-apply CCS checkbox skin
            -------------------------------------------------
            CCS.SkinCheckbox(cb)
        end
    end

    -------------------------------------------------
    -- Stat buttons (crit/haste/mastery/vers)
    -------------------------------------------------
    local statButtons = {
        self.statCrit,
        self.statHaste,
        self.statMastery,
        self.statVers,
    }

    for _, btn in ipairs(statButtons) do
        if btn then
            -- Enabled/disabled alpha
            if btn.enabled then
                btn.icon:SetAlpha(1.0)
                btn.border:SetAlpha(0.35)
            else
                btn.icon:SetAlpha(0.35)
                btn.border:SetAlpha(0.10)
            end

            -- Glow color (theme highlight)
            if btn.glow then
                btn.glow:SetVertexColor(unpack(CCS.StyleColor.highlight))
            end
        end
    end
    -------------------------------------------------
    -- Reset Filters Button
    -------------------------------------------------
    local reset = self.resetFilters
    if reset then
        -- Icon alpha
        reset.icon:SetAlpha(1.0)

        -- Border alpha
        reset.border:SetAlpha(0.25)

        -- Glow color
        if reset.glow then
            reset.glow:SetVertexColor(unpack(CCS.StyleColor.highlight))
        end
    end

    -------------------------------------------------
    -- BIS Toggle Button
    -------------------------------------------------
    local bisbtn = self.bisToggle
    if bisbtn then
        -- Icon alpha
        bisbtn.icon:SetAlpha(1.0)

        -- Border alpha
        bisbtn.border:SetAlpha(0.25)

        -- Glow color
        if bisbtn.glow then
            bisbtn.glow:SetVertexColor(unpack(CCS.StyleColor.highlight))
        end
    end
	
end

local function ApplyStyle(self)
    ApplyHeaderStyle(self)
    ApplyRowStyle(self)
    ApplyFooterStyle(self)
end

function module:Initialize(onlyStyle)
    if CCS.AreSecretsDisabled() then 
        CCS.initall = true
        return 
    end
	if onlyStyle == nil then onlyStyle = false end
	
    if option("showgearfinder") ~= true then 
		if _G["ccsgf_sf"] ~= nil then _G["ccsgf_sf"]:Hide() end
		if _G["ccsgf_btn"] ~= nil then _G["ccsgf_btn"]:Hide() end
		return 
	end

	if InCombatLockdown() then CCS.incombat = true return end
	
    local textstring = ""
	local ccsgf_af = _G["ccsgf_af"] or CreateFrame("Frame", "ccsgf_af", CharacterFrame, "SecureHandlerBaseTemplate");
    local ccsgf_sf = _G["ccsgf_sf"] or CreateFrame("Frame", "ccsgf_sf", CharacterFrame, "SecureHandlerBaseTemplate");
	local ccsgf_gf = _G["ccsgf_gf"] or CreateFrame("Frame", "ccsgf_gf", ccsgf_sf, "SecureHandlerBaseTemplate")
    local rf_bg = _G["ccsgf_sf_bg"] or ccsgf_sf:CreateTexture("ccsgf_sf_bg", "BACKGROUND", nil, 1)        
    local rf_topbar = _G["ccsgf_sf_tb"] or ccsgf_sf:CreateTexture("ccsgf_sf_tb", "BACKGROUND", nil, 2)
    local rf_topstreaks = _G["ccsgf_sf_ts"] or ccsgf_sf:CreateTexture("ccsgf_sf_ts", "BACKGROUND", nil, 2)
    local rf_bottombar = _G["ccsgf_sf_bb"] or ccsgf_sf:CreateTexture("ccsgf_sf_bb", "BACKGROUND", nil, 2)
	local totalRows = 10
	local maxHeight = 600
	local rowWidth, rowHeight, rowSpacing = 700, 46, 2 -- height is 23 x 2 lines 720

	ccsgf_sf:SetScale(option("gear_gf_scale"))

	ccsgf_gf:SetAllPoints(ccsgf_sf)


	if not ccsgf_sf:IsVisible() then
		ccsgf_sf:Hide()
	end
	ccsgf_sf.currentSortBy = ccsgf_sf.currentSortBy or "NAME"
	ccsgf_sf.currentDir    = ccsgf_sf.currentDir    or "Descending"
	
---- Create the button
    local ccsgf_btn = _G["ccsgf_btn"] or CreateFrame("Button", "ccsgf_btn", PaperDollFrame)
	ccsgf_btn:SetSize(20, 20)
	ccsgf_btn:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", -0.5, -15)
	ccsgf_btn:SetPoint("TOPRIGHT", CharacterFrameCloseButton, "BOTTOMRIGHT", 0, -44)
	ccsgf_btn:SetFrameStrata("HIGH")

	ccsgf_btn._ccs_OnEnter = function(self)
		CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11)
		GameTooltip_SetTitle(CCS.tooltip, format(L["CATEGORY_GEAR-FINDER"], ""))
		GameTooltip_AddNormalLine(CCS.tooltip, CLICK_HERE_FOR_MORE_INFO)
		CCS.tooltip:Show()
	end

	ccsgf_btn._ccs_OnLeave = function(self)
		CCS.tooltip:Hide()
	end
	if option("showgf_altbtn") then
		local ccsgf_btn_tex = ccsgf_btn.tex or ccsgf_btn:CreateTexture(nil, "ARTWORK")
		ccsgf_btn.tex = ccsgf_btn_tex
		CCS:ApplyIconStyle(ccsgf_btn, "ightarrow", 17) -- We just want the style without the icon.  We set the icon in a few lines.
		ccsgf_btn_tex:SetAllPoints()
		ccsgf_btn_tex:Show()
		ccsgf_btn_tex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\loot.png")
	else
		CCS:ApplyIconStyle(ccsgf_btn, "rightarrow", 17)
		if ccsgf_btn and ccsgf_btn.tex ~= nil then
			ccsgf_btn.tex:Hide()
		end
	end

	-- Click behavior
	ccsgf_btn:SetScript("OnClick", function(self, button)
		PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)

		if InCombatLockdown() then
			PlaySound(8959)
			RaidNotice_AddMessage(RaidBossEmoteFrame, ERR_AFFECTING_COMBAT, ChatTypeInfo.SYSTEM)
			return
		end
		if C_AddOns.IsAddOnLoaded("ClassCodex") == true then
			if ClassCodexPanel and ClassCodexPanel:IsVisible() then ClassCodexPanel:Hide() end
		end

		local sm  = _G.ccsm_sf
		local rf  = _G.ccsrf_sf
		local gf  = _G.ccsgf_sf

		-- Hide other frames if they exist
		if sm and sm:IsShown() then sm:Hide() end
		if rf and rf:IsShown() then rf:Hide() end

		-- Toggle this frame
		if gf:IsShown() then
			gf:Hide()
		else
			gf:Show()
		end
	end)

	ccsgf_btn:Show()

    ccsgf_sf:ClearAllPoints()
	
	local hpad = option("hpad") or 279
	local offsetX = (60 + hpad)

	ccsgf_af:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", offsetX, 0)
	ccsgf_af:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT", offsetX, 0)
	ccsgf_sf:SetPoint("TOPLEFT", ccsgf_af, "TOPRIGHT", 0, 0); 
	ccsgf_sf:SetSize(rowWidth+30, 640)  
    ccsgf_sf:SetFrameStrata("TOOLTIP")
    ccsgf_sf:SetShown(ccsgf_sf:IsVisible())

	local bgr, bgg, bgb, bgalpha = unpack(option("bgcolor_gearfinder"))

    rf_bg:ClearAllPoints()
    rf_bg:SetAllPoints()
    rf_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
	rf_bg:SetColorTexture(bgr,bgg,bgb,bgalpha)

    rf_topbar:ClearAllPoints()
    rf_topbar:SetPoint("TOPLEFT", ccsgf_sf, "TOPLEFT")
    rf_topbar:SetPoint("TOPRIGHT", ccsgf_sf, "TOPRIGHT")
    rf_topbar:SetHeight(16)
    rf_topbar:SetTexture("1723833")
    rf_topbar:SetTexCoord(0, 1, 0.586, .734)

    rf_topstreaks:ClearAllPoints()
    rf_topstreaks:SetPoint("TOPLEFT", rf_topbar, "BOTTOMLEFT")
    rf_topstreaks:SetPoint("TOPRIGHT", rf_topbar, "BOTTOMRIGHT")
    rf_topstreaks:SetHeight(43)
    rf_topstreaks:SetTexture("1723833")
    rf_topstreaks:SetTexCoord(0, 1, 0, .328)

    rf_bottombar:ClearAllPoints()
    rf_bottombar:SetPoint("BOTTOMLEFT", ccsgf_sf, "BOTTOMLEFT")
    rf_bottombar:SetPoint("BOTTOMRIGHT", ccsgf_sf, "BOTTOMRIGHT")
    rf_bottombar:SetHeight(16)

    rf_bottombar:SetTexture("4556093")
    rf_bottombar:SetTexCoord(0, .75, 0, .082) 
	
    -------------------------------------------------
    -- FauxScrollFrame + fixed rows
    -------------------------------------------------
    local scrollFrame = ccsgf_gf_scf
    if not scrollFrame then
        scrollFrame = CreateFrame("ScrollFrame", "ccsgf_gf_scf", ccsgf_gf, "FauxScrollFrameTemplate")
    end

    scrollFrame:ClearAllPoints()
    scrollFrame:SetPoint("TOPLEFT", ccsgf_gf, "TOPLEFT", 10, -78)
    scrollFrame:SetPoint("BOTTOMRIGHT", ccsgf_gf, "BOTTOMRIGHT", -30, 80) -- leave room for scrollbar
    scrollFrame:Show()

	-------------------------------------------------
	-- Shift the default scrollbar to the right
	-------------------------------------------------
	local sb = _G["ccsgf_gf_scfScrollBar"]
	if sb then
		sb:ClearAllPoints()
		sb:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 12, -18)
		sb:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 12, 20)
	end

    local rowWidth, rowHeight, rowSpacing = 700, 46, 2
    local totalRows = 10

    -------------------------------------------------
    -- Create reusable loot rows (children of ccsgf_gf)
    -------------------------------------------------

	if module.rows == nil then
		CCS.LootRows = CCS.LootRows or {}

		for i = 1, totalRows do
			local row = CCS.LootRows[i]
			if not row then
				row = CCS:CreateLootRow(i, ccsgf_gf, rowWidth, rowHeight)
				CCS.LootRows[i] = row
			end

			row:ClearAllPoints()
			if i == 1 then
				row:SetPoint("TOPLEFT", ccsgf_gf, "TOPLEFT", 10, -78)
			else
				row:SetPoint("TOPLEFT", CCS.LootRows[i-1], "BOTTOMLEFT", 0, -rowSpacing)
			end
		end
		
		module.rows   = CCS.LootRows
	end
    -------------------------------------------------
    -- Hook FauxScrollFrame scroll handler
    -------------------------------------------------
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, function()
            if CCS.CurrentResults then
                CCS.UpdateLootScroll(CCS.CurrentResults)
            end
        end)
    end)

	-------------------------------------------------
	-- Create Loot Header (fixed, non-scrolling)
	-------------------------------------------------
	if module.header == nil then
		local header = CCS:CreateLootHeader(ccsgf_gf, rowWidth, rowHeight, "Int")  -- or "Str"/"Agi"
		header:SetPoint("TOPLEFT", ccsgf_gf, "TOPLEFT", 10, 0)
		header:SetPoint("TOPRIGHT", ccsgf_gf, "TOPRIGHT", -10, 0)
		module.header = header
	end
	-------------------------------------------------
	-- Create Loot Footer (houses our filter controls)
	-------------------------------------------------
	if module.footer == nil then
		local footer = CCS:CreateLootFooter(ccsgf_gf)
		module.footer = footer
		module.classSpecDrop   = ccsgf_gf.classSpecDrop
		module.slotDrop        = ccsgf_gf.slotDrop
		module.instanceDrop    = ccsgf_gf.instanceDrop
		module.primaryStatDrop = ccsgf_gf.primaryStatDrop
		module.ilvlDrop        = ccsgf_gf.ilvlDrop
		module.armorTypeDrop   = ccsgf_gf.armorTypeDrop
		module.includeDungeons = ccsgf_gf.includeDungeons
		module.includeRaids    = ccsgf_gf.includeRaids
		module.statCrit        = ccsgf_gf.statCrit
		module.statHaste       = ccsgf_gf.statHaste
		module.statMastery     = ccsgf_gf.statMastery
		module.statVers        = ccsgf_gf.statVers
		module.resetFilters    = ccsgf_gf.resetFilters
		module.bisToggle	   = ccsgf_gf.bisToggle
	end
	-------------------------------------------------
	-- apply styles (for option changes)
	-------------------------------------------------
	module.frame  = ccsgf_gf
	module.scrollFrame = scrollFrame
	-- Filter controls
	if onlyStyle == true then
		ApplyStyle(module)
		if CCS.lastChangedOption == "showgearfinder" then
			CCS:ApplyLootFilters()
		end
	end
	-------------------------------------------------
	-- Apply filters and show data!  Yay!
	-------------------------------------------------
	if onlyStyle == false then
		CCS:ApplyLootFilters()
	end

end

function CCS.gearfinderEventHandler(event, ...)
    local arg1, arg2, arg3 = ...
	if option("showgearfinder") == false then return end

	if CCS.CurrentVersion ~= CCS.RETAIL then return end

    if event == "CCS_EVENT_OPTIONS" and option("showgearfinder") == false then
        if _G["ccsgf_btn1"] ~= nil then _G["ccsgf_btn1"]:Hide() end
    end
end