local Name, Addon = ...
local Locale = Addon.Locale
local lang = "zhTW"

-- Chat messages
local L = {lang = lang}
setmetatable(L, Locale.MT)
Locale[lang] = L

-- Messages
L["MSG_BID_1"] = "請問您有需要 %s 嗎？能否讓我呢？感謝您！"
L["MSG_BID_2"] = "如果您對 %s 無需求，可以讓給我嗎？謝謝！"
L["MSG_BID_3"] = "如果您對 %s 沒有需求的話我可以使用，非常感謝！"
L["MSG_BID_4"] = "如果您 %s 根本無需求，我有榮幸得到它嗎？"
L["MSG_BID_5"] = "請問您有需要 %s 嗎？或是我有榮幸可以得到它嗎？"
L["MSG_HER"] = "她"
L["MSG_HIM"] = "他"
L["MSG_ITEM"] = "物品"
L["MSG_NEED"] = "需要,是"
L["MSG_PASS"] = "放棄,不,不用"
L["MSG_ROLL"] = "骰,分享,送人"
L["MSG_ROLL_ANSWER_AMBIGUOUS"] = "我現正要送出多件物品，請將你想要的物品連結傳送給我。"
L["MSG_ROLL_ANSWER_BID"] = "好的，我已經登記了你在 %s 的競標。"
L["MSG_ROLL_ANSWER_NO"] = "抱歉，您無法再競骰該物品。"
L["MSG_ROLL_ANSWER_NO_OTHER"] = "抱歉！我已經給別人了。"
L["MSG_ROLL_ANSWER_NO_SELF"] = "抱歉，我自己也有需求。"
L["MSG_ROLL_ANSWER_NOT_ELIGIBLE"] = "抱歉，您不具備條件獲得該物品。"
L["MSG_ROLL_ANSWER_NOT_TRADABLE"] = "抱歉，這件無法交易。"
L["MSG_ROLL_ANSWER_STARTED"] = "好的，我會開始它的擲骰。"
L["MSG_ROLL_ANSWER_YES"] = "可以給你，請來跟我交易。"
L["MSG_ROLL_ANSWER_YES_MASTERLOOT"] = "可以給你，請交易 <%s>。"
L["MSG_ROLL_DISENCHANT"] = "<%s> 將分解 %s -> 交易我！"
L["MSG_ROLL_DISENCHANT_MASTERLOOT"] = "<%s> 將分解%s 由<%s>提供 -> 交易他/她！"
L["MSG_ROLL_DISENCHANT_MASTERLOOT_OWN"] = "<％s>會分解他/她擁有的％s！"
L["MSG_ROLL_DISENCHANT_WHISPER"] = "您被選中來分解%s，請交易我。"
L["MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT"] = "您被選中來分解%s 由<%s>提供，請交易他/她。"
L["MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_OWN"] = "你被指定分解自己的％s！"
L["MSG_ROLL_START"] = "送出裝備 %s -> 要的密我，或 /roll %d！"
L["MSG_ROLL_START_CONCISE"] = "%s 有人需要嗎？"
L["MSG_ROLL_START_MASTERLOOT"] = "送出由<%2$s>提供的 %1$s -> /w 我，或 /roll %3$s！"
L["MSG_ROLL_WINNER"] = "<%s> 已贏得 %s -> 請跟我交易！"
L["MSG_ROLL_WINNER_CONCISE"] = "%s 來交易我！"
L["MSG_ROLL_WINNER_MASTERLOOT"] = "<%1$s> 已贏得由<%3$s>提供的 %2$s -> 請交易他/她！"
L["MSG_ROLL_WINNER_MASTERLOOT_OWN"] = "<%s> 已贏得他/她自己的 %s！"
L["MSG_ROLL_WINNER_WHISPER"] = "你已經贏得 %s！請跟我交易。"
L["MSG_ROLL_WINNER_WHISPER_CONCISE"] = "請交易我。"
L["MSG_ROLL_WINNER_WHISPER_MASTERLOOT"] = "你已贏得由<%2$s>提供的 %1$s！請交易他/她。"
L["MSG_ROLL_WINNER_WHISPER_MASTERLOOT_OWN"] = "你贏得自己的 %s！"


-- Addon
local L = LibStub("AceLocale-3.0"):NewLocale(Name, lang, lang == Locale.FALLBACK)
if not L then return end

L["ACTION"] = "動作"
L["ACTIONS"] = "動作"
L["ADVERTISE"] = "在聊天頻道發佈訊息"
L["ANSWER"] = "回答"
L["ASK"] = "詢問"
L["AWARD"] = "分配"
L["AWARD_LOOT"] = "分配戰利品"
L["AWARD_RANDOMLY"] = "隨機分配"
L["BID"] = "競標"
L["COMMUNITY_GROUP"] = "社群隊伍"
L["COMMUNITY_MEMBER"] = "社群成員"
L["CONFIRM"] = "確認"
L["DISABLED"] = "停用"
L["DOWN"] = "下"
L["ENABLED"] = "啟用"
L["EQUIPPED"] = "已裝備"
L["GET_FROM"] = "得到自"
L["GIVE_AWAY"] = "分享給人"
L["GIVE_TO"] = "給予"
L["GUILD_MASTER"] = "公會會長"
L["GUILD_OFFICER"] = "公會幹部"
L["HIDE"] = "隱藏"
L["HIDE_ALL"] = "隱藏全部"
L["ITEM"] = "物品"
L["ITEM_LEVEL"] = "物品等級"
L["KEEP"] = "自己要"
L["LEFT"] = "左"
L["MASTERLOOTER"] = "負責分裝"
L["MESSAGE"] = "訊息"
L["ML"] = "分裝者"
L["OPEN_ROLLS"] = "開啟擲骰視窗"
L["OWNER"] = "提供者"
L["PLAYER"] = "玩家"
L["PRIVATE"] = "私人"
L["PUBLIC"] = "公開"
L["RAID_ASSISTANT"] = "團隊助理"
L["RAID_LEADER"] = "團隊領隊"
L["RESTART"] = "重新開始"
L["RIGHT"] = "右"
L["RINGS"] = "戒指"
L["ROLL"] = "擲骰"
L["ROLLS"] = "骰裝"
L["SECONDS"] = "%d秒"
L["SET_ANCHOR"] = "設置定位點：往%s以及%s延展"
L["SHOW"] = "顯示"
L["SHOW_ALL"] = "顯示全部"
L["SHOW_HIDE"] = "顯示/隱藏"
L["TRADE"] = "交易"
L["TRINKETS"] = "飾品"
L["UP"] = "上"
L["VERSION_NOTICE"] = "插件已經有新的版本，請更新以保持跟所有人的相容性，才不會錯過任何戰利品！"
L["VOTE"] = "表決"
L["VOTE_WITHDRAW"] = "收回"
L["VOTES"] = "表決"
L["WAIT"] = "等候"
L["WINNER"] = "獲勝者"
L["WON"] = "獲勝"
L["YOUR_BID"] = "你的競標"

