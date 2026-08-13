--[[
	FriendGroups - Platform_SocialUI.lua
	============================================================================
	Retail 12.1 Social UI list renderer. Loaded after Compat.lua and
	Platform_Render.lua, before FriendGroups.lua.

	12.1 replaced the contact list. Blizzard_FriendList was split into
	Blizzard_SocialUI (the SocialUIFrame shell), Blizzard_SocialUIShared
	(SocialUIControl / C_SocialUI) and Blizzard_FriendsFrame, which carries BOTH
	the legacy FriendsFrame and the new FriendsListSocialViewTemplate. Because
	every legacy global still exists, the addon's existing hooks all succeed and
	silently decorate a frame the player can no longer open. See
	Compat.IsSocialUIActive for how the two eras are told apart.

	This module renders the SAME layout array FriendGroups_FriendsListUpdate
	builds for the other two platforms, but as a TreeDataProvider instead of a
	flat one, because that is what the Social UI's ScrollBox expects.

	Node contract (read from Blizzard_FriendsFrame/Mainline/FriendsListTemplates.lua
	and confirmed live against the 12.1 client -- a two-friend list reports
	GetDataProviderSize() == 4: header + spacer + two cards):

	  TreeDataProvider
	  |-- { headerText = <string> }              -> SocialUIScrollableHeaderTemplate
	  |     |-- { isSpacer = true }              -> SocialUIScrollableSpacerTemplate
	  |     |-- { friendIndex = n,
	  |     |     accountInfo = <table> }        -> FriendsListSocialCardTemplate
	  |     '-- ...
	  '-- ...

	FriendsListSocialViewMixin:InitializeScrollBox selects the template purely by
	node SHAPE (isSpacer first, then headerText ~= nil, else card), so a provider
	built to this contract is rendered by Blizzard's own element factory with
	Blizzard's own card visuals. Nothing here creates or restyles a row: that is
	deliberate, and is what keeps this step small.

	Collapse is NATIVE here. Blizzard's header button calls node:ToggleCollapsed(),
	so the addon's saved collapse state is seeded onto the nodes at build time and
	read back out again whenever the tree invalidates.

	API compliance: WoW Midnight 12.1 (Interface 120100). Every Blizzard symbol
	touched is presence-guarded, and nothing here runs on a client that does not
	report the Social UI as enabled.
]] --

local addonName, addonTable = ...
local Compat = addonTable.Compat
local L = addonTable.L

-- Blizzard_SocialUI and Blizzard_SocialUIShared are both "AllowLoadGameType: mainline",
-- so the Social UI cannot exist on any Classic flavor. Classic keeps the HybridScroll
-- renderer in Platform_Render.lua and never loads any of this.
if not Compat.IS_MAINLINE then return end

-- Shared state exposed by FriendGroups.lua. That file loads AFTER this one, so
-- capturing addonTable.State now would pin nil; it is bound lazily at first render,
-- exactly as Platform_Render.lua does.
local State

-- The grouped provider currently installed in the Social UI ScrollBox. Held so the
-- re-assert path can tell "ours" from the flat one Blizzard installs on every Refresh.
local FG_SocialProvider

-- Stable owner token for provider callback registration (CallbackRegistryMixin keys
-- registrations by owner, and passes it back as the handler's first argument).
local FG_CallbackOwner = {}

local hooksInstalled = false
local cardHookInstalled = false

-- Set only when the row-height override has actually been ACCEPTED, which is not the same as
-- "we tried once". See FG_InstallCardHeightOverride and its retry in Compat.RenderSocialUIList.
local cardHeightInstalled = false

-- Diagnostic counters (see FriendGroups_GetSocialUIState). Cheap integers, incremented on
-- the row path so "the hook never fired" can be told apart from "the hook fired and bailed".
local FG_RowApplyCalls = 0
local FG_RowApplyApplied = 0
local FG_AltTooltipCalls = 0

-- Forward declaration: the row-content applier is defined further down, next to the
-- display settings it reads, but the delivery pass above it needs the reference. Without
-- this the name would compile as a global lookup in the earlier function and resolve to
-- nil at call time -- a fault no syntax check can see.
local FG_ApplySocialCardContent
local FG_OnCardShowTooltip
local FG_OnCardHideTooltip
local FG_HookSearchBox
-- Defined next to the other menu work, far below, but called from the renderer above it.
-- Without this forward declaration that call would compile as a GLOBAL lookup and be nil
-- at runtime -- the exact silent-failure class this file's header warns about.
local FG_HookFilterDropdown
local FG_RefreshPortrait
-- The legacy panel's half of the streamer-mode BattleTag, defined in the legacy section at the
-- foot of this file but dispatched to from Compat.RefreshOwnBattleTag, which sits above it.
-- Same reason as every other name in this block: without the declaration that call compiles to
-- a global lookup, resolves to nil, and the mode silently does nothing on the panel that is
-- actually on screen.
local FG_RefreshOwnBattleTagLegacy
local FG_HeaderOnDragStart
local FG_HeaderOnDragStop
-- Defined with the row-density constants far below, but retried from Compat.RenderSocialUIList
-- above them. Declared here for the same reason as everything else in this block, and it is
-- worth recording that it was NOT: the call compiled to a global lookup, resolved to nil, and
-- threw on every single list render. luac -p reports that file as perfectly valid.
local FG_InstallCardHeightOverride
local FG_UpdateContactCounter
local FG_ContactCountText, FG_ContactCountHover

-- Four digits of GameFontNormalSmall plus padding: the online count is capped in practice
-- by the 600-contact Battle.net limit the cap tooltip reports.
local FG_CONTACT_COUNT_WIDTH = 36

-- ============================================================================
-- [[ ELLESMEREUI COLOURISE ]]
-- EllesmereSkin.lua publishes the theme; this file only asks for it. The rule is
-- colourise-ONLY: the four call sites below all sit in code that already writes the
-- region in question (header banner, row background, contact count, drag indicator),
-- so nothing new is drawn and no Blizzard chrome is touched. EllesmereUI reskins
-- SocialUIFrame itself, and fighting that is the one outcome to avoid.
--
-- Looked up by GLOBAL NAME at call time, never captured at file scope:
-- EllesmereSkin.lua is the LAST entry in the TOC, so FriendGroupsEUISkin does not
-- exist yet while this file loads. It is a true global (EllesmereSkin.lua sets
-- _G.FriendGroupsEUISkin), not a file-local, so the lookup genuinely resolves --
-- checked, because a bare global reference to another file's local returns nil in
-- silence. Returns nil on every client where EllesmereSkin.lua is not loaded at
-- all, which is all three Classic flavors.
local function FG_EUITheme()
	local skin = _G.FriendGroupsEUISkin
	if type(skin) ~= "table" or type(skin.GetTheme) ~= "function" then return nil end
	return skin.GetTheme()
end

-- Re-font a fontstring to the EllesmereUI family, keeping Blizzard's SIZE.
--
-- The size is deliberately never touched. Every string on this frame is re-derived
-- from TextSizeManager when the user changes their UI text size, so an absolute size
-- written here would freeze one row at one scale; and a relative one would compound
-- across recycles, which is the trap FG_ShrinkFont already documents.
--
-- A nil fontFlag means "we do not know" (no facade) and keeps the string's own flags.
-- An EMPTY STRING is a real answer from EllesmereUI's API -- the user's font has no
-- outline -- and must override them.
-- ============================================================================
-- [[ FONT ADOPTION ]]
-- Give a fontstring we created the same face as one Blizzard created, so the two read as one
-- line. Every step matters, and the LAST one is the one that bit:
--
--   GetFontObject   preferred -- the object carries the player's UI text scaling, so the
--                   result tracks their settings instead of freezing today's size;
--   GetFont         for a region the template configured with an explicit SetFont, where
--                   GetFontObject answers nil;
--   a named default because a fontstring with NO font set renders absolutely nothing, and
--                   silently: the Battle.net bar's replacement label was created, positioned,
--                   given text, shown -- and was invisible, because the region it copied from
--                   had no font object and the fallback chain stopped one step short. A blank
--                   gap where a label should be is indistinguishable from "the feature did
--                   not run", which is exactly how it was reported.
-- ============================================================================
local function FG_AdoptFont(fontString, source)
	if not fontString then return end

	if source then
		local fontObject = source.GetFontObject and source:GetFontObject()
		if fontObject then
			fontString:SetFontObject(fontObject)
			return
		end
		if source.GetFont then
			local font, size, flags = source:GetFont()
			if font and size and size > 0 then
				fontString:SetFont(font, size, flags)
				return
			end
		end
	end

	-- Last resort, so the string is never fontless. GameFontNormal is defined by the base UI
	-- on every client and flavor this addon runs on.
	if GameFontNormal then
		fontString:SetFontObject(GameFontNormal)
	end
end

local function FG_ApplyThemeFont(fontString, theme)
	if not fontString or not theme or not theme.fontPath then return end

	local _, size, flags = fontString:GetFont()
	if not size then return end
	if theme.fontFlag ~= nil then flags = theme.fontFlag end

	fontString:SetFont(theme.fontPath, size, flags)
end

-- The font EllesmereSkin.lua draws the LEGACY window's chrome in, or nil when nothing is
-- themed. Deliberately NOT theme.fontPath: the theme carries EllesmereUI's Blizzard-skin font
-- (what IT paints the 12.1 Social UI with), while every string that file writes on 12.0.7's
-- FriendsFrame -- the title, the tabs, the search box, the BattleTag bar -- takes the
-- friends-module font. The two are the same until the user sets a per-module override, and a
-- label sitting between two chrome strings has to match its neighbours, not the other panel.
local function FG_EUIChromeFontPath()
	local skin = _G.FriendGroupsEUISkin
	if type(skin) ~= "table" or type(skin.GetChromeFontPath) ~= "function" then return nil end
	return skin.GetChromeFontPath()
end

-- Re-font to an explicit family, keeping the string's own size AND flags -- the same terms
-- EllesmereSkin's own re-font pass over the Battle.net bar uses, so a label restyled here is
-- indistinguishable from one restyled there.
local function FG_ApplyFontPath(fontString, path)
	if not fontString or not path then return end

	local _, size, flags = fontString:GetFont()
	if not size then return end

	fontString:SetFont(path, size, flags)
end

-- ============================================================================
-- [[ HEADER TEXT ]]
-- The group LABEL only. Blizzard's header template exposes exactly one string
-- (SocialUIScrollableHeaderMixin:Initialize reads nodeData.headerText and nothing else),
-- and that string is left-aligned, so the count cannot ride along inside it: joined
-- together, the numbers land at whatever x the group name happened to end at, which on a
-- list of differently-named groups is a different x on every row. FG_BuildHeaderCount
-- below produces the count as its own string, drawn right-aligned by the decoration pass --
-- which is how retail's own divider has always laid the two out.
-- ============================================================================
local function FG_BuildHeaderText(groupName)
	if type(groupName) ~= "string" or groupName == "" then return "" end

	-- The guild group carries the player's guild name in its header, as on retail.
	-- FriendGroups_PlayerGuildName is a file-local in FriendGroups.lua; a scalar cannot
	-- be shared by reference, so State exposes a live accessor for it.
	if groupName == L["GROUP_GUILDMATES"] then
		local guildName = State and State.GetPlayerGuildName and State.GetPlayerGuildName()
		if type(guildName) == "string" and guildName ~= "" then
			return string.format(L["FORMAT_GUILD_TAG"], groupName, guildName)
		end
	end

	return groupName
end

-- The count half. Semantics copied verbatim from
-- FriendGroups_FriendsListUpdateDividerTemplate so both platforms agree:
--   online     = groupsCount[group].Online
--   total      = groupsCount[group].Raw (the unfiltered group size), falling back to Total
--   offline groups show the total alone -- their "0/" carries no information
--   the empty-list placeholder shows no count at all
--
-- overrideOnline/overrideTotal are supplied ONLY while a native Status/Tags filter is
-- active, where the group's real membership is not what is on screen. Blizzard does the
-- same thing in InsertFriendsIntoDataProvider: with a search result in hand it zeroes its
-- totals and recounts from the survivors rather than reporting the roster.
local function FG_BuildHeaderCount(groupName, overrideOnline, overrideTotal)
	if type(groupName) ~= "string" or groupName == "" then return "" end
	if groupName == L["GROUP_EMPTY"] then return "" end

	local counts = State and State.groupsCount and State.groupsCount[groupName]
	local online = overrideOnline or (counts and counts.Online) or 0
	local total = overrideTotal or (counts and (counts.Raw or counts.Total)) or 0

	-- FriendGroups_IsOfflineGroup is the single authority on which groups these are, so a
	-- fourth bucket reaches this header without an edit here. Guarded because this file is
	-- loaded BEFORE FriendGroups.lua by the TOC -- at run time the global is always present,
	-- but the type test costs nothing and keeps the load order from being load-bearing.
	-- Offline groups show the total alone: their "0/" carries no information.
	if type(FriendGroups_IsOfflineGroup) == "function" and FriendGroups_IsOfflineGroup(groupName) then
		return string.format(L["SOCIALUI_GROUP_COUNT_TOTAL"], total)
	end

	return string.format(L["SOCIALUI_GROUP_COUNT"], online, total)
end

-- ============================================================================
-- [[ ROW CONTENT DELIVERY ]]
-- Hooking FriendsListSocialCardMixin is NOT sufficient, and the 12.1 client proved it:
-- with the mixin hook verifiably attached, it never fired once. XML mixin= applies
-- Mixin(), which COPIES functions onto each frame at creation, so a card built before the
-- hook keeps the original forever -- and the ScrollBox's frame pool has already built its
-- cards by the time any addon event runs. Frames are then recycled, never rebuilt, so the
-- mixin hook can never catch up.
--
-- The reliable route is the frame itself. After every provider swap, the visible frames
-- are walked with ForEachFrame (the same API the legacy path uses): each one gets our
-- content applied immediately, and a ONE-TIME post-hook on its OWN InitializeDisplay so
-- that recycling it onto a different friend re-applies without another pass.
--
-- Headers and spacers fall through harmlessly: they carry no elementData.accountInfo, so
-- the applier returns before touching anything.
-- ============================================================================
-- ============================================================================
-- [[ GROUP HEADER ]]
-- Blizzard's header is a plain collapse button: its factory sets a left-click OnClick that
-- toggles the node and nothing else. Retail's header additionally carries a banner colour
-- and a right-click menu (rename, colour, reorder, delete).
--
-- Both are added here rather than reimplemented. FriendGroups_FrameFriendDividerTemplate-
-- HeaderClick is the retail handler and a genuine global; it reads `rawGroupName` and
-- `name` off whatever frame it is given, so aliasing those onto the Social UI header lets
-- it run unchanged -- one menu definition serving both platforms.
--
-- HookScript rather than SetScript, so Blizzard's collapse survives; and RegisterForClicks
-- must name RightButtonUp or a right-click never reaches OnClick at all.
-- ============================================================================
-- Left-click collapses, right-click opens the group menu. Both are retail's own globals,
-- reached through the rawGroupName / name aliases set below, so the two platforms share one
-- implementation of each.
--
-- Routing collapse through FriendGroups_FrameFriendDividerTemplateCollapseClick rather than
-- node:ToggleCollapsed() is what makes "Auto Collapse Groups" work: that setting lives
-- inside this handler, and Blizzard's node toggle never reaches it. It writes
-- FriendGroups_SavedVars.collapsed and rebuilds; the rebuild reseeds every node's collapsed
-- state and Blizzard's Initialize sets the chevron from the node, so the visual follows.
local function FG_HeaderOnClick(self, button, down)
	if button == "RightButton" then
		if type(FriendGroups_FrameFriendDividerTemplateHeaderClick) == "function" then
			FriendGroups_FrameFriendDividerTemplateHeaderClick(self, button, down)
		end
		return
	end

	if type(FriendGroups_FrameFriendDividerTemplateCollapseClick) == "function" then
		FriendGroups_FrameFriendDividerTemplateCollapseClick(self, button, down)
	end
end

local function FG_ApplyHeaderClickScript(header)
	header.fgSettingOwnScript = true
	header:SetScript("OnClick", FG_HeaderOnClick)
	header.fgSettingOwnScript = false
end

-- Blizzard's element factory re-runs
--     button:SetScript("OnClick", <collapse closure>)
-- on EVERY initialisation, after button:Initialize(node) -- so hooking Initialize is too
-- early and a plain HookScript is discarded the first time the header is rebound. That is
-- why the right-click menu never appeared.
--
-- Watching SetScript itself is the one place that reliably sees their assignment land. The
-- guard flag stops our own re-assignment from re-entering the hook.
local function FG_InstallHeaderClickTakeover(header)
	if not header.fgHeaderScriptHooked then
		header.fgHeaderScriptHooked = true
		hooksecurefunc(header, "SetScript", function(self, scriptType)
			if scriptType ~= "OnClick" then return end
			if self.fgSettingOwnScript then return end
			FG_ApplyHeaderClickScript(self)
		end)
	end

	-- Right-click only reaches OnClick when it is named here. Re-applied every pass:
	-- RegisterForClicks replaces its list, so this is idempotent.
	if type(header.RegisterForClicks) == "function" then
		header:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	end

	-- Drag scripts are safe to set once: Blizzard's factory only ever re-sets OnClick.
	-- Registered for every header, movable or not; OnDragStart itself refuses fixed anchors,
	-- which keeps the decision in one place.
	if type(header.RegisterForDrag) == "function" then
		header:RegisterForDrag("LeftButton")
	end
	header:SetScript("OnDragStart", FG_HeaderOnDragStart)
	header:SetScript("OnDragStop", FG_HeaderOnDragStop)

	FG_ApplyHeaderClickScript(header)
end

-- ============================================================================
-- [[ GROUP DRAG AND DROP ]]
-- Free drag on the header itself. RegisterForDrag gives the click/drag split for nothing:
-- OnDragStart only fires once the pointer has moved a few pixels while held, and the click
-- is suppressed when it does -- so collapse-on-click survives without a manual threshold.
--
-- Blizzard's factory only ever re-sets OnClick, so the drag scripts are safe from the
-- clobbering that defeated the right-click menu.
--
-- Only movable groups take part. Favorites, [No Group] and the offline trackers are fixed
-- anchors: they cannot be dragged, and the drop slot is computed across movable headers
-- alone so nothing can be dropped above them either.
-- ============================================================================
local FG_DragGroupName = nil
local FG_DragIndicator = nil
local FG_DragStarts = 0

local function FG_IsGroupMovable(groupName)
	State = State or addonTable.State
	if not State or type(State.IsFixedAnchor) ~= "function" then return false end
	return not State.IsFixedAnchor(groupName)
end

-- Cursor Y in the ScrollBox's own coordinate space. GetCursorPosition reports in raw screen
-- units, so it has to be divided by the effective scale before it can be compared against
-- frame edges.
local function FG_CursorY(referenceFrame)
	local _, y = GetCursorPosition()
	local scale = referenceFrame:GetEffectiveScale()
	if not scale or scale <= 0 then return nil end
	return y / scale
end

-- Returns the insertion slot under the pointer, plus the header frame that slot sits above
-- (nil when the slot is past the last movable header, i.e. dropping at the end).
--
-- Screen Y increases UPWARDS, and headers are laid out top to bottom, so walking them in
-- display order and counting the ones the cursor has fallen below yields the slot directly.
local function FG_ComputeDropSlot()
	local view = Compat.GetSocialUIFriendsView()
	local scrollBox = view and view.ScrollBox
	if not scrollBox or type(scrollBox.ForEachFrame) ~= "function" then return nil, nil end

	State = State or addonTable.State
	if not State or type(State.GetMovableIndex) ~= "function" then return nil, nil end

	local cursorY = FG_CursorY(scrollBox)
	if not cursorY then return nil, nil end

	local byIndex = {}
	scrollBox:ForEachFrame(function(frame)
		if frame.ButtonText and not frame.FriendName and frame.rawGroupName then
			local index = State.GetMovableIndex(frame.rawGroupName)
			if index then byIndex[index] = frame end
		end
	end)

	local count = (type(State.GetMovableCount) == "function" and State.GetMovableCount()) or 0
	local slot = 1
	for index = 1, count do
		local frame = byIndex[index]
		if frame and frame:GetBottom() and cursorY < frame:GetBottom() then
			slot = index + 1
		end
	end

	return slot, byIndex[slot]
end

local function FG_HideDropIndicator()
	if FG_DragIndicator then FG_DragIndicator:Hide() end
end

local function FG_UpdateDropIndicator()
	local view = Compat.GetSocialUIFriendsView()
	local scrollBox = view and view.ScrollBox
	if not scrollBox then return end

	if not FG_DragIndicator then
		FG_DragIndicator = scrollBox:CreateTexture(nil, "OVERLAY")
		FG_DragIndicator:SetHeight(2)
		FG_DragIndicator:SetColorTexture(1, 0.82, 0, 0.9)
	end

	local slot, frameAtSlot = FG_ComputeDropSlot()
	if not slot then
		FG_HideDropIndicator()
		return
	end

	FG_DragIndicator:ClearAllPoints()
	if frameAtSlot then
		-- Land the line on the top edge of the header we would displace.
		FG_DragIndicator:SetPoint("TOPLEFT", frameAtSlot, "TOPLEFT", 0, 1)
		FG_DragIndicator:SetPoint("TOPRIGHT", frameAtSlot, "TOPRIGHT", 0, 1)
	else
		-- Past the last movable header: sit at the bottom of the list.
		FG_DragIndicator:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMLEFT", 0, 0)
		FG_DragIndicator:SetPoint("BOTTOMRIGHT", scrollBox, "BOTTOMRIGHT", 0, 0)
	end
	FG_DragIndicator:Show()
end

FG_HeaderOnDragStart = function(self)
	local groupName = self.rawGroupName
	if not groupName or not FG_IsGroupMovable(groupName) then return end

	FG_DragStarts = FG_DragStarts + 1
	FG_DragGroupName = groupName
	self:SetAlpha(0.5)
	self:SetScript("OnUpdate", FG_UpdateDropIndicator)
	FG_UpdateDropIndicator()

	-- Colour resolved once per drag rather than at texture creation: the EllesmereUI
	-- theme can arrive after the indicator was first built, and the user can recolour
	-- their accent live. Done here and not in FG_UpdateDropIndicator because that one
	-- runs from OnUpdate -- every frame of the drag.
	-- FriendGroups_AccentRGB is the addon-wide resolver: EllesmereUI's live accent when
	-- themed, gold otherwise. Read here rather than from the cached theme table, which
	-- deliberately no longer carries an accent -- it is the one value the user edits at
	-- runtime.
	if FG_DragIndicator then
		local aR, aG, aB = FriendGroups_AccentRGB()
		FG_DragIndicator:SetColorTexture(aR, aG, aB, 0.9)
	end
end

FG_HeaderOnDragStop = function(self)
	self:SetAlpha(1)
	self:SetScript("OnUpdate", nil)
	FG_HideDropIndicator()

	local groupName = FG_DragGroupName
	FG_DragGroupName = nil
	if not groupName then return end

	local slot = FG_ComputeDropSlot()
	if not slot then return end

	State = State or addonTable.State
	if State and type(State.MoveGroupToIndex) == "function" then
		State.MoveGroupToIndex(groupName, slot)
	end
end

-- [[ COLLAPSE INDICATOR ]]
-- Probed off a live 12.1 header rather than named from source: its regions are
--   1 FontString  2 Texture common-button-list-collapseExpand
--   3 Texture common-button-list-collapseExpand  4 FontString  5 Texture (ours)
-- The two toggle states share one atlas, and neither carries a frame-table key -- a
-- pairs() walk of the header finds only solidBannerTexture. So they are matched by
-- ATLAS, which is the one stable handle: the region index is an accident of template
-- order, and there is no name to match on.
--
-- Only touched while a theme is live. Vertex colour MULTIPLIES the atlas, so tinting an
-- unthemed client with the gold that FriendGroups_AccentRGB falls back to would visibly
-- recolour Blizzard's own art. The flag records that we tinted, so switching the skin off
-- restores white instead of leaving the accent stranded.
local FG_HEADER_TOGGLE_ATLAS = "common-button-list-collapseExpand"

local function FG_TintHeaderToggle(header)
	local themed = FG_EUITheme() ~= nil
	if not themed and not header.fgToggleTinted then return end

	local r, g, b = 1, 1, 1
	if themed then r, g, b = FriendGroups_AccentRGB() end

	for i = 1, select("#", header:GetRegions()) do
		local region = select(i, header:GetRegions())
		if region and region.GetAtlas and region:GetAtlas() == FG_HEADER_TOGGLE_ATLAS then
			region:SetVertexColor(r, g, b)
		end
	end

	header.fgToggleTinted = themed or nil
end

-- ============================================================================
-- [[ HEADER COUNT ]]
-- The "12/40" sits hard against the right edge of every header, in a column of its own, so
-- the numbers line up down the list instead of trailing group names of differing lengths.
--
-- Blizzard's header template exposes exactly one string (SocialUIScrollableHeaderMixin
-- :Initialize reads nodeData.headerText and nothing else), so this is a fontstring of our
-- own, anchored to the header's own right edge with a fixed inset that clears the chevron.
--
-- [[ TWO THINGS THIS MUST NOT DO, BOTH LEARNED THE HARD WAY ]]
--
-- It must not MEASURE the chevron. FG_ApplyHeaderDecoration runs immediately after
-- SetDataProvider, before the frames are laid out, so GetCenter/GetWidth answer nil there and
-- any decision taken from them is taken on no information -- which is how the count ended up
-- underneath the chevron instead of beside it.
--
-- It must not ANCHOR to the chevron either. Its region is found by atlas, and the atlas is
-- not proof that the region is the small glyph at the right: anchoring the count to that
-- region's LEFT edge put it off the left end of the bar, and the label -- which was anchored
-- to the count in turn -- went with it, blanking every group header on the list.
--
-- So: anchor to the header, reserve a constant, and leave Blizzard's own label alone
-- entirely. The label keeps whatever anchors its template gave it. A very long group name can
-- therefore run under the count, which is a far smaller price than a list of blank bars.
-- ============================================================================
local FG_HEADER_COUNT_GAP = 6

