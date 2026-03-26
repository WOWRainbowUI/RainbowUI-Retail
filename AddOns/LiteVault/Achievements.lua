local addonName, lv = ...
local L = lv.L

function lv.LocalizeDisplayText(text, fallback)
    if type(text) ~= "string" or text == "" then
        return fallback or text or ""
    end

    local translated = L and L[text]
    if translated and translated ~= "" and translated ~= text then
        return translated
    end

    return text
end

function lv.GetLocalizedItemNameByID(itemID, fallback)
    local itemName = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
    if itemName and itemName ~= "" then
        return lv.LocalizeDisplayText(itemName, itemName)
    end

    return fallback or "Item"
end

local TREASURE_ACHIEVEMENT_REWARDS = {
    [61960] = { type = "item", itemID = 269028, label = "Pet: Sootpaw" },
    [62126] = { type = "item", itemID = 264695, label = "Toy: Interdimensional Parcel Signal" },
    [61263] = { type = "mount", name = "Vivacious Chloroceros", label = "Mount: Vivacious Chloroceros" },
    [62125] = { type = "item", itemID = 268717, label = "Toy: Pango Plating" },
}
local TREASURES_OF_MIDNIGHT = {
    {
        id = 61960,
        name = "Treasures of Eversong Woods",
        treasures = {
            {
                mapID = 2393,
                x = 24.28,
                y = 69.50,
                name = "Rookery Cache",
                reward = { type = "item", itemID = 267838, label = "Pet: Sunwing Hatchling" },
                steps = {
                    { x = 24.28, y = 69.50, text = "1 Rookery Cache" },
                    { x = 24.28, y = 69.50, text = "2 Buy Tasty Meat from Farstrider Aerieminder" },
                    { x = 24.28, y = 69.50, text = "3 Feed Mischievous Chick for Rookery Cache Key" },
                    { x = 24.28, y = 69.50, text = "4 Loot Rookery Cache" },
                },
            },
            {
                mapID = 2395,
                x = 38.85,
                y = 76.08,
                name = "Triple-Locked Safebox",
                reward = { type = "item", itemID = 243106, label = "Housing Decor: Gemmed Eversong Lantern" },
                steps = {
                    { x = 38.85, y = 76.08, text = "1 Triple-Locked Safebox" },
                    { x = 38.85, y = 76.08, text = "2 Burning Torch - use it so the keys become visible" },
                    { x = 37.64, y = 74.84, text = "3 Key 1" },
                    { x = 38.48, y = 73.43, text = "4 Key 2" },
                    { x = 40.23, y = 75.81, text = "5 Key 3" },
                    { x = 38.85, y = 76.08, text = "6 Loot Triple-Locked Safebox" },
                },
            },
            {
                mapID = 2395,
                x = 40.95,
                y = 19.49,
                name = "Gift of the Phoenix",
                reward = { type = "item", itemID = 263211, label = "Housing Decor: Gilded Eversong Cup" },
                steps = {
                    { x = 40.95, y = 19.49, text = "1 Sunstrider Vessel" },
                    { x = 40.95, y = 19.49, text = "2 Collect 5 Phoenix Cinders from hatchling circles" },
                    { x = 40.95, y = 19.49, text = "3 Return Vessel" },
                    { x = 40.95, y = 19.49, text = "4 Loot Gift of the Phoenix" },
                },
            },
            { mapID = 2395, x = 43.27, y = 69.51, name = "Forgotten Ink and Quill", reward = { type = "item", itemID = 262616, label = "Housing Decor: Lively Songwriter's Quill" } },
            { mapID = 2395, x = 44.61, y = 45.59, name = "Gilded Armillary Sphere", reward = { type = "item", itemID = 265828, label = "Item: Gilded Armillary Sphere" } },
            { mapID = 2395, x = 52.32, y = 45.41, name = "Antique Nobleman's Signet Ring", reward = { type = "item", itemID = 265814, label = "Item: Noble's Signet Ring" } },
            { mapID = 2395, x = 60.67, y = 67.29, name = "Farstrider's Lost Quiver", reward = { type = "item", itemID = 265816, label = "Item: Lost Quiver" } },
            {
                mapID = 2395,
                x = 40.48,
                y = 60.84,
                name = "Stone Vat",
                reward = { type = "item", itemID = 251912, label = "Housing Decor: Goldenmist Grapes" },
                steps = {
                    { x = 40.48, y = 60.84, text = "1 Stone Vat" },
                    { x = 40.48, y = 60.84, text = "2 Collect 10 Ripe Grapes from nearby platforms" },
                    { x = 40.48, y = 60.84, text = "3 Deposit grapes into the vat" },
                    { x = 40.48, y = 60.84, text = "4 Jump in the vat" },
                    { x = 40.48, y = 60.84, text = "5 Buy Packet of Instant Yeast from Sheri" },
                    { x = 40.48, y = 60.84, text = "6 Use the vat again" },
                    { x = 40.48, y = 60.84, text = "7 Loot Stone Vat" },
                },
            },
            {
                mapID = 2395,
                x = 48.74,
                y = 75.45,
                name = "Burbling Paint Pot",
                reward = { type = "item", itemID = 246314, label = "Pet: Dali" },
                steps = {
                    { x = 48.74, y = 75.45, text = "1 Click Pot" },
                    { x = 48.74, y = 75.45, text = "2 Jump in water" },
                    { x = 48.74, y = 75.45, text = "3 Loot pet" },
                },
            },
        },
    },
    {
        id = 62126,
        name = "Treasures of Voidstorm",
        treasures = {
            {
                mapID = 2405,
                x = 48.90,
                y = 78.31,
                name = "Final Clutch of Predaxas",
                reward = { type = "item", itemID = 257446, label = "Mount: Reins of the Insatiable Shredclaw" },
                steps = {
                    { x = 48.89, y = 78.29, text = "1 Cave Entrance" },
                    { x = 48.90, y = 78.31, text = "2 Final Clutch of Predaxas - work through the electrified egg maze and loot it at the back" },
                },
            },
            {
                mapID = 2405,
                x = 25.78,
                y = 67.28,
                name = "Void-Shielded Tomb",
                reward = { type = "item", itemID = 246951, label = "Item x20: Stormarion Core" },
                steps = {
                    { x = 25.78, y = 67.27, text = "1 Void-Shielded Tomb - drink the Potion of Dissociation on the table next to it" },
                    { x = 25.90, y = 68.60, text = "2 Key of Fused Darkness" },
                    { x = 25.78, y = 67.27, text = "3 Loot Void-Shielded Tomb" },
                },
            },
            {
                mapID = 2405,
                x = 64.50,
                y = 75.49,
                name = "Bloody Sack",
                reward = { type = "item", itemID = 267139, label = "Toy: Hungry Black Hole" },
                steps = {
                    { x = 64.49, y = 75.49, text = "1 Forgotten Oubliette" },
                    { x = 64.49, y = 75.49, text = "2 Feed 4 nearby meat pieces" },
                    { x = 64.49, y = 75.49, text = "3 Bloody Sack" },
                },
            },
            {
                mapID = 2405,
                x = 54.10,
                y = 43.92,
                name = "Malignant Chest",
                reward = { type = "item", itemID = 264482, label = "Housing Decor: Void Elf Torch" },
                steps = {
                    { x = 53.21, y = 44.23, text = "1 Cave Entrance" },
                    { x = 54.10, y = 43.92, text = "2 Malignant Chest - activate the four Malignant Nodes inside until it spawns" },
                },
            },
            {
                mapID = 2444,
                x = 53.20,
                y = 32.23,
                name = "Stellar Stash",
                reward = { type = "item", itemID = 262467, label = "Housing Decor: Void Elf Round Table" },
                steps = {
                    { x = 52.26, y = 31.08, text = "1 Area Entrance" },
                    { x = 53.20, y = 32.23, text = "2 Stellar Stash - use one of the arena gateways to get inside" },
                    { x = 53.20, y = 32.23, text = "3 Pull 3 objects from the stash" },
                    { x = 53.20, y = 32.23, text = "4 Loot Stellar Stash" },
                },
            },
            {
                mapID = 2405,
                x = 47.99,
                y = 78.45,
                name = "Forgotten Researcher's Cache",
                reward = { type = "item", itemID = 250319, label = "Toy: Researcher's Shadowgraft" },
                steps = {
                    { x = 47.90, y = 78.62, text = "1 Cave Entrance" },
                    { x = 47.99, y = 78.45, text = "2 Forgotten Researcher's Cache - jump up the rocks to the small platform and loot it" },
                },
            },
            { mapID = 2444, x = 49.05, y = 20.12, name = "Scout's Pack", reward = { type = "item", itemID = 266101, label = "Cosmetic: Unused Initiate's Bulwark" } },
            { mapID = 2405, x = 55.40, y = 75.40, name = "Embedded Spear", reward = { type = "item", itemID = 266075, label = "Cosmetic: Harpoon of Extirpation" } },
            { mapID = 2405, x = 31.46, y = 44.49, name = "Quivering Egg", reward = { type = "item", itemID = 266076, label = "Pet: Nether Siphoner" } },
            {
                mapID = 2405,
                x = 28.34,
                y = 72.85,
                name = "Exaliburn",
                reward = { type = "item", itemID = 266099, label = "Cosmetic: Extinguished Exaliburn" },
                steps = {
                    { x = 28.34, y = 72.85, text = "1 Exaliburn" },
                    { x = 28.34, y = 72.85, text = "2 Potion of Unquestionable Strength" },
                    { x = 28.34, y = 72.85, text = "3 Pull Exaliburn" },
                },
            },
            {
                mapID = 2405,
                x = 35.73,
                y = 41.40,
                name = "Discarded Energy Pike",
                reward = { type = "item", itemID = 266100, label = "Cosmetic: Barbed Riftwalker Dirk" },
                steps = {
                    { x = 35.73, y = 41.40, text = "1 Discarded Energy Pike" },
                    { x = 35.73, y = 41.40, text = "2 Defeat nearby mobs" },
                    { x = 35.73, y = 41.40, text = "3 Loot Discarded Energy Pike" },
                },
            },
            { mapID = 2405, x = 43.02, y = 81.92, name = "Faindel's Quiver", reward = { type = "item", itemID = 266098, label = "Cosmetic: Faindel's Longbow" } },
            { mapID = 2405, x = 38.06, y = 68.76, name = "Half-Digested Viscera", reward = { type = "item", itemID = 264303, label = "Pet: Willie" } },
        },
    },
    {
        id = 62125,
        name = "Treasures of Zul'Aman",
        treasures = {
            {
                mapID = 2437,
                x = 21.86,
                y = 77.37,
                name = "Sealed Twilight Blade Bounty",
                reward = { type = "item", itemID = 265362, label = "Appearances: Arsenal: Twilight Blade" },
                steps = {
                    { x = 24.06, y = 75.71, text = "1 Sealing Orb #1 - complete the orb puzzle by untangling the void tethers" },
                    { x = 26.09, y = 74.07, text = "2 Sealing Orb #2 - complete the orb puzzle by untangling the void tethers" },
                    { x = 26.09, y = 80.69, text = "3 Sealing Orb #3 - complete the orb puzzle by untangling the void tethers" },
                    { x = 23.99, y = 78.90, text = "4 Sealing Orb #4 - complete the orb puzzle by untangling the void tethers" },
                    { x = 21.81, y = 77.38, text = "5 Sealed Twilight Blade Bounty - after all 4 puzzles are done, loot it" },
                },
            },
            { mapID = 2437, x = 42.02, y = 47.79, name = "Burrow Bounty", reward = { type = "item", itemID = 254749, label = "Item: Phial of Burrow Balm" } },
            {
                mapID = 2437,
                x = 40.45,
                y = 35.95,
                name = "Secret Formula",
                rewards = {
                    { type = "item", itemID = 256326, label = "Item: Fetid Dartfrog Idol" },
                    { type = "item", itemID = 257149, label = "Item: Old Tome" },
                },
            },
            {
                mapID = 2437,
                x = 46.92,
                y = 82.25,
                name = "Honored Warrior's Cache",
                reward = { type = "item", itemID = 257223, label = "Mount: Ancestral War Bear" },
                steps = {
                    { x = 47.03, y = 82.36, text = "1 Cave Entrance" },
                    { x = 46.80, y = 82.00, text = "2 Honored Warrior's Cache - interact with the chest first so the urns appear" },
                    { x = 32.68, y = 83.51, text = "3 Nalorakk's Chosen - interact with urn, defeat the mob, collect the token" },
                    { x = 34.53, y = 33.50, text = "4 Halazzi's Chosen - interact with urn, defeat the mob, collect the token" },
                    { x = 54.76, y = 22.38, text = "5 Jan'alai's Chosen - interact with urn, defeat the mob, collect the token" },
                    { x = 51.58, y = 84.90, text = "6 Akil'zon's Chosen - interact with urn, defeat the mob, collect the token" },
                    { x = 46.93, y = 81.97, text = "7 Honored Warrior's Cache - after collecting all 4 tokens, loot it" },
                },
            },
            { mapID = 2437, x = 21.12, y = 67.09, name = "Bait and Tackle", reward = { type = "item", itemID = 255157, label = "Item: Abyss Angler's Fish Log" } },
            {
                mapID = 2437,
                x = 52.33,
                y = 65.94,
                name = "Mrruk's Mangy Trove",
                reward = { type = "item", itemID = 255428, label = "Item: Tolpani's Medicine Satchel" },
                steps = {
                    { x = 52.34, y = 65.50, text = "1 Mrruk the Musclefin - defeat him near Amani'zar Village" },
                    { x = 52.34, y = 65.50, text = "2 Mrruk's Mangy Trove - loot it at the same spot" },
                },
            },
            { mapID = 2437, x = 42.62, y = 52.45, name = "Abandoned Nest", reward = { type = "item", itemID = 255008, label = "Pet: Weathered Eagle Egg (hatches into Scruffbeak)" } },
        },
    },
    {
        id = 61263,
        name = "Treasures of Harandar",
        note = "Some treasures require extra steps or items to open.",
        treasures = {
            { mapID = 2413, x = 71.69, y = 31.04, name = "Failed Shroom Jumper's Satchel", reward = { type = "item", itemID = 258963, label = "Toy: Shroom Jumper's Parachute" } },
            { mapID = 2413, x = 47.00, y = 50.33, name = "Burning Branch of the World Tree", reward = { type = "item", itemID = 258900, label = "Item: Charred World Tree Branch" } },
            { mapID = 2413, x = 73.63, y = 65.29, name = "Sporelord's Fight Prize", reward = { type = "item", itemID = 263289, label = "Cosmetic: Sporelord's Authority" } },
            { mapID = 2413, x = 62.92, y = 51.17, name = "Reliquary's Lost Paintbrush", reward = { type = "item", itemID = 263287, label = "Cosmetic: Reliquary-Keeper's Lost Shortbow" } },
            { mapID = 2413, x = 55.69, y = 39.43, name = "Kemet's Simmering Cauldron", reward = { type = "item", itemID = 258903, label = "Pet: Percival" } },
            {
                mapID = 2413,
                x = 51.20,
                y = 52.90,
                name = "Gift of the Cycle",
                reward = { type = "item", itemID = 259084 },
                steps = {
                    { x = 51.13, y = 47.57, text = "1 Altar of Innocence - on top of mountain, meditate to talk to Spirit" },
                    { x = 51.12, y = 50.55, text = "2 A Tattered Ball - return it to Altar of Innocence" },
                    { x = 47.19, y = 53.12, text = "3 Altar of Vigor - on top of mountain, meditate to talk to Spirit" },
                    { x = 45.11, y = 54.12, text = "4 A Lost Hunting Knife - return it to Altar of Vigor" },
                    { x = 51.14, y = 58.50, text = "5 Altar of Wisdom - on top of mountain, meditate to talk to Spirit" },
                    { x = 51.39, y = 56.00, text = "6 A Rolled-Up Pillow - return it to Altar of Wisdom" },
                    { x = 47.24, y = 50.77, text = "7 Gift of the Cycle - in big den with portal in the lake" },
                },
            },
            {
                mapID = 2413,
                x = 27.51,
                y = 67.97,
                name = "Impenetrably Sealed Gourd",
                reward = { type = "item", itemID = 260730, label = "Pet: Perturbed Sporebat" },
                steps = {
                    { x = 27.49, y = 68.02, text = "1 Cave Entrance" },
                    { x = 27.08, y = 67.75, text = "2 Mysterious Red Fluid - inside cave" },
                    { x = 26.69, y = 68.01, text = "3 Mysterious Purple Fluid - inside cave" },
                    { mapID = 2412, x = 26.57, y = 67.94, text = "4 Durable Vase - upper level, mix into Fizzing Fluid" },
                    { x = 26.74, y = 67.65, text = "5 Impenetrably Sealed Gourd - upper level, use Fizzing Fluid then loot" },
                },
            },
            {
                mapID = 2413,
                x = 46.60,
                y = 67.80,
                name = "Sporespawned Cache",
                reward = { type = "mount", name = "Untainted Grove Crawler" },
                steps = {
                    { x = 41.33, y = 67.99, text = "1 Fungal Mallet - small, tucked into rocky alcove near orange door, interact to gain 5-minute buff" },
                    { x = 46.66, y = 67.81, text = "2 Mycelium Gong - ring before buff expires" },
                    { x = 46.66, y = 67.81, text = "3 Sporespawned Cache - spawns beside gong" },
                },
            },
            {
                mapID = 2413,
                x = 40.61,
                y = 27.99,
                name = "Peculiar Cauldron",
                reward = { type = "item", itemID = 252017, label = "Mount: Ruddy Sporeglider" },
                steps = {
                    { x = 40.66, y = 28.05, text = "1 Peculiar Cauldron - under the bridge east of Har'mara" },
                    { x = 40.66, y = 28.05, text = "2 Farm Flame-Hardened Sap of Teldrassil in the nearby river" },
                    { x = 40.66, y = 28.05, text = "3 Return and loot Peculiar Cauldron after 150 Crystalized Resin Fragment" },
                },
            },
        },
    },
}
local MIDNIGHT_DELVER_CRITERIA = {
    { id = 61741, name = "Delve Loremaster: Midnight" },
    { id = 61723, name = "Curio Fanatic: Midnight" },
    { id = 61901, name = "Midnight: Leave No Treasure Unfound" },
    { id = 61797, name = "My Shady Nemesis" },
}
local MIDNIGHT_HIGHEST_PEAKS_CRITERIA = {
    { id = 62288, name = "Eversong Woods: The Highest Peaks" },
    { id = 62289, name = "Zul'Aman: The Highest Peaks" },
    { id = 62290, name = "Harandar: The Highest Peaks" },
    { id = 62291, name = "Voidstorm: The Highest Peaks" },
}
local MIDNIGHT_RARES_OF_MIDNIGHT = {
    { id = 61507, name = "A Bloody Song" },
    { id = 62122, name = "Tallest Tree in the Forest" },
    { id = 61264, name = "Leaf None Behind" },
    { id = 62130, name = "The Ultimate Predator" },
}
local MIDNIGHT_RARES_REWARDS = {
    [61507] = { type = "item", itemID = 257367, label = "Housing Decor: Silvermoon Energy Focus" },
    [62122] = { type = "item", itemID = 264335, label = "Housing Decor: Colossal Amani Stone Visage" },
    [61264] = { type = "item", itemID = 264266, label = "Housing Decor: Lightbloom Moss Mound" },
    [62130] = { type = "item", itemID = 264493, label = "Housing Decor: Opened Domanaar Storage Crate" },
}
local MIDNIGHT_RARES_SHARED_LOOT = {
    [61507] = {
        { itemID = 251788, label = "Gift of Light" },
        { itemID = 251791, label = "Holy Retributor's Order" },
        { itemID = 257147, label = "Cobalt Dragonhawk" },
        { itemID = 257156, label = "Cerulean Hawkstrider" },
    },
    [62122] = {
        { itemID = 251783, label = "Lost Idol of the Hash'ey" },
        { itemID = 251784, label = "Sylvan Wakrapuku" },
        { itemID = 265543, label = "Tempered Amani Spearhead" },
        { itemID = 265554, label = "Reinforced Amani Haft" },
        { itemID = 265560, label = "Toughened Amani Leather Wrap" },
        { itemID = 257152, label = "Amani Sharptalon" },
        { itemID = 257200, label = "Escaped Witherbark Pango" },
    },
    [61264] = {
        { itemID = 251782, label = "Withered Saptor's Paw" },
        { itemID = 255826, label = "Mysterious Skyshards" },
        { itemID = 246735, label = "Rootstalker Grimlynx" },
        { itemID = 252012, label = "Vibrant Petalwing" },
        { itemID = 264895, label = "Trials of the Florafaun Hunter", note = "Drops from: Ha'kalawe, Queen Lashtongue, Dracaena, Oro'ohna, Pterrock" },
    },
    [62130] = {
        { itemID = 246951, label = "Stormarion Core" },
        { itemID = 251786, label = "Ever-Collapsing Void Fissure" },
        { itemID = 264694, label = "Ultradon Cuirass" },
        { itemID = 264701, label = "Cosmic Bell" },
        { itemID = 257085, label = "Augmented Stormray" },
        { itemID = 260635, label = "Sanguine Harrower" },
    },
}

