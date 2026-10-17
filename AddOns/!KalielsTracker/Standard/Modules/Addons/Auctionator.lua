--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonAuctionator
local M = KT:NewModule("AddonAuctionator")
KT.AddonAuctionator = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions(versionText)
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddAddonOption("addons", {
        addonAuctionator = {
            name = "Auctionator",
            desc = "Version: "..versionText,
            descStyle = "inline",
            type = "toggle",
            width = 1.05,
            confirm = true,
            confirmText = KT.TEXT.OPTION_WARNING,
            disabled = function()
                return not C_AddOns.IsAddOnLoaded("Auctionator")
            end,
            set = function()
                db.addonAuctionator = not db.addonAuctionator
                ReloadUI()
            end,
            order = 1.1,
        },
        addonAuctionatorDesc = {
            name = "Enables an Auctionator search button inside the Profession module header.",
            type = "description",
            width = "double",
            order = 1.2,
        }
    })
end

local function SetHooks()
    hooksecurefunc(Auctionator.CraftingInfo, "InitializeObjectiveTrackerFrame", function()
        local searchFrame = AuctionatorCraftingInfoObjectiveTrackerFrame
        searchFrame:SetParent(KT_ProfessionsRecipeTracker.Header)
        searchFrame:ClearAllPoints()
        searchFrame:SetPoint("TOPRIGHT")
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
    local loaded, versionText = KT.CheckAddOn("Auctionator", "341")

    SetupOptions(versionText)
    if loaded and db.addonAuctionator then
        SetHooks()
    end
end