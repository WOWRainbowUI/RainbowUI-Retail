--[[
	Copyright (C) 2006-2007 Nymbia
	Copyright (C) 2010-2017 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

local MODNAME = "AuraFilters"
local AuraFilters = Quartz3:NewModule(MODNAME)

----------------------------
-- Upvalues
-- GLOBALS: C_Spell C_Traits C_ClassTalents UNKNOWN CopyTable GetCursorInfo ClearCursor
-- GLOBALS: hooksecurefunc ChatEdit_GetActiveWindow GetCurrentKeyBoardFocus strtrim
local pairs, ipairs, tonumber, tostring, type, next = pairs, ipairs, tonumber, tostring, type, next
local format, tinsert, tremove, sort = string.format, table.insert, table.remove, table.sort

local pdb -- per-profile filters and section assignments
local revision = 0
local getOptions
local refreshOptions

local UNITS = { "player", "target", "focus" }
local DEFAULT_SECTIONS = { "MINE_HELPFUL", "MINE_HARMFUL" }
local PRESETS = {
	MINE_HELPFUL = { filterString = "HELPFUL|PLAYER", isHelpful = true },
	ALL_HELPFUL = { filterString = "HELPFUL", isHelpful = true },
	MINE_HOTS = { filterString = "HELPFUL|PLAYER|RAID_IN_COMBAT", isHelpful = true },
	ALL_HOTS = { filterString = "HELPFUL|RAID_IN_COMBAT", isHelpful = true },
	MINE_HARMFUL = { filterString = "HARMFUL|PLAYER", isHelpful = false },
	ALL_HARMFUL = { filterString = "HARMFUL", isHelpful = false },
}
local PRESET_ORDER = { "MINE_HELPFUL", "ALL_HELPFUL", "MINE_HOTS", "ALL_HOTS", "MINE_HARMFUL", "ALL_HARMFUL" }

-- global.filters is the pre-revision-1 store, kept as the migration source.
local defaults = {
	global = {
		filters = {},
	},
	profile = {
		filters = {},
		sections = {},
	},
}

local function bump()
	revision = revision + 1
	if refreshOptions then
		refreshOptions()
	end
	local Buff = Quartz3:GetModule("Buff", true)
	if Buff and Buff:IsEnabled() then
		Buff:ApplySettings()
	end
end

function AuraFilters:GetRevision()
	return revision
end

local function presetLabel(key)
	if key == "MINE_HELPFUL" then return L["My Buffs"]
	elseif key == "ALL_HELPFUL" then return L["All Buffs"]
	elseif key == "MINE_HOTS" then return L["My HoTs"]
	elseif key == "ALL_HOTS" then return L["All HoTs"]
	elseif key == "MINE_HARMFUL" then return L["My Debuffs"]
	elseif key == "ALL_HARMFUL" then return L["All Debuffs"]
	end
	return key:match("^custom:(.+)$") or key
end

local function sectionKeys(unit)
	local list = pdb.sections[unit]
	if list and #list > 0 then
		return list
	end
	return DEFAULT_SECTIONS
end

local function ensureList(unit)
	local list = pdb.sections[unit]
	if not list then
		list = {}
		pdb.sections[unit] = list
	end
	if #list == 0 then
		for i, key in ipairs(DEFAULT_SECTIONS) do
			list[i] = key
		end
	end
	return list
end

-- Custom filters own their spells (excluded from presets, first custom wins) and render as two glued groups since a filter string is HELPFUL xor HARMFUL.
function AuraFilters:GetUnitSections(unit)
	local keys = sectionKeys(unit)
	local resolved = {}

	local present = {}
	for _, key in ipairs(keys) do
		present[key] = true
	end

	local allCustomSpells
	for _, key in ipairs(keys) do
		local name = key:match("^custom:(.+)$")
		local filter = name and pdb.filters[name]
		if filter then
			allCustomSpells = allCustomSpells or {}
			for spellID in pairs(filter.spells) do
				allCustomSpells[spellID] = true
			end
		end
	end

	local carriedExcludes
	for _, key in ipairs(keys) do
		local name = key:match("^custom:(.+)$")
		if name then
			local filter = pdb.filters[name]
			if filter then
				local exclude = carriedExcludes and CopyTable(carriedExcludes) or nil
				resolved[#resolved + 1] = { key = key, filterString = "HELPFUL", isHelpful = true, custom = true, include = filter.spells, exclude = exclude }
				resolved[#resolved + 1] = { key = key, filterString = "HARMFUL", isHelpful = false, custom = true, include = filter.spells, exclude = exclude, glued = true }
				carriedExcludes = carriedExcludes or {}
				for spellID in pairs(filter.spells) do
					carriedExcludes[spellID] = true
				end
			end
		else
			local preset = PRESETS[key]
			if preset then
				local filterString = preset.filterString
				if (key == "ALL_HELPFUL" and present.MINE_HELPFUL) or (key == "ALL_HARMFUL" and present.MINE_HARMFUL) or (key == "ALL_HOTS" and present.MINE_HOTS) then
					filterString = filterString .. "|!PLAYER"
				end
				if (key == "MINE_HELPFUL" and present.MINE_HOTS) or (key == "ALL_HELPFUL" and present.ALL_HOTS) then
					filterString = filterString .. "|!RAID_IN_COMBAT"
				end
				resolved[#resolved + 1] = { key = key, filterString = filterString, isHelpful = preset.isHelpful, exclude = allCustomSpells }
			end
		end
	end

	return resolved, revision
end

----------------------------
-- Spell input resolution

local function resolveSpellInput(value)
	if type(value) ~= "string" or value == "" then return nil end

	local spellID = tonumber(value)
	if not spellID then
		spellID = tonumber(value:match("|Hspell:(%d+)") or "")
	end
	if not spellID then
		local entryID = tonumber(value:match("|Htalent:(%d+)") or "")
		if entryID and C_Traits and C_ClassTalents and C_ClassTalents.GetActiveConfigID then
			local configID = C_ClassTalents.GetActiveConfigID()
			if configID then
				local ok, entry = pcall(C_Traits.GetEntryInfo, configID, entryID)
				local definitionID = ok and entry and entry.definitionID
				if definitionID then
					local okDef, definition = pcall(C_Traits.GetDefinitionInfo, definitionID)
					spellID = okDef and definition and definition.spellID or nil
				end
			end
		end
	end
	if not spellID then
		local spellInfo = C_Spell.GetSpellInfo(value)
		spellID = spellInfo and spellInfo.spellID
	end

	if spellID and C_Spell.DoesSpellExist(spellID) then
		return spellID
	end
	return nil
end

----------------------------
-- Input widgets: an EditBox that also accepts spellbook drags and shift-clicked links.

local function registerSpellEditBox()
	local AceGUI = LibStub("AceGUI-3.0")
	local function Constructor()
		local widget = AceGUI:Create("EditBox")
		widget.type = "Quartz3SpellEditBox"
		local function receiveSpell()
			local kind, _, _, spellID = GetCursorInfo()
			if kind == "spell" and spellID then
				ClearCursor()
				widget:SetText(tostring(spellID))
				widget:Fire("OnEnterPressed", tostring(spellID))
			end
		end
		widget.editbox:HookScript("OnReceiveDrag", receiveSpell)
		widget.editbox:HookScript("OnMouseDown", receiveSpell)
		return widget
	end
	AceGUI:RegisterWidgetType("Quartz3SpellEditBox", Constructor, 1)
end

local function hookLinkInsertion()
	hooksecurefunc("ChatEdit_InsertLink", function(link)
		if type(link) ~= "string" then return end
		if ChatEdit_GetActiveWindow and ChatEdit_GetActiveWindow() then return end
		local focus = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
		if focus and focus.obj and focus.obj.type == "Quartz3SpellEditBox" and focus.Insert then
			focus:Insert(link)
		end
	end)
end

----------------------------
-- Options

do
	local newname
	local options

	local function spellRowName(spellID)
		return function()
			local name = C_Spell.GetSpellName(spellID)
			local icon = C_Spell.GetSpellTexture(spellID)
			return format("|T%s:14:14:0:0|t %s (#%d)", icon or "Interface\\Icons\\INV_Misc_QuestionMark", name or UNKNOWN, spellID)
		end
	end

	local function buildFilterGroup(name)
		local filter = pdb.filters[name]
		local group = {
			type = "group",
			name = name,
			args = {
				addspell = {
					type = "input",
					dialogControl = "Quartz3SpellEditBox",
					name = L["Add Spell"],
					desc = L["Enter a spell ID, a spell name, or shift-click a spell or talent to link it"],
					validate = function(info, value)
						if not resolveSpellInput(value) then
							return L["Enter a spell ID, a spell name, or shift-click a spell or talent to link it"]
						end
						return true
					end,
					get = function() return "" end,
					set = function(info, value)
						local spellID = resolveSpellInput(value)
						if spellID then
							filter.spells[spellID] = true
							bump()
						end
					end,
					order = 1,
				},
				deletefilter = {
					type = "execute",
					name = L["Delete Filter"],
					confirm = true,
					func = function()
						pdb.filters[name] = nil
						for _, unit in ipairs(UNITS) do
							local list = pdb.sections[unit]
							if list then
								for i = #list, 1, -1 do
									if list[i] == "custom:" .. name then
										tremove(list, i)
									end
								end
							end
						end
						bump()
					end,
					order = 2,
				},
			},
		}

		local sorted = {}
		for spellID in pairs(filter.spells) do
			sorted[#sorted + 1] = spellID
		end
		sort(sorted)
		for i, spellID in ipairs(sorted) do
			group.args["spell" .. i] = {
				type = "description",
				width = "double",
				fontSize = "medium",
				name = spellRowName(spellID),
				order = 10 + i,
			}
			group.args["remove" .. i] = {
				type = "execute",
				width = "half",
				name = L["Delete"],
				desc = L["Click to remove this spell"],
				func = function()
					filter.spells[spellID] = nil
					bump()
				end,
				order = 10 + i + 0.5,
			}
		end

		return group
	end

	local function buildUnitGroup(unit, unitLabel)
		local group = { type = "group", name = unitLabel, args = {} }
		local args = group.args
		local display = sectionKeys(unit)

		for i, key in ipairs(display) do
			args["sec" .. i] = {
				type = "group",
				dialogInline = true,
				name = i .. ". " .. presetLabel(key),
				order = i * 10,
				args = {
					up = {
						type = "execute",
						width = "half",
						name = L["Move Up"],
						disabled = i == 1,
						func = function()
							local list = ensureList(unit)
							list[i], list[i - 1] = list[i - 1], list[i]
							bump()
						end,
						order = 1,
					},
					down = {
						type = "execute",
						width = "half",
						name = L["Move Down"],
						disabled = i == #display,
						func = function()
							local list = ensureList(unit)
							list[i], list[i + 1] = list[i + 1], list[i]
							bump()
						end,
						order = 2,
					},
					rem = {
						type = "execute",
						width = "half",
						name = L["Remove Section"],
						func = function()
							tremove(ensureList(unit), i)
							bump()
						end,
						order = 3,
					},
				},
			}
		end

		args.addsection = {
			type = "select",
			name = L["Add Section"],
			desc = L["Select a filter or preset to add as a section"],
			get = function() return "" end,
			set = function(info, key)
				tinsert(ensureList(unit), key)
				bump()
			end,
			values = function()
				local used = {}
				for _, key in ipairs(sectionKeys(unit)) do
					used[key] = true
				end
				local values = {}
				for _, key in ipairs(PRESET_ORDER) do
					if not used[key] then
						values[key] = presetLabel(key)
					end
				end
				for name in pairs(pdb.filters) do
					local key = "custom:" .. name
					if not used[key] then
						values[key] = name
					end
				end
				return values
			end,
			order = 1000,
		}

		return group
	end

	refreshOptions = function()
		if not options then return end
		local args = options.args.main.args
		for key in pairs(args) do
			if key:find("^unit_") or key:find("^filter_") then
				args[key] = nil
			end
		end

		local unitLabels = { player = L["Player"], target = L["Target"], focus = L["Focus"] }
		for i, unit in ipairs(UNITS) do
			local group = buildUnitGroup(unit, unitLabels[unit])
			group.order = 100 + i
			args["unit_" .. unit] = group
		end

		local names = {}
		for name in pairs(pdb.filters) do
			names[#names + 1] = name
		end
		sort(names)
		for i, name in ipairs(names) do
			local group = buildFilterGroup(name)
			group.order = 200 + i
			args["filter_" .. name] = group
		end

		LibStub("AceConfigRegistry-3.0"):NotifyChange("Quartz3")
	end

	function getOptions()
		if not options then
			options = {
				type = "group",
				name = L["Aura Filters"],
				childGroups = "tab",
				order = 591,
				args = {
					overview = {
						type = "description",
						name = L["Assign aura sections (buff and debuff presets or custom filters) to each unit of the Buff module, and create your own spell filters."],
						order = 1,
					},
					main = {
						type = "group",
						name = L["Aura Filters"],
						childGroups = "tree",
						order = 10,
						args = {
							create = {
								type = "group",
								name = L["Create an Aura Filter"],
								order = 150,
								args = {
									limitations = {
										type = "description",
										name = L["Spell whitelists cannot filter debuffs on friendly units or buffs on hostile units (Blizzard restriction); those sections are hidden on such units, except spells Blizzard flags as never secret."],
										order = 1,
									},
									howto = {
										type = "description",
										name = L["Once created, add spells to the filter, then apply it by adding it as a section on the Player, Target or Focus panel."],
										order = 2,
									},
									newfiltername = {
										type = "input",
										name = L["New Filter Name"],
										desc = L["Set a name for the new filter"],
										get = function()
											return newname or ""
										end,
										set = function(info, value)
											value = strtrim(value)
											newname = value ~= "" and value or nil
										end,
										order = 10,
									},
									createfilter = {
										type = "execute",
										name = L["Create Filter"],
										func = function()
											pdb.filters[newname] = { spells = {} }
											newname = nil
											bump()
										end,
										disabled = function()
											return not newname or pdb.filters[newname] ~= nil
										end,
										order = 11,
									},
								},
							},
						},
					},
				},
			}
			refreshOptions()
		end
		return options
	end
end

----------------------------
-- Module lifecycle

function AuraFilters:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	pdb = self.db.profile

	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileUpdate")

	registerSpellEditBox()
	hookLinkInsertion()

	self:SetEnabledState(true)
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Aura Filters"])
end

function AuraFilters:OnProfileUpdate()
	pdb = self.db.profile
	bump()
end

-- Seeds a pre-revision-1 profile from the legacy account-wide store, called by the core CheckUpgrade.
function AuraFilters:MigrateLegacyFilters()
	if next(pdb.filters) ~= nil or next(self.db.global.filters) == nil then
		return
	end
	for name, filter in pairs(self.db.global.filters) do
		pdb.filters[name] = CopyTable(filter)
	end
	bump()
end
