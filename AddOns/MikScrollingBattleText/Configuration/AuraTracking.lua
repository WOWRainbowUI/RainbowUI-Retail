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

local function NameKey(spellID, name)
	name = RestrictedValue:String(name)
	if not name then
		local id = SpellKey(spellID)
		local info = id and Spells:GetInfo(tonumber(id))
		name = info and info.name
	end
	if name and name ~= "" then return "name:" .. name end
end

function AuraTracking:Resolve(input)
	if type(input) ~= "string" then return end
	input = input:match("^%s*(.-)%s*$")
	if input == "" or input:find("%c") then return end
	local number = tonumber(input)
	local info = Spells:GetInfo(number or input)
	if number then return info and SpellKey(number) end
	-- A valid aura name need not be resolvable through the spellbook API.
	return NameKey(nil, info and info.name or input)
end

function AuraTracking:ShouldShow(rules, spellID, name)
	if type(rules) ~= "table" then return true end
	local key = SpellKey(spellID)
	if key and rules[key] == false then return false end
	local named = NameKey(spellID, name)
	return not named or rules[named] ~= false
end

function AuraTracking:FindID(rules, spellID, name)
	if type(rules) ~= "table" then return end
	local key = SpellKey(spellID)
	if key and rules[key] ~= nil then return key end
	local named = NameKey(spellID, name)
	if named and rules[named] ~= nil then return named end
end

local function NativeValue(value, expectedType)
	if not RestrictedValue:IsRestricted(value)
		and type(value) ~= expectedType then
		error("Native aura filtering unavailable")
	end
	return value
end

-- A zero produces empty normalized text; a nonzero value retains a
-- decomposed marker. Every derived value stays inside native helpers.
local function IsZero(value)
	local text = NativeValue(C_StringUtil.TruncateWhenZero(value), "string")
	local marker = NativeValue(
		C_StringUtil.WrapString(text, "e\204\129", ""), "string")
	return NativeValue(C_Intl.IsNormalized(
		marker, Enum.NormalizationForm.Nfc), "boolean")
end

function AuraTracking:SecretVisibility(rules, name)
	if type(rules) ~= "table" or not C_Intl or not C_StringUtil
		or not C_CurveUtil or not Enum or not Enum.CollationStrength
		or not Enum.NormalizationForm then return end
	if not Enum.CollationStrength.Identical or not Enum.NormalizationForm.Nfc
		or type(C_Intl.CompareStrings) ~= "function"
		or type(C_Intl.IsNormalized) ~= "function"
		or type(C_StringUtil.TruncateWhenZero) ~= "function"
		or type(C_StringUtil.WrapString) ~= "function"
		or type(C_CurveUtil.EvaluateColorValueFromBoolean) ~= "function" then
		return
	end
	local ok, visibility = pcall(function()
		local hidden, hasExclusions = 0, false
		for key, enabled in pairs(rules) do
			local excludedName = type(key) == "string"
				and key:match("^name:(.+)$")
			if enabled == false and excludedName then
				hasExclusions = true
				local comparison = NativeValue(C_Intl.CompareStrings(
					name, excludedName, Enum.CollationStrength.Identical), "number")
				hidden = NativeValue(C_CurveUtil.EvaluateColorValueFromBoolean(
					IsZero(comparison), 1, hidden), "number")
			end
		end
		if hasExclusions then return { visible = IsZero(hidden) } end
	end)
	if ok then return visibility end
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
