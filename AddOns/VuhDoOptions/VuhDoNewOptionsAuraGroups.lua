local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local tsort = table.sort;
local twipe = table.wipe;
local strfind = string.find;

VUHDO_AURA_GROUPS_SELECTED = nil;
VUHDO_AURA_GROUPS_COMBO_MODEL = { };
VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL = { };
VUHDO_AURA_GROUPS_FILTER_SELECTED = "";
VUHDO_AURA_GROUPS_EXCLUDE_SELECTED = "";
VUHDO_AURA_GROUPS_PRIORITY = 50;
VUHDO_AURA_GROUPS_COLOR_TYPE = 1;

VUHDO_AURA_GROUPS_CUSTOM_COLOR = {
	["R"] = 0.6,
	["G"] = 0.3,
	["B"] = 0,
	["O"] = 1,
	["TR"] = 0.8,
	["TG"] = 0.5,
	["TB"] = 0,
	["TO"] = 1,
	["useBackground"] = true,
	["useText"] = true,
	["useOpacity"] = true,
};

VUHDO_AURA_GROUPS_CAN_COLOR_BAR = false;
VUHDO_AURA_GROUPS_CAN_COLOR_TEXT = false;
VUHDO_AURA_GROUPS_ENABLED = true;

VUHDO_AURA_FILTER_OPTIONS = {
	{ "HELPFUL", VUHDO_I18N_AURA_GROUP_ALL_BUFFS, nil, nil, VUHDO_I18N_TT.K635 },
	{ "HARMFUL", VUHDO_I18N_AURA_GROUP_ALL_DEBUFFS, nil, nil, VUHDO_I18N_TT.K636 },
	{ "HELPFUL|PLAYER|RAID_IN_COMBAT", VUHDO_I18N_AURA_GROUP_MY_HOTS, nil, nil, VUHDO_I18N_TT.K637 },
	{ "HELPFUL|RAID_IN_COMBAT", VUHDO_I18N_AURA_GROUP_ALL_HOTS, nil, nil, VUHDO_I18N_TT.K638 },
	{ "HARMFUL|RAID_PLAYER_DISPELLABLE", VUHDO_I18N_AURA_FILTER_HARMFUL_DISPELLABLE, nil, nil, VUHDO_I18N_TT.K639 },
	{ "HARMFUL|CROWD_CONTROL", VUHDO_I18N_AURA_GROUP_CC, nil, nil, VUHDO_I18N_TT.K640 },
	{ "HELPFUL|BIG_DEFENSIVE", VUHDO_I18N_AURA_GROUP_BIG_DEF, nil, nil, VUHDO_I18N_TT.K641 },
	{ "HELPFUL|EXTERNAL_DEFENSIVE", VUHDO_I18N_AURA_GROUP_EXTERNAL_DEF, nil, nil, VUHDO_I18N_TT.K642 },
	{ "HELPFUL|RAID|PLAYER", VUHDO_I18N_AURA_GROUP_MY_BUFFS, nil, nil, VUHDO_I18N_TT.K643 },
	{ "HELPFUL|RAID", VUHDO_I18N_AURA_GROUP_ALL_RAID_BUFFS, nil, nil, VUHDO_I18N_TT.K644 },
	{ "HARMFUL|RAID", VUHDO_I18N_AURA_GROUP_RAID_DEBUFFS, nil, nil, VUHDO_I18N_TT.K645 },
	{ "HELPFUL|IMPORTANT", VUHDO_I18N_AURA_GROUP_IMPORTANT_BUFFS, nil, nil, VUHDO_I18N_TT.K646 },
	{ "HARMFUL|IMPORTANT", VUHDO_I18N_AURA_GROUP_IMPORTANT_DEBUFFS, nil, nil, VUHDO_I18N_TT.K647 },
	{ "HELPFUL|CANCELABLE", VUHDO_I18N_AURA_GROUP_CANCELABLE, nil, nil, VUHDO_I18N_TT.K648 },
	{ "HELPFUL|NOT_CANCELABLE", VUHDO_I18N_AURA_GROUP_NOT_CANCELABLE, nil, nil, VUHDO_I18N_TT.K649 },
	{ "HELPFUL|MAW", VUHDO_I18N_AURA_GROUP_TORGHAST_ANIMA, nil, nil, VUHDO_I18N_TT.K650 },
	{ "HARMFUL|INCLUDE_NAME_PLATE_ONLY|PLAYER", VUHDO_I18N_AURA_GROUP_MY_NAMEPLATE, nil, nil, VUHDO_I18N_TT.K651 },
	{ "HARMFUL|INCLUDE_NAME_PLATE_ONLY", VUHDO_I18N_AURA_GROUP_ALL_NAMEPLATE, nil, nil, VUHDO_I18N_TT.K652 },
	{ "HARMFUL|PLAYER", VUHDO_I18N_AURA_GROUP_MY_DEBUFFS, nil, nil, VUHDO_I18N_TT.K663 },
	{ "HELPFUL|EXTERNAL_DEFENSIVE|PLAYER", VUHDO_I18N_AURA_GROUP_MY_EXTERNAL_DEF, nil, nil, VUHDO_I18N_TT.K664 },
	{ "HARMFUL|RAID|PLAYER", VUHDO_I18N_AURA_GROUP_MY_RAID_DEBUFFS, nil, nil, VUHDO_I18N_TT.K665 },
};

