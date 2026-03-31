local _, BR = ...

-- Lookup tables of known consumable item IDs, keyed by consumable type.
-- Values: `true` for simple membership, or a table with `label` (stat abbreviation) and optional fields.
-- Food tables: `{ label, badge }`. Flask tables: `{ label, badge, priority }`.
-- `badge`: bottom-left overlay text ("H" for hearty food, "R1"/"R2"/"R3" for flask quality).
BR.CONSUMABLE_ITEMS = {
    food = {
        -- TWW 11.0.0
        [222702] = { label = "Lo 2nd" }, -- Skewered Fillet
        [222703] = { label = "Lo 2nd" }, -- Simple Stew
        [222704] = { label = "Lo 2nd" }, -- Unseasoned Field Steak
        [222705] = { label = "Lo 2nd" }, -- Roasted Mycobloom
        [222706] = { label = "Lo 2nd" }, -- Pan-Seared Mycobloom
        [222707] = { label = "Lo 2nd" }, -- Hallowfall Chili
        [222708] = { label = "Lo 2nd" }, -- Coreway Kabob
        [222709] = { label = "Lo 2nd" }, -- Flashfire Fillet
        [222710] = { label = "Stam/Str" }, -- Meat and Potatoes
        [222711] = { label = "Stam/Agi" }, -- Rib Stickers
        [222712] = { label = "Stam/Int" }, -- Sweet and Sour Meatballs
        [222713] = { label = "Stam" }, -- Tender Twilight Jerky
        [222714] = { label = "H" }, -- Zesty Nibblers
        [222715] = { label = "Crit" }, -- Fiery Fish Sticks
        [222716] = { label = "V" }, -- Ginger-Glazed Fillet
        [222717] = { label = "M" }, -- Salty Dog
        [222718] = { label = "H/Crit" }, -- Deepfin Patty
        [222719] = { label = "H/V" }, -- Sweet and Spicy Soup
        [222720] = { label = "Hi 2nd" }, -- The Sushi Special
        [222721] = { label = "Crit/V" }, -- Fish and Chips
        [222722] = { label = "M/Crit" }, -- Salt Baked Seafood
        [222723] = { label = "M/V" }, -- Marinated Tenderloins
        [222724] = { label = "Stam/Str" }, -- Sizzling Honey Roast
        [222725] = { label = "Stam/Agi" }, -- Mycobloom Risotto
        [222726] = { label = "Stam/Int" }, -- Stuffed Cave Peppers
        [222727] = { label = "Stam" }, -- Angler's Delight
        [222728] = { label = "Hi 2nd" }, -- Beledar's Bounty
        [222729] = { label = "Hi 2nd" }, -- Empress' Farewell
        [222730] = { label = "Hi 2nd" }, -- Jester's Board
        [222731] = { label = "Hi 2nd" }, -- Outsider's Provisions
        [222732] = { label = "Feast" }, -- Feast of the Divine Day
        [222733] = { label = "Feast" }, -- Feast of the Midnight Masquerade
        [222735] = { label = "Lo 2nd" }, -- Everything Stew
        [222736] = { label = "M/H" }, -- Chippy Tea
        [222750] = { label = "Lo 2nd", badge = "H" }, -- Hearty Skewered Fillet
        [222751] = { label = "Lo 2nd", badge = "H" }, -- Hearty Simple Stew
        [222752] = { label = "Lo 2nd", badge = "H" }, -- Hearty Unseasoned Field Steak
        [222753] = { label = "Lo 2nd", badge = "H" }, -- Hearty Roasted Mycobloom
        [222754] = { label = "Lo 2nd", badge = "H" }, -- Hearty Pan-Seared Mycobloom
        [222755] = { label = "Lo 2nd", badge = "H" }, -- Hearty Hallowfall Chili
        [222756] = { label = "Lo 2nd", badge = "H" }, -- Hearty Coreway Kabob
        [222757] = { label = "Lo 2nd", badge = "H" }, -- Hearty Flashfire Fillet
        [222758] = { label = "Stam/Str", badge = "H" }, -- Hearty Meat and Potatoes
        [222759] = { label = "Stam/Agi", badge = "H" }, -- Hearty Rib Stickers
        [222760] = { label = "Stam/Int", badge = "H" }, -- Hearty Sweet and Sour Meatballs
        [222761] = { label = "Stam", badge = "H" }, -- Hearty Tender Twilight Jerky
        [222762] = { label = "H", badge = "H" }, -- Hearty Zesty Nibblers
        [222763] = { label = "Crit", badge = "H" }, -- Hearty Fiery Fish Sticks
        [222764] = { label = "V", badge = "H" }, -- Hearty Ginger-Glazed Fillet
        [222765] = { label = "M", badge = "H" }, -- Hearty Salty Dog
        [222766] = { label = "H/Crit", badge = "H" }, -- Hearty Deepfin Patty
        [222767] = { label = "H/V", badge = "H" }, -- Hearty Sweet and Spicy Soup
        [222768] = { label = "Hi 2nd", badge = "H" }, -- Hearty Sushi Special
        [222769] = { label = "Crit/V", badge = "H" }, -- Hearty Fish and Chips
        [222770] = { label = "M/Crit", badge = "H" }, -- Hearty Salt Baked Seafood
        [222771] = { label = "M/V", badge = "H" }, -- Hearty Marinated Tenderloins
        [222772] = { label = "Stam/Str", badge = "H" }, -- Hearty Sizzling Honey Roast
        [222773] = { label = "Stam/Agi", badge = "H" }, -- Hearty Mycobloom Risotto
        [222774] = { label = "Stam/Int", badge = "H" }, -- Hearty Stuffed Cave Peppers
        [222775] = { label = "Stam", badge = "H" }, -- Hearty Angler's Delight
        [222776] = { label = "Hi 2nd", badge = "H" }, -- Hearty Beledar's Bounty
        [222777] = { label = "Hi 2nd", badge = "H" }, -- Hearty Empress' Farewell
        [222778] = { label = "Hi 2nd", badge = "H" }, -- Hearty Jester's Board
        [222779] = { label = "Hi 2nd", badge = "H" }, -- Hearty Outsider's Provisions
        [222780] = { label = "Feast", badge = "H" }, -- Hearty Feast of the Divine Day
        [222781] = { label = "Feast", badge = "H" }, -- Hearty Feast of the Midnight Masquerade
        [222783] = { label = "Lo 2nd", badge = "H" }, -- Hearty Everything Stew
        [222784] = { label = "M/H", badge = "H" }, -- Hearty Chippy Tea
        [223966] = { label = "Rand" }, -- Everything-on-a-Stick (random Khaz Algar meal)
        [223967] = { label = "Lo 2nd" }, -- Protein Slurp
        [223968] = { label = "Lo 2nd" }, -- Spongey Scramble
        [225592] = { label = "Speed" }, -- Exquisitely Eviscerated Muscle

        -- TWW 11.1.0
        [235805] = { label = "Hi 2nd" }, -- Authentic Undermine Clam Chowder
        [235853] = { label = "Hi 2nd", badge = "H" }, -- Hearty Authentic Undermine Clam Chowder

        -- Midnight 12.0.0
        [242272] = { label = "Hi 2nd" }, -- Quel'dorei Medley
        [242273] = { label = "Hi 2nd" }, -- Blooming Feast
        [242274] = { label = "Hi 2nd" }, -- Champion's Bento
        [242275] = { label = "Hi 1st" }, -- Royal Roast
        [242276] = { label = "V" }, -- Braised Blood Hunter
        [242277] = { label = "H" }, -- Crimson Calamari
        [242278] = { label = "Crit" }, -- Tasty Smoked Tetra
        [242279] = { label = "Mid 1st" }, -- Baked Lucky Loa
        [242280] = { label = "V" }, -- Buttered Root Crab
        [242281] = { label = "M" }, -- Glitter Skewers
        [242282] = { label = "H" }, -- Null and Void Plate
        [242283] = { label = "Crit" }, -- Sun-Seared Lumifin
        [242284] = { label = "V" }, -- Void-Kissed Fish Rolls
        [242285] = { label = "M" }, -- Warped Wise Wings
        [242286] = { label = "H" }, -- Fel-Kissed Filet
        [242287] = { label = "Crit" }, -- Arcano Cutlets
        [242288] = { label = "Mid 1st" }, -- Twilight Angler's Medley
        [242289] = { label = "Mid 1st" }, -- Spellfire Filet
        [242290] = { label = "Crit/V" }, -- Wise Tails
        [242291] = { label = "M/V" }, -- Fried Bloomtail
        [242292] = { label = "M/Crit" }, -- Eversong Pudding
        [242293] = { label = "H/V" }, -- Sunwell Delight
        [242294] = { label = "V" }, -- Felberry Figs
        [242295] = { label = "H/Crit" }, -- Hearthflame Supper
        [242296] = { label = "M/H" }, -- Bloodthistle-wrapped Cutlets
        [242302] = { label = "Lo 1st" }, -- Bloom Skewers
        [242303] = { label = "Lo 1st" }, -- Mana-Infused Stew
        [242304] = { label = "Crit/V" }, -- Spiced Biscuits
        [242305] = { label = "M/V" }, -- Silvermoon Standard
        [242306] = { label = "M/Crit" }, -- Forager's Medley
        [242307] = { label = "H/V" }, -- Quick Sandwich
        [242308] = { label = "H/Crit" }, -- Portable Snack
        [242309] = { label = "M/H" }, -- Farstrider Rations
        [242532] = { label = "Lo 1st" }, -- [PH] Vegetarian Recipe
        [242744] = { label = "Hi 2nd", badge = "H" }, -- Hearty Quel'dorei Medley
        [242745] = { label = "Hi 2nd", badge = "H" }, -- Hearty Blooming Feast
        [242746] = { label = "Hi 2nd", badge = "H" }, -- Hearty Champion's Bento
        [242747] = { label = "Hi 1st", badge = "H" }, -- Hearty Royal Roast
        [242748] = { label = "V", badge = "H" }, -- Hearty Braised Blood Hunter
        [242749] = { label = "H", badge = "H" }, -- Hearty Crimson Calamari
        [242750] = { label = "Crit", badge = "H" }, -- Hearty Tasty Smoked Tetra
        [242751] = { label = "Mid 1st", badge = "H" }, -- Hearty Rootland Surprise
        [242752] = { label = "V", badge = "H" }, -- Hearty Buttered Root Crab
        [242753] = { label = "M", badge = "H" }, -- Hearty Glitter Skewers
        [242754] = { label = "H", badge = "H" }, -- Hearty Null and Void Plate
        [242755] = { label = "Crit", badge = "H" }, -- Hearty Sun-Seared Lumifin
        [242756] = { label = "V", badge = "H" }, -- Hearty Void-Kissed Fish Rolls
        [242757] = { label = "M", badge = "H" }, -- Hearty Warped Wise Wings
        [242758] = { label = "H", badge = "H" }, -- Hearty Fel-Kissed Filet
        [242759] = { label = "Crit", badge = "H" }, -- Hearty Arcano Cutlets
        [242760] = { label = "Mid 1st", badge = "H" }, -- Hearty Twilight Angler's Medley
        [242761] = { label = "Mid 1st", badge = "H" }, -- Hearty Spellfire Filet
        [242762] = { label = "Crit/V", badge = "H" }, -- Hearty Wise Tails
        [242763] = { label = "M/V", badge = "H" }, -- Hearty Fried Bloomtail
        [242764] = { label = "M/Crit", badge = "H" }, -- Hearty Eversong Pudding
        [242765] = { label = "H/V", badge = "H" }, -- Hearty Sunwell Delight
        [242766] = { label = "V", badge = "H" }, -- Hearty Felberry Figs
        [242767] = { label = "H/Crit", badge = "H" }, -- Hearty Hearthflame Supper
        [242768] = { label = "M/H", badge = "H" }, -- Hearty Bloodthistle-Wrapped Cutlets
        [242769] = { label = "Lo 1st", badge = "H" }, -- Hearty Bloom Skewers
        [242770] = { label = "Lo 1st", badge = "H" }, -- Hearty Mana-Infused Stew
        [242771] = { label = "Crit/V", badge = "H" }, -- Hearty Spiced Biscuits
        [242772] = { label = "M/V", badge = "H" }, -- Hearty Silvermoon Standard
        [242773] = { label = "M/Crit", badge = "H" }, -- Hearty Forager's Medley
        [242774] = { label = "H/V", badge = "H" }, -- Hearty Quick Sandwich
        [242775] = { label = "H/Crit", badge = "H" }, -- Hearty Portable Snack
        [242776] = { label = "M/H", badge = "H" }, -- Hearty Farstrider Rations
        [255845] = { label = "Feast" }, -- Silvermoon Parade
        [255846] = { label = "Feast" }, -- Harandar Celebration
        [255847] = { label = "Hi 1st" }, -- Impossibly Royal Roast
        [255848] = { label = "Hi 2nd" }, -- Flora Frenzy
        [266985] = { label = "Feast", badge = "H" }, -- Hearty Silvermoon Parade
        [266986] = { label = "Hi 2nd", badge = "H" }, -- Hearty Quel'dorei Medley
        [266996] = { label = "Feast", badge = "H" }, -- Hearty Harandar Celebration
        [267000] = { label = "Hi 2nd", badge = "H" }, -- Hearty Flora Frenzy
        [268679] = { label = "Hi 1st", badge = "H" }, -- Hearty Impossibly Royal Roast
        [268680] = { label = "Hi 2nd", badge = "H" }, -- Hearty Flora Frenzy
        -- Recovery-only (no Well Fed buff, just health/mana restore). Not tracked, listed here for reference.
        -- [260264] = true, -- Quel'Danas Rations
        -- [260275] = true, -- Mukleech Curry
        -- [260276] = true, -- Akil'stew
        -- [260277] = true, -- Sedge Crawler Gumbo
        -- [260286] = true, -- Shrooms and Nectar
        -- [260299] = true, -- Roasted Abyssal Eel
    },
    -- Flask entries: { label, badge } for regular, { label, badge, priority } for fleeting/cauldron
    -- badge = quality rank (R1/R2/R3), priority = sort order (fleeting sort first)
    flask = {
        -- TWW 11.0.0 (3 tiers: R1 gold, R2 silver, R3 bronze)
        [212269] = { label = "Crit", badge = "R1" }, -- Flask of Tempered Aggression
        [212270] = { label = "Crit", badge = "R2" }, -- Flask of Tempered Aggression (quality 2)
        [212271] = { label = "Crit", badge = "R3" }, -- Flask of Tempered Aggression (quality 3)
        [212272] = { label = "Haste", badge = "R1" }, -- Flask of Tempered Swiftness
        [212273] = { label = "Haste", badge = "R2" }, -- Flask of Tempered Swiftness (quality 2)
        [212274] = { label = "Haste", badge = "R3" }, -- Flask of Tempered Swiftness (quality 3)
        [212275] = { label = "Vers", badge = "R1" }, -- Flask of Tempered Versatility
        [212276] = { label = "Vers", badge = "R2" }, -- Flask of Tempered Versatility (quality 2)
        [212277] = { label = "Vers", badge = "R3" }, -- Flask of Tempered Versatility (quality 3)
        [212278] = { label = "Mast", badge = "R1" }, -- Flask of Tempered Mastery
        [212279] = { label = "Mast", badge = "R2" }, -- Flask of Tempered Mastery (quality 2)
        [212280] = { label = "Mast", badge = "R3" }, -- Flask of Tempered Mastery (quality 3)
        [212281] = { label = "Rand", badge = "R1" }, -- Flask of Alchemical Chaos
        [212282] = { label = "Rand", badge = "R2" }, -- Flask of Alchemical Chaos (quality 2)
        [212283] = { label = "Rand", badge = "R3" }, -- Flask of Alchemical Chaos (quality 3)
        [212299] = { label = "Heal", badge = "R1" }, -- Flask of Saving Graces
        [212300] = { label = "Heal", badge = "R2" }, -- Flask of Saving Graces (quality 2)
        [212301] = { label = "Heal", badge = "R3" }, -- Flask of Saving Graces (quality 3)
        -- TWW 11.0.0 (fleeting/cauldron, 3 tiers)
        [212725] = { label = "Crit", badge = "F1", priority = 1 }, -- Fleeting Flask of Tempered Aggression
        [212727] = { label = "Crit", badge = "F2", priority = 1 }, -- Fleeting Flask of Tempered Aggression (quality 2)
        [212728] = { label = "Crit", badge = "F3", priority = 1 }, -- Fleeting Flask of Tempered Aggression (quality 3)
        [212729] = { label = "Haste", badge = "F1", priority = 1 }, -- Fleeting Flask of Tempered Swiftness
        [212730] = { label = "Haste", badge = "F2", priority = 1 }, -- Fleeting Flask of Tempered Swiftness (quality 2)
        [212731] = { label = "Haste", badge = "F3", priority = 1 }, -- Fleeting Flask of Tempered Swiftness (quality 3)
        [212732] = { label = "Vers", badge = "F1", priority = 1 }, -- Fleeting Flask of Tempered Versatility
        [212733] = { label = "Vers", badge = "F2", priority = 1 }, -- Fleeting Flask of Tempered Versatility (quality 2)
        [212734] = { label = "Vers", badge = "F3", priority = 1 }, -- Fleeting Flask of Tempered Versatility (quality 3)
        [212735] = { label = "Mast", badge = "F1", priority = 1 }, -- Fleeting Flask of Tempered Mastery
        [212736] = { label = "Mast", badge = "F2", priority = 1 }, -- Fleeting Flask of Tempered Mastery (quality 2)
        [212738] = { label = "Mast", badge = "F3", priority = 1 }, -- Fleeting Flask of Tempered Mastery (quality 3)
        [212739] = { label = "Rand", badge = "F1", priority = 1 }, -- Fleeting Flask of Alchemical Chaos
        [212740] = { label = "Rand", badge = "F2", priority = 1 }, -- Fleeting Flask of Alchemical Chaos (quality 2)
        [212741] = { label = "Rand", badge = "F3", priority = 1 }, -- Fleeting Flask of Alchemical Chaos (quality 3)
        [212745] = { label = "Heal", badge = "F1", priority = 1 }, -- Fleeting Flask of Saving Graces
        [212746] = { label = "Heal", badge = "F2", priority = 1 }, -- Fleeting Flask of Saving Graces (quality 2)
        [212747] = { label = "Heal", badge = "F3", priority = 1 }, -- Fleeting Flask of Saving Graces (quality 3)
        -- Midnight 12.0.0 (2 tiers: R1 gold, R2 silver)
        [241320] = { label = "Vers", badge = "R1" }, -- Flask of Thalassian Resistance
        [241321] = { label = "Vers", badge = "R2" }, -- Flask of Thalassian Resistance (quality 2)
        [241322] = { label = "Mast", badge = "R1" }, -- Flask of the Magisters
        [241323] = { label = "Mast", badge = "R2" }, -- Flask of the Magisters (quality 2)
        [241324] = { label = "Haste", badge = "R1" }, -- Flask of the Blood Knights
        [241325] = { label = "Haste", badge = "R2" }, -- Flask of the Blood Knights (quality 2)
        [241326] = { label = "Crit", badge = "R1" }, -- Flask of the Shattered Sun
        [241327] = { label = "Crit", badge = "R2" }, -- Flask of the Shattered Sun (quality 2)
        [241334] = { label = "PvP", badge = "R1" }, -- Vicious Thalassian Flask of Honor
        [241335] = { label = "PvP", badge = "R2" }, -- Vicious Thalassian Flask of Honor (quality 2)
        -- Midnight 12.0.0 (fleeting, 2 tiers)
        [245926] = { label = "Vers", badge = "F1", priority = 1 }, -- Fleeting Flask of Thalassian Resistance
        [245927] = { label = "Vers", badge = "F2", priority = 1 }, -- Fleeting Flask of Thalassian Resistance (quality 2)
        [245928] = { label = "Crit", badge = "F1", priority = 1 }, -- Fleeting Flask of the Shattered Sun
        [245929] = { label = "Crit", badge = "F2", priority = 1 }, -- Fleeting Flask of the Shattered Sun (quality 2)
        [245930] = { label = "Haste", badge = "F1", priority = 1 }, -- Fleeting Flask of the Blood Knights
        [245931] = { label = "Haste", badge = "F2", priority = 1 }, -- Fleeting Flask of the Blood Knights (quality 2)
        [245932] = { label = "Mast", badge = "F1", priority = 1 }, -- Fleeting Flask of the Magisters
        [245933] = { label = "Mast", badge = "F2", priority = 1 }, -- Fleeting Flask of the Magisters (quality 2)
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

-- Fleeting flask item IDs. These sort first by numeric priority but should NOT be
-- remembered — they would overwrite the user's regular flask preference.
BR.FLEETING_FLASK_ITEMS = {
    [245926] = true, -- Fleeting Flask of Thalassian Resistance
    [245927] = true, -- Fleeting Flask of Thalassian Resistance (quality 2)
    [245928] = true, -- Fleeting Flask of the Shattered Sun
    [245929] = true, -- Fleeting Flask of the Shattered Sun (quality 2)
    [245930] = true, -- Fleeting Flask of the Blood Knights
    [245931] = true, -- Fleeting Flask of the Blood Knights (quality 2)
    [245932] = true, -- Fleeting Flask of the Magisters
    [245933] = true, -- Fleeting Flask of the Magisters (quality 2)
}
