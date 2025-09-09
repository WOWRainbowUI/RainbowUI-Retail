KM_Localization_zhTW = {}
local L = KM_Localization_zhTW

-- Localization file for "zhTW": 正體中文 (Taiwan)
-- Translated by: 三皈依

--[[Notes for Translators: In many locations throughout Key Master, line space is limited. This can cause
    overlapping or strange text display. Where possible, try to keep the overall length of the string comparable or shorter
    than the English version. If that is not possible, development adjustments may need made.
    If you are not comfortable setting up your own local testing to check for these issues, make sure you let a dev know
    so they can go over a screen-share with you.]]--

-- Translation issue? Assist us in correcting it! Visit: https://discord.gg/bbMaUpfgn8

L.LANGUAGE = "正體中文 (TW)"
L.TRANSLATOR = "三皈依" -- Translator display name

L.TOCNOTES = {} -- these are manaually copied to the TOC so they show up in the appropriate language in the AddOns list. Please translate them both but let a dev know if you update them later.
L.TOCNOTES["ADDONDESC"] = "傳奇+鑰石資訊以及協同工具"
L.TOCNOTES["ADDONNAME"] = "鑰石大師"

L.MAPNAMES = {} -- Note: Map abbrevations should be a max of 4 characters and be commonly known. Map names come directly from Blizzard already translated.

-- USE /fsstack to mouseover the icons in the player frame to find their mapIds if you need to add new dungeons.
-- DF S3
L.MAPNAMES[9001] = { name = "未知", abbr = "???" }
L.MAPNAMES[463] = { name = "Dawn of the Infinite: Galakrond\'s Fall", abbr = "殞落"}
L.MAPNAMES[464] = { name = "Dawn of the Infinite: Murozond\'s Rise", abbr = "崛起"}
L.MAPNAMES[244] = { name = "Atal'Dazar", abbr = "阿塔" }
L.MAPNAMES[248] = { name = "Waycrest Manor", abbr = "莊園" }
L.MAPNAMES[199] = { name = "Black Rook Hold", abbr = "玄鴉" }
L.MAPNAMES[198] = { name = "Darkheart Thicket", abbr = "暗心" }
L.MAPNAMES[168] = { name = "The Everbloom", abbr = "永茂" }
L.MAPNAMES[456] = { name = "Throne of the Tides", abbr = "海潮" }
--DF S4
L.MAPNAMES[399] = { name = "Ruby Life Pools", abbr = "晶紅" }
L.MAPNAMES[401] = { name = "The Azue Vault", abbr = "蒼藍" }
L.MAPNAMES[400] = { name = "The Nokhud Offensive", abbr = "諾庫德" }
L.MAPNAMES[402] = { name = "Algeth\'ar Academy", abbr = "學院" }
L.MAPNAMES[403] = { name = "Legacy of Tyr", abbr = "奧達曼" }
L.MAPNAMES[404] = { name = "Neltharus", abbr = "奈堡" }
L.MAPNAMES[405] = { name = "Brackenhide Hollow", abbr = "蕨皮" }
L.MAPNAMES[406] = { name = "Halls of Infusion", abbr = "灌注" }
--TWW S1
L.MAPNAMES[503] = { name = "『回音之城』厄拉卡拉", abbr = "回音" }
L.MAPNAMES[502] = { name = "蛛絲城", abbr = "蛛絲" }
L.MAPNAMES[505] = { name = "破曉者號", abbr = "破曉" }
L.MAPNAMES[501] = { name = "石庫", abbr = "石庫" }
L.MAPNAMES[353] = { name = "波拉勒斯圍城戰", abbr = "圍城" }
L.MAPNAMES[507] = { name = "格瑞姆巴托", abbr = "格瑞" }
L.MAPNAMES[375] = { name = "特拉希迷霧", abbr = "迷霧" }
L.MAPNAMES[376] = { name = "死靈戰地", abbr = "死靈" }
--TWW S2 zhTW
L.MAPNAMES[500] = { name = "培育所", abbr = "培育" }
L.MAPNAMES[525] = { name = "水閘行動", abbr = "水閘" }
L.MAPNAMES[247] = { name = "晶喜鎮！", abbr = "晶喜" }
L.MAPNAMES[370] = { name = "機械岡 - 工坊", abbr = "工坊" }
L.MAPNAMES[504] = { name = "暗焰裂縫", abbr = "裂縫" }
L.MAPNAMES[382] = { name = "苦痛劇場", abbr = "苦痛" }
L.MAPNAMES[506] = { name = "燼釀酒莊", abbr = "酒莊" }
L.MAPNAMES[499] = { name = "聖焰隱修院", abbr = "聖焰" }
--TWW S3
L.MAPNAMES[392] = { name = "索利亞的險招", abbr = "險招" }
L.MAPNAMES[391] = { name = "奇觀街道", abbr = "街道" }
L.MAPNAMES[378] = { name = "贖罪之殿", abbr = "贖罪" }
L.MAPNAMES[542] = { name = "埃達尼秘境", abbr = "秘境" }

