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

local MODULE_NAME = "General"
local General = EasyFrames:NewModule(MODULE_NAME, "AceHook-3.0", "AceEvent-3.0")

local db

local GetFramesHealthBar = EasyFrames.Utils.GetFramesHealthBar
local GetFramesManaBar = EasyFrames.Utils.GetFramesManaBar
local GetAllFrames = EasyFrames.Utils.GetAllFrames
local GetTargetHealthBar = EasyFrames.Utils.GetTargetHealthBar
local GetFocusHealthBar = EasyFrames.Utils.GetFocusHealthBar

local AllFramesIterator = EasyFrames.Helpers.Iterator(GetAllFrames())
local PartyIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetPartyFrames())
local BossIterator = EasyFrames.Helpers.Iterator(EasyFrames.Utils.GetBossFrames())

local DEFAULT_BUFF_SIZE = 17

local registeredCombatEvent = false

-- aura positioning constants
local AURA_START_X = 10; -- default is 5
local AURA_START_Y = 12; -- default is 9
local AURA_OFFSET_Y = 3;
local LARGE_AURA_SIZE = 21;
local SMALL_AURA_SIZE = 17;
local AURA_ROW_WIDTH = 105; -- default is 122
local TOT_AURA_ROW_WIDTH = 101;
local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

local PLAYER_UNITS = {
    player = true,
    vehicle = true,
    pet = true,
};

local function ClassColored(originStatusbar, unit, localStatusbar)
    local statusbar = localStatusbar or originStatusbar

    if (db.general.colorBasedOnCurrentHealth) then
        local value = UnitHealth(unit)
        local min, max = originStatusbar:GetMinMaxValues()

        local r, g

        if ((value < min) or (value > max)) then
            return
        end

        if ((max - min) > 0) then
            value = (value - min) / (max - min)
        else
            value = 0
        end

        if (value > 0.5) then
            r = (1.0 - value) * 2
            g = 1.0
        else
            r = 1.0
            g = value * 2
        end

        statusbar:SetStatusBarColor(r, g, 0.0)

        return
    end

    if (UnitIsPlayer(unit) and UnitClass(unit)) then
        -- player
        if (db.general.classColored) then
            local _, class, classColor

            _, class = UnitClass(unit)
            classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

            statusbar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
            --statusbar:SetStatusBarDesaturated(true)
        else
            local colors

            if (UnitIsFriend("player", unit)) then
                colors = db.general.friendlyFrameDefaultColors
            else
                colors = db.general.enemyFrameDefaultColors
            end

            statusbar:SetStatusBarColor(colors[1], colors[2], colors[3])
        end
    else
        -- non player
        local colors

        local red, green, _ = UnitSelectionColor(unit)

        if (red == 0) then
            colors = db.general.friendlyFrameDefaultColors
        elseif (green == 0) then
            colors = db.general.enemyFrameDefaultColors
        else
            colors = db.general.neutralFrameDefaultColors
        end

        if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
            colors = {0.5, 0.5, 0.5}
        end

        statusbar:SetStatusBarColor(colors[1], colors[2], colors[3])
    end
end


function General:OnInitialize()
    self.db = EasyFrames.db
    db = self.db.profile
end

