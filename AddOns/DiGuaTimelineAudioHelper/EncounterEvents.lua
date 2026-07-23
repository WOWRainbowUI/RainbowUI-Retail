-- EncounterEvents.lua
local addonName, addonTable = ...
addonTable.EventSoundData = {
    -- 熔炉之主加弗斯特
    [147] = { {"KuaiZhaoYanTi.ogg", 1} }, -- 冰川过载
    -- 阿拉卡纳斯
    [302] = { {"ZhuYiTouQian.ogg", 1, {TANK = true}} }, -- 灼热重击
    [303] = { {"XiaoGuaiJiHuo.ogg", 1} }, -- 充能
    [304] = { {"ZhunBeiAOE.ogg", 1} }, -- 超级新星
    -- 鲁克兰
    [603] = { {"XiaoGuaiFuHuo.ogg", 0} }, -- 荣耀烈焰 (1283787)
    -- 高阶贤者维里克斯
    -- [309] = { {".ogg", 1} }, -- 灼烧射线 (1253538)
    [310] = { {"ZhunBeiJiuRen.ogg", 1} }, -- 扔下 (1253998)
    -- [311] = { {".ogg", 1} }, -- 日光冲击 (154396)
    -- [312] = { {".ogg", 1} }, -- 眩光 (1253840)
    
    -- 学院
    -- 茂林古树
    [282] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 裂树击 (388544)
    [283] = { {"ZhunBeiDaGuaiErDianWuMiaoZhuanHuoDaGuai.ogg", 1, {TANK = true, DAMAGER = true}} }, -- 分枝 (388567)
    [284] = { {"ZhuYiJiaoXia.ogg", 1} }, -- 发芽 (388796)
    [285] = { {"ZhunBeiAOE.ogg", 1} }, -- 爆发苏醒 (388923)
    -- [293] = { {".ogg", 1} }, -- 奥术飞弹 (373325)
    -- [294] = { {".ogg", 1} }, -- 星界冲击 (1282251)
    [295] = { {"TieBianFangShui.ogg", 0} }, -- 能量炸弹 (374341)
    -- [296] = { {".ogg", 1} }, -- 力量真空 (388820)
    
    -- 晋升者祖拉尔
    [223] = { {"DuoKaiZhengMian.ogg", 1} }, -- 虚空之掌 (1268916)
    [224] = { {"ZhunBeiTiaoRen.ogg", 1} }, -- 残杀 (1263282)
    [225] = { {"ZhunBeiAOE.ogg", 1} }, -- 渗漏猛击 (1263399)
    [226] = { {"WuMiaoHouTanKeJianCiSanErYi.ogg", 2, {TANK = true, HEALER = true}}, {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 虚空挥砍 (1263440)
    -- [238] = { {"XiaoXinJiTui.ogg", 1} }, -- 崩解虚空 (1263304)
    
    -- 萨普瑞什
    [234] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 虚空炸弹 (247175)
    -- [235] = { {".ogg", 1} }, -- 相位冲锋 (1263509)
    [236] = { {"DaDuanDuTiao.ogg", 0, {DAMAGER = true, TANK = true}} }, -- 恐惧尖啸 (248831)
    [237] = { {"DanShuaLiuXue.ogg", 1, {HEALER = true}}, {"ZhunBeiLiuXueSanErYi.ogg", 2, {DAMAGER = true, HEALER = true}} }, -- 暗影突袭 (245738)
    -- [243] = { {".ogg", 1} }, -- 过载 (1263523)
    
    -- 总督奈扎尔
    [244] = { {"DaDuanDuTiao.ogg", 1, {DAMAGER = true, TANK = true}} }, -- 心灵震爆 (244750)
    [246] = { {"ZhunBeiXiaoGuai.ogg", 1} }, -- 暗影触须 (1263538)
    
    -- 鲁拉    
    [249] = { {"ZhunBeiAOE.ogg", 1} }, -- 绝望哀歌    
    [250] = { {"ZhunBeiDianMingLiangMiaoSanErYi.ogg", 2} }, -- 不谐射线
    [251] = { {"ZhuYiSheXian.ogg", 1} }, -- 裂解
    [252] = { {"DuoKaiDaQuan.ogg", 1} }, -- 幽冥和音
    [253] = { {"ZhunBeiYiShangShiMiaoYiShangJieDuan.ogg", 1} }, -- 永夜交响曲
    [254] = { {"ZhunBeiJiTuiLiangMiaoSanErYi.ogg", 2} }, -- 反冲    
    -- [247] = { {".ogg", 1} }, -- 驱逐 (1263528)
    -- [376] = { {"ZhunBeiDuoQiuSiMiaoZhuYiDuoQiu.ogg", 1} }, -- 深渊之门 (1277358)
    [245] = { {"ZhuYiDanShua.ogg", 1, {HEALER = true}} }, -- 群体虚空灌输 (1263542)
    
    -- 烬晓
    [239] = { {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}} }, -- 炽热尖喙
    [241] = { {"ZhunBeiDianMing.ogg", 1}, {"TieBianFangShuiSanMiaoSanErYi.ogg", 0} }, -- 炽焰腾流 (包含原表2)
    [242] = { {"WuMiaoZhunBeiChuiFengSanMiaoNiShiZhenTouQian.ogg", 2} }, -- 燃烧烈风          
    
    -- 被遗弃的二人组
    [25]  = { {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}} }, -- 碎骨猛砍  
    [26]  = { {"GuiHunDianNiSanErYi.ogg", 0}, {"ZhunBeiZuZhouLiangMiao.ogg", 2} }, -- 黑暗诅咒 (包含原表2)
    [27]  = { {"ZhunBeiDianMing.ogg", 2} }, -- 衰弱尖啸         
    
    -- 指挥官克罗鲁科
    [210] = { {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}} }, -- 暴怒
    [211] = { {"ZiQuanChongHeLiangMiaoSanErYi.ogg", 1} }, -- 破胆怒吼
    [212] = { {"SanMiaoZhuYiDuoQuan.ogg", 1} }, -- 无情跳跃
    -- [213] = { {"ZiQuanChongHeLiangMiaoSanErYi.ogg", 1} }, -- 破胆怒吼
    [214] = { {"SanMiaoZhuYiDuoQuan.ogg", 1} }, -- 无情跳跃
    [215] = { {"ZhunBeiAOE.ogg", 0} }, -- 集结怒吼
    
    -- 无眠之心
    [21]  = { {"ZhunBeiAOELiangMiaoSanErYi.ogg", 2} }, -- 疾风狙击
    [22]  = { {"ZhunBeiJianYu.ogg", 2} }, -- 飞矢烈风
    [23]  = { {"ZhuYiDuoQuanWuMiaoCaiQuanXiaoCeng.ogg", 1} }, -- 矢如雨下
    [24]  = { {"TanKeJiTui.ogg", 1, {TANK = true, HEALER = true}} }, -- 暴风斩    
    
    -- 核技工程长卡斯雷瑟   
    [108] = { {"ZhuYiSheXian.ogg", 1} }, -- 魔网阵列 (1251183)
    -- [106] = { {".ogg", 1} }, -- 核闪引爆 (1257512)
    -- [107] = { {"JiaoChaDianXiaoLianXian.ogg", 0} }, -- 回流充能 (1251767)
    [172] = { {"ZhuYiJiaoXia.ogg", 1} }, -- 能量坍缩 (1264048)
    
    -- 核心守卫奈萨拉 
    [36]  = { {"ZhunBeiXiaoGuaiLiuMiaoXiaoGuaiJiHuo.ogg", 1} }, -- 空无先锋
    [35]  = { {"WuMiaoHouTanKeJianCi.ogg", 2, {TANK = true, HEALER = true}}, {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 幽影鞭笞   
    [34]  = { {"ZhunBeiYiShangJiuMiaoKuaiJinShengGuang.ogg", 0} }, -- 光痕耀斑
    -- [33]  = { {"ZhunBeiDianMing.ogg", 2} }, -- 蚀光步伐    
    
    -- 洛萨克森
    [109] = { {"BaMaFenSanSiMiaoZhuYiDuoQuan.ogg", 1} }, -- 辉熠消散
    [110] = { {"ZhunBeiJiTuiSiDianWuMiaoSanErYiDaDuanGuangTou.ogg", 1} }, -- 神圣诡计
    [111] = { {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}} }, -- 灼热撕裂
    [112] = { {"DuoKaiChongFeng.ogg", 1} }, -- 闪烁   

    -- 姆罗金和内克拉克斯
    [150] = { {"TanKeLiuXue.ogg", 1, {TANK = true, HEALER = true}} }, -- 长矛侧攻
    [151] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 恶臭羽毛风暴
    [152] = { {"DuoKaiXianJing.ogg", 1} }, -- 冰冻陷阱
    [153] = { {"ZhunBeiJianYu.ogg", 2} }, -- 弹幕射击    
    [154] = { {"ZhunBeiJiBing.ogg", 1}, {"WuMiaoHouAOE.ogg", 2} }, -- 感染羽翼 (包含原表2)
    [155] = { {"ZhunBeiDianMing.ogg", 2} }, -- 腐肉飞扑
    
    -- 沃达扎    
    [16]  = { {"TanKeChengShang.ogg", 1, {TANK = true, HEALER = true}} }, -- 吸取灵魂
    [17]  = { {"DuoKaiTouQian.ogg", 1} }, -- 寂灭
    [19]  = { {"ZhunBeiDianMing.ogg", 1} }, -- 束缚幻影
    [20]  = { {"WuMiaoZhunBeiPoDunSanMiaoKuaiKaiJianShangShiErMiaoZhuYiDuoQiu.ogg", 2} }, -- 死疽融合

    -- 魔导师平台
    -- 奥能金刚库斯托斯
    -- [281] = { {".ogg", 1} }, -- 补给协议 (474345)
    -- [286] = { {".ogg", 1} }, -- 震退猛击 (474496)
    -- [287] = { {".ogg", 1} }, -- 虚灵枷锁 (1214032)
    [288] = { {"XiaoXinJiTui.ogg", 1} }, -- 奥术驱除 (1214081)    
    -- 瑟拉奈尔·日鞭
    [94]  = { {"ShouLingQiangHua.ogg", 1} }, -- 加速结界
    [96]  = { {"ZhunBeiJinZhaoZiSanErYiJin.ogg", 1} }, -- 静默浪潮        
    -- 吉美尔鲁斯
    [635] = { {"SanChongFuZhi.ogg", 0} }, -- 三重复制
    [97]  = { {"ZhunBeiDianMing.ogg", 1} }, -- 神经链接
    [98]  = { {"ZhunBeiLaRen.ogg", 0} }, -- 星界束缚
    [100] = { {"DianMingFangShui.ogg", 1} }, -- 寰宇刺击
    -- 迪詹崔乌斯
    [420] = { {"TanKeChengShangSanMiaoQuSanTanKe.ogg", 1, {TANK = true, HEALER = true}} }, -- 庞大碎片  
    [292] = { {"ZhunBeiJieQuan.ogg", 1} }, -- 不稳定的虚空精华
    [290] = { {"ShiErMiaoDuoQiuShiWuMiaoDuoQiuShiBaMiaoDuoQiu.ogg", 1} }, -- 贪噬之熵   

    -- 元首阿福扎恩
    [194] = { {"ZhaoHuanDaGuai.ogg", 1} }, -- [暗影进军] (1262776)
    [195] = { {"ZhaoHuanDaGuai.ogg", 1} }, -- [暗影进军] (1251361)
    [198] = { {"DuoBiBiaoQiang.ogg", 1} }, -- [湮灭之怒] (1260712)
    [197] = { {"FenTanShangHaiQiMiaoFenTanShangHaiZhuanHuoDaGuai.ogg", 1} }, -- [幽影坍缩] (1249265)
    [200] = { {"ShouLingKuangBao.ogg", 0} }, -- [无尽行军] (1251583)
    -- [201] = { {".ogg", 1} }, -- [浓暗壁垒] (1255702)    
    -- [492] = { {".ogg", 1} }, -- [虚弱] (1283069)
    [419] = { {"ZhunBeiDianMing.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- [虚空标记] (1280015)
    [196] = { {"ZhunBeiAOE.ogg", 1, {HEALER = true}} }, -- [黑暗颠覆] (1249251)
    [199] = { {"ZhunBeiJiTuiShiYiMiaoZhuYiDuoQuan.ogg", 2} }, -- [虚空坠落] (1258880) (来自原表2)
    [209] = { {"ZhunBeiJiTuiShiYiMiaoZhuYiDuoQuan.ogg", 2} }, -- [虚空坠落] (1266786) (来自原表2)

    -- 弗拉希乌斯
    [133] = { {"ZhunBeiJiTuiLiangMiaoSanErYi.ogg", 1} }, -- [始源咆哮] (1260046)
    [59]  = { {"TanKeChengShangSanErYiShiMiaoTanKeChengShangSanErYi.ogg", 1} }, -- [影爪重击] (1241836)
    [60]  = { {"TanKeChengShangSanErYiShiMiaoTanKeChengShangSanErYi.ogg", 1} }, -- [影爪重击] (1244293)
    [62]  = { {"ZhuYiJiaoXia.ogg", 1}, {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}} }, -- [散逸寄生虫] (包含原表2)
    [61]  = { {"ZhunBeiJiGuang.ogg", 0} }, -- [虚空吐息] (1243853)

    -- 陨落之王萨哈达尔
    -- [140] = { {"ZhunBeiDianMing.ogg", 1} }, -- 专制命令 (1260823)
    [143] = { {"HuanJingShangHai.ogg", 1, {HEALER = true}} }, -- 扭曲遮蔽 (1250686)
    [148] = { {"YiShangJieDuan.ogg", 1}, {"ZhunBeiYiShang.ogg", 2} }, -- 熵能瓦解 (包含原表2)
    [141] = { {"KongDuanDaGuai.ogg", 1, {DAMAGER = true, TANK = true}} }, -- 破碎投影 (1254081)
    [142] = { {"ZhunBeiDiCi.ogg", 1} }, -- 粉碎暮光 (1253911)
    [139] = { {"ZhaoHuanXiaoGuai.ogg", 1, {DAMAGER = true, TANK = true}} }, -- 虚空融合 (1243453)

    -- 威厄高尔和艾佐拉克
    [103] = { {"CengQiu.ogg", 1}, {"ZhunBeiCengQiuSanErYi.ogg", 2} }, -- 阴霾 (包含原表2)
    [104] = { {"KongJuTuXi.ogg", 1}, {"ZhunBeiKongJuLiangMiaoSanErYi.ogg", 2} }, -- 亡者吐息 (包含原表2)
    [105] = { {"ZhuanHuoDaGuai.ogg", 1} }, -- 午夜烈焰 (1249748)
    -- [221] = { {"TanKeChengShang.ogg", 1, TANK = true} }, -- 威厄之翼 (1265131)
    -- [220] = { {"TanKeChengShang.ogg", 1, TANK = true} }, -- 拉克獠牙 (1245645)
    -- [551] = { {".ogg", 1} }, -- 穿刺 (435193)
    -- [101] = { {"TanKeTuXi.ogg", 1} }, -- 虚无光束 (1262623)
    [102] = { {"WuMaFenSan.ogg", 1}, {"ZhunBeiXiaoGuai.ogg", 2} }, -- 虚空嚎叫 (包含原表2)
    [381] = { {"KaoJinZhongChang.ogg", 1} }, -- 辐光屏障 (1248847)

    -- 光盲先锋军
    [74]  = { {"ZhunBeiPoDun.ogg", 1, {DAMAGER = true}} }, -- 圣洁护盾 (1248674)
    [80]  = { {"ZhunBeiDuoFeiDun.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 圣洁鸣钟 (1248644)
    [85]  = { {"FenTanShangHai.ogg", 1} }, -- 处决宣判 (1276368)
    [79]  = { {"BaMaFenSan.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 复仇者之盾 (1246485)
    [365] = { {"BaMaFenSan.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 复仇者之盾 (1276635)
    [78]  = { {"ZhuYiHuanTan.ogg", 1, {TANK = true}}, {"ZhunBeiShenPanSanErYi.ogg", 2, {TANK = true}} }, -- 审判 (包含原表2)
    [82]  = { {"ZhuYiHuanTan.ogg", 1, {TANK = true}}, {"ZhunBeiShenPanSanErYi.ogg", 2, {TANK = true}} }, -- 审判 (包含原表2)
    -- [75]  = { {"ZhunBeiShuaDun.ogg", 1, {HEALER = true}} }, -- 提尔之怒 (1276831)
    [77]  = { {"ZhunBeiAOE.ogg", 1, {HEALER = true}} }, -- 灼热光辉 (1255738)
    [373] = { {"ZhunBeiAOE.ogg", 1, {HEALER = true}} }, -- 灼热光辉 (1276639)
    -- [535] = { {".ogg", 1} }, -- 盲目之光 (428169)
    -- [83] = { {".ogg", 1} }, -- 神圣风暴 (1246765)
    -- [374] = { {".ogg", 1} }, -- 神圣风暴 (1272310)
    [84]  = { {"AOE.ogg", 1, {HEALER = true}}, {"ZhunBeiAOELiangMiaoSanErYi", 2, {HEALER = true}} }, -- 神圣鸣罪 (包含原表2)
    -- [76]  = { {"DuoKaiDaQuan.ogg", 1} }, -- 虔诚光环 (1246162)    
    -- [71]  = { {"DuoKaiDaQuan.ogg", 1} }, -- 平心光环 (1248451)
    -- [81]  = { {"DuoKaiDaQuan.ogg", 1} }, -- 愤怒光环 (1248449)
    [73]  = { {"DuoKaiChongFeng.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 雷象冲锋 (1249130)

    -- 奇美鲁斯，未梦之神
    [118] = { {"ZhunBeiAOE.ogg", 1, {HEALER = true}} }, -- 不谐咆哮 (1249207)
    [117] = { {"DaDuanDuTiao.ogg", 1, {DAMAGER = true, TANK = true}} }, -- 可怖战吼 (1249017)
    [307] = { {"ZhunBeiAOE.ogg", 1} }, -- 吞噬 (1245396)
    [119] = { {"ZhunBeiQuSan.ogg", 1, {HEALER = true}}, {"ZhunBeiDianMing.ogg", 2} }, -- 吞噬瘴气 (包含原表2)
    [51]  = { {"DuoKaiTouQian.ogg", 1} }, -- 猛撕开裂 (1272726)
    [53]  = { {"ZhunBeiTuXi.ogg", 1} }, -- 腐化毁灭 (1245452)
    [458] = { {"ZhunBeiTuXi.ogg", 1} }, -- 腐化毁灭 (1282856)
    [50]  = { {"ZhunBeiAOE.ogg", 1, {HEALER = true}} }, -- 腐蚀黏痰 (1246621)
    [149] = { {"FenTanShangHai.ogg", 1} }, -- 艾林之尘剧变 (1262289)
    [431] = { {"FenTanShangHai.ogg", 1} }, -- 艾林之尘剧变 (1282001)
    [555] = { {"ShouLingQiangHua.ogg", 1} }, -- 被吞噬的精华 (1245844)
    [49]  = { {"ZhunBeiNeiChang.ogg", 1}, {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}} }, -- 裂隙涌现 (包含原表2)
    [217] = { {"ZhunBeiJiuRen.ogg", 1} }, -- 裂隙疯狂 (1268905)
    [48]  = { {"ZhunBeiJiFei.ogg", 0} }, -- 贪食俯冲 (1245404)

    -- 宇宙之冕
    [15]  = { {"ChangDiQieHuan.ogg", 1} }, -- 噬灭宇宙 (1238843)
    [8]   = { {"ZhuYiDuoQuan.ogg", 1} }, -- 奇点喷发 (1235622)
    [12]  = { {"ZhunBeiDaDun.ogg", 0, {DAMAGER = true, HEALER = true}} }, -- 宇宙屏障 (1246918)
    [66]  = { {"ZhunBeiChenMo.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 干扰震荡 (1243743)
    [65]  = { {"JinZhanDaQuan.ogg", 1, {DAMAGER = true}} }, -- 暴食深渊 (1243753)
    [11]  = { {"ZhunBeiYinFengJian.ogg", 1} }, -- 游侠队长印记 (1237614)
    [131] = { {"ZhunBeiYinFengJian.ogg", 1} }, -- 游侠队长印记 (1260010)
    -- [4]   = { {"ZhuYiDanShua.ogg", 1, {HEALER = true}} }, -- 空无之冕 (1233865)
    [14]  = { {"DuoBiBiaoQiang.ogg", 1} }, -- 空虚之握 (1232467)
    [132] = { {"DuoBiBiaoQiang.ogg", 1} }, -- 空虚之握 (1260026)
    [13]  = { {"ZhunBeiLaXian.ogg", 1}, {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}} }, -- 终末守护 (包含原表2)
    [10]  = { {"ZhunBeiXiaoGuai.ogg", 1, {DAMAGER = true}} }, -- 虚空召唤 (1237837)
    [5]   = { {"HeiQiuChuXianDanQiuZhunBeiSanErYiShuangQiuZhunBeiSanErYi.ogg", 1, {HEALER = true}}, {"ZhunBeiHeiQiu.ogg", 2} }, -- 虚空斥力 (包含原表2)
    [6]   = { {"ZhunBeiYinFengJian.ogg", 2} }, -- 银锋箭 (来自原表2)
    -- [9]   = { {".ogg", 1, HEALER = true} }, -- 虚空追猎者钉刺 (1237035)
    [137] = { {"TanKeChengShang.ogg", 1, {TANK = true}} }, -- 裂隙挥砍 (1246461)
    [7]   = { {"SheXian.ogg", 1} }, -- 银锋弹幕射击 (1234564)    
    [64]  = { {"TanKeJiTui.ogg", 1, {TANK = true}} }, -- 黑暗之手 (1233787)

    -- 贝洛朗，奥的子嗣
    [130] = { {"ZhunBeiBaoZhu.ogg", 1} }, -- light (1242981)
    [494] = { {"FenTanShangHai.ogg", 0} }, -- 圣光俯冲 (1241292)
    [482] = { {"NiShiHuangSe.ogg", 0} }, -- 圣光羽毛 (1241162)
    [384] = { {"MuBiaoShiNi.ogg", 0} }, -- 圣光飞羽 (1241992)
    [497] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 复生 (1241313)
    [134] = { {"TanKeLianJi.ogg", 1, {TANK = true}} }, -- 守护者敕令 (1260763)
    [272] = { {"ZhunBeiJiFei.ogg", 2} }, -- 死亡坠落 (1246709)
    [138] = { {"ShuaXiNaiDun.ogg", 1, {HEALER = true}}, {"WuMiaoHouXiNaiDun.ogg", 2, {HEALER = true}} }, -- 永恒灼烧 (1244344)
    -- [161] = { {"ZhuYiSheXian.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 注能飞羽 (1242260)
    -- [273] = { {".ogg", 1} }, -- 烈焰孵化 (1242792)
    [218] = { {"KaiShiHuanSe.ogg", 1}, {"ZhunBeiHuanSeSanErYiKaiShiHuanSe.ogg", 2} }, -- 虚光汇流 (包含原表2)
    [495] = { {"FenTanShangHai.ogg", 0} }, -- 虚空俯冲 (1241339)
    [483] = { {"NiShiLanSe.ogg", 0} }, -- 虚空羽毛 (1241163)
    [385] = { {"MuBiaoShiNi.ogg", 0} }, -- 虚空飞羽 (1242091)
    [128] = { {"FenTanShangHai.ogg", 1} }, -- 贝洛朗的燃烬 (1241282)

    -- 至暗之夜降临    
    [632] = { {"MiaoZhunHeiQiu.ogg", 0}, {"ZhunBeiSheQiu.ogg", 2} }, -- 充电 (包含原表2)
    [259] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 全蚀 (1261871)
    [261] = { {"XiHeiQiu.ogg", 1} }, -- 圣光虹吸 (1266897)
    [364] = { {"TanKeChengShang.ogg", 1, {TANK = true}} }, -- 天穹之枪 (1267049)
    [256] = { {"DuoKaiZhanRen.ogg", 1} }, -- 天穹战刃 (1253915)
    [257] = { {"ZhunBeiHuWeiDaDuanHuWeiZhuanHuoShuiJing.ogg", 1} }, -- 护卫棱镜 (1251386)
    -- [434] = { {".ogg", 1} }, -- 宇宙裂变 (1282249)
    -- [363] = { {".ogg", 1} }, -- 断离 (1276202)
    -- [437] = { {"SheXianDianNi.ogg", 0} }, -- 星辰裂片 (1282441)
    [435] = { {"DuoKaiLianXian.ogg", 1}, {"ZhiLiaoYuPu.ogg", 2, {HEALER = true}} }, -- 核心收割 (包含原表2)
    -- [362] = { {".ogg", 1} }, -- 死亡安魂曲 (1273158)    
    [255] = { {"FuWenDianNi.ogg", 0}, {"ZhunBeiFuWenLiangMiaoSanErYi.ogg", 2} }, -- 死亡挽歌 (包含原表2)
    [433] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 深入黑暗之井 (1282047)
    -- [258] = { {".ogg", 1} }, -- 破碎天空 (1249796)
    -- [636] = { {".ogg", 1} }, -- 终结棱柱 (1284931)
    -- [260] = { {".ogg", 1} }, -- 至暗之夜 (1266622)
    -- [405] = { {".ogg", 1} }, -- 蚀盛 (1237690)
    [263] = { {"KuaiJinZhaoZiQiMiaoKuaiPao.ogg", 1} }, -- 黑暗天使长 (1250898)
    -- [262] = { {"DuoKaiXingZuo.ogg", 1} }, -- 黑暗星座 (1266388)
    [436] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 黑暗熔毁 (1281194)
    -- [650] = { {"FuWenDianNi.ogg", 0} }, -- 黑暗符文 (1249609)
    [649] = { {"ZhuYiSheXian.ogg", 1} }, -- 黑暗类星体 (1279420)
    -- [644] = { {".ogg", 1} }, -- 黯灭协奏 (1284980)

    -- 腐沼
    [424] = { {"ZhunBeiJiTuiLiangMiaoSanErYi.ogg", 1} }, -- 真菌绽放 (1221637)
    [425] = { {"ZhuYiJiaoXia.ogg", 1} }, -- 唤醒真菌 (1221622)
    [426] = { {"ZhunBeiAOE.ogg", 1}, {"WuMiaoHouAOE.ogg", 2, {HEALER = true}} }, -- 脓包爆裂 (1221787)
    [427] = { {"WuMiaoHouTanKeJianCi.ogg", 2, {TANK = true}}, {"TanKeJianCi.ogg", 1, {TANK = true}} }, -- 腐烂之拳 (1221781)
    [428] = { {"ZhunBeiDianMing.ogg", 1, {DAMAGER = true, HEALER = true}} }, -- 溃烂藤蔓 (1222088)
    [808] = { {"HongSeLianXian.ogg", 0} },
    [809] = { {"LvSeLianXian.ogg", 0} },

    -- 光明众花
    [177] = { {"ZhunBeiCaiQuan.ogg", 1} }, -- 光明之花射线 (1235564)
    [173] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 基岩猛击 (1234753)
    [174] = { {"DuoKaiChongFeng.ogg", 1} }, -- 播光急奔 (1234850)
    -- [175] = { {"ZhunBeiLiuXue.ogg", 0} }, -- 荆棘之刃 (1235640)
    -- [176] = { {"ZhunBeiLiuXue.ogg", 0} }, -- 荆棘之刃 (1261276)

    -- 圣光猎手伊库兹
    [179] = { {"ZhunBeiAOE.ogg", 1} }, -- 唤棘者咆哮 (1236709)
    [180] = { {"MuBiaoShiNi.ogg", 0} }, -- 嗜血注视 (1237090)
    [178] = { {"XiaoXinJiTui.ogg", 1} }, -- 青翠践踏 (1236746)

    -- 护光者鲁伊亚
    [181] = { {"ZhuYiDianMing.ogg", 1}, {"JiHeFangFeng.ogg", 0}}, -- 光明之火 (1239824)
    [182] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 光明坠落 (1240098)
    [184] = { {"ZhunBeiLiuXue.ogg", 1}, {"WuMiaoHouAOE.ogg", 2, {HEALER = true}} }, -- 凶残痛击 (1241058)
    [188] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 峡谷之灵 (1241067)
    [115] = { {"TanKeChengShang.ogg", 1} }, -- 撕裂之爪 (1258136)
    [183] = { {"ZhuYiDianMing.ogg", 1} }, -- 粉碎打击 (1240210)

    -- 兹欧凯特
    [192] = { {"ZhunBeiChiQiu.ogg", 1} }, -- 光绽精华 (1246858)
    [191] = { {"MiaoZhunXiaoGuai.ogg", 0} }, -- 凝聚光线 (1246607)
    [189] = { {"ZhunBeiXiaoGuai.ogg", 1} }, -- 唤醒光绽 (1246372)
    [190] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 棘刺 (1247685)

    -- 凯斯媞亚·魔力之心
    [610] = { {"YiShangJieDuan.ogg", 0} }, -- 光明灌注 (1230304)
    [202] = { {"DuoKaiDaQuan.ogg", 1} }, -- 邪能新星 (474240)
    [122] = { {"DuoKaiTouQian.ogg", 1} }, -- 邪能飞溅 (1253811)
    [120] = { {"DaDuanXiaoGuai.ogg", 1} }, -- 镜像 (1264095)

    -- 赞恩·刃悲
    [124] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 当日送达 (474765)
    [127] = { {"ZhunBeiAOE.ogg", 1}, {"WuMiaoHouAOE.ogg", 2, {HEALER = true}} }, -- 影舞步 (474478)
    [193] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 毒伤 (1222795)
    [123] = { {"QuanZhuLvTong.ogg", 0} }, -- 火焰炸弹 (1214357)
    [125] = { {"KuaiZhaoYanTi.ogg", 1} }, -- 绝命凶径 (1218347)

    -- 歼灭者萨祖克斯
    [30] = { {"TanKeTouQian.ogg", 1} }, -- 军团打击 (473898)
    [31] = { {"ZhunBeiXiaoGuai.ogg", 1} }, -- 利斧投掷 (1214637)
    [32] = { {"ZhunBeiYiShangShiMiaoYiShangJieDuan.ogg", 1} }, -- 魔化狂怒 (474197)
    [752] = { {"BaMaFenSan.ogg", 1} }, -- 地狱火碾压 (1295452)

    -- 利希尔·烬怒
    [37] = { {"JiHeFenSan.ogg", 1} }, -- 古尔丹之指 (1218203)
    [38] = { {"ZhuanHuoXiaoGuai.ogg", 1} }, -- 召唤邪犬 (474408)
    [207] = { {"ZhunBeiDianMen.ogg", 1} }, -- 灾厄浪潮 (1224478)

    -- 囤宝狂人
    [86] = { {"ZhuYiCaiQuan.ogg", 1} }, -- 腐坏补给 (1234233)
    [87] = { {"DuoKaiTouQian.ogg", 1} }, -- 裂地强击 (1253268)
    [88] = { {"ZhunBeiAOE.ogg", 1} }, -- 贪婪咆哮 (1235118)

    -- 寒冬哨兵
    [67] = { {"QuSanMoFa.ogg", 1, {HEALER = true}} }, -- 冰川折磨 (1235548)
    [70] = { {"KaoJinZhongChang.ogg", 1} }, -- 寒冰暴雨 (1235656)
    [68] = { {"ZhuYiDuoFeng.ogg", 1} }, -- 狂怒的飑风 (1235623)
    [69] = { {"ZhunBeiXiaoGuai.ogg", 1} }, -- 粉碎冰刺 (1235783)

    -- 纳洛拉克
    [92] = { {"KuaiZhaoYanTi.ogg", 1} }, -- 压制强攻 (1243569)
    [90] = { {"BaMaFenSan.ogg", 1} }, -- 回响重击 (1242860)
    -- [89] = { {"ZhunBeiJiTui.ogg", 1} }, -- 强力咆哮 (1255385)
    [91] = { {"ZuDangLingHun.ogg", 1} }, -- 战神之怒 (1243011)

    -- 塔兹拉尔
    [39] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 虚空冲击 (1222085)
    [558] = { {"JiHeFenSan.ogg", 0} }, -- 空灵冲刺 (1222098)
    [41] = { {"ZhunBeiDuoQiu.ogg", 1} }, -- 黑暗裂缝 (1222274)

    -- 阿特洛苏斯
    [297] = { {"ZhunBeiAOE.ogg", 1} }, -- 巨响咆哮 (1262497)
    [47] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 巨型爪击 (1222642)
    [54] = { {"DuoKaiTouQian.ogg", 1} }, -- 毒性吐息 (1222721)
    [55] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 毒液喷溅 (1226120)
    [46] = { {"ZhunBeiXiaoGuai.ogg", 1} }, -- 激怒蠕行者 (1222371)

    -- 煞戎努斯
    [56] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 不稳定的奇点 (1282770)
    [57] = { {"WuMaFenSan.ogg", 1} }, -- 星辰坠击 (1227264)
    [58] = { {"ZhuYiBaoZhu.ogg", 1} }, -- 引力宝珠 (1263982)
    [171] = { {"TanKeDangQiu.ogg", 1} }, -- 虚空奔涌 (1222758)
    [961] = { {"TanKeTouQian.ogg", 1} }, -- Dark Waves (1311923)

    -- 拉维
    [795] = { {"ZhunBeiPoDun.ogg", 2}, {"HuDunKuaiDa.ogg", 1} }, -- 嘶嘶食腐 (1309522)
    [796] = { {"ZhunBeiAOE.ogg", 1} }, -- 恶臭咆哮 (1296219)
    [797] = { {"ZhunBeiDianMing.ogg", 1}, {"WuMaFenSan.ogg", 0} }, -- 三重喷吐 (1296220)
    [798] = { {"DuoKaiTouQian.ogg", 1} }, -- 反刍 (1296050)
    [899] = { {"ZhunBeiAOE.ogg", 1} }, -- 贪婪践踏 (1307894)
    -- [902] = { {".ogg", 1} }, -- 进食狂热 (1307765)
    [901] = { {"TanKeDaiWei.ogg", 0} }, -- 鲜肉 (1307921)

    -- 扭缠盘蛇
    [813] = { {"ZhunBeiAOE.ogg", 1} }, -- 同步毒液 (1299154)
    [814] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 镰尾 (1298949)
    [815] = { {"DuoKaiChongFeng.ogg", 1} }, -- 复仇猛攻 (1299940)
    [816] = { {"ZhunBeiLaXian.ogg", 1} }, -- 濒死喘息 (1299053)
    -- [817] = { {"XiaoGuaiDingNi.ogg", 0} }, -- 怨毒狩猎 (1300503)
    [818] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 同化 (1300686)
    [938] = { {"DaDuanBoss.ogg", 1} }, -- 准备毒素 (1310357)
    [939] = { {"DaDuanXiaoGuai.ogg", 1} }, -- 剧毒萎缩 (1310547)

    -- 祖尔加
    [821] = { {"ZhuYiSheXian.ogg", 1} }, -- 切骨者 (1301413)
    [822] = { {"ZhuYiDangXian.ogg", 1} }, -- 毒牙仪式 (1300876)
    [823] = { {"ZhuYiTouQian.ogg", 1} }, -- 碎斧 (1301111)
    [824] = { {"WuMiaoHouTanKeJianCiSanErYi.ogg", 2, {TANK = true, HEALER = true}}, {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 砍倒 (1301350)
    
    -- 梅莉杜莎·寒妆
    [866] = { {"ZhunBeiAOELiangMiaoZhuYiJiaoXia.ogg", 1} }, -- 冰雹爆裂 (1307297)
    [867] = { {"ZhuYiDianMing.ogg", 1} }, -- 霜风 (1307308)
    [868] = { {"HuDunKuaiDa.ogg", 1} }, -- 冰霜过载 (373686)
    [869] = { {"ZhaoHuanXiaoGuai.ogg", 0} }, -- 唤醒雏龙 (373046)

    -- 柯姬雅·焰蹄
    [882] = { {"ZhunBeiDaGuai.ogg", 1} }, -- 缚焰仪式 (372864)
    [883] = { {"DuoKaiTouQian.ogg", 1} }, -- 熔火巨石 (372110)
    [884] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 灼热打击 (372858)

    -- 基拉卡与厄克哈特·风脉
    [885] = { {"ZhunBeiChenMo.ogg", 1} }, -- 阻断暴雨 (381516)
    [887] = { {"ZhunBeiChuiFeng.ogg", 1} }, -- 变迁之风 (381517)
    [888] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 风暴猛击 (381512)
    [889] = { {"ZhunBeiDianMing.ogg", 1}, {"TieBianFangShuiSanMiaoSanErYi.ogg", 0}}, -- 烈焰喷吐 (381602)
    [890] = { {"DuoKaiTouQian.ogg", 1} }, -- 怒吼火息 (381525)
    [894] = { {"ZhunBeiDianMing.ogg", 1}, {"TieBianFangShuiSanMiaoSanErYi.ogg", 0}}, -- 烈焰喷吐 (381605)

    -- 阿德里斯和阿斯匹克斯
    [689] = { {"FenTanShangHaiSanErYiDuoKaiDaQuan.ogg", 1} }, -- 电闪雷鸣 (1288049)
    [690] = { {"ShouLingQiangHua.ogg", 1, {TANK = true, HEALER = true}} }, -- 过载 (1311804)
    [691] = { {"ZhunBeiDianMing.ogg", 1} }, -- 暴风 (1311805)
    [713] = { {"TieBianFangShuiYiMiaoSanErYi.ogg", 0} }, -- 暴风 (1289754)
    [692] = { {"XiaoXinJiTui.ogg", 1}, {"LingDianWuMiaoSanErYi.ogg", 0} }, -- 狂风之力 (1289059)

    -- 米利克萨
    [701] = { {"JieDuanZhuanHuan.ogg", 1}, {"ZhuYiDuoQuan.ogg", 0} }, -- 钻地 (264172)
    [702] = { {"ZhunBeiXiaoGuai.ogg", 1} }, -- 缠绕蛇群 (1290029)
    [703] = { {"ZhunBeiDianMing.ogg", 1} }, -- 雷霆喷吐 (1289109)
    [704] = { {"ZhunBeiDaGuai.ogg", 1} }, -- 孵化 (1289205)
    [705] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 闪电撕咬 (1290797)
    [706] = { {"XiaoXinJiTuiSanMiaoZhuYiDuoQuan.ogg", 1} }, -- 毒蛇风暴 (1293048)

    -- 加瓦兹特
    [697] = { {"ZhunBeiAOE.ogg", 1}, {"WuMiaoHouAOE.ogg", 2} }, -- 诱导 (1309525)
    [698] = { {"ZhuYiDangXian.ogg", 1} }, -- 闪电尖塔 (1291618)

    -- 塞塔里斯的化身
    [827] = { {"ZhiLiaoBoss.ogg", 1} }, -- 净化 (1301963)
    [828] = { {"JieDuanZhuanHuan.ogg", 1} }, -- 污染之秽 (1301202)

    -- 黄金风蛇
    [767] = { {"TieBianFangShui.ogg", 0} }, -- 吐金 (265773)
    [891] = { {"WuMiaoHouTanKeJianCiSanErYi.ogg", 2, {TANK = true, HEALER = true}}, {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 甩尾 (265910)
    [892] = { {"ZhunBeiAOE.ogg", 1} }, -- 蛇之风 (1311987)
    [893] = { {"ZhaoHuanXiaoGuai.ogg", 1} }, -- 卢彻的召唤 (265923)

    -- 殓尸者姆沁巴
    [878] = { {"ZhuYiDianMing.ogg", 1} }, -- 燃烧腐蚀 (1311956)
    [879] = { {"ZhunBeiJiuRen.ogg", 1} }, -- 埋葬 (267702)
    [880] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 排干体液 (267618)
    [973] = { {"ZhunBeiAOE.ogg", 1} }, -- Awakening Slam (1312146)
    
    -- 部族议会
    [870] = { {"ZhuYiDuoQuan.ogg", 1} }, -- 旋转利斧 (266206)
    [871] = { {"ZhunBeiLiuXue.ogg", 1} }, -- 斩首之斧 (266231)
    [872] = { {"FenTanShangHai.ogg", 1} }, -- 翻滚 (267494)
    [873] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 衰弱抽击 (266237)
    -- [874] = { {"AOE.ogg", 1}, {"WuMiaoHouAOE.ogg", 2} }, -- 电弧 (1305810)
    [875] = { {"DaDuanBoss.ogg", 1} }, -- 毒性新星 (267273)
    [876] = { {"ZhuanHuoTuTeng.ogg", 1} }, -- 元素的召唤 (267060)

    -- 始皇达萨
    [831] = { {"MuBiaoShiNi.ogg", 0} }, -- 凌空猛击 (1303115)
    [832] = { {"TanKeJianCi.ogg", 1, {TANK = true, HEALER = true}} }, -- 剑刃连击 (268586)
    [833] = { {"ZhunBeiAOE.ogg", 1} }, -- 镀金毁灭 (1303267)
    [834] = { {"DuoKaiTouQian.ogg", 1} }, -- 狩猎跃击 (269230)
    [835] = { {"DaDuanDaGuai.ogg", 1} }, -- 致命咆哮 (269369)
    [836] = { {"BaMaFenSan.ogg", 0} }, -- 震地之跃 (1303326)
    [837] = { {"TanKeLiuXue.ogg", 1, {TANK = true, HEALER = true}} }, -- 野蛮槌击 (1303481)
}