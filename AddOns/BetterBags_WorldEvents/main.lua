---@class BetterBags: AceAddon
local addon = LibStub("AceAddon-3.0"):GetAddon("BetterBags")

---@class Categories: AceModule
local categories = addon:GetModule("Categories")

-- Localization table
local locales = {
    ["enUS"] = {
        ["Noblegarden"] = "Noblegarden",
        ["Darkmoon Faire"] = "Darkmoon Faire",
        ["Lunar Festival"] = "Lunar Festival",
        ["Remix"] = "Remix",
        ["Meta Gems"] = "Meta Gems",
        ["Cogwheel Gems"] = "Cogwheel Gems",
        ["Tinker Gems"] = "Tinker Gems",
        ["Prismatic Gems"] = "Prismatic Gems",
        ["Enhancements"] = "Enhancements",
        ["Utilities"] = "Utilities",
        ["Consumables"] = "Potions & Bandages",
    },
    ["frFR"] = {
        ["Noblegarden"] = "Le Jardin des nobles",
        ["Darkmoon Faire"] = "Foire de Sombrelune",
        ["Lunar Festival"] = "Fête lunaire",
        ["Remix"] = "Remix",
        ["Meta Gems"] = "Meta-gemmes",
        ["Cogwheel Gems"] = "Roues dentées précieuses",
        ["Tinker Gems"] = "Gemmes de bricolage",
        ["Prismatic Gems"] = "Gemmes prosmatiques",
        ["Enhancements"] = "Améliorations",
        ["Utilities"] = "Utilitaires",
        ["Consumables"] = "Potions et Bandages",
    },
    ["deDE"] = {
        ["Noblegarden"] = "Nobelgartenfest",
        ["Darkmoon Faire"] = "Dunkelmond-Jahrmarkt",
        ["Lunar Festival"] = "Mondfest",
        ["Remix"] = "Remix",
        ["Meta Gems"] = "Metaedelstein",
        ["Cogwheel Gems"] = "Zahnradedelstein",
        ["Tinker Gems"] = "Tüftleredelstein",
        ["Prismatic Gems"] = "Prismatischer Edelstein",
        ["Enhancements"] = "Verbrauchbares: Verbesserungen",
        ["Utilities"] = "Verbrauchbares: Hilfsmittel",
        ["Consumables"] = "Tränke und Verbände",
    },
}

-- Detects current language
local currentLocale = GetLocale()

-- Function to get the translation
local function L(key)
    return locales[currentLocale] and locales[currentLocale][key] or locales["enUS"][key]
end

--Noblegarden
local Noblegarden = {
    116258, --Mystical Spring Bouquet
    216874, --Loot-Filled Basket
    155905, --Cursed Rabbit's Foot
    45072, --Brightly Colored Egg
    72145, --Swift Springstrider
    44791, --Noblegarden Chocolate
    213428, --Loot-Stuffed Basket
    116371, --Magnificently-Painted Egg
    116370, --Intricately-Painted Egg
    44793, --Tome of Polymorph: Rabbit
    44806, --Brightly Colored Shell Fragment
    116369, --Poorly-Painted Egg
    44794, --Spring Rabbit's Foot
    44803, --Spring Circlet
    6835, --Black Tuxedo Pants
    19028, --Elegant Dress
    45073, --Spring Flowers
    45067, --Egg Basket
    74283, --Pink Spring Circlet
    44792, --Blossoming Branch
    74282, --Black Spring Circlet
    44800, --Spring Robes
    44818, --Noblegarden Egg
    6833, --White Tuxedo Shirt
    44802, --Borrowed Egg Basket
    212599, --Noble Flying Carpet
    212786, --Lovely Duckling
    216881, --Duck Disguiser
    212701, --Spring Reveler's Turquoise Boots
    212711, --Spring Reveler's Turquoise Dress
    212985, --Spring Reveler's Turquoise Pants
    212698, --Spring Reveler's Turquoise Attire
    212699, --Spring Reveler's Turquoise Belt
    212715, --Spring Reveler's Turquoise Sun Hat
    116357, --Poorly-Painted Egg
    116358, --Intricately-Painted Egg
    116359, --Magnificently-Painted Egg
    141532, --Noblegarden Bunny
    151804, --Black Tuxedo Pants
    151806, --Elegant Dress
    164922, --Blue Spring Circlet
    164923, --Brown Spring Circlet
    164924, --Yellow Spring Circlet
    165802, --Noble Gardener's Hearthstone
    188694, --Spring Florist's Pouch
    204675, --A Drake's Big Basket of Eggs
    216898, --Mallard Duck Disguise
    216901, --White Duck Disguise
    216890, --Black Duck Disguise
    216897, --Brown Duck Disguise
    216902, --Yellow Duck Disguise
    216900 --Pink Duck Disguise
}

