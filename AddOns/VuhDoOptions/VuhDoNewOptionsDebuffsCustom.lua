local _;
local VUHDO_COMBO_MODEL = nil;
local VUHDO_DEBUFFS_SORTABLE = { };


--
local tSpellNameById;
function VUHDO_initCustomDebuffComboModel()
  -- Nicht die saved variables direkt sortieren, wird sonst inkonsistent
	VUHDO_DEBUFFS_SORTABLE = { };
	for _, tStoredName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		tinsert(VUHDO_DEBUFFS_SORTABLE, tStoredName);
	end
	table.sort(VUHDO_DEBUFFS_SORTABLE,
		function(aDebuff, anotherDebuff)
			return VUHDO_resolveSpellId(aDebuff) < VUHDO_resolveSpellId(anotherDebuff);
		end
	);

	VUHDO_COMBO_MODEL = { };
	for tIndex, tStoredName in ipairs(VUHDO_DEBUFFS_SORTABLE) do
		tSpellNameById = VUHDO_resolveSpellId(tStoredName);
		if (tSpellNameById ~= tStoredName) then
			VUHDO_COMBO_MODEL[tIndex] = { tStoredName, "[" .. tStoredName .. "] " .. tSpellNameById };
		else
			VUHDO_COMBO_MODEL[tIndex] = { tStoredName, tStoredName };
		end
	end
end



--
function VUHDO_setupCustomDebuffsComboModel(aComboBox)
	VUHDO_initCustomDebuffComboModel();
	VUHDO_notifyCustomDebuffSelect(aComboBox, VUHDO_CONFIG.CUSTOM_DEBUFF.SELECTED);

	VUHDO_setComboModel(aComboBox, "VUHDO_CONFIG.CUSTOM_DEBUFF.SELECTED", VUHDO_COMBO_MODEL);
	VUHDO_lnfComboBoxInitFromModel(aComboBox);
end



--
function VUHDO_notifyCustomDebuffSelect(aComboBox, aValue)
	if (VuhDoNewOptionsDebuffsCustomStorePanelEditBox ~= nil and aValue ~= nil) then
		VuhDoNewOptionsDebuffsCustomStorePanelEditBox:SetText(aValue);
	else
		VuhDoNewOptionsDebuffsCustomStorePanelEditBox:SetText("");
	end
end

-- nicht local machen, da sonst im LNF nicht auffindbar
VUHDO_ICON_MODEL = nil;
VUHDO_COLOR_MODEL = nil;
VUHDO_ANIMATE_MODEL = nil;
VUHDO_TIMER_MODEL = nil;
VUHDO_STACKS_MODEL = nil;
VUHDO_ALIVE_TIME_MODEL = nil;
VUHDO_FULL_DURATION_MODEL = nil;
VUHDO_MINE_MODEL = nil;
VUHDO_OTHERS_MODEL = nil;
VUHDO_COLOR_SWATCH_MODEL = nil;
VUHDO_BAR_GLOW_MODEL = nil;
VUHDO_BAR_GLOW_SWATCH_MODEL = nil;
VUHDO_ICON_GLOW_MODEL = nil;
VUHDO_ICON_GLOW_SWATCH_MODEL = nil;
VUHDO_SOUND_MODEL = nil;



