local _, ns = ...

local data = {};
tinsert(ns.data, data)

function data:GetPatchVersion()
    return {
        timestamp = 1700046129,
        version = '10.2.0',
        build = 52148,
    }
end

function data:GetDungeonOverrides()
    return {}
end

function data:GetNPCData()
    -- data is sorted with natural sorting by NPC ID
    return {
        [39616] = { ["name"] = "Naz'jar Invader", ["count"] = 4 },
        [39960] = { ["name"] = "Deep Murloc Drudge", ["count"] = 1 },
        [40577] = { ["name"] = "Naz'jar Sentinel", ["count"] = 10 },
        [40634] = { ["name"] = "Naz'jar Tempest Witch", ["count"] = 5 },
        [40925] = { ["name"] = "Tainted Sentry", ["count"] = 7 },
        [40935] = { ["name"] = "Gilgoblin Hunter", ["count"] = 3 },
        [40936] = { ["name"] = "Faceless Watcher", ["count"] = 8 },
        [40943] = { ["name"] = "Gilgoblin Aquamage", ["count"] = 3 },
        [41096] = { ["name"] = "Naz'jar Spiritmender", ["count"] = 5 },
        [45477] = { ["name"] = "Gust Soldier", ["count"] = 5 },
        [45704] = { ["name"] = "Lurking Tempest", ["count"] = 3 },
        [45912] = { ["name"] = "Wild Vortex", ["count"] = 4 },
        [45915] = { ["name"] = "Armored Mistral", ["count"] = 15 },
        [45917] = { ["name"] = "Cloud Prince", ["count"] = 12 },
        [45919] = { ["name"] = "Young Storm Dragon", ["count"] = 20 },
        [45922] = { ["name"] = "Empyrean Assassin", ["count"] = 5 },
        [45924] = { ["name"] = "Turbulent Squall", ["count"] = 3 },
        [45926] = { ["name"] = "Servant of Asaad", ["count"] = 4 },
        [45928] = { ["name"] = "Executor of the Caliph", ["count"] = 8 },
        [45930] = { ["name"] = "Minister of Air", ["count"] = 15 },
        [45932] = { ["name"] = "Skyfall Star", ["count"] = 1 },
        [45935] = { ["name"] = "Temple Adept", ["count"] = 5 },
        [212673] = { ["name"] = "Naz'jar Ravager", ["count"] = 25 },
        [212681] = { ["name"] = "Vicious Snap Dragon", ["count"] = 4 },
        [212775] = { ["name"] = "Faceless Seer", ["count"] = 5 },
        [212778] = { ["name"] = "Minion of Ghur'sha", ["count"] = 3 },
    }
end