-- Commands
L["HELP"] = [=[開始物品的擲骰或競標（/PersoLootRoll 或 /plr）。
使用方法：
/plr: 開啟擲骰視窗
/plr help: 發送此幫助訊息
/plr roll [物品]* (<持續時間> <擁有者>): 開始一個或多個物品的擲骰
/plr bid [物品] (<擁有者> <bid>): 競標來自其他玩家的物品
/plr trade (<player>): 跟給予的玩家或你當前目標交易
/plr test: 開始一個測試擲骰(只有你能看到)
/plr options: 開啟選項視窗
/plr config: 透過指令更改設置
/plr debug: 切換偵錯模式

解釋: [..] = 物品連結, * = 一個或多個物品， (..) = 備選的]=]
L["USAGE_BID"] = "使用方法：/plr bid [物品] (<提供者> <bid>)"
L["USAGE_ROLL"] = "使用：/plr roll [item]* (<提供者> <持續時間>)"

-- Errors
L["ERROR_CMD_UNKNOWN"] = "未知指令'%s'"
L["ERROR_COLLECTION_FILTERS_DISABLED"] = "全部的收藏品過濾都已停用。如果想要骰缺少的的收藏物品，請在物品過濾選項中啟用。"
L["ERROR_ITEM_NOT_TRADABLE"] = "你無法交易這項物品。"
L["ERROR_NOT_IN_GROUP"] = "你不在隊伍或團隊中。"
L["ERROR_NOT_MASTERLOOTER_OTHER_OWNER"] = "你需要成為拾取分配者來為其他玩家的物品創建擲骰。"
L["ERROR_NOT_MASTERLOOTER_TIMEOUT"] = "當拾取分配者不是你自己時，你無法更改擲骰時間。"
L["ERROR_OPT_MASTERLOOT_EXPORT_FAILED"] = "匯出分裝設置到<%s>失敗了！"
L["ERROR_PLAYER_NOT_FOUND"] = "找不到玩家 %s。"
L["ERROR_ROLL_BID_IMPOSSIBLE_OTHER"] = "%s已發送了%s的競標，但現在不允許這樣做。"
L["ERROR_ROLL_BID_IMPOSSIBLE_SELF"] = "你現在無法競標該物品。"
L["ERROR_ROLL_BID_UNKNOWN_OTHER"] = "%s已發送了%s的競標邀請。"
L["ERROR_ROLL_BID_UNKNOWN_SELF"] = "這不是有效的競標。"
L["ERROR_ROLL_STATUS_NOT_0"] = "此擲骰已經開始或是結束。"
L["ERROR_ROLL_STATUS_NOT_1"] = "此擲骰沒有運行。"
L["ERROR_ROLL_UNKNOWN"] = "此擲骰不存在。"
L["ERROR_ROLL_VOTE_IMPOSSIBLE_OTHER"] = "%s已經發送了%s的投票表決，但現在不允許這樣做。"
L["ERROR_ROLL_VOTE_IMPOSSIBLE_SELF"] = "你現在無法對該物品進行投票。"

-- GUI
L["DIALOG_MASTERLOOT_ASK"] = "<%s>想成為你的分裝者。"
L["DIALOG_OPT_MASTERLOOT_LOAD"] = "這將用你公會/社群訊息中儲存的設置替換你當前的分裝設置，你確定要繼續嗎？"
L["DIALOG_OPT_MASTERLOOT_SAVE"] = "這將使用您當前的設置替換公會/社群訊息中的任何分裝設置，您確定要繼續嗎？"
L["DIALOG_ROLL_CANCEL"] = "你想要取消這次擲骰嗎？"
L["DIALOG_ROLL_RESTART"] = "你想要重新開始擲骰嗎？"
L["DIALOG_ROLL_WHISPER_ASK"] = "您想要為了拾取物自動密語其他玩家嗎？您可以隨時在\"訊息\"選項中變更。"
L["FILTER"] = "過濾"
L["FILTER_ALL"] = "所有玩家"
L["FILTER_ALL_DESC"] = "包含所有玩家的擲骰，並非只有你的或是你感興趣的物品。"
L["FILTER_AWARDED"] = "已取得"
L["FILTER_AWARDED_DESC"] = "包含已經由其他人贏得的骰裝。"
L["FILTER_DONE"] = "已完成"
L["FILTER_DONE_DESC"] = "包含已經結束的擲骰。"
L["FILTER_HIDDEN"] = "隱藏"
L["FILTER_HIDDEN_DESC"] = "包含已取消、處理中、已放棄以及隱藏的骰裝。"
L["FILTER_TRADED"] = "已交易"
L["FILTER_TRADED_DESC"] = "包含物品已經交易的擲骰。"
L["MENU_MASTERLOOT_SEARCH"] = "搜尋有人負責分裝的團體"
L["MENU_MASTERLOOT_SETTINGS"] = "拾取分配設置"
L["MENU_MASTERLOOT_START"] = "成為分裝者"
L["TIP_ADDON_MISSING"] = "插件缺少："
L["TIP_ADDON_VERSIONS"] = "插件版本："
L["TIP_CHAT_TO_TRADE"] = "交易前請先詢問提供者"
L["TIP_COMP_ADDON_USERS"] = "相容的插件使用者："
L["TIP_ENABLE_WHISPER_ASK"] = "提示：右鍵點擊啟用戰利品自動詢問"
L["TIP_MASTERLOOT"] = "隊長分配是啟用的"
L["TIP_MASTERLOOT_INFO"] = [=[|cffffff00分裝者:|r %s 
|cffffff00擲骰時間:|r %ds (+ %ds 每項物品) 
|cffffff00議會:|r %s |
cffffff00競標:|r %s 
|cffffff00表決:|r %s]=]
L["TIP_MASTERLOOT_START"] = "成為或搜尋負責分裝者"
L["TIP_MASTERLOOT_STOP"] = "移除負責分裝者"
L["TIP_MASTERLOOTING"] = "有分裝者的隊伍 (%d):"
L["TIP_MINIMAP_ICON"] = [=[|cffffff00左鍵:|r 開關骰裝視窗 
|cffffff00右鍵:|r 設定選項]=]
L["TIP_SUPPRESS_CHAT"] = "|cffffff78提示:|r 您可以通過按住Shift鍵點擊“出價/放棄”按鈕來隱藏單個聊天訊息。"
L["TIP_TEST"] = "顯示測試的擲骰"
L["TIP_VOTES"] = "表決來自:"

