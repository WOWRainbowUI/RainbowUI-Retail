local addonName, ACP = ...;
ACP.version = 0.22

local castingMount = false
local activeMountID = 0
local ignoreCVarUpdate = false
local _destination = nil

BINDING_HEADER_ACTIONCAMPLUS = "ActionCamPlus" 
local _

local ActionCamPlus_EventFrame = CreateFrame("Frame", 'ActionCamPlus_EventFrame')
-- Init Events
ActionCamPlus_EventFrame:RegisterEvent("ADDON_LOADED")
ActionCamPlus_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionCamPlus_EventFrame:RegisterEvent("CVAR_UPDATE")

-- Mount Events
ActionCamPlus_EventFrame:RegisterEvent("UNIT_SPELLCAST_START")
ActionCamPlus_EventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
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

-- Create frame for tracking where we like to have our camera set
local ActionCamPlus_ZoomLevelUpdateFrame = CreateFrame("Frame")
ActionCamPlus_ZoomLevelUpdateFrame:SetScript("OnUpdate", function(self, elapsed) ACP.zoomLevelUpdate(self, elapsed) end)

ActionCamPlus_EventFrame:SetScript("OnKeyDown", function() 
	keyboardInput = true
	C_Timer.After(2, function() keyboardInput = false end)
end)
ActionCamPlus_EventFrame:SetPropagateKeyboardInput(true)

local camMoving = false
local lastCamPosition = 0
local timeSinceLastUpdate = 0
local timeSinceLastCheck = 0
function ACP.zoomLevelUpdate(self, elapsed) -- constantly monitor camera zoom and movement so we can accurately track what's happening and react
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if _destination then timeSinceLastCheck = timeSinceLastCheck + elapsed end
	local camPosition = GetCameraZoom()

	if _destination and timeSinceLastUpdate > .016 then
		timeSinceLastCheck = 0
		local diff = abs(camPosition - _destination)

		if diff >= 0 and diff < .25 then
			_destination = nil
			MoveViewInStop()
			MoveViewOutStop()
		end
	end

	if (timeSinceLastUpdate > .25) then
		timeSinceLastUpdate = 0
		if camMoving then
			if camPosition == lastCamPosition and not castingMount then
				camMoving = false
				_destination = nil

				ACP.setZoomSpeed()

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

					ACP.UpdateZoomOptions()
				end
			end
		elseif camPosition ~= lastCamPosition then
			camMoving = true
		end
		lastCamPosition = camPosition
	end
end

--init
function ActionCamPlus_EventFrame:ADDON_LOADED(self, addon)
	if addon == addonName then
		-- set up slash commands and see if Addon Control Panel is being used.
		SLASH_ACTIONCAMPLUS1 = "/actioncamplus"
		SLASH_ACTIONCAMPLUS4 = "/動感鏡頭"
		if not ACP_Data then 
			SLASH_ACTIONCAMPLUS2 = "/acp"
			SLASH_ACTIONCAMPLUS3 = "/acpl"
		else
			SLASH_ACTIONCAMPLUS2 = "/acpl"
		end

		ActionCamPlusConfig_Setup()
		UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")
	end
end

function ActionCamPlus_EventFrame:PLAYER_ENTERING_WORLD()
	if ActionCamPlusDB.defaultZoomSpeed then
		SetCVar("cameraZoomSpeed", ActionCamPlusDB.defaultZoomSpeed)
	else
		ActionCamPlusDB.defaultZoomSpeed = GetCVar("cameraZoomSpeed")
	end
	SetCVar("CameraKeepCharacterCentered", 0)
	
	ACP.SpellIsMount(spellID) -- call once to init mountIDs
	activeMountID = ACP.getMountID()

	ACP.SetActionCam()

	-- ActionCamPlus_EventFrame:UPDATE_SHAPESHIFT_FORM()
	-- if ActionCamPlusDB.ACP_AddonEnabled then 
		-- ActionCamPlus_EventFrame:PLAYER_MOUNT_DISPLAY_CHANGED()
	-- 	ActionCamPlus_EventFrame:UPDATE_SHAPESHIFT_FORM()
	-- else
	-- 	ACP.ActionCamOFF()
	-- end
end

function ActionCamPlus_EventFrame:CVAR_UPDATE(self, CVar, value)
	if CVar == "cameraZoomSpeed" and not ignoreCVarUpdate then
		ActionCamPlusDB.defaultZoomSpeed = value
	end
end

-- Mount Event Functions
function ActionCamPlus_EventFrame:UNIT_SPELLCAST_START(self, unit, counter, spellID)
	if unit == "player" and ACP.SpellIsMount(spellID) then
		MoveViewInStop()

		activeMountID = spellID
		castingMount = true
		ACP.SetActionCam()
	end
