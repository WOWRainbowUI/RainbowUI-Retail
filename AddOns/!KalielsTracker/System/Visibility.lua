--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

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
    else
        local mapID = KT.GetCurrentMapAreaID()
        if mapID and KT.MAJOR_CITY_MAPS[mapID] then
            add("city")
        end
    end
    if C_PetBattles.IsInBattle() then
        add("petbattle")
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
KT:RegSignal("OPTIONS_OPENED", Visibility_BroadcastContext)

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
KT:RegSignal("OPTIONS_CHANGED", Visibility_ApplyAction, {})

KT:RegEvent("PLAYER_ENTERING_WORLD", Visibility_ApplyAction)
KT:RegEvent("ZONE_CHANGED_NEW_AREA", Visibility_ApplyAction)
KT:RegEvent("CHALLENGE_MODE_START", Visibility_ApplyAction)
KT:RegEvent("PET_BATTLE_OPENING_START", Visibility_ApplyAction)
KT:RegEvent("PET_BATTLE_CLOSE", Visibility_ApplyAction)