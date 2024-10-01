if GetLocale()=="zhTW" or GetLocale()=="zhCN" then return end

local IUF = CreateFrame("Frame", "InvenUnitFrames", UIParent)
IUF:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
IUF:RegisterEvent("ADDON_LOADED")
IUF.units, IUF.links, IUF.objectOrder, IUF.visibleObject = {}, {}, {}, {}
IUF.handlers, IUF.callbacks, IUF.valueHandler = CreateFrame("Frame"), {}, {}

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local tremove = _G.table.remove
local InCombatLockdown = _G.InCombatLockdown
local GetNumRaidMembers = _G.GetNumRaidMembers
local collectgarbage = _G.collectgarbage
local category ,layout

local Broker = LibStub("LibDataBroker-1.1")
local MapButton = LibStub("LibMapButton-1.1")

function IUF:PRINT(...)
	if IRF3Debug then
		print(...)
	end
end

function IUF:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
	-- 옵션 프레임 생성
	self.optionFrame = CreateFrame("Frame", "InvenUnitFramesOptionFrame", InterfaceOptionsFramePanelContainer)
	self.optionFrame:Hide()
	self.optionFrame.name = "Inven Unit Frame"
	self.optionFrame:SetScript("OnShow", function(self)
		self:SetScript("OnShow", nil)
		InvenUnitFrames:LoadModule("Option")
	end)
--	InterfaceOptions_AddCategory(self.optionFrame)
category, layout = Settings.RegisterCanvasLayoutCategory(self.optionFrame, "InvenUnitFrame")
Settings.RegisterAddOnCategory(category)
layout:AddAnchorPoint("TOPLEFT", 10, -10);
layout:AddAnchorPoint("BOTTOMRIGHT", -10, 10);
	-- 슬래쉬 커맨드 등록
	SLASH_INVENUNITFRAMES1 = "/iuf"
	SLASH_INVENUNITFRAMES2 = "/인벤유닛"
	SLASH_INVENUNITFRAMES3 = "/인벤유니트"
	SLASH_INVENUNITFRAMES4 = "/인벤유닛프레임"
	SLASH_INVENUNITFRAMES5 = "/인벤유니트프레임"
	SLASH_INVENUNITFRAMES6 = "/invenunitframe"
	SLASH_INVENUNITFRAMES7 = "/invenunitframes"
	SLASH_INVENUNITFRAMES8 = "/ㅑㅕㄹ"
	SlashCmdList["INVENUNITFRAMES"] = function()
		IUF:OnClick("LeftButton")
	end
	-- LDB 정의
	Broker:NewDataObject("InvenUnitFrames", {
		type = "launcher",
		text = "IUF",
		OnClick = function(_, button) IUF:OnClick(button) end,
		icon = "Interface\\AddOns\\InvenUnitFrames\\Texture\\Icon.tga",
		OnTooltipShow = function(tooltip)
			if tooltip and tooltip.AddLine then
				IUF:OnTooltip(tooltip)
			end
		end,
		OnLeave = GameTooltip_Hide,
	})
	self:Show()
	self:SetAllPoints()
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UPDATE_ALL_UI_WIDGETS")	--add 9.2.0
	self:RegisterEvent("CLIENT_SCENE_CLOSED")	--add 9.2.0
	self:RegisterEvent("CLIENT_SCENE_OPENED")	--add 9.2.0
	
end


IUF.dummyParent = CreateFrame("Frame")
IUF.dummyParent:Hide()

local function changeParent(frame, prevParent, newParent)
	if frame and frame:GetParent() == prevParent then
		frame:SetParent(newParent)
	end
end

