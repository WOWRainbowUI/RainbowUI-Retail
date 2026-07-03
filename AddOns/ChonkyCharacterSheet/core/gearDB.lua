-- The purpose of the this file is to house the seasonal gear information.
-- It currently holds the M+ dungeon, raid, and class tier information
-- for building a master loot list.
local addonName, ns = ...
local L = ns.L  -- grab the localization table
local CCS = ns.CCS

if CCS.CurrentVersion ~= CCS.RETAIL then
    return
end

local locale = GetLocale()
local _, _, _, tocversion = GetBuildInfo()
local playerLevel = UnitLevel("player")
CCS.SeasonRanges = {
    { season = 1, expansion = 11, toc = {120000, 120009}, ilvlCap = 289 },     -- Midnight Season 1
    { season = 2, expansion = 11, toc = {120100, 120199}, ilvlCap = 328 },     -- Midnight Season 2
    -- Future seasons
    -- { season = 3, expansion = 11, toc = {120200, 120299} },
}

CCS.CurrentSeasonNumber = 0

for _, s in ipairs(CCS.SeasonRanges) do
    if tocversion >= s.toc[1] and tocversion <= s.toc[2] then
        CCS.CurrentSeasonNumber = s.season
        CCS.expansionID = s.expansion
        CCS.seasonCap = s.ilvlCap
        break
    end
end

CCS.Dungeon = CCS.Dungeon or {}
CCS.Raid = CCS.Raid or {}
CCS.Season = CCS.Season or {}
CCS.MasterLoot = {}

-- Initialize the version data container for each xpac and season
CCS.Data = CCS.Data or {}
CCS.Data[11] = CCS.Data[11] or {}   -- Midnight expansion
CCS.Data[11][1] = CCS.Data[11][1] or {}  -- Season 1
CCS.Data[11][2] = CCS.Data[11][2] or {}  -- Season 2 (placeholder)

CCS.FooterFilters = {
    slot = "ALL",
    class = "ALL",
    armor = "ALL",
    primary = "ALL",
    secondaries = {
        CRIT = false,
        HASTE = false,
        MASTERY = false,
        VERS = false,
    },
    instance = "ALL",
    includeDungeons = true,
    includeRaids = true,
    ilvl = CCS.seasonCap,
    track = "Myth",
}


CCS.Dungeon.AltarOfFangs = {
    ejID = 1322,
    bosses = {
        {
            id = 2878, -- Rav'i
            loot = {
                { itemID = 273793 }, -- Hydraspine Twinblade
                { itemID = 273780 }, -- Venom-Etched Crescent
                { itemID = 273785 }, -- Primordial Robe of Rites
                { itemID = 273775 }, -- Hydra Scale Wristguards
                { itemID = 273777 }, -- Poison-Proof Stompers
                { itemID = 273795 }, -- Coiled Fangstone
                { itemID = 273796 }, -- Vile Vial of Volatile Venom
            },
        },
        {
            id = 2879, -- The Writhing Coil
            loot = {
                { itemID = 273783 }, -- Toxin-Coated Warstaff
                { itemID = 273782 }, -- Vile Writhefang Glaive
                { itemID = 273779 }, -- Nocuous Focal Fang
                { itemID = 273781 }, -- Strand of Warding Fangs
                { itemID = 273774 }, -- Snakeskin Spaulders
                { itemID = 273787 }, -- Aged Interwoven Scaleplate
                { itemID = 273786 }, -- Leggings of Entwined Serpents
                { itemID = 273794 }, -- Knot of Writhing Serpents
            },
        },
        {
            id = 2880, -- Zul'jan
            loot = {
                { itemID = 273778 }, -- Polished Lightwood Channeler
                { itemID = 275070 }, -- Sharpened Lightwood Slasher
                { itemID = 273784 }, -- Ancestral Amani Recurve
                { itemID = 273791 }, -- Spare Speaker's Hood
                { itemID = 273789 }, -- Chestguard of Corroded Scales
                { itemID = 273773 }, -- Handwraps of Blasphemous Rites
                { itemID = 273776 }, -- Ancient General's Obsidian Pillars
                { itemID = 273792 }, -- Band of the Amani Warlord
                { itemID = 273797 }, -- Tattered Amani War Banner
            },
        },
    },
}

CCS.Dungeon.DenOfNalorakk = {
    ejID = 1311,
    bosses = {
        {
            id = 2776, -- The Hoardmonger
            loot = {
                { itemID = 251143 }, -- Grim Harvest Gloves
                { itemID = 251146 }, -- Scavenger's Spaulders
                { itemID = 251147 }, -- Hoarded Harvest Wrap
                { itemID = 251144 }, -- Autumn's Boon Belt
                { itemID = 251145 }, -- Forgotten Tribe Footguards
                { itemID = 251148 }, -- Pilfered Precious Band
                { itemID = 250248 }, -- Mycolic Medicine
            },
        },
        {
            id = 2777, -- Sentinel of Winter
            loot = {
                { itemID = 251149 }, -- Victor's Flashfrozen Blade
                { itemID = 251150 }, -- Tempest's Shelter
                { itemID = 271681 }, -- Perennial Frostbound Charm
                { itemID = 251151 }, -- Sentinel Challenger's Prize
                { itemID = 251154 }, -- Winter's Embrace Bracers
                { itemID = 251152 }, -- Season's Turn Gauntlets
                { itemID = 251155 }, -- Tribal Defender's Cord
                { itemID = 251153 }, -- Arctic Explorer's Legwraps
                { itemID = 250244 }, -- Permafrost Essence
            },
        },
        {
            id = 2778, -- Nalorakk
            loot = {
                { itemID = 251156 }, -- Fallen Speaker's Staff
                { itemID = 251158 }, -- Nalorakk's Nightmare
                { itemID = 251173 }, -- Yoke of the Charging Bear
                { itemID = 251159 }, -- War Trial Vestments
                { itemID = 251214 }, -- Bonds of the Hash'ura
                { itemID = 251160 }, -- Forest Dream Leg-guards
                { itemID = 250229 }, -- Idol of the War Loa
                { itemID = 264332 }, -- Amani Ritual Altar
            },
        },
    },
}

