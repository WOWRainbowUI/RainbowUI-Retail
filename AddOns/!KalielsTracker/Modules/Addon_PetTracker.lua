--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local M = KT:NewModule("AddonPetTracker")
KT.AddonPetTracker = M

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local OTF = KT_ObjectiveTrackerFrame
local PetTracker = PetTracker

local content

local settings = {
	headerText = PETS,
	blockOffsetX = 10
}
KT_PetTrackerObjectiveTrackerMixin = CreateFromMixins(KT_ObjectiveTrackerModuleMixin, settings)

M.Texts = {
	TrackPets = C_Spell.GetSpellName(122026),
	CapturedPets = "顯示已有的",
	DisplayCondition = "顯示條件",
	DisplayAlways = "總是",
	DisplayMissingRares = "缺少的稀有",
	DisplayMissingPets = "缺少的寵物"
}

--------------
-- Internal --
--------------

local function SetHooks_Init()
	if not db.addonPetTracker and PetTracker then
		PetTracker.Objectives.OnLoad = function() end
	end
end

local function SetHooks()
	hooksecurefunc(KT_ObjectiveTrackerManager, "OnPlayerEnteringWorld", function(self, isInitialLogin, isReloadingUI)
		self:SetModuleContainer(KT_PetTrackerObjectiveTracker, OTF)
	end)

	function PetTracker.Objectives:OnLoad()  -- R
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Layout")
		self:RegisterSignal("COLLECTION_CHANGED", "Layout")
		self:RegisterSignal("OPTIONS_CHANGED", "Layout")

		self.MaxEntries = 200
		self:Layout()
	end

	function PetTracker.Objectives:Layout()  -- R
		local hasContent = false
		if PetTracker.sets.zoneTracker then
			self:Update()
			hasContent = not self.Bar:IsMaximized()
		end
		self:SetShown(hasContent)
		KT_PetTrackerObjectiveTracker:MarkDirty()
	end

	local bck_PetTracker_SpecieLine_New = PetTracker.SpecieLine.New
	function PetTracker.SpecieLine:New(parent, text, icon, subicon, r, g, b)
		local line = bck_PetTracker_SpecieLine_New(self, parent, text, icon, subicon, r, g, b)
		if line.KTskinID ~= KT.skinID then
			line:SetWidth(parent.width)
			line.Dash:SetText("")
			line.SubIcon:ClearAllPoints()
			line.SubIcon:SetPoint("TOPLEFT", 0, -1)
			line.Icon:ClearAllPoints()
			line.Icon:SetPoint("LEFT", line.SubIcon, "RIGHT", 5, 0)
			line.Text:SetFont(KT.font, db.fontSize, db.fontFlag)
			line.Text:SetShadowColor(0, 0, 0, db.fontShadow)
			line.Text:SetWordWrap(false)
			line.KTskinID = KT.skinID
		end
		line.Text:ClearAllPoints()
		line.Text:SetPoint("LEFT", line.Icon, "RIGHT", 5, -1)
		line.Text:SetPoint("RIGHT")
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
			GameTooltip:AddLine(M.Texts.TrackPets, 1, 1, 1)
			GameTooltip:AddLine("Support can be enabled inside addon "..KT.title, 1, 0, 0, true)
			GameTooltip:Show()
		end)
		infoFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	else
		PetTrackerTrackToggle:HookScript("OnClick", function()
			if dbChar.collapsed and PetTracker.sets.zoneTracker then
				KT:MinimizeButton_OnClick()
			end
		end)
	end
end

local function Event_PLAYER_ENTERING_WORLD(eventID)
	KT:RegEvent("PET_JOURNAL_LIST_UPDATE", function()
		M:SetPetsHeaderText()
	end)
	KT:UnregEvent(eventID)
end

local function SetEvents_Init()
	if not C_AddOns.IsAddOnLoaded("PetTracker_Journal") then
		KT:RegEvent("ADDON_LOADED", function(eventID, addon)
			if addon == "PetTracker_Journal" then
				SetHooks_PetTracker_Journal()
				KT:UnregEvent(eventID)
			end
		end)
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
	objectives.width = 250

	-- Progress bar
	objectives.Bar:SetSize(objectives.width - 17, 13)
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

--------------
-- External --
--------------

function KT_PetTrackerObjectiveTrackerMixin:InitModule()
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
	if PetTracker.Objectives:IsShown() then
		local block = self:GetBlock("pettracker")
		block.height = PetTracker.Objectives:GetHeight() - 42
		self:LayoutBlock(block)
	end
end

KT_PetTrackerBlockMixin = CreateFromMixins(KT_ObjectiveTrackerBlockMixin)

function KT_PetTrackerBlockMixin:Init()
	self.usedLines = {}  -- unused, needed throughout KT_ObjectiveTrackerBlockMixin
end

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
	self.isLoaded = (KT:CheckAddOn("PetTracker", "11.0.9") and db.addonPetTracker)

	if self.isLoaded then
		KT:Alert_IncompatibleAddon("PetTracker", "11.0.9")

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

	KT:RegEvent("PLAYER_ENTERING_WORLD", Event_PLAYER_ENTERING_WORLD)
end

function M:IsShown()
	return (self.isLoaded and
			(PetTracker.sets and PetTracker.sets.zoneTracker) and
			PetTracker.Objectives:IsShown())
end

function M:SetPetsHeaderText(reset)
	if self.isLoaded and db.hdrPetTrackerTitleAppend then
		local _, numPetsOwned = C_PetJournal.GetNumPets()
		KT:SetHeaderText(KT_PetTrackerObjectiveTracker, numPetsOwned)
	elseif reset then
		KT:SetHeaderText(KT_PetTrackerObjectiveTracker)
	end
end