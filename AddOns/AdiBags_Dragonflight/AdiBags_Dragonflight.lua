--[[
AdiBags - Dragonflight
by Zottelchen
version: 2.3.35
Items from the Dragonflight expansion.
]]

local addonName, addon = ...
local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")

local L = addon.L
local MatchIDs
local Result = {}

local function AddToSet(...)
  local Set = {}
  for _, l in ipairs({ ... }) do
    for _, v in ipairs(l) do
      Set[v] = true
    end
  end
  return Set
end

local database = {}

-- Cavern Clawbering (Achievement)
database["CavernClawberingAchievement"] = {
  205686, -- Clacking Claw
}

-- Chip (Pet)
database["ChipPet"] = {
  198082, -- Pre-Sentient Rock Cluster
  198357, -- Rock of Aegis
  199219, -- Element-Infused Blood
}

-- Honor Our Ancestors
database["HonorOurAncestors"] = {
  190327, -- Awakened Air
  191471, -- Writhebark
  193470, -- Feral Hide Drums
  194690, -- Horn o' Mead
  197776, -- Thrice-Spiced Mammoth Kabob
  197788, -- Braised Bruffalon Brisket
  199049, -- Fire-Blessed Greatsword
  200018, -- Enchant Boots - Plainsrunner's Breeze
  202070, -- Exceptional Pelt
}

-- Librarian of the Reach (Achievement)
database["LibrarianoftheReachAchievement"] = {
  204181, -- Opera of the Aspects
  204185, -- The Old Gods and the Ordering of Azeroth (Annotated)
  204316, -- A Soldier's Journal
  204317, -- Words of the Wyrmslayer
  204321, -- Lost Expedition Notes
  204328, -- Return of the Nightsquall
  204335, -- A Song of the Depths
  204338, -- The Burden of Lapisagos
  204691, -- Living Book
}

-- Lizis Reins (Mount)
database["LizisReinsMount"] = {
  192615, -- Fluorescent Fluid
  192636, -- Woolly Mountain Pelt
  192658, -- High-Fiber Leaf
  194966, -- Thousandbite Piranha
  200598, -- Meluun's Green Curry
}

-- Magmashell (Mount)
database["MagmashellMount"] = {
  201883, -- Empty Magma Shell
}

-- Otto (Mount)
database["OttoMount"] = {
  199338, -- Copper Coin of the Isles
  199339, -- Silver Coin of the Isles
  199340, -- Gold Coin of the Isles
  202061, -- Empty Fish Barrel
  202066, -- Half-Filled Fish Barrel
  202068, -- Brimming Fish Barrel
  202069, -- Overflowing Fish Barrel
  202072, -- Frigid Floe Fish
  202073, -- Calamitous Carp
  202074, -- Kingfin, the Wise Whiskerfish
  202102, -- Immaculate Sac of Swog Treasures
}

-- Phoenix Wishwing (Pet)
database["PhoenixWishwingPet"] = {
  199080, -- Smoldering Phoenix Ash
  199092, -- Inert Phoenix Ash
  199097, -- Sacred Phoenix Ash
  199099, -- Glittering Phoenix Ember
  199177, -- Ash Feather Amulet
  199203, -- Phoenix Ash Talisman
  202062, -- Ash Feather
}

-- Scrappy Worldsnail (Mount)
database["ScrappyWorldsnailMount"] = {
  199215, -- Worldbreaker Membership
  202173, -- Magmote
}

-- Temperamental Skyclaw (Mount)
database["TemperamentalSkyclawMount"] = {
  201420, -- Gnolan's House Special
  201421, -- Tuskarr Jerky
  201422, -- Flash Frozen Meat
}

-- Tetrachromancer (Achievement)
database["TetrachromancerAchievement"] = {
  193205, -- Ohuna Companion Color: Brown
  194087, -- Ohuna Companion Color: Red
  194088, -- Ohuna Companion Color: Dark
  194089, -- Bakar Companion Color: Orange
  194090, -- Bakar Companion Color: White
  194091, -- Bakar Companion Color: Golden Brown
  194093, -- Bakar Companion Color: Brown
  194094, -- Bakar Companion Color: Black
  194095, -- Ohuna Companion Color: Sepia
}

-- While We Were Sleeping (Achievement)
database["WhileWeWereSleepingAchievement"] = {
  202203, -- Sending Stone: Protest
  202326, -- Sending Stone: Initial Report
  202327, -- Sending Stone: The Prisoner
  202328, -- Receiving Stone: Final Warning
  202329, -- Journal Entry: Experiments
  202335, -- Journal Entry: Relics
  202336, -- Journal Entry: The Creches
  202337, -- Journal Entry: Silence
  204200, -- Journal Entry: Experiments
  204221, -- Journal Entry: Relics
  204223, -- Journal Entry: The Creches
  204246, -- Journal Entry: Silence
  204250, -- Receiving Stone: Final Warning
  204251, -- Sending Stone: Protest
  204252, -- Sending Stone: Initial Report
  204253, -- Sending Stone: The Prisoner
}

-- Bandages
database["Bandages"] = {
  194048, -- Wildercloth Bandage
  194049, -- Wildercloth Bandage
  194050, -- Wildercloth Bandage
}

-- Cauldrons
database["Cauldrons"] = {
  191482, -- Potion Cauldron of Power
  191483, -- Potion Cauldron of Power
  191484, -- Potion Cauldron of Power
  191485, -- Potion Cauldron of Ultimate Power
  191486, -- Potion Cauldron of Ultimate Power
  191487, -- Potion Cauldron of Ultimate Power
  191488, -- Cauldron of the Pooka
  191489, -- Cauldron of the Pooka
  191490, -- Cauldron of the Pooka
}

-- Contracts
database["Contracts"] = {
  198494, -- Contract: Iskaara Tuskarr
  198495, -- Contract: Iskaara Tuskarr
  198496, -- Contract: Iskaara Tuskarr
  198497, -- Contract: Valdrakken Accord
  198498, -- Contract: Valdrakken Accord
  198499, -- Contract: Valdrakken Accord
  198500, -- Contract: Maruuk Centaur
  198501, -- Contract: Maruuk Centaur
  198502, -- Contract: Maruuk Centaur
  198503, -- Contract: Artisan's Consortium
  198504, -- Contract: Artisan's Consortium
  198505, -- Contract: Artisan's Consortium
  198506, -- Contract: Dragonscale Expedition
  198507, -- Contract: Dragonscale Expedition
  198508, -- Contract: Dragonscale Expedition
  210244, -- Contract: Dream Wardens
  210245, -- Contract: Dream Wardens
  210246, -- Contract: Dream Wardens
}

-- Crafting Potions
database["CraftingPotions"] = {
  191342, -- Aerated Phial of Deftness
  191343, -- Aerated Phial of Deftness
  191344, -- Aerated Phial of Deftness
  191345, -- Steaming Phial of Finesse
  191346, -- Steaming Phial of Finesse
  191347, -- Steaming Phial of Finesse
  191354, -- Crystalline Phial of Perception
  191355, -- Crystalline Phial of Perception
  191356, -- Crystalline Phial of Perception
  197720, -- Aerated Phial of Quick Hands
  197721, -- Aerated Phial of Quick Hands
  197722, -- Aerated Phial of Quick Hands
}

-- Food
database["Food"] = {
  191050, -- 10.0 Food/Drink Template - Food Only - Level 65 - Required Level 60
  191051, -- 10.0 Food/Drink Template - Food Only - Level 70 - Required Level 65
  191052, -- 10.0 Food/Drink Template - Drink Only - Level 65 - Required Level 60
  191053, -- 10.0 Food/Drink Template - Drink Only - Level 70 - Required Level 65
  191056, -- 10.0 Food/Drink Template - Both Health and Mana - Level 70 - Required Level 65
  191062, -- 10 Food/Drink Template - Alcohol - Weak
  191063, -- 10 Food/Drink Template - Alcohol - Potent
  191064, -- 10 Food/Drink Template - Alcohol - Strong
  191917, -- Suspiciously Fuzzy Drink
  191918, -- Suspiciously Fuzzy Drink
  191919, -- Suspiciously Fuzzy Drink
  193859, -- Twice-Burnt Potato
  194680, -- Jerky Surprise
  194681, -- Sugarwing Cupcake
  194682, -- Mother's Gift
  194683, -- Buttermilk
  194684, -- Azure Leywine
  194685, -- Dragonspring Water
  194686, -- Spicy Musken Drummies
  194688, -- Vorquin Filet
  194689, -- Anchovy Crisps
  194690, -- Horn o' Mead
  194691, -- Artisanal Berry Juice
  194692, -- Distilled Fish Juice
  194693, -- Improvised Sushi
  194694, -- Seasoned Hornswog Steak
  194695, -- Ramloaf
  195455, -- Argali Cheese
  195456, -- Plains Flatbread
  195457, -- Mammoth Jerky
  195458, -- Forager's Stew
  195459, -- Argali Milk
  195460, -- Fermented Musken Milk
  195462, -- Fried Hornstrider Wings
  195463, -- Seasoned Mudstomper Belly
  195464, -- Sweetened Broadhoof Milk
  195465, -- Stormwing Egg Breakfast
  195466, -- Frenzy and Chips
  196440, -- Dragon Flight
  196540, -- Broadhoof Tail Poutine
  196582, -- Syrup-Drenched Toast
  196583, -- Greenberry Toast
  196584, -- Acorn Milk
  196585, -- Plainswheat Pretzel
  197758, -- Twice-Baked Potato
  197759, -- Cheese and Quackers
  197760, -- Mackerel Snackerel
  197761, -- Probably Protein
  197762, -- Sweet and Sour Clam Chowder
  197763, -- Breakfast of Draconic Champions
  197766, -- Snow in a Cone
  197767, -- Blubbery Muffin
  197768, -- Celebratory Cake
  197769, -- Tasty Hatchling's Treat
  197770, -- Zesty Water
  197771, -- Delicious Dragon Spittle
  197772, -- Churnbelly Tea
  197774, -- Charred Hornswog Steaks
  197775, -- Scrambled Basilisk Eggs
  197776, -- Thrice-Spiced Mammoth Kabob
  197777, -- Hopefully Healthy
  197778, -- Timely Demise
  197779, -- Filet of Fangs
  197780, -- Seamoth Surprise
  197781, -- Salt-Baked Fishcake
  197782, -- Feisty Fish Sticks
  197783, -- Aromatic Seafood Platter
  197784, -- Sizzling Seafood Medley
  197785, -- Revenge, Served Cold
  197786, -- Thousandbone Tongueslicer
  197787, -- Great Cerulean Sea
  197788, -- Braised Bruffalon Brisket
  197789, -- Riverside Picnic
  197790, -- Roast Duck Delight
  197791, -- Salted Meat Mash
  197792, -- Fated Fortune Cookie
  197793, -- Yusa's Hearty Stew
  197794, -- Grand Banquet of the Kalu'ak
  197795, -- Hoard of Draconic Delicacies
  197847, -- Gorloc Fin Soup
  197848, -- Hearty Squash Stew
  197849, -- Ancient Firewine
  197850, -- Mammoth Dumpling
  197851, -- Extra Crispy Mutton
  197852, -- Goat Brisket
  197853, -- Critter Kebab
  197854, -- Enchanted Argali Tenderloin
  197855, -- Explorer's Mix
  197856, -- Cup o' Wakeup
  197857, -- Swog Slurp
  197858, -- Salt-Baked Scalebelly
  198356, -- Honey Snack
  198440, -- Discounted Meat
  198441, -- Thunderspine Tenders
  198830, -- Conjured Tasty Hatchling's Treat
  198831, -- Conjured Snow in a Cone
  198832, -- Conjured Blubbery Muffin
  198833, -- Conjured Celebratory Cake
  200099, -- M.R.E.
  200304, -- Stored Dracthyr Rations
  200305, -- Dracthyr Water Rations
  200619, -- Scaralesh's Special
  200680, -- Maruukai Mule
  200681, -- Ohn Lite
  200855, -- Tuskarr Port Wine
  200856, -- Sideboat
  200862, -- Experimental Duck Feed
  200871, -- Steamed Scarab Steak
  200953, -- Wild Dragon Fruit
  200966, -- Wild Truffle
  201045, -- Icecrown Bleu
  201046, -- Dreamwarding Dripbrew
  201047, -- Arcanostabilized Provisions
  201089, -- Craft Creche Crowler
  201090, -- Bivigosa's Blood Sausages
  201327, -- Emerald Dreamtime
  201398, -- Mogu Mozzarella
  201413, -- Eternity-Infused Burrata
  201415, -- Temporal Parmesan
  201416, -- Black Empire Brunost
  201417, -- Curding of Stratholme
  201419, -- Apexis Asiago
  201469, -- Emerald Green Apple
  201697, -- Coldarra Coldbrew
  201698, -- Black Dragon Red Eye
  201721, -- Life Fire Latte
  201725, -- Flappuccino
  201813, -- Spoiled Firewine
  201820, -- Silithus Swiss
  202033, -- Slippery Salmon
  202063, -- Flopping Tilapia
  202108, -- Bouncing Bass
  202290, -- Firewater Sorbet
  202314, -- Big Chunk o' Meat
  202315, -- Frozen Solid Tea
  202401, -- Cactus Apple Surprise
  204072, -- Deviously Deviled Eggs
  204235, -- Kaldorei Fruitcake
  204342, -- Questionable Jerky
  204729, -- Freshly Squeezed Mosswater
  204730, -- Grub Grub
  204790, -- Strong Sniffin' Soup for Niffen
  204845, -- Rocks on the Rocks
  204846, -- Conjured Rocks on the Rocks
  205417, -- Fungishine
  205684, -- Forbidden Flounder
  205690, -- Barter-B-Q
  205692, -- Stellaviatori Soup
  205693, -- Latticed Stinkhorn
  205793, -- Skitter Souf-fly
  205794, -- Beetle Juice
  206139, -- Volatile Crimson Embers
  206140, -- Soothing Emerald Tea
  206141, -- Prismatic Snail Mucus
  206142, -- Gritty Stone Potion
  206143, -- Energized Temporal Spores
  206144, -- Curious Primordial Fungus
}

-- Incense
database["Incense"] = {
  191499, -- Sagacious Incense
  191500, -- Sagacious Incense
  191501, -- Sagacious Incense
  191502, -- Somniferous Incense
  191503, -- Somniferous Incense
  191504, -- Somniferous Incense
  191505, -- Exultant Incense
  191506, -- Exultant Incense
  191507, -- Exultant Incense
  191508, -- Fervid Incense
  191509, -- Fervid Incense
  191510, -- Fervid Incense
}

-- Phials
database["Phials"] = {
  191318, -- Phial of the Eye in the Storm
  191319, -- Phial of the Eye in the Storm
  191320, -- Phial of the Eye in the Storm
  191321, -- Phial of Still Air
  191322, -- Phial of Still Air
  191323, -- Phial of Still Air
  191324, -- Phial of Icy Preservation
  191325, -- Phial of Icy Preservation
  191326, -- Phial of Icy Preservation
  191327, -- Iced Phial of Corrupting Rage
  191328, -- Iced Phial of Corrupting Rage
  191329, -- Iced Phial of Corrupting Rage
  191330, -- Phial of Charged Isolation
  191331, -- Phial of Charged Isolation
  191332, -- Phial of Charged Isolation
  191333, -- Phial of Glacial Fury
  191334, -- Phial of Glacial Fury
  191335, -- Phial of Glacial Fury
  191336, -- Phial of Static Empowerment
  191337, -- Phial of Static Empowerment
  191338, -- Phial of Static Empowerment
  191339, -- Phial of Tepid Versatility
  191340, -- Phial of Tepid Versatility
  191341, -- Phial of Tepid Versatility
  191348, -- Charged Phial of Alacrity
  191349, -- Charged Phial of Alacrity
  191350, -- Charged Phial of Alacrity
  191357, -- Phial of Elemental Chaos
  191358, -- Phial of Elemental Chaos
  191359, -- Phial of Elemental Chaos
}

-- Potions
database["Potions"] = {
  191351, -- Potion of Frozen Fatality
  191352, -- Potion of Frozen Fatality
  191353, -- Potion of Frozen Fatality
  191360, -- Bottled Putrescence
  191361, -- Bottled Putrescence
  191362, -- Bottled Putrescence
  191363, -- Potion of Frozen Focus
  191364, -- Potion of Frozen Focus
  191365, -- Potion of Frozen Focus
  191366, -- Potion of Chilled Clarity
  191367, -- Potion of Chilled Clarity
  191368, -- Potion of Chilled Clarity
  191369, -- Potion of Withering Vitality
  191370, -- Potion of Withering Vitality
  191371, -- Potion of Withering Vitality
  191372, -- Residual Neural Channeling Agent
  191373, -- Residual Neural Channeling Agent
  191374, -- Residual Neural Channeling Agent
  191375, -- Delicate Suspension of Spores
  191376, -- Delicate Suspension of Spores
  191377, -- Delicate Suspension of Spores
  191378, -- Refreshing Healing Potion
  191379, -- Refreshing Healing Potion
  191380, -- Refreshing Healing Potion
  191381, -- Elemental Potion of Ultimate Power
  191382, -- Elemental Potion of Ultimate Power
  191383, -- Elemental Potion of Ultimate Power
  191384, -- Aerated Mana Potion
  191385, -- Aerated Mana Potion
  191386, -- Aerated Mana Potion
  191387, -- Elemental Potion of Power
  191388, -- Elemental Potion of Power
  191389, -- Elemental Potion of Power
  191393, -- Potion of the Hushed Zephyr
  191394, -- Potion of the Hushed Zephyr
  191395, -- Potion of the Hushed Zephyr
  191396, -- Potion of Gusts
  191397, -- Potion of Gusts
  191398, -- Potion of Gusts
  191399, -- Potion of Shocking Disclosure
  191400, -- Potion of Shocking Disclosure
  191401, -- Potion of Shocking Disclosure
  191905, -- Fleeting Elemental Potion of Power
  191906, -- Fleeting Elemental Potion of Power
  191907, -- Fleeting Elemental Potion of Power
  191912, -- Fleeting Elemental Potion of Ultimate Power
  191913, -- Fleeting Elemental Potion of Ultimate Power
  191914, -- Fleeting Elemental Potion of Ultimate Power
  194337, -- Liquid Courage
  207021, -- Dreamwalker's Healing Potion
  207022, -- Dreamwalker's Healing Potion
  207023, -- Dreamwalker's Healing Potion
  207039, -- Potion of Withering Dreams
  207040, -- Potion of Withering Dreams
  207041, -- Potion of Withering Dreams
}

-- Ruby Feast
database["RubyFeast"] = {
  200759, -- Aruunem Berrytart
  200885, -- Cinna-Cinderbloom Tea
  200886, -- Lemon Silverleaf Tea
  200887, -- Charred Porter
  200888, -- Coal-Fired Rib Rack
  200889, -- Highly-Spiced Haunch
  200890, -- Stonetalon Bloom Skewer
  200891, -- Druidic Dreamsalad
  200892, -- Dragonfruit Punch
  200893, -- Azsunian-Poached Lobster
  200894, -- Rare Vintage Arcwine
  200895, -- Fine Taladorian Cheese Platter
  200896, -- Captain's Caramelized Catfish
  200897, -- Venrik's Goat Milk
  200898, -- Mantis Shrimp Cocktail
  200899, -- Seared Sea Mist Noodles
  200900, -- Fried Emperor Wraps
  200901, -- Roquefort-Stuffed Peppers
  200902, -- Ravenberry Panacotta Delight
  200903, -- Moira's Choice Espresso
  200904, -- Picante Pomfruit Cake
}

-- Runes
database["Runes"] = {
  194817, -- Howling Rune
  194819, -- Howling Rune
  194820, -- Howling Rune
  194821, -- Buzzing Rune
  194822, -- Buzzing Rune
  194823, -- Buzzing Rune
  194824, -- Chirping Rune
  194825, -- Chirping Rune
  194826, -- Chirping Rune
  198491, -- Vantus Rune: Vault of the Incarnates
  198492, -- Vantus Rune: Vault of the Incarnates
  198493, -- Vantus Rune: Vault of the Incarnates
  201325, -- Draconic Augment Rune
  204858, -- Vantus Rune: Aberrus, the Shadowed Crucible
  204859, -- Vantus Rune: Aberrus, the Shadowed Crucible
  204860, -- Vantus Rune: Aberrus, the Shadowed Crucible
  204971, -- Hissing Rune
  204972, -- Hissing Rune
  204973, -- Hissing Rune
  210247, -- Vantus Rune: Amirdrassil, the Dream's Hope
  210248, -- Vantus Rune: Amirdrassil, the Dream's Hope
  210249, -- Vantus Rune: Amirdrassil, the Dream's Hope
}

-- Statues
database["Statues"] = {
  193007, -- Narcissist's Sculpture
  193008, -- Narcissist's Sculpture
  193009, -- Narcissist's Sculpture
  193011, -- Revitalizing Red Carving
  193012, -- Revitalizing Red Carving
  193013, -- Revitalizing Red Carving
  193015, -- Statue of Tyr's Herald
  193016, -- Statue of Tyr's Herald
  193017, -- Statue of Tyr's Herald
  193019, -- Djaradin's Pinata
  193020, -- Djaradin's Pinata
  193021, -- Djaradin's Pinata
  194723, -- Kalu'ak Figurine
  194724, -- Kalu'ak Figurine
  194725, -- Kalu'ak Figurine
}

-- Tools
database["Tools"] = {
  191256, -- Serevite Skeleton Key
  191304, -- Sturdy Expedition Shovel
  193470, -- Feral Hide Drums
  195580, -- Suspicious Bottle
  198250, -- Convincingly Realistic Jumper Cables
  198251, -- Convincingly Realistic Jumper Cables
  198252, -- Convincingly Realistic Jumper Cables
  198275, -- S.A.V.I.O.R.
  198276, -- S.A.V.I.O.R.
  198277, -- S.A.V.I.O.R.
  198442, -- Bogthwottle's Shrinky-Do
  198836, -- Arclight Vital Correctors
  200121, -- Potion of Beginner's Luck
  201427, -- Fleeting Sands
  201428, -- Quicksilver Sands
  201436, -- Temporally-Locked Sands
  201438, -- Weary Sands
}

-- Awakened Elementals
database["AwakenedElementals"] = {
  190316, -- Awakened Earth
  190321, -- Awakened Fire
  190324, -- Awakened Order
  190327, -- Awakened Air
  190329, -- Awakened Frost
  190331, -- Awakened Decay
  190450, -- Awakened Ire
}

-- Rousing Elementals
database["RousingElementals"] = {
  190315, -- Rousing Earth
  190320, -- Rousing Fire
  190322, -- Rousing Order
  190326, -- Rousing Air
  190328, -- Rousing Frost
  190330, -- Rousing Decay
  190451, -- Rousing Ire
}

-- Cavern Currencies
database["CavernCurrencies"] = {
  202171, -- Obsidian Flightstone
  204715, -- Unearthed Fragrant Coin
  204985, -- Barter Brick
  205188, -- Barter Boulder
  205247, -- Clinking Dirt-Covered Pouch
  205248, -- Clanging Dirt-Covered Pouch
  205452, -- Ponzo's Cream
  205962, -- Echoing Storm Flightstone
  205982, -- Lost Dig Map
  205984, -- Bartered Dig Map
  206037, -- Ruby Flightstone
}

-- Fyrak Assault
database["FyrakAssault"] = {
  203430, -- Ward of Igira
  203683, -- Ward of Fyrakk
  203710, -- Everburning Key
}

-- Shadowflame Crests
database["ShadowflameCrests"] = {
  204075, -- Whelpling's Shadowflame Crest Fragment
  204076, -- Drake's Shadowflame Crest Fragment
  204077, -- Wyrm's Shadowflame Crest Fragment
  204078, -- Aspect's Shadowflame Crest Fragment
  204193, -- Whelpling's Shadowflame Crest
  204194, -- Aspect's Shadowflame Crest
  204195, -- Drake's Shadowflame Crest
  204196, -- Wyrm's Shadowflame Crest
  205423, -- Shadowflame Residue Sack
  205682, -- Large Shadowflame Residue Sack
}

-- Artifacts
database["Artifacts"] = {
  202854, -- Wondrous Fish
  202870, -- Mysterious Writings
  202871, -- Draconic Artifact
  202872, -- Token of Blessing
}

-- Artisan Curious
database["ArtisanCurious"] = {
  203398, -- Dampening Powder
  203399, -- Damaged Trident
  203400, -- Lackluster Spices
  203401, -- Dull Crystal
  203402, -- Broken Gnomish Voicebox
  203403, -- Hastily Scrawled Rune
  203404, -- Crystal Fork
  203405, -- Pristine Pelt
  203406, -- Torn Morqut Kite
  203407, -- Draconic Suppression Powder
  203408, -- Ancient Ceremonial Trident
  203409, -- Sparkling Spice Pouch
  203410, -- Glowing Crystal Bookmark
  203411, -- Gnomish Voicebox
  203412, -- Arcane Dispelling Rune
  203413, -- Crystal Tuning Fork
  203414, -- Reinforced Pristine Leather
  203415, -- Traditional Morqut Kite
  203416, -- Dormant Lifebloom Seeds
  203417, -- Razor-Sharp Animal Bone
  203418, -- Amplified Quaking Stone
  203419, -- Elusive Croaking Crab
}

-- Leftover Elemental Slime
database["LeftoverElementalSlime"] = {
  204352, -- Leftover Elemental Slime
}

-- Mossy Mammoth
database["MossyMammoth"] = {
  192790, -- Mossy Mammoth
  204360, -- Strange Petrified Orb
  204363, -- Particularly Ordinary Egg
  204364, -- Magically Altered Egg
  204366, -- Egg of Unknown Contents
  204367, -- Sleeping Ancient Mammoth
  204369, -- Scrap of Black Dragonscales
  204371, -- Drop of Blue Dragon Magic
  204372, -- Speck of Bronze Dust
  204374, -- Emerald Dragon Brooch
  204375, -- Everburning Ruby Coals
}

-- Primordial Stones & Onyx Annulet
database["PrimordialStonesOnyxAnnulet"] = {
  203460, -- Onyx Annulet
  203702, -- Experimental Melder
  203703, -- Prismatic Fragment
  204000, -- Storm Infused Stone
  204001, -- Echoing Thunder Stone
  204002, -- Flame Licked Stone
  204003, -- Raging Magma Stone
  204004, -- Searing Smokey Stone
  204005, -- Entropic Fel Stone
  204006, -- Indomitable Earth Stone
  204007, -- Shining Obsidian Stone
  204009, -- Gleaming Iron Stone
  204010, -- Deluging Water Stone
  204011, -- Freezing Ice Stone
  204012, -- Cold Frost Stone
  204013, -- Exuding Steam Stone
  204014, -- Sparkling Mana Stone
  204015, -- Swirling Mojo Stone
  204018, -- Humming Arcane Stone
  204019, -- Harmonic Music Stone
  204020, -- Wild Spirit Stone
  204021, -- Necromantic Death Stone
  204022, -- Pestilent Plague Stone
  204025, -- Obscure Pastel Stone
  204027, -- Desirous Blood Stone
  204029, -- Prophetic Twilight Stone
  204030, -- Wind Sculpted Stone
  204215, -- Dormant Primordial Fragment
  204217, -- Unstable Elementium
  204573, -- Condensed Fire Magic
  204574, -- Condensed Frost Magic
  204575, -- Condensed Earth Magic
  204576, -- Condensed Shadow Magic
  204577, -- Condensed Nature Magic
  204578, -- Condensed Arcane Magic
  204579, -- Condensed Necromantic Magic
}

-- Zskera Vault
database["ZskeraVault"] = {
  202196, -- Zskera Vault Key
  203690, -- Pearlescent Bubble Key
  203701, -- Neltharion Gift Token
  203704, -- Stone Dissolver
  203705, -- Empty Obsidian Vial
  203715, -- Oozing Gold
  203718, -- Vial of Flames
  203720, -- Restorative Water
  204199, -- Ley-Infused Crystal
  204278, -- Neltharion's Toolkit
  204439, -- Research Chest Key
  204802, -- Scroll of Teleport: Zskera Vaults
}

-- Embellishments
database["Embellishments"] = {
  191250, -- Armor Spikes
  191532, -- Potion Absorption Inhibitor
  191533, -- Potion Absorption Inhibitor
  191534, -- Potion Absorption Inhibitor
  191535, -- zzOldAlchemical Flavor Pocket
  191536, -- zzOldAlchemical Flavor Pocket
  191537, -- zzOldAlchemical Flavor Pocket
  191872, -- Armor Spikes
  191873, -- Armor Spikes
  193468, -- Fang Adornments
  193469, -- Toxified Armor Patch
  193551, -- Fang Adornments
  193552, -- Toxified Armor Patch
  193554, -- Fang Adornments
  193555, -- Toxified Armor Patch
  193941, -- Bronzed Grip Wrappings
  193942, -- Bronzed Grip Wrappings
  193943, -- Bronzed Grip Wrappings
  193944, -- Blue Silken Lining
  193945, -- Blue Silken Lining
  193946, -- Blue Silken Lining
  198256, -- Magazine of Healing Darts
  198257, -- Magazine of Healing Darts
  198258, -- Magazine of Healing Darts
  200652, -- Alchemical Flavor Pocket
  203652, -- Griftah's All-Purpose Embellishing Powder
  204708, -- Shadowflame-Tempered Armor Patch
  204709, -- Shadowflame-Tempered Armor Patch
  204710, -- Shadowflame-Tempered Armor Patch
  204909, -- Statuette of Foreseen Power
  205012, -- Reserve Parachute
  205115, -- Statuette of Foreseen Power
  205170, -- Statuette of Foreseen Power
  205171, -- Figurine of the Gathering Storm
  205172, -- Figurine of the Gathering Storm
  205173, -- Figurine of the Gathering Storm
  205411, -- Medical Wrap Kit
}

-- General Crafting Reagents
database["GeneralCraftingReagents"] = {
  190456, -- Artisan's Mettle
  191493, -- Primal Convergent
  191494, -- Primal Convergent
  191495, -- Primal Convergent
  191496, -- Omnium Draconis
  191497, -- Omnium Draconis
  191498, -- Omnium Draconis
  191529, -- Illustrious Insight
  200860, -- Draconic Stopper
  201399, -- Primal Bear Spine
  201400, -- Aquatic Maw
  201401, -- Iridescent Plume
  201402, -- Large Sturdy Femur
  201403, -- Mastodon Tusk
  201404, -- Tallstrider Sinew
  201405, -- Tuft of Primal Wool
  201406, -- Glowing Titan Orb
}

-- Item Level Upgrades
database["ItemLevelUpgrades"] = {
  190453, -- Spark of Ingenuity
  190455, -- Concentrated Primal Focus
  197921, -- Primal Infusion
  198046, -- Concentrated Primal Infusion
  198048, -- Titan Training Matrix I
  198056, -- Titan Training Matrix II
  198058, -- Titan Training Matrix III
  198059, -- Titan Training Matrix IV
  200686, -- Primal Focus
  204440, -- Spark of Shadowflame
  204673, -- Titan Training Matrix V
  204681, -- Enchanted Whelpling's Shadowflame Crest
  204682, -- Enchanted Wyrm's Shadowflame Crest
  204697, -- Enchanted Aspect's Shadowflame Crest
  204717, -- Splintered Spark of Shadowflame
  206959, -- Spark of Dreams
  208396, -- Splintered Spark of Dreams
}

