-- Centralized event handling
local addonName, ns = ...
local CCS = ns.CCS
local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

-- Create event frame
CCS.EventsFrame = CCS.EventsFrame or CreateFrame("Frame")
CCS.RegisteredEvents = CCS.RegisteredEvents or {}

local LSM = LibStub("LibSharedMedia-3.0")

--------------------------------------------------------
-- Register event handler (supports multiple listeners, version-aware)
--------------------------------------------------------
function CCS:RegisterEvent(event, func, isBlizzardEvent, versions)
    self.RegisteredEvents[event] = self.RegisteredEvents[event] or {}

    -- Version-gated wrapper (unchanged)
    local handler
    if versions and #versions > 0 then
        handler = function(ev, ...)
            local current = CCS.GetCurrentVersion()
            for _, v in ipairs(versions) do
                if v == current or v == CCS.ALL then
                    return func(ev, ...)
                end
            end
            -- silently skip
        end
    else
        handler = func
    end

    table.insert(self.RegisteredEvents[event], handler)

    -- Only register with Blizzard if the event exists for the current version
    if isBlizzardEvent then
        local shouldRegister = true
        if versions and #versions > 0 then
            shouldRegister = false
            local current = CCS.GetCurrentVersion()
            for _, v in ipairs(versions) do
                if v == current or v == CCS.ALL then
                    shouldRegister = true
                    break
                end
            end
        end

        if shouldRegister then
            self.EventsFrame:RegisterEvent(event)
        end
    end
end

--------------------------------------------------------
-- Dispatch Blizzard events
--------------------------------------------------------
CCS.EventsFrame:SetScript("OnEvent", function(_, event, ...)
    local handlers = CCS.RegisteredEvents[event]
    if handlers then
        for _, fn in ipairs(handlers) do
            fn(event, ...)
        end
    end
end)

--------------------------------------------------------
-- Fire a custom event manually
--------------------------------------------------------
function CCS:FireEvent(event, ...)
    local handlers = self.RegisteredEvents[event]
    if handlers then
        for _, fn in ipairs(handlers) do
            fn(event, ...)
        end
    end
end

local function WrapHandler(eventName, handlerFn, handlerName)
    -- Fallback to function pointer string if no name provided
    local hkey = handlerName or tostring(handlerFn)

    return function(...)
        local startExec
        if CCS.EventStatsEnabled then
            startExec = debugprofilestop()
        end

        -- Run the actual handler
        local result = handlerFn(...)

        if CCS.EventStatsEnabled then
            local finish = debugprofilestop()
            local execTime = finish - startExec

            -- Ensure event stats exist
            local eventStats = CCS.EventStats[eventName]
            if not eventStats then
                eventStats = { handlers = {} }
                CCS.EventStats[eventName] = eventStats
            end

            -- Ensure handler stats exist
            local hstats = eventStats.handlers[hkey]
            if not hstats then
                hstats = {
                    execCount = 0,
                    execAvg = nil,
                    execMin = nil,
                    execMax = nil,
                }
                eventStats.handlers[hkey] = hstats
            end

            -- Update handler execution stats
            hstats.execCount = hstats.execCount + 1
            hstats.execAvg = hstats.execAvg and ((hstats.execAvg * (hstats.execCount - 1)) + execTime) / hstats.execCount or execTime
            hstats.execMin = hstats.execMin and math.min(hstats.execMin, execTime) or execTime
            hstats.execMax = hstats.execMax and math.max(hstats.execMax, execTime) or execTime
        end

        return result
    end
end

