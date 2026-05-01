local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework
local Dropdowns -- resolved lazily

function Fonts:CreateStyleSelector(parent, opts)
	opts = opts or {}
	parent = parent or UIParent

	local selector = CreateFrame("Frame", nil, parent)
	selector:SetSize(opts.width or 250, opts.height or 130)

	selector.value = self:NormalizeStyle(opts.value or {
		font = self:GetDefault(),
		size = self.defaultSize,
		flags = self.defaultFlags,
	})

	selector.label = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	selector.label:SetPoint("TOPLEFT", 0, 0)
	selector.label:SetText(opts.label or "Font Style")

	selector.preview = selector:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	selector.preview:SetPoint("TOPLEFT", selector.label, "BOTTOMLEFT", 0, -6)
	selector.preview:SetPoint("RIGHT", 0, 0)
	selector.preview:SetJustifyH("LEFT")
	selector.preview:SetText(opts.previewText or "The quick brown fox jumps over the lazy dog.")

	selector.dropdown = self:CreateFontDropdown(selector, {
		label = opts.fontLabel or "Font",
		value = selector.value.font,
		width = opts.dropdownWidth or 220,
		buttonWidth = opts.buttonWidth or 180,
		menuWidth = opts.menuWidth or 230,
		menuHeight = opts.menuHeight or 220,
		onChange = function(fontName)
			selector.value.font = fontName
			selector:Refresh()
		end,
	})
	if selector.dropdown and type(selector.dropdown.SetPoint) == "function" then
		selector.dropdown:SetPoint("TOPLEFT", selector.preview, "BOTTOMLEFT", 0, -12)
	end

	self._widgetId = self._widgetId + 1
	local selectorSliderName = "RGXFontStyleSelectorSlider" .. self._widgetId
	selector.sizeSlider = CreateFrame("Slider", selectorSliderName, selector, "OptionsSliderTemplate")
	selector.sizeSlider:SetPoint("TOPLEFT", selector.dropdown, "BOTTOMLEFT", 8, -18)
	selector.sizeSlider:SetWidth(opts.sliderWidth or 150)
	selector.sizeSlider:SetMinMaxValues(opts.minSize or 8, opts.maxSize or 32)
	selector.sizeSlider:SetValueStep(1)
	selector.sizeSlider:SetObeyStepOnDrag(true)
	selector.sizeSlider:SetValue(selector.value.size)
	_G[selector.sizeSlider:GetName() .. "Low"]:SetText(tostring(opts.minSize or 8))
	_G[selector.sizeSlider:GetName() .. "High"]:SetText(tostring(opts.maxSize or 32))
	_G[selector.sizeSlider:GetName() .. "Text"]:SetText(opts.sizeLabel or "Size")

	Dropdowns = Dropdowns or RGX:GetDropdowns()
	selector.flagsDropdown = Dropdowns and Dropdowns:CreateNestedDropdown(selector, {
		label = opts.flagsLabel or "Style",
		width = opts.flagsDropdownWidth or 190,
		buttonWidth = opts.flagsButtonWidth or 150,
		value = selector.value.flags or "",
		items = function()
			local items = {}
			for _, preset in ipairs(Fonts:GetFlagPresets()) do
				items[#items + 1] = {
					text = preset.label,
					value = preset.value,
				}
			end
			return items
		end,
		getValueText = function(value)
			return Fonts:DescribeFlags(value or "")
		end,
		onChange = function(value)
			selector.value.flags = value or ""
			selector:Refresh()
		end,
	})

	if selector.flagsDropdown then
		selector.flagsDropdown:SetPoint("TOPLEFT", selector.sizeSlider, "BOTTOMLEFT", -8, -8)
	end

	function selector:GetValue()
		return RGX:CopyTable(self.value)
	end

	function selector:SetValue(style)
		self.value = Fonts:NormalizeStyle(style)
		self:Refresh()
	end

	function selector:Refresh()
		if self.dropdown then
			if type(self.dropdown.Refresh) == "function" then
				self.dropdown:Refresh(self.value.font)
			elseif self.dropdown.dropdown then
				Fonts:_SafeDropdownSetText(self.dropdown.dropdown, Fonts:GetDropdownFontLabel(self.value.font))
			elseif type(self.dropdown.GetName) == "function" then
				Fonts:_SafeDropdownSetText(self.dropdown, Fonts:GetDropdownFontLabel(self.value.font))
			end
		end
		if self.sizeSlider and type(self.sizeSlider.SetValue) == "function" then
			self.sizeSlider:SetValue(self.value.size)
		end
		if self.flagsDropdown and self.flagsDropdown.Refresh then
			self.flagsDropdown:Refresh(self.value.flags or "")
		end
		Fonts:ApplyStyle(self.preview, self.value)
		if type(opts.onChange) == "function" then
			opts.onChange(self:GetValue())
		end
	end

	selector.sizeSlider:SetScript("OnValueChanged", function(_, value)
		selector.value.size = math.floor(value + 0.5)
		Fonts:ApplyStyle(selector.preview, selector.value)
		if type(opts.onChange) == "function" then
			opts.onChange(selector:GetValue())
		end
	end)

	selector:Refresh()
	return selector
end

function Fonts:CreateSimpleStyleSelector(parent, opts)
	return self:CreateStyleSelector(parent, opts)
end

