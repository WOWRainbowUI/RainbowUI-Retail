--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Hooks")

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local fmod = math.fmod
local format = string.format
local ipairs = ipairs
local max = math.max
local pairs = pairs
local strfind = string.find
local tonumber = tonumber
local tinsert = table.insert

-- WoW API
local _G = _G
local GameTooltip = GameTooltip

local db, dbChar
local changedMixins = {}

local KTF = KT.frame
local OTF = KT_ObjectiveTrackerFrame

local function Default_SetChangedMixin(mixin, parentKey, method, ...)
    tinsert(changedMixins, {
        mixin = mixin,
        parentKey = parentKey,
        method = method,
        modules = { ... }
    })
end

local function Default_UpdateMixins()
    for _, data in ipairs(changedMixins) do
        local modules = #data.modules > 0 and data.modules or KT.MODULES
        for _, module in ipairs(modules) do
            local frame = data.parentKey and _G[module][data.parentKey] or _G[module]
            if frame then
                frame[data.method] = data.mixin[data.method]
            end
        end
    end

    if KT_ScenarioObjectiveTracker then
        for k, v in pairs(KT_ObjectiveTrackerBlockMixin) do
            KT_ScenarioObjectiveTracker.ObjectivesBlock[k] = v
        end
    end
end

local function CreateQuestTags(quest)
    local level, tag = "", ""
    local result = ""

    if db.questsShowLevel then
        level = tostring(quest.level)
    end

    if db.questsShowTags then
        local questID = quest:GetID()
        local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
        local questTag = tagInfo and tagInfo.tagID
        if questTag then
            tag = KT.QUEST_TAGS[questTag] or ""
            if questTag == Enum.QuestTag.Group then
                local suggestedGroup = quest.suggestedGroup
                if suggestedGroup and suggestedGroup > 0 then
                    tag = tag..suggestedGroup
                end
            end
        end

        if C_QuestLog.IsAccountQuest(questID) then
            tag = "*"..tag
        end

        local frequency = quest.frequency
        if frequency == Enum.QuestFrequency.Daily then
            tag = tag.."!"
        elseif frequency == Enum.QuestFrequency.Weekly or frequency == Enum.QuestFrequency.ResetByScheduler then
            tag = tag.."!!"
        end
    end

    if level ~= "" or tag ~= "" then
        result = format("[%s|cff00b3ff%s|r] ", level, tag)
    end

    return result
end

local function GetTaskTimeLeftData(questID)
    local timeString = ""
    local timeColor = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2"]
    local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID)
    if timeLeftMinutes and timeLeftMinutes > 0 then
        timeString = SecondsToTime(timeLeftMinutes * 60)
        if timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES then
            timeColor = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft"]
        end
    end
    return timeString, timeColor
end


function KT.Hooks_ObjectiveTrackerManager()
    function KT.ObjectiveTrackerManager:OnPlayerEnteringWorld(isInitialLogin, isReloadingUI)
        if not isInitialLogin and not isReloadingUI then
            return
        end

        local mainTrackerFrame = KT_ObjectiveTrackerFrame
        self:AddContainer(mainTrackerFrame)

        if self.canAddModules then
            for i, moduleName in ipairs(db.modulesOrder) do
                KT:Module_Setup(moduleName, i)
            end
        end

        self:UpdateAll()
    end
end

function KT.Hooks_ObjectiveTrackerContainer()
    local bck_KT_ObjectiveTrackerContainerMixin_Update = KT_ObjectiveTrackerContainerMixin.Update
    function KT_ObjectiveTrackerContainerMixin:Update(dirtyUpdate)
        if KT.stopUpdate then return end

        bck_KT_ObjectiveTrackerContainerMixin_Update(self, dirtyUpdate)

        KT.QuestButtons_Reanchor()

        KT:Tracker_ShowHeader()
        KT:Tracker_ToggleEmpty()
        KT:Tracker_SetSize()
    end

    hooksecurefunc(OTF.Header, "SetCollapsed", function(self, collapsed)
        local texture = KTF.MinimizeButton:GetNormalTexture()
        if collapsed then
            _DBG("COLLAPSE", true)
            texture:SetTexCoord(0, 0.5, 0, 0.25)
            if KT:Addon_IsModule(KT.Scenario) then
                KT.Scenario:ExternalFrames_Hide()
            end
        else
            _DBG("EXPAND", true)
            texture:SetTexCoord(0, 0.5, 0.25, 0.5)
        end
        MSA_CloseDropDownMenus()
    end)