-- Options-Home
L["OPT_ACTIONS_WINDOW"] = "顯示動作視窗"
L["OPT_ACTIONS_WINDOW_DESC"] = "當有處理中的動作時顯示動作視窗，例如，當你贏得一件物品但還需要交易某人才能得到它。"
L["OPT_ACTIONS_WINDOW_MOVE"] = "移動"
L["OPT_ACTIONS_WINDOW_MOVE_DESC"] = "移動動作視窗到一旁。"
L["OPT_ACTIVE_GROUPS"] = "根據團體類型啟用"
L["OPT_ACTIVE_GROUPS_DESC"] = [=[只有當您處於以下團體類型時才啟用。

|cffffff78公會團隊：|r團隊的%d%%或更多的成員是來自一個公會。
|cffffff78社群團隊：|r團隊的%d%%或更多的成員是來自一個魔獸社群。]=]
L["OPT_ALLOW_DISENCHANT"] = "允許 \"分解\" 的競標"
L["OPT_ALLOW_DISENCHANT_DESC"] = "允許其他人對你自己的物品競標 \"分解\"。"
L["OPT_AUTHOR"] = "|cffffff00作者:|r Shrugal (EU-Mal'Ganis)"
L["OPT_AWARD_SELF"] = "自行選擇你的物品的獲勝者"
L["OPT_AWARD_SELF_DESC"] = "自行選擇誰該得到你的戰利品，而非讓插件隨機選擇，當你是拾取分配者時，始終啟用此功能。"
L["OPT_BID_PUBLIC"] = "公開競標"
L["OPT_BID_PUBLIC_DESC"] = "你擲骰的競標是公開的，所有使用此插件的人都可以看見。"
L["OPT_CHILL_MODE"] = "冷漠模式"
L["OPT_CHILL_MODE_DESC"] = [=[冷漠模式的目的是消除分享戰利品的壓力，即使這意味著事情會花費更長的時間。 如果啟用它，以下內容將會更改：

|cffffff781.|r 在你真正決定分享它們之前，你的擲骰不會開始，因此你有足夠的時間選擇，而其他插件用戶在你決定之前不會看到你的物品。
|cffffff782.|r 如果您選擇了自己是自己物品的獲勝者，那麼您的運行時間是正常時間的兩倍，或者根本無時間限制(參見下個選項)。
|cffffff783.|r 來自您團體中的非插件用戶的擲骰也將保持打開狀態，直到您決定是否需要它們為止。

|cffff0000重要:|r 在沒有啟用模式的情況下，其他插件用戶的擲骰仍將具有正常運行時間。 如果您想要冷漠模式運行，請確保團體中的每個人都啟用此選項。]=]
L["OPT_COLLECTIONS"] = "無論其他規則如何，請始終顯示這些收藏中缺少的可收藏物品。"
L["OPT_DISENCHANT"] = "分解"
L["OPT_DISENCHANT_DESC"] = "如果您擁有附魔專業並且物品所有者允許，則對您無法使用的項目競標“分解”。"
L["OPT_DONT_SHARE"] = "不分享戰利品"
L["OPT_DONT_SHARE_DESC"] = "不去骰別人的戰利品但也不分享自己的。此插件將會阻擋對你戰利品的請求(如果啟用的話)，但你仍可以成為分裝者以及戰利品議會成員。"
L["OPT_ENABLE"] = "啟用"
L["OPT_ENABLE_DESC"] = "啟用或停用此插件"
L["OPT_ENABLE_MODULE_DESC"] = "啟用或停用此模組"
L["OPT_ILVL_THRESHOLD"] = "物品等級門檻"
L["OPT_ILVL_THRESHOLD_DESC"] = [=[忽略物品基於物品等級，會對比您當前裝備或背包中同部位物品。

|cffffff78Negative:|r 物品的等級最多可以比你的低這麼多。
|cffffff78Positive:|r 物品的等級必須至少比你的高出這麼多。]=]
L["OPT_ILVL_THRESHOLD_DOUBLE"] = "雙倍門檻在..."
L["OPT_ILVL_THRESHOLD_DOUBLE_DESC"] = "某些物品應該具有兩倍的物品等級門檻，因為觸發等理由，可以使數值變化很大。"
L["OPT_ILVL_THRESHOLD_RINGS"] = "戒指門檻為雙倍"
L["OPT_ILVL_THRESHOLD_RINGS_DESC"] = "戒指的門檻應該是正常值的兩倍，因為缺乏主屬性它們的價值可能會有很大差異。"
L["OPT_ILVL_THRESHOLD_TRINKETS"] = "飾品門檻為雙倍"
L["OPT_ILVL_THRESHOLD_TRINKETS_DESC"] = "飾品的門檻應該是正常值的兩倍，因為觸發特效會讓收益變化很大。"
L["OPT_INFO"] = "資訊"
L["OPT_INFO_DESC"] = "關於此插件的一些資訊。"
L["OPT_ITEM_FILTER"] = "物品過濾"
L["OPT_ITEM_FILTER_DESC"] = "更改你想要擲骰的物品。"
L["OPT_ITEM_FILTER_ENABLE"] = "啟用額外規則"
L["OPT_ITEM_FILTER_ENABLE_DESC"] = "您無法使用或發送到小號的物品將始終被過濾掉。下面您可以設置物品必須滿足的額外條件，以便顯示給您。"
L["OPT_LVL_THRESHOLD"] = "角色等級門檻"
L["OPT_LVL_THRESHOLD_DESC"] = "忽略哪些要求角色等級高於目前的物品。設置為 -1停用此過濾。"
L["OPT_MINIMAP_ICON"] = "顯示小地圖圖示"
L["OPT_MINIMAP_ICON_DESC"] = "顯示或隱藏小地圖圖示"
L["OPT_MISSING_PETS"] = "缺少的寵物"
L["OPT_MISSING_TRANSMOG"] = "缺少的塑形外觀"
L["OPT_MISSING_TRANSMOG_ITEM"] = "檢查塑形物品"
L["OPT_MISSING_TRANSMOG_ITEM_DESC"] = "檢查您是否收藏了特定的物品，而不僅僅是物品的外觀"
L["OPT_ONLY_MASTERLOOT"] = "只有拾取分配"
L["OPT_ONLY_MASTERLOOT_DESC"] = "只有使用拾取分配時才啟用此插件(例如跟你的公會一起)"
L["OPT_PAWN"] = "檢查 \"Pawn\" 提供的數值"
L["OPT_PAWN_DESC"] = "只骰裝備屬性比較插件 \"Pawn\" 標示為提升的物品。"
L["OPT_ROLL_FRAMES"] = "顯示擲骰框架"
L["OPT_ROLL_FRAMES_DESC"] = "當某人拾取你感興趣的戰利品時顯示擲骰框架，這樣你就可以骰它。"
L["OPT_ROLLS_WINDOW"] = "顯示擲骰視窗"
L["OPT_ROLLS_WINDOW_DESC"] = "當某人拾取你感興趣的戰利品時總是顯示擲骰視窗(所有的擲骰都在上面)。當你是分裝者時，始終啟用此功能。"
L["OPT_SPECS"] = "專精"
L["OPT_SPECS_DESC"] = "只建議這些職業專精的戰利品。"
L["OPT_TRANSLATION"] = "|cffffff00翻譯:|r 三皈依-暗影之月 (TW)"
L["OPT_TRANSMOG"] = "檢查塑形外觀"
L["OPT_TRANSMOG_DESC"] = "擲骰那些你還未擁有外觀的物品。"
L["OPT_UI"] = "使用者介面"
L["OPT_UI_DESC"] = "根據自己的喜好自訂PersoLootRoll的外觀。"
L["OPT_VERSION"] = "|cffffff00版本:|r "

