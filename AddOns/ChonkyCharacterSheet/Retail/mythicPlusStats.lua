local addonName, ns = ...
local CCS = ns.CCS

if CCS.GetCurrentVersion() ~= CCS.RETAIL then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

local module = {
	Name = "mythicPlusStats",
	CompatibleVersions = { CCS.RETAIL },
}

CCS.Modules[module.Name] = module

local function display_time(timex, spelltimer)
	local timestring = ""
	
	if timex < 0 then timex = timex*-1 end
	
	local hours = floor(mod(timex, 86400)/3600)
	local minutes = floor(mod(timex, 3600)/60)
	local seconds = floor(mod(timex,60))
	if spelltimer == false then
		timestring = format("%02d:%02d:%02d", hours, minutes, seconds)
	else
		if hours > 0 then timestring = timestring .. hours .. "h " end
		if minutes > 0 then timestring = timestring .. format("%02dm ",minutes) end
		if seconds > 0 and hours <= 0 then timestring = timestring .. format("%02ds ", seconds)  end
	end
	return timestring
end

local function stars(runtime, dungeontime)
	local text = "|cFFFFFC33".."|r"
	
	if runtime == 0 then text = "|cFFFFFC33".."|r"
	elseif runtime < (dungeontime * 0.6) then text = "|cFFFFFC33".."***".."|r"
	elseif runtime < (dungeontime * 0.8) then text = "|cFFFFFC33".."**".."|r"
	elseif runtime < dungeontime then text = "|cFFFFFC33".."*".."|r"
	end
	return text
end

local function RunProgression()
	local tf=C_MythicPlus.GetRunHistory(true, false);
	local t20s, t15s, t10s, t7s, t5s, t2s=0,0,0,0,0,0
	local x = 1;
	local maptable = {C_ChallengeMode.GetMapTable()}
	
	while tf[x] do
		local found = false;
		for mapID=1,8 do
			if maptable[1] and maptable[1][mapID] and (tf[x].mapChallengeModeID == maptable[1][mapID]) then
				found = true
			end
		end
		
		if tf[x].completed and found then
			if tf[x].completed and tf[x].level >= 20 then t20s=t20s+1
			elseif tf[x].completed and tf[x].level >= 15 then t15s=t15s+1
			elseif tf[x].completed and tf[x].level >= 10 then t10s=t10s+1
			elseif tf[x].completed and tf[x].level >= 7 then t7s=t7s+1  
			elseif tf[x].completed and tf[x].level >= 5 then t5s=t5s+1  
			elseif tf[x].completed and tf[x].level >= 2 then t2s=t2s+1  
			end
		end
		x=x+1
	end
	
	return t20s, t15s, t10s, t7s, t5s, t2s
end

local function AddTopRunsToTooltip(t)
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, t.info.threshold));
	
	local runHistory = C_MythicPlus.GetRunHistory(false, true);
	if #runHistory > 0 then
		local comparison = function(entry1, entry2)
			if ( entry1.level == entry2.level ) then
				return entry1.mapChallengeModeID < entry2.mapChallengeModeID;
			else
				return entry1.level > entry2.level;
			end
		end
		table.sort(runHistory, comparison);
		for i = 1, t.info.threshold do
			if runHistory[i] then
				local runInfo = runHistory[i];
				local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID);
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name));
			end
		end
	end
	
	local missingRuns = t.info.threshold - #runHistory;
	if missingRuns > 0 then
		local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns();
		while numMythic > 0 and missingRuns > 0 do
			GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_MYTHIC:format(WeeklyRewardsUtil.MythicLevel));
			numMythic = numMythic - 1;
			missingRuns = missingRuns - 1;
		end
		while numHeroic > 0 and missingRuns > 0 do
			GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_HEROIC);
			numHeroic = numHeroic - 1;
			missingRuns = missingRuns - 1;
		end
	end
end


local function ShowIncompleteMythicTooltip(t, tframe, mythictt, worldtt, raidtt)
	GameTooltip:SetOwner(tframe, "ANCHOR_RIGHT", -7, -11);
	GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_UNLOCK_REWARD);
	if t.info.index == 1 then    -- 1st box in this row
		if mythictt then GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE)
		elseif worldtt then GameTooltip_AddNormalLine(GameTooltip, format(GREAT_VAULT_REWARDS_WORLD_INCOMPLETE, 2))
		elseif raidtt then GameTooltip_AddNormalLine(GameTooltip, format(t.info.raidString, 2))
		end
	else
		local globalString="";
		if t.info.index == 2 then    -- 2nd box in this row
			
			if mythictt then globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST;
			elseif worldtt then globalString = GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST;
			elseif raidtt then globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST
			end
			
		else    -- 3rd box
			if mythictt then globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
			elseif worldtt then globalString = GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST;
			elseif raidtt then globalString = GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
			end
		end
		GameTooltip_AddNormalLine(GameTooltip, globalString:format(t.info.threshold - t.info.progress));
		if t.info.progress > 0 and not worldtt then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			local lowestLevel = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(t.info.threshold);
			if lowestLevel == WeeklyRewardsUtil.HeroicLevel then
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_CURRENT_LEVEL_HEROIC:format(t.info.threshold));
			else
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_CURRENT_LEVEL_MYTHIC:format(t.info.threshold, lowestLevel));
			end
		end
	end
	if mythictt then AddTopRunsToTooltip(t); end
	GameTooltip:Show();
end


local function HandlePreviewMythicRewardTooltip(self, itemLevel, upgradeItemLevel, nextLevel)
	local isHeroicLevel = self:IsCompletedAtHeroicLevel();
	if isHeroicLevel then        
		GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_HEROIC, itemLevel));
	else
		GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, self.info.level));
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
		if self.info.threshold == 1 then
			if isHeroicLevel then
				GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_COMPLETE_HEROIC_SHORT);
			else
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT, nextLevel));
			end
		else
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC, nextLevel, self.info.threshold));
		end
	end
end

local function ShowPreviewItemTooltip(t, tframe, mythictt)
	GameTooltip:SetOwner(tframe, "ANCHOR_RIGHT", -7, -11);
	GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_CURRENT_REWARD);
	local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(t.info.id);
	local itemLevel, upgradeItemLevel;
	if itemLink then
		itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);
	end
	if upgradeItemLink then
		upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
	end
	
	if not itemLevel then
		GameTooltip_AddErrorLine(GameTooltip, RETRIEVING_ITEM_INFO);
		t.UpdateTooltip = t.ShowPreviewItemTooltip;
	else
		t.UpdateTooltip = nil;
		if t.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
			t:HandlePreviewRaidRewardTooltip(itemLevel, upgradeItemLevel);
		elseif t.info.type == Enum.WeeklyRewardChestThresholdType.Activities then
			local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(t.info.activityTierID, t.info.level);
			if hasData then
				upgradeItemLevel = nextItemLevel;
			else
				nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(t.info.level);
			end
			HandlePreviewMythicRewardTooltip(t,itemLevel, upgradeItemLevel, nextLevel)
		elseif t.info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
			t:HandlePreviewPvPRewardTooltip(itemLevel, upgradeItemLevel);
		end
		if not upgradeItemLevel then
			GameTooltip_AddColoredLine(GameTooltip, WEEKLY_REWARDS_MAXED_REWARD, GREEN_FONT_COLOR);
		end
	end
	if mythictt then AddTopRunsToTooltip(t); end
	GameTooltip:Show();
end

