local addonName, ACP = ...;
ACP.version = 1.0

local castingMount = false
local activeMountID = 0
local _destination = nil
local _delta = 0
local isDruid

BINDING_HEADER_ACTIONCAMPLUS = "ActionCamPlus"
local CAMERA_ZOOM_PRECISION = .1
local CAMERA_ZOOM_MIN_CORRECTION = .04
local _

ACP.transitionFunctions = {
	{name = "Linear", func = "linear", coefficients = {0, 0, 1, 1}},
	{name = "Ease Out", func = "cbSpecialCase", coefficients = {0, 1, 1, 1}},
	{name = "Ease In", func = "ease", coefficients = {.6, 0, 1, 1}},
	{name = "Ease In and Out", func = "ease", coefficients = {.5, 0, .5, 1}}
}
TRANS_FUNCTIONS = ACP.transitionFunctions

local ActionCamPlus_EventFrame = CreateFrame("Frame", 'ActionCamPlus_EventFrame')
-- Init Events
ActionCamPlus_EventFrame:RegisterEvent("ADDON_LOADED")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Mount Events
ActionCamPlus_EventFrame:RegisterEvent("UNIT_SPELLCAST_START")
ActionCamPlus_EventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
ActionCamPlus_EventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
ActionCamPlus_EventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
if select(2, UnitClass("player")) == "DRUID" then
	ActionCamPlus_EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- for Druid forms
end

-- Focusing Events
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_STARTED_TURNING")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_STOPPED_TURNING")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_STARTED_MOVING")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
ActionCamPlus_EventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
ActionCamPlus_EventFrame:RegisterEvent("GLOBAL_MOUSE_UP")

ActionCamPlus_EventFrame:SetScript("OnEvent", function(self,event,...) self[event](self,event,...);end)

-- Create frames for camera zooming, tracking, and animating
local ZoomFrame = CreateFrame("Frame")
ZoomFrame:SetScript("OnUpdate", function(self, elapsed) ACP.zoomTracker(self, elapsed) end)

local TrackingFrame = CreateFrame("Frame")
TrackingFrame:SetScript("OnUpdate", function(self, elapsed) ACP.cameraTracker(self, elapsed) end)

local OffsetAnimationFrame = CreateFrame("Frame")
OffsetAnimationFrame:SetScript("OnUpdate", function(self, elapsed) ACP.offsetTracker(self,elapsed) end)

function ACP.zoomTracker(self, elapsed)
	if not _destination then self:Hide() return end

	self[ACP.transitionFunctions[ActionCamPlusDB.transitionFunction].func](self, elapsed)
end

local zoomTransitionDuration
function ZoomFrame.linear(self, elapsed)
	if self._end and _destination ~= self._end then
		self._end = _destination
		self:Reset()
		_destination = self._end
		return
	end

	local camPosition = GetCameraZoom()
	if not self.start then
		self.start = camPosition
		self._end = _destination

		local path = _destination - camPosition
		local velocity = abs(ActionCamPlusDB.transitionUsingSpeed and ActionCamPlusDB.transitionSpeed or (path / ActionCamPlusDB.transitionTime))
		zoomTransitionDuration = abs(path / velocity)
		local f = _delta > 0 and MoveViewOutStart or MoveViewInStart
		f(velocity / GetCVar("cameraZoomSpeed"), nil, nil, true)
	end

	local diff = camPosition - _destination
	local absDiff = diff * _delta
	if absDiff >= 0 then
		if absDiff >= CAMERA_ZOOM_MIN_CORRECTION then
			local f = _delta < 0 and CameraZoomOut or CameraZoomIn
			RunNextFrame(function() f(abs(absDiff), true) end)
		else
			MoveViewInStop()
			MoveViewOutStop()
		end
		self:Reset()
		self:Hide()
	end
end

function ZoomFrame.cbSpecialCase(self, elapsed)
	self:smoothZoomUpdate(elapsed, cbSpecialCase)
end

function ZoomFrame.cbSpecialCaseR(self, elapsed)
	self:smoothZoomUpdate(elapsed, function(t)
		return 1 - cbSpecialCase(1-t)
	end)
end