VUHDO_AURA_EXCLUDE_FILTER_OPTIONS = {
	{ "", VUHDO_I18N_AURA_FILTER_NONE },
	{ "PLAYER", VUHDO_I18N_PLAYER },
};

local VUHDO_AURA_GROUP_TOOLTIPS = {
	["OTHERS_HOTS"] = VUHDO_I18N_TT.K660,
	["OTHERS_BUFFS"] = VUHDO_I18N_TT.K661,
	["OTHERS_NAMEPLATE_DEBUFFS"] = VUHDO_I18N_TT.K662,
};

local VUHDO_AURA_FILTER_TOOLTIPS = {
	["HELPFUL"] = VUHDO_I18N_TT.K635,
	["HARMFUL"] = VUHDO_I18N_TT.K636,
	["HELPFUL|PLAYER|RAID_IN_COMBAT"] = VUHDO_I18N_TT.K637,
	["HELPFUL|RAID_IN_COMBAT"] = VUHDO_I18N_TT.K638,
	["HARMFUL|RAID_PLAYER_DISPELLABLE"] = VUHDO_I18N_TT.K639,
	["HARMFUL|CROWD_CONTROL"] = VUHDO_I18N_TT.K640,
	["HELPFUL|BIG_DEFENSIVE"] = VUHDO_I18N_TT.K641,
	["HELPFUL|EXTERNAL_DEFENSIVE"] = VUHDO_I18N_TT.K642,
	["HELPFUL|RAID|PLAYER"] = VUHDO_I18N_TT.K643,
	["HELPFUL|RAID"] = VUHDO_I18N_TT.K644,
	["HARMFUL|RAID"] = VUHDO_I18N_TT.K645,
	["HELPFUL|IMPORTANT"] = VUHDO_I18N_TT.K646,
	["HARMFUL|IMPORTANT"] = VUHDO_I18N_TT.K647,
	["HELPFUL|CANCELABLE"] = VUHDO_I18N_TT.K648,
	["HELPFUL|NOT_CANCELABLE"] = VUHDO_I18N_TT.K649,
	["HELPFUL|MAW"] = VUHDO_I18N_TT.K650,
	["HARMFUL|INCLUDE_NAME_PLATE_ONLY|PLAYER"] = VUHDO_I18N_TT.K651,
	["HARMFUL|INCLUDE_NAME_PLATE_ONLY"] = VUHDO_I18N_TT.K652,
	["HARMFUL|PLAYER"] = VUHDO_I18N_TT.K663,
	["HELPFUL|EXTERNAL_DEFENSIVE|PLAYER"] = VUHDO_I18N_TT.K664,
	["HARMFUL|RAID|PLAYER"] = VUHDO_I18N_TT.K665,
};

