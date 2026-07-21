local _, DR = ...;
local Print = DR.Print;
local L = DR.L;

-- v 1 export/import key whitelist
DR.ExportWhitelist = {
	["speedTextFlagOutline"] = true,
	["vigorBarOrientation"] = true,
	["vigorPosY"] = true,
	["showGroundSkimming"] = true,
	["toggleTopper"] = true,
	["toggleFlashFull"] = true,
	["vigorRotation"] = true,
	["vigorScale"] = true,
	["vigorBarWidth"] = true,
	["vigorBarDirection"] = true,
	["speedTextJustify"] = true,
	["sideArt"] = true,
	["speedometerScale"] = true,
	["speedometerPosX"] = true,
	["sideArtStyle"] = true,
	["speedTextFont"] = true,
	["vigorBarSpacing"] = true,
	["speedometerPosY"] = true,
	["sideArtPosX"] = true,
	["speedTextFlagSlug"] = true,
	["toggleModels"] = true,
	["speedometerHeight"] = true,
	["vigorPosX"] = true,
	["groundSkimmingColor"] = true,
	["speedBarTexture"] = true,
	["speedometerWidth"] = true,
	["speedBarColor"] = true,
	["sideArtRot"] = true,
	["position"] = true,
	["sideArtPosY"] = true,
	["mainFrameSize"] = true,
	["toggleFlashProgress"] = true,
	["staticChargeWidth"] = true,
	["staticChargeHeight"] = true,
	["hideVigor"] = true,
	["vigorBarColor"] = true,
	["muteVigorSound"] = true,
	["speedTextScale"] = true,
	["speedTextDecimals"] = true,
	["toggleSpeedometer"] = true,
	["toggleFooter"] = true,
	["sideArtSize"] = true,
	["speedTextColor"] = true,
	["speedometerPosPoint"] = true,
	["themeSpeed"] = true,
	["staticChargeOffset"] = true,
	["toggleVigor"] = true,
	["modelTheme"] = true,
	["vigorBarFillDirection"] = true,
	["speedTextFlagMonochrome"] = true,
	["vigorSparkThickness"] = true,
	["vigorProgressStyle"] = true,
	["speedTextFlagThickOutline"] = true,
	["vigorBarHeight"] = true,
	["vigorWrap"] = true,
	["themeVigor"] = true,
	["staticChargeSpacing"] = true,
};

--profile functions
local function InitializeProfileDB()
	if not DragonRider_DB then DragonRider_DB = {}; end
	if not DragonRider_DB.Profiles then DragonRider_DB.Profiles = {}; end
	if not DragonRider_DB.CharSpecLinks then DragonRider_DB.CharSpecLinks = {}; end
end

function DR.AutoSaveActiveProfile()
	if DragonRider_DB and DragonRider_DB.ActiveProfile then
		DR.SaveProfile(DragonRider_DB.ActiveProfile);
	end
end

function DR.SaveProfile(profileName)
	if not profileName or profileName == "" then return; end
	InitializeProfileDB();
	
	local newProfile = CopyTable(DragonRider_DB); -- kinda lazy, but it works
	newProfile.Profiles = nil ;
	newProfile.ActiveProfile = nil;
	newProfile.AccountProfile = nil;
	newProfile.CharSpecLinks = nil; --wouldn't want any infinite loops
	
	DragonRider_DB.Profiles[profileName] = newProfile;
	DragonRider_DB.ActiveProfile = profileName;
	--print("DEBUG Profile '" .. profileName .. "' saved.")
end

