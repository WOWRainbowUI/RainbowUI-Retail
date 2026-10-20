-- Adapted from Forever Combat Text 0.6.8 (Tarolg, MIT).
-- See Combat/LICENSE-ForeverCombatText. MSBT uses its own presentation.
local ns = MikSBT.CombatEngine

-- What a spell of yours does, read from its own description
-- (C_Spell.GetSpellDescription: SecretArguments AllowedWhenTainted, plain
-- for your spells; "may be empty if spell's data isn't loaded yet",
-- SpellDocumentation). 0.3.5 (the user, 14 October 2026: "i have a Curse of
-- tongues icon doing damage"): without it the engine (Mine.lua) took the next
-- hit after any cast for that spell's, so a curse that deals no damage took
-- a DoT's tick, and one hit could teach the wrong school.
--   "causing 120 Shadow damage over 18 sec": deals damage, Shadow, ticks;
--   "causing 60 Shadow damage.": deals damage, Shadow, hits at once;
--   "Burns the enemy for 25 Fire damage and then an additional 40 Fire
--   damage over 15 sec.": both;
--   "Forces the target to speak in Demonic ...": no damage at all.
-- Only English descriptions are read; on other clients, and while a
-- description has not loaded, the engine learns as before.
-- Returns { damages = bool, school = mask or nil, direct = bool, ticks = bool,
-- low and high of the hit at once, total and duration of the damage over
-- time when given }
-- or nil when nothing can be said.

local SCHOOLS = { physical = 1, holy = 2, fire = 4, nature = 8, frost = 16, shadow = 32, arcane = 64 }
-- Words of spells that harm or drain without saying "<school> damage".
local HARM = { "health every", "from the target", "drains" }

-- Damage the spell deals: a school or an amount before "damage" ("282
-- Shadow damage", "causing 50 damage"). A word alone does not count (0.3.10:
-- Fear's "Damage caused may interrupt the effect" made it a damage spell,
-- and it took a teammate's hit in a battleground), nor healing ("Heals 66
-- damage", a bandage).
local function DealsDamage(lower)
    if lower:find("^heals") or lower:find("heals %d") or lower:find("restores %d") or lower:find("converts %d+ health") then return false end
    for word in lower:gmatch("(%a+) damage") do
        if SCHOOLS[word] then return true end
    end
    if lower:find("%d damage") then return true end
    -- Melee abilities say it another way (0.3.31): "deals weapon damage
    -- plus 85" (Mortal Strike), "increases melee damage by 138" (Heroic
    -- Strike).
    if lower:find("weapon damage", 1, true) or lower:find("melee damage", 1, true) then return true end
    for _, word in ipairs(HARM) do
        if lower:find(word, 1, true) then return true end
    end
    return false
end

-- 0.6.7 (the user, 19 October 2026): what your swings' procs come from. A
-- seal ("Only one Seal can be active", or a seal that adds to "each melee
-- attack": Righteousness, Command, Fury, Martyrdom on Forever, 1.60.1.70450)
-- or a poison that deals damage ("Coats a weapon with poison ... Nature
-- damage": Instant, Deadly; not Crippling or Mind-numbing, which deal none).
-- 0.6.8: oils ("When applied to a melee weapon it gives a 10% chance of
-- casting Frostbolt") and weapon enchants ("Permanently enchant a melee
-- weapon to often strike for 40 additional fire damage"), with the school
-- their hits are of, so each lends its icon only to hits of its school.
local BOLT_SCHOOLS = { frostbolt = 16, shadowbolt = 32, ["shadow bolt"] = 32, fireball = 4, firebolt = 4 }
local function WeaponProc(lower)
    if lower:find("only one seal", 1, true) or lower:find("each melee attack", 1, true)
        or lower:find("each of your melee attacks", 1, true) or lower:find("melee attacks to deal", 1, true) then
        return "seal"
    end
    if lower:find("coats a weapon", 1, true) and lower:find("damage", 1, true) then return "poison" end
    if lower:find("applied to a melee weapon", 1, true) and lower:find("chance of casting", 1, true) then
        for word, school in pairs(BOLT_SCHOOLS) do
            if lower:find(word, 1, true) then return "oil", school end
        end
        return "oil"
    end
    if lower:find("enchant a melee weapon", 1, true) and lower:find("damage", 1, true) then return "enchant" end
end

function ns.ParseSpellDescription(text)
    if type(text) ~= "string" or text == "" then return nil end
    local lower = text:lower()
    local harms = DealsDamage(lower)
    local proc, procSchool = WeaponProc(lower)
    -- "Converts 75 health into 75 mana" (Life Tap): a cost the game reports
    -- nowhere (0.3.19), shown from the description when you cast it.
    local cost = tonumber(lower:match("converts (%d+) health"))
    if not harms then
        return { damages = false, direct = false, ticks = false, healthCost = cost, weaponProc = proc, procSchool = procSchool }
    end
    local facts = { damages = true, direct = false, ticks = false, weaponProc = proc }
    -- Each "<word> damage": over time when " over" or "every" follows it
    -- before the next "damage" or the sentence's end.
    local at = 1
    while true do
        local first, last, word = lower:find("(%a+) damage", at)
        if not first then break end
        local rest = lower:sub(last + 1)
        local stop = math.min(rest:find("damage", 1, true) or #rest + 1, rest:find("%.") or #rest + 1)
        local after = rest:sub(1, stop - 1)
        if SCHOOLS[word] then
            facts.school = facts.school or SCHOOLS[word]
            if after:find("^ over") or after:find("every", 1, true) then
                facts.ticks = true
            else
                -- What the hit at once does before bonuses (0.3.40): "33 to
                -- 38 Frost damage", "134 Fire damage".
                if not facts.direct then
                    local before = lower:sub(1, first - 1)
                    local low, high = before:match("(%d+) to (%d+)%s*$")
                    low = tonumber(low or before:match("(%d+)%s*$"))
                    if low then facts.low, facts.high = low, tonumber(high) or low end
                end
                facts.direct = true
            end
        end
        at = last + 1
    end
    if lower:find("every %d") then facts.ticks = true end
    -- "bleed for 15 damage over 9 sec" (Rend): ticks, school not said.
    if lower:find("%d+ damage over %d") then facts.ticks = true end
    -- A weapon or melee strike is physical and hits at once.
    if not facts.school and (lower:find("weapon damage", 1, true) or lower:find("melee damage", 1, true)) then
        facts.school, facts.direct = 1, true
    end
    if proc then facts.procSchool = procSchool or facts.school end
    -- "282 Shadow damage over 18 sec": what the ticks add up to (0.3.9).
    local total, secs = lower:match("(%d+) %a+ damage over (%d+) sec")
    if total then facts.total, facts.duration = tonumber(total), tonumber(secs) end
    -- Harm with no "<school> damage" (Drain Life's "health every"): say no
    -- more than that it harms.
    if not facts.direct and not facts.ticks then facts.direct, facts.ticks = nil, nil end
    -- 0.3.49: a spell that gives you the health it takes ("Transfers 10
    -- health every 1 sec from the target to the caster"): its hits come with
    -- a heal on you of the same amount (Mine.lua, leech).
    if lower:find("to the caster", 1, true) or lower:find("transfers", 1, true) then facts.leech = true end
    return facts
end

local cache = {}
local function English()
    local locale = GetLocale and GetLocale()
    return locale == "enUS" or locale == "enGB"
end

-- The facts for a spell ID, cached; nil until its text has loaded.
function ns.SpellFacts(spell)
    if type(spell) ~= "number" then return nil end
    if cache[spell] ~= nil then return cache[spell] or nil end
    if not English() or not (C_Spell and C_Spell.GetSpellDescription) then return nil end
    local text = C_Spell.GetSpellDescription(spell)
    if not ns.Text(text) then
        if C_Spell.RequestLoadSpellData then C_Spell.RequestLoadSpellData(spell) end
        return nil
    end
    local facts = ns.ParseSpellDescription(text)
    -- Whether it is cast on yourself or friends (0.3.38: a resist of yours
    -- had gone to the Life Tap cast just before it).
    if facts and C_Spell.IsSpellHelpful then
        local helpful = C_Spell.IsSpellHelpful(spell)
        if ns.Bool(helpful) then facts.helpful = helpful end
    end
    cache[spell] = facts or false
    return facts
end

-- A spell's text changed (SPELL_TEXT_UPDATE): read it again next time.
function ns.ForgetSpellFacts(spell)
    if type(spell) == "number" then cache[spell] = nil end
end
