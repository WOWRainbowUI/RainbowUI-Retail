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

local MODULE_NAME = "Player";
local Player = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0", "AceEvent-3.0");
local Core = EasyFrames:GetModule("Core");

local db

local UpdateHealthValues = EasyFrames.Utils.UpdateHealthValues
local UpdateManaValues = EasyFrames.Utils.UpdateManaValues
local SetClassPortraitsOldSyle = EasyFrames.Utils.SetClassPortraitsOldSyle;
local SetClassPortraitsNewStyle = EasyFrames.Utils.SetClassPortraitsNewStyle;
local SetClassPortraitToSpecIcon = EasyFrames.Utils.SetClassPortraitToSpecIcon;
local DefaultPortraits = EasyFrames.Utils.DefaultPortraits;
local isNeedsUpdateFrame = false;

local OnShowHookScript = function(frame)
    frame:Hide()
end

local OnSetTextHookScript = function(frame, _, flag)
    if (flag ~= "EasyFramesHookSetText" and not db.player.showHitIndicator) then
        frame:SetText(nil, "EasyFramesHookSetText")
    end
end


function Player:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Player:OnEnable()
    self:ShowName(db.player.showName);
    self:SetFrameNameFont();
    self:SetFrameNameColor();
    self:SetHealthBarsFont();
    self:SetManaBarsFont();
    self:ShowHitIndicator(db.player.showHitIndicator);
    self:ShowSpecialbar(db.player.showSpecialbar);
    self:ShowRestIcon(db.player.showRestIcon);
    self:ShowStatusTexture(db.player.showStatusTexture);
    self:ShowAttackBackground(db.player.showAttackBackground);
    self:SetAttackBackgroundOpacity(db.player.attackBackgroundOpacity);
    self:ShowGroupIndicator(db.player.showGroupIndicator);
    self:ShowRoleIcon(db.player.showRoleIcon);
    self:ShowPVPIcon(db.player.showPVPIcon);

    if db.general.useEFTextures then
        self:SecureHook("PlayerFrame_ToPlayerArt", "PlayerFrame_ToPlayerArt");
        self:SecureHook("PlayerFrame_ToVehicleArt", "PlayerFrame_ToVehicleArt");

        self:SecureHook("PlayerFrame_UpdateStatus", "PlayerFrame_UpdateStatus");
        self:SecureHook("PlayerFrame_UpdatePlayerNameTextAnchor", "PlayerFrame_UpdatePlayerNameTextAnchor");

        self:RegisterEvent("PLAYER_REGEN_ENABLED", "PlayerFrame_UpdateArt");

        self:MovePlayerClassPowerBar();
    end

    hooksecurefunc(PlayerFrame_GetHealthBar(), "UpdateTextString", function()
        self:UpdateHealthBarTextString(PlayerFrame);
    end)

    hooksecurefunc(PlayerFrame_GetManaBar(), "UpdateTextString", function()
        self:UpdateManaBarTextString(PlayerFrame);
    end)

    self:SecureHook("UnitFramePortrait_Update", "MakeClassPortraits");

    if (db.player.portrait == "SPEC_ICON") then
        self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "PlayerSpecializationChanged");
    end
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

    self:UnregisterEvent("PLAYER_REGEN_ENABLED");

    if db.general.useEFTextures then
        self:MovePlayerClassPowerBar();

        self:RegisterEvent("PLAYER_REGEN_ENABLED", "PlayerFrame_UpdateArt");
    end
end


function Player:PlayerFrame_UpdateArt()
    -- out of combat
    if (isNeedsUpdateFrame) then
        if (UnitHasVehiclePlayerFrameUI("player")) then
            self:PlayerFrame_ToVehicleArt();
        else
            self:PlayerFrame_ToPlayerArt();
        end

        isNeedsUpdateFrame = false;
    end
end

function Player:PlayerFrame_ToPlayerArt()
    local healthBarContainer = PlayerFrame_GetHealthBarContainer();
    local healthBar = PlayerFrame_GetHealthBar();
    local manaBar = PlayerFrame_GetManaBar();
    local alternatePowerBar = PlayerFrame_GetAlternatePowerBar();

    PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexture(Media:Fetch("frames", "default"));
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexCoord(1.01, 0.025, 0.24, 1);

    PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:SetTexture(Media:Fetch("frames", "default-alternate"));
    PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:SetTexCoord(1.01, 0.025, 0.24, 1.03);

    -- Update Flash and Status Textures
    local frameFlash = PlayerFrame.PlayerFrameContainer.FrameFlash;
    if alternatePowerBar then
        frameFlash:SetTexture(Media:Fetch("misc", "player-alternate-status-flash"));
        frameFlash:SetTexCoord(0.99, 0, 0.24, 1);
        frameFlash:SetPoint("CENTER",  frameFlash:GetParent(), "CENTER", 2, 0);
    else
        frameFlash:SetTexture(Media:Fetch("misc", "player-status-flash"));
        frameFlash:SetTexCoord(0.99, 0, 0.24, 1);
        frameFlash:SetPoint("CENTER",  frameFlash:GetParent(), "CENTER", 2, 0);
    end

    local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;
    statusTexture:SetTexture(Media:Fetch("misc", "player-status"));
    statusTexture:SetTexCoord(1.008, 0.025, 0.22, 1);

    if (not InCombatLockdown()) then
        -- Update health bar
        healthBarContainer:SetPoint("TOPLEFT", 85, -30);

        healthBar:SetHeight(EasyFrames.Const.HEALTHBAR_HEIGHT);
        healthBarContainer:SetHeight(EasyFrames.Const.HEALTHBAR_HEIGHT);

        healthBarContainer.HealthBarMask:Hide(); -- Reverse in Vehicle
        healthBarContainer:SetFrameStrata("BACKGROUND"); -- Reverse in Vehicle

        -- Update mana bar
        manaBar:SetPoint("TOPLEFT", 85, -55);

        -- Update alternate power bar
        if alternatePowerBar then
            alternatePowerBar:SetPoint("TOPLEFT", 85, -69);
        end
    else
        isNeedsUpdateFrame = true;
    end

    -- Update other stuff
    local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual();
    playerFrameTargetContextual.GroupIndicator:SetPoint("BOTTOMRIGHT", PlayerFrame, "TOPLEFT", 95, -15);
    playerFrameTargetContextual.GroupIndicator.GroupIndicatorLeft:SetAlpha(0);
    playerFrameTargetContextual.GroupIndicator.GroupIndicatorRight:SetAlpha(0);

    playerFrameTargetContextual.RoleIcon:SetPoint("TOPLEFT", 28, -63);

    playerFrameTargetContextual.PrestigePortrait:SetPoint("TOPLEFT", -4, -16);

    PlayerLevelText:SetJustifyH("CENTER");
    PlayerLevelText:SetPoint("BOTTOMLEFT", -138, -10);
