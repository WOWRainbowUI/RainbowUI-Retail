local _;

local VUHDO_RAID;
local VUHDO_BUFF_REMOVAL_SPELLS;
local VUHDO_SPELL_ASSIGNMENTS;
local VUHDO_MODIFIER_KEYS;
local VUHDO_CONFIG;

local VUHDO_buildMacroText;
local VUHDO_buildTargetButtonMacroText;
local VUHDO_buildTargetMacroText;
local VUHDO_buildFocusMacroText;
local VUHDO_buildAssistMacroText;
local VUHDO_buildExtraActionButtonMacroText;
local VUHDO_buildMouseLookMacroText;
local VUHDO_buildPingMacroText;
local VUHDO_replaceMacroTemplates;
local VUHDO_isActionValid;
local VUHDO_isSpellKnown;
local VUHDO_findButtonFromChild;
local VUHDO_buildSecureMacroTemplate;
local VUHDO_buildTargetSecureMacroTemplate;
local VUHDO_buildFocusSecureMacroTemplate;
local VUHDO_buildAssistSecureMacroTemplate;
local VUHDO_buildPingSecureMacroTemplate;
local VUHDO_buildExtraActionButtonSecureMacroTemplate;
local VUHDO_buildRezSecureMacroTemplate;
local VUHDO_buildPurgeSecureMacroTemplate;
local VUHDO_buildCustomMacroSecureTemplate;
local VUHDO_generateSetupClicksCode;
local VUHDO_generateRemoveClicksCode;
local VUHDO_getBindingAttributeRequirements;
local VUHDO_isBossUnit;

local GetMacroIndexByName = GetMacroIndexByName;
local GetMacroInfo = GetMacroInfo;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local GetCursorInfo = GetCursorInfo;
local GetShapeshiftForm = GetShapeshiftForm;
local InCombatLockdown = InCombatLockdown;
local IsUsableItem = IsUsableItem or C_Item.IsUsableItem;
local pairs = pairs;
local strlower = strlower;
local format = format;
local issecretvalue = issecretvalue;

local sIsCliqueCompat;

