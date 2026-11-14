local Presentation = {}
Presentation.__index = Presentation

local RestrictedValue = MikSBT.API.RestrictedValue
local HEALER_PAIR_WINDOW = 0.2
local GENERIC_SPELL_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local MISS_TYPES = {
	"MISS", "DODGE", "PARRY", "BLOCK", "RESIST", "EVADE",
	"IMMUNE", "DEFLECT", "ABSORB", "REFLECT",
}
local RESOURCE_LABELS = {
	MANA = "Mana",
	RAGE = "Rage",
	FOCUS = "Focus",
	ENERGY = "Energy",
	COMBO_POINTS = "Combo Point",
	RUNES = "Runes",
	RUNIC_POWER = "Runic Power",
	SOUL_SHARDS = "Soul Shards",
	LUNAR_POWER = "Lunar Power",
	HOLY_POWER = "Holy Power",
	ALTERNATE_POWER = "Alternate Power",
	MAELSTROM = "Maelstrom",
	CHI = "Chi",
	INSANITY = "Insanity",
	BURNING_EMBERS = "Burning Embers",
	DEMONIC_FURY = "Demonic Fury",
	ARCANE_CHARGES = "Arcane Charges",
	FURY = "Fury",
	PAIN = "Pain",
	ESSENCE = "Essence",
	RUNE_BLOOD = "Rune Blood",
	RUNE_FROST = "Rune Frost",
	RUNE_UNHOLY = "Rune Unholy",
	ALTERNATE_QUEST_POWER = "Alternate Quest Power",
	ALTERNATE_ENCOUNTER_POWER = "Alternate Encounter Power",
	ALTERNATE_MOUNT_POWER = "Alternate Mount Power",
	BALANCE = "Balance",
	HAPPINESS = "Happiness",
	SHADOW_ORBS = "Shadow Orbs",
	RUNE_CHROMATIC = "Rune Chromatic",
}

-- A pet's swing: its family's icon when the client gives one. Auto Attack's
-- icon (6603) is the player's own weapon.
local function PetIcon()
	local get = _G.GetPetIcon
	if type(get) ~= "function" then return nil end
	local ok, icon = pcall(get)
	if ok and icon and RestrictedValue:CanAccess(icon) then return icon end
	return nil
end

local function MissAction(word)
	for _, action in ipairs(MISS_TYPES) do
		if word == action or word == _G[action]
			or (type(word) == "string" and word:upper() == action) then
			return action
		end
	end
	return "MISS"
end

function Presentation:New(config)
	return setmetatable({
		config = config, batches = {}, generation = 0,
	}, self)
end

function Presentation:Reset()
	self.generation = self.generation + 1
	self.batches = {}
	self.lastIncomingHeal = nil
	self.waitingHealer = nil
end

function Presentation:Settings(key, crit)
	local events = self.config.getProfile().events
	local settings = crit and events[key .. "_CRIT"] or events[key]
	if not settings then settings = events[key] end
	if settings and not settings.disabled then return settings end
end

function Presentation:Emit(key, record, eventSettings)
	local settings = eventSettings or self:Settings(key, record.crit)
	if not settings then return end
	local icon = record.icon or (record.spell
		and self.config.getSpellTexture(record.spell))
	if record.event == "heal" and self.config.displayHeal
		and RestrictedValue:IsRestricted(record.sourceName) then
		local template = record.message or settings.message or ""
		if template:find("%n", 1, true) then
			local metadata = {}
			for field, value in pairs(record) do metadata[field] = value end
			metadata.sourceName = nil
			if RestrictedValue:IsRestricted(record.amount) then
				metadata.amount = nil
			end
			-- Keep the hidden name outside public formatting and cleanup.
			local message = self.config.formatMessage(settings, metadata,
				(template:gsub("%%n", "\002")))
			self.config.displayHeal(settings, record.amount, record.sourceName,
				icon, message)
			return
		end
	end
	if RestrictedValue:IsRestricted(record.amount) then
		local message = record.message
		if record.event == "heal" then
			-- Format public spell metadata while leaving %a for native rendering.
			local metadata = {}
			for field, value in pairs(record) do metadata[field] = value end
			metadata.amount = nil
			message = self.config.formatMessage(settings, metadata, message)
		end
		self.config.displayRestricted(settings, record.amount, icon, message)
		return
	end
	local message
	if record.event == "miss" and record.amount == nil
		and MissAction(record.missWord) == "ABSORB" then
		message = (_G.ABSORB or "Absorb") .. "!"
	else
		message = self.config.formatMessage(settings, record, record.message)
	end
	if message and message ~= "" then
		self.config.display(settings, message, icon)
	end
