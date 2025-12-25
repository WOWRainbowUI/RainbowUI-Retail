--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("AddonCompartment")

local function Compartment_OnClick(data, menuInputData, menu)
    if menuInputData.buttonName == "LeftButton" then
        KT:SetHidden()
    elseif menuInputData.buttonName == "RightButton" then
        KT:OpenOptions()
    end
end

local function Compartment_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, 7)
    GameTooltip:AddLine(KT.TITLE)
    GameTooltip:AddLine("左鍵 - 顯示/隱藏追蹤清單", 1, 1, 1)
    GameTooltip:AddLine("右鍵 - 打開設定選項", 1, 1, 1)
    GameTooltip:Show()
end

local function Compartment_OnLeave(self)
    GameTooltip:Hide()
end

function SS:Init()
    local data = {
        text = KT.TITLE,
        icon = KT.MEDIA_PATH.."KT_logo",
        notCheckable = true,
        registerForAnyClick = true,
        func = Compartment_OnClick,
        funcOnEnter = Compartment_OnEnter,
        funcOnLeave = Compartment_OnLeave
    }
    AddonCompartmentFrame:RegisterAddon(data)
end