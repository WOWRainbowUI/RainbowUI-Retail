--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonBtWQuests
local M = KT:NewModule("AddonBtWQuests")
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
            confirm = true,
            confirmText = KT.TEXT.OPTION_WARNING,
            disabled = function()
                return not C_AddOns.IsAddOnLoaded("BtWQuests")
            end,
            set = function()
                db.addonBtWQuests = not db.addonBtWQuests
                ReloadUI()
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
            BtWQuestsFrame:SelectCharacter(UnitName("player"), GetRealmName())
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
    local loaded, versionText = KT.CheckAddOn("BtWQuests", "v2.65.0")

    SetupOptions(versionText)
    if loaded and db.addonBtWQuests then
        KT:RegSignal("CONTEXT_MENU_UPDATE", ContextMenu_Extend, self)
    end
end