function VUHDO_keySetupInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_BUFF_REMOVAL_SPELLS = _G["VUHDO_BUFF_REMOVAL_SPELLS"];
	VUHDO_SPELL_ASSIGNMENTS = _G["VUHDO_SPELL_ASSIGNMENTS"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_MODIFIER_KEYS = _G["VUHDO_MODIFIER_KEYS"];

	VUHDO_buildMacroText = _G["VUHDO_buildMacroText"];
	VUHDO_buildTargetButtonMacroText = _G["VUHDO_buildTargetButtonMacroText"];
	VUHDO_buildTargetMacroText = _G["VUHDO_buildTargetMacroText"];
	VUHDO_buildFocusMacroText = _G["VUHDO_buildFocusMacroText"];
	VUHDO_buildAssistMacroText = _G["VUHDO_buildAssistMacroText"];
	VUHDO_buildExtraActionButtonMacroText = _G["VUHDO_buildExtraActionButtonMacroText"];
	VUHDO_buildMouseLookMacroText = _G["VUHDO_buildMouseLookMacroText"];
	VUHDO_buildPingMacroText = _G["VUHDO_buildPingMacroText"];
	VUHDO_replaceMacroTemplates = _G["VUHDO_replaceMacroTemplates"];
	VUHDO_isActionValid = _G["VUHDO_isActionValid"];
	VUHDO_isSpellKnown = _G["VUHDO_isSpellKnown"];
	VUHDO_findButtonFromChild = _G["VUHDO_findButtonFromChild"];
	VUHDO_buildSecureMacroTemplate = _G["VUHDO_buildSecureMacroTemplate"];
	VUHDO_buildTargetSecureMacroTemplate = _G["VUHDO_buildTargetSecureMacroTemplate"];
	VUHDO_buildFocusSecureMacroTemplate = _G["VUHDO_buildFocusSecureMacroTemplate"];
	VUHDO_buildAssistSecureMacroTemplate = _G["VUHDO_buildAssistSecureMacroTemplate"];
	VUHDO_buildPingSecureMacroTemplate = _G["VUHDO_buildPingSecureMacroTemplate"];
	VUHDO_buildExtraActionButtonSecureMacroTemplate = _G["VUHDO_buildExtraActionButtonSecureMacroTemplate"];
	VUHDO_buildRezSecureMacroTemplate = _G["VUHDO_buildRezSecureMacroTemplate"];
	VUHDO_buildPurgeSecureMacroTemplate = _G["VUHDO_buildPurgeSecureMacroTemplate"];
	VUHDO_buildCustomMacroSecureTemplate = _G["VUHDO_buildCustomMacroSecureTemplate"];
	VUHDO_generateSetupClicksCode = _G["VUHDO_generateSetupClicksCode"];
	VUHDO_generateRemoveClicksCode = _G["VUHDO_generateRemoveClicksCode"];
	VUHDO_getBindingAttributeRequirements = _G["VUHDO_getBindingAttributeRequirements"];
	VUHDO_isBossUnit = _G["VUHDO_isBossUnit"];

	sIsCliqueCompat = VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"];

end



--
local sHealButtonAttributeChangedSnippet = [[
	if name == "vuhdo-unit-exists" and value == "false" and sHealButton then
		local tX, tY = sHealButton:GetMousePosition();

		local tXInBounds;
		local tYInBounds;

		if not tX or type(tX) ~= "number" then
			tXInBounds = false;
		else
			tXInBounds = tX >= 0 and tX <= 1;
		end

		if not tY or type(tY) ~= "number" then
			tYInBounds = false;
		else
			tYInBounds = tY >= 0 and tY <= 1;
		end

		if not sHealButton:IsVisible() or not tXInBounds or not tYInBounds then
			sHealButton:ClearBindings();

			sHealButton = nil;
		end
	end
]];



--
function VUHDO_setupHealButtonSecureHeader(aFrame)

	aFrame:SetAttribute("_onattributechanged", sHealButtonAttributeChangedSnippet);

	RegisterAttributeDriver(aFrame, "vuhdo-unit-exists", "[@mouseover, exists] true; false");

	return;

end



local VUHDO_REZ_SPELLS_NAMES = {
	[VUHDO_SPELL_ID.REDEMPTION] = true,
	[VUHDO_SPELL_ID.ABSOLUTION] = true,
	[VUHDO_SPELL_ID.INTERCESSION] = true,
	[VUHDO_SPELL_ID.ANCESTRAL_SPIRIT] = true,
	[VUHDO_SPELL_ID.ANCESTRAL_VISION] = true,
	[VUHDO_SPELL_ID.REVIVE] = true,
	[VUHDO_SPELL_ID.REBIRTH] = true,
	[VUHDO_SPELL_ID.REVITALIZE] = true,
	[VUHDO_SPELL_ID.RESURRECTION] = true,
	[VUHDO_SPELL_ID.MASS_RESURRECTION] = true,
	[VUHDO_SPELL_ID.RESUSCITATE] = true,
	[VUHDO_SPELL_ID.REAWAKEN] = true,
	[VUHDO_SPELL_ID.RETURN] = true,
	[VUHDO_SPELL_ID.MASS_RETURN] = true,
};



--
local tUnit, tInfo;
local tMacroId, tMacroText;
local tActionLow;
local function _VUHDO_setupHealButtonAttributes(aModiKey, aButtonId, anAction, aButton, anIsTgButton, anIndex)

	tUnit = aButton["raidid"];

	if not anAction then
		return;
	end

	tActionLow = strlower(anAction);

	if tActionLow then
		if "assist" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildAssistMacroText(tUnit));
		elseif "focus" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildFocusMacroText(tUnit));
		elseif "target" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildTargetMacroText(tUnit));
		elseif "extraactionbutton" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildExtraActionButtonMacroText(tUnit));
		elseif "mouselook" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildMouseLookMacroText());
		elseif "ping" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildPingMacroText(tUnit));
		elseif "menu" == tActionLow or "tell" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, nil);
		elseif "dropdown" == tActionLow then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "togglemenu");
		else
			anAction = VUHDO_REPLACE_SPELL_NAME[anAction] or anAction;

			if VUHDO_NATIVE_ASSIGN_SPELLS[anAction] then
				VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "spell");
				VUHDO_safeSetAttribute(aButton, aModiKey .. "spell" .. aButtonId, anAction);
			elseif VUHDO_isSpellKnown(anAction) or VUHDO_IN_COMBAT_RELOG or anAction == "13" or anAction == "14" then -- Spells may not be initialized yet
				-- Dead players do not trigger "help/noharm" conditionals
				if VUHDO_REZ_SPELLS_NAMES[anAction] then
					VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
					VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildRezMacroText(anAction, tUnit));

					return;
				-- Cleansing charmed players is an offensive thing to do
				elseif VUHDO_BUFF_REMOVAL_SPELLS[anAction] then
					VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
					VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildPurgeMacroText(anAction, tUnit));

					return;
				else
					-- build a spell macro
					VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
					VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, VUHDO_buildMacroText(anAction, false, tUnit));
				end
			else
				tMacroId = GetMacroIndexByName(anAction);

				if tMacroId ~= 0 then -- Macro?
					_, _, tMacroText = GetMacroInfo(tMacroId);

					tMacroText = VUHDO_replaceMacroTemplates(tMacroText, tUnit);

					VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");
					VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, tMacroText);
				elseif IsUsableItem(anAction) then -- Item?
					VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "item");
					VUHDO_safeSetAttribute(aButton, aModiKey .. "item" .. aButtonId, anAction);
				else -- we don't know, assume it's a spell
					VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "spell");
					VUHDO_safeSetAttribute(aButton, aModiKey .. "spell" .. aButtonId, anAction);
				end
			end
		end
	end

