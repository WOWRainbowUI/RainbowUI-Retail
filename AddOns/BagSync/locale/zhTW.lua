local L = LibStub("AceLocale-3.0"):NewLocale("BagSync", "zhTW")
if not L then return end

--  zhTW client (三皈依-暗影之月@TW補齊)
--  Last update: 2022/05/28

L.Yes = "是"
L.No = "否"
L.Page = "頁"
L.Done = "完成"
L.Realm = "伺服器:"
L.TooltipCR_Tag = "CR"
L.TooltipBNET_Tag = "BN"
L.Tooltip_bag = "背包"
L.Tooltip_bank = "銀行"
L.Tooltip_equip = "已裝備"
L.Tooltip_guild = "公會"
L.Tooltip_mailbox = "信箱"
L.Tooltip_void = "虛空倉庫"
L.Tooltip_reagents = "材料銀行"
L.Tooltip_auction = "拍賣"
L.TooltipSmall_bag = "包"
L.TooltipSmall_bank = "銀"
L.TooltipSmall_reagents = "材"
L.TooltipSmall_equip = "裝"
L.TooltipSmall_guild = "公"
L.TooltipSmall_mailbox = "郵"
L.TooltipSmall_void = "虛"
L.TooltipSmall_auction = "拍"
L.TooltipTotal = "總計:"
L.TooltipGuildTabs = "T:"
L.TooltipItemID = "[物品ID]:"
L.TooltipDebug = "[Debug]:"
L.TooltipCurrencyID = "[貨幣ID]:"
L.TooltipFakeID = "[虛擬ID]:"
L.TooltipExpansion = "[資料片]:"
L.TooltipItemType = "[物品類型]:"
L.TooltipDelimiter = ", "
L.TooltipRealmKey = "伺服器:"
L.TooltipDetailsInfo = "物品詳細摘要。"
L.DetailsBagID = "ID:"
L.DetailsSlot = "欄位:"
L.DetailsTab = "標籤頁面:"
L.Debug_DEBUG = "DEBUG"
L.Debug_INFO = "INFO"
L.Debug_TRACE = "TRACE"
L.Debug_WARN = "WARN"
L.Debug_FINE = "FINE"
L.DebugEnable = "啟用除錯"
L.DebugCache = "停用快取"
L.DebugDumpOptions = "傾印選項 |cff3587ff[DEBUG]|r"
L.DebugIterateUnits = "重複單元 |cff3587ff[DEBUG]|r"
L.DebugDBTotals = "資料庫總計 |cff3587ff[DEBUG]|r"
L.DebugAddonList = "插件列表 |cff3587ff[DEBUG]|r"
L.DebugExport = "匯出"
L.DebugWarning = "|cFFDF2B2B警告:|R BagSync 除錯模式已啟用! |cFFDF2B2B(將會造成卡頓)|r"
L.Search = "搜尋"
L.Debug = "除錯"
L.AdvSearchBtn = "搜尋/重新整理"
L.Reset = "重置"
L.Refresh = "重新整理"
L.Clear = "清空"
L.AdvancedSearch = "進階搜尋"
L.AdvancedSearchInformation = "* 使用 BagSync |cffff7d0a[CR]|r 和 |cff3587ff[BNet]|r 設定"
L.AdvancedLocationInformation = "* 選擇所有因為無預設"
L.Units = "名字:"
L.Locations = "位置:"
L.Profiles = "角色"
L.SortOrder = "排列順序"
L.Professions = "專業"
L.Currency = "貨幣"
L.Blacklist = "黑名單"
L.Whitelist = "白名單"
L.Recipes = "配方"
L.Details = "詳細"
L.Gold = "金幣"
L.Close = "關閉"
L.FixDB = "優化資料庫"
L.Config = "設定"
L.DeleteWarning = "選擇要刪除的設定檔。注意: 刪除後將無法還原!"
L.Delete = "刪除"
L.Confirm = "確認"
L.SelectAll = "全選"
L.FixDBComplete = "已執行FixDB, 資料庫已優化!"
L.ResetDBInfo = "BagSync:\n是否確定要重置資料庫?\n|cFFDF2B2B注意: 這是無法還原的!|r"
L.ON = "開[ON]"
L.OFF = "關[OFF]"
L.LeftClickSearch = "|cffddff00左鍵:|r|cff00ff00 搜尋視窗|r"
L.RightClickBagSyncMenu = "|cffddff00右鍵:|r|cff00ff00 選單|r"
L.ProfessionInformation = "|cffddff00左鍵:|r|cff00ff00查看專業配方|r"
L.ClickViewProfession = "點一下查看專業"
L.ClickHere = "點這裡"
L.ErrorUserNotFound = "BagSync: 錯誤, 未找到用戶!"
L.EnterItemID = "輸入物品ID (用 wowhead.com 查詢)"
L.AddGuild = "新增公會"
L.AddItemID = "新增物品 ID"
L.RemoveItemID = "移除物品 ID"
L.PleaseRescan = "|cFF778899[請重新掃描|r"
L.UseFakeID = "戰寵使用 [虛擬ID] 而不是 [物品ID]"
L.ItemIDNotFound = "[%s] 未找到物品 ID。再試一次!"
L.ItemIDNotValid = "[%s] 物品 ID 無效或查詢伺服器未回應。請再試一次!"
L.ItemIDRemoved = "[%s] 物品 ID 已移除"
L.ItemIDAdded = "[%s] 已新增物品 ID"
L.ItemIDExistBlacklist = "[%s] 物品 ID 已在黑名單資料庫中"
L.ItemIDExistWhitelist = "[%s] 物品 ID 已在白名單資料庫中"
L.GuildExist = "公會 [%s] 已在黑名單資料庫中"
L.GuildAdded = "公會 [%s] 已新增"
L.GuildRemoved = "公會 [%s] 已移除"
L.BlackListRemove = "從黑名單中移除 [%s] ?"
L.WhiteListRemove = "從白名單中移除 [%s] ?"
L.BlackListErrorRemove = "移除黑名單時出錯"
L.WhiteListErrorRemove = "移除白名單時出錯"
L.ProfilesRemove = "刪除 [%s][|cFF99CC33%s|r] 的 BagSync 角色資料?"
L.ProfilesErrorRemove = "BagSync 刪除時出錯"
L.ProfileBeenRemoved = "[%s][|cFF99CC33%s|r] 的 BagSync 角色資料已刪除!"
L.ProfessionsFailedRequest = "[%s] 伺服器請求失敗"
L.ProfessionHasRecipes = "左鍵點擊查看專業"
L.ProfessionHasNoRecipes = "沒有配方可供查看"
L.KeybindBlacklist = "顯示黑名單視窗"
L.KeybindWhitelist = "顯示白名單視窗"
L.KeybindCurrency = "顯示貨幣視窗"
L.KeybindGold = "顯示金幣視窗"
L.KeybindProfessions = "顯示職業視窗"
L.KeybindProfiles = "顯示設定檔"
L.KeybindSearch = "顯示搜尋視窗"
L.ObsoleteWarning = "\n\n注意: 過時的物品將繼續顯示為缺少。要修復此問題，請再次掃描您的角色以刪除過時的物品。\n(背包、銀行、虛空銀行等 ...)"
L.DatabaseReset = "由於資料庫的變化。您的BagSync資料庫已重置"
L.UnitDBAuctionReset = "所有角色的拍賣資料已重置。"
L.ScanGuildBankStart = "公會銀行內訊息正在查詢伺服器，請稍候....."
L.ScanGuildBankDone = "公會銀行掃描完成!"
L.ScanGuildBankError = "警告: 公會銀行掃描不完整"
L.ScanGuildBankScanInfo = "掃描公會標籤頁面 (%s/%s)"
L.DefaultColors = "預設顏色"
-- ----THESE ARE FOR SLASH COMMANDS OPERATORS
L.SlashItemName = "[物品名稱]"
L.SlashSearch = "search"
L.SlashGold = "gold"
L.SlashMoney = "money"
L.SlashConfig = "config"
L.SlashCurrency = "currency"
L.SlashFixDB = "fixdb"
L.SlashProfiles = "profiles"
L.SlashProfessions = "professions"
L.SlashBlacklist = "blacklist"
L.SlashWhitelist = "whitelist"
L.SlashResetDB = "resetdb"
L.SlashDebug = "debug"
L.SlashResetPOS = "resetpos"
L.SlashSortOrder = "sortorder"
------------------------
-- ----THESE USE THE SLASH OPERATOR COMMANDS FOUND ABOVE
L.HelpSearchItemName = "快速搜尋一件物品"
L.HelpSearchWindow = "開啟搜尋視窗"
L.HelpGoldTooltip = "顯示各角色的金錢統計"
L.HelpCurrencyWindow = "打開貨幣視窗"
L.HelpProfilesWindow = "打開訊息視窗"
L.HelpFixDB = "讓 BagSync 進行資料庫修復"
L.HelpResetDB = "重置整個 BagSync 資料庫"
L.HelpConfigWindow = "打開設定視窗"
L.HelpProfessionsWindow = "打開專業視窗"
L.HelpBlacklistWindow = "打開黑名單視窗"
L.HelpWhitelistWindow = "打開白名單視窗"
L.HelpDebug = "打開 BagSync 除錯視窗"
L.HelpResetPOS = "重置 BagSync 每一個模組的所有視窗位置"
L.HelpSortOrder = "角色和公會自訂排列順序"
------------------------
L.EnableBagSyncTooltip = "啟用 BagSync 浮動提示資訊"
L.ShowOnModifier = "按住才顯示:"
L.ShowOnModifierDesc = "按下輔助鍵時顯示 BagSync 浮動提示資訊"
L.ModValue_NONE = "無 (總是顯示)"
L.EnableExtTooltip = "在獨立視窗中顯示物品統計數據"
L.EnableLoginVersionInfo = "顯示 BagSync 的登入訊息"
L.FocusSearchEditBox = "打開搜尋視窗時直接使用搜尋輸入框"
L.AlwaysShowAdvSearch = "總是顯示 Bagsync 進階搜尋視窗"
L.DisplayTotal = "顯示 [總計] 金額"
L.DisplayGuildGoldInGoldWindow = "顯示 [公會] 金幣總數"
L.Display_GSC = "顯示|cFFFFD700金|r、|cFFC0C0C0銀|r和|cFFB87333銅|r"
L.DisplayGuildBank = "包括公會銀行物品 |cFF99CC33(需要掃描公會銀行)|r"
L.DisplayMailbox = "包括信箱內物品"
L.DisplayAuctionHouse = "包括拍賣行物品"
L.DisplayMinimap = "顯示小地圖按鈕"
L.DisplayFaction = "同時顯示雙方陣營的物品 (|cff3587ff聯盟|r/|cFFDF2B2B部落|r)"
L.DisplayClassColor = "職業顏色"
L.DisplayItemTotalsByClassColor = "物品總計顯示職業顏色"
L.DisplayTooltipOnlySearch = "僅在 BagSync 搜尋視窗內顯示修改過的浮動提示資訊"
L.DisplayLineSeparator = "顯示空行分隔線"
L.DisplayCR = "顯示跨伺服器 / |cffff7d0a[連結伺服器]|r 角色 |cffff7d0a[CR]|r"
L.DisplayBNET = "顯示所有戰網帳號角色 |cff3587ff[BNet]|r |cFFDF2B2B(不推薦)|r"
L.DisplayItemID = "顯示 [物品ID] "
L.DisplaySourceDebugInfo = "顯示有用的 [除錯] 訊息"
L.DisplayWhiteListOnly = "只有白名單的物品顯示總數"
L.DisplaySourceExpansion = "顯示資料片 |cFF99CC33[正式版專用]|r"
L.DisplayItemTypes = "顯示 [物品類型 | 子類型] 類別"
L.DisplayTooltipTags = "標籤"
L.DisplayTooltipStorage = "倉庫"
L.DisplayTooltipExtra = "其他統計"
L.DisplaySortOrderHelp = "排列順序說明"
L.DisplaySortOrderStatus = "目前的排列順序是: [%s]"
L.DisplayWhitelistHelp = "白名單說明"
L.DisplayWhitelistStatus = "目前的白名單是: [%s]"
L.DisplayWhitelistHelpInfo = "只能輸入物品 ID 數字到白名單資料庫。\n\n戰寵請輸入虛擬 ID 不是物品 ID，在 BagSync 設定選項中啟用顯示物品 ID 後可以看到虛擬 ID。\n\n|cFFDF2B2B不適用於貨幣視窗|r"
L.DisplayTooltipAccountWide = "帳號共用"
L.DisplayAccountWideTagOpts = "|cFF99CC33標籤選項 ( |cffff7d0a[CR]|r & |cff3587ff[BNet]|r )|r"
L.DisplayGreenCheck = "在當前角色名字旁顯示 %s "
L.DisplayRealmIDTags = "顯示 |cffff7d0a[CR]|r 和 |cff3587ff[BNet]|r 標籤"
L.DisplayRealmNames = "顯示伺服器名字"
L.DisplayRealmAstrick = "顯示 [*] 而不是顯示 |cffff7d0a[CR]|r 和 |cff3587ff[BNet]|r"
L.DisplayShortRealmName = "|cffff7d0a[CR]|r 和 |cff3587ff[BNet]|r 顯示簡短的伺服器名稱"
L.DisplayFactionIcons = "顯示陣營圖示"
L.DisplayGuildBankTabs = "顯示公會銀行頁數 [1,2,3...]"
L.DisplayRaceIcons = "顯示種族圖示"
L.DisplaySingleCharLocs = "用單一字元顯示存放位置"
L.DisplayIconLocs = "用圖示顯示存放位置"
L.DisplayGuildSeparately = "分開顯示 [公會] 物品總計"
L.DisplayGuildCurrentCharacter = "僅顯示當前角色的 [公會] 物品"
L.DisplayGuildBankScanAlert = "顯示公會銀行掃描視窗"
L.DisplayAccurateBattlePets = "啟用公會銀行&信箱中準確的戰寵 |cFFDF2B2B(可能會造成遊戲卡頓)|r |cff3587ff[請看 BagSync FAQ]|r"
L.DisplaySorting = "浮動提示資訊排序"
L.DisplaySortInfo = "預設: 浮動提示資訊會先依照伺服器再依照角色名字來排序"
L.SortTooltipByTotals = "使用總數量來排序 BagSync 的浮動提示資訊，而不是依照字母排序"
L.SortByCustomSortOrder = "依照自訂的順序來排序"
L.CustomSortInfo = "清單使用升冪 (1,2,3)"
L.CustomSortInfoWarn = "|cFF99CC33注意: 只用使用數字! (-1,0,3,4)|r"
L.DisplayShowUniqueItemsTotals = "啟用該選項將允許物品總數量增加獨特的物品，無論物品的統計訊息。|cFF99CC33(推薦)|r"
L.DisplayShowUniqueItemsTotals_2 = [[
某些物品例如 |cffff7d0a[Legendaries]|r 可以共享相同的名字但具有不同的統計數據。由於這些物品是彼此獨立處理，因此有時不計入總物品數。啟用此選項將完全忽略獨特的物品統計數據並一視同仁，只要它們共享相同的物品名稱。
停用此選項將獨立顯示物品計數，因此將考慮物品統計訊息。物品總數將只顯示每個游戲角色共享相同的唯一物品和完全相同的統計數據。|cFFDF2B2B(不推薦)|r
]]
L.DisplayShowUniqueItemsTotalsTitle = "在浮動提示資訊上顯示唯一物品的總數"
L.DisplayShowUniqueItemsEnableText = "啟用唯一物品的總數"
L.ColorPrimary = "主要 BagSync 提示顏色"
L.ColorSecondary = "輔助 BagSync 提示顏色"
L.ColorTotal = "BagSync [總計] 提示顏色"
L.ColorGuild = "BagSync [公會] 提示顏色"
L.ColorCR = "BagSync [連結伺服器] 提示顏色"
L.ColorBNET = "BagSync [戰網] 提示顏色"
L.ColorItemID = "BagSync [物品ID] 提示顏色"
L.ColorExpansion = "BagSync [資料片] 提示顏色"
L.ColorItemTypes = "BagSync [物品類型] 提示顏色"
L.ColorGuildTabs = "公會頁數 [1,2,3...] 提示顏色"
L.ConfigHeader = "各種 BagSync 功能的設置"
L.ConfigDisplay = "顯示"
L.ConfigTooltipHeader = "BagSync 浮動提示資訊的顯示設定"
L.ConfigColor = "顏色"
L.ConfigColorHeader = "BagSync 浮動提示資訊的顏色設定"
L.ConfigMain = "主要"
L.ConfigMainHeader = "BagSync 的主要設定"
L.ConfigSearch = "搜尋"
L.ConfigKeybindings = "按鍵綁定"
L.ConfigKeybindingsHeader = "BagSync 功能的按鍵綁定"
L.ConfigExternalTooltip = "外部浮動提示資訊"
L.ConfigSearchHeader = "搜尋視窗的設定"
L.ConfigFont = "字體"
L.ConfigFontSize = "文字大小"
L.ConfigFontOutline = "外框"
L.ConfigFontOutline_NONE = "無"
L.ConfigFontOutline_OUTLINE = "外框"
L.ConfigFontOutline_THICKOUTLINE = "粗外框"
L.ConfigFontMonochrome = "單色"
L.ConfigTracking = "追蹤"
L.ConfigTrackingHeader = "所有儲存 BagSync 資料庫位置的追蹤設定"
L.ConfigTrackingCaution = "警告"
L.ConfigTrackingModules = "模組"
L.ConfigTrackingInfo = [[
|cFFDF2B2B注意|r: 停用模組會使 BagSync 停止追蹤和儲存模組到資料庫中。

被停用的模組不會在 BagSync 的任何視窗、聊天指令和浮動提示資訊中顯示。
]]
L.TrackingModule_Bag = "背包"
L.TrackingModule_Bank = "銀行"
L.TrackingModule_Reagents = "材料銀行"
L.TrackingModule_Equip = "已裝備的物品"
L.TrackingModule_Mailbox = "郵箱"
L.TrackingModule_Void = "虛空銀行"
L.TrackingModule_Auction = "拍賣場"
L.TrackingModule_Guild = "公會銀行"
L.TrackingModule_Professions = "專業 / 交易技能"
L.TrackingModule_Currency = "通貨代幣"
L.WarningItemSearch = "警告: 共有 [|cFFFFFFFF%s|r] 個物品未被搜尋!\n\nBagSync 仍在等待伺服器/資料庫回應\n\n按 “搜尋” 或 “重新整理” 按鈕"
L.WarningUpdatedDB = "您已更新到最新的版本! 您將需要再次重新掃描所有角色!|r "
L.WarningHeader = "警告!"
L.SavedSearch = "儲存的搜尋"
L.SavedSearch_Add = "新增搜尋"
L.SavedSearch_Warn = "請在搜尋框中輸入一些東西"
---------------------------------------
--Localization Note:  Please be advised that the commands for the SearchHelp are english only, however the variables can be any language.  Example: class:<name of class in your locale>
--This includes name searches like name:<name in your locale>
---------------------------------------
L.SearchHelpHeader = "搜尋說明"
L.SearchHelp = [[
|cffff7d0a搜尋選項|r:
|cFFDF2B2B(注意: 所有指令只限英文！)|r

|cFF99CC33角色物品的位置|r:
@bag
@bank
@reagents
@equip
@mailbox
@void
@auction
@guild

|cffff7d0a進階搜尋|r (|cFF99CC33指令|r | |cFFFFD580範例|r):

|cff00ffff<item name>|r = |cFF99CC33n|r ; |cFF99CC33name|r | |cFFFFD580n:<text>|r ; |cFFFFD580name:<text>|r (n:ore ; name:ore)

|cff00ffff<item bind>|r = |cFF99CC33bind|r | |cFFFFD580bind:<type>|r ; types (boe, bop, bou, boq) i.e boe = bind on equip

|cff00ffff<quality>|r = |cFF99CC33q|r ; |cFF99CC33quality|r | |cFFFFD580q<op><text>|r ; |cFFFFD580q<op><digit>|r (q:rare ; q:>2 ; q:>=3)

|cff00ffff<ilvl>|r = |cFF99CC33l|r ; |cFF99CC33level|r ; |cFF99CC33lvl|r ; |cFF99CC33ilvl|r | |cFFFFD580ilvl<op><number>|r ; |cFFFFD580lvl<op><number>|r (lvl:>5 ; lvl:>=20)

|cff00ffff<required ilvl>|r = |cFF99CC33r|r ; |cFF99CC33req|r ; |cFF99CC33rl|r ; |cFF99CC33reql|r ; |cFF99CC33reqlvl|r | |cFFFFD580req<op><number>|r ; |cFFFFD580req<op><number>|r (req:>5 ; req:>=20)

|cff00ffff<type / slot>|r = |cFF99CC33t|r ; |cFF99CC33type|r ; |cFF99CC33slot|r | |cFFFFD580t:<text>|r (slot:head) ; (t:battlepet or t:petcage) (t:armor) (t:weapon)

|cff00ffff<tooltip>|r = |cFF99CC33tt|r ; |cFF99CC33tip|r ; |cFF99CC33tooltip|r | |cFFFFD580tt:<text>|r (tt:summon)

|cff00ffff<item set>|r = |cFF99CC33s|r ; |cFF99CC33set|r | |cFFFFD580s:<setname>|r (setname can be * for all sets)

|cff00ffff<expansion>|r = |cFF99CC33x|r ; |cFF99CC33xpac|r ; |cFF99CC33expansion|r | |cFFFFD580x:<expacID>|r ; |cFFFFD580x:<expansion name>|r ; |cFFFFD580xpac:<expansion name>|r (xpac:shadow)

|cff00ffff<keyword>|r = |cFF99CC33k|r ; |cFF99CC33key|r ; |cFF99CC33keyword|r | |cFFFFD580k:<keyword>|r (key:quest) (keywords: soulbound, bound, boe, bop, bou, boa, quest, unique, toy, reagent, crafting, naval, follower, follow, power, apperance)

|cff00ffff<class>|r = |cFF99CC33c|r ; |cFF99CC33class|r | |cFFFFD580c:<classname>|r ; |cFFFFD580class:<classname>|r (class:shaman)

|cffff7d0a運算符號 <op>|r:
|cFF99CC33:|r | |cFF99CC33=|r | |cFF99CC33==|r | |cFF99CC33!=|r | |cFF99CC33~=|r | |cFF99CC33<|r | |cFF99CC33>|r | |cFF99CC33<=|r | |cFF99CC33>=|r


|cffff7d0a反向指令|r:
範例: |cFF99CC33!|r|cFFFFD580bind:boe|r (不是boe)
範例: |cFF99CC33!|r|cFFFFD580bind:boe|r |cFF99CC33&&|r |cFFFFD580lvl:>20|r (不是boe以及物品等級大於20)

|cffff7d0a聯合搜尋 (以及搜尋):|r
(使用以及 |cFF99CC33&&|r 標點符號)
範例: |cFFFFD580bind:boe|r |cFF99CC33&&|r |cFFFFD580lvl:>20|r

|cffff7d0a交互搜尋 (或搜尋):|r
(使用分隔 |cFF99CC33|||||r 標點符號)
範例: |cFFFFD580bind:boe|r |cFF99CC33|||||r |cFFFFD580lvl:>20|r

|cffff7d0a複雜搜尋範例:|r
(boe裝備綁定，裝等正好20且名稱中帶有'robe')
|cFFFFD580bind:boe|r |cFF99CC33&&|r |cFFFFD580lvl:20|r |cFF99CC33&&|r |cFFFFD580name:robe|r

]]
L.ConfigFAQ= " FAQ / 說明 "
L.ConfigFAQHeader = "BagSync 的常見問題和幫助介紹"
L.FAQ_Question_1 = "我遇到浮動提示資訊上/卡頓/滯後"
L.FAQ_Question_1_p1 = [[
當資料庫中有舊的和損壞的數據 BagSync 無法解讀時,通常會發生此問題。當 BagSync 需要處理大量的數據時,也會出現該問題,如果您在多個數據中數千個物品,那麼在一秒鐘內需要處理大量數據.這可能會導致您的計算機在短時間內滯後。最後,此問題的另一個原因是您擁有一台非常舊的計算機。當 BagSync 處理數以千計的物品和角色數據時,較舊的計算機會遇到滯後/卡頓的情況。具有更快的CPU和更大的內存的計算機通常不會出現這些問題。
為了解決這個問題,您可以嘗試重置資料庫。通常可以解決問題。使用以下命令： |cFF99CC33/bgs 重置|r
如果這不能解決您的問題,請在 GitHub 上的 BagSync 提交問題報告。
]]
L.FAQ_Question_2 = " 在|cFFDF2B2B單獨|r |cff3587ff戰網|r 帳號中。找不到我的其他魔獸世界帳號的物品數據"
L.FAQ_Question_2_p1 = [[
插件無法從其他魔獸世界帳戶讀取數據。這是因為它們不共享相同的 SavedVariable 文件夾。這是暴雪魔獸世界客戶端的內置限制。因此,您將無法在 |cFFDF2B2Bsingle|r |cff3587ffBattle.net|r 下看到多個魔獸世界帳戶的物品數據。 BagSync 將只能讀取同一魔獸世界帳戶內同伺服器內多個的角色數據,而不是整個戰網帳戶。|cFF99CC33https://www.wowhead.com/guide=934|r
有一種方法可以在 |cFFDF2B2Bsingle|r |cff3587ffBattle.net|r 帳戶內連接多個魔獸世界帳戶,以便它們共享相同的 SavedVariables 文件夾。 這涉及創建伺服器鏈接文件夾。我不會在這方面提供幫助。所以別問了！請訪問以下指南了解更多詳情。 
]]
L.FAQ_Question_3 = "您可以查看來自 |cFFDF2B2B多個|r |cff3587ff戰網|r 賬號內的物品數據嗎?"
L.FAQ_Question_3_p1 = "不,這不可能。我不會在這方面提供幫助。所以不要問!"
L.FAQ_Question_4 = "我可以在|cFFDF2B2B當前登錄|r的帳號查看多個魔獸世界賬戶的物品數據嗎?"
L.FAQ_Question_4_p1 = "目前 BagSync 不支持在多個登錄的魔獸世界帳戶之間傳輸數據。這在未來可能會改變。"
L.FAQ_Question_5 = "為什麼會提示公會銀行掃描未完成?"
L.FAQ_Question_5_p1 = [[
BagSync 必須向伺服器查詢您的公會銀行的 |cFF99CC33全部|r 訊息。伺服器傳輸所有數據需要時間。為了讓 BagSync 正確存儲您的所有物品,您必須等到伺服器查詢完成。掃描過程完成後,BagSync 將在聊天欄通知您。在掃描過程完成之前關閉公會銀行視窗,將導致為您的公會銀行存儲不完整的數據。 
]]
L.FAQ_Question_6 = "為什麼我看到戰鬥寵物是虛擬ID[FakeID]而不是物品ID[ItemID]?"
L.FAQ_Question_6_p1 = [[
暴雪不會將物品ID[ItemID]分配給魔獸世界的戰鬥寵物。相反,魔獸世界中的戰鬥寵物會從伺服器分配到一個臨時的寵物ID[PetID]。這個寵物ID[PetID]不是唯一的,會在伺服器重置時更改。為了跟蹤戰鬥寵物,BagSync 會生成一個虛擬ID[FakeID]。 虛擬ID[FakeID]是根據與戰鬥寵物相關聯的靜態數字生成的。使用虛擬ID[FakeID]可以保證BagSync在伺服器重置期間跟蹤到戰鬥寵物。
]]
L.FAQ_Question_7 = "公會銀行和郵箱中準確的戰鬥寵物掃描是什麼？"
L.FAQ_Question_7_p1 = [[
暴雪不會將戰鬥寵物存儲在公會銀行或郵箱中，並帶有適當的物品ID或種類ID。事實上，戰鬥寵物以|cFF99CC33[寵物籠]|r的形式存儲在公會銀行和郵箱中，物品ID為|cFF99CC3382800|r。這使得有關插件作者難以進行特定戰鬥寵物的抓取任何數據。您可以在公會銀行交易日誌中看到，您會注意到戰鬥寵物被存儲為|cFF99CC33[寵物籠]|r。如果您從公會銀行鏈接一個，它也將顯示為|cFF99CC33[寵物籠]|r。為了解決這個問題，可以使用兩種方法。第一種方法是將戰鬥寵物分配給工具提示，然後從那裡找到。這要求伺服器響應WOW客戶端，並可能導致大量延遲，尤其是在公會銀行中有很多戰鬥寵物的情況下。第二種方法使用戰鬥寵物的圖示試圖找到。有時由於某些戰鬥寵物共享相同的圖示，這有時是不準確的。示例：毒毒與翡翠軟泥怪具有相同的圖示。啟用此選項將迫使工具提示掃描方法盡可能準確，但可能會導致延遲。|cFF99CC33直暴雪為我們提供更多數據來使用。|r
]]

-- 自行加入
L.BagSync = "物品數量"
L.BAGSYNC = "物品數量統計"