local _;
local pairs = pairs;
local tinsert = table.insert;
local twipe = table.wipe;
local ceil = math.ceil;
local min = math.min;

local VUHDO_BUFF_PANEL_X;
local VUHDO_BUFF_PANEL_Y;
local VUHDO_BUFF_PANEL_WIDTH;
local VUHDO_BUFF_PANEL_HEIGHT;
local VUHDO_PANEL_INSET_X = 10;
local VUHDO_PANEL_INSET_Y = 10;

local VUHDO_BUFF_PANEL_BASE_HEIGHT = nil;

local sBuffPanelBaseHeight = 46;
local sBuffPanelWidth = 229;
local sBuffAreaWidth = 515;
local sBuffAreaHeight = 435;
local sBuffAreaSafetyMargin = 8;
local sPanelMaxHeight;
local sPanelHeights = { };
local sLayoutIndex = 0;

-- must match VuhDoBuffWatchSetup.xml template heights
local sSubPanelTemplateHeights = {
	["VuhDoBuffSetupDedicatedPanelTemplate"] = 33,
	["VuhDoBuffSetupFilterTemplate"] = 33,
	["VuhDoBuffSetupUniqueSingleTargetPanelTemplate"] = 92,
};



--
local tUniqueModeTable;
local function VUHDO_buffWatchSetupGetTargetModeTable()

	if not tUniqueModeTable then
		tUniqueModeTable = {
			{ "name", VUHDO_I18N_BW_TARGET_BY_NAME },
			{ "target", VUHDO_I18N_BW_TARGET },
			{ "focus", VUHDO_I18N_BW_FOCUS },
		};

		for _, tFilter in pairs(VUHDO_BUFF_FILTER_COMBO_TABLE) do
			if tFilter[1] >= VUHDO_ID_MELEE_TANK and tFilter[1] <= VUHDO_ID_RANGED_HEAL then
				tinsert(tUniqueModeTable, { tostring(tFilter[1]), tFilter[2] });
			end
		end
	end

	return tUniqueModeTable;

end



do
	--
	local tCombo;
	local tEditBox;
	local tNameLabel;
	local tModeLabel;
	local tValue;
	function VUHDO_buffWatchSetupRefreshTargetMode(aGenericPanel)

		tCombo = _G[aGenericPanel:GetName() .. "TargetModeComboBox"];
		tEditBox = _G[aGenericPanel:GetName() .. "PlayerNameEditBox"];
		tNameLabel = _G[aGenericPanel:GetName() .. "PlayerNameLabel"];
		tModeLabel = _G[aGenericPanel:GetName() .. "TargetModeLabel"];

		if not tCombo or not tEditBox then
			return;
		end

		tValue = tCombo:GetAttribute("selected_value") or "name";

		if tValue == "name" then
			tEditBox:Show();
			tNameLabel:Show();
		else
			tEditBox:Hide();
			tNameLabel:Hide();
		end

		if tModeLabel then
			tModeLabel:Show();
		end

		tCombo:Show();

		return;

	end
end



--
function VUHDO_buffWatchSetupTargetModeChanged(aComboBox, aValue)

	if aValue ~= aComboBox:GetAttribute("selected_value") then
		aComboBox:SetAttribute("selected_value", aValue);
		VUHDO_buffWatchSetupRefreshTargetMode(aComboBox:GetParent());
		VUHDO_buffChanged(aComboBox);
	end

	return;

end



--
local function VUHDO_getGenericPanel(aCategoryName)
	return _G["VuhDoBuffSetupPanel" .. aCategoryName .. "GenericPanel"];
end



--
local function VUHDO_getBuffPanelCheckBox(aCategoryName)
	return _G["VuhDoBuffSetupPanel" .. aCategoryName .. "EnableCheckButton"];
end



