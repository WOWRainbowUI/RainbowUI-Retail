--[[
    RGX-Framework - Cross-Version Compatibility Layer
    
    Provides API shims and version detection for WoW Classic Era, TBC, Wrath,
    Cataclysm, MoP, and Retail.
]]

local addonName, RGX = ...

-- Version detection
local function GetWoWVersion()
    local projectID = WOW_PROJECT_ID
    if projectID == WOW_PROJECT_CLASSIC then return "classic_era" end
    if projectID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return "tbc" end
    if projectID == WOW_PROJECT_WRATH_CLASSIC then return "wrath" end
    if projectID == WOW_PROJECT_CATACLYSM_CLASSIC then return "cata" end
    if projectID == WOW_PROJECT_MISTS_CLASSIC then return "mists" end
    if projectID == WOW_PROJECT_MAINLINE then return "retail" end
    return "unknown"
end

RGX.wowVersion = GetWoWVersion()
RGX.isRetail = (RGX.wowVersion == "retail")
RGX.isClassic = (RGX.wowVersion ~= "retail")
RGX.isClassicEra = (RGX.wowVersion == "classic_era")
RGX.isTBC = (RGX.wowVersion == "tbc")
RGX.isWrath = (RGX.wowVersion == "wrath")
RGX.isCata = (RGX.wowVersion == "cata")
RGX.isMists = (RGX.wowVersion == "mists")

