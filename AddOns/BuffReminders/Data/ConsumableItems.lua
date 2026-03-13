local _, BR = ...

-- Lookup tables of known consumable item IDs, keyed by consumable type.
-- Values: `true` for simple membership, or a number for priority sorting (lower = higher priority).
-- Food items may use a table with `label` (stat abbreviation) and `hearty` (boolean) fields.
BR.CONSUMABLE_ITEMS = {
    food = {
        -- TWW 11.0.0
        [222702] = { label = "低次屬性" }, -- Skewered Fillet
        [222703] = { label = "低次屬性" }, -- Simple Stew
        [222704] = { label = "低次屬性" }, -- Unseasoned Field Steak
        [222705] = { label = "低次屬性" }, -- Roasted Mycobloom
        [222706] = { label = "低次屬性" }, -- Pan-Seared Mycobloom
        [222707] = { label = "低次屬性" }, -- Hallowfall Chili
        [222708] = { label = "低次屬性" }, -- Coreway Kabob
        [222709] = { label = "低次屬性" }, -- Flashfire Fillet
        [222710] = { label = "耐/力" }, -- Meat and Potatoes
        [222711] = { label = "耐/敏" }, -- Rib Stickers
        [222712] = { label = "耐/智" }, -- Sweet and Sour Meatballs
        [222713] = { label = "耐力" }, -- Tender Twilight Jerky
        [222714] = { label = "加速" }, -- Zesty Nibblers
        [222715] = { label = "致命" }, -- Fiery Fish Sticks
        [222716] = { label = "臨機" }, -- Ginger-Glazed Fillet
        [222717] = { label = "精通" }, -- Salty Dog
        [222718] = { label = "加速/致命" }, -- Deepfin Patty
        [222719] = { label = "加速/臨機" }, -- Sweet and Spicy Soup
        [222720] = { label = "高次屬性" }, -- The Sushi Special
        [222721] = { label = "致命/臨機" }, -- Fish and Chips
        [222722] = { label = "精通/致命" }, -- Salt Baked Seafood
        [222723] = { label = "精通/臨機" }, -- Marinated Tenderloins
        [222724] = { label = "耐/力" }, -- Sizzling Honey Roast
        [222725] = { label = "耐/敏" }, -- Mycobloom Risotto
        [222726] = { label = "耐/智" }, -- Stuffed Cave Peppers
        [222727] = { label = "耐力" }, -- Angler's Delight
        [222728] = { label = "高次屬性" }, -- Beledar's Bounty
        [222729] = { label = "高次屬性" }, -- Empress' Farewell
        [222730] = { label = "高次屬性" }, -- Jester's Board
        [222731] = { label = "高次屬性" }, -- Outsider's Provisions
        [222732] = { label = "大餐" }, -- 大餐 of the Divine Day
        [222733] = { label = "大餐" }, -- 大餐 of the Midnight Masquerade
        [222735] = { label = "低次屬性" }, -- Everything Stew
        [222736] = { label = "精通/加速" }, -- Chippy Tea
        [222750] = { label = "低次屬性", hearty = true }, -- Hearty Skewered Fillet
        [222751] = { label = "低次屬性", hearty = true }, -- Hearty Simple Stew
        [222752] = { label = "低次屬性", hearty = true }, -- Hearty Unseasoned Field Steak
        [222753] = { label = "低次屬性", hearty = true }, -- Hearty Roasted Mycobloom
        [222754] = { label = "低次屬性", hearty = true }, -- Hearty Pan-Seared Mycobloom
        [222755] = { label = "低次屬性", hearty = true }, -- Hearty Hallowfall Chili
        [222756] = { label = "低次屬性", hearty = true }, -- Hearty Coreway Kabob
        [222757] = { label = "低次屬性", hearty = true }, -- Hearty Flashfire Fillet
        [222758] = { label = "耐/力", hearty = true }, -- Hearty Meat and Potatoes
        [222759] = { label = "耐/敏", hearty = true }, -- Hearty Rib Stickers
        [222760] = { label = "耐/智", hearty = true }, -- Hearty Sweet and Sour Meatballs
        [222761] = { label = "耐力", hearty = true }, -- Hearty Tender Twilight Jerky
        [222762] = { label = "加速", hearty = true }, -- Hearty Zesty Nibblers
        [222763] = { label = "致命", hearty = true }, -- Hearty Fiery Fish Sticks
        [222764] = { label = "臨機", hearty = true }, -- Hearty Ginger-Glazed Fillet
        [222765] = { label = "精通", hearty = true }, -- Hearty Salty Dog
        [222766] = { label = "加速/致命", hearty = true }, -- Hearty Deepfin Patty
        [222767] = { label = "加速/臨機", hearty = true }, -- Hearty Sweet and Spicy Soup
        [222768] = { label = "高次屬性", hearty = true }, -- Hearty Sushi Special
        [222769] = { label = "致命/臨機", hearty = true }, -- Hearty Fish and Chips
        [222770] = { label = "精通/致命", hearty = true }, -- Hearty Salt Baked Seafood
        [222771] = { label = "精通/臨機", hearty = true }, -- Hearty Marinated Tenderloins
        [222772] = { label = "耐/力", hearty = true }, -- Hearty Sizzling Honey Roast
        [222773] = { label = "耐/敏", hearty = true }, -- Hearty Mycobloom Risotto
        [222774] = { label = "耐/智", hearty = true }, -- Hearty Stuffed Cave Peppers
        [222775] = { label = "耐力", hearty = true }, -- Hearty Angler's Delight
        [222776] = { label = "高次屬性", hearty = true }, -- Hearty Beledar's Bounty
        [222777] = { label = "高次屬性", hearty = true }, -- Hearty Empress' Farewell
        [222778] = { label = "高次屬性", hearty = true }, -- Hearty Jester's Board
        [222779] = { label = "高次屬性", hearty = true }, -- Hearty Outsider's Provisions
        [222780] = { label = "大餐", hearty = true }, -- Hearty 大餐 of the Divine Day
        [222781] = { label = "大餐", hearty = true }, -- Hearty 大餐 of the Midnight Masquerade
        [222783] = { label = "低次屬性", hearty = true }, -- Hearty Everything Stew
        [222784] = { label = "精通/加速", hearty = true }, -- Hearty Chippy Tea
        [223966] = { label = "隨機" }, -- Everything-on-a-Stick (random Khaz Algar meal)
        [223967] = { label = "低次屬性" }, -- Protein Slurp
        [223968] = { label = "低次屬性" }, -- Spongey Scramble
        [225592] = { label = "速度" }, -- Exquisitely Eviscerated Muscle

        -- TWW 11.1.0
        [235805] = { label = "高次屬性" }, -- Authentic Undermine Clam Chowder
        [235853] = { label = "高次屬性", hearty = true }, -- Hearty Authentic Undermine Clam Chowder

        -- Midnight 12.0.0
        [242272] = { label = "高次屬性" }, -- Quel'dorei Medley
        [242273] = { label = "高次屬性" }, -- Blooming 大餐
        [242274] = { label = "高次屬性" }, -- Champion's Bento
        [242275] = { label = "高主屬性" }, -- Royal Roast
        [242276] = { label = "臨機" }, -- Braised Blood Hunter
        [242277] = { label = "加速" }, -- Crimson Calamari
        [242278] = { label = "致命" }, -- Tasty Smoked Tetra
        [242279] = { label = "中主屬性" }, -- Baked Lucky Loa
        [242280] = { label = "臨機" }, -- Buttered Root Crab
        [242281] = { label = "精通" }, -- Glitter Skewers
        [242282] = { label = "加速" }, -- Null and Void Plate
        [242283] = { label = "致命" }, -- Sun-Seared Lumifin
        [242284] = { label = "臨機" }, -- Void-Kissed Fish Rolls
        [242285] = { label = "精通" }, -- Warped Wise Wings
        [242286] = { label = "加速" }, -- Fel-Kissed Filet
        [242287] = { label = "致命" }, -- Arcano Cutlets
        [242288] = { label = "中主屬性" }, -- Twilight Angler's Medley
        [242289] = { label = "中主屬性" }, -- Spellfire Filet
        [242290] = { label = "致命/臨機" }, -- Wise Tails
        [242291] = { label = "精通/臨機" }, -- Fried Bloomtail
        [242292] = { label = "精通/致命" }, -- Eversong Pudding
        [242293] = { label = "加速/臨機" }, -- Sunwell Delight
        [242294] = { label = "臨機" }, -- Felberry Figs
        [242295] = { label = "加速/致命" }, -- Hearthflame Supper
        [242296] = { label = "精通/加速" }, -- Bloodthistle-wrapped Cutlets
        [242302] = { label = "低主屬性" }, -- Bloom Skewers
        [242303] = { label = "低主屬性" }, -- Mana-Infused Stew
        [242304] = { label = "致命/臨機" }, -- Spiced Biscuits
        [242305] = { label = "精通/臨機" }, -- Silvermoon Standard
        [242306] = { label = "精通/致命" }, -- Forager's Medley
        [242307] = { label = "加速/臨機" }, -- Quick Sandwich
        [242308] = { label = "加速/致命" }, -- Portable Snack
        [242309] = { label = "精通/加速" }, -- Farstrider Rations
        [242532] = { label = "低主屬性" }, -- [PH] Vegetarian Recipe
        [242744] = { label = "高次屬性", hearty = true }, -- Hearty Quel'dorei Medley
        [242745] = { label = "高次屬性", hearty = true }, -- Hearty Blooming 大餐
        [242746] = { label = "高次屬性", hearty = true }, -- Hearty Champion's Bento
        [242747] = { label = "高主屬性", hearty = true }, -- Hearty Royal Roast
        [242748] = { label = "臨機", hearty = true }, -- Hearty Braised Blood Hunter
        [242749] = { label = "加速", hearty = true }, -- Hearty Crimson Calamari
        [242750] = { label = "致命", hearty = true }, -- Hearty Tasty Smoked Tetra
        [242751] = { label = "中主屬性", hearty = true }, -- Hearty Rootland Surprise
        [242752] = { label = "臨機", hearty = true }, -- Hearty Buttered Root Crab
        [242753] = { label = "精通", hearty = true }, -- Hearty Glitter Skewers
        [242754] = { label = "加速", hearty = true }, -- Hearty Null and Void Plate
        [242755] = { label = "致命", hearty = true }, -- Hearty Sun-Seared Lumifin
        [242756] = { label = "臨機", hearty = true }, -- Hearty Void-Kissed Fish Rolls
        [242757] = { label = "精通", hearty = true }, -- Hearty Warped Wise Wings
        [242758] = { label = "加速", hearty = true }, -- Hearty Fel-Kissed Filet
        [242759] = { label = "致命", hearty = true }, -- Hearty Arcano Cutlets
        [242760] = { label = "中主屬性", hearty = true }, -- Hearty Twilight Angler's Medley
        [242761] = { label = "中主屬性", hearty = true }, -- Hearty Spellfire Filet
        [242762] = { label = "致命/臨機", hearty = true }, -- Hearty Wise Tails
        [242763] = { label = "精通/臨機", hearty = true }, -- Hearty Fried Bloomtail
        [242764] = { label = "精通/致命", hearty = true }, -- Hearty Eversong Pudding
        [242765] = { label = "加速/臨機", hearty = true }, -- Hearty Sunwell Delight
        [242766] = { label = "臨機", hearty = true }, -- Hearty Felberry Figs
        [242767] = { label = "加速/致命", hearty = true }, -- Hearty Hearthflame Supper
        [242768] = { label = "精通/加速", hearty = true }, -- Hearty Bloodthistle-Wrapped Cutlets
        [242769] = { label = "低主屬性", hearty = true }, -- Hearty Bloom Skewers
        [242770] = { label = "低主屬性", hearty = true }, -- Hearty Mana-Infused Stew
        [242771] = { label = "致命/臨機", hearty = true }, -- Hearty Spiced Biscuits
        [242772] = { label = "精通/臨機", hearty = true }, -- Hearty Silvermoon Standard
        [242773] = { label = "精通/致命", hearty = true }, -- Hearty Forager's Medley
        [242774] = { label = "加速/臨機", hearty = true }, -- Hearty Quick Sandwich
        [242775] = { label = "加速/致命", hearty = true }, -- Hearty Portable Snack
        [242776] = { label = "精通/加速", hearty = true }, -- Hearty Farstrider Rations
        [255845] = { label = "大餐" }, -- Silvermoon Parade
        [255846] = { label = "大餐" }, -- Harandar Celebration
        [255847] = { label = "高主屬性" }, -- Impossibly Royal Roast
        [255848] = { label = "高次屬性" }, -- Flora Frenzy
        [266985] = { label = "大餐", hearty = true }, -- Hearty Silvermoon Parade
        [266986] = { label = "高次屬性", hearty = true }, -- Hearty Quel'dorei Medley
        [266996] = { label = "大餐", hearty = true }, -- Hearty Harandar Celebration
        [267000] = { label = "高次屬性", hearty = true }, -- Hearty Flora Frenzy
        [268679] = { label = "大餐", hearty = true }, -- Hearty Impossibly Royal Roast
        [268680] = { label = "高次屬性", hearty = true }, -- Hearty Flora Frenzy
        -- Recovery-only (no Well Fed buff, just health/mana restore). Not tracked, listed here for reference.
        -- [260264] = true, -- Quel'Danas Rations
        -- [260275] = true, -- Mukleech Curry
        -- [260276] = true, -- Akil'stew
        -- [260277] = true, -- Sedge Crawler Gumbo
        -- [260286] = true, -- Shrooms and Nectar
        -- [260299] = true, -- Roasted Abyssal Eel
    },
    -- Flask priority: fleeting/cauldron flasks (1) are prioritized over regular flasks (true)
    flask = {
        -- TWW 11.0.0
        [212269] = true, -- Flask of Tempered Aggression
        [212270] = true, -- Flask of Tempered Aggression (quality 2)
        [212271] = true, -- Flask of Tempered Aggression (quality 3)
        [212272] = true, -- Flask of Tempered Swiftness
        [212273] = true, -- Flask of Tempered Swiftness (quality 2)
        [212274] = true, -- Flask of Tempered Swiftness (quality 3)
        [212275] = true, -- Flask of Tempered Versatility
        [212276] = true, -- Flask of Tempered Versatility (quality 2)
        [212277] = true, -- Flask of Tempered Versatility (quality 3)
        [212278] = true, -- Flask of Tempered Mastery
        [212279] = true, -- Flask of Tempered Mastery (quality 2)
        [212280] = true, -- Flask of Tempered Mastery (quality 3)
        [212281] = true, -- Flask of Alchemical Chaos
        [212282] = true, -- Flask of Alchemical Chaos (quality 2)
        [212283] = true, -- Flask of Alchemical Chaos (quality 3)
        [212299] = true, -- Flask of Saving Graces
        [212300] = true, -- Flask of Saving Graces (quality 2)
        [212301] = true, -- Flask of Saving Graces (quality 3)
        -- TWW 11.0.0 (fleeting/cauldron)
        [212725] = 1, -- Fleeting Flask of Tempered Aggression
        [212727] = 1, -- Fleeting Flask of Tempered Aggression (quality 2)
        [212728] = 1, -- Fleeting Flask of Tempered Aggression (quality 3)
        [212729] = 1, -- Fleeting Flask of Tempered Swiftness
        [212730] = 1, -- Fleeting Flask of Tempered Swiftness (quality 2)
        [212731] = 1, -- Fleeting Flask of Tempered Swiftness (quality 3)
        [212732] = 1, -- Fleeting Flask of Tempered Versatility
        [212733] = 1, -- Fleeting Flask of Tempered Versatility (quality 2)
        [212734] = 1, -- Fleeting Flask of Tempered Versatility (quality 3)
        [212735] = 1, -- Fleeting Flask of Tempered Mastery
        [212736] = 1, -- Fleeting Flask of Tempered Mastery (quality 2)
        [212738] = 1, -- Fleeting Flask of Tempered Mastery (quality 3)
        [212739] = 1, -- Fleeting Flask of Alchemical Chaos
        [212740] = 1, -- Fleeting Flask of Alchemical Chaos (quality 2)
        [212741] = 1, -- Fleeting Flask of Alchemical Chaos (quality 3)
        [212745] = 1, -- Fleeting Flask of Saving Graces
        [212746] = 1, -- Fleeting Flask of Saving Graces (quality 2)
        [212747] = 1, -- Fleeting Flask of Saving Graces (quality 3)
        -- Midnight 12.0.0
        [241320] = true, -- Flask of Thalassian Resistance
        [241321] = true, -- Flask of Thalassian Resistance (quality 2)
        [241322] = true, -- Flask of the Magisters
        [241323] = true, -- Flask of the Magisters (quality 2)
        [241324] = true, -- Flask of the Blood Knights
        [241325] = true, -- Flask of the Blood Knights (quality 2)
        [241326] = true, -- Flask of the Shattered Sun
        [241327] = true, -- Flask of the Shattered Sun (quality 2)
        [241334] = true, -- Vicious Thalassian Flask of Honor
        [241335] = true, -- Vicious Thalassian Flask of Honor (quality 2)
        -- Midnight 12.0.0 (fleeting)
        [245926] = 1, -- Fleeting Flask of Thalassian Resistance
        [245927] = 1, -- Fleeting Flask of Thalassian Resistance (quality 2)
        [245928] = 1, -- Fleeting Flask of the Shattered Sun
        [245929] = 1, -- Fleeting Flask of the Shattered Sun (quality 2)
        [245930] = 1, -- Fleeting Flask of the Blood Knights
        [245931] = 1, -- Fleeting Flask of the Blood Knights (quality 2)
        [245932] = 1, -- Fleeting Flask of the Magisters
        [245933] = 1, -- Fleeting Flask of the Magisters (quality 2)
    },
    -- Rune priority: lower number = use first (Ethereal > Soulgorged > Crystallized > legacy)
    rune = {
        [259085] = 1, -- Void-Touched Augment Rune (Midnight)
        [243191] = 2, -- Ethereal Augment Rune (TWW permanent)
        [246492] = 3, -- Soulgorged Augment Rune (TWW, persists through death)
        [224572] = 4, -- Crystallized Augment Rune (TWW single use)
        -- Legacy runes
        [211495] = 5, -- Dreambound Augment Rune (Dragonflight)
        [201325] = 6, -- Draconic Augment Rune (Dragonflight)
        [181468] = 7, -- Veiled Augment Rune (Shadowlands)
    },
    weapon = {
        -- TWW 11.0.0
        [220156] = true, -- Bubbling Wax (Rogue)
        [222502] = true, -- Ironclaw Whetstone
        [222503] = true, -- Ironclaw Whetstone (quality 2)
        [222504] = true, -- Ironclaw Whetstone (quality 3)
        [222508] = true, -- Ironclaw Weightstone
        [222509] = true, -- Ironclaw Weightstone (quality 2)
        [222510] = true, -- Ironclaw Weightstone (quality 3)
        [224105] = true, -- Algari Mana Oil
        [224106] = true, -- Algari Mana Oil (quality 2)
        [224107] = true, -- Algari Mana Oil (quality 3)
        [224108] = true, -- Oil of Beledar's Grace
        [224109] = true, -- Oil of Beledar's Grace (quality 2)
        [224110] = true, -- Oil of Beledar's Grace (quality 3)
        [224111] = true, -- Oil of Deep Toxins
        [224112] = true, -- Oil of Deep Toxins (quality 2)
        [224113] = true, -- Oil of Deep Toxins (quality 3)
        -- Midnight 12.0.0
        [237367] = true, -- Refulgent Weightstone
        [237369] = true, -- Refulgent Weightstone (quality 2)
        [237370] = true, -- Refulgent Whetstone
        [237371] = true, -- Refulgent Whetstone (quality 2)
        [243733] = true, -- Thalassian Phoenix Oil
        [243734] = true, -- Thalassian Phoenix Oil (quality 2)
        [243735] = true, -- Oil of Dawn
        [243736] = true, -- Oil of Dawn (quality 2)
        [243737] = true, -- Smuggler's Enchanted Edge
        [243738] = true, -- Smuggler's Enchanted Edge (quality 2)
        [257749] = true, -- Laced Zoomshots
        [257750] = true, -- Laced Zoomshots (quality 2)
        [257751] = true, -- Weighted Boomshots
        [257752] = true, -- Weighted Boomshots (quality 2)
    },
}