-- Options-Masterloot
L["OPT_MASTERLOOT"] = "拾取分配"
L["OPT_MASTERLOOT_APPROVAL"] = "認可"
L["OPT_MASTERLOOT_APPROVAL_ACCEPT"] = "自動接受分裝者"
L["OPT_MASTERLOOT_APPROVAL_ACCEPT_DESC"] = "自動接受來自其他玩家的分裝者請求。"
L["OPT_MASTERLOOT_APPROVAL_ALLOW"] = "允許成為分裝者"
L["OPT_MASTERLOOT_APPROVAL_ALLOW_ALL"] = "允許所有人"
L["OPT_MASTERLOOT_APPROVAL_ALLOW_ALL_DESC"] = "|cffff0000警告:|r 這會允許每個人請求成為分裝者，並可能騙你放棄戰利品！只有你知道自己在做什麼的情況下才可以啟用它。"
L["OPT_MASTERLOOT_APPROVAL_ALLOW_DESC"] = [=[選擇誰可以請求成為你的分裝者。你仍然會收到一個需要確認的彈出訊息，所以你可以在當時拒絕成為分裝者。

|cffffff00公會團隊:|r 團隊的%d%%或更多的成員是來自一個公會。]=]
L["OPT_MASTERLOOT_APPROVAL_DESC"] = "在此你可以決定誰可以成為你的分裝者。"
L["OPT_MASTERLOOT_APPROVAL_WHITELIST"] = "分裝者白名單"
L["OPT_MASTERLOOT_APPROVAL_WHITELIST_DESC"] = "如果上述選項某人並非真正適宜，但你仍希望該玩家能成為你的分裝者，那麼請在此輸入名稱，用空格或逗號在名稱中分隔。"
L["OPT_MASTERLOOT_AWARD"] = "給予中"
L["OPT_MASTERLOOT_BIDS_AND_VOTES"] = "競標與投票"
L["OPT_MASTERLOOT_CLUB"] = "公會/社群"
L["OPT_MASTERLOOT_CLUB_DESC"] = "選擇要從何公會/社群來匯入/匯出設置。"
L["OPT_MASTERLOOT_COUNCIL"] = "議會"
L["OPT_MASTERLOOT_COUNCIL_CLUB_RANK"] = "議會的公會/社群階級"
L["OPT_MASTERLOOT_COUNCIL_CLUB_RANK_DESC"] = "除了上面的選項之外，想要加入這個公會/社群階級的成員進入議會。"
L["OPT_MASTERLOOT_COUNCIL_DESC"] = "議會的玩家可以投票表決誰該得到戰利品。"
L["OPT_MASTERLOOT_COUNCIL_ROLES"] = "議會角色"
L["OPT_MASTERLOOT_COUNCIL_ROLES_DESC"] = "那些玩家會自動成為議會的成員。"
L["OPT_MASTERLOOT_COUNCIL_WHITELIST"] = "議會白名單"
L["OPT_MASTERLOOT_COUNCIL_WHITELIST_DESC"] = "你還可以在議會中命名特定的玩家。用空格或逗號分隔多個人。"
L["OPT_MASTERLOOT_DESC"] = "當你(或其他人)成為分裝者，所有戰利品都將由此人分發。你會收到你贏得什麼物品以及誰贏得你物品的通知，因此你可以交易物品給合適的人。"
L["OPT_MASTERLOOT_EXPORT_DONE"] = "分裝設置成功匯出到<%s>。"
L["OPT_MASTERLOOT_EXPORT_GUILD_ONLY"] = "請使用本文替換社群的當前訊息，因為自動替換它僅適用於公會。"
L["OPT_MASTERLOOT_EXPORT_NO_PRIV"] = "請讓會長用這個文字替換公會的訊息，因為你自己沒有權限這樣做。"
L["OPT_MASTERLOOT_EXPORT_WINDOW"] = "匯出分裝設置"
L["OPT_MASTERLOOT_LOAD"] = "載入"
L["OPT_MASTERLOOT_LOAD_DESC"] = "從公會/社群的說明訊息中載入分裝設置。"
L["OPT_MASTERLOOT_RULES"] = "規則"
L["OPT_MASTERLOOT_RULES_ALLOW_DISENCHANT_DESC"] = "允許團體成員在物品上擲骰\"分解\"。"
L["OPT_MASTERLOOT_RULES_ALLOW_KEEP"] = "允許保留戰利品"
L["OPT_MASTERLOOT_RULES_ALLOW_KEEP_DESC"] = "允許物品擁有者保留他們的戰利品，只有當選擇不保留的時候才可以送人。"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD"] = "自動給予戰利品"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_DESC"] = "讓插件決定誰應該獲得戰利品，基於議會投票，競標和裝等等因素。"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT"] = "自動給予時間(基本)"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT_DESC"] = "在自動給予戰利品之前等待的基準時間，所以你有時間投票表決並可能自己決定。"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT_PER_ITEM"] = "自動給予時間(每項物品)"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT_PER_ITEM_DESC"] = "將每個掉落的物品都加入到基本自動給予時間。"
L["OPT_MASTERLOOT_RULES_BID_PUBLIC"] = "公開競標"
L["OPT_MASTERLOOT_RULES_BID_PUBLIC_DESC"] = "你可以公開競標，這樣每個人都可以看到誰出價。"
L["OPT_MASTERLOOT_RULES_DESC"] = "當你是分裝者時，這些選項適用於每個人。"
L["OPT_MASTERLOOT_RULES_DISENCHANTER"] = "分解者"
L["OPT_MASTERLOOT_RULES_DISENCHANTER_DESC"] = "將沒人要的戰利品給這些玩家分解。用空格或逗號分隔多個名稱。"
L["OPT_MASTERLOOT_RULES_GREED_ANSWERS"] = "自訂 '貪婪' 的應答"
L["OPT_MASTERLOOT_RULES_GREED_ANSWERS_DESC"] = [=[當擲骰'貪婪'時最多可依據優先等級指定9個自訂回答。你還可以插入'%s'本身讓優先級降低到先前回答之下。使用逗號分隔多個條目。

當擲骰戰利品時，可以透由右鍵點擊'貪婪'按鈕來查閱。]=]
L["OPT_MASTERLOOT_RULES_NEED_ANSWERS"] = "自訂 '需求' 的應答"
L["OPT_MASTERLOOT_RULES_NEED_ANSWERS_DESC"] = [=[當擲骰'需求'時最多可依據優先等級指定9個自訂回答。你還可以插入'%s'本身讓優先級降低到先前回答之下。使用逗號分隔多個條目。

當擲骰戰利品時，可以透由右鍵點擊'需求'按鈕來查閱。]=]
L["OPT_MASTERLOOT_RULES_START_ALL"] = "開始所有人的擲骰"
L["OPT_MASTERLOOT_RULES_START_ALL_DESC"] = "為沒有附加戰利品的隊伍成員開始所有合適物品的擲骰。"
L["OPT_MASTERLOOT_RULES_START_LIMIT"] = "並行擲骰限制"
L["OPT_MASTERLOOT_RULES_START_LIMIT_DESC"] = [=[同時運行的最大擲骰數。即使您選擇手動開始擲骰，後續擲骰也會在前一個擲骰結束時自動開始。

設置為0來禁用。]=]
L["OPT_MASTERLOOT_RULES_START_MANUALLY"] = "手動開始擲骰"
L["OPT_MASTERLOOT_RULES_START_MANUALLY_DESC"] = "不要自動開始新的擲骰，而是透過主擲骰視窗手動開始。"
L["OPT_MASTERLOOT_RULES_START_WHISPER"] = "根據密語開始擲骰"
L["OPT_MASTERLOOT_RULES_START_WHISPER_DESC"] = "允許沒有插件的隊伍成員密語你物品連結以及關鍵字\"%s\"來開始他們物品的擲骰。"
L["OPT_MASTERLOOT_RULES_TIMEOUT_BASE"] = "骰裝時間(基本)"
L["OPT_MASTERLOOT_RULES_TIMEOUT_BASE_DESC"] = "無論掉落多少物品，骰裝的基本運行時間。"
L["OPT_MASTERLOOT_RULES_TIMEOUT_PER_ITEM"] = "骰裝時間(每項物品)"
L["OPT_MASTERLOOT_RULES_TIMEOUT_PER_ITEM_DESC"] = "將每個掉落的物品都加入到基本骰裝運行時間。"
L["OPT_MASTERLOOT_RULES_VOTE_PUBLIC"] = "投票公開"
L["OPT_MASTERLOOT_RULES_VOTE_PUBLIC_DESC"] = "你可以讓議會表決公開透明，所以每個人都可以看到誰有多少票。"
L["OPT_MASTERLOOT_SAVE"] = "儲存"
L["OPT_MASTERLOOT_SAVE_DESC"] = "儲存你當前的分裝設置到你公會/社群的說明訊息。"