end

function KT.Hooks_ObjectiveTrackerModule()
    hooksecurefunc(KT_ObjectiveTrackerModuleHeaderMixin, "SetCollapsed", function(self, collapsed)
        local texture = self.Icon
        if collapsed then
            texture:SetTexCoord(0, 0.5, 0.75, 1)
        else
            texture:SetTexCoord(0.5, 1, 0.75, 1)
        end
    end)
    Default_SetChangedMixin(KT_ObjectiveTrackerModuleHeaderMixin, "Header", "SetCollapsed")

    local bck_KT_ObjectiveTrackerModuleMixin_MarkDirty = KT_ObjectiveTrackerModuleMixin.MarkDirty
    function KT_ObjectiveTrackerModuleMixin:MarkDirty()
        if KT.stopUpdate then return end

        bck_KT_ObjectiveTrackerModuleMixin_MarkDirty(self)
    end
    Default_SetChangedMixin(KT_ObjectiveTrackerModuleMixin, nil, "MarkDirty")

    hooksecurefunc(KT_ObjectiveTrackerModuleMixin, "SetNeedsFanfare", function(self, key)
        if KT.stopUpdate and key then
            self.fanfares[key] = nil
        end
    end)
    Default_SetChangedMixin(KT_ObjectiveTrackerModuleMixin, nil, "SetNeedsFanfare")

    function KT_ObjectiveTrackerModuleMixin:OnBlockHeaderLeave(block)
        if db.tooltipShow then
            GameTooltip:Hide()
        end
    end
    Default_SetChangedMixin(KT_ObjectiveTrackerModuleMixin, nil, "OnBlockHeaderLeave", "KT_AchievementObjectiveTracker", "KT_MonthlyActivitiesObjectiveTracker", "KT_InitiativeTasksObjectiveTracker", "KT_ProfessionsRecipeTracker")
end