function ZoomFrame.ease(self, elapsed)
	self:smoothZoomUpdate(elapsed, cubicBezier)
end

local updateTime = 0
local updateFPS = 60
function ZoomFrame.smoothZoomUpdate(self, elapsed, transitionFunc)
	updateTime = updateTime + elapsed
	if self.start and updateTime < 1 / updateFPS then return end

	if _destination ~= self._end then
		self._end = _destination
		self:Reset()
		_destination = self._end
		return
	end

	local dt
	if not self.start then
		self._end = _destination
		self.time = 0
		self.start = GetCameraZoom()
		self.path = _destination - self.start
		self.lastVelocity = 0

		if ActionCamPlusDB.transitionUsingSpeed then
			zoomTransitionDuration = abs(self.path / ActionCamPlusDB.transitionSpeed)
		else
			zoomTransitionDuration = ActionCamPlusDB.transitionTime
		end

		dt = 1 / updateFPS / zoomTransitionDuration

		if self.path == 0 then
			self:Reset()
			self:Hide()
		end
	else
		self.time = self.time + updateTime
		dt = updateTime / zoomTransitionDuration
	end

	local t = self.time / zoomTransitionDuration
	if t >= 1 then
		local diff = _destination - GetCameraZoom()
		if abs(diff) >= CAMERA_ZOOM_MIN_CORRECTION then
			local f = diff < 0 and CameraZoomIn or CameraZoomOut
			RunNextFrame(function() f(abs(diff), true) end)
			ACP.print("Applying correction:", diff)
		end

		ACP.print("Zoom Complete:",_destination, GetCameraZoom())
		MoveViewInStop()
		MoveViewOutStop()
		self:Reset()
		self:Hide()
		return
	end

	local frameStart = GetCameraZoom() - self.start
	local frameEnd = self.path * transitionFunc(t + dt, zoomTransitionDuration)
	local velocity = _delta * (frameEnd - frameStart) / updateTime
	updateTime = 0
	if velocity < 0 then velocity = self.lastVelocity / 2 end
	self.lastVelocity = velocity

	local f = _delta < 0 and MoveViewInStart or MoveViewOutStart
	f(velocity / ActionCamPlusDB.defaultZoomSpeed, nil, nil, true)
end

function ZoomFrame.Reset(self)
	self._destination, self.start, self.time, zoomTransitionDuration = nil, nil, nil, nil
	self.lastVelocity, updateTime = 0, 0
end

local camMoving = false
local lastCamPosition = 0
local timeSinceLastUpdate = 0
function ACP.cameraTracker(self, elapsed) -- constantly monitor camera zoom and movement so we can accurately track what's happening and react
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if (timeSinceLastUpdate > .25) then
		timeSinceLastUpdate = 0
		local camPosition = GetCameraZoom()

		if camMoving then
			if camPosition == lastCamPosition and not castingMount then
				camMoving = false
				_destination = nil

				if ActionCamPlusDB.ACP_AddonEnabled then
					local zoomAmount = floor(GetCameraZoom() * 2 + .5) / 2
					if ((ActionCamPlusDB.ACP_Mounted and IsMounted()) or (ActionCamPlusDB.ACP_DruidFormMounts and ACP.CheckDruidForm())) and ActionCamPlusDB.ACP_AutoSetMountedCameraDistance then
						if ActionCamPlusDB.ACP_MountSpecificZoom and activeMountID then
							ActionCamPlusDB.mountZooms[activeMountID] = zoomAmount
						else
							ActionCamPlusDB.mountedCamDistance = zoomAmount
						end

					elseif ActionCamPlusDB.ACP_Combat and ActionCamPlusDB.ACP_AutoSetCombatCameraDistance and UnitAffectingCombat("player") then
						ActionCamPlusDB.combatCamDistance = zoomAmount
					elseif ActionCamPlusDB.ACP_AutoSetCameraDistance then
						ActionCamPlusDB.unmountedCamDistance = zoomAmount
					end
				end
			end
		elseif camPosition ~= lastCamPosition then
			camMoving = true
		end
		lastCamPosition = camPosition
	end
end


