local ns = MikSBT.CombatEngine
local casts = {}
local targets = {}
local DIRECT_WINDOW, HOT_WINDOW, MAX_CASTS = 3, 30, 64
local MEND_PET_SPELL_ID = 136

function ns.ResetHealing() casts, targets = {}, {} end

local function TargetlessHealRecipient(unit, spell)
	if unit ~= "player" then return end
	if spell == MEND_PET_SPELL_ID then return "pet" end
	-- Classic ranks have different IDs but share the localized spell name.
	local name = ns.SpellName(spell)
	local mendPet = ns.SpellName(MEND_PET_SPELL_ID)
	if name and mendPet and name == mendPet then return "pet" end
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
			local ok, name, realm = pcall(UnitName, token)
			if ok and ns.Text(name) and (target == name
				or (ns.Text(realm) and target == name .. "-" .. realm)) then
				if recipient then return end
				recipient = token
			end
		end
		if not recipient then return end
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
	else
		local selfTarget = UnitIsUnit("target", "player")
		if ns.Bool(selfTarget) and selfTarget then key = "player" end
		local petTarget = UnitIsUnit("target", "pet")
		if ns.Bool(petTarget) and petTarget then key = "pet" end
	end
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