-- Clearance from the header's right edge for the collapse chevron. A constant on purpose:
-- the chevron is a fixed-size glyph in Blizzard's template, and every attempt to derive this
-- number at decoration time has been wrong because nothing is laid out yet.
local FG_HEADER_TOGGLE_RESERVE = 30

local function FG_ApplyHeaderCount(header, countText)
	if type(countText) ~= "string" or countText == "" then
		if header.fgCountText then header.fgCountText:Hide() end
		return
	end

	if not header.fgCountText then
		header.fgCountText = header:CreateFontString(nil, "OVERLAY")
		-- Same font as the label, so the two read as one line rather than as a caption
		-- bolted on. Captured from ButtonText rather than named, because the template's
		-- font object is what tracks the player's UI text scale.
		FG_AdoptFont(header.fgCountText, header.ButtonText)
	end

	local count = header.fgCountText
	count:SetJustifyH("RIGHT")
	count:ClearAllPoints()
	count:SetPoint("RIGHT", header, "RIGHT", -(FG_HEADER_TOGGLE_RESERVE + FG_HEADER_COUNT_GAP), 0)

	FG_ApplyThemeFont(count, FG_EUITheme())

	-- [[ COLOUR IS COPIED FROM THE LABEL, NOT RE-DERIVED ]]
	-- Taken from ButtonText, which by this point in FG_ApplyHeaderDecoration has already been
	-- given whatever colour this group resolves to. So the count matches the name by
	-- construction, with or without an override, and there is no default here to get wrong.
	--
	-- Re-derived it used to be, via HeaderFontRGB -- which returns NIL for a group with no
	-- override, so the SetTextColor call was skipped and this pooled fontstring kept the last
	-- colour it had been given. A header recycled from a red-tinted custom group onto
	-- [No Group] carried the red with it. Blizzard's own label never shows that bug because
	-- its template re-applies a font object on every recycle, and a font object carries its
	-- colour; ours has no template to recover from, so it must be written every pass.
	if header.ButtonText and type(header.ButtonText.GetTextColor) == "function" then
		local r, g, b = header.ButtonText:GetTextColor()
		if r then count:SetTextColor(r, g, b) end
	end

	count:SetText(countText)
	count:Show()
end

local function FG_ApplyHeaderDecoration(header, groupName, countText)
	if type(groupName) ~= "string" or groupName == "" then return end

	FG_TintHeaderToggle(header)

	header.rawGroupName = groupName
	-- The retail handler reads frame.name:GetText() as its fallback label.
	header.name = header.name or header.ButtonText

	-- Banner colour behind the header text, from the same saved variable retail uses.
	--
	-- The draw layer is measured, not assumed -- two earlier guesses put this underneath
	-- Blizzard's art and it never appeared. ListHeaderVisualTemplate gives the button a
	-- NormalTexture covering its whole face, and that texture draws at ARTWORK, so BACKGROUND
	-- and BORDER are both beneath it. Sitting at ARTWORK sublevel 1 puts the banner one step
	-- above it, and the label is lifted to OVERLAY so it is guaranteed to stay on top
	-- regardless of where the template happens to place it.
	--
	-- SetDrawLayer is re-applied every pass rather than only at creation, so a texture built
	-- by an earlier build corrects itself instead of staying invisible.
	if not header.solidBannerTexture then
		header.solidBannerTexture = header:CreateTexture(nil, "ARTWORK")
		header.solidBannerTexture:SetAllPoints(header)
	end
	header.solidBannerTexture:SetDrawLayer("ARTWORK", 1)
	if header.ButtonText then
		header.ButtonText:SetDrawLayer("OVERLAY")

		FG_ApplyThemeFont(header.ButtonText, FG_EUITheme())

		-- Label colour, resolved by the same shared rule the legacy renderer uses: an
		-- explicit override wins, a banner colour implies white, and no banner returns nil so
		-- Blizzard's own colour stands. Re-applied every pass because the header is pooled and
		-- its template colour comes back on each recycle.
		State = State or addonTable.State
		if State and type(State.HeaderFontRGB) == "function" then
			local fontR, fontG, fontB = State.HeaderFontRGB(groupName)
			if fontR then header.ButtonText:SetTextColor(fontR, fontG, fontB) end
		end

		-- ListHeaderVisualTemplate declares BOTH a NormalFont and a HighlightFont, and the
		-- button swaps between them on mouseover. Applying a font object also re-applies that
		-- object's colour, which discards our SetTextColor -- so the header reverted to grey
		-- the moment the pointer touched it.
		--
		-- Re-applied on both edges rather than only on enter: the swap back on leave resets it
		-- again. Hooked once per frame -- HookScript APPENDS, so doing this every decoration
		-- pass would stack a new handler on each rebuild.
		if not header.fgFontHooked then
			local function ReapplyHeaderFont(self)
				if not self.ButtonText or not self.rawGroupName then return end

				-- The font-object swap discards the FAMILY as surely as it discards the
				-- colour, so both are re-stated on both edges.
				FG_ApplyThemeFont(self.ButtonText, FG_EUITheme())

				local s = addonTable.State
				if not s or type(s.HeaderFontRGB) ~= "function" then return end
				local r, g, b = s.HeaderFontRGB(self.rawGroupName)
				if r then self.ButtonText:SetTextColor(r, g, b) end
			end
			header:HookScript("OnEnter", ReapplyHeaderFont)
			header:HookScript("OnLeave", ReapplyHeaderFont)
			header.fgFontHooked = true
		end
	end
	local hex = FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName]
	if type(hex) == "string" and #hex >= 6 then
		local r = (tonumber(hex:sub(1, 2), 16) or 0) / 255
		local g = (tonumber(hex:sub(3, 4), 16) or 0) / 255
		local b = (tonumber(hex:sub(5, 6), 16) or 0) / 255
		header.solidBannerTexture:SetColorTexture(r, g, b, 0.4)
		header.solidBannerTexture:Show()
	else
		-- No custom banner. With EllesmereUI colours available the group gets the house
		-- band -- which is what makes a group read as a band rather than as one more row
		-- -- and without them it stays hidden exactly as before, so Blizzard's own header
		-- art is untouched on a plain client.
		local theme = FG_EUITheme()
		if theme then
			local c = theme.headerBanner
			header.solidBannerTexture:SetColorTexture(c[1], c[2], c[3], c[4])
			header.solidBannerTexture:Show()
		else
			header.solidBannerTexture:Hide()
		end
	end

	-- After the label colour and banner are settled, so the count can inherit both.
	FG_ApplyHeaderCount(header, countText)

	FG_InstallHeaderClickTakeover(header)
end

local function FG_ApplyToVisibleCards(view)
	local scrollBox = view and view.ScrollBox
	if not scrollBox or type(scrollBox.ForEachFrame) ~= "function" then return end

	scrollBox:ForEachFrame(function(frame)
		if type(frame) ~= "table" then return end

		-- Headers carry ButtonText and no FriendName; spacers carry neither. The element
		-- data is a tree NODE here, not a bare table, so it is unwrapped before reading.
		if frame.ButtonText and not frame.FriendName then
			local data = frame.GetElementData and frame:GetElementData()
			if data and type(data.GetData) == "function" then data = data:GetData() end
			if data and data.groupName then
				FG_ApplyHeaderDecoration(frame, data.groupName, data.headerCount)
			end
			return
		end

		if not frame.fgSocialCardHooked and type(frame.InitializeDisplay) == "function" then
			hooksecurefunc(frame, "InitializeDisplay", FG_ApplySocialCardContent)

			-- [[ KNOWN-ALTS PANEL ]]
			-- The card owns its tooltip: ShowTooltip does SetOwner(self, "ANCHOR_RIGHT")
			-- and HideTooltip tears it down. Post-hooking the pair on the frame gives the
			-- alt panel the same row-anchored hover the legacy list has.
			--
			-- Only ShowTooltip needs a partner: hiding is already handled, because
			-- HideTooltip calls GameTooltip:Hide, which FriendGroups hooks -- and that hook
			-- keeps the panel up while the pointer is still over the contact panel, which is
			-- the anti-flicker behaviour.
			if type(frame.ShowTooltip) == "function" then
				hooksecurefunc(frame, "ShowTooltip", FG_OnCardShowTooltip)
			end

			-- The card's own HideTooltip is the precise "pointer left THIS row" signal.
			-- The GameTooltip:Hide hook cannot serve here: its anti-flicker guard suppresses
			-- the hide whenever the pointer is anywhere over the contact panel, which on the
			-- Social UI is true for every row -- so the alt panel would latch on screen and
			-- never clear, which is exactly what happened.
			if type(frame.HideTooltip) == "function" then
				hooksecurefunc(frame, "HideTooltip", FG_OnCardHideTooltip)
			end

			frame.fgSocialCardHooked = true
		end

		FG_ApplySocialCardContent(frame)
	end)
end

-- ============================================================================
-- [[ GROUP FILTER ]]
-- The Groups submenu FriendGroups adds to Blizzard's Filter dropdown, alongside its own
-- Status and Tags.
--
-- SESSION STATE, deliberately not a saved variable. Blizzard's own filter options live on
-- the view and reset with the UI, and a list that comes back filtered after a reload --
-- with the only indicator buried two levels inside a dropdown -- reads as "my friends are
-- missing", which is the worst kind of bug to be on the receiving end of.
--
-- Empty means unfiltered. Ticking nothing is the same as ticking everything, which is how
-- every filter of this shape behaves, Blizzard's included.
local FG_GroupFilter = {}

-- The group names of the last render, in the order they appeared on screen. Captured from
-- the buckets BEFORE any filtering, so a group hidden by the filter is still listed in the
-- menu -- otherwise ticking one group would make every other group unreachable.
local FG_LastGroupOrder = {}

-- Force a full rebuild NOW, for a change to what should be SHOWN rather than to the roster.
--
-- FriendGroups_RequestListUpdate is the wrong call here and was a real bug: it defers to
-- FriendGroups_FriendsListUpdate(false), whose `rosterUnchanged` shortcut returns
-- immediately on the Social UI path when no friend has come or gone. Ticking a filter box
-- never changes the roster, so every checkbox -- Blizzard's Status and Tags as well as our
-- own Groups -- silently did nothing. The live search box already knew this and forces.
--
-- Reached through State, NOT as a global: FriendGroups_FriendsListUpdate is a file-local of
-- FriendGroups.lua, and a bare global reference here resolves to nil in silence.
local function FG_ForceListRebuild()
	State = State or addonTable.State
	if State and type(State.FriendsListUpdate) == "function" then
		State.FriendsListUpdate(true)
	end
end

local function FG_GroupFilterActive()
	return next(FG_GroupFilter) ~= nil
end

local function FG_GroupPassesFilter(groupName)
	if not FG_GroupFilterActive() then return true end
	return FG_GroupFilter[groupName] == true
end

