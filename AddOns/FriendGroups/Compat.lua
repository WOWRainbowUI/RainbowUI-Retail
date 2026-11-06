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
-- IS_MAINLINE is the retail PROJECT (what a friend's wowProjectID is compared with).
-- IS_RETAIL_UI is retail's FrameXML, which Forever (project 18, Camelot) also runs:
-- gate UI paths on IS_RETAIL_UI, never on IS_MAINLINE, or Forever falls into Classic code.
-- ============================================================================
Compat.PROJECT_ID   = WOW_PROJECT_ID
Compat.IS_MAINLINE  = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
Compat.IS_FOREVER   = (WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
Compat.IS_RETAIL_UI = Compat.IS_MAINLINE or Compat.IS_FOREVER
Compat.IS_CLASSIC   = not Compat.IS_RETAIL_UI

-- Forever's project id, readable on every flavor (Classic clients lack the global).
Compat.FOREVER_PROJECT = WOW_PROJECT_CAMELOT or 18
-- Realm value stored on Forever alts. Never rename: it is part of every Forever alt key.
Compat.FOREVER_REALM = "Forever"

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
Compat.CAN_RESIZE_WIDTH = Compat.IS_RETAIL_UI

-- The addon list under the minimap. Not every Classic client has it; LibDBIcon gates the same way.
Compat.HAS_COMPARTMENT = (AddonCompartmentFrame ~= nil)

-- Retail 12.1 replaced the contact list with the Social UI. Blizzard_FriendList was
-- split into Blizzard_SocialUI (the SocialUIFrame shell and its tab rail),
-- Blizzard_SocialUIShared (SocialUIControl / C_SocialUI) and Blizzard_FriendsFrame,
-- which carries BOTH the legacy FriendsFrame and the new FriendsListSocialViewTemplate.
--
-- Every legacy global this addon hooks still exists on 12.1 -- FriendsFrame,
-- FriendsListFrame, FriendsTooltip, FriendsList_Update, FriendsFrame_UpdateFriendButton,
-- FriendsListButtonMixin are all still defined by Blizzard_FriendsFrame -- so a presence
-- probe cannot tell the two eras apart, and HAS_SCROLLBOX above is TRUE on 12.1 even
-- though that ScrollBox is no longer reachable by the player.
--
-- The only authority is Blizzard's own switch. ToggleFriendsFrame tests
-- SocialUIControl.IsEnabled() before redirecting away from the legacy frame, and
-- FriendsFrame_UpdateTabs hides the Friends/Raid/Quick Join tabs on the same condition.
-- SocialUIControl.IsEnabled() wraps C_SocialUI.IsSystemEnabled(), which is server-driven
-- and can change mid-session (SOCIAL_UI_SYSTEM_STATUS_UPDATED fires when it does), so it
-- is evaluated LIVE on every call here and never cached at load time.
--
-- The friends list itself is an ANONYMOUS frame: SocialUIFrame creates one content frame
-- per tab via CreateFrame("Frame", nil, socialUIFrame, template) and reaches it by
-- parentKey. There is no global to probe, so the reference is taken off SocialUIFrame.
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

-- "Is the contact list the player is actually looking at on screen right now?"
-- Every visibility guard in the addon asks this instead of testing FriendsListFrame
-- directly, because on 12.1 FriendsListFrame still exists and is permanently hidden.
-- IsVisible() rather than IsShown() on the Social UI path: the friends view is only one
-- of six sibling content frames and SocialUIFrame shows exactly one at a time, so the
-- parent chain is part of the answer.
function Compat.IsContactListShown()
	local view = Compat.GetSocialUIFriendsView()
	if view then
		return view:IsVisible()
	end
	return FriendsListFrame ~= nil and FriendsListFrame:IsShown()
end

-- "Is the pointer over the contact list right now?"
--
-- This is the SCOPING test for FriendGroups' unit-menu injection. The MENU_UNIT_*_FRIEND
-- tags fire from several places -- chat lines, unit frames, the glue screen -- and the
-- addon only wants its entries on the contact list, so the menu builder confirms the click
-- originated there. On 12.1 the legacy FriendsListFrame is present but permanently hidden,
-- so a direct IsMouseOver() on it is false forever and the injection silently adds nothing.
--
-- The Classic/retail-12.0.7 branch is deliberately the exact expression the menu builder
-- used before, so nothing changes on those clients.
function Compat.IsContactListMouseOver()
	local view = Compat.GetSocialUIFriendsView()
	if view then
		return view:IsVisible() and view:IsMouseOver()
	end
	return FriendsListFrame ~= nil and FriendsListFrame:IsMouseOver()
end

-- True when this friend is a 12.1 TITLE friend -- the "WoW Friend" tier added in that patch,
-- created by "Add WoW Friend" rather than by BattleTag.
--
-- These are the successor to C_FriendList character friends, and the addon must treat them as
-- such: FRIENDS_BUTTON_TYPE_WOW, not _BNET. That distinction drives real behaviour --
-- FriendGroups_ShowButtonAltTooltip only raises the known-alts panel for BNET rows, because
-- the alt cache is a BATTLE.NET ACCOUNT concept and a title friend has no BattleTag to key it
-- by (confirmed on 12.1: accountInfo.battleTag is nil for the whole tier).
--
-- Enum.BattleNetFriendLevel.Title is the documented marker, and FriendsListUtil.IsTitleFriend
-- is Blizzard's own test for it; both are 12.1-only, so every earlier client answers false and
-- keeps its existing behaviour untouched.
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

-- Walk the frames the contact list is CURRENTLY rendering, whichever list that is.
--
-- The group banner colour picker refreshes visible headers live while the user drags, by
-- iterating the ScrollBox and matching on rawGroupName. Hard-coding FriendsListFrame.ScrollBox
-- there means that on 12.1 it iterates the hidden legacy box, finds nothing, and the preview
-- silently does nothing -- the colour only appears after some unrelated rebuild.
--
-- Resolves to exactly FriendsListFrame.ScrollBox on every non-Social-UI client, so the retail
-- and Classic behaviour is unchanged.
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

-- ============================================================================
-- [[ CLASSIC LIST OWNERSHIP ]]
-- Which HybridScrollFrame the Classic renderer draws into: Blizzard's, or ours.
--
-- Drawing into Blizzard's FriendsFrameFriendsScrollFrame means writing fields its own
-- code reads back while the Social window opens. FriendsFrame_OnShow calls
-- FriendsList_Update(true), which reads the FriendsFrame_UpdateFriends global and
-- FriendsFrame.selectedFriendType, and the native updater then reads scrollFrame.buttons,
-- the scroll offset and FriendsTooltip.button. Reading a value addon code last wrote
-- taints the rest of that execution -- and OnShow ends in RaidFrame:Show() whenever the
-- Raid tab is selected. RaidFrame is protected, so in combat that call is refused: the
-- Raid panel never opens, which is CurseForge issue #55. On Classic that panel is the
-- only way to move raid members between groups mid-fight (SetRaidSubgroup and
-- SwapRaidSubgroup are blocked for addons and macros, but Blizzard's own drag is not),
-- so the cost is real and not cosmetic.
--
-- The fix is ownership, not cleverness: our own list frame, Blizzard's left alone.
-- FriendGroups_ClassicList.xml builds it from the same templates so nothing changes
-- visually. See FriendGroups-Classic-OwnList-Plan.md in the dev workspace.
--
-- GATED while the path is built out. The row handlers, selection and tooltip still
-- write Blizzard's fields (plan WP4-WP6), so the taint is not gone yet and this must
-- stay off by default until they land. Flip it for a test with
--   /run FriendGroups_SavedVars.classic_own_list = true  (then /reload)
-- Every caller goes through GetClassicListFrame, so with the flag off the addon behaves
-- exactly as it always has.
function Compat.UseOwnClassicList()
	if Compat.HAS_SCROLLBOX then return false end
	if not _G.FriendGroupsClassicList then return false end
	local sv = FriendGroups_SavedVars
	return (sv ~= nil and sv.classic_own_list) and true or false
end

-- The Classic list frame in force right now. Nil on no flavor: Blizzard's frame is the
-- fallback and exists on every Classic client (retail never reaches these callers, which
-- all sit behind HAS_SCROLLBOX checks or in the Classic-only renderer).
--
-- Resolved per call, never cached: the saved variable is read live so a /reload is the
-- only thing needed to switch paths, and no caller can be holding a stale frame.
function Compat.GetClassicListFrame()
	if Compat.UseOwnClassicList() then return _G.FriendGroupsClassicList end
	return FriendsFrameFriendsScrollFrame
end

-- Walk every row frame the contact list is currently rendering, on EVERY flavor.
--
-- ForEachContactListFrame above covers the two ScrollBox platforms only, which is all the
-- banner colour preview that calls it has ever needed. Header drag and drop needs the
-- Classic list as well, and there the rows are a fixed HybridScrollFrame button pool
-- rather than a ScrollBox: the frames have to be read off scrollFrame.buttons and filtered
-- down to the ones actually on screen, because that pool keeps its off-list buttons around
-- hidden rather than releasing them.
--
-- Kept separate from ForEachContactListFrame rather than folded into it: that function's
-- callers assume the retail-only reach they were written against, and widening it would
-- start running their work on a platform that has never seen it.
--
-- The callback is handed frames in no defined order and must not assume a row type.
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

-- The frame the contact list SCROLLS INSIDE -- the viewport the rows move within, not the
-- outer window GetContactListAnchor returns. Drag and drop measures the pointer against
-- its top and bottom edges and parents its drop indicator to it.
--
-- Nil on a client where neither list exists, which every caller has to tolerate: on 12.1
-- the answer changes when the player is moved between the Social UI and the legacy panel
-- mid-session, so it is resolved on each call and never cached.
function Compat.GetListScrollContainer()
	local view = Compat.GetSocialUIFriendsView()
	if view and view.ScrollBox then return view.ScrollBox end
	if FriendsListFrame and FriendsListFrame.ScrollBox then return FriendsListFrame.ScrollBox end
	return Compat.GetClassicListFrame()
end

-- Scroll the contact list by a signed FRACTION of its total scrollable range; negative
-- moves toward the top of the list.
--
-- A fraction rather than a pixel or row count, deliberately. It makes a full traversal
-- take the same wall time on a four-group list and a forty-group one, which is the
-- property an edge-scroll wants: the user is holding the pointer against an edge and
-- waiting, and how long that wait is should not depend on how many friends they have.
--
-- ScrollBox carries its position as a 0..1 percentage (GetScrollPercentage /
-- SetScrollPercentage -- the same pair FG_ForceScrollRedraw in FriendGroups.lua uses).
-- HybridScrollFrame has no equivalent: its position lives on the companion slider the bar
-- template publishes as scrollFrame.scrollBar (parentKey, so it is there on Blizzard's
-- frame and on ours alike), is read and written in that slider's own units, and only
-- redraws because the template's OnValueChanged runs
-- HybridScrollFrame_SetOffset and then the frame's update callback.
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

-- The PANEL that hosts the contact list -- the outer window, not the list subframe.
--
-- Two things key off this. The alt-tooltip parks itself against the panel's right edge, and
-- FriendGroups_DockNativeTooltipBelowPanel decides WHICH native tooltip is in play from it:
-- the legacy friends list draws into the dedicated FriendsTooltip, while the 12.1 card draws
-- into the shared GameTooltip. Returning SocialUIFrame there is what makes the docking code
-- select GameTooltip and the Show hook stop early-returning, with no change to either.
--
-- Returns FriendsFrame on every client that is not running the Social UI, so the retail and
-- Classic paths evaluate exactly the frame they always did.
function Compat.GetContactListAnchor()
	if Compat.IsSocialUIActive() then
		return SocialUIFrame
	end
	return FriendsFrame
end

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

-- ============================================================================
-- [[ C_BattleNet.SearchFriends ]] Protected on live 12.1 and on Forever; pcall cannot stop
-- ADDON_ACTION_FORBIDDEN, so the event latches it off. Forever starts latched: it blocks the
-- very first call. Why: Desktop\Claude\FriendGroups\FriendGroups-Forever-Port-Plan.md s9.2.
-- ============================================================================
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
	if Compat.IsForeverGame(gameInfo) then return Compat.IS_FOREVER end
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
	[WOW_PROJECT_CAMELOT or 18] = 60,
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