CCS.Dungeon.MurderRow = {
    ejID = 1304,
    bosses = {
        {
            id = 2679, -- Kystia Manaheart
            loot = {
                { itemID = 251123 }, -- Nibbles' Training Rod
                { itemID = 271680 }, -- Sinseared Repeater
                { itemID = 251126 }, -- Greathelm of Temptation
                { itemID = 251127 }, -- Nibbling Armbands
                { itemID = 251124 }, -- Gauntlets of Fevered Defense
                { itemID = 251125 }, -- Felsoaked Soles
                { itemID = 250243 }, -- Manaheart's Binding Flame
            },
        },
        {
            id = 2680, -- Zaen Bladesorrow
            loot = {
                { itemID = 251128 }, -- Bladesorrow
                { itemID = 251131 }, -- Jangling Felpaulets
                { itemID = 251132 }, -- Speakeasy Shroud
                { itemID = 251133 }, -- Overseer's Vambraces
                { itemID = 251129 }, -- Counterfeit Clutches
                { itemID = 251130 }, -- Breeches of Deft Deals
                { itemID = 250215 }, -- Freightrunner's Flask
            },
        },
        {
            id = 2681, -- Xathuux the Annihilator
            loot = {
                { itemID = 251134 }, -- Xathuux's Cleave
                { itemID = 251135 }, -- Fury-fletched Armlets
                { itemID = 251137 }, -- Tempestuous Sandals
                { itemID = 251136 }, -- Signet of Snarling Servitude
                { itemID = 250228 }, -- Resonant Bellowstone
            },
        },
        {
            id = 2682, -- Lithiel Cinderfury
            loot = {
                { itemID = 251140 }, -- Vilefiend's Guise
                { itemID = 251142 }, -- Pendant of Malefic Fury
                { itemID = 251138 }, -- Cinderfury Shoulderguards
                { itemID = 251139 }, -- Summoner's Searing Shirt
                { itemID = 251141 }, -- Lithiel's Linked Leggings
                { itemID = 250255 }, -- Unstable Felheart Crystal
            },
        },
    },
}

CCS.Dungeon.TheBlindingVale = {
    ejID = 1309,
    bosses = {
        {
            id = 2769, -- Lightblossom Trinity
            loot = {
                { itemID = 251181 }, -- Pruning Lance
                { itemID = 251180 }, -- Thornblade
                { itemID = 251184 }, -- Ironroot Collar
                { itemID = 251183 }, -- Rootwarden Wraps
                { itemID = 251185 }, -- Lightblossom Cinch
                { itemID = 251182 }, -- Bedrock Breeches
                { itemID = 250254 }, -- Seed of Radiant Hope
            },
        },
        {
            id = 2770, -- Ikuzz the Light Hunter
            loot = {
                { itemID = 251186 }, -- Thorntalon Edge
                { itemID = 251187 }, -- Amirdrassil's Reach
                { itemID = 251188 }, -- Doompetal
                { itemID = 251190 }, -- Bloodthorn Burnous
                { itemID = 251189 }, -- Rootwalker Harness
                { itemID = 250238 }, -- Seed of the Devouring Wild
            },
        },
        {
            id = 2771, -- Lightwarden Ruia
            loot = {
                { itemID = 251192 }, -- Branch of Pride
                { itemID = 251191 }, -- Luminescent Sprout
                { itemID = 251193 }, -- Taproot Ribs
                { itemID = 251165 }, -- Pulverizing Pads
                { itemID = 251194 }, -- Lightwarden's Bind
                { itemID = 250214 }, -- Lightspire Core
            },
        },
        {
            id = 2772, -- Ziekket
            loot = {
                { itemID = 251195 }, -- Thorned Reply
                { itemID = 251196 }, -- Teldrassil's Sacrifice
                { itemID = 251199 }, -- Worldroot Canopy
                { itemID = 251200 }, -- Saptorbane Guards
                { itemID = 251197 }, -- Thornspike Gauntlets
                { itemID = 251198 }, -- Lightspore Leggings
                { itemID = 250259 }, -- Sapling of the Dawnroot
            },
        },
    },
}

CCS.Dungeon.VoidScarArena = {
    ejID = 1313,
    bosses = {
        {
            id = 2791, -- Taz'Rah
            loot = {
                { itemID = 251218 }, -- Taz'Rah's Cosmic Edge
                { itemID = 251220 }, -- Voidscarred Crown
                { itemID = 251223 }, -- Somber Spaulders
                { itemID = 251221 }, -- Despondent's Gauntlets
                { itemID = 251222 }, -- Ethereal Netherwrap
                { itemID = 251219 }, -- Riftworn Stompers
                { itemID = 250225 }, -- Void Execution Mandate
            },
        },
        {
            id = 2792, -- Atroxus
            loot = {
                { itemID = 251225 }, -- Fang of Contagion
                { itemID = 251224 }, -- Hulking Handaxe
                { itemID = 251229 }, -- Visor of the Predator
                { itemID = 251227 }, -- Poisoner's Pauldrons
                { itemID = 251226 }, -- Hide of Pestilence
                { itemID = 251228 }, -- Behemoth Waistband
                { itemID = 252258 }, -- Sickening Signet of Atroxus
                { itemID = 250245 }, -- Tumor of the Swarm
            },
        },
        {
            id = 2793, -- Charonus
            loot = {
                { itemID = 251230 }, -- Charonic Crescent
                { itemID = 251231 }, -- Singularity Slicer
                { itemID = 251232 }, -- Overseer's Diadem
                { itemID = 251234 }, -- Graft of the Domanaar
                { itemID = 251233 }, -- Manipulator's Vest
                { itemID = 251235 }, -- Gravitic Girdle
                { itemID = 250224 }, -- Mindpiercer's Sigil
            },
        },
    },
}

CCS.Dungeon.KingsRest = {
    ejID = 1041,
    bosses = {
        {
            id = 2165, -- The Golden Serpent
            loot = {
                { itemID = 159137 }, -- Gilded Serpent's Tooth
                { itemID = 159413 }, -- Gauntlets of the Avian Sentinel
                { itemID = 159369 }, -- Belt of the Consecrated Tomb
                { itemID = 159313 }, -- Breeches of the Sacred Hall
                { itemID = 159234 }, -- Down-Lined Breeches
                { itemID = 159412 }, -- Auric Puddle Stompers
                { itemID = 159304 }, -- Goldfeather Boots
                { itemID = 159617 }, -- Lustrous Golden Plumage
            },
        },
        {
            id = 2171, -- Mchimba the Embalmer
            loot = {
                { itemID = 159642 }, -- Royal Purifier's Spade
                { itemID = 159667 }, -- Vessel of Last Rites
                { itemID = 159409 }, -- Embalmer's Steadying Bracers
                { itemID = 159312 }, -- Desiccator's Blessed Gloves
                { itemID = 160213 }, -- Sepulchral Construct's Gloves
                { itemID = 159459 }, -- Ritual Binder's Ring
                { itemID = 159618 }, -- Mchimba's Ritual Bandages
            },
        },
        {
            id = 2170, -- The Council of Tribes
            loot = {
                { itemID = 160216 }, -- Crackling Jade Kilij
                { itemID = 159136 }, -- Jeweled Dagger of Subjugation
                { itemID = 159643 }, -- Crossbow of Forgotten Majesty
                { itemID = 159288 }, -- Cloak of the Restless Tribes
                { itemID = 159300 }, -- Kula's Butchering Wristwraps
                { itemID = 159418 }, -- Girdle of Pestilent Purification
                { itemID = 159371 }, -- Boots of the Headlong Conqueror
                { itemID = 159243 }, -- Sandals of Wise Voodoo
            },
        },
        {
            id = 2172, -- Dazar, The First King
            loot = {
                { itemID = 159644 }, -- Geti'ikku, Cut of Death
                { itemID = 159645 }, -- Headcracker of Supplication
                { itemID = 239047 }, -- Headdress of the First Empire
                { itemID = 239050 }, -- Helm of the Raptor King
                { itemID = 239045 }, -- Mantle of Ceremonial Ascension
                { itemID = 239051 }, -- Pauldrons of the Great Unifier
                { itemID = 239049 }, -- Spaulders of Prime Emperor
                { itemID = 239046 }, -- Loa-Blessed Chestguard
                { itemID = 239048 }, -- Vest of Reverent Adoration
                { itemID = 159301 }, -- Primal Dinomancer's Belt
                { itemID = 273649 }, -- Stormbound Emblem of Dazar
            },
        },
    },
}

