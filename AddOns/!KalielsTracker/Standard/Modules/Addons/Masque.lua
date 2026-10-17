--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonMasque
local M = KT:NewModule("AddonMasque")
KT.AddonMasque = M

local MSQ = LibStub("Masque", true)
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db
local msqGroup = {}

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions(versionText)
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddAddonOption("addons", {
        addonMasque = {
            name = "Masque",
            desc = "Version: "..versionText,
            descStyle = "inline",
            type = "toggle",
            width = 1.05,
            confirm = true,
            confirmText = KT.TEXT.OPTION_WARNING,
            disabled = function()
                return not C_AddOns.IsAddOnLoaded("Masque")
            end,
            set = function()
                db.addonMasque = not db.addonMasque
                ReloadUI()
            end,
            order = 4.1,
        },
        addonMasqueDesc = {
            name = "Enables skinning of Quest Item buttons and the Active Button.",
            type = "description",
            width = "double",
            order = 4.2,
        }
    })
end

local function Masque_SetButtonStyle(button, state)
    if button.Style then
        button.Style:SetAlpha(state and 1 or 0)
    end
end

local function Masque_Callback(self, option, value)
    if option == "Disabled" then
        for button in pairs(self.Buttons) do
            Masque_SetButtonStyle(button, value)
        end
    end
end

local function Masque_Init()
    msqGroup[1] = MSQ:Group(KT.TITLE, "Quest Item Buttons")
    if KT:Addon_IsModule(KT.ActiveButton) then
        msqGroup[2] = MSQ:Group(KT.TITLE, "Quest Active Button")
        msqGroup[2]:RegisterCallback(Masque_Callback)
    end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:IsActive()
    return C_AddOns.IsAddOnLoaded("Masque") and db.addonMasque
end

function M:AddButton(button, groupID)
    if not self:IsActive() then return end

    local group = msqGroup[groupID]
    group:AddButton(button)
    Masque_SetButtonStyle(button, group.db.Disabled)
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    local loaded, versionText = KT.CheckAddOn("Masque", "12.1.0")

    SetupOptions(versionText)
    if loaded and db.addonMasque then
        KT:Alert_IncompatibleAddon("Masque", "11.0.1")

        Masque_Init()
    end
end