KT_OBJECTIVE_TRACKER_COLOR = {
	["Normal"] = { r = 0.8, g = 0.8, b = 0.8 },
	["NormalHighlight"] = { r = HIGHLIGHT_FONT_COLOR.r, g = HIGHLIGHT_FONT_COLOR.g, b = HIGHLIGHT_FONT_COLOR.b },
	["Failed"] = { r = DIM_RED_FONT_COLOR.r, g = DIM_RED_FONT_COLOR.g, b = DIM_RED_FONT_COLOR.b },
	["FailedHighlight"] = { r = RED_FONT_COLOR.r, g = RED_FONT_COLOR.g, b = RED_FONT_COLOR.b },
	["Header"] = { r = OBJECTIVE_TRACKER_BLOCK_HEADER_COLOR.r, g = OBJECTIVE_TRACKER_BLOCK_HEADER_COLOR.g, b = OBJECTIVE_TRACKER_BLOCK_HEADER_COLOR.b },
	["HeaderHighlight"] = { r = NORMAL_FONT_COLOR.r, g = NORMAL_FONT_COLOR.g, b = NORMAL_FONT_COLOR.b },
	["Complete"] = { r = 0.6, g = 0.6, b = 0.6 },
	["TimeLeft"] = { r = DIM_RED_FONT_COLOR.r, g = DIM_RED_FONT_COLOR.g, b = DIM_RED_FONT_COLOR.b },
	["TimeLeftHighlight"] = { r = RED_FONT_COLOR.r, g = RED_FONT_COLOR.g, b = RED_FONT_COLOR.b },
};
	KT_OBJECTIVE_TRACKER_COLOR["Normal"].reverse = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"];
	KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Normal"];
	KT_OBJECTIVE_TRACKER_COLOR["Failed"].reverse = KT_OBJECTIVE_TRACKER_COLOR["FailedHighlight"];
	KT_OBJECTIVE_TRACKER_COLOR["FailedHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Failed"];
	KT_OBJECTIVE_TRACKER_COLOR["Header"].reverse = KT_OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
	KT_OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Header"];
	KT_OBJECTIVE_TRACKER_COLOR["TimeLeft"].reverse = KT_OBJECTIVE_TRACKER_COLOR["TimeLeftHighlight"];
	KT_OBJECTIVE_TRACKER_COLOR["TimeLeftHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft"];

KT_OBJECTIVE_DASH_STYLE_SHOW = 1;
KT_OBJECTIVE_DASH_STYLE_HIDE = 2;
KT_OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE = 3;

-- *****************************************************************************************************
-- ***** QUEST ITEM BUTTON
-- *****************************************************************************************************

KT_QuestObjectiveItemButtonMixin = { };

function KT_QuestObjectiveItemButtonMixin:OnLoad()
	self:RegisterForClicks("AnyUp");
end

function KT_QuestObjectiveItemButtonMixin:OnEvent(event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		self.rangeTimer = -1;
	elseif event == "BAG_UPDATE_COOLDOWN" then
		KT_QuestObjectiveItemButtonMixin.UpdateCooldown(self);  -- MSA (fix)
	elseif event == "PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED" then
		local questID, inside = ...;
		KT_QuestObjectiveItemButtonMixin.UpdateInsideBlob(self, questID, inside);  -- MSA (fix)
	end
end

function KT_QuestObjectiveItemButtonMixin:OnUpdate(elapsed)
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if rangeTimer then
		local questLogIndex = self:GetAttribute("questLogIndex");
		rangeTimer = rangeTimer - elapsed;
		if rangeTimer <= 0 then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);
			if not charges or charges ~= self.charges then
				KT_QuestObjectiveTracker:MarkDirty();
				return;
			end
			local count = self.HotKey;
			local valid = IsQuestLogSpecialItemInRange(questLogIndex);
			if valid == 0 then
				count:Show();
				count:SetVertexColor(1.0, 0.1, 0.1);
			elseif valid == 1 then
				count:Show();
				count:SetVertexColor(0.6, 0.6, 0.6);
			else
				count:Hide();
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end

		self.rangeTimer = rangeTimer;
	end
