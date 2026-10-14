local mod	= DBM:NewMod("Grukk", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("20261013182813")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3636)
mod:SetZone()

mod:RegisterCombat("combat")
