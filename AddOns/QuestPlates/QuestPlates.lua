--------------------
-- ICON SETTINGS

-- Settings can be referenced by typing "QuestPlateSettings." followed by the name of the setting.
-- For example, to move the icon 10 pixels down, you can type the following into the chat:
--   /run QuestPlateSettings.OffsetY = -10
-- To move the icon from the left to the right of the nameplate, you can type this:
--   /run QuestPlateSettings.AnchorPoint = 'LEFT'; QuestPlateSettings.RelativeTo = 'RIGHT'

-- After changing your settings, you can type /reload to save and apply them
-- If you wish to wipe out any changes you've made and return to the default settings, you can type:
--   /run QuestPlateSettings = nil
-- And then /reload your ui

QuestPlateSettings = {
	AnchorPoint = 'RIGHT', -- Point of icon to anchor to nameplate (CENTER, LEFT, RIGHT, TOP, BOTTOM)
	RelativeTo = 'LEFT', -- Point of nameplate to anchor icon to (CENTER, LEFT, RIGHT, TOP, BOTTOM)
	OffsetX = 0, -- Horizontal offset for icon (from anchor point)
	OffsetY = 0, -- Vertical offset for icon
	IconScale = 1, -- Scale for icon
}

-- Uncomment these lines if you want to enable them, or set to 0 to turn them off
-- SetCVar('showQuestUnitCircles', 1) -- Enables subtle glow under quest mobs
-- SetCVar('UnitNameFriendlySpecialNPCName', 1) -- Show name for quest objectives, even out of range of nameplates

-- END OF SETTINGS
--------------------

local addonName, addon = ...

local E = addon:Eve()

-- function E:VARIABLES_LOADED()
	-- SetCVar('showQuestTrackingTooltips', '1') -- Required for this addon to function, don't turn this off
-- end

local TextureAtlases = {
	['item'] = 'Banker', -- bag icon, you have to loot something for this quest
	--['monster'] = '', -- you must kill or interact with units for this quest
}

-- C_TaskQuest.GetQuestsForPlayerByMapID(GetCurrentMapAreaID())
local ActiveWorldQuests = {
	-- [questName] = questID ?
}

do
	function E:PLAYER_LOGIN()
		-- local areaID = GetCurrentMapAreaID()
		local uiMapID = C_Map.GetBestMapForUnit('player')
		if uiMapID then
			for k, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) or {}) do
				if task.inProgress and task.questID then -- 暫時修正
					-- track active world quests
					local questID = task.questID
					local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
					if questName then
						-- print(k, questID, questName)
						ActiveWorldQuests[ questName ] = questID
					end
				end
			end
		end
	end

	function E:QUEST_ACCEPTED(questLogIndex, questID, ...)
		if questID and C_QuestLog.IsQuestTask(questID) then
			-- print('TASK_QUEST_ACCEPTED', questID, questLogIndex, GetQuestLogTitle(questLogIndex))
			local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
			if questName then
				ActiveWorldQuests[ questName ] = questID
			end
		else
			-- print('QUEST_ACCEPTED', questID, questLogIndex, GetQuestLogTitle(questLogIndex))
		end
		E:UNIT_QUEST_LOG_CHANGED()
	end
	
	function E:QUEST_REMOVED(questID)
		local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
		if questName and ActiveWorldQuests[ questName ] then
			ActiveWorldQuests[ questName ] = nil
			-- print('TASK_QUEST_REMOVED', questID, questName)
			-- get task progress when it's updated to display on the nameplate
			-- C_TaskQuest.GetQuestProgressBarInfo
		end
		E:UNIT_QUEST_LOG_CHANGED()
	end
	
	function E:QUEST_WATCH_LIST_CHANGED(questID, added)
		E:QUEST_ACCEPTED(nil, questID)
	end
end

