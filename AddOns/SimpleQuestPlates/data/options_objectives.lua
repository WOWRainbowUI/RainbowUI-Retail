--=====================================================================================
-- RGX | Simple Quest Plates! - options_objectives.lua
--
-- Author: DonnieDice
-- Description: Compact purpose-first option pages for style, animation, and layout.
--=====================================================================================

local addonName, SQP = ...
local format = string.format

local OBJECTIVES = {
    {
        key = "kill",
        title = "Kill",
        preview = "activateKillMode",
        showKey = "showKillIcon",
        displayKey = "killShowIconBackground",
        colorKey = "killColor",
        colorLabel = "Quest target color",
        colorDefault = {1, 0.82, 0},
        sizeKey = "killIconSize",
        sizeDefault = 14,
        offsetXKey = "killIconOffsetX",
        offsetXDefault = 2,
        offsetYKey = "killIconOffsetY",
        offsetYDefault = 15,
        fontSizeKey = "killFontSize",
        fontSizeDefault = 12,
        fontFamilyKey = "killFontFamily",
        fontDropdown = "SQPKillFontDropdownCompact",
        animateMainKey = "killAnimateMain",
        intensityKey = "killAnimationIntensity",
        resetLabel = "Reset Kill",
    },
    {
        key = "loot",
        title = "Loot",
        preview = "activateLootMode",
        showKey = "showLootIcon",
        displayKey = "lootShowIconBackground",
        colorKey = "itemColor",
        colorLabel = "Quest item color",
        colorDefault = {0.2, 1, 0.2},
        sizeKey = "lootIconSize",
        sizeDefault = 14,
        offsetXKey = "lootIconOffsetX",
        offsetXDefault = -38,
        offsetYKey = "lootIconOffsetY",
        offsetYDefault = 16,
        fontSizeKey = "lootFontSize",
        fontSizeDefault = 12,
        fontFamilyKey = "lootFontFamily",
        fontDropdown = "SQPLootFontDropdownCompact",
        animateMainKey = "lootAnimateMain",
        intensityKey = "lootAnimationIntensity",
        resetLabel = "Reset Loot",
    },
    {
        key = "percent",
        title = "Percent",
        preview = "activatePercentMode",
        showKey = "showPercentIcon",
        displayKey = "percentShowIconBackground",
        colorKey = "percentColor",
        colorLabel = "Progress color",
        colorDefault = {0.2, 1, 1},
        sizeKey = "percentIconSize",
        sizeDefault = 8,
        offsetXKey = "percentIconOffsetX",
        offsetXDefault = 18,
        offsetYKey = "percentIconOffsetY",
        offsetYDefault = 0,
        fontSizeKey = "percentFontSize",
        fontSizeDefault = 8,
        fontFamilyKey = "percentFontFamily",
        fontDropdown = "SQPPercentFontDropdownCompact",
        animateMainKey = "percentAnimateMain",
        intensityKey = "percentAnimationIntensity",
        resetLabel = "Reset Percent",
    },
}

local function ActivatePreview(previewMethod)
    if SQP.previewFrame and SQP.previewFrame[previewMethod] then
        SQP.previewFrame[previewMethod]()
    end
end

local function CreateSectionFrame(parent, title, anchor, relAnchor, x, y, width, height)
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    section:SetSize(width, height)
    section:SetPoint(anchor, relAnchor, x, y)
    section:SetBackdrop(SQP.BACKDROP_DARK)
    section:SetBackdropColor(0.08, 0.08, 0.08, 0.85)
    section:SetBackdropBorderColor(0.188, 0.212, 0.231, 1)

    local header = section:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 12, -10)
    header:SetText("|cffbc6fa8" .. title .. "|r")

    return section
end

