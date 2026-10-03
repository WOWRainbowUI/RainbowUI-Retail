local mod	= DBM:NewMod(379, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(8983)
mod:SetEncounterID(237)
mod:SetModelID(8759)
mod:SetZone(230)

mod:RegisterCombat("combat")

