-- 12.1 Social UI renderer: the layout FriendGroups_FriendsListUpdate builds, as a
-- TreeDataProvider. Blizzard's factory picks templates by node shape (isSpacer, headerText,
-- else card), so nodes must match {headerText} > {isSpacer}, {friendIndex, accountInfo}.

local addonName, addonTable = ...
local Compat = addonTable.Compat
local L = addonTable.L
local Perf = addonTable.Perf

-- The Social UI ships on retail and Forever only. Classic keeps the HybridScroll
-- renderer in Platform_Render.lua and never loads any of this.
if not Compat.IS_RETAIL_UI then return end

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

-- Set only once FG_InstallCardHeightOverride has been accepted, not merely tried.
local cardHeightInstalled = false

-- Diagnostic counters (see FriendGroups_GetSocialUIState). Cheap integers, incremented on
-- the row path so "the hook never fired" can be told apart from "the hook fired and bailed".
local FG_RowApplyCalls = 0
local FG_RowApplyApplied = 0
local FG_AltTooltipCalls = 0

-- Forward declarations: without them a later definition compiles as a nil global lookup,
-- which luac -p cannot catch.
local FG_ApplySocialCardContent
local FG_OnCardShowTooltip
local FG_OnCardHideTooltip
local FG_HookSearchBox
-- Defined next to the other menu work, far below, but called from the renderer above it.
-- Without this forward declaration that call would compile as a GLOBAL lookup and be nil
-- at runtime -- the exact silent-failure class this file's header warns about.
local FG_HookFilterDropdown
local FG_RefreshPortrait
-- Legacy-panel half of the streamer-mode BattleTag, defined at the foot of this file.
local FG_RefreshOwnBattleTagLegacy
-- Defined with the row-density constants below; retried from Compat.RenderSocialUIList.
local FG_InstallCardHeightOverride
local FG_UpdateContactCounter
local FG_ContactCountText, FG_ContactCountHover

-- Four digits of GameFontNormalSmall plus padding: the online count is capped in practice
-- by the 600-contact Battle.net limit the cap tooltip reports.
local FG_CONTACT_COUNT_WIDTH = 36

-- [[ ELLESMEREUI COLOURISE ]] Tint only regions we already write. FriendGroupsEUISkin is looked
-- up at call time: EllesmereSkin.lua loads last. Nil on Classic.
local function FG_EUITheme()
	local skin = _G.FriendGroupsEUISkin
	if type(skin) ~= "table" or type(skin.GetTheme) ~= "function" then return nil end
	return skin.GetTheme()
end

-- [[ FONT ADOPTION ]] Copy a Blizzard string's face: font object first (keeps text scaling),
-- then GetFont, then a named default. A fontstring with no font renders nothing, silently.
-- EUI re-font keeps Blizzard's size; a nil flag keeps the string's, "" means no outline.
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

-- Font of the legacy window's chrome, not theme.fontPath (EUI's 12.1 font): they differ once
-- the user sets a per-module override.
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

-- [[ HEADER TEXT ]] Label only: the header's one string is left-aligned, so the count is drawn
-- separately, right-aligned, by FG_ApplyHeaderDecoration.
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

-- Same semantics as FriendGroups_FriendsListUpdateDividerTemplate: online/Raw (or Total).
-- Overrides are passed only while a native Status/Tags filter is active (count the survivors).
local function FG_BuildHeaderCount(groupName, overrideOnline, overrideTotal)
	if type(groupName) ~= "string" or groupName == "" then return "" end
	if groupName == L["GROUP_EMPTY"] then return "" end

	local counts = State and State.groupsCount and State.groupsCount[groupName]
	local online = overrideOnline or (counts and counts.Online) or 0
	local total = overrideTotal or (counts and (counts.Raw or counts.Total)) or 0

	-- Offline groups show the total alone. Type-checked: this file loads before FriendGroups.lua.
	if type(FriendGroups_IsOfflineGroup) == "function" and FriendGroups_IsOfflineGroup(groupName) then
		return string.format(L["SOCIALUI_GROUP_COUNT_TOTAL"], total)
	end

	return string.format(L["SOCIALUI_GROUP_COUNT"], online, total)
end

-- [[ GROUP HEADER ]] Left-click collapses via FriendGroups_FrameFriendDividerTemplateCollapseClick
-- (where Auto Collapse lives), right-click opens the retail group menu, via the rawGroupName and
-- name aliases. RegisterForClicks must include RightButtonUp.
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

-- Blizzard's factory re-sets OnClick after every Initialize, discarding a HookScript, so watch
-- SetScript itself. The guard flag stops our own assignment re-entering.
local function FG_InstallHeaderClickTakeover(header, groupName)
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

	-- Drag lives in Platform_Drag.lua; the factory only re-sets OnClick, so its scripts survive.
	Compat.AttachHeaderDrag(header, groupName)

	FG_ApplyHeaderClickScript(header)
end

-- [[ COLLAPSE INDICATOR ]] Matched by atlas: the chevrons have no key and their index is
-- template order. Tint only while themed (vertex colour multiplies the atlas); the flag restores white.
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

