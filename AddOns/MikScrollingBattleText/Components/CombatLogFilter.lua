local CombatLog = {}
CombatLog.__index = CombatLog

local RestrictedValue = MikSBT.API.RestrictedValue
local FILTER_NAME = "MSBT combat"
local COLOURS = {
	direct = { 1, 0.8, 0.3 },
	tick = { 0.8, 0.6, 1 },
	melee = { 0.9, 0.9, 0.9 },
	ranged = { 0.85, 0.7, 0.5 },
	directMiss = { 0.6, 0.65, 0.8 },
	tickMiss = { 0.65, 0.55, 0.8 },
	meleeMiss = { 0.6, 0.6, 0.6 },
	rangedMiss = { 0.65, 0.6, 0.5 },
	heal = { 0.35, 1, 0.45 }, hot = { 0.55, 0.88, 0.55 },
	shield = { 1, 0.6, 0.25 }, shieldMiss = { 0.72, 0.58, 0.45 },
	interrupt = { 1, 0.45, 0.1 }, purge = { 0.3, 0.85, 1 },
	cleanse = { 0.4, 0.95, 0.8 }, steal = { 0.6, 0.8, 1 },
	dispelFailed = { 0.55, 0.72, 0.82 }, broke = { 1, 0.35, 0.35 },
	kill = { 1, 1, 1 },
}
local EVENTS = {
	SPELL_DAMAGE = "direct", SPELL_BUILDING_DAMAGE = "direct",
	SPELL_PERIODIC_DAMAGE = "tick", SPELL_LEECH = "direct",
	SPELL_PERIODIC_LEECH = "tick", SWING_DAMAGE = "melee",
	RANGE_DAMAGE = "ranged", SPELL_MISSED = "directMiss",
	SPELL_PERIODIC_MISSED = "tickMiss", SWING_MISSED = "meleeMiss",
	RANGE_MISSED = "rangedMiss",
	SPELL_HEAL = "heal", SPELL_BUILDING_HEAL = "heal",
	SPELL_PERIODIC_HEAL = "hot", DAMAGE_SHIELD = "shield",
	DAMAGE_SHIELD_MISSED = "shieldMiss", SPELL_INTERRUPT = "interrupt",
	SPELL_DISPEL = "purge", SPELL_STOLEN = "steal",
	SPELL_DISPEL_FAILED = "dispelFailed", SPELL_AURA_BROKEN = "broke",
	SPELL_AURA_BROKEN_SPELL = "broke", PARTY_KILL = "kill",
}
local FILTER_EVENTS = {}
for event in pairs(EVENTS) do FILTER_EVENTS[event] = true end
local MISSES = {
	"ABSORB", "BLOCK", "DEFLECT", "DODGE", "EVADE", "IMMUNE",
	"MISS", "PARRY", "REFLECT", "RESIST",
}
for _, prefix in ipairs({ "SPELL", "SPELL_PERIODIC", "SWING", "RANGE", "DAMAGE_SHIELD" }) do
	local kind = EVENTS[prefix .. "_MISSED"]
	for _, miss in ipairs(MISSES) do
		EVENTS[prefix .. "_MISSED_" .. miss] = kind
	end
end
EVENTS.SPELL_DISPEL_BUFF = "purge"
EVENTS.SPELL_DISPEL_DEBUFF = "cleanse"
for _, suffix in ipairs({ "BUFF", "DEBUFF" }) do
	EVENTS["SPELL_STOLEN_" .. suffix] = "steal"
	EVENTS["SPELL_AURA_BROKEN_" .. suffix] = "broke"
	EVENTS["SPELL_AURA_BROKEN_SPELL_" .. suffix] = "broke"
end

local function SameColour(colour, rgb)
	return type(colour) == "table" and colour.r == rgb[1]
		and colour.g == rgb[2] and colour.b == rgb[3]
end

