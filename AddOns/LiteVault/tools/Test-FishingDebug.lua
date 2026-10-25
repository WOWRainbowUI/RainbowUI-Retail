-- Minimal Lua 5.1 harness for the runtime-only fishing diagnostic.
local now = 100
local namedFrames = {}
local createdFrames = {}
local secureHooks = {}
local secureHookInstallCount = 0

local function NewObject(kind)
    local object = { kind = kind, shown = true, height = 560, width = 840, frameLevel = 1, alpha = 1,
        textColor = { 1, 1, 1, 1 }, maxLetters = 0, maxBytes = 32767 }
    function object:SetSize(width, height) self.width = width; self.height = height end
    function object:SetPoint() end
    function object:SetFrameStrata() end
    function object:SetFrameLevel(value) self.frameLevel = value end
    function object:GetFrameLevel() return self.frameLevel end
    function object:SetClampedToScreen() end
    function object:SetMovable() end
    function object:EnableMouse() end
    function object:RegisterForDrag() end
    function object:SetScript(name, callback) self.scripts = self.scripts or {}; self.scripts[name] = callback end
    function object:RegisterAllEvents() self.allEvents = true end
    function object:RegisterEvent(event) self.registeredEvents = self.registeredEvents or {}; self.registeredEvents[event] = true end
    function object:UnregisterAllEvents() self.allEvents = false end
    function object:StartMoving() end
    function object:StopMovingOrSizing() end
    function object:Show() self.shown = true end
    function object:Hide() self.shown = false end
    function object:SetMultiLine(value) self.multiline = value end
    function object:SetAutoFocus() end
    function object:SetFontObject() end
    function object:SetFont(path, size, flags) self.font = { path, size, flags } end
    function object:GetFont()
        local font = self.font or { "Fonts\\FRIZQT__.TTF", 14, "" }
        return font[1], font[2], font[3]
    end
    function object:SetTextColor(red, green, blue, alpha) self.textColor = { red, green, blue, alpha } end
    function object:GetTextColor() return unpack(self.textColor) end
    function object:SetAlpha(value) self.alpha = value end
    function object:GetAlpha() return self.alpha end
    function object:SetJustifyH(value) self.justifyH = value end
    function object:SetJustifyV(value) self.justifyV = value end
    function object:SetTextInsets() end
    function object:SetWidth(width) self.width = width end
    function object:GetWidth() return self.width end
    function object:SetHeight(height) self.height = height end
    function object:GetHeight() return self.height end
    function object:SetScrollChild(child) self.scrollChild = child end
    function object:EnableMouseWheel(value) self.mouseWheelEnabled = value end
    function object:ClearAllPoints() end
    function object:UpdateScrollChildRect() self.updatedScrollRect = true end
    function object:SetVerticalScroll(value) self.verticalScroll = value end
    function object:GetVerticalScroll() return self.verticalScroll or 0 end
    function object:GetVerticalScrollRange() return math.max(0, (self.scrollChild and self.scrollChild.height or 0) - self.height) end
    function object:SetText(value)
        self.text = self.maxBytes > 0 and #value > self.maxBytes and "" or value
        if self.scripts and self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
    end
    function object:GetText() return self.text end
    function object:GetNumLines()
        local _, count = (self.text or ""):gsub("\n", "\n")
        return count + 1
    end
    function object:SetCursorPosition(value) self.cursor = value end
    function object:HighlightText(first, last) self.highlight = { first, last } end
    function object:SetFocus() self.focused = true end
    function object:IsVisible() return self.shown end
    function object:EnableMouse() end
    function object:SetMaxLetters(value) self.maxLetters = value end
    function object:GetMaxLetters() return self.maxLetters end
    function object:SetMaxBytes(value) self.maxBytes = value end
    function object:GetMaxBytes() return self.maxBytes end
    function object:SetEnabled(value) self.enabled = value end
    object.TitleText = { SetText = function(self, value) self.text = value end }
    return object
end

