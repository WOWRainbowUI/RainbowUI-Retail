--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Scenario
local M = KT:NewModule("Scenario")
KT.Scenario = M

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar

local KTF = KT.frame
local MawBuffs = KT_ScenarioObjectiveTracker.MawBuffsBlock.Container
local TieredEntranceTraits = KT_ScenarioObjectiveTracker.TieredEntranceTraitsBlock.Container
local UIWidgetBaseScenarioHeaderText

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    KT_ScenarioObjectiveTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
    KT_ScenarioObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            local isInitialLogin, isReloadingUI = ...
            if not isInitialLogin and not isReloadingUI then
                if KT.inInstance then
                    KT:Module_Expand(self)
                end
            end
        end
    end)

    -- WidgetSetID:
    -- 461 ... Ember Court
    -- 291 ... Torghast (3302, 11)
    -- 842 ... Delves (6183, 29)
    hooksecurefunc(KT_ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", function(self, scenarioID, scenarioType, widgetSetID, textureKit, flags, currentStage, stageName, numStages)
        if widgetSetID == 291 then
            self.offsetX = 27
            self.KTtooltipOffsetXmod = 5
            self.KTtooltipOffsetYmod = 0
        elseif widgetSetID == 842 then
            self.offsetX = 17
            self.KTtooltipOffsetXmod = -5
            self.KTtooltipOffsetYmod = 2
        else
            self.offsetX = 22
            self.KTtooltipOffsetXmod = 0
            self.KTtooltipOffsetYmod = 0
        end
    end)

    KT_ScenarioObjectiveTracker.StageBlock:HookScript("OnEnter", function(self)
        KT.GameTooltip_SetPosition(self, 19, -2 - self.KTtooltipOffsetYmod, -24 - self.KTtooltipOffsetXmod, -2 - self.KTtooltipOffsetYmod, true)
    end)

    KT_ScenarioTrackerProgressBarMixin.PlayFlareAnim = function() end

    -- Blizzard_UIWidgetTemplateBase.lua
    hooksecurefunc(UIWidgetBaseScenarioHeaderTemplateMixin, "Setup", function(self, widgetInfo, widgetContainer)
        if self.KTskinID ~= KT.skinID then
            local fontSize = db.fontSize + 4
            self.HeaderText:SetFont(KT.font, fontSize, db.fontFlag)  -- see KT:Tracker_SetText()
            UIWidgetBaseScenarioHeaderText = self.HeaderText
            self.KTskinID = KT.skinID
        end
    end)

    -- Blizzard_UIWidgetTemplateScenarioHeaderDelves.lua
    hooksecurefunc(UIWidgetTemplateScenarioHeaderDelvesMixin, "UpdateSpellFrameEffects", function(self, widgetInfo, spellInfo, spellFrame)
        -- Disable all spell effects
        if spellFrame.effectController then
            spellFrame.effectController:CancelEffect()
            spellFrame.effectController = nil
        end
    end)

    -- Torghast - Blizzard_UIWidgetTemplateStatusBar.lua
    hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", function(self, widgetInfo, widgetContainer)
        if self.frameTextureKit == "jailerstower-scorebar" and not self.KThooked then
            hooksecurefunc(self.Bar, "SetTooltipOwner", function(self2)
                if self2:GetParent().frameTextureKit ~= "jailerstower-scorebar" then return end
                EmbeddedItemTooltip:SetOwner(self2, "ANCHOR_NONE")
                EmbeddedItemTooltip:ClearAllPoints()
                if KTF.anchorLeft then
                    EmbeddedItemTooltip:SetPoint("LEFT", self2, "RIGHT", 30, 0)
                else
                    EmbeddedItemTooltip:SetPoint("RIGHT", self2, "LEFT", -31, 0)
                end
            end)
            self.KThooked = true
        end
    end)

    hooksecurefunc(UIWidgetTemplateStatusBarMixin, "EvaluateTutorials", function(self)
        if self.frameTextureKit == "jailerstower-scorebar" then
            HelpTip:Hide(self, TORGHAST_DOMINANCE_BAR_TIP)
            HelpTip:Hide(self, TORGHAST_DOMINANCE_BAR_CUTOFF_TIP)
        end
    end)

    -- Torghast - Blizzard_MawBuffs.lua
    hooksecurefunc(MawBuffs, "UpdateAlignment", function(self)
        if KTF.anchorLeft == self.KTanchorLeft then return end

        self.KTanchorLeft = KTF.anchorLeft

        self:SetPushedTextOffset(KTF.anchorLeft and -1.25 or 1.25, -1)

        self:ClearAllPoints()
        self.List:ClearAllPoints()

        if KTF.anchorLeft then
            self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 27, 0)
            self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, 1)

            self.NormalTexture:SetTexCoord(1, 0, 0, 1)
            self.PushedTexture:SetTexCoord(1, 0, 0, 1)
            self.HighlightTexture:SetTexCoord(1, 0, 0, 1)
            self.DisabledTexture:SetTexCoord(1, 0, 0, 1)
        else
            self:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", -10, 0)
            self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", -2, 1)

            self.NormalTexture:SetTexCoord(0, 1, 0, 1)
            self.PushedTexture:SetTexCoord(0, 1, 0, 1)
            self.HighlightTexture:SetTexCoord(0, 1, 0, 1)
            self.DisabledTexture:SetTexCoord(0, 1, 0, 1)
        end
    end)

    MawBuffs.List:HookScript("OnShow", function(self)
        self.button:SetButtonState("NORMAL")
        self.button:SetPushedTextOffset(KTF.anchorLeft and -8.75 or 8.75, -1)
        self.button:SetButtonState("PUSHED", true)
    end)

    MawBuffs.List:HookScript("OnHide", function(self)
        self.button:SetButtonState("NORMAL", false)
        self.button:SetPushedTextOffset(KTF.anchorLeft and -1.25 or 1.25, -1)
    end)

    MawBuffs.UpdateHelptip = function() end

    -- Blizzard_TieredEntranceTraits.lua
    hooksecurefunc(TieredEntranceTraits, "UpdateAlignment", function(self)
        if KTF.anchorLeft == self.KTanchorLeft then return end

        self.KTanchorLeft = KTF.anchorLeft

        self.List:ClearAllPoints()
        self.Arrow:ClearAllPoints()

        if KTF.anchorLeft then
            self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 17, 1)
            self.Arrow:SetAtlas("themed-scenario-challenge-flyout-forwardarrow", TextureKitConstants.UseAtlasSize)
            self.Arrow:SetPoint("LEFT", self, "RIGHT", -5, 0)
        else
            self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", -17, 1)
            self.Arrow:SetAtlas("themed-scenario-challenge-flyout-backarrow", TextureKitConstants.UseAtlasSize)
            self.Arrow:SetPoint("RIGHT", self, "LEFT", 5, 0)
        end
    end)
