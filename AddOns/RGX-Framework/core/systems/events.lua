--[[
    RGX-Framework - Events and Messages

    RGX does not need LibStub-style indirection for its own internal foundation.
    Instead, it exposes a tiny native dispatcher for:
    - Blizzard events
    - framework-wide messages
    - lightweight callback emitters for module-local signals
--]]

local addonName, RGX = ...

RGX.events = RGX.events or {}
RGX.unitEvents = RGX.unitEvents or {}
RGX.messages = RGX.messages or {}
RGX.pendingFrameEvents = RGX.pendingFrameEvents or {}
RGX.registeredFrameEvents = RGX.registeredFrameEvents or {}
RGX.allFrameEventsRegistered = RGX.allFrameEventsRegistered or false
RGX.wakeFrameEvents = RGX.wakeFrameEvents or {
    PLAYER_LOGIN = true,
    PLAYER_ENTERING_WORLD = true,
    PLAYER_REGEN_ENABLED = true,
    PET_BATTLE_CLOSE = true,
}

local canRegisterFrameEventsNow
local flushPendingFrameEvents
local armRegistrationDriver

-- Registrations attempted from a blocked-but-valid context are retried by the
-- next-frame driver. Truly rejected registrations (protection layer refuses
-- the event even from an untainted stack) are dropped after this many tries
-- so a permanently-blocked event can never spin forever.
local MAX_REGISTER_ATTEMPTS = 10

local function canAccessValue(value)
    local api = RGX.API
    if type(api) == "table" and type(api.CanAccessValue) == "function" then
        return api.CanAccessValue(value) == true
    end
    return false
end

local function canAccessTable(value)
    local api = RGX.API
    if type(api) == "table" and type(api.CanAccessTable) == "function" then
        return api.CanAccessTable(value) == true
    end
    return false
end

local function safeErrorText(err)
    if not canAccessValue(err) then
        return "<inaccessible error>"
    end
    return tostring(err)
end

local function reportDispatchError(channel, name, id, err)
    local message = string.format(
        "[RGX:%s] Error in '%s' handler '%s': %s",
        tostring(channel),
        tostring(name),
        tostring(id),
        safeErrorText(err)
    )

    if type(_G.geterrorhandler) == "function" then
        _G.geterrorhandler()(message)
        return
    end

    print("|cFFFF4444" .. message .. "|r")
end

local function reportEventRegistrationError(action, event, err)
    local message = string.format(
        "[RGX:event] %s failed for '%s': %s",
        tostring(action),
        tostring(event),
        safeErrorText(err)
    )

    if type(_G.geterrorhandler) == "function" then
        _G.geterrorhandler()(message)
        return
    end

    print("|cFFFF4444" .. message .. "|r")
end

-- Returns ok[, permanent]:
--   ok=true                     registered (verified when verifiable)
--   ok=false, permanent=true    known-invalid on this client; never retry
--   ok=false                    transient (unsafe stack / rejected attempt)
local function safeRegisterFrameEvent(frame, event)
    if not frame or type(event) ~= "string" or event == "" then
        return false, true
    end

    if C_EventUtils and type(C_EventUtils.IsEventValid) == "function"
        and C_EventUtils.IsEventValid(event) ~= true then
        return false, true
    end

    if RGX.registeredFrameEvents[event] then
        return true
    end

    if not canRegisterFrameEventsNow() then
        return false
    end

    -- pcall isolates ordinary Lua/API errors only. ADDON_ACTION_FORBIDDEN is
    -- raised by the client's protection machinery, not converted to a Lua
    -- error, so pcall success is NOT proof the registration stuck. The
    -- authoritative success signal, when the client provides it, is
    -- frame:IsEventRegistered(event).
    local ok = pcall(frame.RegisterEvent, frame, event)
    if not ok then
        return false
    end

    if type(frame.IsEventRegistered) == "function" and not frame:IsEventRegistered(event) then
        return false
    end

    RGX.registeredFrameEvents[event] = true
    if RGX.pendingFrameEventAttempts then
        RGX.pendingFrameEventAttempts[event] = nil
    end
    return true
end

local function hasAnyEventHandlers(rgx, event)
    return (rgx.events and rgx.events[event] and next(rgx.events[event]) ~= nil)
        or (rgx.unitEvents and rgx.unitEvents[event] and next(rgx.unitEvents[event]) ~= nil)
end

local function queuePendingFrameEvent(rgx, event)
    if type(event) ~= "string" or event == "" then
        return
    end

    rgx.pendingFrameEvents[event] = true
    armRegistrationDriver()
end

local function unqueuePendingFrameEvent(rgx, event)
    if rgx.pendingFrameEvents then
        rgx.pendingFrameEvents[event] = nil
    end
    if rgx.pendingFrameEventAttempts then
        rgx.pendingFrameEventAttempts[event] = nil
    end
end

