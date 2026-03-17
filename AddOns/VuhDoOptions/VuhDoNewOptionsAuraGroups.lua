local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local tsort = table.sort;
local twipe = table.wipe;
local strfind = string.find;

VUHDO_AURA_GROUPS_SELECTED = nil;
VUHDO_AURA_GROUPS_PENDING_SELECTION = nil;
VUHDO_AURA_GROUPS_COMBO_MODEL = { };
VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL = { };
VUHDO_AURA_GROUPS_FILTER_SELECTED = "";
VUHDO_AURA_GROUPS_EXCLUDE_SELECTED = "";
VUHDO_AURA_GROUPS_TYPE_SELECTED = 1;
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
VUHDO_AURA_GROUPS_CAN_GLOW_BAR = false;
VUHDO_AURA_GROUPS_SOUND = nil;
VUHDO_AURA_GROUPS_ENABLED = true;
VUHDO_AURA_GROUPS_IGNORE_COMBO_MODEL = { };
VUHDO_AURA_GROUPS_IGNORE_SELECTED = "";
VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";
VUHDO_AURA_GROUPS_ADD_SPELL_COMBO_MODEL = { };

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
	["PRESERVATION_EVOKER_HOTS"] = VUHDO_I18N_TT.K670,
	["AUGMENTATION_EVOKER_BUFFS"] = VUHDO_I18N_TT.K671,
	["RESTORATION_DRUID_HOTS"] = VUHDO_I18N_TT.K672,
	["DISCIPLINE_PRIEST_HOTS"] = VUHDO_I18N_TT.K673,
	["HOLY_PRIEST_HOTS"] = VUHDO_I18N_TT.K674,
	["MISTWEAVER_MONK_HOTS"] = VUHDO_I18N_TT.K675,
	["RESTORATION_SHAMAN_HOTS"] = VUHDO_I18N_TT.K676,
	["HOLY_PALADIN_HOTS"] = VUHDO_I18N_TT.K677,
	["RAID_BUFFS"] = VUHDO_I18N_TT.K678,
	["BLESSING_OF_BRONZE"] = VUHDO_I18N_TT.K679,
	["ROGUE_POISONS"] = VUHDO_I18N_TT.K680,
	["SHAMAN_WEAPON_IMBUEMENTS"] = VUHDO_I18N_TT.K681,
	["PALADIN_WEAPON_IMBUEMENTS"] = VUHDO_I18N_TT.K682,
	["ENHANCEMENT_SHAMAN_BUFFS"] = VUHDO_I18N_TT.K683,
	["BREWMASTER_MONK_BUFFS"] = VUHDO_I18N_TT.K684,
	["WARLOCK_METAMORPHOSIS"] = VUHDO_I18N_TT.K685,
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

VUHDO_AURA_GROUP_TYPE_OPTIONS = {
	{ VUHDO_AURA_GROUP_TYPE_FILTER, VUHDO_I18N_AURA_GROUP_TYPE_FILTER },
	{ VUHDO_AURA_GROUP_TYPE_LIST, VUHDO_I18N_AURA_GROUP_TYPE_LIST },
};

local VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT = 22;

VUHDO_AURA_GROUPS_NEW_BOUQUET_SELECTED = "";