end



--
local tActionLow;
local tMacroId;
local tMacroText;
local tType;
local tTemplate;
function VUHDO_getSecureActionForBinding(anAction, anUsesPet)

	if not anAction or anAction == "" then
		return nil, nil;
	end

	tActionLow = strlower(anAction);

	if "assist" == tActionLow then
		tType = "macro";

		tTemplate = VUHDO_buildAssistSecureMacroTemplate(anUsesPet);
	elseif "focus" == tActionLow then
		tType = "macro";

		tTemplate = VUHDO_buildFocusSecureMacroTemplate(anUsesPet);
	elseif "target" == tActionLow then
		tType = "macro";

		tTemplate = VUHDO_buildTargetSecureMacroTemplate(anUsesPet);
	elseif "extraactionbutton" == tActionLow then
		tType = "macro";

		tTemplate = VUHDO_buildExtraActionButtonSecureMacroTemplate();
	elseif "mouselook" == tActionLow then
		tType = "macro";

		tTemplate = VUHDO_buildMouseLookMacroText();
	elseif "ping" == tActionLow then
		tType = "macro";

		tTemplate = VUHDO_buildPingSecureMacroTemplate();
	elseif "menu" == tActionLow or "tell" == tActionLow then
		return nil, nil;
	elseif "dropdown" == tActionLow then
		return "togglemenu", nil;
	else
		anAction = VUHDO_REPLACE_SPELL_NAME[anAction] or anAction;

		if VUHDO_NATIVE_ASSIGN_SPELLS[anAction] then
			return "spell", anAction;
		elseif VUHDO_isSpellKnown(anAction) or VUHDO_IN_COMBAT_RELOG or anAction == "13" or anAction == "14" then
			if VUHDO_REZ_SPELLS_NAMES[anAction] then
				tType = "macro";

				tTemplate = VUHDO_buildRezSecureMacroTemplate(anAction);
			elseif VUHDO_BUFF_REMOVAL_SPELLS[anAction] then
				tType = "macro";

				tTemplate = VUHDO_buildPurgeSecureMacroTemplate(anAction);
			else
				tType = "macro";

				tTemplate = VUHDO_buildSecureMacroTemplate(anAction, false);
			end
		else
			tMacroId = GetMacroIndexByName(anAction);

			if tMacroId ~= 0 then
				_, _, tMacroText = GetMacroInfo(tMacroId);

				tType = "macro";

				tTemplate = VUHDO_buildCustomMacroSecureTemplate(tMacroText);
			elseif IsUsableItem(anAction) then
				return "item", anAction;
			else
				return "spell", anAction;
			end
		end
	end

	return tType, tTemplate;

end



