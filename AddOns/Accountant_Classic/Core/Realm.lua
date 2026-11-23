-- Accountant Classic realm keys.
--
-- Every saved table is keyed by realm first:
--   Accountant_ClassicSaveData[realm][character]
--   Accountant_ClassicZoneDB[realm][character]
--   Accountant_ClassicHistory.chars["realm|character"]
--
-- WoW Forever 1.60.1 hides the realm from add-ons: GetRealmName() returns "" and
-- GetRealmID() 0 (Blizzard add-on notes "Forever 1.60.1 Live Update 2", November 2026,
-- applied with the November 20 hotfix). Up to v2.30.03 every Forever character was then
-- saved under the realm key "", next to (not in) its earlier record under the real realm
-- name such as "CAMWOW TW4 Realm 1 PvE".
--
-- This file
--   * resolves a stable realm key for the current character when the realm is hidden:
--       1. the realm the same character was saved under before. Forever full names
--          ("First-Surname") are unique per region; when the name is found under more
--          than one realm (e.g. a beta copy), the history GUID, region, ruleset and the
--          last session date pick one;
--       2. for a character first seen after the change: the single earlier realm of the
--          same region and ruleset;
--       3. otherwise a ruleset key, "Forever <region> <ruleset>", e.g. "Forever TW PvE";
--   * merges the records saved under "" back into that realm (RepairHidden). The current
--     character is repaired on login; other characters are repaired at the same time when
--     their realm is certain, otherwise on their own next login.
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
---@class ACNamespace
local private = select(2, ...)

local _G = getfenv(0)
local pairs, ipairs, next, type, pcall = _G.pairs, _G.ipairs, _G.next, _G.type, _G.pcall
local string = _G.string
local strmatch, strfind, strlower, strupper, strsub, gmatch = string.match, string.find, string.lower, string.upper, string.sub, string.gmatch
local tsort = table.sort

---@class ACRealm
local Realm = {}
private.Realm = Realm

-- Realm key written by v2.30.03 and older while Forever hides the realm.
local HIDDEN = ""
Realm.HIDDEN_KEY = HIDDEN
-- Prefix of the realm keys made from the ruleset (step 3 above).
local RULESET_PREFIX = "Forever"
Realm.RULESET_PREFIX = RULESET_PREFIX

-- GetCurrentRegion() ids, same table as AceDB-3.0.
local REGIONS = { "US", "KR", "EU", "TW", "CN" }
local REGION_SET = {}
for _, r in ipairs(REGIONS) do REGION_SET[r] = true end
-- Battle.net Asia (KR and TW) shares portal "KR" / GetCurrentRegion() == 2,
-- while TW Forever realm names contain "TW" (e.g. "CAMWOW TW4 Realm 1 PvE").
local ASIA_REGIONS = { KR = true, TW = true }

local issecretvalue = _G.issecretvalue

---@param value any
---@return string? text The value when it is a plain, non-empty string
local function usableString(value)
	if value == nil then return nil end
	if issecretvalue and issecretvalue(value) then return nil end
	if type(value) ~= "string" or value == "" then return nil end
	return value
end

---@param value any
---@return boolean
local function isTrue(value)
	if issecretvalue and issecretvalue(value) then return false end
	return value == true
end

-----------------------------------------------------------------------
-- Client information
-----------------------------------------------------------------------
---@return string? realm Realm name from the client, nil when it is hidden (Forever)
function Realm.GetClientRealm()
	local GetRealmName = _G.GetRealmName
	if not GetRealmName then return nil end
	local ok, name = pcall(GetRealmName)
	return ok and usableString(name) or nil
end

---@return string? region "US", "KR", "EU", "TW" or "CN"
function Realm.GetRegion()
	local GetCurrentRegion, GetCurrentRegionName = _G.GetCurrentRegion, _G.GetCurrentRegionName
	if GetCurrentRegion then
		local ok, id = pcall(GetCurrentRegion)
		if ok and not (issecretvalue and issecretvalue(id)) and REGIONS[id] then
			return REGIONS[id]
		end
	end
	if GetCurrentRegionName then
		local ok, name = pcall(GetCurrentRegionName)
		name = ok and usableString(name)
		if name then return strupper(name) end
	end
	return nil
end

