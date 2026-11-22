-- /fg perf: times the contact list while it refreshes. Off by default: each timing point
-- then costs one table read, and nothing is hooked into Blizzard's frames until first start.

local addonName, addonTable = ...

local Perf = { on = false }
addonTable.Perf = Perf

local now = debugprofilestop
local AUTO_STOP_SECONDS = 20 * 60
local TIMELINE_SIZE = 60
local HITCH_MS = 100
local SLOW_MS = 50

local stats, counts, inFlight = {}, {}, {}
local timeline = {}
local warnings = {}
local session = { start = 0, stop = nil, shown = 0, peakPerSecond = 0, second = nil, secondCount = 0 }
local profilerStart
local contextProviders = {}
local failedEvents = {}
local attachNote = "not attempted"

local PREFIX = "|cff33ff99FriendGroups|r "

local function Say(text)
	if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. text) end
end

local function Plain(v)
	if v ~= nil and issecretvalue and issecretvalue(v) then return "<secret>" end
	return tostring(v)
end

-- ============================================================================
-- Recording
-- ============================================================================
local function Record(key, ms)
	local s = stats[key]
	if not s then
		s = { n = 0, total = 0, max = 0 }
		stats[key] = s
	end
	s.n = s.n + 1
	s.total = s.total + ms
	if ms > s.max then s.max = ms end
end

local function Bump(key, k)
	counts[key] = (counts[key] or 0) + (k or 1)
end

