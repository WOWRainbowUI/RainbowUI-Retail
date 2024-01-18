local L = LibStub("AceLocale-3.0"):GetLocale("TankMD")
local _, addon = ...
local config = addon.config
local defaultClass = "HUNTER"

local spell, roleKey
do
	local _, class = UnitClass("player")
	local spellId = config.misdirectSpells[class] or config.misdirectSpells[defaultClass]
	spell = GetSpellInfo(spellId)
	roleKey = config.targets[class] or config.targets[defaultClass]
end

_G["BINDING_HEADER_TANKMD"] = L.title

_G["BINDING_NAME_CLICK TankMDButton1:LeftButton"] = L.toFirst:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton2:LeftButton"] = L.toSecond:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton3:LeftButton"] = L.toThird:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton4:LeftButton"] = L.toFourth:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton5:LeftButton"] = L.toFifth:format(spell, L[roleKey])