function CCS:PrintEventStats()
    print("=== CCS Event Stats ===")
    for eventName, stats in pairs(CCS.EventStats) do

        -- Event-level interval stats
        print(string.format(
            "Event: %s | Count=%d | AvgInt=%.2fms | MinInt=%.2fms | MaxInt=%.2fms",
            eventName,
            stats.count or 0,
            stats.avgInterval or 0,
            stats.minInterval or 0,
            stats.maxInterval or 0
        ))

        -- NEW: Event-level execution stats
        print(string.format(
            "      Exec: Count=%d | Avg=%.3fms | Min=%.3fms | Max=%.3fms",
            stats.execCount or 0,
            stats.execAvg or 0,
            stats.execMin or 0,
            stats.execMax or 0
        ))

        -- Handler-level breakdown (if you want per-handler exec stats too)
        if stats.handlers then
            for hkey, hstats in pairs(stats.handlers) do
                print(string.format(
                    "   Handler: %s | Count=%d | AvgInt=%.2fms | MinInt=%.2fms | MaxInt=%.2fms",
                    hkey,
                    hstats.count or 0,
                    hstats.avgInterval or 0,
                    hstats.minInterval or 0,
                    hstats.maxInterval or 0
                ))

                -- NEW: per-handler execution stats
                print(string.format(
                    "           Exec: Count=%d | Avg=%.3fms | Min=%.3fms | Max=%.3fms",
                    hstats.execCount or 0,
                    hstats.execAvg or 0,
                    hstats.execMin or 0,
                    hstats.execMax or 0
                ))
            end
        end
    end
    print("=== End Stats ===")
end

