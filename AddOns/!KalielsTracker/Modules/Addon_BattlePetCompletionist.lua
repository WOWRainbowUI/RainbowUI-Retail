--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AddonBattlePetCompletionist
local M = KT:NewModule("AddonBattlePetCompletionist")
KT.AddonBattlePetCompletionist = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local BattlePetCompletionist = BattlePetCompletionist
local BPC_ObjectiveTrackerModule, BPC_Profile

local settings = {
    headerText = PETS,
    events = { "PET_JOURNAL_LIST_UPDATE", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA" },
    blockTemplate = "KT_ObjectiveTrackerStaticBlockTemplate",
    lineTemplate = "KT_ObjectiveTrackerClickLineWithIconTemplate"
}
KT_BattlePetCompletionistObjectiveTrackerMixin = CreateFromMixins(KT_ObjectiveTrackerModuleMixin, settings)

local texts = {
    TrackPets = C_Spell.GetSpellName(122026),
    CapturedPets = "Show Captured"
}

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupBPC()
    BPC_ObjectiveTrackerModule = BattlePetCompletionist:GetModule("ObjectiveTrackerModule")
    BPC_Profile = BattlePetCompletionist:GetModule("DBModule"):GetProfile()
end

local function SetPetsHeaderText()
    local suffix
    if db.bpcHeaderSuffix then
        local _, numPetsOwned = C_PetJournal.GetNumPets()
        suffix = numPetsOwned
    end
    KT_BattlePetCompletionistObjectiveTracker:SetHeaderSuffix(suffix)
end

function M:GetHeaderAppendText()
    if db.bpcHeaderSuffix then
        local _, numPetsOwned = C_PetJournal.GetNumPets()
        return numPetsOwned
    end
end

local function SetupOptions()
    KT.options.args.addons.args.battlepetcompletionist = {
        name = "Battle Pet Completionist",
        type = "group",
        order = 2,
        args = {
            header = {
                name = "Header",
                type = "group",
                inline = true,
                order = 1,
                args = {
                    bpcHeaderSuffix = {
                        name = "Show number of owned Pets",
                        desc = "Show number of owned Pets inside the Battle Pet Completionist header.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.bpcHeaderSuffix = not db.bpcHeaderSuffix
                            SetPetsHeaderText()
                        end,
                        order = 1,
                    },
                },
            },
        },
    }
end

local function FilterMenuUpdate(self, info, level)
    if MSA_DROPDOWNMENU_MENU_LEVEL == 1 then
        KT.Menu_AddSeparator()

        KT.Menu_AddTitle(PETS)
        info.notCheckable = false

        KT.Menu_AddCheck(texts.TrackPets, { BPC_Profile, "objectiveTrackerEnabled" }, function()
            BPC_Profile.objectiveTrackerEnabled = not BPC_Profile.objectiveTrackerEnabled
            KT_BattlePetCompletionistObjectiveTracker:MarkDirty()
            if KT:IsCollapsed() and BPC_Profile.objectiveTrackerEnabled then
                KT:MinimizeButton_OnClick()
            end
        end)

        info.keepShownOnClick = true

        KT.Menu_AddCheck(texts.CapturedPets, { BPC_Profile, "objectiveTrackerFilter", _BattlePetCompletionist.Enums.MapPinFilter.ALL }, function(_, _, _, _, value)
            BPC_Profile.objectiveTrackerFilter = value and _BattlePetCompletionist.Enums.MapPinFilter.ALL or _BattlePetCompletionist.Enums.MapPinFilter.MISSING
            KT_BattlePetCompletionistObjectiveTracker:MarkDirty()
        end)
    end
end

-- External ------------------------------------------------------------------------------------------------------------

function KT_BattlePetCompletionistObjectiveTrackerMixin:OnEvent(event, ...)
    if event == "PET_JOURNAL_LIST_UPDATE" then
        SetPetsHeaderText()
    end

    self:MarkDirty()
end

function KT_BattlePetCompletionistObjectiveTrackerMixin:OnLineClick(line, mouseButton)
    if mouseButton == "LeftButton" then
        if KT.InCombatBlocked() then return end

        if not CollectionsJournal or not CollectionsJournal:IsShown() then
            ToggleCollectionsJournal()
        end
        CollectionsJournal_SetTab(CollectionsJournal, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)

        PetJournal_SelectSpecies(PetJournal, line.speciesId)
    end
end

function KT_BattlePetCompletionistObjectiveTrackerMixin:OnLineFree(line)
    line.speciesId = nil
end

function KT_BattlePetCompletionistObjectiveTrackerMixin:LayoutContents()
    local filteredPets, mapID = BPC_ObjectiveTrackerModule:GetFilteredPetList()
    if not filteredPets then return end

    local mapInfo = C_Map.GetMapInfo(mapID)
    local zoneName = mapInfo and mapInfo.name

    local block = self:GetBlock("battlepets")
    block:SetHeader(zoneName)

    for _, petInfo in ipairs(filteredPets) do
        self:AddBattlePet(block, petInfo)
    end

    self:LayoutBlock(block)
end

function KT_BattlePetCompletionistObjectiveTrackerMixin:AddBattlePet(block, petInfo)
    if not petInfo.speciesName then return end

    local objectiveKey = "battlepet-" .. petInfo.speciesId
    local _, icon = C_PetJournal.GetPetInfoBySpeciesID(petInfo.speciesId)
    local colorStyle
    if petInfo.numCollected > 0 then
        colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
    end

    local line = block:AddObjective(objectiveKey, petInfo.speciesName, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE, colorStyle, nil, 16)
    line:SetIcon(icon)
    line.speciesId = petInfo.speciesId
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = (KT:CheckAddOn("BattlePetCompletionist", "12.0.5-20260508-1") and db.addonBattlePetCompletionist)

    if self.isAvailable then
        local defaults = KT:MergeTables({
            profile = {
                bpcHeaderSuffix = true,
            }
        }, KT.db.defaults)
        KT.db:RegisterDefaults(defaults)

        KT:Tracker_RegisterModule("KT_BattlePetCompletionistObjectiveTracker", not self.isAvailable)
    end
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetupBPC()
    SetupOptions()

    KT:RegSignal("FILTER_MENU_UPDATE", FilterMenuUpdate, self)
end