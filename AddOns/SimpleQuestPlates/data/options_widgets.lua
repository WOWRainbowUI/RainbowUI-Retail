--=====================================================================================
-- RGX | Simple Quest Plates! - options_widgets.lua

-- Author: DonnieDice
-- Description: Custom widget creation functions
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global
local CreateFrame = CreateFrame

-- Apply the framework's default font to one of SQP's ad-hoc panel font
-- strings so menu text matches every other RGX addon. Framework fonts
-- default to the Blizzard font.
function SQP:ApplyDefaultFont(fontString)
    local Fonts = _G.RGXFonts
    if not (Fonts and type(Fonts.Apply) == "function" and type(Fonts.GetDefault) == "function") then return end
    if not (fontString and fontString.GetFont) then return end
    pcall(function()
        local _, size, flags = fontString:GetFont()
        Fonts:Apply(fontString, Fonts:GetDefault(), size, flags)
    end)
end

-- Create custom styled button - delegates to RGXDesign via RGXUI
function SQP:CreateStyledButton(parent, text, width, height)
    local UI = _G.RGXUI
    if UI and type(UI.CreateButton) == "function" then
        return UI:CreateButton(parent, text, width, height)
    end
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 120, height or 22)
    button:SetText(text or "")
    return button
end

-- Create compact inline reset button - delegates to RGXUI
function SQP:CreateInlineResetButton(parent, onClickFn)
    local UI = _G.RGXUI
    if UI and type(UI.CreateResetButton) == "function" then
        return UI:CreateResetButton(parent, onClickFn)
    end
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(20, 16)
    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    SQP:ApplyDefaultFont(lbl)
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetText("R")
    btn.lbl = lbl
    btn:SetAlpha(0.7)
    btn:SetScript("OnClick", onClickFn)
    btn:SetScript("OnEnter", function(self) self:SetAlpha(1.0) end)
    btn:SetScript("OnLeave", function(self) self:SetAlpha(0.7) end)
    return btn
end

-- Create custom styled slider - delegates to RGXUI
function SQP:CreateStyledSlider(parent, options)
	options = options or {}
	if options.valueDisplay == nil then options.valueDisplay = "hover" end
	-- Purpose stays visible above the track; only the numeric value is hover-only.
	options.noLabel = false
	local baseline = options.key and self:GetSettingBaseline(options.key)
	if baseline ~= nil then options.default = baseline end
	local UI = _G.RGXUI
	if UI and type(UI.CreateSlider) == "function" then
		return UI:CreateSlider(parent, options)
	end
	local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
	slider:SetSize((options and options.width) or 200, 14)
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues((options and options.min) or 0, (options and options.max) or 100)
	slider:SetValueStep((options and options.step) or 1)
	slider:SetObeyStepOnDrag(true)
	slider:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, tileSize = 8, edgeSize = 8,
		insets = {left = 3, right = 3, top = 6, bottom = 6}
	})
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

	-- Persisted value binding + live thumb restore. Old fallback returned a bare
	-- slider whose thumb always defaulted to the left until someone dragged it.
	local storage = (options and options.storage) or {}
	local key = (options and options.key) or "value"
	local default = options and options.default
	local onChange = (options and options.onChange) or function() end
	local suffix = (options and options.suffix) or ""
	local valueLabel = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	valueLabel:SetPoint("TOP", slider, "BOTTOM", 0, -2)
	slider.value = valueLabel
	slider.valueLabel = valueLabel
	if options.valueDisplay ~= "always" then valueLabel:Hide() end
	slider:SetScript("OnEnter", function()
		if options.valueDisplay ~= "none" then valueLabel:Show() end
	end)
	slider:SetScript("OnLeave", function()
		if options.valueDisplay ~= "always" then valueLabel:Hide() end
	end)

	local nativeSetValue = slider.SetValue
	local restoring = false
	local function RefreshFromStorage()
		local minV, maxV = slider:GetMinMaxValues()
		local step = slider:GetValueStep() or 1
		local value = storage[key]
		if value == nil then value = default end
		if value == nil then value = minV end
		local snapped = math.floor(value / step + 0.5) * step
		snapped = math.max(minV, math.min(maxV, snapped))
		restoring = true
		nativeSetValue(slider, snapped)
		restoring = false
		valueLabel:SetText(tostring(snapped) .. suffix)
		local width = slider:GetWidth()
		local thumb = slider:GetThumbTexture()
		if width > 0 and thumb then
			local pct = (maxV == minV) and 0 or ((snapped - minV) / (maxV - minV))
			thumb:ClearAllPoints()
			thumb:SetPoint("CENTER", slider, "LEFT", pct * width, 0)
		end
	end

	slider:SetScript("OnValueChanged", function(self, value)
		if restoring then return end
		local minV, maxV = self:GetMinMaxValues()
		local step = self:GetValueStep() or 1
		value = math.max(minV, math.min(maxV, math.floor(value / step + 0.5) * step))
		storage[key] = value
		valueLabel:SetText(tostring(value) .. suffix)
		onChange(value)
	end)
	slider.SetValue = function(self, value)
		if value == nil and type(self) == "number" then value = self end
		storage[key] = value
		RefreshFromStorage()
		onChange(storage[key])
	end
	slider.Refresh = RefreshFromStorage
	RefreshFromStorage()
	if slider.HookScript then
		slider:HookScript("OnShow", RefreshFromStorage)
		slider:HookScript("OnSizeChanged", function() RefreshFromStorage() end)
	end
	return slider