CCS.Dungeon.RubyLifePools = {
    ejID = 1202,
    bosses = {
        {
            id = 2488, -- Melidrussa Chillworn
            loot = {
                { itemID = 193761 }, -- Chillworn's Infusion Staff
                { itemID = 193758 }, -- Subjugator's Chilling Grips
                { itemID = 193759 }, -- Egg Tender's Leggings
                { itemID = 193728 }, -- Scaleguard's Stalwart Greatboots
                { itemID = 193757 }, -- Ruby Whelp Shell
            },
        },
        {
            id = 2485, -- Kokia Blazehoof
            loot = {
                { itemID = 193767 }, -- Havoc Crusher
                { itemID = 193766 }, -- Kokia's Burnout Rod
                { itemID = 193765 }, -- Blazebound Lieutenant's Helm
                { itemID = 193763 }, -- Fireproof Drape
                { itemID = 193764 }, -- Invader's Firestorm Chestguard
                { itemID = 193762 }, -- Blazebinder's Hoof
            },
        },
        {
            id = 2503, -- Kyrakka and Erkhart Stormvein
            loot = {
                { itemID = 193755 }, -- Backdraft Cleaver
                { itemID = 193756 }, -- Skyferno Rondel
                { itemID = 193754 }, -- Drake Rider's Stecktarge
                { itemID = 193751 }, -- Crown of Roaring Storms
                { itemID = 193753 }, -- Breastplate of Soaring Terror
                { itemID = 193752 }, -- Galerattle Gauntlets
                { itemID = 193691 }, -- Sky Saddle Cord
                { itemID = 193750 }, -- Wind Soarer's Breeches
                { itemID = 193748 }, -- Kyrakka's Searing Embers
            },
        },
    },
}

CCS.Dungeon.TempleOfSethraliss = {
    ejID = 1030,
    bosses = {
        {
            id = 2142, -- Adderis and Aspix
            loot = {
                { itemID = 159636 }, -- Staff of the Lightning Serpent
                { itemID = 158370 }, -- Twin-Strike Polearm
                { itemID = 159380 }, -- Arc-Glass Bindings
                { itemID = 159263 }, -- Bindings of the Slithering Current
                { itemID = 159425 }, -- Shard-Tipped Vambraces
                { itemID = 159317 }, -- Whirling Dervish Sash
                { itemID = 159329 }, -- Leggings of the Galeforce Viper
                { itemID = 159435 }, -- Legplates of Charged Duality
                { itemID = 159388 }, -- Sabatons of Coruscating Energy
                { itemID = 159259 }, -- Sandswept Sandals
            },
        },
        {
            id = 2143, -- Merektha
            loot = {
                { itemID = 158714 }, -- Swarm's Edge
                { itemID = 159637 }, -- Snakebite Recurve
                { itemID = 159255 }, -- Ouroborial Sash
                { itemID = 159375 }, -- Legguards of the Awakening Brood
                { itemID = 159327 }, -- Sand-Shined Snakeskin Sandals
                { itemID = 162544 }, -- Jade Ophidian Band
                { itemID = 158367 }, -- Merektha's Fang
                { itemID = 160832 }, -- Viable Cobra Egg
                { itemID = 159388 }, -- Sabatons of Coruscating Energy (shared)
            },
        },
        {
            id = 2144, -- Galvazzt
            loot = {
                { itemID = 158369 }, -- Galvanized Stormcrusher
                { itemID = 159664 }, -- Bulwark of Brimming Potential
                { itemID = 159247 }, -- Handwraps of Oscillating Polarity
                { itemID = 159442 }, -- Sand-Scoured Greatbelt
                { itemID = 158366 }, -- Charged Sandstone Band
                { itemID = 158374 }, -- Tiny Electromental in a Jar
            },
        },
        {
            id = 2145, -- Avatar of Sethraliss
            loot = {
                { itemID = 158373 }, -- Resonating Crystal Scimitar
                { itemID = 239033 }, -- Hood of the Slithering Loa
                { itemID = 239035 }, -- Sethraliss' Fanged Helm
                { itemID = 239031 }, -- Brood Cleanser's Amice
                { itemID = 239037 }, -- C'thraxxi Binders Pauldrons
                { itemID = 239034 }, -- Corrupted Hexxer's Vestments
                { itemID = 239036 }, -- Desert Guardian's Breastplate
                { itemID = 239032 }, -- Robes of the Reborn Serpent
                { itemID = 159337 }, -- Grips of Electrified Defense
                { itemID = 158368 }, -- Sethraliss' Defiled Relic
            },
        },
    },
}

CCS.Dungeon.MagistersTerrace = {
    ejID = 249,
    bosses = {
        {
            id = 2659, -- Arcanotron Custos
            loot = {
                { itemID = 251100 },
                { itemID = 251101 },
                { itemID = 251103 },
                { itemID = 251102 },
                { itemID = 251104 },
                { itemID = 250246 },
            },
        },
        {
            id = 2661, -- Seranel Sunlash
            loot = {
                { itemID = 251106 },
                { itemID = 251105 },
                { itemID = 251109 },
                { itemID = 260312 },
                { itemID = 251108 },
                { itemID = 251110 },
                { itemID = 251107 },
            },
        },
        {
            id = 2660, -- Gemellus
            loot = {
                { itemID = 251111 },
                { itemID = 251114 },
                { itemID = 251113 },
                { itemID = 251112 },
                { itemID = 251115 },
                { itemID = 250242 },
            },
        },
        {
            id = 2662, -- Degentrius
            loot = {
                { itemID = 251117 },
                { itemID = 251118 },
                { itemID = 251119 },
                { itemID = 251120 },
                { itemID = 251121 },
                { itemID = 251122 },
                { itemID = 250257 },
            },
        },
    },
}

-- Maisara Caverns (EJ ID 1315)
CCS.Dungeon.MaisaraCaverns = {
    ejID = 1315,
    bosses = {
        {
            id = 2810, -- Muro'jin and Nekraxx
            loot = {
                { itemID = 251162 },
                { itemID = 251174 },
                { itemID = 251176 },
                { itemID = 263193 },
                { itemID = 251166 },
                { itemID = 251167 },
            },
        },
        {
            id = 2811, -- Vordaza
            loot = {
                { itemID = 251178 },
                { itemID = 251171 },
                { itemID = 251161 },
                { itemID = 251172 },
                { itemID = 251170 },
                { itemID = 251169 },
                { itemID = 250223 },
            },
        },
        {
            id = 2812, -- Rak'tul, Vessel of Souls
            loot = {
                { itemID = 251168 },
                { itemID = 251163 },
                { itemID = 251175 },
                { itemID = 251177 },
                { itemID = 251164 },
                { itemID = 251179 },
                { itemID = 250258 },
            },
        },
    },
}

