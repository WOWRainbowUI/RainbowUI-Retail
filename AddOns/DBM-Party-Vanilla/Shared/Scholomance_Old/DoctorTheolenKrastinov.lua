local mod	= DBM:NewMod("DoctorTheolenKrastinov", "DBM-Party-Vanilla", DBM:IsPostCata() and 16 or 13)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260905035030")
mod:DisableHardcodedOptions()
mod:SetCreatureID(11261)
mod:SetEncounterID(mod:IsClassic() and 2802 or 458)
mod:SetModelID(10901)
mod:SetZone(289)

mod:RegisterCombat("combat")

if DBM:IsRestricted() then
	--do stuff
	--mod:AddAuraSoundOption(372820, true, 372820, 1, 2, "watchfeet", 8, 0)
end
