-- Cross-flavor capability layer, loaded first. Retail's path must stay identical: each
-- wrapper resolves to the global retail already used. Detect capabilities, never versions.

local addonName, addonTable = ...

local Compat = {}
addonTable.Compat = Compat

-- [[ FLAVOR IDENTITY ]] IS_MAINLINE is the retail project; IS_RETAIL_UI is retail FrameXML,
-- which Forever also runs. Gate UI on IS_RETAIL_UI, or Forever falls into Classic code.
Compat.PROJECT_ID   = WOW_PROJECT_ID
Compat.IS_MAINLINE  = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
Compat.IS_FOREVER   = (WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
Compat.IS_RETAIL_UI = Compat.IS_MAINLINE or Compat.IS_FOREVER
Compat.IS_CLASSIC   = not Compat.IS_RETAIL_UI

-- Forever's project id, readable on every flavor (Classic clients lack the global).
Compat.FOREVER_PROJECT = WOW_PROJECT_CAMELOT or 18
-- Realm value stored on Forever alts. Never rename: it is part of every Forever alt key.
Compat.FOREVER_REALM = "Forever"

-- [[ FEATURE DETECTION ]] Evaluated once at load.

-- Retail's friends list is a ScrollBox (FriendsListFrame.ScrollBox + DataProvider).
-- MoP Classic's friends list is a HybridScrollFrame (FriendsFrameFriendsScrollFrame).
-- The renderer adapter keys off this flag to choose its draw path.
Compat.HAS_SCROLLBOX = (FriendsListFrame ~= nil and FriendsListFrame.ScrollBox ~= nil)

-- Present on every shipping flavor; the Platform_Menu polyfill is only a safety net.
Compat.HAS_MENU_API = (Menu ~= nil and type(Menu.ModifyMenu) == "function")

-- Classic friends frames are fixed-size art that misaligns when widened, so width is
-- retail UI only. Width saved variables are still stored everywhere (profiles travel).
Compat.CAN_RESIZE_WIDTH = Compat.IS_RETAIL_UI

-- The addon list under the minimap. Not every Classic client has it; LibDBIcon gates the same way.
Compat.HAS_COMPARTMENT = (AddonCompartmentFrame ~= nil)

-- Every legacy global still exists on 12.1, so presence probes can't tell the lists apart.
-- SocialUIControl.IsEnabled() is server-driven and can change mid-session: evaluate live.
-- The friends view is anonymous; reach it via SocialUIFrame's parentKey.
function Compat.IsSocialUIActive()
	if not Compat.IS_RETAIL_UI then return false end
	if type(SocialUIControl) ~= "table" or type(SocialUIControl.IsEnabled) ~= "function" then
		return false
	end
	if not SocialUIControl.IsEnabled() then return false end
	return SocialUIFrame ~= nil and SocialUIFrame.FriendsList ~= nil
end

-- The Social UI friends list content frame (FriendsListSocialViewTemplate), or nil when
-- this client is not running the Social UI. Never cached: SocialUIFrame builds its content
-- frames once at OnLoad, but the ENABLED state above can change under us.
function Compat.GetSocialUIFriendsView()
	if not Compat.IsSocialUIActive() then return nil end
	return SocialUIFrame.FriendsList
end

-- Every visibility guard uses this: FriendsListFrame exists but is hidden on 12.1.
-- IsVisible, not IsShown: the friends view is one of six sibling content frames.
function Compat.IsContactListShown()
	local view = Compat.GetSocialUIFriendsView()
	if view then
		return view:IsVisible()
	end
	return FriendsListFrame ~= nil and FriendsListFrame:IsShown()
end

-- Scopes the unit-menu injection to the contact list (MENU_UNIT_* tags fire elsewhere too).
-- The legacy frame is hidden on 12.1, so IsMouseOver on it alone would always be false.
function Compat.IsContactListMouseOver()
	local view = Compat.GetSocialUIFriendsView()
	if view then
		return view:IsVisible() and view:IsMouseOver()
	end
	return FriendsListFrame ~= nil and FriendsListFrame:IsMouseOver()
end

-- 12.1 "WoW Friend" tier: treat as FRIENDS_BUTTON_TYPE_WOW. No BattleTag, so no alt cache.
function Compat.IsTitleFriend(accountInfo)
	if not accountInfo then return false end
	if type(FriendsListUtil) == "table" and type(FriendsListUtil.IsTitleFriend) == "function" then
		return FriendsListUtil.IsTitleFriend(accountInfo) and true or false
	end
	if type(Enum) == "table" and type(Enum.BattleNetFriendLevel) == "table"
		and Enum.BattleNetFriendLevel.Title ~= nil then
		return accountInfo.friendLevel == Enum.BattleNetFriendLevel.Title
	end
	return false
end

-- Frames the visible list is rendering; FriendsListFrame.ScrollBox off the Social UI.
function Compat.ForEachContactListFrame(callback)
	if type(callback) ~= "function" then return end

	local view = Compat.GetSocialUIFriendsView()
	local scrollBox = view and view.ScrollBox
	if not scrollBox then
		scrollBox = FriendsListFrame and FriendsListFrame.ScrollBox
	end
	if not scrollBox or type(scrollBox.ForEachFrame) ~= "function" then return end

	scrollBox:ForEachFrame(callback)
end

-- [[ CLASSIC LIST OWNERSHIP ]] Writing Blizzard's FriendsFrameFriendsScrollFrame taints
-- FriendsFrame_OnShow, which blocks RaidFrame:Show in combat (CurseForge #55). Off by default
-- until row handlers stop writing Blizzard fields: /run FriendGroups_SavedVars.classic_own_list = true
function Compat.UseOwnClassicList()
	if Compat.HAS_SCROLLBOX then return false end
	if not _G.FriendGroupsClassicList then return false end
	local sv = FriendGroups_SavedVars
	return (sv ~= nil and sv.classic_own_list) and true or false
end

-- Resolved per call, never cached, so a /reload switches paths.
function Compat.GetClassicListFrame()
	if Compat.UseOwnClassicList() then return _G.FriendGroupsClassicList end
	return FriendsFrameFriendsScrollFrame
end

-- Like ForEachContactListFrame plus the Classic HybridScroll pool (shown buttons only).
-- Kept separate so that function's retail-only callers don't widen. Frames come unordered.
function Compat.ForEachListRowFrame(callback)
	if type(callback) ~= "function" then return end

	local view = Compat.GetSocialUIFriendsView()
	local scrollBox = view and view.ScrollBox
	if not scrollBox then
		scrollBox = FriendsListFrame and FriendsListFrame.ScrollBox
	end
	if scrollBox and type(scrollBox.ForEachFrame) == "function" then
		scrollBox:ForEachFrame(callback)
		return
	end

	local scrollFrame = Compat.GetClassicListFrame()
	local buttons = scrollFrame and scrollFrame.buttons
	if type(buttons) ~= "table" then return end
	for i = 1, #buttons do
		local button = buttons[i]
		if button and button:IsShown() then
			callback(button)
		end
	end
end

-- Viewport the rows scroll in (drag edges, indicator parent). May be nil; never cached.
function Compat.GetListScrollContainer()
	local view = Compat.GetSocialUIFriendsView()
	if view and view.ScrollBox then return view.ScrollBox end
	if FriendsListFrame and FriendsListFrame.ScrollBox then return FriendsListFrame.ScrollBox end
	return Compat.GetClassicListFrame()
end

-- Signed fraction of the full range, so edge-scroll takes the same time at any list length.
-- ScrollBox uses its 0..1 percentage; HybridScroll goes through scrollFrame.scrollBar.
function Compat.ScrollListByFraction(fraction)
	if type(fraction) ~= "number" or fraction == 0 then return end

	local view = Compat.GetSocialUIFriendsView()
	local scrollBox = (view and view.ScrollBox) or (FriendsListFrame and FriendsListFrame.ScrollBox)
	if scrollBox and type(scrollBox.GetScrollPercentage) == "function"
		and type(scrollBox.SetScrollPercentage) == "function" then
		local noInterp = ScrollBoxConstants and ScrollBoxConstants.NoScrollInterpolation
		local percent = (scrollBox:GetScrollPercentage() or 0) + fraction
		if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end
		scrollBox:SetScrollPercentage(percent, noInterp)
		return
	end

	local listFrame = Compat.GetClassicListFrame()
	local scrollBar = listFrame and listFrame.scrollBar
	if not scrollBar or type(scrollBar.GetMinMaxValues) ~= "function" then return end
	local minValue, maxValue = scrollBar:GetMinMaxValues()
	if not minValue or not maxValue or maxValue <= minValue then return end
	local value = (scrollBar:GetValue() or minValue) + fraction * (maxValue - minValue)
	if value < minValue then value = minValue elseif value > maxValue then value = maxValue end
	scrollBar:SetValue(value)
end

-- Outer contact window. Decides which native tooltip the alt panel docks to: SocialUIFrame
-- means GameTooltip, FriendsFrame means FriendsTooltip.
function Compat.GetContactListAnchor()
	if Compat.IsSocialUIActive() then
		return SocialUIFrame
	end
	return FriendsFrame
end

-- [[ PLATFORM PRIMITIVES ]]

-- C_PartyInfo.InviteUnit, falling back to the legacy InviteUnit global.
function Compat.InviteUnit(name)
	if type(name) ~= "string" or name == "" then return end
	if C_PartyInfo and type(C_PartyInfo.InviteUnit) == "function" then
		C_PartyInfo.InviteUnit(name)
	elseif type(InviteUnit) == "function" then
		InviteUnit(name)
	end
end

-- [[ FRIEND NOTE PRIMITIVES ]] The Battle.net note stores the note grammar; it is shared by
-- every flavor and the Battle.net app.

-- 127 BYTES, not characters: a server truncation mid-UTF-8 would corrupt the tag.
Compat.BNET_NOTE_MAXBYTES = 127

-- Nickname length cap, in codepoints (matches the Set Nickname edit box maxLetters
-- and Sync.lua's envelope sanitiser).
Compat.NICKNAME_MAXLEN = 20

-- Resolved once at load; with no writer, CanSetBNetNote() is false and callers show a message.
local FG_SetNoteFunc
if C_BattleNet and type(C_BattleNet.SetFriendNote) == "function" then
	FG_SetNoteFunc = C_BattleNet.SetFriendNote
elseif type(BNSetFriendNote) == "function" then
	FG_SetNoteFunc = BNSetFriendNote
end

-- True when this client can write Battle.net friend notes at all.
function Compat.CanSetBNetNote()
	return FG_SetNoteFunc ~= nil
end

-- Write a Battle.net friend note. Returns true when the write was actually issued.
-- Length is the CALLER's responsibility (see Compat.BNET_NOTE_MAXBYTES) so it can
-- report a meaningful refusal; this only guards the types.
function Compat.SetBNetNote(bnetIDAccount, note)
	if not FG_SetNoteFunc then return false end
	if type(bnetIDAccount) ~= "number" or type(note) ~= "string" then return false end
	FG_SetNoteFunc(bnetIDAccount, note)
	return true
end

-- Returns inviteID, accountName. C_BattleNet.GetFriendInviteInfo is retail/Forever only;
-- the Classic clients still have just the BNGetFriendInviteInfo global.
function Compat.GetFriendInviteInfo(inviteIndex)
	if type(C_BattleNet.GetFriendInviteInfo) == "function" then
		local info = C_BattleNet.GetFriendInviteInfo(inviteIndex)
		if info then return info.inviteID, info.accountName end
		return
	end
	return BNGetFriendInviteInfo(inviteIndex)
end

-- BNGetNumFriends is the documented call on every flavor; C_BattleNet.GetFriendNum doesn't
-- exist on live clients. Only the first return (total) is used.
function Compat.GetBNetFriendNum()
	local total
	if C_BattleNet and type(C_BattleNet.GetFriendNum) == "function" then
		total = C_BattleNet.GetFriendNum()
	end
	if type(total) ~= "number" and type(BNGetNumFriends) == "function" then
		total = BNGetNumFriends()
	end
	return (type(total) == "number") and total or 0
end

-- Truncate to a codepoint count without ever splitting a UTF-8 sequence.
function Compat.Utf8Trunc(s, maxChars)
	if type(s) ~= "string" then return "" end
	local i, chars, len = 1, 0, #s
	while i <= len and chars < maxChars do
		local b = s:byte(i)
		local step = (b < 0x80) and 1 or (b < 0xE0) and 2 or (b < 0xF0) and 3 or 4
		i = i + step
		chars = chars + 1
	end
	return s:sub(1, i - 1)
end

-- Strips chars that break the note grammar: '#' starts groups, '<>' match guilds, '[]@' are
-- tag delimiters, '|' is a UI escape, %c control. Applied on read too (notes are hand-editable).
function Compat.SanitizeNickname(s)
	if type(s) ~= "string" then return "" end
	s = s:gsub("[#<>@%[%]|%c]", "")
	s = s:gsub("%s+", " ")
	s = s:match("^%s*(.-)%s*$") or ""
	return Compat.Utf8Trunc(s, Compat.NICKNAME_MAXLEN)
end

-- RegisterEvent errors on unknown events and would abort file load: validate each name.
function Compat.RegisterEvents(frame, events)
	if not frame or type(events) ~= "table" then return end
	local validate = (C_EventUtils and type(C_EventUtils.IsEventValid) == "function")
		and C_EventUtils.IsEventValid or nil
	for i = 1, #events do
		local event = events[i]
		if type(event) == "string" and event ~= "" then
			if validate then
				if validate(event) then
					frame:RegisterEvent(event)
				end
			else
				pcall(frame.RegisterEvent, frame, event)
			end
		end
	end
end

-- [[ C_BattleNet.SearchFriends ]] Protected on live 12.1 and Forever; pcall can't stop
-- ADDON_ACTION_FORBIDDEN, so the event latches it off. Forever starts latched.
local searchFriendsForbidden = Compat.IS_FOREVER == true
local searchFriendsInFlight = false

local searchFriendsWatcher = CreateFrame("Frame")
Compat.RegisterEvents(searchFriendsWatcher, { "ADDON_ACTION_FORBIDDEN" })
searchFriendsWatcher:SetScript("OnEvent", function(_, _, blamedAddon)
	if blamedAddon ~= addonName then return end
	if not searchFriendsInFlight then return end
	searchFriendsForbidden = true
end)

-- Reported by /fg match, so "the name set is empty" can be told apart from "we are not
-- allowed to ask".
function Compat.IsSearchFriendsForbidden()
	return searchFriendsForbidden
end

-- Returns the friend-index array on success, or nil plus a short reason for /fg match.
-- Every caller must route through here: a direct call anywhere else re-opens the error.
function Compat.SearchFriends(searchInfo)
	if searchFriendsForbidden then return nil, "forbidden" end
	if type(searchInfo) ~= "table" then return nil, "noinfo" end
	if type(C_BattleNet) ~= "table" or type(C_BattleNet.SearchFriends) ~= "function" then
		return nil, "noapi"
	end

	searchFriendsInFlight = true
	local ok, result = pcall(C_BattleNet.SearchFriends, searchInfo)
	searchFriendsInFlight = false

	-- Tested BEFORE the result: a forbidden call returns quietly, so the flag set by the
	-- handler above is the only thing that distinguishes it from an empty match.
	if searchFriendsForbidden then return nil, "forbidden" end
	if not ok then return nil, "threw" end
	if type(result) ~= "table" then return nil, "badresult" end
	return result, "ok"
end

-- 12.0 secret values read as absent -- never inspect their contents.
local function FG_Plain(v)
	if v ~= nil and issecretvalue and issecretvalue(v) then return nil end
	return v
end

-- [[ FOREVER RULESETS ]] Forever is realmless: each ruleset per region is one megaserver of
-- hidden shards named "CAMWOW <US1|US2|AU1|EU..> Realm <n> <PVE|PVP|RP|RPPVP>". Players see the ruleset.
local FOREVER_RULESET_CODES = {
	PVE = "NORMAL", NORMAL = "NORMAL", PVP = "PVP", RP = "RP", RPPVP = "RPPVP", RPVP = "RPPVP",
}

local FOREVER_REGIONS = {
	AU = { icon = "FlagAU.tga", region = "Oceania", forever = true },
	CN = { icon = "FlagCN.tga", region = "China", forever = true },
	EU = { icon = "FlagGB.tga", region = "EU", forever = true },
	KR = { icon = "FlagKR.tga", region = "Korea", forever = true },
	TW = { icon = "FlagTW.tga", region = "Taiwan", forever = true },
	US = { icon = "FlagUS.tga", region = "US", forever = true },
}

-- Battle.net regionID to Forever region. Region 1 holds both US and AU shards, so it is absent.
local FOREVER_REGION_BY_BNET = { [2] = "KR", [3] = "EU", [4] = "TW", [5] = "CN" }

-- realmID -> { ruleset, region }. Retail gets a Forever friend's realmID but never its name.
-- From /fgprobe realms on live Forever, 2026-11-05; data in FriendGroups-Forever-Port-Plan.md s11.
local FOREVER_SHARDS = {
	[6794] = { "NORMAL", "US" }, [6796] = { "NORMAL", "US" }, [6797] = { "NORMAL", "AU" },
	[6798] = { "PVP", "US" },    [6800] = { "PVP", "US" },    [6801] = { "PVP", "AU" },
	[6921] = { "NORMAL", "US" }, [6922] = { "PVP", "US" },    [6923] = { "NORMAL", "US" },
	[6924] = { "PVP", "US" },    [6925] = { "NORMAL", "US" }, [6926] = { "PVP", "US" },
	[6927] = { "RPPVP", "US" },  [6929] = { "NORMAL", "US" }, [6930] = { "PVP", "US" },
	[6931] = { "NORMAL", "US" }, [6932] = { "PVP", "US" },    [6933] = { "NORMAL", "US" },
	[6934] = { "PVP", "US" },    [6936] = { "RPPVP", "US" },  [7055] = { "RP", "US" },
}

-- Bundled 32 px Forever logo: Blizzard's own WoWF title icon is a blank silhouette on Forever.
Compat.FOREVER_ICON = "Interface\\AddOns\\FriendGroups\\Textures\\forever"

local function FG_Flat(s)
	return (s:gsub("[%s%p]", "")):upper()
end

-- Shard name to ruleset code and region ("US"/"AU"/"EU"), or nil when not a Forever shard.
function Compat.ParseForeverShard(realm)
	realm = FG_Plain(realm)
	if type(realm) ~= "string" or realm == "" then return nil end
	local region, kind = FG_Flat(realm):match("^CAMWOW(%a%a)%d*REALM%d+(%a+)$")
	if not region then return nil end
	return FOREVER_RULESET_CODES[kind] or kind, region
end

-- A ruleset word as Blizzard or our locale prints it ("PvP", "JcJ") to its code; other
-- words are returned unchanged so they still display.
function Compat.ForeverRulesetCode(word)
	word = FG_Plain(word)
	if type(word) ~= "string" or word == "" then return nil end
	local flat = FG_Flat(word)
	if FOREVER_RULESET_CODES[flat] then return FOREVER_RULESET_CODES[flat] end
	local L = addonTable.L
	if L then
		for _, code in ipairs({ "NORMAL", "PVP", "RP", "RPPVP" }) do
			local label = rawget(L, "RULESET_" .. code)
			if label and FG_Flat(label) == flat then return code end
		end
	end
	return word
end

-- Retail rich presence for a Forever friend is "<Forever> - <ruleset> - <zone>".
function Compat.ParseForeverPresence(richPresence)
	richPresence = FG_Plain(richPresence)
	if type(richPresence) ~= "string" then return nil end
	local ruleset, zone = richPresence:match("^.-%s%-%s(.-)%s%-%s(.+)$")
	if not ruleset then ruleset = richPresence:match("^.-%s%-%s(.+)$") end
	if not ruleset then return nil end
	return Compat.ForeverRulesetCode(ruleset), zone
end

function Compat.IsForeverGame(gameInfo)
	if not gameInfo then return false end
	-- Blizzard's own product marker; reduced sessions carry it with project 0.
	if FG_Plain(gameInfo.subIcon) == "WoWF" then return true end
	local pid = FG_Plain(gameInfo.wowProjectID)
	if type(pid) == "number" and pid > 0 then return pid == Compat.FOREVER_PROJECT end
	if Compat.ParseForeverShard(gameInfo.realmName) then return true end
	-- Presence-reduced sessions carry only "Forever - <ruleset> - <zone>".
	local presence = FG_Plain(gameInfo.richPresence)
	local product = type(presence) == "string" and presence:match("^(.-)%s%-%s")
	if not product then return false end
	local L = addonTable.L
	return product == Compat.FOREVER_REALM or (L ~= nil and product == rawget(L, "FOREVER"))
end

function Compat.ForeverRulesetLabel(code)
	if type(code) ~= "string" or code == "" then return nil end
	local L = addonTable.L
	return (L and rawget(L, "RULESET_" .. code)) or code
end

-- Realm-database-shaped entry (icon/region) for a Forever region code, or nil.
function Compat.ForeverRealmEntry(region)
	return region and FOREVER_REGIONS[region] or nil
end

-- Ruleset code, region code and zone for a Forever session, from whichever source this
-- client has: shard name (Forever), realmID table (retail), or rich presence (reduced).
function Compat.ForeverInfo(gameInfo)
	if not gameInfo then return nil end
	local ruleset, region = Compat.ParseForeverShard(gameInfo.realmName)
	if not ruleset then
		local shard = FOREVER_SHARDS[FG_Plain(gameInfo.realmID)]
		if shard then ruleset, region = shard[1], shard[2] end
	end
	region = region or FOREVER_REGION_BY_BNET[FG_Plain(gameInfo.regionID)]
	local presenceRuleset, presenceZone = Compat.ParseForeverPresence(gameInfo.richPresence)
	local zone = FG_Plain(gameInfo.areaName)
	if type(zone) ~= "string" or zone == "" then zone = presenceZone end
	return ruleset or presenceRuleset, region, zone
end

-- "Forever Normal", or "Forever" when the ruleset is unknown.
function Compat.ForeverLabel(ruleset)
	local L = addonTable.L
	local label = (L and rawget(L, "FOREVER")) or Compat.FOREVER_REALM
	local rulesetLabel = Compat.ForeverRulesetLabel(ruleset)
	return rulesetLabel and (label .. " " .. rulesetLabel) or label
end

-- The row's location for a Forever friend on every client: "Zone - Forever Normal".
function Compat.ForeverLocation(gameInfo, showRealm)
	local ruleset, _, zone = Compat.ForeverInfo(gameInfo)
	if not showRealm then return zone end
	if not zone then return Compat.ForeverLabel(ruleset) end
	return zone .. " - " .. Compat.ForeverLabel(ruleset)
end

-- What a realm name should read as: the ruleset for a Forever shard, else the name.
function Compat.DisplayRealmName(realm)
	local code = Compat.ParseForeverShard(realm)
	if code then return Compat.ForeverRulesetLabel(code) end
	return realm
end

-- [[ FRIEND ACCOUNT FETCH ]] A friend on two games at once reports one game account; prefer the
-- one on our own client so the row, search and Blizzard's invite button describe one session.
function Compat.GetFriendAccountInfo(friendIndex)
	local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex)
	local current = accountInfo and accountInfo.gameAccountInfo
	if not current or FG_Plain(current.wowProjectID) == WOW_PROJECT_ID then return accountInfo end
	if type(C_BattleNet.GetFriendNumGameAccounts) ~= "function"
		or type(C_BattleNet.GetFriendGameAccountInfo) ~= "function" then
		return accountInfo
	end
	local count = C_BattleNet.GetFriendNumGameAccounts(friendIndex)
	if type(count) ~= "number" or count < 2 then return accountInfo end
	for i = 1, count do
		local other = C_BattleNet.GetFriendGameAccountInfo(friendIndex, i)
		if other and FG_Plain(other.isOnline) and FG_Plain(other.clientProgram) == (BNET_CLIENT_WOW or "WoW")
			and FG_Plain(other.wowProjectID) == WOW_PROJECT_ID then
			accountInfo.gameAccountInfo = other
			break
		end
	end
	return accountInfo
end

-- Blizzard's own switch for the Party Sync UI; Forever hard-codes it off.
function Compat.IsPartySyncAvailable()
	if type(QuestMapFrameUtils) == "table" and type(QuestMapFrameUtils.IsPartySyncEnabled) == "function" then
		return QuestMapFrameUtils:IsPartySyncEnabled() and true or false
	end
	return true
end

-- Same project as us (can group). Compare with WOW_PROJECT_ID, never MAINLINE. A reported
-- project is trusted first; else realm fields, which the API fills only for same-project.
function Compat.IsSameProject(gameInfo)
	if not gameInfo then return false end
	local pid = FG_Plain(gameInfo.wowProjectID)
	if type(pid) == "number" and pid > 0 then
		return pid == WOW_PROJECT_ID
	end
	if Compat.IsForeverGame(gameInfo) then return Compat.IS_FOREVER end
	local realmID = FG_Plain(gameInfo.realmID)
	local realmName = FG_Plain(gameInfo.realmName)
	if (type(realmID) == "number" and realmID > 0)
		or (type(realmName) == "string" and realmName ~= "") then
		return true
	end
	-- 12.0.7 often publishes only rich presence. On retail a non-classic realm in that text
	-- proves mainline; on Classic a classic realm is ambiguous across projects.
	if Compat.IS_MAINLINE then
		local isClassic, source = Compat.ResolveFriendFlavor(gameInfo)
		if source == "realm" and isClassic == false then
			return true
		end
	end
	return false
end

-- Retail vs classic for a WoW friend, plus the deciding source. Ladder: wowProjectID, then
-- realm database tag (exact per region), then API realm fields (ours), else retail.
function Compat.ResolveFriendFlavor(gameInfo)
	if not gameInfo or FG_Plain(gameInfo.clientProgram) ~= (BNET_CLIENT_WOW or "WoW") then
		return nil, "not-wow"
	end
	local mainline = WOW_PROJECT_MAINLINE or 1
	-- Forever is not Classic: no green tint, own icon via subIcon.
	if Compat.IsForeverGame(gameInfo) then return false, "forever" end
	local pid = FG_Plain(gameInfo.wowProjectID)
	if type(pid) == "number" and pid > 0 then
		return (pid ~= mainline), "projectID"
	end
	local entry = _G.FriendGroups_GetRealmEntry and _G.FriendGroups_GetRealmEntry(gameInfo)
	if entry then
		return (entry.classic == true), "realm"
	end
	local realmID = FG_Plain(gameInfo.realmID)
	local realmName = FG_Plain(gameInfo.realmName)
	if (type(realmID) == "number" and realmID > 0) or (type(realmName) == "string" and realmName ~= "") then
		return Compat.IS_CLASSIC, "same-project"
	end
	return false, "default"
end

-- Highest attainable level on THIS client, read live so it never goes stale.
local HOST_MAX_LEVEL = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
	or (GetMaxLevelForExpansionLevel and GetExpansionLevel and GetMaxLevelForExpansionLevel(GetExpansionLevel()))
	or 80

-- Caps for OTHER projects; the host's own entry is overwritten from the live API.
-- Bump when an expansion raises a cap (last audit 2026-07).
local PROJECT_MAX_LEVEL = {
	[WOW_PROJECT_MAINLINE or 1] = 90,
	[WOW_PROJECT_CLASSIC or 2] = 60,
	[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5] = 70,
	[WOW_PROJECT_MISTS_CLASSIC or 19] = 90,
	[WOW_PROJECT_CAMELOT or 18] = 60,
}
PROJECT_MAX_LEVEL[WOW_PROJECT_ID] = HOST_MAX_LEVEL

-- Fail-open: anything unresolvable shows the level. nil gameInfo = character friend (ours).
function Compat.IsMaxLevel(gameInfo, level)
	level = tonumber(FG_Plain(level))
	if not level or level <= 0 then return false end
	if not gameInfo then
		return level == HOST_MAX_LEVEL
	end
	local pid = FG_Plain(gameInfo.wowProjectID)
	if type(pid) == "number" and pid > 0 then
		return level == PROJECT_MAX_LEVEL[pid]
	end
	-- No reported project. A realm-database hit that says "retail" is exact
	-- (mainline is a single project); a "classic" hit is ambiguous across the
	-- Era/BC/MoP caps, so it falls through to the same-project check instead.
	local isClassic, source = Compat.ResolveFriendFlavor(gameInfo)
	if source == "realm" and isClassic == false then
		return level == PROJECT_MAX_LEVEL[WOW_PROJECT_MAINLINE or 1]
	end
	if Compat.IsSameProject(gameInfo) then
		return level == HOST_MAX_LEVEL
	end
	return false
end

-- Classic-family friends' WoW icon is desaturated and tinted monk green; retail keeps gold.
function Compat.TintGameIcon(icon, gameInfo)
	if not icon then return end
	local classicFriend = Compat.ResolveFriendFlavor(gameInfo)
	if classicFriend then
		if icon.SetDesaturated then icon:SetDesaturated(true) end
		local monk = RAID_CLASS_COLORS and RAID_CLASS_COLORS.MONK
		if monk then
			icon:SetVertexColor(monk.r, monk.g, monk.b)
		else
			icon:SetVertexColor(0.00, 1.00, 0.59)
		end
	else
		if icon.SetDesaturated then icon:SetDesaturated(false) end
		icon:SetVertexColor(1, 1, 1)
	end
end

-- One icon path for list rows and the Online by Game tooltip, so the two always match.
function Compat.SetGameIcon(icon, gameInfo)
	local client = gameInfo and gameInfo.clientProgram
	if Compat.IsForeverGame(gameInfo) then
		icon:SetTexture(Compat.FOREVER_ICON)
	elseif C_Texture and C_Texture.SetTitleIconTexture then
		C_Texture.SetTitleIconTexture(icon, client, Enum.TitleIconVersion.Medium, gameInfo and gameInfo.subIcon)
	elseif BNet_GetClientTexture then
		icon:SetTexture(BNet_GetClientTexture(client))
	end
	Compat.TintGameIcon(icon, gameInfo)
end

-- [[ ONLINE BY GAME ]] WoW splits by project; an unprovable Classic friend goes to
-- "WoW:classic", never a guess.
local WOW_PROJECT_LABEL_KEYS = {
	[WOW_PROJECT_MAINLINE or 1] = "GAME_WOW",
	[WOW_PROJECT_CLASSIC or 2] = "GAME_WOW_ERA",
	[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5] = "GAME_WOW_TBC",
	[WOW_PROJECT_MISTS_CLASSIC or 19] = "GAME_WOW_MISTS",
	[WOW_PROJECT_CAMELOT or 18] = "GAME_WOW_FOREVER",
}

-- Other games show their logo only: Blizzard has no client-code-to-name API.
local GAME_LABEL_KEYS = { App = "GAME_BNET_APP", ["?"] = "GAME_UNKNOWN" }

-- gameInfo nil means a WoW character friend, who is on our project by definition.
function Compat.GameBucket(gameInfo)
	if not gameInfo then return "WoW:" .. WOW_PROJECT_ID end
	local client = FG_Plain(gameInfo.clientProgram)
	if type(client) ~= "string" or client == "" then return "?" end
	if client == "App" or client == "BSAp" then return "App" end
	if client ~= (BNET_CLIENT_WOW or "WoW") then return client end
	if Compat.IsForeverGame(gameInfo) then return "WoW:" .. Compat.FOREVER_PROJECT end
	local pid = FG_Plain(gameInfo.wowProjectID)
	if type(pid) == "number" and pid > 0 then return "WoW:" .. pid end
	if Compat.IsSameProject(gameInfo) then return "WoW:" .. WOW_PROJECT_ID end
	if Compat.ResolveFriendFlavor(gameInfo) then return "WoW:classic" end
	return "WoW:" .. (WOW_PROJECT_MAINLINE or 1)
end

-- nil for a non-WoW game: the tooltip shows its logo alone.
function Compat.GameLabel(bucket)
	local key
	local pid = bucket:match("^WoW:(%d+)$")
	if pid then
		key = WOW_PROJECT_LABEL_KEYS[tonumber(pid)] or "GAME_WOW_CLASSIC"
	elseif bucket == "WoW:classic" then
		key = "GAME_WOW_CLASSIC"
	else
		key = GAME_LABEL_KEYS[bucket]
		if not key then return nil end
	end
	local L = addonTable.L
	return (L and rawget(L, key)) or key
end

-- Our own WoW first, other WoW versions, other games, then the app and unknown last.
function Compat.GameBucketRank(bucket)
	if bucket == "WoW:" .. WOW_PROJECT_ID then return 0 end
	if bucket:find("^WoW:") then return 1 end
	if bucket == "App" then return 3 end
	if bucket == "?" then return 4 end
	return 2
end

-- Square class atlas; Platform_Render overrides this on Classic (no classicon-* atlas).
function Compat.ClassIconMarkup(engClass, size)
	if not engClass or engClass == "" then return "" end
	size = size or 16
	local atlas = GetClassAtlas and GetClassAtlas(engClass)
	if atlas then
		return "|A:" .. atlas .. ":" .. size .. ":" .. size .. "|a"
	end
	return "|A:classicon-" .. string.lower(engClass) .. ":" .. size .. ":" .. size .. "|a"
end

-- [[ CLASS FALLBACK ]] Classes an older client lacks (Forever, Classic: DK, Monk, DH, Evoker),
-- resolved privately. Never write them into RAID_CLASS_COLORS or LOCALIZED_CLASS_NAMES_*:
-- Blizzard iterates those, and addon-written entries would taint it.
local FG_EXTRA_CLASSES = {
	DEATHKNIGHT = { id = 6,  key = "CLASS_DEATHKNIGHT", en = "Death Knight", r = 0.77, g = 0.12, b = 0.23 },
	MONK        = { id = 10, key = "CLASS_MONK",        en = "Monk",         r = 0.00, g = 1.00, b = 0.59 },
	DEMONHUNTER = { id = 12, key = "CLASS_DEMONHUNTER", en = "Demon Hunter", r = 0.64, g = 0.19, b = 0.79 },
	EVOKER      = { id = 13, key = "CLASS_EVOKER",      en = "Evoker",       r = 0.20, g = 0.58, b = 0.50 },
}

local function FG_ExtraClassName(info)
	if C_CreatureInfo and type(C_CreatureInfo.GetClassInfo) == "function" then
		local classInfo = C_CreatureInfo.GetClassInfo(info.id)
		if classInfo and type(classInfo.className) == "string" and classInfo.className ~= "" then
			return classInfo.className
		end
	end
	local L = addonTable.L
	return L and rawget(L, info.key) or nil
end

-- English token ("MONK") from a token or a localized class name, or nil.
function Compat.ClassToken(name)
	name = FG_Plain(name)
	if type(name) ~= "string" or name == "" then return nil end
	if (RAID_CLASS_COLORS and RAID_CLASS_COLORS[name]) or FG_EXTRA_CLASSES[name] then return name end
	for _, names in ipairs({ LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE }) do
		if type(names) == "table" then
			for token, localized in pairs(names) do
				if localized == name then return token end
			end
		end
	end
	for token, info in pairs(FG_EXTRA_CLASSES) do
		if name == info.en or name == FG_ExtraClassName(info) then return token end
	end
	return nil
end

-- Color table ({r,g,b}) for a token, including the private fallback classes.
function Compat.ClassColor(token)
	if type(token) ~= "string" then return nil end
	if RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then return RAID_CLASS_COLORS[token] end
	local info = FG_EXTRA_CLASSES[token]
	if not info then return nil end
	info.color = info.color or (CreateColor and CreateColor(info.r, info.g, info.b)) or { r = info.r, g = info.g, b = info.b }
	return info.color
end
