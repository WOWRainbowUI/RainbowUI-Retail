
	----------------------------------------------------------------------
	-- Leatrix Plus Mute for Burning Crusade Anniversary
	----------------------------------------------------------------------

	local void, Leatrix_Plus = ...
	local L = Leatrix_Plus.L

	----------------------------------------------------------------------
	-- Mute game sounds
	----------------------------------------------------------------------

	-- Create soundtable
	local muteTable = {

		----------------------------------------------------------------------
		-- General
		----------------------------------------------------------------------

		-- Chimes (sound/doodad/)
		["MuteChimes"] = {
			"belltollalliance.ogg#566564",
			"belltollhorde.ogg#565853",
			"belltollnightelf.ogg#566558",
			"belltolltribal.ogg#566027",
			"kharazahnbelltoll.ogg#566254",
			"dwarfhorn.ogg#566064",
		},

		["MuteFizzle"] = {"sound/spells/fizzle/fizzlefirea.ogg#569773", "sound/spells/fizzle/FizzleFrostA.ogg#569775", "sound/spells/fizzle/FizzleHolyA.ogg#569772", "sound/spells/fizzle/FizzleNatureA.ogg#569774", "sound/spells/fizzle/FizzleShadowA.ogg#569776",},
		["MuteInterface"] = {"sound/interface/iUiInterfaceButtonA.ogg#567481", "sound/interface/uChatScrollButton.ogg#567407", "sound/interface/uEscapeScreenClose.ogg#567464", "sound/interface/uEscapeScreenOpen.ogg#567490",},

		-- Login
		["MuteLogin"] = {

			-- This is handled with the PLAYER_LOGOUT event

		},

		-- Trains
		["MuteTrains"] = {

			--[[Blood Elf]]	"sound#539219", "sound#539203",
			--[[Draenei]]	"sound#539516", "sound#539730",
			--[[Dwarf]]		"sound#539802", "sound#539881",
			--[[Gnome]]		"sound#540271", "sound#540275",
			--[[Human]]		"sound#540535", "sound#540734",
			--[[Night Elf]]	"sound#540870", "sound#540947",
			--[[Orc]]		"sound#541157", "sound#541239",
			--[[Tauren]]	"sound#542818", "sound#542896",
			--[[Troll]] 	"sound#543085", "sound#543093",
			--[[Undead]]	"sound#542526", "sound#542600",

		},

		-- Events
		["MuteEvents"] = {

			-- Headless Horseman (sound/creature/headlesshorseman/)
			"horseman_beckon_01.ogg#551670",
			"horseman_bodydefeat_01.ogg#551706",
			"horseman_bomb_01.ogg#551705",
			"horseman_conflag_01.ogg#551686",
			"horseman_death_01.ogg#551695",
			"horseman_failing_01.ogg#551684",
			"horseman_failing_02.ogg#551700",
			"horseman_fire_01.ogg#551673",
			"horseman_laugh_01.ogg#551703",
			"horseman_laugh_02.ogg#551682",
			"horseman_out_01.ogg#551680",
			"horseman_request_01.ogg#551687",
			"horseman_return_01.ogg#551698",
			"horseman_slay_01.ogg#551676",
			"horseman_special_01.ogg#551696",

		},

		-- Ready (ready check) (sound/interface/)
		["MuteReady"] = {"levelup2.ogg#567478", "readycheck.ogg#567409",},

		----------------------------------------------------------------------
		-- Pets
		----------------------------------------------------------------------

		-- Screech (sound/spells/)
		["MuteScreech"] = {"screech.ogg#569429",},

		-- Yawns (sound/creature/tiger/)
		["MuteYawns"] = {"mtigerstand2a.ogg#562388",},

		----------------------------------------------------------------------
		-- Toys
		----------------------------------------------------------------------

		-- Piccolo (Piccolo of the Flaming Fire) (sound/spells/)
		["MutePiccolo"] = {
			"sound/spells/seduction_state_head.ogg#568271",
		},

		----------------------------------------------------------------------
		-- Misc
		----------------------------------------------------------------------

		-- A'dal
		["MuteAdal"] = {

			-- sound/creature/naaru/
			"naruuloopgood.ogg#601649",

			-- sound/doodad/
			"ancient_d_lights.ogg#567134",

		},

	}

	----------------------------------------------------------------------
	-- Mute mount sounds
	----------------------------------------------------------------------

	-- Create soundtable
	local mountTable = {

		----------------------------------------------------------------------
		-- Mounts
		----------------------------------------------------------------------

		-- Gyrocopters
		["MuteGyrocopters"] = {

			-- sound/creature/gyrocopter/
			"gyrocopterfly.ogg#551390",
			"gyrocopterflyidle.ogg#551398",
			"gyrocopterflyup.ogg#551389",
			"gyrocoptergearshift1.ogg#551384",
			"gyrocoptergearshift2.ogg#551391",
			"gyrocoptergearshift3.ogg#551387",
			"gyrocopterjumpend.ogg#551396",
			"gyrocopterjumpstart.ogg#551399",
			"gyrocopterrun.ogg#551386",
			"gyrocoptershuffleleftorright1.ogg#551385",
			"gyrocoptershuffleleftorright2.ogg#551382",
			"gyrocoptershuffleleftorright3.ogg#551392",
			"gyrocopterstallinair.ogg#551395",
			"gyrocopterstand.ogg#551383",
			"gyrocopterstandvar1_a.ogg#551388",
			"gyrocopterstandvar1_b.ogg#551397",
			"gyrocopterstandvar1_bnew.ogg#551400",
			"gyrocopterwalk.ogg#551401",

			-- sound/spells/
			"summongyrocopter.ogg#568252",

		},

		-- Mechanical mount footsteps
		["MuteMechSteps"] = {

			-- Mechanostriders (sound/creature/gnomespidertank/)
			"gnomespidertankfootstepa.ogg#550507",
			"gnomespidertankfootstepb.ogg#550514",
			"gnomespidertankfootstepc.ogg#550501",
			"gnomespidertankfootstepd.ogg#550500",
			"gnomespidertankwoundd.ogg#550511",
			"gnomespidertankwounde.ogg#550504",
			"gnomespidertankwoundf.ogg#550498",

		},

		-- Striders
		["MuteStriders"] = {

			-- sound/creature/mechastrider/
			"mechastrideraggro.ogg#555127",
			"mechastriderattacka.ogg#555125",
			"smechastriderattackb.ogg#555123",
			"mechastriderattackc.ogg#555132",
			"mechastriderloop.ogg#555124",
			"mechastriderwounda.ogg#555128",
			"mechastriderwoundb.ogg#555129",
			"mechastriderwoundc.ogg#555130",
			"mechastriderwoundcrit.ogg#555131",

		},

		-- Horse footsteps
		["MuteHorsesteps"] = {

			-- sound/creature/horse/mfootstepshorse
			"dirt01.ogg#552083",
			"dirt02.ogg#552081",
			"dirt03.ogg#552072",
			"dirt04.ogg#552089",
			"dirt05.ogg#552078",
			"grass01.ogg#552087",
			"grass02.ogg#552085",
			"grass03.ogg#552062",
			"grass04.ogg#552071",
			"grass05.ogg#552079",
			"snow01.ogg#552065",
			"snow02.ogg#552084",
			"snow03.ogg#552058",
			"snow04.ogg#552073",
			"snow05.ogg#552077",
			"stone01.ogg#552090",
			"stone02.ogg#552068",
			"stone03.ogg#552070",
			"stone04.ogg#552082",
			"stone05.ogg#552060",
			"wood01.ogg#552086",
			"wood02.ogg#552075",
			"wood03.ogg#552076",
			"wood04.ogg#552066",
			"wood05.ogg#552063",

			-- Water is sound/character/footsteps/watersplash/footstepsmediumwater

		},

	}

	----------------------------------------------------------------------
	-- End
	----------------------------------------------------------------------

	Leatrix_Plus["muteTable"] = muteTable
	Leatrix_Plus["mountTable"] = mountTable
