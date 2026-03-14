local _;

local format = string.format;
local pairs = pairs;
local tinsert = table.insert;
local tconcat = table.concat;
local gsub = string.gsub;
local tostring = tostring;

local VUHDO_SPELL_ASSIGNMENTS;
local VUHDO_MODIFIER_KEYS;
local VUHDO_NUM_MOUSE_BUTTONS;

local VUHDO_analyzeMacroPlaceholders;
local VUHDO_getSecureActionForBinding;
local VUHDO_getMacroTemplateForAction;

local sSetupClicksCache = nil;
local sRemoveClicksCache = nil;
local sRequiresPet = false;
local sRequiresName = false;
local sRequiresTarget = false;



--
function VUHDO_bindingGeneratorInitLocalOverrides()

	VUHDO_SPELL_ASSIGNMENTS = _G["VUHDO_SPELL_ASSIGNMENTS"];
	VUHDO_MODIFIER_KEYS = _G["VUHDO_MODIFIER_KEYS"];
	VUHDO_NUM_MOUSE_BUTTONS = _G["VUHDO_NUM_MOUSE_BUTTONS"];

	VUHDO_analyzeMacroPlaceholders = _G["VUHDO_analyzeMacroPlaceholders"];
	VUHDO_getSecureActionForBinding = _G["VUHDO_getSecureActionForBinding"];
	VUHDO_getMacroTemplateForAction = _G["VUHDO_getMacroTemplateForAction"];

	VUHDO_analyzeBindingRequirements();

	return;

end



--
local tUsesName;
local tUsesPet;
local tUsesTarget;
local tTemplate;
function VUHDO_analyzeBindingRequirements()

	sRequiresPet = false;
	sRequiresName = false;
	sRequiresTarget = false;

	if not VUHDO_SPELL_ASSIGNMENTS then
		return sRequiresPet, sRequiresName, sRequiresTarget;
	end

	for tKey, tBinding in pairs(VUHDO_SPELL_ASSIGNMENTS) do
		if tBinding and tBinding[3] then
			tTemplate = VUHDO_getMacroTemplateForAction(tBinding[3]);

			_, tUsesName, tUsesPet, tUsesTarget = VUHDO_analyzeMacroPlaceholders(tTemplate);

			sRequiresPet = sRequiresPet or tUsesPet;
			sRequiresName = sRequiresName or tUsesName;
			sRequiresTarget = sRequiresTarget or tUsesTarget;
		end
	end

	return sRequiresPet, sRequiresName, sRequiresTarget;

end



--
local tEscaped;
local function VUHDO_escapeForLuaString(aStr)

	tEscaped = gsub(aStr, "\\", "\\\\");
	tEscaped = gsub(tEscaped, '"', '\\"');
	tEscaped = gsub(tEscaped, "\n", "\\n");

	return tEscaped;

end