local EVER_PAINTING_ENTRIES = {
    { mapID = 2395, x = 50.78, y = 41.32, name = "Anar'alah Belore" },
    { mapID = 2395, x = 46.07, y = 64.36, name = "Babble and Brook" },
    { mapID = 2395, x = 42.63, y = 62.66, name = "Elrendar's Song" },
    { mapID = 2395, x = 55.11, y = 59.66, name = "Light Consuming" },
    { mapID = 2395, x = 41.80, y = 56.37, name = "Lost Lamppost" },
    { mapID = 2395, x = 39.00, y = 78.22, name = "Memories of Ghosts" },
    { mapID = 2395, x = 53.95, y = 75.63, name = "Sway of Red and Gold" },
}
local EVER_PAINTING_REWARD = {
    type = "item",
    itemID = 244656,
    label = "Housing Decor: Silvermoon Painter's Cushion",
}
local RUNESTONE_RUSH_ENTRIES = {
    { mapID = 2395, x = 47.36, y = 58.61, name = "Elrendar River Runestone", boss = "Sapmaw the Infestor" },
    { mapID = 2395, x = 38.36, y = 55.54, name = "Ath'ran Runestone", boss = "Commander Viskaj" },
    { mapID = 2395, x = 61.77, y = 61.77, name = "Dawnstar Spire Runestone", boss = "Hal'nok the Trampler" },
    { mapID = 2395, x = 41.13, y = 73.83, name = "Sanctum of the Moon Runestone", boss = "Commander Gravok" },
    { mapID = 2395, x = 40.48, y = 13.61, name = "Sunstrider Isle Runestone", boss = "Claw of the Void" },
}
local RUNESTONE_RUSH_REWARD = nil
local THE_PARTY_MUST_GO_ON_ENTRIES = {
    { mapID = 2395, x = 42.40, y = 46.67, name = "Blood Knights" },
    { mapID = 2395, x = 42.62, y = 46.17, name = "Magisters" },
    { mapID = 2395, x = 42.87, y = 46.41, name = "Farstriders" },
    { mapID = 2395, x = 42.82, y = 45.63, name = "Shades of the Row" },
}
local THE_PARTY_MUST_GO_ON_REWARD = {
    type = "item",
    itemID = 251909,
    label = "Housing Decor: Eversong Feast Platter",
}
local EXPLORE_EVERSONG_WOODS_ENTRIES = {
    { mapID = 2395, x = 55.60, y = 81.42, name = "Amani Pass" },
    { mapID = 2395, x = 63.47, y = 29.19, name = "Brightwing Estate" },
    { mapID = 2395, x = 46.80, y = 45.36, name = "Fairbreeze Village" },
    { mapID = 2395, x = 40.49, y = 60.45, name = "Goldenmist Village" },
    { mapID = 2393, x = 45.66, y = 83.82, name = "Silvermoon City" },
    { mapID = 2395, x = 53.44, y = 61.17, name = "Suncrown Village" },
    { mapID = 2395, x = 42.16, y = 19.37, name = "Sunstrider Isle" },
    { mapID = 2395, x = 48.46, y = 65.65, name = "Tranquillien" },
    { mapID = 2395, x = 35.77, y = 79.64, name = "Windrunner Spire" },
}
local EXPLORE_EVERSONG_WOODS_REWARD = nil
local EXPLORE_VOIDSTORM_ENTRIES = {
    { mapID = 2405, x = 29.58, y = 53.58, name = "Nexus-Point Antius" },
    { mapID = 2405, x = 37.75, y = 47.07, name = "Shadowguard Point" },
    { mapID = 2405, x = 51.78, y = 70.03, name = "Howling Ridge" },
    { mapID = 2405, x = 39.82, y = 83.32, name = "Nexus-Point Mid'Ar" },
    { mapID = 2405, x = 55.74, y = 77.01, name = "Obscurion Citadel" },
    { mapID = 2444, x = 47.30, y = 72.08, name = "Slayer's Rise" },
    { mapID = 2405, x = 26.52, y = 67.09, name = "Stormarion Citadel" },
    { mapID = 2405, x = 35.87, y = 57.89, name = "The Ingress" },
    { mapID = 2405, x = 51.41, y = 56.06, name = "The Voidspire" },
    { mapID = 2405, x = 64.00, y = 61.77, name = "Nexus-Point Xenas" },
}
local EXPLORE_VOIDSTORM_REWARD = nil
local THRILL_OF_THE_CHASE_ENTRIES = {}
local THRILL_OF_THE_CHASE_REWARD = nil
local A_SINGULAR_PROBLEM_ENTRIES = {}
local A_SINGULAR_PROBLEM_REWARD = nil
local EXPLORE_ZULAMAN_ENTRIES = {
    { mapID = 2536, x = 25.74, y = 47.30, name = "Atal'Aman" },
    { mapID = 2437, x = 43.50, y = 66.89, name = "Amani'Zar Village" },
    { mapID = 2437, x = 51.77, y = 80.10, name = "Temple of Akil'zon" },
    { mapID = 2437, x = 33.09, y = 32.71, name = "Temple of Halazzi" },
    { mapID = 2437, x = 51.14, y = 24.06, name = "Temple of Jan'alai" },
    { mapID = 2437, x = 31.58, y = 83.86, name = "Den of Nalorakk" },
    { mapID = 2437, x = 38.09, y = 26.84, name = "Witherbark Bluffs" },
    { mapID = 2437, x = 29.86, y = 77.36, name = "Broken Throne" },
    { mapID = 2437, x = 43.39, y = 42.95, name = "Maisara Deeps" },
    { mapID = 2437, x = 53.13, y = 54.45, name = "Strait of Hexx'alor" },
}
local EXPLORE_ZULAMAN_REWARD = nil
local EXPLORE_HARANDAR_ENTRIES = {
    { mapID = 2413, x = 72.97, y = 57.78, name = "Har'kuai" },
    { mapID = 2413, x = 58.68, y = 24.08, name = "Har'athir" },
    { mapID = 2413, x = 45.58, y = 28.00, name = "Blooming Lattice" },
    { mapID = 2413, x = 67.67, y = 71.93, name = "The Blinding Bloom" },
    { mapID = 2413, x = 39.39, y = 65.25, name = "The Grudge Pit" },
    { mapID = 2413, x = 38.78, y = 78.16, name = "The Rift of Aln" },
    { mapID = 2413, x = 27.39, y = 81.54, name = "Fungara Village" },
    { mapID = 2413, x = 53.56, y = 43.07, name = "The Den" },
    { mapID = 2413, x = 29.98, y = 46.21, name = "Gloom Mire" },
    { mapID = 2413, x = 62.17, y = 55.44, name = "Har'mara" },
}
local EXPLORE_HARANDAR_REWARD = nil
local ABUNDANCE_PROSPEROUS_PLENTITUDE_ENTRIES = {
    { mapID = 2395, x = 56.73, y = 65.78, name = "Eversong Woods: Watha'nan Crypts" },
    { mapID = 2437, x = 31.61, y = 26.09, name = "Zul'Aman: Loaknit Den" },
    { mapID = 2413, x = 66.21, y = 61.67, name = "Harandar: Floaret Grotto" },
    { mapID = 2405, x = 38.85, y = 53.37, name = "Voidstorm: Abundant Voidburrow" },
}
local ABUNDANCE_PROSPEROUS_PLENTITUDE_REWARD = nil
local ALTAR_OF_BLESSINGS_REWARD = nil
local FOREVER_SONG_CHILDREN = {
    { id = 61960, name = "Treasures of Eversong Woods", subView = "treasures", selectedID = 61960 },
    { id = 61855, name = "Explore Eversong Woods", subView = "exploreeversong" },
    { id = 61507, name = "A Bloody Song", subView = "rares", selectedID = 61507 },
    { id = 61961, name = "Runestone Rush", subView = "runestonerush" },
    { id = 62186, name = "The Party Must Go On", subView = "partymustgoon" },
    { id = 62185, name = "Ever Painting", subView = "everpainting" },
}
local FOREVER_SONG_REWARD = nil
local YELLING_INTO_THE_VOIDSTORM_CHILDREN = {
    { name = "The Ultimate Predator", subView = "rares", selectedID = 62130 },
    { name = "Treasures of Voidstorm", subView = "treasures", selectedID = 62126 },
    { name = "Explore Voidstorm", subView = "explorevoidstorm" },
    { name = "Thrill of the Chase", subView = "thrillofthechase" },
    { name = "A Singular Problem", subView = "asingularproblem" },
}
local YELLING_INTO_THE_VOIDSTORM_REWARD = nil
local LIGHT_UP_THE_NIGHT_CHILDREN = {
    { id = 62261, name = "Forever Song", subView = "foreversong" },
    { id = 61453, name = "Making an Amani Out of You", subView = "makinganamani" },
    { id = 62260, name = "That's Aln, Folks!", subView = "thatsalnfolks" },
    { id = 62256, name = "Yelling into the Voidstorm", subView = "yellingintovoidstorm" },
}
local LIGHT_UP_THE_NIGHT_REWARD = { type = "item", itemID = 252011, label = "Mount: Brilliant Petalwing" }
local MAKING_AN_AMANI_OUT_OF_YOU_CHILDREN = {
    { name = "Treasures of Zul'Aman", subView = "treasures", selectedID = 62125 },
    { name = "Tallest Tree in the Forest", subView = "rares", selectedID = 62122 },
    { name = "Explore Zul'Aman", subView = "explorezulaman" },
    { name = "Abundance: Prosperous Plentitude!", subView = "abundanceprosperous" },
    { name = "Altar of Blessings: Sacred Buffet Devotee", subView = "altarofblessings" },
}
local MAKING_AN_AMANI_OUT_OF_YOU_REWARD = nil
local THATS_ALN_FOLKS_CHILDREN = {
    { name = "Treasures of Harandar", subView = "treasures", selectedID = 61263 },
    { name = "Explore Harandar", subView = "exploreharandar" },
    { name = "Leaf None Behind", subView = "rares", selectedID = 61264 },
    { name = "Chronicler of the Haranir", subView = "chronicleroftheharanir" },
    { name = "Legends Never Die", subView = "legendsneverdie" },
    { name = "No Time to Paws", subView = "notimetopaws" },
    { name = "Dust 'Em Off", subView = "dustemoff" },
    { name = "From The Cradle to the Grave", subView = "fromthecradletothegrave" },
}
local THATS_ALN_FOLKS_REWARD = nil
local CHRONICLER_OF_THE_HARANIR_REWARD_TEXT = "Title: \"Chronicler of the Haranir\""
local LEGENDS_NEVER_DIE_REWARD = { type = "item", itemID = 264259, label = "Housing Decor: On'ohia's Call" }
local DUST_EM_OFF_REWARD_TEXT = "Title: \"Dustlord\""
local DUST_MOTH_QUEST_OFFSETS = {
    [1] = 0, [2] = 60, [3] = 11, [4] = 99, [5] = 12, [6] = 34, [7] = 28, [8] = 46, [9] = 27, [10] = 45,
    [11] = 40, [12] = 72, [13] = 36, [14] = 74, [15] = 31, [16] = 42, [17] = 3, [18] = 73, [19] = 87, [20] = 97,
    [21] = 2, [22] = 88, [23] = 29, [24] = 82, [25] = 105, [26] = 63, [27] = 101, [28] = 89, [29] = 1, [30] = 104,
    [31] = 90, [32] = 35, [33] = 47, [34] = 55, [35] = 18, [36] = 62, [37] = 81, [38] = 33, [39] = 113, [40] = 10,
    [41] = 115, [42] = 56, [43] = 13, [44] = 57, [45] = 58, [46] = 109, [47] = 49, [48] = 20, [49] = 65, [50] = 76,
    [51] = 119, [52] = 93, [53] = 66, [54] = 103, [55] = 59, [56] = 106, [57] = 48, [58] = 30, [59] = 21, [60] = 83,
    [61] = 108, [62] = 85, [63] = 107, [64] = 61, [65] = 26, [66] = 86, [67] = 41, [68] = 37, [69] = 75, [70] = 64,
    [71] = 84, [72] = 120, [73] = 114, [74] = 24, [75] = 25, [76] = 19, [77] = 44, [78] = 96, [79] = 4, [80] = 94,
    [81] = 67, [82] = 68, [83] = 32, [84] = 95, [85] = 43, [86] = 110, [87] = 22, [88] = 23, [89] = 38, [90] = 98,
    [91] = 80, [92] = 39, [93] = 54, [94] = 79, [95] = 9, [96] = 78, [97] = 71, [98] = 8, [99] = 50, [100] = 118,
    [101] = 69, [102] = 100, [103] = 17, [104] = 116, [105] = 91, [106] = 15, [107] = 6, [108] = 51, [109] = 53, [110] = 7,
    [111] = 16, [112] = 92, [113] = 52, [114] = 5, [115] = 112, [116] = 70, [117] = 117, [118] = 14, [119] = 77, [120] = 111,
}
local DUST_MOTH_COORD_DATA = {
    { questID = 92196, moth = 1, renown = 1, x = 36.35, y = 48.39 },
    { questID = 92256, moth = 2, renown = 4, x = 36.97, y = 48.30 },
    { questID = 92207, moth = 3, renown = 1, x = 38.33, y = 47.44 },
    { questID = 92295, moth = 4, renown = 9, x = 34.61, y = 48.54 },
    { questID = 92208, moth = 5, renown = 1, x = 33.95, y = 44.04 },
    { questID = 92230, moth = 6, renown = 1, x = 41.61, y = 40.12 },
    { questID = 92224, moth = 7, renown = 4, x = 43.06, y = 39.45 },
    { questID = 92242, moth = 8, renown = 4, x = 43.26, y = 40.35 },
    { questID = 92223, moth = 9, renown = 4, x = 44.02, y = 38.12 },
    { questID = 92241, moth = 10, renown = 4, x = 41.95, y = 37.72 },
    { questID = 92236, moth = 11, renown = 4, x = 44.78, y = 35.69 },
    { questID = 92268, moth = 12, renown = 9, x = 47.73, y = 32.85 },
    { questID = 92232, moth = 13, renown = 1, x = 50.35, y = 33.60 },
    { questID = 92270, moth = 14, renown = 9, x = 54.54, y = 31.76 },
    { questID = 92227, moth = 15, renown = 1, x = 55.14, y = 32.88 },
    { questID = 92238, moth = 16, renown = 4, x = 58.67, y = 30.20 },
    { questID = 92199, moth = 17, renown = 1, x = 55.00, y = 27.55 },
    { questID = 92269, moth = 18, renown = 9, x = 52.42, y = 29.21 },
    { questID = 92283, moth = 19, renown = 9, x = 48.49, y = 28.27 },
    { questID = 92293, moth = 20, renown = 9, x = 48.55, y = 26.23 },
    { questID = 92198, moth = 21, renown = 1, x = 49.88, y = 25.51 },
    { questID = 92284, moth = 22, renown = 9, x = 47.76, y = 23.38 },
    { questID = 92225, moth = 23, renown = 1, x = 46.38, y = 24.88 },
    { questID = 92278, moth = 24, renown = 9, x = 43.18, y = 27.34 },
    { questID = 92301, moth = 25, renown = 1, x = 41.59, y = 27.44 },
    { questID = 92259, moth = 26, renown = 4, x = 42.19, y = 22.26 },
    { questID = 92297, moth = 27, renown = 9, x = 39.21, y = 18.35 },
    { questID = 92285, moth = 28, renown = 9, x = 34.63, y = 24.22 },
    { questID = 92197, moth = 29, renown = 1, x = 36.11, y = 26.39 },
    { questID = 92300, moth = 30, renown = 1, x = 40.44, y = 34.46 },
    { questID = 92286, moth = 31, renown = 9, x = 44.43, y = 45.18 },
    { questID = 92231, moth = 32, renown = 1, x = 47.63, y = 46.96 },
    { questID = 92243, moth = 33, renown = 4, x = 46.86, y = 48.47 },
    { questID = 92251, moth = 34, renown = 4, x = 48.27, y = 50.58 },
    { questID = 92214, moth = 35, renown = 1, x = 52.93, y = 50.65 },
    { questID = 92258, moth = 36, renown = 4, x = 54.49, y = 52.06 },
    { questID = 92277, moth = 37, renown = 9, x = 53.01, y = 55.98 },
    { questID = 92229, moth = 38, renown = 1, x = 53.76, y = 59.10 },
    { questID = 92309, moth = 39, renown = 9, x = 56.58, y = 57.16 },
    { questID = 92206, moth = 40, renown = 1, x = 59.44, y = 54.33 },
    { questID = 92311, moth = 41, renown = 9, x = 62.51, y = 53.75 },
    { questID = 92252, moth = 42, renown = 4, x = 61.24, y = 50.46 },
    { questID = 92209, moth = 43, renown = 1, x = 60.34, y = 48.58 },
    { questID = 92253, moth = 44, renown = 4, x = 60.72, y = 45.40 },
    { questID = 92254, moth = 45, renown = 4, x = 62.49, y = 44.32 },
    { questID = 92305, moth = 46, renown = 1, x = 59.98, y = 43.05 },
    { questID = 92245, moth = 47, renown = 4, x = 62.43, y = 40.85 },
    { questID = 92216, moth = 48, renown = 4, x = 63.74, y = 41.45 },
    { questID = 92261, moth = 49, renown = 4, x = 65.89, y = 44.71 },
    { questID = 92272, moth = 50, renown = 9, x = 67.04, y = 48.39 },
    { questID = 92315, moth = 51, renown = 9, x = 69.44, y = 48.98 },
    { questID = 92289, moth = 52, renown = 9, x = 65.14, y = 50.85 },
    { questID = 92262, moth = 53, renown = 4, x = 63.99, y = 48.63 },
    { questID = 92299, moth = 54, renown = 1, x = 56.58, y = 47.65 },
    { questID = 92255, moth = 55, renown = 4, x = 54.49, y = 38.85 },
    { questID = 92302, moth = 56, renown = 1, x = 50.63, y = 40.62 },
    { questID = 92244, moth = 57, renown = 4, x = 61.42, y = 37.12 },
    { questID = 92226, moth = 58, renown = 1, x = 62.34, y = 37.14 },
    { questID = 92217, moth = 59, renown = 4, x = 61.28, y = 35.17 },
    { questID = 92279, moth = 60, renown = 9, x = 66.50, y = 33.10 },
    { questID = 92304, moth = 61, renown = 1, x = 69.03, y = 31.20 },
    { questID = 92281, moth = 62, renown = 9, x = 68.25, y = 27.78 },
    { questID = 92303, moth = 63, renown = 1, x = 65.43, y = 27.12 },
    { questID = 92257, moth = 64, renown = 4, x = 67.97, y = 19.99 },
    { questID = 92222, moth = 65, renown = 4, x = 60.34, y = 17.77 },
    { questID = 92282, moth = 66, renown = 9, x = 56.02, y = 24.52 },
    { questID = 92237, moth = 67, renown = 4, x = 51.38, y = 20.32 },
    { questID = 92233, moth = 68, renown = 1, x = 68.69, y = 36.33 },
    { questID = 92271, moth = 69, renown = 9, x = 71.17, y = 39.10 },
    { questID = 92260, moth = 70, renown = 4, x = 72.87, y = 37.19 },
    { questID = 92280, moth = 71, renown = 9, x = 72.04, y = 33.14 },
    { questID = 92316, moth = 72, renown = 9, x = 75.83, y = 50.15 },
    { questID = 92310, moth = 73, renown = 9, x = 74.09, y = 53.39 },
    { questID = 92220, moth = 74, renown = 4, x = 74.00, y = 57.23 },
    { questID = 92221, moth = 75, renown = 4, x = 71.71, y = 58.82 },
    { questID = 92215, moth = 76, renown = 1, x = 71.38, y = 58.63 },
    { questID = 92240, moth = 77, renown = 4, x = 73.71, y = 61.73 },
    { questID = 92292, moth = 78, renown = 9, x = 69.35, y = 62.94 },
    { questID = 92200, moth = 79, renown = 1, x = 66.30, y = 62.82 },
    { questID = 92290, moth = 80, renown = 9, x = 62.57, y = 64.63 },
    { questID = 92263, moth = 81, renown = 4, x = 62.49, y = 58.67 },
    { questID = 92264, moth = 82, renown = 4, x = 65.30, y = 57.74 },
    { questID = 92228, moth = 83, renown = 1, x = 66.96, y = 56.57 },
    { questID = 92291, moth = 84, renown = 9, x = 71.73, y = 67.45 },
    { questID = 92239, moth = 85, renown = 4, x = 73.71, y = 68.30 },
    { questID = 92306, moth = 86, renown = 1, x = 67.73, y = 68.86 },
    { questID = 92218, moth = 87, renown = 4, x = 55.79, y = 66.64 },
    { questID = 92219, moth = 88, renown = 4, x = 55.61, y = 64.29 },
    { questID = 92234, moth = 89, renown = 1, x = 50.26, y = 69.66 },
    { questID = 92294, moth = 90, renown = 9, x = 49.04, y = 70.69 },
    { questID = 92276, moth = 91, renown = 9, x = 46.10, y = 71.84 },
    { questID = 92235, moth = 92, renown = 1, x = 49.26, y = 75.52 },
    { questID = 92250, moth = 93, renown = 4, x = 51.88, y = 76.62 },
    { questID = 92275, moth = 94, renown = 9, x = 50.10, y = 80.17 },
    { questID = 92205, moth = 95, renown = 1, x = 52.41, y = 80.78 },
    { questID = 92274, moth = 96, renown = 9, x = 54.00, y = 73.03 },
    { questID = 92267, moth = 97, renown = 9, x = 47.24, y = 66.10 },
    { questID = 92204, moth = 98, renown = 1, x = 42.19, y = 66.51 },
    { questID = 92246, moth = 99, renown = 4, x = 41.34, y = 66.13 },
    { questID = 92314, moth = 100, renown = 9, x = 41.06, y = 67.35 },
    { questID = 92265, moth = 101, renown = 4, x = 41.34, y = 68.07 },
    { questID = 92296, moth = 102, renown = 9, x = 34.48, y = 68.99 },
    { questID = 92213, moth = 103, renown = 1, x = 32.06, y = 67.08 },
    { questID = 92312, moth = 104, renown = 9, x = 28.83, y = 66.91 },
    { questID = 92287, moth = 105, renown = 9, x = 27.39, y = 70.32 },
    { questID = 92211, moth = 106, renown = 1, x = 30.31, y = 73.39 },
    { questID = 92202, moth = 107, renown = 1, x = 33.37, y = 75.61 },
    { questID = 92247, moth = 108, renown = 4, x = 35.89, y = 74.26 },
    { questID = 92249, moth = 109, renown = 4, x = 36.09, y = 81.44 },
    { questID = 92203, moth = 110, renown = 1, x = 31.84, y = 81.76 },
    { questID = 92212, moth = 111, renown = 1, x = 32.62, y = 84.77 },
    { questID = 92288, moth = 112, renown = 9, x = 29.84, y = 87.65 },
    { questID = 92248, moth = 113, renown = 4, x = 30.80, y = 63.65 },
    { questID = 92201, moth = 114, renown = 1, x = 33.37, y = 63.49 },
    { questID = 92308, moth = 115, renown = 9, x = 39.36, y = 61.37 },
    { questID = 92266, moth = 116, renown = 4, x = 39.09, y = 55.10 },
    { questID = 92313, moth = 117, renown = 9, x = 40.88, y = 51.52 },
    { questID = 92210, moth = 118, renown = 1, x = 43.21, y = 53.65 },
    { questID = 92273, moth = 119, renown = 9, x = 45.01, y = 58.08 },
    { questID = 92307, moth = 120, renown = 1, x = 48.54, y = 55.35 },
}
local DUST_EM_OFF_GROUPS = {
    { name = "Group 1", note = "Moths 1-40 appear at Hara'ti Renown 1. Tracking unlocks at Renown 2.", entries = {
        { mapID = 2413, x = 42.18, y = 22.28, name = "Moth #49" },
        { mapID = 2413, x = 36.10, y = 26.40, name = "Moth #8" },
        { mapID = 2413, x = 41.59, y = 27.41, name = "Moth #12" },
        { mapID = 2413, x = 49.90, y = 25.50, name = "Moth #20" },
        { mapID = 2413, x = 34.00, y = 44.10, name = "Moth #7" },
        { mapID = 2413, x = 36.40, y = 48.30, name = "Moth #9" },
        { mapID = 2413, x = 36.97, y = 48.29, name = "Moth #44" },
        { mapID = 2413, x = 38.40, y = 47.40, name = "Moth #10" },
        { mapID = 2413, x = 41.70, y = 40.10, name = "Moth #13" },
        { mapID = 2413, x = 41.94, y = 37.73, name = "Moth #48" },
        { mapID = 2413, x = 43.03, y = 39.45, name = "Moth #50" },
        { mapID = 2413, x = 43.24, y = 40.36, name = "Moth #51" },
        { mapID = 2413, x = 43.97, y = 38.10, name = "Moth #52" },
        { mapID = 2413, x = 44.79, y = 35.69, name = "Moth #53" },
        { mapID = 2413, x = 46.88, y = 48.56, name = "Moth #54" },
        { mapID = 2413, x = 47.60, y = 46.90, name = "Moth #17" },
        { mapID = 2413, x = 48.30, y = 50.60, name = "Moth #55" },
        { mapID = 2413, x = 50.40, y = 33.60, name = "Moth #22" },
        { mapID = 2413, x = 50.60, y = 40.50, name = "Moth #23" },
        { mapID = 2413, x = 30.81, y = 63.67, name = "Moth #41" },
        { mapID = 2413, x = 32.00, y = 67.10, name = "Moth #3" },
        { mapID = 2413, x = 27.39, y = 70.32, name = "Moth #81" },
        { mapID = 2413, x = 28.83, y = 66.91, name = "Moth #82" },
        { mapID = 2413, x = 33.40, y = 63.50, name = "Moth #5" },
        { mapID = 2413, x = 39.11, y = 55.10, name = "Moth #45" },
        { mapID = 2413, x = 42.19, y = 66.52, name = "Moth #14" },
        { mapID = 2413, x = 41.34, y = 66.14, name = "Moth #46" },
        { mapID = 2413, x = 41.40, y = 68.00, name = "Moth #47" },
        { mapID = 2413, x = 31.90, y = 81.80, name = "Moth #2" },
        { mapID = 2413, x = 32.60, y = 84.80, name = "Moth #4" },
        { mapID = 2413, x = 35.91, y = 74.26, name = "Moth #42" },
        { mapID = 2413, x = 36.07, y = 81.44, name = "Moth #43" },
        { mapID = 2413, x = 33.40, y = 75.60, name = "Moth #6" },
        { mapID = 2413, x = 30.30, y = 73.40, name = "Moth #1" },
        { mapID = 2413, x = 34.48, y = 68.99, name = "Moth #84" },
        { mapID = 2413, x = 41.06, y = 67.35, name = "Moth #90" },
        { mapID = 2413, x = 49.29, y = 75.54, name = "Moth #19" },
        { mapID = 2413, x = 50.30, y = 69.60, name = "Moth #21" },
        { mapID = 2413, x = 52.41, y = 80.79, name = "Moth #24" },
        { mapID = 2413, x = 51.84, y = 76.46, name = "Moth #57" },
    } },
    { name = "Group 2", note = "Moths 41-80 appear at Hara'ti Renown 4. Tracking unlocks at Renown 6.", entries = {
        { mapID = 2413, x = 39.21, y = 18.35, name = "Moth #87" },
        { mapID = 2413, x = 34.63, y = 24.22, name = "Moth #86" },
        { mapID = 2413, x = 47.76, y = 23.38, name = "Moth #97" },
        { mapID = 2413, x = 46.34, y = 24.89, name = "Moth #16" },
        { mapID = 2413, x = 51.39, y = 20.31, name = "Moth #56" },
        { mapID = 2413, x = 48.55, y = 26.23, name = "Moth #99" },
        { mapID = 2413, x = 43.18, y = 27.34, name = "Moth #91" },
        { mapID = 2413, x = 48.49, y = 28.27, name = "Moth #98" },
        { mapID = 2413, x = 55.00, y = 27.40, name = "Moth #27" },
        { mapID = 2413, x = 56.02, y = 24.52, name = "Moth #106" },
        { mapID = 2413, x = 52.42, y = 29.21, name = "Moth #102" },
        { mapID = 2413, x = 58.61, y = 30.29, name = "Moth #62" },
        { mapID = 2413, x = 54.54, y = 31.76, name = "Moth #105" },
        { mapID = 2413, x = 55.14, y = 32.83, name = "Moth #28" },
        { mapID = 2413, x = 47.73, y = 32.85, name = "Moth #96" },
        { mapID = 2413, x = 40.40, y = 34.60, name = "Moth #11" },
        { mapID = 2413, x = 54.46, y = 38.87, name = "Moth #58" },
        { mapID = 2413, x = 34.61, y = 48.54, name = "Moth #85" },
        { mapID = 2413, x = 44.43, y = 45.18, name = "Moth #92" },
        { mapID = 2413, x = 56.57, y = 47.68, name = "Moth #29" },
        { mapID = 2413, x = 40.88, y = 51.52, name = "Moth #89" },
        { mapID = 2413, x = 52.90, y = 50.70, name = "Moth #25" },
        { mapID = 2413, x = 54.50, y = 52.01, name = "Moth #59" },
        { mapID = 2413, x = 43.25, y = 53.65, name = "Moth #15" },
        { mapID = 2413, x = 48.50, y = 55.30, name = "Moth #18" },
        { mapID = 2413, x = 53.01, y = 55.98, name = "Moth #103" },
        { mapID = 2413, x = 56.58, y = 57.16, name = "Moth #107" },
        { mapID = 2413, x = 60.00, y = 43.01, name = "Moth #31" },
        { mapID = 2413, x = 53.80, y = 59.10, name = "Moth #26" },
        { mapID = 2413, x = 45.01, y = 58.08, name = "Moth #93" },
        { mapID = 2413, x = 59.50, y = 54.40, name = "Moth #30" },
        { mapID = 2413, x = 39.36, y = 61.37, name = "Moth #88" },
        { mapID = 2413, x = 55.59, y = 64.28, name = "Moth #60" },
        { mapID = 2413, x = 47.24, y = 66.10, name = "Moth #95" },
        { mapID = 2413, x = 55.78, y = 66.69, name = "Moth #61" },
        { mapID = 2413, x = 49.04, y = 70.69, name = "Moth #100" },
        { mapID = 2413, x = 46.10, y = 71.84, name = "Moth #94" },
        { mapID = 2413, x = 54.00, y = 73.03, name = "Moth #104" },
        { mapID = 2413, x = 50.10, y = 80.17, name = "Moth #101" },
        { mapID = 2413, x = 29.84, y = 87.65, name = "Moth #83" },
    } },
    { name = "Group 3", note = "Moths 81-120 appear at Hara'ti Renown 9. Tracking unlocks at Renown 11.", entries = {
        { mapID = 2413, x = 60.31, y = 17.75, name = "Moth #63" },
        { mapID = 2413, x = 67.98, y = 19.98, name = "Moth #75" },
        { mapID = 2413, x = 65.40, y = 27.10, name = "Moth #34" },
        { mapID = 2413, x = 68.25, y = 27.78, name = "Moth #113" },
        { mapID = 2413, x = 69.03, y = 31.20, name = "Moth #39" },
        { mapID = 2413, x = 66.50, y = 33.10, name = "Moth #111" },
        { mapID = 2413, x = 72.04, y = 33.14, name = "Moth #118" },
        { mapID = 2413, x = 61.32, y = 35.18, name = "Moth #66" },
        { mapID = 2413, x = 68.70, y = 36.40, name = "Moth #38" },
        { mapID = 2413, x = 62.35, y = 37.09, name = "Moth #33" },
        { mapID = 2413, x = 61.43, y = 37.10, name = "Moth #67" },
        { mapID = 2413, x = 72.87, y = 37.16, name = "Moth #77" },
        { mapID = 2413, x = 71.17, y = 39.10, name = "Moth #116" },
        { mapID = 2413, x = 62.48, y = 40.78, name = "Moth #69" },
        { mapID = 2413, x = 63.70, y = 41.43, name = "Moth #71" },
        { mapID = 2413, x = 62.52, y = 44.26, name = "Moth #70" },
        { mapID = 2413, x = 65.88, y = 44.66, name = "Moth #74" },
        { mapID = 2413, x = 60.72, y = 45.41, name = "Moth #64" },
        { mapID = 2413, x = 67.04, y = 48.39, name = "Moth #112" },
        { mapID = 2413, x = 60.37, y = 48.61, name = "Moth #32" },
        { mapID = 2413, x = 64.03, y = 48.67, name = "Moth #72" },
        { mapID = 2413, x = 69.44, y = 48.98, name = "Moth #115" },
        { mapID = 2413, x = 75.83, y = 50.15, name = "Moth #120" },
        { mapID = 2413, x = 61.20, y = 50.47, name = "Moth #65" },
        { mapID = 2413, x = 65.14, y = 50.85, name = "Moth #110" },
        { mapID = 2413, x = 74.09, y = 53.39, name = "Moth #119" },
        { mapID = 2413, x = 62.51, y = 53.75, name = "Moth #108" },
        { mapID = 2413, x = 66.95, y = 56.59, name = "Moth #36" },
        { mapID = 2413, x = 73.99, y = 57.24, name = "Moth #80" },
        { mapID = 2413, x = 65.30, y = 57.69, name = "Moth #73" },
        { mapID = 2413, x = 71.42, y = 58.61, name = "Moth #76" },
        { mapID = 2413, x = 71.39, y = 58.64, name = "Moth #40" },
        { mapID = 2413, x = 62.46, y = 58.65, name = "Moth #68" },
        { mapID = 2413, x = 73.69, y = 61.71, name = "Moth #78" },
        { mapID = 2413, x = 66.30, y = 62.80, name = "Moth #35" },
        { mapID = 2413, x = 69.35, y = 62.94, name = "Moth #114" },
        { mapID = 2413, x = 62.57, y = 64.63, name = "Moth #109" },
        { mapID = 2413, x = 71.73, y = 67.45, name = "Moth #117" },
        { mapID = 2413, x = 73.71, y = 68.27, name = "Moth #79" },
        { mapID = 2413, x = 67.76, y = 68.86, name = "Moth #37" },
    } },
}
local MIDNIGHT_RARES_DETAILS = {
    [61507] = {
        { mapID = 2395, x = 51.84, y = 74.07, name = "Warden of Weeds", note = "Wanders.", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264520, label = "Warden's Leycrook" }, { itemID = 264613, label = "Steelbark Bulwark" } } },
        { mapID = 2395, x = 45.20, y = 79.15, name = "Harried Hawkstrider", note = "Runs around nearby.", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264521, label = "Striderplume Focus" }, { itemID = 264522, label = "Striderplume Armbands" } } },
        { mapID = 2395, x = 54.66, y = 60.76, name = "Overfester Hydra", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264523, label = "Hydrafang Blade" }, { itemID = 264524, label = "Lightblighted Verdant Vest" } } },
        { mapID = 2395, x = 36.48, y = 63.81, name = "Bloated Snapdragon", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264543, label = "Snapdragon Pantaloons" }, { itemID = 264560, label = "Sharpclaw Gauntlets" }, { itemID = 260647, label = "Digested Human Hand" } } },
        { mapID = 2395, x = 63.05, y = 49.85, name = "Cre'van", note = "Wanders the camp a bit.", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264573, label = "Taskmaster's Sadistic Shoulderguards" }, { itemID = 264647, label = "Cre'van's Punisher" } } },
        { mapID = 2395, x = 36.55, y = 36.24, name = "Coralfang", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264602, label = "Abyss Coral Band" }, { itemID = 264629, label = "Coralfang's Hefty Fin" } } },
        { mapID = 2395, x = 36.62, y = 77.32, name = "Lady Liminus", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264612, label = "Tarnished Gold Locket" }, { itemID = 264645, label = "Aged Farstrider Bow" }, { itemID = 260655, label = "Decaying Humanoid Flesh" } } },
        { mapID = 2395, x = 40.17, y = 85.32, name = "Terrinor", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264537, label = "Winged Terror Gloves" }, { itemID = 264546, label = "Bat Fur Boots" } } },
        { mapID = 2395, x = 48.99, y = 87.79, name = "Bad Zed", note = "Inside building, not on rock.", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264536, label = "Zedling Summoning Collar" }, { itemID = 264621, label = "Bad Zed's Worst Channeler" } } },
        { mapID = 2395, x = 34.85, y = 20.91, name = "Waverly", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264608, label = "String of Lovely Blossoms" }, { itemID = 264910, label = "Shell-Cleaving Poleaxe" } } },
        { mapID = 2395, x = 56.40, y = 77.12, name = "Banuran", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264526, label = "Supremely Slimy Sash" }, { itemID = 264552, label = "Frogskin Grips" } } },
        { mapID = 2395, x = 59.33, y = 79.26, name = "Lost Guardian", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264555, label = "Splintered Hexwood Clasps" }, { itemID = 264575, label = "Hexwood Helm" } } },
        { mapID = 2395, x = 42.58, y = 69.27, name = "Duskburn", note = "Patrols.", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264569, label = "Void-Gorged Kickers" }, { itemID = 264594, label = "Netherscale Cloak" } } },
        { mapID = 2395, x = 51.73, y = 45.70, name = "Malfunctioning Construct", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264584, label = "Stonecarved Smashers" }, { itemID = 264603, label = "Guardian's Gemstone Loop" } } },
        { mapID = 2395, x = 45.62, y = 38.78, name = "Dame Bloodshed", note = "Wanders.", rep = "50 Silvermoon Court rep", rewards = { { itemID = 264595, label = "Lynxhide Shawl" }, { itemID = 264624, label = "Fang of the Dame" } } },
    },
    [62122] = {
        { mapID = 2437, x = 34.42, y = 33.07, name = "Necrohexxer Raz'ka", rep = "50 Amani rep", rewards = { { itemID = 264527, label = "Vile Hexxer's Mantle" }, { itemID = 264611, label = "Pendant of Siphoned Vitality" } } },
        { mapID = 2437, x = 51.45, y = 18.44, name = "The Snapping Scourge", rep = "50 Amani rep", rewards = { { itemID = 264585, label = "Snapper Steppers" }, { itemID = 264617, label = "Scourge's Spike" } } },
        { mapID = 2437, x = 51.82, y = 72.88, name = "Skullcrusher Harak", rep = "50 Amani rep", rewards = { { itemID = 264542, label = "Skullcrusher's Mantle" }, { itemID = 264631, label = "Harak's Skullcutter" } } },
        { mapID = 2437, x = 28.73, y = 23.97, name = "Lightwood Borer", rep = "50 Amani rep", rewards = { { itemID = 264557, label = "Borerplate Pauldrons" }, { itemID = 264640, label = "Sharpened Borer Claw" } } },
        { mapID = 2437, x = 50.80, y = 65.19, name = "Mrrlokk", rep = "50 Amani rep", rewards = { { itemID = 264570, label = "Reinforced Chainmrrl" }, { itemID = 264580, label = "Mrrlokk's Mrgl Grrdle" } } },
        { mapID = 2437, x = 39.01, y = 50.02, name = "Poacher Rav'ik", rep = "50 Amani rep", rewards = { { itemID = 264627, label = "Rav'ik's Spare Hunting Spear" }, { itemID = 264911, label = "Forest Hunter's Arc" } } },
        { mapID = 2437, x = 30.65, y = 45.07, name = "Spinefrill", rep = "50 Amani rep", rewards = { { itemID = 264554, label = "Frilly Leather Vest" }, { itemID = 264620, label = "Pufferspine Spellpierce" } } },
        { mapID = 2437, x = 46.43, y = 51.90, name = "Oophaga", rep = "50 Amani rep", rewards = { { itemID = 264528, label = "Goop-Coated Leggings" }, { itemID = 264541, label = "Egg-Swaddling Sash" } } },
        { mapID = 2437, x = 47.88, y = 34.21, name = "Tiny Vermin", rep = "50 Amani rep", rewards = { { itemID = 264648, label = "Verminscale Gavel" }, { itemID = 264597, label = "Leechtooth Band" } } },
        { mapID = 2437, x = 21.27, y = 70.64, name = "Voidtouched Crustacean", rep = "50 Amani rep", rewards = { { itemID = 264564, label = "Crab Wrangling Harness" }, { itemID = 264586, label = "Crustacean Carapace Chestguard" } } },
        { mapID = 2437, x = 39.49, y = 20.11, name = "The Devouring Invader", note = "Cave entrance at 39.49, 19.95.", rep = "50 Amani rep", rewards = { { itemID = 264559, label = "Devourer's Visage" }, { itemID = 264638, label = "Fangs of the Invader" } } },
        { mapID = 2437, x = 33.69, y = 88.98, name = "Elder Oaktalon", rep = "50 Amani rep", rewards = { { itemID = 264547, label = "Worn Furbolg Bindings" }, { itemID = 264529, label = "Cover of the Furbolg Elder" } } },
        { mapID = 2437, x = 47.76, y = 20.97, name = "Depthborn Eelamental", rep = "50 Amani rep", rewards = { { itemID = 264598, label = "Eelectrum Signet" }, { itemID = 264618, label = "Strangely Eelastic Blade" } } },
        { mapID = 2437, x = 46.69, y = 43.45, name = "The Decaying Diamondback", rep = "50 Amani rep", rewards = { { itemID = 264525, label = "Wrapped Antenna Cuffs" }, { itemID = 264582, label = "Diamondback-Scale Legguards" } } },
        { mapID = 2437, x = 45.11, y = 41.48, name = "Ash'an the Empowered", rep = "50 Amani rep", rewards = { { itemID = 264593, label = "Warcloak of the Butcher" }, { itemID = 264643, label = "Ash'an's Spare Cleaver" } } },
    },
    [61264] = {
        { mapID = 2413, x = 51.17, y = 45.34, name = "Rhazul", rep = "50 Hara'ti rep", rewards = { { itemID = 264530, label = "Grimfur Mittens" }, { itemID = 264622, label = "Grimfang Shank" } } },
        { mapID = 2413, x = 68.66, y = 39.04, name = "Chironex", rep = "50 Hara'ti rep", rewards = { { itemID = 264538, label = "Translucent Membrane Slippers" }, { itemID = 264544, label = "Grounded Death Cap" } } },
        { mapID = 2413, x = 69.03, y = 59.95, name = "Ha'kalawe", rep = "50 Hara'ti rep", rewards = { { itemID = 264553, label = "Deepspore Leather Galoshes" }, { itemID = 264592, label = "Ha'kalawe's Flawless Wing" } } },
        { mapID = 2413, x = 72.64, y = 69.34, name = "Tallcap the Truthspreader", rep = "50 Hara'ti rep", rewards = { { itemID = 264532, label = "Robes of Flowing Truths" }, { itemID = 264650, label = "Truthspreader's Truth Spreader" } } },
        { mapID = 2413, x = 59.86, y = 47.02, name = "Queen Lashtongue", rep = "50 Hara'ti rep", rewards = { { itemID = 264566, label = "Lashtongue's Leaffroggers" }, { itemID = 264571, label = "Ironleaf Wristguards" } } },
        { mapID = 2413, x = 64.43, y = 47.52, name = "Chlorokyll", rep = "50 Hara'ti rep", rewards = { { itemID = 264604, label = "Sludgy Verdant Signet" }, { itemID = 264626, label = "Scepter of Radiant Conversion" } } },
        { mapID = 2413, x = 65.77, y = 32.86, name = "Stumpy", rep = "50 Hara'ti rep", rewards = { { itemID = 264635, label = "Stumpy's Stump" }, { itemID = 264578, label = "Stumpy's Terrorplate" } } },
        { mapID = 2413, x = 56.82, y = 34.09, name = "Serrasa", rep = "50 Hara'ti rep", rewards = { { itemID = 264568, label = "Serrated Scale Gauntlets" }, { itemID = 264639, label = "Razorfang Hacker" } } },
        { mapID = 2413, x = 45.61, y = 29.69, name = "Mindrot", rep = "50 Hara'ti rep", rewards = { { itemID = 264550, label = "Fungal Stalker's Stockings" }, { itemID = 264649, label = "Mindrot Claw-Hammer" } } },
        { mapID = 2413, x = 40.65, y = 43.13, name = "Dracaena", rep = "50 Hara'ti rep", rewards = { { itemID = 264562, label = "Plated Grove Vest" }, { itemID = 264644, label = "Crawler's Mindscythe" } } },
        { mapID = 2413, x = 36.56, y = 74.83, name = "Treetop", rep = "50 Hara'ti rep", rewards = { { itemID = 264633, label = "Treetop Battlestave" }, { itemID = 264581, label = "Bloombark Spaulders" } } },
        { mapID = 2413, x = 28.10, y = 81.83, name = "Oro'ohna", rep = "50 Hara'ti rep", rewards = { { itemID = 264591, label = "Radiant Petalwing's Feather" }, { itemID = 264616, label = "Lightblighted Sapdrinker" } } },
        { mapID = 2413, x = 27.38, y = 71.39, name = "Pterrock", rep = "50 Hara'ti rep", rewards = { { itemID = 264567, label = "Rockscale Hood" }, { itemID = 264576, label = "Slatescale Grips" } } },
        { mapID = 2413, x = 39.66, y = 60.76, name = "Ahl'ua'huhi", rep = "50 Hara'ti rep", rewards = { { itemID = 264534, label = "Bogvine Shoulderguards" }, { itemID = 264540, label = "Mirevine Wristguards" } } },
        { mapID = 2413, x = 44.42, y = 15.99, name = "Annulus the Worldshaker", rep = "50 Hara'ti rep", rewards = { { itemID = 264607, label = "Spore-Laden Choker" }, { itemID = 264614, label = "Fungal Cap Guard" } } },
    },
    [62130] = {
        { mapID = 2405, x = 29.52, y = 50.05, name = "Sundereth the Caller", rep = "50 Singularity rep", rewards = { { itemID = 264619, label = "Nethersteel Spellblade" }, { itemID = 264539, label = "Robes of the Voidcaller" } } },
        { mapID = 2405, x = 34.12, y = 82.13, name = "Territorial Voidscythe", rep = "50 Singularity rep", rewards = { { itemID = 264565, label = "Voidscale Shoulderpads" }, { itemID = 264642, label = "Carving Voidscythe" } } },
        { mapID = 2405, x = 35.68, y = 81.16, name = "Tremora", rep = "50 Singularity rep", rewards = { { itemID = 264610, label = "Escaped Specimen's ID Tag" }, { itemID = 264646, label = "Specimen Sinew Longbow" } } },
        { mapID = 2405, x = 43.69, y = 51.48, name = "Screammaxa the Matriarch", rep = "50 Singularity rep", rewards = { { itemID = 264545, label = "Harrower-Claw Grips" }, { itemID = 264583, label = "Barbute of the Winged Hunter" } } },
        { mapID = 2405, x = 47.16, y = 79.77, name = "Bane of the Vilebloods", rep = "50 Singularity rep", rewards = { { itemID = 264558, label = "Vileblood Resistant Sabatons" }, { itemID = 264572, label = "Netherplate Clasp" } } },
        { mapID = 2405, x = 39.49, y = 64.61, name = "Aeonelle Blackstar", rep = "50 Singularity rep", rewards = { { itemID = 264549, label = "Ever-Devouring Shoulderguards" }, { itemID = 264637, label = "Cosmic Hunter's Glaive" } } },
        { mapID = 2405, x = 37.88, y = 71.79, name = "Lotus Darkblossom", rep = "50 Singularity rep", rewards = { { itemID = 264632, label = "Darkblossom's Crook" }, { itemID = 264548, label = "Sash of Cosmic Tranquility" } } },
        { mapID = 2405, x = 55.70, y = 79.47, name = "Queen o' War", rep = "50 Singularity rep", rewards = { { itemID = 264533, label = "Queen's Tentacle Sash" }, { itemID = 264601, label = "Queen's Eye Band" } } },
        { mapID = 2405, x = 48.81, y = 53.00, name = "Ravengerus", rep = "50 Singularity rep", rewards = { { itemID = 264535, label = "Leggings of the Cosmic Harrower" }, { itemID = 264589, label = "Voidfused Wing Cloak" } } },
        { mapID = 2444, x = 46.36, y = 40.96, name = "Rakshur the Bonegrinder", rep = "50 Singularity rep", rewards = { { itemID = 264561, label = "Primal Bonestompers" }, { itemID = 264630, label = "Colossal Voidsunderer" } } },
        { mapID = 2405, x = 35.62, y = 49.37, name = "Bilemaw the Gluttonous", rep = "50 Singularity rep", rewards = { { itemID = 264579, label = "Hungering Wristplates" }, { itemID = 264623, label = "Shredding Fang" } } },
        { mapID = 2444, x = 41.03, y = 89.14, name = "Eruundi", note = "Patrols around Master's Perch.", rep = "50 Singularity rep", rewards = { { itemID = 264563, label = "Eruundi's Wristguards" }, { itemID = 264600, label = "Ancient Argussian Band" } } },
        { mapID = 2405, x = 40.19, y = 41.40, name = "Nightbrood", rep = "50 Singularity rep", rewards = { { itemID = 264551, label = "Nightbrood's Jaw" }, { itemID = 264574, label = "Netherterror's Legplates" } } },
        { mapID = 2405, x = 53.96, y = 62.73, name = "Far'thana the Mad", rep = "50 Singularity rep", rewards = { { itemID = 264912, label = "Void-Channeler's Spire" }, { itemID = 264913, label = "Focused Netherslicer" } } },
    },
}
local MIDNIGHT_HIGHEST_PEAKS_WAYPOINTS = {
    [62288] = {
        { mapID = 2393, x = 20.12, y = 79.73, name = "Telescope #1" },
        { mapID = 2395, x = 40.40, y = 10.08, name = "Telescope #2" },
        { mapID = 2395, x = 54.59, y = 51.02, name = "Telescope #3" },
        { mapID = 2395, x = 37.40, y = 47.87, name = "Telescope #4" },
        { mapID = 2395, x = 50.21, y = 85.45, name = "Telescope #5" },
    },
    [62289] = {
        { mapID = 2395, x = 63.65, y = 85.12, name = "Telescope #1" },
        { mapID = 2437, x = 53.03, y = 82.04, name = "Telescope #2" },
        { mapID = 2437, x = 57.70, y = 21.24, name = "Telescope #3" },
        { mapID = 2437, x = 41.86, y = 41.61, name = "Telescope #4" },
        { mapID = 2437, x = 27.79, y = 69.95, name = "Telescope #5" },
    },
    [62290] = {
        { mapID = 2413, x = 53.47, y = 58.60, name = "Telescope #1" },
        { mapID = 2413, x = 49.38, y = 75.94, name = "Telescope #2" },
        { mapID = 2413, x = 69.20, y = 46.38, name = "Telescope #3" },
        { mapID = 2413, x = 69.38, y = 63.37, name = "Telescope #4" },
        { mapID = 2413, x = 68.20, y = 25.93, name = "Telescope #5" },
    },
    [62291] = {
        { mapID = 2405, x = 41.75, y = 70.26, name = "Telescope #1" },
        { mapID = 2405, x = 39.66, y = 61.18, name = "Telescope #2" },
        { mapID = 2405, x = 55.46, y = 67.20, name = "Telescope #3" },
        { mapID = 2405, x = 37.80, y = 54.98, name = "Telescope #4" },
        { mapID = 2405, x = 36.49, y = 44.33, name = "Telescope #5" },
    },
}
local MIDNIGHT_HIGHEST_PEAKS_REWARDS = {
    [62288] = { type = "item", itemID = 254773, rewardID = 10542, label = "Painting: Eversong Lantern" },
    [62289] = { type = "item", itemID = 256925, rewardID = 11325, label = "Housing Decor: Amani Spearhunter's Spit" },
    [62290] = { type = "item", itemID = 265792, rewardID = 17516, label = "Housing Decor: Fungarian Vine Fence" },
    [62291] = { type = "item", itemID = 264656, rewardID = 15890, label = "Housing Decor: Void Elf Weapon Rack" },
}
local MIDNIGHT_HIGHEST_PEAKS_RENOWN_KEYS = {
    [62288] = "BUTTON_SILVERMOON_COURT",
    [62289] = "BUTTON_AMANI_TRIBE",
    [62290] = "BUTTON_HARATI",
    [62291] = "BUTTON_SINGULARITY",
}
local MIDNIGHT_HIGHEST_PEAKS_RENOWN_ATLASES = {
    [62288] = "majorfactions_icons_light512",
    [62289] = "majorfactions_icons_origin512",
    [62290] = "majorfactions_icons_root512",
    [62291] = "majorfactions_icons_sky512",
}



