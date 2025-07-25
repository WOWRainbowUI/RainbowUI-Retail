-------------------------------------------------------------------------------
---------------------------------- NAMESPACE ----------------------------------
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.locale

local Class = ns.Class
local Group = ns.Group

local Collectible = ns.node.Collectible

local Achievement = ns.reward.Achievement

-------------------------------------------------------------------------------

ns.expansion = 11

-------------------------------------------------------------------------------
----------------------------------- GROUPS ------------------------------------
-------------------------------------------------------------------------------

ns.groups.DELVE_REWARDS = Group('delve_rewards', 4203076, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION,
    HasEnabledNodes = function() return true end
})

ns.groups.DISTURBED_EARTH = Group('disturbed_earth', 132386, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

ns.groups.PROFESSION_TREASURES = Group('profession_treasures', 4620676, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

ns.groups.RATTS_REVENGE = Group('ratts_revenge', 5370377, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

ns.groups.SCRAP_REWARDS = ns.Group('scrap_rewards', 5768266, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

ns.groups.SKYRIDING_GLYPH = Group('skyriding_glyph', 4728198, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

ns.groups.WORLDSOUL_MEMORIES = Group('worldsoul_memories', 2967105, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

-------------------------------------------------------------------------------

ns.groups.BACK_TO_THE_WALL = Group('back_to_the_wall', 236681, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40620
})

ns.groups.BEACON_OF_HOPE = Group('beacon_of_hope', 135922, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40308
})

ns.groups.BIBLO_ARCHIVIST = Group('biblo_archivist', 5341597, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40622
})

ns.groups.BOOKWORM = Group('bookworm', 4549129, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40629
})

ns.groups.FIGHTER = Group('fighter', 135945, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 41999
})

ns.groups.FLAMEGARDS_HOPE = Group('flamegards_hope', 463526, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 20594
})

ns.groups.FLAT_EARTHEN = Group('flat_earthen', 4620670, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40606
})

ns.groups.FLIGHT_MASTER = Group('flight_master', 'flight_point_y', {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40430
})

ns.groups.FOR_THE_COLLECTIVE = Group('for_the_collective', 975747, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40630
})

ns.groups.GOBBLIN_WITH_GLUBLURP = Group('gobblin_with_glublurp', 5763494, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40614
})

ns.groups.ITSY_BITSY_SPIDER = Group('itsy_bitsy_spider', 5793405, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40624
})
ns.groups.I_ONLY_NEED_ONE_TRIP = Group('i_only_need_one_trip', 236316, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40623
})

ns.groups.KHAZ_ALGAR_LORE_HUNTER = Group('khaz_algar_lore_hunter', 4419344, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40762
})

ns.groups.CAN_DO_ATTITUDE = Group('can_do_attitude', 236996, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 41589
})

ns.groups.LOST_AND_FOUND = Group('lost_and_found', 4635200, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40618
})

ns.groups.MERELDAR_MENACE = Group('mereldar_menace', 135232, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40151
})

ns.groups.MISSING_LYNX = Group('missing_lynx', 5689905, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40625
})

ns.groups.NINE_TENTHS = Group('nine_tenths', 2201832, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40948
})

ns.groups.NO_HARM_FROM_READING = Group('no_harm_from_reading', 463284, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40632
})

ns.groups.NOT_SO_QUICK_FIX = Group('not_so_quick_fix', 134067, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40473
})

ns.groups.NOTABLE_MACHINES = Group('notable_machines', 1506451, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40628
})

ns.groups.BETWEEN_THE_LINES = Group('between_the_lines', 4549129, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 41588
})

ns.groups.ROCKED_TO_SLEEP = Group('rocked_to_sleep', 5788303, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40504
})

ns.groups.RUNED_STORM_CHEST = Group('runed_storm_chest', 'chest_rd', {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 41131
})

-- ns.groups.SAFARI = Group('safari', 4048818, {
--     defaults = ns.GROUP_HIDDEN,
--     type = ns.group_types.ACHIEVEMENT,
--     achievement = 40194
-- })

ns.groups.SECRETS_OF_AZEROTH = Group('secrets_of_azeroth', 'peg_gn', {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.EXPANSION
})

