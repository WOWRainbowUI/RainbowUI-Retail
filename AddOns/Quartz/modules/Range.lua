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

local MODNAME = "Range"
local Range = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local Player = Quartz3:GetModule("Player")

----------------------------
-- Upvalues
local CreateFrame, UIParent = CreateFrame, UIParent
local UnitExists, UnitCanAssist, UnitCanAttack = UnitExists, UnitCanAssist, UnitCanAttack
local UnitInRange, UnitName = UnitInRange, UnitName
local unpack, select, ipairs = unpack, select, ipairs

local IsSpellInRange = C_Spell.IsSpellInRange
local IsSpellUsable = C_Spell.IsSpellUsable

----------------------------
-- Class spell table (spell IDs, locale-independent)
local classSpells = {
	friendly = {
		["PRIEST"]      = { 17, 527 },              -- PW:Shield, Purify
		["DRUID"]       = { 8936 },                  -- Regrowth
		["PALADIN"]     = { 19750 },                 -- Flash of Light
		["SHAMAN"]      = { 8004 },                  -- Healing Surge
		["WARLOCK"]     = { 5697 },                  -- Unending Breath
		-- DEATHKNIGHT: no reliable friendly range spell, falls back to UnitInRange
		["MONK"]        = { 115450 },                -- Detox
		["MAGE"]        = { 130 },                   -- Slow Fall
		["WARRIOR"]     = { 3411 },                  -- Intervene
		["EVOKER"]      = { 361469 },                -- Living Flame
	},
	hostile = {
		["DEATHKNIGHT"] = { 47541, 49576 },          -- Death Coil, Death Grip
		["DEMONHUNTER"] = { 185123 },                -- Throw Glaive
		["DRUID"]       = { 8921 },                  -- Moonfire
		["HUNTER"]      = { 193455, 19434, 193265 }, -- Cobra Shot, Aimed Shot, Hatchet Toss
		["MAGE"]        = { 116, 30451, 133 },       -- Frostbolt, Arcane Blast, Fireball
		["MONK"]        = { 115546 },                -- Provoke
		["PALADIN"]     = { 62124 },                 -- Hand of Reckoning
		["PRIEST"]      = { 585 },                   -- Smite
		["ROGUE"]       = { 185565, 185763, 114014 },-- Poisoned Knife, Pistol Shot, Shuriken Toss
		["SHAMAN"]      = { 188196 },                -- Lightning Bolt
		["WARLOCK"]     = { 686 },                   -- Shadow Bolt
		["WARRIOR"]     = { 355 },                   -- Taunt
		["EVOKER"]      = { 361469 },                -- Living Flame
	},
}

----------------------------
-- State
local playerClass = select(2, UnitClass("player"))
local rangeSpells = { friendly = nil, hostile = nil }

local f, OnUpdate, db, getOptions, castBar
local rangeOverlay, rangeCheckedFrame
local selfCast = false

local defaults = {
	profile = {
		rangecolor = { 1, 1, 1 },
	}
}

----------------------------
-- Spell cache
local function updateSpellCache()
	rangeSpells.friendly = nil
	rangeSpells.hostile = nil

	for _, category in ipairs({ "friendly", "hostile" }) do
		local spellList = classSpells[category][playerClass]
		if spellList then
			for _, spellID in ipairs(spellList) do
				if IsSpellUsable(spellID) then
					rangeSpells[category] = spellID
					break
				end
			end
		end
	end
end

----------------------------
-- Overlay setup (called once when castBar is first available)
local function setupOverlay()
	if rangeOverlay then return end

	-- Intermediate frame for UnitInRange fallback (controls checkedRange visibility)
	rangeCheckedFrame = CreateFrame("Frame", nil, castBar)
	rangeCheckedFrame:SetAllPoints(castBar:GetStatusBarTexture())
	rangeCheckedFrame:SetAlpha(1)

	-- Overlay texture colored with rangecolor (solid color, anchored to fill area)
	rangeOverlay = rangeCheckedFrame:CreateTexture(nil, "OVERLAY")
	rangeOverlay:SetAllPoints(rangeCheckedFrame)
	rangeOverlay:SetColorTexture(1, 1, 1)
	rangeOverlay:SetVertexColor(unpack(db.rangecolor))
	rangeOverlay:SetAlpha(0)