--
local tValue;
local tIndex;
local tPanelName;
local tCheckButton;
local tComboBox;
local tColorSwatch;
function VUHDO_customDebuffUpdateEditBox(anEditBox)
	tValue = anEditBox:GetText();
	tIndex = VUHDO_tableGetKeyFromValue(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tValue);

	if (tIndex ~= nil) then
		anEditBox:SetTextColor(1, 1, 1, 1);

		tPanelName = anEditBox:GetParent():GetName();

		tCheckButton = _G[tPanelName .. "IconCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isIcon");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "ColorCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isColor");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "AnimateCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".animate");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "TimerCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".timer");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "StacksCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isStacks");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		-- reset any sound settings referencing the old 'none' LSM default
		if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].SOUND and 
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].SOUND == "Interface\\Quiet.ogg") then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].SOUND = nil;
		end

		tComboBox = _G[tPanelName .. "SoundCombo"];
		VUHDO_setComboModel(tComboBox, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".SOUND", VUHDO_SOUNDS);
		VUHDO_lnfComboBoxInitFromModel(tComboBox);

		if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isColor) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color = nil;
		end

		if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color == nil) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color
				= VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF" .. VUHDO_DEBUFF_TYPE_CUSTOM]);

			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color.useBackground = true;
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color.useText = true;
		end

		tColorSwatch = _G[tPanelName .. "ColorTexture"];
		VUHDO_lnfSetModel(tColorSwatch, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".color");
		VUHDO_lnfInitColorSwatch(tColorSwatch, VUHDO_I18N_COLOR, VUHDO_I18N_COLOR);
		VUHDO_lnfColorSwatchInitFromModel(tColorSwatch);

		tCheckButton = _G[tPanelName .. "AliveTimeCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isAliveTime");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "FullDurationCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isFullDuration");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);
		
		if VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue]["isMine"] == nil then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue]["isMine"] = true;
		end

		tCheckButton = _G[tPanelName .. "MineCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isMine");	
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		if VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue]["isOthers"] == nil then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue]["isOthers"] = true;
		end

		tCheckButton = _G[tPanelName .. "OthersCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isOthers");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "BarGlowCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isBarGlow");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isBarGlow) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].barGlowColor = nil;
		end

		if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].barGlowColor == nil) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].barGlowColor
				= VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]);
		end

		tColorSwatch = _G[tPanelName .. "BarGlowTexture"];
		VUHDO_lnfSetModel(tColorSwatch, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".barGlowColor");
		VUHDO_lnfInitColorSwatch(tColorSwatch, VUHDO_I18N_COLOR, VUHDO_I18N_COLOR);
		VUHDO_lnfColorSwatchInitFromModel(tColorSwatch);
		
		tCheckButton = _G[tPanelName .. "IconGlowCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".isIconGlow");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isIconGlow) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].iconGlowColor = nil;
		end

		if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].iconGlowColor == nil) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].iconGlowColor
				= VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]);
		end

		tColorSwatch = _G[tPanelName .. "IconGlowTexture"];
		VUHDO_lnfSetModel(tColorSwatch, "VUHDO_CONFIG.CUSTOM_DEBUFF.STORED_SETTINGS." .. tValue .. ".iconGlowColor");
		VUHDO_lnfInitColorSwatch(tColorSwatch, VUHDO_I18N_COLOR, VUHDO_I18N_COLOR);
		VUHDO_lnfColorSwatchInitFromModel(tColorSwatch);

	else
		anEditBox:SetTextColor(0.8, 0.8, 1, 1);

		tPanelName = anEditBox:GetParent():GetName();

		VUHDO_ICON_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.isIcon;
		VUHDO_COLOR_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.isColor;
		VUHDO_ANIMATE_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.animate;
		VUHDO_TIMER_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.timer;
		VUHDO_STACKS_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.isStacks;
		VUHDO_ALIVE_TIME_MODEL = false;
		VUHDO_FULL_DURATION_MODEL = false;
		VUHDO_MINE_MODEL = true;
		VUHDO_OTHERS_MODEL = true;
		VUHDO_BAR_GLOW_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.isBarGlow;
		VUHDO_ICON_GLOW_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.isIconGlow;

		VUHDO_COLOR_SWATCH_MODEL = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF" .. VUHDO_DEBUFF_TYPE_CUSTOM]);
		VUHDO_COLOR_SWATCH_MODEL.useBackground = true;
		VUHDO_COLOR_SWATCH_MODEL.useText = true;

		VUHDO_BAR_GLOW_SWATCH_MODEL = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]);
		VUHDO_ICON_GLOW_SWATCH_MODEL = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]);
		VUHDO_SOUND_MODEL = VUHDO_CONFIG.CUSTOM_DEBUFF.SOUND;

		tCheckButton = _G[tPanelName .. "IconCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_ICON_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "ColorCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_COLOR_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "AnimateCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_ANIMATE_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "TimerCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_TIMER_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "StacksCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_STACKS_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tComboBox = _G[tPanelName .. "SoundCombo"];
		VUHDO_setComboModel(tComboBox, "VUHDO_SOUND_MODEL", VUHDO_SOUNDS);
		VUHDO_lnfComboBoxInitFromModel(tComboBox);

		tColorSwatch = _G[tPanelName .. "ColorTexture"];
		VUHDO_lnfSetModel(tColorSwatch, "VUHDO_COLOR_SWATCH_MODEL");
		VUHDO_lnfInitColorSwatch(tColorSwatch, VUHDO_I18N_COLOR, VUHDO_I18N_COLOR);
		VUHDO_lnfColorSwatchInitFromModel(tColorSwatch);

		tCheckButton = _G[tPanelName .. "AliveTimeCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_ALIVE_TIME_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "FullDurationCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_FULL_DURATION_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "MineCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_MINE_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "OthersCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_OTHERS_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tCheckButton = _G[tPanelName .. "BarGlowCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_BAR_GLOW_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tColorSwatch = _G[tPanelName .. "BarGlowTexture"];
		VUHDO_lnfSetModel(tColorSwatch, "VUHDO_BAR_GLOW_SWATCH_MODEL");
		VUHDO_lnfInitColorSwatch(tColorSwatch, VUHDO_I18N_COLOR, VUHDO_I18N_COLOR);
		VUHDO_lnfColorSwatchInitFromModel(tColorSwatch);

		tCheckButton = _G[tPanelName .. "IconGlowCheckButton"];
		VUHDO_lnfSetModel(tCheckButton, "VUHDO_ICON_GLOW_MODEL");
		VUHDO_lnfCheckButtonInitFromModel(tCheckButton);

		tColorSwatch = _G[tPanelName .. "IconGlowTexture"];
		VUHDO_lnfSetModel(tColorSwatch, "VUHDO_ICON_GLOW_SWATCH_MODEL");
		VUHDO_lnfInitColorSwatch(tColorSwatch, VUHDO_I18N_COLOR, VUHDO_I18N_COLOR);
		VUHDO_lnfColorSwatchInitFromModel(tColorSwatch);

	end
end



--
local tOldValue = nil;
function VUHDO_notifySoundSelect(aComboBox, aValue)
	if (aValue ~= nil and tOldValue ~= aValue) then
		local tSuccess = VUHDO_playSoundFile(aValue);
		
		if tSuccess then
			tOldValue = aValue;
		end
	end
end



--
local tEditBox;
local tValue;
local tIndex;
local tCheckButton;
local tPanelName;
local tComboBox;
local tSoundName;
function VUHDO_saveCustomDebuffOnClick(aButton)
	tEditBox = _G[aButton:GetParent():GetName() .. "EditBox"];
	tValue = strtrim(tEditBox:GetText());
	tIndex = VUHDO_tableGetKeyFromValue(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tValue);

	if (tIndex == nil and #tValue > 0) then
		tinsert(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tValue);
		VuhDoNewOptionsDebuffsCustomStorePanelEditBox:SetText(tValue);
		VuhDoNewOptionsDebuffsCustomStorePanelEditBox:SetTextColor(1, 1, 1);
	end

	tPanelName = aButton:GetParent():GetName();

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue] = { };
	end

	tCheckButton = _G[tPanelName .. "IconCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isIcon = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "ColorCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isColor = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "AnimateCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].animate = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "TimerCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].timer = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "StacksCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isStacks = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "AliveTimeCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isAliveTime = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "FullDurationCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isFullDuration = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "MineCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isMine = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "OthersCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isOthers = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "BarGlowCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isBarGlow = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tCheckButton = _G[tPanelName .. "IconGlowCheckButton"];
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isIconGlow = VUHDO_forceBooleanValue(tCheckButton:GetChecked());

	tComboBox = _G[tPanelName .. "SoundCombo"];
	tSoundName = _G[tComboBox:GetName() .. "Text"]:GetText();
	VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].SOUND = VUHDO_LibSharedMedia:Fetch("sound", tSoundName);
	VUHDO_lnfComboBoxInitFromModel(tComboBox);

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isColor) then
		if (VUHDO_COLOR_SWATCH_MODEL ~= nil) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color
				= VUHDO_deepCopyTable(VUHDO_COLOR_SWATCH_MODEL);

			VUHDO_COLOR_SWATCH_MODEL = nil;
		end
	else
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].color = nil;
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isBarGlow) then
		if (VUHDO_BAR_GLOW_SWATCH_MODEL ~= nil) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].barGlowColor
				= VUHDO_deepCopyTable(VUHDO_BAR_GLOW_SWATCH_MODEL);

			VUHDO_BAR_GLOW_SWATCH_MODEL = nil;
		end
	else
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].barGlowColor = nil;
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].isIconGlow) then
		if (VUHDO_ICON_GLOW_SWATCH_MODEL ~= nil) then
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].iconGlowColor
				= VUHDO_deepCopyTable(VUHDO_ICON_GLOW_SWATCH_MODEL);

			VUHDO_ICON_GLOW_SWATCH_MODEL = nil;
		end
	else
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue].iconGlowColor = nil;
	end

	VUHDO_CONFIG["CUSTOM_DEBUFF"]["SELECTED"] = tValue;
	VUHDO_initCustomDebuffComboModel();

	VUHDO_customDebuffUpdateEditBox(VuhDoNewOptionsDebuffsCustomStorePanelEditBox);

	VuhDoNewOptionsDebuffsCustom:Hide();
	VuhDoNewOptionsDebuffsCustom:Show();
