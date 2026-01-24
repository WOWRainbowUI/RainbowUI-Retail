local addonName, addonTable = ...
if GetLocale() ~= "zhTW" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "過濾方式"
L["SETTINGS_APPEARANCE"] = "外觀"
L["SETTINGS_BEHAVIOR"] = "群組行為"
L["SETTINGS_AUTOMATION"] = "自動化"
L["SETTINGS_RESET"] = "|cffff0000重置為預設|r"

L["SET_HIDE_OFFLINE"] = "隱藏所有離線"
L["SET_HIDE_AFK"] = "隱藏所有暫離(AFK)"
L["SET_HIDE_EMPTY"] = "隱藏空群組"
L["SET_INGAME_ONLY"] = "僅顯示遊戲內好友"
L["SET_RETAIL_ONLY"] = "僅顯示正式服好友"
L["SET_CLASS_COLOR"] = "使用職業顏色名字"
L["SET_FACTION_ICONS"] = "顯示陣營圖示"
L["SET_GRAY_FACTION"] = "淡化對立陣營"
L["SET_SHOW_REALM"] = "顯示伺服器"
L["SET_SHOW_BTAG"] = "僅顯示 BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "隱藏滿級"
L["SET_MOBILE_AFK"] = "標記手機版為暫離"
L["SET_FAV_GROUP"] = "啟用最愛群組"
L["SET_COLLAPSE"] = "自動收合群組"
L["SET_AUTO_ACCEPT"] = "自動接受組隊邀請"

L["MENU_RENAME"] = "重新命名群組"
L["MENU_REMOVE"] = "移除群組"
L["MENU_INVITE"] = "邀請群組"
L["MENU_MAX_40"] = " (最多 40)"

L["DROP_TITLE"] = "好友群組"
L["DROP_COPY_NAME"] = "複製 名字-伺服器"
L["DROP_COPY_BTAG"] = "複製 BattleTag"
L["DROP_CREATE"] = "建立新群組"
L["DROP_ADD"] = "加入群組"
L["DROP_REMOVE"] = "移出群組"
L["DROP_CANCEL"] = "取消"

L["POPUP_ENTER_NAME"] = "輸入新群組名稱"
L["POPUP_COPY"] = "按 Ctrl+C 複製:"

L["GROUP_FAVORITES"] = "[最愛]"
L["GROUP_NONE"] = "[無群組]"
L["GROUP_EMPTY"] = "好友列表是空的"

L["STATUS_MOBILE"] = "手機"
L["SEARCH_PLACEHOLDER"] = "搜尋好友"
L["MSG_RESET"] = "|cFF33FF99好友群組|r: 設定已重置。"
L["MSG_BUG_WARNING"] = "|cFF33FF99好友群組s|r: 檢測到 Bnet API 錯誤。您的好友列表為空是遊戲客戶端 Bug 導致的。請嘗試重啟遊戲。"
L["MSG_WELCOME"] = "版本 %s 已更新至 12.0 (Osiris the Kiwi)"

L["SEARCH_TOOLTIP"] = "好友群組: 搜尋任何人！名字，伺服器，職業甚至備註"

L["RELOAD_BTN_TEXT"]      = "重載好友群組"
L["RELOAD_TOOLTIP_TITLE"] = "重載好友群組"
L["RELOAD_TOOLTIP_DESC"]  = "重載介面以恢復好友群組插件。"

L["SHIELD_MSG"]           = "|cffFF0000好友群組已啟用|r\n\n由於暴雪安全框架限制，\n您必須重載介面才能查看房屋。"
L["SHIELD_BTN_TEXT"]      = "重載以查看房屋"
L["SAFE_MODE_WARNING"]    = "|cffFF0000查看房屋:|r 好友群組已禁用以查看房屋。重載以啟用。"


-- 自行加入
L["FriendGroups Settings"] = "好友群組設定"