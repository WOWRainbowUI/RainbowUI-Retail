--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonPetTracker
local M = KT:NewModule("AddonPetTracker")
KT.AddonPetTracker = M

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local OTF = KT_ObjectiveTrackerFrame
local PetTracker = PetTracker

local content
local contentWidth = 237

local settings = {
	headerText = PETS,
	blockOffsetX = 10
}
KT_PetTrackerObjectiveTrackerMixin = CreateFromMixins(KT_ObjectiveTrackerModuleMixin, settings)

local texts = {
	TrackPets = C_Spell.GetSpellName(122026),
	CapturedPets = "顯示已有的",
	DisplayCondition = "顯示條件",
	DisplayAlways = "總是",
	DisplayMissingRares = "缺少的稀有",
	DisplayMissingPets = "缺少的寵物"
}

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks_Init()
	if PetTracker then
		if db.addonPetTracker then
			function PetTracker.Objectives:OnLoad()  -- R
				self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Layout")
				self:RegisterEvent("ZONE_CHANGED_INDOORS")
				self:RegisterEvent("ZONE_CHANGED")
				self:RegisterSignal("COLLECTION_CHANGED", "Layout")
				self:RegisterSignal("OPTIONS_CHANGED", "Layout")

				self.MaxEntries = 200
			end

			function PetTracker.Objectives:ZONE_CHANGED_INDOORS()  -- N
				self:UnregisterEvent("ZONE_CHANGED")
				self:RegisterEvent("ZONE_CHANGED")
			end

			function PetTracker.Objectives:ZONE_CHANGED()  -- N
				self:Layout()
				self:UnregisterEvent("ZONE_CHANGED")
			end

			function PetTracker.Objectives:Layout()  -- R
				local hasContent = false
				if PetTracker.sets.zoneTracker then
					self:Hide()
					self:Update()
					hasContent = not self.Bar:IsMaximized()
				end
				KT_PetTrackerObjectiveTracker.PThasContent = hasContent
				KT_PetTrackerObjectiveTracker:MarkDirty()
			end
		else
			PetTracker.Objectives.OnLoad = function() end
		end
	end
end

local function SetHooks()
	hooksecurefunc(KT.ObjectiveTrackerManager, "OnPlayerEnteringWorld", function(self, isInitialLogin, isReloadingUI)
		self:SetModuleContainer(KT_PetTrackerObjectiveTracker, OTF)
	end)

	local bck_PetTracker_SpecieLine_New = PetTracker.SpecieLine.New
	function PetTracker.SpecieLine:New(parent, text, icon, subicon, r, g, b)
		local line = bck_PetTracker_SpecieLine_New(self, parent, text, icon, subicon, r, g, b)
		if line.KTskinID ~= KT.skinID then
			line:SetWidth(contentWidth)
			line.SubIcon:ClearAllPoints()
			line.SubIcon:SetPoint("TOPLEFT", 0, -1)
			line.Icon:ClearAllPoints()
			line.Icon:SetPoint("LEFT", line.SubIcon, "RIGHT", 5, 0)
			line.Text:ClearAllPoints()
			line.Text:SetPoint("LEFT", line.Icon, "RIGHT", 5, 0)
			line.Text:SetPoint("RIGHT")
			line.Text:SetFont(KT.font, db.fontSize, db.fontFlag)
			line.Text:SetShadowColor(0, 0, 0, db.fontShadow)
			line.Text:SetWordWrap(false)
			line.KTskinID = KT.skinID
		end
		return line
	end

	local bck_PetTracker_Pet_Display = PetTracker.Pet.Display
	function PetTracker.Pet:Display()
		if not KT.InCombatBlocked() then
			bck_PetTracker_Pet_Display(self)
		end
	end

	hooksecurefunc(PetTracker.ProgressBar, "SetProgress", function(self, progress)
		if self.KTskinID ~= KT.skinID then
			for _, bar in ipairs(self.Bars) do
				bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
			end
			self.KTskinID = KT.skinID
		end
	end)
end

