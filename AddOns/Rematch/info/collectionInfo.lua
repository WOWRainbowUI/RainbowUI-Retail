local _,rematch = ...
local L = rematch.localization
local C = rematch.constants
rematch.collectionInfo = {}

--[[
    Information about the collection, such as number of pets at 25 and such, is kept here.
]]

-- on-demand table for species at 25
local speciesAt25 = rematch.odTable:Create(function(self)
    for petID in rematch.roster:AllOwnedPets() do
        local petInfo = rematch.petInfo:Fetch(petID)
        if petInfo.level==25 then
            self[petInfo.speciesID] = true
        end
    end
end)

-- this is used for level filter "Moveset Not At 25" and is probably used even more rarely
local movesetsAt25 = rematch.odTable:Create(function(self)
    speciesAt25:Start()
    for speciesID in pairs(speciesAt25) do
        local moveset = rematch.speciesInfo:GetMoveset(speciesID)
        if moveset then
            self[moveset] = true
        end
    end
end)

-- this is used for other filter "Unique Moveset" to find all pets that have a unique moveset
local uniqueMovesets = rematch.odTable:Create(function(self)
    -- first gather a count of all movesets
    for speciesID in rematch.roster:AllSpecies() do
        local petInfo = rematch.petInfo:Fetch(speciesID)
        local moveset = petInfo.moveset
        if moveset and petInfo.canBattle then
            self[moveset] = (self[moveset] or 0) + 1
        end
    end
    -- now remove the movesets with more than 1
    for moveset,count in pairs(self) do
        if count>1 then
            self[moveset] = nil
        end
    end
end)

-- used by pet summary/statistics to break down pets
local speciesStats = rematch.odTable:Create(function(self)
    for petID in rematch.roster:AllPets() do
        local petInfo = rematch.petInfo:Fetch(petID)
        local speciesID = petInfo.speciesID
        if not self[speciesID] then
            self[speciesID] = {petInfo.petType,petInfo.sourceID,0,0,0,0,0,0,0,0}
        end
        if petInfo.isOwned then
            local info = self[speciesID]
            info[3] = info[3] + 1 -- numPets
            info[4] = info[4] + (petInfo.level==25 and 1 or 0) -- numAt25
            info[5] = info[5] + (petInfo.level or 0) -- totalLevels
            if type(petInfo.rarity)=="number" and petInfo.rarity>0 then
                info[6+petInfo.rarity] = info[5+petInfo.rarity]+1 -- rarity takes up 7th through 10th indexes
            end
        end
        -- unowned pets can be saved in a team, add those separately
        if petInfo.inTeams then
            self[speciesID][6] = self[speciesID][6] + 1
        end
    end
end)

-- returns whether the given speciesID has a version at 25
function rematch.collectionInfo:IsSpeciesAt25(speciesID)
    return speciesAt25[speciesID] or false
end

-- returns the whole lookup table of species at 25
function rematch.collectionInfo:GetAllSpeciesAt25()
    speciesAt25:Start()
    return speciesAt25
end

-- returns whether the given moveset has a pet at 25
function rematch.collectionInfo:IsMovesetAt25(moveset)
    return movesetsAt25[moveset] or false
end

-- returns whether the moveset is unique
function rematch.collectionInfo:IsMovesetUnique(moveset)
    return uniqueMovesets[moveset] and true
end

-- returns stats about all species in a lookup table by speciesID where each is an ordered list of stats:
-- [speciesID] = {petType,source,numPets,numAt25,totalLevels,numPoor,numCommon,numUncommon,numRare}
function rematch.collectionInfo:GetSpeciesStats()
    speciesStats:Start()
    return speciesStats
end