-- Profession Gear
database["ProfessionGear"] = {
  191223, -- Khaz'gorite Pickaxe
  191224, -- Khaz'gorite Sickle
  191225, -- Khaz'gorite Skinning Knife
  191226, -- Khaz'gorite Needle Set
  191227, -- Khaz'gorite Leatherworker's Knife
  191228, -- Black Dragon Touched Hammer
  191229, -- Khaz'gorite Leatherworker's Toolset
  191230, -- Khaz'gorite Blacksmith's Toolbox
  191231, -- Alchemist's Brilliant Mixing Rod
  191232, -- Chef's Splendid Rolling Pin
  191233, -- Chef's Smooth Rolling Pin
  191234, -- Alchemist's Sturdy Mixing Rod
  191235, -- Draconium Blacksmith's Toolbox
  191236, -- Draconium Leatherworker's Toolset
  191237, -- Draconium Blacksmith's Hammer
  191238, -- Draconium Leatherworker's Knife
  191239, -- Draconium Needle Set
  191240, -- Draconium Skinning Knife
  191241, -- Draconium Sickle
  191242, -- Draconium Pickaxe
  191888, -- Khaz'gorite Blacksmith's Hammer
  193035, -- Bold-Print Bifocals
  193036, -- Left-Handed Magnifying Glass
  193037, -- Sundered Onyx Loupe
  193038, -- Chromatic Focus
  193039, -- Fine-Print Trifocals
  193040, -- Magnificent Margin Magnifier
  193041, -- Alexstraszite Loupes
  193042, -- Resonant Focus
  193479, -- Floral Basket
  193480, -- Durable Pack
  193482, -- Skinner's Cap
  193485, -- Protective Gloves
  193486, -- Resilient Smock
  193487, -- Alchemist's Hat
  193488, -- Lavish Floral Pack
  193489, -- Reinforced Pack
  193490, -- Expert Skinner's Cap
  193491, -- Shockproof Gloves
  193492, -- Masterwork Smock
  193493, -- Expert Alchemist's Hat
  193528, -- Wildercloth Alchemist's Robe
  193529, -- Wildercloth Fishing Cap
  193533, -- Master's Wildercloth Enchanter's Hat
  193534, -- Wildercloth Chef's Hat
  193538, -- Wildercloth Gardening Hat
  193539, -- Wildercloth Enchanter's Hat
  193540, -- Dragoncloth Tailoring Vestments
  193541, -- Wildercloth Tailor's Coat
  193542, -- Master's Wildercloth Gardening Hat
  193543, -- Master's Wildercloth Fishing Cap
  193544, -- Master's Wildercloth Alchemist's Robe
  193545, -- Master's Wildercloth Chef's Hat
  193612, -- Smithing Apron
  193613, -- Flameproof Apron
  193615, -- Jeweler's Cover
  193616, -- Resplendent Cover
  194125, -- Spring-Loaded Draconium Fabric Cutters
  194126, -- Spring-Loaded Khaz'gorite Fabric Cutters
  194874, -- Scribe's Fastened Quill
  194875, -- Scribe's Resplendent Quill
  198204, -- Draconium Brainwave Amplifier
  198205, -- Khaz'gorite Brainwave Amplifier
  198225, -- Draconium Fisherfriend
  198226, -- Khaz'gorite Fisherfriend
  198234, -- Lapidary's Draconium Clamps
  198235, -- Lapidary's Khaz'gorite Clamps
  198243, -- Draconium Delver's Helmet
  198244, -- Khaz'gorite Delver's Helmet
  198245, -- Draconium Encased Samophlange
  198246, -- Khaz'gorite Encased Samophlange
  198262, -- Bottomless Stonecrust Ore Satchel
  198263, -- Bottomless Mireslush Ore Satchel
  198715, -- Runed Draconium Rod
  198716, -- Runed Khaz'gorite Rod
  201601, -- Runed Serevite Rod
}

-- Profession Knowledge
database["ProfessionKnowledge"] = {
  191784, -- Dragon Shard of Knowledge
  192130, -- Sundered Flame Weapon Mold
  192131, -- Valdrakken Weapon Chain
  192132, -- Draconium Blade Sharpener
  192443, -- Element-Infused Rocket Helmet
  193891, -- Experimental Substance
  193897, -- Reawakened Catalyst
  193898, -- Umbral Bone Needle
  193899, -- Primalweave Spindle
  193900, -- Prismatic Focusing Shard
  193901, -- Primal Dust
  193902, -- Eroded Titan Gizmo
  193903, -- Watcher Power Core
  193904, -- Phoenix Feather Quill
  193905, -- Iskaaran Trading Ledger
  193907, -- Chipped Tyrstone
  193909, -- Ancient Gem Fragments
  193910, -- Molted Dragon Scales
  193913, -- Preserved Animal Parts
  194039, -- Heated Ore Sample
  194040, -- Slateskin Hide
  194041, -- Driftbloom Sprout
  194042, -- Explorer's Banner of Herbology
  194043, -- Explorer's Banner of Herbology
  194044, -- Explorer's Banner of Herbology
  194045, -- Explorer's Banner of Geology
  194046, -- Explorer's Banner of Geology
  194047, -- Explorer's Banner of Geology
  194054, -- Dredged Seedling
  194055, -- Primordial Soil
  194061, -- Suffocating Spores
  194062, -- Unyielding Stone Chunk
  194063, -- Glowing Fragment
  194064, -- Intricate Geode
  194066, -- Frigid Frostfur Pelt
  194067, -- Festering Carcass
  194068, -- Progenitor Scales
  194076, -- Exotic Resilient Leather
  194077, -- Pristine Adamant Scales
  194078, -- Perfect Draconium Scale
  194079, -- Pure Serevite Nugget
  194080, -- Peculiar Bud
  194081, -- Mutated Root
  194697, -- Draconic Treatise on Alchemy
  194698, -- Draconic Treatise on Tailoring
  194699, -- Draconic Treatise on Inscription
  194700, -- Draconic Treatise on Leatherworking
  194702, -- Draconic Treatise on Enchanting
  194703, -- Draconic Treatise on Jewelcrafting
  194704, -- Draconic Treatise on Herbalism
  194708, -- Draconic Treatise on Mining
  198156, -- Wyrmhole Generator
  198454, -- Draconic Treatise on Blacksmithing
  198510, -- Draconic Treatise on Engineering
  198518, -- Professor Instructaur's Top Secret Guide to Blacksmithing
  198519, -- Professor Instructaur's Top Secret Guide to Alchemy
  198520, -- Professor Instructaur's Top Secret Guide to Enchanting
  198521, -- Professor Instructaur's Top Secret Guide to Engineering
  198522, -- Professor Instructaur's Top Secret Guide to Herbalism
  198523, -- Professor Instructaur's Top Secret Guide to Inscription
  198524, -- Professor Instructaur's Top Secret Guide to Jewelcrafting
  198525, -- Professor Instructaur's Top Secret Guide to Leatherworking
  198526, -- Professor Instructaur's Top Secret Guide to Mining
  198527, -- Professor Instructaur's Top Secret Guide to Skinning
  198528, -- Professor Instructaur's Top Secret Guide to Tailoring
  198599, -- Experimental Decay Sample
  198606, -- Blacksmith's Writ
  198607, -- Scribe's Glyphs
  198608, -- Alchemy Notes
  198609, -- Tailoring Examples
  198610, -- Enchanter's Script
  198611, -- Engineering Details
  198612, -- Jeweler's Cuts
  198613, -- Leatherworking Designs
  198656, -- Painter's Pretty Jewel
  198658, -- Decay-Infused Tanning Oil
  198659, -- Forgetful Apprentice's Tome
  198660, -- Fragmented Key
  198662, -- Intriguing Bolt of Blue Cloth
  198663, -- Frostforged Potion
  198664, -- Crystalline Overgrowth
  198667, -- Spare Djaradin Tools
  198669, -- How to Train Your Whelpling
  198670, -- Lofty Malygite
  198675, -- Lava-Infused Seed
  198680, -- Decaying Brackenhide Blanket
  198682, -- Alexstraszite Cluster
  198683, -- Treated Hides
  198684, -- Miniature Bronze Dragonflight Banner
  198685, -- Well Insulated Mug
  198686, -- Frosted Parchment
  198687, -- Closely Guarded Shiny
  198689, -- Stormbound Horn
  198690, -- Decayed Scales
  198692, -- Noteworthy Scrap of Carpet
  198693, -- Dusty Darkmoon Card
  198694, -- Enriched Earthen Shard
  198696, -- Wind-Blessed Hide
  198697, -- Contraband Concoction
  198699, -- Mysterious Banner
  198702, -- Itinerant Singed Fabric
  198703, -- Sign Language Reference Sheet
  198704, -- Pulsing Earth Rune
  198710, -- Canteen of Suspicious Water
  198711, -- Poacher's Pack
  198712, -- Firewater Powder Sample
  198789, -- Intact Coil Capacitor
  198798, -- Flashfrozen Scroll
  198799, -- Forgotten Arcane Tome
  198800, -- Fractured Titanic Sphere
  198837, -- Curious Hide Scraps
  198841, -- Large Sample of Curious Hide
  198963, -- Decaying Phlegm
  198964, -- Elementious Splinter
  198965, -- Primeval Earth Fragment
  198966, -- Molten Globule
  198967, -- Primordial Aether
  198968, -- Primalist Charm
  198969, -- Keeper's Mark
  198970, -- Infinitely Attachable Pair o' Docks
  198971, -- Curious Djaradin Rune
  198972, -- Draconic Glamour
  198973, -- Incandescent Curio
  198974, -- Elegantly Engraved Embellishment
  198975, -- Ossified Hide
  198976, -- Exceedingly Soft Skin
  198977, -- Ohn'arhan Weave
  198978, -- Stupidly Effective Stitchery
  199115, -- Herbalism Field Notes
  199122, -- Mining Field Notes
  199128, -- Skinning Field Notes
  200677, -- Dreambloom Petal
  200678, -- Dreambloom
  200939, -- Chromatic Pocketwatch
  200940, -- Everflowing Inkwell
  200941, -- Seal of Order
  200942, -- Vibrant Emulsion
  200943, -- Whispering Band
  200945, -- Valiant Hammer
  200946, -- Thunderous Blade
  200947, -- Carving of Awakening
  200972, -- Dusty Blacksmith's Diagrams
  200973, -- Dusty Scribe's Runic Drawings
  200974, -- Dusty Alchemist's Research
  200975, -- Dusty Tailor's Diagrams
  200976, -- Dusty Enchanter's Research
  200977, -- Dusty Engineer's Scribblings
  200978, -- Dusty Jeweler's Illustrations
  200979, -- Dusty Leatherworker's Diagrams
  200980, -- Dusty Herbalist's Notes
  200981, -- Dusty Miner's Notes
  200982, -- Dusty Skinner's Notes
  201003, -- Furry Gloop
  201004, -- Ancient Spear Shards
  201005, -- Curious Ingots
  201006, -- Draconic Flux
  201007, -- Ancient Monument
  201008, -- Molten Ingot
  201009, -- Falconer Gauntlet Drawings
  201010, -- Qalashi Weapon Diagram
  201011, -- Spelltouched Tongs
  201012, -- Enchanted Debris
  201013, -- Faintly Enchanted Remains
  201014, -- Boomthyr Rocket
  201015, -- Counterfeit Darkmoon Deck
  201016, -- Harmonic Crystal Harmonizer
  201017, -- Igneous Gem
  201018, -- Well-Danced Drum
  201019, -- Ancient Dragonweave Bolt
  201020, -- Silky Surprise
  201023, -- Draconic Treatise on Skinning
  201268, -- Rare Blacksmith's Diagrams
  201269, -- Rare Scribe's Runic Drawings
  201270, -- Rare Alchemist's Research
  201271, -- Rare Tailor's Diagrams
  201272, -- Rare Enchanter's Research
  201273, -- Rare Engineer's Scribblings
  201274, -- Rare Jeweler's Illustrations
  201275, -- Rare Leatherworker's Diagrams
  201276, -- Rare Herbalist's Notes
  201277, -- Rare Miner's Notes
  201278, -- Rare Skinner's Notes
  201279, -- Ancient Blacksmith's Diagrams
  201280, -- Ancient Scribe's Runic Drawings
  201281, -- Ancient Alchemist's Research
  201282, -- Ancient Tailor's Diagrams
  201283, -- Ancient Enchanter's Research
  201284, -- Ancient Engineer's Scribblings
  201285, -- Ancient Jeweler's Illustrations
  201286, -- Ancient Leatherworker's Diagrams
  201287, -- Ancient Herbalist's Notes
  201288, -- Ancient Miner's Notes
  201289, -- Ancient Skinner's Notes
  201300, -- Iridescent Ore Fragments
  201301, -- Iridescent Ore
  201356, -- Glimmer of Fire
  201357, -- Glimmer of Frost
  201358, -- Glimmer of Air
  201359, -- Glimmer of Earth
  201360, -- Glimmer of Order
  201700, -- Notebook of Crafting Knowledge
  201705, -- Notebook of Crafting Knowledge
  201706, -- Notebook of Crafting Knowledge
  201708, -- Notebook of Crafting Knowledge
  201709, -- Notebook of Crafting Knowledge
  201710, -- Notebook of Crafting Knowledge
  201711, -- Notebook of Crafting Knowledge
  201712, -- Notebook of Crafting Knowledge
  201713, -- Notebook of Crafting Knowledge
  201714, -- Notebook of Crafting Knowledge
  201715, -- Notebook of Crafting Knowledge
  201716, -- Notebook of Crafting Knowledge
  201717, -- Notebook of Crafting Knowledge
  201718, -- Notebook of Crafting Knowledge
  202011, -- Elementally-Charged Stone
  202014, -- Infused Pollen
  202016, -- Saturated Bone
  203471, -- Tasty Candy
  204222, -- Conductive Ametrine Shard
  204224, -- Speck of Arcane Awareness
  204225, -- Perfect Windfeather
  204226, -- Blazehoof Ashes
  204227, -- Everflowing Antifreeze
  204228, -- Undigested Hochenblume Petal
  204229, -- Glimmering Rune of Arcantrix
  204230, -- Dense Seaforged Javelin
  204231, -- Kingly Sheepskin Pelt
  204232, -- Slyvern Alpha Claw
  204469, -- Misplaced Aberrus Outflow Blueprints
  204470, -- Haphazardly Discarded Bomb
  204471, -- Defective Survival Pack
  204475, -- Busted Wyrmhole Generator
  204480, -- Inconspicuous Data Miner
  204632, -- Tectonic Rock Fragment
  204850, -- Handful of Khaz'gorite Bolts
  204853, -- Discarded Dracothyst Drill
  204855, -- Overclocked Determination Core
  204986, -- Flame-Infused Scale Oil
  204987, -- Lava-Forged Leatherworker's "Knife"
  204988, -- Sulfur-Soaked Skins
  204990, -- Lava-Drenched Shadow Crystal
  204999, -- Shimmering Aqueous Orb
  205001, -- Resonating Arcane Crystal
  205211, -- Nutrient Diluted Protofluid
  205212, -- Marrow-Ripened Slime
  205213, -- Suspicious Mold
  205214, -- Snubbed Snail Shells
  205216, -- Gently Jostled Jewels
  205219, -- Broken Barter Boulder
  205348, -- Niffen Notebook of Jewelcrafting Knowledge
  205349, -- Niffen Notebook of Engineering Knowledge
  205350, -- Niffen Notebook of Leatherworking Knowledge
  205351, -- Niffen Notebook of Enchanting Knowledge
  205352, -- Niffen Notebook of Blacksmithing Knowledge
  205353, -- Niffen Notebook of Alchemy Knowledge
  205354, -- Niffen Notebook of Inscription Knowledge
  205355, -- Niffen Notebook of Tailoring Knowledge
  205356, -- Niffen Notebook of Mining Knowledge
  205357, -- Niffen Notebook of Skinning Knowledge
  205358, -- Niffen Notebook of Herbalism Knowledge
  205424, -- Bartered Jewelcrafting Notes
  205425, -- Bartered Engineering Notes
  205426, -- Bartered Leatherworking Notes
  205427, -- Bartered Enchanting Notes
  205428, -- Bartered Blacksmithing Notes
  205429, -- Bartered Alchemy Notes
  205430, -- Bartered Inscription Notes
  205431, -- Bartered Tailoring Notes
  205432, -- Bartered Mining Notes
  205433, -- Bartered Skinning Notes
  205434, -- Bartered Herbalism Notes
  205435, -- Bartered Jewelcrafting Journal
  205436, -- Bartered Engineering Journal
  205437, -- Bartered Leatherworking Journal
  205438, -- Bartered Enchanting Journal
  205439, -- Bartered Blacksmithing Journal
  205440, -- Bartered Alchemy Journal
  205441, -- Bartered Inscription Journal
  205442, -- Bartered Tailoring Journal
  205443, -- Bartered Mining Journal
  205444, -- Bartered Skinning Journal
  205445, -- Bartered Herbalism Journal
  205451, -- Flawless Crystal Scale
  205986, -- Well-Worn Kiln
  205987, -- Brimstone Rescue Ring
  205988, -- Zaqali Elder Spear
  206019, -- Abandoned Reserve Chute
  206025, -- Used Medical Wrap Kit
  206030, -- Exquisitely Embroidered Banner
  206031, -- Intricate Zaqali Runes
  206034, -- Hissing Rune Draft
  206035, -- Ancient Research
  210184, -- Half-Filled Dreamless Sleep Potion
  210185, -- Splash Potion of Narcolepsy
  210190, -- Blazeroot
  210193, -- Experimental Dreamcatcher
  210194, -- Insomniotron
  210197, -- Unhatched Battery
  210198, -- Depleted Battery
  210200, -- Petrified Hope
  210201, -- Handful of Pebbles
  210202, -- Coalesced Dreamstone
  210208, -- Tuft of Dreamsaber Fur
  210211, -- Molted Faerie Dragon Scales
  210215, -- Dreamtalon Claw
  210228, -- Pure Dream Water
  210231, -- Everburning Core
  210234, -- Essence of Dreams
  210458, -- Winnie's Notes on Flora and Fauna
  210459, -- Grove Keeper's Pillar
  210460, -- Primalist Shadowbinding Rune
  210461, -- Exceedingly Soft Wildercloth
  210462, -- Plush Pillow
  210463, -- Snuggle Buddy
  210464, -- Amirdrassil Defender's Shield
  210465, -- Deathstalker Chassis
  210466, -- Flamesworn Render
}

-- Dreaming Crests
database["DreamingCrests"] = {
  206960, -- Enchanted Wyrm's Dreaming Crest
  206961, -- Enchanted Aspect's Dreaming Crest
  206977, -- Enchanted Whelpling's Dreaming Crest
  208393, -- Nascent Aspect's Dreaming Crest
  208394, -- Nascent Wyrm's Dreaming Crest
  208395, -- Nascent Whelpling's Dreaming Crest
  208568, -- Lesser Verdant Crest of Honor
  208569, -- Verdant Crest of Honor
  208570, -- Greater Verdant Crest of Honor
}

-- Dreamseeds
database["Dreamseeds"] = {
  208047, -- Gigantic Dreamseed
  208066, -- Small Dreamseed
  208067, -- Plump Dreamseed
}

-- Darkmoon Cards
database["DarkmoonCards"] = {
  194785, -- Ace of Fire
  194786, -- Two of Fire
  194787, -- Three of Fire
  194788, -- Four of Fire
  194789, -- Five of Fire
  194790, -- Six of Fire
  194791, -- Seven of Frost
  194792, -- Eight of Fire
  194793, -- Ace of Frost
  194794, -- Two of Frost
  194795, -- Three of Frost
  194796, -- Four of Frost
  194797, -- Five of Frost
  194798, -- Six of Frost
  194799, -- Seven of Fire
  194800, -- Eight of Frost
  194801, -- Ace of Air
  194802, -- Two of Air
  194803, -- Three of Air
  194804, -- Four of Air
  194805, -- Five of Air
  194806, -- Six of Air
  194807, -- Seven of Air
  194808, -- Eight of Air
  194809, -- Ace of Earth
  194810, -- Two of Earth
  194811, -- Three of Earth
  194812, -- Four of Earth
  194813, -- Five of Earth
  194814, -- Six of Earth
  194815, -- Seven of Earth
  194816, -- Eight of Earth
  194827, -- Bundle O' Cards: Dragon Isles
  198614, -- Soggy Clump of Darkmoon Cards
}

-- Drakewatcher Manuscripts
database["DrakewatcherManuscripts"] = {
  192523, -- Renewed Proto-Drake: Green Scales
  196961, -- Cliffside Wylderdrake: Armor
  196962, -- Cliffside Wylderdrake: Silver and Purple Armor
  196963, -- Cliffside Wylderdrake: Silver and Blue Armor
  196964, -- Cliffside Wylderdrake: Gold and Black Armor
  196965, -- Cliffside Wylderdrake: Bronze and Teal Armor
  196966, -- Cliffside Wylderdrake: Gold and Orange Armor
  196967, -- Cliffside Wylderdrake: Gold and White Armor
  196968, -- Cliffside Wylderdrake: Steel and Yellow Armor
  196969, -- Cliffside Wylderdrake: Finned Back
  196970, -- Cliffside Wylderdrake: Spiked Back
  196971, -- Cliffside Wylderdrake: Spiked Brow
  196972, -- Cliffside Wylderdrake: Plated Brow
  196973, -- Cliffside Wylderdrake: Dual Horned Chin
  196974, -- Cliffside Wylderdrake: Four Horned Chin
  196975, -- Cliffside Wylderdrake: Head Fin
  196976, -- Cliffside Wylderdrake: Head Mane
  196977, -- Cliffside Wylderdrake: Split Head Horns
  196978, -- Cliffside Wylderdrake: Small Head Spikes
  196979, -- Cliffside Wylderdrake: Curled Head Horns
  196980, -- Cliffside Wylderdrake: Triple Head Horns
  196981, -- Cliffside Wylderdrake: Conical Head
  196982, -- Cliffside Wylderdrake: Ears
  196983, -- Cliffside Wylderdrake: Maned Jaw
  196984, -- Cliffside Wylderdrake: Finned Jaw
  196985, -- Cliffside Wylderdrake: Horned Jaw
  196986, -- Cliffside Wylderdrake: Black Hair
  196987, -- Cliffside Wylderdrake: Blonde Hair
  196988, -- Cliffside Wylderdrake: Red Hair
  196989, -- Cliffside Wylderdrake: White Hair
  196990, -- Cliffside Wylderdrake: Helm
  196991, -- Cliffside Wylderdrake: Black Horns
  196992, -- Cliffside Wylderdrake: Heavy Horns
  196993, -- Cliffside Wylderdrake: Sleek Horns
  196994, -- Cliffside Wylderdrake: Short Horns
  196995, -- Cliffside Wylderdrake: Spiked Horns
  196996, -- Cliffside Wylderdrake: Branched Horns
  196997, -- Cliffside Wylderdrake: Split Horns
  196998, -- Cliffside Wylderdrake: Hook Horns
  196999, -- Cliffside Wylderdrake: Swept Horns
  197000, -- Cliffside Wylderdrake: Coiled Horns
  197001, -- Cliffside Wylderdrake: Finned Cheek
  197002, -- Cliffside Wylderdrake: Flared Cheek
  197003, -- Cliffside Wylderdrake: Spiked Cheek
  197004, -- Cliffside Wylderdrake: Spiked Legs
  197005, -- Cliffside Wylderdrake: Horned Nose
  197006, -- Cliffside Wylderdrake: Plated Nose
  197007, -- Cliffside Wylderdrake: Wide Stripes Pattern
  197008, -- Cliffside Wylderdrake: Narrow Stripes Pattern
  197009, -- Cliffside Wylderdrake: Scaled Pattern
  197010, -- Cliffside Wylderdrake: Red Scales
  197011, -- Cliffside Wylderdrake: Green Scales
  197012, -- Cliffside Wylderdrake: Blue Scales
  197013, -- Cliffside Wylderdrake: Black Scales
  197014, -- Cliffside Wylderdrake: White Scales
  197015, -- Cliffside Wylderdrake: Dark Skin Variation
  197016, -- Cliffside Wylderdrake: Maned Tail
  197017, -- Cliffside Wylderdrake: Large Tail Spikes
  197018, -- Cliffside Wylderdrake: Finned Tail
  197019, -- Cliffside Wylderdrake: Blunt Spiked Tail
  197020, -- Cliffside Wylderdrake: Spear Tail
  197021, -- Cliffside Wylderdrake: Spiked Club Tail
  197022, -- Cliffside Wylderdrake: Finned Neck
  197023, -- Cliffside Wylderdrake: Maned Neck
  197090, -- Highland Drake: Gold and Black Armor
  197091, -- Highland Drake: Silver and Blue Armor
  197093, -- Highland Drake: Silver and Purple Armor
  197094, -- Highland Drake: Gold and Red Armor
  197095, -- Highland Drake: Gold and White Armor
  197096, -- Highland Drake: Steel and Yellow Armor
  197097, -- Highland Drake: Spined Back
  197098, -- Highland Drake: Finned Back
  197099, -- Highland Drake: Armor
  197100, -- Highland Drake: Crested Brow
  197101, -- Highland Drake: Bushy Brow
  197102, -- Highland Drake: Horned Chin
  197103, -- Highland Drake: Maned Chin
  197104, -- Highland Drake: Tapered Chin
  197105, -- Highland Drake: Spined Chin
  197106, -- Highland Drake: Finned Head
  197107, -- Highland Drake: Triple Finned Head
  197108, -- Highland Drake: Spined Head
  197109, -- Highland Drake: Spiked Head
  197110, -- Highland Drake: Plated Head
  197111, -- Highland Drake: Maned Head
  197112, -- Highland Drake: Single Horned Head
  197113, -- Highland Drake: Swept Spiked Head
  197114, -- Highland Drake: Multi-Horned Head
  197115, -- Highland Drake: Thorned Jaw
  197116, -- Highland Drake: Ears
  197117, -- Highland Drake: Black Hair
  197118, -- Highland Drake: Brown Hair
  197119, -- Highland Drake: Helm
  197120, -- Highland Drake: Ornate Helm
  197121, -- Highland Drake: Tan Horns
  197122, -- Highland Drake: Heavy Horns
  197123, -- Highland Drake: Thorn Horns
  197124, -- Highland Drake: Swept Horns
  197125, -- Highland Drake: Coiled Horns
  197126, -- Highland Drake: Hooked Horns
  197127, -- Highland Drake: Grand Thorn Horns
  197128, -- Highland Drake: Curled Back Horns
  197129, -- Highland Drake: Sleek Horns
  197130, -- Highland Drake: Stag Horns
  197131, -- Highland Drake: Hairy Cheek
  197132, -- Highland Drake: Spiked Cheek
  197133, -- Highland Drake: Spined Cheek
  197134, -- Highland Drake: Spiked Legs
  197135, -- Highland Drake: Toothy Mouth
  197136, -- Highland Drake: Taperered Nose
  197137, -- Highland Drake: Spined Nose
  197138, -- Highland Drake: Striped Pattern
  197139, -- Highland Drake: Large Spotted Pattern
  197140, -- Highland Drake: Small Spotted Pattern
  197141, -- Highland Drake: Scaled Pattern
  197142, -- Highland Drake: Black Scales
  197143, -- Highland Drake: Green Scales
  197144, -- Highland Drake: Red Scales
  197145, -- Highland Drake: Bronze Scales
  197146, -- Highland Drake: White Scales
  197147, -- Highland Drake: Heavy Scales
  197148, -- Highland Drake: Vertical Finned Tail
  197149, -- Highland Drake: Club Tail
  197150, -- Highland Drake: Spiked Club Tail
  197151, -- Highland Drake: Spiked Tail
  197152, -- Highland Drake: Hooked Tail
  197153, -- Highland Drake: Bladed Tail
  197154, -- Highland Drake: Spined Neck
  197155, -- Highland Drake: Finned Neck
  197156, -- Highland Drake: Bronze and Green Armor
  197346, -- Renewed Proto-Drake: Gold and Black Armor
  197347, -- Renewed Proto-Drake: Silver and Blue Armor
  197348, -- Renewed Proto-Drake: Black and Red Armor
  197349, -- Renewed Proto-Drake: Gold and White Armor
  197350, -- Renewed Proto-Drake: Silver and Purple Armor
  197351, -- Renewed Proto-Drake: Gold and Red Armor
  197352, -- Renewed Proto-Drake: Steel and Yellow Armor
  197353, -- Renewed Proto-Drake: Bronze and Pink Armor
  197354, -- Renewed Proto-Drake: Horned Back
  197355, -- Renewed Proto-Drake: Thick Spined Jaw
  197356, -- Renewed Proto-Drake: Hairy Back
  197357, -- Renewed Proto-Drake: Armor
  197358, -- Renewed Proto-Drake: Curved Spiked Brow
  197359, -- Renewed Proto-Drake: Hairy Brow
  197360, -- Renewed Proto-Drake: Spined Brow
  197361, -- Renewed Proto-Drake: Spiked Crest
  197362, -- Renewed Proto-Drake: Spined Crest
  197363, -- Renewed Proto-Drake: Maned Crest
  197364, -- Renewed Proto-Drake: Short Spiked Crest
  197365, -- Renewed Proto-Drake: Finned Crest
  197366, -- Renewed Proto-Drake: Dual Horned Crest
  197367, -- Renewed Proto-Drake: Gray Hair
  197368, -- Renewed Proto-Drake: Blue Hair
  197369, -- Renewed Proto-Drake: Brown Hair
  197370, -- Renewed Proto-Drake: Red Hair
  197371, -- Renewed Proto-Drake: Green Hair
  197372, -- Renewed Proto-Drake: Purple Hair
  197373, -- Renewed Proto-Drake: Helm
  197374, -- Renewed Proto-Drake: Swept Horns
  197375, -- Renewed Proto-Drake: Curled Horns
  197376, -- Renewed Proto-Drake: Ears
  197377, -- Renewed Proto-Drake: Bovine Horns
  197378, -- Renewed Proto-Drake: Subtle Horns
  197379, -- Renewed Proto-Drake: Impaler Horns
  197380, -- Renewed Proto-Drake: Curved Horns
  197381, -- Renewed Proto-Drake: Gradient Horns
  197382, -- Renewed Proto-Drake: White Horns
  197383, -- Renewed Proto-Drake: Heavy Horns
  197384, -- Renewed Proto-Drake: Thick Spined Jaw
  197385, -- Renewed Proto-Drake: Horned Jaw
  197386, -- Renewed Proto-Drake: Spiked Jaw
  197387, -- Renewed Proto-Drake: Thin Spined Jaw
  197388, -- Renewed Proto-Drake: Finned Jaw
  197389, -- Renewed Proto-Drake: Green Scales
  197390, -- Renewed Proto-Drake: Blue Scales
  197391, -- Renewed Proto-Drake: Bronze Scales
  197392, -- Renewed Proto-Drake: Black Scales
  197393, -- Renewed Proto-Drake: White Scales
  197394, -- Renewed Proto-Drake: Predator Pattern
  197395, -- Renewed Proto-Drake: Harrier Pattern
  197396, -- Renewed Proto-Drake: Skyterror Pattern
  197397, -- Renewed Proto-Drake: Heavy Scales
  197398, -- Renewed Proto-Drake: Snub Snout
  197399, -- Renewed Proto-Drake: Razor Snout
  197400, -- Renewed Proto-Drake: Shark Snout
  197401, -- Renewed Proto-Drake: Beaked Snout
  197402, -- Renewed Proto-Drake: Spiked Club Tail
  197403, -- Renewed Proto-Drake: Club Tail
  197404, -- Renewed Proto-Drake: Finned Tail
  197405, -- Renewed Proto-Drake: Maned Tail
  197406, -- Renewed Proto-Drake: Spined Tail
  197407, -- Renewed Proto-Drake: Spiked Throat
  197408, -- Renewed Proto-Drake: Finned Throat
  197577, -- Windborne Velocidrake: Bronze and Green Armor
  197578, -- Windborne Velocidrake: Silver and Blue Armor
  197579, -- Windborne Velocidrake: Steel and Orange Armor
  197580, -- Windborne Velocidrake: Gold and Red Armor
  197581, -- Windborne Velocidrake: Silver and Purple Armor
  197582, -- Windborne Velocidrake: White and Pink Armor
  197583, -- Windborne Velocidrake: Exposed Finned Back
  197584, -- Windborne Velocidrake: Finned Back
  197585, -- Windborne Velocidrake: Maned Back
  197586, -- Windborne Velocidrake: Spiked Back
  197587, -- Windborne Velocidrake: Feathered Back
  197588, -- Windborne Velocidrake: Armor
  197589, -- Windborne Velocidrake: Large Head Fin
  197590, -- Windborne Velocidrake: Small Head Fin
  197591, -- Windborne Velocidrake: Hairy Head
  197592, -- Windborne Velocidrake: Spined Head
  197593, -- Windborne Velocidrake: Feathery Head
  197594, -- Windborne Velocidrake: Small Ears
  197595, -- Windborne Velocidrake: Finned Ears
  197596, -- Windborne Velocidrake: Horned Jaw
  197597, -- Windborne Velocidrake: Black Fur
  197598, -- Windborne Velocidrake: Gray Hair
  197599, -- Windborne Velocidrake: Red Hair
  197600, -- Windborne Velocidrake: Helm
  197601, -- Windborne Velocidrake: Wavy Horns
  197602, -- Windborne Velocidrake: Cluster Horns
  197603, -- Windborne Velocidrake: Curved Horns
  197604, -- Windborne Velocidrake: Ox Horns
  197605, -- Windborne Velocidrake: Curled Horns
  197606, -- Windborne Velocidrake: Swept Horns
  197607, -- Windborne Velocidrake: Split Horns
  197608, -- Windborne Velocidrake: Gray Horns
  197609, -- Windborne Velocidrake: White Horns
  197610, -- Windborne Velocidrake: Yellow Horns
  197611, -- Windborne Velocidrake: Black Scales
  197612, -- Windborne Velocidrake: Blue Scales
  197613, -- Windborne Velocidrake: Bronze Scales
  197614, -- Windborne Velocidrake: Red Scales
  197615, -- Windborne Velocidrake: Teal Scales
  197616, -- Windborne Velocidrake: White Scales
  197617, -- Windborne Velocidrake: Heavy Scales
  197618, -- Windborne Velocidrake: Long Snout
  197619, -- Windborne Velocidrake: Hooked Snout
  197620, -- Windborne Velocidrake: Beaked Snout
  197621, -- Windborne Velocidrake: Exposed Finned Tail
  197622, -- Windborne Velocidrake: Finned Tail
  197623, -- Windborne Velocidrake: Spiked Tail
  197624, -- Windborne Velocidrake: Club Tail
  197625, -- Windborne Velocidrake: Feathery Tail
  197626, -- Windborne Velocidrake: Exposed Finned Neck
  197627, -- Windborne Velocidrake: Finned Neck
  197628, -- Windborne Velocidrake: Plated Neck
  197629, -- Windborne Velocidrake: Spiked Neck
  197630, -- Windborne Velocidrake: Feathered Neck
  197634, -- Windborne Velocidrake: Windswept Pattern
  197635, -- Windborne Velocidrake: Reaver Pattern
  197636, -- Windborne Velocidrake: Shrieker Pattern
  199074, -- Studies of Arcane Magic
  201790, -- Renewed Proto-Drake: Embodiment of the Storm-Eater
  201792, -- Highland Drake: Embodiment of the Crimson Gladiator
  202273, -- Renewed Proto-Drake: Stubby Snout
  202274, -- Renewed Proto-Drake: Plated Brow
  202275, -- Renewed Proto-Drake: Plated Jaw
  202277, -- Renewed Proto-Drake: Bruiser Horns
  202278, -- Renewed Proto-Drake: Antlers
  202279, -- Renewed Proto-Drake: Malevolent Horns
  202280, -- Renewed Proto-Drake: Pronged Tail
  203299, -- Winding Slitherdrake: Green and Bronze Armor
  203300, -- Winding Slitherdrake: Blue and Silver Armor
  203303, -- Winding Slitherdrake: Red and Gold Armor
  203304, -- Winding Slitherdrake: Yellow and Silver Armor
  203306, -- Winding Slitherdrake: Horned Brow
  203307, -- Winding Slitherdrake: Plated Brow
  203308, -- Winding Slitherdrake: Hairy Brow
  203309, -- Winding Slitherdrake: Long Chin Horn
  203310, -- Winding Slitherdrake: Grand Chin Thorn
  203311, -- Winding Slitherdrake: Hairy Chin
  203312, -- Winding Slitherdrake: Cluster Chin Horn
  203313, -- Winding Slitherdrake: Spiked Chin
  203314, -- Winding Slitherdrake: Curved Chin Horn
  203315, -- Winding Slitherdrake: Small Spiked Crest
  203316, -- Winding Slitherdrake: Large Finned Crest
  203317, -- Winding Slitherdrake: Small Finned Crest
  203318, -- Winding Slitherdrake: Hairy Crest
  203319, -- Winding Slitherdrake: Finned Cheek
  203320, -- Winding Slitherdrake: Ears
  203321, -- Winding Slitherdrake: Curled Cheek Horn
  203322, -- Winding Slitherdrake: Blonde Hair
  203323, -- Winding Slitherdrake: Brown Hair
  203324, -- Winding Slitherdrake: White Hair
  203325, -- Winding Slitherdrake: Red Hair
  203327, -- Winding Slitherdrake: Tan Horns
  203328, -- Winding Slitherdrake: White Horns
  203329, -- Winding Slitherdrake: Heavy Horns
  203330, -- Winding Slitherdrake: Swept Horns
  203331, -- Winding Slitherdrake: Cluster Horns
  203332, -- Winding Slitherdrake: Spiked Horns
  203333, -- Winding Slitherdrake: Short Horns
  203334, -- Winding Slitherdrake: Curled Horns
  203335, -- Winding Slitherdrake: Curved Horns
  203336, -- Winding Slitherdrake: Paired Horns
  203337, -- Winding Slitherdrake: Thorn Horns
  203338, -- Winding Slitherdrake: Antler Horns
  203339, -- Winding Slitherdrake: Impaler Horns
  203340, -- Winding Slitherdrake: Cluster Jaw Horns
  203341, -- Winding Slitherdrake: Long Jaw Horns
  203342, -- Winding Slitherdrake: Triple Jaw Horns
  203343, -- Winding Slitherdrake: Hairy Jaw
  203344, -- Winding Slitherdrake: Single Jaw Horn
  203345, -- Winding Slitherdrake: Split Jaw Horns
  203346, -- Winding Slitherdrake: Curled Nose
  203347, -- Winding Slitherdrake: Large Spiked Nose
  203348, -- Winding Slitherdrake: Pointed Nose
  203349, -- Winding Slitherdrake: Curved Nose Horn
  203350, -- Winding Slitherdrake: Blue Scales
  203351, -- Winding Slitherdrake: Bronze Scales
  203352, -- Winding Slitherdrake: Green Scales
  203353, -- Winding Slitherdrake: Red Scales
  203354, -- Winding Slitherdrake: White Scales
  203355, -- Winding Slitherdrake: Yellow Scales
  203357, -- Winding Slitherdrake: Spiked Tail
  203358, -- Winding Slitherdrake: Small Finned Tail
  203359, -- Winding Slitherdrake: Shark Finned Tail
  203360, -- Winding Slitherdrake: Large Finned Tail
  203361, -- Winding Slitherdrake: Finned Tip Tail
  203362, -- Winding Slitherdrake: Hairy Tail
  203363, -- Winding Slitherdrake: Large Finned Throat
  203364, -- Winding Slitherdrake: Small Finned Throat
  203365, -- Winding Slitherdrake: Hairy Throat
  205341, -- Winding Slitherdrake: Heavy Scales
  205865, -- Winding Slitherdrake: Embodiment of the Obsidian Gladiator
  205876, -- Highland Drake: Embodiment of the Hellforged
  207757, -- Grotto Netherwing Drake: Purple and Silver Armor
  207758, -- Grotto Netherwing Drake: Spiked Back
  207759, -- Grotto Netherwing Drake: Cluster Spiked Back
  207760, -- Grotto Netherwing Drake: Armor
  207761, -- Grotto Netherwing Drake: Chin Tendrils
  207762, -- Grotto Netherwing Drake: Chin Spike
  207763, -- Grotto Netherwing Drake: Single Horned Crest
  207764, -- Grotto Netherwing Drake: Head Spike
  207765, -- Grotto Netherwing Drake: Cluster Spiked Crest
  207766, -- Grotto Netherwing Drake: Triple Spiked Crest
  207767, -- Grotto Netherwing Drake: Tempestuous Pattern
  207768, -- Grotto Netherwing Drake: Volatile Pattern
  207769, -- Grotto Netherwing Drake: Outcast Pattern
  207770, -- Grotto Netherwing Drake: Helm
  207771, -- Grotto Netherwing Drake: Short Horns
  207772, -- Grotto Netherwing Drake: Long Horns
  207773, -- Grotto Netherwing Drake: Spiked Jaw
  207774, -- Grotto Netherwing Drake: Finned Jaw
  207775, -- Grotto Netherwing Drake: Teal Scales
  207776, -- Grotto Netherwing Drake: Black Scales
  207777, -- Grotto Netherwing Drake: Yellow Scales
  207778, -- Grotto Netherwing Drake: Double Finned Tail
  207779, -- Grotto Netherwing Drake: Barbed Tail
  208102, -- Cliffside Wylderdrake: Infinite Scales
  208103, -- Highland Drake: Infinite Scales
  208104, -- Renewed Proto-Drake: Infinite Scales
  208105, -- Windborne Velocidrake: Infinite Scales
  208106, -- Winding Slitherdrake: Infinite Scales
  208200, -- Dragon Isles Drakes: Gilded Armor
  208550, -- Dragon Isles Drakes: White Scales
  208680, -- Windborne Velocidrake: Hallow's End Armor
  208742, -- Renewed Proto-Drake: Brewfest Armor
  208858, -- Highland Drake: Pirates' Day Armor
  208859, -- Cliffside Wylderdrake: Day of the Dead Armor
  210064, -- Winding Slitherdrake: Embodiment of the Verdant Gladiator
  210432, -- Highland Drake: Winter Veil Armor
  210471, -- Flourishing Whimsydrake: Body Armor
  210476, -- Flourishing Whimsydrake: Helmet
  210478, -- Flourishing Whimsydrake: Gold and Pink Armor
  210479, -- Flourishing Whimsydrake: Night Scales
  210480, -- Flourishing Whimsydrake: Sunrise Scales
  210481, -- Flourishing Whimsydrake: Sunset Scales
  210482, -- Flourishing Whimsydrake: Back Fins
  210483, -- Flourishing Whimsydrake: Ridged Brow
  210484, -- Flourishing Whimsydrake: Underbite Snout
  210485, -- Flourishing Whimsydrake: Long Snout
  210486, -- Flourishing Whimsydrake: Horns
  210487, -- Flourishing Whimsydrake: Neck Fins
  210536, -- Renewed Proto-Drake: Embodiment of the Blazing
  210537, -- Renewed Proto-Drake: Embodiment of Shadowflame
  211381, -- Grotto Netherwing Drake: Violet Scales
}

