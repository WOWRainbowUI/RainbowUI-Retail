local addonName, addon = ...
local utils = addon.utils
local event = addon.event
local const = addon.const
local dialog = addon.dialog
local config = addon.config
addon.handlers = addon.handlers or {}
local handlers = addon.handlers
handlers.base = handlers.base or utils.class("baseHandler").new()
local baseHandler = handlers.base

--临时表，不写config
--local declined_list = {}

function baseHandler:GetClassTexture(index, parent)
    if not parent.classTextures then
        parent.classTextures = {}
    end

    if not parent.classTextures[index] then
        parent.classTextures[index] = parent:CreateTexture(nil, "ARTWORK")
        parent.classTextures[index]:SetSize(24, 24)
    end

    return parent.classTextures[index]
end

function baseHandler:HideAllClassTextures(parent)
    if not parent.classTextures then
        return
    end

    for k, v in pairs(parent.classTextures) do
        v:Hide()
    end
end

function baseHandler:GetRoleTexture(index, parent)
    if not parent.roleTextures then
        parent.roleTextures = {}
    end

    if not parent.roleTextures[index] then
        parent.roleTextures[index] = parent:CreateTexture(nil, "ARTWORK")
        parent.roleTextures[index]:SetSize(14, 14)
    end

    return parent.roleTextures[index]
end

function baseHandler:HideAllRoleTextures(parent)
    if not parent.roleTextures then
        return
    end

    for k, v in pairs(parent.roleTextures) do
        v:Hide()
    end
end

function baseHandler:GetClassBarTexture(index, parent)
    if not parent.classBarTextures then
        parent.classBarTextures = {}
    end

    if not parent.classBarTextures[index] then
        parent.classBarTextures[index] = parent:CreateTexture(nil, "ARTWORK")
        parent.classBarTextures[index]:SetSize(14, 3)
    end

    return parent.classBarTextures[index]
end

function baseHandler:HideAllClassBarTexture(parent)
    if not parent.classBarTextures then
        return
    end

    for k, v in pairs(parent.classBarTextures) do
        v:Hide()
    end
end
function baseHandler:GetLeaderTexture(parent)
    if not parent.leaderTexture then
        parent.leaderTexture = parent:CreateTexture(nil, "ARTWORK", nil, 1)
        parent.leaderTexture:SetSize(14,14)
        parent.leaderTexture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        parent.leaderTexture:SetRotation(-0.61)
    end

    return parent.leaderTexture
end

function baseHandler:HideLeaderTexture(parent)
    if parent.leaderTexture then
        parent.leaderTexture:Hide()
    end
end

