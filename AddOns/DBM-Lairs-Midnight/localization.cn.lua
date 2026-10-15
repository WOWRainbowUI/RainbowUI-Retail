if GetLocale() ~= "zhCN" then return end
local L = DBM:GetModLocalization(2896)
L:SetOptionLocalization({warnAddCasts = "大型增援存活期间，添加通用法术与目标通报"})
