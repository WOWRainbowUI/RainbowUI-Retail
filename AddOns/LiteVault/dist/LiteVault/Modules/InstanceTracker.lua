local addonName, lv = ...
local L = lv.L

lv.InstanceTracker = lv.InstanceTracker or {}

local tracker = CreateFrame("Frame")
local debouncePending = false
local finalEncounterCache = {}
local function GetCrestCurrencySnapshot()
    local snapshot = {}
    if not (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo) then
        return snapshot
    end

    for _, def in ipairs(lv.GetActiveCrestDefinitions()) do
        local currencyID = lv.ResolveActiveCrestCurrencyID(def)
        local info = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID)
        snapshot[def.key] = (info and tonumber(info.quantity)) or 0
    end

    return snapshot
end

local function GetCrestCurrencyGains(startSnapshot)
    local gains = {}
    local hadGain = false
    local currentSnapshot = GetCrestCurrencySnapshot()

    for _, def in ipairs(lv.GetActiveCrestDefinitions()) do
        local crestName = def.key
        local gained = (currentSnapshot[crestName] or 0) - ((startSnapshot and startSnapshot[crestName]) or 0)
        if gained > 0 then
            gains[crestName] = gained
            hadGain = true
        end
    end

    return hadGain and gains or nil
end

local function EnsureDB()
    if lv.Stats and lv.Stats.EnsureDB then
        lv.Stats.EnsureDB()
    else
        LiteVaultDB = LiteVaultDB or {}
        LiteVaultDB.instances = LiteVaultDB.instances or { runs = {}, current = nil, pendingDungeon = nil }
        LiteVaultDB.instances.pendingDungeon = LiteVaultDB.instances.pendingDungeon or nil
        LiteVaultDB.legacyRaids = LiteVaultDB.legacyRaids or { runs = {} }
    end
end

local function CopyRun(run)
    if not run then return nil end
    local out = {}
    for k, v in pairs(run) do
        out[k] = v
    end
    return out
end

local function IsLikelyDuplicateRun(existing, run)
    if not existing or not run then return false end
    if existing.type ~= run.type then return false end
    if (existing.instanceID or 0) ~= (run.instanceID or 0) then return false end
    if (existing.name or "") ~= (run.name or "") then return false end

    local eEnd = existing.endTime or 0
    local rEnd = run.endTime or 0
    local endClose = math.abs(eEnd - rEnd) <= 15
    local durationClose = math.abs((existing.duration or 0) - (run.duration or 0)) <= 5
    local goldClose = math.abs((existing.gold or 0) - (run.gold or 0)) <= 10

    return endClose and durationClose and goldClose
end

local function IsSameAuthoritativeMPlusRun(existing, run)
    if not (existing and run and existing.isMythicPlus and run.isMythicPlus) then return false end
    if existing.charKey ~= run.charKey then return false end
    if existing.challengeMapID ~= run.challengeMapID then return false end
    if existing.keystoneLevel ~= run.keystoneLevel then return false end
    if existing.mplusTimeMS ~= run.mplusTimeMS then return false end
    return math.abs((existing.endTime or 0) - (run.endTime or 0)) <= 5
end

local function IsTrackableInstanceType(instanceType)
    return instanceType == "party" or instanceType == "raid"
end

local function IsDailyLockoutDungeonDiff(diffID)
    return diffID == 2 or diffID == 23
end

local function IsMythicPlusActive()
    return C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive and C_ChallengeMode.IsChallengeModeActive() or false
end

local function IsEncounterSuccess(success)
    return success == 1 or success == true
end

local function IsLegacyRaid(playerLevel, difficultyID, mapID, instanceName)
    local seasonKey = lv.ResolveConfiguredRaid and lv.ResolveConfiguredRaid(instanceName, mapID)
    local season = seasonKey and lv.RAID_SEASONS and lv.RAID_SEASONS[seasonKey]
    if season then
        return season.category ~= "current" or seasonKey ~= lv.CURRENT_RAID_SEASON
    end

    -- Any other raid at max-level endgame is considered legacy content.
    if (playerLevel or 0) >= 70 then
        return true
    end
    return false
end

