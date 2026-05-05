-- PlayerPowerText.lua
-- PlayerPowerText: safe, taint-free player power text with options and lock/unlock dragging via slash commands.
-- Backdrop (white border + background) is shown only when unlocked.
-- SavedVariables: PlayerPowerTextDB (declare in the .toc)

local ADDON = "PlayerPowerText"

-- Forward-declare locals so the two function definitions below assign to these
-- locals instead of the GLOBAL `ApplyDisplaySettings` (which is also defined by
-- PlayerHealthText.lua and would otherwise be overwritten by it, breaking power
-- text font/size restoration on /reload).
local ApplyDisplaySettings
local SafeSetFont

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
-- DEBUG: log what was loaded from SavedVariables BEFORE CopyDefaults touches it
do
    local existing = rawget(_G, "PlayerPowerTextDB")
    if type(existing) == "table" then
        print(string.format("|cffff8800[PPT DEBUG]|r SV loaded: fontSize=%s (type=%s)", tostring(existing.fontSize), type(existing.fontSize)))
    else
        print(string.format("|cffff8800[PPT DEBUG]|r SV NOT LOADED (PlayerPowerTextDB is %s) — TOC SavedVariables may be broken", type(existing)))
    end
end

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
print(string.format("|cffff8800[PPT DEBUG]|r After CopyDefaults: fontSize=%s", tostring(PlayerPowerTextDB.fontSize)))

-- Trap any subsequent overwrite of PlayerPowerTextDB.fontSize
do
    local realDB = PlayerPowerTextDB
    local proxy = setmetatable({}, {
        __index = realDB,
        __newindex = function(t, k, v)
            if k == "fontSize" then
                local old = rawget(realDB, "fontSize")
                if old ~= v then
                    print(string.format("|cffff0000[PPT TRAP]|r fontSize change: %s -> %s", tostring(old), tostring(v)))
                    print(debugstack(2, 5, 0))
                end
            end
            rawset(realDB, k, v)
        end,
        __pairs = function() return pairs(realDB) end,
    })
    -- Note: replacing the global with a proxy table breaks SavedVariables persistence
    -- because WoW serializes _G.PlayerPowerTextDB by table identity. So instead of
    -- using a proxy, we'll just hook the slash command path with explicit logging.
    -- (Proxy disabled — keeping realDB as the global.)
end


-- Deferred: frames may not exist at load time
local prd, powerBar, text

