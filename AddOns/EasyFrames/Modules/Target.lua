--[[
    Appreciate what others people do. (c) Usoltsev

    Copyright (c) <2016-2020>, Usoltsev.

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the <EasyFrames> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
    THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local EasyFrames = LibStub("AceAddon-3.0"):GetAddon("EasyFrames");
local Media = LibStub("LibSharedMedia-3.0");

local MODULE_NAME = "Target";
local Target = EasyFrames:NewModule(MODULE_NAME, "AceEvent-3.0", "AceHook-3.0");
local CoreModule = EasyFrames:GetModule("Core");

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local SetClassPortraitsOldSyle = EasyFrames.Utils.SetClassPortraitsOldSyle;
local SetClassPortraitsNewStyle = EasyFrames.Utils.SetClassPortraitsNewStyle;
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits;

local targetFrameContentMain = EasyFrames.Utils.GetTargetFrameContentMain();
local GetTargetHealthBar = EasyFrames.Utils.GetTargetHealthBar;

local OnShowHookScript = function(frame)
    frame:Hide();
end


function Target:OnInitialize()
    self.db = EasyFrames.db;
    db = self.db.profile;
end

function Target:OnEnable()
    if db.general.useEFTextures then
        CoreModule:CreateHealthBarFor(TargetFrame);

        self:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorld");

        hooksecurefunc(TargetFrame, "CheckClassification", function()
            self:CheckClassification(TargetFrame);
        end);

        hooksecurefunc(TargetFrame.TargetFrameContent.TargetFrameContentMain.ManaBar, "SetStatusBarTexture", function(manaBar)
            self:ManaBar_SetStatusBarTexture(manaBar);
        end);

        hooksecurefunc(TargetFrameToT.ManaBar, "SetStatusBarTexture", function(manaBar)
            self:ManaBar_SetStatusBarTexture(manaBar);
        end);
    else
        hooksecurefunc(TargetFrame, "CheckClassification", function()
            self:CheckClassificationForNonEFMode(TargetFrame);
        end);
    end

    self:ShowTargetFrameToT()
    self:ShowName(db.target.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()

    self:ReverseDirectionLosingHP(db.target.reverseDirectionLosingHP)

    self:ShowAttackBackground(db.target.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.target.attackBackgroundOpacity)
    self:ShowPVPIcon(db.target.showPVPIcon)

    hooksecurefunc(targetFrameContentMain.HealthBarsContainer.HealthBar, "UpdateTextString", function()
        self:UpdateHealthBarTextString(TargetFrame)
    end)

    hooksecurefunc(targetFrameContentMain.ManaBar, "UpdateTextString", function()
        self:UpdateManaBarTextString(TargetFrame)
    end)

    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits")
end

function Target:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:MakeClassPortraits(TargetFrame)
    self:ShowTargetFrameToT()
    self:ShowName(db.target.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()

    self:ReverseDirectionLosingHP(db.target.reverseDirectionLosingHP)

    self:ShowAttackBackground(db.target.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.target.attackBackgroundOpacity)
    self:ShowPVPIcon(db.target.showPVPIcon)

    self:UpdateHealthBarTextString(TargetFrame)
    self:UpdateManaBarTextString(TargetFrame)
end

function Target:PlayerEnteringWorld()
    local reputationBar = targetFrameContentMain.ReputationColor;
    reputationBar:Hide();

    -- FrameTexture
    TargetFrame.TargetFrameContainer.FrameTexture:SetTexCoord(0.024, 0.99, 0.25, 1);

    TargetFrame.TargetFrameContainer.Flash:SetTexCoord(0.01, 0.985, 0.24, 1);
    TargetFrame.TargetFrameContainer.Flash:SetPoint("CENTER", TargetFrame.TargetFrameContainer.Flash:GetParent(), "CENTER", 0, 0);

    -- PvP icon
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetPoint("TOPRIGHT", 4, -16);
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetPoint("RIGHT", -8, -16);
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetPoint("TOP", 4, -20);

    -- LevelText
    targetFrameContentMain.LevelText:ClearAllPoints();
    targetFrameContentMain.LevelText:SetPoint("CENTER", 83, -18);
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture:ClearAllPoints();
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture:SetPoint("CENTER", 83, -18);

    -- PetBattleIcon
    local point, relativeTo, relativePoint, xOffset, yOffset = TargetFrame.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:GetPoint();
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:ClearAllPoints();
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:SetPoint(point, relativeTo, relativePoint, xOffset + 5, yOffset + 20);

    -- Threat Frame
    local numericalThreat = TargetFrame.TargetFrameContent.TargetFrameContentContextual.NumericalThreat;
    numericalThreat:SetScale(0.8);
    numericalThreat:SetFrameLevel(TargetFrame:GetFrameLevel());
    CoreModule:MoveRegion(numericalThreat, "BOTTOMRIGHT", TargetFrame, "RIGHT", -45, 48);
    TargetFrameBG:Hide();

    -- HealthBar
    local originHealthBar = targetFrameContentMain.HealthBarsContainer.HealthBar;
    local localHealthBar = GetTargetHealthBar();

    -- Something like permanent hide.
    originHealthBar:GetStatusBarTexture():SetAlpha(0)
    originHealthBar.MyHealPredictionBar:SetAlpha(0)
    originHealthBar.OtherHealPredictionBar:SetAlpha(0)
    originHealthBar.TotalAbsorbBar:SetAlpha(0)
    originHealthBar.OverAbsorbGlow:SetAlpha(0)
    originHealthBar.OverHealAbsorbGlow:SetAlpha(0)
    originHealthBar.HealAbsorbBar:SetAlpha(0)
    targetFrameContentMain.HealthBarsContainer.TempMaxHealthLoss:SetAlpha(0);

    localHealthBar:SetPoint("CENTER", TargetFrame, "CENTER", -30, 8);

    -- Dead text
    CoreModule:MoveRegion(targetFrameContentMain.HealthBarsContainer.DeadText, "CENTER", localHealthBar, "CENTER", 0, 0);

    -- TextString
    CoreModule:MoveRegion(originHealthBar.TextString, "CENTER", localHealthBar, "CENTER", 0, 0);
    CoreModule:MoveRegion(originHealthBar.RightText, "RIGHT", localHealthBar, "RIGHT", -5, 0);
    CoreModule:MoveRegion(originHealthBar.LeftText, "LEFT", localHealthBar, "LEFT", 2, 0);

    -- ManaBar
    targetFrameContentMain.ManaBar:SetPoint("TOPRIGHT", targetFrameContentMain.HealthBarsContainer, 8, -15);
    targetFrameContentMain.ManaBar:SetFrameLevel(TargetFrame.TargetFrameContainer.FrameTexture:GetParent():GetFrameLevel());

    -- TargetFrameToT
    TargetFrameToT:ClearAllPoints();
    TargetFrameToT:SetPoint("CENTER", TargetFrame, "CENTER", 80, -53);

    TargetFrameToT.FrameTexture:SetTexture(Media:Fetch("frames", "targetoftarget"));
    TargetFrameToT.FrameTexture:SetTexCoord(0, 0.97, 0, 0.8);

    TargetFrameToT.HealthBar:SetFrameLevel(TargetFrameToT.FrameTexture:GetParent():GetFrameLevel());
    TargetFrameToT.ManaBar:SetFrameLevel(TargetFrameToT.FrameTexture:GetParent():GetFrameLevel());

    TargetFrameToT.HealthBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND");

    --TargetFrameToT.name:ClearAllPoints();
    --TargetFrameToT.name:SetPoint("CENTER", TargetFrameToT, "CENTER", 18, 15);
end

function Target:CheckClassification()
    TargetFrame.TargetFrameContainer.FrameTexture:SetTexture(Media:Fetch("frames", "target-frame"));
    TargetFrame.TargetFrameContainer.Flash:SetTexture(Media:Fetch("misc", "player-status-flash"));

    TargetFrameToT.ManaBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND");
end

function Target:CheckClassificationForNonEFMode(frame)
    local healthBar = frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar;

    healthBar:SetStatusBarTexture(Media:Fetch("statusbar", db.general.barTexture));
    healthBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0);
end

function Target:ManaBar_SetStatusBarTexture(manaBar)
    manaBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND");
end

function Target:MakeClassPortraits(frame)
    if (frame.portrait and (frame.unit == "target" or frame.unit == "targettarget")) then
        if (db.target.portrait == "2") then
            SetClassPortraitsOldSyle(frame);
        elseif (db.target.portrait == "3") then
            SetClassPortraitsNewStyle(frame);
        else
            DefaultPortraits(frame);
        end
    end
end

function Target:UpdateHealthBarTextString(frame)
    if (frame.unit == "target") then
        UpdateHealthValues(
            targetFrameContentMain.HealthBarsContainer.HealthBar,
            db.target.healthFormat,
            db.target.customHealthFormat,
            db.target.customHealthFormatFormulas,
            db.target.useHealthFormatFullValues,
            db.target.useChineseNumeralsHealthFormat
        )
    end
end

function Target:UpdateManaBarTextString(frame)
    if (frame.unit == "target") then
        UpdateManaValues(
            targetFrameContentMain.ManaBar,
            db.target.manaFormat,
            db.target.customManaFormat,
            db.target.customManaFormatFormulas,
            db.target.useManaFormatFullValues,
            db.target.useChineseNumeralsManaFormat
        )
    end
end

function Target:ShowTargetFrameToT()
    if (db.target.showToTFrame) then
        TargetFrame.totFrame:SetAlpha(1)
    else
        TargetFrame.totFrame:SetAlpha(0)
    end
end

function Target:ShowName(value)
    if (value) then
        TargetFrame.name:Show();
    else
        TargetFrame.name:Hide();
    end

    self:ShowNameInsideFrame(db.target.showNameInsideFrame);
end

function Target:ShowNameInsideFrame(showNameInsideFrame)
    if db.general.useEFTextures then
        local xOffset = -13;
        if showNameInsideFrame then
            xOffset = -28;
        end

        TargetFrame.name:SetJustifyH("CENTER");
        TargetFrame.name:SetWidth(108);

        TargetFrame.name:SetPoint("TOPLEFT", 36, xOffset);

        local healthBar = targetFrameContentMain.HealthBarsContainer.HealthBar;
        local HealthBarTexts = {
            healthBar.RightText,
            healthBar.LeftText,
            healthBar.TextString,
            targetFrameContentMain.HealthBarsContainer.DeadText
        };

        for _, healthBarTextString in pairs(HealthBarTexts) do
            local point, relativeTo, relativePoint, xOffset = healthBarTextString:GetPoint();

            if (showNameInsideFrame and db.target.showName) then
                CoreModule:MoveRegion(healthBarTextString, point, relativeTo, relativePoint, xOffset, -4);

                --EasyFrames.Const.AURAR_MIRRORED_START_Y = -6
            else
                CoreModule:MoveRegion(healthBarTextString, point, relativeTo, relativePoint, xOffset, 0);

                --EasyFrames.Const.AURAR_MIRRORED_START_Y = 4
            end
        end
    end
end

function Target:SetHealthBarsFont()
    local fontSize = db.target.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.target.healthBarFontFamily)
    local fontStyle = db.target.healthBarFontStyle

    local healthBar = targetFrameContentMain.HealthBarsContainer.HealthBar

    healthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    healthBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    healthBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Target:SetManaBarsFont()
    local fontSize = db.target.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.target.manaBarFontFamily)
    local fontStyle = db.target.manaBarFontStyle

    local manaBar = targetFrameContentMain.ManaBar

    manaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    manaBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    manaBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Target:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.target.targetNameFontFamily)
    local fontSize = db.target.targetNameFontSize
    local fontStyle = db.target.targetNameFontStyle

    TargetFrame.name:SetFont(fontFamily, fontSize, fontStyle)
end

function Target:SetFrameNameColor()
    local color = db.target.targetNameColor

    EasyFrames.Utils.SetTextColor(TargetFrame.name, color)
end

function Target:ResetFrameNameColor()
    EasyFrames.db.profile.target.targetNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Target:ReverseDirectionLosingHP(value)
    local healthBar = GetTargetHealthBar()
    local manaBar = targetFrameContentMain.ManaBar

    healthBar:SetReverseFill(value)
    manaBar:SetReverseFill(value)
end

function Target:ShowAttackBackground(value)
    local frame = TargetFrame.TargetFrameContainer.Flash

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("target")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Target:SetAttackBackgroundOpacity(value)
    TargetFrame.TargetFrameContainer.Flash:SetAlpha(value)
end

function Target:ShowPVPIcon(value)
    for _, frame in pairs({
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait,
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge,
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon,
    }) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (UnitIsPVP("target")) then
                    frame:Show()
                end
            else
                frame:Hide()

                self:SecureHook(frame, "Show", OnShowHookScript)
            end
        end
    end
end
