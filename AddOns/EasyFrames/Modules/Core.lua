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

local MODULE_NAME = "Core"
local Core = EasyFrames:NewModule(MODULE_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local db
local PartyIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetPartyFrames())
local BossIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetBossFrames())

local CreateBar = EasyFrames.Utils.CreateBar

local OnSetPointHookScript = function(point, relativeTo, relativePoint, xOffset, yOffset)
    return function(frame, _, _, _, _, _, flag)
        if flag ~= "EasyFramesHookSetPoint" then
            frame:ClearAllPoints()
            frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, "EasyFramesHookSetPoint")
        end
    end
end

function Core:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function Core:OnEnable()
    if db.general.useEFTextures then
        self:SecureHook("UnitFrame_Update", "UnitFrame_Update");

        --local _, class = UnitClass("player")
        --if class == "DRUID" then
        --    self:RegisterEvent("UNIT_DISPLAYPOWER", "UnitDisplaypower")
        --end

        --self:MovePartyFrameBars()
        --self:MoveBossFrameBars()
    end

    if (db.general.showWelcomeMessage) then
        print("|cff0cbd0cEasy Frames|cffffffff " .. L["loaded. Options:"] .. " |cff0cbd0c/ef")
    end
end

function Core:OnProfileChanged(newDB)
    -- db.general.useEFTextures == nil it's the same as true.

    if (db.general) and ((db.general.useEFTextures == nil
        and newDB.profile.general.useEFTextures == false
    ) or (db.general.useEFTextures == false
        and newDB.profile.general.useEFTextures == true
    )) or not db.general then
        EasyFrames.Helpers.ConfirmPopup(
            L["You are going to toggle the \"Use the Easy Frames style\" setting, you need to reload the UI for it to work correctly.\n\n Do you want to reload the UI?"],
            function()
                ReloadUI();
            end
        )
    end

    self.db = newDB
    db = self.db.profile
end


function Core:UnitFrame_Update(frame)
    if (frame.unit == "target" or frame.unit == "focus") then
        self:UnitFrameHealthBar_Update(frame.EasyFrames.healthbar);
        self:UnitFrameHealPredictionBars_Update(frame);

        if ( frame.EasyFrames.tempMaxHealthLossBar and frame.EasyFrames.tempMaxHealthLossBar.initialized) then
            self:TempMaxHealthLoss_OnMaxHealthModifiersChanged(frame.EasyFrames.tempMaxHealthLossBar, GetUnitTotalModifiedMaxHealthPercent(frame.unit));
        end
    end
end

