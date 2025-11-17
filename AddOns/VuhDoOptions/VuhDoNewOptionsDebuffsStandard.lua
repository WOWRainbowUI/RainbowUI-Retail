local _;

VUHDO_DEBUFF_BLACKLIST_SORTABLE = { };
VUHDO_DEBUFF_IGNORE_COMBO_MODEL = { };
VUHDO_SELECTED_DEBUFF_IGNORE = "";
VUHDO_DEBUFF_IGNORE_SHARE_VERSION = 1;



--
local tResolvedName;
function VUHDO_formatSpellDisplayName(aSpellName)

	tResolvedName = VUHDO_resolveSpellId(aSpellName);

	return (tResolvedName ~= aSpellName) and ("[" .. aSpellName .. "] " .. tResolvedName) or aSpellName;

end



--
local tConflictingCustomDebuffs;
local tResolvedSpellName;
local tResolvedStoredName;
function VUHDO_getConflictingCustomDebuffs(aSpellName)

	tConflictingCustomDebuffs = { };

	tResolvedSpellName = VUHDO_resolveSpellId(aSpellName);

	for _, tStoredName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		tResolvedStoredName = VUHDO_resolveSpellId(tStoredName);

		if tStoredName == aSpellName or tResolvedStoredName == tResolvedSpellName then
			tinsert(tConflictingCustomDebuffs, tStoredName);
		end
	end

	return tConflictingCustomDebuffs;

end



--
local tConflictingIgnoreListSpells;
local tResolvedCustomDebuffName;
local tResolvedIgnoreListName;
function VUHDO_getConflictingIgnoreListSpells(aCustomDebuffName)

	tConflictingIgnoreListSpells = { };

	tResolvedCustomDebuffName = VUHDO_resolveSpellId(aCustomDebuffName);

	for tIgnoreListName, _ in pairs(VUHDO_DEBUFF_BLACKLIST) do
		tResolvedIgnoreListName = VUHDO_resolveSpellId(tIgnoreListName);

		if tIgnoreListName == aCustomDebuffName or tResolvedIgnoreListName == tResolvedCustomDebuffName then
			tinsert(tConflictingIgnoreListSpells, tIgnoreListName);
		end
	end

	return tConflictingIgnoreListSpells;

end



--
local tConflicts;
function VUHDO_formatConflictList(aConflictList)

	tConflicts = { };

	for _, tConflict in pairs(aConflictList) do
		tinsert(tConflicts, VUHDO_formatSpellDisplayName(tConflict));
	end

	return table.concat(tConflicts, ", ");

end



--
local tConflicts;
local tDisplayName;
local function VUHDO_showIgnoreListCustomDebuffWarning(aSpellName, aConflicts)

	if #aConflicts > 0 then
		tDisplayName = VUHDO_formatSpellDisplayName(aSpellName);

		VUHDO_Msg("[WARNING] " .. string.format(VUHDO_I18N_IGNORE_LIST_CUSTOM_DEBUFF_WARNING, tDisplayName), 1, 0, 0);
	end

	return;

end



--
local function VUHDO_hideIgnoreListCustomDebuffWarning()

	return;

end



--
local tSpellNameById;
function VUHDO_initDebuffIgnoreComboModel()

	table.wipe(VUHDO_DEBUFF_BLACKLIST_SORTABLE);

	for tName, _ in pairs(VUHDO_DEBUFF_BLACKLIST) do
		tinsert(VUHDO_DEBUFF_BLACKLIST_SORTABLE, tName);
	end

	table.sort(VUHDO_DEBUFF_BLACKLIST_SORTABLE,
	    function(aDebuff, anotherDebuff)
		    return VUHDO_resolveSpellId(aDebuff) < VUHDO_resolveSpellId(anotherDebuff);
	    end
	);

	table.wipe(VUHDO_DEBUFF_IGNORE_COMBO_MODEL);

	for _, tName in pairs(VUHDO_DEBUFF_BLACKLIST_SORTABLE) do 
		tSpellNameById = VUHDO_resolveSpellId(tName);

		tConflicts = VUHDO_getConflictingCustomDebuffs(tName);

		if (tSpellNameById ~= tName) then
			tDisplayName = "[" .. tName .. "] " .. tSpellNameById;
		else
			tDisplayName = tName;
		end

		if #tConflicts > 0 then
			tDisplayName = "[X] " .. tDisplayName .. " [X]";
		end

		tinsert(VUHDO_DEBUFF_IGNORE_COMBO_MODEL, { tName, tDisplayName });
	end

	return;

end



