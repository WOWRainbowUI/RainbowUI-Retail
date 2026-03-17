local AddOnName, _ = ...

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
---@class XIV_DatabarLocale : table<string, boolean|string>
local L ---@type XIV_DatabarLocale
L = AceLocale:NewLocale(AddOnName, "zhTW", false, false)
if not L then return end

-- NOTE: Strings needing translation are marked with `-- TODO: To Translate`.
-- Some strings are sourced from BlizzardInterfaceResources:
-- https://github.com/Ketho/BlizzardInterfaceResources/blob/live/Resources/GlobalStrings/deDE.lua

L["MODULES"] = "功能模組"
L["LEFT_CLICK"] = "左鍵"
L["RIGHT_CLICK"] = "右鍵"
L["k"] = "千" -- short for 1000
L["M"] = "百萬" -- short for 1000000
L["B"] = "十億" -- short for 1000000000
L["L"] = "本地" -- For the local ping
L["W"] = "世界" -- For the world ping
L["w"] = "萬"	-- short for 10000, used in zhCN and zhTW
L["e"] = "億" -- short for 100000000
L["c"] = "兆" -- short for 1000000000000

-- General
L["POSITIONING"] = "位置"
L["BAR_POSITION"] = "資訊列位置"
L["TOP"] = "上"
L["BOTTOM"] = "下"
L["BAR_COLOR"] = "資訊列顏色"
L["USE_CLASS_COLOR"] = "使用職業顏色"
L["MISCELLANEOUS"] = "其他"
L["HIDE_IN_COMBAT"] = "戰鬥中隱藏"
L["HIDE_IN_FLIGHT"] = "飛行時隱藏"
L["BAR_PADDING"] = "資訊列內距"
L["MODULE_SPACING"] = "模組間距"
L["BAR_MARGIN"] = "資訊列間距"
L["BAR_MARGIN_DESC"] = "資訊列模組最左邊和最右邊的間距"
L["HIDE_ORDER_HALL_BAR"] = "隱藏職業大廳列"
L["USE_ELVUI_FOR_TOOLTIPS"] = "使用ElvUI浮動提示"
L["LOCK_BAR"] = "鎖定狀態列"
L["LOCK_BAR_DESC"] = "鎖定狀態列以防止拖曳"
L["BAR_FULLSCREEN_DESC"] = "讓狀態列橫跨整個螢幕寬度"
L["BAR_POSITION_DESC"] = "將狀態列定位在螢幕頂端或底端"
L["X_OFFSET"] = "水平偏移"
L["Y_OFFSET"] = "垂直偏移"
L["HORIZONTAL_POSITION"] = "狀態列的水平位置"
L["VERTICAL_POSITION"] = "狀態列的垂直位置"
L["BEHAVIOR"] = "行為"
L["SPACING"] = "間距"

-- Modules Positioning
L["MODULES_POSITIONING"] = "模組定位"
L["ENABLE_FREE_PLACEMENT"] = "啟用自由放置"
L["ENABLE_FREE_PLACEMENT_DESC"] = "為每個模組啟用獨立的 X 軸定位，並停用模組間的對齊點"
L["RESET_ALL_POSITIONS"] = "重設所有位置"
L["RESET_ALL_POSITIONS_DESC"] = "將所有模組重設到初始的自由放置位置"
L["ANCHOR_POINT"] = "對齊點"
L["X_POSITION"] = "水平位置"
L["RESET_POSITION"] = "重設位置"
L["RESET_POSITION_DESC"] = "重設到對齊位置"
L["RECAPTURE_INITIAL_POSITIONS"] = "重新捕捉初始位置"
L["RECAPTURE_INITIAL_POSITIONS_DESC"] = "將目前的對齊位置記錄為新的初始自由放置位置"

-- Positioning Options
L["BAR_WIDTH"] = "資訊列寬度"
L["LEFT"] = "左"
L["CENTER"] = "中"
L["RIGHT"] = "右"

-- Media
L["FONT"] = "字體"
L["SMALL_FONT_SIZE"] = "小字體大小"
L["TEXT_STYLE"] = "文字樣式"

-- Text Colors
L["COLORS"] = "顏色"
L["TEXT_COLORS"] = "文字顏色"
L["NORMAL"] = "平時"
L["INACTIVE"] = "未使用時"
L["USE_CLASS_COLOR_TEXT"] = "使用職業顏色"
L["USE_CLASS_COLOR_TEXT_DESC"] = "顏色選擇器中只能設定透明度"
L["USE_CLASS_COLORS_FOR_HOVER"] = "使用職業顏色"
L["HOVER"] = "滑鼠指向時"

