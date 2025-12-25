--- MSA-Event-1.0
--- Based on AceEvent-3.0
--- - Wrapped API - aggregates all same events into one frame and control them separately
--- - Unwrapped API - same as AceEvent
--- Copyright (c) 2024-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-Event-1.0", 2

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

local CallbackHandler = LibStub("CallbackHandler-1.0")

-- Lua API
local pairs = pairs
local strmatch = string.match
local tinsert = table.insert
local tonumber = tonumber
local type = type

-- Registry Blizzard Events
lib.frame = lib.frame or CreateFrame("Frame")
lib.events = lib.events or CallbackHandler:New(lib, "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents")

function lib.events:OnUsed(target, event)
    lib.frame:RegisterEvent(event)
end

function lib.events:OnUnused(target, event)
    lib.frame:UnregisterEvent(event)
end

lib.frame:SetScript("OnEvent", function(_, event, ...)
    lib.events:Fire(event, ...)
end)

-- Registry Event Handlers
lib.eventHandlers = lib.eventHandlers or {}

local function handleEvent(self, event, ...)
    local list = lib.eventHandlers[event]
    if list then
        --print("|cff00ffff"..event, "|r...", ...)
        for id, handler in pairs(list) do
            --print(id, "...", handler.owner.moduleName or handler.owner.name or handler.owner)
            local eventID = event.."-"..id
            if type(handler.fn) == "function" then
                handler.fn(eventID, ...)
            else
                self[handler.fn](self, eventID, ...)
            end
        end
    end
end

function lib:RegEvent(event, methodOrName, object)
    local owner = object or self
    local list = lib.eventHandlers[event]
    if not list then
        list = {}
        lib.eventHandlers[event] = list
        self:RegisterEvent(event, handleEvent, self)
    end
    tinsert(list, {
        fn = methodOrName,
        owner = owner
    })
    --print("|cff00ff00REG|r ...", event.."-"..#list, "...", owner.moduleName or owner.name or owner)
end

function lib:UnregEvent(eventID)
    local event, id = strmatch(eventID, "^(%S+)-(%d+)$")
    local list = lib.eventHandlers[event]
    if list then
        id = tonumber(id)
        --print("|cffff0000UNREG|r ...", eventID, "...", list[id].owner.moduleName or list[id].owner.name or list[id].owner)
        list[id] = nil
        if not next(list) then
            self:UnregisterEvent(event)
        end
    end
end

function lib:UnregAllEvents()
    --print("|cffff0000UNREG|r ... All Events")
    lib.eventHandlers = {}
    self:UnregisterAllEvents()
end

function lib:RegSignal(event, call, object, ...)
    local owner = object or self
    --print("|cff00ff00REG Signal|r ...", event, "...", owner.moduleName or owner.name or owner, "...", ...)
    EventRegistry:RegisterCallback(self.name.."."..event, owner[call or event] or call, owner, ...)
end

function lib:UnregSignal(event, object)
    local owner = object or self
    --print("|cffff0000UNREG Signal|r ...", event, "...", owner.moduleName or owner.name or owner)
    EventRegistry:UnregisterCallback(self.name.."."..event, owner)
end

function lib:SendSignal(event, ...)
    --print("|cffffff00SEND Signal|r ...", event, "...", ...)
    EventRegistry:TriggerEvent(self.name.."."..event, ...)
end

------------------------------------------------------------------------------------------------------------------------
-- Embed handling
------------------------------------------------------------------------------------------------------------------------

lib.embeds = lib.embeds or {}

local mixins = {
    "RegEvent", "UnregEvent", "UnregAllEvents",  -- Wrapped
    "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents",  -- Unwrapped
    "RegSignal", "UnregSignal", "SendSignal"
}

function lib:Embed(target)
    for _, v in pairs(mixins) do
        target[v] = self[v]
    end
    self.embeds[target] = true
    return target
end

function lib:OnEmbedDisable(target)
    target:UnregAllEvents()
end

for target in pairs(lib.embeds) do
    lib:Embed(target)
end