VUHDO_AURA_GROUPS_COLOR_TYPE_OPTIONS = {
	{ VUHDO_AURA_GROUP_COLOR_OFF, VUHDO_I18N_AURA_COLOR_OFF },
	{ VUHDO_AURA_GROUP_COLOR_DISPEL, VUHDO_I18N_AURA_COLOR_DISPEL },
	{ VUHDO_AURA_GROUP_COLOR_CUSTOM, VUHDO_I18N_AURA_COLOR_CUSTOM },
};

local sSelectedGroupId = nil;



--
local tGroup;
local tTooltipResult;
local function VUHDO_getAuraGroupTooltip(aGroupId)

	tTooltipResult = VUHDO_AURA_GROUP_TOOLTIPS[aGroupId];

	if tTooltipResult then
		return tTooltipResult;
	end

	tGroup = VUHDO_getAuraGroup(aGroupId);

	if tGroup and tGroup["filter"] then
		return VUHDO_AURA_FILTER_TOOLTIPS[tGroup["filter"]];
	end

	return nil;

end



--
local tCandidate;
local tSuffix;
local tAllGroups;
local tFound;
local function VUHDO_ensureUniqueAuraGroupName(aBaseName)

	tCandidate = aBaseName;
	tSuffix = 1;

	tAllGroups = VUHDO_getAllAuraGroups();

	while true do
		tFound = false;

		for _, tGroup in pairs(tAllGroups) do
			if tGroup["displayName"] == tCandidate then
				tFound = true;

				tSuffix = tSuffix + 1;

				tCandidate = aBaseName .. " (" .. tSuffix .. ")";

				break;
			end
		end

		if not tFound then
			return tCandidate;
		end
	end

end



--
local tAllGroups;
local tDisplayName;
local tSortTable;
local tTooltip;
function VUHDO_initAuraGroupsComboModel()

	twipe(VUHDO_AURA_GROUPS_COMBO_MODEL);

	tAllGroups = VUHDO_getAllAuraGroups();

	if not tAllGroups then
		return;
	end

	tSortTable = { };

	for tGroupId, tGroup in pairs(tAllGroups) do
		tDisplayName = VUHDO_getAuraGroupDisplayName(tGroupId);
		tTooltip = VUHDO_getAuraGroupTooltip(tGroupId);

		tinsert(tSortTable, { tGroupId, tDisplayName, tTooltip });
	end

	tsort(tSortTable, function(anA, anotherA) return anA[2] < anotherA[2]; end);

	for _, tEntry in ipairs(tSortTable) do
		tinsert(VUHDO_AURA_GROUPS_COMBO_MODEL, { tEntry[1], tEntry[2], nil, nil, tEntry[3] });
	end

	return;

end



--
local tAllGroups;
local tDisplayName;
local tSortTable;
local tTooltip;
function VUHDO_initPanelAuraGroupsComboModel()

	twipe(VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL);

	tAllGroups = VUHDO_getAllAuraGroups();

	if not tAllGroups then
		return;
	end

	tSortTable = { };

	for tGroupId, tGroup in pairs(tAllGroups) do
		if VUHDO_getAuraGroup(tGroupId) then
			tDisplayName = VUHDO_getAuraGroupDisplayName(tGroupId);
			tTooltip = VUHDO_getAuraGroupTooltip(tGroupId);

			tinsert(tSortTable, { tGroupId, tDisplayName, tTooltip });
		end
	end

	tsort(tSortTable, function(anA, anotherA) return anA[2] < anotherA[2]; end);

	for _, tEntry in ipairs(tSortTable) do
		tinsert(VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL, { tEntry[1], tEntry[2], nil, nil, tEntry[3] });
	end

	return;