local function Timeline(label, ms)
	local t = GetTime()
	local last = timeline[#timeline]
	if last and last.label == label and t - last.t1 < 1 then
		last.n = last.n + 1
		last.t1 = t
		if ms then
			last.ms = (last.ms or 0) + ms
			if ms > (last.max or 0) then last.max = ms end
		end
		return
	end
	if #timeline >= TIMELINE_SIZE then table.remove(timeline, 1) end
	timeline[#timeline + 1] = { label = label, t0 = t, t1 = t, n = 1, ms = ms, max = ms }
end

function Perf.Count(key, k)
	if Perf.on then Bump(key, k) end
end

-- Elapsed since t0, a debugprofilestop() value taken while the probe was on.
function Perf.Add(key, t0)
	if not t0 then return end
	local ms = now() - t0
	Record(key, ms)
	return ms
end

function Perf.Finish(key, t0, ...)
	inFlight[key] = nil
	local ms = Perf.Add(key, t0)
	if ms and ms >= SLOW_MS then Timeline("slow " .. key, ms) end
	return ...
end

-- Times fn and keeps its returns: return Perf.Time("key", fn, ...)
-- A call left unfinished by an earlier frame never returned: the client stopped it.
function Perf.Time(key, fn, ...)
	if not Perf.on then return fn(...) end
	local frame = GetTime()
	local open = inFlight[key]
	if open and open ~= frame then
		Bump(key .. ".aborted")
		Timeline("aborted " .. key)
	end
	inFlight[key] = frame
	return Perf.Finish(key, now(), fn(...))
end

function Perf.AddContext(fn)
	contextProviders[#contextProviders + 1] = fn
end

-- Refresh phases: RefreshActionButtonEnabledState (t0), GenerateDataProvider (t1),
-- layout, FriendGroups' Refresh hook (t2), end. RefreshSearchResults has no t0.
local cycle = { open = false }

local function CycleOpen(kind, withStart)
	if cycle.open and cycle.frame ~= GetTime() then
		Bump("blz.aborted")
		Timeline("aborted Blizzard " .. cycle.kind)
	end
	cycle.open, cycle.kind, cycle.frame = true, kind, GetTime()
	cycle.t0 = withStart and now() or nil
	cycle.t1, cycle.t2 = nil, nil
end

local function InBlizzardLayout()
	return cycle.open and cycle.t2 == nil
end

local function OnRefreshStart()
	if Perf.on then CycleOpen("refresh", true) end
end

local function OnGenerated()
	if not Perf.on then return end
	if not cycle.open or cycle.t1 then CycleOpen("search", false) end
	cycle.t1 = now()
end

local function OnCycleEnd()
	if not (Perf.on and cycle.open) then return end
	local tEnd = now()
	local t0, t1, t2 = cycle.t0, cycle.t1, cycle.t2
	local first = t0 or t1 or tEnd
	local key = (cycle.kind == "search") and "blz.search" or "blz.refresh"
	cycle.open = false
	Record(key, tEnd - first)
	Record(key .. ".own", (t2 or tEnd) - first)
	if t0 and t1 then Record("blz.generate", t1 - t0) end
	if t1 then Record("blz.layout", (t2 or tEnd) - t1) end
	if t2 then Record("fg.hook", tEnd - t2) end
	if tEnd - first >= SLOW_MS then Timeline("slow " .. key, tEnd - first) end
end

-- Called first thing in FriendGroups' Refresh and search hooks.
function Perf.HookStart()
	if Perf.on and cycle.open and not cycle.t2 then cycle.t2 = now() end
end

-- FriendGroups code that runs per element or per card, inside or outside Blizzard's layout.
function Perf.Extent(t0)
	Record(InBlizzardLayout() and "extent.blz" or "extent.fg", now() - t0)
end

function Perf.Card(t0)
	Record(InBlizzardLayout() and "card.blz" or "card.fg", now() - t0)
end

-- Set by Platform_SocialUI.lua. The end-of-refresh mark has to run after FriendGroups'
-- own Refresh hook, and hooks run in install order, so attach waits for those.
Perf.fgHooksReady = nil

local attachedView
local SEARCH_METHODS = { "RefreshSearchResults", "OnSearchEnterPressed" }

local function Attach()
	if attachedView then return true end
	local view = SocialUIFrame and SocialUIFrame.FriendsList
	if type(view) ~= "table" or type(view.Refresh) ~= "function" then
		attachNote = "no Social UI friends view on this client"
		return false
	end
	if not Perf.fgHooksReady then
		attachNote = "FriendGroups Social UI module not loaded"
		return false
	end
	if not Perf.fgHooksReady() then
		attachNote = "waiting for FriendGroups' own hooks"
		return false
	end
	attachedView = view
	if type(view.RefreshActionButtonEnabledState) == "function" then
		hooksecurefunc(view, "RefreshActionButtonEnabledState", OnRefreshStart)
		attachNote = "attached"
	else
		attachNote = "attached without a start mark: generate time not split out"
	end
	if type(view.GenerateDataProvider) == "function" then
		hooksecurefunc(view, "GenerateDataProvider", OnGenerated)
	else
		attachNote = attachNote .. "; no GenerateDataProvider"
	end
	hooksecurefunc(view, "Refresh", OnCycleEnd)
	for i = 1, #SEARCH_METHODS do
		if type(view[SEARCH_METHODS[i]]) == "function" then
			hooksecurefunc(view, SEARCH_METHODS[i], OnCycleEnd)
			break
		end
	end
	return true
end

-- ============================================================================
-- Events and frame hitches
-- ============================================================================
local EVENTS = {
	"BN_FRIEND_INFO_CHANGED", "BN_FRIEND_LIST_SIZE_CHANGED", "FRIENDLIST_UPDATE",
	"BN_CONNECTED", "BN_DISCONNECTED",
	"CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER_INFORM",
	"LUA_WARNING", "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN",
}

local EVENT_LABELS = {
	BN_FRIEND_INFO_CHANGED = "friend info",
	BN_FRIEND_LIST_SIZE_CHANGED = "list size",
	FRIENDLIST_UPDATE = "friendlist update",
	BN_CONNECTED = "bnet connected",
	BN_DISCONNECTED = "bnet disconnected",
	CHAT_MSG_WHISPER_INFORM = "whisper sent",
	CHAT_MSG_BN_WHISPER_INFORM = "bnet whisper sent",
	LUA_WARNING = "Lua warning",
	ADDON_ACTION_BLOCKED = "action blocked",
	ADDON_ACTION_FORBIDDEN = "action forbidden",
}

local frame = CreateFrame("Frame")

local function IsListShown()
	local C = addonTable.Compat
	if C and type(C.IsContactListShown) == "function" then
		local ok, shown = pcall(C.IsContactListShown)
		return ok and shown and true or false
	end
	return false
end

local function AddWarning(text)
	if #warnings < 10 then warnings[#warnings + 1] = text end
end

local function OnEvent(_, event, ...)
	if not Perf.on then return end
	Bump("ev." .. event)
	Timeline(EVENT_LABELS[event] or event)
	if event == "BN_FRIEND_INFO_CHANGED" then
		local second = math.floor(GetTime())
		if session.second == second then
			session.secondCount = session.secondCount + 1
		else
			session.second, session.secondCount = second, 1
		end
		if session.secondCount > session.peakPerSecond then session.peakPerSecond = session.secondCount end
	elseif event == "LUA_WARNING" then
		local _, text = ...
		AddWarning(string.format("+%.1fs %s", GetTime() - session.start, Plain(text):sub(1, 160)))
	elseif event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
		local who, what = ...
		AddWarning(string.format("+%.1fs %s: %s %s", GetTime() - session.start, EVENT_LABELS[event], Plain(who), Plain(what)))
	end
end

local editBoxHooked = false
local function HookChatEditBox()
	if editBoxHooked then return end
	local box = (DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox) or _G.ChatFrame1EditBox
	if type(box) == "table" and type(box.HookScript) == "function" then
		box:HookScript("OnShow", function()
			if Perf.on then Timeline("chat box opened") end
		end)
		editBoxHooked = true
	end
end

local nextAttachTry = 0
local function OnUpdate(_, elapsed)
	if not Perf.on then return end
	local shown = IsListShown()
	if shown then session.shown = session.shown + elapsed end
	local ms = elapsed * 1000
	if ms >= HITCH_MS then
		Record("hitch", ms)
		if ms >= 500 then Bump("hitch.500") end
		if ms >= 1000 then Bump("hitch.1000") end
		if shown then Bump("hitch.shown") end
		Timeline("frame hitch", ms)
	end
	local t = GetTime()
	if not attachedView and t >= nextAttachTry then
		nextAttachTry = t + 1
		Attach()
	end
	if t - session.start >= AUTO_STOP_SECONDS then
		Say("perf probe stopped after 20 minutes.")
		Perf.Stop()
	end
end

-- ============================================================================
-- Addon profiler (retail; absent elsewhere)
-- ============================================================================
local PROFILER_METRICS = {
	"PeakTime", "RecentAverageTime", "SessionAverageTime",
	"CountTimeOver100Ms", "CountTimeOver500Ms", "CountTimeOver1000Ms",
}

local function ProfilerRead(name)
	local P = C_AddOnProfiler
	local E = Enum and Enum.AddOnProfilerMetric
	if type(P) ~= "table" or type(P.GetAddOnMetric) ~= "function" or type(E) ~= "table" then return nil end
	local out = {}
	for i = 1, #PROFILER_METRICS do
		local m = PROFILER_METRICS[i]
		if E[m] ~= nil then
			local ok, v = pcall(P.GetAddOnMetric, name, E[m])
			if ok and type(v) == "number" then out[m] = v end
		end
	end
	return out
end

local function ProfilerTop(limit)
	local E = Enum and Enum.AddOnProfilerMetric
	if not (C_AddOns and type(C_AddOns.GetNumAddOns) == "function" and E and E.PeakTime) then return nil end
	if not (C_AddOnProfiler and type(C_AddOnProfiler.GetAddOnMetric) == "function") then return nil end
	local list = {}
	local ok = pcall(function()
		for i = 1, C_AddOns.GetNumAddOns() do
			local name = C_AddOns.GetAddOnInfo(i)
			if type(name) == "string" and C_AddOns.IsAddOnLoaded(i) then
				local got, peak = pcall(C_AddOnProfiler.GetAddOnMetric, name, E.PeakTime)
				if got and type(peak) == "number" and peak > 0 then
					list[#list + 1] = { name = name, peak = peak }
				end
			end
		end
	end)
	if not ok then return nil end
	table.sort(list, function(a, b) return a.peak > b.peak end)
	local parts = {}
	for i = 1, math.min(limit, #list) do
		parts[#parts + 1] = string.format("%s %.0f ms", list[i].name, list[i].peak)
	end
	return table.concat(parts, ", ")
end

-- ============================================================================
-- Report
-- ============================================================================
local OTHER_ADDONS = {
	"ElvUI", "EllesmereUI", "EllesmereUIFriends", "BetterFriendlist", "WIM", "Prat-3.0",
	"Chattynator", "GLogger", "FriendListColors", "RaiderIO", "Glass", "TinyChat",
}

local function Loaded(name)
	if C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function" then
		local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, name)
		return ok and loaded and true or false
	end
	return false
end

local function S(key)
	local s = stats[key]
	if not s or s.n == 0 then return "none" end
	return string.format("%d x, %.0f ms total, max %.1f ms", s.n, s.total, s.max)
end

local function N(key) return counts[key] or 0 end

local function Max(key)
	local s = stats[key]
	return s and s.max or 0
end

local function BuildReport()
	local lines = {}
	local function Add(fmt, ...) lines[#lines + 1] = string.format(fmt, ...) end

	local version = "?"
	if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
		version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "?"
	elseif GetAddOnMetadata then
		version = GetAddOnMetadata(addonName, "Version") or "?"
	end
	local build, buildNum = "?", "?"
	if GetBuildInfo then build, buildNum = GetBuildInfo() end
	local social = "n/a"
	local C = addonTable.Compat
	if C and type(C.IsSocialUIActive) == "function" then
		local ok, active = pcall(C.IsSocialUIActive)
		social = ok and (active and "on" or "off") or "error"
	end
	Add("FriendGroups perf report: v%s, client %s.%s, project %s, Social UI %s",
		tostring(version), tostring(build), tostring(buildNum), tostring(WOW_PROJECT_ID), social)

	local stopAt = session.stop or GetTime()
	local bnetTotal, bnetOnline = 0, 0
	if BNGetNumFriends then
		local ok, t, o = pcall(BNGetNumFriends)
		if ok then bnetTotal, bnetOnline = t or 0, o or 0 end
	end
	local wowFriends = 0
	if C_FriendList and type(C_FriendList.GetNumFriends) == "function" then
		local ok, n = pcall(C_FriendList.GetNumFriends)
		if ok and type(n) == "number" then wowFriends = n end
	end
	Add("Window %.0f s, list open %.0f s. BNet friends %s (%s online), WoW friends %s.",
		stopAt - session.start, session.shown, Plain(bnetTotal), Plain(bnetOnline), Plain(wowFriends))

	for i = 1, #contextProviders do
		local ok, text = pcall(contextProviders[i])
		if ok and type(text) == "string" then Add("%s", text) end
	end

	local others = {}
	for i = 1, #OTHER_ADDONS do
		if Loaded(OTHER_ADDONS[i]) then others[#others + 1] = OTHER_ADDONS[i] end
	end
	local numLoaded = 0
	if C_AddOns and type(C_AddOns.GetNumAddOns) == "function" then
		pcall(function()
			for i = 1, C_AddOns.GetNumAddOns() do
				if C_AddOns.IsAddOnLoaded(i) then numLoaded = numLoaded + 1 end
			end
		end)
	end
	Add("Addons loaded: %d. Of note: %s", numLoaded, (#others > 0) and table.concat(others, ", ") or "none")

	Add("Events: friend info %d (peak %d/s), list size %d, friendlist %d, whispers sent %d, Lua warnings %d, blocked %d",
		N("ev.BN_FRIEND_INFO_CHANGED"), session.peakPerSecond, N("ev.BN_FRIEND_LIST_SIZE_CHANGED"),
		N("ev.FRIENDLIST_UPDATE"), N("ev.CHAT_MSG_WHISPER_INFORM") + N("ev.CHAT_MSG_BN_WHISPER_INFORM"),
		N("ev.LUA_WARNING"), N("ev.ADDON_ACTION_BLOCKED") + N("ev.ADDON_ACTION_FORBIDDEN"))
	if #failedEvents > 0 then Add("Events not available here: %s", table.concat(failedEvents, ", ")) end

	Add("Refresh calls, whole (%s): %s", attachNote, S("blz.refresh"))
	Add("  Blizzard's part: %s", S("blz.refresh.own"))
	Add("  generate max %.1f ms, layout max %.1f ms, never finished %d", Max("blz.generate"), Max("blz.layout"), N("blz.aborted"))
	Add("Search refresh calls, after the search call: %s", S("blz.search"))
	Add("  FriendGroups code inside Blizzard's layout: row heights %s; cards %s", S("extent.blz"), S("card.blz"))
	Add("FriendGroups after each Blizzard refresh: %s", S("fg.hook"))
	Add("FriendGroups rebuild: %s", S("fg.rebuild"))
	Add("  unchanged skips %d, combat deferred %d, requests %d (timers started %d)",
		N("rebuild.unchanged"), N("rebuild.combat"), N("request"), N("request.timer"))
	Add("FriendGroups render: %s", S("fg.render"))
	Add("  set provider %s; card pass %s; held for click or menu %d", S("fg.setProvider"), S("fg.cardPass"), N("render.held"))
	Add("FriendGroups re-assert: %s", S("fg.reassert"))
	Add("FriendGroups own list: row heights %s; cards %s", S("extent.fg"), S("card.fg"))
	Add("Frame hitches >=100 ms: %d (>=500 ms %d, >=1 s %d, with list open %d), worst %.0f ms",
		stats.hitch and stats.hitch.n or 0, N("hitch.500"), N("hitch.1000"), N("hitch.shown"), Max("hitch"))

	local aborted = {}
	for key, n in pairs(counts) do
		local name = key:match("^(.+)%.aborted$")
		if name and name ~= "blz" then aborted[#aborted + 1] = string.format("%s %d", name, n) end
	end
	table.sort(aborted)
	if #aborted > 0 then Add("Never finished: %s", table.concat(aborted, ", ")) end

	local prof = ProfilerRead(addonName)
	if prof and next(prof) then
		local function Delta(m)
			local a, b = prof[m], profilerStart and profilerStart[m]
			if not a then return "?" end
			if b then return string.format("+%d", a - b) end
			return tostring(a)
		end
		Add("Profiler: peak %.0f ms, recent avg %.2f ms, session avg %.2f ms; this window >100 ms %s, >500 ms %s, >1 s %s",
			prof.PeakTime or -1, prof.RecentAverageTime or -1, prof.SessionAverageTime or -1,
			Delta("CountTimeOver100Ms"), Delta("CountTimeOver500Ms"), Delta("CountTimeOver1000Ms"))
		local top = ProfilerTop(6)
		if top and top ~= "" then Add("Peak by addon: %s", top) end
	else
		Add("Profiler: not available on this client")
	end

	for i = 1, #warnings do Add("Warning %s", warnings[i]) end

	Add("Timeline (newest last):")
	for i = 1, #timeline do
		local e = timeline[i]
		local text = string.format("  +%.1fs %s", e.t0 - session.start, e.label)
		if e.n > 1 then text = text .. string.format(" x%d", e.n) end
		if e.max then
			if e.n > 1 then
				text = text .. string.format(" (max %.0f ms, %.0f ms total)", e.max, e.ms)
			else
				text = text .. string.format(" %.0f ms", e.max)
			end
		end
		lines[#lines + 1] = text
	end
	return lines
end

local copyFrame, copyBox
local function ShowCopy(text)
	local ok = pcall(function()
		if not copyFrame then
			local f = CreateFrame("Frame", "FriendGroupsPerfReport", UIParent, "BasicFrameTemplateWithInset")
			f:SetSize(680, 440)
			f:SetPoint("CENTER")
			f:SetFrameStrata("DIALOG")
			f:SetMovable(true)
			f:EnableMouse(true)
			f:RegisterForDrag("LeftButton")
			f:SetScript("OnDragStart", f.StartMoving)
			f:SetScript("OnDragStop", f.StopMovingOrSizing)
			if f.TitleText then f.TitleText:SetText("FriendGroups perf report: Ctrl+C to copy") end
			local sf = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
			sf:SetPoint("TOPLEFT", 12, -30)
			sf:SetPoint("BOTTOMRIGHT", -32, 12)
			local eb = CreateFrame("EditBox", nil, sf)
			eb:SetMultiLine(true)
			eb:SetAutoFocus(false)
			eb:SetFontObject(ChatFontNormal)
			eb:SetWidth(630)
			eb:SetScript("OnEscapePressed", function() f:Hide() end)
			sf:SetScrollChild(eb)
			if type(UISpecialFrames) == "table" then tinsert(UISpecialFrames, "FriendGroupsPerfReport") end
			copyFrame, copyBox = f, eb
		end
		copyBox:SetText(text)
		copyFrame:Show()
		copyBox:SetFocus()
		copyBox:HighlightText()
	end)
	return ok
end

function Perf.Report()
	local ok, lines = pcall(BuildReport)
	if not ok then
		Say("perf report failed: " .. tostring(lines))
		return
	end
	if ShowCopy(table.concat(lines, "\n")) then
		for i = 1, math.min(3, #lines) do Say(lines[i]) end
		Say("Full report is in the window: Ctrl+A, Ctrl+C, then paste it to the author.")
	else
		for i = 1, #lines do Say(lines[i]) end
	end
end

-- ============================================================================
-- Control
-- ============================================================================
local function Reset()
	wipe(stats); wipe(counts); wipe(inFlight); wipe(timeline); wipe(warnings)
	cycle.open = false
	session.start, session.stop, session.shown = GetTime(), nil, 0
	session.peakPerSecond, session.second, session.secondCount = 0, nil, 0
	profilerStart = ProfilerRead(addonName)
end

function Perf.Start()
	if Perf.on then
		Say("perf probe is already on. /fg perf stops it and shows the report.")
		return
	end
	Reset()
	wipe(failedEvents)
	for i = 1, #EVENTS do
		if not pcall(frame.RegisterEvent, frame, EVENTS[i]) then failedEvents[#failedEvents + 1] = EVENTS[i] end
	end
	frame:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnUpdate", OnUpdate)
	pcall(HookChatEditBox)
	Perf.on = true
	nextAttachTry = 0
	Attach()
	Say("perf probe on. Open your friends list and do what freezes it, then type /fg perf again for the report.")
end

function Perf.Stop()
	if not Perf.on then return end
	Perf.on = false
	session.stop = GetTime()
	frame:SetScript("OnUpdate", nil)
	frame:SetScript("OnEvent", nil)
	frame:UnregisterAllEvents()
	Perf.Report()
end

function Perf.Slash(arg)
	arg = (arg or ""):lower()
	if arg == "" then
		if Perf.on then Perf.Stop() else Perf.Start() end
	elseif arg == "start" or arg == "on" then
		Perf.Start()
	elseif arg == "stop" or arg == "off" then
		if Perf.on then Perf.Stop() else Say("perf probe is not on.") end
	elseif arg == "report" then
		Perf.Report()
	elseif arg == "reset" then
		Reset()
		Say("perf counters reset.")
	else
		Say("/fg perf: start or stop the probe. /fg perf report: report so far. /fg perf reset: clear counters.")
	end
end
