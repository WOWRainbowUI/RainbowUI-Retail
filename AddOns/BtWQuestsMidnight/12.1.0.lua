if select(4, GetBuildInfo()) < 120100 then
    return
end

local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Midnight
local CATEGORY_ID = BtWQuests.Constant.Category.Midnight.CurseOfUlatek
local Chain = BtWQuests.Constant.Chain.Midnight.CurseOfUlatek
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 2512
local CONTINENT_ID = 2537
local LEVEL_RANGE = {80, 90}
local ACHIEVEMENT_ID_1 = select(4, GetBuildInfo()) == 120007 and 62413 or 62297
local ACHIEVEMENT_ID_2 = 63641

Chain.LegacyOfTheAmani = 120601
Chain.AnIslandOfFangs = 120602
Chain.GhostsOfThePast = 120603
Chain.OriginalSin = 120604
Chain.TheBattleForAtalUtek = 120605
Chain.TheCallOfTheVoid = 120606

Chain.StrangeFriendsInOddPlaces = 120611
Chain.TokkasCrew = 120612
Chain.AncientAnthropology = 120613
Chain.BoneDeep = 120614
Chain.TheHonoredMedjai = 120615
Chain.DontBeAfrayed = 120616
Chain.ABondOfBrothers = 120617
Chain.TheTroublesOfMlurkkrMire = 120618
Chain.SomethinBadInside = 120619
Chain.LivingLegend = 120620
Chain.TheMonstersMother = 120621

Chain.Chain01 = 120631

Chain.OtherAlliance = 120697
Chain.OtherHorde = 120698
Chain.OtherBoth = 120699

