local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

-------------------------------------------------
-- click-castings
-------------------------------------------------
local defaultSpells = {
    ["DEATHKNIGHT"] = {
        ["common"] = {
            61999, -- Raise Ally - 复活盟友
            47541, -- Death Coil - 凋零缠绕
        },
        -- 250 - Blood
        -- 251 - Frost
        -- 252 - Unholy
    },

    ["DEMONHUNTER"] = {
        -- 577 - Havoc
        -- 581 - Vengeance
    },

    ["DRUID"] = {
        ["common"] = {
            1126, -- Mark of the Wild - 野性印记
            20484, -- Rebirth - 复生
            50769, -- Revive - 起死回生
            8936, -- Regrowth - 愈合
            "774C", -- Rejuvenation - 回春术
            "102401C", -- Wild Charge - 野性冲锋
            "29166C", -- Innervate - 激活
            "48438C", -- Wild Growth - 野性成长
            "474750C", -- Symbiotic Relationship - 共生关系
        },
        -- 102 - Balance
        [102] = {
            "2782C", -- Remove Corruption - 清除腐蚀
            "305497P", -- pvp - Thorns - 荆棘术
        },
        -- 103 - Feral
        [103] = {
            "2782C", -- Remove Corruption - 清除腐蚀
            "391888S", -- Adaptive Swarm - 激变蜂群
            "305497P", -- pvp - Thorns - 荆棘术
        },
        -- 104 - Guardian
        [104] = {
            "2782C", -- Remove Corruption - 清除腐蚀
        },
        -- Restoration
        [105] = {
            212040, -- Revitalize - 新生
            88423, -- Nature's Cure - 自然之愈
            "33763S", -- Lifebloom - 生命绽放
            "102351S", -- Cenarion Ward - 塞纳里奥结界
            "50464S", -- Nourish - 滋养
            "102342S", -- Ironbark - 铁木树皮
            "203651S", -- Overgrowth - 过度生长
            "392160S", -- Invigorate - 鼓舞
            "18562S", -- Swiftmend - 迅捷治愈
            "102693H", -- Grove Guardians - 林莽卫士
            "305497P", -- pvp - Thorns - 荆棘术
            "474149P", -- pvp - Mass Blooming - 群体绽放
            "473919P", -- pvp - Blossom Burst - 绽放迸发
        },
    },

    ["EVOKER"] = {
        ["common"] = {
            364342, -- Blessing of the Bronze - 青铜龙的祝福
            361227, -- Return - 生还
            361469, -- Living Flame - 活化烈焰
            355913, -- Emerald Blossom - 翡翠之花
            "360995C", -- Verdant Embrace - 青翠之拥
            "374251C", -- Cauterizing Flame - 灼烧之焰
            "369459C", -- Source of Magic - 魔力之源
            "370665C", -- Rescue - 营救
            "406732C", -- Spatial Paradox - 空间悖论
            "378441P", -- Time Stop - 时间停止
            -- "374348C", -- Renewing Blaze - 新生光焰
            "443328H", -- Engulf -- 焚身
        },
        -- 1467 - Devastation
        [1467] = {
            "365585C", -- Expunge - 净除
        },
        -- 1468	- Preservation
        [1468] = {
            361178, -- Mass Return - 群体生还
            360823, -- Naturalize - 自然平衡
            "364343S", -- Echo - 回响
            "366155S", -- Reversion - 逆转
            "367226S", -- Spiritbloom - 精神之花
            "357170S", -- Time Dilation - 时间膨胀
        },
        -- 1473 - Augmentation
        [1473] = {
            -- "395152S", -- Ebon Might - 黑檀之力
            "365585C", -- Expunge - 净除
            "360827S", -- Blistering Scales - 炽火龙鳞
            "409311S", -- Prescience - 先知先觉
            "408233S", -- Bestow Weyrnstone - 赋予军营之石
            "412710S", -- Timelessness - 超脱时间
        }
    },

    ["HUNTER"] = {
        ["common"] = {
            "34477C", -- Misdirection - 误导
            53271, -- Master's Call - 主人的召唤
            "248518P", -- pvp - Interlope - 干涉
            "53480P", -- pvp - Roar of Sacrifice - 牺牲咆哮
        },
        -- 253 - Beast Mastery
        [253] = {
            90361, -- Spirit Mend - 灵魂治愈
        },
        -- 254 - Marksmanship
        -- 255 - Survival
        [255] = {
            "212640P", -- pvp - Mending Bandage - 治疗绷带
        },
    },

    ["MAGE"] = {
        ["common"] = {
            1459, -- Arcane Intellect - 奥术智慧
            130, -- Slow Fall - 缓落术
            "475C", -- Remove Curse - 解除诅咒
        },
        -- 62 - Arcane
        -- 63 - Fire
        -- 64 - Frost
    },

    ["MONK"] = {
        ["common"] = {
            115178, -- Resuscitate - 轮回转世
            116670, -- Vivify - 活血术
            "115175C", -- Soothing Mist - 抚慰之雾
            "115098C", -- Chi Wave - 真气波
            "116841C", -- Tiger's Lust - 迅如猛虎
        },
        -- 268 - Brewmaster
        [268] = {
            "218164C", -- Detox - 清创生血
        },
        -- 269 - Windwalker
        [269] = {
            "218164C", -- Detox - 清创生血
        },
        -- 270 - Mistweaver
        [270] = {
            212051, -- Reawaken - 死而复生
            115450, -- Detox - 清创生血
            "124682S", -- Enveloping Mist - 氤氲之雾
            "115151S", -- Renewing Mist - 复苏之雾
            "116849S", -- Life Cocoon - 作茧缚命
            "124081S", -- Zen Pulse - 禅意波
            "399491S" -- Sheilun's Gift - 神龙之赐
        },
    },

    ["PALADIN"] = {
        ["common"] = {
            7328, -- Redemption - 救赎
            391054, -- Intercession - 代祷
            19750, -- Flash of Light - 圣光闪现
            85673, -- Word of Glory - 荣耀圣令
            "633C", -- Lay on Hands - 圣疗术
            "1044C", -- Blessing of Freedom - 自由祝福
            "6940C", -- Blessing of Sacrifice - 牺牲祝福
            "1022C", -- Blessing of Protection - 保护祝福
        },
        -- 65 - Holy
        [65] = {
            212056, -- Absolution - 宽恕
            4987, -- Cleanse - 清洁术
            53563, -- Beacon of Light - 圣光道标
            "20473S", -- Holy Shock - 神圣震击
            "82326S", -- Holy Light - 圣光术
            "223306S", -- Bestow Faith -- 赋予信仰
            "114165S", -- Holy Prism - 神圣棱镜
            "183998S", -- Light of the Martyr -- 殉道者之光
            "148039S", -- Barrier of Faith - 信仰屏障
            "156910S", -- Beacon of Faith - 信仰道标
            "388007S", -- Blessing of Summer - 仲夏祝福
            "200025S", -- Beacon of Virtue -- 美德道标
            "432459H", -- Holy Bulwark - 神圣壁垒
            "156322H", -- Eternal Flame - 永恒之火
        },
        -- 66 - Protection
        [66] = {
            "213644C", -- Cleanse Toxins - 清毒术
            "204018S", -- Blessing of Spellwarding - 破咒祝福
            "228049P", -- pvp - Guardian of the Forgotten Queen - 被遗忘的女王护卫
            "432459H", -- Holy Bulwark - 神圣壁垒
        },
        -- 70 - Retribution
        [70] = {
            "213644C", -- Cleanse Toxins - 清毒术
            "210256P", -- pvp - Blessing of Sanctuary - 庇护祝福
            "156322H", -- Eternal Flame - 永恒之火
        },
    },

    ["PRIEST"] = {
        ["common"] = {
            21562, -- Power Word: Fortitude - 真言术：韧
            2006, -- Resurrection - 复活术
            1706, -- Levitate - 漂浮术
            17, -- Power Word: Shield - 真言术：盾
            2061, -- Flash Heal - 快速治疗
            2096, -- Mind Vision - 心灵视界
            "139C", -- Renew - 恢复
            "33076C", -- Prayer of Mending - 愈合祷言
            "73325C", -- Leap of Faith - 信仰飞跃
            "10060C", -- Power Infusion - 能量灌注
            "373481C", -- Power Word: Life - 真言术：命
            "108968C", -- Void Shift - 虚空转移
        },
        -- 256 - Discipline
        [256] = {
            212036, -- Mass Resurrection - 群体复活
            527, -- Purify - 纯净术
            47540, -- Penance - 苦修
            "194509S", -- Power Word: Radiance - 真言术：耀
            "33206S", -- Pain Suppression - 痛苦压制
            "47536S", -- Rapture - 全神贯注
            "314867S", -- Shadow Covenant - 暗影盟约
            -- "421453S", -- Ultimate Penitence - 终极苦修
        },
        -- 257 - Holy
        [257] = {
            212036, -- Mass Resurrection - 群体复活
            527, -- Purify - 纯净术
            2060, -- Heal - 治疗术
            "2050S", -- Holy Word: Serenity - 圣言术：静
            "596S", -- Prayer of Healing - 治疗祷言
            "47788S", -- Guardian Spirit - 守护之魂
            "204883S", -- Circle of Healing - 治疗之环
            "289666P", -- pvp - Greater Heal - 强效治疗术
            "213610P", -- pvp - Holy Ward - 神圣守卫
            "197268P", -- pvp - Ray of Hope - 希望之光
        },
        -- 258 - Shadow
        [258] = {
            "213634C", -- Purify Disease - 净化疾病
        },
    },

    ["ROGUE"] = {
        ["common"] = {
            "57934C", -- Tricks of the Trade - 嫁祸诀窍
            "36554C", -- Shadowstep - 暗影步
        },
        -- 259 - Assassination
        -- 260 - Outlaw
        -- 261 - Subtlety
    },

    ["SHAMAN"] = {
        ["common"] = {
            462854, -- Skyfury - 天怒
            2008, -- Ancestral Spirit - 先祖之魂
            8004, -- Healing Surge - 治疗之涌
            546, -- Water Walking - 水上行走
            "1064C", -- Chain Heal - 治疗链
            "974C", -- Earth Shield - 大地之盾
            "51490C", -- Thunderstorm - 雷霆风暴
        },
        -- 262 - Elemental
        [262] = {
            "51886C", -- Cleanse Spirit - 净化灵魂
        },
        -- 263 - Enhancement
        [263] = {
            "51886C", -- Cleanse Spirit - 净化灵魂
        },
        -- 264 - Restoration
        [264] = {
            212048, -- Ancestral Vision - 先祖视界
            77130, -- Purify Spirit - 净化灵魂
            "61295S", -- Riptide - 激流
            "77472S", -- Healing Wave - 治疗波
            "73685S", -- Unleash Life - 生命释放
            "428332S", -- Primordial Wave - 始源之潮
        },
    },

    ["WARLOCK"] = {
        ["common"] = {
            20707, -- Soulstone - 灵魂石
            89808, -- Singe Magic - 烧灼驱魔
            5697, -- Unending Breath - 无尽呼吸
        },
        -- 265 - Affliction
        -- 266 - Demonology
        -- 267 - Destruction
    },

    ["WARRIOR"] = {
        ["common"] = {
            "3411C", -- Intervene - 援护
        },
        -- 71 - Arms
        -- 72 - Fury
        -- 73 - Protection
        [73] = {
            "213871P", -- pvp - Bodyguard - 护卫
        },
    },
}

