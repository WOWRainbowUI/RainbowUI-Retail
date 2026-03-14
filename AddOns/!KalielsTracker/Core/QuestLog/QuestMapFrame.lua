local ignoreWaypointsByQuestID = { };

function KT_QuestMapFrame_ToggleShowDestination()
    local questID = KT_QuestMapFrame.DetailsFrame.questID;
    ignoreWaypointsByQuestID[questID] = not ignoreWaypointsByQuestID[questID];
    KT_QuestMapFrame_ShowQuestDetails(KT_QuestMapFrame.DetailsFrame.questID);
end

function KT_QuestMapFrame_AdjustPathButtons()
	if KT_QuestMapDetailsScrollFrame:GetVerticalScrollRange() > 0 then
		KT_QuestInfo_AdjustTitleWidth(-19);
	else
		KT_QuestInfo_AdjustTitleWidth(-2);
	end
end

KT_QuestLogQuestDetailsMixin = { };

function KT_QuestLogQuestDetailsMixin:OnLoad()
    KT_QuestMapDetailsScrollFrame:RegisterCallback("OnVerticalScroll", GenerateClosure(self.AdjustRewardsFrameContainer, self));
    KT_QuestMapDetailsScrollFrame:RegisterCallback("OnScrollRangeChanged", GenerateClosure(self.AdjustRewardsFrameContainer, self));
end

function KT_QuestLogQuestDetailsMixin:OnShow()
	self.Bg:SetAtlas(QuestTextContrast.GetDefaultDetailsBackgroundAtlas());
	self:AdjustBackgroundTexture(self.Bg);
end

function KT_QuestLogQuestDetailsMixin:OnHide()

end

-- This function will resize the background textures (Bg and SealMaterialBG) proportionally to fit the new bigger size of the panel.
-- Capping off at 440 max height so it doesn't run out of bounds.
function KT_QuestLogQuestDetailsMixin:AdjustBackgroundTexture(texture)
	local atlasName = texture:GetAtlas();
	if not atlasName then
		return;
	end

	local atlasInfo = C_Texture.GetAtlasInfo(atlasName);
	local width = KT_QuestMapFrame.DetailsFrame:GetWidth();
	local atlasWidth = atlasInfo.width;
	local ratio = width / atlasWidth;
	local neededHeight = atlasInfo.height * ratio;
	local maxHeight = 440;
	texture:SetWidth(width);
	if neededHeight > maxHeight then
		texture:SetTexCoord(0, 1, 0, maxHeight / neededHeight);
		texture:SetHeight(maxHeight);
	else
		texture:SetTexCoord(0, 1, 0, 1);
		texture:SetHeight(neededHeight);
	end
end

function KT_QuestLogQuestDetailsMixin:SetRewardsHeight(height)
	local container = self.RewardsFrameContainer;
	container.isFixedHeight = nil;	-- trinary
	container.RewardsFrame:SetHeight(height);
	KT_QuestInfo_AdjustSpacerHeight(height);
	local numRewardRows = KT_QuestInfo_GetNumRewardRows();
	container.RewardsFrame.Label:SetShown(numRewardRows > 0);
	self.ScrollFrame:UpdateScrollChildRect();
	self:AdjustRewardsFrameContainer();
end

function KT_QuestLogQuestDetailsMixin:AdjustRewardsFrameContainer()
	local container = self.RewardsFrameContainer;
	if container.isFixedHeight then
		return;
	end

	local scrollRange = self.ScrollFrame:GetVerticalScrollRange();
	local rewardsHeight = self.RewardsFrameContainer.RewardsFrame:GetHeight();
	local numRewardRows = KT_QuestInfo_GetNumRewardRows();

	if container.isFixedHeight == nil then
		container.isFixedHeight = scrollRange == 0 or numRewardRows <= 1;
		if container.isFixedHeight then
			-- no further adjusting needed, can display entire reward frame
			self.RewardsFrameContainer:SetHeight(rewardsHeight);
			return;
		end
	end

	local offset = self.ScrollFrame:GetVerticalScroll();
	local pixelsToHide = scrollRange - offset;
	local containerHeight = rewardsHeight - pixelsToHide;
	local minHeight = 124;	-- want it where it's clear there are more rewards past 1st row
	if containerHeight < minHeight then
		containerHeight = minHeight;
	end
	self.RewardsFrameContainer:SetHeight(containerHeight);
end

