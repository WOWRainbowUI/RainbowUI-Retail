-- Raid identity and progression. Numeric Blizzard identifiers are authoritative
-- when known; localized names are display/fallback data only.
local addonName, lv = ...
local L = lv.L

local RAID_SCHEMA_VERSION = 5
local CURRENT_RAID_SEASON = "midnight_s2"
local GetEncounterStorageKey
local RecordSeasonRaidKill
local MigrateRaidData
local RaidLockoutWindow

local RAID_SEASONS = {
    midnight_s1 = {
        category = "legacy",
        progressionTrackingActive = false,
        firstKillTrackingActive = false,
        labelKey = "LABEL_MIDNIGHT_SEASON_1",
        raidOrder = { "midnight_s1_voidspire", "midnight_s1_dreamrift", "midnight_s1_sporefall", "midnight_s1_march" },
        raids = {
            midnight_s1_voidspire = {
                displayKey = "The Voidspire", bossCount = 6,
                bosses = { "Imperator Averzian", "Vorasius", "Fallen-King Salhadaar", "Vaelgor & Ezzorak", "Lightblinded Vanguard", "Alleria Windrunner (Crown of the Cosmos)" },
            },
            midnight_s1_dreamrift = { displayKey = "The Dreamrift", bossCount = 1, bosses = { "Chimarus" } },
            midnight_s1_sporefall = { displayKey = "Sporefall", bossCount = 1, bosses = { "Rotmire" }, instanceIDs = { 16279 } },
            midnight_s1_march = { displayKey = "March of Quel'Danas", bossCount = 2, bosses = { "Belo'ren", "L'ura (Midnight Falls)" } },
        },
    },
    midnight_s2 = {
        category = "current",
        progressionTrackingActive = true,
        firstKillTrackingActive = true,
        labelKey = "LABEL_MIDNIGHT_SEASON_2",
        raidOrder = { "midnight_s2_venomous_abyss", "midnight_s2_tidebound_grotto" },
        -- Blizzard has confirmed eight encounters. Numeric instance, journal,
        -- and encounter IDs remain intentionally unset until verified in-client.
        raids = {
            midnight_s2_venomous_abyss = {
                displayKey = "The Venomous Abyss", bossCount = 8, identifiersPending = true,
                difficulties = {
                    { storageKey=17, difficultyID=17, tag="L", labelKey="DIFFICULTY_LFR" },
                    { storageKey=14, difficultyID=14, tag="N", labelKey="DIFFICULTY_NORMAL" },
                    { storageKey=15, difficultyID=15, tag="H", labelKey="DIFFICULTY_HEROIC" },
                    { storageKey=16, difficultyID=16, tag="M", labelKey="DIFFICULTY_MYTHIC" },
                },
                bosses = {
                    "Nek'zali the Soulcoiler", "Entombed Sentinels", "Vashnik the Malignant", "The Lost Explorers",
                    "Sszorak", "The Twin Fangs", "The Coiled Altar", "Ula'tek",
                },
            },
            midnight_s2_tidebound_grotto = {
                displayKey = "The Tidebound Grotto", bossCount = 1, identifiersPending = true,
                difficulties = {
                    { storageKey="world", difficultyID=nil, tag="W", labelKey="DIFFICULTY_WORLD", identifiersPending=true },
                    { storageKey=14, difficultyID=14, tag="N", labelKey="DIFFICULTY_NORMAL" },
                    { storageKey=15, difficultyID=15, tag="H", labelKey="DIFFICULTY_HEROIC" },
                    { storageKey=16, difficultyID=16, tag="M", labelKey="DIFFICULTY_MYTHIC" },
                },
                bosses = { "Nymrissa Wavecaller" },
            },
        },
        achievements = {
            aotc = { labelKey = "LABEL_RAID_AOTC", achievementID = nil },
            cuttingEdge = { labelKey = "LABEL_RAID_CUTTING_EDGE", achievementID = nil },
        },
    },
}

lv.RAID_SEASONS = RAID_SEASONS
lv.CURRENT_RAID_SEASON = CURRENT_RAID_SEASON

local function LT(text)
    return (L and L[text] and L[text] ~= text) and L[text] or text
end

local CATEGORY_DEFAULT_SEASONS = { current = "midnight_s2", legacy = "midnight_s1" }
local selectedCategory = "current"
local selectedSeasonKey = CATEGORY_DEFAULT_SEASONS.current
local selectedRaidBySeason = {
    midnight_s1 = RAID_SEASONS.midnight_s1.raidOrder[1],
    midnight_s2 = RAID_SEASONS.midnight_s2.raidOrder[1],
}
local raidTabs = RAID_SEASONS[selectedSeasonKey].raidOrder
local raidTabButtons = {}
local selectedRaidTab = selectedRaidBySeason[selectedSeasonKey]
local currentRaidCharKey = nil

local function GetSeasonLabel(seasonKey)
    local season = RAID_SEASONS[seasonKey] or {}
    local labelKey = season.labelKey or "LABEL_MIDNIGHT_SEASON_1"
    return L[labelKey] or labelKey
end

local function GetCurrentSeasonLabel()
    return GetSeasonLabel(selectedSeasonKey)
end

local function GetRaidConfig(seasonKey, raidKey)
    local season = RAID_SEASONS[seasonKey]
    return season and season.raids and season.raids[raidKey]
end

local function GetRaidDisplayName(seasonKey, raidKey)
    local raid = GetRaidConfig(seasonKey, raidKey)
    return raid and LT(raid.displayKey) or tostring(raidKey or "")
end

local function FormatRaidCharacterTitle(character, raidsTitle, season)
    local formatText = L["TITLE_RAIDS_CHARACTER_FMT"] or "{character} - {raids} - {season}"
    return (formatText:gsub("{character}", character):gsub("{raids}", raidsTitle):gsub("{season}", season))
end

