local _, KT = ...

KT_ObjectiveTrackerManager = {
	containers = { },
	moduleToContainerMap = { },
	backgroundAlpha = 0,
};

function KT_ObjectiveTrackerManager:AssignModulesOrder(modules)
	for i, module in ipairs(modules) do
		module.uiOrder = i;
	end
end

function KT_ObjectiveTrackerManager:AddContainer(container)
	self.containers[container] = true;
	-- pass current alpha to new container
	container:OnAdded(self.backgroundAlpha);
end

function KT_ObjectiveTrackerManager:UpdateAll()
	for container in pairs(self.containers) do
		container:Update();
	end
end

function KT_ObjectiveTrackerManager:UpdateModule(module)
	-- check that module is assigned
	local container = self:GetContainerForModule(module);
	if container then
		module:MarkDirty();
	end
end

function KT_ObjectiveTrackerManager:GetContainerForModule(module)
	return self.moduleToContainerMap[module];
end

function KT_ObjectiveTrackerManager:SetModuleContainer(module, container)
	if not self.containers[container] then
		return;
	end

	local oldContainer = self:GetContainerForModule(module);
	if oldContainer then
		oldContainer:RemoveModule(module);
	end
	self.moduleToContainerMap[module] = container;
	container:AddModule(module);
end

function KT_ObjectiveTrackerManager:AcquireFrame(parent, template)
	if not self.poolCollection then
		self.poolCollection = CreateFramePoolCollection();
		self.templateTypes = { };
	end

	local templateType = self.templateTypes[template];
	if not templateType then
		local templateInfo = C_XMLUtil.GetTemplateInfo(template);
		templateType = templateInfo and templateInfo.type or "Frame";
		self.templateTypes[template] = templateType;
	end

	local pool = self.poolCollection:GetOrCreatePool(templateType, parent, template);
	local frame, isNew = pool:Acquire(template);
	if isNew then
		frame.template = template; -- stored so we can use it to free from the lookup later
	end
	return frame, isNew;
end

function KT_ObjectiveTrackerManager:ReleaseFrame(frame)
	self.poolCollection:Release(frame);
end

function KT_ObjectiveTrackerManager:SetOpacity(opacity)
	self.backgroundAlpha = (opacity or 0) / 100;
	for container in pairs(self.containers) do
		container:SetBackgroundAlpha(self.backgroundAlpha);
	end
end

local minLineFontSize = 12;
local maxLineFontSize = 20;
local headerExtraSize = 2;

function KT_ObjectiveTrackerManager:SetTextSize(textSize)
	if textSize < minLineFontSize or textSize > maxLineFontSize then
		return;
	end

	local lineFont = "KT_ObjectiveTrackerFont"..textSize;
	local headerFont = "KT_ObjectiveTrackerFont"..(textSize + headerExtraSize);
	KT_ObjectiveTrackerLineFont:SetFontObject(lineFont);
	KT_ObjectiveTrackerHeaderFont:SetFontObject(headerFont);
	self:UpdateAll();
end

-- Rewards Toast
function KT_ObjectiveTrackerManager:ShowRewardsToast(rewards, module, block, headerText, callback)
	if not rewards or #rewards == 0 then
		return;
	end

	if not self.rewardsToastPool then
		self.rewardsToastPool = CreateFramePool("FRAME", UIParent, "KT_ObjectiveTrackerRewardsToastTemplate");
	end
	
	local rewardsToast = self.rewardsToastPool:Acquire();
	rewardsToast.block = block;
	rewardsToast:SetFrameLevel(1000 + self.rewardsToastPool:GetNumActive() * 10);	
	rewardsToast:ShowRewards(rewards, module, block, headerText, callback);
end

function KT_ObjectiveTrackerManager:HideRewardsToast(rewardsToast)
	self.rewardsToastPool:Release(rewardsToast);
end

function KT_ObjectiveTrackerManager:HasRewardsToastForBlock(block)
	if not self.rewardsToastPool then
		return false;
	end

	for rewardsToast in self.rewardsToastPool:EnumerateActive() do
		if rewardsToast.block == block then
			return true;
		end
	end
	return false;
end

-- questPOI cvar

function KT_ObjectiveTrackerManager:UpdatePOIEnabled(enabled)
	self.questPOIEnabled = enabled;
	for module in pairs(self.questPOIEnabledModules) do
		module:MarkDirty();
	end
end

function KT_ObjectiveTrackerManager:OnVariablesLoaded()
	local enabled = GetCVarBool("questPOI");
	self:UpdatePOIEnabled(enabled);
end

function KT_ObjectiveTrackerManager:OnCVarChanged(cvar, value)
	if cvar == "questPOI" then
		local enabled = value == "1";
		self:UpdatePOIEnabled(enabled);
	end
end

function KT_ObjectiveTrackerManager:CanShowPOIs(module)
	if self.questPOIEnabled == nil then
		self.questPOIEnabled = GetCVarBool("questPOI");
		self.questPOIEnabledModules = { };
		EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
		CVarCallbackRegistry:RegisterCVarChangedCallback(self.OnCVarChanged, self);
	end

	if not self.questPOIEnabledModules[module] then
		self.questPOIEnabledModules[module] = true;
	end

	return self.questPOIEnabled;
end

function KT_ObjectiveTrackerManager:EnumerateActiveBlocksByTag(tag, callback)
	local ContainerEnumerateActiveModuleBlocksByTag = function(module)
		if module:MatchesTag(tag) then
			module:EnumerateActiveBlocks(callback);
		end
	end

	for container in pairs(self.containers) do
		container:ForEachModule(ContainerEnumerateActiveModuleBlocksByTag);
	end
end

function KT_ObjectiveTrackerManager:OnPlayerEnteringWorld(isInitialLogin, isReloadingUI)
	if not isInitialLogin and not isReloadingUI then
		return;
	end

	local orderedModules = {
		KT_ScenarioObjectiveTracker,
		KT_UIWidgetObjectiveTracker,
		KT_CampaignQuestObjectiveTracker,
		KT_QuestObjectiveTracker,
		KT_AdventureObjectiveTracker,
		KT_AchievementObjectiveTracker,
		KT_MonthlyActivitiesObjectiveTracker,
		KT_ProfessionsRecipeTracker,
		KT_BonusObjectiveTracker,
		KT_WorldQuestObjectiveTracker,
	};

	self:AssignModulesOrder(orderedModules);
	local mainTrackerFrame = KT_ObjectiveTrackerFrame;
	self:AddContainer(mainTrackerFrame);
	self:SetModuleContainer(KT_ScenarioObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_UIWidgetObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_CampaignQuestObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_QuestObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_AdventureObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_AchievementObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_MonthlyActivitiesObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_ProfessionsRecipeTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_BonusObjectiveTracker, mainTrackerFrame);
	self:SetModuleContainer(KT_WorldQuestObjectiveTracker, mainTrackerFrame);
end

--EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", KT_ObjectiveTrackerManager.OnPlayerEnteringWorld, KT_ObjectiveTrackerManager);  -- MSA