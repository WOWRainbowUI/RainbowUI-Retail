--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local LSM = LibStub("LibSharedMedia-3.0")

local SS = KT:NewSubsystem("ProgressBar")

local db
local FORMAT_OPTIONS = { "39.58%", "39.58% (60.42%)", "95 / 240", "95 / 240 (145)", "39.58% - 95 / 240", "95 / 240 - 39.58%", "39.58% (60.42%) - 95 / 240 (145)", "95 / 240 (145) - 39.58% (60.42%)" }

function KT.ProgressBar_SetStyle(block, progressBar, xOffsetMod)
    if progressBar.KTskinID ~= KT.skinID then
        block.height = block.height - progressBar.height

        progressBar:SetSize(240, 21)
        progressBar.height = 21

        local xOffset = KT.dashWidth + 2
        progressBar.Bar:SetSize(205 - xOffset, 13)
        progressBar.Bar:EnableMouse(false)
        progressBar.Bar:ClearAllPoints()

        if progressBar.Bar.BarFrame then
            -- World Quest / Scenario
            xOffsetMod = xOffsetMod or 0
            progressBar.Bar:SetPoint("LEFT", xOffset + xOffsetMod, 0)
            progressBar.Bar.BarFrame:Hide()
            progressBar.Bar.BarFrame2:Hide()
            progressBar.Bar.BarFrame3:Hide()
            progressBar.Bar.BarGlow:Hide()
            progressBar.Bar.Sheen:Hide()
            progressBar.Bar.Starburst:Hide()
        else
            -- Default
            progressBar.Bar:SetPoint("LEFT", xOffset, 0)
            progressBar.Bar.BorderLeft:Hide()
            progressBar.Bar.BorderRight:Hide()
            progressBar.Bar.BorderMid:Hide()
        end

        local border1 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -2)
        border1:SetPoint("TOPLEFT", -1, 1)
        border1:SetPoint("BOTTOMRIGHT", 1, -1)
        border1:SetColorTexture(0, 0, 0)

        local border2 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -3)
        border2:SetPoint("TOPLEFT", -2, 2)
        border2:SetPoint("BOTTOMRIGHT", 2, -2)
        border2:SetColorTexture(0.4, 0.4, 0.4)

        progressBar.Bar.Label:SetPoint("CENTER", 0, 0.5)
        progressBar.Bar.Label:SetFont(LSM:Fetch("font", "Arial Narrow"), 13, "")
        progressBar.Bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
        progressBar.KTskinID = KT.skinID
        progressBar.isSkinned = true  -- ElvUI hack

        block.height = block.height + progressBar.height
    end
end

function KT.ProgressBar_SetValue(block, progressBar, id)
    if block.parentModule ~= KT_ScenarioObjectiveTracker then return end

    local scenarioType = select(10, C_Scenario.GetInfo())
    if scenarioType ~= LE_SCENARIO_TYPE_CHALLENGE_MODE then return end

    local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(id)
    if criteriaInfo then
        local quantity = criteriaInfo.quantityString and tonumber(criteriaInfo.quantityString:match("%d+"))
        local totalQuantity = criteriaInfo.totalQuantity
        if quantity and totalQuantity then
            if db.scenarioEnemyForcesFormat == 1 then
                progressBar.Bar.Label:SetFormattedText("%.2f%%", quantity / totalQuantity * 100)
            elseif db.scenarioEnemyForcesFormat == 2 then
                progressBar.Bar.Label:SetFormattedText("%.2f%% (%.2f%%)", quantity / totalQuantity * 100, (totalQuantity - quantity) / totalQuantity * 100)
            elseif db.scenarioEnemyForcesFormat == 3 then
                progressBar.Bar.Label:SetFormattedText("%d / %d", quantity, totalQuantity)
            elseif db.scenarioEnemyForcesFormat == 4 then
                progressBar.Bar.Label:SetFormattedText("%d / %d (%d)", quantity, totalQuantity, totalQuantity - quantity)
            elseif db.scenarioEnemyForcesFormat == 5 then
                progressBar.Bar.Label:SetFormattedText("%.2f%% - %d / %d", quantity / totalQuantity * 100, quantity, totalQuantity)
            elseif db.scenarioEnemyForcesFormat == 6 then
                progressBar.Bar.Label:SetFormattedText("%d / %d - %.2f%%", quantity, totalQuantity, quantity / totalQuantity * 100)
            elseif db.scenarioEnemyForcesFormat == 7 then
                progressBar.Bar.Label:SetFormattedText("%.2f%% (%.2f%%) - %d / %d (%d)", quantity / totalQuantity * 100, (totalQuantity - quantity) / totalQuantity * 100, quantity, totalQuantity, totalQuantity - quantity)
            elseif db.scenarioEnemyForcesFormat == 8 then
                progressBar.Bar.Label:SetFormattedText("%d / %d (%d) - %.2f%% (%.2f%%)", quantity, totalQuantity, totalQuantity - quantity, quantity / totalQuantity * 100, (totalQuantity - quantity) / totalQuantity * 100)
            end
        end
    end
end

function KT.ProgressBar_GetFormatOptions()
    return FORMAT_OPTIONS
end

function SS:Init()
    db = KT.db.profile
end