function Core:CreateHealthBarFor(parentFrame)
    local HealthBar = CreateBar(parentFrame, "HealthBar")
    HealthBar:SetFrameLevel(HealthBar:GetParent():GetFrameLevel())

    HealthBar:SetScript("OnEvent", function()
        Core:UnitFrameHealthBar_Update(HealthBar)
    end)

    HealthBar:RegisterUnitEvent("UNIT_HEALTH", HealthBar.unit);
    HealthBar:RegisterUnitEvent("UNIT_MAXHEALTH", HealthBar.unit);

    local TempMaxHealthLossBar = CreateBar(parentFrame, "TempMaxHealthLoss");
    TempMaxHealthLossBar:SetFrameLevel(HealthBar:GetFrameLevel() + 1);
    TempMaxHealthLossBar:SetStatusBarTexture(Media:Fetch("statusbar", db.general.barTexture));
    TempMaxHealthLossBar:SetPoint("RIGHT", HealthBar, "RIGHT", 0, 0);

    TempMaxHealthLossBar:SetScript("OnEvent", function(_, _, ...)
        local _, arg2 = ...
        Core:TempMaxHealthLoss_OnMaxHealthModifiersChanged(TempMaxHealthLossBar, arg2);
    end);

    TempMaxHealthLossBar:RegisterUnitEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED", HealthBar.unit);

    local tempMaxHealthLossBarTexture = TempMaxHealthLossBar:GetStatusBarTexture();
    tempMaxHealthLossBarTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-TempHPLoss", TextureKitConstants.UseAtlasSize);
    tempMaxHealthLossBarTexture:SetDrawLayer("BACKGROUND");

    local TotalAbsorbBar = CreateBar(parentFrame, "TotalAbsorbBar")
    TotalAbsorbBar:SetFrameLevel(HealthBar:GetFrameLevel())
    TotalAbsorbBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Fill")

    TotalAbsorbBar:SetScript("OnEvent", function()
        Core:UnitFrameHealPredictionBars_Update(parentFrame)
    end)

    TotalAbsorbBar:RegisterUnitEvent("UNIT_HEALTH", HealthBar.unit)
    TotalAbsorbBar:RegisterUnitEvent("UNIT_MAXHEALTH", HealthBar.unit)
    TotalAbsorbBar:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", HealthBar.unit)
    TotalAbsorbBar:RegisterUnitEvent("UNIT_HEAL_PREDICTION", HealthBar.unit)
    TotalAbsorbBar:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", HealthBar.unit)

    local TotalAbsorbBarOverlay = CreateBar(parentFrame, "TotalAbsorbBarOverlay")
    TotalAbsorbBarOverlay.tileSize = 32
    TotalAbsorbBarOverlay:SetFrameLevel(TotalAbsorbBar:GetFrameLevel() + 1)
    TotalAbsorbBarOverlay:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Overlay")
    TotalAbsorbBarOverlay:SetAllPoints(TotalAbsorbBar)

    local HealPredictionBar = CreateBar(parentFrame, "HealPredictionBar")
    HealPredictionBar:SetFrameLevel(HealthBar:GetFrameLevel())
    HealPredictionBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    HealPredictionBar:GetStatusBarTexture():SetVertexColor(0.0, 0.827, 0.765)

    local OverAbsorbGlow = CreateBar(parentFrame, "OverAbsorbGlow")
    OverAbsorbGlow:SetFrameLevel(HealthBar:GetFrameLevel())
    OverAbsorbGlow:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Overshield")
    OverAbsorbGlow:GetStatusBarTexture():SetBlendMode("ADD")
    OverAbsorbGlow:SetPoint("BOTTOMLEFT", HealthBar, "BOTTOMRIGHT", -7, 0)
    OverAbsorbGlow:SetPoint("TOPLEFT", HealthBar, "TOPRIGHT", -7, 0)
    OverAbsorbGlow:SetWidth(16)

    local OverHealAbsorbGlow = CreateBar(parentFrame, "OverHealAbsorbGlow")
    OverHealAbsorbGlow:SetFrameLevel(HealthBar:GetFrameLevel() + 1)
    OverHealAbsorbGlow:SetStatusBarTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
    OverHealAbsorbGlow:GetStatusBarTexture():SetBlendMode("ADD")
    OverHealAbsorbGlow:SetPoint("BOTTOMRIGHT", HealthBar, "BOTTOMLEFT", 7, 0)
    OverHealAbsorbGlow:SetPoint("TOPRIGHT", HealthBar, "TOPLEFT", 7, 0)
    OverHealAbsorbGlow:SetWidth(16)

    local HealAbsorbBar = CreateBar(parentFrame, "HealAbsorbBar")
    HealAbsorbBar:SetStatusBarTexture("Interface\\RaidFrame\\Absorb-Fill")
    HealAbsorbBar:SetFrameLevel(HealthBar:GetFrameLevel())

    local HealAbsorbBarLeftShadow = CreateBar(parentFrame, "HealAbsorbBarLeftShadow")
    HealAbsorbBarLeftShadow:SetStatusBarTexture("Interface\\RaidFrame\\Absorb-Edge")
    HealAbsorbBarLeftShadow:SetSize(8, EasyFrames.Const.HEALTHBAR_HEIGHT)

    local HealAbsorbBarRightShadow = CreateBar(parentFrame, "HealAbsorbBarRightShadow")
    HealAbsorbBarRightShadow:SetStatusBarTexture("Interface\\RaidFrame\\Absorb-Edge")
    HealAbsorbBarRightShadow:SetSize(8, EasyFrames.Const.HEALTHBAR_HEIGHT)
    HealAbsorbBarRightShadow:GetStatusBarTexture():SetTexCoord(1, 0, 0, 1);

    for _, frame in pairs({
        HealthBar,
        TempMaxHealthLossBar,
    }) do
        if (frame) then
            frame:SetSize(EasyFrames.Const.HEALTHBAR_WIDTH_BLIZZARD, EasyFrames.Const.HEALTHBAR_HEIGHT)
        end
    end

    Core:TempMaxHealthLoss_InitalizeMaxHealthLossBar(TempMaxHealthLossBar, HealthBar, HealthBar);

    parentFrame.EasyFrames = {
        healthbar = HealthBar,
        totalAbsorbBar = TotalAbsorbBar,
        overAbsorbGlow = OverAbsorbGlow,
        otherHealPredictionBar = HealPredictionBar,
        overHealAbsorbGlow = OverHealAbsorbGlow,
        healAbsorbBar = HealAbsorbBar,
        healAbsorbBarLeftShadow = HealAbsorbBarLeftShadow,
        healAbsorbBarRightShadow = HealAbsorbBarRightShadow,
        tempMaxHealthLossBar = TempMaxHealthLossBar,
    }
    parentFrame.EasyFrames.totalAbsorbBar.overlay = TotalAbsorbBarOverlay
