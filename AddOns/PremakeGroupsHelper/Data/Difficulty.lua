-------------------------------------------------------------------------------
-- Premade Groups Filter
-------------------------------------------------------------------------------
-- Copyright (C) 2020 Elotheon-Arthas-EU
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

local addonName, addon = ...
local const = addon.const or {}

local ACTIVITY_TO_DIFFICULTY = {
    -- Warlords of Draenor (raids only)
    [37]  = const.DIFFICULTY_NORMAL, -- Highmaul
    [38]  = const.DIFFICULTY_HEROIC, -- Highmaul
    [399] = const.DIFFICULTY_MYTHIC, -- Highmaul

    [39]  = const.DIFFICULTY_NORMAL, -- Blackrock Foundry
    [40]  = const.DIFFICULTY_HEROIC, -- Blackrock Foundry
    [400] = const.DIFFICULTY_MYTHIC, -- Blackrock Foundry

    [409] = const.DIFFICULTY_NORMAL, -- Hellfire Citadel
    [410] = const.DIFFICULTY_HEROIC, -- Hellfire Citadel
    [412] = const.DIFFICULTY_MYTHIC, -- Hellfire Citadel

    -- Legion
    [413] = const.DIFFICULTY_NORMAL, -- The Emerald Nightmare
    [414] = const.DIFFICULTY_HEROIC, -- The Emerald Nightmare
    [415] = const.DIFFICULTY_NORMAL, -- The Nighthold
    [416] = const.DIFFICULTY_HEROIC, -- The Nighthold

    [417] = const.DIFFICULTY_NORMAL, -- Random Dungeon
    [418] = const.DIFFICULTY_HEROIC, -- Random Dungeon

    [425] = const.DIFFICULTY_NORMAL, -- Eye of Azshara
    [426] = const.DIFFICULTY_NORMAL, -- Darkheart Thicket
    [427] = const.DIFFICULTY_NORMAL, -- Halls of Valor
    [428] = const.DIFFICULTY_NORMAL, -- Neltharion's Lair
    [429] = const.DIFFICULTY_NORMAL, -- Violet Hold
    [430] = const.DIFFICULTY_NORMAL, -- Black Rook Hold
    [431] = const.DIFFICULTY_NORMAL, -- Vault of the Wardens
    [432] = const.DIFFICULTY_NORMAL, -- Maw of Souls
    [433] = const.DIFFICULTY_NORMAL, -- Court of Stars
    [434] = const.DIFFICULTY_NORMAL, -- The Arcway

    [435] = const.DIFFICULTY_HEROIC, -- Eye of Azshara
    [436] = const.DIFFICULTY_HEROIC, -- Darkheart Thicket
    [437] = const.DIFFICULTY_HEROIC, -- Halls of Valor
    [438] = const.DIFFICULTY_HEROIC, -- Neltharion's Lair
    [439] = const.DIFFICULTY_HEROIC, -- Violet Hold
    [440] = const.DIFFICULTY_HEROIC, -- Black Rook Hold
    [441] = const.DIFFICULTY_HEROIC, -- Vault of the Wardens
    [442] = const.DIFFICULTY_HEROIC, -- Maw of Souls
    [443] = const.DIFFICULTY_HEROIC, -- Court of Stars
    [444] = const.DIFFICULTY_HEROIC, -- The Arcway

    [445] = const.DIFFICULTY_MYTHIC, -- Eye of Azshara
    [446] = const.DIFFICULTY_MYTHIC, -- Darkheart Thicket
    [447] = const.DIFFICULTY_MYTHIC, -- Halls of Valor
    [448] = const.DIFFICULTY_MYTHIC, -- Neltharion's Lair
    [449] = const.DIFFICULTY_MYTHIC, -- Violet Hold
    [450] = const.DIFFICULTY_MYTHIC, -- Black Rook Hold
    [451] = const.DIFFICULTY_MYTHIC, -- Vault of the Wardens
    [452] = const.DIFFICULTY_MYTHIC, -- Maw of Souls
    [453] = const.DIFFICULTY_MYTHIC, -- Court of Stars
    [454] = const.DIFFICULTY_MYTHIC, -- The Arcway

    [455] = const.DIFFICULTY_MYTHIC, -- Karazhan

    [456] = const.DIFFICULTY_NORMAL, -- Trial of Valor
    [457] = const.DIFFICULTY_HEROIC, -- Trial of Valor

    [458] = const.DIFFICULTY_NORMAL, -- World Bosses Legion

    [459] = const.DIFFICULTY_MYTHICPLUS, -- Eye of Azshara
    [460] = const.DIFFICULTY_MYTHICPLUS, -- Darkheart Thicket
    [461] = const.DIFFICULTY_MYTHICPLUS, -- Halls of Valor
    [462] = const.DIFFICULTY_MYTHICPLUS, -- Neltharion's Lair
    [463] = const.DIFFICULTY_MYTHICPLUS, -- Black Rook Hold
    [464] = const.DIFFICULTY_MYTHICPLUS, -- Vault of the Wardens
    [465] = const.DIFFICULTY_MYTHICPLUS, -- Maw of Souls
    [466] = const.DIFFICULTY_MYTHICPLUS, -- Court of Stars
    [467] = const.DIFFICULTY_MYTHICPLUS, -- The Arcway

    [468] = const.DIFFICULTY_MYTHIC,     -- The Emerald Nightmare

    [470] = const.DIFFICULTY_HEROIC,     -- Lower Karazhan
    [471] = const.DIFFICULTY_MYTHICPLUS, -- Lower Karazhan
    [472] = const.DIFFICULTY_HEROIC,     -- Upper Karazhan
    [473] = const.DIFFICULTY_MYTHICPLUS, -- Upper Karazhan

    [474] = const.DIFFICULTY_HEROIC,     -- Cathedral of Eternal Night
    [475] = const.DIFFICULTY_MYTHIC,     -- Cathedral of Eternal Night
    [476] = const.DIFFICULTY_MYTHICPLUS, -- Cathedral of Eternal Night

    [478] = const.DIFFICULTY_HEROIC,     -- Tomb of Sargeras
    [479] = const.DIFFICULTY_NORMAL,     -- Tomb of Sargeras

    [480] = const.DIFFICULTY_MYTHIC,     -- Trial of Valor
    [481] = const.DIFFICULTY_MYTHIC,     -- The Nighthold

    [482] = const.DIFFICULTY_NORMAL,     -- Antorus, the Burning Throne
    [483] = const.DIFFICULTY_HEROIC,     -- Antorus, the Burning Throne

    [484] = const.DIFFICULTY_HEROIC,     -- Seat of the Triumvirate
    [485] = const.DIFFICULTY_MYTHIC,     -- Seat of the Triumvirate
    [486] = const.DIFFICULTY_MYTHICPLUS, -- Seat of the Triumvirate

    [492] = const.DIFFICULTY_MYTHICPLUS, -- Tomb of Sargeras
    [493] = const.DIFFICULTY_MYTHIC,     -- Antorus, the Burning Throne

    [494] = const.DIFFICULTY_NORMAL,     -- Uldir
    [495] = const.DIFFICULTY_HEROIC,     -- Uldir
    [496] = const.DIFFICULTY_MYTHIC,     -- Uldir

    [497] = const.DIFFICULTY_NORMAL,     -- Random Normal Dungeon BfA
    [498] = const.DIFFICULTY_HEROIC,     -- Random Heroic Dungeon BfA

    [499] = const.DIFFICULTY_MYTHIC,     -- Atal'Dazar
    [500] = const.DIFFICULTY_HEROIC,     -- Atal'Dazar
    [501] = const.DIFFICULTY_NORMAL,     -- Atal'Dazar
    [502] = const.DIFFICULTY_MYTHICPLUS, -- Atal'Dazar

    [503] = const.DIFFICULTY_NORMAL,     -- Temple of Sethraliss
    [504] = const.DIFFICULTY_MYTHICPLUS, -- Temple of Sethraliss
    [505] = const.DIFFICULTY_HEROIC,     -- Temple of Sethraliss

    [506] = const.DIFFICULTY_NORMAL,     -- The Underrot
    [507] = const.DIFFICULTY_MYTHICPLUS, -- The Underrot
    [508] = const.DIFFICULTY_HEROIC,     -- The Underrot

    [509] = const.DIFFICULTY_NORMAL,     -- The MOTHERLODE
    [510] = const.DIFFICULTY_MYTHICPLUS, -- The MOTHERLODE
    [511] = const.DIFFICULTY_HEROIC,     -- The MOTHERLODE

    [512] = const.DIFFICULTY_NORMAL,     -- Kings' Rest
    [513] = const.DIFFICULTY_MYTHIC,     -- Kings' Rest
    [514] = const.DIFFICULTY_MYTHICPLUS, -- Kings' Rest
    [515] = const.DIFFICULTY_HEROIC,     -- Kings' Rest

    [516] = const.DIFFICULTY_NORMAL,     -- Freehold
    [517] = const.DIFFICULTY_MYTHIC,     -- Freehold
    [518] = const.DIFFICULTY_MYTHICPLUS, -- Freehold
    [519] = const.DIFFICULTY_HEROIC,     -- Freehold

    [520] = const.DIFFICULTY_NORMAL,     -- Shrine of the Storm
    [521] = const.DIFFICULTY_MYTHIC,     -- Shrine of the Storm
    [522] = const.DIFFICULTY_MYTHICPLUS, -- Shrine of the Storm
    [523] = const.DIFFICULTY_HEROIC,     -- Shrine of the Storm

    [524] = const.DIFFICULTY_NORMAL,     -- Tol Dagor
    [525] = const.DIFFICULTY_MYTHIC,     -- Tol Dagor
    [526] = const.DIFFICULTY_MYTHICPLUS, -- Tol Dagor
    [527] = const.DIFFICULTY_HEROIC,     -- Tol Dagor

    [528] = const.DIFFICULTY_NORMAL,     -- Waycrest Manor
    [529] = const.DIFFICULTY_MYTHIC,     -- Waycrest Manor
    [530] = const.DIFFICULTY_MYTHICPLUS, -- Waycrest Manor
    [531] = const.DIFFICULTY_HEROIC,     -- Waycrest Manor

    [532] = const.DIFFICULTY_NORMAL,     -- Siege of Boralus
    [533] = const.DIFFICULTY_MYTHIC,     -- Siege of Boralus
    [534] = const.DIFFICULTY_MYTHICPLUS, -- Siege of Boralus
    [535] = const.DIFFICULTY_HEROIC,     -- Siege of Boralus

    [536] = const.DIFFICULTY_NORMAL,     -- Waycrest Manor
    [537] = const.DIFFICULTY_NORMAL,     -- Tol Dagor
    [538] = const.DIFFICULTY_NORMAL,     -- Shrine of the Storm
    [539] = const.DIFFICULTY_NORMAL,     -- Freehold
    [540] = const.DIFFICULTY_NORMAL,     -- The MOTHERLODE
    [541] = const.DIFFICULTY_NORMAL,     -- The Underrot
    [542] = const.DIFFICULTY_NORMAL,     -- Temple of Sethraliss
    [543] = const.DIFFICULTY_NORMAL,     -- Atal'Dazar

    [644] = const.DIFFICULTY_MYTHIC,     -- The Underrot
    [645] = const.DIFFICULTY_MYTHIC,     -- Temple of Sethraliss
    [646] = const.DIFFICULTY_MYTHIC,     -- The MOTHERLODE

    [653] = const.DIFFICULTY_NORMAL,     -- Random Island
    [654] = const.DIFFICULTY_HEROIC,     -- Random Island
    [655] = const.DIFFICULTY_MYTHIC,     -- Random Island

    [658] = const.DIFFICULTY_MYTHIC,     -- Siege of Boralus
    [659] = const.DIFFICULTY_MYTHICPLUS, -- Siege of Boralus
    [660] = const.DIFFICULTY_MYTHIC,     -- Kings Rest
    [661] = const.DIFFICULTY_MYTHICPLUS, -- Kings Rest

    [663] = const.DIFFICULTY_NORMAL,     -- Battle of Dazar'alor
    [664] = const.DIFFICULTY_HEROIC,     -- Battle of Dazar'alor
    [665] = const.DIFFICULTY_MYTHIC,     -- Battle of Dazar'alor

    [666] = const.DIFFICULTY_MYTHIC,     -- Crucible of Storms
    [667] = const.DIFFICULTY_HEROIC,     -- Crucible of Storms
    [668] = const.DIFFICULTY_NORMAL,     -- Crucible of Storms
    
    [669] = const.DIFFICULTY_MYTHIC,     -- Operation: Mechagon

    [670] = const.DIFFICULTY_MYTHIC,     -- The Eternal Palace
    [671] = const.DIFFICULTY_HEROIC,     -- The Eternal Palace
    [672] = const.DIFFICULTY_NORMAL,     -- The Eternal Palace

    [679] = const.DIFFICULTY_MYTHICPLUS, -- Operation: Mechagon - Junkyard
    [682] = const.DIFFICULTY_HEROIC,     -- Operation: Mechagon - Junkyard
    [683] = const.DIFFICULTY_MYTHICPLUS, -- Operation: Mechagon - Workshop
    [684] = const.DIFFICULTY_HEROIC,     -- Operation: Mechagon - Workshop

    [685] = const.DIFFICULTY_MYTHIC,     -- Ny’alotha, the Waking City
    [686] = const.DIFFICULTY_HEROIC,     -- Ny’alotha, the Waking City
    [687] = const.DIFFICULTY_NORMAL,     -- Ny’alotha, the Waking City

    [688] = const.DIFFICULTY_NORMAL,     -- Plaguefall
    [689] = const.DIFFICULTY_HEROIC,     -- Plaguefall
    [690] = const.DIFFICULTY_MYTHIC,     -- Plaguefall
    [691] = const.DIFFICULTY_MYTHICPLUS, -- Plaguefall

    [692] = const.DIFFICULTY_NORMAL,     -- De Other Side
    [693] = const.DIFFICULTY_HEROIC,     -- De Other Side
    [694] = const.DIFFICULTY_MYTHIC,     -- De Other Side
    [695] = const.DIFFICULTY_MYTHICPLUS, -- De Other Side

    [696] = const.DIFFICULTY_NORMAL,     -- Halls of Atonement
    [697] = const.DIFFICULTY_HEROIC,     -- Halls of Atonement
    [698] = const.DIFFICULTY_MYTHIC,     -- Halls of Atonement
    [699] = const.DIFFICULTY_MYTHICPLUS, -- Halls of Atonement

    [700] = const.DIFFICULTY_NORMAL,     -- Mists of Tirna Scithe
    [701] = const.DIFFICULTY_HEROIC,     -- Mists of Tirna Scithe
    [702] = const.DIFFICULTY_MYTHIC,     -- Mists of Tirna Scithe
    [703] = const.DIFFICULTY_MYTHICPLUS, -- Mists of Tirna Scithe

    [704] = const.DIFFICULTY_NORMAL,     -- Sanguine Depths
    [707] = const.DIFFICULTY_HEROIC,     -- Sanguine Depths
    [706] = const.DIFFICULTY_MYTHIC,     -- Sanguine Depths
    [705] = const.DIFFICULTY_MYTHICPLUS, -- Sanguine Depths

    [708] = const.DIFFICULTY_NORMAL,     -- Spires of Ascension
    [711] = const.DIFFICULTY_HEROIC,     -- Spires of Ascension
    [710] = const.DIFFICULTY_MYTHIC,     -- Spires of Ascension
    [709] = const.DIFFICULTY_MYTHICPLUS, -- Spires of Ascension

    [712] = const.DIFFICULTY_NORMAL,     -- The Necrotic Wake
    [715] = const.DIFFICULTY_HEROIC,     -- The Necrotic Wake
    [714] = const.DIFFICULTY_MYTHIC,     -- The Necrotic Wake
    [713] = const.DIFFICULTY_MYTHICPLUS, -- The Necrotic Wake

    [716] = const.DIFFICULTY_NORMAL,     -- Theater of Pain
    [719] = const.DIFFICULTY_HEROIC,     -- Theater of Pain
    [718] = const.DIFFICULTY_MYTHIC,     -- Theater of Pain
    [717] = const.DIFFICULTY_MYTHICPLUS, -- Theater of Pain

    [720] = const.DIFFICULTY_NORMAL,     -- Castle Nathria
    [722] = const.DIFFICULTY_HEROIC,     -- Castle Nathria
    [721] = const.DIFFICULTY_MYTHIC,     -- Castle Nathria

    [743] = const.DIFFICULTY_NORMAL,     -- Sanctum of Domination
    [744] = const.DIFFICULTY_HEROIC,     -- Sanctum of Domination
    [745] = const.DIFFICULTY_MYTHIC,     -- Sanctum of Domination

    [746] = const.DIFFICULTY_MYTHIC,     -- Tazavesh, the Veiled Market

    [1018] = const.DIFFICULTY_HEROIC,     -- Tazavesh, the Veiled Market
    [1019] = const.DIFFICULTY_HEROIC,     -- Tazavesh, the Veiled Market

    [1016] = const.DIFFICULTY_DIFFICULTY_MYTHICPLUSMYTHIC,     -- Tazavesh, the Veiled Market
    [1017] = const.DIFFICULTY_MYTHICPLUS,     -- Tazavesh, the Veiled Market
}

