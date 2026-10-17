
	local addonName, addonNameSpace = ...

	if not (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or WOW_PROJECT_ID == WOW_PROJECT_CAMELOT) then return end

		local MediaPath = "Interface\\AddOns\\" .. addonName .. "\\Media\\"
		local EdgeTexture = MediaPath .. "edge.png" -- "Interface\\Cooldown\\edge"

		local function ApplyEdgeTexture(frame)
			if not frame then return end
			if frame:IsForbidden() then return end
			if issecretvalue and issecretvalue(frame) then return end

			if frame:GetObjectType() == "Cooldown" then
				if frame.SetEdgeTexture then
					frame:SetEdgeTexture(EdgeTexture)
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
		if type(ActionButton_ApplyCooldown) == "function" then -- Action Buttons no longer use CooldownFrame_Set
			hooksecurefunc("ActionButton_ApplyCooldown", function(normalCooldown, cooldownInfo, chargeCooldown, chargeInfo, lossOfControlCooldown, lossOfControlInfo)
				ApplyEdgeTexture(normalCooldown)
				ApplyEdgeTexture(chargeCooldown)
				ApplyEdgeTexture(lossOfControlCooldown)
			end)
		end
		if type(CooldownFrame_Set) == "function" then -- CooldownManager uses this
			hooksecurefunc("CooldownFrame_Set", function(frame)
				ApplyEdgeTexture(frame)
			end)
		end