function ACP.offsetTracker(self, elapsed)
	self:smoothCameraUpdate(elapsed, self[ACP.transitionFunctions[ActionCamPlusDB.transitionFunction].func])
end

function OffsetAnimationFrame.linear(t)
	return t > 1 and 1 or t
end

function OffsetAnimationFrame.ease(t, duration)
	return cubicBezier(t, duration)
end

function OffsetAnimationFrame.cbSpecialCase(t)
	return cbSpecialCase(t)
end

-- animate smooth camera movements
local offsetDestination
local offsetStart
local offsetEnd
local offsetPath
local offsetTime
local offsetDuration
function OffsetAnimationFrame.smoothCameraUpdate(self, elapsed, transitionFunc)
	if not offsetDestination then self:Hide() return end

	if offsetDestination ~= offsetEnd then
		offsetEnd = offsetDestination
		self:Reset()
		offsetDestination = offsetEnd
		return
	end

	if not offsetStart then
		offsetEnd = offsetDestination
		offsetTime = 0
		offsetStart = GetCVar('test_cameraOverShoulder')
		offsetPath = offsetDestination - offsetStart

		if offsetPath == 0 then
			self:Reset()
			self:Hide()
			return
		end

		if ActionCamPlusDB.syncHorizontalOffsetTime and zoomTransitionDuration then
			offsetDuration = zoomTransitionDuration
		else
			offsetDuration = ActionCamPlusDB.horizontalOffsetTime
		end
	else offsetTime = offsetTime + elapsed end

	local t = offsetTime / offsetDuration
	SetCVar("test_cameraOverShoulder", offsetStart + transitionFunc(t, offsetDuration) * offsetPath, "ACP")
	if offsetTime >= offsetDuration then
		ACP.print("Offset Complete:", offsetDestination, GetCVar("test_cameraOverShoulder"))
		self:Reset()
		self:Hide()
	end
end

function OffsetAnimationFrame.Reset(self)
	offsetDestination, offsetStart, offsetTime, offsetDuration = nil, nil, nil, nil
end

function ACP.smoothFocusInteractUpdate(self, elapsed)
	return
end

--init
function ActionCamPlus_EventFrame:ADDON_LOADED(self, addon)
	if addon ~= addonName then return end

	-- set up slash commands and see if Addon Control Panel is being used.
	SLASH_ACTIONCAMPLUS1 = "/actioncamplus"
	if not ACP_Data then
		SLASH_ACTIONCAMPLUS2 = "/acp"
		SLASH_ACTIONCAMPLUS3 = "/acpl"
	else
		SLASH_ACTIONCAMPLUS2 = "/acpl"
	end

	if not TabSystemButtonArtMixin then ACP.useClassicUI = true end
	ACP.ActionCamPlusConfig_Setup()

	UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")
	_,isDruid = UnitClass("player")

	for _,func in pairs({"CameraZoomIn", "CameraZoomOut"}) do
		hooksecurefunc(func, function(_, wasACP)
			if _destination and not wasACP then _destination = nil end
		end)
	end
	for _,func in pairs({"MoveViewInStart", "MoveViewOutStart"}) do
		hooksecurefunc(func, function(_,_,_, wasACP)
			if _destination and not wasACP then _destination = nil end
		end)
	end
end

function ActionCamPlus_EventFrame:PLAYER_ENTERING_WORLD()
	if ActionCamPlusDB.defaultZoomSpeed then
		SetCVar("cameraZoomSpeed", ActionCamPlusDB.defaultZoomSpeed, "ACP")
	else
		ActionCamPlusDB.defaultZoomSpeed = GetCVar("cameraZoomSpeed")
	end
	SetCVar("CameraKeepCharacterCentered", 0)
	SetCVar("CameraReduceUnexpectedMovement", 0)

	ACP.SpellIsMount() -- call once to init mountIDs
	activeMountID = ACP.getMountID()

	ACP.CheckAllSettings()
end

