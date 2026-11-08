-- ----------------------------------------------------------------------------
-- Localized Lua globals.
-- ----------------------------------------------------------------------------
-- Functions
local _G = getfenv(0)
local LibStub = _G.LibStub
local UnitFactionGroup = _G.UnitFactionGroup
local UnitClass = _G.UnitClass
-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
---@class ACNamespace
local private = select(2, ...)
private.addon_name = "Accountant_Classic"

local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name)
local playerFaction = UnitFactionGroup("player")
local _, playerClass = UnitClass("player")

-- Determine WoW client family
local projectID = WOW_PROJECT_ID

local function IsProject(id)
    return id ~= nil and projectID == id
end

---@class ACClient
local Client = {
    projectID = projectID,

    isRetail = IsProject(WOW_PROJECT_MAINLINE),
    isClassicEra = IsProject(WOW_PROJECT_CLASSIC),
    isTBCClassic = IsProject(WOW_PROJECT_BURNING_CRUSADE_CLASSIC),
    isCataclysmClassic = IsProject(WOW_PROJECT_CATACLYSM_CLASSIC),
    isMistsClassic = IsProject(WOW_PROJECT_MISTS_CLASSIC),
    isForever = IsProject(WOW_PROJECT_CAMELOT),
}

Client.isProgressionClassic = Client.isCataclysmClassic or Client.isMistsClassic
Client.isAnyClassic = Client.isClassicEra or Client.isTBCClassic or Client.isProgressionClassic
Client.isKnownProject = Client.isRetail or Client.isAnyClassic or Client.isForever
private.Client = Client

-- Returns the "|cAARRGGBB" colour prefix for a class token, or "" when the token is
-- unknown to this client (e.g. data saved by another game flavour), instead of erroring
-- on RAID_CLASS_COLORS[class] being nil.
---@param classToken string? Class token, e.g. "MAGE"
---@return string prefix "|cAARRGGBB", or "" when the class is unknown
function private.GetClassColorPrefix(classToken)
	local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
	if color and color.colorStr then
		return "|c"..color.colorStr
	end
	return ""
end

-- Create constants table
---@class ACConstants
local constants = {}
private.constants = constants

constants.defaults = {
	profile = {
		minimap = {
			hide = false,
			show = true,
			minimapPos = 153,
		},
		showbutton = true, 
		showmoneyinfo = false,
		showintrotip = true,
		showmoneyonbutton = true,
		showsessiononbutton = true,
		cross_server = true,
		show_allFactions = true,
		trackzone = true,
		tracksubzone = true,
		breakupnumbers = true,
		weekstart = 5,
		ldbDisplayType = 2,
		dateformat = 1,
		scale = 1,
		alpha = 1,
		infoscale = 1,
		infoalpha = 1,
		faction = playerFaction,
		class = playerClass,
		AcFramePoint = { "TOPLEFT", "UIParent", "TOPLEFT", 0, -104 },
		MnyFramePoint = { "TOPLEFT", "UIParent", "TOPLEFT", 10, -80 },
		profileCopied = false,
		rememberSelectedCharacter = true,
	},
}

constants.logmodes = {"Session", "Day", "PrvDay", "Week", "PrvWeek", "Month", "PrvMonth", "Year", "PrvYear", "Total" }
constants.months = { MONTH_JANUARY, MONTH_FEBRUARY, MONTH_MARCH, MONTH_APRIL, MONTH_MAY, MONTH_JUNE, MONTH_JULY, MONTH_AUGUST, MONTH_SEPTEMBER, MONTH_OCTOBER, MONTH_NOVEMBER, MONTH_DECEMBER }

constants.eventLogTypes = {
	GUILDBANKFRAME_OPENED = "GUILD",
	GUILDBANK_UPDATE_MONEY = "GUILD",
	GUILDBANK_UPDATE_WITHDRAWMONEY = "GUILD",
	GUILDBANKFRAME_CLOSED = "",
	LFG_COMPLETION_REWARD = "LFG",
	BARBER_SHOP_APPEARANCE_APPLIED = "",
	BARBER_SHOP_OPEN = "BARBER",
	BARBER_SHOP_CLOSE = "",
	BARBER_SHOP_RESULT = "BARBER",
	BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE = "BARBER",
	BARBER_SHOP_COST_UPDATE = "BARBER",
	TRANSMOGRIFY_OPEN = "TRANSMO",
	TRANSMOGRIFY_CLOSE = "",
	MERCHANT_SHOW = "MERCH",
	MERCHANT_CLOSED = "",
	TAXIMAP_OPENED = "TAXI",
	LOOT_OPENED = "LOOT",
	TRADE_SHOW = "TRADE",
	TRADE_CLOSED = "",
	QUEST_COMPLETE = "QUEST",
	QUEST_TURNED_IN = "QUEST",
	TRAINER_SHOW = "TRAIN",
	TRAINER_CLOSED = "",
	CONFIRM_TALENT_WIPE = "TRAIN",
	AUCTION_HOUSE_SHOW = "AH",
	AUCTION_HOUSE_CLOSED = "",
	-- Bank (bank bag slots / bank tab purchases, Warband bank gold deposits / withdrawals)
	BANKFRAME_OPENED = "BANK",
	BANKFRAME_CLOSED = "",
}