-- ============================================================================
-- [[ NATIVE FILTER CHECKBOXES ]]
-- The Filter dropdown's Status and Tags boxes are Blizzard's, and they worked by
-- re-running the whole search: OnSearchEnterPressed composes the ticked options and
-- hands them to the server, then rebuilds the provider from the result. Read from the
-- 12.1 source:
--
--   function FriendsListSocialViewMixin:OnSearchEnterPressed(text)
--       local activeSearchInfo = self:BuildActiveSearchInfo();
--       activeSearchInfo.searchText = text or "";
--       local friendsData = C_BattleNet.SearchFriends(activeSearchInfo);
--       self.ScrollBox:SetDataProvider(self:GenerateDataProvider(friendsData), ...);
--   end
--
-- Because FriendGroups re-asserts its own grouped provider over the top, that rebuild was
-- discarded and ticking a box did nothing -- a native control we silently broke.
--
-- The fix reuses Blizzard's own machinery rather than reimplementing presence and tag
-- predicates: BuildActiveSearchInfo composes the ticked options, and C_BattleNet
-- .SearchFriends returns a plain ARRAY OF FRIEND INDICES (confirmed in
-- InsertFriendsIntoDataProvider, which does `for _, friendIndex in ipairs(friendsData)`).
-- Those indices are the same index space as element.id, so honouring the filter is a set
-- membership test during the build.
--
-- Called ONCE per rebuild, never per keystroke -- the plan's standing rule about
-- SearchFriends. When nothing is ticked this returns nil before making any call at all,
-- so the unfiltered path is exactly what it was.
local function FG_BuildFilterAllowSet(view)
	if not view or type(view.BuildActiveSearchInfo) ~= "function" then return nil end
	-- Routed through Compat.SearchFriends below, which owns the presence check AND the
	-- forbidden latch. This path only runs with the Social UI live, which is where the call
	-- is expected to be allowed -- but "expected" is what produced an error per keystroke on
	-- the other call site, so it goes through the same door.
	if Compat.IsSearchFriendsForbidden() then return nil end

	local ok, searchInfo = pcall(view.BuildActiveSearchInfo, view)
	if not ok or type(searchInfo) ~= "table" then return nil end

	-- BuildActiveSearchInfo returns every flag false and an empty tags table when nothing
	-- is ticked, so "any filter active" is exactly this test.
	local active = searchInfo.isOnline or searchInfo.isOffline or searchInfo.isDND
		or searchInfo.isAFK or searchInfo.isInQueue or searchInfo.isAvailableForQueue
		or (type(searchInfo.tags) == "table" and #searchInfo.tags > 0)
	if not active then return nil end

	-- The search TEXT is deliberately cleared. FriendGroups filters live from its own
	-- matcher -- notes, groups, nicknames, realm, class, known alts, guild -- and none of
	-- that is visible to the server. Passing the same string here as well would AND the two
	-- and drop every row that matched on something only we can see.
	searchInfo.searchText = ""

	local friendsData = Compat.SearchFriends(searchInfo)
	if not friendsData then return nil end

	local allowed = {}
	for _, friendIndex in ipairs(friendsData) do
		allowed[friendIndex] = true
	end
	return allowed
end

-- ============================================================================
-- [[ RENDERER ]]
-- Consumes the flat layout array FriendGroups_FriendsListUpdate builds (dividers
-- followed by their members, already sorted) and rebuilds it as the tree the Social
-- UI's ScrollBox expects.
--
-- Skipped element types, deliberately:
--   FRIENDS_BUTTON_TYPE_INVITE      -- Battle.net friend invites are their own tab in
--                                      12.1 (SocialUITabType.FriendRequests), rendered
--                                      by FriendRequestsListTemplates; they are not
--                                      cards and would not initialise as one.
--   FRIENDS_BUTTON_TYPE_WOW         -- legacy C_FriendList character friends. Blizzard's
--                                      own generator (InsertFriendsIntoDataProvider)
--                                      walks C_BattleNet.GetFriendAccountInfo only, and
--                                      FriendsListSocialCardMixin reads elementData
--                                      .accountInfo unconditionally, so a legacy friend
--                                      has no valid card representation.
-- ============================================================================
function Compat.RenderSocialUIList(layout)
	State = State or addonTable.State

	local view = Compat.GetSocialUIFriendsView()
	if not view or not view.ScrollBox then return end
	if type(layout) ~= "table" then return end

	-- Presence guards for the two shared-XML symbols this path depends on. Both ship
	-- with the ScrollBox system the Social UI itself is built on, so a client that
	-- reports the Social UI as enabled always has them; the guards exist so a future
	-- reshuffle degrades to "no grouping" instead of erroring on every list refresh.
	if type(CreateTreeDataProvider) ~= "function" then return end
	if type(ScrollBoxConstants) ~= "table" or ScrollBoxConstants.RetainScrollPosition == nil then return end
	if type(TreeDataProviderMixin) ~= "table" or type(TreeDataProviderMixin.Event) ~= "table" then return end

	-- [[ ROW HEIGHT, RETRIED ]]
	-- Compat.InitSocialUI attempts this first, but it runs on PLAYER_ENTERING_WORLD, and the
	-- view's TemplateRegistrations table may not exist that early. By the time a rebuild
	-- reaches here the view has definitely rendered at least once, so the registration is
	-- present -- this is the pass that cannot be too early.
	--
	-- Gated on ACCEPTANCE rather than on having tried, so a failed attempt is retried on the
	-- next rebuild instead of being remembered as done. Re-installing is idempotent (it
	-- assigns the same function to the same field), so the cost of the extra check is one
	-- boolean read per rebuild once it has taken.
	if not cardHeightInstalled then
		cardHeightInstalled = FG_InstallCardHeightOverride(view)
	end

	local provider = CreateTreeDataProvider()

	-- Nil unless a Status or Tags box is ticked, in which case it is the set of friend
	-- indices Blizzard's own search allows through.
	local allowSet = FG_BuildFilterAllowSet(view)

	-- [[ BUCKET, THEN EMIT ]]
	-- The layout is walked into per-group buckets first and only turned into nodes
	-- afterwards. A tree node's header has to be inserted BEFORE its children, but with a
	-- filter active the header's count -- and whether the group should appear at all --
	-- are not known until its members have been tested. Buffering is what lets both be
	-- decided from the survivors, and it also means each friend's account info is fetched
	-- exactly once, as the single-pass version did.
	local buckets = {}
	local currentBucket = nil

	for i = 1, #layout do
		local element = layout[i]
		local buttonType = element and element.buttonType

		if buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
			local groupName = element.groupName
			if type(groupName) == "string" and groupName ~= "" then
				currentBucket = { groupName = groupName, members = {}, online = 0 }
				buckets[#buckets + 1] = currentBucket
			end

		elseif buttonType == FRIENDS_BUTTON_TYPE_BNET and currentBucket then
			-- Native Status/Tags filter, tested before the account info is even read so a
			-- filtered-out friend costs nothing beyond one table lookup.
			local allowed = (allowSet == nil) or allowSet[element.id]

			-- Re-read the account info at build time rather than carrying a cached table
			-- through the layout, matching what Blizzard's own generator does on every
			-- refresh. element.id is the Battle.net friend index, the same value
			-- C_BattleNet.GetFriendAccountInfo takes.
			local accountInfo = allowed and C_BattleNet.GetFriendAccountInfo(element.id) or nil
			if accountInfo then
				-- [[ NOTE DSL CONTAINMENT ]]
				-- Blizzard's card tooltip prints accountInfo.note verbatim, which would put
				-- the addon's own grammar -- @[nickname] and #group -- on screen as raw text.
				-- That tooltip is built by a LOCAL function in Blizzard_FriendsFrame, so it
				-- cannot be hooked; the note is cleaned at the source instead.
				--
				-- Safe to mutate: C_BattleNet.GetFriendAccountInfo returns a freshly built
				-- table on every call, and this one is ours alone -- the group parser runs
				-- off its own separate fetch in FriendGroups_FriendsListUpdate.
				--
				-- FriendGroups_NoteForDisplay is the same function every other surface uses,
				-- so what Blizzard's tooltip shows now matches the row and the alt tooltip
				-- by construction rather than by a parallel rule that could drift.
				if type(accountInfo.note) == "string" then
					accountInfo.note = FriendGroups_NoteForDisplay(accountInfo.note)
				end

				-- friendIndex/accountInfo are what Blizzard's card reads. id/buttonType are
				-- the legacy element shape, carried so FriendGroups' own row-level code --
				-- FriendGroups_ShowButtonAltTooltip in particular -- accepts the card
				-- directly without a translation layer.
				--
				-- The TIER matters and must not be flattened to BNET. A 12.1 title friend is
				-- the successor to a C_FriendList character friend, so it carries
				-- FRIENDS_BUTTON_TYPE_WOW -- which is exactly what stops the known-alts panel
				-- opening for someone who has no Battle.net account to track alts against, and
				-- what makes every other tier-aware branch in the addon behave as it does on
				-- 12.0.7 for a character friend.
				local rowType = Compat.IsTitleFriend(accountInfo)
					and FRIENDS_BUTTON_TYPE_WOW
					or FRIENDS_BUTTON_TYPE_BNET

				currentBucket.members[#currentBucket.members + 1] = {
					friendIndex = element.id,
					accountInfo = accountInfo,
					id = element.id,
					buttonType = rowType,
				}

				-- Counted the way Blizzard counts a filtered list: its own
				-- InsertFriendsIntoDataProvider zeroes the totals and recounts from the
				-- search result, reading gameAccountInfo.isOnline exactly like this.
				local gameInfo = accountInfo.gameAccountInfo
				if gameInfo and gameInfo.isOnline then
					currentBucket.online = currentBucket.online + 1
				end
			end
		end
	end

	-- Menu source for the Groups submenu, captured unfiltered so every group stays
	-- reachable once one of them is ticked.
	wipe(FG_LastGroupOrder)
	for i = 1, #buckets do
		FG_LastGroupOrder[#FG_LastGroupOrder + 1] = buckets[i].groupName
	end

	local isFirstGroup = true
	for i = 1, #buckets do
		local bucket = buckets[i]

		-- Two independent filters decide whether a group is drawn:
		--
		-- The GROUP filter drops the whole group when other groups are ticked and this one
		-- is not. The native STATUS/TAGS filter drops a group every member of which was
		-- filtered out, rather than leaving an empty header -- which is what Blizzard's own
		-- TryInsertFriendsSubTree does when a subtree total reaches zero.
		--
		-- With neither active nothing is suppressed, so "Hide Empty Groups" remains the
		-- only thing deciding whether an empty group is drawn.
		local groupAllowed = FG_GroupPassesFilter(bucket.groupName)
		local hasSurvivors = (allowSet == nil) or (#bucket.members > 0)

		if groupAllowed and hasSurvivors then
			-- Blizzard separates its own two subtrees with a root-level spacer.
			-- Mirrored so grouped output sits at the same rhythm as the native list.
			if not isFirstGroup then
				provider:Insert({ isSpacer = true })
			end
			isFirstGroup = false

			-- The header count is overridden only while filtering, where the group's real
			-- membership is not what is on screen.
			local headerCount
			if allowSet ~= nil then
				headerCount = FG_BuildHeaderCount(bucket.groupName, bucket.online, #bucket.members)
			else
				headerCount = FG_BuildHeaderCount(bucket.groupName)
			end

			-- groupName and headerCount ride alongside headerText. headerText is the LABEL
			-- alone -- Blizzard's factory reads only that, and writes it into a left-aligned
			-- fontstring -- while the count is drawn separately, right-aligned, by
			-- FG_ApplyHeaderDecoration. The extra fields are free: the factory ignores them.
			local headerNode = provider:Insert({
				headerText = FG_BuildHeaderText(bucket.groupName),
				headerCount = headerCount,
				groupName = bucket.groupName,
			})

			-- Seed the saved collapse state BEFORE the children go in.
			-- SetCollapsed(collapsed, affectChildren, skipInvalidate): children are
			-- left alone (they are leaf cards, not subtrees) and invalidation is
			-- skipped because the provider is still detached from the ScrollBox and
			-- about to be handed over whole.
			local collapsed = false
			if type(FriendGroups_SavedVars) == "table"
				and type(FriendGroups_SavedVars.collapsed) == "table"
				and FriendGroups_SavedVars.collapsed[bucket.groupName] then
				collapsed = true
			end
			headerNode:SetCollapsed(collapsed, false, true)

			-- Blizzard opens every subtree with a spacer child; matched for parity.
			headerNode:Insert({ isSpacer = true })

			for m = 1, #bucket.members do
				headerNode:Insert(bucket.members[m])
			end
		end
	end

	-- No collapse reconcile is registered here any more. Collapse now travels one way only:
	-- the header's click handler writes FriendGroups_SavedVars.collapsed and rebuilds, and
	-- the build seeds each node from it. An OnSizeChanged callback writing node state back
	-- into the same variable would make two writers for one fact, and the click handler's
	-- "Auto Collapse Groups" pass could be undone by whichever fired last.
	FG_SocialProvider = provider
	view.ScrollBox:SetDataProvider(provider, ScrollBoxConstants.RetainScrollPosition)

	-- Blizzard's element factory has just initialised the visible cards with its own text.
	-- Apply the FriendGroups display settings over the top, and hook each frame so a
	-- recycle re-applies them. Runs after SetDataProvider so the frames exist and are bound.
	FG_ApplyToVisibleCards(view)

	-- The online total is recomputed by the rebuild that produced this layout, so refresh
	-- the title here too -- RefreshTitle alone only fires on tab changes.
	FG_UpdateContactCounter(view)

	-- [[ ELLESMEREUI WIDGET PASS ]] the chrome around the list -- Add New Friend, the
	-- search field, the filter dropdown, the panel's labels -- through EllesmereUI's own
	-- primitives. Raised from here rather than once at init because these widgets are
	-- built lazily and some do not exist until the panel has been shown. The primitives
	-- are documented as idempotent, so a re-call on an already-skinned frame costs one
	-- table lookup, and the pass simply does nothing when EllesmereUI is absent.
	local skin = _G.FriendGroupsEUISkin
	if skin and type(skin.SkinSocialWidgets) == "function" then
		skin.SkinSocialWidgets(view)
	end

	-- Retried here as well as at init. The dropdown's own OnLoad has to have run for
	-- menuGenerator to exist, and if it had not by the time InitSocialUI fired there would
	-- otherwise be no second attempt for the rest of the session. Guarded by a flag on the
	-- dropdown, so the repeat costs one field read.
	FG_HookFilterDropdown(view)
end

-- ============================================================================
-- [[ PROVIDER RE-ASSERT ]]
-- Direct counterpart of FriendGroups_ReassertGroupedProvider on the legacy path, and
-- for the same reason: FriendsListSocialViewMixin:Refresh installs its own flat-ish
-- provider, so ours is swapped back inside the same execution, before anything renders.
-- ============================================================================
-- True once a grouped provider has been built and installed at least once this session.
-- FriendGroups_FriendsListUpdate consults this before taking its "roster unchanged, nothing
-- to do" shortcut: the very first build can be deferred (opening the list while in combat
-- queues it), and without this the queued rebuild would find a clean roster and return
-- without ever installing the grouped provider.
function Compat.HasSocialUIProvider()
	return FG_SocialProvider ~= nil
end

function Compat.ReassertSocialUIProvider()
	if not FG_SocialProvider then return end

	local view = Compat.GetSocialUIFriendsView()
	if not view or not view.ScrollBox then return end
	if type(ScrollBoxConstants) ~= "table" or ScrollBoxConstants.RetainScrollPosition == nil then return end
	if view.ScrollBox:GetDataProvider() == FG_SocialProvider then return end

	view.ScrollBox:SetDataProvider(FG_SocialProvider, ScrollBoxConstants.RetainScrollPosition)

	-- The swap re-initialises the visible cards from Blizzard's factory, wiping our text.
	FG_ApplyToVisibleCards(view)
end

-- ============================================================================
-- [[ ROW CONTENT ]]
-- The Social UI card carries five display strings: FriendName (the account identity),
-- then Name / Level / Class on one line, then Location. Blizzard fills all five from
-- FriendsListUtil in FriendsListSocialCardMixin:InitializeCardDisplayText.
--
-- This runs afterwards and re-states the ones FriendGroups has an opinion about, so the
-- user's display settings apply to the native card. Blizzard's own values are left in
-- place wherever FriendGroups has nothing to add -- every override below is conditional,
-- so a disabled setting means Blizzard's text simply survives untouched.
--
-- Row GEOMETRY is deliberately not touched here: the card keeps Blizzard's height and
-- anchoring, and LayoutScaledContent is re-run at the end so their layout pass sees our
-- strings. Retail's denser row is a later step.
-- ============================================================================

-- [[ ROW DENSITY ]]
-- Blizzard's card is 70px (85 at large text scale) laid out over three text rows: the
-- account name, then character/level/class, then location. Retail FriendGroups packs the
-- same information into ONE rich line, with the note beneath it, and is far denser.
--
-- These two values are the tuning knobs for that. They are BASE heights: the extent
-- previewer still scales them through TextSizeManager using the card template's own
-- scaleWeight, so large-text users keep working rows.
-- Retail's own friend row is FRIENDS_FRAME_FRIEND_HEIGHT = 34 and fits BOTH lines in it.
-- These match that rather than Blizzard's roomier card, which is the whole point of the
-- exercise: a long contact list has to stay scannable.
local FG_CARD_HEIGHT_COMPACT = 24    -- one rich line
local FG_CARD_HEIGHT_WITH_NOTE = 34  -- rich line plus the second line, as retail

-- Inline icon size, in the same units the row's font uses.
local FG_ROW_ICON_SIZE = 14

-- Bounds for the presence-dot column. 16 is retail's own STATUS_W; the ceiling exists so a
-- dot measured off a mis-sized card can never claim the name's width (see the status block
-- in FG_ApplySocialCardContent).
local FG_STATUS_MIN_WIDTH = 16
local FG_STATUS_MAX_WIDTH = 24

-- The text column never gets less than this share of the row, whatever the icon gutters
-- would otherwise claim. A last-resort floor, not a layout rule: every gutter above it is
-- derived from the row height, so a wrong row height would otherwise push the name off the
-- card entirely rather than merely making it look odd.
--
-- Set LOW on purpose. At 0.5 it engaged on a legitimate combination -- Large text in a
-- narrow panel -- and quietly shaved the right-hand reserve, which is the one gutter that
-- must not shrink, since it is what keeps the name clear of Blizzard's game and faction
-- icons. At 0.4 every legitimate configuration clears it untouched and only a genuinely
-- broken row height reaches it.
local FG_MIN_TEXT_SHARE = 0.4

-- Gap between the name and the second line. Named because the row-centring maths has to
-- budget for the same value the anchor uses; two literals would drift apart.
local FG_ROW_LINE_GAP = 2

-- Nickname tint, matching the retail rows (pure green). Built as a color object rather
-- than an escape-sequence literal so the markup is generated, never hand-written.
local FG_NICKNAME_COLOR = CreateColor(0, 1, 0)

-- Opposing-faction dim, matching the exact grey the retail rows use (0x949694) rather
-- than the near-miss shared DISABLED_FONT_COLOR, so both platforms look identical.
local FG_DIM_COLOR = CreateColor(148 / 255, 150 / 255, 148 / 255)

-- [[ ROW FONT SCALE ]]
-- Indexed by FriendGroups_GetFontScale(): 1 Small, 2 Medium, 3 Large.
--
--   fontDelta      added to Blizzard's PRISTINE size for the string, never to the current one
--   compactHeight  row height with one text line
--   noteHeight     row height with the note line as well
--
-- Medium is the historical behaviour to the point: delta -1 and the two base heights above
-- verbatim, which is what FG_ShrinkFont did unconditionally before this setting existed. So
-- a user who never opens the menu sees no change at all.
--
-- The height has to move with the font or the row clips: it is a fixed extent, not a frame
-- that grows to fit its text.
--
-- HEIGHTS ARE EXPLICIT, NOT A MULTIPLIER, and that is the whole point. A proportional
-- heightScale was tried first and made Small clip. The text block is anchored to the TOP of
-- the card by FIXED insets -- 4px above the name, 2px between the lines -- so only the glyph
-- rows scale with the font while the padding does not. Multiplying the whole row therefore
-- moved it FASTER than its contents in both directions: Small lost 4px of row to reclaim
-- 2.3px of text and clipped, Large gained 7px to spend 4.6px and just looked loose. Each
-- step now carries the height its own font size actually needs.
--
-- Small is the tight one and is the reason these are tuned rather than derived: a 1pt drop
-- across two lines is worth about 2px, so it takes 2 off the row and no more. CJK glyphs are
-- taller than Latin at equal point size and are what run out of room first, so any retune
-- has to be checked against a contact whose name or note is CJK, not against Latin alone.
local FG_FONT_SCALE_STEPS = {
	[1] = { fontDelta = -2, compactHeight = FG_CARD_HEIGHT_COMPACT - 1, noteHeight = FG_CARD_HEIGHT_WITH_NOTE - 2 },
	[2] = { fontDelta = -1, compactHeight = FG_CARD_HEIGHT_COMPACT,     noteHeight = FG_CARD_HEIGHT_WITH_NOTE     },
	[3] = { fontDelta =  1, compactHeight = FG_CARD_HEIGHT_COMPACT + 5, noteHeight = FG_CARD_HEIGHT_WITH_NOTE + 7 },
}

local function FG_FontScaleStep()
	local n = 2
	if type(FriendGroups_GetFontScale) == "function" then
		n = FriendGroups_GetFontScale()
	end
	return FG_FONT_SCALE_STEPS[n] or FG_FONT_SCALE_STEPS[2]
end

-- Row height. Uniform across the list, exactly as Blizzard's own GetActiveBaseHeight is:
-- the extent previewer asks once per cache fill and has no row to inspect, so the note line
-- is budgeted whenever the setting is on rather than per friend.
local function FG_GetCardBaseHeight()
	local step = FG_FontScaleStep()
	if type(FriendGroups_SavedVars) == "table" and FriendGroups_SavedVars.show_note then
		return step.noteHeight
	end
	return step.compactHeight
end

-- Drop the cached template extents so the next layout re-derives the row height through
-- FG_GetCardBaseHeight. Raised by FriendGroups_SetFontScale, which then forces the rebuild.
function Compat.OnFontScaleChanged()
	local view = Compat.GetSocialUIFriendsView()
	if view and type(view.ClearTemplateExtentCache) == "function" then
		view:ClearTemplateExtentCache()
	end
end

-- Height is taken WITHOUT owning the ScrollBox view. GetTemplateExtent always recalculates
-- a cleared cache from TemplateRegistrations, so replacing the card template's
-- baseHeightCalculator is permanent: Blizzard's own ClearTemplateExtentCache on every
-- Refresh and OnShow re-derives through our function. That avoids re-initialising the view,
-- which would also mean taking over the element factory, the extent calculator and the
-- selection behaviour -- an all-or-nothing change that fails to a blank list.
FG_InstallCardHeightOverride = function(view)
	if not view or type(view.TemplateRegistrations) ~= "table" then return false end

	local registration = view.TemplateRegistrations["FriendsListSocialCardTemplate"]
	if type(registration) ~= "table" then return false end

	registration.baseHeightCalculator = FG_GetCardBaseHeight
	if type(view.ClearTemplateExtentCache) == "function" then
		view:ClearTemplateExtentCache()
	end
	return true
end

-- [[ CLASS ICON ]]
-- A real texture at retail's geometry, not inline markup: the retail row sizes its class
-- icon to the ROW HEIGHT (minus 4) and anchors it LEFT +4, then reserves a matching left
-- gutter for the text. Inline markup can only ever be font-sized, so it could not match.
--
-- Every number and the atlas/TexCoord fallback here are lifted from the retail renderer so
-- both platforms draw an identical icon. Returns the left gutter the text must clear.
--
-- [[ THE GUTTER IS RESERVED BY THE SETTING, NOT BY THE LOOKUP ]]
-- "Class icons are on" and "this friend's class is known" are two different questions, and
-- collapsing them into one branch is what made offline rows sit five pixels left of online
-- ones. class comes from gameAccountInfo.className, which is absent for EVERY row without a
-- live WoW session -- offline friends, app/mobile friends, friends in another Blizzard game
-- -- so those rows lost the gutter entirely and both text lines slid under the icon column.
--
-- FriendGroups_ApplyRowLayout has always had this right on the legacy list: it derives
-- leftPad from show_class_icons alone and lets the token decide only Show vs Hide. This is
-- that structure, so the two platforms now indent identically.
local function FG_UpdateClassIcon(card, class, iconSize, desaturated)
	if not card.fgClassIcon then
		card.fgClassIcon = card:CreateTexture(nil, "ARTWORK", nil, 2)
	end
	local icon = card.fgClassIcon

	local showIcons = not (FriendGroups_SavedVars.show_class_icons == false)
	local token
	if showIcons and class and class ~= "" then
		token = State and type(State.ResolveClassToken) == "function"
			and State.ResolveClassToken(class) or nil
	end

	-- Retail's own two values, and now literally the same expression the legacy renderer uses.
	-- The presence dot no longer needs to be measured here: it used to straddle the row's
	-- top-left corner, so the text had to clear it, but it is now re-anchored into its own
	-- reserved column to the RIGHT of this gutter (see the status block in
	-- FG_ApplySocialCardContent), exactly as retail has always laid the row out.
	local iconGutter = showIcons and (iconSize + 8) or 6

	-- Either no icons at all, or no class to draw for this row. Both hide the texture; only
	-- the first gives the space back. Keeping the column reserved in the second case is what
	-- lines an offline (or app/mobile) row up with its neighbours -- both text lines hang off
	-- this one value, since Location anchors to FriendName.
	if not token then
		icon:Hide()
		return iconGutter
	end

	icon:ClearAllPoints()
	icon:SetPoint("LEFT", card, "LEFT", 4, 0)
	icon:SetSize(iconSize, iconSize)

	local atlas = GetClassAtlas and GetClassAtlas(token)
	if atlas then
		icon:SetTexCoord(0, 1, 0, 1)
		icon:SetAtlas(atlas)
	else
		icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
		local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[token]
		if coords then icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]) end
	end

	-- Greyed when the class describes the contact's SELECTED MAIN rather than the character
	-- they are on right now, which is the only way an offline row gets an icon at all. Always
	-- re-stated, never toggled only on: these textures are pooled, so a row recycled from an
	-- offline contact onto a live one would otherwise keep the grey.
	icon:SetDesaturated(desaturated and true or false)
	icon:SetAlpha(desaturated and 0.6 or 1)
	icon:Show()

	return iconGutter
end

-- ============================================================================
-- [[ ROW FONT SIZE, AND THE CJK TOFU BUG ]]
--
-- SetFont takes ONE file. Blizzard's font OBJECTS carry a fallback list, and GetFont reports
-- whichever file of that list the text currently in the string actually needs -- measured with
-- /fg font, on one object, on two rows:
--
--   洛特瑞      obj=UserScaledFontHeader  file=ARKai_T.ttf
--   [No Group]  obj=UserScaledFontHeader  file=FRIZQT__.TTF
--
-- The old code captured that file ONCE per pooled card and re-applied it forever. So each
-- card was permanently branded with whichever script it happened to draw first, and a CJK
-- name later recycled onto a card branded FRIZQT__ rendered as boxes. It looked stable
-- whenever the list fitted on screen (cards map 1:1 to rows and never get reused) and broke
-- the moment you scrolled -- which is exactly how it was finally reproduced.
--
-- So the file is now resolved PER SCRIPT rather than per card, and the cache is shared: the
-- first row of a given script to be measured teaches every card the file for that script.
--
-- SIZE is still cached per card, and must be: it is the one value that cannot be re-read
-- safely. Reading a size back after our own SetFont returns the SHRUNK size, and feeding
-- that in again compounds the reduction until the text disappears -- the original bug this
-- function was written to fix.
-- ============================================================================

-- [fontObjectName/script] = the file Blizzard's object resolved to for that script. Shared
-- across every card deliberately; per-card was the bug.
local FG_ScriptFontFile = {}

-- Only two classes matter here: text that a Latin file can draw, and text that needs the
-- locale's wide-glyph file. Any byte >= 128 means the latter.
local function FG_TextScript(text)
	if type(text) == "string" and text:find("[\128-\255]") then return "wide" end
	return "ascii"
end

local function FG_ShrinkFont(card, fontString, key)
	if not fontString then return end

	card.fgBaseFont = card.fgBaseFont or {}
	local base = card.fgBaseFont[key]

	if not base then
		-- First pass for this region is the one moment nothing of ours has been applied, so
		-- both the size and the file are Blizzard's own. The OBJECT is kept as well: it
		-- survives our SetFont (verified -- /fg font still reports the object on rows we have
		-- already shrunk) and is the handle used to re-resolve the file below.
		local path, size, flags = fontString:GetFont()
		if not path or not size then return end
		local object = (type(fontString.GetFontObject) == "function") and fontString:GetFontObject() or nil
		base = { object = object, path = path, size = size, flags = flags }
		card.fgBaseFont[key] = base
	end

	local objectName = (base.object and type(base.object.GetName) == "function" and base.object:GetName()) or "?"
	local script = FG_TextScript(fontString:GetText())
	local scriptKey = objectName .. "/" .. script

	-- Hand the string back to its object, then read what the client resolves for the text
	-- that is in it RIGHT NOW. That is the only moment the correct file for this script is
	-- observable.
	--
	-- The colour is carried across by hand: SetFontObject re-applies the object's colour and
	-- would otherwise discard the name tint applied further up this function.
	if base.object then
		local r, g, b, a = fontString:GetTextColor()
		fontString:SetFontObject(base.object)
		local resolvedPath, resolvedSize = fontString:GetFont()

		-- Trusted ONLY when the size came back to pristine. That is the proof the restore
		-- actually took -- an older comment in this file claimed an explicit SetFont wins over
		-- a later SetFontObject, and rather than take either answer on faith the read is
		-- validated before it is believed. A stale read reports our own shrunk size, and its
		-- path would mean nothing.
		if resolvedPath and resolvedSize and math.abs(resolvedSize - base.size) < 0.5 then
			FG_ScriptFontFile[scriptKey] = resolvedPath
		end
		if r then fontString:SetTextColor(r, g, b, a) end
	end

	local path = FG_ScriptFontFile[scriptKey]
	local flags = base.flags

	-- The EllesmereUI colourise pass overrides the FAMILY only, and it is folded into this one
	-- write rather than applied afterwards: this is the write that runs on every recycle, so a
	-- second pass would simply be undone by the next one.
	local theme = FG_EUITheme()
	if theme and theme.fontPath then
		path = theme.fontPath
		if theme.fontFlag ~= nil then flags = theme.fontFlag end
	end

	-- No file known for this script yet -- which can only happen if no row of it has ever been
	-- measured pristine. Leave the string on its object rather than pinning a file that cannot
	-- draw it: the row renders at Blizzard's size instead of the chosen one, which is a
	-- cosmetic difference, where guessing would be a row of boxes.
	if not path then return end

	-- Derived from the captured baseline plus the user's scale, never from the current size,
	-- so this stays idempotent no matter how many times the row is recycled. Floored at 6pt:
	-- below that the text is unreadable, and SetFont rejects a size of zero outright.
	local size = base.size + FG_FontScaleStep().fontDelta
	if size < 6 then size = 6 end

	fontString:SetFont(path, size, flags)
end

-- [[ RIGHT-SIDE ICON CLUSTER ]] faction icon then realm flag, marching leftwards from
-- Blizzard's game icon exactly as retail marches them leftwards from its own:
--   facIcon    sized to the game icon,        anchored RIGHT -> gameIcon LEFT
--   realmFlag  sized to 0.75 of the game icon, anchored RIGHT -> facIcon LEFT (-1),
--              or straight onto the game icon when no faction icon is shown
-- Returns the width the text must keep clear on the right, built the same way retail
-- accumulates its rightReserve so toggling an icon off gives the width back to the text.
local function FG_UpdateRightIcons(card, gameInfo, iconSize)
	local gameIcon = card.GameIconHolder
	if not gameIcon then return 31 end

	-- Every row icon is driven from the SAME size as the class icon so the four of them
	-- match and all track the Contact List Size setting together. Blizzard pins its game
	-- icon holder to a fixed 20x20 in XML, so it is resized here too; its .Icon is
	-- setAllPoints, so the texture follows.
	local iconW, iconH = iconSize, iconSize
	gameIcon:SetSize(iconSize, iconSize)

	-- [[ SHOW GAME ICON ]] Blizzard's InitializeGameIcon decides this frame's visibility from
	-- its own rules and re-runs before us on every initialise, so the user's setting is
	-- applied here, afterwards. Retail does three things when the icon is off -- hides it,
	-- drops it from the right reserve, and lets the faction icon / realm flag take over its
	-- slot so the text reclaims the width -- and all three are mirrored below.
	local showGameIcon = not (FriendGroups_SavedVars.show_game_icon == false)
	if not showGameIcon then
		gameIcon:Hide()
	end

	if not card.fgFacIcon then
		card.fgFacIcon = card:CreateTexture(nil, "ARTWORK", nil, 2)
	end
	if not card.fgRealmFlag then
		card.fgRealmFlag = card:CreateTexture(nil, "ARTWORK", nil, 2)
	end
	local facIcon, realmFlag = card.fgFacIcon, card.fgRealmFlag

	local facPath = ""
	if FriendGroups_SavedVars.show_faction_icons and gameInfo then
		facPath = FriendGroups_GetFactionIcon(gameInfo.factionName) or ""
	end
	local facShown = (facPath ~= "")
	if facShown then
		facIcon:SetSize(iconW, iconH)
		facIcon:ClearAllPoints()
		-- With the game icon hidden its slot is free, so the faction icon takes it by
		-- anchoring to that frame's RIGHT edge instead of its LEFT -- retail's own trick.
		facIcon:SetPoint("RIGHT", gameIcon, showGameIcon and "LEFT" or "RIGHT", 0, 0)
		facIcon:SetTexture(facPath)
		facIcon:Show()
	else
		facIcon:Hide()
	end

	local flagPath
	if FriendGroups_SavedVars.show_flags and gameInfo then
		flagPath = FriendGroups_GetRealmInfo(gameInfo)
	end
	local flagShown = (type(flagPath) == "string" and flagPath ~= "")
	if flagShown then
		realmFlag:SetSize(iconW, iconH)
		realmFlag:ClearAllPoints()
		if facShown then
			realmFlag:SetPoint("RIGHT", facIcon, "LEFT", -1, 0)
		else
			realmFlag:SetPoint("RIGHT", gameIcon, showGameIcon and "LEFT" or "RIGHT", 0, 0)
		end
		realmFlag:SetTexture(flagPath)
		realmFlag:Show()
	else
		realmFlag:Hide()
	end

	-- Retail's base reserve is 31 (invite button plus margins); the card's party button
	-- occupies the same slot, so it is measured rather than assumed.
	local reserve = 7
	if card.PartyButton then
		local w = card.PartyButton:GetWidth()
		reserve = reserve + ((w and w >= 1) and w or 24) + 4
	else
		reserve = 31
	end
	if showGameIcon then reserve = reserve + iconW + 2 end
	if facShown then reserve = reserve + iconW + 2 end
	if flagShown then reserve = reserve + iconW + 2 end

	return reserve
end

FG_ApplySocialCardContent = function(card)
	FG_RowApplyCalls = FG_RowApplyCalls + 1

	if not Compat.IsSocialUIActive() then return end
	if type(FriendGroups_SavedVars) ~= "table" then return end

	local elementData = card and card.elementData
	local accountInfo = elementData and elementData.accountInfo
	if not accountInfo then return end

	FG_RowApplyApplied = FG_RowApplyApplied + 1
	State = State or addonTable.State

	-- Make the card answer to the legacy row contract. FriendGroups_ShowButtonAltTooltip
	-- reads button.id and button.buttonType off whatever frame it is handed, so stamping
	-- them here lets the hover path below pass the card straight in.
	card.id = elementData.friendIndex
	card.buttonType = elementData.buttonType or FRIENDS_BUTTON_TYPE_BNET

	local gameInfo = accountInfo.gameAccountInfo
	local client, characterName, class, level, realmName

	if gameInfo then
		client = gameInfo.clientProgram
		characterName = gameInfo.characterName
		class = gameInfo.className
		level = gameInfo.characterLevel
		realmName = gameInfo.realmName

		-- 12.0.7 presence reduction leaves className nil for most sessions; FriendGroups
		-- keeps its own cache so class colour and the class icon survive. Same recovery the
		-- retail row renderer performs before building its name text.
		if gameInfo.isOnline and (not class or class == "") and client == BNET_CLIENT_WOW then
			class = FriendGroups_LookupAccountClass(accountInfo, characterName, realmName)
		end

	end

	-- [[ OFFLINE: FALL BACK TO THE SELECTED MAIN ]]
	-- An offline contact has no live class, so their icon column sat empty. When the user has
	-- nominated a main for them, that character's class fills it -- drawn desaturated, because
	-- it describes who they are rather than who they are playing.
	--
	-- Strictly a fallback: `class` above always wins, so a live session is never overridden,
	-- and the flag is what keeps a real class icon from being greyed by mistake.
	local classIsMain = false
	if (not class or class == "") and type(FriendGroups_LookupMainClass) == "function" then
		local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
		local mainClass = accountIdentifier and FriendGroups_LookupMainClass(accountIdentifier)
		if mainClass then
			class = mainClass
			classIsMain = true
		end
	end

	local canCoop = true
	if type(CanCooperateWithGameAccount) == "function" then
		canCoop = CanCooperateWithGameAccount(accountInfo) and true or false
	end

	-- [[ TITLE FRIENDS ]] 12.1's "WoW Friend" tier. Their accountName IS a character name,
	-- so feeding them through the Battle.net builder prints the person twice --
	-- "Lotrui-Anasterian [Puddingpal]". Retail has never done that: a character friend
	-- renders as the bracketed, class-coloured name plus the level suffix, nothing else.
	-- This branch reproduces retail's character-friend row, with the nickname kept because
	-- 12.1 lets these friends carry one.
	local isTitleFriend = false
	if type(FriendsListUtil) == "table" and type(FriendsListUtil.IsTitleFriend) == "function" then
		isTitleFriend = FriendsListUtil.IsTitleFriend(accountInfo) and true or false
	end

	local line
	if isTitleFriend then
		local displayName = characterName or accountInfo.accountName or UNKNOWN

		-- [[ STREAMER MODE ]] This tier is exactly the case the |K escape breaks: offline,
		-- characterName is nil and accountName is the six-byte escape, which cannot be
		-- sliced. FriendGroups_StreamerName falls back to the plain-text name recorded while
		-- the friend was last online, so these rows still reveal three real characters
		-- instead of collapsing to an indistinguishable row of asterisks.
		if FriendGroups_IsStreamerMode and FriendGroups_IsStreamerMode() then
			displayName = FriendGroups_StreamerName(displayName, accountInfo)
		end

		displayName = "[" .. displayName .. "]"
		if FriendGroups_SavedVars.colour_classes and class and class ~= "" then
			displayName = FriendGroups_GetClassColorCode(class) .. displayName .. FONT_COLOR_CODE_CLOSE
		elseif type(FRIENDS_WOW_NAME_COLOR_CODE) == "string" then
			-- Class colours off: a WoW-tier friend takes the pale yellow the default UI has
			-- always used for character friends, rather than inheriting the Battle.net blue of
			-- the surrounding line. That is the one place the two tiers should read apart.
			displayName = FRIENDS_WOW_NAME_COLOR_CODE .. displayName .. FONT_COLOR_CODE_CLOSE
		end

		-- Level rule copied from retail's character-friend branch.
		local levelSuffix = ""
		if level and level ~= 0
			and not (FriendGroups_SavedVars.hide_high_level and Compat.IsMaxLevel(gameInfo, level)) then
			levelSuffix = " " .. level
		end

		local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
		local nickname = accountIdentifier
			and FriendGroups_SavedVars.nicknames
			and FriendGroups_SavedVars.nicknames[accountIdentifier]
		if type(nickname) == "string" and nickname ~= "" then
			line = FG_NICKNAME_COLOR:WrapTextInColorCode(nickname) .. " " .. displayName .. levelSuffix
		else
			line = displayName .. levelSuffix
		end
	else
		-- THE retail line, from the same builder the legacy rows use -- nickname or split
		-- BattleTag, the character in brackets under class colour, the level suffix obeying
		-- hide-max-level, the "aka" main-character tag, and opposing-faction dimming.
		line = FriendGroups_GetBNetButtonNameText(
			accountInfo.accountName, client, canCoop, characterName, class, level,
			accountInfo.battleTag, gameInfo and gameInfo.timerunningSeasonID, realmName, gameInfo) or ""
	end

	if gameInfo then
	end

	card.FriendName:SetText(line)

	-- [[ NAME COLOUR ]] The account name itself carries no colour code -- retail leaves it
	-- to the fontstring's own colour, which is Battle.net blue for an online BNet friend and
	-- grey when offline. FriendsFrame_GetBNetAccountNameAndStatus is Blizzard's own source
	-- for that colour, and is what the retail row renderer reads. The embedded codes inside
	-- the line (character name, level, aka) are unaffected; this only tints the bare account
	-- name, exactly as on retail.
	if type(FriendsFrame_GetBNetAccountNameAndStatus) == "function" then
		local _, nameColor = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo)

		-- [[ ONE COLOUR FOR EVERY TIER ]] 12.1 tints title friends with HIGHLIGHT_FONT_COLOR
		-- (white) to mark them apart from account friends. Retail FriendGroups has always used
		-- FRIENDS_BNET_NAME_COLOR for BOTH Battle.net and character friends -- deliberately, so
		-- the level suffix renders identically and class colour alone conveys the class. That
		-- consistency is kept here: online is blue whatever the tier, offline keeps Blizzard's
		-- grey, and the embedded codes inside the line are untouched.
		local gameInfoForColor = accountInfo.gameAccountInfo
		if gameInfoForColor and gameInfoForColor.isOnline and FRIENDS_BNET_NAME_COLOR then
			nameColor = FRIENDS_BNET_NAME_COLOR
		end

		if nameColor and nameColor.r then
			card.FriendName:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
		end
	end

	-- Everything that line now carries is cleared from Blizzard's other strings. This is
	-- what collapses the card from three text rows to one.
	card.Name:SetText("")
	card.Level:SetText("")
	card.Class:SetText("")

	-- [[ SECOND LINE ]] retail builds location first, then APPENDS the note after two
	-- spaces -- they are shown together, not one or the other:
	--     "Maisara Caverns - Mok'Nathal  #VVIP"
	-- FriendGroups_GetOnlineInfoText is retail's own builder and handles mobile,
	-- Recruit-a-Friend wording, and the " - Realm" suffix under show_realm. That is where
	-- the realm belongs; putting it inside the name brackets overran the single-line name
	-- field and truncated it.
	local secondLine = ""
	if gameInfo and gameInfo.isOnline then
		secondLine = FriendGroups_GetOnlineInfoText(
			client, gameInfo.isWowMobile, accountInfo.rafLinkType,
			gameInfo.areaName, realmName) or ""
	end

	-- show_note defaults ON, so the test is ~= false to match retail's own condition.
	if FriendGroups_SavedVars.show_note ~= false then
		local noteClean = FriendGroups_NoteForDisplay(accountInfo.note)
		if noteClean ~= "" then
			secondLine = (secondLine ~= "") and (secondLine .. "  " .. noteClean) or noteClean
		end
	end
	card.Location:SetText(secondLine)

	-- Blizzard's layout pass, so it measures OUR strings. It only positions regions -- it
	-- never sets text -- so this cannot recurse back into here.
	card:LayoutScaledContent()

	-- [[ TYPE SIZE ]] one step below Blizzard's card, which is set for a roomier row than
	-- ours. The font OBJECT is reinstated before shrinking so repeated applications cannot
	-- compound -- this runs on every recycle, and a relative "size - 1" without the reset
	-- would shave a point off each time until the row was unreadable.
	--
	-- Applied HERE, above the geometry, and that ordering is load-bearing: it used to run at
	-- the end of the row, so the block below was anchoring text whose size had not been set
	-- yet and any measurement of it described the previous recycle's font. Blizzard's pass
	-- above still sees the same fonts it has always seen, since it ran first either way.
	FG_ShrinkFont(card, card.FriendName, "FriendName")
	FG_ShrinkFont(card, card.Location, "Location")

	-- [[ RETAIL ROW GEOMETRY ]] applied AFTER their pass, which would otherwise reinstate
	-- its own three-row anchoring. Every offset below is retail's:
	--   class icon  -> LEFT +4, sized to the row height, claiming a leftPad gutter
	--   status icon -> LEFT at leftPad, widening the text gutter by STATUS_W + 4
	--   text        -> nameLeft to -rightReserve, vertically CENTRED (see below). This is the
	--                  one offset that is NOT retail's: retail hangs the block from a fixed
	--                  -4, which only centres at the single font size it was tuned against.
	--   second line -> directly beneath the name, sharing its right edge
	-- One size drives every icon on the row -- class, status, faction, realm flag and
	-- Blizzard's game icon -- so they match each other and all track the row height, and
	-- therefore the Contact List Size setting. Retail's formula: row height less 4.
	local iconSize = (card:GetHeight() or 0) - 4
	if iconSize <= 0 then iconSize = 16 end

	local leftPad = FG_UpdateClassIcon(card, class, iconSize, classIsMain)

	-- ====================================================================
	-- [[ STATUS COLUMN ]]
	-- The presence dot and the favourite star share ONE reserved column, sitting between the
	-- class icon and the text and vertically centred across both text rows. This is the
	-- arrangement FriendGroups_ApplyRowLayout has always used on the legacy list, ported here
	-- verbatim -- same slot width, same star offsets, same "the star claims the slot even when
	-- the status icon is off" rule.
	--
	-- The previous arrangement left Blizzard's dot where their template puts it (straddling
	-- the row's top-left corner) and badged the star onto it. That put two different things in
	-- the corner where the class icon's own column begins, so the cluster read as clutter and
	-- the text gutter had to be measured around it rather than simply reserved.
	--
	-- Blizzard's own dot is reused rather than replaced -- it already tracks their text
	-- scaling and carries the real presence state -- so this only re-anchors it. card.fgStatus
	-- stays hidden: drawing a second indicator beside theirs was what gave every row two.
	-- ====================================================================
	local showStatus = FriendGroups_SavedVars.show_status ~= false
	local hasStar = card.StateDisplay and card.StateDisplay:IsShown()

	if card.fgStatus then card.fgStatus:Hide() end

	-- Measured, not assumed: the dot is Blizzard's frame and scales with their text setting,
	-- so the slot has to be as wide as whatever they built. 16 is retail's STATUS_W and the
	-- fallback for a frame that has not laid out yet.
	--
	-- CLAMPED, because a measurement is only as good as the frame it came from. When the row
	-- height override loses its race at login the card stays at Blizzard's 70px, the dot
	-- scales with it, and an unclamped slot reserved sixty-odd pixels for an indicator --
	-- which, on top of a class-icon gutter doing the same, left the name nothing but an
	-- ellipsis. A presence dot is a small indicator at any legitimate row height.
	local statusW = card.PresenceHolder and card.PresenceHolder:GetWidth()
	if not statusW or statusW < FG_STATUS_MIN_WIDTH then statusW = FG_STATUS_MIN_WIDTH end
	if statusW > FG_STATUS_MAX_WIDTH then statusW = FG_STATUS_MAX_WIDTH end

	if card.PresenceHolder then
		card.PresenceHolder:SetShown(showStatus)
		card.PresenceHolder:ClearAllPoints()
		-- "LEFT" anchors at the row's vertical middle, so the dot centres across both rows.
		card.PresenceHolder:SetPoint("LEFT", card, "LEFT", leftPad, 0)
	end

	-- [[ FAVOURITE STAR ]] Blizzard lays StateDisplay out on the RIGHT, where it landed on top
	-- of the realm flag. Retail's placement instead: a corner badge on the status icon when
	-- one is shown, or centred in the slot when the star is its only occupant.
	--
	-- BEHIND the dot, which is why the dot is the frame raised here and not the star. The
	-- status is the information you scan the row for; the star is a persistent property you
	-- already know. Putting the star in front covered the thing that changes with the thing
	-- that does not.
	if card.StateDisplay then
		card.StateDisplay:ClearAllPoints()
		if showStatus then
			card.StateDisplay:SetPoint("CENTER", card, "LEFT", leftPad + statusW - 3, 6)
			if card.PresenceHolder then
				card.PresenceHolder:SetFrameLevel(card.StateDisplay:GetFrameLevel() + 1)
			end
		else
			card.StateDisplay:SetPoint("CENTER", card, "LEFT", leftPad + statusW * 0.5, 0)
		end
	end

	-- The text starts clear of the whole column. A visible star claims it even with the status
	-- icon off, so the star can never end up behind the name.
	local nameLeft = leftPad + ((showStatus or hasStar) and (statusW + 4) or 0)
	local rightReserve = FG_UpdateRightIcons(card, gameInfo, iconSize)

	-- [[ THE NAME ALWAYS GETS ROOM ]]
	-- Both gutters are derived from the row height, so if the row height is wrong they are
	-- both wrong in the same direction and the text is what pays. That is not hypothetical:
	-- it is exactly what a mis-sized card produced -- a row of icons with an ellipsis where
	-- the contact used to be.
	--
	-- The gutters are given back proportionally rather than one being zeroed, so the row
	-- degrades into something cramped-but-legible instead of losing a column outright.
	local cardWidth = card:GetWidth() or 0
	if cardWidth > 0 then
		local maxGutters = cardWidth * (1 - FG_MIN_TEXT_SHARE)
		local gutters = nameLeft + rightReserve
		if gutters > maxGutters then
			local scale = maxGutters / gutters
			nameLeft = nameLeft * scale
			rightReserve = rightReserve * scale
		end
	end

	-- [[ VERTICAL CENTRING ]] The text block is centred in the row, not hung from the top by
	-- a fixed inset. With a fixed inset only the TOP margin is a constant -- the bottom is
	-- whatever the row has left over -- so the two matched at one font size and nowhere else,
	-- and the block sat visibly low. Centring makes them equal by construction at every size.
	--
	-- Measured, not calculated from point sizes: GetStringHeight reports what the font
	-- actually rendered, so CJK (taller than Latin at equal point size) and any font the
	-- EllesmereUI skin substitutes are handled without a table of per-script fudge factors.
	-- Valid only because FG_ShrinkFont now runs above.
	--
	-- Row height comes from the card, not FG_GetCardBaseHeight, so the centring follows
	-- TextSizeManager's scaling of the row rather than our unscaled base value.
	local rowH = card:GetHeight()
	if not rowH or rowH <= 0 then rowH = FG_GetCardBaseHeight() end

	local nameH = card.FriendName:GetStringHeight() or 0
	local locH, lineGap = 0, 0
	if secondLine ~= "" then
		locH = card.Location:GetStringHeight() or 0
		lineGap = FG_ROW_LINE_GAP
	end

	-- A pooled frame that has never rendered can measure 0. Falling back to retail's fixed
	-- inset keeps that first pass looking exactly as it did before centring existed, rather
	-- than centring a zero-height block and parking the text mid-row.
	local topInset = 4
	if nameH > 0 then
		topInset = math.floor((rowH - (nameH + lineGap + locH)) / 2 + 0.5)
		if topInset < 1 then topInset = 1 end
	end

	card.FriendName:ClearAllPoints()
	card.FriendName:SetPoint("TOPLEFT", card, "TOPLEFT", nameLeft, -topInset)
	card.FriendName:SetPoint("TOPRIGHT", card, "TOPRIGHT", -rightReserve, -topInset)
	card.FriendName:SetWordWrap(false)

	card.Location:ClearAllPoints()
	card.Location:SetPoint("TOPLEFT", card.FriendName, "BOTTOMLEFT", 0, -FG_ROW_LINE_GAP)
	card.Location:SetPoint("RIGHT", card.FriendName, "RIGHT", 0, 0)
	card.Location:SetWordWrap(false)

	-- The second line is supporting detail, so it is greyed rather than left at the body
	-- colour, which competed with the name for attention.
	local grey = FRIENDS_GRAY_COLOR or GRAY_FONT_COLOR
	if grey then
		card.Location:SetTextColor(grey.r, grey.g, grey.b)
	end

	-- [[ FACTION ROW TINT ]] retail's own values and its own independent toggle (separate
	-- from the faction ICON setting). Blizzard re-applies the card's background atlas in
	-- InitializeBackground on every initialise, so an untinted row restores itself and only
	-- the tinted case needs writing here.
	local tinted = false
	if gameInfo and FriendGroups_SavedVars.show_faction_color ~= false and card.Background then
		local faction = gameInfo.factionName
		if faction == "Horde" then
			card.Background:SetColorTexture(0.7, 0.2, 0.2, 0.2)
			tinted = true
		elseif faction == "Alliance" then
			card.Background:SetColorTexture(0.2, 0.2, 0.7, 0.2)
			tinted = true
		end
	end

	-- [[ ELLESMEREUI ROW WASH ]] the faction tint keeps precedence where it applies;
	-- every other row gets the house panel fill so the list reads as one surface instead
	-- of a column of Blizzard's atlas plates. Written here for the same reason the faction
	-- tint is: InitializeBackground re-asserts the atlas on every initialise, and we run
	-- after it.
	if not tinted and card.Background then
		local theme = FG_EUITheme()
		if theme then
			local c = theme.rowBackground
			card.Background:SetColorTexture(c[1], c[2], c[3], c[4])
		end
	end