end

-- Attach a hover tooltip to a control (explanations stay out of panel body)
function SQP:SetControlTooltip(widget, text)
    if not widget or not widget.SetScript or not widget.EnableMouse then return end
    widget:EnableMouse(true)
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Re-apply font settings to live nameplate texts and the preview after a
-- font size or family change. activatePreviewFn: optional preview mode switch.
function SQP:RefreshFontDisplays(activatePreviewFn)
    if type(activatePreviewFn) == "function" then
        pcall(activatePreviewFn)
    end
    SQP:RefreshAllNameplates()
    if SQP.previewFrame and type(SQP.previewFrame.UpdatePreview) == "function" then
        pcall(function() SQP.previewFrame:UpdatePreview() end)
    end
end

-- Create a font settings section (size + family)
-- typeKey: "kill", "loot", or "percent" for per-type overrides; nil for the
-- global nameplate font (shared settings). Per-type sections inherit the
-- global font until overridden on their own tab.
-- activatePreviewFn: optional function to switch preview mode before refresh
-- returns: next yOffset after all controls
function SQP:CreateFontSection(parent, typeKey, yOffset, activatePreviewFn)
    if not self.optionControls then self.optionControls = {} end

    local Fonts = _G.RGXFonts
    local sizeKey   = typeKey and (typeKey .. "FontSize")   or "fontSize"
    local familyKey = typeKey and (typeKey .. "FontFamily") or "fontFamily"
    local defaultSize = SQP:GetSettingBaseline(sizeKey)
    -- Display the effective font: inherited global unless this type has an
    -- explicit override; fall back to the framework default (Blizzard font).
    local baselineFamily = SQP:GetSettingBaseline(familyKey)
    local defaultName = Fonts:ResolveName(baselineFamily, Fonts:GetDefault()) or Fonts:GetDefault()

    -- The Global card already supplies the Font header. Standalone per-type
    -- sections still need their own heading.
    if typeKey then
        local fontHeader = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fontHeader:SetPoint("TOPLEFT", 8, yOffset)
        fontHeader:SetText("|cff58be81" .. (self.L["OPTIONS_FONT"] or "Font") .. "|r")
        SQP:ApplyDefaultFont(fontHeader)
        yOffset = yOffset - 18
    end

	-- == Font Size ==========================================================
	local curSize = SQPSettings[sizeKey] or defaultSize
	local sizeSlider = self:CreateStyledSlider(parent, {
		key = sizeKey,
		label = "Size",
		min = 6,
		max = 26,
		step = 1,
		default = defaultSize,
		storage = SQPSettings,
		width = 160,
		onChange = function(val)
			SQP:RefreshFontDisplays(activatePreviewFn)
		end,
	})
	sizeSlider:SetPoint("TOPLEFT", 8, yOffset)
	sizeSlider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yOffset)
	self.optionControls[sizeKey] = sizeSlider

	yOffset = yOffset - 38

    -- == Font Family ========================================================
    local familyLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    familyLabel:SetPoint("TOPLEFT", 8, yOffset)
    familyLabel:SetText("Family")
    SQP:ApplyDefaultFont(familyLabel)
    familyLabel:SetTextColor(0.345, 0.745, 0.506)
    yOffset = yOffset - 20

    local fontControl = Fonts:CreateFontSettingControl(parent, {
        width = 210,
        buttonWidth = 160,
        fill = true,
        height = 36,
        dropdownHeight = 36,
        label = "",
        triggerStyle = "retail",
        showReset = true,
        storage = SQPSettings,
        key = familyKey,
        defaultName = defaultName,
        defaultPath = (Fonts.GetPath and Fonts:GetPath(Fonts:GetDefault())) or "Fonts\\FRIZQT__.TTF",
        onChange = function(_, _, fontPath)
            if type(fontPath) == "string" then
                fontPath = fontPath:gsub("/", "\\")
            end
            SQP:SetSetting(familyKey, fontPath)
            SQP:RefreshFontDisplays(activatePreviewFn)
        end,
    })
    fontControl:SetPoint("TOPLEFT", 8, yOffset)
    fontControl:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -36, yOffset)
    self.optionControls[familyKey] = fontControl

    yOffset = yOffset - 30

    return yOffset