if (Client.isAnyClassic) then 
	constants.events = {
		-- Barber shop
		"BARBER_SHOP_APPEARANCE_APPLIED",
		"BARBER_SHOP_OPEN",
		"BARBER_SHOP_CLOSE",
		"BARBER_SHOP_RESULT",
		"BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE",
		"BARBER_SHOP_COST_UPDATE",
		-- LFG
		"LFG_COMPLETION_REWARD",
		-- Transmogrify
		"TRANSMOGRIFY_OPEN",
		"TRANSMOGRIFY_CLOSE",
		-- Guild
		"GUILDBANKFRAME_OPENED",
		"GUILDBANKFRAME_CLOSED",
		"GUILDBANK_UPDATE_MONEY",
		"GUILDBANK_UPDATE_WITHDRAWMONEY",
		-- Bank
		"BANKFRAME_OPENED",
		"BANKFRAME_CLOSED",
		"PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
		"PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
		-- Talent
		"CONFIRM_TALENT_WIPE",
		-- Merchant
		"MERCHANT_SHOW",
		"MERCHANT_CLOSED",
		"MERCHANT_UPDATE",
		-- Quest
		"QUEST_COMPLETE",
		"QUEST_FINISHED",
		"QUEST_TURNED_IN",
		-- Loot
		"LOOT_OPENED",
		"LOOT_CLOSED",
		-- Taxi
		"TAXIMAP_OPENED",
		"TAXIMAP_CLOSED",
		-- Trade
		"TRADE_SHOW",
		"TRADE_CLOSED",
		-- Mail
		"MAIL_INBOX_UPDATE",
		-- Trainer
		"TRAINER_SHOW",
		"TRAINER_CLOSED",
		-- AH
		"AUCTION_HOUSE_SHOW",
		"AUCTION_HOUSE_CLOSED",
		-- Others
		"CHAT_MSG_MONEY",
		"PLAYER_MONEY",
	}
	constants.logtypes = {
		"TRANSMO", "GARRISON", "LFG", "BARBER", "GUILD", "BANK",
		"TRAIN", "TAXI", "TRADE", "AH", "MERCH", "REPAIRS", "MAIL", "QUEST", "LOOT", "OTHER" 
	}
	constants.onlineData = {
		["TRANSMO"] =	{ Title = TRANSMOGRIFY};
		["LFG"] =		{ Title = L["LFD, LFR and Scen."]};
		["BARBER"] =	{ Title = BARBERSHOP};
		["GUILD"] =		{ Title = GUILD};
		["BANK"] =		{ Title = BANK};
		["TRAIN"] = 	{ Title = L["Training Costs"]};
		["TAXI"] = 		{ Title = L["Taxi Fares"]};
		["TRADE"] = 	{ Title = L["Trade Window"]};
		["AH"] = 		{ Title = AUCTIONS};
		["MERCH"] = 	{ Title = L["Merchants"]};
		["REPAIRS"] = 	{ Title = L["Repair Costs"]};
		["MAIL"] = 		{ Title = L["Mail"]};
		["QUEST"] = 	{ Title = QUESTS_LABEL};
		["LOOT"] = 		{ Title = LOOT};
		["OTHER"] = 	{ Title = L["Unknown"]};
	}
