local addonName, addon = ...
local utils = addon.utils
local event = addon.event
local const = addon.const
local lang = addon.language
local handlers = addon.handlers
handlers.groupinfo = handlers.groupinfo or utils.class("groupInfoHandler").new()
local groupInfoHandler = handlers.groupinfo

function groupInfoHandler:check()
    --兼容ElvUI
    local E = _G.ElvUI and _G.ElvUI[1]
    if E and E.db and E.db.WT 
        and E.db.WT.tooltips 
        and E.db.WT.tooltips.groupInfo 
        and E.db.WT.tooltips.groupInfo.enable 
        and E.db.WT.tooltips.groupInfo.enable == true then
            
        return false
    end

    return true
end

function groupInfoHandler:LFGListUtil_ShowGroupInfo(tooltip, resultID)
    --local resultID = frame.resultID
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID);

    --dump(activityInfo, "activityInfo")
    if not activityInfo then
        return
    end

    -- do not show members where Blizzard already does that
    if activityInfo.displayType == LE_LFG_LIST_DISPLAY_TYPE_CLASS_ENUMERATE then 
        return
    end

    if searchResultInfo.isDelisted or not tooltip:IsShown() then 
        return 
    end

    --[[tooltip:AddLine("resultID:" .. resultID)]]
    tooltip:AddLine(" ")
    tooltip:AddLine(CLASS_ROLES)

    local roles = {}
    local classInfo = {}

    for i = 1, searchResultInfo.numMembers do
        local role, class, classLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)
        classInfo[class] = {
            name = classLocalized,
            color = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR
        }

        if not roles[role] then
            roles[role] = {}
        end

        if not roles[role][class] then
            roles[role][class] = 0
        end

        roles[role][class] = roles[role][class] + 1
    end

    local displayOrder = {
        [1] = "TANK",
        [2] = "HEALER",
        [3] = "DAMAGER"
    }

    local RoleStrings = {
        TANK = '|TInterface/LFGFrame/LFGRole:16:16:0:0:64:16:32:48:0:16|t',
        HEALER = '|TInterface/LFGFrame/LFGRole:16:16:0:0:64:16:48:64:0:16|t',
        DAMAGER = '|TInterface/LFGFrame/LFGRole:16:16:0:0:64:16:16:32:0:16|t',
    }

    local roleText = {
        TANK = "|cff00a8ff" .. lang["Tank"] .. "|r",
        HEALER = "|cff2ecc71" .. lang["Healer"] .. "|r",
        DAMAGER = "|cffe74c3c" .. lang["DPS"] .. "|r"
    }

    for i = 1, #displayOrder do
        local role = displayOrder[i]
        local members = roles[role]
        if members then
            tooltip:AddLine(" ")

            tooltip:AddLine(RoleStrings[role] .. roleText[role])
            for class, counter in pairs(members) do
                local numberText = counter ~= 1 and format(" × %d", counter) or ""
                local className = "|c" .. classInfo[class].color.colorStr ..  classInfo[class].name .. "|r "
                tooltip:AddLine(className .. numberText)
            end
        end
    end
end

function groupInfoHandler:LFGListUtil_SetSearchEntryTooltip(tooltip, resultID, autoAcceptOption)
    if not self:check() then
        return
    end
    
    self:LFGListUtil_ShowGroupInfo(tooltip, resultID)
    tooltip:Show()
end


function groupInfoHandler:init()
    event:registerHandlers(self)
end

groupInfoHandler:init()