-- Dreambound Armor
database["DreamboundArmor"] = {
  208890, -- Dreambound Plate Helm
  208891, -- Dreambound Cloth Helm
  208892, -- Dreambound Mail Helm
  208893, -- Dreambound Leather Helm
  208894, -- Dreambound Plate Chestpiece
  208895, -- Dreambound Cloth Chestpiece
  208896, -- Dreambound Mail Chestpiece
  208897, -- Dreambound Leather Chestpiece
  208898, -- Dreambound Leather Leggings
  208899, -- Dreambound Mail Leggings
  208900, -- Dreambound Cloth Leggings
  208901, -- Dreambound Plate Leggings
  208902, -- Dreambound Plate Spaulders
  208903, -- Dreambound Cloth Spaulders
  208904, -- Dreambound Mail Spaulders
  208905, -- Dreambound Leather Spaulders
  208906, -- Dreambound Leather Bracers
  208907, -- Dreambound Mail Bracers
  208908, -- Dreambound Cloth Bracers
  208909, -- Dreambound Plate Bracers
  208910, -- Dreambound Plate Belt
  208911, -- Dreambound Cloth Belt
  208912, -- Dreambound Mail Belt
  208913, -- Dreambound Leather Belt
  208914, -- Dreambound Leather Boots
  208915, -- Dreambound Mail Boots
  208916, -- Dreambound Plate Boots
  208917, -- Dreambound Cloth Boots
  208918, -- Dreambound Cloth Gloves
  208919, -- Dreambound Plate Gloves
  208920, -- Dreambound Mail Gloves
  208921, -- Dreambound Leather Gloves
}

-- Dreamsurge
database["Dreamsurge"] = {
  207026, -- Dreamsurge Coalescence
  208153, -- Dreamsurge Chrysalis
  209419, -- Charred Elemental Remains
}

-- Fortune Cards
database["FortuneCards"] = {
  194829, -- Fated Fortune Card
  199114, -- Fated Fortune Card
  199116, -- Fated Fortune Card
  199117, -- Fated Fortune Card
  199118, -- Fated Fortune Card
  199119, -- Fated Fortune Card
  199120, -- Fated Fortune Card
  199121, -- Fated Fortune Card
  199123, -- Fated Fortune Card
  199124, -- Fated Fortune Card
  199125, -- Fated Fortune Card
  199126, -- Fated Fortune Card
  199127, -- Fated Fortune Card
  199129, -- Fated Fortune Card
  199130, -- Fated Fortune Card
  199131, -- Fated Fortune Card
  199132, -- Fated Fortune Card
  199133, -- Fated Fortune Card
  199134, -- Fated Fortune Card
  199135, -- Fated Fortune Card
  199136, -- Fated Fortune Card
  199137, -- Fated Fortune Card
  199138, -- Fated Fortune Card
  199139, -- Fated Fortune Card
  199140, -- Fated Fortune Card
  199141, -- Fated Fortune Card
  199142, -- Fated Fortune Card
  199143, -- Fated Fortune Card
  199144, -- Fated Fortune Card
  199145, -- Fated Fortune Card
  199146, -- Fated Fortune Card
  199147, -- Fated Fortune Card
  199148, -- Fated Fortune Card
  199149, -- Fated Fortune Card
  199150, -- Fated Fortune Card
  199151, -- Fated Fortune Card
  199152, -- Fated Fortune Card
  199153, -- Fated Fortune Card
  199154, -- Fated Fortune Card
  199155, -- Fated Fortune Card
  199156, -- Fated Fortune Card
  199157, -- Fated Fortune Card
  199158, -- Fated Fortune Card
  199159, -- Fated Fortune Card
  199160, -- Fated Fortune Card
  199161, -- Fated Fortune Card
  199162, -- Fated Fortune Card
  199163, -- Fated Fortune Card
  199164, -- Fated Fortune Card
  199165, -- Fated Fortune Card
  199166, -- Fated Fortune Card
  199167, -- Fated Fortune Card
  199168, -- Fated Fortune Card
  199169, -- Fated Fortune Card
  199170, -- Fated Fortune Card
}

-- Reputation Items
database["ReputationItems"] = {
  191251, -- Key Fragments
  191264, -- Restored Obsidian Key
  192055, -- Dragon Isles Artifact
  193201, -- Key Framing
  198790, -- I.O.U.
  199906, -- Titan Relic
  200071, -- Sacred Tuskarr Totem
  200093, -- Centaur Hunting Trophy
  200224, -- Mark of Sargha
  200285, -- Dragonscale Expedition Insignia
  200287, -- Iskaara Tuskarr Insignia
  200288, -- Maruuk Centaur Insignia
  200289, -- Valdrakken Accord Insignia
  200443, -- Dragon Isles Artifact
  200447, -- Centaur Hunting Trophy
  200449, -- Sacred Tuskarr Totem
  200450, -- Titan Relic
  200452, -- Dragonscale Expedition Insignia
  200453, -- Iskaara Tuskarr Insignia
  200454, -- Maruuk Centaur Insignia
  200455, -- Valdrakken Accord Insignia
  201411, -- Ancient Vault Artifact
  201779, -- Merithra's Blessing
  201781, -- Memory of Tyr
  201782, -- Tyr's Blessing
  201783, -- Tutaqan's Commendation
  201921, -- Dragonscale Expedition Insignia
  201922, -- Iskaara Tuskarr Insignia
  201923, -- Maruuk Centaur Insignia
  201924, -- Valdrakken Accord Insignia
  201991, -- Sargha's Signet
  202091, -- Dragonscale Expedition Insignia
  202092, -- Iskaara Tuskarr Insignia
  202093, -- Valdrakken Accord Insignia
  202094, -- Maruuk Centaur Insignia
  205249, -- Pungent Niffen Incense
  205250, -- Gift of the High Redolence
  205251, -- Champion's Rock Bar
  205252, -- Momento of Rekindled Bonds
  205253, -- Farmhand's Abundant Harvest
  205254, -- Honorary Explorer's Compass
  205342, -- Loamm Niffen Insignia
  205365, -- Loamm Niffen Insignia
  205985, -- Loamm Niffen Insignia
  205989, -- Symbol of Friendship
  205991, -- Shiny Token of Gratitude
  205992, -- Regurgitated Half-Digested Fish
  205998, -- Sign of Respect
  206006, -- Earth-Warder's Thanks
  210419, -- Dream Wardens Insignia
  210420, -- Dream Wardens Insignia
  210421, -- Dream Wardens Insignia
  210422, -- Loamm Niffen Insignia
  210423, -- Dream Wardens Insignia
  210730, -- Mark of the Dream Wardens
  210757, -- Scales of Remorse
  210847, -- Tears of the Eye
  210916, -- Ember of Fyrakk
  210920, -- Gift of Amirdrassil
  210921, -- Bounty of the Fallen Defector
  210950, -- Insight of Q'onzu
  210951, -- Treacherous Research Notes
  210952, -- Spare Heated Hearthstone
  210954, -- Sprout of Rebirth
  210957, -- Rune of the Fire Druids
  210958, -- Crown of the Dryad Daughter
  210959, -- Pact of the Netherwing
  210997, -- Spare Party Hat
  211131, -- Delicately Curated Blossoms
  211353, -- Roasted Ram Special
  211366, -- Drops of Moon Water
  211369, -- Charred Staff of the Overseer
  211370, -- Branch of Gracus
  211371, -- Dryad-Keeper Credentials
  211372, -- Q'onzu's Consolation Prize
  211416, -- Dream Wardens Insignia
  211417, -- Dream Wardens Insignia
}

-- Time Rifts
database["TimeRifts"] = {
  207002, -- Encapsulated Destiny
  207027, -- Greater Encapsulated Destiny
  207030, -- Dilated Time Capsule
  207582, -- Box of Tampered Reality
  207583, -- Box of Collapsed Reality
  207584, -- Box of Volatile Reality
  208090, -- Contained Paracausality
}

-- Treasure Maps
database["TreasureMaps"] = {
  194540, -- Nokhud Armorer's Notes
  198843, -- Emerald Gardens Explorer's Notes
  198852, -- Bear Termination Orders
  198854, -- Archeologist Artifact Notes
  199061, -- A Guide to Rare Fish
  199062, -- Ruby Gem Cluster Map
  199065, -- Sorrowful Letter
  199066, -- Letter of Caution
  199067, -- Precious Plans
  199068, -- Time-Lost Memo
  200738, -- Onyx Gem Cluster Map
  202667, -- Sealed Artifact Scroll
  202668, -- Sealed Spirit Scroll
  202669, -- Sealed Fish Scroll
  202670, -- Sealed Knowledge Scroll
}

-- Treasure Sacks
database["TreasureSacks"] = {
  199341, -- Regurgitated Sac of Swog Treasures
  199342, -- Weighted Sac of Swog Treasures
  199343, -- Immaculate Sack of Swog Treasures
  202102, -- Immaculate Sac of Swog Treasures
}

-- PreEvent Currency
database["PreEventCurrency"] = {
  199211, -- Primeval Essence
  199836, -- Dimmed Primeval Fire
  199837, -- Dimmed Primeval Earth
  199838, -- Dimmed Primeval Storm
  199839, -- Dimmed Primeval Water
}

-- PreEvent Gear
database["PreEventGear"] = {
  199348, -- Cloudburst Robes
  199349, -- Cloudburst Slippers
  199350, -- Cloudburst Mitts
  199351, -- Cloudburst Hood
  199352, -- Cloudburst Breeches
  199353, -- Cloudburst Mantle
  199354, -- Cloudburst Sash
  199355, -- Cloudburst Bindings
  199356, -- Dust Devil Raiment
  199357, -- Dust Devil Treads
  199358, -- Dust Devil Gloves
  199359, -- Dust Devil Mask
  199360, -- Dust Devil Leggings
  199361, -- Dust Devil Epaulets
  199362, -- Dust Devil Cincture
  199363, -- Dust Devil Wristbands
  199364, -- Cyclonic Chainmail
  199365, -- Cyclonic Striders
  199366, -- Cyclonic Gauntlets
  199367, -- Cyclonic Cowl
  199368, -- Cyclonic Kilt
  199369, -- Cyclonic Spaulders
  199370, -- Cyclonic Cinch
  199371, -- Cyclonic Bracers
  199372, -- Firestorm Chestplate
  199373, -- Firestorm Stompers
  199374, -- Firestorm Crushers
  199375, -- Firestorm Greathelm
  199376, -- Firestorm Greaves
  199377, -- Firestorm Pauldrons
  199378, -- Firestorm Girdle
  199379, -- Firestorm Vambraces
  199380, -- Cyclonic Drape
  199381, -- Seal of Elemental Disasters
  199382, -- Catastrophe Signet
  199383, -- Torc of Calamities
  199384, -- Cloudburst Wrap
  199385, -- Dust Devil Cloak
  199386, -- Firestorm Cape
  199399, -- Galerider Poleaxe
  199400, -- Squallbreaker Greatsword
  199401, -- Stormbender Scroll
  199402, -- Galepiercer Ballista
  199403, -- Stormbender Maul
  199404, -- Squallbreaker Shield
  199405, -- Stormbender Rod
  199406, -- Galerider Mallet
  199407, -- Galerider Shank
  199408, -- Squallbreaker Longblade
  199409, -- Stormbender Saber
  199416, -- Galerider Crescent
  199555, -- Versatile Storm Lure
  199645, -- Storm Hunter's Insignia
}

-- Primalist Accessories
database["PrimalistAccessories"] = {
  203646, -- Primalist Cloak
  203647, -- Primalist Ring
  203648, -- Primalist Necklace
  203649, -- Primalist Trinket
}

-- Primalist Cloth
database["PrimalistCloth"] = {
  203612, -- Primalist Cloth Helm
  203616, -- Primalist Cloth Chestpiece
  203622, -- Primalist Cloth Leggings
  203627, -- Primalist Cloth Spaulders
  203632, -- Primalist Cloth Bracers
  203635, -- Primalist Cloth Belt
  203641, -- Primalist Cloth Boots
  203642, -- Primalist Cloth Gloves
}

-- Primalist Leather
database["PrimalistLeather"] = {
  203614, -- Primalist Leather Helm
  203618, -- Primalist Leather Chestpiece
  203619, -- Primalist Leather Leggings
  203629, -- Primalist Leather Spaulders
  203630, -- Primalist Leather Bracers
  203637, -- Primalist Leather Belt
  203638, -- Primalist Leather Boots
  203645, -- Primalist Leather Gloves
}

-- Primalist Mail
database["PrimalistMail"] = {
  203613, -- Primalist Mail Helm
  203617, -- Primalist Mail Chestpiece
  203620, -- Primalist Mail Leggings
  203628, -- Primalist Mail Spaulders
  203631, -- Primalist Mail Bracers
  203636, -- Primalist Mail Belt
  203639, -- Primalist Mail Boots
  203644, -- Primalist Mail Gloves
}

-- Primalist Plate
database["PrimalistPlate"] = {
  203611, -- Primalist Plate Helm
  203615, -- Primalist Plate Chestpiece
  203623, -- Primalist Plate Leggings
  203626, -- Primalist Plate Spaulders
  203633, -- Primalist Plate Bracers
  203634, -- Primalist Plate Belt
  203640, -- Primalist Plate Boots
  203643, -- Primalist Plate Gloves
}

-- Primalist Weapon
database["PrimalistWeapon"] = {
  203650, -- Primalist Weapon
}

-- Untapped Forbidden Knowledge
database["UntappedForbiddenKnowledge"] = {
  204276, -- Untapped Forbidden Knowledge
}

-- Alchemy Flasks
database["AlchemyFlasks"] = {
  191474, -- Draconic Vial
  191475, -- Draconic Vial
  191476, -- Draconic Vial
  198265, -- Portable Alchemist's Lab Bench
}

-- Cloth
database["Cloth"] = {
  192095, -- Spool of Wilderthread
  192096, -- Spool of Wilderthread
  192097, -- Spool of Wilderthread
  193050, -- Tattered Wildercloth
  193053, -- Contoured Fowlfeather
  193922, -- Wildercloth
  193923, -- Decayed Wildercloth
  193924, -- Frostbitten Wildercloth
  193925, -- Singed Wildercloth
  193926, -- Wildercloth Bolt
  193927, -- Wildercloth Bolt
  193928, -- Wildercloth Bolt
  193929, -- Vibrant Wildercloth Bolt
  193930, -- Vibrant Wildercloth Bolt
  193931, -- Vibrant Wildercloth Bolt
  193932, -- Infurious Wildercloth Bolt
  193933, -- Infurious Wildercloth Bolt
  193934, -- Infurious Wildercloth Bolt
  193935, -- Chronocloth Bolt
  193936, -- Chronocloth Bolt
  193937, -- Chronocloth Bolt
  193938, -- Azureweave Bolt
  193939, -- Azureweave Bolt
  193940, -- Azureweave Bolt
}

-- Cooking
database["Cooking"] = {
  194730, -- Scalebelly Mackerel
  194966, -- Thousandbite Piranha
  194967, -- Aileron Seamoth
  194968, -- Cerulean Spinefish
  194969, -- Temporal Dragonhead
  194970, -- Islefin Dorado
  197741, -- Maybe Meat
  197742, -- Ribbed Mollusk Meat
  197743, -- Waterfowl Filet
  197744, -- Hornswog Hunk
  197745, -- Basilisk Eggs
  197746, -- Bruffalon Flank
  197747, -- Mighty Mammoth Ribs
  197748, -- Burly Bear Haunch
  197749, -- Ohn'ahran Potato
  197750, -- Three-Cheese Blend
  197751, -- Pastry Packets
  197752, -- Conveniently Packaged Ingredients
  197753, -- Thaldraszian Cocoa Powder
  197754, -- Salt Deposit
  197755, -- Lava Beetle
  197756, -- Pebbled Rock Salts
  197757, -- Assorted Exotic Spices
  198395, -- Dull Spined Clam
  199063, -- Salted Fish Scraps
  199100, -- Peppersmelt
  199101, -- Dried Wyldermane Kelp
  199102, -- Hunk o' Blubber
  199103, -- Nappa's Famous Tea
  199104, -- Piping-Hot Orca Milk
  199105, -- Ancheevy
  199106, -- Tiny Leviathan Bone
  199205, -- Manasucker
  199207, -- Iceback Sculpin
  199208, -- Grungle
  199212, -- Clubfish
  199213, -- Lakkamuk Blenny
  199344, -- Magma Thresher
  199345, -- Rimefin Tuna
  199346, -- Rotten Rimefin Tuna
  199832, -- Smoked Seaviper
  199833, -- Dragonhead Eel
  199834, -- Pulpy Seagrass
  199835, -- Torga's Braid
  200061, -- Prismatic Leaper
  200074, -- Frosted Rimefin Tuna
}

-- Enchanting
database["Enchanting"] = {
  193057, -- 10.0 Placeholder Enchanting Crystal
  194123, -- Chromatic Dust
  194124, -- Vibrant Shard
  200113, -- Resonant Crystal
  201584, -- Serevite Rod
}

-- Enchanting - Insight of the Blue
database["EnchantingInsightoftheBlue"] = {
  200939, -- Chromatic Pocketwatch
  200940, -- Everflowing Inkwell
  200941, -- Seal of Order
  200942, -- Vibrant Emulsion
  200943, -- Whispering Band
  200945, -- Valiant Hammer
  200946, -- Thunderous Blade
  200947, -- Carving of Awakening
}

-- Engineering
database["Engineering"] = {
  198183, -- Handful of Serevite Bolts
  198184, -- Handful of Serevite Bolts
  198185, -- Handful of Serevite Bolts
  198186, -- Shock-Spring Coil
  198187, -- Shock-Spring Coil
  198188, -- Shock-Spring Coil
  198189, -- Everburning Blasting Powder
  198190, -- Everburning Blasting Powder
  198191, -- Everburning Blasting Powder
  198192, -- Greased-Up Gears
  198193, -- Greased-Up Gears
  198194, -- Greased-Up Gears
  198195, -- Arclight Capacitor
  198196, -- Arclight Capacitor
  198197, -- Arclight Capacitor
  198198, -- Reinforced Machine Chassis
  198199, -- Reinforced Machine Chassis
  198200, -- Reinforced Machine Chassis
  198201, -- Assorted Safety Fuses
  198202, -- Assorted Safety Fuses
  198203, -- Assorted Safety Fuses
  201832, -- Smudged Lens
}

-- Fishing Lures
database["FishingLures"] = {
  193893, -- Scalebelly Mackerel Lure
  193894, -- Thousandbite Piranha Lure
  193895, -- Temporal Dragonhead Lure
  193896, -- Cerulean Spinefish Lure
  198401, -- Aileron Seamoth Lure
  198403, -- Islefin Dorado Lure
}

-- Herbs
database["Herbs"] = {
  191460, -- Hochenblume
  191461, -- Hochenblume
  191462, -- Hochenblume
  191464, -- Saxifrage
  191465, -- Saxifrage
  191466, -- Saxifrage
  191467, -- Bubble Poppy
  191468, -- Bubble Poppy
  191469, -- Bubble Poppy
  191470, -- Writhebark
  191471, -- Writhebark
  191472, -- Writhebark
}

-- Herbs - Seeds
database["HerbsSeeds"] = {
  200506, -- Roused Seedling
  200507, -- Decayed Roused Seedling
  200508, -- Propagating Roused Seedling
  200509, -- Agitated Roused Seedling
}

-- Inscription
database["Inscription"] = {
  194751, -- Blazing Ink
  194752, -- Blazing Ink
  194754, -- Cosmic Ink
  194755, -- Cosmic Ink
  194756, -- Cosmic Ink
  194758, -- Flourishing Ink
  194760, -- Burnished Ink
  194761, -- Burnished Ink
  194767, -- Chilled Rune
  194768, -- Chilled Rune
  194784, -- Glittering Parchment
  194846, -- Blazing Ink
  194850, -- Flourishing Ink
  194852, -- Flourishing Ink
  194855, -- Burnished Ink
  194856, -- Serene Ink
  194857, -- Serene Ink
  194858, -- Serene Ink
  194859, -- Chilled Rune
  194862, -- Runed Writhebark
  194863, -- Runed Writhebark
  194864, -- Runed Writhebark
  198412, -- Serene Pigment
  198413, -- Serene Pigment
  198414, -- Serene Pigment
  198415, -- Flourishing Pigment
  198416, -- Flourishing Pigment
  198417, -- Flourishing Pigment
  198418, -- Blazing Pigment
  198419, -- Blazing Pigment
  198420, -- Blazing Pigment
  198421, -- Shimmering Pigment
  198422, -- Shimmering Pigment
  198423, -- Shimmering Pigment
}