function KT.Hooks_ObjectiveTrackerBlock()
    function KT_ObjectiveTrackerBlockMixin:AddObjective(objectiveKey, text, template, useFullHeight, dashStyle, colorStyle, adjustForNoText, overrideHeight)  -- RO
        if objectiveKey == "TimeLeft" then
            text, colorStyle = GetTaskTimeLeftData(self.id)
        end

        if self.parentModule.NormalizeObjective then
            text, dashStyle = self.parentModule:NormalizeObjective(text, dashStyle)
        end

        local _, _, leftText, colon, progress, numHave, numNeed, rightText = strfind(text, "(.-)(%s?:?%s?)((%d+)%s?/%s?(%d+))(.*)")
        if progress then
            if tonumber(numHave) > 0 and tonumber(numHave) < tonumber(numNeed) then
                progress = "|cffc8c800" .. progress .. "|r"
            end
            if not db.questsObjectiveNumAtStart then
                text = leftText .. colon .. progress .. rightText
            else
                text = progress
                if rightText ~= " " then
                    text = text .. rightText
                end
                if leftText ~= "" then
                    text = text .. " " .. leftText
                end
            end
        end

        local line = self:GetLine(objectiveKey, template);

        line.progressBar = nil;

        -- dash
        if line.Dash then
            if not dashStyle then
                dashStyle = KT_OBJECTIVE_DASH_STYLE_SHOW;
            end
            if line.dashStyle ~= dashStyle then
                if dashStyle == KT_OBJECTIVE_DASH_STYLE_SHOW then
                    line.Dash:Show();
                    line.Dash:SetText(KT.QUEST_DASH);
                elseif dashStyle == KT_OBJECTIVE_DASH_STYLE_HIDE then
                    line.Dash:Hide();
                    line.Dash:SetText(KT.QUEST_DASH);
                elseif dashStyle == KT_OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE then
                    line.Dash:Hide();
                    line.Dash:SetText(nil);
                else
                    assertsafe(false, "Invalid dash style: " .. tostring(dashStyle));
                end
                line.dashStyle = dashStyle;
            end
            if line.Dash.KTskinID ~= KT.skinID then
                line.Dash:SetFont(KT.font, db.fontSize, db.fontFlag)
                line.Dash:SetShadowColor(0, 0, 0, db.fontShadow)
                line.Dash.KTskinID = KT.skinID
            end
        end

        -- check
        if line.Icon and line.Icon.KTskinID ~= KT.skinID then
            line.Icon:SetSize(db.fontSize, db.fontSize)
            line.Icon:ClearAllPoints()
            line.Icon:SetPoint("TOPLEFT", KT.round(db.fontSize * -0.4) + (db.fontFlag == "" and 0 or 1), 0)
            line.Icon.KTskinID = KT.skinID
        end

        local lineSpacing = self.parentModule.lineSpacing;
        local offsetY = -lineSpacing;

        -- anchor the line
        local anchor = self.lastRegion or self.HeaderText;
        if anchor then
            line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, offsetY);
        else
            line:SetPoint("TOPLEFT", 0, offsetY);
        end
        line:SetPoint("RIGHT", self.rightEdgeOffset, 0);

        -- set the text
        local textHeight = self:SetStringText(line.Text, text, useFullHeight, colorStyle, self.isHighlighted or line.isHighlighted);  -- MSA
        local height = overrideHeight and max(overrideHeight,  textHeight) or textHeight;  -- MSA
        line:SetHeight(height);

        self.height = self.height + height + lineSpacing;

        self.lastRegion = line;

        -- completion state
        if KT.inWorld and type(objectiveKey) == "string" then
            local state = KT.QuestsCache_GetProperty(self.id, "state")
            if strfind(objectiveKey, "Complete") then
                if not state or state ~= "complete" then
                    if db.messageQuest then
                        KT:SetMessage(self.title, 0, 1, 0, ERR_QUEST_COMPLETE_S, "Interface\\GossipFrame\\ActiveQuestIcon", -2, 0)
                    end
                    if db.soundQuest then
                        KT:PlaySound(db.soundQuestComplete)
                    end
                    KT.QuestsCache_UpdateProperty(self.id, "state", "complete")
                end
            elseif strfind(objectiveKey, "Failed") then
                if not state or state ~= "failed" then
                    if db.messageQuest then
                        KT:SetMessage(self.title, 1, 0, 0, ERR_QUEST_FAILED_S, "Interface\\GossipFrame\\AvailableQuestIcon", -2, 0)
                    end
                    KT.QuestsCache_UpdateProperty(self.id, "state", "failed")
                end
            end
        end

        return line;
    end

    function KT_ObjectiveTrackerBlockMixin:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)  -- RO
        if fontString.KTskinID ~= KT.skinID then
            fontString:SetFont(KT.font, db.fontSize, db.fontFlag)
            fontString:SetShadowColor(0, 0, 0, db.fontShadow)
            fontString:SetWordWrap(db.textWordWrap)
            fontString.KTskinID = KT.skinID
        end

        if useFullHeight then
            fontString:SetMaxLines(0);
        else
            fontString:SetMaxLines(2);
        end
        fontString:SetHeight(0);	-- force a clear of internals or GetHeight() might return an incorrect value

        -- fix Blizz bug
        local origWidth = fontString:GetWidth()
        fontString:SetWidth(origWidth + 2)

        fontString:SetText(text);

        local stringHeight = fontString:GetHeight();
        colorStyle = colorStyle or KT_OBJECTIVE_TRACKER_COLOR["Normal"];
        if useHighlight and colorStyle.reverse then
            colorStyle = colorStyle.reverse;
        end
        if fontString.colorStyle ~= colorStyle then
            fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
            fontString.colorStyle = colorStyle;
        end
        return stringHeight;
    end

    function KT_ObjectiveTrackerBlockMixin:UpdateHighlight()
        KT.KT_ObjectiveTrackerBlockMixin.UpdateHighlight(self)

        local colorStyle, colorStyleTag, _
        if self.parentModule == KT_QuestObjectiveTracker or self.parentModule == KT_CampaignQuestObjectiveTracker then
            if self.isHighlighted then
                if self.questCompleted then
                    colorStyle = KT_OBJECTIVE_TRACKER_COLOR["CompleteHighlight"]
                elseif db.questsColorByDifficulty then
                    _, colorStyle = GetQuestDifficultyColor(self.level)
                end
                colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
            else
                if self.questCompleted then
                    colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
                elseif db.questsColorByDifficulty then
                    colorStyle = GetQuestDifficultyColor(self.level)
                end
                colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
            end
        end
        if colorStyle then
            self.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
            self.HeaderText.colorStyle = colorStyle
        end

        if self.fixedTag then
            if self.isHighlighted then
                colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
            else
                colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
            end
            self.fixedTag:SetBackdropColor(colorStyleTag.r, colorStyleTag.g, colorStyleTag.b)
            self.fixedTag.text:SetTextColor(colorStyleTag.r, colorStyleTag.g, colorStyleTag.b)
        end
    end

    function KT_ObjectiveTrackerBlockMixin:SetHeader(text, questID, isQuestComplete, quest)
        local isTask = questID and QuestUtil.IsQuestTrackableTask(questID)
        if questID and not isTask then
            text = CreateQuestTags(quest)..text
            self.level = quest.level
            KT.T_Set("level", self.level, self.parentModule.name, "block")
            self.title = text
            KT.T_Set("title", self.title, self.parentModule.name, "block")
            self.questCompleted = isQuestComplete
            KT.T_Set("questComplete", self.questCompleted, self.parentModule.name, "block")
        end

        KT.KT_ObjectiveTrackerBlockMixin.SetHeader(self, text)

        local colorStyle
        if self.parentModule == KT_QuestObjectiveTracker or self.parentModule == KT_CampaignQuestObjectiveTracker then
            if self.questCompleted then
                colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
            elseif db.questsColorByDifficulty then
                colorStyle = GetQuestDifficultyColor(self.level)
            end
        end
        if colorStyle then
            self.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
            self.HeaderText.colorStyle = colorStyle
        end

        if questID then
            if not isTask then
                local questData = KT.QuestsCache_GetInfo(questID)
                KT.T_Set("cache", questData, self.parentModule.name, "questData")
                if db.questsShowZone and questData then
                    local infoText = questData.zone
                    if infoText then
                        if questData.isCalling then
                            local timeRemaining = GetTaskTimeLeftData(questID)
                            if timeRemaining ~= "" then
                                infoText = infoText.." - "..timeRemaining
                            end
                        end
                        self:AddObjective("Zone", infoText, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE, KT_OBJECTIVE_TRACKER_COLOR["Zone"])
                    end
                end
            else
                if db.tasksShowFaction then
                    local _, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questID)
                    local factionData = factionID and C_Reputation.GetFactionDataByID(factionID)
                    local factionColor = KT_OBJECTIVE_TRACKER_COLOR["Zone"]
                    if factionData then
                        local reputationYieldsRewards = not capped or C_Reputation.IsFactionParagon(factionID)
                        if not reputationYieldsRewards then
                            factionColor = KT_OBJECTIVE_TRACKER_COLOR["Inactive"]
                        end
                        self:AddObjective("Faction", factionData.name, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE, factionColor)
                    end
                end
            end
        end
    end

    function KT_ObjectiveTrackerBlockMixin:AddRightEdgeFrame(settings, identifier, ...)
        local frame
        if settings.template == "KT_QuestObjectiveItemButtonTemplate" then
            KT.QuestButtons_Add(self, 3, 4)
            frame = self.ItemButton
        else
            frame = KT.KT_ObjectiveTrackerBlockMixin.AddRightEdgeFrame(self, settings, identifier, ...)
            frame:SetFrameLevel(self:GetFrameLevel() + 1)
        end
        return frame
    end

    function KT_ObjectiveTrackerBlockMixin:AddProgressBar(id, lineSpacing)
        local progressBar = KT.KT_ObjectiveTrackerBlockMixin.AddProgressBar(self, id, lineSpacing)
        KT.ProgressBar_SetStyle(self, progressBar)
        KT.ProgressBar_SetValue(self, progressBar, id)
        return progressBar
    end

    local function SetTimerBarStyle(block, progressBar)
        if progressBar.KTskinID ~= KT.skinID then
            block.height = block.height - progressBar.height

            local barHeight = max(12, db.fontSize + fmod(db.fontSize, 2))
            progressBar:SetSize(240, barHeight)
            progressBar.height = barHeight

            progressBar.Label:SetWidth(0)
            progressBar.Label:SetPoint("LEFT", KT.dashWidth, 1)
            progressBar.Label:SetFont(LSM:Fetch("font", "Arial Narrow"), db.fontSize, db.fontFlag)
            progressBar.Label:SetText("00:00")
            local labelWidth = progressBar.Label:GetWidth() + 10
            progressBar.Label:SetText()
            progressBar.Label:SetWidth(labelWidth)

            progressBar.Bar:SetSize(205 - KT.dashWidth - labelWidth, 8)
            progressBar.Bar:EnableMouse(false)
            progressBar.Bar:ClearAllPoints()
            progressBar.Bar:SetPoint("LEFT", progressBar.Label, "RIGHT", 0, 0)
            progressBar.Bar.BorderLeft:Hide()
            progressBar.Bar.BorderRight:Hide()
            progressBar.Bar.BorderMid:Hide()

            local border1 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -2)
            border1:SetPoint("TOPLEFT", -1, 1)
            border1:SetPoint("BOTTOMRIGHT", 1, -1)
            border1:SetColorTexture(0, 0, 0)

            local border2 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -3)
            border2:SetPoint("TOPLEFT", -2, 2)
            border2:SetPoint("BOTTOMRIGHT", 2, -2)
            border2:SetColorTexture(0.4, 0.4, 0.4)

            progressBar.Bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
            progressBar.KTskinID = KT.skinID
            progressBar.isSkinned = true  -- ElvUI hack

            block.height = block.height + progressBar.height
        end
    end

    function KT_ObjectiveTrackerBlockMixin:AddTimerBar(duration, startTime)
        local timerBar = KT.KT_ObjectiveTrackerBlockMixin.AddTimerBar(self, duration, startTime)
        SetTimerBarStyle(self, timerBar)
        return timerBar
    end
