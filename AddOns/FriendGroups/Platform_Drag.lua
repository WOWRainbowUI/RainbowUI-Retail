--[[
	FriendGroups - Platform_Drag.lua
	============================================================================
	Group-header drag and drop, shared by all three list renderers. Loaded after
	Compat.lua and Platform_Render.lua, before Platform_SocialUI.lua.

	This began life inside Platform_SocialUI.lua, where it could only ever run on
	a client that had the 12.1 Social UI switched on -- and that switch is server
	driven, so on a live realm running the 12.0.7 contact list the whole feature
	was unreachable. Nothing about reordering is Social-UI-specific, so it moved
	here and the three renderers now share one implementation:

	  retail legacy  FriendsListFrame.ScrollBox, headers drawn from
	                 FriendGroupsFrameFriendDividerTemplate (our own template)
	  retail 12.1    SocialUIFrame.FriendsList.ScrollBox, headers drawn from
	                 Blizzard's SocialUIScrollableHeaderTemplate and decorated
	  Classic        FriendsFrameFriendsScrollFrame, a HybridScrollFrame whose
	                 button pool is SHARED between headers and friend rows

	The platform divergence is confined to three Compat primitives --
	ForEachListRowFrame, GetListScrollContainer and ScrollListByFraction -- so
	everything below is written once against those.

	HEADER CONTRACT. A frame is draggable when it is currently rendering a group
	header, which the renderers state by stamping `fgIsHeader` and `rawGroupName`
	and clearing them again on any other row type. That is not decoration: the
	Classic pool recycles one button between a header and a friend row, so "what
	is this frame right now" cannot be inferred from the frame itself.

	API compliance:
	  - Retail  : WoW Midnight 12.0.7 (Interface 120007) / 12.1 (120100)
	  - Classic : MoP Classic 5.5.4, BC Anniversary 2.5.6, Classic Era 1.15.x
	  Only documented globals are referenced, each guarded before use.
]] --

local addonName, addonTable = ...
local Compat = addonTable.Compat

-- Shared state published by FriendGroups.lua. That file loads AFTER this one, so capturing
-- addonTable.State now would pin nil; it is bound lazily at first use, exactly as
-- Platform_Render.lua and Platform_SocialUI.lua do.
local State

-- The group being dragged, and the frame the drag started on. The frame is remembered
-- rather than relied upon: auto-scrolling during a drag rebinds pooled frames, so by the
-- time the pointer is released the frame may be showing an entirely different row -- but
-- its alpha still has to be put back, and the group name captured at the start is the one
-- that gets moved.
local FG_DragGroupName
local FG_DragFrame

-- Times a drag actually BEGAN. Zero after a failed attempt means the scroll container is
-- swallowing the drag before OnDragStart is ever reached, which is a completely different
-- fault from a drop that computes the wrong slot. Read by FriendGroups_GetSocialUIState.
local FG_DragStarts = 0

-- The drop indicator, and the frame it is drawn on. See FG_GetDropIndicator for why the
-- line does not simply live on the scroll container.
local FG_DragHolder
local FG_DragIndicator

-- How close to an edge the pointer has to be for the list to start scrolling, in UI units,
-- and how much of the scrollable range one second at full strength covers.
local FG_EDGE_ZONE = 24
local FG_EDGE_SPEED = 0.4

-- Fixed anchors -- Favorites, [No Group], the offline trackers -- cannot be reordered, so
-- they are never registered for drag and keep an unsuppressed click.
local function FG_IsGroupMovable(groupName)
	if type(groupName) ~= "string" or groupName == "" then return false end
	State = State or addonTable.State
	if not State or type(State.IsFixedAnchor) ~= "function" then return false end
	return not State.IsFixedAnchor(groupName)
end

-- Cursor Y in a frame's own coordinate space. GetCursorPosition reports in raw screen
-- units, so it has to be divided by the effective scale before it can be compared against
-- frame edges.
local function FG_CursorY(referenceFrame)
	local _, y = GetCursorPosition()
	local scale = referenceFrame:GetEffectiveScale()
	if not scale or scale <= 0 then return nil end
	return y / scale