local function EnsurePowerTextCreated()
    if text then return true end
    prd = _G.PersonalResourceDisplayFrame
    powerBar = prd and prd.PowerBar
    if powerBar then
        text = powerBar:CreateFontString("PlayerPowerTextFontString", "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
        text:SetText("")
        text:SetDrawLayer("OVERLAY")
        if text:GetParent() and text:GetParent().SetFrameStrata then
            text:GetParent():SetFrameStrata("HIGH")
        end
        return true
    end
    return false
end




local PPT_EDITMODE_ACTIVE = false
local function PPT_Disable()
    PPT_EDITMODE_ACTIVE = true
    -- Show a static preview so the font size slider is usable during Edit Mode
    if EnsurePowerTextCreated() then
        ApplyDisplaySettings()
        if text then text:SetText("100 / 100"); text:Show() end
    end
end
local function PPT_Enable()
    PPT_EDITMODE_ACTIVE = false
    if text then text:Show() end
    ApplyDisplaySettings()
    UpdatePowerText()
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

-- Safe font setter: always resolve to a font path so the custom size is respected
function SafeSetFont(fs, fontChoice, size, fontFlags)
    local flags = (fontFlags and fontFlags ~= "NONE") and fontFlags or nil
    if type(fontChoice) == "string" and _G[fontChoice] and type(_G[fontChoice]) == "table" then
        local fontObj = _G[fontChoice]
        local path = fontObj.GetFont and fontObj:GetFont() or nil
        if path then
            local ok = pcall(function() fs:SetFont(path, size, flags) end)
            if not ok then fs:SetFontObject(fontObj) end
            return
        end
        fs:SetFontObject(fontObj)
        pcall(function()
            local p = fs:GetFont()
            if p then fs:SetFont(p, size, flags) end
        end)
    else
        local ok = pcall(function() fs:SetFont(fontChoice, size, flags) end)
        if not ok then
            local fallbackPath = GameFontNormal.GetFont and GameFontNormal:GetFont() or "Fonts\\FRIZQT__.TTF"
            pcall(function() fs:SetFont(fallbackPath, size, flags) end)
        end
    end
end

ApplyDisplaySettings = function()
    if not EnsurePowerTextCreated() then return end
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
    if not EnsurePowerTextCreated() then return end
    if PPT_EDITMODE_ACTIVE then
        -- In Edit Mode: keep preview text, just re-apply font settings
        ApplyDisplaySettings()
        if text then text:SetText("100 / 100"); text:Show() end
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
        cur = SafeNumberCall(UnitPower, "player", powerType)
        max = SafeNumberCall(UnitPowerMax, "player", powerType)
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

    if db.textFormat == "percent" and pct then
        text:SetFormattedText("%.0f%%", pct)
    elseif db.textFormat == "currentmax" and type(cur) == "number" and type(max) == "number" then
        if type(AbbreviateNumbers) == "function" then
            text:SetText(AbbreviateNumbers(cur) .. " / " .. AbbreviateNumbers(max))
        else
            text:SetFormattedText("%d / %d", cur, max)
        end
    elseif db.textFormat == "current" and type(cur) == "number" then
        if type(AbbreviateNumbers) == "function" then
            text:SetText(AbbreviateNumbers(cur))
        else
            text:SetFormattedText("%d", cur)
        end
    elseif db.textFormat == "both" and type(cur) == "number" and type(max) == "number" and pct then
        -- Show both current/max and percent
        if type(AbbreviateNumbers) == "function" then
            text:SetText(AbbreviateNumbers(cur) .. " / " .. AbbreviateNumbers(max) .. " (" .. string.format("%.0f%%", pct) .. ")")
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
sizeSlider:SetMinMaxValues(8, 100)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
do
    local txt = _G["PlayerPowerText_SizeSliderText"]
    if txt then txt:SetText("Font Size") end
    local low = _G["PlayerPowerText_SizeSliderLow"]
    local high = _G["PlayerPowerText_SizeSliderHigh"]
    if low then low:SetText("8") end
    if high then high:SetText("100") end
end
sizeSlider:SetScript("OnValueChanged", function(self, val)
    if self._initializing then return end
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
            return AbbreviateNumbers(val)
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
    if self._initializing then return end
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
    if sizeSlider then sizeSlider._initializing = true; sizeSlider:SetValue(PlayerPowerTextDB.fontSize); sizeSlider._initializing = false end
    UpdateColorButton()
    if fadeCheck then fadeCheck:SetChecked(PlayerPowerTextDB.fadeWhenFull) end
    if fadeSlider then fadeSlider._initializing = true; fadeSlider:SetValue(PlayerPowerTextDB.fadeAlpha); fadeSlider._initializing = false end
    ApplyDisplaySettings()
    UpdatePowerText()
end)

panel.okay = function() end
panel.refresh = function()
    if anchorCheck then anchorCheck:SetChecked(PlayerPowerTextDB.anchorToPlayerFrame) end
    if unlockCheck then unlockCheck:SetChecked(not PlayerPowerTextDB.locked) end
    if xSlider then xSlider:SetValue(PlayerPowerTextDB.offsetX) end
    if ySlider then ySlider:SetValue(PlayerPowerTextDB.offsetY) end
    if UIDropDownMenu_SetSelectedValue and fontDropdown then UIDropDownMenu_SetSelectedValue(fontDropdown, PlayerPowerTextDB.fontChoice) end
    if UIDropDownMenu_SetSelectedValue and formatDropdown then UIDropDownMenu_SetSelectedValue(formatDropdown, PlayerPowerTextDB.textFormat) end
    if sizeSlider then sizeSlider._initializing = true; sizeSlider:SetValue(PlayerPowerTextDB.fontSize); sizeSlider._initializing = false end
    UpdateColorButton()
    if fadeCheck then fadeCheck:SetChecked(PlayerPowerTextDB.fadeWhenFull) end
    if fadeSlider then fadeSlider._initializing = true; fadeSlider:SetValue(PlayerPowerTextDB.fadeAlpha); fadeSlider._initializing = false end
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
    if sizeSlider then sizeSlider._initializing = true; sizeSlider:SetValue(PlayerPowerTextDB.fontSize); sizeSlider._initializing = false end
    UpdateColorButton()
    if fadeCheck then fadeCheck:SetChecked(PlayerPowerTextDB.fadeWhenFull) end
    if fadeSlider then fadeSlider._initializing = true; fadeSlider:SetValue(PlayerPowerTextDB.fadeAlpha); fadeSlider._initializing = false end

    self:UnregisterEvent("PLAYER_LOGIN")
end)





-- Create a hidden event frame to update the text live
local pptEventFrame = CreateFrame("Frame")
pptEventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
pptEventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
pptEventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
pptEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
pptEventFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyDisplaySettings()
    end
    UpdatePowerText()
end)


-- Initial display settings only; UpdatePowerText() deferred to PLAYER_ENTERING_WORLD
ApplyDisplaySettings()

-- Listen for external font/color/fontFlags changes (from main config menu)
local lastFont, lastColor, lastFontFlags
local function MonitorExternalFontColor()
    -- Use the AceDB proxy object (PersonalResourceReskin.db.profile), NOT the raw
    -- _G.PersonalResourceReskinDB.profile which is always nil in AceDB.
    local db = _G.PersonalResourceReskin and _G.PersonalResourceReskin.db and _G.PersonalResourceReskin.db.profile
    if db then
        -- Font
        if db.font and db.font ~= PlayerPowerTextDB.fontChoice then
            PlayerPowerTextDB.fontChoice = db.font
            ApplyDisplaySettings()
            UpdatePowerText()
        end
        -- Font size: do NOT sync from AceDB here — the /prr slider set function
        -- already writes directly to PlayerPowerTextDB.fontSize. Syncing from AceDB
        -- would overwrite the saved value if AceDB defaults differ.
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
    C_Timer.After(2, MonitorExternalFontColor)
