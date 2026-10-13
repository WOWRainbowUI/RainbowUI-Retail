if GetLocale() ~= "zhTW" then return end

local L = DBM:GetModLocalization(2874)
L:SetOptionLocalization({
	AdvancedBossFiltering = "持續偵測與各首領的距離，並自動隱藏距離超過48碼的首領之部分警告，同時淡化其計時條"
})