-------------------- MODULES ---------------------------

L["Social"] = "好友"
L["MICROMENU"] = "微型選單"
L["SHOW_SOCIAL_TOOLTIPS"] = "顯示公會/好友名單"
L["SHOW_ACCESSIBILITY_TOOLTIPS"] = "顯示無障礙提示"
L["BLIZZARD_MICROMENU"] = "內建微型選單"
L["DISABLE_BLIZZARD_MICROMENU"] = "停用內建微型選單"
L["KEEP_QUEUE_STATUS_ICON"] = "保留隊列狀態圖示"
L["BLIZZARD_MICROMENU_DISCLAIMER"] = "此選項已停用，因為偵測到外部的狀態列管理器：%s。"
L["BLIZZARD_BAGS_BAR"] = "內建背包列"
L["DISABLE_BLIZZARD_BAGS_BAR"] = "停用內建背包列"
L["BLIZZARD_BAGS_BAR_DISCLAIMER"] = "此選項已停用，因為偵測到外部的狀態列管理器：%s。"
L["MAIN_MENU_ICON_RIGHT_SPACING"] = "主選單圖示右方間距"
L["ICON_SPACING"] = "圖示間距"
L["HIDE_BNET_APP_FRIENDS"] = "隱藏戰網 app 好友"
L["OPEN_GUILD_PAGE"] = "開啟公會視窗"
L["NO_TAG"] = "沒有 Tag"
L["WHISPER_BNET"] = "密語 Battle Tag"
L["WHISPER_CHARACTER"] = "密語伺服器角色"
L["HIDE_SOCIAL_TEXT"] = "隱藏人數"
L["SOCIAL_TEXT_OFFSET"] = "人數文字位置偏移"
L["GMOTD_IN_TOOLTIP"] = "顯示公會今日資訊"
L["FRIEND_INVITE_MODIFIER"] = "組隊邀請的組合鍵"
L["SHOW_HIDE_BUTTONS"] = "顯示/隱藏按鈕"
L["SHOW_MENU_BUTTON"] = "顯示選單按鈕"
L["SHOW_CHAT_BUTTON"] = "顯示聊天按鈕"
L["SHOW_GUILD_BUTTON"] = "顯示公會按鈕"
L["SHOW_SOCIAL_BUTTON"] = "顯示好友按鈕"
L["SHOW_CHARACTER_BUTTON"] = "顯示角色按鈕"
L["SHOW_SPELLBOOK_BUTTON"] = "顯示法術書按鈕"
L["SHOW_TALENTS_BUTTON"] = "顯示天賦按鈕"
L["SHOW_ACHIEVEMENTS_BUTTON"] = "顯示成就按鈕"
L["SHOW_QUESTS_BUTTON"] = "顯示任務按鈕"
L["SHOW_LFG_BUTTON"] = "顯示隊伍搜尋器按鈕"
L["SHOW_JOURNAL_BUTTON"] = "顯示冒險指南按鈕"
L["SHOW_PVP_BUTTON"] = "顯示 PVP 按鈕"
L["SHOW_PETS_BUTTON"] = "顯示收藏按鈕"
L["SHOW_SHOP_BUTTON"] = "顯示遊戲商城按鈕"
L["SHOW_HELP_BUTTON"] = "顯示客服支援按鈕"
L["SHOW_HOUSING_BUTTON"] = "顯示房屋按鈕"
L["NO_INFO"] = "沒有資訊"
L["CLASSIC"] = "經典版"
L["Alliance"] = FACTION_ALLIANCE
L["Horde"] = FACTION_HORDE

L["DURABILITY_WARNING_THRESHOLD"] = "裝備耐久度警告門檻"
L["SHOW_ITEM_LEVEL"] = "顯示物品等級"
L["SHOW_COORDINATES"] = "顯示座標"

-- Master Volume
L["MASTER_VOLUME"] = "主音量"
L["VOLUME_STEP"] = "每點一下調整的值"
L["ENABLE_MOUSE_WHEEL"] = "啟用滑鼠滾輪"

