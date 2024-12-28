--- MSA-ProtRouter-1.0 - Router for Protected functions
--- Copyright (c) 2019-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-ProtRouter-1.0", 4

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

-- Lua API
local next = next
local type = type
local unpack = unpack

local combatLockdown = InCombatLockdown()

lib.protectedActions = {}

local function protRunStoredActions()
    local func, params = next(lib.protectedActions)
    while func do
        if combatLockdown then break end
        func(unpack(params))
        lib.protectedActions[func] = nil
        func, params = next(lib.protectedActions)
    end
end

function lib:prot(method, object, ...)
    local func
    if type(method) == "string" then
        func = object[method]
    else
        func = method
    end
    local params = { object, ... }

    if combatLockdown then
        lib.protectedActions[func] = params
    else
        func(unpack(params))
    end
end

-- Events
lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        combatLockdown = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        combatLockdown = false
        protRunStoredActions()
    end
end)
lib.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

------------------------------------------------------------------------------------------------------------------------
-- Embed handling
------------------------------------------------------------------------------------------------------------------------

lib.embeds = lib.embeds or {}

local mixins = {
    "prot"
}

function lib:Embed(target)
    lib.embeds[target] = true
    for _, v in next, mixins do
        target[v] = lib[v]
    end
    return target
end

for addon in next, lib.embeds do
    lib:Embed(addon)
end