-- Nexus-Point Xenas (EJ ID 1316)
CCS.Dungeon.NexusPointXenas = {
    ejID = 1316,
    bosses = {
        {
            id = 2813, -- Chief Corewright Kasreth
            loot = {
                { itemID = 251202 },
                { itemID = 251206 },
                { itemID = 251203 },
                { itemID = 251204 },
                { itemID = 251205 },
                { itemID = 251201 },
            },
        },
        {
            id = 2814, -- Corewarden Nysarra
            loot = {
                { itemID = 251213 },
                { itemID = 251209 },
                { itemID = 251208 },
                { itemID = 251210 },
                { itemID = 251093 },
                { itemID = 251207 },
                { itemID = 250253 },
            },
        },
        {
            id = 2815, -- Lothraxion
            loot = {
                { itemID = 251212 },
                { itemID = 251157 },
                { itemID = 251216 },
                { itemID = 251211 },
                { itemID = 251215 },
                { itemID = 251217 },
                { itemID = 250241 },
            },
        },
    },
}

-- Windrunner Spire (EJ ID 1299)
CCS.Dungeon.WindrunnerSpire = {
    ejID = 1299,
    bosses = {
        {
            id = 2655, -- Emberdawn
            loot = {
                { itemID = 251078 },
                { itemID = 251077 },
                { itemID = 251080 },
                { itemID = 251079 },
                { itemID = 251081 },
                { itemID = 251082 },
                { itemID = 250144 },
            },
        },
        {
            id = 2656, -- Derelict Duo
            loot = {
                { itemID = 251083 },
                { itemID = 251085 },
                { itemID = 251086 },
                { itemID = 251087 },
                { itemID = 251084 },
                { itemID = 250226 },
            },
        },
        {
            id = 2657, -- Commander Kroluk
            loot = {
                { itemID = 251088 },
                { itemID = 251092 },
                { itemID = 251089 },
                { itemID = 251090 },
                { itemID = 251091 },
                { itemID = 250227 },
            },
        },
        {
            id = 2658, -- The Restless Heart
            loot = {
                { itemID = 251094 },
                { itemID = 251095 },
                { itemID = 251096 },
                { itemID = 251097 },
                { itemID = 251098 },
                { itemID = 251099 },
                { itemID = 250256 },
            },
        },
    },
}

-- Algeth'ar Academy (EJ ID 1201)
CCS.Dungeon.AlgetharAcademy = {
    ejID = 1201,
    bosses = {
        {
            id = 2509, -- Vexamus
            loot = {
                { itemID = 258529 },
                { itemID = 193711 },
                { itemID = 193710 },
                { itemID = 193709 },
                { itemID = 193708 },
            },
        },
        {
            id = 2512, -- Overgrown Ancient
            loot = {
                { itemID = 193716 },
                { itemID = 193717 },
                { itemID = 193712 },
                { itemID = 193714 },
                { itemID = 193713 },
                { itemID = 193715 },
            },
        },
        {
            id = 2495, -- Crawth
            loot = {
                { itemID = 193723 },
                { itemID = 258531 },
                { itemID = 193720 },
                { itemID = 193721 },
                { itemID = 193722 },
                { itemID = 193719 },
                { itemID = 193718 },
            },
        },
        {
            id = 2514, -- Echo of Doragosa
            loot = {
                { itemID = 193707 },
                { itemID = 193703 },
                { itemID = 193704 },
                { itemID = 193705 },
                { itemID = 193706 },
                { itemID = 193701 },
            },
        },
    },
}

-- Pit of Saron (EJ ID 278)
CCS.Dungeon.PitOfSaron = {
    ejID = 278,
    bosses = {
        {
            id = 608, -- Forgemaster Garfrost
            loot = {
                { itemID = 49802 },
                { itemID = 50227 },
                { itemID = 50228 },
                { itemID = 50234 },
                { itemID = 50233 },
                { itemID = 49806 },
                { itemID = 49805 },
            },
        },
        {
            id = 609, -- Ick and Krick
            loot = {
                { itemID = 49807 },
                { itemID = 50264 },
                { itemID = 49809 },
                { itemID = 49808 },
                { itemID = 50263 },
                { itemID = 49810 },
                { itemID = 49811 },
                { itemID = 49812 },
                { itemID = 252421 },
            },
        },
        {
            id = 610, -- Scourgelord Tyrannus
            loot = {
                { itemID = 49813 },
                { itemID = 49824 },
                { itemID = 49819 },
                { itemID = 49823 },
                { itemID = 50272 },
                { itemID = 49825 },
                { itemID = 49817 },
                { itemID = 50259 },
            },
        },
    },
}

-- Seat of the Triumvirate (EJ ID 945)
CCS.Dungeon.SeatOfTheTriumvirate = {
    ejID = 945,
    bosses = {
        {
            id = 1979, -- Zuraal the Ascended
            loot = {
                { itemID = 258514 },
                { itemID = 151336 },
                { itemID = 151329 },
                { itemID = 151300 },
                { itemID = 151320 },
                { itemID = 151308 },
                { itemID = 151312 },
            },
        },
        {
            id = 1980, -- Saprish
            loot = {
                { itemID = 258516 },
                { itemID = 151337 },
                { itemID = 151323 },
                { itemID = 151303 },
                { itemID = 151321 },
                { itemID = 151318 },
                { itemID = 151327 },
                { itemID = 151314 },
                { itemID = 151330 },
                { itemID = 151307 },
            },
        },
        {
            id = 1981, -- Viceroy Nezhar
            loot = {
                { itemID = 258524 },
                { itemID = 258523 },
                { itemID = 151333 },
                { itemID = 151309 },
                { itemID = 151299 },
                { itemID = 151325 },
                { itemID = 151305 },
                { itemID = 151332 },
                { itemID = 151317 },
                { itemID = 151310 },
            },
        },
        {
            id = 1982, -- L'ura
            loot = {
                { itemID = 258525 },
                { itemID = 151319 },
                { itemID = 151313 },
                { itemID = 151328 },
                { itemID = 151322 },
                { itemID = 151302 },
                { itemID = 151301 },
                { itemID = 151311 },
                { itemID = 151340 },
            },
        },
    },
}

-- Skyreach (EJ ID 476)
CCS.Dungeon.Skyreach = {
    ejID = 476,
    bosses = {
        {
            id = 965, -- Ranjit
            loot = {
                { itemID = 258046 },
                { itemID = 258218 },
                { itemID = 258412 },
                { itemID = 258575 },
                { itemID = 258574 },
            },
        },
        {
            id = 966, -- Araknath
            loot = {
                { itemID = 258047 },
                { itemID = 258436 },
                { itemID = 258579 },
                { itemID = 258578 },
                { itemID = 258576 },
                { itemID = 258577 },
                { itemID = 252418 },
            },
        },
        {
            id = 967, -- Rukhran
            loot = {
                { itemID = 258048 },
                { itemID = 258438 },
                { itemID = 258472 },
                { itemID = 258581 },
                { itemID = 258580 },
                { itemID = 258583 },
                { itemID = 258582 },
                { itemID = 252411 },
            },
        },
        {
            id = 968, -- High Sage Viryx
            loot = {
                { itemID = 258484 },
                { itemID = 258050 },
                { itemID = 258049 },
                { itemID = 258585 },
                { itemID = 258587 },
                { itemID = 258586 },
                { itemID = 258584 },
                { itemID = 252420 },
            },
        },
    },
}


