local ns = { generation = 0 }
MikSBT.CombatEngine = ns

local RestrictedValue = MikSBT.API.RestrictedValue
local LEARNED_FIELDS = { school = true, direct = true, period = true }
local MAX_LEARNED = 400

function ns.Public(value)
	if type(value) == "table" then return RestrictedValue:CanAccessTable(value) end
	return RestrictedValue:CanAccess(value)
end

function ns.Number(value, low, high)
	return ns.Public(value) and type(value) == "number" and value == value
		and value >= (low or -math.huge) and value <= (high or math.huge)
end

function ns.Text(value)
	return ns.Public(value) and type(value) == "string" and value ~= ""
end

function ns.Bool(value)
	return ns.Public(value) and type(value) == "boolean"
end

function ns.LoadLearned(saved)
	local result = { version = 1, school = {}, direct = {}, period = {} }
	if not RestrictedValue:Table(saved) or saved.version ~= 1 then return result end
	for field in pairs(LEARNED_FIELDS) do
		local count = 0
		for id, value in pairs(RestrictedValue:Table(saved[field]) or {}) do
			if ns.Number(id, 1) and ns.Number(value, 0.01, 255)
				and count < MAX_LEARNED then
				result[field][id] = value
				count = count + 1
			end
		end
	end
	return result
end

function ns.Learned(field, id)
	local values = ns.learned and ns.learned[field]
	return values and values[id]
end

function ns.Learn(field, id, value)
	if not LEARNED_FIELDS[field] or not ns.Number(id, 1)
		or not ns.Number(value, 0.01, 255) then return end
	local values = ns.learned[field]
	if values[id] == nil then
		local count = 0
		for _ in pairs(values) do count = count + 1 end
		if count >= MAX_LEARNED then return end
	end
	values[id] = value
end

function ns.EventAvailable(event)
	if C_EventUtils and C_EventUtils.IsEventValid then
		return C_EventUtils.IsEventValid(event)
	end
	-- Older clients retain the existing pipeline. These modern-only events
	-- require a positive capability check before registration.
	return event ~= "PLAYER_SWING" and event ~= "COMBAT_LOG_MESSAGE"
		and event ~= "SPELL_TEXT_UPDATE"
end

-- The imported reader schedules delayed matches. Generation guards stop a
-- disabled or previous session from writing into a newly enabled session.
ns.Timer = {}
function ns.Timer.After(delay, callback)
	local generation = ns.generation
	C_Timer.After(delay, function()
		if ns.active and generation == ns.generation then callback() end
	end)
end

function ns.Timer.NewTicker(interval, callback)
	local generation = ns.generation
	return C_Timer.NewTicker(interval, function()
		if ns.active and generation == ns.generation then callback() end
	end)
end
