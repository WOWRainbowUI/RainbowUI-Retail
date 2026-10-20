local ns = MikSBT.CombatEngine
local casts = {}
local DIRECT_WINDOW, HOT_WINDOW, MAX_CASTS = 3, 30, 64

function ns.ResetHealing() casts = {} end

function ns.NoteHealCast(unit, spell, key, now)
	local helpful = C_Spell and C_Spell.IsSpellHelpful
		and C_Spell.IsSpellHelpful(spell)
	if not ns.Bool(helpful) or not helpful then return end
	local selfTarget = UnitIsUnit("target", "player")
	if ns.Bool(selfTarget) and selfTarget then key = "player" end
	if not key then return end
	for i = #casts, 1, -1 do
		if now - casts[i].at > HOT_WINDOW then table.remove(casts, i) end
	end
	casts[#casts + 1] = {
		at = now, spell = spell, key = key,
		who = unit == "pet" and "pet" or "you",
	}
	while #casts > MAX_CASTS do table.remove(casts, 1) end
end

function ns.MatchHealing(key, now, tick, confirmed)
	if confirmed == false then return nil end
	local best, age, ambiguous
	for _, cast in ipairs(casts) do
		local since = now - cast.at
		if cast.key == key and since >= 0
			and since <= (tick and HOT_WINDOW or DIRECT_WINDOW)
			and (tick or not cast.used) then
			if not age or since < age then
				best, age, ambiguous = cast, since, false
			elseif since == age and cast.spell ~= best.spell then
				ambiguous = true
			end
		end
	end
	if not best or ambiguous then return nil end
	best.used = true
	return { who = best.who, spell = best.spell, tick = tick }
end

function ns.TagIncomingHeal(record, unit, now)
	local result = ns.MatchHealing(unit, now, record.tick, nil)
	if not result then return end
	record.selfHeal = unit == "player" and result.who == "you"
	record.spell = result.spell
	record.icon = ns.SpellIcon(result.spell)
	record.name = ns.SpellName(result.spell)
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
