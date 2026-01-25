--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class QuestLog
local M = KT:NewModule("QuestLog")
KT.QuestLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar

local dropDownFrame

-- Internal ------------------------------------------------------------------------------------------------------------

local function QuestMapQuestOptionsDropDown_Initialize(self)
	local info = KT.Menu_CreateInfo()
	KT.Menu_AddTitle(C_QuestLog.GetTitleForQuestID(self.questID))

	local text, func
	if C_SuperTrack.GetSuperTrackedQuestID() ~= self.questID then
		text = SUPER_TRACK_QUEST
		func = function()
			C_SuperTrack.SetSuperTrackedQuestID(self.questID)
		end
	else
		text = STOP_SUPER_TRACK_QUEST
		func = function()
			C_SuperTrack.SetSuperTrackedQuestID(0)
		end
	end
	KT.Menu_AddButton(text, func)

	KT.Menu_AddButton(QuestUtils_IsQuestWatched(self.questID) and UNTRACK_QUEST or TRACK_QUEST, function()
		QuestMapQuestOptions_TrackQuest(self.questID)
	end, (dbChar.filterAuto[1] ~= nil))

	info.disabled = false

	KT.Menu_AddButton(SHARE_QUEST, function()
		QuestMapQuestOptions_ShareQuest(self.questID)
	end, (not C_QuestLog.IsPushableQuest(self.questID) or not IsInGroup()))

	info.disabled = false

	if C_QuestLog.CanAbandonQuest(self.questID) then
		KT.Menu_AddButton(ABANDON_QUEST, function()
			QuestMapQuestOptions_AbandonQuest(self.questID)
		end)
	end

	KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", self.questID)
end

local function SetHooks()
	-- DropDown - QuestMapFrame.lua
	function QuestMapLogTitleButton_OnClick(self, button)  -- R
		if ChatFrameUtil.TryInsertQuestLinkForQuestID(self.questID) then
			return;
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

		if IsShiftKeyDown() then
			self:ToggleTracking();
		else
			local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(self.questID);
			if not isDisabledQuest and button == "RightButton" then
				if ( self.questID ~= dropDownFrame.questID ) then
					MSA_CloseDropDownMenus();
				end
				dropDownFrame.questID = self.questID;
				MSA_ToggleDropDownMenu(1, nil, dropDownFrame, "cursor", 6, -6);
			elseif button == "LeftButton" then
				if IsModifiedClick(db.menuWowheadURLModifier) then
					KT:Alert_WowheadURL("quest", self.questID)
				elseif IsModifiedClick(db.menuYouTubeURLModifier) then
					KT:Alert_YouTubeURL("quest", self.questID)
				else
					QuestMapFrame_ShowQuestDetails(self.questID);
				end
			end
		end
	end

	hooksecurefunc("QuestMapQuestOptions_TrackQuest", function(questID)
		if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
			KT.QuestSuperTracking_ChooseClosestQuest()
		end
	end)
end

local function SetFrames()
	-- DropDown frame
	dropDownFrame = MSA_DropDownMenu_Create(addonName.."QuestLogDropDown", QuestMapFrame)
	dropDownFrame.questID = 0	-- for QuestMapQuestOptionsDropDown_Initialize
	MSA_DropDownMenu_Initialize(dropDownFrame, QuestMapQuestOptionsDropDown_Initialize, "MENU")
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = true

    if self.isAvailable then
        SetHooks()
        SetFrames()
    end
end