end

function KT_QuestObjectiveItemButtonMixin:OnShow()
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED");
end

function KT_QuestObjectiveItemButtonMixin:OnHide()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED");
end

function KT_QuestObjectiveItemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local questLogIndex = self:GetAttribute("questLogIndex");
	GameTooltip:SetQuestLogSpecialItem(questLogIndex);
end

function KT_QuestObjectiveItemButtonMixin:OnClick(button)
	local questLogIndex = self:GetAttribute("questLogIndex");
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);
		if link then
			ChatEdit_InsertLink(link);
		end
	else
		UseQuestLogSpecialItem(questLogIndex);
	end
end

function KT_QuestObjectiveItemButtonMixin:SetUp(questLogIndex)
	local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);
	self:SetAttribute("questLogIndex", questLogIndex);
	self:SetAttribute("questID", C_QuestLog.GetQuestIDForLogIndex(questLogIndex));
	self.charges = charges;
	self.rangeTimer = -1;
	SetItemButtonTexture(self, item);
	SetItemButtonCount(self, charges);
	self:UpdateCooldown(self);
	self:CheckUpdateInsideBlob();
end

function KT_QuestObjectiveItemButtonMixin:UpdateCooldown()
	local questLogIndex = self:GetAttribute("questLogIndex");
	if not questLogIndex then return end  -- MSA

	local start, duration, enable = GetQuestLogSpecialItemCooldown(questLogIndex);
	if start then
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
		if duration > 0 and enable == 0 then
			SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(self, 1, 1, 1);
		end
	end
end

function KT_QuestObjectiveItemButtonMixin:CheckUpdateInsideBlob()
	local questID = self:GetAttribute("questID");
	KT_QuestObjectiveItemButtonMixin.UpdateInsideBlob(self, questID, C_Minimap.IsInsideQuestBlob(questID));  -- MSA (fix)
end

function KT_QuestObjectiveItemButtonMixin:UpdateInsideBlob(questID, inside)
	if questID == self:GetAttribute("questID") then
		self.Glow:SetShown(inside); -- maybe fade out anim and then stop glow
		if inside then
			self.GlowAnim:Play();
		else
			self.GlowAnim:Stop();
		end
	end
end

-- *****************************************************************************************************
-- ***** FIND GROUP BUTTON
-- *****************************************************************************************************

KT_QuestObjectiveFindGroupButtonMixin = { };

function KT_QuestObjectiveFindGroupButtonMixin:SetUp(questID)
	self:SetAttribute("questID", questID);
end

function KT_QuestObjectiveFindGroupButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self, "CENTER", -2, -1);
	end
end

function KT_QuestObjectiveFindGroupButtonMixin:OnMouseUp()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self, "CENTER", -1, 0);
	end
end

function KT_QuestObjectiveFindGroupButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:AddLine(TOOLTIP_TRACKER_FIND_GROUP_BUTTON, HIGHLIGHT_FONT_COLOR:GetRGB());

	GameTooltip:Show();
end

function KT_QuestObjectiveFindGroupButtonMixin:OnClick()
	local isFromGreenEyeButton = true;
	local questID = self:GetAttribute("questID");
	-- We only want green eye button groups to display the create a group button if there are already groups there.
	LFGListUtil_FindQuestGroup(questID, isFromGreenEyeButton);
end

-- *****************************************************************************************************
-- ***** REWARDS TOAST
-- *****************************************************************************************************

KT_ObjectiveTrackerRewardsToastMixin = {};

function KT_ObjectiveTrackerRewardsToastMixin:OnLoad()
	self.framePool = CreateFramePool("FRAME", self, "KT_ObjectiveTrackerRewardFrameTemplate");
	self.Anim:SetScript("OnFinished", GenerateClosure(self.OnAnimateRewardsDone, self));
end

--[[ rewards is a table containing 1 table per reward with this data
	{
		count,							-- how much of the reward is being granted
		font,							-- font for the reward name
		label,							-- item name of the reward
		texture,						-- item icon
		overlay							-- overlay icon (can be nil) 
	}
]]--