ACP.handledCVars = {
	cameraZoomSpeed = "defaultZoomSpeed",
	test_cameraTargetFocusEnemyStrengthPitch = "focusStrengthVertical",
	test_cameraTargetFocusEnemyStrengthYaw = "focusStrengthHorizontal",
	test_cameraTargetFocusInteractStrengthPitch = "focusStrengthVertical",
	test_cameraTargetFocusInteractStrengthYaw = "focusStrengthHorizontal",
	test_cameraDynamicPitchBaseFovPad = "pitchStrength",
	test_cameraDynamicPitchBaseFovPadDownScale = "pitchDownStrength",
	test_cameraDynamicPitchBaseFovPadFlying = "pitchFlightStrength"
}
hooksecurefunc("SetCVar", function(self, CVar, value, flag)
	if ACP.handledCVars[CVar] and flag ~= "ACP" then
		ActionCamPlusDB[ACP.handledCVars[CVar]] = value
		ACP.UpdateConfig()
	end
end)

-- Mount Event Functions
function ActionCamPlus_EventFrame:UNIT_SPELLCAST_START(self, unit, counter, spellID)
	if unit == "player" and ACP.SpellIsMount(spellID) then
		MoveViewInStop()

		activeMountID = spellID
		castingMount = true
		ACP.CheckAllSettings()
	end
end

function ActionCamPlus_EventFrame:UNIT_SPELLCAST_INTERRUPTED(self, unit)
	ACP.MountCastNotSuccessfull(unit)
end

function ActionCamPlus_EventFrame:UNIT_SPELLCAST_FAILED(self, unit)
	ACP.MountCastNotSuccessfull(unit)
end

function ACP.MountCastNotSuccessfull(unit)
	if unit == "player" and castingMount and not IsMounted() then
		castingMount = false
		ACP.CheckAllSettings()
	end
end

function ActionCamPlus_EventFrame:UNIT_SPELLCAST_SUCCEEDED(self, unit)
	if unit == "player" and castingMount then castingMount = false end
end

function ActionCamPlus_EventFrame:PLAYER_MOUNT_DISPLAY_CHANGED()
	if not castingMount then ACP.CheckAllSettings() end
end

function ActionCamPlus_EventFrame:UPDATE_SHAPESHIFT_FORM() -- druid form check
	C_Timer.After(.1, function() if not castingMount then ACP.CheckAllSettings() end end)
end

function ACP.CheckDruidForm()
	local currentForm = GetShapeshiftFormID()
	local mountForms = {4, 29, 27, 3}
	if ActionCamPlusDB.ACP_DruidFormMounts and currentForm and tContains(mountForms, currentForm) then
		activeMountID = currentForm
		return true
	else
		return false
	end
end

-- Combat Event Functions
function ActionCamPlus_EventFrame:PLAYER_REGEN_DISABLED() ACP.CheckAllSettings() end

function ACP.waitForActive()
	if ACP.clientActive() then ACP.CheckAllSettings()
	else C_Timer.After(.1, ACP.waitForActive) end
end

local keyboardInput = false
local mouseInput = false
local playerMoving = false
local playerTurning = false
function ACP.clientActive()
	return keyboardInput or mouseInput or playerMoving or playerTurning
end

function ActionCamPlus_EventFrame:PLAYER_REGEN_ENABLED()
	ACP.waitForActive()
end

function ActionCamPlus_EventFrame:PLAYER_STARTED_TURNING() playerTurning = true end
function ActionCamPlus_EventFrame:PLAYER_STOPPED_TURNING() playerTurning = false end

function ActionCamPlus_EventFrame:PLAYER_STARTED_MOVING() playerMoving = true end
function ActionCamPlus_EventFrame:PLAYER_STOPPED_MOVING() playerMoving = false end

local mouseInputTimer
function ActionCamPlus_EventFrame:GLOBAL_MOUSE_DOWN()
	mouseInput = true
	if mouseInputTimer then mouseInputTimer:Cancel() end
end

function ActionCamPlus_EventFrame:GLOBAL_MOUSE_UP()
	mouseInputTimer = C_Timer.After(2, function() mouseInput = false end)
end
------------------------