-- The Dreamrift (EJ ID 1314)
CCS.Raid.Dreamrift = {
    ejID = 1314,
    bosses = {
        {
            id = 2795, -- Chimaerus the Undreamt God
            loot = {
                --{ itemID = 249347 },
                --{ itemID = 249348 },
                --{ itemID = 249349 },
                --{ itemID = 249350 },
                { itemID = 249278 },
                { itemID = 249922 },
                { itemID = 249374 },
                { itemID = 249371 },
                { itemID = 249373 },
                { itemID = 249381 },
                { itemID = 249343 },
                { itemID = 249805 },
            },
        },
    },
}

-- The Sporefall (EJ ID 1305)
CCS.Raid.Sporefall = {
    ejID = 1305,
    bosses = {
        {
            id = 2711, -- Rotmire
            loot = {
                { itemID = 268283 },
                { itemID = 268291 },
                { itemID = 268284 },
                { itemID = 268285 },
                { itemID = 268289 },
                { itemID = 268286 },
                { itemID = 268288 },
                { itemID = 268287 },
                { itemID = 268282 },
                { itemID = 268292 },
                { itemID = 268290 },
            },
        },
    },
}

-- The Voidspire (EJ ID 1307)
CCS.Raid.Voidspire = {
    ejID = 1307,
    bosses = {
        {
            id = 2733, -- Imperator Averzian
            loot = {
                { itemID = 249293 },
                { itemID = 249279 },
                { itemID = 249275 },
                { itemID = 249306 },
                { itemID = 249313 },
                { itemID = 249335 },
                { itemID = 249310 },
                { itemID = 249326 },
                { itemID = 249319 },
                { itemID = 249323 },
                { itemID = 249320 },
                { itemID = 249334 },
                { itemID = 249344 },
            },
        },
        {
            id = 2734, -- Vorasius
            loot = {
                --{ itemID = 249353 },
                --{ itemID = 249352 },
                --{ itemID = 249354 },
                --{ itemID = 249351 },
                { itemID = 249302 },
                { itemID = 249925 },
                { itemID = 249276 },
                { itemID = 249317 },
                { itemID = 249327 },
                { itemID = 249315 },
                { itemID = 249332 },
                { itemID = 249336 },
                { itemID = 249342 },
            },
        },
        {
            id = 2736, -- Fallen-King Salhadaar
            loot = {
                --{ itemID = 249365 },
                --{ itemID = 249364 },
                --{ itemID = 249366 },
                --{ itemID = 249363 },
                { itemID = 249281 },
                { itemID = 249298 },
                { itemID = 249316 },
                { itemID = 249337 },
                { itemID = 249308 },
                { itemID = 249304 },
                { itemID = 249314 },
                { itemID = 249341 },
                { itemID = 249340 },
            },
        },
        {
            id = 2735, -- Vaelgor & Ezzorak
            loot = {
                --{ itemID = 249361 },
                --{ itemID = 249360 },
                --{ itemID = 249362 },
                --{ itemID = 249359 },
                { itemID = 249287 },
                { itemID = 249280 },
                { itemID = 249318 },
                { itemID = 249370 },
                { itemID = 249321 },
                { itemID = 249331 },
                { itemID = 249305 },
                { itemID = 249339 },
                { itemID = 249346 },
            },
        },
        {
            id = 2737, -- Lightblinded Vanguard
            loot = {
                --{ itemID = 249357 },
                --{ itemID = 249356 },
                --{ itemID = 249358 },
                --{ itemID = 249355 },
                { itemID = 249277 },
                { itemID = 249294 },
                { itemID = 249333 },
                { itemID = 249330 },
                { itemID = 249303 },
                { itemID = 249311 },
                { itemID = 249369 },
                { itemID = 249808 },
            },
        },
        {
            id = 2738, -- Crown of the Cosmos
            loot = {
                { itemID = 260423 },
                { itemID = 249295 },
                { itemID = 249288 },
                { itemID = 249329 },
                { itemID = 249309 },
                { itemID = 249325 },
                { itemID = 249380 },
                { itemID = 249312 },
                { itemID = 249382 },
                { itemID = 249809 },
                { itemID = 249345 },
                { itemID = 249368 },
            },
        },
    },
}

-- March on Quel'Danas (EJ ID 1308)
CCS.Raid.MarchOnQueldanas = {
    ejID = 1308,
    bosses = {
        {
            id = 2739, -- Belo'ren, Child of Al'ar
            loot = {
                { itemID = 249283 },
                { itemID = 249284 },
                { itemID = 249921 },
                { itemID = 249328 },
                { itemID = 249322 },
                { itemID = 249307 },
                { itemID = 249376 },
                { itemID = 249324 },
                { itemID = 249377 },
                { itemID = 249919 },
                { itemID = 249806 },
                { itemID = 249807 },
                { itemID = 260235 },
            },
        },
        {
            id = 2740, -- Midnight Falls
            loot = {
                { itemID = 249296 },
                { itemID = 249286 },
                { itemID = 260408 },
                { itemID = 249913 },
                { itemID = 249914 },
                { itemID = 250247 },
                { itemID = 249912 },
                { itemID = 249915 },
                { itemID = 249811 },
                { itemID = 249810 },
                { itemID = 249920 },
            },
        },
    },
}