end

-- Raise the known-alts panel for the hovered card. Runs after Blizzard's own tooltip has
-- been built and shown, so the alt panel docks beneath a tooltip whose size is already
-- settled -- the same ordering the legacy list relies on.
--
-- FriendGroups_ShowButtonAltTooltip is a genuine global (verified: no local declaration
-- shadows it in FriendGroups.lua) and reads button.id / button.buttonType, both stamped onto
-- the card by the content applier above.
FG_OnCardShowTooltip = function(card)
	FG_AltTooltipCalls = FG_AltTooltipCalls + 1

	if not Compat.IsSocialUIActive() then return end

	-- [[ STREAMER MODE ]] Blizzard's card tooltip is built by a LOCAL function inside
	-- Blizzard_FriendsFrame, so its CONTENT cannot be reached to mask -- and it prints the
	-- full account name, the character, the realm and the note, which is every single thing
	-- the row masking exists to withhold. Hovering a row was a hole straight through the
	-- feature. This is a post-hook, so the tooltip has already been built and shown by the
	-- time we run; hiding it here is what closes it.
	--
	-- ONLY Blizzard's. The known-alts panel is ours, every name in it is masked, and it is
	-- the reason to hover a row in the first place -- suppressing it too (which an earlier
	-- pass did) removed a working feature to solve a problem it was not causing.
	if type(FriendGroups_IsStreamerMode) == "function" and FriendGroups_IsStreamerMode() then
		if GameTooltip then GameTooltip:Hide() end
		if FriendsTooltip then FriendsTooltip:Hide() end
	end

	if type(FriendGroups_ShowButtonAltTooltip) ~= "function" then return end
	if not card or not card.id then return end

	FriendGroups_ShowButtonAltTooltip(card)
