-- Professions.lua - Profession details window for LiteVault
local addonName, lv = ...
local L = lv.L
local function LT(key, fallback)
    local v = L and L[key]
    if not v or v == key then return fallback end
    return v
end

local SetCircularBadgeState = lv.SetCircularBadgeState
local SetCircularBadgeTexture = lv.SetCircularBadgeTexture
local CreateCircularBadge = lv.CreateCircularBadge

local PROFESSION_WINDOW_BADGE_STYLE = {
    frameSize = 36,
    hoverSize = 32,
    shellSize = 30,
    innerSize = 28,
    iconSize = 28,
}

-- 1. DATA COLLECTION

-- Cache for expansion-specific profession skill line IDs (captured when profession window opens)
local cachedChildSkillLines = {}
local cachedExpansionMode = "tww"

-- Hardcoded fallback mappings for current expansion (TWW/Khaz Algar)
-- Parent skill line ID -> Current expansion child skill line ID
local KHAZ_ALGAR_SKILL_LINES = {
    [164] = 2872,  -- Blacksmithing
    [165] = 2880,  -- Leatherworking
    [171] = 2871,  -- Alchemy
    [182] = 2877,  -- Herbalism
    [186] = 2881,  -- Mining
    [197] = 2883,  -- Tailoring
    [202] = 2875,  -- Engineering
    [333] = 2874,  -- Enchanting
    [393] = 2882,  -- Skinning
    [755] = 2879,  -- Jewelcrafting
    [773] = 2878,  -- Inscription
}

-- Midnight fallback mappings (used after Midnight is detected/captured once)
local MIDNIGHT_SKILL_LINES = {
    [171] = 2906,  -- Alchemy
    [164] = 2907,  -- Blacksmithing
    [333] = 2909,  -- Enchanting
    [202] = 2910,  -- Engineering
    [182] = 2912,  -- Herbalism
    [773] = 2913,  -- Inscription
    [755] = 2914,  -- Jewelcrafting
    [165] = 2915,  -- Leatherworking
    [186] = 2916,  -- Mining
    [393] = 2917,  -- Skinning
    [197] = 2918,  -- Tailoring
}

-- Weekly knowledge source mapping by expansion parent skillLineID.
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
local MIDNIGHT_TREASURE_QUESTS = {
    [171] = { -- Alchemy
        unique = {89111, 89112, 89113, 89114, 89115, 89116, 89117, 89118},
        weekly = {93528, 93529},
    },
    [164] = { -- Blacksmithing
        unique = {89177, 89178, 89179, 89180, 89181, 89182, 89183, 89184},
        weekly = {93530, 93531},
    },
    [333] = { -- Enchanting
        unique = {89100, 89101, 89102, 89103, 89104, 89105, 89106, 89107},
        weekly = {93532, 93533, 95048, 95049, 95050, 95051, 95052, 95053},
    },
    [202] = { -- Engineering
        unique = {89133, 89134, 89135, 89136, 89137, 89138, 89139, 89140},
        weekly = {93534, 93535},
    },
    [182] = { -- Herbalism
        unique = {89155, 89156, 89157, 89158, 89159, 89160, 89161, 89162},
        weekly = {81425, 81426, 81427, 81428, 81429, 81430},
    },
    [773] = { -- Inscription
        unique = {89067, 89068, 89069, 89070, 89071, 89072, 89073, 89074},
        weekly = {93536, 93537},
    },
    [755] = { -- Jewelcrafting
        unique = {89122, 89123, 89124, 89125, 89126, 89127, 89128, 89129},
        weekly = {93538, 93539},
    },
    [165] = { -- Leatherworking
        unique = {89089, 89090, 89091, 89092, 89093, 89094, 89095, 89096},
        weekly = {93540, 93541},
    },
    [186] = { -- Mining
        unique = {89144, 89145, 89146, 89147, 89148, 89149, 89150, 89151},
        weekly = {88673, 88674, 88675, 88676, 88677, 88678},
    },
    [393] = { -- Skinning
        unique = {89166, 89167, 89168, 89169, 89170, 89171, 89172, 89173},
        weekly = {88529, 88530, 88534, 88536, 88537, 88549},
    },
    [197] = { -- Tailoring
        unique = {89078, 89079, 89080, 89081, 89082, 89083, 89084, 89085},
        weekly = {93542, 93543},
    },
}

local MIDNIGHT_GLYPH_ZONES = {
    {
        key = "eversong",
        map = 2395,
        zoneName = "Eversong Woods",
        achievementID = 61576,
        glyphs = {
            { x = 0.4832, y = 0.0667, criteriaID = 110335, label = "The Shining Span" },
            { x = 0.6520, y = 0.3258, criteriaID = 110336, label = "Brightwing Estate" },
            { x = 0.5892, y = 0.1954, criteriaID = 110337, label = "Silvermoon City" },
            { x = 0.4000, y = 0.5960, criteriaID = 110338, label = "Goldenmist Village" },
            { x = 0.4947, y = 0.4803, criteriaID = 110339, label = "Path of Dawn" },
            { x = 0.3945, y = 0.4563, criteriaID = 110340, label = "Sunsail Anchorage" },
            { x = 0.6261, y = 0.6278, criteriaID = 110341, label = "Dawnstar Spire" },
            { x = 0.5246, y = 0.6754, criteriaID = 110342, label = "Tranquillien" },
            { x = 0.3343, y = 0.6540, criteriaID = 110343, label = "Daggerspine Point" },
            { x = 0.5843, y = 0.5831, criteriaID = 110344, label = "Suncrown Tree" },
            { x = 0.4320, y = 0.4636, criteriaID = 110345, label = "Fairbreeze Village" },
        },
    },
    {
        key = "harandar",
        map = 2413,
        zoneName = "Harandar",
        achievementID = 61582,
        glyphs = {
            { x = 0.6024, y = 0.4436, criteriaID = 110364, label = "Blossoming Terrace" },
            { x = 0.4707, y = 0.5321, criteriaID = 110365, label = "The Cradle" },
            { x = 0.3450, y = 0.2360, criteriaID = 112628, label = "Roots of Teldrassil" },
            { x = 0.6930, y = 0.4593, criteriaID = 110367, label = "Roots of Amirdrassil" },
            { x = 0.5412, y = 0.3558, criteriaID = 110368, label = "Blooming Lattice" },
            { x = 0.7301, y = 0.2599, criteriaID = 110369, label = "Roots of Nordrassil" },
            { x = 0.4454, y = 0.6280, criteriaID = 110370, label = "Fungara Village" },
            { x = 0.2653, y = 0.6139, criteriaID = 110366, label = "Roots of Shaladrassil" },
            { x = 0.6186, y = 0.6750, criteriaID = 110371, label = "Rift of Aln" },
        },
    },
    {
        key = "voidstorm",
        map = 2405,
        zoneName = "Voidstorm",
        achievementID = 61583,
        glyphs = {
            { x = 0.5135, y = 0.6271, criteriaID = 110372, label = "The Voidspire" },
            { x = 0.3716, y = 0.4996, criteriaID = 110373, label = "The Molt" },
            { x = 0.3567, y = 0.6109, criteriaID = 110374, label = "The Ingress" },
            { x = 0.3990, y = 0.7098, criteriaID = 110375, label = "The Bladeburrows" },
            { x = 0.5495, y = 0.4554, criteriaID = 110376, label = "Gnawing Reach" },
            { x = 0.3622, y = 0.4497, criteriaID = 110377, label = "Hanaar Outpost" },
            { x = 0.3891, y = 0.7611, criteriaID = 110378, label = "Ethereum Refinery" },
            { x = 0.4530, y = 0.5226, criteriaID = 110379, label = "Master's Perch" },
            { x = 0.6508, y = 0.7193, criteriaID = 110380, label = "Obscurion Citadel" },
            { x = 0.3605, y = 0.3726, criteriaID = 110381, label = "Shadowguard Point" },
            { x = 0.4927, y = 0.8746, criteriaID = 110382, label = "The Gorging Pit" },
        },
    },
    {
        key = "zulaman",
        map = 2437,
        zoneName = "Zul'Aman",
        achievementID = 61581,
        glyphs = {
            { x = 0.1917, y = 0.7064, criteriaID = 110353, label = "Revantusk Sedge" },
            { x = 0.4292, y = 0.3436, criteriaID = 110355, label = "Shadebasin Watch" },
            { x = 0.5363, y = 0.8039, criteriaID = 110354, label = "Temple of Akil'zon" },
            { x = 0.5148, y = 0.2357, criteriaID = 110356, label = "Temple of Jan'alai" },
            { x = 0.5320, y = 0.5448, criteriaID = 110357, label = "Strait of Hexx'alor" },
            { x = 0.3955, y = 0.1977, criteriaID = 110358, label = "Witherbark Bluffs" },
            { x = 0.3041, y = 0.8478, criteriaID = 110359, label = "Nalorakk's Prowl" },
            { x = 0.2791, y = 0.2860, criteriaID = 110360, label = "Zeb'Alar Lumberyard" },
            { x = 0.2482, y = 0.5483, criteriaID = 110361, label = "Amani Pass" },
            { x = 0.4669, y = 0.8217, criteriaID = 110362, label = "Solemn Valley" },
            { x = 0.4274, y = 0.8014, criteriaID = 110363, label = "Spiritpaw Burrow" },
        },
    },
}

