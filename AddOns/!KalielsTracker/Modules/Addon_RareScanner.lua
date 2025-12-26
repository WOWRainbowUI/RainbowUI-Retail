--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonRareScanner
local M = KT:NewModule("AddonRareScanner")
KT.AddonRareScanner = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local OTF = KT_ObjectiveTrackerFrame
local RareScanner = RareScanner
local RSbutton = RARESCANNER_BUTTON
local L

local content
local contentHeight = 80
local lootNumItems = 14

local settings = {
	headerText = "RareScanner",
	blockOffsetX = 0
}
KT_RareScannerObjectiveTrackerMixin = CreateFromMixins(KT_ObjectiveTrackerModuleMixin, settings)

-- Internal ------------------------------------------------------------------------------------------------------------

local function RS_HideButton()
	RSbutton.ModelView:Hide()
	RSbutton:SetAlpha(0)

	KT:prot("ClearAllPoints", RSbutton)
	KT:prot("SetPoint", RSbutton, "TOPLEFT", -10000, 10000)
end

local function RS_SetOptions()
	local profile = RareScanner.db.profile
	profile.display.displayButtonContainers = false
	profile.loot.numItems = lootNumItems
	profile.loot.numItemsPerRow = profile.loot.numItems / 2
end

local function RS_OnMouseUp(self, button)
	if not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
		if button == "LeftButton" then
			C_SuperTrack.SetSuperTrackedQuestID(0)
			RSbutton:GetScript("PostClick")(RSbutton, button)
		elseif button == "RightButton" then
			if not KT.InCombatBlocked() then
				RSbutton.CloseButton:Click()
			end
		end
	end
end

local function Wrapper_SetHeight()
	local lootBarHeight = 0
	if RareScanner.db.profile.loot.displayLoot and RSbutton.LootBar.itemFramesPool:GetNumActive() > 0 then
		lootBarHeight = RSbutton.LootBar:GetHeight()
		if lootBarHeight > 0 then
			lootBarHeight = min(lootBarHeight, 40) + 10
		end
	end
	local height = KT.round(content.title:GetHeight() + lootBarHeight)
	content.button.wrapper:SetHeight(height)
end

