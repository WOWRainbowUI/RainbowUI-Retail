-- Manaforge Omega Boss Names (Season 3) - Hardcoded since EJ may not be available
local addonName, lv = ...
local L = lv.L

local function LT(text)
    return (L and L[text] and L[text] ~= text) and L[text] or text
end

local raidTabs = {"The Voidspire", "The Dreamrift", "March of Quel'Danas"}
local raidTabButtons = {}
local selectedRaidTab = raidTabs[1]
local currentRaidCharKey = nil

local function UpdateRaidTabButtonStyles()
    local theme = lv.GetTheme and lv.GetTheme() or nil
    if not theme then return end
    for raidName, btn in pairs(raidTabButtons) do
        if raidName == selectedRaidTab then
            btn:SetBackdropColor(unpack(theme.buttonBgActive or theme.buttonBgHover or theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
        else
            btn:SetBackdropColor(unpack(theme.buttonBg or theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end
    end
end

local function ShowRaidTab(raidName)
    selectedRaidTab = raidName
    UpdateRaidTabButtonStyles()
    if lv.GetCurrentRaidBossCount then
        lv.NUM_RAID_BOSSES = lv.GetCurrentRaidBossCount()
    end
    if lv.UpdateRaidLockoutGrid then
        lv.UpdateRaidLockoutGrid()
    end
end

local function CreateRaidTabs(parent)
    local title = parent.title or parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if not parent.title then
        title:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -18)
        title:SetText(L["TITLE_RAID_LOCKOUTS_WINDOW"] or "Raid Lockouts")
        if lv.ApplyLocaleFont then
            lv.ApplyLocaleFont(title, 15)
        end
        parent.title = title
    end
    local startX = 40
    local spacing = 140
    for i, raidName in ipairs(raidTabs) do
        local btnWidth = 130
        if raidName == "March of Quel'Danas" then
            btnWidth = (lv.Layout and lv.Layout.raidLongTabWidth) or 146
        else
            btnWidth = (lv.Layout and lv.Layout.raidTabWidth) or 130
        end
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(btnWidth, 28)
        if i == 1 then
            btn:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        else
            btn:SetPoint("LEFT", raidTabButtons[raidTabs[i-1]], "RIGHT", 10, 0)
        end
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        btn:EnableMouse(true)
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.Text:SetPoint("CENTER")
        btn.Text:SetText(LT(raidName))
        if lv.ApplyLocaleFont then
            lv.ApplyLocaleFont(btn.Text, 11)
        end
        btn:SetFrameLevel(parent:GetFrameLevel() + 100)
        btn:SetToplevel(true)
        btn:Raise()
        btn:SetAlpha(1)
        btn:SetScript("OnClick", function()
            ShowRaidTab(raidName)
        end)
        btn:SetScript("OnEnter", function(self)
            local theme = lv.GetTheme and lv.GetTheme() or nil
            if not theme then return end
            if raidName ~= selectedRaidTab then
                self:SetBackdropColor(unpack(theme.buttonBgHover or theme.buttonBg))
                self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
            end
        end)
        btn:SetScript("OnLeave", function(self)
            local theme = lv.GetTheme and lv.GetTheme() or nil
            if not theme then return end
            if raidName == selectedRaidTab then
                self:SetBackdropColor(unpack(theme.buttonBgActive or theme.buttonBgHover or theme.buttonBg))
                self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
            else
                self:SetBackdropColor(unpack(theme.buttonBg or theme.buttonBgAlt))
                self:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end
        end)
        raidTabButtons[raidName] = btn
        -- Register for theme updates
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(btn, function(f, theme)
                if raidName == selectedRaidTab then
                    f:SetBackdropColor(unpack(theme.buttonBgActive or theme.buttonBgHover or theme.buttonBg))
                    f:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
                else
                    f:SetBackdropColor(unpack(theme.buttonBg or theme.buttonBgAlt))
                    f:SetBackdropBorderColor(unpack(theme.borderPrimary))
                end
                f.Text:SetTextColor(unpack(theme.textSecondary))
            end)
        end
    end
    UpdateRaidTabButtonStyles()
end

C_Timer.After(0, function()
    if _G["LiteVaultRaidFrame"] then
        CreateRaidTabs(_G["LiteVaultRaidFrame"])
    end
end)

local MIDNIGHT_RAIDS = {
    ["The Voidspire"] = {
        bossCount = 6,
        bosses = {
            "Imperator Averzian",
            "Vorasius",
            "Fallen-King Salhadaar",
            "Vaelgor & Ezzorak",
            "Lightblinded Vanguard",
            "Alleria Windrunner (Crown of the Cosmos)"
        }
    },
    ["The Dreamrift"] = {
        bossCount = 1,
        bosses = {
            "Chimarus"
        }
    },
    ["March of Quel'Danas"] = {
        bossCount = 2,
        bosses = {
            "Belo'ren",
            "L'ura (Midnight Falls)"
        }
    }
}

-- Expose current selected raid boss count for other UI surfaces (e.g. roster badge).
function lv.GetCurrentRaidBossCount()
    local raidName = selectedRaidTab or raidTabs[1]
    local raidData = MIDNIGHT_RAIDS and MIDNIGHT_RAIDS[raidName]
    if not raidData then
        return lv.NUM_RAID_BOSSES or 8
    end
    return raidData.bossCount or #(raidData.bosses or {}) or (lv.NUM_RAID_BOSSES or 8)
end

-- Current tier map IDs - FIXED: Make sure this table exists and contains correct IDs
if not lv.CURRENT_TIER_MAPS then
    -- Learned dynamically when entering/saving tracked raids.
    lv.CURRENT_TIER_MAPS = {}
end

-- Difficulty data (names are set dynamically from locale)
lv.RAID_DIFFICULTIES = {
    {id = 17, nameKey = "DIFFICULTY_LFR", tag = "LFR", color = {0.1, 0.9, 0.1}},
    {id = 14, nameKey = "DIFFICULTY_NORMAL", tag = "N", color = {0, 0.44, 0.87}},
    {id = 15, nameKey = "DIFFICULTY_HEROIC", tag = "H", color = {0.64, 0.21, 0.93}},
    {id = 16, nameKey = "DIFFICULTY_MYTHIC", tag = "M", color = {1, 0.5, 0}},
}

-- Current selected difficulty
local currentDifficulty = 16 -- Default to Mythic

-- View mode: "lockouts" (current week) or "progression" (best ever)
local currentViewMode = "lockouts"
lv.getRaidViewMode = function() return currentViewMode end

-- Optional statistic backfill map (fill with real stat IDs when available).
-- Shape:
-- BossStatMap["The Voidspire"][1] = { normal = 123, heroic = 456, mythic = 789 }
local BossStatMap = {
    ["The Voidspire"] = {
        [1] = { mythic = 61372 }, -- Imperator Averzian
        [2] = { mythic = 61373 }, -- Vorasius
        [3] = { mythic = 61374 }, -- Fallen-King Salhadaar
        [4] = { mythic = 61375 }, -- Vaelgor (& Ezzorak)
    },
    ["March of Quel'Danas"] = {
        -- Shared encounter stat (Belo'ren + Child of Al'ar).
        [1] = { mythic = 61378 }, -- Belo'ren
        [2] = { mythic = 61378 }, -- Child of Al'ar
    },
}

local function GetDifficultyKey(difficultyID)
    if difficultyID == 17 then return "lfr" end
    if difficultyID == 14 then return "normal" end
    if difficultyID == 15 then return "heroic" end
    if difficultyID == 16 then return "mythic" end
    return nil
end

local function IsTrackedRaidDifficulty(difficultyID)
    return difficultyID == 17 or difficultyID == 14 or difficultyID == 15 or difficultyID == 16
end

local DIFF_ORDER = {17, 14, 15, 16} -- LFR, Normal, Heroic, Mythic
local function EnsureTripletOrbs(indicator)
    if indicator.orbs then return end
    local parent = indicator:GetParent()
    indicator.orbs = {}
    indicator.orbShells = {}
    local offsets = {-26, -9, 9, 26} -- 4px gap between 15px shells, fits widened columns
    for i = 1, 4 do
        -- Outer shell for square "orb" border.
        local shell = parent:CreateTexture(nil, "ARTWORK")
        shell:SetSize(15, 15)
        shell:SetPoint("CENTER", indicator, "CENTER", offsets[i], 0)
        shell:SetDrawLayer("OVERLAY", 5)
        shell:SetTexture("Interface\\Buttons\\WHITE8X8")
        shell:SetBlendMode("BLEND")

        -- Inner fill.
        local orb = parent:CreateTexture(nil, "ARTWORK")
        orb:SetSize(11, 11)
        orb:SetPoint("CENTER", indicator, "CENTER", offsets[i], 0)
        orb:SetDrawLayer("OVERLAY", 6)
        orb:SetTexture("Interface\\Buttons\\WHITE8X8")
        orb:SetBlendMode("BLEND")

        indicator.orbShells[i] = shell
        indicator.orbs[i] = orb
    end
end

local function HideTripletOrbs(indicator)
    if indicator.orbs then
        for i = 1, 4 do
            indicator.orbs[i]:Hide()
        end
    end
    if indicator.orbShells then
        for i = 1, 4 do
            indicator.orbShells[i]:Hide()
        end
    end
end

local function RenderBossTriplet(indicator, statesByDiff, viewMode)
    indicator:Show()
    indicator:SetTexCoord(0, 1, 0, 1)
    if indicator.text then indicator.text:Hide() end
    -- Base indicator acts as an anchor; actual visuals are 3 tiny orbs.
    indicator:SetTexture(nil)
    indicator:SetAlpha(0)
    EnsureTripletOrbs(indicator)

    local isDark = (lv.currentTheme == "dark")
    local theme = lv.GetTheme and lv.GetTheme() or nil
    local darkButton = (theme and theme.buttonBgAlt) or {0.10, 0.10, 0.10, 1.0}
    local lightButton = (theme and theme.buttonBgAlt) or {0.28, 0.33, 0.28, 1.0}
    local killColor = isDark and {0.58, 0.34, 0.86, 1.0} or {0.50, 0.58, 0.47, 1.0}
    local unkillColor = isDark and {darkButton[1], darkButton[2], darkButton[3], 1.0} or {lightButton[1], lightButton[2], lightButton[3], 1.0}
    -- Keep dark-mode borders neutral so kill fill doesn't blend into the border.
    local shellColor
    if isDark then
        -- Dark-mode border tone: #56019c
        shellColor = {0.337, 0.004, 0.612, 0.82}
    else
        local shellBase = (theme and theme.borderPrimary) or {0.2, 0.2, 0.2, 1.0}
        shellColor = {shellBase[1], shellBase[2], shellBase[3], 0.68}
    end

    for i = 1, 4 do
        local orb = indicator.orbs[i]
        local shell = indicator.orbShells and indicator.orbShells[i]
        local state = statesByDiff and statesByDiff[i] or {}
        local hasData = state.hasData
        local isKilled = state.isKilled

        if isKilled and hasData then
            orb:SetVertexColor(killColor[1], killColor[2], killColor[3], killColor[4] or 1.0)
        else
            orb:SetVertexColor(unkillColor[1], unkillColor[2], unkillColor[3], unkillColor[4] or 1.0)
        end

        if shell then
            shell:SetVertexColor(shellColor[1], shellColor[2], shellColor[3], shellColor[4] or 1.0)
            shell:Show()
        end

        orb:SetAlpha(1.0)
        orb:SetDesaturated(false)
        orb:Show()
    end
end

local function GetBossStateForDifficulty(playerData, raidName, bosses, bossIndex, difficultyID, viewMode)
    local targetKey = currentRaidCharKey or lv.PLAYER_KEY
    local liveRaidState = lv._liveRaidState
    local isViewingCurrentPlayer = (targetKey == lv.PLAYER_KEY)

    -- Current lockout display is API-truth for the active player.
    if viewMode == "lockouts" and isViewingCurrentPlayer and liveRaidState then
        local raidState = liveRaidState[raidName]
        local diffState = raidState and raidState[difficultyID]
        if diffState and diffState.bosses then
            return true, diffState.bosses[bossIndex] == true
        end
        return true, false
    end

    if viewMode == "progression" then
        local diffKey = GetDifficultyKey(difficultyID)
        local raidKills = playerData and playerData.raidKills and playerData.raidKills[raidName]
        if raidKills and diffKey and raidKills[diffKey] then
            return true, raidKills[diffKey][bossIndex] == true
        end

        local prog = playerData and playerData.raidProgression and playerData.raidProgression[difficultyID]
        if prog and prog.bosses then
            local savedName = prog.bossNames and prog.bossNames[bossIndex]
            if savedName and bosses[bossIndex] and savedName == bosses[bossIndex] then
                return true, prog.bosses[bossIndex] == true
            end
        end
        return false, false
    end

    local lockout = playerData and playerData.raidLockouts and playerData.raidLockouts[raidName] and playerData.raidLockouts[raidName][difficultyID]
    if lockout and lockout.bosses then
        local savedName = lockout.bossNames and lockout.bossNames[bossIndex]
        if savedName and bosses[bossIndex] and savedName == bosses[bossIndex] then
            return true, lockout.bosses[bossIndex] == true
        end
    end
    return false, false
end

local function EnsureRaidKills(playerData, raidName)
    if not playerData then return nil end
    playerData.raidKills = playerData.raidKills or {}
    playerData.raidKills[raidName] = playerData.raidKills[raidName] or {
        lfr = {},
        normal = {},
        heroic = {},
        mythic = {},
        bossNames = {},
        updatedAt = 0
    }
    return playerData.raidKills[raidName]
end

local function HasLegacyRaidLockoutSchema(raidLockouts)
    if type(raidLockouts) ~= "table" then return false end
    for k, v in pairs(raidLockouts) do
        if type(k) == "number" and type(v) == "table" and v.bosses then
            return true
        end
    end
    return false
end

local function EnsureRaidLockoutsSchema(playerData)
    if not playerData then return end
    playerData.raidLockouts = playerData.raidLockouts or {}

    -- One-time migration from old difficulty-only schema.
    if playerData.raidLockoutsSchemaVersion ~= 2 and HasLegacyRaidLockoutSchema(playerData.raidLockouts) then
        playerData.raidLockouts = {}
    end

    for raidName in pairs(MIDNIGHT_RAIDS) do
        playerData.raidLockouts[raidName] = playerData.raidLockouts[raidName] or {}
    end
    playerData.raidLockoutsSchemaVersion = 2
end

local function EnsureRaidLockoutBucket(playerData, raidName, difficultyID)
    if not playerData or not raidName or not difficultyID then return nil end
    EnsureRaidLockoutsSchema(playerData)
    playerData.raidLockouts[raidName][difficultyID] = playerData.raidLockouts[raidName][difficultyID] or {
        bosses = {},
        bossNames = {},
        scannedAt = GetServerTime()
    }
    return playerData.raidLockouts[raidName][difficultyID]
end

local function BackfillRaidKillsFromStatistics(playerData)
    if not playerData then return end
    for raidName, bosses in pairs(BossStatMap) do
        local raidKills = EnsureRaidKills(playerData, raidName)
        for bossIndex, diffStats in pairs(bosses or {}) do
            for diffKey, statID in pairs(diffStats or {}) do
                local statText = select(1, GetStatistic(statID))
                local statVal = tonumber(statText) or 0
                if statVal > 0 and raidKills[diffKey] then
                    -- Boolean-only progression seed: killed at least once.
                    raidKills[diffKey][bossIndex] = true
                    if MIDNIGHT_RAIDS[raidName] and MIDNIGHT_RAIDS[raidName].bosses then
                        raidKills.bossNames[bossIndex] = MIDNIGHT_RAIDS[raidName].bosses[bossIndex]
                    end
                end
            end
        end
        raidKills.updatedAt = GetServerTime()
    end
end

-- Debounce raid info requests to avoid request/update loops.
local raidInfoRequestPending = false

-- Scan lockouts using API only (no UI manipulation to avoid taint)
function lv.ScanRaidLockouts()
    if not LiteVaultDB then return end

    local playerData = LiteVaultDB[lv.PLAYER_KEY]
    if not playerData then return end

    -- Weekly reset check - clear lockout data if reset has occurred
    local currentTime = GetServerTime()
    local lastLockoutReset = playerData.lastLockoutReset or 0
    local nextReset = currentTime + C_DateAndTime.GetSecondsUntilWeeklyReset()

    -- If nextReset is less than a week away and lastLockoutReset was before the previous reset
    -- then a reset has occurred
    if lastLockoutReset > 0 and lastLockoutReset < (nextReset - 604800) then
        -- Weekly reset occurred, clear lockout data
        playerData.raidLockouts = {}
    end
    playerData.lastLockoutReset = currentTime

    -- Initialize raid lockout data (current week)
    EnsureRaidLockoutsSchema(playerData)

    -- Initialize raid progression data (best ever - never decreases)
    if not playerData.raidProgression then
        playerData.raidProgression = {}
    end
    if not playerData.raidKills then
        playerData.raidKills = {}
    end
    if not playerData.raidKillsBackfilled and next(BossStatMap) then
        BackfillRaidKillsFromStatistics(playerData)
        playerData.raidKillsBackfilled = true
    end

    -- Ensure progression buckets exist per difficulty.
    for _, diff in ipairs(lv.RAID_DIFFICULTIES) do
        if not playerData.raidProgression[diff.id] then
            playerData.raidProgression[diff.id] = {bosses = {}, bossNames = {}, killCount = 0}
        end
    end

    -- Request fresh data from server, then scan after delay (debounced).
    if raidInfoRequestPending then return end
    raidInfoRequestPending = true
    RequestRaidInfo()
    C_Timer.After(0.5, function()
        raidInfoRequestPending = false
        if lv and lv.ScanRaidInfoPanel then
            lv.ScanRaidInfoPanel()
        end
    end)
end

local function LearnTrackedRaidMapID(raidName, mapID)
    mapID = tonumber(mapID)
    if not raidName or not mapID or mapID <= 0 then return end
    if not MIDNIGHT_RAIDS[raidName] then return end
    lv.CURRENT_TIER_MAPS = lv.CURRENT_TIER_MAPS or {}
    lv.CURRENT_TIER_MAP_KEYS = lv.CURRENT_TIER_MAP_KEYS or {}
    lv.CURRENT_TIER_MAPS[mapID] = true
    lv.CURRENT_TIER_MAP_KEYS[mapID] = raidName
end

local function DetectTrackedRaid(instanceName, mapID)
    if mapID and lv.CURRENT_TIER_MAPS and lv.CURRENT_TIER_MAPS[mapID] then
        local byMap = lv.CURRENT_TIER_MAP_KEYS and lv.CURRENT_TIER_MAP_KEYS[mapID]
        if byMap and MIDNIGHT_RAIDS[byMap] then
            return true, byMap
        end
    end
    if not instanceName then return false, nil end
    for raidName, _ in pairs(MIDNIGHT_RAIDS) do
        if instanceName == raidName or instanceName:find(raidName, 1, true) then
            LearnTrackedRaidMapID(raidName, mapID)
            return true, raidName
        end
    end
    return false, nil
end

-- Scan the actual raid info panel for lockout data
function lv.ScanRaidInfoPanel()
    if not LiteVaultDB or not LiteVaultDB[lv.PLAYER_KEY] then return end

    local playerData = LiteVaultDB[lv.PLAYER_KEY]
    lv._liveRaidState = {}

    -- Rebuild current-week lockout table from API snapshot each scan.
    EnsureRaidLockoutsSchema(playerData)
    for raidName in pairs(MIDNIGHT_RAIDS) do
        for _, diff in ipairs(lv.RAID_DIFFICULTIES or {}) do
            playerData.raidLockouts[raidName][diff.id] = {bosses = {}, bossNames = {}, scannedAt = GetServerTime()}
        end
    end

    -- Use the built-in API but with better validation
    for i = 1, GetNumSavedInstances() do
        local name, _, reset, difficulty, locked, extended, _, isRaid, _, _, numBosses, _, _, _, mapID = GetSavedInstanceInfo(i)

        -- Detect current tracked raid by mapID or Midnight raid name.
        local isCurrentRaid, trackedRaidName = DetectTrackedRaid(name, mapID)

        -- Only scan ACTIVE lockouts (reset > 0 means it expires in the future = current week)
        -- Expired lockouts (reset = 0) are from previous weeks and should be ignored
        local isActiveLockout = reset and reset > 0

        -- Skip expired lockouts (from previous weeks)
        if isRaid and isCurrentRaid and not isActiveLockout and IsTrackedRaidDifficulty(difficulty) then
        end

        if isRaid and isCurrentRaid and isActiveLockout and IsTrackedRaidDifficulty(difficulty) then
            local resolvedRaidName = trackedRaidName
            if not MIDNIGHT_RAIDS[resolvedRaidName or ""] and name then
                for raidName, _ in pairs(MIDNIGHT_RAIDS) do
                    if name == raidName or name:find(raidName, 1, true) then
                        resolvedRaidName = raidName
                        break
                    end
                end
            end
            local raidInfo = MIDNIGHT_RAIDS[resolvedRaidName or ""]
            LearnTrackedRaidMapID(resolvedRaidName, mapID)
            local trackedBossCount = (raidInfo and raidInfo.bossCount) or lv.NUM_RAID_BOSSES

            local canStoreLiveState = resolvedRaidName and MIDNIGHT_RAIDS[resolvedRaidName]
            if canStoreLiveState then
                -- Live, API-authoritative state for current lockout rendering.
                lv._liveRaidState[resolvedRaidName] = lv._liveRaidState[resolvedRaidName] or {}
                lv._liveRaidState[resolvedRaidName][difficulty] = lv._liveRaidState[resolvedRaidName][difficulty] or {
                    bosses = {},
                    bossNames = {},
                    scannedAt = GetServerTime()
                }
            end

            -- Scan the lockout data
            for bossIndex = 1, math.min(numBosses, trackedBossCount) do
                local bossName, _, isDead = GetSavedInstanceEncounterInfo(i, bossIndex)
                if bossName then
                    -- Update current week's lockout (live scan is authoritative).
                    if isDead then
                        local lockout = EnsureRaidLockoutBucket(playerData, resolvedRaidName, difficulty)
                        local canonicalName = (raidInfo and raidInfo.bosses and raidInfo.bosses[bossIndex]) or bossName
                        if lockout then
                            lockout.bosses[bossIndex] = true
                            lockout.bossNames[bossIndex] = canonicalName
                            lockout.scannedAt = GetServerTime()
                        end
                        if canStoreLiveState then
                            lv._liveRaidState[resolvedRaidName][difficulty].bosses[bossIndex] = true
                            lv._liveRaidState[resolvedRaidName][difficulty].bossNames[bossIndex] = canonicalName
                        end
                    end
                end
            end
        end
    end

    -- Reconcile persistent progression from live API snapshot.
    playerData.raidProgression = playerData.raidProgression or {}
    playerData.raidKills = playerData.raidKills or {}
    for raidName, byDiff in pairs(lv._liveRaidState) do
        for diffID, diffState in pairs(byDiff or {}) do
            if IsTrackedRaidDifficulty(diffID) then
                playerData.raidProgression[diffID] = playerData.raidProgression[diffID] or {bosses = {}, bossNames = {}, killCount = 0}
                local diffKey = GetDifficultyKey(diffID)
                local raidKills = (diffKey and EnsureRaidKills(playerData, raidName)) or nil
                for bossIndex, isKilled in pairs(diffState.bosses or {}) do
                    if isKilled then
                        local bossName = (diffState.bossNames and diffState.bossNames[bossIndex]) or (MIDNIGHT_RAIDS[raidName] and MIDNIGHT_RAIDS[raidName].bosses and MIDNIGHT_RAIDS[raidName].bosses[bossIndex])
                        playerData.raidProgression[diffID].bosses[bossIndex] = true
                        if bossName then
                            playerData.raidProgression[diffID].bossNames[bossIndex] = bossName
                        end
                        if raidKills and diffKey then
                            raidKills[diffKey][bossIndex] = true
                            if bossName then
                                raidKills.bossNames[bossIndex] = bossName
                            end
                            raidKills.updatedAt = GetServerTime()
                        end
                    end
                end
                local killCount = 0
                for _, killed in pairs(playerData.raidProgression[diffID].bosses or {}) do
                    if killed then killCount = killCount + 1 end
                end
                playerData.raidProgression[diffID].killCount = killCount
            end
        end
    end

    -- Update the UI if it's showing
    if RaidLockoutWindow and RaidLockoutWindow:IsShown() then
        lv.UpdateRaidLockoutGrid()
    end
end

-- Helper function to count progression kills for a character
function lv.GetProgressionKills(charKey, difficultyId)
    if not LiteVaultDB or not LiteVaultDB[charKey] then return 0 end
    local data = LiteVaultDB[charKey]
    if not data.raidProgression or not data.raidProgression[difficultyId] then return 0 end
    return data.raidProgression[difficultyId].killCount or 0
end

-- Create the Raid Lockout Window
local RaidLockoutWindow = CreateFrame("Frame", "LiteVaultRaidFrame", UIParent, "BackdropTemplate")
RaidLockoutWindow:SetSize(700, 440) -- Reduced size for less wasted space
RaidLockoutWindow:SetPoint("CENTER")
RaidLockoutWindow:SetFrameStrata("DIALOG")
RaidLockoutWindow:SetMovable(true)
RaidLockoutWindow:EnableMouse(true)
RaidLockoutWindow:RegisterForDrag("LeftButton")
RaidLockoutWindow:SetScript("OnDragStart", function(self) self:StartMoving() end)
RaidLockoutWindow:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
RaidLockoutWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
RaidLockoutWindow:Hide()

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(RaidLockoutWindow, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundSolid))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            -- Refresh grid to update button colors when theme changes
            if f:IsShown() then
                lv.UpdateRaidLockoutGrid()
            end
        end)
        local t = lv.GetTheme()
        RaidLockoutWindow:SetBackdropColor(unpack(t.backgroundSolid))
        RaidLockoutWindow:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

-- FIXED: Register with escape handler so it closes when user hits Escape
RaidLockoutWindow:SetScript("OnShow", function(self)
    table.insert(UISpecialFrames, "LiteVaultRaidFrame")
    -- Ensure saved theme is applied before first paint of this window.
    if LiteVaultDB and LiteVaultDB.theme and lv.Themes and lv.Themes[LiteVaultDB.theme] then
        lv.currentTheme = LiteVaultDB.theme
        if lv.ApplyTheme then
            lv.ApplyTheme()
        end
    end
    -- Refresh immediately on open so first load is correct without mode toggles.
    if lv.ScanRaidLockouts then
        lv.ScanRaidLockouts()
    end
    C_Timer.After(0, function()
        if self and self:IsShown() and lv.UpdateRaidLockoutGrid then
            lv.UpdateRaidLockoutGrid()
        end
    end)
    -- Some theme state initializes slightly later on login/reload; refresh again.
    C_Timer.After(0.2, function()
        if self and self:IsShown() and lv.UpdateRaidLockoutGrid then
            lv.UpdateRaidLockoutGrid()
        end
    end)
end)

RaidLockoutWindow:SetScript("OnHide", function(self)
    -- Remove from escape handler when hidden
    for i, frameName in ipairs(UISpecialFrames) do
        if frameName == "LiteVaultRaidFrame" then
            table.remove(UISpecialFrames, i)
            break
        end
    end
end)

-- Title (will be updated with character name) - Left aligned to avoid buttons
local title = RaidLockoutWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 15, -15)
title:SetText("|cffa335ee" .. L["TITLE_RAID_LOCKOUTS_WINDOW"] .. "|r - " .. ((L["LABEL_MIDNIGHT_SEASON_1"] ~= "LABEL_MIDNIGHT_SEASON_1") and L["LABEL_MIDNIGHT_SEASON_1"] or "Season 1 of Midnight"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(title, 15)
end
RaidLockoutWindow.title = title

-- Bottom-right live marker for current-character lockout API view
local liveTagText = RaidLockoutWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
liveTagText:SetPoint("BOTTOMRIGHT", RaidLockoutWindow, "BOTTOMRIGHT", -14, 10)
liveTagText:SetText("|cff2ecc71[LIVE]|r")
liveTagText:Hide()
RaidLockoutWindow.liveTagText = liveTagText

local function RefreshRaidWindowTitle()
    if not RaidLockoutWindow or not RaidLockoutWindow.title then return end
    local playerKey = currentRaidCharKey or lv.PLAYER_KEY
    local charName = (playerKey and playerKey:match("^([^-]+)")) or UnitName("player") or "Character"
    local classTag = (LiteVaultDB and playerKey and LiteVaultDB[playerKey] and LiteVaultDB[playerKey].class) or select(2, UnitClass("player")) or "WARRIOR"
    local cc = C_ClassColor.GetClassColor(classTag or "WARRIOR")
    local nameHex = (cc and cc.GenerateHexColor and cc:GenerateHexColor()) or "ffffffff"
    local modeTitle = (currentViewMode == "progression") and LT("Raid Progression") or (L["TITLE_RAID_LOCKOUTS_WINDOW"] or "Raid Lockouts")
    local isCurrentPlayerView = (playerKey == lv.PLAYER_KEY)
    local seasonText = ((L["LABEL_MIDNIGHT_SEASON_1"] ~= "LABEL_MIDNIGHT_SEASON_1") and L["LABEL_MIDNIGHT_SEASON_1"] or "Season 1 of Midnight")
    RaidLockoutWindow.title:SetText(string.format("|c%s%s|r|cffa335ee's %s|r - %s", nameHex, charName, modeTitle, seasonText))

    if RaidLockoutWindow.liveTagText then
        if currentViewMode == "lockouts" and isCurrentPlayerView then
            RaidLockoutWindow.liveTagText:Show()
        else
            RaidLockoutWindow.liveTagText:Hide()
        end
    end
end

-- Close Button
local closeBtn = CreateFrame("Button", nil, RaidLockoutWindow, "BackdropTemplate")
closeBtn:SetSize((lv.Layout and lv.Layout.raidCloseWidth) or 70, 26)
closeBtn:SetPoint("TOPRIGHT", -10, -10)
closeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
closeTxt:SetPoint("CENTER")
closeTxt:SetText(L["BUTTON_CLOSE"])
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(closeTxt, 11)
end
closeBtn.Text = closeTxt
lv.raidLockoutsCloseBtn = closeBtn

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(closeBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        closeBtn:SetBackdropColor(unpack(t.buttonBgAlt))
        closeBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

closeBtn:SetScript("OnClick", function() RaidLockoutWindow:Hide() end)
closeBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
closeBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

-- View Mode Toggle Button (Lockouts vs Progression)
local viewToggleBtn = CreateFrame("Button", nil, RaidLockoutWindow, "BackdropTemplate")
viewToggleBtn:SetSize((lv.Layout and lv.Layout.raidViewToggleWidth) or 110, 26)
viewToggleBtn:SetPoint("RIGHT", closeBtn, "LEFT", -10, 0)
viewToggleBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

local viewToggleTxt = viewToggleBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
viewToggleTxt:SetPoint("CENTER")
viewToggleTxt:SetText(L["BUTTON_PROGRESSION"])
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(viewToggleTxt, 11)
end
viewToggleBtn.text = viewToggleTxt

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(viewToggleBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        viewToggleBtn:SetBackdropColor(unpack(t.buttonBgAlt))
        viewToggleBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

viewToggleBtn:SetScript("OnClick", function(self)
    if currentViewMode == "lockouts" then
        currentViewMode = "progression"
        self.text:SetText(L["BUTTON_PROGRESSION"])
    else
        currentViewMode = "lockouts"
        self.text:SetText(L["BUTTON_LOCKOUTS"])
    end
    RefreshRaidWindowTitle()
    lv.UpdateRaidLockoutGrid()
end)

viewToggleBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.text:SetTextColor(unpack(t.textPrimary))
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    if currentViewMode == "lockouts" then
        GameTooltip:SetText(L["TOOLTIP_VIEW_LOCKOUTS"], 1, 1, 1)
        GameTooltip:AddLine(L["TOOLTIP_VIEW_LOCKOUTS_SWITCH"], 0.7, 0.7, 0.7)
    else
        GameTooltip:SetText(L["TOOLTIP_VIEW_PROGRESSION"], 1, 1, 1)
        GameTooltip:AddLine(L["TOOLTIP_VIEW_PROGRESSION_SWITCH"], 0.7, 0.7, 0.7)
    end
    GameTooltip:Show()
end)

viewToggleBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
    self.text:SetTextColor(unpack(t.textPrimary))
    GameTooltip:Hide()
end)

RaidLockoutWindow.viewToggleBtn = viewToggleBtn
lv.raidViewToggleBtn = viewToggleBtn

-- Difficulty Tabs (Vertical on left side, centered)
local diffButtons = {}
local SHOW_DIFFICULTY_SELECTOR = false

for i, diff in ipairs(lv.RAID_DIFFICULTIES) do
    local btn = CreateFrame("Button", nil, RaidLockoutWindow, "BackdropTemplate")
    btn:SetSize((lv.Layout and lv.Layout.raidDifficultyWidth) or 90, 28)
    btn:SetPoint("TOPLEFT", 15, -180 - ((i-1) * 35)) -- Moved down to center vertically
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btnText:SetPoint("CENTER")
    btnText:SetText(L[diff.nameKey])
    if lv.ApplyLocaleFont then
        lv.ApplyLocaleFont(btnText, 11)
    end
    
    btn.diffID = diff.id
    btn.text = btnText
    
    btn:SetScript("OnClick", function(self)
        currentDifficulty = self.diffID
        lv.UpdateRaidLockoutGrid()
    end)
    
    btn:SetScript("OnEnter", function(self)
        self.isHovered = true
        if currentDifficulty ~= self.diffID then
            local t = lv.GetTheme()
            self:SetBackdropBorderColor(unpack(t.borderHover))
        end
    end)

    btn:SetScript("OnLeave", function(self)
        self.isHovered = false
        if currentDifficulty ~= self.diffID then
            if lv.currentTheme == "light" then
                self:SetBackdropBorderColor(0.20, 0.20, 0.20, 0.6)
            else
                self:SetBackdropBorderColor(0.5, 0.2, 0.8, 0.6)
            end
        end
    end)

    diffButtons[diff.id] = btn
    if not SHOW_DIFFICULTY_SELECTOR then
        btn:Hide()
        btn:EnableMouse(false)
    end
end
lv.raidDiffButtons = diffButtons

-- Boss Name Headers (dynamic for selected raid)
local maxBosses = 8 -- Maximum possible bosses in any raid (for grid allocation)
local bossHeaders = {}
local gridStartX = 180 -- Shifted right to avoid difficulty slider
local columnWidth = 80 -- Width of each boss column
for i = 1, maxBosses do
    local header = CreateFrame("Frame", nil, RaidLockoutWindow)
    header:SetSize(columnWidth, 40)
    -- Move boss headers further down to avoid overlap with tabs
    local xPos = gridStartX + ((i - 0.5) * columnWidth) - 375
    header:SetPoint("CENTER", xPos, 110) -- moved further down to avoid title overlap
    local nameText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOP", 0, 0)
    nameText:SetWidth(columnWidth - 4)
    nameText:SetWordWrap(false)
    nameText:SetJustifyH("CENTER")
    nameText:SetText("")
    local separator = header:CreateTexture(nil, "ARTWORK")
    separator:SetSize(columnWidth - 4, 1)
    -- Keep the separator tied to the label position so it always sits just under boss names.
    separator:SetPoint("TOP", nameText, "BOTTOM", 0, -2)
    local function GetBossNameColor()
        if lv.currentTheme == "dark" then
            return 0.9, 0.7, 1, 1
        else
            return 1, 0.82, 0, 1
        end
    end
    local function GetSeparatorColor()
        if lv.currentTheme == "dark" then
            return 0.5, 0.2, 0.8, 0.6
        else
            return 0.2, 0.2, 0.2, 0.6
        end
    end
    nameText:SetTextColor(GetBossNameColor())
    separator:SetColorTexture(GetSeparatorColor())
    header.bossIndex = i
    header.nameText = nameText
    header.separator = separator
    header.GetBossNameColor = GetBossNameColor
    header.GetSeparatorColor = GetSeparatorColor
    header:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if self.bossName then
            GameTooltip:SetText(self.bossName, 1, 0.82, 0)
        else
            GameTooltip:SetText("", 1, 0.82, 0)
        end
        GameTooltip:Show()
        separator:SetColorTexture(1, 0.82, 0, 1)
        nameText:SetTextColor(1, 0.82, 0, 1)
    end)
    header:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        local theme = lv.GetTheme and lv.GetTheme() or { borderPrimary = {0.6, 0.2, 1, 1} }
        separator:SetColorTexture(header.GetSeparatorColor())
        nameText:SetTextColor(header.GetBossNameColor())
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(unpack(theme.borderPrimary)) end
    end)
    bossHeaders[i] = {frame = header, nameText = nameText, separator = separator}
