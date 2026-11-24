local ns = MikSBT.CombatEngine
local casts = {}
local targets = {}
local DIRECT_WINDOW, HOT_WINDOW, MAX_CASTS = 3, 30, 64
local MEND_PET_SPELL_ID = 136
-- How far a tick can lie from where its HoT's period puts one.
local TICK_SLACK = 0.3

function ns.ResetHealing() casts, targets = {}, {} end

local function TargetlessHealRecipient(unit, spell)
	if unit ~= "player" then return end
	if spell == MEND_PET_SPELL_ID then return "pet" end
	-- Classic ranks have different IDs but share the localized spell name.
	local name = ns.SpellName(spell)
	local mendPet = ns.SpellName(MEND_PET_SPELL_ID)
	if name and mendPet and name == mendPet then return "pet" end
end

-- True only when the game shows that no friend is selected: no target, or
-- one you cannot assist.
local function NoFriendSelected()
	if type(UnitExists) ~= "function" or type(UnitCanAssist) ~= "function" then return false end
	local exists = UnitExists("target")
	if ns.Bool(exists) and not exists then return true end
	local assist = UnitCanAssist("player", "target")
	return ns.Bool(assist) and not assist
end

-- What Forever's own data says of a spell (HealSpells.lua): the facts of a
-- spell whose own effects heal, false when the table takes it not to heal,
-- nil on other clients, when the table does not know it or when it may heal
-- through an effect the table cannot see.
local function Facts(spell)
	local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
	local known = ns.HEAL_SPELLS
	if not (client and client.isForever) or not known then return end
	if ns.HEAL_SPELLS_UNKNOWN[spell] then return end
	if known[spell] then return known[spell] end
	if spell <= (ns.HEAL_SPELLS_LAST or 0) then return false end
end

-- Healing keywords across supported client locales
local HEALING_PATTERNS = {
	"heal",                    -- English: "heals", "healing"
	"restores? %d+.*health",   -- English: "restores 100 health"
	"rend %d+.*points de vie", -- French: "Rend 189 points de vie..."
	"soigne",                  -- French: "soigne la cible..."
	"guérison",                -- French: "guérison"
	"heilt",                   -- German: "Heilt das Ziel..."
	"heilung",                 -- German: "heilung"
	"sana",                    -- Spanish: "Sana al objetivo..."
	"cura",                    -- Spanish: "Cura"
}

-- Duration patterns across supported client locales
local DURATION_PATTERNS = {
	"over (%d+) s",    -- English: "over 12 sec", "over 12 s"
	"for (%d+) s",     -- English: "for 12 sec", "for 12 s"
	"en (%d+) s",      -- French: "en 12 sec", "en 12 s"
	"von (%d+) s",     -- German: "von 12 Sek", "von 12 s"
	"durante (%d+) s", -- Spanish: "durante 12 seg", "durante 12 s"
}

-- Phrases that mention healing purely as a passive stat modifier
local IGNORED_STAT_PATTERNS = {
	-- English
	"healing received",
	"healing taken",
	"healing done",
	"damage and healing",
	-- Spanish
	"sanación recibida",
	"sanacion recibida",
	"sanación realizada",
	"sanacion realizada",
	"curación recibida",
	"curacion recibida",
	"daño y sanación",
	"daño y sanacion",
	-- French
	"soins reçus",
	"soins recus",
	"soins prodigués",
	"soins prodigues",
	-- German
	"erhaltene heilung",
	"verursachte heilung",
}

-- Explicit non-healing patterns to reject across supported locales (e.g. Thorns, Mark of the Wild, Shields)
local NON_HEALING_PATTERNS = {
	-- English
	"damage",
	"armor by",
	"intellect by",
	"stamina by",
	"absorbing %d+ damage",
	-- Spanish
	"daño",
	"daÑo",
	"armadura",
	"intelecto",
	"aguante",
	"absorbe %d+.*daño",
	-- French
	"dégât",
	"dégats",
	"degat",
	"armure",
	"intelligence",
	"endurance",
	"absorbe %d+.*dégât",
	-- German
	"schaden",
	"rüstung",
	"rustung",
	"intelligenz",
	"ausdauer",
	"absorbiert %d+.*schaden",
}

-- Lua 5.1 lowercases bytes using the host locale. Fold ASCII only so
-- accented UTF-8 bytes still match the localized patterns.
local function LowerASCII(text)
	return (text:gsub("[A-Z]", function(letter)
		return string.char(letter:byte() + 32)
	end))