function General:OnEnable()
    if db.general.useEFTextures then
        self:SetLightTexture(db.general.lightTexture)

        --     self:SecureHook("TargetFrame_UpdateAuraPositions", "MakeCustomBuffSize") -- self:UpdateAuraFrames(self.activeBuffs, numBuffs, numDebuffs, UpdateAuraFrame, Tar
        --     self:SecureHook("TargetFrame_UpdateAuras", "TargetFrame_UpdateAuras") -- self:UpdateAuras(unitAuraUpdateInfo);

        self:SecureHook("TargetFrame_UpdateBuffAnchor", "TargetFrameUpdateBuffAnchor") -- self:UpdateAuras(unitAuraUpdateInfo);
        self:SecureHook("TargetFrame_UpdateDebuffAnchor", "TargetFrameUpdateDebuffAnchor") -- self:UpdateAuras(unitAuraUpdateInfo);
    end

    self:SecureHook("UnitFrameHealthBar_Update", "MakeFramesColored")
    self:SecureHook("HealthBar_OnValueChanged", function(statusbar)
        self:MakeFramesColored(statusbar, statusbar.unit)
    end)

    self:SetFrameBarTexture(db.general.barTexture)

    if (db.general.hideOutOfCombat) then
        self:HideFramesOutOfCombat()

        registeredCombatEvent = true
    end

    self:SetBrightFramesBorder(db.general.brightFrameBorder)

    --self:SetMaxBuffCount(db.general.maxBuffCount)
    --self:SetMaxDebuffCount(db.general.maxDebuffCount)
end

function General:OnProfileChanged(newDB)
    self.db = newDB
    db = self.db.profile

    if db.general.useEFTextures then
        self:SetLightTexture(db.general.lightTexture)
    end

    self:SetFramesColored()

    self:SetFrameBarTexture(db.general.barTexture)

    self:HideFramesOutOfCombat()

    self:SetBrightFramesBorder(db.general.brightFrameBorder)

    self:SetCustomBuffSize(db.general.customBuffSize)

    --self:SetMaxBuffCount(db.general.maxBuffCount)
    --self:SetMaxDebuffCount(db.general.maxDebuffCount)
end


function General:ResetFriendlyFrameDefaultColors()
    EasyFrames.db.profile.general.friendlyFrameDefaultColors = {0, 1, 0}
end

function General:ResetEnemyFrameDefaultColors()
    EasyFrames.db.profile.general.enemyFrameDefaultColors = {1, 0, 0}
end

function General:ResetNeutralFrameDefaultColors()
    EasyFrames.db.profile.general.neutralFrameDefaultColors = {1, 1, 0}
end

function General:SetFramesColored()
    local healthBars = GetFramesHealthBar()

    for _, statusbar in pairs(healthBars) do
        if (UnitIsConnected(statusbar.unit)) then
            ClassColored(statusbar, statusbar.unit)
        end
    end
end

function General:MakeFramesColored(statusbar, unit)
    if (not unit) then return end

    if (UnitIsConnected(unit) and unit == statusbar.unit) then
        -- Ovrerwrite to local.
        if (db.general.useEFTextures and statusbar == TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar) then
            ClassColored(statusbar, unit, GetTargetHealthBar())
        elseif (db.general.useEFTextures and statusbar == FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar) then
            ClassColored(statusbar, unit, GetFocusHealthBar())
        else
            -- Old (normal) behavior.
            ClassColored(statusbar, unit)
        end
    end
end

function General:CombatStatusEvent(event)
    if (event == 'PLAYER_REGEN_DISABLED') then
        -- combat
        self:HideFramesOutOfCombat(true)
    else
        -- out of combat
        self:HideFramesOutOfCombat()
    end
end

function General:HideFramesOutOfCombat(forceShow)
    local hide = db.general.hideOutOfCombat
    local opacity = db.general.hideOutOfCombatOpacity

    AllFramesIterator(function(frame)
        if (hide and not forceShow) then
            frame:SetAlpha(opacity)

            if (opacity == 0) then
                if (frame:IsShown()) then
                    frame:Hide()
                    frame.__hiddenByAddon__ = true
                end
            else
                if (frame.__hiddenByAddon__) then
                    frame:Show()
                end
            end
        else
            frame:SetAlpha(1)

            if (frame.__hiddenByAddon__) then
                frame:Show()
            end
        end
    end)

    if (hide and not registeredCombatEvent) then
        self:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatStatusEvent")
        self:RegisterEvent("PLAYER_REGEN_ENABLED", "CombatStatusEvent")
    end
end

function General:SetFrameBarTexture(value)
    local texture = Media:Fetch("statusbar", value)

    local healthBars = GetFramesHealthBar()
    local manaBars = GetFramesManaBar()

    for _, healthbar in pairs(healthBars) do
        healthbar:SetStatusBarTexture(texture)
        --healthbar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0)
    end

    PlayerFrame_GetHealthBar().AnimatedLossBar:SetStatusBarTexture(texture) -- fix for blinking red texture
    PlayerFrame_GetHealthBar().AnimatedLossBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0)

    for _, manabar in pairs(manaBars) do
        -- This is old color and texture.
        --manabar:SetStatusBarTexture(texture)
        --manabar:SetStatusBarColor(0, 0, 1)

        manabar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 0)
    end
end