local Darkmoonfaire = {
    71083, --Darkmoon Game Token
    93724, --Darkmoon Game Prize
    71970, --Darkmoon Prize Ticket
    19296, --Greater Darkmoon Prize
    19297, --Lesser Darkmoon Prize
    19298, --Minor Darkmoon Prize
    19425, --Mysterious Lockbox
    116052, --Nobleman's Coat
    116134, --Noble's Fancy Boots
    116136, --Noblewoman's Skirt
    116133, --Nobleman's Pantaloons
    116137, --Noblewoman's Finery
    78340, --Cloak of the Darkmoon Faire
    78341, --Darkmoon Hammer
    122129, --Fire-Eater's Vial
    138202, --Sparklepony XL
    116115, --Blazing Wings
    97994, --Darkmoon Seesaw
    126931, --Seafarer's Slidewhistle
    105898, --Moonfang's Paw
    116139, --Haunting Memento
    116067, --Moonfang Shroud
    101571, --Ring of Broken Promises
    122121, --Darkmoon Gazer
    122119, --Everlasting Darkmoon Firework
    122122, --Darkmoon Tonk Controller
    75042, --Flimsy Yellow Balloon
    122123, --Darkmoon Ring-Flinger
    90899, --Darkmoon Whistle
    122126, --Attraction Sign
    122120, --Gaze of the Darkmoon
    124669, --Darkmoon Daggermaw
    73766, --Darkmoon Dancing Bear
    72140, --Swift Forest Strider
    138429, --Cropped Tabard of the Scarlet Crusade
    80008, --Darkmoon Rabbit
    73905, --Darkmoon Zeppelin
    74981, --Darkmoon Cub
    73953, --Sea Pony
    116064, --Syd the Squid
    19450, --A Jubling's Tiny Home
    91040, --Darkmoon Eye
    73765, --Darkmoon Turtle
    101570, --Moon Moon
    75042, --Flimsy Yellow Balloon
    73762, --Darkmoon Balloon
    73903, --Darkmoon Tonk
    73764, --Darkmoon Monkey
    126925, --Blorp's Bubble
    126926, --Translucent Shell
    123862, --Hogs' Studded Collar
    91003, --Darkmoon Hatchling
    122125, --Race MiniZep Controller
    91031, --Darkmoon Glowfly
    75041, --Flimsy Green Balloon
    75040, --Flimsy Darkmoon Balloon
    19422, --Darkmoon Faire Fortune
    19443, --Sayge's Fortune #25
    19266, --Sayge's Fortune #20
    19255, --Sayge's Fortune #22
    19424, --Sayge's Fortune #24
    19453, --Sayge's Fortune #28
    19254, --Sayge's Fortune #21
    19242, --Sayge's Fortune #7
    19247, --Sayge's Fortune #12
    19237, --Sayge's Fortune #19
    19253, --Sayge's Fortune #17
    19423, --Sayge's Fortune #23
    19452, --Sayge's Fortune #27
    19249, --Sayge's Fortune #14
    19250, --Sayge's Fortune #15
    19252, --Sayge's Fortune #18
    19454, --Sayge's Fortune #29
    19229, --Sayge's Fortune #1
    19451, --Sayge's Fortune #26
    19240, --Sayge's Fortune #5
    19239, --Sayge's Fortune #4
    19241, --Sayge's Fortune #6
    19245, --Sayge's Fortune #10
    19251, --Sayge's Fortune #16
    19238, --Sayge's Fortune #3
    19244, --Sayge's Fortune #9
    19246, --Sayge's Fortune #11
    19248, --Sayge's Fortune #13
    19243, --Sayge's Fortune #8
    19256, --Sayge's Fortune #2
    71976, --Darkmoon Prize
    71977, --Darkmoon Craftsman's Kit
    72049, --Darkmoon Banner
    72048, --Darkmoon Banner Kit
    71978 --Darkmoon Bandage
}

