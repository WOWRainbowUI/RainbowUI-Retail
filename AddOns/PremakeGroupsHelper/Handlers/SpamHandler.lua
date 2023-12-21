-------------------------------------------------------------------------------
-- Edit for LFGSpamFilter
-------------------------------------------------------------------------------

local addonName, addon = ...
local utils = addon.utils
local event = addon.event
local const = addon.const
local config = addon.config
local dialog = addon.dialog
local handlers = addon.handlers
handlers.spam = handlers.spam or utils.class("spamHandler").new()
local spamHandler = handlers.spam

--local titlespamlist = {}
function spamHandler:LFGListSearchPanelScrollFrameButtons_OnEnter(button)
    self.resultID = button.resultID
    if PremakeGroupsHelperReportButton then
        PremakeGroupsHelperReportButton:ClearAllPoints()
        PremakeGroupsHelperReportButton:SetPoint('LEFT', button, 'LEFT', -23, 0)
        PremakeGroupsHelperReportButton:Show()
    end
end

function spamHandler:LFGListSearchPanelScrollFrameButtons_OnLeave(button)
    if PremakeGroupsHelperReportButton and not MouseIsOver(PremakeGroupsHelperReportButton) then
        PremakeGroupsHelperReportButton:Hide()
    end
end

function spamHandler:PremakeGroupsHelperReportButton_OnClick(button)
    if PremakeGroupsHelperReportButton and not MouseIsOver(PremakeGroupsHelperReportButton) then
        PremakeGroupsHelperReportButton:Hide()
    end

    if self.resultID then
        --举报类型为广告
        --C_LFGList.ReportSearchResult(self.resultID, 'lfglistspam')

        local reportInfo = ReportInfo:CreateReportInfoFromType(Enum.ReportType.GroupFinderPosting, self.resultID);
        --reportInfo:SetGroupFinderSearchResultID();
        reportInfo:SetReportMajorCategory(0);
        reportInfo:SetMinorCategoryFlags(256);
        --reportInfo:SetComment(nil);
        --reportInfo.reportPlayerLocation = nil;
        --reportInfo.playerName = "喷到你发慌-凤凰之神";
        _G[C_ReportSystem].SendReport(reportInfo, nil);
        --是否自动举报同标题
        --[[if true then
            local searchResultInfo = C_LFGList.GetSearchResultInfo(self.resultID)
            if not searchResultInfo or not searchResultInfo.name then
                return
            end

            local name = searchResultInfo.name
            local totalResultsFound, results = C_LFGList.GetSearchResults()
            if totalResultsFound > 0 then
                utils.twalk(results, function(searchResultID, _)
                    local searchResultInfo2 = C_LFGList.GetSearchResultInfo(searchResultID)
                    if searchResultInfo2 and searchResultInfo2.name then
                        if searchResultInfo2.name == name then
                            C_LFGList.ReportSearchResult(searchResultID, 'lfglistspam')
                        end
                    end
                end)
            end
        end]]
    end
end

function spamHandler:LFGListUtil_SortSearchResults(results)
    local filteredIDs = {}
    utils.twalk(results, function(searchResultID, _)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(searchResultID)
        if searchResultInfo and searchResultInfo.leaderName then
            local name = utils.normalizePlayerName(searchResultInfo.leaderName)
            local spamfilter = config:getValue({"spamfilter"})
            if spamfilter and spamfilter[name] then
                filteredIDs[searchResultID] = true
            end

            --[[if titlespamlist and titlespamlist[searchResultInfo.name] then
                filteredIDs[searchResultID] = true
            end]]
        end
    end)

    utils.twalk(filteredIDs, function( _, searchResultID)
        utils.tremovebyvalue(results, searchResultID, false)
    end)
end

function spamHandler:ReportSearchResult(resultID, reason)
    if reason ~= "lfglistspam" then
        return
    end

    --从名单里移除这个人
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    if not searchResultInfo or not searchResultInfo.leaderName then
        return
    end

    local name = utils.normalizePlayerName(searchResultInfo.leaderName)
    local spamfilter = config:getValue({"spamfilter"})

    if not spamfilter then
        config:setValue({"spamfilter"}, { [name] = time() })
    else
        spamfilter[name] = time()
    end

    --添加同标题屏蔽项
    --titlespamlist[searchResultInfo.name] = time()

    --刷新页面
    LFGListSearchPanel_UpdateResultList(LFGListFrame.SearchPanel)

    if PremakeGroupsHelperReportButton and not MouseIsOver(PremakeGroupsHelperReportButton) then
        PremakeGroupsHelperReportButton:Hide()
    end
end

function spamHandler:ADDON_LOADED(frame, name)
    if name == addonName then
        dialog:_registerScriptEvent(PremakeGroupsHelperReportButton, "OnClick", "PremakeGroupsHelperReportButton_OnClick")
    end
end

function spamHandler:init()
    event:registerHandlers(self)
    dialog:registerHandlers(self)
end

function spamHandler:PremakeGroupsHelperDialog_OnHide()
    if PremakeGroupsHelperReportButton then
        PremakeGroupsHelperReportButton:Hide()
    end
end

spamHandler:init()