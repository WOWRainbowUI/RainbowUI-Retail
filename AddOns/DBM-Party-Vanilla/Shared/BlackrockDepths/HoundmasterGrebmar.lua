local mod	= DBM:NewMod(371, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9319)
mod:SetEncounterID(229)
mod:SetModelID(9212)
mod:SetZone(230)

mod:RegisterCombat("combat")

