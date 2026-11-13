-- Accountant Classic history ledger.
--
-- A second, long-lived money record that sits next to the classic Session / Day /
-- PrvDay / ... / Total data without touching it. Every logged money change is added,
-- at the moment it happens, to a per day / per character / per category bucket, so
-- no period rollover or batch job is involved and nothing is lost when a period ends.
--
--   Accountant_ClassicHistory
--     .chars[charKey].days[YYYYMMDD][category] = { i, o, ni, no, mi, mo }
--     .chars[charKey].days[YYYYMMDD].h[hour]   = { i, o, m, a }
--     .chars[charKey].days[YYYYMMDD].bal       = closing balance of the day
--     .chars[charKey].days[YYYYMMDD].z[uiMapID][category]          = { i, o, ni, no }
--     .chars[charKey].days[YYYYMMDD].s[uiMapID][subZone][category] = { i, o, ni, no }
--     .warband                                  = Warband bank balance (Retail)
--     .recent                                   = bounded list of recent records
--
-- A money change found at login (between the last logout and this login, e.g. played
-- without the addon) is "untracked": it is counted in the day's category bucket so the
-- totals still match the classic data, but it has no hour and no place, so it is left
-- out of the hourly and location buckets and its recent record carries u = 1.
--
-- The daily buckets are the only source for reports; the recent list exists for
-- drill-down and debugging and can be trimmed or wiped without changing any total.
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
---@class ACNamespace
local private = select(2, ...)

local _G = getfenv(0)
local pairs, ipairs, next, type, tonumber, tostring = _G.pairs, _G.ipairs, _G.next, _G.type, _G.tonumber, _G.tostring
local format = string.format
local floor = math.floor
local tsort, tconcat = table.sort, table.concat
local time, date = _G.time, _G.date
local LibStub = _G.LibStub

---@class ACHistory
local History = {}
private.History = History

-----------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------
local SCHEMA = 1
local DEFAULT_RECENT_MAX = 2000
local DEFAULT_RECENT_DAYS = 30
-- The recent list may grow this far past its limit during a session before it is
-- trimmed again, so trimming is a rare bulk operation instead of a per-record one.
local RECENT_SLACK = 200
-- Consecutive income records of a mergeable category, by one character in one place
-- within this many seconds of the first one, are merged into a single recent record.
local RECENT_MERGE_SECONDS = 60
-- Categories whose income records are merged (looting, selling to a merchant).
-- Spending is never merged, so every purchase or repair keeps its own record.
local MERGE_CATEGORIES = { LOOT = true, MERCH = true }
local ONLINE_TICK_SECONDS = 60
local SECONDS_PER_DAY = 86400

-- Categories whose money movement is a transfer between the player's own pockets.
-- They are kept out of income, expense and the hourly buckets.
---@type table<string, "transfer">
local TRANSFER_CATEGORIES = {
	WARBAND = "transfer",
}
History.TRANSFER_CATEGORIES = TRANSFER_CATEGORIES

-----------------------------------------------------------------------
-- Small helpers
-----------------------------------------------------------------------
local issecretvalue = _G.issecretvalue

---@param value any
---@return boolean usable True for a plain, non secret number
local function isUsableNumber(value)
	if issecretvalue and issecretvalue(value) then return false end
	return type(value) == "number"
end

---Tests a flag returned by the game API. Since 12.0 some of them (e.g. UnitIsAFK)
---can return a secret boolean, which raises an error when tested; it counts as false.
---@param value any
---@return boolean
local function isTrue(value)
	if issecretvalue and issecretvalue(value) then return false end
	return not not value
end

---@param t integer? Unix time, defaults to now
---@return integer day YYYYMMDD in local time
local function dayKey(t)
	return tonumber(date("%Y%m%d", t or time())) --[[@as integer]]
end
History.DayKey = dayKey

---@param day integer YYYYMMDD
---@return integer t Unix time of local noon on that day (noon avoids DST edges)
local function dayToTime(day)
	local y = floor(day / 10000)
	local m = floor(day / 100) % 100
	local d = day % 100
	return time({ year = y, month = m, day = d, hour = 12 })
end
History.DayToTime = dayToTime

---@param day integer YYYYMMDD
---@param delta integer Days to add (may be negative)
---@return integer day YYYYMMDD
local function addDays(day, delta)
	return dayKey(dayToTime(day) + delta * SECONDS_PER_DAY)
end
History.AddDays = addDays

---@param server string
---@param name string
---@return string charKey
local function charKey(server, name)
	return server .. "|" .. name
