local AuraTracking = {}
local RestrictedValue = MikSBT.API.RestrictedValue
local Spells = MikSBT.API.Spells
local STYLE_FIELDS = {
	"message", "colorR", "colorG", "colorB", "fontName", "fontSize",
	"fontAlpha", "outlineIndex", "scrollArea", "soundFile", "alwaysSticky",
}

local function SpellKey(value)
	local id = RestrictedValue:Number(value)
	if id and id > 0 and id <= 2147483647 and id == math.floor(id) then
		return tostring(id)
	end
end

function AuraTracking:Resolve(input)
	if type(input) ~= "string" then return end
	input = input:match("^%s*(.-)%s*$")
	if input == "" then return end
	local info = Spells:GetInfo(tonumber(input) or input)
	return info and SpellKey(info.spellID)
end

function AuraTracking:ShouldShow(rules, spellID, name)
	if type(rules) ~= "table" then return true end
	local key = SpellKey(spellID)
	if key then return rules[key] ~= false end
	name = RestrictedValue:String(name)
	if not name then return true end
	-- Combat-text fallbacks may expose a name without a spell ID.
	for id, enabled in pairs(rules) do
		if enabled == false then
			local info = Spells:GetInfo(tonumber(id))
			if info and info.name == name then return false end
		end
	end
	return true
end

function AuraTracking:FindID(rules, spellID, name)
	local key = SpellKey(spellID)
	if key then return key end
	name = RestrictedValue:String(name)
	if not name or type(rules) ~= "table" then return end
	for id in pairs(rules) do
		local info = Spells:GetInfo(tonumber(id))
		if info and info.name == name then return id end
	end
end

function AuraTracking:GetSettings(profile, id, eventKey)
	local base = profile.events[eventKey or "NOTIFICATION_BUFF"]
	local overrides = profile.auraSettings and profile.auraSettings[id]
	if not base or type(overrides) ~= "table" then return base end
	local settings = setmetatable({}, { __index = base })
	for _, field in ipairs(STYLE_FIELDS) do
		if overrides[field] ~= nil then settings[field] = overrides[field] end
	end
	return settings
end

MikSBT.Configuration.AuraTracking = AuraTracking
return AuraTracking