local function Copy(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, entry in pairs(value) do result[key] = Copy(entry) end
	return result
end

function CombatLog:New(config)
	return setmetatable({ config = config }, self)
end

function CombatLog:IsReady()
	local saved = RestrictedValue:Table(self.config.getSaved())
	local filters = saved and RestrictedValue:Table(saved.filters)
	local current = saved and RestrictedValue:Number(saved.currentFilter)
	local filter = filters and current and filters[current]
	if type(filter) ~= "table" or filter.name ~= FILTER_NAME then
		return false
	end
	local settings, colours = filter.settings, filter.colors
	if type(settings) ~= "table" or not settings.lineColoring
		or settings.lineColorPriority ~= 3 or settings.lineHighlighting
		or type(colours) ~= "table" then
		return false
	end
	local parts = filter.filters
	local part = type(parts) == "table" and parts[1]
	if type(part) ~= "table" or parts[2] ~= nil
		or type(part.sourceFlags) ~= "table"
		or type(part.eventList) ~= "table"
		or type(colours.eventColoring) ~= "table" then
		return false
	end
	for index in pairs(parts) do
		if index ~= 1 then return false end
	end
	if part.destFlags ~= nil and type(part.destFlags) ~= "table" then
		return false
	end
	local mine, pet = self.config.mineFlag, self.config.petFlag
	if not mine or not pet or part.sourceFlags[mine] ~= true
		or part.sourceFlags[pet] ~= true then
		return false
	end
	for flag, on in pairs(part.sourceFlags) do
		if on and flag ~= mine and flag ~= pet then return false end
	end
	for _, on in pairs(part.destFlags or {}) do
		if on then return false end
	end
	for event, kind in pairs(EVENTS) do
		if not SameColour(colours.eventColoring[event], COLOURS[kind]) then
			return false
		end
	end
	for event in pairs(FILTER_EVENTS) do
		if part.eventList[event] ~= true then return false end
	end
	for event, on in pairs(part.eventList) do
		if on and not FILTER_EVENTS[event] then return false end
	end
	return true
end

function CombatLog:Kind(r, g, b)
	r, g, b = RestrictedValue:Number(r), RestrictedValue:Number(g),
		RestrictedValue:Number(b)
	if not r or not g or not b then return nil end
	for kind, rgb in pairs(COLOURS) do
		if math.abs(r - rgb[1]) < 0.015
			and math.abs(g - rgb[2]) < 0.015
			and math.abs(b - rgb[3]) < 0.015 then
			return kind
		end
	end
end

-- Called only at PLAYER_LOGOUT. Applying tainted filter settings during a
-- session breaks Blizzard's secure processor; it must load these from disk.
function CombatLog:WriteSettings()
	local saved = RestrictedValue:Table(self.config.getSaved())
	local mine, pet = self.config.mineFlag, self.config.petFlag
	if type(saved) ~= "table" or type(saved.filters) ~= "table"
		or not mine or not pet then return false end
	local index
	for i, filter in ipairs(saved.filters) do
		if filter.name == FILTER_NAME then index = i break end
	end
	index = index or (#saved.filters + 1)
	local events, colouring = Copy(FILTER_EVENTS), {}
	for event, kind in pairs(EVENTS) do
		local rgb = COLOURS[kind]
		colouring[event] = { r = rgb[1], g = rgb[2], b = rgb[3], a = 1 }
	end
	local template = self.config.getTemplate and self.config.getTemplate()
	local filter = Copy(template or {})
	filter.name, filter.quickButtonName = FILTER_NAME, FILTER_NAME
	filter.tooltip = FILTER_NAME
	filter.hasQuickButton = true
	filter.quickButtonDisplay = { solo = true, party = true, raid = true }
	filter.settings = filter.settings or {}
	filter.settings.lineColoring = true
	filter.settings.lineColorPriority = 3
	filter.settings.lineHighlighting = false
	filter.settings.hideDebuffs = false
	filter.colors = filter.colors or {}
	filter.colors.eventColoring = colouring
	filter.colors.highlightedEvents = {}
	filter.filters = { {
		sourceFlags = { [mine] = true, [pet] = true }, eventList = events,
	} }
	saved.filters[index] = filter
	saved.currentFilter = index
	return true
end

local ENGINE_KINDS = {
	direct = { "spell", "damage", "direct" },
	tick = { "tick", "damage", "tick" },
	melee = { "swing", "damage", "swing" },
	ranged = { "shot", "damage", "shot" },
	directMiss = { "spellMiss", "miss", "direct" },
	tickMiss = { "tickMiss", "miss", "tick" },
	meleeMiss = { "swingMiss", "miss", "swing" },
	rangedMiss = { "shotMiss", "miss", "shot" },
	heal = { "heal", "heal", "direct" }, hot = { "hot", "heal", "tick" },
	shield = { "shield", "damage", "shield" },
	shieldMiss = { "shieldMiss", "miss", "shield" },
}
function CombatLog:ConfigureNamespace(ns)
	ns.LINE_KINDS = {}
	for kind in pairs(COLOURS) do
		local entry = ENGINE_KINDS[kind] or { kind }
		ns.LINE_KINDS[entry[1]] = { class = entry[2], restrict = entry[3] }
	end
	ns.LineKind = function(r, g, b)
		local kind = self:Kind(r, g, b)
		local entry = kind and ENGINE_KINDS[kind]
		return entry and entry[1] or kind
	end
	ns.LineKindsActive = function()
		local ready = self:IsReady()
		return ready, ready
	end
	ns.LineKindsReady = function() return self:IsReady() end
end

MikSBT.Components.CombatLogFilter = CombatLog
return CombatLog