function F.GetClickCastingSpellList(class, spec)
    local spells = defaultSpells[class]["common"] and F.Copy(defaultSpells[class]["common"]) or {}

    -- check spec
    if spec and defaultSpells[class][spec] then
        for _, v in pairs(defaultSpells[class][spec]) do
            tinsert(spells, v)
        end
    end

    local invalid

    -- fill data
    for i, v in pairs(spells) do
        local spellId, spellType

        if type(v) == "number" then
            spellId = v
        else -- string
            spellId, spellType = strmatch(v, "(%d+)(%a)")
            spellId = tonumber(spellId)
            spellType = L[spellType]
        end

        local name, icon = F.GetSpellInfo(spellId)
        if name then
            spells[i] = {icon, name, spellType, spellId}
        else
            F.Debug("|cffff0000[INVALID]|r click-casting spell:", spellId)
            if not invalid then invalid = {} end
            tinsert(invalid, i)
        end
    end

    -- check invalid ids
    if invalid then
        for i = #invalid, 1, -1 do
            tremove(spells, invalid[i])
        end
    end

    -- texplore(spells)
    return spells
end

-------------------------------------------------
-- resurrections
-------------------------------------------------
local resurrections_for_dead = {
    -- DEATHKNIGHT
    61999, -- 复活盟友

    -- DRUID
    20484, -- 复生
    50769, -- 起死回生
    212040, -- 新生

    -- EVOKER
    361227, -- 生还
    361178, -- 群体生还

    -- MONK
    115178, -- 轮回转世
    212051, -- 死而复生

    -- PALADIN
    391054, -- 代祷
    7328, -- 救赎
    212056, -- 宽恕

    -- PRIEST
    2006, -- 复活术
    212036, -- 群体复活

    -- SHAMAN
    2008, -- 先祖之魂
    212048, -- 先祖视界

    -- WARLOCK
    20707, -- 灵魂石
}

