local addonName, IVSP = ...
local L = IVSP.L

local data = {
    -- 250 - Death Knight: Blood -- https://www.icy-veins.com/wow/blood-death-knight-pve-tank-stat-priority
    [250] = {
        {"Item Level > Critical Strike = Versatility = Mastery > Haste", "Deathbringer"},
        {"Item Level > Haste > Critical Strike = Versatility = Mastery", "San'layn"},
    },
    -- 251 - Death Knight: Frost -- https://www.icy-veins.com/wow/frost-death-knight-pve-dps-stat-priority
    [251] = {
        {"Critical Strike > Mastery > Haste > Versatility"},
    },
    -- 252 - Death Knight: Unholy -- https://www.icy-veins.com/wow/unholy-death-knight-pve-dps-stat-priority
    [252] = {
        {"Haste > Mastery > Critical Strike > Versatility"},
    },

    -- 577 - Demon Hunter: Havoc -- https://www.icy-veins.com/wow/havoc-demon-hunter-pve-dps-stat-priority
    [577] = {
        {"Critical Strike > Mastery > Haste > Versatility > Agility", "Aldrachi"},
        {"Mastery = Critical Strike > Haste > Versatility > Agility", "Fel-Scarred"},
    },
    -- 581 - Demon Hunter: Vengeance -- https://www.icy-veins.com/wow/vengeance-demon-hunter-pve-tank-stat-priority
    [581] = {
        {"Agility > Haste = Critical Strike > Versatility > Mastery"},
    },

    -- 102 - Druid: Balance -- https://www.icy-veins.com/wow/balance-druid-pve-dps-stat-priority
    [102] = {
        {"Intellect > Mastery > Haste > Versatility > Critical Strike"},
    },
    -- 103 - Druid: Feral -- https://www.icy-veins.com/wow/feral-druid-pve-dps-stat-priority
    [103] = {
        {"Critical Strike = Mastery > Haste = Versatility > Agility", "Single-Target"},
        {"Critical Strike = Mastery > Versatility > Haste > Agility", "Multi-Target"},
    },
    -- 104 - Druid: Guardian -- https://www.icy-veins.com/wow/guardian-druid-pve-tank-stat-priority
    [104] = {
        {"Agility > Haste > Versatility > Mastery > Critical Strike"},
    },
    -- Druid: Restoration -- https://www.icy-veins.com/wow/restoration-druid-pve-healing-stat-priority
    [105] = {
        {"Intellect > Haste = Mastery > Versatility > Critical Strike", "General Healing"},
        {"Intellect > Haste > Versatility > Critical Strike > Mastery", "Dungeon Damage Dealing"},
    },

    -- Evoker: Devastation -- https://www.icy-veins.com/wow/devastation-evoker-pve-dps-stat-priority
    [1467] = {
        {"Intellect > Haste > Critical Strike > Mastery > Versatility"},
    },
    -- Evoker: Preservation -- https://www.icy-veins.com/wow/preservation-evoker-pve-healing-stat-priority
    [1468] = {
        {"Intellect > Mastery > Critical Strike > Haste > Versatility", "Raiding"},
        {"Intellect > Critical Strike > Haste > Versatility > Mastery", "Mythic+"},
    },
    -- Evoker: Augmentation -- https://www.icy-veins.com/wow/augmentation-evoker-pve-dps-stat-priority
    [1473] = {
        {"Intellect > Mastery > Critical Strike > Haste > Versatility", "Chronowarden"},
        {"Intellect > Critical Strike > Haste > Mastery > Versatility", "Scalecommander"},
    },

    -- 253 - Hunter: Beast Mastery -- https://www.icy-veins.com/wow/beast-mastery-hunter-pve-dps-stat-priority
    [253] = {
        {"Agility > Haste (40%) > Mastery = Critical Strike > Haste (>40%) > Versatility", "Pack Leader (ST)"},
        {"Agility > Haste (40%) > Critical Strike > Haste (>40%) > Mastery > Versatility", "Pack Leader (AoE)"},
        {"Agility > Critical Strike = Haste > Versatility > Mastery", "Dark Ranger (ST)"},
        {"Agility > Critical Strike = Haste > Mastery > Versatility", "Dark Ranger (AoE)"},
    },
    -- 254 - Hunter: Marksmanship -- https://www.icy-veins.com/wow/marksmanship-hunter-pve-dps-stat-priority
    [254] = {
        {"Weapon Damage > Critical Strike > Mastery > Versatility > Haste", "Single Target"},
        {"Weapon Damage > Critical Strike > Mastery > Versatility > Haste", "Sentinel (AoE)"},
        {"Weapon Damage > Critical Strike > Haste = Mastery > Versatility", "Dark Ranger (AoE)"},
    },
    -- 255 - Hunter: Survival -- https://www.icy-veins.com/wow/survival-hunter-pve-dps-stat-priority
    [255] = {
        {"Agility > Mastery > Haste > Critical Strike > Versatility", "Pack Leader"},
        {"Agility > Mastery > Critical Strike > Haste > Versatility", "Sentinel (ST)"},
        {"Agility > Mastery > Haste > Critical Strike > Versatility", "Sentinel (AoE)"},
    },

    -- 62 - Mage: Arcane -- https://www.icy-veins.com/wow/arcane-mage-pve-dps-stat-priority
    [62] = {
        {"Intellect > Haste > Versatility > Mastery > Critical Strike"},
    },
    -- 63 - Mage: Fire -- https://www.icy-veins.com/wow/fire-mage-pve-dps-stat-priority
    [63] = {
        {"Intellect > Haste >> Mastery > Versatility > Critical Strike"},
    },
    -- 64 - Mage: Frost -- https://www.icy-veins.com/wow/frost-mage-pve-dps-stat-priority
    [64] = {
        {"Intellect > Haste > Critical Strike (33.34%) > Mastery > Versatility > Critical Strike (>33.34%)"},
    },

    -- 268 - Monk: Brewmaster -- https://www.icy-veins.com/wow/brewmaster-monk-pve-tank-stat-priority
    [268] = {
        {"Agility > Versatility = Mastery = Critical Strike > Haste", "Defensive"},
        {"Agility > Versatility = Critical Strike > Mastery > Haste", "Offensive"},
    },
    -- 269 - Monk: Windwalker -- https://www.icy-veins.com/wow/windwalker-monk-pve-dps-stat-priority
    [269] = {
        {"Weapon Damage > Agility > Mastery = Haste > Versatility = Critical Strike"},
    },
    -- 270 - Monk: Mistweaver -- https://www.icy-veins.com/wow/mistweaver-monk-pve-healing-stat-priority
    [270] = {
        {"Intellect > Haste > Critical Strike > Versatility = Mastery", "Raiding"},
        {"Intellect > Haste > Critical Strike >= Versatility > Mastery", "Mythic+"},
    },

    -- 65 - Paladin: Holy -- https://www.icy-veins.com/wow/holy-paladin-pve-healing-stat-priority
    [65] = {
        {"Intellect > Haste > Mastery > Critical Strike > Versatility", "Raiding"},
        {"Intellect > Critical Strike > Haste > Mastery > Versatility", "Raiding - Avenging Crusade"},
        {"Intellect > Haste > Versatility > Critical Strike > Mastery", "Mythic+"},
    },
    -- 66 - Paladin: Protection -- https://www.icy-veins.com/wow/protection-paladin-pve-tank-stat-priority
    [66] = {
        {"Strength > Haste > Mastery > Versatility = Critical Strike"},
    },
    -- 70 - Paladin: Retribution -- https://www.icy-veins.com/wow/retribution-paladin-pve-dps-stat-priority
    [70] = {
        {"Strength > Mastery = Critical Strike > Haste > Versatility"},
    },

    -- 256 - Priest: Discipline -- https://www.icy-veins.com/wow/discipline-priest-pve-healing-stat-priority
    [256] = {
        {"Intellect > Haste > Mastery > Critical Strike > Versatility", "Voidweaver"},
        {"Intellect > Haste (20%) > Critical Strike = Mastery > Haste (>20%) > Versatility", "Oracle"},
    },
    -- 257 - Priest: Holy -- https://www.icy-veins.com/wow/holy-priest-pve-healing-stat-priority
    [257] = {
        {"Intellect > Critical Strike = Mastery > Versatility >= Haste", "Raiding"},
        {"Intellect > Critical Strike = Haste > Versatility > Mastery", "Mythic+"},
    },
    -- 258 - Priest: Shadow -- https://www.icy-veins.com/wow/shadow-priest-pve-dps-stat-priority
    [258] = {
        {"Intellect > Mastery > Haste > Critical Strike > Versatility", "Single-Target"},
        {"Intellect > Haste > Mastery > Critical Strike > Versatility", "Multi-Target"},
    },

    -- 259 - Rogue: Assassination -- https://www.icy-veins.com/wow/assassination-rogue-pve-dps-stat-priority
    [259] = {
        {"Agility > Critical Strike > Mastery > Haste > Versatility"},
    },
    -- 260 - Rogue: Outlaw -- https://www.icy-veins.com/wow/outlaw-rogue-pve-dps-stat-priority
    [260] = {
        {"Agility > Versatility > Haste > Critical Strike > Mastery"},
    },
    -- 261 - Rogue: Subtlety -- https://www.icy-veins.com/wow/subtlety-rogue-pve-dps-stat-priority
    [261] = {
        {"Agility > Mastery > Versatility > Critical Strike > Haste"},
    },

    -- 262 - Shaman: Elemental -- https://www.icy-veins.com/wow/elemental-shaman-pve-dps-stat-priority
    [262] = {
        {"Intellect > Mastery > Haste = Versatility > Critical Strike"},
    },
    -- 263 - Shaman: Enhancement -- https://www.icy-veins.com/wow/enhancement-shaman-pve-dps-stat-priority
    [263] = {
        {"Haste > Mastery > Critical Strike > Versatility > Agility", "Stormbringer"},
        {"Mastery > Haste > Critical Strike > Versatility > Agility", "Totemic"},
    },
    -- 264 - Shaman: Restoration -- https://www.icy-veins.com/wow/restoration-shaman-pve-healing-stat-priority
    [264] = {
        {"Intellect > Critical Strike > Versatility > Haste = Mastery", "General"},
        {"Intellect > Haste = Critical Strike > Versatility > Mastery", "Farseer with Whispering Waves"},
    },

    -- 265 - Warlock: Affliction -- https://www.icy-veins.com/wow/affliction-warlock-pve-dps-stat-priority
    [265] = {
        {"Intellect > Mastery = Critical Strike > Haste > Versatility"},
    },
    -- 266 - Warlock: Demonology -- https://www.icy-veins.com/wow/demonology-warlock-pve-dps-stat-priority
    [266] = {
        {"Intellect > Haste = Critical Strike > Mastery > Versatility"},
    },
    -- 267 - Warlock: Destruction -- https://www.icy-veins.com/wow/destruction-warlock-pve-dps-stat-priority
    [267] = {
        {"Haste = Critical Strike > Intellect > Mastery > Versatility"},
    },

    -- 71 - Warrior: Arms -- https://www.icy-veins.com/wow/arms-warrior-pve-dps-stat-priority
    [71] = {
        {"Strength > Critical Strike > Haste > Mastery > Versatility"},
    },
    -- 72 - Warrior: Fury -- https://www.icy-veins.com/wow/fury-warrior-pve-dps-stat-priority
    [72] = {
        {"Strength > Mastery > Haste > Versatility > Critical Strike"},
    },
    -- 73 - Warrior: Protection -- https://www.icy-veins.com/wow/protection-warrior-pve-tank-stat-priority
    [73] = {
        {"Strength > Haste > Critical Strike = Versatility > Mastery"},
    },
}