end

-- Code from Blizzard with some changes.
local MAX_INCOMING_HEAL_OVERFLOW = 1.0;
function Core:UnitFrameHealPredictionBars_Update(frame)
    local _, maxHealth = frame.EasyFrames.healthbar:GetMinMaxValues();
    local health = frame.EasyFrames.healthbar:GetValue();
    if ( maxHealth <= 0 ) then
        return;
    end

    local allIncomingHeal = UnitGetIncomingHeals(frame.unit) or 0;
    local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0;

    local myCurrentHealAbsorb = 0;
    if ( frame.EasyFrames.healAbsorbBar ) then
        myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(frame.unit) or 0;

        --We don't fill outside the health bar with healAbsorbs.  Instead, an overHealAbsorbGlow is shown.
        if ( health < myCurrentHealAbsorb ) then
            frame.EasyFrames.overHealAbsorbGlow:Show();
            myCurrentHealAbsorb = health;
        else
            frame.EasyFrames.overHealAbsorbGlow:Hide();
        end
    end

    --See how far we're going over the health bar and make sure we don't go too far out of the frame.
    if ( health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW ) then
        allIncomingHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health + myCurrentHealAbsorb;
    end

    --We don't fill outside the the health bar with absorbs.  Instead, an overAbsorbGlow is shown.
    local overAbsorb = false;
    if ( health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth ) then
        if ( totalAbsorb > 0 ) then
            overAbsorb = true;
        end

        if ( allIncomingHeal > myCurrentHealAbsorb ) then
            totalAbsorb = max(0,maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal));
        else
            totalAbsorb = max(0,maxHealth - health);
        end
    end

    if ( overAbsorb ) then
        frame.EasyFrames.overAbsorbGlow:Show();
    else
        frame.EasyFrames.overAbsorbGlow:Hide();
    end

    local healthTexture = frame.EasyFrames.healthbar:GetStatusBarTexture();
    local myCurrentHealAbsorbPercent = 0;
    local healAbsorbTexture = nil;

    if ( frame.EasyFrames.healAbsorbBar ) then
        myCurrentHealAbsorbPercent = myCurrentHealAbsorb / maxHealth;

        --If allIncomingHeal is greater than myCurrentHealAbsorb, then the current
        --heal absorb will be completely overlayed by the incoming heals so we don't show it.
        if ( myCurrentHealAbsorb > allIncomingHeal ) then
            local shownHealAbsorb = myCurrentHealAbsorb - allIncomingHeal;
            local shownHealAbsorbPercent = shownHealAbsorb / maxHealth;

            healAbsorbTexture = Core:UnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.EasyFrames.healAbsorbBar, shownHealAbsorb, -shownHealAbsorbPercent);

            --If there are incoming heals the left shadow would be overlayed by the incoming heals
            --so it isn't shown.
            if ( allIncomingHeal > 0 ) then
                frame.EasyFrames.healAbsorbBarLeftShadow:Hide();
            else
                frame.EasyFrames.healAbsorbBarLeftShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPLEFT", 0, 0);
                frame.EasyFrames.healAbsorbBarLeftShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMLEFT", 0, 0);
                frame.EasyFrames.healAbsorbBarLeftShadow:Show();
            end

            -- The right shadow is only shown if there are absorbs on the health bar.
            if ( totalAbsorb > 0 ) then
                frame.EasyFrames.healAbsorbBarRightShadow:SetPoint("TOPLEFT", healAbsorbTexture, "TOPRIGHT", -8, 0);
                frame.EasyFrames.healAbsorbBarRightShadow:SetPoint("BOTTOMLEFT", healAbsorbTexture, "BOTTOMRIGHT", -8, 0);
                frame.EasyFrames.healAbsorbBarRightShadow:Show();
            else
                frame.EasyFrames.healAbsorbBarRightShadow:Hide();
            end
        else
            frame.EasyFrames.healAbsorbBar:Hide();
            frame.EasyFrames.healAbsorbBarLeftShadow:Hide();
            frame.EasyFrames.healAbsorbBarRightShadow:Hide();
        end
    end

    --Show incomingHeal on the health bar.
    local incomingHealTexture = Core:UnitFrameUtil_UpdateFillBar(frame, healthTexture, frame.EasyFrames.otherHealPredictionBar, allIncomingHeal, -myCurrentHealAbsorbPercent);

    --Append absorbs to the correct section of the health bar.
    local appendTexture = nil;
    if ( healAbsorbTexture ) then
        --If there is a healAbsorb part shown, append the absorb to the end of that.
        appendTexture = healAbsorbTexture;
    else
        --Otherwise, append the absorb to the end of the the incomingHeals part;
        appendTexture = incomingHealTexture;
    end
    Core:UnitFrameUtil_UpdateFillBar(frame, appendTexture, frame.EasyFrames.totalAbsorbBar, totalAbsorb)
