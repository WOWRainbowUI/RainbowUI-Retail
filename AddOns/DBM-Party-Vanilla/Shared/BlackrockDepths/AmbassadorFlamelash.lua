local mod	= DBM:NewMod(384, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9156)
mod:SetEncounterID(242)
mod:SetModelID(8329)
mod:SetZone(230)

mod:RegisterCombat("combat")