end



--
function VUHDO_auraGroupsComboChanged(aComboBox, aValue, anArrayModel)

	VUHDO_AURA_GROUPS_SELECTED = aValue;
	sSelectedGroupId = aValue;

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
function VUHDO_auraGroupsNameChanged(aEditBox)

	if VUHDO_AURA_GROUPS_SELECTED and VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][VUHDO_AURA_GROUPS_SELECTED] and aEditBox:GetText() then
		VUHDO_CONFIG["AURA_GROUPS"][VUHDO_AURA_GROUPS_SELECTED]["displayName"] = aEditBox:GetText();

		VUHDO_auraGroupsRefreshList();
	end

	return;

end



--
local tGroupCombo;
function VUHDO_auraGroupsRefreshList()

	VUHDO_initAuraGroupsComboModel();

	tGroupCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelGroupCombo"];

	if tGroupCombo then
		VUHDO_lnfComboBoxInitFromModel(tGroupCombo);
	end

	return;

end



--
function VUHDO_auraGroupsListDropdownInitFromModel()

	return;

end



--
function VUHDO_auraGroupsOnGroupSelected(aGroupId)

	sSelectedGroupId = aGroupId;
	VUHDO_AURA_GROUPS_SELECTED = aGroupId;

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
local tGroup;
local tNameEditBox;
local tFilterCombo;
local tExcludeFilterCombo;
local tPrioritySlider;
local tColorTypeCombo;
local tCanColorBarCheck;
local tCanColorTextCheck;
local tCustomColorSwatch;
local tEnabledCheck;
local tDeleteButton;
local tIsBuiltIn;
local tInnerSlider;
function VUHDO_auraGroupsRefreshRightPanel()

	tGroup = sSelectedGroupId and VUHDO_getAuraGroupRaw(sSelectedGroupId) or nil;
	tIsBuiltIn = tGroup and VUHDO_isBuiltInAuraGroup(sSelectedGroupId);

	tNameEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelNameEditBox"];
	tFilterCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelFilterCombo"];
	tExcludeFilterCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelExcludeFilterCombo"];
	tPrioritySlider = _G["VuhDoNewOptionsAuraGroupsStorePanelPrioritySlider"];
	tColorTypeCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelColorTypeCombo"];
	tCanColorBarCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanColorBarCheckButton"];
	tCanColorTextCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanColorTextCheckButton"];
	tCustomColorSwatch = _G["VuhDoNewOptionsAuraGroupsStorePanelCustomColorTexture"];
	tDeleteButton = _G["VuhDoNewOptionsAuraGroupsStorePanelDeleteButton"];
	tEnabledCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelEnabledCheckButton"];

	if tDeleteButton then
		if tGroup and not tIsBuiltIn then
			tDeleteButton:Enable();
			tDeleteButton:SetAlpha(1);
		else
			tDeleteButton:Disable();
			tDeleteButton:SetAlpha(0.5);
		end
	end

	if tNameEditBox and tGroup then
		tNameEditBox:Show();
		if tIsBuiltIn then
			tNameEditBox:SetText(VUHDO_getAuraGroupDisplayName(sSelectedGroupId) or "");
			tNameEditBox:Disable();
			tNameEditBox:SetAlpha(0.5);
		else
			tNameEditBox:SetText(tGroup["displayName"] or "");
			tNameEditBox:Enable();
			tNameEditBox:SetAlpha(1);
		end
	end

	if tFilterCombo and tGroup then
		tFilterCombo:SetShown(true);

		VUHDO_AURA_GROUPS_FILTER_SELECTED = tGroup["filter"] or "";

		VUHDO_lnfComboBoxInitFromModel(tFilterCombo);
		tFilterCombo:Enable();
		tFilterCombo:SetAlpha(1);

		if tIsBuiltIn or tGroup["isInferred"] then
			tFilterCombo:Disable();
			tFilterCombo:SetAlpha(0.5);
		end
	end

	if tExcludeFilterCombo and tGroup then
		tExcludeFilterCombo:SetShown(true);

		VUHDO_AURA_GROUPS_EXCLUDE_SELECTED = tGroup["excludeFilter"] or "";

		VUHDO_lnfComboBoxInitFromModel(tExcludeFilterCombo);
		tExcludeFilterCombo:Enable();
		tExcludeFilterCombo:SetAlpha(1);

		if tIsBuiltIn or tGroup["isInferred"] then
			tExcludeFilterCombo:Disable();
			tExcludeFilterCombo:SetAlpha(0.5);
		end
	end

	if tPrioritySlider and tGroup then
		tPrioritySlider:SetShown(true);
		tPrioritySlider:SetAlpha(1);

		VUHDO_AURA_GROUPS_PRIORITY = tGroup["priority"] or 50;

		tInnerSlider = _G[tPrioritySlider:GetName() .. "Slider"];
		VUHDO_lnfSliderInitFromModel(tInnerSlider);
		tInnerSlider:Enable();

		if tIsBuiltIn then
			tPrioritySlider:SetAlpha(0.5);
			tInnerSlider:Disable();
		end
	end

	if tColorTypeCombo and tGroup then
		tColorTypeCombo:SetShown(true);

		VUHDO_AURA_GROUPS_COLOR_TYPE = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

		VUHDO_lnfComboBoxInitFromModel(tColorTypeCombo);
		tColorTypeCombo:Enable();
		tColorTypeCombo:SetAlpha(1);

		if tIsBuiltIn then
			tColorTypeCombo:Disable();
			tColorTypeCombo:SetAlpha(0.5);
		end
	end

	if tCanColorBarCheck and tGroup then
		tCanColorBarCheck:SetShown(true);

		VUHDO_AURA_GROUPS_CAN_COLOR_BAR = tGroup["canColorBar"];

		VUHDO_lnfCheckButtonInitFromModel(tCanColorBarCheck);

		if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_OFF then
			tCanColorBarCheck:Disable();
			tCanColorBarCheck:SetAlpha(0.5);
		else
			tCanColorBarCheck:Enable();
			tCanColorBarCheck:SetAlpha(1);
		end

		if tIsBuiltIn then
			tCanColorBarCheck:Disable();
			tCanColorBarCheck:SetAlpha(0.5);
		end
	end

	if tCanColorTextCheck and tGroup then
		tCanColorTextCheck:SetShown(true);

		VUHDO_AURA_GROUPS_CAN_COLOR_TEXT = tGroup["canColorText"];

		VUHDO_lnfCheckButtonInitFromModel(tCanColorTextCheck);

		if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_OFF then
			tCanColorTextCheck:Disable();
			tCanColorTextCheck:SetAlpha(0.5);
		else
			tCanColorTextCheck:Enable();
			tCanColorTextCheck:SetAlpha(1);
		end

		if tIsBuiltIn then
			tCanColorTextCheck:Disable();
			tCanColorTextCheck:SetAlpha(0.5);
		end
	end

	if tCustomColorSwatch and tGroup then
		if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_CUSTOM then
			tCustomColorSwatch:SetShown(true);

			if not tIsBuiltIn then
				VUHDO_CONFIG["AURA_GROUPS"] = VUHDO_CONFIG["AURA_GROUPS"] or { };

				if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
					VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] = { };
				end

				if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["customColor"] then
					VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["customColor"] = tGroup["customColor"] and VUHDO_deepCopyTable(tGroup["customColor"]) or {
						["R"] = 0.6, ["G"] = 0.3, ["B"] = 0, ["O"] = 1,
						["TR"] = 0.8, ["TG"] = 0.5, ["TB"] = 0, ["TO"] = 1,
						["useBackground"] = true, ["useText"] = true, ["useOpacity"] = true,
					};
				end

				VUHDO_lnfSetModel(tCustomColorSwatch, "VUHDO_CONFIG.AURA_GROUPS." .. sSelectedGroupId .. ".customColor");
				tCustomColorSwatch:SetAttribute("custom_function_post", VUHDO_auraGroupsCustomColorChanged);
				tCustomColorSwatch:SetAttribute("disabled", nil);
				tCustomColorSwatch:SetAlpha(1);
			else
				VUHDO_lnfSetModel(tCustomColorSwatch, "VUHDO_DEFAULT_AURA_GROUPS." .. sSelectedGroupId .. ".customColor");
				tCustomColorSwatch:SetAttribute("disabled", true);
				tCustomColorSwatch:SetAlpha(0.5);
			end

			VUHDO_lnfInitColorSwatch(tCustomColorSwatch, VUHDO_I18N_AURA_GROUP_CUSTOM_COLOR, VUHDO_I18N_AURA_GROUP_CUSTOM_COLOR);
			VUHDO_lnfSetTooltip(tCustomColorSwatch, VUHDO_I18N_TT.K616);
			VUHDO_lnfColorSwatchInitFromModel(tCustomColorSwatch);
		else
			tCustomColorSwatch:SetShown(false);
		end
	end

	if tEnabledCheck and tGroup then
		tEnabledCheck:SetShown(true);

		if tIsBuiltIn then
			VUHDO_AURA_GROUPS_ENABLED = not (VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][sSelectedGroupId]);
		else
			VUHDO_AURA_GROUPS_ENABLED = tGroup["enabled"] ~= false;
		end

		VUHDO_lnfCheckButtonInitFromModel(tEnabledCheck);

		tEnabledCheck:Enable();
		tEnabledCheck:SetAlpha(1);
	end

	if not tGroup then
		if tNameEditBox then
			tNameEditBox:Show();
			tNameEditBox:SetText("");
			tNameEditBox:Disable();
			tNameEditBox:SetAlpha(0.5);
		end

		if tFilterCombo then
			tFilterCombo:Show();
			tFilterCombo:Disable();
			tFilterCombo:SetAlpha(0.5);
		end

		if tExcludeFilterCombo then
			tExcludeFilterCombo:Show();
			tExcludeFilterCombo:Disable();
			tExcludeFilterCombo:SetAlpha(0.5);
		end

		if tPrioritySlider then
			tPrioritySlider:Show();
			tInnerSlider = _G[tPrioritySlider:GetName() .. "Slider"];
			if tInnerSlider then
				tInnerSlider:Disable();
			end
			tPrioritySlider:SetAlpha(0.5);
		end

		if tColorTypeCombo then
			tColorTypeCombo:Show();
			tColorTypeCombo:Disable();
			tColorTypeCombo:SetAlpha(0.5);
		end

		if tCanColorBarCheck then
			tCanColorBarCheck:Show();
			tCanColorBarCheck:Disable();
			tCanColorBarCheck:SetAlpha(0.5);
		end

		if tCanColorTextCheck then
			tCanColorTextCheck:Show();
			tCanColorTextCheck:Disable();
			tCanColorTextCheck:SetAlpha(0.5);
		end

		if tCustomColorSwatch then
			tCustomColorSwatch:Show();
			tCustomColorSwatch:SetAlpha(0.5);
		end

		if tEnabledCheck then
			tEnabledCheck:Show();
			tEnabledCheck:Disable();
			tEnabledCheck:SetAlpha(0.5);
		end
	end

	return;