local TREASURE_WAYPOINT_BY_QUEST = {
    [89067] = { map = 2444, x = 0.6069, y = 0.8426 },
    [89068] = { map = 2437, x = 0.4048, y = 0.4935 },
    [89069] = { map = 2395, x = 0.4831, y = 0.7554 },
    [89070] = { map = 2413, x = 0.5243, y = 0.5261 },
    [89071] = { map = 2413, x = 0.5275, y = 0.4998 },
    [89072] = { map = 2444, x = 0.6069, y = 0.8426 },
    [89073] = { map = 2393, x = 0.4759, y = 0.5041 },
    [89074] = { map = 2395, x = 0.4035, y = 0.6124 },
    [89078] = { map = 2413, x = 0.7057, y = 0.5090 },
    [89079] = { map = 2393, x = 0.3575, y = 0.6124 },
    [89080] = { map = 2395, x = 0.4635, y = 0.3486 },
    [89081] = { map = 2413, x = 0.6976, y = 0.5105 },
    [89082] = { map = 2444, x = 0.6201, y = 0.8351 },
    [89083] = { map = 2444, x = 0.6139, y = 0.8513 },
    [89084] = { map = 2393, x = 0.3179, y = 0.6828 },
    [89085] = { map = 2437, x = 0.4053, y = 0.4937 },
    [89089] = { map = 2437, x = 0.3308, y = 0.7891 },
    [89090] = { map = 2405, x = 0.3471, y = 0.5692 },
    [89091] = { map = 2437, x = 0.3075, y = 0.8398 },
    [89092] = { map = 2536, x = 0.4530, y = 0.4559 },
    [89093] = { map = 2444, x = 0.5374, y = 0.5168 },
    [89094] = { map = 2413, x = 0.5169, y = 0.5131 },
    [89095] = { map = 2413, x = 0.3610, y = 0.2517 },
    [89096] = { map = 2393, x = 0.4477, y = 0.5626 },
    [89100] = { map = 2536, x = 0.4877, y = 0.2255 },
    [89101] = { map = 2395, x = 0.4021, y = 0.6123, zoneName = "Eversong Woods", note = "In the bottom building" },
    [89102] = { map = 2405, x = 0.3546, y = 0.5882 },
    [89103] = { map = 2395, x = 0.6075, y = 0.5301 },
    [89104] = { map = 2413, x = 0.3775, y = 0.6523 },
    [89105] = { map = 2413, x = 0.6572, y = 0.5022 },
    [89106] = { map = 2437, x = 0.4041, y = 0.5118 },
    [89107] = { map = 2395, x = 0.6349, y = 0.3259 },
    [89111] = { map = 2437, x = 0.4040, y = 0.5118 },
    [89112] = { map = 2444, x = 0.4198, y = 0.4061 },
    [89113] = { map = 2413, x = 0.3477, y = 0.2469 },
    [89114] = { map = 2437, x = 0.4040, y = 0.5118 },
    [89115] = { map = 2393, x = 0.4911, y = 0.7585 },
    [89116] = { map = 2536, x = 0.4910, y = 0.2314 },
    [89117] = { map = 2393, x = 0.4775, y = 0.5169 },
    [89118] = { map = 2405, x = 0.3279, y = 0.4330 },
    [89122] = { map = 2393, x = 0.5064, y = 0.5651 },
    [89123] = { map = 2444, x = 0.3047, y = 0.6902 },
    [89124] = { map = 2393, x = 0.2862, y = 0.4638 },
    [89125] = { map = 2395, x = 0.5662, y = 0.4088 },
    [89126] = { map = 2444, x = 0.6274, y = 0.5343 },
    [89127] = { map = 2393, x = 0.5544, y = 0.4782 },
    [89128] = { map = 2444, x = 0.5420, y = 0.5104 },
    [89129] = { map = 2395, x = 0.3964, y = 0.3882 },
    [89133] = { map = 2393, x = 0.5132, y = 0.7445 },
    [89134] = { map = 2444, x = 0.2893, y = 0.3899 },
    [89135] = { map = 2395, x = 0.3957, y = 0.4580 },
    [89136] = { map = 2413, x = 0.6799, y = 0.4980 },
    [89137] = { map = 2444, x = 0.5413, y = 0.5100 },
    [89138] = { map = 2536, x = 0.6514, y = 0.3475 },
    [89139] = { map = 2393, x = 0.5120, y = 0.5726 },
    [89140] = { map = 2437, x = 0.3420, y = 0.8780 },
    [89144] = { map = 2444, x = 0.3047, y = 0.6907 },
    [89145] = { map = 2437, x = 0.4200, y = 0.4653 },
    [89146] = { map = 2444, x = 0.5424, y = 0.5160 },
    [89147] = { map = 2395, x = 0.3798, y = 0.4537 },
    [89148] = { map = 2444, x = 0.2875, y = 0.3857 },
    [89149] = { map = 2536, x = 0.3329, y = 0.6589 },
    [89150] = { map = 2405, x = 0.4184, y = 0.3821 },
    [89151] = { map = 2413, x = 0.3884, y = 0.6586 },
    [89155] = { map = 2413, x = 0.5111, y = 0.5571 },
    [89156] = { map = 2405, x = 0.3468, y = 0.5696 },
    [89157] = { map = 2437, x = 0.4191, y = 0.4591 },
    [89158] = { map = 2395, x = 0.6426, y = 0.3046 },
    [89159] = { map = 2413, x = 0.3666, y = 0.2506 },
    [89160] = { map = 2393, x = 0.4901, y = 0.7595 },
    [89161] = { map = 2405, x = 0.3468, y = 0.5696 },
    [89162] = { map = 2413, x = 0.3832, y = 0.6704 },
    [89166] = { map = 2413, x = 0.7609, y = 0.5108 },
    [89167] = { map = 2536, x = 0.4491, y = 0.4519 },
    [89168] = { map = 2413, x = 0.6952, y = 0.4917 },
    [89169] = { map = 2444, x = 0.4550, y = 0.4240 },
    [89170] = { map = 2437, x = 0.4039, y = 0.3601 },
    [89171] = { map = 2393, x = 0.4313, y = 0.5562 },
    [89172] = { map = 2437, x = 0.3307, y = 0.7907 },
    [89173] = { map = 2395, x = 0.4840, y = 0.7625 },
    [89177] = { map = 2393, x = 0.2697, y = 0.6029 },
    [89178] = { map = 2395, x = 0.4837, y = 0.7583 },
    [89179] = { map = 2536, x = 0.3312, y = 0.6579 },
    [89180] = { map = 2395, x = 0.5683, y = 0.4077 },
    [89181] = { map = 2444, x = 0.3051, y = 0.6900 },
    [89182] = { map = 2413, x = 0.6634, y = 0.5084 },
    [89183] = { map = 2393, x = 0.4916, y = 0.6135 },
    [89184] = { map = 2393, x = 0.4853, y = 0.7438 },
}

local function GetTreatiseQuestID(skillLineID)
    if cachedExpansionMode == "midnight" then
        return TREATISE_QUEST_MIDNIGHT[skillLineID]
    end
    return TREATISE_QUEST_TWW[skillLineID]
end
local function IsMidnightChildLine(parentID, childID)
    return MIDNIGHT_SKILL_LINES[parentID] and MIDNIGHT_SKILL_LINES[parentID] == childID
end

-- Called when profession window opens to capture child profession info
function lv.CaptureChildProfessionInfo()
    if C_TradeSkillUI and C_TradeSkillUI.GetChildProfessionInfo then
        local childInfo = C_TradeSkillUI.GetChildProfessionInfo()
        local childID = childInfo and tonumber(childInfo.professionID) or 0
        local parentID = childInfo and tonumber(childInfo.parentProfessionID) or 0
        if childID > 0 and parentID > 0 then
            -- Store mapping: parentID -> childID
            cachedChildSkillLines[parentID] = childID
            -- Also save to DB for persistence
            if LiteVaultDB then
                LiteVaultDB.childSkillLines = LiteVaultDB.childSkillLines or {}
                LiteVaultDB.childSkillLines[parentID] = childID
            end

            -- Promote to Midnight mode once a valid Midnight child line is detected.
            local expansionName = childInfo.expansionName and tostring(childInfo.expansionName):lower() or ""
            if expansionName:find("midnight", 1, true) or IsMidnightChildLine(parentID, childID) then
                cachedExpansionMode = "midnight"
                if LiteVaultDB then
                    LiteVaultDB.professionExpansionMode = "midnight"
                end
            end
        end
    end
end

-- Load cached skill lines from DB on startup
function lv.LoadCachedSkillLines()
    if LiteVaultDB and LiteVaultDB.childSkillLines then
        for parentID, childID in pairs(LiteVaultDB.childSkillLines) do
            if tonumber(childID) and tonumber(childID) > 0 then
                cachedChildSkillLines[parentID] = childID
            end
        end
    end
    if LiteVaultDB and LiteVaultDB.professionExpansionMode == "midnight" then
        cachedExpansionMode = "midnight"
    end
end

-- Get child skill line ID with fallback to hardcoded values
local function GetChildSkillLineID(parentSkillLineID)
    -- First check cached (dynamically captured) values
    if cachedChildSkillLines[parentSkillLineID] then
        return cachedChildSkillLines[parentSkillLineID]
    end
    -- If Midnight was detected once, use Midnight map for uncached professions too.
    if cachedExpansionMode == "midnight" and MIDNIGHT_SKILL_LINES[parentSkillLineID] then
        return MIDNIGHT_SKILL_LINES[parentSkillLineID]
    end
    -- Fallback to hardcoded current expansion values (default before first Midnight capture).
    if KHAZ_ALGAR_SKILL_LINES[parentSkillLineID] then
        return KHAZ_ALGAR_SKILL_LINES[parentSkillLineID]
    end
    -- Last resort: return the parent ID itself
    return parentSkillLineID
end