end

function KT.Hooks_ObjectiveTrackerQuestPOIBlock()
    function KT_ObjectiveTrackerQuestPOIBlockMixin:AddPOIButton(questID, isComplete, isSuperTracked, isWorldQuest)  -- R
        local style
        if self.poiInfo then
            style = KT_POIButtonUtil.Style[self.poiInfo.areaPoiID and "AreaPOI" or "BonusObjective"]
        elseif self.poiIsWorldQuest then
            style = KT_POIButtonUtil.Style.WorldQuest
        elseif self.poiIsComplete then
            style = KT_POIButtonUtil.Style.QuestComplete
        else
            style = KT_POIButtonUtil.Style.QuestInProgress
        end
        local poiButton = self:GetPOIButton(style)
        poiButton:SetPoint("TOPRIGHT", self.HeaderText, "TOPLEFT", -7, 3)
        poiButton:SetPingWorldMap(isWorldQuest)
    end
end

function KT.Hooks_ObjectiveTracker()
    function KT_ObjectiveTracker_ToggleDropDown(frame, handlerFunc)
        local dropDown = KT.DropDown;
        if ( dropDown.activeFrame ~= frame ) then
            MSA_CloseDropDownMenus();
        end
        dropDown.activeFrame = frame;
        dropDown.initialize = handlerFunc;
        MSA_ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    end