-- maps localized shortNames from C_LFGList.GetActivityInfo() to difficulties
local SHORTNAME_TO_DIFFICULTY = {
    [C_LFGList.GetActivityInfoTable(46).shortName]  = const.DIFFICULTY_NORMAL,      -- 10 Normal
    [C_LFGList.GetActivityInfoTable(47).shortName]  = const.DIFFICULTY_HEROIC,      -- 10 Heroic
    [C_LFGList.GetActivityInfoTable(48).shortName]  = const.DIFFICULTY_NORMAL,      -- 25 Normal
    [C_LFGList.GetActivityInfoTable(49).shortName]  = const.DIFFICULTY_HEROIC,      -- 25 Heroic
    [C_LFGList.GetActivityInfoTable(179).shortName] = const.DIFFICULTY_CHALLENGE,   -- Challenge
    [C_LFGList.GetActivityInfoTable(425).shortName] = const.DIFFICULTY_NORMAL,      -- Normal
    [C_LFGList.GetActivityInfoTable(435).shortName] = const.DIFFICULTY_HEROIC,      -- Heroic
    [C_LFGList.GetActivityInfoTable(445).shortName] = const.DIFFICULTY_MYTHIC,      -- Mythic
    [C_LFGList.GetActivityInfoTable(459).shortName] = const.DIFFICULTY_MYTHICPLUS,  -- Mythic+
}

