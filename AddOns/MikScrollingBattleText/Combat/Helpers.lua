-- Adapted from Forever Combat Text 0.6.8 (Tarolg, MIT).
-- See Combat/LICENSE-ForeverCombatText. MSBT uses its own presentation.
local ns = MikSBT.CombatEngine

-- The words for misses, from the game's own strings (CombatFeedback.lua's).
local WORDS = { MISS = "MISS", DODGE = "DODGE", PARRY = "PARRY", BLOCK = "BLOCK", RESIST = "RESIST", EVADE = "EVADE",
    IMMUNE = "IMMUNE", DEFLECT = "DEFLECT", ABSORB = "ABSORB", REFLECT = "REFLECT" }
local FALLBACK = { MISS = "Miss", DODGE = "Dodge", PARRY = "Parry", BLOCK = "Block", RESIST = "Resist", EVADE = "Evade",
    IMMUNE = "Immune", DEFLECT = "Deflect", ABSORB = "Absorb", REFLECT = "Reflect" }
function ns.MissWord(event)
    local global = WORDS[event] and _G[WORDS[event]]
    if ns.Text(global) then return global end
    return FALLBACK[event] or event
end

-- Icons: a spell's own, else the auto attack's or the wand's.
local AUTO_ATTACK, SHOOT = 6603, 5019
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
function ns.SpellIcon(spell)
    if ns.Text(spell) then return spell end
    if not ns.Number(spell) or not C_Spell or not C_Spell.GetSpellTexture then return nil end
    local icon = C_Spell.GetSpellTexture(spell)
    if ns.Public(icon) and icon then return icon end
    return nil
end
local function MeleeIcon(hand)
    return ns.SpellIcon(hand == "ranged" and SHOOT or AUTO_ATTACK) or FALLBACK_ICON
end
ns.MeleeIcon = MeleeIcon
-- Names (0.3.21, the user, 14 October 2026: Busy "should write the name
-- with the icon"): a spell of yours by its ID, your swings and shots by the
-- game's own names (Auto Attack, Shoot), your pet's swings by its name.
function ns.SpellName(spell)
    if not ns.Number(spell, 1) or not C_Spell or not C_Spell.GetSpellName then return nil end
    local name = C_Spell.GetSpellName(spell)
    if ns.Text(name) then return name end
    return nil
end