end

function Player:PlayerFrame_ToVehicleArt()
    local healthBarContainer = PlayerFrame_GetHealthBarContainer();
    healthBarContainer.HealthBarMask:Show(); -- Default state.

    if (not InCombatLockdown()) then
        healthBarContainer:SetFrameStrata("LOW"); -- Default state.
    end

    PlayerFrame.PlayerFrameContainer.FrameFlash:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1); -- Default state.
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1); -- Default state.
end

function Player:PlayerSpecializationChanged()
    self:MakeClassPortraits(PlayerFrame);
end

function Player:PlayerFrame_UpdatePlayerNameTextAnchor()
    if db.general.useEFTextures then
        local xOffset = -13;
        if db.player.showNameInsideFrame then
            xOffset = -28;
        end

        PlayerName:SetJustifyH("CENTER");
        PlayerName:SetWidth(116);

        if PlayerFrame.unit == "vehicle" then
            PlayerName:SetPoint("TOPLEFT", 96, -27);
        else
            PlayerName:SetPoint("TOPLEFT", 89, xOffset);
        end

        self:ShowNameInsideFrame(db.player.showNameInsideFrame);
    end
end

function Player:ShowName(value)
    if (value) then
        PlayerName:Show()
    else
        PlayerName:Hide()
    end

    self:PlayerFrame_UpdatePlayerNameTextAnchor()
end

function Player:ShowNameInsideFrame(showNameInsideFrame)
    if db.general.useEFTextures then
        local HealthBarTexts = {
            PlayerFrame_GetHealthBar().RightText,
            PlayerFrame_GetHealthBar().LeftText,
            PlayerFrame_GetHealthBar().TextString
        };

        for _, healthBarTextString in pairs(HealthBarTexts) do
            local point, relativeTo, relativePoint, xOffset = healthBarTextString:GetPoint();

            if (showNameInsideFrame and db.player.showName and PlayerFrame.unit ~= "vehicle") then
                Core:MoveRegion(healthBarTextString, point, relativeTo, relativePoint, xOffset, -4);
            else
                Core:MoveRegion(healthBarTextString, point, relativeTo, relativePoint, xOffset, 0);
            end
        end
    end
end

function Player:PlayerFrame_UpdateStatus()
    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:Hide();
end

function Player:MovePlayerClassPowerBar()
    local frame
    local _, class = UnitClass("player")
    local adXOffset = 5
    local adYOffset = 0
    local xGlobalOffset
    local yGlobalOffset

    if PlayerFrame.classPowerBar then
        frame = PlayerFrame.classPowerBar
    elseif class == "SHAMAN" then
        frame = TotemFrame
    elseif class == "DEATHKNIGHT" then
        frame = RuneFrame
        adXOffset = -2
        adYOffset = 4
    elseif class == "PRIEST" then
        frame = PriestBarFrame
    elseif class == "EVOKER" then
        frame = EssencePlayerFrame
        adXOffset = 4
    end

    if class == "DRUID" then
        xGlobalOffset = -4 -- TODO: need to check
        yGlobalOffset = 4
    elseif class == "MAGE" then
        adXOffset = 0
    elseif class == "ROGUE" then
        adXOffset = 5
    end

    if (frame and db.player.specialbarFixPosition) then
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()

        if point then
            Core:MoveRegion(frame, point, relativeTo, relativePoint, xGlobalOffset or (xOffset - adXOffset), yGlobalOffset or (yOffset + adYOffset))
        end
    end
end

function Player:MakeClassPortraits(frame)
    if (frame.unit == "vehicle") then
        DefaultPortraits(frame);

        return
    end

    if (frame.unit == "player" and frame.portrait) then
        if (db.player.portrait == "2") then
            SetClassPortraitsOldSyle(frame);
        elseif (db.player.portrait == "3") then
            SetClassPortraitsNewStyle(frame, true);
        elseif (db.player.portrait == "SPEC_ICON") then
            SetClassPortraitToSpecIcon(frame, true);
        else
            DefaultPortraits(frame);
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
                if (IsResting()) then
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
    }) do
        if frame then
            self:Unhook(frame, "Show")

            if (value) then
                if (IsResting() or UnitAffectingCombat("player")) then
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
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon,
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
