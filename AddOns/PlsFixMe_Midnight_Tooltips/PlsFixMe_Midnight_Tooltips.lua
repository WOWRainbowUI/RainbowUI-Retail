--print("PlsFixMe")
--1.0.1 TooltipDataHandlerMixin.ProcessInfo fix

local originalSetText = GameTooltip.SetText
function GameTooltip:SetText(text, r, g, b, alpha, wrap, shrink)
	if type(alpha) == "boolean" then
		--alpha is wrap? 0_o
		return originalSetText(self, text, r, g, b, 1, alpha, wrap)
    end
    return originalSetText(self, text, r, g, b, alpha, wrap, shrink)
end



function fixScrt(value)
	if value == nil then
		return value
	end
	local success, result = pcall(function()
		return value + 0
	end)
	if success then
		return result
	else
		return 30
	end
end


function TooltipComparisonManager:SetItemTooltip(isPrimaryTooltip)
	local tooltip, displayedItem
	if isPrimaryTooltip then
		displayedItem = self.compareInfo.item
		tooltip = self.tooltip.shoppingTooltips[1]
	else
		displayedItem = self:GetSecondaryItem()
		tooltip = self.tooltip.shoppingTooltips[2]
	end
	
	local comparisonMethod = self.compareInfo.method

	local tooltipData = self:GetComparisonItemData(displayedItem)
	if not tooltipData then
		return
	end

	tooltip:ClearLines()

	local isPairedItem = comparisonMethod == Enum.TooltipComparisonMethod.WithBagMainHandItem or comparisonMethod == Enum.TooltipComparisonMethod.WithBagOffHandItem

	-- header
	local headerText = EQUIPPED
	if not isPrimaryTooltip and isPairedItem then
		headerText = IF_EQUIPPED_TOGETHER
	end
	tooltip.CompareHeader:Show()
	tooltip.CompareHeader.Label:SetText(headerText)
	tooltip.CompareHeader:SetWidth(fixScrt(tooltip.CompareHeader.Label:GetWidth()) + 30)
	--is secret value? 0_o

	-- the item
	local tooltipInfo = {
		tooltipData = tooltipData,
		append = true,
	}
	tooltip:ProcessInfo(tooltipInfo)

	-- delta stats
	-- always for primary tooltip, secondary only if it's not a combined comparison
	if isPrimaryTooltip or comparisonMethod == Enum.TooltipComparisonMethod.Single then
		local additionalItem = comparisonMethod ~= Enum.TooltipComparisonMethod.Single and self:GetSecondaryItem() or nil
		local delta = C_TooltipComparison.GetItemComparisonDelta(self.comparisonItem, displayedItem, additionalItem, isPairedItem)
		if delta and #delta > 0 then
			-- summary header
			local summaryHeader = ITEM_DELTA_DESCRIPTION
			if isPrimaryTooltip and comparisonMethod == Enum.TooltipComparisonMethod.WithBothHands then
				summaryHeader = ITEM_DELTA_MULTIPLE_COMPARISON_DESCRIPTION
			end
			GameTooltip_AddBlankLineToTooltip(tooltip)
			GameTooltip_AddNormalLine(tooltip, summaryHeader)
			-- additional item?
			if isPairedItem and additionalItem then
				local formatString = ITEM_DELTA_DUAL_WIELD_COMPARISON_MAINHAND_DESCRIPTION
				if comparisonMethod ==  Enum.TooltipComparisonMethod.WithBagOffHandItem then
					formatString = ITEM_DELTA_DUAL_WIELD_COMPARISON_OFFHAND_DESCRIPTION
				end
				local itemName = C_Item.GetItemNameByID(additionalItem.guid or additionalItem.hyperlink)
				local itemQuality = C_Item.GetItemQualityByID(additionalItem.guid or additionalItem.hyperlink)
				if itemName then
					GameTooltip_AddBlankLineToTooltip(tooltip)

					local colorData = ColorManager.GetColorDataForItemQuality(itemQuality)
					if colorData then
						local hexColor = colorData.color:GenerateHexColor()
						GameTooltip_AddNormalLine(tooltip, formatString:format(hexColor, itemName))
					else
						GameTooltip_AddNormalLine(tooltip, itemName)
					end
				end
			end
			-- the stats
			for i, deltaLine in ipairs(delta) do
				GameTooltip_AddHighlightLine(tooltip, deltaLine)
			end

			-- cyclable items?
			if #self.compareInfo.additionalItems > 1 and GetCVarBool("allowCompareWithToggle") then
				GameTooltip_AddBlankLineToTooltip(tooltip)
				local bindKey = GetBindingKeyForAction("ITEMCOMPARISONCYCLING")
				if bindKey and bindKey ~= "" then
					local formatString = ITEM_COMPARISON_SWAP_ITEM_MAINHAND_DESCRIPTION
					if comparisonMethod ==  Enum.TooltipComparisonMethod.WithBagOffHandItem then
						formatString = ITEM_COMPARISON_SWAP_ITEM_OFFHAND_DESCRIPTION
					end
					GameTooltip_AddDisabledLine(tooltip, formatString:format(bindKey))
				else
					local text = ITEM_COMPARISON_CYCLING_DISABLED_MSG_MAINHAND					
					if comparisonMethod ==  Enum.TooltipComparisonMethod.WithBagOffHandItem then
						text = ITEM_COMPARISON_CYCLING_DISABLED_MSG_OFFHAND
					end			
					GameTooltip_AddDisabledLine(tooltip, text)
				end
			end
		end		
	end

	return true