ns.groups.SKITTERSHAW_SPIN = Group('skittershaw_spin', 879828, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40727
})

ns.groups.SMELLING_HISTORY = Group('smelling_history', 4549130, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40542
})

ns.groups.THE_UNSEEMING = Group('the_unseeming', 1386549, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40633
})

ns.groups.YOU_CANT_HANG_WITH_US = Group('you_cant_hang_with_us', 5763494, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40634
})

ns.groups.YOURE_MY_FRIEND_NOW = Group('youre_my_friend_now', 6351952, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 41708
})

ns.groups.CRITTER_LOVE = Group('critter_love', 3459801, {
    defaults = ns.GROUP_HIDDEN,
    type = ns.group_types.ACHIEVEMENT,
    achievement = 40475
})

-------------------------------------------------------------------------------
---------------------------- KHAZ ALGAR LORE HUNTER ---------------------------
-------------------------------------------------------------------------------

local LoreObject = Class('LoreObject', Collectible, {
    icon = 4419344,
    group = ns.groups.KHAZ_ALGAR_LORE_HUNTER
})

ns.node.LoreObject = LoreObject

-------------------------------------------------------------------------------
------------------------------- SKYRIDING GLYPH -------------------------------
-------------------------------------------------------------------------------

local SkyridingGlyph = Class('SkyridingGlyph', Collectible, {
    icon = 4728198,
    label = L['skyriding_glyph'],
    group = ns.groups.SKYRIDING_GLYPH
})

ns.node.SkyridingGlyph = SkyridingGlyph

-------------------------------------------------------------------------------
----------------------------- PROFESSION TREASURES ----------------------------
-------------------------------------------------------------------------------

local ProfessionMaster = Class('ProfessionMaster', ns.node.NPC, {
    scale = 0.9,
    group = ns.groups.PROFESSION_TREASURES
})

function ProfessionMaster:IsEnabled()
    if not ns.PlayerHasProfession(self.skillID) then return false end
    return ns.node.NPC.IsEnabled(self)
end

local ProfessionTreasure = Class('ProfessionTreasure', ns.node.Item, {
    scale = 0.9,
    group = ns.groups.PROFESSION_TREASURES
})

function ProfessionTreasure:IsEnabled()
    if not ns.PlayerHasProfession(self.skillID) then return false end
    return ns.node.Item.IsEnabled(self)
end

ns.node.ProfessionMasters = {}
ns.node.ProfessionTreasures = {}

local PM = ns.node.ProfessionMasters
local PT = ns.node.ProfessionTreasures

for _, profession in pairs(ns.professions) do
    if profession.variantID ~= nil then
        local name = profession.name
        local icon = profession.icon
        local skillID = profession.skillID
        local variantID = profession.variantID[11]

        PM[name] = Class(name .. 'Master', ProfessionMaster, {
            icon = icon,
            skillID = skillID,
            requires = ns.requirement.Profession(skillID, variantID, 1)
        })

        PT[name] = Class(name .. 'Treasure', ProfessionTreasure, {
            icon = icon,
            skillID = skillID,
            requires = ns.requirement.Profession(skillID, variantID, 1)
        })
    end
end

-------------------------------------------------------------------------------
-------------------------------- DISTURBED DIRT -------------------------------
-------------------------------------------------------------------------------

ns.node.DisturbedEarth = Class('Disturbed_earth', ns.node.Node, {
    icon = 132386,
    scale = 0.7,
    label = '{npc:213440}',
    group = ns.groups.DISTURBED_EARTH,
    requires = {ns.requirement.Reputation(2594, 2, true)}, -- Assembly of the Deeps Renown 2
    rewards = {
        ns.reward.Item({item = 212493}), -- Odd Glob of Wax
        Achievement({id = 40585, criteria = {id = 1, qty = true}}) -- Super Size Snuffling
    }
}) -- Disturbed Earth

-------------------------------------------------------------------------------
-------------------- ACHIEVEMENT: KHAZ ALGAR FLIGHT MASTER --------------------
-------------------------------------------------------------------------------