-- Clock
L["TIME_FORMAT"] = "時間格式"
L["USE_SERVER_TIME"] = "使用伺服器時間"
L["NEW_EVENT"] = "新活動!"
L["LOCAL_TIME"] = "本地時間"
L["REALM_TIME"] = "伺服器時間"
L["OPEN_CALENDAR"] = "開啟行事曆"
L["OPEN_CLOCK"] = "開啟時鐘"
L["HIDE_EVENT_TEXT"] = "隱藏活動文字"
L["REST_ICON"] = "休息圖示"
L["SHOW_REST_ICON"] = "顯示休息圖示"
L["TEXTURE"] = "材質"
L["DEFAULT"] = "預設"
L["CUSTOM"] = "自訂"
L["CUSTOM_TEXTURE"] = "自訂材質"
L["HIDE_REST_ICON_MAX_LEVEL"] = "在最高等級時隱藏"
L["TEXTURE_SIZE"] = "材質大小"
L["POSITION"] = "位置"
L["CUSTOM_TEXTURE_COLOR"] = "自訂顏色"
L["COLOR"] = "顏色"

L["TRAVEL"] = "旅行傳送"
L["PORT_OPTIONS"] = "傳送選項"
L["READY"] = "完成"
L["TRAVEL_COOLDOWNS"] = "旅行傳送冷卻"
L["CHANGE_PORT_OPTION"] = "變更傳送選項"

-- Gold
L["REGISTERED_CHARACTERS"] = "已註冊角色"
L["SHOW_FREE_BAG_SPACE"] = "顯示背包剩餘空間"
L["SHOW_OTHER_REALMS"] = "顯示其他伺服器"
L["ALWAYS_SHOW_SILVER_COPPER"] = "總是顯示銀和銅"
L["SHORTEN_GOLD"] = "金額縮寫"
L["TOGGLE_BAGS"] = "打開/關閉背包"
L["SESSION_TOTAL"] = "本次登入總計"
L["DAILY_TOTAL"] = "本日總計"
L["SHOW_WARBAND_BANK_GOLD"] = "顯示" .. ACCOUNT_BANK_PANEL_TITLE .. "金錢"
L["GOLD_ROUNDED_VALUES"] = "只顯示金的部分"
L["HIDE_CHAR_UNDER_THRESHOLD"] = "隱藏低於閾值的角色"
L["HIDE_CHAR_UNDER_THRESHOLD_AMOUNT"] = "閾值"

-- Currency
L["SHOW_XP_BAR_BELOW_MAX_LEVEL"] = "未滿等時顯示經驗條"
L["CLASS_COLORS_XP_BAR"] = "使用職業顏色"
L["SHOW_TOOLTIPS"] = "顯示浮動提示資訊"
L["TEXT_ON_RIGHT"] = "文字在右側"
L["BAR_CURRENCY_SELECT"] = "要顯示在資訊列上的通貨"
L["FIRST_CURRENCY"] = "第一種兌換通貨"
L["SECOND_CURRENCY"] = "第二種兌換通貨"
L["THIRD_CURRENCY"] = "第三種兌換通貨"
L["RESTED"] = "休息加成"
L["SHOW_MORE_CURRENCIES"] = "Shift+滑鼠指向時顯示更多貨幣"
L["MAX_CURRENCIES_SHOWN"] = "按住 Shift 時顯示的最大貨幣數量"
L["ONLY_SHOW_MODULE_ICON"] = "只顯示模組圖示"
L["CURRENCY_NUMBER"] = "狀態列上的貨幣數量"
L["CURRENCY_SELECTION"] = "貨幣選擇"
L["SELECT_ALL"] = "全選"
L["UNSELECT_ALL"] = "取消全選"
L["OPEN_XIV_CURRENCY_OPTIONS"] = "開啟功能資訊列的貨幣選項"

-- System
L["WORLD_PING"] = "顯示世界延遲"
L["ADDONS_NUMBER_TO_SHOW"] = "顯示的插件數目"
L["ADDONS_IN_TOOLTIP"] = "顯示插件數目"
L["SHOW_ALL_ADDONS"] = "按住 Shift 顯示全部"
L["MEMORY_USAGE"] = "記憶體使用量"
L["GARBAGE_COLLECT"] = "清理記憶體"
L["CLEANED"] = "已清理"

-- Reputation
L["OPEN_REPUTATION"] = "開啟" .. REPUTATION
L["PARAGON_REWARD_AVAILABLE"] = "可領取巔峰獎勵"
L["CLASS_COLORS_REPUTATION"] = "聲望條使用職業顏色"
L["REPUTATION_COLORS_REPUTATION"] = "聲望條使用聲望顏色"
L["SHOW_LAST_REPUTATION_GAINED"] = "顯示最近取得的聲望"
L["FLASH_PARAGON_REWARD"] = "巔峰獎勵閃爍提示"
L["PROGRESS"] = "進度"
L["RANK"] = "等級"
L["PARAGON"] = "巔峰"

