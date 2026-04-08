--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local SS = KT:NewSubsystem("Telemetry")

-- Lua API
local format = string.format
local pairs = pairs
local pcall = pcall
local select = select
local tconcat = table.concat
local tostring = tostring
local type = type

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

    return format(LINE_PATTERN, name, tconcat(values, "|cff808080 | |r"))
end

local function FormatTable(tbl, prefix)
    prefix = prefix or ""
    local parts = {}

    for k, v in pairs(tbl) do
        local valueType = type(v)
        if valueType ~= "function" then
            if valueType == "table" then
                parts[#parts+1] = FormatText(prefix..k, "{")
                parts[#parts+1] = FormatTable(v, prefix.."   ")
                parts[#parts+1] = "\n|cffffffff"..prefix.."}|r"
            else
                parts[#parts+1] = FormatText(prefix..k, v)
            end
        end
    end

    return tconcat(parts)
end

local function BuildTelemetry()
    local mapID = KT.GetCurrentMapAreaID()

    local telemetry = "\n|cff808080"..TITLE_SLUG.." Telemetry:|r"..
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

local InstallTelemetry

if BugGrabber then
    local errors = {}

    EventRegistry:RegisterCallback("BugGrabber.BugGrabbed", function(_, tableID)
        if errors[tableID] then return end
        errors[tableID] = true

        local err = BugGrabber:GetErrorByID(tableID)
        if not err or not err.message then return end
        if not IsOwnError(err.message) then return end

        local ok, telemetry = pcall(BuildTelemetry)
        if ok and telemetry then
            err.KTtelemetry = telemetry
        end
    end, KT)

    function InstallTelemetry()
        if not BugSack then return end

        local bck_BugSack_FormatError = BugSack.FormatError
        function BugSack:FormatError(err)
            local result = bck_BugSack_FormatError(self, err)
            if err.KTtelemetry then
                result = result:gsub("(\n\nLocals:\n)", err.KTtelemetry.."%1", 1)
                if not result:find(err.KTtelemetry, 1, true) then
                    result = result..err.KTtelemetry
                end
            end
            return result
        end
    end
else
    function InstallTelemetry()
        local errorHandler = geterrorhandler()
        seterrorhandler(function(msg)
            if IsOwnError(msg) then
                local ok, telemetry = pcall(BuildTelemetry)
                if ok and telemetry then
                    msg = msg.."\n"..telemetry.."\n"
                end
            end
            errorHandler(msg)
        end)
    end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", InstallTelemetry)
f:RegisterEvent("PLAYER_LOGIN")

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