local _;

local VUHDO_RAID;
local VUHDO_BUFF_REMOVAL_SPELLS;
local VUHDO_SPELL_ASSIGNMENTS;
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

local sIsCliqueCompat;

function VUHDO_keySetupInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_BUFF_REMOVAL_SPELLS = _G["VUHDO_BUFF_REMOVAL_SPELLS"];
	VUHDO_SPELL_ASSIGNMENTS = _G["VUHDO_SPELL_ASSIGNMENTS"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];

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

	sIsCliqueCompat = VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"];

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
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildAssistMacroText(tUnit));
		elseif "focus" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildFocusMacroText(tUnit));
		elseif "target" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildTargetMacroText(tUnit));
		elseif "extraactionbutton" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildExtraActionButtonMacroText(tUnit));
		elseif "mouselook" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildMouseLookMacroText());
		elseif "ping" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildPingMacroText(tUnit));
		elseif "menu" == tActionLow or "tell" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, nil);
		elseif "dropdown" == tActionLow then
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "VUHDO_contextMenu");

			VUHDO_contextMenu = function()
				tUnit = aButton["raidid"];
				local tName, tMenu;

				if UnitIsUnit(tUnit, "player") then
					tMenu = "SELF";
				elseif UnitIsUnit(tUnit, "vehicle") then
					tMenu = "VEHICLE";
				elseif UnitIsUnit(tUnit, "pet") then
					tMenu = "PET";
				elseif UnitIsPlayer(tUnit) then
					tInfo = VUHDO_RAID[tUnit];
				
					tName = tInfo["name"];

					if UnitInRaid(tUnit) then
						tMenu = "RAID_PLAYER";
					elseif UnitInParty(tUnit) then
						tMenu = "PARTY";
					else
						tMenu = "PLAYER";
					end
				else
					tMenu = "TARGET";
					tName = RAID_TARGET_ICON;
				end

				UIDropDownMenu_SetInitializeFunction(VuhDoUnitButtonDropDown,
					function(self)
						if tMenu then
							local tContextData = {
								unit = tUnit,
								name = tName,
							};

							UnitPopup_OpenMenu(tMenu, tContextData);
						end
					end
				);
				UIDropDownMenu_SetDisplayMode(VuhDoUnitButtonDropDown, "MENU");

				ToggleDropDownMenu(1, nil, VuhDoUnitButtonDropDown, "cursor", 0, 0);
			end

			aButton["VUHDO_contextMenu"] = VUHDO_contextMenu;
		else
			anAction = VUHDO_REPLACE_SPELL_NAME[anAction] or anAction;

			if VUHDO_NATIVE_ASSIGN_SPELLS[anAction] then
				aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "spell");
				aButton:SetAttribute(aModiKey .. "spell" .. aButtonId, anAction);
			elseif VUHDO_isSpellKnown(anAction) or VUHDO_IN_COMBAT_RELOG or anAction == "13" or anAction == "14" then -- Spells may not be initialized yet
				-- Dead players do not trigger "help/noharm" conditionals
				if VUHDO_REZ_SPELLS_NAMES[anAction] then
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
					aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildRezMacroText(anAction, tUnit));

					return;
				-- Cleansing charmed players is an offensive thing to do
				elseif VUHDO_BUFF_REMOVAL_SPELLS[anAction] then
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
					aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildPurgeMacroText(anAction, tUnit));

					return;
				else
					-- build a spell macro
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
					aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, VUHDO_buildMacroText(anAction, false, tUnit));
				end
			else
				tMacroId = GetMacroIndexByName(anAction);

				if tMacroId ~= 0 then -- Macro?
					_, _, tMacroText = GetMacroInfo(tMacroId);

					tMacroText = VUHDO_replaceMacroTemplates(tMacroText, tUnit);

					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
					aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, tMacroText);
				elseif IsUsableItem(anAction) then -- Item?
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "item");
					aButton:SetAttribute(aModiKey .. "item" .. aButtonId, anAction);
				else -- we don't know, assume it's a spell
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "spell");
					aButton:SetAttribute(aModiKey .. "spell" .. aButtonId, anAction);
				end
			end
		end
	end

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

		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");

		if (tHostSpell or "") ~= "" or (tActionLow or "") ~= "" then
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
				VUHDO_buildTargetButtonMacroText(tUnit, tActionLow, tHostSpell));
		else
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, nil);
		end

		return;
	end

	if (tActionLow or "") == "" then
		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, nil);

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