---Ruleset of the current character, named like AceDB-3.0 does on Forever.
---@return "Hardcore"|"RP-PvP"|"RP"|"PvP"|"PvE"|nil
function Realm.GetRuleset()
	local C_GameRules, Enum = _G.C_GameRules, _G.Enum
	if not (C_GameRules and C_GameRules.IsGameRuleActive and Enum and Enum.GameRule) then return nil end
	local rules = Enum.GameRule
	local function active(rule)
		if rule == nil then return false end
		local ok, value = pcall(C_GameRules.IsGameRuleActive, rule)
		return ok and isTrue(value)
	end
	if active(rules.HardcoreRuleset) then return "Hardcore" end
	local rp, pvp = active(rules.RPRuleset), active(rules.PvPRuleset)
	if rp and pvp then return "RP-PvP" end
	if rp then return "RP" end
	if pvp then return "PvP" end
	return "PvE"
end

-----------------------------------------------------------------------
-- Realm keys
-----------------------------------------------------------------------
---Reads the region and ruleset out of a Forever realm name, e.g.
---"CAMWOW TW4 Realm 1 PvE" -> "TW", "PvE"; "CAMWOW US2 Realm 9 RP PvP" -> "US", "RP-PvP".
---@param name string
---@return string? region
---@return string? ruleset
function Realm.ParseRealm(name)
	if type(name) ~= "string" then return nil, nil end
	local region
	for token in gmatch(name, "%S+") do
		local r = strmatch(token, "^(%u%u)%d*$")
		if r and REGION_SET[r] then
			region = r
			break
		end
	end
	local lower = strlower(name)
	local ruleset
	if strfind(lower, "hardcore", 1, true) then
		ruleset = "Hardcore"
	elseif strfind(lower, "%f[%a]rp[%s%-]*pvp") then
		ruleset = "RP-PvP"
	elseif strfind(lower, "%f[%a]rp%f[%A]") then
		ruleset = "RP"
	elseif strfind(lower, "pvp", 1, true) then
		ruleset = "PvP"
	elseif strfind(lower, "pve", 1, true) or strfind(lower, "normal", 1, true) then
		ruleset = "PvE"
	end
	return region, ruleset
end

---@param name string
---@return boolean
local function isBetaRealm(name)
	return strfind(strlower(name), "beta", 1, true) ~= nil
end

---Realm key made from the region and ruleset, e.g. "Forever TW PvE".
---@param region string?
---@param ruleset string?
---@return string
function Realm.RulesetKey(region, ruleset)
	local key = RULESET_PREFIX
	if region then key = key.." "..region end
	if ruleset then key = key.." "..ruleset end
	return key
end

---Compares two player GUIDs ("Player-<realmID>-<characterID>").
---@param a string?
---@param b string?
---@return boolean? same true = same character, false = another character, nil = unknown
function Realm.CompareGUID(a, b)
	if type(a) ~= "string" or type(b) ~= "string" then return nil end
	if issecretvalue and (issecretvalue(a) or issecretvalue(b)) then return nil end
	if a == b then return true end
	local ra, ca = strmatch(a, "^Player%-(%d+)%-(%x+)$")
	local rb, cb = strmatch(b, "^Player%-(%d+)%-(%x+)$")
	if not ra or not rb then return false end
	-- Same character id: the realm part changed (hidden / obfuscated realm).
	if ca == cb then return true end
	-- Both parts changed: the realm id is no longer readable, so this proves nothing.
	if ra ~= rb then return nil end
	return false
end

---"dd/mm/yy" -> "yymmdd" so that string comparison sorts chronologically.
---@param s string?
---@return string
local function sortableDate(s)
	if type(s) ~= "string" or #s < 8 then return "" end
	return strsub(s, 7, 8)..strsub(s, 4, 5)..strsub(s, 1, 2)
end
Realm.SortableDate = sortableDate

---@param historyChars table<string, ACHistoryChar>?
---@param server string
---@param name string
---@return string? guid
local function historyGUID(historyChars, server, name)
	local node = historyChars and historyChars[server.."|"..name]
	return node and node.guid
end