function baseHandler:LFGListSearchEntry_Update(entry, ...)
    local resultID = entry.resultID
    local resultInfo = C_LFGList.GetSearchResultInfo(resultID)
    local leaderName = resultInfo.leaderName
    local showinfo = config:getValue({"showinfo"}, utils.getCategory())
    local activityInfo = C_LFGList.GetActivityInfoTable(resultInfo.activityID);

    
    self:HideAllClassTextures(entry.DataDisplay.Enumerate)
    self:HideAllRoleTextures(entry.DataDisplay.Enumerate)
    self:HideLeaderTexture(entry.DataDisplay.Enumerate)
    self:HideAllClassBarTexture(entry.DataDisplay.Enumerate)

    if showinfo and showinfo.enable then
        if showinfo.showservername then
            local serverNameText = ""
            if (leaderName and leaderName:find("-") ~= nil) then
                local serverName = string.sub(leaderName, leaderName:find("-") + 1, string.len(leaderName))
                serverNameText = " - |" .. ("cFF66CD00") .. serverName .. "|r"
            end
            entry.ActivityName:SetText(entry.ActivityName:GetText() ..  serverNameText)
        end

        --如果发现拒绝过我的队长
        --[[if declined_list[resultID] then
            entry.Name:SetTextColor(0.5, 1, 1)
        end]]

        if utils.getCategory() == const.CATEGORY_TYPE_RAID or utils.getCategory() == const.CATEGORY_TYPE_CLASSRAID then
            if showinfo.showleaderraidprocess and addon.RAID_ENCOUNTER_NUM and addon.RAID_ENCOUNTER_NUM[resultInfo.activityID] then
                local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(resultID)
                local numGroupDefeated = encounterInfo and utils.tnums(encounterInfo) or 0
                local numGroup = addon.RAID_ENCOUNTER_NUM[resultInfo.activityID] or 0
                local name = entry.Name:GetText() or ""
                entry.Name:SetText(string.format("|c%s%d/%d|r %s", numGroupDefeated == numGroup and "FFFF0000" or "FFFFFFFF", numGroupDefeated, numGroup, name))
            end
        elseif utils.getCategory() == const.CATEGORY_TYPE_DUNGEON then
            entry.leaderMPlusRating = resultInfo.leaderOverallDungeonScore or 0

            if showinfo.showclassinfo or showinfo.showclassbar then
                local numMembers = resultInfo.numMembers
                entry.DataDisplay:SetPoint("RIGHT", entry.DataDisplay:GetParent(), "RIGHT", 0, 0)
                
                local orderIndexes = {}
                
                for i = 1, numMembers do
                    local role, class = C_LFGList.GetSearchResultMemberInfo(resultID, i)
                    local orderIndex = utils.tkeyof(LFG_LIST_GROUP_DATA_ROLE_ORDER, role)
                    table.insert(orderIndexes, {orderIndex, class, role, i})
                end
                
                table.sort(orderIndexes,function(a, b)return a[1] < b[1]end)
                local xOffset = (showinfo.showclassbar and showinfo.showclassbar == true) and -74 or -81
                
                for i = 1, numMembers do
                    local class = orderIndexes[i][2] or "NONE"
                    local role = orderIndexes[i][3] or "DAMAGE"
                    local index = orderIndexes[i][4] or 1
                    local classColor = RAID_CLASS_COLORS[class]
                    local r, g, b, _ = classColor:GetRGBA()

                    if showinfo.showclassbar and showinfo.showclassbar == true then
                        local classBarTexture = self:GetClassBarTexture(i, entry.DataDisplay.Enumerate)
                        if classBarTexture then
                            classBarTexture:SetPoint("RIGHT",entry.DataDisplay.Enumerate,"RIGHT",xOffset,-10)
                            classBarTexture:Show()
                            classBarTexture:SetColorTexture(r, g, b, 1)
                        end

                        for j = 2, 5 do
                            if entry.DataDisplay.Enumerate["Icon" .. j] then
                                entry.DataDisplay.Enumerate["Icon" .. j]:SetPoint("CENTER",entry.DataDisplay.Enumerate["Icon" .. j - 1],"CENTER",-15,0)
                                --entry.DataDisplay.Enumerate["Icon" .. i]:Hide()
                            end
                        end

                        xOffset = xOffset + 15
                    else
                        local classTexture = self:GetClassTexture(i, entry.DataDisplay.Enumerate)
                        local roleTexture = self:GetRoleTexture(i, entry.DataDisplay.Enumerate)

                        if classTexture then
                            classTexture:SetAtlas("groupfinder-icon-class-"..string.lower(class))
                            classTexture:SetPoint("RIGHT",entry.DataDisplay.Enumerate,"RIGHT",xOffset,0)
                            classTexture:Show()
                        end

                        if roleTexture then
                            roleTexture:SetAtlas(LFG_LIST_GROUP_DATA_ATLASES[role])
                            roleTexture:SetPoint("TOPLEFT",classTexture,"TOPLEFT",0,3)
                            roleTexture:Show()
                        end

                        if index == 1 then
                            local leaderTexture = self:GetLeaderTexture(entry.DataDisplay.Enumerate)
                            if leaderTexture then
                                leaderTexture:SetPoint("TOPRIGHT",classTexture,"TOPRIGHT",0,3)
                                leaderTexture:Show()
                            end
                        end

                        xOffset = xOffset + 24

                        for j = 1, 5 do
                            if entry.DataDisplay.Enumerate["Icon" .. j] then
                                entry.DataDisplay.Enumerate["Icon" .. j]:Hide()
                            end
                        end
                    end
                end
            end

            if showinfo.showleaderscore then
                local name = entry.Name:GetText() or ""
                local leaderMPlusRatingFormatted = utils.formatMPlusRating(entry.leaderMPlusRating)
                entry.Name:SetText(""..leaderMPlusRatingFormatted .. " " .. name)
            end
        --elseif activityInfo.isRatedPvpActivity then
        elseif utils.getCategory() == const.CATEGORY_TYPE_ARENA or utils.getCategory() == const.CATEGORY_TYPE_RBG then
            local pvpRating = resultInfo.leaderPvpRatingInfo or nil

            if pvpRating then
                if showinfo.showleaderscore then
                    local name = entry.Name:GetText() or ""
                    local leaderPvpRatingFormatted = utils.formatMPlusRating(pvpRating.rating or 0)
                    entry.Name:SetText(""..leaderPvpRatingFormatted .. " " .. name)
                end
            end
        end
    end

    entry.ExpirationTime:SetPoint("RIGHT", entry, "RIGHT", -35, 10)
    entry.DataDisplay:SetPoint("RIGHT", entry, "RIGHT", -28, -5)
    
    if not entry.DataDisplay:IsShown() then
        entry.DataDisplay:Show()
    end
end

