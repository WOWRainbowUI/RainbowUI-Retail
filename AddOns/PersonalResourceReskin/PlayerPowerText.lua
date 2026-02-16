-- Blizzard-style abbreviation data
local abbrevData = {
    breakpointData = {
        { breakpoint = 1e12, abbreviation = "B", significandDivisor = 1e10, fractionDivisor = 100, abbreviationIsGlobal = false },
        { breakpoint = 1e11, abbreviation = "B", significandDivisor = 1e9, fractionDivisor = 1, abbreviationIsGlobal = false },
        { breakpoint = 1e10, abbreviation = "B", significandDivisor = 1e8, fractionDivisor = 10, abbreviationIsGlobal = false },
        { breakpoint = 1e9, abbreviation = "B", significandDivisor = 1e7, fractionDivisor = 100, abbreviationIsGlobal = false },
        { breakpoint = 1e8, abbreviation = "M", significandDivisor = 1e6, fractionDivisor = 1, abbreviationIsGlobal = false },
        { breakpoint = 1e7, abbreviation = "M", significandDivisor = 1e5, fractionDivisor = 10, abbreviationIsGlobal = false },
        { breakpoint = 1e6, abbreviation = "M", significandDivisor = 1e4, fractionDivisor = 100, abbreviationIsGlobal = false },
        { breakpoint = 1e5, abbreviation = "K", significandDivisor = 1000, fractionDivisor = 1, abbreviationIsGlobal = false },
        { breakpoint = 1e4, abbreviation = "K", significandDivisor = 100, fractionDivisor = 10, abbreviationIsGlobal = false },
    },
}
-- PlayerPowerText.lua
-- PlayerPowerText: safe, taint-free player power text with options and lock/unlock dragging via slash commands.
-- Backdrop (white border + background) is shown only when unlocked.
-- SavedVariables: PlayerPowerTextDB (declare in the .toc)

local ADDON = "PlayerPowerText"

-- Default settings
local defaults = {
    anchorToPlayerFrame = false,
    snapToPRD = true, -- default: snap to Personal Resource Display Power Bar
    offsetX = 0,
    offsetY = 0,
    fontChoice = "GameFontNormal",
    fontSize = 14,
    fontOutline = "OUTLINE", -- new: font outline option ("NONE", "OUTLINE", "THICKOUTLINE", etc)
    color = {1, 1, 1},
    textFormat = "currentmax", -- "currentmax", "current", "percent"
    fadeWhenFull = true,
    fadeAlpha = 0.35,
    visibleAlpha = 1.0,
    locked = true, -- true = locked by default for new users
    hidden = false, -- false = shown by default
}

-- SavedVariables
PlayerPowerTextDB = PlayerPowerTextDB or {}

