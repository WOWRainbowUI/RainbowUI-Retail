local addonName, addonTable = ...
if GetLocale() ~= "zhCN" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "过滤器"
L["SETTINGS_APPEARANCE"] = "外观"
L["SETTINGS_BEHAVIOR"] = "分组行为"
L["SETTINGS_AUTOMATION"] = "自动化"
L["SETTINGS_RESET"] = "|cffff0000重置为默认|r"

L["SET_HIDE_OFFLINE"] = "隐藏所有离线"
L["SET_HIDE_AFK"] = "隐藏所有暂离(AFK)"
L["SET_HIDE_EMPTY"] = "隐藏空分组"
L["SET_INGAME_ONLY"] = "仅显示游戏内好友"
L["SET_RETAIL_ONLY"] = "仅显示正式服好友"
L["SET_CLASS_COLOR"] = "使用职业颜色名字"
L["SET_FACTION_ICONS"] = "显示阵营图标"
L["SET_GRAY_FACTION"] = "暗化对立阵营"
L["SET_SHOW_REALM"] = "显示服务器"
L["SET_SHOW_BTAG"] = "仅显示战网昵称"
L["SET_HIDE_MAX_LEVEL"] = "隐藏满级"
L["SET_MOBILE_AFK"] = "标记移动端为暂离"
L["SET_FAV_GROUP"] = "启用特别关注分组"
L["SET_COLLAPSE"] = "自动折叠分组"
L["SET_AUTO_ACCEPT"] = "自动接受组队邀请"

L["MENU_RENAME"] = "重命名分组"
L["MENU_REMOVE"] = "删除分组"
L["MENU_INVITE"] = "邀请全组"
L["MENU_MAX_40"] = " (最多 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "复制 名字-服务器"
L["DROP_COPY_BTAG"] = "复制 战网昵称"
L["DROP_CREATE"] = "创建新分组"
L["DROP_ADD"] = "添加到分组"
L["DROP_REMOVE"] = "从分组移除"
L["DROP_CANCEL"] = "取消"

L["POPUP_ENTER_NAME"] = "输入新分组名称"
L["POPUP_COPY"] = "按 Ctrl+C 复制:"

L["GROUP_FAVORITES"] = "[特别关注]"
L["GROUP_NONE"] = "[无分组]"
L["GROUP_EMPTY"] = "好友列表是空的"

L["STATUS_MOBILE"] = "移动端"
L["SEARCH_PLACEHOLDER"] = "搜索好友"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: 设置已重置。"
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: 检测到战网API错误。您的好友列表为空是游戏客户端Bug导致的。请尝试重启游戏。"
L["MSG_WELCOME"] = "版本 %s 已更新至 12.0 (Osiris the Kiwi)"

L["SEARCH_TOOLTIP"] = "FriendGroups: 搜索任何人！名字，服务器，职业甚至备注"

L["RELOAD_BTN_TEXT"]      = "重载 FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "重载 FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "重载界面以恢复 FriendGroups 插件。"

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups 已激活|r\n\n由于暴雪安全框架限制，\n您必须重载界面才能查看房屋。"
L["SHIELD_BTN_TEXT"]      = "重载以查看房屋"
L["SAFE_MODE_WARNING"]    = "|cffFF0000查看房屋:|r FriendGroups 已禁用以查看房屋。重载以启用。"