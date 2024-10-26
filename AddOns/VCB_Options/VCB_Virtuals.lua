-- register frame --
local zlave = CreateFrame("Frame")
zlave:RegisterEvent("ADDON_LOADED")
-- create options global variables --
local function CreateOptionsGV()
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
					PlaySound(855, "Master")
				else
					var2:Hide()
				end
			end
		end)
	end
end
local function options1()
-- drop down --
	vcbClickPopOut(vcbOptions1Box1PopOut1, vcbOptions1Box1PopOut1Choice0)
	vcbOptions1Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box1PopOut2, vcbOptions1Box1PopOut2Choice0)
	vcbOptions1Box1PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box2PopOut1, vcbOptions1Box2PopOut1Choice0)
	vcbOptions1Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box2PopOut2, vcbOptions1Box2PopOut2Choice0)
	vcbOptions1Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box2PopOut3, vcbOptions1Box2PopOut3Choice0)
	vcbOptions1Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box2PopOut4, vcbOptions1Box2PopOut4Choice0)
	vcbOptions1Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box3PopOut1, vcbOptions1Box3PopOut1Choice0)
	vcbOptions1Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box3PopOut2, vcbOptions1Box3PopOut2Choice0)
	vcbOptions1Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box3PopOut3, vcbOptions1Box3PopOut3Choice0)
	vcbOptions1Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box3PopOut4, vcbOptions1Box3PopOut4Choice0)
	vcbOptions1Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box4PopOut1, vcbOptions1Box4PopOut1Choice0)
	vcbOptions1Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box4PopOut2, vcbOptions1Box4PopOut2Choice0)
	vcbOptions1Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box4PopOut3, vcbOptions1Box4PopOut3Choice0)
	vcbOptions1Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box5PopOut1, vcbOptions1Box5PopOut1Choice0)
	vcbOptions1Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box5PopOut2, vcbOptions1Box5PopOut2Choice0)
	vcbOptions1Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box6PopOut1, vcbOptions1Box6PopOut1Choice0)
	vcbOptions1Box6PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box6PopOut2, vcbOptions1Box6PopOut2Choice0)
	vcbOptions1Box6PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
	vcbClickPopOut(vcbOptions1Box7PopOut1, vcbOptions1Box7PopOut1Choice0)
	vcbOptions1Box7PopOut1:SetScript("OnLeave", vcbLeavingMenus)
end
local function options2()
	TargetFrame.CBpreview:SetScript("OnLeave", vcbLeavingMenus)
	vcbOptions2Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
	vcbOptions2Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
	vcbOptions2Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	vcbClickPopOut(vcbOptions2Box1PopOut1, vcbOptions2Box1PopOut1Choice0)
	-- leave choice 1 --
	vcbOptions2Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
	-- leave --
	vcbOptions2Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box2PopOut1, vcbOptions2Box2PopOut1Choice0)
	-- leave --
	vcbOptions2Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box2PopOut2, vcbOptions2Box2PopOut2Choice0)
	-- leave --
	vcbOptions2Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box2PopOut3, vcbOptions2Box2PopOut3Choice0)
	-- leave --
	vcbOptions2Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box2PopOut4, vcbOptions2Box2PopOut4Choice0)
	-- leave --
	vcbOptions2Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box3PopOut1, vcbOptions2Box3PopOut1Choice0)
	-- leave --
	vcbOptions2Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box3PopOut2, vcbOptions2Box3PopOut2Choice0)
	-- leave --
	vcbOptions2Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box3PopOut3, vcbOptions2Box3PopOut3Choice0)
	-- leave --
	vcbOptions2Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box3PopOut4, vcbOptions2Box3PopOut4Choice0)
	-- leave --
	vcbOptions2Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box4PopOut1, vcbOptions2Box4PopOut1Choice0)
	-- leave --
	vcbOptions2Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box4PopOut2, vcbOptions2Box4PopOut2Choice0)
	-- leave --
	vcbOptions2Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box4PopOut3, vcbOptions2Box4PopOut3Choice0)
	-- leave --
	vcbOptions2Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box5PopOut1, vcbOptions2Box5PopOut1Choice0)
	-- leave --
	vcbOptions2Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions2Box5PopOut2, vcbOptions2Box5PopOut2Choice0)
end
local function options3()
	FocusFrame.CBpreview:SetScript("OnLeave", vcbLeavingMenus)
	vcbOptions3Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
	vcbOptions3Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
	vcbOptions3Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	vcbClickPopOut(vcbOptions3Box1PopOut1, vcbOptions3Box1PopOut1Choice0)
	-- leave choice 1 --
	vcbOptions3Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
	-- leave --
	vcbOptions3Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box2PopOut1, vcbOptions3Box2PopOut1Choice0)
	-- leave --
	vcbOptions3Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box2PopOut2, vcbOptions3Box2PopOut2Choice0)
	-- leave --
	vcbOptions3Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box2PopOut3, vcbOptions3Box2PopOut3Choice0)
	-- leave --
	vcbOptions3Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box2PopOut4, vcbOptions3Box2PopOut4Choice0)
	-- leave --
	vcbOptions3Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box3PopOut1, vcbOptions3Box3PopOut1Choice0)
	-- leave --
	vcbOptions3Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box3PopOut2, vcbOptions3Box3PopOut2Choice0)
	-- leave --
	vcbOptions3Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box3PopOut3, vcbOptions3Box3PopOut3Choice0)
	-- leave --
	vcbOptions3Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box3PopOut4, vcbOptions3Box3PopOut4Choice0)
	-- leave --
	vcbOptions3Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box4PopOut1, vcbOptions3Box4PopOut1Choice0)
	-- leave --
	vcbOptions3Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box4PopOut2, vcbOptions3Box4PopOut2Choice0)
	-- leave --
	vcbOptions3Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box4PopOut3, vcbOptions3Box4PopOut3Choice0)
	-- leave --
	vcbOptions3Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box5PopOut1, vcbOptions3Box5PopOut1Choice0)
	-- leave --
	vcbOptions3Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions3Box5PopOut2, vcbOptions3Box5PopOut2Choice0)
end
local function options4()
	-- leave --
	vcbOptions4Box1EditBox1.WritingLine:HookScript("OnLeave", vcbLeavingMenus)
	-- leave --
	vcbOptions4Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions4Box2PopOut1, vcbOptions4Box2PopOut1Choice0)
	-- leave --
	vcbOptions4Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
	-- drop down --
	vcbClickPopOut(vcbOptions4Box3PopOut1, vcbOptions4Box3PopOut1Choice0)
end
-- Events time --
local function EventsTime(self, event, arg1, arg2, arg3)
	if event == "ADDON_LOADED" and arg1 == "VCB_Options" then
		CreateOptionsGV()
		options1()
		options2()
		options3()
		options4()
	end
end
zlave:SetScript("OnEvent", EventsTime)
