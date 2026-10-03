local mod	= DBM:NewMod(393, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9736)
mod:SetEncounterID(272)
mod:SetModelID(9738)
mod:SetZone(229)

mod:RegisterCombat("combat")

