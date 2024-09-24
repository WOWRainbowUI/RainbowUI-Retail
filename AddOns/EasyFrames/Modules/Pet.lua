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
local Media = LibStub("LibSharedMedia-3.0")

local MODULE_NAME = "Pet"
local Pet = EasyFrames:NewModule(MODULE_NAME, "AceEvent-3.0", "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues

local OnShowHookScript = function(frame)
    frame:Hide();
end

local OnSetTextHookScript = function(frame, _, flag)
    if (flag ~= "EasyFramesHookSetText" and not db.pet.showHitIndicator) then
        frame:SetText(nil, "EasyFramesHookSetText");
    end
end


function Pet:OnInitialize()
    self.db = EasyFrames.db;
    db = self.db.profile;
end

function Pet:OnEnable()
    if db.general.useEFTextures then
        self:SecureHook("PlayerFrame_UpdateArt", "PlayerFrame_UpdateArt");
    end

    self:SetHealthBarsFont();
    self:ShowName(db.pet.showName);
    self:SetFrameNameFont();
    self:SetFrameNameColor();
    self:SetManaBarsFont();
    self:ShowHitIndicator(db.pet.showHitIndicator);

    self:ShowStatusTexture(db.pet.showStatusTexture);
    self:ShowAttackBackground(db.pet.showAttackBackground);
    self:SetAttackBackgroundOpacity(db.pet.attackBackgroundOpacity);

    hooksecurefunc(PetFrameHealthBar, "UpdateTextString", function()
        self:UpdateHealthBarTextString(PetFrame);
    end)

    hooksecurefunc(PetFrameManaBar, "UpdateTextString", function()
        self:UpdateManaBarTextString(PetFrame);
    end)
end

function Pet:OnProfileChanged(newDB)
    self.db = newDB;
    db = self.db.profile;

    self:SetHealthBarsFont();
    self:ShowName(db.pet.showName);
    self:SetFrameNameFont();
    self:SetFrameNameColor();
    self:SetManaBarsFont();
    self:ShowHitIndicator(db.pet.showHitIndicator);

    self:ShowStatusTexture(db.pet.showStatusTexture);
    self:ShowAttackBackground(db.pet.showAttackBackground);
    self:SetAttackBackgroundOpacity(db.pet.attackBackgroundOpacity);

    self:UpdateHealthBarTextString(PetFrame);
    self:UpdateManaBarTextString(PetFrame);
end

function Pet:PlayerFrame_UpdateArt()
    -- Update Pet Textures
    PetFrameTexture:SetTexture(Media:Fetch("frames", "targetoftarget"))
    PetFrameTexture:SetTexCoord(0.01, 0.97, 0, 0.8)

    PetFrameHealthBar:SetFrameLevel(PetFrameTexture:GetParent():GetFrameLevel());
    PetFrameManaBar:SetFrameLevel(PetFrameTexture:GetParent():GetFrameLevel());

    PetFrameTexture:SetDrawLayer("OVERLAY");
end

function Pet:UpdateHealthBarTextString(frame)
    if (frame.unit == "pet") then
        UpdateHealthValues(
            PetFrameHealthBar,
            db.pet.healthFormat,
            db.pet.customHealthFormat,
            db.pet.customHealthFormatFormulas,
            db.pet.useHealthFormatFullValues,
            db.pet.useChineseNumeralsHealthFormat
        )
    end
end

function Pet:UpdateManaBarTextString(frame)
    if (frame.unit == "pet") then
        UpdateManaValues(
            PetFrameManaBar,
            db.pet.manaFormat,
            db.pet.customManaFormat,
            db.pet.customManaFormatFormulas,
            db.pet.useManaFormatFullValues,
            db.pet.useChineseNumeralsManaFormat
        )
    end
end

function Pet:SetHealthBarsFont()
    local fontSize = db.pet.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.pet.healthBarFontFamily)
    local fontStyle = db.pet.healthBarFontStyle

    PetFrameHealthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    PetFrameHealthBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    PetFrameHealthBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Pet:SetManaBarsFont()
    local fontSize = db.pet.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.pet.manaBarFontFamily)
    local fontStyle = db.pet.manaBarFontStyle

    PetFrameManaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    PetFrameManaBar.RightText:SetFont(fontFamily, fontSize, fontStyle)
    PetFrameManaBar.LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Pet:ShowName(value)
    if (value) then
        PetName:Show()
    else
        PetName:Hide()
    end
end

function Pet:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.pet.petNameFontFamily)
    local fontSize = db.pet.petNameFontSize
    local fontStyle = db.pet.petNameFontStyle

    PetName:SetFont(fontFamily, fontSize, fontStyle)
end

function Pet:SetFrameNameColor()
    local color = db.pet.petNameColor

    EasyFrames.Utils.SetTextColor(PetName, color)
end

function Pet:ResetFrameNameColor()
    EasyFrames.db.profile.pet.petNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Pet:ShowHitIndicator(value)
    local frame = PetHitIndicator

    if (not value) then
        frame:SetText(nil)

        if (not frame.EasyFramesHookSetText) then
            hooksecurefunc(frame, "SetText", OnSetTextHookScript)
            frame.EasyFramesHookSetText = true
        end
    end
end

function Pet:ShowStatusTexture(value)
    local frame = PetAttackModeTexture

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("player")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Pet:ShowAttackBackground(value)
    local frame = PetFrameFlash

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (UnitAffectingCombat("player")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Pet:SetAttackBackgroundOpacity(value)
    PetFrameFlash:SetAlpha(value)
end
