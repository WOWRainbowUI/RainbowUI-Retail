local addonName, addon = ...
local utils = addon.utils
addon.event = addon.event or utils.class("addon.event", addon.schedule).new()
local event = addon.event

function event:registerFrameEvents()
    addon.eventFrame = addon.eventFrame or CreateFrame("Frame", "PremakeGroupsHelperEventFrame")
    
    local frameEvents = {
        "ADDON_LOADED",
        "UNIT_AURA",
        "LFG_LIST_APPLICATION_STATUS_UPDATED",
        'LFG_LIST_APPLICANT_LIST_UPDATED',
    }

    for _, v in pairs(frameEvents) do
        addon.eventFrame:RegisterEvent(v)
    end

    addon.eventFrame:SetScript('OnEvent', function (frame, evt, ...)
        return self:exec(evt, frame, ...)
    end)
end

function event:_hookSecureFunc(v)
    if type(v) == "table" then
        hooksecurefunc(v.table, v.func, self:handler(v.func))
    else
        hooksecurefunc(_G, v, self:handler(v))
    end
end

function event:registerSecurefuncHooks()

    local secureFuncs = {
        "PVEFrame_ShowFrame",
        "LFGListFrame_SetActivePanel",
        "GroupFinderFrame_ShowGroupFrame",
        "LFGListUtil_SetSearchEntryTooltip",
        "LFGListSearchEntry_Update",
        "LFGListUtil_SortSearchResults",
        "LFGListUtil_SortApplicants",
        "LFGListApplicationViewer_UpdateApplicantMember",
        "LFGListInviteDialog_Show",
        --[[{
            ["table"] = C_LFGList,
            ["func"] = "ReportSearchResult",
        },]]
    }
    
    for _, v in ipairs(secureFuncs) do
        self:_hookSecureFunc(v)
    end
end

function event:init()
    self:registerHandlers(self)
    self:registerFrameEvents()
    self:registerSecurefuncHooks()
end

event:init()