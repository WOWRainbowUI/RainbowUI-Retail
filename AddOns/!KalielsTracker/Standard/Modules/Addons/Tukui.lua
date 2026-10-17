--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonTukui
local M = KT:NewModule("AddonTukui")
KT.AddonTukui = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions(loaded, versionText)
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddAddonOption("uis", {
        tukui = {
            name = "Tukui"..(loaded and " - "..versionText or ""),
            type = "toggle",
            disabled = function() return not loaded end,
            get = function() return loaded end,
            order = 2,
        }
    })
end

local function Tukui_Init()
    local T = unpack(_G.Tukui)

    T.Miscellaneous.ObjectiveTracker.Enable = function() end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00初始化|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00啟用|r - "..self:GetName(), true)
    local loaded, versionText = KT.CheckAddOn("Tukui", "v20.463")

    SetupOptions(loaded, versionText)
    if loaded then
        Tukui_Init()
    end
end