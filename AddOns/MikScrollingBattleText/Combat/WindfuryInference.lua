-- Optional presentation inference. Combat ownership and spell identity stay
-- with the reader; only complete public source accounting can add an icon.
local Inference = {}
Inference.__index = Inference
MikSBT.Components.WindfuryInference = Inference

local Restricted = MikSBT.API.RestrictedValue
local FRAME_WINDOW, SOURCE_WINDOW = 0.001, 1.6
local WEAPON_SIGNAL_WINDOW = 0.05
local MAX_SOURCES, MAX_TARGETS, MAX_PENDING = 8, 2, 64
local MAX_RESERVATIONS, MAX_LINES, MAX_OUTCOMES = 8, 32, 64
local STORMSTRIKE, WEAPON, TOTEM, ICON = 17364, 439440, 10610, 8232
local nextInstance = 0

local function Number(value)
    value = Restricted:Number(value)
    if value and value == value and math.abs(value) < math.huge then
        return value
    end
end

local function Text(value)
    value = Restricted:String(value)
    if value and #value > 0 and #value <= 160 then return value end
end

local function SameFrame(first, second)
    return math.abs(first - second) <= FRAME_WINDOW
end

local function Fields(value, schema)
    local input = Restricted:Table(value)
    if not input then return end
    local result = {}
    for field, expected in pairs(schema) do
        local item = rawget(input, field)
        if not Restricted:CanAccess(item) then return end
        if item ~= nil then
            if type(item) ~= expected then return end
            if expected == "number" and not Number(item) then return end
            if expected == "string" and not Text(item) then return end
        end
        result[field] = item
    end
    return result
end

local RECORD_FIELDS = {
    event = "string", school = "number", crit = "boolean", pet = "boolean",
}
local RESULT_FIELDS = {
    who = "string", spell = "number", procSpell = "number",
    melee = "boolean", tick = "boolean", extra = "boolean",
    ambiguous = "boolean",
}
local INFO_FIELDS = {
    at = "number", key = "string", confirmed = "boolean",
    restrict = "string", receipt = "table", evidence = "table",
}
local RECEIPT_FIELDS = {
    kind = "string", at = "number", key = "string", sourceKey = "string",
    hand = "string", spell = "number", ordinal = "number", who = "string",
    uncertain = "boolean",
}
local EVIDENCE_FIELDS = {
    at = "number", source = "string", kind = "string", shared = "boolean",
    capacity = "number", ambiguous = "boolean", targetContext = "string",
}
local CAST_FIELDS = {
    at = "number", key = "string", spell = "number", guid = "string",
    uncertain = "boolean", conflict = "boolean",
}

function Inference:New(config)
    nextInstance = nextInstance + 1
    return setmetatable({ config = config, sources = {}, generation = 0,
        instance = nextInstance, nextID = 0, pendingCount = 0, latestAt = 0 }, self)
end

local function Release(self, source, decorate)
    for _, frame in ipairs(source.frames) do
        local pending = frame.pending
        frame.pending = {}
        self.pendingCount = self.pendingCount - #pending
        for _, entry in ipairs(pending) do
            local record = entry.record
            record.windfuryInferenceGroup = source.id
            if decorate and entry.damage then
                record.inferredWindfuryIcon = ICON
            end
            self.config.emit(record)
        end
    end
end

function Inference:FlushPlain()
    for _, source in ipairs(self.sources) do
        source.blocked = true
        Release(self, source, false)
    end
end

function Inference:Reset()
    self.generation = self.generation + 1
    for _, source in ipairs(self.sources) do
        source.alive = false
        for _, frame in ipairs(source.frames) do frame.pending = {} end
    end
    self.sources, self.pendingCount = {}, 0
    self.latestAt, self.retiredAt = 0, nil
end

local function Enabled(self)
    if Restricted:Boolean(self.config.enabled()) == true then return true end
    if #self.sources > 0 then
        self:FlushPlain()
        self:Reset()
    end
    return false