function KT_QuestMapFrame_ShowQuestDetails(questID)
    if not QuestMapFrame.DetailsFrame.questID then
        EventRegistry:TriggerEvent("QuestLog.HideCampaignOverview")
    end
    C_QuestLog.SetSelectedQuest(questID);
    local detailsFrame = KT_QuestMapFrame.DetailsFrame;
    detailsFrame.questID = questID;
    --WorldMapFrame:SetFocusedQuestID(questID);  -- MSA
    KT_QuestInfo_Display(KT_QUEST_TEMPLATE_MAP_DETAILS, detailsFrame.ScrollFrame.Contents);
    KT_QuestInfo_Display(KT_QUEST_TEMPLATE_MAP_REWARDS, detailsFrame.RewardsFrameContainer.RewardsFrame, nil, nil, true);
    detailsFrame:AdjustBackgroundTexture(detailsFrame.SealMaterialBG);
    detailsFrame.BackFrame.AccountCompletedNotice:Refresh(questID);

    detailsFrame.ScrollFrame.ScrollBar:ScrollToBegin();

    -- MSA
    --[[local mapFrame = WorldMapFrame;
	local questPortrait, questPortraitText, questPortraitName, questPortraitMount, questPortraitModelSceneID = C_QuestLog.GetQuestLogPortraitGiver();
	if (questPortrait and questPortrait ~= 0 and QuestLogShouldShowPortrait()) then
		local useCompactDescription = false;
		QuestFrame_ShowQuestPortrait(mapFrame, questPortrait, questPortraitMount, questPortraitModelSceneID, questPortraitText, questPortraitName, 1, -43, useCompactDescription);
		QuestModelScene:SetFrameStrata("HIGH");
		QuestModelScene:SetFrameLevel(1000);
	else
		QuestFrame_HideQuestPortrait();
	end]]

    -- height
    local height;
    if ( KT_MapQuestInfoRewardsFrame:IsShown() ) then
        height = KT_MapQuestInfoRewardsFrame:GetHeight() + 62;
    else
        height = 59;
    end
    detailsFrame:SetRewardsHeight(height);

    --QuestMapFrame.QuestsFrame.ScrollFrame:Hide();  -- MSA
    KT_QuestMapFrame:Show()  -- MSA
    detailsFrame:Show();

    -- save current view
    detailsFrame.returnMapID = WorldMapFrame:GetMapID();

    -- destination/waypoint
    local ignoreWaypoints = true  -- MSA
    -- MSA
    --[[if C_QuestLog.GetNextWaypoint(questID) then
        ignoreWaypoints = ignoreWaypointsByQuestID[questID];
        detailsFrame.DestinationMapButton:SetShown(not ignoreWaypoints);
        detailsFrame.WaypointMapButton:SetShown(ignoreWaypoints);
    else
        detailsFrame.DestinationMapButton:Hide();
        detailsFrame.WaypointMapButton:Hide();
    end]]

    local mapID = GetQuestUiMapID(questID, ignoreWaypoints);
    detailsFrame.questMapID = mapID;
    if ( mapID ~= 0 ) then
        C_Map.OpenWorldMap(mapID)  -- MSA
        EventRegistry:TriggerEvent("MapCanvas.PingQuestID", questID);
    end

    KT_QuestMapFrame_UpdateQuestDetailsButtons();
    KT_QuestMapFrame_AdjustPathButtons();

    StaticPopup_Hide("ABANDON_QUEST");
    StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
end

function KT_QuestMapFrame_CloseQuestDetails(optPortraitOwnerCheckFrame)
    --KT_QuestMapFrame.QuestsFrame.ScrollFrame:Show();  -- MSA
    KT_QuestMapFrame:Hide()  -- MSA
    KT_QuestMapFrame.DetailsFrame:Hide();
    KT_QuestMapFrame.DetailsFrame.questID = nil;
    --WorldMapFrame:ClearFocusedQuestID();  -- MSA
    KT_QuestMapFrame.DetailsFrame.returnMapID = nil;
    KT_QuestMapFrame.DetailsFrame.questMapID = nil;
    --QuestMapFrame_UpdateAll();  -- MSA
    --QuestFrame_HideQuestPortrait(optPortraitOwnerCheckFrame);  -- MSA

    StaticPopup_Hide("ABANDON_QUEST");
    StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
end

