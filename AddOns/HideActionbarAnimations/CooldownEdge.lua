
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then

	local function ApplyEdgeTexture(frame)
		if frame and issecretvalue(frame) then return end
		if frame and not frame:IsForbidden() then
			if frame:GetObjectType() == "Cooldown" then
				if frame.SetEdgeTexture then
					frame:SetEdgeTexture("Interface\\Cooldown\\edge")
				end
			end
		end
	end
	if ActionButton_ApplyCooldown and type(ActionButton_ApplyCooldown) == "function" then -- Action Buttons no longer use CooldownFrame_Set
		hooksecurefunc("ActionButton_ApplyCooldown", function(normalCooldown, cooldownInfo, chargeCooldown, chargeInfo, lossOfControlCooldown, lossOfControlInfo)
			ApplyEdgeTexture(normalCooldown)
			ApplyEdgeTexture(chargeCooldown)
			ApplyEdgeTexture(lossOfControlCooldown)
		end)
	end
	if CooldownFrame_Set and type(ActionButton_ApplyCooldown) == "function" then
		hooksecurefunc("CooldownFrame_Set", function(self)
			ApplyEdgeTexture(self)
		end)
	end

end
