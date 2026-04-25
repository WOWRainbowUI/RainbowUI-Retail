--[[
    RGX-Framework - Events and Messages

    RGX does not need LibStub-style indirection for its own internal foundation.
    Instead, it exposes a tiny native dispatcher for:
    - Blizzard events
    - framework-wide messages
    - lightweight callback emitters for module-local signals
--]]

local _, RGX = ...

RGX.events = RGX.events or {}
RGX.messages = RGX.messages or {}

local function reportDispatchError(channel, name, id, err)
    local message = string.format(
        "[RGX:%s] Error in '%s' handler '%s': %s",
        tostring(channel),
        tostring(name),
        tostring(id),
        tostring(err)
    )

    if type(_G.geterrorhandler) == "function" then
        _G.geterrorhandler()(message)
        return
    end

    print("|cFFFF4444" .. message .. "|r")
end

local function makeHandlerId(callback, id)
    if type(id) == "string" and id ~= "" then
        return id
    end

    if type(callback) == "string" and callback ~= "" then
        return callback
    end

    return tostring(callback)
end

local function registerHandler(container, key, callback, id, owner, defaultOwner)
    if type(key) ~= "string" or key == "" then
        return false
    end

    local callbackType = type(callback)
    if callbackType ~= "function" and callbackType ~= "string" then
        return false
    end

    owner = owner or defaultOwner
    if callbackType == "string" then
        if type(owner) ~= "table" or type(owner[callback]) ~= "function" then
            return false
        end
    end

    local bucket = container[key]
    if not bucket then
        bucket = {}
        container[key] = bucket
    end

    local handlerId = makeHandlerId(callback, id)
    bucket[handlerId] = {
        callback = callback,
        callbackType = callbackType,
        owner = owner,
    }

    return handlerId
end

local function unregisterHandler(container, key, id)
    local bucket = container[key]
    if not bucket or type(id) ~= "string" or id == "" then
        return false
    end

    bucket[id] = nil
    if not next(bucket) then
        container[key] = nil
    end

    return true
end

local function unregisterHandlerEverywhere(container, id)
    if type(id) ~= "string" or id == "" then
        return false
    end

    local removed = false
    for key, bucket in pairs(container) do
        if bucket[id] then
            bucket[id] = nil
            removed = true
        end

        if not next(bucket) then
            container[key] = nil
        end
    end

    return removed
end

local function dispatchHandlers(container, channel, key, ...)
    local bucket = container[key]
    if not bucket then
        return 0
    end

    local queued = {}
    for id, entry in pairs(bucket) do
        queued[#queued + 1] = {
            id = id,
            entry = entry,
        }
    end

    for index = 1, #queued do
        local item = queued[index]
        local entry = item.entry

        local ok, err
        if entry.callbackType == "string" then
            ok, err = pcall(entry.owner[entry.callback], entry.owner, key, ...)
        else
            ok, err = pcall(entry.callback, key, ...)
        end

        if not ok then
            reportDispatchError(channel, key, item.id, err)
        end
    end

    return #queued
end

RGX.eventFrame = RGX.eventFrame or CreateFrame("Frame")
RGX.eventFrame:SetScript("OnEvent", function(_, event, ...)
    RGX:FireEvent(event, ...)
end)

function RGX:RegisterEvent(event, callback, id, owner)
    local created = not self.events[event]
    local handlerId = registerHandler(self.events, event, callback, id, owner, self)
    if not handlerId then
        return false
    end

    if created then
        self.eventFrame:RegisterEvent(event)
    end

    return handlerId
end

function RGX:UnregisterEvent(event, id)
    local removed = unregisterHandler(self.events, event, id)
    if removed and not self.events[event] then
        self.eventFrame:UnregisterEvent(event)
    end

    return removed
end

function RGX:UnregisterAllEvents(id)
    local removed = false

    for event, bucket in pairs(self.events) do
        if bucket[id] then
            bucket[id] = nil
            removed = true
        end

        if not next(bucket) then
            self.events[event] = nil
            self.eventFrame:UnregisterEvent(event)
        end
    end

    return removed
end

function RGX:FireEvent(event, ...)
    return dispatchHandlers(self.events, "event", event, ...)
end

function RGX:RegisterMessage(message, callback, id, owner)
    return registerHandler(self.messages, message, callback, id, owner, self)
end

function RGX:UnregisterMessage(message, id)
    return unregisterHandler(self.messages, message, id)
end

function RGX:UnregisterAllMessages(id)
    return unregisterHandlerEverywhere(self.messages, id)
end

function RGX:SendMessage(message, ...)
    return dispatchHandlers(self.messages, "message", message, ...)
end

RGX.RegisterCallback = RGX.RegisterMessage
RGX.UnregisterCallback = RGX.UnregisterMessage
RGX.UnregisterAllCallbacks = RGX.UnregisterAllMessages
RGX.FireMessage = RGX.SendMessage

function RGX:CreateEmitter(name)
    local emitter = {
        name = tostring(name or "RGXEmitter"),
        callbacks = {},
    }

    function emitter:RegisterCallback(signal, callback, id, owner)
        return registerHandler(self.callbacks, signal, callback, id, owner, self)
    end

    function emitter:UnregisterCallback(signal, id)
        return unregisterHandler(self.callbacks, signal, id)
    end

    function emitter:UnregisterAllCallbacks(id)
        return unregisterHandlerEverywhere(self.callbacks, id)
    end

    function emitter:Fire(signal, ...)
        return dispatchHandlers(self.callbacks, self.name, signal, ...)
    end

    return emitter
end
