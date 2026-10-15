if GetLocale() ~= "zhTW" then return end
local L = DBM:GetModLocalization(2896)
L:SetOptionLocalization({warnAddCasts = "大型增援存活期間，加入通用法術與目標通報"})
