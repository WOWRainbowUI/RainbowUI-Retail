local addonName, addonTable = ...
if GetLocale() ~= "enGB" then return end
local L = addonTable.L

-- Settings Menu Titles
L["SETTINGS_FILTER"] = "Filter"
L["SETTINGS_APPEARANCE"] = "Appearance"
L["SETTINGS_BEHAVIOR"] = "Group Behaviour"
L["SETTINGS_AUTOMATION"] = "Automation"
L["SETTINGS_RESET"] = "|cffff0000Reset to Default|r"

-- Settings Options
L["SET_HIDE_OFFLINE"] = "Hide All Offline"
L["SET_HIDE_AFK"] = "Hide All AFK"
L["SET_HIDE_EMPTY"] = "Hide Empty Groups"
L["SET_INGAME_ONLY"] = "Show Only In-Game Friends"
L["SET_RETAIL_ONLY"] = "Show Only Retail Friends"
L["SET_CLASS_COLOR"] = "Use Class Colour Names"
L["SET_FACTION_ICONS"] = "Show Faction Icons"
L["SET_GRAY_FACTION"] = "Dim Opposing Faction"
L["SET_SHOW_REALM"] = "Show Realm"
L["SET_SHOW_BTAG"] = "Show Only BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "Hide Max Level"
L["SET_MOBILE_AFK"] = "Mark Mobile As AFK"
L["SET_FAV_GROUP"] = "Enable Favourite Friends Group"
L["SET_COLLAPSE"] = "Auto Collapse Groups"
L["SET_AUTO_ACCEPT"] = "Auto Accept Group Invite"

-- Group Right-Click Menu
L["MENU_RENAME"] = "Rename Group"
L["MENU_REMOVE"] = "Remove Group"
L["MENU_INVITE"] = "Invite Group to Party"
L["MENU_MAX_40"] = " (Max 40)"

-- Friend Dropdown Menu
L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Copy Name-Realm"
L["DROP_COPY_BTAG"] = "Copy BattleTag"
L["DROP_CREATE"] = "Create New Group"
L["DROP_ADD"] = "Add to Group"
L["DROP_REMOVE"] = "Remove from Group"
L["DROP_CANCEL"] = "Cancel"

-- Popups
L["POPUP_ENTER_NAME"] = "Enter new group name"
L["POPUP_COPY"] = "Press Ctrl+C to copy:"

-- Special Group Names
L["GROUP_FAVORITES"] = "[Favourites]"
L["GROUP_NONE"] = "[No Group]"
L["GROUP_EMPTY"] = "Friends List is empty"

-- Messages / Status
L["STATUS_MOBILE"] = "Mobile"
L["SEARCH_PLACEHOLDER"] = "FriendGroups Search"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Settings reset to default."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Bnet API Bug detected. Your empty Friends List is caused by a WoW Client Bug. Please try to restart your game. (no guaranteed fix)"
L["MSG_WELCOME"] = "Version %s updated for patch 12.0 by Osiris the Kiwi"

-- Tooltips
L["SEARCH_TOOLTIP"] = "FriendGroups: Search for anyone! Name, Realm, Class and even Notes"

-- [[ HOUSING / SAFE MODE ]] --
L["RELOAD_BTN_TEXT"]      = "Reload FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Reload FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Reloads the UI to restore FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups is Active|r\n\nDue to Blizzard Secure Frame restrictions,\nyou must reload to View Houses."
L["SHIELD_BTN_TEXT"]      = "Reload to View Houses"
L["SAFE_MODE_WARNING"]    = "|cffFF0000VIEW HOUSES:|r FriendGroups disabled to View Houses. Reload to enable."