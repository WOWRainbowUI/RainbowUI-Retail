--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Quests
local M = KT:NewModule("Quests")
KT.Quests = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar
local tooltipUpdateQuestID = 0
local freeIcons = {}

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHeaderText()
    local suffix
    if db.questsHeaderSuffix then
        local numOver = dbChar.quests.numOver > 0 and " +"..dbChar.quests.numOver or ""
        suffix = dbChar.quests.num.."/"..MAX_QUESTS..numOver
    end
    KT_QuestObjectiveTracker:SetHeaderSuffix(suffix)
end

local function SetupOptions()
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddModuleTab("quests", {
        name = "Quests",
        type = "group",
        order = 3,
        args = {
            header = {
                name = "Header",
                type = "group",
                inline = true,
                order = 1,
                args = {
                    questsHeaderSuffix = {
                        name = "Show number of Quests",
                        desc = "Show number of Quests inside the Quests header.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.questsHeaderSuffix = not db.questsHeaderSuffix
                            SetHeaderText()
                        end,
                        order = 1,
                    },
                },
            },
            content = {
                name = "Content",
                type = "group",
                inline = true,
                order = 2,
                args = {
                    questsObjectiveNumAtStart = {
                        name = "Objective numbers first",
                        type = "toggle",
                        width = 1.7,
                        disabled = function()
                            return not KT.IsSpecialLocale()
                        end,
                        set = function()
                            db.questsObjectiveNumAtStart = not db.questsObjectiveNumAtStart
                            KT:Tracker_Update()
                        end,
                        order = 1.1,
                    },
                    questsObjectiveNumAtStartDesc = {
                        name = "Moves objective numbers to the start of the line.\n"..
                                format(KT.FORMAT.TEXT_BOLD, "Only for deDE, esES, frFR, ruRU locale.").."\n\n",
                        type = "description",
                        width = 1.7,
                        marginLeft = 30,
                        disabled = function()
                            return not KT.IsSpecialLocale()
                        end,
                        order = 1.2,
                    },
                },
            },
            contentQuests = {
                name = "Quests Content",
                type = "group",
                inline = true,
                order = 3,
                args = {
                    questsColorByDifficulty = {
                        name = "Color by difficulty",
                        desc = "Quest titles color by difficulty.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.questsColorByDifficulty = not db.questsColorByDifficulty
                            KT:Tracker_Update()
                        end,
                        order = 1,
                    },
                    questsSpacer1 = {
                        name = " ",
                        type = "description",
                        order = 2,
                    },
                    questsShowLevel = {
                        name = "Show Quest Level",
                        desc = "Show / Hide Quest Level inside the tracker.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.questsShowLevel = not db.questsShowLevel
                            KT:Tracker_Update()
                        end,
                        order = 3,
                    },
                    questsShowTags = {
                        name = "Show Quest Tags",
                        desc = "Show / Hide Quest Tags (type, frequency) inside the tracker.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.questsShowTags = not db.questsShowTags
                            KT:Tracker_Update()
                        end,
                        order = 4,
                    },
                    questsShowZone = {
                        name = "Show Quest Zone",
                        desc = "Show / Hide Quest Zone inside the tracker.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.questsShowZone = not db.questsShowZone
                            KT:Tracker_Update()
                        end,
                        order = 5,
                    },
                    questsAutoTrack = {
                        name = "Auto Quest tracking",
                        desc = "Quests are automatically watched when accepted. Uses Blizzard's value \"autoQuestWatch\".\n"..KT.TEXT.OPTION_WARNING,
                        type = "toggle",
                        width = "normal+half",
                        confirm = true,
                        confirmText = KT.TEXT.OPTION_WARNING,
                        get = function()
                            return GetCVarBool("autoQuestWatch")
                        end,
                        set = function(_, value)
                            SetCVar("autoQuestWatch", value)
                            ReloadUI()
                        end,
                        order = 6,
                    },
                    questsProgressAutoTrack = {
                        name = "Auto Quest progress tracking",
                        desc = "Quests are automatically watched when progress updated. Uses Blizzard's value \"autoQuestProgress\".\n"..KT.TEXT.OPTION_WARNING,
                        type = "toggle",
                        width = "normal+half",
                        confirm = true,
                        confirmText = KT.TEXT.OPTION_WARNING,
                        get = function()
                            return GetCVarBool("autoQuestProgress")
                        end,
                        set = function(_, value)
                            SetCVar("autoQuestProgress", value)
                            ReloadUI()
                        end,
                        order = 7,
                    },
                    questsAutoFocusClosest = {
                        name = "Auto focus closest Quest                            ",  -- space for a wider tooltip
                        --[[desc = "Closest Quest is automatically focussed in specific situations:\n"..
                                "- Quest was turned in and was focused,\n"..
                                "- Quest was abandoned and was focused,\n"..
                                "- Quest was untracked and was focused,\n"..
                                "- World Quest was untracked and was focus,\n"..
                                "- you manually or automatically select a Zone Filter and nothing is focused.",]]
                        desc = format(KT.FORMAT.COLOR_WARNING2, "(Temporarily disabled)"),
                        descStyle = "inline",
                        type = "toggle",
                        width = "normal+half",
                        disabled = true,
                        set = function()
                            db.questsAutoFocusClosest = not db.questsAutoFocusClosest
                        end,
                        order = 8,
                    },
                },
            },
        },
    })