function KT_QuestMapFrame_UpdateSuperTrackedQuest(self)
    local questID = C_SuperTrack.GetSuperTrackedQuestID();
	if ( questID ~= KT_QuestMapFrame.DetailsFrame.questID ) then
		KT_QuestMapFrame_CloseQuestDetails();  -- MSA
	end
end

function KT_QuestMapFrame_UpdateQuestDetailsButtons()
	local questID = C_QuestLog.GetSelectedQuest();

	local isQuestDisabled = C_QuestLog.IsQuestDisabledForSession(questID);

	local canAbandon = not isQuestDisabled and C_QuestLog.CanAbandonQuest(questID);
	KT_QuestMapFrame.DetailsFrame.AbandonButton:SetEnabled(canAbandon);
	--QuestLogPopupDetailFrame.AbandonButton:SetEnabled(canAbandon);  -- MSA

	local isWatched = QuestUtils_IsQuestWatched(questID);
	if isWatched then
		KT_QuestMapFrame.DetailsFrame.TrackButton:SetText(UNTRACK_QUEST_ABBREV);
		--QuestLogPopupDetailFrame.TrackButton:SetText(UNTRACK_QUEST_ABBREV);  -- MSA
	else
		KT_QuestMapFrame.DetailsFrame.TrackButton:SetText(TRACK_QUEST_ABBREV);
		--QuestLogPopupDetailFrame.TrackButton:SetText(TRACK_QUEST_ABBREV);  -- MSA
	end

	-- Need to be able to remove watch if the quest got disabled
	local canRemoveQuestWatch = QuestUtil.CanRemoveQuestWatch();
	local enableTrackButton = (isWatched and canRemoveQuestWatch) or (not isWatched and not isQuestDisabled);
	KT_QuestMapFrame.DetailsFrame.TrackButton:SetEnabled(enableTrackButton);
	--QuestLogPopupDetailFrame.TrackButton:SetEnabled(enableTrackButton);  -- MSA

	local enableShare = not isQuestDisabled and C_QuestLog.IsPushableQuest(questID) and IsInGroup();
	KT_QuestMapFrame.DetailsFrame.ShareButton:SetEnabled(enableShare);
	--QuestLogPopupDetailFrame.ShareButton:SetEnabled(enableShare);  -- MSA
end

function KT_QuestMapFrame_ReturnFromQuestDetails()
	if ( KT_QuestMapFrame.DetailsFrame.returnMapID ) then
        C_Map.OpenWorldMap(KT_QuestMapFrame.DetailsFrame.returnMapID)
	end
	KT_QuestMapFrame_CloseQuestDetails();  -- MSA
end

function KT_QuestMapFrame_GetDetailQuestID()
	return KT_QuestMapFrame.DetailsFrame.questID;
end

function KT_QuestMapQuestOptions_TrackQuest(questID)
	if QuestUtils_IsQuestWatched(questID) then
		if QuestUtil.CanRemoveQuestWatch() then
			C_QuestLog.RemoveQuestWatch(questID);
		end
	else
		if C_QuestLog.GetNumQuestWatches() >= Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
			UIErrorsFrame:AddMessage(OBJECTIVES_WATCH_TOO_MANY, 1.0, 0.1, 0.1, 1.0);
		else
			C_QuestLog.AddQuestWatch(questID);
		end
	end
end

function KT_QuestMapQuestOptions_ShareQuest(questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPushQuest(questLogIndex);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end

local function BuildItemNames(items)
	if items then
		local itemNames = {};
		local item = Item:CreateFromItemID(0);

		for itemIndex, itemID in ipairs(items) do
			item:SetItemID(itemID);
			local itemName = item:GetItemName();
			if itemName then
				table.insert(itemNames, itemName);
			end
		end

		if #itemNames > 0 then
			return table.concat(itemNames, ", ");
		end
	end

	return nil;
end

function KT_QuestMapQuestOptions_AbandonQuest(questID)
	local oldSelectedQuest = C_QuestLog.GetSelectedQuest();
	C_QuestLog.SetSelectedQuest(questID);
	C_QuestLog.SetAbandonQuest();

	local items = BuildItemNames(C_QuestLog.GetAbandonQuestItems());
	local title = QuestUtils_GetQuestName(C_QuestLog.GetAbandonQuest());
	if ( items ) then
		StaticPopup_Hide("ABANDON_QUEST");
		StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", title, items);
	else
		StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
		StaticPopup_Show("ABANDON_QUEST", title);
	end
	C_QuestLog.SetSelectedQuest(oldSelectedQuest);
end