---@class BetterBags: AceAddon
local addon = LibStub("AceAddon-3.0"):GetAddon("BetterBags")

---@class Categories: AceModule
local categories = addon:GetModule("Categories")

---@class Localization: AceModule
local L = addon:GetModule("Localization")

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
    -- Cache
    223908, --Minor Bronze Cache
    223909, --Lesser Bronze Cache
    223910, --Bronze Cache
    223911, --Greater Bronze Cache
    211279, --Cache of Infinite Treasure
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
    --Cloak Threads
    217722, --Thread of Experience
    219264, --Temporal Thread of Experience
    219273, --Perpetual Thread of Experience
    219282, --Infinite Thread of Experience
    210990, --Thread of Versatility
    219263, --Temporal Thread of Versatility
    219272, --Perpetual Thread of Versatility
    219281, --Infinite Thread of Versatility
    210989, --Thread of Mastery
    219262, --Temporal Thread of Mastery
    219271, --Perpetual Thread of Mastery
    219280, --Infinite Thread of Mastery
    210987, --Thread of Leech
    219261, --Temporal Thread of Leech
    219270, --Perpetual Thread of Leech
    219279, --Infinite Thread of Leech
    210986, --Thread of Speed
    219260, --Temporal Thread of Speed
    219269, --Perpetual Thread of Speed
    219278, --Infinite Thread of Speed
    210985, --Thread of Haste
    219259, --Temporal Thread of Haste
    219268, --Perpetual Thread of Haste
    219277, --Infinite Thread of Haste
    210984, --Thread of Critical Strike
    219258, --Temporal Thread of Critical Strike
    219267, --Perpetual Thread of Critical Strike
    219276, --Infinite Thread of Critical Strike
    210983, --Thread of Stamina
    219257, --Temporal Thread of Stamina
    219266, --Perpetual Thread of Stamina
    219275, --Infinite Thread of Stamina
    210982, --Thread of Power
    219256, --Temporal Thread of Power
    219265, --Perpetual Thread of Power
    219274, --Infinite Thread of Power
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
    221816, --Halfhill Farmer's Backpack
    210334, --Chen Stormstout's Keg
    218247, --Chen Stormstout's Bamboo Hat
    218248, --Chen Stormstout's Bamboo Hat
    217836, --Ensemble: Sin'dorei Magister's Regalia
    217837, --Ensemble: Webbed Soulforged Exoskeleton
    217843, --Ensemble: Ela'lothen's Vestment of Rebirth
    217846, --Ensemble: Plate of the Holy Avenger
    217841, --Ensemble: Shado-Pan Watcher Guise
    215219, --Ensemble: Guise of the Shado-Pan
    215287, --Ensemble: Sun Pearl Clothing
    217845, --Ensemble: Silks of the Abyssal Cult
    217842, --Ensemble: Aldrachi Blasphemer's Flames
    217835, --Ensemble: Scales of the Gold Hoarder
    217838, --Ensemble: Fanatical Champion's Trophies
    217832, --Arsenal: Armaments of the Holy Avenger
    217834, --Ensemble: Dreadsquall Hunter's Camouflage
    217833, --Ensemble: Imminence of Krag'wa's Disciple
    217844, --Ensemble: Igneous Onyx Uniform
    215220, --Ensemble: Guise of the Shado-Pan
    217825, --Arsenal: Fanatical Champion's Aggression
    217839, --Ensemble: Jewels of Temptation's Call
    217827, --Arsenal: Shado-Pan Watcher Arsenal
    217824, --Arsenal: Webbed Soulforged Weaponry
    217828, --Arsenal: Aldrachi Blasphemer's Glaives
    217829, --Arsenal: Ela'lothen's Blessings of Rebirth
    217823, --Arsenal: Sin'dorei Magister's Enchantment
    215275, --Ensemble: Kor'kron Shaman Vestments
    217820, --Arsenal: Dreadsquall Hunter's Preference
    217830, --Arsenal: Igneous Onyx Blades
    217819, --Arsenal: Tools of Krag'wa's Disciple
    217821, --Arsenal: Treasure of the Gold Hoarder
    215276, --Ensemble: Kor'kron Shaman Vestments
    215238, --Ensemble: Tian Monastery Clothing
    217831, --Arsenal: Secrets of the Abyssal Cult
    217826, --Arsenal: Instruments of Temptation's Call
    215277, --Ensemble: Kor'kron Shaman Vestments
    215353, --Ensemble: Robes of Quiet Reflection
    215352, --Ensemble: Robes of Quiet Reflection
    215356, --Ensemble: Vestments of Serenity
    215355, --Ensemble: Robes of Quiet Reflection
    215358, --Ensemble: Vestments of Serenity
    215357, --Ensemble: Vestments of Serenity
    215341, --Ensemble: Battleplate of Resounding Rings
    215354, --Ensemble: Robes of Quiet Reflection
    215315 --Ensemble: Spiritguard's Warplate
    --Missing a lot Ensembles
}

--Loop
for _, ItemID in pairs(Noblegarden) do
    categories:AddItemToCategory(ItemID, "Noblegarden")
end

for _, ItemID in pairs(Darkmoonfaire) do
    categories:AddItemToCategory(ItemID, "Darkmoon Faire")
end

for _, ItemID in pairs(LunarFestival) do
    categories:AddItemToCategory(ItemID, "Lunar Festival")
end

for _, ItemID in pairs(WoWRemixMoP) do
    categories:AddItemToCategory(ItemID, "Lunar Festival")
end