-- Options-Messages
L["OPT_CUSTOM_MESSAGES"] = "自訂訊息"
L["OPT_CUSTOM_MESSAGES_DEFAULT"] = "預設語言 (%s)"
L["OPT_CUSTOM_MESSAGES_DEFAULT_DESC"] = "當收訊息的人說%s或非你伺服器預設的語言時(%s)，將使用這些訊息。"
L["OPT_CUSTOM_MESSAGES_DESC"] = "你可以重新排列佔位符(|cffffff00%s|r, |cffffff00%d|r)透過在中間添加它們的位置和$符號，例如：像第二個佔位符可以用|cffffff00%2$s|r取代|cffffff00%s|r，詳情請看工具提示。"
L["OPT_CUSTOM_MESSAGES_LOCALIZED"] = "伺服器語言 (%s)"
L["OPT_CUSTOM_MESSAGES_LOCALIZED_DESC"] = "當收訊人說你伺服器的預設語言時(%s)使用這些訊息。"
L["OPT_ECHO"] = "聊天資訊"
L["OPT_ECHO_DEBUG"] = "偵錯"
L["OPT_ECHO_DESC"] = [=[你想要在聊天中顯示多少插件的資訊？

|cffffff00無:|r 聊天中無資訊。 
|cffffff00錯誤:|r 只有錯誤訊息。 
|cffffff00資訊:|r 你可能會採取行動的錯誤與有用訊息。 
|cffffff00詳細:|r 獲取有關插件所做的任何事情的通知。
|cffffff00偵錯:|r 類似於詳細，但有額外偵錯訊息。]=]
L["OPT_ECHO_ERROR"] = "錯誤"
L["OPT_ECHO_INFO"] = "資訊"
L["OPT_ECHO_NONE"] = "無"
L["OPT_ECHO_VERBOSE"] = "詳細"
L["OPT_GROUPCHAT"] = "團體聊天頻道"
L["OPT_GROUPCHAT_ANNOUNCE"] = "公告骰裝以及贏家"
L["OPT_GROUPCHAT_ANNOUNCE_DESC"] = "在隊伍/團隊/副本聊天中公告你的擲骰以及擲骰的獲得者。"
L["OPT_GROUPCHAT_CONCISE"] = "可能的話讓公告簡單扼要"
L["OPT_GROUPCHAT_CONCISE_DESC"] = [=[當首領只掉落一件物品時使用更簡要的公告(例如5人副本)。

插件會在聊天中貼上物品連結，而隊伍成員可以應答某些像是"%s"、"%s"或"+"來擲骰它們。]=]
L["OPT_GROUPCHAT_DESC"] = "更改插件是否要將骰裝公告到團體聊天中。"
L["OPT_GROUPCHAT_GROUP_TYPE"] = "公告依據團體類型"
L["OPT_GROUPCHAT_GROUP_TYPE_DESC"] = [=[只有當你是處於以下團體類型時發送到團體聊天。

|cffffff78公會團隊：|r團隊的%d%%或更多的成員是來自一個公會。
|cffffff78社群團隊：|r團隊的%d%%或更多的成員是來自一個魔獸社群。]=]
L["OPT_GROUPCHAT_ROLL"] = "在聊天中擲骰戰利品"
L["OPT_GROUPCHAT_ROLL_DESC"] = "如果其他人在團體聊天中貼出連結，請擲骰你要的戰利品(/roll)。"
L["OPT_MESSAGES"] = "訊息"
L["OPT_MSG_BID"] = "詢問戰利品: 版本 %d"
L["OPT_MSG_BID_DESC"] = "1：物品連結"
L["OPT_MSG_ROLL_ANSWER_AMBIGUOUS"] = "回答：發給我物品連結"
L["OPT_MSG_ROLL_ANSWER_AMBIGUOUS_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_BID"] = "回答：競標已登記"
L["OPT_MSG_ROLL_ANSWER_BID_DESC"] = "1：物品連結"
L["OPT_MSG_ROLL_ANSWER_NO_OTHER"] = "回答：我已經給了別人"
L["OPT_MSG_ROLL_ANSWER_NO_OTHER_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_NO_SELF"] = "回答：我自己也有需求"
L["OPT_MSG_ROLL_ANSWER_NO_SELF_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_NOT_TRADABLE"] = "回答：這件無法交易"
L["OPT_MSG_ROLL_ANSWER_NOT_TRADABLE_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_STARTED"] = "回答：我為你開始了一個擲骰"
L["OPT_MSG_ROLL_ANSWER_STARTED_DESC"] = "當作為分裝者，沒裝插件的某些人密語我們之後來開始他們的擲骰。"
L["OPT_MSG_ROLL_ANSWER_YES"] = "回答：你可以得到它"
L["OPT_MSG_ROLL_ANSWER_YES_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_YES_MASTERLOOT"] = "回答：你可以得到它(如同隊長分配)"
L["OPT_MSG_ROLL_ANSWER_YES_MASTERLOOT_DESC"] = "1：物品提供者"
L["OPT_MSG_ROLL_DISENCHANT"] = "通告分解者"
L["OPT_MSG_ROLL_DISENCHANT_DESC"] = [=[1：分解者
2：物品連結]=]
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT"] = "通告分解者(作為分裝者)"
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT_DESC"] = [=[1：分解者
2：物品連結
3：物品提供者
4：他/她]=]
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT_OWN"] = "通告物品擁有者代為分解他/她的物品（作為分裝者）"
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT_OWN_DESC"] = [=[1：物品擁有者
2：物品連結]=]
L["OPT_MSG_ROLL_DISENCHANT_WHISPER"] = "密語分解者"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_DESC"] = "1：物品連結"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT"] = "密語分解者(作為分裝者)"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_DESC"] = [=[1：物品連結
2：物品提供者
3：他/她]=]
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_OWN"] = "密語物品擁有者分解他/她的物品（作為分裝者）"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_OWN_DESC"] = "1：物品連結"
L["OPT_MSG_ROLL_START"] = "通告新的骰裝"
L["OPT_MSG_ROLL_START_CONCISE"] = "公告新的擲骰(簡要)"
L["OPT_MSG_ROLL_START_CONCISE_DESC"] = "1：物品連結"
L["OPT_MSG_ROLL_START_DESC"] = [=[1：物品連結
2：擲骰數字]=]
L["OPT_MSG_ROLL_START_MASTERLOOT"] = "通告新的骰裝 (作為分裝者)"
L["OPT_MSG_ROLL_START_MASTERLOOT_DESC"] = [=[1：物品連結
2：物品提供者
3：擲骰數字]=]
L["OPT_MSG_ROLL_WINNER"] = "通告骰裝獲勝者"
L["OPT_MSG_ROLL_WINNER_CONCISE"] = "公告擲骰獲勝者(簡要)"
L["OPT_MSG_ROLL_WINNER_CONCISE_DESC"] = "1：獲勝者"
L["OPT_MSG_ROLL_WINNER_DESC"] = [=[1：獲勝者
2：物品連結]=]
L["OPT_MSG_ROLL_WINNER_MASTERLOOT"] = "通告骰裝的獲勝者 (如同隊長分配)"
L["OPT_MSG_ROLL_WINNER_MASTERLOOT_DESC"] = [=[1：獲勝者
2：物品連結
3：物品提供者
4：他/她]=]
L["OPT_MSG_ROLL_WINNER_MASTERLOOT_OWN"] = "通告物品擁有者保留他/她的物品（作為分裝者）"
L["OPT_MSG_ROLL_WINNER_MASTERLOOT_OWN_DESC"] = [=[1：物品擁有者
2：物品連結]=]
L["OPT_MSG_ROLL_WINNER_WHISPER"] = "密語骰裝獲勝者"
L["OPT_MSG_ROLL_WINNER_WHISPER_CONCISE"] = "密語擲骰獲勝者(簡要)"
L["OPT_MSG_ROLL_WINNER_WHISPER_CONCISE_DESC"] = ""
L["OPT_MSG_ROLL_WINNER_WHISPER_DESC"] = "1：物品連結"
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT"] = "密語骰裝獲勝者 (作為分裝者)"
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT_DESC"] = [=[1：物品連結
2：物品提供者
3：他/她]=]
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT_OWN"] = "密語物品擁有者保留他/她的物品（作為分裝者）"
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT_OWN_DESC"] = "1：物品連結"
L["OPT_SHOULD_CHAT"] = "啟用/停用"
L["OPT_SHOULD_CHAT_DESC"] = "決定插件何時發佈到隊伍/團隊聊天並密語其他玩家。"
L["OPT_WHISPER"] = "聊天密語"
L["OPT_WHISPER_ANSWER"] = "回答詢問"
L["OPT_WHISPER_ANSWER_DESC"] = "讓插件自動回答來自隊伍/團隊成員的關於你拾取物品的密語。"
L["OPT_WHISPER_ASK"] = "詢問戰利品"
L["OPT_WHISPER_ASK_DESC"] = "當他人拾取你想要的戰利品時密語他們。"
L["OPT_WHISPER_ASK_VARIANTS"] = "啟用不固定的詢問"
L["OPT_WHISPER_ASK_VARIANTS_DESC"] = "當詢問戰利品時使用不同行(請看以下)，以降低重複性。"
L["OPT_WHISPER_DESC"] = "更改插件是否會密語其他玩家並且/或回應其他人的訊息。"
L["OPT_WHISPER_GROUP"] = "密語根據團體類型"
L["OPT_WHISPER_GROUP_DESC"] = "如果其他人拾取你想要的物品則密語他們，這取決於你目前所處的團體類型。"
L["OPT_WHISPER_GROUP_TYPE"] = "訊問根據團體類型"
L["OPT_WHISPER_GROUP_TYPE_DESC"] = [=[只有當你處於以下類型團體時才訊問戰利品。

|cffffff78公會團隊：|r團隊的%d%%或更多的成員是來自一個公會。
|cffffff78社群團隊：|r團隊的%d%%或更多的成員是來自一個魔獸社群。]=]
L["OPT_WHISPER_SUPPRESS"] = "阻擋詢問"
L["OPT_WHISPER_SUPPRESS_DESC"] = "當你放棄戰利品時，阻擋來自符合條件玩家的密語訊息。"
L["OPT_WHISPER_TARGET"] = "詢問目標"
L["OPT_WHISPER_TARGET_DESC"] = "是否詢問戰利品取決於目標是否在你的公會或是魔獸社群或是好友名單上。"