local function SetHooks_PetTracker_Journal()
	if not db.addonPetTracker and PetTracker then
		PetTrackerTrackToggle:Disable()
		PetTrackerTrackToggle.Text:SetTextColor(0.5, 0.5, 0.5)
		local infoFrame = CreateFrame("Frame", nil, PetJournal)
		infoFrame:SetSize(PetTrackerTrackToggle:GetWidth() + PetTrackerTrackToggle.Text:GetWidth(), PetTrackerTrackToggle:GetHeight())
		infoFrame:SetPoint("TOPLEFT", PetTrackerTrackToggle, 0, 0)
		infoFrame:SetFrameLevel(PetTrackerTrackToggle:GetFrameLevel() + 1)
		infoFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:AddLine(texts.TrackPets, 1, 1, 1)
			GameTooltip:AddLine("Support can be enabled inside addon "..KT.TITLE, 1, 0, 0, true)
			GameTooltip:Show()
		end)
		infoFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	else
		PetTrackerTrackToggle:HookScript("OnClick", function()
			if KT:IsCollapsed() and PetTracker.sets.zoneTracker then
				KT:MinimizeButton_OnClick()
			end
		end)
	end
end

local function Event_PLAYER_ENTERING_WORLD(eventID)
	KT:RegEvent("PET_JOURNAL_LIST_UPDATE", function()
		M:SetPetsHeaderText()
	end, M)
	KT:UnregEvent(eventID)
end

local function SetEvents_Init()
	if not C_AddOns.IsAddOnLoaded("PetTracker_Journal") then
		KT:RegEvent("ADDON_LOADED", function(eventID, addon)
			if addon == "PetTracker_Journal" then
				SetHooks_PetTracker_Journal()
				KT:UnregEvent(eventID)
			end
		end, M)
	else
		SetHooks_PetTracker_Journal()
	end
end

local function SetFrames()
	-- Content frame
	content = CreateFrame("Frame")
	Mixin(content, KT_PetTrackerBlockMixin)
	content:Hide()

	-- Objectives
	local objectives = PetTracker.Objectives
	objectives:SetParent(content)

	-- Progress bar
	objectives.Bar:SetSize(contentWidth - 4, 13)
	objectives.Bar:SetPoint("TOPLEFT", content, 2, -3)
	objectives.Bar.xOff = -2
	objectives.Bar:EnableMouse(false)

	objectives.Bar.Overlay.BorderLeft:Hide()
	objectives.Bar.Overlay.BorderRight:Hide()
	objectives.Bar.Overlay.BorderCenter:Hide()

	local border1 = objectives.Bar:CreateTexture(nil, "BACKGROUND", nil, -2)
	border1:SetPoint("TOPLEFT", -1, 1)
	border1:SetPoint("BOTTOMRIGHT", 1, -1)
	border1:SetColorTexture(0, 0, 0)

	local border2 = objectives.Bar:CreateTexture(nil, "BACKGROUND", nil, -3)
	border2:SetPoint("TOPLEFT", -2, 2)
	border2:SetPoint("BOTTOMRIGHT", 2, -2)
	border2:SetColorTexture(0.4, 0.4, 0.4)

	objectives.Bar.Overlay.Text:SetPoint("CENTER", 0, 0.5)
	objectives.Bar.Overlay.Text:SetFont(LSM:Fetch("font", "Arial Narrow"), 13, "")
end