local LunarFestival = {
    74611, -- Festival Lantern
    74610, -- Lunar Lantern
    44919, -- Schematic: Firework Launcher
    21741, -- Cluster Rocket Recipes
    21100, -- Coin of Ancestry
    21721, -- Moonglow
    21746, -- Lucky Red Envelope
    21730, -- Schematic: Blue Rocket Cluster
    21733, -- Schematic: Large Blue Rocket Cluster
    21728, -- Schematic: Large Green Rocket
    21713, -- Elune's Candle
    21154, -- Festival Dress
    21538, -- Festive Pink Dress
    21570, -- Cluster Launcher
    21740, -- Small Rocket Recipes
    21544, -- Festive Blue Pant Suit
    21727, -- Schematic: Large Blue Rocket
    21725, -- Schematic: Small Green Rocket
    21571, -- Blue Rocket Cluster
    21745, -- Elder's Moonstone
    21747, -- Festival Firecracker
    21540, -- Elune's Lantern
    21539, -- Festive Purple Dress
    44916, -- Pattern: Festival Dress
    21724, -- Schematic: Small Blue Rocket
    21726, -- Schematic: Small Red Rocket
    21536, -- Elune Stone
    21640, -- Lunar Festival Fireworks Pack
    21541, -- Festive Black Pant Suit
    21731, -- Schematic: Green Rocket Cluster
    21734, -- Schematic: Large Green Rocket Cluster
    21729, -- Schematic: Large Red Rocket
    21735, -- Schematic: Large Red Rocket Cluster
    21732, -- Schematic: Red Rocket Cluster
    21537, -- Festival Dumplings
    21542, -- Festival Suit
    21743, -- Large Cluster Rocket Recipes
    21742, -- Large Rocket Recipes
    21711, -- Lunar Festival Invitation
    21157, -- Festive Green Dress
    21543, -- Festive Teal Pant Suit
    44918, -- Schematic: Cluster Launcher
    21744, -- Lucky Rocket Cluster
    90000, -- Everlasting Horde Firework
    89999 -- Everlasting Alliance Firework
}

