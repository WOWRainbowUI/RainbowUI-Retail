---------------------------------------------------------------------
-- File: Cell\RaidDebuffs\RaidDebuffs_Legion.lua
-- Author: enderneko (enderneko-dev@outlook.com)
-- Created : 2022-08-05 16:05:39 +08:00
-- Modified: 2025-02-20 16:08 +08:00
---------------------------------------------------------------------

local _, Cell = ...
local F = Cell.funcs

local debuffs = {
    [822] = { -- 破碎群岛
        [1790] = { -- 鬼母阿娜
            219045,
        },
        [1956] = { -- 阿波克隆
        },
        [1883] = { -- 布鲁塔卢斯
        },
        [1774] = { -- 卡拉米尔
            217877,
        },
        [1789] = { -- 冷血的杜贡
            219812,
            219610,
        },
        [1795] = { -- 浮骸
            223373,
        },
        [1770] = { -- 胡墨格里斯
            216822,
        },
        [1769] = { -- 勒凡图斯
            217206,
        },
        [1884] = { -- 马利费库斯
        },
        [1783] = { -- 魔王纳扎克
            219861,
            219349,
        },
        [1749] = { -- 尼索格
            212852,
        },
        [1763] = { -- 沙索斯
        },
        [1885] = { -- 丝瓦什
        },
        [1756] = { -- 夺魂者
        },
        [1796] = { -- 凋零者吉姆
        },
    },

    [768] = { -- 翡翠梦魇
        ["general"] = {
            222771,
            222786,
            222719,
            223912,
            221028,
        },
        [1703] = { -- 尼珊德拉
            203096,
            205043,
            204463,
        },
        [1738] = { -- 伊格诺斯，腐蚀之心
            208929,
            210984,
            209469,
            208931,
            210099,
        },
        [1744] = { -- 艾乐瑞瑟·雷弗拉尔
            215443,
            210850,
            215288,
            210229,
            215582,
        },
        [1667] = { -- 乌索克
            198108,
            198006,
            197943,
            197942,
            197980,
        },
        [1704] = { -- 梦魇之龙
            203110,
            203770,
            203690,
            203124,
            203102,
        },
        [1750] = { -- 塞纳留斯
            210279,
        },
        [1726] = { -- 萨维斯
            206005,
            206651,
            209158,
        },
    },

    [861] = { -- 勇气试炼
        ["general"] = {
        },
        [1819] = { -- 奥丁
            228030,
            229584,
            197961,
            228683,
            227959,
            228915,
        },
        [1830] = { -- 高姆
            227539,
            227566,
            227570,
            228226,
            228246,
            228250,
        },
        [1829] = { -- 海拉
            227903,
            228058,
            228054,
            193367,
            227982,
            232488,
        },
    },

    [786] = { -- 暗夜要塞
        ["general"] = {
            224440,
            230994,
            222079,
            222101,
            224995,
            225583,
            234585,
            224944,
            206847,
        },
        [1706] = { -- 斯考匹隆
            204531,
            204483,
        },
        [1725] = { -- 时空畸体
            206607,
        },
        [1731] = { -- 崔利艾克斯
            208506,
            206788,
            206641,
            208924,
            206798,
        },
        [1751] = { -- 魔剑士奥鲁瑞尔
            212587,
            213328,
            212494,
            224234,
            212647,
            213166,
            213621,
        },
        [1762] = { -- 提克迪奥斯
            206480,
            206365,
            212795,
            216040,
            208230,
            225003,
            224944,
            216024,
            224982,
        },
        [1713] = { -- 克洛苏斯
            206677,
            205344,
        },
        [1761] = { -- 高级植物学家特尔安
            218424,
            218502,
            218342,
        },
        [1732] = { -- 占星师艾塔乌斯
            206936,
            205649,
            206464,
            207720,
            206585,
            206388,
            206589,
            206965,
        },
        [1743] = { -- 大魔导师艾利桑德
            210387,
            209973,
            209244,
            209598,
            211887,
        },
        [1737] = { -- 古尔丹
            206222,
            206883,
            208536,
            208802,
            206384,
            221606,
            206896,
        },
    },

    [875] = { -- 萨格拉斯之墓
        ["general"] = {
            240706,
            239810,
            240737,
            241171,
            241009,
            239666,
            241234,
            241237,
            241116,
            241703,
            243298,
            33086,
            240599,
            241276,
        },
        [1862] = { -- 格罗斯
            233279,
            230345,
            231363,
            236329,
        },
        [1867] = { -- 恶魔审判庭
            233430,
            233983,
            248713,
        },
        [1856] = { -- 哈亚坦
            231770,
            231998,
            234016,
        },
        [1903] = { -- 月之姐妹
            236603,
            234995,
            234996,
            236519,
            236547,
            236550,
            239264,
            237351,
            236712,
            237561,
            236305,
        },
        [1861] = { -- 主母萨丝琳
            230959,
            230201,
            234661,
            230139,
            232754,
            232913,
            240169,
            230362,
        },
        [1896] = { -- 绝望的聚合体
            236449,
            236515,
            236513,
            235989,
            236340,
            236138,
        },
        [1897] = { -- 戒卫侍女
            235117,
            235534,
            235538,
        },
        [1873] = { -- 堕落的化身
            239739,
            236494,
        },
        [1898] = { -- 基尔加丹
            239155,
            234310,
            236710,
            239932,
        },
    },

    [959] = { -- 侵入点
        [2010] = { -- 主母芙努娜
            247361,
            247389,
            247411,
        },
        [2011] = { -- 妖女奥露拉黛儿
            247551,
            247544
        },
        [2012] = { -- 审判官梅托
            247495,
            247492,
        },
        [2013] = { -- 奥库拉鲁斯
            247332,
            247318,
        },
        [2014] = { -- 索塔纳索尔
            247698,
            247444,
        },
        [2015] = { -- 深渊领主维尔姆斯
            247731,
            247739,
        },
    },

    [946] = { -- 安托鲁斯，燃烧王座
        ["general"] = {
        },
        [1992] = { -- 加洛西灭世者
            244410, -- 屠戮
            244536, -- 邪能轰炸
        },
        [1987] = { -- 萨格拉斯的恶犬
            244767, -- 荒芜之径
            244056, -- 虹吸腐蚀
            248819, -- 虹吸
            244057, -- 燃烧腐蚀
            248815, -- 点燃
        },
        [1997] = { -- 安托兰统帅议会
            244172, -- 灵能突袭
            244420, -- 混乱脉冲
            245103, -- 凋零射击
            244892, -- 弱点攻击
        },
        [1985] = { -- 传送门守护者哈萨贝尔
            244613,
            245157,
            244952,
            244849,
            245050,
            196207,
            245118,
            245075,
        },
        [2025] = { -- 生命的缚誓者艾欧娜尔
            248326,
        },
        [2009] = { -- 猎魂者伊墨纳尔
            248424,
            247641,
            247962,
            247552,
            247367,
            247565,
            248255,
            247687,
            247932,
            250255,
        },
        [2004] = { -- 金加洛斯
            246706,
            244312,
        },
        [1983] = { -- 瓦里玛萨斯
            244042,
            244093,
            243961,
        },
        [1986] = { -- 破坏魔女巫会
            246763,
            245586,
            245518,
            244899,
            244899,
            253538,
        },
        [1984] = { -- 阿格拉玛
            245995,
            244291,
            246014,
            243431,
        },
        [2031] = { -- 寂灭者阿古斯
            248499,
            250669,
            251570,
            257299,
        },
    },

    [727] = { -- 噬魂之喉
        ["general"] = {
        },
        [1502] = { -- 堕落君王伊米隆
            193211, -- 黑暗鞭笞
            193364, -- 亡者嚎叫
            193460, -- 灾祸
        },
        [1512] = { -- 哈布隆
            194325, -- 破碎
            194216, -- 空间之镰
            194266, -- 虚空裂痕
        },
        [1663] = { -- 海拉
            197264, -- 海洋污染
            227233, -- 腐化咆哮
            197858, -- 喧闹之水
        },
    },

    [767] = { -- 奈萨里奥的巢穴
        ["general"] = {
            193585, -- 束缚
            193941, -- 穿刺碎片
            183465, -- 粘性胆汁
            193639, -- 噬骨咀嚼
        },
        [1662] = { -- 洛克莫拉
            192799, -- 窒息之尘
        },
        [1665] = { -- 乌拉罗格·塑山
            198496, -- 破甲
        },
        [1673] = { -- 纳拉萨斯
            210150, -- 毒性污秽
            199178, -- 尖刺之舌
            205549, -- 腐坏之喉
            199705, -- 吞噬
        },
        [1687] = { -- 地底之王达古尔
            200732, -- 熔岩冲击
            200404, -- 熔岩波
            200154, -- 燃烧之恨
            201953, -- 水晶之刺
        },
    },

    [707] = { -- 守望者地窟
        ["general"] = {
        },
        [1467] = { -- 提拉宋·萨瑟利尔
            202913,
            202919,
            214625,
        },
        [1695] = { -- 审判官托蒙托鲁姆
            203685, -- 石化血肉
            204899, -- 石块
            199917, -- 暗影冲撞
            206019, -- 腐蚀之触
            214804, -- 腐蚀之种
            200904, -- 侵蚀灵魂
        },
        [1468] = { -- 阿什高姆
            192519, -- 熔岩
            192520, -- 火山
        },
        [1469] = { -- 格雷泽
            195032, -- 辐射
            214893, -- 脉冲
            194945, -- 纠缠凝视
        },
        [1470] = { -- 科达娜·邪歌
            197541, -- 自爆
            213583, -- 侵蚀之影
            197333, -- 邪能战刃
            197941, -- 艾露恩之光
        },
    },

    [945] = { -- 执政团之座
        ["general"] = {
            245735, -- 黑暗凋敝
            246677, -- 压制力场
            248239, -- 黑暗拼接
            245736, -- 虚空碎裂
            245748, -- 腐蚀之触
            248298, -- 尖啸
            245706, -- 毁灭打击
            245722, -- 黑暗伤痕
            245510, -- 腐蚀虚空
            248184, -- 黑暗鞭笞
            248133, -- 冥河冲击
            246697, -- 消除烙印
            245727, -- 吞噬精华
            246900, -- 黑暗爆发
        },
        [1979] = { -- 晋升者祖拉尔
            244653, -- 锁定
        },
        [1980] = { -- 萨普瑞什
            247245, -- 幽影侧击
        },
        [1981] = { -- 总督奈扎尔
            1604, -- 眩晕
            244751, -- 黑暗咆哮
            244916, -- 虚空鞭笞
        },
        [1982] = { -- 鲁拉
            245289, -- 虚空冲击
        },
    },

    [900] = { -- 永夜大教堂
        ["general"] = {
            236954, -- 邪恶利齿
            239288, -- 燃烧的绳索
            238583, -- 吞噬魔法
            236975, -- 锯齿顺劈
            238688, -- 窒息藤蔓
            239022, -- 邪能箭
            238991, -- 倒刺荆棘
            237391, -- 诱惑香氛
            238674, -- 锁定
            239217, -- 眩目闪光
        },
        [1905] = { -- 阿格洛诺克斯
            243613, -- 锁定
            236524, -- 毒性孢子
        },
        [1906] = { -- 轻蔑的萨什比特
            237726, -- 轻蔑凝视
            237276, -- 粉碎之击
        },
        [1904] = { -- 多玛塔克斯
            241609, -- 灼热之面
        },
        [1878] = { -- 孟菲斯托斯
            233963, -- 恶魔突起
            233177, -- 腐臭蜂群
            234830, -- 黑暗孤寂
        },
    },

    [777] = { -- 突袭紫罗兰监狱
        ["general"] = {
        },
        [1693] = { -- 溃面
            202266, -- 黏糊糊的黏质
        },
        [1694] = { -- 颤栗之喉
            201379, -- 冰霜吐息
        },
        [1702] = { -- 鲜血公主萨安娜
            202779, -- 鲜血公主的精华
            202792, -- 疯狂嗜血
            203364, -- 鲜血浸没
        },
        [1686] = { -- 夺心者卡什
            201146, -- 狂乱
            197783, -- 暗影冲撞
            201172, -- 无尽黑暗
        },
        [1688] = { -- 米尔菲丝·法力风暴
            201159, -- 德尔塔手指型激光发射器究极版
        },
        [1696] = { -- 阿努贝斯特
            202217, -- 颚骨打击
            202341, -- 穿刺
            202300, -- 毒液喷吐
        },
        [1697] = { -- 赛尔奥隆
            202414, -- 剧毒喷射
            202306, -- 潜伏猎手
        },
        [1711] = { -- 邪能领主贝图格
            203619, -- 混沌能量
            203641, -- 邪能挥砍
            202361, -- 处决
        },
    },

    [800] = { -- 群星庭院
        ["general"] = {
            212773, -- 强光克敌
            209027, -- 压制打击
            209036, -- 丢火把
            209404, -- 封印魔法
            209413, -- 镇压
            209516, -- 魔法之牙
            211464, -- 邪能引爆
            209512, -- 分裂的能量
            211391, -- 邪焰泥浆
            373552, -- 催眠蝙蝠
            373570, -- 催眠
            373607, -- 暗影屏障
            213304, -- 义愤填膺
            213233, -- 不速之客
            234965, -- 低俗举止
        },
        [1718] = { -- 巡逻队长加多
            206574, -- 共鸣挥砍
            207278, -- 奥术锁定
            215204, -- 遏止
        },
        [1719] = { -- 塔丽克萨·火冠
            207979, -- 震荡波
            397907, -- 末日迫近
            209378, -- 剑刃旋风
            207980, -- 衰变光束
            208165, -- 枯萎灵魂
        },
        [1720] = { -- 顾问麦兰杜斯
            224333, -- 包围之风
            209667, -- 剑刃奔涌
        },
    },

    [716] = { -- 艾萨拉之眼
        ["general"] = {
        },
        [1480] = { -- 督军帕杰什
            192094, -- 穿刺之矛
            192131, -- 投掷长矛
        },
        [1490] = { -- 积怨夫人
            193597, -- 静电新星
            193716, -- 女巫的诅咒
            197326, -- 爆裂闪电
        },
        [1491] = { -- 深须国王
            193152, -- 地震
            193171, -- 余震
            193018, -- 气体泡泡
            193093, -- 大地猛击
        },
        [1479] = { -- 瑟芬崔斯克
            192050, -- 毒液喷吐
            191855, -- 剧毒创伤
        },
        [1492] = { -- 艾萨拉之怒
            192706, -- 奥术炸弹
            192985, -- 愤怒嚎叫
            192675, -- 秘法旋风
            192794, -- 闪电打击
        },
    },

    [721] = { -- 英灵殿
        ["general"] = {
            199337, -- 捕熊陷阱 199340
            192563, -- 净化烈焰
            198959, -- 蚀刻
            198903, -- 爆裂风暴
            215429, -- 雷霆打击
            199050, -- 致死劈砍
            196194, -- 压碎护甲
            198944, -- 穿甲
            320679, -- 冲锋
            199818, -- 连环爆裂
            199674, -- 邪恶短匕
            199652, -- 撕裂
            -- 198936, -- 治疗符文
        },
        [1485] = { -- 海姆达尔
            193092, -- 放血扫击
            193234, -- 舞动之刃
            193260, -- 静电力场
        },
        [1486] = { -- 赫娅
            192048, -- 驱逐之光
            -203963, -- 风暴之眼
        },
        [1487] = { -- 芬雷尔
            196838, -- 血之气息
            197556, -- 掠食飞扑
            -196497, -- 掠食飞扑
        },
        [1488] = { -- 神王斯科瓦尔德
            193659, -- 邪炽冲刺
            193702, -- 地狱火焰
            -193743, -- 阿格拉玛之盾
        },
        [1489] = { -- 奥丁
            198088, -- 光耀碎片
            197964, -- 符文烙印（橙）
            197965, -- 符文烙印（黄）
            197966, -- 符文烙印（蓝）
            197967, -- 符文烙印（绿）
            197968, -- 符文烙印（紫）
            200988, -- 光明之枪
            -197996, -- 烙印
        },
    },

    [860] = { -- 重返卡拉赞
        ["general"] = {
            228252, -- 暗影撕裂
            228241, -- 诅咒之触
            230050, -- 力场之刃
            229705, -- 蛛网
            229706, -- 汲取生命
            229716, -- 厄运诅咒
            228164, -- 裂地猛击
            227977, -- 炫目灯光
            227965, -- 检票
            228277, -- 仆役的镣铐
            228576, -- 被诱惑
            228526, -- 调情
            29928, -- 献祭
            238606, -- 奥术爆发
            228389, -- 炙烤
            228610, -- 燃烧之路
            230297, -- 脆骨
            228995, -- 腐蚀剧毒
            228331, -- 爆裂充能
            29930, -- 痛苦诅咒
            29690, -- 裂颅醉意
            228559, -- 魅惑香水
            228571, -- 腐烂之咬
        },
        [1820] = { -- 歌剧院：魔法坏女巫
            227405, -- 反抗引力
        },
        [1826] = { -- 歌剧院：西部故事
            227325, -- 剧毒匕首
            227568, -- 燃烧扫堂腿
            227567, -- 被击倒
            227480, -- 烈焰狂风
            227777, -- 雷霆仪式
        },
        [1827] = { -- 歌剧院：美女与野兽
            228221, -- 扬尘漫天
            228215, -- 扬尘漫天
            228013, -- 浸透
            227985, -- 削弱护甲
            232135, -- 血腥突刺
            228200, -- 燃烧之焰
        },
        [1825] = { -- 贞节圣女
            227800, -- 神圣震击
            227848, -- 神圣之地
            227508, -- 群体忏悔
            227823, -- 神圣愤怒
        },
        [1835] = { -- 猎手阿图门
            227404, -- 无形
            227493, -- 致死打击
        },
        [1837] = { -- 莫罗斯
            227742, -- 锁喉
            227545, -- 抽取法力
            227851, -- 保管外套
        },
        [1836] = { -- 馆长
            227465, -- 能量释放
        },
        [1817] = { -- 麦迪文之影
            227644, -- 穿刺飞弹
            228249, -- 炼狱箭
            228261, -- 烈焰花环
            227592, -- 霜寒
        },
        [1818] = { -- 魔力吞噬者
            227502, -- 不稳定的法力
            227524, -- 能量虚空
            230221, -- 被吸收的法力
        },
        [1838] = { -- 监视者维兹艾德姆
            229159, -- 混沌暗影
            229241, -- 获取目标
            229083, -- 炽热冲击
            230002, -- 炽热断筋
            229248, -- 邪能光束
            229250, -- 邪能烈焰
            230431, -- 渗漏邪能
        },
    },

    [726] = { -- 魔法回廊
        ["general"] = {
        },
        [1497] = { -- 伊凡尔
            196562, -- 动荡魔法
            196804, -- 虚空链接
        },
        [1498] = { -- 科蒂拉克斯
            196074, -- 镇压协议
            195791, -- 隔离区
            203649, -- 破灭
            220481, -- 动荡宝珠
            196115, -- 净化之力
        },
        [1499] = { -- 萨卡尔将军
            220443, -- 暗影觉醒
            197776, -- 邪能裂痕
        },
        [1500] = { -- 纳尔提拉
            200227, -- 缠绕之网
            199811, -- 闪击
            200040, -- 虚空毒液
        },
        [1501] = { -- 顾问凡多斯
            203957, -- 时空枷锁
            220871, -- 不稳定的魔法
        },
    },

    [762] = { -- 黑心林地
        ["general"] = {
            200771, -- 推进冲锋
            204243, -- 折磨之眼
            204246, -- 折磨恐惧
            200684, -- 梦魇毒素
            225484, -- 痛苦撕裂
            198904, -- 剧毒之矛
            201839, -- 隔绝诅咒
            201902, -- 灼热射击
            198477, -- 锁定
            200580, -- 疯狂怒吼
            200642, -- 绝望
            -201365, -- 魔魂吸取
            -218759, -- 腐蚀之池
        },
        [1654] = { -- 大德鲁伊格兰达里斯
            196376, -- 痛苦撕扯
            198376, -- 原始狂暴
            198408, -- 夜幕
        },
        [1655] = { -- 橡树之心
            204611, -- 粉碎之握
            204574, -- 纠缠之根
            204666, -- 碎裂之土
        },
        [1656] = { -- 德萨隆
            199345, -- 下冲气流
            199460, -- 落石
            199389, -- 大地咆哮
            191326, -- 腐化之息
        },
        [1657] = { -- 萨维斯之影
            200182, -- 溃烂割裂
            200238, -- 弱肉强食
            204502, -- 天启梦魇
            200111, -- 天启之火
        },
    },

    [740] = { -- 黑鸦堡垒
        ["general"] = {
            225732, -- 击倒
            200084, -- 灵魂之刃
            225909, -- 灵魂毒液
            225963, -- 嗜血跳跃
            204896, -- 吸取生命
            203163, -- 可恶的蝙蝠！
            214002, -- 渡鸦的俯冲
        },
        [1518] = { -- 融合之魂
            194956, -- 收割灵魂
            195254, -- 漩涡之镰
            "194960", -- 灵魂回响（恐惧）
            "194966", -- 灵魂回响
        },
        [1653] = { -- 伊莉萨娜·拉文凯斯
            197418, -- 复仇之剪
            197546, -- 野蛮战刃
            197687, -- 眼棱
            197821, -- 邪炽之地
            197484, -- 黑暗冲锋
        },
        [1664] = { -- 可恨的斯麦斯帕
            198079, -- 怨恨凝视
            198245, -- 野蛮强击
            198073, -- 大地践踏
            198446, -- 邪能呕吐
            198501, -- 邪能呕吐物
            224188, -- 怨恨冲锋
        },
        [1672] = { -- 库塔洛斯·拉文凯斯
            201733, -- 针刺虫群
            198635, -- 无失之剪
            199143, -- 催眠之云
            198820, -- 黑暗冲击
            202019, -- 暗影箭雨
        },
    },
}

F.LoadBuiltInDebuffs(debuffs)