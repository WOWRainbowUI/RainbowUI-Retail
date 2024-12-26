local _, KT = ...

-- shared pool since there are several modules that can display quests, but a given quest can only appear in a specific module
local g_questPOIButtonPool = CreateFramePool("BUTTON", nil, "KT2_ObjectiveTrackerPOIButtonTemplate");  -- MSA

KT_ObjectiveTrackerQuestPOIBlockMixin = CreateFromMixins(KT_ObjectiveTrackerAnimBlockMixin);

-- overrides inherited
function KT_ObjectiveTrackerQuestPOIBlockMixin:OnLayout()
	local module = self.parentModule;
	if self.poiQuestID and (module.showWorldQuests or KT_ObjectiveTrackerManager:CanShowPOIs(module)) then
		self:AddPOIButton();
	else
		self:CheckAndReleasePOIButton();
	end

	-- this could play anim on POI button so it has to run last
	KT_ObjectiveTrackerAnimBlockMixin.OnLayout(self);
end

function KT_ObjectiveTrackerQuestPOIBlockMixin:AddPOIButton(questID, isComplete, isSuperTracked, isWorldQuest)
	local style;
	if self.poiIsWorldQuest then
		style = POIButtonUtil.Style.WorldQuest;
	elseif self.poiIsComplete then
		style = POIButtonUtil.Style.QuestComplete;
	else
		style = POIButtonUtil.Style.QuestInProgress;
	end
	local poiButton = self:GetPOIButton(style);
	poiButton:SetPoint("TOPRIGHT", self.HeaderText, "TOPLEFT", -7, 5);
	poiButton:SetPingWorldMap(isWorldQuest);
end
KT.BackupMixin("KT_ObjectiveTrackerQuestPOIBlockMixin", "AddPOIButton")  -- MSA

function KT_ObjectiveTrackerQuestPOIBlockMixin:GetPOIButton(style)
	local button = self.poiButton;
	if not button then
		button = g_questPOIButtonPool:Acquire();
		button:SetParent(self);
		-- MSA (begin)
		if style ~= POIButtonUtil.Style.AreaPOI then
			-- Quest / World Quest / Bonus Objective
			button:SetQuestID(self.poiQuestID);
			button.areaPOIID = nil
		else
			-- Event
			if self.poiInfo then
				button:SetAreaPOIInfo(self.poiInfo)
			end
			button.questID = nil
		end
		-- MSA (end)
		self.poiButton = button;
		self:SetExtraAddAnimation(button.AddAnim);
	end

	button:SetStyle(style);
	button:SetSelected(self.poiIsSuperTracked);
	button:UpdateButtonStyle();
	button:Show();
	return button;
end

function KT_ObjectiveTrackerQuestPOIBlockMixin:SetPOIInfo(questID, isComplete, isSuperTracked, isWorldQuest, poiInfo)  -- MSA
	self.poiQuestID = questID;
	self.poiIsComplete = isComplete;
	self.poiIsSuperTracked = isSuperTracked;
	self.poiIsWorldQuest = isWorldQuest;
	self.poiInfo = poiInfo  -- MSA
end

-- overrides inherited
function KT_ObjectiveTrackerQuestPOIBlockMixin:Free()
	KT_ObjectiveTrackerAnimBlockMixin.Free(self);
	self:CheckAndReleasePOIButton();
end

function KT_ObjectiveTrackerQuestPOIBlockMixin:CheckAndReleasePOIButton()
	if self.poiButton then
		g_questPOIButtonPool:Release(self.poiButton);
		self.poiButton = nil;
		self:SetExtraAddAnimation(nil);
		-- clear out the values with nils
		self:SetPOIInfo();
	end
end