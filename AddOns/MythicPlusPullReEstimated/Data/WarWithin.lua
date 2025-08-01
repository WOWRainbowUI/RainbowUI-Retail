local _, ns = ...

local data = {};
tinsert(ns.data, data)

function data:GetPatchVersion()
    return {
        timestamp = 1749741408,
        version = '11.1.5',
        build = 61188,
    }
end

function data:GetDungeonOverrides()
    return {
        [505] = { -- The Dawnbreaker
            [230740] = { ["name"] = "Shreddinator 3000", ["count"] = 5 },
        },
        [525] = { -- Operation: Floodgate
            [230740] = { ["name"] = "Shreddinator 3000", ["count"] = 10 },
        },
    }
end

--- @return table<number, {name: string, count: number}> # [npcID] = info
function data:GetNPCData()
    -- data is sorted with natural sorting by NPC ID
    return {
        [206694] = { name = "Fervent Sharpshooter", count = 5 },
        [206696] = { name = "Arathi Knight", count = 18 },
        [206697] = { name = "Devout Priest", count = 6 },
        [206698] = { name = "Fanatical Conjuror", count = 6 },
        [206699] = { name = "War Lynx", count = 6 },
        [206704] = { name = "Ardent Paladin", count = 14 },
        [206705] = { name = "Arathi Footman", count = 3 },
        [206710] = { name = "Lightspawn", count = 18 },
        [207186] = { name = "Unruly Stormrook", count = 12 },
        [207197] = { name = "Cursed Rookguard", count = 10 },
        [207198] = { name = "Cursed Thunderer", count = 10 },
        [207199] = { name = "Cursed Rooktender", count = 10 },
        [207943] = { name = "Arathi Neophyte", count = 1 },
        [207949] = { name = "Zealous Templar", count = 10 },
        [208450] = { name = "Wandering Candle", count = 15 },
        [208456] = { name = "Shuffling Horror", count = 2 },
        [208457] = { name = "Skittering Darkness", count = 1 },
        [209747] = { name = "Arathi Neophyte", count = 1 },
        [209801] = { name = "Quartermaster Koratite", count = 20 },
        [210109] = { name = "Earth Infused Golem", count = 10 },
        [210264] = { name = "Bee Wrangler", count = 5 },
        [210265] = { name = "Worker Bee", count = 5 },
        [210269] = { name = "Hired Muscle", count = 10 },
        [210270] = { name = "Brew Drop", count = 1 },
        [210539] = { name = "Corridor Creeper", count = 4 },
        [210810] = { name = "Menial Laborer", count = 1 },
        [210812] = { name = "Royal Wicklighter", count = 6 },
        [210818] = { name = "Lowly Moleherd", count = 5 },
        [210966] = { name = "Sureki Webmage", count = 12 },
        [211121] = { name = "Rank Overseer", count = 10 },
        [211228] = { name = "Blazing Fiend", count = 7 },
        [211261] = { name = "Ascendant Vis'coxria", count = 25 },
        [211262] = { name = "Ixkreten the Unbreakable", count = 25 },
        [211263] = { name = "Deathscreamer Iken'tak", count = 25 },
        [211341] = { name = "Manifested Shadow", count = 16 },
        [211977] = { name = "Pack Mole", count = 3 },
        [212383] = { name = "Kobold Taskworker", count = 4 },
        [212389] = { name = "Cursedheart Invader", count = 5 },
        [212400] = { name = "Void Touched Elemental", count = 4 },
        [212403] = { name = "Cursedheart Invader", count = 5 },
        [212405] = { name = "Aspiring Forgehand", count = 1 },
        [212411] = { name = "Torchsnarl", count = 20 },
        [212412] = { name = "Sootsnout", count = 20 },
        [212453] = { name = "Ghastly Voidsoul", count = 7 },
        [212739] = { name = "Consuming Voidstone", count = 25 },
        [212764] = { name = "Engine Speaker", count = 3 },
        [212765] = { name = "Void Bound Despoiler", count = 10 },
        [212786] = { name = "Voidrider", count = 25 },
        [212793] = { name = "Void Ascendant", count = 22 },
        [212826] = { name = "Guard Captain Suleyman", count = 50 },
        [212827] = { name = "High Priest Aemya", count = 50 },
        [212831] = { name = "Forge Master Damian", count = 50 },
        [212835] = { name = "Risen Footman", count = 4 },
        [212838] = { name = "Arathi Neophyte", count = 1 },
        [213338] = { name = "Forgebound Mender", count = 5 },
        [213343] = { name = "Forge Loader", count = 10 },
        [213885] = { name = "Nightfall Dark Architect", count = 30 },
        [213892] = { name = "Nightfall Shadowmage", count = 5 },
        [213893] = { name = "Nightfall Darkcaster", count = 5 },
        [213895] = { name = "Nightfall Shadowalker", count = 5 },
        [213913] = { name = "Kobold Flametender", count = 1 },
        [213932] = { name = "Sureki Militant", count = 12 },
        [213934] = { name = "Nightfall Tactician", count = 10 },
        [213954] = { name = "Rock Smasher", count = 12 },
        [214066] = { name = "Cursedforge Stoneshaper", count = 5 },
        [214264] = { name = "Cursedforge Honor Guard", count = 8 },
        [214350] = { name = "Turned Speaker", count = 3 },
        [214419] = { name = "Void-Cursed Crusher", count = 15 },
        [214421] = { name = "Coalescing Void Diffuser", count = 25 },
        [214439] = { name = "Corrupted Oracle", count = 12 },
        [214668] = { name = "Venture Co. Patron", count = 3 },
        [214673] = { name = "Flavor Scientist", count = 7 },
        [214697] = { name = "Chef Chewie", count = 15 },
        [214761] = { name = "Nightfall Ritualist", count = 12 },
        [214762] = { name = "Nightfall Commander", count = 12 },
        [214840] = { name = "Engorged Crawler", count = 4 },
        [214920] = { name = "Tasting Room Attendant", count = 3 },
        [216293] = { name = "Trilling Attendant", count = 4 },
        [216328] = { name = "Unstable Test Subject", count = 20 },
        [216329] = { name = "Congealed Droplet", count = 1 },
        [216333] = { name = "Bloodstained Assistant", count = 7 },
        [216336] = { name = "Starved Crawler", count = 1 },
        [216337] = { name = "Bloodworker", count = 1 },
        [216338] = { name = "Hulking Bloodguard", count = 20 },
        [216339] = { name = "Sureki Unnaturaler", count = 6 },
        [216340] = { name = "Sentry Stagshell", count = 7 },
        [216341] = { name = "Jabbing Flyer", count = 2 },
        [216342] = { name = "Assistant Unnaturaler", count = 3 },
        [216363] = { name = "Reinforced Drone", count = 3 },
        [216364] = { name = "Blood Overseer", count = 14 },
        [216365] = { name = "Winged Carrier", count = 3 },
        [217039] = { name = "Nerubian Hauler", count = 35 },
        [217531] = { name = "Ixin", count = 12 },
        [217533] = { name = "Atik", count = 12 },
        [217658] = { name = "Sir Braunpyke", count = 50 },
        [218324] = { name = "Nakt", count = 12 },
        [218671] = { name = "Venture Co. Pyromaniac", count = 5 },
        [218865] = { name = "Bee-let", count = 1 },
        [219066] = { name = "Afflicted Civilian", count = 1 },
        [219588] = { name = "Yes Man", count = 3 },
        [219983] = { name = "Hollows Resident", count = 20 },
        [219984] = { name = "Xeph'itik", count = 8 },
        [220003] = { name = "Eye of the Queen", count = 20 },
        [220060] = { name = "Taste Tester", count = 5 },
        [220141] = { name = "Royal Jelly Purveyor", count = 7 },
        [220193] = { name = "Sureki Venomblade", count = 10 },
        [220195] = { name = "Sureki Silkbinder", count = 10 },
        [220196] = { name = "Herald of Ansurek", count = 20 },
        [220197] = { name = "Royal Swarmguard", count = 20 },
        [220199] = { name = "Battle Scarab", count = 1 },
        [220423] = { name = "Retired Lord Vul'azak", count = 20 },
        [220616] = { name = "Corridor Sleeper", count = 4 },
        [220730] = { name = "Royal Venomshell", count = 20 },
        [220815] = { name = "Blazing Fiend", count = 7 },
        [220946] = { name = "Venture Co. Honey Harvester", count = 10 },
        [221102] = { name = "Elder Shadeweaver", count = 40 },
        [221103] = { name = "Hulking Warshell", count = 40 },
        [221760] = { name = "Risen Mage", count = 6 },
        [221979] = { name = "Void Bound Howler", count = 7 },
        [222923] = { name = "Repurposed Loaderbot", count = 3 },
        [222964] = { name = "Flavor Scientist", count = 7 },
        [223181] = { name = "Agile Pursuer", count = 14 },
        [223182] = { name = "Web Marauder", count = 14 },
        [223253] = { name = "Bloodstained Webmage", count = 7 },
        [223357] = { name = "Sureki Conscript", count = 3 },
        [223423] = { name = "Careless Hopgoblin", count = 10 },
        [223497] = { name = "Worker Bee", count = 5 },
        [223498] = { name = "Bee-let", count = 1 },
        [223770] = { name = "Blazing Fiend", count = 7 },
        [223772] = { name = "Blazing Fiend", count = 7 },
        [223773] = { name = "Blazing Fiend", count = 7 },
        [223774] = { name = "Blazing Fiend", count = 7 },
        [223775] = { name = "Blazing Fiend", count = 7 },
        [223776] = { name = "Blazing Fiend", count = 7 },
        [223777] = { name = "Blazing Fiend", count = 7 },
        [223844] = { name = "Covert Webmancer", count = 14 },
        [224731] = { name = "Web Marauder", count = 14 },
        [224732] = { name = "Covert Webmancer", count = 14 },
        [224962] = { name = "Cursedforge Mender", count = 5 },
        [227145] = { name = "Waterworks Crocolisk", count = 1 },
        [228144] = { name = "Darkfuse Soldier", count = 3 },
        [228361] = { name = "Agile Pursuer", count = 14 },
        [229069] = { name = "Mechadrone Sniper", count = 5 },
        [229212] = { name = "Darkfuse Demolitionist", count = 7 },
        [229250] = { name = "Venture Co. Contractor", count = 2 },
        [229251] = { name = "Venture Co. Architect", count = 10 },
        [229252] = { name = "Darkfuse Hyena", count = 3 },
        [229686] = { name = "Venture Co. Surveyor", count = 7 },
        [230748] = { name = "Darkfuse Bloodwarper", count = 12 },
        [231014] = { name = "Loaderbot", count = 2 },
        [231197] = { name = "Bubbles", count = 20 },
        [231223] = { name = "Disturbed Kelp", count = 7 },
        [231312] = { name = "Venture Co. Electrician", count = 7 },
        [231325] = { name = "Darkfuse Jumpstarter", count = 12 },
        [231380] = { name = "Undercrawler", count = 1 },
        [231385] = { name = "Darkfuse Inspector", count = 5 },
        [231496] = { name = "Venture Co. Diver", count = 5 },
        [231497] = { name = "Bombshell Crab", count = 3 },
        [239833] = { name = "Elaena Emberlanz", count = 50 },
        [239834] = { name = "Taener Duelmal", count = 50 },
        [239836] = { name = "Sergeant Shaynemail", count = 50 },
    }
