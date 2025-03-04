local _, Cell = ...
---@type CellFuncs
local F = Cell.funcs
---@class CellIndicatorFuncs
local I = Cell.iFuncs
---@type PixelPerfectFuncs
local P = Cell.pixelPerfectFuncs

CELL_SUMMON_ICONS_ENABLED = false

-------------------------------------------------
-- event
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, unit)
    F.HandleUnitButton("unit", unit, I.UpdateStatusIcon)
end)

local function DiedWithSoulstone(b)
    b.states.hasSoulstone = true
    I.UpdateStatusIcon(b)
end

local rez = {}
local soulstones = {}
local SOULSTONE = F.GetSpellInfo(20707)
local RESURRECTING = F.GetSpellInfo(160029)

local cleuFrame = CreateFrame("Frame")
cleuFrame:SetScript("OnEvent", function()
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_AURA_REMOVED" then
        if spellName == SOULSTONE then
            -- print("soulstone removed", timestamp, destName)
            soulstones[destGUID] = timestamp
            C_Timer.After(0.1, function()
                soulstones[destGUID] = nil
            end)
        elseif spellName == RESURRECTING then
            rez[destGUID] = nil
            F.HandleUnitButton("guid", destGUID, I.UpdateStatusIcon_Resurrection)
        end
    elseif subEvent == "UNIT_DIED" then
        -- print("died", timestamp, destName)
        if soulstones[destGUID] then
            F.HandleUnitButton("guid", destGUID, DiedWithSoulstone)
        end
        soulstones[destGUID] = nil
    elseif subEvent == "SPELL_RESURRECT" then
        local start, duration = GetTime(), 60
        rez[destGUID] = {start, duration}

        F.HandleUnitButton("guid", destGUID, I.UpdateStatusIcon_Resurrection, start, duration)
    end
end)

-------------------------------------------------
-- create
-------------------------------------------------
function I.CreateStatusIcon(parent)
    local statusIcon = CreateFrame("Frame", parent:GetName().."StatusIcon", parent.widgets.indicatorFrame)
    parent.indicators.statusIcon = statusIcon
    statusIcon:Hide()

    statusIcon:SetIgnoreParentAlpha(true)

    statusIcon.tex = statusIcon:CreateTexture(nil, "OVERLAY")
    statusIcon.tex:SetAllPoints(statusIcon)

    function statusIcon:SetTexture(tex)
        statusIcon.tex:SetTexture(tex)
    end

    function statusIcon:SetTexCoord(...)
        statusIcon.tex:SetTexCoord(...)
    end

    function statusIcon:SetAtlas(...)
        statusIcon.tex:SetAtlas(...)
    end

    function statusIcon:SetVertexColor(...)
        statusIcon.tex:SetVertexColor(...)
    end

    -- resurrection icon ----------------------------------
    local resurrectionIcon = CreateFrame("Frame", parent:GetName().."ResurrectionIcon", parent.widgets.indicatorFrame)
    parent.indicators.resurrectionIcon = resurrectionIcon
    resurrectionIcon:SetAllPoints(statusIcon)
    resurrectionIcon:Hide()

    resurrectionIcon.tex = resurrectionIcon:CreateTexture(nil, "ARTWORK")
    resurrectionIcon.tex:SetAllPoints(resurrectionIcon)
    resurrectionIcon.tex:SetDesaturated(true)
    resurrectionIcon.tex:SetVertexColor(0.4, 0.4, 0.4, 0.5)
    resurrectionIcon.tex:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")

    local bar = CreateFrame("StatusBar", nil, resurrectionIcon)
    bar:SetAllPoints(resurrectionIcon)
    bar:SetOrientation("VERTICAL")
    bar:SetReverseFill(true)
    bar:SetStatusBarTexture(Cell.vars.whiteTexture)
    bar:GetStatusBarTexture():SetAlpha(0)
    bar.elapsedTime = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        if bar.elapsedTime >= 0.25 then
            bar:SetValue(bar:GetValue() + bar.elapsedTime)
            bar.elapsedTime = 0
        end
        bar.elapsedTime = bar.elapsedTime + elapsed
    end)

    local mask = resurrectionIcon:CreateMaskTexture()
    mask:SetTexture(Cell.vars.whiteTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "BOTTOMLEFT")
    mask:SetPoint("BOTTOMRIGHT")

    local maskIcon = bar:CreateTexture(nil, "ARTWORK")
    maskIcon:SetAllPoints(resurrectionIcon)
    maskIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
    maskIcon:AddMaskTexture(mask)

    function resurrectionIcon:SetTimer(start, duration)
        resurrectionIcon:Hide() -- pause OnUpdate
        bar:SetMinMaxValues(0, duration + 13) -- NOTE: texture gap (texcoord 0,1,0,1)
        bar:SetValue(GetTime()-start)
        resurrectionIcon:Show()
    end

    resurrectionIcon:SetScript("OnHide", function()
        if resurrectionIcon.timer then
            resurrectionIcon.timer:Cancel()
            resurrectionIcon.timer = nil
        end
    end)
    -------------------------------------------------------

    statusIcon._SetFrameLevel = statusIcon.SetFrameLevel
    function statusIcon:SetFrameLevel(level)
        statusIcon:_SetFrameLevel(level)
        resurrectionIcon:SetFrameLevel(level)
    end
end