Database:AddChain(Chain.LegacyOfTheAmani, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 6050,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Midnight.Voidstorm.DawnOfReckoning,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
    },
    active = {
        type = "quest",
        ids = { 92897, 92895 },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 93012,
    },
    items = {
        {
            variations = {
                { -- The Preparations Are Complete
                    type = "quest",
                    id = 92897,
                    restrictions = { -- The Preparations Are Complete
                        type = "quest",
                        id = 92897,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 253640,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Hagar's Invitation
            type = "quest",
            id = 92895,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- History Lesson
            type = "quest",
            id = 92899,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Favor for Kinduru
            type = "quest",
            id = 92900,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Revisionist History
            type = "quest",
            id = 92901,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Return to Zul'Aman
            type = "quest",
            id = 92904,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Amani Answers
            type = "quest",
            id = 92907,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Tablets of Numazon
            type = "quest",
            id = 92955,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- There's the Rub
            type = "quest",
            id = 92957,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Brain Drain
            type = "quest",
            id = 92958,
            connections = {
                1, 
            },
        },
        { -- Mission to Maisara
            type = "quest",
            id = 92952,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Memories of Malacrass
            type = "quest",
            id = 92953,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Digging Deeper
            type = "quest",
            id = 92951,
            connections = {
                1, 
            },
        },
        { -- Maisara Caverns: Master of Souls
            type = "quest",
            id = 92954,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Serpent Shrine
            type = "quest",
            id = 93010,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Legacy of the Amani
            type = "quest",
            id = 93011,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Dead End
            type = "quest",
            id = 93012,
            x = 0,
        },
    }
})
Database:AddChain(Chain.AnIslandOfFangs, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 6229,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Midnight.Voidstorm.DawnOfReckoning,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheAmani,
        },
    },
    active = {
        type = "quest",
        ids = { 98218, 92916, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 93024,
    },
    items = {
        {
            variations = {
                { -- Return to Amani'Zar
                    type = "quest",
                    id = 98218,
                    restrictions = { -- Return to Amani'Zar
                        type = "quest",
                        id = 98218,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 263331,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Call for Aid
            type = "quest",
            id = 92916,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Saving Those Bound
            type = "quest",
            id = 92917,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- All Bark, All Bite
            type = "quest",
            id = 92919,
            connections = {
                1, 
            },
        },
        { -- Severing the Serpent's Head
            type = "quest",
            id = 93265,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- To the Skybridge
            type = "quest",
            id = 92921,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- It Just Had to Be...
            type = "quest",
            id = 93263,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Drumming Up the Troops
            type = "quest",
            id = 93266,
            connections = {
                1, 
            },
        },
        { -- Down With the Skies
            type = "quest",
            id = 92920,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- What Lies Beyond the Fog
            type = "quest",
            id = 92924,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Children of Ula'tek
            type = "quest",
            id = 95804,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Situation Normal, All Snaked Up
            type = "quest",
            id = 93019,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- The Serpent's Tail
            type = "quest",
            id = 95564,
            connections = {
                1, 2, 
            },
        },
        { -- Them That Were Lost
            type = "quest",
            id = 93018,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Fire, the Only Way to Be Sure
            type = "quest",
            id = 93022,
            connections = {
                1, 
            },
        },
        { -- Death of Furies
            type = "quest",
            id = 93023,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Come With Me
            type = "quest",
            id = 93024,
            x = 0,
        },
    }
})
Database:AddChain(Chain.GhostsOfThePast, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 6230,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Midnight.Voidstorm.DawnOfReckoning,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheAmani,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnIslandOfFangs,
        },
    },
    active = {
        type = "quest",
        id = 93454,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 92930,
    },
    items = {
        {
            type = "npc",
            id = 258859,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Words to Hear
            type = "quest",
            id = 93454,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Glint of History
            type = "quest",
            id = 92925,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Echoed Steps
            type = "quest",
            id = 92927,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- What Was Buried
            type = "quest",
            id = 92928,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Lurking in the Dark
            type = "quest",
            id = 92929,
            connections = {
                1, 
            },
        },
        { -- Written by the Victors
            type = "quest",
            id = 92930,
            x = 0,
        },
    }
})
Database:AddChain(Chain.OriginalSin, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 6231,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Midnight.Voidstorm.DawnOfReckoning,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheAmani,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnIslandOfFangs,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GhostsOfThePast,
        },
    },
    active = {
        type = "quest",
        id = 92931,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 92937,
    },
    items = {
        {
            type = "npc",
            id = 253827,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Delay the Venom
            type = "quest",
            id = 92931,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Clear the Swamp
            type = "quest",
            id = 92932,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- Haunted Shore
            type = "quest",
            id = 92933,
            connections = {
                1, 2, 
            },
        },
        { -- Site of Terror
            type = "quest",
            id = 92938,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Broken Spears
            type = "quest",
            id = 93063,
            connections = {
                1, 
            },
        },
        { -- Awe of She
            type = "quest",
            id = 93064,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Fuel the Calling
            type = "quest",
            id = 92934,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Pushed to the Brink
            type = "quest",
            id = 92935,
            connections = {
                1, 
            },
        },
        { -- The Summoning of Ula'tek
            type = "quest",
            id = 92936,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Awakened Evil
            type = "quest",
            id = 92937,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheBattleForAtalUtek, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 5),
    questline = 6232,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Midnight.Voidstorm.DawnOfReckoning,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheAmani,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnIslandOfFangs,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GhostsOfThePast,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.OriginalSin,
        },
    },
    active = {
        type = "quest",
        id = 93417,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 93420,
    },
    items = {
        {
            type = "npc",
            id = 253827,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Vaults of Atal'Utek: Altar of Fangs
            type = "quest",
            id = 93417,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Nature of Her Wounds
            type = "quest",
            id = 93419,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Venomous Abyss
            type = "quest",
            id = 93418,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Lor'themar's Judgement
            type = "quest",
            id = 93420,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheCallOfTheVoid, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 6),
    questline = 6121,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Midnight.Voidstorm.DawnOfReckoning,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheAmani,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnIslandOfFangs,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GhostsOfThePast,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.OriginalSin,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBattleForAtalUtek,
        },
    },
    active = {
        type = "quest",
        ids = { 90748, 88710, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 88710,
    },
    items = {
        
    }
})