end

-- Register boss headers for theme updates
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for i, headerData in ipairs(bossHeaders) do
            lv.RegisterThemedElement(headerData.frame, function(f, theme)
                if lv.currentTheme == "dark" then
                    headerData.nameText:SetTextColor(0.9, 0.7, 1, 1)
                    headerData.separator:SetColorTexture(0.5, 0.2, 0.8, 0.6)
                else
                    headerData.nameText:SetTextColor(1, 0.82, 0, 1)
                    headerData.separator:SetColorTexture(0.2, 0.2, 0.2, 0.6)
                end
            end)
        end
    end
end)

-- Character Rows (no grid lines needed for single character view)
local charRows = {}
local maxRows = 20

for i = 1, maxRows do
    local row = CreateFrame("Frame", nil, RaidLockoutWindow, "BackdropTemplate")
    row:SetSize(maxBosses * columnWidth + 190, 40)
    row:SetPoint("TOPLEFT", RaidLockoutWindow, "TOPLEFT", 20, -145 - ((i - 1) * 42))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })

    -- Alternating row colors (striping for even rows)
    if i % 2 == 0 then
        row:SetBackdropColor(1, 1, 1, 0.05)
    else
        row:SetBackdropColor(0, 0, 0, 0)
    end

    -- Theme-aware border color
    row.UpdateTheme = function(self)
        local t = lv.GetTheme()
        self:SetBackdropColor(0.0, 0.0, 0.0, 0.0)
        self:SetBackdropBorderColor(0.0, 0.0, 0.0, 0.0)
        if self.diffLabels then
            for _, labelSet in ipairs(self.diffLabels) do
                if labelSet then
                    for _, fs in ipairs(labelSet) do
                        fs:SetTextColor(1, 1, 1, 0.95)
                    end
                end
            end
        end
    end
    row:UpdateTheme()
    
    -- Character name (hidden for character-specific view)
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("LEFT", 15, 0)
    row.nameText:SetWidth(100)
    row.nameText:SetJustifyH("LEFT")
    
    row:UpdateTheme()
    
    -- Boss kill indicators - centered under boss name headers
    row.bossIndicators = {}
    row.diffLabels = {}
    for b = 1, maxBosses do
        local indicator = row:CreateTexture(nil, "ARTWORK")
        indicator:SetSize(72, 32)
        indicator:SetDrawLayer("OVERLAY", 7)
        -- Move indicators further down to avoid overlap with headers
        local xPos = gridStartX + ((b - 0.5) * columnWidth) - 375
        indicator:SetPoint("CENTER", xPos, -30) -- was 0, now -30 for more space
        row.bossIndicators[b] = indicator

        local offsets = {-26, -9, 9, 26}
        local tokens = {"L", "N", "H", "M"}
        local labelSet = {}
        for idx = 1, 4 do
            local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            label:SetPoint("TOP", indicator, "BOTTOM", offsets[idx], 1)
            label:SetText(tokens[idx])
            label:SetJustifyH("CENTER")
            labelSet[idx] = label
        end
        row.diffLabels[b] = labelSet
    end
    
    charRows[i] = row
    row:Hide()
