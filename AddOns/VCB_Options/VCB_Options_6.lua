-- taking care of the panel --
vcbOptions6.TopTxt:SetText("建立和載入設定檔!")
vcbOptions6Box1.TitleTxt:SetText("建立設定檔!")
vcbOptions6Box2:SetPoint("TOP", vcbOptions6Box1, "BOTTOM", 0, 0)
vcbOptions6Box2.TitleTxt:SetText("載入設定檔!")
vcbOptions6Box3:SetPoint("TOP", vcbOptions6Box2, "BOTTOM", 0, 0)
vcbOptions6Box3.TitleTxt:SetText("刪除設定檔!")
vcbOptions6Box3.CenterTxt:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("注意: ")..vcbHighColor:WrapTextInColorCode("儲存").."、"..vcbHighColor:WrapTextInColorCode("載入").."或"..vcbHighColor:WrapTextInColorCode("刪除").."設定檔時，會重新載入介面!")
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
	GameTooltip:SetText("在文字框中輸入設定檔的名稱|n然後按下 Enter 鍵儲存設定/選項!") 
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
				DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] 設定檔已經存在，請嘗試其它名稱!")
				return
			end
		end
		VCBrNumber = VCBrNumber + 1
		VCBrProfile[name] = {Player = VCBrPlayer, Target = VCBrTarget, Focus = VCBrFocus}
		C_UI.Reload()
	else
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] 請輸入設定檔名稱!")
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
	GameTooltip:SetText("選擇一個設定檔來"..vcbHighColor:WrapTextInColorCode("載入!")) 
end)
-- leave --
vcbOptions6Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- choice 0 --
vcbOptions6Box2PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] 我只是一個沒有任何功能的按鈕!")
		vcbOptions6Box2PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions6Box2PopOut1Choice0.Text:SetText("沒東西")
-- Box 3 --
-- Popout 1 DELETE --
-- width --
vcbOptions6Box3PopOut1:SetWidth(vcbOptions6Box3:GetWidth()*0.65)
-- drop down --
vcbClickPopOut(vcbOptions6Box3PopOut1, vcbOptions6Box3PopOut1Choice0)
-- enter --
vcbOptions6Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("選擇一個設定檔來"..vcbHighColor:WrapTextInColorCode("刪除!")) 
end)
-- leave --
vcbOptions6Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- choice 0 --
vcbOptions6Box3PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local vcbTime = GameTime_GetTime(false)
		DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] 我只是一個沒有任何功能的按鈕!")
		vcbOptions6Box3PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions6Box3PopOut1Choice0.Text:SetText("沒東西")
-- Showing the panel --
vcbOptions6:HookScript("OnShow", function(self)
	FindingKeys()
	LoadingProfiles()
	DeletingProfiles()
	vcbOptions6Box2PopOut1.Text:SetText("請點我")
	vcbOptions6Box3PopOut1.Text:SetText("請點我")
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
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice0"].Text:SetText("隱藏")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice1"].Text:SetText("左上")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice2"].Text:SetText("左")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice3"].Text:SetText("左下")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice4"].Text:SetText("上")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice5"].Text:SetText("中")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice6"].Text:SetText("下")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice7"].Text:SetText("右上")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice8"].Text:SetText("右")
		_G["vcbOptions"..k.."Box"..i.."PopOut1Choice9"].Text:SetText("右下")
	end
end
