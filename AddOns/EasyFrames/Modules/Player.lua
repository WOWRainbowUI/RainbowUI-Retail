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

local MODULE_NAME = "Player"
local Player = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0")

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local ClassPortraits = EasyFrames.Utils.ClassPortraits
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits

local Core = EasyFrames:GetModule("Core")

local OnShowHookScript = function(frame)
    frame:Hide()
end

local OnSetTextHookScript = function(frame, text, flag)
    if (flag ~= "EasyFramesHookSetText" and not db.player.showHitIndicator) then
        frame:SetText(nil, "EasyFramesHookSetText")
    end
end


function Player:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile

end

function Player:OnEnable()
    self:ShowName(db.player.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    self:ShowHitIndicator(db.player.showHitIndicator)
    self:ShowSpecialbar(db.player.showSpecialbar)
    self:ShowRestIcon(db.player.showRestIcon)
    self:ShowStatusTexture(db.player.showStatusTexture)
    self:ShowAttackBackground(db.player.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.player.attackBackgroundOpacity)
    self:ShowGroupIndicator(db.player.showGroupIndicator)
    self:ShowRoleIcon(db.player.showRoleIcon)
    self:ShowPVPIcon(db.player.showPVPIcon)

    if db.general.useEFTextures then
        self:SecureHook("PlayerFrame_ToPlayerArt", "PlayerFrameToPlayerArt")
        self:SecureHook("PlayerFrame_ToVehicleArt", "PlayerFrameToVehicleArt")
        self:SecureHook("PlayerFrame_UpdateStatus", "PlayerFrameUpdateStatus")
        --self:SecureHook("PlayerFrame_UpdatePlayerNameTextAnchor", "PlayerFrameUpdatePlayerNameTextAnchor") -- @TODO: check the vehicle later.

        --self:SecureHook("UnitFrameManaBar_UpdateType", "UnitFrameManaBarUpdate") -- @TODO check perfomance here
    end

    hooksecurefunc(PlayerFrame_GetHealthBar(), "UpdateTextString", function()
        self:UpdateHealthBarTextString(PlayerFrame)
    end)

    hooksecurefunc(PlayerFrame_GetManaBar(), "UpdateTextString", function()
        self:UpdateManaBarTextString(PlayerFrame)
    end)

    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits")
end

function Player:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    self:MakeClassPortraits(PlayerFrame)
    self:ShowName(db.player.showName)
    self:SetFrameNameFont()
    self:SetFrameNameColor()
    self:SetHealthBarsFont()
    self:SetManaBarsFont()
    self:ShowHitIndicator(db.player.showHitIndicator)
    self:ShowSpecialbar(db.player.showSpecialbar)
    self:ShowRestIcon(db.player.showRestIcon)
    self:ShowStatusTexture(db.player.showStatusTexture)
    self:ShowAttackBackground(db.player.showAttackBackground)
    self:SetAttackBackgroundOpacity(db.player.attackBackgroundOpacity)
    self:ShowGroupIndicator(db.player.showGroupIndicator)
    self:ShowRoleIcon(db.player.showRoleIcon)
    self:ShowPVPIcon(db.player.showPVPIcon)

    self:UpdateHealthBarTextString(PlayerFrame)
    self:UpdateManaBarTextString(PlayerFrame)
end


function Player:PlayerFrameToPlayerArt()
    Core:MovePlayerFrameBars()
    --Core:MovePlayerFramesBarsTextString()

    -- The API changes the texture every time. It is necessary to change it back to own after the changes.
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexture(Media:Fetch("frames", "default"))
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexture(Media:Fetch("misc", "player-status"))
    PlayerFrame.PlayerFrameContainer.FrameFlash:SetTexture(Media:Fetch("misc", "player-status-flash"))

    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexCoord(0.013, 0.803, 0, 0.57)

    TargetFrame.TargetFrameContainer.Flash:SetTexture(Media:Fetch("misc", "player-status-flash"))
end

function Player:PlayerFrameToVehicleArt()
    Core:MovePlayerFrameBars(true)

    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
end

function Player:PlayerFrameUpdateStatus()
    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:Hide()
end

function Player:PlayerFrameUpdatePlayerNameTextAnchor()
    if PlayerFrame.unit == "vehicle" then
        --PlayerName:SetPoint("TOPLEFT", 96, -27);
    else
        --PlayerName:SetPoint("TOPLEFT", 88, -27);
        --Core:MovePlayerFrameName(nil, nil, -28)
    end
end

function Player:UnitFrameManaBarUpdate(manaBar)
    if (not manaBar or not manaBar.unitFrame.frameType or manaBar.unit ~= "player") then
        return;
    end

    manaBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0)
end

function Player:MakeClassPortraits(frame)
    if (frame.unit == "vehicle") then
        DefaultPortraits(frame)

        return
    end

    if (frame.unit == "player" and frame.portrait) then
        if (db.player.portrait == "2") then
            ClassPortraits(frame)
        else
            DefaultPortraits(frame)
        end
    end
end

function Player:ShowName(value)
    if (value) then
        PlayerName:Show()
    else
        PlayerName:Hide()
    end

    self:ShowNameInsideFrame(db.player.showNameInsideFrame)
end

function Player:ShowNameInsideFrame(value)
    if db.general.useEFTextures then
        local HealthBarTexts = {
            PlayerFrame_GetHealthBar().RightText,
            PlayerFrame_GetHealthBar().LeftText,
            PlayerFrame_GetHealthBar().TextString
        }

        for _, healthBar in pairs(HealthBarTexts) do
            local point, relativeTo, relativePoint, xOffset, yOffset = healthBar:GetPoint()

            if (value and db.player.showName) then
                Core:MovePlayerFrameName(nil, nil, -28)

                Core:MoveRegion(healthBar, point, relativeTo, relativePoint, xOffset, yOffset - 4)
            else
                Core:MovePlayerFrameName()

                Core:MoveRegion(healthBar, point, relativeTo, relativePoint, xOffset, 0)
            end
        end
    end
