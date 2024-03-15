local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

local hiddenFrame = CreateFrame("Frame")

local function handleFrame(self, spec)
    if InCombatLockdown() then return end
    self:SetParent(hiddenFrame)
end

eventFrame:SetScript("OnEvent", function(self, event, name)
    if name ~= "FatalArenaFrames" then return end
    if not CompactArenaFrame then return end
    hiddenFrame:Hide()
    hooksecurefunc(CompactArenaFrame, "UpdateVisibility", handleFrame)
end)