function IUF:HideBlizzardPartyFrame(hide)
	if hide then
		for i = 1, MAX_PARTY_MEMBERS do
			changeParent(_G["PartyMemberFrame"..i], UIParent, self.dummyParent)
		end
		changeParent(PartyMemberBackground, UIParent, self.dummyParent)
	else
		for i = 1, MAX_PARTY_MEMBERS do
			changeParent(_G["PartyMemberFrame"..i], self.dummyParent, UIParent)
		end
		changeParent(PartyMemberBackground, self.dummyParent, UIParent)
	end
end

local function hideBlizFrames()
	if not InCombatLockdown() then
		if PlayerFrame:IsShown() then
			PlayerFrame:Hide()
		end	
		if TargetFrame:IsShown() then
			TargetFrame:Hide()
		end
		if PartyFrame:IsShown() then
			PartyFrame:Hide()
		end	PlayerFrame:ClearAllPoints()
		
		if IUF then
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint("TOPLEFT", IUF.units.player, "TOPLEFT", 0, 0)
			PetFrame:ClearAllPoints()
			PetFrame:SetPoint("TOPLEFT", IUF.units.pet, "TOPLEFT", 0, 0)
			TargetFrame:ClearAllPoints()
			TargetFrame:SetPoint("TOPLEFT", IUF.units.target, "TOPLEFT", 0, 0)
			FocusFrame:ClearAllPoints()
			FocusFrame:SetPoint("TOPLEFT", IUF.units.focus, "TOPLEFT", 0, 0)
		end
	end
end

local function hideBlizFrames2()
	PlayerFrame:SetAlpha(0)
	PetFrame:SetAlpha(0)
	TargetFrame:SetAlpha(0)

	--adjustment to avoid overlap
	if not InCombatLockdown() then
		PetFrame:SetScale(0.00001)
		PlayerFrame:SetScale(0.00001)
		TargetFrame:SetScale(0.00001)
	end




end


function IUF:UPDATE_ALL_UI_WIDGETS()
	hideBlizFrames()
	hideBlizFrames2()
end

function IUF:CLIENT_SCENE_CLOSED()
	hideBlizFrames()
	hideBlizFrames2()
end

function IUF:CLIENT_SCENE_OPENED()
	hideBlizFrames()
	hideBlizFrames2()
end

function IUF:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
	self.isLoading = true
	self.playerGUID = UnitGUID("player")
	self.playerClass = select(2, UnitClass("player"))
	self:SearchModules()
	self:InitDB()
	if type(self.db.skin) ~= "string" or not self:LoadSkinAddOn(self.db.skin) then
		self.db.skin = "Default"
	end
	if self.db.skin == "DefaultSquare" then
		if type(IUF.SetDefaultSkinSquare) == "function" then
			IUF:SetDefaultSkinSquare(true)
		else
			self.db.skin = "Default"
		end
	end
	self.db.skinName = self.skinDB.idx[self.db.skin]
	self:SetScale(self.db.scale)
	
	-- 미니맵 버튼, 미니맵 메뉴 생성
	MapButton:CreateButton(self, "InvenUnitFramesMapButton", "Interface\\AddOns\\InvenUnitFrames\\Texture\\Icon.tga", 190, InvenUnitFramesDB.minimapButton)
	-- 유닛 프레임 생성 시작
	local partys = {}
	self:CreateObject("player")
	self:CreateObject("pet", "player")
	self:CreateObject("pettarget", "player")
	self:CreateObject("target")
	self:CreateObject("targettarget", "target")
	self:CreateObject("targettargettarget", "target")
	self:CreateObject("focus")
	self:CreateObject("focustarget", "focus")
	self:CreateObject("focustargettarget", "focus")
	for i = 1, MAX_PARTY_MEMBERS do
		partys[i] = self:CreateObject("party"..i)
		self:CreateObject("partypet"..i, "party"..i)
		self:CreateObject("party"..i.."target", "party"..i)
	end
	for i = 1, MAX_BOSS_FRAMES do
		self:CreateObject("boss"..i)
	end
	self.CreateObject, self.RegisterObjectEvents = nil
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterUnitEvent("UNIT_FACTION", "player")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	self:Hide()
	self:Show()
	for _, unit in ipairs(self.objectOrder) do
		self.units[unit]:SetLocation()
		self:SetActiveObject(self.units[unit])
	end
	self:RegisterHandlerEvents()
	self:EnableModules()
	self.isLoading = nil
	
	PlayerFrameBottomManagedFramesContainer:SetParent(IUF)
	PlayerFrameBottomManagedFramesContainer:ClearAllPoints()
	PlayerFrameBottomManagedFramesContainer:SetPoint("TOP", IUF.units.player, "BOTTOM", 30, 0)
	
	PlayerFrame:ClearAllPoints()
	PlayerFrame:SetPoint("TOPLEFT", self.units.player, "TOPLEFT", 0, 0)
	PetFrame:ClearAllPoints()
	PetFrame:SetPoint("TOPLEFT", self.units.pet, "TOPLEFT", 0, 0)
	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("TOPLEFT", self.units.target, "TOPLEFT", 0, 0)
	
	FocusFrame:ClearAllPoints()	

	parent = self.units.focus:GetParent()
	scale = self.units.focus:GetEffectiveScale() / parent:GetEffectiveScale()
	local left = self.units.focus:GetLeft() * scale - parent:GetLeft()
	local top = self.units.focus:GetTop() * scale - parent:GetTop()
	FocusFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200 + left, -200 + top)