function CCS.getraiderioscoreplayer(fBtntxt)
	local name = UnitName("player")
	local score=0
	local returnvalue=""
	local scorecolor=""
	
	if C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player") == nil then return "" end
	
	score = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player").currentSeasonScore
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
	local red = color.r
	local green = color.g
	local blue = color.b
	
	scorecolor = format("|cff%.2x%.2x%.2x", red*255,green*255,blue*255)
	
	if scorecolor ~= nil then
		if string.len(CHALLENGE_COMPLETE_DUNGEON_SCORE) < 50 or fBtntxt == false then
			returnvalue = format(CHALLENGE_COMPLETE_DUNGEON_SCORE, format("%s\n", scorecolor) .. score .. format("|r\n") )
		else
			returnvalue = ("M+" .. format("%s\n", scorecolor) .. score .. format("|r\n") )        
		end
	else
		returnvalue = ""
	end
	
	return returnvalue
end

local function UpdateRewardFrame(name, data)
    local frame = _G[name]
    if not frame then return end

    -- FontStrings
    local fs1 = _G[name.."_fs1"]
    local fs2 = _G[name.."_fs2"]
    local fs3 = _G[name.."_fs3"]
    local fs4 = _G[name.."_fs4"]

    -- Textures
    local tex1 = _G[name.."_tex1"]
    local tex2 = _G[name.."_tex2"]
    local tex3 = _G[name.."_tex3"]
    local tex4 = _G[name.."_tex4"]

    -- Update top label
    if fs1 and data.label then
        fs1:SetText(data.label)
        if data.labelColor then
            fs1:SetTextColor(unpack(data.labelColor))
        end
        fs1:Show()
    end

    -- Update ilvl
    if fs2 then
        if data.ilvl then
            fs2:SetText(data.ilvl)
            if data.ilvlColor then
                fs2:SetTextColor(unpack(data.ilvlColor))
            end
            fs2:Show()
        else
            fs2:Hide()
        end
    end

    -- Update difficulty or item name
    if fs3 then
        fs3:SetJustifyH(data.justifyH or "RIGHT")
        fs3:SetText(data.diffText or "")
        if data.diffColor then
            fs3:SetTextColor(unpack(data.diffColor))
        end
        fs3:Show()
    end

    -- Update completion string
    if fs4 and data.completeText then
        fs4:SetText(data.completeText)
        if data.completeColor then
            fs4:SetTextColor(unpack(data.completeColor))
        end
        fs4:Show()
    end

    -- Texture visibility
    if tex1 then tex1:SetShown(data.showTex1 == true) end
    if tex2 then tex2:SetShown(data.showTex2 ~= false) end
    if tex3 then tex3:SetShown(data.showTex3 == true) end

    if tex4 then
        if data.iconTexture then
            tex4:SetTexture(data.iconTexture)
            tex4:Show()
        else
            tex4:Hide()
        end
    end

    -- Tooltip handlers
    if data.tooltipFunc then
        frame:SetScript("OnEnter", function(self) data.tooltipFunc(self) end)
        frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    else
        frame:SetScript("OnEnter", nil)
        frame:SetScript("OnLeave", nil)
    end
end