function SlashCmdList.ACTIONCAMPLUS(msg)
	msg = string.lower(msg)
	local arg1, arg2 = strsplit(" ", msg, 2)

	if arg1 == "" then
		if ActionCamPlusDB.ACP_AddonEnabled then
			ActionCamPlusDB.ACP_AddonEnabled = false
			RaidNotice_AddMessage(RaidWarningFrame, "ActionCamPlus disabled.", ChatTypeInfo["SYSTEM"])
		else
			ActionCamPlusDB.ACP_AddonEnabled = true
			RaidNotice_AddMessage(RaidWarningFrame, "ActionCamPlus enabled.", ChatTypeInfo["SYSTEM"])
		end
		ACP.CheckAllSettings()

	elseif arg1 == "h" or arg1 == "config" then 
		ActionCamPlus_ToggleConfigFrame()

	elseif arg1 == "transitionspeed" or arg1 == "ts" then 
		ActionCamPlusDB.transitionSpeed = tonumber(arg2)

	elseif arg1 == "zoomspeed" or arg1 == "zs" then
		SetCVar("cameraZoomSpeed", tonumber(arg2))
		ActionCamPlusDB.defaultZoomSpeed = tonumber(arg2)

	elseif arg1 == "smooth" or arg1 == "transitionsmoothing" then
		ACP.setZoomSmoothness(tonumber(arg2))

	elseif arg1 == 'd' then
		offsetDestination = tonumber(arg2)

	elseif arg1 == "break" then 
		ACP.print("-------------")

	elseif arg1 == "fps" then
		SetCVar("maxFPS", arg2)

	elseif arg1 == "t" or arg1 == "test" then
		--TEST CODE
		-- if TEST_G then
		-- 	_destination = 3.5
		-- 	_delta = -1
		-- 	ZoomFrame:Show()
		-- else
		-- 	_destination = 28
		-- 	_delta = 1
		-- 	ZoomFrame:Show()
		-- end
		-- TEST_G = not TEST_G
		--END TEST CODE
	end
end

function ACP.CheckAllSettings() -- This function basically decides everything
	ACP.UpdateConfig()
	if not ActionCamPlusDB.ACP_AddonEnabled then
		ACP.SetCameraOffset(false)
		ACP.SetFocus(false)
		ACP.SetFocusInteract(false)
		ACP.SetPitch(false)
		return
	end

	local mounted = IsMounted() or castingMount or ACP.CheckDruidForm()
	local combat = UnitAffectingCombat("player")
	if mounted and ActionCamPlusDB.ACP_Mounted then
		ACP.print("Mounted")
		ACP.SetCameraOffset(ActionCamPlusDB.ACP_MountedActionCam)
		ACP.SetFocus(ActionCamPlusDB.ACP_MountedFocusing)
		ACP.SetFocusInteract(ActionCamPlusDB.ACP_MountedFocusingInteract)
		ACP.SetPitch(ActionCamPlusDB.ACP_MountedPitch)

		if not ActionCamPlusDB.ACP_MountedSetCameraZoom then return end
		if ActionCamPlusDB.ACP_MountSpecificZoom and ActionCamPlusDB.mountZooms[activeMountID] then
			ACP.SetCameraZoom(ActionCamPlusDB.mountZooms[activeMountID], mounted)
		else
			ACP.SetCameraZoom(ActionCamPlusDB.mountedCamDistance, mounted)
		end
	elseif combat and ActionCamPlusDB.ACP_Combat then
		ACP.print("Combat")
		ACP.SetCameraOffset(ActionCamPlusDB.ACP_CombatActionCam)
		ACP.SetFocus(ActionCamPlusDB.ACP_CombatFocusing)
		ACP.SetFocusInteract(ActionCamPlusDB.ACP_CombatFocusingInteract)
		ACP.SetPitch(ActionCamPlusDB.ACP_CombatPitch)

		if not ActionCamPlusDB.ACP_CombatSetCameraZoom then return end
		ACP.SetCameraZoom(ActionCamPlusDB.combatCamDistance)
	else
		ACP.print("On Foot")
		ACP.SetCameraOffset(ActionCamPlusDB.ACP_ActionCam)
		ACP.SetFocus(ActionCamPlusDB.ACP_Focusing)
		ACP.SetFocusInteract(ActionCamPlusDB.ACP_FocusingInteract)
		ACP.SetPitch(ActionCamPlusDB.ACP_Pitch)

		if not ActionCamPlusDB.ACP_SetCameraZoom then return end
		ACP.SetCameraZoom(ActionCamPlusDB.unmountedCamDistance)
	end
