--[[
    RGX-Framework - Pet Battles Module

    Provides pet battle event tracking, pet journal utilities, and a callback
    system for level-up / capture / battle-start / battle-end events.

    Consumers (PB2, BLU, etc.) register callbacks instead of wiring raw events:

        local PetBattles = RGX:GetModule("petbattles")

        PetBattles:OnLevelUp(function(petID, petSlot, newLevel, oldLevel)
            print("Pet leveled up!", newLevel)
        end)

        PetBattles:OnCapture(function(petID, petSlot)
            print("Captured a pet!")
        end)

        PetBattles:OnBattleStart(function()
            print("Battle started")
        end)

        PetBattles:OnBattleEnd(function()
            print("Battle ended")
        end)
--]]

local addonName, RGX = ...

if not RGX then
    error("RGX PetBattles: RGX-Framework not loaded")
    return
end

local PetBattles = {}
PetBattles.name    = "petbattles"
PetBattles.version = "1.0.0"
PetBattles._eventsInit = false

-- Internal state
PetBattles._lastLevel       = {}  -- [petID] = level
PetBattles._cooldown        = {}  -- [petSlot] = lastFiredTime
PetBattles._pendingScan     = false
PetBattles._inBattle        = false
PetBattles._callbacks       = {
    levelup      = {},
    capture      = {},
    battlestart  = {},
    battleend    = {},
    petchanged   = {},
}

local LEVEL_COOLDOWN = 1.0  -- seconds between level-up fires for the same slot

--[[============================================================================
    CALLBACK REGISTRATION
============================================================================]]

local function addCallback(list, fn)
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