-- Plugins-EPGP
L["EPGP"] = "EPGP（貢獻點/裝備點）制度"
L["EPGP_CREDIT_GP"] = "將％d GP計入％s的<％s>。（裝備點）"
L["EPGP_EP"] = "EP（貢獻點）"
L["EPGP_ERROR_CREDIT_GP_FAILED"] = "將％d GP歸入<％s>的％s 失敗！"
L["EPGP_GP"] = "GP（裝備點）"
L["EPGP_OPT_AWARD_BEFORE"] = "賦予獎勵優先權"
L["EPGP_OPT_AWARD_BEFORE_DESC"] = "選擇預設獎勵方法之前，在確定拾取者時，應該結合EPGP PR值。"
L["EPGP_OPT_BID_WEIGHTS"] = "GP（裝備點）競標權重"
L["EPGP_OPT_BID_WEIGHTS_DESC"] = "擲骰中競標時分配以不同的權重。物品獲取者得到的GP乘以該值，也可以是 零 或 負數。"
L["EPGP_OPT_DESC"] = "當裝備分配模式處於活動狀態時，使用EPGP進行戰利品分發。 包括按玩家的PR值顯示和排序，以及在獲得戰利品時記入GP。"
L["EPGP_OPT_ONLY_GUILD_RAID"] = "僅限於公會裡的團隊活動"
L["EPGP_OPT_ONLY_GUILD_RAID_DESC"] = "僅在團隊活動中啟用且該隊伍中的人至少％d %%來自您的公會。"
L["EPGP_OPT_WARNING_NO_ADDON"] = "|cffff0000警告：|r您需要安裝\"EPGP Next\"插件並且啟用此模組才能運作。"
L["EPGP_OPT_WARNING_NO_OFFICER"] = "|cffff0000警告:|r 在公會中您沒有（EPGP記錄）管理員的權限，因此當您是裝備分配者時，EPGP將無法將GP點值歸入裝備戰利品。"
L["EPGP_PR"] = "拾取優先(PR)"

