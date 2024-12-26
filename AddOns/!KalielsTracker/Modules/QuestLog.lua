--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local M = KT:NewModule("QuestLog")
KT.QuestLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

local dropDownFrame

--------------
-- Internal --
--------------

local function QuestMapQuestOptionsDropDown_Initialize(self)
	local info = MSA_DropDownMenu_CreateInfo();
	info.text = C_QuestLog.GetTitleForQuestID(self.questID);
	info.isTitle = 1;
	info.notCheckable = 1;
	MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

	info = MSA_DropDownMenu_CreateInfo();
	info.notCheckable = 1;

	if C_SuperTrack.GetSuperTrackedQuestID() ~= self.questID then
		info.text = SUPER_TRACK_QUEST
		info.func = function()
			C_SuperTrack.SetSuperTrackedQuestID(self.questID)
		end
	else
		info.text = STOP_SUPER_TRACK_QUEST
		info.func = function()
			C_SuperTrack.SetSuperTrackedQuestID(0)
		end
	end
	MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)

	info.text = QuestUtils_IsQuestWatched(self.questID) and UNTRACK_QUEST or TRACK_QUEST;
	info.disabled = (db.filterAuto[1])
	info.func = function()
		QuestMapQuestOptions_TrackQuest(self.questID)
	end;
	MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);

	info.disabled = false;

	info.text = SHARE_QUEST;
	info.func = function()
		QuestMapQuestOptions_ShareQuest(self.questID)
	end;
	info.disabled = (not C_QuestLog.IsPushableQuest(self.questID) or not IsInGroup());
	MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);

	info.disabled = false;

	if C_QuestLog.CanAbandonQuest(self.questID) then
		info.text = ABANDON_QUEST;
		info.func = function()
			QuestMapQuestOptions_AbandonQuest(self.questID)
		end;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);
	end

	if db.menuWowheadURL then
		info.text = "|cff33ff99Wowhead|r URL";
		info.func = KT.Alert_WowheadURL;
		info.arg1 = "quest";
		info.arg2 = self.questID;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
	end
end

local function SetHooks()
	-- DropDown - QuestMapFrame.lua
	function QuestMapLogTitleButton_OnClick(self, button)  -- R
		if ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
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
				MSA_ToggleDropDownMenu(1, nil, dropDownFrame, "cursor", 6, -6, nil, nil, MSA_DROPDOWNMENU_SHOW_TIME);
			elseif button == "LeftButton" then
				if IsModifiedClick(db.menuWowheadURLModifier) then
					KT:Alert_WowheadURL("quest", self.questID)
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

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	SetHooks()
	SetFrames()
end