end

-- Pointer left the row: clear the alt panel. Kept deliberately dumb -- no visibility
-- guards -- because the card only calls HideTooltip when its own hover genuinely ends.
FG_OnCardHideTooltip = function()
	if not Compat.IsSocialUIActive() then return end
	if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end

	-- Hiding the panel is not enough: the hover ANCHOR has to go too. It is what the
	-- GameTooltip Show hook reads to decide whether a tooltip belongs to FriendGroups, and
	-- on 12.1 it holds SocialUIFrame rather than the FriendsFrame that hook skips -- so
	-- leaving it set makes every spell, item and unit tooltip dock to the contact list.
	-- Routed through State because it is a file-local in FriendGroups.lua.
	State = State or addonTable.State
	if State and type(State.ClearHoverAnchor) == "function" then
		State.ClearHoverAnchor()
	end
end

-- ============================================================================
-- [[ GROUPS SUBMENU ]]
-- Blizzard's Filter dropdown offers exactly two extension points, matched by literal
-- method name. From SocialUISharedTemplates.lua:
--
--   function SocialUIOnlineSearchFilterDropdownMixin:OnLoad()
--       ...
--       self:SetupMenu(function(dropdown, rootDescription)
--           local socialView = self:GetSocialView();
--           if socialView then
--               if socialView.SetupStatusFilterDropdown then ... end
--               if socialView.SetupTagsFilterDropdown then ... end
--           end
--       end);
--   end
--
-- Defining a third method on the view therefore does nothing -- the generator would have
-- to name it. There is also no menu tag on this dropdown, so Menu.ModifyMenu cannot reach
-- it either. Re-issuing SetupMenu with a wrapper is the only route.
--
-- Blizzard's generator is CHAINED, not reproduced: DropdownButtonMixin:SetupMenu stores
-- the closure on self.menuGenerator, so the original is captured and called first. Status
-- and Tags therefore stay exactly Blizzard's, including any submenu added in a later
-- patch, and only the append is ours.
--
-- Installed once. SetupMenu asserts its argument is a function and regenerates if the
-- dropdown is shown, so re-wrapping on every refresh would nest the wrappers.
FG_HookFilterDropdown = function(view)
	local filterBar = view and view.FilterBar
	local dropdown = filterBar and filterBar.SearchFilterDropdown
	if not dropdown or dropdown.fgGroupsMenuHooked then return false end
	if type(dropdown.SetupMenu) ~= "function" then return false end

	local blizzardGenerator = dropdown.menuGenerator
	if type(blizzardGenerator) ~= "function" then return false end

	dropdown.fgGroupsMenuHooked = true

	dropdown:SetupMenu(function(ownerDropdown, rootDescription)
		blizzardGenerator(ownerDropdown, rootDescription)

		if not Compat.IsSocialUIActive() then return end
		if #FG_LastGroupOrder == 0 then return end
		if type(rootDescription) ~= "table" or type(rootDescription.CreateButton) ~= "function" then return end

		local submenu = rootDescription:CreateButton(L["SOCIALUI_FILTER_GROUPS"])

		-- Checkboxes keep the menu open, so several groups can be ticked in one visit.
		for i = 1, #FG_LastGroupOrder do
			local groupName = FG_LastGroupOrder[i]
			submenu:CreateCheckbox(
				groupName,
				function() return FG_GroupFilter[groupName] == true end,
				function()
					FG_GroupFilter[groupName] = (not FG_GroupFilter[groupName]) or nil
					FG_ForceListRebuild()
				end
			)
		end

		-- Clearing every tick is the only way back to "show everything" without hunting
		-- down each ticked box, and it is the state most users will want to return to.
		submenu:CreateDivider()
		submenu:CreateButton(L["SOCIALUI_FILTER_GROUPS_CLEAR"], function()
			wipe(FG_GroupFilter)
			FG_ForceListRebuild()
		end)
	end)

	return true
end

-- ============================================================================
-- [[ HOOKS ]]
-- Refresh, and whichever search-results method this build has, are the ONLY callers of
-- self.ScrollBox:SetDataProvider on FriendsListSocialViewMixin, so post-hooking the pair
-- covers every path that would otherwise leave Blizzard's ungrouped provider on screen:
-- OnShow, BN_FRIEND_LIST_SIZE_CHANGED, BN_FRIEND_INFO_CHANGED,
-- BATTLE_NET_FRIEND_TAG_ENABLED_STATUS_UPDATED, text-scale changes, the search box, and
-- every Filter dropdown checkbox (they all route through the search-results method).
--
-- That second method is NOT a stable name -- it was OnSearchEnterPressed and is
-- RefreshSearchResults as of 12.1.0.69214 -- so it is resolved from FG_SEARCH_HOOK_NAMES at
-- install time and is treated as optional. Only Refresh is required.
--
-- Post-hooks, never replacements. GenerateDataProvider returns a value and so cannot be
-- intercepted by hooksecurefunc, and swapping a method on the instance is precisely the
-- overwrite that caused the 12.2.2 taint regression -- see the SECURE LIST REFRESH note
-- in FriendGroups.lua. Nothing here writes to a Blizzard global.
--
-- The hooks are attached to the view INSTANCE rather than to FriendsListSocialViewMixin.
-- XML mixin= applies Mixin(), which copies functions onto the frame, so hooking the mixin
-- table would not affect a frame that already exists -- and SocialUIFrame builds its
-- content frames during its own OnLoad, long before this runs.
-- ============================================================================
local function FG_OnNativeRefresh()
	if not Compat.IsSocialUIActive() then return end

	State = State or addonTable.State

	if FG_SocialProvider then
		-- Put the grouped provider back immediately, then let the coalescing timer
		-- rebuild the grouped data itself. FriendGroups_RequestListUpdate IS a global.
		Compat.ReassertSocialUIProvider()
		if type(FriendGroups_RequestListUpdate) == "function" then
			FriendGroups_RequestListUpdate()
		end
	elseif State and type(State.FriendsListUpdate) == "function" then
		-- First refresh of the session: there is nothing to re-assert yet, so build
		-- synchronously rather than leaving Blizzard's ungrouped list on screen for the
		-- length of the throttle window. The combat guard inside still applies.
		--
		-- Reached through State, NOT as a global: FriendGroups_FriendsListUpdate is a
		-- file-local of FriendGroups.lua and a bare global reference here resolves to nil.
		State.FriendsListUpdate(true)
	end
end

-- The "what should be SHOWN has changed" handler needs to be SEPARATE from Refresh, and
-- conflating the two was the bug.
--
-- Refresh means the ROSTER may have changed, so the throttled, non-forcing path above is
-- right: it coalesces bursts of BN_FRIEND_INFO_CHANGED and skips the work when nothing
-- actually moved.
--
-- This one means the roster is deliberately IDENTICAL and only the view of it has moved --
-- the search text, or a checkbox in the Filter dropdown. That is exactly the case the
-- non-forcing path throws away, so it forces.
-- View methods that mean "the view of the roster has changed", newest build first. Consumed
-- by Compat.InitSocialUI, which hooks the first one this client actually has.
local FG_SEARCH_HOOK_NAMES = {
	"RefreshSearchResults",   -- 12.1.0.69214 onwards
	"OnSearchEnterPressed",   -- earlier 12.1 builds
}

local FG_SearchForceTimer

local function FG_OnNativeSearchChanged()
	if not Compat.IsSocialUIActive() then return end

	-- Immediate: Blizzard's handler has just put its own provider in, and leaving it up even
	-- for one frame flashes the ungrouped list.
	Compat.ReassertSocialUIProvider()

	-- [[ THE REBUILD IS COALESCED ]]
	-- On 12.1.0.69214 this handler hangs off RefreshSearchResults, which the search bar can
	-- call on every keystroke -- and a full roster rebuild per keystroke is precisely what
	-- FG_HookSearchBox's own 0.3s debounce exists to avoid. Its predecessor
	-- (OnSearchEnterPressed) fired once per commit, so an unguarded force was safe there and
	-- is not safe here.
	--
	-- The window is short enough to be imperceptible on a filter click, which is a single
	-- discrete action, while still collapsing a typing burst into one pass.
	if FG_SearchForceTimer then FG_SearchForceTimer:Cancel() end
	FG_SearchForceTimer = C_Timer.NewTimer(0.05, function()
		FG_SearchForceTimer = nil
		FG_ForceListRebuild()
	end)
end

-- Hook installation is deliberately NOT gated on Compat.IsSocialUIActive(). That test
-- includes C_SocialUI.IsSystemEnabled(), which is server-driven: if the status has not
-- arrived by the time this runs, gating on it would skip installation permanently unless
-- the status later CHANGED (an unchanged status fires no event, so there would be no
-- retry). Installation therefore only requires the frame to exist; whether to act at all
-- is decided at call time, inside FG_OnNativeRefresh.
function Compat.InitSocialUI()
	if hooksInstalled then return end

	local view = SocialUIFrame and SocialUIFrame.FriendsList
	if not view then return end

	-- [[ GATE ON WHAT IS ESSENTIAL, AND ONLY THAT ]]
	-- Refresh is genuinely required: it is how Blizzard tells us it has installed its own
	-- provider, and without it ours can never be re-asserted.
	--
	-- Nothing else is. This used to ALSO require OnSearchEnterPressed, and build
	-- 12.1.0.69214 removed that method -- so this function returned here, before the latch
	-- below, and every hook after it was silently never installed: the provider re-assert,
	-- the row content, the portrait, the panel sizing, the status dropdown, the BattleTag
	-- label. The visible result was the addon appearing to do nothing at all, because one
	-- OPTIONAL method had gone.
	--
	-- The file already argues this above for IsSocialUIActive: do not gate installation on
	-- something that can be absent for reasons that have nothing to do with whether the rest
	-- can work. A missing method must cost the one feature that needs it, nothing more.
	if type(view.Refresh) ~= "function" then return end

	hooksInstalled = true

	hooksecurefunc(view, "Refresh", FG_OnNativeRefresh)

	-- [[ SEARCH / FILTER FORCING PATH ]]
	-- Whichever of these the client has, newest first. 12.1.0.69214 renamed the old
	-- OnSearchEnterPressed to RefreshSearchResults; the predecessor is kept in the list so a
	-- rollback to an earlier build still finds a hook rather than silently losing filters.
	--
	-- First match wins: hooking two names that both exist would force two rebuilds per click.
	-- Every one of them is OPTIONAL -- if a future build renames it again, filter checkboxes
	-- stop forcing a rebuild and nothing else changes.
	for i = 1, #FG_SEARCH_HOOK_NAMES do
		local methodName = FG_SEARCH_HOOK_NAMES[i]
		if type(view[methodName]) == "function" then
			hooksecurefunc(view, methodName, FG_OnNativeSearchChanged)
			break
		end
	end

	-- [[ RETAIL ROW DENSITY ]]
	-- The registration this replaces outlives every cache clear, so once accepted the height
	-- survives Refresh, OnShow and text-scale changes -- but ACCEPTANCE is not guaranteed
	-- here, and the result has to be recorded rather than assumed.
	--
	-- view.TemplateRegistrations is not populated until the view's ScrollBox first initialises
	-- its templates, which can happen well after PLAYER_ENTERING_WORLD. This function runs on
	-- that event, and hooksInstalled is already true by the time we reach this line -- so a
	-- miss here used to be permanent for the session, and every row stayed at Blizzard's
	-- 70px card with all four icons scaled to match and the name squeezed to an ellipsis.
	-- That is a login-timing race, so it appears at random and never in a fresh test.
	cardHeightInstalled = FG_InstallCardHeightOverride(view)

	-- Drive Blizzard's own search field instead of adding a second one.
	FG_HookSearchBox(view)

	-- FriendGroups' own Groups submenu, appended to Blizzard's Filter dropdown.
	FG_HookFilterDropdown(view)

	-- FriendGroups mark on the panel portrait while the Friends tab is selected.
	-- RefreshVisuals runs on every tab change; the immediate call covers the current tab,
	-- since the panel may already be open when this installs.
	if type(SocialUIFrame.RefreshVisuals) == "function" then
		hooksecurefunc(SocialUIFrame, "RefreshVisuals", FG_RefreshPortrait)
	end
	FG_RefreshPortrait()

	-- Panel size. FriendGroups_UpdateSize is a global and is the single funnel every size
	-- setting already calls, so post-hooking it means the menu items need no changes at all.
	-- Re-applied on OnShow because the UIPanel system re-lays-out the frame when it opens.
	if type(FriendGroups_UpdateSize) == "function" then
		hooksecurefunc("FriendGroups_UpdateSize", Compat.ApplySocialUISize)
	end
	SocialUIFrame:HookScript("OnShow", Compat.ApplySocialUISize)
	Compat.ApplySocialUISize()

	-- Row content. Hooked on the MIXIN rather than an instance because cards are pooled
	-- and created lazily -- there is no frame to hook yet. XML mixin= applies Mixin(),
	-- which COPIES functions onto each frame at creation, so this only reaches cards
	-- created after this point. That is safe here and only here: the pool builds its first
	-- card when the ScrollBox first renders, which cannot happen before the contact list
	-- has been opened, and this runs at PLAYER_ENTERING_WORLD.
	if type(FriendsListSocialCardMixin) == "table"
		and type(FriendsListSocialCardMixin.InitializeDisplay) == "function" then
		hooksecurefunc(FriendsListSocialCardMixin, "InitializeDisplay", FG_ApplySocialCardContent)
		cardHookInstalled = true
	end
end