end



--
local tNewId;
function VUHDO_auraGroupsOnNewGroup()

	tNewId = VUHDO_generateAuraGroupId();

	VUHDO_CONFIG["AURA_GROUPS"][tNewId] = {
		["filter"] = "HELPFUL|PLAYER",
		["excludeFilter"] = nil,
		["priority"] = VUHDO_getNextAuraGroupPriority(),
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = true,
		["canColorText"] = true,
		["enabled"] = true,
		["displayName"] = VUHDO_ensureUniqueAuraGroupName(VUHDO_I18N_NEW .. " " .. VUHDO_I18N_GROUP),
		["isHarmful"] = false,
	};

	sSelectedGroupId = tNewId;
	VUHDO_AURA_GROUPS_SELECTED = tNewId;

	VUHDO_auraGroupsRefreshList();
	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
local tNewId;
local tSourceGroup;
function VUHDO_auraGroupsOnCloneGroup(aSourceId)

	tSourceGroup = VUHDO_getAuraGroup(aSourceId);

	if not tSourceGroup then
		return;
	end

	tNewId = VUHDO_cloneAuraGroup(aSourceId, VUHDO_ensureUniqueAuraGroupName(VUHDO_getAuraGroupDisplayName(aSourceId) .. " (Copy)"));

	if tNewId then
		sSelectedGroupId = tNewId;
		VUHDO_AURA_GROUPS_SELECTED = tNewId;

		VUHDO_auraGroupsRefreshList();
		VUHDO_auraGroupsRefreshRightPanel();
	end

	return;

