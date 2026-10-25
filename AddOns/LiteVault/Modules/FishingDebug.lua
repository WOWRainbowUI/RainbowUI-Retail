local addonName, lv = ...

-- Temporary, runtime-only fishing research tool. It never casts, interacts,
-- loots, targets, changes settings, or writes to SavedVariables.
local MAX_ENTRIES = 8000
local MAX_ARGUMENTS = 12
local MAX_TEXT_LENGTH = 180
local RECORDING_TIMEOUT_SECONDS = 15 * 60
local SAMPLE_INTERVAL_SECONDS = 0.10
local MARK_CONTEXT_MS = 1500
local BOBBER_ACQUISITION_SECONDS = 3
local BOBBER_POST_CAST_GRACE_SECONDS = 1
local TOOLTIP_LINE_LIMIT = 6

local frame = CreateFrame("Frame")
local recording = false
local hasRecording = false
local startedAt = 0
local nextSequence = 0
local droppedEntries = 0
local entries = {}
local entryHead = 1
local markers = {}
local castID = 0
local activeCastID = nil
local contextCastID = nil
local sessionID = "-"
local activePlayerChannel = false
local sampleElapsed = 0
local lastSample = nil
local timeoutTimer = nil
local reportFrame = nil
local soundHooksInstalled = false
local soundHookStatus = {}
local currentBobberGUID = nil
local currentBobberCastID = nil
local currentBobberAcquiredAt = nil
local bobberAcquisitionEndsAt = nil
local bobberPostCastEndsAt = nil
local lastBobberProbeFingerprint = nil
local lastBobberTooltipFingerprint = nil
local lastBobberTooltipDataInstanceID = nil
local lastBobberCursorFingerprint = nil
local bobberAPICallStatus = {}

lv._FishingDebugModuleLoadCount = (lv._FishingDebugModuleLoadCount or 0) + 1
local moduleLoadID = lv._FishingDebugModuleLoadCount

BINDING_HEADER_LITEVAULT = "LiteVault"
BINDING_NAME_LITEVAULT_FISH_DEBUG_MARK = "Fishing diagnostic: mark observed splash"

local observedEvents = {
    UNIT_SPELLCAST_CHANNEL_START = true,
    UNIT_SPELLCAST_CHANNEL_UPDATE = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_CHANNEL_INTERRUPTED = true,
    PLAYER_SOFT_INTERACT_CHANGED = true,
    UPDATE_MOUSEOVER_UNIT = true,
    LOOT_READY = true,
    LOOT_OPENED = true,
    LOOT_CLOSED = true,
    LOOT_SLOT_CLEARED = true,
    LOOT_SLOT_CHANGED = true,
}

local excludedTraceEvents = {
    SPELL_DATA_LOAD_RESULT = true,
    QUEST_DATA_LOAD_RESULT = true,
    CRITERIA_UPDATE = true,
}

local soundHookOrder = {
    "PlaySound",
    "PlaySoundFile",
    "C_Sound.PlaySound",
    "C_Sound.PlaySoundFile",
}

local bobberProbeOrder = {
    { "IsWorldLootObjectByGUID", "C_WorldLootObject", "IsWorldLootObjectByGUID" },
    { "GetWorldLootObjectInfoByGUID", "C_WorldLootObject", "GetWorldLootObjectInfoByGUID" },
    { "IsWorldLootObject", "C_WorldLootObject", "IsWorldLootObject" },
    { "GetWorldLootObjectInfo", "C_WorldLootObject", "GetWorldLootObjectInfo" },
    { "TooltipWorldLootObject", "C_TooltipInfo", "GetWorldLootObject" },
    { "TooltipWorldCursor", "C_TooltipInfo", "GetWorldCursor" },
}

local cursorProbeEvents = {
    WORLD_CURSOR_TOOLTIP_UPDATE = true,
    UPDATE_MOUSEOVER_UNIT = true,
    CURSOR_CHANGED = true,
}

local function Emit(message)
    local text = "|cffd4af37LiteVault Fishing Debug:|r " .. message
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    else
        print(text)
    end
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