local function UpdateAffixDisplay(index, affixData)
    if not affixData or not affixData.id then return end

    local name, desc, textureID = C_ChallengeMode.GetAffixInfo(affixData.id)
    local btn = _G["ccsm_aff"..index.."_btn"]
    local tex = _G["ccsm_aff"..index.."_tex"]
    local fs = _G["ccsm_aff"..index.."_fs1"]

    if btn and tex and fs then
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11)
            GameTooltip:SetText(name, 1, 1, 1, 1)
            GameTooltip:AddLine(desc, nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        tex:SetTexture(textureID or "Interface\\Masks\\SquareMask.BLP")
        fs:Show()
        btn:Show()
    end
end

local function updatesideframe()
	if option("showm_sp") ~= true then return end
	
	if CCS.AreSecretsDisabled() then 
		CCS.secretsdisabled = true
		return
	end
	
	local tf = {WeeklyRewardsFrame:GetChildren()};
	local x=1; -- M+
	local x1=1; -- Raid
	local x2=1; -- World
	local tempstring=""

	for _, t in ipairs(tf) do
		if t ~= nil and t.type ~= nil and t.info ~= nil and (t.type ==1 or t.type == 3 or t.type == 6) then
			local progress = t.info.progress
			local threshold = t.info.threshold
			local itemName, itemLevel, iconTexture, tooltipFunc
			local label, ilvl, diffText, completeText
			local showTex1, showTex2, showTex3, showTex4 = false, true, false, false
			local justifyH = "RIGHT"
			local namePrefix, index
			local colorComplete = {1,1,1,1}
			local colorLabel = {1,1,1,1}
			
			-- Determine label format based on reward type
			local function getLabel()
				if t.type == 1 then
					return format(WEEKLY_REWARDS_THRESHOLD_DUNGEONS, threshold)
				elseif t.type == 6 then
					return format(WEEKLY_REWARDS_THRESHOLD_WORLD, threshold)
				elseif t.type == 3 then
					return format(t.info.raidString, threshold)
				end
			end

			if C_WeeklyRewards.HasGeneratedRewards() and t.ItemFrame and t.ItemFrame.displayedItemDBID then
				local itemLink = C_WeeklyRewards.GetItemHyperlink(t.ItemFrame.displayedItemDBID)
				itemName, _, _, itemLevel = C_Item.GetItemInfo(itemLink)
				iconTexture = t.ItemFrame.Icon:GetTexture() or "Interface\\Masks\\SquareMask.BLP"
				tooltipFunc = function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -3, -6)
					GameTooltip:SetWeeklyReward(t.ItemFrame.displayedItemDBID)
				end
				showTex1, showTex2, showTex3, showTex4 = true, false, true, true
				label = getLabel()
				ilvl = nil
				diffText = itemName or ""
				completeText = t.Progress:GetText() or ""
				colorComplete = option("fontcolor_wc_prog_complete")
				justifyH = "LEFT"
			elseif progress >= threshold then
				local exampleLink = ""
				exampleLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(t.info.id or "")
				
				_, _, _, itemLevel = C_Item.GetItemInfo(exampleLink or "")
				progress = threshold
				showTex1, showTex2, showTex3, showTex4 = true, false, true, false
				label = getLabel()
				ilvl = itemLevel or " "
				diffText = t.Progress:GetText() or ""
				completeText = format("%s/%s %s", progress, threshold, COMPLETE)
				colorComplete = option("fontcolor_wc_prog_complete")
				colorLabel = option("fontcolor_wc_obj_complete")
				tooltipFunc = function(self) ShowPreviewItemTooltip(t, self, t.type == 1) end
			else
				showTex1, showTex2, showTex3, showTex4 = false, true, false, false
				label = getLabel()
				diffText = ""
				completeText = format("%s/%s %s", progress, threshold, COMPLETE)
				colorComplete = option("fontcolor_wc_prog_incomplete")
				colorLabel = option("fontcolor_wc_obj_incomplete")
				
				tooltipFunc = function(self)
					ShowIncompleteMythicTooltip(t, self, t.type == 1, t.type == 6, t.type == 3)
				end
			end

			if t.type == 1 then
				namePrefix, index = "ccms_r", x
				x = x + 1
			elseif t.type == 6 then
				namePrefix, index = "ccms_world", x2
				x2 = x2 + 1
			elseif t.type == 3 then
				namePrefix, index = "ccms_raid", x1
				x1 = x1 + 1
			end
			UpdateRewardFrame(namePrefix..index, {
				label = label,
				labelColor = colorLabel,
				ilvl = ilvl,
				ilvlColor = option("fontcolor_wc_ilvl"), -- "fontcolor_wc_ilvl"
				diffText = diffText,
				diffColor = option("fontcolor_wc_diff_complete"), -- "fontcolor_wc_diff_complete"
				completeText = completeText,
				completeColor = colorComplete, 
				showTex1 = showTex1,
				showTex2 = showTex2,
				showTex3 = showTex3,
				showTex4 = showTex4,
				iconTexture = iconTexture,
				justifyH = justifyH,
				tooltipFunc = tooltipFunc
			})
		end
	end

	-- Update the Mythic Plus portion
	if C_MythicPlus.GetCurrentAffixes() == nil or 
	C_MythicPlus.GetCurrentAffixes()[1] == nil or 
	C_MythicPlus.GetCurrentAffixes()[2] == nil or 
	C_MythicPlus.GetCurrentAffixes()[3] == nil then return end 
	
	_G["ccsm_sf"]:SetScale(option("mplus_sp_scale"))
	
	if C_WeeklyRewards.HasAvailableRewards() and _G["ccsm_fs4"] ~= nil then _G["ccsm_fs4"]:Show() else _G["ccsm_fs4"]:Hide() end
	
	local ccsm_fs1 = _G["ccsm_fs1"]

	if C_MythicPlus.GetOwnedKeystoneLevel() ~= nil and C_MythicPlus.GetOwnedKeystoneChallengeMapID() ~= nil then
	local mapName, _, MaptimeLimit, MapTexture = C_ChallengeMode.GetMapUIInfo(C_MythicPlus.GetOwnedKeystoneChallengeMapID())
		tempstring = "("..C_MythicPlus.GetOwnedKeystoneLevel()..") "..mapName
	else 
		tempstring = ADDON_MISSING
	end
	ccsm_fs1:SetText("|cFFFFFC33"..ITEM_UPGRADE_CURRENT.."|r "..tempstring)

	local affixes = C_MythicPlus.GetCurrentAffixes()
	if affixes then
		for i = 1, 5 do
			UpdateAffixDisplay(i, affixes[i])
		end
	end
	
	local ccsm_fs2 = _G["ccsm_fs2"]
	ccsm_fs2:SetText(CCS.getraiderioscoreplayer(false))
	
	local ccsm_fs3 = _G["ccsm_fs3"]
	ccsm_fs3:SetText("")
	ccsm_fs3:Hide()
	
	for x=1,8 do 
		
		local ccsm_bx = _G["ccsm_b"..x] or CreateFrame("Frame", "ccsm_b"..x, _G["ccsm_sf"]);
		local mapID = C_ChallengeMode.GetMapTable()[x] or 0
		local mapspellID = 0
		local mapName, _, MaptimeLimit, MapTexture = C_ChallengeMode.GetMapUIInfo(mapID)
		local MapTable, MapScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID);
		local ccsm_bx_btn1 = _G["ccsm_b"..x.."_btn1"]
		local ccsm_bx_btn2 = _G["ccsm_b"..x.."_btn2"]
		local ccsm_bx_tex1 = _G["ccsm_b"..x.."_tex1"]
		local ccsm_bx_tex2 = _G["ccsm_b"..x.."_tex2"]
		local ccsm_bx_fs1 = _G["ccsm_b"..x.."_fs1"]
		local ccsm_bx_fs2 = _G["ccsm_b"..x.."_fs2"]
		local ccsm_bx_fs3 = _G["ccsm_b"..x.."_fs3"]
		local ccsm_bx_fs4 = _G["ccsm_b"..x.."_fs4"]
		local ccsm_bx_fs7 = _G["ccsm_b"..x.."_fs7"]
		local ccsm_bx_btn1_bg = _G["ccsm_b"..x.."_btn1_bg"] or ccsm_bx_btn1:CreateTexture("ccsm_b"..x.."_btn1_bg", "BACKGROUND", nil)
		local ccsm_bx_btn2_bg = _G["ccsm_b"..x.."_btn2_bg"]
		
		
		ccsm_bx_tex2:SetTexture(MapTexture or 5221804)
		ccsm_bx_fs2:SetText(mapName or " ");
		ccsm_bx_btn2_bg:SetTexture(MapTexture or "Interface\\CovenantRenown\\DragonflightMajorFactionsNiffen.BLP")
		ccsm_bx_btn2_bg:SetTexCoord(0, 1, 0, 1)
		ccsm_bx_btn2_bg:SetAlpha(1)
		
		if ccsm_bx_btn2 then
			ccsm_bx_btn2:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
					GameTooltip:AddDoubleLine(GARRISON_TROPHY_LOCKED_SUBTEXT, "", 1, 1, 1, 1, 1, 1) 
					GameTooltip:Show()
			end)
			ccsm_bx_btn2:SetScript("OnLeave", function() GameTooltip:Hide() end)
			ccsm_bx_btn1:Hide()
		end
		if mapID and mapID == 353 then -- Fix because blizzard...
			if UnitFactionGroup("player") == "Horde" then
				mapspellID =464256
			else
				mapspellID =445418
			end
		elseif mapID and mapID == 247 then -- Fix because blizzard...
			mapspellID =467553
			if IsSpellKnown(467553) then mapspellID =467553 end
			if IsSpellKnown(467555) then mapspellID =467555 end
		elseif CCS.Dungeon_Teleports[mapID] and CCS.Dungeon_Teleports[mapID].spellID and CCS.Dungeon_Teleports[mapID].spellID ~= 0 then
			mapspellID = CCS.Dungeon_Teleports[mapID].spellID
		end
		
		ccsm_bx_btn1:Show()
		
		if mapspellID ~= 0 and IsSpellKnown(mapspellID) then
			local SpellLink = C_Spell.GetSpellLink(mapspellID)
			local ccsm_bx_btn2_fs = _G["ccsm_b"..x.."_btn2_fs"]
			local spellCooldownInfo = nil
			local start = 0
			local duration = 0
			local enabled = 0
			local modRate = 0

			if not CCS.AreSecretsDisabled() then 
				spellCooldownInfo = C_Spell.GetSpellCooldown(mapspellID)
				start = spellCooldownInfo.startTime or 0
				duration = spellCooldownInfo.duration or 0
				enabled = spellCooldownInfo.isEnabled or 0
				modRate = spellCooldownInfo.modRate or 0			
			else
				CCS.secretsdisabled = true
			end
				
			ccsm_bx_btn1_bg:SetTexture(MapTexture or "Interface\\CovenantRenown\\DragonflightMajorFactionsNiffen.BLP")
			ccsm_bx_btn1_bg:SetTexCoord(0, 1, 0, 1)
			ccsm_bx_btn1_bg:SetAlpha(1)
			ccsm_bx_btn1_bg:SetAllPoints(ccsm_bx_btn2_bg)

			
			if ccsm_bx_btn2 then
				ccsm_bx_btn2:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
						if SpellLink then
							GameTooltip:SetHyperlink(SpellLink)
						else
							GameTooltip:AddDoubleLine(GARRISON_TROPHY_LOCKED_SUBTEXT, "", 1, 1, 1, 1, 1, 1) 
						end
						GameTooltip:Show()
						ccsm_bx_btn1_bg:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
				end)
				ccsm_bx_btn2:SetScript("OnLeave", function() GameTooltip:Hide()
				
				ccsm_bx_btn1_bg:SetTexCoord(0,0,0,1,1,0,1,1)
				end)
				ccsm_bx_btn2:SetAttribute("spell", mapspellID)
				ccsm_bx_btn2_fs:SetText("")
				ccsm_bx_btn2:SetScript("OnUpdate", nil)                    
				if duration > 0 and start > 0 then
					ccsm_bx_btn2.start = start
					ccsm_bx_btn2.duration = duration
					ccsm_bx_btn2:SetScript("OnUpdate", function(self) 

							ccsm_bx_btn1_bg:SetTexture(MapTexture or "Interface\\CovenantRenown\\DragonflightMajorFactionsNiffen.BLP")
							ccsm_bx_btn1_bg:SetTexCoord(0, 1, 0, 1)
							ccsm_bx_btn1_bg:SetAlpha(1)							
							local spellCooldownInfo = nil
							local start=self.start
							local duration=self.duration

							if CCS.AreSecretsDisabled() then 
								if self.start > 0 and self.duration > 0 then
								  -- do nothing, we can process everything. 
								else
									CCS.secretsdisabled = true 
									return 
								end
								
							else
									CCS.secretsdisabled = false
									spellCooldownInfo = C_Spell.GetSpellCooldown(mapspellID)
									start = spellCooldownInfo.startTime or 0
									duration = spellCooldownInfo.duration or 0
									self.start = start
									self.duration = duration
							end
							
							if duration > 0 and start > 0 then
								ccsm_bx_btn2_fs:SetText(display_time(start+duration - GetTime(), true))
								--  print("b",x, " ", CCS.Dungeon_Teleports[mapID].spellID, " ", GetSpellCooldown(spellID))
							else
								self.start = 0
								self.duration = 0
								ccsm_bx_btn2_fs:SetText("")  
								ccsm_bx_btn2:SetScript("OnUpdate", nil)
							end
					end)
				else
					ccsm_bx_btn2_fs:SetText("")  
					ccsm_bx_btn2:SetScript("OnUpdate", nil)
				end
				
			end
			
			ccsm_bx_btn1_bg:Show()
			ccsm_bx_btn2_bg:Hide()
		end        
		
		if MapTable ~= nil and MapScore ~= nil then
			local MapFort = TableUtil.FindMax(MapTable, function(MapTable) return MapTable.score; end) or MapTable[1];
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(MapScore) or HIGHLIGHT_FONT_COLOR
			local red = color.r
			local green = color.g
			local blue = color.b
			local scorecolor = format("|cff%.2x%.2x%.2x", red*255,green*255,blue*255)
			
			ccsm_bx_fs1:SetText(format("%s", scorecolor) .. MapScore or " " .. format("|r\n"))
			
			--== Fortified Score and Color
			
			ccsm_bx_fs3:SetText(stars(MapFort and MapFort.durationSec or 0, MaptimeLimit).. (MapFort and MapFort.level or "0"));
			
			color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(MapScore) or HIGHLIGHT_FONT_COLOR
			red = color.r
			green = color.g
			blue = color.b
			scorecolor = format("|cff%.2x%.2x%.2x", red*255,green*255,blue*255)
			
			ccsm_bx_fs4:SetText(format("%s", scorecolor) .. format("%.f", MapScore).. format("|r\n"))
			
			if option("showm_overundertime") then
				if (MapFort and MapFort.durationSec or 0) == 0 then
					ccsm_bx_fs7:SetText("     -")
				elseif (MapFort and MapFort.durationSec or 0) - MaptimeLimit <= 0 then
					ccsm_bx_fs7:SetText(display_time(MapFort and MapFort.durationSec or 0, false).."  ".."(|cFF00AA00-"..display_time((MapFort and MapFort.durationSec or 0) - MaptimeLimit, false).."|r)\n");            
				else
					ccsm_bx_fs7:SetText(display_time(MapFort.durationSec, false).."  ".."(|cFFAA0000+"..display_time((MapFort and MapFort.durationSec or 0) - MaptimeLimit, false).."|r)\n");            
				end
			else
				ccsm_bx_fs7:SetText(display_time(MapFort and MapFort.durationSec or 0, false).."\n");            
			end
		else
			ccsm_bx_fs1:SetText("-")
			ccsm_bx_fs3:SetText("-")
			ccsm_bx_fs4:SetText("-")
			ccsm_bx_fs7:SetText("     -")
		end 
	end