--
local tLines;
local tKey;
local tBinding;
local tAction;
local tAttrPrefix;
local tAttrSuffix;
local tType;
local tTemplate;
local tFormat;
local tCount;
local tArgs;
local tFormatEscaped;
function VUHDO_generateSetupClicksCode()

	if sSetupClicksCache then
		return sSetupClicksCache;
	end

	tLines = {
		"local button = self",
		"local unit = button:GetAttribute('unit')",
		"if not unit then return end",
	};

	if sRequiresPet then
		tinsert(tLines, "local pet = button:GetAttribute('vuhdo-pet') or ''");
	end
	if sRequiresName then
		tinsert(tLines, "local name = button:GetAttribute('vuhdo-name') or ''");
	end
	if sRequiresTarget then
		tinsert(tLines, "local target = button:GetAttribute('vuhdo-target') or ''");
	end

	for tNoMinus, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
		for tCnt = 1, VUHDO_NUM_MOUSE_BUTTONS do
			tKey = tNoMinus .. tCnt;
			tBinding = VUHDO_SPELL_ASSIGNMENTS[tKey];

			if tBinding and tBinding[3] and tBinding[3] ~= "" then
				tAction = tBinding[3];

				tAttrPrefix = tWithMinus;
				tAttrSuffix = tostring(tCnt);

				tType, tTemplate = VUHDO_getSecureActionForBinding(tAction, sRequiresPet);

				if tType == "spell" then
					tinsert(tLines, format(
						'button:SetAttribute("%stype%s", "spell")',
						tAttrPrefix, tAttrSuffix
					));

					tinsert(tLines, format(
						'button:SetAttribute("%sspell%s", %q)',
						tAttrPrefix, tAttrSuffix, tTemplate
					));
				elseif tType == "macro" and tTemplate and tTemplate ~= "" then
					tinsert(tLines, format(
						'button:SetAttribute("%stype%s", "macro")',
						tAttrPrefix, tAttrSuffix
					));

					tFormat = tTemplate;

					tArgs = { };

					tFormat, tCount = gsub(tFormat, "SECURE_UNIT", "%%s");

					for tIdx = 1, tCount do
						tinsert(tArgs, "unit");
					end

					tFormat, tCount = gsub(tFormat, "SECURE_PET", "%%s");

					for tIdx = 1, tCount do
						tinsert(tArgs, "pet");
					end

					tFormat, tCount = gsub(tFormat, "SECURE_NAME", "%%s");

					for tIdx = 1, tCount do
						tinsert(tArgs, "name");
					end

					tFormat, tCount = gsub(tFormat, "SECURE_TARGET", "%%s");

					for tIdx = 1, tCount do
						tinsert(tArgs, "target");
					end

					tFormatEscaped = VUHDO_escapeForLuaString(tFormat);

					if #tArgs > 0 then
						tinsert(tLines, format(
							'local macro = string.format("%s", %s)',
							tFormatEscaped, tconcat(tArgs, ", ")
						));
					else
						tinsert(tLines, format(
							'local macro = "%s"',
							tFormatEscaped
						));
					end

					tinsert(tLines, format(
						'button:SetAttribute("%smacrotext%s", macro)',
						tAttrPrefix, tAttrSuffix
					));
				elseif tType == "item" then
					tinsert(tLines, format(
						'button:SetAttribute("%stype%s", "item")',
						tAttrPrefix, tAttrSuffix
					));

					tinsert(tLines, format(
						'button:SetAttribute("%sitem%s", %q)',
						tAttrPrefix, tAttrSuffix, tTemplate
					));
				elseif tType == "togglemenu" then
					tinsert(tLines, format(
						'button:SetAttribute("%stype%s", "togglemenu")',
						tAttrPrefix, tAttrSuffix
					));
				end
			end
		end
	end

	sSetupClicksCache = tconcat(tLines, "\n");

	return sSetupClicksCache;

end



--
local tLines;
local tKey;
local tBinding;
local tAttrPrefix;
local tAttrSuffix;
function VUHDO_generateRemoveClicksCode()

	if sRemoveClicksCache then
		return sRemoveClicksCache;
	end

	tLines = { };

	for tNoMinus, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
		for tCnt = 1, VUHDO_NUM_MOUSE_BUTTONS do
			tKey = tNoMinus .. tCnt;
			tBinding = VUHDO_SPELL_ASSIGNMENTS[tKey];

			if tBinding and tBinding[3] and tBinding[3] ~= "" then
				tAttrPrefix = tWithMinus;
				tAttrSuffix = tostring(tCnt);

				tinsert(tLines, format('button:SetAttribute("%stype%s", nil)', tAttrPrefix, tAttrSuffix));
				tinsert(tLines, format('button:SetAttribute("%smacrotext%s", nil)', tAttrPrefix, tAttrSuffix));
				tinsert(tLines, format('button:SetAttribute("%sspell%s", nil)', tAttrPrefix, tAttrSuffix));
				tinsert(tLines, format('button:SetAttribute("%sitem%s", nil)', tAttrPrefix, tAttrSuffix));
			end
		end
	end

	sRemoveClicksCache = tconcat(tLines, "\n");

	return sRemoveClicksCache;

end



--
function VUHDO_invalidateBindingCodeCache()

	sSetupClicksCache = nil;
	sRemoveClicksCache = nil;

	VUHDO_analyzeBindingRequirements();

	return;

end



--
function VUHDO_getBindingAttributeRequirements()

	return sRequiresPet, sRequiresName, sRequiresTarget;

end