local sSelectedGroupId = nil;
local sAuraGroupEntryItems = { };



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
local tSpellId;
local tSpellIds;
local tDisplayName;
local tSecrecy;
local tSortTable;
function VUHDO_initAuraGroupsAddSpellComboModel()

	twipe(VUHDO_AURA_GROUPS_ADD_SPELL_COMBO_MODEL);

	VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";

	tSpellIds = { };

	for _, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or { }) do
		if tGroup["type"] == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
			for _, tEntry in ipairs(tGroup["entries"]) do
				if (tEntry["entryType"] or 0) == VUHDO_AURA_LIST_ENTRY_SPELL and tEntry["value"] then
					tSpellId = tonumber(tEntry["value"]) or tEntry["value"];

					tSpellIds[tSpellId] = true;
				end
			end
		end
	end

	tSortTable = { };

	for tSpellId, _ in pairs(tSpellIds) do
		tDisplayName = VUHDO_resolveSpellId(tSpellId);

		if tDisplayName ~= tostring(tSpellId) then
			tDisplayName = "[" .. tSpellId .. "] " .. tDisplayName;
		else
			tDisplayName = tostring(tSpellId);
		end

		tSecrecy = VUHDO_getSpellAuraSecrecy(tSpellId);

		if tSecrecy >= 1 then
			tDisplayName = "|cFFFF4444" .. tDisplayName .. "|r";
		end

		tinsert(tSortTable, { tSpellId, tDisplayName, VUHDO_resolveSpellId(tSpellId) });
	end

	tsort(tSortTable, function(anA, anotherA) return anA[3] < anotherA[3]; end);

	for _, tEntry in ipairs(tSortTable) do
		tinsert(VUHDO_AURA_GROUPS_ADD_SPELL_COMBO_MODEL, { tEntry[1], tEntry[2] });
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
local tScrollPanel;
function VUHDO_auraGroupsGroupComboOnLoad(aGroupCombo)

	VUHDO_initResizeableScrollCombo(aGroupCombo);

	VUHDO_setComboModel(aGroupCombo, "VUHDO_AURA_GROUPS_SELECTED", VUHDO_AURA_GROUPS_COMBO_MODEL, VUHDO_I18N_SELECT);
	aGroupCombo:SetAttribute("custom_function", VUHDO_auraGroupsComboChanged);
	VUHDO_lnfSetTooltip(aGroupCombo, VUHDO_I18N_TT.K611);

	tScrollPanel = _G[aGroupCombo:GetName() .. "ScrollPanel"];

	if tScrollPanel then
		tScrollPanel:SetScript("OnShow", function()
			VUHDO_initAuraGroupsComboModel();
			VUHDO_lnfComboBoxInitFromModel(aGroupCombo);
		end);
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
local tNameLabel;
local tTypeCombo;
local tTypeLabel;
local tFilterCombo;
local tExcludeFilterCombo;
local tFilterLabel;
local tExcludeFilterLabel;
local tListEntriesPanel;
local tColorTypeLabel;
local tPrioritySlider;
local tColorTypeCombo;
local tCanColorBarCheck;
local tCanColorTextCheck;
local tCustomColorSwatch;
local tCanUseCustomColor;
local tCanUseGlow;
local tCanGlowBarCheck;
local tGlowBarColorSwatch;
local tEnabledCheck;
local tDeleteButton;
local tIsBuiltIn;
local tInnerSlider;
local tNewSpellCombo;
local tAddSpellButton;
local tNewBouquetCombo;
local tAddBouquetButton;
local tAddEmptyButton;
local tIgnorePanel;
local tIgnoreLabel;
local tIgnoreCombo;
local tIgnoreAddButton;
local tIgnoreDeleteButton;
local tSoundCombo;
local tSoundLabel;
local tFrame;
function VUHDO_auraGroupsRefreshRightPanel()

	tGroup = sSelectedGroupId and VUHDO_getAuraGroupRaw(sSelectedGroupId) or nil;
	tIsBuiltIn = tGroup and VUHDO_isBuiltInAuraGroup(sSelectedGroupId);

	tNameEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelNameEditBox"];
	tNameLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelNameLabel"];
	tTypeLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelTypeLabel"];
	tTypeCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelTypeCombo"];
	tFilterLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelFilterLabel"];
	tExcludeFilterLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelExcludeFilterLabel"];
	tFilterCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelFilterCombo"];
	tExcludeFilterCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelExcludeFilterCombo"];
	tListEntriesPanel = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanel"];
	tColorTypeLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelColorTypeLabel"];
	tPrioritySlider = _G["VuhDoNewOptionsAuraGroupsStorePanelPrioritySlider"];
	tColorTypeCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelColorTypeCombo"];
	tCanColorBarCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanColorBarCheckButton"];
	tCanColorTextCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanColorTextCheckButton"];
	tCustomColorSwatch = _G["VuhDoNewOptionsAuraGroupsStorePanelCustomColorTexture"];
	tCanGlowBarCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanGlowBarCheckButton"];
	tGlowBarColorSwatch = _G["VuhDoNewOptionsAuraGroupsStorePanelGlowBarColorTexture"];
	tDeleteButton = _G["VuhDoNewOptionsAuraGroupsStorePanelDeleteButton"];
	tEnabledCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelEnabledCheckButton"];
	tIgnorePanel = _G["VuhDoNewOptionsAuraGroupsStorePanelIgnorePanel"];
	tSoundCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelSoundCombo"];
	tSoundLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelSoundLabel"];

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

	if tNameLabel and tGroup then
		if tIsBuiltIn then
			tNameLabel:SetAlpha(0.5);
		else
			tNameLabel:SetAlpha(1);
		end
	end

	if tTypeLabel and tTypeCombo then
		if tGroup then
			tTypeLabel:Show();
			tTypeCombo:Show();

			VUHDO_AURA_GROUPS_TYPE_SELECTED = tGroup["type"] or 1;

			VUHDO_lnfComboBoxInitFromModel(tTypeCombo);

			if tIsBuiltIn then
				tTypeLabel:SetAlpha(0.5);
				tTypeCombo:Disable();
				tTypeCombo:SetAlpha(0.5);
			else
				tTypeLabel:SetAlpha(1);
				tTypeCombo:Enable();
				tTypeCombo:SetAlpha(1);
			end
		else
			tTypeLabel:Hide();
			tTypeCombo:Hide();
		end
	end

	if not tGroup then
		if tIgnorePanel then
			tIgnorePanel:Show();

			tIgnoreLabel = _G[tIgnorePanel:GetName() .. "IgnoreLabel"];
			tIgnoreCombo = _G[tIgnorePanel:GetName() .. "IgnoreCombo"];
			tIgnoreAddButton = _G[tIgnorePanel:GetName() .. "IgnoreAddButton"];
			tIgnoreDeleteButton = _G[tIgnorePanel:GetName() .. "IgnoreDeleteButton"];

			if tIgnoreLabel then
				tIgnoreLabel:SetAlpha(0.5);
			end

			if tIgnoreCombo then
				tIgnoreCombo:Disable();
				tIgnoreCombo:SetAlpha(0.5);
			end

			if tIgnoreAddButton then
				tIgnoreAddButton:Disable();
				tIgnoreAddButton:SetAlpha(0.5);
			end

			if tIgnoreDeleteButton then
				tIgnoreDeleteButton:Disable();
				tIgnoreDeleteButton:SetAlpha(0.5);
			end
		end

		if tFilterLabel then
			tFilterLabel:Hide();
		end

		if tExcludeFilterLabel then
			tExcludeFilterLabel:Hide();
		end

		if tFilterCombo then
			tFilterCombo:Hide();
		end

		if tExcludeFilterCombo then
			tExcludeFilterCombo:Hide();
		end

		if tListEntriesPanel then
			tListEntriesPanel:Hide();
		end
	elseif (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
		if tIgnorePanel then
			tIgnorePanel:Hide();
		end

		if tFilterLabel then
			tFilterLabel:Hide();
		end

		if tExcludeFilterLabel then
			tExcludeFilterLabel:Hide();
		end

		if tFilterCombo then
			tFilterCombo:Hide();
		end

		if tExcludeFilterCombo then
			tExcludeFilterCombo:Hide();
		end

		if tListEntriesPanel then
			if VUHDO_initBouquetComboModel then
				VUHDO_initBouquetComboModel();
			end

			VUHDO_initAuraGroupsAddSpellComboModel();

			tNewSpellCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelNewSpellCombo"];

			if tNewSpellCombo then
				tFrame = _G[tNewSpellCombo:GetName() .. "EditBox"];

				if tFrame then
					tFrame:SetText("");
				end

				VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";
				VUHDO_lnfComboBoxInitFromModel(tNewSpellCombo);
			end

			tListEntriesPanel:Show();
			VUHDO_auraGroupsRefreshListEntries();

			tAddSpellButton = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelAddSpellButton"];
			tNewBouquetCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelNewBouquetCombo"];
			tAddBouquetButton = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelAddBouquetButton"];
			tAddEmptyButton = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelAddEmptyButton"];

			if tIsBuiltIn then
				if tNewSpellCombo then
					tNewSpellCombo:Disable();
					tNewSpellCombo:SetAlpha(0.5);
				end

				if tAddSpellButton then
					tAddSpellButton:Disable();
					tAddSpellButton:SetAlpha(0.5);
				end

				if tNewBouquetCombo then
					tNewBouquetCombo:Disable();
					tNewBouquetCombo:SetAlpha(0.5);
				end

				if tAddBouquetButton then
					tAddBouquetButton:Disable();
					tAddBouquetButton:SetAlpha(0.5);
				end

				if tAddEmptyButton then
					tAddEmptyButton:Disable();
					tAddEmptyButton:SetAlpha(0.5);
				end
			else
				if tNewSpellCombo then
					tNewSpellCombo:Enable();
					tNewSpellCombo:SetAlpha(1);
				end

				if tAddSpellButton then
					tAddSpellButton:Enable();
					tAddSpellButton:SetAlpha(1);
				end

				if tNewBouquetCombo then
					tNewBouquetCombo:Enable();
					tNewBouquetCombo:SetAlpha(1);
				end

				if tAddBouquetButton then
					tAddBouquetButton:Enable();
					tAddBouquetButton:SetAlpha(1);
				end

				if tAddEmptyButton then
					tAddEmptyButton:Enable();
					tAddEmptyButton:SetAlpha(1);
				end
			end
		end

		if tColorTypeLabel and tListEntriesPanel then
			tColorTypeLabel:ClearAllPoints();
			tColorTypeLabel:SetPoint("TOPLEFT", tListEntriesPanel, "BOTTOMLEFT", 0, -16);
		end
	else
		if tFilterLabel then
			tFilterLabel:Show();
		end

		if tExcludeFilterLabel then
			tExcludeFilterLabel:Show();
		end

		if tFilterCombo then
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

		if tExcludeFilterCombo then
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

		if tFilterLabel then
			tFilterLabel:SetAlpha((tIsBuiltIn or tGroup["isInferred"]) and 0.5 or 1);
		end

		if tExcludeFilterLabel then
			tExcludeFilterLabel:SetAlpha((tIsBuiltIn or tGroup["isInferred"]) and 0.5 or 1);
		end

		if tListEntriesPanel then
			tListEntriesPanel:Hide();
		end

		if tColorTypeLabel and tFilterCombo then
			tColorTypeLabel:ClearAllPoints();
			tColorTypeLabel:SetPoint("TOPLEFT", tFilterCombo, "BOTTOMLEFT", 0, -16);
		end

		if tIgnorePanel then
			tIgnorePanel:Show();
			VUHDO_auraGroupsRefreshIgnorePanel();

			tIgnoreLabel = _G[tIgnorePanel:GetName() .. "IgnoreLabel"];
			tIgnoreCombo = _G[tIgnorePanel:GetName() .. "IgnoreCombo"];
			tIgnoreAddButton = _G[tIgnorePanel:GetName() .. "IgnoreAddButton"];
			tIgnoreDeleteButton = _G[tIgnorePanel:GetName() .. "IgnoreDeleteButton"];

			if tIgnoreLabel then
				tIgnoreLabel:SetAlpha(tIsBuiltIn and 0.5 or 1);
			end

			if tIgnoreCombo then
				if tIsBuiltIn then
					tIgnoreCombo:Disable();
					tIgnoreCombo:SetAlpha(0.5);
				else
					tIgnoreCombo:Enable();
					tIgnoreCombo:SetAlpha(1);
				end
			end

			if tIgnoreAddButton then
				if tIsBuiltIn then
					tIgnoreAddButton:Disable();
					tIgnoreAddButton:SetAlpha(0.5);
				else
					tIgnoreAddButton:Enable();
					tIgnoreAddButton:SetAlpha(1);
				end
			end

			if tIgnoreDeleteButton then
				if tIsBuiltIn then
					tIgnoreDeleteButton:Disable();
					tIgnoreDeleteButton:SetAlpha(0.5);
				else
					tIgnoreDeleteButton:Enable();
					tIgnoreDeleteButton:SetAlpha(1);
				end
			end
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

	if tSoundLabel and tSoundCombo and tGroup then
		tSoundLabel:SetShown(true);
		tSoundCombo:SetShown(true);

		VUHDO_AURA_GROUPS_SOUND = tGroup["sound"];

		VUHDO_lnfComboBoxInitFromModel(tSoundCombo);

		if tIsBuiltIn then
			tSoundLabel:SetAlpha(0.5);
			tSoundCombo:Disable();
			tSoundCombo:SetAlpha(0.5);
		else
			tSoundLabel:SetAlpha(1);
			tSoundCombo:Enable();
			tSoundCombo:SetAlpha(1);
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

		if tColorTypeLabel then
			tColorTypeLabel:SetAlpha(tIsBuiltIn and 0.5 or 1);
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
		if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_DISPEL then
			tCustomColorSwatch:SetShown(false);
		else
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

				tCanUseCustomColor = VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_CUSTOM and (VUHDO_AURA_GROUPS_CAN_COLOR_BAR or VUHDO_AURA_GROUPS_CAN_COLOR_TEXT);

				tCustomColorSwatch:SetAttribute("disabled", not tCanUseCustomColor);
				tCustomColorSwatch:SetAlpha(tCanUseCustomColor and 1 or 0.5);
			else
				VUHDO_lnfSetModel(tCustomColorSwatch, "VUHDO_DEFAULT_AURA_GROUPS." .. sSelectedGroupId .. ".customColor");

				tCustomColorSwatch:SetAttribute("disabled", true);
				tCustomColorSwatch:SetAlpha(0.5);
			end

			VUHDO_lnfInitColorSwatch(tCustomColorSwatch, VUHDO_I18N_AURA_GROUP_CUSTOM_COLOR, VUHDO_I18N_AURA_GROUP_CUSTOM_COLOR);
			VUHDO_lnfSetTooltip(tCustomColorSwatch, VUHDO_I18N_TT.K616);
			VUHDO_lnfColorSwatchInitFromModel(tCustomColorSwatch);
		end
	end

	if tCanGlowBarCheck and tGroup then
		tCanGlowBarCheck:SetShown(true);

		VUHDO_AURA_GROUPS_CAN_GLOW_BAR = tGroup["canGlowBar"];

		VUHDO_lnfCheckButtonInitFromModel(tCanGlowBarCheck);

		if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_OFF then
			tCanGlowBarCheck:Disable();
			tCanGlowBarCheck:SetAlpha(0.5);
		elseif tIsBuiltIn then
			tCanGlowBarCheck:Disable();
			tCanGlowBarCheck:SetAlpha(0.5);
		else
			tCanGlowBarCheck:Enable();
			tCanGlowBarCheck:SetAlpha(1);
		end
	end

	if tGlowBarColorSwatch and tGroup then
		tGlowBarColorSwatch:SetShown(true);

		if not tIsBuiltIn then
			VUHDO_CONFIG["AURA_GROUPS"] = VUHDO_CONFIG["AURA_GROUPS"] or { };

			if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
				VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] = { };
			end

			if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["glowBarColor"] then
				VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["glowBarColor"] = (VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"] and VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF_BAR_GLOW"]) and VUHDO_deepCopyTable(VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF_BAR_GLOW"]) or { ["R"] = 0.95, ["G"] = 0.95, ["B"] = 0.32, ["O"] = 1 };
			end

			VUHDO_lnfSetModel(tGlowBarColorSwatch, "VUHDO_CONFIG.AURA_GROUPS." .. sSelectedGroupId .. ".glowBarColor");

			tGlowBarColorSwatch:SetAttribute("custom_function_post", VUHDO_auraGroupsGlowColorChanged);

			tCanUseGlow = VUHDO_AURA_GROUPS_COLOR_TYPE ~= VUHDO_AURA_GROUP_COLOR_OFF and VUHDO_AURA_GROUPS_CAN_GLOW_BAR;

			tGlowBarColorSwatch:SetAttribute("disabled", not tCanUseGlow);
			tGlowBarColorSwatch:SetAlpha(tCanUseGlow and 1 or 0.5);
		else
			VUHDO_lnfSetModel(tGlowBarColorSwatch, "VUHDO_DEFAULT_AURA_GROUPS." .. sSelectedGroupId .. ".glowBarColor");

			tGlowBarColorSwatch:SetAttribute("disabled", true);
			tGlowBarColorSwatch:SetAlpha(0.5);
		end

		VUHDO_lnfInitColorSwatch(tGlowBarColorSwatch, VUHDO_I18N_AURA_GLOW_BAR, VUHDO_I18N_AURA_GLOW_BAR);
		VUHDO_lnfSetTooltip(tGlowBarColorSwatch, VUHDO_I18N_TT.K758);
		VUHDO_lnfColorSwatchInitFromModel(tGlowBarColorSwatch);
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
		if tColorTypeLabel and tFilterCombo then
			tColorTypeLabel:ClearAllPoints();
			tColorTypeLabel:SetPoint("TOPLEFT", tFilterCombo, "BOTTOMLEFT", 0, -8);
			tColorTypeLabel:SetAlpha(0.5);
		end

		VUHDO_AURA_GROUPS_ENABLED = false;
		VUHDO_AURA_GROUPS_PRIORITY = 50;
		VUHDO_AURA_GROUPS_COLOR_TYPE = 1;
		VUHDO_AURA_GROUPS_FILTER_SELECTED = "";
		VUHDO_AURA_GROUPS_EXCLUDE_SELECTED = "";
		VUHDO_AURA_GROUPS_CAN_COLOR_BAR = false;
		VUHDO_AURA_GROUPS_CAN_COLOR_TEXT = false;
		VUHDO_AURA_GROUPS_CAN_GLOW_BAR = false;
		VUHDO_AURA_GROUPS_SOUND = nil;

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

			VUHDO_lnfComboBoxInitFromModel(tFilterCombo);
		end

		if tExcludeFilterCombo then
			tExcludeFilterCombo:Show();
			tExcludeFilterCombo:Disable();
			tExcludeFilterCombo:SetAlpha(0.5);

			VUHDO_lnfComboBoxInitFromModel(tExcludeFilterCombo);
		end

		if tPrioritySlider then
			tPrioritySlider:Show();
			tInnerSlider = _G[tPrioritySlider:GetName() .. "Slider"];

			if tInnerSlider then
				VUHDO_lnfSliderInitFromModel(tInnerSlider);

				tInnerSlider:Disable();
			end

			tPrioritySlider:SetAlpha(0.5);
		end

		if tSoundLabel then
			tSoundLabel:Show();
			tSoundLabel:SetAlpha(0.5);
		end

		if tSoundCombo then
			tSoundCombo:Show();
			tSoundCombo:Disable();
			tSoundCombo:SetAlpha(0.5);

			VUHDO_lnfComboBoxInitFromModel(tSoundCombo);
		end

		if tColorTypeCombo then
			tColorTypeCombo:Show();
			tColorTypeCombo:Disable();
			tColorTypeCombo:SetAlpha(0.5);

			VUHDO_lnfComboBoxInitFromModel(tColorTypeCombo);
		end

		if tCanColorBarCheck then
			tCanColorBarCheck:Show();
			tCanColorBarCheck:Disable();
			tCanColorBarCheck:SetAlpha(0.5);

			VUHDO_lnfCheckButtonInitFromModel(tCanColorBarCheck);
		end

		if tCanColorTextCheck then
			tCanColorTextCheck:Show();
			tCanColorTextCheck:Disable();
			tCanColorTextCheck:SetAlpha(0.5);

			VUHDO_lnfCheckButtonInitFromModel(tCanColorTextCheck);
		end

		if tCustomColorSwatch then
			tCustomColorSwatch:Show();
			tCustomColorSwatch:SetAlpha(0.5);
		end

		if tCanGlowBarCheck then
			tCanGlowBarCheck:Show();
			tCanGlowBarCheck:Disable();
			tCanGlowBarCheck:SetAlpha(0.5);

			VUHDO_lnfCheckButtonInitFromModel(tCanGlowBarCheck);
		end

		if tGlowBarColorSwatch then
			tGlowBarColorSwatch:Show();
			tGlowBarColorSwatch:SetAlpha(0.5);
		end

		if tEnabledCheck then
			tEnabledCheck:Show();
			tEnabledCheck:Disable();
			tEnabledCheck:SetAlpha(0.5);

			VUHDO_lnfCheckButtonInitFromModel(tEnabledCheck);
		end
	end

	return;

end



--
local tNewId;
function VUHDO_auraGroupsOnNewGroup()

	tNewId = VUHDO_generateAuraGroupId();

	VUHDO_CONFIG["AURA_GROUPS"][tNewId] = {
		["type"] = VUHDO_AURA_GROUP_TYPE_FILTER,
		["filter"] = "HELPFUL|PLAYER",
		["excludeFilter"] = nil,
		["priority"] = VUHDO_getNextAuraGroupPriority(),
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = true,
		["canColorText"] = true,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["enabled"] = true,
		["displayName"] = VUHDO_ensureUniqueAuraGroupDisplayName(VUHDO_I18N_NEW .. " " .. VUHDO_I18N_GROUP),
		["isHarmful"] = false,
		["sound"] = nil,
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

	tNewId = VUHDO_cloneAuraGroup(aSourceId, VUHDO_ensureUniqueAuraGroupDisplayName(VUHDO_getAuraGroupDisplayName(aSourceId) .. " (Copy)"));

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
function VUHDO_auraGroupsTypeChanged(aComboBox, aValue, anArrayModel)

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["type"] = tonumber(aValue) or 1;

	if (tonumber(aValue) or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
		if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"] then
			VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"] = { };
		end
	else
		if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["filter"] then
			VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["filter"] = "HELPFUL|PLAYER";
		end
	end

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
local tOldValue = nil;
local tSuccess;
function VUHDO_auraGroupsSoundSelect(aComboBox, aValue, anArrayModel)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["sound"] = (aValue ~= nil and aValue ~= "") and aValue or nil;
	end

	if aValue ~= nil and tOldValue ~= aValue then
		tSuccess = VUHDO_playSoundFile(aValue);

		if tSuccess then
			tOldValue = aValue;
		end
	end

	return;

end



--
local tGroup;
local tIgnoreList;
local tSpellNameById;
local tDisplayName;
local tSecrecy;
local tFrame;
function VUHDO_auraGroupsRefreshIgnorePanel()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then

		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_FILTER then
		return;
	end

	if not tGroup["ignoreList"] then
		tGroup["ignoreList"] = { };
	end

	tIgnoreList = tGroup["ignoreList"];
	table.wipe(VUHDO_AURA_GROUPS_IGNORE_COMBO_MODEL);

	VUHDO_AURA_GROUPS_IGNORE_SELECTED = "";

	for tName, _ in pairs(tIgnoreList) do
		tSpellNameById = VUHDO_resolveSpellId(tName);

		if (tSpellNameById ~= tName) then
			tDisplayName = "[" .. tName .. "] " .. tSpellNameById;
		else
			tDisplayName = tName;
		end

		tSecrecy = VUHDO_getSpellAuraSecrecy(tName);

		if tSecrecy >= 1 then
			tDisplayName = "|cFFFF4444" .. tDisplayName .. "|r";
		end

		tinsert(VUHDO_AURA_GROUPS_IGNORE_COMBO_MODEL, { tName, tDisplayName });
	end

	tFrame = _G["VuhDoNewOptionsAuraGroupsStorePanelIgnorePanel"];

	if tFrame then
		tFrame = _G[tFrame:GetName() .. "IgnoreComboEditBox"];

		if tFrame then
			tFrame:SetText("");
		end

		tFrame = _G["VuhDoNewOptionsAuraGroupsStorePanelIgnorePanelIgnoreCombo"];

		if tFrame then
			VUHDO_lnfComboBoxInitFromModel(tFrame);
		end
	end

	tFrame = _G["VuhDoNewOptionsAuraGroupsStorePanelGroupCombo"];

	if tFrame then
		VUHDO_initAuraGroupsComboModel();
		VUHDO_lnfComboBoxInitFromModel(tFrame);
	end

	return;

end



--
local tText;
local tKey;
local tGroup;
local tDisplayName;
local tEditBox;
function VUHDO_auraGroupsIgnoreAdd()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_FILTER then
		return;
	end

	tEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelIgnorePanelIgnoreComboEditBox"];

	if not tEditBox then
		return;
	end

	tText = tEditBox:GetText();

	if not tText or tText == "" then
		return;
	end

	tText = strtrim(tText);

	if tText == "" then
		return;
	end

	if VUHDO_checkSpellSecrecy(tText) == 1 then
		return;
	end

	if not tGroup["ignoreList"] then
		tGroup["ignoreList"] = { };
	end

	tKey = tonumber(tText);

	if tKey then
		tGroup["ignoreList"][tKey] = true;
	else
		tGroup["ignoreList"][tText] = true;
	end

	tDisplayName = VUHDO_formatAuraSpellDisplayName(tText);
	VUHDO_Msg(string.format(VUHDO_I18N_AURA_ADDED_TO_IGNORE_LIST, tDisplayName));

	tEditBox:SetText("");

	VUHDO_auraGroupsRefreshIgnorePanel();

	return;

end



--
local tText;
local tSpellId;
local tKeyToRemove;
local tGroup;
local tDisplayName;
local tComboEditBox;
function VUHDO_auraGroupsIgnoreDelete()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_FILTER or not tGroup["ignoreList"] then
		return;
	end

	tComboEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelIgnorePanelIgnoreComboEditBox"];

	if not tComboEditBox then
		return;
	end

	tText = tComboEditBox:GetText();

	if not tText or tText == "" then
		return;
	end

	if string.sub(tText, 1, 2) == "|c" and string.len(tText) > 10 then
		tText = string.sub(tText, 11);
	end

	if string.sub(tText, -2) == "|r" then
		tText = string.sub(tText, 1, -3);
	end

	tSpellId = string.match(tText, '^%[([^%]]+)%] (.+)$');

	if tSpellId then
		tText = tSpellId;
	end

	tText = strtrim(tText);
	tDisplayName = VUHDO_formatAuraSpellDisplayName(tText);

	tKeyToRemove = nil;

	if tonumber(tText) and tGroup["ignoreList"][tonumber(tText)] then
		tKeyToRemove = tonumber(tText);
	elseif tGroup["ignoreList"][tText] then
		tKeyToRemove = tText;
	end

	if tKeyToRemove then
		tGroup["ignoreList"][tKeyToRemove] = nil;

		VUHDO_Msg(string.format(VUHDO_I18N_AURA_REMOVED_FROM_IGNORE_LIST, tDisplayName));
	else
		VUHDO_Msg(string.format(VUHDO_I18N_AURA_DOES_NOT_EXIST_IN_IGNORE_LIST, tDisplayName));
	end

	VUHDO_auraGroupsRefreshIgnorePanel();

	return;

end



--
function VUHDO_auraGroupsColorTypeChanged(aComboBox, aValue, anArrayModel)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["colorType"] = aValue or VUHDO_AURA_GROUP_COLOR_OFF;
	end

	VUHDO_auraGroupsRefreshRightPanel();
	VUHDO_rebuildCanColorBarGroupsCache();
	VUHDO_registerAllBouquets(false);

	return;

end



--
function VUHDO_auraGroupsCustomColorChanged(aColorSwatch)

	VUHDO_rebuildCanColorBarGroupsCache();

	return;

end



--
local tCustomColorSwatchForUpdate;
local tCanUseCustomColorForUpdate;
function VUHDO_auraGroupsUpdateCustomColorSwatchState()

	tCustomColorSwatchForUpdate = _G["VuhDoNewOptionsAuraGroupsStorePanelCustomColorTexture"];

	if tCustomColorSwatchForUpdate and tCustomColorSwatchForUpdate:IsShown() then
		tCanUseCustomColorForUpdate = VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_CUSTOM and (VUHDO_AURA_GROUPS_CAN_COLOR_BAR or VUHDO_AURA_GROUPS_CAN_COLOR_TEXT);

		tCustomColorSwatchForUpdate:SetAttribute("disabled", not tCanUseCustomColorForUpdate);
		tCustomColorSwatchForUpdate:SetAlpha(tCanUseCustomColorForUpdate and 1 or 0.5);
	end

	return;

end



--
function VUHDO_auraGroupsCanColorBarChanged(aParent, aValue)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canColorBar"] = aValue;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	VUHDO_auraGroupsUpdateCustomColorSwatchState();

	return;

end



--
function VUHDO_auraGroupsCanColorTextChanged(aParent, aValue)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canColorText"] = aValue;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	VUHDO_auraGroupsUpdateCustomColorSwatchState();

	return;

end



--
function VUHDO_auraGroupsCanGlowBarChanged(aParent, aValue)

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canGlowBar"] = aValue;
	end

	VUHDO_rebuildCanColorBarGroupsCache();

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
function VUHDO_auraGroupsGlowColorChanged(aColorSwatch)

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

	VUHDO_registerAllBouquets(false);
	VUHDO_reloadUI(false);

	return;

end



--
local function VUHDO_getOrCreateAuraGroupEntryItem(anIndex, aParent)

	if sAuraGroupEntryItems[anIndex] == nil then
		sAuraGroupEntryItems[anIndex] = CreateFrame("Frame", "VuhDoAuraGroupEntry" .. anIndex, aParent, "VuhDoAuraGroupListEntryTemplate");
	end

	return sAuraGroupEntryItems[anIndex];

end



--
local tRowName;
local tIcon;
local tValueLabel;
local tTypeLabel;
local tTypeLabelFrame;
local tBouquetButton;
local tRemoveButton;
local tUpButton;
local tDownButton;
local tSecrecy;
local function VUHDO_initAuraGroupEntryItem(aParent, anItemPanel, anIndex, anEntry, anIsBuiltIn)

	anItemPanel["vuhdo_entryIdx"] = anIndex;

	anItemPanel:ClearAllPoints();
	VUHDO_PixelUtil.SetPoint(anItemPanel, "TOPLEFT", aParent:GetName(), "TOPLEFT", 0, -(anIndex - 1) * VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT);

	tRowName = anItemPanel:GetName();

	tIcon = _G[tRowName .. "IconTexture"];

	if tIcon then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
			tIcon:SetTexture(nil);
		else
			tIcon:SetTexture(VUHDO_getGlobalIcon(tostring(anEntry["value"])));
		end
	end

	tValueLabel = _G[tRowName .. "ValueLabelLabel"];

	if tValueLabel then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
			tValueLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_EMPTY);
		else
			tValueLabel:SetText(VUHDO_formatAuraSpellDisplayName(tostring(anEntry["value"] or "")));
		end

		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			tSecrecy = VUHDO_getSpellAuraSecrecy(anEntry["value"]);

			if tSecrecy == 1 or tSecrecy == 2 then
				tValueLabel:SetTextColor(1, 0.3, 0.3, 1);
			else
				tValueLabel:SetTextColor(0.4, 0.4, 1, 1);
			end
		else
			tValueLabel:SetTextColor(0.4, 0.4, 1, 1);
		end
	end

	tTypeLabel = _G[tRowName .. "TypeLabelLabel"];
	tTypeLabelFrame = _G[tRowName .. "TypeLabel"];
	tBouquetButton = _G[tRowName .. "BouquetButton"];

	if tTypeLabel then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
			tTypeLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_EMPTY);
		elseif anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
			tTypeLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_BOUQUET);
		else
			tTypeLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_SPELL);
		end
	end

	if tTypeLabelFrame and tBouquetButton then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
			tTypeLabelFrame:Hide();

			tBouquetButton:Show();

			tBouquetButton:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_BOUQUET);
			VUHDO_lnfSetTooltip(tBouquetButton, VUHDO_I18N_TT.K732);
		else
			tTypeLabelFrame:Show();

			tBouquetButton:Hide();
		end
	end

	tRemoveButton = _G[tRowName .. "RemoveButton"];
	tUpButton = _G[tRowName .. "UpButton"];
	tDownButton = _G[tRowName .. "DownButton"];

	if tRemoveButton then
		tRemoveButton:SetText("");
		VUHDO_lnfSetTooltip(tRemoveButton, VUHDO_I18N_TT.K726);
	end

	if tUpButton then
		VUHDO_lnfSetTooltip(tUpButton, VUHDO_I18N_TT.K727);
	end

	if tDownButton then
		VUHDO_lnfSetTooltip(tDownButton, VUHDO_I18N_TT.K728);
	end

	if anIsBuiltIn then
		if tRemoveButton then
			tRemoveButton:Disable();
			tRemoveButton:SetAlpha(0.5);
		end

		if tUpButton then
			tUpButton:Disable();
			tUpButton:SetAlpha(0.5);
		end

		if tDownButton then
			tDownButton:Disable();
			tDownButton:SetAlpha(0.5);
		end
	else
		if tRemoveButton then
			tRemoveButton:Enable();
			tRemoveButton:SetAlpha(1);
		end

		if tUpButton then
			tUpButton:Enable();
			tUpButton:SetAlpha(1);
		end

		if tDownButton then
			tDownButton:Enable();
			tDownButton:SetAlpha(1);
		end
	end

	anItemPanel:Show();

	return;

