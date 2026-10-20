local mod	= DBM:NewMod("SpeakerHalven", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20261019224209")
mod:EnableGenericTrash()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3007)
mod:SetZone()

mod:RegisterCombat("combat")
