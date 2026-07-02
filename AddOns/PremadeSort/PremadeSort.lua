local addonName, PremadeSort = ...
local Settings = {}

local internal = {
    _frame = CreateFrame('frame'),
}

local format = format

local roleRemainingKeyLookup = {
    ["TANK"] = "TANK_REMAINING",
    ["HEALER"] = "HEALER_REMAINING",
    ["DAMAGER"] = "DAMAGER_REMAINING",
};

local checkButton = CreateFrame("CheckButton", "PremadeSortSkipCheckButton", LFGListFrame.SearchPanel.SignUpButton, "ChatConfigCheckButtonTemplate");

checkButton:SetPoint("RIGHT", LFGListFrame.SearchPanel.SignUpButton, "RIGHT")
checkButton:SetHitRectInsets(0,-1,0,0)
checkButton.tooltip = "跳過選擇角色職責，除非之前未選擇。\n\n點兩下某個隊伍總是會跳過角色職責，除非之前未選擇。\n\n設定:\n 輸入 /ps 或 /premadesort";
--checkButton:SetScript("OnClick", nop)

if ElvUI then
    local Skins = ElvUI[1]:GetModule('Skins')
    Skins:HandleCheckBox(checkButton)
end

local SignUp = false
local function OnDoubleClick(self)
    local button = self:GetParent():GetParent():GetParent()
    if button.selectedResult and (not UnitInParty("player") or UnitIsGroupLeader("player")) then
        SignUp = true
        LFGListSearchPanel_SignUp(button)
    end
end

hooksecurefunc("LFGListSearchPanel_SignUp", function()
    if checkButton:GetChecked() or SignUp then
        SignUp = false
        LFGListApplicationDialog.SignUpButton:Click()
    end
end)

local function HasRemainingSlotsForLocalPlayerRole(lfgSearchResultID)
    local roles = C_LFGList.GetSearchResultMemberCounts(lfgSearchResultID);
    local playerRole = GetSpecializationRole(GetSpecialization());
    return roles and roles[roleRemainingKeyLookup[playerRole]] > 0;
end

local function IsDeclined(appStatus)
	return appStatus == "declined" or appStatus == "declined_delisted" or appStatus =="declined_full";
end

local function SortRules(searchResultID1, searchResultID2)
    local searchResultInfo1 = C_LFGList.GetSearchResultInfo(searchResultID1);
    local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID2);
    local activityID1 = searchResultInfo1.activityIDs[1]
    local activityID2 = searchResultInfo2.activityIDs[1]
    local _, appStatus1, pendingStatus1, appDuration1 = C_LFGList.GetApplicationInfo(searchResultID1);
    local _, appStatus2, pendingStatus2, appDuration2 = C_LFGList.GetApplicationInfo(searchResultID2);
    local isDeclined1 = IsDeclined(appStatus1);
    local isDeclined2 = IsDeclined(appStatus2);

    if LFGListFrame.declines then
        isDeclined1 = isDeclined1 or not not LFGListFrame.declines[searchResultInfo1.partyGUID];
        isDeclined2 = isDeclined2 or not not LFGListFrame.declines[searchResultInfo2.partyGUID];
    end

    if isDeclined1 ~= isDeclined2 then
        return isDeclined2;
    end

    if Settings.FriendsEnabled then
        if ( searchResultInfo1.numBNetFriends ~= searchResultInfo2.numBNetFriends ) then
            return searchResultInfo1.numBNetFriends > searchResultInfo2.numBNetFriends;
        end

        if ( searchResultInfo1.numCharFriends ~= searchResultInfo2.numCharFriends ) then
            return searchResultInfo1.numCharFriends > searchResultInfo2.numCharFriends;
        end

        if ( searchResultInfo1.numGuildMates ~= searchResultInfo2.numGuildMates ) then
            return searchResultInfo1.numGuildMates > searchResultInfo2.numGuildMates;
        end
    end

    if (appStatus1 ~= appStatus2) then
        return (appStatus1 ~= "none") and (appStatus2 == "none" or appStatus1 > appStatus2)
    end

    if Settings.SortWarMode then
        local isWarModeZone1 = (activityID1 == 16 or activityID1 == 17)
        local isWarModeZone2 = (activityID2 == 16 or activityID2 == 17)
        local isWarmodeDesired = C_PvP.IsWarModeDesired()
        local wmMatch1 = isWarModeZone1 and (searchResultInfo1.isWarMode == isWarmodeDesired)
        local wmMatch2 = isWarModeZone2 and (searchResultInfo2.isWarMode == isWarmodeDesired)

        if wmMatch1 ~= wmMatch2 then
            return wmMatch1
        end
    end

    if ( searchResultInfo1.age ~= searchResultInfo2.age ) then
        return searchResultInfo1.age < searchResultInfo2.age
    end

    return searchResultID1 < searchResultID2;
end

function SortSearchResults(result)
    -- No longer sort anything on unsecured accounts due taints
    if not IsAccountSecured() then return end
    if not result or (result and next(result) == nil or next(result.results) == nil) then return end

    if LFGListFrame.SearchPanel.categoryID ~= 2 then
        table.sort(result.results, SortRules)
    end
end

local LFGListDisplayType = Enum.LFGListDisplayType