local function UpdateRaidTabButtonStyles()
    local theme = lv.GetTheme and lv.GetTheme() or nil
    if not theme then return end
    for raidKey, btn in pairs(raidTabButtons) do
        if raidKey == selectedRaidTab then
            btn:SetBackdropColor(unpack(theme.buttonBgActive or theme.buttonBgHover or theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
        else
            btn:SetBackdropColor(unpack(theme.buttonBg or theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end
    end
end

local function ShowRaidTab(raidKey)
    selectedRaidTab = raidKey
    selectedRaidBySeason[selectedSeasonKey] = raidKey
    if lv.InvalidateWarbandRaidCache then lv.InvalidateWarbandRaidCache() end
    UpdateRaidTabButtonStyles()
    if lv.UpdateRaidLockoutGrid then
        lv.UpdateRaidLockoutGrid()
    end
end

local function SizeRaidTabButtonToLabel(button)
    if not button or not button.Text then return end
    local minimumWidth = (lv.Layout and lv.Layout.raidTabWidth) or 130
    local labelWidth = math.ceil(button.Text:GetStringWidth() or 0)
    button:SetWidth(math.max(minimumWidth, labelWidth + 32))
end

local function CreateRaidTabs(parent)
    local title = parent.title or parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    if not parent.title then
        title:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -18)
        title:SetText(L["TITLE_RAIDS"] or "Raids")
        if lv.ApplyLocaleFont then
            lv.ApplyLocaleFont(title, 15)
        end
        parent.title = title
    end
    local startX = 40
    local spacing = 140
    for _, existing in pairs(raidTabButtons) do existing:Hide() end
    raidTabs = (RAID_SEASONS[selectedSeasonKey] and RAID_SEASONS[selectedSeasonKey].raidOrder) or {}
    selectedRaidTab = selectedRaidBySeason[selectedSeasonKey] or raidTabs[1]
    for i, raidKey in ipairs(raidTabs) do
        local btnWidth = (lv.Layout and lv.Layout.raidTabWidth) or 130
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(btnWidth, 28)
        if i == 1 then
            btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -112)
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
        btn.Text:SetText(GetRaidDisplayName(selectedSeasonKey, raidKey))
        if lv.ApplyLocaleFont then
            lv.ApplyLocaleFont(btn.Text, 11)
        end
        -- Content-aware width keeps localized short and long raid names inside
        -- their button while retaining the existing LiteVault tab styling.
        SizeRaidTabButtonToLabel(btn)
        btn:SetFrameLevel(parent:GetFrameLevel() + 100)
        btn:SetToplevel(true)
        btn:Raise()
        btn:SetAlpha(1)
        btn:SetScript("OnClick", function()
            ShowRaidTab(raidKey)
        end)
        btn:SetScript("OnEnter", function(self)
            local theme = lv.GetTheme and lv.GetTheme() or nil
            if not theme then return end
            if raidKey ~= selectedRaidTab then
                self:SetBackdropColor(unpack(theme.buttonBgHover or theme.buttonBg))
                self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
            end
        end)
        btn:SetScript("OnLeave", function(self)
            local theme = lv.GetTheme and lv.GetTheme() or nil
            if not theme then return end
            if raidKey == selectedRaidTab then
                self:SetBackdropColor(unpack(theme.buttonBgActive or theme.buttonBgHover or theme.buttonBg))
                self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
            else
                self:SetBackdropColor(unpack(theme.buttonBg or theme.buttonBgAlt))
                self:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end
        end)
        raidTabButtons[raidKey] = btn
        -- Register for theme updates
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(btn, function(f, theme)
                if raidKey == selectedRaidTab then
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

local function ForEachConfiguredRaid(callback)
    for seasonKey, season in pairs(RAID_SEASONS) do
        for raidKey, raidInfo in pairs(season.raids or {}) do
            callback(seasonKey, raidKey, raidInfo)
        end
    end
end

local function NormalizeEncounterName(name)
    if type(name) ~= "string" then
        return ""
    end

    -- Strip punctuation and spaces so boss names still match if Blizzard
    -- changes commas, apostrophes, or parenthetical suffixes.
    return (name:lower():gsub("[%c%p%s]+", ""))
end

local function EncounterNamesMatch(encounterName, bossName)
    if type(encounterName) ~= "string" or type(bossName) ~= "string" then
        return false
    end

    if encounterName == bossName then
        return true
    end

    if encounterName:find(bossName, 1, true) or bossName:find(encounterName, 1, true) then
        return true
    end

    local normalizedEncounter = NormalizeEncounterName(encounterName)
    local normalizedBoss = NormalizeEncounterName(bossName)
    if normalizedEncounter == "" or normalizedBoss == "" then
        return false
    end

    return normalizedEncounter == normalizedBoss
        or normalizedEncounter:find(normalizedBoss, 1, true)
        or normalizedBoss:find(normalizedEncounter, 1, true)
end

-- Expose current selected raid boss count for other UI surfaces (e.g. roster badge).
function lv.GetCurrentRaidBossCount()
    local raidKey = selectedRaidBySeason[CURRENT_RAID_SEASON] or RAID_SEASONS[CURRENT_RAID_SEASON].raidOrder[1]
    return lv.GetRaidBossCount(CURRENT_RAID_SEASON, raidKey)
end

function lv.GetSelectedRaidKey()
    return selectedSeasonKey, selectedRaidTab or raidTabs[1]
end

function lv.GetRaidBossCount(seasonKey, raidKey)
    local raid = GetRaidConfig(seasonKey, raidKey)
    return raid and (raid.bossCount or #(raid.bosses or {})) or 0
end

function lv.GetRaidProgressionCount(charKey, seasonKey, raidKey, difficultyID)
    local playerData = LiteVaultDB and LiteVaultDB[charKey]
    if not playerData then return 0 end
    if not playerData.raidData or playerData.raidData.schemaVersion ~= RAID_SCHEMA_VERSION then MigrateRaidData(playerData) end
    local season = playerData.raidData and playerData.raidData.seasons and playerData.raidData.seasons[seasonKey]
    local raid = season and season.raids and season.raids[raidKey]
    local difficulty = raid and raid.difficulties and raid.difficulties[difficultyID]
    local count, seen = 0, {}
    for _, encounter in pairs((difficulty and difficulty.encounters) or {}) do
        if encounter == true then
            count = count + 1
        elseif type(encounter) == "table" and encounter.killed then
            local identity = encounter.bossIndex and ("index:" .. tostring(encounter.bossIndex))
                or (encounter.encounterID and ("encounter:" .. tostring(encounter.encounterID)))
            if not identity or not seen[identity] then
                count = count + 1
                if identity then seen[identity] = true end
            end
        end
    end
    return count
end

function lv.GetCurrentRaidProgressionKills(charKey, difficultyID)
    local raidKey = selectedRaidBySeason[CURRENT_RAID_SEASON] or RAID_SEASONS[CURRENT_RAID_SEASON].raidOrder[1]
    return lv.GetRaidProgressionCount(charKey, CURRENT_RAID_SEASON, raidKey, difficultyID)
end

-- Current tier map IDs - FIXED: Make sure this table exists and contains correct IDs
if not lv.CURRENT_TIER_MAPS then
    -- Learned dynamically when entering/saving tracked raids.
    lv.CURRENT_TIER_MAPS = {}
end
lv.CURRENT_TIER_MAP_KEYS = lv.CURRENT_TIER_MAP_KEYS or {}
lv.CURRENT_TIER_INSTANCE_IDS = lv.CURRENT_TIER_INSTANCE_IDS or {}
ForEachConfiguredRaid(function(seasonKey, raidKey, raidInfo)
    for _, instanceID in ipairs(raidInfo.instanceIDs or {}) do
        lv.CURRENT_TIER_MAPS[instanceID] = true
        lv.CURRENT_TIER_MAP_KEYS[instanceID] = { seasonKey = seasonKey, raidKey = raidKey }
        lv.CURRENT_TIER_INSTANCE_IDS[instanceID] = { seasonKey = seasonKey, raidKey = raidKey }
    end
end)

-- Difficulty data (names are set dynamically from locale)
lv.RAID_DIFFICULTIES = {
    {id = 17, nameKey = "DIFFICULTY_LFR", tag = "LFR", color = {0.1, 0.9, 0.1}},
    {id = 14, nameKey = "DIFFICULTY_NORMAL", tag = "N", color = {0, 0.44, 0.87}},
    {id = 15, nameKey = "DIFFICULTY_HEROIC", tag = "H", color = {0.64, 0.21, 0.93}},
    {id = 16, nameKey = "DIFFICULTY_MYTHIC", tag = "M", color = {1, 0.5, 0}},
}

-- Current selected difficulty
local currentDifficulty = 16 -- Default to Mythic

-- Optional statistic backfill map (fill with real stat IDs when available).
-- Shape:
-- BossStatMap["The Voidspire"][1] = { normal = 123, heroic = 456, mythic = 789 }
local BossStatMap = {
    seasonKey = "midnight_s1",
    raids = {
    midnight_s1_voidspire = {
        [1] = { mythic = 61372 }, -- Imperator Averzian
        [2] = { mythic = 61373 }, -- Vorasius
        [3] = { mythic = 61374 }, -- Fallen-King Salhadaar
        [4] = { mythic = 61375 }, -- Vaelgor (& Ezzorak)
    },
    midnight_s1_march = {
        -- Shared encounter stat (Belo'ren + Child of Al'ar).
        [1] = { mythic = 61378 }, -- Belo'ren
        [2] = { mythic = 61378 }, -- Child of Al'ar
    },
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
local function GetRaidDifficultyOrder(seasonKey, raidKey)
    local raidInfo = GetRaidConfig(seasonKey, raidKey)
    if raidInfo and raidInfo.difficulties then return raidInfo.difficulties end
    return {
        { storageKey=17, difficultyID=17, tag="L", labelKey="DIFFICULTY_LFR" },
        { storageKey=14, difficultyID=14, tag="N", labelKey="DIFFICULTY_NORMAL" },
        { storageKey=15, difficultyID=15, tag="H", labelKey="DIFFICULTY_HEROIC" },
        { storageKey=16, difficultyID=16, tag="M", labelKey="DIFFICULTY_MYTHIC" },
    }
end
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

local function RenderBossTriplet(indicator, statesByDiff)
    indicator:Show()
    indicator:SetTexCoord(0, 1, 0, 1)
    if indicator.text then indicator.text:Hide() end
    -- Base indicator acts as an anchor; actual visuals are 3 tiny orbs.
    indicator:SetTexture(nil)
    indicator:SetAlpha(0)
    EnsureTripletOrbs(indicator)

    local theme = lv.GetTheme and lv.GetTheme() or nil
    local button = (theme and theme.buttonBgAlt) or {0.210, 0.239, 0.278, 1.0}
    local killColor = {0.58, 0.34, 0.86, 1.0}
    local unkillColor = {button[1], button[2], button[3], 1.0}
    local shellBase = (theme and theme.borderSecondary) or {0.349, 0.388, 0.435, 1.0}
    local shellColor = {shellBase[1], shellBase[2], shellBase[3], 0.68}

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

function lv.GetCharacterRaidWeeklyBossState(charKey, seasonKey, raidKey, difficultyID, bossIndex)
    local playerData = LiteVaultDB and LiteVaultDB[charKey]
    if not playerData then return false end
    if charKey == lv.PLAYER_KEY and lv._liveRaidState and not lv._raidScanInProgress then
        local raidState = lv._liveRaidState[seasonKey] and lv._liveRaidState[seasonKey][raidKey]
        local diffState = raidState and raidState[difficultyID]
        if diffState and diffState.bosses then return diffState.bosses[bossIndex] == true end
    end
    local raidInfo = GetRaidConfig(seasonKey, raidKey)
    local displayKey = raidInfo and raidInfo.displayKey
    local lockout = playerData and playerData.raidLockouts and playerData.raidLockouts[seasonKey]
        and playerData.raidLockouts[seasonKey][raidKey] and playerData.raidLockouts[seasonKey][raidKey][difficultyID]
    if not lockout and playerData and playerData.raidLockouts and displayKey then
        lockout = playerData.raidLockouts[displayKey] and playerData.raidLockouts[displayKey][difficultyID]
    end
    if lockout and lockout.bosses then
        return lockout.bosses[bossIndex] == true
    end
    return false
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

local function EnsureSeasonRaidDifficulty(playerData, seasonKey, raidName, difficultyID)
    if not playerData or not seasonKey or not raidName or not difficultyID then return nil end
    playerData.raidData = playerData.raidData or { schemaVersion = RAID_SCHEMA_VERSION, seasons = {} }
    playerData.raidData.seasons = playerData.raidData.seasons or {}
    local season = playerData.raidData.seasons[seasonKey]
    if not season then
        season = { raids = {} }
        playerData.raidData.seasons[seasonKey] = season
    end
    season.raids = season.raids or {}
    local raid = season.raids[raidName]
    if not raid then
        raid = { difficulties = {} }
        season.raids[raidName] = raid
    end
    raid.difficulties = raid.difficulties or {}
    local difficulty = raid.difficulties[difficultyID]
    if not difficulty then
        difficulty = { encounters = {}, updatedAt = 0 }
        raid.difficulties[difficultyID] = difficulty
    end
    difficulty.encounters = difficulty.encounters or {}
    playerData.raidData.schemaVersion = RAID_SCHEMA_VERSION
    return difficulty
end

GetEncounterStorageKey = function(raidInfo, bossIndex, encounterID)
    encounterID = tonumber(encounterID)
    if encounterID and encounterID > 0 then return encounterID end
    local configured = raidInfo and raidInfo.encounters and raidInfo.encounters[bossIndex]
    if configured and configured.encounterID then return configured.encounterID end
    return "index:" .. tostring(bossIndex)
end

RecordSeasonRaidKill = function(playerData, seasonKey, raidName, difficultyID, bossIndex, encounterID, displayName, metadata)
    metadata = metadata or {}
    local seasonInfo = RAID_SEASONS[seasonKey]
    if not seasonInfo or (not seasonInfo.progressionTrackingActive and not metadata.migration) then return false end
    local raidInfo = RAID_SEASONS[seasonKey] and RAID_SEASONS[seasonKey].raids[raidName]
    local bucket = EnsureSeasonRaidDifficulty(playerData, seasonKey, raidName, difficultyID)
    if not bucket then return false end
    local storageKey = GetEncounterStorageKey(raidInfo, bossIndex, encounterID)
    local fallbackKey = "index:" .. tostring(bossIndex)
    local existingKey, existing, hadUndatedKill = nil, nil, false
    local earliestFirstKillAt, earliestFirstKillSource
    for key, saved in pairs(bucket.encounters) do
        if type(saved) == "table" and saved.bossIndex == bossIndex then
            if not existing or tonumber(key) then existingKey, existing = key, saved end
            if saved.killed and (not saved.firstKillAt or saved.firstKillSource ~= "observed") then hadUndatedKill = true end
            if saved.firstKillAt and saved.firstKillSource == "observed"
                and (not earliestFirstKillAt or saved.firstKillAt < earliestFirstKillAt) then
                earliestFirstKillAt, earliestFirstKillSource = saved.firstKillAt, saved.firstKillSource
            end
        elseif saved == true and (key == storageKey or key == fallbackKey) then
            hadUndatedKill = true
        end
    end
    local incomingFirstKillAt = metadata.firstKillSource == "observed" and tonumber(metadata.firstKillAt) or nil
    if incomingFirstKillAt and (not earliestFirstKillAt or incomingFirstKillAt < earliestFirstKillAt) then
        earliestFirstKillAt, earliestFirstKillSource = incomingFirstKillAt, metadata.firstKillSource
    end
    if metadata.historicalUndated then hadUndatedKill = true end
    if not tonumber(storageKey) and existingKey and tonumber(existingKey) then
        storageKey = existingKey
    end
    local mergeCandidate = existing or bucket.encounters[storageKey] or bucket.encounters[fallbackKey]
    local merged = type(mergeCandidate) == "table" and mergeCandidate or {}
    merged.killed = true
    merged.encounterID = tonumber(encounterID) or merged.encounterID
    merged.bossIndex = bossIndex
    merged.displayName = displayName or merged.displayName
    local observedAt = tonumber(metadata.observedAt)
    if observedAt and seasonInfo.firstKillTrackingActive and not existing and not hadUndatedKill then
        earliestFirstKillAt, earliestFirstKillSource = observedAt, "observed"
    end
    if hadUndatedKill then
        -- An older undated record means a later observed date cannot truthfully
        -- be called this character's first kill.
        merged.firstKillAt, merged.firstKillSource = nil, nil
    else
        merged.firstKillAt, merged.firstKillSource = earliestFirstKillAt, earliestFirstKillSource
    end
    bucket.encounters[storageKey] = merged
    for key, saved in pairs(bucket.encounters) do
        if key ~= storageKey and type(saved) == "table" and saved.bossIndex == bossIndex then
            bucket.encounters[key] = nil
        end
    end
    bucket.encounters[storageKey] = merged
    bucket.updatedAt = GetServerTime()
    lv._warbandRaidCache = nil
    return true
end

MigrateRaidData = function(playerData)
    if not playerData then return end
    playerData.raidData = playerData.raidData or { schemaVersion = RAID_SCHEMA_VERSION, seasons = {} }
    playerData.raidData.seasons = playerData.raidData.seasons or {}
    if not playerData.raidData.migratedRaidKillsS1 and type(playerData.raidKills) == "table" then
        for raidName, legacyRaid in pairs(playerData.raidKills) do
            local legacyMap = {
                ["The Voidspire"]="midnight_s1_voidspire", ["The Dreamrift"]="midnight_s1_dreamrift",
                ["Sporefall"]="midnight_s1_sporefall", ["March of Quel'Danas"]="midnight_s1_march",
            }
            local raidKey = legacyMap[raidName]
            if raidKey and type(legacyRaid) == "table" then
                for _, difficultyID in ipairs({ 17, 14, 15, 16 }) do
                    local diffKey = GetDifficultyKey(difficultyID)
                    for bossIndex, killed in pairs(legacyRaid[diffKey] or {}) do
                        if killed then
                            RecordSeasonRaidKill(playerData, "midnight_s1", raidKey, difficultyID, bossIndex, nil,
                                legacyRaid.bossNames and legacyRaid.bossNames[bossIndex], { migration = true })
                        end
                    end
                end
            end
        end
        playerData.raidData.migratedRaidKillsS1 = true
    end
    -- Schema v4 copies display-name raid buckets into stable internal-key buckets.
    -- Originals remain untouched for rollback compatibility. RecordSeasonRaidKill
    -- performs boss-identity merging, making this safe to run repeatedly.
    local legacyKeys = {
        midnight_s1 = {
            ["The Voidspire"]="midnight_s1_voidspire", ["The Dreamrift"]="midnight_s1_dreamrift",
            ["Sporefall"]="midnight_s1_sporefall", ["March of Quel'Danas"]="midnight_s1_march",
        },
        midnight_s2 = {
            ["The Venomous Abyss"]="midnight_s2_venomous_abyss",
            ["Lair Boss"]="midnight_s2_tidebound_grotto",
            ["midnight_s2_lair_boss"]="midnight_s2_tidebound_grotto",
        },
    }
    for seasonKey, names in pairs(legacyKeys) do
        local season = playerData.raidData.seasons[seasonKey]
        for displayName, raidKey in pairs(names) do
            local oldRaid = season and season.raids and season.raids[displayName]
            for difficultyID, difficulty in pairs((oldRaid and oldRaid.difficulties) or {}) do
                for _, encounter in pairs(difficulty.encounters or {}) do
                    if encounter == true then
                        -- Very old boolean records have no safe boss identity.
                    elseif type(encounter) == "table" and encounter.killed and encounter.bossIndex then
                        local canonicalRaid = season.raids and season.raids[raidKey]
                        local canonicalDifficulty = canonicalRaid and canonicalRaid.difficulties and canonicalRaid.difficulties[difficultyID]
                        local existingBoss
                        for _, saved in pairs((canonicalDifficulty and canonicalDifficulty.encounters) or {}) do
                            if type(saved) == "table" and saved.bossIndex == encounter.bossIndex then existingBoss = saved break end
                        end
                        if not existingBoss or (not existingBoss.encounterID and encounter.encounterID) then
                            RecordSeasonRaidKill(playerData, seasonKey, raidKey, difficultyID, encounter.bossIndex,
                                encounter.encounterID, encounter.displayName, {
                                    migration = true,
                                    firstKillAt = encounter.firstKillAt,
                                    firstKillSource = encounter.firstKillSource,
                                    historicalUndated = not encounter.firstKillAt or encounter.firstKillSource ~= "observed",
                                })
                        end
                    end
                end
            end
        end
    end
    -- raidProgression is deliberately retained: its raid attribution is ambiguous.
    playerData.raidData.schemaVersion = RAID_SCHEMA_VERSION
end

lv.EnsureRaidDataSchema = MigrateRaidData

function lv.GetCharacterRaidBossState(charKey, seasonKey, raidKey, difficultyID, bossIndex)
    local playerData = LiteVaultDB and LiteVaultDB[charKey]
    if not playerData then return false end
    if not playerData.raidData or playerData.raidData.schemaVersion ~= RAID_SCHEMA_VERSION then MigrateRaidData(playerData) end
    local season = playerData.raidData and playerData.raidData.seasons and playerData.raidData.seasons[seasonKey]
    local raid = season and season.raids and season.raids[raidKey]
    local difficulty = raid and raid.difficulties and raid.difficulties[difficultyID]
    for _, encounter in pairs((difficulty and difficulty.encounters) or {}) do
        if type(encounter) == "table" and encounter.killed and encounter.bossIndex == bossIndex then
            return true
        end
    end
    return false
end

function lv.GetCharacterRaidBossHistory(charKey, seasonKey, raidKey, difficultyID, bossIndex)
    local playerData = LiteVaultDB and LiteVaultDB[charKey]
    if not playerData then return nil end
    if not playerData.raidData or playerData.raidData.schemaVersion ~= RAID_SCHEMA_VERSION then MigrateRaidData(playerData) end
    local season = playerData.raidData and playerData.raidData.seasons and playerData.raidData.seasons[seasonKey]
    local raid = season and season.raids and season.raids[raidKey]
    local difficulty = raid and raid.difficulties and raid.difficulties[difficultyID]
    for _, encounter in pairs((difficulty and difficulty.encounters) or {}) do
        if type(encounter) == "table" and encounter.killed and encounter.bossIndex == bossIndex then
            local trustworthy = encounter.firstKillSource == "observed" and tonumber(encounter.firstKillAt) or nil
            return { firstKillAt = trustworthy, firstKillSource = trustworthy and "observed" or nil }
        end
    end
    return nil
end

local function GetWarbandCacheKey(seasonKey, raidKey, difficultyID, bossIndex)
    return table.concat({seasonKey, raidKey, difficultyID, bossIndex}, ":")
end

function lv.GetWarbandRaidBossState(seasonKey, raidKey, difficultyID, bossIndex)
    for charKey, data in pairs(LiteVaultDB or {}) do
        if lv.IsLiteVaultCharacterRecord and lv.IsLiteVaultCharacterRecord(charKey, data)
            and (not data.raidData or data.raidData.schemaVersion ~= RAID_SCHEMA_VERSION) then
            MigrateRaidData(data)
        end
    end
    lv._warbandRaidCache = lv._warbandRaidCache or {}
    local cacheKey = GetWarbandCacheKey(seasonKey, raidKey, difficultyID, bossIndex)
    local cached = lv._warbandRaidCache[cacheKey]
    if cached then return cached.killed, cached.killers, cached.history end
    local killers, seen = {}, {}
    for _, charKey in ipairs(LiteVaultOrder or {}) do
        local data = LiteVaultDB and LiteVaultDB[charKey]
        if lv.IsLiteVaultCharacterRecord and lv.IsLiteVaultCharacterRecord(charKey, data)
            and lv.GetCharacterRaidBossState(charKey, seasonKey, raidKey, difficultyID, bossIndex) then
            local history = lv.GetCharacterRaidBossHistory(charKey, seasonKey, raidKey, difficultyID, bossIndex) or {}
            killers[#killers + 1] = { key = charKey, name = charKey:match("^([^-]+)") or charKey, class = data.classFile or data.class,
                firstKillAt = history.firstKillAt, firstKillSource = history.firstKillSource }
            seen[charKey] = true
        end
    end
    for charKey, data in pairs(LiteVaultDB or {}) do
        if not seen[charKey] and lv.IsLiteVaultCharacterRecord and lv.IsLiteVaultCharacterRecord(charKey, data)
            and lv.GetCharacterRaidBossState(charKey, seasonKey, raidKey, difficultyID, bossIndex) then
            local history = lv.GetCharacterRaidBossHistory(charKey, seasonKey, raidKey, difficultyID, bossIndex) or {}
            killers[#killers + 1] = { key = charKey, name = charKey:match("^([^-]+)") or charKey, class = data.classFile or data.class,
                firstKillAt = history.firstKillAt, firstKillSource = history.firstKillSource }
        end
    end
    local earliest, hasUndated = nil, false
    for _, killer in ipairs(killers) do
        if killer.firstKillAt then
            if not earliest or killer.firstKillAt < earliest.firstKillAt then earliest = killer end
        else
            hasUndated = true
        end
    end
    local history = {
        definitive = #killers > 0 and not hasUndated and earliest ~= nil,
        hasUndated = hasUndated,
        earliest = earliest,
    }
    cached = { killed = #killers > 0, killers = killers, history = history }
    lv._warbandRaidCache[cacheKey] = cached
    return cached.killed, cached.killers, cached.history
end

function lv.InvalidateWarbandRaidCache()
    lv._warbandRaidCache = nil
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

    -- Retain old display-name and difficulty-only snapshots for rollback.
    -- Their raid attribution may be ambiguous, so new writes use nested stable
    -- keys without destructively guessing at the old data.
    local s2Lockouts = playerData.raidLockouts.midnight_s2
    local temporaryLair = s2Lockouts and s2Lockouts.midnight_s2_lair_boss
    if temporaryLair then
        s2Lockouts.midnight_s2_tidebound_grotto = s2Lockouts.midnight_s2_tidebound_grotto or {}
        local target = s2Lockouts.midnight_s2_tidebound_grotto
        for difficultyKey, oldState in pairs(temporaryLair) do
            if type(oldState) == "table" then
                target[difficultyKey] = target[difficultyKey] or { bosses={}, bossNames={}, scannedAt=0 }
                for bossIndex, killed in pairs(oldState.bosses or {}) do
                    if killed then target[difficultyKey].bosses[bossIndex] = true end
                end
                for bossIndex, bossName in pairs(oldState.bossNames or {}) do
                    target[difficultyKey].bossNames[bossIndex] = target[difficultyKey].bossNames[bossIndex] or bossName
                end
                target[difficultyKey].scannedAt = math.max(target[difficultyKey].scannedAt or 0, oldState.scannedAt or 0)
            end
        end
    end

    for seasonKey, season in pairs(RAID_SEASONS) do
        playerData.raidLockouts[seasonKey] = playerData.raidLockouts[seasonKey] or {}
        for raidKey in pairs(season.raids or {}) do
            playerData.raidLockouts[seasonKey][raidKey] = playerData.raidLockouts[seasonKey][raidKey] or {}
        end
    end
    playerData.raidLockoutsSchemaVersion = 3
    MigrateRaidData(playerData)
end

local function EnsureRaidLockoutBucket(playerData, seasonKey, raidKey, difficultyID)
    if not playerData or not seasonKey or not raidKey or not difficultyID then return nil end
    EnsureRaidLockoutsSchema(playerData)
    playerData.raidLockouts[seasonKey][raidKey][difficultyID] = playerData.raidLockouts[seasonKey][raidKey][difficultyID] or {
        bosses = {},
        bossNames = {},
        scannedAt = GetServerTime()
    }
    return playerData.raidLockouts[seasonKey][raidKey][difficultyID]
end

local function BackfillRaidKillsFromStatistics(playerData)
    if not playerData then return end
    local seasonKey = BossStatMap.seasonKey
    if not (RAID_SEASONS[seasonKey] and RAID_SEASONS[seasonKey].progressionTrackingActive) then return end
    for raidKey, bosses in pairs(BossStatMap.raids or {}) do
        local raidInfo = GetRaidConfig(seasonKey, raidKey)
        local raidKills = EnsureRaidKills(playerData, raidInfo and raidInfo.displayKey or raidKey)
        for bossIndex, diffStats in pairs(bosses or {}) do
            for diffKey, statID in pairs(diffStats or {}) do
                local statText = select(1, GetStatistic(statID))
                local statVal = tonumber(statText) or 0
                if statVal > 0 and raidKills[diffKey] then
                    -- Boolean-only progression seed: killed at least once.
                    raidKills[diffKey][bossIndex] = true
                    if raidInfo and raidInfo.bosses then
                        raidKills.bossNames[bossIndex] = raidInfo.bosses[bossIndex]
                    end
                    local difficultyIDs = { lfr=17, normal=14, heroic=15, mythic=16 }
                    RecordSeasonRaidKill(playerData, seasonKey, raidKey,
                        difficultyIDs[diffKey], bossIndex, nil, raidKills.bossNames[bossIndex])
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
        lv._liveRaidState = {}
        lv._liveRaidResetEpoch = nextReset - 604800
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
    if not playerData.raidKillsBackfilled and next(BossStatMap.raids or {}) then
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

local function LearnTrackedRaidInstanceID(seasonKey, raidKey, instanceID)
    instanceID = tonumber(instanceID)
    if not GetRaidConfig(seasonKey, raidKey) or not instanceID or instanceID <= 0 then return end
    lv.CURRENT_TIER_INSTANCE_IDS = lv.CURRENT_TIER_INSTANCE_IDS or {}
    lv.CURRENT_TIER_INSTANCE_IDS[instanceID] = { seasonKey = seasonKey, raidKey = raidKey }
end

local RAID_INSTANCE_ALIASES = {
    midnight_s1_voidspire = {
        "The Voidspire",
    },
    midnight_s1_dreamrift = {
        "The Dreamrift",
    },
    midnight_s1_sporefall = {
        "Sporefall",
    },
    midnight_s1_march = {
        "March of Quel'Danas",
        "March on Quel'Danas",
        "Dragon's March on Quel'Danas",
        "The Dragon's March on Quel'Danas",
    },
    midnight_s2_venomous_abyss = { "The Venomous Abyss" },
    midnight_s2_tidebound_grotto = { "The Tidebound Grotto" },
}

local function InstanceNameMatchesRaid(instanceName, raidKey, raidInfo)
    if type(instanceName) ~= "string" or type(raidKey) ~= "string" then
        return false
    end

    local aliases = RAID_INSTANCE_ALIASES[raidKey] or { raidInfo and raidInfo.displayKey or raidKey }
    for _, alias in ipairs(aliases) do
        for _, candidate in ipairs({ alias, LT(alias) }) do
            if instanceName == candidate or instanceName:find(candidate, 1, true) or candidate:find(instanceName, 1, true) then
                return true
            end
        end
    end

    local normalizedInstance = NormalizeEncounterName(instanceName)
    for _, alias in ipairs(aliases) do
        for _, candidate in ipairs({ alias, LT(alias) }) do
            local normalizedAlias = NormalizeEncounterName(candidate)
            if normalizedAlias ~= "" and (normalizedInstance == normalizedAlias
                or normalizedInstance:find(normalizedAlias, 1, true)
                or normalizedAlias:find(normalizedInstance, 1, true)) then
                return true
            end
        end
    end

    return false
end

local function DetectTrackedRaid(instanceName, instanceID)
    if instanceID and lv.CURRENT_TIER_INSTANCE_IDS then
        local byInstanceID = lv.CURRENT_TIER_INSTANCE_IDS[instanceID]
        if type(byInstanceID) == "table" and GetRaidConfig(byInstanceID.seasonKey, byInstanceID.raidKey) then
            return byInstanceID.seasonKey, byInstanceID.raidKey
        end
    end
    if not instanceName then return nil, nil end
    local foundSeason, foundRaid
    ForEachConfiguredRaid(function(seasonKey, raidKey, raidInfo)
        if not foundRaid and InstanceNameMatchesRaid(instanceName, raidKey, raidInfo) then
            foundSeason, foundRaid = seasonKey, raidKey
            LearnTrackedRaidInstanceID(seasonKey, raidKey, instanceID)
        end
    end)
    return foundSeason, foundRaid
end

-- Shared season-aware raid resolver for runtime consumers such as InstanceTracker.
-- Numeric identifiers remain authoritative when known; localized configured names
-- provide the fallback while new-season identifiers are pending live verification.
function lv.ResolveConfiguredRaid(instanceName, instanceID)
    return DetectTrackedRaid(instanceName, instanceID)
end

-- Scan the actual raid info panel for lockout data
function lv.ScanRaidInfoPanel()
    if not LiteVaultDB or not LiteVaultDB[lv.PLAYER_KEY] then return end

    local playerData = LiteVaultDB[lv.PLAYER_KEY]
    lv._raidScanInProgress = true
    local currentResetEpoch = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    local previousLiveRaidState = (currentResetEpoch and lv._liveRaidResetEpoch == currentResetEpoch) and (lv._liveRaidState or {}) or {}
    lv._liveRaidResetEpoch = currentResetEpoch
    lv._liveRaidState = {}
    -- Keep the existing current-week lockout table and merge fresh API data into it.
    EnsureRaidLockoutsSchema(playerData)
    ForEachConfiguredRaid(function(seasonKey, raidKey)
        for _, diff in ipairs(lv.RAID_DIFFICULTIES or {}) do
            playerData.raidLockouts[seasonKey][raidKey][diff.id] = playerData.raidLockouts[seasonKey][raidKey][diff.id] or {
                bosses = {},
                bossNames = {},
                scannedAt = 0
            }
        end
    end)

    -- Use the built-in API but with better validation
    for i = 1, GetNumSavedInstances() do
        local name, _, reset, difficulty, locked, extended, _, isRaid, _, _, numBosses, _, _, instanceID = GetSavedInstanceInfo(i)
        -- The final Retail return is an instance ID, not a map ID.
        local resolvedSeasonKey, resolvedRaidKey = DetectTrackedRaid(name, instanceID)

        -- Only scan ACTIVE lockouts (reset > 0 means it expires in the future = current week)
        -- Expired lockouts (reset = 0) are from previous weeks and should be ignored
        local isActiveLockout = reset and reset > 0

        -- Skip expired lockouts (from previous weeks)
        if isRaid and resolvedRaidKey and not isActiveLockout and IsTrackedRaidDifficulty(difficulty) then
        end

        if isRaid and resolvedRaidKey and isActiveLockout and IsTrackedRaidDifficulty(difficulty) then
            local raidInfo = GetRaidConfig(resolvedSeasonKey, resolvedRaidKey)
            LearnTrackedRaidInstanceID(resolvedSeasonKey, resolvedRaidKey, instanceID)
            local trackedBossCount = (raidInfo and raidInfo.bossCount) or 0

            local canStoreLiveState = raidInfo ~= nil
            if canStoreLiveState then
                -- Live, API-authoritative state for current lockout rendering.
                local priorState = previousLiveRaidState[resolvedSeasonKey] and previousLiveRaidState[resolvedSeasonKey][resolvedRaidKey]
                    and previousLiveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty] or nil
                lv._liveRaidState[resolvedSeasonKey] = lv._liveRaidState[resolvedSeasonKey] or {}
                lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey] = lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey] or {}
                lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty] = lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty] or {
                    bosses = {},
                    bossNames = {},
                    encounterIDs = {},
                    encounterObservedAt = {},
                    scannedAt = GetServerTime()
                }
                if priorState and priorState.bosses then
                    for bossIndex, isKilled in pairs(priorState.bosses) do
                        if isKilled then
                            lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty].bosses[bossIndex] = true
                        end
                    end
                end
                if priorState and priorState.bossNames then
                    lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty].bossNames = priorState.bossNames
                end
            end

            -- Scan the lockout data
            for bossIndex = 1, math.min(numBosses, trackedBossCount) do
                local bossName, _, isDead = GetSavedInstanceEncounterInfo(i, bossIndex)
                if bossName then
                    -- Update current week's lockout (live scan is authoritative).
                    if isDead then
                        local lockout = EnsureRaidLockoutBucket(playerData, resolvedSeasonKey, resolvedRaidKey, difficulty)
                        local canonicalName = (raidInfo and raidInfo.bosses and raidInfo.bosses[bossIndex]) or bossName
                        if lockout then
                            lockout.bosses[bossIndex] = true
                            lockout.bossNames[bossIndex] = canonicalName
                            lockout.scannedAt = GetServerTime()
                        end
                        if canStoreLiveState then
                            lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty].bosses[bossIndex] = true
                            lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty].bossNames[bossIndex] = canonicalName
                            local pending = lv._pendingRaidEncounter
                            if pending and pending.seasonKey == resolvedSeasonKey and pending.raidKey == resolvedRaidKey and pending.difficultyID == difficulty
                                and EncounterNamesMatch(pending.encounterName, bossName) then
                                lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty].encounterIDs[bossIndex] = pending.encounterID
                                lv._liveRaidState[resolvedSeasonKey][resolvedRaidKey][difficulty].encounterObservedAt[bossIndex] = pending.observedAt
                                lv._pendingRaidEncounter = nil
                            end
                        end
                    end
                end
            end
        end
    end

    -- Reconcile persistent progression from live API snapshot.
    playerData.raidProgression = playerData.raidProgression or {}
    playerData.raidKills = playerData.raidKills or {}
    for seasonKey, byRaid in pairs(lv._liveRaidState) do
      for raidKey, byDiff in pairs(byRaid or {}) do
        for diffID, diffState in pairs(byDiff or {}) do
            local seasonInfo = RAID_SEASONS[seasonKey]
            if seasonInfo and seasonInfo.progressionTrackingActive and IsTrackedRaidDifficulty(diffID) then
                playerData.raidProgression[diffID] = playerData.raidProgression[diffID] or {bosses = {}, bossNames = {}, killCount = 0}
                local diffKey = GetDifficultyKey(diffID)
                local raidInfo = GetRaidConfig(seasonKey, raidKey)
                local raidKills = (diffKey and raidInfo and EnsureRaidKills(playerData, raidInfo.displayKey)) or nil
                for bossIndex, isKilled in pairs(diffState.bosses or {}) do
                    if isKilled then
                        local bossName = (diffState.bossNames and diffState.bossNames[bossIndex]) or (raidInfo and raidInfo.bosses and raidInfo.bosses[bossIndex])
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
                        local encounterID = diffState.encounterIDs and diffState.encounterIDs[bossIndex]
                        RecordSeasonRaidKill(playerData, seasonKey, raidKey, diffID, bossIndex, encounterID, bossName, {
                            observedAt = diffState.encounterObservedAt and diffState.encounterObservedAt[bossIndex],
                        })
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
    end

    lv._raidScanInProgress = false

    -- Update the UI if it's showing
    if RaidLockoutWindow and RaidLockoutWindow:IsShown() then
        lv.UpdateRaidLockoutGrid()
    end

