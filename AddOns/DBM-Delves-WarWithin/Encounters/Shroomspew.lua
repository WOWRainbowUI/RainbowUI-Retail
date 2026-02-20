local mod	= DBM:NewMod("Shroomspew", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260220041047")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3139)
mod:SetZone()

mod:RegisterCombat("combat")