---Realm keys (other than the hidden one) that hold a classic record of this character,
---best match first.
---@param saveData table<string, table<string, ACCharacterData>>
---@param historyChars table<string, ACHistoryChar>?
---@param name string
---@param info { guid: string?, region: string?, ruleset: string? }
---@return string[] servers
---@return table<string, boolean> guidMatch Servers whose history GUID is the same character
local function findPrevious(saveData, historyChars, name, info)
	local list, score, stamp, guidMatch = {}, {}, {}, {}
	for server, chars in pairs(saveData) do
		if server ~= HIDDEN and type(chars) == "table" and type(chars[name]) == "table" then
			local s = 0
			local same = Realm.CompareGUID(historyGUID(historyChars, server, name), info.guid)
			if same then
				guidMatch[server] = true
				s = s + 8
			elseif same == false then
				-- Another character that had this name (deleted, name reused).
				s = -100
			end
			local region, ruleset = Realm.ParseRealm(server)
			if info.region then
				if region == info.region then
					s = s + 4
				elseif region and ASIA_REGIONS[info.region] and ASIA_REGIONS[region] then
					s = s + 2
				end
			end
			if info.ruleset and ruleset == info.ruleset then s = s + 2 end
			if not isBetaRealm(server) then s = s + 1 end
			list[#list + 1] = server
			score[server] = s
			local options = chars[name].options
			stamp[server] = sortableDate(options and options.lastsessiondate)
		end
	end
	local kept = {}
	for _, server in ipairs(list) do
		if score[server] >= 0 then kept[#kept + 1] = server end
	end
	tsort(kept, function(a, b)
		if score[a] ~= score[b] then return score[a] > score[b] end
		if stamp[a] ~= stamp[b] then return stamp[a] > stamp[b] end
		return a < b
	end)
	return kept, guidMatch
end

---Returns the single non-beta saved realm matching ruleset and region predicate, if unique.
---@param saveData table<string, table<string, ACCharacterData>>
---@param own string Fallback ruleset key to exclude
---@param targetRuleset string
---@param matchRegion fun(region: string?): boolean
---@return string? match
---@return integer count
local function findUniqueRealm(saveData, own, targetRuleset, matchRegion)
	local match, count = nil, 0
	for server in pairs(saveData) do
		if server ~= HIDDEN and server ~= own and not isBetaRealm(server) then
			local region, ruleset = Realm.ParseRealm(server)
			if ruleset == targetRuleset and matchRegion(region) then
				match, count = server, count + 1
			end
		end
	end
	return match, count
end

---Realm key for the current character while the client hides the realm.
---@param saveData table<string, table<string, ACCharacterData>>?
---@param historyChars table<string, ACHistoryChar>?
---@param name string Classic character key
---@param info { guid: string?, region: string?, ruleset: string? }
---@return string server
---@return "previous"|"region"|"ruleset" reason
function Realm.ResolveHidden(saveData, historyChars, name, info)
	saveData = saveData or {}
	-- 1. The realm this character was saved under before.
	local previous = findPrevious(saveData, historyChars, name, info)
	if previous[1] then
		return previous[1], "previous"
	end

	-- 2. A character first seen now: the single earlier realm of its region and ruleset.
	local own = Realm.RulesetKey(info.region, info.ruleset)
	if info.ruleset and not saveData[own] then
		local match, count = findUniqueRealm(saveData, own, info.ruleset, function(region)
			return region == info.region
		end)
		if count == 1 then
			return match --[[@as string]], "region"
		end
		-- On Battle.net Asia, TW clients report region "KR" (GetCurrentRegion() == 2).
		if count == 0 and info.region and ASIA_REGIONS[info.region] then
			match, count = findUniqueRealm(saveData, own, info.ruleset, function(region)
				return region ~= nil and ASIA_REGIONS[region] == true
			end)
			if count == 1 then
				return match --[[@as string]], "region"
			end
		end
	end

	-- 3. Ruleset key.
	return own, "ruleset"
end

---Realm key of the current character.
---@param saveData table?
---@param historyChars table?
---@param name string Classic character key
---@param guid string?
---@param isForever boolean
---@return string server
---@return string? reason nil when the client gave the realm
function Realm.Resolve(saveData, historyChars, name, guid, isForever)
	local realm = Realm.GetClientRealm()
	if realm then return realm, nil end
	if not isForever then
		-- Not expected outside Forever; keep the old behaviour.
		return HIDDEN, nil
	end
	return Realm.ResolveHidden(saveData, historyChars, name, {
		guid = guid,
		region = Realm.GetRegion(),
		ruleset = Realm.GetRuleset(),
	})
end

---Text shown for a realm key.
---@param server string
---@param unknownText string Text for the hidden realm key
---@return string
function Realm.DisplayName(server, unknownText)
	if server == HIDDEN then return unknownText end
	return server
end

-----------------------------------------------------------------------
-- Repair of the records saved under the hidden realm
-----------------------------------------------------------------------
local SESSION_MODE = "Session"

---@param t table?
---@return boolean
local function isEmpty(t)
	return type(t) ~= "table" or next(t) == nil
end

---Adds every In / Out of one amount table into another.
---@param src ACAmounts
---@param dst ACAmounts
local function addAmounts(src, dst)
	dst.In = (dst.In or 0) + (src.In or 0)
	dst.Out = (dst.Out or 0) + (src.Out or 0)
end

---@param src table<string, ACAmounts> Zone -> amounts
---@param dst table<string, ACAmounts>
local function addZoneAmounts(src, dst)
	for zone, amounts in pairs(src) do
		local d = dst[zone]
		if type(d) ~= "table" then
			d = { In = 0, Out = 0 }
			dst[zone] = d
		end
		addAmounts(amounts, d)
	end
end

---Merges one classic character record (and its zone record) into another. Both records
---must already be rolled over to the current periods.
---@param src ACCharacterData Record saved under the hidden realm
---@param dst ACCharacterData Record under the real realm, receives the result
---@param zsrc table? Zone record of src ({ data = ... })
---@param zdst table? Zone record of dst
---@param periods ACPeriodRule[]
---@return table? zone The zone record to keep for dst
function Realm.MergeCharacterData(src, dst, zsrc, zdst, periods)
	local so, dopt = src.options or {}, dst.options
	if not dopt then
		dopt = {}
		dst.options = dopt
	end
	dst.data = dst.data or {}
	local srcNewer = sortableDate(so.lastsessiondate) >= sortableDate(dopt.lastsessiondate)

	-- Previous periods: the same previous period is added up; otherwise the newer
	-- record's previous period wins.
	---@type table<string, "sum"|"take"|"keep">
	local prvAction = {}
	local isPrevious = {}
	for _, period in ipairs(periods) do
		local prvKey, prvMode = period[2], period[4]
		isPrevious[prvMode] = true
		if so[prvKey] == nil then
			prvAction[prvMode] = "keep"
		elseif dopt[prvKey] == nil or so[prvKey] == dopt[prvKey] then
			prvAction[prvMode] = (dopt[prvKey] == nil) and "take" or "sum"
		else
			prvAction[prvMode] = srcNewer and "take" or "keep"
		end
		if prvAction[prvMode] == "take" then
			dopt[prvKey] = so[prvKey]
			-- The older previous period is replaced, also for log types src never had.
			for _, dmodes in pairs(dst.data) do
				if type(dmodes) == "table" and type(dmodes[prvMode]) == "table" then
					dmodes[prvMode].In, dmodes[prvMode].Out = 0, 0
				end
			end
		end
	end

	for logtype, modes in pairs(src.data or {}) do
		local dmodes = dst.data[logtype]
		if type(dmodes) ~= "table" then
			dmodes = {}
			dst.data[logtype] = dmodes
		end
		for mode, amounts in pairs(modes) do
			if type(amounts) == "table" and mode ~= SESSION_MODE then
				local d = dmodes[mode]
				if type(d) ~= "table" then
					d = { In = 0, Out = 0 }
					dmodes[mode] = d
				end
				local action = isPrevious[mode] and prvAction[mode] or "sum"
				if action == "sum" then
					addAmounts(amounts, d)
				elseif action == "take" then
					d.In, d.Out = amounts.In or 0, amounts.Out or 0
				end
			end
		end
	end

	-- Options: the newer record has the current balance and last session.
	if srcNewer then
		if so.totalcash ~= nil then dopt.totalcash = so.totalcash end
		if so.lastsessiondate ~= nil then dopt.lastsessiondate = so.lastsessiondate end
	end
	for k, v in pairs(so) do
		if dopt[k] == nil then dopt[k] = v end
	end

	-- Zone record
	if not zsrc or isEmpty(zsrc.data) then return zdst end
	if not zdst or isEmpty(zdst.data) then return zsrc end
	for mode, byType in pairs(zsrc.data) do
		if mode ~= SESSION_MODE and type(byType) == "table" then
			local action = isPrevious[mode] and prvAction[mode] or "sum"
			if action == "take" then
				zdst.data[mode] = byType
			elseif action == "sum" then
				local dByType = zdst.data[mode]
				if type(dByType) ~= "table" then
					dByType = {}
					zdst.data[mode] = dByType
				end
				for logtype, zones in pairs(byType) do
					if type(zones) == "table" then
						local dZones = dByType[logtype]
						if type(dZones) ~= "table" then
							dZones = {}
							dByType[logtype] = dZones
						end
						addZoneAmounts(zones, dZones)
					end
				end
			end
		end
	end
	return zdst
end

---Moves (or merges) one character from the hidden realm into a realm key.
---@param ctx ACRealmRepairContext
---@param name string
---@param target string
---@return boolean merged True when an existing record was merged, false when moved
local function moveCharacter(ctx, name, target)
	local saveData, zoneDB = ctx.saveData, ctx.zoneDB
	local hiddenChars = saveData[HIDDEN]
	local src = hiddenChars and hiddenChars[name]
	local zHidden = zoneDB and zoneDB[HIDDEN]
	local zsrc = zHidden and zHidden[name]
	local merged = false

	saveData[target] = saveData[target] or {}
	local dst = saveData[target][name]
	if zoneDB then zoneDB[target] = zoneDB[target] or {} end
	local zdst = zoneDB and zoneDB[target][name]

	if src then
		if dst then
			-- Bring both records to the current periods before adding them up.
			ctx.roll(HIDDEN, name, src)
			ctx.roll(target, name, dst)
			local zone = Realm.MergeCharacterData(src, dst, zsrc, zdst, ctx.periods)
			if zoneDB then zoneDB[target][name] = zone end
			merged = true
		else
			saveData[target][name] = src
			if zoneDB and zsrc then zoneDB[target][name] = zsrc end
		end
		hiddenChars[name] = nil
	elseif zoneDB and zsrc and not zdst then
		zoneDB[target][name] = zsrc
	end
	if zHidden then zHidden[name] = nil end
	if zoneDB and isEmpty(zoneDB[target]) then zoneDB[target] = nil end

	if ctx.history and ctx.history.MoveChar then
		local ok, historyMerged = pcall(ctx.history.MoveChar, ctx.history, HIDDEN, name, target)
		merged = merged or (ok and historyMerged == "merged")
	end
	return merged
end

---Merges the records saved under the hidden realm ("") into their realm keys.
---@param ctx ACRealmRepairContext
---@return ACRealmRepairResult
function Realm.RepairHidden(ctx)
	local result = { merged = 0, moved = 0, pending = {} }
	local saveData, zoneDB = ctx.saveData, ctx.zoneDB
	if not saveData then return result end
	local historyChars = ctx.historyChars

	-- Every character known under the hidden realm, in any of the three tables.
	local names = {}
	for name in pairs(saveData[HIDDEN] or {}) do names[name] = true end
	for name in pairs(zoneDB and zoneDB[HIDDEN] or {}) do names[name] = true end
	if historyChars then
		for _, node in pairs(historyChars) do
			if type(node) == "table" and node.server == HIDDEN and node.name and not node.archivedFrom then
				names[node.name] = true
			end
		end
	end

	local ordered = {}
	for name in pairs(names) do ordered[#ordered + 1] = name end
	tsort(ordered)

	for _, name in ipairs(ordered) do
		local target
		if name == ctx.player then
			target = ctx.server
		else
			-- Another character: only when its realm is certain.
			local previous, guidMatch = findPrevious(saveData, historyChars, name, {
				guid = historyGUID(historyChars, HIDDEN, name),
			})
			if #previous == 1 then
				target = previous[1]
			elseif #previous > 1 then
				local only
				for _, server in ipairs(previous) do
					if guidMatch[server] then
						if only then only = nil break end
						only = server
					end
				end
				target = only
			end
		end
		if target and target ~= HIDDEN then
			if moveCharacter(ctx, name, target) then
				result.merged = result.merged + 1
			else
				result.moved = result.moved + 1
			end
		else
			result.pending[#result.pending + 1] = name
		end
	end

	if isEmpty(saveData[HIDDEN]) then saveData[HIDDEN] = nil end
	if zoneDB and isEmpty(zoneDB[HIDDEN]) then zoneDB[HIDDEN] = nil end
	return result
end