local function ExtractNameSuffix(name)
    if GetLocale() == "zhCN" or GetLocale() == "zhTW" then
        -- Chinese clients use different parenthesis
        return name:lower():match("[(（]([^)）]+)[)）]")
    else
        -- however we cannot use the regex above for every language
        -- because the Chinese parenthesis somehow breaks the recognition
        -- of other Western special characters such as Umlauts
        return name:lower():match("%(([^)]+)%)")
    end
end

-- maps localized name suffixes (the value in parens) from C_LFGList.GetActivityInfo() to difficulties
local NAMESUFFIX_TO_DIFFICULTY = {
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(46).fullName)]  = const.DIFFICULTY_NORMAL,      -- XXX (10 Normal)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(47).fullName)]  = const.DIFFICULTY_HEROIC,      -- XXX (10 Heroic)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(48).fullName)]  = const.DIFFICULTY_NORMAL,      -- XXX (25 Normal)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(49).fullName)]  = const.DIFFICULTY_HEROIC,      -- XXX (25 Heroic)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(179).fullName)]  = const.DIFFICULTY_CHALLENGE,      -- XXX (25 Heroic)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(425).fullName)] = const.DIFFICULTY_NORMAL,      -- XXX (Normal)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(435).fullName)] = const.DIFFICULTY_HEROIC,      -- XXX (Heroic)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(445).fullName)] = const.DIFFICULTY_MYTHIC,      -- XXX (Mythic)
    [ExtractNameSuffix(C_LFGList.GetActivityInfoTable(459).fullName)] = const.DIFFICULTY_MYTHICPLUS,  -- XXX (Mythic Keystone)
    --[PGF.ExtractNameSuffix(C_LFGList.GetActivityInfo(476))] = const.DIFFICULTY_MYTHICPLUS, -- XXX (Mythic+)
}

function addon:getDifficulty(activity, name, shortName)
    local difficulty

    difficulty = ACTIVITY_TO_DIFFICULTY[activity]
    if difficulty and difficulty ~= "" then
        return difficulty
    end

    difficulty = SHORTNAME_TO_DIFFICULTY[shortName]
    if difficulty and difficulty ~= "" then
        return difficulty
    end

    difficulty = NAMESUFFIX_TO_DIFFICULTY[ExtractNameSuffix(name)]
    if difficulty and difficulty ~= "" then
        return difficulty
    end

    return const.DIFFICULTY_NORMAL
end
