local mod	= DBM:NewMod("z3038", "DBM-Delves-Midnight", 3)
--local L		= mod:GetLocalizedStrings()

mod:SetRevision("20260806200220")
mod:SetHotfixNoticeRev(20250220000000)
mod:SetMinSyncRevision(20250220000000)
mod:SetZone(3038)

mod:RegisterCombat("scenario", 3038)
