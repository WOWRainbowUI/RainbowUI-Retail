local IUF = InvenUnitFrames


local _G = _G
local GetReadyCheckStatus = _G.GetReadyCheckStatus
local GetReadyCheckTimeLeft = _G.GetReadyCheckTimeLeft
local readyCheckFrame = CreateFrame("Frame")
local timer = 0


local function ReadyCheckFinishAnim(reset)
	if reset then
		timer = 1
	end
	timer = timer - 0.02
	if timer > 0 then
		for object in pairs(IUF.visibleObject) do
			if object and object.readyCheckIcon then
				object.readyCheckIcon:SetAlpha(timer)
			end
		end
		readyCheckFrame.anim = C_Timer.After(0.02, ReadyCheckFinishAnim)
	else
		IUF:ReadyCheckHide()
	end
end

readyCheckFrame:SetScript("OnEvent", function(self, event)
	if event == "READY_CHECK_FINISHED" then
		if readyCheckFrame.anim then
			readyCheckFrame.anim:Cancel()
			readyCheckFrame.anim = nil
		end
		if readyCheckFrame.animrun then
			readyCheckFrame.animrun:Cancel()
			readyCheckFrame.animrun = nil
		end
		readyCheckFrame.animrun = C_Timer.After(2.5, function() ReadyCheckFinishAnim(true) end)
	else
		IUF:ReadyCheckHide()
	end
end)
readyCheckFrame:RegisterEvent("READY_CHECK_FINISHED")
readyCheckFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function IUF:ReadyCheckHide()
	IUF.doReadyCheck = nil
	if readyCheckFrame.anim then
		readyCheckFrame.anim:Cancel()
		readyCheckFrame.anim = nil
	end
	if readyCheckFrame.animrun then
		readyCheckFrame.animrun:Cancel()
		readyCheckFrame.animrun = nil
	end

	for object in pairs(IUF.visibleObject) do
		if object and object.readyCheckIcon then
			object.readyCheckIcon:Hide()
		end
	end
end 

function IUF:UpdateReadyCheck(self)
	if IUF.doReadyCheck then
		if GetReadyCheckStatus(self.unit) then
			IUF:UpdateReadyCheck2(self)
		end
	elseif self.readyCheckIcon then
		self.readyCheckIcon:Hide()
	end
end

function IUF:READY_CHECK()
	readyCheckFrame:Hide()
	self.doReadyCheck = true
	
	for object in pairs(IUF.visibleObject) do
		if object then
			if object.readyCheckIcon then
			object.readyCheckIcon:SetAlpha(1)
			object.readyCheckIcon:SetTexture("")
			end
			IUF:UpdateReadyCheck(object)
		end
	end
end

function IUF:UpdateReadyCheck2(self)
	if GetReadyCheckTimeLeft() <= 0 then
		return
	end
	
	local readyCheckStatus = GetReadyCheckStatus(self.unit)
	self.readyCheckStatus = readyCheckStatus
	if self.readyCheckIcon then
	if ( readyCheckStatus == "ready" ) then
		self.readyCheckIcon:SetAtlas(READY_CHECK_READY_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
		self.readyCheckIcon:Show()
	elseif ( readyCheckStatus == "notready" ) then
		self.readyCheckIcon:SetAtlas(READY_CHECK_NOT_READY_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
		self.readyCheckIcon:Show()
	elseif ( readyCheckStatus == "waiting" ) then
		self.readyCheckIcon:SetAtlas(READY_CHECK_WAITING_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
		self.readyCheckIcon:Show()
	else
		self.readyCheckIcon:Hide()
	end
	end
end