local function DeepCopyInPlace(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" and type(dest[k]) == "table" then
			DeepCopyInPlace(dest[k], v);
		else
			if type(v) == "table" then
				dest[k] = CopyTable(v);
			else
				dest[k] = v;
			end
		end
	end
end

function DR.LoadProfile(profileName)
	InitializeProfileDB();
	if not profileName or not DragonRider_DB.Profiles[profileName] then return; end

	local loadedProfile = DragonRider_DB.Profiles[profileName];

	for key, value in pairs(loadedProfile) do
		if key ~= "Profiles" and key ~= "ActiveProfile" and key ~= "AccountProfile" and key ~= "CharSpecLinks" then
			if type(value) == "table" and type(DragonRider_DB[key]) == "table" then
				DeepCopyInPlace(DragonRider_DB[key], value);
			else
				DragonRider_DB[key] = value;
			end
		end
	end

	DragonRider_DB.ActiveProfile = profileName;

	DR.setPositions();
	DR.UpdateSpeedometerTheme();
	DR.UpdateSpeedTextAppearance();
	DR.UpdateVigorLayout();
	DR.UpdateVigorFillDirection();
	DR.UpdateVigorTheme();
	DR.modelSetup();
	DR.ToggleDecor();
	DR.UpdateChargeBars();
	DR.UpdateChargePositions();
	
	if DR.UpdateGroundSkimmingColor then
		DR.UpdateGroundSkimmingColor();
	end
	
	if DR.EvaluateGroundSkimmingVisibility then
		DR.EvaluateGroundSkimmingVisibility();
	end
	
	if DR.EvaluateVigorVisibility then
		DR.EvaluateVigorVisibility();
	end

	Print(string.format(L["ProfileLoaded"], profileName))
end

function DR.DeleteProfile(profileName)
	if DragonRider_DB.Profiles and DragonRider_DB.Profiles[profileName] then
		DragonRider_DB.Profiles[profileName] = nil;
		
		if DragonRider_DB.ActiveProfile == profileName then
			DragonRider_DB.ActiveProfile = nil;
		end

		if DragonRider_DB.AccountProfile == profileName then
			DragonRider_DB.AccountProfile = nil
		end
		
		Print(string.format(L["ProfileDeleted"], profileName))
	end
end

--import/export
function DR.GenerateExportString(profileName)
	InitializeProfileDB()
	local dataToExport = profileName and DragonRider_DB.Profiles[profileName] or DragonRider_DB;
	local safeExport = {};
	
	for key, value in pairs(dataToExport) do
		if DR.ExportWhitelist[key] then
			safeExport[key] = value;
		end
	end

	if safeExport.position then
		local cleanPosition = CopyTable(safeExport.position);
		cleanPosition.secondWind = nil;
		cleanPosition.surge = nil;
		cleanPosition.aerialHalt = nil;
		safeExport.position = cleanPosition;
	end

	local exportData = {
		addon = "DragonRider",
		version = 1,
		settings = safeExport,
	};
	
	local options = { ignoreSerializationErrors = true };
	return C_EncodingUtil.SerializeJSON(exportData, options);
end

function DR.ImportSettings(importString, profileName)
	local success, importData = pcall(C_EncodingUtil.DeserializeJSON, importString);
	
	if not success or type(importData) ~= "table" then
		return false;
	end

	if importData.addon ~= "DragonRider" then
		Print(L["ImportStringDifferentAddon"]);
		return false;
	end

	if importData.settings then
		local cleanedSettings = {};
		local skippedKeys = {};
		local hasSkippedOptions = false;

		for key, value in pairs(importData.settings) do
			if DR.ExportWhitelist[key] then
				if key == "position" and type(value) == "table" then
					cleanedSettings[key] = CopyTable(value);
					cleanedSettings[key].secondWind = nil;
					cleanedSettings[key].surge = nil;
					cleanedSettings[key].aerialHalt = nil;
				else
					cleanedSettings[key] = value;
				end
			else
				table.insert(skippedKeys, key);
				hasSkippedOptions = true;
			end
		end

		if hasSkippedOptions then
			Print(string.format(L["ImportStringOutdatedUnrecognized"], table.concat(skippedKeys, ", ")));
		end

		if profileName and profileName ~= "" then
			InitializeProfileDB();
			DragonRider_DB.Profiles[profileName] = cleanedSettings;
			Print(string.format(L["ProfileImportedAs"], profileName));
		else
			for key, value in pairs(cleanedSettings) do
				if type(value) == "table" and type(DragonRider_DB[key]) == "table" then
					DeepCopyInPlace(DragonRider_DB[key], value);
				else
					DragonRider_DB[key] = value;
				end
			end
			Print(L["ActiveSettingsOverwritten"]);
			
			if DragonRider_DB.ActiveProfile then
				DR.LoadProfile(DragonRider_DB.ActiveProfile);
			else
				DR.LoadProfile(nil);
			end
		end
	end
	return true;
end

local function GenerateDRDialog(name, width, height)
	local dialog = CreateFrame("Frame", name, UIParent);
	dialog:SetToplevel(true);
	table.insert(UISpecialFrames, name);
	dialog:SetPoint("CENTER", 0, 0);
	dialog:EnableMouse(true);
	dialog:SetFrameStrata("DIALOG");
	dialog:SetSize(width, height);
	dialog:Hide();

	dialog.NineSlice = CreateFrame("Frame", nil, dialog, "NineSlicePanelTemplate");
	NineSliceUtil.ApplyLayoutByName(dialog.NineSlice, "Dialog", dialog.NineSlice:GetFrameLayoutTextureKit());

	local bg = dialog:CreateTexture(nil, "BACKGROUND", nil, -1);
	bg:SetColorTexture(0, 0, 0, 0.8);
	bg:SetPoint("TOPLEFT", 11, -11);
	bg:SetPoint("BOTTOMRIGHT", -11, 11);

	dialog.text = dialog:CreateFontString(nil, nil, "GameFontHighlight");
	dialog.text:SetPoint("TOP", 0, -20);
	
	return dialog;
end


function DR.ShowExportDialog(exportString)
	if not DR.ExportFrame then
		DR.ExportFrame = GenerateDRDialog("DragonRiderExportDialog", 400, 130);
		
		local editBox = CreateFrame("EditBox", nil, DR.ExportFrame, "InputBoxTemplate");
		editBox:SetAutoFocus(true);
		editBox:SetSize(300, 30);
		editBox:SetPoint("CENTER", 0, -10);
		DR.ExportFrame.editBox = editBox;

		editBox:SetScript("OnEditFocusGained", function(self)
			self:HighlightText();
		end);
		editBox:SetScript("OnMouseUp", function(self)
			self:HighlightText();
		end);

		editBox:SetScript("OnKeyDown", function(self, key)
			if IsControlKeyDown() and (key == "C" or key == "X") then
				PlaySound(SOUNDKIT.TUTORIAL_POPUP);
				C_Timer.After(0.1, function()
					self:ClearFocus();
				end);
			end
		end);

		editBox:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				self:SetText(self.contentString or "");
				self:HighlightText();
			else
				self.contentString = self:GetText();
			end
		end);

		local closeBtn = CreateFrame("Button", nil, DR.ExportFrame, "UIPanelButtonTemplate");
		closeBtn:SetSize(100, 25);
		closeBtn:SetText(DONE);
		closeBtn:SetPoint("BOTTOM", 0, 15);
		closeBtn:SetScript("OnClick", function() DR.ExportFrame:Hide() end);
	end

	DR.ExportFrame:SetFrameStrata("FULLSCREEN_DIALOG");

	DR.ExportFrame.text:SetText(L["CopyProfileCode"]);
	DR.ExportFrame:Show();
	
	DR.ExportFrame.editBox.contentString = exportString;
	DR.ExportFrame.editBox:SetText(exportString);
	DR.ExportFrame.editBox:HighlightText();
	DR.ExportFrame.editBox:SetFocus();
