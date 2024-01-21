--[[
AdiBags_Hearthstones - Adds various hearthing items to AdiBags virtual groups
Copyright © 2023 Paul Vandersypen, All Rights Reserved
]]--

local _, addon = ...
local L = addon.L

-- need to check game version
local isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local db = {}

-- all game versions have these items
db.Filters = {
    ["hearthstones"] = {
        uiName = TUTORIAL_TITLE31,
        uiDesc = L["Items that hearth you to various places."],
        title = TUTORIAL_TITLE31,
        items = {
            -- itemID               item name
            [6948]  = true,         -- Hearthstone
            [17690] = true,         -- Frostwolf Insignia Rank 1
            [17691] = true,         -- Stormpike Insignia Rank 1
            [17900] = true,         -- Stormpike Insignia Rank 2
            [17901] = true,         -- Stormpike Insignia Rank 3
            [17902] = true,         -- Stormpike Insignia Rank 4
            [17903] = true,         -- Stormpike Insignia Rank 5
            [17904] = true,         -- Stormpike Insignia Rank 6
            [17905] = true,         -- Frostwolf Insignia Rank 2
            [17906] = true,         -- Frostwolf Insignia Rank 3
            [17907] = true,         -- Frostwolf Insignia Rank 4
            [17908] = true,         -- Frostwolf Insignia Rank 5
            [17909] = true,         -- Frostwolf Insignia Rank 6
            [18149] = true,         -- Rune of Recall (Frostwolf Keep)
            [18150] = true,         -- Rune of Recall (Dun Baldar)
            [18984] = true,         -- Dimensional Ripper - Everlook
            [18986] = true,         -- Ultrasafe Transporter - Gadgetzan
            [22589] = true,         -- Atiesh, Greatstaff of the Guardian (Mage)
            [22630] = true,         -- Atiesh, Greatstaff of the Guardian (Warlock)
            [22631] = true,         -- Atiesh, Greatstaff of the Guardian (Priest)
            [22632] = true,         -- Atiesh, Greatstaff of the Guardian (Druid)
        }
    }
}

-- add TBC and Wrath items to Wrath and mainline
if isWrath or isMainline then
    db.Filters["hearthstones"].items[28585]     = true      -- Ruby Slippers
    db.Filters["hearthstones"].items[29796]     = true      -- Socrethar's Teleportation Stone
    db.Filters["hearthstones"].items[30542]     = true      -- Dimensional Ripper - Area 52
    db.Filters["hearthstones"].items[32757]     = true      -- Blessed Medallion of Karabor
    db.Filters["hearthstones"].items[35230]     = true      -- Darnarian's Scroll of Teleportation
    db.Filters["hearthstones"].items[36955]     = true      -- Ultrasafe Transporter - Toshley's Station
    db.Filters["hearthstones"].items[37118]     = true      -- Scroll of Recall
    db.Filters["hearthstones"].items[37863]     = true      -- Direbrew's Remote
    db.Filters["hearthstones"].items[38685]     = true      -- Teleport Scroll: Zul'Farrak
    db.Filters["hearthstones"].items[40585]     = true      -- Signet of the Kirin Tor
    db.Filters["hearthstones"].items[40586]     = true      -- Band of the Kirin Tor
    db.Filters["hearthstones"].items[43824]     = true      -- The Schools of Arcane Magic - Mastery (spires atop the Violet Citadel)
    db.Filters["hearthstones"].items[44934]     = true      -- Loop of the Kirin Tor
    db.Filters["hearthstones"].items[44935]     = true      -- Ring of the Kirin Tor
    db.Filters["hearthstones"].items[45688]     = true      -- Inscribed Band of the Kirin Tor
    db.Filters["hearthstones"].items[45689]     = true      -- Inscribed Loop of the Kirin Tor
    db.Filters["hearthstones"].items[45690]     = true      -- Inscribed Ring of the Kirin Tor
    db.Filters["hearthstones"].items[45691]     = true      -- Inscribed Signet of the Kirin Tor
    db.Filters["hearthstones"].items[46874]     = true      -- Argent Crusader's Tabard
    db.Filters["hearthstones"].items[48933]     = true      -- Wormhole Generator: Northrend
    db.Filters["hearthstones"].items[48954]     = true      -- Etched Band of the Kirin Tor
    db.Filters["hearthstones"].items[48955]     = true      -- Etched Loop of the Kirin Tor
    db.Filters["hearthstones"].items[48956]     = true      -- Etched Ring of the Kirin Tor
    db.Filters["hearthstones"].items[48957]     = true      -- Etched Signet of the Kirin Tor
    db.Filters["hearthstones"].items[50287]     = true      -- Boots of the Bay
    db.Filters["hearthstones"].items[51557]     = true      -- Runed Signet of the Kirin Tor
    db.Filters["hearthstones"].items[51558]     = true      -- Runed Loop of the Kirin Tor
    db.Filters["hearthstones"].items[51559]     = true      -- Runed Ring of the Kirin Tor
    db.Filters["hearthstones"].items[51560]     = true      -- Runed Band of the Kirin Tor
    db.Filters["hearthstones"].items[52251]     = true      -- Jaina's Locket
    db.Filters["hearthstones"].items[54452]     = true      -- Ethereal Portal
    db.Filters["hearthstones"].items[60336]     = true      -- Scroll of Recall II
    db.Filters["hearthstones"].items[60337]     = true      -- Scroll of Recall III
    db.Filters["hearthstones"].items[184871]    = true      -- Dark Portal (TBC)
    db.Filters["hearthstones"].items[199335]    = true      -- Teleport Scroll: Menethil Harbor
    db.Filters["hearthstones"].items[199336]    = true      -- Teleport Scroll: Stormwind Harbor
    db.Filters["hearthstones"].items[199777]    = true      -- Teleport Scroll: Orgrimmar Zepplin Tower
    db.Filters["hearthstones"].items[199778]    = true      -- Teleport Scroll: Undercity Zepplin Tower
    db.Filters["hearthstones"].items[200068]    = true      -- Teleport Scroll: Shattrath City
