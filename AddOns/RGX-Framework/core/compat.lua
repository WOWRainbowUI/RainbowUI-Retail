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

local function HasFunction(namespace, name)
    return type(namespace) == "table" and type(namespace[name]) == "function"
end

local function HasEvent(name)
    if HasFunction(C_EventUtils, "IsEventValid") then
        return C_EventUtils.IsEventValid(name) == true
    end
    return true
end

RGX.Capabilities = {
    events = HasFunction(C_EventUtils, "IsEventValid"),
    modernAuras = HasFunction(C_UnitAuras, "GetAuraDataByIndex"),
    playerAuraBySpell = HasFunction(C_UnitAuras, "GetPlayerAuraBySpellID"),
    modernQuestLog = HasFunction(C_QuestLog, "GetNumQuestLogEntries") and HasFunction(C_QuestLog, "GetInfo"),
    legacyQuestLog = type(GetNumQuestLogEntries) == "function" and type(GetQuestLogTitle) == "function",
    modernReputation = HasFunction(C_Reputation, "GetNumFactions") and HasFunction(C_Reputation, "GetFactionDataByIndex"),
    legacyReputation = type(GetNumFactions) == "function" and type(GetFactionInfo) == "function",
    achievements = HasEvent("ACHIEVEMENT_EARNED"),
    petBattles = HasFunction(C_PetBattles, "GetHealth") and HasEvent("PET_BATTLE_OPENING_START"),
    modernHonor = type(UnitHonorLevel) == "function" and HasEvent("HONOR_LEVEL_UPDATE"),
    legacyHonor = HasEvent("HONOR_XP_UPDATE") or HasEvent("PLAYER_PVP_RANK_CHANGED"),
    renown = HasFunction(C_MajorFactions, "GetMajorFactionIDs") and HasFunction(C_MajorFactions, "GetMajorFactionData") and HasEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED"),
    delves = HasFunction(C_DelvesUI, "GetFactionForCompanion") or HasFunction(C_DelvesUI, "GetDelvesFactionForSeason"),
    housing = HasEvent("CURRENT_HOUSE_INFO_RECIEVED") and (type(C_Housing) == "table" or type(C_HousingDecor) == "table"),
    tradingPost = HasFunction(C_PerksProgram, "GetCurrencyAmount") and HasEvent("PERKS_PROGRAM_CURRENCY_REFRESH"),
    prey = HasFunction(C_QuestLog, "GetActivePreyQuest") and HasEvent("UPDATE_UI_WIDGET"),
    settings = HasFunction(Settings, "RegisterCanvasLayoutCategory") and HasFunction(Settings, "RegisterAddOnCategory") and HasFunction(Settings, "OpenToCategory"),
    menuUtil = HasFunction(MenuUtil, "CreateContextMenu"),
}

function RGX:HasCapability(name)
    return self.Capabilities[name] == true
end

function RGX:HasEvent(name)
    return HasEvent(name)
end

function RGX:CreateCompatibleFrame(frameType, name, parent, preferredTemplate, fallbackTemplate)
    if preferredTemplate then
        local ok, frame = pcall(CreateFrame, frameType, name, parent, preferredTemplate)
        if ok and frame then return frame, true end
    end
    return CreateFrame(frameType, name, parent, fallbackTemplate), false
end