--
local tTemplate;
local tMacroId;
local tMacroText;
local tActionLow;
function VUHDO_getMacroTemplateForAction(anAction)

	if not anAction or anAction == "" then
		return "";
	end

	tActionLow = strlower(anAction);

	if "assist" == tActionLow then
		return VUHDO_buildAssistSecureMacroTemplate(true);
	elseif "focus" == tActionLow then
		return VUHDO_buildFocusSecureMacroTemplate(true);
	elseif "target" == tActionLow then
		return VUHDO_buildTargetSecureMacroTemplate(true);
	elseif "ping" == tActionLow then
		return VUHDO_buildPingSecureMacroTemplate();
	elseif "extraactionbutton" == tActionLow then
		return VUHDO_buildExtraActionButtonSecureMacroTemplate();
	elseif "mouselook" == tActionLow then
		return "";
	elseif "menu" == tActionLow or "tell" == tActionLow or "dropdown" == tActionLow then
		return "";
	end

	tMacroId = GetMacroIndexByName(anAction);

	if tMacroId ~= 0 then
		_, _, tMacroText = GetMacroInfo(tMacroId);

		return VUHDO_buildCustomMacroSecureTemplate(tMacroText);
	end

	if VUHDO_REZ_SPELLS_NAMES[anAction] then
		return VUHDO_buildRezSecureMacroTemplate(anAction);
	end

	if VUHDO_BUFF_REMOVAL_SPELLS[anAction] then
		return VUHDO_buildPurgeSecureMacroTemplate(anAction);
	end

	return VUHDO_buildSecureMacroTemplate(anAction, false);

end



--
local tUnit;
local tHostSpell;
local tSpellInfo;
local tActionLow;
local function VUHDO_setupHealButtonAttributes(aModiKey, aButtonId, anAction, aButton, anIsTgButton, anIndex)

	tUnit = aButton["raidid"];
	tActionLow = strlower(anAction);

	if anIsTgButton or tUnit == "focus" or (tUnit == "target" and "dropdown" ~= tActionLow) or VUHDO_isBossUnit(tUnit) then
		if not anIndex then
			tSpellInfo = VUHDO_HOSTILE_SPELL_ASSIGNMENTS[VUHDO_KEYS_MODIFIER[aModiKey] .. aButtonId];
			tHostSpell = tSpellInfo ~= nil and tSpellInfo[3] or "";
		else
			tHostSpell = VUHDO_SPELLS_KEYBOARD["HOSTILE_WHEEL"][anIndex][3];
		end

		VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, "macro");

		if (tHostSpell or "") ~= "" or (tActionLow or "") ~= "" then
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId,
				VUHDO_buildTargetButtonMacroText(tUnit, tActionLow, tHostSpell));
		else
			VUHDO_safeSetAttribute(aButton, aModiKey .. "macrotext" .. aButtonId, nil);
		end

		return;
	end

	if (tActionLow or "") == "" then
		VUHDO_safeSetAttribute(aButton, aModiKey .. "type" .. aButtonId, nil);

		return;
	else
		_VUHDO_setupHealButtonAttributes(aModiKey, aButtonId, anAction, aButton, anIsTgButton, anIndex);
	end

end



--
local tString, tAssignIdx, tFriendSpell, tHostSpell;
local function VUHDO_getWheelDefString()
	tString = "";
	for tIndex, tValue in pairs(VUHDO_WHEEL_BINDINGS) do
		tAssignIdx = VUHDO_WHEEL_INDEX_BINDING[tIndex];
		tFriendSpell = VUHDO_SPELLS_KEYBOARD["HOSTILE_WHEEL"][tAssignIdx][3];
		tHostSpell = VUHDO_SPELLS_KEYBOARD["WHEEL"][tAssignIdx][3];

		if #tFriendSpell > 0 or #tHostSpell > 0 then
			tString = format("%sself:SetBindingClick(0, \"%s\", self:GetName(), \"w%d\");", tString, tValue, tIndex);
		end
	end
	return tString;
end



--
local tString;
local function VUHDO_getInternalKeyString()
	tString = "";
	for tIndex, tEntries in pairs(VUHDO_SPELLS_KEYBOARD["INTERNAL"]) do
		tString = format("%sself:SetBindingClick(0, [=[%s]=], self:GetName(), \"ik%d\");", tString, tEntries[2] or "", tIndex);
	end
	return tString;
end



--
local tPreAction;
local tIsWheel;
local tIsHostileButton;
local tHostSpell;
local tWheelDefString;
local tBinding;
local tHeaderFrame;
local tRequiresPet;
local tRequiresName;
local tRequiresTarget;
local tInfo;
local tOnEnterSnippet = [[
	if sHealButton then
		sHealButton:ClearBindings();
	end

	sHealButton = self;
]]
local tOnLeaveSnippet = [[
	self:ClearBindings();

	sHealButton = nil;
]]
local tClearBindsSnippet = [[
	self:ClearBindings();
]]