local WoWRemixMoP = {
    217930, --Nostwin's Voucher
    211388, --Timerunner's Starter Kit
    219218, --Timerunner's Starter Kit
    219219, --Timerunner's Starter Kit
    -- Cache
    223908, --Minor Bronze Cache
    223909, --Lesser Bronze Cache
    223910, --Bronze Cache
    223911, --Greater Bronze Cache
    211279, --Cache of Infinite Treasure
    --Gear
    208555, --Timerunner's Idol
    208554, --Timerunner's Beacon
    208487, --Timerunner's Ring
    208491, --Timerunner's Seal
    210523, --Timerunner's Amulet
    --Miscellaneous
    223905, --Asynchronized Meta Gem
    223904, --Asynchronized Cogwheel Gem
    223906, --Asynchronized Tinker Gem
    223907, --Asynchronized Prismatic Gem
    --Companions
    221817, --Muskpaw Calf
    --Toys
    220777, --Cherry Blossom Trail
    217723, --Fury of Xuen
    217724, --Kindness of Chi-ji
    217725, --Essence of Yu'lon
    217726, --Fortitude of Niuzao
    104262, --Odd Polished Stone Odd Polished Stone
    86565, --Battle Horn
    134023, --Bottled Tornado
    86575, --Chalice of Secrets
    86590, --Essence of the Breeze
    86594, --Helpful Wikky's Whistle
    86571, --Kang's Bindstone
    86589, --Ai-Li's Skymirror
    86578, --Eternal Warrior's Sigil
    86581, --Farwater Conch
    86593, --Hozen Beach Ball
    86586, --Panflute of Pandaria
    86583, --Salyin Battle Banner
    86573, --Shard of Archstone
    86582, --Aqua Jewel
    86568, --Mr. Smite's Brass Compass
    86588, --Pandaren Firework Launcher
    104302, --Blackflame Daggers
    104331, --Warning Sign
    98136, --Gastropod Shell
    104309, --Eternal Kiln
    89205, --Mini Mana Bomb
    --Mounts
    220768, --Reins of the Astral Emperor's Serpent
    220766, --Reins of the August Phoenix
    213582, --Sky Surfer
    213576, --Golden Discus Golden Discus
    213584, --Mogu Hazeblazer Mogu Hazeblazer
    213595, --Feathered Windsurfer String Feathered Windsurfer String
    87784, --Reins of the Jungle Riding Crane Reins of the Jungle Riding Crane
    213602, --Reins of the Gilded Riding Crane Reins of the Gilded Riding Crane
    213603, --Reins of the Pale Riding Crane Reins of the Pale Riding Crane
    213605, --Reins of the Rose Riding Crane Reins of the Rose Riding Crane
    213606, --Reins of the Silver Riding Crane Reins of the Silver Riding Crane
    213607, --Reins of the Luxurious Riding Crane Reins of the Luxurious Riding Crane
    213604, --Reins of the Tropical Riding Crane Reins of the Tropical Riding Crane
    213608, --Reins of the Snowy Riding Goat Reins of the Snowy Riding Goat
    213609, --Reins of the Little Red Riding Goat Reins of the Little Red Riding Goat
    213628, --Reins of the Riverwalker Mushan Reins of the Riverwalker Mushan
    213627, --Reins of the Palehide Mushan Beast Reins of the Palehide Mushan Beast
    87786, --Reins of the Black Riding Yak Reins of the Black Riding Yak
    87787, --Reins of the Modest Expedition Yak Reins of the Modest Expedition Yak
    84753, --Reins of the Kafa Yak Reins of the Kafa Yak
    213626, --Reins of the Purple Shado-Pan Riding Tiger Reins of the Purple Shado-Pan Riding Tiger
    213624, --Cobalt Juggernaut Cobalt Juggernaut
    213625, --Fel Iron Juggernaut Fel Iron Juggernaut
    213623, --Reins of the Bloody Skyscreamer Reins of the Bloody Skyscreamer
    213622, --Reins of the Night Pterrorwing Reins of the Night Pterrorwing
    213621, --Reins of the Jade Pterrordax Reins of the Jade Pterrordax
    218111, --Reins of the Amber Pterrordax Reins of the Amber Pterrordax
    213600, --Reins of the Marble Quilen Reins of the Marble Quilen
    213601, --Reins of the Guardian Quilen Reins of the Guardian Quilen
    213598, --Reins of the Dashing Windsteed Reins of the Dashing Windsteed
    213597, --Reins of the Forest Windsteed Reins of the Forest Windsteed
    213596, --Reins of the Daystorm Windsteed Reins of the Daystorm Windsteed
    --Cosmetics
    215320, --Ensemble:
    215219, --Ensemble:
    217836, --Ensemble:
    215189, --Ensemble:
    217837, --Ensemble:
    215327, --Ensemble:
    215324, --Ensemble:
    215267, --Ensemble:
    217846, --Ensemble:
    215330, --Ensemble:
    217841, --Ensemble:
    217843, --Ensemble:
    215241, --Ensemble:
    215289, --Ensemble:
    215275, --Ensemble:
    215252, --Ensemble:
    215261, --Ensemble:
    215335, --Ensemble:
    215334, --Ensemble:
    215245, --Ensemble:
    215220, --Ensemble:
    215196, --Ensemble:
    215247, --Ensemble:
    217842, --Ensemble:
    215193, --Ensemble:
    215199, --Ensemble:
    215255, --Ensemble:
    215295, --Ensemble:
    217834, --Ensemble:
    215293, --Ensemble:
    215201, --Ensemble:
    217838, --Ensemble:
    215264, --Ensemble:
    215208, --Ensemble:
    215339, --Ensemble:
    215256, --Ensemble:
    217845, --Ensemble:
    217839, --Ensemble:
    217835, --Ensemble:
    215298, --Ensemble:
    217833, --Ensemble:
    217844, --Ensemble:
    215204, --Ensemble:
    215302, --Ensemble:
    215343, --Ensemble:
    215346, --Ensemble:
    215210, --Ensemble:
    215214, --Ensemble:
    215304, --Ensemble:
    215277, --Ensemble:
    215276, --Ensemble:
    223485, --Ensemble:
    215176, --Ensemble:
    215285, --Ensemble:
    215352, --Ensemble:
    215310, --Ensemble:
    215190, --Ensemble:
    215329, --Ensemble:
    215321, --Ensemble:
    215209, --Ensemble:
    215286, --Ensemble:
    215274, --Ensemble:
    215221, --Ensemble:
    215238, --Ensemble:
    215216, --Ensemble:
    215195, --Ensemble:
    223486, --Ensemble:
    215358, --Ensemble:
    215336, --Ensemble:
    215183, --Ensemble:
    215191, --Ensemble:
    215251, --Ensemble:
    215345, --Ensemble:
    215186, --Ensemble:
    215356, --Ensemble:
    215225, --Ensemble:
    215248, --Ensemble:
    215287, --Ensemble:
    215242, --Ensemble:
    215181, --Ensemble:
    215217, --Ensemble:
    215322, --Ensemble:
    215250, --Ensemble:
    215272, --Ensemble:
    215207, --Ensemble:
    215222, --Ensemble:
    215355, --Ensemble:
    215192, --Ensemble:
    215244, --Ensemble:
    215271, --Ensemble:
    215253, --Ensemble:
    215268, --Ensemble:
    215254, --Ensemble:
    222961, --Ensemble:
    215348, --Ensemble:
    215198, --Ensemble:
    215328, --Ensemble:
    215351, --Ensemble:
    215265, --Ensemble:
    215288, --Ensemble:
    215305, --Ensemble:
    215331, --Ensemble:
    215297, --Ensemble:
    215200, --Ensemble:
    215203, --Ensemble:
    215308, --Ensemble:
    215312, --Ensemble:
    215273, --Ensemble:
    215282, --Ensemble:
    215301, --Ensemble:
    223244, --Ensemble:
    215182, --Ensemble:
    215213, --Ensemble:
    215224, --Ensemble:
    215260, --Ensemble:
    215243, --Ensemble:
    215296, --Ensemble:
    215290, --Ensemble:
    215266, --Ensemble:
    215354, --Ensemble:
    215323, --Ensemble:
    215353, --Ensemble:
    215194, --Ensemble:
    215342, --Ensemble:
    215211, --Ensemble:
    215249, --Ensemble:
    215340, --Ensemble:
    221542, --Ensemble:
    215188, --Ensemble:
    215309, --Ensemble:
    215232, --Ensemble:
    215306, --Ensemble:
    215357, --Ensemble:
    215344, --Ensemble:
    215262, --Ensemble:
    215319, --Ensemble:
    215326, --Ensemble:
    215227, --Ensemble:
    215259, --Ensemble:
    215299, --Ensemble:
    215187, --Ensemble:
    215197, --Ensemble:
    215263, --Ensemble:
    215337, --Ensemble:
    215311, --Ensemble:
    215332, --Ensemble:
    215269, --Ensemble:
    215294, --Ensemble:
    215333, --Ensemble:
    215212, --Ensemble:
    215239, --Ensemble:
    215279, --Ensemble:
    215246, --Ensemble:
    215258, --Ensemble:
    215300, --Ensemble:
    215303, --Ensemble:
    215315, --Ensemble:
    215223, --Ensemble:
    215341, --Ensemble:
    215202, --Ensemble:
    215313, --Ensemble:
    215215, --Ensemble:
    215291, --Ensemble:
    215347, --Ensemble:
    215283, --Ensemble:
    215284, --Ensemble:
    215316, --Ensemble:
    222960, --Ensemble:
    215228, --Ensemble:
    215205, --Ensemble:
    215229, --Ensemble:
    215307, --Ensemble:
    215218, --Ensemble:
    215240, --Ensemble:
    215278, --Ensemble:
    215314, --Ensemble:
    215325, --Ensemble:
    215317, --Ensemble:
    215338, --Ensemble:
    215349, --Ensemble:
    215350, --Ensemble:
    223246, --Ensemble:
    215318, --Ensemble:
    215270, --Ensemble:
    215226, --Ensemble:
    215292, --Ensemble:
    211446, --Ensemble:
    215184, --Ensemble:
    215185, --Ensemble:
    215206, --Ensemble:
    221847, --Ensemble:
    215231, --Ensemble:
    215230, --Ensemble:
    215280, --Ensemble:
    211313, --Ensemble:
    215281, --Ensemble:
    221540, --Ensemble:
    222959, --Ensemble:
    221541, --Ensemble:
    224717, --Ensemble:
    219065, --Ensemble:
    223245, --Ensemble:
    223243, --Ensemble:
    219086, --Ensemble:
    221543, --Ensemble:
    219075, --Ensemble:
    219076, --Ensemble:
    219080, --Ensemble:
    219077, --Ensemble:
    219081, --Ensemble:
    219084, --Ensemble:
    219085, --Ensemble:
    219091, --Ensemble:
    219066, --Ensemble:
    219068, --Ensemble:
    219070, --Ensemble:
    219078, --Ensemble:
    219079, --Ensemble:
    219087, --Ensemble:
    219090, --Ensemble:
    219095, --Ensemble:
    219067, --Ensemble:
    219069, --Ensemble:
    219071, --Ensemble:
    219072, --Ensemble:
    219073, --Ensemble:
    219074, --Ensemble:
    219082, --Ensemble:
    219083, --Ensemble:
    219088, --Ensemble:
    219089, --Ensemble:
    219092, --Ensemble:
    219093, --Ensemble:
    219094, --Ensemble:
    219096, --Ensemble:
    219097, --Ensemble:
    219098, --Ensemble:
    219099, --Ensemble:
    217824, --Arsenal:
    217832, --Arsenal:
    217823, --Arsenal:
    217825, --Arsenal:
    217828, --Arsenal:
    217827, --Arsenal:
    217829, --Arsenal:
    217819, --Arsenal:
    217820, --Arsenal:
    217826, --Arsenal:
    217830, --Arsenal:
    217831, --Arsenal:
    217821, --Arsenal:
    
}
local WoWRemixMoP_metagems = {
    -- Meta Gems
    219878, --Tireless Spirit
    221977, --Funeral Pyre
    216663, --Oblivion Sphere
    220211, --Precipice of Madness
    216711, --Chi-ji, the Red Crane
    220117, --Ward of Salvation
    216671, --Thundering Orb
    219386, --Locus of Power
    216695, --Lifestorm
    221982, --Bulwark of the Black Ox
    220120, --Soul Tether
}
local WoWRemixMoP_cogwheelgems = { 
    -- Cogwheel Gems
    216632, --Sprint
    218044, --Pursuit of Justice
    218045, --Door of Shadows
    216629, --Blink
    218043, --Wild Charge
    218108, --Dark Pact
    216631, --Roll
    217989, --Trailblazer
    218082, --Spiritwalker's Grace
    218109, --Death's Advance
    218110, --Soulshape
    217983, --Disengage
    218003, --Leap of Faith
    218004, --Vanish
    216630, --Heroic Leap
    218005, --Stampeding Roar
    218046, --Spirit Walk
}
local WoWRemixMoP_tinkergems = {
    -- Tinker Gems
    219801, --Ankh of Reincarnation
    212366, --Arcanist's Edge
    219944, --Bloodthirsty Coral
    219818, --Brilliance
    216649, --Brittle
    216648, --Cold Front
    217957, --Deliverance
    212694, --Enkindle
    212749, --Explosive Barrage
    212365, --Fervor
    219817, --Freedom
    212916, --Frost Armor
    219777, --Grounding
    216647, --Hailstorm
    217964, --Holy Martyr
    212758, --Incendiary Terror
    219389, --Lightning Rod
    216624, --Mark of Arrogance
    216650, --Memory of Vengeance
    212759, --Meteor Storm
    212361, --Opportunist
    216625, --Quick Strike
    217961, --Righteous Frenzy
    217927, --Savior
    216651, --Searing Light
    216626, --Slay
    219452, --Static Charge
    219523, --Storm Overload
    212362, --Sunstrider's Flourish
    212629, --Test Ruby
    216627, --Tinkmaster's Shield
    219527, --Vampiric Aura
    216628, --Victory Fire
    217903, --Vindication
    217907, --Warmth
    212760, --Wildfire
    219516, --Windweaver
}
local WoWRemixMoP_prismaticgems = {
    --Prismatic Gems
    210714, --Chipped Deadly Sapphire
    210717, --Chipped Hungering Ruby
    210715, --Chipped Masterful Amethyst
    210681, --Chipped Quick Topaz
    220367, --Chipped Stalwart Pearl
    211109, --Chipped Sustaining Emerald
    210716, --Chipped Swift Opal
    220371, --Chipped Versatile Diamond
    211123, --Deadly Sapphire
    216644, --Flawed Deadly Sapphire
    216641, --Flawed Hungering Ruby
    216640, --Flawed Masterful Amethyst
    216643, --Flawed Quick Topaz
    220368, --Flawed Stalwart Pearl
    216642, --Flawed Sustaining Emerald
    216639, --Flawed Swift Opal
    220372, --Flawed Versatile Diamond
    210718, --Hungering Ruby
    211106, --Masterful Amethyst
    211102, --Perfect Deadly Sapphire
    211103, --Perfect Hungering Ruby
    211108, --Perfect Masterful Amethyst
    211110, --Perfect Quick Topaz
    220369, --Perfect Stalwart Pearl
    211105, --Perfect Sustaining Emerald
    211101, --Perfect Swift Opal
    220373, --Perfect Versatile Diamond
    211107, --Quick Topaz
    220370, --Stalwart Pearl
    211125, --Sustaining Emerald
    211124, --Swift Opal
    220374, --Versatile Diamond
}

