
	-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/FrameXML/Cooldown.xml
	-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/FrameXML/ActionButton.lua#L808
	--hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", function(self)
	hooksecurefunc(getmetatable(CreateFrame("Cooldown", nil, nil, "CooldownFrameTemplate")).__index, "SetCooldown", function(self)
		if not self:IsForbidden() then
			self:SetEdgeTexture("Interface\\Cooldown\\edge")
		end
	end)