local function LocalizeSP(text)
    -- localize
    text = string.gsub(text, "Haste", STAT_HASTE)
    text = string.gsub(text, "Critical Strike", STAT_CRITICAL_STRIKE)
    text = string.gsub(text, "Mastery", STAT_MASTERY)
    text = string.gsub(text, "Versatility", STAT_VERSATILITY)
    text = string.gsub(text, "Armor", STAT_ARMOR)
    text = string.gsub(text, "Stamina", ITEM_MOD_STAMINA_SHORT)
    text = string.gsub(text, "Strength", SPEC_FRAME_PRIMARY_STAT_STRENGTH)
    text = string.gsub(text, "Agility", SPEC_FRAME_PRIMARY_STAT_AGILITY)
    text = string.gsub(text, "Intellect", SPEC_FRAME_PRIMARY_STAT_INTELLECT)
    text = string.gsub(text, "Weapon Damage", DAMAGE_TOOLTIP)
    text = string.gsub(text, "Item Level", STAT_AVERAGE_ITEM_LEVEL)
    return text
end

function IVSP:GetSPText(specID)
    if not data[specID] then
        return L["No Specialization Selected"]
    end

    local selected = IVSP_Config["selected"][specID] or 1
    local text

    if selected > #data[specID] then -- isCustom
        if IVSP_Custom[specID] and IVSP_Custom[specID][selected - #data[specID]] then
            text = IVSP_Custom[specID][selected - #data[specID]][1]
        else -- data not exists
            IVSP_Config["selected"][specID] = 1
            selected = 1
        end
    else
        text = data[specID][selected][1]
    end

    text = LocalizeSP(text)
    return text
end

function IVSP:GetSPDesc(specID)
    local desc = {}
    if data[specID] then
        for _, t in pairs(data[specID]) do
            table.insert(desc, {t[2] or L["General"]})
        end
    end
    -- load custom
    if IVSP_Custom[specID] then
        for k, t in pairs(IVSP_Custom[specID]) do
            table.insert(desc, {t[2], k})
        end
    end
    return desc
end

function IVSP:GetSP(specID)
    local sp = {}

    -- load built-in
    for _, t in pairs(data[specID]) do
        if t[2] then
            tinsert(sp, t[2] .. ": " .. LocalizeSP(t[1]))
        else
            tinsert(sp, LocalizeSP(t[1]))
        end
    end

    -- load custom
    if IVSP_Custom[specID] then
        for _, t in pairs(IVSP_Custom[specID]) do
            if t[2] then
                tinsert(sp, t[2] .. ": " .. LocalizeSP(t[1]))
            else
                tinsert(sp, LocalizeSP(t[1]))
            end
        end
    end

    return sp
end