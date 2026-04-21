
-- SavedVariables
PlayerHealthTextDB = PlayerHealthTextDB or {}

local defaults = {
    offsetX = 0,
    offsetY = 0,
    fontChoice = "GameFontNormal",
    fontSize = 14,
    fontFlags = "OUTLINE",
    color = {1, 1, 1},
    displayMode = "both",
    visibleAlpha = 1.0,
    showAbsorbs = false,
}

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
CopyDefaults(PlayerHealthTextDB, defaults)

-- Safe helpers --------------------------------------------------------------

local function safe_tonumber(v)
    if type(v) == "number" then return v end
    local ok, n = pcall(tonumber, v)
    if ok and type(n) == "number" then return n end
    return nil
end



-- UnitHealthPercent returns a secret number (0.0–1.0 range).
-- We cannot do any Lua arithmetic or string.format on secret numbers.
-- Store it raw; format via text:SetFormattedText (C++) at display time.
local function SafeUnitHealthPercent(unit)
    if type(UnitHealthPercent) == "function" then
        local curve = _G.CurveConstants and _G.CurveConstants.ScaleTo100 or nil
        local ok, val = pcall(UnitHealthPercent, unit, false, curve)
        if ok and type(val) == "number" then
            return val -- already scaled to 0-100 when curve is available
        end
    end
    return nil
end

local function SafeNumbers(unit)
    local ok1, cur = pcall(UnitHealth, unit)
    local ok2, max = pcall(UnitHealthMax, unit)
    if not ok1 or not ok2 then return nil, nil end
    if type(cur) ~= "number" or type(max) ~= "number" then return nil, nil end
    return cur, max
end

local function FormatText(style, cur, max, pct)
    local function abbr(val)
        if type(AbbreviateNumbers) == "function" and type(val) == "number" then
            return AbbreviateNumbers(val)
        end
        return tostring(val)
    end
    -- pct is a secret number (0.0–1.0); format percentage via SetFormattedText at display time
    -- These helpers return strings for non-percent parts only
    if style == "percent" then
        return nil  -- caller must use SetFormattedText
    elseif style == "both" then
        if type(cur) ~= "number" then return "?" end
        return nil  -- caller must use SetFormattedText
    elseif style == "both_reverse" then
        if type(cur) ~= "number" then return "?" end
        return nil  -- caller must use SetFormattedText
    elseif style == "currentmax" then
        if type(cur) ~= "number" or type(max) ~= "number" then return "?" end
        return abbr(cur) .. " / " .. abbr(max)
    elseif style == "current" then
        if type(cur) ~= "number" then return "?" end
        return abbr(cur)
    end
end
-- Add abbreviation style option to SavedVariables and default



-- Attach health text directly to PRD health bar, like PlayerPowerText
-- Deferred: frames may not exist at load time
local prd, healthBar, text

