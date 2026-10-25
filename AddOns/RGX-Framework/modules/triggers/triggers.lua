--=====================================================================================
-- RGX-Framework | RGXTriggers
-- Trigger state store: the substrate for the trigger evaluation engine.
--
-- Usage:
--   local Triggers = RGX:GetTriggers()
--   local trigger = Triggers:New("lust")
--
--   trigger:Update("player", { active = true })
--   trigger:UpdateProgress("player", { duration = 40 })       -- timed progress
--   trigger:UpdateProgress("player", { value = 3, total = 8 }) -- static progress
--
--   Triggers:OnChanged("lust", function(id, states)
--       -- states is the live clone-keyed table; states.player.changed
--       -- reflects the engine diff of the last write
--   end)
--
-- Contract (mirrors the WeakAuras baseline, AddonLearner pass 5):
--   - Trigger authors never decide when to "fire". They mutate clone-keyed
--     state; the engine diffs every field write and sets state.changed only
--     when a value actually changed or the clone is new.
--   - Stale clones cannot survive: Sweep(keepIds) removes every clone the
--     author did not keep alive in one coalesced notification.
--   - Progress states carry a guaranteed shape (progressType, duration,
--     expirationTime, value, total, inverse, autoHide) so conditions and
--     displays read one stable form.
--   - Change notifications are failure-isolated: one handler error cannot
--     break dispatch or other handlers.
--=====================================================================================

local addonName, RGX = ...

local Triggers = {
    _registry = {},
    _changeHandlers = {},
}

-- ── Callback helpers ──────────────────────────────────────────────────────────

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    list[#list + 1] = fn
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXTriggers] Change handler error: " .. tostring(err)) end
    end
end

-- ── Trigger instances ─────────────────────────────────────────────────────────

local Trigger = {}

local function ValidCloneId(cloneId)
    return type(cloneId) == "string" or type(cloneId) == "number"
end

local function NotifyChanged(id, states)
    local handlers = Triggers._changeHandlers[id]
    if handlers then Fire(handlers, id, states) end
end

-- Shared diff path: fields are compared before applied, clearKeys are removed
-- when present, and one coalesced notification fires only when something
-- actually changed. `changed` describes the last write, not a sticky flag.
local function UpdateInternal(self, cloneId, fields, clearKeys)
    local state = self.states[cloneId]
    local isNew = state == nil
    if isNew then
        state = {}
        self.states[cloneId] = state
    end

    local changed = isNew
    if clearKeys then
        for _, key in ipairs(clearKeys) do
            if state[key] ~= nil then
                state[key] = nil
                changed = true
            end
        end
    end
    for key, value in pairs(fields) do
        if state[key] ~= value then
            state[key] = value
            changed = true
        end
    end
    state.changed = changed

    if changed then NotifyChanged(self.id, self.states) end
    return changed, state
end

--- Update one clone's fields. Returns changed, state.
function Trigger:Update(cloneId, fields)
    if not ValidCloneId(cloneId) then
        error("RGXTriggers: clone id must be a string or number, got " .. type(cloneId), 2)
    end
    if type(fields) ~= "table" then
        error("RGXTriggers: Update fields must be a table, got " .. type(fields), 2)
    end
    return UpdateInternal(self, cloneId, fields, nil)
end

