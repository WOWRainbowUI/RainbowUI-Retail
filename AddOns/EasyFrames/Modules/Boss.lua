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

local MODULE_NAME = "Boss"
local Boss = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local BossIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetBossFrames())

local InCombatLockdown = InCombatLockdown

function Boss:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Boss:OnEnable()
    self:SetScale(db.boss.scaleFrame)
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    -- Name
    self:ShowName(db.boss.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()

    self:ShowThreatIndicator()

    self:SecureHook("TextStatusBar_UpdateTextStringWithValues", "UpdateTextStringWithValues")
end

function Boss:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:SetScale(db.boss.scaleFrame)
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    -- Name
    self:ShowName(db.boss.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()

    self:ShowThreatIndicator()

    self:UpdateTextStringWithValues()
    self:UpdateTextStringWithValues(Boss1TargetFrameManaBar)
end

function Boss:SetScale(value)
    BossIterator(function(frame)
        if (not InCombatLockdown()) then
            frame:SetScale(value)
        end
    end)

    -- The default boss frame height is 100.
    -- Default scale boss frame is 0.75.
    if (db.boss.setOffset and not ObjectiveTrackerFrame.EasyFramesHookSetPoint) then
        hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(frame, point, relativeTo, relativePoint, xOffset, yOffset, flag)
            if (flag ~= "EasyFramesHookSetPoint" and yOffset) then
                local numBossFrames = 0;
                for i = 1, MAX_BOSS_FRAMES do
                    if (_G["Boss"..i.."TargetFrame"]:IsShown()) then
                        numBossFrames = i;
                    end
                end

                if (numBossFrames > 0) then
                    local diff = value - 0.75

                    if (diff > 0) then
                        local diffYOffset = numBossFrames * (100 * diff)
                        frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset - diffYOffset, "EasyFramesHookSetPoint")
                    end
                end

            end
        end)
        ObjectiveTrackerFrame.EasyFramesHookSetPoint = true
    end
end

function Boss:UpdateTextStringWithValues(statusBar)
    local frame = statusBar or Boss1TargetFrameHealthBar

    if (frame.unit == "boss1" or frame.unit == "boss2" or frame.unit == "boss3" or frame.unit == "boss4" or frame.unit == "boss5") then
        if (string.find(frame:GetName(), 'HealthBar')) then
            UpdateHealthValues(
                frame,
                db.boss.healthFormat,
                db.boss.customHealthFormat,
                db.boss.customHealthFormatFormulas,
                db.boss.useHealthFormatFullValues,
                db.boss.useChineseNumeralsHealthFormat
            )
        elseif (string.find(frame:GetName(), 'ManaBar')) then
            UpdateManaValues(
                frame,
                db.boss.manaFormat,
                db.boss.customManaFormat,
                db.boss.customManaFormatFormulas,
                db.boss.useManaFormatFullValues,
                db.boss.useChineseNumeralsManaFormat
            )
        end
    end
end

function Boss:ShowName(value)
    BossIterator(function(frame)
        if (value) then
            frame.name:Show()
        else
            frame.name:Hide()
        end
    end)

    self:ShowNameInsideFrame(db.boss.showNameInsideFrame)
end

function Boss:ShowNameInsideFrame(value)
    local Core = EasyFrames:GetModule("Core")

    BossIterator(function(frame)
        local HealthBarTexts = {
            frame.healthbar.RightText,
            frame.healthbar.LeftText,
            frame.healthbar.TextString,
        }

        for _, healthBar in pairs(HealthBarTexts) do
            local namePoint, nameRelativeTo, nameRelativePoint, nameXOffset, nameYOffset = frame.name:GetPoint()
            local healthBarPoint, healthBarRelativeTo, healthBarRelativePoint, healthBarXOffset, healthBarYOffset = healthBar:GetPoint()

            if (value and db.boss.showName) then
                Core:MoveRegion(frame.name, namePoint, nameRelativeTo, nameRelativePoint, nameXOffset, 20)
                Core:MoveRegion(healthBar, healthBarPoint, healthBarRelativeTo, healthBarRelativePoint, healthBarXOffset, healthBarYOffset - 4)
            else
                Core:MoveRegion(frame.name, namePoint, nameRelativeTo, nameRelativePoint, nameXOffset, 39)
                Core:MoveRegion(healthBar, healthBarPoint, healthBarRelativeTo, healthBarRelativePoint, healthBarXOffset, 12)
            end
        end
    end)
end

function Boss:SetHealthBarsFont()
    local fontSize = db.boss.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.boss.healthBarFontFamily)
    local fontStyle = db.boss.healthBarFontStyle

    BossIterator(function(frame)
        local healthBar = _G[frame:GetName() .. "HealthBar"]

        healthBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Boss:SetManaBarsFont()
    local fontSize = db.boss.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.boss.manaBarFontFamily)
    local fontStyle = db.boss.manaBarFontStyle

    BossIterator(function(frame)
        local manaBar = _G[frame:GetName() .. "ManaBar"]

        manaBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Boss:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.boss.bossNameFontFamily)
    local fontSize = db.boss.bossNameFontSize
    local fontStyle = db.boss.bossNameFontStyle

    BossIterator(function(frame)
        frame.name:SetFont(fontFamily, fontSize, fontStyle)
    end)
end

function Boss:SetFrameNameColor()
    local color = db.boss.bossNameColor

    BossIterator(function(frame)
        EasyFrames.Utils.SetTextColor(frame.name, color)
    end)
end

function Boss:ResetFrameNameColor()
    EasyFrames.db.profile.boss.bossNameColor = { unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR) }
end

function Boss:ShowThreatIndicator()
    local showThreatIndicator = db.boss.showThreatIndicator

    BossIterator(function(frame)
        if (showThreatIndicator) then
            frame.threatNumericIndicator:SetAlpha(1)
        else
            frame.threatNumericIndicator:SetAlpha(0)
        end
    end)
end