local function SetFrames()
	RSbutton:SetMovable(false)
	RSbutton:RegisterForDrag()
	RSbutton:SetClampedToScreen(false)
	RSbutton.LootBar.LootBarToolTip:SetScale(1)
	RSbutton.LootBar.LootBarToolTipComp1:SetScale(0.55)
	RSbutton.LootBar.LootBarToolTipComp2:SetScale(0.55)

	content = CreateFrame("Frame")
	Mixin(content, KT_RareScannerBlockMixin)
	content:Hide()

	local button = CreateFrame("Frame", nil, content)
	button:SetPoint("TOPLEFT", 3, 0)
	button:SetPoint("RIGHT", -6, 0)
	button:SetScript("OnEnter", function() content:OnEnter() end)
	button:SetScript("OnLeave", function() content:OnLeave() end)
	button:SetScript("OnMouseUp", RS_OnMouseUp)
	content.button = button

	local model = CreateFrame("PlayerModel", nil, button)
	model:SetSize(100, contentHeight)
	model:SetPoint("TOPLEFT", -2, 0)
	content.model = model

	local halo = model:CreateTexture(nil, "BACKGROUND", nil, -1)
	halo:SetTexture("Interface\\Map\\MapFogOfWar.blp")
	halo:SetPoint("CENTER")
	halo:SetSize(256, 256)
	halo:SetBlendMode("ADD")
	halo:SetAlpha(0.4)

	local wrapper = CreateFrame("Frame", nil, button)
	wrapper:SetPoint("LEFT", model, "RIGHT")
	wrapper:SetPoint("RIGHT")
	button.wrapper = wrapper

	local title = wrapper:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("TOPLEFT")
	title:SetPoint("RIGHT")
	title:SetJustifyH("LEFT")
	content.title = title

	local lootBar = RSbutton.LootBar
	lootBar:SetParent(content)
	lootBar:ClearAllPoints()
	lootBar:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -10)

	local prevButton = CreateFrame("Frame", nil, content)
	prevButton.texture = prevButton:CreateTexture(nil, "ARTWORK")
	KT.SetSprite(prevButton.texture, "arrow-left", true)
	prevButton.texture:SetPoint("TOPLEFT")
	prevButton:SetSize(10, 22)
	prevButton:SetPoint("RIGHT", button, "LEFT")
	prevButton:SetScript("OnMouseUp", function(self)
		if not KT.InCombatBlocked() then
			RS_SetOptions()
			self.rs:OnPreviousMouseDown()
		end
	end)
	prevButton:SetScript("OnEnter", function(self)
		self.texture:SetVertexColor(1, 1, 1)
	end)
	prevButton:SetScript("OnLeave", function(self)
		self.texture:SetVertexColor(self.color.r, self.color.g, self.color.b)
	end)
	prevButton:Hide()
	content.prevButton = prevButton

	local nextButton = CreateFrame("Frame", nil, content)
	nextButton.texture = nextButton:CreateTexture(nil, "ARTWORK")
	KT.SetSprite(nextButton.texture, "arrow-right", true)
	nextButton.texture:SetPoint("TOPRIGHT")
	nextButton:SetSize(10, 22)
	nextButton:SetPoint("LEFT", button, "RIGHT")
	nextButton:SetScript("OnMouseUp", function(self)
		if not KT.InCombatBlocked() then
			RS_SetOptions()
			self.rs:OnNextMouseDown()
		end
	end)
	nextButton:SetScript("OnEnter", function(self)
		self.texture:SetVertexColor(1, 1, 1)
	end)
	nextButton:SetScript("OnLeave", function(self)
		self.texture:SetVertexColor(self.color.r, self.color.g, self.color.b)
	end)
	nextButton:Hide()
	content.nextButton = nextButton
end

local function SetHooks()
	hooksecurefunc(KT.ObjectiveTrackerManager, "OnPlayerEnteringWorld", function(self, isInitialLogin, isReloadingUI)
		self:SetModuleContainer(KT_RareScannerObjectiveTracker, OTF)
	end)

	hooksecurefunc(RSbutton, "ShowButton", function(self)
		RS_HideButton()
		RS_SetOptions()

		if self.displayID then
			content.model:SetDisplayInfo(self.displayID)
		end
		local text = self.preEvent and string.format(L["PRE_EVENT"], self.name) or self.name
		content:SetStringText(content.title, text, KT_OBJECTIVE_TRACKER_COLOR["Header"], content.isHighlighted)

		Wrapper_SetHeight()

		content.nextButton.rs = self.NextButton
		content.nextButton:SetShown(self.NextButton:EnableNextButton())
		content.prevButton.rs = self.PreviousButton
		content.prevButton:SetShown(self.PreviousButton:EnablePreviousButton())

		KT_RareScannerObjectiveTracker.RShasContent = true
		KT_RareScannerObjectiveTracker:MarkDirty()

		KT:SendSignal("VISIBILITY_FLAG", "rare", true)
	end)

	RSbutton:HookScript("OnHide", function(self)
		content.model:ClearModel()

		KT_RareScannerObjectiveTracker.RShasContent = false
		KT_RareScannerObjectiveTracker:MarkDirty()

		KT:SendSignal("VISIBILITY_FLAG", "rare", false)
	end)

	hooksecurefunc(RSbutton.LootBar.itemFramesPool, "ShowIfReady", function(self)
		Wrapper_SetHeight()
	end)

	hooksecurefunc(RSLootMixin, "AddItem", function(self, itemID, numActive)
		self:SetScript("OnMouseUp", RS_OnMouseUp)
	end)

	hooksecurefunc(RSLootMixin, "OnEnter", function(self)
		content:OnEnter()
		local tooltip = self:GetParent().LootBarToolTip
		tooltip:SetParent(UIParent)
		tooltip:SetFrameStrata("TOOLTIP")
		tooltip:ClearAllPoints()
		if KT.frame.anchorLeft then
			tooltip:SetPoint("TOPLEFT", content, "TOPRIGHT", db.frameScale * 19, 0)
		else
			tooltip:SetPoint("TOPRIGHT", content, "TOPLEFT", db.frameScale * -22, 0)
		end
	end)

	hooksecurefunc(RSLootMixin, "OnLeave", function(self)
		content:OnLeave()
	end)

	RareScanner.ResetPosition = function() end