local function CreateObjectiveColorControl(parent, objective, yOffset)
    local colorBtn = CreateFrame("Button", nil, parent)
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("TOPLEFT", 12, yOffset)

    local bg = colorBtn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 1)

    local swatch = colorBtn:CreateTexture(nil, "ARTWORK")
    swatch:SetSize(16, 16)
    swatch:SetPoint("CENTER")
    swatch:SetColorTexture(unpack(SQPSettings[objective.colorKey] or objective.colorDefault))
    SQP.optionControls[objective.colorKey .. "CompactSwatch"] = swatch

    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    label:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    label:SetText(objective.colorLabel)

    local reset = SQP:CreateInlineResetButton(parent, function()
        SQP:SetSetting(objective.colorKey, {unpack(objective.colorDefault)})
        swatch:SetColorTexture(unpack(objective.colorDefault))
        ActivatePreview(objective.preview)
        SQP:RefreshAllNameplates()
    end)
    reset:SetPoint("LEFT", label, "RIGHT", 5, 0)

    colorBtn:SetScript("OnClick", function()
        ActivatePreview(objective.preview)
        local r, g, b = unpack(SQPSettings[objective.colorKey] or objective.colorDefault)
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting(objective.colorKey, {nr, ng, nb})
            swatch:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting(objective.colorKey, {r, g, b})
            swatch:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    return yOffset - 28
end

local function CreateCompactSlider(parent, title, key, defaultValue, minValue, maxValue, step, yOffset, previewMethod)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", 12, yOffset)
    label:SetText(title)

    local valueLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valueLabel:SetPoint("RIGHT", parent, "TOPRIGHT", -12, yOffset)

    local slider = SQP:CreateStyledSlider(parent, minValue, maxValue, step, 150)
    slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
    slider:SetValue(SQPSettings[key] ~= nil and SQPSettings[key] or defaultValue)
    SQP.optionControls[key] = slider

    local reset = SQP:CreateInlineResetButton(parent, function()
        SQP:SetSetting(key, defaultValue)
        slider:SetValue(defaultValue)
        if previewMethod then
            ActivatePreview(previewMethod)
        end
        SQP:RefreshAllNameplates()
    end)
    reset:SetPoint("LEFT", slider, "RIGHT", 4, 0)

    local function formatValue(value)
        if step == 0.1 then
            return format("%.1f", value)
        end
        return tostring(value)
    end

    local function normalize(value)
        if step == 0.1 then
            return math.floor(value * 10 + 0.5) / 10
        elseif step == 5 then
            return math.floor(value / 5 + 0.5) * 5
        end
        return math.floor(value + 0.5)
    end

    local function updateLabel(value)
        valueLabel:SetText(formatValue(value))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        value = normalize(value)
        SQP:SetSetting(key, value)
        updateLabel(value)
        if previewMethod then
            ActivatePreview(previewMethod)
        end
        SQP:RefreshAllNameplates()
    end)

    updateLabel(SQPSettings[key] ~= nil and SQPSettings[key] or defaultValue)
    return yOffset - 38
end