Database:AddChain(Chain.StrangeFriendsInOddPlaces, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 6276,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 93387,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 93393,
    },
    items = {
        {
            type = "npc",
            id = 263327,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Dealing with Pests
            type = "quest",
            id = 93387,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Unusual Alchemy
            type = "quest",
            id = 93388,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Rocksblood
            type = "quest",
            id = 93389,
            connections = {
                1, 
            },
        },
        { -- Acceptable Apprentice
            type = "quest",
            id = 93390,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Make it Stinky
            type = "quest",
            id = 93391,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Recovering Memories
            type = "quest",
            id = 93392,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Little Kindness
            type = "quest",
            id = 93393,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TokkasCrew, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 6271,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
        {
            type = "chain",
            id = Chain.OriginalSin,
            upto = 92936,
        },
    },
    active = {
        type = "quest",
        ids = { 90748, 88710, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 96111,
    },
    items = {
        {
            type = "npc",
            id = 258755,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Venom Fishing: Proof is in the Ooze
            type = "quest",
            id = 96110,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Venom Fishing: My Second-Best
            type = "quest",
            id = 98343,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                { -- A Request from the Captain
                    type = "quest",
                    id = 98414,
                    restrictions = { -- A Request from the Captain
                        type = "quest",
                        id = 98414,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 258755,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Venom Fishing: Shell of Yourself
            type = "quest",
            id = 96111,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AncientAnthropology, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 6277,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        ids = { 96467, 96469, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 96471,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 96467,
                    restrictions = {
                        type = "quest",
                        id = 96467,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 265329,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 96469,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 96471,
            x = 0,
        },
    },
})
Database:AddChain(Chain.BoneDeep, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    questline = 6114,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        ids = { 94031, 94035, 94036, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 94040,
    },
    items = {
        {
            type = "npc",
            id = 257298,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Bones of My Soul
            type = "quest",
            id = 94031,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- Meat for the Bones
            type = "quest",
            id = 94035,
            connections = {
                2, 
            },
        },
        { -- One Final Prisoner
            type = "quest",
            id = 94036,
            connections = {
                1, 
            },
        },
        { -- Meat and Bone and Soul
            type = "quest",
            id = 94040,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheHonoredMedjai, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    questline = 6227,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 95521,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 95525,
    },
    items = {
        {
            type = "object",
            id = 641565,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Med'jai Medallion
            type = "quest",
            id = 95521,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Guardians of Death, Guardians in Stone
            type = "quest",
            id = 95522,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Worthy of the Past
            type = "quest",
            id = 95523,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- The Unremembered
            type = "quest",
            id = 95524,
            connections = {
                1, 
            },
        },
        { -- An Ancient Foe
            type = "quest",
            id = 95954,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Worthy Vigil
            type = "quest",
            id = 95525,
            x = 0,
        },
    }
})
Database:AddChain(Chain.DontBeAfrayed, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 6123,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 93841,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 93906,
    },
    items = {
        {
            type = "npc",
            id = 258068,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Ghosts of the Ring
            type = "quest",
            id = 93841,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Bloom and Fade
            type = "quest",
            id = 93842,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Ectoplasmic Extractions
            type = "quest",
            id = 93843,
            connections = {
                1, 
            },
        },
        { -- Ectoplasmic Emporium
            type = "quest",
            id = 93849,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Communing with Ghosts
            type = "quest",
            id = 93851,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Untethering the Two
            type = "quest",
            id = 93906,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ABondOfBrothers, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 6329,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 94936,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 94941,
    },
    items = {
        {
            type = "npc",
            id = 258717,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Bond of Brothers
            type = "quest",
            id = 94936,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Too Quiet on the Northern Front
            type = "quest",
            id = 94937,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Saving Recruit Jabat
            type = "quest",
            id = 94941,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheTroublesOfMlurkkrMire, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    questline = 6118,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 93449,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 93340,
    },
    items = {
        {
            type = "npc",
            id = 257091,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Trouble in the Swamp
            type = "quest",
            id = 93449,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Slithering in the Mire
            type = "quest",
            id = 93199,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Fried Eggs
            type = "quest",
            id = 93229,
            connections = {
                1, 
            },
        },
        { -- The Search for Wa'kani
            type = "quest",
            id = 93576,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Ophidia the Broodmother
            type = "quest",
            id = 94447,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Savagery Among the Ruins
            type = "quest",
            id = 93233,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- Trinket Trading
            type = "quest",
            id = 93339,
            connections = {
                2, 
            },
        },
        { -- Scouts in the Swamp
            type = "quest",
            id = 93239,
            connections = {
                1, 
            },
        },
        { -- The Shadow Shard
            type = "quest",
            id = 93340,
            x = 0,
        },
    }
})
Database:AddChain(Chain.SomethinBadInside, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    questline = 6264,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 96089,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 96099,
    },
    items = {
        {
            type = "npc",
            id = 263618,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Somethin's Not Right
            type = "quest",
            id = 96089,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Venemetic
            type = "quest",
            id = 96090,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Get the Balance Right
            type = "quest",
            id = 96091,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- That Fool, Ruma
            type = "quest",
            id = 96092,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- It's a Satchel, Not a Bag
            type = "quest",
            id = 96093,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- To the Forum
            type = "quest",
            id = 96094,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Sampling the Local Wildlife
            type = "quest",
            id = 96095,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Scout Team Seven
            type = "quest",
            id = 96096,
            connections = {
                1, 
            },
        },
        { -- What the Scouts Saw
            type = "quest",
            id = 96097,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Final Reagents
            type = "quest",
            id = 96098,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- La'una's Fate
            type = "quest",
            id = 96099,
            x = 0,
        },
    }
})
Database:AddChain(Chain.LivingLegend, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 6302,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        id = 96523,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 96546,
    },
    items = {
        {
            type = "npc",
            id = 265476,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Living Legend
            type = "quest",
            id = 96523,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Last Resort
            type = "quest",
            id = 96539,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Strong Hands
            type = "quest",
            id = 96540,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Strong Mind
            type = "quest",
            id = 96541,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Root of Survival
            type = "quest",
            id = 96543,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Bravely Burning
            type = "quest",
            id = 96544,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Strong Voice
            type = "quest",
            id = 96545,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Strong Heart
            type = "quest",
            id = 96546,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheMonstersMother, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    questline = 6274,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
        ids = { 96439, 96450, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 96458,
    },
    items = {
        {
            variations = {
                { -- Gone Dark
                    type = "quest",
                    id = 96439,
                    restrictions = { -- Gone Dark
                        type = "quest",
                        id = 96439,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 265194,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Sideways
            type = "quest",
            id = 96450,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Child of Ula'tek
            type = "quest",
            id = 96451,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Nothing Must Remain
            type = "quest",
            id = 96457,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Last Promise
            type = "quest",
            id = 96458,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain01, {
    name = { -- Into the Vaults of Atal'Utek
        type = "quest",
        id = 98388,
    },
    questline = 6274,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 90,
        },
    },
    active = {
        type = "quest",
            id = 98388,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = { 98428, 98515, },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 271885,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Into the Vaults of Atal'Utek
            type = "quest",
            id = 98388,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Vaults of Atal'Utek: One Coin Too Many
            type = "quest",
            id = 97640,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Vaults of Atal'Utek: A Toxic Tour
            type = "quest",
            id = 98515,
        },
        { -- Vaults of Atal'Utek: The Altar of Corrosion
            type = "quest",
            id = 98428,
            x = -1,
        },
    }
})
Database:AddChain(Chain.OtherAlliance, {
    name = "Other Alliance",
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherHorde, {
    name = "Other Horde",
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherBoth, {
    name = "Other Both",
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    items = {
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = L["THE_CURSE_OF_ULATEK"],
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    buttonImage = 7956179,
    items = {
        {
            type = "chain",
            id = Chain.LegacyOfTheAmani,
        },
        {
            type = "chain",
            id = Chain.AnIslandOfFangs,
        },
        {
            type = "chain",
            id = Chain.GhostsOfThePast,
        },
        {
            type = "chain",
            id = Chain.OriginalSin,
        },
        {
            type = "chain",
            id = Chain.TheBattleForAtalUtek,
        },
--[==[@debug@
        {
            type = "chain",
            id = Chain.TheCallOfTheVoid,
        },
--@end-debug@]==]
        {
            type = "chain",
            id = Chain.StrangeFriendsInOddPlaces,
        },
        {
            type = "chain",
            id = Chain.TokkasCrew,
        },
        {
            type = "chain",
            id = Chain.AncientAnthropology,
        },
        {
            type = "chain",
            id = Chain.BoneDeep,
        },
        {
            type = "chain",
            id = Chain.TheHonoredMedjai,
        },
        {
            type = "chain",
            id = Chain.DontBeAfrayed,
        },
        {
            type = "chain",
            id = Chain.ABondOfBrothers,
        },
        {
            type = "chain",
            id = Chain.TheTroublesOfMlurkkrMire,
        },
        {
            type = "chain",
            id = Chain.SomethinBadInside,
        },
        {
            type = "chain",
            id = Chain.LivingLegend,
        },
        {
            type = "chain",
            id = Chain.TheMonstersMother,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
--[==[@debug@
        {
            type = "chain",
            id = Chain.OtherAlliance,
        },
        {
            type = "chain",
            id = Chain.OtherHorde,
        },
        {
            type = "chain",
            id = Chain.OtherBoth,
        },
--@end-debug@]==]
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})