end

local function GetBlockIcon(block)
    local icon = block.icon
    if not icon then
        local numFreeIcons = #freeIcons
        if numFreeIcons > 0 then
            icon = freeIcons[numFreeIcons]
            tremove(freeIcons, numFreeIcons)
            icon:ClearAllPoints()
        else
            icon = CreateFrame("Frame", nil, block, "KT_ObjectiveTrackerBlockIconTemplate")
        end
        icon:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", 1, 8)
        block.icon = icon
    end
    icon:Show()
    return icon
end

local function RemoveBlockIcon(block)
    local icon = block.icon
    if icon then
        tinsert(freeIcons, icon)
        icon:Hide()
        block.icon = nil
    end
end

local function SetHooks()
    local function OnEvent(self, event, ...)
        if event == "QUEST_WATCH_LIST_CHANGED" then
            local questID, added = ...
            if added and not dbChar.filterAuto[1] and KT:Module_IsCollapsed(self) then
                local quest = KT_QuestCache:Get(questID)
                if self:ShouldDisplayQuest(quest) then
                    KT:Module_Expand(self)
                end
            end
        end
    end
    KT_QuestObjectiveTracker:HookScript("OnEvent", OnEvent)
    if KT_CampaignQuestObjectiveTracker then
        KT_CampaignQuestObjectiveTracker:HookScript("OnEvent", OnEvent)
        KT_CampaignQuestObjectiveTracker:RegisterEvent("SUPER_TRACKING_CHANGED")
    end

    hooksecurefunc(KT_QuestObjectiveTracker, "OnFreeBlock", function(self, block)
        block.questCompleted = nil
        KT.QuestButtons_Remove(block)
        RemoveBlockIcon(block)
    end)
    if KT_CampaignQuestObjectiveTracker then
        KT_CampaignQuestObjectiveTracker.OnFreeBlock = KT_QuestObjectiveTracker.OnFreeBlock
    end

    function KT_QuestObjectiveTracker:UntrackQuest(questID)  -- N
        C_QuestLog.RemoveQuestWatch(questID)
        if db.questsAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
            KT.QuestSuperTracking_ChooseClosestQuest()
        end
    end
    if KT_CampaignQuestObjectiveTracker then
        KT_CampaignQuestObjectiveTracker.UntrackQuest = KT_QuestObjectiveTracker.UntrackQuest
    end

    function KT_QuestObjectiveTracker:OnBlockHeaderEnter(block)
        if not db.tooltipShow then return end

        local questLink = GetQuestLink(block.id)
        if not questLink then return end

        KT.GameTooltip_SetPosition(block)

        GameTooltip:SetHyperlink(questLink)

        if db.tooltipShowRewards then
            if KT.HaveQuestRewardData(block.id) then
                tooltipUpdateQuestID = 0
                KT.GameTooltip_AddQuestRewardsToTooltip(GameTooltip, block.id)
            else
                tooltipUpdateQuestID = block.id
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(KT.RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
                C_Timer.After(0.1, function()
                    if tooltipUpdateQuestID == block.id then
                        self:OnBlockHeaderEnter(block)
                    end
                end)
            end
        end

        if IsInGroup() then
            local tooltipData = C_TooltipInfo.GetQuestPartyProgress(block.id, true)
            if tooltipData then
                GameTooltip:AddLine(" ")
                local tooltipInfo = { tooltipData = tooltipData, append = true }
                GameTooltip:ProcessInfo(tooltipInfo)
            end
        end

        if db.tooltipShowID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
        end

        GameTooltip:Show()
    end
    if KT_CampaignQuestObjectiveTracker then
        KT_CampaignQuestObjectiveTracker.OnBlockHeaderEnter = KT_QuestObjectiveTracker.OnBlockHeaderEnter
    end

    function KT_QuestObjectiveTracker:OnBlockHeaderLeave(block)
        if db.tooltipShow then
            tooltipUpdateQuestID = 0
            GameTooltip:Hide()
        end
    end
    if KT_CampaignQuestObjectiveTracker then
        KT_CampaignQuestObjectiveTracker.OnBlockHeaderLeave = KT_QuestObjectiveTracker.OnBlockHeaderLeave
    end

    local function OnOpenDropDown(self)
        local block = self.activeFrame

        local info = KT.Menu_CreateInfo()
        KT.Menu_AddTitle(C_QuestLog.GetTitleForQuestID(block.id))

        local text, func
        if C_SuperTrack.GetSuperTrackedQuestID() ~= block.id then
            text = SUPER_TRACK_QUEST
            func = function()
                C_SuperTrack.SetSuperTrackedQuestID(block.id)
            end
        else
            text = STOP_SUPER_TRACK_QUEST
            func = function()
                C_SuperTrack.SetSuperTrackedQuestID(0)
            end
        end
        KT.Menu_AddButton(text, func)

        KT.Menu_AddButton(OBJECTIVES_SHOW_QUEST_MAP, function()
            KT.OpenService_Open("quest", block.id)
        end)

        if ( C_QuestLog.IsPushableQuest(block.id) and IsInGroup() ) then
            KT.Menu_AddButton(SHARE_QUEST, function()
                QuestUtil.ShareQuest(block.id)
            end)
        end

        KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
            block.parentModule:UntrackQuest(block.id)
        end, (dbChar.filterAuto[1] ~= nil))

        info.disabled = false

        if C_QuestLog.CanAbandonQuest(block.id) then
            KT.Menu_AddButton(ABANDON_QUEST, function()
                QuestMapQuestOptions_AbandonQuest(block.id)
            end)
        end

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", block.id)
    end

    function KT_QuestObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
        if ChatFrameUtil.TryInsertQuestLinkForQuestID(block.id) then
            return;
        end

        if mouseButton ~= "RightButton" then
            local questID = block.id;
            if IsModifiedClick("QUESTWATCHTOGGLE") then
                self:UntrackQuest(questID)
            elseif IsModifiedClick(db.menuWowheadURLModifier) then
                KT:Alert_WowheadURL("quest", questID)
            elseif IsModifiedClick(db.menuYouTubeURLModifier) then
                KT:Alert_YouTubeURL("quest", questID)
            else
                local quest = KT_QuestCache:Get(questID);
                if quest.isAutoComplete and quest:IsComplete() then
                    self:RemoveAutoQuestPopUp(questID);
                    ShowQuestComplete(questID);
                else
                    KT.OpenService_Open("quest", questID)
                end
            end
        else
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end
    if KT_CampaignQuestObjectiveTracker then
        KT_CampaignQuestObjectiveTracker.OnBlockHeaderClick = KT_QuestObjectiveTracker.OnBlockHeaderClick
    end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    if KT_CampaignQuestObjectiveTracker then
        KT:Tracker_RegisterModule("KT_CampaignQuestObjectiveTracker", not self.isAvailable)
    end
    KT:Tracker_RegisterModule("KT_QuestObjectiveTracker", not self.isAvailable)

    SetupOptions()
    SetHooks()

    KT:RegSignal("TRACKER_INITIALIZING", SetHeaderText, self)
    KT:RegSignal("QUESTS_COUNT_UPDATED", SetHeaderText, self)
end