local function FilterMenuUpdate(self, info, level)
	if level == 1 then
		MSA_DropDownMenu_AddSeparator(info)

		info.text = PETS
		info.isTitle = true
		MSA_DropDownMenu_AddButton(info)

		info.isTitle = false
		info.disabled = false
		info.notCheckable = false

		info.text = texts.TrackPets
		info.checked = (PetTracker.sets.zoneTracker)
		info.func = function()
			PetTracker.ToggleOption("zoneTracker")
			if KT:IsCollapsed() and PetTracker.sets.zoneTracker then
				KT:MinimizeButton_OnClick()
			end
		end
		MSA_DropDownMenu_AddButton(info)

		info.text = texts.CapturedPets
		info.checked = (PetTracker.sets.capturedPets)
		info.func = function()
			PetTracker.ToggleOption("capturedPets")
		end
		MSA_DropDownMenu_AddButton(info)

		info.notCheckable = true

		info.text = texts.DisplayCondition
		info.keepShownOnClick = true
		info.hasArrow = true
		info.value = 3
		info.func = nil
		MSA_DropDownMenu_AddButton(info)
	elseif level == 2 then
		if MSA_DROPDOWNMENU_MENU_VALUE == 3 then
			info.notCheckable = false
			info.isNotRadio = false
			info.func = function(_, arg)
				PetTracker.SetOption("targetQuality", arg)
				KT:Filter_DropDown_Toggle()
			end

			info.text = texts.DisplayAlways
			info.arg1 = PetTracker.MaxQuality
			info.checked = (PetTracker.sets.targetQuality == info.arg1)
			MSA_DropDownMenu_AddButton(info, level)

			info.text = texts.DisplayMissingRares
			info.arg1 = PetTracker.MaxPlayerQuality
			info.checked = (PetTracker.sets.targetQuality == info.arg1)
			MSA_DropDownMenu_AddButton(info, level)

			info.text = texts.DisplayMissingPets
			info.arg1 = 1
			info.checked = (PetTracker.sets.targetQuality == info.arg1)
			MSA_DropDownMenu_AddButton(info, level)
		end
	end
end

-- External ------------------------------------------------------------------------------------------------------------

function KT_PetTrackerObjectiveTrackerMixin:InitModule()
	self.PThasContent = false

	local block = content
	block:SetParent(self.ContentsFrame)
	block.parentModule = self
	block:Init()
end

function KT_PetTrackerObjectiveTrackerMixin:GetBlock(id)
	local block = content
	block.id = id
	block:Reset()

	self:AnchorBlock(block)

	return block
end

function KT_PetTrackerObjectiveTrackerMixin:MarkBlocksUnused()
	content.used = nil
end

function KT_PetTrackerObjectiveTrackerMixin:FreeUnusedBlocks()
	if not content.used then
		content:Hide()
	end
end

function KT_PetTrackerObjectiveTrackerMixin:LayoutContents()
	if self.PThasContent then
		local block = self:GetBlock("pettracker")
		block.height = PetTracker.Objectives:GetHeight() - 42
		local blockAdded = self:LayoutBlock(block)
		PetTracker.Objectives:SetShown(blockAdded)
	end
end

KT_PetTrackerBlockMixin = CreateFromMixins(KT_ObjectiveTrackerBlockMixin)

function KT_PetTrackerBlockMixin:Init()
	self.usedLines = {}  -- unused, needed throughout KT_ObjectiveTrackerBlockMixin
end

function M:Update(forced)
	self:SetForced(forced)
	PetTracker.Objectives:Update()
end

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = (KT:CheckAddOn("PetTracker", "11.2.7") and db.addonPetTracker)

	if self.isAvailable then
		KT:Alert_IncompatibleAddon("PetTracker", "11.1.10")

		tinsert(KT.MODULES, "KT_PetTrackerObjectiveTracker")
		KT.db:RegisterDefaults(KT.db.defaults)
	end

	SetEvents_Init()
	SetHooks_Init()
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	SetFrames()
	SetHooks()

	KT:RegSignal("OPTIONS_CHANGED", "Update", self)
	KT:RegSignal("FILTER_MENU_UPDATE", FilterMenuUpdate, self)
	KT:RegEvent("PLAYER_ENTERING_WORLD", Event_PLAYER_ENTERING_WORLD, self)
end

function M:IsShown()
	return (self.isAvailable and
			(PetTracker.sets and PetTracker.sets.zoneTracker) and
			PetTracker.Objectives:IsShown())
end

function M:SetPetsHeaderText(reset)
	if self.isAvailable and db.hdrPetTrackerTitleAppend then
		local _, numPetsOwned = C_PetJournal.GetNumPets()
		KT:SetHeaderText(KT_PetTrackerObjectiveTracker, numPetsOwned)
	elseif reset then
		KT:SetHeaderText(KT_PetTrackerObjectiveTracker)
	end
end