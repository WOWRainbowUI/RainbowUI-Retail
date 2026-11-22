-- Group-header drag and drop for all three renderers, via Compat.ForEachListRowFrame,
-- GetListScrollContainer and ScrollListByFraction. A frame is draggable only while stamped
-- fgIsHeader + rawGroupName: the Classic pool recycles one button for headers and rows.

local addonName, addonTable = ...
local Compat = addonTable.Compat

-- Shared state published by FriendGroups.lua. That file loads AFTER this one, so capturing
-- addonTable.State now would pin nil; it is bound lazily at first use, exactly as
-- Platform_Render.lua and Platform_SocialUI.lua do.
local State

-- Auto-scroll rebinds pooled frames mid-drag, so the frame may show another row by release:
-- its alpha is still restored, and the group captured at start is the one moved.
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

-- Insertion slot under the pointer, plus the header it sits above (nil past the last).
-- Seed is the first VISIBLE movable index, not 1, or a scrolled list would drop at the top.
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

-- On a raised child frame, not a container texture: rows are children and would cover it.
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

-- Edge auto-scroll, scaled by elapsed so speed is frame-rate independent.
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

-- Runs on the indicator holder, never the dragged header: a recycled or hidden header never
-- delivers OnDragStop. Release is detected here too; FG_FinishDrag is idempotent.
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

	-- Accent read per drag: the EUI theme can arrive late, and FriendGroups_AccentRGB is
	-- defined in FriendGroups.lua, which loads after this file.
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

-- Scripts once per frame; drag registration re-decided each pass (pooled frames).
-- RegisterForDrag swallows clicks, so a fixed anchor must stay unregistered.
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

-- Required on Classic: a shared pool button left registered would swallow friend-row clicks.
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

-- [[ DIAGNOSTIC ]] /run: 1 dragStarts, 2 dragging, 3 movableCount, 4 headersOnScreen,
-- 5 containerFound. Headers on screen with dragStarts 0 = the list swallows the drag.
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
