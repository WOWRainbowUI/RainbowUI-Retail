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
-- English descriptions provide full facts. Chinese descriptions provide a
-- school when client-localized labels identify it unambiguously. Other
-- unknown facts retain the existing learning fallback.
-- Returns { damages = bool, school = mask or nil, direct = bool, ticks = bool,
-- low and high of the hit at once, total and duration of the damage over
-- time when given }
-- or nil when nothing can be said.

local SCHOOLS = {
    physical = 1, holy = 2, fire = 4, nature = 8,
    frost = 16, shadow = 32, arcane = 64,
    holystrike = 3, flamestrike = 5, stormstrike = 9,
    froststrike = 17, shadowstrike = 33, spellstrike = 65,
    holyfire = 6, holystorm = 10, holyfrost = 18,
    shadowholy = 34, divine = 66,
    firestorm = 12, frostfire = 20, shadowflame = 36, spellfire = 68,
    froststorm = 24, shadowstorm = 40, spellstorm = 72,
    shadowfrost = 48, spellfrost = 80, spellshadow = 96,
    elemental = 28, cosmic = 106, chromatic = 124, magic = 126, chaos = 127,
    -- Tooltip names for schools whose display constants use older names.
    radiant = 6, twilight = 34, plague = 40, astral = 72, volcanic = 5,
}
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
    -- Shots say it a third way: "increases ranged damage by 70" (Aimed
    -- Shot), "Fires several missiles, hitting 3 targets" (Multi-Shot). Read
    -- as dealing none, their hits went to the cast before them (a hunter's
    -- pet's Claw; 1.60.1.70862).
    if lower:find("ranged damage", 1, true) or lower:find("fires several missiles", 1, true) then return true end
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
    if not facts.school and facts.ticks and lower:find("bleed", 1, true) then
        facts.school = SCHOOLS.physical
    end
    -- A weapon or melee strike, or a shot, is physical and hits at once.
    if not facts.school and (lower:find("weapon damage", 1, true) or lower:find("melee damage", 1, true)
        or lower:find("ranged damage", 1, true) or lower:find("fires several missiles", 1, true)) then
        facts.school, facts.direct = 1, true
    end
    if proc then facts.procSchool = procSchool or facts.school end
    -- "282 Shadow damage over 18 sec": what the ticks add up to (0.3.9).
    local total, secs = lower:match("(%d+) %a+ damage over (%d+) sec")
    if not total then
        total, secs = lower:match("(%d+) damage over (%d+) sec")
    end
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
local function English(locale)
    return locale == "enUS" or locale == "enGB"
end

local LOCALIZED_SCHOOLS = {
    PHYSICAL = 1, HOLY = 2, FIRE = 4, NATURE = 8,
    FROST = 16, SHADOW = 32, ARCANE = 64,
}
local DAMAGE_WORDS = { zhCN = "伤害", zhTW = "傷害" }

local function LocalizedSchoolFacts(text, locale)
    local damage = DAMAGE_WORDS[locale]
    if not damage then return nil end
    local school, mentioned
    for token, mask in pairs(LOCALIZED_SCHOOLS) do
        local label = _G["STRING_SCHOOL_" .. token]
        local first = ns.Text(label) and (text:find(label .. damage, 1, true)
            or text:find(label .. " " .. damage, 1, true))
        if first then
            -- A multi-school tooltip cannot establish one damage school.
            if mentioned and mentioned ~= mask then return nil end
            mentioned = mask
            local before = text:sub(1, first - 1)
            -- Damage bonuses/resistances mention a school without dealing it.
            if before:find("%d+%s*$") or before:find("%d+%s*点%s*$")
                or before:find("%d+%s*點%s*$") then school = mask end
        end
    end
    if school then return { school = school } end
end

local function CatalogFacts(spell)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if client and client.isForever and ns.CatalogSpellFacts then
        return ns.CatalogSpellFacts(spell)
    end
end

-- The facts for a spell ID, cached; nil until its text has loaded.
function ns.SpellFacts(spell)
    if type(spell) ~= "number" then return nil end
    if cache[spell] ~= nil then return cache[spell] or nil end
    local locale = GetLocale and GetLocale()
    local facts
    if (English(locale) or DAMAGE_WORDS[locale])
        and C_Spell and type(C_Spell.GetSpellDescription) == "function" then
        local ok, text = pcall(C_Spell.GetSpellDescription, spell)
        if ok and ns.Text(text) then
            if English(locale) then facts = ns.ParseSpellDescription(text)
            else facts = LocalizedSchoolFacts(text, locale) end
        elseif type(C_Spell.RequestLoadSpellData) == "function" then
            C_Spell.RequestLoadSpellData(spell)
        end
    end
    local verified = CatalogFacts(spell)
    if verified then
        -- Retain optional tooltip amounts/proc hints. Verified identity fields
        -- win even when a localized description is incomplete or unavailable.
        facts = facts or {}
        for field, value in pairs(verified) do facts[field] = value end
        -- Missing identity fields are authoritative too: a direct-only spell
        -- has no periodic duration, and Shoot's school is set by its wand.
        facts.school = verified.school
        facts.period = verified.period
        facts.duration = verified.duration
    end
    -- Whether it is cast on yourself or friends (0.3.38: a resist of yours
    -- had gone to the Life Tap cast just before it). This API is locale-neutral.
    if C_Spell and type(C_Spell.IsSpellHelpful) == "function" then
        local ok, helpful = pcall(C_Spell.IsSpellHelpful, spell)
        if ok and ns.Bool(helpful) then
            if helpful and not verified then
                facts = facts or {}
                facts.damages = false
            end
            if facts and not verified then facts.helpful = helpful end
        end
    end
    if facts then cache[spell] = facts end
    return facts
end

-- A spell's text changed (SPELL_TEXT_UPDATE): read it again next time.
function ns.ForgetSpellFacts(spell)
    if type(spell) == "number" then cache[spell] = nil end
end

-- What a spell of yours can be avoided with. Only a melee strike can be
-- parried, and only a weapon attack (melee, or a hunter's shot at Auto Shot's
-- range) dodged, blocked or deflected. A magic spell or debuff is resisted,
-- immune, reflected or evaded instead: Hunter's Mark (100 yards) had been
-- taking the pet's parries and the hunter's shots' dodges.
-- Ranges come from C_Spell.GetSpellInfo; when they cannot be read, nothing is
-- ruled out, so the engine behaves as before.
local MELEE_REACH = 8
local PHYSICAL_AVOID = { DODGE = true, PARRY = true, BLOCK = true, DEFLECT = true }

local function Readable(value) return not ns.Public or ns.Public(value) end

local function MaxRange(spell)
    if not (C_Spell and C_Spell.GetSpellInfo) then return nil end
    local ok, info = pcall(C_Spell.GetSpellInfo, spell)
    if not ok or type(info) ~= "table" or not Readable(info) then return nil end
    local range = info.maxRange
    if Readable(range) and type(range) == "number" and range >= 0 then return range end
end

-- "melee", "ranged" (a weapon shot), "spell", or nil when unknown.
function ns.SpellReach(spell)
    if type(spell) ~= "number" or not (C_Spell and C_Spell.SpellHasRange) then return nil end
    local ok, hasRange = pcall(C_Spell.SpellHasRange, spell)
    if not ok or not Readable(hasRange) or hasRange ~= true then return nil end
    local range = MaxRange(spell)
    if not range then return nil end
    if range <= MELEE_REACH then return "melee" end
    local rules = ns.PlayerClassRules and ns.PlayerClassRules()
    if rules and rules.rangedAttackSpell then
        local shot = MaxRange(rules.rangedAttackSpell)
        if shot and math.abs(range - shot) < 0.5 then return "ranged" end
    end
    return "spell"
end

-- False when the spell can never have been answered with this avoid
-- ("PARRY", "DODGE", ... as UNIT_COMBAT names them); true otherwise.
function ns.SpellCanAvoid(spell, avoid)
    if not PHYSICAL_AVOID[avoid] then return true end
    local reach = ns.SpellReach(spell)
    if reach == "spell" then return false end
    if avoid == "PARRY" and reach == "ranged" then return false end
    return true
end