end


function DR.ShowImportDialog()
	if not DR.ImportFrame then
		DR.ImportFrame = GenerateDRDialog("DragonRiderImportDialog", 400, 310);
		
		DR.ImportFrame.text:SetText(L["PasteProfileCode"]);
		
		local scrollFrame = CreateFrame("ScrollFrame", "DragonRiderImportScrollFrame", DR.ImportFrame, BackdropTemplateMixin and "BackdropTemplate" or nil);
		scrollFrame:SetSize(340, 90);
		scrollFrame:SetPoint("TOP", 0, -40);
		scrollFrame:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		});
		scrollFrame:SetBackdropColor(0, 0, 0, 0.8);
		scrollFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

		local scrollBar = CreateFrame("EventFrame", nil, scrollFrame, "MinimalScrollBar");
		scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 8, -2);
		scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 8, 2);
		ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, scrollBar);

		local editBox = CreateFrame("EditBox", nil, scrollFrame);
		editBox:SetMultiLine(true);
		editBox:SetAutoFocus(true);
		editBox:SetFontObject("ChatFontNormal");
		editBox:SetWidth(330);
		scrollFrame:SetScrollChild(editBox);
		DR.ImportFrame.editBox = editBox;

		editBox:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged);
		editBox:SetScript("OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, scrollFrame);
		end)
		editBox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus();
		end);

		local errorSubtext = DR.ImportFrame:CreateFontString(nil, "OVERLAY", "GameFontRedSmall");
		errorSubtext:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 5, -5);
		errorSubtext:SetText(L["InvalidImportCode"]);
		errorSubtext:Hide();
		DR.ImportFrame.errorSubtext = errorSubtext;

		local nameBox = CreateFrame("EditBox", nil, DR.ImportFrame, "InputBoxTemplate");
		nameBox:SetAutoFocus(false);
		nameBox:SetSize(200, 30);
		nameBox:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 5, -45);
		
		local nameLabel = DR.ImportFrame:CreateFontString(nil, nil, "GameFontNormal");
		nameLabel:SetPoint("BOTTOMLEFT", nameBox, "TOPLEFT", 0, 2);
		nameLabel:SetText(L["NewProfileName"]);

		local currentProfileText = DR.ImportFrame:CreateFontString(nil, nil, "GameFontHighlight");
		currentProfileText:SetPoint("LEFT", nameBox, "LEFT", 0, 0);
		currentProfileText:Hide();

		local saveToCurrentCB = CreateFrame("CheckButton", nil, DR.ImportFrame, "UICheckButtonTemplate");
		saveToCurrentCB:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -5, -5);
		saveToCurrentCB.Text:SetText(L["SavetoCurrentProfile"]);

		local importBtn = CreateFrame("Button", nil, DR.ImportFrame, "UIPanelButtonTemplate");
		importBtn:SetSize(100, 25);
		importBtn:SetText(L["Import"]);
		importBtn:SetPoint("BOTTOMRIGHT", DR.ImportFrame, "BOTTOM", -5, 15);
		
		local function ValidateImportState()
			local importStr = editBox:GetText();
			local isCodeValid = false;
			
			if importStr and importStr ~= "" then
				importStr = importStr:match("^%s*(.-)%s*$");
				
				local hasBrackets = importStr:sub(1, 1) == "{" and importStr:sub(-1) == "}";
				local _, addonCount = importStr:gsub('"addon"%s*:%s*"DragonRider"', "");
				
				if hasBrackets and addonCount == 1 then
					local success, data = pcall(C_EncodingUtil.DeserializeJSON, importStr);
					
					if success and type(data) == "table" and data.addon == "DragonRider" and type(data.settings) == "table" then
						isCodeValid = true;
					end
				end
			end

			if importStr == "" then
				editBox:SetTextColor(1, 1, 1);
				errorSubtext:Hide();
			elseif isCodeValid then
				editBox:SetTextColor(0.1, 1, 0.1);
				errorSubtext:Hide();
			else
				editBox:SetTextColor(1, 0.1, 0.1);
				errorSubtext:Show();
			end

			local saveToCurrent = saveToCurrentCB:GetChecked();
			local hasValidName = false;

			if saveToCurrent then
				nameBox:Hide();
				currentProfileText:Show();
				currentProfileText:SetText(DragonRider_DB.ActiveProfile or L["NoneWillCreateDefault"]);
				hasValidName = true;
			else
				nameBox:Show();
				currentProfileText:Hide();
				local typedName = nameBox:GetText();
				if typedName and typedName:match("%S") then
					hasValidName = true;
				end
			end

			if isCodeValid and hasValidName then
				importBtn:Enable();
			else
				importBtn:Disable();
			end
		end

		editBox:SetScript("OnTextChanged", function(self, userInput)
			ScrollingEdit_OnTextChanged(self, scrollFrame);
			ValidateImportState();
		end)
		
		nameBox:SetScript("OnTextChanged", ValidateImportState);
		saveToCurrentCB:SetScript("OnClick", ValidateImportState);

		importBtn:SetScript("OnClick", function()
			local str = editBox:GetText();
			local saveToCurrent = saveToCurrentCB:GetChecked();
			local profileName = nameBox:GetText();
			
			if saveToCurrent and DragonRider_DB.ActiveProfile then
				profileName = DragonRider_DB.ActiveProfile;
			elseif saveToCurrent and not DragonRider_DB.ActiveProfile then
				Print(L["NoActiveProfileSelected"]);
				profileName = nil;
			end

			local success = DR.ImportSettings(str, profileName);
			if success then
				if profileName and profileName ~= "" then
					DR.LoadProfile(profileName);
				else
					DR.LoadProfile(DragonRider_DB.ActiveProfile or nil);
				end
				
				if DR.UpdateProfileDropdownMenu then
					DR.UpdateProfileDropdownMenu();
				end
				if DR.UpdateSpecDropdownMenu then
					DR.UpdateSpecDropdownMenu();
				end
				
				DR.ImportFrame:Hide();
			end
		end);

		local cancelBtn = CreateFrame("Button", nil, DR.ImportFrame, "UIPanelButtonTemplate");
		cancelBtn:SetSize(100, 25);
		cancelBtn:SetText("Cancel");
		cancelBtn:SetPoint("BOTTOMLEFT", DR.ImportFrame, "BOTTOM", 5, 15);
		cancelBtn:SetScript("OnClick", function()
			DR.ImportFrame:Hide();
		end)
		
		DR.ImportFrame.nameBox = nameBox;
		DR.ImportFrame.saveToCurrentCB = saveToCurrentCB;
		DR.ImportFrame.ValidateImportState = ValidateImportState;
		
		DR.ImportFrame:SetScript("OnShow", function(self)
			self.editBox:SetText("");
			self.nameBox:SetText("");
			self.saveToCurrentCB:SetChecked(false);
			self.ValidateImportState();
			self.editBox:SetFocus();
		end);
	end

	DR.ImportFrame:Show();