end

-- Create a Display Style section: a Classic / Forever background dropdown plus
-- a "Text mode" tick box. The two controls are mutually exclusive at their
-- scope: picking a dropdown entry clears text mode, and ticking the box
-- clears the chip. Unticking returns to the inherited (per-type) or default
-- (global) style.
-- typeKey: "kill", "loot", "percent", or nil (legacy/global)
-- activatePreviewFn: optional function to call to switch the preview mode
-- returns: next yOffset
function SQP:CreateDisplayStyleSection(parent, typeKey, activatePreviewFn, yOffset, opts)
    opts = opts or {}
    if type(typeKey) == "function" then
        yOffset = activatePreviewFn
        activatePreviewFn = typeKey
        typeKey = nil
    end
    if yOffset == nil and type(activatePreviewFn) == "number" then
        yOffset = activatePreviewFn
        activatePreviewFn = nil
    end

    local settingKey = typeKey and (typeKey .. "ShowIconBackground") or "showIconBackground"
    local chipKey = typeKey and (typeKey .. "LevelChip") or "unifiedNameplates"

    local dsHeader = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    SQP:ApplyDefaultFont(dsHeader)
    dsHeader:SetPoint("TOPLEFT", 8, yOffset)
    dsHeader:SetText("|cff58be81Background Style|r")
    dsHeader:SetFontObject(GameFontNormal)
    dsHeader:SetTextColor(0.345, 0.745, 0.506)
    yOffset = yOffset - 18
    -- Same two-way model as the Global "Background style" dropdown, as a
    -- dropdown so both surfaces expose identical options. Text-only lives
    -- in the tick box below, not in this list.
    local Drops = _G.RGXDropdowns
    if not (Drops and type(Drops.CreateNestedDropdown) == "function") then
        return yOffset
    end

    -- Background choice only: text mode is reported by the tick box.
    local function CurrentMode()
        if SQP:UsesLevelChip(typeKey) then return "chip" end
        return "icon"
    end

    local function IsTextMode()
        local value = SQPSettings[settingKey]
        if value == nil and typeKey then
            value = SQPSettings.showIconBackground
        end
        return value == false
    end

    local function UpdateStyleButtons()
        local dd = SQP.optionControls[settingKey .. "StyleDropdown"]
        if dd and type(dd.SetValue) == "function" then
            dd:SetValue(CurrentMode())
        end
        local box = SQP.optionControls[settingKey .. "TextOnly"]
        if box and type(box.SetChecked) == "function" then
            box:SetChecked(IsTextMode())
        end
    end

    local function BroadcastStyleUpdate()
        local updaters = SQP.styleButtonUpdaters and SQP.styleButtonUpdaters[settingKey]
        if not updaters then return end
        for _, fn in ipairs(updaters) do
            fn()
        end
    end

    local function ApplyStyle()
        BroadcastStyleUpdate()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end

    local dd = Drops:CreateNestedDropdown(parent, {
        -- No dropdown label: the section header above ("Display Style") is
        -- the label. A second "Style" caption would say the word twice.
        label = "",
        width = 300,
        buttonWidth = 290,
        triggerStyle = "retail",
        value = CurrentMode(),
        items = {
            { text = "Classic (default)", value = "icon" },
            -- The Forever atlas only exists on the Forever client. Elsewhere,
            -- chip maps to the portable rounded bubble variant instead.
            { text = "Coin", value = "chip" },
        },
        onChange = function(value)
            SQP:SetSetting(chipKey, value == "chip")
            ApplyStyle()
        end,
    })
    if dd then
        dd:SetPoint("TOPLEFT", 8, yOffset)
        dd:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yOffset)
        SQP:SetControlTooltip(dd, "Pick this quest type's background: Classic icon or the Forever level-frame style.")
        self.optionControls[settingKey .. "StyleDropdown"] = dd
    end
    yOffset = yOffset - 30

    local textFrame = self:CreateStyledCheckbox(parent, "Text Mode")
    textFrame:SetPoint("TOPLEFT", 8, opts.textRowY or yOffset)
    if opts.textRowY then textFrame:SetWidth(130) end
    textFrame.checkbox:SetChecked(IsTextMode())
    self.optionControls[settingKey .. "TextOnly"] = textFrame.checkbox
    textFrame.checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            SQP:SetSetting(settingKey, false)
            if typeKey == "percent" then
                SQP:SetSetting("showPercentIcon", true)
                local control = SQP.optionControls.showPercentIcon
                if control then control:SetChecked(true) end
            end
        else
            SQP:SetSetting(settingKey, nil)
        end
        ApplyStyle()
    end)
    SQP:SetControlTooltip(textFrame, "Use objective ratio text. Forever keeps its frame; Classic shows bare text. Unticking inherits Global text formatting.")
    if not opts.textRowY then yOffset = yOffset - 22 end

    UpdateStyleButtons()
    if self.optionControls then
        self.optionControls[settingKey .. "StyleUpdater"] = UpdateStyleButtons
    end

    -- Register updater for cross-panel sync of this specific display-style key
    if not SQP.styleButtonUpdaters then SQP.styleButtonUpdaters = {} end
    if not SQP.styleButtonUpdaters[settingKey] then
        SQP.styleButtonUpdaters[settingKey] = {}
    end
    table.insert(SQP.styleButtonUpdaters[settingKey], UpdateStyleButtons)

    -- Keep the dropdown selection live when the style changes from elsewhere.
    table.insert(SQP.styleButtonUpdaters[settingKey], function()
        local control = self.optionControls[settingKey .. "StyleDropdown"]
        if control and type(control.SetValue) == "function" then
            control:SetValue(CurrentMode())
        end
    end)

    return yOffset