local function PersistCompletedRun(run)
    if not run or run.practiceRun or (run.isMythicPlus and not run.mplusCompleted) or run.mplusPersisted then return false end
    -- Defensive dedupe: we may get repeated exit transitions when zoning/reloading.
    for i = #LiteVaultDB.instances.runs, math.max(1, #LiteVaultDB.instances.runs - 20), -1 do
        if IsLikelyDuplicateRun(LiteVaultDB.instances.runs[i], run) or IsSameAuthoritativeMPlusRun(LiteVaultDB.instances.runs[i], run) then
            return false
        end
    end
    if run.isMythicPlus then run.mplusPersisted = true end
    table.insert(LiteVaultDB.instances.runs, CopyRun(run))
    if run.type == "dungeon" and (not run.isMythicPlus) and (not run.capCounted) and lv.InstanceCap and lv.InstanceCap.RecordEntry then
        run.capCounted = true
        lv.InstanceCap.RecordEntry()
        if lv.InstanceCap.CheckAndWarn then
            lv.InstanceCap.CheckAndWarn()
        end
    end
    if run.type == "raid" and run.isLegacy then
        for i = #LiteVaultDB.legacyRaids.runs, math.max(1, #LiteVaultDB.legacyRaids.runs - 20), -1 do
            if IsLikelyDuplicateRun(LiteVaultDB.legacyRaids.runs[i], run) then
                return
            end
        end
        table.insert(LiteVaultDB.legacyRaids.runs, CopyRun(run))
    end
    return true
end

local function CopyArray(values)
    local out = {}
    for i, value in ipairs(values or {}) do out[i] = value end
    return out
end

local function ApplyChallengeMapInfo(run, challengeMapID)
    if not (run and challengeMapID and C_ChallengeMode and C_ChallengeMode.GetMapUIInfo) then return end
    local name, id, timeLimit, texture, backgroundTexture, instanceMapID = C_ChallengeMode.GetMapUIInfo(challengeMapID)
    run.challengeMapID = challengeMapID
    run.challengeMapName = name or run.challengeMapName or run.name
    run.challengeTimeLimit = tonumber(timeLimit) or run.challengeTimeLimit
    run.challengeTexture = texture or run.challengeTexture
    run.challengeBackgroundTexture = backgroundTexture or run.challengeBackgroundTexture
    run.challengeInstanceMapID = instanceMapID or id or run.challengeInstanceMapID
    if name and name ~= "" then run.name = name end
end

local function GetKnownCrestRewardKey(currencyID)
    for _, season in pairs(lv.MIDNIGHT_UPGRADE_SEASONS or {}) do
        for _, def in ipairs(season.crests or {}) do
            if def.currencyID == currencyID or def.preferredCurrencyID == currencyID then return def.key end
            for _, alternateID in ipairs(def.alternateCurrencyIDs or {}) do
                if alternateID == currencyID then return def.key end
            end
        end
    end
end