end

function ActionCamPlus_EventFrame:UNIT_SPELLCAST_INTERRUPTED(self, unit)
	if unit == "player" and castingMount and not IsMounted() then
		castingMount = false
		ACP.SetActionCam()
	end
end

function ActionCamPlus_EventFrame:UNIT_SPELLCAST_SUCCEEDED(self, unit)
	if unit == "player" and castingMount then castingMount = false end
end

function ActionCamPlus_EventFrame:PLAYER_MOUNT_DISPLAY_CHANGED()
	if not castingMount then ACP.SetActionCam() end 
end

function ActionCamPlus_EventFrame:UPDATE_SHAPESHIFT_FORM() -- druid form check
	C_Timer.After(.1, function() if not castingMount then ACP.SetActionCam() end end)
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
function ActionCamPlus_EventFrame:PLAYER_REGEN_DISABLED() ACP.SetActionCam() end

function waitForActive()
	if clientActive() then ACP.SetActionCam()
	else C_Timer.After(.1, waitForActive) end
end

local keyboardInput = false
local mouseInput = false
local playerMoving = false
local playerTurning = false
function clientActive()
	return keyboardInput or mouseInput or playerMoving or playerTurning
end

function ActionCamPlus_EventFrame:PLAYER_REGEN_ENABLED()
	waitForActive()
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


-- Slash command handler function (init happens on addon_loaded)
function SlashCmdList.ACTIONCAMPLUS(msg)
	msg = string.lower(msg)
	arg1, arg2 = strsplit(" ", msg, 2)

	if arg1 == "" then
		if ActionCamPlusDB.ACP_AddonEnabled then
			ActionCamPlusDB.ACP_AddonEnabled = false
			RaidNotice_AddMessage(RaidWarningFrame, "動感鏡頭 Plus 已停用。", ChatTypeInfo["SYSTEM"])
		else
			ActionCamPlusDB.ACP_AddonEnabled = true
			RaidNotice_AddMessage(RaidWarningFrame, "動感鏡頭 Plus 已啟用。", ChatTypeInfo["SYSTEM"])
		end
		ACP.SetActionCam()

	elseif arg1 == "h" or arg1 == "config" or arg1 == "設定" then 
		if ActionCamPlusOptionsFrame:IsShown() then 
			ActionCamPlusOptionsFrame:Hide()
		else
			ActionCamPlusOptionsFrame:Show()
		end

	elseif arg1 == "transitionspeed" or arg1 == "ts" then 
		ActionCamPlusDB.transitionSpeed = tonumber(arg2)

	elseif arg1 == "zoomspeed" or arg1 == "zs" then
		SetCVar("cameraZoomSpeed", tonumber(arg2))
		ActionCamPlusDB.defaultZoomSpeed = tonumber(arg2)

	elseif arg1 == "t" or arg1 == "test" then 
		-- ACP.SetActionCam()
		-- print(GetCameraZoom())
		--TEST CODE
		-- SetCVar("test_cameraDynamicPitchSmartPivotCutoffDist", arg2)
		-- print(ActionCamPlusDB.transitionSpeed)
		ACP_CVars = {}
		local commands = ConsoleGetAllCommands()
		for i=1,#commands do
			if strfind(string.upper(commands[i].command), 'TEST') then
				ACP_CVars[commands[i].command] = commands[i]
			end
		end

		--END TEST CODE
	end
end

function ACP.ToggleCVar(CVar)
	if GetCVar(CVar) == "1" then
		SetCVar(CVar, 0)
	else
		SetCVar(CVar, 1)
	end
end

