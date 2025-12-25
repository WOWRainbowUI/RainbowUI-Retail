--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Visibility")

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local contextFlags = {}
local lastContextKey

local function GetContext()
    local result = { "world" }

    local function add(ctx)
        tinsert(result, 1, ctx)
    end

    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "party" or instanceType == "scenario" then
        add("dungeon")
        if difficultyID == 8 or C_ChallengeMode.IsChallengeModeActive() then
            add("mythicplus")
        end
    elseif instanceType == "raid" then
        add("raid")
    elseif instanceType == "arena" then
        add("arena")
    elseif instanceType == "pvp" then
        add("battleground")
    elseif instanceType == "interior" then
        add("house")
    else
        local mapID = KT.GetCurrentMapAreaID()
        if mapID and KT.MAJOR_CITY_MAPS[mapID] then
            add("city")
        end
    end
    if C_PetBattles.IsInBattle() then
        add("petbattle")
    end
    if contextFlags.rare then
        add("rare")
    end

    return result
end

local function ApplyAction(action)
    if action == "show" then
        KT:SetHidden(false)
    elseif action == "hide" then
        KT:SetHidden(true)
    elseif action == "collapse" then
        if KT.hidden then
            KT:SetHidden(false)
        end
        KT:SetCollapsed(true)
    elseif action == "expand" then
        if KT.hidden then
            KT:SetHidden(false)
        end
        KT:SetCollapsed(false)
    end
end

local function Visibility_BroadcastContext()
    local contexts = GetContext()
    KT:SendSignal("VISIBILITY_CONTEXT", contexts)
end

local function Visibility_ApplyAction()
    local db = KT.db.profile
    local contexts = GetContext()
    local action = db["visibility"..contexts[1]]
    local key = table.concat(contexts, "-") .. "#" .. action
    if lastContextKey ~= key then
        _DBG(contexts[1].." - "..action, true)
        ApplyAction(action)
        KT:SendSignal("VISIBILITY_CONTEXT", contexts)
        lastContextKey = key
    end
end

local function Visibility_OnFlag(self, name, state)
    contextFlags[name] = state and true or false
    Visibility_ApplyAction()
end

function SS:Init()
    KT:RegSignal("OPTIONS_OPENED", Visibility_BroadcastContext, self)
    KT:RegSignal("OPTIONS_CHANGED", Visibility_ApplyAction, self)
    KT:RegSignal("VISIBILITY_FLAG", Visibility_OnFlag, self)

    KT:RegEvent("PLAYER_ENTERING_WORLD", Visibility_ApplyAction, self)
    KT:RegEvent("ZONE_CHANGED_NEW_AREA", Visibility_ApplyAction, self)
    KT:RegEvent("CHALLENGE_MODE_START", Visibility_ApplyAction, self)
    KT:RegEvent("PET_BATTLE_OPENING_START", Visibility_ApplyAction, self)
    KT:RegEvent("PET_BATTLE_CLOSE", Visibility_ApplyAction, self)
end