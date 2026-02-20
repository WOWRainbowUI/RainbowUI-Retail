local mod	= DBM:NewMod("Cragpie", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260220041047")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3001)
mod:SetZone()

mod:RegisterCombat("combat")
