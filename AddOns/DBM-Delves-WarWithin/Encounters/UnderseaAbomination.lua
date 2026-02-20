local mod	= DBM:NewMod("UnderseaAbomination", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260220041047")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(2895)
mod:SetZone()

mod:RegisterCombat("combat")
