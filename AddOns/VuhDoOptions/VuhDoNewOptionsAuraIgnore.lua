local _;

local tinsert = table.insert;
local strtrim = strtrim;

VUHDO_AURA_IGNORE_SORTABLE = { };
VUHDO_AURA_IGNORE_COMBO_MODEL = { };
VUHDO_SELECTED_AURA_IGNORE = "";
VUHDO_AURA_IGNORE_SHARE_VERSION = 1;



--
local tSpellNameById;
local tDisplayName;
local tSecrecy;
function VUHDO_initAuraIgnoreComboModel()

	table.wipe(VUHDO_AURA_IGNORE_SORTABLE);

	for tName, _ in pairs(VUHDO_AURA_IGNORE_LIST) do
		tinsert(VUHDO_AURA_IGNORE_SORTABLE, tName);
	end

	table.sort(VUHDO_AURA_IGNORE_SORTABLE,
	    function(aSpell, anotherSpell)
		    return VUHDO_resolveSpellId(aSpell) < VUHDO_resolveSpellId(anotherSpell);
	    end
	);

	table.wipe(VUHDO_AURA_IGNORE_COMBO_MODEL);

	for _, tName in pairs(VUHDO_AURA_IGNORE_SORTABLE) do
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

		tinsert(VUHDO_AURA_IGNORE_COMBO_MODEL, { tName, tDisplayName });
	end

	return;

end



--
local tText;
local tKey;
local tDisplayName;
local tCombo;
function VUHDO_saveAuraIgnoreClicked(aButton)

	tText = _G[aButton:GetParent():GetName() .. "IgnoreComboBoxEditBox"]:GetText();

	if tText ~= nil then
		tText = strtrim(tText);

		if tText ~= "" then
			if VUHDO_checkSpellSecrecy(tText) == 1 then

				return;
			end

			tKey = tonumber(tText);

			if tKey then
				VUHDO_AURA_IGNORE_LIST[tKey] = true;
			else
				VUHDO_AURA_IGNORE_LIST[tText] = true;
			end

			tDisplayName = VUHDO_formatAuraSpellDisplayName(tText);
			VUHDO_Msg(string.format(VUHDO_I18N_AURA_ADDED_TO_IGNORE_LIST, tDisplayName));

			VUHDO_initAuraIgnoreComboModel();

			tCombo = _G[aButton:GetParent():GetName() .. "IgnoreComboBox"];

			if tCombo then
				VUHDO_lnfComboBoxInitFromModel(tCombo);
			end

			_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Hide();
			_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Show();
		end
	end

	return;

end



--
local tText;
local tSpellId;
local tTrimmed;
local tKeyToRemove;
local tDisplayName;
local tCombo;
function VUHDO_deleteAuraIgnoreClicked(aButton)

	tText = _G[aButton:GetParent():GetName() .. "IgnoreComboBoxEditBox"]:GetText();

	if tText ~= nil then
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

		tDisplayName = VUHDO_formatAuraSpellDisplayName(strtrim(tText));

		tTrimmed = strtrim(tText);
		tKeyToRemove = nil;

		if tonumber(tTrimmed) and VUHDO_AURA_IGNORE_LIST[tonumber(tTrimmed)] then
			tKeyToRemove = tonumber(tTrimmed);
		elseif VUHDO_AURA_IGNORE_LIST[tTrimmed] then
			tKeyToRemove = tTrimmed;
		end

		if tKeyToRemove then
			VUHDO_AURA_IGNORE_LIST[tKeyToRemove] = nil;

			VUHDO_Msg(string.format(VUHDO_I18N_AURA_REMOVED_FROM_IGNORE_LIST, tDisplayName));
		else
			VUHDO_Msg(string.format(VUHDO_I18N_AURA_DOES_NOT_EXIST_IN_IGNORE_LIST, tDisplayName));
		end

		VUHDO_initAuraIgnoreComboModel();

		tCombo = _G[aButton:GetParent():GetName() .. "IgnoreComboBox"];

		if tCombo then
			VUHDO_lnfComboBoxInitFromModel(tCombo);
		end

		_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Hide();
		_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Show();
	end

	return;

end



--
function VUHDO_exportAuraIgnoreClicked(aButton)

	_G[aButton:GetParent():GetParent():GetName() .. "ExportFrame"]:Show();

	return;

end



--
function VUHDO_importAuraIgnoreClicked(aButton)

	_G[aButton:GetParent():GetParent():GetName() .. "ImportFrame"]:Show();

	return;

end