end

StaticPopupDialogs["DRAGONRIDER_CONFIRM_DELETE_PROFILE"] = {
	text = L["Dialog_DeleteProfile"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, profileName)
		DR.DeleteProfile(profileName);
		if DR.ProfileManagerFrame and DR.ProfileManagerFrame:IsShown() then
			DR.ProfileManagerFrame.UpdateDropdownMenu();
			DR.ProfileManagerFrame.UpdateSpecDropdownMenu();
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
};

StaticPopupDialogs["DRAGONRIDER_RENAME_PROFILE"] = {
	text = L["Dialog_RenameProfile"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	OnShow = function(self, profileName)
		local editBox = self:GetEditBox();
		editBox:SetText(profileName);
		editBox:HighlightText();
	end,
	OnAccept = function(self, oldName)
		local newName = self:GetEditBox():GetText();
		if newName and newName ~= "" and newName ~= oldName then
			DragonRider_DB.Profiles[newName] = CopyTable(DragonRider_DB.Profiles[oldName]);
			
			if DragonRider_DB.AccountProfile == oldName then
				DragonRider_DB.AccountProfile = newName;
			end
			if DragonRider_DB.ActiveProfile == oldName then
				DragonRider_DB.ActiveProfile = newName;
			end

			if DragonRider_DB.CharSpecLinks then
				for playerKey, specs in pairs(DragonRider_DB.CharSpecLinks) do
					for specIdx, linkedName in pairs(specs) do
						if linkedName == oldName then
							DragonRider_DB.CharSpecLinks[playerKey][specIdx] = newName;
						end
					end
				end
			end

			DragonRider_DB.Profiles[oldName] = nil;
			Print(string.format(L["ProfileRenamed"], oldName, newName));
			
			if DR.ProfileManagerFrame and DR.ProfileManagerFrame:IsShown() then
				DR.ProfileManagerFrame.UpdateDropdownMenu();
				DR.ProfileManagerFrame.UpdateSpecDropdownMenu();
			end
		end
	end,

	EditBoxOnEnterPressed = function(self)
		local dialog = self:GetParent();
		if dialog:GetButton1():IsEnabled() then
			StaticPopup_OnClick(dialog, 1);
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
};

--diff settings canvas instead of the searchable ones
--it wasn't really great as searchable, ended up confusing, and just easier
function DR.InitializeProfileSettingsCanvas()
	local canvas = CreateFrame("Frame", "DragonRiderProfileCanvas", UIParent);
	canvas:Hide();

	local title = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge");
	title:SetPoint("TOPLEFT", 15, -15);
	title:SetText(L["ProfileManager"]);

	local profileLabel = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	profileLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -25);
	profileLabel:SetText(L["SelectActiveProfile"]);

	local profileDropdown = CreateFrame("DropdownButton", nil, canvas, "WowStyle1DropdownTemplate");
	profileDropdown:SetPoint("TOPLEFT", profileLabel, "BOTTOMLEFT", 0, -10);
	profileDropdown:SetWidth(200);

	local UpdateSpecDropdownMenu;
	
	local function UpdateDropdownMenu()
		local accountProfile = DragonRider_DB.AccountProfile or DragonRider_DB.ActiveProfile or DEFAULT;

		profileDropdown:SetDefaultText(accountProfile);
		
		profileDropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:CreateTitle(L["AccountProfile"]);
			
			InitializeProfileDB();

			local function IsSelected(pName)
				local current = DragonRider_DB.AccountProfile or DragonRider_DB.ActiveProfile or DEFAULT;
				return current == pName;
			end
			
			local function SetSelected(pName)
				DR.LoadProfile(pName);
				DragonRider_DB.AccountProfile = pName;
				profileDropdown:GenerateMenu(); 
				if DR.UpdateSpecDropdownMenu then
					DR.UpdateSpecDropdownMenu();
				end
			end

			for pName, _ in pairs(DragonRider_DB.Profiles) do
				local profileBtn = rootDescription:CreateRadio(pName, IsSelected, SetSelected, pName);

				profileBtn:AddInitializer(function(button, description, menu)
					local cancelButton = MenuTemplates.AttachAutoHideCancelButton(button);
					cancelButton:SetPoint("RIGHT", button, "RIGHT", -5, 0);
					
					cancelButton:SetScript("OnClick", function()
						menu:Close();
						StaticPopup_Show("DRAGONRIDER_CONFIRM_DELETE_PROFILE", pName, nil, pName);
					end);
					
					MenuUtil.HookTooltipScripts(cancelButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, L["DeleteProfile"]);
					end);

					local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
					gearButton:SetPoint("RIGHT", cancelButton, "LEFT", -3, 0); 
					
					gearButton:SetScript("OnClick", function()
						menu:Close();
						StaticPopup_Show("DRAGONRIDER_RENAME_PROFILE", pName, nil, pName);
					end);
					
					MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, L["RenameProfile"]);
					end);
				end);
			end
		end)
	end
	DR.UpdateProfileDropdownMenu = UpdateDropdownMenu;

	local specLabel = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	specLabel:SetPoint("TOPLEFT", profileDropdown, "BOTTOMLEFT", 0, -30);
	specLabel:SetText(L["ProfileCurrentSpec"]);

	local specDropdown = CreateFrame("DropdownButton", nil, canvas, "WowStyle1DropdownTemplate");
	specDropdown:SetPoint("TOPLEFT", specLabel, "BOTTOMLEFT", 0, -10);
	specDropdown:SetWidth(200);

	UpdateSpecDropdownMenu = function()
		local name, realm = UnitFullName("player");
		local playerKey = name .. "-" .. (realm or "");
		local specIndex = GetSpecialization() or 0;
		
		local linkedProfile = NONE;
		if DragonRider_DB.CharSpecLinks and DragonRider_DB.CharSpecLinks[playerKey] and DragonRider_DB.CharSpecLinks[playerKey][specIndex] then
			linkedProfile = DragonRider_DB.CharSpecLinks[playerKey][specIndex];
			if not DragonRider_DB.Profiles[linkedProfile] then
				linkedProfile = NONE;
				DragonRider_DB.CharSpecLinks[playerKey][specIndex] = nil;
			end
		end

		specDropdown:SetDefaultText(linkedProfile);

		if linkedProfile ~= NONE then
			profileDropdown:SetEnabled(false);
		else
			profileDropdown:SetEnabled(true);
		end

		specDropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:CreateTitle(L["LinkToSpec"]);

			local function IsSelected(pName)
				return linkedProfile == pName;
			end
			
			local function SetSelected(pName)
				if DR.SetProfileForSpec then DR.SetProfileForSpec(pName) end
				UpdateSpecDropdownMenu();
			end

			rootDescription:CreateRadio(NONE, IsSelected, SetSelected, NONE);
			InitializeProfileDB();
			
			for pName, _ in pairs(DragonRider_DB.Profiles) do
				rootDescription:CreateRadio(pName, IsSelected, SetSelected, pName);
			end
		end);
	end
	DR.UpdateSpecDropdownMenu = UpdateSpecDropdownMenu;

	local saveLabel = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	saveLabel:SetPoint("TOPLEFT", specDropdown, "BOTTOMLEFT", 0, -30);
	saveLabel:SetText(L["SaveCurrentToNewProfile"]);

	local saveBox = CreateFrame("EditBox", nil, canvas, "InputBoxTemplate");
	saveBox:SetAutoFocus(false);
	saveBox:SetSize(150, 30);
	saveBox:SetPoint("TOPLEFT", saveLabel, "BOTTOMLEFT", 5, -10);
	
	local saveBtn = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate");
	saveBtn:SetSize(100, 25);
	saveBtn:SetText(L["SaveAsNew"]);
	saveBtn:SetPoint("LEFT", saveBox, "RIGHT", 10, 0);
	
	local function TriggerSaveAsNew()
		local text = saveBox:GetText();
		if text and text ~= "" then
			DR.SaveProfile(text);
			DragonRider_DB.AccountProfile = text;
			saveBox:SetText("");
			saveBox:ClearFocus();
			DR.UpdateProfileDropdownMenu();
			DR.UpdateSpecDropdownMenu();
		end
	end
	saveBtn:SetScript("OnClick", TriggerSaveAsNew);
	saveBox:SetScript("OnEnterPressed", TriggerSaveAsNew);
	saveBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus();
	end);

	local exportBtn = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate");
	exportBtn:SetSize(100, 25);
	exportBtn:SetText(L["Export"]);
	exportBtn:SetPoint("TOPLEFT", saveBox, "BOTTOMLEFT", -5, -30);
	exportBtn:SetScript("OnClick", function()
		local str = DR.GenerateExportString(DragonRider_DB.ActiveProfile);
		DR.ShowExportDialog(str);
	end);

	local importBtn = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate");
	importBtn:SetSize(100, 25);
	importBtn:SetText(L["Import"]);
	importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 10, 0);
	importBtn:SetScript("OnClick", function()
		DR.ShowImportDialog();
	end);

	DR.UpdateProfileDropdownMenu();
	DR.UpdateSpecDropdownMenu();

	if DR.SettingsCategory then
		local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(DR.SettingsCategory, canvas, L["Profiles"]);
		
		layout:AddAnchorPoint("TOPLEFT", 10, -10);
		layout:AddAnchorPoint("BOTTOMRIGHT", -10, 10);
	else
		Print(L["SettingsCatMissing"]);
	end
