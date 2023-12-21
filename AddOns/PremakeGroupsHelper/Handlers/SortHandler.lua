local addonName, addon = ...
local utils = addon.utils
local event = addon.event
local const = addon.const
local config = addon.config
local handlers = addon.handlers
handlers.sort = handlers.sort or utils.class("sortHandler").new()
local sortHandler = handlers.sort

function sortHandler:LFGListUtil_SortSearchResults(results)
    local roleRemainingKeyLookup = {
        ["TANK"] = "TANK_REMAINING",
        ["HEALER"] = "HEALER_REMAINING",
        ["DAMAGER"] = "DAMAGER_REMAINING",
    }

    local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
        local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID)
        local playerRole = GetSpecializationRole(GetSpecialization())
        return roles[roleRemainingKeyLookup[playerRole]] > 0
    end

    local function HasRemainingSlotsForLocalPlayerPartyRoles(lfgSearchResultID)
        local numGroupMembers = GetNumGroupMembers()
    
        if numGroupMembers == 0 then
            -- not in a group
            return HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
        end
    
        local partyRoles = {["TANK"] = 0, ["HEALER"] = 0, ["DAMAGER"] = 0}
    
        for i = 1, numGroupMembers do
            local unit
    
            if i == 1 then
                unit = "player"
            else
                unit = "party" .. (i - 1)
            end
    
            local groupMemberRole = UnitGroupRolesAssigned(unit)
    
            if groupMemberRole == "NONE" then
                groupMemberRole = "DAMAGER"
            end
    
            partyRoles[groupMemberRole] = partyRoles[groupMemberRole] + 1
        end
    
        local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID)
    
        for role, remainingKey in pairs(roleRemainingKeyLookup) do
            if roles[remainingKey] < partyRoles[role] then
                return false
            end
        end
    
        return true
    end

    local function SortSearchResultsCB(searchResultID1, searchResultID2)
        --If one has more friends, do that one first
        local searchResultInfo1 = C_LFGList.GetSearchResultInfo(searchResultID1)
        local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID2)
        local activityInfo1 = C_LFGList.GetActivityInfoTable(searchResultInfo1.activityID, nil, searchResultInfo1.isWarMode) or nil
        local activityInfo2 = C_LFGList.GetActivityInfoTable(searchResultInfo2.activityID, nil, searchResultInfo2.isWarMode) or nil

        --PVP活动不检测空缺职责
        if not activityInfo1.isPvpActivity and not activityInfo2.isPvpActivity then
            local hasRemainingRole1 = HasRemainingSlotsForLocalPlayerPartyRoles(searchResultID1)
            local hasRemainingRole2 = HasRemainingSlotsForLocalPlayerPartyRoles(searchResultID2)

            if (hasRemainingRole1 ~= hasRemainingRole2) then
                return hasRemainingRole1
            end
        end

        if (searchResultInfo1.numBNetFriends ~= searchResultInfo2.numBNetFriends) then
            return searchResultInfo1.numBNetFriends > searchResultInfo2.numBNetFriends
        end
        
        if (searchResultInfo1.numCharFriends ~= searchResultInfo2.numCharFriends) then
            return searchResultInfo1.numCharFriends > searchResultInfo2.numCharFriends
        end
        
        if (searchResultInfo1.numGuildMates ~= searchResultInfo2.numGuildMates) then
            return searchResultInfo1.numGuildMates > searchResultInfo2.numGuildMates
        end
        
        --PVP活动不检测位面
        if not activityInfo1.isPvpActivity and not activityInfo2.isPvpActivity then
            if searchResultInfo1.isWarMode ~= searchResultInfo2.isWarMode then
                return searchResultInfo1.isWarMode == C_PvP.IsWarModeDesired()
            end
        end

        local order = config:getValue({"order"}, utils.getCategory())
        --utils.dump(order, "order")
        if order and order.enable then
            if (activityInfo1 and activityInfo2) then
                local res1Score = 0
                local res2Score = 0
                if ( activityInfo1.isMythicPlusActivity or activityInfo2.isMythicPlusActivity) then
                    res1Score = searchResultInfo1.leaderOverallDungeonScore or 0
                    res2Score = searchResultInfo2.leaderOverallDungeonScore or 0
                end
    
                if (activityInfo1.isRatedPvpActivity or activityInfo2.isRatedPvpActivity) then
                    local res1pvpRating = searchResultInfo1.leaderPvpRatingInfo or nil
                    local res2pvpRating = searchResultInfo2.leaderPvpRatingInfo or nil
        
                    res1Score = res1pvpRating and res1pvpRating.rating or 0
                    res2Score = res2pvpRating and res2pvpRating.rating or 0
    
                    --return res1rating > res2rating
                end

                if order.value == const.ORDER_TYPE_SCORE then
                    return res1Score > res2Score
                end
            end

            if utils.getCategory() == const.CATEGORY_TYPE_RAID or utils.getCategory() == const.CATEGORY_TYPE_CLASSRAID then
                --if addon.RAID_ENCOUNTER_NUM[searchResultInfo1.activityID] or addon.RAID_ENCOUNTER_NUM[searchResultInfo2.activityID] then
                    local encounterInfo1 = C_LFGList.GetSearchResultEncounterInfo(searchResultID1)
                    local numGroupDefeated1= encounterInfo1 and utils.tnums(encounterInfo1) or 0

                    local encounterInfo2 = C_LFGList.GetSearchResultEncounterInfo(searchResultID2)
                    local numGroupDefeated2= encounterInfo2 and utils.tnums(encounterInfo2) or 0

                    if order.value == const.ORDER_TYPE_LESS_PROCESS then
                        return numGroupDefeated1 < numGroupDefeated2
                    elseif order.value == const.ORDER_TYPE_MORE_PROCESS then
                        return numGroupDefeated1 > numGroupDefeated2
                    end
            end

            if order.value == const.ORDER_TYPE_TIME then
                return searchResultInfo1.age < searchResultInfo2.age
            end
        end

        --If we aren't sorting by anything else, just go by ID
        return searchResultID1 < searchResultID2
    end

    table.sort(results, SortSearchResultsCB)

    LFGListFrame.SearchPanel.totalResults = #results
    --[[if #results > 0 then
        LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel)
    end]]
