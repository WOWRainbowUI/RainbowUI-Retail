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

local MODNAME = "Interrupt"
local Interrupt = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local Player = Quartz3:GetModule("Player")
local Target = Quartz3:GetModule("Target", true)
local Focus = Quartz3:GetModule("Focus", true)

local unitToModule = {
	player = Player,
	target = Target,
	focus = Focus,
}

local db, getOptions

----------------------------
-- Upvalues
local GetTime = GetTime
local unpack = unpack
local UnitNameFromGUID = UnitNameFromGUID

local defaults = {
	profile = {
		interruptcolor = {0,0,0},
	},
}

function Interrupt:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Interrupt"])
end

function Interrupt:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
end

function Interrupt:ApplySettings()
	db = self.db.profile
end

-- C_Intl.ToUpper (12.1.5) accepts secret strings from tainted code and handles non-ASCII letters, string.upper does neither.
local function UpperName(name)
	if C_Intl and C_Intl.ToUpper then
		local upper = C_Intl.ToUpper(name)
		if type(upper) == "string" then
			return upper
		end
	end
	if issecretvalue(name) then
		return name
	end
	return name:upper()
end

function Interrupt:UNIT_SPELLCAST_INTERRUPTED(event, unit, castGUID, spellID, interruptedBy)
	local mod = unitToModule[unit]
	if not mod or not mod:IsEnabled() or not mod.Bar then return end
	-- The payload can be secret, type() is the only nil test allowed on it.
	local sourceName
	if type(interruptedBy) == "string" then
		sourceName = UnitNameFromGUID(interruptedBy)
	end
	if type(sourceName) == "string" then
		mod.Bar.Text:SetText(L["INTERRUPTED (%s)"]:format(UpperName(sourceName)))
	else
		mod.Bar.Text:SetText(INTERRUPTED)
	end
	mod.Bar.Bar:SetStatusBarColor(unpack(db.interruptcolor))
	mod.Bar.stopTime = GetTime()
end

do
	local options
	function getOptions()
		options = options or {
		type = "group",
		name = L["Interrupt"],
		order = 600,
		args = {
			toggle = {
				type = "toggle",
				name = L["Enable"],
				get = function()
					return Quartz3:GetModuleEnabled(MODNAME)
				end,
				set = function(info, v)
					Quartz3:SetModuleEnabled(MODNAME, v)
				end,
				order = 100,
			},
			interruptcolor = {
				type = "color",
				name = L["Interrupt Color"],
				desc = L["Set the color the cast bar is changed to when you have a spell interrupted"],
				set = function(info, ...)
					db.interruptcolor = {...}
				end,
				get = function()
					return unpack(db.interruptcolor)
				end,
				order = 101,
			},
		},
	}
	return options
	end
end