end

local function GetPlayerKey()
	local name, realm = UnitFullName("player");
	return name .. "-" .. (realm or "");
end

function DR.SetProfileForSpec(profileName)
	InitializeProfileDB();
	local playerKey = GetPlayerKey();
	local specIndex = GetSpecialization() or 0;

	if not DragonRider_DB.CharSpecLinks[playerKey] then
		DragonRider_DB.CharSpecLinks[playerKey] = {};
	end

	if profileName == NONE or not profileName then
		DragonRider_DB.CharSpecLinks[playerKey][specIndex] = nil;
		--Print(string.format("[PH] Spec %s is now using the account-wide loadout.",specIndex));
		
		local fallback = DragonRider_DB.AccountProfile;
		if fallback and DragonRider_DB.Profiles[fallback] and DragonRider_DB.ActiveProfile ~= fallback then
			DR.LoadProfile(fallback);
			if DR.UpdateProfileDropdownMenu then
				DR.UpdateProfileDropdownMenu();
			end
		end
	else
		DragonRider_DB.CharSpecLinks[playerKey][specIndex] = profileName;
		Print(string.format(L["ProfileLinkedToSpec"], profileName, specIndex));
		
		if DragonRider_DB.ActiveProfile ~= profileName then
			DR.LoadProfile(profileName);
			if DR.UpdateProfileDropdownMenu then
				DR.UpdateProfileDropdownMenu();
			end
		end
	end