end

-- Helper function to count progression kills for a character
function lv.GetProgressionKills(charKey, difficultyId)
    return lv.GetCurrentRaidProgressionKills(charKey, difficultyId)
end

-- Create the Raid Lockout Window
RaidLockoutWindow = CreateFrame("Frame", "LiteVaultRaidFrame", UIParent, "BackdropTemplate")
RaidLockoutWindow:SetSize(900, 500)
RaidLockoutWindow:SetPoint("CENTER")
RaidLockoutWindow:SetClampedToScreen(true)
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
lv.EnsureBorderStyle(RaidLockoutWindow, "panel")
RaidLockoutWindow:Hide()

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(RaidLockoutWindow, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundSolid))
            lv.ApplyBorderStyle(f, "panel", theme)
            -- Refresh grid to update button colors when theme changes
            if f:IsShown() then
                lv.UpdateRaidLockoutGrid()
            end
        end)
        local t = lv.GetTheme()
        RaidLockoutWindow:SetBackdropColor(unpack(t.backgroundSolid))
        lv.ApplyBorderStyle(RaidLockoutWindow, "panel", t)
    end
end)

-- Register with escape handler so it closes when user hits Escape.
RaidLockoutWindow:SetScript("OnShow", function(self)
    table.insert(UISpecialFrames, "LiteVaultRaidFrame")
    -- Refresh immediately on open so first load is correct without mode toggles.
    if lv.ScanRaidLockouts then
        lv.ScanRaidLockouts()
    end
    -- Give the async raid info scan time to complete, then repaint once more.
    C_Timer.After(0.75, function()
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
title:SetText(string.format(L["TITLE_RAID_SEASON_FMT"] or "%s - %s", L["TITLE_RAIDS"] or "Raids", GetCurrentSeasonLabel()))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(title, 15)
end
RaidLockoutWindow.title = title

local seasonContextText = RaidLockoutWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
seasonContextText:SetPoint("TOPLEFT", RaidLockoutWindow, "TOPLEFT", 20, -87)
RaidLockoutWindow.seasonContextText = seasonContextText

local categoryButtons = {}
local function UpdateCategoryButtonStyles()
    local theme = lv.GetTheme and lv.GetTheme()
    if not theme then return end
    for category, button in pairs(categoryButtons) do
        local active = category == selectedCategory
        button:SetBackdropColor(unpack(active and (theme.buttonBgActive or theme.buttonBgHover) or theme.buttonBg))
        button:SetBackdropBorderColor(unpack(active and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
    end
end

local function SelectRaidCategory(category)
    local seasonKey = CATEGORY_DEFAULT_SEASONS[category]
    if not seasonKey or not RAID_SEASONS[seasonKey] then return end
    selectedCategory = category
    selectedSeasonKey = seasonKey
    raidTabs = RAID_SEASONS[seasonKey].raidOrder
    selectedRaidTab = selectedRaidBySeason[seasonKey] or raidTabs[1]
    selectedRaidBySeason[seasonKey] = selectedRaidTab
    lv.InvalidateWarbandRaidCache()
    CreateRaidTabs(RaidLockoutWindow)
    UpdateCategoryButtonStyles()
    if lv.UpdateRaidLockoutGrid then lv.UpdateRaidLockoutGrid() end
end

for index, category in ipairs({ "current", "legacy" }) do
    local button = CreateFrame("Button", nil, RaidLockoutWindow, "BackdropTemplate")
    button:SetSize(112, 28)
    button:SetPoint("TOPLEFT", RaidLockoutWindow, "TOPLEFT", 20 + ((index - 1) * 122), -48)
    button:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=12, insets={left=3,right=3,top=3,bottom=3} })
    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.Text:SetPoint("CENTER")
    button.Text:SetText(category == "current" and L["TAB_RAID_CURRENT"] or L["TAB_RAID_LEGACY"])
    button:SetScript("OnClick", function() SelectRaidCategory(category) end)
    button:SetScript("OnEnter", function(self) local t=lv.GetTheme(); self:SetBackdropColor(unpack(t.buttonBgHover)); self:SetBackdropBorderColor(unpack(t.borderHover)) end)
    button:SetScript("OnLeave", UpdateCategoryButtonStyles)
    categoryButtons[category] = button
end
UpdateCategoryButtonStyles()
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for _, button in pairs(categoryButtons) do
            lv.RegisterThemedElement(button, function() UpdateCategoryButtonStyles() end)
        end
    end
end)

-- Bottom-right live marker for current-character lockout API view
local liveTagText = RaidLockoutWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
liveTagText:SetPoint("BOTTOMRIGHT", RaidLockoutWindow, "BOTTOMRIGHT", -14, 10)
liveTagText:SetText("|cff2ecc71" .. L["STATUS_LIVE"] .. "|r")
liveTagText:Hide()
RaidLockoutWindow.liveTagText = liveTagText

local function RefreshRaidWindowTitle()
    if not RaidLockoutWindow or not RaidLockoutWindow.title then return end
    local playerKey = currentRaidCharKey or lv.PLAYER_KEY
    local charName = (playerKey and playerKey:match("^([^-]+)")) or UnitName("player") or L["LABEL_CHARACTER"]
    local classTag = (LiteVaultDB and playerKey and LiteVaultDB[playerKey] and LiteVaultDB[playerKey].class) or select(2, UnitClass("player")) or "WARRIOR"
    local cc = C_ClassColor.GetClassColor(classTag or "WARRIOR")
    local nameHex = (cc and cc.GenerateHexColor and cc:GenerateHexColor()) or "ffffffff"
    local isCurrentPlayerView = (playerKey == lv.PLAYER_KEY)
    local seasonText = GetCurrentSeasonLabel()
    local coloredName = string.format("|c%s%s|r", nameHex, charName)
    RaidLockoutWindow.title:SetText(FormatRaidCharacterTitle(coloredName, L["TITLE_RAIDS"] or "Raids", seasonText))

    if RaidLockoutWindow.liveTagText then
        if isCurrentPlayerView then
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
            local t = lv.GetTheme()
            self:SetBackdropBorderColor(t.borderPrimary[1], t.borderPrimary[2], t.borderPrimary[3], 0.6)
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
local gridStartX = 145
local columnWidth = 90
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
        return unpack(lv.GetTheme().textGold)
    end
    local function GetSeparatorColor()
        return unpack(lv.GetTheme().dividerBright)
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
                headerData.nameText:SetTextColor(unpack(theme.textGold))
                headerData.separator:SetColorTexture(unpack(theme.dividerBright))
            end)
        end
    end