--
local tWheelDefString;
function VUHDO_generateOnEnterCode()

	tWheelDefString = tClearBindsSnippet .. VUHDO_getWheelDefString() .. VUHDO_getInternalKeyString();

	return tWheelDefString;

end



--
function VUHDO_generateOnLeaveCode()

	return tClearBindsSnippet;

end



--
local tHeader;
local tSetupCode;
local tRemoveCode;
local tEnterCode;
local tLeaveCode;
function VUHDO_updateBindingCodeAttributes()

	tHeader = _G["VuhDoHealButtonSecureHeaderFrame"];

	if not tHeader then
		return;
	end

	tSetupCode = VUHDO_generateSetupClicksCode();
	tRemoveCode = VUHDO_generateRemoveClicksCode();
	tEnterCode = VUHDO_generateOnEnterCode();
	tLeaveCode = VUHDO_generateOnLeaveCode();

	tHeader:SetAttribute("vuhdo_setup_clicks", tSetupCode);
	tHeader:SetAttribute("vuhdo_remove_clicks", tRemoveCode);
	tHeader:SetAttribute("vuhdo_setup_onenter", tEnterCode);
	tHeader:SetAttribute("vuhdo_setup_onleave", tLeaveCode);

	return;

end



--
local tDebuffFrame;
function VUHDO_setupAllHealButtonAttributes(aButton, aUnit, anIsDisable, aForceTarget, anIsTgButton, anIsIcButton)

	if aUnit and not anIsIcButton then
		VUHDO_safeSetAttribute(aButton, "unit", aUnit);
		aButton["raidid"] = aUnit;

		if not anIsTgButton then
			for tCnt = 40, VUHDO_CONFIG["CUSTOM_DEBUFF"]["max_num"] + 39 do
				tDebuffFrame = VUHDO_getBarIconFrame(aButton, tCnt);

				if tDebuffFrame then
					VUHDO_safeSetAttribute(tDebuffFrame, "unit", aUnit);
					tDebuffFrame["raidid"] = aUnit;
				end
			end
		end
	end

	if not aButton:GetAttribute("vd_tt_hook") then
		if anIsIcButton then
			aButton:HookScript("OnEnter", function(self) VUHDO_showDebuffTooltip(self); VuhDoActionOnEnter(VUHDO_findButtonFromChild(self)) end);
			aButton:HookScript("OnLeave", function(self) VUHDO_hideDebuffTooltip(); VuhDoActionOnLeave(VUHDO_findButtonFromChild(self)) end);
		else
			aButton:HookScript("OnEnter",	function(self) VuhDoActionOnEnter(self); end);
			aButton:HookScript("OnLeave",	function(self) VuhDoActionOnLeave(self); end);
		end

		VUHDO_safeSetAttribute(aButton, "vd_tt_hook", true);
	end

	if sIsCliqueCompat then
		VUHDO_PixelUtil.EnableMouseWheel(aButton, 1);

		return;
	end

	tPreAction = anIsDisable and "" or aForceTarget and "target" or nil;

	tIsHostileButton = anIsTgButton or (aUnit and (aUnit == "focus" or aUnit == "target" or VUHDO_isBossUnit(aUnit)));

	if tIsHostileButton then
		for tNoMinus, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
			for tCnt = 1, 16 do
				tBinding = VUHDO_SPELL_ASSIGNMENTS[format("%s%d", tNoMinus, tCnt)];

				VUHDO_setupHealButtonAttributes(tWithMinus, tCnt,
					tPreAction or tBinding ~= nil and tBinding[3] or "",
					aButton, anIsTgButton);
			end
		end
	else
		if not InCombatLockdown() then
			VUHDO_updateBindingCodeAttributes();

			tRequiresPet, tRequiresName, tRequiresTarget = VUHDO_getBindingAttributeRequirements();

			tInfo = VUHDO_RAID[aUnit];

			if tRequiresPet and tInfo and tInfo["petUnit"] then
				VUHDO_safeSetAttribute(aButton, "vuhdo-pet", tInfo["petUnit"]);
			end

			if tRequiresName and tInfo and tInfo["name"] and not tInfo["hasSecretName"] then
				VUHDO_safeSetAttribute(aButton, "vuhdo-name", tInfo["name"]);
			end

			if tRequiresTarget and tInfo and tInfo["targetUnit"] then
				VUHDO_safeSetAttribute(aButton, "vuhdo-target", tInfo["targetUnit"]);
			end

			tHeaderFrame = _G["VuhDoHealButtonSecureHeaderFrame"];

			if tHeaderFrame then
				tHeaderFrame:SetFrameRef("vuhdo_setup_button", aButton);

				tHeaderFrame:Execute([[
					local button = self:GetFrameRef("vuhdo_setup_button")
					self:RunFor(button, self:GetAttribute("vuhdo_setup_clicks"))
				]]);

				VUHDO_safeSetAttribute(aButton, "_onenter", tHeaderFrame:GetAttribute("vuhdo_setup_onenter"));
				VUHDO_safeSetAttribute(aButton, "_onleave", tHeaderFrame:GetAttribute("vuhdo_setup_onleave"));
			end
		else
			for tNoMinus, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
				for tCnt = 1, 16 do
					tBinding = VUHDO_SPELL_ASSIGNMENTS[format("%s%d", tNoMinus, tCnt)];

					VUHDO_setupHealButtonAttributes(tWithMinus, tCnt,
						tPreAction or tBinding ~= nil and tBinding[3] or "",
						aButton, anIsTgButton);
				end
			end
		end
	end

	tIsWheel = false;

	for tIndex, tSpellDescr in pairs(VUHDO_SPELLS_KEYBOARD["WHEEL"]) do
		tHostSpell = VUHDO_SPELLS_KEYBOARD["HOSTILE_WHEEL"][tIndex][3];

		if #tSpellDescr[3] > 0 or #tHostSpell > 0 then
			tIsWheel = true;

			VUHDO_setupHealButtonAttributes("", tSpellDescr[2], tSpellDescr[3], aButton, anIsTgButton, tIndex);
		end
	end

	for tIndex, tEntries in pairs(VUHDO_SPELLS_KEYBOARD["INTERNAL"]) do
		if VUHDO_isActionValid(tEntries[1], false) then
			_VUHDO_setupHealButtonAttributes("",  "-ik" .. tIndex, tEntries[1], aButton, anIsTgButton, tIndex);
		else
			VUHDO_safeSetAttribute(aButton, "type-ik" .. tIndex, "macro");
			VUHDO_safeSetAttribute(aButton, "macrotext-ik" .. tIndex, VUHDO_replaceMacroTemplates(tEntries[3] or "", aUnit));
		end
	end

	if VUHDO_BUTTON_CACHE[aButton] or VUHDO_BUTTON_CACHE[VUHDO_findButtonFromChild(aButton)] then
		tWheelDefString = tClearBindsSnippet;

		if tIsWheel then
			tWheelDefString = tWheelDefString .. VUHDO_getWheelDefString();
		end

		tWheelDefString = tWheelDefString .. VUHDO_getInternalKeyString();

		VUHDO_safeSetAttribute(aButton, "_onenter", tWheelDefString);
		VUHDO_safeSetAttribute(aButton, "_onleave", tClearBindsSnippet);
		VUHDO_safeSetAttribute(aButton, "_onshow", tClearBindsSnippet);
		VUHDO_safeSetAttribute(aButton, "_onhide", tClearBindsSnippet);

		VUHDO_safeSetAttribute(aButton, "vuhdo_onenter", tWheelDefString);
		VUHDO_safeSetAttribute(aButton, "vuhdo_onleave", tClearBindsSnippet);

		tHeaderFrame = _G["VuhDoHealButtonSecureHeaderFrame"];

		if tHeaderFrame then
			if not aButton:GetAttribute("vuhdo_secureheader_wrap") then
				VUHDO_safeWrapScript(tHeaderFrame, aButton, "OnEnter", tOnEnterSnippet);
				VUHDO_safeWrapScript(tHeaderFrame, aButton, "OnLeave", tOnLeaveSnippet);

				VUHDO_safeSetAttribute(aButton, "vuhdo_secureheader_wrap", true);
			end
		end
	end