function SQP:CreateAnimationOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 14, -12)
    header:SetText("|cffbc6fa8Animation Controls|r")

    local note = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    note:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    note:SetText("One place for all nameplate animation behavior.")

    local globalSection = CreateSectionFrame(content, "Global Animation", "TOPLEFT", content, 0, -42, 314, 164)
    local perTypeSection = CreateSectionFrame(content, "Objective Animation", "TOPRIGHT", content, 0, -42, 314, 290)

    local yOffset = -34
    local overrideFrame = self:CreateStyledCheckbox(globalSection, "Use global override")
    overrideFrame:SetPoint("TOPLEFT", 12, yOffset)
    overrideFrame.checkbox:SetChecked(SQPSettings.useGlobalAnimationSettings == true)
    self.optionControls.useGlobalAnimationSettings = overrideFrame.checkbox
    yOffset = yOffset - 24

    local enabledFrame = self:CreateStyledCheckbox(globalSection, "Enable all animations")
    enabledFrame:SetPoint("TOPLEFT", 12, yOffset)
    enabledFrame.checkbox:SetChecked(SQPSettings.globalAnimationEnabled ~= false)
    self.optionControls.globalAnimationEnabled = enabledFrame.checkbox
    yOffset = yOffset - 24

    local modeLabel = globalSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    modeLabel:SetPoint("TOPLEFT", 12, yOffset)
    modeLabel:SetText("Animate when")
    yOffset = yOffset - 18

    local alwaysBtn = self:CreateStyledButton(globalSection, "Always", 58, 18)
    local combatBtn = self:CreateStyledButton(globalSection, "Combat", 58, 18)
    local noCombatBtn = self:CreateStyledButton(globalSection, "No Combat", 74, 18)
    alwaysBtn:SetPoint("TOPLEFT", 12, yOffset)
    combatBtn:SetPoint("LEFT", alwaysBtn, "RIGHT", 6, 0)
    noCombatBtn:SetPoint("LEFT", combatBtn, "RIGHT", 6, 0)
    yOffset = yOffset - 24

    local function GetAnimationMode()
        local mode = SQPSettings.animationCombatMode
        if mode ~= "always" and mode ~= "combat" and mode ~= "outofcombat" then
            return "always"
        end
        return mode
    end

    local function UpdateModeButtons()
        local mode = GetAnimationMode()
        alwaysBtn:SetAlpha(mode == "always" and 1 or 0.6)
        combatBtn:SetAlpha(mode == "combat" and 1 or 0.6)
        noCombatBtn:SetAlpha(mode == "outofcombat" and 1 or 0.6)
    end

    local function SetMode(mode)
        SQP:SetSetting("animationCombatMode", mode)
        UpdateModeButtons()
        SQP:RefreshAllNameplates()
    end

    alwaysBtn:SetScript("OnClick", function() SetMode("always") end)
    combatBtn:SetScript("OnClick", function() SetMode("combat") end)
    noCombatBtn:SetScript("OnClick", function() SetMode("outofcombat") end)
    UpdateModeButtons()

    CreateCompactSlider(globalSection, "Global intensity", "globalAnimationIntensity", 100, 25, 200, 5, yOffset, nil)

    local taskSectionLabel = perTypeSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    taskSectionLabel:SetPoint("TOPLEFT", 12, -34)
    taskSectionLabel:SetText("|cff58be81Task Icons|r")

    local taskFrame = self:CreateStyledCheckbox(perTypeSection, "Animate task icons")
    taskFrame:SetPoint("TOPLEFT", 12, -54)
    taskFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
    self.optionControls.animateQuestIcons = taskFrame.checkbox

    local summary = perTypeSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    summary:SetPoint("TOPLEFT", 12, -82)
    summary:SetWidth(280)
    summary:SetJustifyH("LEFT")
    summary:SetText("Applies to the small quest markers on kill, loot, and percent plates.")

    local updaters = {}
    local startY = -122
    for index, objective in ipairs(OBJECTIVES) do
        local title = perTypeSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        title:SetPoint("TOPLEFT", 12, startY)
        title:SetText("|cffbc6fa8" .. objective.title .. "|r")

        local mainFrame = self:CreateStyledCheckbox(perTypeSection, "Animate main icon")
        mainFrame:SetPoint("TOPLEFT", 12, startY - 18)
        mainFrame.checkbox:SetChecked(SQPSettings[objective.animateMainKey] == true)
        self.optionControls[objective.animateMainKey] = mainFrame.checkbox

        local label = perTypeSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", 34, startY - 42)
        label:SetText(format("Intensity: %d%%", SQPSettings[objective.intensityKey] or 100))
        self.optionControls[objective.intensityKey .. "Label"] = label

        local slider = self:CreateStyledSlider(perTypeSection, 25, 200, 5, 132)
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
        slider:SetValue(SQPSettings[objective.intensityKey] or 100)
        self.optionControls[objective.intensityKey] = slider

        local reset = self:CreateInlineResetButton(perTypeSection, function()
            SQP:SetSetting(objective.intensityKey, 100)
            slider:SetValue(100)
            label:SetText("Intensity: 100%")
            ActivatePreview(objective.preview)
            SQP:RefreshAllNameplates()
        end)
        reset:SetPoint("LEFT", slider, "RIGHT", 4, 0)

        mainFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting(objective.animateMainKey, self:GetChecked())
            ActivatePreview(objective.preview)
            SQP:RefreshAllNameplates()
        end)

        slider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value / 5 + 0.5) * 5
            SQP:SetSetting(objective.intensityKey, value)
            label:SetText(format("Intensity: %d%%", value))
            ActivatePreview(objective.preview)
            SQP:RefreshAllNameplates()
        end)

        updaters[#updaters + 1] = function(disabled)
            local alpha = disabled and 0.45 or 1
            title:SetAlpha(alpha)
            mainFrame:SetAlpha(alpha)
            if mainFrame.checkbox then
                mainFrame.checkbox:SetEnabled(not disabled)
            end
            slider:SetEnabled(not disabled)
            slider:SetAlpha(alpha)
            label:SetAlpha(alpha)
            reset:SetAlpha(disabled and 0.35 or 0.7)
        end

        startY = startY - 56
    end

    local function UpdateAnimationState()
        local usingGlobal = SQPSettings.useGlobalAnimationSettings == true
        enabledFrame:SetAlpha(usingGlobal and 1 or 0.45)
        enabledFrame.checkbox:SetEnabled(usingGlobal)

        for _, fn in ipairs(updaters) do
            fn(usingGlobal)
        end
    end

    overrideFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting("useGlobalAnimationSettings", self:GetChecked())
        UpdateAnimationState()
        SQP:RefreshAllNameplates()
    end)
    enabledFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting("globalAnimationEnabled", self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    taskFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting("animateQuestIcons", self:GetChecked())
        SQP:RefreshAllNameplates()
    end)

    UpdateAnimationState()
    if content.panel then
        content.panel:SetContentHeight(360)
    end
end