--~ 	FocusFrame:SetPoint("TOPLEFT", self.units.focus, "TOPLEFT", 0, 0)

	IUF:InitSetPoint(PlayerFrame, self.units.player)
	IUF:InitSetParent(PlayerFrame, self.units.player)
	IUF:InitSetPoint(PetFrame, self.units.pet)
	IUF:InitSetParent(PetFrame, self.units.pet)
	IUF:InitSetPoint(TargetFrame, self.units.target)
	IUF:InitSetParent(TargetFrame, self.units.target)
--~ 	IUF:InitFocusSetPoint()
	IUF:InitSetPoint(FocusFrame, self.units.focus)
	IUF:InitSetParent(FocusFrame, self.units.focus)

end

function IUF:OnClick(button)
	if button == "RightButton" then
		-- nothing
	elseif InterfaceOptions and InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == IUF.optionFrame then
		InterfaceOptionsFrame_Show()
	elseif InterfaceOptions then
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(IUF.optionFrame)
	elseif Settings then
		Settings.OpenToCategory(category.ID)
	end
end

function IUF:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine("Inven Unit Frame v"..IUF.version)
	tooltip:AddLine("http://wow.inven.co.kr", 1, 1, 1)
	tooltip:AddLine("클릭: 설정창 열기", 1, 1, 0)
end

function IUF:CollectGarbage()
	collectgarbage()
end

local function targettingSound(unit)
	if UnitExists(unit) then
		if UnitIsEnemy(unit, "player") then
			PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT);
		elseif UnitIsFriend("player", unit) then
			PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT);
		else
			PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT);
		end
	else
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT);
	end
end

function IUF:PLAYER_TARGET_CHANGED()
	targettingSound("target")
end

function IUF:PLAYER_FOCUS_CHANGED()
	targettingSound("focus")
end

function IUF:UNIT_FACTION(unit)
	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not self.playerIsPVP then
			self.playerIsPVP = true
			PlaySound(SOUNDKIT.IG_PVP_UPDATE);
		end
	else
		self.playerIsPVP = nil
	end
end

local function updatePlayerInCombat()
	for object in pairs(IUF.visibleObject) do
		if not (object.needAutoUpdate or object.needElement) then
			IUF.callbacks.Health(object)
			IUF.callbacks.Power(object)
		end
	end
end

