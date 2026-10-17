--- MSA-ProtRouter-1.0 - Router for Protected functions
--- Copyright (c) 2019-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-ProtRouter-1.0", 6

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

-- Lua API
local next = next
local type = type
local unpack = unpack

local combatLockdown = InCombatLockdown()

lib.protectedActions = lib.protectedActions or {}
local protectedActions = lib.protectedActions

local CallbackHandler = LibStub("CallbackHandler-1.0")
lib.callbacks = lib.callbacks or CallbackHandler:New(lib)

local COMBAT_STOP = "PROT_COMBAT_STOP"

local function RunStoredActions()
    --print("|cff00ff00RUN STORED|r")
    local func, params = next(protectedActions)
    while func do
        if combatLockdown then break end
        --print("-", func, "-", unpack(params))

        func(unpack(params))
        protectedActions[func] = nil

        func, params = next(protectedActions)
    end
end

function lib:Prot(method, object, ...)
    local methodType = type(method)
    local func

    if methodType == "string" then
        --print(combatLockdown and "|cffffff00STORE|r" or "|cff00ff00RUN|r", method, "-", object, "-", ...)
        func = object[method]
    elseif methodType == "table" then
        --print(combatLockdown and "|cffffff00STORE|r" or "|cff00ff00RUN|r", object, "-", method, "-", ...)
        func = method[object]
        if combatLockdown then
            protectedActions[func] = { ... }
        else
            func(...)
        end
        return
    else
        --print(combatLockdown and "|cffffff00STORE|r" or "|cff00ff00RUN|r", method, "-", object, ...)
        func = method
    end

    if combatLockdown then
        protectedActions[func] = { object, ... }
    else
        func(object, ...)
    end
end

function lib:ProtOnCombatStop(method, object)
    lib.RegisterCallback(object or self, COMBAT_STOP, method)
end

-- Events
lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        combatLockdown = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        combatLockdown = false
        RunStoredActions()

        lib.callbacks:Fire(COMBAT_STOP)
    end
end)
lib.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Embed handling ------------------------------------------------------------------------------------------------------

lib.embeds = lib.embeds or {}

local mixins = {
    "Prot",
    "ProtOnCombatStop"
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