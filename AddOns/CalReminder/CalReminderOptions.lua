local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CalReminder", true)

if not CalReminderOptionsData then
	CalReminderOptionsData = {}
end

CalReminder_allianceNpcValues = {
	"ANDUIN"               ,
	"ALLIANCE_GUILD_HERALD",
	"VARIAN"               ,
	"HEMET"                ,
	"RAVERHOLDT"           ,
	"UTHER"                ,
	"VELEN"                ,
	"NOBUNDO"              ,
	"CHEN"                 ,
	"MALFURION"            ,
	"ILLIDAN"              ,
	"LICH_KING"            ,
	"SHANDRIS"             ,
	"SHAW"                 ,
	"VALEERA"              ,
	"JAINA"                ,
	"KANRETHAD"            ,
	"BOLVAR"               ,
	"TURALYON"             ,
	"ALLERIA"              ,
	"AZURATHEL"            ,
	"DINAIRE"              ,
	"VEREESA"              ,
}

CalReminder_hordeNpcValues = {
	"BAINE"             ,
	"SYLVANAS"          ,
	"HEMET"             ,
	"RAVERHOLDT"        ,
	"ILLIDAN"           ,
	"LICH_KING"         ,
	"HORDE_GUILD_HERALD",
	"THRALL"            ,
	"GALLYWIX"          ,
	"GAMON"             ,
	"REXXAR"            ,
	"VALEERA"           ,
	"HAMUUL"            ,
	"SAURFANG"          ,
	"GARROSH"           ,
	"LIADRIN"           ,
	"FAOL"              ,
	"KAELTHAS"          ,
	"CINDRETHRESH"      ,
	"DINAIRE"           ,
	"VEREESA"           ,
}


local function sorTableByNames(inputTable, firstValue)
    -- Create a temporary table to store the codes sorted by names
    local sortedTable = {}

    -- Insert the keys (codes) into the temporary table with their associated names
    for code, name in pairs(inputTable) do
        table.insert(sortedTable, { code = code, name = name })
    end

    -- Sort the temporary table by the 'name' field
    table.sort(sortedTable, function(a, b)
        return a.name < b.name
    end)

    -- Create the final table with numeric indices
    local resultTable = {}

    -- Add firstValue to the result table
    table.insert(resultTable, firstValue) -- Insert firstValue at the beginning

    -- Add the sorted values to the result table
    for _, entry in ipairs(sortedTable) do
        table.insert(resultTable, entry.code)
    end

    return resultTable
end

function loadCalReminderOptions()
	local allianceNpcValues = {}
	for _, entry in ipairs(CalReminder_allianceNpcValues) do
        allianceNpcValues[entry] = EZBlizzUiPop_GetNameFromNpcID(EZBlizzUiPop_npcModels[entry]["CreatureId"])
    end

	local allianceNpcValuesSorting = sorTableByNames(allianceNpcValues, "RANDOM")
	allianceNpcValues["RANDOM"] = ORANGE_FONT_COLOR:GenerateHexColorMarkup()..RANDOMIZE_APPEARANCE.."|r"
	
	local hordeNpcValues = {}
	for _, entry in ipairs(CalReminder_hordeNpcValues) do
        hordeNpcValues[entry] = EZBlizzUiPop_GetNameFromNpcID(EZBlizzUiPop_npcModels[entry]["CreatureId"])
    end

	local hordeNpcValuesSorting = sorTableByNames(hordeNpcValues, "RANDOM")
	hordeNpcValues["RANDOM"] = ORANGE_FONT_COLOR:GenerateHexColorMarkup()..RANDOMIZE_APPEARANCE.."|r"

	local CalReminderOptions = {
		type = "group",
		name = format("%s |cffADFF2Fv%s|r", L["CALREMINDER"], C_AddOns.GetAddOnMetadata("CalReminder", "Version")),
		args = {
			general = {
				type = "group", order = 1,
				name = GENERAL,
				inline = true,
				args = {
					enableSound = {
						type = "toggle", order = 1,
						name = ENABLE_SOUND,
						desc = ENABLE_SOUND,
						set = function(info, val) 
							CalReminderOptionsData["SoundsDisabled"] = not val
						end,
						get = function(info)
							local enabled = true
							if CalReminderOptionsData["SoundsDisabled"] ~= nil then
								enabled = not CalReminderOptionsData["SoundsDisabled"]
							end
							return enabled
						end
					},
					enableDeathQuotes = {
						type = "toggle", order = 2,
						name = L["CALREMINDER_OPTIONS_QUOTES"],
						desc = L["CALREMINDER_OPTIONS_QUOTES_DESC"],
						set = function(info, val) 
							DeadpoolOptionsData["QuotesDisabled"] = not val
							if val then
								if val then
									local englishFaction = UnitFactionGroup("player")
									local chief = CalReminderOptionsData["HORDE_NPC"] or "RANDOM"
									local chiefList = CalReminder_hordeNpcValues
									if englishFaction == "Alliance" then
										chief = CalReminderOptionsData["ALLIANCE_NPC"] or "RANDOM"
										chiefList = CalReminder_allianceNpcValues
									end
									if chief == "RANDOM" then
										chief = chiefList[math.random(1, #chiefList)]
									end
									EZBlizzUiPop_PlayNPCRandomSound(chief, "Dialog", true)
								end
							end
						end,
						get = function(info)
							local enabled = true
							if DeadpoolOptionsData["QuotesDisabled"] ~= nil then
								enabled = not DeadpoolOptionsData["QuotesDisabled"]
							end
							return enabled
						end
					},
					alliance = {
						type = "select", order = 3,
						width = "double",
						name = string.format(L["CALREMINDER_OPTIONS_NPC"], FACTION_ALLIANCE),
						desc = string.format(L["CALREMINDER_OPTIONS_NPC_DESC"], FACTION_ALLIANCE),
						values = allianceNpcValues,
						sorting = allianceNpcValuesSorting,
						set = function(info, val)
							CalReminderOptionsData["ALLIANCE_NPC"] = val
						end,
						get = function(info)
							return CalReminderOptionsData["ALLIANCE_NPC"] or "RANDOM"
						end
					},
					horde = {
						type = "select", order = 4,
						width = "double",
						name = string.format(L["CALREMINDER_OPTIONS_NPC"], FACTION_HORDE),
						desc = string.format(L["CALREMINDER_OPTIONS_NPC_DESC"], FACTION_HORDE),
						values = hordeNpcValues,
						sorting = hordeNpcValuesSorting,
						set = function(info, val)
							CalReminderOptionsData["HORDE_NPC"] = val
						end,
						get = function(info)
							return CalReminderOptionsData["HORDE_NPC"] or "RANDOM"
						end
					},
				},
			},
		},
	}

	ACR:RegisterOptionsTable("CalReminder", CalReminderOptions)
	
	CalReminderOptionsLoaded = true
	
	ACD:AddToBlizOptions("CalReminder", L["CalReminder"])
	ACD:SetDefaultSize("CalReminder", 400, 222)
end
