local _, ns = ...

local data = {};
tinsert(ns.data, data)

function data:GetPatchVersion()
    return {
        timestamp = 1720351840,
        version = '11.0.2',
        build = 55399,
    }
end

function data:GetDungeonOverrides()
    return {}
end

function data:GetNPCData()
    -- data is sorted with natural sorting by NPC ID
    return {
        [56658] = { ["name"] = "Corrupt Droplet", ["count"] = 1 },
        [57109] = { ["name"] = "Minion of Doubt", ["count"] = 8 },
        [58319] = { ["name"] = "Lesser Sha", ["count"] = 1 },
        [59544] = { ["name"] = "The Nodding Tiger", ["count"] = 8 },
        [59545] = { ["name"] = "The Golden Beetle", ["count"] = 8 },
        [59546] = { ["name"] = "The Talking Fish", ["count"] = 8 },
        [59547] = { ["name"] = "Jiang", ["count"] = 5 },
        [59552] = { ["name"] = "The Crybaby Hozen", ["count"] = 8 },
        [59553] = { ["name"] = "The Songbird Queen", ["count"] = 8 },
        [59555] = { ["name"] = "Haunting Sha", ["count"] = 5 },
        [59598] = { ["name"] = "Lesser Sha", ["count"] = 1 },
        [59873] = { ["name"] = "Corrupt Living Water", ["count"] = 12 },
        [62358] = { ["name"] = "Corrupt Droplet", ["count"] = 1 },
        [65317] = { ["name"] = "Xiang", ["count"] = 5 },
        [65362] = { ["name"] = "Minion of Doubt", ["count"] = 8 },
        [200126] = { ["name"] = "Fallen Waterspeaker", ["count"] = 8 },
        [200131] = { ["name"] = "Sha-Touched Guardian", ["count"] = 8 },
        [200137] = { ["name"] = "Depraved Mistweaver", ["count"] = 8 },
        [200387] = { ["name"] = "Shambling Infester", ["count"] = 18 },
    }
end
