--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Profession
local M = KT:NewModule("Profession")
KT.Profession = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    KT_ProfessionsRecipeTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "TRACKED_RECIPE_UPDATE" then
            local _, added = ...
            if added then
                KT:Module_Expand(self)
            end
        end
    end)

    function KT_ProfessionsRecipeTracker:OnBlockHeaderEnter(block)
        if db.tooltipShow then
            KT.GameTooltip_SetPosition(block)

            local recipeID = KT.GetRecipeID(block)
            GameTooltip:SetRecipeResultItem(recipeID)

            if db.tooltipShowID then
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..recipeID)
            end

            GameTooltip:Show()
        end
    end

    local function OnOpenDropDown(self)
        local block = self.activeFrame
        local recipeID = KT.GetRecipeID(block)

        local info = KT.Menu_CreateInfo()
        KT.Menu_AddTitle(C_Spell.GetSpellName(recipeID))

        local spellBank = Enum.SpellBookSpellBank.Player
        local includeOverrides = false
        if not KT.IsRecraftBlock(block) and C_SpellBook.IsSpellInSpellBook(recipeID, spellBank, includeOverrides) then
            KT.Menu_AddButton(PROFESSIONS_TRACKING_VIEW_RECIPE, function()
                KT.OpenService_Open("profession", recipeID)
            end)
        end

        KT.Menu_AddButton(PROFESSIONS_UNTRACK_RECIPE, function()
            C_TradeSkillUI.SetRecipeTracked(recipeID, false, KT.IsRecraftBlock(block))
        end)

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "spell", recipeID)
    end

    function KT_ProfessionsRecipeTracker:OnBlockHeaderClick(block, mouseButton)  -- R
        local recipeID = KT.GetRecipeID(block)
        if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
            local link = C_TradeSkillUI.GetRecipeLink(recipeID);
            if link then
                ChatFrameUtil.InsertLink(link);
            end
        elseif mouseButton ~= "RightButton" then
            if not ProfessionsFrame then
                ProfessionsFrame_LoadUI();
            end
            if IsModifiedClick("RECIPEWATCHTOGGLE") then
                local track = false;
                C_TradeSkillUI.SetRecipeTracked(recipeID, track, KT.IsRecraftBlock(block));
            elseif IsModifiedClick(db.menuWowheadURLModifier) then
                KT:Alert_WowheadURL("spell", recipeID)
            else
                if not KT.IsRecraftBlock(block) then
                    KT.OpenService_Open("profession", recipeID)
                end
            end
        else
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetHooks()
end