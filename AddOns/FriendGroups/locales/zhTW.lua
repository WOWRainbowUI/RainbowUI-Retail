local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT TW ]] --
if GetLocale() ~= "zhTW" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "列表大小"
L["SETTINGS_FILTER"]     = "過濾"
L["SETTINGS_APPEARANCE"] = "外觀"
L["SETTINGS_BEHAVIOR"]   = "行為"
L["SETTINGS_AUTOMATION"] = "自動化"
L["SETTINGS_RESET"]      = "|cffff0000重置為預設值|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "小 (預設)"
L["SET_SIZE_MEDIUM"]     = "中"
L["SET_SIZE_LARGE"]      = "大"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "隱藏離線"
L["SET_HIDE_AFK"]        = "隱藏暫離 (AFK)"
L["SET_MOBILE_AFK"]      = "標記手機為暫離"
L["SET_HIDE_EMPTY"]      = "隱藏空群組"
L["SET_INGAME_ONLY"]     = "僅顯示遊戲內好友"
L["SET_RETAIL_ONLY"]     = "僅顯示正式服好友"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "顯示伺服器旗幟"
L["SET_SHOW_REALM"]      = "顯示伺服器名稱"
L["SET_CLASS_COLOR"]     = "使用職業顏色"
L["SET_FACTION_ICONS"]   = "顯示陣營圖示"
L["SET_GRAY_FACTION"]    = "灰顯對立陣營"
L["SET_SHOW_BTAG"]       = "僅顯示 BattleTag"
L["SET_HIDE_MAX_LEVEL"]  = "隱藏滿級等級"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "啟用最愛群組"
L["SET_COLLAPSE"]        = "自動折疊群組"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "自動接受組隊邀請"
L["SET_AUTO_PARTY_SYNC"] = "自動接受隊伍同步"
L["MSG_AUTO_INVITE"]     = "|cFF33FF99FriendGroups|r: %s 邀請你加入隊伍。自動接受 |cff00ff00已啟用|r"
L["MSG_AUTO_SYNC"]       = "|cFF33FF99FriendGroups|r: %s 邀請你進行隊伍同步。自動接受 |cff00ff00已啟用|r"

-- Spirit Behavior Sub-Menu
L["SET_SPIRIT_HEADER"]   = "靈魂行為"
L["SET_SPIRIT_NONE"]     = "無"
L["SET_SPIRIT_RES"]      = "自動接受復活"
L["SET_SPIRIT_RELEASE"]  = "自動釋放靈魂"

L["MSG_AUTO_RES"]        = "|cFF33FF99FriendGroups|r: %s 正在復活你。自動接受 |cff00ff00已啟用|r"
L["MSG_AUTO_RELEASE"]    = "|cFF33FF99FriendGroups|r: 你已經死亡。自動釋放靈魂 |cff00ff00已啟用|r"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "重新命名群組"
L["MENU_REMOVE"]         = "移除群組"
L["MENU_INVITE"]         = "邀請群組"
L["MENU_MAX_40"]         = " (上限 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "複製 名字-伺服器"
L["DROP_COPY_BTAG"]      = "複製 BattleTag"
L["DROP_CREATE"]         = "建立新群組"
L["DROP_ADD"]            = "加入群組"
L["DROP_REMOVE"]         = "移出群組"
L["DROP_CANCEL"]         = "取消"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "輸入新群組名稱"
L["POPUP_COPY"]          = "按 Ctrl+C 複製:"

L["SEARCH_PLACEHOLDER"]  = "搜尋 FriendGroups"
L["SEARCH_TOOLTIP"]      = "FriendGroups: 搜尋任何人！名字、伺服器、職業甚至備註"

L["MSG_WELCOME"]         = "版本 %s 已由 Osiris the Kiwi 為更新檔 12.0 更新"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: 設定已重置為預設值。"
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: 偵測到 Bnet API 錯誤。好友列表是空的可能是魔獸客戶端錯誤導致。請嘗試重新啟動遊戲。(無法保證修復)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[最愛]"
L["GROUP_NONE"]          = "[無群組]"
L["GROUP_EMPTY"]         = "好友列表是空的"
L["STATUS_MOBILE"]       = "手機"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "重載 FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "重載 FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "重載介面以還原 FriendGroups。"

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups 已啟用|r\n\n由於暴雪安全框架限制，\n你需要重載介面才能檢視房屋。"
L["SHIELD_BTN_TEXT"]      = "重載以檢視房屋"
L["SAFE_MODE_WARNING"]    = "|cffFF0000房屋:|r FriendGroups 已停用以檢視房屋。重載以啟用。"

-- 自行加入
L["SETTINGS_TITLE"] = "設定選項"