end



--
local tPanel;
local tGroup;
local tEntries;
local tEntryScrollChild;
local tIsBuiltInList;
function VUHDO_auraGroupsRefreshListEntries()

	for _, tPanel in pairs(sAuraGroupEntryItems) do
		tPanel:Hide();
	end

	if not sSelectedGroupId then
		return;
	end

	tGroup = VUHDO_getAuraGroupRaw(sSelectedGroupId);

	if not tGroup or (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	tIsBuiltInList = VUHDO_isBuiltInAuraGroup(sSelectedGroupId);

	tEntries = tGroup["entries"] or { };
	tEntryScrollChild = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelEntryScrollEntryScrollChild"];

	if not tEntryScrollChild then
		return;
	end

	for tIdx, tEntry in ipairs(tEntries) do
		tPanel = VUHDO_getOrCreateAuraGroupEntryItem(tIdx, tEntryScrollChild);
		VUHDO_initAuraGroupEntryItem(tEntryScrollChild, tPanel, tIdx, tEntry, tIsBuiltInList);
	end

	if #tEntries > 0 then
		VUHDO_PixelUtil.SetHeight(tEntryScrollChild, #tEntries * VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT);
	else
		VUHDO_PixelUtil.SetHeight(tEntryScrollChild, VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT);
	end

	return;

end



--
local tSpellComboEditBox;
local tText;
local tValue;
local tSpellIdFromMatch;
function VUHDO_auraGroupsListAddSpell()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if tGroup["type"] ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	tSpellComboEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelNewSpellComboEditBox"];

	if not tSpellComboEditBox then
		return;
	end

	tText = tSpellComboEditBox:GetText();

	if not tText or tText == "" then
		return;
	end

	tText = strtrim(tText);

	if tText == "" then
		return;
	end

	tSpellIdFromMatch = string.match(tText, "^%[([^%]]+)%]");

	if tSpellIdFromMatch then
		tValue = tonumber(tSpellIdFromMatch) or tSpellIdFromMatch;
	else
		tValue = tonumber(tText) or tText;
	end

	if VUHDO_checkSpellSecrecy(tValue) == 1 then
		return;
	end

	if not tGroup["entries"] then
		tGroup["entries"] = { };
	end

	tinsert(tGroup["entries"], {
		["entryType"] = VUHDO_AURA_LIST_ENTRY_SPELL,
		["value"] = tValue,
		["mine"] = true,
		["others"] = false,
	});

	tSpellComboEditBox:SetText("");
	VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tBouquetName;
function VUHDO_auraGroupsListAddBouquet()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if tGroup["type"] ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	tBouquetName = VUHDO_AURA_GROUPS_NEW_BOUQUET_SELECTED;

	if not tBouquetName or tBouquetName == "" then
		return;
	end

	if not tGroup["entries"] then
		tGroup["entries"] = { };
	end

	tinsert(tGroup["entries"], {
		["entryType"] = VUHDO_AURA_LIST_ENTRY_BOUQUET,
		["value"] = tBouquetName,
	});

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tGroup;
function VUHDO_auraGroupsListAddEmpty()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if tGroup["type"] ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	if not tGroup["entries"] then
		tGroup["entries"] = { };
	end

	tinsert(tGroup["entries"], {
		["entryType"] = VUHDO_AURA_LIST_ENTRY_EMPTY,
	});

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tItemPanel;
local tIdx;
local tGroup;
local tEntry;
function VUHDO_auraGroupEntryBouquetButtonClicked(aButton)

	tItemPanel = aButton:GetParent();

	if not tItemPanel then
		return;
	end

	tIdx = tItemPanel["vuhdo_entryIdx"];

	if not tIdx or not sSelectedGroupId then
		return;
	end

	tGroup = VUHDO_getAuraGroupRaw(sSelectedGroupId);

	if not tGroup or not tGroup["entries"] then
		return;
	end

	tEntry = tGroup["entries"][tIdx];

	if not tEntry or tEntry["entryType"] ~= VUHDO_AURA_LIST_ENTRY_BOUQUET then
		return;
	end

	VUHDO_BOUQUETS["SELECTED"] = tEntry["value"];

	if VUHDO_MENU_RETURN_TARGET_MAIN ~= nil or VUHDO_MENU_RETURN_TARGET ~= nil then
		VUHDO_MENU_RETURN_TARGET_MAIN_SAVED = VUHDO_MENU_RETURN_TARGET_MAIN;
		VUHDO_MENU_RETURN_TARGET_SAVED = VUHDO_MENU_RETURN_TARGET;
	end

	VUHDO_MENU_RETURN_TARGET_MAIN = VuhDoNewOptionsTabbedFrameTabsPanelAurasRadioButton;
	VUHDO_MENU_RETURN_TARGET = VuhDoNewOptionsAuraRadioPanelGroupsRadioButton;

	VUHDO_newOptionsTabbedClickedClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);
	VUHDO_lnfRadioButtonClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);
	VUHDO_lnfTabRadioButtonClicked(VuhDoNewOptionsGeneralRadioPanelBouquetRadioButton);

	return;