end

function ACP.SetCameraOffset(enable)
	if enable then
		offsetDestination = (ActionCamPlusDB.leftShoulder and -1 or 1) * ActionCamPlusDB.horizontalOffset
	else
		offsetDestination = 0
	end
	OffsetAnimationFrame:Show()
end

function ACP.SetFocus(enable)
	if enable then
		SetCVar("test_cameraTargetFocusEnemyEnable", 1, "ACP")
	else
		SetCVar("test_cameraTargetFocusEnemyEnable", 0, "ACP")
	end
end

function ACP.SetFocusInteract(enable)
	if enable then
		SetCVar("test_cameraTargetFocusInteractEnable", 1, "ACP")
	else
		SetCVar("test_cameraTargetFocusInteractEnable", 0, "ACP")
	end
end

function ACP.SetPitch(enable)
	if enable then
		SetCVar("test_cameraDynamicPitch", 1, "ACP")
	else
		SetCVar("test_cameraDynamicPitch", 0, "ACP")
	end
end

function ACP.SetCameraZoom(destination, isMount)
	if isDruid and not isMount and tContains({1,2,4,5,31,32,33,34,35,36}, GetShapeshiftFormID()) then
		destination = destination + 1.5
	end

	if destination == _destination then return end
	local currentZoom = GetCameraZoom()
	local delta = destination >= currentZoom and -1 or 1
	if abs(destination - currentZoom) > CAMERA_ZOOM_PRECISION then
		if _destination and _delta ~= delta then
			MoveViewInStop()
			MoveViewOutStop()
		end

		_destination = destination

		-- we have to delay for one in-game frame so that our wow's cam doesn't get confused
		local zoomSpeed = ActionCamPlusDB.transitionSpeed / GetCVar("cameraZoomSpeed")
		if destination >= currentZoom then
			-- C_Timer.After(0, function() CameraZoomOut(destination - GetCameraZoom() + .5) end)
			_delta = 1
			-- C_Timer.After(0, function() MoveViewOutStart(zoomSpeed, 0, true, true) end)
			-- ACP.doubleDelay(function() CameraZoomOut(destination - currentZoom + .5) end)
		else
			-- C_Timer.After(0, function() CameraZoomIn(GetCameraZoom() - destination + .5) end)
			_delta = -1
			-- C_Timer.After(0, function() MoveViewInStart(zoomSpeed, 0, true, true) end)
			-- ACP.doubleDelay(function() CameraZoomIn(currentZoom - destination + .5) end)
		end
		ZoomFrame.start = nil
		ZoomFrame:Show()
	end
end

-- delay two frames
function ACP.doubleDelay(func)
	C_Timer.After(.001, function()
		-- double check after one frame
		-- if CVar hasn't updated then wait another frame
		-- why do we sometimes transition at default scroll speed??? >.<
		-- it still happens sometimes even with this...
		if tonumber(GetCVar('cameraZoomSpeed')) ~= ActionCamPlusDB.transitionSpeed then
			ACP.setZoomSpeed(true)
			ACP.doubleDelay(func)
		else
			C_Timer.After(.001, function() func() end)
		end
	end)
end

function ACP.setZoomSmoothness(multiplier) -- 0-1
	SetCVar("cameraDistanceRateMult", multiplier >= 1 and 1 or multiplier <= 0 and 0 or multiplier)
end

function ACP.getMountID()
	if not IsMounted() then return nil end

	local i = 1
	while true do
        local buff=C_UnitAuras.GetBuffDataByIndex('player', i)

        if buff then
            if ACP.SpellIsMount(buff.spellId) then return buff.spellId end
            i=i+1
        else break end
    end
end

function ActionCamPlus_ToggleConfigFrame()
	if ActionCamPlusOptionsFrame:IsShown() then
		ActionCamPlusOptionsFrame:Hide()
	else
		ActionCamPlusOptionsFrame:Show()
	end
end