--
local tText;
local tConflicts;
function VUHDO_saveDebuffIgnoreClicked(aButton)

	tText = _G[aButton:GetParent():GetName() .. "IgnoreComboBoxEditBox"]:GetText();

	if (tText ~= nil) then
		tText = strtrim(tText);
		tConflicts = VUHDO_getConflictingCustomDebuffs(tText);

		VUHDO_DEBUFF_BLACKLIST[tText] = true;

		VUHDO_removeIgnoredDebuffFromAllUnits(tText);

		tDisplayName = VUHDO_formatSpellDisplayName(tText);
		VUHDO_Msg(string.format(VUHDO_I18N_DEBUFF_ADDED_TO_IGNORE_LIST, tDisplayName));

		VUHDO_showIgnoreListCustomDebuffWarning(tText, tConflicts);

		VUHDO_initDebuffIgnoreComboModel();

		_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Hide();
		_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Show();
	end

	return;

end



--
local tText;
local tSpellId;
local tConflicts;
local tDisplayName;
function VUHDO_deleteDebuffIgnoreClicked(aButton)

	tText = _G[aButton:GetParent():GetName() .. "IgnoreComboBoxEditBox"]:GetText();

	if (tText ~= nil) then
		if string.sub(tText, 1, 4) == "[X] " then
			tText = string.sub(tText, 5);
		end

		if string.sub(tText, -4) == " [X]" then
			tText = string.sub(tText, 1, -5);
		end

		tSpellId = string.match(tText, '^%[([^%]]+)%] (.+)$');

		if tSpellId then
			tText = tSpellId;
		end

		tConflicts = VUHDO_getConflictingCustomDebuffs(tText);

		tDisplayName = VUHDO_formatSpellDisplayName(tText);

		if (VUHDO_DEBUFF_BLACKLIST[strtrim(tText)]) then
			VUHDO_DEBUFF_BLACKLIST[strtrim(tText)] = nil;

			VUHDO_Msg(string.format(VUHDO_I18N_DEBUFF_REMOVED_FROM_IGNORE_LIST, tDisplayName));

			if #tConflicts > 0 then
				VUHDO_Msg("[WARNING] " .. string.format(VUHDO_I18N_IGNORE_LIST_CUSTOM_DEBUFF_REMOVED_WARNING, tDisplayName), 1, 0, 0);
			end
		else
			tSpellId = string.match(tText, '([^%]%[]+)');

			if (tSpellId ~= nil and VUHDO_DEBUFF_BLACKLIST[tSpellId]) then
				VUHDO_DEBUFF_BLACKLIST[tSpellId] = nil;

				VUHDO_Msg(string.format(VUHDO_I18N_DEBUFF_REMOVED_FROM_IGNORE_LIST, tDisplayName));

				if #tConflicts > 0 then
					VUHDO_Msg("[WARNING] " .. string.format(VUHDO_I18N_IGNORE_LIST_CUSTOM_DEBUFF_REMOVED_WARNING, tDisplayName), 1, 0, 0);
				end
			else
				VUHDO_Msg(string.format(VUHDO_I18N_DEBUFF_DOES_NOT_EXIST, tDisplayName));
			end
		end

		VUHDO_initDebuffIgnoreComboModel();

		_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Hide();
		_G[aButton:GetParent():GetName() .. "IgnoreComboBox"]:Show();
	end

	return;

end



--
local tDebuffName;
local tDebuffSpellId;
local tConflicts;
local tDisplayName;
function VUHDO_addDebuffToBlacklist(aCuDeIconFrame)

	if not aCuDeIconFrame then
		return;
	end

	tDebuffName = aCuDeIconFrame["debuffInfo"];

	if tDebuffName then
		tDebuffSpellId = strtrim(aCuDeIconFrame["debuffSpellId"]);

		if not VUHDO_DEBUFF_BLACKLIST[tDebuffSpellId] then
			VUHDO_DEBUFF_BLACKLIST[tDebuffSpellId] = true;

			VUHDO_removeIgnoredDebuffFromAllUnits(tDebuffSpellId);
			VUHDO_initDebuffIgnoreComboModel();

			tDisplayName = VUHDO_formatSpellDisplayName(tDebuffSpellId);
			VUHDO_Msg(string.format(VUHDO_I18N_DEBUFF_ADDED_TO_IGNORE_LIST, tDisplayName));

			tConflicts = VUHDO_getConflictingCustomDebuffs(tDebuffSpellId);

			if #tConflicts > 0 then
				VUHDO_Msg("[WARNING] " .. string.format(VUHDO_I18N_IGNORE_LIST_CUSTOM_DEBUFF_WARNING, tDisplayName), 1, 0, 0);
			end
		end
	end

	return;

end



--
function VUHDO_exportDebuffIgnoreClicked(aButton)

	_G[aButton:GetParent():GetParent():GetName() .. "ExportFrame"]:Show();

end



--
function VUHDO_importDebuffIgnoreClicked(aButton)

	_G[aButton:GetParent():GetParent():GetName() .. "ImportFrame"]:Show();

end