function IUF:PLAYER_REGEN_ENABLED()
	self.inCombat = nil
	updatePlayerInCombat()
	--CombatFeedback_StopFullscreenStatus()
	if self.onEnter and (self.db.tooltip == 2 or self.db.tooltip == 3) then
		self:UpdateUnitTooltip(self.onEnter)
	end
	
	hideBlizFrames()
	hideBlizFrames2()
end

function IUF:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	updatePlayerInCombat()
	if self.SetPreviewMode and self.previewMode then
		self:SetPreviewMode(nil)
	end
	if GetCVarBool("screenEdgeFlash") then
		--CombatFeedback_StartFullscreenStatus()
	end
	if self.onEnter and (self.db.tooltip == 2 or self.db.tooltip == 3) then
		self:UpdateUnitTooltip(self.onEnter)
	end
	hideBlizFrames()
	hideBlizFrames2()
end

local changeModelCamera = {
	["character\\scourge\\female\\scourgefemale_hd.m2"] = 1,
	["character\\worgen\\male\\worgenmale.m2"] = 1,
	["creature\\celestialhuman\\celestialhuman.m2"] = 1,
	["creature\\celestialserpent\\celestialserpent.m2"] = 1,
	["creature\\dragonhawk\\dragonhawkmount.m2"] = 1,
	["creature\\dragonturtle\\dragonturtle.m2"] = 1,
	["creature\\epicdruidflighttroll\\epicdruidflighttroll.m2"] = 1,
	["creature\\mantid\\mantid.m2"] = 1,
	["creature\\mantid\\mantid_low01.m2"] = 1,
	["creature\\mantid\\mantid_low03.m2"] = 1,
	["creature\\mantid\\mantid_low03_wingednoshadow.m2"] = 1,
	["creature\\mantid_1batch\\mantid_1batch.m2"] = 1,
	["creature\\mantidcommander\\mantidcommander.m2"] = 1,
	["creature\\mantidgrandvizier\\mantidgrandvizier.m2"] = 1,
	["creature\\mantidlord\\mantidlord.m2"] = 1,
	["creature\\mantidtank\\mantidtank_damaged.m2"] = 1,
	["creature\\mantidtank\\mantidtank_low01.m2"] = 1,
	["creature\\pandarenserpentgod\\pandarenserpentgod.m2"] = 1,
	["creature\\pandarenserpent\\pandarenserpent_lightning.m2"] = 1,
	["creature\\quilin\\quilin.m2"] = 1,
	["creature\\waterdragon\\waterdragon.m2"] = 1,
}

function IUF:RefreshCamera(model)
	--model:SetCamera(type(model:GetModelFileID()) == "string" and changeModelCamera[model:GetModelFileID():lower()] or 0)
	SetPortraitZoom = 1
end

function IUF:CheckModel()
	--if UnitExists("target") and InvenUnitFrames_Target and InvenUnitFrames_Target.portrait and InvenUnitFrames_Target.portrait:IsVisible() then
	--	print(InvenUnitFrames_Target.portrait.model3d:GetModelFileID())
	--end
end

do
	local dummy = CreateFrame("Frame")
	dummy:Hide()
	dummy:SetAlpha(0)
	
	-- This stops the compact party frame from being shown
	UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
	
	-- 블리자드 유닛 프레임 숨김
	function hideBlizzard(self)
		if self then
			UnregisterUnitWatch(self)
			self:UnregisterAllEvents()
			self:Hide()
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", -400, 500)
			local bar = _G[self:GetName().."HealthBar"]
			if bar then
				bar:UnregisterAllEvents()
			end
			bar = _G[self:GetName().."ManaBar"]
			if bar then
				bar:UnregisterAllEvents()
			end
			hideBlizzard(_G[self:GetName().."PetFrame"])
			hideBlizzard(_G[self:GetName().."ToT"])
		end
	end

	hideBlizzard(PlayerFrame)
	hideBlizzard(PetFrame)
	hideBlizzard(TargetFrame)
	hideBlizzard(ComboFrame)
	hideBlizzard(FocusFrame)
	hideBlizzard(PartyMemberBackground)
	hideBlizzard(PartyFrame)

	for i = 1, MAX_PARTY_MEMBERS do
		hideBlizzard(_G["PartyMemberFrame"..i])
	end
	for i = 1, MAX_BOSS_FRAMES do
		hideBlizzard(_G["Boss"..i.."TargetFrame"])
	end