-- API shims for Classic (Retail APIs that don't exist on Classic)
if not C_AddOns then
    C_AddOns = {}
    C_AddOns.GetAddOnMetadata = GetAddOnMetadata
    C_AddOns.LoadAddOn = LoadAddOn
    C_AddOns.IsAddOnLoaded = IsAddOnLoaded
end

if not C_QuestLog then
    C_QuestLog = {}
    -- Classic uses GetQuestLogTitle, GetNumQuestLogEntries, etc.
end

if not C_TaskQuest then
    C_TaskQuest = {}
    -- Classic doesn't have C_TaskQuest
end

if not C_NamePlate then
    C_NamePlate = {}
    -- Classic has NamePlate API but different
end

if not C_UnitAuras then
    C_UnitAuras = {}
    -- Classic uses UnitAura
end

if not C_Spell then
    C_Spell = {}
    -- Classic uses GetSpellInfo
end

if not C_Item then
    C_Item = {}
    -- Classic uses GetItemInfo
end

if not C_GossipInfo then
    C_GossipInfo = {}
    -- Classic uses GetGossipOptions
end

if not C_PerksProgram then
    C_PerksProgram = {}
    -- Classic doesn't have Trading Post
end

if not C_PlayerInfo then
    C_PlayerInfo = {}
    -- Classic may not have IsTravelersLogAvailable
end

if not C_CurrencyInfo then
    C_CurrencyInfo = {}
end

if not C_SpellBook then
    C_SpellBook = {}
end

-- Safe API wrappers (return nil if API doesn't exist)
RGX.API = {}

function RGX.API.GetAddOnMetadata(name, field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(name, field)
    end
    return GetAddOnMetadata and GetAddOnMetadata(name, field)
end

function RGX.API.LoadAddOn(name)
    if C_AddOns and C_AddOns.LoadAddOn then
        return C_AddOns.LoadAddOn(name)
    end
    return LoadAddOn and LoadAddOn(name)
end

function RGX.API.IsAddOnLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    end
    return IsAddOnLoaded and IsAddOnLoaded(name)
end

function RGX.API.GetQuestLogTitle(index)
    if C_QuestLog and C_QuestLog.GetTitleForLogIndex then
        return C_QuestLog.GetTitleForLogIndex(index)
    end
    return GetQuestLogTitle and GetQuestLogTitle(index)
end

function RGX.API.GetNumQuestLogEntries()
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        return C_QuestLog.GetNumQuestLogEntries()
    end
    return GetNumQuestLogEntries and GetNumQuestLogEntries()
end

function RGX.API.GetQuestLogIndexByID(questID)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(questID)
    end
    return GetQuestLogIndexByID and GetQuestLogIndexByID(questID)
end

function RGX.API.GetQuestObjectives(questID)
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        return C_QuestLog.GetQuestObjectives(questID)
    end
    if C_TaskQuest and C_TaskQuest.GetQuestObjectives then
        return C_TaskQuest.GetQuestObjectives(questID)
    end
    return nil
end

function RGX.API.IsQuestTask(questID)
    if C_QuestLog and C_QuestLog.IsQuestTask then
        return C_QuestLog.IsQuestTask(questID)
    end
    if C_TaskQuest and C_TaskQuest.IsQuestTask then
        return C_TaskQuest.IsQuestTask(questID)
    end
    return false
end

function RGX.API.GetQuestInfoByQuestID(questID)
    if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
        return C_TaskQuest.GetQuestInfoByQuestID(questID)
    end
    return nil
end

function RGX.API.GetNamePlateForUnit(unit)
    if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
        return C_NamePlate.GetNamePlateForUnit(unit)
    end
    return nil
end

function RGX.API.GetNamePlates()
    if C_NamePlate and C_NamePlate.GetNamePlates then
        return C_NamePlate.GetNamePlates()
    end
    return {}
end

function RGX.API.UnitAura(unit, index, filter)
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        return C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    end
    return UnitAura(unit, index, filter)
end

function RGX.API.GetPlayerAuraBySpellID(spellID)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        return C_UnitAuras.GetPlayerAuraBySpellID(spellID)
    end
    -- Fallback: scan manually
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i, "HELPFUL")
        if spellId == spellID then
            return { spellId = spellId, name = name, index = i }
        end
    end
    return nil
end

function RGX.API.GetSpellInfo(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            return info.name, info.rank, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID
        end
    end
    return GetSpellInfo(spellID)
end

function RGX.API.GetSpellCooldown(spellID)
    if C_Spell and C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(spellID)
        if info then
            return info.startTime or 0, info.duration or 0, info.isEnabled and 1 or 0, info.modRate or 1
        end
    end
    return GetSpellCooldown(spellID)
end

function RGX.API.IsUsableSpell(spellID)
    if C_Spell and C_Spell.IsSpellUsable then
        local usable, noMana = C_Spell.IsSpellUsable(spellID)
        if type(usable) == "table" then
            return usable.isUsable, usable.notEnoughMana
        end
        return usable, noMana
    end
    return IsUsableSpell(spellID)
end

function RGX.API.GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        local info = C_Item.GetItemInfo(item)
        if type(info) == "table" then
            return info.itemName, info.itemLink, info.itemQuality, info.itemLevel, info.itemMinLevel, info.itemType, info.itemSubType, info.itemStackCount, info.itemEquipLoc, info.iconFileID, info.itemSellPrice
        end
    end
    return GetItemInfo(item)
end

function RGX.API.GetItemCount(itemID, includeBank)
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, includeBank)
    end
    return GetItemCount(itemID, includeBank)
end

function RGX.API.GetItemIcon(itemID)
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(itemID)
    end
    return GetItemIcon(itemID)
end

function RGX.API.GetGossipOptions()
    if C_GossipInfo and C_GossipInfo.GetOptions then
        return C_GossipInfo.GetOptions()
    end
    return GetGossipOptions and GetGossipOptions() or {}
end

function RGX.API.GetNumGossipOptions()
    if C_GossipInfo and C_GossipInfo.GetOptions then
        return #C_GossipInfo.GetOptions()
    end
    return GetNumGossipOptions and GetNumGossipOptions() or 0
end

function RGX.API.IsTravelersLogAvailable()
    if C_PlayerInfo and C_PlayerInfo.IsTravelersLogAvailable then
        return C_PlayerInfo.IsTravelersLogAvailable()
    end
    return false
end

-- Module loading conditionals
RGX.ModuleAvailability = {}

function RGX:IsModuleAvailable(moduleName)
    local version = self.wowVersion
    
    -- Modules only available on Retail
    local retailOnly = {
        "tradingpost", "housing", "delves", "collectibles",
        "databroker", "sound", "sharedmedia"
    }
    
    -- Modules available on Wrath+
    local wrathPlus = {
        "achievement", "levelup", "honor"
    }
    
    -- Modules available on Cata+
    local cataPlus = {
        "reputation", "petbattles"
    }
    
    if not self.isRetail then
        for _, mod in ipairs(retailOnly) do
            if mod == moduleName then return false end
        end
    end
    
    if self.isClassicEra or self.isTBC then
        for _, mod in ipairs(wrathPlus) do
            if mod == moduleName then return false end
        end
        for _, mod in ipairs(cataPlus) do
            if mod == moduleName then return false end
        end
    end
    
    if self.isClassicEra then
        for _, mod in ipairs(cataPlus) do
            if mod == moduleName then return false end
        end
    end
    
    return true
end

-- Conditional module loader
function RGX:TryLoadModule(moduleName)
    if not self:IsModuleAvailable(moduleName) then
        if self.debugMode then
            print("|cFFFF8800[RGX] Module " .. moduleName .. " not available on " .. self.wowVersion .. "|r")
        end
        return false
    end
    
    local global = self.moduleAliases[moduleName]
    if global then
        local mod = _G[global]
        if mod and type(mod.Init) == "function" then
            local ok, err = pcall(mod.Init, mod)
            if not ok then
                print("|cFFFF4444[RGX] Init error " .. global .. ": " .. tostring(err) .. "|r")
            end
            return true
        end
    end
    return false
end

print("|cFF88FF88[RGX] Compat layer loaded: " .. RGX.wowVersion .. "|r")

-- Secret value/table access helpers for addons
function RGX.API.CanAccessValue(value)
    if value == nil then return false end
    if type(canaccessvalue) == "function" then
        return canaccessvalue(value) == true
    end
    if type(issecretvalue) == "function" then
        return not issecretvalue(value)
    end
    return true
end

function RGX.API.CanAccessTable(tbl)
    if tbl == nil then return false end
    if type(canaccesstable) == "function" then
        return canaccesstable(tbl) == true
    end
    if type(issecrettable) == "function" then
        return not issecrettable(tbl)
    end
    if type(issecretvalue) == "function" then
        return not issecretvalue(tbl)
    end
    return type(tbl) == "table"
end

-- Safe iteration helper
function RGX.API.SafeIterate(tbl, fn)
    if not RGX.API.CanAccessTable(tbl) then return end
    for k, v in pairs(tbl) do
        fn(k, v)
    end
end

function RGX.API.SafeIpairs(tbl, fn)
    if not RGX.API.CanAccessTable(tbl) then return end
    for i, v in ipairs(tbl) do
        fn(i, v)
    end
end