end


local function CreateRewardFrame(name, anchorPoint, anchorFrame, relativePoint, parentFrame, offsetX, offsetY, opts)
    local frame = _G[name] or CreateFrame("Frame", name, parentFrame)
	local bgc = option("wc_bgcolor") or {}
    frame:SetPoint(anchorPoint, anchorFrame, relativePoint, offsetX, offsetY)
    frame:SetSize(200, 75)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(10)
    frame:SetShown(option(opts.showToggle) == true)

    -- Background
    local bg = _G[name.."_bg"] or frame:CreateTexture(name.."_bg", "BACKGROUND", nil, 0)
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 0)
    bg:SetSize(200, 80)
    bg:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\steelboxbg.png")
    bg:Show()

    local bgtex = _G[name.."_bgtex"] or frame:CreateTexture(name.."_bgtex", "BACKGROUND", nil, 1)
    bgtex:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    bgtex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 5)
    bgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    bgtex:SetGradient("Vertical", CreateColor(0, 0, 0, .4), CreateColor(bgc[1] or 0.2, bgc[2] or 0, bgc[3] or 0.3, bgc[4] or 1))
    bgtex:Show()

    -- Icon Textures
    local tex1 = _G[name.."_tex1"] or frame:CreateTexture(name.."_tex1", "ARTWORK")
    tex1:SetPoint("TOP", frame, "TOPLEFT", 0, 3)
    tex1:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\shieldcheck.png")
    tex1:SetSize(35, 35)
    tex1:Hide()

    local tex2 = _G[name.."_tex2"] or frame:CreateTexture(name.."_tex2", "ARTWORK")
    tex2:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 40, 8)
    tex2:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\lock.png")
    tex2:SetSize(40, 40)
    tex2:Show()

    local tex3 = _G[name.."_tex3"] or frame:CreateTexture(name.."_tex3", "ARTWORK", nil, 0)
    tex3:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 4, 10)
    tex3:SetTexture("Interface\\Masks\\SquareMask.BLP")
	local ilvlc = option("wc_ilvlbannercolor") or {}
    tex3:SetGradient("Horizontal", CreateColor(ilvlc[1] or 0.64, ilvlc[2] or 0.21, ilvlc[3] or 0.93, ilvlc[4] or 1), CreateColor(0, 0, 0, 1))
    tex3:SetSize(140, 32)
    tex3:Hide()

    local tex4 = _G[name.."_tex4"] or frame:CreateTexture(name.."_tex4", "ARTWORK", nil, 2)
    tex4:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 28, 10)
    tex4:SetTexture("Interface\\Masks\\SquareMask.BLP")
    tex4:SetSize(32, 32)
    tex4:Hide()

    -- FontStrings
    local fs1 = _G[name.."_fs1"] or frame:CreateFontString(name.."_fs1")
    fs1:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -7)
    fs1:SetSize(165, 20)
    fs1:SetFont(option("fontname_wc_obj") or CCS.fontname, option("fontsize_wc_obj") or 10, CCS.textoutline)
	if option("showfontshadow") == true then
		fs1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		fs1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
    fs1:SetJustifyH("LEFT")
	local fs1c = option("fontcolor_wc_obj_incomplete") or {}
    fs1:SetText(format(WEEKLY_REWARDS_THRESHOLD_DUNGEONS, 4))
	fs1:SetTextColor(fs1c[1] or 0.62, fs1c[2] or 0.62, fs1c[3] or 0.62, fs1c[4] or 1)
    fs1:Show()


    local fs2 = _G[name.."_fs2"] or frame:CreateFontString(name.."_fs2")
    fs2:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 28, 16)
    fs2:SetFont(option("fontname_wc_ilvl") or CCS.fontname, option("fontsize_wc_ilvl") or 20, CCS.textoutline)
	if option("showfontshadow") == true then
		fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	local fs2c = option("fontcolor_wc_ilvl") or {}
	fs2:SetTextColor(fs2c[1] or 1, fs2c[2] or 1, fs2c[3] or 1, fs2c[4] or 1)

    fs2:SetJustifyH("LEFT")
    fs2:SetText("---")
    fs2:Hide()

    local fs3 = _G[name.."_fs3"] or frame:CreateFontString(name.."_fs3")
    fs3:SetPoint("RIGHT", frame, "RIGHT", -12, -6)
    fs3:SetFont(option("fontname_wc_diff") or CCS.fontname, option("fontsize_wc_diff") or 10, CCS.textoutline)
	if option("showfontshadow") == true then
		fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	local fs3c = option("fontcolor_wc_diff_complete") or {}
	fs3:SetTextColor(fs3c[1] or 0.12, fs3c[2] or 1, fs3c[3] or 0, fs3c[4] or 1)
    fs3:SetJustifyH("RIGHT")
    fs3:SetJustifyV("TOP")
    fs3:SetSize(123, 20)
    fs3:SetText("")
	fs3:Show()

    local fs4 = _G[name.."_fs4"] or frame:CreateFontString(name.."_fs4")
    fs4:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 6)
    fs4:SetFont(option("fontname_wc_prog") or CCS.fontname, option("fontsize_wc_prog") or 10, CCS.textoutline)
	if option("showfontshadow") == true then
		fs4:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		fs4:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	local fs4c = option("fontcolor_wc_prog_incomplete") or {}
	fs4:SetTextColor(fs4c[1] or 0.62, fs4c[2] or 0.62, fs4c[3] or 0.62, fs4c[4] or 1)
    fs4:SetJustifyH("RIGHT")
    fs4:SetText("0/1 "..COMPLETE)
    fs4:Show()

    return frame
