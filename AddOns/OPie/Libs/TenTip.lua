local _, T = ...

local tn, suf = "NotGameTooltip", 0
while _G[tn] do
	tn, suf = tn .. suf, suf + 1
end
local tip = CreateFrame("GameTooltip", tn, UIParent, "GameTooltipTemplate") do
	local skipHide
	tip:SetScript("OnShow", function(self)
		if GameTooltip:IsForbidden() then
			return
		end
		skipHide = true
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetText(" ")
		GameTooltip:Hide()
		-- GameTooltip's OnShow is deferred, so skipHide can't be cleared here
	end)
	local tw = CreateFrame("Frame", nil, GameTooltip)
	tw:SetScript("OnShow", function()
		if skipHide then
			skipHide = false
		else
			tip:Hide()
		end
	end)
end

T.NotGameTooltip = tip