local FlightMaster = Class('FlightMaster', Collectible, {
    icon = 'flight_point_y',
    scale = 2,
    group = ns.groups.FLIGHT_MASTER
}) -- Flight Point

ns.node.FlightMaster = FlightMaster

-------------------------------------------------------------------------------
-------------------- ACHIEVEMENT: FIGHTER OF THE NIGHTMAN ---------------------
-------------------------------------------------------------------------------

local SuspiciousDocument = Collectible({
    label = L['suspicious_document_label'],
    icon = 'peg_bl',
    scale = 1.5,
    note = L['suspicious_document_note'],
    group = ns.groups.FIGHTER
})

ns.node.SuspiciousDocument = SuspiciousDocument

-------------------------------------------------------------------------------
----------------------------- WORLDSOUL MEMORIES ------------------------------
-------------------------------------------------------------------------------

local WORLDSOUL_AREA_POIS = {
    [7833] = {
        Achievement({id = 40252, criteria = 67594}), -- Descendants of Distant Waters
        Achievement({id = 40314, criteria = 68241}), -- Echoing Fragment: Hallowfall
        Achievement({id = 40222, criteria = {67512, 67513, 67514, 67515, 67516}}) -- Echoes of Danger
    },
    [7834] = {
        Achievement({id = 40252, criteria = 67593}), -- Reign of The Old Gods
        Achievement({id = 40314, criteria = 68241}), -- Echoing Fragment: Hallowfall
        Achievement({id = 40222, criteria = {67509, 67510, 67507, 67508, 67511}}) -- Echoes of Danger
    },
    [7835] = {
        Achievement({id = 40252, criteria = 67595}), -- Elemental Fury
        Achievement({id = 40314, criteria = 68257}), -- Echoing Fragment: The Ringing Deeps
        Achievement({id = 40222, criteria = {67523, 67524, 67525, 67526, 67527}}) -- Echoes of Danger
    },
    [7836] = {
        Achievement({id = 40252, criteria = 67596}), -- Primal Predators
        Achievement({id = 40314, criteria = 68257}), -- Echoing Fragment: The Ringing Deeps
        Achievement({id = 40222, criteria = {67517, 67518, 67519, 67520, 67521}}) -- Echoes of Danger
    },
    [7837] = {
        Achievement({id = 40252, criteria = 67589}), -- Ancient Explorers
        Achievement({id = 40314, criteria = 68256}), -- Echoing Fragment: Isle of Dorn
        Achievement({id = 40222, criteria = {67528, 67529, 67530, 67531, 67532}}) -- Echoes of Danger
    },
    [7838] = {
        Achievement({id = 40252, criteria = 67590}), -- The Worldcarvers
        Achievement({id = 40314, criteria = 68256}), -- Echoing Fragment: Isle of Dorn
        Achievement({id = 40222, criteria = {67534, 67535, 67540, 67541}}) -- Echoes of Danger
    },
    [7839] = {
        Achievement({id = 40252, criteria = 67591}), -- Old Gods Forsaken
        Achievement({id = 40314, criteria = 68258}), -- Echoing Fragment: Azj-Kahet
        Achievement({id = 40222, criteria = {67544, 67545, 67546, 67547, 67548}}) -- Echoes of Danger
    },
    [7840] = {
        Achievement({id = 40252, criteria = 67592}), -- A Wounded Soul
        Achievement({id = 40314, criteria = 68258}), -- Echoing Fragment: Azj-Kahet
        Achievement({id = 40222, criteria = {67549, 67550, 67552, 67553}}) -- Echoes of Danger
    },
    [8200] = {
        Achievement({id = 41214, criteria = 71579}), -- Early Cartel Wars
        Achievement({id = 41215, criteria = {71581, 71582, 71583, 71584, 71585}}) -- Echoes of Deeper Dangers
    },
    [8201] = {
        Achievement({id = 41214, criteria = 71580}), -- Kaja'mite Contact
        Achievement({id = 41215, criteria = {71586, 71587, 71588, 71589, 71590}}) -- Echoes of Deeper Dangers
    }
}

local WorldsoulMemory = Class('WorldsoulMemory', Collectible, {
    icon = 2967105,
    group = ns.groups.WORLDSOUL_MEMORIES
}) -- Worldsoul Memory