function CreateFrame(kind, name)
    local object = NewObject(kind)
    createdFrames[#createdFrames + 1] = object
    if name then namedFrames[name] = object; _G[name] = object end
    return object
end

UIParent = NewObject("UIParent")
ChatFontNormal = NewObject("Font")
local chatMessages = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) chatMessages[#chatMessages + 1] = message end }
SlashCmdList = {}
C_Timer = {
    NewTimer = function(_, callback)
        return { Cancel = function() end, callback = callback }
    end,
    After = function(_, callback) callback() end,
}
function GetTimePreciseSec() now = now + 0.125; return now end
function GetTime() return GetTimePreciseSec() end
function GetBuildInfo() return "12.1.0", "65000", "Sep 12 2026", 120100 end
function GetLocale() return "enUS" end
function UnitExists() return false end
function UnitGUID() return nil end
function UnitName() return nil end
function UnitChannelInfo() return nil end
function issecretvalue() return false end
date = os.date

function PlaySound() end
function PlaySoundFile() end
C_Sound = { PlaySound = function() end }
local guidWorldLoot = false
local guidWorldLootInfo = nil
local softWorldLoot = false
local softWorldLootInfo = nil
local worldLootErrors = {}
local worldLootCalls = { guidWorld = 0, guidInfo = 0, softWorld = 0, softInfo = 0 }
C_WorldLootObject = {
    IsWorldLootObjectByGUID = function()
        worldLootCalls.guidWorld = worldLootCalls.guidWorld + 1
        if worldLootErrors.guidWorld then error("guid world failure") end
        return guidWorldLoot
    end,
    GetWorldLootObjectInfoByGUID = function()
        worldLootCalls.guidInfo = worldLootCalls.guidInfo + 1
        if worldLootErrors.guidInfo then error("guid info failure") end
        return guidWorldLootInfo
    end,
    IsWorldLootObject = function()
        worldLootCalls.softWorld = worldLootCalls.softWorld + 1
        if worldLootErrors.softWorld then error("soft world failure") end
        return softWorldLoot
    end,
    GetWorldLootObjectInfo = function()
        worldLootCalls.softInfo = worldLootCalls.softInfo + 1
        if worldLootErrors.softInfo then error("soft info failure") end
        return softWorldLootInfo
    end,
}
local bobberTooltipData = nil
local worldCursorData = nil
local tooltipErrors = {}
local tooltipCalls = { bobber = 0, cursor = 0 }
C_TooltipInfo = {
    GetWorldLootObject = function()
        tooltipCalls.bobber = tooltipCalls.bobber + 1
        if tooltipErrors.bobber then error("bobber tooltip failure") end
        return bobberTooltipData
    end,
    GetWorldCursor = function()
        tooltipCalls.cursor = tooltipCalls.cursor + 1
        if tooltipErrors.cursor then error("cursor tooltip failure") end
        return worldCursorData
    end,
}
function hooksecurefunc(target, methodOrCallback, callback)
    secureHookInstallCount = secureHookInstallCount + 1
    if type(target) == "string" then
        secureHooks[target] = methodOrCallback
    else
        secureHooks["C_Sound." .. methodOrCallback] = callback
    end
end

local lv = {}
assert(loadfile("Modules/FishingDebug.lua"))("LiteVault", lv)

local function CountPlain(text, needle)
    local count, position = 0, 1
    while true do
        local found = text:find(needle, position, true)
        if not found then return count end
        count = count + 1
        position = found + #needle
    end
end

-- The diagnostic is development tooling only: the release TOC must not load it
-- and no production keybinding (root Bindings.xml) may reference it.
local tocFile = assert(io.open("LiteVault.toc", "r"))
local tocText = tocFile:read("*a")
tocFile:close()
assert(not tocText:find("FishingDebug.lua", 1, true), "fishing diagnostic must not be loaded by the release TOC")
assert(io.open("Bindings.xml", "r") == nil, "production Bindings.xml must not reference the fishing diagnostic")
assert(type(LiteVaultFishingDebugMark) == "function", "development mark helper is not registered globally")

-- Verify the slash-command flow without invoking the binding action.
SlashCmdList.LVFISHDEBUG("show")
local window = assert(namedFrames.LiteVaultFishingDebugReport)
assert(window.editBox:GetText() == "No recording available. Run /lvfishdebug start.")

SlashCmdList.LVFISHDEBUG("start")
assert(secureHookInstallCount == 3, "available sound APIs were not hooked exactly once")
assert(type(secureHooks.PlaySound) == "function", "PlaySound hook was not installed")
assert(type(secureHooks.PlaySoundFile) == "function", "PlaySoundFile hook was not installed")
assert(type(secureHooks["C_Sound.PlaySound"]) == "function", "C_Sound.PlaySound hook was not installed")
assert(secureHooks["C_Sound.PlaySoundFile"] == nil, "missing C_Sound.PlaySoundFile was hooked")
SlashCmdList.LVFISHDEBUG("mark")
SlashCmdList.LVFISHDEBUG("stop")
SlashCmdList.LVFISHDEBUG("show")

local displayed = assert(window.editBox:GetText())
assert(displayed:find("started local=", 1, true), "missing session start/header")
assert(displayed:find("PLAYER_MARK", 1, true), "missing manual marker")
assert(displayed:find("recording stopped reason=manual stop", 1, true), "missing stop entry")
assert(window.editBox.multiline, "report edit box is not multiline")
assert(window.scrollFrame.scrollChild == window.editBox, "visible edit box is not the scroll child")
assert(window.scrollFrame.mouseWheelEnabled, "report scroll frame does not accept mouse-wheel input")
assert(window.editBox.height > 1, "report edit box has no visible height")
assert(window.shown and window.editBox.focused, "report is not shown/focused")
assert(window.editBox.highlight[1] == 0 and window.editBox.highlight[2] == 0, "selection state is unexpected")
assert(window.scrollFrame.verticalScroll == 0, "opening the report did not scroll to the top")
assert(window.editBox:GetMaxLetters() == 0, "report edit box has a letter limit")
assert(window.editBox:GetMaxBytes() == 0, "report edit box has a byte limit")
assert(not window.TitleText.text:find("page", 1, true), "viewer title still mentions pages")
local commandDiagnostics = table.concat(chatMessages, "\n")
assert(commandDiagnostics:find("command=start", 1, true), "start did not traverse registered slash handler")
assert(commandDiagnostics:find("command=mark", 1, true), "mark did not traverse registered slash handler")
assert(commandDiagnostics:find("command=stop", 1, true), "stop did not traverse registered slash handler")
assert(commandDiagnostics:find("command=show", 1, true), "show did not traverse registered slash handler")
assert(commandDiagnostics:find("builder=recording available", 1, true), "show selected the empty-state branch")

-- Verify the binding action independently from the slash-command flow.
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
LiteVaultFishingDebugMark()
SlashCmdList.LVFISHDEBUG("stop")
SlashCmdList.LVFISHDEBUG("show")
assert(window.editBox:GetText():find("PLAYER_MARK", 1, true), "binding action did not add a marker")

-- Excluded TRACE events must be rejected before payload serialization or
-- buffer accounting, while important TRACE, OBSERVED, and manual entries remain.
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
local eventFrame = createdFrames[1]
local originalTostring = tostring
local excludedArgumentFormatting = 0
tostring = function(value)
    if type(value) == "string" and value:find("EXCLUDED_", 1, true) == 1 then
        excludedArgumentFormatting = excludedArgumentFormatting + 1
    end
    return originalTostring(value)
end
eventFrame.scripts.OnEvent(eventFrame, "CHAT_MSG_CHANNEL", "TRADE_CHAT_PAYLOAD_MUST_NOT_APPEAR", "sender")
eventFrame.scripts.OnEvent(eventFrame, "CHAT_MSG_ADDON", "PREFIX", "ADDON_CHAT_PAYLOAD_MUST_NOT_APPEAR", "PARTY")
eventFrame.scripts.OnEvent(eventFrame, "SPELL_DATA_LOAD_RESULT", "EXCLUDED_ARGUMENT_SENTINEL")
eventFrame.scripts.OnEvent(eventFrame, "QUEST_DATA_LOAD_RESULT", "EXCLUDED_QUEST_DATA_SENTINEL")
eventFrame.scripts.OnEvent(eventFrame, "CRITERIA_UPDATE", "EXCLUDED_CRITERIA_SENTINEL")
tostring = originalTostring
eventFrame.scripts.OnEvent(eventFrame, "HARNESS_NON_CHAT_EVENT", "NON_CHAT_PAYLOAD_MUST_APPEAR")
eventFrame.scripts.OnEvent(eventFrame, "LOOT_READY", "OBSERVED_PAYLOAD_MUST_APPEAR")
SlashCmdList.LVFISHDEBUG("mark")
SlashCmdList.LVFISHDEBUG("stop")
SlashCmdList.LVFISHDEBUG("show")
local filteredReport = window.editBox:GetText()
assert(not filteredReport:find("TRADE_CHAT_PAYLOAD_MUST_NOT_APPEAR", 1, true), "channel chat payload was retained")
assert(not filteredReport:find("ADDON_CHAT_PAYLOAD_MUST_NOT_APPEAR", 1, true), "addon chat payload was retained")
assert(not filteredReport:find("EXCLUDED_ARGUMENT_SENTINEL", 1, true), "spell data load payload was retained")
assert(not filteredReport:find("EXCLUDED_QUEST_DATA_SENTINEL", 1, true), "quest data load payload was retained")
assert(not filteredReport:find("EXCLUDED_CRITERIA_SENTINEL", 1, true), "criteria update payload was retained")
assert(excludedArgumentFormatting == 0, "excluded event arguments were formatted")
assert(filteredReport:find("HARNESS_NON_CHAT_EVENT", 1, true), "non-chat event was not retained")
assert(filteredReport:find("OBSERVED_PAYLOAD_MUST_APPEAR", 1, true), "observed event was not retained")
assert(filteredReport:find("PLAYER_MARK", 1, true), "manual marker was not retained after chat filtering")
assert(filteredReport:find("retained=6", 1, true), "excluded events affected the retained entry count")
assert(filteredReport:find("dropped-oldest=0", 1, true), "excluded events affected the dropped-oldest count")

-- At exact capacity, excluded events must not cause replacement or overflow.
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
for index = 1, 7998 do
    eventFrame.scripts.OnEvent(eventFrame, "HARNESS_CAPACITY_EVENT", index)
end
local capacityBeforeExclusions = lv.FishingDebug.BuildReport()
assert(capacityBeforeExclusions:find("retained=8000", 1, true), "capacity fixture did not fill the retained buffer")
assert(capacityBeforeExclusions:find("dropped-oldest=0", 1, true), "capacity fixture overflowed too early")
eventFrame.scripts.OnEvent(eventFrame, "CHAT_MSG_SYSTEM", "EXCLUDED_CHAT_AT_CAPACITY")
eventFrame.scripts.OnEvent(eventFrame, "SPELL_DATA_LOAD_RESULT", "EXCLUDED_SPELL_LOAD_AT_CAPACITY")
eventFrame.scripts.OnEvent(eventFrame, "QUEST_DATA_LOAD_RESULT", "EXCLUDED_QUEST_DATA_AT_CAPACITY")
eventFrame.scripts.OnEvent(eventFrame, "CRITERIA_UPDATE", "EXCLUDED_CRITERIA_AT_CAPACITY")
local capacityAfterExclusions = lv.FishingDebug.BuildReport()
assert(capacityAfterExclusions:find("retained=8000", 1, true), "excluded event changed retained count at capacity")
assert(capacityAfterExclusions:find("dropped-oldest=0", 1, true), "excluded event increased dropped-oldest at capacity")
assert(not capacityAfterExclusions:find("EXCLUDED_CHAT_AT_CAPACITY", 1, true), "chat event was retained at capacity")
assert(not capacityAfterExclusions:find("EXCLUDED_SPELL_LOAD_AT_CAPACITY", 1, true), "spell data event was retained at capacity")
assert(not capacityAfterExclusions:find("EXCLUDED_QUEST_DATA_AT_CAPACITY", 1, true), "quest data event was retained at capacity")
assert(not capacityAfterExclusions:find("EXCLUDED_CRITERIA_AT_CAPACITY", 1, true), "criteria event was retained at capacity")

-- Secure sound-hook callbacks retain raw source-specific evidence only during
-- recording. Nil and table arguments use the existing compact serializer.
SlashCmdList.LVFISHDEBUG("clear")
secureHooks.PlaySound(12345, "Master", true, nil, { nested = "not dumped" })
assert(lv.FishingDebug.BuildReport() == "No recording available. Run /lvfishdebug start.", "sound callback created a recording while stopped")
SlashCmdList.LVFISHDEBUG("start")
assert(secureHookInstallCount == 3, "a repeated start installed duplicate sound hooks")
secureHooks.PlaySound(12345, "Master", true, nil, { nested = "not dumped" })
secureHooks.PlaySoundFile("Interface\\AddOns\\LiteVault\\sound.ogg", "SFX")
secureHooks["C_Sound.PlaySound"](67890, "Dialog", false)
eventFrame.scripts.OnEvent(eventFrame, "SOUNDKIT_FINISHED", 67890, true, "finished")
SlashCmdList.LVFISHDEBUG("mark")
SlashCmdList.LVFISHDEBUG("stop")
local soundReportBeforeStoppedCallback = lv.FishingDebug.BuildReport()
secureHooks.PlaySound(99999, "SHOULD_NOT_BE_RETAINED")
local soundReport = lv.FishingDebug.BuildReport()
assert(soundReport == soundReportBeforeStoppedCallback, "sound callback retained an entry after stop")
assert(soundReport:find("SOUND_CALL", 1, true), "sound call is missing from chronology")
assert(soundReport:find("api=PlaySound arg1=12345 arg2=Master arg3=true arg4=nil arg5=<table>", 1, true), "PlaySound arguments were not safely serialized")
assert(soundReport:find("api=PlaySoundFile arg1=Interface\\AddOns\\LiteVault\\sound.ogg arg2=SFX", 1, true), "PlaySoundFile evidence is missing")
assert(soundReport:find("api=C_Sound.PlaySound arg1=67890 arg2=Dialog arg3=false", 1, true), "C_Sound.PlaySound evidence is missing")
assert(soundReport:find("SOUND_EVENT", 1, true) and soundReport:find("SOUNDKIT_FINISHED arg1=67890 arg2=true arg3=finished", 1, true), "SOUNDKIT_FINISHED arguments are missing")
assert(not soundReport:find("SHOULD_NOT_BE_RETAINED", 1, true), "stopped sound callback payload was retained")
assert(soundReport:find("C_Sound.PlaySoundFile=unavailable", 1, true), "missing sound API was not reported safely")
local manualContext = assert(soundReport:match("=== MANUAL MARK CONTEXT.-\n(.*)"), "manual mark context is missing")
assert(manualContext:find("SOUND_CALL", 1, true), "sound call near marker is missing from manual context")
assert(manualContext:find("SOUNDKIT_FINISHED", 1, true), "sound event near marker is missing from manual context")

-- Bind the first GameObject observed just after a Fishing channel starts, then
-- verify change-only GUID/unit WorldLootObject, tooltip, event, and cursor probes.
local bobberGUID = "GameObject-0-4227-0-71211-35591-000026EB17"
local otherGUID = "GameObject-0-4227-0-71211-99999-0000OTHER"
local nextBobberGUID = "GameObject-0-4227-0-71211-35591-000026EB18"
UnitChannelInfo = function()
    return "Fishing", "Fishing", 136245, 100000, 120000, false, false, 131476, false, 0, 0
end
guidWorldLoot, guidWorldLootInfo = false, nil
softWorldLoot, softWorldLootInfo = false, nil
bobberTooltipData, worldCursorData = nil, nil
worldLootErrors, tooltipErrors = {}, {}
worldLootCalls = { guidWorld = 0, guidInfo = 0, softWorld = 0, softInfo = 0 }
tooltipCalls = { bobber = 0, cursor = 0 }
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
assert(eventFrame.registeredEvents.WORLD_LOOT_OBJECT_INFO_UPDATED, "world-loot update event was not explicitly registered")
assert(eventFrame.registeredEvents.TOOLTIP_DATA_UPDATE, "tooltip update event was not explicitly registered")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "bobber-cast-1")
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", "softinteract", bobberGUID)
local initialBobberReport = lv.FishingDebug.BuildReport()
assert(initialBobberReport:find("BOBBER_BIND", 1, true), "bobber GameObject was not bound")
assert(initialBobberReport:find("cast=1  guid=" .. bobberGUID, 1, true), "bobber binding lacks its cast ID or GUID")
assert(initialBobberReport:find("entryID=35591", 1, true), "bobber entry ID was not parsed for diagnostics")
assert(initialBobberReport:find("source=PLAYER_SOFT_INTERACT_CHANGED", 1, true), "bobber binding source is missing")
assert(initialBobberReport:find("guidWorldLoot=false", 1, true), "initial false GUID baseline is missing")
assert(initialBobberReport:find("guidInfo={nil}", 1, true), "initial nil GUID info is missing")
assert(initialBobberReport:find("softWorldLoot=false", 1, true), "initial softinteract baseline is missing")
assert(CountPlain(initialBobberReport, "BOBBER_STATE") == 2, "initial state should appear once plus its header description")
for _ = 1, 5 do eventFrame.scripts.OnUpdate(eventFrame, 0.10) end
local unchangedBobberReport = lv.FishingDebug.BuildReport()
assert(CountPlain(unchangedBobberReport, "BOBBER_STATE") == 2, "identical false state produced duplicate entries")