else
	constants.events = {
		-- Garrison
		-- Only events caused by the player interacting with a garrison / order hall NPC
		-- switch the log type. GARRISON_UPDATE and GARRISON_MISSION_FINISHED fire in the
		-- background (missions completing, garrison data refreshes), so using them left
		-- the log type stuck on GARRISON and unrelated money (bank tab purchases, loot)
		-- was logged there.
		"GARRISON_ARCHITECT_OPENED",
		"GARRISON_ARCHITECT_CLOSED",
		"GARRISON_MISSION_NPC_OPENED",
		"GARRISON_MISSION_NPC_CLOSED",
		"GARRISON_SHIPYARD_NPC_OPENED",
		"GARRISON_SHIPYARD_NPC_CLOSED",
		-- Barber shop
		"BARBER_SHOP_APPEARANCE_APPLIED",
		"BARBER_SHOP_OPEN",
		"BARBER_SHOP_CLOSE",
		"BARBER_SHOP_RESULT",
		"BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE",
		"BARBER_SHOP_COST_UPDATE",
		-- LFG
		"LFG_COMPLETION_REWARD",
		-- Transmogrify
		"TRANSMOGRIFY_OPEN",
		"TRANSMOGRIFY_CLOSE",
		-- Guild
		"GUILDBANKFRAME_OPENED",
		"GUILDBANKFRAME_CLOSED",
		"GUILDBANK_UPDATE_MONEY",
		"GUILDBANK_UPDATE_WITHDRAWMONEY",
		-- Bank
		"BANKFRAME_OPENED",
		"BANKFRAME_CLOSED",
		"PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
		"PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
		-- Talent
		"CONFIRM_TALENT_WIPE",
		-- Merchant
		"MERCHANT_SHOW",
		"MERCHANT_CLOSED",
		"MERCHANT_UPDATE",
		-- Quest
		"QUEST_COMPLETE",
		"QUEST_FINISHED",
		"QUEST_TURNED_IN",
		-- Loot
		"LOOT_OPENED",
		"LOOT_CLOSED",
		-- Taxi
		"TAXIMAP_OPENED",
		"TAXIMAP_CLOSED",
		-- Trade
		"TRADE_SHOW",
		"TRADE_CLOSED",
		-- Mail
		"MAIL_INBOX_UPDATE",
		-- Trainer
		"TRAINER_SHOW",
		"TRAINER_CLOSED",
		-- AH
		"AUCTION_HOUSE_SHOW",
		"AUCTION_HOUSE_CLOSED",
		-- Others
		"CHAT_MSG_MONEY",
		"PLAYER_MONEY",
	}
	constants.eventLogTypes.GARRISON_ARCHITECT_OPENED = "GARRISON"
	constants.eventLogTypes.GARRISON_MISSION_NPC_OPENED = "GARRISON"
	constants.eventLogTypes.GARRISON_SHIPYARD_NPC_OPENED = "GARRISON"
	constants.eventLogTypes.GARRISON_ARCHITECT_CLOSED = ""
	constants.eventLogTypes.GARRISON_MISSION_NPC_CLOSED = ""
	constants.eventLogTypes.GARRISON_SHIPYARD_NPC_CLOSED = ""

	constants.logtypes = {
		"TRANSMO", "GARRISON", "LFG", "BARBER", "GUILD", "BANK",
		"TRAIN", "TAXI", "TRADE", "AH", "MERCH", "REPAIRS", "MAIL", "QUEST", "LOOT", "OTHER"
	}
	constants.onlineData = {
		["TRANSMO"] =	{ Title = TRANSMOGRIFY};
		["GARRISON"] =	{ Title = GARRISON_LOCATION_TOOLTIP.." / "..ORDER_HALL_MISSIONS };
		["LFG"] =		{ Title = L["LFD, LFR and Scen."]};
		["BARBER"] =	{ Title = BARBERSHOP};
		["GUILD"] =		{ Title = GUILD};
		["BANK"] =		{ Title = BANK};

		["TRAIN"] = 	{ Title = L["Training Costs"]};
		["TAXI"] = 		{ Title = L["Taxi Fares"]};
		["TRADE"] = 	{ Title = L["Trade Window"]};
		["AH"] = 		{ Title = AUCTIONS};
		["MERCH"] = 	{ Title = L["Merchants"]};
		["REPAIRS"] = 	{ Title = L["Repair Costs"]};
		["MAIL"] = 		{ Title = L["Mail"]};
		["QUEST"] = 	{ Title = QUESTS_LABEL};
		["LOOT"] = 		{ Title = LOOT};
		["OTHER"] = 	{ Title = L["Unknown"]};
	}
end


constants.currTab = 1

constants.ldbDisplayTypes = { "Total", "Session", "Day", "Week", "Month" }

constants.dateformats = { "mm/dd/yy", "dd/mm/yy", "yy/mm/dd", }

constants.tabText = {
	L["This Session"],
	L["Today"],
	L["Prv. Day"],
	L["This Week"],
	L["Prv. Week"],
	L["This Month"],
	L["Prv. Month"],
	L["This Year"],
	L["Prv. Year"],
	L["Total"],
	L["All Chars"],
}
constants.tabTooltipText = {
	L["TT1"],
	L["TT2"],
	L["TT3"],
	L["TT4"],
	L["TT5"],
	L["TT6"],
	L["TT7"],
	L["TT8"],
	L["TT9"],
	L["TT10"],
	L["TT11"],
}

-- Maximum lines for characters to be displayed. 
-- We have 18 lines of space but we are using the 18th line to present the total. 
constants.maxCharLines = 17

-- Maximum lines of tooltip
constants.maxTooltipLines = 50

-- icon texture
constants.iconTexture = "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantClassicButton-Up"