-- ============================================================================
-- [[ PANEL SIZE ]]
-- FriendGroups_UpdateSize resizes FriendsFrame and FriendsListFrame, both permanently
-- hidden on 12.1, so the Contact List Size and width settings had no visible effect.
--
-- WIDTH goes through Blizzard's own machinery rather than around it. SocialUIFrame computes
-- its panel width in GetBestUIPanelWidth as baseUIPanelWidth plus whatever side window is
-- open, then feeds it to SetUIPanelAttribute / UpdateUIPanelPositions. Overwriting
-- baseUIPanelWidth and asking it to refresh therefore resizes the panel the way Blizzard
-- intends -- and side windows keep sizing correctly on top, which a raw SetWidth would break.
--
-- HEIGHT has no such hook, so it is a direct SetHeight. The tab content frames are anchored
-- to the frame's edges, so the list grows with it.
--
-- Both are skipped in combat: SocialUIFrame is a UIPanel, and resizing or repositioning one
-- during combat is a taint risk. FriendGroups_UpdateSize is already only called from paths
-- that respect the same rule.
-- ============================================================================
-- Blizzard keeps TWO different widths for this frame and they are not interchangeable:
--   <Size x="410">                the frame's VISUAL width
--   baseUIPanelWidth = 460        the width registered with the UIPanel manager
-- An earlier version captured one value for both, which made every SetWidth 50px too wide.
local FG_PanelBaseHeight, FG_PanelBaseVisualWidth, FG_PanelBaseUIWidth
local FG_SizeRebuildPending = false

function Compat.ApplySocialUISize()
	if not Compat.IsSocialUIActive() then return end
	if InCombatLockdown() then return end
	if type(FriendGroups_SavedVars) ~= "table" then return end

	local frame = SocialUIFrame

	-- Capture Blizzard's defaults once, before anything of ours has moved them.
	if not FG_PanelBaseHeight then FG_PanelBaseHeight = frame:GetHeight() end
	if not FG_PanelBaseVisualWidth then FG_PanelBaseVisualWidth = frame:GetWidth() end
	if not FG_PanelBaseUIWidth then FG_PanelBaseUIWidth = frame.baseUIPanelWidth or frame:GetWidth() end
	if not FG_PanelBaseHeight or not FG_PanelBaseVisualWidth then return end

	local extraHeight = FriendGroups_SavedVars.extra_height or 0
	local extraWidth = 0
	if type(FriendGroups_GetExtraWidth) == "function" then
		extraWidth = FriendGroups_GetExtraWidth() or 0
	end

	frame:SetHeight(FG_PanelBaseHeight + extraHeight)

	-- Width needs BOTH halves, which the first attempt got wrong by doing only the second.
	--   SetWidth            -- the frame's actual visual width
	--   baseUIPanelWidth    -- what GetBestUIPanelWidth reports to the UIPanel manager, so
	--                          neighbouring panels are pushed aside and side windows still
	--                          add their own width on top
	-- SetUIPanelAttribute("width") alone only tells the panel MANAGER how much room to
	-- reserve; it never resizes the frame, which is why the width settings appeared dead.
	frame:SetWidth(FG_PanelBaseVisualWidth + extraWidth)
	frame.baseUIPanelWidth = FG_PanelBaseUIWidth + extraWidth
	if type(frame.TryRefreshUIPanelWidth) == "function" then
		frame:TryRefreshUIPanelWidth()
	end

	-- [[ CONTENT MUST TRACK THE FRAME, NOT THE BATTLE.NET BAR ]]
	-- SocialUI.lua anchors each tab's content frame like this:
	--     SetPoint("TOPLEFT",     BattleNetBar, "BOTTOMLEFT", 0, 5)
	--     SetPoint("BOTTOMRIGHT", socialUIFrame, "BOTTOMRIGHT", -2, 2)
	-- and SocialUIBattleNetBarTemplate is a FIXED 413 wide, anchored by TOP alone -- so it
	-- stays centred and never stretches. Widening the frame by N therefore moves the bar's
	-- left edge right by N/2 while the content's right edge moves by N: the list gains only
	-- half the width and is pushed right, leaving a dead gutter down the left.
	--
	-- Re-anchored so the vertical still comes from the bar (keeping Blizzard's spacing) while
	-- both horizontal edges come from the frame. FilterBar is already TOPLEFT/TOPRIGHT to the
	-- content frame, so the search bar, ScrollBox and every row inherit the correction.
	--
	-- Only the Friends tab's frame is touched. The other five belong to Blizzard.
	local view = Compat.GetSocialUIFriendsView()
	if view and frame.BattleNetBar then
		view:ClearAllPoints()
		view:SetPoint("TOP", frame.BattleNetBar, "BOTTOM", 0, 5)
		view:SetPoint("LEFT", frame, "LEFT", 2, 0)
		view:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
	end

	-- [[ BATTLE.NET BAR ]] the band carrying the BattleTag, status dropdown and hamburger.
	-- SocialUIBattleNetBarTemplate is a fixed 413 wide anchored by TOP alone, so in a widened
	-- window it sits marooned in the middle. Its ControlsContainer is already LEFT/RIGHT to
	-- the bar, so the controls follow once the bar itself spans.
	--
	-- Its Background is an atlas with useAtlasSize="true" anchored CENTER, i.e. authored at a
	-- fixed size. SetAllPoints overrides that so the art stretches with the bar; it was not
	-- drawn to scale, so if it distorts badly the alternative is tiling it.
	local bar = frame.BattleNetBar
	if bar then
		bar:ClearAllPoints()
		bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -22)
		bar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -22)
		if bar.Background then
			bar.Background:ClearAllPoints()
			bar.Background:SetAllPoints(bar)
		end
		-- Deferred a frame: the dropdown is measured, and re-anchoring the bar above is
		-- exactly the kind of change that leaves a child's width unresolved until the next
		-- layout pass. Declared as a function reference, so it is the CURRENT definition
		-- that runs rather than one captured at file scope before it existed.
		C_Timer.After(0, function()
			Compat.RefreshStatusDropdown()
			Compat.RefreshOwnBattleTag()
		end)
	end

	-- The two decorative fades are also useAtlasSize textures, so they stay at native width
	-- while everything around them grows. Their height is preserved and re-applied, because
	-- anchoring only the two horizontal edges would leave them with no height at all.
	if frame.TopFade and bar then
		local h = frame.TopFade:GetHeight()
		frame.TopFade:ClearAllPoints()
		frame.TopFade:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 5)
		frame.TopFade:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 5)
		if h and h > 0 then frame.TopFade:SetHeight(h) end
	end
	if frame.BottomFade and frame.Bg then
		local h = frame.BottomFade:GetHeight()
		frame.BottomFade:ClearAllPoints()
		frame.BottomFade:SetPoint("BOTTOMLEFT", frame.Bg, "BOTTOMLEFT", 0, 0)
		frame.BottomFade:SetPoint("BOTTOMRIGHT", frame.Bg, "BOTTOMRIGHT", 0, 0)
		if h and h > 0 then frame.BottomFade:SetHeight(h) end
	end

	-- Widening the panel stretches the ScrollBox, but the row frames it has already laid out
	-- keep the width they were built at, so the list stays narrow inside a wide window. The
	-- ScrollBox re-sizes its elements on the next layout pass, so one is forced by rebuilding
	-- the provider.
	--
	-- Deferred by a zero-delay timer, and flagged, so a burst of size changes collapses into
	-- a single rebuild rather than one per setting click. Safe from recursion: verified that
	-- FriendGroups_FriendsListUpdate never calls FriendGroups_UpdateSize, which is what
	-- brought us here.
	if not FG_SizeRebuildPending then
		FG_SizeRebuildPending = true
		C_Timer.After(0, function()
			FG_SizeRebuildPending = false
			State = State or addonTable.State
			if State and type(State.FriendsListUpdate) == "function" then
				State.FriendsListUpdate(true)
			end
		end)
	end
end

-- ============================================================================
-- [[ SEARCH ]]
-- Blizzard's filter bar already owns a search box, so FriendGroups drives that one rather
-- than adding a second field. Its own box stays on the legacy frame for the other platforms.
--
-- Blizzard searches only on ENTER, and through C_BattleNet.SearchFriends -- a real call that
-- must not run per keystroke. FriendGroups filters live instead, over data it already holds,
-- and matches far more than a name: notes, groups, nicknames, realm, class and known alts.
-- Hooking OnTextChanged gives that behaviour behind Blizzard's field, with the same 0.3s
-- debounce the legacy search box uses so a fast typist triggers one rebuild, not ten.
--
-- HookScript, not SetScript: Blizzard's own handler must keep running or the field loses its
-- clear button and instruction text.
-- ============================================================================
local FG_SearchDebounceTimer = nil
local searchHooked = false

FG_HookSearchBox = function(view)
	if searchHooked then return false end

	local filterBar = view and view.FilterBar
	local searchBox = filterBar and filterBar.SearchBar
	if not searchBox or type(searchBox.HookScript) ~= "function" then return false end

	searchHooked = true

	searchBox:HookScript("OnTextChanged", function(self)
		State = State or addonTable.State
		if not State or type(State.SetSearchText) ~= "function" then return end

		-- No-op keystrokes (arrow keys, re-entering the same text) change nothing.
		if not State.SetSearchText(self:GetText()) then return end

		if FG_SearchDebounceTimer then
			FG_SearchDebounceTimer:Cancel()
		end
		FG_SearchDebounceTimer = C_Timer.NewTimer(0.3, function()
			FG_SearchDebounceTimer = nil
			if State and type(State.FriendsListUpdate) == "function" then
				State.FriendsListUpdate(true)
			end
		end)
	end)

	return true
end

-- ============================================================================
-- [[ PORTRAIT ]]
-- SocialUIFrame is shared by all six tabs, so the FriendGroups mark is applied only while
-- the Friends tab is selected and Blizzard's own portrait is restored on the way out --
-- branding their Raid or Recruit-a-Friend tab would read as a bug, not a feature.
--
-- InitializeFrameVisuals sets the portrait once at OnLoad, so this rides RefreshVisuals,
-- which runs on every tab change.
-- ============================================================================
local FG_PORTRAIT_ASSET = "Interface\\AddOns\\FriendGroups\\Textures\\fg"

-- [[ PORTRAIT SUPPRESSION ]]
-- Another addon may have removed the portrait entirely. EllesmereUI's window engine does
-- exactly that in WSkin.RemovePortrait: it alpha-zeroes PortraitContainer's regions and the
-- portrait texture, and re-applies that on relayout.
--
-- Our mark is written to the same texture, so it disappears with Blizzard's -- but the
-- backing below is a SEPARATE texture their fade pass never enumerated, so it survives. The
-- result on screen is a black disc floating where the portrait used to be, which is what
-- this exists to prevent.
--
-- MEASURED rather than inferred from "is EllesmereUI loaded": the user can keep our colours
-- with EUI's window skinning switched off, any other skin does the same thing, and the two
-- addons can run in either order. Re-read on every call, so whichever order they land in,
-- the next RefreshVisuals corrects it.
local function FG_PortraitIsSuppressed(frame)
	local container = frame.PortraitContainer
	if container and container:GetAlpha() <= 0.01 then return true end
	-- Alpha is not the only way a skin removes it: FriendGroups' OWN EllesmereUI skin hides
	-- the container outright, which leaves alpha at 1 and read as "not suppressed" here.
	-- IsShown is the frame's own state, not effective visibility, so this does not fire
	-- merely because the contact list is closed.
	if container and not container:IsShown() then return true end

	local portrait = type(frame.GetPortrait) == "function" and frame:GetPortrait() or nil
	if portrait and portrait:GetAlpha() <= 0.01 then return true end

	return false
end

-- Published for ContactsMark.lua. "A skin removed the portrait" is exactly the condition
-- that leaves the band above the sub-tab strip empty for the mark to fill, so both readers
-- ask the same question of the same frame rather than each keeping a guess about which
-- suites do it.
Compat.PortraitIsSuppressed = FG_PortraitIsSuppressed

-- [[ BACKING ]] The FriendGroups mark has transparent areas, so on its own the world shows
-- through the portrait ring. Blizzard's own portrait art is fully opaque and never needed one.
--
-- A plain black square would square off a round frame, so it is masked with
-- TempPortraitAlphaMask -- the circular mask Blizzard uses for portraits throughout the UI.
-- Parented to PortraitContainer and one draw layer below the portrait itself, so it backs the
-- mark without covering the ring.
--
-- Built at most once per frame, and never while the portrait is suppressed: the mark is
-- written to Blizzard's texture and disappears with it under a skin that hides portraits, but
-- this is a SEPARATE texture that no such pass enumerates, so it would survive as a black disc
-- floating where the portrait used to be.
--
-- Shared by both contact lists, keyed on the frame it is given: the Social UI panel and the
-- legacy FriendsFrame are different frames, each carrying its own fgPortraitBacking.
local function FG_EnsurePortraitBacking(frame, suppressed)
	if suppressed or frame.fgPortraitBacking then return end
	if not frame.PortraitContainer or type(frame.GetPortrait) ~= "function" then return end

	local portrait = frame:GetPortrait()
	if not portrait then return end

	local backing = frame.PortraitContainer:CreateTexture(nil, "BACKGROUND")
	backing:SetAllPoints(portrait)
	backing:SetColorTexture(0, 0, 0, 1)

	local mask = frame.PortraitContainer:CreateMaskTexture()
	mask:SetAllPoints(portrait)
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask",
		"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	backing:AddMaskTexture(mask)

	frame.fgPortraitBacking = backing
end

FG_RefreshPortrait = function()
	if not Compat.IsSocialUIActive() then return end

	local frame = SocialUIFrame
	if type(frame.SetPortraitToAsset) ~= "function" then return end
	if type(frame.GetSelectedTab) ~= "function" then return end
	if type(SocialUITabType) ~= "table" then return end

	local onFriendsTab = (frame:GetSelectedTab() == SocialUITabType.Friends)

	local suppressed = FG_PortraitIsSuppressed(frame)
	FG_EnsurePortraitBacking(frame, suppressed)

	if frame.fgPortraitBacking then
		frame.fgPortraitBacking:SetShown(onFriendsTab and not suppressed)
	end

	-- The asset is still written while suppressed. It costs nothing against an invisible
	-- texture, and it means the mark simply reappears if the skin hiding it is turned off,
	-- with no state of ours to unwind.
	if onFriendsTab then
		frame:SetPortraitToAsset(FG_PORTRAIT_ASSET)
	elseif frame.portraitIcon then
		frame:SetPortraitToAsset(frame.portraitIcon)
	end
end

-- ============================================================================
-- [[ CONTACT COUNT ]]
-- Retail draws the unique-online-contacts number in its own fontstring above the group
-- headers. That fontstring is parented to FriendsListFrame, so on 12.1 it exists and is
-- invisible. The panel title is the natural replacement: SocialUIFrameMixin:RefreshTitle
-- already recomputes it on every tab change, so appending there keeps the number correct
-- without owning any new region.
--
-- Scoped to the Friends tab -- the count means nothing over Raid or Recruit-a-Friend -- and
-- gated on the same show_contact_cap setting the legacy counter uses.
-- ============================================================================
-- Retail draws this over the group headers' count column, beside its settings gear. The
-- Social UI's filter bar has the same shape -- search field left, Filter dropdown right -- so
-- the counter takes the gap between them, which is where the eye already goes on retail. The
-- number lives on the bar; an invisible frame sitting exactly on top of it carries the hover,
-- because a FontString cannot take mouse input.
--
-- The tooltip is NOT rebuilt here. FriendGroups_ShowContactTooltip is the very function the
-- legacy counter raises -- per-group online counts on banner-tinted strips, Battle.net and WoW
-- totals against their caps, pending invites, the at-cap warning. Reimplementing that for this
-- platform would guarantee the two drift apart.
FG_UpdateContactCounter = function(view)
	if type(FriendGroups_SavedVars) ~= "table" then return end

	local filterBar = view and view.FilterBar
	if not filterBar then return end

	if not FG_ContactCountText then
		FG_ContactCountText = filterBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		-- A fixed, right-aligned slot wide enough for four digits. Without it the string is
		-- sized to its text and grows LEFTWARDS from its right anchor, so a three-digit count
		-- would slide under the search box -- and the gap between the two shrinks at Narrow.
		-- Fixing the width also stops the bar reflowing every time a friend logs in or out.
		FG_ContactCountText:SetWidth(FG_CONTACT_COUNT_WIDTH)
		FG_ContactCountText:SetJustifyH("RIGHT")

		FG_ContactCountHover = CreateFrame("Frame", nil, filterBar)
		FG_ContactCountHover:SetPoint("TOPLEFT", FG_ContactCountText, "TOPLEFT", 0, 0)
		FG_ContactCountHover:SetPoint("BOTTOMRIGHT", FG_ContactCountText, "BOTTOMRIGHT", 0, 0)
		FG_ContactCountHover:SetScript("OnEnter", function(self)
			if type(FriendGroups_ShowContactTooltip) == "function" then
				FriendGroups_ShowContactTooltip(self)
			end
		end)
		FG_ContactCountHover:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	if FriendGroups_SavedVars.show_contact_cap == false then
		FG_ContactCountText:Hide()
		FG_ContactCountHover:Hide()
		return
	end

	-- Anchored to the Filter dropdown so it holds its place as the panel is widened.
	local dropdown = filterBar.SearchFilterDropdown
	FG_ContactCountText:ClearAllPoints()
	if dropdown then
		FG_ContactCountText:SetPoint("RIGHT", dropdown, "LEFT", -8, 0)
	else
		FG_ContactCountText:SetPoint("RIGHT", filterBar, "RIGHT", -8, 0)
	end

	-- Give the counter its own space by shortening the search field. The template anchors
	-- SearchBar LEFT to the bar and RIGHT to the dropdown, so re-setting RIGHT alone re-points
	-- that edge and leaves the left one intact -- a frame holds only one anchor per point.
	-- No cycle: counter -> dropdown, search -> counter, search LEFT -> bar.
	local searchBar = filterBar.SearchBar
	if searchBar then
		searchBar:SetPoint("RIGHT", FG_ContactCountText, "LEFT", -10, 0)
	end

	State = State or addonTable.State
	local total = (State and type(State.GetOnlineTotal) == "function" and State.GetOnlineTotal()) or 0

	-- Same string and the same gold as retail's counter -- unless EllesmereUI colours are
	-- live, in which case the accent replaces the gold and the family follows the user's
	-- chosen font. The size is left alone, as everywhere else in this pass.
	FG_ContactCountText:SetText(string.format(L["TEXT_ONLINE_COUNT"], total))
	FG_ApplyThemeFont(FG_ContactCountText, FG_EUITheme())
	FG_ContactCountText:SetTextColor(FriendGroups_AccentRGB())
	FG_ContactCountText:Show()
	FG_ContactCountHover:Show()
end

-- ============================================================================
-- [[ SETTINGS MENU ]]
-- On 12.1 FriendGroups' gear button lives on FriendsListFrame, which the player cannot
-- open, so the addon would otherwise be unconfigurable. The Social UI's Battle.net bar
-- menu -- the hamburger at the top right, holding Broadcast and Ignore List -- carries a
-- real menu tag, so the settings are injected through the supported Menu API instead of
-- by bolting a button onto a frame we do not own. Nothing is overwritten and no Blizzard
-- frame is restyled, so this adds no taint surface.
--
-- FriendGroups_BuildSettingsMenu is the same generator the legacy gear raises; it is given
-- a SUBMENU description here rather than a root, which works because both expose the same
-- Create* API.
-- ============================================================================
local function FG_InjectSettingsMenu(ownerRegion, rootDescription)
	if not Compat.IsSocialUIActive() then return end
	if type(FriendGroups_BuildSettingsMenu) ~= "function" then return end
	if type(rootDescription) ~= "table" or type(rootDescription.CreateButton) ~= "function" then return end

	local submenu = rootDescription:CreateButton(L["SETTINGS_TITLE"])
	FriendGroups_BuildSettingsMenu(ownerRegion, submenu)
end

-- Registered at load rather than from Compat.InitSocialUI: Menu.ModifyMenu only records a
-- callback against a tag, so it needs no frame, and keeping it independent means the
-- settings stay reachable even if the list hooks fail to install. The tag exists only on
-- 12.1, so on any earlier client this simply never fires.
if Compat.HAS_MENU_API then
	Menu.ModifyMenu("MENU_SOCIAL_UI_BATTLE_NET_BAR", FG_InjectSettingsMenu)
end

