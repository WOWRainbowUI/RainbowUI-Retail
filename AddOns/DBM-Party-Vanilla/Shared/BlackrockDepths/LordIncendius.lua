local mod	= DBM:NewMod(374, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9017)
mod:SetEncounterID(232)
mod:SetModelID(1204)
mod:SetZone(230)

mod:RegisterCombat("combat")