guidWorldLoot = true
guidWorldLootInfo = { inventoryType = 7, atMaxQuality = false, isUpgrade = true, nested = { ignored = true } }
eventFrame.scripts.OnUpdate(eventFrame, 0.10)
local trueBobberReport = lv.FishingDebug.BuildReport()
assert(CountPlain(trueBobberReport, "BOBBER_STATE") == 3, "false-to-true did not produce exactly one state change")
assert(trueBobberReport:find("guidWorldLoot=true", 1, true), "true GUID state is missing")
assert(trueBobberReport:find("inventoryType=7 atMaxQuality=false isUpgrade=true", 1, true), "WorldLootObjectInfo scalar fields are missing")
assert(trueBobberReport:find("softWorldLoot=false", 1, true), "GUID and softinteract disagreement was not preserved")
assert(not trueBobberReport:find("ignored", 1, true), "nested WorldLootObjectInfo was recursively serialized")
guidWorldLoot, guidWorldLootInfo = false, nil
eventFrame.scripts.OnUpdate(eventFrame, 0.10)
local falseAgainReport = lv.FishingDebug.BuildReport()
assert(CountPlain(falseAgainReport, "BOBBER_STATE") == 4, "true-to-false did not produce a state change")

guidWorldLoot = true
local guidProbeCallsBeforeEvent = worldLootCalls.guidWorld
eventFrame.scripts.OnEvent(eventFrame, "WORLD_LOOT_OBJECT_INFO_UPDATED", bobberGUID)
assert(worldLootCalls.guidWorld > guidProbeCallsBeforeEvent, "matching world-loot event did not force an immediate probe")
eventFrame.scripts.OnEvent(eventFrame, "WORLD_LOOT_OBJECT_INFO_UPDATED", otherGUID)
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", otherGUID)
local eventBobberReport = lv.FishingDebug.BuildReport()
assert(eventBobberReport:find("event=WORLD_LOOT_OBJECT_INFO_UPDATED guid=" .. bobberGUID .. " matchesBobber=true", 1, true), "matching bobber event correlation is missing")
assert(eventBobberReport:find("event=WORLD_LOOT_OBJECT_INFO_UPDATED guid=" .. otherGUID .. " matchesBobber=false", 1, true), "nonmatching bobber event correlation is missing")
assert(CountPlain(eventBobberReport, "BOBBER_BIND") == 2, "unrelated GameObject replaced the bobber")

