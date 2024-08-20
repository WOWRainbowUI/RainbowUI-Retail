--[[ Hooking Time part 1 --
TargetFrameSpellBar:HookScript("OnShow", function(self)
	print("Hello Target's Spell")
end)]]
-- Hooking Time part 2 --
TargetFrameSpellBar:HookScript("OnUpdate", function(self)
	if VCBrTarget["Unlock"] then
		self:SetIgnoreParentAlpha(true)
		self:SetAlpha(1)
		self:SetScale(VCBrTarget["Scale"]/100)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	elseif not VCBrTarget["Unlock"] then
		self:SetIgnoreParentAlpha(false)
		self:SetScale(1)
		self:ClearAllPoints()
		if self:IsUserPlaced() then self:SetUserPlaced(false) end
	end
end)
