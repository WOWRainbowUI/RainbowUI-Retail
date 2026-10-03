local mod	= DBM:NewMod(380, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9537)
mod:SetEncounterID(238)
mod:SetModelID(8658)
mod:SetZone(230)

mod:RegisterCombat("combat")