function KT_ObjectiveTrackerRewardsToastMixin:ShowRewards(rewards, module, block, headerText, callback)
	self.Header:SetText(headerText or REWARDS);
	self.callback = callback;
	
	self.framePool:ReleaseAll();
	
	local lastFrame;
	for i, rewardData in ipairs(rewards) do
		local frame = self.framePool:Acquire();
		if lastFrame then
			frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -4);
		else
			frame:SetPoint("TOPLEFT", self.RewardsTop, "BOTTOMLEFT", 25, 0);
		end
		
		if rewardData.count > 1 then
			frame.Count:Show();
			frame.Count:SetText(rewardData.count);
		else
			frame.Count:Hide();
		end
		frame.Label:SetFontObject(rewardData.font);
		frame.Label:SetText(rewardData.label);
		frame.ItemIcon:SetTexture(rewardData.texture);
		if rewardData.overlay then
			frame.ItemOverlay:SetTexture(rewardData.overlay);
			frame.ItemOverlay:Show();
		else
			frame.ItemOverlay:Hide();
		end
		frame:Show();
		frame.Anim:Restart();
			
		lastFrame = frame;
	end

	self:ClearAllPoints();
	local container = KT_ObjectiveTrackerManager:GetContainerForModule(module);
	if container:IsCollapsed() then
		self:SetPoint("TOPRIGHT", container, "TOPLEFT", 20, 0);
	elseif block then
		self:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4);
	elseif module:HasContents() then
		if module:IsCollapsed() then
			self:SetPoint("TOPRIGHT", module.Header, "TOPLEFT");
		else
			self:SetPoint("TOPRIGHT", module:GetLastBlock(), "BOTTOMLEFT");
		end
	else
		self:SetPoint("TOPRIGHT", container, "BOTTOMLEFT", 20, 16);
	end
	
	self:Show();
	local contentsHeight = 12 + #rewards * 36;
	self.Anim.RewardsBottomAnim:SetOffset(0, -contentsHeight);
	self.Anim.RewardsShadowAnim:SetScaleTo(0.8, contentsHeight / 16);
	self.Anim:Play();
	PlaySound(SOUNDKIT.UI_BONUS_EVENT_SYSTEM_VIGNETTES);
end	

function KT_ObjectiveTrackerRewardsToastMixin:OnAnimateRewardsDone()
	if self.callback then
		self.callback();
		self.callback = nil;
	end
	KT_ObjectiveTrackerManager:HideRewardsToast(self);
end

-- *****************************************************************************************************
-- ***** LINE
-- *****************************************************************************************************

KT_ObjectiveTrackerLineMixin = {};

function KT_ObjectiveTrackerLineMixin:OnLoad()
	-- override in your mixin
end

function KT_ObjectiveTrackerLineMixin:OnHyperlinkClick(link, text, button)
	SetItemRef(link, text, button);
end

function KT_ObjectiveTrackerLineMixin:UpdateModule()
	self.parentBlock.parentModule:MarkDirty();
end

-- *****************************************************************************************************
-- ***** PROGRESS BARS
-- *****************************************************************************************************

KT_ObjectiveTrackerProgressBarMixin = { };

function KT_ObjectiveTrackerProgressBarMixin:SetPercent(percent)
	self.Bar:SetValue(percent);
	self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
end

-- *****************************************************************************************************
-- ***** TIMER BARS
-- *****************************************************************************************************

KT_ObjectiveTrackerTimerBarMixin = { };

function KT_ObjectiveTrackerTimerBarMixin:OnUpdate(elapsed)
	local timeNow = GetTime();
	local timeRemaining = self.duration - (timeNow - self.startTime);
	self.Bar:SetValue(timeRemaining);
	if timeRemaining < 0 then
		-- hold at 0 for a moment
		if timeRemaining > -1 then
			timeRemaining = 0;
		else
			local module = self.parentLine.parentBlock.parentModule;
			module:MarkDirty();
		end
	end
	self.Label:SetText(SecondsToClock(timeRemaining));
	self.Label:SetTextColor(self:GetTextColor(timeRemaining));
end

