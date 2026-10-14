local mod	= DBM:NewMod("Drakta", "DBM-Delves-Midnight", 2)
--local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal"
mod.soloChallenge = true

mod:SetRevision("20261013183750")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3535)
mod:SetZone()

mod:RegisterCombat("combat")