local function ApplyPendingMPlusRewards(run, rewardData)
    if not (run and rewardData) then return end
    run.rewardEventMapID = rewardData.mapID
    run.rewardTimeMS = rewardData.timeMS
    run.rewardMoney = rewardData.money
    run.mplusRewards = {}
    local exactCrests = {}
    local hasExactCrests = false
    for _, reward in ipairs(rewardData.rewards or {}) do
        local copied = {
            rewardID=reward.rewardID, displayInfoID=reward.displayInfoID,
            quantity=reward.quantity, isCurrency=reward.isCurrency and true or false,
        }
        run.mplusRewards[#run.mplusRewards + 1] = copied
        local crestKey = copied.isCurrency and GetKnownCrestRewardKey(copied.rewardID)
        if crestKey and tonumber(copied.quantity) then
            exactCrests[crestKey] = tonumber(copied.quantity)
            hasExactCrests = true
        end
    end
    if hasExactCrests then
        run.crestGains = exactCrests
        run.crestGainsSource = "challengeRewards"
    end
end

local function FinalizePendingMPlus()
    local pending = lv.InstanceTracker.pendingMPlus
    if not (pending and pending.completionCaptured and pending.run) then return end
    local run = pending.run
    if pending.rewardData then ApplyPendingMPlusRewards(run, pending.rewardData) end
    if not run.crestGains then
        run.crestGains = GetCrestCurrencyGains(run.crestSnapshotStart)
        if run.crestGains then run.crestGainsSource = "currencySnapshot" end
    end
    run.gold = tonumber(run.rewardMoney) or math.max(0, run.goldGained or 0)
    run.crestSnapshotStart = nil
    run.startGold = nil
    run.goldGained = nil
    run.lastMoneySnapshot = nil
    PersistCompletedRun(run)
    lv.InstanceTracker.pendingMPlus = nil
    if LiteVaultDB and LiteVaultDB.instances then
        LiteVaultDB.instances.current = (lv.InstanceTracker.currentRun == run) and CopyRun(run) or nil
    end
    if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
end

local function SchedulePendingMPlusFinalize()
    local pending = lv.InstanceTracker.pendingMPlus
    if not pending or pending.finalizeScheduled then return end
    pending.finalizeScheduled = true
    C_Timer.After(1.5, FinalizePendingMPlus)
end

local function MarkDungeonCompleted()
    local run = lv.InstanceTracker.currentRun
    if run and run.type == "dungeon" then
        run.isCompleted = true
        LiteVaultDB.instances.current = CopyRun(run)
    end
end

local function MarkRaidCountedOnBossKill()
    local run = lv.InstanceTracker.currentRun
    if not run or run.type ~= "raid" then return end
    if run.capCounted then return end

    run.capCounted = true
    LiteVaultDB.instances.current = CopyRun(run)
    if lv.InstanceCap and lv.InstanceCap.RecordEntry then
        lv.InstanceCap.RecordEntry()
        if lv.InstanceCap.CheckAndWarn then
            lv.InstanceCap.CheckAndWarn()
        end
    end
end

local function MarkDungeonCountedOnBossKill()
    local run = lv.InstanceTracker.currentRun
    if not run or run.type ~= "dungeon" then return end
    if run.isMythicPlus then return end
    if run.capCounted then return end

    run.capCounted = true
    LiteVaultDB.instances.current = CopyRun(run)
    if lv.InstanceCap and lv.InstanceCap.RecordEntry then
        lv.InstanceCap.RecordEntry()
        if lv.InstanceCap.CheckAndWarn then
            lv.InstanceCap.CheckAndWarn()
        end
    end
end

local function IsResetSuccessMessage(msg)
    if not msg then return false end
    if issecretvalue and issecretvalue(msg) then return false end
    local resetSuccess = _G.INSTANCE_RESET_SUCCESS
    if not resetSuccess then return false end

    -- Localized global like "%s has been reset." -> turn into a match pattern.
    local escaped = resetSuccess:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    local pattern = escaped:gsub("%%%%s", "(.+)")
    return string.match(msg, "^" .. pattern .. "$") ~= nil
end

local function TrackRunMoneyGain()
    local run = lv.InstanceTracker.currentRun
    if not run then return end
    if run.type ~= "dungeon" and run.type ~= "raid" then return end

    local currentMoney = GetMoney() or 0
    local lastMoney = run.lastMoneySnapshot or currentMoney
    local delta = currentMoney - lastMoney
    if delta > 0 then
        run.goldGained = (run.goldGained or 0) + delta
    end
    run.lastMoneySnapshot = currentMoney
    LiteVaultDB.instances.current = CopyRun(run)
end

local function GetFinalEncounterIDForInstance(instanceID)
    if not instanceID or instanceID <= 0 then return nil end
    if finalEncounterCache[instanceID] ~= nil then
        return finalEncounterCache[instanceID]
    end

    if not C_EncounterJournal or not C_EncounterJournal.GetInstanceForGameMap then
        finalEncounterCache[instanceID] = false
        return nil
    end

    local journalID = C_EncounterJournal.GetInstanceForGameMap(instanceID)
    if not journalID then
        finalEncounterCache[instanceID] = false
        return nil
    end

    if not EJ_GetEncounterInfoByIndex then
        finalEncounterCache[instanceID] = false
        return nil
    end

    local lastEncounterID = nil
    local idx = 1
    while true do
        local _, _, encounterID = EJ_GetEncounterInfoByIndex(idx, journalID)
        if not encounterID then
            break
        end
        lastEncounterID = encounterID
        idx = idx + 1
    end

    finalEncounterCache[instanceID] = lastEncounterID or false
    return lastEncounterID
end

function lv.InstanceTracker.IsInInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance and IsTrackableInstanceType(instanceType), instanceType
end

function lv.InstanceTracker.GetCurrentRun()
    return lv.InstanceTracker.currentRun
end

function lv.InstanceTracker.OnEnterInstance()
    EnsureDB()
    local name, instanceType, difficultyID, difficultyName, _, _, _, mapID = GetInstanceInfo()
    local runType = (instanceType == "raid") and "raid" or "dungeon"
    local level = UnitLevel("player") or 0

    lv.InstanceTracker.currentRun = {
        name = name or UNKNOWN,
        instanceID = mapID or 0,
        difficulty = difficultyID or 0,
        difficultyName = difficultyName or "",
        charKey = lv.PLAYER_KEY,
        charName = UnitName("player") or UNKNOWN,
        charClass = select(2, UnitClass("player")),
        type = runType,
        isLegacy = (runType == "raid") and IsLegacyRaid(level, difficultyID, mapID, name) or false,
        startTime = time(),
        endTime = nil,
        duration = nil,
        playerLevel = level,
        startGold = GetMoney() or 0,
        gold = nil,
        goldGained = 0,
        lastMoneySnapshot = GetMoney() or 0,
        isCompleted = false,
        isMythicPlus = IsMythicPlusActive(),
        capCounted = false,
        finalized = false,
        crestSnapshotStart = GetCrestCurrencySnapshot(),
        crestGains = nil,
    }

    LiteVaultDB.instances.current = CopyRun(lv.InstanceTracker.currentRun)
end

function lv.InstanceTracker.OnExitInstance()
    EnsureDB()
    local run = lv.InstanceTracker.currentRun
    if not run then return end
    if run.finalized then
        lv.InstanceTracker.currentRun = nil
        LiteVaultDB.instances.current = nil
        return
    end
    run.finalized = true

    run.endTime = time()
    run.duration = math.max(0, run.endTime - (run.startTime or run.endTime))

    if run.type == "raid" then
        if run.isLegacy then
            run.gold = math.max(0, run.goldGained or 0)
        else
            local delta = (GetMoney() or 0) - (run.startGold or 0)
            run.gold = math.max(0, delta)
        end
    elseif run.type == "dungeon" then
        run.gold = math.max(0, run.goldGained or 0)
    end

    if not run.isMythicPlus then
        run.crestGains = GetCrestCurrencyGains(run.crestSnapshotStart)
    end

    if not run.isMythicPlus then
        run.startGold = nil
        run.goldGained = nil
        run.lastMoneySnapshot = nil
        run.crestSnapshotStart = nil
    end

    if run.type == "dungeon" then
        if run.isMythicPlus then
            -- Authoritative M+ completion is finalized by the bounded challenge
            -- reconciliation path. Started/reset/abandoned keys are discarded.
            LiteVaultDB.instances.pendingDungeon = nil
        -- Safety net: if cap was already counted but completion flag was missed,
        -- still persist the run so it doesn't disappear after zoning/reset edges.
        elseif run.isCompleted or run.capCounted then
            PersistCompletedRun(run)
            LiteVaultDB.instances.pendingDungeon = nil
        else
            -- Keep incomplete dungeon run pending until player explicitly resets.
            LiteVaultDB.instances.pendingDungeon = CopyRun(run)
        end
    else
        PersistCompletedRun(run)
    end

    lv.InstanceTracker.currentRun = nil
    LiteVaultDB.instances.current = nil
end

function lv.InstanceTracker.CheckInstanceState()
    EnsureDB()
    local inside, _ = lv.InstanceTracker.IsInInstance()
    local hadRun = lv.InstanceTracker.currentRun ~= nil

    if inside and not hadRun then
        lv.InstanceTracker.OnEnterInstance()
    elseif (not inside) and hadRun then
        lv.InstanceTracker.OnExitInstance()
    elseif inside and hadRun and LiteVaultDB.instances.current == nil then
        LiteVaultDB.instances.current = CopyRun(lv.InstanceTracker.currentRun)
    end
end

local function DebouncedCheck()
    if debouncePending then return end
    debouncePending = true
    C_Timer.After(0.5, function()
        debouncePending = false
        lv.InstanceTracker.CheckInstanceState()
        if lv.UpdateInstancePanel then
            lv.UpdateInstancePanel()
        end
    end)
end

tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
tracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
tracker:RegisterEvent("PLAYER_LOGOUT")
tracker:RegisterEvent("SCENARIO_COMPLETED")
tracker:RegisterEvent("CHALLENGE_MODE_START")
tracker:RegisterEvent("CHALLENGE_MODE_COMPLETED")
tracker:RegisterEvent("CHALLENGE_MODE_COMPLETED_REWARDS")
tracker:RegisterEvent("CHALLENGE_MODE_RESET")
tracker:RegisterEvent("ENCOUNTER_END")
tracker:RegisterEvent("PLAYER_MONEY")
tracker:RegisterEvent("CHAT_MSG_SYSTEM")
tracker:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGOUT" then
        EnsureDB()
        LiteVaultDB.instances.current = CopyRun(lv.InstanceTracker.currentRun)
        return
    end

    if event == "CHALLENGE_MODE_START" then
        EnsureDB()
        local mapID = ...
        if not lv.InstanceTracker.currentRun then lv.InstanceTracker.OnEnterInstance() end
        local run = lv.InstanceTracker.currentRun
        if run and run.type == "dungeon" then
            run.isMythicPlus = true
            run.mplusStarted = true
            run.isCompleted = false
            run.mplusCompleted = false
            ApplyChallengeMapInfo(run, mapID)
            if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
                local level, affixIDs, charged = C_ChallengeMode.GetActiveKeystoneInfo()
                run.keystoneLevel = tonumber(level)
                run.affixIDs = CopyArray(affixIDs)
                run.wasActiveKeystoneCharged = charged
            end
            local seasonID = C_MythicPlus and C_MythicPlus.GetCurrentSeason and C_MythicPlus.GetCurrentSeason()
            if tonumber(seasonID) and tonumber(seasonID) > 0 then run.mplusSeasonID = tonumber(seasonID) end
            if lv.GetActiveUpgradeSeasonKey then run.contentSeasonKey = lv.GetActiveUpgradeSeasonKey() end
            lv.InstanceTracker.pendingMPlus = { run=run, startedAt=GetTime and GetTime() or 0 }
            LiteVaultDB.instances.current = CopyRun(run)
        end
        if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
        return
    end

    if event == "CHALLENGE_MODE_COMPLETED" then
        EnsureDB()
        local run = lv.InstanceTracker.currentRun
        local info = lv.InstanceTracker.retryCompletionInfo
            or (C_ChallengeMode and C_ChallengeMode.GetChallengeCompletionInfo and C_ChallengeMode.GetChallengeCompletionInfo())
        lv.InstanceTracker.retryCompletionInfo = nil
        if not info then
            C_Timer.After(0.2, function()
                if C_ChallengeMode and C_ChallengeMode.GetChallengeCompletionInfo then
                    local retryInfo = C_ChallengeMode.GetChallengeCompletionInfo()
                    if retryInfo then
                        lv.InstanceTracker.retryCompletionInfo = retryInfo
                        tracker:GetScript("OnEvent")(tracker, "CHALLENGE_MODE_COMPLETED")
                    end
                end
            end)
            return
        end
        if info.practiceRun then
            if run then run.practiceRun = true; run.isCompleted = false; run.mplusCompleted = false end
            lv.InstanceTracker.pendingMPlus = nil
            return
        end
        if not run then
            lv.InstanceTracker.OnEnterInstance()
            run = lv.InstanceTracker.currentRun
        end
        if run and run.type == "dungeon" then
            run.isMythicPlus = true
            run.mplusStarted = true
            run.mplusCompleted = true
            run.isCompleted = true
            run.challengeMapID = info.mapChallengeModeID
            run.keystoneLevel = tonumber(info.level)
            run.mplusTimeMS = tonumber(info.time)
            run.onTime = info.onTime
            run.keystoneUpgradeLevels = tonumber(info.keystoneUpgradeLevels)
            run.practiceRun = info.practiceRun and true or false
            run.oldOverallDungeonScore = tonumber(info.oldOverallDungeonScore)
            run.newOverallDungeonScore = tonumber(info.newOverallDungeonScore)
            if run.oldOverallDungeonScore and run.newOverallDungeonScore then
                run.ratingChange = run.newOverallDungeonScore - run.oldOverallDungeonScore
            else
                run.ratingChange = nil
            end
            run.isMapRecord = info.isMapRecord and true or false
            run.isAffixRecord = info.isAffixRecord and true or false
            run.isEligibleForScore = info.isEligibleForScore
            run.members = {}
            for _, member in ipairs(info.members or {}) do
                run.members[#run.members + 1] = { name=member.name, classID=member.classID, specID=member.specID }
            end
            run.endTime = time()
            run.duration = math.max(0, run.endTime - (run.startTime or run.endTime))
            ApplyChallengeMapInfo(run, info.mapChallengeModeID)
            local pending = lv.InstanceTracker.pendingMPlus or {}
            pending.run = run
            pending.completionCaptured = true
            lv.InstanceTracker.pendingMPlus = pending
            LiteVaultDB.instances.current = CopyRun(run)
            SchedulePendingMPlusFinalize()
        end
        if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
        return
    end

    if event == "CHALLENGE_MODE_COMPLETED_REWARDS" then
        EnsureDB()
        local mapID, medal, timeMS, money, rewards = ...
        local copiedRewards = {}
        for _, reward in ipairs(rewards or {}) do
            copiedRewards[#copiedRewards + 1] = {
                rewardID=reward.rewardID, displayInfoID=reward.displayInfoID,
                quantity=reward.quantity, isCurrency=reward.isCurrency and true or false,
            }
        end
        local pending = lv.InstanceTracker.pendingMPlus or { run=lv.InstanceTracker.currentRun }
        pending.rewardData = { mapID=mapID, medal=medal, timeMS=timeMS, money=money, rewards=copiedRewards }
        lv.InstanceTracker.pendingMPlus = pending
        if pending.completionCaptured then SchedulePendingMPlusFinalize() end
        return
    end

    if event == "CHALLENGE_MODE_RESET" then
        local run = lv.InstanceTracker.currentRun
        if run and run.isMythicPlus and not run.mplusCompleted then
            run.mplusReset = true
            run.isCompleted = false
            LiteVaultDB.instances.current = CopyRun(run)
        end
        lv.InstanceTracker.pendingMPlus = nil
        return
    end

    if event == "SCENARIO_COMPLETED" then
        EnsureDB()
        MarkDungeonCompleted()
        if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
        return
    end

    if event == "ENCOUNTER_END" then
        local encounterID, _, _, _, success = ...
        if IsEncounterSuccess(success) then
            EnsureDB()
            if not lv.InstanceTracker.currentRun then
                local inside = lv.InstanceTracker.IsInInstance and lv.InstanceTracker.IsInInstance()
                if inside then
                    lv.InstanceTracker.OnEnterInstance()
                end
            end
            MarkRaidCountedOnBossKill()

            -- Dungeon completion rules:
            -- 1) Heroic/Mythic (non-key): first boss kill locks run, mark complete.
            -- 2) Other dungeons: mark complete on final-boss kill.
            local run = lv.InstanceTracker.currentRun
            if run and run.type == "dungeon" and encounterID and not run.isMythicPlus then
                if (not run.isMythicPlus) and IsDailyLockoutDungeonDiff(run.difficulty) then
                    MarkDungeonCountedOnBossKill()
                    MarkDungeonCompleted()
                else
                    local finalEncounterID = GetFinalEncounterIDForInstance(run.instanceID)
                    if finalEncounterID and encounterID == finalEncounterID then
                        MarkDungeonCountedOnBossKill()
                        MarkDungeonCompleted()
                    end
                end
            end

            -- If challenge mode is active at any point, classify as Mythic+.
            if run and run.type == "dungeon" and IsMythicPlusActive() then
                run.isMythicPlus = true
                LiteVaultDB.instances.current = CopyRun(run)
            end

            if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
        end
        return
    end

    if event == "PLAYER_MONEY" then
        EnsureDB()
        TrackRunMoneyGain()
        return
    end

    if event == "CHAT_MSG_SYSTEM" then
        EnsureDB()
        local msg = ...
        if issecretvalue and issecretvalue(msg) then
            return
        end
        if IsResetSuccessMessage(msg) then
            local pending = LiteVaultDB.instances.pendingDungeon
            if pending then
                PersistCompletedRun(pending)
                LiteVaultDB.instances.pendingDungeon = nil
            end
            if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
        end
        return
    end

    EnsureDB()
    if not lv.InstanceTracker.currentRun and LiteVaultDB.instances.current then
        if not LiteVaultDB.instances.current.finalized then
            lv.InstanceTracker.currentRun = CopyRun(LiteVaultDB.instances.current)
            if lv.InstanceTracker.currentRun.isMythicPlus and lv.InstanceTracker.currentRun.mplusCompleted
                and not lv.InstanceTracker.currentRun.mplusPersisted then
                lv.InstanceTracker.pendingMPlus = {
                    run = lv.InstanceTracker.currentRun,
                    completionCaptured = true,
                }
                SchedulePendingMPlusFinalize()
            end
        else
            LiteVaultDB.instances.current = nil
        end
    end
    DebouncedCheck()
end)
