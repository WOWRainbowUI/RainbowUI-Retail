--[[ Hooking Time part 1 --
FocusFrameSpellBar:HookScript("OnShow", function(self)
	print("Hello Focus' Spell")
end)]]
-- Hooking Time part 2 --
FocusFrameSpellBar:HookScript("OnUpdate", function(self)
	if VCBrFocus["Unlock"] then
		self:SetIgnoreParentAlpha(true)
		self:SetAlpha(1)
		self:SetScale(VCBrFocus["Scale"]/100)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
	elseif not VCBrFocus["Unlock"] then
		self:SetIgnoreParentAlpha(false)
		self:SetScale(1)
		self:ClearAllPoints()
		if self:IsUserPlaced() then self:SetUserPlaced(false) end
	end
end)