--	local LEDDM = LibStub("LibEnhanceDDMenu-1.0")
--	LEDDM:DisableUnitMenu("MOVE_PLAYER_FRAME")
--	LEDDM:DisableUnitMenu("MOVE_TARGET_FRAME")
--	LEDDM:DisableUnitMenu("MOVE_FOCUS_FRAME")
--	LEDDM:DisableUnitMenu("LARGE_FOCUS")
	IUF:HideBlizzardPartyFrame(true)
end







-- Taint 오류 방지 1: UIFrameFlash 사용 회피

local frameFlashManager = CreateFrame("FRAME");
local UIFrameFlashTimers = {};
local UIFrameFlashTimerRefCount = {};
local FLASHFRAMES = {};
local UIFrameFlash, UIFrameFlash_OnUpdate, UIFrameFlashStop

-- Function to start a frame flashing
function UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	if ( frame ) then
		local index = 1;
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if ( FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end

		if (syncId) then
			frame.syncId = syncId;
			if (UIFrameFlashTimers[syncId] == nil) then
				UIFrameFlashTimers[syncId] = 0;
				UIFrameFlashTimerRefCount[syncId] = 0;
			end
			UIFrameFlashTimerRefCount[syncId] = UIFrameFlashTimerRefCount[syncId]+1;
		else
			frame.syncId = nil;
		end

		-- Time it takes to fade in a flashing frame
		frame.fadeInTime = fadeInTime;
		-- Time it takes to fade out a flashing frame
		frame.fadeOutTime = fadeOutTime;
		-- How long to keep the frame flashing
		frame.flashDuration = flashDuration;
		-- Show the flashing frame when the fadeOutTime has passed
		frame.showWhenDone = showWhenDone;
		-- Internal timer
		frame.flashTimer = 0;
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime;

		tinsert(FLASHFRAMES, frame);

		frameFlashManager:SetScript("OnUpdate", UIFrameFlash_OnUpdate);
	end
end

-- Called every frame to update flashing frames
function UIFrameFlash_OnUpdate(self, elapsed)
	local frame;
	local index = #FLASHFRAMES;

	-- Update timers for all synced frames
	for syncId, timer in pairs(UIFrameFlashTimers) do
		UIFrameFlashTimers[syncId] = timer + elapsed;
	end

	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index];
		frame.flashTimer = frame.flashTimer + elapsed;

		if ( (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
			UIFrameFlashStop(frame);
		else
			local flashTime = frame.flashTimer;
			local alpha;

			if (frame.syncId) then
				flashTime = UIFrameFlashTimers[frame.syncId];
			end

			flashTime = flashTime%(frame.fadeInTime+frame.fadeOutTime+(frame.flashInHoldTime or 0)+(frame.flashOutHoldTime or 0));
			if (flashTime < frame.fadeInTime) then
				alpha = flashTime/frame.fadeInTime;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)) then
				alpha = 1;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)+frame.fadeOutTime) then
				alpha = 1 - ((flashTime - frame.fadeInTime - (frame.flashInHoldTime or 0))/frame.fadeOutTime);
			else
				alpha = 0;
			end

			frame:SetAlpha(alpha);
			frame:Show();
		end

		-- Loop in reverse so that removing frames is safe
		index = index - 1;
	end

	if ( #FLASHFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

-- Function to stop flashing
function UIFrameFlashStop(frame)
	tDeleteItem(FLASHFRAMES, frame);
	frame:SetAlpha(1.0);
	frame.flashTimer = nil;
	if (frame.syncId) then
		UIFrameFlashTimerRefCount[frame.syncId] = UIFrameFlashTimerRefCount[frame.syncId]-1;
		if (UIFrameFlashTimerRefCount[frame.syncId] == 0) then
			UIFrameFlashTimers[frame.syncId] = nil;
			UIFrameFlashTimerRefCount[frame.syncId] = nil;
		end
		frame.syncId = nil;
	end
	if ( frame.showWhenDone ) then
		frame:Show();
	else
		frame:Hide();
	end
end

function IUF:UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
end

function IUF:UIFrameFlashStop(frame)
	UIFrameFlashStop(frame)
end

--[[
function IUF:InitSetPoint(frame, parent)
	local origsetpoint = getmetatable(frame).__index.SetPoint
	local function move1(self)
		if not InCombatLockdown() then
			self:ClearAllPoints()
			origsetpoint(self, "TOPLEFT", UIParent, "TOPLEFT", 0, 0)
		end
	end
	hooksecurefunc(frame, "SetPoint", move1)
end

function IUF:InitSetParent(frame, parent)
	local origsetParent = getmetatable(frame).__index.SetParent
	local function move2(self)
	   origsetParent(self, parent)
	end
	hooksecurefunc(frame, "SetParent", move2)
end

function IUF:InitFocusSetPoint()
	local origsetpoint = getmetatable(FocusFrame).__index.SetPoint
	local function move3(self)
		if not InCombatLockdown() then
			FocusFrame:ClearAllPoints()
			parent = IUF.units.focus:GetParent()
			scale = IUF.units.focus:GetEffectiveScale() / parent:GetEffectiveScale()
			local left = 200 + IUF.units.focus:GetLeft() * scale - parent:GetLeft()
			local top = -200 + IUF.units.focus:GetTop() * scale - parent:GetTop()
--~ 			origsetpoint(FocusFrame, "TOPLEFT", left, top)
			origsetpoint(FocusFrame, "TOPLEFT", UIParent, "TOPLEFT", left, top)
		end
	end
	hooksecurefunc(FocusFrame, "SetPoint", move3)
end
--]]
	
function IUF:InitSetPoint(frame, parent)
	local origsetpoint = getmetatable(frame).__index.SetPoint
	local function move1(self)

		if not InCombatLockdown() then
			local frame = self
			local parent = nil
			if self == PlayerFrame then
				parent = IUF.units.player
			elseif self == PetFrame then
				parent = IUF.units.pet
			elseif self == TargetFrame then
				parent = IUF.units.target
			elseif self == FocusFrame then
				parent = IUF.units.focus
			end
			if frame and parent then
				if self == FocusFrame then
					if parent:GetParent() then
						frame:ClearAllPoints()
						scale = parent:GetEffectiveScale() / parent:GetParent():GetEffectiveScale()
						local left = 200 + parent:GetLeft() * scale - parent:GetParent():GetLeft()
						local top = -200 + parent:GetTop() * scale - parent:GetParent():GetTop()
						origsetpoint(frame, "TOPLEFT", UIParent, "TOPLEFT", left, top)
					end
				elseif self == PlayerFrame then
					frame:ClearAllPoints()
					local left = 0
					local top = 0
					origsetpoint(frame, "TOPLEFT", parent, "TOPLEFT", left, -top)
				else
					frame:ClearAllPoints()
					local left = parent:GetLeft()
					local top = parent:GetTop()
					origsetpoint(frame, "TOPLEFT", UIParent, "TOPLEFT", left, -top)
				end
			end
		end
	end
	hooksecurefunc(frame, "SetPoint", move1)
end

function IUF:InitSetParent(frame, parent)
	local origsetParent = getmetatable(frame).__index.SetParent
	local function move2(self)
	   origsetParent(self, parent)
	end
	hooksecurefunc(frame, "SetParent", move2)
end