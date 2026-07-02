local addonName, lv = ... -- 'lv' is our shared namespace
local L = lv.L

-- 1. INITIALIZE GLOBALS
LiteVaultDB = LiteVaultDB or {}
LiteVaultOrder = LiteVaultOrder or {}
LiteVaultMinimapDB = LiteVaultMinimapDB or {}

-- 2. CONSTANTS
local playerName = UnitName("player") or "Unknown"
local realmName = GetRealmName() or "UnknownRealm"
lv.PLAYER_KEY = playerName .. "-" .. realmName
local regionNames = { "US", "KR", "EU", "TW", "CN" }
lv.REGION = regionNames[GetCurrentRegion and GetCurrentRegion() or 1] or "US"
lv.RAID_DIFFS = { {id = 16, tag = "M", col = "ffff8000"}, {id = 15, tag = "H", col = "ffa335ee"}, {id = 14, tag = "N", col = "ff0070dd"} }
-- Learned dynamically by raid tracker when current-tier raids are detected.
lv.CURRENT_TIER_MAPS = lv.CURRENT_TIER_MAPS or {}
lv.NUM_RAID_BOSSES = 8 -- Manaforge Omega has 8 bosses

-- 3. RUNTIME STATE
lv.atWarbandBank = false -- Track if warband bank is open

local questTooltipHooksInstalled = false

local function AddQuestIDToTooltip(tooltip, questID)
    questID = tonumber(questID)
    if not tooltip or not questID or questID == 0 then
        return
    end
    if tooltip.lvQuestIDLine == questID then
        return
    end

    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(" ", "ID: |cffffffff" .. questID)
    tooltip.lvQuestIDLine = questID
    tooltip:Show()
end

local function ClearQuestIDTooltipState(tooltip)
    if tooltip then
        tooltip.lvQuestIDLine = nil
    end
end

local function InstallQuestTooltipHooks()
    if questTooltipHooksInstalled or not hooksecurefunc then
        return
    end

    local gameTooltip = GameTooltip
    if not gameTooltip then
        return
    end

    questTooltipHooksInstalled = true
    gameTooltip:HookScript("OnTooltipCleared", ClearQuestIDTooltipState)

    if ItemRefTooltip and ItemRefTooltip.HookScript then
        ItemRefTooltip:HookScript("OnTooltipCleared", ClearQuestIDTooltipState)
    end

    local function ShowQuestTooltipWithID(owner, questID)
        questID = tonumber(questID)
        if not owner or not questID or questID == 0 then
            return
        end

        local questLink = GetQuestLink and GetQuestLink(questID)
        local title = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)
        if (not questLink or questLink == "") and (not title or title == "") then
            return
        end

        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
        if questLink and questLink ~= "" then
            GameTooltip:SetHyperlink(questLink)
        else
            GameTooltip:SetText(title, 1, 0.82, 0)
        end
        AddQuestIDToTooltip(GameTooltip, questID)
    end

    local function GetQuestIDFromMapButton(button)
        if not button then
            return nil
        end
        if button.questID then
            return button.questID
        end
        if button.questLogIndex and C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
            return C_QuestLog.GetQuestIDForLogIndex(button.questLogIndex)
        end
        if button.tagInfo and button.tagInfo.questID then
            return button.tagInfo.questID
        end
        return nil
    end

    if ObjectiveTrackerModuleMixin then
        hooksecurefunc(ObjectiveTrackerModuleMixin, "OnBlockHeaderEnter", function(self, block)
            local questID = block and block.id
            if not questID then
                return
            end
            if GameTooltip and GameTooltip:IsShown() then
                AddQuestIDToTooltip(GameTooltip, questID)
            else
                ShowQuestTooltipWithID(block, questID)
            end
        end)
    end

    if BonusObjectiveTrackerBlockMixin then
        hooksecurefunc(BonusObjectiveTrackerBlockMixin, "TryShowRewardsTooltip", function(self)
            if not self or not self.id then
                return
            end
            if GameTooltip and GameTooltip:IsShown() then
                AddQuestIDToTooltip(GameTooltip, self.id)
            else
                ShowQuestTooltipWithID(self, self.id)
            end
        end)
    end

    if QuestMapLogTitleButton_OnEnter then
        hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(button)
            local questID = GetQuestIDFromMapButton(button)
            if not questID then
                return
            end
            if GameTooltip and GameTooltip:IsShown() then
                AddQuestIDToTooltip(GameTooltip, questID)
            else
                ShowQuestTooltipWithID(button, questID)
            end
        end)
    end

    if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Quest then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function(tooltip, data)
            AddQuestIDToTooltip(tooltip, data and (data.questID or data.id))
        end)
    end

    if gameTooltip.SetQuestLogItem then
        hooksecurefunc(gameTooltip, "SetQuestLogItem", function(tooltip, itemType, index, questID)
            AddQuestIDToTooltip(tooltip, questID)
        end)
    end

    if gameTooltip.SetHyperlink then
        hooksecurefunc(gameTooltip, "SetHyperlink", function(tooltip, link)
            local questID = type(link) == "string" and link:match("^quest:(%d+)")
            AddQuestIDToTooltip(tooltip, questID)
        end)
    end

    if ItemRefTooltip and ItemRefTooltip.SetHyperlink then
        hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(tooltip, link)
            local questID = type(link) == "string" and link:match("^quest:(%d+)")
            AddQuestIDToTooltip(tooltip, questID)
        end)
    end
end

-- Catalyst Currency IDs
-- 3269 = Ethereal Voidsplinter (TWW Season 3, until 2/27/2026)
-- 3378 = Dawnlight Manaflux (Midnight, after 2/27/2026)
lv.CATALYST_ID = 3378  -- Dawnlight Manaflux (Midnight)
lv.ASCENDANT_VOIDSHARD_ITEM_ID = 268650
lv.ASCENDANT_VOIDCORE_ITEM_ID = 268552

-- KNOWN IDs to force-check (Bypasses "Collapsed/Legacy" bugs)
lv.FORCE_IDS = {
    [3028] = "Restored Coffer Key",
    [3310] = "Coffer Key Shards",
    [2803] = "Undercoin",
    [3356] = "Untainted Mana-Crystals",
    [3316] = "Voidlight Marl",
    [3376] = "Shard of Dundun",
    [3379] = "Brimming Arcana",
    [3392] = "Remnant of Anguish"
}

-- Pattern matching for auto-detecting currencies (future-proof)
lv.CURRENCY_PATTERNS = {
    "Dawncrest",       -- Midnight crest family
    "Coffer Key",      -- Delve keys
    "Undercoin",       -- Delve currency
    "Mana%-Crystals",  -- Midnight delve currency
    "Voidlight Marl",  -- Midnight crystals
    "Spark",           -- Crafting sparks
    "Flightstones?",   -- Dragon Isles currency (with optional 's')
}

-- Legacy keyword system (kept for backward compatibility)
lv.CURRENCY_KEYWORDS = {
    ["Restored Coffer Key"] = true, 
    ["Coffer Key Shards"] = true,
    ["Undercoin"] = true, 
    ["Untainted Mana-Crystals"] = true,
    ["Voidlight Marl"] = true,
    ["Shard of Dundun"] = true,
    ["Brimming Arcana"] = true,
    ["Remnant of Anguish"] = true,
    -- Midnight dawncrests
    ["Adventurer Dawncrest"] = true,
    ["Veteran Dawncrest"] = true,
    ["Champion Dawncrest"] = true,
    ["Hero Dawncrest"] = true,
    ["Myth Dawncrest"] = true,
}

lv.ORDERED_KEYWORDS = {
    "Undercoin",
    "Voidlight Marl",
    "Brimming Arcana",
    "Remnant of Anguish",
    "Restored Coffer Key",
    "Coffer Key Shards",
    "Untainted Mana-Crystals",
    "Shard of Dundun",
    "Adventurer Dawncrest",
    "Veteran Dawncrest",
    "Champion Dawncrest",
    "Hero Dawncrest",
    "Myth Dawncrest"
}

local function GetVaultThresholdType(name, fallback)
    return (Enum and Enum.WeeklyRewardChestThresholdType and Enum.WeeklyRewardChestThresholdType[name]) or fallback
end

local VAULT_RAID_TYPE = GetVaultThresholdType("Raid", 3)
local VAULT_MYTHIC_TYPE = GetVaultThresholdType("Activities", 1)
local VAULT_DELVE_TYPE = GetVaultThresholdType("World", 6)

local function BuildEmptyVaultCategory()
    return {
        progress = 0,
        threshold = 0,
        slots = 0,
        highest = 0,
        rewardText = nil,
        itemLevel = 0,
        slotData = {},
    }
end

local function GetVaultRewardText(activityType, level)
    if not level or level <= 0 then
        return nil
    end

    if activityType == VAULT_RAID_TYPE then
        if DifficultyUtil and DifficultyUtil.GetDifficultyName then
            return DifficultyUtil.GetDifficultyName(level)
        end
        return tostring(level)
    end

    if activityType == VAULT_MYTHIC_TYPE then
        return string.format("+%d", level)
    end

    return string.format("Tier %d", level)
end

local function GetItemLevelFromLink(itemLink)
    if not itemLink then
        return 0
    end

    if GetDetailedItemLevelInfo then
        local itemLevel = GetDetailedItemLevelInfo(itemLink)
        if itemLevel and itemLevel > 0 then
            return itemLevel
        end
    end

    if C_Item and C_Item.GetDetailedItemLevelInfo then
        local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
        if itemLevel and itemLevel > 0 then
            return itemLevel
        end
    end

    return 0
end

local function GetVaultRewardItemLevel(activityID)
    if not activityID or not C_WeeklyRewards or not C_WeeklyRewards.GetExampleRewardItemHyperlinks then
        return 0
    end

    local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activityID)

    -- Prefer the base reward link for the actual vault slot item level.
    -- The upgrade preview link can flatten lower slots upward (for example, +9 showing as +10+).
    local itemLevel = GetItemLevelFromLink(itemLink)
    if itemLevel > 0 then
        return itemLevel
    end

    return GetItemLevelFromLink(upgradeItemLink)
end

local function RebuildBucketSummary(bucket)
    bucket.itemLevel = 0
    bucket.rewardText = nil
    bucket.highest = 0

    for _, slotInfo in ipairs(bucket.slotData or {}) do
        if slotInfo and slotInfo.unlocked then
            bucket.highest = math.max(bucket.highest or 0, slotInfo.highest or 0)
            if (slotInfo.itemLevel or 0) > (bucket.itemLevel or 0) then
                bucket.itemLevel = slotInfo.itemLevel or 0
                bucket.rewardText = slotInfo.rewardText
            elseif (slotInfo.itemLevel or 0) == 0 and not bucket.rewardText and slotInfo.rewardText then
                bucket.rewardText = slotInfo.rewardText
            end
        end
    end
end

function lv.ReconcileVaultSnapshotItemLevels(snapshot, previousSnapshot)
    if not snapshot or not previousSnapshot then
        return snapshot
    end

    for _, bucketKey in ipairs({ "raid", "mythic", "delve" }) do
        local currentBucket = snapshot[bucketKey]
        local previousBucket = previousSnapshot[bucketKey]

        if currentBucket and previousBucket and previousBucket.slotData then
            local restoredAny = false
            for slotIndex, slotInfo in ipairs(currentBucket.slotData or {}) do
                local previousSlot = previousBucket.slotData[slotIndex]
                if previousSlot
                    and (slotInfo.itemLevel or 0) <= 0
                    and (previousSlot.itemLevel or 0) > 0
                    and (previousSlot.threshold or 0) == (slotInfo.threshold or 0)
                    and (previousSlot.highest or 0) == (slotInfo.highest or 0) then
                    slotInfo.itemLevel = previousSlot.itemLevel
                    restoredAny = true
                end
            end

            if restoredAny then
                RebuildBucketSummary(currentBucket)
            end
        end
    end

    return snapshot
end

