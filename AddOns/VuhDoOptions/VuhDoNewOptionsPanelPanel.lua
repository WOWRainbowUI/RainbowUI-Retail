local _;


--
local tMaxModels;
function VUHDO_newOptionsPanelFindDefaultPanel()
	tMaxModels = -1;
	DESIGN_MISC_PANEL_NUM = 1;

	for tCnt = 1, VUHDO_MAX_PANELS do
		if (VUHDO_PANEL_MODELS[tCnt] ~= nil and #VUHDO_PANEL_MODELS[tCnt] > tMaxModels) then
			DESIGN_MISC_PANEL_NUM = tCnt;
			tMaxModels = #VUHDO_PANEL_MODELS[tCnt];
		end
	end
end



--
local function VUHDO_refreshAllModelsForPanel(aPanel, aRefreshModels)

	if not aPanel or not aRefreshModels then
		return;
	end

	local tSubPanels = { aPanel:GetChildren() };

	for _, tSubPanel in pairs(tSubPanels) do
		if (tSubPanel:IsObjectType("Frame")) then
			local tModel = tSubPanel:GetAttribute("model");

			if (tModel ~= nil) then
				aRefreshModels[tModel] = true;
			end

			VUHDO_refreshAllModelsForPanel(tSubPanel, aRefreshModels);
		end
	end

end



--
local tActivePanel;
local tRefreshModels;
local tContentPane;
local tAllPanels;
local tValue;
function VUHDO_newOptionsApplyToAllOnClick()
	tActivePanel = nil;
	tRefreshModels = { };
	tContentPane = _G["VuhDoNewOptionsPanelPanelContentPanel"];
	tAllPanels = { tContentPane:GetChildren() };

	for _, tAktPanel in pairs(tAllPanels) do
		if (tAktPanel:IsObjectType("Frame") and tAktPanel:IsShown()) then
			tActivePanel = tAktPanel;
		end
	end

	if (tActivePanel == nil) then
		return;
	end

	VUHDO_refreshAllModelsForPanel(tActivePanel, tRefreshModels);

	if (tActivePanel:GetName() == "VuhDoNewOptionsPanelTooltip") then
		tRefreshModels["VUHDO_PANEL_SETUP.#PNUM#.TOOLTIP.x"] = true;
		tRefreshModels["VUHDO_PANEL_SETUP.#PNUM#.TOOLTIP.y"] = true;
		tRefreshModels["VUHDO_PANEL_SETUP.#PNUM#.TOOLTIP.point"] = true;
		tRefreshModels["VUHDO_PANEL_SETUP.#PNUM#.TOOLTIP.relativePoint"] = true;
	end

	for tModel, _ in pairs(tRefreshModels) do
		tValue = VUHDO_lnfGetValueFrom(tModel);
		for tCnt = 1, VUHDO_MAX_PANELS do
			if (tCnt ~= DESIGN_MISC_PANEL_NUM) then
				VUHDO_lnfUpdateVar(tModel, tValue, tCnt);
			end
		end
	end

	VUHDO_reloadUI(false);
end


--
function VUHDO_newOptionsShowHeadersEnableClicked(aCheckButton)
	if (aCheckButton:GetChecked()) then
		VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["MODEL"].ordering = 0;
	end
end



--
function VUHDO_newOptionsLooseRadioButtonClicked(aRadioButton)
	if (aRadioButton:GetChecked()) then
		VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["SCALING"].showHeaders = false;
	end
end



--
function VUHDO_newOptionsStrictRadioButtonClicked(aRadioButton)
	if (aRadioButton:GetChecked()) then
		VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["SCALING"].showHeaders = true;
	end
end