-- Roll
L["BID_CHAT"] = "正在詢問 %s 為了 %s -> %s。"
L["BID_MAX_WHISPERS"] = "不會問 %s 於 %s，因為你隊伍中的玩家 %d 已經詢問過 -> %s。"
L["BID_NO_CHAT"] = "無法詢問或通報%s的擲骰。"
L["BID_NO_CHAT_ADDONS"] = "因為每個人都使用戰利品插件，所以不會通告%s的擲骰。"
L["BID_NO_CHAT_ANNOUNCE"] = "不會通報%s的擲骰因為已經停用。"
L["BID_NO_CHAT_ASK"] = "密語已禁用，你需要詢問%s為了%s由你自己 -> %s。"
L["BID_NO_CHAT_CLUB"] = "密語已禁用，你需要詢問%s為了%s由你自己 -> %s。"
L["BID_NO_CHAT_DND"] = "不會詢問%s的%s，因為他/她已經啟用勿擾 -> %s。"
L["BID_NO_CHAT_FRIEND"] = "密語已禁用，你需要詢問%s為了%s由你自己 -> %s。"
L["BID_NO_CHAT_GRP"] = "不會通告%s的擲骰，因為它是在'%s'隊伍中。"
L["BID_NO_CHAT_GRP_ASK"] = "不會詢問%s的%s，因為它是在'%s'隊伍中。 -> %s"
L["BID_NO_CHAT_GUILD"] = "密語已禁用，你需要詢問%s為了%s由你自己 -> %s。"
L["BID_NO_CHAT_OTHER"] = "密語已禁用，你需要詢問%s為了%s由你自己 -> %s。"
L["BID_NO_CHAT_SELF"] = "不會詢問%s的%s，因為它是你自己 -> %s。"
L["BID_NO_CHAT_TRACKING"] = "不會詢問%s的%s，因為他/她也使用戰利品插件 -> %s。"
L["BID_PASS"] = "已放棄 %s 來自 %s。"
L["BID_START"] = "正在競標 %q 為了 %s 來自 %s。"
L["MASTERLOOTER_OTHER"] = "%s 現在負責分裝。"
L["MASTERLOOTER_REJECT"] = "%s 想要負責分裝，但是需要在 \"拾取分配\" 選項中允許成為分裝者。"
L["MASTERLOOTER_SELF"] = "你現在負責分裝。"
L["ROLL_AWARD_BIDS"] = "競標"
L["ROLL_AWARD_RANDOM"] = "隨機"
L["ROLL_AWARD_ROLLS"] = "擲骰結果"
L["ROLL_AWARD_VOTES"] = "表決結果"
L["ROLL_AWARDED"] = "已給予"
L["ROLL_AWARDING"] = "給予中"
L["ROLL_CANCEL"] = "已取消擲骰由 %2$s 提供的 %1$s。"
L["ROLL_END"] = "由 %2$s 提供的 %1$s 擲骰結束。"
L["ROLL_IGNORING_BID"] = "已忽略 %s 對 %s 的競標，因為之前已經聊過了 -> 競標：%s 或 %s。"
L["ROLL_LIST_EMPTY"] = "啟用的擲骰會顯示在此"
L["ROLL_START"] = "開始骰由 %2$s 提供的 %1$s。"
L["ROLL_STATUS_0"] = "處理中"
L["ROLL_STATUS_1"] = "執行中"
L["ROLL_STATUS_-1"] = "已取消"
L["ROLL_STATUS_2"] = "完成"
L["ROLL_TRADED"] = "已交易"
L["ROLL_WHISPER_SUPPRESSED"] = "%s 對 %s競標 -> %s / %s。"
L["ROLL_WINNER_MASTERLOOT"] = "%1$s 已經贏得由 %3$s 提供的 %2$s。"
L["ROLL_WINNER_OTHER"] = "%s 贏得你提供的 %s -> %s。"
L["ROLL_WINNER_OWN"] = "你贏得自己的 %s。"
L["ROLL_WINNER_SELF"] = "你贏得由 %2$s 提供的 %1$s -> %s。"
L["TRADE_CANCEL"] = "與 %s 取消交易。"
L["TRADE_START"] = "與 %s 開始交易。"

-- Globals
_G["LOOT_ROLL_INELIGIBLE_REASONPLR_NO_ADDON"] = "物品的提供者並沒有使用PersoLootRoll插件。"
_G["LOOT_ROLL_INELIGIBLE_REASONPLR_NO_DISENCHANT"] = "物品的提供者不允許\"分解\"的競標。"
_G["LOOT_ROLL_INELIGIBLE_REASONPLR_NOT_ENCHANTER"] = "您的角色並未學習\"附魔\"專業技能。"


-- Other
L["ID"] = ID
L["ITEMS"] = ITEMS
L["LEVEL"] = LEVEL
L["STATUS"] = STATUS
L["TARGET"] = TARGET
L["ROLL_BID_1"] = NEED
L["ROLL_BID_2"] = GREED
L["ROLL_BID_3"] = ROLL_DISENCHANT
L["ROLL_BID_4"] = PASS
L[""] = ""

-- 自行加入
L["PersoLootRoll"] = "裝備-分享"
L["PersoLootRoll "] = "個人拾取分享助手"
L["Profiles"] = "設定檔"