local ACH = {
    MIDNIGHT_GLYPH_HUNTER = 61584,
    GLORY_OF_THE_MIDNIGHT_DELVER = 61906,
    MIDNIGHT_HIGHEST_PEAKS = 62057,
    EVER_PAINTING = 62185,
    RUNESTONE_RUSH = 61961,
    THE_PARTY_MUST_GO_ON = 62186,
    EXPLORE_EVERSONG_WOODS = 61855,
    FOREVER_SONG = 62261,
    LIGHT_UP_THE_NIGHT = 62386,
    THATS_ALN_FOLKS = 62260,
    YELLING_INTO_THE_VOIDSTORM = 62256,
    EXPLORE_VOIDSTORM = 61857,
    THRILL_OF_THE_CHASE = 62133,
    A_SINGULAR_PROBLEM = 61913,
    MAKING_AN_AMANI_OUT_OF_YOU = 61453,
    EXPLORE_ZULAMAN = 61856,
    EXPLORE_HARANDAR = 61520,
    ABUNDANCE_PROSPEROUS_PLENTITUDE = 61943,
    ALTAR_OF_BLESSINGS = 62121,
    NO_TIME_TO_PAWS = 61219,
    CHRONICLER_OF_THE_HARANIR = 61344,
    LEGENDS_NEVER_DIE = 61574,
    DUST_EM_OFF = 61052,
    FROM_THE_CRADLE_TO_THE_GRAVE = 61860,
}
local REWARD_ITEM = {
    CRIMSON_DRAGONHAWK = 257145,
    GIGANTO_MANIS = 257199,
}
local function HasAchievement(achievementID)
    if not achievementID then
        return false
    end
    local _, _, _, completed = GetAchievementInfo(achievementID)
    return completed and true or false
end

local function GetAchievementName(achievementID, fallback)
    if achievementID and GetAchievementInfo then
        local _, name = GetAchievementInfo(achievementID)
        if name and name ~= "" then
            return name
        end
    end
    return fallback or ("Achievement " .. tostring(achievementID))
end

local function GetAchievementDescription(achievementID)
    if achievementID and GetAchievementInfo then
        local _, _, _, _, _, _, _, description = GetAchievementInfo(achievementID)
        if description and description ~= "" then
            return description
        end
    end
    return nil
end

local function GetAchievementRewardText(achievementID)
    if achievementID and GetAchievementInfo then
        local _, _, _, _, _, _, _, _, _, _, rewardText = GetAchievementInfo(achievementID)
        if rewardText and rewardText ~= "" then
            return rewardText
        end
    end
    return nil
end

local function GetMountRewardInfoByName(mountName)
    if not (mountName and C_MountJournal and C_MountJournal.GetMountIDs and C_MountJournal.GetMountInfoByID) then
        return nil
    end
    for _, journalID in ipairs(C_MountJournal.GetMountIDs() or {}) do
        local name, spellID, icon = C_MountJournal.GetMountInfoByID(journalID)
        if name == mountName then
            return {
                journalID = journalID,
                spellID = spellID,
                icon = icon,
                name = name,
            }
        end
    end
    return nil
end

local function GetAchievementRewardDisplayInfo(achievementID, rewardText)
    local override = achievementID and TREASURE_ACHIEVEMENT_REWARDS[achievementID]
    if override then
        if override.type == "mount" and override.name then
            local mountInfo = GetMountRewardInfoByName(override.name)
            return {
                icon = mountInfo and mountInfo.icon or nil,
                label = override.label or ("Mount: " .. override.name),
                tooltipType = "mount",
                tooltipValue = mountInfo and mountInfo.spellID or nil,
            }
        end
        if override.type == "item" and override.itemID then
            return {
                icon = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(override.itemID) or nil,
                label = override.label or rewardText,
                tooltipType = "item",
                tooltipValue = override.itemID,
            }
        end
    end
    if rewardText and rewardText ~= "" then
        return {
            label = rewardText,
        }
    end
    return nil
end

local function SetAchievementTreasureWaypoint(mapID, x, y, title)
    if not (mapID and x and y) then
        return
    end

    local nx, ny = x / 100, y / 100
    local displayTitle = title or "Treasure"

    if _G.TomTom and _G.TomTom.AddWaypoint then
        _G.TomTom:AddWaypoint(mapID, nx, ny, { title = displayTitle, persistent = false, minimap = true, world = true })
        return
    end

    if C_Map and C_Map.SetUserWaypoint and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        local point = UiMapPoint.CreateFromCoordinates(mapID, nx, ny)
        if point then
            C_Map.SetUserWaypoint(point)
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
    end
end

local function ApplyMetaAchievementOverlay(view)
    if not view or view.MetaOverlay then
        return view and view.MetaOverlay or nil
    end
    local overlay = view:CreateTexture(nil, "ARTWORK", nil, 1)
    overlay:SetTexture("Interface\\AddOns\\LiteVault\\MetaOverlay.png")
    overlay:SetTexCoord(248 / 1536, 1288 / 1536, 40 / 1024, 904 / 1024)
    overlay:SetPoint("TOPLEFT", view, "TOPLEFT", -18, 18)
    overlay:SetPoint("BOTTOMRIGHT", view, "BOTTOMRIGHT", 18, -18)
    overlay:SetBlendMode("BLEND")
    overlay:SetAlpha(1)
    view.MetaOverlay = overlay
    return overlay
end

local function CreateMetaAchievementHomeOverlay(parent, btn, note)
    if not (parent and btn and note) then
        return nil
    end
    local box = CreateFrame("Frame", nil, parent)
    box:SetPoint("TOPLEFT", btn, "TOPLEFT", -10, 26)
    box:SetPoint("BOTTOMRIGHT", note, "BOTTOMRIGHT", 10, -22)
    local overlay = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    overlay:SetTexture("Interface\\AddOns\\LiteVault\\MetaOverlay.png")
    overlay:SetTexCoord(248 / 1536, 1288 / 1536, 40 / 1024, 904 / 1024)
    overlay:SetPoint("TOPLEFT", box, "TOPLEFT", -18, 32)
    overlay:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 18, -24)
    overlay:SetBlendMode("BLEND")
    overlay:SetAlpha(0.98)
    box.Overlay = overlay
    return box
end

local function GetAchievementCriteriaRows(achievementID)
    local rows = {}
    local count = GetAchievementNumCriteria and GetAchievementNumCriteria(achievementID) or 0
    if not GetAchievementCriteriaInfo then return rows end
    for index = 1, count do
        local desc, _, completed = GetAchievementCriteriaInfo(achievementID, index)
        if desc and desc ~= "" then
            rows[#rows + 1] = {
                text = desc,
                done = completed and true or false,
            }
        end
    end
    return rows
end

local function NormalizeAchievementTreasureName(text)
    if not text or text == "" then
        return nil
    end
    local normalized = tostring(text):lower()
    normalized = normalized:gsub("|c%x%x%x%x%x%x%x%x", "")
    normalized = normalized:gsub("|r", "")
    normalized = normalized:gsub("[^%w%s]", "")
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:gsub("^%s+", "")
    normalized = normalized:gsub("%s+$", "")
    return normalized
end

local function GetDustMothQuestIDForCoord(x, y)
    if not (x and y) then
        return nil
    end
    local bestQuestID
    local bestDistanceSq
    local maxDistanceSq = 0.80 * 0.80
    for _, info in ipairs(DUST_MOTH_COORD_DATA or {}) do
        local dx = x - info.x
        local dy = y - info.y
        local distanceSq = (dx * dx) + (dy * dy)
        if distanceSq <= maxDistanceSq and (not bestDistanceSq or distanceSq < bestDistanceSq) then
            bestDistanceSq = distanceSq
            bestQuestID = info.questID
        end
    end
    return bestQuestID
end

local function IsDustMothCollected(info)
    local questID = info and GetDustMothQuestIDForCoord(info.x, info.y)
    if not (questID and C_QuestLog) then
        return false
    end
    if C_QuestLog.IsQuestFlaggedCompletedOnAccount then
        return C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) and true or false
    end
    if C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
    end
    return false
end

local function HasMountRewardFromItem(itemID)
    if not (itemID and C_MountJournal and C_MountJournal.GetMountIDs and C_MountJournal.GetMountInfoByID) then
        return false
    end
    local rewardName = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
    if not rewardName or rewardName == "" then
        if C_Item and C_Item.RequestLoadItemDataByID then
            C_Item.RequestLoadItemDataByID(itemID)
        end
        return false
    end
    for _, journalID in ipairs(C_MountJournal.GetMountIDs() or {}) do
        local name, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(journalID)
        if name == rewardName then
            return isCollected and true or false
        end
    end
    return false
end


function lv.InitAchievementsUI(env)
local LVWindow = env.LVWindow
local dashboardTab = env.dashboardTab
local instancesTab = env.instancesTab
local achievementsBtn = env.achievementsBtn
local factionsTab = env.factionsTab
local optionsTab = env.optionsTab
local currentMainView = (env.getCurrentMainView and env.getCurrentMainView()) or "dashboard"
local UIText = env.UIText or lv.UIText or function(key, fallback)
    local value = L and L[key]
    if value == nil or value == "" or value == key then
        return fallback or key
    end
    return value
end
local RefreshAchievementsView
local function SetDashboardContentVisible(visible)
    if env.setDashboardContentVisible then
        env.setDashboardContentVisible(visible)
    end
end
local function SetFactionCardsVisible(visible)
    if env.setFactionCardsVisible then
        env.setFactionCardsVisible(visible)
    end
end
local function GetFactionWeeklyWindow()
    if env.getFactionWeeklyWindow then
        return env.getFactionWeeklyWindow()
    end
    return nil
end
local AchievementView = CreateFrame("Frame", nil, LVWindow, "BackdropTemplate")
AchievementView:SetPoint("TOPLEFT", 35, -65)
AchievementView:SetPoint("BOTTOMRIGHT", -15, 25)
AchievementView:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 14,
})
AchievementView:Hide()
lv.AchievementView = AchievementView

do
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        AchievementView:SetBackdropColor(unpack(t.backgroundTransparent))
        AchievementView:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end

local achievementsTitle = AchievementView:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
achievementsTitle:SetPoint("TOPLEFT", 18, -14)
achievementsTitle:SetText(UIText("TITLE_ACHIEVEMENTS", "Achievements"))

local achievementsSubtitle = AchievementView:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
achievementsSubtitle:SetPoint("TOPLEFT", 18, -38)
achievementsSubtitle:SetJustifyH("LEFT")
achievementsSubtitle:SetText(UIText("DESC_ACHIEVEMENTS", "Choose an achievement tracker to view detailed progress."))

local achievementSubView = "home"

local achievementHome = CreateFrame("Frame", nil, AchievementView)
achievementHome:SetPoint("TOPLEFT", 0, 0)
achievementHome:SetPoint("BOTTOMRIGHT", 0, 0)
local home = {}

home.treasureLaunchBtn = CreateFrame("Button", nil, achievementHome, "BackdropTemplate")
home.treasureLaunchBtn:SetSize(220, 34)
home.treasureLaunchBtn:SetPoint("TOPLEFT", 18, -118)
home.treasureLaunchBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
home.treasureLaunchBtn.Text = home.treasureLaunchBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
home.treasureLaunchBtn.Text:SetPoint("CENTER")
home.treasureLaunchBtn.Text:SetText(UIText("Treasures of Midnight", "Treasures of Midnight"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(home.treasureLaunchBtn.Text, 11)
end

home.treasureLaunchNote = achievementHome:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
home.treasureLaunchNote:SetPoint("TOPLEFT", home.treasureLaunchBtn, "BOTTOMLEFT", 2, -10)
home.treasureLaunchNote:SetPoint("TOPRIGHT", home.treasureLaunchBtn, "BOTTOMRIGHT", -2, -10)
home.treasureLaunchNote:SetJustifyH("LEFT")
home.treasureLaunchNote:SetWordWrap(true)
home.treasureLaunchNote:SetText("|cffb8b8b8" .. UIText("Track the four Midnight treasure achievements and their rewards.", "Track the four Midnight treasure achievements and their rewards.") .. "|r")

home.glyphHunterLaunchBtn = CreateFrame("Button", nil, achievementHome, "BackdropTemplate")
home.glyphHunterLaunchBtn:SetSize(220, 34)
home.glyphHunterLaunchBtn:SetPoint("TOPLEFT", home.treasureLaunchNote, "BOTTOMLEFT", 0, -22)
home.glyphHunterLaunchBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
home.glyphHunterLaunchBtn.Text = home.glyphHunterLaunchBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
home.glyphHunterLaunchBtn.Text:SetPoint("CENTER")
home.glyphHunterLaunchBtn.Text:SetText(GetAchievementName(ACH.MIDNIGHT_GLYPH_HUNTER, UIText("BUTTON_MIDNIGHT_GLYPH_HUNTER", "Midnight Glyph Hunter")))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(home.glyphHunterLaunchBtn.Text, 11)
end

home.glyphRewardIcon = achievementHome:CreateTexture(nil, "ARTWORK")
home.glyphRewardIcon:SetSize(18, 18)
home.glyphRewardIcon:SetPoint("TOPLEFT", home.glyphHunterLaunchBtn, "BOTTOMLEFT", 2, -10)
if C_Item and C_Item.GetItemIconByID then
    home.glyphRewardIcon:SetTexture(C_Item.GetItemIconByID(REWARD_ITEM.CRIMSON_DRAGONHAWK))
end

home.glyphRewardText = achievementHome:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
home.glyphRewardText:SetPoint("LEFT", home.glyphRewardIcon, "RIGHT", 6, 0)
home.glyphRewardText:SetJustifyH("LEFT")
home.glyphRewardText:SetText(string.format("%s: |cffff8040%s|r", UIText("LABEL_REWARD", "Reward"), UIText("Crimson Dragonhawk", "Crimson Dragonhawk")))

home.glyphRewardNote = achievementHome:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
home.glyphRewardNote:SetPoint("TOPLEFT", home.glyphRewardIcon, "BOTTOMLEFT", 0, -4)
home.glyphRewardNote:SetPoint("RIGHT", home.glyphHunterLaunchBtn, "RIGHT", -2, 0)
home.glyphRewardNote:SetJustifyH("LEFT")
home.glyphRewardNote:SetWordWrap(true)
home.glyphRewardNote:SetText("|cffb8b8b8" .. UIText("DESC_GLYPH_REWARD", "Complete Midnight Glyph Hunter to earn this mount.") .. "|r")

home.delverLaunchBtn = CreateFrame("Button", nil, achievementHome, "BackdropTemplate")
home.delverLaunchBtn:SetSize(220, 34)
home.delverLaunchBtn:SetPoint("TOPLEFT", home.glyphRewardNote, "BOTTOMLEFT", 0, -22)
home.delverLaunchBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
home.delverLaunchBtn.Text = home.delverLaunchBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
home.delverLaunchBtn.Text:SetPoint("CENTER")
home.delverLaunchBtn.Text:SetText(UIText("Glory of the Midnight Delver", "Glory of the Midnight Delver"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(home.delverLaunchBtn.Text, 11)
end

home.delverRewardIcon = achievementHome:CreateTexture(nil, "ARTWORK")
home.delverRewardIcon:SetSize(18, 18)
home.delverRewardIcon:SetPoint("TOPLEFT", home.delverLaunchBtn, "BOTTOMLEFT", 2, -10)
if C_Item and C_Item.GetItemIconByID then
    home.delverRewardIcon:SetTexture(C_Item.GetItemIconByID(REWARD_ITEM.GIGANTO_MANIS))
end

home.delverRewardText = achievementHome:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
home.delverRewardText:SetPoint("LEFT", home.delverRewardIcon, "RIGHT", 6, 0)
home.delverRewardText:SetJustifyH("LEFT")
home.delverRewardText:SetText(string.format("%s: |cffff8040%s|r", UIText("LABEL_REWARD", "Reward"), UIText("Giganto-Manis", "Giganto-Manis")))

home.delverRewardNote = achievementHome:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
home.delverRewardNote:SetPoint("TOPLEFT", home.delverRewardIcon, "BOTTOMLEFT", 0, -4)
home.delverRewardNote:SetPoint("RIGHT", home.delverLaunchBtn, "RIGHT", -2, 0)
home.delverRewardNote:SetJustifyH("LEFT")
home.delverRewardNote:SetWordWrap(true)
home.delverRewardNote:SetText("|cffb8b8b8" .. UIText("Complete Glory of the Midnight Delver to earn this mount.", "Complete Glory of the Midnight Delver to earn this mount.") .. "|r")

local function CreateAchievementLaunchButton(parent, anchorTarget, offsetY, text)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(220, 34)
    btn:SetPoint("TOPLEFT", anchorTarget, "BOTTOMLEFT", 0, offsetY)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(text)
    if lv.ApplyLocaleFont then
        lv.ApplyLocaleFont(btn.Text, 11)
    end
    return btn
end

local function CreateAchievementLaunchNote(parent, anchorTarget, text)
    local note = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", anchorTarget, "BOTTOMLEFT", 2, -10)
    note:SetPoint("TOPRIGHT", anchorTarget, "BOTTOMRIGHT", -2, -10)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)
    note:SetText(text)
    return note
end

local function CreateAchievementChoiceButton(parent, achievementID, yOffset, onSelect)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(410, 22)
    btn:SetPoint("TOPLEFT", 0, yOffset)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.achievementID = achievementID
    btn:SetScript("OnClick", function(self)
        onSelect(self.achievementID)
    end)
    btn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end)
    btn:SetScript("OnLeave", function()
        RefreshAchievementsView()
    end)
    return btn
end

local function CreateAchievementRewardDisplay(parent, yOffset)
    local reward = {}
    reward.icon = parent:CreateTexture(nil, "ARTWORK")
    reward.icon:SetSize(32, 32)
    reward.icon:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    reward.icon:Hide()

    reward.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reward.label:SetPoint("LEFT", reward.icon, "RIGHT", 6, 0)
    reward.label:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    reward.label:SetJustifyH("LEFT")
    reward.label:SetWordWrap(true)
    reward.label:Hide()

    reward.button = CreateFrame("Button", nil, parent)
    reward.button:SetPoint("TOPLEFT", reward.icon, "TOPLEFT", -2, 2)
    reward.button:SetPoint("BOTTOMRIGHT", reward.label, "BOTTOMRIGHT", 2, -2)
    reward.button:Hide()

    return reward
end

home.peaksLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.delverRewardNote,
    -22,
    GetAchievementName(ACH.MIDNIGHT_HIGHEST_PEAKS, "Midnight, the Highest Peaks")
)
home.peaksLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.peaksLaunchBtn,
    "|cffb8b8b8Track the four zone achievements for Midnight, the Highest Peaks.|r"
)

home.raresLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.peaksLaunchNote,
    -22,
    "Rares of Midnight"
)
home.raresLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.raresLaunchBtn,
    "|cffb8b8b8" .. UIText("Track the four Midnight rare achievements and zone rare rewards.", "Track the four Midnight rare achievements and zone rare rewards.") .. "|r"
)

home.everPaintingLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.raresLaunchNote,
    -22,
    GetAchievementName(ACH.EVER_PAINTING, "Ever-Painting")
)
home.everPaintingLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.everPaintingLaunchBtn,
    "|cffb8b8b8Track Ever-Painting progress. Entry details can be filled in later.|r"
)
home.everPaintingLaunchBtn:Hide()
home.everPaintingLaunchNote:Hide()

home.runestoneRushLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.everPaintingLaunchNote,
    -22,
    GetAchievementName(ACH.RUNESTONE_RUSH, "Runestone Rush")
)
home.runestoneRushLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.runestoneRushLaunchBtn,
    "|cffb8b8b8Track Runestone Rush progress. Entry details can be filled in later.|r"
)
home.runestoneRushLaunchBtn:Hide()
home.runestoneRushLaunchNote:Hide()

home.partyMustGoOnLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.runestoneRushLaunchNote,
    -22,
    GetAchievementName(ACH.THE_PARTY_MUST_GO_ON, "The Party Must Go On")
)
home.partyMustGoOnLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.partyMustGoOnLaunchBtn,
    "|cffb8b8b8Track The Party Must Go On progress. Entry details can be filled in later.|r"
)
home.partyMustGoOnLaunchBtn:Hide()
home.partyMustGoOnLaunchNote:Hide()

home.exploreEversongLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.raresLaunchNote,
    -22,
    GetAchievementName(ACH.EXPLORE_EVERSONG_WOODS, "Explore Eversong Woods")
)
home.exploreEversongLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.exploreEversongLaunchBtn,
    "|cffb8b8b8Track Explore Eversong Woods progress. Entry details can be filled in later.|r"
)
home.exploreEversongLaunchBtn:ClearAllPoints()
home.exploreEversongLaunchBtn:SetPoint("TOPLEFT", home.treasureLaunchBtn, "TOPRIGHT", 40, 56)
home.exploreEversongLaunchBtn:Hide()
home.exploreEversongLaunchNote:Hide()

home.foreverSongLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.treasureLaunchNote,
    -22,
    GetAchievementName(ACH.FOREVER_SONG, "Forever Song")
)
home.foreverSongLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.foreverSongLaunchBtn,
    "|cffb8b8b8Track the Eversong Woods meta-achievement and jump into its child trackers.|r"
)
home.foreverSongLaunchBtn:ClearAllPoints()
home.foreverSongLaunchBtn:SetPoint("TOPLEFT", home.treasureLaunchBtn, "TOPRIGHT", 78, 0)
home.foreverSongLaunchNote:ClearAllPoints()
home.foreverSongLaunchNote:SetPoint("TOPLEFT", home.foreverSongLaunchBtn, "BOTTOMLEFT", 2, -10)
home.foreverSongLaunchNote:SetPoint("TOPRIGHT", home.foreverSongLaunchBtn, "BOTTOMRIGHT", -2, -10)

home.yellingIntoVoidstormLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.foreverSongLaunchNote,
    -22,
    GetAchievementName(ACH.YELLING_INTO_THE_VOIDSTORM, "Yelling into the Voidstorm")
)
home.yellingIntoVoidstormLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.yellingIntoVoidstormLaunchBtn,
    "|cffb8b8b8Track the Voidstorm meta-achievement and jump into its child trackers.|r"
)
home.yellingIntoVoidstormLaunchBtn:ClearAllPoints()
home.yellingIntoVoidstormLaunchBtn:SetPoint("TOPLEFT", home.foreverSongLaunchNote, "BOTTOMLEFT", -2, -22)
home.yellingIntoVoidstormLaunchNote:ClearAllPoints()
home.yellingIntoVoidstormLaunchNote:SetPoint("TOPLEFT", home.yellingIntoVoidstormLaunchBtn, "BOTTOMLEFT", 2, -10)
home.yellingIntoVoidstormLaunchNote:SetPoint("TOPRIGHT", home.yellingIntoVoidstormLaunchBtn, "BOTTOMRIGHT", -2, -10)

home.makingAnAmaniLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.yellingIntoVoidstormLaunchNote,
    -22,
    GetAchievementName(ACH.MAKING_AN_AMANI_OUT_OF_YOU, "Making an Amani Out of You")
)
home.makingAnAmaniLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.makingAnAmaniLaunchBtn,
    "|cffb8b8b8Track the Zul'Aman meta-achievement and jump into its child trackers.|r"
)
home.makingAnAmaniLaunchBtn:ClearAllPoints()
home.makingAnAmaniLaunchBtn:SetPoint("TOPLEFT", home.yellingIntoVoidstormLaunchNote, "BOTTOMLEFT", -2, -22)
home.thatsAlnFolksLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.makingAnAmaniLaunchNote,
    -22,
    "That's Aln, Folks!"
)
home.thatsAlnFolksLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.thatsAlnFolksLaunchBtn,
    "|cffb8b8b8Track the Harandar meta-achievement and jump into its child trackers.|r"
)
home.thatsAlnFolksLaunchBtn:ClearAllPoints()
home.thatsAlnFolksLaunchBtn:SetPoint("TOPLEFT", home.makingAnAmaniLaunchNote, "BOTTOMLEFT", -2, -22)

home.lightUpTheNightLaunchBtn = CreateAchievementLaunchButton(
    achievementHome,
    home.thatsAlnFolksLaunchNote,
    -22,
    GetAchievementName(ACH.LIGHT_UP_THE_NIGHT, "Light Up the Night")
)
home.lightUpTheNightLaunchNote = CreateAchievementLaunchNote(
    achievementHome,
    home.lightUpTheNightLaunchBtn,
    "|cffb8b8b8Complete the four Midnight zone meta-achievements and earn the mount reward.|r"
)
home.lightUpTheNightLaunchBtn:ClearAllPoints()
home.lightUpTheNightLaunchBtn:SetPoint("TOPLEFT", home.treasureLaunchBtn, "TOPRIGHT", 78, 0)
home.lightUpTheNightLaunchBtn:SetSize(220, 34)
home.lightUpTheNightLaunchNote:ClearAllPoints()
home.lightUpTheNightLaunchNote:SetPoint("TOPLEFT", home.lightUpTheNightLaunchBtn, "BOTTOMLEFT", 2, -10)
home.lightUpTheNightLaunchNote:SetPoint("TOPRIGHT", home.lightUpTheNightLaunchBtn, "BOTTOMRIGHT", -2, -10)
home.lightUpTheNightLaunchNote:SetJustifyH("LEFT")
home.lightUpTheNightMetaOverlay = CreateMetaAchievementHomeOverlay(achievementHome, home.lightUpTheNightLaunchBtn, home.lightUpTheNightLaunchNote)
home.foreverSongLaunchBtn:Hide()
home.foreverSongLaunchNote:Hide()
home.yellingIntoVoidstormLaunchBtn:Hide()
home.yellingIntoVoidstormLaunchNote:Hide()
home.makingAnAmaniLaunchBtn:Hide()
home.makingAnAmaniLaunchNote:Hide()
home.thatsAlnFolksLaunchBtn:Hide()
home.thatsAlnFolksLaunchNote:Hide()
do
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        home.treasureLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.treasureLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.treasureLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.glyphHunterLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.glyphHunterLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.glyphHunterLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.peaksLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.peaksLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.peaksLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.raresLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.raresLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.raresLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.everPaintingLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.everPaintingLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.everPaintingLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.runestoneRushLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.runestoneRushLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.runestoneRushLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.partyMustGoOnLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.partyMustGoOnLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.partyMustGoOnLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.exploreEversongLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.exploreEversongLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.exploreEversongLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.foreverSongLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.foreverSongLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.foreverSongLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.yellingIntoVoidstormLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.yellingIntoVoidstormLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.yellingIntoVoidstormLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.makingAnAmaniLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.makingAnAmaniLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.makingAnAmaniLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.thatsAlnFolksLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.thatsAlnFolksLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.thatsAlnFolksLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
        home.lightUpTheNightLaunchBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        home.lightUpTheNightLaunchBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        home.lightUpTheNightLaunchBtn.Text:SetTextColor(unpack(t.textPrimary))
    end