end

-- Register character rows for theme updates
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for _, row in ipairs(charRows) do
            lv.RegisterThemedElement(row, function(r, theme)
                r:UpdateTheme()
            end)
        end
    end
end)

-- FIXED: Update the grid with better validation and debug info
function lv.UpdateRaidLockoutGrid()
    RefreshRaidWindowTitle()
    -- Update difficulty button states
    if SHOW_DIFFICULTY_SELECTOR then
        for diffID, btn in pairs(diffButtons) do
            if diffID == currentDifficulty then
                -- Active button
                if lv.currentTheme == "light" then
                    btn:SetBackdropColor(0.35, 0.42, 0.35, 1)  -- Sage green active
                    btn:SetBackdropBorderColor(0.20, 0.20, 0.20, 1)  -- Dark grey border
                else
                    btn:SetBackdropColor(0.2, 0.1, 0.3, 1)  -- Void purple active
                    btn:SetBackdropBorderColor(0.6, 0.2, 1, 1)  -- Void purple border
                end
            else
                -- Inactive button
                if lv.currentTheme == "light" then
                    btn:SetBackdropColor(0.30, 0.35, 0.30, 0.9)  -- Sage green inactive
                else
                    btn:SetBackdropColor(0.1, 0.05, 0.15, 0.9)  -- Void purple inactive
                end
                -- Only reset border if not being hovered
                if not btn.isHovered then
                    if lv.currentTheme == "light" then
                        btn:SetBackdropBorderColor(0.20, 0.20, 0.20, 0.6)  -- Dark grey border
                    else
                        btn:SetBackdropBorderColor(0.5, 0.2, 0.8, 0.6)  -- Void purple border
                    end
                end
            end
        end
    end
    
    -- Use selected Midnight S1 raid bosses for headers
    local raidName = selectedRaidTab or raidTabs[1]
    local raidData = MIDNIGHT_RAIDS[raidName]
    local bosses = raidData and raidData.bosses or {}
    local bossCount = (raidData and raidData.bossCount) or #bosses
    lv.NUM_RAID_BOSSES = bossCount
    for i = 1, #bossHeaders do
        if i <= bossCount and bosses[i] then
            bossHeaders[i].nameText:SetText(LT(bosses[i]))
            bossHeaders[i].frame.bossName = LT(bosses[i])
            bossHeaders[i].frame:Show()
        else
            bossHeaders[i].nameText:SetText("")
            bossHeaders[i].frame.bossName = nil
            bossHeaders[i].frame:Hide()
        end
    end

    -- Hide all rows first
    for _, row in ipairs(charRows) do
        row:Hide()
    end

    local targetKey = currentRaidCharKey or lv.PLAYER_KEY
    local playerData = LiteVaultDB and LiteVaultDB[targetKey]
    if not playerData then
        if RaidLockoutWindow.noDataText then
            RaidLockoutWindow.noDataText:SetText("|cffff8000" .. L["MSG_NO_CHAR_DATA"] .. "|r")
            RaidLockoutWindow.noDataText:Show()
        end
        return
    end

    if RaidLockoutWindow.noDataText then
        RaidLockoutWindow.noDataText:Hide()
    end

    local row = charRows[1]
    if not row then return end
    row.nameText:SetText("")
    -- Restore old Claude indicator logic, adapted to current dynamic raid boss count
    for bossIdx = 1, #bossHeaders do
        local indicator = row.bossIndicators[bossIdx]
        local diffLabelSet = row.diffLabels and row.diffLabels[bossIdx]
        if bossIdx <= bossCount then
            local headerFrame = bossHeaders[bossIdx] and bossHeaders[bossIdx].frame
            indicator:ClearAllPoints()
            if headerFrame then
                -- Invisible grid anchor: marker is pinned to the matching boss header column.
                indicator:SetPoint("TOP", headerFrame, "BOTTOM", 0, 26)
            else
                indicator:SetPoint("CENTER", 0, -30)
            end
            if diffLabelSet then
                for _, label in ipairs(diffLabelSet) do
                    label:Show()
                end
            end
            local statesByDiff = {}
            for orbIdx, diffID in ipairs(DIFF_ORDER) do
                local hasData, isKilled = GetBossStateForDifficulty(playerData, raidName, bosses, bossIdx, diffID, currentViewMode)
                statesByDiff[orbIdx] = {hasData = hasData, isKilled = isKilled}
            end
            RenderBossTriplet(indicator, statesByDiff, currentViewMode)
        else
            if indicator.text then indicator.text:Hide() end
            HideTripletOrbs(indicator)
            indicator:Hide()
            if diffLabelSet then
                for _, label in ipairs(diffLabelSet) do
                    label:Hide()
                end
            end
        end
    end

    row:Show()
    for i = 2, maxRows do
        charRows[i]:Hide()
    end