end

-- Returns the insertion slot under the pointer, plus the header frame that slot sits above
-- (nil when the slot is past the last movable header currently drawn).
--
-- Screen Y increases UPWARDS and headers are laid out top to bottom, so walking them in
-- display order and counting the ones the pointer has fallen below yields the slot.
--
-- The seed is the FIRST VISIBLE movable index, not 1. Only the headers on screen can be
-- measured, so with the list scrolled down past groups 1-3 a pointer above every visible
-- header means "before group 4" -- seeding at 1 would silently promote it to the very top
-- of a list the user cannot even see. Reaching slot 1 is what the edge auto-scroll below
-- is for.
local function FG_ComputeDropSlot()
	State = State or addonTable.State
	if not State or type(State.GetMovableIndex) ~= "function" then return nil, nil end

	local container = Compat.GetListScrollContainer()
	if not container then return nil, nil end

	local cursorY = FG_CursorY(container)
	if not cursorY then return nil, nil end

	local byIndex = {}
	Compat.ForEachListRowFrame(function(frame)
		if type(frame) == "table" and frame.fgIsHeader and frame.rawGroupName then
			local index = State.GetMovableIndex(frame.rawGroupName)
			if index then byIndex[index] = frame end
		end
	end)

	local count = (type(State.GetMovableCount) == "function" and State.GetMovableCount()) or 0

	local slot
	for index = 1, count do
		if byIndex[index] then
			slot = index
			break
		end
	end
	if not slot then return nil, nil end

	for index = 1, count do
		local frame = byIndex[index]
		if frame and frame:GetBottom() and cursorY < frame:GetBottom() then
			slot = index + 1
		end
	end

	return slot, byIndex[slot]
end

-- The indicator is drawn on a dedicated frame parented to the scroll container and raised
-- above it, rather than straight onto the container as a texture.
--
-- Row buttons are CHILDREN of the container, and a child frame draws above its parent's
-- own regions whatever layer those are given. A texture created on the container is
-- therefore underneath every row -- and this line's entire job is to sit on the boundary
-- between two rows, which is exactly where a row's background covers it. A child frame at
-- a raised level is the only placement that puts it on top.
local function FG_GetDropIndicator(container)
	if not FG_DragHolder then
		FG_DragHolder = CreateFrame("Frame", nil, container)
		FG_DragIndicator = FG_DragHolder:CreateTexture(nil, "OVERLAY")
		FG_DragIndicator:SetHeight(2)
	elseif FG_DragHolder:GetParent() ~= container then
		FG_DragHolder:SetParent(container)
	end

	-- Re-anchored on every call rather than only at creation: on 12.1 the container can
	-- change under us when the player is moved between the Social UI and the legacy panel.
	FG_DragHolder:ClearAllPoints()
	FG_DragHolder:SetAllPoints(container)
	FG_DragHolder:SetFrameLevel(container:GetFrameLevel() + 20)
	FG_DragHolder:Show()

	return FG_DragIndicator
end

local function FG_HideDropIndicator()
	if FG_DragIndicator then FG_DragIndicator:Hide() end
end

local function FG_UpdateDropIndicator()
	local container = Compat.GetListScrollContainer()
	if not container then return end

	local slot, frameAtSlot = FG_ComputeDropSlot()
	if not slot then
		FG_HideDropIndicator()
		return
	end

	local indicator = FG_GetDropIndicator(container)
	if not indicator then return end

	indicator:ClearAllPoints()
	if frameAtSlot then
		-- On the top edge of the header this drop would displace.
		indicator:SetPoint("TOPLEFT", frameAtSlot, "TOPLEFT", 0, 1)
		indicator:SetPoint("TOPRIGHT", frameAtSlot, "TOPRIGHT", 0, 1)
	else
		-- Past the last movable header. Where the list actually ends is the bottom of that
		-- group's last MEMBER, which the headers alone cannot locate and which is usually
		-- scrolled out of sight anyway, so the foot of the viewport stands in for it.
		indicator:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", 0, 0)
		indicator:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)
	end
	indicator:Show()