local function CopyDefaults(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            CopyDefaults(dest[k], v)
        else
            if dest[k] == nil then dest[k] = v end
        end
    end
end
CopyDefaults(PlayerPowerTextDB, defaults)


local prd = _G.PersonalResourceDisplayFrame
local powerBar = prd and prd.PowerBar
local text


if powerBar then
    text = powerBar:CreateFontString("PlayerPowerTextFontString", "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    text:SetText("")
    text:SetDrawLayer("OVERLAY")
    if text.SetFrameStrata then
        text:SetFrameStrata("HIGH")
    elseif text:GetParent() and text:GetParent().SetFrameStrata then
        text:GetParent():SetFrameStrata("HIGH")
    end
else
    print("|cff00ff80PlayerPowerText|r: 無法找到 PersonalResourceDisplayFrame.PowerBar!")
end




local PPT_EDITMODE_ACTIVE = false
local function PPT_Disable()
    PPT_EDITMODE_ACTIVE = true
    if text then text:SetText(""); text:Hide() end
    print("|cff00ff80PlayerPowerText|r: 打開編輯模式時停用")
end
local function PPT_Enable()
    PPT_EDITMODE_ACTIVE = false
    if text then text:Show() end
    ApplyDisplaySettings()
    UpdatePowerText()
    print("|cff00ff80PlayerPowerText|r: 關閉編輯模式後已啟用")
end



-- Use EditModeManagerFrame:RegisterCallback for Edit Mode handling (correct Blizzard API)
if EditModeManagerFrame and EditModeManagerFrame.RegisterCallback then
    EditModeManagerFrame:RegisterCallback("EditModeEnter", function()
        PPT_Disable()
    end)
    EditModeManagerFrame:RegisterCallback("EditModeExit", function()
        PPT_Enable()
        if PlayerPowerText_NeedsReanchor then
            AnchorToPowerBar()
        end
    end)
end



-- Safe helper to call functions that may return secret values; returns number or nil
local function SafeNumberCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then return nil end
    if type(res) == "number" then return res end
    local n = tonumber(res)
    if type(n) == "number" then return n end
    return nil
end

-- Safely read unit power values
-- Class/spec to power type mapping
local CLASS_SPEC_POWER_TYPE = {
    SHAMAN = {
        [262] = Enum and Enum.PowerType and Enum.PowerType.Maelstrom or 11, -- Elemental
        [263] = Enum and Enum.PowerType and Enum.PowerType.Mana or 0,      -- Enhancement
        [264] = Enum and Enum.PowerType and Enum.PowerType.Mana or 0,      -- Restoration
    },
    -- Add more classes/specs as needed
}
local function SafeGetUnitPower(unit)
    local cur = SafeNumberCall(UnitPower, unit)
    local max = SafeNumberCall(UnitPowerMax, unit)
    if cur == nil then
        cur = SafeNumberCall(UnitPower, unit, 0)
    end
    return cur, max
end

-- Safe font setter: prefer SetFontObject for built-in FontObjects, guard SetFont with pcall
function SafeSetFont(fs, fontChoice, size, fontFlags)
    if type(fontChoice) == "string" and _G[fontChoice] and type(_G[fontChoice]) == "table" then
        fs:SetFontObject(_G[fontChoice])
        pcall(function()
            local fontPath = fs:GetFont()
            if fontPath then fs:SetFont(fontPath, size, fontFlags ~= "NONE" and fontFlags or nil) end
        end)
    else
        local ok = pcall(function() fs:SetFont(fontChoice, size, fontFlags ~= "NONE" and fontFlags or nil) end)
        if not ok then
            fs:SetFontObject(GameFontNormal)
            pcall(function()
                local fontPath = fs:GetFont()
                if fontPath then fs:SetFont(fontPath, size, fontFlags ~= "NONE" and fontFlags or nil) end
            end)
        end
    end
end

function ApplyDisplaySettings()
    if PPT_EDITMODE_ACTIVE then
        if text then text:SetText(""); text:Hide() end
        return
    end
    local db = PlayerPowerTextDB
    -- Font and size
    local fontChoice = (type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.fontChoice) or db.fontChoice or defaults.fontChoice
    local fontPath = fontChoice
    if type(fontChoice) == "string" and LibStub and LibStub("LibSharedMedia-3.0", true) then
        local LSM = LibStub("LibSharedMedia-3.0")
        local lsmFont = LSM:Fetch("font", fontChoice)
        if lsmFont then
            fontPath = lsmFont
        else
            fontPath = LSM:Fetch("font", "Friz Quadrata TT")
        end
    end
    local fontOutline = (type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.fontOutline) or db.fontOutline or defaults.fontOutline or "OUTLINE"
    if fontPath then
        SafeSetFont(text, fontPath, db.fontSize or defaults.fontSize, fontOutline)
    end
    -- Color
    local color = (type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.color) or db.color or defaults.color
    local r, g, b = unpack(color)
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
        r, g, b = 1, 1, 1
    end
    if text and text.SetTextColor then
        text:SetTextColor(r, g, b)
    end
    if text then text:Show() end
end

function UpdatePowerText()
    if PPT_EDITMODE_ACTIVE then
        if text then text:SetText(""); text:Hide() end
        return
    end
    local db = PlayerPowerTextDB
    -- Support displayMode from PersonalResourceReskin.lua
    if type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.displayMode then
        db.textFormat = _G.PlayerPowerTextDB.displayMode
    end
    local profile = _G.PersonalResourceReskin and _G.PersonalResourceReskin.db and _G.PersonalResourceReskin.db.profile
    if profile and profile.hidden then
        if text then text:SetText(""); text:Hide() end
        return
    end
    if not UnitExists("player") then
        if text then text:SetText("") end
        return
    end

    local cur, max
    local _, class = UnitClass("player")
    local spec = GetSpecialization and GetSpecialization() or nil
    local powerType
    if class and CLASS_SPEC_POWER_TYPE[class] and spec and CLASS_SPEC_POWER_TYPE[class][spec] then
        powerType = CLASS_SPEC_POWER_TYPE[class][spec]
    end
    if powerType then
        cur = UnitPower("player", powerType)
        max = UnitPowerMax("player", powerType)
    else
        cur, max = SafeGetUnitPower("player")
    end
    local pct = nil
    if type(cur) == "number" and type(max) == "number" and max > 0 then
        local ok, result = pcall(function() return (cur / max) * 100 end)
        if ok and type(result) == "number" and result == result then
            pct = result
        end
    end

    -- Ensure font is applied before setting text to avoid "Font not set" taint
    ApplyDisplaySettings()

    if db.textFormat == "percent" and pct then
        text:SetFormattedText("%.0f%%", pct)
    elseif db.textFormat == "currentmax" and type(cur) == "number" and type(max) == "number" then
        if type(AbbreviateNumbers) == "function" then
            text:SetText(AbbreviateNumbers(cur, abbrevData) .. " / " .. AbbreviateNumbers(max, abbrevData))
        else
            text:SetFormattedText("%d / %d", cur, max)
        end
    elseif db.textFormat == "current" and type(cur) == "number" then
        if type(AbbreviateNumbers) == "function" then
            text:SetText(AbbreviateNumbers(cur, abbrevData))
        else
            text:SetFormattedText("%d", cur)
        end
    elseif db.textFormat == "both" and type(cur) == "number" and type(max) == "number" and pct then
        -- Show both current/max and percent
        if type(AbbreviateNumbers) == "function" then
            text:SetText(AbbreviateNumbers(cur, abbrevData) .. " / " .. AbbreviateNumbers(max, abbrevData) .. " (" .. string.format("%.0f%%", pct) .. ")")
        else
            text:SetFormattedText("%d / %d (%.0f%%)", cur, max, pct)
        end
    else
        text:SetText("")
    end

end

_G.UpdatePlayerPowerText = UpdatePowerText



do
    -- No-op: frame removed, nothing to anchor
end

-- Built-in FontObject choices (safe defaults)
local FONT_CHOICES = {
    { key = "GameFontNormal", label = "GameFontNormal" },
    { key = "GameFontNormalLarge", label = "GameFontNormalLarge" },
    { key = "GameFontHighlight", label = "GameFontHighlight" },
    { key = "GameFontDisable", label = "GameFontDisable" },
}

-- ---------- Options panel (created now, registered on PLAYER_LOGIN) ----------
local panel = CreateFrame("Frame", "PlayerPowerTextOptions", UIParent)
panel.name = "PlayerPowerText"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("PlayerPowerText Settings")



-- Anchor to PlayerFrame checkbox
local anchorCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
anchorCheck:SetPoint("TOPLEFT", snapCheck, "BOTTOMLEFT", 0, -8)
anchorCheck.Text:SetText("Anchor to PlayerFrame")
anchorCheck:SetScript("OnClick", function(self)
    PlayerPowerTextDB.anchorToPlayerFrame = self:GetChecked()
    ApplyDisplaySettings()
end)

local unlockCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
unlockCheck:SetPoint("TOPLEFT", anchorCheck, "BOTTOMLEFT", 0, -12)
unlockCheck.Text:SetText("Unlock to move (drag to place)")
unlockCheck:SetScript("OnClick", function(self)
    PlayerPowerTextDB.locked = not self:GetChecked()
    ApplyDisplaySettings()
end)

-- X slider (named to avoid nil GetName)
local xSlider = CreateFrame("Slider", "PlayerPowerText_XSlider", panel, "OptionsSliderTemplate")
xSlider:SetPoint("TOPLEFT", unlockCheck, "BOTTOMLEFT", 0, -24)
xSlider:SetWidth(260)
xSlider:SetMinMaxValues(-500, 500)
xSlider:SetValueStep(1)
xSlider:SetObeyStepOnDrag(true)
do
    local txt = _G["PlayerPowerText_XSliderText"]
    if txt then txt:SetText("Offset X") end
    local low = _G["PlayerPowerText_XSliderLow"]
    local high = _G["PlayerPowerText_XSliderHigh"]
    if low then low:SetText("-500") end
    if high then high:SetText("500") end
end
xSlider:SetScript("OnValueChanged", function(self, val)
    PlayerPowerTextDB.offsetX = math.floor(val + 0.5)
    ApplyDisplaySettings()
end)

-- Y slider (named)
local ySlider = CreateFrame("Slider", "PlayerPowerText_YSlider", panel, "OptionsSliderTemplate")
ySlider:SetPoint("TOPLEFT", xSlider, "BOTTOMLEFT", 0, -36)
ySlider:SetWidth(260)
ySlider:SetMinMaxValues(-500, 500)
ySlider:SetValueStep(1)
ySlider:SetObeyStepOnDrag(true)
do
    local txt = _G["PlayerPowerText_YSliderText"]
    if txt then txt:SetText("Offset Y") end
    local low = _G["PlayerPowerText_YSliderLow"]
    local high = _G["PlayerPowerText_YSliderHigh"]
    if low then low:SetText("-500") end
    if high then high:SetText("500") end
end
ySlider:SetScript("OnValueChanged", function(self, val)
    PlayerPowerTextDB.offsetY = math.floor(val + 0.5)
    ApplyDisplaySettings()
end)

-- Font dropdown
local fontLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
fontLabel:SetPoint("TOPLEFT", ySlider, "BOTTOMLEFT", 0, -24)
fontLabel:SetText("Font")

local fontDropdown = CreateFrame("Frame", "PlayerPowerTextFontDropdown", panel, "UIDropDownMenuTemplate")
fontDropdown:SetPoint("LEFT", fontLabel, "RIGHT", 10, 0)
UIDropDownMenu_SetWidth(fontDropdown, 160)

-- Font size slider
local sizeSlider = CreateFrame("Slider", "PlayerPowerText_SizeSlider", panel, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -36)
sizeSlider:SetWidth(260)
sizeSlider:SetMinMaxValues(8, 36)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
do
    local txt = _G["PlayerPowerText_SizeSliderText"]
    if txt then txt:SetText("Font Size") end
    local low = _G["PlayerPowerText_SizeSliderLow"]
    local high = _G["PlayerPowerText_SizeSliderHigh"]
    if low then low:SetText("8") end
    if high then high:SetText("36") end
end
sizeSlider:SetScript("OnValueChanged", function(self, val)
    PlayerPowerTextDB.fontSize = math.floor(val + 0.5)
    ApplyDisplaySettings()
end)

-- Color picker
local colorLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
colorLabel:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -24)
colorLabel:SetText("Text Color")

local colorButton = CreateFrame("Button", nil, panel)
colorButton:SetSize(24, 24)
colorButton:SetPoint("LEFT", colorLabel, "RIGHT", 10, 0)
colorButton.texture = colorButton:CreateTexture(nil, "BACKGROUND")
colorButton.texture:SetAllPoints()
local function UpdateColorButton()
    local r, g, b = unpack(PlayerPowerTextDB.color or defaults.color)
    if colorButton.texture.SetColorTexture then
        colorButton.texture:SetColorTexture(r, g, b, 1)
    else
        colorButton.texture:SetTexture(r, g, b, 1)
    end
end
UpdateColorButton()

colorButton:SetScript("OnClick", function()
    local r, g, b = unpack(PlayerPowerTextDB.color or defaults.color)
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame.func = function()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        PlayerPowerTextDB.color = {nr, ng, nb}
        UpdateColorButton()
        ApplyDisplaySettings()
    end
    ColorPickerFrame.cancelFunc = function(prev)
        local pr, pg, pb = prev.r, prev.g, prev.b
        PlayerPowerTextDB.color = {pr, pg, pb}
        UpdateColorButton()
        ApplyDisplaySettings()
    end
    ColorPickerFrame:Show()
end)



-- Text format dropdown
local formatLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
formatLabel:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 0, -36)
formatLabel:SetText("Text Format")

