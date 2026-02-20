local mod	= DBM:NewMod("SpeakerWicke", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260220041047")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3147)
mod:SetZone()

mod:RegisterCombat("combat")