function WorldsoulMemory.getters:rewards()
    return WORLDSOUL_AREA_POIS[self.areaPoiID]
end

ns.node.WorldsoulMemory = WorldsoulMemory

ns.hooks.areapoievent.Add(ns.groups.WORLDSOUL_MEMORIES, WORLDSOUL_AREA_POIS)

-------------------------------------------------------------------------------
------------------------------ KHAZ ALGAR SAFARI ------------------------------
-------------------------------------------------------------------------------

-- local Safari = Class('Safari', Collectible,
--     {icon = 'paw_g', group = ns.groups.SAFARI}) -- Khaz Algar Safari

-- ns.node.Safari = Safari

-- map.nodes[0000] = Safari({
--     id = 222071,
--     rewards = {Achievement({id = 40194, criteria = 67292}), Pet({id = 4457})}
--     -- pois = {POI({0000})}
-- }) -- Chitin Burrower

-- map.nodes[0000] = Safari({
--     id = 222613,
--     rewards = {Achievement({id = 40194, criteria = 67294}), Pet({id = 4514})}
--     -- pois = {POI({0000})}
-- }) -- Fallowspark Glowfly

-- map.nodes[0000] = Safari({
--     id = 222615,
--     rewards = {Achievement({id = 40194, criteria = 67296}), Pet({id = 4516})}
--     -- pois = {POI({0000})}
-- }) -- Vibrant Glowfly

-- map.nodes[0000] = Safari({
--     id = 222344,
--     rewards = {Achievement({id = 40194, criteria = 67298}), Pet({id = 4477})}
--     -- pois = {POI({0000})}
-- }) -- Verdant Scootlefish

-- map.nodes[0000] = Safari({
--     id = 222351,
--     rewards = {Achievement({id = 40194, criteria = 67300}), Pet({id = 4480})}
--     -- pois = {POI({0000})}
-- }) -- Shadowy Oozeling

-- map.nodes[0000] = Safari({
--     id = 222582,
--     rewards = {Achievement({id = 40194, criteria = 67302}), Pet({id = 4498})}
--     -- pois = {POI({0000})}
-- }) -- Ebon Ploughworm

-- map.nodes[0000] = Safari({
--     id = 222195,
--     rewards = {Achievement({id = 40194, criteria = 67304}), Pet({id = 4460})}
--     -- pois = {POI({0000})}
-- }) -- Arathi Chicken

-- map.nodes[0000] = Safari({
--     id = 222877,
--     rewards = {Achievement({id = 40194, criteria = 67306}), Pet({id = 4535})}
--     -- pois = {POI({0000})}
-- }) -- Ghostcap Menace

-- map.nodes[0000] = Safari({
--     id = 222421,
--     rewards = {Achievement({id = 40194, criteria = 67308}), Pet({id = 4483})}
--     -- pois = {POI({0000})}
-- }) -- Vile Bloodtick

-- map.nodes[0000] = Safari({
--     id = 222499,
--     rewards = {Achievement({id = 40194, criteria = 67310}), Pet({id = 4485})}
--     -- pois = {POI({0000})}
-- }) -- Mossy Snail

-- map.nodes[0000] = Safari({
--     id = 222739,
--     rewards = {Achievement({id = 40194, criteria = 67312}), Pet({id = 4522})}
--     -- pois = {POI({0000})}
-- }) -- Troglofrog

-- map.nodes[0000] = Safari({
--     id = 222775,
--     rewards = {Achievement({id = 40194, criteria = 67314}), Pet({id = 4526})}
--     -- pois = {POI({0000})}
-- }) -- Sandstone Mosswool

-- map.nodes[0000] = Safari({
--     id = 223136,
--     rewards = {Achievement({id = 40194, criteria = 67316}), Pet({id = 4544})}
--     -- pois = {POI({0000})}
-- }) -- Umbral Amalgam

-- map.nodes[0000] = Safari({
--     id = 223094,
--     rewards = {Achievement({id = 40194, criteria = 67318}), Pet({id = 4538})}
--     -- pois = {POI({0000})}
-- }) -- Cobalt Ramolith