end

-- Create a per-type mini icon tint section (kill or loot task icons)
-- Compact single-row: [Swatch] [Tint Icon] [Reset]
-- typeKey: "kill" or "loot"
-- returns: next yOffset
function SQP:CreateMiniIconTintSection(parent, typeKey, activatePreviewFn, yOffset)
    local tintKey      = typeKey .. "TintIcon"
    local tintColorKey = typeKey .. "TintIconColor"
    local labelText
    if typeKey == "kill" then
        labelText = "Tint Kill Icon"
    elseif typeKey == "loot" then
        labelText = "Tint Loot Icon"
    else
        labelText = "Tint Percent Sign"
    end

    -- Color swatch button (also acts as color picker opener)
    local tintColorBtn = CreateFrame("Button", nil, parent)
    tintColorBtn:SetSize(20, 20)
    tintColorBtn:SetPoint("TOPLEFT", 8, yOffset)
    local tintBg = tintColorBtn:CreateTexture(nil, "BACKGROUND")
    tintBg:SetAllPoints(); tintBg:SetColorTexture(0, 0, 0, 1)
    local tintSw = tintColorBtn:CreateTexture(nil, "ARTWORK")
    tintSw:SetSize(16, 16); tintSw:SetPoint("CENTER")
    tintSw:SetColorTexture(unpack(SQPSettings[tintColorKey] or {1, 1, 1}))

    -- Checkbox + label inline with swatch
    local tintCbFrame = self:CreateStyledCheckbox(parent, labelText)
    tintCbFrame:SetPoint("LEFT", tintColorBtn, "RIGHT", 6, 0)
    tintCbFrame:SetWidth(tintCbFrame.label:GetStringWidth() + 24)
    tintCbFrame.checkbox:SetChecked(SQPSettings[tintKey] == true)
    self.optionControls[tintKey] = tintCbFrame.checkbox

    local tintReset = self:CreateInlineResetButton(parent, function()
        SQP:SetSetting(tintColorKey, {1, 1, 1})
        tintSw:SetColorTexture(1, 1, 1)
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    _G.RGXUI:AnchorRowReset(parent, tintReset, tintColorBtn)

    local function UpdateTintAlpha()
        local a = SQPSettings[tintKey] == true and 1 or 0.4
        tintColorBtn:SetAlpha(a)
        tintReset:SetAlpha(a * 0.7)
    end
    UpdateTintAlpha()
    -- Store for external access (e.g. tab reset buttons)
    self.optionControls[tintColorKey.."Swatch"] = tintSw
    self.optionControls[tintKey.."AlphaUpdate"] = UpdateTintAlpha

    tintCbFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting(tintKey, self:GetChecked())
        UpdateTintAlpha()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)

    tintColorBtn:SetScript("OnClick", function()
        if not SQPSettings[tintKey] then return end
        if activatePreviewFn then activatePreviewFn() end
        local r, g, b = unpack(SQPSettings[tintColorKey] or {1, 1, 1})
        _G.RGXColors:OpenPicker({
            r = r, g = g, b = b,
            onChanged = function(_, nr, ng, nb)
                SQP:SetSetting(tintColorKey, {nr, ng, nb})
                tintSw:SetColorTexture(nr, ng, nb)
                SQP:RefreshAllNameplates()
            end,
        })
    end)
    yOffset = yOffset - 26

    return yOffset