local formatDropdown = CreateFrame("Frame", "PlayerPowerTextFormatDropdown", panel, "UIDropDownMenuTemplate")
formatDropdown:SetPoint("TOPLEFT", formatLabel, "BOTTOMLEFT", 0, -8)
UIDropDownMenu_SetWidth(formatDropdown, 160)

local FORMAT_CHOICES = {
    { key = "currentmax", label = "Current / Max" },
    { key = "current", label = "Current Only" },
    { key = "percent", label = "Percent" },
}


-- Fade when full checkbox
local fadeCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
fadeCheck:SetPoint("TOPLEFT", formatDropdown, "BOTTOMLEFT", 0, -20)
fadeCheck.Text:SetText("Fade out when at full power")
fadeCheck:SetScript("OnClick", function(self)
    PlayerPowerTextDB.fadeWhenFull = self:GetChecked()
    local db = PlayerPowerTextDB
    local function abbr(val)
        if type(AbbreviateNumbers) == "function" and type(val) == "number" then
            return AbbreviateNumbers(val, abbrevData)
        end
        return tostring(val)
    end
end)

-- Fade alpha slider
local fadeSlider = CreateFrame("Slider", "PlayerPowerText_FadeSlider", panel, "OptionsSliderTemplate")
fadeSlider:SetPoint("TOPLEFT", fadeCheck, "BOTTOMLEFT", 0, -36)
fadeSlider:SetWidth(260)
fadeSlider:SetMinMaxValues(0.05, 1.0)
fadeSlider:SetValueStep(0.05)
fadeSlider:SetObeyStepOnDrag(true)
do
    local txt = _G["PlayerPowerText_FadeSliderText"]
    if txt then txt:SetText("Alpha when full") end
    local low = _G["PlayerPowerText_FadeSliderLow"]
    local high = _G["PlayerPowerText_FadeSliderHigh"]
    if low then low:SetText("0.05") end
    if high then high:SetText("1.0") end
