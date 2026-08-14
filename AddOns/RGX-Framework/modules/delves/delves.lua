--=====================================================================================
-- RGX-Framework | RGXDelves
-- Delve companion and lives-remaining callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local Delves = {
    _eventsInit = false,
    _onCompanionLevelUp = {},
    _onLifeLost = {},
    _onLifeGained = {},
    cachedCompanionFactionID = nil,
    lastCompanionLevel = nil,
    cachedLivesRemaining = nil,
    pendingLivesRefresh = false,
}

local DELVE_LIVES_SPELL_ID = 458103
local DELVE_LIVES_RECHECK_DELAY_SECONDS = 0.10

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    list[#list + 1] = fn
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXDelves] Callback error: " .. tostring(err)) end
    end
end

local function GetAuraStackCount(aura)
    if type(aura) ~= "table" then return nil end
    if type(aura.applications) == "number" then return aura.applications end
    if type(aura.stackCount) == "number" then return aura.stackCount end
    if type(aura.charges) == "number" then return aura.charges end
    if type(aura.points) == "table" then
        for _, value in ipairs(aura.points) do
            if type(value) == "number" then return value end
        end
    end
    return 0
end

function Delves:OnCompanionLevelUp(fn) return AddCb(self._onCompanionLevelUp, fn) end
function Delves:OnLifeLost(fn) return AddCb(self._onLifeLost, fn) end
function Delves:OnLifeGained(fn) return AddCb(self._onLifeGained, fn) end

function Delves:GetCompanionFactionID()
    if not C_DelvesUI then return nil end
    if C_DelvesUI.GetFactionForCompanion then
        local id = C_DelvesUI.GetFactionForCompanion()
        if id and id > 0 then return id end
    end
    if C_DelvesUI.GetDelvesFactionForSeason then
        local id = C_DelvesUI.GetDelvesFactionForSeason()
        if id and id > 0 then return id end
    end
end

function Delves:GetCompanionLevel()
    local factionID = self.cachedCompanionFactionID or self:GetCompanionFactionID()
    if not factionID then return nil, nil end
    self.cachedCompanionFactionID = factionID

    if C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks then
        local info = C_GossipInfo.GetFriendshipReputationRanks(factionID)
        if info and info.currentLevel then return info.currentLevel, factionID end
    end

    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        local info = C_MajorFactions.GetMajorFactionData(factionID)
        if info and info.renownLevel then return info.renownLevel, factionID end
    end
end

function Delves:UpdateCompanionCache()
    local level, factionID = self:GetCompanionLevel()
    if factionID then self.cachedCompanionFactionID = factionID end
    if level then self.lastCompanionLevel = level end
end

function Delves:CheckCompanionLevel(expectedFactionID)
    local currentLevel, factionID = self:GetCompanionLevel()
    if not factionID or not currentLevel then return end
    if expectedFactionID and expectedFactionID ~= factionID then return end

    local oldLevel = self.lastCompanionLevel
    self.lastCompanionLevel = currentLevel
    if oldLevel and currentLevel > oldLevel then
        Fire(self._onCompanionLevelUp, currentLevel, oldLevel, factionID)
    end
end

function Delves:GetLivesRemaining()
    if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return nil end
    return GetAuraStackCount(C_UnitAuras.GetPlayerAuraBySpellID(DELVE_LIVES_SPELL_ID))
end

function Delves:RefreshLives()
    local current = self:GetLivesRemaining()
    local previous = self.cachedLivesRemaining

    if current == nil then
        self.cachedLivesRemaining = nil
        return
    end

    if previous ~= nil then
        if current < previous then
            Fire(self._onLifeLost, current, previous)
        elseif current > previous then
            Fire(self._onLifeGained, current, previous)
        end
    end

    self.cachedLivesRemaining = current
end

function Delves:QueueLivesRefresh(delay)
    if self.pendingLivesRefresh then return end
    self.pendingLivesRefresh = true
    RGX:After(delay or DELVE_LIVES_RECHECK_DELAY_SECONDS, function()
        self.pendingLivesRefresh = false
        Delves:RefreshLives()
    end, "RGXDelves:LivesRefresh")
end

function Delves:Init()
    if self._eventsInit then return end
    self._eventsInit = true
    if not RGX:HasCapability("delves") then return end

    RGX:RegisterEvent("FACTION_STANDING_CHANGED", function(_, factionID)
        Delves:CheckCompanionLevel(factionID)
    end, "RGXDelves_Faction")

    RGX:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function(_, factionID, newLevel, oldLevel)
        local companionFactionID = Delves.cachedCompanionFactionID or Delves:GetCompanionFactionID()
        if companionFactionID and factionID == companionFactionID and newLevel and oldLevel and newLevel > oldLevel then
            Delves.lastCompanionLevel = newLevel
            Fire(Delves._onCompanionLevelUp, newLevel, oldLevel, factionID)
        else
            Delves:CheckCompanionLevel(factionID)
        end
    end, "RGXDelves_Renown")

    RGX:RegisterEvent("UNIT_AURA", function(_, unit)
        if unit ~= "player" then return end
        Delves:RefreshLives()
        Delves:QueueLivesRefresh()
    end, "RGXDelves_Lives")

    self:UpdateCompanionCache()
    self.cachedLivesRemaining = self:GetLivesRemaining()
end

_G.RGXDelves = Delves
RGX:RegisterModule("delves", Delves)
