local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:_GetPreviewSample(fontInfo)
	local family = fontInfo and (fontInfo.family or fontInfo.displayName or fontInfo.name) or "RGX Font"
	return string.format(
		"%s\n\n%s\n\n0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz",
		family,
		self.previewSample
	)
end

function Fonts:_ApplyPreviewSelection(frame, fontName)
	if not frame or not frame.fontButtons then
		return
	end

	fontName = self:ResolveName(fontName, self:GetDefault()) or self:GetDefault()
	local entry = self.registry[fontName]
	if not entry then
		return
	end

	frame.selectedFont = fontName

	local size = math.floor(frame.sizeSlider:GetValue() + 0.5)
	local flags = self:NormalizeFlags(frame.flagsValue)
	local previewPath = self:GetPath(fontName)

	frame.previewTitle:SetFont(previewPath, size + 10, flags)
	frame.previewTitle:SetText(entry.family or entry.name or fontName)

	frame.previewMeta:SetFont(previewPath, math.max(11, size - 1), flags)
	frame.previewMeta:SetText(string.format(
		"%s\nCategory: %s\nStyle: %s\nFile: %s",
		fontName,
		entry.category or "Unknown",
		self:DescribeFlags(flags),
		entry.path or "Unknown"
	))

	frame.previewBody:SetFont(previewPath, size, flags)
	frame.previewBody:SetText(self:_GetPreviewSample(entry))

	frame.currentFontLabel:SetText(fontName)
	frame.currentSizeLabel:SetText(string.format("%d pt", size))
	frame.currentStyleLabel:SetText(self:DescribeFlags(flags))

	for _, button in ipairs(frame.fontButtons) do
		local selected = button.fontName == fontName
		button:SetNormalFontObject(selected and "GameFontHighlight" or "GameFontNormal")
		if button.bg then
			button.bg:SetColorTexture(
				selected and 0.18 or 0.08,
				selected and 0.34 or 0.08,
				selected and 0.52 or 0.08,
				selected and 0.95 or 0.75
			)
		end
	end
end

function Fonts:_CreatePreviewFontButton(parent, fontInfo, index, onClick)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(180, 22)
	button:SetPoint("TOPLEFT", 0, -((index - 1) * 24))
	button.fontName = fontInfo.name

	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetAllPoints()
	button.bg:SetColorTexture(0.08, 0.08, 0.08, 0.75)

	button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.text:SetPoint("LEFT", 8, 0)
	button.text:SetPoint("RIGHT", -8, 0)
	button.text:SetJustifyH("LEFT")
	button.text:SetText(fontInfo.name)
	self:Apply(button.text, fontInfo.name, 12, "")

	button:SetScript("OnClick", function()
		onClick(fontInfo.name)
	end)

	return button
end