local WoWRemixMoP_Buff = {
    217731, --Timeless Scroll of Mystic Power
    217605, --Timeless Scroll of Intellect
    217607, --Timeless Scroll of the Wild
    217606, --Timeless Scroll of Fortitude
    217608, --Timeless Scroll of Battle Shout
    217730, --Timeless Scroll of Chaos
    217901, --Timeless Drums
  }
  
local WoWRemixMoP_Utility = {
    217928, --Timeless Scroll of Resurrection
    217929, --Timeless Scroll of Cleansing
    217956, --Timeless Scroll of Summoning
  }
  
local WoWRemixMoP_Consumable = {
    217904, --Timerunner's Draught of Power
    217905, --Timerunner's Draught of Health
    211254, --Timerunner's Bandage
  }

--Loop
for _, ItemID in pairs(Noblegarden) do
    categories:AddItemToCategory(ItemID, L("Noblegarden"))
end

for _, ItemID in pairs(Darkmoonfaire) do
    categories:AddItemToCategory(ItemID, L("Darkmoon Faire"))
end

for _, ItemID in pairs(LunarFestival) do
    categories:AddItemToCategory(ItemID, L("Lunar Festival"))
end

--[=[
    MoP Remix
    Color Categories
--]=]

local colorPrefix = "|cff1DDB7F"
local resetColor = "|r"

for _, ItemID in pairs(WoWRemixMoP) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Remix") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_metagems) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Meta Gems") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_cogwheelgems) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Cogwheel Gems") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_tinkergems) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Tinker Gems") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_prismaticgems) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Prismatic Gems") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_Buff) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Enhancements") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_Utility) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Utilities") .. resetColor)
end

for _, ItemID in pairs(WoWRemixMoP_Consumable) do
    categories:AddItemToCategory(ItemID, colorPrefix .. L("Consumables") .. resetColor)
end