-- Jewelcrafting
database["Jewelcrafting"] = {
  192833, -- Misshapen Filigree
  192834, -- Shimmering Clasp
  192835, -- Shimmering Clasp
  192836, -- Shimmering Clasp
  192837, -- Queen's Ruby
  192838, -- Queen's Ruby
  192839, -- Queen's Ruby
  192840, -- Mystic Sapphire
  192841, -- Mystic Sapphire
  192842, -- Mystic Sapphire
  192843, -- Vibrant Emerald
  192844, -- Vibrant Emerald
  192845, -- Vibrant Emerald
  192846, -- Sundered Onyx
  192847, -- Sundered Onyx
  192848, -- Sundered Onyx
  192849, -- Eternity Amber
  192850, -- Eternity Amber
  192851, -- Eternity Amber
  192852, -- Alexstraszite
  192853, -- Alexstraszite
  192855, -- Alexstraszite
  192856, -- Malygite
  192857, -- Malygite
  192858, -- Malygite
  192859, -- Ysemerald
  192860, -- Ysemerald
  192861, -- Ysemerald
  192862, -- Neltharite
  192863, -- Neltharite
  192865, -- Neltharite
  192866, -- Nozdorite
  192867, -- Nozdorite
  192868, -- Nozdorite
  192869, -- Illimited Diamond
  192870, -- Illimited Diamond
  192871, -- Illimited Diamond
  192872, -- Fractured Glass
  192876, -- Frameless Lens
  192877, -- Frameless Lens
  192878, -- Frameless Lens
  192880, -- Crumbled Stone
  192883, -- Glossy Stone
  192884, -- Glossy Stone
  192885, -- Glossy Stone
  192888, -- Queen's Gift
  192889, -- Dreamer's Vision
  192890, -- Keeper's Glory
  192891, -- Earthwarden's Prize
  192892, -- Timewatcher's Patience
  192893, -- Jeweled Dragon's Heart
  192894, -- Blotting Sand
  192895, -- Blotting Sand
  192896, -- Blotting Sand
  192897, -- Pounce
  192898, -- Pounce
  192899, -- Pounce
  193029, -- Projection Prism
  193030, -- Projection Prism
  193031, -- Projection Prism
  193368, -- Silken Gemdust
  193369, -- Silken Gemdust
  193370, -- Silken Gemdust
  198397, -- Rainbow Pearl
  200156, -- Amethyzarite Geode
  202048, -- Queen's Gift
  202049, -- Dreamer's Vision
  202050, -- Keeper's Glory
  202051, -- Earthwarden's Prize
  202052, -- Timewatcher's Patience
  202054, -- Queen's Gift
  202055, -- Dreamer's Vision
  202056, -- Keeper's Glory
  202057, -- Earthwarden's Prize
  202058, -- Timewatcher's Patience
}

-- Leather
database["Leather"] = {
  193208, -- Resilient Leather
  193210, -- Resilient Leather
  193211, -- Resilient Leather
  193213, -- Adamant Scales
  193214, -- Adamant Scales
  193215, -- Adamant Scales
  193216, -- Dense Hide
  193217, -- Dense Hide
  193218, -- Dense Hide
  193222, -- Lustrous Scaled Hide
  193223, -- Lustrous Scaled Hide
  193224, -- Lustrous Scaled Hide
  193226, -- Stonecrust Hide
  193227, -- Stonecrust Hide
  193228, -- Stonecrust Hide
  193229, -- Mireslush Hide
  193230, -- Mireslush Hide
  193231, -- Mireslush Hide
  193232, -- Deathchill Hide
  193233, -- Deathchill Hide
  193234, -- Deathchill Hide
  193236, -- Infurious Hide
  193237, -- Infurious Hide
  193238, -- Infurious Hide
  193239, -- Drygrate Scales
  193240, -- Drygrate Scales
  193241, -- Drygrate Scales
  193242, -- Earthshine Scales
  193243, -- Earthshine Scales
  193244, -- Earthshine Scales
  193245, -- Frostbite Scales
  193246, -- Frostbite Scales
  193247, -- Frostbite Scales
  193248, -- Infurious Scales
  193249, -- Infurious Scales
  193250, -- Infurious Scales
  193251, -- Crystalspine Fur
  193252, -- Salamanther Scales
  193253, -- Cacophonous Thunderscale
  193254, -- Rockfang Leather
  193255, -- Pristine Vorquin Horn
  193256, -- Windsong Plumage
  193258, -- Fire-Infused Hide
  193259, -- Flawless Proto Dragon Scale
  193261, -- Bite-Sized Morsel
  193262, -- Exceptional Morsel
  197735, -- Finished Prototype Explorer's Barding
  197736, -- Finished Prototype Regal Barding
}

-- Leather - Bait
database["LeatherBait"] = {
  193906, -- Elusive Creature Bait
  198404, -- Bottled Pheromones
  198804, -- Frost-Infused Creature Bait
  198805, -- Earth-Infused Creature Bait
  198806, -- Decay-Infused Creature Bait
  198807, -- Titan-Infused Creature Bait
}

-- Mining
database["Mining"] = {
  188658, -- Draconium Ore
  189143, -- Draconium Ore
  189541, -- Primal Molten Alloy
  189542, -- Primal Molten Alloy
  189543, -- Primal Molten Alloy
  190311, -- Draconium Ore
  190312, -- Khaz'gorite Ore
  190313, -- Khaz'gorite Ore
  190314, -- Khaz'gorite Ore
  190394, -- Serevite Ore
  190395, -- Serevite Ore
  190396, -- Serevite Ore
  190452, -- Primal Flux
  190530, -- Frostfire Alloy
  190531, -- Frostfire Alloy
  190532, -- Frostfire Alloy
  190533, -- Obsidian Seared Alloy
  190534, -- Obsidian Seared Alloy
  190535, -- Obsidian Seared Alloy
  190536, -- Infurious Alloy
  190537, -- Infurious Alloy
  190538, -- Infurious Alloy
  194545, -- Prismatic Ore
}

-- Alchemy Recipes
database["AlchemyRecipes"] = {
  191429, -- Recipe: Phial of the Eye in the Storm
  191430, -- Recipe: Phial of Still Air
  191431, -- Recipe: Phial of Icy Preservation
  191432, -- Recipe: Iced Phial of Corrupting Rage
  191433, -- Recipe: Phial of Charged Isolation
  191434, -- Recipe: Phial of Glacial Fury
  191435, -- Recipe: Phial of Static Empowerment
  191436, -- Recipe: Phial of Tepid Versatility
  191437, -- Recipe: Aerated Phial of Deftness
  191438, -- Recipe: Steaming Phial of Finesse
  191439, -- Recipe: Charged Phial of Alacrity
  191440, -- Recipe: Potion of Frozen Fatality
  191441, -- Recipe: Crystalline Phial of Perception
  191442, -- Recipe: Phial of Elemental Chaos
  191443, -- Recipe: Bottled Putrescence
  191444, -- Recipe: Potion of Frozen Focus
  191445, -- Recipe: Potion of Chilled Clarity
  191446, -- Recipe: Potion of Withering Vitality
  191447, -- Recipe: Residual Neural Channeling Agent
  191448, -- Recipe: Delicate Suspension of Spores
  191449, -- Recipe: Refreshing Healing Potion
  191450, -- Recipe: Elemental Potion of Ultimate Power
  191451, -- Recipe: Aerated Mana Potion
  191452, -- Recipe: Elemental Potion of Power
  191454, -- Recipe: Potion of the Hushed Zephyr
  191455, -- Recipe: Potion of Gusts
  191456, -- Recipe: Potion of Shocking Disclosure
  191542, -- Recipe: Potion Cauldron of Power
  191543, -- Recipe: Potion Cauldron of Ultimate Power
  191544, -- Recipe: Cauldron of the Pooka
  191545, -- Recipe: Sustaining Alchemist's Stone
  191547, -- Recipe: Alacritous Alchemist Stone
  191578, -- Recipe: Transmute: Awakened Fire
  191579, -- Recipe: Transmute: Awakened Frost
  191580, -- Recipe: Transmute: Awakened Earth
  191581, -- Recipe: Transmute: Awakened Air
  191582, -- Recipe: Transmute: Decay to Elements
  191583, -- Recipe: Transmute: Order to Elements
  191584, -- Recipe: Primal Convergent
  191585, -- Recipe: Omnium Draconis
  191586, -- Recipe: Sagacious Incense
  191587, -- Recipe: Somniferous Incense
  191588, -- Recipe: Exultant Incense
  191589, -- Recipe: Fervid Incense
  191590, -- Recipe: Stable Fluidic Draconium
  191591, -- Recipe: Brood Salt
  191592, -- Recipe: Writhefire Oil
  191593, -- Recipe: Agitating Potion Augmentation
  191594, -- Recipe: Reactive Phial Embellishment
  191595, -- ERROR1
  191596, -- Recipe: Illustrious Insight
  191597, -- Recipe: Potion Absorption Inhibitor
  191598, -- ERROR1
  191599, -- Recipe: Basic Potion Experimentation
  191600, -- Recipe: Advanced Potion Experimentation
  191601, -- Recipe: Basic Phial Experimentation
  191602, -- Recipe: Advanced Phial Experimentation
  192180, -- Basic Phial Alchemical Experimentation
  193365, -- Basic Potion Alchemical Experimentation
  193366, -- Advanced Phial Alchemical Experimentation
  193367, -- Advanced Potion Alchemical Experimentation
  194973, -- Reclaim Concoctions
  198533, -- Recipe: Aerated Phial of Quick Hands
  201740, -- Elemental Codex of Ultimate Power
  203420, -- Recipe: Draconic Suppression Powder
  204631, -- Recipe: Transmute: Dracothyst
  204695, -- Recipe: Cauldron of Extracted Putrescence
  204696, -- Recipe: Draconic Phial Cauldron
  204984, -- Recipe: Stinky Bright Potion
  210241, -- Recipe: Dreamwalker's Healing Potion
}

-- Blacksmithing Recipes
database["BlacksmithingRecipes"] = {
  194453, -- Plans: Crimson Combatant's Draconium Helm
  194454, -- Plans: Crimson Combatant's Draconium Breastplate
  194455, -- Plans: Crimson Combatant's Draconium Greaves
  194456, -- Plans: Crimson Combatant's Draconium Pauldrons
  194457, -- Plans: Crimson Combatant's Draconium Gauntlets
  194458, -- Plans: Crimson Combatant's Draconium Sabatons
  194459, -- Plans: Crimson Combatant's Draconium Armguards
  194460, -- Plans: Crimson Combatant's Draconium Waistguard
  194461, -- Plans: Primal Molten Helm
  194462, -- Plans: Primal Molten Breastplate
  194463, -- Plans: Primal Molten Legplates
  194464, -- Plans: Primal Molten Pauldrons
  194465, -- Plans: Primal Molten Gauntlets
  194466, -- Plans: Primal Molten Sabatons
  194467, -- Plans: Primal Molten Vambraces
  194468, -- Plans: Primal Molten Greatbelt
  194469, -- Plans: Primal Molten Defender
  194470, -- Plans: Primal Molten Shortblade
  194471, -- Plans: Primal Molten Spellblade
  194472, -- Plans: Primal Molten Longsword
  194473, -- Plans: Primal Molten Warglaive
  194474, -- Plans: Primal Molten Mace
  194475, -- Plans: Primal Molten Greataxe
  194476, -- Plans: Obsidian Seared Hexsword
  194477, -- Plans: Obsidian Seared Runeaxe
  194478, -- Plans: Obsidian Seared Facesmasher
  194479, -- Plans: Obsidian Seared Claymore
  194480, -- Plans: Obsidian Seared Halberd
  194481, -- Plans: Obsidian Seared Crusher
  194482, -- Plans: Obsidian Seared Invoker
  194483, -- Plans: Obsidian Seared Slicer
  194484, -- Plans: Infurious Helm of Vengeance
  194485, -- Plans: Infurious Warboots of Impunity
  194486, -- Plans: Shield of the Hearth
  194487, -- ERROR1
  194488, -- ERROR1
  194489, -- Plans: Allied Chestplate of Generosity
  194490, -- Plans: Allied Wristguard of Companionship
  194491, -- Plans: Frostfire Legguards of Preparation
  194492, -- Plans: Unstable Frostfire Belt
  194493, -- Plans: Armor Spikes
  194495, -- Plans: Khaz'gorite Sickle
  194496, -- Plans: Khaz'gorite Pickaxe
  194497, -- Plans: Khaz'gorite Skinning Knife
  194498, -- Plans: Khaz'gorite Needle Set
  194499, -- Plans: Khaz'gorite Leatherworker's Knife
  194500, -- Plans: Khaz'gorite Leatherworker's Toolset
  194501, -- Plans: Khaz'gorite Blacksmith's Hammer
  194502, -- Plans: Khaz'gorite Blacksmith's Toolbox
  194503, -- Plans: Black Dragon Touched Hammer
  194504, -- Plans: Primal Whetstone
  194505, -- Plans: Primal Weightstone
  194506, -- Plans: Primal Razorstone
  194507, -- Plans: Serevite Skeleton Key
  194508, -- Plans: Alvin the Anvil
  194963, -- Plans: Obsidian Seared Alloy
  198713, -- Plans: Prototype Explorer's Barding Framework
  198714, -- Plans: Prototype Regal Barding Framework
  198719, -- Plans: Sturdy Expedition Shovel
  200102, -- Plans: Infurious Alloy
  201256, -- Bloodstained Plans: Infurious Alloy
  202223, -- Plans: Impressive Steelforged Essence
  202224, -- Plans: Remarkable Steelforged Essence
  202226, -- Plans: Impressive Truesteel Essence
  202227, -- Plans: Remarkable Truesteel Essence
  203421, -- Plans: Ancient Ceremonial Trident
  203824, -- Ancient Plans: Gurubashi Headplate
  203825, -- Ancient Plans: Gurubashi Carver
  203826, -- Ancient Plans: Venomfang
  203827, -- Ancient Plans: Gurubashi Poker
  203828, -- Ancient Plans: Gurubashi Grinder
  203829, -- Ancient Plans: Gurubashi Hexxer
  203830, -- Ancient Plans: Sceptre of Hexing
  203831, -- Ancient Plans: Gurubashi Crusher
  203832, -- Ancient Plans: Pitchfork of Mojo Madness
  203833, -- Ancient Plans: Bloodherald
  203834, -- Ancient Plans: Bloodlord's Reaver
  203835, -- Ancient Plans: Fiery Vengeance
  203836, -- Ancient Plans: Warblades of the Hakkari, Reborn
  203837, -- Ancient Plans: Gurubashi Slicer
  203861, -- Ancient Plans: Venomreaver
  204138, -- Plans: Obsidian Combatant's Draconium Helm
  204139, -- Plans: Obsidian Combatant's Draconium Breastplate
  204140, -- Plans: Obsidian Combatant's Draconium Greaves
  204141, -- Plans: Obsidian Combatant's Draconium Pauldrons
  204142, -- Plans: Obsidian Combatant's Draconium Gauntlets
  204143, -- Plans: Obsidian Combatant's Draconium Sabatons
  204144, -- Plans: Obsidian Combatant's Draconium Armguards
  204145, -- Plans: Obsidian Combatant's Draconium Waistguard
  205137, -- Plans: Shadowed Alloy
  205143, -- Plans: Shadowed Belt Clasp
  205144, -- Plans: Shadowed Razing Annihilator
  205145, -- Plans: Shadowed Impact Buckler
  205161, -- Plans: Heat-Resistant Rescue Ring
  206351, -- Plans: Truesilver Champion
  206352, -- Plans: The Shatterer
  206419, -- Plans: Icebane Coif
  206420, -- Plans: Icebane Mantle
  206421, -- Plans: Icebane Breastplate
  206422, -- Plans: Icebane Bracers
  206423, -- Plans: Icebane Gauntlets
  206424, -- Plans: Icebane Waistguard
  206425, -- Plans: Icebane Leggings
  206426, -- Plans: Icebane Trudgers
  206522, -- Ancient Plans: Warsword of Caer Darrow
  206525, -- Ancient Plans: Darrowdirk
  206526, -- Ancient Plans: Darrowshire Protector
  206527, -- Ancient Plans: Mirah's Lullaby
  206531, -- Ancient Plans: Strength of Menethil
  206533, -- Ancient Plans: Midnight's Graze
  206534, -- Ancient Plans: Weaver's Fang
  206535, -- Ancient Plans: Widow's Weep
  206536, -- Ancient Plans: Shade's Blade
  206537, -- Ancient Plans: Edict of the Redeemed Crusader
  206539, -- Ancient Plans: Blade of Unholy Might
  206540, -- Ancient Plans: Axe of Sundered Bone
  206541, -- Ancient Plans: The Plague Belcher
  206542, -- Ancient Plans: Bracers of Vengeance
  206544, -- Ancient Plans: The Final Dream
  206545, -- Ancient Plans: Plated Construct's Ribcage
  206546, -- Ancient Plans: Blade of the Fallen Seraph
  206549, -- Ancient Plans: The Face of Doom
  206550, -- Ancient Plans: Harbinger of Death
  206553, -- Ancient Plans: Dawn of Demise
  206555, -- Ancient Plans: Gauntlets of the Unrelenting
  206557, -- Ancient Plans: Death's Gamble
  206558, -- Ancient Plans: Belt of the Mentor
  206560, -- Ancient Plans: Stygian Shield
  206774, -- Plans: Undeath Metal
  206805, -- Ancient Plans: Bucket Kickers
  207567, -- Ancient Plans: Intrepid Shortblade
  207568, -- Ancient Plans: Valiant Shortblade
  207572, -- Ancient Plans: Sacred Guardian
  207573, -- Ancient Plans: Ichor Slicer
  208281, -- Plans: Verdant Combatant's Draconium Helm
  208282, -- Plans: Verdant Combatant's Draconium Breastplate
  208283, -- Plans: Verdant Combatant's Draconium Greaves
  208284, -- Plans: Verdant Combatant's Draconium Pauldrons
  208285, -- Plans: Verdant Combatant's Draconium Gauntlets
  208286, -- Plans: Verdant Combatant's Draconium Sabatons
  208287, -- Plans: Verdant Combatant's Draconium Armguards
  208288, -- Plans: Verdant Combatant's Draconium Waistguard
  210644, -- Plans: Flourishing Dream Helm
  211580, -- Plans: Draconic Combatant's Draconium Helm
  211581, -- Plans: Draconic Combatant's Draconium Breastplate
  211582, -- Plans: Draconic Combatant's Draconium Greaves
  211583, -- Plans: Draconic Combatant's Draconium Pauldrons
  211584, -- Plans: Draconic Combatant's Draconium Gauntlets
  211585, -- Plans: Draconic Combatant's Draconium Sabatons
  211586, -- Plans: Draconic Combatant's Draconium Armguards
  211587, -- Plans: Draconic Combatant's Draconium Waistguard
}

-- Cooking Recipes
database["CookingRecipes"] = {
  194964, -- Recipe: Thrice-Spiced Mammoth Kabob
  194965, -- Recipe: Yusa's Hearty Stew
  195881, -- Recipe: Charred Hornswog Steaks
  198092, -- Recipe: Twice-Baked Potato
  198093, -- Recipe: Cheese and Quackers
  198094, -- Recipe: Mackerel Snackerel
  198095, -- Recipe: Probably Protein
  198096, -- Recipe: Sweet and Sour Clam Chowder
  198097, -- Recipe: Hungry Whelpling Breakfast
  198098, -- Recipe: Ooey-Gooey Chocolate
  198099, -- Recipe: Pebbled Rock Salts
  198100, -- Recipe: Assorted Exotic Spices
  198101, -- Recipe: Salad on the Side
  198102, -- Recipe: Impossibly Sharp Cutting Knife
  198103, -- Recipe: Snow in a Cone
  198104, -- Recipe: Blubbery Muffin
  198105, -- Recipe: Celebratory Cake
  198106, -- Recipe: Tasty Hatchling's Treat
  198107, -- Recipe: Zesty Water
  198108, -- Recipe: Delicious Dragon Spittle
  198109, -- Recipe: Churnbelly Tea
  198110, -- ERROR1
  198111, -- Recipe: Scrambled Basilisk Eggs
  198112, -- Recipe: Hopefully Healthy
  198113, -- Recipe: Timely Demise
  198114, -- Recipe: Filet of Fangs
  198115, -- Recipe: Seamoth Surprise
  198116, -- Recipe: Salt-Baked Fishcake
  198117, -- Recipe: Feisty Fish Sticks
  198118, -- Recipe: Aromatic Seafood Platter
  198119, -- Recipe: Sizzling Seafood Medley
  198120, -- Recipe: Revenge, Served Cold
  198121, -- Recipe: Thousandbone Tongueslicer
  198122, -- Recipe: Great Cerulean Sea
  198123, -- Recipe: Braised Bruffalon Brisket
  198124, -- Recipe: Riverside Picnic
  198125, -- Recipe: Roast Duck Delight
  198126, -- Recipe: Salted Meat Mash
  198127, -- Recipe: Fated Fortune Cookie
  198129, -- Recipe: Gral's Reverence
  198130, -- Recipe: Gral's Veneration
  198131, -- Recipe: Gral's Devotion
  198132, -- Recipe: Hoard of Draconic Delicacies
  201784, -- Recipe: Timely Demise
  201785, -- Recipe: Seamoth Surprise
  201786, -- Recipe: Salt-Baked Fishcake
  201787, -- Recipe: Filet of Fangs
  202249, -- Recipe: Goldthorn Tea
  202289, -- Recipe: Firewater Sorbet
  203422, -- Recipe: Sparkling Spice Pouch
  204073, -- Ratcipe: Deviously Deviled Eggs
  204847, -- Recipe: Rocks on the Rocks
  204849, -- Ratcipe: Charitable Cheddar
  210242, -- Recipe: Slumbering Peacebloom Tea
  210496, -- ERROR1
}

-- Enchanting Recipes
database["EnchantingRecipes"] = {
  199802, -- Formula: Enchant Tool - Draconic Finesse
  199803, -- Formula: Enchant Tool - Draconic Perception
  199804, -- Formula: Enchant Tool - Draconic Deftness
  199811, -- Formula: Enchant Cloak - Graceful Avoidance
  199812, -- Formula: Enchant Boots - Rider's Reassurance
  199813, -- Formula: Enchant Chest - Sustained Strength
  199814, -- Formula: Enchant Boots - Plainsrunner's Breeze
  199815, -- Formula: Enchant Cloak - Regenerative Leech
  199816, -- Formula: Enchant Chest - Accelerated Agility
  199817, -- Formula: Enchant Cloak - Homebound Speed
  199818, -- Formula: Enchant Boots - Watcher's Loam
  200911, -- Formula: Illusion: Primal Air
  200912, -- Formula: Illusion: Primal Earth
  200913, -- Formula: Illusion: Primal Fire
  200914, -- Formula: Illusion: Primal Frost
  200916, -- Formula: Illusion: Primal Mastery
  203423, -- Formula: Glowing Crystal Bookmark
  203838, -- Ancient Formula: Mindslave's Reach
  204975, -- Formula: Enchant Weapon - Shadowflame Wreathe
  204976, -- Formula: Spore Keeper's Baton
  204977, -- Formula: Illusory Adornment: Spores
  204978, -- Formula: Enchant Weapon - Spore Tender
  205337, -- Formula: Titan Training Matrix V
  205338, -- Formula: Enchanted Whelpling's Shadowflame Crest
  205339, -- Formula: Enchanted Wyrm's Shadowflame Crest
  205340, -- Formula: Enchanted Aspect's Shadowflame Crest
  207569, -- Ancient Formula: Magebane Nexus
  207570, -- Ancient Formula: Smoked Fireshooter
  207571, -- Ancient Formula: Stormwatcher
  210171, -- Formula: Enchanted Aspect's Dreaming Crest
  210172, -- Formula: Enchanted Wyrm's Dreaming Crest
  210173, -- Formula: Enchanted Whelpling's Dreaming Crest
  210174, -- Formula: Illusory Adornment: Dreams
  210175, -- Formula: Enchant Weapon - Dreaming Devotion
  211524, -- ERROR1
  211525, -- ERROR1
  211526, -- ERROR1
  218269, -- Draconic Tome of Awakening
}

-- Engineering Recipes
database["EngineeringRecipes"] = {
  198780, -- ERROR1
  198781, -- Schematic: Gravitational Displacer
  198782, -- Schematic: Bottomless Mireslush Ore Satchel
  198783, -- Schematic: Spring-Loaded Khaz'gorite Fabric Cutters
  198784, -- Schematic: Primal Deconstruction Charge
  198785, -- Schematic: Quack-E
  199221, -- Schematic: Element-Infused Rocket Helmet
  199222, -- Schematic: Overengineered Sleeve Extenders
  199223, -- Schematic: Needlessly Complex Wristguards
  199224, -- Schematic: Complicated Cuffs
  199225, -- Schematic: Difficult Wrist Protectors
  199226, -- Schematic: P.E.W. x2
  199227, -- Schematic: Ol' Smoky
  199228, -- Schematic: Grease Grenade
  199229, -- Schematic: Tinker: Breath of Neltharion
  199230, -- Schematic: Projectile Propulsion Pinion
  199231, -- Schematic: High Intensity Thermal Scanner
  199232, -- Schematic: Bundle of Fireworks
  199233, -- Schematic: S.A.V.I.O.R.
  199234, -- Schematic: Khaz'gorite Fisherfriend
  199235, -- Schematic: Creature Combustion Canister
  199236, -- Schematic: D.U.C.K.O.Y.
  199238, -- Schematic: Sticky Warp Grenade
  199239, -- Schematic: Tinker: Alarm-O-Turret
  199240, -- Schematic: Green Fireflight
  199241, -- Schematic: H.E.L.P.
  199242, -- Schematic: Portable Alchemist's Lab Bench
  199243, -- Schematic: Portable Tinker's Workbench
  199244, -- Schematic: Khaz'gorite Delver's Helmet
  199245, -- Schematic: Lapidary's Khaz'gorite Clamps
  199246, -- Schematic: Tinker: Grounded Circuitry
  199247, -- Schematic: Haphazardly Tethered Wires
  199248, -- Schematic: Overcharged Overclocker
  199249, -- Schematic: Critical Failure Prevention Unit
  199250, -- Schematic: Calibrated Safety Switch
  199251, -- Schematic: Magazine of Healing Darts
  199252, -- Schematic: I.W.I.N. Button Mk10
  199253, -- Schematic: Suspiciously Ticking Crate
  199254, -- Schematic: EZ-Thro Creature Combustion Canister
  199255, -- Schematic: EZ-Thro Gravitational Displacer
  199256, -- Schematic: EZ-Thro Primal Deconstruction Charge
  199257, -- Schematic: Suspiciously Silent Crate
  199258, -- Schematic: Tinker: Supercollide-O-Tron
  199259, -- Schematic: Razor-Sharp Gear
  199260, -- Schematic: Rapidly Ticking Gear
  199261, -- Schematic: Meticulously Tuned Gear
  199262, -- Schematic: One-Size-Fits-All Gear
  199263, -- Schematic: Completely Safe Rockets
  199264, -- Schematic: Endless Stack of Needles
  199265, -- Schematic: Wyrmhole Generator
  199266, -- Schematic: Centralized Precipitation Emitter
  199267, -- Schematic: Environmental Emulator
  199268, -- Schematic: Giggle Goggles
  199270, -- Schematic: Quality-Assured Optics
  199271, -- Schematic: Milestone Magnifiers
  199272, -- Schematic: Deadline Deadeyes
  199273, -- Schematic: Sentry's Stabilized Specs
  199274, -- Schematic: Lightweight Ocular Lenses
  199275, -- Schematic: Peripheral Vision Projectors
  199276, -- Schematic: Oscillating Wilderness Opticals
  199277, -- Schematic: Battle-Ready Binoculars
  199278, -- Schematic: Draconium Delver's Helmet
  199279, -- Schematic: Bottomless Stonecrust Ore Satchel
  199280, -- Schematic: Draconium Fisherfriend
  199281, -- Schematic: Lapidary's Draconium Clamps
  199282, -- Schematic: Spring-Loaded Draconium Fabric Cutters
  199283, -- Schematic: Draconium Encased Samophlange
  199284, -- Schematic: Draconium Brainwave Amplifier
  199285, -- Schematic: Khaz'gorite Encased Samophlange
  199286, -- Schematic: Khaz'gorite Brainwave Amplifier
  199287, -- Schematic: Tinker: Plane Displacer
  199288, -- Schematic: Gyroscopic Kaleidoscope
  199289, -- Schematic: Blue Fireflight
  199290, -- Schematic: Red Fireflight
  199291, -- ERROR1
  199292, -- ERROR1
  199293, -- Schematic: Neural Silencer Mk3
  199294, -- Schematic: Atomic Recalibrator
  199295, -- Schematic: Black Fireflight
  199296, -- Schematic: Bronze Fireflight
  199297, -- Schematic: Spring-Loaded Capacitor Casing
  199298, -- ERROR1
  199299, -- Schematic: Tinker: Polarity Amplifier
  199300, -- Schematic: EZ-Thro Grease Grenade
  199415, -- Schematic: Zapthrottle Soul Inhaler
  199685, -- ERROR1
  201794, -- Schematic: Tranquil Mechanical Yeti
  202228, -- Schematic: Impressive Linkgrease Locksprocket
  202229, -- Schematic: Remarkable Linkgrease Locksprocket
  202230, -- Schematic: Impressive True Iron Trigger
  202231, -- Schematic: Remarkable True Iron Trigger
  203424, -- Schematic: Gnomish Voicebox
  204844, -- Schematic: Polarity Bomb
  205036, -- Schematic: Tinker: Shadowflame Rockets
  205178, -- Schematic: Mallard Mortar
  205282, -- Schematic: Obsidian Combatant's Cloth Goggles
  205283, -- Schematic: Obsidian Combatant's Leather Goggles
  205284, -- Schematic: Obsidian Combatant's Mail Goggles
  205285, -- Schematic: Obsidian Combatant's Plate Goggles
  206559, -- Ancient Schematic: Replaced Servo Arm
  207461, -- Schematic: Portable Party Platter
  207574, -- Ancient Schematic: Skullstone Bludgeon
  207576, -- Ancient Schematic: Refurbished Purifier
  208317, -- Schematic: Verdant Combatant's Cloth Goggles
  208318, -- Schematic: Verdant Combatant's Leather Goggles
  208319, -- Schematic: Verdant Combatant's Mail Goggles
  208320, -- Schematic: Verdant Combatant's Plate Goggles
  211616, -- Schematic: Draconic Combatant's Cloth Goggles
  211617, -- Schematic: Draconic Combatant's Leather Goggles
  211618, -- Schematic: Draconic Combatant's Mail Goggles
  211619, -- Schematic: Draconic Combatant's Plate Goggles
}