L.XPAC = {}
L.XPAC[0] = { enum = "LE_EXPANSION_CLASSIC", desc = "經典版" }
L.XPAC[1] = { enum = "LE_EXPANSION_BURNING_CRUSADE", desc = "燃燒的遠征" }
L.XPAC[2] = { enum = "LE_EXPANSION_WRATH_OF_THE_LICH_KING", desc = "巫妖王之怒" }
L.XPAC[3] = { enum = "LE_EXPANSION_CATACLYSM", desc = "浩劫與重生" }
L.XPAC[4] = { enum = "LE_EXPANSION_MISTS_OF_PANDARIA", desc = "潘達利亞的迷霧" }
L.XPAC[5] = { enum = "LE_EXPANSION_WARLORDS_OF_DRAENOR", desc = "德拉諾之霸" }
L.XPAC[6] = { enum = "LE_EXPANSION_LEGION", desc = "軍臨天下" }
L.XPAC[7] = { enum = "LE_EXPANSION_BATTLE_FOR_AZEROTH", desc = "決戰艾澤拉斯" }
L.XPAC[8] = { enum = "LE_EXPANSION_SHADOWLANDS", desc = "暗影之境" }
L.XPAC[9] = { enum = "LE_EXPANSION_DRAGONFLIGHT", desc = "巨龍崛起" }
L.XPAC[10] = { enum = "LE_EXPANSION_WAR_WITHIN", desc = "地心之戰" }

L.MPLUSSEASON = {}
L.MPLUSSEASON[11] = { name = "第3賽季" }
L.MPLUSSEASON[12] = { name = "第4賽季" }
L.MPLUSSEASON[13] = { name = "第1賽季" } -- expecting season 13 to be TWW S1
L.MPLUSSEASON[14] = { name = "第2賽季" } -- expecting season 14 to be TWW S2
L.MPLUSSEASON[15] = { name = "第3賽季" } -- expecting season 15 to be TWW S2

L.DISPLAYVERSION = "版本"
L.WELCOMEMESSAGE = "歡迎回來"
L.ON = "開"
L.OFF = "關"
L.ENABLED = "啟用"
L.DISABLED = "停用"
L.CLICK = "點擊"
L.CLICKDRAG = "點擊 + 拖拉"
L.TOOPEN = "來開啟"
L.TOREPOSITION = "來重新定位"
L.EXCLIMATIONPOINT = "!"
L.THISWEEKSAFFIXES = "本週..."
L.YOURRATING = "你的評分"
L.ERRORMESSAGES = "錯誤訊息為"
L.ERRORMESSAGESNOTIFY = "通知: 啟用錯誤訊息。"
L.DEBUGMESSAGES = "偵錯訊息為"
L.DEBUGMESSAGESNOTIFY = "通知: 啟用偵錯訊息。"
L.COMMANDERROR1 = "無效指令"
L.COMMANDERROR2 = "輸入"
L.COMMANDERROR3 = "指令"
L.YOURCURRENTKEY = "你的鑰石"
L.ADDONOUTOFDATE = "你的 Key Master 插件已經過期！"
L.INSTANCETIMER = "副本訊息"
L.VAULTINFORMATION = "傳奇+ 寶庫進度"
L.TIMELIMIT = "時間限制"
L.SEASON = "賽季"
L.COMBATMESSAGE = { errormsg = "Key Master無法在戰鬥中使用。", chatmsg = "介面將會在您離開戰鬥後開啟。"}