end
History.CharKey = charKey

local function newBucket()
	return { i = 0, o = 0, ni = 0, no = 0, mi = 0, mo = 0 }
end

local function newLocationBucket()
	return { i = 0, o = 0, ni = 0, no = 0 }
end

-- uiMapID used when the map is unknown (e.g. during a loading screen).
local UNKNOWN_MAP = 0
-- Prefix of a sub-zone key that holds raw text (no English key was found):
-- "#<locale>:<text>", so it can be resolved again later on a client of that locale.
local RAW_SUBZONE_PREFIX = "#"
History.UNKNOWN_MAP = UNKNOWN_MAP
History.RAW_SUBZONE_PREFIX = RAW_SUBZONE_PREFIX

-----------------------------------------------------------------------
-- Database
-----------------------------------------------------------------------
---@type ACHistoryDB?
local db
---@type ACHistoryChar? Node of the character currently logged in
local current
---@type string? charKey of the character currently logged in
local currentKey
---@type boolean True when the saved data was written by a newer schema; nothing is written then
local readOnly = false

---Upgrades older saved data to SCHEMA. Each step moves the data one version up.
---@param data table
local function migrate(data)
	-- schema 1 is the first version; future steps go here, e.g.
	-- if data.schema == 1 then ...; data.schema = 2 end
	data.schema = data.schema or SCHEMA
end

---Creates or upgrades the saved table. Safe to call more than once.
---@return ACHistoryDB?
function History:InitDB()
	local data = _G.Accountant_ClassicHistory
	if type(data) ~= "table" then
		data = {}
		_G.Accountant_ClassicHistory = data
	end
	if data.schema and data.schema > SCHEMA then
		-- Saved by a newer version of the addon: keep it intact.
		readOnly = true
		db = data --[[@as ACHistoryDB]]
		return db
	end
	migrate(data)
	data.created = data.created or time()
	data.settings = data.settings or {}
	data.settings.recentMax = data.settings.recentMax or DEFAULT_RECENT_MAX
	data.settings.recentDays = data.settings.recentDays or DEFAULT_RECENT_DAYS
	data.chars = data.chars or {}
	data.recent = data.recent or {}
	db = data --[[@as ACHistoryDB]]
	return db
end

---@return ACHistoryDB?
function History:GetDB()
	return db
end

---@return boolean
function History:IsReadOnly()
	return readOnly
end

-----------------------------------------------------------------------
-- Characters
-----------------------------------------------------------------------
---Moves a character node out of the way, e.g. when a deleted character's name is reused.
---@param key string
---@return string archivedKey
local function archiveChar(key)
	local node = db.chars[key]
	local stamp = node.deleted or time()
	local archived = key .. "#" .. stamp
	local n = 1
	while db.chars[archived] do
		n = n + 1
		archived = key .. "#" .. stamp .. "-" .. n
	end
	db.chars[archived] = node
	db.chars[key] = nil
	node.archivedFrom = key
	node.deleted = node.deleted or stamp
	return archived
end

---Returns (and creates when needed) the node of a character.
---@param server string
---@param name string
---@return ACHistoryChar
function History:GetChar(server, name)
	local key = charKey(server, name)
	local node = db.chars[key]
	if not node then
		node = {
			server = server,
			name = name,
			since = dayKey(),
			days = {},
		}
		db.chars[key] = node
	end
	return node
end

---Called once the player is in the world. Identifies the character node, handles
---deleted / re-created characters and stores the opening balance.
---@param server string
---@param name string
---@param info { guid: string?, faction: string?, class: string?, money: integer? }
function History:OnLogin(server, name, info)
	if not db or readOnly then return end
	local key = charKey(server, name)
	local node = db.chars[key]
	local guid = info.guid
	if guid and issecretvalue and issecretvalue(guid) then guid = nil end

	if node and guid and node.guid and node.guid ~= guid then
		-- Same name, different character: the old one was deleted and the name reused.
		archiveChar(key)
		node = nil
	end
	node = node or self:GetChar(server, name)
	if guid then node.guid = guid end
	-- The same character logging in again after its classic data was removed.
	node.deleted = nil
	node.faction = info.faction or node.faction
	node.class = info.class or node.class

	current, currentKey = node, key
	if isUsableNumber(info.money) then
		self:SetBalance(info.money)
	end
	self:TrimRecent()
	self:StartOnlineTimer()
	self:UpdateWarband()
end