local tooltipLines = {}
for index = 1, 8 do tooltipLines[index] = { leftText = "tooltip-line-" .. index, rightText = "right-" .. index, color = { 1, 1, 1 } } end
bobberTooltipData = {
    type = 4, id = 2468, dataInstanceID = 77, guid = bobberGUID,
    hasDynamicData = true, lines = tooltipLines, nested = { ignored = true },
}
eventFrame.scripts.OnUpdate(eventFrame, 0.10)
local tooltipReport = lv.FishingDebug.BuildReport()
assert(tooltipReport:find("BOBBER_TOOLTIP", 1, true), "bobber tooltip state is missing")
assert(tooltipReport:find("type=4 id=2468 dataInstanceID=77 guid=" .. bobberGUID, 1, true), "tooltip scalar summary is incomplete")
assert(tooltipReport:find("lineCount=8", 1, true), "tooltip line count is missing")
assert(tooltipReport:find("tooltip-line-6", 1, true), "bounded tooltip lines lost an allowed line")
assert(not tooltipReport:find("tooltip-line-7", 1, true), "tooltip line serialization exceeded its bound")
assert(not tooltipReport:find("nested", 1, true), "tooltip tables were recursively serialized")
local tooltipCallsBeforeMatch = tooltipCalls.bobber
eventFrame.scripts.OnEvent(eventFrame, "TOOLTIP_DATA_UPDATE", 77)
assert(tooltipCalls.bobber > tooltipCallsBeforeMatch, "matching tooltip update did not force a refresh")
eventFrame.scripts.OnEvent(eventFrame, "TOOLTIP_DATA_UPDATE", 999)
local tooltipEventReport = lv.FishingDebug.BuildReport()
assert(tooltipEventReport:find("event=TOOLTIP_DATA_UPDATE dataInstanceID=77 matchesBobberTooltip=true", 1, true), "matching tooltip event correlation is missing")
assert(not tooltipEventReport:find("dataInstanceID=999", 1, true), "unrelated tooltip update created report spam")

