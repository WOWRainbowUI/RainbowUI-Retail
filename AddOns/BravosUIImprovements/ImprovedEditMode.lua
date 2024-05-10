local queueStatusButtonOverlayFrame = nil
local queueStatusButtonOverlayFrameHook = nil
local queueStatusButtonOverlayFrameHookEnabled = false

local function setupFrame(frame, frameName, frameTemplate, parent, point, overlayWidth, overlayHeight, onMouseDownFunc,
                          onMouseUpFunc, label, databaseName)
	if not frame then
		frame = CreateFrame("Frame", frameName, parent, frameTemplate)
		frame:SetSize(overlayWidth, overlayHeight)
		frame:SetPoint(point)
		frame.Selection:SetScript("OnMouseDown", onMouseDownFunc)
		frame.Selection:SetScript("OnMouseUp", onMouseUpFunc)
		frame.Selection.Label:SetText(label)
	end

	-- TODO: Implement support for layouts
	if BUIIDatabase[databaseName] then
		frame:GetParent():ClearAllPoints()
		frame:GetParent():SetPoint(BUIIDatabase[databaseName]["point"],
			UIParent,
			BUIIDatabase[databaseName]["relativePoint"],
			BUIIDatabase[databaseName]["xOffset"],
			BUIIDatabase[databaseName]["yOffset"])
	end

	return frame
end

local function resetFrame(frame, pointDefault, parentDefault, relativeToDefault)
	frame:GetParent():ClearAllPoints()
	frame:GetParent():SetPoint(pointDefault, parentDefault, relativeToDefault, 0, 0)
end

local function restorePosition(frame, databaseName)
	if BUIIDatabase[databaseName] then
		local point, _, relativePoint, xOffset, yOffset = frame:GetPoint()

		if point ~= BUIIDatabase[databaseName]["point"] or
			 relativePoint ~= BUIIDatabase[databaseName]["relativePoint"] or
			 xOffset ~= BUIIDatabase[databaseName]["xOffset"] or
			 yOffset ~= BUIIDatabase[databaseName]["yOffset"] then
			frame:ClearAllPoints()
			frame:SetPoint(BUIIDatabase[databaseName]["point"],
				UIParent,
				BUIIDatabase[databaseName]["relativePoint"],
				BUIIDatabase[databaseName]["xOffset"],
				BUIIDatabase[databaseName]["yOffset"])
		end
	end
end

local function onEditModeEnter(frame)
	frame:Show()
	frame.Selection:ShowHighlighted()
end

local function onEditModeExit(frame)
	frame.Selection:Hide()
	frame.Selection.isSelected = false
	frame.Selection.isHighlighted = false
	frame:Hide()
end

local function onMouseDown(frame)
	EditModeManagerFrame:SelectSystem(frame:GetParent())
	frame.Selection:ShowSelected()
	frame:GetParent():SetMovable(true)
	frame:GetParent():SetClampedToScreen(true)
	frame:GetParent():StartMoving()
end

local function onMouseUp(frame, databaseName, pointDefault, relativeToDefault, relativePointDefault)
	frame.Selection:ShowHighlighted()
	frame:GetParent():StopMovingOrSizing()
	frame:GetParent():SetMovable(false)
	frame:GetParent():SetClampedToScreen(false)

	local point, _, relativePoint, xOffset, yOffset = frame:GetParent():GetPoint()

	if not BUIIDatabase[databaseName] then
		BUIIDatabase[databaseName] = {
			point = pointDefault,
			relativeTo = relativeToDefault,
			relativePoint = relativePointDefault,
			xOffset = 0,
			yOffset = 0,
		}
	end

	BUIIDatabase[databaseName]["point"] = point
	BUIIDatabase[databaseName]["relativeTo"] = nil
	BUIIDatabase[databaseName]["relativePoint"] = relativePoint
	BUIIDatabase[databaseName]["xOffset"] = xOffset
	BUIIDatabase[databaseName]["yOffset"] = yOffset
end

local function editMode_OnEnter()
	onEditModeEnter(queueStatusButtonOverlayFrame)

end

local function editMode_OnExit()
	onEditModeExit(queueStatusButtonOverlayFrame)
end

local function queueStatusButtonOverlayFrame_OnMouseDown()
	onMouseDown(queueStatusButtonOverlayFrame)
end

local function queueStatusButtonOverlayFrame_OnMouseUp()
	onMouseUp(queueStatusButtonOverlayFrame, "queue_status_button_position", "BOTTOMRIGHT", nil, "BOTTOMRIGHT")
end

local function queueStatusButtonOverlayFrame_OnUpdate()
	if queueStatusButtonOverlayFrameHookEnabled and not queueStatusButtonOverlayFrame.Selection.isSelected then
		restorePosition(queueStatusButtonOverlayFrame:GetParent(), "queue_status_button_position")
	end
end

local function setupQueueStatusButton()
	queueStatusButtonOverlayFrame = setupFrame(statusTrackingBarOverlayFrame, "BUIIQueueStatusButtonOverlay",
		"BUIIQueueStatusButtonEditModeSystemTemplate", QueueStatusButton, "BOTTOMRIGHT", QueueStatusButton:GetWidth(),
		QueueStatusButton:GetHeight(), queueStatusButtonOverlayFrame_OnMouseDown,
		queueStatusButtonOverlayFrame_OnMouseUp, "Queue Status Button", "queue_status_button_position")
	if not queueStatusButtonOverlayFrameHook then
		QueueStatusButton:HookScript("OnUpdate", queueStatusButtonOverlayFrame_OnUpdate)
		queueStatusButtonOverlayFrameHook = true
		queueStatusButtonOverlayFrameHookEnabled = true
	end
end

local function resetQueueStatusButton()
	resetFrame(queueStatusButtonOverlayFrame, "BOTTOMLEFT", MicroMenuContainer, "BOTTOMLEFT")
	queueStatusButtonOverlayFrameHookEnabled = false
end

function BUII_ImprovedEditModeEnable()
	setupQueueStatusButton()

	EventRegistry:RegisterCallback("EditMode.Enter", editMode_OnEnter, "BUII_ImprovedEditMode_OnEnter")
	EventRegistry:RegisterCallback("EditMode.Exit", editMode_OnExit, "BUI_ImprovedEditMode_OnExit")
end

function BUII_ImprovedEditModeDisable()
	resetQueueStatusButton()

	EventRegistry:UnregisterCallback("EditMode.Enter", "BUII_ImprovedEditMode_OnEnter")
	EventRegistry:UnregisterCallback("EditMode.Exit", "BUI_ImprovedEditMode_OnExit")
end