L.COMMANDLINE = {} -- translate whatever in this section would be standard of an addon in the language. i.e. /km show, /km XXXX, or /XX XXXX It will work just fine.
L.COMMANDLINE["/km"] = { name = "/km", text = "/km"}
L.COMMANDLINE["/keymaster"] = {name = "/keymaster", text = "/keymaster"}
L.COMMANDLINE["Show"] = { name = "show", text = " - 顯示/隱藏主視窗。"}
L.COMMANDLINE["Help"] = { name = "help", text = " - 顯示幫助選單。"}
L.COMMANDLINE["Errors"] = { name = "errors", text = " - 切換錯誤訊息。"}
L.COMMANDLINE["Debug"] = { name = "debug", text = " - 切換偵錯訊息。"}
L.COMMANDLINE["Version"] = { name = "version", text = " - shows the current build version." }

L.TOOLTIPS = {}
L.TOOLTIPS["MythicRating"] = { name = "傳奇評分", text = "此為角色當前的傳奇+評分。" }
L.TOOLTIPS["OverallScore"] = { name = "總體分數", text = "總分是地圖的暴君和強悍分數的結合。（涉及大量計算）"}
L.TOOLTIPS["TeamRatingGain"] = { name = "估計隊伍評分收穫", text = "這是Key Master內部進行的估計。 該數字代表成功完成隊伍給予的鑰石時，您當前隊伍的總最低評分收益潛力。它可能不是100％準確的，並且僅出於估計目的。"}

L.PARTYFRAME = {}
L.PARTYFRAME["PartyInformation"] = { name = "隊伍資訊", text = "隊伍資訊"}
L.PARTYFRAME["OverallRating"] = { name = "當前總分", text = "當前總分" }
L.PARTYFRAME["PartyPointGain"] = { name = "隊伍獲得分數", text = "隊伍獲得分數"}
L.PARTYFRAME["Level"] = { name = "層級", text = "層級" }
L.PARTYFRAME["Weekly"] = { name = "每週", text = "每週"}
L.PARTYFRAME["NoAddon"] = { name = "沒偵測到插件", text = "未偵測到！"}
L.PARTYFRAME["PlayerOffline"] = { name = "玩家離線", text = "玩家已離線。"}
L.PARTYFRAME["TeamRatingGain"] = { name = "隊伍收益預估", text = "預估隊伍評分收益"}
L.PARTYFRAME["MemberPointsGain"] = { name = "收益預估", text = "預估個人分數收益，當完成 +1 的可用鑰石時。"}
L.PARTYFRAME["NoKey"] = { name = "無鑰石", text = "無鑰石"}
L.PARTYFRAME["NoPartyInfo"] = { text = "隊伍成員資訊在配對隊伍中不可用。 (地城搜尋器, 團隊搜尋器, 等等。)" }

