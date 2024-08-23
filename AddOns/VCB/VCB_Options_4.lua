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
			local button = CreateFrame("Button" , "vcbOptions4Box2PopOut1Choice"..VCBrCounterLoading, vcbOptions4Box2PopOut1Choice0, "vcbPopOutButton")
			_G["vcbOptions4Box2PopOut1Choice"..VCBrCounterLoading]:SetPoint("TOP","vcbOptions4Box2PopOut1Choice"..VCBrCounterLoading - 1, "BOTTOM", 0, 0)
			_G["vcbOptions4Box2PopOut1Choice"..VCBrCounterLoading].Text:SetText(k)
			_G["vcbOptions4Box2PopOut1Choice"..VCBrCounterLoading]:HookScript("OnClick", function(self, button, down)
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
			local button = CreateFrame("Button" , "vcbOptions4Box3PopOut1Choice"..VCBrCounterDeleting, vcbOptions4Box3PopOut1Choice0, "vcbPopOutButton")
			_G["vcbOptions4Box3PopOut1Choice"..VCBrCounterDeleting]:SetPoint("TOP","vcbOptions4Box3PopOut1Choice"..VCBrCounterDeleting - 1, "BOTTOM", 0, 0)
			_G["vcbOptions4Box3PopOut1Choice"..VCBrCounterDeleting].Text:SetText(k)
			_G["vcbOptions4Box3PopOut1Choice"..VCBrCounterDeleting]:HookScript("OnClick", function(self, button, down)
				if button == "LeftButton" and down == false then
					DeletingKeys(self)
					C_UI.Reload()
				end
			end)
		end
	end
end
-- taking care of the panel --
vcbOptions4:ClearAllPoints()
vcbOptions4:SetPoint("TOPLEFT", vcbOptions00, "TOPLEFT", 0, 0)
vcbOptions4.BGtexture:SetAlpha(1)
vcbOptions4.TopTxt:SetText("Create and load profiles!")
vcbOptions4.CenterTxt:Hide()
vcbOptions4.BottomLeftTxt:Hide()
vcbOptions4Box1.TitleTxt:SetText("Create a profile!")
vcbOptions4Box2:SetPoint("TOP", vcbOptions4Box1, "BOTTOM", 0, 0)
vcbOptions4Box2.TitleTxt:SetText("Load a profile!")
vcbOptions4Box3:SetPoint("TOP", vcbOptions4Box2, "BOTTOM", 0, 0)
vcbOptions4Box3.TitleTxt:SetText("Delete a profile!")
vcbOptions4Box3.CenterTxt:SetText(vcbHighColor:WrapTextInColorCode("Note: ").."When you "..vcbHighColor:WrapTextInColorCode("SAVE")..", "..vcbHighColor:WrapTextInColorCode("LOAD")..", or "..vcbHighColor:WrapTextInColorCode("DELETE").." a Profile, the UI will be RELOADED!")
-- taking care of the edit box --
-- width and height --
local fontFile, height, flags = vcbOptions4Box1EditBox1.WritingLine:GetFont()
vcbOptions4Box1EditBox1.WritingLine:SetHeight(height)
vcbOptions4Box1EditBox1:SetWidth(vcbOptions4Box1:GetWidth()*0.65)
vcbOptions4Box1EditBox1:SetHeight(vcbOptions4Box1EditBox1.WritingLine:GetHeight()*1.75)
vcbOptions4Box1EditBox1.WritingLine:SetWidth(vcbOptions4Box1EditBox1:GetWidth()*0.95)
-- entering, leaving --
vcbOptions4Box1EditBox1.WritingLine:HookScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWrite a name for your profile in the Edit Box and|npress enter to save your settings/options!") 
end)
vcbOptions4Box1EditBox1.WritingLine:HookScript("OnLeave", vcbLeavingMenus)
-- pressing enter --
vcbOptions4Box1EditBox1.WritingLine:SetScript("OnEnterPressed", function(self)
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
				DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] This Profile already exist please try another name!")
				return
			end
		end
		VCBrNumber = VCBrNumber + 1
		VCBrProfile[name] = {Player = VCBrPlayer, Target = VCBrTarget, Focus = VCBrFocus}
		C_UI.Reload()
	else
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] Please enter a name for your profile!")
	end
end)
-- Popout 1, entering, leaving, click --
vcbOptions4Box2PopOut1:SetWidth(vcbOptions4Box2:GetWidth()*0.65)
vcbOptions4Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nSelect one of the profiles to be "..vcbHighColor:WrapTextInColorCode("LOADED!")) 
end)
vcbOptions4Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions4Box2PopOut1, vcbOptions4Box2PopOut1Choice0)
vcbOptions4Box2PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] I did nothing, I literally do nothing as button!")
		vcbOptions4Box2PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions4Box2PopOut1Choice0.Text:SetText("Nothing")
-- Popout 1, entering, leaving, click --
vcbOptions4Box3PopOut1:SetWidth(vcbOptions4Box3:GetWidth()*0.65)
vcbOptions4Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nSelect one of the profiles to be "..vcbHighColor:WrapTextInColorCode("DELETED!")) 
end)
vcbOptions4Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions4Box3PopOut1, vcbOptions4Box3PopOut1Choice0)
vcbOptions4Box3PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] I did nothing, I literally do nothing as button!")
		vcbOptions4Box3PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions4Box3PopOut1Choice0.Text:SetText("Nothing")
-- Showing the panel --
vcbOptions4:HookScript("OnShow", function(self)
	FindingKeys()
	LoadingProfiles()
	DeletingProfiles()
	vcbOptions4Box2PopOut1.Text:SetText("Click me")
	vcbOptions4Box3PopOut1.Text:SetText("Click me")
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbHighColor:GetRGB())
end)