function General:SetBrightFramesBorder(value)
    for _, t in pairs({
        PlayerFrame.PlayerFrameContainer.FrameTexture, PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture,
        PetFrameTexture,
        TargetFrame.TargetFrameContainer.FrameTexture, TargetFrameToT.FrameTexture,
        TargetFrame.TargetFrameContainer.BossPortraitFrameTexture,
        FocusFrame.TargetFrameContainer.FrameTexture, FocusFrameToT.FrameTexture,
        --PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture, PartyMemberFrame4Texture,
        --PartyMemberFrame1PetFrameTexture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame4PetFrameTexture,
        --Boss1TargetFrameTextureFrameTexture, Boss2TargetFrameTextureFrameTexture, Boss3TargetFrameTextureFrameTexture, Boss4TargetFrameTextureFrameTexture, Boss5TargetFrameTextureFrameTexture
    }) do
        t:SetVertexColor(value, value, value)
    end
end

function General:SetTexture()
    -- Player
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexture(Media:Fetch("frames", "default"))
    PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:SetTexture(Media:Fetch("frames", "default-alternate"))
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexture(Media:Fetch("misc", "player-status"))
    PlayerFrame.PlayerFrameContainer.FrameFlash:SetTexture(Media:Fetch("misc", "player-status-flash"))

    PlayerFrame.PlayerFrameContainer.FrameTexture:SetTexCoord(0.858, 0.058, 0.068, 0.658)
    PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:SetTexCoord(0.858, 0.058, 0.068, 0.658)
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetTexCoord(0.013, 0.803, 0, 0.57)
    PlayerFrame.PlayerFrameContainer.FrameFlash:SetTexCoord(0.86, 0.07, 0.009, 0.168)

    -- Target, Focus
    local targetFrames = {
        TargetFrame,
        FocusFrame,
    }

    for _, frame in pairs(targetFrames) do
        EasyFrames:GetModule("Core"):CheckClassification(frame)
    end

    TargetFrame.TargetFrameContainer.FrameTexture:SetTexCoord(0.068, 0.85, 0.084, 0.642)
    TargetFrame.TargetFrameContainer.Flash:SetTexCoord(0.07, 0.854, 0.01, 0.16)

    TargetFrameToT.FrameTexture:SetTexture(Media:Fetch("frames", "smalltarget"))
    TargetFrameToT.FrameTexture:SetTexCoord(0.01, 0.95, 0.02, 0.765)

    FocusFrame.TargetFrameContainer.FrameTexture:SetTexCoord(0.068, 0.85, 0.084, 0.642)
    FocusFrame.TargetFrameContainer.Flash:SetTexCoord(0.07, 0.854, 0.01, 0.16)

    FocusFrameToT.FrameTexture:SetTexture(Media:Fetch("frames", "smalltarget"))
    FocusFrameToT.FrameTexture:SetTexCoord(0.01, 0.94, 0.02, 0.765)

    -- Pet
    PetFrameTexture:SetTexture(Media:Fetch("frames", "smalltarget"))
    PetFrameTexture:SetTexCoord(0.01, 0.94, 0.02, 0.765)
    PetFrameFlash:SetTexture(Media:Fetch("misc", "player-status-flash"))
    PetFrameFlash:SetTexCoord(0.86, 0.103, 0.004, 0.166)

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

function General:SetLightTexture(value)
    for key, data in pairs(Media:HashTable("frames")) do
        if (value) then
            Media:HashTable("frames")[key] = data .. "-Light"
        else
            if (string.find(data, "-Light", -7)) then
                Media:HashTable("frames")[key] = string.sub(data, 0, -7)
            end
        end
    end

    self:SetTexture()
end

function General:UpdateFrames()
    local frames = {
        TargetFrame,
        FocusFrame
    }

    for _, frame in pairs(frames) do
        frame:UpdateAuras()
    end
end

function General:SetCustomBuffSize(value)

    self:UpdateFrames()


