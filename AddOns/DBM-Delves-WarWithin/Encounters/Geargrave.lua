local mod	= DBM:NewMod("Geargrave", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260220224950")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3174, 3120, 3123, 3352)--Appears in 3 different delves
mod:SetZone()

mod:RegisterCombat("combat")
