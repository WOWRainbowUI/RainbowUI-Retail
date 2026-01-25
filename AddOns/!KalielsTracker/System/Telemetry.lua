--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local SS = KT:NewSubsystem("Telemetry")

local TITLE_SLUG = gsub(KT.TITLE, "'", "")
local LINE_PATTERN = "\n|cff8888ff%s|r |cff808080...|r |cffffffff%s|r"

local data = {}

-- ---------------------------------------------------------------------------------------------------------------------

local function IsOwnError(err)
    return err and err:find(addonName, 1, true) ~= nil
end

local function FormatText(name, value1, ...)
    if select("#", ...) == 0 then
        return format(LINE_PATTERN, name, tostring(value1))
    end

    local values = { value1, ... }
    for i = 1, #values do
        values[i] = tostring(values[i])
    end

    return format(LINE_PATTERN, name, table.concat(values, "|cff808080 | |r"))
end

local function FormatTable(table, prefix)
    prefix = prefix or ""
    local result = ""

    for k, v in pairs(table) do
        local valueType = type(v)
        if valueType ~= "function"then
            local line
            if valueType == "table" then
                line = FormatText(prefix..k, "{")
                line = line..FormatTable(v, prefix.."   ")
                line = line.."\n|cffffffff"..prefix.."}|r"
            else
                line = FormatText(prefix..k, v)
            end
            result = result..line
        end
    end

    return result
end

local function BuildTelemetry()
    local mapID = KT.GetCurrentMapAreaID()

    local telemetry = "\n\n|cff808080"..TITLE_SLUG.." Telemetry:|r"..
            FormatText("version", KT.VERSION)..
            FormatText("gameVersion", KT.GAME_VERSION.."."..KT.GAME_BUILD)..
            FormatText("gameLocale", KT.LOCALE)..
            FormatText("player", KT.playerLevel, UnitRace("player"), KT.playerClass, KT.playerFaction)..
            FormatText("mapID", mapID, KT.GetMapNameByID(mapID))..
            FormatText("zoneName", GetRealZoneText())..
            FormatText("inWorld", KT.inWorld)..
            FormatText("inInstance", KT.inInstance)..
            FormatText("inScenario", KT.inScenario)..
            FormatText("hidden", KT.hidden)..
            FormatText("locked", KT.locked)..
            FormatTable(data)

    return telemetry
end

if BugGrabber then
    if not BugGrabber.RegisterCallback then
        BugGrabber.setupCallbacks()
    end

    BugGrabber.RegisterCallback(KT, "BugGrabber_BugGrabbed", function(_, err)
        if not err or not err.message then return end
        if not IsOwnError(err.message) then return end

        local telemetry = BuildTelemetry()
        if telemetry == "" then
            if err.KTbckStack then
                err.stack = err.KTbckStack
                err.KTbckStack = nil
            end
            err.KTtelemetry = nil
        else
            if telemetry ~= err.KTtelemetry then
                if err.KTbckStack then
                    err.stack = err.KTbckStack
                    err.KTbckStack = nil
                end
                err.KTtelemetry = nil
            end
            if not err.KTtelemetry then
                err.KTtelemetry = telemetry
                err.KTbckStack = err.stack
                err.stack = (err.stack or "")..telemetry
            end
        end
    end)
else
    local function InstallErrorHandler()
        local errorHandler = geterrorhandler()
        seterrorhandler(function(msg)
            if IsOwnError(msg) then
                msg = msg..BuildTelemetry().."\n"
            end
            errorHandler(msg)
        end)
    end

    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", InstallErrorHandler)
    f:RegisterEvent("PLAYER_LOGIN")
end

-- ---------------------------------------------------------------------------------------------------------------------

---Set telemetry value.
---@param key string|number
---@param value any
---@param parent string|number
---@param parent2 string|number
function KT.T_Set(key, value, parent, parent2)
    if value == nil then
        value = "nil"
    end

    if parent then
        local target = data[parent]
        if not target then
            target = {}
            data[parent] = target
        end
        if parent2 then
            target = target[parent2]
            if not target then
                target = {}
                data[parent][parent2] = target
            end
        end
        target[key] = value
    else
        data[key] = value
    end
end

---Clear telemetry.
function KT.T_Clear()
    wipe(data)
end