--
local tDebuffIgnoreCompressed;
local tDebuffIgnoreTable;
local tDebuffIgnoreString;
local function VUHDO_debuffIgnoreTableToString(aDebuffIgnore)

	if (aDebuffIgnore ~= nil) then
		tDebuffIgnoreCompressed = VUHDO_compressAndPackTable(aDebuffIgnore);

		tDebuffIgnoreTable = {
			["debuffIgnoreVersion"] = VUHDO_DEBUFF_IGNORE_SHARE_VERSION,
			["playerName"] = GetUnitName("player", true),
			["debuffIgnore"] = tDebuffIgnoreCompressed,
		};

		tDebuffIgnoreString = VUHDO_serializeTable(tDebuffIgnoreTable);
		tDebuffIgnoreString = VUHDO_LibBase64.Encode(tDebuffIgnoreString);

		return tDebuffIgnoreString;
	end

	return;

end



--
local tDecodedDebuffIgnoreString;
local tDebuffIgnoreTable;
local tDecompressedDebuffIgnoreTable;
local function VUHDO_debuffIgnoreStringToTable(aDebuffIgnoreString)

	tDecodedDebuffIgnoreString = VUHDO_LibBase64.Decode(aDebuffIgnoreString);
	tDebuffIgnoreTable = VUHDO_deserializeTable(tDecodedDebuffIgnoreString);

	if tDebuffIgnoreTable and tDebuffIgnoreTable["debuffIgnore"] then
		tDecompressedDebuffIgnoreTable = VUHDO_decompressIfCompressed(tDebuffIgnoreTable["debuffIgnore"]);

		tDebuffIgnoreTable["debuffIgnore"] = tDecompressedDebuffIgnoreTable;
	end

	return tDebuffIgnoreTable;

end



--
local tEditText;
function VUHDO_debuffIgnoreExportButtonShown(aEditBox)

	tEditText = VUHDO_debuffIgnoreTableToString(VUHDO_DEBUFF_BLACKLIST);

	aEditBox:SetText(tEditText);
	aEditBox:SetTextInsets(0, 10, 5, 5);

	aEditBox:Show();

	return;

end



--
local tImportString;
local tImportTable;
function VUHDO_debuffIgnoreImport(aEditBoxName)

	tImportString = _G[aEditBoxName]:GetText();
	tImportTable = VUHDO_debuffIgnoreStringToTable(tImportString);

	if (tImportTable == nil or tImportTable["debuffIgnoreVersion"] == nil or tonumber(tImportTable["debuffIgnoreVersion"]) == nil or 
		tonumber(tImportTable["debuffIgnoreVersion"]) ~= VUHDO_DEBUFF_IGNORE_SHARE_VERSION or tImportTable["playerName"] == nil or 
		tImportTable["debuffIgnore"] == nil or type(tImportTable["debuffIgnore"]) ~= "table") then
		VUHDO_Msg(VUHDO_I18N_IMPORT_STRING_INVALID);

		return;
	end

	for tDebuffIgnoreSpell, _ in pairs(tImportTable["debuffIgnore"]) do
		VUHDO_DEBUFF_BLACKLIST[tDebuffIgnoreSpell] = true;
	end

	VUHDO_Msg(VUHDO_I18N_DEBUFF_IGNORE_IMPORTED);

	return;

end



--
function VUHDO_yesNoImportDebuffIgnoreCallback(aDecision)

	if (VUHDO_YES == aDecision) then
		local tEditBoxName = VuhDoYesNoFrame:GetAttribute("importStringEditBoxName");

		VUHDO_debuffIgnoreImport(tEditBoxName);

		_G[tEditBoxName]:GetParent():GetParent():GetParent():Hide();

		VUHDO_initDebuffIgnoreComboModel();
		_G["VuhDoNewOptionsDebuffsStandardIconsPanelIgnoreComboBox"]:Hide();
		_G["VuhDoNewOptionsDebuffsStandardIconsPanelIgnoreComboBox"]:Show();
	end

	return;

end



--
function VUHDO_importDebuffIgnoreOkayClicked(aButton)

	VuhDoYesNoFrameText:SetText(VUHDO_I18N_REALLY_IMPORT);

	VuhDoYesNoFrame:SetAttribute("callback", VUHDO_yesNoImportDebuffIgnoreCallback);
	VuhDoYesNoFrame:SetAttribute("importStringEditBoxName", aButton:GetParent():GetName() .. "StringScrollFrameStringEditBox");

	VuhDoYesNoFrame:Show();

	return;

end



--
local tOldValue = nil;
local tSuccess;
function VUHDO_notifySoundSelect(aComboBox, aValue)

	if (aValue ~= nil and tOldValue ~= aValue) then
		tSuccess = VUHDO_playSoundFile(aValue);

		if tSuccess then
			tOldValue = aValue;
		end
	end

	return;

end