-- Inscription Recipes
database["InscriptionRecipes"] = {
  198390, -- Milling
  198598, -- Technique: Scroll of Sales
  198788, -- Technique: Contract: Dragonscale Expedition
  198874, -- Technique: Kinetic Pillar of the Isles
  198875, -- Technique: Illuminating Pillar of the Isles
  198876, -- Technique: Weathered Explorer's Stave
  198877, -- Technique: Pioneer's Writhebark Stave
  198878, -- Technique: Overseer's Writhebark Stave
  198879, -- Technique: Draconic Treatise on Alchemy
  198880, -- Technique: Draconic Treatise on Engineering
  198881, -- Technique: Draconic Treatise on Blacksmithing
  198882, -- Technique: Bundle O' Cards: Dragon Isles
  198883, -- Technique: Draconic Treatise on Enchanting
  198884, -- Technique: Draconic Treatise on Herbalism
  198885, -- Technique: Draconic Treatise on Inscription
  198886, -- Technique: Draconic Treatise on Jewelcrafting
  198887, -- Technique: Draconic Treatise on Leatherworking
  198888, -- Technique: Draconic Treatise on Mining
  198889, -- Technique: Draconic Treatise on Tailoring
  198891, -- Technique: Cliffside Wylderdrake: Conical Head
  198892, -- Technique: Cliffside Wylderdrake: Red Hair
  198893, -- Technique: Cliffside Wylderdrake: Triple Head Horns
  198894, -- Technique: Highland Drake: Black Hair
  198895, -- Technique: Highland Drake: Spined Head
  198896, -- Technique: Highland Drake: Spined Neck
  198899, -- Technique: Renewed Proto-Drake: Predator Pattern
  198901, -- Technique: Renewed Proto-Drake: Spined Crest
  198902, -- Technique: Windborne Velocidrake: Black Fur
  198903, -- Technique: Windborne Velocidrake: Spined Head
  198904, -- Technique: Windborne Velocidrake: Windswept Pattern
  198905, -- Technique: Illusion Parchment: Aqua Torrent
  198906, -- Technique: Illusion Parchment: Arcane Burst
  198907, -- Technique: Illusion Parchment: Chilling Wind
  198908, -- Technique: Illusion Parchment: Love Charm
  198909, -- Technique: Illusion Parchment: Magma Missile
  198910, -- Technique: Illusion Parchment: Shadow Orb
  198911, -- Technique: Illusion Parchment: Spell Shield
  198912, -- Technique: Illusion Parchment: Whirling Breeze
  198913, -- Technique: Chilled Rune
  198914, -- Technique: Flourishing Fortune
  198915, -- Technique: Blazing Fortune
  198916, -- Technique: Serene Fortune
  198917, -- Technique: Buzzing Rune
  198918, -- Technique: Howling Rune
  198919, -- Technique: Chirping Rune
  198920, -- Technique: Draconic Missive of the Fireflash
  198921, -- Technique: Draconic Missive of the Peerless
  198922, -- Technique: Azurescale Sigil
  198923, -- Technique: Sagescale Sigil
  198924, -- Technique: Emberscale Sigil
  198925, -- Technique: Bronzescale Sigil
  198926, -- Technique: Jetscale Sigil
  198927, -- Technique: Draconic Missive of the Quickblade
  198928, -- Technique: Draconic Missive of the Aurora
  198929, -- Technique: Draconic Missive of the Harmonious
  198930, -- Technique: Runed Writhebark
  198931, -- Technique: Draconic Missive of the Feverflare
  198932, -- Technique: Burnished Ink
  198933, -- Technique: Cosmic Ink
  198934, -- Technique: Blazing Ink
  198935, -- Technique: Flourishing Ink
  198936, -- Technique: Serene Ink
  198937, -- Technique: Contract: Maruuk Centaur
  198938, -- Technique: Contract: Artisan's Consortium
  198940, -- Technique: Contract: Iskaara Tuskarr
  198941, -- Technique: Contract: Valdrakken Accord
  198942, -- Technique: Alchemist's Sturdy Mixing Rod
  198943, -- Technique: Alchemist's Brilliant Mixing Rod
  198946, -- Technique: Chef's Smooth Rolling Pin
  198947, -- Technique: Chef's Splendid Rolling Pin
  198950, -- Technique: Scribe's Fastened Quill
  198951, -- Technique: Scribe's Resplendent Quill
  198952, -- Technique: Darkmoon Deck Box: Dance
  198953, -- Technique: Darkmoon Deck Box: Watcher
  198954, -- Technique: Darkmoon Deck Box: Rime
  198955, -- Technique: Darkmoon Deck Box: Inferno
  198956, -- Technique: Vantus Rune: Vault of the Incarnates
  198957, -- Technique: Crackling Codex of the Isles
  198958, -- Technique: Core Explorer's Compendium
  199901, -- Extraction: Awakened Fire
  199903, -- Extraction: Awakened Frost
  199904, -- Extraction: Awakened Air
  199905, -- Extraction: Awakened Earth
  199927, -- ERROR1
  200599, -- Technique: Draconic Missive of Inspiration
  200600, -- Technique: Draconic Missive of Resourcefulness
  200601, -- Technique: Draconic Missive of Multicraft
  200602, -- Technique: Draconic Missive of Crafting Speed
  200603, -- Technique: Draconic Missive of Finesse
  200604, -- Technique: Draconic Missive of Perception
  200605, -- Technique: Draconic Missive of Deftness
  201026, -- Technique: Draconic Treatise on Skinning
  201734, -- Technique: Cliffside Wylderdrake: Silver and Blue Armor
  201735, -- Technique: Highland Drake: Silver and Blue Armor
  201736, -- Technique: Cliffside Wylderdrake: Steel and Yellow Armor
  201737, -- Technique: Highland Drake: Steel and Yellow Armor
  201738, -- Technique: Renewed Proto-Drake: Steel and Yellow Armor
  201739, -- Technique: Windborne Velocidrake: Steel and Yellow Armor
  201741, -- Technique: Renewed Proto-Drake: Bovine Horns
  201742, -- Technique: Renewed Proto-Drake: Silver and Blue Armor
  201743, -- Technique: Windborne Velocidrake: Silver and Blue Armor
  202236, -- Technique: Impressive Weapon Crystal
  202237, -- Technique: Remarkable Weapon Crystal
  203378, -- Technique: Crimson Combatant's Medallion
  203379, -- Technique: Crimson Combatant's Insignia of Alacrity
  203380, -- Technique: Crimson Combatant's Emblem
  203425, -- Technique: Arcane Dispelling Rune
  203839, -- Ancient Technique: Gurubashi Hoodoo Stick
  203840, -- Ancient Technique: Judgment of the Gurubashi
  203841, -- Ancient Technique: Gurubashi Ceremonial Staff
  204167, -- Technique: Obsidian Combatant's Medallion
  204168, -- Technique: Obsidian Combatant's Insignia of Alacrity
  204169, -- Technique: Obsidian Combatant's Emblem
  205127, -- Technique: Winding Slitherdrake: Blue and Silver Armor
  205128, -- Technique: Winding Slitherdrake: Yellow and Silver Armor
  205129, -- Technique: Winding Slitherdrake: Curved Chin Horn
  205130, -- Technique: Winding Slitherdrake: White Hair
  205131, -- Technique: Winding Slitherdrake: Small Finned Throat
  205132, -- Technique: Glyph of the Chosen Glaive
  205133, -- Technique: Glyph of the Heaved Armament
  205134, -- Technique: Vantus Rune: Aberrus, the Shadowed Crucible
  205135, -- Technique: Hissing Rune
  205136, -- Technique: Contract: Loamm Niffen
  206528, -- Ancient Technique: Shifting Sliver
  206532, -- Ancient Technique: Soulscryer
  206548, -- Ancient Technique: Encased Frigid Heart
  207091, -- Technique: Glyph of the Shath'Yar
  207575, -- Ancient Technique: Wanderer's Guide
  208310, -- Technique: Verdant Combatant's Medallion
  208311, -- Technique: Verdant Combatant's Insignia of Alacrity
  208312, -- Technique: Verdant Combatant's Emblem
  210243, -- Technique: Contract: Dream Wardens
  210490, -- Technique: Vantus Rune: Amirdrassil, the Dream's Hope
  210491, -- Technique: Winding Slitherdrake: Hairy Chin
  210492, -- Technique: Grotto Netherwing Drake: Chin Tendrils
  210493, -- Technique: Grotto Netherwing Drake: Spiked Jaw
  211065, -- Technique: Mark of the Auric Dreamstag
  211399, -- Technique: Glyph of the Lunar Chameleon
  211609, -- Technique: Draconic Combatant's Medallion
  211610, -- Technique: Draconic Combatant's Insignia of Alacrity
  211611, -- Technique: Draconic Combatant's Emblem
}

-- Jewelcrafting Recipes
database["JewelcraftingRecipes"] = {
  194596, -- Design: Crafty Queen's Ruby
  194597, -- Design: Zen Mystic Sapphire
  194598, -- Design: Energized Vibrant Emerald
  194599, -- Design: Sensei's Sundered Onyx
  194600, -- Design: Solid Eternity Amber
  194601, -- Design: Crafty Alexstraszite
  194602, -- Design: Sensei's Alexstraszite
  194603, -- Design: Radiant Alexstraszite
  194604, -- Design: Deadly Alexstraszite
  194605, -- Design: Radiant Malygite
  194606, -- Design: Energized Malygite
  194607, -- Design: Zen Malygite
  194608, -- Design: Stormy Malygite
  194609, -- Design: Crafty Ysemerald
  194610, -- Design: Keen Ysemerald
  194611, -- Design: Energized Ysemerald
  194612, -- Design: Quick Ysemerald
  194613, -- Design: Sensei's Neltharite
  194614, -- Design: Keen Neltharite
  194615, -- Design: Zen Neltharite
  194616, -- Design: Fractured Neltharite
  194617, -- Design: Jagged Nozdorite
  194618, -- Design: Forceful Nozdorite
  194619, -- Design: Puissant Nozdorite
  194620, -- Design: Steady Nozdorite
  194621, -- Design: Inscribed Illimited Diamond
  194622, -- Design: Fierce Illimited Diamond
  194623, -- Design: Skillful Illimited Diamond
  194624, -- Design: Resplendent Illimited Diamond
  194625, -- Design: Tiered Medallion Setting
  194626, -- Design: Shimmering Clasp
  194627, -- Design: Draconic Vial
  194628, -- Design: Frameless Lens
  194629, -- Design: Chiseled Stone Block
  194630, -- Design: Blotting Sand
  194631, -- Design: Pounce
  194632, -- Design: Idol of the Life-Binder
  194633, -- Design: Idol of the Spell-Weaver
  194634, -- Design: Idol of the Dreamer
  194635, -- Design: Idol of the Earth-Warder
  194636, -- Design: Pendant of Impending Perils
  194637, -- Design: Crimson Combatant's Jeweled Amulet
  194638, -- Design: Crimson Combatant's Jeweled Signet
  194639, -- ERROR1
  194640, -- Design: Ring-Bound Hourglass
  194641, -- Design: Elemental Lariat
  194642, -- Design: Choker of Shielding
  194643, -- Design: Narcissist's Sculpture
  194644, -- Design: Revitalizing Red Carving
  194645, -- Design: Statue of Tyr's Herald
  194646, -- Design: Djaradin's "Pinata"
  194647, -- Design: Jeweled Ruby Whelpling
  194648, -- Design: Jeweled Emerald Whelpling
  194649, -- Design: Jeweled Sapphire Whelpling
  194650, -- Design: Jeweled Onyx Whelpling
  194651, -- Design: Jeweled Amber Whelpling
  194652, -- Design: Projection Prism
  194653, -- Design: Jeweled Offering
  194654, -- Design: Convergent Prism
  194656, -- Design: Bold-Print Bifocals
  194657, -- Design: Left-Handed Magnifying Glass
  194658, -- Design: Sundered Onyx Loupes
  194659, -- Design: Chromatic Focus
  194660, -- Design: Fine-Print Trifocals
  194661, -- Design: Magnificent Margin Magnifier
  194662, -- Design: Alexstraszite Loupes
  194663, -- Design: Resonant Focus
  194664, -- Design: Queen's Gift
  194665, -- Design: Dreamer's Vision
  194666, -- Design: Keeper's Glory
  194667, -- Design: Earthwarden's Prize
  194668, -- Design: Timewatcher's Patience
  194669, -- Design: Jeweled Dragon's Heart
  194670, -- Design: Elemental Harmony
  194671, -- Design: "Rhinestone" Sunglasses
  194672, -- Design: Band of New Beginnings
  194674, -- Design: Soul Drainer
  194709, -- Prospecting
  194726, -- Design: Kalu'ak Figurine
  194749, -- Design: Split-Lens Specs
  198839, -- Design: Signet of Titanic Insight
  201926, -- Crushing
  203426, -- Design: Crystal Tuning Fork
  204146, -- Design: Obsidian Combatant's Jeweled Amulet
  204147, -- Design: Obsidian Combatant's Jeweled Signet
  204216, -- Primordial Pulverizing
  204218, -- Design: Primordial Pulverizing
  204219, -- Design: Unstable Elementium
  204406, -- Ancient Design: Square Holders
  205174, -- Design: B.B.F. Fist
  205175, -- Design: Statuette of Foreseen Power
  205176, -- Design: Figurine of the Gathering Storm
  206543, -- Ancient Design: Gem of the Nerubians
  206551, -- Ancient Design: Frostwyrm's Icy Gaze
  206552, -- Ancient Design: Frostwyrm's Frigid Stare
  208289, -- Design: Verdant Combatant's Jeweled Amulet
  208290, -- Design: Verdant Combatant's Jeweled Signet
  210170, -- Design: Dreamtender's Charm
  211588, -- Design: Draconic Combatant's Jeweled Amulet
  211589, -- Design: Draconic Combatant's Jeweled Signet
}

-- Leatherworking Recipes
database["LeatherworkingRecipes"] = {
  193868, -- Pattern: Slimy Expulsion Boots
  193869, -- Pattern: Toxic Thorn Footwraps
  193870, -- Pattern: Allied Legguards of Sansok Khan
  193871, -- Pattern: Infurious Spirit's Hood
  193872, -- Pattern: String of Spiritual Knick-Knacks
  193873, -- Pattern: Old Spirit's Wristwraps
  193875, -- Pattern: Allied Heartwarming Fur Coat
  193876, -- Pattern: Snowball Makers
  193877, -- Pattern: Infurious Boots of Reprieve
  193878, -- Pattern: Ancestor's Dew Drippers
  193879, -- Pattern: Infurious Footwraps of Indemnity
  193880, -- Pattern: Wind Spirit's Lasso
  193881, -- Pattern: Scale Rein Grips
  193882, -- Pattern: Acidic Hailstone Treads
  193883, -- Pattern: Venom-Steeped Stompers
  193884, -- Pattern: Infurious Chainhelm Protector
  194311, -- Pattern: Tuskarr Beanbag
  194312, -- Pattern: Gnoll Tent
  197964, -- Pattern: Crimson Combatant's Resilient Mask
  197965, -- Pattern: Crimson Combatant's Resilient Chestpiece
  197966, -- Pattern: Crimson Combatant's Resilient Trousers
  197967, -- Pattern: Crimson Combatant's Resilient Shoulderpads
  197968, -- Pattern: Crimson Combatant's Resilient Boots
  197969, -- Pattern: Crimson Combatant's Resilient Gloves
  197970, -- Pattern: Crimson Combatant's Resilient Wristwraps
  197971, -- Pattern: Crimson Combatant's Resilient Belt
  197972, -- Pattern: Crimson Combatant's Adamant Cowl
  197973, -- Pattern: Crimson Combatant's Adamant Chainmail
  197974, -- Pattern: Crimson Combatant's Adamant Leggings
  197975, -- Pattern: Crimson Combatant's Adamant Epaulettes
  197976, -- Pattern: Crimson Combatant's Adamant Treads
  197977, -- Pattern: Crimson Combatant's Adamant Gauntlets
  197978, -- Pattern: Crimson Combatant's Adamant Cuffs
  197979, -- Pattern: Crimson Combatant's Adamant Girdle
  197981, -- Pattern: Finished Prototype Regal Barding
  197982, -- Pattern: Finished Prototype Explorer's Barding
  198457, -- Pattern: Masterwork Smock
  198458, -- Pattern: Resplendent Cover
  198459, -- Pattern: Lavish Floral Pack
  198461, -- Pattern: Shockproof Gloves
  198462, -- Pattern: Flameproof Apron
  198463, -- Pattern: Expert Alchemist's Hat
  198464, -- Pattern: Reinforced Pack
  198465, -- Pattern: Expert Skinner's Cap
  198618, -- Pattern: Artisan's Sign
  200103, -- Pattern: Infurious Hide
  200104, -- Pattern: Infurious Scales
  201257, -- Bloodstained Pattern: Infurious Hide
  201259, -- Bloodstained Pattern: Infurious Scales
  201732, -- Pattern: Fierce Armor Kit
  201733, -- Pattern: Frosted Armor Kit
  202232, -- Pattern: Impressive Burnished Essence
  202233, -- Pattern: Remarkable Burnished Essence
  203427, -- Pattern: Reinforced Pristine Leather
  203842, -- Ancient Pattern: Animist's Footwraps
  203843, -- Ancient Pattern: Animist's Legguards
  203844, -- Ancient Pattern: Gloves of the Tormentor
  203845, -- Ancient Pattern: Junglefury Gauntlets
  203846, -- Ancient Pattern: Junglefury Leggings
  203847, -- Ancient Pattern: Gurubashi's Grasp
  203968, -- Ancient Pattern: Cord of Shriveled Heads
  204148, -- Pattern: Obsidian Combatant's Resilient Mask
  204149, -- Pattern: Obsidian Combatant's Resilient Chestpiece
  204150, -- Pattern: Obsidian Combatant's Resilient Trousers
  204151, -- Pattern: Obsidian Combatant's Resilient Shoulderpads
  204152, -- Pattern: Obsidian Combatant's Resilient Boots
  204153, -- Pattern: Obsidian Combatant's Resilient Gloves
  204154, -- Pattern: Obsidian Combatant's Resilient Wristwraps
  204155, -- Pattern: Obsidian Combatant's Resilient Belt
  204156, -- Pattern: Obsidian Combatant's Adamant Cowl
  204157, -- Pattern: Obsidian Combatant's Adamant Chainmail
  204158, -- Pattern: Obsidian Combatant's Adamant Leggings
  204159, -- Pattern: Obsidian Combatant's Adamant Epaulettes
  204160, -- Pattern: Obsidian Combatant's Adamant Treads
  204161, -- Pattern: Obsidian Combatant's Adamant Gauntlets
  204162, -- Pattern: Obsidian Combatant's Adamant Cuffs
  204163, -- Pattern: Obsidian Combatant's Adamant Girdle
  204968, -- Pattern: Shadowflame-Tempered Armor Patch
  204969, -- Pattern: Spore Colony Shoulderguards
  204970, -- Pattern: Adaptive Dracothyst Armguards
  204974, -- Pattern: Lambent Armor Kit
  206403, -- Pattern: Polar Helm
  206404, -- Pattern: Polar Spaulders
  206405, -- Pattern: Polar Tunic
  206406, -- Pattern: Polar Bracers
  206407, -- Pattern: Polar Gloves
  206408, -- Pattern: Polar Belt
  206409, -- Pattern: Polar Leggings
  206410, -- Pattern: Polar Footwarmers
  206411, -- Pattern: Icy Scale Crown
  206412, -- Pattern: Icy Scale Shoulderpads
  206413, -- Pattern: Icy Scale Breastplate
  206414, -- Pattern: Icy Scale Bracers
  206415, -- Pattern: Icy Scale Gauntlets
  206416, -- Pattern: Icy Scale Waistwrap
  206417, -- Pattern: Icy Scale Leggings
  206418, -- Pattern: Icy Scale Stompers
  206529, -- Ancient Pattern: Helm of Lingering Power
  206530, -- Ancient Pattern: Skyfury Headdress
  206538, -- Ancient Pattern: Nerubian Persuader
  206556, -- Ancient Pattern: Displacement Boots
  206561, -- Ancient Pattern: Lucien's Lost Soles
  206772, -- Pattern: Languished Leather
  206773, -- Pattern: Scourged Scales
  207577, -- Ancient Pattern: Sanctified Leather Hat
  208291, -- Pattern: Verdant Combatant's Resilient Mask
  208292, -- Pattern: Verdant Combatant's Resilient Chestpiece
  208293, -- Pattern: Verdant Combatant's Resilient Trousers
  208294, -- Pattern: Verdant Combatant's Resilient Shoulderpads
  208295, -- Pattern: Verdant Combatant's Resilient Boots
  208296, -- Pattern: Verdant Combatant's Resilient Gloves
  208297, -- Pattern: Verdant Combatant's Resilient Wristwraps
  208298, -- Pattern: Verdant Combatant's Resilient Belt
  208299, -- Pattern: Verdant Combatant's Adamant Cowl
  208300, -- Pattern: Verdant Combatant's Adamant Chainmail
  208301, -- Pattern: Verdant Combatant's Adamant Leggings
  208302, -- Pattern: Verdant Combatant's Adamant Epaulets
  208303, -- Pattern: Verdant Combatant's Adamant Treads
  208304, -- Pattern: Verdant Combatant's Adamant Gauntlets
  208305, -- Pattern: Verdant Combatant's Adamant Cuffs
  208306, -- Pattern: Verdant Combatant's Adamant Girdle
  210169, -- Pattern: Verdant Conduit
  211590, -- Pattern: Draconic Combatant's Resilient Mask
  211591, -- Pattern: Draconic Combatant's Resilient Chestpiece
  211592, -- Pattern: Draconic Combatant's Resilient Trousers
  211593, -- Pattern: Draconic Combatant's Resilient Shoulderpads
  211594, -- Pattern: Draconic Combatant's Resilient Boots
  211595, -- Pattern: Draconic Combatant's Resilient Gloves
  211596, -- Pattern: Draconic Combatant's Resilient Wristwraps
  211597, -- Pattern: Draconic Combatant's Resilient Belt
  211598, -- Pattern: Draconic Combatant's Adamant Cowl
  211599, -- Pattern: Draconic Combatant's Adamant Chainmail
  211600, -- Pattern: Draconic Combatant's Adamant Leggings
  211601, -- Pattern: Draconic Combatant's Adamant Epaulets
  211602, -- Pattern: Draconic Combatant's Adamant Treads
  211603, -- Pattern: Draconic Combatant's Adamant Gauntlets
  211604, -- Pattern: Draconic Combatant's Adamant Cuffs
  211605, -- Pattern: Draconic Combatant's Adamant Girdle
}

-- Tailoring Recipes
database["TailoringRecipes"] = {
  194127, -- Dragon Isles Unravelling
  194255, -- Pattern: Amice of the Blue
  194256, -- Pattern: Hood of Surging Time
  194257, -- Pattern: Infurious Binding of Gesticulation
  194258, -- Pattern: Infurious Legwraps of Possibility
  194259, -- Pattern: Allied Wristguards of Time Dilation
  194260, -- Pattern: Blue Dragon Soles
  194261, -- Pattern: Frozen Spellthread
  194262, -- Pattern: Temporal Spellthread
  194263, -- Pattern: Blue Dragon Rider's Robe
  194264, -- Pattern: Bronze Dragon Rider's Wraps
  194265, -- Pattern: Blue Silken Lining
  194266, -- Pattern: Bronzed Grip Wrappings
  194267, -- Pattern: Shimmering Embroidery Thread
  194268, -- Pattern: Dragonscale Expedition's Expedition Tent
  194269, -- Pattern: Infurious Wildercloth Bolt
  194270, -- Pattern: Crimson Combatant's Wildercloth Bands
  194271, -- Pattern: Crimson Combatant's Wildercloth Cloak
  194272, -- Pattern: Crimson Combatant's Wildercloth Gloves
  194273, -- Pattern: Crimson Combatant's Wildercloth Hood
  194274, -- Pattern: Crimson Combatant's Wildercloth Leggings
  194275, -- Pattern: Crimson Combatant's Wildercloth Sash
  194276, -- Pattern: Crimson Combatant's Wildercloth Shoulderpads
  194277, -- Pattern: Crimson Combatant's Wildercloth Treads
  194278, -- Pattern: Crimson Combatant's Wildercloth Tunic
  194279, -- Pattern: Azureweave Slippers
  194280, -- Pattern: Chronocloth Sash
  194281, -- Pattern: Cold Cushion
  194282, -- Pattern: Cushion of Time Travel
  194283, -- Pattern: Duck-Stuffed Duck Lovie
  194284, -- Pattern: Wildercloth Weapon Upholstery
  194285, -- Pattern: Azureweave Expedition Pack
  194286, -- Pattern: Chromatic Embroidery Thread
  194287, -- Pattern: Chronocloth Reagent Bag
  194288, -- Pattern: Master's Wildercloth Alchemist's Robe
  194289, -- Pattern: Master's Wildercloth Chef's Hat
  194290, -- Pattern: Master's Wildercloth Enchanter's Hat
  194291, -- Pattern: Master's Wildercloth Fishing Cap
  194292, -- Pattern: Master's Wildercloth Gardening Hat
  194293, -- Pattern: Vibrant Polishing Cloth
  194294, -- Pattern: Explorer's Banner of Herbology
  194295, -- Pattern: Explorer's Banner of Geology
  194296, -- Pattern: Fiddle with Draconium Fabric Cutters
  194297, -- Pattern: Fiddle with Khaz'gorite Fabric Cutters
  194298, -- Pattern: Forlorn Funeral Pall
  194537, -- Fiddle with Draconium Fabric Cutters
  194538, -- Fiddle with Khaz'gorite Fabric Cutters
  201258, -- Bloodstained Pattern: Infurious Wildercloth Bolt
  202234, -- Pattern: Impressive Hexweave Essence
  202235, -- Pattern: Remarkable Hexweave Essence
  203428, -- Pattern: Traditional Morqut Kite
  203848, -- Ancient Pattern: Bloodlord's Embrace
  203849, -- Ancient Pattern: Gurubashi Tigerhide Cloak
  203850, -- Ancient Pattern: Gurubashi Headdress
  203851, -- Ancient Pattern: Ritualistic Legwarmers
  204129, -- Pattern: Obsidian Combatant's Wildercloth Bands
  204130, -- Pattern: Obsidian Combatant's Wildercloth Cloak
  204131, -- Pattern: Obsidian Combatant's Wildercloth Gloves
  204132, -- Pattern: Obsidian Combatant's Wildercloth Hood
  204133, -- Pattern: Obsidian Combatant's Wildercloth Leggings
  204134, -- Pattern: Obsidian Combatant's Wildercloth Sash
  204135, -- Pattern: Obsidian Combatant's Wildercloth Shoulderpads
  204136, -- Pattern: Obsidian Combatant's Wildercloth Treads
  204137, -- Pattern: Obsidian Combatant's Wildercloth Tunic
  204678, -- Pattern: Paw-Made Winterpelt Reagent Bag
  205138, -- Pattern: Medical Wrap Kit
  205139, -- Pattern: Reserve Parachute
  205140, -- Pattern: Undulating Sporecloak
  206393, -- Pattern: Glacial Cloak
  206395, -- Pattern: Glacial Chapeau
  206396, -- Pattern: Glacial Epaulets
  206397, -- Pattern: Glacial Vest
  206398, -- Pattern: Glacial Wrists
  206399, -- Pattern: Glacial Gloves
  206400, -- Pattern: Glacial Tether
  206401, -- Pattern: Glacial Leggings
  206402, -- Pattern: Glacial Footwear
  206547, -- Ancient Pattern: Bindings of the Harvested Soul
  206554, -- Ancient Pattern: Necrotic Gown
  206563, -- Ancient Pattern: Shroud of Forbidden Magic
  206583, -- Ancient Pattern: Peculiar Glacial Mantle
  206771, -- Pattern: Cursed Cloth
  208272, -- Pattern: Verdant Combatant's Wildercloth Bands
  208273, -- Pattern: Verdant Combatant's Wildercloth Cloak
  208274, -- Pattern: Verdant Combatant's Wildercloth Gloves
  208275, -- Pattern: Verdant Combatant's Wildercloth Hood
  208276, -- Pattern: Verdant Combatant's Wildercloth Leggings
  208277, -- Pattern: Verdant Combatant's Wildercloth Sash
  208278, -- Pattern: Verdant Combatant's Wildercloth Shoulderpads
  208279, -- Pattern: Verdant Combatant's Wildercloth Treads
  208280, -- Pattern: Verdant Combatant's Wildercloth Tunic
  210670, -- Pattern: Verdant Tether
  211571, -- Pattern: Draconic Combatant's Wildercloth Bands
  211572, -- Pattern: Draconic Combatant's Wildercloth Cloak
  211573, -- Pattern: Draconic Combatant's Wildercloth Gloves
  211574, -- Pattern: Draconic Combatant's Wildercloth Hood
  211575, -- Pattern: Draconic Combatant's Wildercloth Leggings
  211576, -- Pattern: Draconic Combatant's Wildercloth Sash
  211577, -- Pattern: Draconic Combatant's Wildercloth Shoulderpads
  211578, -- Pattern: Draconic Combatant's Wildercloth Treads
  211579, -- Pattern: Draconic Combatant's Wildercloth Tunic
}

-- Gems
database["Gems"] = {
  192900, -- Crafty Queen's Ruby
  192901, -- Crafty Queen's Ruby
  192902, -- Crafty Queen's Ruby
  192903, -- Zen Mystic Sapphire
  192904, -- Zen Mystic Sapphire
  192905, -- Zen Mystic Sapphire
  192906, -- Energized Vibrant Emerald
  192907, -- Energized Vibrant Emerald
  192908, -- Energized Vibrant Emerald
  192910, -- Sensei's Sundered Onyx
  192911, -- Sensei's Sundered Onyx
  192912, -- Sensei's Sundered Onyx
  192913, -- Solid Eternity Amber
  192914, -- Solid Eternity Amber
  192916, -- Solid Eternity Amber
  192917, -- Crafty Alexstraszite
  192918, -- Crafty Alexstraszite
  192919, -- Crafty Alexstraszite
  192920, -- Sensei's Alexstraszite
  192921, -- Sensei's Alexstraszite
  192922, -- Sensei's Alexstraszite
  192923, -- Radiant Alexstraszite
  192924, -- Radiant Alexstraszite
  192925, -- Radiant Alexstraszite
  192926, -- Deadly Alexstraszite
  192927, -- Deadly Alexstraszite
  192928, -- Deadly Alexstraszite
  192929, -- Radiant Malygite
  192931, -- Radiant Malygite
  192932, -- Radiant Malygite
  192933, -- Energized Malygite
  192934, -- Energized Malygite
  192935, -- Energized Malygite
  192936, -- Zen Malygite
  192937, -- Zen Malygite
  192938, -- Zen Malygite
  192940, -- Stormy Malygite
  192941, -- Stormy Malygite
  192942, -- Stormy Malygite
  192943, -- Crafty Ysemerald
  192944, -- Crafty Ysemerald
  192945, -- Crafty Ysemerald
  192946, -- Keen Ysemerald
  192947, -- Keen Ysemerald
  192948, -- Keen Ysemerald
  192950, -- Energized Ysemerald
  192951, -- Energized Ysemerald
  192952, -- Energized Ysemerald
  192953, -- Quick Ysemerald
  192954, -- Quick Ysemerald
  192955, -- Quick Ysemerald
  192956, -- Sensei's Neltharite
  192957, -- Sensei's Neltharite
  192958, -- Sensei's Neltharite
  192959, -- Keen Neltharite
  192960, -- Keen Neltharite
  192961, -- Keen Neltharite
  192962, -- Zen Neltharite
  192963, -- Zen Neltharite
  192964, -- Zen Neltharite
  192965, -- Fractured Neltharite
  192966, -- Fractured Neltharite
  192967, -- Fractured Neltharite
  192968, -- Jagged Nozdorite
  192969, -- Jagged Nozdorite
  192970, -- Jagged Nozdorite
  192971, -- Forceful Nozdorite
  192972, -- Forceful Nozdorite
  192973, -- Forceful Nozdorite
  192974, -- Puissant Nozdorite
  192975, -- Puissant Nozdorite
  192976, -- Puissant Nozdorite
  192977, -- Steady Nozdorite
  192978, -- Steady Nozdorite
  192979, -- Steady Nozdorite
  192980, -- Inscribed Illimited Diamond
  192981, -- Inscribed Illimited Diamond
  192982, -- Inscribed Illimited Diamond
  192983, -- Fierce Illimited Diamond
  192984, -- Fierce Illimited Diamond
  192985, -- Fierce Illimited Diamond
  192986, -- Skillful Illimited Diamond
  192987, -- Skillful Illimited Diamond
  192988, -- Skillful Illimited Diamond
  192989, -- Resplendent Illimited Diamond
  192990, -- Resplendent Illimited Diamond
  192991, -- Resplendent Illimited Diamond
}

