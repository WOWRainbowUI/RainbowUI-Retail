local mod	= DBM:NewMod(369, "DBM-Party-Vanilla", 2, 228)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20261019224209")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(9018)
mod:SetEncounterID(227)
mod:SetModelID(8761)
mod:SetZone(230)

mod:RegisterCombat("combat")

