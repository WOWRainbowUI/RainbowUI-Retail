-- NewSpenderTracker.lua
-- Tracker for custom spell/spender logic, based on WarriorTracker.lua
-- Triggers on SPELL_CAST_SUCCESS for spellID 1283344, displays icons for spenders 228477 and 247454

local SPELL_TRIGGER_ID = 1283344
local SPENDERS = {
    [228477] = { icon = 1344653 }, -- Soul Cleave
    [263642] = { icon = 1388065 }, -- Fracture
}
local spenderList = {228477, 263642}


local _, class = UnitClass("player")
if class ~= "DEMONHUNTER" then return end

local function IsVengeanceOrHavoc()
    local spec = GetSpecialization and GetSpecialization() or nil
    return spec == 1 or spec == 2 -- 1 = Havoc, 2 = Vengeance
end

if not IsVengeanceOrHavoc() then return end

