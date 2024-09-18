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
    return {}
end

function data:GetNPCData()
    -- data is sorted with natural sorting by NPC ID
    return {
        [210109] = { ["name"] = "Earth Infused Golem", ["count"] = 10 },
        [210966] = { ["name"] = "Sureki Webmage", ["count"] = 12 },
        [211261] = { ["name"] = "Ascendant Vis'coxria", ["count"] = 25 },
        [211262] = { ["name"] = "Ixkreten the Unbreakable", ["count"] = 25 },
        [211263] = { ["name"] = "Deathscreamer Iken'tak", ["count"] = 25 },
        [211341] = { ["name"] = "Manifested Shadow", ["count"] = 16 },
        [212389] = { ["name"] = "Cursedheart Invader", ["count"] = 5 },
        [212400] = { ["name"] = "Void Touched Elemental", ["count"] = 4 },
        [212403] = { ["name"] = "Cursedheart Invader", ["count"] = 5 },
        [212405] = { ["name"] = "Aspiring Forgehand", ["count"] = 1 },
        [212453] = { ["name"] = "Ghastly Voidsoul", ["count"] = 7 },
        [212764] = { ["name"] = "Engine Speaker", ["count"] = 3 },
        [212765] = { ["name"] = "Void Bound Despoiler", ["count"] = 10 },
        [213338] = { ["name"] = "Forgebound Mender", ["count"] = 5 },
        [213343] = { ["name"] = "Forge Loader", ["count"] = 10 },
        [213885] = { ["name"] = "Nightfall Dark Architect", ["count"] = 30 },
        [213892] = { ["name"] = "Nightfall Shadowmage", ["count"] = 5 },
        [213893] = { ["name"] = "Nightfall Darkcaster", ["count"] = 5 },
        [213894] = { ["name"] = "Nightfall Curseblade", ["count"] = 5 },
        [213895] = { ["name"] = "Nightfall Shadowalker", ["count"] = 5 },
        [213932] = { ["name"] = "Sureki Militant", ["count"] = 12 },
        [213934] = { ["name"] = "Nightfall Tactician", ["count"] = 10 },
        [213954] = { ["name"] = "Rock Smasher", ["count"] = 12 },
        [214066] = { ["name"] = "Cursedforge Stoneshaper", ["count"] = 5 },
        [214264] = { ["name"] = "Cursedforge Honor Guard", ["count"] = 8 },
        [214350] = { ["name"] = "Turned Speaker", ["count"] = 3 },
        [214761] = { ["name"] = "Nightfall Ritualist", ["count"] = 12 },
        [214762] = { ["name"] = "Nightfall Commander", ["count"] = 12 },
        [214840] = { ["name"] = "Engorged Crawler", ["count"] = 4 },
        [216293] = { ["name"] = "Trilling Attendant", ["count"] = 4 },
        [216328] = { ["name"] = "Unstable Test Subject", ["count"] = 20 },
        [216329] = { ["name"] = "Congealed Droplet", ["count"] = 1 },
        [216333] = { ["name"] = "Bloodstained Assistant", ["count"] = 7 },
        [216336] = { ["name"] = "Starved Crawler", ["count"] = 1 },
        [216337] = { ["name"] = "Bloodworker", ["count"] = 1 },
        [216338] = { ["name"] = "Hulking Bloodguard", ["count"] = 20 },
        [216339] = { ["name"] = "Sureki Unnaturaler", ["count"] = 6 },
        [216340] = { ["name"] = "Sentry Stagshell", ["count"] = 7 },
        [216341] = { ["name"] = "Jabbing Flyer", ["count"] = 2 },
        [216342] = { ["name"] = "Assistant Unnaturaler", ["count"] = 3 },
        [216363] = { ["name"] = "Reinforced Drone", ["count"] = 3 },
        [216364] = { ["name"] = "Blood Overseer", ["count"] = 14 },
        [216365] = { ["name"] = "Winged Carrier", ["count"] = 3 },
        [217039] = { ["name"] = "Nerubian Hauler", ["count"] = 35 },
        [217531] = { ["name"] = "Ixin", ["count"] = 12 },
        [217533] = { ["name"] = "Atik", ["count"] = 12 },
        [218324] = { ["name"] = "Nakt", ["count"] = 12 },
        [220003] = { ["name"] = "Eye of the Queen", ["count"] = 20 },
        [220193] = { ["name"] = "Sureki Venomblade", ["count"] = 10 },
        [220195] = { ["name"] = "Sureki Silkbinder", ["count"] = 10 },
        [220196] = { ["name"] = "Herald of Ansurek", ["count"] = 20 },
        [220197] = { ["name"] = "Royal Swarmguard", ["count"] = 20 },
        [220199] = { ["name"] = "Battle Scarab", ["count"] = 1 },
        [220423] = { ["name"] = "Retired Lord Vul'azak", ["count"] = 20 },
        [220730] = { ["name"] = "Royal Venomshell", ["count"] = 20 },
        [221102] = { ["name"] = "Elder Shadeweaver", ["count"] = 40 },
        [221103] = { ["name"] = "Hulking Warshell", ["count"] = 40 },
        [221979] = { ["name"] = "Void Bound Howler", ["count"] = 7 },
        [222923] = { ["name"] = "Repurposed Loaderbot", ["count"] = 3 },
        [223181] = { ["name"] = "Agile Pursuer", ["count"] = 14 },
        [223182] = { ["name"] = "Web Marauder", ["count"] = 14 },
        [223253] = { ["name"] = "Bloodstained Webmage", ["count"] = 7 },
        [223357] = { ["name"] = "Sureki Conscript", ["count"] = 3 },
        [223844] = { ["name"] = "Covert Webmancer", ["count"] = 14 },
        [224731] = { ["name"] = "Web Marauder", ["count"] = 14 },
        [224732] = { ["name"] = "Covert Webmancer", ["count"] = 14 },
        [224962] = { ["name"] = "Cursedforge Mender", ["count"] = 5 },
        [228361] = { ["name"] = "Agile Pursuer", ["count"] = 14 },
    }
end