end


local function CreateAffixButton(index, anchorFrame, parentFrame)
    local name = "ccsm_aff"..index

    -- Create button
    local btn = _G[name.."_btn"] or CreateFrame("Button", name.."_btn", parentFrame)
    if index == 1 then
        btn:SetPoint("TOPLEFT", anchorFrame, "BOTTOMRIGHT", -185, -4)
    else
        btn:SetPoint("LEFT", _G["ccsm_aff"..(index - 1).."_btn"], "RIGHT", 5, 0)
    end
    btn:SetSize(32, 32)
    btn:SetFrameStrata("DIALOG")
    btn:Hide()

    -- Create font string
    local fs = _G[name.."_fs1"] or btn:CreateFontString(name.."_fs1")
    fs:SetPoint("TOP", btn, "BOTTOM", 0, -3)
    fs:SetFont(option("fontname_mplus_affix") or CCS.fontname, option("fontsize_mplus_affix") or 11, CCS.textoutline)
	if option("showfontshadow") == true then
		fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
    fs:SetTextColor(
        option("fontcolor_mplus_affix")[1] or 1,
        option("fontcolor_mplus_affix")[2] or 1,
        option("fontcolor_mplus_affix")[3] or 1,
        option("fontcolor_mplus_affix")[4] or 1
    )
    fs:SetText("") -- placeholder, updated later
    fs:Hide()

    -- Create texture
    local tex = _G[name.."_tex"] or btn:CreateTexture(name.."_tex", "BACKGROUND")
    tex:SetAllPoints()
    tex:SetSize(32, 32)
    tex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    tex:Show()

    return btn
end

local function initializeframes()
    if InCombatLockdown()then CCS.secretsdisabled = true return end
	if option("showm_sp") ~= true then return end
	
	local bgr, bgg, bgb, bgalpha = option("ccsmbgcolor")[1], option("ccsmbgcolor")[2], option("ccsmbgcolor")[3], option("ccsmbgcolor")[4];
	
	-- Create the basic side frame
	local ccsm_af = _G["ccsm_af"] or CreateFrame("Frame", "ccsm_af", CharacterFrame, "SecureHandlerBaseTemplate");
	local ccsm_sf = _G["ccsm_sf"] or CreateFrame("Frame", "ccsm_sf", CharacterFrame, "SecureHandlerBaseTemplate");

	local hpad = option("hpad") or 279
	local sheetscale = option("sheetscale") or 1

	-- offset in raw pixels, not scaled twice
	local offsetX = (60 + hpad)

    if C_AddOns.IsAddOnLoaded("DejaCharacterStats") then
		ccsm_af:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", offsetX-63, 0)
		ccsm_af:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT", offsetX-63, 0)
	else
		ccsm_af:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", offsetX, 0)
		ccsm_af:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT", offsetX, 0)
	end
	
	ccsm_sf:SetPoint("TOPLEFT", ccsm_af, "TOPRIGHT", 0, 0); 
	ccsm_sf:SetSize(660, 640)  
	ccsm_sf:SetScale(option("mplus_sp_scale"))
	ccsm_sf.throttle = 0;

	local sf_bg = _G["ccsm_sf_bg"] or ccsm_sf:CreateTexture("ccsm_sf_bg", "BACKGROUND", nil, 1)        
	local sf_topbar = _G["ccsm_sf_tb"] or ccsm_sf:CreateTexture("ccsm_sf_tb", "BACKGROUND", nil, 2)
	local sf_topstreaks = _G["ccsm_sf_ts"] or ccsm_sf:CreateTexture("ccsm_sf_ts", "BACKGROUND", nil, 2)
	local sf_bottombar = _G["ccsm_sf_bb"] or ccsm_sf:CreateTexture("ccsm_sf_bb", "BACKGROUND", nil, 2)