function baseHandler:LFGListApplicationViewer_UpdateApplicantMember(member, applicantID, memberIdx, status, pendingStatus, ...)
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
    local grayedOut = not pendingStatus and (status == "failed" or status == "cancelled" or status == "declined" or status == "declined_full" or status == "declined_delisted" or status == "invitedeclined" or status == "timedout" or status == "inviteaccepted" or status == "invitedeclined");
    if not activeEntryInfo then
        return
    end
    
    if utils.getCategory() ~= const.CATEGORY_TYPE_DUNGEON then
        return
    end
    
    local textName = member.Name:GetText()
    local _, className, _, _, _, _, _, _, _, _, relationship, dungeonScore  = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
    
    local bestDungeonScoreForEntry = C_LFGList.GetApplicantDungeonScoreForListing(applicantID, memberIdx, activeEntryInfo.activityID);
    local scoreText = utils.formatMPlusRating(dungeonScore)

    local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(bestDungeonScoreForEntry.mapScore) or HIGHLIGHT_FONT_COLOR
    local bestRunString = color:WrapTextInColorCode(bestDungeonScoreForEntry.mapScore)
    --local bestRunString = bestDungeonScoreForEntry and ("|" .. (bestDungeonScoreForEntry.finishedSuccess and "cFF00FF00" or "cFFFF0000" ).. bestDungeonScoreForEntry.bestRunLevel .. "|r") or ""
    member.Rating:SetText(" " .. bestRunString .. "/" .. scoreText)
    member.Rating:SetWidth(0)
    -- LFGListApplicationViewerScrollFrameButton1.Member1.DungeonScore

    --"ItemLevel", "TOPLEFT", 39, 5
    member.ItemLevel:SetPoint("CENTER", member, "LEFT", 170, 0)
    --member.DungeonScore:SetPoint("CENTER", member, "LEFT", 219, 0)
    
    local nameLength = 100
    if (relationship) then
        nameLength = nameLength - 22
    end
    
    if (member.Name:GetWidth() > nameLength) then
        member.Name:SetWidth(nameLength)
    end
end

function baseHandler:LFGListApplicationDialog_OnShow(frame)
    --功能未开启，则跳过，走默认逻辑
    local shortcutoption = config:getValue({"shortcutoption"}, utils.getCategory())
    if not shortcutoption or not shortcutoption.enable then
        return
    end

    if not shortcutoption.autorolecheck then
        return
    end

    frame.SignUpButton:Click()

    --[[
    --根据默认选择，不做任何调整
    if PremakeGroupsHelperConfig.filter.quicksingnup.role == "DEFAULT" then
        LFGListApplicationDialog.SignUpButton.Click(LFGListApplicationDialog.SignUpButton)
        return
    end
        
    local roleKeyLookup = {
        ["TANK"] = LFGListApplicationDialog.TankButton,
        ["HEALER"] = LFGListApplicationDialog.HealerButton,
        ["DAMAGER"] = LFGListApplicationDialog.DamagerButton,
    }

    for k, v in pairs(roleKeyLookup) do
        v.CheckButton:SetChecked(false)
    end

    --获取专精对于该职业来说是否可用
    local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles()
    local roleKeyCheck = {
        ["TANK"] = availTank,
        ["HEALER"] = availHealer,
        ["DAMAGER"] = availDPS,
    }

    --如果未设置则默认为DEFAULT
    local playerRole = PremakeGroupsHelperConfig.filter.quicksingnup.role or "DEFAULT"

    --根据自己当前专精的职责，进行职责确认
    if not roleKeyCheck[playerRole] then
        --如果不可用，则取当前
        playerRole = GetSpecializationRole(GetSpecialization())
    end

    dump(playerRole)

    roleKeyLookup[playerRole].CheckButton:SetChecked(true)

    frame.SignUpButton.Click(frame.SignUpButton)
    ]]
end


function baseHandler:LFDRoleCheckPopup_OnShow(frame)
    --功能未开启，则跳过，走默认逻辑
    local shortcutoption = config:getValue({"shortcutoption"}, utils.getCategory())
    if not shortcutoption or not shortcutoption.enable then
        return
    end

    if not shortcutoption.autorolecheck then
        return
    end

    LFDRoleCheckPopupAcceptButton:Click()

    --frame.SignUpButton:Click()

    --[[
    --根据默认选择，不做任何调整
    if PremakeGroupsHelperConfig.filter.quicksingnup.role == "DEFAULT" then
        LFGListApplicationDialog.SignUpButton.Click(LFGListApplicationDialog.SignUpButton)
        return
    end
        
    local roleKeyLookup = {
        ["TANK"] = LFGListApplicationDialog.TankButton,
        ["HEALER"] = LFGListApplicationDialog.HealerButton,
        ["DAMAGER"] = LFGListApplicationDialog.DamagerButton,
    }

    for k, v in pairs(roleKeyLookup) do
        v.CheckButton:SetChecked(false)
    end

    --获取专精对于该职业来说是否可用
    local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles()
    local roleKeyCheck = {
        ["TANK"] = availTank,
        ["HEALER"] = availHealer,
        ["DAMAGER"] = availDPS,
    }

    --如果未设置则默认为DEFAULT
    local playerRole = PremakeGroupsHelperConfig.filter.quicksingnup.role or "DEFAULT"

    --根据自己当前专精的职责，进行职责确认
    if not roleKeyCheck[playerRole] then
        --如果不可用，则取当前
        playerRole = GetSpecializationRole(GetSpecialization())
    end

    dump(playerRole)

    roleKeyLookup[playerRole].CheckButton:SetChecked(true)

    frame.SignUpButton.Click(frame.SignUpButton)
    ]]
