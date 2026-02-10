-- Add to TOC: ## SavedVariables: PRDHealthToggleDB
PRDHealthToggleDB = PRDHealthToggleDB or { hidden = false }

local f = CreateFrame("Frame")

local function HookHealthBarHide()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd or not prd.HealthBarsContainer then return end
    local healthBar = prd.HealthBarsContainer
    if not healthBar._prdhook then
        healthBar._prdhook = true
        healthBar:HookScript("OnShow", function(self)
            if PRDHealthToggleDB.hidden then
                self:Hide()
            end
        end)
    end
end

local function UpdateHealthBarVisibility()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd or not prd.HealthBarsContainer then return end
    if PRDHealthToggleDB.hidden then
        prd.HealthBarsContainer:Hide()
        -- Also hide health text if present
        local hb = prd.HealthBarsContainer.healthBar
        if hb and hb.healthBar and hb.healthBar.__PRD_Text then
            hb.healthBar.__PRD_Text:Hide()
        elseif hb and hb.__PRD_Text then
            hb.__PRD_Text:Hide()
        end
    else
        prd.HealthBarsContainer:Show()
        -- Optionally show health text if you want
        local hb = prd.HealthBarsContainer.healthBar
        if hb and hb.healthBar and hb.healthBar.__PRD_Text then
            hb.healthBar.__PRD_Text:Show()
        elseif hb and hb.__PRD_Text then
            hb.__PRD_Text:Show()
        end
    end
    HookHealthBarHide()
end

-- Reapply on login, spec change, etc
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:SetScript("OnEvent", function()
    C_Timer.After(0.5, UpdateHealthBarVisibility)
end)

-- Optional: slash command to toggle visibility
SLASH_PRDHEALTH1 = "/prdhealth"
SlashCmdList["PRDHEALTH"] = function(msg)
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd or not prd.HealthBarsContainer then return end
    if msg == "show" then
        PRDHealthToggleDB.hidden = false
        UpdateHealthBarVisibility()
        print("|cff00ff00個人資源的血量條會在重新載入後保持顯示。|r")
    elseif msg == "hide" then
        PRDHealthToggleDB.hidden = true
        UpdateHealthBarVisibility()
        print("|cffff0000個人資源的血量條會在重新載入後保持隱藏。|r")
    else
        print("|cffffff00Usage: /prdhealth show|hide|r")
    end
end
