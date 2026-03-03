--=====================================================================================
-- RGX | Simple Quest Plates! - options_widgets.lua

-- Author: DonnieDice
-- Description: Custom widget creation functions
--=====================================================================================

local addonName, SQP = ...
local CreateFrame = CreateFrame

-- Create custom styled button
function SQP:CreateStyledButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 120, height or 30)

    -- Normal texture
    button:SetNormalTexture("Interface\\Buttons\\UI-DialogBox-Button-Up")
    button:GetNormalTexture():SetTexCoord(0, 1, 0, 0.71875)

    -- Highlight texture
    button:SetHighlightTexture("Interface\\Buttons\\UI-DialogBox-Button-Highlight")
    button:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.71875)
    button:GetHighlightTexture():SetBlendMode("ADD")

    -- Pushed texture
    button:SetPushedTexture("Interface\\Buttons\\UI-DialogBox-Button-Down")
    button:GetPushedTexture():SetTexCoord(0, 1, 0, 0.71875)

    -- Text
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetDisabledFontObject("GameFontDisable")

    return button
end

-- Create small inline reset button (↺ symbol)
function SQP:CreateInlineResetButton(parent, onClickFn)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(22, 16)
    btn:SetNormalTexture("Interface\\Buttons\\UI-DialogBox-Button-Up")
    btn:GetNormalTexture():SetTexCoord(0, 1, 0, 0.71875)
    btn:SetHighlightTexture("Interface\\Buttons\\UI-DialogBox-Button-Highlight")
    btn:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.71875)
    btn:GetHighlightTexture():SetBlendMode("ADD")
    btn:SetPushedTexture("Interface\\Buttons\\UI-DialogBox-Button-Down")
    btn:GetPushedTexture():SetTexCoord(0, 1, 0, 0.71875)

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont("Fonts\\ARIALN.TTF", 13)
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetText("\226\134\186") -- ↺ (U+21BA)

    btn:SetAlpha(0.7)
    btn:SetScript("OnClick", onClickFn)
    btn:SetScript("OnEnter", function(self) self:SetAlpha(1.0) end)
    btn:SetScript("OnLeave", function(self) self:SetAlpha(0.7) end)
    return btn
end

-- Create custom slider
function SQP:CreateStyledSlider(parent, min, max, step, width)
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    slider:SetSize(width or 200, 16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Background
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = {left = 3, right = 3, top = 6, bottom = 6}
    })

    -- Thumb
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

    return slider
end