worldCursorData = {
    type = 4, id = 8642, dataInstanceID = 88, guid = bobberGUID,
    hasDynamicData = false, lines = { { leftText = "cursor-bobber", rightText = nil } },
}
local cursorCallsBeforePolling = tooltipCalls.cursor
eventFrame.scripts.OnUpdate(eventFrame, 0.10)
assert(tooltipCalls.cursor == cursorCallsBeforePolling, "world cursor was polled by the 10 Hz sampler")
eventFrame.scripts.OnEvent(eventFrame, "CURSOR_CHANGED")
eventFrame.scripts.OnEvent(eventFrame, "WORLD_CURSOR_TOOLTIP_UPDATE")
local cursorReport = lv.FishingDebug.BuildReport()
assert(tooltipCalls.cursor == cursorCallsBeforePolling + 2, "world cursor was not probed only on cursor events")
assert(CountPlain(cursorReport, "BOBBER_CURSOR") == 2, "identical cursor snapshots were logged repeatedly")
assert(cursorReport:find("cursor-bobber", 1, true), "compact cursor tooltip text is missing")
SlashCmdList.LVFISHDEBUG("mark")
local bobberContextReport = lv.FishingDebug.BuildReport()
local bobberManualContext = assert(bobberContextReport:match("=== MANUAL MARK CONTEXT.-\n(.*)"), "bobber manual context is missing")
assert(bobberManualContext:find("BOBBER_", 1, true), "bobber evidence near the marker is missing from manual context")