end



--
local tPanel;
local tIdx;
function VUHDO_auraGroupEntryRemoveOnClick(aButton)

	tPanel = aButton:GetParent();

	if not tPanel then
		return;
	end

	tIdx = tPanel["vuhdo_entryIdx"];

	if not tIdx then
		return;
	end

	VUHDO_auraGroupsListRemoveEntry(tIdx);

	return;

end



--
local tPanel;
local tIdx;
function VUHDO_auraGroupEntryUpOnClick(aButton)

	tPanel = aButton:GetParent();

	if not tPanel then
		return;
	end

	tIdx = tPanel["vuhdo_entryIdx"];

	if not tIdx then
		return;
	end

	VUHDO_auraGroupsListMoveEntry(tIdx, -1);

	return;

end



--
local tPanel;
local tIdx;
function VUHDO_auraGroupEntryDownOnClick(aButton)

	tPanel = aButton:GetParent();

	if not tPanel then
		return;
	end

	tIdx = tPanel["vuhdo_entryIdx"];

	if not tIdx then
		return;
	end

	VUHDO_auraGroupsListMoveEntry(tIdx, 1);

	return;

end



--
local tEntries;
function VUHDO_auraGroupsListRemoveEntry(anIndex)

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tEntries = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"];

	if not tEntries or anIndex < 1 or anIndex > #tEntries then
		return;
	end

	tremove(tEntries, anIndex);

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tEntries;
local tSwap;
function VUHDO_auraGroupsListMoveEntry(anIndex, aDirection)

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tEntries = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"];

	if not tEntries or anIndex < 1 or anIndex > #tEntries then
		return;
	end

	tSwap = anIndex + aDirection;

	if tSwap < 1 or tSwap > #tEntries then
		return;
	end

	tSwap = tEntries[anIndex];
	tEntries[anIndex] = tEntries[anIndex + aDirection];
	tEntries[anIndex + aDirection] = tSwap;

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tGroupsRadio;
function VUHDO_auraGroupsOnShow()

	if VUHDO_AURA_GROUPS_PENDING_SELECTION then
		sSelectedGroupId = VUHDO_AURA_GROUPS_PENDING_SELECTION;

		VUHDO_AURA_GROUPS_SELECTED = VUHDO_AURA_GROUPS_PENDING_SELECTION;
		VUHDO_AURA_GROUPS_PENDING_SELECTION = nil;
	end

	tGroupsRadio = _G["VuhDoNewOptionsAuraRadioPanelGroupsRadioButton"];

	if tGroupsRadio and tGroupsRadio:GetChecked() then
		_G["VuhDoNewOptionsAuraIgnore"]:Hide();
	else
		_G["VuhDoNewOptionsAuraGroups"]:Hide();
		_G["VuhDoNewOptionsAuraIgnore"]:Show();
	end

	VUHDO_auraGroupsRefreshList();

	if sSelectedGroupId and VUHDO_getAuraGroupRaw(sSelectedGroupId) then
		VUHDO_auraGroupsOnGroupSelected(sSelectedGroupId);
	else
		sSelectedGroupId = nil;
	end

	if _G["VuhDoNewOptionsAuraGroupsBackButton"] then
		_G["VuhDoNewOptionsAuraGroupsBackButton"]:SetShown(VUHDO_MENU_RETURN_TARGET ~= nil or VUHDO_MENU_RETURN_TARGET_MAIN ~= nil);
	end

	return;

end



--
function VUHDO_auraGroupsBackButtonClicked(aPanel)

	if VUHDO_MENU_RETURN_TARGET_MAIN ~= nil then
		VUHDO_newOptionsTabbedClickedClicked(VUHDO_MENU_RETURN_TARGET_MAIN);
		VUHDO_lnfRadioButtonClicked(VUHDO_MENU_RETURN_TARGET_MAIN);

		VUHDO_MENU_RETURN_TARGET_MAIN = nil;
	end

	if VUHDO_MENU_RETURN_TARGET ~= nil then
		VUHDO_lnfTabRadioButtonClicked(VUHDO_MENU_RETURN_TARGET);

		VUHDO_MENU_RETURN_TARGET = nil;
	end

	return;

end