local OurName = UnitName('player')
--local QuestPlateTooltip = CreateFrame('GameTooltip', 'QuestPlateTooltip', nil, 'GameTooltipTemplate')
QuestLogIndex = {} -- [questName] = questLogIndex, this is to "quickly" look up quests from its name in the tooltip

function GetQuestProgress(unitID)
	-- TODO: Refactor this mess
	if not C_QuestLog.UnitIsRelatedToActiveQuest(unitID) then return end

	local tooltipData = C_TooltipInfo.GetUnit(unitID)
	local progressGlob -- concatenated glob of quest text
	local questType -- 1 for player, 2 for group
	local objectiveCount = 0
	local questTexture -- if usable item
	local questLogIndex -- should generally be set, index usable with questlog functions
	local questID
	for i = 3, #tooltipData.lines do
		local line = tooltipData.lines[i]
		-- TooltipUtil.SurfaceArgs(line)

		if line.type == 17 and line.id then -- Tooltip line is a quest header..?
			--if not text then return end
			local text, objectiveType, finished = GetQuestObjectiveInfo(line.id, 1, false)
			questID = questID or line.id or text and ActiveWorldQuests[ text ]
			--local playerName, progressText = strmatch(text, '^(.-)(.+)$') -- nil or '' if 1 is missing but 2 is there
			local playerName = ""
			local progressText = text
			local isQuestText = not not progressText
			
			-- todo: if multiple entries are present, ONLY read the quest objectives for the player
			-- if a name is listed in the pattern then we must be in a group
			if playerName and playerName ~= '' and playerName ~= OurName then -- quest is for another group member
				if not questType then
					questType = 2
				end
			else
				if isQuestText then
					local x, y = strmatch(progressText, '(%d+)/(%d+)')
					if x and y then
						local numLeft = y - x
						if numLeft > objectiveCount then -- track highest number of objectives
							objectiveCount = numLeft
						end
					else
						local progress = tonumber(strmatch(progressText, '([%d%.]+)%%')) -- tooltip actually contains progress %
						if progress and progress <= 100 then
							local questID = ActiveWorldQuests[ text ] -- not a guarantee
							local questType = 3
							return text, questType, ceil(100 - progress), questID
						end
					end
					--local x, y = strmatch(progressText, '(%d+)/(%d+)$')
					if not x or (x and y and x ~= y) then
						progressGlob = progressGlob and progressGlob .. '\n' .. progressText or progressText
					end
				elseif ActiveWorldQuests[text] then
					local questID = ActiveWorldQuests[ text ]
					local progress = C_TaskQuest.GetQuestProgressBarInfo(questID) -- or GetQuestProgressBarPercent(questID) -- not sure what the difference is between these functions
					if progress then
						local questType = 3 -- progress bar
						return text, questType, ceil(100 - progress), questID
					end
				elseif QuestLogIndex[text] then
					questLogIndex = QuestLogIndex[text]
				end
			end
		end
	end
	
	return progressGlob, progressGlob and 1 or questType, objectiveCount, questLogIndex, questID
end