-- A new cast clears the old binding and can acquire only a fresh first candidate.
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "bobber-cast-2")
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", nextBobberGUID)
local replacementReport = lv.FishingDebug.BuildReport()
assert(replacementReport:find("BOBBER_CLEAR", 1, true) and replacementReport:find("reason=new-cast", 1, true), "new cast did not clear stale bobber state")
assert(replacementReport:find("guid=" .. nextBobberGUID .. " entryID=35591", 1, true), "new cast did not bind its fresh bobber")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_STOP", "player", "Fishing", "bobber-cast-2")
for _ = 1, 10 do eventFrame.scripts.OnUpdate(eventFrame, 0.10) end
local graceReport = lv.FishingDebug.BuildReport()
assert(graceReport:find("guid=" .. nextBobberGUID .. " reason=post-cast-timeout", 1, true), "post-cast grace period did not clear the bobber")

-- Stop clears a live binding before recording is disabled.
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "stop-cast")
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", bobberGUID)
SlashCmdList.LVFISHDEBUG("stop")
local stoppedBobberReport = lv.FishingDebug.BuildReport()
assert(stoppedBobberReport:find("BOBBER_CLEAR", 1, true) and stoppedBobberReport:find("reason=recording-stopped", 1, true), "recording stop did not clear the bobber")
eventFrame.scripts.OnEvent(eventFrame, "WORLD_LOOT_OBJECT_INFO_UPDATED", bobberGUID)
assert(lv.FishingDebug.BuildReport() == stoppedBobberReport, "stopped bobber event changed the report")