--------------------------------------------------------
-- EVENT HANDLER MAPPING (version-aware declarations)
--------------------------------------------------------
local eventHandlers = {
    -- Blizzard events
    ["ACTIVE_TALENT_GROUP_CHANGED"] = {
        { fn = WrapHandler("ACTIVE_TALENT_GROUP_CHANGED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["ACTIVE_PLAYER_SPECIALIZATION_CHANGED"] = {
        { fn = WrapHandler("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
    },

    ["ADDON_LOADED"] = WrapHandler("ADDON_LOADED", function(event, loadedAddon)
        if loadedAddon ~= addonName then return end
        CCS:InitSavedVariables()
        CCS:LoadOptions()
    end),

    ["AVOIDANCE_UPDATE"] = {
        { fn = WrapHandler("AVOIDANCE_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["ITEM_PUSH"] = {
        { fn = WrapHandler("ITEM_PUSH", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["ENCOUNTER_START"] = WrapHandler("ENCOUNTER_START", function()
		CCS.inencounter = true
    end),

    ["ENCOUNTER_END"] = WrapHandler("ENCOUNTER_END", function()
		CCS.inencounter = false
        if CCS.secretsdisabled == true then
            CCS.secretsdisabled = false
            CCS.MythicPlusEventHandler()
        end
    end),
    
    ["BOSS_KILL"] = {
        { fn = WrapHandler("BOSS_KILL", CCS.RaidProgressEventHandler, "RaidProgressEventHandler"), versions = { CCS.RETAIL } },
    },

    ["CHALLENGE_MODE_START"] = WrapHandler("CHALLENGE_MODE_START", function()
		CCS.challengemode = true
    end),

    ["CHALLENGE_MODE_RESET"] = WrapHandler("CHALLENGE_MODE_RESET", function()
		CCS.challengemode = false
    end),

    ["CHALLENGE_MODE_COMPLETED"] = {
        { fn = WrapHandler("CHALLENGE_MODE_COMPLETED", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["CHALLENGE_MODE_MAPS_UPDATE"] = {
        { fn = WrapHandler("CHALLENGE_MODE_MAPS_UPDATE", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["CHARACTER_ITEM_FIXUP_NOTIFICATION"] = {
        { fn = WrapHandler("CHARACTER_ITEM_FIXUP_NOTIFICATION", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["CHARACTER_POINTS_CHANGED"] = {
        { fn = WrapHandler("CHARACTER_POINTS_CHANGED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["COMBAT_RATING_UPDATE"] = {
        { fn = WrapHandler("COMBAT_RATING_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("COMBAT_RATING_UPDATE", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },

    ["CURRENCY_DISPLAY_UPDATE"]  = {
        { fn = WrapHandler("CURRENCY_DISPLAY_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
--[[
    ["GOSSIP_CLOSED"] = {
        { fn = WrapHandler("GOSSIP_CLOSED", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },
--]]

    ["INSPECT_READY"] = {
        { fn = WrapHandler("INSPECT_READY", CCS.InspectSheetEventHandler, "InspectSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("INSPECT_READY", CCS.MOPCharacterSheetEventHandler, "MOPCharacterSheetEventHandler"), versions = { CCS.MOP } },
        { fn = WrapHandler("INSPECT_READY", CCS.TBCCharacterSheetEventHandler, "TBCCharacterSheetEventHandler"), versions = { CCS.TBC } },
    },

    ["INSTANCE_ENCOUNTER_OBJECTIVE_UPDATE"] = {
        { fn = WrapHandler("INSTANCE_ENCOUNTER_OBJECTIVE_UPDATE", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["ITEM_CHANGED"] = {
        { fn = WrapHandler("ITEM_CHANGED", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },
    
    ["LIFESTEAL_UPDATE"] = {
        { fn = WrapHandler("LIFESTEAL_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["LOOT_READY"] = {
        { fn = WrapHandler("LOOT_READY", CCS.RaidProgressEventHandler, "RaidProgressEventHandler"), versions = { CCS.RETAIL } },
    },

    ["MASTERY_UPDATE"] = {
        { fn = WrapHandler("MASTERY_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["MYTHIC_PLUS_CURRENT_AFFIX_UPDATE"] = {
        { fn = WrapHandler("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["MYTHIC_PLUS_NEW_WEEKLY_RECORD"] = {
        { fn = WrapHandler("MYTHIC_PLUS_NEW_WEEKLY_RECORD", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_AVG_ITEM_LEVEL_UPDATE"] = {
        { fn = WrapHandler("PLAYER_AVG_ITEM_LEVEL_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_ENTERING_WORLD"] = {
        { fn = WrapHandler("PLAYER_ENTERING_WORLD", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("PLAYER_ENTERING_WORLD", CCS.MOPCharacterSheetEventHandler, "MOPCharacterSheetEventHandler"), versions = { CCS.MOP } },
        { fn = WrapHandler("PLAYER_ENTERING_WORLD", CCS.TBCCharacterSheetEventHandler, "TBCCharacterSheetEventHandler"), versions = { CCS.TBC } },
        { fn = WrapHandler("PLAYER_ENTERING_WORLD", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
        { fn = WrapHandler("PLAYER_ENTERING_WORLD", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("PLAYER_ENTERING_WORLD", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_EQUIPMENT_CHANGED"] = {
        { fn = WrapHandler("PLAYER_EQUIPMENT_CHANGED", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("PLAYER_EQUIPMENT_CHANGED", CCS.MOPCharacterSheetEventHandler, "MOPCharacterSheetEventHandler"), versions = { CCS.MOP } },
        { fn = WrapHandler("PLAYER_EQUIPMENT_CHANGED", CCS.TBCCharacterSheetEventHandler, "TBCCharacterSheetEventHandler"), versions = { CCS.TBC } },
        { fn = WrapHandler("PLAYER_EQUIPMENT_CHANGED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_LEAVE_COMBAT"] = {
        --{ fn = WrapHandler("PLAYER_LEAVE_COMBAT", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("PLAYER_LEAVE_COMBAT", CCS.RaidProgressEventHandler, "RaidProgressEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_LEVEL_UP"] = {
        { fn = WrapHandler("PLAYER_LEVEL_UP", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("PLAYER_LEVEL_UP", CCS.RaidProgressEventHandler, "RaidProgressEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_LOGIN"] = WrapHandler("PLAYER_LOGIN", function()

        for _, def in ipairs(ns.optionDefs or {}) do
            if def.key then
                local value = CCS.CurrentProfile[def.key]
            
                if def.type == "font" then
                    local profileFontpath = CCS.CurrentProfile[def.key]
                    local fontName = CCS.GetFontKeyByPath(profileFontpath)
                    local LSM_fontpath = LSM:Fetch("font", fontName)
                    value = LSM_fontpath
                end
                CCS:UpdateOption(def, value)
            end
        end    

        CCS:Initialize()
        CCS:LoadBlizzardAddOns()
        C_Timer.After(0.1, function()
            CCS.RefreshStyleColors()
            CCS:PrimeFontsAndTextures()
            CCS.fontname = CCS:GetDefaultFontForLocale() or CCS:GetOptionValue("default_font") or "Fonts\\FRIZQT__.TTF"
            if CCS:GetOptionValue("textoutline") == "Thin Outline" then
                CCS.textoutline = "OUTLINE"
            elseif CCS:GetOptionValue("textoutline") == "Thick Outline" then
                CCS.textoutline = "THICKOUTLINE"
            else
                CCS.textoutline = ""
            end

        end)
        CCS.fontname = CCS:GetDefaultFontForLocale() or CCS:GetOptionValue("default_font") or "Fonts\\FRIZQT__.TTF"

        if CCS:GetOptionValue("textoutline") == "Thin Outline" then
            CCS.textoutline = "OUTLINE"
        elseif CCS:GetOptionValue("textoutline") == "Thick Outline" then
            CCS.textoutline = "THICKOUTLINE"
        else
            CCS.textoutline = ""
        end

        for _, module in pairs(CCS.Modules) do
            if type(module.Initialize) == "function" then
                C_Timer.After(0.1, function() module:Initialize() end)
            end
        end
        CCS:FireEvent("CCS_EVENT_OPTIONS")
        
    end),

    ["PLAYER_LOOT_SPEC_UPDATED"] = {
        { fn = WrapHandler("PLAYER_LOOT_SPEC_UPDATED", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
    },

    ["PLAYER_REGEN_ENABLED"] = WrapHandler("PLAYER_REGEN_ENABLED", function()


        if CCS.initall == true then
            for _, module in pairs(CCS.Modules) do
                if type(module.Initialize) == "function" then
                    C_Timer.After(0.1, function() module:Initialize() end)
                end
            end
            CCS:FireEvent("CCS_EVENT_OPTIONS")
            CCS.initall = nil
        end
        
        if CCS.GetCurrentVersion() == CCS.RETAIL then 

            if CCS.secretsdisabled == true then
                CCS.secretsdisabled = false
                CCS.MythicPlusEventHandler()
            end

            if CCS.incombat == true then
                CCS.incombat = false
                CCS.CharacterStatsEventHandler()
            end 

            CCS.RaidProgressEventHandler() 
            
            if InspectFrame and not InspectFrame.loaded and option("show_inspect") then
                CCS.initializeinspectframe()
            end

        end

    end),

    ["PLAYER_REGEN_DISABLED"] = WrapHandler("PLAYER_REGEN_DISABLED", function()
        local optionsFrame = _G["CCS_Options"]
        if optionsFrame and optionsFrame:IsShown() then
            optionsFrame:Hide()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end
    end),

    ["PLAYER_SPECIALIZATION_CHANGED"] = {
        { fn = WrapHandler("PLAYER_SPECIALIZATION_CHANGED", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("PLAYER_SPECIALIZATION_CHANGED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["PLAYER_STARTED_TURNING"] = {
        { fn = WrapHandler("PLAYER_STARTED_TURNING", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["PLAYER_STOPPED_LOOKING"] = {
        { fn = WrapHandler("PLAYER_STOPPED_LOOKING", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["PLAYER_STOPPED_TURNING"] = {
        { fn = WrapHandler("PLAYER_STOPPED_TURNING", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["PLAYER_TALENT_UPDATE"] = {
        { fn = WrapHandler("PLAYER_TALENT_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["QUEST_ACCEPTED"] = {
        { fn = WrapHandler("QUEST_ACCEPTED", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
    },
    ["SPEED_UPDATE"] = {
        { fn = WrapHandler("SPEED_UPDATE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["TRAIT_CONFIG_UPDATED"] = {
        { fn = WrapHandler("TRAIT_CONFIG_UPDATED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["SPELL_POWER_CHANGED"] = {
        { fn = WrapHandler("SPELL_POWER_CHANGED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },

    ["UNIT_ATTACK"] = {
        { fn = WrapHandler("UNIT_ATTACK", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_ATTACK", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_ATTACK_POWER"] = {
        { fn = WrapHandler("UNIT_ATTACK_POWER", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_ATTACK_POWER", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_ATTACK_SPEED"] = {
        { fn = WrapHandler("UNIT_ATTACK_SPEED", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_ATTACK_SPEED", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_AURA"] = {
        { fn = WrapHandler("UNIT_AURA", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_DAMAGE"] = {
        { fn = WrapHandler("UNIT_DAMAGE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_DAMAGE", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_LEVEL"] = {
        { fn = WrapHandler("UNIT_LEVEL", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_LEVEL", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    
    ["UNIT_MODEL_CHANGED"] = {
        { fn = WrapHandler("UNIT_MODEL_CHANGED", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    
    ["UNIT_MAXHEALTH"] = {
        { fn = WrapHandler("UNIT_MAXHEALTH", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_MAXHEALTH", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_MAXPOWER"] = {
        { fn = WrapHandler("UNIT_MAXPOWER", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["UNIT_RANGED_ATTACK_POWER"] = {
        { fn = WrapHandler("UNIT_RANGED_ATTACK_POWER", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_RANGED_ATTACK_POWER", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_RANGEDDAMAGE"] = {
        { fn = WrapHandler("UNIT_RANGEDDAMAGE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_RANGEDDAMAGE", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_RESISTANCES"] = {
        { fn = WrapHandler("UNIT_RESISTANCES", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UNIT_SPELL_HASTE"] = {
        { fn = WrapHandler("UNIT_SPELL_HASTE", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    ["UNIT_STATS"] = {
        { fn = WrapHandler("UNIT_STATS", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UNIT_STATS", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },
    ["UPDATE_INVENTORY_DURABILITY"] = {
        { fn = WrapHandler("UPDATE_INVENTORY_DURABILITY", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("UPDATE_INVENTORY_DURABILITY", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },        
        { fn = WrapHandler("UPDATE_INVENTORY_DURABILITY", CCS.MOPCharacterSheetEventHandler, "MOPCharacterSheetEventHandler"), versions = { CCS.MOP } },
        { fn = WrapHandler("UPDATE_INVENTORY_DURABILITY", CCS.TBCCharacterSheetEventHandler, "TBCCharacterSheetEventHandler"), versions = { CCS.TBC } },
    },

    ["WEEKLY_REWARDS_ITEM_CHANGED"] = {
        { fn = WrapHandler("WEEKLY_REWARDS_ITEM_CHANGED", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },
    ["WEEKLY_REWARDS_UPDATE"] = {
        { fn = WrapHandler("WEEKLY_REWARDS_UPDATE", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
    },

    -- Custom events (manually fired)
    ["CCS_EVENT_CSHOW"] = {
        { fn = WrapHandler("CCS_EVENT_CSHOW", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_CSHOW", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_CSHOW", CCS.MOPCharacterSheetEventHandler, "MOPCharacterSheetEventHandler"), versions = { CCS.MOP } },
        { fn = WrapHandler("CCS_EVENT_CSHOW", CCS.TBCCharacterSheetEventHandler, "TBCCharacterSheetEventHandler"), versions = { CCS.TBC } },
        { fn = WrapHandler("CCS_EVENT_CSHOW", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },

    ["CCS_STATS"] = {
        { fn = WrapHandler("CCS_STATS", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
    },
    
    ["CCS_EVENT_OPTIONS"] = {
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.RefreshStyleColors, "RefreshStyleColors"), versions = { CCS.ALL } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.CharacterSheetEventHandler, "CharacterSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.MOPCharacterSheetEventHandler, "MOPCharacterSheetEventHandler"), versions = { CCS.MOP } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.TBCCharacterSheetEventHandler, "TBCCharacterSheetEventHandler"), versions = { CCS.TBC } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.InspectSheetEventHandler, "InspectSheetEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.RaidProgressEventHandler, "RaidProgressEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.MythicPlusEventHandler, "MythicPlusEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.CharacterStatsEventHandler, "CharacterStatsEventHandler"), versions = { CCS.RETAIL } },
        { fn = WrapHandler("CCS_EVENT_OPTIONS", CCS.TBCCharacterStatsEventHandler, "TBCCharacterStatsEventHandler"), versions = { CCS.TBC } },
    },    
}


--------------------------------------------------------
-- REGISTER ALL EVENTS DIRECTLY (Blizzard only)
--------------------------------------------------------
for event, handlers in pairs(eventHandlers) do
    if event ~= "CCS_EVENT_CSHOW" and event ~= "CCS_STATS" and event ~= "CCS_EVENT_OPTIONS" then
        if type(handlers) == "function" then
            CCS:RegisterEvent(event, handlers, true)
        else
            for _, h in ipairs(handlers) do
                CCS:RegisterEvent(event, h.fn, true, h.versions)
            end
        end
    else
        -- Custom events: just store in RegisteredEvents
        CCS.RegisteredEvents[event] = {}
        if type(handlers) == "function" then
            table.insert(CCS.RegisteredEvents[event], handlers)
        else
            for _, h in ipairs(handlers) do
                CCS:RegisterEvent(event, h.fn, false, h.versions)
            end
        end
    end
end