function Fonts:_BuildPreviewButtons(frame)
	if not frame or not frame.fontListContent then
		return
	end

	if frame.fontButtons then
		for _, button in ipairs(frame.fontButtons) do
			button:Hide()
		end
	end

	frame.fontButtons = {}

	local search = ""
	if frame.searchBox and type(frame.searchBox.GetText) == "function" then
		search = string.lower(strtrim(frame.searchBox:GetText() or ""))
	end

	local fonts = self:ListAvailable()
	local visible = {}
	for _, fontInfo in ipairs(fonts) do
		local haystack = string.lower(string.format("%s %s %s",
			fontInfo.name or "",
			fontInfo.family or "",
			fontInfo.category or ""
		))
		if search == "" or string.find(haystack, search, 1, true) then
			table.insert(visible, fontInfo)
		end
	end

	for index, fontInfo in ipairs(visible) do
		local button = self:_CreatePreviewFontButton(frame.fontListContent, fontInfo, index, function(fontName)
			self:_ApplyPreviewSelection(frame, fontName)
		end)
		frame.fontButtons[index] = button
	end

	local contentHeight = math.max(1, #visible * 24)
	frame.fontListContent:SetHeight(contentHeight)
	frame.noResults:Hide()

	if #visible == 0 then
		frame.noResults:Show()
		contentHeight = 24
		frame.fontListContent:SetHeight(contentHeight)
	end

	if not frame.selectedFont or not self:Exists(frame.selectedFont) then
		frame.selectedFont = self:GetDefault()
	end

	local stillVisible = false
	for _, fontInfo in ipairs(visible) do
		if fontInfo.name == frame.selectedFont then
			stillVisible = true
			break
		end
	end

	if stillVisible then
		self:_ApplyPreviewSelection(frame, frame.selectedFont)
	elseif visible[1] then
		self:_ApplyPreviewSelection(frame, visible[1].name)
	end
end

function Fonts:CreateTestFrame()
	if self.testFrame then
		return self.testFrame
	end

	local frame = CreateFrame("Frame", "RGXFontTestFrame", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(860, 560)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()

	frame.TitleText:SetText("RGX Font Test")

	frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.subtitle:SetPoint("TOPLEFT", 16, -34)
	frame.subtitle:SetText("Preview RGX fonts and reuse the same selector pattern in your addon options.")

	frame.searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.searchLabel:SetPoint("TOPLEFT", 16, -58)
	frame.searchLabel:SetText("Search")

	frame.searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	frame.searchBox:SetSize(190, 24)
	frame.searchBox:SetPoint("TOPLEFT", frame.searchLabel, "BOTTOMLEFT", 0, -4)
	frame.searchBox:SetAutoFocus(false)
	frame.searchBox:SetScript("OnTextChanged", function()
		self:_BuildPreviewButtons(frame)
	end)

	frame.fontListLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.fontListLabel:SetPoint("TOPLEFT", frame.searchBox, "BOTTOMLEFT", 0, -10)
	frame.fontListLabel:SetText("Available Fonts")

	frame.fontListScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	frame.fontListScroll:SetPoint("TOPLEFT", frame.fontListLabel, "BOTTOMLEFT", 0, -6)
	frame.fontListScroll:SetSize(210, 360)

	frame.fontListContent = CreateFrame("Frame", nil, frame.fontListScroll)
	frame.fontListContent:SetSize(186, 1)
	frame.fontListScroll:SetScrollChild(frame.fontListContent)

	frame.noResults = frame.fontListContent:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	frame.noResults:SetPoint("TOPLEFT", 0, 0)
	frame.noResults:SetText("No fonts matched your search.")
	frame.noResults:Hide()

	frame.previewPane = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	frame.previewPane:SetPoint("TOPLEFT", 252, -58)
	frame.previewPane:SetPoint("BOTTOMRIGHT", -16, 60)
	frame.previewPane:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	frame.previewPane:SetBackdropColor(0.05, 0.06, 0.08, 0.96)
	frame.previewPane:SetBackdropBorderColor(0.25, 0.28, 0.34, 1)

	frame.previewTitle = frame.previewPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	frame.previewTitle:SetPoint("TOPLEFT", 16, -18)
	frame.previewTitle:SetPoint("RIGHT", -16, 0)
	frame.previewTitle:SetJustifyH("LEFT")

	frame.previewMeta = frame.previewPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.previewMeta:SetPoint("TOPLEFT", frame.previewTitle, "BOTTOMLEFT", 0, -10)
	frame.previewMeta:SetPoint("RIGHT", -16, 0)
	frame.previewMeta:SetJustifyH("LEFT")
	frame.previewMeta:SetTextColor(0.72, 0.78, 0.86)

	frame.previewBody = frame.previewPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.previewBody:SetPoint("TOPLEFT", frame.previewMeta, "BOTTOMLEFT", 0, -16)
	frame.previewBody:SetPoint("BOTTOMRIGHT", -16, 16)
	frame.previewBody:SetJustifyH("LEFT")
	frame.previewBody:SetJustifyV("TOP")
	frame.previewBody:SetSpacing(6)

	frame.currentFontTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.currentFontTag:SetPoint("BOTTOMLEFT", 16, 36)
	frame.currentFontTag:SetText("Selected")

	frame.currentFontLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.currentFontLabel:SetPoint("LEFT", frame.currentFontTag, "RIGHT", 8, 0)

	frame.currentSizeTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.currentSizeTag:SetPoint("BOTTOMLEFT", 16, 14)
	frame.currentSizeTag:SetText("Preview Size")

	frame.currentSizeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.currentSizeLabel:SetPoint("LEFT", frame.currentSizeTag, "RIGHT", 8, 0)

	frame.currentStyleTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.currentStyleTag:SetPoint("LEFT", frame.currentSizeLabel, "RIGHT", 22, 0)
	frame.currentStyleTag:SetText("Style")

	frame.currentStyleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.currentStyleLabel:SetPoint("LEFT", frame.currentStyleTag, "RIGHT", 8, 0)

	self._widgetId = self._widgetId + 1
	local previewSliderName = "RGXFontPreviewSlider" .. self._widgetId
	frame.sizeSlider = CreateFrame("Slider", previewSliderName, frame, "OptionsSliderTemplate")
	frame.sizeSlider:SetPoint("BOTTOMRIGHT", -180, 16)
	frame.sizeSlider:SetMinMaxValues(10, 28)
	frame.sizeSlider:SetValueStep(1)
	frame.sizeSlider:SetObeyStepOnDrag(true)
	frame.sizeSlider:SetValue(16)
	_G[frame.sizeSlider:GetName() .. "Low"]:SetText("10")
	_G[frame.sizeSlider:GetName() .. "High"]:SetText("28")
	_G[frame.sizeSlider:GetName() .. "Text"]:SetText("Size")
	frame.sizeSlider:SetScript("OnValueChanged", function()
		self:_ApplyPreviewSelection(frame, frame.selectedFont or self:GetDefault())
	end)

	frame.flagsValue = ""
	frame.flagsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.flagsLabel:SetPoint("LEFT", frame.sizeSlider, "RIGHT", 18, 10)
	frame.flagsLabel:SetText("Style")

	frame.flagsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.flagsButton:SetSize(150, 24)
	frame.flagsButton:SetPoint("TOPLEFT", frame.flagsLabel, "BOTTOMLEFT", 0, -2)
	frame.flagsButton:SetText("")

	frame.flagsButtonText = frame.flagsButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.flagsButtonText:SetPoint("LEFT", 8, 0)
	frame.flagsButtonText:SetPoint("RIGHT", -18, 0)
	frame.flagsButtonText:SetJustifyH("LEFT")
	frame.flagsButtonText:SetText(self:DescribeFlags(frame.flagsValue))

	frame.flagsArrow = frame.flagsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.flagsArrow:SetPoint("RIGHT", -8, 0)
	frame.flagsArrow:SetText("v")

	frame.flagsMenu = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	frame.flagsMenu:SetPoint("TOPLEFT", frame.flagsButton, "BOTTOMLEFT", 0, -2)
	frame.flagsMenu:SetSize(180, 150)
	frame.flagsMenu:SetFrameStrata("DIALOG")
	frame.flagsMenu:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8X8",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	frame.flagsMenu:SetBackdropColor(0.05, 0.06, 0.08, 0.96)
	frame.flagsMenu:SetBackdropBorderColor(0.32, 0.36, 0.42, 1)
	frame.flagsMenu:Hide()

	frame.flagButtons = {}
	for index, preset in ipairs(self:GetFlagPresets()) do
		local button = CreateFrame("Button", nil, frame.flagsMenu, "UIPanelButtonTemplate")
		button:SetSize(156, 22)
		button:SetPoint("TOPLEFT", 12, -10 - ((index - 1) * 24))
		button:SetText("")
		button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		button.text:SetPoint("LEFT", 8, 0)
		button.text:SetPoint("RIGHT", -8, 0)
		button.text:SetJustifyH("LEFT")
		button.text:SetText(preset.label)
		button.value = preset.value
		button:SetScript("OnClick", function()
			frame.flagsValue = preset.value
			frame.flagsButtonText:SetText(preset.label)
			frame.flagsMenu:Hide()
			self:_ApplyPreviewSelection(frame, frame.selectedFont or self:GetDefault())
		end)
		frame.flagButtons[#frame.flagButtons + 1] = button
	end

	frame.flagsButton:SetScript("OnClick", function()
		frame.flagsMenu:SetShown(not frame.flagsMenu:IsShown())
	end)

	frame.demoSelector = self:CreateFontDropdown(frame, {
		label = "Reusable Selector Demo",
		value = self:GetDefault(),
		width = 220,
		buttonWidth = 180,
		menuWidth = 230,
		menuHeight = 220,
		onChange = function(fontName)
			self:_ApplyPreviewSelection(frame, fontName)
		end,
	})
	frame.demoSelector:SetPoint("BOTTOMLEFT", 252, 10)

	frame.demoStyleSelector = self:CreateStyleSelector(frame, {
		label = "Full Style Selector Demo",
		value = {
			font = self:GetDefault(),
			size = 14,
			flags = "",
		},
		previewText = "Shared selector for addon settings.",
		width = 290,
		dropdownWidth = 220,
		sliderWidth = 140,
		onChange = function(style)
			frame.flagsValue = style.flags or ""
			frame.flagsButtonText:SetText(self:DescribeFlags(style.flags))
			frame.sizeSlider:SetValue(style.size or 16)
			self:_ApplyPreviewSelection(frame, style.font or self:GetDefault())
		end,
	})
	frame.demoStyleSelector:SetPoint("LEFT", frame.demoSelector, "RIGHT", 26, 0)

	self.testFrame = frame
	self:_BuildPreviewButtons(frame)
	self:_ApplyPreviewSelection(frame, self:GetDefault())

	return frame
end

function Fonts:ToggleTestFrame()
	local frame = self:CreateTestFrame()
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
		frame:SetFrameStrata("DIALOG")
		frame:Raise()
		self:_BuildPreviewButtons(frame)
		self:_ApplyPreviewSelection(frame, frame.selectedFont or self:GetDefault())
	end
	return frame
end
