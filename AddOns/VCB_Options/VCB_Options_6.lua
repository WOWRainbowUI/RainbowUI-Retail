-- taking care of the panel --
vcbOptions6.TopTxt:SetText("Create and load profiles!")
vcbOptions6Box1.TitleTxt:SetText("Create a profile!")
vcbOptions6Box2:SetPoint("TOP", vcbOptions6Box1, "BOTTOM", 0, 0)
vcbOptions6Box2.TitleTxt:SetText("Load a profile!")
vcbOptions6Box3:SetPoint("TOP", vcbOptions6Box2, "BOTTOM", 0, 0)
vcbOptions6Box3.TitleTxt:SetText("Delete a profile!")
vcbOptions6Box3.CenterTxt:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note: ").."When you "..vcbHighColor:WrapTextInColorCode("SAVE")..", "..vcbHighColor:WrapTextInColorCode("LOAD")..", or "..vcbHighColor:WrapTextInColorCode("DELETE").." a Profile, the UI will be RELOADED!")
-- some variables --
local NameExist = false
-- finding keys --
local function FindingKeys()
	local Keys = 0
	for k, v in pairs(VCBrProfile) do
		Keys = Keys + 1
	end
	VCBrNumber = Keys
end
-- coping the tables --
local function CopyTable(k)
	VCBrPlayer = VCBrProfile[k]["Player"]
	VCBrTarget = VCBrProfile[k]["Target"]
	VCBrFocus = VCBrProfile[k]["Focus"]
end
-- deleting keys --
local function DeletingKeys(self)
	for k, v in pairs(VCBrProfile) do
		if k == self:GetText() then
		VCBrProfile[k] = nil
		end
	end
end
-- functions for loading the profiles --
local function LoadingProfiles()
	if VCBrCounterLoading == 0 and VCBrNumber > 0 then
		for k, v in pairs(VCBrProfile) do
			VCBrCounterLoading = VCBrCounterLoading + 1
			local button = CreateFrame("Button" , "vcbOptions6Box2PopOut1Choice"..VCBrCounterLoading, vcbOptions6Box2PopOut1Choice0, "vcbPopOutButton")
			_G["vcbOptions6Box2PopOut1Choice"..VCBrCounterLoading]:SetPoint("TOP","vcbOptions6Box2PopOut1Choice"..VCBrCounterLoading - 1, "BOTTOM", 0, 0)
			_G["vcbOptions6Box2PopOut1Choice"..VCBrCounterLoading].Text:SetText(k)
			_G["vcbOptions6Box2PopOut1Choice"..VCBrCounterLoading]:HookScript("OnClick", function(self, button, down)
				if button == "LeftButton" and down == false then
					CopyTable(k)
					C_UI.Reload()
				end
			end)
		end
	end
end
-- functions for deleting the profiles --
local function DeletingProfiles()
	if VCBrCounterDeleting == 0 and VCBrNumber > 0 then
		for k, v in pairs(VCBrProfile) do
			VCBrCounterDeleting = VCBrCounterDeleting + 1
			local button = CreateFrame("Button" , "vcbOptions6Box3PopOut1Choice"..VCBrCounterDeleting, vcbOptions6Box3PopOut1Choice0, "vcbPopOutButton")
			_G["vcbOptions6Box3PopOut1Choice"..VCBrCounterDeleting]:SetPoint("TOP","vcbOptions6Box3PopOut1Choice"..VCBrCounterDeleting - 1, "BOTTOM", 0, 0)
			_G["vcbOptions6Box3PopOut1Choice"..VCBrCounterDeleting].Text:SetText(k)
			_G["vcbOptions6Box3PopOut1Choice"..VCBrCounterDeleting]:HookScript("OnClick", function(self, button, down)
				if button == "LeftButton" and down == false then
					DeletingKeys(self)
					C_UI.Reload()
				end
			end)
		end
	end
