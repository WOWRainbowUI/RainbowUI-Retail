local _;

local format = string.format;
local strmatch = strmatch;
local tonumber = tonumber;
local twipe = table.wipe;

local sClickBindingWarningKeys = { };

VUHDO_CURR_SPELL_MODIFIER = "";


function VUHDO_newOptionsSpellSetModifier(aModifier)
	local tComponents;
	local tNum;
	local tModel;
	local tBox;
	local tIndex;

	VUHDO_CURR_SPELL_MODIFIER = aModifier;

	tComponents = { VuhDoNewOptionsSpellMouseKeyPanelScrollPanelChild:GetChildren() };
	for _, tPanel in pairs(tComponents) do
		tNum = VUHDO_getNumbersFromString(tPanel:GetName(), 1)[1];
		if (tNum ~= nil) then
			tBox = _G[tPanel:GetName() .. "EditBox"];
			tIndex = aModifier .. tNum;
			if (VUHDO_SPELL_ASSIGNMENTS[tIndex] == nil) then
				VUHDO_SPELL_ASSIGNMENTS[tIndex] = { VUHDO_MODIFIER_KEYS[aModifier], tostring(tNum), "" };
			end
			tModel = "VUHDO_SPELL_ASSIGNMENTS." .. tIndex .. ".##3";
			tBox:SetAttribute("model", tModel);
			tBox:Hide();
			tBox:Show();
		end
	end

	tComponents = { VuhDoNewOptionsSpellMouseWheelPanel:GetChildren() };
	for _, tComp in pairs(tComponents) do
		if (tComp:IsObjectType("EditBox")) then
			tNum = VUHDO_getComponentPanelNum(tComp);
			tModel = "VUHDO_SPELLS_KEYBOARD.WHEEL." .. aModifier .. tNum .. ".##3";
			tComp:SetAttribute("model", tModel);
			tComp:Hide();
			tComp:Show();
		end
	end

end



--
function VUHDO_newOptionsSpellResetClickBindingWarnings()

	twipe(sClickBindingWarningKeys);

	return;

end



do
	--
	local tModel;
	local tModifier;
	local tMouseButtonNum;
	local tActionName;
	local tClickText;
	local tWarningKey;
	function VUHDO_newOptionsSpellEditBoxCheckClickBinding(anEditBox, aHintLabel)

		if VUHDO_strempty(anEditBox:GetText()) then
			sClickBindingWarningKeys[anEditBox] = nil;

			return;
		end

		tModel = anEditBox:GetAttribute("model");

		if not tModel then
			sClickBindingWarningKeys[anEditBox] = nil;

			return;
		end

		tModifier, tMouseButtonNum = strmatch(tModel, "^VUHDO_[%u_]*SPELL_ASSIGNMENTS%.(%l*)(%d+)%.##3$");

		if not tMouseButtonNum then
			sClickBindingWarningKeys[anEditBox] = nil;

			return;
		end

		tActionName, tClickText = VUHDO_getClickBindingConflict(tModifier, tonumber(tMouseButtonNum));

		if not tActionName then
			sClickBindingWarningKeys[anEditBox] = nil;

			return;
		end

		tWarningKey = format("%s|%s", tActionName, tClickText);

		if sClickBindingWarningKeys[anEditBox] ~= tWarningKey then
			sClickBindingWarningKeys[anEditBox] = tWarningKey;

			VUHDO_Msg(format(VUHDO_I18N_CLICK_BINDING_CONFLICT, tActionName, tClickText), 1, 0.3, 0.3);
		end

		aHintLabel:SetText(VUHDO_I18N_WARNING);
		aHintLabel:SetTextColor(1, 0.3, 0.3, 1);

		return;

	end
end



--
function VUHDO_newOptionsSpellEditBoxCheckSpell(anEditBox, anIsCustom)

	local tText, tR, tG, tB = VUHDO_isActionValid(anEditBox:GetText(), anIsCustom);
	local tLabel = _G[anEditBox:GetName() .. "Hint"];

	anEditBox["skinKeepTextColor"] = true;

	if (tText ~= nil) then
		anEditBox:SetTextColor(1, 1, 1, 1);

		tLabel:SetText(tText);
		tLabel:SetTextColor(tR, tG, tB, 1);
	else
		anEditBox:SetTextColor(0.8, 0.8, 1, 1);

		tLabel:SetText("");
	end

	VUHDO_newOptionsSpellEditBoxCheckClickBinding(anEditBox, tLabel);

	return;

end



--
local sButtonTitles = {
	VUHDO_I18N_LEFT_BUTTON,
	VUHDO_I18N_RIGHT_BUTTON,
	VUHDO_I18N_MIDDLE_BUTTON,
	VUHDO_I18N_BUTTON_4,
	VUHDO_I18N_BUTTON_5,
}



--
local function VUHDO_addSpellEditBox(aScrollPanel, anIndex)
	local tFrame = CreateFrame("Frame", aScrollPanel:GetName() .. "E" .. anIndex, aScrollPanel, "VuhDoNewOptionsSpellMouseEditBoxTemplate");
	VUHDO_PixelUtil.SetPoint(tFrame, "TOPLEFT", aScrollPanel:GetName(), "TOPLEFT", 23, -(anIndex - 1) * tFrame:GetHeight() - 7);
	_G[tFrame:GetName() .. "LabelLabel"]:SetText(sButtonTitles[anIndex] or (VUHDO_I18N_BUTTON .. " " .. anIndex));
	return tFrame;
end



--
function VUHDO_newOptionsSpellMouseScrollPanelOnLoad(aScrollPanel)
	local tFrame;
	for tCnt = 1, VUHDO_NUM_MOUSE_BUTTONS do
		tFrame = VUHDO_addSpellEditBox(aScrollPanel, tCnt);
	end

	VUHDO_PixelUtil.SetHeight(aScrollPanel, VUHDO_NUM_MOUSE_BUTTONS * tFrame:GetHeight() + 18);
end