-- Missing namespaces/functions and repeated API failures are safe and change-only.
local savedWorldLootAPI = C_WorldLootObject
C_WorldLootObject = nil
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "missing-api-cast")
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", bobberGUID)
local missingNamespaceReport = lv.FishingDebug.BuildReport()
assert(missingNamespaceReport:find("guidWorldLoot=unavailable", 1, true), "missing WorldLootObject namespace was unsafe")
assert(missingNamespaceReport:find("IsWorldLootObjectByGUID=unavailable", 1, true), "missing namespace capability was not reported")
SlashCmdList.LVFISHDEBUG("stop")
C_WorldLootObject = savedWorldLootAPI
local savedInfoByGUID = C_WorldLootObject.GetWorldLootObjectInfoByGUID
C_WorldLootObject.GetWorldLootObjectInfoByGUID = nil
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "missing-function-cast")
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", bobberGUID)
local missingFunctionReport = lv.FishingDebug.BuildReport()
assert(missingFunctionReport:find("guidInfo={unavailable}", 1, true), "missing individual WorldLootObject function was unsafe")
SlashCmdList.LVFISHDEBUG("stop")
C_WorldLootObject.GetWorldLootObjectInfoByGUID = savedInfoByGUID

worldLootErrors = { guidWorld = true, guidInfo = true, softWorld = true, softInfo = true }
tooltipErrors = { bobber = true }
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "error-cast")
eventFrame.scripts.OnEvent(eventFrame, "PLAYER_SOFT_INTERACT_CHANGED", bobberGUID)
for _ = 1, 5 do eventFrame.scripts.OnUpdate(eventFrame, 0.10) end
local errorReport = lv.FishingDebug.BuildReport()
assert(errorReport:find("guidWorldLoot=error", 1, true), "WorldLootObject API error was not normalized")
assert(errorReport:find("guidInfo={error}", 1, true), "WorldLootObject info error was not normalized")
assert(errorReport:find("TooltipWorldLootObject=available:last=error", 1, true), "tooltip API error status is missing")
assert(CountPlain(errorReport, "BOBBER_STATE") == 2, "repeated WorldLootObject errors spammed state entries")
assert(CountPlain(errorReport, "BOBBER_TOOLTIP") == 2, "repeated tooltip errors spammed tooltip entries")
SlashCmdList.LVFISHDEBUG("stop")
worldLootErrors, tooltipErrors = {}, {}
bobberTooltipData, worldCursorData = nil, nil

