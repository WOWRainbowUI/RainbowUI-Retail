--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class AddonElvUI
local M = KT:NewModule("AddonElvUI")
KT.AddonElvUI = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions(loaded, versionText)
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddAddonOption("uis", {
        elvui = {
            name = "ElvUI"..(loaded and " - "..versionText or ""),
            type = "toggle",
            disabled = function() return not loaded end,
            get = function() return loaded end,
            order = 1,
        }
    })
end

local function ElvUI_PatchOptions()
    KT:RegisterOptionsPatch("ElvUI", function(options)
        C_Timer.After(0, function()
            local target = options.args.general.args.blizzardImprovements.args.objectiveFrameGroup.args
            target[addonName.."Warning"] = {
                name = " "..KT.TEXT.ADDON_IS_ACTIVE_DISABLED,
                type = "description",
                order = 0,
            }
        end)
    end)
end

local function ElvUI_Init()
    local E = unpack(ElvUI)
    local B = E:GetModule("Blizzard")

    B.HandleObjectiveTracker = function() end

    if E.private.skins.blizzard.objectiveTracker then
        KT.StaticPopup_Show("ReloadUI", nil, "Activate changes for |cff00ffe3ElvUI|r.")
    end

    hooksecurefunc(E, "CheckIncompatible", function(self)
        self.private.skins.blizzard.objectiveTracker = false
    end)
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    local loaded, versionText = KT.CheckAddOn("ElvUI", "v16.00")

    SetupOptions(loaded, versionText)
    if loaded then
        ElvUI_Init()
        ElvUI_PatchOptions()
    end
end