end

local function NativeResourceValue(value, expectedType)
	if not RestrictedValue:IsRestricted(value)
		and type(value) ~= expectedType then
		error("Native resource label selection unavailable")
	end
	return value
end

-- The hyperlink carries the conditional numeric gate in its hidden target.
-- Stripping it leaves only the selected label, without changing text colors.
local function ResourceLabelFragment(gate, label)
	local text = NativeResourceValue(C_StringUtil.TruncateWhenZero(gate), "string")
	local suffix = string.format("|h%s|h", label)
	local link = NativeResourceValue(
		C_StringUtil.WrapString(text, "|Hmsbt-resource:", suffix), "string")
	return NativeResourceValue(C_StringUtil.StripHyperlinks(link), "string")
end

local function ResourceLabel(token)
	if not RestrictedValue:IsRestricted(token) then
		return RESOURCE_LABELS[token] or token
	end
	if not C_Intl or not C_StringUtil or not C_CurveUtil
		or not Enum or not Enum.CollationStrength or not Enum.NormalizationForm
		or not Enum.CollationStrength.Identical or not Enum.NormalizationForm.Nfc
		or type(C_Intl.CompareStrings) ~= "function"
		or type(C_Intl.IsNormalized) ~= "function"
		or type(C_StringUtil.TruncateWhenZero) ~= "function"
		or type(C_StringUtil.WrapString) ~= "function"
		or type(C_StringUtil.StripHyperlinks) ~= "function"
		or type(C_CurveUtil.EvaluateColorValueFromBoolean) ~= "function" then
		return token
	end
	local ok, label = pcall(function()
		local output, unmatched = "", 1
		for candidate, text in pairs(RESOURCE_LABELS) do
			local comparison = NativeResourceValue(C_Intl.CompareStrings(
				token, candidate, Enum.CollationStrength.Identical), "number")
			local difference = NativeResourceValue(
				C_StringUtil.TruncateWhenZero(comparison), "string")
			-- Equality is empty NFC text; a mismatch retains a decomposed marker.
			local marker = NativeResourceValue(
				C_StringUtil.WrapString(difference, "e\204\129", ""), "string")
			local matches = NativeResourceValue(C_Intl.IsNormalized(
				marker, Enum.NormalizationForm.Nfc), "boolean")
			local matched = NativeResourceValue(
				C_CurveUtil.EvaluateColorValueFromBoolean(matches, 1, 0), "number")
			unmatched = NativeResourceValue(
				C_CurveUtil.EvaluateColorValueFromBoolean(matches, 0, unmatched), "number")
			output = string.format("%s%s",
				output, ResourceLabelFragment(matched, text))
		end
		return string.format("%s%s",
			output, ResourceLabelFragment(unmatched, token))
	end)
	if ok then return label end
	return token
end

local function AllowedResources()
	local configuration = MikSBT.Configuration
	local policy = configuration and configuration.ResourcePolicy
	return policy and policy:Allowed()
end

local function ResourceVisibility(rules, token, allowlist)
	local visibility = MikSBT.Configuration.AuraTracking:SecretVisibility(rules, token)
	if not visibility or not allowlist then return visibility end
	-- The existing matcher hides listed names. Invert it to show only allowed names.
	local ok, visible = pcall(function()
		local unmatched = NativeResourceValue(
			C_CurveUtil.EvaluateColorValueFromBoolean(visibility.visible, 1, 0), "number")
		local text = NativeResourceValue(C_StringUtil.TruncateWhenZero(unmatched), "string")
		local marker = NativeResourceValue(
			C_StringUtil.WrapString(text, "e\204\129", ""), "string")
		return NativeResourceValue(C_Intl.IsNormalized(
			marker, Enum.NormalizationForm.Nfc), "boolean")
	end)
	if ok then return { visible = visible } end
end

