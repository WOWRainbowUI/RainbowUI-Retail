local mod	= DBM:NewMod("TheUndeadTrollbunal", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("20261019224209")
mod:EnableGenericTrash()
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3632)
mod:SetZone()

mod:RegisterCombat("combat")
