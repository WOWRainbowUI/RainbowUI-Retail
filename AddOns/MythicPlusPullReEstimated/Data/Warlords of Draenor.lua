local _, ns = ...

local data = {};
tinsert(ns.data, data)

function data:GetPatchVersion()
    return {
        timestamp = 1726594067,
        version = '11.0.2',
        build = 56625,
    }
end

function data:GetDungeonOverrides()
    return {
        [166] = { -- Grimrail Depot
            [189878] = { ["name"] = "Nathrezim Infiltrator", ["count"] = 6 },
            [190128] = { ["name"] = "Zul'gamux", ["count"] = 18 },
        },
        [169] = { -- Iron Docks
            [189878] = { ["name"] = "Nathrezim Infiltrator", ["count"] = 4 },
            [190128] = { ["name"] = "Zul'gamux", ["count"] = 12 },
        },
    }
end

function data:GetNPCData()
    -- data is sorted with natural sorting by NPC ID
    return {
        [75451] = { ["name"] = "Defiled Spirit", ["count"] = 3 },
        [75459] = { ["name"] = "Plagued Bat", ["count"] = 5 },
        [75506] = { ["name"] = "Shadowmoon Loyalist", ["count"] = 5 },
        [75652] = { ["name"] = "Void Spawn", ["count"] = 10 },
        [75713] = { ["name"] = "Shadowmoon Bone-Mender", ["count"] = 6 },
        [75715] = { ["name"] = "Reanimated Ritual Bones", ["count"] = 5 },
        [76104] = { ["name"] = "Monstrous Corpse Spider", ["count"] = 6 },
        [76444] = { ["name"] = "Subjugated Soul", ["count"] = 4 },
        [76446] = { ["name"] = "Shadowmoon Enslaver", ["count"] = 6 },
        [77006] = { ["name"] = "Corpse Skitterling", ["count"] = 1 },
        [77700] = { ["name"] = "Shadowmoon Exhumer", ["count"] = 8 },
        [80935] = { ["name"] = "Grom'kar Boomer", ["count"] = 7 },
        [80936] = { ["name"] = "Grom'kar Grenadier", ["count"] = 7 },
        [80937] = { ["name"] = "Grom'kar Gunner", ["count"] = 6 },
        [80938] = { ["name"] = "Grom'kar Hulk", ["count"] = 18 },
        [80940] = { ["name"] = "Iron Infantry", ["count"] = 3 },
        [81212] = { ["name"] = "Grimrail Overseer", ["count"] = 7 },
        [81235] = { ["name"] = "Grimrail Laborer", ["count"] = 2 },
        [81236] = { ["name"] = "Grimrail Technician", ["count"] = 4 },
        [81279] = { ["name"] = "Grom'kar Flameslinger", ["count"] = 5 },
        [81283] = { ["name"] = "Grom'kar Footsoldier", ["count"] = 4 },
        [81407] = { ["name"] = "Grimrail Bombardier", ["count"] = 12 },
        [81432] = { ["name"] = "Grom'kar Technician", ["count"] = 4 },
        [81603] = { ["name"] = "Champion Druna", ["count"] = 9 },
        [81819] = { ["name"] = "Everbloom Naturalist", ["count"] = 4 },
        [81820] = { ["name"] = "Everbloom Mender", ["count"] = 4 },
        [81864] = { ["name"] = "Dreadpetal", ["count"] = 1 },
        [81983] = { ["name"] = "Verdant Mandragora", ["count"] = 15 },
        [81984] = { ["name"] = "Gnarlroot", ["count"] = 25 },
        [81985] = { ["name"] = "Everbloom Tender", ["count"] = 3 },
        [82039] = { ["name"] = "Rockspine Stinger", ["count"] = 3 },
        [82579] = { ["name"] = "Grom'kar Far Seer", ["count"] = 12 },
        [82590] = { ["name"] = "Grimrail Scout", ["count"] = 12 },
        [82594] = { ["name"] = "Grimrail Loader", ["count"] = 1 },
        [82597] = { ["name"] = "Grom'kar Captain", ["count"] = 18 },
        [83025] = { ["name"] = "Grom'kar Battlemaster", ["count"] = 9 },
        [83026] = { ["name"] = "Siegemaster Olugar", ["count"] = 9 },
        [83028] = { ["name"] = "Grom'kar Deadeye", ["count"] = 3 },
        [83389] = { ["name"] = "Ironwing Flamespitter", ["count"] = 8 },
        [83390] = { ["name"] = "Thunderlord Wrangler", ["count"] = 7 },
        [83392] = { ["name"] = "Rampaging Clefthoof", ["count"] = 8 },
        [83578] = { ["name"] = "Ogron Laborer", ["count"] = 9 },
        [83697] = { ["name"] = "Grom'kar Deckhand", ["count"] = 3 },
        [83761] = { ["name"] = "Ogron Laborer", ["count"] = 9 },
        [83762] = { ["name"] = "Grom'kar Deckhand", ["count"] = 1 },
        [83763] = { ["name"] = "Grom'kar Technician", ["count"] = 2 },
        [83764] = { ["name"] = "Grom'kar Deadeye", ["count"] = 2 },
        [83765] = { ["name"] = "Grom'kar Footsoldier", ["count"] = 2 },
        [84028] = { ["name"] = "Siegemaster Rokra", ["count"] = 9 },
        [84520] = { ["name"] = "Pitwarden Gwarnok", ["count"] = 9 },
        [84767] = { ["name"] = "Twisted Abomination", ["count"] = 8 },
        [84957] = { ["name"] = "Putrid Pyromancer", ["count"] = 5 },
        [84989] = { ["name"] = "Infested Icecaller", ["count"] = 5 },
        [84990] = { ["name"] = "Addled Arcanomancer", ["count"] = 5 },
        [85232] = { ["name"] = "Infested Venomfang", ["count"] = 8 },
        [86372] = { ["name"] = "Melded Berserker", ["count"] = 5 },
        [86526] = { ["name"] = "Grom'kar Chainmaster", ["count"] = 9 },
        [86809] = { ["name"] = "Grom'kar Incinerator", ["count"] = 5 },
        [87252] = { ["name"] = "Unruly Ogron", ["count"] = 9 },
        [88163] = { ["name"] = "Grom'kar Cinderseer", ["count"] = 8 },
        [212981] = { ["name"] = "Hapless Assistant", ["count"] = 3 },
    }
end
