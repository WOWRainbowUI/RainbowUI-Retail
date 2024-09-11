-- taking care of the panel --
vcbOptions0.BGtexture:SetAlpha(0.70)
vcbOptions0.TopTxt:SetText("It would be good when you open the |cffFF0055Options' Panel|r to close the other ones so you can watch what changes you are making!")
vcbOptions0.CenterTxt:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title").." is an add on that enchants the default Casting Bars!|n|nPress the button below to open the options pane!")
vcbOptions0.BottomTxt:SetText("Thank you for using this amazing add-on!|nYou are a |cff00CED1Funky|r and a |cffFF0055Groovy|r person!|nMay the good |cff9400D3Mojo|r be with you!")
-- button 1 to option's panel --
vcbOptions0Button1.Text:SetText("Options Panel")
-- enter --
vcbOptions0Button1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nClick: "..vcbMainColor:WrapTextInColorCode("Open the main panel of settings!")) 
end)
-- leave --
vcbOptions0Button1:SetScript("OnLeave", vcbLeavingMenus)
-- click --
vcbOptions0Button1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		vcbShowMenu()
	end
end)
-- Move the Tabs --
vcbOptions00:RegisterForDrag("LeftButton")
vcbOptions00:SetScript("OnDragStart", vcbOptions00.StartMoving)
vcbOptions00:SetScript("OnDragStop", vcbOptions00.StopMovingOrSizing)
-- taking care of the Tabs --
-- position --
for i = 2, 4, 1 do
	_G["vcbOptions00Tab"..i]:SetPoint("TOP", _G["vcbOptions00Tab"..i-1], "BOTTOM", 0, 0)
end
-- naming --
vcbOptions00Tab1.Text:SetText("Player's Castbar")
vcbOptions00Tab2.Text:SetText("Target's Castbar")
vcbOptions00Tab3.Text:SetText("Focus' Castbar")
vcbOptions00Tab4.Text:SetText("Profiles")
-- hiding the center text --
for i = 1, 3, 1 do
	_G["vcbOptions00Tab"..i].CenterTxt:Hide()
end
vcbOptions00Tab4.CenterTxt:SetText("Thank you for using this amazing add-on!|nYou are a |cff00CED1Funky|r and a |cffFF0055Groovy|r person!|nMay the good |cff9400D3Mojo|r be with you!")
vcbOptions00.BGtexture:SetGradient("VERTICAL", vcbNoColor, vcbMainColor)
vcbOptions00.BGtexture:ClearAllPoints()
vcbOptions00.BGtexture:SetPoint("TOPRIGHT", vcbOptions00, "TOPRIGHT", 0, 0)
vcbOptions00.BGtexture:SetPoint("BOTTOMLEFT", vcbOptions00Tab4, "BOTTOMLEFT", 0, -128)
-- clicking on the tabs --
for i = 1, 4, 1 do
	_G["vcbOptions00Tab"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Show() end
		end
	end)
end
-- showing the tabs --
vcbOptions00:SetScript("OnShow", function(self)
	if not vcbOptions1:IsShown() then vcbOptions1:Show() end
end)
-- hiding the tabs --
vcbOptions00:HookScript("OnHide", function(self)
	for i = 1, 4, 1 do
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
end)
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		local category = Settings.RegisterCanvasLayoutCategory(self, "VCB")
		category:SetName("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title"))
		Settings.RegisterAddOnCategory(category)
	end
end
vcbOptions0:SetScript("OnEvent", EventsTime)
