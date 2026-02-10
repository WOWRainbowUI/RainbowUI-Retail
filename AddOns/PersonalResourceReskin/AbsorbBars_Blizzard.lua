-- Media textures 
local MediaTextures = {
    overabsorb = "Interface\\AddOns\\PersonalResourceReskin\\Media\\overabsorb",
    overshield = "Interface\\AddOns\\PersonalResourceReskin\\Media\\overshield",
    overshield_reversed = "Interface\\AddOns\\PersonalResourceReskin\\Media\\overshield_reversed",
    shield = "Interface\\AddOns\\PersonalResourceReskin\\Media\\shield",
    white8x8 = "Interface\\AddOns\\PersonalResourceReskin\\Media\\white8x8",
}

------------------------------------------------------------
-- SavedVariables
------------------------------------------------------------
AbsorbBarsBlizzard_Config = AbsorbBarsBlizzard_Config or {
    texture = "Blizzard",
    opacity = 0.8,
    x = 0,
    y = 0,
    fgColor = { r = 1, g = 1, b = 1 },      -- Foreground default: white
}

------------------------------------------------------------
-- LibSharedMedia
------------------------------------------------------------
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
-- Register custom Media textures with LSM
if LSM then
    LSM:Register("statusbar", "Overabsorb", MediaTextures.overabsorb)
    LSM:Register("statusbar", "Overshield", MediaTextures.overshield)
    LSM:Register("statusbar", "Overshield Reversed", MediaTextures.overshield_reversed)
    LSM:Register("statusbar", "Shield", MediaTextures.shield)
    LSM:Register("statusbar", "White8x8", MediaTextures.white8x8)
end
local function GetStatusBarTexture()
    if LSM and AbsorbBarsBlizzard_Config.texture then
        local tex = LSM:Fetch("statusbar", AbsorbBarsBlizzard_Config.texture, true)
        if tex then return tex end
    end
    return "Interface\\TargetingFrame\\UI-StatusBar"
end
local function GetLSMStatusBars()
    if not LSM then return {} end
    local list = LSM:List("statusbar")
    table.sort(list)
    return list
end

------------------------------------------------------------
-- Utilities
------------------------------------------------------------
local function SafeIsStatusBar(obj)
    return obj and obj.IsObjectType and obj:IsObjectType("StatusBar")
end

local function ApplyReverseFill(bar)
    if bar.SetReverseFill then
        bar:SetReverseFill(true)
    else
        local tex = bar:GetStatusBarTexture()
        if tex and tex.SetTexCoord then
            tex:SetTexCoord(1, 0, 0, 1)
        end
    end
end

local function FindHealthBar(frame)
    if frame and frame.HealthBarsContainer then
        local hb = frame.HealthBarsContainer.healthBar
        if SafeIsStatusBar(hb) then
            return hb
        end
    end
end

------------------------------------------------------------
-- Color Picker (safe for all builds)
------------------------------------------------------------
local function OpenColorPicker(colorTable, callback)
    if not ColorPickerFrame then return end

    ColorPickerFrame:Hide()
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.previousValues = { colorTable.r, colorTable.g, colorTable.b }

    -- Safe assignment for all builds
    ColorPickerFrame.func = nil
    ColorPickerFrame.swatchFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        colorTable.r, colorTable.g, colorTable.b = r, g, b
        if callback then callback() end
    end

    ColorPickerFrame.cancelFunc = function(prev)
        colorTable.r, colorTable.g, colorTable.b = prev[1], prev[2], prev[3]
        if callback then callback() end
    end

    -- Set initial color safely
    if ColorPickerFrame.SetColorRGB then
        ColorPickerFrame:SetColorRGB(colorTable.r, colorTable.g, colorTable.b)
    else
        ColorPickerFrame.previousValues = { colorTable.r, colorTable.g, colorTable.b }
    end

    ColorPickerFrame:Show()
end

------------------------------------------------------------
-- Create Absorb Bar
------------------------------------------------------------
local function CreateAbsorbBarForPRD()
    local frame = PersonalResourceDisplayFrame
    if not frame or frame.__blizzAbsorbBar then return end

    local healthBar = FindHealthBar(frame)
    if not healthBar then return end

    local tex = GetStatusBarTexture()

    -- Foreground absorb bar
    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetFrameLevel(healthBar:GetFrameLevel() + 200)
    bar:SetStatusBarTexture(tex)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    ApplyReverseFill(bar)
    bar:Show()
    bar:Raise()

    frame.__blizzAbsorbBar = bar

    --------------------------------------------------------
    -- Update function
    --------------------------------------------------------
    local function Update()
        if not bar or not healthBar then return end
        -- Hide absorb bar if health bar is hidden
        if not (healthBar and healthBar:IsShown() and healthBar:GetParent() and healthBar:GetParent():IsShown()) then
            bar:Hide()
            return
        end

        local maxHP = UnitHealthMax("player") or 1
        local absorb = UnitGetTotalAbsorbs("player") or 0
        local alpha = AbsorbBarsBlizzard_Config.opacity

        local c = AbsorbBarsBlizzard_Config.fgColor
        bar:SetStatusBarColor(c.r, c.g, c.b, alpha)

        local tex = GetStatusBarTexture()
        bar:SetStatusBarTexture(tex)

        bar:SetMinMaxValues(0, maxHP)
        bar:SetValue(absorb)

        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", AbsorbBarsBlizzard_Config.x or 0, AbsorbBarsBlizzard_Config.y or 0)
        bar:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", AbsorbBarsBlizzard_Config.x or 0, AbsorbBarsBlizzard_Config.y or 0)

        ApplyReverseFill(bar)
        bar:SetFrameLevel(healthBar:GetFrameLevel() + 200)
        bar:Raise()
        bar:Show()
    end

    bar.UpdateAbsorbBar = Update

    --------------------------------------------------------
    -- Events
    --------------------------------------------------------
    local ef = CreateFrame("Frame")
    ef:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    ef:RegisterEvent("UNIT_HEALTH")
    ef:RegisterEvent("PLAYER_ENTERING_WORLD")
    ef:RegisterEvent("PLAYER_LOGIN")
    ef:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    ef:SetScript("OnEvent", function(_, event, unit)
        if not unit or unit == "player" then
            Update()
        end
    end)

    Update()
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    C_Timer.After(1, CreateAbsorbBarForPRD)
end)

