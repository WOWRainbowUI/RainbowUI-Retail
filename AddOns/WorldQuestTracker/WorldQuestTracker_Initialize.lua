


do
	WQT_VERSION = 414
	ARROW_UPDATE_FREQUENCE = 0.2

	--update quest type max when a new type of world quest is added to the filtering
	WQT_QUESTTYPE_MAX = 		11			--[[global]]

	--all quest types current available
	WQT_QUESTTYPE_GOLD = 		"gold"			--[[global]]
	WQT_QUESTTYPE_RESOURCE = 	"resource"		--[[global]]
	WQT_QUESTTYPE_APOWER = 		"apower"		--[[global]]
	WQT_QUESTTYPE_EQUIPMENT = 	"equipment"		--[[global]]
	WQT_QUESTTYPE_TRADE = 		"trade"			--[[global]]
	WQT_QUESTTYPE_DUNGEON = 	"dungeon"		--[[global]]
	WQT_QUESTTYPE_PROFESSION =	 "profession"	--[[global]]
	WQT_QUESTTYPE_PVP = 		"pvp"			--[[global]]
	WQT_QUESTTYPE_PETBATTLE = 	"petbattle"		--[[global]]
	WQT_QUESTTYPE_REPUTATION = 	"reputation"	--[[global]]
	WQT_QUESTTYPE_RACING = 		"racing"		--[[global]]

	WQT_QUERYTYPE_REWARD = 		"reward"		--[[global]]
	WQT_QUERYTYPE_QUEST = 		"quest"			--[[global]]
	WQT_QUERYTYPE_PERIOD = 		"period"		--[[global]]
	WQT_QUERYDB_ACCOUNT = 		"global"		--[[global]]
	WQT_QUERYDB_LOCAL = 		"character"		--[[global]]
	WQT_REWARD_RESOURCE = 		"resource"		--[[global]]
	WQT_REWARD_GOLD = 			"gold"			--[[global]]
	WQT_REWARD_APOWER = 		"artifact"		--[[global]]
	WQT_QUESTS_TOTAL = 			"total"			--[[global]]
	WQT_QUESTS_PERIOD = 		"quest"			--[[global]]
	WQT_DATE_TODAY = 			1				--[[global]]
	WQT_DATE_YESTERDAY = 		2				--[[global]]
	WQT_DATE_1WEEK = 			3				--[[global]]
	WQT_DATE_2WEEK = 			4				--[[global]]
	WQT_DATE_MONTH = 			5				--[[global]]

	--helps blend the icons within the map texture
	WQT_ZONEWIDGET_ALPHA =		0.97
	WQT_WORLDWIDGET_ALPHA =		0.975
	WQT_WORLDWIDGET_BLENDED =	ALPHA_BLEND_AMOUNT

	WQT_ANIMATION_SPEED = 0.05

	--where these came from
	QUESTTYPE_GOLD = 0x1
	QUESTTYPE_RESOURCE = 0x2
	QUESTTYPE_ITEM = 0x4
	QUESTTYPE_ARTIFACTPOWER = 0x8
	QUESTTYPE_PET = 0x16

	--todo: rename or put these into a table
	FILTER_TYPE_PET_BATTLES = "pet_battles"
	FILTER_TYPE_PVP = "pvp"
	FILTER_TYPE_PROFESSION = "profession"
	FILTER_TYPE_DUNGEON = "dungeon"
	FILTER_TYPE_GOLD = "gold"
	FILTER_TYPE_ARTIFACT_POWER = "artifact_power"
	FILTER_TYPE_GARRISON_RESOURCE = "garrison_resource"
	FILTER_TYPE_REPUTATION_TOKEN = "reputation_token"
	FILTER_TYPE_EQUIPMENT = "equipment"
	FILTER_TYPE_TRADESKILL = "trade_skill"
	FILTER_TYPE_RACING = "racing"

	--9.0.1 re-filling the French globals
	local questTagType = _G.Enum.QuestTagType
	LE_QUEST_TAG_TYPE_PET_BATTLE = questTagType.PetBattle
	LE_QUEST_TAG_TYPE_PROFESSION = questTagType.Profession
	LE_QUEST_TAG_TYPE_DUNGEON = questTagType.Dungeon
	LE_QUEST_TAG_TYPE_RAID = questTagType.Raid
	LE_QUEST_TAG_TYPE_INVASION = questTagType.Invasion
	LE_QUEST_TAG_TYPE_FACTION_ASSAULT = questTagType.FactionAssault
	LE_QUEST_TAG_TYPE_PVP = questTagType.PvP

	local questQualityType = _G.Enum.WorldQuestQuality --former known as rarity
	LE_WORLD_QUEST_QUALITY_COMMON = questQualityType.Common
	LE_WORLD_QUEST_QUALITY_RARE = questQualityType.Rare
	LE_WORLD_QUEST_QUALITY_EPIC = questQualityType.Epic

	local default_config = {
		profile = {
			ignore_maps = {
				[1978] = false, --dragon isles
			},
			filters = {
				pet_battles = true,
				pvp = true,
				profession = true,
				dungeon = true,
				gold = true,
				artifact_power = true,
				garrison_resource = true,
				equipment = true,
				trade_skill = true,
				reputation_token = true,
				racing = true,
			},

			dragon_racing = {
				minimap_enabled = true,
				minimap_scale = 1,
				minimap_track_color = {1, 1, 1},
			},

			close_blizz_popups = {
				ABANDON_QUEST = true,
			},

			sort_order = {
				[WQT_QUESTTYPE_REPUTATION] = 7,
				[WQT_QUESTTYPE_TRADE] = 5,
				[WQT_QUESTTYPE_APOWER] = 11,
				[WQT_QUESTTYPE_GOLD] = 8,
				[WQT_QUESTTYPE_RESOURCE] = 5,
				[WQT_QUESTTYPE_EQUIPMENT] = 10,
				[WQT_QUESTTYPE_DUNGEON] = 4,
				[WQT_QUESTTYPE_PROFESSION] = 3,
				[WQT_QUESTTYPE_PVP] = 2,
				[WQT_QUESTTYPE_PETBATTLE] = 6,
				[WQT_QUESTTYPE_RACING] = 9,
			},

			groupfinder = {
				enabled = false, -- 更改預設值
				invasion_points = false, --deprecated
				tracker_buttons = false,
				autoleave = false,
				autoleave_delayed = false,
				askleave_delayed = true,
				noleave = false,
				leavetimer = 30,
				noafk = true, --deprecated
				noafk_ticks = 5, --deprecated
				noafk_distance = 500, --deprecated
				nopvp = false, --deprecated
				frame = {},
				tutorial = 0,
				argus_min_itemlevel = 830, --deprecated
				ignored_quests = {},
				send_whispers = false,
				dont_open_in_group = true,

				kfilter = { --anti spam on pre-made dungeons
					enabled = true,
					ignore_leaders_enabled = true,
					leaders_ignored = {},
					ignore_by_time = 30,
					show_button = true,
					dont_show_ignored_leaders = true,
					wipe_counter = 0,
				},
			},

			rarescan = {
				show_icons = true,
				alerts_anywhere = false,
				join_channel = false,
				search_group = false, -- 更改預設值
				recently_spotted = {},
				recently_killed = {},
				name_cache = {},
				playsound = false,
				playsound_volume = 2,
				playsound_warnings = 0,
				use_master = true,
				always_use_english = true,
				add_from_premade = false,
				autosearch = true,
				autosearch_cooldown = 600,
				autosearch_share = false,
			},

			raredetected = {},

			world_map_config = {
				onmap_show = true,
				onmap_scale_offset = 1.0,
				summary_show = true,
				summary_scale = 0.95,
				summary_showby = "bytype", --"bytype" or "byzone"
				summary_anchor = "left",
				summary_widgets_per_row = 8,
			},

			world_map_hubscale = {},
			world_map_hubenabled = {},

			speed_run = {
				auto_accept = false,
				auto_complete = false,
				cancel_cinematic = false,
			},

			disable_world_map_widgets = false, --a
			show_filter_button = true, --a
			show_sort_button = false, --a
			show_timeleft_button = true, --a
			numerate_quests = true, --a
			show_warband_rep_warning = true, --a
			show_warband_rep_warning_color = "yellow",
			show_warband_rep_warning_alpha = 0.834,
			show_warband_rep_warning_desaturation = 0.5,

			show_emissary_info = true,

			worldmap_widgets = {
				textsize = 9,
				scale = 1,
				quest_icons_scale_offset = 0,
			},

			accessibility = {--a
				extra_tracking_indicator = false,--a
				use_bounty_ring = false,--a
			},--a

			show_world_shortcuts = false,

			last_news_time = 0,

			world_summary_alpha = 0.934, --parei fazendo a substituição dos valores hardcoded to these values, parei na criação da opção de mudar o alpha, parei procurando as funções que atualiza of frames com o novo alpha
			worldmap_widget_alpha = 0.933,

			hoverover_animations = false, --hover and shown slider animations
			anchor_options = {}, --store the anchor options of each anchor

			filter_always_show_faction_objectives = true,
			filter_force_show_brokenshore = true, --deprecated at this point, but won't be removed since further expantion might need this back
			sort_time_priority = 0,
			force_sort_by_timeleft = false,
			alpha_time_priority = false,
			show_timeleft = false,
			quests_tracked = {},
			quests_all_characters = {},
			banned_quests = {},
			syntheticMapIdList = {
				[1015] = 1, --azsuna
				[1018] = 2, --valsharah
				[1024] = 3, --highmountain
				[1017] = 4, --stormheim
				[1033] = 5, --suramar
				[1096] = 6, --eye of azshara
			},
			taxy_showquests = true,
			taxy_trackedonly = false,
			taxy_tracked_scale = 3,
			arrow_update_frequence = 0.016,
			map_lock = false,
			sound_enabled = true,--a
			use_tracker = false, -- 更改預設值
			tracker_attach_to_questlog = true,
			tracker_is_locked = false,
			tracker_only_currentmap = false,
			tracker_scale = 1,
			tracker_show_time = false,
			tracker_textsize = 15,
			tracker_background_alpha = 0.15,

			talking_heads_heard = {},--a
			talking_heads_torgast = false,--a
			talking_heads_dungeon = false,--a
			talking_heads_raid = false,--a
			talking_heads_openworld = false,--a

			flymaster_tracker_frame_pos = {},--a
			flymaster_tracker_enabled = true,--a

			show_faction_frame = true,--a

			map_frame_anchor = "left",--a

			map_frame_scale_enabled = false,--a
			map_frame_scale_mod = 1,--a

			use_quest_summary = true,
			quest_summary_minimized = false,
			show_summary_minimize_button = true,

			pins_discovered = {
				["worldquest-Capstone-questmarker-epic-Locked"] = {},
			},

			zone_map_config = {
				summary_show = true,
				quest_summary_scale = 1.2,
				show_widgets = true,
				scale = 1,
			},

			is_BFA_version = false, --if is false, reset the tutorial

			zone_only_tracked = false,
			low_level_tutorial = false,
			bar_anchor = "bottom",
			bar_visible = true,--a
			use_old_icons = false,--a
			history = {
				reward = {
					global = {},
					character = {},
				},
				quest = {
					global = {},
					character = {},
				},
				period = {
					global = {},
					character = {},
				},
			},
			show_yards_distance = true,
			player_names = {},
			tomtom = {
				enabled = false,
				uids = {},
				persistent = true,
			},

			path = {
				enabled = false,
				ColorSRGB = {1, 1, 1, 1},
				DotSize = 5,
				DotAmount = 20,
				DotTexture = [[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]],
				LineSize = 500,
			},
		},
	}

	--details! framework
	local DF = _G ["DetailsFramework"]
	if (not DF) then
		print ("|cFFFFAA00World Quest Tracker: framework not found, if you just installed or updated the addon, please restart your client.|r")
		return
	end

	--create the addon object
	local WorldQuestTracker = DF:CreateAddOn("WorldQuestTrackerAddon", "WQTrackerDB", default_config)
	WorldQuestTracker.__debug = false
	WorldQuestTracker.MapChangedTime = time()-1

	--create the group finder and rare finder frames
	CreateFrame("frame", "WorldQuestTrackerFinderFrame", UIParent, "BackdropTemplate")
	CreateFrame("frame", "WorldQuestTrackerRareFrame", UIParent, "BackdropTemplate")

	--create world quest tracker pin
	WorldQuestTrackerPinMixin = CreateFromMixins(MapCanvasPinMixin)

	--data providers are stored inside .dataProviders folder
	--catch the blizzard quest provider
	function WorldQuestTrackerAddon.CatchMapProvider (fromMapOpened)
		if (not WorldQuestTrackerAddon.DataProvider) then
			if (WorldMapFrame and WorldMapFrame.dataProviders) then
				for dataProvider, state in pairs (WorldMapFrame.dataProviders) do
					if (dataProvider.IsQuestSuppressed) then
						WorldQuestTrackerAddon.DataProvider = dataProvider
						break
					end
				end
			end

			if (not WorldQuestTrackerAddon.DataProvider and fromMapOpened) then
				WorldQuestTracker:Msg ("Failed to initialize or get Data Provider.")
			end
		end
	end

	WorldQuestTrackerAddon.CatchMapProvider()

	--store zone widgets
	WorldQuestTracker.ZoneWidgetPool = {}
	WorldQuestTracker.VignettePool = {}
	--default world quest pins
	WorldQuestTracker.DefaultWorldQuestPin = {}
	WorldQuestTracker.ShowDefaultWorldQuestPin = {}
	--frame where things will be parented to
	WorldQuestTracker.AnchoringFrame = WorldMapFrame.BorderFrame
	--frame level for things attached to the world map
	WorldQuestTracker.DefaultFrameLevel = 5000
	--the client has all the data for the quest
	WorldQuestTracker.HasQuestData = {}

	--color pallete
	WorldQuestTracker.ColorPalette = {
		orange = {1, .8, .22},
		yellow = {.8, .8, .22},
		red = {.9, .22, .22},
		green = {.22, .9, .22},
		blue = {.22, .22, .9},
	}

	--store the available resources from each quest and map
	WorldQuestTracker.ResourceData = {}

	--comms
	WorldQuestTracker.CommFunctions = {}
	function WorldQuestTracker.HandleComm (validData)
		local prefix = validData [1]
		if (WorldQuestTracker.CommFunctions [prefix]) then
			WorldQuestTracker.CommFunctions [prefix] (validData)
		end
	end

	--register things we'll use
	local color = OBJECTIVE_TRACKER_COLOR ["Header"]
	DF:NewColor ("WQT_QUESTTITLE_INMAP", color.r, color.g, color.b, .8)
	DF:NewColor ("WQT_QUESTTITLE_OUTMAP", 1, .8, .2, .7)
	DF:NewColor ("WQT_QUESTZONE_INMAP", 1, 1, 1, 1)
	DF:NewColor ("WQT_QUESTZONE_OUTMAP", 1, 1, 1, .7)
	DF:NewColor ("WQT_ORANGE_ON_ENTER", 1, 0.847059, 0, 1)
	DF:NewColor ("WQT_ORANGE_RESOURCES_AVAILABLE", 1, .7, .2, .85)
	DF:NewColor ("WQT_ORANGE_YELLOW_RARE_TITTLE", 1, 0.677059, 0.05, 1)

	DF:InstallTemplate ("font", "WQT_SUMMARY_TITLE", {color = "orange", size = 12, font = "Friz Quadrata TT"})
	DF:InstallTemplate ("font", "WQT_RESOURCES_AVAILABLE", {color = {1, .7, .2, .85}, size = 10, font = "Friz Quadrata TT"})
	DF:InstallTemplate ("font", "WQT_GROUPFINDER_BIG", {color = {1, .7, .2, .85}, size = 11, font = "Friz Quadrata TT"})
	DF:InstallTemplate ("font", "WQT_GROUPFINDER_SMALL", {color = {1, .9, .1, .85}, size = 10, font = "Friz Quadrata TT"})
	DF:InstallTemplate ("font", "WQT_GROUPFINDER_TRANSPARENT", {color = {1, 1, 1, .2}, size = 10, font = "Friz Quadrata TT"})
	DF:InstallTemplate ("font", "WQT_TOGGLEQUEST_TEXT", {color = {0.811, 0.626, .109}, size = 10, font = "Friz Quadrata TT"})

	DF:InstallTemplate ("button", "WQT_GROUPFINDER_BUTTON", {
		backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
		backdropcolor = {.2, .2, .2, 1},
		backdropbordercolor = {0, 0, 0, 1},
		width = 20,
		height = 20,
		enabled_backdropcolor = {.2, .2, .2, 1},
		disabled_backdropcolor = {.2, .2, .2, 1},
		onenterbordercolor = {0, 0, 0, 1},
	})

	DF:InstallTemplate ("button", "WQT_NEWS_BUTTON", {
		backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
		backdropcolor = {.2, .2, .2, .8},
		backdropbordercolor = {0, 0, 0, .8},
		width = 120,
		height = 20,
		onenterbordercolor = {0, 0, 0, 1},
		onentercolor = {.4, .4, .4, 1},
	}, "WQT_GROUPFINDER_BUTTON")

	--settings
	--WorldQuestTracker.Constants.
	WorldQuestTrackerAddon.Constants = {
		WorldMapSquareSize = 24,
		TimeBlipSize = 14,
	}

	WorldQuestTracker.ChangeLogTable = {}
