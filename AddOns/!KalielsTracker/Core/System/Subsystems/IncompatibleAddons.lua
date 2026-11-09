--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("IncompatibleAddons")

local incompatibleAddons = {
    ["UnlimitedMapPinDistance"] = true,
}
local detectedAddons = {}

local function IncompatibleAddons_Alert()
    if #detectedAddons == 0 then return end

    local addonList = ""
    for _, addon in ipairs(detectedAddons) do
        addonList = addonList.."- "..C_AddOns.GetAddOnMetadata(addon, "Title").."\n"
        KT.T_Set(addon, C_AddOns.GetAddOnMetadata(addon, "Version"), "incompatibleAddons")
    end

    KT.StaticPopup_Show("InfoWide", nil, "下列插件|cff00ffe3不相容|r，可能造成錯誤或不穩定行為：\n\n%s\n|cffff4200請停用不相容的插件或停用 %s。|r", addonList, KT.TITLE)

    wipe(detectedAddons)
end

local function IncompatibleAddons_Loaded(addon)
    if incompatibleAddons[addon] then
        tinsert(detectedAddons, addon)

        if KT.inWorld then
            IncompatibleAddons_Alert()
        end
    end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        IncompatibleAddons_Loaded(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        IncompatibleAddons_Alert()
        self:UnregisterEvent(event)
    end
end)
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")