end

-- Checks if a spell description speaks of healing, with safe fallback for unidentifiable text.
local function Heals(spell)
	if TargetlessHealRecipient("player", spell) then return true end
	if not (C_Spell and C_Spell.GetSpellDescription) then return true end
	local ok, text = pcall(C_Spell.GetSpellDescription, spell)
	if not ok or not ns.Text(text) then return true end
	local lower = LowerASCII(text)

	-- Strip passive stat phrases before checking for healing terms
	local clean = lower
	for _, pattern in ipairs(IGNORED_STAT_PATTERNS) do
		clean = clean:gsub(pattern, "")
	end

	for _, pattern in ipairs(HEALING_PATTERNS) do
		if clean:find(pattern) then return true end
	end

	-- If it doesn't match known healing terms, only reject if explicitly a damaging/stat buff
	for _, pattern in ipairs(NON_HEALING_PATTERNS) do
		if lower:find(pattern) then return false end
	end

	-- Safe fallback: never drop casts when description cannot establish whether it heals
	return true
end

-- Extracts the spell duration in seconds from the description across locales.
local function ParseDuration(spell)
	if TargetlessHealRecipient("player", spell) then return nil end
	if not (C_Spell and C_Spell.GetSpellDescription) then return nil end
	local ok, text = pcall(C_Spell.GetSpellDescription, spell)
	if not ok or not ns.Text(text) then return nil end
	local lower = LowerASCII(text)
	for _, pattern in ipairs(DURATION_PATTERNS) do
		local secs = lower:match(pattern)
		if secs then return tonumber(secs) end
	end
end

-- Whether a cast sent at this name went to the unit. UnitName gives a unit's
-- second name apart: its realm, which the sent name carries after "-", or,
-- where units have surnames (Forever), its surname after the client's own
-- separator.
local function IsNamed(target, token)
	local ok, name, second = pcall(UnitName, token)
	if not ok or not ns.Text(name) then return false end
	if target == name then return true end
	if not ns.Text(second) then return false end
	local separators = Constants and Constants.CharacterNameSeparatorConsts
	local surname = separators and separators.CHARACTERNAME_SURNAME_SEPARATOR
	return target == name .. "-" .. second
		or (ns.Text(surname) and target == name .. surname .. second) or false
end

function ns.NoteHealTarget(unit, target, guid, spell, now)
	if (unit ~= "player" and unit ~= "pet")
		or not ns.Text(guid) or not ns.Number(spell, 1) then return end
	local recipient
	if ns.Public(target) and (target == nil or target == "") then
		-- Only a known automatic recipient can replace an absent target.
		-- Hidden targets still follow the guarded named-recipient path.
		recipient = TargetlessHealRecipient(unit, spell)
		if not recipient then return end
	else
		if not ns.Text(target) or type(UnitName) ~= "function" then return end
		for _, token in ipairs({ "player", "pet" }) do
			if IsNamed(target, token) then
				if recipient then return end
				recipient = token
			end
		end
		if not recipient then
			-- A name that is not yours, your pet's or your target's is a
			-- friend the cast went to, so it does not land on you.
			if IsNamed(target, "target") then return end
			recipient = false
		end
	end
	for index = #targets, 1, -1 do
		if now - targets[index].at > HOT_WINDOW then
			table.remove(targets, index)
		end
	end
	targets[#targets + 1] = { unit = unit, guid = guid, spell = spell,
		key = recipient, at = now }
	while #targets > MAX_CASTS do table.remove(targets, 1) end
end