end
local VUHDO_setupAllHealButtonAttributes = VUHDO_setupAllHealButtonAttributes;



--
local tProhibitSmartCastOn = {
	["target"] = true,
	["assist"] = true,
	["focus"] = true,
	["menu"] = true,
	["dropdown"] = true,
	["tell"] = true,
	["boss1"] = true,
	["boss2"] = true,
	["boss3"] = true,
	["boss4"] = true,
	["boss5"] = true,
	["boss6"] = true,
	["boss7"] = true,
	["boss8"] = true,
};
-- Setup for smart cast
local tKey;
local function VUHDO_setupAllButtonsTo(aButton, aSpellName)
	for tNoMinus, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
		for tCnt = 1, VUHDO_NUM_MOUSE_BUTTONS do
			tKey = tNoMinus .. tCnt;
			if not VUHDO_SPELL_ASSIGNMENTS[tKey] or not tProhibitSmartCastOn[VUHDO_SPELL_ASSIGNMENTS[tKey][3]] then
				VUHDO_setupHealButtonAttributes(tWithMinus, tCnt, aSpellName, aButton, false);
			end
		end
	end
end



--
function VUHDO_setupAllTargetButtonAttributes(aButton, aUnit)
	VUHDO_setupAllHealButtonAttributes(aButton, aUnit .. "target", false, false, true, false);