-- [[ HEADER COUNT ]] Our own fontstring, anchored to the header's right edge with a constant
-- inset. Never measure the chevron (frames aren't laid out yet) or anchor to it (its region
-- isn't proven to be the glyph); a blank header list resulted both times.
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

	-- Colour copied from ButtonText every pass: this pooled string has no template to reset it,
	-- and skipping nil overrides carried colours between groups.
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
	-- Shared drag code tests this flag.
	header.fgIsHeader = true
	-- The retail handler reads frame.name:GetText() as its fallback label.
	header.name = header.name or header.ButtonText

	-- Banner at ARTWORK sublevel 1, above the NormalTexture; label lifted to OVERLAY. Draw layer
	-- re-applied every pass so older textures correct themselves.
	if not header.solidBannerTexture then
		header.solidBannerTexture = header:CreateTexture(nil, "ARTWORK")
		header.solidBannerTexture:SetAllPoints(header)
	end
	header.solidBannerTexture:SetDrawLayer("ARTWORK", 1)
	if header.ButtonText then
		header.ButtonText:SetDrawLayer("OVERLAY")

		FG_ApplyThemeFont(header.ButtonText, FG_EUITheme())

		-- Override wins, a banner implies white, else Blizzard's colour. Every pass (pooled header).
		State = State or addonTable.State
		if State and type(State.HeaderFontRGB) == "function" then
			local fontR, fontG, fontB = State.HeaderFontRGB(groupName)
			if fontR then header.ButtonText:SetTextColor(fontR, fontG, fontB) end
		end

		-- Normal/Highlight font swaps on hover re-apply the object's colour, so re-apply on enter and
		-- leave. Hooked once per frame: HookScript appends.
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
		-- No custom banner: house band when EUI colours exist, else hidden as on a plain client.
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

	FG_InstallHeaderClickTakeover(header, groupName)
end

local function FG_ClearHeaderDecoration(header)
	header.rawGroupName = nil
	header.fgIsHeader = nil
	if header.solidBannerTexture then header.solidBannerTexture:Hide() end
	if header.fgCountText then header.fgCountText:Hide() end
	Compat.DetachHeaderDrag(header)
end

-- Headers are pooled: Blizzard's Initialize rewrites only the title, so a scrolled-in header
-- kept the last group's banner, count and rawGroupName (clicks hit that group) until a rebuild.
local function FG_OnHeaderInitialize(header, node)
	header.fgHeaderInitHooked = true
	local data = node and type(node.GetData) == "function" and node:GetData()
	if type(data) == "table" and data.groupName then
		FG_ApplyHeaderDecoration(header, data.groupName, data.headerCount)
	elseif header.fgIsHeader then
		FG_ClearHeaderDecoration(header)
	end
end

local function FG_ApplyToVisibleCardsBody(view)
	local scrollBox = view and view.ScrollBox
	if not scrollBox or type(scrollBox.ForEachFrame) ~= "function" then return end

	scrollBox:ForEachFrame(function(frame)
		if type(frame) ~= "table" then return end

		-- Headers carry ButtonText and no FriendName; spacers carry neither. The element
		-- data is a tree NODE here, not a bare table, so it is unwrapped before reading.
		if frame.ButtonText and not frame.FriendName then
			-- Headers built before the mixin hook in InitSocialUI need their own.
			if not frame.fgHeaderInitHooked and type(frame.Initialize) == "function" then
				hooksecurefunc(frame, "Initialize", FG_OnHeaderInitialize)
				frame.fgHeaderInitHooked = true
			end
			local data = frame.GetElementData and frame:GetElementData()
			if data and type(data.GetData) == "function" then data = data:GetData() end
			if data and data.groupName then
				FG_ApplyHeaderDecoration(frame, data.groupName, data.headerCount)
			end
			return
		end

		if not frame.fgSocialCardHooked and type(frame.InitializeDisplay) == "function" then
			-- Cards made after InitSocialUI copied the hooked mixin method; a second hook here
			-- decorated every row twice per layout.
			local hasMixinHook = cardHookInstalled and type(FriendsListSocialCardMixin) == "table"
				and frame.InitializeDisplay == FriendsListSocialCardMixin.InitializeDisplay
			if not hasMixinHook then
				hooksecurefunc(frame, "InitializeDisplay", FG_ApplySocialCardContent)
			end

			-- Known-alts panel. HideTooltip is the "pointer left this row" signal: the
			-- GameTooltip:Hide hook keeps the panel up anywhere over the contact panel.
			if type(frame.ShowTooltip) == "function" then
				hooksecurefunc(frame, "ShowTooltip", FG_OnCardShowTooltip)
			end
			if type(frame.HideTooltip) == "function" then
				hooksecurefunc(frame, "HideTooltip", FG_OnCardHideTooltip)
			end

			frame.fgSocialCardHooked = true
		end

		-- SetDataProvider has just initialised these cards through the hook; only catch misses.
		if frame.fgAppliedData ~= frame.elementData then
			FG_ApplySocialCardContent(frame)
		end
	end)
end

local function FG_ApplyToVisibleCards(view)
	return Perf.Time("fg.cardPass", FG_ApplyToVisibleCardsBody, view)
end

-- [[ GROUP FILTER ]] Session state, not saved: a list that reloads filtered reads as missing
-- friends. Empty means unfiltered.
local FG_GroupFilter = {}

-- The group names of the last render, in the order they appeared on screen. Captured from
-- the buckets BEFORE any filtering, so a group hidden by the filter is still listed in the
-- menu -- otherwise ticking one group would make every other group unreachable.
local FG_LastGroupOrder = {}

-- Forced rebuild for display changes: RequestListUpdate's rosterUnchanged shortcut drops them.
-- Via State: FriendGroups_FriendsListUpdate is a file-local of FriendGroups.lua.
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

-- [[ NATIVE FILTER CHECKBOXES ]] Status/Tags: SearchFriends(BuildActiveSearchInfo()) returns
-- friend indices (same space as element.id), used as an allow-set. Once per rebuild, never
-- per keystroke; nil with nothing ticked.
local function FG_BuildFilterAllowSet(view)
	if not view or type(view.BuildActiveSearchInfo) ~= "function" then return nil end
	-- Through Compat.SearchFriends, which owns the forbidden latch.
	if Compat.IsSearchFriendsForbidden() then return nil end

	local ok, searchInfo = pcall(view.BuildActiveSearchInfo, view)
	if not ok or type(searchInfo) ~= "table" then return nil end

	-- BuildActiveSearchInfo returns every flag false and an empty tags table when nothing
	-- is ticked, so "any filter active" is exactly this test.
	local active = searchInfo.isOnline or searchInfo.isOffline or searchInfo.isDND
		or searchInfo.isAFK or searchInfo.isInQueue or searchInfo.isAvailableForQueue
		or (type(searchInfo.tags) == "table" and #searchInfo.tags > 0)
	if not active then return nil end

	-- Text cleared: our matcher sees notes, groups and alts the server can't, and ANDing would
	-- drop those matches.
	searchInfo.searchText = ""

	local friendsData = Compat.SearchFriends(searchInfo)
	if not friendsData then return nil end

	local allowed = {}
	for _, friendIndex in ipairs(friendsData) do
		allowed[friendIndex] = true
	end
	return allowed
end

-- [[ RENDERER ]] Skips INVITE rows (their own tab on 12.1) and WOW rows (no accountInfo card).
-- True while a row's menu is open or a button is held over the list: a rebuild would release it.
local function FG_RowInteractionActive(view)
	local manager = Menu and type(Menu.GetManager) == "function" and Menu.GetManager()
	local menu = manager and manager:GetOpenMenu()
	local owner = menu and type(menu.GetOwnerRegion) == "function" and menu:GetOwnerRegion()
	for _ = 1, 6 do
		if not owner then break end
		if owner == view.ScrollBox then return true end
		owner = type(owner.GetParent) == "function" and owner:GetParent() or nil
	end
	return (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton"))
		and view.ScrollBox:IsMouseOver()
end

local FG_DeferredLayout

-- [[ EVENT DIET ]] Social UI twin of the FriendsFrame diet in FriendGroups.lua. Blizzard's view
-- rebuilt its whole list on every BN_FRIEND_INFO_CHANGED; the roster engine already rebuilds ours.
-- The view re-registers in each OnShow, so this re-runs then. docs: FriendGroups-friends-list-freeze.md
local FG_DIET_EVENT = "BN_FRIEND_INFO_CHANGED"
local FG_DietActive = false

local function FG_UpdateEventDiet()
	local view = SocialUIFrame and SocialUIFrame.FriendsList
	if type(view) ~= "table" or type(view.UnregisterEvent) ~= "function" then return end
	-- Hidden: Blizzard's OnHide has dropped the event and its OnShow will add it back.
	if not view:IsVisible() then
		FG_DietActive = false
		return
	end
	local inCharge = Compat.IsSocialUIActive() and FG_SocialProvider ~= nil
		and view.ScrollBox ~= nil and view.ScrollBox:GetDataProvider() == FG_SocialProvider
	if inCharge then
		view:UnregisterEvent(FG_DIET_EVENT)
		FG_DietActive = true
	elseif FG_DietActive then
		view:RegisterEvent(FG_DIET_EVENT)
		FG_DietActive = false
	end
end

-- [[ SCROLL MEMORY ]] Blizzard's own list, swapped in on every BN_FRIEND_INFO_CHANGED, is
-- shorter than ours and its layout clamps the offset; ours kept the clamp, so the list jumped
-- up near the bottom. Why: Desktop\Claude\FriendGroups\FriendGroups-socialui-scroll.md.
local FG_ScrollMemory = { offset = nil, atEnd = false }
local FG_InstallingProvider = false

-- Every user scroll (wheel, bar, ScrollTo*) passes SetScrollPercentage. So does the scrollbar's
-- echo of each layout, which during our own install would record the clamp: skipped there.
local function FG_RememberScroll(scrollBox, scrollPercentage)
	if FG_InstallingProvider then return end
	if not FG_SocialProvider or scrollBox:GetDataProvider() ~= FG_SocialProvider then return end
	if type(scrollPercentage) ~= "number" then return end
	local pct = math.min(math.max(scrollPercentage, 0), 1)
	FG_ScrollMemory.atEnd = pct >= 0.999
	FG_ScrollMemory.offset = scrollBox:GetDerivedScrollRange() * pct
end

local function FG_InstallScrollMemory(scrollBox)
	if scrollBox.fgScrollMemoryHooked or type(scrollBox.SetScrollPercentage) ~= "function" then return end
	scrollBox.fgScrollMemoryHooked = true
	hooksecurefunc(scrollBox, "SetScrollPercentage", FG_RememberScroll)
end

local function FG_RestoreScroll(scrollBox)
	local offset = FG_ScrollMemory.offset
	if not offset then return end
	local noLerp = ScrollBoxConstants.NoScrollInterpolation
	if FG_ScrollMemory.atEnd then
		if not scrollBox:IsAtEnd() then scrollBox:ScrollToEnd(noLerp) end
	elseif math.abs(scrollBox:GetDerivedScrollOffset() - offset) >= 1 then
		scrollBox:ScrollToOffset(offset, noLerp)
	end
end

-- The only way FriendGroups puts its list in, so the echo guard and the restore are never missed.
local function FG_SetOurProvider(scrollBox, provider)
	FG_InstallingProvider = true
	Perf.Time("fg.setProvider", scrollBox.SetDataProvider, scrollBox, provider, ScrollBoxConstants.RetainScrollPosition)
	FG_InstallingProvider = false
	FG_RestoreScroll(scrollBox)
end

local function FG_RenderSocialUIList(layout)
	State = State or addonTable.State

	local view = Compat.GetSocialUIFriendsView()
	if not view or not view.ScrollBox then return end
	if type(layout) ~= "table" then return end

	-- Held, not dropped: the newest layout runs as soon as the click or menu is done.
	if FG_RowInteractionActive(view) then
		Perf.Count("render.held")
		local alreadyWaiting = FG_DeferredLayout ~= nil
		FG_DeferredLayout = layout
		if not alreadyWaiting then
			local function retry()
				local current = Compat.GetSocialUIFriendsView()
				if current and FG_RowInteractionActive(current) then
					C_Timer.After(0.2, retry)
					return
				end
				local pending = FG_DeferredLayout
				FG_DeferredLayout = nil
				if pending then Compat.RenderSocialUIList(pending) end
			end
			C_Timer.After(0.2, retry)
		end
		return
	end
	FG_DeferredLayout = nil

	-- Guards so a reshuffle degrades to "no grouping" instead of erroring every refresh.
	if type(CreateTreeDataProvider) ~= "function" then return end
	if type(ScrollBoxConstants) ~= "table" or ScrollBoxConstants.RetainScrollPosition == nil then return end
	if type(TreeDataProviderMixin) ~= "table" or type(TreeDataProviderMixin.Event) ~= "table" then return end

	-- Retried until accepted: InitSocialUI's attempt can precede the view's first render.
	if not cardHeightInstalled then
		cardHeightInstalled = FG_InstallCardHeightOverride(view)
	end

	local provider = CreateTreeDataProvider()

	-- Nil unless a Status or Tags box is ticked, in which case it is the set of friend
	-- indices Blizzard's own search allows through.
	local allowSet = FG_BuildFilterAllowSet(view)

	-- Bucket first: a header goes in before its children, but its count and visibility depend
	-- on which members survive the filter.
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

			-- Re-read per build, like Blizzard's generator. element.id is the Battle.net friend index.
			local accountInfo = allowed and Compat.GetFriendAccountInfo(element.id) or nil
			if accountInfo then
				-- Blizzard's card tooltip (an unhookable local) prints the note verbatim: strip our grammar
				-- here. Safe to mutate: this accountInfo table is fresh and ours alone.
				if type(accountInfo.note) == "string" then
					accountInfo.note = FriendGroups_NoteForDisplay(accountInfo.note)
				end

				-- friendIndex/accountInfo for Blizzard's card; id/buttonType for our row code. Title friends
				-- stay FRIENDS_BUTTON_TYPE_WOW (no alt panel), never flattened to BNET.
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

		-- Group filter drops unticked groups; Status/Tags drops groups with no survivors. With
		-- neither active, only Hide Empty Groups decides.
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

			-- Factory reads only headerText; the extra fields ride along for FG_ApplyHeaderDecoration.
			local headerNode = provider:Insert({
				headerText = FG_BuildHeaderText(bucket.groupName),
				headerCount = headerCount,
				groupName = bucket.groupName,
			})

			-- Seed collapse before inserting children; skip invalidation (provider not attached yet).
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

	-- Collapse flows one way: click handler writes SavedVars and rebuilds. No reverse callback.
	FG_InstallScrollMemory(view.ScrollBox)
	FG_SocialProvider = provider
	FG_SetOurProvider(view.ScrollBox, provider)
	FG_UpdateEventDiet()

	-- Blizzard's element factory has just initialised the visible cards with its own text.
	-- Apply the FriendGroups display settings over the top, and hook each frame so a
	-- recycle re-applies them. Runs after SetDataProvider so the frames exist and are bound.
	FG_ApplyToVisibleCards(view)

	-- The online total is recomputed by the rebuild that produced this layout, so refresh
	-- the title here too -- RefreshTitle alone only fires on tab changes.
	FG_UpdateContactCounter(view)

	-- [[ ELLESMEREUI WIDGET PASS ]] Here, not at init: these widgets are built lazily. Idempotent.
	local skin = _G.FriendGroupsEUISkin
	if skin and type(skin.SkinSocialWidgets) == "function" then
		skin.SkinSocialWidgets(view)
	end

	-- Retried here as well as at init, in case the view was not built yet; a local flag
	-- makes the repeat free.
	FG_HookFilterDropdown(view)
end

function Compat.RenderSocialUIList(layout)
	return Perf.Time("fg.render", FG_RenderSocialUIList, layout)
end

-- [[ PROVIDER RE-ASSERT ]] Blizzard's Refresh installs its flat provider; ours goes back in the
-- same execution. HasSocialUIProvider stops the roster shortcut skipping a combat-deferred
-- first build.
function Compat.HasSocialUIProvider()
	return FG_SocialProvider ~= nil
end

local function FG_ReassertSocialUIProvider()
	if not FG_SocialProvider then return end

	local view = Compat.GetSocialUIFriendsView()
	if not view or not view.ScrollBox then return end
	if type(ScrollBoxConstants) ~= "table" or ScrollBoxConstants.RetainScrollPosition == nil then return end
	if view.ScrollBox:GetDataProvider() == FG_SocialProvider then return end

	FG_SetOurProvider(view.ScrollBox, FG_SocialProvider)
	FG_UpdateEventDiet()

	-- The swap re-initialises the visible cards from Blizzard's factory, wiping our text.
	FG_ApplyToVisibleCards(view)
end

function Compat.ReassertSocialUIProvider()
	return Perf.Time("fg.reassert", FG_ReassertSocialUIProvider)
end

-- [[ ROW CONTENT ]] Runs after InitializeCardDisplayText and re-states only what a setting
-- changes, so a disabled setting leaves Blizzard's text alone.

-- [[ ROW DENSITY ]] Base heights (TextSizeManager still scales them), matching retail's 34px
-- two-line row rather than Blizzard's 70px card.
local FG_CARD_HEIGHT_COMPACT = 24    -- one rich line
local FG_CARD_HEIGHT_WITH_NOTE = 34  -- rich line plus the second line, as retail

-- Inline icon size, in the same units the row's font uses.
local FG_ROW_ICON_SIZE = 14

-- Bounds for the presence-dot column. 16 is retail's own STATUS_W; the ceiling exists so a
-- dot measured off a mis-sized card can never claim the name's width (see the status block
-- in FG_ApplySocialCardContent).
local FG_STATUS_MIN_WIDTH = 16
local FG_STATUS_MAX_WIDTH = 24

-- Floor on the text column's share; only a broken row height reaches it. Above 0.4 it shaved
-- the right reserve on Large text in a narrow panel.
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

-- [[ ROW FONT SCALE ]] 1 Small, 2 Medium, 3 Large. fontDelta applies to Blizzard's pristine size.
-- Heights are explicit, not a multiplier: padding is fixed, so scaling the row clipped Small.
-- Check any retune against CJK names, which are taller.
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

-- Row height, uniform across the list; the note line is budgeted whenever the setting is on.
local function FG_GetCardBaseHeight()
	local step = FG_FontScaleStep()
	if type(FriendGroups_SavedVars) == "table" and FriendGroups_SavedVars.show_note then
		return step.noteHeight
	end
	return step.compactHeight
end

-- Scaled exactly as Blizzard's CalculateTemplateExtent scales a card's base height.
local function FG_ScaledCardHeight(view)
	local base = FG_GetCardBaseHeight()
	local registration = view.TemplateRegistrations["FriendsListSocialCardTemplate"]
	if type(TextSizeManager) ~= "table" then return base end
	if registration and registration.useScaleWeightForHeight then
		return TextSizeManager:GetScaledValueWeighted(base, registration)
	end
	return TextSizeManager:GetScaledValue(base)
end

-- Our own extent calculator; never write TemplateRegistrations or fill TemplateExtentCache.
-- Refresh wipes that cache just before the protected SearchFriends, and wiping entries our
-- code computed got it forbidden on Forever. Headers and spacers use Blizzard's uncached math.
local FG_ExtentScrollView
FG_InstallCardHeightOverride = function(view)
	local scrollBox = view and view.ScrollBox
	local scrollView = scrollBox and type(scrollBox.GetView) == "function" and scrollBox:GetView()
	if not scrollView or type(scrollView.SetElementExtentCalculator) ~= "function" then return false end
	if type(view.CalculateTemplateExtent) ~= "function" or type(view.TemplateRegistrations) ~= "table" then
		return false
	end
	if FG_ExtentScrollView == scrollView then return true end
	FG_ExtentScrollView = scrollView

	scrollView:SetElementExtentCalculator(function(_, node)
		local t0 = Perf.on and debugprofilestop()
		local data = node and type(node.GetData) == "function" and node:GetData()
		local extent
		if data and data.isSpacer then
			extent = view:CalculateTemplateExtent("SocialUIScrollableSpacerTemplate")
		elseif data and data.headerText ~= nil then
			extent = view:CalculateTemplateExtent("SocialUIScrollableHeaderTemplate")
		else
			extent = FG_ScaledCardHeight(view)
		end
		if t0 then Perf.Extent(t0) end
		return extent
	end)
	return true
end

-- [[ CLASS ICON ]] Retail geometry: row height - 4, LEFT +4. The gutter follows the setting,
-- not whether the class is known, or offline and app rows shift left.
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

	-- Same expression as the legacy renderer; the status dot has its own column to the right.
	local iconGutter = showIcons and (iconSize + 8) or 6

	-- Hide the texture but keep the column, so classless rows line up.
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

	-- Greyed when the class is a guess (main or cached alt), not the live character. Always
	-- re-stated: pooled rows would otherwise keep a previous friend's grey.
	icon:SetDesaturated(desaturated and true or false)
	icon:SetAlpha(desaturated and 0.6 or 1)
	icon:Show()

	return iconGutter
end

-- [[ ROW FONT SIZE ]] SetFont pins ONE file; a font object picks the file per script, |K
-- names included. So each pass asks the object, on a hidden string, which file this text
-- needs. Why: Desktop\Claude\FriendGroups\FriendGroups-row-font-files.md.
local FG_FontResolver

local function FG_ResolveFontFile(object, text)
	if not object then return nil end
	if not FG_FontResolver then
		local holder = CreateFrame("Frame")
		holder:Hide()
		FG_FontResolver = holder:CreateFontString(nil, "OVERLAY")
	end
	FG_FontResolver:SetFontObject(object)
	FG_FontResolver:SetText(text or "")
	local path = FG_FontResolver:GetFont()
	FG_FontResolver:SetText("")
	return path
end

local function FG_ShrinkFont(card, fontString, key)
	if not fontString then return end

	card.fgBaseFont = card.fgBaseFont or {}
	local base = card.fgBaseFont[key]

	-- Captured on the first pass, before any SetFont of ours: re-reading the size later
	-- returns the shrunk value and compounds. The object survives our SetFont.
	if not base then
		local path, size, flags = fontString:GetFont()
		if not path or not size then return end
		local object = (type(fontString.GetFontObject) == "function") and fontString:GetFontObject() or nil
		base = { object = object, path = path, size = size, flags = flags }
		card.fgBaseFont[key] = base
	end

	local path = FG_ResolveFontFile(base.object, fontString:GetText())
	local flags = base.flags

	-- EllesmereUI's theme font replaces the family; folded into this write, which runs on every recycle.
	local theme = FG_EUITheme()
	if theme and theme.fontPath then
		path = theme.fontPath
		if theme.fontFlag ~= nil then flags = theme.fontFlag end
	end

	-- No object to ask: stay on Blizzard's font at its own size rather than pin a guess.
	if not path then return end

	local size = base.size + FG_FontScaleStep().fontDelta
	if size < 6 then size = 6 end

	fontString:SetFont(path, size, flags)
end

-- [[ RIGHT-SIDE ICON CLUSTER ]] Faction icon then realm flag (0.75 size), leftwards from the
-- game icon. Returns the right reserve; hidden icons give their width back.
local function FG_UpdateRightIcons(card, gameInfo, iconSize)
	local gameIcon = card.GameIconHolder
	if not gameIcon then return 31 end

	-- One size for every row icon; Blizzard's game icon holder is fixed 20x20 in XML, so resize it.
	local iconW, iconH = iconSize, iconSize
	gameIcon:SetSize(iconSize, iconSize)

	-- [[ SHOW GAME ICON ]] Blizzard re-decides visibility first on every initialise, so apply the
	-- setting after: hide it, drop it from the reserve, slide faction/realm into its slot.
	local showGameIcon = not (FriendGroups_SavedVars.show_game_icon == false)
	if not showGameIcon then
		gameIcon:Hide()
	elseif gameIcon.Icon then
		-- Same bundled logo as every other client's Forever row.
		if gameInfo and Compat.IsForeverGame(gameInfo) then gameIcon.Icon:SetTexture(Compat.FOREVER_ICON) end
		-- Blizzard fades other projects to 0.6; FriendGroups shows every game at full brightness.
		gameIcon.Icon:SetAlpha(1)
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
		local faction = gameInfo.factionName
		if (not faction or faction == "") and Compat.IsForeverGame(gameInfo) then
			faction = FriendGroups_ForeverFaction(card.elementData and card.elementData.accountInfo)
		end
		facPath = FriendGroups_GetFactionIcon(faction) or ""
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
		local accountInfo = card.elementData and card.elementData.accountInfo
		flagPath = FriendGroups_GetRealmInfo(gameInfo, FriendGroups_AccountIdentifier(accountInfo))
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

local function FG_ApplySocialCardContentBody(card)
	FG_RowApplyCalls = FG_RowApplyCalls + 1

	if not Compat.IsSocialUIActive() then return end
	if type(FriendGroups_SavedVars) ~= "table" then return end

	local elementData = card and card.elementData
	local accountInfo = elementData and elementData.accountInfo
	if not accountInfo then return end
	-- Blizzard's element (no buttonType) while ours exists: replaced in this same execution.
	if FG_SocialProvider and elementData.buttonType == nil then return end

	FG_RowApplyApplied = FG_RowApplyApplied + 1
	card.fgAppliedData = elementData
	State = State or addonTable.State

	-- Make the card answer to the legacy row contract. FriendGroups_ShowButtonAltTooltip
	-- reads button.id and button.buttonType off whatever frame it is handed, so stamping
	-- them here lets the hover path below pass the card straight in.
	card.id = elementData.friendIndex
	card.buttonType = elementData.buttonType or FRIENDS_BUTTON_TYPE_BNET

	local gameInfo = accountInfo.gameAccountInfo
	local client, characterName, class, level, realmName
	local classIsMain = false

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
			class, classIsMain = FriendGroups_LookupAccountClass(accountInfo, characterName, realmName)
			classIsMain = classIsMain and true or false
		end

	end

	-- Offline: the selected main's class, greyed. Never overrides a class found above.
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

	-- [[ TITLE FRIENDS ]] accountName is a character name, so render retail's character-friend
	-- row (bracketed class-coloured name and level), keeping the 12.1 nickname.
	local isTitleFriend = false
	if type(FriendsListUtil) == "table" and type(FriendsListUtil.IsTitleFriend) == "function" then
		isTitleFriend = FriendsListUtil.IsTitleFriend(accountInfo) and true or false
	end

	local line
	if isTitleFriend then
		local displayName = characterName or accountInfo.accountName or UNKNOWN

		-- [[ STREAMER MODE ]] Offline, accountName is a |K escape that can't be sliced:
		-- FriendGroups_StreamerName falls back to the name recorded while online.
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

	-- [[ NAME COLOUR ]] Colour from FriendsFrame_GetBNetAccountNameAndStatus, as retail does.
	if type(FriendsFrame_GetBNetAccountNameAndStatus) == "function" then
		local _, nameColor = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo)

		-- [[ ONE COLOUR FOR EVERY TIER ]] Online is Battle.net blue for title friends too (12.1 uses
		-- white), so class colour alone conveys class.
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

	-- [[ SECOND LINE ]] location, then the note after two spaces ("Zone - Realm  #VVIP").
	-- Cross-project friends have no areaName; like the legacy row, they show Blizzard's
	-- rich presence instead of "Unknown".
	local secondLine = ""
	if gameInfo and gameInfo.isOnline then
		if Compat.IsForeverGame(gameInfo) then
			-- Same "Zone - Forever Normal" line on every client.
			secondLine = FriendGroups_GetOnlineInfoText(
				client, gameInfo.isWowMobile, accountInfo.rafLinkType,
				Compat.ForeverLocation(gameInfo, FriendGroups_SavedVars.show_realm)) or ""
		elseif FriendGroups_ShowRichPresenceOnly(client, gameInfo.wowProjectID, gameInfo.factionName,
			gameInfo.realmID, gameInfo.areaName) then
			secondLine = FriendGroups_GetOnlineInfoText(
				client, gameInfo.isWowMobile, accountInfo.rafLinkType, gameInfo.richPresence) or ""
		else
			secondLine = FriendGroups_GetOnlineInfoText(
				client, gameInfo.isWowMobile, accountInfo.rafLinkType,
				gameInfo.areaName, realmName) or ""
		end
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

	-- [[ TYPE SIZE ]] Reset the font object before shrinking or it compounds on every recycle.
	-- Must run before the geometry below, which measures the text.
	FG_ShrinkFont(card, card.FriendName, "FriendName")
	FG_ShrinkFont(card, card.Location, "Location")

	-- [[ RETAIL ROW GEOMETRY ]] After Blizzard's pass, which re-applies its three-row layout. One
	-- icon size (row height - 4) for every icon; text block vertically centred.
	local iconSize = (card:GetHeight() or 0) - 4
	if iconSize <= 0 then iconSize = 16 end

	local leftPad = FG_UpdateClassIcon(card, class, iconSize, classIsMain)

	-- [[ STATUS COLUMN ]] Presence dot and favourite star share one column between class icon
	-- and text, as FriendGroups_ApplyRowLayout does. Blizzard's dot is re-anchored; fgStatus stays hidden.
	local showStatus = FriendGroups_SavedVars.show_status ~= false
	local hasStar = card.StateDisplay and card.StateDisplay:IsShown()

	if card.fgStatus then card.fgStatus:Hide() end

	-- Measured (scales with Blizzard's text), default 16, and clamped: a 70px card at login once
	-- reserved 60px and left the name an ellipsis.
	local statusW = card.PresenceHolder and card.PresenceHolder:GetWidth()
	if not statusW or statusW < FG_STATUS_MIN_WIDTH then statusW = FG_STATUS_MIN_WIDTH end
	if statusW > FG_STATUS_MAX_WIDTH then statusW = FG_STATUS_MAX_WIDTH end

	if card.PresenceHolder then
		card.PresenceHolder:SetShown(showStatus)
		card.PresenceHolder:ClearAllPoints()
		-- "LEFT" anchors at the row's vertical middle, so the dot centres across both rows.
		card.PresenceHolder:SetPoint("LEFT", card, "LEFT", leftPad, 0)
	end

	-- [[ FAVOURITE STAR ]] Corner badge on the dot, or centred alone; drawn behind the dot.
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

	-- [[ THE NAME ALWAYS GETS ROOM ]] A wrong row height inflates both gutters; shrink them
	-- proportionally so the row stays legible.
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

	-- [[ VERTICAL CENTRING ]] From GetStringHeight (handles CJK and EUI fonts) and the card's real
	-- height. Needs FG_ShrinkFont to have run first.
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

	-- [[ FACTION ROW TINT ]] InitializeBackground restores the atlas each initialise; only tint.
	local tinted = false
	if gameInfo and FriendGroups_SavedVars.show_faction_color ~= false and card.Background then
		local faction = gameInfo.factionName
		if (not faction or faction == "") and Compat.IsForeverGame(gameInfo) then
			faction = FriendGroups_ForeverFaction(accountInfo)
		end
		if faction == "Horde" then
			card.Background:SetColorTexture(0.7, 0.2, 0.2, 0.2)
			tinted = true
		elseif faction == "Alliance" then
			card.Background:SetColorTexture(0.2, 0.2, 0.7, 0.2)
			tinted = true
		end
	end

	-- [[ ELLESMEREUI ROW WASH ]] Faction tint wins; written after InitializeBackground.
	if not tinted and card.Background then
		local theme = FG_EUITheme()
		if theme then
			local c = theme.rowBackground
			card.Background:SetColorTexture(c[1], c[2], c[3], c[4])
		end
	end
end

FG_ApplySocialCardContent = function(card)
	if not Perf.on then return FG_ApplySocialCardContentBody(card) end
	local t0 = debugprofilestop()
	FG_ApplySocialCardContentBody(card)
	Perf.Card(t0)
end

-- Alt panel for the hovered card, after Blizzard's tooltip has settled its size. Reads the
-- id/buttonType the content applier stamped.
FG_OnCardShowTooltip = function(card)
	FG_AltTooltipCalls = FG_AltTooltipCalls + 1

	if not Compat.IsSocialUIActive() then return end

	-- [[ STREAMER MODE ]] Blizzard's tooltip (an unhookable local) shows everything the masking
	-- hides, so hide it in this post-hook. Never the alt panel: it is masked and ours.
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

	-- Clear the hover anchor too: it holds SocialUIFrame on 12.1, and a stale one docks every
	-- game tooltip to the list. Via State (file-local in FriendGroups.lua).
	State = State or addonTable.State
	if State and type(State.ClearHoverAnchor) == "function" then
		State.ClearHoverAnchor()
	end
end

-- [[ GROUPS SUBMENU ]] Post-hook only: replacing menuGenerator tainted
-- selectedSearchFilterOptions and got SearchFriends forbidden on Forever.
local FG_FilterMenuHooked = false
FG_HookFilterDropdown = function(view)
	if FG_FilterMenuHooked then return false end
	if not view or type(view.GenerateSearchFilterMenu) ~= "function" then return false end
	FG_FilterMenuHooked = true

	hooksecurefunc(view, "GenerateSearchFilterMenu", function(_, rootDescription)
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

-- [[ HOOKS ]] Refresh and the search method are the only SetDataProvider callers. Post-hooks
-- on the view INSTANCE (mixin copies are made at OnLoad); never replace methods (12.2.2 taint).
-- The search method name changed in 12.1.0.69214, so it is optional.
local function FG_OnNativeRefresh(_, retainScrollPosition)
	Perf.HookStart()
	if not Compat.IsSocialUIActive() then return end

	-- OnShow and BN_DISCONNECTED discard on purpose: the list opens at the top.
	if not retainScrollPosition then
		FG_ScrollMemory.offset, FG_ScrollMemory.atEnd = nil, false
	end

	State = State or addonTable.State

	if FG_SocialProvider then
		-- Put the grouped provider back immediately, then let the coalescing timer
		-- rebuild the grouped data itself. FriendGroups_RequestListUpdate IS a global.
		Compat.ReassertSocialUIProvider()
		if type(FriendGroups_RequestListUpdate) == "function" then
			FriendGroups_RequestListUpdate()
		end
	elseif State and type(State.FriendsListUpdate) == "function" then
		-- First refresh: build now rather than show Blizzard's list for the throttle window.
		-- Via State: file-local in FriendGroups.lua.
		State.FriendsListUpdate(true)
	end
end

-- Separate from Refresh: Refresh may mean a roster change (throttled), this means only the
-- view changed (forced). Newest method name first.
local FG_SEARCH_HOOK_NAMES = {
	"RefreshSearchResults",   -- 12.1.0.69214 onwards
	"OnSearchEnterPressed",   -- earlier 12.1 builds
}

local FG_SearchForceTimer

local function FG_OnNativeSearchChanged()
	Perf.HookStart()
	if not Compat.IsSocialUIActive() then return end

	-- Immediate: Blizzard's handler has just put its own provider in, and leaving it up even
	-- for one frame flashes the ungrouped list.
	Compat.ReassertSocialUIProvider()

	-- Coalesced: RefreshSearchResults can fire per keystroke.
	if FG_SearchForceTimer then FG_SearchForceTimer:Cancel() end
	FG_SearchForceTimer = C_Timer.NewTimer(0.05, function()
		FG_SearchForceTimer = nil
		FG_ForceListRebuild()
	end)
end

-- Not gated on IsSocialUIActive: the server status may arrive late and an unchanged status
-- fires no event. Acting is decided at call time.
-- /fg perf attaches its end-of-refresh mark only after the Refresh hook below exists.
Perf.fgHooksReady = function() return hooksInstalled end

Perf.AddContext(function()
	if not Compat.IsSocialUIActive() then
		return "Social UI module: not in use, the legacy friends list is (Social UI lines below stay empty)"
	end
	local view = SocialUIFrame and SocialUIFrame.FriendsList
	local diet = "n/a, list closed"
	if view and type(view.IsVisible) == "function" and view:IsVisible() then
		local listens = type(view.IsEventRegistered) == "function" and view:IsEventRegistered(FG_DIET_EVENT)
		diet = string.format("%s, Blizzard listening %s", tostring(FG_DietActive), tostring(listens))
	end
	return string.format("Social UI module: hooks %s, grouped list %s, groups %d, row height %s (override %s), event diet %s",
		tostring(hooksInstalled), tostring(FG_SocialProvider ~= nil), #FG_LastGroupOrder,
		tostring(math.floor(FG_GetCardBaseHeight() or 0)), tostring(cardHeightInstalled), diet)
end)

function Compat.InitSocialUI()
	if hooksInstalled then return end

	local view = SocialUIFrame and SocialUIFrame.FriendsList
	if not view then return end

	-- Gate on Refresh alone: an optional method going missing (12.1.0.69214) once disabled every
	-- hook. A missing method may cost only its own feature.
	if type(view.Refresh) ~= "function" then return end

	hooksInstalled = true

	hooksecurefunc(view, "Refresh", FG_OnNativeRefresh)

	-- After Blizzard's OnShow, which re-registers its events and refreshes.
	view:HookScript("OnShow", FG_UpdateEventDiet)
	view:HookScript("OnHide", FG_UpdateEventDiet)

	-- First match only: two hooks would force two rebuilds per click.
	for i = 1, #FG_SEARCH_HOOK_NAMES do
		local methodName = FG_SEARCH_HOOK_NAMES[i]
		if type(view[methodName]) == "function" then
			hooksecurefunc(view, methodName, FG_OnNativeSearchChanged)
			break
		end
	end

	-- Recorded, not assumed: a miss here (view not built yet) is retried on the next rebuild,
	-- otherwise rows stay at Blizzard's 70px card for the session.
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

	-- Mixin hook reaches cards created after this; the pool builds its first card on first open.
	if type(FriendsListSocialCardMixin) == "table"
		and type(FriendsListSocialCardMixin.InitializeDisplay) == "function" then
		hooksecurefunc(FriendsListSocialCardMixin, "InitializeDisplay", FG_ApplySocialCardContent)
		cardHookInstalled = true
	end

	-- Same for group headers, created after this point. Other Social UI lists share the
	-- template; their nodes carry no groupName, so the handler leaves them alone.
	if type(SocialUIScrollableHeaderMixin) == "table"
		and type(SocialUIScrollableHeaderMixin.Initialize) == "function" then
		hooksecurefunc(SocialUIScrollableHeaderMixin, "Initialize", FG_OnHeaderInitialize)
	end
end

-- [[ PANEL SIZE ]] Width via baseUIPanelWidth plus SetWidth so the UIPanel manager and side
-- windows stay right; height is a plain SetHeight. Skipped in combat (UIPanel taint).
-- Two widths: visual <Size x="410"> and baseUIPanelWidth 460. Don't mix them up.
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

	-- Both halves: SetWidth resizes the frame, baseUIPanelWidth tells the panel manager.
	frame:SetWidth(FG_PanelBaseVisualWidth + extraWidth)
	frame.baseUIPanelWidth = FG_PanelBaseUIWidth + extraWidth
	if type(frame.TryRefreshUIPanelWidth) == "function" then
		frame:TryRefreshUIPanelWidth()
	end

	-- The fixed-width Battle.net bar is anchored by TOP, so content anchored to it gains half the
	-- width. Re-anchor horizontally to the frame. Friends tab's frame only.
	local view = Compat.GetSocialUIFriendsView()
	if view and frame.BattleNetBar then
		view:ClearAllPoints()
		view:SetPoint("TOP", frame.BattleNetBar, "BOTTOM", 0, 5)
		view:SetPoint("LEFT", frame, "LEFT", 2, 0)
		view:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
	end

	-- [[ BATTLE.NET BAR ]] Stretch the fixed 413px bar to the frame; SetAllPoints its fixed-size
	-- background atlas (tile it instead if it distorts).
	local bar = frame.BattleNetBar
	if bar then
		bar:ClearAllPoints()
		bar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -22)
		bar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -22)
		if bar.Background then
			bar.Background:ClearAllPoints()
			bar.Background:SetAllPoints(bar)
		end
		-- Next frame: the dropdown's width is unresolved until the next layout pass.
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

	-- Existing rows keep their built width; rebuild the provider to re-layout. Deferred and
	-- flagged so a burst of size clicks makes one rebuild.
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

-- [[ SEARCH ]] Drive Blizzard's search box with our live matcher (0.3s debounce) instead of
-- its per-Enter SearchFriends. HookScript keeps its clear button and instructions.
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

-- [[ PORTRAIT ]] Our mark only on the Friends tab, Blizzard's restored elsewhere. Rides
-- RefreshVisuals, which runs on every tab change.
local FG_PORTRAIT_ASSET = "Interface\\AddOns\\FriendGroups\\Textures\\fg"

-- [[ PORTRAIT SUPPRESSION ]] A skin (EUI WSkin.RemovePortrait) can hide the portrait but not
-- our separate backing, leaving a black disc. Measured every call, not "EUI loaded".
local function FG_PortraitIsSuppressed(frame)
	local container = frame.PortraitContainer
	if container and container:GetAlpha() <= 0.01 then return true end
	-- FriendGroups' own EUI skin hides the container (alpha stays 1). IsShown, not visibility.
	if container and not container:IsShown() then return true end

	local portrait = type(frame.GetPortrait) == "function" and frame:GetPortrait() or nil
	if portrait and portrait:GetAlpha() <= 0.01 then return true end

	return false
end

-- Shared with ContactsMark.lua: a removed portrait is what leaves its band empty.
Compat.PortraitIsSuppressed = FG_PortraitIsSuppressed

-- [[ BACKING ]] Round black backing (TempPortraitAlphaMask) behind our transparent mark, one
-- layer below the portrait. Never built while suppressed. One per frame.
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

-- [[ CONTACT COUNT ]] In the filter bar gap between search and Filter, gated on
-- show_contact_cap. An invisible frame carries the hover; the tooltip is the legacy
-- counter's own FriendGroups_ShowContactTooltip.
FG_UpdateContactCounter = function(view)
	if type(FriendGroups_SavedVars) ~= "table" then return end

	local filterBar = view and view.FilterBar
	if not filterBar then return end

	if not FG_ContactCountText then
		FG_ContactCountText = filterBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		-- Fixed four-digit slot: a text-sized string grows left under the search box.
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

	-- Re-point only the search bar's RIGHT anchor; no cycle (counter -> dropdown, search -> counter).
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

-- [[ SETTINGS MENU ]] The gear lives on the hidden FriendsListFrame, so inject
-- FriendGroups_BuildSettingsMenu (as a submenu) into the Battle.net bar's menu tag.
local function FG_InjectSettingsMenu(ownerRegion, rootDescription)
	if not Compat.IsSocialUIActive() then return end
	if type(FriendGroups_BuildSettingsMenu) ~= "function" then return end
	if type(rootDescription) ~= "table" or type(rootDescription.CreateButton) ~= "function" then return end

	local submenu = rootDescription:CreateButton(L["SETTINGS_TITLE"])
	FriendGroups_BuildSettingsMenu(ownerRegion, submenu)
end

-- Registered at load: needs no frame, and keeps settings reachable if list hooks fail.
if Compat.HAS_MENU_API then
	Menu.ModifyMenu("MENU_SOCIAL_UI_BATTLE_NET_BAR", FG_InjectSettingsMenu)
end

-- [[ DIAGNOSTIC ]] /run: 1 socialUIActive, 2 viewExists, 3 hooksInstalled, 4 providerBuilt,
-- 5 providerInstalled, 6 cardHookInstalled, 7 rowApplyCalls, 8 rowApplyApplied, 9 dragStarts,
-- then panel sizes, cardHeightInstalled and row height (false with ~70 = login race).
function FriendGroups_GetSocialUIState()
	local view = SocialUIFrame and SocialUIFrame.FriendsList
	local installed = false
	if view and view.ScrollBox and FG_SocialProvider then
		installed = (view.ScrollBox:GetDataProvider() == FG_SocialProvider)
	end
	return Compat.IsSocialUIActive(), view ~= nil, hooksInstalled, FG_SocialProvider ~= nil, installed,
		cardHookInstalled, FG_RowApplyCalls, FG_RowApplyApplied, FG_AltTooltipCalls,
		Compat.GetHeaderDragStarts(),
		SocialUIFrame and math.floor(SocialUIFrame:GetWidth() or 0) or 0,
		SocialUIFrame and math.floor(SocialUIFrame:GetHeight() or 0) or 0,
		SocialUIFrame and math.floor(SocialUIFrame.baseUIPanelWidth or 0) or 0,
		cardHeightInstalled,
		math.floor(FG_GetCardBaseHeight() or 0)
end

-- [[ STATUS DROPDOWN PREVIEW ]] Blizzard bug: an ellipsis instead of the status. First widen
-- if the text is set but truncated; else derive it (BNGetInfo has no Appear Offline flag).

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

-- Matched by method (SetupMenu/OpenMenu), not name. The hamburger is a menu button too: the
-- status control has a text label and is the leftmost.
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

-- True when the label is only ellipsis. Strip U+2026 first: %w is ASCII-only, so the test
-- needs the high-byte range for CJK labels.
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

	-- Icon only, like 12.1's native status dot.
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

	-- [[ ICON-ONLY ]] Width = the control's own height plus the chevron. Never measure a |T|t
	-- escape: it doesn't measure like what it draws.
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

-- [[ STREAMER MODE: OWN BATTLETAG ]] Replaced with a label, not masked. Found by its value
-- (BNGetInfo), hidden, and drawn over: Blizzard re-sets its text and would win.
local FG_OwnTagFontString = nil
local FG_OwnTagOverlay = nil
-- True only while WE are the reason the copy button is hidden, so turning the mode off can
-- never re-show a button Blizzard had hidden for its own reasons (the bar hides
-- BattleNetUnavailableNoticeButton the same way).
local FG_CopyButtonHidden = false

-- Copy button via BattleNetBar.ControlsContainer.PersonalBattleTagDisplay.
-- CopyBattleTagToClipboardButton, falling back to a "Copy" key scan.
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

-- Title insets from TitleContainer's declared anchors (GetPoint works before layout), only if
-- anchored to SocialUIFrame. Defaults: TOPLEFT 58,-1 / TOPRIGHT -24,-1.
local FG_TITLE_INSET_LEFT = 58
local FG_TITLE_INSET_RIGHT = -24

-- Measured: the tag sits a few pixels above the bar's vertical centre.
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

-- Dispatches to whichever contact list is live.
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

	-- Parented to the tag's own parent: on the bar it drew under the tag's plate (child frames
	-- draw above parent layers).
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

	-- [[ CENTRED UNDER THE WINDOW TITLE ]] Same asymmetric insets as the title, so it sits under
	-- "Friends". Re-anchored every pass (resizes re-lay the bar).
	local insetLeft, insetRight = FG_TitleInsets()
	FG_OwnTagOverlay:ClearAllPoints()
	FG_OwnTagOverlay:SetPoint("LEFT", bar, "LEFT", insetLeft, FG_TITLE_LABEL_NUDGE_Y)
	FG_OwnTagOverlay:SetPoint("RIGHT", bar, "RIGHT", insetRight, FG_TITLE_LABEL_NUDGE_Y)
	FG_OwnTagOverlay:SetJustifyH("CENTER")

	-- Battle.net blue, same fallbacks as the alt tooltip's BattleTag line.
	local tagColor = FRIENDS_BNET_NAME_COLOR or BATTLENET_FONT_COLOR or CreateColor(0.510, 0.773, 1.0)
	FG_OwnTagOverlay:SetTextColor(tagColor.r, tagColor.g, tagColor.b)

	-- The menu's own label; a separate key duplicated it in every locale.
	FG_OwnTagOverlay:SetText(L["SET_STREAMER_MODE"])
	FG_OwnTagOverlay:Show()
	FG_OwnTagFontString:Hide()
end

-- [[ THE LEGACY CONTACT LIST ON A 12.1 CLIENT ]] Streamer label and portrait mark for the
-- 12.0.7 FriendsFrame. Every function re-tests IsSocialUIActive, so it is inert once it's on.
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

-- [[ STREAMER MODE: LEGACY PANEL ]] FriendsFrameBattlenetFrame.Tag, value search as fallback.
-- Hidden and drawn over, never rewritten.
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

	-- Adopt every pass, then re-state the EUI chrome font: the skin's SetFont leaves
	-- GetFontObject on Blizzard's object.
	FG_AdoptFont(FG_LegacyTagOverlay, tagFS)
	FG_ApplyFontPath(FG_LegacyTagOverlay, FG_EUIChromeFontPath())

	-- CENTER on the tag, not SetAllPoints: that would truncate longer translations.
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

-- [[ LEGACY PORTRAIT ]] Mark on every tab, no tab detection: every tab signal races on this
-- panel and flickered twice. 12.1 draws into the PortraitContainer texture, not the
-- FriendsFrameIcon global.
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

	-- Backing suppressed under a portrait-removing skin, or it floats as a black disc.
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

-- Re-assert after any repaint. The flag stops our own write recursing; same-asset writes no-op.
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

-- [[ PORTRAIT PROBE ]] /fg portrait. Read-only.
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

-- Not gated on the Social UI being off (status may arrive late); both functions re-test it.
function Compat.InitLegacyContactList()
	if FG_LegacyHooksInstalled then return end

	local frame = _G.FriendsFrame
	if type(frame) ~= "table" then return end

	FG_LegacyHooksInstalled = true

	-- The catch-all: anyone repainting the portrait gets ours back. Installed first, because it is
	-- the one that does not depend on knowing which paths repaint.
	FG_HookLegacyPortraitSetter()

	-- [[ TAB CHANGES ]] Belt to the setter hook: a direct SetTexture would slip past it. Also next
	-- frame, after the tab click's repaint. FriendsFrame only.
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

	-- Painted immediately; nothing to capture first.
	FG_RefreshPortraitLegacy()
	FG_RefreshOwnBattleTagLegacy()
end

-- PLAYER_ENTERING_WORLD: frames and globals exist. SOCIAL_UI_SYSTEM_STATUS_UPDATED hooks a
-- mid-session switch. BN_* keep the status preview current. Unknown events are skipped.
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