local function SafeValue(value)
    if IsSecret(value) then return "<secret>" end
    if value == nil then return "nil" end
    local valueType = type(value)
    if valueType == "table" then return "<table>" end
    if valueType == "function" then return "<function>" end
    if valueType == "userdata" then return "<userdata>" end
    if valueType == "thread" then return "<thread>" end
    if valueType ~= "string" and valueType ~= "number" and valueType ~= "boolean" then
        return "<unreadable>"
    end
    local text = tostring(value):gsub("[\r\n\t]", " ")
    text = text:gsub("[%z\1-\8\11\12\14-\31\127]", function(character)
        return string.format("\\x%02X", string.byte(character))
    end)
    -- Prevent event payloads containing WoW markup from affecting the
    -- copyable plain-text report while retaining every literal pipe.
    text = text:gsub("|", "\\x7C")
    if #text > MAX_TEXT_LENGTH then text = text:sub(1, MAX_TEXT_LENGTH) .. "...<truncated>" end
    return text
end

local function Now()
    local value = GetTimePreciseSec and GetTimePreciseSec() or GetTime()
    if IsSecret(value) or type(value) ~= "number" then return 0 end
    return value
end

local function RelativeMS()
    return math.max(0, math.floor(((Now() - startedAt) * 1000) + 0.5))
end

