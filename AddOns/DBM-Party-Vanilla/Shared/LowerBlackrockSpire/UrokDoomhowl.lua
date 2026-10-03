local mod	= DBM:NewMod(392, "DBM-Party-Vanilla", DBM:IsPostCata() and 5 or 3, 229)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(10584)
mod:SetEncounterID(271)
mod:SetModelID(11583)
mod:SetZone(229)

mod:RegisterCombat("combat")