L.PLAYERFRAME = {}
L.PLAYERFRAME["KeyLevel"] = { name = "鑰石層級", text = "要計算的鑰石層級。"}
L.PLAYERFRAME["Gain"] = { name = "收益", text = "潛在的評分收益。"}
L.PLAYERFRAME["New"] = { name = "新", text = "你完成此鑰石+1後的評分。"}
L.PLAYERFRAME["RatingCalculator"] = { name = "評分計算", text = "計算潛在評分收益。"}
L.PLAYERFRAME["EnterKeyLevel"] = { name = "輸入鑰石層數", text = "輸入一個鑰石層數來觀看"}
L.PLAYERFRAME["YourBaseRating"] = { name = "基礎評分收益", text = "你的基礎評分收益預測。"}
L.PLAYERFRAME["Characters"] = "角色"
L.PLAYERFRAME["DungeonTools"] = { name = "地下城工具", text = "與此地下城相關的各種工具。"}

L.CHARACTERINFO = {}
L.CHARACTERINFO["NoKeyFound"] = { name = "未找到鑰石", text = "未找到鑰石"}
L.CHARACTERINFO["KeyInVault"] = { name = "鑰石在寶庫", text = "在寶庫"}
L.CHARACTERINFO["AskMerchant"] = { name = "詢問鑰石商人", text = "鑰石商人"}

L.TABPLAYER = "玩家"
L.TABPARTY = "隊伍"
L.TABABOUT = "關於"
L.TABCONFIG = "配置"

L.CONFIGURATIONFRAME = {}
L.CONFIGURATIONFRAME["DisplaySettings"] = { name = "顯示設定", text = "顯示設定"}
L.CONFIGURATIONFRAME["ToggleRatingFloat"] = { name = "切換評分小數點", text = "顯示評分小數點。"}
L.CONFIGURATIONFRAME["ShowMiniMapButton"] = { name = "顯示小地圖按鈕", text = "顯示小地圖按鈕。"}
L.CONFIGURATIONFRAME["DiagnosticSettings"] = { name = "診斷設定", text = "診斷設定。"}
L.CONFIGURATIONFRAME["DisplayErrorMessages"] = { name = "顯示錯誤", text = "顯示錯誤訊息。"}
L.CONFIGURATIONFRAME["DisplayDebugMessages"] = { name = "顯示偵錯", text = "顯示偵錯訊息。"}
L.CONFIGURATIONFRAME["DiagnosticsAdvanced"] = { name = "進階診斷", text="注意: 這些僅用於診斷目的。 如果啟用，他們可能會洗您的聊天視窗！"}
L.CONFIGURATIONFRAME["CharacterSettings"] = { name="角色清單過濾", text = "分身角色清單過濾選項。" }
L.CONFIGURATIONFRAME["FilterByServer"] = { name = "當前伺服器", text = "僅顯示當前伺服器。" }
L.CONFIGURATIONFRAME["FilterByNoRating"] = { name = "無評分", text = "僅顯示有評分的角色。" }
L.CONFIGURATIONFRAME["FilterByNoKey"] = { name = "無鑰石No Key", text = "僅顯示有鑰石的角色。" }
L.CONFIGURATIONFRAME["FilterByMaxLvl"] = { name = "只限滿等", text = "只顯示滿等的角色。" }
L.CONFIGURATIONFRAME["Purge"] = { present = "清除", past = "已清除" }

L.ABOUTFRAME = {}
L.ABOUTFRAME["AboutGeneral"] = { name = "Key Master 資訊", text = "Key Master 資訊"}
L.ABOUTFRAME["AboutAuthors"] = { name = "作者", text = "作者"}
L.ABOUTFRAME["AboutSpecialThanks"] = { name = "特別感謝", text = "特別感謝"}
L.ABOUTFRAME["AboutContributors"] = { name = "貢獻者", text = "貢獻者"}
L.ABOUTFRAME["Translators"] = { text = "翻譯者" }
L.ABOUTFRAME["WhatsNew"] = { text = "顯示更新的訊息"}

L.SYSTEMMESSAGE = {}
L.SYSTEMMESSAGE["NOTICE"] = { text = "注意：本賽季評分計算仍需驗證。"}