local function Append(kind, text, explicitMS)
    if not recording then return nil end
    nextSequence = nextSequence + 1
    local ms = explicitMS or RelativeMS()
    local cast = contextCastID and (" cast=" .. contextCastID) or " cast=-"
    local line = string.format("%09d  +%08dms  %-12s session=%s%s  %s", nextSequence, ms, kind, sessionID, cast, text)
    local entry = { sequence = nextSequence, ms = ms, kind = kind, line = line }
    if #entries < MAX_ENTRIES then
        entries[#entries + 1] = entry
    else
        entries[entryHead] = entry
        entryHead = (entryHead % MAX_ENTRIES) + 1
        droppedEntries = droppedEntries + 1
    end
    return entry
end

local function EntryAt(chronologicalIndex)
    if #entries < MAX_ENTRIES then return entries[chronologicalIndex] end
    local physicalIndex = ((entryHead + chronologicalIndex - 2) % MAX_ENTRIES) + 1
    return entries[physicalIndex]
end

local function SafeArguments(...)
    local count = select("#", ...)
    local limit = math.min(count, MAX_ARGUMENTS)
    local parts = {}
    for index = 1, limit do
        parts[#parts + 1] = "arg" .. index .. "=" .. SafeValue(select(index, ...))
    end
    if count > limit then parts[#parts + 1] = "... " .. (count - limit) .. " more argument(s)" end
    return table.concat(parts, " ")
end

local function RecordSoundCall(apiName, ...)
    if not recording then return end
    local arguments = SafeArguments(...)
    Append("SOUND_CALL", "api=" .. apiName .. (#arguments > 0 and (" " .. arguments) or ""))
end

local function TryInstallSoundHook(apiName, owner, methodName)
    local target
    if owner then
        target = owner[methodName]
    else
        target = _G[methodName]
    end
    if type(target) ~= "function" then
        soundHookStatus[apiName] = "unavailable"
        return
    end
    if type(hooksecurefunc) ~= "function" then
        soundHookStatus[apiName] = "hooksecurefunc-unavailable"
        return
    end

    local callback = function(...) RecordSoundCall(apiName, ...) end
    local succeeded
    if owner then
        succeeded = pcall(hooksecurefunc, owner, methodName, callback)
    else
        succeeded = pcall(hooksecurefunc, methodName, callback)
    end
    soundHookStatus[apiName] = succeeded and "hooked" or "hook-failed"
end

local function InstallSoundHooks()
    if soundHooksInstalled then return end
    soundHooksInstalled = true

    TryInstallSoundHook("PlaySound", nil, "PlaySound")
    TryInstallSoundHook("PlaySoundFile", nil, "PlaySoundFile")
    local soundNamespace = type(C_Sound) == "table" and C_Sound or nil
    if soundNamespace then
        TryInstallSoundHook("C_Sound.PlaySound", soundNamespace, "PlaySound")
        TryInstallSoundHook("C_Sound.PlaySoundFile", soundNamespace, "PlaySoundFile")
    else
        soundHookStatus["C_Sound.PlaySound"] = "unavailable"
        soundHookStatus["C_Sound.PlaySoundFile"] = "unavailable"
    end
end

local function DescribeSoundHooks()
    local parts = {}
    for _, apiName in ipairs(soundHookOrder) do
        parts[#parts + 1] = apiName .. "=" .. (soundHookStatus[apiName] or "not-attempted")
    end
    return table.concat(parts, "; ")
end

local function GetNamespaceFunction(namespaceName, methodName)
    local namespace = _G[namespaceName]
    if type(namespace) ~= "table" then return nil end
    local succeeded, value = pcall(function() return namespace[methodName] end)
    if not succeeded or type(value) ~= "function" then return nil end
    return value
end

local function DescribeBobberProbes()
    local parts = {}
    for _, definition in ipairs(bobberProbeOrder) do
        local label, namespaceName, methodName = definition[1], definition[2], definition[3]
        local availability = GetNamespaceFunction(namespaceName, methodName) and "available" or "unavailable"
        local lastCall = bobberAPICallStatus[label]
        if lastCall then availability = availability .. ":last=" .. lastCall end
        parts[#parts + 1] = label .. "=" .. availability
    end
    return table.concat(parts, "; ")
end

local function CallBobberAPI(label, namespaceName, methodName, ...)
    local api = GetNamespaceFunction(namespaceName, methodName)
    if not api then
        bobberAPICallStatus[label] = "unavailable"
        return "unavailable", nil
    end
    local succeeded, value = pcall(api, ...)
    if not succeeded then
        bobberAPICallStatus[label] = "error"
        return "error", nil
    end
    bobberAPICallStatus[label] = "ok"
    return "ok", value
end

local function SafeTableField(value, key)
    if IsSecret(value) or type(value) ~= "table" then return nil, false end
    local succeeded, field = pcall(function() return value[key] end)
    if not succeeded or IsSecret(field) then return nil, false end
    return field, true
end

local function SummarizeWorldLootInfo(status, info)
    if status ~= "ok" then return status end
    if info == nil then return "nil" end
    if IsSecret(info) then return "<secret>" end
    if type(info) ~= "table" then return "unexpected=" .. SafeValue(info) end
    local inventoryType = SafeTableField(info, "inventoryType")
    local atMaxQuality = SafeTableField(info, "atMaxQuality")
    local isUpgrade = SafeTableField(info, "isUpgrade")
    return "present=true inventoryType=" .. SafeValue(inventoryType)
        .. " atMaxQuality=" .. SafeValue(atMaxQuality)
        .. " isUpgrade=" .. SafeValue(isUpgrade)
end

local function SummarizeBooleanProbe(status, value)
    if status ~= "ok" then return status end
    return SafeValue(value)
end

local function BuildTooltipSummary(data)
    if data == nil then return "present=false", nil end
    if IsSecret(data) then return "present=<secret>", nil end
    if type(data) ~= "table" then return "present=unexpected value=" .. SafeValue(data), nil end

    local tooltipType = SafeTableField(data, "type")
    local tooltipID = SafeTableField(data, "id")
    local dataInstanceID = SafeTableField(data, "dataInstanceID")
    local guid = SafeTableField(data, "guid")
    local hasDynamicData = SafeTableField(data, "hasDynamicData")
    local lines = SafeTableField(data, "lines")
    local lineCount = type(lines) == "table" and #lines or 0
    local texts = {}
    if type(lines) == "table" then
        for index = 1, math.min(lineCount, TOOLTIP_LINE_LIMIT) do
            local line = lines[index]
            if type(line) == "table" and not IsSecret(line) then
                local leftText = SafeTableField(line, "leftText")
                local rightText = SafeTableField(line, "rightText")
                if leftText ~= nil or rightText ~= nil then
                    texts[#texts + 1] = SafeValue(leftText) .. " / " .. SafeValue(rightText)
                end
            end
        end
    end
    local summary = "present=true type=" .. SafeValue(tooltipType)
        .. " id=" .. SafeValue(tooltipID)
        .. " dataInstanceID=" .. SafeValue(dataInstanceID)
        .. " guid=" .. SafeValue(guid)
        .. " hasDynamicData=" .. SafeValue(hasDynamicData)
        .. " lineCount=" .. SafeValue(lineCount)
    if #texts > 0 then summary = summary .. " text=[" .. table.concat(texts, " | ") .. "]" end
    return summary, dataInstanceID
end

local function SummarizeTooltipResult(status, data)
    if status ~= "ok" then return status, nil end
    local succeeded, summary, dataInstanceID = pcall(BuildTooltipSummary, data)
    if not succeeded then return "unreadable", nil end
    return summary, dataInstanceID
end

local function ResetBobberBinding()
    currentBobberGUID = nil
    currentBobberCastID = nil
    currentBobberAcquiredAt = nil
    bobberAcquisitionEndsAt = nil
    bobberPostCastEndsAt = nil
    lastBobberProbeFingerprint = nil
    lastBobberTooltipFingerprint = nil
    lastBobberTooltipDataInstanceID = nil
    lastBobberCursorFingerprint = nil
end

local function ClearBobber(reason)
    if currentBobberGUID then
        Append("BOBBER_CLEAR", "guid=" .. SafeValue(currentBobberGUID) .. " reason=" .. SafeValue(reason))
    end
    ResetBobberBinding()
end

local function ProbeBobberState(force)
    if not recording or not currentBobberGUID then return end
    local guidWorldStatus, guidWorldValue = CallBobberAPI(
        "IsWorldLootObjectByGUID", "C_WorldLootObject", "IsWorldLootObjectByGUID", currentBobberGUID)
    local guidInfoStatus, guidInfo = CallBobberAPI(
        "GetWorldLootObjectInfoByGUID", "C_WorldLootObject", "GetWorldLootObjectInfoByGUID", currentBobberGUID)
    local softWorldStatus, softWorldValue = CallBobberAPI(
        "IsWorldLootObject", "C_WorldLootObject", "IsWorldLootObject", "softinteract")
    local softInfoStatus, softInfo = CallBobberAPI(
        "GetWorldLootObjectInfo", "C_WorldLootObject", "GetWorldLootObjectInfo", "softinteract")
    local fingerprint = "guid=" .. SafeValue(currentBobberGUID)
        .. " guidWorldLoot=" .. SummarizeBooleanProbe(guidWorldStatus, guidWorldValue)
        .. " guidInfo={" .. SummarizeWorldLootInfo(guidInfoStatus, guidInfo) .. "}"
        .. " softWorldLoot=" .. SummarizeBooleanProbe(softWorldStatus, softWorldValue)
        .. " softInfo={" .. SummarizeWorldLootInfo(softInfoStatus, softInfo) .. "}"
    if force or fingerprint ~= lastBobberProbeFingerprint then
        Append("BOBBER_STATE", fingerprint)
        lastBobberProbeFingerprint = fingerprint
    end
end

local function ProbeBobberTooltip(force)
    if not recording or not currentBobberGUID then return end
    local status, data = CallBobberAPI(
        "TooltipWorldLootObject", "C_TooltipInfo", "GetWorldLootObject", "softinteract")
    local summary, dataInstanceID = SummarizeTooltipResult(status, data)
    if dataInstanceID ~= nil then lastBobberTooltipDataInstanceID = dataInstanceID end
    local fingerprint = "guid=" .. SafeValue(currentBobberGUID) .. " tooltip{" .. summary .. "}"
    if force or fingerprint ~= lastBobberTooltipFingerprint then
        Append("BOBBER_TOOLTIP", fingerprint)
        lastBobberTooltipFingerprint = fingerprint
    end
end

local function ProbeBobber(force)
    ProbeBobberState(force)
    ProbeBobberTooltip(force)
end

local function ProbeBobberCursor()
    if not recording or not activePlayerChannel or not currentBobberGUID then return end
    local status, data = CallBobberAPI("TooltipWorldCursor", "C_TooltipInfo", "GetWorldCursor")
    if status ~= "ok" or type(data) ~= "table" or IsSecret(data) then return end
    local guid = SafeTableField(data, "guid")
    if guid ~= currentBobberGUID then return end
    local summary = SummarizeTooltipResult(status, data)
    local fingerprint = "guid=" .. SafeValue(currentBobberGUID) .. " cursor{" .. summary .. "}"
    if fingerprint ~= lastBobberCursorFingerprint then
        Append("BOBBER_CURSOR", fingerprint)
        lastBobberCursorFingerprint = fingerprint
    end
end

local function UpdateBobberProbe()
    if not recording or not currentBobberGUID then return end
    if activePlayerChannel then
        ProbeBobber(false)
        return
    end
    if bobberPostCastEndsAt and Now() < bobberPostCastEndsAt then
        ProbeBobber(false)
    else
        ClearBobber("post-cast-timeout")
    end
end

local function FindGameObjectGUID(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if not IsSecret(value) and type(value) == "string" and value:find("GameObject-", 1, true) == 1 then
            return value
        end
    end
    return nil
end

local function BindBobberFromSoftInteract(...)
    if not recording or not activePlayerChannel or currentBobberGUID then return end
    if not bobberAcquisitionEndsAt or Now() > bobberAcquisitionEndsAt then
        bobberAcquisitionEndsAt = nil
        return
    end
    local guid = FindGameObjectGUID(...)
    if not guid then return end
    currentBobberGUID = guid
    currentBobberCastID = activeCastID
    currentBobberAcquiredAt = Now()
    bobberAcquisitionEndsAt = nil
    local entryID = guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)-")
    Append("BOBBER_BIND", "guid=" .. SafeValue(guid) .. " entryID=" .. SafeValue(entryID)
        .. " source=PLAYER_SOFT_INTERACT_CHANGED")
    ProbeBobber(true)
end

local function HandleWorldLootObjectInfoUpdated(guid)
    if not activePlayerChannel and not currentBobberGUID then return end
    local matchesBobber = currentBobberGUID ~= nil and not IsSecret(guid) and guid == currentBobberGUID
    Append("BOBBER_EVENT", "event=WORLD_LOOT_OBJECT_INFO_UPDATED guid=" .. SafeValue(guid)
        .. " matchesBobber=" .. tostring(matchesBobber))
    if matchesBobber then ProbeBobber(false) end
end

local function HandleTooltipDataUpdate(dataInstanceID)
    if not currentBobberGUID or lastBobberTooltipDataInstanceID == nil
        or IsSecret(dataInstanceID) or dataInstanceID ~= lastBobberTooltipDataInstanceID then
        return
    end
    Append("BOBBER_EVENT", "event=TOOLTIP_DATA_UPDATE dataInstanceID=" .. SafeValue(dataInstanceID)
        .. " matchesBobberTooltip=true")
    ProbeBobberTooltip(false)
end

local function RegisterBobberEvents()
    if type(frame.RegisterEvent) ~= "function" then return end
    pcall(frame.RegisterEvent, frame, "WORLD_LOOT_OBJECT_INFO_UPDATED")
    pcall(frame.RegisterEvent, frame, "TOOLTIP_DATA_UPDATE")
end

local function ReadUnitState(unit)
    local exists = UnitExists and UnitExists(unit)
    if IsSecret(exists) then return "exists=<secret> guid=<unreadable> name=<unreadable>" end
    if not exists then return "exists=false guid=nil name=nil" end
    local guid = UnitGUID and UnitGUID(unit)
    local name = UnitName and UnitName(unit)
    return "exists=true guid=" .. SafeValue(guid) .. " name=" .. SafeValue(name)
end

local function ReadChannelState()
    if not UnitChannelInfo then return "available=false" end
    local name, text, textureID, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellID,
        isEmpowered, numEmpowerStages, empowerStartTime = UnitChannelInfo("player")
    return table.concat({
        "name=" .. SafeValue(name),
        "text=" .. SafeValue(text),
        "texture=" .. SafeValue(textureID),
        "startMS=" .. SafeValue(startTimeMS),
        "endMS=" .. SafeValue(endTimeMS),
        "tradeSkill=" .. SafeValue(isTradeSkill),
        "notInterruptible=" .. SafeValue(notInterruptible),
        "spellID=" .. SafeValue(spellID),
        "empowered=" .. SafeValue(isEmpowered),
        "stages=" .. SafeValue(numEmpowerStages),
        "empowerStartMS=" .. SafeValue(empowerStartTime),
    }, " ")
end

local function ReadSample()
    return "channel{" .. ReadChannelState() .. "} softinteract{" .. ReadUnitState("softinteract")
        .. "} mouseover{" .. ReadUnitState("mouseover") .. "}"
end

local function Sample(force)
    if not recording or not activePlayerChannel then return end
    local state = ReadSample()
    if force or state ~= lastSample then
        Append("STATE_CHANGE", state)
        lastSample = state
    end
end

local function CancelTimeout()
    if timeoutTimer then timeoutTimer:Cancel(); timeoutTimer = nil end
end

local function Stop(reason)
    if not recording then Emit("No recording is active."); return end
    ClearBobber("recording-stopped")
    Append("SESSION", "recording stopped reason=" .. SafeValue(reason))
    recording = false
    frame:UnregisterAllEvents()
    frame:SetScript("OnUpdate", nil)
    CancelTimeout()
    activePlayerChannel = false
    activeCastID = nil
    contextCastID = nil
    lastSample = nil
    Emit(string.format("Stopped. %d entries retained, %d dropped. Use /lvfishdebug show.", #entries, droppedEntries))
end

local function Start()
    if recording then Stop("restarted") end
    InstallSoundHooks()
    ResetBobberBinding()
    bobberAPICallStatus = {}
    entries = {}
    entryHead = 1
    markers = {}
    droppedEntries = 0
    nextSequence = 0
    castID = 0
    activeCastID = nil
    contextCastID = nil
    sessionID = "-"
    activePlayerChannel = false
    lastSample = nil
    sampleElapsed = 0
    startedAt = Now()
    sessionID = date("%Y%m%d-%H%M%S")
    recording = true
    hasRecording = true
    frame:RegisterAllEvents()
    RegisterBobberEvents()
    frame:SetScript("OnUpdate", function(_, elapsed)
        if IsSecret(elapsed) or type(elapsed) ~= "number" then return end
        sampleElapsed = sampleElapsed + elapsed
        if sampleElapsed >= SAMPLE_INTERVAL_SECONDS then
            sampleElapsed = sampleElapsed % SAMPLE_INTERVAL_SECONDS
            Sample(false)
            UpdateBobberProbe()
        end
    end)
    local version, build, buildDate, interfaceVersion = GetBuildInfo()
    Append("SESSION", "started local=" .. date("%Y-%m-%d %H:%M:%S %z")
        .. " client=" .. SafeValue(version) .. " build=" .. SafeValue(build)
        .. " buildDate=" .. SafeValue(buildDate) .. " interface=" .. SafeValue(interfaceVersion)
        .. " locale=" .. SafeValue(GetLocale and GetLocale())
        .. " maxEntries=" .. MAX_ENTRIES .. " timeoutSec=" .. RECORDING_TIMEOUT_SECONDS)
    Append("SESSION", "manual markers are player observations; event proximity is correlation only, not proof of a bite")
    timeoutTimer = C_Timer.NewTimer(RECORDING_TIMEOUT_SECONDS, function() Stop("automatic timeout") end)
    Emit("Fresh recording started (15 minute limit). Cast normally; use /lvfishdebug mark or the optional keybinding when you see the splash.")
end

local function Mark()
    if not recording then Emit("Start a recording before adding a splash marker."); return end
    local entry = Append("PLAYER_MARK", "PLAYER-OBSERVED SPLASH (manual; not automatic detection)")
    markers[#markers + 1] = { sequence = entry.sequence, ms = entry.ms, castID = activeCastID }
    Emit("Manual splash observation marked at +" .. entry.ms .. "ms (cast " .. SafeValue(activeCastID) .. ").")
end

function LiteVaultFishingDebugMark()
    Mark()
end

local function BuildReport()
    if not hasRecording then
        return "No recording available. Run /lvfishdebug start.", "hasRecording=false"
    end
    local lines = {
        "LiteVault Fishing Diagnostic",
        "Purpose: compare readable client signals around player-observed splashes.",
        "IMPORTANT: PLAYER_MARK entries are manual observations. Nearby events are not proof of a bite.",
        string.format("Status: %s | retained=%d | dropped-oldest=%d | capacity=%d", recording and "RECORDING" or "STOPPED", #entries, droppedEntries, MAX_ENTRIES),
        "Kinds: OBSERVED=selected relevant event; TRACE=unrelated all-event trace; STATE_CHANGE=10 Hz changed-state sample; SOUND_CALL=Lua-visible sound API invocation; SOUND_EVENT=Lua-visible sound event.",
        "Bobber kinds: BOBBER_BIND=current-cast GameObject association; BOBBER_CLEAR=binding lifecycle; BOBBER_STATE=change-only WorldLootObject snapshot; BOBBER_EVENT=event correlation; BOBBER_TOOLTIP=change-only softinteract tooltip; BOBBER_CURSOR=change-only matching world-cursor tooltip.",
        "Sound hooks: " .. DescribeSoundHooks(),
        "Bobber probes: " .. DescribeBobberProbes(),
        "",
        "=== CHRONOLOGICAL EVIDENCE ===",
    }
    if #entries == 0 then
        lines[#lines + 1] = "<recording exists but no entries are retained>"
    else
        for index = 1, #entries do lines[#lines + 1] = EntryAt(index).line end
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "=== MANUAL MARK CONTEXT (duplicates from chronology for inspection) ==="
    if #markers == 0 then lines[#lines + 1] = "No manual splash markers were recorded." end
    for markerIndex, marker in ipairs(markers) do
        lines[#lines + 1] = string.format("--- marker %d sequence=%d +%dms cast=%s window=+/-%.1fs ---",
            markerIndex, marker.sequence, marker.ms, SafeValue(marker.castID), MARK_CONTEXT_MS / 1000)
        local found = false
        for index = 1, #entries do
            local entry = EntryAt(index)
            if math.abs(entry.ms - marker.ms) <= MARK_CONTEXT_MS then
                lines[#lines + 1] = entry.line
                found = true
            end
        end
        if not found then lines[#lines + 1] = "<context no longer retained in bounded buffer>" end
    end
    return table.concat(lines, "\n"), "recording available"
end

local function DescribeEditText(edit)
    local value = edit:GetText()
    if IsSecret(value) then return "secret", nil end
    if value == nil then return "nil", nil end
    if type(value) ~= "string" then return "type:" .. type(value), nil end
    return "string:" .. #value, #value
end

local function EnsureReportFrame()
    if reportFrame then return reportFrame end
    local window = CreateFrame("Frame", "LiteVaultFishingDebugReport", UIParent, "BasicFrameTemplateWithInset")
    window:SetSize(900, 620)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetFrameLevel(100)
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window.TitleText:SetText("LiteVault Fishing Diagnostic - Ctrl+A, Ctrl+C to copy")

    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -34)
    scroll:SetPoint("BOTTOMRIGHT", -30, 12)
    scroll:SetFrameLevel(window:GetFrameLevel() + 2)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maximum = self:GetVerticalScrollRange()
        local step = 42
        self:SetVerticalScroll(math.max(0, math.min(maximum, current - (delta * step))))
    end)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:ClearAllPoints()
    edit:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    local fontPath, fontSize, fontFlags = ChatFontNormal:GetFont()
    edit:SetFont(fontPath or "Fonts\\FRIZQT__.TTF", fontSize or 14, fontFlags or "")
    edit:SetTextColor(1, 1, 1, 1)
    edit:SetAlpha(1)
    edit:SetJustifyH("LEFT")
    edit:SetJustifyV("TOP")
    edit:SetTextInsets(6, 6, 6, 6)
    edit:SetWidth(840)
    edit:SetHeight(560)
    edit:SetFrameLevel(scroll:GetFrameLevel() + 1)
    window.initialMaxLetters = edit:GetMaxLetters()
    window.initialMaxBytes = edit:GetMaxBytes()
    edit:SetMaxLetters(0)
    edit:SetMaxBytes(0)
    edit:EnableMouse(true)
    edit:SetScript("OnEscapePressed", function() window:Hide() end)
    edit:SetScript("OnTextChanged", function(self)
        local _, currentFontSize = self:GetFont()
        local lineHeight = currentFontSize or 14
        local numLines = self:GetNumLines() or 1
        self:SetHeight(math.max(scroll:GetHeight(), (numLines * lineHeight) + 24))
        scroll:UpdateScrollChildRect()
    end)
    scroll:SetScrollChild(edit)
    window.scrollFrame = scroll
    window.editBox = edit
    reportFrame = window
    return window
end

local function DisplayReport(window, report)
    window.editBox:SetText(report)
    local immediateState, immediateLength = DescribeEditText(window.editBox)
    window.editBox:SetCursorPosition(0)
    window.editBox:HighlightText(0, 0)
    window.scrollFrame:SetVerticalScroll(0)
    window.editBox:SetFocus()
    local finalState, finalLength = DescribeEditText(window.editBox)
    Emit(string.format("report assigned=%d immediate=%s final=%s maxLetters=%s->%s maxBytes=%s->%s",
        #report, immediateState, finalState,
        SafeValue(window.initialMaxLetters), SafeValue(window.editBox:GetMaxLetters()),
        SafeValue(window.initialMaxBytes), SafeValue(window.editBox:GetMaxBytes())))
    C_Timer.After(0, function()
        if reportFrame == window then
            local nextFrameState = DescribeEditText(window.editBox)
            Emit(string.format("report nextFrame=%s expected=%d immediateBytes=%s finalBytes=%s",
                nextFrameState, #report, SafeValue(immediateLength), SafeValue(finalLength)))
        end
    end)
end

local function Show()
    local window = EnsureReportFrame()
    local report, reportReason = BuildReport()
    window:Show()
    DisplayReport(window, report)
    return reportReason
end

local function Clear()
    if recording then
        frame:UnregisterAllEvents()
        frame:SetScript("OnUpdate", nil)
        CancelTimeout()
    end
    recording = false
    hasRecording = false
    entries = {}
    entryHead = 1
    markers = {}
    droppedEntries = 0
    nextSequence = 0
    castID = 0
    activeCastID = nil
    contextCastID = nil
    activePlayerChannel = false
    lastSample = nil
    ResetBobberBinding()
    bobberAPICallStatus = {}
    if reportFrame then reportFrame:Hide() end
    Emit("Recording cleared.")
end

frame:SetScript("OnEvent", function(_, event, ...)
    if not recording or IsSecret(event) or type(event) ~= "string" then return end
    -- Chat payloads are unrelated to splash discovery and can contain private
    -- or very large text. Reject the entire CHAT_MSG_* family before touching
    -- arguments or buffer accounting (including CHAT_MSG_ADDON variants).
    if event:sub(1, 9) == "CHAT_MSG_" then return end
    if event == "WORLD_LOOT_OBJECT_INFO_UPDATED" then
        HandleWorldLootObjectInfoUpdated(select(1, ...))
        return
    elseif event == "TOOLTIP_DATA_UPDATE" then
        HandleTooltipDataUpdate(select(1, ...))
        return
    end
    local kind
    if event == "SOUNDKIT_FINISHED" then
        kind = "SOUND_EVENT"
    elseif observedEvents[event] then
        kind = "OBSERVED"
    else
        kind = "TRACE"
    end
    -- Known data-loading completion spam has no bearing on the splash timing
    -- investigation. Only generic TRACE events are excluded here so an event
    -- explicitly assigned another diagnostic category always remains visible.
    if kind == "TRACE" and excludedTraceEvents[event] then return end
    local arguments = SafeArguments(...)

    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit = select(1, ...)
        if not IsSecret(unit) and unit == "player" then
            ClearBobber("new-cast")
            castID = castID + 1
            activeCastID = castID
            contextCastID = castID
            activePlayerChannel = true
            bobberAcquisitionEndsAt = Now() + BOBBER_ACQUISITION_SECONDS
            bobberPostCastEndsAt = nil
            lastSample = nil
            Append("CAST_START", "player channel/cast began; fishing must be confirmed from recorded spell/channel data " .. arguments)
            Sample(true)
            return
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        local unit = select(1, ...)
        if not IsSecret(unit) and unit == "player" then
            Append("CAST_UPDATE", arguments)
            Sample(true)
            return
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_CHANNEL_INTERRUPTED" then
        local unit = select(1, ...)
        if not IsSecret(unit) and unit == "player" then
            Append("CAST_END", event .. " " .. arguments .. " post-channel trace continues while recording")
            activePlayerChannel = false
            activeCastID = nil
            bobberAcquisitionEndsAt = nil
            if currentBobberGUID then
                bobberPostCastEndsAt = Now() + BOBBER_POST_CAST_GRACE_SECONDS
            end
            lastSample = nil
            return
        end
    elseif event == "PLAYER_SOFT_INTERACT_CHANGED" then
        Append(kind, event .. (#arguments > 0 and (" " .. arguments) or ""))
        BindBobberFromSoftInteract(...)
        return
    end

    Append(kind, event .. (#arguments > 0 and (" " .. arguments) or ""))
    if cursorProbeEvents[event] then ProbeBobberCursor() end
end)

SLASH_LVFISHDEBUG1 = "/lvfishdebug"
SlashCmdList.LVFISHDEBUG = function(message)
    if IsSecret(message) or type(message) ~= "string" then return end
    local command = message:match("^%s*(%S*)")
    command = command and command:lower() or ""
    local detail = nil
    if command == "start" then Start()
    elseif command == "mark" then Mark()
    elseif command == "stop" then Stop("manual stop")
    elseif command == "show" then detail = " builder=" .. Show()
    elseif command == "clear" then Clear()
    else Emit("Commands: /lvfishdebug start | mark | stop | show | clear"); return end
    Emit(string.format("command=%s session=%s recording=%s available=%s entries=%d load=%d%s", command,
        SafeValue(sessionID), tostring(recording), tostring(hasRecording), #entries, moduleLoadID, detail or ""))
end

lv.FishingDebug = {
    IsRecording = function() return recording end,
    BuildReport = BuildReport,
    Mark = Mark,
    Show = Show,
}
