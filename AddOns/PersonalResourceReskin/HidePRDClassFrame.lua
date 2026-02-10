
local function HideOrTransparentPRDClassFrame()
    local _, class = UnitClass("player")
    if class == "ROGUE" or class == "MAGE" or class == "DEATHKNIGHT" then return end
    local f = _G.prdClassFrame
    if not f then

        C_Timer.After(0.5, HideOrTransparentPRDClassFrame)
        return
    end

    f:Hide()

    f:SetAlpha(0)
    if f.Background then f.Background:SetAlpha(0) end
    if f.Glow then f.Glow:SetAlpha(0) end
    if f.ThinGlow then f.ThinGlow:SetAlpha(0) end
    if f.ActiveTexture then f.ActiveTexture:SetAlpha(0) end
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("UNIT_DISPLAYPOWER")
frame:RegisterEvent("PLAYER_TALENT_UPDATE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function()
    C_Timer.After(0.1, HideOrTransparentPRDClassFrame)
end)