L["USE_CLASS_COLORS"] = "使用職業顏色"
L["COOLDOWNS"] = "冷卻時間"
L["TOGGLE_PROFESSION_FRAME"] = "打開/關閉專業視窗"
L["TOGGLE_PROFESSION_SPELLBOOK"] = "打開/關閉專業技能書"

L["SET_SPECIALIZATION"] = "切換專精"
L["SET_LOADOUT"] = "切換天賦配置"
L["SET_LOOT_SPECIALIZATION"] = "切換優先拾取的專精"
L["CURRENT_SPECIALIZATION"] = "目前職業專精"
L["CURRENT_LOOT_SPECIALIZATION"] = "目前優先拾取的專精"
L["ENABLE_LOADOUT_SWITCHER"] = "啟用切換天賦配置"
L["TALENT_MINIMUM_WIDTH"] = "天賦最小寬度"
L["OPEN_ARTIFACT"] = "檢視神兵武器"
L["REMAINING"] = "還需要"
L["AVAILABLE_RANKS"] = "神兵武器等級"
L["ARTIFACT_KNOWLEDGE"] = "神兵知識等級"

L["SHOW_BUTTON_TEXT"] = "顯示按鈕文字"

-- Travel
L["HEARTHSTONE"] = "爐石"
L["M_PLUS_TELEPORTS"] = "M+ 傳送"
L["ONLY_SHOW_CURRENT_SEASON"] = "僅顯示當前賽季"
L["MYTHIC_PLUS_TELEPORTS"] = "傳奇+ 傳送"
L["HIDE_M_PLUS_TELEPORTS_TEXT"] = "隱藏 M+ 傳送文字"
L["SHOW_MYTHIC_PLUS_TELEPORTS"] = "顯示傳奇+ 傳送"
L["USE_RANDOM_HEARTHSTONE"] = "使用隨機爐石"
local retrievingData = "正在讀取資料..."
L["RETRIEVING_DATA"] = retrievingData
L["EMPTY_HEARTHSTONES_LIST"] = "如果你在下方的清單中看到 '" .. retrievingData .. "'，只需切換分頁或重新開啟此選單即可重新整理資料。"
L["HEARTHSTONES_SELECT"] = "選擇爐石"
L["HEARTHSTONES_SELECT_DESC"] = "選擇要使用哪個爐石 (如果選擇了多個爐石，請勾選 \"使用隨機爐石\" 選項)"
L["HIDE_HEARTHSTONE_BUTTON"] = "隱藏爐石按鈕"
L["HIDE_PORT_BUTTON"] = "隱藏傳送按鈕"
L["HIDE_HOME_BUTTON"] = "隱藏家園按鈕"
L["HIDE_HEARTHSTONE_TEXT"] = "隱藏爐石文字"
L["HIDE_PORT_TEXT"] = "隱藏傳送文字"
L["HIDE_ADDITIONAL_TOOLTIP_TEXT"] = "隱藏額外提示文字"
L["HIDE_ADDITIONAL_TOOLTIP_TEXT_DESC"] = "在提示中隱藏爐石綁定位置與傳送按鈕。"
L["NOT_LEARNED"] = "尚未習得"
L["SHOW_UNLEARNED_TELEPORTS"] = "顯示未習得的傳送"
L["HIDE_BUTTON_DURING_OFF_SEASON"] = "在非賽季期間隱藏按鈕"

-- House/Home Selection
L["HOME"] = "回家"
L["UNKNOWN_HOUSE"] = "未知的房屋"
L["HOUSE"] = "房屋"
L["PLOT"] = NEIGHBORHOOD_ROSTER_COLUMN_TITLE_PLOT
L["SELECTED"] = "已選擇"
L["CHANGE_HOME"] = "更換回家"
L["NO_HOUSES_OWNED"] = "尚未擁有房屋"
L["VISIT_SELECTED_HOME"] = "造訪已選擇的房屋"

L["CLASSIC"] = "經典版"
L["Burning Crusade"] = "燃燒的遠征"
L["Wrath of the Lich King"] = "巫妖王之怒"
L["Cataclysm"] = "浩劫與重生"
L["Mists of Pandaria"] = "潘達利亞之謎"
L["Warlords of Draenor"] = "德拉諾之霸"
L["Legion"] = "軍臨天下"
L["Battle for Azeroth"] = "決戰艾澤拉斯"
L["Shadowlands"] = "暗影之境"
L["Dragonflight"] = "巨龍崛起"
L["The War Within"] = "地心之戰"
L["Midnight"] = "至暗之夜"
L["CURRENT_SEASON"] = "當前賽季"