end



--
function VUHDO_auraGroupsOnDeleteGroup(aGroupId)

	if VUHDO_isBuiltInAuraGroup(aGroupId) then
		return;
	end

	VUHDO_CONFIG["AURA_GROUPS"][aGroupId] = nil;
	sSelectedGroupId = nil;
	VUHDO_AURA_GROUPS_SELECTED = nil;

	VUHDO_auraGroupsRefreshList();
	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
function VUHDO_auraGroupsFilterChanged(aComboBox, aValue, anArrayModel)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["filter"] = aValue or "";

		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["isHarmful"] = (aValue and strfind(aValue, "HARMFUL")) and true or false;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
function VUHDO_auraGroupsExcludeFilterChanged(aComboBox, aValue, anArrayModel)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["excludeFilter"] = (aValue ~= "" and aValue) or nil;
	end

	return;

end



--
function VUHDO_auraGroupsPriorityChanged(aComponent, aValue)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["priority"] = tonumber(aValue) or 50;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
function VUHDO_auraGroupsColorTypeChanged(aComboBox, aValue, anArrayModel)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["colorType"] = aValue or VUHDO_AURA_GROUP_COLOR_OFF;
	end

	VUHDO_auraGroupsRefreshRightPanel();
	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
function VUHDO_auraGroupsCustomColorChanged(aColorSwatch)

	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