end

--[[
function sortHandler:LFGListUtil_SortApplicants(applicants)
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo();
    if ( not activeEntryInfo ) then
        return;
    end

    local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
    if(not activityInfo) then 
        return;
    end 
    
    local function SortApplicantsCB(applicantID1, applicantID2)
        local applicantInfo1 = C_LFGList.GetApplicantInfo(applicantID1)
        local applicantInfo2 = C_LFGList.GetApplicantInfo(applicantID2)
        if (applicantInfo1 == nil) then
            return false
        end
        
        if (applicantInfo2 == nil) then
            return true
        end
        
        local _, _, _, _, _, _, _, _, _, _, relationship1, dungeonScore1, pvpItemLevel1 = C_LFGList.GetApplicantMemberInfo(applicantInfo1.applicantID, 1)
        local _, _, _, _, _, _, _, _, _, _, relationship2, dungeonScore2, pvpItemLevel2 = C_LFGList.GetApplicantMemberInfo(applicantInfo2.applicantID, 1)
        
        if relationship1 == true then
            return true
        end

        if relationship2 == true then
            return false
        end
        
        --if activityInfo then
        --    if activityInfo.isMythicPlusActivity then
        --        if dungeonScore1 ~= dungeonScore2 then
        --            return dungeonScore1 > dungeonScore2
        --        end
        --    elseif activityInfo.isRatedPvpActivity then
        --        local pvpRatingForEntry1 = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantInfo1.applicantID, 1, activeEntryInfo.activityID) or nil
        --        local pvpRatingForEntry2 = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantInfo2.applicantID, 1, activeEntryInfo.activityID) or nil
        --        
        --        if pvpRatingForEntry1 and not pvpRatingForEntry2 then
        --            return true
        --        end

        --        if pvpRatingForEntry2 and not pvpRatingForEntry1 then
        --            return false
        --        end

        --        if pvpRatingForEntry1.rating ~= pvpRatingForEntry2.rating then
        --            return pvpRatingForEntry1.rating > pvpRatingForEntry2.rating
        --        end

        --        if pvpItemLevel1 ~= pvpItemLevel2 then
        --            return pvpItemLevel1 > pvpItemLevel2
        --        end
        --    end
        --end

        --New items go to the top
        if ( applicantInfo1.isNew ~= applicantInfo2.isNew ) then
            return applicantInfo1.isNew;
        end

        return applicantInfo1.displayOrderID < applicantInfo2.displayOrderID;
    end

    table.sort(applicants, SortApplicantsCB)

    --if #applicants > 0 then
    --    LFGListApplicationViewer_UpdateResults(LFGListFrame.ApplicationViewer)
    --end
end--]]

function sortHandler:init()
    event:registerHandlers(self)
end

--[[
function LFGListGroupDataDisplay_Update(self, activityID, displayData, disabled)
	local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
	if(not activityInfo) then 
		return;
	end

    local displayType = activityInfo.displayType
	displayType = Enum.LfgListDisplayType.ClassEnumerate

    print("update")
	if ( displayType == Enum.LfgListDisplayType.RoleCount ) then
		self.RoleCount:Show();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayRoleCount_Update(self.RoleCount, displayData, disabled);
	elseif ( displayType == Enum.LfgListDisplayType.RoleEnumerate ) then
		self.RoleCount:Hide();
		self.Enumerate:Show();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayEnumerate_Update(self.Enumerate, activityInfo.maxNumPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_ROLE_ORDER);
	elseif ( displayType == Enum.LfgListDisplayType.ClassEnumerate ) then
		self.RoleCount:Hide();
		self.Enumerate:Show();
		self.PlayerCount:Hide();
		LFGListGroupDataDisplayEnumerate_Update(self.Enumerate, activityInfo.maxNumPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_CLASS_ORDER);
	elseif ( displayType == Enum.LfgListDisplayType.PlayerCount ) then
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Show();
		LFGListGroupDataDisplayPlayerCount_Update(self.PlayerCount, displayData, disabled);
	elseif ( displayType == Enum.LfgListDisplayType.HideAll ) then
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
	else
		GMError("Unknown display type");
		self.RoleCount:Hide();
		self.Enumerate:Hide();
		self.PlayerCount:Hide();
	end
end]]

sortHandler:init()