end

-- add everything else for mainline
if isMainline then
    -- delete these items, since they don't exist
    db.Filters["hearthstones"].items[184871]    = nil       -- Dark Portal (TBC)
    db.Filters["hearthstones"].items[199335]    = nil       -- Teleport Scroll: Menethil Harbor
    db.Filters["hearthstones"].items[199336]    = nil       -- Teleport Scroll: Stormwind Harbor
    db.Filters["hearthstones"].items[199777]    = nil       -- Teleport Scroll: Orgrimmar Zepplin Tower
    db.Filters["hearthstones"].items[199778]    = nil       -- Teleport Scroll: Undercity Zepplin Tower
    db.Filters["hearthstones"].items[200068]    = nil       -- Teleport Scroll: Shattrath City

    -- mainline items
    db.Filters["hearthstones"].items[58487]     = true      -- Potion of Deepholm
    db.Filters["hearthstones"].items[61379]     = true      -- Gidwin's Hearthstone
    db.Filters["hearthstones"].items[63206]     = true      -- Wrap of Unity: Stormwind
    db.Filters["hearthstones"].items[63207]     = true      -- Wrap of Unity: Orgrimmar
    db.Filters["hearthstones"].items[63352]     = true      -- Shroud of Cooperation: Stormwind
    db.Filters["hearthstones"].items[63353]     = true      -- Shroud of Cooperation: Orgrimmar
    db.Filters["hearthstones"].items[63378]     = true      -- Hellscream's Reach Tabard
    db.Filters["hearthstones"].items[63379]     = true      -- Baradin's Wardens Tabard
    db.Filters["hearthstones"].items[64457]     = true      -- The Last Relic of Argus
    db.Filters["hearthstones"].items[64488]     = true      -- The Innkeeper's Daughter
    db.Filters["hearthstones"].items[65274]     = true      -- Cloak of Coordination: Orgrimmar
    db.Filters["hearthstones"].items[65360]     = true      -- Cloak of Coordination: Stormwind
    db.Filters["hearthstones"].items[68808]     = true      -- Hero's Hearthstone
    db.Filters["hearthstones"].items[68809]     = true      -- Veteran's Hearthstone
    db.Filters["hearthstones"].items[87215]     = true      -- Wormhole Generator: Pandaria
    db.Filters["hearthstones"].items[87548]     = true      -- Lorewalker's Lodestone
    db.Filters["hearthstones"].items[92510]     = true      -- Vol'jin's Hearthstone
    db.Filters["hearthstones"].items[93672]     = true      -- Dark Portal (MoP)
    db.Filters["hearthstones"].items[95050]     = true      -- The Brassiest Knuckle (Brawl'gar Arena)
    db.Filters["hearthstones"].items[95051]     = true      -- The Brassiest Knuckle (Bizmo's Brawlpub)
    db.Filters["hearthstones"].items[95567]     = true      -- Kirin Tor Beacon
    db.Filters["hearthstones"].items[95568]     = true      -- Sunreaver Beacon
    db.Filters["hearthstones"].items[103678]    = true      -- Time-Lost Artifact
    db.Filters["hearthstones"].items[110560]    = true      -- Garrison Hearthstone
    db.Filters["hearthstones"].items[112059]    = true      -- Wormhole Centrifuge
    db.Filters["hearthstones"].items[117389]    = true      -- Draenor Archaeologist's Lodestone
    db.Filters["hearthstones"].items[118662]    = true      -- Bladespire Relic
    db.Filters["hearthstones"].items[118663]    = true      -- Relic of Karabor
    db.Filters["hearthstones"].items[118907]    = true      -- Pit Fighter's Punching Ring (Bizmo's Brawlpub)
    db.Filters["hearthstones"].items[118908]    = true      -- Pit Fighter's Punching Ring (Brawl'gar Arena)
    db.Filters["hearthstones"].items[119183]    = true      -- Scroll of Risky Recall
    db.Filters["hearthstones"].items[128502]    = true      -- Hunter's Seeking Crystal
    db.Filters["hearthstones"].items[128503]    = true      -- Master Hunter's Seeking Crystal
    db.Filters["hearthstones"].items[128353]    = true      -- Admiral's Compass
    db.Filters["hearthstones"].items[129276]    = true      -- Beginner's Guide to Dimensional Rifting
    db.Filters["hearthstones"].items[132119]    = true      -- Orgrimmar Portal Stone
    db.Filters["hearthstones"].items[132120]    = true      -- Stormwind Portal Stone
    db.Filters["hearthstones"].items[132517]    = true      -- Intra-Dalaran Wormhole Generator
    db.Filters["hearthstones"].items[132523]    = true      -- Reaves Battery
    db.Filters["hearthstones"].items[138448]    = true      -- Emblem of Margoss
    db.Filters["hearthstones"].items[139590]    = true      -- Scroll of Teleport: Ravenholdt
    db.Filters["hearthstones"].items[139599]    = true      -- Empowered Ring of the Kirin Tor
    db.Filters["hearthstones"].items[140192]    = true      -- Dalaran Hearthstone
    db.Filters["hearthstones"].items[140493]    = true      -- Adept's Guide to Dimensional Rifting
    db.Filters["hearthstones"].items[141013]    = true      -- Scroll of Town Portal: Shala'nir
    db.Filters["hearthstones"].items[141014]    = true      -- Scroll of Town Portal: Sashj'tar
    db.Filters["hearthstones"].items[141015]    = true      -- Scroll of Town Portal: Kal'delar
    db.Filters["hearthstones"].items[141016]    = true      -- Scroll of Town Portal: Faronaar
    db.Filters["hearthstones"].items[141017]    = true      -- Scroll of Town Portal: Lian'tril
    db.Filters["hearthstones"].items[141324]    = true      -- Talisman of the Shal'dorei
    db.Filters["hearthstones"].items[141605]    = true      -- Flight Master's Whistle
    db.Filters["hearthstones"].items[142298]    = true      -- Astonishingly Scarlet Slippers
    db.Filters["hearthstones"].items[142469]    = true      -- Violet Seal of the Grand Magus
    db.Filters["hearthstones"].items[142542]    = true      -- Tome of Town Portal (Diablo 3 event)
    db.Filters["hearthstones"].items[142543]    = true      -- Scroll of Town Portal (Diablo 3 event)
    db.Filters["hearthstones"].items[144341]    = true      -- Rechargeable Reaves Battery
    db.Filters["hearthstones"].items[144391]    = true      -- Pugilist's Powerful Punching Ring (Alliance)
    db.Filters["hearthstones"].items[144392]    = true      -- Pugilist's Powerful Punching Ring (Horde)
    db.Filters["hearthstones"].items[150733]    = true      -- Scroll of Town Portal (Ar'gorok in Arathi)
    db.Filters["hearthstones"].items[151652]    = true      -- Wormhole Generator: Argus
    db.Filters["hearthstones"].items[158897]    = true      -- Improved Flight Master's Whistle
    db.Filters["hearthstones"].items[159224]    = true      -- Zuldazar Hearthstone
    db.Filters["hearthstones"].items[160219]    = true      -- Scroll of Town Portal (Stromgarde in Arathi)
    db.Filters["hearthstones"].items[162973]    = true      -- Greatfather Winter's Hearthstone
    db.Filters["hearthstones"].items[163045]    = true      -- Headless Horseman's Hearthstone
    db.Filters["hearthstones"].items[163694]    = true      -- Scroll of Luxurious Recall
    db.Filters["hearthstones"].items[166559]    = true      -- Commander's Signet of Battle
    db.Filters["hearthstones"].items[166560]    = true      -- Captain's Signet of Command
    db.Filters["hearthstones"].items[165669]    = true      -- Lunar Elder's Hearthstone
    db.Filters["hearthstones"].items[165670]    = true      -- Peddlefeet's Lovely Hearthstone
    db.Filters["hearthstones"].items[165802]    = true      -- Noble Gardener's Hearthstone
    db.Filters["hearthstones"].items[166746]    = true      -- Fire Eater's Hearthstone
    db.Filters["hearthstones"].items[166747]    = true      -- Brewfest Reveler's Hearthstone
    db.Filters["hearthstones"].items[167065]    = true      -- Ultrasafe Transporter: Mechagon
    db.Filters["hearthstones"].items[168807]    = true      -- Wormhole Generator: Kul Tiras
    db.Filters["hearthstones"].items[168808]    = true      -- Wormhole Generator: Zandalar
    db.Filters["hearthstones"].items[168862]    = true      -- G.E.A.R. Tracking Beacon
    db.Filters["hearthstones"].items[168907]    = true      -- Holographic Digitalization Hearthstone
    db.Filters["hearthstones"].items[169064]    = true      -- Montebank's Colorful Cloak
    db.Filters["hearthstones"].items[169297]    = true      -- Stormpike Insignia
    db.Filters["hearthstones"].items[172179]    = true      -- Eternal Traveler's Hearthstone
    db.Filters["hearthstones"].items[172203]    = true      -- Cracked Hearthstone
    db.Filters["hearthstones"].items[172924]    = true      -- Wormhole Generator: Shadowlands
    db.Filters["hearthstones"].items[173373]    = true      -- Faol's Hearthstone
    db.Filters["hearthstones"].items[173430]    = true      -- Nexus Teleport Scroll
    db.Filters["hearthstones"].items[173532]    = true      -- Tirisfal Camp Scroll
    db.Filters["hearthstones"].items[173528]    = true      -- Gilded Hearthstone
    db.Filters["hearthstones"].items[173537]    = true      -- Glowing Hearthstone
    db.Filters["hearthstones"].items[173716]    = true      -- Mossy Hearthstone
    db.Filters["hearthstones"].items[180290]    = true      -- Night Fae Hearthstone
    db.Filters["hearthstones"].items[180817]    = true      -- Cypher of Relocation (Ve'nari's Refuge)
    db.Filters["hearthstones"].items[181163]    = true      -- Scroll of Teleport: Theater of Pain
    db.Filters["hearthstones"].items[182773]    = true      -- Necrolord's Hearthstone
    db.Filters["hearthstones"].items[183716]    = true      -- Venthyr Sinstone
    db.Filters["hearthstones"].items[184353]    = true      -- Kyrian Hearthstone
    db.Filters["hearthstones"].items[184500]    = true      -- Attendant's Pocket Portal: Bastion
    db.Filters["hearthstones"].items[184501]    = true      -- Attendant's Pocket Portal: Revendreth
    db.Filters["hearthstones"].items[184502]    = true      -- Attendant's Pocket Portal: Maldraxxus
    db.Filters["hearthstones"].items[184503]    = true      -- Attendant's Pocket Portal: Ardenweald
    db.Filters["hearthstones"].items[184504]    = true      -- Attendant's Pocket Portal: Oribos
    db.Filters["hearthstones"].items[188952]    = true      -- Dominated Hearthstone
    db.Filters["hearthstones"].items[189827]    = true      -- Cartel Xy's Proof of Initiation
    db.Filters["hearthstones"].items[190196]    = true      -- Enlightened Hearthstone
    db.Filters["hearthstones"].items[190237]    = true      -- Broker Translocation Matrix
    db.Filters["hearthstones"].items[191029]    = true      -- Lilian's Hearthstone
    db.Filters["hearthstones"].items[193588]    = true      -- Timewalker's Hearthstone
    db.Filters["hearthstones"].items[198156]    = true      -- Wyrmhole Generator: Dragon Isles
    db.Filters["hearthstones"].items[200630]    = true      -- Ohn'ir Windsage's Hearthstone
    db.Filters["hearthstones"].items[201957]    = true      -- Thrall's Hearthstone
    db.Filters["hearthstones"].items[202046]    = true      -- Lucky Tortollan Charm
    db.Filters["hearthstones"].items[204481]    = true      -- Morqut Hearth Totem
    db.Filters["hearthstones"].items[205255]    = true      -- Niffen Diggin' Mitts
end

-- return data to main file
addon.db = db