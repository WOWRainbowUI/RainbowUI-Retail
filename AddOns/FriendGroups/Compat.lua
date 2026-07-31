--[[
	FriendGroups - Compat.lua
	============================================================================
	Cross-flavor capability layer. Loaded FIRST (before FriendGroups.lua) so that
	every platform-divergent primitive is resolved exactly once, here, and the
	rest of the addon calls through addonTable.Compat instead of branching inline.

	Design rule (retail is canonical):
	  - Retail's execution path must be byte-identical to its pre-unification
	    behavior. On retail every wrapper resolves to the same global the addon
	    already used, so nothing changes.
	  - Divergence is expressed as CAPABILITY detection (does the API exist?),
	    never as version-number guessing, so the layer degrades gracefully.

	API compliance:
	  - Retail   : WoW Midnight 12.0.7 (Interface 120007)
	  - Classic  : MoP Classic 5.5.4  (Interface 50504)
	               BC Anniversary 2.5.6 (Interface 20506)
	               Classic Era 1.15.x (FriendGroups_Vanilla.toc)
	  Only documented globals are referenced, each guarded before use.
]] --

local addonName, addonTable = ...

local Compat = {}
addonTable.Compat = Compat

-- ============================================================================
-- [[ FLAVOR IDENTITY ]]
-- WOW_PROJECT_ID and WOW_PROJECT_MAINLINE are documented globals present on
-- every flavor. IS_MAINLINE is the single source of truth for "this is retail".
-- ============================================================================
Compat.PROJECT_ID  = WOW_PROJECT_ID
Compat.IS_MAINLINE = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
Compat.IS_CLASSIC  = not Compat.IS_MAINLINE

-- ============================================================================
-- [[ FEATURE DETECTION ]]
-- Presence checks against the live client, evaluated once at load.
-- ============================================================================

-- Retail's friends list is a ScrollBox (FriendsListFrame.ScrollBox + DataProvider).
-- MoP Classic's friends list is a HybridScrollFrame (FriendsFrameFriendsScrollFrame).
-- The renderer adapter keys off this flag to choose its draw path.
Compat.HAS_SCROLLBOX = (FriendsListFrame ~= nil and FriendsListFrame.ScrollBox ~= nil)

-- Retail 11.0+ context-menu system (Menu.ModifyMenu / MenuUtil). Probed 2026-07:
-- present AND live on every shipping flavor (retail 12.0.7, MoP 5.5.4, BC
-- Anniversary 2.5.6 -- the MENU_UNIT_* friend tags fire on all of them), so the
-- modern injection path is what actually runs everywhere. The UIDropDownMenu
-- polyfill in Platform_Menu.lua is retained purely as a safety net for a client
-- that lacks the API.
Compat.HAS_MENU_API = (Menu ~= nil and type(Menu.ModifyMenu) == "function")

-- Contact-list WIDTH resizing (Narrow / Normal / Wide). Retail's FriendsFrame and
-- FriendsListFrame redraw cleanly when grown horizontally; MoP Classic, BC Anniversary
-- and Era draw the friends frame from fixed-size art with a HybridScroll button
-- template sized to it, where the same SetWidth leaves border and rows misaligned.
-- No API reports "does this frame's art scale", so this is the one capability derived
-- from the documented flavor identity above (WOW_PROJECT_ID) rather than from a
-- presence probe -- it is a layout fact, not a missing function.
--
-- The width saved variables (wide_list / width_normal) are still STORED on every
-- flavor: settings profiles travel between flavors as Sync.lua strings, and a profile
-- that passes through a Classic character must carry a retail user's width choice back
-- out intact. They are simply never CONSUMED where this is false -- see
-- FriendGroups_GetExtraWidth / FriendGroups_IsWideList in FriendGroups.lua.
Compat.CAN_RESIZE_WIDTH = Compat.IS_MAINLINE

-- ============================================================================
-- [[ PLATFORM PRIMITIVES ]]
-- Small, universally-needed wrappers. Heavier render/menu adapters live in
-- their own Platform_* files; only leaf primitives that both flavors share
-- (with a differing implementation) belong here.
-- ============================================================================

-- Invite a unit to the player's party/raid.
-- C_PartyInfo.InviteUnit is the documented modern entry point and is present on
-- both retail 12.0.7 and MoP Classic 5.5.4; the legacy global InviteUnit is kept
-- as a defensive fallback so a missing namespace can never hard-error.
function Compat.InviteUnit(name)
	if type(name) ~= "string" or name == "" then return end
	if C_PartyInfo and type(C_PartyInfo.InviteUnit) == "function" then
		C_PartyInfo.InviteUnit(name)
	elseif type(InviteUnit) == "function" then
		InviteUnit(name)
	end
end

-- ============================================================================
-- [[ FRIEND NOTE PRIMITIVES ]]
-- The Battle.net friend note is the addon's persistent store for the note DSL
-- (see FriendGroups.lua "NOTE GRAMMAR"). It lives on the Battle.net account, so
-- it is shared by every flavor and is visible in the Battle.net desktop/mobile
-- client -- which is precisely why nicknames are stored there.
-- ============================================================================