local QuestPlates = {} -- [plate] = f
function E:OnNewPlate(f, plate)
	local frame = CreateFrame('frame', nil, f)
	frame:Hide()
	frame:SetAllPoints(f)
	QuestPlates[plate] = frame
	
	local icon = frame:CreateTexture(nil, nil, nil, 0)
	icon:SetSize(28, 22)
	icon:SetTexture('Interface/QuestFrame/AutoQuest-Parts')
	icon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)
	icon:SetPoint(QuestPlateSettings.AnchorPoint or 'RIGHT', frame, QuestPlateSettings.RelativeTo or 'LEFT', (QuestPlateSettings.OffsetX or 0) / (QuestPlateSettings.IconScale or 1), (QuestPlateSettings.OffsetY or 0) / (QuestPlateSettings.IconScale or 1))
	frame:SetScale(QuestPlateSettings.IconScale or 1)
	frame.jellybean = icon
	
	local itemTexture = frame:CreateTexture(nil, nil, nil, 1)
	itemTexture:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
	itemTexture:SetSize(16, 16)
	itemTexture:SetMask('Interface/CharacterFrame/TempPortraitAlphaMask')
	itemTexture:Hide()
	frame.itemTexture = itemTexture
	
	-- Loot icon, display if mob needs to be looted for quest item
	local lootIcon = frame:CreateTexture(nil, nil, nil, 1)
	lootIcon:SetAtlas('Banker')
	lootIcon:SetSize(16, 16)
	lootIcon:SetPoint('TOPLEFT', icon, 'BOTTOMRIGHT', -12, 12)
	lootIcon:Hide()
	frame.lootIcon = lootIcon
	
	local iconText = frame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
	iconText:SetPoint('CENTER', icon, 0.8, 0)
	iconText:SetShadowOffset(1, -1)
	--iconText:SetText(math.random(22))
	iconText:SetTextColor(1,.82,0)
	frame.iconText = iconText
	
	-- todo: add setting for displaying quest text again
	local questText = frame:CreateFontString(nil, 'BACKGROUND', 'GameFontWhiteSmall')
	questText:SetPoint('TOP', frame, 'BOTTOM')
	questText:SetShadowOffset(1, -1)
	questText:Hide()
	frame.questText = questText
	
	local qmark = frame:CreateTexture(nil, 'OVERLAY')
	qmark:SetSize(28, 28)
	qmark:SetPoint('CENTER', icon)
	qmark:SetTexture('Interface/WorldMap/UI-WorldMap-QuestIcon')
	qmark:SetTexCoord(0, 0.56, 0.5, 1)
	qmark:SetAlpha(0)
	
	local duration = 1
	local group = qmark:CreateAnimationGroup()
	local alpha = group:CreateAnimation('Alpha')
	alpha:SetOrder(1)
	alpha:SetFromAlpha(0)
	alpha:SetToAlpha(1)
	alpha:SetDuration(0)
	
	local translation = group:CreateAnimation('Translation')
	translation:SetOrder(1)
	translation:SetOffset(0, 20)
	translation:SetDuration(duration)
	translation:SetSmoothing('OUT')
	
	local alpha2 = group:CreateAnimation('Alpha')
	alpha2:SetOrder(1)
	alpha2:SetFromAlpha(1)
	alpha2:SetToAlpha(0)
	alpha2:SetDuration(duration)
	alpha2:SetSmoothing('OUT')
	
	frame.ani = group
	
	frame:HookScript('OnShow', function(self)
		group:Play()
	end)
	
end