do
    local temp = {}
    for _, id in pairs(resurrections_for_dead) do
        temp[F.GetSpellInfo(id)] = true
    end
    resurrections_for_dead = temp
end

local spell_soulstone = F.GetSpellInfo(20707)
function F.IsSoulstone(spell)
    return spell == spell_soulstone
end

function F.IsResurrectionForDead(spell)
    return resurrections_for_dead[spell]
end

local resurrection_click_castings = {
    ["DEATHKNIGHT"] = {
        {"type-altR", "spell", 61999},
    },
    ["DRUID"] = {
        {"type-altR", "spell", 20484},
        {"type-shiftR", "spell", 50769},
    },
    ["EVOKER"] = {
        {"type-shiftR", "spell", 361227},
    },
    ["MONK"] = {
        {"type-shiftR", "spell", 115178},
    },
    ["PALADIN"] = {
        {"type-altR", "spell", 391054},
        {"type-shiftR", "spell", 7328},
    },
    ["PRIEST"] = {
        {"type-shiftR", "spell", 2006},
    },
    ["SHAMAN"] = {
        {"type-shiftR", "spell", 2008},
    },
    ["WARLOCK"] = {
        {"type-altR", "spell", 20707},
    },
}

-- do
--     for class, t in pairs(resurrection_click_castings) do
--         for _, clickCasting in pairs(t) do
--             clickCasting[3] = F.GetSpellInfo(clickCasting[3])
--         end
--     end
-- end