-- Permanent Enhancements
database["PermanentEnhancements"] = {
  193556, -- Frosted Armor Kit
  193557, -- Fierce Armor Kit
  193559, -- Reinforced Armor Kit
  193560, -- Frosted Armor Kit
  193561, -- Fierce Armor Kit
  193563, -- Reinforced Armor Kit
  193564, -- Frosted Armor Kit
  193565, -- Fierce Armor Kit
  193567, -- Reinforced Armor Kit
  194008, -- Vibrant Spellthread
  194009, -- Vibrant Spellthread
  194010, -- Vibrant Spellthread
  194011, -- Frozen Spellthread
  194012, -- Frozen Spellthread
  194013, -- Frozen Spellthread
  194014, -- Temporal Spellthread
  194015, -- Temporal Spellthread
  194016, -- Temporal Spellthread
  198310, -- Gyroscopic Kaleidoscope
  198311, -- Gyroscopic Kaleidoscope
  198312, -- Gyroscopic Kaleidoscope
  198313, -- Projectile Propulsion Pinion
  198314, -- Projectile Propulsion Pinion
  198315, -- Projectile Propulsion Pinion
  198316, -- High Intensity Thermal Scanner
  198317, -- High Intensity Thermal Scanner
  198318, -- High Intensity Thermal Scanner
  199934, -- Enchant Boots - Plainsrunner's Breeze
  199935, -- Enchant Boots - Rider's Reassurance
  199936, -- Enchant Boots - Watcher's Loam
  199937, -- Enchant Bracer - Devotion of Avoidance
  199938, -- Enchant Bracer - Devotion of Leech
  199939, -- Enchant Bracer - Devotion of Speed
  199940, -- Enchant Bracer - Writ of Avoidance
  199941, -- Enchant Bracer - Writ of Leech
  199942, -- Enchant Bracer - Writ of Speed
  199943, -- Enchant Chest - Accelerated Agility
  199944, -- Enchant Chest - Reserve of Intellect
  199945, -- Enchant Chest - Sustained Strength
  199946, -- Enchant Chest - Waking Stats
  199947, -- Enchant Cloak - Graceful Avoidance
  199948, -- Enchant Cloak - Homebound Speed
  199949, -- Enchant Cloak - Regenerative Leech
  199950, -- Enchant Cloak - Writ of Avoidance
  199951, -- Enchant Cloak - Writ of Leech
  199952, -- Enchant Cloak - Writ of Speed
  199953, -- Enchant Ring - Devotion of Critical Strike
  199954, -- Enchant Ring - Devotion of Haste
  199955, -- Enchant Ring - Devotion of Mastery
  199956, -- Enchant Ring - Devotion of Versatility
  199957, -- Enchant Ring - Writ of Critical Strike
  199958, -- Enchant Ring - Writ of Haste
  199959, -- Enchant Ring - Writ of Mastery
  199960, -- Enchant Ring - Writ of Versatility
  199961, -- Enchant Tool - Draconic Deftness
  199962, -- Enchant Tool - Draconic Finesse
  199963, -- Enchant Tool - Draconic Inspiration
  199964, -- Enchant Tool - Draconic Perception
  199965, -- Enchant Tool - Draconic Resourcefulness
  199966, -- Enchant Weapon - Burning Devotion
  199967, -- Enchant Weapon - Burning Writ
  199968, -- Enchant Weapon - Earthen Devotion
  199969, -- Enchant Weapon - Earthen Writ
  199970, -- Enchant Weapon - Sophic Devotion
  199971, -- Enchant Weapon - Sophic Writ
  199972, -- Enchant Weapon - Frozen Devotion
  199973, -- Enchant Weapon - Frozen Writ
  199974, -- Enchant Weapon - Wafting Devotion
  199975, -- Enchant Weapon - Wafting Writ
  199976, -- Enchant Boots - Plainsrunner's Breeze
  199977, -- Enchant Boots - Rider's Reassurance
  199978, -- Enchant Boots - Watcher's Loam
  199979, -- Enchant Bracer - Devotion of Avoidance
  199980, -- Enchant Bracer - Devotion of Leech
  199981, -- Enchant Bracer - Devotion of Speed
  199982, -- Enchant Bracer - Writ of Avoidance
  199983, -- Enchant Bracer - Writ of Leech
  199984, -- Enchant Bracer - Writ of Speed
  199985, -- Enchant Chest - Accelerated Agility
  199986, -- Enchant Chest - Reserve of Intellect
  199987, -- Enchant Chest - Sustained Strength
  199988, -- Enchant Chest - Waking Stats
  199989, -- Enchant Cloak - Graceful Avoidance
  199990, -- Enchant Cloak - Homebound Speed
  199991, -- Enchant Cloak - Regenerative Leech
  199992, -- Enchant Cloak - Writ of Avoidance
  199993, -- Enchant Cloak - Writ of Leech
  199994, -- Enchant Cloak - Writ of Speed
  199995, -- Enchant Ring - Devotion of Critical Strike
  199996, -- Enchant Ring - Devotion of Haste
  199997, -- Enchant Ring - Devotion of Mastery
  199998, -- Enchant Ring - Devotion of Versatility
  199999, -- Enchant Ring - Writ of Critical Strike
  200000, -- Enchant Ring - Writ of Haste
  200001, -- Enchant Ring - Writ of Mastery
  200002, -- Enchant Ring - Writ of Versatility
  200003, -- Enchant Tool - Draconic Deftness
  200004, -- Enchant Tool - Draconic Finesse
  200005, -- Enchant Tool - Draconic Inspiration
  200006, -- Enchant Tool - Draconic Perception
  200007, -- Enchant Tool - Draconic Resourcefulness
  200008, -- Enchant Weapon - Burning Devotion
  200009, -- Enchant Weapon - Burning Writ
  200010, -- Enchant Weapon - Earthen Devotion
  200011, -- Enchant Weapon - Earthen Writ
  200012, -- Enchant Weapon - Sophic Devotion
  200013, -- Enchant Weapon - Sophic Writ
  200014, -- Enchant Weapon - Frozen Devotion
  200015, -- Enchant Weapon - Frozen Writ
  200016, -- Enchant Weapon - Wafting Devotion
  200017, -- Enchant Weapon - Wafting Writ
  200018, -- Enchant Boots - Plainsrunner's Breeze
  200019, -- Enchant Boots - Rider's Reassurance
  200020, -- Enchant Boots - Watcher's Loam
  200021, -- Enchant Bracer - Devotion of Avoidance
  200022, -- Enchant Bracer - Devotion of Leech
  200023, -- Enchant Bracer - Devotion of Speed
  200024, -- Enchant Bracer - Writ of Avoidance
  200025, -- Enchant Bracer - Writ of Leech
  200026, -- Enchant Bracer - Writ of Speed
  200027, -- Enchant Chest - Accelerated Agility
  200028, -- Enchant Chest - Reserve of Intellect
  200029, -- Enchant Chest - Sustained Strength
  200030, -- Enchant Chest - Waking Stats
  200031, -- Enchant Cloak - Graceful Avoidance
  200032, -- Enchant Cloak - Homebound Speed
  200033, -- Enchant Cloak - Regenerative Leech
  200034, -- Enchant Cloak - Writ of Avoidance
  200035, -- Enchant Cloak - Writ of Leech
  200036, -- Enchant Cloak - Writ of Speed
  200037, -- Enchant Ring - Devotion of Critical Strike
  200038, -- Enchant Ring - Devotion of Haste
  200039, -- Enchant Ring - Devotion of Mastery
  200040, -- Enchant Ring - Devotion of Versatility
  200041, -- Enchant Ring - Writ of Critical Strike
  200042, -- Enchant Ring - Writ of Haste
  200043, -- Enchant Ring - Writ of Mastery
  200044, -- Enchant Ring - Writ of Versatility
  200045, -- Enchant Tool - Draconic Deftness
  200046, -- Enchant Tool - Draconic Finesse
  200047, -- Enchant Tool - Draconic Inspiration
  200048, -- Enchant Tool - Draconic Perception
  200049, -- Enchant Tool - Draconic Resourcefulness
  200050, -- Enchant Weapon - Burning Devotion
  200051, -- Enchant Weapon - Burning Writ
  200052, -- Enchant Weapon - Earthen Devotion
  200053, -- Enchant Weapon - Earthen Writ
  200054, -- Enchant Weapon - Sophic Devotion
  200055, -- Enchant Weapon - Sophic Writ
  200056, -- Enchant Weapon - Frozen Devotion
  200057, -- Enchant Weapon - Frozen Writ
  200058, -- Enchant Weapon - Wafting Devotion
  200059, -- Enchant Weapon - Wafting Writ
  204613, -- Enchant Weapon - Spore Tender
  204614, -- Enchant Weapon - Spore Tender
  204615, -- Enchant Weapon - Spore Tender
  204621, -- Enchant Weapon - Shadowflame Wreathe
  204622, -- Enchant Weapon - Shadowflame Wreathe
  204623, -- Enchant Weapon - Shadowflame Wreathe
  204700, -- Lambent Armor Kit
  204701, -- Lambent Armor Kit
  204702, -- Lambent Armor Kit
  205039, -- Shadowed Belt Clasp
  205043, -- Shadowed Belt Clasp
  205044, -- Shadowed Belt Clasp
}

-- Temporary Enhancements
database["TemporaryEnhancements"] = {
  191933, -- Primal Whetstone
  191939, -- Primal Whetstone
  191940, -- Primal Whetstone
  191943, -- Primal Weightstone
  191944, -- Primal Weightstone
  191945, -- Primal Weightstone
  191948, -- Primal Razorstone
  191949, -- Primal Razorstone
  191950, -- Primal Razorstone
  194817, -- Howling Rune
  194819, -- Howling Rune
  194820, -- Howling Rune
  194821, -- Buzzing Rune
  194822, -- Buzzing Rune
  194823, -- Buzzing Rune
  194824, -- Chirping Rune
  194825, -- Chirping Rune
  194826, -- Chirping Rune
  198160, -- Completely Safe Rockets
  198161, -- Completely Safe Rockets
  198162, -- Completely Safe Rockets
  198163, -- Endless Stack of Needles
  198164, -- Endless Stack of Needles
  198165, -- Endless Stack of Needles
  203862, -- Brilliant Mana Oil
  203865, -- Brilliant Wizard Oil
  204971, -- Hissing Rune
  204972, -- Hissing Rune
  204973, -- Hissing Rune
}

local function converttohex(rgb)
  return string.format("%02x%02x%02x", rgb.r * 255, rgb.g * 255, rgb.b * 255)
end

local function converttorgb(hex, as_table)
  if as_table then
    return {
      r = tonumber("0x" .. strsub(hex, 1, 2)) / 255,
      g = tonumber("0x" .. strsub(hex, 3, 4)) / 255,
      b = tonumber("0x" .. strsub(hex, 5, 6)) / 255,
    }
  else
    -- as 3 values
    return tonumber("0x" .. hex:sub(1, 2)) / 255,
      tonumber("0x" .. hex:sub(3, 4)) / 255,
      tonumber("0x" .. hex:sub(5, 6)) / 255
  end
end


local function formatBagTitle(self, title, hex)
  local prefix = ""
  if self.db.profile.prefixCategories then
    if self.db.profile.prefixCategories == "!CUSTOM" then
      prefix = self.db.profile.customPrefix
    else
      prefix = self.db.profile.prefixCategories
    end
  end
  if self.db.profile.coloredPrefix then
    prefix = "|cff" .. converttohex(self.db.profile.color.prefix) .. prefix .. "|r"
    if self.db.profile.coloredCategories then
      return prefix .. "|cff" .. hex .. title .. "|r"
    else
      return prefix .. title
    end
  else
    if self.db.profile.coloredCategories then
      return prefix .. "|cff" .. hex .. title .. "|r"
    else
      return prefix .. title
    end
  end
end

local function MatchIDs_Init(self)
  wipe(Result)

  if self.db.profile.moveMergedAchievementsUnlockables then
    Result[formatBagTitle(
      self,
      L["Achievements & Unlockables"],
      converttohex(self.db.profile.color.mergedAchievementsUnlockables)
    )] =
      AddToSet(
        database["CavernClawberingAchievement"],
        database["ChipPet"],
        database["HonorOurAncestors"],
        database["LibrarianoftheReachAchievement"],
        database["LizisReinsMount"],
        database["MagmashellMount"],
        database["OttoMount"],
        database["PhoenixWishwingPet"],
        database["ScrappyWorldsnailMount"],
        database["TemperamentalSkyclawMount"],
        database["TetrachromancerAchievement"],
        database["WhileWeWereSleepingAchievement"]
      )
  else
    if self.db.profile.moveCavernClawberingAchievement then
      Result[formatBagTitle(
        self,
        L["Cavern Clawbering (Achievement)"],
        converttohex(self.db.profile.color.CavernClawberingAchievement)
      )] =
        AddToSet(database["CavernClawberingAchievement"])
    end
    if self.db.profile.moveChipPet then
      Result[formatBagTitle(self, L["Chip (Pet)"], converttohex(self.db.profile.color.ChipPet))] =
        AddToSet(database["ChipPet"])
    end
    if self.db.profile.moveHonorOurAncestors then
      Result[formatBagTitle(self, L["Honor Our Ancestors"], converttohex(self.db.profile.color.HonorOurAncestors))] =
        AddToSet(database["HonorOurAncestors"])
    end
    if self.db.profile.moveLibrarianoftheReachAchievement then
      Result[formatBagTitle(
        self,
        L["Librarian of the Reach (Achievement)"],
        converttohex(self.db.profile.color.LibrarianoftheReachAchievement)
      )] =
        AddToSet(database["LibrarianoftheReachAchievement"])
    end
    if self.db.profile.moveLizisReinsMount then
      Result[formatBagTitle(self, L["Lizis Reins (Mount)"], converttohex(self.db.profile.color.LizisReinsMount))] =
        AddToSet(database["LizisReinsMount"])
    end
    if self.db.profile.moveMagmashellMount then
      Result[formatBagTitle(self, L["Magmashell (Mount)"], converttohex(self.db.profile.color.MagmashellMount))] =
        AddToSet(database["MagmashellMount"])
    end
    if self.db.profile.moveOttoMount then
      Result[formatBagTitle(self, L["Otto (Mount)"], converttohex(self.db.profile.color.OttoMount))] =
        AddToSet(database["OttoMount"])
    end
    if self.db.profile.movePhoenixWishwingPet then
      Result[formatBagTitle(self, L["Phoenix Wishwing (Pet)"], converttohex(self.db.profile.color.PhoenixWishwingPet))] =
        AddToSet(database["PhoenixWishwingPet"])
    end
    if self.db.profile.moveScrappyWorldsnailMount then
      Result[formatBagTitle(
        self,
        L["Scrappy Worldsnail (Mount)"],
        converttohex(self.db.profile.color.ScrappyWorldsnailMount)
      )] =
        AddToSet(database["ScrappyWorldsnailMount"])
    end
    if self.db.profile.moveTemperamentalSkyclawMount then
      Result[formatBagTitle(
        self,
        L["Temperamental Skyclaw (Mount)"],
        converttohex(self.db.profile.color.TemperamentalSkyclawMount)
      )] =
        AddToSet(database["TemperamentalSkyclawMount"])
    end
    if self.db.profile.moveTetrachromancerAchievement then
      Result[formatBagTitle(
        self,
        L["Tetrachromancer (Achievement)"],
        converttohex(self.db.profile.color.TetrachromancerAchievement)
      )] =
        AddToSet(database["TetrachromancerAchievement"])
    end
    if self.db.profile.moveWhileWeWereSleepingAchievement then
      Result[formatBagTitle(
        self,
        L["While We Were Sleeping (Achievement)"],
        converttohex(self.db.profile.color.WhileWeWereSleepingAchievement)
      )] =
        AddToSet(database["WhileWeWereSleepingAchievement"])
    end
  end
  if self.db.profile.moveMergedConsumables then
    Result[formatBagTitle(self, L["Consumables"], converttohex(self.db.profile.color.mergedConsumables))] = AddToSet(
      database["Bandages"],
      database["Cauldrons"],
      database["Contracts"],
      database["CraftingPotions"],
      database["Food"],
      database["Incense"],
      database["Phials"],
      database["Potions"],
      database["RubyFeast"],
      database["Runes"],
      database["Statues"],
      database["Tools"]
    )
  else
    if self.db.profile.moveBandages then
      Result[formatBagTitle(self, L["Bandages"], converttohex(self.db.profile.color.Bandages))] =
        AddToSet(database["Bandages"])
    end
    if self.db.profile.moveCauldrons then
      Result[formatBagTitle(self, L["Cauldrons"], converttohex(self.db.profile.color.Cauldrons))] =
        AddToSet(database["Cauldrons"])
    end
    if self.db.profile.moveContracts then
      Result[formatBagTitle(self, L["Contracts"], converttohex(self.db.profile.color.Contracts))] =
        AddToSet(database["Contracts"])
    end
    if self.db.profile.moveCraftingPotions then
      Result[formatBagTitle(self, L["Crafting Potions"], converttohex(self.db.profile.color.CraftingPotions))] =
        AddToSet(database["CraftingPotions"])
    end
    if self.db.profile.moveFood then
      Result[formatBagTitle(self, L["Food"], converttohex(self.db.profile.color.Food))] = AddToSet(database["Food"])
    end
    if self.db.profile.moveIncense then
      Result[formatBagTitle(self, L["Incense"], converttohex(self.db.profile.color.Incense))] =
        AddToSet(database["Incense"])
    end
    if self.db.profile.movePhials then
      Result[formatBagTitle(self, L["Phials"], converttohex(self.db.profile.color.Phials))] =
        AddToSet(database["Phials"])
    end
    if self.db.profile.movePotions then
      Result[formatBagTitle(self, L["Potions"], converttohex(self.db.profile.color.Potions))] =
        AddToSet(database["Potions"])
    end
    if self.db.profile.moveRubyFeast then
      Result[formatBagTitle(self, L["Ruby Feast"], converttohex(self.db.profile.color.RubyFeast))] =
        AddToSet(database["RubyFeast"])
    end
    if self.db.profile.moveRunes then
      Result[formatBagTitle(self, L["Runes"], converttohex(self.db.profile.color.Runes))] = AddToSet(database["Runes"])
    end
    if self.db.profile.moveStatues then
      Result[formatBagTitle(self, L["Statues"], converttohex(self.db.profile.color.Statues))] =
        AddToSet(database["Statues"])
    end
    if self.db.profile.moveTools then
      Result[formatBagTitle(self, L["Tools"], converttohex(self.db.profile.color.Tools))] = AddToSet(database["Tools"])
    end
  end
  if self.db.profile.moveMergedElementalTradeGoods then
    Result[formatBagTitle(
      self,
      L["Elemental Trade Goods"],
      converttohex(self.db.profile.color.mergedElementalTradeGoods)
    )] =
      AddToSet(database["AwakenedElementals"], database["RousingElementals"])
  else
    if self.db.profile.moveAwakenedElementals then
      Result[formatBagTitle(self, L["Awakened Elementals"], converttohex(self.db.profile.color.AwakenedElementals))] =
        AddToSet(database["AwakenedElementals"])
    end
    if self.db.profile.moveRousingElementals then
      Result[formatBagTitle(self, L["Rousing Elementals"], converttohex(self.db.profile.color.RousingElementals))] =
        AddToSet(database["RousingElementals"])
    end
  end
  if self.db.profile.moveMergedEmbersofNeltharion101 then
    Result[formatBagTitle(
      self,
      L["Embers of Neltharion (10.1)"],
      converttohex(self.db.profile.color.mergedEmbersofNeltharion101)
    )] =
      AddToSet(database["CavernCurrencies"], database["FyrakAssault"], database["ShadowflameCrests"])
  else
    if self.db.profile.moveCavernCurrencies then
      Result[formatBagTitle(self, L["Cavern Currencies"], converttohex(self.db.profile.color.CavernCurrencies))] =
        AddToSet(database["CavernCurrencies"])
    end
    if self.db.profile.moveFyrakAssault then
      Result[formatBagTitle(self, L["Fyrak Assault"], converttohex(self.db.profile.color.FyrakAssault))] =
        AddToSet(database["FyrakAssault"])
    end
    if self.db.profile.moveShadowflameCrests then
      Result[formatBagTitle(self, L["Shadowflame Crests"], converttohex(self.db.profile.color.ShadowflameCrests))] =
        AddToSet(database["ShadowflameCrests"])
    end
  end
  if self.db.profile.moveMergedForbiddenReach1007 then
    Result[formatBagTitle(
      self,
      L["Forbidden Reach (10.0.7)"],
      converttohex(self.db.profile.color.mergedForbiddenReach1007)
    )] =
      AddToSet(
        database["Artifacts"],
        database["ArtisanCurious"],
        database["LeftoverElementalSlime"],
        database["MossyMammoth"],
        database["PrimordialStonesOnyxAnnulet"],
        database["ZskeraVault"]
      )
  else
    if self.db.profile.moveArtifacts then
      Result[formatBagTitle(self, L["Artifacts"], converttohex(self.db.profile.color.Artifacts))] =
        AddToSet(database["Artifacts"])
    end
    if self.db.profile.moveArtisanCurious then
      Result[formatBagTitle(self, L["Artisan Curious"], converttohex(self.db.profile.color.ArtisanCurious))] =
        AddToSet(database["ArtisanCurious"])
    end
    if self.db.profile.moveLeftoverElementalSlime then
      Result[formatBagTitle(
        self,
        L["Leftover Elemental Slime"],
        converttohex(self.db.profile.color.LeftoverElementalSlime)
      )] =
        AddToSet(database["LeftoverElementalSlime"])
    end
    if self.db.profile.moveMossyMammoth then
      Result[formatBagTitle(self, L["Mossy Mammoth"], converttohex(self.db.profile.color.MossyMammoth))] =
        AddToSet(database["MossyMammoth"])
    end
    if self.db.profile.movePrimordialStonesOnyxAnnulet then
      Result[formatBagTitle(
        self,
        L["Primordial Stones & Onyx Annulet"],
        converttohex(self.db.profile.color.PrimordialStonesOnyxAnnulet)
      )] =
        AddToSet(database["PrimordialStonesOnyxAnnulet"])
    end
    if self.db.profile.moveZskeraVault then
      Result[formatBagTitle(self, L["Zskera Vault"], converttohex(self.db.profile.color.ZskeraVault))] =
        AddToSet(database["ZskeraVault"])
    end
  end
  if self.db.profile.moveEmbellishments then
    Result[formatBagTitle(self, L["Embellishments"], converttohex(self.db.profile.color.Embellishments))] =
      AddToSet(database["Embellishments"])
  end
  if self.db.profile.moveGeneralCraftingReagents then
    Result[formatBagTitle(
      self,
      L["General Crafting Reagents"],
      converttohex(self.db.profile.color.GeneralCraftingReagents)
    )] =
      AddToSet(database["GeneralCraftingReagents"])
  end
  if self.db.profile.moveItemLevelUpgrades then
    Result[formatBagTitle(self, L["Item Level Upgrades"], converttohex(self.db.profile.color.ItemLevelUpgrades))] =
      AddToSet(database["ItemLevelUpgrades"])
  end
  if self.db.profile.moveProfessionGear then
    Result[formatBagTitle(self, L["Profession Gear"], converttohex(self.db.profile.color.ProfessionGear))] =
      AddToSet(database["ProfessionGear"])
  end
  if self.db.profile.moveProfessionKnowledge then
    Result[formatBagTitle(self, L["Profession Knowledge"], converttohex(self.db.profile.color.ProfessionKnowledge))] =
      AddToSet(database["ProfessionKnowledge"])
  end
  if self.db.profile.moveMergedGuardiansoftheDream102 then
    Result[formatBagTitle(
      self,
      L["Guardians of the Dream (10.2)"],
      converttohex(self.db.profile.color.mergedGuardiansoftheDream102)
    )] =
      AddToSet(database["DreamingCrests"], database["Dreamseeds"])
  else
    if self.db.profile.moveDreamingCrests then
      Result[formatBagTitle(self, L["Dreaming Crests"], converttohex(self.db.profile.color.DreamingCrests))] =
        AddToSet(database["DreamingCrests"])
    end
    if self.db.profile.moveDreamseeds then
      Result[formatBagTitle(self, L["Dreamseeds"], converttohex(self.db.profile.color.Dreamseeds))] =
        AddToSet(database["Dreamseeds"])
    end
  end
  if self.db.profile.moveDarkmoonCards then
    Result[formatBagTitle(self, L["Darkmoon Cards"], converttohex(self.db.profile.color.DarkmoonCards))] =
      AddToSet(database["DarkmoonCards"])
  end
  if self.db.profile.moveDrakewatcherManuscripts then
    Result[formatBagTitle(
      self,
      L["Drakewatcher Manuscripts"],
      converttohex(self.db.profile.color.DrakewatcherManuscripts)
    )] =
      AddToSet(database["DrakewatcherManuscripts"])
  end
  if self.db.profile.moveDreamboundArmor then
    Result[formatBagTitle(self, L["Dreambound Armor"], converttohex(self.db.profile.color.DreamboundArmor))] =
      AddToSet(database["DreamboundArmor"])
  end
  if self.db.profile.moveDreamsurge then
    Result[formatBagTitle(self, L["Dreamsurge"], converttohex(self.db.profile.color.Dreamsurge))] =
      AddToSet(database["Dreamsurge"])
  end
  if self.db.profile.moveFortuneCards then
    Result[formatBagTitle(self, L["Fortune Cards"], converttohex(self.db.profile.color.FortuneCards))] =
      AddToSet(database["FortuneCards"])
  end
  if self.db.profile.moveReputationItems then
    Result[formatBagTitle(self, L["Reputation Items"], converttohex(self.db.profile.color.ReputationItems))] =
      AddToSet(database["ReputationItems"])
  end
  if self.db.profile.moveTimeRifts then
    Result[formatBagTitle(self, L["Time Rifts"], converttohex(self.db.profile.color.TimeRifts))] =
      AddToSet(database["TimeRifts"])
  end
  if self.db.profile.moveTreasureMaps then
    Result[formatBagTitle(self, L["Treasure Maps"], converttohex(self.db.profile.color.TreasureMaps))] =
      AddToSet(database["TreasureMaps"])
  end
  if self.db.profile.moveTreasureSacks then
    Result[formatBagTitle(self, L["Treasure Sacks"], converttohex(self.db.profile.color.TreasureSacks))] =
      AddToSet(database["TreasureSacks"])
  end
  if self.db.profile.moveMergedPreEvent then
    Result[formatBagTitle(self, L["PreEvent"], converttohex(self.db.profile.color.mergedPreEvent))] =
      AddToSet(database["PreEventCurrency"], database["PreEventGear"])
  else
    if self.db.profile.movePreEventCurrency then
      Result[formatBagTitle(self, L["PreEvent Currency"], converttohex(self.db.profile.color.PreEventCurrency))] =
        AddToSet(database["PreEventCurrency"])
    end
    if self.db.profile.movePreEventGear then
      Result[formatBagTitle(self, L["PreEvent Gear"], converttohex(self.db.profile.color.PreEventGear))] =
        AddToSet(database["PreEventGear"])
    end
  end
  if self.db.profile.moveMergedPrimalistGearTokens then
    Result[formatBagTitle(
      self,
      L["Primalist Gear Tokens"],
      converttohex(self.db.profile.color.mergedPrimalistGearTokens)
    )] =
      AddToSet(
        database["PrimalistAccessories"],
        database["PrimalistCloth"],
        database["PrimalistLeather"],
        database["PrimalistMail"],
        database["PrimalistPlate"],
        database["PrimalistWeapon"],
        database["UntappedForbiddenKnowledge"]
      )
  else
    if self.db.profile.movePrimalistAccessories then
      Result[formatBagTitle(self, L["Primalist Accessories"], converttohex(self.db.profile.color.PrimalistAccessories))] =
        AddToSet(database["PrimalistAccessories"])
    end
    if self.db.profile.movePrimalistCloth then
      Result[formatBagTitle(self, L["Primalist Cloth"], converttohex(self.db.profile.color.PrimalistCloth))] =
        AddToSet(database["PrimalistCloth"])
    end
    if self.db.profile.movePrimalistLeather then
      Result[formatBagTitle(self, L["Primalist Leather"], converttohex(self.db.profile.color.PrimalistLeather))] =
        AddToSet(database["PrimalistLeather"])
    end
    if self.db.profile.movePrimalistMail then
      Result[formatBagTitle(self, L["Primalist Mail"], converttohex(self.db.profile.color.PrimalistMail))] =
        AddToSet(database["PrimalistMail"])
    end
    if self.db.profile.movePrimalistPlate then
      Result[formatBagTitle(self, L["Primalist Plate"], converttohex(self.db.profile.color.PrimalistPlate))] =
        AddToSet(database["PrimalistPlate"])
    end
    if self.db.profile.movePrimalistWeapon then
      Result[formatBagTitle(self, L["Primalist Weapon"], converttohex(self.db.profile.color.PrimalistWeapon))] =
        AddToSet(database["PrimalistWeapon"])
    end
    if self.db.profile.moveUntappedForbiddenKnowledge then
      Result[formatBagTitle(
        self,
        L["Untapped Forbidden Knowledge"],
        converttohex(self.db.profile.color.UntappedForbiddenKnowledge)
      )] =
        AddToSet(database["UntappedForbiddenKnowledge"])
    end
  end
  if self.db.profile.moveMergedProfessions then
    Result[formatBagTitle(self, L["Professions"], converttohex(self.db.profile.color.mergedProfessions))] = AddToSet(
      database["AlchemyFlasks"],
      database["Cloth"],
      database["Cooking"],
      database["Enchanting"],
      database["EnchantingInsightoftheBlue"],
      database["Engineering"],
      database["FishingLures"],
      database["Herbs"],
      database["HerbsSeeds"],
      database["Inscription"],
      database["Jewelcrafting"],
      database["Leather"],
      database["LeatherBait"],
      database["Mining"]
    )
  else
    if self.db.profile.moveAlchemyFlasks then
      Result[formatBagTitle(self, L["Alchemy Flasks"], converttohex(self.db.profile.color.AlchemyFlasks))] =
        AddToSet(database["AlchemyFlasks"])
    end
    if self.db.profile.moveCloth then
      Result[formatBagTitle(self, L["Cloth"], converttohex(self.db.profile.color.Cloth))] = AddToSet(database["Cloth"])
    end
    if self.db.profile.moveCooking then
      Result[formatBagTitle(self, L["Cooking"], converttohex(self.db.profile.color.Cooking))] =
        AddToSet(database["Cooking"])
    end
    if self.db.profile.moveEnchanting then
      Result[formatBagTitle(self, L["Enchanting"], converttohex(self.db.profile.color.Enchanting))] =
        AddToSet(database["Enchanting"])
    end
    if self.db.profile.moveEnchantingInsightoftheBlue then
      Result[formatBagTitle(
        self,
        L["Enchanting - Insight of the Blue"],
        converttohex(self.db.profile.color.EnchantingInsightoftheBlue)
      )] =
        AddToSet(database["EnchantingInsightoftheBlue"])
    end
    if self.db.profile.moveEngineering then
      Result[formatBagTitle(self, L["Engineering"], converttohex(self.db.profile.color.Engineering))] =
        AddToSet(database["Engineering"])
    end
    if self.db.profile.moveFishingLures then
      Result[formatBagTitle(self, L["Fishing Lures"], converttohex(self.db.profile.color.FishingLures))] =
        AddToSet(database["FishingLures"])
    end
    if self.db.profile.moveHerbs then
      Result[formatBagTitle(self, L["Herbs"], converttohex(self.db.profile.color.Herbs))] = AddToSet(database["Herbs"])
    end
    if self.db.profile.moveHerbsSeeds then
      Result[formatBagTitle(self, L["Herbs - Seeds"], converttohex(self.db.profile.color.HerbsSeeds))] =
        AddToSet(database["HerbsSeeds"])
    end
    if self.db.profile.moveInscription then
      Result[formatBagTitle(self, L["Inscription"], converttohex(self.db.profile.color.Inscription))] =
        AddToSet(database["Inscription"])
    end
    if self.db.profile.moveJewelcrafting then
      Result[formatBagTitle(self, L["Jewelcrafting"], converttohex(self.db.profile.color.Jewelcrafting))] =
        AddToSet(database["Jewelcrafting"])
    end
    if self.db.profile.moveLeather then
      Result[formatBagTitle(self, L["Leather"], converttohex(self.db.profile.color.Leather))] =
        AddToSet(database["Leather"])
    end
    if self.db.profile.moveLeatherBait then
      Result[formatBagTitle(self, L["Leather - Bait"], converttohex(self.db.profile.color.LeatherBait))] =
        AddToSet(database["LeatherBait"])
    end
    if self.db.profile.moveMining then
      Result[formatBagTitle(self, L["Mining"], converttohex(self.db.profile.color.Mining))] =
        AddToSet(database["Mining"])
    end
  end
  if self.db.profile.moveMergedRecipes then
    Result[formatBagTitle(self, L["Recipes"], converttohex(self.db.profile.color.mergedRecipes))] = AddToSet(
      database["AlchemyRecipes"],
      database["BlacksmithingRecipes"],
      database["CookingRecipes"],
      database["EnchantingRecipes"],
      database["EngineeringRecipes"],
      database["InscriptionRecipes"],
      database["JewelcraftingRecipes"],
      database["LeatherworkingRecipes"],
      database["TailoringRecipes"]
    )
  else
    if self.db.profile.moveAlchemyRecipes then
      Result[formatBagTitle(self, L["Alchemy Recipes"], converttohex(self.db.profile.color.AlchemyRecipes))] =
        AddToSet(database["AlchemyRecipes"])
    end
    if self.db.profile.moveBlacksmithingRecipes then
      Result[formatBagTitle(self, L["Blacksmithing Recipes"], converttohex(self.db.profile.color.BlacksmithingRecipes))] =
        AddToSet(database["BlacksmithingRecipes"])
    end
    if self.db.profile.moveCookingRecipes then
      Result[formatBagTitle(self, L["Cooking Recipes"], converttohex(self.db.profile.color.CookingRecipes))] =
        AddToSet(database["CookingRecipes"])
    end
    if self.db.profile.moveEnchantingRecipes then
      Result[formatBagTitle(self, L["Enchanting Recipes"], converttohex(self.db.profile.color.EnchantingRecipes))] =
        AddToSet(database["EnchantingRecipes"])
    end
    if self.db.profile.moveEngineeringRecipes then
      Result[formatBagTitle(self, L["Engineering Recipes"], converttohex(self.db.profile.color.EngineeringRecipes))] =
        AddToSet(database["EngineeringRecipes"])
    end
    if self.db.profile.moveInscriptionRecipes then
      Result[formatBagTitle(self, L["Inscription Recipes"], converttohex(self.db.profile.color.InscriptionRecipes))] =
        AddToSet(database["InscriptionRecipes"])
    end
    if self.db.profile.moveJewelcraftingRecipes then
      Result[formatBagTitle(self, L["Jewelcrafting Recipes"], converttohex(self.db.profile.color.JewelcraftingRecipes))] =
        AddToSet(database["JewelcraftingRecipes"])
    end
    if self.db.profile.moveLeatherworkingRecipes then
      Result[formatBagTitle(
        self,
        L["Leatherworking Recipes"],
        converttohex(self.db.profile.color.LeatherworkingRecipes)
      )] =
        AddToSet(database["LeatherworkingRecipes"])
    end
    if self.db.profile.moveTailoringRecipes then
      Result[formatBagTitle(self, L["Tailoring Recipes"], converttohex(self.db.profile.color.TailoringRecipes))] =
        AddToSet(database["TailoringRecipes"])
    end
  end
  if self.db.profile.moveMergedTemporaryPermanentEnhancements then
    Result[formatBagTitle(
      self,
      L["Temporary & Permanent Enhancements"],
      converttohex(self.db.profile.color.mergedTemporaryPermanentEnhancements)
    )] =
      AddToSet(database["Gems"], database["PermanentEnhancements"], database["TemporaryEnhancements"])
  else
    if self.db.profile.moveGems then
      Result[formatBagTitle(self, L["Gems"], converttohex(self.db.profile.color.Gems))] = AddToSet(database["Gems"])
    end
    if self.db.profile.movePermanentEnhancements then
      Result[formatBagTitle(
        self,
        L["Permanent Enhancements"],
        converttohex(self.db.profile.color.PermanentEnhancements)
      )] =
        AddToSet(database["PermanentEnhancements"])
    end
    if self.db.profile.moveTemporaryEnhancements then
      Result[formatBagTitle(
        self,
        L["Temporary Enhancements"],
        converttohex(self.db.profile.color.TemporaryEnhancements)
      )] =
        AddToSet(database["TemporaryEnhancements"])
    end
  end

  return Result
