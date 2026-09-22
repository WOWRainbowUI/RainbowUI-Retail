
	local addonName, addonNameSpace = ...
	local Version, _, _, tocVersion = GetBuildInfo()

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or (tocVersion >= 16000 and tocVersion < 17000) then

		local MediaPath = "Interface\\AddOns\\" .. addonName .. "\\"

		local function ApplyEdgeTexture(frame)
			if frame and issecretvalue(frame) then return end
			if frame and not frame:IsForbidden() then
				if frame:GetObjectType() == "Cooldown" then
					if frame.SetEdgeTexture then
						frame:SetEdgeTexture(MediaPath .. "edge.png") -- "Interface\\Cooldown\\edge"
					end
					--[[
					if frame.SetSwipeColor then
						frame:SetSwipeColor(0, 0, 0, 0.8)
					end
					if frame.SetBlingTexture then
						frame:SetBlingTexture("Interface\\Cooldown\\star4", 0.3, 0.6, 1, 0.8)
					end
					--]]
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
		if CooldownFrame_Set and type(CooldownFrame_Set) == "function" then -- CooldownManager uses this
			hooksecurefunc("CooldownFrame_Set", function(self)
				ApplyEdgeTexture(self)
			end)
		end

	end
