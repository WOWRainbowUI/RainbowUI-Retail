local addonName, lv = ...

lv.KnowledgeSources = lv.KnowledgeSources or {}

-- Treatise source IDs by expansion parent skillLineID.
local TREATISE_QUEST_TWW = {
    [171] = 83725, [164] = 83726, [333] = 83727, [202] = 83728, [182] = 83729,
    [773] = 83730, [755] = 83731, [165] = 83732, [186] = 83733, [393] = 83734, [197] = 83735
}
local TREATISE_QUEST_MIDNIGHT = {
    [171] = 95127, -- Alchemy
    [164] = 95128, -- Blacksmithing
    [333] = 95129, -- Enchanting
    [202] = 83728, -- Engineering (from current MKPT 0.3.1 data)
    [182] = 95130, -- Herbalism
    [773] = 95131, -- Inscription
    [755] = 95133, -- Jewelcrafting
    [165] = 95134, -- Leatherworking
    [186] = 95135, -- Mining
    [393] = 95136, -- Skinning
    [197] = 95137, -- Tailoring
}

local ARTISAN_QUEST_BY_PROF = {
    [171] = 84133, [164] = 84127, [202] = 84128, [773] = 84129, [755] = 84130, [165] = 84131, [197] = 84132
}
local ARTISAN_QUESTS_MIDNIGHT = {
    [171] = {93690},                          -- Alchemy
    [164] = {93691},                          -- Blacksmithing
    [333] = {93699, 93698, 93697},           -- Enchanting (rotating)
    [202] = {93692},                          -- Engineering
    [182] = {93700, 93701, 93702, 93703, 93704}, -- Herbalism (rotating)
    [773] = {93693},                          -- Inscription
    [755] = {93694},                          -- Jewelcrafting
    [165] = {93695},                          -- Leatherworking
    [186] = {93705, 93706, 93707, 93708, 93709}, -- Mining (rotating)
    [393] = {93710, 93711, 93712, 93713, 93714}, -- Skinning (rotating)
    [197] = {93696},                          -- Tailoring
}

-- Midnight artisan currencies by parent skillLineID.
-- Parent skillLineID -> Artisan <Profession>'s Moxie currencyID.
local ARTISAN_CURRENCY_MIDNIGHT = {
    [171] = 3256, -- Alchemy
    [164] = 3257, -- Blacksmithing
    [333] = 3258, -- Enchanting
    [202] = 3259, -- Engineering
    [182] = 3260, -- Herbalism
    [773] = 3261, -- Inscription
    [755] = 3262, -- Jewelcrafting
    [165] = 3263, -- Leatherworking
    [186] = 3264, -- Mining
    [393] = 3265, -- Skinning
    [197] = 3266, -- Tailoring
}

-- Catch-up currency by expansion parent skillLineID.
local CATCHUP_CURRENCY_TWW = {
    [171] = 3057, [164] = 3058, [333] = 3059, [202] = 3060, [182] = 3061,
    [773] = 3062, [755] = 3063, [165] = 3064, [186] = 3065, [393] = 3066, [197] = 3067
}

local CATCHUP_CURRENCY_MIDNIGHT = {
    [171] = 3189, [164] = 3199, [333] = 3198, [202] = 3197, [182] = 3196,
    [773] = 3195, [755] = 3194, [165] = 3193, [186] = 3192, [393] = 3191, [197] = 3190
}

-- Unlock requirement quests for catch-up (from MKPT reference IDs).
local CATCHUP_UNLOCK_QUESTS = {
    [171] = {83253, 83255, 84133},
    [164] = {83256, 83257, 84127},
    [333] = {83258, 83259, 84084, 84290, 84295},
    [202] = {83260, 83261, 84128},
    [182] = {81416, 81421, 82970},
    [773] = {83262, 83264, 84129},
    [755] = {83265, 83266, 84130},
    [165] = {83267, 83268, 84131},
    [186] = {83049, 83050, 83104},
    [393] = {81464, 81459, 83097},
    [197] = {83269, 83270, 84132},
}
local CATCHUP_UNLOCK_QUESTS_MIDNIGHT = {
    [333] = {93532, 93533, 95048, 95053, 93699}, -- Enchanting
    [182] = {93700, 81421, 81430},               -- Herbalism
    [186] = {93705, 88673, 88678},               -- Mining
    [393] = {93710, 88534, 88529},               -- Skinning
}

local function IsMidnightMode()
    return LiteVaultDB and LiteVaultDB.professionExpansionMode == "midnight"
end

local function GetTreatiseQuestID(skillLineID)
    if IsMidnightMode() then
        return TREATISE_QUEST_MIDNIGHT[skillLineID]
    end
    return TREATISE_QUEST_TWW[skillLineID]
end