-- Blizzard's own SET_BNFRIENDNOTE dialog caps the edit box at 127 letters with
-- countInvisibleLetters = true (FrameXML StaticPopup.lua). The SERVER-side limit is
-- not documented anywhere, so 127 is treated as the ceiling, and it is measured in
-- BYTES rather than codepoints: a 20-character Cyrillic or CJK nickname is up to 80
-- bytes, and a server-side truncation that lands mid-UTF-8 would corrupt the tag and
-- then be read back as garbage. Refusing slightly early is cosmetic; writing a note
-- that gets truncated is not.
Compat.BNET_NOTE_MAXBYTES = 127

-- Nickname length cap, in codepoints (matches the Set Nickname edit box maxLetters
-- and Sync.lua's envelope sanitiser).
Compat.NICKNAME_MAXLEN = 20

-- Note writer, resolved ONCE at load. C_BattleNet.SetFriendNote is the modern entry
-- point; BNSetFriendNote is the legacy global (documented since 3.3.5 / 1.13.2) and is
-- the path the Classic clients take. Neither is assumed to exist: if the running client
-- exposes no writer at all, Compat.CanSetBNetNote() reports false and every caller
-- degrades to a localized message instead of erroring at click time.
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

-- Total number of Battle.net friends.
--
-- BNGetNumFriends is the DOCUMENTED entry point (added 3.3.5 / 1.13.2) and is present
-- on every shipping flavor: retail 12.x, MoP Classic 5.5.4, BC Anniversary 2.5.6 and
-- Classic Era 1.15.x. C_BattleNet.GetFriendNum is NOT documented and does not exist on
-- the live clients -- every call site in this addon that appears to use it actually
-- runs its BNGetNumFriends fallback. Probing the namespace first costs nothing and
-- picks up a future addition automatically; the fallback is what does the work today.
--
-- BNGetNumFriends returns four values (total, online, favorite, favoriteOnline); only
-- the first is taken here.
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

-- Make an arbitrary string safe to live inside an @[...] tag in a friend note.
-- Every character stripped here would otherwise break a DIFFERENT part of the note
-- grammar, so none of these bans are cosmetic:
--   #     -- FriendGroups_GetPlayerGroups treats everything from the first '#' as
--            groups, regardless of nesting, so a '#' inside the tag invents a group.
--   < >   -- the guild scanner is a bare gmatch("<([^>]+)>") over the whole note, so
--            "@[Bob <the> Builder]" would invent a guild called "the".
--   [ ] @ -- tag delimiters; banning them keeps "does this note already carry a tag"
--            trivially decidable and the writer idempotent.
--   |     -- UI escape sequences; the note is rendered verbatim into a FontString.
--   %c    -- control characters.
-- Applied on READ as well as on write: since 13.0.1 a nickname can be typed by hand
-- into the note from the Battle.net app, so untrusted text reaches the parser.
function Compat.SanitizeNickname(s)
	if type(s) ~= "string" then return "" end
	s = s:gsub("[#<>@%[%]|%c]", "")
	s = s:gsub("%s+", " ")
	s = s:match("^%s*(.-)%s*$") or ""
	return Compat.Utf8Trunc(s, Compat.NICKNAME_MAXLEN)
end

-- Register a list of events on a frame, skipping any the running client does not
-- recognise. RegisterEvent raises a Lua error on an unknown event, so a retail-era
-- event absent on Classic (e.g. Party Sync's QUEST_SESSION_CREATED) would otherwise
-- abort file load. No assumption is made about which events exist: each name is
-- validated where the client exposes C_EventUtils.IsEventValid, and defensively
-- guarded with pcall otherwise, so exactly the supported subset is registered.
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

-- 12.0 secret values read as absent -- never inspect their contents.
local function FG_Plain(v)
	if v ~= nil and issecretvalue and issecretvalue(v) then return nil end
	return v
end

-- True when the given Battle.net game account is on OUR project.
-- This is the correct gate for "can I invite / group with this WoW friend": you
-- can only party with players on the same project, so both flavors must compare
-- against WOW_PROJECT_ID (self), never a hardcoded WOW_PROJECT_MAINLINE.
-- Takes the friend's gameAccountInfo. Classic clients omit wowProjectID for
-- same-project friends, so a reported project is trusted first, and otherwise the
-- realm fields decide: the API only populates realmName/realmID for SAME-project
-- friends (cross-project realms ride inside rich presence text instead).
function Compat.IsSameProject(gameInfo)
	if not gameInfo then return false end
	local pid = FG_Plain(gameInfo.wowProjectID)
	if type(pid) == "number" and pid > 0 then
		return pid == WOW_PROJECT_ID
	end
	local realmID = FG_Plain(gameInfo.realmID)
	local realmName = FG_Plain(gameInfo.realmName)
	if (type(realmID) == "number" and realmID > 0)
		or (type(realmName) == "string" and realmName ~= "") then
		return true
	end
	-- Rescue tier (12.0.7 presence reduction, observed 2026-07): most friends'
	-- sessions now publish NO structured fields at all -- wowProjectID, realmID and
	-- realmName are nil -- leaving only the rich-presence display text. On a retail
	-- host, a rich-presence realm that resolves in the realm database WITHOUT a
	-- classic tag proves the friend is on mainline (the one project retail realms
	-- belong to), so same-project is provable from the text alone. Classic hosts
	-- keep the strict behavior: a classic-tagged realm is ambiguous across
	-- Era/BC/MoP, which are all different projects.
	if Compat.IS_MAINLINE then
		local isClassic, source = Compat.ResolveFriendFlavor(gameInfo)
		if source == "realm" and isClassic == false then
			return true
		end
	end
	return false
end

-- Resolve which FLAVOR (retail vs classic-family) a WoW friend is playing.
-- Returns isClassic (boolean, nil when not a WoW client) plus the decision source
-- ("projectID" / "realm" / "same-project" / "default"), for diagnostics.
-- Decision ladder -- deterministic tiers first, heuristics last:
--   1. wowProjectID reported as a real number -> trust Blizzard (retail always
--      reports it; classic clients report it for some cross-project friends).
--   2. Realm resolves in the bundled realm database (API field or rich presence,
--      region-scoped via FriendGroups_GetRealmEntry) -> its `classic` tag decides.
--      Realm names are unique per game mode within a region, so this is exact.
--   3. API realm fields populated (same-project friends only) -> our own flavor.
--   4. Nothing resolvable -> assume retail (fail-safe default).
function Compat.ResolveFriendFlavor(gameInfo)
	if not gameInfo or FG_Plain(gameInfo.clientProgram) ~= (BNET_CLIENT_WOW or "WoW") then
		return nil, "not-wow"
	end
	local mainline = WOW_PROJECT_MAINLINE or 1
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
		return (WOW_PROJECT_ID ~= mainline), "same-project"
	end
	return false, "default"
end

-- Highest attainable level on THIS client, read live so it never goes stale.
local HOST_MAX_LEVEL = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
	or (GetMaxLevelForExpansionLevel and GetExpansionLevel and GetMaxLevelForExpansionLevel(GetExpansionLevel()))
	or 80

-- Level cap BY PROJECT, for friends playing a DIFFERENT game than the host: the
-- "hide max level" toggle must compare a friend against the cap of the game THEY
-- are playing (a level-70 retail alt is not max just because BC Anniversary caps
-- at 70). The host's own entry is overwritten with the live API value below, so
-- this table only ever serves OTHER projects.
-- MAINTENANCE: bump these when an expansion raises a cap (last audit 2026-07:
-- Midnight 90 / Era-HC-SoD 60 / BC Anniversary 70 / MoP progression 90).
local PROJECT_MAX_LEVEL = {
	[WOW_PROJECT_MAINLINE or 1] = 90,
	[WOW_PROJECT_CLASSIC or 2] = 60,
	[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5] = 70,
	[WOW_PROJECT_MISTS_CLASSIC or 19] = 90,
}
PROJECT_MAX_LEVEL[WOW_PROJECT_ID] = HOST_MAX_LEVEL

-- True only when the friend's level is provably the cap of the friend's OWN game.
-- Fail-open by design: wrongly hiding a real level loses information, while
-- showing a redundant cap level is merely cosmetic -- so every unresolvable tier
-- answers false (show the level).
-- gameInfo == nil means a WoW character friend, who is on our client by definition.
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

-- Tint a WoW client (game) icon by flavor so retail vs Classic friends are easy to
-- tell apart: retail keeps its native gold "W"; Classic-family friends are desaturated
-- and tinted green (launcher parity). Keyed on the FRIEND's flavor, not ours, as
-- resolved by Compat.ResolveFriendFlavor (see its decision ladder above). Non-WoW
-- client icons are never tinted.
-- The green is the Monk class color (0, 255, 150), read from RAID_CLASS_COLORS so it
-- always matches the client's own monk green exactly.
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

-- Inline class-icon markup (for tooltip / fontstring text) given an English class
-- token. Retail uses the square class atlas; Platform_Render.lua overrides this on
-- Classic with the round UI-Classes-Circles texture and bundled TGAs, since MoP has
-- no "classicon-*" atlas.
function Compat.ClassIconMarkup(engClass, size)
	if not engClass or engClass == "" then return "" end
	size = size or 16
	local atlas = GetClassAtlas and GetClassAtlas(engClass)
	if atlas then
		return "|A:" .. atlas .. ":" .. size .. ":" .. size .. "|a"
	end
	return "|A:classicon-" .. string.lower(engClass) .. ":" .. size .. ":" .. size .. "|a"
end