end





function TooltipComparisonManager:AnchorShoppingTooltips(primaryShown, secondaryShown)
	local tooltip = self.tooltip
	local primaryTooltip = tooltip.shoppingTooltips[1]
	local secondaryTooltip = tooltip.shoppingTooltips[2]
	
	primaryTooltip:SetShown(primaryShown)
	secondaryTooltip:SetShown(secondaryShown)

	local sideAnchorFrame = self.anchorFrame
	if self.anchorFrame.IsEmbedded then
		sideAnchorFrame = self.anchorFrame:GetParent():GetParent()
	end

	local leftPos = fixScrt(sideAnchorFrame:GetLeft())
	local rightPos = fixScrt(sideAnchorFrame:GetRight())

	local selfLeftPos = fixScrt(tooltip:GetLeft())
	local selfRightPos = fixScrt(tooltip:GetRight())

	-- if we get the Left, we have the Right
	if leftPos and selfLeftPos then
		leftPos = math.min(selfLeftPos, leftPos)-- get the left most bound
		rightPos = math.max(selfRightPos, rightPos)-- get the right most bound
	else
		leftPos = leftPos or selfLeftPos or 0
		rightPos = rightPos or selfRightPos or 0
	end

	-- sometimes the sideAnchorFrame is an actual tooltip, and sometimes it's a script region, so make sure we're getting the actual anchor type
	local anchorType = sideAnchorFrame.GetAnchorType and sideAnchorFrame:GetAnchorType() or tooltip:GetAnchorType()

	local totalWidth = 0
	if primaryShown then
		totalWidth = totalWidth + fixScrt(primaryTooltip:GetWidth())
	end
	if secondaryShown then
		totalWidth = totalWidth + fixScrt(secondaryTooltip:GetWidth())
	end

	local rightDist = 0
	local screenWidth = fixScrt(GetScreenWidth())
	rightDist = screenWidth - rightPos

	-- find correct side
	local side
	if anchorType and (totalWidth < leftPos) and (anchorType == "ANCHOR_LEFT" or anchorType == "ANCHOR_TOPLEFT" or anchorType == "ANCHOR_BOTTOMLEFT") then
		side = "left"
	elseif anchorType and (totalWidth < rightDist) and (anchorType == "ANCHOR_RIGHT" or anchorType == "ANCHOR_TOPRIGHT" or anchorType == "ANCHOR_BOTTOMRIGHT") then
		side = "right"
	elseif rightDist < leftPos then
		side = "left"
	else
		side = "right"
	end

	-- see if we should slide the tooltip
	if totalWidth > 0 and (anchorType and anchorType ~= "ANCHOR_PRESERVE") then --we never slide a tooltip with a preserved anchor
		local slideAmount = 0
		if ( (side == "left") and (totalWidth > leftPos) ) then
			slideAmount = totalWidth - leftPos
		elseif ( (side == "right") and (rightPos + totalWidth) >  screenWidth ) then
			slideAmount = screenWidth - (rightPos + totalWidth)
		end

		if slideAmount ~= 0 then -- if we calculated a slideAmount, we need to slide
			if sideAnchorFrame.SetAnchorType then
				sideAnchorFrame:SetAnchorType(anchorType, slideAmount, 0)
			else
				tooltip:SetAnchorType(anchorType, slideAmount, 0)
			end
		end
	end

	if secondaryShown then
		primaryTooltip:SetPoint("TOP", self.anchorFrame, 0, 0)
		secondaryTooltip:SetPoint("TOP", self.anchorFrame, 0, 0)
		if side and side == "left" then
			primaryTooltip:SetPoint("RIGHT", sideAnchorFrame, "LEFT")
		else
			secondaryTooltip:SetPoint("LEFT", sideAnchorFrame, "RIGHT")
		end

		if side and side == "left" then
			secondaryTooltip:SetPoint("TOPRIGHT", primaryTooltip, "TOPLEFT")
		else
			primaryTooltip:SetPoint("TOPLEFT", secondaryTooltip, "TOPRIGHT")
		end
	else
		primaryTooltip:SetPoint("TOP", self.anchorFrame, 0, 0)
		if side and side == "left" then
			primaryTooltip:SetPoint("RIGHT", sideAnchorFrame, "LEFT")
		else
			primaryTooltip:SetPoint("LEFT", sideAnchorFrame, "RIGHT")
		end
	end
	

end



local originalMoneyFrame_Update = MoneyFrame_Update
MoneyFrame_Update = function (frameName, money, forceShow)
	local success, result = pcall(function()
		return originalMoneyFrame_Update(frameName, money, forceShow)
	end)
	if success then
		return result
	else
		return 0
	end
end


local originalSetTooltipMoney = SetTooltipMoney
SetTooltipMoney = function (frame, money, type, prefixText, suffixText)
	local success, result = pcall(function()
		return originalSetTooltipMoney(frame, money, type, prefixText, suffixText)
	end)
	if success then
		return result
	else
		return 0
	end
end

local originalProcessInfo = TooltipDataHandlerMixin.ProcessInfo
function TooltipDataHandlerMixin:ProcessInfo(info)
	local success, result = pcall(function()
		return originalProcessInfo(self, info)
	end)
	if success then
		return result
	else
		return 0
	end
end