CCS.Raid.TheVenomousAbyss = {
    ejID = 1320,
    bosses = {
        {
            id = 2888, -- Nek'zali the Soulcoiler
            loot = {
                { itemID = 268203 }, -- Hexing Spiritrender
                { itemID = 268208 }, -- Strongblood's Ceremonial Cleaver
                { itemID = 270930 }, -- Tomb-Creeper's Claw
                { itemID = 268229 }, -- Skullguard of the Risen Sacrifice
                { itemID = 268231 }, -- Soulslither Spaulders
                { itemID = 268248 }, -- Amani Summoning Shawl
                { itemID = 268235 }, -- Vestment of the Awakening
                { itemID = 268240 }, -- Restless Spirit Shackles
                { itemID = 268216 }, -- Cursed Reliquary Cincture
                { itemID = 268236 }, -- Initiate's Sacrificial Tights
                { itemID = 268245 }, -- Entombed Cultist's Sabatons
                { itemID = 268218 }, -- Nek'zali's Spiritwalkers
                { itemID = 270162 }, -- Soulcoiler Ritual Vessel
            },
        },
        {
            id = 2874, -- Entombed Sentinels
            loot = {
                { itemID = 268198 }, -- Caustic Keeper-Crusher
                { itemID = 268204 }, -- Ancient Construct's Venomshiv
                { itemID = 268197 }, -- Spine of the Hissing Abyss
                { itemID = 268230 }, -- Crown of the Eternal Fang
                { itemID = 268219 }, -- Shadow Hunter's Warmask
                { itemID = 268250 }, -- Sentinel's Vitriolic Chain
                { itemID = 268228 }, -- Venom-Singed Cuffs
                { itemID = 268224 }, -- Venom Warden's Greaves
                { itemID = 270165 }, -- Keeper's Seething Core
            },
        },
        {
            id = 2882, -- Vashnik the Malignant
            loot = {
                { itemID = 268214 }, -- Malignant Toothed Edge
                { itemID = 268205 }, -- Venomancer's Winged Channeler
                { itemID = 268246 }, -- Frothing Venom Spaulders
                { itemID = 268254 }, -- Serpentine Mixing Belt
                { itemID = 268260 }, -- Scaled Fiend's Warboots
                { itemID = 268249 }, -- Vile Alchemist's Band
                { itemID = 270161 }, -- Fang of Umbral Malignance
                { itemID = 270166 }, -- Vashnik's Sanguine Rancor
                { itemID = 272361 }, -- No Item Name
            },
        },
        {
            id = 2894, -- The Lost Explorers
            loot = {
                { itemID = 268210 }, -- Malevolent Spiritcudgel
                { itemID = 268200 }, -- Gebbo's Backup Blaster
                { itemID = 268196 }, -- Venom-Slashed Scuteward
                { itemID = 268242 }, -- Errant Scrollsage's Hood
                { itemID = 268239 }, -- Shellbound Bracers
                { itemID = 268227 }, -- Unpossessed Skullsash
                { itemID = 268258 }, -- Boots of the Reckless Wayfarer
                { itemID = 270160 }, -- First Mate's Shellward
                { itemID = 270164 }, -- Gebbo's Bottomless Bag
            },
        },
        {
            id = 2871, -- Sszorak
            loot = {
                { itemID = 268206 }, -- Slithering Savage's Gavel
                { itemID = 268201 }, -- Venomous Boneglaive
                { itemID = 268234 }, -- Ruthless Slaughtergrips
                { itemID = 268257 }, -- Caustic Chain-Wrapped Sash
                { itemID = 268233 }, -- Ferocious Scaleboots
                { itemID = 268252 }, -- Apex Brute's Claw Ring
                { itemID = 270174 }, -- Idol of the Howling Nexus
                { itemID = 270163 }, -- Sszorak's Ferocity
            },
        },
        {
            id = 2887, -- The Twin Fangs
            loot = {
                { itemID = 268264 }, -- Ravenous Feaster's Fang
                { itemID = 268251 }, -- Amulet of the Twin Fangs
                { itemID = 268241 }, -- Ornaments of the Eternal Coil
                { itemID = 268223 }, -- Ophidian Fangmail
                { itemID = 268220 }, -- Scaleplate Strangulators
                { itemID = 268261 }, -- Bespittled Slitherslippers
                { itemID = 270171 }, -- Preternatural Antivenom
                { itemID = 270170 }, -- Vexhul's Everflowing Gland
            },
        },
        {
            id = 2883, -- The Coiled Altar
            loot = {
                { itemID = 268211 }, -- Baleful Hexblade
                { itemID = 268253 }, -- Silken Voodoo Drape
                { itemID = 268222 }, -- Reckless Spirit Breastplate
                { itemID = 268243 }, -- Grasps of the Eternal Shadow
                { itemID = 268259 }, -- Girdle of Toxic Regret
                { itemID = 268256 }, -- Sash of the Forlorn Vessel
                { itemID = 268237 }, -- Cuisses of the Uncoiled Union
                { itemID = 268255 }, -- Cackling Soultreads
                { itemID = 270169 }, -- Hex Lord's Dooming Idol
                { itemID = 270173 }, -- Zul'jin's Guillotine Technique
                { itemID = 268213 }, -- Maze-roa, Warlord's Fury
                { itemID = 268209 }, -- Aman'muso, Warlord's Vengeance
            },
        },
        {
            id = 2895, -- Ula'tek
            loot = {
                { itemID = 268215 }, -- Abyssal Broodfiend's Bardiche
                { itemID = 268202 }, -- Jaw of the Shackled Goddess
                { itemID = 268207 }, -- Caustic Repose Greatbow
                { itemID = 271875 }, -- Gaze of the Coiled Watcher
                { itemID = 271874 }, -- Venomkeeper's Horrific Cowl
                { itemID = 268265 }, -- Aqirbane Reliquary
                { itemID = 271876 }, -- Awoken Dreadfang Cuirass
                { itemID = 271878 }, -- Chausses of Unbound Rancor
                { itemID = 270168 }, -- Font of Venomous Rage
                { itemID = 270175 }, -- Voracious Heart of Ula'tek
                { itemID = 271093 }, -- Zatha'tek, Breath of Corruption
                { itemID = 271092 }, -- Jan'thrazet, the Soul Fang
            },
        },
    },
}


CCS.Raid.TheTideboundGrotto = {
    ejID = 1317,
    bosses = {
        {
            id = 2849, -- Nymrissa Wavecaller
            loot = {
                { itemID = 268199 }, -- Tidepiercer's Bubble Popper
                { itemID = 268262 }, -- Bubblefin Splash Guard
                { itemID = 268263 }, -- Frostscale's Mystic Frond
                { itemID = 268226 }, -- Swelling Sea Spaulders
                { itemID = 268221 }, -- Tidebound Sorcereress's Robes
                { itemID = 268217 }, -- Rising Tide Wristguards
                { itemID = 268238 }, -- Grips of Swirling Fury
                { itemID = 268232 }, -- Cincture of the Abyssal Grotto
                { itemID = 268244 }, -- Forgotten Grotto Girdle
                { itemID = 268225 }, -- Spelunker's Drenched Legguards
                { itemID = 268247 }, -- Breakwater Boots
                { itemID = 268266 }, -- Alluring Bubbleband
                { itemID = 270167 }, -- Wavecaller's Seastone
            },
        },
    },
}