end

-- FIXED: Public function to show window with better timing
function lv.ShowRaidLockoutWindow(charKey)
    local targetKey = charKey or lv.PLAYER_KEY
    if RaidLockoutWindow:IsShown() and currentRaidCharKey == targetKey then
        RaidLockoutWindow:Hide()
    else
        currentRaidCharKey = targetKey
        -- Force theme refresh for raid tab buttons
        for _, btn in pairs(raidTabButtons) do
            if lv.GetTheme and btn and btn.SetBackdropColor then
                local theme = lv.GetTheme()
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                if btn.Text then
                    btn.Text:SetTextColor(unpack(theme.textSecondary))
                end
            end
        end
        -- Force theme refresh for boss headers
        local theme = lv.GetTheme and lv.GetTheme() or { borderPrimary = {0.6, 0.2, 1, 1} }
        for _, header in ipairs(bossHeaders) do
            if header and header.nameText and header.separator then
                -- Ensure color functions are present
                if not header.GetBossNameColor then
                    header.GetBossNameColor = function()
                        if lv.currentTheme == "dark" then
                            return 0.9, 0.7, 1, 1
                        else
                            return 1, 0.82, 0, 1
                        end
                    end
                end
                if not header.GetSeparatorColor then
                    header.GetSeparatorColor = function()
                        if lv.currentTheme == "dark" then
                            return 0.5, 0.2, 0.8, 0.6
                        else
                            return 0.2, 0.2, 0.2, 0.6
                        end
                    end
                end
                header.nameText:SetTextColor(header.GetBossNameColor())
                header.separator:SetColorTexture(header.GetSeparatorColor())
                if header.frame and header.frame.SetBackdropBorderColor then
                    header.frame:SetBackdropBorderColor(unpack(theme.borderPrimary))
                end
            end
        end
        RefreshRaidWindowTitle()
        -- Show immediately; OnShow performs a single scan/update pass.
        RaidLockoutWindow:Show()
    end