local function GetArtisanQuestIDs(skillLineID)
    if IsMidnightMode() then
        return ARTISAN_QUESTS_MIDNIGHT[skillLineID]
    end
    local questID = ARTISAN_QUEST_BY_PROF[skillLineID]
    if questID then
        return { questID }
    end
    return nil
end

function lv.KnowledgeSources.GetCatchUpCurrencyID(skillLineID)
    if IsMidnightMode() then
        return CATCHUP_CURRENCY_MIDNIGHT[skillLineID]
    end
    return CATCHUP_CURRENCY_TWW[skillLineID]
end

local function IsQuestDone(questID)
    if not questID then return false end
    return C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
end

local function CountCompletedQuests(questList)
    if not questList or #questList == 0 then return 0 end
    local done = 0
    for _, q in ipairs(questList) do
        if IsQuestDone(q) then
            done = done + 1
        end
    end
    return done
end

local function AreAllQuestsDone(questList)
    if not questList or #questList == 0 then return true end
    for _, q in ipairs(questList) do
        if not IsQuestDone(q) then
            return false
        end
    end
    return true
end

function lv.KnowledgeSources.GetSourcesForProfession(skillLineID)
    local out = {}
    local tQuest = GetTreatiseQuestID(skillLineID)
    if tQuest then
        out[#out + 1] = {
            key = "treatise",
            label = (L and L["Treatise"] and L["Treatise"] ~= "Treatise") and L["Treatise"] or "Treatise",
            questID = tQuest,
            done = IsQuestDone(tQuest),
            points = 1,
            repeatable = true
        }
    end

    local artisanQuestIDs = GetArtisanQuestIDs(skillLineID)
    local artisanDoneCount = CountCompletedQuests(artisanQuestIDs)
    local artisanTotalCount = artisanQuestIDs and #artisanQuestIDs or 0
    local artisanDone = artisanTotalCount > 0 and artisanDoneCount > 0 or false
    local artisanCurrencyID = IsMidnightMode() and ARTISAN_CURRENCY_MIDNIGHT[skillLineID] or nil
    local artisanCurrencyInfo = artisanCurrencyID and C_CurrencyInfo.GetCurrencyInfo(artisanCurrencyID) or nil
    if artisanQuestIDs or artisanCurrencyInfo then
        out[#out + 1] = {
            key = "artisan",
            label = (L and L["Artisan"] and L["Artisan"] ~= "Artisan") and L["Artisan"] or "Artisan",
            questID = artisanQuestIDs and artisanQuestIDs[1] or nil,
            questIDs = artisanQuestIDs,
            done = artisanDone,
            doneCount = artisanDoneCount,
            totalCount = artisanTotalCount,
            points = 2,
            repeatable = true,
            currencyID = artisanCurrencyID,
            currencyInfo = artisanCurrencyInfo,
        }
    end

    local catchID = lv.KnowledgeSources.GetCatchUpCurrencyID(skillLineID)
    if catchID then
        local cInfo = C_CurrencyInfo.GetCurrencyInfo(catchID)
        local unlockQuests = nil
        if IsMidnightMode() and CATCHUP_UNLOCK_QUESTS_MIDNIGHT[skillLineID] then
            unlockQuests = CATCHUP_UNLOCK_QUESTS_MIDNIGHT[skillLineID]
        else
            unlockQuests = CATCHUP_UNLOCK_QUESTS[skillLineID]
        end
        out[#out + 1] = {
            key = "catchup",
            label = (L and L["Catch-up"] and L["Catch-up"] ~= "Catch-up") and L["Catch-up"] or "Catch-up",
            currencyID = catchID,
            currencyInfo = cInfo,
            unlocked = AreAllQuestsDone(unlockQuests),
            unlockQuests = unlockQuests,
            repeatable = true
        }
    end

    return out
end

function lv.KnowledgeSources.CalculateWeeklySummary(skillLineID)
    local summary = {
        weeklyDone = 0,
        weeklyTotal = 0,
        catchUpCurrent = 0,
        catchUpMax = 0,
        catchUpUnlocked = false,
    }
    local entries = lv.KnowledgeSources.GetSourcesForProfession(skillLineID)
    for _, e in ipairs(entries) do
        if e.key == "treatise" or e.key == "artisan" then
            summary.weeklyTotal = summary.weeklyTotal + 1
            if e.done then summary.weeklyDone = summary.weeklyDone + 1 end
        elseif e.key == "catchup" and e.currencyInfo then
            summary.catchUpCurrent = tonumber(e.currencyInfo.quantity) or 0
            summary.catchUpMax = tonumber(e.currencyInfo.maxQuantity) or 0
            summary.catchUpUnlocked = e.unlocked and true or false
        end
    end
    return summary, entries
end