end)

local function GetSelectedCharacterClassColor(characterData)
    if type(characterData) ~= "table" then return nil end
    local classTag = characterData.classFile or characterData.class
    if type(classTag) ~= "string" or classTag == "" then return nil end
    classTag = classTag:upper():gsub("%s+", "")

    local color = C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(classTag)
    if not color and RAID_CLASS_COLORS then
        color = RAID_CLASS_COLORS[classTag]
    end
    return color
end

local function SetCharacterNameColor(fontString, classColor)
    if classColor then
        fontString:SetTextColor(classColor.r or 1, classColor.g or 1, classColor.b or 1, 1)
        return
    end
    local theme = lv.GetTheme()
    fontString:SetTextColor(unpack((theme and theme.textPrimary) or { 1, 1, 1, 1 }))
end

local function AddCharacterNameTooltipLine(characterName, classColor)
    if classColor then
        GameTooltip:AddLine(characterName, classColor.r or 1, classColor.g or 1, classColor.b or 1)
    else
        GameTooltip:AddLine(characterName, 1, 1, 1)
    end
end

local function FormatRaidKillDate(timestamp)
    return timestamp and date("%x", timestamp) or nil
end

local function AddClassColoredKiller(killer)
    local color = C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(killer.class)
    if not color and RAID_CLASS_COLORS then color = RAID_CLASS_COLORS[killer.class] end
    if color and color.WrapTextInColorCode then
        GameTooltip:AddLine(color:WrapTextInColorCode(killer.name))
    else
        GameTooltip:AddLine(killer.name, 0.9, 0.9, 0.9)
    end