-- API shims for Classic (Retail APIs that don't exist on Classic)
if not C_AddOns then
    C_AddOns = {}
    C_AddOns.GetAddOnMetadata = GetAddOnMetadata
    C_AddOns.LoadAddOn = LoadAddOn
    C_AddOns.IsAddOnLoaded = IsAddOnLoaded
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
    if type(UnitAura) ~= "function" then return nil end
    local name, icon, applications, dispelName, duration, expirationTime,
        sourceUnit, isStealable, _, spellId, canApplyAura, isBossAura,
        castByPlayer, nameplateShowAll, timeMod = UnitAura(unit, index, filter)
    if not name then return nil end
    return {
        name = name,
        icon = icon,
        applications = applications,
        dispelName = dispelName,
        duration = duration,
        expirationTime = expirationTime,
        sourceUnit = sourceUnit,
        isStealable = isStealable,
        spellId = spellId,
        canApplyAura = canApplyAura,
        isBossAura = isBossAura,
        isFromPlayerOrPlayerPet = castByPlayer,
        nameplateShowAll = nameplateShowAll,
        timeMod = timeMod,
    }
end

function RGX.API.GetPlayerAuraBySpellID(spellID)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        return C_UnitAuras.GetPlayerAuraBySpellID(spellID)
    end
    -- Fallback: scan manually
    for i = 1, 40 do
        local aura = RGX.API.UnitAura("player", i, "HELPFUL")
        if not aura then break end
        if aura.spellId == spellID then return aura end
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
    return type(GetSpellInfo) == "function" and GetSpellInfo(spellID) or nil
end

function RGX.API.GetSpellCooldown(spellID)
    if C_Spell and C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(spellID)
        if info then
            return info.startTime or 0, info.duration or 0, info.isEnabled and 1 or 0, info.modRate or 1
        end
    end
    return type(GetSpellCooldown) == "function" and GetSpellCooldown(spellID) or nil
end

function RGX.API.IsUsableSpell(spellID)
    if C_Spell and C_Spell.IsSpellUsable then
        local usable, noMana = C_Spell.IsSpellUsable(spellID)
        if type(usable) == "table" then
            return usable.isUsable, usable.notEnoughMana
        end
        return usable, noMana
    end
    return type(IsUsableSpell) == "function" and IsUsableSpell(spellID) or nil
end

function RGX.API.GetItemInfo(item)
    if C_Item and C_Item.GetItemInfo then
        local info = C_Item.GetItemInfo(item)
        if type(info) == "table" then
            return info.itemName, info.itemLink, info.itemQuality, info.itemLevel, info.itemMinLevel, info.itemType, info.itemSubType, info.itemStackCount, info.itemEquipLoc, info.iconFileID, info.itemSellPrice
        end
    end
    return type(GetItemInfo) == "function" and GetItemInfo(item) or nil
end

function RGX.API.GetItemCount(itemID, includeBank)
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, includeBank)
    end
    return type(GetItemCount) == "function" and GetItemCount(itemID, includeBank) or 0
end

function RGX.API.GetItemIcon(itemID)
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(itemID)
    end
    return type(GetItemIcon) == "function" and GetItemIcon(itemID) or nil
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
RGX.ModuleAvailability = {
    achievement = "achievements",
    petbattles = "petBattles",
    honor = function(self) return self:HasCapability("modernHonor") or self:HasCapability("legacyHonor") end,
    delves = "delves",
    housing = "housing",
    tradingpost = "tradingPost",
    prey = "prey",
}

function RGX:IsModuleAvailable(moduleName)
    local rule = self.ModuleAvailability[moduleName]
    if type(rule) == "string" then return self:HasCapability(rule) end
    if type(rule) == "function" then return rule(self) == true end
    return true
end

for moduleName, module in pairs(RGX.modules or {}) do
    module.available = RGX:IsModuleAvailable(moduleName)
end

function RGX.API.GetQuestLogInfo(index)
    if C_QuestLog and type(C_QuestLog.GetInfo) == "function" then
        return C_QuestLog.GetInfo(index)
    end
    if type(GetQuestLogTitle) ~= "function" then return nil end
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
        frequency, questID = GetQuestLogTitle(index)
    return {
        title = title,
        level = level,
        suggestedGroup = suggestedGroup,
        isHeader = isHeader == true,
        isCollapsed = isCollapsed == true,
        isComplete = isComplete,
        frequency = frequency,
        questID = questID,
        questLogIndex = index,
    }
end

function RGX.API.GetFactionCount()
    if C_Reputation and type(C_Reputation.GetNumFactions) == "function" then
        return C_Reputation.GetNumFactions()
    end
    return type(GetNumFactions) == "function" and GetNumFactions() or 0
end

function RGX.API.GetFactionDataByIndex(index)
    if C_Reputation and type(C_Reputation.GetFactionDataByIndex) == "function" then
        return C_Reputation.GetFactionDataByIndex(index)
    end
    if type(GetFactionInfo) ~= "function" then return nil end
    local name, description, standingID, barMin, barMax, barValue,
        atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep,
        isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(index)
    if not name then return nil end
    return {
        factionID = factionID,
        name = name,
        description = description,
        reaction = standingID,
        currentReactionThreshold = barMin,
        nextReactionThreshold = barMax,
        currentStanding = barValue,
        atWarWith = atWarWith,
        canToggleAtWar = canToggleAtWar,
        isHeader = isHeader,
        isHeaderWithRep = hasRep,
        isCollapsed = isCollapsed,
        isWatched = isWatched,
        isChild = isChild,
        hasBonusRepGain = hasBonusRepGain,
        canSetInactive = canSetInactive,
    }
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