end



--
function VUHDO_deleteCustomDebuffOnClick(aButton)
	local tEditBox = _G[aButton:GetParent():GetName() .. "EditBox"];
	local tValue = strtrim(tEditBox:GetText());
	local tIndex = VUHDO_tableGetKeyFromValue(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tValue);

	if (tIndex ~= nil and #tValue > 0) then
		tremove(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tIndex);
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tValue] = nil;
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["SELECTED"] = "";

		VUHDO_Msg("減益效果 " .. tValue .. " 已移除。", 1, 0.4, 0.4);
	else
		VUHDO_Msg("減益效果 " .. tValue .. " 不存在。", 1, 0.4, 0.4);
	end

	VUHDO_initCustomDebuffComboModel();

	VuhDoNewOptionsDebuffsCustomStorePanelEditBox:SetText("");
	VUHDO_customDebuffUpdateEditBox(VuhDoNewOptionsDebuffsCustomStorePanelEditBox);

	VuhDoNewOptionsDebuffsCustom:Hide();
	VuhDoNewOptionsDebuffsCustom:Show();
end



--
function VUHDO_applyToAllCustomDebuffOnClick()
	for _, tSettings in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"]) do
		tSettings["isIcon"] = VUHDO_CONFIG.CUSTOM_DEBUFF.isIcon;
		tSettings["isColor"] = VUHDO_CONFIG.CUSTOM_DEBUFF.isColor;
		tSettings["SOUND"] = VUHDO_CONFIG.CUSTOM_DEBUFF.SOUND;
		tSettings["animate"] = VUHDO_CONFIG.CUSTOM_DEBUFF.animate;
		tSettings["timer"] = VUHDO_CONFIG.CUSTOM_DEBUFF.timer;
		tSettings["isStacks"] = VUHDO_CONFIG.CUSTOM_DEBUFF.isStacks;
		if (tSettings["isColor"]) then
			tSettings["color"] = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF" .. VUHDO_DEBUFF_TYPE_CUSTOM]);
		else
			tSettings["color"] = nil;
		end
	end

	VuhDoNewOptionsDebuffsCustomStorePanel:Hide();
	VuhDoNewOptionsDebuffsCustomStorePanel:Show();
end