---------------------------------------------------
-- Class Sets per xpac and season
---------------------------------------------------
CCS.Data[11][1].classSets = { -- Midnight Season 1
    [1]  = { setID = 1990, items = { {itemID=249955},{itemID=249953},{itemID=249952},{itemID=249951},{itemID=249950} } }, -- Warrior
    [2]  = { setID = 1985, items = { {itemID=249964},{itemID=249962},{itemID=249961},{itemID=249960},{itemID=249959} } }, -- Paladin
    [3]  = { setID = 1982, items = { {itemID=249991},{itemID=249989},{itemID=249988},{itemID=249987},{itemID=249986} } }, -- Hunter
    [4]  = { setID = 1987, items = { {itemID=250009},{itemID=250007},{itemID=250006},{itemID=250005},{itemID=250004} } }, -- Rogue
    [5]  = { setID = 1986, items = { {itemID=250052},{itemID=250051},{itemID=250050},{itemID=250054},{itemID=250049} } }, -- Priest
    [6]  = { setID = 1978, items = { {itemID=249973},{itemID=249971},{itemID=249970},{itemID=249969},{itemID=249968} } }, -- Death Knight
    [7]  = { setID = 1988, items = { {itemID=249982},{itemID=249980},{itemID=249979},{itemID=249978},{itemID=249977} } }, -- Shaman
    [8]  = { setID = 1983, items = { {itemID=250063},{itemID=250061},{itemID=250060},{itemID=250059},{itemID=250058} } }, -- Mage
    [9]  = { setID = 1989, items = { {itemID=250043},{itemID=250042},{itemID=250041},{itemID=250045},{itemID=250040} } }, -- Warlock
    [10] = { setID = 1984, items = { {itemID=250018},{itemID=250016},{itemID=250015},{itemID=250014},{itemID=250013} } }, -- Monk
    [11] = { setID = 1980, items = { {itemID=250027},{itemID=250025},{itemID=250024},{itemID=250023},{itemID=250022} } }, -- Druid
    [12] = { setID = 1979, items = { {itemID=250036},{itemID=250034},{itemID=250033},{itemID=250032},{itemID=250031} } }, -- Demon Hunter
    [13] = { setID = 1981, items = { {itemID=250000},{itemID=249998},{itemID=249997},{itemID=249996},{itemID=249995} } }, -- Evoker
}

CCS.Data[11][2].classSets = { -- Midnight Season 2
    [1]  = { setID = 2067, items = { {itemID=271459},{itemID=271457},{itemID=271456},{itemID=271455},{itemID=271454} } }, -- Warrior
    [2]  = { setID = 2062, items = { {itemID=271468},{itemID=271466},{itemID=271465},{itemID=271464},{itemID=271463} } }, -- Paladin
    [3]  = { setID = 2059, items = { {itemID=271495},{itemID=271493},{itemID=271492},{itemID=271491},{itemID=271490} } }, -- Hunter
    [4]  = { setID = 2064, items = { {itemID=271513},{itemID=271511},{itemID=271510},{itemID=271509},{itemID=271508} } }, -- Rogue
    [5]  = { setID = 2063, items = { {itemID=271556},{itemID=271555},{itemID=271554},{itemID=271558},{itemID=271553} } }, -- Priest
    [6]  = { setID = 2055, items = { {itemID=271477},{itemID=271475},{itemID=271474},{itemID=271473},{itemID=271472} } }, -- Death Knight
    [7]  = { setID = 2065, items = { {itemID=271486},{itemID=271484},{itemID=271483},{itemID=271482},{itemID=271481} } }, -- Shaman
    [8]  = { setID = 2060, items = { {itemID=271567},{itemID=271565},{itemID=271564},{itemID=271563},{itemID=271562} } }, -- Mage
    [9]  = { setID = 2066, items = { {itemID=271547},{itemID=271546},{itemID=271545},{itemID=271549},{itemID=271544} } }, -- Warlock
    [10] = { setID = 2061, items = { {itemID=271522},{itemID=271520},{itemID=271519},{itemID=271518},{itemID=271517} } }, -- Monk
    [11] = { setID = 2057, items = { {itemID=271531},{itemID=271529},{itemID=271528},{itemID=271527},{itemID=271526} } }, -- Druid
    [12] = { setID = 2056, items = { {itemID=271540},{itemID=271538},{itemID=271537},{itemID=271536},{itemID=271535} } }, -- Demon Hunter
    [13] = { setID = 2058, items = { {itemID=271504},{itemID=271502},{itemID=271501},{itemID=271500},{itemID=271499} } }, -- Evoker
}


---------------------------------------------------
-- UpgradeTracks per xpac and season
---------------------------------------------------
CCS.Data[11][1].upgradeTracks = { -- Midnight Season 1
    Champion = {
        id    = CCS.Champion,
        label = L["Champion"],
        bonusByIlvl = {
            [246] = 12785,
            [250] = 12786,
            [253] = 12787,
            [256] = 12788,
            [259] = 12789,
            [263] = 12790,
        },
    },

    Hero = {
        id    = CCS.Hero,
        label = L["Hero"],
        bonusByIlvl = {
            [259] = 12793,
            [263] = 12794,
            [266] = 12795,
            [269] = 12796,
            [272] = 12797,
            [276] = 12798,
            [285] = 13653,
        },
    },

    Myth = {
        id    = CCS.Myth,
        label = L["Myth"],
        bonusByIlvl = {
            [272] = 12801,
            [276] = 12802,
            [279] = 12803,
            [282] = 12804,
            [285] = 12805,
            [289] = 12806,
            [298] = 13654,
        },
    },
}

CCS.Data[11][2].upgradeTracks = { -- Midnight Season 2
    Champion = {
        id    = CCS.Champion,
        label = L["Champion"],
        bonusByIlvl = {
        [285] = 12833,
        [289] = 12834,
        [292] = 12835,
        [295] = 12836,
        [298] = 12837,
        [302] = 12838,
        },
    },

    Hero = {
        id    = CCS.Hero,
        label = L["Hero"],
        bonusByIlvl = {
        [298] = 12841,
        [302] = 12842,
        [305] = 12843,
        [308] = 12844,
        [311] = 12845,
        [315] = 12846,
        },
    },

    Myth = {
        id    = CCS.Myth,
        label = L["Myth"],
        bonusByIlvl = {
        [311] = 12849,
        [315] = 12850,
        [318] = 12851,
        [321] = 12852,
        [324] = 12853,
        [328] = 12854,
        },
    },
}

---------------------------------------------------
-- Dungeons/Raids per xpac and season
---------------------------------------------------
CCS.Data[11][1].season = { -- Midnight Season 1
    seasonName = string.format(EXPANSION_SEASON_NAME, EXPANSION_NAME11, 1),

    dungeons = {
        [249]  = CCS.Dungeon.MagistersTerrace,
        [1315] = CCS.Dungeon.MaisaraCaverns,
        [1316] = CCS.Dungeon.NexusPointXenas,
        [1299] = CCS.Dungeon.WindrunnerSpire,
        [1201] = CCS.Dungeon.AlgetharAcademy,
        [278]  = CCS.Dungeon.PitOfSaron,
        [945]  = CCS.Dungeon.SeatOfTheTriumvirate,
        [476]  = CCS.Dungeon.Skyreach,
    },

    raids = {
        [1314] = CCS.Raid.Dreamrift,
        [1307] = CCS.Raid.Voidspire,
        [1308] = CCS.Raid.MarchOnQueldanas,
        [1305] = CCS.Raid.Sporefall,
    },

    classSets = CCS.Data[11][1].classSets,
    upgradeTracks = CCS.Data[11][1].upgradeTracks,
}