function ACP.SetActionCam() -- This function basically decides everything
	if ActionCamPlusDB.ACP_AddonEnabled then
		local mounted = IsMounted() or castingMount or ACP.CheckDruidForm()
		local combat = UnitAffectingCombat("player")
		if mounted and ActionCamPlusDB.ACP_Mounted then 
			ACP.ActionCam(ActionCamPlusDB.ACP_MountedActionCam)
			ACP.SetFocus(ActionCamPlusDB.ACP_MountedFocusing)
			ACP.SetFocusInteract(ActionCamPlusDB.ACP_MountedFocusingInteract)
			ACP.SetPitch(ActionCamPlusDB.ACP_MountedPitch)

			if not ActionCamPlusDB.ACP_MountedSetCameraZoom then return end
			if ActionCamPlusDB.ACP_MountSpecificZoom and ActionCamPlusDB.mountZooms[activeMountID] then
				ACP.SetCameraZoom(ActionCamPlusDB.mountZooms[activeMountID])
			else
				ACP.SetCameraZoom(ActionCamPlusDB.mountedCamDistance)
			end
		elseif combat and ActionCamPlusDB.ACP_Combat then
			ACP.ActionCam(ActionCamPlusDB.ACP_CombatActionCam)
			ACP.SetFocus(ActionCamPlusDB.ACP_CombatFocusing)
			ACP.SetFocusInteract(ActionCamPlusDB.ACP_CombatFocusingInteract)
			ACP.SetPitch(ActionCamPlusDB.ACP_CombatPitch)

			if not ActionCamPlusDB.ACP_CombatSetCameraZoom then return end
			ACP.SetCameraZoom(ActionCamPlusDB.combatCamDistance)
		else
			ACP.ActionCam(ActionCamPlusDB.ACP_ActionCam)
			ACP.SetFocus(ActionCamPlusDB.ACP_Focusing)
			ACP.SetFocusInteract(ActionCamPlusDB.ACP_FocusingInteract)
			ACP.SetPitch(ActionCamPlusDB.ACP_Pitch)

			if not ActionCamPlusDB.ACP_SetCameraZoom then return end
			ACP.SetCameraZoom(ActionCamPlusDB.unmountedCamDistance)
		end
	else
		ACP.ActionCam(false)
		ACP.SetFocus(false)
		ACP.SetFocusInteract(false)
		ACP.SetPitch(false)
	end
end

function ACP.ActionCam(enable)
	if enable then
		SetCVar("test_cameraOverShoulder", ActionCamPlusDB.leftShoulder and -1 or 1)
	else
		SetCVar("test_cameraOverShoulder", 0)
	end
end
-- GetCVar("test_cameraOverShoulder")

function ACP.SetFocus(enable)
	if enable then 
		SetCVar("test_cameraTargetFocusEnemyEnable", 1)
	else
		SetCVar("test_cameraTargetFocusEnemyEnable", 0)
	end
end

function ACP.SetFocusInteract(enable)
	if enable then 
		SetCVar("test_cameraTargetFocusInteractEnable", 1)
	else
		SetCVar("test_cameraTargetFocusInteractEnable", 0)
	end
end

function ACP.SetPitch(enable)
	if enable then
		SetCVar("test_cameraDynamicPitch", 1)
		SetCVar("test_cameraDynamicPitchBaseFovPad", 0.4) -- 上下偏移距離
	else
		SetCVar("test_cameraDynamicPitch", 0)
	end
end

function ACP.SetCameraZoom(destination)
	if abs(destination - GetCameraZoom()) > .5 then
		-- MoveViewInStop() -- this line stops the camera from doing whatever it might have been doing before...
		-- MoveViewOutStop()

		_destination = destination
		ACP.setZoomSpeed(true)

		-- we have to delay for one in-game frame so that our wow's cam doesn't get confused
		-- also, set the target .5 further to account for the general inaccuracy of this function. It should be sorted out by the stop script
		if destination >= GetCameraZoom() then 
			-- C_Timer.After(.001, function() CameraZoomOut(destination - GetCameraZoom() + .5) end)
			ACP.doubleDelay(function() CameraZoomOut(destination - GetCameraZoom() + .5) end)
		else
			-- C_Timer.After(.001, function() CameraZoomIn(GetCameraZoom() - destination + .5) end)
			ACP.doubleDelay(function() CameraZoomIn(GetCameraZoom() - destination + .5) end)
		end
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

function ACP.setZoomSpeed(transition)
	ignoreCVarUpdate = true
	SetCVar("cameraZoomSpeed", transition and ActionCamPlusDB.transitionSpeed or ActionCamPlusDB.defaultZoomSpeed)
	ignoreCVarUpdate = false
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

-- Is spell id a mount?
mountSpellIDs = nil
function ACP.SpellIsMount(spellID)
	if not mountSpellIDs then
		mountSpellIDs = {}
		for i,k in pairs(C_MountJournal.GetMountIDs()) do
			name, mountSpellID, _ = C_MountJournal.GetMountInfoByID(k)
			if mountSpellID then mountSpellIDs[mountSpellID] = true end
		end
	end

	return mountSpellIDs[spellID] or false
end

function ACP.IsClassic()
	return _G.WOW_PROJECT_ID == 11
end

-- function ACP.IsMounted():
-- 	if ActionCamPlusDB.druidFormMounts then
-- 		if IsMounted() or druidMounted then 
-- 			return true
-- 		end
-- 	else
-- 		return IsMounted()
-- 	end 
-- end