end

function KT.Hooks_POIButton()
    -- POIButton.lua
    hooksecurefunc(KT_POIButtonMixin, "UpdateButtonStyle", function(self)
        self.questTagInfo = nil  -- fix Blizz bug
        if self.Display.SubTypeIcon and self.hideSubTypeIcon then
            self.Display.SubTypeIcon:Hide()
        end
        self.Glow:SetShown(false)
    end)
end

function KT.Hooks_ContentTrackingManager()
    if not KT_AdventureObjectiveTracker then return end

    -- ContentTrackingManager.lua
    local function OnContentTrackingUpdate(self, trackableType, id, isTracked)
        -- Assume other types don't need bespoke behavior (Enum.ContentTrackingType.Appearance, Enum.ContentTrackingType.Mount, Enum.ContentTrackingType.Decor)
        if trackableType ~= Enum.ContentTrackingType.Achievement then
            KT_AdventureObjectiveTracker:MarkDirty()
        end
    end

    local function OnContentTrackingToggled(self, isEnabled)
        KT_AdventureObjectiveTracker:MarkDirty()
    end

    EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_UPDATE", OnContentTrackingUpdate, KT)
    EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_IS_ENABLED_UPDATE", OnContentTrackingToggled, KT)
end

function KT.Hooks_GossipFrame()
    -- GossipFrame.lua
    hooksecurefunc(GossipFrame, "HandleShow", function(self, textureKit)
        local gossipQuests = C_GossipInfo.GetActiveQuests()
        for _, questInfo in ipairs(gossipQuests) do
            KT.QuestsCache_UpdateProperty(questInfo.questID, "startMapID", KT.GetCurrentMapAreaID())
        end
        KT:SendSignal("QUEST_DATA_CHANGED")
    end)
