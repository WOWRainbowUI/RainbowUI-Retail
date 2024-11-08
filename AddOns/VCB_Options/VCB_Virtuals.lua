-- functions for the buttons and popouts --
-- on enter --
function vcbEnteringMenus(self)
	GameTooltip_ClearStatusBars(GameTooltip)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("RIGHT", self, "LEFT", 0, 0)
end
-- on leave --
function vcbLeavingMenus()
	GameTooltip:Hide()
end
-- click on Pop Out --
function vcbClickPopOut(var1, var2)
	var1:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not var2:IsShown() then
				var2:Show()
			else
				var2:Hide()
			end
		end
	end)
end