function ns.NoteHealCast(unit, spell, key, now, guid)
	local helpful = C_Spell and C_Spell.IsSpellHelpful
		and C_Spell.IsSpellHelpful(spell)
	if not ns.Bool(helpful) or not helpful then return end
	local facts = Facts(spell)
	-- Do not record non-healing buffs as heals.
	if facts == false or (not facts and not Heals(spell)) then return end
	local recipient
	if ns.Text(guid) then
		for index = #targets, 1, -1 do
			local target = targets[index]
			if target.unit == unit and target.guid == guid
				and target.spell == spell then
				if now >= target.at and now - target.at <= HOT_WINDOW then
					recipient = target.key
				end
				table.remove(targets, index)
				break
			end
		end
	end
	if recipient then
		key = recipient
	elseif recipient == nil then
		-- Only a cast for which SENT gave no recipient goes by the selection;
		-- one whose SENT names a friend is never yours or your pet's.
		local selfTarget = UnitIsUnit("target", "player")
		if ns.Bool(selfTarget) and selfTarget then key = "player" end
		local petTarget = UnitIsUnit("target", "pet")
		if ns.Bool(petTarget) and petTarget then key = "pet" end
		-- With no friend selected, a heal of yours lands on you, as the game
		-- casts it, or on your pet when it heals the pet; buffs and forms are
		-- not heals and stay out.
		if facts and unit == "player" and NoFriendSelected() then
			key = facts[4] == 1 and "pet" or "player"
		end
	end
	if not key then return end
	for i = #casts, 1, -1 do
		if now - casts[i].at > HOT_WINDOW then table.remove(casts, i) end
	end
	local duration, direct, period
	if facts then
		direct, period = facts[1] == 1, facts[2] > 0 and facts[2] or nil
		duration = facts[3] > 0 and facts[3] or nil
	else
		duration = ParseDuration(spell)
	end
	casts[#casts + 1] = {
		at = now, spell = spell, key = key, duration = duration,
		known = facts and true, direct = direct, period = period,
		who = unit == "pet" and "pet" or "you",
	}
	while #casts > MAX_CASTS do table.remove(casts, 1) end
end

local function Candidate(cast, key, since, tick)
	if cast.key ~= key or since < 0 then return false end
	-- A spell the table knows heals only the way it can: at once, over time.
	if not tick then
		return since <= DIRECT_WINDOW and not cast.used
			and (not cast.known or cast.direct)
	end
	if cast.known and not cast.period then return false end
	-- A confirmed direct heal cannot claim ticks unless it has a HoT duration
	if cast.directUsed and not cast.duration then return false end
	return since <= (cast.duration and (cast.duration + 2) or HOT_WINDOW)
end

-- With several HoTs on one recipient, a confirmed tick is the one whose
-- period puts a tick of its newest cast here; a recast restarts the beat.
-- Without a period for each, or with more than one on the beat, no spell is
-- named.
local function OnBeat(key, now)
	local newest = {}
	for _, cast in ipairs(casts) do
		if Candidate(cast, key, now - cast.at, true) then
			if not cast.period then return end
			newest[cast.who .. ":" .. cast.spell] = cast
		end
	end
	local found
	for _, cast in pairs(newest) do
		local since = now - cast.at
		local beats = math.floor(since / cast.period + 0.5)
		if beats >= 1 and math.abs(since - beats * cast.period) <= TICK_SLACK then
			if found then return end
			found = cast
		end
	end
	return found
end

function ns.MatchHealing(key, now, tick, confirmed)
	if confirmed == false then return nil end
	local best, age, ambiguous, rival
	for _, cast in ipairs(casts) do
		local since = now - cast.at
		-- A heal only taken for a tick, with no combat log line saying so,
		-- may be the heal at once of a known cast not matched yet, so no
		-- spell is named for it.
		if tick and not confirmed and cast.direct and Candidate(cast, key, since, false) then
			return nil
		end
		if Candidate(cast, key, since, tick) then
			if tick and best and (best.spell ~= cast.spell or best.who ~= cast.who) then
				rival = true
			end
			if not age or since < age then
				best, age, ambiguous = cast, since, false
			elseif since == age and cast.spell ~= best.spell then
				ambiguous = true
			end
		end
	end
	if rival then
		-- A tick no combat log line confirms may be someone else's, and with
		-- several HoTs to choose from no spell is named for it.
		if not confirmed then return nil end
		best, ambiguous = OnBeat(key, now), false
	end
	if not best or ambiguous then return nil end
	best.used = true
	if not tick and confirmed then
		best.directUsed = true
	end
	return { who = best.who, spell = best.spell, tick = tick }
end

function ns.TagIncomingHeal(record, unit, now, confirmed)
	local result = ns.MatchHealing(unit, now, record.tick, confirmed)
	if not result then return end
	record.selfHeal = unit == "player" and result.who == "you"
	record.spell = result.spell
	record.icon = ns.SpellIcon(result.spell)
	record.name = ns.SpellName(result.spell)
	return result
end

function ns.RekeyHealing(old, new)
	for _, cast in ipairs(casts) do
		if cast.key == old then cast.key = new end
	end
end

function ns.ForgetHealing(key)
	for i = #casts, 1, -1 do
		if casts[i].key == key then table.remove(casts, i) end
	end
end