canRegisterFrameEventsNow = function()
    if (RGX._dispatchDepth or 0) > 0 then
        return false
    end

    if (RGX._timerDispatchDepth or 0) > 0 then
        return false
    end

    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        return false
    end

    if type(UnitAffectingCombat) == "function" and UnitAffectingCombat("player") then
        return false
    end

    if C_PetBattles and type(C_PetBattles.IsInBattle) == "function" and C_PetBattles.IsInBattle() then
        return false
    end

    return true
end

local function safeUnregisterFrameEvent(frame, event)
    if not frame or type(event) ~= "string" or event == "" then
        return false
    end

    if RGX.allFrameEventsRegistered then
        RGX.registeredFrameEvents[event] = nil
        return true
    end

    if RGX.wakeFrameEvents and RGX.wakeFrameEvents[event] then
        return true
    end

    local ok = pcall(frame.UnregisterEvent, frame, event)
    if ok then
        RGX.registeredFrameEvents[event] = nil
    end
    return ok
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

RGX.pendingFrameEventAttempts = RGX.pendingFrameEventAttempts or {}

flushPendingFrameEvents = function(rgx)
    if not rgx or not rgx.pendingFrameEvents or not next(rgx.pendingFrameEvents) then
        return false
    end

    if not canRegisterFrameEventsNow() then
        return false
    end

    local changed = false
    for event in pairs(rgx.pendingFrameEvents) do
        if not hasAnyEventHandlers(rgx, event) then
            unqueuePendingFrameEvent(rgx, event)
            changed = true
        else
            local ok, permanent = safeRegisterFrameEvent(rgx.eventFrame, event)
            if ok or permanent then
                unqueuePendingFrameEvent(rgx, event)
                changed = true
            else
                local attempts = (rgx.pendingFrameEventAttempts[event] or 0) + 1
                rgx.pendingFrameEventAttempts[event] = attempts
                if attempts >= MAX_REGISTER_ATTEMPTS then
                    -- Repeatedly rejected even from a clean next-frame stack:
                    -- the client's protection layer refuses this event. Drop it
                    -- instead of retrying forever.
                    unqueuePendingFrameEvent(rgx, event)
                    changed = true
                    if type(rgx.Debug) == "function" then
                        rgx:Debug("[RGX:event] dropping '" .. tostring(event)
                            .. "': native registration repeatedly rejected (protection layer)")
                    end
                end
            end
        end
    end
    return changed
end

-- Anonymous next-frame registration driver. Native Frame:RegisterEvent calls
-- must NOT run while unwinding Blizzard's event dispatch (or a timer dispatch,
-- or combat): the protection layer can flag any C call on those stacks with
-- ADDON_ACTION_FORBIDDEN. Deferred registrations therefore wait for this
-- driver's OnUpdate, which always runs on a clean frame-tick stack.
--
-- The driver stays armed while pending registrations exist and disarms itself
-- when the queue is empty. It is a no-op while any unsafe context is active.
RGX._registrationDriver = CreateFrame("Frame")
RGX._registrationDriver:Hide()
armRegistrationDriver = function()
    RGX._registrationDriver:Show()
end
RGX._registrationDriver:SetScript("OnUpdate", function(driver)
    if type(RGX.pendingFrameEvents) ~= "table" or not next(RGX.pendingFrameEvents) then
        driver:Hide()
        return
    end
    if not canRegisterFrameEventsNow() then
        return
    end
    flushPendingFrameEvents(RGX)
    if type(RGX.pendingFrameEvents) ~= "table" or not next(RGX.pendingFrameEvents) then
        driver:Hide()
    end
end)

function RGX:FlushPendingFrameEvents()
    return flushPendingFrameEvents(self)
end

local function registerWakeFrameEvents(frame)
    if not frame then return end
    for event in pairs(RGX.wakeFrameEvents) do
        if not RGX.registeredFrameEvents[event] then
            local ok = pcall(frame.RegisterEvent, frame, event)
            if ok
                and (type(frame.IsEventRegistered) ~= "function"
                    or frame:IsEventRegistered(event)) then
                RGX.registeredFrameEvents[event] = true
            end
        end
    end
end

registerWakeFrameEvents(RGX.eventFrame)

RGX.eventFrame:SetScript("OnEvent", function(_, event, ...)
    RGX:FireEvent(event, ...)
end)

function RGX:RegisterEvent(event, callback, id, owner)
    local created = not hasAnyEventHandlers(self, event)
    local handlerId = registerHandler(self.events, event, callback, id, owner, self)
    if not handlerId then
        return false
    end

    if created then
        if canRegisterFrameEventsNow() then
            if not safeRegisterFrameEvent(self.eventFrame, event) then
                queuePendingFrameEvent(self, event)
            end
        else
            queuePendingFrameEvent(self, event)
        end
    end

    return handlerId
end

function RGX:UnregisterEvent(event, id)
    local removed = unregisterHandler(self.events, event, id)
    if removed and not hasAnyEventHandlers(self, event) then
        unqueuePendingFrameEvent(self, event)
        safeUnregisterFrameEvent(self.eventFrame, event)
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

    if not hasAnyEventHandlers(self, event) then
      self.events[event] = nil
      unqueuePendingFrameEvent(self, event)
      safeUnregisterFrameEvent(self.eventFrame, event)
    end
  end

  return removed
