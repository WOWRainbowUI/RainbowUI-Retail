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

local EasyFrames = LibStub("AceAddon-3.0"):GetAddon("EasyFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("EasyFrames")
local Media = LibStub("LibSharedMedia-3.0")

local MODULE_NAME = "Target"
local Target = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local ClassPortraits = EasyFrames.Utils.ClassPortraits
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits

local targetFrameContentMain = EasyFrames.Utils.GetTargetFrameContentMain()
local GetTargetHealthBar = EasyFrames.Utils.GetTargetHealthBar


local OnShowHookScript = function(frame)
    frame:Hide()
end


function Target:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Target:OnEnable()
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

    hooksecurefunc(targetFrameContentMain.HealthBar, "UpdateTextString", function()
        self:UpdateHealthBarTextString(TargetFrame)
    end)

    hooksecurefunc(targetFrameContentMain.ManaBar, "UpdateTextString", function()
        self:UpdateManaBarTextString(TargetFrame)
    end)

    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits")

    self:SecureHook("UnitFrameManaBar_UpdateType", "UnitFrameManaBarUpdate") -- @TODO check perfomance here
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

function Target:UnitFrameManaBarUpdate(manaBar)
    if (not manaBar or not manaBar.unitFrame.frameType or manaBar.unit ~= "target") then
        return;
    end

    local _, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
    local info = PowerBarColor[powerToken];

    local portraitType = manaBar.unitFrame.portrait and "PortraitOn" or "PortraitOff";

    -- Some mana bar art is different for a frame depending on if they are in a vehicle or not.
    -- Special case for the party frame.
    local vehicleText = "";
    if(manaBar.unitFrame.frameType == "Party" and manaBar.unitFrame.state == "vehicle") then
        vehicleText = "-Vehicle";
    end

    if (info) then
        if (manaBar.unitFrame.frameType and info.atlasElementName) then
            local manaBarTexture = "UI-HUD-UnitFrame-Player-"..portraitType..vehicleText.."-Bar-"..info.atlasElementName;
            manaBar:SetStatusBarTexture(manaBarTexture);
        elseif (info.atlas) then
            manaBar:SetStatusBarTexture(info.atlas);
        end
    else
        -- If we cannot find the info for what the mana bar should be, default either to Mana or Mana-Status (colorable).
        local manaBarTexture = "UI-HUD-UnitFrame-Player-"..portraitType..vehicleText.."-Bar-Mana";
        manaBar:SetStatusBarColor(1, 1, 1);

        if (altR) then
            -- This steps around manaBar.lockColor as it is initially setting things.
            manaBarTexture = "UI-HUD-UnitFrame-Player-"..portraitType..vehicleText.."-Bar-Mana-Status";
            manaBar:SetStatusBarColor(altR, altG, altB);
        end

        manaBar:SetStatusBarTexture(manaBarTexture);
    end

    manaBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0)
end

function Target:MakeClassPortraits(frame)
    -- @TODO move targettarget to its own settings module.
    if (frame.portrait and (frame.unit == "target" or frame.unit == "targettarget")) then
        if (db.target.portrait == "2") then
            ClassPortraits(frame)
        else
            DefaultPortraits(frame)
        end
    end
end

function Target:UpdateHealthBarTextString(frame)
    if (frame.unit == "target") then
        UpdateHealthValues(
            targetFrameContentMain.HealthBar,
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
        TargetFrame.name:Show()
    else
        TargetFrame.name:Hide()
    end

    self:ShowNameInsideFrame(db.target.showNameInsideFrame)
end

function Target:ShowNameInsideFrame(value)
    if db.general.useEFTextures then
        local Core = EasyFrames:GetModule("Core")

        local healthBar = targetFrameContentMain.HealthBar

        local HealthBarTexts = {
            healthBar.RightText,
            healthBar.LeftText,
            healthBar.TextString,
            healthBar.DeadText
        }

        for _, healthBarText in pairs(HealthBarTexts) do
            local point, relativeTo, relativePoint, xOffset, yOffset = healthBarText:GetPoint()

            if (value and db.target.showName) then
                Core:MoveTargetFrameName(nil, nil, -28)

                Core:MoveRegion(healthBarText, point, relativeTo, relativePoint, xOffset, yOffset - 4)

                EasyFrames.Const.AURAR_MIRRORED_START_Y = -6
            else
                Core:MoveTargetFrameName()

                Core:MoveRegion(healthBarText, point, relativeTo, relativePoint, xOffset, 0)

                EasyFrames.Const.AURAR_MIRRORED_START_Y = 4
            end
        end
    end
end

function Target:SetHealthBarsFont()
    local fontSize = db.target.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.target.healthBarFontFamily)
    local fontStyle = db.target.healthBarFontStyle

    local healthBar = targetFrameContentMain.HealthBar

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