function Fonts:AttachStyleSelector(parent, db, key, opts)
	opts = opts or {}
	if type(db) ~= "table" or type(key) ~= "string" or key == "" then
		RGX:Debug("Fonts: AttachStyleSelector requires db table and key")
		return nil
	end

	local fallback = self:NormalizeStyle(opts.value or {
		font = self:GetDefault(),
		size = self.defaultSize,
		flags = self.defaultFlags,
	})

	local current = self:_EnsureBindingTable(db, key, fallback)
	current = self:NormalizeStyle(current)
	db[key] = current

	local selector = self:CreateSimpleStyleSelector(parent, {
		label = opts.label or "Text Style",
		value = current,
		width = opts.width,
		height = opts.height,
		dropdownWidth = opts.dropdownWidth,
		buttonWidth = opts.buttonWidth,
		menuWidth = opts.menuWidth,
		menuHeight = opts.menuHeight,
		sliderWidth = opts.sliderWidth,
		minSize = opts.minSize,
		maxSize = opts.maxSize,
		previewText = opts.previewText,
		fontLabel = opts.fontLabel,
		sizeLabel = opts.sizeLabel,
		flagsLabel = opts.flagsLabel,
		onChange = function(style)
			db[key] = Fonts:NormalizeStyle(style)
			if type(opts.onChange) == "function" then
				opts.onChange(db[key], db)
			end
		end,
	})

	selector.DB = db
	selector.DBKey = key

	function selector:RefreshFromDB()
		local value = Fonts:NormalizeStyle(self.DB[self.DBKey] or fallback)
		self.DB[self.DBKey] = value
		self:SetValue(value)
	end

	selector:RefreshFromDB()
	return selector
end

function Fonts:CreateStyleEditorFrame(opts)
	opts = opts or {}

	local db = opts.db
	local styles = opts.styles
	if type(db) ~= "table" or type(styles) ~= "table" then
		RGX:Debug("Fonts: CreateStyleEditorFrame requires db table and styles list")
		return nil
	end

	local parent = opts.parent or UIParent
	local frame = CreateFrame("Frame", opts.name, parent, "BasicFrameTemplateWithInset")
	frame:SetSize(opts.width or 420, opts.height or 520)
	frame:SetPoint(unpack(opts.point or { "CENTER" }))
	frame:SetFrameStrata(opts.frameStrata or "DIALOG")
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()

	frame.TitleText:SetText(opts.title or "Text Styles")

	if type(opts.subtitle) == "string" and opts.subtitle ~= "" then
		frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		frame.subtitle:SetPoint("TOPLEFT", 16, -34)
		frame.subtitle:SetPoint("RIGHT", -16, 0)
		frame.subtitle:SetJustifyH("LEFT")
		frame.subtitle:SetText(opts.subtitle)
	end

	frame.StyleSelectors = {}
	frame.StyleOrder = {}

	local previous
	local startY = frame.subtitle and -64 or -40
	local gap = tonumber(opts.selectorGap) or 26
	local selectorWidth = opts.selectorWidth or ((opts.width or 420) - 60)

	local function onAnyStyleChanged()
		if type(opts.onChange) == "function" then
			opts.onChange(db)
		end
	end

	for index, styleDef in ipairs(styles) do
		if type(styleDef) == "table" and type(styleDef.key) == "string" and styleDef.key ~= "" then
			local selector = self:AttachStyleSelector(frame, db, styleDef.key, {
				label = styleDef.label or styleDef.key,
				value = styleDef.value or styleDef.default,
				previewText = styleDef.previewText,
				width = styleDef.width or selectorWidth,
				height = styleDef.height or 130,
				dropdownWidth = styleDef.dropdownWidth,
				buttonWidth = styleDef.buttonWidth,
				menuWidth = styleDef.menuWidth,
				menuHeight = styleDef.menuHeight,
				sliderWidth = styleDef.sliderWidth,
				minSize = styleDef.minSize,
				maxSize = styleDef.maxSize,
				fontLabel = styleDef.fontLabel,
				sizeLabel = styleDef.sizeLabel,
				flagsLabel = styleDef.flagsLabel,
				onChange = onAnyStyleChanged,
			})

			if selector then
				if previous then
					selector:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -gap)
				else
					selector:SetPoint("TOPLEFT", 18, startY)
				end
				previous = selector
				frame.StyleSelectors[styleDef.key] = selector
				frame.StyleOrder[#frame.StyleOrder + 1] = styleDef.key
			end
		end
	end

	if type(opts.onReset) == "function" then
		frame.resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.resetButton:SetSize(opts.resetButtonWidth or 120, 24)
		frame.resetButton:SetPoint("BOTTOMLEFT", 18, 16)
		frame.resetButton:SetText(opts.resetButtonText or "Reset Styles")
		frame.resetButton:SetScript("OnClick", function()
			opts.onReset(db)
			for _, key in ipairs(frame.StyleOrder) do
				local selector = frame.StyleSelectors[key]
				if selector and selector.RefreshFromDB then
					selector:RefreshFromDB()
				end
			end
			onAnyStyleChanged()
		end)
	end

	function frame:RefreshFromDB()
		for _, key in ipairs(self.StyleOrder) do
			local selector = self.StyleSelectors[key]
			if selector and selector.RefreshFromDB then
				selector:RefreshFromDB()
			end
		end
	end

	function frame:Toggle()
		if self:IsShown() then
			self:Hide()
			return
		end

		self:RefreshFromDB()
		self:Show()
		self:Raise()
	end

	return frame
end