local timeFormatter = CreateFromMixins(SecondsFormatterMixin);
timeFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, false);
timeFormatter:SetStripIntervalWhitespace(true);
--timeFormatter:SetDesiredUnitCount(1);

local function GetGeneralPlaystyleString(enumValue)
	if enumValue == Enum.LFGEntryGeneralPlaystyle.Learning then
		return GROUP_FINDER_GENERAL_PLAYSTYLE1;
	elseif enumValue == Enum.LFGEntryGeneralPlaystyle.FunRelaxed then
		return GROUP_FINDER_GENERAL_PLAYSTYLE2;
	elseif enumValue == Enum.LFGEntryGeneralPlaystyle.FunSerious then
		return GROUP_FINDER_GENERAL_PLAYSTYLE3;
	elseif enumValue == Enum.LFGEntryGeneralPlaystyle.Expert then
		return GROUP_FINDER_GENERAL_PLAYSTYLE4;
	end
	return "";
end

local function OnLFGListSearchEntryUpdate(self)
    if not self.resultID then return end

    local searchResultInfo = C_LFGList.GetSearchResultInfo(self.resultID);
    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode);
    if not activityInfo then return end

    local fullName = activityInfo.fullName
    if (searchResultInfo.isWarMode and (searchResultInfo.activityIDs[1] == 16 or searchResultInfo.activityIDs[1] == 17)) then
        fullName = activityInfo.fullName:gsub("%((.-)%)", "(|cFFFF282E%1|r)")
    end

    self.ActivityName:SetText(fullName)
    local playstyleStr = GetGeneralPlaystyleString(searchResultInfo.generalPlaystyle)

    if not Settings.HideTimestamp then
        local color = searchResultInfo.age < 60 and "|cff65DC3D" or "|cffF7783C"
        local timeStr = searchResultInfo.age <= 0 and "Now" or timeFormatter:Format(searchResultInfo.age, false, true)

        if playstyleStr == "" then
            self.Playstyle:SetText(format("%s%s|r", color, timeStr))
        else
            self.Playstyle:SetText(format("%s%s|r |cff787878|||r %s", color, timeStr, playstyleStr))
        end
    else
        self.Playstyle:SetText(playstyleStr)
    end

    if searchResultInfo.isDelisted then
        self:SetScript('OnDoubleClick', nil);
        return
    end
    self:SetScript('OnDoubleClick', OnDoubleClick);
end

function PremadeSort:OnEvent(e, ...)
    if e == "ADDON_LOADED" and addonName == ... then
        PremadeSortDB = PremadeSortDB or {};
        Settings = PremadeSortDB;
        Settings.SortWarMode = Settings.SortWarMode or true;
        Settings.ColorDisabled = nil;
        --BINDING_HEADER_PREMADESORT = GetAddOnMetadata(addonName, "Title");
    end
end

local function AddMessage(...) _G.DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", tostringall(...))) end

SLASH_PREMADESORT1, SLASH_PREMADESORT2 = '/ps', '/premadesort'
SlashCmdList.PREMADESORT = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
    cmd = cmd and cmd:lower()
    args = args and args:lower()

    local ShowDefault = function()
        AddMessage("|cffEEE4AEPremade Sort: /ps /premadesort|r")
        AddMessage("   Tip: Set a Keybind to refresh LFG under Game Options > Key Bindings > Premade Sort")
        AddMessage("   Show Friends at the top - /ps friends (Toggle)")
        AddMessage("   Sort the Warmode you are not in to the bottom - /ps wm (Toggle)")
        AddMessage("   Hide timestamp - /ps timestamp (Toggle)")
    end

    if not cmd or cmd == "" or cmd == "help" then
        ShowDefault()
    elseif cmd == "friends" then
        if not Settings.FriendsEnabled then
            AddMessage("|cffEEE4AEPremade Sort:|r Friends take priority")
        else
            AddMessage("|cffEEE4AEPremade Sort:|r Friends don't take priority.")
        end
        Settings.FriendsEnabled = not Settings.FriendsEnabled
    elseif cmd == "wm" then
        if not Settings.SortWarMode then
            AddMessage("|cffEEE4AEPremade Sort:|r Sort opposite warmode to bottom.")
        else
            AddMessage("|cffEEE4AEPremade Sort:|r Sorting by time regardless of warmode.")
        end
        Settings.SortWarMode = not Settings.SortWarMode
    elseif cmd == "timestamp" then
        if not Settings.HideTimestamp then
            AddMessage("|cffEEE4AE預組隊伍排序:|r 已隱藏時間標記。")
        else
            AddMessage("|cffEEE4AE預組隊伍排序:|r 已顯示時間標記。")
        end
        Settings.HideTimestamp = not Settings.HideTimestamp
    else
        ShowDefault()
    end
end

function PremadeSort:OnLoad()
    internal._frame:RegisterEvent("ADDON_LOADED")
    internal._frame:RegisterEvent("PLAYER_LOGIN")
    internal._frame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
    internal._frame:SetScript("OnEvent", self.OnEvent)
end

PremadeSort:OnLoad()

hooksecurefunc("LFGListSearchEntry_Update", OnLFGListSearchEntryUpdate);
hooksecurefunc("LFGListUtil_SortSearchResults", SortSearchResults);