end

--old to new api of wow v11
--C_Reputation.GetFactionDataByID
if (not GetFactionInfoByID) then
	WorldQuestTrackerAddon.GetFactionDataByID = function(id)
		---@type factioninfo
		local fD = C_Reputation.GetFactionDataByID(id) --sometimes he data isn't yet loaded, calling the function will make the client download the quest info.
		if (not fD) then
			return
		end

		return fD.name, fD.description, fD.currentStanding, 0, fD.nextReactionThreshold, fD.currentReactionThreshold, fD.atWarWith, fD.canToggleAtWar, fD.isHeader, fD.isCollapsed, fD.isHeaderWithRep, fD.isWatched, fD.isChild, fD.factionID,	fD.hasBonusRepGain, false

		--[=[]]
		--hasBonusRepGain=false,
		--description="Centaur clans roam the Ohn'ahran Plains, where they follow the call of the wind and seek the thrill of the hunt.",
		--isHeaderWithRep=false,
		--isHeader=false,
		--currentReactionThreshold=3000,
		canSetInactive=true,
		--atWarWith=false,
		--isWatched=false,
		--isCollapsed=false,
		--canToggleAtWar=false,
		--nextReactionThreshold=9000,
		--factionID=2503,
		--name="Maruuk Centaur",
		--currentStanding=3000,
		isAccountWide=true,
		--isChild=false,
		reaction=5
		--]=]

		--local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID (id)
		--return name
	end