---Stores the current character's last known balance and today's closing balance.
---@param money integer
function History:SetBalance(money)
	if not current or readOnly or not isUsableNumber(money) then return end
	local now = time()
	local day = dayKey(now)
	local d = current.days[day]
	if not d then
		d = {}
		current.days[day] = d
	end
	d.bal = money
	current.money, current.moneyAt = money, now
end

---Marks a character as deleted, or removes its history completely.
---@param server string
---@param name string
---@param removeHistory boolean
function History:OnCharacterRemoved(server, name, removeHistory)
	if not db or readOnly then return end
	local key = charKey(server, name)
	local node = db.chars[key]
	if not node then return end
	if removeHistory then
		db.chars[key] = nil
		local recent = db.recent
		local kept = {}
		for _, r in ipairs(recent) do
			if r.c ~= key then kept[#kept + 1] = r end
		end
		db.recent = kept
	else
		node.deleted = time()
	end
	if key == currentKey and removeHistory then
		current, currentKey = nil, nil
	end
end

-----------------------------------------------------------------------
-- Location (recent records only)
-----------------------------------------------------------------------
local C_Map = _G.C_Map
local GetSubZoneText, IsInInstance, GetLocale = _G.GetSubZoneText, _G.IsInInstance, _G.GetLocale

---@type table? LibBabble-SubZone-3.0, looked up lazily
local LBSZ
local LBSZ_checked = false
local lastSubZoneText, lastSubZoneKey

---@return table?
local function getLBSZ()
	if not LBSZ_checked then
		LBSZ_checked = true
		LBSZ = LibStub and LibStub("LibBabble-SubZone-3.0", true)
	end
	return LBSZ
end

-- Separator of an ambiguous sub-zone key: "English A;English B". No English key
-- contains ";", and unlike "|" it is not an escape character in WoW text.
local AMBIGUOUS_SEPARATOR = ";"
History.AMBIGUOUS_SEPARATOR = AMBIGUOUS_SEPARATOR

---Turns the localized sub-zone text into LibBabble-SubZone's English key.
---The lookup has to happen now: the library only knows the running locale, so a
---localized string saved today could not be resolved after a locale switch.
---When several English names share the translation (mostly spelling variants such
---as "The Scribe's Sacellum" / "The Scribes' Sacellum"), all of them are kept,
---sorted and joined with ";", so the key stays stable and locale independent and
---can still be matched to the single English key recorded by an enUS client.
---@param text string Localized text from GetSubZoneText()
---@return string? key English key (or joined candidates), nil when unknown
local function resolveSubZoneKey(text)
	if text == lastSubZoneText then return lastSubZoneKey end
	lastSubZoneText, lastSubZoneKey = text, nil
	local lib = getLBSZ()
	if lib and lib.GetReverseIterator then
		local keys = {}
		for key in lib:GetReverseIterator(text) do
			keys[#keys + 1] = key
		end
		if #keys == 1 then
			lastSubZoneKey = keys[1]
		elseif #keys > 1 then
			tsort(keys)
			lastSubZoneKey = tconcat(keys, AMBIGUOUS_SEPARATOR)
		end
	end
	return lastSubZoneKey
end

---Localized name of a stored English sub-zone key (or joined candidates).
---@param key string
---@return string
local function subZoneKeyName(key)
	local lib = getLBSZ()
	local first = key:match("^([^;]+)") or key
	local name = lib and lib:GetLookupTable()[first]
	return name or first
end

---@return integer? mapID uiMapID of the player
---@return string? subZoneKey English sub-zone key
---@return string? subZoneRaw Localized sub-zone text when no key was found
---@return string? subZoneLocale Locale of subZoneRaw
local function getLocation()
	local mapID
	if C_Map and C_Map.GetBestMapForUnit then
		local ok, id = pcall(C_Map.GetBestMapForUnit, "player")
		if ok and isUsableNumber(id) then mapID = id end
	end
	-- Inside instances the sub-zone adds little, same as the classic zone breakdown.
	if IsInInstance and isTrue((IsInInstance())) then
		return mapID
	end
	local text = GetSubZoneText and GetSubZoneText()
	if type(text) ~= "string" or text == "" or (issecretvalue and issecretvalue(text)) then
		return mapID
	end
	local key = resolveSubZoneKey(text)
	if key then return mapID, key end
	return mapID, nil, text, GetLocale and GetLocale() or nil
end
History.GetLocation = getLocation

---Localized name of a recent record's location for the running client.
---@param record ACHistoryRecent
---@return string? zone
---@return string? subZone
function History:GetLocationName(record)
	local zone, subZone
	if record.z and C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(record.z)
		zone = info and info.name
	end
	if record.s then
		subZone = subZoneKeyName(record.s)
	elseif record.sr then
		-- No English key was found when this was recorded; the raw text is shown as
		-- saved (it may be in another locale, see record.sl).
		subZone = record.sr
	end
	return zone, subZone
end

-----------------------------------------------------------------------
-- Recent records
-----------------------------------------------------------------------
---@param now integer
---@param key string charKey
---@param category string
---@param diff integer Signed amount
---@param z integer? uiMapID
---@param s string? English sub-zone key
---@param sr string? Raw sub-zone text
---@param sl string? Locale of sr
---@param untracked boolean? Money change found at login (no place, never merged)
function History:PushRecent(now, key, category, diff, z, s, sr, sl, untracked)
	local recent = db.recent
	local last = recent[#recent]
	if untracked then
		recent[#recent + 1] = { t = now, c = key, k = category, a = diff, u = 1 }
	elseif MERGE_CATEGORIES[category] and diff > 0 and last and not last.u and last.k == category and last.c == key
		and last.a > 0 and last.z == z and last.s == s and last.sr == sr
		and (now - last.t) <= RECENT_MERGE_SECONDS then
		last.a = last.a + diff
		last.n = (last.n or 1) + 1
		return
	else
		recent[#recent + 1] = { t = now, c = key, k = category, a = diff, z = z, s = s, sr = sr, sl = sl }
	end
	if #recent > db.settings.recentMax + RECENT_SLACK then
		self:TrimRecent()
	end
end

---Drops recent records older than recentDays and keeps at most recentMax of them.
function History:TrimRecent()
	if not db or readOnly then return end
	local recent = db.recent
	local max = db.settings.recentMax
	local cutoff = time() - db.settings.recentDays * SECONDS_PER_DAY
	local first = 1
	while recent[first] and recent[first].t < cutoff do
		first = first + 1
	end
	local count = #recent - first + 1
	if count > max then
		first = first + (count - max)
	end
	if first > 1 then
		local kept = {}
		for i = first, #recent do
			kept[#kept + 1] = recent[i]
		end
		db.recent = kept
	end
end

-----------------------------------------------------------------------
-- Recording
-----------------------------------------------------------------------
---Adds one money change to today's buckets. Called from updateLog() after the
---classic data has been written, so it inherits all of its log type decisions.
---@param server string
---@param name string
---@param category string Classic log type, or a history-only category such as WARBAND
---@param diff integer Signed copper amount, positive for money in
---@param balance integer? Balance after the change
---@param untracked boolean? The change happened outside the tracked sessions (see top)
function History:Record(server, name, category, diff, balance, untracked)
	if not db or readOnly or not isUsableNumber(diff) or diff == 0 then return end
	local key = charKey(server, name)
	local node = (key == currentKey and current) or self:GetChar(server, name)
	local now = time()
	local day = dayKey(now)

	local d = node.days[day]
	if not d then
		d = {}
		node.days[day] = d
	end
	local b = d[category]
	if not b then
		b = newBucket()
		d[category] = b
	end

	local amount
	if diff > 0 then
		amount = diff
		b.i, b.ni = b.i + amount, b.ni + 1
		if amount > b.mi then b.mi = amount end
	else
		amount = -diff
		b.o, b.no = b.o + amount, b.no + 1
		if amount > b.mo then b.mo = amount end
	end

	local placed = not TRANSFER_CATEGORIES[category] and not untracked
	if placed then
		local hr = tonumber(date("%H", now)) --[[@as integer]]
		local h = d.h
		if not h then
			h = {}
			d.h = h
		end
		local hb = h[hr]
		if not hb then
			hb = { i = 0, o = 0, m = 0 }
			h[hr] = hb
		end
		if diff > 0 then hb.i = hb.i + amount else hb.o = hb.o + amount end
	end

	if isUsableNumber(balance) then
		d.bal = balance
		node.money, node.moneyAt = balance, now
	end

	if untracked then
		self:PushRecent(now, key, category, diff, nil, nil, nil, nil, true)
		return
	end
	local z, s, sr, sl = getLocation()
	if placed then
		self:AddLocation(d, category, diff, z, s, sr, sl)
	end
	self:PushRecent(now, key, category, diff, z, s, sr, sl)
end

---Adds a money change to the day's per zone and per sub-zone buckets. These are kept
---as long as the daily buckets, so location analysis is not limited to the recent list.
---Transfers are left out, same as the hourly buckets.
---@param d ACHistoryDay
---@param category string
---@param diff integer
---@param z integer?
---@param s string?
---@param sr string?
---@param sl string?
function History:AddLocation(d, category, diff, z, s, sr, sl)
	local mapID = z or UNKNOWN_MAP
	local amount = diff > 0 and diff or -diff

	local function add(byCategory)
		local b = byCategory[category]
		if not b then
			b = newLocationBucket()
			byCategory[category] = b
		end
		if diff > 0 then
			b.i, b.ni = b.i + amount, b.ni + 1
		else
			b.o, b.no = b.o + amount, b.no + 1
		end
	end

	local zones = d.z
	if not zones then
		zones = {}
		d.z = zones
	end
	local zone = zones[mapID]
	if not zone then
		zone = {}
		zones[mapID] = zone
	end
	add(zone)

	local subKey = s or (sr and (RAW_SUBZONE_PREFIX .. (sl or "") .. ":" .. sr))
	if subKey then
		local subs = d.s
		if not subs then
			subs = {}
			d.s = subs
		end
		local byMap = subs[mapID]
		if not byMap then
			byMap = {}
			subs[mapID] = byMap
		end
		local sub = byMap[subKey]
		if not sub then
			sub = {}
			byMap[subKey] = sub
		end
		add(sub)
	end
end

-----------------------------------------------------------------------
-- Online / AFK minutes
-----------------------------------------------------------------------
local onlineTicker
local UnitIsAFK = _G.UnitIsAFK

---Adds one minute of online time (and AFK time when flagged) to the current hour.
function History:TickOnline()
	if not current or readOnly then return end
	local now = time()
	local day = dayKey(now)
	local hr = tonumber(date("%H", now)) --[[@as integer]]
	local d = current.days[day]
	if not d then
		d = {}
		current.days[day] = d
	end
	local h = d.h
	if not h then
		h = {}
		d.h = h
	end
	local hb = h[hr]
	if not hb then
		hb = { i = 0, o = 0, m = 0 }
		h[hr] = hb
	end
	hb.m = (hb.m or 0) + 1
	-- A secret AFK flag (12.0) cannot be read; that minute counts as online only.
	if UnitIsAFK and isTrue(UnitIsAFK("player")) then
		hb.a = (hb.a or 0) + 1
	end
end

function History:StartOnlineTimer()
	if onlineTicker or not (_G.C_Timer and _G.C_Timer.NewTicker) then return end
	onlineTicker = _G.C_Timer.NewTicker(ONLINE_TICK_SECONDS, function() History:TickOnline() end)
end

-----------------------------------------------------------------------
-- Warband bank balance (Retail only)
-----------------------------------------------------------------------
---@return integer? money Warband bank balance, nil when unavailable on this client
local function fetchWarbandMoney()
	local C_Bank = _G.C_Bank
	local bankTypes = _G.Enum and _G.Enum.BankType
	if not (C_Bank and C_Bank.FetchDepositedMoney and bankTypes and bankTypes.Account) then return nil end
	local ok, money = pcall(C_Bank.FetchDepositedMoney, bankTypes.Account)
	if ok and isUsableNumber(money) then return money end
end

---Reads the Warband bank balance and stores it with today's closing value.
---A failed read never overwrites a stored value.
function History:UpdateWarband()
	if not db or readOnly then return end
	local money = fetchWarbandMoney()
	if not money then return end
	local w = db.warband
	if not w then
		w = { days = {} }
		db.warband = w
	end
	local now = time()
	w.money, w.moneyAt = money, now
	w.days[dayKey(now)] = money
end

-----------------------------------------------------------------------
-- Events owned by the history module
-----------------------------------------------------------------------
local eventFrame
function History:RegisterEvents()
	if eventFrame or not _G.CreateFrame then return end
	eventFrame = _G.CreateFrame("Frame")
	eventFrame:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_LOGOUT" then
			-- GetMoney() reports 0 while logging out, so the balance is not read here;
			-- the last value written by Record() / PLAYER_ENTERING_WORLD is kept.
			History:TrimRecent()
		elseif event == "PLAYER_ENTERING_WORLD" then
			-- GetMoney() is reliable from here on; it may still be 0 at PLAYER_LOGIN.
			if current and _G.GetMoney then History:SetBalance(_G.GetMoney()) end
			History:UpdateWarband()
		else
			History:UpdateWarband()
		end
	end)
	eventFrame:RegisterEvent("PLAYER_LOGOUT")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	local bankTypes = _G.Enum and _G.Enum.BankType
	if _G.C_Bank and _G.C_Bank.FetchDepositedMoney and bankTypes and bankTypes.Account then
		-- ACCOUNT_MONEY does not exist on clients without a Warband bank. The balance
		-- itself may not be available yet this early, so only the API is checked.
		pcall(eventFrame.RegisterEvent, eventFrame, "ACCOUNT_MONEY")
		eventFrame:RegisterEvent("BANKFRAME_OPENED")
	end
end

-----------------------------------------------------------------------
-- Queries (the base for the analysis UI)
-----------------------------------------------------------------------
---@param node ACHistoryChar
---@param scope ACHistoryScope?
---@return boolean
local function inScope(key, node, scope)
	if not scope then return true end
	if scope.char and scope.char ~= "All" and scope.char ~= key then return false end
	if scope.server and scope.server ~= "All" and scope.server ~= node.server then return false end
	if scope.faction and scope.faction ~= "All" and scope.faction ~= node.faction then return false end
	if scope.excludeDeleted and node.deleted then return false end
	return true
end

---Iterates the characters matching scope.
---@param scope ACHistoryScope?
---@return fun(): string?, ACHistoryChar?
function History:IterateChars(scope)
	local chars = db and db.chars or {}
	local key, node
	return function()
		repeat
			key, node = next(chars, key)
		until key == nil or inScope(key, node, scope)
		return key, node
	end
end

---Category totals for a day range.
---@param scope ACHistoryScope?
---@param fromDay integer YYYYMMDD, inclusive
---@param toDay integer YYYYMMDD, inclusive
---@return table<string, ACHistoryBucket> totals By category, transfers included
---@return ACHistorySummary summary Income / expense / net without transfers
function History:GetTotals(scope, fromDay, toDay)
	local totals = {}
	local summary = { income = 0, expense = 0, net = 0, transferIn = 0, transferOut = 0, since = nil }
	for _, node in self:IterateChars(scope) do
		if not summary.since or node.since < summary.since then summary.since = node.since end
		for day, d in pairs(node.days) do
			if day >= fromDay and day <= toDay then
				for category, b in pairs(d) do
					if type(b) == "table" and b.ni then
						local t = totals[category]
						if not t then
							t = newBucket()
							totals[category] = t
						end
						t.i, t.o = t.i + b.i, t.o + b.o
						t.ni, t.no = t.ni + b.ni, t.no + b.no
						if b.mi > t.mi then t.mi = b.mi end
						if b.mo > t.mo then t.mo = b.mo end
						if TRANSFER_CATEGORIES[category] then
							summary.transferIn = summary.transferIn + b.i
							summary.transferOut = summary.transferOut + b.o
						else
							summary.income = summary.income + b.i
							summary.expense = summary.expense + b.o
						end
					end
				end
			end
		end
	end
	summary.net = summary.income - summary.expense
	return totals, summary
end

---One entry per day in the range, zero-filled; days before tracking began are marked.
---@param scope ACHistoryScope?
---@param fromDay integer
---@param toDay integer
---@return ACHistoryDailyPoint[]
function History:GetDailySeries(scope, fromDay, toDay)
	local byDay = {}
	local since
	for _, node in self:IterateChars(scope) do
		if not since or node.since < since then since = node.since end
		for day, d in pairs(node.days) do
			if day >= fromDay and day <= toDay then
				local p = byDay[day]
				if not p then
					p = { income = 0, expense = 0, transferIn = 0, transferOut = 0, minutes = 0, afk = 0 }
					byDay[day] = p
				end
				for category, b in pairs(d) do
					if type(b) == "table" and b.ni then
						if TRANSFER_CATEGORIES[category] then
							p.transferIn = p.transferIn + b.i
							p.transferOut = p.transferOut + b.o
						else
							p.income = p.income + b.i
							p.expense = p.expense + b.o
						end
					end
				end
				if d.h then
					for _, hb in pairs(d.h) do
						p.minutes = p.minutes + (hb.m or 0)
						p.afk = p.afk + (hb.a or 0)
					end
				end
			end
		end
	end

	local series = {}
	local day = fromDay
	while day <= toDay do
		local p = byDay[day] or { income = 0, expense = 0, transferIn = 0, transferOut = 0, minutes = 0, afk = 0 }
		p.day = day
		p.net = p.income - p.expense
		p.noData = (since == nil) or (day < since)
		series[#series + 1] = p
		day = addDays(day, 1)
	end
	return series
end

---Groups a daily series into weeks, months or years.
---@param series ACHistoryDailyPoint[]
---@param unit "week"|"month"|"year"
---@param weekstart integer? 1 = Sunday ... 7 = Saturday (same as the classic option)
---@return ACHistoryDailyPoint[]
function History:AggregateBy(series, unit, weekstart)
	local out, index = {}, {}
	for _, p in ipairs(series) do
		local key
		if unit == "year" then
			key = floor(p.day / 10000) * 10000 + 101
		elseif unit == "month" then
			key = floor(p.day / 100) * 100 + 1
		else
			local t = dayToTime(p.day)
			local back = (tonumber(date("%w", t)) + 1 - (weekstart or 1)) % 7
			key = dayKey(t - back * SECONDS_PER_DAY)
		end
		local g = index[key]
		if not g then
			g = { day = key, income = 0, expense = 0, net = 0, transferIn = 0, transferOut = 0, minutes = 0, afk = 0, noData = true }
			index[key] = g
			out[#out + 1] = g
		end
		g.income = g.income + p.income
		g.expense = g.expense + p.expense
		g.net = g.net + p.net
		g.transferIn = g.transferIn + p.transferIn
		g.transferOut = g.transferOut + p.transferOut
		g.minutes = g.minutes + p.minutes
		g.afk = g.afk + p.afk
		if not p.noData then g.noData = false end
	end
	return out
end

---Totals by location over a range of days. Transfers are never included.
---@param scope ACHistoryScope?
---@param fromDay integer
---@param toDay integer
---@return table<integer, ACHistoryLocationTotal> zones By uiMapID (UNKNOWN_MAP when unknown)
function History:GetLocationTotals(scope, fromDay, toDay)
	local zones = {}
	local function merge(target, byCategory)
		for category, b in pairs(byCategory) do
			local c = target.categories[category]
			if not c then
				c = newLocationBucket()
				target.categories[category] = c
			end
			c.i, c.o, c.ni, c.no = c.i + b.i, c.o + b.o, c.ni + b.ni, c.no + b.no
			target.i, target.o = target.i + b.i, target.o + b.o
			target.ni, target.no = target.ni + b.ni, target.no + b.no
		end
	end
	local function newTotal()
		return { i = 0, o = 0, ni = 0, no = 0, categories = {} }
	end
	for _, node in self:IterateChars(scope) do
		for day, d in pairs(node.days) do
			if day >= fromDay and day <= toDay then
				if d.z then
					for mapID, byCategory in pairs(d.z) do
						local zt = zones[mapID]
						if not zt then
							zt = newTotal()
							zt.subZones = {}
							zones[mapID] = zt
						end
						merge(zt, byCategory)
					end
				end
				if d.s then
					for mapID, bySub in pairs(d.s) do
						local zt = zones[mapID]
						if not zt then
							zt = newTotal()
							zt.subZones = {}
							zones[mapID] = zt
						end
						for subKey, byCategory in pairs(bySub) do
							local st = zt.subZones[subKey]
							if not st then
								st = newTotal()
								zt.subZones[subKey] = st
							end
							merge(st, byCategory)
						end
					end
				end
			end
		end
	end
	return zones
end

---Display names for a uiMapID and a stored sub-zone key, in the running locale.
---@param mapID integer
---@param subKey string?
---@return string zone
---@return string? subZone
function History:GetLocationKeyName(mapID, subKey)
	local zone
	if mapID ~= UNKNOWN_MAP and C_Map and C_Map.GetMapInfo then
		local info = C_Map.GetMapInfo(mapID)
		zone = info and info.name
	end
	zone = zone or ("#" .. tostring(mapID))
	local subZone
	if subKey then
		if subKey:sub(1, 1) == RAW_SUBZONE_PREFIX then
			subZone = subKey:match("^#[^:]*:(.*)$") or subKey
		else
			subZone = subZoneKeyName(subKey)
		end
	end
	return zone, subZone
end

---Sum of every character's last known cash plus the Warband bank.
---@param scope ACHistoryScope?
---@return integer total
---@return table<string, { money: integer, moneyAt: integer?, deleted: integer? }> chars
---@return { money: integer, moneyAt: integer }? warband
function History:GetNetWorth(scope)
	local total, chars = 0, {}
	for key, node in self:IterateChars(scope) do
		if node.money and not node.deleted then
			total = total + node.money
			chars[key] = { money = node.money, moneyAt = node.moneyAt }
		end
	end
	local w = db and db.warband
	if w and w.money then
		total = total + w.money
	end
	return total, chars, w
end

-----------------------------------------------------------------------
-- Diagnostics (slash commands)
-----------------------------------------------------------------------
---@return { chars: integer, deleted: integer, days: integer, buckets: integer, hours: integer, locations: integer, recent: integer, bytes: integer }
function History:GetStats()
	local s = { chars = 0, deleted = 0, days = 0, buckets = 0, hours = 0, locations = 0, recent = 0, bytes = 0 }
	if not db then return s end
	for _, node in pairs(db.chars) do
		s.chars = s.chars + 1
		if node.deleted then s.deleted = s.deleted + 1 end
		for _, d in pairs(node.days) do
			s.days = s.days + 1
			for _, b in pairs(d) do
				if type(b) == "table" and b.ni then s.buckets = s.buckets + 1 end
			end
			if d.h then
				for _ in pairs(d.h) do s.hours = s.hours + 1 end
			end
			if d.z then
				for _, byCategory in pairs(d.z) do
					for _ in pairs(byCategory) do s.locations = s.locations + 1 end
				end
			end
			if d.s then
				for _, bySub in pairs(d.s) do
					for _, byCategory in pairs(bySub) do
						for _ in pairs(byCategory) do s.locations = s.locations + 1 end
					end
				end
			end
		end
	end
	s.recent = #db.recent
	-- Rough size of the serialized SavedVariables text, from measured averages.
	s.bytes = s.days * 40 + s.buckets * 75 + s.hours * 45 + s.locations * 70 + s.recent * 110
	return s
end

---Compares today's history of the current character with the classic Day data.
---@param classicData table<string, ACLogTypeHistory> AccountantClassic_Profile.data
---@return { category: string, classicIn: integer, classicOut: integer, historyIn: integer, historyOut: integer, ok: boolean }[] rows
---@return boolean startedToday True when history began today (classic Day may hold earlier changes)
function History:Verify(classicData)
	local rows = {}
	if not current then return rows, false end
	local today = dayKey()
	local d = current.days[today] or {}
	local function hist(category)
		local b = d[category]
		return b and b.i or 0, b and b.o or 0
	end
	local categories = {}
	for category in pairs(classicData) do categories[#categories + 1] = category end
	tsort(categories)
	for _, category in ipairs(categories) do
		local day = classicData[category].Day or {}
		local cIn, cOut = day.In or 0, day.Out or 0
		local hIn, hOut = hist(category)
		if category == "BANK" then
			-- History splits Warband bank transfers out of the classic BANK row.
			local wIn, wOut = hist("WARBAND")
			hIn, hOut = hIn + wIn, hOut + wOut
		end
		if cIn ~= 0 or cOut ~= 0 or hIn ~= 0 or hOut ~= 0 then
			rows[#rows + 1] = {
				category = category, classicIn = cIn, classicOut = cOut,
				historyIn = hIn, historyOut = hOut, ok = (cIn == hIn and cOut == hOut),
			}
		end
	end
	local startedToday = (current.since == today) or (dayKey(db.created) == today)
	return rows, startedToday
end

---Removes every history record. The classic data is not touched.
function History:Wipe()
	if not db or readOnly then return end
	local settings = db.settings
	for k in pairs(db) do db[k] = nil end
	db.settings = settings
	self:InitDB()
	current, currentKey = nil, nil
end

---Re-attaches the current character after a wipe.
---@param server string
---@param name string
---@param info { guid: string?, faction: string?, class: string?, money: integer? }
function History:Reattach(server, name, info)
	if current then return end
	self:OnLogin(server, name, info)
end

---@param amount integer Copper
---@return string
function History.FormatCopper(amount)
	local sign = amount < 0 and "-" or ""
	amount = amount < 0 and -amount or amount
	local g = floor(amount / 10000)
	local s = floor(amount / 100) % 100
	local c = amount % 100
	return format("%s%dg %02ds %02dc", sign, g, s, c)
end

-- Exposed for tests.
History._internal = {
	resolveSubZoneKey = resolveSubZoneKey,
	resetCaches = function()
		LBSZ, LBSZ_checked, lastSubZoneText, lastSubZoneKey = nil, false, nil, nil
		current, currentKey, readOnly, db = nil, nil, false, nil
		onlineTicker, eventFrame = nil, nil
	end,
}
