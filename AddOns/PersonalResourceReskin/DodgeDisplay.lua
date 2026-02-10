

-- Loader frame: only loads the DodgeDisplay for Brewmaster Monk
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

local function IsBrewmasterMonk()
    local _, class = UnitClass("player")
    if class ~= "MONK" then return false end
    local spec = GetSpecialization()
    if not spec then return false end
    local specID = GetSpecializationInfo(spec)
    return specID == 268
end

local initialized = false
local f, msgFrame, msgTimer

local function ShowScreenMessage(msg)
    msgFrame.text:SetText(msg)
    msgFrame:Show()
    if msgTimer then
        msgTimer:Cancel()
    end
    msgTimer = C_Timer.NewTimer(20, function()
        msgFrame:Hide()
    end)
end

local function AnchorFrame()
    f:ClearAllPoints()
    local anchor = _G["PersonalResourceDisplayFrame"] and _G["PersonalResourceDisplayFrame"].AlternatePowerBar and _G["PersonalResourceDisplayFrame"].AlternatePowerBar.background
    if anchor then
        f:SetPoint("RIGHT", anchor, "RIGHT", 34, 0)
        f:Show()
    else
        f:Hide()
    end
end

local function UpdateDodge()
    local dodge = GetDodgeChance()
    f.text:SetText(string.format(" %.2f%%", dodge))
end

local function InitializeDodgeDisplay()
    if initialized then return end
    initialized = true
    f = CreateFrame("Frame", "DodgeDisplayFrame", UIParent)
    f:SetSize(120, 30)
    f:SetFrameStrata("HIGH")

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.text:SetPoint("CENTER")
    f.text:SetTextColor(1, 1, 1, 1)

    msgFrame = CreateFrame("Frame", nil, UIParent)
    msgFrame:SetSize(400, 40)
    msgFrame:SetPoint("TOP", 0, -200)
    msgFrame:SetFrameStrata("DIALOG")
    msgFrame.text = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    msgFrame.text:SetPoint("CENTER")
    msgFrame.text:SetTextColor(1, 1, 0, 1)
    msgFrame:Hide()

    f:RegisterEvent("UNIT_STATS")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("UNIT_AURA")
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    f:SetScript("OnEvent", function(self, event)
        if not IsBrewmasterMonk() then
            f:Hide()
            return
        end
        if event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(1, function()
                AnchorFrame()
            end)
        end
        UpdateDodge()
        AnchorFrame()
    end)

    f:SetScript("OnMouseDown", function(self, button)
    end)

    f:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
        end
    end)

    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)

    UpdateDodge()

    -- Slash command for manual anchor (for debugging)
    SLASH_DODGEDISPLAYANCHOR1 = "/dodgeanchor"
    SlashCmdList["DODGEDISPLAYANCHOR"] = function()
        AnchorFrame()
    end
end

loader:SetScript("OnEvent", function(self, event)
    local hasAltPower = _G["PersonalResourceDisplayFrame"] and _G["PersonalResourceDisplayFrame"].AlternatePowerBar
    if IsBrewmasterMonk() and hasAltPower then
        if not initialized then
            InitializeDodgeDisplay()
        else
            f:Show()
        end
    else
        if initialized and f then
            f:Hide()
        end
    end
end)