function Presentation:Resource(amount, powerToken, ignoreComboPoints)
	local settings = self:Settings("NOTIFICATION_RESOURCE_GAIN")
	if not settings then return end
	if not RestrictedValue:IsRestricted(amount) then
		local amountText = RestrictedValue:String(amount)
		local readableAmount = RestrictedValue:Number(amount) or tonumber(amountText)
		if not readableAmount or readableAmount <= 0 then return end
	end
	local exclusions = self.config.getProfile().resourceExclusions or {}
	local allowed = AllowedResources()
	if not RestrictedValue:IsRestricted(powerToken) then
		if allowed and not allowed[powerToken] then return end
		if ignoreComboPoints and powerToken == "COMBO_POINTS" then return end
		if exclusions[powerToken] == true then return end
	else
		local rules = {}
		if allowed then
			for token in pairs(allowed) do
				if exclusions[token] ~= true
					and not (ignoreComboPoints and token == "COMBO_POINTS") then
					rules["name:" .. token] = false
				end
			end
			if not next(rules) then return end
		else
			if ignoreComboPoints then rules["name:COMBO_POINTS"] = false end
			for token, excluded in pairs(exclusions) do
				if excluded == true and type(token) == "string" then
					rules["name:" .. token] = false
				end
			end
		end
		if next(rules) then
			local visibility = ResourceVisibility(rules, powerToken, allowed ~= nil)
			if allowed and not visibility then return end
			-- A hidden match can select native alpha, but cannot gate sound.
			settings = setmetatable({
				auraVisibility = visibility, soundFile = "",
			}, { __index = settings })
		end
	end
	self.config.displayResource(settings, amount, ResourceLabel(powerToken))
end

local function NativeCountMatches(left, right)
	local comparison = NativeResourceValue(C_Intl.CompareStrings(
		string.format("%d", left), string.format("%d", right),
		Enum.CollationStrength.Identical), "number")
	local difference = NativeResourceValue(
		C_StringUtil.TruncateWhenZero(comparison), "string")
	local marker = NativeResourceValue(
		C_StringUtil.WrapString(difference, "e\204\129", ""), "string")
	return NativeResourceValue(C_Intl.IsNormalized(
		marker, Enum.NormalizationForm.Nfc), "boolean")
end

local function SelectComboValue(matches, yes, no)
	return NativeResourceValue(
		C_CurveUtil.EvaluateColorValueFromBoolean(matches, yes, no), "number")
end

-- All decisions remain native when either count is hidden, including zero.
local function ComboPointDisplay(count, maximum)
	local zero = NativeCountMatches(count, 0)
	local full = NativeCountMatches(count, maximum)
	local one = NativeCountMatches(count, 1)
	local normal = SelectComboValue(zero, 0, SelectComboValue(full, 0, 1))
	local ready = SelectComboValue(zero, 0, SelectComboValue(full, 1, 0))
	return {
		normal = { visible = NativeCountMatches(normal, 1) },
		full = { visible = NativeCountMatches(ready, 1) },
		label = string.format("%s%s",
			ResourceLabelFragment(SelectComboValue(one, 1, 0), "Combo Point"),
			ResourceLabelFragment(SelectComboValue(one, 0, 1), "Combo Points")),
	}
end

function Presentation:CanTrackComboPoints()
	local ok, selected = pcall(ComboPointDisplay, 1, 5)
	return ok and type(selected) == "table"
end

local function FinishSettings(settings, visibility)
	local alert = {
		alwaysSticky = true, fontSizeScale = 2,
		colorR = 1, colorG = 0, colorB = 0,
	}
	if visibility then
		alert.auraVisibility, alert.soundFile = visibility, ""
	end
	return setmetatable(alert, { __index = settings })
end

function Presentation:ComboPoints(count, maximum)
	local settings = self:Settings("NOTIFICATION_RESOURCE_GAIN")
	local exclusions = self.config.getProfile().resourceExclusions
	local allowed = AllowedResources()
	if allowed and not allowed.COMBO_POINTS then return end
	if not settings or (exclusions and exclusions.COMBO_POINTS == true) then return end
	local publicCount = not RestrictedValue:IsRestricted(count)
	local publicMaximum = not RestrictedValue:IsRestricted(maximum)
	if publicCount and (type(count) ~= "number" or count <= 0) then return end
	if publicMaximum and (type(maximum) ~= "number" or maximum <= 0) then return end
	local finish = (MikSBT.translations or {}).CP_FULL or "Finish Him!"
	if publicCount and publicMaximum then
		if count == maximum then
			self.config.display(FinishSettings(settings), finish)
		else
			local name = count == 1 and "Combo Point" or "Combo Points"
			self.config.displayResource(settings, count, name)
		end
		return
	end
	local ok, selected = pcall(ComboPointDisplay, count, maximum)
	-- Without a native decision, do not risk showing zero or a false maximum.
	if not ok then return end
	local normal = setmetatable({
		auraVisibility = selected.normal, soundFile = "",
	}, { __index = settings })
	local sticky = FinishSettings(settings, selected.full)
	self.config.displayResource(normal, count, selected.label)
	self.config.display(sticky, finish)