end
-- taking care of the edit box --
-- width and height --
local fontFile, height, flags = vcbOptions6Box1EditBox1.WritingLine:GetFont()
vcbOptions6Box1EditBox1.WritingLine:SetHeight(height)
vcbOptions6Box1EditBox1:SetWidth(vcbOptions6Box1:GetWidth()*0.65)
vcbOptions6Box1EditBox1:SetHeight(vcbOptions6Box1EditBox1.WritingLine:GetHeight()*1.75)
vcbOptions6Box1EditBox1.WritingLine:SetWidth(vcbOptions6Box1EditBox1:GetWidth()*0.95)
-- enter --
vcbOptions6Box1EditBox1.WritingLine:HookScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWrite a name for your profile in the Edit Box and|npress enter to save your settings/options!") 
end)
-- leave --
vcbOptions6Box1EditBox1.WritingLine:HookScript("OnLeave", vcbLeavingMenus)
-- pressing enter --
vcbOptions6Box1EditBox1.WritingLine:SetScript("OnEnterPressed", function(self)
	if self:HasText() then
		EditBox_HighlightText(self)
		local name = self:GetText()
		for k, v in pairs(VCBrProfile) do
			if k == name then
				NameExist = true
			else
				NameExist = false
			end
			if NameExist then
				local vcbTime = GameTime_GetTime(false)
				DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] This Profile already exist please try another name!")
				return
			end
		end
		VCBrNumber = VCBrNumber + 1
		VCBrProfile[name] = {Player = VCBrPlayer, Target = VCBrTarget, Focus = VCBrFocus}
		C_UI.Reload()
	else
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] Please enter a name for your profile!")
	end
end)
-- Box 2 --
-- Popout 1 LOAD --
-- width --
vcbOptions6Box2PopOut1:SetWidth(vcbOptions6Box2:GetWidth()*0.65)
-- drop down --
vcbClickPopOut(vcbOptions6Box2PopOut1, vcbOptions6Box2PopOut1Choice0)
-- enter --
vcbOptions6Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nSelect one of the profiles to be "..vcbHighColor:WrapTextInColorCode("LOADED!")) 
end)
-- leave --
vcbOptions6Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- choice 0 --
vcbOptions6Box2PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] I did nothing, I literally do nothing as button!")
		vcbOptions6Box2PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions6Box2PopOut1Choice0.Text:SetText("Nothing")
-- Box 3 --
-- Popout 1 DELETE --
-- width --
vcbOptions6Box3PopOut1:SetWidth(vcbOptions6Box3:GetWidth()*0.65)
-- drop down --
vcbClickPopOut(vcbOptions6Box3PopOut1, vcbOptions6Box3PopOut1Choice0)
-- enter --
vcbOptions6Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nSelect one of the profiles to be "..vcbHighColor:WrapTextInColorCode("DELETED!")) 
end)
-- leave --
vcbOptions6Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- choice 0 --
vcbOptions6Box3PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] I did nothing, I literally do nothing as button!")
		vcbOptions6Box3PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions6Box3PopOut1Choice0.Text:SetText("Nothing")
-- Showing the panel --
vcbOptions6:HookScript("OnShow", function(self)
	FindingKeys()
	LoadingProfiles()
	DeletingProfiles()
	vcbOptions6Box2PopOut1.Text:SetText("Click me")
	vcbOptions6Box3PopOut1.Text:SetText("Click me")
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	if vcbOptions5:IsShown() then vcbOptions5:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab5.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab6.Text:SetTextColor(vcbHighColor:GetRGB())
end)
-- taking of the options panels --
for i = 1, 6, 1 do
	_G["vcbOptions"..i]:ClearAllPoints()
	_G["vcbOptions"..i]:SetPoint("TOPLEFT", vcbOptions00, "TOPLEFT", 0, 0)
	_G["vcbOptions"..i].BGtexture:SetAlpha(1)
	_G["vcbOptions"..i].CenterTxt:Hide()
	_G["vcbOptions"..i].BottomTxt:Hide()
	_G["vcbOptions"..i].BottomLeftTxt:Hide()
end
-- naming button choices for spell's name, current cast time, current & total time, and total time -- for target and focus!
for k = 2, 3, 1 do
	for i = 2, 5, 1 do
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice0"].Text:SetText("Hide")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice1"].Text:SetText("Top Left")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice2"].Text:SetText("Left")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice3"].Text:SetText("Bottom Left")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice4"].Text:SetText("Top")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice5"].Text:SetText("Center")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice6"].Text:SetText("Bottom")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice7"].Text:SetText("Top Right")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice8"].Text:SetText("Right")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice9"].Text:SetText("Bottom Right")
	end
end
