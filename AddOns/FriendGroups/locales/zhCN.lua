local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT CN ]] --
if GetLocale() ~= "zhCN" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "列表大小"
L["SETTINGS_FILTER"]     = "过滤器"
L["SETTINGS_APPEARANCE"] = "外观"
L["SETTINGS_BEHAVIOR"]   = "行为"
L["SETTINGS_AUTOMATION"] = "自动化"
L["SETTINGS_RESET"]      = "|cffff0000重置为默认|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "小 (默认)"
L["SET_SIZE_MEDIUM"]     = "中"
L["SET_SIZE_LARGE"]      = "大"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "隐藏离线"
L["SET_HIDE_AFK"]        = "隐藏暂离 (AFK)"
L["SET_MOBILE_AFK"]      = "将移动端标记为暂离"
L["SET_HIDE_EMPTY"]      = "隐藏空分组"
L["SET_INGAME_ONLY"]     = "仅显示游戏内好友"
L["SET_RETAIL_ONLY"]     = "仅显示正式服好友"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "显示服务器旗帜"
L["SET_SHOW_REALM"]      = "显示服务器名称"
L["SET_CLASS_COLOR"]     = "使用职业颜色"
L["SET_FACTION_ICONS"]   = "显示阵营图标"
L["SET_GRAY_FACTION"]    = "灰显对立阵营"
L["SET_SHOW_BTAG"]       = "仅显示战网昵称"
L["SET_HIDE_MAX_LEVEL"]  = "隐藏满级等级"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "启用特别关注分组"
L["SET_COLLAPSE"]        = "自动折叠分组"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "自动接受组队邀请"
L["SET_AUTO_PARTY_SYNC"] = "自动接受队伍同步"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "重命名分组"
L["MENU_REMOVE"]         = "删除分组"
L["MENU_INVITE"]         = "邀请分组"
L["MENU_MAX_40"]         = " (最多 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "复制 名字-服务器"
L["DROP_COPY_BTAG"]      = "复制 战网昵称"
L["DROP_CREATE"]         = "新建分组"
L["DROP_ADD"]            = "添加到分组"
L["DROP_REMOVE"]         = "移出分组"
L["DROP_CANCEL"]         = "取消"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "输入新分组名称"
L["POPUP_COPY"]          = "按 Ctrl+C 复制:"

L["SEARCH_PLACEHOLDER"]  = "FriendGroups 搜索"
L["SEARCH_TOOLTIP"]      = "FriendGroups: 搜索任何人！名字、服务器、职业甚至备注"

L["MSG_WELCOME"]         = "版本 %s 已由 Osiris the Kiwi 为补丁 12.0 更新"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: 设置已重置为默认。"
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: 检测到 Bnet API 错误。好友列表为空是魔兽客户端的 Bug 导致的。请尝试重启游戏。(无法保证修复)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[特别关注]"
L["GROUP_NONE"]          = "[无分组]"
L["GROUP_EMPTY"]         = "好友列表为空"
L["STATUS_MOBILE"]       = "移动端"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "重载 FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "重载 FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "重载界面以恢复 FriendGroups。"

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups 已激活|r\n\n由于暴雪安全框架限制，\n你需要重载界面才能查看房屋。"
L["SHIELD_BTN_TEXT"]      = "重载以查看房屋"
L["SAFE_MODE_WARNING"]    = "|cffFF0000房屋:|r FriendGroups 已禁用以查看房屋。重载以启用。"