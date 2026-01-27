--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2024 - James N. Whitehead II
-------------------------------------------------------------------]] ---

---@class addon
local addon = select(2, ...)
local L = addon.L

local libCatalog = addon.catalog
local libActions = addon.actionCatalog
local libSpellbook = addon.spellbookCatalog
local libMacros = addon.macroCatalog

---@class BindingConfig
local config = addon:GetBindingConfig()

-- Globals used in this file
local GetMouseFoci = GetMouseFoci
local GetMouseFocus = GetMouseFocus

function config:IsInMouseFocus(frame)
    if GetMouseFoci then
        for idx, focus in ipairs(GetMouseFoci()) do
            if focus == frame then
                return true
            end
        end
        return false
    else
        return GetMouseFocus() == frame
    end
end

-- Return a table that contains the action attributes for an entry
-- from the action catalog keyed by entryType and entryId
function config:GetActionAttributes(entryType, entryId)
    local draft = {}

    -- Now set the new attributes from the new entry
    if entryType == libCatalog.entryType.Spell then
        local spellName, texture = libSpellbook:GetSpellNameTexture(entryId)
        local spellSubName = libSpellbook:GetSpellSubName(entryId)

        if spellSubName == "" then
            spellSubName = nil
        end

        draft.type = "spell"
        draft.spell = spellName
        draft.spellSubName = spellSubName
        draft.icon = texture
    elseif entryType == libCatalog.entryType.Macro then
        local name, icon, body = libMacros:GetMacroNameIconBody(entryId)

        draft.type = "macro"
        draft.macro = name
        draft.icon = icon
    elseif entryType == libCatalog.entryType.Action then
        local name, icon, type, unit = libActions:GetNameIconTypeUnit(entryId)

        draft.type = type
        draft.icon = icon
        if unit then
            draft.unit = unit
        end
    end

    return draft
end

-- Remove the action information from a bind table
function config:RemoveActionFromBinding(bind)
    if bind.type == "target" then
        -- nothing extra to remove
    elseif bind.type == "menu" then
        -- nothing extra to remove
    elseif bind.type == "spell" then
        bind.spell = nil
        bind.spellSubName = nil
    elseif bind.type == "macro" then
        bind.macrotext = nil
        bind.macro = nil
    end

    bind.icon = nil
    bind.type = nil
    bind.unit = nil
end

-- Copy the action information from bind to dest
function config:CopyActionFromTo(bind, dest)
    if bind.type == "target" then
        -- nothing extra to copy
    elseif bind.type == "menu" then
        -- nothing extra to copy
    elseif bind.type == "spell" then
        dest.spell = bind.spell
        dest.spellSubName = bind.spellSubName
    elseif bind.type == "macro" then
        dest.macro = bind.macro
        dest.macrotext = bind.macrotext
    end

    dest.icon = bind.icon
    dest.type = bind.type
    dest.unit = bind.unit
end

function addon:DeleteBindingMouseFocus()
    local bind = GetMouseFocus().id
    bind.type = "spell"
    bind.spell = "Dash"
    addon:DeleteBinding(bind)

    local page = config:GetBrowsePage()
    page:UPDATE_BROWSE_PAGE()
end