end

local function Block(self, source)
    source.blocked = true
    Release(self, source, false)
    local partner = source.swingSource or source.extraSource
    if partner then
        partner.blocked = true
        Release(self, partner, false)
    end
end

local function BlockAll(self)
    for _, source in ipairs(self.sources) do Block(self, source) end
end

local function Retire(self, source)
    if not source.closed and (source.swingSource or source.extraSource) then
        Block(self, source)
    else
        Release(self, source, false)
    end
    source.alive = false
    self.retiredAt = math.max(self.retiredAt or 0, source.at)
    for index, entry in ipairs(self.sources) do
        if entry == source then
            table.remove(self.sources, index)
            return
        end
    end
end

local function ObserveTime(self, at)
    self.latestAt = math.max(self.latestAt, at)
    for index = #self.sources, 1, -1 do
        local source = self.sources[index]
        if self.latestAt - source.at > SOURCE_WINDOW then
            Retire(self, source)
        end
    end
end

local function Complete(self, source)
    source = source.extraSource or source
    if source.closed or not source.sealed then return end
    if source.blocked then Release(self, source, false) return end
    if #source.frames ~= 1 then return end
    if source.weapon and source.totem then Block(self, source) return end
    local capacity = source.weapon and 2 or (source.totem and 1)
    if not capacity then return end
    local frame = source.frames[1]
    local swingSource = source.swingSource or source
    if not swingSource.alive or not swingSource.sealed
        or swingSource.blocked or #swingSource.frames ~= 1 then return end
    local swingFrame = swingSource.frames[1]
    if swingSource ~= source and (swingSource.weapon or swingSource.totem
        or swingFrame.key ~= frame.key or swingFrame.directLines ~= 0
        or frame.swingLines ~= 0 or #frame.reservations ~= 0) then
        Block(self, source)
        return
    end
    if frame.extras > capacity then Block(self, source) return end
    if frame.sharedCapacity and (frame.sharedUsed > frame.sharedCapacity
        or frame.sharedCapacity ~= frame.directLines) then
        Block(self, source)
        return
    end
    if swingFrame.swingUsed > swingFrame.swingLines
        or frame.directUsed > frame.directLines then
        Block(self, source)
        return
    end
    if #swingFrame.reservations == 0 or frame.extras ~= capacity then return end
    for _, reservation in ipairs(swingFrame.reservations) do
        if not reservation.used then return end
    end
    if swingFrame.swingUsed ~= swingFrame.swingLines
        or frame.directUsed ~= frame.directLines then return end
    source.closed = true
    swingSource.closed = true
    Release(self, source, true)
end

local function Source(self, at)
    if not at or at < 0 then return end
    for _, source in ipairs(self.sources) do
        if SameFrame(source.at, at) then return source end
    end
    if self.retiredAt and at <= self.retiredAt + FRAME_WINDOW then return end
    if self.latestAt - at > SOURCE_WINDOW then return end
    if #self.sources == MAX_SOURCES then Retire(self, self.sources[1]) end
    self.nextID = self.nextID + 1
    local source = { at = at, frames = {}, alive = true,
        id = "inferred-windfury:" .. self.instance .. ":" .. self.nextID }
    self.sources[#self.sources + 1] = source
    local generation = self.generation
    self.config.after(0, function()
        if generation ~= self.generation or not source.alive then return end
        if not Enabled(self) then return end
        source.sealed = true
        Complete(self, source)
    end)
    local remaining = math.max(0, SOURCE_WINDOW - (self.latestAt - at))
    self.config.after(remaining, function()
        if generation ~= self.generation or not source.alive then return end
        if not Enabled(self) then return end
        Retire(self, source)
    end)
    return source
end

local function Frame(self, source, key)
    if not key then Block(self, source) return end
    for _, frame in ipairs(source.frames) do
        if frame.key == key then return frame end
    end
    if #source.frames == MAX_TARGETS then Block(self, source) return end
    local frame = { key = key, reservations = {}, pending = {},
        swingLines = 0, directLines = 0, swingUsed = 0, directUsed = 0,
        extras = 0, outcomes = 0, sharedUsed = 0 }
    source.frames[#source.frames + 1] = frame
    if #source.frames > 1 then Block(self, source) end
    return frame
end

local function Reservation(self, source, frame, info)
    if #frame.reservations == MAX_RESERVATIONS then
        Block(self, source)
        return
    end
    for _, previous in ipairs(frame.reservations) do
        if previous.kind == info.kind and (info.kind == "cast"
            or previous.hand == info.hand) then
            if info.guid and previous.guid == info.guid then return end
            Block(self, source)
            return
        end
    end
    frame.reservations[#frame.reservations + 1] = info
end

function Inference:Swing(at, key, hand)
    if not Enabled(self) then return end
    at, key, hand = Number(at), Text(key), Text(hand)
    if not at or not key or (hand ~= "main" and hand ~= "off") then return end
    ObserveTime(self, at)
    local source = Source(self, at)
    if not source then return end
    local frame = Frame(self, source, key)
    if frame then
        Reservation(self, source, frame, { kind = "swing", hand = hand })
    end
end

function Inference:Cast(info)
    if not Enabled(self) then return end
    local cast = Fields(info, CAST_FIELDS)
    if not cast or not cast.at or not cast.spell then BlockAll(self) return end
    ObserveTime(self, cast.at)
    if cast.spell ~= STORMSTRIKE and not cast.conflict then return end
    local source = Source(self, cast.at)
    if not source then return end
    if cast.conflict or cast.uncertain or not cast.key then
        Block(self, source)
        return
    end
    local frame = Frame(self, source, cast.key)
    if frame then
        Reservation(self, source, frame, { kind = "cast", guid = cast.guid })
    end
end

local function LinkWeaponCooldown(self, signal, key)
    if signal.blocked or signal.closed or signal.totem
        or signal.swingSource or signal.extraSource then return end
    local swingSource, extraSource
    for _, source in ipairs(self.sources) do
        if math.abs(source.at - signal.at) <= WEAPON_SIGNAL_WINDOW then
            if source.blocked or source.totem or source.extraSource
                or (source ~= signal and source.weapon) then return end
            if #source.frames > 0 then
                if not source.sealed or #source.frames ~= 1 then return end
                local frame = source.frames[1]
                if frame.key ~= key then return end
                if not swingSource and frame.swingLines == 1 and #frame.reservations == 1
                    and frame.reservations[1].kind == "swing"
                    and (frame.directLines == 0 or frame.directLines == 2) then
                    swingSource = source
                elseif not extraSource and frame.swingLines == 0
                    and #frame.reservations == 0 and frame.directLines == 2 then
                    extraSource = source
                else
                    return
                end
            end
        end
    end
    if not swingSource then return end
    if swingSource.frames[1].directLines == 2 then
        if extraSource then return end
        extraSource = swingSource
    else
        if not extraSource or swingSource.at > signal.at or extraSource.at < signal.at
            or extraSource.at - swingSource.at > WEAPON_SIGNAL_WINDOW then return end
        -- Keep both original frames so receipts and confirmations retain
        -- their own timestamps.
        swingSource.extraSource, extraSource.swingSource = extraSource, swingSource
        swingSource.weapon = nil
    end

    extraSource.weapon = true
    Complete(self, extraSource)
end

function Inference:Signal(at, spell, cooldownTarget)
    if not Enabled(self) then return end
    at, spell = Number(at), Number(spell)
    if not at or (spell ~= WEAPON and spell ~= TOTEM) then return end
    ObserveTime(self, at)
    local source = Source(self, at)
    if not source then return end
    if spell == WEAPON then source.weapon = true else source.totem = true end
    Complete(self, source)
    local key = spell == WEAPON and Text(cooldownTarget)
    if key and not source.closed and not source.cooldownPending then
        source.cooldownPending = true
        local generation = self.generation
        self.config.after(WEAPON_SIGNAL_WINDOW + FRAME_WINDOW, function()
            if generation ~= self.generation or not source.alive or not Enabled(self) then return end
            LinkWeaponCooldown(self, source, key)
        end)
    end
end

function Inference:Line(at, key, origin, kind)
    if not Enabled(self) then return end
    at, key, origin, kind = Number(at), Text(key), Text(origin), Text(kind)
    if not at then return end
    local swing = kind == "swing" or kind == "swingMiss"
    local direct = kind == "spell" or kind == "spellMiss" or kind == "direct"
    if not swing and not direct then return end
    ObserveTime(self, at)
    local source = Source(self, at)
    if not source then return end
    if origin ~= "mine" then Block(self, source) return end
    local frame = Frame(self, source, key)
    if not frame then return end
    local field = swing and "swingLines" or "directLines"
    if frame[field] == MAX_LINES then Block(self, source) return end
    frame[field] = frame[field] + 1
    Complete(self, source)
end

local function OutcomeMetadata(metadata)
    local info = Fields(metadata, INFO_FIELDS)
    if not info or not info.at or info.at < 0 or not info.key then return end
    if info.receipt then
        info.receipt = Fields(info.receipt, RECEIPT_FIELDS)
        if not info.receipt then return end
    end
    if info.evidence then
        info.evidence = Fields(info.evidence, EVIDENCE_FIELDS)
        if not info.evidence then return end
    end
    return info
end

local function SpendReceipt(self, source, frame, receipt, result)
    if not receipt.at or not SameFrame(source.at, receipt.at)
        or receipt.uncertain or (receipt.who and receipt.who ~= "you")
        or receipt.key ~= frame.key
        or (receipt.sourceKey and receipt.sourceKey ~= frame.key) then
        Block(self, source)
        return
    end
    local found
    for _, reservation in ipairs(frame.reservations) do
        local matches = receipt.kind == reservation.kind
        if receipt.kind == "swing" then
            matches = matches and receipt.hand == reservation.hand
                and result.melee == true
        elseif receipt.kind == "cast" then
            matches = matches and receipt.spell == STORMSTRIKE
                and result.spell == STORMSTRIKE
                and (not receipt.ordinal or receipt.ordinal == 1)
        else matches = false end
        if matches and not reservation.used then
            if found then Block(self, source) return end
            found = reservation
        end
    end
    if not found then Block(self, source) return end
    found.used = true
    local field = receipt.kind == "swing" and "swingUsed" or "directUsed"
    frame[field] = frame[field] + 1
end

local function ExtraEvidence(frame, info)
    local evidence = info.evidence
    if not evidence or info.confirmed ~= true or info.restrict ~= "direct"
        or evidence.source ~= "mine" or evidence.ambiguous
        or (evidence.kind ~= "spell" and evidence.kind ~= "spellMiss"
            and evidence.kind ~= "direct")
        or (evidence.targetContext and evidence.targetContext ~= frame.key) then
        return false
    end
    if evidence.shared then
        local capacity = evidence.capacity
        if not capacity or capacity < 1 or capacity > MAX_LINES
            or capacity % 1 ~= 0 then return false end
        if frame.sharedCapacity and frame.sharedCapacity ~= capacity then
            return false
        end
        frame.sharedCapacity = capacity
        frame.sharedUsed = frame.sharedUsed + 1
    end
    return true
end

local function AccountedWeaponExtras(source, frame, info, record, result)
    local swing = frame.reservations[1]
    -- An unrelated later report cannot consume already matched direct lines.
    -- Complete still requires the native swing's own matching receipt.
    return source.sealed and source.weapon and not source.totem
        and #source.frames == 1 and #frame.reservations == 1
        and swing.kind == "swing"
        and frame.extras == 2 and frame.directUsed == 2 and frame.directLines == 2
        and info.at > source.at + FRAME_WINDOW and info.confirmed == false
        and record.event == "damage" and record.school == 1
        and result.who == "unknown" and not result.ambiguous
end

local function BlockUnlinked(self, info, publicRecord, result)
    if publicRecord.school ~= 1 and publicRecord.event ~= "miss" then return end
    for _, source in ipairs(self.sources) do
        local age = info.at - source.at
        if age >= -FRAME_WINDOW and age <= SOURCE_WINDOW then
            for _, frame in ipairs(source.frames) do
                if frame.key == info.key then
                    if not AccountedWeaponExtras(source, frame, info, publicRecord, result) then
                        Block(self, source)
                    end
                    break
                end
            end
        end
    end
end

function Inference:Out(record, metadata)
    if not Enabled(self) then self.config.emit(record) return end
    local publicRecord = Fields(record, RECORD_FIELDS)
    if not publicRecord then BlockAll(self) self.config.emit(record) return end
    if publicRecord.event ~= "damage" and publicRecord.event ~= "miss" then
        self.config.emit(record)
        return
    end
    local result = Fields(rawget(record, "result"), RESULT_FIELDS)
    local info = OutcomeMetadata(metadata)
    if not result or not info then BlockAll(self) self.config.emit(record) return end
    ObserveTime(self, info.at)
    local receipt, evidence = info.receipt, info.evidence
    local sourceAt = receipt and receipt.at or (evidence and evidence.at)
    if not sourceAt then
        BlockUnlinked(self, info, publicRecord, result)
        self.config.emit(record)
        return
    end
    local source = Source(self, sourceAt)
    if not source then self.config.emit(record) return end
    local frame = Frame(self, source, info.key)
    if not frame or source.closed or source.blocked then
        self.config.emit(record)
        return
    end
    frame.outcomes = frame.outcomes + 1
    if frame.outcomes > MAX_OUTCOMES or result.who ~= "you"
        or publicRecord.pet or result.ambiguous or result.tick
        or (publicRecord.school ~= 1 and not (publicRecord.event == "miss"
            and publicRecord.school == nil))
        or (evidence and (evidence.ambiguous or evidence.source ~= "mine"
            or not evidence.at or not SameFrame(sourceAt, evidence.at)
            or (evidence.targetContext and evidence.targetContext ~= frame.key))) then
        Block(self, source)
        self.config.emit(record)
        return
    end
    if receipt then
        SpendReceipt(self, source, frame, receipt, result)
        self.config.emit(record)
        Complete(self, source)
        return
    end
    -- Explicit orphan melee extras stay on the existing melee presentation.
    if result.spell or result.procSpell or result.melee
        or not ExtraEvidence(frame, info) then
        Block(self, source)
        self.config.emit(record)
        return
    end
    if self.pendingCount == MAX_PENDING then
        BlockAll(self)
        self.config.emit(record)
        return
    end
    frame.extras, frame.directUsed = frame.extras + 1, frame.directUsed + 1
    frame.pending[#frame.pending + 1] = {
        record = record, damage = publicRecord.event == "damage",
    }
    self.pendingCount = self.pendingCount + 1
    Complete(self, source)
end

function Inference:Rekey(old, new)
    old, new = Text(old), Text(new)
    if not old or not new or old == new then return end
    for _, source in ipairs(self.sources) do
        local previous, replacement
        for _, frame in ipairs(source.frames) do
            if frame.key == old then previous = frame end
            if frame.key == new then replacement = frame end
        end
        if previous and replacement then
            -- Existing competition cannot become clean through alias merging.
            Block(self, source)
            for index, frame in ipairs(source.frames) do
                if frame == previous then table.remove(source.frames, index) break end
            end
        elseif previous then previous.key = new end
    end
end

return Inference