local function EnsureHealthTextCreated()
    if text then return true end
    prd = _G.PersonalResourceDisplayFrame
    healthBar = prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar
    if healthBar and healthBar.CreateFontString then
        healthBar:SetFrameStrata("MEDIUM")
        text = healthBar:CreateFontString("PlayerHealthTextFontString", "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        text:SetJustifyH("CENTER")
        if text.SetJustifyV then text:SetJustifyV("MIDDLE") end
        text:SetText("")
        return true
    end
    return false
end

-- Safe helpers
local function SafeNumberCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then return nil end
    if type(res) == "number" then return res end
    local n = tonumber(res)
    if type(n) == "number" then return n end
    return nil
end

local function SafeGetUnitHealth(unit)
    local cur = SafeNumberCall(UnitHealth, unit)
    local max = SafeNumberCall(UnitHealthMax, unit)
    return cur, max
end

local function AppendAbsorbSuffix(unit)
    if not (PlayerHealthTextDB and PlayerHealthTextDB.showAbsorbs) then return end
    local absorb = UnitGetTotalAbsorbs(unit)
    if type(absorb) ~= "number" then return end
    local okAbs, absText = pcall(AbbreviateNumbers, absorb)
    if not okAbs or not absText then return end
    local okBase, baseText = pcall(text.GetText, text)
    if not okBase then return end
    local okFmt = pcall(text.SetFormattedText, text, "%s +%s", baseText or "", absText)
    if not okFmt then
        pcall(text.SetText, text, absText)
    end
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


function ApplyDisplaySettings()
    if not EnsureHealthTextCreated() then return end
    local db = PlayerHealthTextDB
    -- Font and size — use own DB, not PlayerPowerTextDB
    local fontChoice = db.fontChoice or defaults.fontChoice
    local fontFlags = db.fontFlags or "OUTLINE"
    SafeSetFont(text, fontChoice, db.fontSize or defaults.fontSize, fontFlags)
    -- Color — use own DB
    local color = db.color or defaults.color
    local r, g, b = unpack(color)
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
        r, g, b = unpack(defaults.color)
    end
    text:SetTextColor(r, g, b)
    -- Set position based on dropdown
    text:ClearAllPoints()
    local pos = db.textPosition or "center"
    if pos == "left" then
        text:SetPoint("LEFT", healthBar, "LEFT", 4, 0)
        text:SetJustifyH("LEFT")
    elseif pos == "right" then
        text:SetPoint("RIGHT", healthBar, "RIGHT", -4, 0)
        text:SetJustifyH("RIGHT")
    else
        text:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        text:SetJustifyH("CENTER")
    end
    if text.SetJustifyV then text:SetJustifyV("MIDDLE") end
    local alpha = db.visibleAlpha or 1.0
    text:SetAlpha(alpha)
    if alpha <= 0 then
        text:Hide()
    else
        text:Show()
    end
end


function UpdateHealthText()
    if not EnsureHealthTextCreated() then return end
    -- Respect user hide state from buttons/options.
    local db = PlayerHealthTextDB or {}
    if (db.visibleAlpha or 1.0) <= 0 then
        if text then text:Hide() end
        return
    end
    if not UnitExists("player") then
        if text then text:SetText(""); text:Hide() end
        return
    end
    -- Hide health text if PRD health bar is hidden
    if healthBar and not healthBar:IsShown() then
        if text then text:Hide() end
        return
    end
    if UnitIsDeadOrGhost("player") then
        if text then text:SetText("Dead"); text:Show() end
        return
    end
    -- Anchor to selected position
    local db = PlayerHealthTextDB or {}
    text:ClearAllPoints()
    local pos = db.textPosition or "center"
    if pos == "left" then
        text:SetPoint("LEFT", healthBar, "LEFT", 4, 0)
        text:SetJustifyH("LEFT")
    elseif pos == "right" then
        text:SetPoint("RIGHT", healthBar, "RIGHT", -4, 0)
        text:SetJustifyH("RIGHT")
    else
        text:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
        text:SetJustifyH("CENTER")
    end
    if text.SetJustifyV then text:SetJustifyV("MIDDLE") end
    local okRender = pcall(function()
        local Unit = "player"
        local Percent = SafeUnitHealthPercent(Unit)
        local Current, Max = SafeGetUnitHealth(Unit)
        local displayMode = PlayerHealthTextDB and PlayerHealthTextDB.displayMode or "percent"
        if displayMode == "absorbs" then
            local absorb = UnitGetTotalAbsorbs(Unit)
            local function abbr(val)
                if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                    return AbbreviateNumbers(val)
                end
                return tostring(val)
            end
            local textStr = "Absorbs " .. abbr(absorb)
            text:SetText(textStr)
        elseif displayMode == "full" or displayMode == "bothfull" then
            local calculator = _G.UnitHealPredictionCalculator and _G.UnitHealPredictionCalculator.Create and _G.UnitHealPredictionCalculator:Create(Unit)
            local incomingHeals, damageAbsorbs, healAbsorbs = 0, 0, 0
            if calculator then
                calculator:ResetPredictedValues()
                local predictedValues = calculator:GetPredictedValues()
                calculator:SetToDefaults()
                calculator:SetPredictedValues(predictedValues)
                calculator:SetIncomingHealOverflowPercent(0)
                calculator:SetIncomingHealClampMode(calculator:GetIncomingHealClampMode())
                calculator:SetDamageAbsorbClampMode(calculator:GetDamageAbsorbClampMode())
                calculator:SetHealAbsorbClampMode(calculator:GetHealAbsorbClampMode())
                calculator:SetHealAbsorbMode(calculator:GetHealAbsorbMode())
                incomingHeals = calculator:GetTotalIncomingHeals()
                damageAbsorbs = calculator:GetTotalDamageAbsorbs()
                healAbsorbs = calculator:GetTotalHealAbsorbs()
            end
            local function abbr(val)
                if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                    return AbbreviateNumbers(val)
                end
                return tostring(val)
            end
            local textStr = abbr(Current)
            if displayMode == "bothfull" and Percent then
                local okPct, pctText = pcall(string.format, "%.0f%%", Percent)
                if okPct and pctText then
                    textStr = textStr .. " (" .. pctText .. ")"
                end
            end
            local incomingStr = (type(incomingHeals) == "number" and type(AbbreviateNumbers) == "function") and AbbreviateNumbers(incomingHeals) or nil
            if incomingStr then
                textStr = textStr .. " +" .. incomingStr
            end
            local absorbParts = {}
            local dmgAbsStr = (type(damageAbsorbs) == "number" and type(AbbreviateNumbers) == "function") and AbbreviateNumbers(damageAbsorbs) or nil
            if dmgAbsStr then
                table.insert(absorbParts, "Absorb " .. dmgAbsStr)
            end
            local healAbsStr = (type(healAbsorbs) == "number" and type(AbbreviateNumbers) == "function") and AbbreviateNumbers(healAbsorbs) or nil
            if healAbsStr then
                table.insert(absorbParts, "HealAbsorb " .. healAbsStr)
            end
            if #absorbParts > 0 then
                textStr = textStr .. " (" .. table.concat(absorbParts, ", ") .. ")"
            end
            text:SetText(textStr)
        elseif displayMode == "both" then
            local sep = _G.CONFIG and _G.CONFIG.separator or " - "
            local okFmt = false
            if type(Current) == "number" and type(Percent) == "number" and type(AbbreviateNumbers) == "function" then
                okFmt = pcall(text.SetFormattedText, text, "%s" .. sep .. "%.0f%%", AbbreviateNumbers(Current), Percent)
            end
            if not okFmt then
                local raw = FormatText("both", Current, nil, Percent)
                text:SetText(raw or "?")
            end
            AppendAbsorbSuffix(Unit)
        elseif displayMode == "current" then
            text:SetText(FormatText("current", Current, nil, Percent))
            AppendAbsorbSuffix(Unit)
        elseif displayMode == "currentmax" then
            text:SetText(FormatText("currentmax", Current, Max, Percent))
            AppendAbsorbSuffix(Unit)
        else -- percent
            local okFmt = false
            if type(Percent) == "number" then
                okFmt = pcall(text.SetFormattedText, text, "%.0f%%", Percent)
            end
            if not okFmt then
                local raw = FormatText("percent", Current, nil, Percent)
                text:SetText(raw or "?")
            end
            AppendAbsorbSuffix(Unit)
        end
    end)
    if not okRender then
        pcall(text.SetText, text, "")
    end
    if (db.visibleAlpha or 1.0) > 0 then
        text:Show()
    else
        text:Hide()
    end
end


-- Event handling
local evt = CreateFrame("Frame")
evt:RegisterUnitEvent("UNIT_HEALTH", "player")
evt:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
evt:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
evt:RegisterEvent("PLAYER_ENTERING_WORLD")
evt:RegisterEvent("PLAYER_UNGHOST")
evt:RegisterEvent("PLAYER_ALIVE")
evt:SetScript("OnEvent", function(self, event, unit)
    if unit and unit ~= "player" then return end
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyDisplaySettings()
    end
    UpdateHealthText()
end)


-- Slash command for display mode
SLASH_PLAYERHEALTHTEXT1 = "/pht"
SlashCmdList["PLAYERHEALTHTEXT"] = function(msg)
    local cmd, arg = (msg or ""):match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()
    arg = (arg or ""):lower()
    if cmd == "displaymode" then
        if arg == "current" or arg == "percent" or arg == "both" or arg == "currentmax" or arg == "full" or arg == "bothfull" or arg == "absorbs" then
            PlayerHealthTextDB.displayMode = arg
            ApplyDisplaySettings()
            UpdateHealthText()
            print("Player health text display mode set to", arg)
        else
            print("Usage: /pht displaymode <current|percent|both|currentmax|full|bothfull|absorbs>")
        end
        return
    elseif cmd == "showabsorbs" then
        if arg == "true" or arg == "on" or arg == "1" then
            PlayerHealthTextDB.showAbsorbs = true
            UpdateHealthText()
            print("Player health text show absorbs enabled")
        elseif arg == "false" or arg == "off" or arg == "0" then
            PlayerHealthTextDB.showAbsorbs = false
            UpdateHealthText()
            print("Player health text show absorbs disabled")
        else
            print("Usage: /pht showabsorbs <true|false>")
        end
        return
    end
    print("Commands: /pht displaymode <current|percent|both|currentmax|full|bothfull|absorbs>")
    print("          /pht showabsorbs <true|false> (or use the Style dropdown in options)")
end


-- Initial display settings only; UpdateHealthText() deferred to PLAYER_ENTERING_WORLD
ApplyDisplaySettings()


-- No custom frame or re-anchoring needed; text is always on healthBar