--- Update one clone's progress with a guaranteed state shape.
-- Timed form:  { duration = seconds, autoHide = bool? }
-- Static form: { value = number, total = number > 0, inverse = bool? }
-- Switching forms clears the other form's fields in the same diff.
function Trigger:UpdateProgress(cloneId, progress)
    if not ValidCloneId(cloneId) then
        error("RGXTriggers: clone id must be a string or number, got " .. type(cloneId), 2)
    end
    if type(progress) ~= "table" then
        error("RGXTriggers: UpdateProgress progress must be a table, got " .. type(progress), 2)
    end

    if progress.duration ~= nil then
        local duration = progress.duration
        if type(duration) ~= "number" or duration ~= duration or duration < 0 or duration >= math.huge then
            error("RGXTriggers: timed progress duration must be a finite number >= 0", 2)
        end
        local autoHide = progress.autoHide
        if autoHide ~= nil and type(autoHide) ~= "boolean" then
            error("RGXTriggers: timed progress autoHide must be a boolean", 2)
        end

        local fields = {
            progressType = "timed",
            duration = duration,
            expirationTime = (GetTime and GetTime() or 0) + duration,
        }
        if autoHide ~= nil then fields.autoHide = autoHide end
        -- Clearing autoHide before applying fields keeps the shape single-form.
        return UpdateInternal(self, cloneId, fields, { "value", "total", "inverse", "autoHide" })
    end

    local value, total = progress.value, progress.total
    if type(value) ~= "number" or value ~= value then
        error("RGXTriggers: static progress requires a numeric value", 2)
    end
    if type(total) ~= "number" or total ~= total or total <= 0 then
        error("RGXTriggers: static progress requires a numeric total > 0", 2)
    end
    local inverse = progress.inverse
    if inverse ~= nil and type(inverse) ~= "boolean" then
        error("RGXTriggers: static progress inverse must be a boolean", 2)
    end

    local fields = {
        progressType = "static",
        value = value,
        total = total,
    }
    if inverse ~= nil then fields.inverse = inverse end
    return UpdateInternal(self, cloneId, fields, { "duration", "expirationTime", "autoHide" })
end

--- Remove one clone. Returns true when a clone was removed.
function Trigger:Remove(cloneId)
    if not ValidCloneId(cloneId) then
        error("RGXTriggers: clone id must be a string or number, got " .. type(cloneId), 2)
    end
    if self.states[cloneId] == nil then return false end
    self.states[cloneId] = nil
    NotifyChanged(self.id, self.states)
    return true
end

--- Remove every clone not present in the keep set (array or map). A nil keep
-- set removes all clones. Returns the number removed; one coalesced
--- notification fires when at least one clone was removed.
function Trigger:Sweep(keep)
    if keep ~= nil and type(keep) ~= "table" then
        error("RGXTriggers: Sweep keep set must be a table, got " .. type(keep), 2)
    end

    local removed = 0
    for cloneId in pairs(self.states) do
        if keep == nil or keep[cloneId] ~= true then
            self.states[cloneId] = nil
            removed = removed + 1
        end
    end
    if removed > 0 then NotifyChanged(self.id, self.states) end
    return removed
end

--- Remove all clones. Returns the number removed.
function Trigger:Clear()
    return self:Sweep(nil)
end

--- The live clone-keyed state table. Read-mostly; writes belong to the
--- engine methods above.
function Trigger:States()
    return self.states
end

--- Number of live clones.
function Trigger:Count()
    local count = 0
    for _ in pairs(self.states) do count = count + 1 end
    return count
end

-- ── Registry ──────────────────────────────────────────────────────────────────

--- Create a trigger instance keyed by id. Ids are non-empty strings without
--- spaces; a duplicate id fails before anything registers.
function Triggers:New(id)
    if type(id) ~= "string" or #id == 0 or id:find("%s") then
        error("RGXTriggers: trigger id must be a non-empty string without spaces", 2)
    end
    if self._registry[id] then
        error("RGXTriggers: trigger '" .. id .. "' already exists", 2)
    end

    local trigger = setmetatable({ id = id, states = {} }, { __index = Trigger })
    self._registry[id] = trigger
    return trigger
end

--- Look up a trigger instance by id.
function Triggers:Get(id)
    if type(id) ~= "string" then return nil end
    return self._registry[id]
end

--- Remove a trigger: clears its clones (with change notifications) and drops
--- its change handlers. Returns true when the trigger existed.
function Triggers:Remove(id)
    local trigger = type(id) == "string" and self._registry[id] or nil
    if not trigger then return false end
    trigger:Clear()
    self._registry[id] = nil
    self._changeHandlers[id] = nil
    return true
end

--- Register a change handler for one trigger id: function(id, states) fires
--- whenever that trigger's diff, progress update, or removal changed
--- anything. Returns an unsubscribe function.
function Triggers:OnChanged(id, fn)
    if type(id) ~= "string" or #id == 0 then
        error("RGXTriggers: OnChanged id must be a non-empty string", 2)
    end
    local list = self._changeHandlers[id]
    if not list then
        list = {}
        self._changeHandlers[id] = list
    end
    return AddCb(list, fn)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXTriggers = Triggers
RGX:RegisterModule("triggers", Triggers, { category = "game" })