end

local function ShowRaidIndicatorTooltip(button)
    if not button or not button.bossName or not button.difficultyLabelKey then return end
    local difficultyName = L[button.difficultyLabelKey] or button.difficultyLabelKey
    GameTooltip:SetOwner(button, "ANCHOR_TOP")
    GameTooltip:SetText(string.format(L["TOOLTIP_RAID_BOSS_DIFFICULTY_FMT"] or "%s — %s", button.bossName, difficultyName), 1, 0.82, 0)
    GameTooltip:AddLine(" ")
    if button.rowKind == "warband" then
        GameTooltip:AddLine(L["LABEL_WARBAND_PROGRESSION"], 0.75, 0.45, 1)
        if button.isKilled then
            GameTooltip:AddLine(L["STATUS_KILLED"], 0.2, 1, 0.2)
            local history = button.firstKillHistory or {}
            GameTooltip:AddLine(L["LABEL_FIRST_KILL"], 1, 1, 1)
            if history.definitive and history.earliest then
                AddClassColoredKiller({
                    name = string.format("%s — %s", history.earliest.name, FormatRaidKillDate(history.earliest.firstKillAt)),
                    class = history.earliest.class,
                })
                if #(button.killers or {}) > 1 then GameTooltip:AddLine(L["LABEL_ALSO_KILLED_BY"], 1, 1, 1) end
            else
                GameTooltip:AddLine(L["TEXT_HISTORICAL_DATA_UNAVAILABLE"], 0.7, 0.7, 0.7)
                if history.earliest then
                    GameTooltip:AddLine(L["LABEL_EARLIEST_RECORDED_KILL"], 1, 1, 1)
                    AddClassColoredKiller({
                        name = string.format("%s — %s", history.earliest.name, FormatRaidKillDate(history.earliest.firstKillAt)),
                        class = history.earliest.class,
                    })
                end
                GameTooltip:AddLine(L["LABEL_KNOWN_KILLS"], 1, 1, 1)
            end
            local displayed, limit = 0, 8
            for _, killer in ipairs(button.killers or {}) do
                if not (history.definitive and history.earliest and killer.key == history.earliest.key) and displayed < limit then
                    AddClassColoredKiller(killer)
                    displayed = displayed + 1
                end
            end
            local omitted = #(button.killers or {}) - displayed - ((history.definitive and history.earliest) and 1 or 0)
            if omitted > 0 then
                GameTooltip:AddLine(string.format(L["TEXT_MORE_CHARACTERS_FMT"] or "+ %d more", omitted), 0.7, 0.7, 0.7)
            end
        else
            GameTooltip:AddLine(L["TEXT_NO_WARBAND_RAID_KILL"], 0.7, 0.7, 0.7, true)
        end
    elseif button.rowKind == "weekly" then
        GameTooltip:AddLine(L["LABEL_THIS_WEEK"], 0.75, 0.75, 1)
        AddCharacterNameTooltipLine(button.characterName or L["LABEL_CHARACTER"], button.characterClassColor)
        GameTooltip:AddLine(button.isKilled and L["STATUS_SAVED_KILLED"] or L["STATUS_NOT_SAVED_KILLED"], button.isKilled and 0.2 or 0.8, button.isKilled and 1 or 0.35, 0.2)
    else
        GameTooltip:AddLine(L["LABEL_CHARACTER_PROGRESSION"], 0.75, 0.75, 1)
        AddCharacterNameTooltipLine(button.characterName or L["LABEL_CHARACTER"], button.characterClassColor)
        GameTooltip:AddLine(button.isKilled and L["STATUS_KILLED"] or L["STATUS_NOT_KILLED"], button.isKilled and 0.2 or 0.8, button.isKilled and 1 or 0.35, 0.2)
        if button.isKilled then
            if button.characterHistory and button.characterHistory.firstKillAt then
                GameTooltip:AddLine(L["LABEL_FIRST_KILL"], 1, 1, 1)
                GameTooltip:AddLine(FormatRaidKillDate(button.characterHistory.firstKillAt), 0.9, 0.9, 0.9)
            else
                GameTooltip:AddLine(L["TEXT_KILL_DATE_UNAVAILABLE"], 0.7, 0.7, 0.7)
            end
        end
    end
    GameTooltip:Show()