CCS.Data[11][2].season = { -- Midnight Season 2
    seasonName = string.format(EXPANSION_SEASON_NAME, EXPANSION_NAME11, 2),

    dungeons = {
        [1322] = CCS.Dungeon.AltarOfFangs,
        [1311] = CCS.Dungeon.DenOfNalorakk,
        [1304] = CCS.Dungeon.MurderRow,
        [1309] = CCS.Dungeon.TheBlindingVale,
        [1313] = CCS.Dungeon.VoidScarArena,
        [1041] = CCS.Dungeon.KingsRest,
        [1202] = CCS.Dungeon.RubyLifePools,
        [1030] = CCS.Dungeon.TempleOfSethraliss,
    },

    raids = {
        [1320] = CCS.Raid.TheVenomousAbyss,
        [1317] = CCS.Raid.TheTideboundGrotto,
    },

    classSets = CCS.Data[11][2].classSets,
    upgradeTracks = CCS.Data[11][2].upgradeTracks,
}

function CCS:BuildClassSetLookup()
    CCS.ClassSetLookup = {}

    local classSets = CCS.Data[CCS.expansionID][CCS.CurrentSeasonNumber].classSets
    if not classSets then return end

    for classID, data in pairs(classSets) do
        CCS.ClassSetLookup[classID] = {}

        for _, entry in ipairs(data.items) do
            CCS.ClassSetLookup[classID][entry.itemID] = true
        end
    end
end

CCS:BuildClassSetLookup()

local function AddItemToMaster(itemID, container, boss, seasonName)
    local entry = CCS.MasterLoot[itemID] or {}

    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()

        ---------------------------------------------------------
        -- Get item info
        ---------------------------------------------------------
        local name, link, quality, ilvl, req, classStr, subclassStr, stack, equipLoc =
            C_Item.GetItemInfo(itemID)

        -- Numeric class/subclass IDs (REQUIRED for filtering)
        local itemClassID, itemSubClassID = select(12, GetItemInfo(itemID))
        -- itemClassID: 2 = WEAPON, 4 = ARMOR, etc.
        -- itemSubClassID: numeric weapon/armor subtype

        ---------------------------------------------------------
        -- Armor type (Cloth / Leather / Mail / Plate)
        ---------------------------------------------------------
        local armorType = nil

        if itemClassID == 4 then  -- 4 = ARMOR
            -- Retail armor subclass IDs:
            -- 1 = Cloth, 2 = Leather, 3 = Mail, 4 = Plate
            if itemSubClassID == 1 then
                armorType = "Cloth"
            elseif itemSubClassID == 2 then
                armorType = "Leather"
            elseif itemSubClassID == 3 then
                armorType = "Mail"
            elseif itemSubClassID == 4 then
                armorType = "Plate"
            end
        end

        ---------------------------------------------------------
        -- Primary/secondary stat *types* (not values)
        ---------------------------------------------------------
        local stats = link and C_Item.GetItemStats(link) or nil
        local primary = {}
        local secondary = {}

        if stats then
            if stats["ITEM_MOD_STRENGTH"] then table.insert(primary, "STR") end
            if stats["ITEM_MOD_AGILITY"] then table.insert(primary, "AGI") end
            if stats["ITEM_MOD_INTELLECT"] then table.insert(primary, "INT") end

            if stats["ITEM_MOD_CRIT_RATING"] then secondary.CRIT = true end
            if stats["ITEM_MOD_HASTE_RATING"] then secondary.HASTE = true end
            if stats["ITEM_MOD_MASTERY_RATING"] then secondary.MASTERY = true end
            if stats["ITEM_MOD_VERSATILITY"] then secondary.VERS = true end
        end

        ---------------------------------------------------------
        -- Source info
        ---------------------------------------------------------
        local instanceName = container.instanceName or EJ_GetInstanceInfo(container.ejID)
        local bossName = boss.name or EJ_GetEncounterInfo(boss.id)

        ---------------------------------------------------------
        -- Store static fields
        ---------------------------------------------------------
        entry.itemID         = itemID
        entry.name           = name or ("Item "..itemID)
        entry.slot           = equipLoc
        entry.slotID         = CCS.EQUIPLOC_TO_SLOTID[equipLoc] or 0
        entry.armorType      = armorType
        entry.primary        = primary
        entry.secondary      = secondary

        -- ⭐ Correct numeric class/subclass IDs
        entry.itemClassID    = itemClassID
        entry.itemSubClassID = itemSubClassID

        entry.source = {
            type         = container.type,
            ejID         = container.ejID,
            classID      = container.classID,
            instanceName = instanceName,
            bossID       = boss.id,
            bossName     = bossName,
        }

        entry.seasons = entry.seasons or {}
        entry.seasons[seasonName] = true

        ---------------------------------------------------------
        -- Runtime fields (dummy placeholders)
        ---------------------------------------------------------
        entry.runtime = {
            ilvl = 0,
            track = nil,
            rank = 0,
            stats = {
                crit = 0,
                haste = 0,
                mastery = 0,
                vers = 0,
                str = 0,
                agi = 0,
                int = 0,
            }
        }

        CCS.MasterLoot[itemID] = entry
    end)
end

function CCS.BuildMasterLoot()
    -- Pull the correct season dynamically
    local seasonData = CCS.Data[CCS.expansionID]
        and CCS.Data[CCS.expansionID][CCS.CurrentSeasonNumber]
        and CCS.Data[CCS.expansionID][CCS.CurrentSeasonNumber].season

    if not seasonData then
        print("CCS: No season data for expansion", CCS.expansionID, "season", CCS.CurrentSeasonNumber)
        return
    end

    local seasonName = seasonData.seasonName

    ---------------------------------------------------------
    -- Dungeons
    ---------------------------------------------------------
    for ejID, dungeon in pairs(seasonData.dungeons or {}) do
        dungeon.type = "dungeon"

        for _, boss in ipairs(dungeon.bosses or {}) do
            for _, item in ipairs(boss.loot or {}) do
                AddItemToMaster(item.itemID, dungeon, boss, seasonName)
            end
        end
    end

    ---------------------------------------------------------
    -- Raids
    ---------------------------------------------------------
    for ejID, raid in pairs(seasonData.raids or {}) do
        if EJ_GetInstanceInfo(ejID) then
            raid.type = "raid"

            for _, boss in ipairs(raid.bosses or {}) do
                if EJ_GetEncounterInfo(boss.id) then
                    for _, item in ipairs(boss.loot or {}) do
                        AddItemToMaster(item.itemID, raid, boss, seasonName)
                    end
                end
            end
        end
    end

    ---------------------------------------------------------
    -- Class Sets
    ---------------------------------------------------------
    local classSets = seasonData.classSets
    if classSets then
        for classID, classSet in pairs(classSets) do
            if classSet.items then
                classSet.type = "classset"
                classSet.ejID = classID
                classSet.classID = classID
                classSet.instanceName = "Class Sets"

                local classInfo = {
                    id = 0,
                    name = select(1, GetClassInfo(classID)) or " "
                }

                for _, entry in ipairs(classSet.items) do
                    AddItemToMaster(entry.itemID, classSet, classInfo, seasonName)
                end
            end
        end
    end
end
-- This is just for an easier lookup.
CCS.Season = CCS.Data[CCS.expansionID][CCS.CurrentSeasonNumber].season
CCS.BuildMasterLoot()