end

home.treasureLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.treasureLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.glyphHunterLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.glyphHunterLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.delverLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.delverLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.peaksLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.peaksLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.raresLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.raresLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.everPaintingLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.everPaintingLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.runestoneRushLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.runestoneRushLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.partyMustGoOnLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.partyMustGoOnLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.exploreEversongLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.exploreEversongLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.foreverSongLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.foreverSongLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.yellingIntoVoidstormLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.yellingIntoVoidstormLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.makingAnAmaniLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.makingAnAmaniLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.thatsAlnFolksLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.thatsAlnFolksLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

home.lightUpTheNightLaunchBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
home.lightUpTheNightLaunchBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

local glyphHunterBackBtn = CreateFrame("Button", nil, AchievementView, "BackdropTemplate")
glyphHunterBackBtn:SetSize(72, 22)
glyphHunterBackBtn:SetPoint("TOPRIGHT", -14, -12)
glyphHunterBackBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
glyphHunterBackBtn.Text = glyphHunterBackBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
glyphHunterBackBtn.Text:SetPoint("CENTER")
glyphHunterBackBtn.Text:SetText(UIText("Back", "Back"))
glyphHunterBackBtn:Hide()
do
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        glyphHunterBackBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        glyphHunterBackBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        glyphHunterBackBtn.Text:SetTextColor(unpack(t.textPrimary))
    end
end
glyphHunterBackBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
glyphHunterBackBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

