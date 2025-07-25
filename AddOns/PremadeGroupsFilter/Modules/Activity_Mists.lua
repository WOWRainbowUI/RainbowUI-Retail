-------------------------------------------------------------------------------
-- Premade Groups Filter
-------------------------------------------------------------------------------
-- Copyright (C) 2024 Bernhard Saumweber
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-------------------------------------------------------------------------------

local PGF = select(2, ...)
local L = PGF.L
local C = PGF.C

C.ACTIVITY = {
    [ 134] = { difficulty = 1, category =   2, mapID =  645 }, -- Blackrock Caverns (Normal)
    [ 135] = { difficulty = 1, category =   2, mapID =  670 }, -- Grim Batol (Normal)
    [ 136] = { difficulty = 1, category =   2, mapID =  644 }, -- Halls of Origination (Normal)
    [ 137] = { difficulty = 1, category =   2, mapID =  725 }, -- The Stonecore (Normal)
    [ 138] = { difficulty = 1, category =   2, mapID =  657 }, -- The Vortex Pinnacle (Normal)
    [ 139] = { difficulty = 1, category =   2, mapID =  755 }, -- Lost City of the Tol'vir (Normal)
    [ 140] = { difficulty = 2, category =   2, mapID =  657 }, -- The Vortex Pinnacle (Heroic)
    [ 141] = { difficulty = 2, category =   2, mapID =  725 }, -- The Stonecore (Heroic)
    [ 142] = { difficulty = 2, category =   2, mapID =  644 }, -- Halls of Origination (Heroic)
    [ 143] = { difficulty = 2, category =   2, mapID =  670 }, -- Grim Batol (Heroic)
    [ 144] = { difficulty = 2, category =   2, mapID =  645 }, -- Blackrock Caverns (Heroic)
    [ 146] = { difficulty = 2, category =   2, mapID =  643 }, -- Throne of the Tides (Heroic)
    [ 147] = { difficulty = 2, category =   2, mapID =  755 }, -- Lost City of the Tol'vir (Heroic)
    [ 148] = { difficulty = 2, category =   2, mapID =   36 }, -- Deadmines (Heroic)
    [ 149] = { difficulty = 2, category =   2, mapID =   33 }, -- Shadowfang Keep (Heroic)
    [ 150] = { difficulty = 2, category =   2, mapID =  859 }, -- Zul'Gurub (Heroic)
    [ 151] = { difficulty = 2, category =   2, mapID =  568 }, -- Zul'Aman (Heroic)
    [ 152] = { difficulty = 2, category =   2, mapID =  938 }, -- End Time (Heroic)
    [ 153] = { difficulty = 2, category =   2, mapID =  939 }, -- Well of Eternity (Heroic)
    [ 154] = { difficulty = 2, category =   2, mapID =  940 }, -- Hour of Twilight (Heroic)
    [ 155] = { difficulty = 1, category =   2, mapID =  960 }, -- Temple of the Jade Serpent (Normal)
    [ 156] = { difficulty = 1, category =   2, mapID =  961 }, -- Stormstout Brewery (Normal)
    [ 157] = { difficulty = 1, category =   2, mapID =  959 }, -- Shado-Pan Monastery (Normal)
    [ 158] = { difficulty = 1, category =   2, mapID =  994 }, -- Mogu'shan Palace (Normal)
    [ 159] = { difficulty = 1, category =   2, mapID = 1011 }, -- Siege of Niuzao Temple (Normal)
    [ 160] = { difficulty = 1, category =   2, mapID =  962 }, -- Gate of the Setting Sun (Normal)
    [ 163] = { difficulty = 2, category =   2, mapID =  960 }, -- Temple of the Jade Serpent (Heroic)
    [ 164] = { difficulty = 2, category =   2, mapID =  961 }, -- Stormstout Brewery (Heroic)
    [ 165] = { difficulty = 2, category =   2, mapID =  959 }, -- Shado-Pan Monastery (Heroic)
    [ 166] = { difficulty = 2, category =   2, mapID =  994 }, -- Mogu'shan Palace (Heroic)
    [ 167] = { difficulty = 2, category =   2, mapID =  962 }, -- Gate of the Setting Sun (Heroic)
    [ 168] = { difficulty = 1, category =   2, mapID = 1007 }, -- Scholomance (Heroic)
    [ 169] = { difficulty = 2, category =   2, mapID = 1004 }, -- Scarlet Monastery (Heroic)
    [ 170] = { difficulty = 2, category =   2, mapID = 1001 }, -- Scarlet Halls (Heroic)
    [ 171] = { difficulty = 2, category =   2, mapID = 1011 }, -- Siege of Niuzao Temple (Heroic)
    [ 331] = { difficulty = 1, category = 114, mapID =  967 }, -- Dragon Soul (10 Normal)
    [ 332] = { difficulty = 2, category = 114, mapID =  967 }, -- Dragon Soul (10 Heroic)
    [ 333] = { difficulty = 2, category = 114, mapID =  967 }, -- Dragon Soul (25 Heroic)
    [ 334] = { difficulty = 1, category = 114, mapID =  967 }, -- Dragon Soul (25 Normal)
    [ 335] = { difficulty = 1, category = 114, mapID = 1008 }, -- Mogu'shan Vaults (10 Normal)
    [ 336] = { difficulty = 2, category = 114, mapID = 1008 }, -- Mogu'shan Vaults (10 Heroic)
    [ 337] = { difficulty = 1, category = 114, mapID = 1008 }, -- Mogu'shan Vaults (25 Normal)
    [ 338] = { difficulty = 2, category = 114, mapID = 1008 }, -- Mogu'shan Vaults (25 Heroic)
    [ 339] = { difficulty = 1, category = 114, mapID = 1009 }, -- Heart of Fear (10 Normal)
    [ 340] = { difficulty = 2, category = 114, mapID = 1009 }, -- Heart of Fear (10 Heroic)
    [ 341] = { difficulty = 1, category = 114, mapID = 1009 }, -- Heart of Fear (25 Normal)
    [ 342] = { difficulty = 2, category = 114, mapID = 1009 }, -- Heart of Fear (25 Heroic)
    [ 343] = { difficulty = 1, category = 114, mapID =  996 }, -- Terrace of Endless Spring (10 Normal)
    [ 344] = { difficulty = 2, category = 114, mapID =  996 }, -- Terrace of Endless Spring (10 Heroic)
    [ 345] = { difficulty = 1, category = 114, mapID =  996 }, -- Terrace of Endless Spring (25 Normal)
    [ 346] = { difficulty = 2, category = 114, mapID =  996 }, -- Terrace of Endless Spring (25 Heroic)
    [ 347] = { difficulty = 1, category = 114, mapID = 1098 }, -- Throne of Thunder (10 Normal)
    [ 348] = { difficulty = 2, category = 114, mapID = 1098 }, -- Throne of Thunder (10 Heroic)
    [ 349] = { difficulty = 2, category = 114, mapID = 1098 }, -- Throne of Thunder (25 Heroic)
    [ 350] = { difficulty = 1, category = 114, mapID = 1098 }, -- Throne of Thunder (25 Normal)
    [ 796] = { difficulty = 1, category =   2, mapID =   43 }, -- Wailing Caverns
    [ 797] = { difficulty = 1, category =   2, mapID =  289 }, -- Scholomance
    [ 798] = { difficulty = 1, category =   2, mapID =  389 }, -- Ragefire Chasm
    [ 799] = { difficulty = 1, category =   2, mapID =   36 }, -- Deadmines
    [ 800] = { difficulty = 1, category =   2, mapID =   33 }, -- Shadowfang Keep
    [ 801] = { difficulty = 1, category =   2, mapID =   48 }, -- Blackfathom Deeps
    [ 802] = { difficulty = 1, category =   2, mapID =   34 }, -- Stormwind Stockades
    [ 803] = { difficulty = 1, category =   2, mapID =   90 }, -- Gnomeregan
    [ 804] = { difficulty = 1, category =   2, mapID =   47 }, -- Razorfen Kraul
    [ 805] = { difficulty = 1, category =   2, mapID =  189 }, -- Scarlet Monastery - Graveyard
    [ 806] = { difficulty = 1, category =   2, mapID =  129 }, -- Razorfen Downs
    [ 807] = { difficulty = 1, category =   2, mapID =   70 }, -- Uldaman
    [ 808] = { difficulty = 1, category =   2, mapID =  209 }, -- Zul'Farrak
    [ 809] = { difficulty = 1, category =   2, mapID =  349 }, -- Maraudon
    [ 810] = { difficulty = 1, category =   2, mapID =  109 }, -- Sunken Temple
    [ 811] = { difficulty = 1, category =   2, mapID =  230 }, -- Blackrock Depths
    [ 812] = { difficulty = 1, category =   2, mapID =  229 }, -- Lower Blackrock Spire
    [ 813] = { difficulty = 1, category =   2, mapID =  429 }, -- Dire Maul - East
    [ 814] = { difficulty = 1, category =   2, mapID =  429 }, -- Dire Maul - West
    [ 815] = { difficulty = 1, category =   2, mapID =  429 }, -- Dire Maul - North
    [ 816] = { difficulty = 1, category =   2, mapID =  329 }, -- Stratholme
    [ 817] = { difficulty = 1, category =   2, mapID =  543 }, -- Hellfire Ramparts (Normal)
    [ 818] = { difficulty = 1, category =   2, mapID =  542 }, -- Blood Furnace (Normal)
    [ 819] = { difficulty = 1, category =   2, mapID =  540 }, -- Shattered Halls (Normal)
    [ 820] = { difficulty = 1, category =   2, mapID =  547 }, -- Slave Pens (Normal)
    [ 821] = { difficulty = 1, category =   2, mapID =  546 }, -- Coilfang - Underbog (Normal)
    [ 822] = { difficulty = 1, category =   2, mapID =  545 }, -- The Steamvault (Normal)
    [ 823] = { difficulty = 1, category =   2, mapID =  557 }, -- Mana-Tombs (Normal)
    [ 824] = { difficulty = 1, category =   2, mapID =  558 }, -- Auchenai Crypts (Normal)
    [ 825] = { difficulty = 1, category =   2, mapID =  556 }, -- Sethekk Halls (Normal)
    [ 826] = { difficulty = 1, category =   2, mapID =  555 }, -- Shadow Labyrinth (Normal)
    [ 827] = { difficulty = 1, category =   2, mapID =  189 }, -- Scarlet Monastery - Armory
    [ 828] = { difficulty = 1, category =   2, mapID =  189 }, -- Scarlet Monastery - Cathedral
    [ 829] = { difficulty = 1, category =   2, mapID =  189 }, -- Scarlet Monastery - Library
    [ 830] = { difficulty = 1, category =   2, mapID =  560 }, -- The Escape From Durnholde (Normal)
    [ 831] = { difficulty = 1, category =   2, mapID =  269 }, -- The Black Morass (Normal)
    [ 832] = { difficulty = 1, category =   2, mapID =  554 }, -- The Mechanar (Normal)
    [ 833] = { difficulty = 1, category =   2, mapID =  553 }, -- The Botanica (Normal)
    [ 834] = { difficulty = 1, category =   2, mapID =  552 }, -- The Arcatraz (Normal)
    [ 835] = { difficulty = 1, category =   2, mapID =  585 }, -- Magisters' Terrace (Normal)
    [ 836] = { difficulty = 1, category = 114, mapID =  309 }, -- Zul'Gurub
    [ 837] = { difficulty = 1, category = 114, mapID =  229 }, -- Upper Blackrock Spire
    [ 838] = { difficulty = 1, category = 114, mapID =  249 }, -- Onyxia's Lair
    [ 839] = { difficulty = 1, category = 114, mapID =  409 }, -- Molten Core
    [ 840] = { difficulty = 1, category = 114, mapID =  469 }, -- Blackwing Lair
    [ 841] = { difficulty = 1, category = 114, mapID =  533 }, -- Naxxramas (10 Normal)
    [ 842] = { difficulty = 1, category = 114, mapID =  509 }, -- Ahn'Qiraj Ruins
    [ 843] = { difficulty = 1, category = 114, mapID =  531 }, -- Ahn'Qiraj Temple
    [ 844] = { difficulty = 1, category = 114, mapID =  532 }, -- Karazhan
    [ 845] = { difficulty = 1, category = 114, mapID =  544 }, -- Magtheridon's Lair
    [ 846] = { difficulty = 1, category = 114, mapID =  565 }, -- Gruul's Lair
    [ 847] = { difficulty = 1, category = 114, mapID =  550 }, -- Tempest Keep
    [ 848] = { difficulty = 1, category = 114, mapID =  548 }, -- Serpentshrine Cavern
    [ 849] = { difficulty = 1, category = 114, mapID =  534 }, -- Hyjal Past
    [ 850] = { difficulty = 1, category = 114, mapID =  564 }, -- Black Temple
    [ 851] = { difficulty = 1, category = 114, mapID =  568 }, -- Zul'Aman
    [ 852] = { difficulty = 1, category = 114, mapID =  580 }, -- The Sunwell
    [ 903] = { difficulty = 2, category =   2, mapID =  558 }, -- Auchenai Crypts (Heroic)
    [ 904] = { difficulty = 2, category =   2, mapID =  557 }, -- Mana-Tombs (Heroic)
    [ 905] = { difficulty = 2, category =   2, mapID =  556 }, -- Sethekk Halls (Heroic)
    [ 906] = { difficulty = 2, category =   2, mapID =  555 }, -- Shadow Labyrinth (Heroic)
    [ 907] = { difficulty = 2, category =   2, mapID =  269 }, -- The Black Morass (Heroic)
    [ 908] = { difficulty = 2, category =   2, mapID =  560 }, -- The Escape From Durnholde (Heroic)
    [ 909] = { difficulty = 2, category =   2, mapID =  547 }, -- Slave Pens (Heroic)
    [ 910] = { difficulty = 2, category =   2, mapID =  545 }, -- The Steamvault (Heroic)
    [ 911] = { difficulty = 2, category =   2, mapID =  546 }, -- Underbog (Heroic)
    [ 912] = { difficulty = 2, category =   2, mapID =  542 }, -- Blood Furnace (Heroic)
    [ 913] = { difficulty = 2, category =   2, mapID =  543 }, -- Hellfire Ramparts (Heroic)
    [ 914] = { difficulty = 2, category =   2, mapID =  540 }, -- Shattered Halls (Heroic)
    [ 915] = { difficulty = 2, category =   2, mapID =  552 }, -- The Arcatraz (Heroic)
    [ 916] = { difficulty = 2, category =   2, mapID =  554 }, -- The Mechanar (Heroic)
    [ 917] = { difficulty = 2, category =   2, mapID =  585 }, -- Magisters' Terrace (Heroic)
    [ 918] = { difficulty = 2, category =   2, mapID =  553 }, -- The Botanica (Heroic)
    [1065] = { difficulty = 1, category =   2, mapID =  595 }, -- The Culling of Stratholme (Normal)
    [1066] = { difficulty = 1, category =   2, mapID =  601 }, -- Azjol-Nerub (Normal)
    [1067] = { difficulty = 1, category =   2, mapID =  578 }, -- The Oculus (Normal)
    [1068] = { difficulty = 1, category =   2, mapID =  602 }, -- Halls of Lightning (Normal)
    [1069] = { difficulty = 1, category =   2, mapID =  599 }, -- Halls of Stone (Normal)
    [1070] = { difficulty = 1, category =   2, mapID =  600 }, -- Drak'Tharon Keep (Normal)
    [1071] = { difficulty = 1, category =   2, mapID =  604 }, -- Gundrak (Normal)
    [1072] = { difficulty = 1, category =   2, mapID =  619 }, -- Ahn'kahet: The Old Kingdom (Normal)
    [1073] = { difficulty = 1, category =   2, mapID =  608 }, -- Violet Hold (Normal)
    [1074] = { difficulty = 1, category =   2, mapID =  574 }, -- Utgarde Keep (Normal)
    [1075] = { difficulty = 1, category =   2, mapID =  575 }, -- Utgarde Pinnacle (Normal)
    [1076] = { difficulty = 1, category =   2, mapID =  650 }, -- Trial of the Champion (Normal)
    [1077] = { difficulty = 1, category =   2, mapID =  576 }, -- The Nexus (Normal)
    [1078] = { difficulty = 1, category =   2, mapID =  632 }, -- The Forge of Souls (Normal)
    [1079] = { difficulty = 1, category =   2, mapID =  658 }, -- Pit of Saron (Normal)
    [1080] = { difficulty = 1, category =   2, mapID =  668 }, -- Halls of Reflection (Normal)
    [1081] = { difficulty = 1, category =   2, mapID =  189 }, -- The Headless Horseman
    [1082] = { difficulty = 1, category =   2, mapID =  547 }, -- The Frost Lord Ahune
    [1083] = { difficulty = 1, category =   2, mapID =  230 }, -- Coren Direbrew
    [1084] = { difficulty = 1, category =   2, mapID =   33 }, -- The Crown Chemical Co.
    [1094] = { difficulty = 1, category = 114, mapID =  616 }, -- The Eye of Eternity (25 Normal)
    [1095] = { difficulty = 1, category = 114, mapID =  624 }, -- Vault of Archavon (10 Normal)
    [1096] = { difficulty = 1, category = 114, mapID =  624 }, -- Vault of Archavon (25 Normal)
    [1097] = { difficulty = 1, category = 114, mapID =  615 }, -- The Obsidian Sanctum (25 Normal)
    [1098] = { difficulty = 1, category = 114, mapID =  533 }, -- Naxxramas (25 Normal)
    [1099] = { difficulty = 1, category = 114, mapID =  249 }, -- Onyxia's Lair (25 Normal)
    [1100] = { difficulty = 1, category = 114, mapID =  649 }, -- Trial of the Crusader (10 Normal)
    [1101] = { difficulty = 1, category = 114, mapID =  615 }, -- The Obsidian Sanctum (10 Normal)
    [1102] = { difficulty = 1, category = 114, mapID =  616 }, -- The Eye of Eternity (10 Normal)
    [1103] = { difficulty = 2, category = 114, mapID =  649 }, -- Trial of the Grand Crusader (10 Normal)
    [1104] = { difficulty = 1, category = 114, mapID =  649 }, -- Trial of the Crusader (25 Normal)
    [1105] = { difficulty = 2, category = 114, mapID =  649 }, -- Trial of the Grand Crusader (25 Normal)
    [1106] = { difficulty = 1, category = 114, mapID =  603 }, -- Ulduar (10 Normal)
    [1107] = { difficulty = 1, category = 114, mapID =  603 }, -- Ulduar (25 Normal)
    [1108] = { difficulty = 1, category = 114, mapID =  724 }, -- Ruby Sanctum (10 Normal)
    [1109] = { difficulty = 1, category = 114, mapID =  724 }, -- Ruby Sanctum (25 Normal)
    [1110] = { difficulty = 1, category = 114, mapID =  631 }, -- Icecrown Citadel (10 Normal)
    [1111] = { difficulty = 1, category = 114, mapID =  631 }, -- Icecrown Citadel (25 Normal)
    [1121] = { difficulty = 2, category =   2, mapID =  601 }, -- Azjol-Nerub (Heroic)
    [1122] = { difficulty = 2, category =   2, mapID =  574 }, -- Utgarde Keep (Heroic)
    [1123] = { difficulty = 2, category =   2, mapID =  608 }, -- Violet Hold (Heroic)
    [1124] = { difficulty = 2, category =   2, mapID =  578 }, -- The Oculus (Heroic)
    [1125] = { difficulty = 2, category =   2, mapID =  575 }, -- Utgarde Pinnacle (Heroic)
    [1126] = { difficulty = 2, category =   2, mapID =  595 }, -- The Culling of Stratholme (Heroic)
    [1127] = { difficulty = 2, category =   2, mapID =  602 }, -- Halls of Lightning (Heroic)
    [1128] = { difficulty = 2, category =   2, mapID =  599 }, -- Halls of Stone (Heroic)
    [1129] = { difficulty = 2, category =   2, mapID =  600 }, -- Drak'Tharon Keep (Heroic)
    [1130] = { difficulty = 2, category =   2, mapID =  604 }, -- Gundrak (Heroic)
    [1131] = { difficulty = 2, category =   2, mapID =  619 }, -- Ahn'kahet: The Old Kingdom (Heroic)
    [1132] = { difficulty = 2, category =   2, mapID =  576 }, -- The Nexus (Heroic)
    [1133] = { difficulty = 2, category =   2, mapID =  650 }, -- Trial of the Champion (Heroic)
    [1134] = { difficulty = 2, category =   2, mapID =  632 }, -- The Forge of Souls (Heroic)
    [1135] = { difficulty = 2, category =   2, mapID =  658 }, -- Pit of Saron (Heroic)
    [1136] = { difficulty = 2, category =   2, mapID =  668 }, -- Halls of Reflection (Heroic)
    [1156] = { difficulty = 1, category = 114, mapID =  249 }, -- Onyxia's Lair (10 Normal)
    [1197] = { difficulty = 2, category =   2, mapID =  576 }, -- The Nexus (Titan Rune Alpha)
    [1198] = { difficulty = 2, category =   2, mapID =  619 }, -- Ahn'kahet: The Old Kingdom (Titan Rune Alpha)
    [1199] = { difficulty = 2, category =   2, mapID =  604 }, -- Gundrak (Titan Rune Alpha)
    [1200] = { difficulty = 2, category =   2, mapID =  600 }, -- Drak'Tharon Keep (Titan Rune Alpha)
    [1201] = { difficulty = 2, category =   2, mapID =  599 }, -- Halls of Stone (Titan Rune Alpha)
    [1202] = { difficulty = 2, category =   2, mapID =  602 }, -- Halls of Lightning (Titan Rune Alpha)
    [1203] = { difficulty = 2, category =   2, mapID =  595 }, -- The Culling of Stratholme (Titan Rune Alpha)
    [1204] = { difficulty = 2, category =   2, mapID =  575 }, -- Utgarde Pinnacle (Titan Rune Alpha)
    [1205] = { difficulty = 2, category =   2, mapID =  578 }, -- The Oculus (Titan Rune Alpha)
    [1206] = { difficulty = 2, category =   2, mapID =  608 }, -- Violet Hold (Titan Rune Alpha)
    [1207] = { difficulty = 2, category =   2, mapID =  574 }, -- Utgarde Keep (Titan Rune Alpha)
    [1208] = { difficulty = 2, category =   2, mapID =  601 }, -- Azjol-Nerub (Titan Rune Alpha)
    [1209] = { difficulty = 2, category =   2, mapID =  608 }, -- Violet Hold (Titan Rune Beta)
    [1210] = { difficulty = 2, category =   2, mapID =  575 }, -- Utgarde Pinnacle (Titan Rune Beta)
    [1211] = { difficulty = 2, category =   2, mapID =  574 }, -- Utgarde Keep (Titan Rune Beta)
    [1212] = { difficulty = 2, category =   2, mapID =  578 }, -- The Oculus (Titan Rune Beta)
    [1213] = { difficulty = 2, category =   2, mapID =  576 }, -- The Nexus (Titan Rune Beta)
    [1214] = { difficulty = 2, category =   2, mapID =  595 }, -- The Culling of Stratholme (Titan Rune Beta)
    [1215] = { difficulty = 2, category =   2, mapID =  599 }, -- Halls of Stone (Titan Rune Beta)
    [1216] = { difficulty = 2, category =   2, mapID =  602 }, -- Halls of Lightning (Titan Rune Beta)
    [1217] = { difficulty = 2, category =   2, mapID =  604 }, -- Gundrak (Titan Rune Beta)
    [1218] = { difficulty = 2, category =   2, mapID =  600 }, -- Drak'Tharon Keep (Titan Rune Beta)
    [1219] = { difficulty = 2, category =   2, mapID =  601 }, -- Azjol-Nerub (Titan Rune Beta)
    [1220] = { difficulty = 2, category =   2, mapID =  619 }, -- Ahn'kahet: The Old Kingdom (Titan Rune Beta)
    [1223] = { difficulty = 2, category =   2, mapID =  608 }, -- Violet Hold (Titan Rune Gamma)
    [1224] = { difficulty = 2, category =   2, mapID =  575 }, -- Utgarde Pinnacle (Titan Rune Gamma)
    [1225] = { difficulty = 2, category =   2, mapID =  574 }, -- Utgarde Keep (Titan Rune Gamma)
    [1226] = { difficulty = 2, category =   2, mapID =  578 }, -- The Oculus (Titan Rune Gamma)
    [1227] = { difficulty = 2, category =   2, mapID =  576 }, -- The Nexus (Titan Rune Gamma)
    [1228] = { difficulty = 2, category =   2, mapID =  595 }, -- The Culling of Stratholme (Titan Rune Gamma)
    [1229] = { difficulty = 2, category =   2, mapID =  599 }, -- Halls of Stone (Titan Rune Gamma)
    [1230] = { difficulty = 2, category =   2, mapID =  602 }, -- Halls of Lightning (Titan Rune Gamma)
    [1231] = { difficulty = 2, category =   2, mapID =  604 }, -- Gundrak (Titan Rune Gamma)
    [1232] = { difficulty = 2, category =   2, mapID =  600 }, -- Drak'Tharon Keep (Titan Rune Gamma)
    [1233] = { difficulty = 2, category =   2, mapID =  601 }, -- Azjol-Nerub (Titan Rune Gamma)
    [1234] = { difficulty = 2, category =   2, mapID =  619 }, -- Ahn'kahet: The Old Kingdom (Titan Rune Gamma)
    [1238] = { difficulty = 2, category =   2, mapID =  650 }, -- Trial of the Champion (Titan Rune Beta)
    [1239] = { difficulty = 2, category =   2, mapID =  650 }, -- Trial of the Champion (Titan Rune Gamma)
    [1240] = { difficulty = 2, category =   2, mapID =  632 }, -- The Forge of Souls (Titan Rune Gamma)
    [1241] = { difficulty = 2, category =   2, mapID =  658 }, -- Pit of Saron (Titan Rune Gamma)
    [1242] = { difficulty = 2, category =   2, mapID =  668 }, -- Halls of Reflection (Titan Rune Gamma)
    [1254] = { difficulty = 2, category = 114, mapID =  249 }, -- Onyxia's Lair (10 Heroic)
    [1255] = { difficulty = 2, category = 114, mapID =  631 }, -- Icecrown Citadel (10 Heroic)
    [1256] = { difficulty = 2, category = 114, mapID =  724 }, -- Ruby Sanctum (10 Heroic)
    [1257] = { difficulty = 2, category = 114, mapID =  603 }, -- Ulduar (10 Heroic)
    [1258] = { difficulty = 2, category = 114, mapID =  649 }, -- Trial of the Grand Crusader (10 Heroic)
    [1259] = { difficulty = 2, category = 114, mapID =  616 }, -- The Eye of Eternity (10 Heroic)
    [1260] = { difficulty = 2, category = 114, mapID =  615 }, -- The Obsidian Sanctum (10 Heroic)
    [1261] = { difficulty = 2, category = 114, mapID =  649 }, -- Trial of the Crusader (10 Heroic)
    [1262] = { difficulty = 2, category = 114, mapID =  624 }, -- Vault of Archavon (10 Heroic)
    [1263] = { difficulty = 2, category = 114, mapID =  533 }, -- Naxxramas (10 Heroic)
    [1264] = { difficulty = 2, category = 114, mapID =  631 }, -- Icecrown Citadel (25 Heroic)
    [1265] = { difficulty = 2, category = 114, mapID =  724 }, -- Ruby Sanctum (25 Heroic)
    [1266] = { difficulty = 2, category = 114, mapID =  603 }, -- Ulduar (25 Heroic)
    [1267] = { difficulty = 2, category = 114, mapID =  649 }, -- Trial of the Grand Crusader (25 Heroic)
    [1268] = { difficulty = 2, category = 114, mapID =  649 }, -- Trial of the Crusader (25 Heroic)
    [1269] = { difficulty = 2, category = 114, mapID =  249 }, -- Onyxia's Lair (25 Heroic)
    [1270] = { difficulty = 2, category = 114, mapID =  533 }, -- Naxxramas (25 Heroic)
    [1271] = { difficulty = 2, category = 114, mapID =  615 }, -- The Obsidian Sanctum (25 Heroic)
    [1272] = { difficulty = 2, category = 114, mapID =  624 }, -- Vault of Archavon (25 Heroic)
    [1273] = { difficulty = 2, category = 114, mapID =  616 }, -- The Eye of Eternity (25 Heroic)
    [1517] = { difficulty = 1, category = 114, mapID =  732 }, -- Baradin Hold (10 Normal)
    [1522] = { difficulty = 1, category = 114, mapID =  732 }, -- Baradin Hold (25 Normal)
    [1523] = { difficulty = 1, category = 114, mapID =  669 }, -- Blackwing Descent (10 Normal)
    [1524] = { difficulty = 1, category = 114, mapID =  669 }, -- Blackwing Descent (25 Normal)
    [1525] = { difficulty = 2, category = 114, mapID =  669 }, -- Blackwing Descent (10 Heroic)
    [1526] = { difficulty = 2, category = 114, mapID =  669 }, -- Blackwing Descent (25 Heroic)
    [1527] = { difficulty = 1, category = 114, mapID =  671 }, -- The Bastion of Twilight (10 Normal)
    [1528] = { difficulty = 1, category = 114, mapID =  671 }, -- The Bastion of Twilight (25 Normal)
    [1529] = { difficulty = 2, category = 114, mapID =  671 }, -- The Bastion of Twilight (10 Heroic)
    [1530] = { difficulty = 2, category = 114, mapID =  671 }, -- The Bastion of Twilight (25 Heroic)
    [1531] = { difficulty = 1, category = 114, mapID =  754 }, -- Throne of the Four Winds (10 Normal)
    [1532] = { difficulty = 1, category = 114, mapID =  754 }, -- Throne of the Four Winds (25 Normal)
    [1533] = { difficulty = 2, category = 114, mapID =  754 }, -- Throne of the Four Winds (10 Heroicl)
    [1534] = { difficulty = 2, category = 114, mapID =  754 }, -- Throne of the Four Winds (25 Heroic)
    [1586] = { difficulty = 1, category = 114, mapID =  720 }, -- Firelands (10 Normal)
    [1587] = { difficulty = 1, category = 114, mapID =  720 }, -- Firelands (25 Normal)
    [1588] = { difficulty = 2, category = 114, mapID =  720 }, -- Firelands (10 Heroic)
    [1589] = { difficulty = 2, category = 114, mapID =  720 }, -- Firelands (25 Heroic)
    [1590] = { difficulty = 2, category =   2, mapID =  643 }, -- Throne of the Tides (Elemental Rune Inferno)
    [1591] = { difficulty = 2, category =   2, mapID =  657 }, -- The Vortex Pinnacle (Elemental Rune Inferno)
    [1592] = { difficulty = 2, category =   2, mapID =  725 }, -- The Stonecore (Elemental Rune Inferno)
    [1593] = { difficulty = 2, category =   2, mapID =   33 }, -- Shadowfang Keep (Elemental Rune Inferno)
    [1594] = { difficulty = 2, category =   2, mapID =  755 }, -- Lost City of the Tol'vir (Elemental Rune Inferno)
    [1595] = { difficulty = 2, category =   2, mapID =  644 }, -- Halls of Origination (Elemental Rune Inferno)
    [1596] = { difficulty = 2, category =   2, mapID =  670 }, -- Grim Batol (Elemental Rune Inferno)
    [1597] = { difficulty = 2, category =   2, mapID =   36 }, -- Deadmines (Elemental Rune Inferno)
    [1598] = { difficulty = 2, category =   2, mapID =  645 }, -- Blackrock Caverns (Elemental Rune Inferno)
    [1684] = { difficulty = 2, category =   2, mapID =  643 }, -- Throne of the Tides (Elemental Rune Twilight)
    [1685] = { difficulty = 2, category =   2, mapID =  657 }, -- The Vortex Pinnacle (Elemental Rune Twilight)
    [1686] = { difficulty = 2, category =   2, mapID =  725 }, -- The Stonecore (Elemental Rune Twilight)
    [1687] = { difficulty = 2, category =   2, mapID =   33 }, -- Shadowfang Keep (Elemental Rune Twilight)
    [1688] = { difficulty = 2, category =   2, mapID =  755 }, -- Lost City of the Tol'vir (Elemental Rune Twilight)
    [1689] = { difficulty = 2, category =   2, mapID =  644 }, -- Halls of Origination (Elemental Rune Twilight)
    [1690] = { difficulty = 2, category =   2, mapID =  670 }, -- Grim Batol (Elemental Rune Twilight)
    [1691] = { difficulty = 2, category =   2, mapID =   36 }, -- Deadmines (Elemental Rune Twilight)
    [1692] = { difficulty = 2, category =   2, mapID =  645 }, -- Blackrock Caverns (Elemental Rune Twilight)
    [1696] = { difficulty = 2, category =   2, mapID =  938 }, -- End Time (Elemental Rune Twilight)
    [1697] = { difficulty = 2, category =   2, mapID =  940 }, -- Hour of Twilight (Elemental Rune Twilight)
    [1698] = { difficulty = 2, category =   2, mapID =  939 }, -- Well of Eternity (Elemental Rune Twilight)
    [1725] = { difficulty = 4, category =   2, mapID = 1011 }, -- Siege of Niuzao Temple (Challenge)
    [1726] = { difficulty = 4, category =   2, mapID = 1007 }, -- Scholomance (Challenge)
    [1727] = { difficulty = 4, category =   2, mapID =  959 }, -- Shado-Pan Monastery (Challenge)
    [1728] = { difficulty = 4, category =   2, mapID =  961 }, -- Stormstout Brewery (Challenge)
    [1729] = { difficulty = 4, category =   2, mapID =  962 }, -- Gate of the Setting Sun (Challenge)
    [1730] = { difficulty = 4, category =   2, mapID =  960 }, -- Temple of the Jade Serpent (Challenge)
    [1731] = { difficulty = 4, category =   2, mapID = 1001 }, -- Scarlet Halls (Challenge)
    [1732] = { difficulty = 4, category =   2, mapID = 1004 }, -- Scarlet Monastery (Challenge)
    [1733] = { difficulty = 4, category =   2, mapID =  994 }, -- Mogu'shan Palace (Challenge)
}

-- Return a default set if activity not found
setmetatable(C.ACTIVITY, { __index = function() return { difficulty = 0, category = 0, mapID = 0 } end })
