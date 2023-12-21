local _, ns = ...
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

local hiddenFrame = CreateFrame("Frame")

function ns:hideFrame(frame)
  frame:SetScript("OnShow", frame.Hide)
  frame:Hide()
end

function ns:handleFrame(frame)
  if not frame then return end
  frame:SetParent(hiddenFrame)
  ns:hideFrame(frame)
end

eventFrame:SetScript("OnEvent", function()
  ns:hideFrame(hiddenFrame)
  local arenaFrame = _G["CompactArenaFrame"]
  ns:handleFrame(arenaFrame)
end)