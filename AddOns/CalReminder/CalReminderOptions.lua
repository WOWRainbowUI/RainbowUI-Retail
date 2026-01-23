local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CalReminder", true)
local XITK = LibStub("XamInsightToolKit")
local EZBUP = LibStub("EZBlizzardUiPopups")

CalReminder_allianceNpcValues = {
	230055, -- ANDUIN
	49587,  -- ALLIANCE_GUILD_HERALD
	29611,  -- VARIAN
	191205, -- HEMET
	229150, -- RAVERHOLDT
	185157, -- Uther
	210670, -- VELEN
	212343, -- NOBUNDO
	250594, -- Chen Stormstout
	216069, -- Malfurion Stormrage
	129114, -- Illidan Stormrage
	36597,  -- LICH_KING
	216682, -- Shandris Feathermoon
	216115, -- Master Mathias Shaw
	229128, -- VALEERA
	216168, -- JAINA
	118618, -- Kanrethad Ebonlocke
	164079, -- BOLVAR
	223205, -- TURALYON
	230062, -- ALLERIA
	181056, -- AZURATHEL
	206533, -- DINAIRE
	250382, -- Vereesa Windrunner
	224220, -- ABIGAIL
	235448, -- XAL'ATATH
	241743, -- Archmage Khadgar
	215113, -- Orweyna
	207471, -- Widow Arak'nai
}

CalReminder_hordeNpcValues = {
	203314, -- Baine Bloodhoof
	177114, -- SYLVANAS
	191205, -- HEMET
	229150, -- RAVERHOLDT
	250594, -- Chen Stormstout
	129114, -- Illidan Stormrage
	36597,  -- LICH_KING
	49590,  -- HORDE_GUILD_HERALD
	229321, -- THRALL
	136683, -- Trade Prince Gallywix
	172181, -- Gamon
	200648, -- Rexxar
	229128, -- VALEERA
	107025, -- Archdruid Hamuul Runetotem
	156180, -- SAURFANG
	143425, -- GARROSH
	226656, -- LIADRIN
	186182, -- FAOL
	177216, -- Kael'thas Sunstrider
	181055, -- CINDRETHRESH
	206533, -- DINAIRE
	250382, -- Vereesa Windrunner
	224220, -- ABIGAIL
	235448, -- XAL'ATATH
	241743, -- Archmage Khadgar
	230062, -- ALLERIA
	215113, -- Orweyna
	207471, -- Widow Arak'nai
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
        allianceNpcValues[entry] = XITK.GetNameFromNpcID(entry)
    end

	local allianceNpcValuesSorting = sorTableByNames(allianceNpcValues, "RANDOM")
	allianceNpcValues["RANDOM"] = ORANGE_FONT_COLOR:GenerateHexColorMarkup()..RANDOMIZE_APPEARANCE.."|r"
	
	local hordeNpcValues = {}
	for _, entry in ipairs(CalReminder_hordeNpcValues) do
        hordeNpcValues[entry] = XITK.GetNameFromNpcID(entry)
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
						width = "normal",
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
					enableQuotes = {
						type = "toggle", order = 2,
						width = "normal",
						name = L["CALREMINDER_OPTIONS_QUOTES"],
						desc = L["CALREMINDER_OPTIONS_QUOTES_DESC"],
						disabled = function()
							return CalReminderOptionsData["SoundsDisabled"]
						end,
						set = function(info, val) 
							CalReminderOptionsData["QuotesDisabled"] = not val
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
									EZBUP.PlayNPCRandomSound(chief, "Dialog", not CalReminderOptionsData["SoundsDisabled"])
								end
							end
						end,
						get = function(info)
							local enabled = true
							if CalReminderOptionsData["QuotesDisabled"] ~= nil then
								enabled = not CalReminderOptionsData["QuotesDisabled"]
							end
							return enabled
						end
					},
					delay = {
						type = "range", order = 3,
						width = "full", descStyle = "",
						name = L["CALREMINDER_OPTIONS_DELAY"],
						get = function(i)
							return CalReminderOptionsData.delay
						end,
						set = function(i, v)
							CalReminderOptionsData.delay = v
						end,
						min = 2,
						max = 14,
						step = 1,
					},
					alliance = {
						type = "select", order = 4,
						width = "double",
						name = string.format(L["CALREMINDER_OPTIONS_NPC"], FACTION_ALLIANCE),
						desc = string.format(L["CALREMINDER_OPTIONS_NPC_DESC"], FACTION_ALLIANCE),
						values = alliancenpcValues,
						set = function(info, val)
							CalReminderOptionsData["ALLIANCE_NPC"] = val
							local chiefList = CalReminder_allianceNpcValues
							local chief = val
							if chief == "RANDOM" then
								chief = chiefList[math.random(1, #chiefList)]
							end
							EZBUP.npcDialog(chief, string.format(L["CALREMINDER_DDAY_REMINDER"], UnitName("player"), "???"))
							EZBUP.PlayNPCRandomSound(chief, "Dialog", not CalReminderOptionsData["SoundsDisabled"] and not CalReminderOptionsData["QuotesDisabled"])
						end,
						get = function(info)
							return CalReminderOptionsData["ALLIANCE_NPC"] or "SHANDRIS"
						end
					},
					horde = {
						type = "select", order = 5,
						width = "double",
						name = string.format(L["CALREMINDER_OPTIONS_NPC"], FACTION_HORDE),
						desc = string.format(L["CALREMINDER_OPTIONS_NPC_DESC"], FACTION_HORDE),
						values = hordeNpcValues,
						set = function(info, val)
							CalReminderOptionsData["HORDE_NPC"] = val
							local chiefList = CalReminder_hordeNpcValues
							local chief = val
							if chief == "RANDOM" then
								chief = chiefList[math.random(1, #chiefList)]
							end
							EZBUP.npcDialog(chief, string.format(L["CALREMINDER_DDAY_REMINDER"], UnitName("player"), "???"))
							EZBUP.PlayNPCRandomSound(chief, "Dialog", not CalReminderOptionsData["SoundsDisabled"] and not CalReminderOptionsData["QuotesDisabled"])
						end,
						get = function(info)
							return CalReminderOptionsData["HORDE_NPC"] or "GAMON"
						end
					},
				},
			},
		},
	}

	ACR:RegisterOptionsTable("CalReminder", CalReminderOptions)
	
	CalReminderOptionsLoaded = true
	
	ACD:AddToBlizOptions("CalReminder", L["CalReminder"])
	ACD:SetDefaultSize("CalReminder", 400, 272)
end