end

local setFilter = AdiBags:RegisterFilter("Dragonflight", 98, "ABEvent-1.0")
setFilter.uiName = string.format("|cffa00000%s|r", L["Dragonflight"])
setFilter.uiDesc = string.format(
  "%s\n|cffffd800%s: 2.3.35|r",
  L["Items from the Dragonflight expansion."],
  L["Filter version"]
)

function setFilter:OnInitialize()
  self.db = AdiBags.db:RegisterNamespace("Dragonflight", {
    profile = {
      coloredCategories = true,
      prefixCategories = "",
      customPrefix = "",
      coloredPrefix = true,
      moveMergedAchievementsUnlockables = false,
      moveCavernClawberingAchievement = true,
      moveChipPet = true,
      moveHonorOurAncestors = false,
      moveLibrarianoftheReachAchievement = true,
      moveLizisReinsMount = true,
      moveMagmashellMount = true,
      moveOttoMount = true,
      movePhoenixWishwingPet = true,
      moveScrappyWorldsnailMount = true,
      moveTemperamentalSkyclawMount = true,
      moveTetrachromancerAchievement = true,
      moveWhileWeWereSleepingAchievement = true,
      moveMergedConsumables = false,
      moveBandages = true,
      moveCauldrons = true,
      moveContracts = true,
      moveCraftingPotions = true,
      moveFood = true,
      moveIncense = true,
      movePhials = true,
      movePotions = true,
      moveRubyFeast = true,
      moveRunes = true,
      moveStatues = true,
      moveTools = true,
      moveMergedElementalTradeGoods = true,
      moveAwakenedElementals = true,
      moveRousingElementals = true,
      moveMergedEmbersofNeltharion101 = false,
      moveCavernCurrencies = true,
      moveFyrakAssault = true,
      moveShadowflameCrests = true,
      moveMergedForbiddenReach1007 = false,
      moveArtifacts = true,
      moveArtisanCurious = true,
      moveLeftoverElementalSlime = true,
      moveMossyMammoth = true,
      movePrimordialStonesOnyxAnnulet = true,
      moveZskeraVault = true,
      moveEmbellishments = true,
      moveGeneralCraftingReagents = true,
      moveItemLevelUpgrades = true,
      moveProfessionGear = true,
      moveProfessionKnowledge = true,
      moveMergedGuardiansoftheDream102 = false,
      moveDreamingCrests = true,
      moveDreamseeds = true,
      moveDarkmoonCards = true,
      moveDrakewatcherManuscripts = true,
      moveDreamboundArmor = true,
      moveDreamsurge = true,
      moveFortuneCards = true,
      moveReputationItems = true,
      moveTimeRifts = true,
      moveTreasureMaps = true,
      moveTreasureSacks = true,
      moveMergedPreEvent = false,
      movePreEventCurrency = true,
      movePreEventGear = true,
      moveMergedPrimalistGearTokens = true,
      movePrimalistAccessories = true,
      movePrimalistCloth = true,
      movePrimalistLeather = true,
      movePrimalistMail = true,
      movePrimalistPlate = true,
      movePrimalistWeapon = true,
      moveUntappedForbiddenKnowledge = true,
      moveMergedProfessions = false,
      moveAlchemyFlasks = false,
      moveCloth = false,
      moveCooking = false,
      moveEnchanting = false,
      moveEnchantingInsightoftheBlue = false,
      moveEngineering = false,
      moveFishingLures = false,
      moveHerbs = false,
      moveHerbsSeeds = false,
      moveInscription = false,
      moveJewelcrafting = false,
      moveLeather = false,
      moveLeatherBait = false,
      moveMining = false,
      moveMergedRecipes = true,
      moveAlchemyRecipes = true,
      moveBlacksmithingRecipes = true,
      moveCookingRecipes = true,
      moveEnchantingRecipes = true,
      moveEngineeringRecipes = true,
      moveInscriptionRecipes = true,
      moveJewelcraftingRecipes = true,
      moveLeatherworkingRecipes = true,
      moveTailoringRecipes = true,
      moveMergedTemporaryPermanentEnhancements = true,
      moveGems = true,
      movePermanentEnhancements = true,
      moveTemporaryEnhancements = true,

      color = {
        prefix = converttorgb("a00000", true),
        mergedAchievementsUnlockables = converttorgb("f7cb15", true),
        CavernClawberingAchievement = converttorgb("004fa7", true),
        ChipPet = converttorgb("deff00", true),
        HonorOurAncestors = converttorgb("76bed0", true),
        LibrarianoftheReachAchievement = converttorgb("e69aff", true),
        LizisReinsMount = converttorgb("878e88", true),
        MagmashellMount = converttorgb("ff8c61", true),
        OttoMount = converttorgb("1d24e2", true),
        PhoenixWishwingPet = converttorgb("ff9600", true),
        ScrappyWorldsnailMount = converttorgb("ce6a85", true),
        TemperamentalSkyclawMount = converttorgb("f55d3e", true),
        TetrachromancerAchievement = converttorgb("fcccbf", true),
        WhileWeWereSleepingAchievement = converttorgb("00d441", true),
        mergedConsumables = converttorgb("7aa36f", true),
        Bandages = converttorgb("ab3428", true),
        Cauldrons = converttorgb("07393c", true),
        Contracts = converttorgb("f2cc8f", true),
        CraftingPotions = converttorgb("ebb134", true),
        Food = converttorgb("34eb9e", true),
        Incense = converttorgb("f4f1de", true),
        Phials = converttorgb("d295bf", true),
        Potions = converttorgb("ebb134", true),
        RubyFeast = converttorgb("ab3428", true),
        Runes = converttorgb("9bc53d", true),
        Statues = converttorgb("36494e", true),
        Tools = converttorgb("ad5d4e", true),
        mergedElementalTradeGoods = converttorgb("644bff", true),
        AwakenedElementals = converttorgb("644bff", true),
        RousingElementals = converttorgb("644bff", true),
        mergedEmbersofNeltharion101 = converttorgb("ffcc00", true),
        CavernCurrencies = converttorgb("ff7800", true),
        FyrakAssault = converttorgb("ff4800", true),
        ShadowflameCrests = converttorgb("ff2400", true),
        mergedForbiddenReach1007 = converttorgb("00ff42", true),
        Artifacts = converttorgb("007eb3", true),
        ArtisanCurious = converttorgb("2200b3", true),
        LeftoverElementalSlime = converttorgb("363881", true),
        MossyMammoth = converttorgb("007010", true),
        PrimordialStonesOnyxAnnulet = converttorgb("b35000", true),
        ZskeraVault = converttorgb("ff5a00", true),
        Embellishments = converttorgb("06ff00", true),
        GeneralCraftingReagents = converttorgb("51479c", true),
        ItemLevelUpgrades = converttorgb("ba00ff", true),
        ProfessionGear = converttorgb("ffd883", true),
        ProfessionKnowledge = converttorgb("33937f", true),
        mergedGuardiansoftheDream102 = converttorgb("0b9600", true),
        DreamingCrests = converttorgb("7eff00", true),
        Dreamseeds = converttorgb("5fff57", true),
        DarkmoonCards = converttorgb("48aa00", true),
        DrakewatcherManuscripts = converttorgb("33937f", true),
        DreamboundArmor = converttorgb("009932", true),
        Dreamsurge = converttorgb("60ff00", true),
        FortuneCards = converttorgb("6cff00", true),
        ReputationItems = converttorgb("1eff00", true),
        TimeRifts = converttorgb("eee5d4", true),
        TreasureMaps = converttorgb("d900d2", true),
        TreasureSacks = converttorgb("fff000", true),
        mergedPreEvent = converttorgb("644bff", true),
        PreEventCurrency = converttorgb("0060a2", true),
        PreEventGear = converttorgb("0050a2", true),
        mergedPrimalistGearTokens = converttorgb("7a00b3", true),
        PrimalistAccessories = converttorgb("5000b3", true),
        PrimalistCloth = converttorgb("00b358", true),
        PrimalistLeather = converttorgb("00adb3", true),
        PrimalistMail = converttorgb("007eb3", true),
        PrimalistPlate = converttorgb("001db3", true),
        PrimalistWeapon = converttorgb("2a00b3", true),
        UntappedForbiddenKnowledge = converttorgb("b100b3", true),
        mergedProfessions = converttorgb("a36f6f", true),
        AlchemyFlasks = converttorgb("91ffe9", true),
        Cloth = converttorgb("ff7e00", true),
        Cooking = converttorgb("ff0072", true),
        Enchanting = converttorgb("96ff00", true),
        EnchantingInsightoftheBlue = converttorgb("96ff00", true),
        Engineering = converttorgb("787878", true),
        FishingLures = converttorgb("40bcd8", true),
        Herbs = converttorgb("00ff36", true),
        HerbsSeeds = converttorgb("bfffbc", true),
        Inscription = converttorgb("4dfaf8", true),
        Jewelcrafting = converttorgb("514dfa", true),
        Leather = converttorgb("865b00", true),
        LeatherBait = converttorgb("f4f1de", true),
        Mining = converttorgb("898396", true),
        mergedRecipes = converttorgb("68d080", true),
        AlchemyRecipes = converttorgb("4e9a06", true),
        BlacksmithingRecipes = converttorgb("8f8f8f", true),
        CookingRecipes = converttorgb("e9b96e", true),
        EnchantingRecipes = converttorgb("5c3566", true),
        EngineeringRecipes = converttorgb("c4a000", true),
        InscriptionRecipes = converttorgb("855c33", true),
        JewelcraftingRecipes = converttorgb("ad7fa8", true),
        LeatherworkingRecipes = converttorgb("8b4513", true),
        TailoringRecipes = converttorgb("d3d7cf", true),
        mergedTemporaryPermanentEnhancements = converttorgb("5a7684", true),
        Gems = converttorgb("ff00ea", true),
        PermanentEnhancements = converttorgb("92afd7", true),
        TemporaryEnhancements = converttorgb("c5d1eb", true),
      },
    },
  })
end

function setFilter:Update()
  MatchIDs = nil
  self:SendMessage("AdiBags_FiltersChanged")
end

function setFilter:OnEnable()
  AdiBags:UpdateFilters()
end

function setFilter:OnDisable()
  AdiBags:UpdateFilters()
end

function setFilter:Filter(slotData)
  MatchIDs = MatchIDs or MatchIDs_Init(self)
  for i, name in pairs(MatchIDs) do
    -- Override Method
    if MatchIDs[i]["override"] then
      slotData["loc"] = ItemLocation:CreateFromBagAndSlot(slotData.bag, slotData.slot)
      if slotData["loc"] and slotData["loc"]:IsValid() then
        if MatchIDs[i]["override"](slotData.loc) then
          return i
        end
      end

      -- Bonus Condition (triggers when bonus condition is not fulfilled)
    elseif MatchIDs[i]["bonus_condition"] then
      if name[slotData.itemId] then
        slotData["loc"] = ItemLocation:CreateFromBagAndSlot(slotData.bag, slotData.slot)
        if slotData["loc"] and slotData["loc"]:IsValid() then
          if not MatchIDs[i]["bonus_condition"](slotData.loc) then
            -- THERE IS A NOT HERE!
            return i
          end
        end
      end

      -- Standard ID Matching
    elseif name[slotData.itemId] then
      return i
    end
  end
end