end


function baseHandler:LFGListInviteDialog_OnShow(frame)
    local shortcutoption = config:getValue({"shortcutoption"}, utils.getCategory())
    if not shortcutoption or not shortcutoption.enable then
        return
    end

    if not shortcutoption.autoacceptinvite then
        return
    end

    frame.AcceptButton:Click()
end

function baseHandler:LFGListInviteDialog_OnEnter(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    LFGListUtil_SetSearchEntryTooltip(GameTooltip, frame.resultID)
end

function baseHandler:LFGListInviteDialog_OnLeave(frame)
    GameTooltip:Hide()
end

function baseHandler:LFGListSearchPanelScrollFrameButtons_OnDoubleClick(button)
    LFGListFrame.SearchPanel.SignUpButton:Click()
    --[[
    local shortcutoption = config:getValue({"shortcutoption"}, utils.getCategory())
    if not shortcutoption or not shortcutoption.enable then
        LFGListFrame.SearchPanel.SignUpButton:Click()
        return
    end

    if not shortcutoption.quicksingnup then
        LFGListFrame.SearchPanel.SignUpButton:Click()
        return
    end
    ]]
	--[[PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    dump(LFGListApplicationDialog, "LFGListApplicationDialog")
	C_LFGList.ApplyToGroup(LFGListFrame.SearchPanel.selectedResult, LFGListApplicationDialog.TankButton:IsShown() and LFGListApplicationDialog.TankButton.CheckButton:GetChecked(), LFGListApplicationDialog.HealerButton:IsShown() and LFGListApplicationDialog.HealerButton.CheckButton:GetChecked(), LFGListApplicationDialog.DamagerButton:IsShown() and LFGListApplicationDialog.DamagerButton.CheckButton:GetChecked());
    ]]
end

function baseHandler:LFGListFrameCategorySelectionCategoryButtons_OnDoubleClick(button)
    LFGListFrame.CategorySelection.FindGroupButton:Click()
end

function baseHandler:LFG_LIST_APPLICANT_LIST_UPDATED(frame, hasNewPending, hasNewPendingWithData)
    local shortcutoption = config:getValue({"shortcutoption"}, utils.getCategory())
    if not shortcutoption or not shortcutoption.enable then
        return
    end

    if not shortcutoption.autoinviteapplicate then
        return
    end

    --只有团长可以，助理是不可以的
    local isLeader = UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME);
    if not isLeader then
        return
    end

    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
	if ( not activeEntryInfo ) then
		return
	end

    local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID, activeEntryInfo.questID)
    if not activityInfo then
        return
    end
    local numAllowed = activityInfo.maxNumPlayers
	if ( numAllowed == 0 ) then
		numAllowed = MAX_RAID_MEMBERS
	end

    --判断所有的按钮
    for i = 1, #LFGListFrame.ApplicationViewer.ScrollFrame.buttons do
        local button = LFGListFrame.ApplicationViewer.ScrollFrame.buttons[i]
        if button and button:IsShown() and button:IsEnabled() then
            local currentCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
            local numInvited = C_LFGList.GetNumInvitedApplicantMembers()

            if (button.numMembers + currentCount + numInvited <= numAllowed) then
                button.InviteButton:Click()
            end
        end
    end
end

--[[
function baseHandler:LFG_LIST_APPLICATION_STATUS_UPDATED(searchResultID, newStatus, oldStatus, groupName)
    local resultInfo = C_LFGList.GetSearchResultInfo(searchResultID)
    if (newStatus == "declined" or newStatus == "timedout") and resultInfo.leaderName then
        table.insert(declined_list, searchResultID)
    end
end
]]

function baseHandler:ADDON_LOADED(frame, name)
    if name == addonName then
        config:initConfiguration()
    end
end

function baseHandler:init()
    self.classTextures = {}
    self.roleTextures = {}
    dialog:registerHandlers(self)
    event:registerHandlers(self)
end

--[[
function baseHandler:UNIT_AURA(unitTarget, isFullUpdate, updatedAuras)
    utils.dump(unitTarget, "unitTarget")
    utils.dump(updatedAuras, "updatedAuras")
end]]

baseHandler:init()