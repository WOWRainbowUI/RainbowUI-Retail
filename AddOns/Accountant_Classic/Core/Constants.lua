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
local _, private = ...
private.addon_name = "Accountant_Classic"

local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name)
local playerFaction = UnitFactionGroup("player")
local _, playerClass = UnitClass("player")

-- Determine WoW client family
local projectID = WOW_PROJECT_ID

local function IsProject(id)
    return id ~= nil and projectID == id
end

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

-- Create constants table
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
		showmoneyinfo = true, 
		showintrotip = true,
		showmoneyonbutton = true,
		showsessiononbutton = true,
		cross_server = true,
		show_allFactions = true,
		trackzone = true,
		tracksubzone = true,
		breakupnumbers = true,
		weekstart = 1,
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
		"TRANSMO", "GARRISON", "LFG", "BARBER", "GUILD",
		"TRAIN", "TAXI", "TRADE", "AH", "MERCH", "REPAIRS", "MAIL", "QUEST", "LOOT", "OTHER" 
	}
	constants.onlineData = {
		["TRANSMO"] =	{ Title = TRANSMOGRIFY};
		["LFG"] =		{ Title = L["LFD, LFR and Scen."]};
		["BARBER"] =	{ Title = BARBERSHOP};
		["GUILD"] =		{ Title = GUILD};
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
		"GARRISON_MISSION_FINISHED",
		"GARRISON_ARCHITECT_OPENED",
		"GARRISON_ARCHITECT_CLOSED",
		"GARRISON_MISSION_NPC_OPENED",
		"GARRISON_MISSION_NPC_CLOSED",
		"GARRISON_SHIPYARD_NPC_OPENED",
		"GARRISON_SHIPYARD_NPC_CLOSED",
		"GARRISON_UPDATE",
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
	constants.eventLogTypes.GARRISON_MISSION_FINISHED = "GARRISON"
	constants.eventLogTypes.GARRISON_UPDATE = "GARRISON"
	constants.eventLogTypes.GARRISON_ARCHITECT_OPENED = "GARRISON"
	constants.eventLogTypes.GARRISON_MISSION_NPC_OPENED = "GARRISON"
	constants.eventLogTypes.GARRISON_SHIPYARD_NPC_OPENED = "GARRISON"
	constants.eventLogTypes.GARRISON_ARCHITECT_CLOSED = ""
	constants.eventLogTypes.GARRISON_MISSION_NPC_CLOSED = ""
	constants.eventLogTypes.GARRISON_SHIPYARD_NPC_CLOSED = ""

	constants.logtypes = {
		"TRANSMO", "GARRISON", "LFG", "BARBER", "GUILD",
		"TRAIN", "TAXI", "TRADE", "AH", "MERCH", "REPAIRS", "MAIL", "QUEST", "LOOT", "OTHER" 
	}
	constants.onlineData = {
		["TRANSMO"] =	{ Title = TRANSMOGRIFY};
		["GARRISON"] =	{ Title = GARRISON_LOCATION_TOOLTIP.." / "..ORDER_HALL_MISSIONS };
		["LFG"] =		{ Title = L["LFD, LFR and Scen."]};
		["BARBER"] =	{ Title = BARBERSHOP};
		["GUILD"] =		{ Title = GUILD};

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