end

-- Create a per-type main icon (jellybean) animate + tinting section
-- Compact: header (18px) + animate checkbox (26px, optional) + inline tint row (26px)
-- skipAnimate: pass true when the tab already has a dedicated Animate section above
-- typeKey: "kill", "loot", or "percent"
-- returns: next yOffset
function SQP:CreateMainIconSection(parent, typeKey, activatePreviewFn, yOffset, skipAnimate)
    local tintKey      = typeKey .. "TintMain"
    local tintColorKey = typeKey .. "TintMainColor"
    local animKey      = typeKey .. "AnimateMain"

    -- Section header (tight gap)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    SQP:ApplyDefaultFont(header)
    header:SetPoint("TOPLEFT", 8, yOffset)
    header:SetText("|cff58be81Main Icon|r")
    header:SetFontObject(GameFontNormal)
    yOffset = yOffset - 18

    -- Animate Main Icon checkbox (skip if tab already exposes it in its own Animate section)
    if not skipAnimate then
        local animFrame = self:CreateStyledCheckbox(parent, "Animate Main Icon")
        animFrame:SetPoint("TOPLEFT", 8, yOffset)
        animFrame.checkbox:SetChecked(SQPSettings[animKey] == true)
        self.optionControls[animKey] = animFrame.checkbox
        animFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting(animKey, self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        yOffset = yOffset - 26
    end

    -- Inline tint row: [Swatch] [Tint Main Icon] [Reset]
    local tintColorBtn = CreateFrame("Button", nil, parent)
    tintColorBtn:SetSize(20, 20)
    tintColorBtn:SetPoint("TOPLEFT", 8, yOffset)
    local tintBg = tintColorBtn:CreateTexture(nil, "BACKGROUND")
    tintBg:SetAllPoints(); tintBg:SetColorTexture(0, 0, 0, 1)
    local tintSw = tintColorBtn:CreateTexture(nil, "ARTWORK")
    tintSw:SetSize(16, 16); tintSw:SetPoint("CENTER")
    tintSw:SetColorTexture(unpack(SQPSettings[tintColorKey] or {1, 1, 1}))

    local tintCbFrame = self:CreateStyledCheckbox(parent, "Tint Main Icon")
    tintCbFrame:SetPoint("LEFT", tintColorBtn, "RIGHT", 6, 0)
    tintCbFrame.checkbox:SetChecked(SQPSettings[tintKey] == true)
    self.optionControls[tintKey] = tintCbFrame.checkbox

    local tintReset = self:CreateInlineResetButton(parent, function()
        SQP:SetSetting(tintColorKey, {1, 1, 1})
        tintSw:SetColorTexture(1, 1, 1)
        SQP:RefreshAllNameplates()
    end)
    _G.RGXUI:AnchorRowReset(parent, tintReset, tintColorBtn)

    local function UpdateTintAlpha()
        local a = SQPSettings[tintKey] == true and 1 or 0.4
        tintColorBtn:SetAlpha(a)
        tintReset:SetAlpha(a * 0.7)
    end
    UpdateTintAlpha()

    tintCbFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting(tintKey, self:GetChecked())
        UpdateTintAlpha()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)

    tintColorBtn:SetScript("OnClick", function()
        if not SQPSettings[tintKey] then return end
        if activatePreviewFn then activatePreviewFn() end
        local r, g, b = unpack(SQPSettings[tintColorKey] or {1, 1, 1})
        _G.RGXColors:OpenPicker({
            r = r, g = g, b = b,
            onChanged = function(_, nr, ng, nb)
                SQP:SetSetting(tintColorKey, {nr, ng, nb})
                tintSw:SetColorTexture(nr, ng, nb)
                SQP:RefreshAllNameplates()
            end,
        })
    end)
    yOffset = yOffset - 26

    return yOffset
