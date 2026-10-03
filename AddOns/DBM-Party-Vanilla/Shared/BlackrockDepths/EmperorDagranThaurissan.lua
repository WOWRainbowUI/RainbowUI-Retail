local mod	= DBM:NewMod(387, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(9019)--Moira 8929
mod:SetEncounterID(245)
mod:SetModelID(8807)
mod:SetZone(230)

mod:RegisterCombat("combat")

