local mod	= DBM:NewMod(419, "DBM-Party-Vanilla", DBM:IsRetail() and 4 or 7, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20231012014002")
mod:SetCreatureID(7361)
mod:SetEncounterID(379)

mod:RegisterCombat("combat")
