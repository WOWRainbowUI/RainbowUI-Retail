local mod	= DBM:NewMod(417, "DBM-Party-Vanilla", DBM:IsPostCata() and 3 or 6, 230)
local L		= mod:GetLocalizedStrings()
mod:SetRevision("20261019224209")
if DBM:IsForever() then
	mod:EnableGenericTrash()
end
mod:SetCreatureID(11501)
mod:SetEncounterID(368)
mod:SetModelID(11583)
mod:SetZone(429)
mod:RegisterCombat("combat")
mod:DisableFriendlyDetection()