end
fadeSlider:SetScript("OnValueChanged", function(self, val)
    PlayerPowerTextDB.fadeAlpha = tonumber(string.format("%.2f", val))
    UpdatePowerText()
end)

-- Reset button
local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
resetBtn:SetSize(140, 24)
resetBtn:SetText("Reset to Defaults")
resetBtn:SetScript("OnClick", function()
    PlayerPowerTextDB = {}
    CopyDefaults(PlayerPowerTextDB, defaults)
    if anchorCheck then anchorCheck:SetChecked(PlayerPowerTextDB.anchorToPlayerFrame) end
    if unlockCheck then unlockCheck:SetChecked(not PlayerPowerTextDB.locked) end
    if xSlider then xSlider:SetValue(PlayerPowerTextDB.offsetX) end
    if ySlider then ySlider:SetValue(PlayerPowerTextDB.offsetY) end
    if UIDropDownMenu_SetSelectedValue and fontDropdown then UIDropDownMenu_SetSelectedValue(fontDropdown, PlayerPowerTextDB.fontChoice) end
    if UIDropDownMenu_SetSelectedValue and formatDropdown then UIDropDownMenu_SetSelectedValue(formatDropdown, PlayerPowerTextDB.textFormat) end
    if sizeSlider then sizeSlider:SetValue(PlayerPowerTextDB.fontSize) end
    UpdateColorButton()
    if fadeCheck then fadeCheck:SetChecked(PlayerPowerTextDB.fadeWhenFull) end
    if fadeSlider then fadeSlider:SetValue(PlayerPowerTextDB.fadeAlpha) end
    ApplyDisplaySettings()
        text:SetText(abbr(cur) .. " / " .. abbr(max))
end)