local function UpdateQuestIcon(plate, unitID)
	local Q = QuestPlates[plate]
	local unitID = unitID or addon:GetUnitForPlate(plate)
	if not Q then return end
	
	local scenarioName, currentStage, numStages, flags, _, _, _, xp, money, scenarioType, _, textureKitID = C_Scenario.GetInfo()
	local inChallengeMode = (scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE)
	local guid = UnitGUID(unitID)
	if inChallengeMode and guid then -- C_MythicPlus.IsMythicPlusActive() and guid then
		Q:Hide()
		return
	end
	
	local progressGlob, questType, objectiveCount, questLogIndex, questID = GetQuestProgress(unitID)
	if progressGlob and questType ~= 2 then
		Q.questText:SetText(progressGlob or '')
		
		if questType == 3 then -- todo: progress bar
			Q.iconText:SetText(objectiveCount > 0 and objectiveCount or '?')
		else
			Q.iconText:SetText(objectiveCount > 0 and objectiveCount or '?')
		end

		if questType == 1 then
			Q.jellybean:SetDesaturated(false)
			Q.iconText:SetTextColor(1, .82, 0)
		elseif questType == 2 then
			Q.jellybean:SetDesaturated(true)
			Q.iconText:SetTextColor(1, 1, 1)
		elseif questType == 3 then
			Q.jellybean:SetDesaturated(false)
			Q.iconText:SetTextColor(0.2, 1, 1)
		end
		Q.itemTexture:Hide()
		Q.lootIcon:Hide()
		if questLogIndex or questID then
			if questID then
				for i = 1, 10 do
					local text, objectiveType, finished = GetQuestObjectiveInfo(questID, i, false)
					if not text then break end
					if not finished and (objectiveType == 'item' or objectiveType == 'object') then
						Q.lootIcon:Show()
					end
				end
			else
				local info = C_QuestLog.GetInfo(questLogIndex)
				if info then
					for i = 1, GetNumQuestLeaderBoards(questLogIndex) or 0 do
						local text, objectiveType, finished = GetQuestObjectiveInfo(info.questID, i, false)
						if not finished and (objectiveType == 'item' or objectiveType == 'object') then
							Q.lootIcon:Show()
						end
					end
				end
			end
			
			if questLogIndex then
				local link, itemTexture, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
				if link and itemTexture then
					Q.itemTexture:SetTexture(itemTexture)
					Q.itemTexture:Show()
				else
					Q.itemTexture:Hide()
				end
			end
		end
		
		if not Q:IsVisible() then
			Q.ani:Stop()
			Q:Show()
			Q.ani:Play()
		end
		--Q:Show()
	else
		Q:Hide()
	end	
end

function E:OnPlateShow(f, plate, unitID)
	UpdateQuestIcon(plate, unitID)
end

QuestObjectiveStrings = {}
local function CacheQuestIndexes()
	wipe(QuestLogIndex)
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do	
		-- for i = 1, GetNumQuestLogEntries() do if not select(4,GetQuestLogTitle(i)) and select(11,GetQuestLogTitle(i)) then QuestLogPushQuest(i) end end
		local info = C_QuestLog.GetInfo(i)		
		if info and not info.isHeader then
			QuestLogIndex[info.title] = i
			for objectiveID = 1, GetNumQuestLeaderBoards(i) or 0 do
				local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(info.questID, objectiveID, false)
				if objectiveText then
					QuestObjectiveStrings[ info.title .. objectiveText ] = {info.questID, objectiveID}
				end
			end
		end
	end
	
	for plate, f in pairs(addon:GetActiveNameplates()) do
		UpdateQuestIcon(plate, f._unitID)
	end
end

function E:UNIT_QUEST_LOG_CHANGED(unitID)
	if unitID == 'player' then
		CacheQuestIndexes()
	else	
		for plate in pairs(addon:GetActiveNameplates()) do
			UpdateQuestIcon(plate)
		end
	end
end

function E:QUEST_LOG_UPDATE()
	CacheQuestIndexes()
end
E:UnregisterEvent('QUEST_LOG_UPDATE')

function E:PLAYER_LEAVING_WORLD()
	E:UnregisterEvent('QUEST_LOG_UPDATE')
end

function E:PLAYER_ENTERING_WORLD()
	E:RegisterEvent('QUEST_LOG_UPDATE')
end

-- Reanchor any existing nameplate icons after settings load
function E:ADDON_LOADED(loadedAddon)
	if loadedAddon == addonName then
		for plate, f in pairs(addon:GetAllNameplates()) do
			local frame = QuestPlates[plate]
			if frame then
				frame.jellybean:ClearAllPoints()
				frame.jellybean:SetPoint(QuestPlateSettings.AnchorPoint or 'RIGHT', frame, QuestPlateSettings.RelativeTo or 'LEFT', (QuestPlateSettings.OffsetX or 0) / (QuestPlateSettings.IconScale or 1), (QuestPlateSettings.OffsetY or 0) / (QuestPlateSettings.IconScale or 1))
				frame:SetScale(QuestPlateSettings.IconScale or 1)
			end
		end	
		self:UnregisterEvent("ADDON_LOADED")
	end
end