end

-- Create custom checkbox
function SQP:CreateStyledCheckbox(parent, text)
    local UI = assert(_G.RGXUI, "SQP: RGXUI unavailable")
    local frame = UI:CreateCheckbox(parent, text)
    SQP:ApplyDefaultFont(frame.label)
    return frame
end

-- Plain columns; CreateCard supplies the only section border.
function SQP:CreateOptionColumns(content, colWidth, gap, titles)
    local UI = assert(_G.RGXUI, "SQP: RGXUI unavailable")
    return UI:CreateColumns(content, 2, { colWidth = colWidth, gap = gap or 8, titles = titles, card = false })
end

-- Section card with optional above-chaining; built on the framework section
-- factory so every options card uses the same skin.
function SQP:CreateCard(host, title, opts)
    opts = opts or {}
    local UI = assert(_G.RGXUI, "SQP: RGXUI unavailable")
    local frame = UI:CreateCard(host, { title = title, height = 200 })
    frame:ClearAllPoints()
    if opts.above then
        frame:SetPoint("TOPLEFT", opts.above, "BOTTOMLEFT", 0, -8)
        frame:SetPoint("TOPRIGHT", opts.above, "BOTTOMRIGHT", 0, -8)
    else
        frame:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", host, "TOPRIGHT", 0, 0)
    end
    return frame
end

-- Page header for an options page: framework section skin with the brand
-- icon, optional subtext rendered inside the same band. Pages keep their
-- full-size content hosts; the header sits above them visually (transparent
-- page frames never cover it).
function SQP:CreateHeaderSwitch(header, key)
    local default = self.DEFAULTS[key]
    if default == nil then default = true end
    local switch = _G.RGXUI:CreateSwitch(header, {
        key = key, storage = SQPSettings, default = default,
        onChange = function(enabled)
            if key == "animationsEnabled" then
                if not enabled then
                    SQP:SetSetting("toastBeforeAnimationDisable", SQPSettings.showQuestMarker ~= false)
                    SQP:SetSetting("showQuestMarker", false)
                else
                    local previous = SQPSettings.toastBeforeAnimationDisable
                    if previous ~= nil then SQP:SetSetting("showQuestMarker", previous) end
                    SQP:SetSetting("toastBeforeAnimationDisable", nil)
                end
                local toast = SQP.optionControls.showQuestMarker
                if toast then toast:SetChecked(SQPSettings.showQuestMarker ~= false) end
            elseif key == "showQuestMarker" and SQPSettings.animationsEnabled == false then
                SQP:SetSetting("toastBeforeAnimationDisable", enabled)
            end
            SQP:RefreshAllNameplates()
            SQP:UpdatePreviewManually()
        end,
    })
    switch:SetWidth(90)
    local band = header.headerBand or header.header or header
    switch:SetPoint("RIGHT", band, "RIGHT", -8, 0)
    self.optionControls[key] = switch.checkbox
    return switch