-- ============================================================================
-- [[ DIAGNOSTIC ]]
-- Returns booleans only -- no strings, so nothing here needs localizing and nothing can
-- reach the UI. Exposed as a global purely so the state of this module can be inspected
-- from a /run without the addon-private Compat table:
--   1 socialUIActive    Compat.IsSocialUIActive()   -- is 12.1's Social UI the live list
--   2 viewExists        SocialUIFrame.FriendsList resolved
--   3 hooksInstalled    Compat.InitSocialUI ran to completion (Refresh post-hook attached)
--   4 providerBuilt     a grouped provider has been built at least once
--   5 providerInstalled that provider is the one currently in the ScrollBox
--   6 cardHookInstalled the row-content post-hook is attached to the card mixin
--   7 rowApplyCalls     times the row hook has fired (0 = it is never reached)
--   8 rowApplyApplied   times it got past its guards to real work
--   9 dragStarts        times a header drag actually began (0 = ScrollBox is eating it)
--
-- Appended after the panel dimensions: cardHeightInstalled, and the height a row actually
-- has right now. FALSE with a row height around 70 is the login race described in
-- Compat.InitSocialUI -- Blizzard's uncompressed card, every icon scaled to match it, and
-- the name reduced to an ellipsis. It reads as "the addon broke", so it is worth being able
-- to confirm in one call rather than inferring it from a screenshot.
-- ============================================================================
function FriendGroups_GetSocialUIState()
	local view = SocialUIFrame and SocialUIFrame.FriendsList
	local installed = false
	if view and view.ScrollBox and FG_SocialProvider then
		installed = (view.ScrollBox:GetDataProvider() == FG_SocialProvider)
	end
	return Compat.IsSocialUIActive(), view ~= nil, hooksInstalled, FG_SocialProvider ~= nil, installed,
		cardHookInstalled, FG_RowApplyCalls, FG_RowApplyApplied, FG_AltTooltipCalls,
		FG_DragStarts,
		SocialUIFrame and math.floor(SocialUIFrame:GetWidth() or 0) or 0,
		SocialUIFrame and math.floor(SocialUIFrame:GetHeight() or 0) or 0,
		SocialUIFrame and math.floor(SocialUIFrame.baseUIPanelWidth or 0) or 0,
		cardHeightInstalled,
		math.floor(FG_GetCardBaseHeight() or 0)
end

-- ============================================================================
-- [[ STATUS DROPDOWN PREVIEW ]]
-- The Battle.net bar's status control shows an ellipsis where the current status should be.
-- Reproduced on a stock 12.1 client with FriendGroups disabled, so this is Blizzard's and
-- not ours -- but it sits inside a window this addon has taken over, where it reads as our
-- bug, and it is cheap to correct.
--
-- Two different faults produce the same ellipsis and they need opposite fixes, so both are
-- handled, cheapest and safest first:
--
--   1. The text IS set and the button is too narrow, so WoW truncates it. Fixed by
--      measuring the string and widening the button until it fits.
--   2. The text is never set and the ellipsis is a placeholder. Fixed by deriving the
--      status ourselves and writing it.
--
-- Case 1 runs first because it cannot display anything untrue -- it only reveals text
-- Blizzard already put there. Case 2 engages only when there is demonstrably nothing to
-- reveal, because it is the one that can be wrong: BNGetInfo reports AFK and DND but has no
-- flag for "Appear Offline", which would therefore read as Online. Showing a status that is
-- merely incomplete beats showing none at all, but it stays the fallback for that reason.
-- ============================================================================

-- Never shrink and never exceed this: the bar also carries the BattleTag, and a dropdown
-- that grew without bound would run into it.
local FG_STATUS_DROPDOWN_MAX_WIDTH = 170
-- Room for the dropdown arrow and the button's own insets, either side of a TEXT label.
local FG_STATUS_DROPDOWN_PADDING = 22

-- Fallback chevron allowance, used only when the arrow region cannot be measured.
local FG_STATUS_DROPDOWN_CHEVRON = 20

-- Breathing room on top of "square icon area + chevron". The square alone still clipped the
-- icon escape back to an ellipsis: the label needs more room than the 16px the dot occupies,
-- because WoW measures the whole |T...|t run rather than the pixels it paints.
local FG_STATUS_DROPDOWN_EXTRA = 14

local FG_StatusDropdown = nil

-- The button's label, however this template happens to expose it.
local function FG_DropdownFontString(dd)
	if type(dd.Text) == "table" and type(dd.Text.GetText) == "function" then return dd.Text end
	if type(dd.GetFontString) == "function" then
		local fs = dd:GetFontString()
		if fs then return fs end
	end
	if type(dd.GetRegions) ~= "function" then return nil end
	local regions = { dd:GetRegions() }
	for i = 1, #regions do
		local r = regions[i]
		if r and type(r.IsObjectType) == "function" and r:IsObjectType("FontString") then return r end
	end
	return nil
end