function lv.ScanProfessionDetails()
    if not LiteVaultDB then return end
    local name = lv.PLAYER_KEY or (UnitName("player") .. "-" .. GetRealmName())
    -- Don't create entry for declined characters
    local declined = LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[name]
    if declined or not LiteVaultDB[name] then return end
    local db = LiteVaultDB[name]

    local prof1, prof2 = GetProfessions()

    local function GetProfessionDetails(profIndex)
        if not profIndex then return nil end

        local profName, icon, skillLevel, maxSkillLevel, numAbilities, spellOffset, skillLineID = GetProfessionInfo(profIndex)
        if not profName or profName == "" then return nil end

        -- Preserve last good values when API data is temporarily unavailable.
        local prev = nil
        if db.professionDetails then
            for _, p in ipairs(db.professionDetails) do
                if p and (p.skillLineID == skillLineID or p.name == profName) then
                    prev = p
                    break
                end
            end
        end

        local details = {
            name = profName,
            icon = icon,
            skillLevel = skillLevel or 0,
            maxSkillLevel = maxSkillLevel or 0,
            skillLineID = skillLineID,
            concentration = (prev and prev.concentration) or 0,
            maxConcentration = (prev and prev.maxConcentration) or 1000,
            knowledgePoints = (prev and prev.knowledgePoints) or 0, -- backwards-compatible: unspent
            maxKnowledgePoints = (prev and prev.maxKnowledgePoints) or 0,
            knowledgeUnspent = (prev and prev.knowledgeUnspent) or 0,
            knowledgeSpent = (prev and prev.knowledgeSpent) or 0,
            knowledgeMax = (prev and prev.knowledgeMax) or 0,
            treatiseQuestID = (prev and prev.treatiseQuestID) or nil,
            treatiseDone = (prev and prev.treatiseDone) or false,
            artisanQuestID = (prev and prev.artisanQuestID) or nil,
            artisanDone = (prev and prev.artisanDone) or false,
            catchUpCurrencyID = (prev and prev.catchUpCurrencyID) or nil,
            catchUpQuantity = (prev and prev.catchUpQuantity) or 0,
            catchUpMax = (prev and prev.catchUpMax) or 0,
            catchUpName = (prev and prev.catchUpName) or nil,
            catchUpIcon = (prev and prev.catchUpIcon) or nil,
            treasureQuestStates = (prev and prev.treasureQuestStates) or nil,
        }

        local childSkillLineID = GetChildSkillLineID(skillLineID)

        -- Get concentration from child skillline first (expansion-specific), then parent as fallback.
        if C_TradeSkillUI and C_TradeSkillUI.GetConcentrationCurrencyID then
            local function ReadConcentrationFor(skillLine)
                local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(skillLine)
                if currencyID and currencyID > 0 then
                    local currencyInfo = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(currencyID)
                    if currencyInfo and type(currencyInfo.quantity) == "number" then
                        details.concentration = currencyInfo.quantity
                        details.maxConcentration = (type(currencyInfo.maxQuantity) == "number" and currencyInfo.maxQuantity > 0) and currencyInfo.maxQuantity or 1000
                        return true
                    end
                end
                return false
            end

            local gotConcentration = ReadConcentrationFor(childSkillLineID)
            if not gotConcentration and childSkillLineID ~= skillLineID then
                ReadConcentrationFor(skillLineID)
            end
        end

        -- Knowledge points: unspent first.
        if C_ProfSpecs and C_ProfSpecs.GetSpendableKnowledge then
            local kp = C_ProfSpecs.GetSpendableKnowledge(childSkillLineID)
            if type(kp) == "number" and kp >= 0 then
                details.knowledgeUnspent = kp
            end
        elseif C_ProfSpecs and C_ProfSpecs.GetCurrencyInfoForSkillLine then
            local currencyInfo = C_ProfSpecs.GetCurrencyInfoForSkillLine(childSkillLineID)
            if currencyInfo and currencyInfo.numAvailable then
                details.knowledgeUnspent = currencyInfo.numAvailable
            end
        end

        -- Scan spent/max from the profession traits tree.
        if C_ProfSpecs and C_ProfSpecs.GetConfigIDForSkillLine and C_Traits and C_Traits.GetConfigInfo then
            local spent, maxValue = 0, 0
            local configID = C_ProfSpecs.GetConfigIDForSkillLine(childSkillLineID)
            if configID and configID > 0 then
                local configInfo = C_Traits.GetConfigInfo(configID)
                if configInfo and configInfo.treeIDs then
                    for _, treeID in ipairs(configInfo.treeIDs) do
                        local treeNodes = C_Traits.GetTreeNodes(treeID)
                        if treeNodes then
                            for _, treeNode in ipairs(treeNodes) do
                                local nodeInfo = C_Traits.GetNodeInfo(configID, treeNode)
                                if nodeInfo then
                                    if nodeInfo.ranksPurchased and nodeInfo.ranksPurchased > 1 and nodeInfo.currentRank then
                                        spent = spent + math.max(0, (nodeInfo.currentRank - 1))
                                    end
                                    if nodeInfo.maxRanks then
                                        maxValue = maxValue + math.max(0, (nodeInfo.maxRanks - 1))
                                    end
                                end
                            end
                        end
                    end
                end
            end
            details.knowledgeSpent = spent
            details.knowledgeMax = maxValue
            details.maxKnowledgePoints = maxValue
        end

        -- Keep existing field behavior for current UI.
        details.knowledgePoints = details.knowledgeUnspent

        -- Weekly source status snapshot for this character/profession.
        local treatiseQuestID = GetTreatiseQuestID(skillLineID)
        local artisanQuestID = ARTISAN_QUEST_BY_PROF[skillLineID]
        if treatiseQuestID then
            details.treatiseQuestID = treatiseQuestID
            details.treatiseDone = C_QuestLog.IsQuestFlaggedCompleted(treatiseQuestID) and true or false
        end
        if artisanQuestID then
            details.artisanQuestID = artisanQuestID
            details.artisanDone = C_QuestLog.IsQuestFlaggedCompleted(artisanQuestID) and true or false
        end

        -- Catch-up currency snapshot.
        local catchUpCurrencyID = lv.KnowledgeSources and lv.KnowledgeSources.GetCatchUpCurrencyID and lv.KnowledgeSources.GetCatchUpCurrencyID(skillLineID)
        if catchUpCurrencyID then
            details.catchUpCurrencyID = catchUpCurrencyID
            local cInfo = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(catchUpCurrencyID)
            if cInfo then
                details.catchUpQuantity = tonumber(cInfo.quantity) or 0
                details.catchUpMax = tonumber(cInfo.maxQuantity) or 0
                details.catchUpName = cInfo.name
                details.catchUpIcon = cInfo.iconFileID
            end
        end

        local treasureData = MIDNIGHT_TREASURE_QUESTS[skillLineID]
        if treasureData then
            details.treasureQuestStates = {}
            for _, questID in ipairs(treasureData.unique or {}) do
                details.treasureQuestStates[questID] = C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
            end
            for _, questID in ipairs(treasureData.weekly or {}) do
                details.treasureQuestStates[questID] = C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
            end
        end

        return details
    end

    -- Build results into temporary table first
    local newDetails = {}

    if prof1 then
        local details = GetProfessionDetails(prof1)
        if details then
            table.insert(newDetails, details)
        end
    end

    if prof2 then
        local details = GetProfessionDetails(prof2)
        if details then
            table.insert(newDetails, details)
        end
    end

    -- Only update if we got data, don't overwrite existing data with empty
    if #newDetails > 0 then
        db.professionDetails = newDetails
    end
end

-- 2. WINDOW SETUP
local currentProfChar = nil
local currentProfTab = "sources"
local pendingTreasureRefresh = false

local LVProfessionWindow = CreateFrame("Frame", "LiteVaultProfessionWindow", UIParent, "BackdropTemplate")
LVProfessionWindow:SetSize(lv.Layout.professionWindowWidth or 500, lv.Layout.professionWindowHeight or 340)
LVProfessionWindow:SetPoint("CENTER")
LVProfessionWindow:SetFrameStrata("DIALOG")
LVProfessionWindow:SetMovable(true)
LVProfessionWindow:EnableMouse(true)
LVProfessionWindow:SetToplevel(true)
LVProfessionWindow:RegisterForDrag("LeftButton")
LVProfessionWindow:SetScript("OnDragStart", LVProfessionWindow.StartMoving)
LVProfessionWindow:SetScript("OnDragStop", LVProfessionWindow.StopMovingOrSizing)

LVProfessionWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
LVProfessionWindow:Hide()

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(LVProfessionWindow, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundSolid))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        LVProfessionWindow:SetBackdropColor(unpack(t.backgroundSolid))
        LVProfessionWindow:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

-- Title
LVProfessionWindow.title = LVProfessionWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
LVProfessionWindow.title:SetPoint("TOPLEFT", 15, -12)

-- Close Button
local profClose = CreateFrame("Button", nil, LVProfessionWindow, "BackdropTemplate")
profClose:SetSize(lv.Layout.professionCloseWidth or 60, 22)
profClose:SetPoint("TOPRIGHT", -8, -8)
profClose:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
profClose.Text = profClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
profClose.Text:SetPoint("CENTER")
profClose.Text:SetText(L["BUTTON_CLOSE"])
lv.ApplyLocaleFont(profClose.Text, 11)
lv.professionCloseBtn = profClose

local profSourcesTabBtn = CreateFrame("Button", nil, LVProfessionWindow, "BackdropTemplate")
profSourcesTabBtn:SetSize(lv.Layout.professionTabWidth or 72, 22)
profSourcesTabBtn:SetPoint("RIGHT", profClose, "LEFT", -6, 0)
profSourcesTabBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
profSourcesTabBtn.Text = profSourcesTabBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
profSourcesTabBtn.Text:SetPoint("CENTER")
profSourcesTabBtn.Text:SetText((L["TAB_SOURCES"] ~= "TAB_SOURCES") and L["TAB_SOURCES"] or "Sources")
lv.ApplyLocaleFont(profSourcesTabBtn.Text, 11)

local profTreasuresTabBtn = CreateFrame("Button", nil, LVProfessionWindow, "BackdropTemplate")
profTreasuresTabBtn:SetSize(lv.Layout.professionTreasureTabWidth or 76, 22)
profTreasuresTabBtn:SetPoint("RIGHT", profSourcesTabBtn, "LEFT", -4, 0)
profTreasuresTabBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
profTreasuresTabBtn.Text = profTreasuresTabBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
profTreasuresTabBtn.Text:SetPoint("CENTER")
profTreasuresTabBtn.Text:SetText((L["TAB_TREASURES"] ~= "TAB_TREASURES") and L["TAB_TREASURES"] or "Treasures")
lv.ApplyLocaleFont(profTreasuresTabBtn.Text, 11)

local profGlyphsTabBtn = CreateFrame("Button", nil, LVProfessionWindow, "BackdropTemplate")
profGlyphsTabBtn:SetSize(lv.Layout.professionGlyphTabWidth or 64, 22)
profGlyphsTabBtn:SetPoint("RIGHT", profTreasuresTabBtn, "LEFT", -4, 0)
profGlyphsTabBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
profGlyphsTabBtn.Text = profGlyphsTabBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
profGlyphsTabBtn.Text:SetPoint("CENTER")
profGlyphsTabBtn.Text:SetText(LT("TAB_GLYPHS", "Glyphs"))
lv.ApplyLocaleFont(profGlyphsTabBtn.Text, 11)