-- Parse and interpret action-type
local tPreAction;
local tIsWheel;
local tHostSpell;
local tWheelDefString;
local tBinding;
local tHeaderFrame;
local tOnEnterSnippet = [[
	if sHealButton then
		sHealButton:ClearBindings();
	end
	sHealButton = self;
]]
local tOnLeaveSnippet = [[
	sHealButton = nil;
]]
local tClearBindsSnippet = "self:ClearBindings();";
function VUHDO_setupAllHealButtonAttributes(aButton, aUnit, anIsDisable, aForceTarget, anIsTgButton, anIsIcButton)

	if aUnit then
		aButton:SetAttribute("unit", aUnit);
		aButton["raidid"] = aUnit;
	end

	if not aButton:GetAttribute("vd_tt_hook") then
		if anIsIcButton then
			aButton:HookScript("OnEnter", function(self) VUHDO_showDebuffTooltip(self); VuhDoActionOnEnter(self:GetParent():GetParent():GetParent():GetParent()) end);
			aButton:HookScript("OnLeave", function(self) VUHDO_hideDebuffTooltip(); VuhDoActionOnLeave(self:GetParent():GetParent():GetParent():GetParent()) end);
		else
			aButton:HookScript("OnEnter",	function(self) VuhDoActionOnEnter(self); end);
			aButton:HookScript("OnLeave",	function(self) VuhDoActionOnLeave(self); end);
		end
		aButton:SetAttribute("vd_tt_hook", true);
	end

	if sIsCliqueCompat then
		aButton:EnableMouseWheel(1);
		return;
	end

	tPreAction = anIsDisable and "" or aForceTarget and "target" or nil;

	for tNoMinus, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
		for tCnt = 1, 16 do -- VUHDO_NUM_MOUSE_BUTTONS
			tBinding = VUHDO_SPELL_ASSIGNMENTS[format("%s%d", tNoMinus, tCnt)];
			VUHDO_setupHealButtonAttributes(tWithMinus, tCnt,
				tPreAction or tBinding ~= nil and tBinding[3] or "",
				aButton, anIsTgButton);
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
			aButton:SetAttribute("type-ik" .. tIndex, "macro");
			aButton:SetAttribute("macrotext-ik" .. tIndex, VUHDO_replaceMacroTemplates(tEntries[3] or "", aUnit));
		end
	end

	if VUHDO_BUTTON_CACHE[aButton] or VUHDO_BUTTON_CACHE[aButton:GetParent():GetParent():GetParent():GetParent()] then
		tWheelDefString = tClearBindsSnippet;

		if tIsWheel then
			tWheelDefString = tWheelDefString .. VUHDO_getWheelDefString();
		end

		tWheelDefString = tWheelDefString .. VUHDO_getInternalKeyString();

		aButton:SetAttribute("_onenter", tWheelDefString);

		aButton:SetAttribute("_onleave", tClearBindsSnippet);
		aButton:SetAttribute("_onshow", tClearBindsSnippet);
		aButton:SetAttribute("_onhide", tClearBindsSnippet);

		if not aButton:GetAttribute("vuhdo_secureheader_wrap") then
			tHeaderFrame = _G["VuhDoHealButtonSecureHeaderFrame"];

			if tHeaderFrame then
				tHeaderFrame:WrapScript(aButton, "OnEnter", tOnEnterSnippet);
				tHeaderFrame:WrapScript(aButton, "OnLeave", tOnLeaveSnippet);

				aButton:SetAttribute("vuhdo_secureheader_wrap", true);
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

	if not tInfo["baseRange"] then return false; end

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