-- Matched by METHOD, never by name or parentKey: the bar's children are anonymous and
-- Blizzard renames parentKeys between patches, so SetupMenu/OpenMenu -- DropdownButtonMixin's
-- own surface -- is the stable handle.
--
-- THE HAMBURGER IS ALSO A MENU BUTTON, and it lives on this same bar (it is where our own
-- settings menu is injected), so "has SetupMenu" alone would match it perhaps half the time
-- depending on child order. Two further tests separate them: the status control carries a
-- text label and the hamburger is icon-only, and of the survivors the status control is the
-- LEFTMOST -- the arrangement in every 12.1 screenshot, with the hamburger at the far right.
-- Neither test alone is conclusive; together they have to pick the wrong frame twice.
--
-- The Filter dropdown cannot be confused with either: it lives on the FilterBar, which is
-- not walked here.
local function FG_CollectDropdowns(frame, depth, out)
	if type(frame) ~= "table" or type(frame.GetChildren) ~= "function" then return out end
	if depth > 3 then return out end

	local kids = { frame:GetChildren() }
	for i = 1, #kids do
		local kid = kids[i]
		if type(kid) == "table"
			and (type(kid.SetupMenu) == "function" or type(kid.OpenMenu) == "function")
			and FG_DropdownFontString(kid) then
			out[#out + 1] = kid
		end
		FG_CollectDropdowns(kid, depth + 1, out)
	end
	return out
end

local function FG_FindStatusDropdown()
	if FG_StatusDropdown and type(FG_StatusDropdown.GetObjectType) == "function" then
		return FG_StatusDropdown
	end

	local bar = SocialUIFrame and SocialUIFrame.BattleNetBar
	if not bar then return nil end

	local candidates = FG_CollectDropdowns(bar, 1, {})
	local best, bestLeft = nil, nil
	for i = 1, #candidates do
		local c = candidates[i]
		local left = (type(c.GetLeft) == "function") and c:GetLeft() or nil
		if best == nil or (left and bestLeft and left < bestLeft) then
			best, bestLeft = c, left
		end
	end

	FG_StatusDropdown = best
	return FG_StatusDropdown
end

-- True when the label holds nothing but ellipsis punctuation, i.e. there is no real status
-- text to reveal and widening the button would achieve nothing.
--
-- The ASCII form, the single U+2026 character and a stray escape-sequence pipe all have to
-- read as empty. Note %w is ASCII-ONLY, so a CJK client's perfectly good status label would
-- be misread as a placeholder without the high-byte range -- but U+2026 is high-byte too,
-- which is why it is stripped BEFORE the test rather than excluded inside it.
local function FG_IsPlaceholderText(text)
	if type(text) ~= "string" then return true end
	local stripped = text:gsub("%s+", ""):gsub("%.%.%.", ""):gsub("\226\128\166", ""):gsub("|", "")
	if stripped == "" then return true end
	return not stripped:find("[%w\128-\255]")
end

-- Fallback only. Blizzard's own globals, so the label is localized and matches the wording
-- the rest of the friends UI has always used.
local function FG_DerivedStatusText()
	if type(BNGetInfo) ~= "function" then return nil end
	local ok, _, _, _, _, bnetAFK, bnetDND = pcall(BNGetInfo)
	if not ok then return nil end

	local icon, label
	if bnetDND then
		icon, label = FRIENDS_TEXTURE_DND, FRIENDS_LIST_BUSY
	elseif bnetAFK then
		icon, label = FRIENDS_TEXTURE_AFK, FRIENDS_LIST_AWAY
	else
		icon, label = FRIENDS_TEXTURE_ONLINE, FRIENDS_LIST_AVAILABLE
	end

	-- ICON ONLY, deliberately, even though the label is resolved above: 12.1's control is a
	-- status dot and nothing else, and appending a word here would both disagree with the
	-- native look and force the button wide enough to hold text the layout then clips.
	-- The label is still resolved so it can be used as the tooltip if that is ever wanted.
	if type(icon) == "string" and icon ~= "" then
		return string.format("|T%s:16:16|t", icon)
	end
	-- No icon global on this client: fall back to the word rather than writing nothing, and
	-- invent no English if that is missing too.
	if type(label) == "string" and label ~= "" then return label end
	return nil
end

-- True when the label contains real words rather than only texture/atlas/colour escapes.
-- Decides which sizing rule applies. %w is ASCII-only, so the high-byte range is required
-- or a CJK client's label would be mistaken for icon-only and clipped to 36px.
local function FG_LabelHasWords(text)
	if type(text) ~= "string" then return false end
	local s = text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
	s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%s+", "")
	if s == "" then return false end
	return s:find("[%w\128-\255]") ~= nil
end

function Compat.RefreshStatusDropdown()
	if not Compat.IsSocialUIActive() then return end
	-- SetWidth on a UIPanel child during combat is the same taint surface ApplySocialUISize
	-- guards against, and a status preview is never worth it.
	if InCombatLockdown() then return end

	local dd = FG_FindStatusDropdown()
	if not dd or type(dd.SetWidth) ~= "function" then return end

	local fs = FG_DropdownFontString(dd)
	if not fs then return end

	if FG_IsPlaceholderText(fs:GetText()) then
		local derived = FG_DerivedStatusText()
		if derived then fs:SetText(derived) end
	end

	-- [[ ICON-ONLY: SQUARE PLUS CHEVRON ]]
	-- What 12.1 puts here is one status dot. So the icon area is simply the control's own
	-- HEIGHT -- a square -- and the chevron is added beside it. Nothing is measured from the
	-- string, which is what went wrong twice: a |T...|t escape does not measure like the
	-- glyphs it draws, so measuring it first over-sized the button and left a gap, and the
	-- corrected constant then under-sized it and clipped the dot away entirely.
	--
	-- The height is already correct (Blizzard sets it), so deriving the width from it cannot
	-- be wrong at any UI scale or font size, and needs no constant to tune.
	if not FG_LabelHasWords(fs:GetText()) then
		local height = dd:GetHeight() or 0
		if height <= 0 then return end

		-- Measured where the template exposes the arrow, so the fallback is only ever used
		-- on a template that names it something else.
		local chevron = FG_STATUS_DROPDOWN_CHEVRON
		local arrow = dd.Arrow or dd.Chevron
		if type(arrow) == "table" and type(arrow.GetWidth) == "function" then
			local w = arrow:GetWidth()
			if w and w > 0 then chevron = w end
		end

		local target = math.ceil(height + chevron + FG_STATUS_DROPDOWN_EXTRA)
		if math.abs((dd:GetWidth() or 0) - target) >= 1 then
			dd:SetWidth(target)
		end
		return
	end

	-- A client that puts words here: measure, and only ever grow, so a correct native
	-- layout is never fought.
	local width = (type(fs.GetUnboundedStringWidth) == "function") and fs:GetUnboundedStringWidth()
		or (type(fs.GetStringWidth) == "function") and fs:GetStringWidth()
		or nil
	if not width or width <= 0 then return end

	local needed = math.min(math.ceil(width) + FG_STATUS_DROPDOWN_PADDING, FG_STATUS_DROPDOWN_MAX_WIDTH)
	if (dd:GetWidth() or 0) < needed then
		dd:SetWidth(needed)
	end
end

-- ============================================================================
-- [[ STREAMER MODE: THE PLAYER'S OWN BATTLETAG ]]
-- The Battle.net bar prints the player's own BattleTag beside the status control. Masking
-- every contact on the list and then leaving the owner's own account name across the top of
-- the window would be pointless, so it is replaced outright with a label.
--
-- Replaced rather than masked, unlike every contact row. The three revealed characters exist
-- so the OWNER can still tell their contacts apart; nobody needs three characters to
-- recognise their own account, so the slot is better spent confirming at a glance that the
-- mode is actually on -- which is exactly what you want to see before you start streaming.
--
-- Blizzard draws it and exposes no handle for it, so the fontstring is FOUND rather than
-- addressed: BNGetInfo reports the player's own BattleTag, and the bar is walked for the
-- fontstring displaying it. Matching on the value rather than on a parentKey means this
-- keeps working if the template is reshuffled, and needs no knowledge of a name that is not
-- documented anywhere.
--
-- The original is HIDDEN and a replacement is drawn over it, rather than having its text
-- rewritten. Two reasons: Blizzard re-sets that text from its own handlers and would win any
-- tug-of-war over it, and leaving the real value in place keeps the search predicate above
-- valid, so the region can still be re-found later.
-- ============================================================================
local FG_OwnTagFontString = nil
local FG_OwnTagOverlay = nil
-- True only while WE are the reason the copy button is hidden, so turning the mode off can
-- never re-show a button Blizzard had hidden for its own reasons (the bar hides
-- BattleNetUnavailableNoticeButton the same way).
local FG_CopyButtonHidden = false

-- The "copy my BattleTag" button, addressed by the parentKeys the bar actually uses:
--   BattleNetBar > ControlsContainer > PersonalBattleTagDisplay > CopyBattleTagToClipboardButton
-- Every frame on that path is anonymous, so the keys are the only handle -- and they were
-- read off the live frame tree (/fg bar) rather than guessed.
--
-- Falls back to scanning the tag's own parent for a key containing "Copy", so a rename costs
-- the button staying visible rather than an error.
local function FG_CopyTagButton(bar, tagParent)
	local controls = bar and bar.ControlsContainer
	local display = controls and controls.PersonalBattleTagDisplay
	local button = display and display.CopyBattleTagToClipboardButton
	if type(button) == "table" and type(button.Hide) == "function" then return button end

	if type(tagParent) == "table" then
		for key, value in pairs(tagParent) do
			if type(key) == "string" and key:find("Copy")
				and type(value) == "table" and type(value.Hide) == "function" then
				return value
			end
		end
	end
	return nil
end

local function FG_OwnBattleTag()
	if type(BNGetInfo) ~= "function" then return nil end
	local ok, _, battleTag = pcall(BNGetInfo)
	if not ok or type(battleTag) ~= "string" or battleTag == "" then return nil end
	return battleTag
end

-- Blizzard's own horizontal insets for the window title, READ FROM ITS DECLARED ANCHORS.
--
-- GetPoint reports what was SET, not where the frame currently is, so unlike GetCenter or
-- GetWidth it answers correctly even before a layout pass. That distinction is the one this
-- file keeps having to relearn: measuring early returns nil and silently takes a fallback.
--
-- Observed on a live frame stack, and the defaults below if the frame cannot be read:
--   TOPLEFT  SocialUIFrame TOPLEFT   58, -1
--   TOPRIGHT SocialUIFrame TOPRIGHT -24, -1
--
-- Only accepted when TitleContainer is anchored to SocialUIFrame, because that is what makes
-- the numbers transferable to the Battle.net bar, which spans the same frame edge to edge.
local FG_TITLE_INSET_LEFT = 58
local FG_TITLE_INSET_RIGHT = -24

-- Vertical nudge for the replacement label. The horizontal span above is anchored to the BAR,
-- so the label inherits the bar's vertical centre -- but the BattleTag it stands in for sits a
-- few pixels above that, inside its own plate. This is the difference, measured off the two
-- side by side rather than derived: the tag's frame is not a usable vertical anchor here,
-- because a single SetPoint carries both axes and the horizontal has to come from the bar.
local FG_TITLE_LABEL_NUDGE_Y = 4

local function FG_TitleInsets()
	local left, right = FG_TITLE_INSET_LEFT, FG_TITLE_INSET_RIGHT

	local title = SocialUIFrame and SocialUIFrame.TitleContainer
	if not title or type(title.GetNumPoints) ~= "function" then return left, right end

	for i = 1, title:GetNumPoints() do
		local point, relativeTo, _, x = title:GetPoint(i)
		if type(point) == "string" and type(x) == "number" and relativeTo == SocialUIFrame then
			-- "TOPLEFT" matches LEFT and not RIGHT, and vice versa, so the order is safe.
			if point:find("LEFT") then
				left = x
			elseif point:find("RIGHT") then
				right = x
			end
		end
	end

	return left, right
end

-- Depth-limited for the same reason FG_CollectDropdowns is: this walks a UI subtree on a
-- refresh path, and an unbounded descent through a frame graph is not something to run there.
local function FG_FindFontStringWithText(frame, text, depth)
	if type(frame) ~= "table" or type(text) ~= "string" or depth > 4 then return nil end

	if type(frame.GetRegions) == "function" then
		local regions = { frame:GetRegions() }
		for i = 1, #regions do
			local region = regions[i]
			if type(region) == "table" and type(region.GetObjectType) == "function"
				and region:GetObjectType() == "FontString" then
				local current = region:GetText()
				if type(current) == "string" and current:find(text, 1, true) then
					return region
				end
			end
		end
	end

	if type(frame.GetChildren) ~= "function" then return nil end
	local kids = { frame:GetChildren() }
	for i = 1, #kids do
		local found = FG_FindFontStringWithText(kids[i], text, depth + 1)
		if found then return found end
	end
	return nil
end

-- The one entry point every caller uses (FriendGroups_ApplyStreamerMode, and the event frame
-- at the foot of this file). It dispatches on which contact list is live, because 12.1 can be
-- running either: the Social UI's Battle.net bar, or 12.0.7's FriendsFrameBattlenetFrame.
--
-- Dispatching HERE rather than at the call sites is deliberate -- the caller's question is
-- "hide my BattleTag", and which panel is on screen is this file's business.
function Compat.RefreshOwnBattleTag()
	if not Compat.IsSocialUIActive() then
		-- Forward-declared above this function, so the legacy panel is reached rather than
		-- silently skipped -- which is what this early return used to do.
		return FG_RefreshOwnBattleTagLegacy()
	end

	local bar = SocialUIFrame and SocialUIFrame.BattleNetBar
	if not bar then return end

	local streamerMode = (type(FriendGroups_IsStreamerMode) == "function") and FriendGroups_IsStreamerMode()

	local tag = FG_OwnBattleTag()
	if not tag then return end

	if not FG_OwnTagFontString then
		FG_OwnTagFontString = FG_FindFontStringWithText(bar, tag, 1)
		if not FG_OwnTagFontString then
			-- Second pass on the name half alone, for a client that prints the tag without
			-- its discriminator. Safe here in a way it would not be over the contact list:
			-- this bar carries the player's own identity and nobody else's.
			local namePart = tag:match("^(.-)#")
			if namePart and namePart ~= "" then
				FG_OwnTagFontString = FG_FindFontStringWithText(bar, namePart, 1)
			end
		end
	end
	if not FG_OwnTagFontString then return end

	local tagParent = FG_OwnTagFontString:GetParent() or bar
	local copyButton = FG_CopyTagButton(bar, tagParent)

	if not streamerMode then
		if FG_OwnTagOverlay then FG_OwnTagOverlay:Hide() end
		FG_OwnTagFontString:Show()
		-- Restored ONLY if we were the ones who hid it.
		if copyButton and FG_CopyButtonHidden then
			copyButton:Show()
			FG_CopyButtonHidden = false
		end
		return
	end

	-- [[ COPY BUTTON ]] It copies the real BattleTag to the clipboard, so leaving it under a
	-- label that exists to conceal that BattleTag is worse than pointless -- and with the
	-- label now centred on the plate, the button sat in the middle of the text.
	if copyButton and copyButton:IsShown() then
		copyButton:Hide()
		FG_CopyButtonHidden = true
	end

	-- [[ PARENTED TO THE STRING IT REPLACES, NOT TO THE BAR ]]
	-- Created on the found fontstring's OWN parent. Parenting it to the BattleNetBar instead
	-- is why it rendered as a blank gap: the tag lives inside a nested frame (the dark plate
	-- it sits on), and a CHILD FRAME draws above every draw layer of its parent -- so an
	-- OVERLAY fontstring on the bar sits behind that plate no matter what sublevel it is
	-- given. It was being drawn correctly the whole time, just underneath the art.
	--
	-- Re-created only if the parent ever differs, which in practice happens once.
	-- (tagParent is resolved above, alongside the copy button that shares this frame.)
	if not FG_OwnTagOverlay or FG_OwnTagOverlay:GetParent() ~= tagParent then
		if FG_OwnTagOverlay then FG_OwnTagOverlay:Hide() end
		FG_OwnTagOverlay = tagParent:CreateFontString(nil, "OVERLAY")
	end
	-- Above any sibling art on that same frame, for the same reason.
	FG_OwnTagOverlay:SetDrawLayer("OVERLAY", 7)

	-- Re-adopted on every pass, not only at creation: a font that is re-stated each time
	-- cannot be left unset by whatever state the source region happened to be in on the one
	-- pass that built it. A fontstring with no font renders nothing, silently.
	FG_AdoptFont(FG_OwnTagOverlay, FG_OwnTagFontString)
	-- And themed, for the reason the legacy path documents: adoption copies the source's font
	-- OBJECT, which a skin's SetFont override does not replace.
	FG_ApplyThemeFont(FG_OwnTagOverlay, FG_EUITheme())

	-- ====================================================================
	-- [[ CENTRED UNDER THE WINDOW TITLE ]]
	-- Spanned across the bar with the SAME horizontal insets Blizzard gives its title, and
	-- centred within that span. So the label sits directly under "Friends" by construction,
	-- rather than by an offset someone tuned against one locale.
	--
	-- Two earlier attempts missed for the same underlying reason -- anchoring to whatever
	-- frame happened to be nearby:
	--   LEFT to the tag      -- started where a shorter string started and ran rightwards
	--                           through the copy button.
	--   CENTER on the plate  -- PersonalBattleTagDisplay is a small frame sitting AT the tag,
	--                           so centring inside it barely moves anything.
	--
	-- And the window centre is not the answer either: the title's insets are ASYMMETRIC (58
	-- left against 24 right, to clear the portrait), so "Friends" sits about 17px right of
	-- centre. Copying the insets reproduces that offset exactly and for free.
	--
	-- Re-anchored every pass, because the bar is re-laid-out whenever the panel is resized.
	-- ====================================================================
	local insetLeft, insetRight = FG_TitleInsets()
	FG_OwnTagOverlay:ClearAllPoints()
	FG_OwnTagOverlay:SetPoint("LEFT", bar, "LEFT", insetLeft, FG_TITLE_LABEL_NUDGE_Y)
	FG_OwnTagOverlay:SetPoint("RIGHT", bar, "RIGHT", insetRight, FG_TITLE_LABEL_NUDGE_Y)
	FG_OwnTagOverlay:SetJustifyH("CENTER")

	-- Battle.net blue, not the source string's colour. This label stands where the BattleTag
	-- stands, so it takes the colour Battle.net identity is drawn in everywhere else in the
	-- addon; inheriting the plain white of the tag fontstring read as a system error message
	-- sitting in the middle of the bar. Same fallback ladder the alt tooltip's BattleTag line
	-- uses, so both surfaces are the same blue by construction.
	local tagColor = FRIENDS_BNET_NAME_COLOR or BATTLENET_FONT_COLOR or CreateColor(0.510, 0.773, 1.0)
	FG_OwnTagOverlay:SetTextColor(tagColor.r, tagColor.g, tagColor.b)

	-- The MENU's own label, not a second string saying the same thing. A dedicated
	-- STREAMER_MODE_BAR key existed and every locale had translated it identically to
	-- SET_STREAMER_MODE, so it was twelve more strings to keep in step for no gain -- and one
	-- of them drifting would have put different wording on the bar than in the menu.
	FG_OwnTagOverlay:SetText(L["SET_STREAMER_MODE"])
	FG_OwnTagOverlay:Show()
	FG_OwnTagFontString:Hide()
end

-- ============================================================================
-- [[ THE LEGACY CONTACT LIST ON A 12.1 CLIENT ]]
-- 12.1 shipped the Social UI but did NOT switch it on: C_SocialUI.IsSystemEnabled() is
-- server-driven and answers false on live, so the window the player opens is the 12.0.7
-- FriendsFrame. Compat.IsSocialUIActive reports this correctly and the list itself renders
-- through the retail ScrollBox path as it always did.
--
-- What did NOT survive are the two decorations that were only ever built against the new
-- panel, because on the PTR that was the only panel there was:
--
--   the streamer-mode BattleTag label -- Compat.RefreshOwnBattleTag returned immediately
--   without the Social UI, so masking every contact on the list still left the owner's own
--   BattleTag across the top of the window, which is most of the point of the mode;
--
--   the FriendGroups mark on the window portrait -- FG_RefreshPortrait did the same, so the
--   panel kept Blizzard's default portrait.
--
-- Both are re-implemented here against the legacy frame rather than by loosening the guards
-- above: the two panels are different frames with different anchors, and the Social UI path is
-- staying exactly as it is for the patch where Blizzard turns it back on.
--
-- Every symbol is presence-guarded and every runtime function re-tests
-- Compat.IsSocialUIActive, so this section is inert the moment the Social UI goes live and
-- nothing here needs unwinding when it does.
-- ============================================================================
local FG_LegacyTagFontString = nil
local FG_LegacyTagOverlay = nil
-- True only while WE are the reason the copy button is hidden, exactly as FG_CopyButtonHidden
-- is for the Social UI bar.
local FG_LegacyCopyHidden = false
local FG_LegacyHooksInstalled = false

-- "Is the legacy contact list the live one, and does it exist yet?"
local function FG_LegacyListLive()
	if Compat.IsSocialUIActive() then return false end
	return type(_G.FriendsFrame) == "table"
end

-- [[ STREAMER MODE: THE PLAYER'S OWN BATTLETAG, LEGACY PANEL ]]
-- The same substitution the Social UI path makes, against a much easier target: FriendsFrame
-- names this fontstring $parentTag, so it is reachable as FriendsFrameBattlenetFrame.Tag and
-- needs none of the search-by-value the anonymous Battle.net bar required. Confirmed on a live
-- 12.1 frame stack, which reports the tag under the mouse as exactly that key.
--
-- The value search is kept as a fallback for a build that renames the key, and it is safe here
-- for the same reason it is safe there: this frame carries the player's own identity and
-- nobody else's.
--
-- HIDDEN and drawn over, never rewritten -- Blizzard re-sets that text from its own status
-- handlers and would win any tug-of-war over it.
FG_RefreshOwnBattleTagLegacy = function()
	if not FG_LegacyListLive() then return end

	local bar = _G.FriendsFrameBattlenetFrame
	if type(bar) ~= "table" then return end

	local streamerMode = (type(FriendGroups_IsStreamerMode) == "function") and FriendGroups_IsStreamerMode()

	if not FG_LegacyTagFontString then
		if type(bar.Tag) == "table" and type(bar.Tag.GetText) == "function" then
			FG_LegacyTagFontString = bar.Tag
		else
			local tag = FG_OwnBattleTag()
			if tag then
				FG_LegacyTagFontString = FG_FindFontStringWithText(bar, tag, 1)
			end
		end
	end

	local tagFS = FG_LegacyTagFontString
	if not tagFS then return end

	local tagParent = tagFS:GetParent() or bar
	local copyButton = FG_CopyTagButton(bar, tagParent)

	if not streamerMode then
		if FG_LegacyTagOverlay then FG_LegacyTagOverlay:Hide() end
		tagFS:Show()
		-- Restored ONLY if we were the ones who hid it.
		if copyButton and FG_LegacyCopyHidden then
			copyButton:Show()
			FG_LegacyCopyHidden = false
		end
		return
	end

	-- A button that copies the real BattleTag to the clipboard, sitting under a label whose
	-- job is to conceal that BattleTag, is worse than pointless.
	if copyButton and copyButton:IsShown() then
		copyButton:Hide()
		FG_LegacyCopyHidden = true
	end

	-- Parented to the string it replaces, for the reason the Social UI path documents at
	-- length: a child frame draws above every draw layer of its parent, so an overlay on the
	-- outer frame can end up behind the plate the tag sits on.
	if not FG_LegacyTagOverlay or FG_LegacyTagOverlay:GetParent() ~= tagParent then
		if FG_LegacyTagOverlay then FG_LegacyTagOverlay:Hide() end
		FG_LegacyTagOverlay = tagParent:CreateFontString(nil, "OVERLAY")
	end
	FG_LegacyTagOverlay:SetDrawLayer("OVERLAY", 7)

	-- Re-adopted every pass: a fontstring with no font renders nothing, silently.
	--
	-- Then handed to the theme, because adoption ALONE is not enough under the EllesmereUI
	-- skin and looked like it should have been. FG_AdoptFont prefers the source's font
	-- OBJECT, and the skin re-fonts the BattleTag with SetFont -- an override that leaves
	-- GetFontObject still answering Blizzard's original object. So the label copied the
	-- object, not the override, and sat there in Friz Quadrata while every string around it
	-- was EllesmereUI's font. The chrome font is re-stated over the top at the size adoption
	-- just resolved, and is a no-op when the skin is off or absent.
	FG_AdoptFont(FG_LegacyTagOverlay, tagFS)
	FG_ApplyFontPath(FG_LegacyTagOverlay, FG_EUIChromeFontPath())

	-- [[ CENTRED ON THE STRING IT REPLACES, NOT SPANNED ACROSS THE BAR ]]
	-- The Social UI label had to copy the panel title's asymmetric insets because its bar spans
	-- the whole window and the tag sits off-centre within it. Here the tag is already where the
	-- label belongs, so a single CENTER anchor reproduces its position exactly.
	--
	-- CENTER specifically, and not SetAllPoints: pinning all four corners of a fontstring that
	-- is auto-sized to "OSiRiS#1322" would truncate a longer replacement string, and every
	-- locale's translation of this label is longer.
	FG_LegacyTagOverlay:ClearAllPoints()
	FG_LegacyTagOverlay:SetPoint("CENTER", tagFS, "CENTER", 0, 0)
	FG_LegacyTagOverlay:SetJustifyH("CENTER")

	-- Battle.net blue, from the same fallback ladder the Social UI label and the alt tooltip's
	-- BattleTag line use, so all three are the same colour by construction.
	local tagColor = FRIENDS_BNET_NAME_COLOR or BATTLENET_FONT_COLOR or CreateColor(0.510, 0.773, 1.0)
	FG_LegacyTagOverlay:SetTextColor(tagColor.r, tagColor.g, tagColor.b)

	-- The MENU's own label rather than a second string saying the same thing, so the bar and
	-- the menu entry can never drift apart in any locale.
	FG_LegacyTagOverlay:SetText(L["SET_STREAMER_MODE"])
	FG_LegacyTagOverlay:Show()
	tagFS:Hide()
end

-- [[ FRIENDGROUPS MARK ON THE LEGACY PANEL PORTRAIT ]]
-- The mark is on the portrait ALWAYS, on every tab of the legacy window, over its own black
-- backing. There is no tab detection here and that is deliberate.
--
-- The Social UI path above scopes its mark to the Friends tab, and this was written the same way
-- twice. Both attempts produced a portrait that flipped between Blizzard's art and ours depending
-- on which tab you had visited and in what order, and was often blank on the first open. The
-- reason is that on the legacy panel every input to that decision is unreliable at the moment it
-- has to be made: PanelTemplates_GetSelectedTab reports the INNER strip (12.1's Contacts tab has
-- its own Friends / Recent Allies / Recruit A Friend tabs) and never leaves 1; the sub-frame
-- visibility lags the tab click by a frame; the portrait is unpainted at PLAYER_ENTERING_WORLD, so
-- there is no reliable moment to capture Blizzard's own art to put back; and Blizzard repaints
-- from paths that are not reachable by any hook this addon can install cleanly.
--
-- Every one of those is a race, and a race decides the portrait. Branding all four tabs of a
-- window the addon has taken over is a small, DETERMINISTIC cost, and it is the right trade: the
-- window is FriendGroups' either way, and a wrong-but-stable portrait beats a correct-but-flickering
-- one. If the Social UI ever goes live, its own path is untouched and keeps the per-tab behaviour.
--
-- The texture the panel actually draws its portrait into, newest shape first. 12.1 converted
-- FriendsFrame to the PortraitContainer/CircleMask template, so the vestigial FriendsFrameIcon
-- global from the old art is no longer the visible one -- writing to it is why a mark can be
-- set successfully and still not appear.
local function FG_LegacyPortraitTexture(frame)
	if type(frame.GetPortrait) == "function" then
		local portrait = frame:GetPortrait()
		if portrait then return portrait end
	end
	if type(_G.FriendsFramePortrait) == "table" then return _G.FriendsFramePortrait end
	if type(_G.FriendsFrameIcon) == "table" then return _G.FriendsFrameIcon end
	return nil
end

-- Guards the SetPortraitToAsset post-hook below against re-entering on our own write.
local FG_LegacyPortraitWriting = false

local function FG_RefreshPortraitLegacy()
	if not FG_LegacyListLive() then return end

	local frame = _G.FriendsFrame
	local portrait = FG_LegacyPortraitTexture(frame)
	if not portrait then return end

	-- The backing follows the mark, so it is shown whenever the mark is -- which is always. Still
	-- suppressed under a skin that removes portraits (EllesmereUI's window engine alpha-zeroes
	-- them): our mark disappears with Blizzard's texture there, but the backing is a separate
	-- texture no such pass enumerates, and would be left as a black disc floating in its place.
	local suppressed = FG_PortraitIsSuppressed(frame)
	FG_EnsurePortraitBacking(frame, suppressed)
	if frame.fgPortraitBacking then
		frame.fgPortraitBacking:SetShown(not suppressed)
	end

	-- Written even while suppressed: it costs nothing against an invisible texture and leaves no
	-- state of ours to unwind if the skin hiding it is switched off.
	FG_LegacyPortraitWriting = true
	if type(frame.SetPortraitToAsset) == "function" then
		frame:SetPortraitToAsset(FG_PORTRAIT_ASSET)
	else
		portrait:SetTexture(FG_PORTRAIT_ASSET)
	end
	FG_LegacyPortraitWriting = false
end

-- [[ RE-ASSERT ON ANY REPAINT, WHEREVER IT COMES FROM ]]
-- The hooks in Compat.InitLegacyContactList cover the paths that are nameable -- tab clicks and
-- panel show. This covers the ones that are not: whoever repaints the portrait, from wherever, is
-- answered immediately with ours again.
--
-- This is what makes "always the FG logo" hold without a list of every Blizzard code path that
-- touches it, which is the list the two tab-scoped attempts kept getting wrong.
--
-- Recursion is the obvious hazard and the flag above is the whole defence: our own write re-enters
-- this hook, and it returns before doing anything. The asset test is a second stop, so a write of
-- the same asset from anywhere else is also a no-op rather than a bounce.
local function FG_HookLegacyPortraitSetter()
	local frame = _G.FriendsFrame
	if type(frame) ~= "table" then return end
	if frame.fgPortraitSetterHooked then return end
	if type(frame.SetPortraitToAsset) ~= "function" then return end

	frame.fgPortraitSetterHooked = true
	hooksecurefunc(frame, "SetPortraitToAsset", function(_, asset)
		if FG_LegacyPortraitWriting then return end
		if type(asset) == "string" and asset:lower():find("friendgroups", 1, true) then return end
		FG_RefreshPortraitLegacy()
	end)
end

-- [[ PORTRAIT PROBE ]] /fg portrait
-- What the portrait holds and which pieces are installed. Reduced along with the logic above --
-- there is no tab decision left to interrogate, so what remains is "is our mark on it, and is the
-- backing there". Reads only, so it is safe to run at any time.
function Compat.ReportLegacyPortrait()
	local frame = _G.FriendsFrame
	if type(frame) ~= "table" then
		DEFAULT_CHAT_FRAME:AddMessage("FriendGroups: no FriendsFrame on this client.")
		return
	end

	local portrait = FG_LegacyPortraitTexture(frame)
	local current
	if portrait then
		current = (type(portrait.GetAtlas) == "function") and portrait:GetAtlas() or nil
		if current == nil and type(portrait.GetTexture) == "function" then
			current = portrait:GetTexture()
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage(string.format(
		"FriendGroups portrait -- hooks=%s socialUI=%s suppressed=%s backing=%s",
		tostring(FG_LegacyHooksInstalled), tostring(Compat.IsSocialUIActive()),
		tostring(FG_PortraitIsSuppressed(frame)),
		frame.fgPortraitBacking and (frame.fgPortraitBacking:IsShown() and "shown" or "hidden") or "none"))
	DEFAULT_CHAT_FRAME:AddMessage(string.format(
		"  portrait=%s texture=%s",
		portrait and (portrait:GetName() or "anonymous") or "NONE", tostring(current)))
	DEFAULT_CHAT_FRAME:AddMessage(string.format(
		"  setPortraitToAsset=%s setterHooked=%s panelSetTab=%s friendsFrameUpdate=%s",
		type(frame.SetPortraitToAsset), tostring(frame.fgPortraitSetterHooked == true),
		type(_G.PanelTemplates_SetTab), type(_G.FriendsFrame_Update)))
end

-- Installation is NOT gated on the Social UI being off, for the mirror image of the reason
-- Compat.InitSocialUI is not gated on it being on: C_SocialUI.IsSystemEnabled() is
-- server-driven and may not have arrived yet, and an unchanged status fires no event to retry
-- on. Both runtime functions re-test it, so installing on a client that later turns the Social
-- UI on costs two hooks that decide to do nothing.
function Compat.InitLegacyContactList()
	if FG_LegacyHooksInstalled then return end

	local frame = _G.FriendsFrame
	if type(frame) ~= "table" then return end

	FG_LegacyHooksInstalled = true

	-- The catch-all: anyone repainting the portrait gets ours back. Installed first, because it is
	-- the one that does not depend on knowing which paths repaint.
	FG_HookLegacyPortraitSetter()

	-- [[ TAB CHANGES ]]
	-- Still hooked even though the mark is now tab-independent: Blizzard repaints per tab, and
	-- SetPortraitToAsset is not guaranteed to be how it does it -- a direct SetTexture on the
	-- portrait region would slip past the setter hook above. This is the belt to its braces.
	--
	-- Deferred as well as immediate, because FriendsFrameTab_OnClick calls PanelTemplates_SetTab
	-- and THEN repaints the panel, so a post-hook here runs before that repaint. One frame later
	-- is after everything the click does, in whatever order it does it.
	--
	-- Filtered to FriendsFrame: this global fires for every tabbed panel in the UI.
	if type(_G.PanelTemplates_SetTab) == "function" then
		hooksecurefunc("PanelTemplates_SetTab", function(tabbedFrame)
			if tabbedFrame ~= _G.FriendsFrame then return end
			FG_RefreshPortraitLegacy()
			C_Timer.After(0, FG_RefreshPortraitLegacy)
		end)
	end

	-- Kept as a second signal for the BattleTag, which Blizzard's status handlers rewrite from
	-- this path. Optional by design -- everything that MUST happen is wired above and below.
	if type(_G.FriendsFrame_Update) == "function" then
		hooksecurefunc("FriendsFrame_Update", function()
			FG_RefreshPortraitLegacy()
			FG_RefreshOwnBattleTagLegacy()
		end)
	end

	-- The one path that must re-assert the label: this is where Blizzard writes the tag, and a
	-- SetText on a hidden fontstring does not reveal it -- but a Show() alongside it would.
	if type(_G.FriendsFrame_CheckBattlenetStatus) == "function" then
		hooksecurefunc("FriendsFrame_CheckBattlenetStatus", FG_RefreshOwnBattleTagLegacy)
	end

	-- Deferred one frame as well as immediate: the panel is laid out AS it opens -- on the first
	-- open the BattleTag fontstring may not have been given its text yet, and OnShow runs before
	-- the panel has repainted itself for the tab it is opening on.
	frame:HookScript("OnShow", function()
		FG_RefreshPortraitLegacy()
		C_Timer.After(0, function()
			FG_RefreshPortraitLegacy()
			FG_RefreshOwnBattleTagLegacy()
		end)
	end)

	-- Painted here unconditionally, open or not. The previous version waited for the panel to be
	-- shown so that Blizzard's own art could be captured first -- and that wait is why the mark
	-- was missing on the first load. There is nothing to capture any more, so the mark goes on
	-- immediately and the hooks above only ever have to re-assert it.
	FG_RefreshPortraitLegacy()
	FG_RefreshOwnBattleTagLegacy()
end

-- Self-contained wiring. PLAYER_ENTERING_WORLD is the first point at which both
-- SocialUIFrame's content frames and FriendGroups.lua's globals are guaranteed to exist.
-- SOCIAL_UI_SYSTEM_STATUS_UPDATED is what Blizzard fires when C_SocialUI.IsSystemEnabled()
-- changes, so a client that enables the Social UI mid-session still gets hooked.
-- Compat.RegisterEvents validates each name, so an event this client does not know is
-- skipped instead of erroring.
--
-- The BN_* events keep the status preview honest after the player changes their own status.
-- Every name is validated by Compat.RegisterEvents, so the ones a given client does not know
-- are skipped rather than erroring -- which is why several candidates can be listed without
-- having to pin down which one 12.1 actually fires for a self-status change.
local FG_SocialUIInitFrame = CreateFrame("Frame")
Compat.RegisterEvents(FG_SocialUIInitFrame, {
	"PLAYER_ENTERING_WORLD",
	"SOCIAL_UI_SYSTEM_STATUS_UPDATED",
	"BN_INFO_CHANGED",
	"BN_SELF_ONLINE",
	"BN_SELF_OFFLINE",
})
FG_SocialUIInitFrame:SetScript("OnEvent", function(self, event)
	Compat.InitSocialUI()
	-- Both are attempted on every event and both latch, because which one has anything to do
	-- is decided by a server-driven flag that can arrive late or change mid-session.
	Compat.InitLegacyContactList()
	-- Deferred on every event, including the two below that skip the status refresh: the bar
	-- is built and re-laid-out during login, so the first pass that can actually find the
	-- BattleTag fontstring is the one that runs after the current frame settles.
	C_Timer.After(0, function() Compat.RefreshOwnBattleTag() end)
	if event ~= "PLAYER_ENTERING_WORLD" and event ~= "SOCIAL_UI_SYSTEM_STATUS_UPDATED" then
		-- Status changed. Blizzard rewrites the label from its own handler, so the width is
		-- re-derived a frame later against whatever it settled on.
		C_Timer.After(0, function()
			Compat.RefreshStatusDropdown()
			Compat.RefreshOwnBattleTag()
		end)
	end
end)