end

function Presentation:RememberIncomingHeal(record)
	local now = self.config.getTime()
	record.healerTime = now
	self.lastIncomingHeal = record
	local waiting = self.waitingHealer
	self.waitingHealer = nil
	if waiting and now - waiting.at <= HEALER_PAIR_WINDOW then
		record.sourceName = waiting.name
	end
end

function Presentation:EmitIncomingHeal(key, record)
	local remaining = HEALER_PAIR_WINDOW
		- (self.config.getTime() - record.healerTime)
	local generation = self.generation
	self.config.after(math.max(0, remaining), function()
		if generation ~= self.generation then return end
		self:Emit(key, record)
	end)
end

function Presentation:Queue(key, record, incomingHeal)
	if not self.config.after then
		self:Emit(key, record)
		return
	end
	if not RestrictedValue:Number(record.amount) then
		if incomingHeal then
			local pending = {}
			for field, value in pairs(record) do pending[field] = value end
			self:RememberIncomingHeal(pending)
			self:EmitIncomingHeal(key, pending)
		else
			self:Emit(key, record)
		end
		return
	end
	local batchKey = key .. (record.crit and ":crit" or "")
		.. ":" .. tostring(record.spell or record.icon or "")
	local batch = self.batches[batchKey]
	if batch then
		batch.amount = batch.amount + record.amount
		batch.hitCount = batch.hitCount + 1
		if incomingHeal then self:RememberIncomingHeal(batch) end
		return
	end
	batch = {}
	for field, value in pairs(record) do batch[field] = value end
	batch.hitCount = 1
	if incomingHeal then self:RememberIncomingHeal(batch) end
	self.batches[batchKey] = batch
	local generation = self.generation
	local delay = self.config.delay or 0.12
	if record.event == "damage" then
		delay = self.config.damageDelay or delay
	end
	self.config.after(delay, function()
		if generation ~= self.generation then return end
		self.batches[batchKey] = nil
		if incomingHeal then
			self:EmitIncomingHeal(key, batch)
		else
			self:Emit(key, batch)
		end
	end)
end

local function EventKey(direction, record, result)
	local pet = record.pet or (result and result.who == "pet")
	local prefix = (pet and "PET_" or "") .. direction .. "_"
	local tick = record.tick or (result and result.tick)
	if record.event == "heal" then
		if direction == "INCOMING" and record.selfHeal then
			return tick and "SELF_HOT" or "SELF_HEAL"
		end
		return prefix .. (tick and "HOT" or "HEAL")
	end
	local melee = result and result.melee and result.hand ~= "ranged"
	local spell = result and not melee or (not result and record.school
		and record.school ~= 1)
	if record.event == "miss" then
		return prefix .. (spell and "SPELL_" or "") .. MissAction(record.missWord)
	end
	if tick then return prefix .. "SPELL_DOT" end
	if result and result.shield then return prefix .. "SPELL_DAMAGE_SHIELD" end
	return prefix .. (spell and "SPELL_DAMAGE" or "DAMAGE")
end