end

-- Unified Character progression, current weekly lockout, and derived Warband rows.
local charRows = {}
local maxRows = 3

for i = 1, maxRows do
    local row = CreateFrame("Frame", nil, RaidLockoutWindow, "BackdropTemplate")
    row:SetSize(860, 62)
    row:SetPoint("TOPLEFT", RaidLockoutWindow, "TOPLEFT", 20, -220 - ((i - 1) * 82))
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
        if self.nameText then
            if self.rowKind == "character" then
                SetCharacterNameColor(self.nameText, self.characterClassColor)
            else
                self.nameText:SetTextColor(unpack(t.textPrimary or { 1, 1, 1, 1 }))
            end
        end
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
    
    row.rowKind = (i == 1 and "character") or (i == 2 and "weekly") or "warband"
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("LEFT", 15, 0)
    row.nameText:SetWidth(100)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)

    row.nameHit = CreateFrame("Button", nil, row)
    row.nameHit:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.nameHit:SetSize(110, 32)
    row.nameHit:SetScript("OnEnter", function(self)
        if not self.characterName then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        AddCharacterNameTooltipLine(self.characterName, self.characterClassColor)
        GameTooltip:Show()
    end)
    row.nameHit:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    row:UpdateTheme()
    
    -- Boss kill indicators - centered under boss name headers
    row.bossIndicators = {}
    row.diffLabels = {}
    row.hitButtons = {}
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
        row.hitButtons[b] = {}
        for idx = 1, 4 do
            local hit = CreateFrame("Button", nil, row)
            hit:SetSize(15, 28)
            hit:SetPoint("CENTER", indicator, "CENTER", offsets[idx], 0)
            hit.rowKind = row.rowKind
            hit:SetScript("OnEnter", ShowRaidIndicatorTooltip)
            hit:SetScript("OnLeave", function() GameTooltip:Hide() end)
            row.hitButtons[b][idx] = hit
        end
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
                local theme = lv.GetTheme()
                btn:SetBackdropColor(unpack(theme.buttonBgActive))
                btn:SetBackdropBorderColor(unpack(theme.borderSecondary))
            else
                -- Inactive button
                local theme = lv.GetTheme()
                btn:SetBackdropColor(unpack(theme.buttonBg))
                -- Only reset border if not being hovered
                if not btn.isHovered then
                    btn:SetBackdropBorderColor(theme.borderPrimary[1], theme.borderPrimary[2], theme.borderPrimary[3], 0.6)
                end
            end
        end
    end
    
    local seasonKey = selectedSeasonKey
    local raidKey = selectedRaidTab or raidTabs[1]
    local raidData = GetRaidConfig(seasonKey, raidKey)
    local bosses = raidData and raidData.bosses or {}
    local bossCount = (raidData and raidData.bossCount) or #bosses
    local raidDifficulties = GetRaidDifficultyOrder(seasonKey, raidKey)
    if RaidLockoutWindow.seasonContextText then
        RaidLockoutWindow.seasonContextText:SetText(GetSeasonLabel(seasonKey))
    end
    categoryButtons.current.Text:SetText(L["TAB_RAID_CURRENT"])
    categoryButtons.legacy.Text:SetText(L["TAB_RAID_LEGACY"])
    for key, button in pairs(raidTabButtons) do
        local config = GetRaidConfig(seasonKey, key)
        if config and button.Text then
            button.Text:SetText(LT(config.displayKey))
            SizeRaidTabButtonToLabel(button)
        end
    end
    local gridLeft, gridWidth = 145, 730
    columnWidth = gridWidth / math.max(1, bossCount)
    for i = 1, #bossHeaders do
        if i <= bossCount and bosses[i] then
            bossHeaders[i].nameText:SetText(LT(bosses[i]))
            bossHeaders[i].frame.bossName = LT(bosses[i])
            bossHeaders[i].frame:ClearAllPoints()
            bossHeaders[i].frame:SetSize(columnWidth, 46)
            bossHeaders[i].nameText:SetWidth(math.max(40, columnWidth - 6))
            bossHeaders[i].separator:SetWidth(math.max(36, columnWidth - 8))
            bossHeaders[i].frame:SetPoint("TOPLEFT", RaidLockoutWindow, "TOPLEFT", gridLeft + ((i - 1) * columnWidth), -158)
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

    local visibleRows = 3
    local characterName = targetKey:match("^([^-]+)") or targetKey
    local characterClassColor = GetSelectedCharacterClassColor(playerData)
    for rowIndex = 1, visibleRows do
        local row = charRows[rowIndex]
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", RaidLockoutWindow, "TOPLEFT", 20, -212 - ((rowIndex - 1) * 82))
        if rowIndex == 1 then
            row.nameText:SetText(characterName)
            row.characterClassColor = characterClassColor
            SetCharacterNameColor(row.nameText, characterClassColor)
            row.nameHit.characterName = characterName
            row.nameHit.characterClassColor = characterClassColor
            row.nameHit:Show()
        else
            row.nameText:SetText(rowIndex == 2 and L["LABEL_THIS_WEEK"] or L["LABEL_WARBAND"])
            row.characterClassColor = nil
            row.nameText:SetTextColor(unpack((lv.GetTheme().textPrimary) or { 1, 1, 1, 1 }))
            row.nameHit.characterName = nil
            row.nameHit.characterClassColor = nil
            row.nameHit:Hide()
        end
        for bossIdx = 1, #bossHeaders do
            local indicator = row.bossIndicators[bossIdx]
            local diffLabelSet = row.diffLabels[bossIdx]
            if bossIdx <= bossCount then
                indicator:ClearAllPoints()
                indicator:SetPoint("TOP", bossHeaders[bossIdx].frame, "BOTTOM", 0, -22 - ((rowIndex - 1) * 82))
                local statesByDiff = {}
                for orbIdx, difficultyInfo in ipairs(raidDifficulties) do
                    local difficultyKey = difficultyInfo.storageKey
                    local isKilled, killers, firstKillHistory, characterHistory
                    if rowIndex == 3 then
                        isKilled, killers, firstKillHistory = lv.GetWarbandRaidBossState(seasonKey, raidKey, difficultyKey, bossIdx)
                    elseif rowIndex == 2 then
                        isKilled = lv.GetCharacterRaidWeeklyBossState(targetKey, seasonKey, raidKey, difficultyKey, bossIdx)
                    else
                        isKilled = lv.GetCharacterRaidBossState(targetKey, seasonKey, raidKey, difficultyKey, bossIdx)
                        characterHistory = lv.GetCharacterRaidBossHistory(targetKey, seasonKey, raidKey, difficultyKey, bossIdx)
                    end
                    statesByDiff[orbIdx] = { hasData = true, isKilled = isKilled }
                    local hit = row.hitButtons[bossIdx][orbIdx]
                    hit.bossName = LT(bosses[bossIdx])
                    hit.characterName = characterName
                    hit.characterClassColor = characterClassColor
                    hit.difficultyID = difficultyInfo.difficultyID
                    hit.difficultyKey = difficultyKey
                    hit.difficultyLabelKey = difficultyInfo.labelKey
                    hit.isKilled = isKilled
                    hit.killers = killers
                    hit.firstKillHistory = firstKillHistory
                    hit.characterHistory = characterHistory
                    hit:Show()
                    diffLabelSet[orbIdx]:SetText(difficultyInfo.tag)
                end
                for _, label in ipairs(diffLabelSet) do label:Show() end
                RenderBossTriplet(indicator, statesByDiff)
            else
                HideTripletOrbs(indicator)
                indicator:Hide()
                for _, label in ipairs(diffLabelSet) do label:Hide() end
                for _, hit in ipairs(row.hitButtons[bossIdx]) do hit:Hide() end
            end
        end
        row:Show()
    end
    for i = visibleRows + 1, maxRows do charRows[i]:Hide() end