end

-- Scroll the list while the pointer is held against one of its edges.
--
-- Without this a drag can only reach a destination that is already on screen, which on a
-- long list is the same "one position at a time" problem the context menu has -- drop,
-- scroll, pick the group up again, drop again.
--
-- Strength ramps with depth into the edge zone and is scaled by the frame's own elapsed
-- time, so the speed is the same on a 30fps client and a 200fps one.
local function FG_AutoScroll(container, cursorY, elapsed)
	if type(elapsed) ~= "number" or elapsed <= 0 then return end

	local top, bottom = container:GetTop(), container:GetBottom()
	if not top or not bottom then return end

	local strength
	if cursorY > top - FG_EDGE_ZONE then
		strength = -math.min((cursorY - (top - FG_EDGE_ZONE)) / FG_EDGE_ZONE, 1)
	elseif cursorY < bottom + FG_EDGE_ZONE then
		strength = math.min(((bottom + FG_EDGE_ZONE) - cursorY) / FG_EDGE_ZONE, 1)
	else
		return
	end

	Compat.ScrollListByFraction(strength * FG_EDGE_SPEED * elapsed)
end

local FG_FinishDrag

-- The drag loop runs on the INDICATOR HOLDER, not on the dragged header.
--
-- Auto-scrolling rebinds pooled frames, so the header the drag started on can be recycled
-- into another row -- or scrolled out of the pool entirely and hidden -- while the button
-- is still held. A script left on that frame would then be updating a row that has nothing
-- to do with the drag, and a frame that is hidden never delivers OnDragStop, which would
-- strand the indicator on screen with the loop still running. The holder is created once
-- and never recycled, so neither can happen to it.
--
-- Releasing the button is therefore detected here as well as through OnDragStop, whichever
-- arrives first; FG_FinishDrag is idempotent.
local function FG_DragOnUpdate(self, elapsed)
	if not FG_DragGroupName then
		self:SetScript("OnUpdate", nil)
		return
	end

	local container = Compat.GetListScrollContainer()
	if container then
		local cursorY = FG_CursorY(container)
		if cursorY then
			FG_AutoScroll(container, cursorY, elapsed)
		end
	end

	FG_UpdateDropIndicator()

	if not IsMouseButtonDown("LeftButton") then
		FG_FinishDrag()
	end
end

-- Commit the drop and put every piece of drag state back. Safe to call twice.
FG_FinishDrag = function()
	local groupName = FG_DragGroupName
	if not groupName then return end

	-- Read the slot BEFORE tearing anything down: FG_ComputeDropSlot measures live frame
	-- positions, and hiding the indicator or restoring alpha does not disturb those, but
	-- the move itself rebuilds the list and invalidates all of them.
	local slot = FG_ComputeDropSlot()

	FG_DragGroupName = nil

	if FG_DragHolder then FG_DragHolder:SetScript("OnUpdate", nil) end
	FG_HideDropIndicator()

	if FG_DragFrame then
		FG_DragFrame:SetAlpha(1)
		FG_DragFrame = nil
	end

	if not slot then return end

	State = State or addonTable.State
	if State and type(State.MoveGroupToIndex) == "function" then
		State.MoveGroupToIndex(groupName, slot)
	end
end

local function FG_HeaderOnDragStart(self)
	if not self.fgIsHeader then return end

	local groupName = self.rawGroupName
	if not FG_IsGroupMovable(groupName) then return end

	local container = Compat.GetListScrollContainer()
	if not container then return end

	FG_DragStarts = FG_DragStarts + 1
	FG_DragGroupName = groupName
	FG_DragFrame = self
	self:SetAlpha(0.5)

	-- Colour resolved once per drag rather than at texture creation. The EllesmereUI theme
	-- can arrive after the indicator was first built, and the accent is the one value the
	-- user edits at runtime -- so it is read here, and not from FG_DragOnUpdate, which runs
	-- every frame of the drag. FriendGroups_AccentRGB is a global defined in
	-- FriendGroups.lua, which loads after this file, hence the lookup at drag time.
	local indicator = FG_GetDropIndicator(container)
	if indicator and type(FriendGroups_AccentRGB) == "function" then
		local aR, aG, aB = FriendGroups_AccentRGB()
		indicator:SetColorTexture(aR, aG, aB, 0.9)
	end

	FG_DragHolder:SetScript("OnUpdate", FG_DragOnUpdate)
	FG_UpdateDropIndicator()