end

function Core:UnitFrameUtil_UpdateFillBarBase(_, realbar, previousTexture, bar, amount, barOffsetXPercent)
    if ( amount == 0 ) then
        bar:Hide();
        if ( bar.overlay ) then
            bar.overlay:Hide();
        end
        return previousTexture;
    end

    local barOffsetX = 0;
    if ( barOffsetXPercent ) then
        local realbarSizeX = realbar:GetWidth();
        barOffsetX = realbarSizeX * barOffsetXPercent;
    end

    bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0);
    bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0);

    local totalWidth, totalHeight = realbar:GetSize();
    local _, totalMax = realbar:GetMinMaxValues();

    local barSize = (amount / totalMax) * totalWidth;
    bar:SetWidth(barSize);
    bar:Show();
    if ( bar.overlay ) then
        bar.overlay:GetStatusBarTexture():SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize);
        bar.overlay:Show();
    end
    return bar;
end

function Core:UnitFrameUtil_UpdateFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
    return Core:UnitFrameUtil_UpdateFillBarBase(frame, frame.EasyFrames.healthbar, previousTexture, bar, amount, barOffsetXPercent);
end

function Core:TempMaxHealthLoss_InitalizeMaxHealthLossBar(bar, healthBarsContainer, healthBar)
    bar.myHealthBarContainer = healthBarsContainer;
    bar.healthBar = healthBar;
    bar:SetFillStyle("REVERSE");
    bar:SetMinMaxValues(0, 1);

    bar.initialized = true;
end

function Core:TempMaxHealthLoss_SetShouldAdjustHealthBarAnchor(bar, xOffset, yOffset)
    bar.ShouldAdjustHealthBarAnchor = true;
    bar.xAnchorOffset = xOffset;
    bar.yAnchorOffset = yOffset;
end

function Core:TempMaxHealthLoss_OnMaxHealthModifiersChanged(bar, value)
    --current UI implementation only cares about showing max health loss, not gain
    local clampedValue = Clamp(value, 0, 1);
    --disable / enable all tempMaxHealth loss bars with CVar
    if (GetCVarBool("showTempMaxHealthLoss")) then
        self:TempMaxHealthLoss_Update_MaxHealthLoss(bar, clampedValue);
    end
end