-- Register close button for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(profClose, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(profSourcesTabBtn, function(btn, theme)
            local isActive = (currentProfTab == "sources")
            btn:SetBackdropColor(unpack(isActive and (theme.buttonBgHover or theme.buttonBgAlt) or theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(isActive and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(profTreasuresTabBtn, function(btn, theme)
            local isActive = (currentProfTab == "treasures")
            btn:SetBackdropColor(unpack(isActive and (theme.buttonBgHover or theme.buttonBgAlt) or theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(isActive and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(profGlyphsTabBtn, function(btn, theme)
            local isActive = (currentProfTab == "glyphs")
            btn:SetBackdropColor(unpack(isActive and (theme.buttonBgHover or theme.buttonBgAlt) or theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(isActive and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        local t = lv.GetTheme()
        profClose:SetBackdropColor(unpack(t.buttonBgAlt))
        profClose:SetBackdropBorderColor(unpack(t.borderPrimary))
        profClose.Text:SetTextColor(unpack(t.textPrimary))
        profSourcesTabBtn:SetBackdropColor(unpack(t.buttonBgHover or t.buttonBgAlt))
        profSourcesTabBtn:SetBackdropBorderColor(unpack(t.borderHover or t.borderPrimary))
        profSourcesTabBtn.Text:SetTextColor(unpack(t.textPrimary))
        profTreasuresTabBtn:SetBackdropColor(unpack(t.buttonBgAlt))
        profTreasuresTabBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        profTreasuresTabBtn.Text:SetTextColor(unpack(t.textPrimary))
        profGlyphsTabBtn:SetBackdropColor(unpack(t.buttonBgAlt))
        profGlyphsTabBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        profGlyphsTabBtn.Text:SetTextColor(unpack(t.textPrimary))
    end
end)

profClose:SetScript("OnClick", function() LVProfessionWindow:Hide() end)
profClose:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
profClose:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

profSourcesTabBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
profSourcesTabBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    local isActive = (currentProfTab == "sources")
    self:SetBackdropBorderColor(unpack(isActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    self:SetBackdropColor(unpack(isActive and (t.buttonBgHover or t.buttonBgAlt) or t.buttonBgAlt))
end)

profTreasuresTabBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
profTreasuresTabBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    local isActive = (currentProfTab == "treasures")
    self:SetBackdropBorderColor(unpack(isActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    self:SetBackdropColor(unpack(isActive and (t.buttonBgHover or t.buttonBgAlt) or t.buttonBgAlt))
end)

profGlyphsTabBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
profGlyphsTabBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    local isActive = (currentProfTab == "glyphs")
    self:SetBackdropBorderColor(unpack(isActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    self:SetBackdropColor(unpack(isActive and (t.buttonBgHover or t.buttonBgAlt) or t.buttonBgAlt))
end)

local function RefreshProfessionTabButtons()
    local t = lv.GetTheme()
    if not t then return end
    profClose.Text:SetText((L["BUTTON_CLOSE"] ~= "BUTTON_CLOSE") and L["BUTTON_CLOSE"] or "Close")
    profSourcesTabBtn.Text:SetText((L["TAB_SOURCES"] ~= "TAB_SOURCES") and L["TAB_SOURCES"] or "Sources")
    profTreasuresTabBtn.Text:SetText((L["TAB_TREASURES"] ~= "TAB_TREASURES") and L["TAB_TREASURES"] or "Treasures")
    profGlyphsTabBtn.Text:SetText(LT("TAB_GLYPHS", "Glyphs"))
    local srcActive = (currentProfTab == "sources")
    local treActive = (currentProfTab == "treasures")
    local glyphActive = (currentProfTab == "glyphs")
    profSourcesTabBtn:SetBackdropColor(unpack(srcActive and (t.buttonBgHover or t.buttonBgAlt) or t.buttonBgAlt))
    profSourcesTabBtn:SetBackdropBorderColor(unpack(srcActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    profTreasuresTabBtn:SetBackdropColor(unpack(treActive and (t.buttonBgHover or t.buttonBgAlt) or t.buttonBgAlt))
    profTreasuresTabBtn:SetBackdropBorderColor(unpack(treActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
    profGlyphsTabBtn:SetBackdropColor(unpack(glyphActive and (t.buttonBgHover or t.buttonBgAlt) or t.buttonBgAlt))
    profGlyphsTabBtn:SetBackdropBorderColor(unpack(glyphActive and (t.borderHover or t.borderPrimary) or t.borderPrimary))
end

profSourcesTabBtn:SetScript("OnClick", function()
    if currentProfTab == "sources" then return end
    currentProfTab = "sources"
    RefreshProfessionTabButtons()
    if currentProfChar then
        lv.ShowProfessionWindow(currentProfChar, true)
    end
end)

profTreasuresTabBtn:SetScript("OnClick", function()
    if currentProfTab == "treasures" then return end
    currentProfTab = "treasures"
    RefreshProfessionTabButtons()
    if currentProfChar then
        lv.ShowProfessionWindow(currentProfChar, true)
    end
end)

profGlyphsTabBtn:SetScript("OnClick", function()
    if currentProfTab == "glyphs" then return end
    currentProfTab = "glyphs"
    RefreshProfessionTabButtons()
    if currentProfChar then
        lv.ShowProfessionWindow(currentProfChar, true)
    end
end)

lv.LVProfessionWindow = LVProfessionWindow

-- Create profession display rows (max 2 professions)
local profRows = {}
for i = 1, 2 do
    local f = CreateFrame("Frame", nil, LVProfessionWindow)
    f:SetSize(470, 124)
    f:SetPoint("TOPLEFT", 15, -40 - ((i-1) * 132))

    -- Profession icon
    f.iconBadge = CreateCircularBadge(f, "TOPLEFT", f, "TOPLEFT", 0, 0, PROFESSION_WINDOW_BADGE_STYLE)
    f.icon = f.iconBadge.icon

    -- Profession name
    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.name:SetPoint("TOPLEFT", f.iconBadge, "TOPRIGHT", 10, -2)

    -- Skill level
    f.skill = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.skill:SetPoint("TOPLEFT", f.name, "BOTTOMLEFT", 0, -4)

    -- Concentration bar background
    f.concBg = f:CreateTexture(nil, "BACKGROUND")
    f.concBg:SetSize(220, 14)
    f.concBg:SetPoint("TOPLEFT", f.skill, "BOTTOMLEFT", 0, -6)
    f.concBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    -- Concentration bar fill
    f.concBar = f:CreateTexture(nil, "ARTWORK")
    f.concBar:SetSize(220, 14)
    f.concBar:SetPoint("TOPLEFT", f.concBg, "TOPLEFT", 0, 0)
    f.concBar:SetColorTexture(0.25, 0.4, 0.7, 1) -- Muted blue for concentration

    -- Concentration bar border (thin 1px border)
    f.concBorder = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.concBorder:SetSize(222, 16)
    f.concBorder:SetPoint("CENTER", f.concBg, "CENTER", 0, 0)
    f.concBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f.concBorder:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    -- Concentration text
    f.concText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.concText:SetPoint("CENTER", f.concBg, "CENTER", 0, 0)

    -- Concentration reset times (daily + weekly)
    f.concReset = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.concReset:SetPoint("TOPLEFT", f.concBg, "BOTTOMLEFT", 0, -4)

    -- Knowledge points
    f.knowledge = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.knowledge:SetPoint("TOPLEFT", f.concReset, "BOTTOMLEFT", 0, -4)

    -- Sources summary (always visible in Skills window)
    f.sourcesTop = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.sourcesTop:SetPoint("TOPLEFT", f.knowledge, "BOTTOMLEFT", 0, -3)
    f.sourcesBottom = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.sourcesBottom:SetPoint("TOPLEFT", f.sourcesTop, "BOTTOMLEFT", 0, -2)

    f.treasureHint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.treasureHint:SetPoint("TOPLEFT", f.skill, "BOTTOMLEFT", 0, -6)
    f.treasureHint:Hide()

    f.uniqueHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.uniqueHeader:SetPoint("TOPLEFT", 0, -38)
    f.uniqueHeader:Hide()

    f.weeklyHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.weeklyHeader:SetPoint("TOPLEFT", 228, -38)
    f.weeklyHeader:Hide()

    f.treasureButtons = {}
    for idx = 1, 16 do
        local btn = CreateFrame("Button", nil, f)
        btn:SetSize(215, 16)
        local col = (idx <= 8) and 0 or 1
        local rowIdx = ((idx - 1) % 8)
        btn:SetPoint("TOPLEFT", 0 + (col * 228), -56 - (rowIdx * 18))
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.text:SetPoint("LEFT", 0, 0)
        btn.text:SetJustifyH("LEFT")
        btn.text:SetWidth(215)
        btn.text:SetWordWrap(false)
        btn:Hide()
        f.treasureButtons[idx] = btn
    end

    profRows[i] = f
end

-- Register concentration bar borders for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for i = 1, 2 do
            local row = profRows[i]
            lv.RegisterThemedElement(row.concBorder, function(border, theme)
                border:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            -- Apply initial theme
            local t = lv.GetTheme()
            row.concBorder:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end
end)

-- No professions text
local noProfText = LVProfessionWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
noProfText:SetPoint("CENTER", 0, 0)
noProfText:SetText("|cff666666" .. L["LABEL_NO_PROFESSIONS"] .. "|r")
noProfText:Hide()

local glyphPanels = {}
for i = 1, 4 do
    local panel = CreateFrame("Frame", nil, LVProfessionWindow)
    panel:SetSize(228, 136)
    local col = ((i - 1) % 2)
    local row = math.floor((i - 1) / 2)
    panel:SetPoint("TOPLEFT", 15 + (col * 235), -44 - (row * 142))

    panel.header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.header:SetPoint("TOPLEFT", 0, 0)
    panel.header:SetJustifyH("LEFT")

    panel.buttons = {}
    for idx = 1, 12 do
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(108, 16)
        local btnCol = ((idx - 1) % 2)
        local btnRow = math.floor((idx - 1) / 2)
        btn:SetPoint("TOPLEFT", btnCol * 114, -22 - (btnRow * 18))
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.text:SetPoint("LEFT", 0, 0)
        btn.text:SetWidth(108)
        btn.text:SetJustifyH("LEFT")
        btn.text:SetWordWrap(false)
        btn:Hide()
        panel.buttons[idx] = btn
    end

    panel:Hide()
    glyphPanels[i] = panel
end

local function BoolStatusText(done)
    if done then
        return "|cff00ff00" .. (L["STATUS_DONE_WORD"] ~= "STATUS_DONE_WORD" and L["STATUS_DONE_WORD"] or "Done") .. "|r"
    end
    return "|cffff5555" .. (L["STATUS_MISSING_WORD"] ~= "STATUS_MISSING_WORD" and L["STATUS_MISSING_WORD"] or "Missing") .. "|r"
end

local QueueTreasureRefreshOnItemLoad

local function GetTreasureZoneName(questID)
    local wp = questID and TREASURE_WAYPOINT_BY_QUEST[questID]
    if wp and wp.zoneName then
        return wp.zoneName
    end
    if not wp or not C_Map or not C_Map.GetMapInfo then
        return nil
    end

    local mapInfo = C_Map.GetMapInfo(wp.map)
    if not mapInfo or not mapInfo.name then
        return nil
    end

    local zoneName = mapInfo.name
    local parentMapID = mapInfo.parentMapID
    if parentMapID and parentMapID > 0 then
        local parentInfo = C_Map.GetMapInfo(parentMapID)
        if parentInfo and parentInfo.name and parentInfo.name ~= zoneName then
            return string.format("%s (%s)", zoneName, parentInfo.name)
        end
    end

    return zoneName
end

local function GetQuestDisplayName(questID)
    if not questID then
        return L["LABEL_UNKNOWN"] or "Unknown"
    end
    local title = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)
    if title and title ~= "" then
        return title
    end
    if C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        C_QuestLog.RequestLoadQuestByID(questID)
    end
    local QUEST_NAME_FALLBACK = {
        -- Midnight Treatises
        [95127] = "Thalassian Treatise on Alchemy",
        [95128] = "Thalassian Treatise on Blacksmithing",
        [95129] = "Thalassian Treatise on Enchanting",
        [83728] = "Thalassian Treatise on Engineering",
        [95130] = "Thalassian Treatise on Herbalism",
        [95131] = "Thalassian Treatise on Inscription",
        [95133] = "Thalassian Treatise on Jewelcrafting",
        [95134] = "Thalassian Treatise on Leatherworking",
        [95135] = "Thalassian Treatise on Mining",
        [95136] = "Thalassian Treatise on Skinning",
        [95137] = "Thalassian Treatise on Tailoring",

        -- Midnight weekly artisan quests
        [93690] = "Alchemy Services Requested",
        [93691] = "Blacksmithing Services Requested",
        [93692] = "Engineering Services Requested",
        [93693] = "Inscription Services Requested",
        [93694] = "Jewelcrafting Services Requested",
        [93695] = "Leatherworking Services Requested",
        [93696] = "Tailoring Services Requested",
        [93697] = "Enchanting Trainer Weekly",
        [93698] = "Enchanting Trainer Weekly",
        [93699] = "Enchanting Trainer Weekly",
        [93700] = "Herbalism Trainer Weekly",
        [93701] = "Herbalism Trainer Weekly",
        [93702] = "Herbalism Trainer Weekly",
        [93703] = "Herbalism Trainer Weekly",
        [93704] = "Herbalism Trainer Weekly",
        [93705] = "Mining Trainer Weekly",
        [93706] = "Mining Trainer Weekly",
        [93707] = "Mining Trainer Weekly",
        [93708] = "Mining Trainer Weekly",
        [93709] = "Mining Trainer Weekly",
        [93710] = "Skinning Trainer Weekly",
        [93711] = "Skinning Trainer Weekly",
        [93712] = "Skinning Trainer Weekly",
        [93713] = "Skinning Trainer Weekly",
        [93714] = "Skinning Trainer Weekly",

        -- Midnight catch-up unlock hidden quest IDs
        [93532] = "Enchanting Catch-up Unlock",
        [93533] = "Enchanting Catch-up Unlock",
        [95048] = "Enchanting Catch-up Unlock",
        [95053] = "Enchanting Catch-up Unlock",
        [81421] = "Herbalism Catch-up Unlock",
        [81430] = "Herbalism Catch-up Unlock",
        [88673] = "Mining Catch-up Unlock",
        [88678] = "Mining Catch-up Unlock",
        [88534] = "Skinning Catch-up Unlock",
        [88529] = "Skinning Catch-up Unlock",
    }
    local TREASURE_ITEM_BY_QUEST = {
        [81425] = 238465, [81426] = 238465, [81427] = 238465, [81428] = 238465, [81429] = 238465, [81430] = 238466,
        [88529] = 238626, [88530] = 238625, [88534] = 238625, [88536] = 238625, [88537] = 238625, [88549] = 238625,
        [88673] = 237496, [88674] = 237496, [88675] = 237496, [88676] = 237496, [88677] = 237496, [88678] = 237506,
        [89067] = 238572, [89068] = 238573, [89069] = 238574, [89070] = 238575, [89071] = 238576, [89072] = 238577, [89073] = 238578, [89074] = 238579,
        [89078] = 238612, [89079] = 238613, [89080] = 238614, [89081] = 238615, [89082] = 238616, [89083] = 238617, [89084] = 238618, [89085] = 238619,
        [89089] = 238588, [89090] = 238589, [89091] = 238590, [89092] = 238591, [89093] = 238592, [89094] = 238593, [89095] = 238594, [89096] = 238595,
        [89100] = 238548, [89101] = 238549, [89102] = 238550, [89103] = 238551, [89104] = 238552, [89105] = 238553, [89106] = 238554, [89107] = 238555,
        [89111] = 238532, [89112] = 238533, [89113] = 238534, [89114] = 238535, [89115] = 238536, [89116] = 238537, [89117] = 238538, [89118] = 238539,
        [89122] = 238580, [89123] = 238581, [89124] = 238582, [89125] = 238583, [89126] = 238584, [89127] = 238585, [89128] = 238586, [89129] = 238587,
        [89133] = 238556, [89134] = 238557, [89135] = 238558, [89136] = 238559, [89137] = 238560, [89138] = 238561, [89139] = 238562, [89140] = 238563,
        [89144] = 238596, [89145] = 238597, [89146] = 238598, [89147] = 238599, [89148] = 238600, [89149] = 238601, [89150] = 238602, [89151] = 238603,
        [89155] = 238475, [89156] = 238474, [89157] = 238473, [89158] = 238472, [89159] = 238471, [89160] = 238470, [89161] = 238469, [89162] = 238468,
        [89166] = 238628, [89167] = 238629, [89168] = 238630, [89169] = 238631, [89170] = 238632, [89171] = 238633, [89172] = 238634, [89173] = 238635,
        [89177] = 238540, [89178] = 238541, [89179] = 238542, [89180] = 238543, [89181] = 238544, [89182] = 238545, [89183] = 238546, [89184] = 238547,
        [93528] = 259188, [93529] = 259189, [93530] = 259190, [93531] = 259191, [93532] = 259192, [93533] = 259193, [93534] = 259194, [93535] = 259195,
        [93536] = 259196, [93537] = 259197, [93538] = 259199, [93539] = 259198, [93540] = 259200, [93541] = 259201, [93542] = 259202, [93543] = 259203,
        [95048] = 267654, [95049] = 267654, [95050] = 267654, [95051] = 267654, [95052] = 267654, [95053] = 267655,
    }
    if QUEST_NAME_FALLBACK[questID] then
        return QUEST_NAME_FALLBACK[questID]
    end
    local itemID = TREASURE_ITEM_BY_QUEST[questID]
    if itemID then
        local itemName = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
        if (not itemName or itemName == "") and C_Item and C_Item.RequestLoadItemDataByID then
            C_Item.RequestLoadItemDataByID(itemID)
            QueueTreasureRefreshOnItemLoad(itemID)
        end
        if itemName and itemName ~= "" then
            return LT(itemName, itemName)
        end
    end
    local SKILL_NAME_BY_ID = {
        [171] = "Alchemy", [164] = "Blacksmithing", [333] = "Enchanting", [202] = "Engineering",
        [182] = "Herbalism", [773] = "Inscription", [755] = "Jewelcrafting", [165] = "Leatherworking",
        [186] = "Mining", [393] = "Skinning", [197] = "Tailoring",
    }
    for skillLineID, data in pairs(MIDNIGHT_TREASURE_QUESTS or {}) do
        if data.unique then
            for idx, qid in ipairs(data.unique) do
                if qid == questID then
                    local pName = L[SKILL_NAME_BY_ID[skillLineID] or ""] or SKILL_NAME_BY_ID[skillLineID] or "Profession"
                    return string.format(LT("LABEL_UNIQUE_TREASURE_FMT", "%s Unique Treasure %d"), pName, idx)
                end
            end
        end
        if data.weekly then
            for idx, qid in ipairs(data.weekly) do
                if qid == questID then
                    local pName = L[SKILL_NAME_BY_ID[skillLineID] or ""] or SKILL_NAME_BY_ID[skillLineID] or "Profession"
                    return string.format(LT("LABEL_WEEKLY_TREASURE_FMT", "%s Weekly Treasure %d"), pName, idx)
                end
            end
        end
    end
    return string.format("%s %d", (L["LABEL_QUEST"] ~= "LABEL_QUEST" and L["LABEL_QUEST"] or "Quest"), questID)
end

local function QuestStatusLine(done, questName)
    local doneWord = (L["STATUS_DONE_WORD"] ~= "STATUS_DONE_WORD") and L["STATUS_DONE_WORD"] or "Done"
    local missWord = (L["STATUS_MISSING_WORD"] ~= "STATUS_MISSING_WORD") and L["STATUS_MISSING_WORD"] or "Missing"
    local status = done and ("|cff00ff00" .. doneWord .. "|r") or ("|cffff5555" .. missWord .. "|r")
    return string.format("%s: %s", status, questName)
end

local function PrintProfessionMessage(msg)
    local prefix = "|cff9933ff" .. ((L and L["MSG_PREFIX"]) or "LiteVault") .. "|r "
    print(prefix .. msg)
end

local function HasTomTom()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("TomTom")
    return (loaded and _G.TomTom) and true or false
end

local function CanUseBlizzardWaypoint()
    return C_Map and C_Map.SetUserWaypoint and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates
end

local function SetBlizzardTreasureWaypoint(mapID, x, y)
    if not CanUseBlizzardWaypoint() then
        return false
    end
    local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
    if not point then
        return false
    end
    C_Map.SetUserWaypoint(point)
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    return true
end

local function SetTreasureWaypoint(questID, title)
    local wp = TREASURE_WAYPOINT_BY_QUEST[questID]
    if not wp then
        PrintProfessionMessage((L["MSG_TREASURE_NO_WAYPOINT"] ~= "MSG_TREASURE_NO_WAYPOINT") and L["MSG_TREASURE_NO_WAYPOINT"] or "No fixed waypoint for this treasure.")
        return
    end
    local displayTitle = title or GetQuestDisplayName(questID)
    if HasTomTom() then
        _G.TomTom:AddWaypoint(wp.map, wp.x, wp.y, {
            title = displayTitle,
            persistent = false,
            source = addonName,
        })
        PrintProfessionMessage(string.format((L["MSG_TREASURE_WAYPOINT_SET"] ~= "MSG_TREASURE_WAYPOINT_SET") and L["MSG_TREASURE_WAYPOINT_SET"] or "Waypoint set: %s (%.1f, %.1f)", displayTitle, wp.x * 100, wp.y * 100))
        return
    end
    if SetBlizzardTreasureWaypoint(wp.map, wp.x, wp.y) then
        PrintProfessionMessage(string.format((L["MSG_TREASURE_BLIZZ_WAYPOINT_SET"] ~= "MSG_TREASURE_BLIZZ_WAYPOINT_SET") and L["MSG_TREASURE_BLIZZ_WAYPOINT_SET"] or "Map waypoint set: %s (%.1f, %.1f)", displayTitle, wp.x * 100, wp.y * 100))
        return
    end
    PrintProfessionMessage((L["MSG_TOMTOM_NOT_DETECTED"] ~= "MSG_TOMTOM_NOT_DETECTED") and L["MSG_TOMTOM_NOT_DETECTED"] or "TomTom not detected.")
end

local function SetGlyphWaypoint(glyph, zoneData)
    if not glyph or not zoneData then
        return
    end
    local displayTitle = glyph.label or LT("TAB_GLYPHS", "Glyphs")
    if HasTomTom() then
        _G.TomTom:AddWaypoint(zoneData.map, glyph.x, glyph.y, {
            title = displayTitle,
            persistent = false,
            source = addonName,
        })
        PrintProfessionMessage(string.format((L["MSG_TREASURE_WAYPOINT_SET"] ~= "MSG_TREASURE_WAYPOINT_SET") and L["MSG_TREASURE_WAYPOINT_SET"] or "Waypoint set: %s (%.1f, %.1f)", displayTitle, glyph.x * 100, glyph.y * 100))
        return
    end
    if SetBlizzardTreasureWaypoint(zoneData.map, glyph.x, glyph.y) then
        PrintProfessionMessage(string.format((L["MSG_TREASURE_BLIZZ_WAYPOINT_SET"] ~= "MSG_TREASURE_BLIZZ_WAYPOINT_SET") and L["MSG_TREASURE_BLIZZ_WAYPOINT_SET"] or "Map waypoint set: %s (%.1f, %.1f)", displayTitle, glyph.x * 100, glyph.y * 100))
        return
    end
    PrintProfessionMessage((L["MSG_TOMTOM_NOT_DETECTED"] ~= "MSG_TOMTOM_NOT_DETECTED") and L["MSG_TOMTOM_NOT_DETECTED"] or "TomTom not detected.")
end

QueueTreasureRefreshOnItemLoad = function(itemID)
    if not itemID or pendingTreasureRefresh then return end
    if not C_Item or not Item or not Item.CreateFromItemID then return end
    pendingTreasureRefresh = true
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        pendingTreasureRefresh = false
        if currentProfChar and LVProfessionWindow and LVProfessionWindow:IsShown() and currentProfTab == "treasures" then
            lv.ShowProfessionWindow(currentProfChar, true)
        end
    end)
end

local function CleanTrackerLabel(text)
    if not text or text == "" then return text end
    -- Remove noisy tracker prefixes like "12.x Professions - Tracker - "
    local cleaned = tostring(text)
    cleaned = cleaned:gsub("^%d+%.x%s+", "")
    cleaned = cleaned:gsub("^%d+%.%d+%s+", "")
    cleaned = cleaned:gsub("^[Pp]rofessions%s*%-%s*Tracker%s*%-%s*", "")
    return cleaned
end

local function CountCompletedQuests(questList)
    if not questList or #questList == 0 then
        return 0, 0
    end
    local done = 0
    for _, qid in ipairs(questList) do
        if C_QuestLog.IsQuestFlaggedCompleted(qid) then
            done = done + 1
        end
    end
    return done, #questList
end

local function IsStoredQuestDone(profData, questID)
    if not profData or not profData.treasureQuestStates then
        return nil
    end
    local state = profData.treasureQuestStates[questID]
    if state == nil then
        return nil
    end
    return state and true or false
end

local function IsQuestDoneForCharacter(charKey, profData, questID)
    if charKey == lv.PLAYER_KEY then
        return C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
    end
    local stored = IsStoredQuestDone(profData, questID)
    if stored ~= nil then
        return stored
    end
    return false
end

local function CountCompletedQuestsForCharacter(charKey, profData, questList)
    if not questList or #questList == 0 then
        return 0, 0
    end
    local done = 0
    for _, qid in ipairs(questList) do
        if IsQuestDoneForCharacter(charKey, profData, qid) then
            done = done + 1
        end
    end
    return done, #questList
end

local function IsAchievementCriteriaDone(achievementID, criteriaID)
    if not (achievementID and criteriaID) then
        return false
    end
    local _, _, completed = GetAchievementCriteriaInfoByID(achievementID, criteriaID)
    if completed ~= nil then
        return completed and true or false
    end
    if criteriaID <= (GetAchievementNumCriteria(achievementID) or 0) then
        local _, _, fallbackDone = GetAchievementCriteriaInfo(achievementID, criteriaID)
        return fallbackDone and true or false
    end
    return false
end

local function CountCompletedGlyphs(zoneData)
    if not zoneData or not zoneData.glyphs then
        return 0, 0
    end
    local done = 0
    for _, glyph in ipairs(zoneData.glyphs) do
        if IsAchievementCriteriaDone(zoneData.achievementID, glyph.criteriaID) then
            done = done + 1
        end
    end
    return done, #zoneData.glyphs
end

lv.GetMidnightGlyphZones = function()
    return MIDNIGHT_GLYPH_ZONES
end

lv.IsGlyphCompleted = function(zoneData, glyph)
    if not zoneData or not glyph then
        return false
    end
    return IsAchievementCriteriaDone(zoneData.achievementID, glyph.criteriaID)
end

lv.CountCompletedGlyphs = CountCompletedGlyphs
lv.SetGlyphWaypoint = SetGlyphWaypoint

-- 3. PUBLIC FUNCTION
function lv.ShowProfessionWindow(charKey, forceRefresh)
    if currentProfTab == "glyphs" then
        currentProfTab = "sources"
    end
    if LVProfessionWindow:IsShown() and currentProfChar == charKey and not forceRefresh then
        LVProfessionWindow:Hide()
        currentProfChar = nil
        return
    end
    currentProfChar = charKey

    -- Scan current character's professions if viewing self
    if charKey == lv.PLAYER_KEY then
        lv.ScanProfessionDetails()
    end

    local data = LiteVaultDB[charKey]
    if not data then return end

    local nameOnly = charKey:match("^([^-]+)")
    local cc = C_ClassColor.GetClassColor(data.class or "WARRIOR")
    if currentProfTab == "glyphs" then
        LVProfessionWindow.title:SetText(LT("TITLE_GLYPH_HUNTER", "Glyph Hunter"))
    else
        LVProfessionWindow.title:SetText(string.format(L["TITLE_PROFESSIONS"], cc:WrapTextInColorCode(nameOnly)))
    end
    RefreshProfessionTabButtons()

    -- Hide all rows first
    for i = 1, 2 do
        profRows[i]:Hide()
    end
    for i = 1, #glyphPanels do
        glyphPanels[i]:Hide()
    end
    noProfText:Hide()

    -- Use professionDetails if it has data, otherwise fall back to basic professions
    local profData = (data.professionDetails and #data.professionDetails > 0) and data.professionDetails or data.professions or {}

    -- Gathering professions don't have concentration
    local gatheringProfs = {
        ["Mining"] = true, ["Herbalism"] = true, ["Skinning"] = true,
        -- German
        ["Bergbau"] = true, ["Kräuterkunde"] = true, ["Kürschnerei"] = true,
        -- French
        ["Minage"] = true, ["Herboristerie"] = true, ["Dépeçage"] = true,
        -- Spanish
        ["Minería"] = true, ["Herboristería"] = true, ["Desuello"] = true,
        -- Portuguese
        ["Mineração"] = true, ["Herborismo"] = true, ["Esfolamento"] = true,
        -- Russian
        ["Горное дело"] = true, ["Травничество"] = true, ["Снятие шкур"] = true,
        -- Chinese (Simplified)
        ["采矿"] = true, ["草药学"] = true, ["剥皮"] = true,
        -- Chinese (Traditional)
        ["採礦"] = true, ["草藥學"] = true, ["剝皮"] = true,
        -- Korean
        ["채광"] = true, ["약초채집"] = true, ["무두질"] = true,
    }

    if currentProfTab == "glyphs" then
        for idx, zoneData in ipairs(MIDNIGHT_GLYPH_ZONES) do
            local panel = glyphPanels[idx]
            if panel then
                local done, total = CountCompletedGlyphs(zoneData)
                panel.header:SetText(string.format("|cffffffcc%s: |cffffff00%d/%d|r", zoneData.zoneName, done, total))

                for buttonIndex, btn in ipairs(panel.buttons) do
                    btn:Hide()
                    btn:SetScript("OnClick", nil)
                    btn:SetScript("OnEnter", nil)
                    btn:SetScript("OnLeave", nil)

                    local glyph = zoneData.glyphs[buttonIndex]
                    if glyph then
                        local glyphDone = IsAchievementCriteriaDone(zoneData.achievementID, glyph.criteriaID)
                        local color = glyphDone and "|cff00ff00" or "|cffff5555"
                        btn.text:SetText(color .. glyph.label .. "|r")
                        btn:Show()
                        btn:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
                            GameTooltip:ClearLines()
                            GameTooltip:SetText(glyph.label, 0.4, 0.8, 1)
                            GameTooltip:AddLine(string.format("%s: %s", (L["LABEL_ZONE"] ~= "LABEL_ZONE") and L["LABEL_ZONE"] or "Zone", zoneData.zoneName), 1, 1, 1)
                            GameTooltip:AddLine(string.format("%s: %.1f / %.1f", (L["LABEL_COORDINATES"] ~= "LABEL_COORDINATES") and L["LABEL_COORDINATES"] or "Coordinates", glyph.x * 100, glyph.y * 100), 1, 1, 1)
                            GameTooltip:AddLine(string.format("%s: %s", LT("LABEL_ACHIEVEMENT", "Achievement"), BoolStatusText(glyphDone)), 1, 1, 1)
                            if HasTomTom() then
                                GameTooltip:AddLine((L["TOOLTIP_TREASURE_SET_WAYPOINT"] ~= "TOOLTIP_TREASURE_SET_WAYPOINT") and L["TOOLTIP_TREASURE_SET_WAYPOINT"] or "Click to place a TomTom waypoint", 0.2, 1, 0.2)
                            elseif CanUseBlizzardWaypoint() then
                                GameTooltip:AddLine((L["TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT"] ~= "TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT") and L["TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT"] or "Click to place a map waypoint", 0.2, 1, 0.2)
                            else
                                GameTooltip:AddLine((L["MSG_TOMTOM_NOT_DETECTED"] ~= "MSG_TOMTOM_NOT_DETECTED") and L["MSG_TOMTOM_NOT_DETECTED"] or "TomTom not detected.", 1, 0.2, 0.2)
                            end
                            GameTooltip:Show()
                        end)
                        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                        btn:SetScript("OnClick", function()
                            SetGlyphWaypoint(glyph, zoneData)
                        end)
                    end
                end

                panel:Show()
            end
        end

        LVProfessionWindow:SetHeight(345)
    elseif #profData == 0 then
        noProfText:Show()
        LVProfessionWindow:SetHeight(100)
    else
        local yOffset = -40
        local requestedTreasureData = false
        for i, prof in ipairs(profData) do
            if i > 2 then break end
            local row = profRows[i]
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", LVProfessionWindow, "TOPLEFT", 15, yOffset)

            SetCircularBadgeTexture(row.iconBadge, prof.icon or 136243)
            SetCircularBadgeState(row.iconBadge, false)
            -- Translate profession name using locale, fallback to stored name
            local displayName = L[prof.name] or prof.name or L["LABEL_UNKNOWN"]
            row._profDisplayName = displayName
            row.name:SetText(string.format("|cff66ccff%s|r", displayName))
            row.skill:SetText(string.format(L["LABEL_SKILL_LEVEL"], prof.skillLevel or 0, prof.maxSkillLevel or 0))

            -- Check if this is a gathering profession (no concentration)
            -- Use original English name for lookup since gatheringProfs uses English keys
            local isGathering = gatheringProfs[prof.name] or false

            if currentProfTab == "sources" then
                row.treasureHint:Hide()
                row.uniqueHeader:Hide()
                row.weeklyHeader:Hide()
                for _, btn in ipairs(row.treasureButtons) do
                    btn:Hide()
                end
                -- Concentration display (only for crafting professions)
                if isGathering then
                    row.concBg:Hide()
                    row.concBar:Hide()
                    row.concText:Hide()
                    row.concBorder:Hide()
                    row.concReset:Hide()
                    row.knowledge:SetPoint("TOPLEFT", row.skill, "BOTTOMLEFT", 0, -6)
                else
                    row.concBg:Show()
                    row.concBar:Show()
                    row.concText:Show()
                    row.concBorder:Show()
                    row.concReset:Show()
                    row.knowledge:SetPoint("TOPLEFT", row.concReset, "BOTTOMLEFT", 0, -4)

                    local conc = prof.concentration or 0
                    local maxConc = prof.maxConcentration or 1000
                    if maxConc == 0 then maxConc = 1000 end
                    local concPercent = conc / maxConc
                    row.concBar:SetWidth(math.max(1, 220 * concPercent))
                    row.concText:SetText(string.format(L["LABEL_CONCENTRATION"], conc, maxConc))

                    if conc >= maxConc then
                        row.concReset:SetText("|cff00ff00" .. L["LABEL_CONC_FULL"] .. "|r")
                    else
                        local dailySeconds = lv.GetSecondsUntilDailyReset()
                        local dailyHours = math.floor(dailySeconds / 3600)
                        local dailyMins = math.floor((dailySeconds % 3600) / 60)

                        local weeklySeconds = C_DateAndTime.GetSecondsUntilWeeklyReset()
                        local weeklyDays = math.floor(weeklySeconds / 86400)
                        local weeklyHours = math.floor((weeklySeconds % 86400) / 3600)

                        local resetText = string.format("|cffffd100%s  |  %s|r",
                            string.format(L["LABEL_CONC_DAILY_RESET"], dailyHours, dailyMins),
                            string.format(L["LABEL_CONC_WEEKLY_RESET"], weeklyDays, weeklyHours))
                        row.concReset:SetText(resetText)
                    end
                end

                local kp = prof.knowledgePoints or 0
                if kp > 0 then
                    row.knowledge:SetText(string.format("|cff00ff00%s|r", string.format(L["LABEL_KNOWLEDGE_AVAILABLE"], kp)))
                else
                    row.knowledge:SetText(string.format("|cff888888%s|r", L["LABEL_NO_KNOWLEDGE"]))
                end

                local weeklyDone, weeklyTotal, catchCur, catchMax = 0, 0, 0, 0
                local treatiseDoneCount, treatiseTotalCount = 0, 0
                local artisanDoneCount, artisanTotalCount = 0, 0
                local unlockDoneCount, unlockTotalCount = 0, 0
                if lv.KnowledgeSources and lv.KnowledgeSources.CalculateWeeklySummary then
                    local s, entries = lv.KnowledgeSources.CalculateWeeklySummary(prof.skillLineID)
                    if s then
                        weeklyDone = tonumber(s.weeklyDone) or 0
                        weeklyTotal = tonumber(s.weeklyTotal) or 0
                        catchCur = tonumber(s.catchUpCurrent) or 0
                        catchMax = tonumber(s.catchUpMax) or 0
                    end
                    for _, e in ipairs(entries or {}) do
                        if e.key == "treatise" then
                            treatiseTotalCount = 1
                            treatiseDoneCount = (e.done and 1) or 0
                        elseif e.key == "artisan" then
                            artisanDoneCount = tonumber(e.doneCount) or ((e.done and 1) or 0)
                            artisanTotalCount = tonumber(e.totalCount) or ((e.questIDs and #e.questIDs) or ((e.questID and 1) or 0))
                        elseif e.key == "catchup" then
                            unlockDoneCount, unlockTotalCount = CountCompletedQuests(e.unlockQuests)
                        end
                    end
                    row._knowledgeEntries = entries
                else
                    row._knowledgeEntries = {}
                end

                row.sourcesTop:SetText(string.format("|cffffffcc%s: |cffffff00%d/%d|r   |cffffffcc%s: |cffffff00%d/%d|r",
                    (L["LABEL_WEEKLY"] ~= "LABEL_WEEKLY" and L["LABEL_WEEKLY"] or "Weekly"), weeklyDone, weeklyTotal,
                    (L["LABEL_CATCHUP"] ~= "LABEL_CATCHUP" and L["LABEL_CATCHUP"] or "Catch-up"), catchCur, catchMax))
                row.sourcesBottom:SetText(string.format("|cffffffcc%s: |cffffff00%d/%d|r   |cffffffcc%s: |cffffff00%d/%d|r   |cffffffcc%s: |cffffff00%d/%d|r",
                    (L["LABEL_TREATISE"] ~= "LABEL_TREATISE" and L["LABEL_TREATISE"] or "Treatise"), treatiseDoneCount, treatiseTotalCount,
                    (L["LABEL_ARTISAN_QUEST"] ~= "LABEL_ARTISAN_QUEST" and L["LABEL_ARTISAN_QUEST"] or "Artisan"), artisanDoneCount, artisanTotalCount,
                    (L["LABEL_UNLOCKED"] ~= "LABEL_UNLOCKED" and L["LABEL_UNLOCKED"] or "Unlocked"), unlockDoneCount, unlockTotalCount))

                row:SetScript("OnEnter", function(self)
                    local entries = self._knowledgeEntries or {}
                    if #entries == 0 then return end
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
                    GameTooltip:ClearLines()
                local tooltipTitle = self._profDisplayName or LT("TITLE_KNOWLEDGE_SOURCES", "Knowledge Sources")
                    GameTooltip:SetText(tooltipTitle, 0.4, 0.8, 1)
                    GameTooltip:SetClampedToScreen(true)

                    for _, e in ipairs(entries) do
                        if e.key == "treatise" then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine((L["LABEL_TREATISE"] ~= "LABEL_TREATISE") and L["LABEL_TREATISE"] or "Treatise", 1, 0.82, 0)
                            if e.questID then
                                local qName = GetQuestDisplayName(e.questID)
                                GameTooltip:AddLine(QuestStatusLine(e.done, qName), 1, 1, 1)
                            end
                        elseif e.key == "artisan" then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine((L["LABEL_ARTISAN_QUEST"] ~= "LABEL_ARTISAN_QUEST") and L["LABEL_ARTISAN_QUEST"] or "Artisan", 1, 0.82, 0)
                            if e.currencyInfo then
                                local cur = tonumber(e.currencyInfo.quantity) or 0
                                local max = tonumber(e.currencyInfo.maxQuantity) or 0
                                GameTooltip:AddLine(string.format("%s: %d/%d", CleanTrackerLabel(e.currencyInfo.name) or "Artisan", cur, max), 1, 1, 1)
                            end
                            if e.questIDs and #e.questIDs > 0 then
                                local doneCount = tonumber(e.doneCount) or 0
                                local totalCount = tonumber(e.totalCount) or #e.questIDs
                                GameTooltip:AddLine(string.format("%s: %d/%d", (L["LABEL_WEEKLY"] ~= "LABEL_WEEKLY") and L["LABEL_WEEKLY"] or "Weekly", doneCount, totalCount), 0.85, 0.85, 0.85)
                                for _, qid in ipairs(e.questIDs) do
                                    local done = C_QuestLog.IsQuestFlaggedCompleted(qid) and true or false
                                    local qName = GetQuestDisplayName(qid)
                                    GameTooltip:AddLine(QuestStatusLine(done, qName), 1, 1, 1)
                                end
                            end
                        elseif e.key == "catchup" and e.currencyInfo then
                            local ci = e.currencyInfo
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine(CleanTrackerLabel(ci.name) or ((L["LABEL_CATCHUP"] ~= "LABEL_CATCHUP") and L["LABEL_CATCHUP"] or "Catch-up"), 1, 0.82, 0)
                            GameTooltip:AddLine(string.format("%s: %d/%d", (L["LABEL_CATCHUP"] ~= "LABEL_CATCHUP") and L["LABEL_CATCHUP"] or "Catch-up", tonumber(ci.quantity) or 0, tonumber(ci.maxQuantity) or 0), 1, 1, 1)
                            if e.unlockQuests and #e.unlockQuests > 0 then
                                GameTooltip:AddLine((L["LABEL_UNLOCK_REQUIREMENTS"] ~= "LABEL_UNLOCK_REQUIREMENTS") and L["LABEL_UNLOCK_REQUIREMENTS"] or "Unlock Requirements", 1, 0.82, 0)
                                for _, qid in ipairs(e.unlockQuests) do
                                    local done = C_QuestLog.IsQuestFlaggedCompleted(qid) and true or false
                                    local qName = GetQuestDisplayName(qid)
                                    GameTooltip:AddLine(QuestStatusLine(done, qName), 1, 1, 1)
                                end
                            end
                        end
                    end
                    GameTooltip:Show()
                end)
            else
                -- Treasures tab
                row:SetScript("OnEnter", nil)
                row.concBg:Hide()
                row.concBar:Hide()
                row.concText:Hide()
                row.concBorder:Hide()
                row.concReset:Hide()
                row.knowledge:Hide()
                row.sourcesTop:Hide()
                row.sourcesBottom:Hide()
                row.treasureHint:Hide()
                row.uniqueHeader:Show()
                row.weeklyHeader:Show()

                local tData = MIDNIGHT_TREASURE_QUESTS[prof.skillLineID]
                local uniqueDone, uniqueTotal = CountCompletedQuestsForCharacter(charKey, prof, tData and tData.unique or nil)
                local weeklyDoneCount, weeklyTotalCount = CountCompletedQuestsForCharacter(charKey, prof, tData and tData.weekly or nil)
                row.skill:SetText("")
                row.uniqueHeader:SetText(string.format("|cffffffcc%s: |cffffff00%d/%d|r", LT("LABEL_UNIQUE_TREASURES", "Unique Treasures"), uniqueDone, uniqueTotal))
                row.weeklyHeader:SetText(string.format("|cffffffcc%s: |cffffff00%d/%d|r", LT("LABEL_WEEKLY_TREASURES", "Weekly Treasures"), weeklyDoneCount, weeklyTotalCount))
                row._treasureData = tData

                for _, btn in ipairs(row.treasureButtons) do
                    btn:Hide()
                    btn:SetScript("OnClick", nil)
                    btn:SetScript("OnEnter", nil)
                    btn:SetScript("OnLeave", nil)
                end

                local function ConfigureTreasureButton(btn, questID, clickable)
                    local done = IsQuestDoneForCharacter(charKey, prof, questID)
                    local label = GetQuestDisplayName(questID)
                    if label and label:match("^Quest%s+%d+") then
                        requestedTreasureData = true
                    end
                    local color = done and "|cff00ff00" or "|cffff5555"
                    btn.text:SetText(color .. label .. "|r")
                    btn:Show()
                    btn:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
                        GameTooltip:ClearLines()
                        GameTooltip:SetText(label, 0.4, 0.8, 1)
                        if TREASURE_WAYPOINT_BY_QUEST[questID] then
                            local wp = TREASURE_WAYPOINT_BY_QUEST[questID]
                            local zoneName = GetTreasureZoneName(questID)
                            if zoneName then
                                GameTooltip:AddLine(string.format("%s: %s", (L["LABEL_ZONE"] ~= "LABEL_ZONE") and L["LABEL_ZONE"] or "Zone", zoneName), 1, 1, 1)
                            end
                            GameTooltip:AddLine(string.format("%s: %.1f / %.1f", (L["LABEL_COORDINATES"] ~= "LABEL_COORDINATES") and L["LABEL_COORDINATES"] or "Coordinates", wp.x * 100, wp.y * 100), 1, 1, 1)
                            if wp.note and wp.note ~= "" then
                                GameTooltip:AddLine(wp.note, 0.85, 0.85, 0.85, true)
                            end
                            if HasTomTom() then
                                GameTooltip:AddLine((L["TOOLTIP_TREASURE_SET_WAYPOINT"] ~= "TOOLTIP_TREASURE_SET_WAYPOINT") and L["TOOLTIP_TREASURE_SET_WAYPOINT"] or "Click to place a TomTom waypoint", 0.2, 1, 0.2)
                            elseif CanUseBlizzardWaypoint() then
                                GameTooltip:AddLine((L["TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT"] ~= "TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT") and L["TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT"] or "Click to place a map waypoint", 0.2, 1, 0.2)
                            else
                                GameTooltip:AddLine((L["MSG_TOMTOM_NOT_DETECTED"] ~= "MSG_TOMTOM_NOT_DETECTED") and L["MSG_TOMTOM_NOT_DETECTED"] or "TomTom not detected.", 1, 0.2, 0.2)
                            end
                        else
                            GameTooltip:AddLine((L["TOOLTIP_TREASURE_NO_FIXED_LOCATION"] ~= "TOOLTIP_TREASURE_NO_FIXED_LOCATION") and L["TOOLTIP_TREASURE_NO_FIXED_LOCATION"] or "No fixed location for this treasure", 1, 0.82, 0)
                        end
                        GameTooltip:Show()
                    end)
                    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                    if clickable and TREASURE_WAYPOINT_BY_QUEST[questID] then
                        btn:SetScript("OnClick", function()
                            SetTreasureWaypoint(questID, label)
                        end)
                    end
                end

                local buttonIndex = 1
                for _, qid in ipairs(tData and tData.unique or {}) do
                    if row.treasureButtons[buttonIndex] then
                        ConfigureTreasureButton(row.treasureButtons[buttonIndex], qid, true)
                        buttonIndex = buttonIndex + 1
                    end
                end
                buttonIndex = 9
                for _, qid in ipairs(tData and tData.weekly or {}) do
                    if row.treasureButtons[buttonIndex] then
                        ConfigureTreasureButton(row.treasureButtons[buttonIndex], qid, false)
                        buttonIndex = buttonIndex + 1
                    end
                end
            end

            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            row:Show()
            if currentProfTab == "treasures" then
                row:SetHeight(lv.Layout.professionTreasureRowHeight or 206)
                yOffset = yOffset - (lv.Layout.professionTreasureRowSpacing or 214)
            else
                row:SetHeight(124)
                row.knowledge:Show()
                row.sourcesTop:Show()
                row.sourcesBottom:Show()
                row.treasureHint:Hide()
                row.uniqueHeader:Hide()
                row.weeklyHeader:Hide()
                for _, btn in ipairs(row.treasureButtons) do
                    btn:Hide()
                end
                yOffset = yOffset - 132
            end
        end

        LVProfessionWindow:SetHeight(math.abs(yOffset) + 58)

        if currentProfTab == "treasures" and requestedTreasureData and not pendingTreasureRefresh then
            C_Timer.After(0.8, function()
                if currentProfChar == charKey and LVProfessionWindow:IsShown() and currentProfTab == "treasures" then
                    lv.ShowProfessionWindow(charKey, true)
                end
            end)
        end
    end

    LVProfessionWindow:Show()
end

-- 4. EVENTS - Update profession data periodically
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

-- Retry scan with increasing delays if initial scan fails
local function ScanWithRetry()
    lv.ScanProfessionDetails()

    -- Check if we got data, if not retry after delays
    local name = lv.PLAYER_KEY or (UnitName("player") .. "-" .. GetRealmName())
    local db = LiteVaultDB and LiteVaultDB[name]
    if db and (not db.professionDetails or #db.professionDetails == 0) then
        -- Retry at 5 seconds
        C_Timer.After(3, function()
            lv.ScanProfessionDetails()
            -- Check again and retry at 10 seconds if still empty
            local db2 = LiteVaultDB and LiteVaultDB[name]
            if db2 and (not db2.professionDetails or #db2.professionDetails == 0) then
                C_Timer.After(5, lv.ScanProfessionDetails)
            end
        end)
    end
end

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        lv.LoadCachedSkillLines()
        C_Timer.After(2, ScanWithRetry)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, ScanWithRetry)
    elseif event == "TRADE_SKILL_SHOW" then
        -- Capture the child profession info when profession window opens
        C_Timer.After(0.1, function()
            lv.CaptureChildProfessionInfo()
            lv.ScanProfessionDetails()
        end)
    elseif event == "SKILL_LINES_CHANGED" or event == "TRADE_SKILL_LIST_UPDATE" or event == "TRADE_SKILL_CLOSE" then
        lv.ScanProfessionDetails()
        if currentProfChar and LVProfessionWindow:IsShown() and currentProfTab == "sources" then
            lv.ShowProfessionWindow(currentProfChar, true)
        end
    elseif event == "PLAYER_LOGOUT" then
        -- Ensure data is captured before logout
        lv.ScanProfessionDetails()
    end
end)

profGlyphsTabBtn:Hide()
profGlyphsTabBtn:EnableMouse(false)