end

local function FG_HeaderOnDragStop(self)
	FG_FinishDrag()
end

-- ============================================================================
-- [[ RENDERER ENTRY POINTS ]]
-- ============================================================================

-- Make a header row draggable. Called from every renderer's header pass, with the group
-- that row is drawing right now.
--
-- The scripts are installed once per frame; the drag REGISTRATION is re-decided on every
-- pass, because the frame is pooled and the group on it changes. That is what keeps a
-- fixed anchor's click unsuppressed: RegisterForDrag makes WoW swallow the click as soon
-- as the pointer moves a few pixels while held, which is exactly the behaviour a movable
-- header wants and exactly the wrong behaviour for one that can never move.
function Compat.AttachHeaderDrag(frame, groupName)
	if not frame then return end

	if type(frame.RegisterForDrag) == "function" then
		if FG_IsGroupMovable(groupName) then
			frame:RegisterForDrag("LeftButton")
		else
			frame:RegisterForDrag()
		end
	end

	if frame.fgHeaderDragHooked then return end
	frame.fgHeaderDragHooked = true
	frame:SetScript("OnDragStart", FG_HeaderOnDragStart)
	frame:SetScript("OnDragStop", FG_HeaderOnDragStop)
end

-- Clear the drag registration from a frame that is no longer drawing a header.
--
-- Required on Classic, where one button pool serves headers AND friend rows: a button left
-- registered for drag would swallow the click that selects a friend the moment the pointer
-- twitched. The scripts themselves are left in place -- they cost nothing and refuse to
-- start a drag without fgIsHeader -- so a button coming back as a header only needs the
-- registration again.
function Compat.DetachHeaderDrag(frame)
	if not frame then return end
	if type(frame.RegisterForDrag) == "function" then
		frame:RegisterForDrag()
	end
end

-- Diagnostic counter, surfaced through FriendGroups_GetSocialUIState. An integer, so
-- nothing here reaches the UI and nothing needs localizing.
function Compat.GetHeaderDragStarts()
	return FG_DragStarts
end

-- ============================================================================
-- [[ DIAGNOSTIC ]]
-- Numbers and booleans only -- nothing here reaches the UI, so nothing needs localizing.
-- Global purely so the module can be inspected from a /run without the addon-private
-- Compat table, exactly as FriendGroups_GetSocialUIState is:
--
--   1 dragStarts        drags that actually began
--   2 dragging          one is in progress right now
--   3 movableCount      groups the order engine considers movable
--   4 headersOnScreen   header rows the drop-slot walk can currently measure
--   5 containerFound    a scroll container resolved on this client
--
-- The pair that matters is 1 and 4. Headers on screen with dragStarts stuck at zero after
-- a real attempt means the list frame is swallowing the drag before OnDragStart is ever
-- reached -- a completely different fault from a drop that resolves to the wrong slot, and
-- one that cannot be told apart from "nothing happened" by watching the screen.
-- ============================================================================
function FriendGroups_GetHeaderDragState()
	State = State or addonTable.State

	local container = Compat.GetListScrollContainer()

	local headers = 0
	Compat.ForEachListRowFrame(function(frame)
		if type(frame) == "table" and frame.fgIsHeader and frame.rawGroupName then
			headers = headers + 1
		end
	end)

	local movable = 0
	if State and type(State.GetMovableCount) == "function" then
		movable = State.GetMovableCount()
	end

	return FG_DragStarts, FG_DragGroupName ~= nil, movable, headers, container ~= nil
end
