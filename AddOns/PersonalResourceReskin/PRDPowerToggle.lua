-- Add to TOC: ## SavedVariables: PRDPowerToggleDB
-- Use profile-aware storage for hidden state
local function getProfile()
    if _G.PersonalResourceReskin and _G.PersonalResourceReskin.db and _G.PersonalResourceReskin.db.profile then
        return _G.PersonalResourceReskin.db.profile
    end
    return nil
end

local function getHidden()
    local profile = getProfile()
    if profile then
        return profile.prdPowerBarHidden or false
    end
    return false
end

local function setHidden(val)
    local profile = getProfile()
    if profile then
        profile.prdPowerBarHidden = val and true or false
    end
end

local f = CreateFrame("Frame")

local function HookPowerBarHide()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd or not prd.PowerBar then return end
    local powerBar = prd.PowerBar
    if not powerBar._prdpowerhook then
        powerBar._prdpowerhook = true
        powerBar:HookScript("OnShow", function(self)
            if getHidden() then
                self:Hide()
            end
        end)
    end
end

local function UpdatePowerBarVisibility()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd or not prd.PowerBar then return end
    if getHidden() then
        prd.PowerBar:Hide()
    else
        prd.PowerBar:Show()
    end
    -- Set frame strata to MEDIUM
    prd.PowerBar:SetFrameStrata("LOW")
    HookPowerBarHide()
end

-- Reapply on login, spec change, etc
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:SetScript("OnEvent", function()
    C_Timer.After(0.5, UpdatePowerBarVisibility)
end)

-- Slash command to toggle visibility
SLASH_PRDPOWER1 = "/prdpower"
SlashCmdList["PRDPOWER"] = function(msg)
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd or not prd.PowerBar then return end
    if msg == "show" then
        setHidden(false)
        UpdatePowerBarVisibility()
        print("|cff00ff00個人資源的能量條會在重新載入後保持顯示。|r")
    elseif msg == "hide" then
        setHidden(true)
        UpdatePowerBarVisibility()
        print("|cffff0000個人資源的能量條會在重新載入後保持隱藏。|r")
    else
        print("|cffffff00Usage: /prdpower show|hide|r")
    end
end
