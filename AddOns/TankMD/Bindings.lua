local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("TankMD")
local TankMD = AceAddon:GetAddon("TankMD")
---@cast TankMD TankMD

local _, class = UnitClass("player")
local spellId = TankMD:GetMisdirectSpellID(class)
local spell = C_Spell.GetSpellInfo(spellId).name
local roleKey = TankMD:GetMisdirectTargetRole(class)

_G["BINDING_HEADER_TANKMD"] = L.title

_G["BINDING_NAME_CLICK TankMDButton1:LeftButton"] = L.to_first:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton2:LeftButton"] = L.to_second:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton3:LeftButton"] = L.to_third:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton4:LeftButton"] = L.to_fourth:format(spell, L[roleKey])
_G["BINDING_NAME_CLICK TankMDButton5:LeftButton"] = L.to_fifth:format(spell, L[roleKey])