function Presentation:Out(record)
	local result = record.result
	if not result or (result.who ~= "you" and result.who ~= "pet") then return end
	if record.event == "killed" then
		self:Alert({ kind = "kill", icon = record.icon,
			victimIsPlayer = record.victimIsPlayer })
		return
	end
	local key = EventKey("OUTGOING", record, result)
	local spell = result.spell or result.procSpell
	if result.melee then spell = result.hand == "ranged" and 5019 or 6603 end
	local icon = record.icon or (spell and self.config.getSpellTexture(spell))
	if result.melee and result.who == "pet" and result.hand ~= "ranged"
		and not record.icon then
		icon = PetIcon()
	end
	if result.ambiguous or (result.proc and not spell) then
		spell, icon = nil, GENERIC_SPELL_ICON
	end
	if record.event == "damage" then
		local isSpell = not result.melee or result.hand == "ranged"
		local school = RestrictedValue:Number(record.school)
		if RestrictedValue:IsRestricted(record.amount) then
			self.config.batcher:DisplayRestricted(
				spell, record.amount, record.crit, icon, isSpell,
				result.who == "pet", result.tick, key, school)
		else
			self.config.batcher:Queue(
				spell, record.amount, record.crit, icon, isSpell,
				result.who == "pet", result.tick, key, nil, school)
		end
		return
	end
	local displayRecord = {}
	for field, value in pairs(record) do displayRecord[field] = value end
	displayRecord.spell, displayRecord.icon = spell, icon
	self:Queue(key, displayRecord)
end

function Presentation:In(record)
	if record.event ~= "damage" and record.event ~= "heal"
		and record.event ~= "miss" then return end
	self:Queue(EventKey("INCOMING", record), record,
		record.event == "heal" and not record.pet)
end

function Presentation:Aura(gained, harmful, name, icon, spellID)
	local rules = self.config.getProfile().auraTracking
	if rules and not MikSBT.Configuration.AuraTracking:ShouldShow(
		rules, spellID, name) then return end
	local key = "NOTIFICATION_" .. (harmful and "DEBUFF" or "BUFF")
		.. (gained and "" or "_FADE")
	local settings = self:Settings(key)
	if not settings then return end
	if rules then
		local tracking = MikSBT.Configuration.AuraTracking
		local id = tracking:FindID(rules, spellID, name)
		if id and rules[id] ~= nil then
			settings = tracking:GetSettings(self.config.getProfile(), id, key)
		end
	end
	if RestrictedValue:IsRestricted(name) then
		local visibility = rules and MikSBT.Configuration.AuraTracking
			:SecretVisibility(rules, name)
		if visibility then
			-- Native visibility cannot selectively suppress sound playback.
			settings = setmetatable({
				auraVisibility = visibility, soundFile = "",
			}, { __index = settings })
		end
		local message = (settings.message or "%sl"):gsub("%%sl", "%%a")
		self.config.displayRestricted(settings, name, icon, message)
	else
		self:Emit(key, { name = name, icon = icon }, settings)
	end
end

local ALERT_EVENTS = {
	interrupt = "OUTGOING_SPELL_INTERRUPT",
	dispel = "OUTGOING_DISPEL",
	broke = "NOTIFICATION_CROWD_CONTROL",
	cc = "NOTIFICATION_CROWD_CONTROL",
	proc = "NOTIFICATION_PROC",
	reactive = "NOTIFICATION_REACTIVE",
	kill = "NOTIFICATION_NPC_KILLING_BLOW",
}
function Presentation:Alert(record)
	local key = ALERT_EVENTS[record.kind]
	if record.kind == "kill" then
		local player = RestrictedValue:Boolean(record.victimIsPlayer)
		if player == true then key = "NOTIFICATION_PC_KILLING_BLOW" end
	elseif record.kind == "combat" then
		key = record.entering and "NOTIFICATION_COMBAT_ENTER"
			or "NOTIFICATION_COMBAT_LEAVE"
	end
	if not key then return end
	local displayRecord = { name = record.text, icon = record.icon }
	if record.args then
		local value = record.args[1]
		if RestrictedValue:IsRestricted(value) then
			local settings = self:Settings(key)
			if settings then
				self.config.displayRestricted(settings, value, record.icon, "%a")
			end
			return
		end
		if value ~= nil then displayRecord.name = value end
	end
	self:Emit(key, displayRecord)
end

-- Match the player's healer notice in either event order. Pet and outgoing
-- heals never consume these notices; opaque names are retained as supplied.
function Presentation:Healer(name)
	if not self.config.getTime then return end
	local now = self.config.getTime()
	local record = self.lastIncomingHeal
	if record and now - record.healerTime <= HEALER_PAIR_WINDOW then
		record.sourceName = name
	else
		self.waitingHealer = { name = name, at = now }
	end
end

MikSBT.Components.CombatPresentation = Presentation
return Presentation