-- map.nodes[0000] = Safari({
--     id = 223092,
--     rewards = {Achievement({id = 40194, criteria = 67320}), Pet({id = 4540})}
--     -- pois = {POI({0000})}
-- }) -- Alabaster Stonecharger

-- map.nodes[0000] = Safari({
--     id = 223698,
--     rewards = {Achievement({id = 40194, criteria = 68270}), Pet({id = 4577})}
--     -- pois = {POI({0000})}
-- }) -- Cinderhoney Emberstinger

-- map.nodes[0000] = Safari({
--     id = 222066,
--     rewards = {Achievement({id = 40194, criteria = 67293}), Pet({id = 4456})}
--     -- pois = {POI({0000})}
-- }) -- Arachnoid Hatchling

-- map.nodes[0000] = Safari({
--     id = 222614,
--     rewards = {Achievement({id = 40194, criteria = 67295}), Pet({id = 4515})}
--     -- pois = {POI({0000})}
-- }) -- Azure Flickerfly

-- map.nodes[0000] = Safari({
--     id = 222325,
--     rewards = {Achievement({id = 40194, criteria = 67297}), Pet({id = 4471})}
--     -- pois = {POI({0000})}
-- }) -- Aubergine Scootlefish

-- map.nodes[0000] = Safari({
--     id = 222354,
--     rewards = {Achievement({id = 40194, criteria = 67299}), Pet({id = 4481})}
--     -- pois = {POI({0000})}
-- }) -- Voidling Ooze

-- map.nodes[0000] = Safari({
--     id = 222584,
--     rewards = {Achievement({id = 40194, criteria = 67301}), Pet({id = 4499})}
--     -- pois = {POI({0000})}
-- }) -- Common Ploughworm

-- map.nodes[0000] = Safari({
--     id = 222194,
--     rewards = {Achievement({id = 40194, criteria = 67303}), Pet({id = 4461})}
--     -- pois = {POI({0000})}
-- }) -- Greenlands Chicken

-- map.nodes[0000] = Safari({
--     id = 222875,
--     rewards = {Achievement({id = 40194, criteria = 67305}), Pet({id = 4533})}
--     -- pois = {POI({0000})}
-- }) -- Meek Bloodlasher

-- map.nodes[0000] = Safari({
--     id = 222608,
--     rewards = {Achievement({id = 40194, criteria = 67307}), Pet({id = 4510})}
--     -- pois = {POI({0000})}
-- }) -- Winged Arachnoid

-- map.nodes[0000] = Safari({
--     id = 222713,
--     rewards = {Achievement({id = 40194, criteria = 67309}), Pet({id = 4518})}
--     -- pois = {POI({0000})}
-- }) -- Magmashell Crawler

-- map.nodes[0000] = Safari({
--     id = 222736,
--     rewards = {Achievement({id = 40194, criteria = 67311}), Pet({id = 4521})}
--     -- pois = {POI({0000})}
-- }) -- Subterranean Dartwog

-- map.nodes[0000] = Safari({
--     id = 222774,
--     rewards = {Achievement({id = 40194, criteria = 67313}), Pet({id = 4525})}
--     -- pois = {POI({0000})}
-- }) -- Fragrant Stonelamb

-- map.nodes[0000] = Safari({
--     id = 222778,
--     rewards = {Achievement({id = 40194, criteria = 67315}), Pet({id = 4529})}
--     -- pois = {POI({0000})}
-- }) -- Shale Mosswool

-- map.nodes[0000] = Safari({
--     id = 223090,
--     rewards = {Achievement({id = 40194, criteria = 67317}), Pet({id = 4541})}
--     -- pois = {POI({0000})}
-- }) -- Bedrock Stonecharger

-- map.nodes[0000] = Safari({
--     id = 223093,
--     rewards = {Achievement({id = 40194, criteria = 	67319}), Pet({id = 4539})}
--     -- pois = {POI({0000})}
-- }) -- Granite Ramolith

-- map.nodes[0000] = Safari({
--     id = 223715,
--     rewards = {Achievement({id = 40194, criteria = 68269}), Pet({id = 4574})}
--     -- pois = {POI({0000})}
-- }) -- Snuffling
