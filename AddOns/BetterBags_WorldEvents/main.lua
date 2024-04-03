---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Categories: AceModule
local categories = addon:GetModule('Categories')

---@class Localization: AceModule
local L = addon:GetModule('Localization')

--Noblegarden
local Noblegarden = {
    116258, --Mystical Spring Bouquet
    216874, --Loot-Filled Basket
    155905, --Cursed Rabbit's Foot
    45072,  --Brightly Colored Egg
    72145,  --Swift Springstrider
    44791,  --Noblegarden Chocolate
    213428, --Loot-Stuffed Basket
    116371, --Magnificently-Painted Egg 
    116370, --Intricately-Painted Egg
    44793,  --Tome of Polymorph: Rabbit 
    44806,  --Brightly Colored Shell Fragment
    116369, --Poorly-Painted Egg
    44794,  --Spring Rabbit's Foot
    44803,  --Spring Circlet
    6835,   --Black Tuxedo Pants
    19028,  --Elegant Dress
    45073,  --Spring Flowers
    45067,  --Egg Basket 
    74283,  --Pink Spring Circlet
    44792,  --Blossoming Branch
    74282,  --Black Spring Circlet
    44800,  --Spring Robes
    44818,  --Noblegarden Egg
    6833,   --White Tuxedo Shirt
    44802,  --Borrowed Egg Basket
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
    216900, --Pink Duck Disguise
}

local Darkmoonfaire = {
    71083,  --Darkmoon Game Token
    93724,  --Darkmoon Game Prize
    71970,  --Darkmoon Prize Ticket
    19296,  --Greater Darkmoon Prize
    19297,  --Lesser Darkmoon Prize
    19298,  --Minor Darkmoon Prize
    19425,  --Mysterious Lockbox
    116052, --Nobleman's Coat
    116134, --Noble's Fancy Boots
    116136, --Noblewoman's Skirt
    116133, --Nobleman's Pantaloons
    116137, --Noblewoman's Finery
    78340,  --Cloak of the Darkmoon Faire
    78341,  --Darkmoon Hammer
    122129, --Fire-Eater's Vial
    138202, --Sparklepony XL
    116115, --Blazing Wings
    97994,  --Darkmoon Seesaw
    126931, --Seafarer's Slidewhistle
    105898, --Moonfang's Paw
    116139, --Haunting Memento
    116067, --Moonfang Shroud
    101571, --Ring of Broken Promises
    122121, --Darkmoon Gazer
    122119, --Everlasting Darkmoon Firework
    122122, --Darkmoon Tonk Controller
    75042,  --Flimsy Yellow Balloon
    122123, --Darkmoon Ring-Flinger
    90899,  --Darkmoon Whistle
    122126, --Attraction Sign
    122120, --Gaze of the Darkmoon
    124669, --Darkmoon Daggermaw
    73766,  --Darkmoon Dancing Bear
    72140,  --Swift Forest Strider
    138429, --Cropped Tabard of the Scarlet Crusade
    80008,  --Darkmoon Rabbit
    73905,  --Darkmoon Zeppelin
    74981,  --Darkmoon Cub
    73953,  --Sea Pony
    116064, --Syd the Squid
    19450,  --A Jubling's Tiny Home
    91040,  --Darkmoon Eye
    73765,  --Darkmoon Turtle
    101570, --Moon Moon
    75042,  --Flimsy Yellow Balloon
    73762,  --Darkmoon Balloon
    73903,  --Darkmoon Tonk
    73764,  --Darkmoon Monkey
    126925, --Blorp's Bubble
    126926, --Translucent Shell
    123862, --Hogs' Studded Collar
    91003,  --Darkmoon Hatchling
    122125, --Race MiniZep Controller
    91031,  --Darkmoon Glowfly
    75041,  --Flimsy Green Balloon
    75040,  --Flimsy Darkmoon Balloon
    19422,  --Darkmoon Faire Fortune
    19443,  --Sayge's Fortune #25
    19266,  --Sayge's Fortune #20
    19255,  --Sayge's Fortune #22
    19424,  --Sayge's Fortune #24
    19453,  --Sayge's Fortune #28
    19254,  --Sayge's Fortune #21
    19242,  --Sayge's Fortune #7
    19247,  --Sayge's Fortune #12
    19237,  --Sayge's Fortune #19
    19253,  --Sayge's Fortune #17
    19423,  --Sayge's Fortune #23
    19452,  --Sayge's Fortune #27
    19249,  --Sayge's Fortune #14
    19250,  --Sayge's Fortune #15
    19252,  --Sayge's Fortune #18
    19454,  --Sayge's Fortune #29
    19229,  --Sayge's Fortune #1
    19451,  --Sayge's Fortune #26
    19240,  --Sayge's Fortune #5
    19239,  --Sayge's Fortune #4
    19241,  --Sayge's Fortune #6
    19245,  --Sayge's Fortune #10
    19251,  --Sayge's Fortune #16
    19238,  --Sayge's Fortune #3
    19244,  --Sayge's Fortune #9
    19246,  --Sayge's Fortune #11
    19248,  --Sayge's Fortune #13
    19243,  --Sayge's Fortune #8
    19256,  --Sayge's Fortune #2
    71976,  --Darkmoon Prize
    71977,  --Darkmoon Craftsman's Kit
    72049,  --Darkmoon Banner
    72048,  --Darkmoon Banner Kit
    71978,  --Darkmoon Bandage
}

--Loop
for _, ItemID in pairs(Noblegarden) do
	categories:AddItemToCategory(ItemID, L:G("Noblegarden"))
end

for _, ItemID in pairs(Darkmoonfaire) do
	categories:AddItemToCategory(ItemID, L:G("Darkmoon Faire"))
end