end

-- Register events to catch lockout updates
local f = CreateFrame("Frame")
f:RegisterEvent("UPDATE_INSTANCE_INFO")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ENCOUNTER_END")  -- Real-time boss kill tracking
f:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, arg5)
    if event == "UPDATE_INSTANCE_INFO" then
        -- Raid info has been updated by the server; parse panel data only.
        if not InCombatLockdown() then
            raidInfoRequestPending = false
            lv.ScanRaidInfoPanel()
            if RaidLockoutWindow and RaidLockoutWindow:IsShown() then
                lv.UpdateRaidLockoutGrid()
            end
        end
    elseif event == "ADDON_LOADED" and arg1 == addonName then
        -- Scan lockouts when addon loads
        C_Timer.After(2.0, function()
            if not InCombatLockdown() then
                lv.ScanRaidLockouts()
            end
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Scan lockouts when entering world
        C_Timer.After(3.0, function()
            if not InCombatLockdown() then
                lv.ScanRaidLockouts()
            end
        end)
    elseif event == "ENCOUNTER_END" then
        -- Real-time boss kill tracking
        -- arg1 = encounterID, arg2 = encounterName, arg3 = difficultyID, arg4 = raidSize, arg5 = success
        local encounterID, encounterName, difficultyID, raidSize, success = arg1, arg2, arg3, arg4, arg5

        -- Only track successful kills in raid difficulties we care about
        if success == 1 and IsTrackedRaidDifficulty(difficultyID) then
            local playerData = LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY]
            if playerData then
                -- Initialize if needed
                EnsureRaidLockoutsSchema(playerData)
                if not playerData.raidProgression then playerData.raidProgression = {} end
                if not playerData.raidProgression[difficultyID] then
                    playerData.raidProgression[difficultyID] = {bosses = {}, bossNames = {}, killCount = 0}
                end

                -- Find boss index by name across Midnight S1 raids
                local matchedRaidName = nil
                local matchedIndex = nil
                for raidName, raidInfo in pairs(MIDNIGHT_RAIDS) do
                    for i, bossName in ipairs(raidInfo.bosses or {}) do
                        if encounterName and bossName and (encounterName:find(bossName, 1, true) or bossName:find(encounterName, 1, true)) then
                            matchedRaidName = raidName
                            matchedIndex = i
                            break
                        end
                    end
                    if matchedIndex then break end
                end
                if matchedIndex then
                        local diffKey = GetDifficultyKey(difficultyID)
                        local canonicalName = (MIDNIGHT_RAIDS[matchedRaidName] and MIDNIGHT_RAIDS[matchedRaidName].bosses and MIDNIGHT_RAIDS[matchedRaidName].bosses[matchedIndex]) or encounterName
                        local raidKills = (matchedRaidName and diffKey) and EnsureRaidKills(playerData, matchedRaidName) or nil
                        local lockout = EnsureRaidLockoutBucket(playerData, matchedRaidName, difficultyID)
                        -- Update lockout (current week)
                        if lockout then
                            lockout.bosses[matchedIndex] = true
                            lockout.bossNames[matchedIndex] = canonicalName
                            lockout.scannedAt = GetServerTime()
                        end

                        -- Update progression (persistent)
                        playerData.raidProgression[difficultyID].bosses[matchedIndex] = true
                        playerData.raidProgression[difficultyID].bossNames[matchedIndex] = canonicalName

                        -- Recount kills
                        local killCount = 0
                        for _, killed in pairs(playerData.raidProgression[difficultyID].bosses) do
                            if killed then killCount = killCount + 1 end
                        end
                        playerData.raidProgression[difficultyID].killCount = killCount

                        -- Write into per-raid progression store used by raid tabs.
                        if raidKills and diffKey then
                            raidKills[diffKey][matchedIndex] = true
                            raidKills.bossNames[matchedIndex] = canonicalName
                            raidKills.updatedAt = GetServerTime()
                        end

                end

                -- Update UI if showing
                if RaidLockoutWindow and RaidLockoutWindow:IsShown() then
                    lv.UpdateRaidLockoutGrid()
                end
            end
        end
    end
end)


