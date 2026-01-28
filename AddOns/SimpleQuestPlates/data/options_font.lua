--=====================================================================================
-- RGX | Simple Quest Plates! - options_font.lua
-- Version: 1.0.0
-- Author: DonnieDice
-- Description: Font options tab content
--=====================================================================================

local addonName, SQP = ...

-- Create font settings section
function SQP:CreateFontOptions(content)
    -- Create two-column layout
    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(320)
    
    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)
    
    -- LEFT COLUMN - Font Settings
    local yOffset = -20
    
    -- Font section title
    local fontTitle = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontTitle:SetPoint("TOPLEFT", 20, yOffset)
    fontTitle:SetText("|cff58be81" .. (self.L["OPTIONS_FONT_SETTINGS"] or "Font Settings") .. "|r")
    yOffset = yOffset - 25
    
    -- Font Size
    local fontLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", 20, yOffset)
    fontLabel:SetText(self.L["OPTIONS_FONT_SIZE"] or "Font Size")
    
    local fontSlider = self:CreateStyledSlider(leftColumn, 8, 20, 1, 200)
    fontSlider:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -5)
    fontSlider:SetValue(SQPSettings.fontSize or 12)
    
    local fontValue = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fontValue:SetPoint("LEFT", fontSlider, "RIGHT", 10, 0)
    fontValue:SetText(tostring(SQPSettings.fontSize or 12))
    
    fontSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('fontSize', value)
        fontValue:SetText(tostring(value))
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 50  -- Condensed from 60
    
    -- Font Family Dropdown
    local fontFamilyLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontFamilyLabel:SetPoint("TOPLEFT", 20, yOffset)
    fontFamilyLabel:SetText(self.L["OPTIONS_FONT_FAMILY"] or "Font Family")
    yOffset = yOffset - 25
    
    -- Create dropdown frame
    local fontDropdown = CreateFrame("Frame", "SQPFontDropdown", leftColumn, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", 5, yOffset)
    UIDropDownMenu_SetWidth(fontDropdown, 180)
    
    -- Store reference for refresh
    self.optionControls.fontFamily = fontDropdown
    
    -- Font options
    local fontOptions = {
        {text = "Default", value = "GameFontNormal", font = "Fonts\\FRIZQT__.TTF"},
        {text = "Friz Quadrata", value = "FrizQuadrata", font = "Fonts\\FRIZQT__.TTF"},
        {text = "Arial", value = "Arial", font = "Fonts\\ARIALN.TTF"},
        {text = "Arial Narrow", value = "ArialN", font = "Fonts\\ARIALN.TTF"},
        {text = "Skurri", value = "Skurri", font = "Fonts\\SKURRI.TTF"},
        {text = "Morpheus", value = "Morpheus", font = "Fonts\\MORPHEUS.TTF"},
        {text = "2002 (Pixel)", value = "2002", font = "Fonts\\2002.TTF"},
        {text = "2002 Bold (Pixel)", value = "2002B", font = "Fonts\\2002B.TTF"},
        {text = "Nimrod MT", value = "NIM", font = "Fonts\\NIM_____.ttf"},
        {text = "Friend or Foe", value = "FRIZQT", font = "Fonts\\FRIENDS.TTF"},
        {text = "bLEI00D (Chinese)", value = "bLEI00D", font = "Fonts\\bLEI00D.TTF"},
        {text = "K_Damage (Korean)", value = "K_Damage", font = "Fonts\\K_Damage.TTF"},
        {text = "K_Pagetext (Korean)", value = "K_Pagetext", font = "Fonts\\K_Pagetext.TTF"},
    }
    
    -- Initialize dropdown
    local function InitializeFontDropdown(self, level)
        for _, option in ipairs(fontOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.value = option.value
            info.fontObject = CreateFont("TempFont")
            info.fontObject:SetFont(option.font, 12, "OUTLINE")
            info.func = function()
                SQP:SetSetting('fontFamily', option.font)
                UIDropDownMenu_SetText(fontDropdown, option.text)
                SQP:RefreshAllNameplates()
            end
            info.checked = (SQPSettings.fontFamily == option.font)
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    UIDropDownMenu_Initialize(fontDropdown, InitializeFontDropdown)
    
    -- Set current value
    local currentFont = SQPSettings.fontFamily or "Fonts\\FRIZQT__.TTF"
    for _, option in ipairs(fontOptions) do
        if option.font == currentFont then
            UIDropDownMenu_SetText(fontDropdown, option.text)
            break
        end
    end
    
    yOffset = yOffset - 40  -- Condensed from 50
    
    -- Outline Width
    local outlineLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    outlineLabel:SetPoint("TOPLEFT", 20, yOffset)
    outlineLabel:SetText(self.L["OPTIONS_OUTLINE_WIDTH"] or "Outline Width")
    yOffset = yOffset - 20  -- Condensed from 25
    
    -- Create outline buttons (only 3 options in WoW)
    local thinButton = self:CreateStyledButton(leftColumn, "None", 80, 25)
    thinButton:SetPoint("TOPLEFT", 20, yOffset)
    
    local normalButton = self:CreateStyledButton(leftColumn, "Normal", 80, 25)
    normalButton:SetPoint("LEFT", thinButton, "RIGHT", 5, 0)
    
    local thickButton = self:CreateStyledButton(leftColumn, "Thick", 80, 25)
    thickButton:SetPoint("LEFT", normalButton, "RIGHT", 5, 0)
    
    -- Create button state update function
    local function UpdateOutlineButtons()
        local width = SQPSettings.outlineWidth or 1
        thinButton:SetAlpha(width == 1 and 1 or 0.6)
        normalButton:SetAlpha(width == 2 and 1 or 0.6)
        thickButton:SetAlpha(width == 3 and 1 or 0.6)
    end
    
    -- Set button scripts
    
    thinButton:SetScript("OnClick", function()
        SQP:SetSetting('outlineWidth', 1)
        SQP:SetSetting('fontOutline', "")
        UpdateOutlineButtons()
        SQP:RefreshAllNameplates()
    end)
    
    normalButton:SetScript("OnClick", function()
        SQP:SetSetting('outlineWidth', 2)
        SQP:SetSetting('fontOutline', "OUTLINE")
        UpdateOutlineButtons()
        SQP:RefreshAllNameplates()
    end)
    
    thickButton:SetScript("OnClick", function()
        SQP:SetSetting('outlineWidth', 3)
        SQP:SetSetting('fontOutline', "THICKOUTLINE")
        UpdateOutlineButtons()
        SQP:RefreshAllNameplates()
    end)
    
    -- Set initial button states
    UpdateOutlineButtons()
    
    -- RIGHT COLUMN - Color Settings
    local rightYOffset = -20
    
    -- Color section title
    local colorTitle = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorTitle:SetPoint("TOPLEFT", 20, rightYOffset)
    colorTitle:SetText("|cff58be81" .. (self.L["OPTIONS_TEXT_COLORS"] or "Text Colors") .. "|r")
    rightYOffset = rightYOffset - 20  -- Condensed from 25
    
    -- Note: Custom colors always enabled
    
    -- Color pickers with reset buttons
    local function CreateColorPicker(parent, label, colorKey, x, y)
        local container = CreateFrame("Frame", nil, parent)
        container:SetSize(250, 25)
        container:SetPoint("TOPLEFT", x, y)
        
        local frame = CreateFrame("Button", nil, container)
        frame:SetSize(20, 20)
        frame:SetPoint("LEFT", 0, 0)
        
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 1)
        
        local swatch = frame:CreateTexture(nil, "ARTWORK")
        swatch:SetSize(16, 16)
        swatch:SetPoint("CENTER")
        local defaultColors = {
            killColor = {1, 0.82, 0},
            itemColor = {0.2, 1, 0.2},
            percentColor = {0.2, 1, 1}
        }
        local color = SQPSettings[colorKey] or defaultColors[colorKey]
        swatch:SetColorTexture(unpack(color))
        
        local text = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        text:SetPoint("LEFT", frame, "RIGHT", 5, 0)
        text:SetText(label)
        
        -- Reset button
        local resetBtn = self:CreateStyledButton(container, "Reset", 50, 20)
        resetBtn:SetPoint("RIGHT", container, "RIGHT", 0, 0)
        resetBtn:SetAlpha(0.8)
        resetBtn:SetScript("OnClick", function()
            _G.SQPSettings[colorKey] = defaultColors[colorKey]
            SQPSettings[colorKey] = defaultColors[colorKey]
            swatch:SetColorTexture(unpack(defaultColors[colorKey]))
            SQP:RefreshAllNameplates()
        end)
        
        frame:SetScript("OnClick", function()
            local r, g, b = unpack(SQPSettings[colorKey] or defaultColors[colorKey])
            
            local info = {}
            info.r = r
            info.g = g
            info.b = b
            info.hasOpacity = false
            info.swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                _G.SQPSettings[colorKey] = {r, g, b}
                SQPSettings[colorKey] = {r, g, b}
                swatch:SetColorTexture(r, g, b)
                SQP:RefreshAllNameplates()
            end
            info.cancelFunc = function()
                local prevR, prevG, prevB = r, g, b
                _G.SQPSettings[colorKey] = {prevR, prevG, prevB}
                SQPSettings[colorKey] = {prevR, prevG, prevB}
                swatch:SetColorTexture(prevR, prevG, prevB)
                SQP:RefreshAllNameplates()
            end
            
            ColorPickerFrame:SetupColorPickerAndShow(info)
        end)
        
        return container
    end
    
    -- Quest type colors (condensed spacing)
    CreateColorPicker(rightColumn, self.L["OPTIONS_COLOR_KILL"] or "Kill Quests", "killColor", 20, rightYOffset)
    CreateColorPicker(rightColumn, self.L["OPTIONS_COLOR_ITEM"] or "Item Quests", "itemColor", 20, rightYOffset - 25)
    CreateColorPicker(rightColumn, self.L["OPTIONS_COLOR_PERCENT"] or "Progress Quests", "percentColor", 20, rightYOffset - 50)
    rightYOffset = rightYOffset - 85  -- Space for reset button
    
    -- Reset Font Settings button (in right column)
    local resetFontBtn = self:CreateStyledButton(rightColumn, self.L["OPTIONS_RESET_FONT"] or "Reset Font Settings", 160, 30)
    resetFontBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    resetFontBtn:SetAlpha(0.8)
    resetFontBtn:SetScript("OnClick", function()
        -- Reset all font settings
        SQP:SetSetting('fontSize', 12)
        SQP:SetSetting('fontFamily', "Fonts\\FRIZQT__.TTF")
        SQP:SetSetting('fontOutline', "")
        SQP:SetSetting('outlineWidth', 1)
        SQP:SetSetting('killColor', {1, 0.82, 0})
        SQP:SetSetting('itemColor', {0.2, 1, 0.2})
        SQP:SetSetting('percentColor', {0.2, 1, 1})
        
        -- Update UI elements
        fontSlider:SetValue(12)
        fontValue:SetText("12")
        UIDropDownMenu_SetText(fontDropdown, "Default")
        UpdateOutlineButtons()
        
        -- Refresh all nameplates
        SQP:RefreshAllNameplates()
    end)
end