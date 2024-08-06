DBM.Test:DefineTest{
	name = "MoP/Party/Scholomance/JandiceBarov/MoP-Remix",
	gameVersion = "Retail",
	addon = "DBM-Party-MoP",
	mod = 663,
	instanceInfo = {name = "Scholomance", instanceType = "party", difficultyID = 1, difficultyName = "Normal", maxPlayers = 5, dynamicDifficulty = 0, isDynamic = false, instanceID = 1007, instanceGroupSize = 5, lfgDungeonID = nil},
	playerName = "Jungwee",
	log = {
		{0.00, "ENCOUNTER_START", 1427, "Jandice Barov", 1, 5},
		{0.00, "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "Fake Args:", "boss1", true, true, true, "Jandice Barov", "Creature-0-3888-1007-7106-59184-00004B386C", "elite", 13982, "boss2", false, false, false, "??", nil, "normal", 0, "boss3", false, false, false, "??", nil, "normal", 0, "boss4", false, false, false, "??", nil, "normal", 0, "boss5", false, false, false, "??", nil, "normal", 0, "Real Args:"},
		{0.00, "IsEncounterInProgress()", true},
		{0.00, "IsEncounterSuppressingRelease()", true},
		{0.01, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Jazac", "TargetOfTarget: Jandice Barov"},
		{0.21, "CHAT_MSG_MONSTER_YELL", "Ooh, it takes some real stones to challenge the Mistress of Illusion. Well? Show me what you've got!", "Jandice Barov", "", "", "", "", 0, 0, "", 0, 152, nil, 0, false, false, false, false},
		{0.21, "CHAT_MSG_MONSTER_SAY", "I can't bear to watch.", "Talking Skull", "", "", "Jandice Barov", "", 0, 0, "", 0, 153, nil, 0, false, false, false, false},
		{-1.34, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_PERIODIC_MISSED", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, nil, nil},
		{0.76, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Moplius", "TargetOfTarget: Jandice Barov"},
		{1.23, "PLAYER_REGEN_DISABLED", "+Entering combat!"},
		{1.34, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Nothankies", "TargetOfTarget: Jandice Barov"},
		{1.66, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_PERIODIC_MISSED", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, nil, nil},
		{2.14, "COMBAT_LOG_EVENT_UNFILTERED", "SWING_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 43, -1, 0x0, nil, 24},
		{2.16, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Jazac", "TargetOfTarget: Jandice Barov"},
		{2.26, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Nothankies", "TargetOfTarget: Jandice Barov"},
		{2.50, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_REMOVED", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", nil},
		{2.92, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_APPLIED", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", nil},
		{2.95, "UPDATE_UI_WIDGET", "widgetID:4834, shownState:0"},
		{4.16, "COMBAT_LOG_EVENT_UNFILTERED", "SWING_MISSED", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBDB62F", "Nothankies-Illidan", 0x512, 0x0, "ABSORB", false, 0x0, false, nil},
		{4.66, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_PERIODIC_DAMAGE", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, nil, nil},
		{5.71, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_APPLIED_DOSE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", 2},
		{6.16, "COMBAT_LOG_EVENT_UNFILTERED", "SWING_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBDB62F", "Nothankies-Illidan", 0x512, 0x0, 26, -1, 0x0, nil, nil},
		{6.27, "CHAT_MSG_MONSTER_YELL", "Come, try your luck! Ha ha haaa...", "Jandice Barov", "", "", "", "", 0, 0, "", 0, 154, nil, 0, false, false, false, false},
		{6.76, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Jazac", "TargetOfTarget: Jandice Barov"},
		{7.09, "UNIT_SPELLCAST_SUCCEEDED", "boss1", "Cast-3-3888-1007-7106-113808-0007CB3974", 113808},
		{7.11, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: ??", "TargetOfTarget: ??"},
		{7.12, "UNIT_TARGETABLE_CHANGED", "-nameplate1- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59184-00004B386C", "Classification:elite", "Health:7819]"},
		{7.12, "UNIT_TARGETABLE_CHANGED", "-boss1- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59184-00004B386C", "Classification:elite", "Health:7819]"},
		{7.66, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_PERIODIC_DAMAGE", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, nil, nil},
		{8.51, "UNIT_SPELLCAST_SUCCEEDED", "boss1", "Cast-3-3888-1007-7106-113819-00104B3976", 113819},
		{9.48, "UNIT_SPELLCAST_SUCCEEDED", "nameplate6", "Cast-3-3888-1007-7106-113866-0002CB3977", 113866},
		{9.48, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-00024B3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{9.48, "UNIT_SPELLCAST_SUCCEEDED", "nameplate6", "Cast-3-3888-1007-7106-113777-00034B3977", 113777},
		{9.50, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-00024B3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{9.53, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-00024B3976", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{9.53, "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "Fake Args:", "boss1", false, false, false, "Unknown", "Creature-0-3888-1007-7106-59184-00004B386C", "normal", 0, "boss2", false, false, false, "??", nil, "normal", 0, "boss3", false, false, false, "??", nil, "normal", 0, "boss4", false, false, false, "??", nil, "normal", 0, "boss5", false, false, false, "??", nil, "normal", 0, "Real Args:"},
		{9.53, "UNIT_TARGETABLE_CHANGED", "-nameplate6- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59220-00024B3976", "Classification:elite", "Health:0]"},
		{10.66, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_PERIODIC_MISSED", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, nil, nil},
		{10.74, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-0002CB3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{10.76, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-0002CB3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{10.77, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-0002CB3976", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{10.93, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-121-0ACD4EE6", "Jungwee", 0x511, 0x0, 113775, "Whirl of Illusion", 0x0, nil, nil},
		{11.18, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-0003CB3976", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{11.37, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: ??", "TargetOfTarget: ??"},
		{11.37, "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "Fake Args:", "boss1", true, true, true, "Jandice Barov", "Creature-0-3888-1007-7106-59184-00004B386C", "elite", 7779, "boss2", false, false, false, "??", nil, "normal", 0, "boss3", false, false, false, "??", nil, "normal", 0, "boss4", false, false, false, "??", nil, "normal", 0, "boss5", false, false, false, "??", nil, "normal", 0, "Real Args:"},
		{11.37, "UNIT_TARGETABLE_CHANGED", "-boss1- [CanAttack:true", "Exists:true", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59184-00004B386C", "Classification:elite", "Health:7779]"},
		{12.14, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-00004B3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{12.16, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-00004B3976", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{12.18, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: ??", "TargetOfTarget: ??"},
		{12.16, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-00004B3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{12.43, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-00034B3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{12.43, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-00034B3976", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{12.43, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-00034B3976", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{13.66, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_PERIODIC_DAMAGE", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, nil, nil},
		{13.66, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_REMOVED", "Creature-0-3888-1007-7106-59501-00004B386D", "Reanimated Corpse", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 114493, "Dark Plague", 0x0, "DEBUFF", nil},
		{13.74, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_APPLIED_DOSE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", 3},
		{13.74, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_REFRESH", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", nil},
		{14.60, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Jazac", "TargetOfTarget: ??"},
		{16.34, "COMBAT_LOG_EVENT_UNFILTERED", "SWING_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 65, -1, 0x0, nil, nil},
		{18.34, "COMBAT_LOG_EVENT_UNFILTERED", "SWING_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 94, -1, 0x0, nil, 19},
		{20.34, "COMBAT_LOG_EVENT_UNFILTERED", "SWING_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-3721-0C383D35", "Jazac-Nagrand", 0x512, 0x0, 100, -1, 0x0, nil, nil},
		{20.85, "CHAT_MSG_MONSTER_YELL", "Feeling a bit... dizzy?", "Jandice Barov", "", "", "", "", 0, 0, "", 0, 155, nil, 0, false, false, false, false},
		{21.68, "UNIT_SPELLCAST_SUCCEEDED", "boss1", "Cast-3-3888-1007-7106-113808-00024B3983", 113808},
		{21.68, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: ??", "TargetOfTarget: ??"},
		{21.68, "UNIT_TARGETABLE_CHANGED", "-nameplate1- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59184-00004B386C", "Classification:elite", "Health:2152]"},
		{21.68, "UNIT_TARGETABLE_CHANGED", "-boss1- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59184-00004B386C", "Classification:elite", "Health:2152]"},
		{23.10, "UNIT_SPELLCAST_SUCCEEDED", "boss1", "Cast-3-3888-1007-7106-113819-000B4B3985", 113819},
		{23.74, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_REMOVED", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", nil},
		{24.13, "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "Fake Args:", "boss1", false, false, false, "Unknown", "Creature-0-3888-1007-7106-59184-00004B386C", "normal", 0, "boss2", false, false, false, "??", nil, "normal", 0, "boss3", false, false, false, "??", nil, "normal", 0, "boss4", false, false, false, "??", nil, "normal", 0, "boss5", false, false, false, "??", nil, "normal", 0, "Real Args:"},
		{24.16, "UNIT_SPELLCAST_SUCCEEDED", "nameplate8", "Cast-3-3888-1007-7106-113866-00044B3986", 113866},
		{24.16, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-00024B3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{24.16, "UNIT_SPELLCAST_SUCCEEDED", "nameplate8", "Cast-3-3888-1007-7106-113777-0004CB3986", 113777},
		{24.18, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-00024B3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{24.19, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-00024B3985", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{24.20, "UNIT_TARGETABLE_CHANGED", "-nameplate8- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59220-00024B3985", "Classification:elite", "Health:0]"},
		{24.61, "UNIT_SPELLCAST_SUCCEEDED", "nameplate6", "Cast-3-3888-1007-7106-113866-0000CB3987", 113866},
		{24.61, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-0003CB3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{24.61, "UNIT_SPELLCAST_SUCCEEDED", "nameplate6", "Cast-3-3888-1007-7106-113777-00014B3987", 113777},
		{24.61, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-0003CB3985", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{24.61, "UNIT_TARGETABLE_CHANGED", "-nameplate6- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59220-0003CB3985", "Classification:elite", "Health:0]"},
		{24.61, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-0003CB3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{25.58, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_AURA_APPLIED", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-57-0DBC35E2", "Moplius-Illidan", 0x512, 0x0, 443503, "Lightning Rod", 0x0, "BUFF", nil},
		{25.95, "UNIT_SPELLCAST_SUCCEEDED", "nameplate4", "Cast-3-3888-1007-7106-114001-0002CB3988", 114001},
		{25.95, "UNIT_SPELLCAST_SUCCEEDED", "nameplate4", "Cast-3-3888-1007-7106-113777-00034B3988", 113777},
		{25.72, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, "Player-3726-0C387243", "Caldera-Aman'Thul", 0x512, 0x0, 113775, "Whirl of Illusion", 0x0, nil, nil},
		{25.97, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-00034B3985", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{25.97, "UNIT_TARGETABLE_CHANGED", "-nameplate4- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59220-00034B3985", "Classification:elite", "Health:0]"},
		{26.00, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: ??", "TargetOfTarget: ??"},
		{26.00, "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "Fake Args:", "boss1", true, true, true, "Jandice Barov", "Creature-0-3888-1007-7106-59184-00004B386C", "elite", 2129, "boss2", false, false, false, "??", nil, "normal", 0, "boss3", false, false, false, "??", nil, "normal", 0, "boss4", false, false, false, "??", nil, "normal", 0, "boss5", false, false, false, "??", nil, "normal", 0, "Real Args:"},
		{26.00, "UNIT_TARGETABLE_CHANGED", "-boss1- [CanAttack:true", "Exists:true", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59184-00004B386C", "Classification:elite", "Health:2129]"},
		{26.74, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: ??", "TargetOfTarget: ??"},
		{26.89, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-0000CB3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{26.89, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-0000CB3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{26.92, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-0000CB3985", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{27.39, "UNIT_SPELLCAST_SUCCEEDED", "nameplate3", "Cast-3-3888-1007-7106-113866-0009CB3989", 113866},
		{27.39, "UNIT_SPELLCAST_SUCCEEDED", "target", "Cast-3-3888-1007-7106-113866-0009CB3989", 113866},
		{27.39, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_CAST_SUCCESS", "Creature-0-3888-1007-7106-59220-00014B3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{27.39, "UNIT_SPELLCAST_SUCCEEDED", "nameplate3", "Cast-3-3888-1007-7106-113777-000A4B3989", 113777},
		{27.39, "UNIT_SPELLCAST_SUCCEEDED", "target", "Cast-3-3888-1007-7106-113777-000A4B3989", 113777},
		{27.40, "COMBAT_LOG_EVENT_UNFILTERED", "UNIT_DIED", "", nil, 0x0, 0x0, "Creature-0-3888-1007-7106-59220-00014B3985", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{27.40, "COMBAT_LOG_EVENT_UNFILTERED", "SPELL_DAMAGE", "Creature-0-3888-1007-7106-59220-00014B3985", "Jandice Barov", 0xa48, 0x0, "", nil, 0x0, 0x0, 113866, "Flash Bang", 0x0, nil, nil},
		{27.41, "UNIT_TARGETABLE_CHANGED", "-nameplate3- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59220-00014B3985", "Classification:elite", "Health:0]"},
		{27.41, "UNIT_TARGETABLE_CHANGED", "-softenemy- [CanAttack:false", "Exists:false", "IsVisible:true", "Name:Jandice Barov", "GUID:Creature-0-3888-1007-7106-59220-00014B3985", "Classification:elite", "Health:0]"},
		{29.19, "UNIT_TARGET", "boss1", "Jandice Barov", "Target: Jazac", "TargetOfTarget: Jandice Barov"},
		{29.42, "UNIT_SPELLCAST_SUCCEEDED", "boss1", "Cast-3-3888-1007-7106-114047-0005CB398B", 114047},
		{29.42, "COMBAT_LOG_EVENT_UNFILTERED", "PARTY_KILL", "Player-57-0DBDB62F", "Nothankies-Illidan", 0x512, 0x0, "Creature-0-3888-1007-7106-59184-00004B386C", "Jandice Barov", 0xa48, 0x0, -1, false, 0x0, nil, nil},
		{29.43, "ENCOUNTER_END", 1427, "Jandice Barov", 1, 5, 1},
	},
}