end

function SQP:CreatePageHeader(parent, title, opts)
    opts = type(opts) == "string" and { icon = opts } or (opts or {})
    local D = assert(_G.RGXDesign, "SQP: RGXDesign unavailable")
    local header = D:CreateSectionHeader(parent, title, opts.icon or SQP.ICON_TEXTURE)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    if opts.subtext then
        local sub = self:CreateLabel(header, { text = opts.subtext, size = "small", color = "muted" })
        -- True "within the header" placement: title and subtext share the band.
        sub:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 34, 4)
    end
    return header
end

-- BLU-style paged tab content (framework pager). Returns the pager object
-- and the list of page host frames; only page 1 is shown initially. Tabs
-- build their content into pager.frames[i]. opts.pageNames (array of label
-- strings) replaces the plain "Page X of Y" readout with the page name.
-- A pager-less fallback still returns pageCount hosts so page content can
-- be built into each.
function SQP:CreatePagedContent(content, pageCount, opts)
    local UI = _G.RGXUI
    if UI and type(UI.CreatePager) == "function" then
        local pager = UI:CreatePager(content, {
            pages = pageCount,
            startPage = opts and opts.startPage,
            onPageChanged = opts and opts.onPageChanged,
        })
        local names = opts and opts.pageNames
        if names and pager.label and pager.pageCount > 1 then
            local origSetPage = pager.SetPage
            pager.SetPage = function(self, n)
                origSetPage(self, n)
                local name = names[self.page]
                if name then
                    self.label:SetText(string.format("%s  (%d/%d)", name, self.page, self.pageCount))
                end
            end
            pager:SetPage(pager.page)
        end
        return pager, pager.frames
    end
    -- Fallback: plain page hosts without pager chrome
    local frames = {}
    for i = 1, pageCount do
        local host = CreateFrame("Frame", nil, content)
        host:SetAllPoints()
        host:SetShown(i == 1)
        frames[i] = host
    end
    return nil, frames
end

-- Task-icon side buttons occupy the first body row; center is optional.
function SQP:CreateIconSideSection(parent, typeKey, activatePreviewFn, yOffset, opts)
    if not self.optionControls then self.optionControls = {} end
    local sideKey = typeKey == "percent" and "percentSignSide" or typeKey .. "IconSide"
    local defaultSide = self.DEFAULTS[sideKey]
    local group = _G.RGXUI:CreateButtonGroup(parent, { "Left Side", "Right Side" },
        { buttonWidth = 68, height = 20, gap = 4 })
    group:ClearAllPoints()
    if opts and opts.center then
        group:SetPoint("TOP", parent, "TOP", 0, yOffset - 1)
    else
        group:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yOffset - 1)
    end
    local leftSideBtn, rightSideBtn = group.buttons[1], group.buttons[2]

    local function UpdateSideButtons()
        local current = SQPSettings[sideKey] or defaultSide
        leftSideBtn:SetAlpha(current == "left" and 1 or 0.6)
        rightSideBtn:SetAlpha(current == "right" and 1 or 0.6)
    end
    UpdateSideButtons()
    self.optionControls[sideKey .. "SideUpdater"] = UpdateSideButtons
    self.optionControls[sideKey .. "Buttons"] = { left = leftSideBtn, right = rightSideBtn }
    if typeKey == "percent" then self.optionControls.updatePercentSignSideButtons = UpdateSideButtons end

    leftSideBtn:SetScript("OnClick", function()
        SQP:SetSetting(sideKey, "left")
        UpdateSideButtons()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    rightSideBtn:SetScript("OnClick", function()
        SQP:SetSetting(sideKey, "right")
        UpdateSideButtons()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)

    return group
end