end

function KT.Hooks_QuestFrame()
    -- QuestFrame.lua
    QuestFrame:HookScript("OnShow", function(self)
        local questID = GetQuestID()
        KT.QuestsCache_UpdateProperty(questID, "startMapID", KT.GetCurrentMapAreaID())
        KT:SendSignal("QUEST_DATA_CHANGED")
    end)
end

function KT.Hooks_SplashFrame()
    -- SplashFrame.lua
    hooksecurefunc(SplashFrame, "SetupFrame", function(self, screenInfo)
        if screenInfo then
            OTF:Update()
        end
    end)

    hooksecurefunc(SplashFrame, "OpenQuestDialog", function(self)
        local questID = self.RightFeature.questID
        KT_QuestObjectiveTracker:RemoveAutoQuestPopUp(questID)
    end)

    SplashFrame:HookScript("OnHide", function(self)
        OTF:ForceExpand()
    end)
end

function KT.Hooks_UIErrorsFrame()
    -- UIErrorsFrame.lua
    local bck_UIErrorsFrame_OnEvent = UIErrorsFrame:GetScript("OnEvent")
    UIErrorsFrame:SetScript("OnEvent", function(self, event, ...)
        if db.messageQuest and event == "UI_INFO_MESSAGE" then
            local text, _ = ...
            for _, patt in ipairs(KT.msgPatterns) do
                if strfind(text, patt) then
                    KT:SetMessage(text, 1, 1, 0, nil, "Interface\\GossipFrame\\AvailableQuestIcon", -2, 0)
                    return
                end
            end
        end
        bck_UIErrorsFrame_OnEvent(self, event, ...)
    end)
end

function SS:Init()
    db = KT.db.profile
    dbChar = KT.db.char

    KT.Hooks_ObjectiveTrackerManager()
    KT.Hooks_ObjectiveTrackerContainer()
    KT.Hooks_ObjectiveTrackerModule()
    KT.Hooks_ObjectiveTrackerBlock()
    KT.Hooks_ObjectiveTrackerQuestPOIBlock()
    KT.Hooks_ObjectiveTracker()
    KT.Hooks_POIButton()
    KT.Hooks_ContentTrackingManager()
    KT.Hooks_GossipFrame()
    KT.Hooks_QuestFrame()
    KT.Hooks_SplashFrame()
    KT.Hooks_UIErrorsFrame()

    KT:RegSignal("ADDON_ENABLED", Default_UpdateMixins, self)
end