-- Create a per-type font settings section (size + family only)
-- parent: frame to attach controls to
-- typeKey: "kill", "loot", or "percent"
-- yOffset: starting y position (negative)
-- dropdownName: unique global name for the dropdown frame
-- activatePreviewFn: optional function to switch preview mode before refresh
-- returns: next yOffset after all controls
function SQP:CreateFontSection(parent, typeKey, yOffset, dropdownName, activatePreviewFn)
    if not self.optionControls then self.optionControls = {} end

    local defaultSize = typeKey == "percent" and 8 or 12

    -- Section header
    local fontHeader = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontHeader:SetPoint("TOPLEFT", 20, yOffset)
    fontHeader:SetText("|cff58be81Font|r")
    yOffset = yOffset - 22

    -- ── Font Size ──────────────────────────────────────────────────────────
    local curSize = SQPSettings[typeKey.."FontSize"] or defaultSize
    local sizeLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sizeLabel:SetPoint("TOPLEFT", 20, yOffset)
    sizeLabel:SetText(string.format("Size: %d", curSize))
    self.optionControls[typeKey.."FontSizeLabel"] = sizeLabel

    local sizeSlider = self:CreateStyledSlider(parent, 6, 26, 1, 160)
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -4)
    sizeSlider:SetValue(curSize)
    self.optionControls[typeKey.."FontSize"] = sizeSlider

    local sizeReset = self:CreateInlineResetButton(parent, function()
        SQP:SetSetting(typeKey.."FontSize", defaultSize)
        sizeSlider:SetValue(defaultSize)
        sizeLabel:SetText(string.format("Size: %d", defaultSize))
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    sizeReset:SetPoint("LEFT", sizeSlider, "RIGHT", 5, 0)

    sizeSlider:SetScript("OnValueChanged", function(self, val)
        val = math.floor(val + 0.5)
        SQP:SetSetting(typeKey.."FontSize", val)
        sizeLabel:SetText(string.format("Size: %d", val))
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 36

    -- ── Font Family ────────────────────────────────────────────────────────
    local familyLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    familyLabel:SetPoint("TOPLEFT", 20, yOffset)
    familyLabel:SetText("Family")

    local fontDd = CreateFrame("Frame", dropdownName, parent, "UIDropDownMenuTemplate")
    local familyReset = self:CreateInlineResetButton(parent, function()
        SQP:SetSetting(typeKey.."FontFamily", "Fonts\\FRIZQT__.TTF")
        UIDropDownMenu_SetText(fontDd, "Friz Quadrata")
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    familyReset:SetPoint("LEFT", familyLabel, "RIGHT", 5, 0)
    yOffset = yOffset - 20

    fontDd:SetPoint("TOPLEFT", 5, yOffset)
    UIDropDownMenu_SetWidth(fontDd, 160)
    self.optionControls[typeKey.."FontFamily"] = fontDd

    local fontOptions = {
        {text = "Friz Quadrata", font = "Fonts\\FRIZQT__.TTF"},
        {text = "Arial Narrow",  font = "Fonts\\ARIALN.TTF"},
        {text = "Skurri",        font = "Fonts\\SKURRI.TTF"},
        {text = "Morpheus",      font = "Fonts\\MORPHEUS.TTF"},
        {text = "2002 (Pixel)",  font = "Fonts\\2002.TTF"},
        {text = "2002 Bold",     font = "Fonts\\2002B.TTF"},
        {text = "Nimrod MT",     font = "Fonts\\NIM_____.ttf"},
    }

    UIDropDownMenu_Initialize(fontDd, function(self, level)
        for _, opt in ipairs(fontOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text
            info.func = function()
                SQP:SetSetting(typeKey.."FontFamily", opt.font)
                UIDropDownMenu_SetText(fontDd, opt.text)
                if activatePreviewFn then activatePreviewFn() end
                SQP:RefreshAllNameplates()
            end
            info.checked = (SQPSettings[typeKey.."FontFamily"] == opt.font)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local curFamily = SQPSettings[typeKey.."FontFamily"] or "Fonts\\FRIZQT__.TTF"
    for _, opt in ipairs(fontOptions) do
        if opt.font == curFamily then UIDropDownMenu_SetText(fontDd, opt.text); break end
    end
    yOffset = yOffset - 34

    return yOffset
end

-- Create a Display Style (Icon / Text) section
-- typeKey: "kill", "loot", "percent", or nil (legacy/global)
-- activatePreviewFn: optional function to call to switch the preview mode
-- returns: next yOffset
function SQP:CreateDisplayStyleSection(parent, typeKey, activatePreviewFn, yOffset)
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

    local dsHeader = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dsHeader:SetPoint("TOPLEFT", 20, yOffset)
    dsHeader:SetText("|cff58be81Display Style|r")
    yOffset = yOffset - 22

    local iconStyleBtn = self:CreateStyledButton(parent, "Icon", 75, 25)
    local textStyleBtn = self:CreateStyledButton(parent, "Text", 75, 25)
    iconStyleBtn:SetPoint("TOPLEFT", 20, yOffset)
    textStyleBtn:SetPoint("LEFT", iconStyleBtn, "RIGHT", 8, 0)

    local function IsIconStyleEnabled()
        local value = SQPSettings[settingKey]
        if value == nil and typeKey then
            value = SQPSettings.showIconBackground
        end
        return value ~= false
    end

    local function UpdateStyleButtons()
        local iconStyle = IsIconStyleEnabled()
        iconStyleBtn:SetAlpha(iconStyle and 1 or 0.6)
        textStyleBtn:SetAlpha(iconStyle and 0.6 or 1)
    end
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

    local function BroadcastStyleUpdate()
        local updaters = SQP.styleButtonUpdaters and SQP.styleButtonUpdaters[settingKey]
        if not updaters then return end
        for _, fn in ipairs(updaters) do
            fn()
        end
    end

    iconStyleBtn:SetScript("OnClick", function()
        SQP:SetSetting(settingKey, true)
        BroadcastStyleUpdate()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    textStyleBtn:SetScript("OnClick", function()
        SQP:SetSetting(settingKey, false)
        BroadcastStyleUpdate()
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    return yOffset
end

-- Create a per-type mini icon tint section (kill or loot task icons)
-- Compact single-row: [Swatch] [☑ Tint Icon] [Reset]
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
    tintColorBtn:SetPoint("TOPLEFT", 20, yOffset)
    local tintBg = tintColorBtn:CreateTexture(nil, "BACKGROUND")
    tintBg:SetAllPoints(); tintBg:SetColorTexture(0, 0, 0, 1)
    local tintSw = tintColorBtn:CreateTexture(nil, "ARTWORK")
    tintSw:SetSize(16, 16); tintSw:SetPoint("CENTER")
    tintSw:SetColorTexture(unpack(SQPSettings[tintColorKey] or {1, 1, 1}))

    -- Checkbox + label inline with swatch
    local tintCbFrame = self:CreateStyledCheckbox(parent, labelText)
    tintCbFrame:SetPoint("LEFT", tintColorBtn, "RIGHT", 6, 0)
    tintCbFrame.checkbox:SetChecked(SQPSettings[tintKey] == true)
    self.optionControls[tintKey] = tintCbFrame.checkbox

    local tintReset = self:CreateInlineResetButton(parent, function()
        SQP:SetSetting(tintColorKey, {1, 1, 1})
        tintSw:SetColorTexture(1, 1, 1)
        if activatePreviewFn then activatePreviewFn() end
        SQP:RefreshAllNameplates()
    end)
    tintReset:SetPoint("LEFT", tintCbFrame.label, "RIGHT", 6, 0)

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
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting(tintColorKey, {nr, ng, nb})
            tintSw:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting(tintColorKey, {r, g, b})
            tintSw:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
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
    header:SetPoint("TOPLEFT", 20, yOffset)
    header:SetText("|cff58be81Main Icon|r")
    yOffset = yOffset - 18

    -- Animate Main Icon checkbox (skip if tab already exposes it in its own Animate section)
    if not skipAnimate then
        local animFrame = self:CreateStyledCheckbox(parent, "Animate Main Icon")
        animFrame:SetPoint("TOPLEFT", 20, yOffset)
        animFrame.checkbox:SetChecked(SQPSettings[animKey] == true)
        self.optionControls[animKey] = animFrame.checkbox
        animFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting(animKey, self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        yOffset = yOffset - 26
    end

    -- Inline tint row: [Swatch] [☑ Tint Main Icon] [Reset]
    local tintColorBtn = CreateFrame("Button", nil, parent)
    tintColorBtn:SetSize(20, 20)
    tintColorBtn:SetPoint("TOPLEFT", 20, yOffset)
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
    tintReset:SetPoint("LEFT", tintCbFrame.label, "RIGHT", 6, 0)

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
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting(tintColorKey, {nr, ng, nb})
            tintSw:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting(tintColorKey, {r, g, b})
            tintSw:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    yOffset = yOffset - 26

    return yOffset
end

-- Create custom checkbox
function SQP:CreateStyledCheckbox(parent, text)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(300, 24)

    local checkbox = CreateFrame("CheckButton", nil, frame)
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("LEFT", 0, 0)

    checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

    local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(text)

    frame.checkbox = checkbox
    frame.label = label

    return frame
end