function lv.BuildVaultSnapshotFromActivities(activities)
    local snapshot = {
        raid = BuildEmptyVaultCategory(),
        mythic = BuildEmptyVaultCategory(),
        delve = BuildEmptyVaultCategory(),
    }
    local bucketActivities = {
        raid = {},
        mythic = {},
        delve = {},
    }

    if not activities then
        return snapshot
    end

    for _, activity in ipairs(activities) do
        local bucket
        local bucketKey
        if activity.type == VAULT_RAID_TYPE then
            bucket = snapshot.raid
            bucketKey = "raid"
        elseif activity.type == VAULT_MYTHIC_TYPE then
            bucket = snapshot.mythic
            bucketKey = "mythic"
        elseif activity.type == VAULT_DELVE_TYPE then
            bucket = snapshot.delve
            bucketKey = "delve"
        end

        if bucket and bucketKey then
            local progress = activity.progress or 0
            local threshold = activity.threshold or 0
            bucket.progress = math.max(bucket.progress or 0, progress)
            bucket.threshold = math.max(bucket.threshold or 0, threshold)
            table.insert(bucketActivities[bucketKey], activity)
        end
    end

    for bucketKey, bucket in pairs(snapshot) do
        local sortedActivities = bucketActivities[bucketKey] or {}
        table.sort(sortedActivities, function(a, b)
            local aThreshold = a and a.threshold or 0
            local bThreshold = b and b.threshold or 0
            if aThreshold ~= bThreshold then
                return aThreshold < bThreshold
            end

            local aIndex = a and a.index
            local bIndex = b and b.index
            if aIndex and bIndex and aIndex ~= bIndex then
                return aIndex < bIndex
            end

            return (a and a.id or 0) < (b and b.id or 0)
        end)

        for slotIndex, activity in ipairs(sortedActivities) do
            if slotIndex > 3 then break end

            local progress = activity.progress or 0
            local threshold = activity.threshold or 0
            local rewardText = GetVaultRewardText(activity.type, activity.level)
            local itemLevel = GetVaultRewardItemLevel(activity.id)
            bucket.slotData[slotIndex] = {
                progress = progress,
                threshold = threshold,
                unlocked = threshold > 0 and progress >= threshold,
                rewardText = rewardText,
                itemLevel = itemLevel,
                highest = activity.level or 0,
            }

            if threshold > 0 and progress >= threshold then
                bucket.slots = (bucket.slots or 0) + 1
                bucket.highest = math.max(bucket.highest or 0, activity.level or 0)
                if itemLevel > (bucket.itemLevel or 0) then
                    bucket.itemLevel = itemLevel
                    bucket.rewardText = rewardText
                elseif itemLevel == 0 and (activity.level or 0) >= (bucket.highest or 0) and not bucket.rewardText then
                    bucket.rewardText = rewardText
                end
            end
        end

        for i = 1, 3 do
            bucket.slotData[i] = bucket.slotData[i] or {
                progress = 0,
                threshold = 0,
                unlocked = false,
                rewardText = nil,
                itemLevel = 0,
                highest = 0,
            }
        end
    end

    return snapshot
end

-- Weekly Quests (TWW until 2/27/2026, then Midnight)
local MIDNIGHT_WEEKLY_QUESTS = {
    {name="Community Engagement", id=95413, variants={95416, 95438, 95440}, activeOnlyVariants={95440}, currentWeekOnly=true, accountWide=true},
    {name="Lady Liadrin Weekly", id=93910, variants={93766, 93767, 93769, 93889, 93890, 93892, 93909, 93911, 93912, 93913, 94457, 95842, 95843}},
    {name="A Nightmarish Task", id=94446},
}

local MIDNIGHT_EVENT_QUESTS = {}
lv.WEEKLY_QUESTS = MIDNIGHT_WEEKLY_QUESTS
lv.WEEKLY_EVENT_QUESTS = MIDNIGHT_EVENT_QUESTS
lv.WEEKLY_AMANI_TRIBE_QUESTS = lv.WEEKLY_AMANI_TRIBE_QUESTS or {
    {name="Abundance Event", id=89507},
}
lv.WEEKLY_HARATI_QUESTS = lv.WEEKLY_HARATI_QUESTS or {
    {name="Legends of the Haranir", id=89268, titleAliases={"Lost Legends"}},
    {name="The Story of Wey'nan's Ward", id=92716},
    {name="The Cauldron of Echoes", id=88994, variants={92719}, titleAliases={"The Story of the Cauldron of Echoes"}},
    {name="The Story of Aln'hara's Bloom", id=92720},
    {name="The Echoless Flame", id=88996, variants={92721}, titleAliases={"The Story of the Echoless Flame"}},
    {name="Russula's Outreach", id=88997, variants={92722}, titleAliases={"The Story of Russula's Outreach"}},
    {name="The Story of the Root of the World", id=92724},
    {name="The Story of Sky's Hope", id=92725},
}
lv.WEEKLY_SINGULARITY_QUESTS = lv.WEEKLY_SINGULARITY_QUESTS or {
    {name="Darkness Unmade", id=91700},
    {name="Harvesting the Void", id=86810},
    {name="Stormarion Assault", id=90962},
    {name="Hidey-Hole", id=92407},
}
lv.WEEKLY_RITUAL_SITES_QUESTS = lv.WEEKLY_RITUAL_SITES_QUESTS or {
    -- Temporarily disabled to test next-week alt pickup behavior.
    -- {name="Void Strike", id=96080, accountWide=true, currentWeekOnly=true},
    {
        name="Void Assaults",
        id=94386,
        variants={94385},
        variantNames={
            [94385]="Void Assaults: Eversong Woods",
            [94386]="Void Assaults: Zul'Aman",
        },
        rotation={
            referenceReset=1777388400,
            questIDs={94385, 94386},
        },
        currentWeekOnly=true,
    },
}
lv.WEEKLY_SILVERMOON_COURT_QUESTS = lv.WEEKLY_SILVERMOON_COURT_QUESTS or {
    {name="Midnight: Saltheril's Soiree", id=91966},
    {name="Fortify the Runestones: Blood Knights", id=90574},
    {name="Fortify the Runestones: Shades of the Row", id=90576},
    {name="Fortify the Runestones: Magisters", id=90573},
    {name="Fortify the Runestones: Farstriders", id=90575},
    {name="Sunfire to the Blade", id=91974},
    {name="Dangerous Showpieces", id=92002},
    {name="What Horrible Magic", id=91995},
    {name="Ghostland Peppers", id=91989},
    {name="Put a Little Snap in Their Step", id=91986},
    {name="Light Snacks", id=89276},
    {name="Less Lawless", id=91977},
    {name="The Subtle Game", id=91693},
    {name="Throw the Dice", id=92005},
    {name="We Need a Refill", id=92006},
    {name="Lovely Plumage", id=91983},
}
lv.ACCOUNT_WIDE_FACTION_CHOICES = {
    harati = {
        parentID = 89268,
        childIDs = {
            88994, -- The Cauldron of Echoes
            88996, -- The Echoless Flame
            88997, -- Russula's Outreach
            92716, -- The Story of Wey'nan's Ward
            92719, -- The Story of the Cauldron of Echoes
            92720, -- The Story of Aln'hara's Bloom
            92721, -- The Story of the Echoless Flame
            92722, -- The Story of Russula's Outreach
            92724, -- The Story of the Root of the World
            92725, -- The Story of Sky's Hope
        },
        captureOnAccept = false,
        captureOnTurnIn = true,
        updateFromLog = false,
        authoritativeChoice = false,
        trackParentPerChar = true,
        trackDailiesPerChar = true,
    },
    silvermoon = {
        parentID = 91966,
        childIDs = { 90574, 90576, 90573, 90575, 91974, 92002, 91995, 91989, 91986, 89276, 91977, 91693, 92005, 92006, 91983 },
        subFactionIDs = { 90574, 90576, 90573, 90575 },
        captureOnAccept = false,
        captureOnTurnIn = true,
        updateFromLog = false,
        authoritativeChoice = false,
        trackDailiesPerChar = true,
    },
}
local ACCOUNT_WIDE_FACTION_MODE_BY_QUEST = {}
for mode, cfg in pairs(lv.ACCOUNT_WIDE_FACTION_CHOICES) do
    cfg.childLookup = {}
    cfg.subFactionLookup = {}
    for _, questID in ipairs(cfg.childIDs) do
        cfg.childLookup[questID] = true
        ACCOUNT_WIDE_FACTION_MODE_BY_QUEST[questID] = mode

        if mode == "harati" then
            for _, haratiQuest in ipairs(lv.WEEKLY_HARATI_QUESTS or {}) do
                if haratiQuest and haratiQuest.id == questID then
                    for _, variantID in ipairs(haratiQuest.variants or {}) do
                        cfg.childLookup[variantID] = true
                        ACCOUNT_WIDE_FACTION_MODE_BY_QUEST[variantID] = mode
                    end
                    break
                end
            end
        end
    end
    if cfg.parentID then
        ACCOUNT_WIDE_FACTION_MODE_BY_QUEST[cfg.parentID] = mode
    end
    if cfg.subFactionIDs then
        for _, questID in ipairs(cfg.subFactionIDs) do
            cfg.subFactionLookup[questID] = true
        end
    end
end
lv.MIDNIGHT_FACTION_IDS = {
    amani = 2696,
    singularity = 2699,
    harati = 2704,
    silvermoon = 2710,
    ritualsites = 2792,
}

local function SaveAccountWideFactionChoice(mode, questID, state)
    if not mode or not questID or not state then return end
    if mode == "harati" then return end
    local cfg = lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES[mode]
    if cfg and cfg.permanent then
        LiteVaultDB.permanentFactionCompletions = LiteVaultDB.permanentFactionCompletions or {}
        LiteVaultDB.permanentFactionCompletions[mode] = {
            questID = questID,
            state = state,
            sourceKey = lv.PLAYER_KEY,
            fromEvent = true,
            updatedAt = GetServerTime and GetServerTime() or time(),
        }
    else
        LiteVaultDB.accountWideFactionChoices = LiteVaultDB.accountWideFactionChoices or {}
        LiteVaultDB.accountWideFactionChoices[mode] = {
            questID = questID,
            state = state,
            sourceKey = lv.PLAYER_KEY,
            updatedAt = GetServerTime and GetServerTime() or time(),
        }
    end
end

local function NormalizeTrackedWeeklyQuestTitle(title)
    if type(title) ~= "string" then return nil end
    title = title:gsub("’", "'"):gsub("‘", "'")
    title = title:gsub("ï¼š", ":"):gsub("：", ":")
    title = title:gsub("%s+", " ")
    title = title:match("^%s*(.-)%s*$")
    if title == "" then return nil end
    return title:lower()
end

local function NormalizeTrackedWeeklyQuestTitle(title)
    if type(title) ~= "string" then return nil end
    title = title:gsub("%s+", " ")
    title = title:match("^%s*(.-)%s*$")
    if title == "" then return nil end
    return title:lower()
end

local function BuildTrackedWeeklyQuestTitleSet(quest)
    local titles = {}
    if not quest or not quest.name then return titles end

    local function AddTitle(title)
        local normalized = NormalizeTrackedWeeklyQuestTitle(title)
        if normalized then
            titles[normalized] = true
        end
    end

    local localized = L and L[quest.name]
    AddTitle(localized)
    AddTitle(quest.name)
    if quest.titleAliases then
        for _, alias in ipairs(quest.titleAliases) do
            AddTitle(alias)
        end
    end
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        AddTitle(C_QuestLog.GetTitleForQuestID(quest.id))
        if quest.variants then
            for _, variantID in ipairs(quest.variants) do
                AddTitle(C_QuestLog.GetTitleForQuestID(variantID))
            end
        end
    end

    return titles
end

local function SaveAccountWideWeeklyQuestState(quest, state, questID, title, source)
    if not (LiteVaultDB and quest and quest.name and state) then return end
    LiteVaultDB.accountWideWeeklyQuests = LiteVaultDB.accountWideWeeklyQuests or {}
    LiteVaultDB.accountWideWeeklyQuests[quest.name] = {
        state = state,
        questID = questID,
        title = title,
        sourceKey = lv.PLAYER_KEY,
        source = source,
        updatedAt = GetServerTime and GetServerTime() or time(),
    }
end

local function SaveCharacterWeeklyQuestState(quest, state, questID, title)
    if not (LiteVaultDB and lv.PLAYER_KEY and quest and quest.name and state) then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if type(db) ~= "table" then return end

    db.weeklyQuests = db.weeklyQuests or {}
    db.weeklyQuests[quest.name] = {
        state = state,
        questID = questID,
        title = title,
        updatedAt = GetServerTime and GetServerTime() or time(),
    }
end

local function ClearCharacterWeeklyQuestState(questName)
    if not (LiteVaultDB and lv.PLAYER_KEY and questName) then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if type(db) ~= "table" or not db.weeklyQuests then return end

    db.weeklyQuests[questName] = nil
end

local function SaveCharacterFactionParentWeeklyState(mode, questID, state)
    if not (LiteVaultDB and lv.PLAYER_KEY and mode and questID and state) then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if type(db) ~= "table" then return end

    db.factionParentWeeklies = db.factionParentWeeklies or {}
    db.factionParentWeeklies[mode] = db.factionParentWeeklies[mode] or {}
    db.factionParentWeeklies[mode][questID] = {
        state = state,
        updatedAt = GetServerTime and GetServerTime() or time(),
    }
end

local FindHaratiChildQuestByQuestID
local GetHaratiCompletedQuestID
local ResolveTrackedWeeklyQuest

local function FinalizeTrackedWeeklyQuestIfCompleted(questID, sourceTag)
    if not questID then
        return
    end

    local trackedWeeklyQuest, trackedWeeklyTitle = ResolveTrackedWeeklyQuest(questID)
    if not trackedWeeklyQuest then
        return
    end

    local completedQuestID = questID
    local haratiChildQuest = FindHaratiChildQuestByQuestID(questID)
    if haratiChildQuest then
        completedQuestID = GetHaratiCompletedQuestID(haratiChildQuest, questID)
        if not completedQuestID then
            return
        end
        trackedWeeklyTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(completedQuestID) or trackedWeeklyTitle
    else
        local isCompleted = C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(questID)
        if not isCompleted then
            return
        end
    end

    SaveCharacterWeeklyQuestState(trackedWeeklyQuest, "done", completedQuestID, trackedWeeklyTitle)
    if trackedWeeklyQuest.accountWide then
        SaveAccountWideWeeklyQuestState(trackedWeeklyQuest, "done", completedQuestID, trackedWeeklyTitle, sourceTag or "completion_fallback")
    end