-- Additional
L["XIV Bar Continued"] = "資訊列"  -- used for config menu
L["Profiles"] = "設定檔"
L["Money"] = "金錢"
L["Enable in combat"] = "戰鬥中可使用"
L["REGISTERED_CHARACTERS"] = "記錄的角色"
L["Overwatch"] = "鬥陣特攻"
L["Heroes of the Storm"] = "暴雪英霸"
L["HEARTHSTONE"] = "爐石戰記"
L["Starcraft 2"] = "星海爭霸II"
L["Diablo 3"] = "暗黑破壞神III"
L["Starcraft Remastered"] = "星海爭霸 高畫質重製版"
L["Destiny 2"] = "天命 2"
L["Call of Duty: BO4"] = "決勝時刻: 黑色行動4"
L["Call of Duty: MW"] = "決勝時刻: 現代戰爭"
L["Call of Duty: MW2"] = "決勝時刻: 現代戰爭2"
L["Call of Duty: BOCW"] = "決勝時刻: 黑色行動冷戰"
L["Call of Duty: Vanguard"] = "決勝時刻: 先鋒"
L["HIDE_IN_FLIGHT"] = "使用鳥點飛行時隱藏"
L["SHOW_ON_MOUSEOVER"] = "滑鼠指向時顯示"
L["SHOW_ON_MOUSEOVER_DESC"] = "只有滑鼠指向時才顯示資訊列"
L["CLASSIC"] = "《經典版》"
L["Warcraft 3 Reforged"] = "魔獸爭霸III: 淬鍊重生"
L["Diablo II: Resurrected"] = "暗黑破壞神II: 獄火重生"
L["Call of Duty: Vanguard"] = "決勝時刻: 先鋒"
L["Diablo Immortal"] = "暗黑破壞神 永生不朽"
L["Warcraft Arclight Rumble"] = "魔獸兵團"
L["Call of Duty: Modern Warfare II"] = "決勝時刻: 現代戰爭II 2022"
L["Diablo 4"] = "暗黑破壞神IV"
L["Blizzard Arcade Collection"] = "暴雪遊樂場典藏系列"
L["Crash Bandicoot 4"] = "袋狼大進擊4"
L["Hide Friends Playing Other Games"] = "隱藏其他遊戲好友" -- used for the friend list function I added myself

-- Profile Import/Export
L["PROFILE_SHARING"] = "分享設定檔"

L["INVALID_IMPORT_STRING"] = "無效的匯入字串"
L["FAILED_DECODE_IMPORT_STRING"] = "解碼匯入字串失敗"
L["FAILED_DECOMPRESS_IMPORT_STRING"] = "解壓縮匯入字串失敗"
L["FAILED_DESERIALIZE_IMPORT_STRING"] = "反序列化匯入字串失敗"
L["INVALID_PROFILE_FORMAT"] = "無效的設定檔格式"
L["PROFILE_IMPORTED_SUCCESSFULLY_AS"] = "設定檔已成功匯入為"

L["COPY_EXPORT_STRING"] = "複製以下匯出字串："
L["PASTE_IMPORT_STRING"] = "在下方貼上匯入字串："
L["IMPORT_EXPORT_PROFILES_DESC"] = "匯入或匯出你的設定檔，以便與其他玩家分享。"
L["PROFILE_IMPORT_EXPORT"] = "設定檔匯入/匯出"
L["EXPORT_PROFILE"] = "匯出設定檔"
L["EXPORT_PROFILE_DESC"] = "匯出你目前的設定檔"
L["IMPORT_PROFILE"] = "匯入設定檔"
L["IMPORT_PROFILE_DESC"] = "從其他玩家匯入設定檔"

-- Changelog
L["DATE_FORMAT"] = "%year%年%month%月%day%日"
L["IMPORTANT"] = "重要"
L["NEW"] = "新增"
L["IMPROVEMENT"] = "改善"
L["BUGFIX"] = "修正bug"
L["CHANGELOG"] = "更新記錄"

-- Vault Module
L["GREAT_VAULT_DISABLED"] = DELVES_GREAT_VAULT_LABEL .. " 目前已停用，直到下一賽季開始。"
L["MAX_LEVEL_DISCLAIMER"] = "此模組僅會在你達到最高等級時顯示。"