local enabled = nil

local function BUII_AddColoredExpLine(name, tooltip)
	if name == "艾澤拉斯" then
		tooltip:AddLine(name, 1, 1, 1)
	elseif name == "燃燒的遠征" then
		tooltip:AddLine(name, 0, 1, 0)
	elseif name == "巫妖王之怒" then
		tooltip:AddLine(name, 0, 0.8, 1)
	elseif name == "浩劫與重生" then
		tooltip:AddLine(name, 0.8, 0.2, 0)
	elseif name == "潘達利亞之謎" then
		tooltip:AddLine(name, 0, 1, 0.6)
	elseif name == "德拉諾之霸" then
		tooltip:AddLine(name, 0.78, 0.61, 0.43)
	elseif name == "軍臨天下" then
		tooltip:AddLine(name, 0, 0.8, 0)
	elseif name == "決戰艾澤拉斯" then
		tooltip:AddLine(name, 0.20, 0.39, 0.67)
	elseif name == "暗影之境" then
		tooltip:AddLine(name, 0.6, 0.8, 1)
	elseif name == "巨龍群島" then
		tooltip:AddLine(name, 0, 1, 0.6)
	elseif name == "當前賽季" then
    -- Blizz seems to have added a Current Season tag in 10.2.7
    -- to have the same behaviour as before the patch make it Dragonflight
		tooltip:AddLine("巨龍群島", 0, 1, 0.6)
	else
		print("缺少資料片: " .. name)
	end
end

local function BUII_TooltipImprovements_OnTooltipSetItem(tooltip, data)
	if enabled then
		if tooltip == GameTooltip or tooltip == ItemRefTooltip then
			local item = select(3, tooltip:GetItem())
			if item then
				local expansionID = select(15, GetItemInfo(item))
				if expansionID then
					-- EJ_GetTierInfo needs expansionID + 1 to get the correct expansion
					local expansionName = EJ_GetTierInfo(expansionID + 1)
					BUII_AddColoredExpLine(expansionName, tooltip)
				end
			end
		end
	end
end

function BUII_TooltipImprovements_Enabled()
	if enabled == nil then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, BUII_TooltipImprovements_OnTooltipSetItem)
		enabled = true
	end
end

function BUII_TooltipImprovements_Disable()
	enabled = false
end