end

-- External ------------------------------------------------------------------------------------------------------------

function KT_RareScannerObjectiveTrackerMixin:InitModule()
	self.PThasContent = false

	local block = content
	block:SetParent(self.ContentsFrame)
	block.parentModule = self
	block:Init()
end

function KT_RareScannerObjectiveTrackerMixin:GetBlock(id)
	local block = content
	block.id = id
	block:Reset()

	self:AnchorBlock(block)

	return block
end

function KT_RareScannerObjectiveTrackerMixin:MarkBlocksUnused()
	content.used = nil
end

function KT_RareScannerObjectiveTrackerMixin:FreeUnusedBlocks()
	if not content.used then
		content:Hide()
	end
end

function KT_RareScannerObjectiveTrackerMixin:LayoutContents()
	if self.RShasContent then
		local block = self:GetBlock("rarescanner")
		self:LayoutBlock(block)
	end
end

KT_RareScannerBlockMixin = CreateFromMixins(KT_ObjectiveTrackerBlockMixin)

function KT_RareScannerBlockMixin:Init()
	self.fixedHeight = true
	self.height = contentHeight
	self.usedLines = {}  -- unused, needed throughout KT_ObjectiveTrackerBlockMixin
end

function KT_RareScannerBlockMixin:SetStringText(fontString, text, colorStyle, useHighlight)
	fontString:SetHeight(0)  -- force a clear of internals or GetHeight() might return an incorrect value
	fontString:SetText(text)

	colorStyle = colorStyle or KT_OBJECTIVE_TRACKER_COLOR["Normal"]
	if useHighlight and colorStyle.reverse then
		colorStyle = colorStyle.reverse
	end
	if fontString.colorStyle ~= colorStyle then
		fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		fontString.colorStyle = colorStyle
	end
end

function KT_RareScannerBlockMixin:OnEnter()
	self.isHighlighted = true
	self:UpdateHighlight()
end

function KT_RareScannerBlockMixin:OnLeave()
	self.isHighlighted = false
	self:UpdateHighlight()
end

function KT_RareScannerBlockMixin:UpdateHighlight()
	local colorStyle = self.title.colorStyle.reverse
	if colorStyle then
		self.title:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
		self.title.colorStyle = colorStyle
	end
end

function M:SetOptions(forced)
	self:SetForced(forced)
	content.title:SetFont(KT.font, db.fontSize, db.fontFlag)
	content.title:SetShadowColor(0, 0, 0, db.fontShadow)

	Wrapper_SetHeight()

	local color = db.hdrBgrColorShare and KT.borderColor or db.hdrBgrColor
	content.prevButton.texture:SetVertexColor(color.r, color.g, color.b)
	content.prevButton.color = color
	content.nextButton.texture:SetVertexColor(color.r, color.g, color.b)
	content.nextButton.color = color
end

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = (KT:CheckAddOn("RareScanner", "11.2.7.3") and db.addonRareScanner)

	if self.isAvailable then
		KT:Alert_IncompatibleAddon("RareScanner", "11.2.0.11")

		tinsert(KT.MODULES, "KT_RareScannerObjectiveTracker")
		KT.db:RegisterDefaults(KT.db.defaults)
	end
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	L = LibStub("AceLocale-3.0"):GetLocale("RareScanner")

	SetFrames()
	SetHooks()

	RS_SetOptions()

	KT:RegSignal("OPTIONS_CHANGED", "SetOptions", self)
end