local mod	= DBM:NewMod(375, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9041)
mod:SetEncounterID(233)
mod:SetModelID(9089)
mod:SetZone(230)

mod:RegisterCombat("combat")

