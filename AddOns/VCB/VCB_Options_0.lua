-- taking care of the panel --
vcbOptions0.BGtexture:SetAlpha(0.70)
vcbOptions0.TopTxt:SetText("It would be good when you open the |cffFF0055Options' Panel|r to close the other ones so you can watch what changes you are making!")
vcbOptions0.CenterTxt:SetText(vcbHighColor:WrapTextInColorCode("Voodoo").." Casting "..vcbHighColor:WrapTextInColorCode("Bar!").."is an add on that enchant the default Casting Bars!|n|nPress the button below to open the options pane!")
vcbOptions0.BottomTxt:SetText("Thank you for using this amazing add-on!|nYou are a |cff00CED1Funky|r and a |cffFF0055Groovy|r person!|nMay the good |cff9400D3Mojo|r be with you!")
-- button 1 do it --
vcbOptions0Button1.Text:SetText("Options Panel")
vcbOptions0Button1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nOpen the main panel of settings!") 
end)
vcbOptions0Button1:SetScript("OnLeave", vcbLeaving)
vcbOptions0Button1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions00:IsShown() then
			vcbOptions00:Show()
			PlaySound(855, "Master")
		else
			vcbOptions00:Hide()
			PlaySound(858, "Master")
		end
	end
end)
-- Move the Tabs --
vcbOptions00:RegisterForDrag("LeftButton")
vcbOptions00:SetScript("OnDragStart", vcbOptions00.StartMoving)
vcbOptions00:SetScript("OnDragStop", vcbOptions00.StopMovingOrSizing)
-- taking care of the Tabs --
vcbOptions00Tab2:SetPoint("TOP", vcbOptions00Tab1, "BOTTOM", 0, 0)
vcbOptions00Tab3:SetPoint("TOP", vcbOptions00Tab2, "BOTTOM", 0, 0)
vcbOptions00Tab4:SetPoint("TOP", vcbOptions00Tab3, "BOTTOM", 0, 0)
vcbOptions00Tab1.Text:SetText("Player's Castbar")
vcbOptions00Tab2.Text:SetText("Target's Castbar")
vcbOptions00Tab3.Text:SetText("Focus' Castbar")
vcbOptions00Tab4.Text:SetText("Profiles")
vcbOptions00Tab1.CenterTxt:Hide()
vcbOptions00Tab2.CenterTxt:Hide()
vcbOptions00Tab3.CenterTxt:Hide()
vcbOptions00Tab4.CenterTxt:SetText("Thank you for using this amazing add-on!|nYou are a |cff00CED1Funky|r and a |cffFF0055Groovy|r person!|nMay the good |cff9400D3Mojo|r be with you!")
vcbOptions00.BGtexture:SetGradient("VERTICAL", vcbNoColor, vcbMainColor)
vcbOptions00.BGtexture:ClearAllPoints()
vcbOptions00.BGtexture:SetPoint("TOPRIGHT", vcbOptions00, "TOPRIGHT", 0, 0)
vcbOptions00.BGtexture:SetPoint("BOTTOMLEFT", vcbOptions00Tab4, "BOTTOMLEFT", 0, -128)
-- clicking on the tabs --
vcbOptions00Tab1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions1:IsShown() then vcbOptions1:Show() end
	end
end)
vcbOptions00Tab2:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions2:IsShown() then vcbOptions2:Show() end
	end
end)
vcbOptions00Tab3:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions3:IsShown() then vcbOptions3:Show() end
	end
end)
vcbOptions00Tab4:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions4:IsShown() then vcbOptions4:Show() end
	end
end)
-- showing the tabs --
vcbOptions00:SetScript("OnShow", function(self)
	if not vcbOptions1:IsShown() then vcbOptions1:Show() end
end)
-- hiding the tabs --
vcbOptions00:SetScript("OnHide", function(self)
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
end)
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		local category = Settings.RegisterCanvasLayoutCategory(self, "VCB")
		category:SetName("Voodoo "..vcbHighColor:WrapTextInColorCode("Casting").." Bar!")
		Settings.RegisterAddOnCategory(category)
	end
end
vcbOptions0:SetScript("OnEvent", EventsTime)