-- A report larger than the native-like default byte cap must be generated and
-- displayed as one complete, unlimited value with no pagination artifacts.
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
for index = 1, 500 do
    eventFrame.scripts.OnEvent(eventFrame, "HARNESS_EVENT", string.rep("x", 120), index)
end
SlashCmdList.LVFISHDEBUG("mark")
SlashCmdList.LVFISHDEBUG("stop")
local completeReport = lv.FishingDebug.BuildReport()
assert(#completeReport > 32767, "large report did not exceed the simulated default byte cap")
assert(completeReport:find("=== MANUAL MARK CONTEXT", 1, true), "large report lost manual mark context")
assert(completeReport:find("recording stopped reason=manual stop", 1, true), "complete report lost stop evidence")
SlashCmdList.LVFISHDEBUG("show")
assert(window.editBox:GetText() == completeReport, "viewer did not contain the complete generated report")
assert(not window.editBox:GetText():find("copy page", 1, true), "report still contains page numbering")
assert(window.reportPages == nil and window.reportPageIndex == nil, "pagination state still exists")
assert(window.previousPage == nil and window.nextPage == nil, "pagination buttons still exist")
window.scrollFrame.scripts.OnMouseWheel(window.scrollFrame, -1)
assert(window.scrollFrame.verticalScroll > 0, "mouse wheel did not scroll the report")

-- Existing player channel/cast detection must still associate entries with a
-- cast and retain the recorded Fishing spell/channel information.
SlashCmdList.LVFISHDEBUG("clear")
SlashCmdList.LVFISHDEBUG("start")
UnitChannelInfo = function()
    return "Fishing", "Fishing", 136245, 100000, 120000, false, false, 131476, false, 0, 0
end
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_START", "player", "Fishing", "cast-guid")
SlashCmdList.LVFISHDEBUG("mark")
eventFrame.scripts.OnEvent(eventFrame, "UNIT_SPELLCAST_CHANNEL_STOP", "player", "Fishing", "cast-guid")
SlashCmdList.LVFISHDEBUG("stop")
local castReport = lv.FishingDebug.BuildReport()
assert(castReport:find("CAST_START", 1, true), "cast start was not retained")
assert(castReport:find("CAST_END", 1, true), "cast end was not retained")
assert(castReport:find("spellID=131476", 1, true), "Fishing spell/channel data was not retained")
assert(castReport:find("PLAYER_MARK", 1, true), "manual marker was not retained with the cast")
assert(castReport:find("cast=1", 1, true), "cast ID was not associated with cast evidence")
print("Fishing diagnostic start -> mark -> stop -> show passed")
