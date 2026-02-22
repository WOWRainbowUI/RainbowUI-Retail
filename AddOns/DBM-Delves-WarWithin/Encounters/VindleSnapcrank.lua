local mod	= DBM:NewMod("VindleSnapcrank", "DBM-Delves-WarWithin", 2)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260220224950")
--mod:SetCreatureID(0)--TODO
mod:SetEncounterID(3173, 3124)
mod:SetZone()

mod:RegisterCombat("combat")