--    for _, frame in pairs(frames) do
--        local LARGE_AURA_SIZE = db.general.selfBuffSize
--        local SMALL_AURA_SIZE = db.general.buffSize
--
--        local buffSize = DEFAULT_BUFF_SIZE
--        local frameName
--        local icon
--        local caster
--        local _
--        local selfName = frame:GetName()
--
----        if (frame.unit == 'target') then
----            buffSize = DEFAULT_BUFF_SIZE * db.target.scaleFrame
----        end
--
----        if (frame.unit == 'focus') then
----            buffSize = DEFAULT_BUFF_SIZE * db.focus.scaleFrame
----        end
--
--        for i = 1, MAX_TARGET_BUFFS do
--            _, icon, _, _, _, _, caster = UnitBuff(frame.unit, i)
--            frameName = selfName .. 'Buff' .. i
--
--            if (icon and (not frame.maxBuffs or i <= frame.maxBuffs)) then
--                if (value) then
--                    if (caster == 'player') then
--                        buffSize = LARGE_AURA_SIZE
--                    else
--                        buffSize = SMALL_AURA_SIZE
--                    end
--                end
--
--                _G[frameName]:SetHeight(buffSize)
--                _G[frameName]:SetWidth(buffSize)
--            end
--        end
--    end
end

local function ShouldAuraBeLarge(caster)
    if not caster then
        return false;
    end

    for token, value in pairs(PLAYER_UNITS) do
        if UnitIsUnit(caster, token) or UnitIsOwnerOrControllerOfUnit(token, caster) then
            return value;
        end
    end
end