end
C_Timer.After(2, MonitorExternalFontColor)

local _LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
function ApplyDisplaySettings()
    if not EnsurePowerTextCreated() then return end
    local db = PlayerPowerTextDB
    -- PlayerPowerTextDB.fontSize is the single source of truth; it is written by
    -- both the /prr slider set function and by MonitorExternalFontColor.
    local size = db.fontSize or defaults.fontSize
    local fontFlags = db.fontFlags or "OUTLINE"
    local flags = (fontFlags ~= "NONE") and fontFlags or nil

    -- Resolve to an actual font file path.
    -- "GameFontNormal" etc. are FontObject names, not paths — LSM won't find them.
    -- Fall straight through to the hardcoded WoW built-in path in that case.
    local fontPath
    if _LSM then
        fontPath = _LSM:Fetch("font", db.fontChoice or defaults.fontChoice)
    end
    if not fontPath then
        -- "Fonts\FRIZQT__.TTF" is the file GameFontNormal uses and always exists in WoW
        fontPath = "Fonts\\FRIZQT__.TTF"
    end

    -- Direct SetFont — no pcall, so any real error will be visible in the log
    text:SetFont(fontPath, size, flags)

    -- Color
    local r, g, b = unpack(db.color or defaults.color)
    if type(r) == "number" and type(g) == "number" and type(b) == "number" then
        text:SetTextColor(r, g, b)
    end
    text:Show()
end

SafeSetFont = function(fs, fontChoice, size, fontFlags)
    local flags = (fontFlags and fontFlags ~= "NONE") and fontFlags or nil
    -- Resolve FontObject name to an actual font path so SetFont works with our custom size
    if type(fontChoice) == "string" and _G[fontChoice] and type(_G[fontChoice]) == "table" then
        local fontObj = _G[fontChoice]
        local path = fontObj.GetFont and fontObj:GetFont() or nil
        if path then
            local ok = pcall(function() fs:SetFont(path, size, flags) end)
            if not ok then
                fs:SetFontObject(fontObj)
            end
            return
        end
        -- fallback: set the object then immediately override size
        fs:SetFontObject(fontObj)
        pcall(function()
            local p = fs:GetFont()
            if p then fs:SetFont(p, size, flags) end
        end)
    else
        local ok = pcall(function() fs:SetFont(fontChoice, size, flags) end)
        if not ok then
            -- last resort: use default font path
            local fallbackPath = GameFontNormal.GetFont and GameFontNormal:GetFont() or "Fonts\\FRIZQT__.TTF"
            pcall(function() fs:SetFont(fallbackPath, size, flags) end)
        end
    end
end


-- Slash command to toggle PlayerPowerText visibility and size
SLASH_PLAYERPOWERTEXT1 = "/pptpower"
SlashCmdList["PLAYERPOWERTEXT"] = function(msg)
    if not PlayerPowerTextDB then PlayerPowerTextDB = {} end
    msg = (msg or ""):lower():match("^%s*(.-)%s*$") -- trim
    if msg == "show" then
        PlayerPowerTextDB.hidden = false
        if text then text:Show() end
        print("|cff00ff80PlayerPowerText|r: Power text shown.")
    elseif msg == "hide" then
        PlayerPowerTextDB.hidden = true
        if text then text:Hide() end
        print("|cff00ff80PlayerPowerText|r: Power text hidden.")
    elseif msg == "size+" then
        PlayerPowerTextDB.fontSize = math.min(72, (PlayerPowerTextDB.fontSize or 14) + 1)
        ApplyDisplaySettings()
        print("|cff00ff80PlayerPowerText|r: Font size " .. PlayerPowerTextDB.fontSize)
    elseif msg == "size-" then
        PlayerPowerTextDB.fontSize = math.max(6, (PlayerPowerTextDB.fontSize or 14) - 1)
        ApplyDisplaySettings()
        print("|cff00ff80PlayerPowerText|r: Font size " .. PlayerPowerTextDB.fontSize)
    elseif msg:match("^size%s+(%d+)$") then
        local val = tonumber(msg:match("^size%s+(%d+)$"))
        if val and val >= 6 and val <= 72 then
            PlayerPowerTextDB.fontSize = val
            ApplyDisplaySettings()
            print("|cff00ff80PlayerPowerText|r: Font size " .. val)
        else
            print("|cffffff00PlayerPowerText|r: Size must be between 6 and 72.")
        end
    else
        print("|cffffff00/pptpower|r: show | hide | size <6-72> | size+ | size-")
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