--
local tAuraIgnoreCompressed;
local tAuraIgnoreTable;
local tAuraIgnoreString;
local function VUHDO_auraIgnoreTableToString(anAuraIgnore)

	if anAuraIgnore ~= nil then
		tAuraIgnoreCompressed = VUHDO_LibCompressEncode:Encode(VUHDO_compressAndPackTable(anAuraIgnore));

		tAuraIgnoreTable = {
			["auraIgnoreVersion"] = VUHDO_AURA_IGNORE_SHARE_VERSION,
			["playerName"] = GetUnitName("player", true),
			["auraIgnore"] = tAuraIgnoreCompressed,
		};

		tAuraIgnoreString = VUHDO_serializeTable(tAuraIgnoreTable);
		tAuraIgnoreString = VUHDO_LibBase64.Encode(tAuraIgnoreString);

		return tAuraIgnoreString;
	end

	return;

end



--
local tDecodedAuraIgnoreString;
local tAuraIgnoreTable;
local tDecompressedAuraIgnoreTable;
local function VUHDO_auraIgnoreStringToTable(anAuraIgnoreString)

	tDecodedAuraIgnoreString = VUHDO_LibBase64.Decode(anAuraIgnoreString);
	tAuraIgnoreTable = VUHDO_deserializeTable(tDecodedAuraIgnoreString);

	if tAuraIgnoreTable and tAuraIgnoreTable["auraIgnore"] then
		tDecompressedAuraIgnoreTable = VUHDO_decompressIfCompressed(VUHDO_LibCompressEncode:Decode(tAuraIgnoreTable["auraIgnore"]));

		tAuraIgnoreTable["auraIgnore"] = tDecompressedAuraIgnoreTable;
	end

	return tAuraIgnoreTable;

end



--
local tEditText;
function VUHDO_auraIgnoreExportButtonShown(aEditBox)

	tEditText = VUHDO_auraIgnoreTableToString(VUHDO_AURA_IGNORE_LIST);

	aEditBox:SetText(tEditText);
	aEditBox:SetTextInsets(0, 10, 5, 5);

	aEditBox:Show();

	return;

end



--
local tImportString;
local tImportTable;
local tKey;
function VUHDO_auraIgnoreImport(anEditBoxName)

	tImportString = _G[anEditBoxName]:GetText();

	tImportTable = VUHDO_auraIgnoreStringToTable(tImportString);

	if tImportTable == nil or tImportTable["auraIgnoreVersion"] == nil or tonumber(tImportTable["auraIgnoreVersion"]) == nil or
		tonumber(tImportTable["auraIgnoreVersion"]) ~= VUHDO_AURA_IGNORE_SHARE_VERSION or tImportTable["playerName"] == nil or
		tImportTable["auraIgnore"] == nil or type(tImportTable["auraIgnore"]) ~= "table" then
		VUHDO_Msg(VUHDO_I18N_IMPORT_STRING_INVALID);

		return;
	end

	for tAuraIgnoreSpell, _ in pairs(tImportTable["auraIgnore"]) do
		tKey = tonumber(tAuraIgnoreSpell);

		VUHDO_AURA_IGNORE_LIST[tKey or tAuraIgnoreSpell] = true;
	end

	VUHDO_Msg(VUHDO_I18N_AURA_IGNORE_IMPORTED);

	return;

end



--
local tEditBoxName;
local tCombo;
function VUHDO_yesNoImportAuraIgnoreCallback(aDecision)

	if VUHDO_YES == aDecision then
		tEditBoxName = VuhDoYesNoFrame:GetAttribute("importStringEditBoxName");

		VUHDO_auraIgnoreImport(tEditBoxName);

		_G[tEditBoxName]:GetParent():GetParent():GetParent():Hide();

		VUHDO_initAuraIgnoreComboModel();

		tCombo = _G["VuhDoNewOptionsAuraIgnoreIgnorePanelIgnoreComboBox"];

		if tCombo then
			VUHDO_lnfComboBoxInitFromModel(tCombo);
		end

		_G["VuhDoNewOptionsAuraIgnoreIgnorePanelIgnoreComboBox"]:Hide();
		_G["VuhDoNewOptionsAuraIgnoreIgnorePanelIgnoreComboBox"]:Show();
	end

	return;

end



--
function VUHDO_importAuraIgnoreOkayClicked(aButton)

	VuhDoYesNoFrameText:SetText(VUHDO_I18N_REALLY_IMPORT);

	VuhDoYesNoFrame:SetAttribute("callback", VUHDO_yesNoImportAuraIgnoreCallback);
	VuhDoYesNoFrame:SetAttribute("importStringEditBoxName", aButton:GetParent():GetName() .. "StringScrollFrameStringEditBox");

	VuhDoYesNoFrame:Show();

	return;

end



--
local tCombo;
function VUHDO_auraIgnoreOnShow()

	if VUHDO_CONFIG and not VUHDO_CONFIG["AURA_IGNORE_MODI"] then
		VUHDO_CONFIG["AURA_IGNORE_MODI"] = "ALT-CTRL-SHIFT";
	end

	VUHDO_initAuraIgnoreComboModel();

	tCombo = _G["VuhDoNewOptionsAuraIgnoreIgnorePanelIgnoreComboBox"];

	if tCombo then
		VUHDO_lnfComboBoxInitFromModel(tCombo);
	end

	return;

end