------------------------------------------------------------
-- Config UI
------------------------------------------------------------
SLASH_ABSORBBARSCONFIG1 = "/absorbbarconfig"
local configFrame

local function CreateTextureDropdown(parent, yOffset)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", -10, yOffset)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    label:SetText("Statusbar Texture")
    local function OnClick(self)
        UIDropDownMenu_SetSelectedValue(dropdown, self.value)
        AbsorbBarsBlizzard_Config.texture = self.value
        PersonalResourceDisplayFrame.__blizzAbsorbBar.UpdateAbsorbBar()
    end
    UIDropDownMenu_Initialize(dropdown, function()
        local info = UIDropDownMenu_CreateInfo()
        for _, name in ipairs(GetLSMStatusBars()) do
            info.value = name
            info.func = OnClick
            -- Always show only the filename, not the full path
            local filename = name:match("[^\\/]+$") or name
            -- If the filename doesn't have an extension, add .tga for custom textures
            if filename == "Overabsorb" then filename = "overabsorb.tga" end
            if filename == "Overshield" then filename = "overshield.tga" end
            if filename == "Overshield Reversed" then filename = "overshield_reversed.tga" end
            if filename == "Shield" then filename = "shield.tga" end
            if filename == "White8x8" then filename = "white8x8.tga" end
            info.text = filename
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetWidth(dropdown, 200)
    UIDropDownMenu_SetSelectedValue(dropdown, AbsorbBarsBlizzard_Config.texture)
end

SlashCmdList["ABSORBBARSCONFIG"] = function()
    if configFrame and configFrame:IsShown() then
        configFrame:Hide()
        return
    end

    if not configFrame then
        configFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
        configFrame:SetSize(360, 290)
        configFrame:SetPoint("CENTER")
        configFrame:SetMovable(true)
        configFrame:EnableMouse(true)
        configFrame:RegisterForDrag("LeftButton")
        configFrame:SetScript("OnDragStart", configFrame.StartMoving)
        configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
        configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        configFrame.title:SetPoint("LEFT", configFrame.TitleBg, "LEFT", 5, 0)
        configFrame.title:SetText("Absorb Bar Settings")

        -- Opacity slider
        local opacity = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
        opacity:SetSize(240, 20)
        opacity:SetPoint("TOP", 0, -40)
        opacity:SetMinMaxValues(0.1, 1.0)
        opacity:SetValueStep(0.01)
        opacity:SetValue(AbsorbBarsBlizzard_Config.opacity)
        opacity.Text:SetText("Opacity")
        opacity:SetScript("OnValueChanged", function(_, v)
            AbsorbBarsBlizzard_Config.opacity = v
            PersonalResourceDisplayFrame.__blizzAbsorbBar.UpdateAbsorbBar()
        end)

        -- X offset
        local xSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
        xSlider:SetSize(240, 20)
        xSlider:SetPoint("TOP", opacity, "BOTTOM", 0, -20)
        xSlider:SetMinMaxValues(-500, 500)
        xSlider:SetValue(AbsorbBarsBlizzard_Config.x)
        xSlider.Text:SetText("X Offset")
        xSlider:SetScript("OnValueChanged", function(_, v)
            AbsorbBarsBlizzard_Config.x = v
            PersonalResourceDisplayFrame.__blizzAbsorbBar.UpdateAbsorbBar()
        end)

        -- Y offset
        local ySlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
        ySlider:SetSize(240, 20)
        ySlider:SetPoint("TOP", xSlider, "BOTTOM", 0, -20)
        ySlider:SetMinMaxValues(-500, 500)
        ySlider:SetValue(AbsorbBarsBlizzard_Config.y)
        ySlider.Text:SetText("Y Offset")
        ySlider:SetScript("OnValueChanged", function(_, v)
            AbsorbBarsBlizzard_Config.y = v
            PersonalResourceDisplayFrame.__blizzAbsorbBar.UpdateAbsorbBar()
        end)

        -- Foreground color picker
        local fgBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
        fgBtn:SetSize(140, 22)
        fgBtn:SetPoint("TOPLEFT", ySlider, "BOTTOMLEFT", 0, -12)
        fgBtn:SetText("Foreground Color")
        fgBtn:SetScript("OnClick", function()
            OpenColorPicker(AbsorbBarsBlizzard_Config.fgColor, PersonalResourceDisplayFrame.__blizzAbsorbBar.UpdateAbsorbBar)
        end)

        -- Reset to white button
        local resetBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
        resetBtn:SetSize(120, 22)
        resetBtn:SetPoint("RIGHT", fgBtn, "BOTTOM", 0, -90)
        resetBtn:SetText("Reset Colors")
        resetBtn:SetScript("OnClick", function()
            AbsorbBarsBlizzard_Config.fgColor = { r = 1, g = 1, b = 1 }
            AbsorbBarsBlizzard_Config.opacity = 1.0
            PersonalResourceDisplayFrame.__blizzAbsorbBar.UpdateAbsorbBar()
        end)

        -- Texture dropdown
        if LSM then
            CreateTextureDropdown(configFrame, -210)
        end

    end

    configFrame:Show()
end
