--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonBtWQuests
local M = KT:NewModule("AddonBtWQuests")
M.COMPATIBLE_VERSION = "v2.69.0"
M.MIN_COMPATIBLE_VERSION = "v2.68.0"
KT.AddonBtWQuests = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions(versionText)
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddAddonOption("addons", {
        addonBtWQuests = {
            name = "BtWQuests",
            desc = "Version: "..versionText,
            descStyle = "inline",
            type = "toggle",
            width = 1.05,
            disabled = function()
                return not C_AddOns.IsAddOnLoaded("BtWQuests")
            end,
            order = 3.1,
        },
        addonBtWQuestsDesc = {
            name = "Enables an \"Open Quest Chain\" option in the Quest context menu.",
            type = "description",
            width = "double",
            order = 3.2,
        }
    })
end

local function ContextMenu_Extend(_, info, type, questID)
    if type ~= "quest" then return end

    local item = BtWQuestsDatabase:GetQuestItem(questID, BtWQuestsCharacters:GetPlayer())
    if item then
        if not info.KTmenuExtended then
            KT.Menu_AddSeparator()
            info.KTmenuExtended = true
        end

        KT.Menu_AddButton("|cff33ff99BtWQ|r - "..BtWQuests.L["BTWQUESTS_OPEN_QUEST_CHAIN"], function()
            local name, surname = UnitName("player")
            if KT.IS_WOW_FOREVER then
                name = name.." "..surname
            end
            BtWQuestsFrame:SelectCharacter(name, GetRealmName())

            BtWQuestsFrame:SelectItem(item.item)
            BtWQuestsFrame:SelectItem(item.item)
        end)
    end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    local loaded, versionText = KT.CheckAddOn("BtWQuests", self.COMPATIBLE_VERSION)

    SetupOptions(versionText)
    if loaded and db.addonBtWQuests then
        KT:Alert_IncompatibleAddon("BtWQuests", self.MIN_COMPATIBLE_VERSION)

        KT:RegSignal("CONTEXT_MENU_UPDATE:10", ContextMenu_Extend, self)
    end
end