end

local function SetFrames()
    KT_ScenarioObjectiveTracker.fromBlockOffsetY = 0
    KT_ScenarioObjectiveTracker.lineSpacing = 4
    KT_ScenarioObjectiveTracker.ObjectivesBlock.offsetX = 40
    KT_ScenarioObjectiveTracker.ObjectivesBlock.HeaderButton:EnableMouse(false)
    KT_ScenarioObjectiveTracker.StageBlock.offsetX = 22
    KT_ScenarioObjectiveTracker.ProvingGroundsBlock.offsetX = 27
    KT_ScenarioObjectiveTracker.MawBuffsBlock.offsetX = 0
    KT_ScenarioObjectiveTracker.TopWidgetContainerBlock.offsetX = 28

    -- Blizzard frames
    MawBuffs.List:SetParent(UIParent)
    MawBuffs.List:SetFrameLevel(MawBuffs:GetFrameLevel() - 1)
    MawBuffs.List:SetClampedToScreen(true)
    TieredEntranceTraits:SetPoint("BOTTOM", TieredEntranceTraits:GetParent(), "BOTTOM", -2, 2)
    TieredEntranceTraits.List:SetParent(UIParent)
    TieredEntranceTraits.List:SetFrameLevel(TieredEntranceTraits:GetFrameLevel() - 1)
    TieredEntranceTraits.List:SetClampedToScreen(true)
    HelpTip:Hide(MawBuffs, JAILERS_TOWER_BUFFS_TUTORIAL)
end

-- External ------------------------------------------------------------------------------------------------------------

function M:Module_SetText()
    if KT_ScenarioObjectiveTracker.KTskinID ~= KT.skinID then
        KT_ScenarioObjectiveTracker.StageBlock.Stage:SetFont(KT.font, db.fontSize + 6, db.fontFlag)
        KT_ScenarioObjectiveTracker.StageBlock.CompleteLabel:SetFont(KT.font, db.fontSize + 6, db.fontFlag)
        KT_ScenarioObjectiveTracker.StageBlock.Name:SetFont(KT.font, db.fontSize, db.fontFlag)
        KT_ScenarioObjectiveTracker.ProvingGroundsBlock.WaveLabel:SetFont(KT.font, db.fontSize + 5, db.fontFlag)
        KT_ScenarioObjectiveTracker.ProvingGroundsBlock.Wave:SetFont(KT.font, db.fontSize + 5, db.fontFlag)
        KT_ScenarioObjectiveTracker.ProvingGroundsBlock.ScoreLabel:SetFont(KT.font, db.fontSize + 5, db.fontFlag)
        KT_ScenarioObjectiveTracker.ProvingGroundsBlock.Score:SetFont(KT.font, db.fontSize + 5, db.fontFlag)
        KT_ScenarioObjectiveTracker.ProvingGroundsBlock.StatusBar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
        if UIWidgetBaseScenarioHeaderText then
            UIWidgetBaseScenarioHeaderText:SetFont(KT.font, db.fontSize + 4, db.fontFlag)  -- see UIWidgetBaseScenarioHeaderTemplateMixin:Setup
        end
        KT_ScenarioObjectiveTracker.KTskinID = KT.skinID
    end
end

function M:ExternalFrames_Hide()
    if KT.inScenario then
        MawBuffs.List:Hide()
        TieredEntranceTraits.List:Hide()
    end
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetHooks()
    SetFrames()
end