end

-- Register a unit-filtered event (e.g. UNIT_AURA for "player" and "target").
-- WoW's RegisterUnitEvent(event, unit1, unit2) fires the callback only when
-- the event concerns one of the specified unit tokens.
--
--   RGX:RegisterUnitEvent("UNIT_AURA", "player", callback, "myId")
--   RGX:RegisterUnitEvent("UNIT_AURA", {"player","target"}, callback, "myId")
--
-- The callback receives (event, unit, ...) — the unit token is always the
-- second argument, matching WoW's native unit event signature.
function RGX:RegisterUnitEvent(event, unit, callback, id, owner)
  if not canAccessValue(event) or type(event) ~= "string" or event == "" then return false end

  local units
  if type(unit) == "table" then
    if not canAccessTable(unit) then return false end
    units = {}
    for _, candidate in ipairs(unit) do
      if not canAccessValue(candidate)
          or type(candidate) ~= "string"
          or candidate == "" then
        return false
      end
      units[#units + 1] = candidate
    end
    if #units == 0 then return false end
  elseif canAccessValue(unit) and type(unit) == "string" and unit ~= "" then
    units = { unit }
  else
    return false
  end

  local created = not hasAnyEventHandlers(self, event)
  local handlerId = registerHandler(self.unitEvents, event, callback, id, owner, self)
  if not handlerId then return false end

  local entry = self.unitEvents[event][handlerId]
  entry.units = units

  if created then
    if canRegisterFrameEventsNow() then
      if not safeRegisterFrameEvent(self.eventFrame, event) then
        queuePendingFrameEvent(self, event)
      end
    else
      queuePendingFrameEvent(self, event)
    end
  end

  return handlerId
end

function RGX:UnregisterUnitEvent(event, id)
  local removed = unregisterHandler(self.unitEvents, event, id)
  if removed and not hasAnyEventHandlers(self, event) then
    unqueuePendingFrameEvent(self, event)
    safeUnregisterFrameEvent(self.eventFrame, event)
  end
  return removed
end

function RGX:UnregisterAllUnitEvents(id)
  if type(id) ~= "string" or id == "" then
    return false
  end

  local removed = false
  local touched = {}
  for event, bucket in pairs(self.unitEvents) do
    if bucket[id] then
      bucket[id] = nil
      removed = true
      touched[event] = true
    end
    if not next(bucket) then
      self.unitEvents[event] = nil
    end
  end

  for event in pairs(touched) do
    if not hasAnyEventHandlers(self, event) then
      unqueuePendingFrameEvent(self, event)
      safeUnregisterFrameEvent(self.eventFrame, event)
    end
  end

  return removed
end

function RGX:FireEvent(event, ...)
  self._dispatchDepth = (self._dispatchDepth or 0) + 1

  local count = dispatchHandlers(self.events, "event", event, ...)

  local unitBucket = self.unitEvents[event]
  if unitBucket then
    local unitToken = select(1, ...)
    if canAccessValue(unitToken) then
      for id, entry in pairs(unitBucket) do
        local match = false
        if entry.units then
          for _, u in ipairs(entry.units) do
            if canAccessValue(u) and u == unitToken then
              match = true
              break
            end
          end
        end
        if match then
          local ok, err
          if entry.callbackType == "string" then
            ok, err = pcall(entry.owner[entry.callback], entry.owner, event, ...)
          else
            ok, err = pcall(entry.callback, event, ...)
          end
          if not ok then
            reportDispatchError("unitEvent", event, id, err)
          end
          count = count + 1
        end
      end
    end
  end

  self._dispatchDepth = math.max(0, (self._dispatchDepth or 1) - 1)
  -- No native registration here: this is still Blizzard's event-dispatch stack.
  -- The anonymous registration driver drains pending events on the next frame.

  return count
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

local lastBlockedReport = 0
local function reportActionBlock(event, blockedAddon, blockedFunction)
    local blocked = tostring(blockedAddon or "UNKNOWN")
    if blocked ~= "UNKNOWN"
        and blocked ~= addonName
        and blocked ~= "RGX-Framework"
        and not string.find(blocked, "RGX", 1, true) then
        return
    end

    local now = type(GetTimePreciseSec) == "function" and GetTimePreciseSec()
        or (type(GetTime) == "function" and GetTime())
        or 0
    if lastBlockedReport + 1 > now then
        return
    end

    lastBlockedReport = now
    local message = string.format(
        "[RGX:blocked] event=%s addon=%s function=%s",
        tostring(event),
        blocked,
        tostring(blockedFunction or "UNKNOWN")
    )

    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. message .. "|r")
    end

    reportDispatchError("blocked", event, blocked, string.format(
        "function=%s",
        tostring(blockedFunction or "UNKNOWN")
    ))
end

-- Do not auto-register ADDON_ACTION_BLOCKED/FORBIDDEN diagnostics here.
-- Subscribing to those diagnostics can itself be attributed to RGX during
-- restricted startup/reload phases, creating recursive BugGrabber noise.

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