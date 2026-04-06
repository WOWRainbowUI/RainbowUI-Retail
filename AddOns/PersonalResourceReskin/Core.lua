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
local function IsInEditModeOrCombat()
    return InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive)
end

local Core_NeedsReanchor = false
local function AnchorToPRDBar()
    if IsInEditModeOrCombat() then
        Core_NeedsReanchor = true
        return
    end
    -- Prefer the custom Brewmaster stagger bar when available
    local customBar = _G.CustomBrewmasterStaggerBar
    if customBar and customBar:IsShown() then
        text:ClearAllPoints()
        text:SetPoint("CENTER", customBar, "CENTER", 0, 0)
        Core_NeedsReanchor = false
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

-- Force it above most UI
text:SetFrameStrata("DIALOG")
text:SetFrameLevel(1000)
-- Start hidden to prevent flash before custom bar loads
text:Hide()

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

    -- If CustomBrewmasterStaggerBar is active it has its own text — hide ours
    local customBar = _G.CustomBrewmasterStaggerBar
    if customBar and customBar:IsShown() then
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
        text.value:SetText(AbbreviateNumbers(stagger))
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
        -- Defer so CustomBrewmasterStaggerBar has time to create/show first
        C_Timer.After(0.2, function()
            AnchorToPRDBar()
            HookPRDBar()
            UpdateStagger()
        end)
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        if Core_NeedsReanchor then
            AnchorToPRDBar()
        end
    end
end)
end