else
	WorldQuestTrackerAddon.GetFactionDataByID = GetFactionInfoByID
end

if (not GetNumQuestLogRewardCurrencies) then
	WorldQuestTrackerAddon.GetNumQuestLogRewardCurrencies = function(questID)
		---@type questrewardcurrencyinfo[]
		local tQuestCurrencies = C_QuestLog.GetQuestRewardCurrencies(questID) or {}
		return #tQuestCurrencies
	end
else
	WorldQuestTrackerAddon.GetNumQuestLogRewardCurrencies = GetNumQuestLogRewardCurrencies
end

if (not GetQuestLogRewardCurrencyInfo) then
	WorldQuestTrackerAddon.GetQuestLogRewardCurrencyInfo = function(currencyIndex, questID)
		---@type questrewardcurrencyinfo[]
		local tQuestCurrencies = C_QuestLog.GetQuestRewardCurrencies(questID)
		tQuestCurrencies = tQuestCurrencies or {}
		local questRewardCurrencyInfo = tQuestCurrencies[currencyIndex]
		if (questRewardCurrencyInfo) then
			return questRewardCurrencyInfo.name, questRewardCurrencyInfo.texture, questRewardCurrencyInfo.totalRewardAmount, questRewardCurrencyInfo.currencyID, questRewardCurrencyInfo.bonusRewardAmount
		end
	end
else
	WorldQuestTrackerAddon.GetQuestLogRewardCurrencyInfo = GetQuestLogRewardCurrencyInfo
end

--WorldQuestTrackerAddon.__debug = true