end

function DR.CheckForLinkedProfile()
	InitializeProfileDB();
	local playerKey = GetPlayerKey();
	local specIndex = GetSpecialization() or 0;

	local targetProfile = nil;

	if DragonRider_DB.CharSpecLinks and DragonRider_DB.CharSpecLinks[playerKey] then
		targetProfile = DragonRider_DB.CharSpecLinks[playerKey][specIndex];
	end

	if not targetProfile then --it's as shrimple as that
		targetProfile = DragonRider_DB.AccountProfile;
	end

	if targetProfile and DragonRider_DB.Profiles[targetProfile] then
		if DragonRider_DB.ActiveProfile ~= targetProfile then
			DR.LoadProfile(targetProfile);
			
			if DR.UpdateProfileDropdownMenu then
				DR.UpdateProfileDropdownMenu();
			end
			if DR.UpdateSpecDropdownMenu then
				DR.UpdateSpecDropdownMenu();
			end
		end
	end
end

local initFrame = CreateFrame("Frame");
initFrame:RegisterEvent("ADDON_LOADED");
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
initFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");

initFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "DragonRider" then
		InitializeProfileDB();
		self:UnregisterEvent("ADDON_LOADED");
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		if DR.CheckForLinkedProfile then
			DR.CheckForLinkedProfile();
		end
		
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		if arg1 == "player" then
			if DR.CheckForLinkedProfile then
				DR.CheckForLinkedProfile();
			end
		end
	end
end);