function SQP:CreateStyleOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 14, -12)
    header:SetText("|cffbc6fa8Nameplate Style|r")

    local topLeft = CreateSectionFrame(content, "Kill Nameplate", "TOPLEFT", content, 0, -40, 314, 248)
    local topRight = CreateSectionFrame(content, "Loot Nameplate", "TOPRIGHT", content, 0, -40, 314, 248)
    local bottom = CreateSectionFrame(content, "Percent Nameplate", "TOPLEFT", topLeft, 0, -256, 314, 230)

    local sections = {
        {frame = topLeft, objective = OBJECTIVES[1]},
        {frame = topRight, objective = OBJECTIVES[2]},
        {frame = bottom, objective = OBJECTIVES[3]},
    }

    for _, entry in ipairs(sections) do
        local frame = entry.frame
        local objective = entry.objective
        local yOffset = -32

        local showFrame = self:CreateStyledCheckbox(frame, "Show on nameplates")
        showFrame:SetPoint("TOPLEFT", 12, yOffset)
        showFrame.checkbox:SetChecked(SQPSettings[objective.showKey] ~= false)
        self.optionControls[objective.showKey] = showFrame.checkbox
        showFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting(objective.showKey, self:GetChecked())
            ActivatePreview(objective.preview)
            SQP:RefreshAllNameplates()
        end)
        yOffset = yOffset - 24

        yOffset = self:CreateDisplayStyleSection(frame, objective.key, function()
            ActivatePreview(objective.preview)
        end, yOffset)

        yOffset = CreateObjectiveColorControl(frame, objective, yOffset)
        yOffset = self:CreateMiniIconTintSection(frame, objective.key, function()
            ActivatePreview(objective.preview)
        end, yOffset)

        local rightColumn = CreateFrame("Frame", nil, frame)
        rightColumn:SetPoint("TOPLEFT", 166, -32)
        rightColumn:SetSize(136, 184)

        local rightOffset = 0
        rightOffset = self:CreateMainIconSection(rightColumn, objective.key, function()
            ActivatePreview(objective.preview)
        end, rightOffset, true)

    end

    if content.panel then
        content.panel:SetContentHeight(530)
    end
end

function SQP:CreateLayoutOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 14, -12)
    header:SetText("|cffbc6fa8Layout & Position|r")

    local globalSection = CreateSectionFrame(content, "Global Placement", "TOPLEFT", content, 0, -40, 314, 212)
    local typeSection = CreateSectionFrame(content, "Per-Objective Placement", "TOPRIGHT", content, 0, -40, 314, 336)

    local yOffset = -32
    yOffset = CreateCompactSlider(globalSection, "Global scale", "scale", 1.1, 0.5, 3.0, 0.1, yOffset, nil)
    yOffset = CreateCompactSlider(globalSection, "Main anchor offset X", "offsetX", 0, -100, 100, 1, yOffset, nil)
    yOffset = CreateCompactSlider(globalSection, "Main anchor offset Y", "offsetY", 3, -100, 100, 1, yOffset, nil)

    local anchorLabel = globalSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    anchorLabel:SetPoint("TOPLEFT", 12, yOffset)
    anchorLabel:SetText("Nameplate side")

    local leftBtn = self:CreateStyledButton(globalSection, "Left Side", 82, 18)
    local rightBtn = self:CreateStyledButton(globalSection, "Right Side", 82, 18)
    leftBtn:SetPoint("TOPLEFT", 12, yOffset - 18)
    rightBtn:SetPoint("LEFT", leftBtn, "RIGHT", 6, 0)

    local function UpdateAnchorButtons()
        leftBtn:SetAlpha(SQPSettings.anchor == "RIGHT" and 1 or 0.6)
        rightBtn:SetAlpha(SQPSettings.anchor == "LEFT" and 1 or 0.6)
    end

    leftBtn:SetScript("OnClick", function()
        SQP:SetSetting("anchor", "RIGHT")
        SQP:SetSetting("relativeTo", "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    rightBtn:SetScript("OnClick", function()
        SQP:SetSetting("anchor", "LEFT")
        SQP:SetSetting("relativeTo", "RIGHT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    UpdateAnchorButtons()

    local currentY = -32
    for _, objective in ipairs(OBJECTIVES) do
        local title = typeSection:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        title:SetPoint("TOPLEFT", 12, currentY)
        title:SetText("|cffbc6fa8" .. objective.title .. "|r")
        currentY = currentY - 18

        currentY = CreateCompactSlider(typeSection, "Size", objective.sizeKey, objective.sizeDefault, 8, 40, 1, currentY, objective.preview)
        currentY = CreateCompactSlider(typeSection, "Offset X", objective.offsetXKey, objective.offsetXDefault, -80, 80, 1, currentY, objective.preview)
        currentY = CreateCompactSlider(typeSection, "Offset Y", objective.offsetYKey, objective.offsetYDefault, -80, 80, 1, currentY, objective.preview)
        currentY = currentY - 6
    end

    if content.panel then
        content.panel:SetContentHeight(390)
    end
end
