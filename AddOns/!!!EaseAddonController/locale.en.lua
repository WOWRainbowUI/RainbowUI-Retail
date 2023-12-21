if GetLocale():sub(1,2)=="zh" then return end

local L = select(2, ...).L

TAG_CLASS = UnitClass("player")
TAG_NOTAGS = "Unclassified"
TAG_ALL = "All AddOns"

TAG_SOCIAL = "Chat & Comm."
TAG_AUCTION = "Auction & Eco."
TAG_PVP = "PvP"
TAG_COMBAT = "Combat"
TAG_ENHANCEMENT = "Enhancements"
TAG_ITEM = "Items"
TAG_MAP = "Map"
TAG_QUEST = "Quests"
TAG_BOSSRAID = "Boss & Raids"
TAG_PROFESSION = "Professions"
TAG_UNITFRAME = "Unit Frames"
TAG_ACTIONBAR = "Action Bars"
TAG_CLASSALL = "Class"
TAG_COLLECTION = "Collections"
TAG_MISC = "Miscellaneous"

TAG_DESC_SOCIAL = "AddOns related to Chat and Communication, and Guild activities."
TAG_DESC_AUCTION = "AddOns related to auctions and economy."
TAG_DESC_PVP = "AddOns related to PvP activities, including Arena and BattleGround."
TAG_DESC_COMBAT = "AddOns related to combats and player roles in combat."
TAG_DESC_ENHANCEMENT = "AddOns that enhance default interface, including Buffs & Debuffs, Tooltips, Garrison UIs, Artwork and Beautifications"
TAG_DESC_ITEM = "AddOns related to Bags, Inventories and Mails"
TAG_DESC_MAP = "Map and Minimap Enhancements"
TAG_DESC_QUEST = "AddOns related to Quests and Levelings."
TAG_DESC_BOSSRAID = "AddOns related to Boss Encounters and Raid Unit Frames."
TAG_DESC_PROFESSION = "AddOns related to profession skills."
TAG_DESC_UNITFRAME = "Unit Frames and HUDs"
TAG_DESC_ACTIONBAR = "Action Bars replacements or enhancements"
TAG_DESC_CLASSALL = "AddOns related to one or some Class skills and informations."
TAG_DESC_COLLECTION = "AddOns related to Achievements, Transmogrifications, Companions and Battle Pets."
TAG_DESC_MISC = "AddOns not easy to classify, and related to Audio & Video, Data Export, Development Tools, Plugins, Minigames and Libraries."

U1REASON_INCOMPATIBLE = "Incompatible"
U1REASON_DISABLED = "Disabled"
U1REASON_INTERFACE_VERSION = "Outdated"
U1REASON_DEP_DISABLED = "Deps Disabled"
U1REASON_DEP_CORRUPT = "Deps Corrupted"
U1REASON_SHORT_DEP_CORRUPT = "Deps Err"
U1REASON_SHORT_DEP_DISABLED = "Deps Err"
U1REASON_DEP_INTERFACE_VERSION = "Deps Outdated"
U1REASON_SHORT_DEP_INTERFACE_VERSION = "Deps Err"
U1REASON_DEP_MISSING = "Deps Missing"
U1REASON_SHORT_DEP_MISSING = "Deps Err"
U1REASON_DEP_NOT_DEMAND_LOADED = "Deps Not LoD"
U1REASON_SHORT_DEP_NOT_DEMAND_LOADED = "Deps Err"

--- ===========================================================
-- 163UI.lua
--- ===========================================================
L["desc.Load Now"] = "Hint`This addon is designed for loading on demand. But if you can load it anytime by pressing this button.` `|cffff0000Warning: Errors may occur.|r"

--- ===========================================================
-- 163UIUI_V3.lua
--- ===========================================================
L["desc.GC"] = "Initiate a memory garbage collection, Free some unnecessary memory usage. Not of much use."
L["EAC Options"] = "Options"
L["MemoryGC"] = "Memory"
L["short.LoadAll"] = "On"
L["short.DisableAll"] = "Off"
L["desc.SEARCH1"] = "Typing some text to start searching. AddOns contain the input text in their titles, folder names or EAC options, will be listed below. And the matching text part will be highlighted."
L["desc.SEARCH2"] = "If there is only one matched AddOn, you can press Enter to quickly select it."
L["desc.SEARCH3"] = false
L["help.SEARCH"] = "Just type here and enjoy the powerful searching feature of Ease AddOn Controller!"

L["CFG.desc"] = "Ease AddOn Controller is an advanced in-game addon control center, which combines Categoring, Searching, Loading and Setting of WoW addons all together.``The most advanced feature is that almost ANY addons can be loaded at ANYTIME, even those are not load-on-demands.``For advanced users, EAC also provides a solution to easily create option GUIs. The detailed development guide is on the website."
L["CFG.author"] = "NetEase Inc."

--- ===========================================================
-- The Complete Locale String List is in locale.cn.lua
--- ===========================================================