local function fireCallbacks(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then
            RGX:Debug("[RGXPetBattles] callback error:", err)
        end
    end
end

function PetBattles:OnLevelUp(fn)
    return addCallback(self._callbacks.levelup, fn)
end

function PetBattles:OnCapture(fn)
    return addCallback(self._callbacks.capture, fn)
end

function PetBattles:OnBattleStart(fn)
    return addCallback(self._callbacks.battlestart, fn)
end

function PetBattles:OnBattleEnd(fn)
    return addCallback(self._callbacks.battleend, fn)
end

function PetBattles:OnPetChanged(fn)
    return addCallback(self._callbacks.petchanged, fn)
end

--[[============================================================================
    PET JOURNAL UTILITIES
============================================================================]]

function PetBattles:IsAvailable()
    return C_PetJournal ~= nil
        and type(C_PetJournal.GetNumPets) == "function"
        and type(C_PetJournal.GetPetInfoByIndex) == "function"
        and type(C_PetJournal.GetPetInfoByPetID) == "function"
end

function PetBattles:GetNumPets()
    if not self:IsAvailable() then return 0 end
    return C_PetJournal.GetNumPets() or 0
end

function PetBattles:GetPetInfoByIndex(index)
    if not self:IsAvailable() then return nil end
    return C_PetJournal.GetPetInfoByIndex(index)
end

function PetBattles:GetPetInfoByID(petID)
    if not self:IsAvailable() then return nil end
    return C_PetJournal.GetPetInfoByPetID(petID)
end

function PetBattles:GetPetLevel(petID)
    return self._lastLevel[petID]
end

function PetBattles:IsInBattle()
    return self._inBattle
end

--[[============================================================================
    BATTLE APIs
    Thin wrappers over C_PetBattles.* for active battle queries.
    Returns nil/0 when the underlying API is unavailable.
============================================================================]]

function PetBattles:GetNumPets(team)
    if type(C_PetBattles.GetNumPets) ~= "function" then return 0 end
    return C_PetBattles.GetNumPets(team) or 0
end

function PetBattles:GetHealth(team, battleIndex)
    if type(C_PetBattles.GetHealth) ~= "function" then return 0 end
    return C_PetBattles.GetHealth(team, battleIndex) or 0
end

function PetBattles:GetMaxHealth(team, battleIndex)
    if type(C_PetBattles.GetMaxHealth) ~= "function" then return 0 end
    return C_PetBattles.GetMaxHealth(team, battleIndex) or 0
end

function PetBattles:GetActivePet(team)
    if type(C_PetBattles.GetActivePet) ~= "function" then return nil end
    return C_PetBattles.GetActivePet(team)
end

-- Scan all owned pets and cache their current levels.
function PetBattles:ScanPetLevels()
    if not self:IsAvailable() then return end

    local numPets = C_PetJournal.GetNumPets()
    for i = 1, numPets do
        local petID, _, owned = C_PetJournal.GetPetInfoByIndex(i)
        if petID and owned then
            local _, _, level = C_PetJournal.GetPetInfoByPetID(petID)
            if level then
                self._lastLevel[petID] = level
            end
        end
    end
end

-- Check all owned pets for level increases since last scan.
function PetBattles:CheckPetLevels()
    if not self:IsAvailable() then return end

    local numPets = C_PetJournal.GetNumPets()
    for i = 1, numPets do
        local petID, _, owned = C_PetJournal.GetPetInfoByIndex(i)
        if petID and owned then
            local _, _, level, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(petID)
            if level then
                local last = self._lastLevel[petID] or 0
                if level > last then
                    self._lastLevel[petID] = level
                    fireCallbacks(self._callbacks.levelup, petID, nil, level, last)
                    RGX:Debug("PetBattles: level up", name or petID, last, "->", level)
                end
            end
        end
    end
end

function PetBattles:SchedulePetLevelScan(delay)
    if self._pendingScan then return end
    self._pendingScan = true
    RGX:After(delay or 0.2, function()
        self._pendingScan = false
        self:CheckPetLevels()
    end)
end

--[[============================================================================
    EVENT HANDLERS
============================================================================]]

function PetBattles:_OnLevelChanged(event, owner, petSlot, newLevel, oldLevel)
    if type(Enum) == "table"
    and type(Enum.BattlePetOwner) == "table"
    and owner ~= Enum.BattlePetOwner.Ally then
        return
    end

    local now = GetTime()
    if self._cooldown[petSlot] and (now - self._cooldown[petSlot]) < LEVEL_COOLDOWN then
        return
    end
    self._cooldown[petSlot] = now

    fireCallbacks(self._callbacks.levelup, nil, petSlot, newLevel, oldLevel)
    RGX:Debug("PetBattles: PET_BATTLE_LEVEL_CHANGED slot", petSlot, oldLevel, "->", newLevel)
end

function PetBattles:_OnPetChanged()
    fireCallbacks(self._callbacks.petchanged)
    self:SchedulePetLevelScan(0.2)
end

function PetBattles:_OnPetCaptured(event, owner, petIndex)
    if type(Enum) == "table"
    and type(Enum.BattlePetOwner) == "table"
    and owner ~= Enum.BattlePetOwner.Ally then
        return
    end
    fireCallbacks(self._callbacks.capture, nil, petIndex)
    RGX:Debug("PetBattles: PET_BATTLE_CAPTURED index", petIndex)
end

function PetBattles:_OnBattleStart()
    self._inBattle = true
    fireCallbacks(self._callbacks.battlestart)
    RGX:Debug("PetBattles: battle started")
end

function PetBattles:_OnBattleEnd()
    self._inBattle = false
    fireCallbacks(self._callbacks.battleend)
    RGX:Debug("PetBattles: battle ended")
    self:SchedulePetLevelScan(0.5)
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function PetBattles:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", function(...) self:_OnLevelChanged(...) end)
    RGX:RegisterEvent("PET_BATTLE_PET_CHANGED",   function(...) self:_OnPetChanged(...)   end)
    RGX:RegisterEvent("PET_BATTLE_CAPTURED",       function(...) self:_OnPetCaptured(...)  end)
    RGX:RegisterEvent("PET_BATTLE_OPENING_START",  function(...) self:_OnBattleStart(...)  end)
    RGX:RegisterEvent("PET_BATTLE_CLOSE",          function(...) self:_OnBattleEnd(...)    end)

    RGX:RegisterEvent("PLAYER_LOGIN", function()
        self:ScanPetLevels()
    end)

    RGX:Debug("PetBattles: module initialized")
end

RGX:RegisterModule("petbattles", PetBattles)
_G.RGXPetBattles = PetBattles

PetBattles:Init()