end

FindHaratiChildQuestByQuestID = function(questID)
    if not questID then
        return nil
    end
    for i = 2, #(lv.WEEKLY_HARATI_QUESTS or {}) do
        local quest = lv.WEEKLY_HARATI_QUESTS[i]
        if quest then
            if quest.id == questID then
                return quest
            end
            for _, variantID in ipairs(quest.variants or {}) do
                if variantID == questID then
                    return quest
                end
            end
        end
    end
    return nil
end

local function GetHaratiAuthoritativeCompletionQuestIDs(quest)
    local questIDs = {}
    if not quest then
        return questIDs
    end

    if quest.variants and #quest.variants > 0 then
        for _, variantID in ipairs(quest.variants) do
            if variantID then
                table.insert(questIDs, variantID)
            end
        end
    elseif quest.id then
        table.insert(questIDs, quest.id)
    end

    return questIDs
end

local function GetHaratiQuestLogMatch(quest)
    if not (quest and C_QuestLog and C_QuestLog.GetLogIndexForQuestID) then
        return nil, nil
    end

    local candidateIDs = {}
    for _, questID in ipairs(GetHaratiAuthoritativeCompletionQuestIDs(quest)) do
        table.insert(candidateIDs, questID)
    end
    if quest.id then
        table.insert(candidateIDs, quest.id)
    end

    local seen = {}
    for _, questID in ipairs(candidateIDs) do
        if questID and not seen[questID] then
            seen[questID] = true
            if C_QuestLog.GetLogIndexForQuestID(questID) then
                local title = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or quest.name
                return questID, title
            end
        end
    end

    if C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
        local titleSet = BuildTrackedWeeklyQuestTitleSet(quest)
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and titleSet[NormalizeTrackedWeeklyQuestTitle(info.title)] then
                return info.questID or quest.id, info.title or quest.name
            end
        end
    end

    return nil, nil
end

GetHaratiCompletedQuestID = function(quest, preferredQuestID)
    if not (quest and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted) then
        return nil
    end

    local candidateIDs = GetHaratiAuthoritativeCompletionQuestIDs(quest)
    if preferredQuestID then
        local preferredIsAuthoritative = false
        for _, questID in ipairs(candidateIDs) do
            if questID == preferredQuestID then
                preferredIsAuthoritative = true
                break
            end
        end
        if preferredIsAuthoritative then
            table.insert(candidateIDs, 1, preferredQuestID)
        end
    end

    local seen = {}
    for _, questID in ipairs(candidateIDs) do
        if questID and not seen[questID] then
            seen[questID] = true
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                return questID
            end
        end
    end

    return nil
end

local function FindSingleCompletedHaratiChildQuest()
    local matchedQuest, matchedQuestID
    for i = 2, #(lv.WEEKLY_HARATI_QUESTS or {}) do
        local quest = lv.WEEKLY_HARATI_QUESTS[i]
        local completedQuestID = GetHaratiCompletedQuestID(quest)
        if completedQuestID then
            if matchedQuest then
                return nil, nil
            end
            matchedQuest = quest
            matchedQuestID = completedQuestID
        end
    end
    return matchedQuest, matchedQuestID
end

ResolveTrackedWeeklyQuest = function(questID)
    if not questID then return nil, nil end

    local title = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or nil
    local normalizedTitle = NormalizeTrackedWeeklyQuestTitle(title)

    local haratiPool = lv.WEEKLY_HARATI_QUESTS or {}
    local haratiParent = haratiPool[1]
    if haratiParent then
        if haratiParent.id == questID then
            return haratiParent, title
        end
        for i = 2, #haratiPool do
            local quest = haratiPool[i]
            if quest and quest.id == questID then
                return quest, title
            end
            if quest and quest.variants then
                for _, variantID in ipairs(quest.variants) do
                    if variantID == questID then
                        return quest, title
                    end
                end
            end
            if normalizedTitle and quest then
                local titleSet = BuildTrackedWeeklyQuestTitleSet(quest)
                if titleSet[normalizedTitle] then
                    return quest, title
                end
            end
        end
    end

    for _, questPool in ipairs({ lv.WEEKLY_QUESTS or {}, lv.WEEKLY_RITUAL_SITES_QUESTS or {} }) do
        for _, quest in ipairs(questPool) do
            if quest.id == questID then
                return quest, title
            end
            if quest.variants then
                for _, variantID in ipairs(quest.variants) do
                    if variantID == questID then
                        return quest, title
                    end
                end
            end
            if normalizedTitle then
                local titleSet = BuildTrackedWeeklyQuestTitleSet(quest)
                if titleSet[normalizedTitle] then
                    return quest, title
                end
            end
        end
    end

    return nil, title
end

local function SeedAccountWideWeeklyQuestsFromLog()
    if not LiteVaultDB then return end
    LiteVaultDB.accountWideWeeklyQuests = LiteVaultDB.accountWideWeeklyQuests or {}

    for _, questPool in ipairs({ lv.WEEKLY_QUESTS or {}, lv.WEEKLY_RITUAL_SITES_QUESTS or {} }) do
        for _, quest in ipairs(questPool) do
            if quest.accountWide then
                local matchedState, matchedQuestID, matchedTitle

                local function TryQuestID(questID)
                    if not questID or matchedState == "done" then return end
                    if not quest.currentWeekOnly and C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        matchedState = "done"
                        matchedQuestID = questID
                        matchedTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or nil
                        return
                    end
                    if not quest.currentWeekOnly and C_QuestLog.IsQuestFlaggedCompletedOnAccount and C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) then
                        matchedState = "done"
                        matchedQuestID = questID
                        matchedTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or nil
                        return
                    end
                    if not matchedState and C_QuestLog.GetLogIndexForQuestID(questID) then
                        matchedState = "in_progress"
                        matchedQuestID = questID
                        matchedTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or nil
                    end
                end

                TryQuestID(quest.id)
                if quest.variants then
                    for _, variantID in ipairs(quest.variants) do
                        TryQuestID(variantID)
                    end
                end

                if not matchedState then
                    local titleSet = BuildTrackedWeeklyQuestTitleSet(quest)
                    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                        local info = C_QuestLog.GetInfo(i)
                        if info and not info.isHeader and titleSet[NormalizeTrackedWeeklyQuestTitle(info.title)] then
                            matchedState = "in_progress"
                            matchedQuestID = info.questID
                            matchedTitle = info.title
                            break
                        end
                    end
                end

                if matchedState then
                    SaveAccountWideWeeklyQuestState(quest, matchedState, matchedQuestID, matchedTitle, "log_seed")
                end
            end
        end
    end
end

local function SeedAccountWideFactionChoicesFromLog()
    if not LiteVaultDB then return end
    LiteVaultDB.accountWideFactionChoices = LiteVaultDB.accountWideFactionChoices or {}

    for mode, cfg in pairs(lv.ACCOUNT_WIDE_FACTION_CHOICES or {}) do
        if cfg.updateFromLog then
            for _, questID in ipairs(cfg.childIDs) do
                if C_QuestLog.GetLogIndexForQuestID(questID) then
                    SaveAccountWideFactionChoice(mode, questID, "in_progress")
                    break
                end
            end
        end
    end
end

local function SyncHaratiCharacterWeeklyState()
    if not (LiteVaultDB and lv.PLAYER_KEY and C_QuestLog) then return end

    local db = LiteVaultDB[lv.PLAYER_KEY]
    local cfg = lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES.harati
    local quest = lv.WEEKLY_HARATI_QUESTS and lv.WEEKLY_HARATI_QUESTS[1]
    if type(db) ~= "table" or not cfg or not quest then return end

    if db.factionDailiesThisWeek then
        db.factionDailiesThisWeek.harati = nil
    end
    if db.factionParentWeeklies then
        db.factionParentWeeklies.harati = nil
    end

    local parentTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(cfg.parentID) or quest.name
    local currentReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    db.weeklyQuests = db.weeklyQuests or {}

    local saved = db.weeklyQuests[quest.name]
    if saved and saved.questID and saved.questID ~= cfg.parentID then
        local childQuest = FindHaratiChildQuestByQuestID(saved.questID)
        if childQuest then
            local existingChildRecord = db.weeklyQuests[childQuest.name]
            if not existingChildRecord or ((existingChildRecord.updatedAt or 0) < (saved.updatedAt or 0)) then
                db.weeklyQuests[childQuest.name] = {
                    state = saved.state,
                    questID = saved.questID,
                    title = saved.title,
                    updatedAt = saved.updatedAt,
                }
            end
            db.weeklyQuests[quest.name] = nil
            saved = nil
        end
    end

    local childDone = false
    local childInProgress = false
    local activeChildQuestID
    local activeChildTitle

    for i = 2, #(lv.WEEKLY_HARATI_QUESTS or {}) do
        local childQuest = lv.WEEKLY_HARATI_QUESTS[i]
        local childRecord = childQuest and db.weeklyQuests[childQuest.name]
        local childRecordIsCurrent = childRecord and ((not currentReset) or ((childRecord.updatedAt or 0) >= currentReset))
        if childRecord and not childRecordIsCurrent then
            ClearCharacterWeeklyQuestState(childQuest.name)
            childRecord = nil
        end

        local logQuestID, logTitle = GetHaratiQuestLogMatch(childQuest)
        if logQuestID then
            childInProgress = true
            if not activeChildQuestID then
                activeChildQuestID = logQuestID
                activeChildTitle = logTitle
            end
            if not childRecord or childRecord.state ~= "done" then
                SaveCharacterWeeklyQuestState(childQuest, "in_progress", logQuestID, logTitle)
                childRecord = db.weeklyQuests[childQuest.name]
            end
        elseif childRecord then
            if childRecord.state == "in_progress" then
                local completedQuestID = GetHaratiCompletedQuestID(childQuest, childRecord.questID)
                if completedQuestID then
                    local completedTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(completedQuestID) or childQuest.name
                    SaveCharacterWeeklyQuestState(childQuest, "done", completedQuestID, completedTitle)
                    childRecord = db.weeklyQuests[childQuest.name]
                else
                    ClearCharacterWeeklyQuestState(childQuest.name)
                    childRecord = nil
                end
            end
        end

        if childRecord and childRecord.state == "done" then
            childDone = true
        elseif childRecord and childRecord.state == "in_progress" then
            childInProgress = true
        end
    end

    if not childDone and not childInProgress then
        local completedChildQuest, completedChildQuestID = FindSingleCompletedHaratiChildQuest()
        if completedChildQuest and completedChildQuestID then
            local childTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(completedChildQuestID) or completedChildQuest.name
            SaveCharacterWeeklyQuestState(completedChildQuest, "done", completedChildQuestID, childTitle)
            childDone = true
        end
    end

    local parentInLog = C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetLogIndexForQuestID(cfg.parentID)
    if childDone then
        SaveCharacterWeeklyQuestState(quest, "done", cfg.parentID, parentTitle)
    elseif childInProgress or parentInLog then
        SaveCharacterWeeklyQuestState(quest, "in_progress", activeChildQuestID or cfg.parentID, parentTitle)
    else
        ClearCharacterWeeklyQuestState(quest.name)
    end
end