end

-- FIXED: Public function to show window with better timing
function lv.ShowRaidLockoutWindow(charKey)
    local targetKey = charKey or lv.PLAYER_KEY
    if RaidLockoutWindow:IsShown() and currentRaidCharKey == targetKey then
        RaidLockoutWindow:Hide()
    else
        currentRaidCharKey = targetKey
        lv.InvalidateWarbandRaidCache()
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
                        return unpack(lv.GetTheme().textGold)
                    end
                end
                if not header.GetSeparatorColor then
                    header.GetSeparatorColor = function()
                        return unpack(lv.GetTheme().dividerBright)
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
        if lv.UpdateRaidLockoutGrid then
            lv.UpdateRaidLockoutGrid()
        end
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
        lv.lastRaidEncounterDiagnostic = { encounterID=tonumber(encounterID), encounterName=encounterName, difficultyID=difficultyID, success=success }

        -- Only track successful kills in raid difficulties we care about
        if success == 1 and IsTrackedRaidDifficulty(difficultyID) then
            local playerData = LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY]
            if playerData then
                -- Initialize if needed
                EnsureRaidLockoutsSchema(playerData)

                -- Resolve the raid from Blizzard's numeric instance identity first.
                -- Saved-instance reconciliation below resolves the localized boss
                -- name to its stable boss index after the encounter.
                local currentInstanceName = GetInstanceInfo and select(1, GetInstanceInfo()) or nil
                local currentInstanceID = GetInstanceInfo and select(8, GetInstanceInfo()) or nil
                local matchedSeasonKey, matchedRaidKey = DetectTrackedRaid(currentInstanceName, currentInstanceID)
                local matchedIndex = nil
                ForEachConfiguredRaid(function(seasonKey, raidKey, raidInfo)
                    if not matchedIndex and (not matchedRaidKey or (matchedSeasonKey == seasonKey and matchedRaidKey == raidKey)) then
                    for i, bossName in ipairs(raidInfo.bosses or {}) do
                        if EncounterNamesMatch(encounterName, bossName) then
                            matchedSeasonKey = seasonKey
                            matchedRaidKey = raidKey
                            matchedIndex = i
                            break
                        end
                    end
                    end
                end)
                if matchedRaidKey and not matchedIndex then
                    lv._pendingRaidEncounter = {
                        seasonKey = matchedSeasonKey, raidKey = matchedRaidKey, encounterID = tonumber(encounterID),
                        encounterName = encounterName, difficultyID = difficultyID, observedAt = GetServerTime(),
                    }
                    RequestRaidInfo()
                    C_Timer.After(0.75, function()
                        if lv.ScanRaidInfoPanel then lv.ScanRaidInfoPanel() end
                    end)
                elseif not matchedRaidKey then
                    lv.lastUnknownRaidIdentity = {
                        instanceID = tonumber(currentInstanceID), encounterID = tonumber(encounterID),
                        instanceName = GetInstanceInfo and select(1, GetInstanceInfo()) or nil,
                        encounterName = encounterName,
                    }
                end
                if matchedIndex then
                        local diffKey = GetDifficultyKey(difficultyID)
                        local matchedRaidInfo = GetRaidConfig(matchedSeasonKey, matchedRaidKey)
                        local canonicalName = (matchedRaidInfo and matchedRaidInfo.bosses and matchedRaidInfo.bosses[matchedIndex]) or encounterName
                        local raidKills = (matchedRaidInfo and diffKey) and EnsureRaidKills(playerData, matchedRaidInfo.displayKey) or nil
                        local lockout = EnsureRaidLockoutBucket(playerData, matchedSeasonKey, matchedRaidKey, difficultyID)
                        lv._liveRaidState = lv._liveRaidState or {}
                        lv._liveRaidState[matchedSeasonKey] = lv._liveRaidState[matchedSeasonKey] or {}
                        lv._liveRaidState[matchedSeasonKey][matchedRaidKey] = lv._liveRaidState[matchedSeasonKey][matchedRaidKey] or {}
                        lv._liveRaidState[matchedSeasonKey][matchedRaidKey][difficultyID] = lv._liveRaidState[matchedSeasonKey][matchedRaidKey][difficultyID] or {
                            bosses = {},
                            bossNames = {},
                            scannedAt = GetServerTime()
                        }
                        -- Update lockout (current week)
                        if lockout then
                            lockout.bosses[matchedIndex] = true
                            lockout.bossNames[matchedIndex] = canonicalName
                            lockout.scannedAt = GetServerTime()
                        end
                        if lv._liveRaidState[matchedSeasonKey] and lv._liveRaidState[matchedSeasonKey][matchedRaidKey][difficultyID] then
                            lv._liveRaidState[matchedSeasonKey][matchedRaidKey][difficultyID].bosses[matchedIndex] = true
                            lv._liveRaidState[matchedSeasonKey][matchedRaidKey][difficultyID].bossNames[matchedIndex] = canonicalName
                            lv._liveRaidState[matchedSeasonKey][matchedRaidKey][difficultyID].scannedAt = GetServerTime()
                        end

                        local seasonInfo = RAID_SEASONS[matchedSeasonKey]
                        if seasonInfo and seasonInfo.progressionTrackingActive then
                            -- Update progression (persistent) only for the configured active season.
                            playerData.raidProgression = playerData.raidProgression or {}
                            playerData.raidProgression[difficultyID] = playerData.raidProgression[difficultyID]
                                or {bosses = {}, bossNames = {}, killCount = 0}
                            playerData.raidProgression[difficultyID].bosses[matchedIndex] = true
                            playerData.raidProgression[difficultyID].bossNames[matchedIndex] = canonicalName

                            local killCount = 0
                            for _, killed in pairs(playerData.raidProgression[difficultyID].bosses) do
                                if killed then killCount = killCount + 1 end
                            end
                            playerData.raidProgression[difficultyID].killCount = killCount

                            if raidKills and diffKey then
                                raidKills[diffKey][matchedIndex] = true
                                raidKills.bossNames[matchedIndex] = canonicalName
                                raidKills.updatedAt = GetServerTime()
                            end
                            RecordSeasonRaidKill(playerData, matchedSeasonKey, matchedRaidKey, difficultyID, matchedIndex,
                                encounterID, canonicalName, { observedAt = GetServerTime() })
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

SLASH_LVRAIDDEBUG1 = "/lvraiddebug"
SlashCmdList["LVRAIDDEBUG"] = function()
    local instanceName, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") or nil
    local seasonKey, raidKey = DetectTrackedRaid(instanceName, instanceID)
    print("|cff9933ffLiteVault Raid Debug|r")
    print("instanceName=" .. tostring(instanceName))
    print("instanceID=" .. tostring(instanceID) .. " mapID=" .. tostring(mapID) .. " difficultyID=" .. tostring(difficultyID))
    print("seasonKey=" .. tostring(seasonKey) .. " raidKey=" .. tostring(raidKey))
    local last = lv.lastRaidEncounterDiagnostic or lv.lastUnknownRaidIdentity
    if last then
        print("lastEncounterID=" .. tostring(last.encounterID) .. " lastEncounterName=" .. tostring(last.encounterName))
    else
        print(L["MSG_RAID_DEBUG_NO_ENCOUNTER"] or "No ENCOUNTER_END event has been observed this session.")
    end
end