function General:MakeCustomBuffSize(selfFrame, auraList, numAuras, numOppositeAuras, setupFunc, anchorFunc, maxRowWidth, offsetX, mirrorAurasVertically)
    local LARGE_AURA_SIZE = db.general.selfBuffSize
    local SMALL_AURA_SIZE = db.general.buffSize
    local maxRowWidth = AURA_ROW_WIDTH

    -- Position auras
    local size;
    local offsetY = AURA_OFFSET_Y;
    -- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
    local rowWidth = 0;
    local i = 0;
    local firstIndexOnRow = 1;
    local firstBuffOnRow;
    local lastBuff;


    auraList:Iterate(function(auraInstanceID, aura)
        i = i + 1;
        if i > numAuras then
            return true;
        end
        local template = aura.isHarmful and "TargetDebuffFrameTemplate" or "TargetBuffFrameTemplate";
        local pool = selfFrame.auraPools:GetPool(template);
        local frame = pool:Acquire();
        setupFunc(frame, aura);

        -- update size and offset info based on large aura status
        if ShouldAuraBeLarge(aura.sourceUnit) then
            size = LARGE_AURA_SIZE;
            offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
        else
            size = SMALL_AURA_SIZE;
        end

        -- anchor the current aura
        if i == 1 then
            rowWidth = size;
            --selfFrame.auraRows = selfFrame.auraRows + 1;
            firstBuffOnRow = frame;
        else
            rowWidth = rowWidth + size + offsetX;
        end

        if rowWidth > maxRowWidth then
            -- this aura would cause the current row to exceed the max row width, so make this aura
            -- the start of a new row instead
            anchorFunc(selfFrame, frame, i, numOppositeAuras, firstBuffOnRow, firstIndexOnRow, size, offsetX, offsetY, mirrorAurasVertically);

            rowWidth = size;
            selfFrame.auraRows = selfFrame.auraRows + 1;
            firstIndexOnRow = i;
            firstBuffOnRow = frame;
            offsetY = AURA_OFFSET_Y;

            if ( selfFrame.auraRows > NUM_TOT_AURA_ROWS ) then
                -- if we exceed the number of tot rows, then reset the max row width
                -- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
                maxRowWidth = AURA_ROW_WIDTH;
            end
        else
            anchorFunc(selfFrame, frame, i, numOppositeAuras, lastBuff, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
        end

        lastBuff = frame;

        return false;
    end);

--    if (db.general.customBuffSize) then
--        local AURA_OFFSET = 3
--        local LARGE_AURA_SIZE = db.general.selfBuffSize
--        local SMALL_AURA_SIZE = db.general.buffSize
--        local size
--        local offsetY = AURA_OFFSET
--        local offsetX = AURA_OFFSET
--        local rowWidth = 0
--        local firstBuffOnRow = 1
--
--        for i = 1, numAuras do
--            if (largeAuraList[i]) then
--                size = LARGE_AURA_SIZE
--                offsetY = AURA_OFFSET
--                offsetX = AURA_OFFSET
--            else
--                size = SMALL_AURA_SIZE
--            end
--
--            if (i == 1) then
--                rowWidth = size
----                frame.auraRows = frame.auraRows + 1
--            else
--                rowWidth = rowWidth + size + offsetX
--            end
--
--            if (rowWidth > 121) then
--                updateFunc(frame, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically)
--                rowWidth = size
----                frame.auraRows = frame.auraRows + 1
--                firstBuffOnRow = i
--                offsetY = AURA_OFFSET
--            else
--                updateFunc(frame, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically)
--            end
--        end
--    end
end

function General:SetHighlightDispelledBuff()
    if (db.general.highlightDispelledBuff) then
        self:TargetFrame_UpdateAuras(TargetFrame)
    else
        self:TargetFrame_UpdateAuras(TargetFrame, true)
    end
end


function General:TargetFrameUpdateBuffAnchor(frame, buff, index, numDebuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
    --For mirroring vertically
    local point, relativePoint;
    local startY, auraOffsetY;
    if (mirrorVertically) then
        point = "BOTTOM";
        relativePoint = "TOP";
        startY = EasyFrames.Const.AURAR_MIRRORED_START_Y;
        if (frame.threatNumericIndicator:IsShown()) then
            startY = startY + frame.threatNumericIndicator:GetHeight();
        end
        offsetY = -offsetY;
        auraOffsetY = -AURA_OFFSET_Y;
    else
        point = "TOP";
        relativePoint = "BOTTOM";
        startY = AURA_START_Y;
        auraOffsetY = AURA_OFFSET_Y;
    end

    local targetFrameContentContextual = frame.TargetFrameContent.TargetFrameContentContextual;
    if (index == 1) then
        if (UnitIsFriend("player", frame.unit) or numDebuffs == 0) then
            -- unit is friendly or there are no debuffs...buffs start on top
            buff:SetPoint(point.."LEFT", frame.TargetFrameContainer.FrameTexture, relativePoint.."LEFT", AURA_START_X, startY);
        else
            -- unit is not friendly and we have debuffs...buffs start on bottom
            buff:SetPoint(point.."LEFT", targetFrameContentContextual.debuffs, relativePoint.."LEFT", 0, -offsetY);
        end
        targetFrameContentContextual.buffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
        targetFrameContentContextual.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
        --frame.spellbarAnchor = buff;
    elseif (anchorIndex ~= (index-1)) then
        -- anchor index is not the previous index...must be a new row
        buff:SetPoint(point.."LEFT", anchorBuff, relativePoint.."LEFT", 0, -offsetY);
        targetFrameContentContextual.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY); -- target Error
        --frame.spellbarAnchor = buff;
    else
        -- anchor index is the previous index
        buff:SetPoint(point.."LEFT", anchorBuff, point.."RIGHT", offsetX, 0);
    end

    -- Resize
    buff:SetWidth(size);
    buff:SetHeight(size);
end

function General:TargetFrameUpdateDebuffAnchor(frame, buff, index, numBuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
    local isFriend = UnitIsFriend("player", frame.unit);

    --For mirroring vertically
    local point, relativePoint;
    local startY, auraOffsetY;
    if (mirrorVertically) then
        point = "BOTTOM";
        relativePoint = "TOP";
        startY = EasyFrames.Const.AURAR_MIRRORED_START_Y;
        if (frame.threatNumericIndicator:IsShown()) then
            startY = startY + frame.threatNumericIndicator:GetHeight();
        end
        offsetY = - offsetY;
        auraOffsetY = -AURA_OFFSET_Y;
    else
        point = "TOP";
        relativePoint="BOTTOM";
        startY = AURA_START_Y;
        auraOffsetY = AURA_OFFSET_Y;
    end

    local targetFrameContentContextual = frame.TargetFrameContent.TargetFrameContentContextual;
    if (index == 1) then
        if (isFriend and numBuffs > 0) then
            -- unit is friendly and there are buffs...debuffs start on bottom
            buff:SetPoint(point.."LEFT", targetFrameContentContextual.buffs, relativePoint.."LEFT", 0, -offsetY);
        else
            -- unit is not friendly or there are no buffs...debuffs start on top
            buff:SetPoint(point.."LEFT", frame.TargetFrameContainer.FrameTexture, relativePoint.."LEFT", AURA_START_X, startY);
        end
        targetFrameContentContextual.debuffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
        targetFrameContentContextual.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
        if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
            --frame.spellbarAnchor = buff;
        end
    elseif (anchorIndex ~= (index-1)) then
        -- anchor index is not the previous index...must be a new row
        buff:SetPoint(point.."LEFT", anchorBuff, relativePoint.."LEFT", 0, -offsetY);
        targetFrameContentContextual.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
        if (( isFriend ) or ( not isFriend and numBuffs == 0)) then
            --frame.spellbarAnchor = buff;
        end
    else
        -- anchor index is the previous index
        buff:SetPoint(point.."LEFT", anchorBuff, point.."RIGHT", offsetX, 0);
    end

    -- Resize
    buff:SetWidth(size);
    buff:SetHeight(size);
    local debuffFrame = buff.Border;
    debuffFrame:SetWidth(size+2);
    debuffFrame:SetHeight(size+2);
end

function General:TargetFrame_UpdateAuras(frame, forceHide)
    local buffFrame, frameStealable, icon, debuffType, isStealable, _
    local selfName = frame:GetName()
    local isEnemy = UnitIsEnemy(PlayerFrame.unit, frame.unit)

    -- Debuffs on top
    if (frame.maxDebuffs > 0 and frame.buffsOnTop) then
        local _, firstDebuffIcon = UnitDebuff(frame.unit, 1)

        if (firstDebuffIcon) then
            local firstDebuffFrame = _G[selfName .. 'Debuff1']
            local point, relativeTo, relativePoint, xOffset, yOffset = firstDebuffFrame:GetPoint()

            firstDebuffFrame:ClearAllPoints()
            firstDebuffFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset + 8)
        end
    end

    for i = 1, MAX_TARGET_BUFFS do
        _, icon, _, debuffType, _, _, _, isStealable = UnitBuff(frame.unit, i)

        if (icon and (not frame.maxBuffs or i <= frame.maxBuffs)) then
            local frameName = selfName .. 'Buff' .. i

            buffFrame = _G[frameName]

            -- Buffs on top
            if (i == 1 and frame.buffsOnTop) then
                local point, relativeTo, relativePoint, xOffset, yOffset = buffFrame:GetPoint()

                buffFrame:ClearAllPoints()
                buffFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset + 8)
            end

            -- Stealable buffs
            if (db.general.highlightDispelledBuff or forceHide) then
                frameStealable = _G[frameName .. 'Stealable']

                local allCanSteal = true
                if (db.general.ifPlayerCanDispelBuff) then
                    allCanSteal = isStealable
                end

                if (isEnemy and debuffType == 'Magic' and allCanSteal and not forceHide) then
                    local buffSize

                    if (db.general.customBuffSize) then
                        buffSize = db.general.buffSize * db.general.dispelledBuffScale
                    else
                        buffSize = DEFAULT_BUFF_SIZE * db.general.dispelledBuffScale
                    end

                    buffFrame:SetHeight(buffSize)
                    buffFrame:SetWidth(buffSize)

                    frameStealable:Show()
                    frameStealable:SetHeight(buffSize * 1.4)
                    frameStealable:SetWidth(buffSize * 1.4)
                elseif (forceHide) then
                    frameStealable:Hide()
                end
            end
        end
    end
end

function General:SetMaxBuffCount(value)
    TargetFrame.maxBuffs = value
    FocusFrame.maxBuffs = value

    self:UpdateFrames()
end

function General:SetMaxDebuffCount(value)
    TargetFrame.maxDebuffs = value
    FocusFrame.maxDebuffs = value

    self:UpdateFrames()
end

function General:SaveFramesPoints()
    for _, frame in pairs({
        PlayerFrame,
        TargetFrame,
        FocusFrame
    }) do
        local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()

        db.general.framesPoints[frame.unit] = {
            point, relativeTo:GetName(), relativePoint, xOffset, yOffset
        }
    end
end

function General:RestoreFramesPoints()
    if (db.general.framesPoints) then
        for _, frame in pairs({
            PlayerFrame,
            TargetFrame,
            FocusFrame
        }) do
            frame:ClearAllPoints()
            frame:SetPoint(unpack(db.general.framesPoints[frame.unit]))
            --frame:SetUserPlaced(true)
            -- SetResizable(true)
        end
    end
end

function General:SetFramePoints(frame, x, y)
    local point, relativeTo, relativePoint = frame:GetPoint()

    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, x, y)
    frame:SetUserPlaced(true)
end
