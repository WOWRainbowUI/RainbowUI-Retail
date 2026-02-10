--========================================================--
-- StaggerMonitor - Text Only + Lock/Unlock
--========================================================--

local addonName = ...
local f = CreateFrame("Frame")

------------------------------------------------------------
-- SavedVariables defaults
------------------------------------------------------------
StaggerMonitorDB = StaggerMonitorDB or {
    locked = true,
    posX = 0,
    posY = -200,
}

------------------------------------------------------------
local text = CreateFrame("Frame", "StaggerMonitorTextFrame", UIParent)
text:SetSize(100, 30)
local abbrevData = {
    breakpointData = {
        { breakpoint = 1e9, abbreviation = "B", significandDivisor = 1e9, fractionDivisor = 1e8, abbreviationIsGlobal = false },
        { breakpoint = 1e6, abbreviation = "M", significandDivisor = 1e6, fractionDivisor = 1e5, abbreviationIsGlobal = false },
        { breakpoint = 1e3, abbreviation = "K", significandDivisor = 1e3, fractionDivisor = 1e2, abbreviationIsGlobal = false },
    },
}

-- Inline AbbreviateNumbers function (copied from PlayerHealthText.lua/PlayerPowerText.lua style)
local function AbbreviateNumbers(val, abbrevData)
    if type(val) ~= "number" then return tostring(val) end
    local breakpoints = abbrevData and abbrevData.breakpointData or {}
    for i = 1, #breakpoints do
        local bp = breakpoints[i]
        if math.abs(val) >= bp.breakpoint then
            local significand = math.floor(val / bp.significandDivisor)
            local fraction = math.floor((math.abs(val) % bp.significandDivisor) / bp.fractionDivisor)
            if fraction > 0 then
                return string.format("%d.%d%s", significand, fraction, bp.abbreviation)
            else
                return string.format("%d%s", significand, bp.abbreviation)
            end
        end
    end
    return tostring(val)
end
local function IsInEditModeOrCombat()
    return InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive)
end

local Core_NeedsReanchor = false
local function AnchorToPRDBar()
    if IsInEditModeOrCombat() then
        Core_NeedsReanchor = true
        return
    end
    local anchor = _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.AlternatePowerBar and _G.PersonalResourceDisplayFrame.AlternatePowerBar.background
    if anchor then
        text:ClearAllPoints()
        text:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    else
        text:ClearAllPoints()
        text:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    end
    Core_NeedsReanchor = false
end
AnchorToPRDBar()

-- Force it above most UI
text:SetFrameStrata("DIALOG")
text:SetFrameLevel(1000)

text.value = text:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
text.value:SetPoint("CENTER")
text.value:SetTextColor(1, 1, 1, 0.7)
text.value:SetDrawLayer("OVERLAY", 7)


------------------------------------------------------------
-- Dragging Logic
------------------------------------------------------------
-- Remove dragging logic
text:EnableMouse(false)
text:SetMovable(false)

------------------------------------------------------------
-- Update Function
------------------------------------------------------------
local function UpdateStagger()
    if not UnitExists("player") then return end

    local _, class = UnitClass("player")
    if class ~= "MONK" then
        if text then text:Hide() end
        return
    end

    -- Only show for Brewmaster spec (specID 268)
    local specID = GetSpecialization() and GetSpecializationInfo(GetSpecialization())
    if specID ~= 268 then
        if text then text:Hide() end
        return
    end

    -- Only show if AlternatePowerBar
    local prd = _G.PersonalResourceDisplayFrame
    local altBar = prd and prd.AlternatePowerBar
    if not (altBar and altBar:IsShown() and altBar:GetEffectiveAlpha() > 0 and (not altBar:GetParent() or altBar:GetParent():IsShown())) then
        if text then text:Hide() end
        return
    end

    if text then text:Show() end

    local stagger = UnitStagger("player") or 0
    if text and text.value then
        text.value:SetText(AbbreviateNumbers(stagger, abbrevData))
    end
end

------------------------------------------------------------
-- Event Handling
------------------------------------------------------------
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("UNIT_MAXHEALTH")

f:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Edit Mode exit event (Dragonflight+)
if EditModeManagerFrame and EditModeManagerFrame.RegisterCallback then
    EditModeManagerFrame:RegisterCallback("EditModeExit", function()
        if Core_NeedsReanchor then
            AnchorToPRDBar()
        end
    end)
end

f:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_AURA" and unit ~= "player" then return end
    UpdateStagger()
end)

------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------
SLASH_STAGTEXT1 = "/stagtext"
SLASH_STAGTEXT2 = "/staggertext"

SlashCmdList["STAGTEXT"] = function(msg)
    msg = msg:lower()

    if msg == "unlock" then
        StaggerMonitorDB.locked = false
        print("StaggerMonitor: unlocked (drag to move)")
        return
    end

    if msg == "lock" then
        StaggerMonitorDB.locked = true
        print("StaggerMonitor: locked")
        return
    end


    if msg == "reset" then
        AnchorToPRDBar()
        print("StaggerMonitor: position reset (anchored to PRD bar)")
        return
    end

    print("StaggerMonitor commands:")
    print("/stagtext reset  - re-anchor to PRD bar")
-- Re-anchor on PLAYER_ENTERING_WORLD
local function HookPRDBar()
    local anchor = _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.AlternatePowerBar and _G.PersonalResourceDisplayFrame.AlternatePowerBar.background
    if anchor and not anchor._staggerMonitorHooked then
        anchor._staggerMonitorHooked = true
        hooksecurefunc(anchor, "SetPoint", function()
            if not (InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive)) then
                AnchorToPRDBar()
            end
        end)
    end
end

f:HookScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        AnchorToPRDBar()
        HookPRDBar()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if Core_NeedsReanchor then
            AnchorToPRDBar()
        end
    end
end)
end