lv.EVENT_CONFIG = {
    -- English keywords
    ["Timewalking"] =   { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["Darkmoon"] =      { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["Dungeon"] =       { r=0, g=1, b=0, order=3, key="dungeon" },
    ["Emissary"] =      { r=0, g=1, b=0, order=3, key="dungeon" },
    ["Battleground"] =  { r=1, g=0, b=0, order=4, key="pvp" },
    ["Skirmish"] =      { r=1, g=0, b=0, order=4, key="pvp" },
    ["Brawl"] =         { r=1, g=0, b=0, order=4, key="pvp" },
    ["Bonus Event"] =   { r=1, g=0.5, b=0, order=5, key="bonus" },
    ["Trial of Style"] = { r=1, g=0.5, b=0, order=5, key="bonus" },
    -- zhTW keywords
    ["時光漫遊"] =       { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["暗月馬戲團"] =     { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["地城"] =          { r=0, g=1, b=0, order=3, key="dungeon" },
    ["戰場"] =          { r=1, g=0, b=0, order=4, key="pvp" },
    ["競技場練習賽"] =   { r=1, g=0, b=0, order=4, key="pvp" },
    ["亂鬥"] =          { r=1, g=0, b=0, order=4, key="pvp" },
    ["獎勵事件"] =       { r=1, g=0.5, b=0, order=5, key="bonus" },
    -- zhCN keywords
    ["时空漫游"] =       { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["暗月马戏团"] =     { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["地下城"] =        { r=0, g=1, b=0, order=3, key="dungeon" },
    ["战场"] =          { r=1, g=0, b=0, order=4, key="pvp" },
    ["竞技场练习赛"] =   { r=1, g=0, b=0, order=4, key="pvp" },
    ["乱斗"] =          { r=1, g=0, b=0, order=4, key="pvp" },
    ["奖励事件"] =       { r=1, g=0.5, b=0, order=5, key="bonus" },
    -- Korean keywords
    ["시간여행"] =       { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["다크문"] =        { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["던전"] =          { r=0, g=1, b=0, order=3, key="dungeon" },
    ["전장"] =          { r=1, g=0, b=0, order=4, key="pvp" },
    ["투기장 연습"] =    { r=1, g=0, b=0, order=4, key="pvp" },
    ["난투"] =          { r=1, g=0, b=0, order=4, key="pvp" },
    ["보너스 이벤트"] =  { r=1, g=0.5, b=0, order=5, key="bonus" },
    -- German keywords
    ["Zeitwanderung"] = { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["Dunkelmond"] =    { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["Schlachtfeld"] =  { r=1, g=0, b=0, order=4, key="pvp" },
    ["Rauferei"] =      { r=1, g=0, b=0, order=4, key="pvp" },
    ["Bonusereignis"] = { r=1, g=0.5, b=0, order=5, key="bonus" },
    -- French keywords
    ["Marcheur du temps"] = { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["Sombrelune"] =    { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["Donjon"] =        { r=0, g=1, b=0, order=3, key="dungeon" },
    ["Champ de bataille"] = { r=1, g=0, b=0, order=4, key="pvp" },
    ["Bagarre"] =       { r=1, g=0, b=0, order=4, key="pvp" },
    -- Spanish keywords
    ["Paseo en el tiempo"] = { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["Feria de la Luna Negra"] = { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["Mazmorra"] =      { r=0, g=1, b=0, order=3, key="dungeon" },
    ["Campo de batalla"] = { r=1, g=0, b=0, order=4, key="pvp" },
    ["Reyerta"] =       { r=1, g=0, b=0, order=4, key="pvp" },
    -- Portuguese keywords
    ["Caminhada Temporal"] = { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["Feira de Negraluna"] = { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["Masmorra"] =      { r=0, g=1, b=0, order=3, key="dungeon" },
    ["Campo de Batalha"] = { r=1, g=0, b=0, order=4, key="pvp" },
    ["Briga"] =         { r=1, g=0, b=0, order=4, key="pvp" },
    -- Russian keywords
    ["Путешествие во времени"] = { r=0, g=0.7, b=1, order=1, key="timewalking" },
    ["Ярмарка Новолуния"] = { r=0.6, g=0, b=0.8, order=2, key="darkmoon" },
    ["Подземелье"] =    { r=0, g=1, b=0, order=3, key="dungeon" },
    ["Поле боя"] =      { r=1, g=0, b=0, order=4, key="pvp" },
    ["Потасовка"] =     { r=1, g=0, b=0, order=4, key="pvp" },
}

-- ==========================================================
-- REGION-AWARE WEEKLY RESET SYSTEM
-- ==========================================================
-- US (Region 1): Tuesday 15:00 UTC
-- EU (Region 3): Wednesday 04:00 UTC
-- KR/TW (Regions 2/4): Thursday realm-time reset window (UTC Wed 23:00)

-- Calculate the next weekly reset timestamp based on region
function lv.GetNextWeeklyReset()
    local region = GetCurrentRegion()
    local now = GetServerTime()

    -- Get current UTC time components
    local utcDate = date("!*t", now)

    -- Determine reset day and hour based on region
    local resetDayOfWeek, resetHourUTC
    if region == 3 then
        -- EU: Wednesday (4) at 04:00 UTC
        resetDayOfWeek = 4
        resetHourUTC = 4
    elseif region == 2 or region == 4 then
        -- KR/TW: Thursday realm-time window (UTC Wednesday 23:00)
        resetDayOfWeek = 4
        resetHourUTC = 23
    else
        -- US/default: Tuesday (3) at 15:00 UTC
        resetDayOfWeek = 3
        resetHourUTC = 15
    end

    -- Calculate days until next reset
    local currentDayOfWeek = utcDate.wday -- Sunday = 1, Monday = 2, etc.
    local daysUntilReset = (resetDayOfWeek - currentDayOfWeek) % 7

    -- If it's reset day, check if reset has already happened today
    if daysUntilReset == 0 then
        if utcDate.hour >= resetHourUTC then
            -- Reset already happened today, next reset is in 7 days
            daysUntilReset = 7
        end
    end

    -- Calculate reset timestamp
    local resetTime = now + (daysUntilReset * 86400) -- Add days
    local resetDate = date("!*t", resetTime)

    -- Set to exact reset hour (midnight + reset hour)
    resetTime = resetTime - (resetDate.hour * 3600) - (resetDate.min * 60) - resetDate.sec
    resetTime = resetTime + (resetHourUTC * 3600)

    return resetTime
end

-- Get the most recent reset timestamp (for checking if reset just happened)
function lv.GetLastWeeklyReset()
    local nextReset = lv.GetNextWeeklyReset()
    return nextReset - (7 * 86400) -- Subtract 7 days
end

-- Calculate seconds until next daily reset (same hour as weekly reset, but daily)
function lv.GetSecondsUntilDailyReset()
    local region = GetCurrentRegion()
    local now = GetServerTime()
    local utcDate = date("!*t", now)

    -- Daily reset hour matches weekly reset hour
    local resetHourUTC
    if region == 3 then
        resetHourUTC = 4  -- EU: 04:00 UTC
    elseif region == 2 or region == 4 then
        resetHourUTC = 23 -- KR/TW: Asia reset window in UTC (07:00/08:00 local)
    else
        resetHourUTC = 15 -- US: 15:00 UTC
    end

    -- Calculate seconds until next reset hour
    local currentSeconds = utcDate.hour * 3600 + utcDate.min * 60 + utcDate.sec
    local resetSeconds = resetHourUTC * 3600

    local secondsUntil = resetSeconds - currentSeconds
    if secondsUntil <= 0 then
        -- Reset already happened today, next one is tomorrow
        secondsUntil = secondsUntil + 86400
    end

    return secondsUntil
end

-- 3. DATA FUNCTIONS
function lv.ScanBags()
    if not LiteVaultDB or not lv.PLAYER_KEY then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if not db then return end

    local scannedBags = {}
    local scannedTotalSlots = 0
    local scannedUsedSlots = 0

    local bagIDs = {}
    for i = 0, NUM_BAG_SLOTS do
        bagIDs[#bagIDs + 1] = i
    end
    local reagentBag = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag
    if reagentBag and reagentBag > NUM_BAG_SLOTS then
        bagIDs[#bagIDs + 1] = reagentBag
    end

    for _, bagID in ipairs(bagIDs) do
        local numSlots = C_Container.GetContainerNumSlots(bagID) or 0
        scannedTotalSlots = scannedTotalSlots + numSlots
        for slotID = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(bagID, slotID)
            if info then
                local itemID = info.itemID or (info.hyperlink and GetItemInfoInstant(info.hyperlink))
                local itemName = info.itemName
                    or (itemID and C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID))
                    or UNKNOWN
                scannedUsedSlots = scannedUsedSlots + 1
                table.insert(scannedBags, {
                    name = itemName,
                    count = info.stackCount,
                    icon = info.iconFileID,
                    quality = info.quality,
                    link = info.hyperlink,
                    craftingQuality = (C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo and info.hyperlink)
                        and C_TradeSkillUI.GetItemReagentQualityByItemInfo(info.hyperlink) or nil,
                })
            end
        end
    end

    db.bags = scannedBags
    db.bagTotalSlots = scannedTotalSlots
    db.bagUsedSlots = scannedUsedSlots
    db.bagLastScanned = time()
end

local GEAR_SLOT_IDS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }

function lv.ScanGear()
    if not LiteVaultDB or not lv.PLAYER_KEY then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if not db then return end

    local scannedGear = {}

    for _, slotID in ipairs(GEAR_SLOT_IDS) do
        local itemLink = GetInventoryItemLink("player", slotID)
        local itemID = itemLink and GetItemInfoInstant(itemLink) or nil
        local itemName, itemQuality, itemIcon

        if itemLink then
            itemName = GetItemInfo(itemLink)
            itemQuality = select(3, GetItemInfo(itemLink))
            itemIcon = GetInventoryItemTexture("player", slotID)

            if not itemName and itemID and C_Item and C_Item.GetItemNameByID then
                itemName = C_Item.GetItemNameByID(itemID)
            end
            if not itemQuality and itemID and C_Item and C_Item.GetItemQualityByID then
                itemQuality = C_Item.GetItemQualityByID(itemID)
            end
            if not itemIcon and itemID and C_Item and C_Item.GetItemIconByID then
                itemIcon = C_Item.GetItemIconByID(itemID)
            end
        end

        scannedGear[#scannedGear + 1] = {
            slotID = slotID,
            link = itemLink,
            itemID = itemID,
            name = itemName,
            icon = itemIcon,
            quality = itemQuality,
            itemLevel = itemLink and GetItemLevelFromLink(itemLink) or nil,
        }
    end

    db.gear = scannedGear
    db.gearLastScanned = time()
end

local function BuildContainerItems(containerIDs)
    local scannedItems = {}
    local scannedTotalSlots = 0
    local scannedUsedSlots = 0

    for _, containerID in ipairs(containerIDs) do
        local numSlots = C_Container.GetContainerNumSlots(containerID) or 0
        scannedTotalSlots = scannedTotalSlots + numSlots
        for slotID = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(containerID, slotID)
            if info then
                local itemID = info.itemID or (info.hyperlink and GetItemInfoInstant(info.hyperlink))
                local itemName = info.itemName
                    or (itemID and C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID))
                    or UNKNOWN
                scannedUsedSlots = scannedUsedSlots + 1
                table.insert(scannedItems, {
                    name = itemName,
                    count = info.stackCount,
                    icon = info.iconFileID,
                    quality = info.quality,
                    link = info.hyperlink,
                    craftingQuality = (C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo and info.hyperlink)
                        and C_TradeSkillUI.GetItemReagentQualityByItemInfo(info.hyperlink) or nil,
                })
            end
        end
    end

    return scannedItems, scannedTotalSlots, scannedUsedSlots
end

local function CaptureCurrentPlayerCombatStats()
    local critRating = (GetCombatRating and _G.CR_CRIT_MELEE) and (GetCombatRating(_G.CR_CRIT_MELEE) or 0) or 0
    local hasteRating = (GetCombatRating and _G.CR_HASTE_MELEE) and (GetCombatRating(_G.CR_HASTE_MELEE) or 0) or 0
    local masteryRating = (GetCombatRating and _G.CR_MASTERY) and (GetCombatRating(_G.CR_MASTERY) or 0) or 0
    local versRating = (GetCombatRating and _G.CR_VERSATILITY_DAMAGE_DONE) and (GetCombatRating(_G.CR_VERSATILITY_DAMAGE_DONE) or 0) or 0

    local critPercent = (GetCritChance and GetCritChance()) or 0
    local hastePercent = (GetHaste and GetHaste()) or 0
    local masteryPercent = (GetMasteryEffect and GetMasteryEffect()) or 0
    local versPercent = (GetCombatRatingBonus and _G.CR_VERSATILITY_DAMAGE_DONE) and (GetCombatRatingBonus(_G.CR_VERSATILITY_DAMAGE_DONE) or 0) or 0

    return {
        critRating = critRating,
        critPercent = critPercent,
        hasteRating = hasteRating,
        hastePercent = hastePercent,
        masteryRating = masteryRating,
        masteryPercent = masteryPercent,
        versRating = versRating,
        versPercent = versPercent,
    }
end

local function CaptureCurrentOmniumFolioSnapshot()
    if not (C_Traits and C_Traits.GetConfigIDBySystemID and C_Traits.GetTreeNodes and C_Traits.GetNodeInfo) then
        return nil
    end

    local configID = C_Traits.GetConfigIDBySystemID(48)
    if not configID or configID <= 0 then
        return nil
    end

    local treeNodes = C_Traits.GetTreeNodes(1186)
    if type(treeNodes) ~= "table" or #treeNodes == 0 then
        return nil
    end

    local availablePoints = 0
    if C_Traits.GetTreeCurrencyInfo then
        local treeCurrencies = C_Traits.GetTreeCurrencyInfo(configID, 1186, false)
        local info = treeCurrencies and treeCurrencies[1]
        availablePoints = (info and info.quantity) or 0
    end

    local selectedNodes = {}
    local spentPoints = 0

    for _, nodeID in ipairs(treeNodes) do
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
        if nodeInfo then
            local rank = tonumber(nodeInfo.currentRank or nodeInfo.ranksPurchased or 0) or 0
            local entryID

            if nodeInfo.activeEntry and nodeInfo.activeEntry.entryID then
                entryID = nodeInfo.activeEntry.entryID
            elseif type(nodeInfo.entryIDsWithCommittedRanks) == "table" and nodeInfo.entryIDsWithCommittedRanks[1] then
                local committedEntry = nodeInfo.entryIDsWithCommittedRanks[1]
                entryID = type(committedEntry) == "table" and committedEntry.entryID or committedEntry
            elseif rank > 0 and type(nodeInfo.entryIDs) == "table" then
                entryID = nodeInfo.entryIDs[1]
            end

            if entryID and rank > 0 then
                local entryInfo = C_Traits.GetEntryInfo and C_Traits.GetEntryInfo(configID, entryID)
                local definitionInfo = entryInfo and entryInfo.definitionID and C_Traits.GetDefinitionInfo and C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                local spellID = definitionInfo and definitionInfo.spellID or nil
                local nodeName = definitionInfo and definitionInfo.overrideName or nil
                local nodeIcon = definitionInfo and (definitionInfo.overrideIcon or definitionInfo.icon) or nil

                if not nodeName and spellID then
                    if C_Spell and C_Spell.GetSpellName then
                        nodeName = C_Spell.GetSpellName(spellID)
                    elseif GetSpellInfo then
                        nodeName = GetSpellInfo(spellID)
                    end
                end
                if not nodeIcon and spellID then
                    if C_Spell and C_Spell.GetSpellTexture then
                        nodeIcon = C_Spell.GetSpellTexture(spellID)
                    elseif GetSpellTexture then
                        nodeIcon = GetSpellTexture(spellID)
                    end
                end

                selectedNodes[#selectedNodes + 1] = {
                    nodeID = nodeID,
                    entryID = entryID,
                    rank = rank,
                    name = nodeName or string.format("Node %d", nodeID),
                    icon = nodeIcon,
                    posX = nodeInfo.posX,
                    posY = nodeInfo.posY,
                    spellID = spellID,
                }
                spentPoints = spentPoints + rank
            end
        end
    end

    return {
        systemID = 48,
        treeID = 1186,
        savedAt = time(),
        availablePoints = availablePoints,
        spentPoints = spentPoints,
        selectedNodeCount = #selectedNodes,
        totalNodeCount = #treeNodes,
        selectedNodes = selectedNodes,
    }
end

function lv.ScanBank()
    if not LiteVaultDB or not lv.PLAYER_KEY then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if not db then return end

    local containerIDs = { 6, 7, 8, 9, 10, 11 }
    local items, totalSlots, usedSlots = BuildContainerItems(containerIDs)
    db.bank = items
    db.bankTotalSlots = totalSlots
    db.bankUsedSlots = usedSlots
    db.bankLastScanned = time()
end

function lv.ScanWarbandBank()
    if not LiteVaultDB then return end
    LiteVaultDB["Warband Bank"] = LiteVaultDB["Warband Bank"] or { gold = 0, class = "Bank", transactions = {}, region = lv.REGION }
    local db = LiteVaultDB["Warband Bank"]

    local containerIDs = { 12, 13, 14, 15, 16 }
    local items, totalSlots, usedSlots = BuildContainerItems(containerIDs)
    db.items = items
    db.totalSlots = totalSlots
    db.usedSlots = usedSlots
    db.lastScanned = time()
end

function lv.UpdateCurrentCharData()
    -- WEEKLY RESET CHECK - Wipe raid lockout data after region-specific reset
    if not LiteVaultDB then LiteVaultDB = {} end

    local regionResetKey = "lastRaidReset_" .. lv.REGION

    -- One-time migration: legacy single-key reset stamp -> active regional key
    if LiteVaultDB.lastRaidReset and not LiteVaultDB[regionResetKey] then
        LiteVaultDB[regionResetKey] = LiteVaultDB.lastRaidReset
        LiteVaultDB.lastRaidReset = nil
    end

    local lastResetTime = lv.GetLastWeeklyReset()

    -- Check if a reset has occurred since we last tracked
    if not LiteVaultDB[regionResetKey] or LiteVaultDB[regionResetKey] < lastResetTime then
        -- Reset has occurred! Wipe all raid lockout data
        for charKey, charData in pairs(LiteVaultDB) do
            if type(charData) == "table" and (not charData.region or charData.region == lv.REGION) then
                charData.factionDailiesThisWeek = nil
                if charData.weeklyPlanner then
                    for _, entry in ipairs(charData.weeklyPlanner) do
                        if type(entry) == "table" then
                            entry.checked = false
                        end
                    end
                end
                if charData.raidLockouts then
                    charData.raidLockouts = nil
                end
            end
        end
        LiteVaultDB.accountWideFactionChoices = nil
        LiteVaultDB.accountWideWeeklyQuests = nil
        LiteVaultDB.permanentFactionCompletions = nil
        LiteVaultDB[regionResetKey] = lastResetTime
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. L["MSG_WEEKLY_RESET"])
    end
    
    local d = date("*t")
    -- Check if user declined tracking for this character
    local declined = LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[lv.PLAYER_KEY]

    -- Only update data if character exists and hasn't been declined
    if LiteVaultDB[lv.PLAYER_KEY] and not LiteVaultDB[lv.PLAYER_KEY].isIgnored and not declined then
        local db = LiteVaultDB[lv.PLAYER_KEY]
        db.gold = GetMoney(); db.class = select(2, UnitClass("player"))
        db.level = UnitLevel("player") or db.level or 0
        db.region = lv.REGION
        db.weeklyPlanner = db.weeklyPlanner or {
            { text = "", checked = false },
            { text = "", checked = false },
            { text = "", checked = false },
            { text = "", checked = false },
            { text = "", checked = false },
            { text = "", checked = false },
        }
        if lv.ScanTeleports then lv.ScanTeleports() end
        local _, equipped = GetAverageItemLevel(); db.ilvl = math.floor(equipped)
        db.combatStats = CaptureCurrentPlayerCombatStats()
        local folioSnapshot = CaptureCurrentOmniumFolioSnapshot()
        if folioSnapshot then
            db.omniumFolio = folioSnapshot
        end
        local currentMPlusSeason = C_MythicPlus and C_MythicPlus.GetCurrentSeason and C_MythicPlus.GetCurrentSeason() or nil
        local liveMPlusScore = C_ChallengeMode.GetOverallDungeonScore() or 0
        if currentMPlusSeason and db.mplusSeason and db.mplusSeason ~= currentMPlusSeason then
            db.mplus = 0
        else
            db.mplus = liveMPlusScore
        end
        db.mplusSeason = currentMPlusSeason or db.mplusSeason
        
        -- NEW: Save portrait info for cross-character viewing
        local race = UnitRace("player")
        local gender = UnitSex("player") -- 2=male, 3=female
        db.race = race
        db.gender = gender
        local specIndex = GetSpecialization and GetSpecialization() or nil
        if specIndex and GetSpecializationInfo then
            local _, specName = GetSpecializationInfo(specIndex)
            db.specName = specName
        else
            db.specName = nil
        end

        -- One-time migration seed for Silvermoon per-character weekly tracking.
        -- This restores already-completed current-character quests after the tracker
        -- moved off Blizzard's permanent completion flags.
        db.factionDailiesThisWeek = db.factionDailiesThisWeek or {}
        db.factionDailiesMigrated = db.factionDailiesMigrated or {}
        if not db.factionDailiesMigrated.silvermoon then
            local cfg = lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES.silvermoon
            if cfg and cfg.trackDailiesPerChar then
                db.factionDailiesThisWeek.silvermoon = db.factionDailiesThisWeek.silvermoon or {}
                for _, questID in ipairs(cfg.childIDs) do
                    if not (cfg.subFactionLookup and cfg.subFactionLookup[questID]) and C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        db.factionDailiesThisWeek.silvermoon[questID] = true
                    end
                end
                local savedChoice = LiteVaultDB.accountWideFactionChoices and LiteVaultDB.accountWideFactionChoices.silvermoon
                if savedChoice and savedChoice.state == "done" and savedChoice.sourceKey == lv.PLAYER_KEY then
                    if savedChoice.questID then
                        db.factionDailiesThisWeek.silvermoon[savedChoice.questID] = true
                    end
                end
            end
            db.factionDailiesMigrated.silvermoon = true
        end
        do
            local cfg = lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES.silvermoon
            local savedChoice = LiteVaultDB.accountWideFactionChoices and LiteVaultDB.accountWideFactionChoices.silvermoon
            if cfg and cfg.trackDailiesPerChar and savedChoice and savedChoice.state == "done" and savedChoice.sourceKey == lv.PLAYER_KEY then
                db.factionDailiesThisWeek.silvermoon = db.factionDailiesThisWeek.silvermoon or {}
                if savedChoice.questID then
                    db.factionDailiesThisWeek.silvermoon[savedChoice.questID] = true
                end
            end
        end
        do
            local cfg = lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES.harati
            if cfg then
                if LiteVaultDB.accountWideFactionChoices then
                    LiteVaultDB.accountWideFactionChoices.harati = nil
                end
                SyncHaratiCharacterWeeklyState()
            end
        end
        SeedAccountWideWeeklyQuestsFromLog()
        SeedAccountWideFactionChoicesFromLog()
        -- NEW: Track current M+ key in inventory
        db.currentKey = nil
        
        -- Use the proper M+ API to get keystone info
        local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
        local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()
        
        if mapID and keyLevel then
            local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
            
            -- If map name isn't loaded, try getting it from map info
            if not mapName or mapName == "" then
                local mapInfo = C_Map.GetMapInfo(mapID)
                if mapInfo then
                    mapName = mapInfo.name
                end
            end
            
            if mapName and mapName ~= "" then
                db.currentKey = {name = mapName, level = keyLevel}
            end
        end
        
        -- Track highest Midnight delve tier completed via achievements.
        local MIDNIGHT_DELVE_ACHIEVEMENTS = {
            [1] = 61832, [2] = 61835, [3] = 61836,
            [4] = 61800, [5] = 61801, [6] = 61802, [7] = 61803,
            [8] = 61804, [9] = 61805, [10] = 61806, [11] = 61807
        }
        db.delveProgress = 0
        for tier = 11, 1, -1 do
            local _, _, _, completed = GetAchievementInfo(MIDNIGHT_DELVE_ACHIEVEMENTS[tier])
            if completed then
                db.delveProgress = tier
                break
            end
        end
        
        -- Midnight-only spark tracking (Spark of Radiance; no fractured sparks).
        db.sparks = 0
        db.fullSparks = GetItemCount(232875, true) or 0
        db.fracturedSparks = 0
        db.ascendantVoidshards = GetItemCount(lv.ASCENDANT_VOIDSHARD_ITEM_ID, true) or 0
        db.ascendantVoidcores = GetItemCount(lv.ASCENDANT_VOIDCORE_ITEM_ID, true) or 0
        
        -- NEW: Update last activity timestamp
        db.lastActiveTimestamp = time()

        -- NEW: Track professions using GetProfessions() API
        db.professions = {}
        local prof1, prof2 = GetProfessions() -- Returns indices for primary professions

        if prof1 then
            local name, icon, skillLevel, maxSkillLevel = GetProfessionInfo(prof1)
            if name and name ~= "" then
                table.insert(db.professions, {
                    name = name,
                    icon = icon,
                    skillLevel = skillLevel or 0,
                    maxSkillLevel = maxSkillLevel or 0
                })
            end
        end

        if prof2 then
            local name, icon, skillLevel, maxSkillLevel = GetProfessionInfo(prof2)
            if name and name ~= "" then
                table.insert(db.professions, {
                    name = name,
                    icon = icon,
                    skillLevel = skillLevel or 0,
                    maxSkillLevel = maxSkillLevel or 0
                })
            end
        end

        -- Raid Progression Logic (uses persistent raidProgression data, not current lockouts)
        -- Shows the highest difficulty with any kills (prioritizes M > H > N)
        db.raid = (function()
            if not db.raidProgression then return "" end

            -- Check difficulties in order: Mythic, Heroic, Normal
            for _, diff in ipairs(lv.RAID_DIFFS) do
                local prog = db.raidProgression[diff.id]
                if prog and prog.killCount and prog.killCount > 0 then
                    local raidBossCount = (lv.GetCurrentRaidBossCount and lv.GetCurrentRaidBossCount()) or lv.NUM_RAID_BOSSES or 8
                    return string.format("|c%s[%d/%dP %s]|r", diff.col, prog.killCount, raidBossCount, diff.tag)
                end
            end
            return ""
        end)()
        
        db.lastActive = string.format("%d-%d-%d", d.year, d.month, d.day)
        
        -- Live Time Calculation (No Spam)
        if lv.sessionRefTime and lv.sessionRefValue then
            db.played = lv.sessionRefValue + (GetTime() - lv.sessionRefTime)
        end
        
        local catInfo = C_CurrencyInfo.GetCurrencyInfo(lv.CATALYST_ID)
        db.catalyst = (catInfo and catInfo.quantity) or 0

        db.currencies = db.currencies or {}
        local count = C_CurrencyInfo.GetCurrencyListSize()
        for i = 1, count do
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if info and not info.isHeader and lv.CURRENCY_KEYWORDS[info.name] then
                db.currencies[info.name] = { amount = info.quantity, icon = info.iconFileID }
            end
        end
        
        for id, name in pairs(lv.FORCE_IDS) do
            local info = C_CurrencyInfo.GetCurrencyInfo(id)
            if info then
                db.currencies[name] = { amount = info.quantity, icon = info.iconFileID }
            end
        end
        
        -- ==========================================================
        -- REGION-AWARE WEEKLY RESET LOGIC
        -- US (Region 1): Tuesday 15:00 UTC
        -- EU (Region 3): Wednesday 04:00 UTC
        -- ==========================================================

        local currentMonthKey = string.format("%04d-%02d", d.year, d.month)

        -- Check if reset has occurred since last recorded reset
        local needsGlobalReset = false
        if not db.lastWeeklyReset then
            -- First time setup for NEW character - only initialize THIS character
            db.lastWeeklyReset = lastResetTime
            db.lastMonthlyReset = currentMonthKey
            db.weeklyQuests = {}
            db.factionParentWeeklies = nil
            db.vR, db.vM, db.vW = 0, 0, 0
            db.vaultDetails = nil
            -- Don't trigger global reset for new characters!
        elseif db.lastWeeklyReset < lastResetTime then
            -- A weekly reset has ACTUALLY occurred since we last logged
            needsGlobalReset = true
        end

        if needsGlobalReset then
            -- Reset ALL characters' weekly tracking (only on actual weekly reset)
            for charKey, charData in pairs(LiteVaultDB) do
                if type(charData) == "table" and charData.class
                    and (not charData.region or charData.region == lv.REGION) then
                    charData.lastWeeklyReset = lastResetTime
                    charData.weeklyQuests = {}
                    charData.factionParentWeeklies = nil
                    charData.vR, charData.vM, charData.vW = 0, 0, 0
                    charData.vaultDetails = nil
                    if charData.weeklyPlanner then
                        for _, entry in ipairs(charData.weeklyPlanner) do
                            if type(entry) == "table" then
                                entry.checked = false
                            end
                        end
                    end
                end
            end
            LiteVaultDB.accountWideWeeklyQuests = nil
            LiteVaultDB.accountWideFactionChoices = nil
        end

        local needsMonthlyReset = db.lastMonthlyReset ~= currentMonthKey
        if needsMonthlyReset then
            for charKey, charData in pairs(LiteVaultDB) do
                if type(charData) == "table" and charData.class
                    and (not charData.region or charData.region == lv.REGION) then
                    charData.lastMonthlyReset = currentMonthKey
                end
            end
        end

        -- ==========================================================
        
        local acts = C_WeeklyRewards.GetActivities and C_WeeklyRewards.GetActivities() or nil
        local vaultSnapshot = lv.BuildVaultSnapshotFromActivities(acts)
        if lv.ReconcileVaultSnapshotItemLevels then
            vaultSnapshot = lv.ReconcileVaultSnapshotItemLevels(vaultSnapshot, db.vaultDetails)
        end
        db.vR = vaultSnapshot.raid.slots or 0
        db.vM = vaultSnapshot.mythic.slots or 0
        db.vW = vaultSnapshot.delve.slots or 0
        db.vaultDetails = vaultSnapshot
        db.vaultDetails.savedAt = time()
    end
end

-- 4. SLASH COMMANDS
SLASH_LITEVAULT1 = "/lv"
SlashCmdList["LITEVAULT"] = function() 
    if LiteVaultWindow then 
        lv.UpdateCurrentCharData()
        lv.UpdateUI()
        LiteVaultWindow:Show()
    end 
end

-- Note: /lvreset is defined at the bottom of the file with full functionality

-- Add Current Character Command
SLASH_LITEVAULTADD1 = "/lvadd"
SlashCmdList["LITEVAULTADD"] = function()
    if LiteVaultDB[lv.PLAYER_KEY] then
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. L["MSG_ALREADY_TRACKED"])
    else
        -- Clear declined flag if it exists
        if LiteVaultDB.declinedCharacters then
            LiteVaultDB.declinedCharacters[lv.PLAYER_KEY] = nil
        end
        if not LiteVaultDB[lv.PLAYER_KEY] then LiteVaultDB[lv.PLAYER_KEY] = {} end
        lv.UpdateCurrentCharData()
        if lv.UpdateUI then lv.UpdateUI() end
        local name = UnitName("player")
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. string.format(L["MSG_CHAR_ADDED"], name))
    end
end

-- Raid Resync Command (launch recovery)
-- Forces a fresh raid info pull and reconciles lockouts/progression from API data.
SLASH_LITEVAULTRAIDRESYNC1 = "/lvraidresync"
SlashCmdList["LITEVAULTRAIDRESYNC"] = function()
    if not lv or not lv.ScanRaidInfoPanel then
        print("|cff9933ff" .. (L["MSG_PREFIX"] or "LiteVault") .. "|r " .. (L["MSG_RAID_RESYNC_UNAVAILABLE"] or "Raid resync unavailable."))
        return
    end

    local prefix = "|cff9933ff" .. (L["MSG_PREFIX"] or "LiteVault") .. "|r "
    print(prefix .. (L["MSG_RAID_RESYNC_STARTED"] or "Raid resync started..."))

    if RequestRaidInfo then
        RequestRaidInfo()
    end

    C_Timer.After(0.6, function()
        if not lv or not lv.ScanRaidInfoPanel then return end
        lv.ScanRaidInfoPanel()
        if lv.UpdateRaidLockoutGrid then
            lv.UpdateRaidLockoutGrid()
        end
        if lv.UpdateUI then
            lv.UpdateUI()
        end
        print(prefix .. (L["MSG_RAID_RESYNC_COMPLETE"] or "Raid resync complete."))
    end)
end

-- 5. EVENT HANDLING

-- Time played message suppression
-- Uses both event unregistration AND a chat filter for maximum compatibility
-- The chat filter uses localized global strings to work across all locales
local playedWindowsRegistered = {}
local timePlayedFilterActive = false
local timePlayedTouchedNIT = false
local initialTimePlayedNoticeShown = false
-- Set when we silently auto-activate suppression during load so we can
-- show a single confirmation later when the user-visible flow runs.
local silentAutoActivated = false

-- Optional debug logger for time-played suppression/restore flows.
local function TimePlayedDebugLog(action, info)
    if not (LiteVaultDB and LiteVaultDB.debugTimePlayed) then return end
    LiteVaultDB.timePlayedDebug = LiteVaultDB.timePlayedDebug or {}
    table.insert(LiteVaultDB.timePlayedDebug, 1, { ts = GetServerTime(), action = action, info = info })
    while #LiteVaultDB.timePlayedDebug > 200 do
        table.remove(LiteVaultDB.timePlayedDebug)
    end
end

-- Chat filter function that uses localized global strings
local function TimePlayedChatFilter(self, event, msg, ...)
    -- Accept either explicit activation OR saved setting (covers timing differences
    -- where the saved variables may already request suppression on some clients).
    if not (timePlayedFilterActive or (LiteVaultDB and LiteVaultDB.disableTimePlayed)) then return false end
    if not msg then return false end

    local function StartsWith(text, prefix)
        return type(text) == "string" and type(prefix) == "string" and prefix ~= "" and text:sub(1, #prefix) == prefix
    end

    -- Normalize punctuation/spacing variants across locales (notably zh clients).
    -- This makes matching resilient to full-width vs ASCII punctuation differences.
    local normMsg = msg
    normMsg = normMsg:gsub("：", ":"):gsub("，", ","):gsub("%s+", " ")

    -- Prefer simple, locale-safe prefix matching using the localized format strings
    local function StripFormatPlaceholder(fmt)
        if not fmt then return nil end
        return fmt:gsub("%%s", "")
    end

    local totalPrefix = StripFormatPlaceholder(TIME_PLAYED_TOTAL)
    local levelPrefix = StripFormatPlaceholder(TIME_PLAYED_LEVEL)

    -- Plain (exact) prefix check is more robust than complex patterns across locales
    if totalPrefix and (StartsWith(msg, totalPrefix) or StartsWith(normMsg, totalPrefix)) then
        return true
    end
    if levelPrefix and (StartsWith(msg, levelPrefix) or StartsWith(normMsg, levelPrefix)) then
        return true
    end

    -- Locale-specific fallback prefixes for clients where the global format
    -- may differ (e.g. zhTW uses different wording / punctuation).
    local locale = GetLocale() or "enUS"
    local localeFallbacks = {
        zhTW = { "總遊戲時間", "遊戲時間", "已遊玩", "等級遊戲時間", "本等級遊戲時間", "你在這個等級的遊戲時間" },
        zhCN = { "总游戏时间", "游戏时间", "已游玩", "等级游戏时间", "本等级游戏时间", "你在这个等级的游戏时间" },
    }
    -- Explicit prefixes reported by users (Traditional/Simplified Chinese variants).
    local noSpaceMsg = normMsg:gsub("%s+", "")
    if normMsg:find("^總遊戲時間", 1, true) or normMsg:find("^你在這個等級的遊戲時間", 1, true)
        or normMsg:find("^总游戏时间", 1, true) or normMsg:find("^你在这个等级的游戏时间", 1, true)
        or noSpaceMsg:find("^總遊戲時間", 1, true) or noSpaceMsg:find("^你在這個等級的遊戲時間", 1, true)
        or noSpaceMsg:find("^总游戏时间", 1, true) or noSpaceMsg:find("^你在这个等级的游戏时间", 1, true) then
        return true
    end

    local function checkPrefixes(prefixes)
        if not prefixes then return false end
        for _, p in ipairs(prefixes) do
            if type(p) == "string" and p ~= "" then
                -- Check plain prefix and common colon variants (ASCII and fullwidth)
                if StartsWith(msg, p) or StartsWith(normMsg, p) then return true end
                if StartsWith(msg, p .. ":") or StartsWith(normMsg, p .. ":") then return true end
                if msg:find("^" .. p .. "：", 1, true) or normMsg:find("^" .. p .. ":", 1, true) then return true end
            end
        end
        return false
    end

    if checkPrefixes(localeFallbacks[locale]) then return true end

    -- Keep suppression strict to known played-time prefixes only.
    -- Do not use broad time-pattern matching here; it can hide unrelated system messages.

    return false
end

-- Register the chat filter once at load time
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TimePlayedChatFilter)
ChatFrame_AddMessageEventFilter("TIME_PLAYED_MSG", TimePlayedChatFilter)

function lv.SuppressTimePlayedChat(silent)
    local wasActive = timePlayedFilterActive
    -- Enable our chat filter
    timePlayedFilterActive = true

    -- If NovaInstanceTracker is loaded, it handles its own suppression
    if NIT and NIT.unregisterTimePlayedMsg then
        NIT:unregisterTimePlayedMsg()
        timePlayedTouchedNIT = true
    end

    -- Also unregister event from chat frames as backup
    playedWindowsRegistered = playedWindowsRegistered or {}
    local function attemptUnregister()
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G['ChatFrame' .. i]
            if chatFrame and chatFrame:IsEventRegistered("TIME_PLAYED_MSG") then
                chatFrame:UnregisterEvent("TIME_PLAYED_MSG")
                playedWindowsRegistered[i] = true
            end
        end
    end

    -- Run immediate unregister and schedule retries to cover clients/addons
    attemptUnregister()
    if lv.timePlayedSuppressTicker then
        lv.timePlayedSuppressTicker:Cancel()
        lv.timePlayedSuppressTicker = nil
    end
    local attempts = 0
    lv.timePlayedSuppressTicker = C_Timer.NewTicker(0.5, function()
        attempts = attempts + 1
        attemptUnregister()
        -- After several attempts, give up and prompt for reload if still failing
        if attempts >= 6 then
            if lv.timePlayedSuppressTicker then
                lv.timePlayedSuppressTicker:Cancel()
                lv.timePlayedSuppressTicker = nil
            end
            -- If after retries some clients still show the message, suggest reload
            if not silent then
                print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. L["MSG_RELOAD_TIMEPLAYED"])
                -- Show the standard reload UI popup once
                if StaticPopup_Show then
                    StaticPopup_Show("RELOAD_UI")
                end
            end
        end
    end)

    -- Inform the user when not silent and either the state changed OR
    -- we previously auto-activated silently during load (show one message).
    if not silent and (not wasActive or silentAutoActivated) then
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. (L["MSG_TIMEPLAYED_SUPPRESSED"] or "Time played messages will be suppressed."))
        silentAutoActivated = false
    end
    TimePlayedDebugLog("suppress", { wasActive = wasActive, silent = not not silent })
end

function lv.RestoreTimePlayedChat(silent)
    local wasActive = timePlayedFilterActive
    -- Disable our chat filter
    timePlayedFilterActive = false

    -- Only restore NovaInstanceTracker if LiteVault previously changed it.
    if timePlayedTouchedNIT and NIT and NIT.registerTimePlayedMsg then
        NIT:registerTimePlayedMsg()
        timePlayedTouchedNIT = false
    end

    -- Restore event registration to chat frames
    for i, wasRegistered in pairs(playedWindowsRegistered or {}) do
        local chatFrame = _G['ChatFrame' .. i]
        if chatFrame and wasRegistered then
            chatFrame:RegisterEvent("TIME_PLAYED_MSG")
        end
    end
    playedWindowsRegistered = {}

    -- Inform the user when not silent and either the state changed OR
    -- we previously auto-activated silently during load (show one message).
    if not silent and (wasActive or silentAutoActivated) then
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. (L["MSG_TIMEPLAYED_RESTORED"] or "Time played messages restored."))
        silentAutoActivated = false
    end
    TimePlayedDebugLog("restore", { wasActive = wasActive, silent = not not silent })
end

local lastMoney = GetMoney()
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("TIME_PLAYED_MSG")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("QUEST_ACCEPTED")
f:RegisterEvent("QUEST_AUTOCOMPLETE")
f:RegisterEvent("QUEST_REMOVED")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("BAG_UPDATE") -- For keystone changes
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN") -- When you insert a key
f:RegisterEvent("WEEKLY_REWARDS_UPDATE") -- Vault progress
f:RegisterEvent("WEEKLY_REWARDS_ITEM_CHANGED") -- Vault rewards available
f:RegisterEvent("TRADE_CLOSED") -- When a trade completes
f:RegisterEvent("MAIL_CLOSED") -- When you send/receive mail
f:RegisterEvent("AUCTION_HOUSE_CLOSED") -- When you buy/sell on AH
f:RegisterEvent("BANKFRAME_OPENED") -- Warband bank tracking
f:RegisterEvent("BANKFRAME_CLOSED") -- Warband bank tracking
f:RegisterEvent("ACCOUNT_MONEY") -- Warband bank balance changes
f:RegisterEvent("TRADE_SKILL_CLOSE") -- When crafting window closes (spark usage)
f:RegisterEvent("CRAFTINGORDERS_CLAIMED_ORDER_UPDATED") -- Work order completion
f:RegisterEvent("SCENARIO_COMPLETED") -- Delve completion tracking
f:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
f:RegisterEvent("MAJOR_FACTION_UNLOCKED")
f:RegisterEvent("QUEST_DATA_LOAD_RESULT")
f:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED")
f:RegisterEvent("TRAIT_CONFIG_UPDATED")

local function ApplySavedClockPreference()
    if not LiteVaultDB then return end
    if LiteVaultDB.use24HourClock == nil then return end
    if not SetCVar then return end

    local want24 = LiteVaultDB.use24HourClock and true or false
    SetCVar("timeMgrUseMilitaryTime", want24 and "1" or "0")
end

local queuedRefresh = {
    currentChar = false,
    ui = false,
    bagPanel = false,
}
local queuedRefreshPending = false

local function FlushQueuedRefresh()
    queuedRefreshPending = false

    local refreshCurrentChar = queuedRefresh.currentChar
    local refreshUI = queuedRefresh.ui
    local refreshBagPanel = queuedRefresh.bagPanel

    queuedRefresh.currentChar = false
    queuedRefresh.ui = false
    queuedRefresh.bagPanel = false

    if refreshCurrentChar and lv.UpdateCurrentCharData then
        lv.UpdateCurrentCharData()
    end
    if refreshCurrentChar and lv.RefreshFolioViewForCurrentChar then
        lv.RefreshFolioViewForCurrentChar(lv.PLAYER_KEY)
    end
    if refreshBagPanel and lv.RefreshBagPanelForCurrentChar then
        lv.RefreshBagPanelForCurrentChar(lv.PLAYER_KEY)
    end
    if refreshUI and lv.UpdateUI then
        lv.UpdateUI()
    end
end

function lv.QueueRefresh(opts)
    opts = opts or {}
    queuedRefresh.currentChar = queuedRefresh.currentChar or opts.currentChar
    queuedRefresh.ui = queuedRefresh.ui or opts.ui
    queuedRefresh.bagPanel = queuedRefresh.bagPanel or opts.bagPanel

    if queuedRefreshPending then return end
    queuedRefreshPending = true
    C_Timer.After(opts.delay or 0.05, FlushQueuedRefresh)
end

local function QueueCurrentCharRefresh(opts)
    opts = opts or {}
    lv.QueueRefresh({
        currentChar = true,
        ui = opts.ui ~= false,
        bagPanel = opts.bagPanel,
        delay = opts.delay,
    })
end

local function RefreshCurrentGearSnapshot(opts)
    opts = opts or {}

    if lv.ScanGear then
        lv.ScanGear()
    end
    if lv.RefreshGearPanelForCurrentChar then
        lv.RefreshGearPanelForCurrentChar(lv.PLAYER_KEY)
    end

    QueueCurrentCharRefresh({
        ui = opts.ui ~= false,
        delay = opts.delay,
    })
end

f:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "LiteVault" then 
        InstallQuestTooltipHooks()

        local LDB = LibStub("LibDataBroker-1.1")
        local LDBIcon = LibStub("LibDBIcon-1.0")
        
        local LiteVaultLDB = LDB:NewDataObject("LiteVault", { 
            type = "data source", 
            text = "LiteVault", 
            icon = "Interface\\AddOns\\LiteVault\\button.png", 
            OnClick = function() if LiteVaultWindow:IsShown() then LiteVaultWindow:Hide() else LiteVaultWindow:Show() end end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine(L["TITLE_LITEVAULT"])
                tooltip:AddLine("|cff9933ff" .. (L and L["ADDON_VERSION"] or "v12.0.7.3") .. "|r")
                tooltip:Show()
            end,
        })
        LDBIcon:Register("LiteVault", LiteVaultLDB, LiteVaultMinimapDB)
        
        local t = date("*t")
        lv.VIEW_MONTH, lv.VIEW_YEAR = t.month, t.year
        if not LiteVaultDB then LiteVaultDB = {} end
        if not LiteVaultOrder then LiteVaultOrder = {} end
        if not LiteVaultDB.filters then LiteVaultDB.filters = { timewalking=true, darkmoon=true, dungeon=true, pvp=true, bonus=true } end
        -- Re-apply saved 24h/12h preference in case Blizzard reset it on login.
        ApplySavedClockPreference()

        -- Load saved theme preference
        if LiteVaultDB.theme and lv.Themes and lv.Themes[LiteVaultDB.theme] then
            lv.currentTheme = LiteVaultDB.theme
        else
            LiteVaultDB.theme = "dark"
            lv.currentTheme = "dark"
        end

        -- EARLY: Suppress time-played message as soon as possible if enabled
        if LiteVaultDB and LiteVaultDB.disableTimePlayed then
            silentAutoActivated = true
            -- Run suppression immediately and with more retries for login race
            lv.SuppressTimePlayedChat(true)
            if lv.timePlayedSuppressTicker then
                lv.timePlayedSuppressTicker:Cancel()
                lv.timePlayedSuppressTicker = nil
            end
            local attempts = 0
            lv.timePlayedSuppressTicker = C_Timer.NewTicker(0.2, function()
                attempts = attempts + 1
                lv.SuppressTimePlayedChat(true)
                if attempts >= 12 then
                    if lv.timePlayedSuppressTicker then
                        lv.timePlayedSuppressTicker:Cancel()
                        lv.timePlayedSuppressTicker = nil
                    end
                end
            end)
        end

        -- Check for NovaInstanceTracker compatibility
        C_Timer.After(2, function()
            if NIT and LiteVaultDB and not LiteVaultDB.disableTimePlayed then
                print("|cff9933ffLiteVault:|r " .. (L["MSG_NIT_TIMEPLAYED_WARNING"] or "NovaInstanceTracker detected. The /played message may be suppressed by NIT even when LiteVault's option is disabled."))
            end
        end)

        -- ============================================================
        -- SEASON RESET CHECK: Wipe raid progression for new expansion/season
        -- Midnight Early Access: 2/27/2026, Full Launch: 3/2/2026
        -- ============================================================
        local MIDNIGHT_SEASON1_RESET = "2026-02-27" -- Early Access date
        local currentDate = string.format("%04d-%02d-%02d", t.year, t.month, t.day)

        if currentDate >= MIDNIGHT_SEASON1_RESET and LiteVaultDB.lastSeasonReset ~= MIDNIGHT_SEASON1_RESET then
            -- Wipe raid progression for ALL characters
            local wipedCount = 0
            for charKey, charData in pairs(LiteVaultDB) do
                if type(charData) == "table" and charData.raidProgression then
                    charData.raidProgression = nil
                    charData.raidLockouts = nil
                    charData.raid = nil -- Clear legacy field too
                    wipedCount = wipedCount + 1
                end
            end

            -- Mark that we've reset for this season
            LiteVaultDB.lastSeasonReset = MIDNIGHT_SEASON1_RESET

            -- Notify user
            print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. L["MSG_RAID_RESET_SEASON"])
            if wipedCount > 0 then
                print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. string.format(L["MSG_CLEARED_PROGRESSION"], wipedCount))
            end
        end
        -- ============================================================

        -- Show prompt only if character not tracked AND not declined
        local declined = LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[lv.PLAYER_KEY]
        if not LiteVaultDB[lv.PLAYER_KEY] and not declined then
            if lv.ShowTrackPrompt then lv.ShowTrackPrompt() end
        end
        
        C_Calendar.SetAbsMonth(lv.VIEW_MONTH, lv.VIEW_YEAR)
        if lv.RestoreCharacterSortMode then
            lv.RestoreCharacterSortMode()
        end
        if lv.SortCharacterList then
            lv.SortCharacterList(lv.currentSortMode)
        end
        lv.UpdateCurrentCharData()
        if lv.SyncOrderList then lv.SyncOrderList() end
        if lv.UpdateUI then lv.UpdateUI() end

    elseif event == "CALENDAR_UPDATE_EVENT_LIST" then
        lv.QueueRefresh({ ui = true })
    elseif event == "TIME_PLAYED_MSG" then
        if LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY] then
            LiteVaultDB[lv.PLAYER_KEY].played = arg1
            lv.sessionRefValue = arg1
            lv.sessionRefTime = GetTime()
        end
        TimePlayedDebugLog("TIME_PLAYED_MSG", { arg1 = arg1 })
        -- Restore chat frame registration after receiving the data
        -- Keep suppressed only if option is permanently enabled
        C_Timer.After(0.1, function()
            if not (LiteVaultDB and LiteVaultDB.disableTimePlayed) then
                lv.RestoreTimePlayedChat()
            end
        end)
    elseif event == "PLAYER_MONEY" or event == "CURRENCY_DISPLAY_UPDATE" then
        local curM = GetMoney()
        local db = LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY]

        -- INITIALIZATION GUARD: If baseline not set, just record current gold and return
        -- This prevents profit spikes before weekly tracking is properly initialized
        -- NOTE: Must check for nil explicitly because 0 is truthy in Lua
        if db and (db.weeklyStartGold == nil or db.monthlyStartGold == nil) then
            db.lastMoney = curM
            lastMoney = curM
            lv.UpdateCurrentCharData() -- This will set the baseline
            if lv.QueueRefresh then
                lv.QueueRefresh({ ui = true })
            elseif lv.UpdateUI then
                lv.UpdateUI()
            end
            return
        end

        -- Calculate gold difference
        local goldDiff = curM - lastMoney
        lastMoney = curM

        if goldDiff == 0 then
            QueueCurrentCharRefresh()
            return
        end

        -- GUARD: Don't record transactions if baseline not initialized
        -- NOTE: Must check for nil explicitly because 0 is truthy in Lua
        if not db or db.weeklyStartGold == nil or db.monthlyStartGold == nil then
            QueueCurrentCharRefresh()
            return
        end

        -- WARBAND BANK TRACKING
        if lv.atWarbandBank and LiteVaultDB then
            -- Initialize warband bank if needed (always include transactions array)
            if not LiteVaultDB["Warband Bank"] then
                LiteVaultDB["Warband Bank"] = {gold = 0, class = "Bank", lastLogin = time(), transactions = {}, region = lv.REGION}
            elseif not LiteVaultDB["Warband Bank"].transactions then
                LiteVaultDB["Warband Bank"].transactions = {}
            end

            -- Update warband bank balance (inverse of player gold change)
            local currentBankGold = LiteVaultDB["Warband Bank"].gold or 0
            LiteVaultDB["Warband Bank"].gold = currentBankGold - goldDiff
            LiteVaultDB["Warband Bank"].region = lv.REGION
            LiteVaultDB["Warband Bank"].lastLogin = time()

            -- Log the transaction
            if not LiteVaultDB["Warband Bank"].transactions then
                LiteVaultDB["Warband Bank"].transactions = {}
            end
            table.insert(LiteVaultDB["Warband Bank"].transactions, 1, {
                char = lv.PLAYER_KEY,
                amount = -goldDiff, -- Positive = deposit, negative = withdrawal
                timestamp = time(),
                charGold = goldDiff -- How much the character's gold changed
            })

            -- Keep only last 100 transactions
            while #LiteVaultDB["Warband Bank"].transactions > 100 do
                table.remove(LiteVaultDB["Warband Bank"].transactions)
            end

            print("|cff9482c9[LiteVault]|r " .. string.format(L["MSG_WARBAND_BALANCE"], GetCoinTextureString(LiteVaultDB["Warband Bank"].gold)))
        end

        QueueCurrentCharRefresh()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Some clients/reset flows can flip clock format after ADDON_LOADED.
        -- Re-apply saved preference here as well.
        ApplySavedClockPreference()
        C_Timer.After(1, ApplySavedClockPreference)

        QueueCurrentCharRefresh()

        -- Blizzard sends the first played-time line; addons cannot reliably suppress it.
        if not initialTimePlayedNoticeShown and (arg1 == true) then
            -- print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. (L["MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE"] or "Blizzard's initial time played message cannot be suppressed."))
            initialTimePlayedNoticeShown = true
        end

        -- Do NOT auto-request /played here.
        -- LiteVault tracks using Blizzard's own played-time message/event to avoid repeat chat spam.
        C_Timer.After(1, function()
            if LiteVaultDB and LiteVaultDB.disableTimePlayed then
                lv.SuppressTimePlayedChat(true) -- silent=true: don't show reload prompt on login
            else
                -- Explicitly restore in case NIT or another addon suppressed
                lv.RestoreTimePlayedChat()
            end
        end)

        C_Timer.After(3, function()
            lv.ScanBags()
            RefreshCurrentGearSnapshot()
        end)
        
    elseif event == "QUEST_ACCEPTED" then
        local questID = arg2
        local trackedWeeklyQuest, trackedWeeklyTitle = ResolveTrackedWeeklyQuest(questID)
        if trackedWeeklyQuest then
            SaveCharacterWeeklyQuestState(trackedWeeklyQuest, "in_progress", questID, trackedWeeklyTitle)
        end
        local mode = questID and ACCOUNT_WIDE_FACTION_MODE_BY_QUEST[questID]
        local cfg = mode and lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES[mode]
        if cfg and cfg.captureOnAccept then
            SaveAccountWideFactionChoice(mode, questID, "in_progress")
        end
        QueueCurrentCharRefresh()
    elseif event == "QUEST_AUTOCOMPLETE" then
        FinalizeTrackedWeeklyQuestIfCompleted(arg1, "autocomplete")
        QueueCurrentCharRefresh()
    elseif event == "QUEST_REMOVED" then
        FinalizeTrackedWeeklyQuestIfCompleted(arg1, "removed")
        QueueCurrentCharRefresh()
    elseif event == "QUEST_TURNED_IN" then
        local questID = arg1
        local trackedWeeklyQuest, trackedWeeklyTitle = ResolveTrackedWeeklyQuest(questID)
        if trackedWeeklyQuest then
            SaveCharacterWeeklyQuestState(trackedWeeklyQuest, "done", questID, trackedWeeklyTitle)
            if trackedWeeklyQuest.accountWide then
                SaveAccountWideWeeklyQuestState(trackedWeeklyQuest, "done", questID, trackedWeeklyTitle, "turn_in")
            end
        end
        local mode = questID and ACCOUNT_WIDE_FACTION_MODE_BY_QUEST[questID]
        local cfg = mode and lv.ACCOUNT_WIDE_FACTION_CHOICES and lv.ACCOUNT_WIDE_FACTION_CHOICES[mode]
        if cfg and cfg.captureOnTurnIn and mode ~= "harati" then
            local db = LiteVaultDB and lv.PLAYER_KEY and LiteVaultDB[lv.PLAYER_KEY]
            local weeklyDailies
            if db and cfg.trackDailiesPerChar then
                db.factionDailiesThisWeek = db.factionDailiesThisWeek or {}
                db.factionDailiesThisWeek[mode] = db.factionDailiesThisWeek[mode] or {}
                weeklyDailies = db.factionDailiesThisWeek[mode]
            end
            if cfg.parentID and questID == cfg.parentID then
                SaveCharacterFactionParentWeeklyState(mode, questID, "done")
                if weeklyDailies then
                    weeklyDailies[questID] = true
                end
                for _, childID in ipairs(cfg.childIDs) do
                    local isSubFaction = cfg.subFactionLookup and cfg.subFactionLookup[childID]
                    local isDaily = cfg.trackDailiesPerChar and not isSubFaction
                    if not isDaily and C_QuestLog.IsQuestFlaggedCompleted(childID) then
                        SaveAccountWideFactionChoice(mode, childID, "done")
                        if weeklyDailies then
                            weeklyDailies[childID] = true
                        end
                        break
                    end
                end
            elseif cfg.subFactionLookup and cfg.subFactionLookup[questID] then
                SaveAccountWideFactionChoice(mode, questID, "done")
                if weeklyDailies then
                    weeklyDailies[questID] = true
                end
            elseif cfg.trackDailiesPerChar then
                if weeklyDailies then
                    weeklyDailies[questID] = true
                end
            else
                SaveAccountWideFactionChoice(mode, questID, "done")
            end
        end
        QueueCurrentCharRefresh()
    elseif event == "QUEST_LOG_UPDATE" then
        QueueCurrentCharRefresh()
    elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" then
        RefreshCurrentGearSnapshot()
    elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
        if arg1 == 1186 then
            QueueCurrentCharRefresh({ delay = 0.1 })
        end
    elseif event == "TRAIT_CONFIG_UPDATED" then
        local configID = C_Traits and C_Traits.GetConfigIDBySystemID and C_Traits.GetConfigIDBySystemID(48)
        if configID and arg1 == configID then
            QueueCurrentCharRefresh({ delay = 0.1 })
        end
    elseif event == "QUEST_DATA_LOAD_RESULT" or event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "MAJOR_FACTION_UNLOCKED" then
        lv.QueueRefresh({ ui = true })
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" or event == "BAG_UPDATE" then
        -- Update when you get a new keystone or bags change
        QueueCurrentCharRefresh()
    elseif event == "BAG_UPDATE_DELAYED" then
        lv.ScanBags()
        QueueCurrentCharRefresh({ bagPanel = true })
    elseif event == "WEEKLY_REWARDS_UPDATE" or event == "WEEKLY_REWARDS_ITEM_CHANGED" then
        -- Update when vault progress changes
        QueueCurrentCharRefresh()
    elseif event == "TRADE_CLOSED" or event == "MAIL_CLOSED" or event == "AUCTION_HOUSE_CLOSED" then
        -- Update profit tracking when trading, mailing, or using AH
        QueueCurrentCharRefresh()
        
    elseif event == "BANKFRAME_OPENED" then
        lv.atWarbandBank = true

        -- Initialize warband bank if needed (preserve existing data)
        if not LiteVaultDB["Warband Bank"] then
            LiteVaultDB["Warband Bank"] = {gold = 0, class = "Bank", lastLogin = time(), transactions = {}, region = lv.REGION}
        end

        C_Timer.After(0.3, function()
            if lv.ScanBank then lv.ScanBank() end
            if lv.ScanWarbandBank then lv.ScanWarbandBank() end
            if lv.RefreshBagPanelForCurrentChar then
                lv.RefreshBagPanelForCurrentChar(lv.PLAYER_KEY)
            end
        end)

        -- Fetch warband bank balance (only when bank is open, so API is reliable)
        if C_Bank and C_Bank.FetchDepositedMoney then
            local warbandGold = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
            -- Update if we got a valid response (bank is open so API works)
            if warbandGold ~= nil then
                LiteVaultDB["Warband Bank"].gold = warbandGold
                LiteVaultDB["Warband Bank"].region = lv.REGION
                LiteVaultDB["Warband Bank"].lastLogin = time()

                print("|cff9482c9[LiteVault]|r " .. string.format(L["MSG_WARBAND_BANK_BALANCE"], GetCoinTextureString(warbandGold)))
                lv.QueueRefresh({ ui = true })
            end
        end
        
        -- Start polling timer
        if lv.warbandBankTimer then
            lv.warbandBankTimer:Cancel()
        end
        
        lv.warbandBankTimer = C_Timer.NewTicker(1, function()
            if not lv.atWarbandBank then return end
            if C_Bank and C_Bank.FetchDepositedMoney then
                local warbandGold = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
                -- Only update if valid and different (allow 0 here since bank is open)
                if warbandGold and LiteVaultDB["Warband Bank"] then
                    if warbandGold ~= LiteVaultDB["Warband Bank"].gold then
                        LiteVaultDB["Warband Bank"].gold = warbandGold
                        LiteVaultDB["Warband Bank"].region = lv.REGION
                        LiteVaultDB["Warband Bank"].lastLogin = time()
                        lv.QueueRefresh({ ui = true })
                    end
                end
            end
        end)
        
    elseif event == "BANKFRAME_CLOSED" then
        lv.atWarbandBank = false
        if lv.warbandBankTimer then
            lv.warbandBankTimer:Cancel()
            lv.warbandBankTimer = nil
        end
        
    elseif event == "TRADE_SKILL_CLOSE" or event == "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED" then
        -- Update sparks when crafting window closes or work order completes
        C_Timer.After(0.5, function()
            QueueCurrentCharRefresh()
        end)

    elseif event == "SCENARIO_COMPLETED" then
        -- Delve completed - refresh data (achievements will update the tier)
        C_Timer.After(1, function()
            QueueCurrentCharRefresh()
        end)

    elseif event == "ACCOUNT_MONEY" then
        -- Warband bank balance changed - only trust this if we're at the warband bank
        -- Otherwise the API might return stale/nil data
        if lv.atWarbandBank and C_Bank and C_Bank.FetchDepositedMoney then
            local warbandGold = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
            if warbandGold ~= nil then
                -- Initialize warband bank entry if it doesn't exist
                if not LiteVaultDB["Warband Bank"] then
                    LiteVaultDB["Warband Bank"] = {
                        gold = 0,
                        class = "Bank",
                        lastLogin = time(),
                        transactions = {},
                        region = lv.REGION
                    }
                elseif not LiteVaultDB["Warband Bank"].transactions then
                    LiteVaultDB["Warband Bank"].transactions = {}
                end

                -- Update the warband bank balance
                LiteVaultDB["Warband Bank"].gold = warbandGold
                LiteVaultDB["Warband Bank"].region = lv.REGION
                LiteVaultDB["Warband Bank"].lastLogin = time()

                lv.QueueRefresh({ ui = true })
            end
        end
    end
end)

-- ============================================================
-- SLASH COMMAND: /lvreset - Manage weekly and season resets
-- ============================================================
SLASH_LVRESET1 = "/lvreset"
SlashCmdList["LVRESET"] = function(msg)
    msg = msg:lower():gsub("^%s*(.-)%s*$", "%1") -- trim

    if msg == "weekly" then
        -- Force reset all weekly tracking data
        local resetTime = GetServerTime()
        local charCount = 0
        for charKey, charData in pairs(LiteVaultDB) do
            if type(charData) == "table" and charData.class then
                charData.lastWeeklyReset = resetTime
                charData.weeklyQuests = {}
                charData.factionParentWeeklies = nil
                charData.vR, charData.vM, charData.vW = 0, 0, 0
                charData.vaultDetails = nil
                if charData.weeklyPlanner then
                    for _, entry in ipairs(charData.weeklyPlanner) do
                        if type(entry) == "table" then
                            entry.checked = false
                        end
                    end
                end
                charCount = charCount + 1
            end
        end
        LiteVaultDB.accountWideFactionChoices = nil
        LiteVaultDB.accountWideWeeklyQuests = nil
        LiteVaultDB.permanentFactionCompletions = nil
        if lv.UpdateCurrentCharData then lv.UpdateCurrentCharData() end
        if lv.UpdateUI then lv.UpdateUI() end
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. string.format(L["MSG_WEEKLY_DATA_RESET"], charCount))

    elseif msg == "season" then
        -- Force reset all raid progression NOW
        local wipedCount = 0
        for charKey, charData in pairs(LiteVaultDB) do
            if type(charData) == "table" and charData.raidProgression then
                charData.raidProgression = nil
                charData.raidLockouts = nil
                charData.raid = nil
                wipedCount = wipedCount + 1
            end
        end

        local resetDate = date("%Y-%m-%d")
        LiteVaultDB.lastSeasonReset = resetDate

        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. L["MSG_RAID_MANUAL_RESET"])
        print("|cff9933ff" .. L["MSG_PREFIX"] .. "|r " .. string.format(L["MSG_CLEARED_DATA"], wipedCount))

        if lv.UpdateUI then lv.UpdateUI() end
    else
        -- Show status and help
        local region = GetCurrentRegion()
        local regionNames = {"US", "KR", "EU", "TW"}
        local regionName = regionNames[region] or "US"
        local resetDays = {
            [1] = "Tuesday 15:00 UTC",
            [2] = "Wednesday 23:00 UTC",
            [3] = "Wednesday 04:00 UTC",
            [4] = "Wednesday 23:00 UTC",
        }
        local resetDay = resetDays[region] or "Tuesday 15:00 UTC"

        print("|cff9933ff" .. L["HELP_RESET_TITLE"] .. "|r")
        print("  " .. string.format(L["HELP_REGION"], regionName, resetDay))
        print("  " .. string.format(L["HELP_LAST_SEASON"], LiteVaultDB.lastSeasonReset or L["HELP_NEVER"]))
        print("")
        print("  " .. L["HELP_RESET_WEEKLY"])
        print("  " .. L["HELP_RESET_SEASON"])
    end
end