local treasureView, treasureSummary, treasureDetailTitle, treasureRewardText, treasureRewardIcon, treasureRewardLabel, treasureRewardButton, treasureCriteriaRows, treasureAchievementButtons, treasureSelectedAchievementID, treasureButtons, treasureStepButtons, treasureSelectedEntry, treasureCollapseCooldownIndex, treasureCollapseCooldownUntil
local delverView, delverSummary, delverCriteriaTitle, delverCriteriaRows, delverAchievementButtons, delverSelectedAchievementID, delverDetailTitle
local peaksView, peaksSummary, peaksRewardIcon, peaksRewardLabel, peaksRewardButton, peaksCriteriaTitle, peaksCriteriaRows, peaksAchievementButtons, peaksSelectedAchievementID, peaksDetailTitle
local rares = {}
local everPainting = {}
local runestoneRush = {}
local partyMustGoOn = {}
local exploreEversong = {}
local foreverSong = {}
local lightUpTheNight = {}
local yellingIntoVoidstorm = {}
local exploreVoidstorm = {}
local thrillOfTheChase = {}
local aSingularProblem = {}
local makingAnAmaniOutOfYou = {}
local thatsAlnFolks = {}
local exploreZulaman = {}
local exploreHarandar = {}
local abundanceProsperous = {}
local altarOfBlessings = {}
local noTimeToPaws = {}
local fromTheCradleToTheGrave = {}
local chroniclerOfTheHaranir = {}
local legendsNeverDie = {}
local dustEmOff = {}
local dustEmOffSelectedGroup = 1
local function ApplyAchievementsTheme(theme)
    if not theme then return end
    AchievementView:SetBackdropColor(unpack(theme.backgroundTransparent))
    AchievementView:SetBackdropBorderColor(unpack(theme.borderPrimary))
    achievementsTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary))
    achievementsSubtitle:SetTextColor(unpack(theme.textSecondary))
    home.treasureLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    home.treasureLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    home.treasureLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    if home.treasureLaunchNote then home.treasureLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    home.glyphHunterLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    home.glyphHunterLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    home.glyphHunterLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    home.delverLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    home.delverLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    home.delverLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    if home.peaksLaunchBtn then
        home.peaksLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.peaksLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.peaksLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.peaksLaunchNote then home.peaksLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.raresLaunchBtn then
        home.raresLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.raresLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.raresLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.raresLaunchNote then home.raresLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.everPaintingLaunchBtn then
        home.everPaintingLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.everPaintingLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.everPaintingLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.everPaintingLaunchNote then home.everPaintingLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.runestoneRushLaunchBtn then
        home.runestoneRushLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.runestoneRushLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.runestoneRushLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.runestoneRushLaunchNote then home.runestoneRushLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.partyMustGoOnLaunchBtn then
        home.partyMustGoOnLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.partyMustGoOnLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.partyMustGoOnLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.partyMustGoOnLaunchNote then home.partyMustGoOnLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.exploreEversongLaunchBtn then
        home.exploreEversongLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.exploreEversongLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.exploreEversongLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.exploreEversongLaunchNote then home.exploreEversongLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.foreverSongLaunchBtn then
        home.foreverSongLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.foreverSongLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.foreverSongLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.foreverSongLaunchNote then home.foreverSongLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.yellingIntoVoidstormLaunchBtn then
        home.yellingIntoVoidstormLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.yellingIntoVoidstormLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.yellingIntoVoidstormLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.yellingIntoVoidstormLaunchNote then home.yellingIntoVoidstormLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.makingAnAmaniLaunchBtn then
        home.makingAnAmaniLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.makingAnAmaniLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.makingAnAmaniLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.makingAnAmaniLaunchNote then home.makingAnAmaniLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.thatsAlnFolksLaunchBtn then
        home.thatsAlnFolksLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.thatsAlnFolksLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.thatsAlnFolksLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.thatsAlnFolksLaunchNote then home.thatsAlnFolksLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    if home.lightUpTheNightLaunchBtn then
        home.lightUpTheNightLaunchBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        home.lightUpTheNightLaunchBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        home.lightUpTheNightLaunchBtn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    if home.lightUpTheNightLaunchNote then home.lightUpTheNightLaunchNote:SetTextColor(unpack(theme.textSecondary)) end
    glyphHunterBackBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    glyphHunterBackBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    glyphHunterBackBtn.Text:SetTextColor(unpack(theme.textPrimary))
    if treasureSummary then treasureSummary:SetTextColor(unpack(theme.textSecondary)) end
    if treasureDetailTitle then treasureDetailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if treasureRewardText then treasureRewardText:SetTextColor(unpack(theme.textPrimary)) end
    if treasureRewardLabel then treasureRewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    for _, btn in ipairs(treasureAchievementButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    for _, row in ipairs(treasureCriteriaRows or {}) do
        row:SetTextColor(unpack(theme.textPrimary))
    end
    for _, btn in ipairs(treasureButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
        if btn.rewardLabel then
            btn.rewardLabel:SetTextColor(unpack(theme.textSecondary))
        end
    end
    for _, btn in ipairs(treasureStepButtons or {}) do
        btn:SetBackdropColor(unpack(theme.dataBoxBgAlt or theme.dataBoxBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    delverSummary:SetTextColor(unpack(theme.textSecondary))
    delverCriteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary))
    delverDetailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary))
    for _, btn in ipairs(delverAchievementButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    for _, row in ipairs(delverCriteriaRows) do
        row:SetTextColor(unpack(theme.textPrimary))
    end
    if peaksSummary then peaksSummary:SetTextColor(unpack(theme.textSecondary)) end
    if peaksRewardLabel then peaksRewardLabel:SetTextColor(unpack(theme.textSecondary)) end
    if peaksCriteriaTitle then peaksCriteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if peaksDetailTitle then peaksDetailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    for _, btn in ipairs(peaksAchievementButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    for _, row in ipairs(peaksCriteriaRows or {}) do
        if row.SetBackdropColor then
            row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
            row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
        if row.RenownText then
            row.RenownText:SetTextColor(unpack(theme.textSecondary))
        end
    end
    if rares.summary then rares.summary:SetTextColor(unpack(theme.textSecondary)) end
    if rares.rewardLabel then rares.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if rares.sharedLootTitle then rares.sharedLootTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if rares.criteriaTitle then rares.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if rares.detailTitle then rares.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    for _, btn in ipairs(rares.achievementButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
    for _, row in ipairs(rares.criteriaRows or {}) do
        if row.SetBackdropColor then
            row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
            row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    for _, slot in ipairs(rares.sharedLootSlots or {}) do
        if slot.label then
            slot.label:SetTextColor(unpack(theme.textSecondary))
        end
    end
    if everPainting.summary then everPainting.summary:SetTextColor(unpack(theme.textSecondary)) end
    if everPainting.criteriaTitle then everPainting.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if everPainting.rewardLabel then everPainting.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if everPainting.detailTitle then everPainting.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if everPainting.emptyText then everPainting.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(everPainting.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if runestoneRush.summary then runestoneRush.summary:SetTextColor(unpack(theme.textSecondary)) end
    if runestoneRush.criteriaTitle then runestoneRush.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if runestoneRush.rewardLabel then runestoneRush.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if runestoneRush.detailTitle then runestoneRush.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if runestoneRush.emptyText then runestoneRush.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(runestoneRush.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if partyMustGoOn.summary then partyMustGoOn.summary:SetTextColor(unpack(theme.textSecondary)) end
    if partyMustGoOn.criteriaTitle then partyMustGoOn.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if partyMustGoOn.rewardLabel then partyMustGoOn.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if partyMustGoOn.detailTitle then partyMustGoOn.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if partyMustGoOn.emptyText then partyMustGoOn.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(partyMustGoOn.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if exploreEversong.summary then exploreEversong.summary:SetTextColor(unpack(theme.textSecondary)) end
    if exploreEversong.criteriaTitle then exploreEversong.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreEversong.rewardLabel then exploreEversong.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if exploreEversong.detailTitle then exploreEversong.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreEversong.emptyText then exploreEversong.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(exploreEversong.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if exploreVoidstorm.summary then exploreVoidstorm.summary:SetTextColor(unpack(theme.textSecondary)) end
    if exploreVoidstorm.criteriaTitle then exploreVoidstorm.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreVoidstorm.rewardLabel then exploreVoidstorm.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if exploreVoidstorm.detailTitle then exploreVoidstorm.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreVoidstorm.emptyText then exploreVoidstorm.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(exploreVoidstorm.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if thrillOfTheChase.summary then thrillOfTheChase.summary:SetTextColor(unpack(theme.textSecondary)) end
    if thrillOfTheChase.criteriaTitle then thrillOfTheChase.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if thrillOfTheChase.rewardLabel then thrillOfTheChase.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if thrillOfTheChase.detailTitle then thrillOfTheChase.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if thrillOfTheChase.emptyText then thrillOfTheChase.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(thrillOfTheChase.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if aSingularProblem.summary then aSingularProblem.summary:SetTextColor(unpack(theme.textSecondary)) end
    if aSingularProblem.criteriaTitle then aSingularProblem.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if aSingularProblem.rewardLabel then aSingularProblem.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if aSingularProblem.detailTitle then aSingularProblem.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if aSingularProblem.emptyText then aSingularProblem.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    if aSingularProblem.eventButton then
        aSingularProblem.eventButton:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        aSingularProblem.eventButton:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if aSingularProblem.eventButton.Text then
            aSingularProblem.eventButton.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    for _, row in ipairs(aSingularProblem.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if exploreZulaman.summary then exploreZulaman.summary:SetTextColor(unpack(theme.textSecondary)) end
    if exploreZulaman.criteriaTitle then exploreZulaman.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreZulaman.rewardLabel then exploreZulaman.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if exploreZulaman.detailTitle then exploreZulaman.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreZulaman.emptyText then exploreZulaman.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(exploreZulaman.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if exploreHarandar.summary then exploreHarandar.summary:SetTextColor(unpack(theme.textSecondary)) end
    if exploreHarandar.criteriaTitle then exploreHarandar.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreHarandar.rewardLabel then exploreHarandar.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if exploreHarandar.detailTitle then exploreHarandar.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if exploreHarandar.emptyText then exploreHarandar.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(exploreHarandar.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if abundanceProsperous.summary then abundanceProsperous.summary:SetTextColor(unpack(theme.textSecondary)) end
    if abundanceProsperous.criteriaTitle then abundanceProsperous.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if abundanceProsperous.rewardLabel then abundanceProsperous.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if abundanceProsperous.detailTitle then abundanceProsperous.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if abundanceProsperous.emptyText then abundanceProsperous.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(abundanceProsperous.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if foreverSong.summary then foreverSong.summary:SetTextColor(unpack(theme.textSecondary)) end
    if foreverSong.criteriaTitle then foreverSong.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if foreverSong.rewardLabel then foreverSong.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if foreverSong.detailTitle then foreverSong.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if foreverSong.emptyText then foreverSong.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, btn in ipairs(foreverSong.childButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if lightUpTheNight.summary then lightUpTheNight.summary:SetTextColor(unpack(theme.textSecondary)) end
    if lightUpTheNight.criteriaTitle then lightUpTheNight.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if lightUpTheNight.rewardLabel then lightUpTheNight.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if lightUpTheNight.detailTitle then lightUpTheNight.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if lightUpTheNight.emptyText then lightUpTheNight.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, btn in ipairs(lightUpTheNight.childButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if yellingIntoVoidstorm.summary then yellingIntoVoidstorm.summary:SetTextColor(unpack(theme.textSecondary)) end
    if yellingIntoVoidstorm.criteriaTitle then yellingIntoVoidstorm.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if yellingIntoVoidstorm.rewardLabel then yellingIntoVoidstorm.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if yellingIntoVoidstorm.detailTitle then yellingIntoVoidstorm.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if yellingIntoVoidstorm.emptyText then yellingIntoVoidstorm.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, btn in ipairs(yellingIntoVoidstorm.childButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if altarOfBlessings.summary then altarOfBlessings.summary:SetTextColor(unpack(theme.textSecondary)) end
    if altarOfBlessings.criteriaTitle then altarOfBlessings.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if altarOfBlessings.rewardLabel then altarOfBlessings.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if altarOfBlessings.detailTitle then altarOfBlessings.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if altarOfBlessings.emptyText then altarOfBlessings.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(altarOfBlessings.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if makingAnAmaniOutOfYou.summary then makingAnAmaniOutOfYou.summary:SetTextColor(unpack(theme.textSecondary)) end
    if makingAnAmaniOutOfYou.criteriaTitle then makingAnAmaniOutOfYou.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if makingAnAmaniOutOfYou.rewardLabel then makingAnAmaniOutOfYou.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if makingAnAmaniOutOfYou.detailTitle then makingAnAmaniOutOfYou.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if makingAnAmaniOutOfYou.emptyText then makingAnAmaniOutOfYou.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, btn in ipairs(makingAnAmaniOutOfYou.childButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if thatsAlnFolks.summary then thatsAlnFolks.summary:SetTextColor(unpack(theme.textSecondary)) end
    if thatsAlnFolks.criteriaTitle then thatsAlnFolks.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if thatsAlnFolks.rewardLabel then thatsAlnFolks.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if thatsAlnFolks.detailTitle then thatsAlnFolks.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if thatsAlnFolks.emptyText then thatsAlnFolks.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, btn in ipairs(thatsAlnFolks.childButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if noTimeToPaws.summary then noTimeToPaws.summary:SetTextColor(unpack(theme.textSecondary)) end
    if noTimeToPaws.criteriaTitle then noTimeToPaws.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if noTimeToPaws.rewardLabel then noTimeToPaws.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if noTimeToPaws.detailTitle then noTimeToPaws.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if noTimeToPaws.emptyText then noTimeToPaws.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(noTimeToPaws.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if fromTheCradleToTheGrave.summary then fromTheCradleToTheGrave.summary:SetTextColor(unpack(theme.textSecondary)) end
    if fromTheCradleToTheGrave.criteriaTitle then fromTheCradleToTheGrave.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if fromTheCradleToTheGrave.rewardLabel then fromTheCradleToTheGrave.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if fromTheCradleToTheGrave.detailTitle then fromTheCradleToTheGrave.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if fromTheCradleToTheGrave.emptyText then fromTheCradleToTheGrave.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(fromTheCradleToTheGrave.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if chroniclerOfTheHaranir.summary then chroniclerOfTheHaranir.summary:SetTextColor(unpack(theme.textSecondary)) end
    if chroniclerOfTheHaranir.criteriaTitle then chroniclerOfTheHaranir.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if chroniclerOfTheHaranir.rewardLabel then chroniclerOfTheHaranir.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if chroniclerOfTheHaranir.detailTitle then chroniclerOfTheHaranir.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if chroniclerOfTheHaranir.noteText then chroniclerOfTheHaranir.noteText:SetTextColor(unpack(theme.textSecondary)) end
    if chroniclerOfTheHaranir.emptyText then chroniclerOfTheHaranir.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(chroniclerOfTheHaranir.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if legendsNeverDie.summary then legendsNeverDie.summary:SetTextColor(unpack(theme.textSecondary)) end
    if legendsNeverDie.criteriaTitle then legendsNeverDie.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if legendsNeverDie.rewardLabel then legendsNeverDie.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if legendsNeverDie.detailTitle then legendsNeverDie.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if legendsNeverDie.noteText then legendsNeverDie.noteText:SetTextColor(unpack(theme.textSecondary)) end
    if legendsNeverDie.emptyText then legendsNeverDie.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, row in ipairs(legendsNeverDie.rows or {}) do
        row:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        row:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if row.Text then
            row.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if dustEmOff.summary then dustEmOff.summary:SetTextColor(unpack(theme.textSecondary)) end
    if dustEmOff.criteriaTitle then dustEmOff.criteriaTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if dustEmOff.rewardLabel then dustEmOff.rewardLabel:SetTextColor(unpack(theme.textPrimary)) end
    if dustEmOff.detailTitle then dustEmOff.detailTitle:SetTextColor(unpack(theme.textGold or theme.textPrimary)) end
    if dustEmOff.noteText then dustEmOff.noteText:SetTextColor(unpack(theme.textSecondary)) end
    if dustEmOff.emptyText then dustEmOff.emptyText:SetTextColor(unpack(theme.textSecondary)) end
    for _, btn in ipairs(dustEmOff.groupButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    if dustEmOff.groupBackBtn then
        dustEmOff.groupBackBtn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        dustEmOff.groupBackBtn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if dustEmOff.groupBackBtn.Text then
            dustEmOff.groupBackBtn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
    for _, btn in ipairs(dustEmOff.entryButtons or {}) do
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if btn.IndexText then
            btn.IndexText:SetTextColor(unpack(theme.textSecondary or theme.textMuted or theme.textPrimary))
        end
        if btn.Text then
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end
    end
end

local achievementsScroll = CreateFrame("ScrollFrame", nil, AchievementView)
achievementsScroll:SetPoint("TOPLEFT", 12, -62)
achievementsScroll:SetPoint("BOTTOMRIGHT", -8, 8)
achievementsScroll:EnableMouseWheel(true)
achievementsScroll:Hide()

treasureView = CreateFrame("Frame", nil, AchievementView)
treasureView:SetPoint("TOPLEFT", 18, -70)
treasureView:SetPoint("BOTTOMRIGHT", -12, 12)
treasureView:Hide()

treasureSummary = treasureView:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
treasureSummary:SetPoint("TOPLEFT", 0, 0)
treasureSummary:SetJustifyH("LEFT")

local treasureAchievementsTitle = treasureView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
treasureAchievementsTitle:SetPoint("TOPLEFT", 0, -28)
treasureAchievementsTitle:SetText(UIText("Achievements", "Achievements"))

treasureAchievementButtons = {}
for i, info in ipairs(TREASURES_OF_MIDNIGHT) do
    treasureAchievementButtons[i] = CreateAchievementChoiceButton(
        treasureView,
        info.id,
        -52 - ((i - 1) * 26),
        function(achievementID)
            treasureSelectedAchievementID = achievementID
            RefreshAchievementsView()
        end
    )
end

treasureDetailTitle = treasureView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
treasureDetailTitle:SetPoint("TOPLEFT", 0, -170)
treasureDetailTitle:SetText(UIText("LABEL_REWARD", "Reward"))

treasureRewardText = treasureView:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
treasureRewardText:SetPoint("TOPLEFT", 0, -196)
treasureRewardText:SetPoint("TOPRIGHT", -12, -196)
treasureRewardText:SetJustifyH("LEFT")
treasureRewardText:SetWordWrap(true)

do
    local reward = CreateAchievementRewardDisplay(treasureView, -198)
    treasureRewardIcon = reward.icon
    treasureRewardLabel = reward.label
    treasureRewardButton = reward.button
end

local treasureCriteriaTitle = treasureView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
treasureCriteriaTitle:SetPoint("TOPLEFT", 0, -244)
treasureCriteriaTitle:SetText(UIText("Details", "Details"))

local treasureCriteriaScroll = CreateFrame("ScrollFrame", nil, treasureView)
treasureCriteriaScroll:SetPoint("TOPLEFT", 0, -268)
treasureCriteriaScroll:SetPoint("BOTTOMRIGHT", -4, 0)
treasureCriteriaScroll:EnableMouseWheel(true)

local treasureCriteriaContent = CreateFrame("Frame", nil, treasureCriteriaScroll)
treasureCriteriaContent:SetSize(760, 1)
treasureCriteriaScroll:SetScrollChild(treasureCriteriaContent)
treasureCriteriaScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = math.max(0, treasureCriteriaContent:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(maxScroll, current - (delta * 40))))
end)

treasureCriteriaRows = {}
for i = 1, 30 do
    local row = treasureCriteriaContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row:SetPoint("TOPLEFT", 0, 0)
    row:SetWidth(760)
    row:SetJustifyH("LEFT")
    row:SetJustifyV("TOP")
    row:SetWordWrap(true)
    row:Hide()
    treasureCriteriaRows[i] = row
end

treasureButtons = {}
for i = 1, 20 do
    local btn = CreateFrame("Button", nil, treasureCriteriaContent, "BackdropTemplate")
    btn:SetSize(740, 22)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetWidth(360)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn.rewardIcon = btn:CreateTexture(nil, "ARTWORK")
    btn.rewardIcon:SetSize(16, 16)
    btn.rewardIcon:SetPoint("LEFT", btn, "LEFT", 390, 0)
    btn.rewardIcon:Hide()
    btn.rewardLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.rewardLabel:SetPoint("LEFT", btn.rewardIcon, "RIGHT", 6, 0)
    btn.rewardLabel:SetJustifyH("LEFT")
    btn.rewardLabel:SetWordWrap(false)
    btn.rewardLabel:Hide()
    btn.rewardButton = CreateFrame("Button", nil, btn)
    btn.rewardButton:SetPoint("LEFT", btn.rewardIcon, "LEFT", 0, -2)
    btn.rewardButton:SetPoint("RIGHT", btn.rewardLabel, "RIGHT", 2, 2)
    btn.rewardButton:SetHeight(20)
    btn.rewardButton:Hide()
    btn.rewardIcon2 = btn:CreateTexture(nil, "ARTWORK")
    btn.rewardIcon2:SetSize(16, 16)
    btn.rewardIcon2:SetPoint("LEFT", btn.rewardLabel, "RIGHT", 10, 0)
    btn.rewardIcon2:Hide()
    btn.rewardLabel2 = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.rewardLabel2:SetPoint("LEFT", btn.rewardIcon2, "RIGHT", 6, 0)
    btn.rewardLabel2:SetJustifyH("LEFT")
    btn.rewardLabel2:SetWordWrap(false)
    btn.rewardLabel2:Hide()
    btn.rewardButton2 = CreateFrame("Button", nil, btn)
    btn.rewardButton2:SetPoint("LEFT", btn.rewardIcon2, "LEFT", 0, -2)
    btn.rewardButton2:SetPoint("RIGHT", btn.rewardLabel2, "RIGHT", 2, 2)
    btn.rewardButton2:SetHeight(20)
    btn.rewardButton2:Hide()
    btn:Hide()
    treasureButtons[i] = btn
end

treasureStepButtons = {}
for i = 1, 30 do
    local btn = CreateFrame("Button", nil, treasureCriteriaContent, "BackdropTemplate")
    btn:SetSize(720, 20)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn:Hide()
    treasureStepButtons[i] = btn
end

delverView = CreateFrame("Frame", nil, AchievementView)
delverView:SetPoint("TOPLEFT", 18, -70)
delverView:SetPoint("BOTTOMRIGHT", -12, 12)
delverView:Hide()

delverSummary = delverView:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
delverSummary:SetPoint("TOPLEFT", 0, 0)
delverSummary:SetJustifyH("LEFT")

delverCriteriaTitle = delverView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
delverCriteriaTitle:SetPoint("TOPLEFT", 0, -28)
delverCriteriaTitle:SetText(UIText("Achievements", "Achievements"))

delverAchievementButtons = {}
for i, info in ipairs(MIDNIGHT_DELVER_CRITERIA) do
    delverAchievementButtons[i] = CreateAchievementChoiceButton(
        delverView,
        info.id,
        -52 - ((i - 1) * 26),
        function(achievementID)
            delverSelectedAchievementID = achievementID
            RefreshAchievementsView()
        end
    )
end

peaksView = CreateFrame("Frame", nil, AchievementView)
peaksView:SetPoint("TOPLEFT", 18, -70)
peaksView:SetPoint("BOTTOMRIGHT", -12, 12)
peaksView:Hide()

peaksSummary = peaksView:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
peaksSummary:SetPoint("TOPLEFT", 0, 0)
peaksSummary:SetJustifyH("LEFT")
peaksSummary:SetText(UIText("Complete the five telescopes in this zone.", "Complete the five telescopes in this zone."))

do
    local reward = CreateAchievementRewardDisplay(peaksView, -198)
    peaksRewardIcon = reward.icon
    peaksRewardLabel = reward.label
    peaksRewardButton = reward.button
end

peaksCriteriaTitle = peaksView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
peaksCriteriaTitle:SetPoint("TOPLEFT", 0, -170)
peaksCriteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

peaksAchievementButtons = {}
for i, info in ipairs(MIDNIGHT_HIGHEST_PEAKS_CRITERIA) do
    peaksAchievementButtons[i] = CreateAchievementChoiceButton(
        peaksView,
        info.id,
        -52 - ((i - 1) * 26),
        function(achievementID)
            peaksSelectedAchievementID = achievementID
            RefreshAchievementsView()
        end
    )
end

peaksDetailTitle = peaksView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
peaksDetailTitle:SetPoint("TOPLEFT", 0, -244)
peaksDetailTitle:SetText(UIText("Details", "Details"))

peaksCriteriaRows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, peaksView, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -270 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -270 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetWidth(360)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row.RenownText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.RenownText:SetPoint("LEFT", row, "LEFT", 390, 0)
    row.RenownText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.RenownText:SetJustifyH("LEFT")
    row.RenownText:SetWordWrap(false)
    row:EnableMouse(true)
    peaksCriteriaRows[i] = row
    row:Hide()
end

rares.view = CreateFrame("Frame", nil, AchievementView)
rares.view:SetPoint("TOPLEFT", 18, -70)
rares.view:SetPoint("BOTTOMRIGHT", -12, 12)
rares.view:Hide()

rares.summary = rares.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rares.summary:SetPoint("TOPLEFT", 0, 0)
rares.summary:SetJustifyH("LEFT")
rares.summary:SetText(UIText("Track the four Midnight rare achievements.", "Track the four Midnight rare achievements."))

rares.criteriaTitle = rares.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rares.criteriaTitle:SetPoint("TOPLEFT", 0, -170)
rares.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

rares.achievementButtons = {}
for i, info in ipairs(MIDNIGHT_RARES_OF_MIDNIGHT) do
    rares.achievementButtons[i] = CreateAchievementChoiceButton(
        rares.view,
        info.id,
        -52 - ((i - 1) * 26),
        function(achievementID)
            rares.selectedAchievementID = achievementID
            RefreshAchievementsView()
        end
    )
end

do
    local reward = CreateAchievementRewardDisplay(rares.view, -198)
    rares.rewardIcon = reward.icon
    rares.rewardLabel = reward.label
    rares.rewardButton = reward.button
end

rares.sharedLootTitle = rares.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rares.sharedLootTitle:SetPoint("TOPLEFT", 0, -232)
rares.sharedLootTitle:SetText("Shared Loot")
rares.sharedLootTitle:Hide()

rares.sharedLootSlots = {}
for i = 1, 7 do
    local slot = {}
    slot.icon = rares.view:CreateTexture(nil, "ARTWORK")
    slot.icon:SetSize(18, 18)
    local col = (i - 1) % 4
    local row = math.floor((i - 1) / 4)
    slot.icon:SetPoint("TOPLEFT", rares.view, "TOPLEFT", 0 + (col * 185), -258 - (row * 24))
    slot.icon:Hide()
    slot.label = rares.view:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slot.label:SetPoint("LEFT", slot.icon, "RIGHT", 6, 0)
    slot.label:SetWidth(150)
    slot.label:SetJustifyH("LEFT")
    slot.label:SetWordWrap(false)
    slot.label:Hide()
    slot.button = CreateFrame("Button", nil, rares.view)
    slot.button:SetPoint("TOPLEFT", slot.icon, "TOPLEFT", -2, 2)
    slot.button:SetPoint("BOTTOMRIGHT", slot.label, "BOTTOMRIGHT", 2, -2)
    slot.button:Hide()
    rares.sharedLootSlots[i] = slot
end

rares.detailTitle = rares.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rares.detailTitle:SetPoint("TOPLEFT", 0, -312)
rares.detailTitle:SetText(UIText("Details", "Details"))

rares.criteriaRows = {}
for i = 1, 15 do
    local btn = CreateFrame("Button", nil, rares.view, "BackdropTemplate")
    btn:SetSize(240, 24)
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    btn:SetPoint("TOPLEFT", 0 + (col * 248), -338 - (row * 28))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetWidth(150)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn.rewardIcon = btn:CreateTexture(nil, "ARTWORK")
    btn.rewardIcon:SetSize(16, 16)
    btn.rewardIcon:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
    btn.rewardIcon:Hide()
    btn.rewardButton = CreateFrame("Button", nil, btn)
    btn.rewardButton:SetPoint("TOPLEFT", btn.rewardIcon, "TOPLEFT", -2, 2)
    btn.rewardButton:SetPoint("BOTTOMRIGHT", btn.rewardIcon, "BOTTOMRIGHT", 2, -2)
    btn.rewardButton:Hide()
    btn.rewardIcon2 = btn:CreateTexture(nil, "ARTWORK")
    btn.rewardIcon2:SetSize(16, 16)
    btn.rewardIcon2:SetPoint("RIGHT", btn.rewardIcon, "LEFT", -5, 0)
    btn.rewardIcon2:Hide()
    btn.rewardButton2 = CreateFrame("Button", nil, btn)
    btn.rewardButton2:SetPoint("TOPLEFT", btn.rewardIcon2, "TOPLEFT", -2, 2)
    btn.rewardButton2:SetPoint("BOTTOMRIGHT", btn.rewardIcon2, "BOTTOMRIGHT", 2, -2)
    btn.rewardButton2:Hide()
    btn.rewardIcon3 = btn:CreateTexture(nil, "ARTWORK")
    btn.rewardIcon3:SetSize(16, 16)
    btn.rewardIcon3:SetPoint("RIGHT", btn.rewardIcon2, "LEFT", -5, 0)
    btn.rewardIcon3:Hide()
    btn.rewardButton3 = CreateFrame("Button", nil, btn)
    btn.rewardButton3:SetPoint("TOPLEFT", btn.rewardIcon3, "TOPLEFT", -2, 2)
    btn.rewardButton3:SetPoint("BOTTOMRIGHT", btn.rewardIcon3, "BOTTOMRIGHT", 2, -2)
    btn.rewardButton3:Hide()
    btn:Hide()
    rares.criteriaRows[i] = btn
end

everPainting.view = CreateFrame("Frame", nil, AchievementView)
everPainting.view:SetPoint("TOPLEFT", 18, -70)
everPainting.view:SetPoint("BOTTOMRIGHT", -12, 12)
everPainting.view:Hide()

everPainting.summary = everPainting.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
everPainting.summary:SetPoint("TOPLEFT", 0, 0)
everPainting.summary:SetJustifyH("LEFT")

everPainting.criteriaTitle = everPainting.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
everPainting.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
everPainting.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(everPainting.view, -64)
    everPainting.rewardIcon = reward.icon
    everPainting.rewardLabel = reward.label
    everPainting.rewardButton = reward.button
end

everPainting.detailTitle = everPainting.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
everPainting.detailTitle:SetPoint("TOPLEFT", 0, -110)
everPainting.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

everPainting.emptyText = everPainting.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
everPainting.emptyText:SetPoint("TOPLEFT", 0, -138)
everPainting.emptyText:SetPoint("RIGHT", -12, 0)
everPainting.emptyText:SetJustifyH("LEFT")
everPainting.emptyText:SetWordWrap(true)
everPainting.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Ever-Painting have not been added yet.", "Tracked entries for Ever-Painting have not been added yet.") .. "|r")

everPainting.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, everPainting.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    everPainting.rows[i] = row
end

runestoneRush.view = CreateFrame("Frame", nil, AchievementView)
runestoneRush.view:SetPoint("TOPLEFT", 18, -70)
runestoneRush.view:SetPoint("BOTTOMRIGHT", -12, 12)
runestoneRush.view:Hide()

runestoneRush.summary = runestoneRush.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
runestoneRush.summary:SetPoint("TOPLEFT", 0, 0)
runestoneRush.summary:SetJustifyH("LEFT")

runestoneRush.criteriaTitle = runestoneRush.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
runestoneRush.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
runestoneRush.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(runestoneRush.view, -64)
    runestoneRush.rewardIcon = reward.icon
    runestoneRush.rewardLabel = reward.label
    runestoneRush.rewardButton = reward.button
end

runestoneRush.detailTitle = runestoneRush.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
runestoneRush.detailTitle:SetPoint("TOPLEFT", 0, -110)
runestoneRush.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

runestoneRush.emptyText = runestoneRush.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
runestoneRush.emptyText:SetPoint("TOPLEFT", 0, -138)
runestoneRush.emptyText:SetPoint("RIGHT", -12, 0)
runestoneRush.emptyText:SetJustifyH("LEFT")
runestoneRush.emptyText:SetWordWrap(true)
runestoneRush.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Runestone Rush have not been added yet.", "Tracked entries for Runestone Rush have not been added yet.") .. "|r")

runestoneRush.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, runestoneRush.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    runestoneRush.rows[i] = row
end

partyMustGoOn.view = CreateFrame("Frame", nil, AchievementView)
partyMustGoOn.view:SetPoint("TOPLEFT", 18, -70)
partyMustGoOn.view:SetPoint("BOTTOMRIGHT", -12, 12)
partyMustGoOn.view:Hide()

partyMustGoOn.summary = partyMustGoOn.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
partyMustGoOn.summary:SetPoint("TOPLEFT", 0, 0)
partyMustGoOn.summary:SetJustifyH("LEFT")

partyMustGoOn.criteriaTitle = partyMustGoOn.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
partyMustGoOn.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
partyMustGoOn.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(partyMustGoOn.view, -64)
    partyMustGoOn.rewardIcon = reward.icon
    partyMustGoOn.rewardLabel = reward.label
    partyMustGoOn.rewardButton = reward.button
end

partyMustGoOn.detailTitle = partyMustGoOn.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
partyMustGoOn.detailTitle:SetPoint("TOPLEFT", 0, -110)
partyMustGoOn.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

partyMustGoOn.emptyText = partyMustGoOn.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
partyMustGoOn.emptyText:SetPoint("TOPLEFT", 0, -138)
partyMustGoOn.emptyText:SetPoint("RIGHT", -12, 0)
partyMustGoOn.emptyText:SetJustifyH("LEFT")
partyMustGoOn.emptyText:SetWordWrap(true)
partyMustGoOn.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for The Party Must Go On have not been added yet.", "Tracked entries for The Party Must Go On have not been added yet.") .. "|r")

partyMustGoOn.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, partyMustGoOn.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    partyMustGoOn.rows[i] = row
end

exploreEversong.view = CreateFrame("Frame", nil, AchievementView)
exploreEversong.view:SetPoint("TOPLEFT", 18, -70)
exploreEversong.view:SetPoint("BOTTOMRIGHT", -12, 12)
exploreEversong.view:Hide()

exploreEversong.summary = exploreEversong.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreEversong.summary:SetPoint("TOPLEFT", 0, 0)
exploreEversong.summary:SetJustifyH("LEFT")

exploreEversong.criteriaTitle = exploreEversong.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreEversong.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
exploreEversong.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(exploreEversong.view, -64)
    exploreEversong.rewardIcon = reward.icon
    exploreEversong.rewardLabel = reward.label
    exploreEversong.rewardButton = reward.button
end

exploreEversong.detailTitle = exploreEversong.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreEversong.detailTitle:SetPoint("TOPLEFT", 0, -110)
exploreEversong.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

exploreEversong.emptyText = exploreEversong.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreEversong.emptyText:SetPoint("TOPLEFT", 0, -138)
exploreEversong.emptyText:SetPoint("RIGHT", -12, 0)
exploreEversong.emptyText:SetJustifyH("LEFT")
exploreEversong.emptyText:SetWordWrap(true)
exploreEversong.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Explore Eversong Woods have not been added yet.", "Tracked entries for Explore Eversong Woods have not been added yet.") .. "|r")

exploreEversong.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, exploreEversong.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    exploreEversong.rows[i] = row
end

exploreVoidstorm.view = CreateFrame("Frame", nil, AchievementView)
exploreVoidstorm.view:SetPoint("TOPLEFT", 18, -70)
exploreVoidstorm.view:SetPoint("BOTTOMRIGHT", -12, 12)
exploreVoidstorm.view:Hide()

exploreVoidstorm.summary = exploreVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreVoidstorm.summary:SetPoint("TOPLEFT", 0, 0)
exploreVoidstorm.summary:SetJustifyH("LEFT")

exploreVoidstorm.criteriaTitle = exploreVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreVoidstorm.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
exploreVoidstorm.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(exploreVoidstorm.view, -64)
    exploreVoidstorm.rewardIcon = reward.icon
    exploreVoidstorm.rewardLabel = reward.label
    exploreVoidstorm.rewardButton = reward.button
end

exploreVoidstorm.detailTitle = exploreVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreVoidstorm.detailTitle:SetPoint("TOPLEFT", 0, -110)
exploreVoidstorm.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

exploreVoidstorm.emptyText = exploreVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreVoidstorm.emptyText:SetPoint("TOPLEFT", 0, -138)
exploreVoidstorm.emptyText:SetPoint("RIGHT", -12, 0)
exploreVoidstorm.emptyText:SetJustifyH("LEFT")
exploreVoidstorm.emptyText:SetWordWrap(true)
exploreVoidstorm.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Explore Voidstorm have not been added yet.", "Tracked entries for Explore Voidstorm have not been added yet.") .. "|r")

exploreVoidstorm.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, exploreVoidstorm.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    exploreVoidstorm.rows[i] = row
end

thrillOfTheChase.view = CreateFrame("Frame", nil, AchievementView)
thrillOfTheChase.view:SetPoint("TOPLEFT", 18, -70)
thrillOfTheChase.view:SetPoint("BOTTOMRIGHT", -12, 12)
thrillOfTheChase.view:Hide()

thrillOfTheChase.summary = thrillOfTheChase.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
thrillOfTheChase.summary:SetPoint("TOPLEFT", 0, 0)
thrillOfTheChase.summary:SetJustifyH("LEFT")

thrillOfTheChase.criteriaTitle = thrillOfTheChase.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
thrillOfTheChase.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
thrillOfTheChase.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(thrillOfTheChase.view, -64)
    thrillOfTheChase.rewardIcon = reward.icon
    thrillOfTheChase.rewardLabel = reward.label
    thrillOfTheChase.rewardButton = reward.button
end

thrillOfTheChase.detailTitle = thrillOfTheChase.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
thrillOfTheChase.detailTitle:SetPoint("TOPLEFT", 0, -110)
thrillOfTheChase.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

thrillOfTheChase.emptyText = thrillOfTheChase.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
thrillOfTheChase.emptyText:SetPoint("TOPLEFT", 0, -138)
thrillOfTheChase.emptyText:SetPoint("RIGHT", -12, 0)
thrillOfTheChase.emptyText:SetJustifyH("LEFT")
thrillOfTheChase.emptyText:SetWordWrap(true)
thrillOfTheChase.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Thrill of the Chase have not been added yet.", "Tracked entries for Thrill of the Chase have not been added yet.") .. "|r")

thrillOfTheChase.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, thrillOfTheChase.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    thrillOfTheChase.rows[i] = row
end

noTimeToPaws.view = CreateFrame("Frame", nil, AchievementView)
noTimeToPaws.view:SetPoint("TOPLEFT", 18, -70)
noTimeToPaws.view:SetPoint("BOTTOMRIGHT", -12, 12)
noTimeToPaws.view:Hide()

noTimeToPaws.summary = noTimeToPaws.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noTimeToPaws.summary:SetPoint("TOPLEFT", 0, 0)
noTimeToPaws.summary:SetJustifyH("LEFT")

noTimeToPaws.criteriaTitle = noTimeToPaws.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
noTimeToPaws.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
noTimeToPaws.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(noTimeToPaws.view, -64)
    noTimeToPaws.rewardIcon = reward.icon
    noTimeToPaws.rewardLabel = reward.label
    noTimeToPaws.rewardButton = reward.button
end

noTimeToPaws.detailTitle = noTimeToPaws.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
noTimeToPaws.detailTitle:SetPoint("TOPLEFT", 0, -110)
noTimeToPaws.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

noTimeToPaws.emptyText = noTimeToPaws.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noTimeToPaws.emptyText:SetPoint("TOPLEFT", 0, -138)
noTimeToPaws.emptyText:SetPoint("RIGHT", -12, 0)
noTimeToPaws.emptyText:SetJustifyH("LEFT")
noTimeToPaws.emptyText:SetWordWrap(true)
noTimeToPaws.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for No Time to Paws have not been added yet.", "Tracked entries for No Time to Paws have not been added yet.") .. "|r")

noTimeToPaws.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, noTimeToPaws.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    noTimeToPaws.rows[i] = row
end

fromTheCradleToTheGrave.view = CreateFrame("Frame", nil, AchievementView)
fromTheCradleToTheGrave.view:SetPoint("TOPLEFT", 18, -70)
fromTheCradleToTheGrave.view:SetPoint("BOTTOMRIGHT", -12, 12)
fromTheCradleToTheGrave.view:Hide()

fromTheCradleToTheGrave.summary = fromTheCradleToTheGrave.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
fromTheCradleToTheGrave.summary:SetPoint("TOPLEFT", 0, 0)
fromTheCradleToTheGrave.summary:SetJustifyH("LEFT")

fromTheCradleToTheGrave.criteriaTitle = fromTheCradleToTheGrave.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fromTheCradleToTheGrave.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
fromTheCradleToTheGrave.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(fromTheCradleToTheGrave.view, -64)
    fromTheCradleToTheGrave.rewardIcon = reward.icon
    fromTheCradleToTheGrave.rewardLabel = reward.label
    fromTheCradleToTheGrave.rewardButton = reward.button
end

fromTheCradleToTheGrave.detailTitle = fromTheCradleToTheGrave.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fromTheCradleToTheGrave.detailTitle:SetPoint("TOPLEFT", 0, -110)
fromTheCradleToTheGrave.detailTitle:SetText(UIText("Info", "Info"))

fromTheCradleToTheGrave.emptyText = fromTheCradleToTheGrave.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
fromTheCradleToTheGrave.emptyText:SetPoint("TOPLEFT", 0, -138)
fromTheCradleToTheGrave.emptyText:SetPoint("RIGHT", -12, 0)
fromTheCradleToTheGrave.emptyText:SetJustifyH("LEFT")
fromTheCradleToTheGrave.emptyText:SetWordWrap(true)
fromTheCradleToTheGrave.emptyText:SetText("|cffb8b8b8" .. UIText("Fly into The Cradle high in the sky above Harandar to complete this achievement.", "Fly into The Cradle high in the sky above Harandar to complete this achievement.") .. "|r")

fromTheCradleToTheGrave.rows = {}
for i = 1, 4 do
    local row = CreateFrame("Frame", nil, fromTheCradleToTheGrave.view, "BackdropTemplate")
    row:SetSize(220, 22)
    local col = (i - 1) % 2
    local rowIndex = math.floor((i - 1) / 2)
    row:SetPoint("TOPLEFT", 0 + (col * 236), -170 - (rowIndex * 26))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    fromTheCradleToTheGrave.rows[i] = row
end

chroniclerOfTheHaranir.view = CreateFrame("Frame", nil, AchievementView)
chroniclerOfTheHaranir.view:SetPoint("TOPLEFT", 18, -70)
chroniclerOfTheHaranir.view:SetPoint("BOTTOMRIGHT", -12, 12)
chroniclerOfTheHaranir.view:Hide()

chroniclerOfTheHaranir.summary = chroniclerOfTheHaranir.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chroniclerOfTheHaranir.summary:SetPoint("TOPLEFT", 0, 0)
chroniclerOfTheHaranir.summary:SetJustifyH("LEFT")

chroniclerOfTheHaranir.criteriaTitle = chroniclerOfTheHaranir.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
chroniclerOfTheHaranir.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
chroniclerOfTheHaranir.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(chroniclerOfTheHaranir.view, -64)
    chroniclerOfTheHaranir.rewardIcon = reward.icon
    chroniclerOfTheHaranir.rewardLabel = reward.label
    chroniclerOfTheHaranir.rewardButton = reward.button
end

chroniclerOfTheHaranir.detailTitle = chroniclerOfTheHaranir.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
chroniclerOfTheHaranir.detailTitle:SetPoint("TOPLEFT", 0, -110)
chroniclerOfTheHaranir.detailTitle:SetText(UIText("Criteria", "Criteria"))

chroniclerOfTheHaranir.noteText = chroniclerOfTheHaranir.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chroniclerOfTheHaranir.noteText:SetPoint("TOPLEFT", 0, -138)
chroniclerOfTheHaranir.noteText:SetPoint("RIGHT", -12, 0)
chroniclerOfTheHaranir.noteText:SetJustifyH("LEFT")
chroniclerOfTheHaranir.noteText:SetWordWrap(true)
chroniclerOfTheHaranir.noteText:SetText("|cffb8b8b8" .. UIText("These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap.", "These journals are only available during the account-bound weekly quest 'Legends of the Haranir'. While in a vision, look for the magnifying glass icon on your minimap.") .. "|r")

chroniclerOfTheHaranir.emptyText = chroniclerOfTheHaranir.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chroniclerOfTheHaranir.emptyText:SetPoint("TOPLEFT", 0, -162)
chroniclerOfTheHaranir.emptyText:SetPoint("RIGHT", -12, 0)
chroniclerOfTheHaranir.emptyText:SetJustifyH("LEFT")
chroniclerOfTheHaranir.emptyText:SetWordWrap(true)
chroniclerOfTheHaranir.emptyText:SetText("|cffb8b8b8" .. UIText("Recover the Haranir journal entries listed below.", "Recover the Haranir journal entries listed below.") .. "|r")

chroniclerOfTheHaranir.rows = {}
for i = 1, 20 do
    local row = CreateFrame("Frame", nil, chroniclerOfTheHaranir.view, "BackdropTemplate")
    row:SetSize(220, 22)
    local col = (i - 1) % 2
    local rowIndex = math.floor((i - 1) / 2)
    row:SetPoint("TOPLEFT", 0 + (col * 236), -194 - (rowIndex * 26))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    chroniclerOfTheHaranir.rows[i] = row
end

legendsNeverDie.view = CreateFrame("Frame", nil, AchievementView)
legendsNeverDie.view:SetPoint("TOPLEFT", 18, -70)
legendsNeverDie.view:SetPoint("BOTTOMRIGHT", -12, 12)
legendsNeverDie.view:Hide()

legendsNeverDie.summary = legendsNeverDie.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
legendsNeverDie.summary:SetPoint("TOPLEFT", 0, 0)
legendsNeverDie.summary:SetJustifyH("LEFT")

legendsNeverDie.criteriaTitle = legendsNeverDie.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
legendsNeverDie.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
legendsNeverDie.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(legendsNeverDie.view, -64)
    legendsNeverDie.rewardIcon = reward.icon
    legendsNeverDie.rewardLabel = reward.label
    legendsNeverDie.rewardButton = reward.button
end

legendsNeverDie.detailTitle = legendsNeverDie.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
legendsNeverDie.detailTitle:SetPoint("TOPLEFT", 0, -110)
legendsNeverDie.detailTitle:SetText(UIText("Criteria", "Criteria"))

legendsNeverDie.noteText = legendsNeverDie.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
legendsNeverDie.noteText:SetPoint("TOPLEFT", 0, -138)
legendsNeverDie.noteText:SetPoint("RIGHT", -12, 0)
legendsNeverDie.noteText:SetJustifyH("LEFT")
legendsNeverDie.noteText:SetWordWrap(true)
legendsNeverDie.noteText:SetText("|cffb8b8b8" .. UIText("This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete.", "This is tied to the account-bound weekly quest 'Legends of the Haranir'. If you have no progress yet, it is estimated to take about 7 weeks to complete.") .. "|r")

legendsNeverDie.emptyText = legendsNeverDie.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
legendsNeverDie.emptyText:SetPoint("TOPLEFT", 0, -162)
legendsNeverDie.emptyText:SetPoint("RIGHT", -12, 0)
legendsNeverDie.emptyText:SetJustifyH("LEFT")
legendsNeverDie.emptyText:SetWordWrap(true)
legendsNeverDie.emptyText:SetText("|cffb8b8b8" .. UIText("Defend each Haranir legend location listed below.", "Defend each Haranir legend location listed below.") .. "|r")

legendsNeverDie.rows = {}
for i = 1, 8 do
    local row = CreateFrame("Frame", nil, legendsNeverDie.view, "BackdropTemplate")
    row:SetSize(220, 22)
    local col = (i - 1) % 2
    local rowIndex = math.floor((i - 1) / 2)
    row:SetPoint("TOPLEFT", 0 + (col * 236), -194 - (rowIndex * 26))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    legendsNeverDie.rows[i] = row
end

dustEmOff.view = CreateFrame("Frame", nil, AchievementView)
dustEmOff.view:SetPoint("TOPLEFT", 18, -70)
dustEmOff.view:SetPoint("BOTTOMRIGHT", -12, 12)
dustEmOff.view:Hide()

dustEmOff.summary = dustEmOff.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dustEmOff.summary:SetPoint("TOPLEFT", 0, 0)
dustEmOff.summary:SetJustifyH("LEFT")

dustEmOff.criteriaTitle = dustEmOff.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dustEmOff.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
dustEmOff.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(dustEmOff.view, -64)
    dustEmOff.rewardIcon = reward.icon
    dustEmOff.rewardLabel = reward.label
    dustEmOff.rewardButton = reward.button
end

dustEmOff.detailTitle = dustEmOff.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dustEmOff.detailTitle:SetPoint("TOPLEFT", 0, -110)
dustEmOff.detailTitle:SetText(UIText("Groups", "Groups"))

dustEmOff.groupBackBtn = CreateFrame("Button", nil, dustEmOff.view, "BackdropTemplate")
dustEmOff.groupBackBtn:SetSize(90, 22)
dustEmOff.groupBackBtn:SetPoint("TOPRIGHT", -8, -110)
dustEmOff.groupBackBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
dustEmOff.groupBackBtn.Text = dustEmOff.groupBackBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
dustEmOff.groupBackBtn.Text:SetPoint("CENTER")
dustEmOff.groupBackBtn.Text:SetText(UIText("Back to Groups", "Back to Groups"))
dustEmOff.groupBackBtn:Hide()

dustEmOff.noteText = dustEmOff.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dustEmOff.noteText:SetPoint("TOPLEFT", 0, -138)
dustEmOff.noteText:SetPoint("RIGHT", -12, 0)
dustEmOff.noteText:SetJustifyH("LEFT")
dustEmOff.noteText:SetWordWrap(true)
dustEmOff.noteText:SetText("|cffb8b8b8" .. UIText("This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable.", "This tracker is split into 3 groups of 40 coordinates so the moth routes stay manageable.") .. "|r")

dustEmOff.emptyText = dustEmOff.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dustEmOff.emptyText:SetPoint("TOPLEFT", 0, -170)
dustEmOff.emptyText:SetPoint("RIGHT", -12, 0)
dustEmOff.emptyText:SetJustifyH("LEFT")
dustEmOff.emptyText:SetWordWrap(true)
dustEmOff.emptyText:SetText("|cffb8b8b8" .. UIText("Coordinate groups have not been added yet.", "Coordinate groups have not been added yet.") .. "|r")

dustEmOff.groupButtons = {}
for i = 1, 3 do
    local btn = CreateFrame("Button", nil, dustEmOff.view, "BackdropTemplate")
    btn:SetSize(220, 24)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    btn:SetPoint("TOPLEFT", 0 + (col * 236), -202 - (row * 30))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    dustEmOff.groupButtons[i] = btn
end

dustEmOff.entriesScroll = CreateFrame("ScrollFrame", nil, dustEmOff.view)
dustEmOff.entriesScroll:SetPoint("TOPLEFT", 0, -238)
dustEmOff.entriesScroll:SetPoint("BOTTOMRIGHT", -4, 8)
dustEmOff.entriesScroll:EnableMouseWheel(true)

dustEmOff.entriesContent = CreateFrame("Frame", nil, dustEmOff.entriesScroll)
dustEmOff.entriesContent:SetSize(472, 1)
dustEmOff.entriesScroll:SetScrollChild(dustEmOff.entriesContent)
dustEmOff.entriesScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = math.max(0, dustEmOff.entriesContent:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(maxScroll, current - (delta * 40))))
end)

dustEmOff.entryButtons = {}
for i = 1, 40 do
    local btn = CreateFrame("Button", nil, dustEmOff.entriesContent, "BackdropTemplate")
    btn:SetSize(170, 22)
    local col = (i - 1) % 4
    local row = math.floor((i - 1) / 4)
    btn:SetPoint("TOPLEFT", 30 + (col * 194), 0 - (row * 26))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.IndexText = dustEmOff.entriesContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.IndexText:SetPoint("RIGHT", btn, "LEFT", -6, 0)
    btn.IndexText:SetWidth(22)
    btn.IndexText:SetJustifyH("RIGHT")
    btn.IndexText:SetJustifyV("MIDDLE")
    btn.IndexText:Hide()
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    dustEmOff.entryButtons[i] = btn
end

aSingularProblem.view = CreateFrame("Frame", nil, AchievementView)
aSingularProblem.view:SetPoint("TOPLEFT", 18, -70)
aSingularProblem.view:SetPoint("BOTTOMRIGHT", -12, 12)
aSingularProblem.view:Hide()

aSingularProblem.summary = aSingularProblem.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
aSingularProblem.summary:SetPoint("TOPLEFT", 0, 0)
aSingularProblem.summary:SetJustifyH("LEFT")

aSingularProblem.criteriaTitle = aSingularProblem.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
aSingularProblem.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
aSingularProblem.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(aSingularProblem.view, -64)
    aSingularProblem.rewardIcon = reward.icon
    aSingularProblem.rewardLabel = reward.label
    aSingularProblem.rewardButton = reward.button
end

aSingularProblem.detailTitle = aSingularProblem.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
aSingularProblem.detailTitle:SetPoint("TOPLEFT", 0, -110)
aSingularProblem.detailTitle:SetText(UIText("Criteria", "Criteria"))

aSingularProblem.eventButton = CreateFrame("Button", nil, aSingularProblem.view, "BackdropTemplate")
aSingularProblem.eventButton:SetSize(120, 24)
aSingularProblem.eventButton:SetPoint("TOPLEFT", 0, -138)
aSingularProblem.eventButton:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
aSingularProblem.eventButton.Text = aSingularProblem.eventButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
aSingularProblem.eventButton.Text:SetPoint("CENTER")
aSingularProblem.eventButton.Text:SetText(UIText("Stormarion Assault", "Stormarion Assault"))

aSingularProblem.emptyText = aSingularProblem.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
aSingularProblem.emptyText:SetPoint("TOPLEFT", 0, -170)
aSingularProblem.emptyText:SetPoint("RIGHT", -12, 0)
aSingularProblem.emptyText:SetJustifyH("LEFT")
aSingularProblem.emptyText:SetWordWrap(true)
aSingularProblem.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for A Singular Problem have not been added yet.", "Tracked entries for A Singular Problem have not been added yet.") .. "|r")

aSingularProblem.rows = {}
for i = 1, 3 do
    local row = CreateFrame("Button", nil, aSingularProblem.view, "BackdropTemplate")
    row:SetSize(220, 24)
    local col = (i - 1) % 2
    local rowIndex = math.floor((i - 1) / 2)
    row:SetPoint("TOPLEFT", 0 + (col * 236), -170 - (rowIndex * 30))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    aSingularProblem.rows[i] = row
end

exploreZulaman.view = CreateFrame("Frame", nil, AchievementView)
exploreZulaman.view:SetPoint("TOPLEFT", 18, -70)
exploreZulaman.view:SetPoint("BOTTOMRIGHT", -12, 12)
exploreZulaman.view:Hide()

exploreZulaman.summary = exploreZulaman.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreZulaman.summary:SetPoint("TOPLEFT", 0, 0)
exploreZulaman.summary:SetJustifyH("LEFT")

exploreZulaman.criteriaTitle = exploreZulaman.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreZulaman.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
exploreZulaman.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(exploreZulaman.view, -64)
    exploreZulaman.rewardIcon = reward.icon
    exploreZulaman.rewardLabel = reward.label
    exploreZulaman.rewardButton = reward.button
end

exploreZulaman.detailTitle = exploreZulaman.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreZulaman.detailTitle:SetPoint("TOPLEFT", 0, -110)
exploreZulaman.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

exploreZulaman.emptyText = exploreZulaman.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreZulaman.emptyText:SetPoint("TOPLEFT", 0, -138)
exploreZulaman.emptyText:SetPoint("RIGHT", -12, 0)
exploreZulaman.emptyText:SetJustifyH("LEFT")
exploreZulaman.emptyText:SetWordWrap(true)
exploreZulaman.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Explore Zul'Aman have not been added yet.", "Tracked entries for Explore Zul'Aman have not been added yet.") .. "|r")

exploreZulaman.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, exploreZulaman.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    exploreZulaman.rows[i] = row
end

exploreHarandar.view = CreateFrame("Frame", nil, AchievementView)
exploreHarandar.view:SetPoint("TOPLEFT", 18, -70)
exploreHarandar.view:SetPoint("BOTTOMRIGHT", -12, 12)
exploreHarandar.view:Hide()

exploreHarandar.summary = exploreHarandar.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreHarandar.summary:SetPoint("TOPLEFT", 0, 0)
exploreHarandar.summary:SetJustifyH("LEFT")

exploreHarandar.criteriaTitle = exploreHarandar.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreHarandar.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
exploreHarandar.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(exploreHarandar.view, -64)
    exploreHarandar.rewardIcon = reward.icon
    exploreHarandar.rewardLabel = reward.label
    exploreHarandar.rewardButton = reward.button
end

exploreHarandar.detailTitle = exploreHarandar.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
exploreHarandar.detailTitle:SetPoint("TOPLEFT", 0, -110)
exploreHarandar.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

exploreHarandar.emptyText = exploreHarandar.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
exploreHarandar.emptyText:SetPoint("TOPLEFT", 0, -138)
exploreHarandar.emptyText:SetPoint("RIGHT", -12, 0)
exploreHarandar.emptyText:SetJustifyH("LEFT")
exploreHarandar.emptyText:SetWordWrap(true)
exploreHarandar.emptyText:SetText("|cffb8b8b8" .. UIText("Tracked entries for Explore Harandar have not been added yet.", "Tracked entries for Explore Harandar have not been added yet.") .. "|r")

exploreHarandar.rows = {}
for i = 1, 12 do
    local row = CreateFrame("Button", nil, exploreHarandar.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -138 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -138 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    exploreHarandar.rows[i] = row
end

abundanceProsperous.view = CreateFrame("Frame", nil, AchievementView)
abundanceProsperous.view:SetPoint("TOPLEFT", 18, -70)
abundanceProsperous.view:SetPoint("BOTTOMRIGHT", -12, 12)
abundanceProsperous.view:Hide()

abundanceProsperous.summary = abundanceProsperous.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
abundanceProsperous.summary:SetPoint("TOPLEFT", 0, 0)
abundanceProsperous.summary:SetJustifyH("LEFT")

abundanceProsperous.criteriaTitle = abundanceProsperous.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
abundanceProsperous.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
abundanceProsperous.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(abundanceProsperous.view, -64)
    abundanceProsperous.rewardIcon = reward.icon
    abundanceProsperous.rewardLabel = reward.label
    abundanceProsperous.rewardButton = reward.button
end

abundanceProsperous.detailTitle = abundanceProsperous.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
abundanceProsperous.detailTitle:SetPoint("TOPLEFT", 0, -110)
abundanceProsperous.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

abundanceProsperous.emptyText = abundanceProsperous.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
abundanceProsperous.emptyText:SetPoint("TOPLEFT", 0, -138)
abundanceProsperous.emptyText:SetPoint("RIGHT", -12, 0)
abundanceProsperous.emptyText:SetJustifyH("LEFT")
abundanceProsperous.emptyText:SetWordWrap(true)
abundanceProsperous.emptyText:SetText("|cffb8b8b8Tracked entries for Abundance: Prosperous Plentitude! have not been added yet.|r")

abundanceProsperous.rows = {}
for i = 1, 8 do
    local row = CreateFrame("Button", nil, abundanceProsperous.view, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 0, -170 - ((i - 1) * 24))
    row:SetPoint("TOPRIGHT", -12, -170 - ((i - 1) * 24))
    row:SetHeight(20)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    abundanceProsperous.rows[i] = row
end

altarOfBlessings.view = CreateFrame("Frame", nil, AchievementView)
altarOfBlessings.view:SetPoint("TOPLEFT", 18, -70)
altarOfBlessings.view:SetPoint("BOTTOMRIGHT", -12, 12)
altarOfBlessings.view:Hide()

altarOfBlessings.summary = altarOfBlessings.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
altarOfBlessings.summary:SetPoint("TOPLEFT", 0, 0)
altarOfBlessings.summary:SetJustifyH("LEFT")

altarOfBlessings.criteriaTitle = altarOfBlessings.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
altarOfBlessings.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
altarOfBlessings.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(altarOfBlessings.view, -64)
    altarOfBlessings.rewardIcon = reward.icon
    altarOfBlessings.rewardLabel = reward.label
    altarOfBlessings.rewardButton = reward.button
end

altarOfBlessings.detailTitle = altarOfBlessings.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
altarOfBlessings.detailTitle:SetPoint("TOPLEFT", 0, -110)
altarOfBlessings.detailTitle:SetText(UIText("Criteria", "Criteria"))

altarOfBlessings.emptyText = altarOfBlessings.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
altarOfBlessings.emptyText:SetPoint("TOPLEFT", 0, -138)
altarOfBlessings.emptyText:SetPoint("RIGHT", -12, 0)
altarOfBlessings.emptyText:SetJustifyH("LEFT")
altarOfBlessings.emptyText:SetWordWrap(true)
altarOfBlessings.emptyText:SetText("|cffb8b8b8Trigger each listed blessing effect for credit.|r")

altarOfBlessings.rows = {}
for i = 1, 24 do
    local row = CreateFrame("Frame", nil, altarOfBlessings.view, "BackdropTemplate")
    row:SetSize(220, 22)
    local col = (i - 1) % 2
    local rowIndex = math.floor((i - 1) / 2)
    row:SetPoint("TOPLEFT", 0 + (col * 236), -170 - (rowIndex * 26))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Text:SetPoint("LEFT", 8, 0)
    row.Text:SetPoint("RIGHT", -8, 0)
    row.Text:SetJustifyH("LEFT")
    row.Text:SetWordWrap(false)
    row:Hide()
    altarOfBlessings.rows[i] = row
end

makingAnAmaniOutOfYou.view = CreateFrame("Frame", nil, AchievementView)
makingAnAmaniOutOfYou.view:SetPoint("TOPLEFT", 18, -70)
makingAnAmaniOutOfYou.view:SetPoint("BOTTOMRIGHT", -12, 12)
makingAnAmaniOutOfYou.view:Hide()

makingAnAmaniOutOfYou.summary = makingAnAmaniOutOfYou.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
makingAnAmaniOutOfYou.summary:SetPoint("TOPLEFT", 0, 0)
makingAnAmaniOutOfYou.summary:SetJustifyH("LEFT")

makingAnAmaniOutOfYou.criteriaTitle = makingAnAmaniOutOfYou.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
makingAnAmaniOutOfYou.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
makingAnAmaniOutOfYou.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(makingAnAmaniOutOfYou.view, -64)
    makingAnAmaniOutOfYou.rewardIcon = reward.icon
    makingAnAmaniOutOfYou.rewardLabel = reward.label
    makingAnAmaniOutOfYou.rewardButton = reward.button
end

makingAnAmaniOutOfYou.detailTitle = makingAnAmaniOutOfYou.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
makingAnAmaniOutOfYou.detailTitle:SetPoint("TOPLEFT", 0, -110)
makingAnAmaniOutOfYou.detailTitle:SetText(UIText("Criteria", "Criteria"))

makingAnAmaniOutOfYou.emptyText = makingAnAmaniOutOfYou.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
makingAnAmaniOutOfYou.emptyText:SetPoint("TOPLEFT", 0, -138)
makingAnAmaniOutOfYou.emptyText:SetPoint("RIGHT", -12, 0)
makingAnAmaniOutOfYou.emptyText:SetJustifyH("LEFT")
makingAnAmaniOutOfYou.emptyText:SetWordWrap(true)
makingAnAmaniOutOfYou.emptyText:SetText("|cffb8b8b8Tracked entries for Making an Amani Out of You have not been added yet.|r")

makingAnAmaniOutOfYou.childButtons = {}
for i = 1, 6 do
    local btn = CreateFrame("Button", nil, makingAnAmaniOutOfYou.view, "BackdropTemplate")
    btn:SetSize(220, 24)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    btn:SetPoint("TOPLEFT", 0 + (col * 236), -138 - (row * 30))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    makingAnAmaniOutOfYou.childButtons[i] = btn
end

thatsAlnFolks.view = CreateFrame("Frame", nil, AchievementView)
thatsAlnFolks.view:SetPoint("TOPLEFT", 18, -70)
thatsAlnFolks.view:SetPoint("BOTTOMRIGHT", -12, 12)
thatsAlnFolks.view:Hide()

thatsAlnFolks.summary = thatsAlnFolks.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
thatsAlnFolks.summary:SetPoint("TOPLEFT", 0, 0)
thatsAlnFolks.summary:SetJustifyH("LEFT")

thatsAlnFolks.criteriaTitle = thatsAlnFolks.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
thatsAlnFolks.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
thatsAlnFolks.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(thatsAlnFolks.view, -64)
    thatsAlnFolks.rewardIcon = reward.icon
    thatsAlnFolks.rewardLabel = reward.label
    thatsAlnFolks.rewardButton = reward.button
end

thatsAlnFolks.detailTitle = thatsAlnFolks.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
thatsAlnFolks.detailTitle:SetPoint("TOPLEFT", 0, -110)
thatsAlnFolks.detailTitle:SetText(UIText("Criteria", "Criteria"))

thatsAlnFolks.emptyText = thatsAlnFolks.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
thatsAlnFolks.emptyText:SetPoint("TOPLEFT", 0, -138)
thatsAlnFolks.emptyText:SetPoint("RIGHT", -12, 0)
thatsAlnFolks.emptyText:SetJustifyH("LEFT")
thatsAlnFolks.emptyText:SetWordWrap(true)
thatsAlnFolks.emptyText:SetText("|cffb8b8b8Tracked entries for That's Aln, Folks! have not been added yet.|r")

thatsAlnFolks.childButtons = {}
for i = 1, 8 do
    local btn = CreateFrame("Button", nil, thatsAlnFolks.view, "BackdropTemplate")
    btn:SetSize(220, 24)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    btn:SetPoint("TOPLEFT", 0 + (col * 236), -138 - (row * 30))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    thatsAlnFolks.childButtons[i] = btn
end

foreverSong.view = CreateFrame("Frame", nil, AchievementView)
foreverSong.view:SetPoint("TOPLEFT", 18, -70)
foreverSong.view:SetPoint("BOTTOMRIGHT", -12, 12)
foreverSong.view:Hide()

foreverSong.summary = foreverSong.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
foreverSong.summary:SetPoint("TOPLEFT", 0, 0)
foreverSong.summary:SetJustifyH("LEFT")

foreverSong.criteriaTitle = foreverSong.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
foreverSong.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
foreverSong.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(foreverSong.view, -64)
    foreverSong.rewardIcon = reward.icon
    foreverSong.rewardLabel = reward.label
    foreverSong.rewardButton = reward.button
end

foreverSong.detailTitle = foreverSong.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
foreverSong.detailTitle:SetPoint("TOPLEFT", 0, -110)
foreverSong.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

foreverSong.emptyText = foreverSong.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
foreverSong.emptyText:SetPoint("TOPLEFT", 0, -138)
foreverSong.emptyText:SetPoint("RIGHT", -12, 0)
foreverSong.emptyText:SetJustifyH("LEFT")
foreverSong.emptyText:SetWordWrap(true)
foreverSong.emptyText:SetText("|cffb8b8b8Tracked entries for Forever Song have not been added yet.|r")

foreverSong.childButtons = {}
for i = 1, 6 do
    local btn = CreateFrame("Button", nil, foreverSong.view, "BackdropTemplate")
    btn:SetSize(220, 24)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    btn:SetPoint("TOPLEFT", 0 + (col * 236), -138 - (row * 30))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    foreverSong.childButtons[i] = btn
end

yellingIntoVoidstorm.view = CreateFrame("Frame", nil, AchievementView)
yellingIntoVoidstorm.view:SetPoint("TOPLEFT", 18, -70)
yellingIntoVoidstorm.view:SetPoint("BOTTOMRIGHT", -12, 12)
yellingIntoVoidstorm.view:Hide()

yellingIntoVoidstorm.summary = yellingIntoVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
yellingIntoVoidstorm.summary:SetPoint("TOPLEFT", 0, 0)
yellingIntoVoidstorm.summary:SetJustifyH("LEFT")

yellingIntoVoidstorm.criteriaTitle = yellingIntoVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
yellingIntoVoidstorm.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
yellingIntoVoidstorm.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(yellingIntoVoidstorm.view, -64)
    yellingIntoVoidstorm.rewardIcon = reward.icon
    yellingIntoVoidstorm.rewardLabel = reward.label
    yellingIntoVoidstorm.rewardButton = reward.button
end

yellingIntoVoidstorm.detailTitle = yellingIntoVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
yellingIntoVoidstorm.detailTitle:SetPoint("TOPLEFT", 0, -110)
yellingIntoVoidstorm.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))

yellingIntoVoidstorm.emptyText = yellingIntoVoidstorm.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
yellingIntoVoidstorm.emptyText:SetPoint("TOPLEFT", 0, -138)
yellingIntoVoidstorm.emptyText:SetPoint("RIGHT", -12, 0)
yellingIntoVoidstorm.emptyText:SetJustifyH("LEFT")
yellingIntoVoidstorm.emptyText:SetWordWrap(true)
yellingIntoVoidstorm.emptyText:SetText("|cffb8b8b8Tracked entries for Yelling into the Voidstorm have not been added yet.|r")

yellingIntoVoidstorm.childButtons = {}
for i = 1, 6 do
    local btn = CreateFrame("Button", nil, yellingIntoVoidstorm.view, "BackdropTemplate")
    btn:SetSize(220, 24)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    btn:SetPoint("TOPLEFT", 0 + (col * 236), -138 - (row * 30))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    yellingIntoVoidstorm.childButtons[i] = btn
end

lightUpTheNight.view = CreateFrame("Frame", nil, AchievementView)
lightUpTheNight.view:SetPoint("TOPLEFT", 18, -70)
lightUpTheNight.view:SetPoint("BOTTOMRIGHT", -12, 12)
lightUpTheNight.view:Hide()

lightUpTheNight.summary = lightUpTheNight.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lightUpTheNight.summary:SetPoint("TOPLEFT", 0, 0)
lightUpTheNight.summary:SetJustifyH("LEFT")

lightUpTheNight.criteriaTitle = lightUpTheNight.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lightUpTheNight.criteriaTitle:SetPoint("TOPLEFT", 0, -36)
lightUpTheNight.criteriaTitle:SetText(UIText("LABEL_REWARD", "Reward"))

do
    local reward = CreateAchievementRewardDisplay(lightUpTheNight.view, -64)
    lightUpTheNight.rewardIcon = reward.icon
    lightUpTheNight.rewardLabel = reward.label
    lightUpTheNight.rewardButton = reward.button
end

lightUpTheNight.detailTitle = lightUpTheNight.view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lightUpTheNight.detailTitle:SetPoint("TOPLEFT", 0, -110)
lightUpTheNight.detailTitle:SetText(UIText("Criteria", "Criteria"))

lightUpTheNight.emptyText = lightUpTheNight.view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lightUpTheNight.emptyText:SetPoint("TOPLEFT", 0, -138)
lightUpTheNight.emptyText:SetPoint("RIGHT", -12, 0)
lightUpTheNight.emptyText:SetJustifyH("LEFT")
lightUpTheNight.emptyText:SetWordWrap(true)
lightUpTheNight.emptyText:SetText("|cffb8b8b8Tracked entries for Light Up the Night have not been added yet.|r")

lightUpTheNight.childButtons = {}
for i = 1, 4 do
    local btn = CreateFrame("Button", nil, lightUpTheNight.view, "BackdropTemplate")
    btn:SetSize(220, 24)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    btn:SetPoint("TOPLEFT", 0 + (col * 236), -138 - (row * 30))
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("LEFT", 8, 0)
    btn.Text:SetPoint("RIGHT", -8, 0)
    btn.Text:SetJustifyH("LEFT")
    btn.Text:SetWordWrap(false)
    btn:Hide()
    lightUpTheNight.childButtons[i] = btn
end

delverDetailTitle = delverView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
delverDetailTitle:SetPoint("TOPLEFT", 0, -170)
delverDetailTitle:SetText(UIText("Criteria", "Criteria"))

delverCriteriaRows = {}
for i = 1, 12 do
    local row = delverView:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row:SetPoint("TOPLEFT", 0, -196 - ((i - 1) * 22))
    row:SetJustifyH("LEFT")
    delverCriteriaRows[i] = row
end

local achievementsContent = CreateFrame("Frame", nil, achievementsScroll)
achievementsContent:SetSize(880, 1)
achievementsScroll:SetScrollChild(achievementsContent)
achievementsScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = math.max(0, achievementsContent:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(maxScroll, current - (delta * 40))))
end)

local achievementsEmpty = achievementsContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
achievementsEmpty:SetPoint("TOPLEFT", 12, -10)
achievementsEmpty:SetJustifyH("LEFT")
achievementsEmpty:SetText("|cff888888" .. UIText("MSG_NO_ACHIEVEMENT_DATA", "No achievement tracking data is available.") .. "|r")
achievementsEmpty:Hide()

local achievementPanels = {}
for i = 1, 4 do
    local panel = CreateFrame("Frame", nil, achievementsContent, "BackdropTemplate")
    panel:SetSize(418, 206)
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    panel:SetPoint("TOPLEFT", 12 + (col * 432), -10 - (row * 216))
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })

    panel.header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.header:SetPoint("TOPLEFT", 12, -12)
    panel.header:SetJustifyH("LEFT")

    panel.buttons = {}
    for idx = 1, 12 do
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(190, 18)
        local btnCol = (idx - 1) % 2
        local btnRow = math.floor((idx - 1) / 2)
        btn:SetPoint("TOPLEFT", 12 + (btnCol * 198), -40 - (btnRow * 24))
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.text:SetPoint("LEFT", 0, 0)
        btn.text:SetWidth(190)
        btn.text:SetWordWrap(false)
        btn.text:SetJustifyH("LEFT")
        btn:Hide()
        panel.buttons[idx] = btn
    end

    panel:Hide()
    achievementPanels[i] = panel

    do
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            panel:SetBackdropColor(unpack(t.background))
            panel:SetBackdropBorderColor(unpack(t.borderSecondary))
        end
    end

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(panel, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderSecondary))
            end)
            local t = lv.GetTheme()
            panel:SetBackdropColor(unpack(t.background))
            panel:SetBackdropBorderColor(unpack(t.borderSecondary))
        end
    end)
end

local function RefreshAchievementsButton()
    local t = lv.GetTheme()
    if not t then return end
    local achActive = (currentMainView == "achievements")
    local instActive = (currentMainView == "instances")
    local dashActive = (currentMainView == "dashboard")
    local optActive = (currentMainView == "options")
    local factionActive = (currentMainView == "factions")

    dashboardTab:SetBackdropBorderColor(unpack(dashActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    dashboardTab:SetBackdropColor(unpack(dashActive and (t.buttonBgHover or t.buttonBgAlt or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
    dashboardTab.Text:SetTextColor(unpack(dashActive and t.textPrimary or t.textSecondary))
    optionsTab:SetBackdropBorderColor(unpack(optActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    optionsTab:SetBackdropColor(unpack(optActive and (t.buttonBgHover or t.buttonBgAlt or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
    optionsTab.Text:SetTextColor(unpack(optActive and t.textPrimary or t.textSecondary))
    factionsTab:SetBackdropBorderColor(unpack(factionActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    factionsTab:SetBackdropColor(unpack(factionActive and (t.buttonBgHover or t.buttonBgAlt or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
    factionsTab.Text:SetTextColor(unpack(factionActive and t.textPrimary or t.textSecondary))
    optionsTab:ClearAllPoints()
    optionsTab:SetPoint("BOTTOMLEFT", LVWindow, "TOPLEFT", 34, -3)

    dashboardTab:ClearAllPoints()
    dashboardTab:SetPoint("LEFT", optionsTab, "RIGHT", -4, 0)

    factionsTab:ClearAllPoints()
    factionsTab:SetPoint("LEFT", dashboardTab, "RIGHT", -4, 0)

    achievementsBtn:SetBackdropBorderColor(unpack(achActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    achievementsBtn:SetBackdropColor(unpack(achActive and (t.buttonBgHover or t.buttonBgAlt or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
    achievementsBtn.Text:SetTextColor(unpack(achActive and t.textPrimary or t.textSecondary))
    achievementsBtn:ClearAllPoints()
    achievementsBtn:SetPoint("LEFT", factionsTab, "RIGHT", -4, 0)

    instancesTab:SetBackdropBorderColor(unpack(instActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    instancesTab:SetBackdropColor(unpack(instActive and (t.buttonBgHover or t.buttonBgAlt or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
    instancesTab.Text:SetTextColor(unpack(instActive and t.textPrimary or t.textSecondary))
    instancesTab:ClearAllPoints()
    instancesTab:SetPoint("LEFT", achievementsBtn, "RIGHT", -4, 0)
  end
lv.RefreshAchievementsButton = RefreshAchievementsButton

C_Timer.After(0, RefreshAchievementsButton)
if lv.RegisterThemedElement then
    lv.RegisterThemedElement(AchievementView, function(_, theme)
        ApplyAchievementsTheme(theme)
    end)
    lv.RegisterThemedElement(dashboardTab, function()
        RefreshAchievementsButton()
    end)
    lv.RegisterThemedElement(achievementsBtn, function()
        RefreshAchievementsButton()
    end)
    lv.RegisterThemedElement(instancesTab, function()
        RefreshAchievementsButton()
    end)
    lv.RegisterThemedElement(factionsTab, function()
        RefreshAchievementsButton()
    end)
    lv.RegisterThemedElement(optionsTab, function()
        RefreshAchievementsButton()
    end)
    lv.RegisterThemedElement(home.treasureLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.treasureLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.glyphHunterLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.peaksLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.peaksLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.raresLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.raresLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.everPaintingLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.everPaintingLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.runestoneRushLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.runestoneRushLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.partyMustGoOnLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.partyMustGoOnLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.exploreEversongLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.exploreEversongLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.foreverSongLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.foreverSongLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.yellingIntoVoidstormLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.yellingIntoVoidstormLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.makingAnAmaniLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.makingAnAmaniLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.thatsAlnFolksLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.thatsAlnFolksLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.lightUpTheNightLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.lightUpTheNightLaunchNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    for _, btn in ipairs(treasureAchievementButtons or {}) do
        lv.RegisterThemedElement(btn, function(b, theme)
            local selected = (treasureSelectedAchievementID == b.achievementID)
            b:SetBackdropColor(unpack(selected and (theme.buttonBgHover or theme.buttonBg) or (theme.buttonBgAlt or theme.buttonBg)))
            b:SetBackdropBorderColor(unpack(selected and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            b.Text:SetTextColor(unpack(theme.textPrimary))
        end)
    end
    lv.RegisterThemedElement(home.delverLaunchBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    for _, btn in ipairs(delverAchievementButtons or {}) do
        lv.RegisterThemedElement(btn, function(b, theme)
            local selected = (delverSelectedAchievementID == b.achievementID)
            b:SetBackdropColor(unpack(selected and (theme.buttonBgHover or theme.buttonBg) or (theme.buttonBgAlt or theme.buttonBg)))
            b:SetBackdropBorderColor(unpack(selected and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            b.Text:SetTextColor(unpack(theme.textPrimary))
        end)
    end
    for _, btn in ipairs(peaksAchievementButtons or {}) do
        lv.RegisterThemedElement(btn, function(b, theme)
            local selected = (peaksSelectedAchievementID == b.achievementID)
            b:SetBackdropColor(unpack(selected and (theme.buttonBgHover or theme.buttonBg) or (theme.buttonBgAlt or theme.buttonBg)))
            b:SetBackdropBorderColor(unpack(selected and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            b.Text:SetTextColor(unpack(theme.textPrimary))
        end)
    end
    for _, btn in ipairs(rares.achievementButtons or {}) do
        lv.RegisterThemedElement(btn, function(b, theme)
            local selected = (rares.selectedAchievementID == b.achievementID)
            b:SetBackdropColor(unpack(selected and (theme.buttonBgHover or theme.buttonBg) or (theme.buttonBgAlt or theme.buttonBg)))
            b:SetBackdropBorderColor(unpack(selected and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            b.Text:SetTextColor(unpack(theme.textPrimary))
        end)
    end
    for _, btn in ipairs(rares.criteriaRows or {}) do
        lv.RegisterThemedElement(btn, function(b, theme)
            b:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
            b:SetBackdropBorderColor(unpack(theme.borderPrimary))
            if b.Text then
                b.Text:SetTextColor(unpack(theme.textPrimary))
            end
        end)
    end
    lv.RegisterThemedElement(glyphHunterBackBtn, function(btn, theme)
        btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.glyphRewardText, function(label, theme)
        label:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.glyphRewardNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
    lv.RegisterThemedElement(home.delverRewardText, function(label, theme)
        label:SetTextColor(unpack(theme.textPrimary))
    end)
    lv.RegisterThemedElement(home.delverRewardNote, function(label, theme)
        label:SetTextColor(unpack(theme.textSecondary))
    end)
end

do
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        ApplyAchievementsTheme(t)
    end
end

local function RenderAchievementsHome()
    achievementsTitle:SetText(UIText("TITLE_ACHIEVEMENTS", "Achievements"))
    achievementsSubtitle:SetText(UIText("DESC_ACHIEVEMENTS", "Choose an achievement tracker to view detailed progress."))
    glyphHunterBackBtn.Text:SetText(UIText("Back", "Back"))
    local rewardName = lv.GetLocalizedItemNameByID(REWARD_ITEM.CRIMSON_DRAGONHAWK, UIText("Crimson Dragonhawk", "Crimson Dragonhawk"))
    local hasReward = HasAchievement(ACH.MIDNIGHT_GLYPH_HUNTER) and HasMountRewardFromItem(REWARD_ITEM.CRIMSON_DRAGONHAWK)
    local rewardColor = hasReward and "|cff00ff00" or "|cffff8040"
    home.glyphRewardText:SetText(string.format("%s: %s%s|r", UIText("LABEL_REWARD", "Reward"), rewardColor, rewardName))
    local delverRewardName = lv.GetLocalizedItemNameByID(REWARD_ITEM.GIGANTO_MANIS, UIText("Giganto-Manis", "Giganto-Manis"))
    local delverHasReward = HasAchievement(ACH.GLORY_OF_THE_MIDNIGHT_DELVER) and HasMountRewardFromItem(REWARD_ITEM.GIGANTO_MANIS)
    local delverRewardColor = delverHasReward and "|cff00ff00" or "|cffff8040"
    home.delverRewardText:SetText(string.format("%s: %s%s|r", UIText("LABEL_REWARD", "Reward"), delverRewardColor, delverRewardName))
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderAchievementSelectionButtons(buttons, entries, selectedID)
    local doneCount = 0
    for i, info in ipairs(entries) do
        local complete = HasAchievement(info.id)
        if complete then
            doneCount = doneCount + 1
        end
        local btn = buttons[i]
        local label = GetAchievementName(info.id, info.name)
        if btn then
            btn.Text:SetText(string.format("%s%s|r", complete and "|cff00ff00" or "|cffff5555", label))
            local t = lv.GetTheme()
            local selected = (selectedID == info.id)
            if t then
                btn:SetBackdropColor(unpack(selected and (t.buttonBgHover or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
                btn:SetBackdropBorderColor(unpack(selected and (t.borderHover or t.borderPrimary) or t.borderPrimary))
                btn.Text:SetTextColor(unpack(t.textPrimary))
            end
        end
    end
    return doneCount
end

local function ResolveSelectedAchievement(entries, selectedID)
    local resolvedID = selectedID or (entries[1] and entries[1].id or nil)
    local selectedName, criteriaRows = nil, {}
    for _, info in ipairs(entries) do
        if info.id == resolvedID then
            selectedName = GetAchievementName(info.id, info.name)
            criteriaRows = GetAchievementCriteriaRows(info.id)
            break
        end
    end
    return resolvedID, selectedName, criteriaRows
end

local function ResolveSelectedAchievementWithDescription(entries, selectedID)
    local resolvedID, selectedName, criteriaRows = ResolveSelectedAchievement(entries, selectedID)
    if #criteriaRows == 0 and resolvedID then
        local description = GetAchievementDescription(resolvedID)
        if description and description ~= "" then
            criteriaRows = {
                { text = description, done = HasAchievement(resolvedID) }
            }
        end
    end
    return resolvedID, selectedName, criteriaRows
end

local function SetItemRewardDisplay(icon, label, button, rewardInfo, emptyText, extraTooltipLine)
    if rewardInfo and rewardInfo.type == "item" and rewardInfo.itemID then
        local displayText = rewardInfo.label and lv.LocalizeDisplayText(rewardInfo.label, rewardInfo.label) or lv.GetLocalizedItemNameByID(rewardInfo.itemID, "Item")
        icon:SetTexture(C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(rewardInfo.itemID) or nil)
        icon:Show()
        label:Show()
        label:SetText(displayText)
        button:Show()
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if GameTooltip.SetItemByID then
                GameTooltip:SetItemByID(rewardInfo.itemID)
            else
                GameTooltip:SetText(displayText or "Reward", 1, 0.82, 0)
            end
            if extraTooltipLine and extraTooltipLine ~= "" then
                GameTooltip:AddLine(extraTooltipLine, 0.8, 0.8, 0.8, true)
            end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return
    end
    if rewardInfo and rewardInfo.label and rewardInfo.label ~= "" then
        local displayText = lv.LocalizeDisplayText(rewardInfo.label, rewardInfo.label)
        icon:Hide()
        label:Show()
        label:SetText(displayText)
        button:Show()
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(displayText, 1, 0.82, 0)
            if extraTooltipLine and extraTooltipLine ~= "" then
                GameTooltip:AddLine(extraTooltipLine, 0.8, 0.8, 0.8, true)
            end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return
    end
    icon:Hide()
    if emptyText and emptyText ~= "" then
        label:Show()
        label:SetText(emptyText)
    else
        label:SetText("")
        label:Hide()
    end
    button:Hide()
    button:SetScript("OnEnter", nil)
    button:SetScript("OnLeave", nil)
end

local function GetAchievementRewardFallback(achievementID)
    if not achievementID or not GetAchievementInfo then
        return nil
    end
    local rewardText = select(11, GetAchievementInfo(achievementID))
    if type(rewardText) == "string" and rewardText ~= "" then
        return { label = rewardText }
    end
    return nil
end

local function SetSharedLootDisplay(titleLabel, slots, items)
    if items and #items > 0 then
        titleLabel:Show()
        for i, slot in ipairs(slots) do
            local info = items[i]
            if info and info.itemID then
                local displayText = info.label and lv.LocalizeDisplayText(info.label, info.label) or lv.GetLocalizedItemNameByID(info.itemID, "Item")
                slot.icon:SetTexture(C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(info.itemID) or nil)
                slot.icon:Show()
                slot.label:SetText(displayText)
                slot.label:Show()
                slot.button:Show()
                slot.button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    if GameTooltip.SetItemByID then
                        GameTooltip:SetItemByID(info.itemID)
                    else
                        GameTooltip:SetText(displayText, 1, 0.82, 0)
                    end
                    if info.note and info.note ~= "" then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine(info.note, 0.8, 0.8, 0.8, true)
                    end
                    GameTooltip:Show()
                end)
                slot.button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            else
                slot.icon:Hide()
                slot.label:SetText("")
                slot.label:Hide()
                slot.button:Hide()
                slot.button:SetScript("OnEnter", nil)
                slot.button:SetScript("OnLeave", nil)
            end
        end
        return
    end
    titleLabel:Hide()
    for _, slot in ipairs(slots) do
        slot.icon:Hide()
        slot.label:SetText("")
        slot.label:Hide()
        slot.button:Hide()
        slot.button:SetScript("OnEnter", nil)
        slot.button:SetScript("OnLeave", nil)
    end
end

local function SetRareRewardIcons(btn, rewards)
    local rewardSlots = {
        { icon = btn.rewardIcon, button = btn.rewardButton },
        { icon = btn.rewardIcon2, button = btn.rewardButton2 },
        { icon = btn.rewardIcon3, button = btn.rewardButton3 },
    }
    for slotIndex, slot in ipairs(rewardSlots) do
        local rewardInfo = rewards and rewards[slotIndex] or nil
        if rewardInfo and rewardInfo.itemID then
            slot.icon:SetTexture(C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(rewardInfo.itemID) or nil)
            slot.icon:Show()
            slot.button:Show()
            slot.button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if GameTooltip.SetItemByID then
                    GameTooltip:SetItemByID(rewardInfo.itemID)
                else
                    local tooltipText = rewardInfo.label and lv.LocalizeDisplayText(rewardInfo.label, rewardInfo.label) or lv.GetLocalizedItemNameByID(rewardInfo.itemID, "Item")
                    GameTooltip:SetText(tooltipText, 1, 0.82, 0)
                end
                GameTooltip:Show()
            end)
            slot.button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        else
            slot.icon:Hide()
            slot.button:Hide()
            slot.button:SetScript("OnEnter", nil)
            slot.button:SetScript("OnLeave", nil)
        end
    end
end

local function SetRareDetailButton(btn, info, isRareDone, fallbackLabel)
    btn.Text:SetText(string.format("%s%s|r", isRareDone and "|cff00ff00" or "|cffff5555", info.name or info.label or fallbackLabel))
    SetRareRewardIcons(btn, info.rewards)
    btn:SetScript("OnClick", function()
        if info.mapID and info.x and info.y then
            SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name or info.label or fallbackLabel)
        end
    end)
    btn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
        if info.mapID and info.x and info.y then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(info.name or info.label or fallbackLabel, 1, 0.82, 0)
            GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
            if info.note and info.note ~= "" then
                GameTooltip:AddLine(info.note, 0.8, 0.8, 0.8, true)
            end
            if info.rep and info.rep ~= "" then
                GameTooltip:AddLine(info.rep, 0.85, 0.85, 0.85)
            end
            GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        self.Text:SetTextColor(unpack(t.textPrimary))
        GameTooltip:Hide()
    end)
    btn:Show()
end

local function HideRareDetailButton(btn)
    btn.Text:SetText("")
    btn.rewardIcon:Hide()
    btn.rewardButton:Hide()
    btn.rewardButton:SetScript("OnEnter", nil)
    btn.rewardButton:SetScript("OnLeave", nil)
    btn.rewardIcon2:Hide()
    btn.rewardButton2:Hide()
    btn.rewardButton2:SetScript("OnEnter", nil)
    btn.rewardButton2:SetScript("OnLeave", nil)
    btn.rewardIcon3:Hide()
    btn.rewardButton3:Hide()
    btn.rewardButton3:SetScript("OnEnter", nil)
    btn.rewardButton3:SetScript("OnLeave", nil)
    btn:SetScript("OnClick", nil)
    btn:SetScript("OnEnter", nil)
    btn:SetScript("OnLeave", nil)
    btn:Hide()
end

local function SetPeaksWaypointRows(rows, waypointRows, renownLabel)
    for i, row in ipairs(rows) do
        row.Text:SetText("")
        if row.RenownText then
            row.RenownText:SetText("")
        end
        row:SetScript("OnClick", nil)
        row:SetScript("OnEnter", nil)
        row:SetScript("OnLeave", nil)
        row:Hide()
        local info = waypointRows and waypointRows[i]
        if info then
            row.Text:SetText(string.format("%.2f, %.2f - %s", info.x, info.y, info.name))
            if row.RenownText then
                row.RenownText:SetText(renownLabel and string.format("100 Renown: %s", renownLabel) or "")
            end
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                if self.Text then
                    self.Text:SetTextColor(1, 0.82, 0)
                end
                if self.RenownText then
                    self.RenownText:SetTextColor(0.85, 0.85, 0.85)
                end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                if renownLabel then
                    GameTooltip:AddLine(string.format("100 Renown: %s", renownLabel), 1, 0.82, 0)
                end
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme and lv.GetTheme() or nil
                if self.Text and t then
                    self.Text:SetTextColor(unpack(t.textPrimary))
                end
                if self.RenownText and t then
                    self.RenownText:SetTextColor(unpack(t.textSecondary))
                end
                GameTooltip:Hide()
            end)
            row:Show()
        end
    end
end

local function RenderRaresAchievementsView()
    local doneCount = RenderAchievementSelectionButtons(rares.achievementButtons, MIDNIGHT_RARES_OF_MIDNIGHT, rares.selectedAchievementID)
    local selectedName, criteriaRows
    rares.selectedAchievementID, selectedName, criteriaRows = ResolveSelectedAchievement(MIDNIGHT_RARES_OF_MIDNIGHT, rares.selectedAchievementID)
    local completedRareLookup = {}
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                completedRareLookup[normalizedName] = rowInfo.done and true or false
            end
        end
    end
    achievementsTitle:SetText("Rares of Midnight")
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%d/%d|r", UIText("LABEL_ACHIEVEMENT", "Achievement"), doneCount, #MIDNIGHT_RARES_OF_MIDNIGHT))
    rares.summary:SetText(UIText("Track the four Midnight rare achievements.", "Track the four Midnight rare achievements."))
    rares.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), selectedName or UIText("LABEL_UNKNOWN", "Unknown")))
    SetItemRewardDisplay(rares.rewardIcon, rares.rewardLabel, rares.rewardButton, MIDNIGHT_RARES_REWARDS[rares.selectedAchievementID], "|cff999999Zone reward not added yet.|r")
    SetSharedLootDisplay(rares.sharedLootTitle, rares.sharedLootSlots, MIDNIGHT_RARES_SHARED_LOOT[rares.selectedAchievementID])

    local detailRows = MIDNIGHT_RARES_DETAILS[rares.selectedAchievementID] or {}
    for i, btn in ipairs(rares.criteriaRows) do
        local info = detailRows[i]
        if info then
            local isRareDone = completedRareLookup[NormalizeAchievementTreasureName(info.name or info.label or ("Rare " .. i))] and true or false
            SetRareDetailButton(btn, info, isRareDone, string.format("Rare %d", i))
        else
            HideRareDetailButton(btn)
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderDelverAchievementsView()
    local doneCount = RenderAchievementSelectionButtons(delverAchievementButtons, MIDNIGHT_DELVER_CRITERIA, delverSelectedAchievementID)
    local selectedName, criteriaRows
    delverSelectedAchievementID, selectedName, criteriaRows = ResolveSelectedAchievementWithDescription(MIDNIGHT_DELVER_CRITERIA, delverSelectedAchievementID)
    achievementsTitle:SetText(UIText("Glory of the Midnight Delver", "Glory of the Midnight Delver"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%d/%d|r", UIText("LABEL_CRITERIA", "Criteria"), doneCount, #MIDNIGHT_DELVER_CRITERIA))
    delverSummary:SetText(UIText("Complete all four supporting Midnight delver achievements to finish this meta achievement.", "Complete all four supporting Midnight delver achievements to finish this meta achievement."))
    delverDetailTitle:SetText(string.format("%s: %s", UIText("LABEL_CRITERIA", "Criteria"), selectedName or UIText("LABEL_UNKNOWN", "Unknown")))
    for i, row in ipairs(delverCriteriaRows) do
        local info = criteriaRows[i]
        if info then
            row:SetText(string.format("%s%s|r", info.done and "|cff00ff00" or "|cffff5555", info.text))
            row:Show()
        else
            row:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderPeaksAchievementsView()
    local doneCount = RenderAchievementSelectionButtons(peaksAchievementButtons, MIDNIGHT_HIGHEST_PEAKS_CRITERIA, peaksSelectedAchievementID)
    local selectedName, criteriaRows
    peaksSelectedAchievementID, selectedName, criteriaRows = ResolveSelectedAchievementWithDescription(MIDNIGHT_HIGHEST_PEAKS_CRITERIA, peaksSelectedAchievementID)
    achievementsTitle:SetText(GetAchievementName(ACH.MIDNIGHT_HIGHEST_PEAKS, "Midnight, the Highest Peaks"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%d/%d|r", UIText("LABEL_CRITERIA", "Criteria"), doneCount, #MIDNIGHT_HIGHEST_PEAKS_CRITERIA))
    peaksSummary:SetText(UIText("Complete the five telescopes in this zone.", "Complete the five telescopes in this zone."))
    peaksCriteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), selectedName or UIText("LABEL_UNKNOWN", "Unknown")))
    SetItemRewardDisplay(peaksRewardIcon, peaksRewardLabel, peaksRewardButton, MIDNIGHT_HIGHEST_PEAKS_REWARDS[peaksSelectedAchievementID], "")
    peaksDetailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    local waypointRows = MIDNIGHT_HIGHEST_PEAKS_WAYPOINTS[peaksSelectedAchievementID]
    if waypointRows and #waypointRows > 0 then
        local renownKey = MIDNIGHT_HIGHEST_PEAKS_RENOWN_KEYS[peaksSelectedAchievementID]
        local renownLabel = (renownKey and L[renownKey] and L[renownKey] ~= renownKey) and L[renownKey] or nil
        SetPeaksWaypointRows(peaksCriteriaRows, waypointRows, renownLabel)
    else
        for i, row in ipairs(peaksCriteriaRows) do
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            local info = criteriaRows[i]
            if info then
                row.Text:SetText(string.format("%s%s|r", info.done and "|cff00ff00" or "|cffff5555", info.text))
                if row.RenownText then
                    row.RenownText:SetText("")
                end
                row:Show()
            else
                row.Text:SetText("")
                if row.RenownText then
                    row.RenownText:SetText("")
                end
                row:Hide()
            end
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderGlyphHunterAchievementsView()
    local zones = lv.GetMidnightGlyphZones and lv.GetMidnightGlyphZones() or nil
    if not zones or #zones == 0 then
        achievementsEmpty:Show()
        achievementsSubtitle:SetText(UIText("MSG_NO_ACHIEVEMENT_DATA", "No achievement tracking data is available."))
        for _, panel in ipairs(achievementPanels) do
            panel:Hide()
        end
        achievementsContent:SetHeight(120)
        return
    end

    achievementsEmpty:Hide()
    local totalDone, totalCount = 0, 0
    for idx, zoneData in ipairs(zones) do
        local panel = achievementPanels[idx]
        if panel then
            local done, total = (lv.CountCompletedGlyphs and lv.CountCompletedGlyphs(zoneData)) or 0, (zoneData.glyphs and #zoneData.glyphs or 0)
            totalDone = totalDone + done
            totalCount = totalCount + total
            panel.header:SetText(string.format("|cffffffcc%s: |cffffff00%d/%d|r", zoneData.zoneName, done, total))

            for buttonIndex, btn in ipairs(panel.buttons) do
                btn:Hide()
                btn:SetScript("OnClick", nil)
                btn:SetScript("OnEnter", nil)
                btn:SetScript("OnLeave", nil)
                local glyph = zoneData.glyphs and zoneData.glyphs[buttonIndex]
                if glyph then
                    local glyphDone = lv.IsGlyphCompleted and lv.IsGlyphCompleted(zoneData, glyph)
                    local color = glyphDone and "|cff00ff00" or "|cffff5555"
                    btn.text:SetText(string.format("%s%s|r", color, glyph.name or string.format("%.2f, %.2f", glyph.x or 0, glyph.y or 0)))
                    btn:SetScript("OnClick", function()
                        if lv.SetMapWaypoint then
                            lv.SetMapWaypoint(zoneData.mapID, glyph.x, glyph.y, glyph.name or zoneData.zoneName)
                        end
                    end)
                    btn:SetScript("OnEnter", function()
                        if GameTooltip then
                            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                            GameTooltip:SetText(glyph.name or zoneData.zoneName, 1, 0.82, 0)
                            if glyph.x and glyph.y then
                                GameTooltip:AddLine(string.format("%.2f, %.2f", glyph.x, glyph.y), 0.8, 0.8, 0.8)
                            end
                            GameTooltip:Show()
                        end
                    end)
                    btn:SetScript("OnLeave", function()
                        if GameTooltip then GameTooltip:Hide() end
                    end)
                    btn:Show()
                end
            end
            panel:Show()
        end
    end
    achievementsTitle:SetText(GetAchievementName(ACH.MIDNIGHT_GLYPH_HUNTER, UIText("TITLE_MIDNIGHT_GLYPH_HUNTER", "Midnight Glyph Hunter")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%d/%d|r", UIText("LABEL_GLYPHS_COLLECTED", "Glyphs Collected"), totalDone, totalCount))
    achievementsContent:SetHeight(440)
end

local function RenderTreasureAchievementsView()
    local doneCount = 0
    for i, info in ipairs(TREASURES_OF_MIDNIGHT) do
        local complete = HasAchievement(info.id)
        if complete then
            doneCount = doneCount + 1
        end
        local btn = treasureAchievementButtons[i]
        local label = GetAchievementName(info.id, info.name)
        if btn then
            btn.Text:SetText(string.format("%s%s|r", complete and "|cff00ff00" or "|cffff5555", label))
            local t = lv.GetTheme()
            local selected = (treasureSelectedAchievementID == info.id)
            if t then
                btn:SetBackdropColor(unpack(selected and (t.buttonBgHover or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
                btn:SetBackdropBorderColor(unpack(selected and (t.borderHover or t.borderPrimary) or t.borderPrimary))
                btn.Text:SetTextColor(unpack(t.textPrimary))
            end
        end
    end
    if not treasureSelectedAchievementID then
        treasureSelectedAchievementID = TREASURES_OF_MIDNIGHT[1] and TREASURES_OF_MIDNIGHT[1].id or nil
    end
    local selectedName, rewardText, selectedTreasureInfo = nil, nil, nil
    local criteriaRows = {}
    local completedTreasureLookup = {}
    for _, info in ipairs(TREASURES_OF_MIDNIGHT) do
        if info.id == treasureSelectedAchievementID then
            selectedName = GetAchievementName(info.id, info.name)
            rewardText = GetAchievementRewardText(info.id)
            selectedTreasureInfo = info
            criteriaRows = GetAchievementCriteriaRows(info.id)
            for _, rowInfo in ipairs(criteriaRows) do
                if rowInfo and rowInfo.text then
                    local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
                    if normalizedName then
                        completedTreasureLookup[normalizedName] = rowInfo.done and true or false
                    end
                end
            end
            if #criteriaRows == 0 then
                local description = GetAchievementDescription(info.id)
                if description and description ~= "" then
                    criteriaRows = {
                        { text = description, done = HasAchievement(info.id) }
                    }
                end
            end
            break
        end
    end
    achievementsTitle:SetText(UIText("Treasures of Midnight", "Treasures of Midnight"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%d/%d|r", UIText("LABEL_ACHIEVEMENT", "Achievement"), doneCount, #TREASURES_OF_MIDNIGHT))
    treasureSummary:SetText(UIText("Track the four Midnight treasure achievements and their rewards.", "Track the four Midnight treasure achievements and their rewards."))
    treasureDetailTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), selectedName or UIText("LABEL_UNKNOWN", "Unknown")))
    local achievementRewardInfo = GetAchievementRewardDisplayInfo(treasureSelectedAchievementID, rewardText)
    if achievementRewardInfo and achievementRewardInfo.icon then
        treasureRewardText:Hide()
        treasureRewardIcon:SetTexture(achievementRewardInfo.icon)
        treasureRewardIcon:Show()
        treasureRewardLabel:SetText(lv.LocalizeDisplayText(achievementRewardInfo.label or "", achievementRewardInfo.label or ""))
        treasureRewardLabel:Show()
        treasureRewardButton:Show()
        treasureRewardButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if achievementRewardInfo.tooltipType == "item" and achievementRewardInfo.tooltipValue and GameTooltip.SetItemByID then
                GameTooltip:SetItemByID(achievementRewardInfo.tooltipValue)
            elseif achievementRewardInfo.tooltipType == "mount" and achievementRewardInfo.tooltipValue and GameTooltip.SetSpellByID then
                GameTooltip:SetSpellByID(achievementRewardInfo.tooltipValue)
            else
                local tooltipText = achievementRewardInfo.label or (selectedName or UIText("LABEL_UNKNOWN", "Unknown"))
                GameTooltip:SetText(lv.LocalizeDisplayText(tooltipText, tooltipText), 1, 0.82, 0)
            end
            GameTooltip:Show()
        end)
        treasureRewardButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    elseif achievementRewardInfo and achievementRewardInfo.label and achievementRewardInfo.label ~= "" then
        treasureRewardIcon:Hide()
        treasureRewardLabel:Hide()
        treasureRewardButton:Hide()
        treasureRewardText:Show()
        treasureRewardText:SetText(lv.LocalizeDisplayText(achievementRewardInfo.label, achievementRewardInfo.label))
    elseif rewardText and rewardText ~= "" then
        treasureRewardIcon:Hide()
        treasureRewardLabel:Hide()
        treasureRewardButton:Hide()
        treasureRewardText:Show()
        treasureRewardText:SetText(rewardText)
    else
        treasureRewardIcon:Hide()
        treasureRewardLabel:Hide()
        treasureRewardButton:Hide()
        treasureRewardText:Show()
        treasureRewardText:SetText("|cff999999" .. UIText("No achievement reward listed.", "No achievement reward listed.") .. "|r")
    end
    for _, row in ipairs(treasureCriteriaRows) do
        row:SetText("")
        row:Hide()
    end
    local currentY = 0
    local content = treasureCriteriaRows[1] and treasureCriteriaRows[1]:GetParent()
    if selectedTreasureInfo and selectedTreasureInfo.note and treasureCriteriaRows[1] then
        local noteRow = treasureCriteriaRows[1]
        noteRow:ClearAllPoints()
        noteRow:SetPoint("TOPLEFT", 0, -currentY)
        noteRow:SetText("|cffffd100Note:|r " .. selectedTreasureInfo.note)
        noteRow:Show()
        currentY = currentY + math.max(20, noteRow:GetStringHeight() + 8)
    end

    local activeTreasures = selectedTreasureInfo and selectedTreasureInfo.treasures or {}
    if not treasureSelectedEntry or not activeTreasures[treasureSelectedEntry] then
        treasureSelectedEntry = nil
    end

    for _, btnStep in ipairs(treasureStepButtons) do
        btnStep:Hide()
        btnStep:SetScript("OnClick", nil)
        btnStep:SetScript("OnEnter", nil)
        btnStep:SetScript("OnLeave", nil)
    end

    local stepIndex = 1
    for i, btn in ipairs(treasureButtons) do
        local treasure = activeTreasures[i]
        if treasure then
            local currentIndex = i
            local currentTreasure = treasure
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", 0, -currentY)
            btn:SetSize(740, 22)
            local isTreasureDone = completedTreasureLookup[NormalizeAchievementTreasureName(currentTreasure.name)] and true or false
            btn.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isTreasureDone and "|cff00ff00" or "|cffff5555", currentTreasure.x, currentTreasure.y, currentTreasure.name))
            local rewardList = currentTreasure.rewards or (currentTreasure.reward and { currentTreasure.reward }) or nil
            local rewardSlots = {
                { icon = btn.rewardIcon, label = btn.rewardLabel, button = btn.rewardButton },
                { icon = btn.rewardIcon2, label = btn.rewardLabel2, button = btn.rewardButton2 },
            }
            for slotIndex, slot in ipairs(rewardSlots) do
                local rewardInfo = rewardList and rewardList[slotIndex] or nil
                local iconTexture, tooltipType, tooltipValue, rewardLabelText = nil, nil, nil, nil
                if rewardInfo and rewardInfo.type == "item" and rewardInfo.itemID then
                    iconTexture = C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(rewardInfo.itemID)
                    tooltipType = "item"
                    tooltipValue = rewardInfo.itemID
                    rewardLabelText = rewardInfo.label and lv.LocalizeDisplayText(rewardInfo.label, rewardInfo.label) or lv.GetLocalizedItemNameByID(rewardInfo.itemID, "Item")
                elseif rewardInfo and rewardInfo.type == "mount" and rewardInfo.name then
                    local mountInfo = GetMountRewardInfoByName(rewardInfo.name)
                    if mountInfo then
                        iconTexture = mountInfo.icon
                        tooltipType = "mount"
                        tooltipValue = mountInfo.spellID
                    end
                    rewardLabelText = lv.LocalizeDisplayText(rewardInfo.label or ("Mount: " .. rewardInfo.name), rewardInfo.label or ("Mount: " .. rewardInfo.name))
                end
                if rewardInfo and iconTexture then
                    slot.icon:SetTexture(iconTexture)
                    slot.icon:Show()
                    slot.label:SetText(rewardLabelText or "")
                    slot.label:Show()
                    slot.button:Show()
                    slot.button:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        if tooltipType == "item" and tooltipValue and GameTooltip.SetItemByID then
                            GameTooltip:SetItemByID(tooltipValue)
                        elseif tooltipType == "mount" and tooltipValue and GameTooltip.SetSpellByID then
                            GameTooltip:SetSpellByID(tooltipValue)
                        else
                            GameTooltip:SetText(currentTreasure.name, 1, 0.82, 0)
                        end
                        GameTooltip:Show()
                    end)
                    slot.button:SetScript("OnLeave", function() GameTooltip:Hide() end)
                else
                    slot.icon:Hide()
                    slot.label:SetText("")
                    slot.label:Hide()
                    slot.button:Hide()
                    slot.button:SetScript("OnEnter", nil)
                    slot.button:SetScript("OnLeave", nil)
                end
            end
            btn:Show()
            btn:SetScript("OnClick", function()
                local now = GetTime and GetTime() or 0
                if treasureCollapseCooldownIndex == currentIndex and treasureCollapseCooldownUntil and now < treasureCollapseCooldownUntil then
                    return
                end
                if currentTreasure.steps then
                    if treasureSelectedEntry == currentIndex then
                        treasureSelectedEntry = nil
                        treasureCollapseCooldownIndex = currentIndex
                        treasureCollapseCooldownUntil = now + 0.30
                    else
                        treasureSelectedEntry = currentIndex
                        treasureCollapseCooldownIndex = nil
                        treasureCollapseCooldownUntil = nil
                    end
                else
                    SetAchievementTreasureWaypoint(currentTreasure.mapID, currentTreasure.x, currentTreasure.y, currentTreasure.name)
                    treasureSelectedEntry = nil
                    treasureCollapseCooldownIndex = nil
                    treasureCollapseCooldownUntil = nil
                end
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                local selected = (treasureSelectedEntry == currentIndex)
                self:SetBackdropBorderColor(unpack(selected and (t.borderHover or t.borderPrimary) or t.borderPrimary))
                self:SetBackdropColor(unpack(selected and (t.buttonBgHover or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
            end)
            local t = lv.GetTheme()
            if t then
                local selected = (treasureSelectedEntry == currentIndex)
                btn:SetBackdropBorderColor(unpack(selected and (t.borderHover or t.borderPrimary) or t.borderPrimary))
                btn:SetBackdropColor(unpack(selected and (t.buttonBgHover or t.buttonBg) or (t.buttonBgAlt or t.buttonBg)))
            end
            currentY = currentY + 26
            if treasureSelectedEntry == currentIndex and currentTreasure.steps then
                currentY = currentY + 2
                for _, step in ipairs(currentTreasure.steps) do
                    local currentStep = step
                    local btnStep = treasureStepButtons[stepIndex]
                    if btnStep then
                        btnStep:ClearAllPoints()
                        btnStep:SetPoint("TOPLEFT", 20, -currentY)
                        btnStep:SetSize(720, 20)
                        btnStep.Text:SetText(string.format("%.2f, %.2f - %s", currentStep.x, currentStep.y, currentStep.text))
                        btnStep:Show()
                        btnStep:SetScript("OnClick", function()
                            SetAchievementTreasureWaypoint(currentStep.mapID or currentTreasure.mapID, currentStep.x, currentStep.y, currentTreasure.name)
                        end)
                        btnStep:SetScript("OnEnter", function(self)
                            local t = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(t.borderHover))
                            self:SetBackdropColor(unpack(t.buttonBgHover))
                        end)
                        btnStep:SetScript("OnLeave", function(self)
                            local t = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(t.borderPrimary))
                            self:SetBackdropColor(unpack(t.dataBoxBgAlt or t.dataBoxBg))
                        end)
                        local t = lv.GetTheme()
                        if t then
                            btnStep:SetBackdropBorderColor(unpack(t.borderPrimary))
                            btnStep:SetBackdropColor(unpack(t.dataBoxBgAlt or t.dataBoxBg))
                        end
                        currentY = currentY + 24
                        stepIndex = stepIndex + 1
                    end
                end
                currentY = currentY + 4
            end
        else
            btn:Hide()
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
        end
    end
    if content then
        content:SetHeight(math.max(1, currentY + 8))
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderEverPaintingView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.EVER_PAINTING)
    local completedLookup = {}
    local seenCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    seenCount = seenCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.EVER_PAINTING) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif seenCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.EVER_PAINTING, "Ever-Painting"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    everPainting.summary:SetText(string.format(UIText("Track the known Ever-Painting canvases. x/y marked.", "Track the known Ever-Painting canvases. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), seenCount, #EVER_PAINTING_ENTRIES))
    everPainting.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.EVER_PAINTING, "Ever-Painting")))
    SetItemRewardDisplay(everPainting.rewardIcon, everPainting.rewardLabel, everPainting.rewardButton, EVER_PAINTING_REWARD, "")
    everPainting.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    everPainting.emptyText:SetShown(#EVER_PAINTING_ENTRIES == 0)
    for i, row in ipairs(everPainting.rows or {}) do
        local info = EVER_PAINTING_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderRunestoneRushView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.RUNESTONE_RUSH)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.RUNESTONE_RUSH) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.RUNESTONE_RUSH, UIText("Runestone Rush", "Runestone Rush")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    runestoneRush.summary:SetText(string.format(UIText("Track the known Runestone Rush entries. x/y marked.", "Track the known Runestone Rush entries. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #RUNESTONE_RUSH_ENTRIES))
    runestoneRush.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.RUNESTONE_RUSH, "Runestone Rush")))
    SetItemRewardDisplay(runestoneRush.rewardIcon, runestoneRush.rewardLabel, runestoneRush.rewardButton, RUNESTONE_RUSH_REWARD, "|cff999999Zone reward not added yet.|r")
    runestoneRush.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    runestoneRush.emptyText:SetShown(#RUNESTONE_RUSH_ENTRIES == 0)
    for i, row in ipairs(runestoneRush.rows or {}) do
        local info = RUNESTONE_RUSH_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Charge the runestone with Latent Arcana to start its defense event.", "Charge the runestone with Latent Arcana to start its defense event."), 0.8, 0.8, 0.8, true)
                if info.boss and info.boss ~= "" then
                    GameTooltip:AddLine(UIText("Achievement credit from:", "Achievement credit from:") .. " " .. info.boss, 1, 0.82, 0, true)
                end
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderPartyMustGoOnView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.THE_PARTY_MUST_GO_ON)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.THE_PARTY_MUST_GO_ON) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.THE_PARTY_MUST_GO_ON, UIText("The Party Must Go On", "The Party Must Go On")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    partyMustGoOn.summary:SetText(string.format(UIText("Track the four faction invites for The Party Must Go On. x/y marked.", "Track the four faction invites for The Party Must Go On. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #THE_PARTY_MUST_GO_ON_ENTRIES))
    partyMustGoOn.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.THE_PARTY_MUST_GO_ON, "The Party Must Go On")))
    SetItemRewardDisplay(partyMustGoOn.rewardIcon, partyMustGoOn.rewardLabel, partyMustGoOn.rewardButton, THE_PARTY_MUST_GO_ON_REWARD, "|cff999999Zone reward not added yet.|r")
    partyMustGoOn.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    partyMustGoOn.emptyText:SetShown(#THE_PARTY_MUST_GO_ON_ENTRIES == 0)
    for i, row in ipairs(partyMustGoOn.rows or {}) do
        local info = THE_PARTY_MUST_GO_ON_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            if info.x and info.y then
                row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            else
                row.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffff5555", info.name))
            end
            if info.mapID and info.x and info.y then
                row:SetScript("OnClick", function()
                    SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
                end)
            else
                row:SetScript("OnClick", nil)
            end
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                if info.x and info.y then
                    GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                    GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderExploreEversongView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.EXPLORE_EVERSONG_WOODS)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.EXPLORE_EVERSONG_WOODS) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.EXPLORE_EVERSONG_WOODS, "Explore Eversong Woods"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    exploreEversong.summary:SetText(string.format(UIText("Track Explore Eversong Woods progress. x/y marked.", "Track Explore Eversong Woods progress. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #EXPLORE_EVERSONG_WOODS_ENTRIES))
    exploreEversong.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.EXPLORE_EVERSONG_WOODS, "Explore Eversong Woods")))
    SetItemRewardDisplay(exploreEversong.rewardIcon, exploreEversong.rewardLabel, exploreEversong.rewardButton, EXPLORE_EVERSONG_WOODS_REWARD, "|cff999999Zone reward not added yet.|r")
    exploreEversong.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    exploreEversong.emptyText:SetShown(#EXPLORE_EVERSONG_WOODS_ENTRIES == 0)
    for i, row in ipairs(exploreEversong.rows or {}) do
        local info = EXPLORE_EVERSONG_WOODS_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderExploreVoidstormView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.EXPLORE_VOIDSTORM)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.EXPLORE_VOIDSTORM) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.EXPLORE_VOIDSTORM, "Explore Voidstorm"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    exploreVoidstorm.summary:SetText(string.format(UIText("Track Explore Voidstorm progress. x/y marked.", "Track Explore Voidstorm progress. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #EXPLORE_VOIDSTORM_ENTRIES))
    exploreVoidstorm.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.EXPLORE_VOIDSTORM, "Explore Voidstorm")))
    SetItemRewardDisplay(exploreVoidstorm.rewardIcon, exploreVoidstorm.rewardLabel, exploreVoidstorm.rewardButton, EXPLORE_VOIDSTORM_REWARD, "|cff999999Zone reward not added yet.|r")
    exploreVoidstorm.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    exploreVoidstorm.emptyText:SetShown(#EXPLORE_VOIDSTORM_ENTRIES == 0)
    for i, row in ipairs(exploreVoidstorm.rows or {}) do
        local info = EXPLORE_VOIDSTORM_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderThrillOfTheChaseView()
    local statusText
    if HasAchievement(ACH.THRILL_OF_THE_CHASE) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif select(4, GetAchievementInfo(ACH.THRILL_OF_THE_CHASE)) then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.THRILL_OF_THE_CHASE, "Thrill of the Chase"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    thrillOfTheChase.summary:SetText("Evade the Hungering Presence's grasp in Voidstorm for at least 60 seconds.")
    thrillOfTheChase.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.THRILL_OF_THE_CHASE, "Thrill of the Chase")))
    SetItemRewardDisplay(thrillOfTheChase.rewardIcon, thrillOfTheChase.rewardLabel, thrillOfTheChase.rewardButton, THRILL_OF_THE_CHASE_REWARD, "|cff999999Zone reward not added yet.|r")
    thrillOfTheChase.detailTitle:SetText(UIText("Info", "Info"))
    thrillOfTheChase.emptyText:SetText("|cffb8b8b8This achievement does not need coordinate tracking in LiteVault. Survive the Hungering Presence event in Voidstorm for at least 60 seconds.|r")
    thrillOfTheChase.emptyText:SetShown(true)
    for i, row in ipairs(thrillOfTheChase.rows or {}) do
        row:SetScript("OnClick", nil)
        row:SetScript("OnEnter", nil)
        row:SetScript("OnLeave", nil)
        row.Text:SetText("")
        row:Hide()
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderASingularProblemView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.A_SINGULAR_PROBLEM)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.A_SINGULAR_PROBLEM) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.A_SINGULAR_PROBLEM, UIText("A Singular Problem", "A Singular Problem")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    aSingularProblem.summary:SetText(string.format(UIText("Complete all three waves of the Stormarion Assault. x/y marked.", "Complete all three waves of the Stormarion Assault. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, 3))
    aSingularProblem.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.A_SINGULAR_PROBLEM, "A Singular Problem")))
    SetItemRewardDisplay(aSingularProblem.rewardIcon, aSingularProblem.rewardLabel, aSingularProblem.rewardButton, A_SINGULAR_PROBLEM_REWARD, "|cff999999Zone reward not added yet.|r")
    aSingularProblem.detailTitle:SetText(UIText("Criteria", "Criteria"))
    aSingularProblem.emptyText:SetShown(false)
    aSingularProblem.eventButton:SetScript("OnClick", function()
        SetAchievementTreasureWaypoint(2405, 27.40, 68.00, UIText("Stormarion Assault", "Stormarion Assault"))
    end)
    aSingularProblem.eventButton:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(UIText("Stormarion Assault", "Stormarion Assault"), 1, 0.82, 0)
        GameTooltip:AddLine("27.40, 68.00", 1, 1, 1)
        GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    aSingularProblem.eventButton:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        self.Text:SetTextColor(unpack(t.textPrimary))
        GameTooltip:Hide()
    end)
    aSingularProblem.eventButton:Show()

    local waveNames = {
        "Wave 1 Complete",
        "Wave 2 Complete",
        "Wave 3 Complete",
    }
    for i, row in ipairs(aSingularProblem.rows or {}) do
        local waveName = waveNames[i]
        if waveName then
            local isDone = completedLookup[NormalizeAchievementTreasureName(waveName)] and true or false
            row.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffffcc66", waveName))
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderNoTimeToPawsView()
    local statusText
    if HasAchievement(ACH.NO_TIME_TO_PAWS) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif select(4, GetAchievementInfo(ACH.NO_TIME_TO_PAWS)) then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.NO_TIME_TO_PAWS, UIText("No Time to Paws", "No Time to Paws")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    noTimeToPaws.summary:SetText(UIText("Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit.", "Complete the Harandar world quest 'Claw Enforcement' while having 15 or more stacks of Predator's Pursuit."))
    noTimeToPaws.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.NO_TIME_TO_PAWS, "No Time to Paws")))
    SetItemRewardDisplay(noTimeToPaws.rewardIcon, noTimeToPaws.rewardLabel, noTimeToPaws.rewardButton, nil, "|cff999999Zone reward not added yet.|r")
    noTimeToPaws.detailTitle:SetText(UIText("Info", "Info"))
    noTimeToPaws.emptyText:SetText("|cffb8b8b8" .. UIText("This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit.", "This achievement does not need coordinate tracking in LiteVault. Complete the Harandar world quest 'Claw Enforcement' while holding 15 or more stacks of Predator's Pursuit.") .. "|r")
    noTimeToPaws.emptyText:SetShown(true)
    for i, row in ipairs(noTimeToPaws.rows or {}) do
        row:SetScript("OnClick", nil)
        row:SetScript("OnEnter", nil)
        row:SetScript("OnLeave", nil)
        row.Text:SetText("")
        row:Hide()
    end
end

local function RenderFromTheCradleToTheGraveView()
    local statusText
    if HasAchievement(ACH.FROM_THE_CRADLE_TO_THE_GRAVE) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif select(4, GetAchievementInfo(ACH.FROM_THE_CRADLE_TO_THE_GRAVE)) then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.FROM_THE_CRADLE_TO_THE_GRAVE, UIText("From The Cradle to the Grave", "From The Cradle to the Grave")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    fromTheCradleToTheGrave.summary:SetText(UIText("Attempt to fly to The Cradle high in the sky above Harandar.", "Attempt to fly to The Cradle high in the sky above Harandar."))
    fromTheCradleToTheGrave.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.FROM_THE_CRADLE_TO_THE_GRAVE, "From The Cradle to the Grave")))
    SetItemRewardDisplay(fromTheCradleToTheGrave.rewardIcon, fromTheCradleToTheGrave.rewardLabel, fromTheCradleToTheGrave.rewardButton, nil, "|cff999999Zone reward not added yet.|r")
    fromTheCradleToTheGrave.detailTitle:SetText(UIText("Info", "Info"))
    fromTheCradleToTheGrave.emptyText:SetText("|cffb8b8b8" .. UIText("Fly into The Cradle high in the sky above Harandar to complete this achievement.", "Fly into The Cradle high in the sky above Harandar to complete this achievement.") .. "|r")
    fromTheCradleToTheGrave.emptyText:SetShown(true)
    for i, row in ipairs(fromTheCradleToTheGrave.rows or {}) do
        row:SetScript("OnEnter", nil)
        row:SetScript("OnLeave", nil)
        row.Text:SetText("")
        row:Hide()
    end
end

local function RenderChroniclerOfTheHaranirView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.CHRONICLER_OF_THE_HARANIR)
    local statusText
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.done then
            completedCount = completedCount + 1
        end
    end
    if HasAchievement(ACH.CHRONICLER_OF_THE_HARANIR) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.CHRONICLER_OF_THE_HARANIR, UIText("Chronicler of the Haranir", "Chronicler of the Haranir")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    chroniclerOfTheHaranir.summary:SetText(string.format(UIText("Recover the Haranir journal entries listed below. x/y marked.", "Recover the Haranir journal entries listed below. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #criteriaRows))
    chroniclerOfTheHaranir.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.CHRONICLER_OF_THE_HARANIR, "Chronicler of the Haranir")))
    SetItemRewardDisplay(chroniclerOfTheHaranir.rewardIcon, chroniclerOfTheHaranir.rewardLabel, chroniclerOfTheHaranir.rewardButton, nil, "|cffb8b8b8" .. UIText("Title: \"Chronicler of the Haranir\"", CHRONICLER_OF_THE_HARANIR_REWARD_TEXT) .. "|r")
    chroniclerOfTheHaranir.detailTitle:SetText(UIText("Criteria", "Criteria"))
    chroniclerOfTheHaranir.emptyText:SetShown(#criteriaRows == 0)
    for i, row in ipairs(chroniclerOfTheHaranir.rows or {}) do
        local info = criteriaRows[i]
        if info then
            row.Text:SetText(string.format("%s%s|r", info.done and "|cff00ff00" or "|cffffcc66", info.text))
            row:Show()
        else
            row:Hide()
        end
    end
end

local function RenderLegendsNeverDieView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.LEGENDS_NEVER_DIE)
    local statusText
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.done then
            completedCount = completedCount + 1
        end
    end
    if HasAchievement(ACH.LEGENDS_NEVER_DIE) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.LEGENDS_NEVER_DIE, UIText("Legends Never Die", "Legends Never Die")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    legendsNeverDie.summary:SetText(string.format(UIText("Protect each Haranir legend location listed below. x/y marked.", "Protect each Haranir legend location listed below. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #criteriaRows))
    legendsNeverDie.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.LEGENDS_NEVER_DIE, "Legends Never Die")))
    SetItemRewardDisplay(legendsNeverDie.rewardIcon, legendsNeverDie.rewardLabel, legendsNeverDie.rewardButton, {
        type = LEGENDS_NEVER_DIE_REWARD.type,
        itemID = LEGENDS_NEVER_DIE_REWARD.itemID,
        label = UIText("Housing Decor: On'ohia's Call", LEGENDS_NEVER_DIE_REWARD.label),
    }, "|cff999999Zone reward not added yet.|r")
    legendsNeverDie.detailTitle:SetText(UIText("Criteria", "Criteria"))
    legendsNeverDie.emptyText:SetShown(#criteriaRows == 0)
    for i, row in ipairs(legendsNeverDie.rows or {}) do
        local info = criteriaRows[i]
        if info then
            row.Text:SetText(string.format("%s%s|r", info.done and "|cff00ff00" or "|cffffcc66", info.text))
            row:Show()
        else
            row:Hide()
        end
    end
end

local function RenderDustEmOffView()
    local progressCount = 0
    local progressTotal = 120
    local isGroupPage = (achievementSubView == "dustemoffgroup")
    for _, groupInfo in ipairs(DUST_EM_OFF_GROUPS or {}) do
        for _, info in ipairs(groupInfo.entries or {}) do
            if IsDustMothCollected(info) then
                progressCount = progressCount + 1
            end
        end
    end
    local statusText
    if HasAchievement(ACH.DUST_EM_OFF) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif progressCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.DUST_EM_OFF, UIText("Dust 'Em Off", "Dust 'Em Off")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    dustEmOff.summary:SetText(string.format(UIText("Find all of the Glowing Moths hiding in Harandar. x/y found.", "Find all of the Glowing Moths hiding in Harandar. x/y found."):gsub("x/y", "|cffffff00%d/%d|r"), progressCount, progressTotal))
    dustEmOff.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.DUST_EM_OFF, "Dust 'Em Off")))
    SetItemRewardDisplay(dustEmOff.rewardIcon, dustEmOff.rewardLabel, dustEmOff.rewardButton, nil, "|cffb8b8b8" .. UIText("Title: \"Dustlord\"", DUST_EM_OFF_REWARD_TEXT) .. "|r")
    local selectedGroup = DUST_EM_OFF_GROUPS[dustEmOffSelectedGroup] or DUST_EM_OFF_GROUPS[1]
    if not DUST_EM_OFF_GROUPS[dustEmOffSelectedGroup] then
        dustEmOffSelectedGroup = DUST_EM_OFF_GROUPS[1] and 1 or nil
    end
    dustEmOff.detailTitle:SetText(isGroupPage and (selectedGroup and selectedGroup.name or UIText("Moths", "Moths")) or UIText("Groups", "Groups"))
    dustEmOff.groupBackBtn:SetShown(isGroupPage)
    dustEmOff.groupBackBtn:SetScript("OnClick", function()
        achievementSubView = "dustemoff"
        RefreshAchievementsView()
    end)
    dustEmOff.emptyText:SetShown(isGroupPage and ((not selectedGroup) or (not selectedGroup.entries) or (#selectedGroup.entries == 0)))
    dustEmOff.entriesScroll:SetShown(isGroupPage and selectedGroup and selectedGroup.entries and #selectedGroup.entries > 0)
    dustEmOff.entriesScroll:ClearAllPoints()
    if isGroupPage then
        dustEmOff.entriesScroll:SetPoint("TOPLEFT", 0, -170)
        dustEmOff.entriesScroll:SetPoint("BOTTOMRIGHT", -4, 8)
    else
        dustEmOff.entriesScroll:SetPoint("TOPLEFT", 0, -238)
        dustEmOff.entriesScroll:SetPoint("BOTTOMRIGHT", -4, 8)
    end
    for i, btn in ipairs(dustEmOff.groupButtons or {}) do
        local info = DUST_EM_OFF_GROUPS[i]
        if info then
            local isSelected = (i == dustEmOffSelectedGroup)
            local isComplete = true
            for _, entry in ipairs(info.entries or {}) do
                if not IsDustMothCollected(entry) then
                    isComplete = false
                    break
                end
            end
            local color
            if isSelected then
                color = "|cffffcc66"
            elseif isComplete then
                color = "|cff00ff00"
            else
                color = "|cffff5555"
            end
            btn.Text:SetText(string.format("%s%s|r", color, info.name))
            btn:SetScript("OnClick", function()
                dustEmOffSelectedGroup = i
                achievementSubView = "dustemoffgroup"
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(info.note or UIText("Coordinates pending.", "Coordinates pending."), 0.8, 0.8, 0.8, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            btn:SetShown(not isGroupPage)
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    if isGroupPage and selectedGroup then
        dustEmOff.noteText:SetText(string.format("|cffb8b8b8%s|r", string.format(UIText("%s contains %d moth coordinates. Click a moth to place a waypoint.", "%s contains %d moth coordinates. Click a moth to place a waypoint."), selectedGroup.name, selectedGroup.entries and #selectedGroup.entries or 0)))
    else
        dustEmOff.noteText:SetText("|cffb8b8b8" .. UIText("Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2.", "Moths 1-40 appear at Hara'ti Renown 1, tracking at Renown 2.") .. "\n" .. UIText("Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6.", "Moths 41-80 appear at Hara'ti Renown 4, tracking at Renown 6.") .. "\n" .. UIText("Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11.", "Moths 81-120 appear at Hara'ti Renown 9, tracking at Renown 11.") .. "\n" .. UIText("LiteVault routing assumes you already have Hara'ti Renown 11 unlocked.", "LiteVault routing assumes you already have Hara'ti Renown 11 unlocked.") .. "|r")
    end
    for i, btn in ipairs(dustEmOff.entryButtons or {}) do
        local info = isGroupPage and selectedGroup and selectedGroup.entries and selectedGroup.entries[i]
        if info then
            local isVisited = IsDustMothCollected(info)
            if btn.IndexText then
                btn.IndexText:SetText(tostring(i))
                btn.IndexText:Show()
            end
            btn.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isVisited and "|cff00ff00" or "|cffffcc66", info.x, info.y, info.name))
            btn:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                local visited = IsDustMothCollected(info)
                self.Text:SetText(string.format("%s%.2f, %.2f - %s|r", visited and "|cff00ff00" or "|cffffcc66", info.x, info.y, info.name))
                GameTooltip:Hide()
            end)
            btn:Show()
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            if btn.IndexText then
                btn.IndexText:SetText("")
                btn.IndexText:Hide()
            end
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    local entryCount = isGroupPage and selectedGroup and selectedGroup.entries and #selectedGroup.entries or 0
    local rowsNeeded = math.max(1, math.ceil(entryCount / 4))
    dustEmOff.entriesContent:SetHeight(rowsNeeded * 26)
    dustEmOff.entriesScroll:SetVerticalScroll(0)
end

local function RenderExploreZulamanView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.EXPLORE_ZULAMAN)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.EXPLORE_ZULAMAN) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.EXPLORE_ZULAMAN, "Explore Zul'Aman"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    exploreZulaman.summary:SetText(string.format(UIText("Track Explore Zul'Aman progress. x/y marked.", "Track Explore Zul'Aman progress. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #EXPLORE_ZULAMAN_ENTRIES))
    exploreZulaman.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.EXPLORE_ZULAMAN, "Explore Zul'Aman")))
    SetItemRewardDisplay(exploreZulaman.rewardIcon, exploreZulaman.rewardLabel, exploreZulaman.rewardButton, EXPLORE_ZULAMAN_REWARD, "|cff999999Zone reward not added yet.|r")
    exploreZulaman.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    exploreZulaman.emptyText:SetShown(#EXPLORE_ZULAMAN_ENTRIES == 0)
    for i, row in ipairs(exploreZulaman.rows or {}) do
        local info = EXPLORE_ZULAMAN_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderExploreHarandarView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.EXPLORE_HARANDAR)
    local completedLookup = {}
    local completedCount = 0
    local trackedLookup = {}
    for _, info in ipairs(EXPLORE_HARANDAR_ENTRIES) do
        trackedLookup[NormalizeAchievementTreasureName(info.name)] = true
    end
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName and trackedLookup[normalizedName] then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.EXPLORE_HARANDAR) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.EXPLORE_HARANDAR, "Explore Harandar"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    exploreHarandar.summary:SetText(string.format(UIText("Track Explore Harandar progress. x/y marked.", "Track Explore Harandar progress. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #EXPLORE_HARANDAR_ENTRIES))
    exploreHarandar.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.EXPLORE_HARANDAR, "Explore Harandar")))
    SetItemRewardDisplay(exploreHarandar.rewardIcon, exploreHarandar.rewardLabel, exploreHarandar.rewardButton, EXPLORE_HARANDAR_REWARD, "|cff999999Zone reward not added yet.|r")
    exploreHarandar.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    exploreHarandar.emptyText:SetShown(#EXPLORE_HARANDAR_ENTRIES == 0)
    for i, row in ipairs(exploreHarandar.rows or {}) do
        local info = EXPLORE_HARANDAR_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            end)
            row:Show()
        else
            row:Hide()
        end
    end
end

local function RenderAbundanceProsperousView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.ABUNDANCE_PROSPEROUS_PLENTITUDE)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.ABUNDANCE_PROSPEROUS_PLENTITUDE) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.ABUNDANCE_PROSPEROUS_PLENTITUDE, UIText("Abundance: Prosperous Plentitude!", "Abundance: Prosperous Plentitude!")))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    abundanceProsperous.summary:SetText(string.format(UIText("Complete an Abundant Harvest cave run in each location. x/y marked.", "Complete an Abundant Harvest cave run in each location. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #ABUNDANCE_PROSPEROUS_PLENTITUDE_ENTRIES))
    abundanceProsperous.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.ABUNDANCE_PROSPEROUS_PLENTITUDE, "Abundance: Prosperous Plentitude!")))
    SetItemRewardDisplay(
        abundanceProsperous.rewardIcon,
        abundanceProsperous.rewardLabel,
        abundanceProsperous.rewardButton,
        ABUNDANCE_PROSPEROUS_PLENTITUDE_REWARD or GetAchievementRewardFallback(ACH.ABUNDANCE_PROSPEROUS_PLENTITUDE),
        "|cff999999Zone reward not added yet.|r"
    )
    abundanceProsperous.detailTitle:SetText(UIText("LABEL_DETAILS", "Details"))
    abundanceProsperous.emptyText:SetText("|cffb8b8b8" .. UIText("You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough.", "You need to complete an Abundant Harvest cave run in each location for credit. Just visiting the cave is not enough.") .. "|r")
    abundanceProsperous.emptyText:SetShown(true)
    for i, row in ipairs(abundanceProsperous.rows or {}) do
        local info = ABUNDANCE_PROSPEROUS_PLENTITUDE_ENTRIES[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            row.Text:SetText(string.format("%s%.2f, %.2f - %s|r", isDone and "|cff00ff00" or "|cffff5555", info.x, info.y, info.name))
            row:SetScript("OnClick", function()
                SetAchievementTreasureWaypoint(info.mapID, info.x, info.y, info.name)
            end)
            row:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(string.format("%.2f, %.2f", info.x, info.y), 1, 1, 1)
                GameTooltip:AddLine(UIText("Complete the cave run here for credit.", "Complete the cave run here for credit."), 0.8, 0.8, 0.8)
                GameTooltip:AddLine(UIText("Click to set waypoint.", "Click to set waypoint."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            row:Show()
        else
            row:SetScript("OnClick", nil)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderAltarOfBlessingsView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.ALTAR_OF_BLESSINGS)
    local statusText
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.done then
            completedCount = completedCount + 1
        end
    end
    if HasAchievement(ACH.ALTAR_OF_BLESSINGS) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.ALTAR_OF_BLESSINGS, "Altar of Blessings: Sacred Buffet Devotee"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    altarOfBlessings.summary:SetText(string.format(UIText("Trigger each listed blessing effect. x/y marked.", "Trigger each listed blessing effect. x/y marked."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #criteriaRows))
    altarOfBlessings.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.ALTAR_OF_BLESSINGS, "Altar of Blessings: Sacred Buffet Devotee")))
    SetItemRewardDisplay(altarOfBlessings.rewardIcon, altarOfBlessings.rewardLabel, altarOfBlessings.rewardButton, ALTAR_OF_BLESSINGS_REWARD, "|cff999999Zone reward not added yet.|r")
    altarOfBlessings.detailTitle:SetText(UIText("Criteria", "Criteria"))
    altarOfBlessings.emptyText:SetShown(#criteriaRows == 0)
    for i, row in ipairs(altarOfBlessings.rows or {}) do
        local info = criteriaRows[i]
        if info then
            row.Text:SetText(string.format("%s%s|r", info.done and "|cff00ff00" or "|cffffcc66", info.text))
            row:Show()
        else
            row.Text:SetText("")
            row:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderForeverSongView()
    local completedCount = 0
    for _, info in ipairs(FOREVER_SONG_CHILDREN) do
        if HasAchievement(info.id) then
            completedCount = completedCount + 1
        end
    end
    local statusText
    if HasAchievement(ACH.FOREVER_SONG) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.FOREVER_SONG, "Forever Song"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    foreverSong.summary:SetText(string.format(UIText("Complete the Eversong Woods achievements listed below. x/y done.", "Complete the Eversong Woods achievements listed below. x/y done."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #FOREVER_SONG_CHILDREN))
    foreverSong.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.FOREVER_SONG, "Forever Song")))
    SetItemRewardDisplay(foreverSong.rewardIcon, foreverSong.rewardLabel, foreverSong.rewardButton, FOREVER_SONG_REWARD, "|cff999999Meta reward not added yet.|r")
    foreverSong.detailTitle:SetText(UIText("Criteria", "Criteria"))
    foreverSong.emptyText:SetShown(#FOREVER_SONG_CHILDREN == 0)
    for i, btn in ipairs(foreverSong.childButtons or {}) do
        local info = FOREVER_SONG_CHILDREN[i]
        if info then
            local isDone = HasAchievement(info.id) and true or false
            btn.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffffcc66", info.name))
            btn:SetScript("OnClick", function()
                if info.subView == "treasures" then
                    achievementSubView = "treasures"
                    treasureSelectedAchievementID = info.selectedID
                elseif info.subView == "rares" then
                    achievementSubView = "rares"
                    rares.selectedAchievementID = info.selectedID
                else
                    achievementSubView = info.subView
                end
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                GameTooltip:AddLine(UIText("Click to open this tracker.", "Click to open this tracker."), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            btn:Show()
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderLightUpTheNightView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.LIGHT_UP_THE_NIGHT)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.LIGHT_UP_THE_NIGHT) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.LIGHT_UP_THE_NIGHT, "Light Up the Night"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    lightUpTheNight.summary:SetText(string.format(UIText("Rally your forces against Xal'atath by completing the achievements below. x/y done.", "Rally your forces against Xal'atath by completing the achievements below. x/y done."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #LIGHT_UP_THE_NIGHT_CHILDREN))
    lightUpTheNight.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.LIGHT_UP_THE_NIGHT, "Light Up the Night")))
    SetItemRewardDisplay(lightUpTheNight.rewardIcon, lightUpTheNight.rewardLabel, lightUpTheNight.rewardButton, {
        type = LIGHT_UP_THE_NIGHT_REWARD.type,
        itemID = LIGHT_UP_THE_NIGHT_REWARD.itemID,
        label = UIText("Mount: Brilliant Petalwing", LIGHT_UP_THE_NIGHT_REWARD.label),
    }, "|cff999999Meta reward not added yet.|r")
    lightUpTheNight.detailTitle:SetText(UIText("Criteria", "Criteria"))
    lightUpTheNight.emptyText:SetShown(#LIGHT_UP_THE_NIGHT_CHILDREN == 0)
    for i, btn in ipairs(lightUpTheNight.childButtons or {}) do
        local info = LIGHT_UP_THE_NIGHT_CHILDREN[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            btn.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffffcc66", info.name))
            btn:SetScript("OnClick", function()
                if info.subView == "treasures" then
                    achievementSubView = "treasures"
                    treasureSelectedAchievementID = info.selectedID
                elseif info.subView == "rares" then
                    achievementSubView = "rares"
                    rares.selectedAchievementID = info.selectedID
                elseif info.subView then
                    achievementSubView = info.subView
                end
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                if info.subView then
                    GameTooltip:AddLine(UIText("Click to open this tracker.", "Click to open this tracker."), 0.8, 0.8, 0.8)
                else
                    GameTooltip:AddLine(UIText("Tracker not added yet.", "Tracker not added yet."), 0.8, 0.8, 0.8)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            btn:Show()
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderYellingIntoTheVoidstormView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.YELLING_INTO_THE_VOIDSTORM)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.YELLING_INTO_THE_VOIDSTORM) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.YELLING_INTO_THE_VOIDSTORM, "Yelling into the Voidstorm"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    yellingIntoVoidstorm.summary:SetText(string.format(UIText("Complete all of the Voidstorm achievements listed below. x/y done.", "Complete all of the Voidstorm achievements listed below. x/y done."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #YELLING_INTO_THE_VOIDSTORM_CHILDREN))
    yellingIntoVoidstorm.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.YELLING_INTO_THE_VOIDSTORM, "Yelling into the Voidstorm")))
    SetItemRewardDisplay(yellingIntoVoidstorm.rewardIcon, yellingIntoVoidstorm.rewardLabel, yellingIntoVoidstorm.rewardButton, YELLING_INTO_THE_VOIDSTORM_REWARD, "|cff999999Meta reward not added yet.|r")
    yellingIntoVoidstorm.detailTitle:SetText(UIText("Criteria", "Criteria"))
    yellingIntoVoidstorm.emptyText:SetShown(#YELLING_INTO_THE_VOIDSTORM_CHILDREN == 0)
    for i, btn in ipairs(yellingIntoVoidstorm.childButtons or {}) do
        local info = YELLING_INTO_THE_VOIDSTORM_CHILDREN[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            btn.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffffcc66", info.name))
            btn:SetScript("OnClick", function()
                if info.subView == "treasures" then
                    achievementSubView = "treasures"
                    treasureSelectedAchievementID = info.selectedID
                elseif info.subView == "rares" then
                    achievementSubView = "rares"
                    rares.selectedAchievementID = info.selectedID
                elseif info.subView then
                    achievementSubView = info.subView
                end
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                if info.subView then
                    GameTooltip:AddLine(UIText("Click to open this tracker.", "Click to open this tracker."), 0.8, 0.8, 0.8)
                else
                    GameTooltip:AddLine(UIText("Tracker not added yet.", "Tracker not added yet."), 0.8, 0.8, 0.8)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            btn:Show()
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderMakingAnAmaniOutOfYouView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.MAKING_AN_AMANI_OUT_OF_YOU)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.MAKING_AN_AMANI_OUT_OF_YOU) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(ACH.MAKING_AN_AMANI_OUT_OF_YOU, "Making an Amani Out of You"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    makingAnAmaniOutOfYou.summary:SetText(string.format(UIText("Complete all of the Zul'Aman achievements listed below. x/y done.", "Complete all of the Zul'Aman achievements listed below. x/y done."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #MAKING_AN_AMANI_OUT_OF_YOU_CHILDREN))
    makingAnAmaniOutOfYou.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.MAKING_AN_AMANI_OUT_OF_YOU, "Making an Amani Out of You")))
    SetItemRewardDisplay(makingAnAmaniOutOfYou.rewardIcon, makingAnAmaniOutOfYou.rewardLabel, makingAnAmaniOutOfYou.rewardButton, MAKING_AN_AMANI_OUT_OF_YOU_REWARD, "|cff999999Meta reward not added yet.|r")
    makingAnAmaniOutOfYou.detailTitle:SetText(UIText("Criteria", "Criteria"))
    makingAnAmaniOutOfYou.emptyText:SetShown(#MAKING_AN_AMANI_OUT_OF_YOU_CHILDREN == 0)
    for i, btn in ipairs(makingAnAmaniOutOfYou.childButtons or {}) do
        local info = MAKING_AN_AMANI_OUT_OF_YOU_CHILDREN[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            btn.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffffcc66", info.name))
            btn:SetScript("OnClick", function()
                if info.subView == "treasures" then
                    achievementSubView = "treasures"
                    treasureSelectedAchievementID = info.selectedID
                elseif info.subView == "rares" then
                    achievementSubView = "rares"
                    rares.selectedAchievementID = info.selectedID
                elseif info.subView then
                    achievementSubView = info.subView
                end
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                if info.subView then
                    GameTooltip:AddLine(UIText("Click to open this tracker.", "Click to open this tracker."), 0.8, 0.8, 0.8)
                else
                    GameTooltip:AddLine(UIText("Tracker not added yet.", "Tracker not added yet."), 0.8, 0.8, 0.8)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            btn:Show()
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

local function RenderThatsAlnFolksView()
    local criteriaRows = GetAchievementCriteriaRows(ACH.THATS_ALN_FOLKS)
    local completedLookup = {}
    local completedCount = 0
    for _, rowInfo in ipairs(criteriaRows) do
        if rowInfo and rowInfo.text then
            local normalizedName = NormalizeAchievementTreasureName(rowInfo.text)
            if normalizedName then
                local isDone = rowInfo.done and true or false
                completedLookup[normalizedName] = isDone
                if isDone then
                    completedCount = completedCount + 1
                end
            end
        end
    end
    local statusText
    if HasAchievement(ACH.THATS_ALN_FOLKS) then
        statusText = UIText("STATUS_DONE", "Done")
    elseif completedCount > 0 then
        statusText = UIText("STATUS_IN_PROGRESS", "In Progress")
    else
        statusText = UIText("STATUS_NOT_STARTED", "Not Started")
    end
    achievementsTitle:SetText(GetAchievementName(62260, "That's Aln, Folks!"))
    achievementsSubtitle:SetText(string.format("%s: |cffffff00%s|r", UIText("LABEL_STATUS", "Status"), statusText))
    thatsAlnFolks.summary:SetText(string.format(UIText("Aid the Hara'ti by completing the achievements below. x/y done.", "Aid the Hara'ti by completing the achievements below. x/y done."):gsub("x/y", "|cffffff00%d/%d|r"), completedCount, #THATS_ALN_FOLKS_CHILDREN))
    thatsAlnFolks.criteriaTitle:SetText(string.format("%s: %s", UIText("LABEL_REWARD", "Reward"), GetAchievementName(ACH.THATS_ALN_FOLKS, "That's Aln, Folks!")))
    SetItemRewardDisplay(thatsAlnFolks.rewardIcon, thatsAlnFolks.rewardLabel, thatsAlnFolks.rewardButton, THATS_ALN_FOLKS_REWARD, "|cff999999Meta reward not added yet.|r")
    thatsAlnFolks.detailTitle:SetText(UIText("Criteria", "Criteria"))
    thatsAlnFolks.emptyText:SetShown(#THATS_ALN_FOLKS_CHILDREN == 0)
    for i, btn in ipairs(thatsAlnFolks.childButtons or {}) do
        local info = THATS_ALN_FOLKS_CHILDREN[i]
        if info then
            local isDone = completedLookup[NormalizeAchievementTreasureName(info.name)] and true or false
            btn.Text:SetText(string.format("%s%s|r", isDone and "|cff00ff00" or "|cffffcc66", info.name))
            btn:SetScript("OnClick", function()
                if info.subView == "treasures" then
                    achievementSubView = "treasures"
                    treasureSelectedAchievementID = info.selectedID
                elseif info.subView == "rares" then
                    achievementSubView = "rares"
                    rares.selectedAchievementID = info.selectedID
                elseif info.subView then
                    achievementSubView = info.subView
                end
                RefreshAchievementsView()
            end)
            btn:SetScript("OnEnter", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
                self.Text:SetTextColor(unpack(t.textPrimary))
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(info.name, 1, 0.82, 0)
                if info.subView then
                    GameTooltip:AddLine(UIText("Click to open this tracker.", "Click to open this tracker."), 0.8, 0.8, 0.8)
                else
                    GameTooltip:AddLine(UIText("Tracker not added yet.", "Tracker not added yet."), 0.8, 0.8, 0.8)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderPrimary))
                self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                GameTooltip:Hide()
            end)
            btn:Show()
        else
            btn:SetScript("OnClick", nil)
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
            btn.Text:SetText("")
            btn:Hide()
        end
    end
    achievementsEmpty:Hide()
    for _, panel in ipairs(achievementPanels) do
        panel:Hide()
    end
end

RefreshAchievementsView = function()
    if not AchievementView:IsShown() then return end
    ApplyAchievementsTheme(lv.GetTheme and lv.GetTheme() or nil)

    local onGlyphs = (achievementSubView == "glyphs")
    local onDelver = (achievementSubView == "delver")
    local onTreasures = (achievementSubView == "treasures")
    local onPeaks = (achievementSubView == "peaks")
    local onRares = (achievementSubView == "rares")
    local onEverPainting = (achievementSubView == "everpainting")
    local onRunestoneRush = (achievementSubView == "runestonerush")
    local onPartyMustGoOn = (achievementSubView == "partymustgoon")
    local onExploreEversong = (achievementSubView == "exploreeversong")
    local onExploreVoidstorm = (achievementSubView == "explorevoidstorm")
    local onThrillOfTheChase = (achievementSubView == "thrillofthechase")
    local onNoTimeToPaws = (achievementSubView == "notimetopaws")
    local onFromTheCradleToTheGrave = (achievementSubView == "fromthecradletothegrave")
    local onChroniclerOfTheHaranir = (achievementSubView == "chronicleroftheharanir")
    local onLegendsNeverDie = (achievementSubView == "legendsneverdie")
    local onDustEmOff = (achievementSubView == "dustemoff")
    local onDustEmOffGroup = (achievementSubView == "dustemoffgroup")
    local onASingularProblem = (achievementSubView == "asingularproblem")
    local onExploreZulaman = (achievementSubView == "explorezulaman")
    local onExploreHarandar = (achievementSubView == "exploreharandar")
    local onAbundanceProsperous = (achievementSubView == "abundanceprosperous")
    local onAltarOfBlessings = (achievementSubView == "altarofblessings")
    local onForeverSong = (achievementSubView == "foreversong")
    local onLightUpTheNight = (achievementSubView == "lightupthenight")
    local onThatsAlnFolks = (achievementSubView == "thatsalnfolks")
    local onYellingIntoVoidstorm = (achievementSubView == "yellingintovoidstorm")
    local onMakingAnAmani = (achievementSubView == "makinganamani")
    local onHome = not (onGlyphs or onDelver or onTreasures or onPeaks or onRares or onEverPainting or onRunestoneRush or onPartyMustGoOn or onExploreEversong or onExploreVoidstorm or onThrillOfTheChase or onNoTimeToPaws or onFromTheCradleToTheGrave or onChroniclerOfTheHaranir or onLegendsNeverDie or onDustEmOff or onDustEmOffGroup or onASingularProblem or onExploreZulaman or onExploreHarandar or onAbundanceProsperous or onAltarOfBlessings or onForeverSong or onLightUpTheNight or onThatsAlnFolks or onYellingIntoVoidstorm or onMakingAnAmani)
    glyphHunterBackBtn.Text:SetText(UIText("Back", "Back"))
    achievementHome:SetShown(onHome)
    glyphHunterBackBtn:SetShown(not onHome)
    achievementsScroll:SetShown(onGlyphs)
    treasureView:SetShown(onTreasures)
    delverView:SetShown(onDelver)
    peaksView:SetShown(onPeaks)
    rares.view:SetShown(onRares)
    everPainting.view:SetShown(onEverPainting)
    runestoneRush.view:SetShown(onRunestoneRush)
    partyMustGoOn.view:SetShown(onPartyMustGoOn)
    exploreEversong.view:SetShown(onExploreEversong)
    exploreVoidstorm.view:SetShown(onExploreVoidstorm)
    thrillOfTheChase.view:SetShown(onThrillOfTheChase)
    noTimeToPaws.view:SetShown(onNoTimeToPaws)
    fromTheCradleToTheGrave.view:SetShown(onFromTheCradleToTheGrave)
    chroniclerOfTheHaranir.view:SetShown(onChroniclerOfTheHaranir)
    legendsNeverDie.view:SetShown(onLegendsNeverDie)
    dustEmOff.view:SetShown(onDustEmOff or onDustEmOffGroup)
    aSingularProblem.view:SetShown(onASingularProblem)
    exploreZulaman.view:SetShown(onExploreZulaman)
    exploreHarandar.view:SetShown(onExploreHarandar)
    abundanceProsperous.view:SetShown(onAbundanceProsperous)
    altarOfBlessings.view:SetShown(onAltarOfBlessings)
    foreverSong.view:SetShown(onForeverSong)
    lightUpTheNight.view:SetShown(onLightUpTheNight)
    thatsAlnFolks.view:SetShown(onThatsAlnFolks)
    yellingIntoVoidstorm.view:SetShown(onYellingIntoVoidstorm)
    makingAnAmaniOutOfYou.view:SetShown(onMakingAnAmani)

    if onHome then
        RenderAchievementsHome()
        return
    end
    if onTreasures then
        RenderTreasureAchievementsView()
        return
    end
    if onDelver then
        RenderDelverAchievementsView()
        return
    end
    if onPeaks then
        RenderPeaksAchievementsView()
        return
    end
    if onRares then
        RenderRaresAchievementsView()
        return
    end
    if onEverPainting then
        RenderEverPaintingView()
        return
    end
    if onRunestoneRush then
        RenderRunestoneRushView()
        return
    end
    if onPartyMustGoOn then
        RenderPartyMustGoOnView()
        return
    end
    if onExploreEversong then
        RenderExploreEversongView()
        return
    end
    if onExploreVoidstorm then
        RenderExploreVoidstormView()
        return
    end
    if onThrillOfTheChase then
        RenderThrillOfTheChaseView()
        return
    end
    if onNoTimeToPaws then
        RenderNoTimeToPawsView()
        return
    end
    if onFromTheCradleToTheGrave then
        RenderFromTheCradleToTheGraveView()
        return
    end
    if onChroniclerOfTheHaranir then
        RenderChroniclerOfTheHaranirView()
        return
    end
    if onLegendsNeverDie then
        RenderLegendsNeverDieView()
        return
    end
    if onDustEmOff or onDustEmOffGroup then
        RenderDustEmOffView()
        return
    end
    if onASingularProblem then
        RenderASingularProblemView()
        return
    end
    if onExploreZulaman then
        RenderExploreZulamanView()
        return
    end
    if onExploreHarandar then
        RenderExploreHarandarView()
        return
    end
    if onAbundanceProsperous then
        RenderAbundanceProsperousView()
        return
    end
    if onAltarOfBlessings then
        RenderAltarOfBlessingsView()
        return
    end
    if onForeverSong then
        RenderForeverSongView()
        return
    end
    if onLightUpTheNight then
        RenderLightUpTheNightView()
        return
    end
    if onThatsAlnFolks then
        RenderThatsAlnFolksView()
        return
    end
    if onYellingIntoVoidstorm then
        RenderYellingIntoTheVoidstormView()
        return
    end
    if onMakingAnAmani then
        RenderMakingAnAmaniOutOfYouView()
        return
    end
    RenderGlyphHunterAchievementsView()
end
lv.RefreshAchievementsView = RefreshAchievementsView

function lv.SetMainView(view)
    currentMainView = ((view == "achievements") or (view == "instances") or (view == "options") or (view == "factions")) and view or "dashboard"
    if env.setCurrentMainView then
        env.setCurrentMainView(currentMainView)
    end
    if lv.LVVaultWindow then
        lv.LVVaultWindow:Hide()
    end
    if currentMainView == "achievements" then
        achievementSubView = "home"
        if lv.CloseAuxPanels then lv.CloseAuxPanels(nil) end
        SetDashboardContentVisible(false)
        SetFactionCardsVisible(false)
        AchievementView:Show()
        if lv.OptionsPanel then lv.OptionsPanel:Hide() end
        if _G["LiteVaultInstancePanel"] then _G["LiteVaultInstancePanel"]:Hide() end
        local factionWeeklyWindow = GetFactionWeeklyWindow()
        if factionWeeklyWindow then factionWeeklyWindow:Hide() end
        ApplyAchievementsTheme(lv.GetTheme and lv.GetTheme() or nil)
        RefreshAchievementsView()
    elseif currentMainView == "factions" then
        AchievementView:Hide()
        if lv.OptionsPanel then lv.OptionsPanel:Hide() end
        if _G["LiteVaultInstancePanel"] then _G["LiteVaultInstancePanel"]:Hide() end
        SetDashboardContentVisible(false)
        local factionWeeklyWindow = GetFactionWeeklyWindow()
        if factionWeeklyWindow then
            factionWeeklyWindow:Show()
            if lv.UpdateFactionWeeklyWindow then
                lv.UpdateFactionWeeklyWindow()
            end
        end
        SetFactionCardsVisible(true)
    elseif currentMainView == "options" then
        AchievementView:Hide()
        if _G["LiteVaultInstancePanel"] then _G["LiteVaultInstancePanel"]:Hide() end
        local factionWeeklyWindow = GetFactionWeeklyWindow()
        if factionWeeklyWindow then factionWeeklyWindow:Hide() end
        SetDashboardContentVisible(false)
        SetFactionCardsVisible(false)
        if lv.OptionsPanel then
            if LiteVaultDB then
                if lv.disableTimePlayedCB then
                    lv.disableTimePlayedCB:SetChecked(LiteVaultDB.disableTimePlayed or false)
                end
                local use24 = false
                if GetCVarBool then
                    use24 = GetCVarBool("timeMgrUseMilitaryTime")
                else
                    use24 = (LiteVaultDB.use24HourClock ~= false)
                end
                if lv.timeFormatCB then
                    lv.timeFormatCB:SetChecked(use24 and true or false)
                end
                if lv.disableBagViewCB then
                    lv.disableBagViewCB:SetChecked(LiteVaultDB.disableBagViewing or false)
                end
                if lv.disableOverlayCB then
                    lv.disableOverlayCB:SetChecked(LiteVaultDB.disableCharacterOverlay or false)
                end
            end
            if lv.darkModeCB then
                lv.darkModeCB:SetChecked(lv.currentTheme == "dark")
            end
            if lv.UpdateLangButtons then
                lv.UpdateLangButtons()
            end
            lv.OptionsPanel:Show()
            if lv.UpdateOptionsPanelLayout then
                lv.UpdateOptionsPanelLayout()
            end
        end
    elseif currentMainView == "instances" then
        AchievementView:Hide()
        if lv.OptionsPanel then lv.OptionsPanel:Hide() end
        local factionWeeklyWindow = GetFactionWeeklyWindow()
        if factionWeeklyWindow then factionWeeklyWindow:Hide() end
        if lv.CloseAuxPanels then lv.CloseAuxPanels("instances") end
        SetDashboardContentVisible(false)
        SetFactionCardsVisible(false)
        if lv.ShowInstancePanel then
            lv.ShowInstancePanel()
        end
    else
        AchievementView:Hide()
        if lv.OptionsPanel then lv.OptionsPanel:Hide() end
        if _G["LiteVaultInstancePanel"] then _G["LiteVaultInstancePanel"]:Hide() end
        local factionWeeklyWindow = GetFactionWeeklyWindow()
        if factionWeeklyWindow then factionWeeklyWindow:Hide() end
        SetDashboardContentVisible(true)
        SetFactionCardsVisible(false)
    end
    RefreshAchievementsButton()
end

home.glyphHunterLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "glyphs"
    RefreshAchievementsView()
end)

home.treasureLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "treasures"
    treasureSelectedAchievementID = TREASURES_OF_MIDNIGHT[1] and TREASURES_OF_MIDNIGHT[1].id or nil
    RefreshAchievementsView()
end)

home.delverLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "delver"
    RefreshAchievementsView()
end)

home.peaksLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "peaks"
    peaksSelectedAchievementID = MIDNIGHT_HIGHEST_PEAKS_CRITERIA[1] and MIDNIGHT_HIGHEST_PEAKS_CRITERIA[1].id or nil
    RefreshAchievementsView()
end)

home.raresLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "rares"
    rares.selectedAchievementID = MIDNIGHT_RARES_OF_MIDNIGHT[1] and MIDNIGHT_RARES_OF_MIDNIGHT[1].id or nil
    RefreshAchievementsView()
end)

home.everPaintingLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "everpainting"
    RefreshAchievementsView()
end)

home.runestoneRushLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "runestonerush"
    RefreshAchievementsView()
end)

home.partyMustGoOnLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "partymustgoon"
    RefreshAchievementsView()
end)

home.exploreEversongLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "exploreeversong"
    RefreshAchievementsView()
end)

home.foreverSongLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "foreversong"
    RefreshAchievementsView()
end)

home.lightUpTheNightLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "lightupthenight"
    RefreshAchievementsView()
end)

home.yellingIntoVoidstormLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "yellingintovoidstorm"
    RefreshAchievementsView()
end)

home.makingAnAmaniLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "makinganamani"
    RefreshAchievementsView()
end)

home.thatsAlnFolksLaunchBtn:SetScript("OnClick", function()
    achievementSubView = "thatsalnfolks"
    RefreshAchievementsView()
end)

glyphHunterBackBtn:SetScript("OnClick", function()
    achievementSubView = "home"
    RefreshAchievementsView()
end)

function lv.GetMainView()
    return currentMainView
end

LVWindow:HookScript("OnShow", function()
    if lv.SetMainView then
        lv.SetMainView(currentMainView)
    end
end)

dashboardTab:SetScript("OnClick", function()
    lv.SetMainView("dashboard")
end)

achievementsBtn:SetScript("OnClick", function()
    lv.SetMainView("achievements")
end)

instancesTab:SetScript("OnClick", function()
    lv.SetMainView("instances")
end)

optionsTab:SetScript("OnClick", function()
    lv.SetMainView("options")
end)

factionsTab:SetScript("OnClick", function()
    lv.SetMainView("factions")
end)

local achievementEventFrame = CreateFrame("Frame")
achievementEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
achievementEventFrame:RegisterEvent("CRITERIA_UPDATE")
achievementEventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
achievementEventFrame:SetScript("OnEvent", function()
    if AchievementView:IsShown() then
        RefreshAchievementsView()
    end
end)

end