function F.GetResurrectionClickCastings(class)
    return resurrection_click_castings[class] or {}
end

-------------------------------------------------
-- smart resurrection
-------------------------------------------------
local normalResurrection = {
    ["DRUID"] = {
        ["nospec:4"] = 50769, -- Revive - 起死回生
        ["spec:4"] = 212040, -- Revitalize - 新生
    },
    ["EVOKER"] = {
        ["nospec:2"] = 361227, -- Return - 生还
        ["spec:2"] = 361178, -- Mass Return - 群体生还
    },
    ["MONK"] = {
        ["nospec:2"] = 115178, -- Resuscitate - 轮回转世
        ["spec:2"] = 212051, -- Reawaken - 死而复生
    },
    ["PALADIN"] = {
        ["nospec:1"] = 7328, -- Redemption - 救赎
        ["spec:1"] = 212056, -- Absolution - 宽恕
    },
    ["PRIEST"] = {
        ["spec:3"] = 2006, -- Resurrection - 复活术
        ["nospec:3"] = 212036, -- Mass Resurrection - 群体复活
    },
    ["SHAMAN"] = {
        ["nospec:3"] = 2008, -- Ancestral Spirit - 先祖之魂
        ["spec:3"] = 212048, -- Ancestral Vision - 先祖视界
    },
}

do
    for class, t in pairs(normalResurrection) do
        for condition, spell in pairs(t) do
            t[condition] = F.GetSpellInfo(spell)
        end
    end
end

function F.GetNormalResurrection(class)
    return normalResurrection[class]
end

local combatResurrection = {
    ["DEATHKNIGHT"] = 61999,
    ["DRUID"] = 20484,
    ["PALADIN"] = 391054,
    ["WARLOCK"] = 20707,
}

do
    for class, spell in pairs(combatResurrection) do
        combatResurrection[class] = F.GetSpellInfo(spell)
    end
end

function F.GetCombatResurrection(class)
    return combatResurrection[class]
end