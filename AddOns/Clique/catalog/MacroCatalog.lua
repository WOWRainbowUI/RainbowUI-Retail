--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2024 - James N. Whitehead II

This file contains an abstraction of the spellbook APIs, ensuring that
Clique has a common interface between different versions of WoW.
-------------------------------------------------------------------]] ---

---@class addon
local addon = select(2, ...)
addon.macroCatalog = {}

local lib = addon.macroCatalog
local catalog = addon.catalog

local MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS

function lib:GetMacroCatalogEntries(orderIndex)
    local results = {}

    local numGlobalMacros, numPlayerMacros = GetNumMacros()


    for idx = 1, numGlobalMacros do
        orderIndex = orderIndex + 1
        local name, icon, body = GetMacroInfo(idx)
        results[#results+1] = catalog:CreateEntry(
            catalog.entryType.Macro,
            orderIndex,
            name,
            icon,
            idx,
            false,
            false,
            true,
            false
        )
    end

    for idx = MAX_ACCOUNT_MACROS + 1, MAX_ACCOUNT_MACROS + numPlayerMacros do
        orderIndex = orderIndex + 1
        local name, icon, body = GetMacroInfo(idx)
        results[#results+1] = catalog:CreateEntry(
            catalog.entryType.Macro,
            orderIndex,
            name,
            icon,
            idx,
            false,
            false,
            false,
            true
        )
    end

    return results
end

function lib:GetMacroNameIconBody(idx)
    local name, icon, body = GetMacroInfo(idx)
    return name, icon, body
end

function lib:MacroExistsByName(name)
    local name, icon, body = GetMacroInfo(name)
    if name then
        return true
    end
end

function lib:IsAccountMacroIndex(idx)
    if idx < MAX_ACCOUNT_MACROS then
        return true
    end

    return false
end