panel.okay = function() end
panel.refresh = function()
    if anchorCheck then anchorCheck:SetChecked(PlayerPowerTextDB.anchorToPlayerFrame) end
    if unlockCheck then unlockCheck:SetChecked(not PlayerPowerTextDB.locked) end
    if xSlider then xSlider:SetValue(PlayerPowerTextDB.offsetX) end
    if ySlider then ySlider:SetValue(PlayerPowerTextDB.offsetY) end
    if UIDropDownMenu_SetSelectedValue and fontDropdown then UIDropDownMenu_SetSelectedValue(fontDropdown, PlayerPowerTextDB.fontChoice) end
    if UIDropDownMenu_SetSelectedValue and formatDropdown then UIDropDownMenu_SetSelectedValue(formatDropdown, PlayerPowerTextDB.textFormat) end
    if sizeSlider then sizeSlider:SetValue(PlayerPowerTextDB.fontSize) end
    UpdateColorButton()
    if fadeCheck then fadeCheck:SetChecked(PlayerPowerTextDB.fadeWhenFull) end
    if fadeSlider then fadeSlider:SetValue(PlayerPowerTextDB.fadeAlpha) end
end

-- Defer adding the options panel and initialize dropdown on PLAYER_LOGIN
local optionsRegistrar = CreateFrame("Frame")
optionsRegistrar:RegisterEvent("PLAYER_LOGIN")
optionsRegistrar:SetScript("OnEvent", function(self)
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end

    if UIDropDownMenu_Initialize and UIDropDownMenu_AddButton and UIDropDownMenu_SetSelectedValue then
        local function FontDropdown_OnClick(self)
            PlayerPowerTextDB.fontChoice = self.value
            UIDropDownMenu_SetSelectedValue(fontDropdown, self.value)
            ApplyDisplaySettings()
        end

        local function FontDropdown_Initialize(frame, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, f in ipairs(FONT_CHOICES) do
                info.text = f.label
                info.value = f.key
                info.func = FontDropdown_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end

        UIDropDownMenu_Initialize(fontDropdown, FontDropdown_Initialize)
        UIDropDownMenu_SetSelectedValue(fontDropdown, PlayerPowerTextDB.fontChoice)

        -- Format dropdown
        local function FormatDropdown_OnClick(self)
            PlayerPowerTextDB.textFormat = self.value
            UIDropDownMenu_SetSelectedValue(formatDropdown, self.value)
            UpdatePowerText()
        end

        local function FormatDropdown_Initialize(frame, level)
            local info = UIDropDownMenu_CreateInfo()
            for _, f in ipairs(FORMAT_CHOICES) do
                info.text = f.label
                info.value = f.key
                info.func = FormatDropdown_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end

        UIDropDownMenu_Initialize(formatDropdown, FormatDropdown_Initialize)
        UIDropDownMenu_SetSelectedValue(formatDropdown, PlayerPowerTextDB.textFormat)
    end

    if anchorCheck then anchorCheck:SetChecked(PlayerPowerTextDB.anchorToPlayerFrame) end
    if unlockCheck then unlockCheck:SetChecked(not PlayerPowerTextDB.locked) end
    if xSlider then xSlider:SetValue(PlayerPowerTextDB.offsetX) end
    if ySlider then ySlider:SetValue(PlayerPowerTextDB.offsetY) end
    if sizeSlider then sizeSlider:SetValue(PlayerPowerTextDB.fontSize) end
    UpdateColorButton()
    if fadeCheck then fadeCheck:SetChecked(PlayerPowerTextDB.fadeWhenFull) end
    if fadeSlider then fadeSlider:SetValue(PlayerPowerTextDB.fadeAlpha) end

    self:UnregisterEvent("PLAYER_LOGIN")
end)





-- Create a hidden event frame to update the text live
local pptEventFrame = CreateFrame("Frame")
pptEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
pptEventFrame:RegisterEvent("UNIT_MAXPOWER")
pptEventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
pptEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pptEventFrame:SetScript("OnEvent", function(self, event, unit)
    if (event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER") and unit ~= "player" then
        return
    end
    ApplyDisplaySettings()
    UpdatePowerText()
end)


-- Initial apply and update
ApplyDisplaySettings()
UpdatePowerText()

-- Listen for external font/color/fontFlags changes (from main config menu)
local lastFont, lastColor, lastFontFlags
local function MonitorExternalFontColor()
    local db = _G.PersonalResourceReskinDB and _G.PersonalResourceReskinDB.profile
    if db then
        -- Font
        if db.font and db.font ~= PlayerPowerTextDB.fontChoice then
            PlayerPowerTextDB.fontChoice = db.font
            ApplyDisplaySettings()
            UpdatePowerText()
        end
        -- Font color
        if db.fontColor and (not PlayerPowerTextDB.color or db.fontColor[1] ~= PlayerPowerTextDB.color[1] or db.fontColor[2] ~= PlayerPowerTextDB.color[2] or db.fontColor[3] ~= PlayerPowerTextDB.color[3]) then
            PlayerPowerTextDB.color = {db.fontColor[1], db.fontColor[2], db.fontColor[3]}
            ApplyDisplaySettings()
            UpdatePowerText()
        end
        -- Font style (fontFlags)
        if db.fontFlags and db.fontFlags ~= PlayerPowerTextDB.fontFlags then
            PlayerPowerTextDB.fontFlags = db.fontFlags
            ApplyDisplaySettings()
            UpdatePowerText()
        end
    end
    C_Timer.After(0.2, MonitorExternalFontColor)
end
C_Timer.After(1, MonitorExternalFontColor)

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local orig_ApplyDisplaySettings = ApplyDisplaySettings
function ApplyDisplaySettings()
    local db = PlayerPowerTextDB
    local fontFlags = db.fontFlags or (_G.PersonalResourceReskinDB and _G.PersonalResourceReskinDB.profile and _G.PersonalResourceReskinDB.profile.fontFlags) or "OUTLINE"
    local fontChoice = db.fontChoice
    if LSM and LSM:Fetch("font", fontChoice) then
        fontChoice = LSM:Fetch("font", fontChoice)
    end
    -- Font and size with style
    SafeSetFont(text, fontChoice or defaults.fontChoice, db.fontSize or defaults.fontSize, fontFlags)
    -- Color
    local r, g, b = unpack(db.color or defaults.color)
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
        r, g, b = unpack(defaults.color)
    end
    text:SetTextColor(r, g, b)
    -- No frame positioning or drag logic
end

function SafeSetFont(fs, fontChoice, size, fontFlags)
    if type(fontChoice) == "string" and _G[fontChoice] and type(_G[fontChoice]) == "table" then
        fs:SetFontObject(_G[fontChoice])
        pcall(function()
            local fontPath = fs:GetFont()
            if fontPath then fs:SetFont(fontPath, size, fontFlags ~= "NONE" and fontFlags or nil) end
        end)
    else
        local ok = pcall(function() fs:SetFont(fontChoice, size, fontFlags ~= "NONE" and fontFlags or nil) end)
        if not ok then
            fs:SetFontObject(GameFontNormal)
            pcall(function()
                local fontPath = fs:GetFont()
                if fontPath then fs:SetFont(fontPath, size, fontFlags ~= "NONE" and fontFlags or nil) end
            end)
        end
    end
end


-- Slash command to toggle PlayerPowerText visibility
SLASH_PLAYERPOWERTEXT1 = "/pptpower"
SlashCmdList["PLAYERPOWERTEXT"] = function(msg)
    if not PlayerPowerTextDB then PlayerPowerTextDB = {} end
    if msg == "show" then
        PlayerPowerTextDB.hidden = false
        if text then text:Show() end
        print("|cff00ff80PlayerPowerText|r: 能量文字會在重新載入後保持顯示。")
    elseif msg == "hide" then
        PlayerPowerTextDB.hidden = true
        if text then text:Hide() end
        print("|cff00ff80PlayerPowerText|r: 能量文字會在重新載入後保持隱藏。")
    else
        print("|cffffff00Usage: /pptpower show|hide|r")
    end
end

-- Hide/show logic in UpdatePowerText
local _UpdatePowerText = UpdatePowerText
function UpdatePowerText(...)
    if PlayerPowerTextDB and PlayerPowerTextDB.hidden then
        if text then text:SetText(""); text:Hide() end
        return
    end
    return _UpdatePowerText(...)
end