-------------------------------------------------
-- resurrection
-------------------------------------------------
function I.UpdateStatusIcon_Resurrection(button, start, duration)
    local guid = button.states.guid
    local unit = button.states.unit
    local resurrectionIcon = button.indicators.resurrectionIcon

    if not (guid and unit) then
        resurrectionIcon:Hide()
        return
    end

    if not start then
        local dur, expir = select(5, F.FindAuraById(unit, "DEBUFF", 160029)) -- battle res
        if dur then --! check Resurrecting debuff
            start = expir - dur
            duration = dur
        elseif rez[guid] then --! check saved data (unit button changed)
            start = rez[guid][1]
            duration = rez[guid][2]
        else
            resurrectionIcon:Hide()
            return
        end
    end

    --! alive or expired
    if not UnitIsDeadOrGhost(unit) or start + duration <= GetTime() then
        rez[guid] = nil
        resurrectionIcon:Hide()
        return
    end

    resurrectionIcon:SetTimer(start, duration)
    -- timer
    if resurrectionIcon.timer then resurrectionIcon.timer:Cancel() end
    resurrectionIcon.timer = C_Timer.NewTimer(start + duration - GetTime(), function()
        rez[guid] = nil
        resurrectionIcon:Hide()
    end)
end

-------------------------------------------------
-- update (UnitButton_UpdateAuras)
-------------------------------------------------
if Cell.isRetail then
    function I.UpdateStatusIcon(button)
        local unit = button.states.unit
        if not unit then return end

        -- https://wow.gamepedia.com/API_UnitPhaseReason
        local phaseReason = UnitPhaseReason(unit)

        local icon = button.indicators.statusIcon

        -- Interface\FrameXML\CompactUnitFrame.lua, CompactUnitFrame_UpdateCenterStatusIcon
        if UnitInOtherParty(unit) then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            -- icon:SetTexCoord(0.125, 0.25, 0.25, 0.5)
            -- icon:SetTexCoord(0.145, 0.23, 0.29, 0.46)
            icon:SetTexCoord(0.14, 0.235, 0.28, 0.47)
            icon:Show()
        elseif UnitHasIncomingResurrection(unit) then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        elseif button.states.hasRezDebuff then
            icon:SetVertexColor(0.6, 1, 0.6, 1)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        elseif button.states.hasSoulstone then
            icon:SetVertexColor(1, 0.4, 1, 1)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        elseif CELL_SUMMON_ICONS_ENABLED and C_IncomingSummon.HasIncomingSummon(unit) then
            local status = C_IncomingSummon.IncomingSummonStatus(unit)
            if status == Enum.SummonStatus.Pending then
                icon:SetAtlas("Raid-Icon-SummonPending")
                icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
            elseif status == Enum.SummonStatus.Accepted then
                icon:SetAtlas("Raid-Icon-SummonAccepted")
                icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
                C_Timer.After(6, function() I.UpdateStatusIcon(button) end)
            elseif status == Enum.SummonStatus.Declined then
                icon:SetAtlas("Raid-Icon-SummonDeclined")
                icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
                C_Timer.After(6, function() I.UpdateStatusIcon(button) end)
            end
            icon:Show()
        elseif UnitIsPlayer(unit) and phaseReason and not button.states.inVehicle then
            if phaseReason == 3 then -- chromie, yellow
                icon:SetVertexColor(1, 1, 0)
            elseif phaseReason == 2 then -- warmode, red
                icon:SetVertexColor(1, 0.6, 0.6)
            elseif phaseReason == 1 then -- sharding, green
                icon:SetVertexColor(0.5, 1, 0.5)
            else -- 0, phasing
                icon:SetVertexColor(1, 1, 1)
            end
            icon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:Show()
        -- elseif UnitIsDeadOrGhost(unit) then
        --     icon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
        --     icon:SetTexCoord(0, 1, 0, 1)
        --     icon:Show()
        elseif button.states.BGFlag then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetAtlas("nameplates-icon-flag-"..button.states.BGFlag)
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        elseif button.states.BGOrb then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetAtlas("nameplates-icon-orb-"..button.states.BGOrb)
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        else
            icon:Hide()
        end
    end
else
    function I.UpdateStatusIcon(button)
        local unit = button.states.unit
        if not unit then return end

        local icon = button.indicators.statusIcon

        -- Interface\FrameXML\CompactUnitFrame.lua, CompactUnitFrame_UpdateCenterStatusIcon
        if UnitInOtherParty(unit) then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            icon:SetTexCoord(0.14, 0.235, 0.28, 0.47)
            icon:Show()
        elseif UnitHasIncomingResurrection(unit) then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        elseif button.states.hasRezDebuff or button.states.hasSoulstone then
            icon:SetVertexColor(0.6, 1, 0.6, 1)
            icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            icon:SetTexCoord(0, 1, 0, 1)
            icon:Show()
        elseif UnitIsPlayer(unit) and UnitIsConnected(unit) and not UnitInPhase(unit) and not button.states.inVehicle then
            icon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:Show()
        -- elseif UnitIsDeadOrGhost(unit) then
        --     icon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
        --     icon:SetTexCoord(0, 1, 0, 1)
        --     icon:Show()
        elseif button.states.BGFlag then
            icon:SetVertexColor(1, 1, 1, 1)
            icon:SetAtlas(button.states.BGFlag.."_icon_and_flag-dynamicIcon")
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:Show()
        else
            icon:Hide()
        end
    end
end

-------------------------------------------------
-- enable
-------------------------------------------------
function I.EnableStatusIcon(enabled)
    if enabled then
        eventFrame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
        eventFrame:RegisterEvent("UNIT_PHASE")
        eventFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
        eventFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
        if Cell.isRetail and CELL_SUMMON_ICONS_ENABLED then
            eventFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
        end
        -- resurrection
        cleuFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        eventFrame:UnregisterAllEvents()
        cleuFrame:UnregisterAllEvents()
        F.IterateAllUnitButtons(function(b)
            b.indicators.statusIcon:Hide()
            b.indicators.resurrectionIcon:Hide()
        end)
    end
end