end

----------------------------
-- OnUpdate (range polling during active cast)
do
	local refreshtime = 0.25
	local sincelast = 0

	function OnUpdate(frame, elapsed)
		sincelast = sincelast + elapsed
		if sincelast < refreshtime then
			return
		end
		sincelast = 0

		-- Stop if cast bar hidden or fading out
		if not castBar:IsVisible() or Player.Bar.fadeOut then
			rangeOverlay:SetAlpha(0)
			rangeCheckedFrame:SetAlpha(1)
			f:SetScript("OnUpdate", nil)
			return
		end

		-- Determine spell based on target relationship
		local spell
		if UnitCanAssist("player", "target") then
			spell = rangeSpells.friendly
		elseif UnitCanAttack("player", "target") then
			spell = rangeSpells.hostile
		end

		if spell then
			-- C_Spell.IsSpellInRange returns non-secret true/false/nil
			local result = IsSpellInRange(spell, "target")
			rangeCheckedFrame:SetAlpha(1)
			if result ~= nil then
				rangeOverlay:SetAlphaFromBoolean(result, 0, 1)
			else
				rangeOverlay:SetAlpha(0)
			end
		elseif UnitExists("target") then
			-- Fallback: UnitInRange (returns secret booleans)
			local inRange, checkedRange = UnitInRange("target")
			rangeCheckedFrame:SetAlphaFromBoolean(checkedRange, 1, 0)
			rangeOverlay:SetAlphaFromBoolean(inRange, 0, 1)
		else
			rangeOverlay:SetAlpha(0)
			rangeCheckedFrame:SetAlpha(1)
		end
	end
end

----------------------------
-- Module lifecycle

function Range:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Range"])

	f = CreateFrame("Frame", nil, UIParent)
end

function Range:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "UpdateSpellCache")
	updateSpellCache()
end

function Range:OnDisable()
	f:SetScript("OnUpdate", nil)
	if rangeOverlay then
		rangeOverlay:SetAlpha(0)
		rangeCheckedFrame:SetAlpha(1)
	end
end

function Range:ApplySettings()
	db = self.db.profile
	if rangeOverlay then
		rangeOverlay:SetVertexColor(unpack(db.rangecolor))
	end
end

function Range:UpdateSpellCache()
	updateSpellCache()
end

-- UnitName("player") is never secret
function Range:UNIT_SPELLCAST_SENT(event, unit, destName)
	if unit ~= "player" then return end
	local playerName = UnitName("player")
	selfCast = (destName and not issecretvalue(destName) and destName == playerName)
end

function Range:UNIT_SPELLCAST_START(event, unit)
	if unit ~= "player" then
		return
	end
	if selfCast then return end
	if not castBar and Player.Bar then
		castBar = Player.Bar.Bar
	end
	if castBar then
		setupOverlay()
		if UnitExists("target") then
			f:SetScript("OnUpdate", OnUpdate)
		end
	end
end

Range.UNIT_SPELLCAST_CHANNEL_START = Range.UNIT_SPELLCAST_START

----------------------------
-- Options UI
do
	local options
	function getOptions()
		if not options then
			options = {
				type = "group",
				name = L["Range"],
				desc = L["Range"],
				order = 600,
				args = {
					toggle = {
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable"],
						get = function()
							return Quartz3:GetModuleEnabled(MODNAME)
						end,
						set = function(info, v)
							Quartz3:SetModuleEnabled(MODNAME, v)
						end,
						order = 100,
					},
					rangecolor = {
						type = "color",
						name = L["Out of Range Color"],
						desc = L["Set the color to turn the cast bar when the target is out of range"],
						get = function() return unpack(db.rangecolor) end,
						set = function(info, ...)
							db.rangecolor = { ... }
							if rangeOverlay then
								rangeOverlay:SetVertexColor(unpack(db.rangecolor))
							end
						end,
						order = 101,
					},
				},
			}
		end
		return options
	end
end
