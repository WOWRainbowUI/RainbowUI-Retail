--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonNarcissus
local M = KT:NewModule("AddonNarcissus")
KT.AddonNarcissus = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions(versionText)
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddAddonOption("addons", {
        addonNarcissus = {
            name = "Narcissus",
            desc = "版本："..versionText,
            descStyle = "inline",
            type = "toggle",
            width = 1.05,
            confirm = true,
            confirmText = KT.TEXT.OPTION_WARNING,
            disabled = function()
                return not C_AddOns.IsAddOnLoaded("Narcissus")
            end,
            set = function()
                db.addonNarcissus = not db.addonNarcissus
                ReloadUI()
            end,
            order = 5.1,
        },
        addonNarcissusDesc = {
            name = "從追蹤器中點擊成就時，於 Narcissus 視窗中開啟。",
            type = "description",
            width = "double",
            order = 5.2,
        }
    })
end

local function ToggleAchievementFrame()
    if Narci_AchievementFrame then
        Narci_AchievementFrame:SetShown(not Narci_AchievementFrame:IsShown())
    else
        Narci.LoadAchievementPanel()
    end
end

local function AttemptToOpenAchievement(achievementID, clickAgainToClose)
    if Narci_AchievementFrame then
        Narci_AchievementFrame:LocateAchievement(achievementID, clickAgainToClose)
    else
        Narci.LoadAchievementPanel(achievementID, clickAgainToClose)
    end
end

local function SetupAchievementsButton()
    if not KT.frame.AchievementsButton then return end

    KT.frame.AchievementsButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "CLICK Narci_Achievement_MinimapButton:LeftButton"), 1, 1, 1)
        GameTooltip:AddLine("透過 Narcissus", 0.57, 0.57, 0.57)
        GameTooltip:Show()
    end)
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00初始化|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00啟用|r - "..self:GetName(), true)
    local loaded, versionText = KT.CheckAddOn("Narcissus", "1.8.6")

    SetupOptions(versionText)
    if loaded and db.addonNarcissus then
        KT.OpenService_Override("achievements", ToggleAchievementFrame)
        KT.OpenService_Override("achievement", AttemptToOpenAchievement)

        KT:RegSignal("OPTIONS_CHANGED", SetupAchievementsButton, self)
    end
end