end



--
function VUHDO_setupAllTotButtonAttributes(aButton, aUnit)
	VUHDO_setupAllHealButtonAttributes(aButton, aUnit .. "targettarget", false, false, true, false);
end



--
function VUHDO_disableActions(aButton)
	VUHDO_setupAllHealButtonAttributes(aButton, nil, true, false, false, false);

	aButton:Hide(); -- For clearing mouse-wheel click bindings
	aButton:Show();
end



--
local tCursorItemType;
local tAbilities;
local tAbility;
local tUnit;
local tInfo;
local tBuff;
function VUHDO_setupSmartCast(aButton)
	if InCombatLockdown() or UnitIsDeadOrGhost("player")
		or (VUHDO_PLAYER_CLASS == "PRIEST" and GetShapeshiftForm() == 4) then -- Priest Spirit of Redemption?
		return false;
	end

	tUnit = aButton["raidid"];
	tInfo = VUHDO_RAID[tUnit];

	if not tInfo then return false; end

	-- Resurrect?
	if VUHDO_CONFIG["SMARTCAST_RESURRECT"] and tInfo["dead"] then
		local tMainRes = VUHDO_getResurrectionSpells();
		if tMainRes then
			VUHDO_setupAllButtonsTo(aButton, tMainRes);
			return true;
		end
	end

	if not (tInfo["hasSecretRange"] or (issecretvalue and issecretvalue(tInfo["baseRange"]))) and not tInfo["baseRange"] then
		return false;
	end

	-- Trade?
	tCursorItemType = GetCursorInfo();
	if "item" == tCursorItemType or "money" == tCursorItemType then
		DropItemOnUnit(tUnit);
		VUHDO_disableActions(aButton);
		return true;
	end

	-- Cleanse?
	if VUHDO_CONFIG["SMARTCAST_CLEANSE"] and not tInfo["dead"] then
		if VUHDO_DEBUFF_TYPE_NONE ~= tInfo["debuff"] then
			tAbilities = VUHDO_getDispelAbilities();
			tAbility = tAbilities[tInfo["debuff"]];

			-- never smart cast cleanse a tank with BoP to avoid aggro loss
			if tAbility and
				(tInfo["role"] ~= VUHDO_ID_MELEE_TANK or tAbility ~= VUHDO_SPELL_ID.BLESSING_OF_PROTECTION) then
				VUHDO_setupAllButtonsTo(aButton, tAbility);

				return true;
			end
		end
	end

	-- Buff?
	if VUHDO_CONFIG["SMARTCAST_BUFF"] and tInfo["missbuff"] and not tInfo["dead"] then
		tBuff = tInfo["mibuvariants"];

		if VUHDO_isBuffOfTargetType(tBuff[1], VUHDO_BUFF_TARGET_HOSTILE) and not UnitIsEnemy("player", tUnit) then
			return false;
		else
			VUHDO_setupAllButtonsTo(aButton, tBuff[1]);
			VUHDO_setupHealButtonAttributes("", "2", tBuff[1], aButton, false);

			return true;
		end
	end

	return false;
end

