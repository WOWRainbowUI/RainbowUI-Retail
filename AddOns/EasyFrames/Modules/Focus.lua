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

local MODULE_NAME = "Focus";
local Focus = EasyFrames:NewModule(MODULE_NAME, "AceEvent-3.0", "AceHook-3.0");
local CoreModule = EasyFrames:GetModule("Core");

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local SetClassPortraitsOldSyle = EasyFrames.Utils.SetClassPortraitsOldSyle;
local SetClassPortraitsNewStyle = EasyFrames.Utils.SetClassPortraitsNewStyle;
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits;

local targetFrameContentMain = EasyFrames.Utils.GetFocusFrameContentMain();
local GetFocusHealthBar = EasyFrames.Utils.GetFocusHealthBar;

local OnShowHookScript = function(frame)
    frame:Hide();
end


function Focus:OnInitialize()
    self.db = EasyFrames.db;
    db = self.db.profile;
end

function Focus:OnEnable()
    if db.general.useEFTextures then
        CoreModule:CreateHealthBarFor(FocusFrame);

        self:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorld");

        hooksecurefunc(FocusFrame, "CheckClassification", function()
            self:CheckClassification(FocusFrame);
        end);

        hooksecurefunc(FocusFrame.TargetFrameContent.TargetFrameContentMain.ManaBar, "SetStatusBarTexture", function(manaBar)
            self:ManaBar_SetStatusBarTexture(manaBar);
        end);

        hooksecurefunc(FocusFrameToT.ManaBar, "SetStatusBarTexture", function(manaBar)
            self:ManaBar_SetStatusBarTexture(manaBar);
        end);
    else
        hooksecurefunc(FocusFrame, "CheckClassification", function()
            self:CheckClassificationForNonEFMode(FocusFrame);
        end);
    end

    self:ShowFocusFrameToT()
    self:ShowName(db.focus.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()

    self:ReverseDirectionLosingHP(db.focus.reverseDirectionLosingHP)

    self:ShowAttackBackground(db.focus.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.focus.attackBackgroundOpacity)
    self:ShowPVPIcon(db.focus.showPVPIcon)

    hooksecurefunc(targetFrameContentMain.HealthBarsContainer.HealthBar, "UpdateTextString", function()
        self:UpdateHealthBarTextString(FocusFrame)
    end)

    hooksecurefunc(targetFrameContentMain.ManaBar, "UpdateTextString", function()
        self:UpdateManaBarTextString(FocusFrame)
    end)

    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits")
end

function Focus:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:MakeClassPortraits(FocusFrame)
    self:ShowFocusFrameToT()
    self:ShowName(db.focus.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()

    self:ReverseDirectionLosingHP(db.focus.reverseDirectionLosingHP)

    self:ShowAttackBackground(db.focus.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.focus.attackBackgroundOpacity)
    self:ShowPVPIcon(db.focus.showPVPIcon)

    self:UpdateHealthBarTextString(FocusFrame)
    self:UpdateManaBarTextString(FocusFrame)
end

function Focus:PlayerEnteringWorld()
    local reputationBar = targetFrameContentMain.ReputationColor;
    reputationBar:Hide();

    -- FrameTexture
    FocusFrame.TargetFrameContainer.FrameTexture:SetTexCoord(0.024, 0.99, 0.25, 1);

    FocusFrame.TargetFrameContainer.Flash:SetTexCoord(0.01, 0.985, 0.24, 1);
    FocusFrame.TargetFrameContainer.Flash:SetPoint("CENTER", FocusFrame.TargetFrameContainer.Flash:GetParent(), "CENTER", 0, 0);

    -- PvP icon
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetPoint("TOPRIGHT", 4, -16);
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetPoint("RIGHT", -8, -16);
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetPoint("TOP", 4, -20);

    -- LevelText
    targetFrameContentMain.LevelText:ClearAllPoints();
    targetFrameContentMain.LevelText:SetPoint("CENTER", 83, -18);
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture:ClearAllPoints();
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture:SetPoint("CENTER", 83, -18);

    -- PetBattleIcon
    local point, relativeTo, relativePoint, xOffset, yOffset = FocusFrame.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:GetPoint();
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:ClearAllPoints();
    FocusFrame.TargetFrameContent.TargetFrameContentContextual.PetBattleIcon:SetPoint(point, relativeTo, relativePoint, xOffset + 5, yOffset + 20);

    -- Threat Frame
    local numericalThreat = FocusFrame.TargetFrameContent.TargetFrameContentContextual.NumericalThreat;
    numericalThreat:SetScale(0.8);
    numericalThreat:SetFrameLevel(FocusFrame:GetFrameLevel());
    CoreModule:MoveRegion(numericalThreat, "BOTTOMRIGHT", FocusFrame, "RIGHT", -45, 48);
    FocusFrameBG:Hide();

    -- HealthBar
    local originHealthBar = targetFrameContentMain.HealthBarsContainer.HealthBar;
    local localHealthBar = GetFocusHealthBar();

    -- Something like permanent hide.
    originHealthBar:GetStatusBarTexture():SetAlpha(0)
    originHealthBar.MyHealPredictionBar:SetAlpha(0)
    originHealthBar.OtherHealPredictionBar:SetAlpha(0)
    originHealthBar.TotalAbsorbBar:SetAlpha(0)
    originHealthBar.OverAbsorbGlow:SetAlpha(0)
    originHealthBar.OverHealAbsorbGlow:SetAlpha(0)
    originHealthBar.HealAbsorbBar:SetAlpha(0)
    targetFrameContentMain.HealthBarsContainer.TempMaxHealthLoss:SetAlpha(0);

    localHealthBar:SetPoint("CENTER", FocusFrame, "CENTER", -30, 8);

    -- Dead text
    CoreModule:MoveRegion(targetFrameContentMain.HealthBarsContainer.DeadText, "CENTER", localHealthBar, "CENTER", 0, 0);

    -- TextString
    CoreModule:MoveRegion(originHealthBar.TextString, "CENTER", localHealthBar, "CENTER", 0, 0);
    CoreModule:MoveRegion(originHealthBar.RightText, "RIGHT", localHealthBar, "RIGHT", -5, 0);
    CoreModule:MoveRegion(originHealthBar.LeftText, "LEFT", localHealthBar, "LEFT", 2, 0);

    -- ManaBar
    targetFrameContentMain.ManaBar:SetPoint("TOPRIGHT", targetFrameContentMain.HealthBarsContainer, 8, -15);
    targetFrameContentMain.ManaBar:SetFrameLevel(FocusFrame.TargetFrameContainer.FrameTexture:GetParent():GetFrameLevel());

    -- FocusFrameToT
    FocusFrameToT:ClearAllPoints();
    FocusFrameToT:SetPoint("CENTER", FocusFrame, "CENTER", 80, -53);

    FocusFrameToT.FrameTexture:SetTexture(Media:Fetch("frames", "targetoftarget"));
    FocusFrameToT.FrameTexture:SetTexCoord(0, 0.97, 0, 0.8);

    FocusFrameToT.HealthBar:SetFrameLevel(FocusFrameToT.FrameTexture:GetParent():GetFrameLevel());
    FocusFrameToT.ManaBar:SetFrameLevel(FocusFrameToT.FrameTexture:GetParent():GetFrameLevel());

    FocusFrameToT.HealthBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND");

    --FocusFrameToT.name:ClearAllPoints();
    --FocusFrameToT.name:SetPoint("CENTER", FocusFrameToT, "CENTER", 18, 15);
end

function Focus:CheckClassification()
    FocusFrame.TargetFrameContainer.FrameTexture:SetTexture(Media:Fetch("frames", "target-frame"));
    FocusFrame.TargetFrameContainer.Flash:SetTexture(Media:Fetch("misc", "player-status-flash"));

    FocusFrameToT.ManaBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND");
end

function Focus:CheckClassificationForNonEFMode(frame)
    local healthBar = frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar;

    healthBar:SetStatusBarTexture(Media:Fetch("statusbar", db.general.barTexture));
    healthBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0);
end

function Focus:ManaBar_SetStatusBarTexture(manaBar)
    manaBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND");
end

function Focus:MakeClassPortraits(frame)
    if (frame.portrait and (frame.unit == "focus" or frame.unit == "focustarget")) then
        if (db.focus.portrait == "2") then
            SetClassPortraitsOldSyle(frame);
        elseif (db.focus.portrait == "3") then
            SetClassPortraitsNewStyle(frame);
        else
            DefaultPortraits(frame);
        end
    end
end

function Focus:UpdateHealthBarTextString(frame)
    if (frame.unit == "focus") then
        UpdateHealthValues(
            targetFrameContentMain.HealthBarsContainer.HealthBar,
            db.focus.healthFormat,
            db.focus.customHealthFormat,
            db.focus.customHealthFormatFormulas,
            db.focus.useHealthFormatFullValues,
            db.focus.useChineseNumeralsHealthFormat
        )
    end
end

function Focus:UpdateManaBarTextString(frame)
    if (frame.unit == "focus") then
        UpdateManaValues(
            targetFrameContentMain.ManaBar,
            db.focus.manaFormat,
            db.focus.customManaFormat,
            db.focus.customManaFormatFormulas,
            db.focus.useManaFormatFullValues,
            db.focus.useChineseNumeralsManaFormat
        )
    end
end

function Focus:ShowFocusFrameToT()
    if (db.focus.showToTFrame) then
        FocusFrame.totFrame:SetAlpha(1)
    else
        FocusFrame.totFrame:SetAlpha(0)
    end
end

function Focus:ShowName(value)
    if (value) then
        FocusFrame.name:Show();
    else
        FocusFrame.name:Hide();
    end

    self:ShowNameInsideFrame(db.focus.showNameInsideFrame);
end

function Focus:ShowNameInsideFrame(showNameInsideFrame)
    if db.general.useEFTextures then
        local xOffset = -13;
        if showNameInsideFrame then
            xOffset = -28;
        end

        FocusFrame.name:SetJustifyH("CENTER");
        FocusFrame.name:SetWidth(108);

        FocusFrame.name:SetPoint("TOPLEFT", 36, xOffset);

        local healthBar = targetFrameContentMain.HealthBarsContainer.HealthBar;
        local HealthBarTexts = {
            healthBar.RightText,
            healthBar.LeftText,
            healthBar.TextString,
            targetFrameContentMain.HealthBarsContainer.DeadText
        }

        for _, healthBarTextString in pairs(HealthBarTexts) do
            local point, relativeTo, relativePoint, xOffset = healthBarTextString:GetPoint();

            if (showNameInsideFrame and db.focus.showName) then
                CoreModule:MoveRegion(healthBarTextString, point, relativeTo, relativePoint, xOffset, -4);

                --EasyFrames.Const.AURAR_MIRRORED_START_Y = -6
            else
                CoreModule:MoveRegion(healthBarTextString, point, relativeTo, relativePoint, xOffset, 0);

                --EasyFrames.Const.AURAR_MIRRORED_START_Y = 4
            end
        end
    end
end

function Focus:SetHealthBarsFont()
    local fontSize = db.focus.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.focus.healthBarFontFamily)
    local fontStyle = db.focus.healthBarFontStyle

    local healthBar = targetFrameContentMain.HealthBarsContainer.HealthBar

    healthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    healthBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    healthBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Focus:SetManaBarsFont()
    local fontSize = db.focus.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.focus.manaBarFontFamily)
    local fontStyle = db.focus.manaBarFontStyle

    local manaBar = targetFrameContentMain.ManaBar

    manaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    manaBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    manaBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Focus:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.focus.focusNameFontFamily)
    local fontSize = db.focus.focusNameFontSize
    local fontStyle = db.focus.focusNameFontStyle

    FocusFrame.name:SetFont(fontFamily, fontSize, fontStyle)
end

function Focus:SetFrameNameColor()
    local color = db.focus.focusNameColor

    EasyFrames.Utils.SetTextColor(FocusFrame.name, color)
end

function Focus:ResetFrameNameColor()
    EasyFrames.db.profile.focus.focusNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Focus:ReverseDirectionLosingHP(value)
    local healthBar = GetFocusHealthBar()
    local manaBar = targetFrameContentMain.ManaBar

    healthBar:SetReverseFill(value)
    manaBar:SetReverseFill(value)
end

function Focus:ShowAttackBackground(value)
    local frame = FocusFrame.TargetFrameContainer.Flash

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("focus")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Focus:SetAttackBackgroundOpacity(value)
    FocusFrame.TargetFrameContainer.Flash:SetAlpha(value)
end

function Focus:ShowPVPIcon(value)
    for _, frame in pairs({
        FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait,
        FocusFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge,
        FocusFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon,
    }) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (UnitIsPVP("focus")) then
                    frame:Show()
                end
            else
                frame:Hide()

                self:SecureHook(frame, "Show", OnShowHookScript)
            end
        end
    end
end
