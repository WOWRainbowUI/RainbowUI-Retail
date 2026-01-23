local _, U1 = ...

--[=[
local fm = CreateFrame("Frame")
for k, _ in pairs(U1.captureEvents) do fm:RegisterEvent(k) end
fm:SetScript("OnEvent", function(self, event, ...) print(event, ...) end)
--]=]