--
local function VUHDO_buffSetupStoreSettings()
	local tGenericPanel;
	local tFound = false;

	for tCategoryName, tCategoryBuffs in pairs(VUHDO_getPlayerClassBuffs()) do
		local tSettings = VUHDO_BUFF_SETTINGS[tCategoryName];
		tGenericPanel = VUHDO_getGenericPanel(tCategoryName);

		if (VUHDO_getBuffPanelCheckBox(tCategoryName) ~= nil) then
			tFound = true;

			if (tSettings ~= nil) then
				tSettings["enabled"] = VUHDO_forceBooleanValue(VUHDO_getBuffPanelCheckBox(tCategoryName):GetChecked());
			end

			if (tGenericPanel ~= nil) then
				local tVariant = tCategoryBuffs[1];
				local tBuffTarget = tVariant[2];

				if (VUHDO_BUFF_TARGET_UNIQUE == tBuffTarget) then
					local tTargetModeCombo = _G[tGenericPanel:GetName() .. "TargetModeComboBox"];
					local tEditBox = _G[tGenericPanel:GetName() .. "PlayerNameEditBox"];

					if tTargetModeCombo then
						tSettings["targetMode"] = VUHDO_comboGetSelectedBuff(tTargetModeCombo) or "name";
					end

					if tSettings["targetMode"] == "name" then
						tSettings["name"] = tEditBox:GetText();
					else
						tSettings["name"] = nil;
					end
				else -- Aura, Totem, own group, self
					if (#tCategoryBuffs > 1) then
						local tCombo = _G[tGenericPanel:GetName() .. "DedicatedComboBox"];
						tSettings["buff"] = VUHDO_comboGetSelectedBuff(tCombo);
					end
				end
			end
		end
	end

	if (tFound) then
		VUHDO_reloadBuffPanel();
	end
end



--
local function VUHDO_buffSetupNewRowCheck(aWidth, anAddHeight)

	if (VUHDO_BUFF_PANEL_Y > VUHDO_BUFF_PANEL_HEIGHT) then
		VUHDO_BUFF_PANEL_HEIGHT = VUHDO_BUFF_PANEL_Y;
	end

	if (VUHDO_BUFF_PANEL_Y + anAddHeight > sPanelMaxHeight) then
		VUHDO_BUFF_PANEL_X = VUHDO_BUFF_PANEL_X + aWidth;
		VUHDO_BUFF_PANEL_Y = VUHDO_PANEL_INSET_Y;
	end

	if (VUHDO_BUFF_PANEL_X > VUHDO_BUFF_PANEL_WIDTH) then
		VUHDO_BUFF_PANEL_WIDTH = VUHDO_BUFF_PANEL_X;
	end

end



--
function VUHDO_buffChanged(aComponent)
	VUHDO_buffSetupStoreSettings();
end



--
local tLayoutHeight;
local function VUHDO_addGenericBuffFrame(aBuffVariant, aFrameTemplateName, aCategoryName, anIsPresent)

	local tBuffPanel, tGenericFrame;

	-- main panel
	local tFrameName = "VuhDoBuffSetupPanel" .. aCategoryName;
	tBuffPanel = _G[tFrameName];

	if (tBuffPanel == nil) then
		tBuffPanel = CreateFrame("Frame", tFrameName, VuhDoNewOptionsBuffsGeneric, "VuhDoBuffSetupPanelTemplate");

		VUHDO_BUFF_PANEL_BASE_HEIGHT = tBuffPanel:GetHeight();
	end

	_G[tBuffPanel:GetName() .. "BuffNameLabelLabel"]:SetText(aCategoryName);

	if (anIsPresent) then
		_G[tBuffPanel:GetName() .. "BuffTextureTexture"]:SetTexture(VUHDO_BUFFS[aBuffVariant[1]].icon);
	else
		_G[tBuffPanel:GetName() .. "BuffTextureTexture"]:SetTexture("interface\\icons\\spell_chargenegative");
	end

	local tInFrameY = VUHDO_BUFF_PANEL_BASE_HEIGHT;

	if (aFrameTemplateName ~= nil) then
		tGenericFrame = _G[tFrameName .. "GenericPanel"];

		if (tGenericFrame == nil) then
			tGenericFrame = CreateFrame("Frame", "$parentGenericPanel", tBuffPanel, aFrameTemplateName);
		end

		VUHDO_PixelUtil.SetPoint(tGenericFrame, "TOPLEFT", tBuffPanel:GetName(), "TOPLEFT", 0, -tInFrameY);
		tInFrameY = tInFrameY + tGenericFrame:GetHeight() + 5;
	end

	sLayoutIndex = sLayoutIndex + 1;
	tLayoutHeight = sPanelHeights[sLayoutIndex] or tInFrameY;

	VUHDO_buffSetupNewRowCheck(sBuffPanelWidth, tLayoutHeight);
	VUHDO_PixelUtil.SetPoint(tBuffPanel, "TOPLEFT", "VuhDoNewOptionsBuffsGeneric", "TOPLEFT", VUHDO_BUFF_PANEL_X, -VUHDO_BUFF_PANEL_Y);
	VUHDO_PixelUtil.SetHeight(tBuffPanel, tLayoutHeight);
	tBuffPanel:Show();

	VUHDO_BUFF_PANEL_Y = VUHDO_BUFF_PANEL_Y + tLayoutHeight;

	return tBuffPanel, tGenericFrame;

end



--
local function VUHDO_setupStaticBuffPanel(aCategoryName, aBuffPanel, anIsPresent)

	local tBuffSettings;

	if (VUHDO_BUFF_SETTINGS[aCategoryName] == nil) then
		VUHDO_BUFF_SETTINGS[aCategoryName] = { ["enabled"] = anIsPresent };
	end

	if (VUHDO_BUFF_SETTINGS[aCategoryName]["missingColor"] == nil) then
		VUHDO_BUFF_SETTINGS[aCategoryName]["missingColor"] = {
			["show"] = false,
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		}
	end

	tBuffSettings = VUHDO_BUFF_SETTINGS[aCategoryName];

	local tEnableCheckButton = _G[aBuffPanel:GetName() .. "EnableCheckButton"];
	tEnableCheckButton:SetChecked(tBuffSettings["enabled"]);
	tEnableCheckButton:SetShown(anIsPresent);
	VUHDO_lnfCheckButtonClicked(tEnableCheckButton);

	local tMissButton = _G[aBuffPanel:GetName() .. "MissingCheckButton"];
	VUHDO_lnfSetModel(tMissButton, "VUHDO_BUFF_SETTINGS." .. aCategoryName .. ".missingColor.show");
	VUHDO_lnfSetTooltip(tMissButton, VUHDO_I18N_TT.K386);
	tMissButton:Show();

	VUHDO_lnfCheckButtonInitFromModel(tMissButton);

	local tMissTexture = _G[aBuffPanel:GetName() .. "MissingTexture"];
	VUHDO_lnfSetModel(tMissTexture, "VUHDO_BUFF_SETTINGS." .. aCategoryName .. ".missingColor");
	VUHDO_lnfSetTooltip(tMissTexture, VUHDO_I18N_TT.K385);
	tMissTexture:Show();

	VUHDO_lnfColorSwatchInitFromModel(tMissTexture);

	return;

end



--
local function VUHDO_buffNameAvail(aBuffName)
	return VUHDO_BUFFS[aBuffName] ~= nil and aBuffName or nil;
end



--
local function VUHDO_getAllBuffNamesAvail(someCategoryBuffs)
	local tBuffNames = { };
	local tName;

	for _, tVariant in ipairs(someCategoryBuffs) do
		tName = tVariant[1];
		if (VUHDO_BUFFS[tName] ~= nil) then
			tinsert(tBuffNames, tName);
		end
	end

	return tBuffNames;
end



--
local tVariant;
local tTargetType;
local tKnownVariants;
local tPanelTemplate;
local function VUHDO_buffSetupResolvePanelTemplate(aCategoryName, someCategoryBuffs)

	tKnownVariants = VUHDO_getAllBuffNamesAvail(someCategoryBuffs);

	tVariant = nil;

	if (#tKnownVariants > 0) then
		tVariant = VUHDO_getBuffInfoForName(tKnownVariants[1], aCategoryName);
	end

	if (tVariant == nil) then
		tVariant = someCategoryBuffs[1];
	end

	tTargetType = tVariant[2];

	if (VUHDO_BUFF_TARGET_UNIQUE == tTargetType) then
		tPanelTemplate = "VuhDoBuffSetupUniqueSingleTargetPanelTemplate";
	elseif (VUHDO_BUFF_TARGET_RAID == tTargetType or VUHDO_BUFF_TARGET_SINGLE == tTargetType) then
		if (#someCategoryBuffs > 1) then
			tPanelTemplate = "VuhDoBuffSetupDedicatedPanelTemplate";
		else
			tPanelTemplate = "VuhDoBuffSetupFilterTemplate";
		end
	else
		if (#someCategoryBuffs > 1) then
			tPanelTemplate = "VuhDoBuffSetupDedicatedPanelTemplate";
		else
			tPanelTemplate = nil;
		end
	end

	return tPanelTemplate;

end



--
local tTemplateHeight;
local tHeight;
local function VUHDO_buffSetupMeasurePanelHeight(aCategoryName, someCategoryBuffs)

	tPanelTemplate = VUHDO_buffSetupResolvePanelTemplate(aCategoryName, someCategoryBuffs);

	tHeight = sBuffPanelBaseHeight;

	if (tPanelTemplate ~= nil) then
		tTemplateHeight = sSubPanelTemplateHeights[tPanelTemplate];

		if (tTemplateHeight ~= nil) then
			tHeight = tHeight + tTemplateHeight + 5;
		end
	end

	return tHeight;

end



--
local tCols;
local tY;
local function VUHDO_buffSetupCountColumns(aThreshold)

	tCols = 1;
	tY = VUHDO_PANEL_INSET_Y;

	for tIdx = 1, #sPanelHeights do
		tHeight = sPanelHeights[tIdx];

		if (tY + tHeight > aThreshold) then
			tCols = tCols + 1;

			tY = VUHDO_PANEL_INSET_Y;
		end

		tY = tY + tHeight;
	end

	return tCols;

end



--
local tMaxPanel;
local tLow;
local tHigh;
local tMid;
local function VUHDO_buffSetupFindMinThreshold(aTargetCols, aTotalHeight)

	tMaxPanel = 0;

	for tIdx = 1, #sPanelHeights do
		if (sPanelHeights[tIdx] > tMaxPanel) then
			tMaxPanel = sPanelHeights[tIdx];
		end
	end

	tLow = VUHDO_PANEL_INSET_Y + tMaxPanel;
	tHigh = aTotalHeight;

	while (tLow < tHigh) do
		tMid = (tLow + tHigh);
		tMid = (tMid - tMid % 2) / 2;

		if (VUHDO_buffSetupCountColumns(tMid) <= aTargetCols) then
			tHigh = tMid;
		else
			tLow = tMid + 1;
		end
	end

	return tLow;

end



--
local function VUHDO_setBuffBoxIcon(aGenericPanel, aBuffName)
	_G[aGenericPanel:GetParent():GetName() .. "BuffTextureTexture"]
		:SetTexture((VUHDO_BUFFS[aBuffName] or {})["icon"]);
end



--
local function VUHDO_addBuffsToCombo(aComboBox, someBuffNames, aSelectedValue, tIsEmpty)
	local tEntryTable = { };

	if (tIsEmpty) then
		tinsert(tEntryTable, { "", "-- " .. VUHDO_I18N_EMPTY_HOTS .. " --" } );
	end

	for _, tBuffName in ipairs(someBuffNames) do
		tinsert(tEntryTable, { tBuffName, tBuffName });
	end

	aComboBox:SetAttribute("combo_table", tEntryTable);
	VUHDO_lnfComboInitItems(aComboBox);
	VUHDO_lnfComboSetSelectedValue(aComboBox, aSelectedValue);
end



--
local function VUHDO_setupGenericBuffPanel(aBuffVariant, aGenericPanel, someCategoryBuffs, aCategoryName)
	local tBuffTarget = aBuffVariant[2];
	local tSettings = VUHDO_BUFF_SETTINGS[aCategoryName];

	if (VUHDO_BUFF_TARGET_RAID == tBuffTarget or VUHDO_BUFF_TARGET_SINGLE == tBuffTarget) then
		if (#someCategoryBuffs > 1) then
			local tCategBuffNames = VUHDO_getAllBuffNamesAvail(someCategoryBuffs);
			local tCombo = _G[aGenericPanel:GetName() .. "DedicatedComboBox"];
			VUHDO_addBuffsToCombo(tCombo, tCategBuffNames, tSettings["buff"], true);
			VUHDO_setBuffBoxIcon(aGenericPanel, VUHDO_comboGetSelectedBuff(tCombo));
		else
			local tComboBox = _G[aGenericPanel:GetName() .. "ComboBox"];
			VUHDO_setComboModel(tComboBox, "VUHDO_BUFF_SETTINGS." .. aCategoryName .. ".filter", VUHDO_BUFF_FILTER_COMBO_TABLE, VUHDO_I18N_TRACK_BUFFS_FOR);
			VUHDO_lnfComboBoxInitFromModel(tComboBox);
		end
	elseif (VUHDO_BUFF_TARGET_UNIQUE == tBuffTarget) then
		if (tSettings["name"] == nil) then
			tSettings["name"] = VUHDO_PLAYER_NAME;
		end

		local tEditBox = _G[aGenericPanel:GetName() .. "PlayerNameEditBox"];
		local tTargetModeCombo = _G[aGenericPanel:GetName() .. "TargetModeComboBox"];

		tEditBox:SetText(tSettings["name"]);

		if tTargetModeCombo then
			tTargetModeCombo:SetAttribute("combo_table", VUHDO_buffWatchSetupGetTargetModeTable());
			VUHDO_lnfComboInitItems(tTargetModeCombo);
			VUHDO_lnfComboSetSelectedValue(tTargetModeCombo, tSettings["targetMode"] or "name");
			VUHDO_buffWatchSetupRefreshTargetMode(aGenericPanel);
		end
	else -- Aura, Totem, own group, self
		if (tSettings["buff"] == nil) then
			tSettings["buff"] = VUHDO_buffNameAvail(aBuffVariant[1]);
		end

		if (#someCategoryBuffs > 1) then
			local tCategBuffNames = VUHDO_getAllBuffNamesAvail(someCategoryBuffs);
			local tCombo = _G[aGenericPanel:GetName() .. "DedicatedComboBox"];
			VUHDO_addBuffsToCombo(tCombo, tCategBuffNames, tSettings["buff"], true);
			VUHDO_setBuffBoxIcon(aGenericPanel, VUHDO_comboGetSelectedBuff(tCombo));
		end
	end
end



--
local function VUHDO_buildBuffSetupGenericPanel(aCategoryName, someCategoryBuffs)
	local tBuffPanel;
	local tGenericPanel;
	local tIsPresent;

	tKnownVariants = VUHDO_getAllBuffNamesAvail(someCategoryBuffs);

	tVariant = nil;
	if (#tKnownVariants > 0) then
		tVariant = VUHDO_getBuffInfoForName(tKnownVariants[1], aCategoryName);
		tIsPresent = true;
	else
		tIsPresent = false;
	end

	if (tVariant == nil) then
		tVariant = someCategoryBuffs[1];
	end

	tPanelTemplate = VUHDO_buffSetupResolvePanelTemplate(aCategoryName, someCategoryBuffs);

	tBuffPanel, tGenericPanel = VUHDO_addGenericBuffFrame(tVariant, tPanelTemplate, aCategoryName, tIsPresent);
	VUHDO_setupStaticBuffPanel(aCategoryName, tBuffPanel, tIsPresent);
	VUHDO_setupGenericBuffPanel(tVariant, tGenericPanel, someCategoryBuffs, aCategoryName);

	return tBuffPanel, tGenericPanel;
end



--
local tBuffPanel;
local tCurPanel;
local tIndex;
local tTotalHeight;
local tNumPanels;
local tAreaWidth;
local tAreaHeight;
local tBestScale;
local tBestThreshold;
local tColHeight;
local tScale;
local tNumber;
local tContentPanel;
function VUHDO_buildAllBuffSetupGenerericPanel()

	twipe(sPanelHeights);

	tTotalHeight = 0;
	tNumPanels = 0;
	tIndex = 0;

	for _, _ in pairs(VUHDO_getPlayerClassBuffs()) do
		for tCategoryName, tAllCategoryBuffs in pairs(VUHDO_getPlayerClassBuffs()) do
			tNumber = VUHDO_BUFF_ORDER[tCategoryName];

			if (tNumber == tIndex + 1) then
				tIndex = tIndex + 1;

				tHeight = VUHDO_buffSetupMeasurePanelHeight(tCategoryName, tAllCategoryBuffs);

				tinsert(sPanelHeights, tHeight);

				tTotalHeight = tTotalHeight + tHeight;

				tNumPanels = tNumPanels + 1;
			end
		end
	end

	if (tNumPanels == 0) then
		return;
	end

	tAreaWidth = sBuffAreaWidth;
	tAreaHeight = sBuffAreaHeight;

	tContentPanel = VuhDoNewOptionsBuffsGeneric:GetParent();

	if (tContentPanel ~= nil) then
		if (tContentPanel:GetWidth() > 0) then
			tAreaWidth = tContentPanel:GetWidth();
		end

		if (tContentPanel:GetHeight() > 0) then
			tAreaHeight = tContentPanel:GetHeight();
		end
	end

	tAreaWidth = tAreaWidth - 2 * VUHDO_PANEL_INSET_X;
	tAreaHeight = tAreaHeight - 2 * VUHDO_PANEL_INSET_Y;

	tAreaWidth = tAreaWidth - sBuffAreaSafetyMargin;
	tAreaHeight = tAreaHeight - sBuffAreaSafetyMargin;

	tBestScale = 0;
	tBestThreshold = tTotalHeight;

	for tTargetCols = 1, tNumPanels do
		tColHeight = VUHDO_buffSetupFindMinThreshold(tTargetCols, tTotalHeight);
		tScale = min(tAreaWidth / (tTargetCols * sBuffPanelWidth), tAreaHeight / tColHeight, 1);

		if (tScale > tBestScale) then
			tBestScale = tScale;

			tBestThreshold = tColHeight;
		end
	end

	sPanelMaxHeight = tBestThreshold;

	if (tBestScale > 0) then
		sPanelMaxHeight = tAreaHeight / tBestScale;
	end

	VUHDO_BUFF_PANEL_X = VUHDO_PANEL_INSET_X;
	VUHDO_BUFF_PANEL_Y = VUHDO_PANEL_INSET_Y;
	VUHDO_BUFF_PANEL_WIDTH = 0;
	VUHDO_BUFF_PANEL_HEIGHT = 0;

	tBuffPanel = nil;
	tIndex = 0;
	sLayoutIndex = 0;

	for _, _ in pairs(VUHDO_getPlayerClassBuffs()) do
		for tCategoryName, tAllCategoryBuffs in pairs(VUHDO_getPlayerClassBuffs()) do
			tNumber = VUHDO_BUFF_ORDER[tCategoryName];

			if (tNumber == tIndex + 1) then
				tIndex = tIndex + 1;

				tCurPanel, _ = VUHDO_buildBuffSetupGenericPanel(tCategoryName, tAllCategoryBuffs);

				if (tBuffPanel == nil) then
					tBuffPanel = tCurPanel;
				end
			end
		end
	end

	if (tBuffPanel == nil) then
		return;
	end

	VuhDoNewOptionsBuffsGeneric:SetScale(tBestScale);

	return;

end



--
function VUHDO_buffWatchSetupDedicatedChanged(aComboBox, aValue)
	if (aValue ~= aComboBox:GetAttribute("selected_value")) then
		aComboBox:SetAttribute("selected_value", aValue);
		VUHDO_buffChanged(aComboBox);
	end
end



--
function VUHDO_buffWatchSetupFilterChanged(aComboBox, aValue, anArrayModel)
	if (aValue ~= nil) then
		if (VUHDO_ID_ALL == aValue) then
			table.wipe(anArrayModel);
			anArrayModel[VUHDO_ID_ALL] = true;
		else
			anArrayModel[VUHDO_ID_ALL] = nil;
		end
		VUHDO_lnfComboSetSelectedValue(aComboBox, nil);
		VUHDO_updateBuffRaidGroup();
	end
end



--
function VUHDO_comboGetSelectedBuff(aComboBox)
	if (aComboBox == nil) then
		return "";
	else
		return aComboBox:GetAttribute("selected_value");
	end
end



--
function VUHDO_buffUpButtonClicked(aButton)
	local tCategName = strsub(aButton:GetParent():GetName(), 20);
	local tIndex = nil;
	local tPreIndex = nil;

	for tCategSpec, _ in pairs(VUHDO_BUFF_ORDER) do
		if (strfind(tCategSpec, tCategName, 1, true)) then
			tIndex = tCategSpec;
			break;
		end
	end

	local tPredec = -1;
	local tCurrOrder = VUHDO_BUFF_ORDER[tIndex];
	if (tIndex ~= nil) then
		for tCategSpec, tNumber in pairs(VUHDO_BUFF_ORDER) do
			if (tNumber > tPredec and tNumber < tCurrOrder) then
				tPredec = tNumber;
				tPreIndex = tCategSpec;
			end
		end
	end

	if (tPredec > 0) then
		VUHDO_BUFF_ORDER[tPreIndex] = tCurrOrder;
		VUHDO_BUFF_ORDER[tIndex] = tPredec;
	end

	VUHDO_buildAllBuffSetupGenerericPanel();
	VUHDO_buffSetupStoreSettings();
end



--
function VUHDO_buffDownButtonClicked(aButton)
	local tCategName = strsub(aButton:GetParent():GetName(), 20);
	local tIndex = nil;
	local tPreIndex = nil;

	for tCategSpec, _ in pairs(VUHDO_BUFF_ORDER) do
		if (strfind(tCategSpec, tCategName, 1, true)) then
			tIndex = tCategSpec;
			break;
		end
	end

	local tPredec = 1000;
	local tCurrOrder = VUHDO_BUFF_ORDER[tIndex];
	if (tIndex ~= nil) then
		for tCategSpec, tNumber in pairs(VUHDO_BUFF_ORDER) do
			if (tNumber < tPredec and tNumber > tCurrOrder) then
				tPredec = tNumber;
				tPreIndex = tCategSpec;
			end
		end
	end

	if (tPredec < 1000) then
		VUHDO_BUFF_ORDER[tPreIndex] = tCurrOrder;
		VUHDO_BUFF_ORDER[tIndex] = tPredec;
	end

	VUHDO_buildAllBuffSetupGenerericPanel();
	VUHDO_buffSetupStoreSettings();
end