function VUHDO_auraGroupsCanColorBarChanged(aParent, aValue)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canColorBar"] = aValue;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
function VUHDO_auraGroupsCanColorTextChanged(aParent, aValue)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canColorText"] = aValue;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
function VUHDO_auraGroupsEnabledChanged(aParent, aValue)

	if not sSelectedGroupId then
		return;
	end

	if VUHDO_isBuiltInAuraGroup(sSelectedGroupId) then
		if not VUHDO_CONFIG["AURA_GROUP_DISABLED"] then
			VUHDO_CONFIG["AURA_GROUP_DISABLED"] = { };
		end

		if aValue then
			VUHDO_CONFIG["AURA_GROUP_DISABLED"][sSelectedGroupId] = nil;
		else
			VUHDO_CONFIG["AURA_GROUP_DISABLED"][sSelectedGroupId] = true;
		end
	else
		if VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
			VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["enabled"] = aValue;
		end
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	VUHDO_auraGroupsRefreshList();

	VUHDO_reloadUI(false);

	return;

end



--
function VUHDO_auraGroupsOnShow()

	VUHDO_auraGroupsRefreshList();

	if sSelectedGroupId and VUHDO_getAuraGroupRaw(sSelectedGroupId) then
		VUHDO_auraGroupsOnGroupSelected(sSelectedGroupId);
	else
		sSelectedGroupId = nil;
	end

	return;

end