-- 338 x 640 CharacterFrame
-- 884 x 640 CharacterFrameBg

	if option("showm_sp") == true and (UnitLevel("player") == CCS.MaxLevel) and (C_MythicPlus.GetCurrentAffixes() and C_MythicPlus.GetCurrentAffixes()[1]) then
		ccsm_sf:Show()
	else
		ccsm_sf:Hide()
	end
	ccsm_sf:SetShown(ccsm_sf:IsVisible())
	sf_bg:SetAllPoints()
	sf_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
	sf_bg:SetColorTexture(bgr,bgg,bgb,bgalpha)
	
	sf_topbar:SetPoint("TOPLEFT", ccsm_sf, "TOPLEFT")
	sf_topbar:SetPoint("TOPRIGHT", ccsm_sf, "TOPRIGHT")
	sf_topbar:SetHeight(16)
	sf_topbar:SetTexture("1723833")
	sf_topbar:SetTexCoord(0, 1, 0.586, .734)
	
	sf_topstreaks:SetPoint("TOPLEFT", sf_topbar, "BOTTOMLEFT")
	sf_topstreaks:SetPoint("TOPRIGHT", sf_topbar, "BOTTOMRIGHT")
	sf_topstreaks:SetHeight(43)
	sf_topstreaks:SetTexture("1723833")
	sf_topstreaks:SetTexCoord(0, 1, 0, .328)
	
	sf_bottombar:SetPoint("BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT")
	sf_bottombar:SetPoint("BOTTOMRIGHT", ccsm_sf, "BOTTOMRIGHT")
	
	local rewardcount = 0
	
	if option("showm_worldrewards") then rewardcount = rewardcount+1 end
	if option("showm_mplusrewards") then rewardcount = rewardcount+1 end
	if option("showm_raidrewards") then rewardcount = rewardcount+1 end
	
	local bottomheight = rewardcount > 0 and (85 * rewardcount) or 60
	sf_bottombar:SetHeight(bottomheight)
	sf_bottombar:SetTexture("4556093")
	sf_bottombar:SetTexCoord(0, .75, 0, .082) 
	
	-- Create the Header fields
	local ccsm_fs1 = _G["ccsm_fs1"] or  ccsm_sf:CreateFontString("ccsm_fs1")
	local tempstring = ""
	
	ccsm_fs1:SetPoint("TOPLEFT", sf_topbar, "BOTTOMLEFT", 10 ,-4);
	ccsm_fs1:SetFont(option("fontname_mplus_key") or CCS.fontname, (option("fontsize_mplus_key") or 11), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsm_fs1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_fs1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_fs1:SetJustifyH("LEFT")
	ccsm_fs1:SetText("")
	ccsm_fs1:Show()

	local ccsm_fs2 = _G["ccsm_fs2"] or  ccsm_sf:CreateFontString("ccsm_fs2")
	ccsm_fs2:SetPoint("TOP", sf_topbar, "BOTTOM", 0, -35);
	ccsm_fs2:SetFont(option("fontname_mplus_title") or CCS.fontname, (option("fontsize_mplus_title") or 16), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsm_fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_fs2:SetJustifyH("CENTER")
	ccsm_fs2:SetText(CCS.getraiderioscoreplayer(false))
	ccsm_fs2:Show()        
	
	local ccsm_fs3 = _G["ccsm_fs3"] or  ccsm_sf:CreateFontString("ccsm_fs3")
	ccsm_fs3:SetPoint("TOPRIGHT", sf_topbar, "BOTTOMRIGHT", -10, -4);
	ccsm_fs3:SetFont(option("fontname_mplus_title") or CCS.fontname, (option("fontsize_mplus_title") or 12), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsm_fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_fs3:SetJustifyH("RIGHT")
	ccsm_fs3:SetText("")
	ccsm_fs3:Hide()       

	local ccsm_fs4 = _G["ccsm_fs4"] or ccsm_sf:CreateFontString("ccsm_fs4")
	ccsm_fs4:SetPoint("TOP", sf_bottombar, "TOP", 0, 0);
	ccsm_fs4:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 11), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsm_fs4:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_fs4:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end 
	
	ccsm_fs4:SetJustifyH("CENTER")
	ccsm_fs4:SetText("|cFFFFFF00" .. WEEKLY_REWARDS_RETURN_TO_CLAIM .. "|r")
	ccsm_fs4:Show()               

	local affixLevels = { "4", "7", "10", "12", "15" }

	for i = 1, 5 do
		CreateAffixButton(i, sf_topbar, ccsm_sf)
		local fs = _G["ccsm_aff"..i.."_fs1"]
		if fs then
			fs:SetText(affixLevels[i])
		end
	end

	-- Visibility toggles
	local showWorld = option("showm_worldrewards") == true
	local showMPlus = option("showm_mplusrewards") == true
	local showRaid = option("showm_raidrewards") == true

	-- Create all frames unconditionally
	local ccms_world1 = CreateRewardFrame("ccms_world1", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_worldrewards" })
	local ccms_world2 = CreateRewardFrame("ccms_world2", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_worldrewards" })
	local ccms_world3 = CreateRewardFrame("ccms_world3", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_worldrewards" })

	local ccms_r1 = CreateRewardFrame("ccms_r1", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_mplusrewards" })
	local ccms_r2 = CreateRewardFrame("ccms_r2", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_mplusrewards" })
	local ccms_r3 = CreateRewardFrame("ccms_r3", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_mplusrewards" })

	local ccms_raid1 = CreateRewardFrame("ccms_raid1", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_raidrewards" })
	local ccms_raid2 = CreateRewardFrame("ccms_raid2", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_raidrewards" })
	local ccms_raid3 = CreateRewardFrame("ccms_raid3", "BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", ccsm_sf, 0, 0, { showToggle = "showm_raidrewards" })

	-- Apply anchor logic

	-- World Rewards Row
	ccms_world1:SetPoint("BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", 28, 7)
	ccms_world2:SetPoint("BOTTOMLEFT", ccms_world1, "BOTTOMRIGHT", 5, 0)
	ccms_world3:SetPoint("BOTTOMLEFT", ccms_world2, "BOTTOMRIGHT", 5, 0)

	-- Dungeon Rewards Row
	if showWorld then
		ccms_r1:SetPoint("BOTTOMLEFT", ccms_world1, "TOPLEFT", 0, 3)
	else
		ccms_r1:SetPoint("BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", 28, 7)
	end
	ccms_r2:SetPoint("BOTTOMLEFT", ccms_r1, "BOTTOMRIGHT", 5, 0)
	ccms_r3:SetPoint("BOTTOMLEFT", ccms_r2, "BOTTOMRIGHT", 5, 0)

	-- Raid Rewards Row
	if showWorld and not showMPlus then
		ccms_raid1:SetPoint("BOTTOMLEFT", ccms_world1, "TOPLEFT", 0, 3)
	elseif not showWorld and not showMPlus then
		ccms_raid1:SetPoint("BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", 28, 7)
	else
		ccms_raid1:SetPoint("BOTTOMLEFT", ccms_r1, "TOPLEFT", 0, 3)
	end
	ccms_raid2:SetPoint("BOTTOMLEFT", ccms_raid1, "BOTTOMRIGHT", 5, 0)
	ccms_raid3:SetPoint("BOTTOMLEFT", ccms_raid2, "BOTTOMRIGHT", 5, 0)
	
	-- This is where the bars are made
	for x=1,8 do
		local ccsm_bx = _G["ccsm_b"..x] or CreateFrame("Frame", "ccsm_b"..x, _G["ccsm_sf"]) --, "SecureHandlerBaseTemplate");
		local height = 1-((math.max(rewardcount,1)-1)*0.208333);
		
		ccsm_bx:SetSize(650, 51*height)
		ccsm_bx:Show()
		
		local ccsm_bx_tex1 = _G["ccsm_b"..x.."_tex1"] or ccsm_bx:CreateTexture("ccsm_b"..x.."_tex1", "BACKGROUND", nil)
		--ccsm_bx_tex1:ClearAllPoints()
		ccsm_bx_tex1:SetAllPoints()
		ccsm_bx_tex1:SetTexture("Interface\\Masks\\SquareMask.BLP")
		
		if x%2 == 1 then 
			ccsm_bx_tex1:SetColorTexture(0, 0, 0, .4)
		else
			ccsm_bx_tex1:SetColorTexture(.15, .15, .15, .6)
		end
		
		ccsm_bx_tex1:Show()
		
		local ccsm_bx_tex2 = _G["ccsm_b"..x.."_tex2"] or ccsm_bx:CreateTexture("ccsm_b"..x.."_tex2", "ARTWORK", nil)
		ccsm_bx_tex2:SetPoint("TOPLEFT", ccsm_bx, "TOPLEFT", 5, -3)
		ccsm_bx_tex2:SetSize(45*height, 45*height)
		ccsm_bx_tex2:Hide()
		
		local ccsm_bx_btn1 = _G["ccsm_b"..x.."_btn1"] or CreateFrame("Frame","ccsm_b"..x.."_btn1", ccsm_bx)
		ccsm_bx_btn1:SetPoint("TOPLEFT", ccsm_bx, "TOPLEFT",5 ,-3);

		ccsm_bx_btn1:SetSize(math.min(45*height,38),math.min(45*height,38))
		ccsm_bx_btn1:SetFrameStrata("HIGH")
		ccsm_bx_btn1:SetFrameLevel(10)
		ccsm_bx_btn1:Show()
		
		local ccsm_bx_btn1_bg = _G["ccsm_b"..x.."_btn1_bg"] or ccsm_bx_btn1:CreateTexture("ccsm_b"..x.."_btn1_bg", "BACKGROUND", nil)
		ccsm_bx_btn1_bg:SetAllPoints()
		ccsm_bx_btn1_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
		ccsm_bx_btn1_bg:SetColorTexture(0, 0, 0, .3)
		ccsm_bx_btn1_bg:Show()
		
		local ccsm_bx_btn2 = _G["ccsm_b"..x.."_btn2"] or CreateFrame("Button", "ccsm_b"..x.."_btn2", _G["ccsm_sf"], "SecureActionButtonTemplate")--, "SecureHandlerBaseTemplate")
		ccsm_bx_btn2:RegisterForClicks("AnyUp", "AnyDown") 
		ccsm_bx_btn2:SetParent(_G["ccsm_sf"])
		ccsm_bx_btn2:SetFrameStrata("HIGH")
		ccsm_bx_btn2:SetFrameLevel(100)
		ccsm_bx_btn2:SetSize(math.min(45*height,38),math.min(45*height,38))
		ccsm_bx_btn2:SetAttribute("type", "spell")
		ccsm_bx_btn2:SetAttribute("spell", 0)
		ccsm_bx_btn2:SetPoint("LEFT", ccsm_bx, "LEFT", 5, -3)
		ccsm_bx_btn2.start = 0  -- a little trickery
		ccsm_bx_btn2.duration = 0 -- a little trickery
		ccsm_bx_btn2:Show()
		
		local ccsm_bx_btn2_fs = _G["ccsm_b"..x.."_btn2_fs"] or ccsm_bx_btn2:CreateFontString("ccsm_b"..x.."_btn2_fs")
		ccsm_bx_btn2_fs:SetPoint("CENTER", ccsm_bx_btn2, "CENTER",0 ,0);
		ccsm_bx_btn2_fs:SetFont(CCS.fontname, (option("fontsize") or 10), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsm_bx_btn2_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsm_bx_btn2_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end	                                                                
		
		ccsm_bx_btn2_fs:SetJustifyH("CENTER")
		ccsm_bx_btn2_fs:Show()
		
		local ccsm_bx_btn2_bg = _G["ccsm_b"..x.."_btn2_bg"] or ccsm_bx_btn2:CreateTexture("ccsm_b"..x.."_btn2_bg", "BACKGROUND", nil)
		ccsm_bx_btn2_bg:SetAllPoints()
		ccsm_bx_btn2_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
		ccsm_bx_btn2_bg:SetColorTexture(0, 0, 0, .3)
		ccsm_bx_btn2_bg:Show()
		
		local ccsm_bx_fs1 = _G["ccsm_b"..x.."_fs1"] or  ccsm_bx:CreateFontString("ccsm_b"..x.."_fs1") -- Over icon
		ccsm_bx_fs1:SetPoint("CENTER", ccsm_bx_tex2, "CENTER", 0 ,0)
		ccsm_bx_fs1:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 18), CCS.textoutline)
		if option("showfontshadow") == true then
			ccsm_bx_fs1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsm_bx_fs1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end	                                                                
		
		ccsm_bx_fs1:Hide()
		
		local ccsm_bx_fs2 = _G["ccsm_b"..x.."_fs2"] or  ccsm_bx:CreateFontString("ccsm_b"..x.."_fs2") -- Dungeon Name
		ccsm_bx_fs2:SetPoint("LEFT", ccsm_bx_tex2, "RIGHT", 10 ,0);
		ccsm_bx_fs2:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsm_bx_fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsm_bx_fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end	                                                                
		
		ccsm_bx_fs2:SetSize(250, 45*height)
		ccsm_bx_fs2:SetJustifyH("LEFT")
		ccsm_bx_fs2:Show()
		
		local ccsm_bx_fs3 = _G["ccsm_b"..x.."_fs3"] or  ccsm_bx:CreateFontString("ccsm_b"..x.."_fs3") -- Level
		ccsm_bx_fs3:SetPoint("RIGHT", ccsm_bx_tex2, "RIGHT", 325 ,0);
		ccsm_bx_fs3:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsm_bx_fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsm_bx_fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end	                                                                
		
		ccsm_bx_fs3:SetJustifyH("RIGHT")
		ccsm_bx_fs3:Show()
		
		local ccsm_bx_fs4 = _G["ccsm_b"..x.."_fs4"] or  ccsm_bx:CreateFontString("ccsm_b"..x.."_fs4") -- Rating
		ccsm_bx_fs4:SetPoint("RIGHT", ccsm_bx_tex2, "RIGHT", 400 ,0);
		ccsm_bx_fs4:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsm_bx_fs4:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsm_bx_fs4:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end	                                                                
		
		ccsm_bx_fs4:SetJustifyH("RIGHT")
		ccsm_bx_fs4:Show()
		
		local ccsm_bx_fs7 = _G["ccsm_b"..x.."_fs7"] or  ccsm_bx:CreateFontString("ccsm_b"..x.."_fs7") -- Best
		ccsm_bx_fs7:SetPoint("LEFT", ccsm_bx_tex2, "RIGHT", 435 ,0);
		ccsm_bx_fs7:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsm_bx_fs7:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsm_bx_fs7:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end	                                                                
		
		ccsm_bx_fs7:SetJustifyH("RIGHT")
		ccsm_bx_fs7:Show()
	end
	_G["ccsm_b8"]:SetPoint("BOTTOMLEFT", ccsm_sf, "BOTTOMLEFT", 5, sf_bottombar:GetHeight()+3)
	_G["ccsm_b7"]:SetPoint("BOTTOMLEFT", _G["ccsm_b8"], "TOPLEFT", 0, 2)
	_G["ccsm_b6"]:SetPoint("BOTTOMLEFT", _G["ccsm_b7"], "TOPLEFT", 0, 2)
	_G["ccsm_b5"]:SetPoint("BOTTOMLEFT", _G["ccsm_b6"], "TOPLEFT", 0, 2)
	_G["ccsm_b4"]:SetPoint("BOTTOMLEFT", _G["ccsm_b5"], "TOPLEFT", 0, 2)
	_G["ccsm_b3"]:SetPoint("BOTTOMLEFT", _G["ccsm_b4"], "TOPLEFT", 0, 2)
	_G["ccsm_b2"]:SetPoint("BOTTOMLEFT", _G["ccsm_b3"], "TOPLEFT", 0, 2)
	_G["ccsm_b1"]:SetPoint("BOTTOMLEFT", _G["ccsm_b2"], "TOPLEFT", 0, 2)
	
	-- This is where the column header items are made
	-- Fortified
	
	local ccsm_headerlvl_fs = _G["ccsm_headerlvl_fs"] or  ccsm_sf:CreateFontString("ccsm_headerlvl_fs")
	ccsm_headerlvl_fs:SetPoint("BOTTOMRIGHT", ccsm_b1_fs3, "TOPRIGHT", 0 ,15)
	ccsm_headerlvl_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsm_headerlvl_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_headerlvl_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_headerlvl_fs:SetText(LEVEL)
    ccsm_headerlvl_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsm_headerlvl_fs:Show()        
	
	local ccsm_header_fs = _G["ccsm_header_fs"] or  ccsm_sf:CreateFontString("ccsm_header_fs")
	ccsm_header_fs:SetPoint("BOTTOMRIGHT", ccsm_b1_fs4, "TOPRIGHT", 0 ,15)
	ccsm_header_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsm_header_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_header_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_header_fs:SetText(PVP_RATING_HEADER)
    ccsm_header_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsm_header_fs:Show()
	
	local ccsm_fbt_fs = _G["ccsm_fbt_fs"] or  ccsm_sf:CreateFontString("ccsm_fbt_fs")
	ccsm_fbt_fs:SetPoint("BOTTOMLEFT", ccsm_b1_fs7, "TOPLEFT", 0 ,15)
	ccsm_fbt_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsm_fbt_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_fbt_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_fbt_fs:SetText(BEST)
    ccsm_fbt_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsm_fbt_fs:Show()
	
	local ccsm_tp_fs = _G["ccsm_tp_fs"] or  ccsm_sf:CreateFontString("ccsm_tp_fs")
	ccsm_tp_fs:SetPoint("BOTTOMLEFT", ccsm_b1_btn1, "TOPLEFT", 0 , 10)
	ccsm_tp_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsm_tp_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsm_tp_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	ccsm_tp_fs:SetText(TELEPORT_TO_DUNGEON)
    ccsm_tp_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsm_tp_fs:Show()

	_G["ccsm_sf_bg"]:SetColorTexture(bgr,bgg,bgb,bgalpha)

	C_Timer.After(1, function() updatesideframe(); end)
end

function module:Initialize()     
	if option("showm_sp") ~= true then return end
	
	local btn = _G["MPlusScoreBtn"] or CreateFrame("Button", "MPlusScoreBtn", CharacterHeadSlot)
	local textstring = CCS.getraiderioscoreplayer(true) or ""

    if InCombatLockdown()then CCS.secretsdisabled = true return end

	initializeframes()
----
---- Create the main button
----
	btn:SetSize(150, 30)
	btn:SetPoint("BOTTOMLEFT", CharacterHeadSlot, "TOPLEFT", 0, 20)
	btn:SetFrameStrata("HIGH")
	
	-- Create the title text
	local btnfont1 = _G[btn:GetName().."fs1"] or btn:CreateFontString(btn:GetName().."fs1")
	btnfont1:SetPoint("LEFT", btn, "LEFT", 0 ,0)
	btnfont1:SetSize(150, 60)
	btnfont1:SetFont(option("fontname_mplus") or CCS.fontname, (option("fontsize_mplus") or 11), CCS.textoutline)
	if option("showfontshadow") == true then
		btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                                
	
	btnfont1:SetText(textstring)
	btnfont1:SetJustifyH("CENTER")

	
	btn:SetScript("OnClick", function() 
			PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK);
			if not InCombatLockdown() then
				if _G["ccsm_sf"]:IsShown() then 
					_G["ccsm_sf"]:Hide()
				else 
					_G["ccsm_sf"]:Show() 
					if _G["CCSf"] then _G["CCSf"]:Hide() end
					if _G["ccs_sf"] then _G["ccs_sf"]:Hide() end
					if WeeklyRewardsFrame:IsVisible() then WeeklyRewardsFrame:Hide() end
				end
			else
				PlaySound(8959)
				RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
			end
	end)

----
---- Create the second button
----

	-- Create the new button
	local btn2 = _G["MPlusScoreIconBtn"] or CreateFrame("Button", "MPlusScoreIconBtn", PaperDollFrame)
	btn2:SetSize(28, 28)
	btn2:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", -0.5, 0)
	btn2:SetFrameStrata("HIGH")

	btn2._ccs_OnEnter = function(self)
		CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11)
		GameTooltip_SetTitle(CCS.tooltip, format(CHALLENGE_COMPLETE_DUNGEON_SCORE, ""))
		GameTooltip_AddNormalLine(CCS.tooltip, CLICK_HERE_FOR_MORE_INFO)
		GameTooltip_AddNormalLine(CCS.tooltip, "\n"..L["CONTROL_CLICK"])
		CCS.tooltip:Show()
	end

	btn2._ccs_OnLeave = function(self)
		CCS.tooltip:Hide()
	end

	CCS:ApplyIconStyle(btn2, "rightarrow", 20)

	-- Click behavior
	btn2:SetScript("OnClick", function(self, button)
		PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)

		if IsControlKeyDown() and button == "LeftButton" then
			local def = CCS:GetOptionDefByKey("showm_sp_onopen")
			if def then
				CCS:UpdateOption(def, _G["ccsm_sf"]:IsShown())
				C_Timer.After(.1, function() CCS:LoadOptions() end)
			end
			return
		end
		if _G["ccsrf_sf"] and _G["ccsrf_sf"]:IsShown() then _G["ccsrf_sf"]:Hide() end
		
		if not InCombatLockdown() then
			if _G["ccsm_sf"]:IsShown() then
				_G["ccsm_sf"]:Hide()
			else
				_G["ccsm_sf"]:Show()
				if _G["CCSf"] then _G["CCSf"]:Hide() end
				if _G["ccs_sf"] then _G["ccs_sf"]:Hide() end
				if WeeklyRewardsFrame:IsVisible() then WeeklyRewardsFrame:Hide() end
			end
		else
			PlaySound(8959)
			RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
		end
	end)

		btn:SetShown(option("showmythicplusscore"))
		btn2:SetShown(option("showm_sp_btn"))
end

function CCS.MythicPlusEventHandler(event, ...)
    local arg1 = ...
    if InCombatLockdown()then CCS.secretsdisabled = true return end
	if CCS.GetCurrentVersion() ~= CCS.RETAIL then return end
	
	if option("showm_sp") ~= true then 
		if _G["MPlusScoreIconBtn"] then _G["MPlusScoreIconBtn"]:Hide() end
		if _G["MPlusScoreBtn"] then _G["MPlusScoreBtn"]:Hide() end
		return 
	end
	
    if event == "PLAYER_LEVEL_UP" then
	   C_Timer.After(.2, function() 
			if UnitLevel("player") >= 80 then  
				_G["MPlusScoreBtn"]:Show()
				_G["MPlusScoreIconBtn"]:Show()
			end 
		end)
    end
	if event == "CHALLENGE_MODE_COMPLETED" then
		CCS.challengemode = false
	end

	if not WeeklyRewardsFrame then
		CCS:LoadBlizzardAddOns()
	end

    if event == "CCS_EVENT_OPTIONS" then
		initializeframes()
        updatesideframe()
        return true
    end

    if not CCS.mythicUpdatePending then
        CCS.mythicUpdatePending = true
		-- Update the Weekly Rewards Frames
		WeeklyRewardsFrame:FullRefresh()
        C_Timer.After(1, function()
            CCS.mythicUpdatePending = false
            updatesideframe()
			if _G["MPlusScoreBtnfs1"] then _G["MPlusScoreBtnfs1"]:SetText(CCS.getraiderioscoreplayer(true) or "") end
        end)
    end
end