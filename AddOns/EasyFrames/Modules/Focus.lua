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

local MODULE_NAME = "Focus"
local Focus = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local ClassPortraits = EasyFrames.Utils.ClassPortraits
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits

local focusFrameContentMain = EasyFrames.Utils.GetFocusFrameContentMain()
local GetFocusHealthBar = EasyFrames.Utils.GetFocusHealthBar


local OnShowHookScript = function(frame)
    frame:Hide()
end


function Focus:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Focus:OnEnable()
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

    hooksecurefunc(focusFrameContentMain.HealthBar, "UpdateTextString", function()
        self:UpdateHealthBarTextString(FocusFrame)
    end)

    hooksecurefunc(focusFrameContentMain.ManaBar, "UpdateTextString", function()
        self:UpdateManaBarTextString(FocusFrame)
    end)

    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits")

    self:SecureHook("UnitFrameManaBar_UpdateType", "UnitFrameManaBarUpdate") -- @TODO check perfomance here
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

function Focus:UnitFrameManaBarUpdate(manaBar)
    if (not manaBar or not manaBar.unitFrame.frameType or manaBar.unit ~= "focus") then
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

function Focus:MakeClassPortraits(frame)
    -- @TODO move focustarget to its own settings module.
    if (frame.portrait and (frame.unit == "focus" or frame.unit == "focustarget")) then
        if (db.focus.portrait == "2") then
            ClassPortraits(frame)
        else
            DefaultPortraits(frame)
        end
    end
end

function Focus:UpdateHealthBarTextString(frame)
    if (frame.unit == "focus") then
        UpdateHealthValues(
            focusFrameContentMain.HealthBar,
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
            focusFrameContentMain.ManaBar,
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
        FocusFrameToT:SetAlpha(1)
    else
        FocusFrameToT:SetAlpha(0)
    end
end

function Focus:ShowName(value)
    if (value) then
        FocusFrame.name:Show()
    else
        FocusFrame.name:Hide()
    end

    self:ShowNameInsideFrame(db.focus.showNameInsideFrame)
end

function Focus:ShowNameInsideFrame(value)
    if db.general.useEFTextures then
        local Core = EasyFrames:GetModule("Core")

        local healthBar = focusFrameContentMain.HealthBar

        local HealthBarTexts = {
            healthBar.RightText,
            healthBar.LeftText,
            healthBar.TextString,
            healthBar.DeadText
        }

        for _, healthBarText in pairs(HealthBarTexts) do
            local point, relativeTo, relativePoint, xOffset, yOffset = healthBarText:GetPoint()

            if (value and db.focus.showName) then
                Core:MoveFocusFrameName(nil, nil, -28)

                Core:MoveRegion(healthBarText, point, relativeTo, relativePoint, xOffset, yOffset - 4)
            else
                Core:MoveFocusFrameName()

                Core:MoveRegion(healthBarText, point, relativeTo, relativePoint, xOffset, 0)
            end
        end
    end
end

function Focus:SetHealthBarsFont()
    local fontSize = db.focus.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.focus.healthBarFontFamily)
    local fontStyle = db.focus.healthBarFontStyle

    local healthBar = focusFrameContentMain.HealthBar

    healthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    healthBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    healthBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Focus:SetManaBarsFont()
    local fontSize = db.focus.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.focus.manaBarFontFamily)
    local fontStyle = db.focus.manaBarFontStyle

    local manaBar = focusFrameContentMain.ManaBar

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
    local manaBar = focusFrameContentMain.ManaBar

    healthBar:SetReverseFill(value)
    manaBar:SetReverseFill(value)
end

function Focus:ShowAttackBackground(value)
    local frame = FocusFrameFlash

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