local START_PERCENTAGE_YELLOW = .66;
local START_PERCENTAGE_RED = .33;

function KT_ObjectiveTrackerTimerBarMixin:GetTextColor(timeRemaining)
	local elapsed = self.duration - timeRemaining;
	local percentageLeft = 1 - ( elapsed / self.duration )
	if percentageLeft > START_PERCENTAGE_YELLOW then
		return 1, 1, 1;
	elseif percentageLeft > START_PERCENTAGE_RED then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED; -- Fade to red by eliminating green
		return 1, greenOffset, 0;
	end
end

-- *****************************************************************************************************
-- ***** SLIDING
-- *****************************************************************************************************

KT_ObjectiveTrackerSlidingState = EnumUtil.MakeEnum(
	"None",
	"SlideIn",
	"SlideOut"
);

KT_ObjectiveTrackerSlidingMixin = { };

function KT_ObjectiveTrackerSlidingMixin:IsSliding()
	return not not self.slideInfo;
end

--[[ slideInfo table layout
	duration		: seconds
	travel			: distance, positive means scroll down from the top, negative means move up
	adjustModule	: boolean, whether the module should resize along (otherwise it will be the final height)
	startDelay		: seconds
	endDelay		: seconds
--]]
function KT_ObjectiveTrackerSlidingMixin:Slide(slideInfo)
	if self.slideInfo then
		return;
	end

	self.slideInfo = slideInfo;

	if slideInfo.startDelay then
		slideInfo.elapsed = -slideInfo.startDelay;
	else
		slideInfo.elapsed = 0;
	end

	-- if sliding down, update with progress 0 now
	if slideInfo.travel > 0 then
		self:UpdateSlideProgress(0);
	end

	if self.isModule then
		self.ContentsFrame:SetClipsChildren(true);
	else
		self:SetClipsChildren(true);
	end
	self:SetScript("OnUpdate", self.OnSlideUpdate);
end

function KT_ObjectiveTrackerSlidingMixin:OnSlideUpdate(elapsed)
	local slideInfo = self.slideInfo;
	slideInfo.elapsed = slideInfo.elapsed + elapsed;

	-- this means there's a start delay
	if slideInfo.elapsed <= 0 then
		return;
	end

	if slideInfo.elapsed >= slideInfo.duration then
		if not slideInfo.endDelay or slideInfo.elapsed >= slideInfo.duration + slideInfo.endDelay then
			local finished = true;
			self:EndSlide(finished);
		end
	else
		local progress = min(slideInfo.elapsed, slideInfo.duration) / slideInfo.duration;
		self:UpdateSlideProgress(progress);
	end
end

function KT_ObjectiveTrackerSlidingMixin:UpdateSlideProgress(progress)
	local slideInfo = self.slideInfo;
	local delta;
	if slideInfo.travel > 0 then
		delta = slideInfo.travel * (1 - progress);
	else
		delta = -slideInfo.travel * progress;
	end

	if not self.isModule then
		self:SetHeight(self.height - delta);
	end

	self:AdjustSlideAnchor(delta);
	if slideInfo.adjustModule then
		local module = self.isModule and self or self.parentModule;
		module:SetHeightModifier(self, -delta);
	end
end

function KT_ObjectiveTrackerSlidingMixin:EndSlide(finished)
	if not self.slideInfo then
		return;
	end
	self:AdjustSlideAnchor(0);
	if self.isModule then
		self.ContentsFrame:SetClipsChildren(false);
	else
		self:SetHeight(self.height);
		self:SetClipsChildren(false);
	end
	self:SetScript("OnUpdate", nil);
	if self.slideInfo.adjustModule then
		local module = self.isModule and self or self.parentModule;
		module:ClearHeightModifier(self);
	end
	local slideOut = self.slideInfo.travel < 0;
	self.slideInfo = nil;
	self:OnEndSlide(slideOut, finished);
end

function KT_ObjectiveTrackerSlidingMixin:AdjustSlideAnchor(offsetY)
	-- override in your mixin
end

function KT_ObjectiveTrackerSlidingMixin:OnEndSlide(slideOut, finished)
	-- override in your mixin
end