---@type string, BBDF
local _, addon = ...

-- Database
-----------------------------------------------------------
addon.db = {
	["|cff16B7FFPrimal Storms|r"] = {
		199211, -- Primeval Essence
		199837, -- Dimmed Primeval Earth
		199836, -- Dimmed Primeval Fire
		199838, -- Dimmed Primeval Storm
		199839, -- Dimmed Primeval Water
	},
	["|cffB5D3E7Storm's Fury|r"] = {
		203478, -- Field Deployable Heat Source
		202039, -- Essence of the Storm
	},
	["|cff88AAFFZskera Vault|r"] = {
		202196, -- Zskera Vault Key
		203701, -- Neltharion Gift Token
		203705, -- Empty Obsidian Vial
		203704, -- Stone Dissolver
		203715, -- Oozing Gold
		203718, -- Vial of Flames
		203720, -- Restorative Water
		204439, -- Research Chest Key
	},
	["|cffFFAB00Primordial Stones|r"] = {
		203703, -- Prismatic Fragment
		203702, -- Experimental Melder
		204215, -- Dormant Primordial Fragment
		204030, -- Wind Sculpted Stone
		204020, -- Wild Spirit Stone
		204015, -- Swirling Mojo Stone
		204000, -- Storm Infused Stone
		204014, -- Sparkling Mana Stone
		204007, -- Shining Obsidian Stone
		204004, -- Searing Smokey Stone
		204003, -- Raging Magma Stone
		204029, -- Prophetic Twilight Stone
		204022, -- Pestilent Plague Stone
		204025, -- Obscure Pastel Stone
		204021, -- Necromantic Death Stone
		204006, -- Indomitable Earth Stone
		204018, -- Humming Arcane Stone
		204019, -- Harmonic Music Stone
		204009, -- Gleaming Iron Stone
		204011, -- Freezing Ice Stone
		204002, -- Flame Licked Stone
		204013, -- Exuding Steam Stone
		204005, -- Entropic Fel Stone
		204001, -- Echoing Thunder Stone
		204027, -- Desirous Blood Stone
		204010, -- Deluging Water Stone
		204012, -- Cold Frost Stone
	},
	["|cff88AAFFArtisan Curios|r"] = {
		203398, -- Dampening Powder
		203399, -- Damaged Trident
		203400, -- Lackluster Spices
		203401, -- Dull Crystal
		203402, -- Broken Gnomish Voicebox
		203404, -- Crystal Fork
		203403, -- Hastily Scrawled Rune
		203405, -- Pristine Pelt
		203406, -- Torn Morqut Kite
		203407, -- Draconic Suppression Powder
		203408, -- Ancient Ceremonial Trident
		203409, -- Elusive Croaking Crab
		203410, -- Glowing Crystal Bookmark
		203411, -- Gnomish Voicebox
		203412, -- Arcane Dispelling Rune
		203413, -- Crystal Tunning Fork
		203414, -- Reinforced Pristine Leather
		203415, -- Traditional Morqut Kite
		203416, -- Dormant Lifebloom Seeds
		203417, -- Razor Sharp Animal Bone
		203418, -- Amplified Quaking Stone
	},
	["Diamanthia Journal"] = {
		202335, -- Journal Entry: Relics
		204200, -- Journal Entry: Experiments
		202337, -- Journal Entry: Silence
		202329, -- Journal Entry: Experiments
		204221, -- Journal Entry: Relics
		204223, -- Journal Entry: The Creches
		202336, -- Journal Entry: The Creches
		204246, -- Journal Entry: Silence
	},
	["|cff0070ddProfession Knowledge|r"] = {
		191784, -- Dragon Shard of Knowledge
		-- Alchemy
		--------------------------------------------------------------------
		198608, -- Alchemy Notes
		201281, -- Ancient Alchemist's ResearchTalent
		198963, -- Decaying Phlegm
		194697, -- Draconic Treatise on Alchemy
		200974, -- Dusty Alchemist's Research
		198964, -- Elementious Splinter
		193891, -- Experimental Substance
		201706, -- Notebook of Crafting Knowledge
		201270, -- Rare Alchemist's Research
		193897, -- Reawakened Catalyst
		198710, -- Canteen of Suspicious Water
		198697, -- Contraband Concoction
		198599, -- Experimental Decay Sample
		198712, -- Firewater Powder Sample
		198663, -- Frostforged Potion
		201003, -- Furry Gloop
		198685, -- Well Insulated Mug
		203471, -- Tasty Candy (10.0.5)
		204226, -- Blazehoof Ashes (10.0.7)
		205212, -- Marrow-Ripened Slime (10.1)
		205211, -- Nutrient Diluted Protofluid (10.1)
		205213, -- Suspicious Mold (10.1)
		205429, -- Bartered Alchemy Notes (10.1)
		205353, -- Niffen Notebook of Alchemy Knowledge (10.1)
		205440, -- Bartered Alchemy Journal (10.1)
		210184, -- Half-Filled Dreamless Sleep Potion (10.2)
		210185, -- Splash Potion of Narcolepsy (10.2)
		210190, -- Blazeroot (10.2)
		-- Blacksmithing
		--------------------------------------------------------------------
		192130, -- Sundered Flame Weapon Mold
		201279, -- Ancient Blacksmith's Diagrams
		198606, -- Blacksmith's Writ
		198454, -- Draconic Treatise on Blacksmithing
		192132, -- Draconium Blade Sharpener
		200972, -- Dusty Blacksmith's Diagrams
		198966, -- Molten Globule
		201708, -- Notebook of Crafting Knowledge
		198965, -- Primeval Earth Fragment
		201268, -- Rare Blacksmith's Diagrams
		192131, -- Valdrakken Weapon Chain
		201007, -- Ancient Monument
		201004, -- Ancient Spear Shards
		201005, -- Curious Ingots
		201006, -- Draconic Flux
		201009, -- Falconer Gauntlet Drawings
		201008, -- Molten Ingot
		201010, -- Qalashi Weapon Diagram
		201011, -- Spelltouched Tongs
		204230, -- Dense Seaforged Javelin (10.0.7)
		205986, -- Well-Worn Kiln (10.1)
		205987, -- Brimstone Rescue Ring (10.1)
		205988, -- Zaqali Elder Spear (10.1)
		205439, -- Bartered Blacksmithing Journal (10.1)
		205352, -- Niffen Notebook of Blacksmithing Knowledge (10.1)
		205428, -- Bartered Blacksmithing Notes (10.1)
		210464, -- Amirdrassil Defender's Shield (10.2)
		210465, -- Deathstalker Chassis (10.2)
		210466, -- Flamesworn Render (10.2)
		-- Enchanting
		--------------------------------------------------------------------
		201283, -- Ancient Enchanter's Research
		194702, -- Draconic Treatise on Enchanting
		200976, -- Dusty Enchanter's Research
		198610, -- Enchanter's Script
		201709, -- Notebook of Crafting Knowledge
		193901, -- Primal Dust
		198968, -- Primalist Charm
		198967, -- Primordial Aether
		193900, -- Prismatic Focusing Shard
		201272, -- Rare Enchanter's Research
		201012, -- Enchanted Debris
		201013, -- Faintly Enchanted Remains
		204224, -- Speck of Arcane Awareness (10.0.7)
		205427, -- Bartered Enchanting Notes (10.1)
		205351, -- Niffen Notebook of Enchanting Knowledge (10.1)
		205438, -- Bartered Enchanting Journal (10.1)
		-- Disenchant these
		200939, -- Chromatic Pocketwatch
		200947, -- Carving of Awakening
		200940, -- Everflowing Inkwell
		200943, -- Whispering Band
		200942, -- Vibrant Emulsion
		200946, -- Thunderous Blade
		200945, -- Valiant Hammer
		204990, -- Lava-Drenched Shadow Crystal (10.1)
		204999, -- Shimmering Aqueous Orb (10.1)
		205001, -- Resonating Arcane Crystal (10.1)
		210228, -- Pure Dream Water (10.2)
		210231, -- Everburning Core (10.2)
		210234, -- Essence of Dreams (10.2)
		-- Engineering
		--------------------------------------------------------------------
		201284, -- Ancient Engineer's Scribblings
		198510, -- Draconic Treatise on Engineering
		200977, -- Dusty Engineer's Scribblings
		198611, -- Engineering Details
		193902, -- Eroded Titan Gizmo
		198970, -- Infinitely Attachable Pair o' Docks
		198969, -- Keeper's Mark
		201710, -- Notebook of Crafting Knowledge
		201273, -- Rare Engineer's Scribblings
		193903, -- Watcher Power Core
		201014, -- Boomthyr Rocket
		198789, -- Intact Coil Capacitor
		204227, -- Everflowing Antifreeze (10.0.7)
		204471, -- Defective Survival Pack (10.1)
		204480, -- Inconspicuous Data Miner (10.1)
		204475, -- Busted Wyrmhole Generator (10.1)
		204855, -- Overclocked Determination Core (10.1)
		204850, -- Handful of Khaz'gorite Bolts (10.1)
		204853, -- Discarded Dracothyst Drill (10.1)
		204469, -- Misplaced Aberrus Outflow Blueprints (10.1)
		204470, -- Haphazardly Discarded Bomb (10.1)
		205349, -- Niffen Notebook of Engineering Knowledge (10.1)
		205425, -- Bartered Engineering Notes (10.1)
		205436, -- Bartered Engineering Journal (10.1)
		210193, -- Experimental Dreamcatcher (10.2)
		210194, -- Insomniotron (10.2)
		210197, -- Unhatched Battery (10.2)
		210198, -- Depleted Battery (10.2)
		-- Herbalism
		--------------------------------------------------------------------
		201287, -- Ancient Herbalist's Notes
		194704, -- Draconic Treatise on Herbalism
		200677, -- Dreambloom Petal
		194054, -- Dredged Seedling
		194041, -- Driftbloom Sprout
		200980, -- Dusty Herbalist's Notes
		199115, -- Herbalism Field Notes
		202014, -- Infused Pollen
		194081, -- Mutated Root
		201705, -- Notebook of Crafting Knowledge
		201717, -- Notebook of Crafting Knowledge
		194080, -- Peculiar Bud
		194055, -- Primordial Soil
		201276, -- Rare Herbalist's Notes
		194061, -- Suffocating Spores
		200678, -- Dreambloom
		204228, -- Undigested Hochenblume Petal (10.0.7)
		205358, -- Niffen Notebook of Herbalism Knowledge (10.1)
		205434, -- Bartered Herbalism Notes (10.1)
		205445, -- Bartered Herbalism Journal (10.1)
		-- Inscription
		--------------------------------------------------------------------
		201280, -- Ancient Scribe's Runic Drawings
		198971, -- Curious Djaradin Rune
		198972, -- Draconic Glamour
		194699, -- Draconic Treatise on Inscription
		200973, -- Dusty Scribe's Runic Drawings
		193905, -- Iskaaran Trading Ledger
		201711, -- Notebook of Crafting Knowledge
		193904, -- Phoenix Feather Quill
		201269, -- Rare Scribe's Runic Drawings
		198607, -- Scribe's Glyphs
		201015, -- Counterfeit Darkmoon Deck
		198659, -- Forgetful Apprentice's Tome
		198686, -- Frosted Parchment
		198669, -- How to Train Your Whelpling
		198704, -- Pulsing Earth Rune
		198703, -- Sign Language Reference Sheet
		204229, -- Glimmering Rune of Arcantrix (10.0.7)
		206035, -- Ancient Research (10.1)
		206034, -- Hissing Rune Draft (10.1)
		206031, -- Intricate Zaqali Runes (10.1)
		205430, -- Bartered Inscription Notes (10.1)
		205354, -- Niffen Notebook of Inscription Knowledge (10.1)
		205441, -- Bartered Inscription Journal (10.1)
		210458, -- Winnie's Notes on Flora and Fauna (10.2)
		210459, -- Grove Keeper's Pillar (10.2)
		210460, -- Primalist Shadowbinding Rune (10.2)
		-- Jewelcrafting
		--------------------------------------------------------------------
		193909, -- Ancient Gem Fragments
		201285, -- Ancient Jeweler's Illustrations
		193907, -- Chipped Tyrstone
		194703, -- Draconic Treatise on Jewelcrafting
		200978, -- Dusty Jeweler's Illustrations
		198974, -- Elegantly Engraved Embellishment
		198612, -- Jeweler's Cuts
		201712, -- Notebook of Crafting Knowledge
		201274, -- Rare Jeweler's Illustrations
		198682, -- Alexstraszite Cluster
		198687, -- Closely Guarded Shiny
		198664, -- Crystalline Overgrowth
		198660, -- Fragmented Key
		201016, -- Harmonic Crystal Harmonizer
		201017, -- Igneous Gem
		198670, -- Lofty Malygite
		198656, -- Painter's Pretty Jewel
		204222, -- Conductive Ametrine Shard (10.0.7)
		205214, -- Snubbed Snail Shells (10.1)
		205219, -- Broken Barter Boulder (10.1)
		205216, -- Gently Jostled Jewels (10.1)
		205348, -- Niffen Notebook of Jewelcrafting Knowledge (10.1)
		205424, -- Bartered Jewelcrafting Notes (10.1)
		205435, -- Bartered Jewelcrafting Journal (10.1)
		210200, -- Petrified Hope (10.2)
		210201, -- Handful of Pebbles (10.2)
		210202, -- Coalesced Dreamstone (10.2)
		-- Leatherworking
		--------------------------------------------------------------------
		201286, -- Ancient Leatherworker's Diagrams
		194700, -- Draconic Treatise on Leatherworking
		200979, -- Dusty Leatherworker's Diagrams
		198976, -- Exceedingly Soft Skin
		198613, -- Leatherworking Designs
		193910, -- Molted Dragon Scales
		201713, -- Notebook of Crafting Knowledge
		198975, -- Ossified Hide
		193913, -- Preserved Animal Parts
		201275, -- Rare Leatherworker's Diagrams
		198658, -- Decay-Infused Tanning Oil
		198690, -- Decayed Scales
		198711, -- Poacher's Pack
		198667, -- Spare Djaradin Tools
		198683, -- Treated Hides
		201018, -- Well-Danced Drum
		198696, -- Wind-Blessed Hide
		204232, -- Slyvern Alpha Claw (10.0.7)
		204986, -- Flame-Infused Scale Oil (10.1)
		204987, -- Lava-Forged Leatherworker's "Knife" (10.1)
		204988, -- Sulfur-Soaked Skins (10.1)
		205350, -- Niffen Notebook of Leatherworking Knowledge (10.1)
		205426, -- Bartered Leatherworking Notes (10.1)
		205437, -- Bartered Leatherworking Journal (10.1)
		210208, -- Tuft of Dreamsaber Fur (10.2)
		210211, -- Molted Faerie Dragon Scales (10.2)
		210215, -- Dreamtalon Claw (10.2)
		-- Mining
		--------------------------------------------------------------------
		201288, -- Ancient Miner's Notes
		194708, -- Draconic Treatise on Mining
		200981, -- Dusty Miner's Notes
		202011, -- Elementally-Charged Stone
		194063, -- Glowing Fragment
		194039, -- Heated Ore Sample
		194064, -- Intricate Geode
		199122, -- Mining Field Notes
		201700, -- Notebook of Crafting Knowledge
		194078, -- Perfect Draconium Scale
		194079, -- Pure Serevite Nugget
		201277, -- Rare Miner's Notes
		194062, -- Unyielding Stone Chunk
		201716, -- Notebook of Crafting Knowledge
		204632, -- Tectonic Rock Fragment (10.0.7)
		205356, -- Niffen Notebook of Mining Knowledge (10.1)
		205443, -- Bartered Mining Journal (10.1)
		205432, -- Bartered Mining Notes (10.1)
		-- Skinning
		--------------------------------------------------------------------
		201289, -- Ancient Skinner's Notes
		198837, -- Curious Hide Scraps
		201023, -- Draconic Treatise on Skinning
		200982, -- Dusty Skinner's Notes
		194076, -- Exotic Resilient Leather
		194067, -- Festering Carcass
		194066, -- Frigid Frostfur Pelt
		201714, -- Notebook of Crafting Knowledge
		201718, -- Notebook of Crafting Knowledge
		194077, -- Pristine Adamant Scales
		194068, -- Progenitor Scales
		201278, -- Rare Skinner's Notes
		202016, -- Saturated Bone
		199128, -- Skinning Field Notes
		194040, -- Slateskin Hide
		198841, -- Large Sample of Curious Hide
		204231, -- Kingly Sheepskin Pelt (10.0.7)
		205433, -- Bartered Skinning Notes (10.1)
		205451, -- Flawless Crystal Scale (10.1)
		205357, -- Niffen Notebook of Skinning Knowledge (10.1)
		205444, -- Bartered Skinning Journal (10.1)
		-- Tailoring
		--------------------------------------------------------------------
		201282, -- Ancient Tailor's Diagrams
		194698, -- Draconic Treatise on Tailoring
		200975, -- Dusty Tailor's Diagrams
		201715, -- Notebook of Crafting Knowledge
		198977, -- Ohn'arhan Weave
		193899, -- Primalweave Spindle
		201271, -- Rare Tailor's Diagrams
		198978, -- Stupidly Effective Stitchery
		198609, -- Tailoring Examples
		193898, -- Umbral Bone Needle
		201019, -- Ancient Dragonweave Bolt
		198680, -- Decaying Brackenhide Blanket
		198662, -- Intriguing Bolt of Blue Cloth
		198702, -- Itinerant Singed Fabric
		198684, -- Miniature Bronze Dragonflight Banner
		198699, -- Mysterious Banner
		198692, -- Noteworthy Scrap of Carpet
		201020, -- Silky Surprise
		204225, -- Perfect Windfeather (10.0.7)
		206019, -- Abandoned Reserve Chute (10.1)
		206030, -- Exquisitely Embroidered Banner (10.1)
		206025, -- Used Medical Wrap Kit (10.1)
		205431, -- Bartered Tailoring Notes (10.1)
		205355, -- Niffen Notebook of Tailoring Knowledge (10.1)
		205442, -- Bartered Tailoring Journal (10.1)
		210461, -- Exceedingly Soft Wildercloth (10.2)
		210462, -- Plush Pillow (10.2)
		210463, -- Snuggle Buddy (10.2)
	},
	["|cff56BBFFDrakewatcher Manuscript|r"] = {
		196961, -- Cliffside Wylderdrake: Armor
		196986, -- Cliffside Wylderdrake: Black Hair
		196991, -- Cliffside Wylderdrake: Black Horns
		197013, -- Cliffside Wylderdrake: Black Scales
		196987, -- Cliffside Wylderdrake: Blonde Hair
		197012, -- Cliffside Wylderdrake: Blue Scales
		197019, -- Cliffside Wylderdrake: Blunt Spiked Tail
		196996, -- Cliffside Wylderdrake: Branched Horns
		196965, -- Cliffside Wylderdrake: Bronze and Teal Armor
		197000, -- Cliffside Wylderdrake: Coiled Horns
		196981, -- Cliffside Wylderdrake: Conical Head
		196979, -- Cliffside Wylderdrake: Curled Head Horns
		197015, -- Cliffside Wylderdrake: Dark Skin Variation
		196973, -- Cliffside Wylderdrake: Dual Horned Chin
		196982, -- Cliffside Wylderdrake: Ears
		196969, -- Cliffside Wylderdrake: Finned Back
		197001, -- Cliffside Wylderdrake: Finned Cheek
		196984, -- Cliffside Wylderdrake: Finned Jaw
		197022, -- Cliffside Wylderdrake: Finned Neck
		197018, -- Cliffside Wylderdrake: Finned Tail
		197002, -- Cliffside Wylderdrake: Flared Cheek
		196974, -- Cliffside Wylderdrake: Four Horned Chin
		196964, -- Cliffside Wylderdrake: Gold and Black Armor
		196966, -- Cliffside Wylderdrake: Gold and Orange Armor
		196967, -- Cliffside Wylderdrake: Gold and White Armor
		197011, -- Cliffside Wylderdrake: Green Scales
		196975, -- Cliffside Wylderdrake: Head Fin
		196976, -- Cliffside Wylderdrake: Head Mane
		196992, -- Cliffside Wylderdrake: Heavy Horns
		196998, -- Cliffside Wylderdrake: Hook Horns
		196985, -- Cliffside Wylderdrake: Horned Jaw
		197005, -- Cliffside Wylderdrake: Horned Nose
		197017, -- Cliffside Wylderdrake: Large Tail Spikes
		196983, -- Cliffside Wylderdrake: Maned Jaw
		197023, -- Cliffside Wylderdrake: Maned Neck
		197016, -- Cliffside Wylderdrake: Maned Tail
		197008, -- Cliffside Wylderdrake: Narrow Stripes Pattern
		196972, -- Cliffside Wylderdrake: Plated Brow
		197006, -- Cliffside Wylderdrake: Plated Nose
		196988, -- Cliffside Wylderdrake: Red Hair
		197010, -- Cliffside Wylderdrake: Red Scales
		197009, -- Cliffside Wylderdrake: Scaled Pattern
		196994, -- Cliffside Wylderdrake: Short Horns
		196963, -- Cliffside Wylderdrake: Silver and Blue Armor
		196962, -- Cliffside Wylderdrake: Silver and Purple Armor
		196993, -- Cliffside Wylderdrake: Sleek Horns
		196978, -- Cliffside Wylderdrake: Small Head Spikes
		197020, -- Cliffside Wylderdrake: Spear Tail
		196970, -- Cliffside Wylderdrake: Spiked Back
		196971, -- Cliffside Wylderdrake: Spiked Brow
		197003, -- Cliffside Wylderdrake: Spiked Cheek
		197021, -- Cliffside Wylderdrake: Spiked Club Tail
		196995, -- Cliffside Wylderdrake: Spiked Horns
		197004, -- Cliffside Wylderdrake: Spiked Legs
		196977, -- Cliffside Wylderdrake: Split Head Horns
		196997, -- Cliffside Wylderdrake: Split Horns
		196968, -- Cliffside Wylderdrake: Steel and Yellow Armor
		196999, -- Cliffside Wylderdrake: Swept Horns
		196980, -- Cliffside Wylderdrake: Triple Head Horns
		196989, -- Cliffside Wylderdrake: White Hair
		197014, -- Cliffside Wylderdrake: White Scales
		197007, -- Cliffside Wylderdrake: Wide Stripes Pattern
		197099, -- Highland Drake: Armor
		197117, -- Highland Drake: Black Hair
		197142, -- Highland Drake: Black Scales
		197153, -- Highland Drake: Bladed Tail
		197156, -- Highland Drake: Bronze and Green Armor
		197145, -- Highland Drake: Bronze Scales
		197118, -- Highland Drake: Brown Hair
		197101, -- Highland Drake: Bushy Brow
		197149, -- Highland Drake: Club Tail
		197125, -- Highland Drake: Coiled Horns
		197100, -- Highland Drake: Crested Brow
		197128, -- Highland Drake: Curled Back Horns
		197116, -- Highland Drake: Ears
		201792, -- Highland Drake: Embodiment of the Crimson Gladiator
		197098, -- Highland Drake: Finned Back
		197106, -- Highland Drake: Finned Head
		197155, -- Highland Drake: Finned Neck
		197090, -- Highland Drake: Gold and Black Armor
		197094, -- Highland Drake: Gold and Red Armor
		197095, -- Highland Drake: Gold and White Armor
		197127, -- Highland Drake: Grand Thorn Horns
		197143, -- Highland Drake: Green Scales
		197131, -- Highland Drake: Hairy Cheek
		197122, -- Highland Drake: Heavy Horns
		197147, -- Highland Drake: Heavy Scales
		197126, -- Highland Drake: Hooked Horns
		197152, -- Highland Drake: Hooked Tail
		197102, -- Highland Drake: Horned Chin
		197139, -- Highland Drake: Large Spotted Pattern
		197103, -- Highland Drake: Maned Chin
		197111, -- Highland Drake: Maned Head
		197114, -- Highland Drake: Multi-Horned Head
		197120, -- Highland Drake: Ornate Helm
		197110, -- Highland Drake: Plated Head
		197144, -- Highland Drake: Red Scales
		197141, -- Highland Drake: Scaled Pattern
		197091, -- Highland Drake: Silver and Blue Armor
		197093, -- Highland Drake: Silver and Purple Armor
		197112, -- Highland Drake: Single Horned Head
		197129, -- Highland Drake: Sleek Horns
		197140, -- Highland Drake: Small Spotted Pattern
		197132, -- Highland Drake: Spiked Cheek
		197150, -- Highland Drake: Spiked Club Tail
		197109, -- Highland Drake: Spiked Head
		197134, -- Highland Drake: Spiked Legs
		197151, -- Highland Drake: Spiked Tail
		197097, -- Highland Drake: Spined Back
		197133, -- Highland Drake: Spined Cheek
		197105, -- Highland Drake: Spined Chin
		197108, -- Highland Drake: Spined Head
		197154, -- Highland Drake: Spined Neck
		197137, -- Highland Drake: Spined Nose
		197130, -- Highland Drake: Stag Horns
		197096, -- Highland Drake: Steel and Yellow Armor
		197138, -- Highland Drake: Striped Pattern
		197124, -- Highland Drake: Swept Horns
		197113, -- Highland Drake: Swept Spiked Head
		197121, -- Highland Drake: Tan Horns
		197104, -- Highland Drake: Tapered Chin
		197136, -- Highland Drake: Taperered Nose
		197123, -- Highland Drake: Thorn Horns
		197115, -- Highland Drake: Thorned Jaw
		197135, -- Highland Drake: Toothy Mouth
		197107, -- Highland Drake: Triple Finned Head
		197148, -- Highland Drake: Vertical Finned Tail
		197146, -- Highland Drake: White Scales
		197357, -- Renewed Proto-Drake: Armor
		197401, -- Renewed Proto-Drake: Beaked Snout
		197348, -- Renewed Proto-Drake: Black and Red Armor
		197392, -- Renewed Proto-Drake: Black Scales
		197368, -- Renewed Proto-Drake: Blue Hair
		197390, -- Renewed Proto-Drake: Blue Scales
		197377, -- Renewed Proto-Drake: Bovine Horns
		197353, -- Renewed Proto-Drake: Bronze and Pink Armor
		197391, -- Renewed Proto-Drake: Bronze Scales
		197369, -- Renewed Proto-Drake: Brown Hair
		197403, -- Renewed Proto-Drake: Club Tail
		197375, -- Renewed Proto-Drake: Curled Horns
		197380, -- Renewed Proto-Drake: Curved Horns
		197358, -- Renewed Proto-Drake: Curved Spiked Brow
		197366, -- Renewed Proto-Drake: Dual Horned Crest
		197376, -- Renewed Proto-Drake: Ears
		201790, -- Renewed Proto-Drake: Embodiment of the Storm-Eater
		197365, -- Renewed Proto-Drake: Finned Crest
		197388, -- Renewed Proto-Drake: Finned Jaw
		197404, -- Renewed Proto-Drake: Finned Tail
		197408, -- Renewed Proto-Drake: Finned Throat
		197346, -- Renewed Proto-Drake: Gold and Black Armor
		197351, -- Renewed Proto-Drake: Gold and Red Armor
		197349, -- Renewed Proto-Drake: Gold and White Armor
		197381, -- Renewed Proto-Drake: Gradient Horns
		197367, -- Renewed Proto-Drake: Gray Hair
		197371, -- Renewed Proto-Drake: Green Hair
		192523, -- Renewed Proto-Drake: Green Scales
		197389, -- Renewed Proto-Drake: Green Scales
		197356, -- Renewed Proto-Drake: Hairy Back
		197359, -- Renewed Proto-Drake: Hairy Brow
		197395, -- Renewed Proto-Drake: Harrier Pattern
		197383, -- Renewed Proto-Drake: Heavy Horns
		197397, -- Renewed Proto-Drake: Heavy Scales
		197354, -- Renewed Proto-Drake: Horned Back
		197385, -- Renewed Proto-Drake: Horned Jaw
		197379, -- Renewed Proto-Drake: Impaler Horns
		197363, -- Renewed Proto-Drake: Maned Crest
		197405, -- Renewed Proto-Drake: Maned Tail
		197394, -- Renewed Proto-Drake: Predator Pattern
		197372, -- Renewed Proto-Drake: Purple Hair
		197399, -- Renewed Proto-Drake: Razor Snout
		197370, -- Renewed Proto-Drake: Red Hair
		197400, -- Renewed Proto-Drake: Shark Snout
		197364, -- Renewed Proto-Drake: Short Spiked Crest
		197347, -- Renewed Proto-Drake: Silver and Blue Armor
		197350, -- Renewed Proto-Drake: Silver and Purple Armor
		197396, -- Renewed Proto-Drake: Skyterror Pattern
		197398, -- Renewed Proto-Drake: Snub Snout
		197402, -- Renewed Proto-Drake: Spiked Club Tail
		197361, -- Renewed Proto-Drake: Spiked Crest
		197386, -- Renewed Proto-Drake: Spiked Jaw
		197407, -- Renewed Proto-Drake: Spiked Throat
		197360, -- Renewed Proto-Drake: Spined Brow
		197362, -- Renewed Proto-Drake: Spined Crest
		197406, -- Renewed Proto-Drake: Spined Tail
		197352, -- Renewed Proto-Drake: Steel and Yellow Armor
		197378, -- Renewed Proto-Drake: Subtle Horns
		197374, -- Renewed Proto-Drake: Swept Horns
		197355, -- Renewed Proto-Drake: Thick Spined Jaw
		197384, -- Renewed Proto-Drake: Thick Spined Jaw
		197387, -- Renewed Proto-Drake: Thin Spined Jaw
		197382, -- Renewed Proto-Drake: White Horns
		197393, -- Renewed Proto-Drake: White Scales
		202278, -- Renewed Proto-Drake: Antlers (10.0.7)
		202279, -- Renewed Proto-Drake: Malevolent Horns (10.0.7)
		202273, -- Renewed Proto-Drake: Stubby Snout (10.0.7)
		202277, -- Renewed Proto-Drake: Bruiser Horns (10.0.7)
		202280, -- Renewed Proto-Drake: Pronged Tail (10.0.7)
		202275, -- Renewed Proto-Drake: Plated Jaw (10.0.7)
		202274, -- Renewed Proto-Drake: Plated Brow (10.0.7)
		197588, -- Windborne Velocidrake: Armor
		197620, -- Windborne Velocidrake: Beaked Snout
		197597, -- Windborne Velocidrake: Black Fur
		197611, -- Windborne Velocidrake: Black Scales
		197612, -- Windborne Velocidrake: Blue Scales
		197577, -- Windborne Velocidrake: Bronze and Green Armor
		197613, -- Windborne Velocidrake: Bronze Scales
		197624, -- Windborne Velocidrake: Club Tail
		197602, -- Windborne Velocidrake: Cluster Horns
		197605, -- Windborne Velocidrake: Curled Horns
		197603, -- Windborne Velocidrake: Curved Horns
		197583, -- Windborne Velocidrake: Exposed Finned Back
		197626, -- Windborne Velocidrake: Exposed Finned Neck
		197621, -- Windborne Velocidrake: Exposed Finned Tail
		197587, -- Windborne Velocidrake: Feathered Back
		197630, -- Windborne Velocidrake: Feathered Neck
		197593, -- Windborne Velocidrake: Feathery Head
		197625, -- Windborne Velocidrake: Feathery Tail
		197584, -- Windborne Velocidrake: Finned Back
		197595, -- Windborne Velocidrake: Finned Ears
		197627, -- Windborne Velocidrake: Finned Neck
		197622, -- Windborne Velocidrake: Finned Tail
		197580, -- Windborne Velocidrake: Gold and Red Armor
		197598, -- Windborne Velocidrake: Gray Hair
		197608, -- Windborne Velocidrake: Gray Horns
		197591, -- Windborne Velocidrake: Hairy Head
		197617, -- Windborne Velocidrake: Heavy Scales
		197619, -- Windborne Velocidrake: Hooked Snout
		197596, -- Windborne Velocidrake: Horned Jaw
		197589, -- Windborne Velocidrake: Large Head Fin
		197618, -- Windborne Velocidrake: Long Snout
		197585, -- Windborne Velocidrake: Maned Back
		197604, -- Windborne Velocidrake: Ox Horns
		197628, -- Windborne Velocidrake: Plated Neck
		197635, -- Windborne Velocidrake: Reaver Pattern
		197599, -- Windborne Velocidrake: Red Hair
		197614, -- Windborne Velocidrake: Red Scales
		197636, -- Windborne Velocidrake: Shrieker Pattern
		197578, -- Windborne Velocidrake: Silver and Blue Armor
		197581, -- Windborne Velocidrake: Silver and Purple Armor
		197594, -- Windborne Velocidrake: Small Ears
		197590, -- Windborne Velocidrake: Small Head Fin
		197586, -- Windborne Velocidrake: Spiked Back
		197629, -- Windborne Velocidrake: Spiked Neck
		197623, -- Windborne Velocidrake: Spiked Tail
		197592, -- Windborne Velocidrake: Spined Head
		197607, -- Windborne Velocidrake: Split Horns
		197579, -- Windborne Velocidrake: Steel and Orange Armor
		197606, -- Windborne Velocidrake: Swept Horns
		197615, -- Windborne Velocidrake: Teal Scales
		197601, -- Windborne Velocidrake: Wavy Horns
		197582, -- Windborne Velocidrake: White and Pink Armor
		197609, -- Windborne Velocidrake: White Horns
		197616, -- Windborne Velocidrake: White Scales
		197634, -- Windborne Velocidrake: Windswept Pattern
		197610, -- Windborne Velocidrake: Yellow Horns
		--------------------------------------------------------
		-- 10.1
		--------------------------------------------------------
		205876, -- Highland Drake: Embodiment of the Hellforged
		205865, -- Winding Slitherdrake: Embodiment of the Obsidian Gladiator
		203308, -- Winding Slitherdrake: Hairy Brow
		203310, -- Winding Slitherdrake: Grand Chin Thorn
		203316, -- Winding Slitherdrake: Large Finned Crest
		203309, -- Winding Slitherdrake: Long Chin Horn
		203327, -- Winding Slitherdrake: Tan Horns
		203331, -- Winding Slitherdrake: Cluster Horns
		203354, -- Winding Slitherdrake: White Scales
		203350, -- Winding Slitherdrake: Blue Scales
		203338, -- Winding Slitherdrake: Antler Horns
		203351, -- Winding Slitherdrake: Bronze Scales
		203353, -- Winding Slitherdrake: Red Scales
		203312, -- Winding Slitherdrake: Cluster Chin Horn
		203346, -- Winding Slitherdrake: Curled Nose
		205341, -- Winding Slitherdrake: Heavy Scales
		203352, -- Winding Slitherdrake: Green Scales
		203358, -- Winding Slitherdrake: Small Finned Tail
		203339, -- Winding Slitherdrake: Impaler Horns
		203300, -- Winding Slitherdrake: Blue and Silver Armor
		203355, -- Winding Slitherdrake: Yellow Scales
		203299, -- Winding Slitherdrake: Green and Bronze Armor
		203323, -- Winding Slitherdrake: Brown Hair
		203318, -- Winding Slitherdrake: Hairy Crest
		203328, -- Winding Slitherdrake: White Horns
		203345, -- Winding Slitherdrake: Split Jaw Horns
		203360, -- Winding Slitherdrake: Large Finned Tail
		203363, -- Winding Slitherdrake: Large Finned Throat
		203321, -- Winding Slitherdrake: Curled Cheek Horn
		203341, -- Winding Slitherdrake: Long Jaw Horns
		203303, -- Winding Slitherdrake: Red and Gold Armor
		203320, -- Winding Slitherdrake: Ears
		203347, -- Winding Slitherdrake: Large Spiked Nose
		203329, -- Winding Slitherdrake: Heavy Horns
		203307, -- Winding Slitherdrake: Plated Brow
		203313, -- Winding Slitherdrake: Spiked Chin
		203317, -- Winding Slitherdrake: Small Finned Crest
		203359, -- Winding Slitherdrake: Shark Finned Tail
		203362, -- Winding Slitherdrake: Hairy Tail
		203304, -- Winding Slitherdrake: Yellow and Silver Armor
		203365, -- Winding Slitherdrake: Hairy Throat
		203334, -- Winding Slitherdrake: Curled Horns
		203335, -- Winding Slitherdrake: Curved Horns
		203361, -- Winding Slitherdrake: Finned Tip Tail
		203332, -- Winding Slitherdrake: Spiked Horns
		203343, -- Winding Slitherdrake: Hairy Jaw
		203322, -- Winding Slitherdrake: Blonde Hair
		203330, -- Winding Slitherdrake: Swept Horns
		203306, -- Winding Slitherdrake: Horned Brow
		203319, -- Winding Slitherdrake: Finned Cheek
		203325, -- Winding Slitherdrake: Red Hair
		203344, -- Winding Slitherdrake: Single Jaw Horn
		203333, -- Winding Slitherdrake: Short Horns
		203340, -- Winding Slitherdrake: Cluster Jaw Horns
		203348, -- Winding Slitherdrake: Pointed Nose
		203324, -- Winding Slitherdrake: White Hair
		203349, -- Winding Slitherdrake: Curved Nose Horn
		203364, -- Winding Slitherdrake: Small Finned Throat
		203314, -- Winding Slitherdrake: Curved Chin Horn
		203342, -- Winding Slitherdrake: Triple Jaw Horns
		203337, -- Winding Slitherdrake: Thorn Horns
		203357, -- Winding Slitherdrake: Spiked Tail
		203315, -- Winding Slitherdrake: Small Spiked Crest
		203336, -- Winding Slitherdrake: Paired Horns
		203311, -- Winding Slitherdrake: Hairy Chin
		-- 10.1.5
		208102, -- Cliffside Wylderdrake: Infinite Scales
		208103, -- Highland Drake: Infinite Scales
		208104, -- Renewed Proto-Drake: Infinite Scales
		208105, -- Windborne Velocidrake: Infinite Scales
		208106, -- Winding Slitherdrake: Infinite Scales
		-- 10.1.7
		208859, -- Cliffside Wylderdrake: Day of the Dead Armor
		208858, -- Highland Drake: Pirates' Day Armor
		208742, -- Renewed Proto-Drake: Brewfest Armor
		208680, -- Windborne Velocidrake: Hallow's End Armor
		208200, -- Dragon Isles Drakes: White Scales
		208550, -- Dragon Isles Drakes: Gilded Armor
		--------------------------------------------------------
		-- 10.2
		--------------------------------------------------------
		210482, -- Flourishing Whimsydrake: Back Fins
		210471, -- Flourishing Whimsydrake: Body Armor
		210478, -- Flourishing Whimsydrake: Gold and Pink Armor
		210476, -- Flourishing Whimsydrake: Helmet
		210486, -- Flourishing Whimsydrake: Horns
		210485, -- Flourishing Whimsydrake: Long Snout
		210487, -- Flourishing Whimsydrake: Neck Fins
		210479, -- Flourishing Whimsydrake: Night Scales
		210483, -- Flourishing Whimsydrake: Ridged Brow
		210480, -- Flourishing Whimsydrake: Sunrise Scales
		210481, -- Flourishing Whimsydrake: Sunset Scales
		210484, -- Flourishing Whimsydrake: Underbite Snout
		207760, -- Grotto Netherwing Drake: Armor
		207779, -- Grotto Netherwing Drake: Barbed Tail
		207776, -- Grotto Netherwing Drake: Black Scales
		207762, -- Grotto Netherwing Drake: Chin Spike
		207761, -- Grotto Netherwing Drake: Chin Tendrils
		207759, -- Grotto Netherwing Drake: Cluster Spiked Back
		207765, -- Grotto Netherwing Drake: Cluster Spiked Crest
		207778, -- Grotto Netherwing Drake: Double Finned Tail
		207774, -- Grotto Netherwing Drake: Finned Jaw
		207764, -- Grotto Netherwing Drake: Head Spike
		207772, -- Grotto Netherwing Drake: Long Horns
		207769, -- Grotto Netherwing Drake: Outcast Pattern
		207757, -- Grotto Netherwing Drake: Purple and Silver Armor
		207771, -- Grotto Netherwing Drake: Short Horns
		207763, -- Grotto Netherwing Drake: Single Horned Crest
		207758, -- Grotto Netherwing Drake: Spiked Back
		207773, -- Grotto Netherwing Drake: Spiked Jaw
		207775, -- Grotto Netherwing Drake: Teal Scales
		207767, -- Grotto Netherwing Drake: Tempestuous Pattern
		207766, -- Grotto Netherwing Drake: Triple Spiked Crest
		211381, -- Grotto Netherwing Drake: Violet Scales
		207768, -- Grotto Netherwing Drake: Volatile Pattern
		207777, -- Grotto Netherwing Drake: Yellow Scales
		210432, -- Highland Drake: Winter Veil Armor
		210537, -- Renewed Proto-Drake: Embodiment of Shadowflame
		210536, -- Renewed Proto-Drake: Embodiment of the Blazing
		210064, -- Winding Slitherdrake: Embodiment of the Verdant Gladiator
		-- 10.2.7
		213561, -- Winding Slitherdrake: Void Scales
	},
	["|cffa335eeLizi's Reins|r"] = {
		192615, -- Fluorescent Fluid
		192658, -- High-Fiber Leaf
		192636, -- Woolly Mountain Pelt
		200598, -- Meluun's Green Curry
	},
	["|cffa335eeTemperamental Skyclaw|r"] = {
		201422, -- Flash Frozen Meat
		201420, -- Gnolan's House Special
		201421, -- Tuskarr Jerky
	},
	["|cffa335eeMagmashell|r"] = {
		201883, -- Empty Magma Shell
	},
	["|cffa335eeLoyal Magmammoth|r"] = {
		201840, -- Sturdy Obsidian Glasses
		201839, -- Netherforged Lavaproof Boots
		201837, -- Magmammoth Harness
	},
	["|cffa335eeMossy Mammoth|r"] = {
		204371, -- Drop of Blue Dragon Magic
		204366, -- Egg of Unknown Contents
		204374, -- Emerald Dragon Brooch
		204375, -- Everburning Ruby Coals
		204364, -- Magically Altered Egg
		204363, -- Particularly Ordinary Egg
		204369, -- Scrap of Black Dragonscales
		204367, -- Sleeping Ancient Mammoth
		204372, -- Speck of Bronze Dust
		204360, -- Strange Petrified Orb
	},
	["|cffa335eeGooey Snailemental|r"] = {
		204352, -- Leftover Elemental Slime
	},
	["|cff0070ddChip|r"] = {
		199219, -- Element-Infused Blood
		198082, -- Pre-Sentient Rock Cluster
		198357, -- Rock of Aegis
	},
	["|cff0070ddPhoenix Wishwing|r"] = {
		199203, -- Phoenix Ash Talisman
		199080, -- Smoldering Phoenix Ash
		202062, -- Ash Feather
		199099, -- Glittering Phoenix Ember
		199097, -- Sacred Phoenix Ash
		199092, -- Inert Phoenix Ash
		199177, -- Ash Feather Amulet
	},
	["|cffff8040Reputation|r"] = {
		191251, -- Key Fragments
		193201, -- Key Framing
		191264, -- Restored Obsidian Key
		191255, -- Greater Obsidian Key
		199906, -- Titan Relic
		200450, -- Titan Relic
		200071, -- Sacred Tuskarr Totem
		200449, -- Sacred Tuskarr Totem
		192055, -- Dragon Isles Artifact
		200443, -- Dragon Isles Artifact
		200093, -- Centaur Hunting Trophy
		200447, -- Centaur Hunting Trophy
		201411, -- Ancient Vault Artifact
		201412, -- Ancient Vault Artifact
		201991, -- Sargha's Signet
		200224, -- Mark of Sargha
		200452, -- Dragonscale Expedition Insignia
		200285, -- Dragonscale Expedition Insignia
		201921, -- Dragonscale Expedition Insignia
		202091, -- Dragonscale Expedition Insignia
		200287, -- Iskaara Tuskarr Insignia
		200453, -- Iskaara Tuskarr Insignia
		201922, -- Iskaara Tuskarr Insignia
		202092, -- Iskaara Tuskarr Insignia
		200288, -- Maruuk Centaur Insignia
		200454, -- Maruuk Centaur Insignia
		201923, -- Maruuk Centaur Insignia
		202094, -- Maruuk Centaur Insignia
		200289, -- Valdrakken Accord Insignia
		200455, -- Valdrakken Accord Insignia
		202093, -- Valdrakken Accord Insignia
		201924, -- Valdrakken Accord Insignia
		205365, -- Loamm Niffen Insignia
		205342, -- Loamm Niffen Insignia
		205985, -- Loamm Niffen Insignia
		210422, -- Loamm Niffen Insignia
		210419, -- Dream Wardens Insignia
		210420, -- Dream Wardens Insignia
		211417, -- Dream Wardens Insignia
		210421, -- Dream Wardens Insignia
		211416, -- Dream Wardens Insignia
		210423, -- Dream Wardens Insignia
		198790, -- I.O.U.
		201782, -- Tyr's Blessing
		201783, -- Tutaqan's Commendation
		201779, -- Merithra's Blessing
		201781, -- Memory of Tyr
		205251, -- Champion's Rock Bar
		206006, -- Earth-Warder's Thanks
		205253, -- Farmhand's Abundant Harvest
		205250, -- Gift of the High Redolence
		205254, -- Honorary Explorer's Compass
		205252, -- Momento of Rekindled Bonds
		205249, -- Pungent Niffen Incense
		205992, -- Regurgitated Half-Digested Fish
		205991, -- Shiny Token of Gratitude
		205998, -- Sign of Respect
		205989, -- Symbol of Friendship
		210921, -- Bounty of the Fallen Defector
		211370, -- Branch of Gracus
		211369, -- Charred Staff of the Overseer
		210958, -- Crown of the Dryad Daughter
		211131, -- Delicately Curated Blossoms
		211366, -- Drops of Moon Water
		211371, -- Dryad-Keeper Credentials
		210916, -- Ember of Fyrakk
		210920, -- Gift of Amirdrassil
		211372, -- Q'onzu's Consolation Prize
		210950, -- Insight of Q'onzu
		210730, -- Mark of the Dream Wardens
		210959, -- Pact of the Netherwing
		211353, -- Roasted Ram Special
		210957, -- Rune of the Fire Druids
		210757, -- Scales of Remorse
		210952, -- Spare Heated Hearthstone
		210997, -- Spare Party Hat
		210954, -- Sprout of Rebirth
		210847, -- Tears of the Eye
		210951, -- Treacherous Research Notes
	},
	["|cffAFB42BContracts|r"] = {
		198497, --Contract: Valdrakken Accord
		198499, --Contract: Valdrakken Accord
		198498, --Contract: Valdrakken Accord
		198500, --Contract: Maruuk Centaur
		198502, --Contract: Maruuk Centaur
		198501, --Contract: Maruuk Centaur
		198494, --Contract: Iskaara Tuskarr
		198495, --Contract: Iskaara Tuskarr
		198496, --Contract: Iskaara Tuskarr
		198506, --Contract: Dragonscale Expedition
		198507, --Contract: Dragonscale Expedition
		198508, --Contract: Dragonscale Expedition
		198505, --Contract: Artisan's Consortium
		198503, --Contract: Artisan's Consortium
		198504, --Contract: Artisan's Consortium
		210244, -- Contract: Dream Wardens
		210245, -- Contract: Dream Wardens
		210246, -- Contract: Dream Wardens
	},
	["Treasure Sacks"] = {
		199341, -- Regurgitated Sac of Swog Treasures
		199342, -- Weighted Sac of Swog Treasures
		202102, -- Immaculate Sac of Swog Treasures
	},
	["Darkmoon Cards"] = {
		198614, -- Soggy Clump of Darkmoon Cards
		194827, -- Bundle O' Cards: Dragon Isles
		194801, -- Ace of Air
		194809, -- Ace of Earth
		194785, -- Ace of Fire
		194793, -- Ace of Frost
		194808, -- Eight of Air
		194816, -- Eight of Earth
		194792, -- Eight of Fire
		194800, -- Eight of Frost
		194805, -- Five of Air
		194813, -- Five of Earth
		194789, -- Five of Fire
		194797, -- Five of Frost
		194804, -- Four of Air
		194812, -- Four of Earth
		194788, -- Four of Fire
		194796, -- Four of Frost
		194807, -- Seven of Air
		194815, -- Seven of Earth
		194799, -- Seven of Fire
		194791, -- Seven of Frost
		194806, -- Six of Air
		194814, -- Six of Earth
		194790, -- Six of Fire
		194798, -- Six of Frost
		194803, -- Three of Air
		194811, -- Three of Earth
		194787, -- Three of Fire
		194795, -- Three of Frost
		194802, -- Two of Air
		194810, -- Two of Earth
		194786, -- Two of Fire
		194794, -- Two of Frost
	},
	["Fortune Cards"] = {
		199137, -- Fated Fortune Card
		199156, -- Fated Fortune Card
		199166, -- Fated Fortune Card
		199116, -- Fated Fortune Card
		199124, -- Fated Fortune Card
		199127, -- Fated Fortune Card
		199129, -- Fated Fortune Card
		199141, -- Fated Fortune Card
		199155, -- Fated Fortune Card
		199158, -- Fated Fortune Card
		199165, -- Fated Fortune Card
		199121, -- Fated Fortune Card
		199135, -- Fated Fortune Card
		199146, -- Fated Fortune Card
		199151, -- Fated Fortune Card
		199167, -- Fated Fortune Card
		199114, -- Fated Fortune Card
		199117, -- Fated Fortune Card
		199118, -- Fated Fortune Card
		199119, -- Fated Fortune Card
		199120, -- Fated Fortune Card
		199123, -- Fated Fortune Card
		199125, -- Fated Fortune Card
		199126, -- Fated Fortune Card
		199133, -- Fated Fortune Card
		199134, -- Fated Fortune Card
		199136, -- Fated Fortune Card
		199138, -- Fated Fortune Card
		199139, -- Fated Fortune Card
		199140, -- Fated Fortune Card
		199142, -- Fated Fortune Card
		199143, -- Fated Fortune Card
		199144, -- Fated Fortune Card
		199145, -- Fated Fortune Card
		199147, -- Fated Fortune Card
		199148, -- Fated Fortune Card
		199149, -- Fated Fortune Card
		199150, -- Fated Fortune Card
		199152, -- Fated Fortune Card
		199153, -- Fated Fortune Card
		199154, -- Fated Fortune Card
		199157, -- Fated Fortune Card
		199161, -- Fated Fortune Card
		199162, -- Fated Fortune Card
		199163, -- Fated Fortune Card
		199164, -- Fated Fortune Card
		199168, -- Fated Fortune Card
		199169, -- Fated Fortune Card
		194829, -- Fated Fortune Card
		199160, -- Fated Fortune Card
		199131, -- Fated Fortune Card
		199130, -- Fated Fortune Card
		199159, -- Fated Fortune Card
		199132, -- Fated Fortune Card
		199170, -- Fated Fortune Card
	},
	["|cffff8040Loamm|r"] = {
		204715, -- Unearthed Fragrant Coin
		204727, -- Coveted Bauble
		204985, -- Barter Brick
		205188, -- Barter Boulder
		205982, -- Lost Dig Map
		205984, -- Bartered Dig Map
	},
	["|cffff8040Crests|r"] = {
		-- 10.2.0
		206961, -- Enchanted Aspect's Dreaming Crest
		206960, -- Enchanted Wyrm's Dreaming Crest
		206977, -- Enchanted Whelpling's Dreaming Crest
		208393, -- Nascent Aspect's Dreaming Crest
		208395, -- Nascent Whelpling's Dreaming Crest
		208394, -- Nascent Wyrm's Dreaming Crest
		208568, -- Lesser Verdant Crest of Honor
		208570, -- Greater Verdant Crest of Honor
		208569, -- Verdant Crest of Honor
		-- 10.1.0
		204078, -- Aspect's Shadowflame Crest Fragment
		204077, -- Wyrm's Shadowflame Crest Fragment
		204076, -- Drake's Shadowflame Crest Fragment
		204075, -- Whelpling's Shadowflame Crest Fragment
		204194, -- Aspect's Shadowflame Crest
		204196, -- Wyrm's Shadowflame Crest
		204195, -- Drake's Shadowflame Crest
		204193, -- Whelpling's Shadowflame Crest
		204697, -- Enchanted Aspect's Shadowflame Crest
		204681, -- Enchanted Whelpling's Shadowflame Crest
		204682, -- Enchanted Wyrm's Shadowflame Crest
		204191, -- Lesser Obsidian Crest of Honor
		204190, -- Obsidian Crest of Honor
		204189, -- Greater Obsidian Crest of Honor
		202171, -- Obsidian Flightstone
		205263, -- Empowered Flightstone
		205962, -- Echoing Storm Flightstone
		205970, -- Azure Flightstone
		206037, -- Ruby Flightstone
		-- 10.2.6
		217242, -- Awakening Stone Wing
		211951, -- Pouch of Whelpling's Awakened Crests
		217420, -- Large Pouch of Whelpling's Awakened Crests
		211952, -- Satchel of Drake's Awakened Crests
		212384, -- Restless Satchel of Drake's Awakened Crests
		212367, -- Clutch of Wyrm's Awakened Crests
		211950, -- Lively Clutch of Wyrm's Awakened Crests
		212383, -- Yawning Basket of Aspect's Awakened Crests
		211522, -- Nascent Aspect's Awakened Crest
		211523, -- Nascent Whelpling's Awakened Crest
		211521, -- Nascent Wyrm's Awakened Crest
		211519, -- Enchanted Aspect's Awakened Crest
		211520, -- Enchanted Whelpling's Awakened Crest
		211518, -- Enchanted Wyrm's Awakened Crest
		-- 11.0.0 ???
		-- 221375, -- Pack of Runed Harbinger Crests
		-- 221268, -- Pouch of Weathered Harbinger Crests
		-- 221373, -- Satchel of Carved Harbinger Crests
		-- 220773, -- Celebratory Pack of Runed Harbinger Crests
		-- 220776, -- Glorious Cluster of Gilded Harbinger Crests
		-- 220767, -- Triumphant Satchel of Carved Harbinger Crests
		-- 220789, -- Nascent Gilded Harbinger Crest
		-- 220790, -- Nascent Runed Harbinger Crest
		-- 220788, -- Nascent Weathered Harbinger Crest
		-- 224073, -- Enchanted Gilded Harbinger Crest
		-- 224072, -- Enchanted Runed Harbinger Crest
		-- 224069, -- Enchanted Weathered Harbinger Crest
	},
	["|cff910951Fyrakk Assault|r"] = {
		203430, -- Ward of Igira
		203683, -- Ward of Fyrakk
		203710, -- Everburning Key
	},
	["|cffEDE4D3Time Rift|r"] = {
		207582, -- Box of Tampered Reality
		207584, -- Box of Volatile Reality
		207583, -- Box of Collapsed Reality
		208090, -- Contained Paracausality
		207002, -- Encapsulated Destiny
		207027, -- Greater Encapsulated Destiny
		207030, -- Dilated Time Capsule
		209856, -- Dilated Time Pod
		224298, -- Dilated Eon Canister
	},
	["|cff67CF9EDreamsurge|r"] = {
		209419, -- Charred Elemental Remains
		207026, -- Dreamsurge Coalescence
		208153, -- Dreamsurge Chrysalis
		210254, -- Dreamsurge Cocoon
		224297, -- Dreamsurge Cradle
	},
	["|cff67CF9ESuperbloom|r"] = {
		208066, -- Small Dreamseed
		208067, -- Plump Dreamseed
		208047, -- Gigantic Dreamseed
	},
	["|cffa335eeAwakened|r"] = {
		213089, -- Antique Bronze Bullion
	}
--[[
	["|cfff49813Bronze|r"] = {
		223908, -- Minor Bronze Cache
		223909, -- Lesser Bronze Cache
		223910, -- Bronze Cache
		223911, -- Greater Bronze Cache
	},
	["|cfff49813Eternal Threads|r"] = {
		226142, --Greater Spool of Eternal Thread
		226143, --Spool of Eternal Thread
		226144, --Lesser Spool of Eternal Thread
		226145, --Minor Spool of Eternal Thread
	}
--]]
}