-- Is spell id a mount?
mountSpellIDs = nil
function ACP.SpellIsMount(spellID)
	if not mountSpellIDs then
		mountSpellIDs = {}
		for i,k in pairs(C_MountJournal.GetMountIDs()) do
			name, mountSpellID, _ = C_MountJournal.GetMountInfoByID(k)
			if mountSpellID then mountSpellIDs[mountSpellID] = true end
		end
		mountSpellIDs[460013] = true -- G-99 Breakneck
	end

	return mountSpellIDs[spellID] or false
end

function ACP.IsClassic()
	return _G.WOW_PROJECT_ID == 11
end

function cbSpecialCase(t)
	if t > 1 then return 1 end
	if t < 0 then return 0 end
	return ACP.x1*(1-t)^3 + 3*ACP.y1*t*(1-t)^2 + 3*ACP.x2*(1-t)*t^2 + ACP.y2*t^3

	-- quadratic bezier
	-- local p0, p1, p2 = 0, 1, 1
	-- return (1-t)*((1-t)*p0 + t*p1) + t * ((1-t)*p1 + t*p2)
end

ACP.x1, ACP.y1, ACP.x2, ACP.y2 = nil, nil, nil, nil
ACP.C1, ACP.C2, ACP.C3 = nil, nil, nil
function cubicBezier(t, duration)
	if t <= 0 then return 0 elseif t >= 1 then return 1 end

	local guess = t
	local lastX, lastT
	for x,t in pairs(ACP.transitionFunctions[ActionCamPlusDB.transitionFunction].dropTable) do
		if lastX then
			if t > lastX and t < x then
				guess = lastT
				break
			end
		end
		lastX = x
		lastT = t
	end

	local i = 0
	repeat
		error = cbSystemEquation(guess, ACP.x1, ACP.x2) - t
		local slope = cbSystemDerivative(guess, ACP.x1, ACP.x2, ACP.C1, ACP.C2, ACP.C3)
		if abs(slope) < .02 then
			guess = bisect(t, duration)
			return cbSystemEquation(guess, ACP.y1, ACP.y2)
		end

		guess = guess - error / slope
		i = i + 1
	until abs(error) < 1 / (200 * (duration or 10)) or i == 8
	return cbSystemEquation(guess, ACP.y1, ACP.y2)
end

function cbSystemEquation(t, n, m)
	return 3*t*(1 - t)^2*n + 3*t^2*(1-t)*m + t^3
end

function cbSystemDerivative(t, x1, x2, C1, C2, C3)
	if C1 then
		return C1*t^2 + C2*t + C3
	else
		return 3*(1 - 3*x2 + 3*x1)*t^2 + 2*(3*x2 - 6*x1)*t + 3*x1
	end
end

function bisect(t, duration)
	local test = .5
	local testRange = .25
	repeat
		error = cbSystemEquation(test, ACP.x1, ACP.x2) - t
		test = test + (error > 0 and -1 or 1) * testRange
		testRange = testRange / 2
	until abs(error) < 1 / (200 * (duration or 10))
	return cbSystemEquation(test, ACP.y1, ACP.y2)
end

-- https://math.stackexchange.com/questions/4542705/derivatives-of-a-linear-and-cubic-b%C3%A9zier-curve
function cubicBezierDerivative(t)
	if t > 1 then return 0 end
	local q = (1-t)^3*(ACP.y1-ACP.x1) + 2*t*(1-t)*(ACP.x2-ACP.y1) + t^2*(ACP.y2-ACP.x2)
	return 3 * q
end

local addonChatFrame
function ACP.print(...)
	if addonChatFrame == false then return end
	if not addonChatFrame then
		for _,frameName in pairs(CHAT_FRAMES) do
			local chatFrame = _G[frameName]
			if chatFrame then
				local name = GetChatWindowInfo(chatFrame:GetID())
				if strlower(name) == "debug" then
					addonChatFrame = chatFrame
					break
				end
			end
		end
		addonChatFrame = addonChatFrame or false
	end

	if not addonChatFrame then return
	else 
		local output = ""
		for _,text in pairs({...}) do
			output = output.." "..text
		end
		addonChatFrame:AddMessage(output)
	end
end