end

--- @return table<number, table<number, {npcID: number?, count: number}>> # [criteriaID] = { [mapID] = info }
function data:GetDebugData()
    return {
        [499] = { -- Priory of the Sacred Flame
            [50191] = { npcID = nil, count = 9 },
            [50192] = { npcID = nil, count = 96 },
        },
        [500] = { -- The Rookery
            [48468] = { npcID = nil, count = 1 },
            [50191] = { npcID = nil, count = 10 },
            [50192] = { npcID = nil, count = 100 },
        },
        [501] = { -- The Stonevault
            [48468] = { npcID = nil, count = 1 },
            [50191] = { npcID = nil, count = 5 },
            [50192] = { npcID = nil, count = 50 },
        },
        [502] = { -- City of Threads
            [50191] = { npcID = nil, count = 8 },
            [50192] = { npcID = nil, count = 74 },
            [69968] = { npcID = 219984, count = 8 },
        },
        [503] = { -- Ara-Kara, City of Echoes
            [48468] = { npcID = nil, count = 1 },
            [50191] = { npcID = nil, count = 4 },
            [50192] = { npcID = nil, count = 43 },
        },
        [504] = { -- Darkflame Cleft
            [48468] = { npcID = nil, count = 1 },
            [50191] = { npcID = nil, count = 4 },
            [50192] = { npcID = nil, count = 44 },
        },
        [505] = { -- The Dawnbreaker
            [48468] = { npcID = nil, count = 1 },
            [50191] = { npcID = nil, count = 5 },
            [50192] = { npcID = nil, count = 48 },
        },
        [506] = { -- Cinderbrew Meadery
            [48468] = { npcID = nil, count = 1 },
            [50191] = { npcID = nil, count = 6 },
            [50192] = { npcID = nil, count = 59 },
        },
        [525] = { -- Operation: Floodgate
            [50191] = { npcID = nil, count = 4 },
            [50192] = { npcID = nil, count = 45 },
        }
    }
end