function Core:TempMaxHealthLoss_Update_MaxHealthLoss(bar, fillPercent)
    --local fullWidth = bar.myHealthBarContainer:GetWidth();
    local fullWidth = EasyFrames.Const.HEALTHBAR_WIDTH_BLIZZARD;
    if ( bar.ShouldAdjustHealthBarAnchor ) then
        bar.healthBar:SetPoint("BOTTOMRIGHT", bar.myHealthBarContainer, "BOTTOMRIGHT", ((fullWidth*(fillPercent))*-1) + bar.xAnchorOffset, bar.yAnchorOffset);
    else
        --bar.healthBar:SetWidth(fullWidth*(1-fillPercent));
    end
    bar:Show();
    bar:SetValue(fillPercent);
end

function Core:SetTexture()
    -- Party
    --PartyIterator(function(frame)
    --    _G[frame:GetName() .. "Texture"]:SetTexture(Media:Fetch("frames", "smalltarget"))
    --end)

    -- Boss
    --BossIterator(function(frame)
    --    local borderTexture = frame.TargetFrameContainer.FrameTexture;
    --    borderTexture:SetTexture(Media:Fetch("frames", "boss"))
    --end)
end

function Core:UnitFrameHealthBar_Update(frame)
    frame:SetMinMaxValues(0, UnitHealthMax(frame.unit))
    frame:SetValue(UnitHealth(frame.unit))
end

function Core:PlayerEnteringWorld()
    if TargetFrame:IsShown() then
        TargetFrame:UpdateAuras()
    end
end

function Core:MoveRegion(frame, point, relativeTo, relativePoint, xOffset, yOffset)
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset, "EasyFramesHookSetPoint")

    if (not frame.EasyFramesHookSetPoint) then
        hooksecurefunc(frame, "SetPoint", OnSetPointHookScript(point, relativeTo, relativePoint, xOffset, yOffset))
        frame.EasyFramesHookSetPoint = true
    end
end

function Core:MoveFramesNames()
    -- Names
    --PartyIterator(function(frame)
    --    local point, relativeTo, relativePoint, xOffset, yOffset = frame.name:GetPoint()
    --
    --    Core:MoveRegion(frame.name, point, relativeTo, relativePoint, xOffset, yOffset - 3)
    --end)
    --
    --BossIterator(function(frame)
    --    local point, relativeTo, relativePoint, xOffset, yOffset = frame.name:GetPoint()
    --
    --    Core:MoveRegion(frame.name, point, relativeTo, relativePoint, xOffset, yOffset + 20)
    --end)
end

function Core:MovePartyFrameBars()
    PartyIterator(function(frame)
        _G[frame:GetName() .. "Background"]:SetVertexColor(0, 0, 0, 0)

        local healthBar = _G[frame:GetName() .. "HealthBar"]
        local manaBar = _G[frame:GetName() .. "ManaBar"]

        healthBar:SetHeight(13)

        Core:MoveRegion(healthBar, "CENTER", frame, "CENTER", 16, 4)
        Core:MoveRegion(healthBar.TextString, "CENTER", healthBar, "CENTER", 0, 0)
        Core:MoveRegion(healthBar.RightText, "RIGHT", frame, "RIGHT", -12, 4)
        Core:MoveRegion(healthBar.LeftText, "LEFT", frame, "LEFT", 46, 4)

        Core:MoveRegion(manaBar, "CENTER", frame, "CENTER", 16, -8)
        Core:MoveRegion(manaBar.TextString, "CENTER", manaBar, "CENTER", 0, 0)
        Core:MoveRegion(manaBar.RightText, "RIGHT", frame, "RIGHT", -12, -8)
        Core:MoveRegion(manaBar.LeftText, "LEFT", frame, "LEFT", 46, -8)
    end)
end

function Core:MoveBossFrameBars()
    BossIterator(function(frame)
        local frameContentMain = _G[frame:GetName()].TargetFrameContent.TargetFrameContentMain;
        local healthBar = frameContentMain.HealthBarsContainer.HealthBar;

        healthBar:SetHeight(27)

        Core:MoveRegion(healthBar, "TOPRIGHT", frame, "TOPRIGHT", -106, -25)
        Core:MoveRegion(healthBar.TextString, "CENTER", frame, "CENTER", -50, 12)
        Core:MoveRegion(healthBar.RightText, "RIGHT", frame, "RIGHT", -110, 12)
        Core:MoveRegion(healthBar.LeftText, "LEFT", frame, "LEFT", 8, 12)
    end)
end