end

function Player:ShowHitIndicator(value)
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText

    if (not value) then
        frame:SetText(nil)

        if (not frame.EasyFramesHookSetText) then
            hooksecurefunc(frame, "SetText", OnSetTextHookScript)
            frame.EasyFramesHookSetText = true
        end
    end
end

function Player:ShowSpecialbar(value)
    local SpecialbarOnShow = function(frame)
        frame:Hide()
    end

    local frame
    local _, class = UnitClass("player")

    if PlayerFrame.classPowerBar then
        frame = PlayerFrame.classPowerBar
    elseif class == "SHAMAN" then
        frame = TotemFrame
    elseif class == "DEATHKNIGHT" then
        frame = RuneFrame
    elseif class == "EVOKER" then
        frame = EssencePlayerFrame
    end

    if (frame) then
        self:Unhook(frame, "OnShow")

        if (value) then
            frame:Show()
        else
            frame:Hide()

            self:HookScript(frame, "OnShow", SpecialbarOnShow)
        end
    end
end

function Player:UpdateHealthBarTextString(frame)
    if (frame.unit == "player") then
        UpdateHealthValues(
            PlayerFrame_GetHealthBar(),
            db.player.healthFormat,
            db.player.customHealthFormat,
            db.player.customHealthFormatFormulas,
            db.player.useHealthFormatFullValues,
            db.player.useChineseNumeralsHealthFormat
        )
    end
end

function Player:UpdateManaBarTextString(frame)
    if (frame.unit == "player") then
        UpdateManaValues(
            PlayerFrame_GetManaBar(),
            db.player.manaFormat,
            db.player.customManaFormat,
            db.player.customManaFormatFormulas,
            db.player.useManaFormatFullValues,
            db.player.useChineseNumeralsManaFormat
        )
    end
end

function Player:SetHealthBarsFont()
    local fontSize = db.player.healthBarFontSize
    local fontFamily = Media:Fetch("font", db.player.healthBarFontFamily)
    local fontStyle = db.player.healthBarFontStyle

    PlayerFrame_GetHealthBar().TextString:SetFont(fontFamily, fontSize, fontStyle)
    PlayerFrame_GetHealthBar().RightText:SetFont(fontFamily, fontSize, fontStyle)
    PlayerFrame_GetHealthBar().LeftText:SetFont(fontFamily, fontSize, fontStyle)
end

function Player:SetManaBarsFont()
    local fontSize = db.player.manaBarFontSize
    local fontFamily = Media:Fetch("font", db.player.manaBarFontFamily)
    local fontStyle = db.player.manaBarFontStyle

    PlayerFrame_GetManaBar().TextString:SetFont(fontFamily, fontSize, fontStyle)
    PlayerFrame_GetManaBar().RightText:SetFont(fontFamily, fontSize, fontStyle)
    PlayerFrame_GetManaBar().LeftText:SetFont(fontFamily, fontSize, fontStyle)

    local playerFrameAlternatePowerBar = PlayerFrame_GetAlternatePowerBar()
    if playerFrameAlternatePowerBar then
        playerFrameAlternatePowerBar.TextString:SetFont(fontFamily, fontSize, fontStyle)
    end
end

function Player:SetFrameNameFont()
    local fontFamily = Media:Fetch("font", db.player.playerNameFontFamily)
    local fontSize = db.player.playerNameFontSize
    local fontStyle = db.player.playerNameFontStyle

    PlayerName:SetFont(fontFamily, fontSize, fontStyle)
end

function Player:SetFrameNameColor()
    local color = db.player.playerNameColor

    EasyFrames.Utils.SetTextColor(PlayerName, color)
end

function Player:ResetFrameNameColor()
    EasyFrames.db.profile.player.playerNameColor = {unpack(EasyFrames.Const.DEFAULT_FRAMES_NAME_COLOR)}
end

function Player:ShowRestIcon(value)
    for _, frame in pairs({
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop,
    }) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (IsResting("player")) then
                    frame:Show()
                end
            else
                frame:Hide()

                self:SecureHook(frame, "Show", OnShowHookScript)
            end
        end
    end
end

function Player:ShowStatusTexture(value)
    for _, frame in pairs({
        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture,
        --PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon,
    }) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (IsResting("player") or UnitAffectingCombat("player")) then
                    frame:Show()
                end
            else
                frame:Hide()

                self:SecureHook(frame, "Show", OnShowHookScript)
            end
        end
    end
end


function Player:ShowAttackBackground(value)
    for _, frame in pairs({
        PlayerFrame.PlayerFrameContainer.FrameFlash,
    }) do
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
end

function Player:SetAttackBackgroundOpacity(value)
    PlayerFrame.PlayerFrameContainer.FrameFlash:SetAlpha(value)
end

function Player:ShowGroupIndicator(value)
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.GroupIndicator

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (IsInRaid("player")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Player:ShowRoleIcon(value)
    local frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.RoleIcon

    if frame then
        self:Unhook(frame, "Show")

        if (value) then
            if (IsInGroup("player")) then
                frame:Show()
            end
        else
            frame:Hide()

            self:SecureHook(frame, "Show", OnShowHookScript)
        end
    end
end

function Player:ShowPVPIcon(value)
    for _, frame in pairs({
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigePortrait,
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PrestigeBadge,
        PlayerPVPTimerText,
    }) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (UnitIsPVP("player")) then
                    frame:Show()
                end
            else
                frame:Hide()

                self:SecureHook(frame, "Show", OnShowHookScript)
            end
        end
    end
end
