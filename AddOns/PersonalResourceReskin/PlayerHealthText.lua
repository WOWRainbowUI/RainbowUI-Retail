
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



-- Use the original percent logic: prefer UnitHealthPercent, fallback to (cur/max)*100
local function SafeUnitHealthPercent(unit)
    local pct = nil
    if type(UnitHealthPercent) == "function" then
        local ok, val = pcall(UnitHealthPercent, unit)
        if ok and type(val) == "number" then
            pct = val
        end
    end
    if type(pct) ~= "number" then
        local cur = UnitHealth(unit)
        local max = UnitHealthMax(unit)
        if type(cur) == "number" and type(max) == "number" and max > 0 then
            pct = (cur / max) * 100
        else
            pct = nil
        end
    end
    return pct
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
            return AbbreviateNumbers(val, abbrevData)
        end
        return tostring(val)
    end
    if style == "percent" then
        if type(pct) ~= "number" then return "?" end
        return string.format("%.0f%%", pct)
    elseif style == "both" then
        if type(cur) ~= "number" or type(pct) ~= "number" then return "?" end
        return abbr(cur or 0) .. (CONFIG and CONFIG.separator or " - ") .. string.format("%.0f%%", pct)
    elseif style == "both_reverse" then
        if type(cur) ~= "number" or type(pct) ~= "number" then return "?" end
        return string.format("%.0f%%", pct) .. (CONFIG and CONFIG.separator or " - ") .. abbr(cur or 0)
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
local prd = _G.PersonalResourceDisplayFrame
local healthBar = prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar
local text
if healthBar and healthBar.CreateFontString then
    healthBar:SetFrameStrata("MEDIUM")
    text = healthBar:CreateFontString("PlayerHealthTextFontString", "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    text:SetJustifyH("CENTER")
    if text.SetJustifyV then text:SetJustifyV("MIDDLE") end
    text:SetText("")
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
    local db = PlayerHealthTextDB
    if not healthBar or not text then return end
    -- Font and size
    local fontChoice = (type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.fontChoice) or db.fontChoice or defaults.fontChoice
    local fontFlags = (type(_G.PersonalResourceReskinDB) == "table" and _G.PersonalResourceReskinDB.profile and _G.PersonalResourceReskinDB.profile.fontFlags)
        or (type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.fontFlags)
        or db.fontFlags or "OUTLINE"
    SafeSetFont(text, fontChoice, db.fontSize or defaults.fontSize, fontFlags)
    -- Color
    local color = (type(_G.PlayerPowerTextDB) == "table" and _G.PlayerPowerTextDB.color) or db.color or defaults.color
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
    text:SetAlpha(db.visibleAlpha or 1.0)
    text:Show()
end


function UpdateHealthText()
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
    local Unit = "player"
    local Percent = UnitHealthPercent and UnitHealthPercent(Unit, false, CurveConstants and CurveConstants.ScaleTo100) or nil
    local Current = UnitHealth(Unit)
    local Max = UnitHealthMax(Unit)
    local displayMode = PlayerHealthTextDB and PlayerHealthTextDB.displayMode or "percent"
    if displayMode == "absorbs" then
        local absorb = UnitGetTotalAbsorbs(Unit)
        local function abbr(val)
            if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                return AbbreviateNumbers(val, abbrevData)
            end
            return tostring(val)
        end
        local textStr = "Absorbs " .. abbr(absorb)
        text:SetText(textStr)
    elseif displayMode == "full" or displayMode == "bothfull" then
        local calculator = UnitHealPredictionCalculator and UnitHealPredictionCalculator.Create and UnitHealPredictionCalculator:Create(Unit)
        local incomingHeals, fromHealer, fromOthers, incomingHealsClamped = 0, 0, 0, false
        local damageAbsorbs, damageAbsorbsClamped = 0, false
        local healAbsorbs, healAbsorbsClamped = 0, false
        if calculator then
            calculator:ResetPredictedValues()
            local hasSecretValues = calculator:HasSecretValues()
            local predictedValues = calculator:GetPredictedValues()
            local amount, amountFromHealer, amountFromOthers, clamped = calculator:GetIncomingHeals()
            calculator:SetToDefaults()
            calculator:SetPredictedValues(predictedValues)
            local incomingHealOverflowPercent = 0
            calculator:SetIncomingHealOverflowPercent(incomingHealOverflowPercent)
            local incomingHealClampMode = calculator:GetIncomingHealClampMode()
            calculator:SetIncomingHealClampMode(incomingHealClampMode)
            local damageAbsorbClampMode = calculator:GetDamageAbsorbClampMode()
            calculator:SetDamageAbsorbClampMode(damageAbsorbClampMode)
            local healAbsorbMode = calculator:GetHealAbsorbMode()
            local healAbsorbClampMode = calculator:GetHealAbsorbClampMode()
            calculator:SetHealAbsorbClampMode(healAbsorbClampMode)
            calculator:SetHealAbsorbMode(healAbsorbMode)
            -- New APIs
            calculator:SetMaximumHealthMode(Enum and Enum.UnitMaximumHealthMode and Enum.UnitMaximumHealthMode.IncludeAbsorbs or 1) -- Assume 1 is include
            incomingHeals = calculator:GetTotalIncomingHeals()
            damageAbsorbs = calculator:GetTotalDamageAbsorbs()
            healAbsorbs = calculator:GetTotalHealAbsorbs()
        end
        local function abbr(val)
            if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                return AbbreviateNumbers(val, abbrevData)
            end
            return tostring(val)
        end
        local textStr = abbr(Current)
        if displayMode == "bothfull" and Percent then
            textStr = textStr .. " (" .. string.format("%.0f%%", Percent) .. ")"
        end
        if incomingHeals and incomingHeals > 0 then
            textStr = textStr .. " +" .. abbr(incomingHeals)
        end
        local absorbParts = {}
        if damageAbsorbs and damageAbsorbs > 0 then
            table.insert(absorbParts, "Absorb " .. abbr(damageAbsorbs))
        end
        if healAbsorbs and healAbsorbs > 0 then
            table.insert(absorbParts, "HealAbsorb " .. abbr(healAbsorbs))
        end
        if #absorbParts > 0 then
            textStr = textStr .. " (" .. table.concat(absorbParts, ", ") .. ")"
        end
        text:SetText(textStr)
    elseif displayMode == "both" then
        text:SetText(FormatText("both", Current, nil, Percent))
        if PlayerHealthTextDB.showAbsorbs then
            local absorb = UnitGetTotalAbsorbs(Unit)
            if absorb then
                local function abbr(val)
                    if type(val) == "number" then
                        if AbbreviateNumbers then
                            return AbbreviateNumbers(val, abbrevData)
                        end
                    end
                    return tostring(val)
                end
                text:SetText(text:GetText() .. " +" .. abbr(absorb))
            end
        end
    elseif displayMode == "current" then
        text:SetText(FormatText("current", Current, nil, Percent))
        if PlayerHealthTextDB.showAbsorbs then
            local absorb = UnitGetTotalAbsorbs(Unit)
            local absorbNum = absorb and tonumber(tostring(absorb)) or 0
            if absorbNum > 0 then
                local function abbr(val)
                    if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                        return AbbreviateNumbers(val, abbrevData)
                    end
                    return tostring(val)
                end
                text:SetText(text:GetText() .. " +" .. abbr(absorbNum))
            end
        end
    elseif displayMode == "currentmax" then
        text:SetText(FormatText("currentmax", Current, Max, Percent))
        if PlayerHealthTextDB.showAbsorbs then
            local absorb = UnitGetTotalAbsorbs(Unit)
            local absorbNum = absorb and tonumber(tostring(absorb)) or 0
            if absorbNum > 0 then
                local function abbr(val)
                    if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                        return AbbreviateNumbers(val, abbrevData)
                    end
                    return tostring(val)
                end
                text:SetText(text:GetText() .. " +" .. abbr(absorbNum))
            end
        end
    else -- percent
        text:SetText(FormatText("percent", Current, nil, Percent))
        if PlayerHealthTextDB.showAbsorbs then
            local absorb = UnitGetTotalAbsorbs(Unit)
            local absorbNum = absorb and tonumber(tostring(absorb)) or 0
            if absorbNum > 0 then
                local function abbr(val)
                    if type(AbbreviateNumbers) == "function" and type(val) == "number" then
                        return AbbreviateNumbers(val, abbrevData)
                    end
                    return tostring(val)
                end
                text:SetText(text:GetText() .. " +" .. abbr(absorbNum))
            end
        end
    end
    text:Show()
end


-- Event handling
local evt = CreateFrame("Frame")
evt:RegisterUnitEvent("UNIT_HEALTH", "player")
evt:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
evt:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
evt:RegisterEvent("PLAYER_ENTERING_WORLD")
evt:RegisterEvent("PLAYER_UNGHOST")
evt:RegisterEvent("PLAYER_ALIVE")
evt:RegisterEvent("PLAYER_REGEN_ENABLED")
evt:RegisterEvent("PLAYER_REGEN_DISABLED")
evt:SetScript("OnEvent", function(self, event, unit)
    if unit and unit ~= "player" then return end
    ApplyDisplaySettings()
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
            print("玩家血量文字顯示模式已設為 ", arg)
        else
            print("用法: /pht displaymode <current|percent|both|currentmax|full|bothfull|absorbs>")
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


-- Initial state
ApplyDisplaySettings()
UpdateHealthText()


-- No custom frame or re-anchoring needed; text is always on healthBar