function setFilter:GetOptions()
  return {
    general_config = {
      type = "group",
      name = L["General Settings"],
      desc = L["Settings affecting all categories."],
      inline = true,
      order = 1,
      args = {
        description = {
          type = "description",
          name = string.format(
            "%s |cffffd800%s |cff529F00%s|r",
            L["These settings affect all categories of this filter."],
            L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."],
            L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."]
          ),
          order = 1,
        },
        coloredCategories = {
          name = string.format("|cffFDFD96%s|r", L["Colored Categories"]),
          desc = L["Should Categories be colored?"],
          width = "full",
          type = "toggle",
          order = 10,
        },
        prefixCategories = {
          name = L["Prefix Categories"],
          desc = L["Select a prefix for the categories, if you like."],
          type = "select",
          order = 20,
          values = {
            [""] = L["None"],
            ["!CUSTOM"] = L["Custom Prefix"],
            ["DF"] = "DF",
            ["DF-"] = "DF-",
            ["9."] = "9.",
            ["|T4734167:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4734167:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T236469:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T236469:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T236473:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T236473:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T236471:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T236471:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T236472:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T236472:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T4640486:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4640486:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T4397694:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4397694:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T4397691:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4397691:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T4397692:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4397692:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T4397690:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4397690:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
            ["|T4397693:" .. AdiBags.HEADER_SIZE .. ":" .. AdiBags.HEADER_SIZE .. ":-2:-10|t"] = "|T4397693:"
              .. AdiBags.HEADER_SIZE
              .. "|t",
          },
        },
        customPrefix = {
          name = L["Custom Prefix"],
          desc = L["Enter a custom prefix for the categories."],
          type = "input",
          order = 30,
          width = "full",
          disabled = function()
            return self.db.profile.prefixCategories ~= "!CUSTOM"
          end,
        },
        coloredPrefix = {
          name = string.format("|cffB9FFB9%s|r", L["Colored Prefix"]),
          desc = L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"],
          type = "toggle",
          order = 40,
        },
        prefixColor = {
          name = L["Prefix Color"],
          desc = L["Select a color for the prefix."],
          type = "color",
          order = 50,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.coloredPrefix
          end,
          get = function()
            local color = self.db.profile.color.prefix
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.prefix
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    AchievementsUnlockables_config = {
      type = "group",
      name = L["Achievements & Unlockables"],
      desc = "", -- doesnt work,
      inline = true,
      order = 52,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."],
          order = 53,
        },
        moveMergedAchievementsUnlockables = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Achievements & Unlockables"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Achievements & Unlockables"]),
          type = "toggle",
          width = 1.5,
          order = 54,
        },
        colorMergedAchievementsUnlockables = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Achievements & Unlockables"]),
          type = "color",
          order = 55,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.mergedAchievementsUnlockables
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedAchievementsUnlockables
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_1 = {
          type = "header",
          name = "",
          order = 56,
        },
        moveCavernClawberingAchievement = {
          name = L["Cavern Clawbering (Achievement)"],
          desc = L["This category contains the item needed to get the Cavern Clawbering achievement."],
          type = "toggle",
          width = 1.5,
          order = 57,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorCavernClawberingAchievement = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Cavern Clawbering (Achievement)"]),
          type = "color",
          order = 58,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.CavernClawberingAchievement
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.CavernClawberingAchievement
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_2 = {
          type = "header",
          name = "",
          order = 59,
        },
        moveChipPet = {
          name = L["Chip (Pet)"],
          desc = L["This category contains the items needed to get the Chip pet."],
          type = "toggle",
          width = 1.5,
          order = 60,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorChipPet = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Chip (Pet)"]),
          type = "color",
          order = 61,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.ChipPet
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ChipPet
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_3 = {
          type = "header",
          name = "",
          order = 62,
        },
        moveHonorOurAncestors = {
          name = L["Honor Our Ancestors"],
          desc = L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."],
          type = "toggle",
          width = 1.5,
          order = 63,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorHonorOurAncestors = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Honor Our Ancestors"]),
          type = "color",
          order = 64,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.HonorOurAncestors
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.HonorOurAncestors
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_4 = {
          type = "header",
          name = "",
          order = 65,
        },
        moveLibrarianoftheReachAchievement = {
          name = L["Librarian of the Reach (Achievement)"],
          desc = L["This category contains the books looted for the Librarian of the Reach achievement."],
          type = "toggle",
          width = 1.5,
          order = 66,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorLibrarianoftheReachAchievement = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Librarian of the Reach (Achievement)"]),
          type = "color",
          order = 67,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.LibrarianoftheReachAchievement
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.LibrarianoftheReachAchievement
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_5 = {
          type = "header",
          name = "",
          order = 68,
        },
        moveLizisReinsMount = {
          name = L["Lizis Reins (Mount)"],
          desc = L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."],
          type = "toggle",
          width = 1.5,
          order = 69,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorLizisReinsMount = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Lizis Reins (Mount)"]),
          type = "color",
          order = 70,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.LizisReinsMount
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.LizisReinsMount
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_6 = {
          type = "header",
          name = "",
          order = 71,
        },
        moveMagmashellMount = {
          name = L["Magmashell (Mount)"],
          desc = L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."],
          type = "toggle",
          width = 1.5,
          order = 72,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorMagmashellMount = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Magmashell (Mount)"]),
          type = "color",
          order = 73,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.MagmashellMount
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.MagmashellMount
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_7 = {
          type = "header",
          name = "",
          order = 74,
        },
        moveOttoMount = {
          name = L["Otto (Mount)"],
          desc = L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."],
          type = "toggle",
          width = 1.5,
          order = 75,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorOttoMount = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Otto (Mount)"]),
          type = "color",
          order = 76,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.OttoMount
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.OttoMount
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_8 = {
          type = "header",
          name = "",
          order = 77,
        },
        movePhoenixWishwingPet = {
          name = L["Phoenix Wishwing (Pet)"],
          desc = L["This category contains the items needed to get the Phoenix Wishwing pet."],
          type = "toggle",
          width = 1.5,
          order = 78,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorPhoenixWishwingPet = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Phoenix Wishwing (Pet)"]),
          type = "color",
          order = 79,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.PhoenixWishwingPet
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PhoenixWishwingPet
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_9 = {
          type = "header",
          name = "",
          order = 80,
        },
        moveScrappyWorldsnailMount = {
          name = L["Scrappy Worldsnail (Mount)"],
          desc = L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."],
          type = "toggle",
          width = 1.5,
          order = 81,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorScrappyWorldsnailMount = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Scrappy Worldsnail (Mount)"]),
          type = "color",
          order = 82,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.ScrappyWorldsnailMount
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ScrappyWorldsnailMount
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_10 = {
          type = "header",
          name = "",
          order = 83,
        },
        moveTemperamentalSkyclawMount = {
          name = L["Temperamental Skyclaw (Mount)"],
          desc = L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."],
          type = "toggle",
          width = 1.5,
          order = 84,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorTemperamentalSkyclawMount = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Temperamental Skyclaw (Mount)"]),
          type = "color",
          order = 85,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.TemperamentalSkyclawMount
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TemperamentalSkyclawMount
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_11 = {
          type = "header",
          name = "",
          order = 86,
        },
        moveTetrachromancerAchievement = {
          name = L["Tetrachromancer (Achievement)"],
          desc = L["This category contains hunting companion colors needed for the achievement."],
          type = "toggle",
          width = 1.5,
          order = 87,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorTetrachromancerAchievement = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Tetrachromancer (Achievement)"]),
          type = "color",
          order = 88,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.TetrachromancerAchievement
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TetrachromancerAchievement
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_12 = {
          type = "header",
          name = "",
          order = 89,
        },
        moveWhileWeWereSleepingAchievement = {
          name = L["While We Were Sleeping (Achievement)"],
          desc = L["This category contains the quest items looted for the While We Were Sleeping achievement."],
          type = "toggle",
          width = 1.5,
          order = 90,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
        },
        colorWhileWeWereSleepingAchievement = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["While We Were Sleeping (Achievement)"]),
          type = "color",
          order = 91,
          disabled = function()
            return self.db.profile.moveMergedAchievementsUnlockables
          end,
          get = function()
            local color = self.db.profile.color.WhileWeWereSleepingAchievement
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.WhileWeWereSleepingAchievement
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    Consumables_config = {
      type = "group",
      name = L["Consumables"],
      desc = "", -- doesnt work,
      inline = true,
      order = 92,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items you can eat or use to improve yourself"],
          order = 93,
        },
        moveMergedConsumables = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Consumables"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Consumables"]),
          type = "toggle",
          width = 1.5,
          order = 94,
        },
        colorMergedConsumables = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Consumables"]),
          type = "color",
          order = 95,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.mergedConsumables
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedConsumables
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_13 = {
          type = "header",
          name = "",
          order = 96,
        },
        moveBandages = {
          name = L["Bandages"],
          desc = L["Bandages, to patch up your broken friends :)"],
          type = "toggle",
          width = 1.5,
          order = 97,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorBandages = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Bandages"]),
          type = "color",
          order = 98,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Bandages
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Bandages
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_14 = {
          type = "header",
          name = "",
          order = 99,
        },
        moveCauldrons = {
          name = L["Cauldrons"],
          desc = L["Cauldrons, to share your soup with friends :)"],
          type = "toggle",
          width = 1.5,
          order = 100,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorCauldrons = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Cauldrons"]),
          type = "color",
          order = 101,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Cauldrons
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Cauldrons
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_15 = {
          type = "header",
          name = "",
          order = 102,
        },
        moveContracts = {
          name = L["Contracts"],
          desc = L["Contracts give additional reputation when completing world quests in the Dragon Isles."],
          type = "toggle",
          width = 1.5,
          order = 103,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorContracts = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Contracts"]),
          type = "color",
          order = 104,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Contracts
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Contracts
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_16 = {
          type = "header",
          name = "",
          order = 105,
        },
        moveCraftingPotions = {
          name = L["Crafting Potions"],
          desc = L["Potions which improve crafting or collecting"],
          type = "toggle",
          width = 1.5,
          order = 106,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorCraftingPotions = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Crafting Potions"]),
          type = "color",
          order = 107,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.CraftingPotions
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.CraftingPotions
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_17 = {
          type = "header",
          name = "",
          order = 108,
        },
        moveFood = {
          name = L["Food"],
          desc = L["Food added in the Dragonflight expansion"],
          type = "toggle",
          width = 1.5,
          order = 109,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorFood = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Food"]),
          type = "color",
          order = 110,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Food
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Food
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_18 = {
          type = "header",
          name = "",
          order = 111,
        },
        moveIncense = {
          name = L["Incense"],
          desc = L["Incense to improve crafting ability or just for a nice smell"],
          type = "toggle",
          width = 1.5,
          order = 112,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorIncense = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Incense"]),
          type = "color",
          order = 113,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Incense
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Incense
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_19 = {
          type = "header",
          name = "",
          order = 114,
        },
        movePhials = {
          name = L["Phials"],
          desc = L["Phials added in the Dragonflight expansion"],
          type = "toggle",
          width = 1.5,
          order = 115,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorPhials = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Phials"]),
          type = "color",
          order = 116,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Phials
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Phials
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_20 = {
          type = "header",
          name = "",
          order = 117,
        },
        movePotions = {
          name = L["Potions"],
          desc = L["Potions added in the Dragonflight expansion"],
          type = "toggle",
          width = 1.5,
          order = 118,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorPotions = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Potions"]),
          type = "color",
          order = 119,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Potions
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Potions
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_21 = {
          type = "header",
          name = "",
          order = 120,
        },
        moveRubyFeast = {
          name = L["Ruby Feast"],
          desc = L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."],
          type = "toggle",
          width = 1.5,
          order = 121,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorRubyFeast = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Ruby Feast"]),
          type = "color",
          order = 122,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.RubyFeast
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.RubyFeast
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_22 = {
          type = "header",
          name = "",
          order = 123,
        },
        moveRunes = {
          name = L["Runes"],
          desc = L["Contains runes & vantus runes which improving your combat ability."],
          type = "toggle",
          width = 1.5,
          order = 124,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorRunes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Runes"]),
          type = "color",
          order = 125,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Runes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Runes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_23 = {
          type = "header",
          name = "",
          order = 126,
        },
        moveStatues = {
          name = L["Statues"],
          desc = L["Statues crafted by Jewelcrafters. They improve various things."],
          type = "toggle",
          width = 1.5,
          order = 127,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorStatues = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Statues"]),
          type = "color",
          order = 128,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Statues
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Statues
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_24 = {
          type = "header",
          name = "",
          order = 129,
        },
        moveTools = {
          name = L["Tools"],
          desc = L["Contains various tools, helpful in the Dragon Isles."],
          type = "toggle",
          width = 1.5,
          order = 130,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
        },
        colorTools = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Tools"]),
          type = "color",
          order = 131,
          disabled = function()
            return self.db.profile.moveMergedConsumables
          end,
          get = function()
            local color = self.db.profile.color.Tools
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Tools
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    ElementalTradeGoods_config = {
      type = "group",
      name = L["Elemental Trade Goods"],
      desc = "", -- doesnt work,
      inline = true,
      order = 132,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Awakened and Rousing Elemental Trade Goods"],
          order = 133,
        },
        moveMergedElementalTradeGoods = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Elemental Trade Goods"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Elemental Trade Goods"]),
          type = "toggle",
          width = 1.5,
          order = 134,
        },
        colorMergedElementalTradeGoods = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Elemental Trade Goods"]),
          type = "color",
          order = 135,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedElementalTradeGoods
          end,
          get = function()
            local color = self.db.profile.color.mergedElementalTradeGoods
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedElementalTradeGoods
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_25 = {
          type = "header",
          name = "",
          order = 136,
        },
        moveAwakenedElementals = {
          name = L["Awakened Elementals"],
          desc = L["Awakened Elementals"],
          type = "toggle",
          width = 1.5,
          order = 137,
          disabled = function()
            return self.db.profile.moveMergedElementalTradeGoods
          end,
        },
        colorAwakenedElementals = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Awakened Elementals"]),
          type = "color",
          order = 138,
          disabled = function()
            return self.db.profile.moveMergedElementalTradeGoods
          end,
          get = function()
            local color = self.db.profile.color.AwakenedElementals
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.AwakenedElementals
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_26 = {
          type = "header",
          name = "",
          order = 139,
        },
        moveRousingElementals = {
          name = L["Rousing Elementals"],
          desc = L["Rousing Elementals"],
          type = "toggle",
          width = 1.5,
          order = 140,
          disabled = function()
            return self.db.profile.moveMergedElementalTradeGoods
          end,
        },
        colorRousingElementals = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Rousing Elementals"]),
          type = "color",
          order = 141,
          disabled = function()
            return self.db.profile.moveMergedElementalTradeGoods
          end,
          get = function()
            local color = self.db.profile.color.RousingElementals
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.RousingElementals
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    EmbersofNeltharion101_config = {
      type = "group",
      name = L["Embers of Neltharion (10.1)"],
      desc = "", -- doesnt work,
      inline = true,
      order = 142,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items which can be found and used in the Zaralek Cavern."],
          order = 143,
        },
        moveMergedEmbersofNeltharion101 = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Embers of Neltharion (10.1)"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Embers of Neltharion (10.1)"]),
          type = "toggle",
          width = 1.5,
          order = 144,
        },
        colorMergedEmbersofNeltharion101 = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Embers of Neltharion (10.1)"]),
          type = "color",
          order = 145,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedEmbersofNeltharion101
          end,
          get = function()
            local color = self.db.profile.color.mergedEmbersofNeltharion101
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedEmbersofNeltharion101
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_27 = {
          type = "header",
          name = "",
          order = 146,
        },
        moveCavernCurrencies = {
          name = L["Cavern Currencies"],
          desc = L["This category contains currencies, used in the Zaralek Cavern."],
          type = "toggle",
          width = 1.5,
          order = 147,
          disabled = function()
            return self.db.profile.moveMergedEmbersofNeltharion101
          end,
        },
        colorCavernCurrencies = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Cavern Currencies"]),
          type = "color",
          order = 148,
          disabled = function()
            return self.db.profile.moveMergedEmbersofNeltharion101
          end,
          get = function()
            local color = self.db.profile.color.CavernCurrencies
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.CavernCurrencies
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_28 = {
          type = "header",
          name = "",
          order = 149,
        },
        moveFyrakAssault = {
          name = L["Fyrak Assault"],
          desc = L["This category contains fragments, used during the Fyrak Assault event."],
          type = "toggle",
          width = 1.5,
          order = 150,
          disabled = function()
            return self.db.profile.moveMergedEmbersofNeltharion101
          end,
        },
        colorFyrakAssault = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Fyrak Assault"]),
          type = "color",
          order = 151,
          disabled = function()
            return self.db.profile.moveMergedEmbersofNeltharion101
          end,
          get = function()
            local color = self.db.profile.color.FyrakAssault
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.FyrakAssault
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_29 = {
          type = "header",
          name = "",
          order = 152,
        },
        moveShadowflameCrests = {
          name = L["Shadowflame Crests"],
          desc = L["This category contains Shadowflame Crests, which can be used to upgrade gear."],
          type = "toggle",
          width = 1.5,
          order = 153,
          disabled = function()
            return self.db.profile.moveMergedEmbersofNeltharion101
          end,
        },
        colorShadowflameCrests = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Shadowflame Crests"]),
          type = "color",
          order = 154,
          disabled = function()
            return self.db.profile.moveMergedEmbersofNeltharion101
          end,
          get = function()
            local color = self.db.profile.color.ShadowflameCrests
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ShadowflameCrests
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    ForbiddenReach1007_config = {
      type = "group",
      name = L["Forbidden Reach (10.0.7)"],
      desc = "", -- doesnt work,
      inline = true,
      order = 155,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items which can be found and used in the Forbidden Reach."],
          order = 156,
        },
        moveMergedForbiddenReach1007 = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Forbidden Reach (10.0.7)"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Forbidden Reach (10.0.7)"]),
          type = "toggle",
          width = 1.5,
          order = 157,
        },
        colorMergedForbiddenReach1007 = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Forbidden Reach (10.0.7)"]),
          type = "color",
          order = 158,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.mergedForbiddenReach1007
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedForbiddenReach1007
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_30 = {
          type = "header",
          name = "",
          order = 159,
        },
        moveArtifacts = {
          name = L["Artifacts"],
          desc = L["These artifacts can be traded in Morqut Village."],
          type = "toggle",
          width = 1.5,
          order = 160,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
        },
        colorArtifacts = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Artifacts"]),
          type = "color",
          order = 161,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.Artifacts
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Artifacts
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_31 = {
          type = "header",
          name = "",
          order = 162,
        },
        moveArtisanCurious = {
          name = L["Artisan Curious"],
          desc = L["These items can be used to summon a rare mob in the Forbidden Reach."],
          type = "toggle",
          width = 1.5,
          order = 163,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
        },
        colorArtisanCurious = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Artisan Curious"]),
          type = "color",
          order = 164,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.ArtisanCurious
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ArtisanCurious
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_32 = {
          type = "header",
          name = "",
          order = 165,
        },
        moveLeftoverElementalSlime = {
          name = L["Leftover Elemental Slime"],
          desc = L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."],
          type = "toggle",
          width = 1.5,
          order = 166,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
        },
        colorLeftoverElementalSlime = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Leftover Elemental Slime"]),
          type = "color",
          order = 167,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.LeftoverElementalSlime
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.LeftoverElementalSlime
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_33 = {
          type = "header",
          name = "",
          order = 168,
        },
        moveMossyMammoth = {
          name = L["Mossy Mammoth"],
          desc = L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."],
          type = "toggle",
          width = 1.5,
          order = 169,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
        },
        colorMossyMammoth = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Mossy Mammoth"]),
          type = "color",
          order = 170,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.MossyMammoth
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.MossyMammoth
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_34 = {
          type = "header",
          name = "",
          order = 171,
        },
        movePrimordialStonesOnyxAnnulet = {
          name = L["Primordial Stones & Onyx Annulet"],
          desc = L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."],
          type = "toggle",
          width = 1.5,
          order = 172,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
        },
        colorPrimordialStonesOnyxAnnulet = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primordial Stones & Onyx Annulet"]),
          type = "color",
          order = 173,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.PrimordialStonesOnyxAnnulet
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimordialStonesOnyxAnnulet
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_35 = {
          type = "header",
          name = "",
          order = 174,
        },
        moveZskeraVault = {
          name = L["Zskera Vault"],
          desc = L["Items found or used in the Zskera Vault."],
          type = "toggle",
          width = 1.5,
          order = 175,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
        },
        colorZskeraVault = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Zskera Vault"]),
          type = "color",
          order = 176,
          disabled = function()
            return self.db.profile.moveMergedForbiddenReach1007
          end,
          get = function()
            local color = self.db.profile.color.ZskeraVault
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ZskeraVault
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    GeneralProfessionItems_config = {
      type = "group",
      name = L["General Profession Items"],
      desc = "", -- doesnt work,
      inline = true,
      order = 177,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items which are used in multiple professions."],
          order = 178,
        },
        moveEmbellishments = {
          name = L["Embellishments"],
          desc = L["Items that provide embellishments to crafted items."],
          type = "toggle",
          width = 1.5,
          order = 179,
        },
        colorEmbellishments = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Embellishments"]),
          type = "color",
          order = 180,
          disabled = function()
            return self.db.profile.moveMergedGeneralProfessionItems
          end,
          get = function()
            local color = self.db.profile.color.Embellishments
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Embellishments
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_36 = {
          type = "header",
          name = "",
          order = 181,
        },
        moveGeneralCraftingReagents = {
          name = L["General Crafting Reagents"],
          desc = L["General Crafting Reagents, used by multiple professions"],
          type = "toggle",
          width = 1.5,
          order = 182,
        },
        colorGeneralCraftingReagents = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["General Crafting Reagents"]),
          type = "color",
          order = 183,
          disabled = function()
            return self.db.profile.moveMergedGeneralProfessionItems
          end,
          get = function()
            local color = self.db.profile.color.GeneralCraftingReagents
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.GeneralCraftingReagents
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_37 = {
          type = "header",
          name = "",
          order = 184,
        },
        moveItemLevelUpgrades = {
          name = L["Item Level Upgrades"],
          desc = L["Items which upgrade the item level of crafted gear."],
          type = "toggle",
          width = 1.5,
          order = 185,
        },
        colorItemLevelUpgrades = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Item Level Upgrades"]),
          type = "color",
          order = 186,
          disabled = function()
            return self.db.profile.moveMergedGeneralProfessionItems
          end,
          get = function()
            local color = self.db.profile.color.ItemLevelUpgrades
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ItemLevelUpgrades
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_38 = {
          type = "header",
          name = "",
          order = 187,
        },
        moveProfessionGear = {
          name = L["Profession Gear"],
          desc = L["Specialized gear which improves your profession"],
          type = "toggle",
          width = 1.5,
          order = 188,
        },
        colorProfessionGear = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Profession Gear"]),
          type = "color",
          order = 189,
          disabled = function()
            return self.db.profile.moveMergedGeneralProfessionItems
          end,
          get = function()
            local color = self.db.profile.color.ProfessionGear
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ProfessionGear
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_39 = {
          type = "header",
          name = "",
          order = 190,
        },
        moveProfessionKnowledge = {
          name = L["Profession Knowledge"],
          desc = L["Items that provide profession knowledge"],
          type = "toggle",
          width = 1.5,
          order = 191,
        },
        colorProfessionKnowledge = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Profession Knowledge"]),
          type = "color",
          order = 192,
          disabled = function()
            return self.db.profile.moveMergedGeneralProfessionItems
          end,
          get = function()
            local color = self.db.profile.color.ProfessionKnowledge
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ProfessionKnowledge
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    GuardiansoftheDream102_config = {
      type = "group",
      name = L["Guardians of the Dream (10.2)"],
      desc = "", -- doesnt work,
      inline = true,
      order = 193,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items which can be found and used in the Emerald Dream and related zones."],
          order = 194,
        },
        moveMergedGuardiansoftheDream102 = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Guardians of the Dream (10.2)"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Guardians of the Dream (10.2)"]),
          type = "toggle",
          width = 1.5,
          order = 195,
        },
        colorMergedGuardiansoftheDream102 = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Guardians of the Dream (10.2)"]),
          type = "color",
          order = 196,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedGuardiansoftheDream102
          end,
          get = function()
            local color = self.db.profile.color.mergedGuardiansoftheDream102
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedGuardiansoftheDream102
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_40 = {
          type = "header",
          name = "",
          order = 197,
        },
        moveDreamingCrests = {
          name = L["Dreaming Crests"],
          desc = L["This category contains Dreaming Crests, which can be used to upgrade gear."],
          type = "toggle",
          width = 1.5,
          order = 198,
          disabled = function()
            return self.db.profile.moveMergedGuardiansoftheDream102
          end,
        },
        colorDreamingCrests = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Dreaming Crests"]),
          type = "color",
          order = 199,
          disabled = function()
            return self.db.profile.moveMergedGuardiansoftheDream102
          end,
          get = function()
            local color = self.db.profile.color.DreamingCrests
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.DreamingCrests
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_41 = {
          type = "header",
          name = "",
          order = 200,
        },
        moveDreamseeds = {
          name = L["Dreamseeds"],
          desc = L["Emerald Bounties are triggered once you plant any dreamseeds at Emerald Bounty mud piles located around the Emerald Dream."],
          type = "toggle",
          width = 1.5,
          order = 201,
          disabled = function()
            return self.db.profile.moveMergedGuardiansoftheDream102
          end,
        },
        colorDreamseeds = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Dreamseeds"]),
          type = "color",
          order = 202,
          disabled = function()
            return self.db.profile.moveMergedGuardiansoftheDream102
          end,
          get = function()
            local color = self.db.profile.color.Dreamseeds
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Dreamseeds
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    OtherItems_config = {
      type = "group",
      name = L["Other Items"],
      desc = "", -- doesnt work,
      inline = true,
      order = 203,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Other items not really fitting in another category."],
          order = 204,
        },
        moveDarkmoonCards = {
          name = L["Darkmoon Cards"],
          desc = L["Darkmoon Cards"],
          type = "toggle",
          width = 1.5,
          order = 205,
        },
        colorDarkmoonCards = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Darkmoon Cards"]),
          type = "color",
          order = 206,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.DarkmoonCards
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.DarkmoonCards
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_42 = {
          type = "header",
          name = "",
          order = 207,
        },
        moveDrakewatcherManuscripts = {
          name = L["Drakewatcher Manuscripts"],
          desc = L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"],
          type = "toggle",
          width = 1.5,
          order = 208,
        },
        colorDrakewatcherManuscripts = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Drakewatcher Manuscripts"]),
          type = "color",
          order = 209,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.DrakewatcherManuscripts
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.DrakewatcherManuscripts
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_43 = {
          type = "header",
          name = "",
          order = 210,
        },
        moveDreamboundArmor = {
          name = L["Dreambound Armor"],
          desc = L["Dreambound armor is the catch-up gear of 10.1.7."],
          type = "toggle",
          width = 1.5,
          order = 211,
        },
        colorDreamboundArmor = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Dreambound Armor"]),
          type = "color",
          order = 212,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.DreamboundArmor
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.DreamboundArmor
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_44 = {
          type = "header",
          name = "",
          order = 213,
        },
        moveDreamsurge = {
          name = L["Dreamsurge"],
          desc = L["Dreamsurges are the part of the content of 10.1.7."],
          type = "toggle",
          width = 1.5,
          order = 214,
        },
        colorDreamsurge = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Dreamsurge"]),
          type = "color",
          order = 215,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.Dreamsurge
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Dreamsurge
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_45 = {
          type = "header",
          name = "",
          order = 216,
        },
        moveFortuneCards = {
          name = L["Fortune Cards"],
          desc = L["Fortune Cards"],
          type = "toggle",
          width = 1.5,
          order = 217,
        },
        colorFortuneCards = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Fortune Cards"]),
          type = "color",
          order = 218,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.FortuneCards
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.FortuneCards
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_46 = {
          type = "header",
          name = "",
          order = 219,
        },
        moveReputationItems = {
          name = L["Reputation Items"],
          desc = L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"],
          type = "toggle",
          width = 1.5,
          order = 220,
        },
        colorReputationItems = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Reputation Items"]),
          type = "color",
          order = 221,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.ReputationItems
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.ReputationItems
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_47 = {
          type = "header",
          name = "",
          order = 222,
        },
        moveTimeRifts = {
          name = L["Time Rifts"],
          desc = L["Time Rifts are the part of the content of 10.1.5."],
          type = "toggle",
          width = 1.5,
          order = 223,
        },
        colorTimeRifts = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Time Rifts"]),
          type = "color",
          order = 224,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.TimeRifts
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TimeRifts
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_48 = {
          type = "header",
          name = "",
          order = 225,
        },
        moveTreasureMaps = {
          name = L["Treasure Maps"],
          desc = L["Maps to Treasure found in the Dragon Isles"],
          type = "toggle",
          width = 1.5,
          order = 226,
        },
        colorTreasureMaps = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Treasure Maps"]),
          type = "color",
          order = 227,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.TreasureMaps
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TreasureMaps
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_49 = {
          type = "header",
          name = "",
          order = 228,
        },
        moveTreasureSacks = {
          name = L["Treasure Sacks"],
          desc = L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."],
          type = "toggle",
          width = 1.5,
          order = 229,
        },
        colorTreasureSacks = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Treasure Sacks"]),
          type = "color",
          order = 230,
          disabled = function()
            return self.db.profile.moveMergedOtherItems
          end,
          get = function()
            local color = self.db.profile.color.TreasureSacks
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TreasureSacks
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    PreEvent_config = {
      type = "group",
      name = L["PreEvent"],
      desc = "", -- doesnt work,
      inline = true,
      order = 231,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items from the Dragonflight Pre-Event."],
          order = 232,
        },
        moveMergedPreEvent = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["PreEvent"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["PreEvent"]),
          type = "toggle",
          width = 1.5,
          order = 233,
        },
        colorMergedPreEvent = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["PreEvent"]),
          type = "color",
          order = 234,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedPreEvent
          end,
          get = function()
            local color = self.db.profile.color.mergedPreEvent
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedPreEvent
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_50 = {
          type = "header",
          name = "",
          order = 235,
        },
        movePreEventCurrency = {
          name = L["PreEvent Currency"],
          desc = L["Currency-like items dropped in the Dragonflight Pre-Patch Event"],
          type = "toggle",
          width = 1.5,
          order = 236,
          disabled = function()
            return self.db.profile.moveMergedPreEvent
          end,
        },
        colorPreEventCurrency = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["PreEvent Currency"]),
          type = "color",
          order = 237,
          disabled = function()
            return self.db.profile.moveMergedPreEvent
          end,
          get = function()
            local color = self.db.profile.color.PreEventCurrency
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PreEventCurrency
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_51 = {
          type = "header",
          name = "",
          order = 238,
        },
        movePreEventGear = {
          name = L["PreEvent Gear"],
          desc = L["Gear dropped or bought in the Dragonflight Pre-Patch Event"],
          type = "toggle",
          width = 1.5,
          order = 239,
          disabled = function()
            return self.db.profile.moveMergedPreEvent
          end,
        },
        colorPreEventGear = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["PreEvent Gear"]),
          type = "color",
          order = 240,
          disabled = function()
            return self.db.profile.moveMergedPreEvent
          end,
          get = function()
            local color = self.db.profile.color.PreEventGear
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PreEventGear
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    PrimalistGearTokens_config = {
      type = "group",
      name = L["Primalist Gear Tokens"],
      desc = "", -- doesnt work,
      inline = true,
      order = 241,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Primalist Gear Tokens is an account wide Catch-Up Gear."],
          order = 242,
        },
        moveMergedPrimalistGearTokens = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Primalist Gear Tokens"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Primalist Gear Tokens"]),
          type = "toggle",
          width = 1.5,
          order = 243,
        },
        colorMergedPrimalistGearTokens = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Primalist Gear Tokens"]),
          type = "color",
          order = 244,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.mergedPrimalistGearTokens
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedPrimalistGearTokens
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_52 = {
          type = "header",
          name = "",
          order = 245,
        },
        movePrimalistAccessories = {
          name = L["Primalist Accessories"],
          desc = L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."],
          type = "toggle",
          width = 1.5,
          order = 246,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorPrimalistAccessories = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primalist Accessories"]),
          type = "color",
          order = 247,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.PrimalistAccessories
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimalistAccessories
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_53 = {
          type = "header",
          name = "",
          order = 248,
        },
        movePrimalistCloth = {
          name = L["Primalist Cloth"],
          desc = L["Cloth Catch-Up Gear."],
          type = "toggle",
          width = 1.5,
          order = 249,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorPrimalistCloth = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primalist Cloth"]),
          type = "color",
          order = 250,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.PrimalistCloth
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimalistCloth
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_54 = {
          type = "header",
          name = "",
          order = 251,
        },
        movePrimalistLeather = {
          name = L["Primalist Leather"],
          desc = L["Leather Catch-Up Gear."],
          type = "toggle",
          width = 1.5,
          order = 252,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorPrimalistLeather = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primalist Leather"]),
          type = "color",
          order = 253,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.PrimalistLeather
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimalistLeather
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_55 = {
          type = "header",
          name = "",
          order = 254,
        },
        movePrimalistMail = {
          name = L["Primalist Mail"],
          desc = L["Mail Catch-Up Gear."],
          type = "toggle",
          width = 1.5,
          order = 255,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorPrimalistMail = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primalist Mail"]),
          type = "color",
          order = 256,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.PrimalistMail
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimalistMail
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_56 = {
          type = "header",
          name = "",
          order = 257,
        },
        movePrimalistPlate = {
          name = L["Primalist Plate"],
          desc = L["Plate Catch-Up Gear."],
          type = "toggle",
          width = 1.5,
          order = 258,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorPrimalistPlate = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primalist Plate"]),
          type = "color",
          order = 259,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.PrimalistPlate
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimalistPlate
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_57 = {
          type = "header",
          name = "",
          order = 260,
        },
        movePrimalistWeapon = {
          name = L["Primalist Weapon"],
          desc = L["Catch-Up Weapon."],
          type = "toggle",
          width = 1.5,
          order = 261,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorPrimalistWeapon = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Primalist Weapon"]),
          type = "color",
          order = 262,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.PrimalistWeapon
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PrimalistWeapon
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_58 = {
          type = "header",
          name = "",
          order = 263,
        },
        moveUntappedForbiddenKnowledge = {
          name = L["Untapped Forbidden Knowledge"],
          desc = L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."],
          type = "toggle",
          width = 1.5,
          order = 264,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
        },
        colorUntappedForbiddenKnowledge = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Untapped Forbidden Knowledge"]),
          type = "color",
          order = 265,
          disabled = function()
            return self.db.profile.moveMergedPrimalistGearTokens
          end,
          get = function()
            local color = self.db.profile.color.UntappedForbiddenKnowledge
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.UntappedForbiddenKnowledge
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    Professions_config = {
      type = "group",
      name = L["Professions"],
      desc = "", -- doesnt work,
      inline = true,
      order = 266,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Items in professions"],
          order = 267,
        },
        moveMergedProfessions = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Professions"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Professions"]),
          type = "toggle",
          width = 1.5,
          order = 268,
        },
        colorMergedProfessions = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Professions"]),
          type = "color",
          order = 269,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.mergedProfessions
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedProfessions
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_59 = {
          type = "header",
          name = "",
          order = 270,
        },
        moveAlchemyFlasks = {
          name = L["Alchemy Flasks"],
          desc = L["Crafting Reagents categorically belonging to Alchemy"],
          type = "toggle",
          width = 1.5,
          order = 271,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorAlchemyFlasks = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Alchemy Flasks"]),
          type = "color",
          order = 272,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.AlchemyFlasks
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.AlchemyFlasks
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_60 = {
          type = "header",
          name = "",
          order = 273,
        },
        moveCloth = {
          name = L["Cloth"],
          desc = L["Crafting Reagents categorically belonging to Cloth"],
          type = "toggle",
          width = 1.5,
          order = 274,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorCloth = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Cloth"]),
          type = "color",
          order = 275,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Cloth
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Cloth
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_61 = {
          type = "header",
          name = "",
          order = 276,
        },
        moveCooking = {
          name = L["Cooking"],
          desc = L["Crafting Reagents categorically belonging to Cooking"],
          type = "toggle",
          width = 1.5,
          order = 277,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorCooking = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Cooking"]),
          type = "color",
          order = 278,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Cooking
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Cooking
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_62 = {
          type = "header",
          name = "",
          order = 279,
        },
        moveEnchanting = {
          name = L["Enchanting"],
          desc = L["Crafting Reagents categorically belonging to Enchanting"],
          type = "toggle",
          width = 1.5,
          order = 280,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorEnchanting = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Enchanting"]),
          type = "color",
          order = 281,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Enchanting
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Enchanting
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_63 = {
          type = "header",
          name = "",
          order = 282,
        },
        moveEnchantingInsightoftheBlue = {
          name = L["Enchanting - Insight of the Blue"],
          desc = L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."],
          type = "toggle",
          width = 1.5,
          order = 283,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorEnchantingInsightoftheBlue = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Enchanting - Insight of the Blue"]),
          type = "color",
          order = 284,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.EnchantingInsightoftheBlue
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.EnchantingInsightoftheBlue
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_64 = {
          type = "header",
          name = "",
          order = 285,
        },
        moveEngineering = {
          name = L["Engineering"],
          desc = L["Crafting Reagents categorically belonging to Engineering"],
          type = "toggle",
          width = 1.5,
          order = 286,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorEngineering = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Engineering"]),
          type = "color",
          order = 287,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Engineering
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Engineering
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_65 = {
          type = "header",
          name = "",
          order = 288,
        },
        moveFishingLures = {
          name = L["Fishing Lures"],
          desc = L["Fishing Lures for catching specific fish"],
          type = "toggle",
          width = 1.5,
          order = 289,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorFishingLures = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Fishing Lures"]),
          type = "color",
          order = 290,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.FishingLures
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.FishingLures
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_66 = {
          type = "header",
          name = "",
          order = 291,
        },
        moveHerbs = {
          name = L["Herbs"],
          desc = L["Crafting Reagents categorically belonging to Herbs"],
          type = "toggle",
          width = 1.5,
          order = 292,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorHerbs = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Herbs"]),
          type = "color",
          order = 293,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Herbs
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Herbs
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_67 = {
          type = "header",
          name = "",
          order = 294,
        },
        moveHerbsSeeds = {
          name = L["Herbs - Seeds"],
          desc = L["Seeds to plant into Rich Soil which in return grants some herbs"],
          type = "toggle",
          width = 1.5,
          order = 295,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorHerbsSeeds = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Herbs - Seeds"]),
          type = "color",
          order = 296,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.HerbsSeeds
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.HerbsSeeds
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_68 = {
          type = "header",
          name = "",
          order = 297,
        },
        moveInscription = {
          name = L["Inscription"],
          desc = L["Crafting Reagents categorically belonging to Inscription"],
          type = "toggle",
          width = 1.5,
          order = 298,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorInscription = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Inscription"]),
          type = "color",
          order = 299,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Inscription
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Inscription
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_69 = {
          type = "header",
          name = "",
          order = 300,
        },
        moveJewelcrafting = {
          name = L["Jewelcrafting"],
          desc = L["Crafting Reagents categorically belonging to Jewelcrafting"],
          type = "toggle",
          width = 1.5,
          order = 301,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorJewelcrafting = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Jewelcrafting"]),
          type = "color",
          order = 302,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Jewelcrafting
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Jewelcrafting
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_70 = {
          type = "header",
          name = "",
          order = 303,
        },
        moveLeather = {
          name = L["Leather"],
          desc = L["Crafting Reagents categorically belonging to Leather"],
          type = "toggle",
          width = 1.5,
          order = 304,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorLeather = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Leather"]),
          type = "color",
          order = 305,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Leather
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Leather
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_71 = {
          type = "header",
          name = "",
          order = 306,
        },
        moveLeatherBait = {
          name = L["Leather - Bait"],
          desc = L["Baits to attract skinnable creatures"],
          type = "toggle",
          width = 1.5,
          order = 307,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorLeatherBait = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Leather - Bait"]),
          type = "color",
          order = 308,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.LeatherBait
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.LeatherBait
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_72 = {
          type = "header",
          name = "",
          order = 309,
        },
        moveMining = {
          name = L["Mining"],
          desc = L["Crafting Reagents categorically belonging to Mining"],
          type = "toggle",
          width = 1.5,
          order = 310,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
        },
        colorMining = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Mining"]),
          type = "color",
          order = 311,
          disabled = function()
            return self.db.profile.moveMergedProfessions
          end,
          get = function()
            local color = self.db.profile.color.Mining
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Mining
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    Recipes_config = {
      type = "group",
      name = L["Recipes"],
      desc = "", -- doesnt work,
      inline = true,
      order = 312,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Recipes for all professions."],
          order = 313,
        },
        moveMergedRecipes = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Recipes"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Recipes"]),
          type = "toggle",
          width = 1.5,
          order = 314,
        },
        colorMergedRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for the merged %s category."], L["Recipes"]),
          type = "color",
          order = 315,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.mergedRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_73 = {
          type = "header",
          name = "",
          order = 316,
        },
        moveAlchemyRecipes = {
          name = L["Alchemy Recipes"],
          desc = L["Recipes for crafting potions, elixirs, and transmuting materials."],
          type = "toggle",
          width = 1.5,
          order = 317,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorAlchemyRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Alchemy Recipes"]),
          type = "color",
          order = 318,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.AlchemyRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.AlchemyRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_74 = {
          type = "header",
          name = "",
          order = 319,
        },
        moveBlacksmithingRecipes = {
          name = L["Blacksmithing Recipes"],
          desc = L["Recipes for forging metal armor, weapons, and enhancements."],
          type = "toggle",
          width = 1.5,
          order = 320,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorBlacksmithingRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Blacksmithing Recipes"]),
          type = "color",
          order = 321,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.BlacksmithingRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.BlacksmithingRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_75 = {
          type = "header",
          name = "",
          order = 322,
        },
        moveCookingRecipes = {
          name = L["Cooking Recipes"],
          desc = L["Recipes for preparing food that provides buffs."],
          type = "toggle",
          width = 1.5,
          order = 323,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorCookingRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Cooking Recipes"]),
          type = "color",
          order = 324,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.CookingRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.CookingRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_76 = {
          type = "header",
          name = "",
          order = 325,
        },
        moveEnchantingRecipes = {
          name = L["Enchanting Recipes"],
          desc = L["Recipes for enchanting gear with magical properties."],
          type = "toggle",
          width = 1.5,
          order = 326,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorEnchantingRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Enchanting Recipes"]),
          type = "color",
          order = 327,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.EnchantingRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.EnchantingRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_77 = {
          type = "header",
          name = "",
          order = 328,
        },
        moveEngineeringRecipes = {
          name = L["Engineering Recipes"],
          desc = L["Recipes for creating gadgets, explosives, and mechanical devices."],
          type = "toggle",
          width = 1.5,
          order = 329,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorEngineeringRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Engineering Recipes"]),
          type = "color",
          order = 330,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.EngineeringRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.EngineeringRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_78 = {
          type = "header",
          name = "",
          order = 331,
        },
        moveInscriptionRecipes = {
          name = L["Inscription Recipes"],
          desc = L["Recipes for scribing glyphs and crafting scrolls and tomes."],
          type = "toggle",
          width = 1.5,
          order = 332,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorInscriptionRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Inscription Recipes"]),
          type = "color",
          order = 333,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.InscriptionRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.InscriptionRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_79 = {
          type = "header",
          name = "",
          order = 334,
        },
        moveJewelcraftingRecipes = {
          name = L["Jewelcrafting Recipes"],
          desc = L["Recipes for cutting gems and crafting jewelry."],
          type = "toggle",
          width = 1.5,
          order = 335,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorJewelcraftingRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Jewelcrafting Recipes"]),
          type = "color",
          order = 336,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.JewelcraftingRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.JewelcraftingRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_80 = {
          type = "header",
          name = "",
          order = 337,
        },
        moveLeatherworkingRecipes = {
          name = L["Leatherworking Recipes"],
          desc = L["Recipes for crafting leather and mail armor."],
          type = "toggle",
          width = 1.5,
          order = 338,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorLeatherworkingRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Leatherworking Recipes"]),
          type = "color",
          order = 339,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.LeatherworkingRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.LeatherworkingRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_81 = {
          type = "header",
          name = "",
          order = 340,
        },
        moveTailoringRecipes = {
          name = L["Tailoring Recipes"],
          desc = L["Recipes for weaving cloth armor and other cloth items."],
          type = "toggle",
          width = 1.5,
          order = 341,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
        },
        colorTailoringRecipes = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Tailoring Recipes"]),
          type = "color",
          order = 342,
          disabled = function()
            return self.db.profile.moveMergedRecipes
          end,
          get = function()
            local color = self.db.profile.color.TailoringRecipes
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TailoringRecipes
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
    TemporaryPermanentEnhancements_config = {
      type = "group",
      name = L["Temporary & Permanent Enhancements"],
      desc = "", -- doesnt work,
      inline = true,
      order = 343,
      args = {
        Legendaries_desc = {
          type = "description",
          name = L["Use these for a powerup!"],
          order = 344,
        },
        moveMergedTemporaryPermanentEnhancements = {
          name = string.format(L["%sMerge %s%s"], "|cffffd800", L["Temporary & Permanent Enhancements"], "|r"),
          desc = string.format(L["Merge all %s into a single category."], L["Temporary & Permanent Enhancements"]),
          type = "toggle",
          width = 1.5,
          order = 345,
        },
        colorMergedTemporaryPermanentEnhancements = {
          name = L["Color"],
          desc = string.format(
            L["Select a color for the merged %s category."],
            L["Temporary & Permanent Enhancements"]
          ),
          type = "color",
          order = 346,
          hasAlpha = false,
          disabled = function()
            return not self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
          get = function()
            local color = self.db.profile.color.mergedTemporaryPermanentEnhancements
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.mergedTemporaryPermanentEnhancements
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_82 = {
          type = "header",
          name = "",
          order = 347,
        },
        moveGems = {
          name = L["Gems"],
          desc = L["These are gems that you can typically apply to armor to improve it."],
          type = "toggle",
          width = 1.5,
          order = 348,
          disabled = function()
            return self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
        },
        colorGems = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Gems"]),
          type = "color",
          order = 349,
          disabled = function()
            return self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
          get = function()
            local color = self.db.profile.color.Gems
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.Gems
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_83 = {
          type = "header",
          name = "",
          order = 350,
        },
        movePermanentEnhancements = {
          name = L["Permanent Enhancements"],
          desc = L["These are permanent enhancements that you can typically apply to armor to improve it."],
          type = "toggle",
          width = 1.5,
          order = 351,
          disabled = function()
            return self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
        },
        colorPermanentEnhancements = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Permanent Enhancements"]),
          type = "color",
          order = 352,
          disabled = function()
            return self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
          get = function()
            local color = self.db.profile.color.PermanentEnhancements
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.PermanentEnhancements
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
        seperator_84 = {
          type = "header",
          name = "",
          order = 353,
        },
        moveTemporaryEnhancements = {
          name = L["Temporary Enhancements"],
          desc = L["These are temporary enhancements that you can typically apply to armor to improve it."],
          type = "toggle",
          width = 1.5,
          order = 354,
          disabled = function()
            return self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
        },
        colorTemporaryEnhancements = {
          name = L["Color"],
          desc = string.format(L["Select a color for %s."], L["Temporary Enhancements"]),
          type = "color",
          order = 355,
          disabled = function()
            return self.db.profile.moveMergedTemporaryPermanentEnhancements
          end,
          get = function()
            local color = self.db.profile.color.TemporaryEnhancements
            AdiBags:UpdateFilters()
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b)
            local color = self.db.profile.color.TemporaryEnhancements
            color.r, color.g, color.b = r, g, b
            AdiBags:UpdateFilters()
          end,
        },
      },
    },
  },
    AdiBags:GetOptionHandler(self, false, function()
      return self:Update()
    end)
end
