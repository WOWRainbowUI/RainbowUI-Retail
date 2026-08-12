if select(4, GetBuildInfo()) ~= 120007 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Midnight
local Category = BtWQuests.Constant.Category.Midnight
local Chain = BtWQuests.Constant.Chain.Midnight
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local LEVEL_RANGE = {80, 90}
local ACHIEVEMENT_ID = 62413

Chain.LegacyOfTheAmani = 120601
Chain.AnIslandOfFangs = 120602
Chain.GhostsOfThePast = 120603
Chain.OriginalSin = 120604
Chain.TheBattleForAtalUtek = 120605

Database:AddChain(Chain.LegacyOfTheAmani, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 6050,
    expansion = EXPANSION_ID,
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
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = 6229,
    expansion = EXPANSION_ID,
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
        ids = { 90690, 88709, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 92520,
    },
    items = {
        
     }
})
Database:AddChain(Chain.GhostsOfThePast, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 6230,
    expansion = EXPANSION_ID,
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
        id = 88920,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 88942,
    },
    items = {
    }
})
Database:AddChain(Chain.OriginalSin, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 6231,
    expansion = EXPANSION_ID,
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
        id = 88769,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 88769,
    },
    items = {
    }
})
Database:AddChain(Chain.TheBattleForAtalUtek, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 6232,
    expansion = EXPANSION_ID,
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
BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.LegacyOfTheAmani,
    },
    -- {
    --     type = "chain",
    --     id = Chain.AnIslandOfFangs,
    -- },
    -- {
    --     type = "chain",
    --     id = Chain.GhostsOfThePast,
    -- },
    -- {
    --     type = "chain",
    --     id = Chain.OriginalSin,
    -- },
    -- {
    --     type = "chain",
    --     id = Chain.TheBattleForAtalUtek,
    -- },
})
