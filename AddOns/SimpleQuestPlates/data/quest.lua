--=====================================================================================
-- RGX | Simple Quest Plates! - quest.lua

-- Author: DonnieDice
-- Description: Quest detection and progress tracking
--=====================================================================================

local addonName, SQP = ...

-- Cache frequently used globals
local C_TaskQuest = C_TaskQuest
local C_Scenario = C_Scenario
local strmatch = string.match
local tonumber = tonumber
local ceil = math.ceil

local function nowSeconds()
    if type(GetTimePreciseSec) == "function" then
        return GetTimePreciseSec()
    end
    if type(debugprofilestop) == "function" then
        return debugprofilestop() / 1000
    end
    if type(GetTime) == "function" then
        return GetTime()
    end
    return 0
end

local function reportSlowPath(label, started)
    local elapsed = nowSeconds() - started
    if elapsed < 0.050 then
        return
    end

    local now = nowSeconds()
    SQP._lastSlowPathReport = SQP._lastSlowPathReport or {}
    if (SQP._lastSlowPathReport[label] or 0) + 2 > now then
        return
    end

    SQP._lastSlowPathReport[label] = now
    local message = string.format("[SQP:slow] %s took %.1fms", tostring(label), elapsed * 1000)
    if type(_G.geterrorhandler) == "function" then
        _G.geterrorhandler()(message)
    else
        print("|cffffaa00" .. message .. "|r")
    end
end

-- Quest storage
SQP.ActiveWorldQuests = {}
SQP.QuestLogIndex = {}
local OurName = UnitName('player')

-- Constants
local LE_SCENARIO_TYPE_CHALLENGE_MODE = LE_SCENARIO_TYPE_CHALLENGE_MODE or 2

-- Normalize objective text for matching (strip counts, percents, color codes, and extra tokens)
local function NormalizeObjectiveText(text)
    if not text then return nil end
    if type(text) ~= "string" then
        text = tostring(text)
    end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("%b[]", "")
    text = text:gsub("%b()", "")
    text = text:gsub("%d+%s*/%s*%d+", "")
    text = text:gsub("[%d%.]+%%", "")
    text = text:gsub("[•·%-–—:]", " ")
    text = text:gsub("[%.,%!%?]", " ")
    text = text:lower()
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function TokenizeText(text)
    if not text then return {}, {} end
    local list = {}
    local set = {}
    for token in text:gmatch("%S+") do
        if #token > 1 then
            list[#list + 1] = token
            set[token] = true
        end
    end
    return list, set
end

local function GetRemainingFromObjectiveText(text)
    if not text then return nil end
    local x, y = strmatch(text, '(%d+)%s*/%s*(%d+)')
    if x and y then
        local numLeft = tonumber(y) - tonumber(x)
        return numLeft
    end
    local progress = tonumber(strmatch(text, '([%d%.]+)%%'))
    if progress and progress < 100 then
        return ceil(100 - progress), true
    end
    return nil
end

local function ObjectiveTextMatchesUnit(objText, unitNameNorm, objectiveType)
    if not objText or not unitNameNorm then return false end
    local objNorm = NormalizeObjectiveText(objText)
    if not objNorm or objNorm == "" then return false end
    if objNorm:find(unitNameNorm, 1, true) or unitNameNorm:find(objNorm, 1, true) then
        return true
    end
    local listA, setA = TokenizeText(objNorm)
    local listB, setB = TokenizeText(unitNameNorm)
    if #listA == 0 or #listB == 0 then return false end
    local overlap = 0
    for token in pairs(setA) do
        if setB[token] then
            overlap = overlap + 1
        end
    end
    if overlap == 0 then return false end
    if objectiveType == "item" or objectiveType == "object" then
        return overlap >= 1
    end
    if #listA <= 1 or #listB <= 1 then
        return overlap >= 1
    end
    return overlap >= 2
end

local function FindObjectiveTypeForText(text)
    if not text then return nil end
    if not SQP or not SQP.Compat or not SQP.Compat.GetNumQuestLogEntries then
        return nil
    end
    local textNorm = NormalizeObjectiveText(text)
    if not textNorm or textNorm == "" then return nil end
    for i = 1, SQP.Compat.GetNumQuestLogEntries() do
        local info = SQP.Compat.GetInfo(i)
        if info and not info.isHeader and not info.isHidden and (not info.isComplete or info.isComplete == 0) then
            local objectives = SQP.Compat.GetQuestObjectives(info.questID, i)
            if objectives then
                for _, obj in ipairs(objectives) do
                    if obj.text then
                        local objNorm = NormalizeObjectiveText(obj.text)
                        if objNorm and (objNorm == textNorm
                            or objNorm:find(textNorm, 1, true)
                            or textNorm:find(objNorm, 1, true)) then
                            return obj.type
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Helper function for quest objectives
local function GetQuestObjectiveInfo(questID, index, isComplete)
    if not questID then return end
    
    if SQP.Compat.GetQuestObjectives then
        local objectives = SQP.Compat.GetQuestObjectives(questID)
        if objectives and objectives[index] then
            local obj = objectives[index]
            return obj.text, obj.type, obj.finished
        end
    else
        -- Fallback for older API
        local text, objectiveType, finished = GetQuestLogLeaderBoard(index, questID)
        return text, objectiveType, finished
    end
end

-- Get quest progress from unit tooltip
function SQP:GetQuestProgress(unitID)
    if not unitID or not UnitExists(unitID) then return end

    local nameOk, unitName = pcall(UnitName, unitID)
    if not nameOk or not unitName then return end

    local testOk, testResult = pcall(function() return unitName == "" end)
    if not testOk or testResult then
        return
    end

    local itemsNeeded, objectiveCount, progressGlob, questType, questIdForItems = 0, 0, nil, nil, nil
    local unitNameNorm = NormalizeObjectiveText(unitName)
    local questObjectiveType, questTitleType, questPlayerType
    if Enum and Enum.TooltipDataLineType then
        questObjectiveType = Enum.TooltipDataLineType.QuestObjective
        questTitleType = Enum.TooltipDataLineType.QuestTitle
        questPlayerType = Enum.TooltipDataLineType.QuestPlayer
    end
    local playerName = UnitName("player")
    local hasPlayerLine = false
    local isPlayerBlock = nil
    
    -- *****************************************************************************
    -- ** Primary Method: Tooltip Scanning (New, More Accurate)
    -- *****************************************************************************
    local tooltipLines = {}
    local tooltipData
    if C_TooltipInfo and C_TooltipInfo.GetUnit then
        local ok, data = pcall(C_TooltipInfo.GetUnit, unitID)
        if ok then
            tooltipData = data
        end
    end
    if tooltipData and tooltipData.lines then
        tooltipLines = tooltipData.lines
    else
        local scanTooltip = SQPScanTooltip or CreateFrame("GameTooltip", "SQPScanTooltip", nil, "GameTooltipTemplate")
        scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        scanTooltip:SetUnit(unitID)
        for i = 1, scanTooltip:NumLines() do
            local textLeft = _G["SQPScanTooltipTextLeft"..i]
            if textLeft and textLeft:GetText() then
                table.insert(tooltipLines, { leftText = textLeft:GetText() })
            end
            local textRight = _G["SQPScanTooltipTextRight"..i]
            if textRight and textRight:GetText() then
                table.insert(tooltipLines, { leftText = textRight:GetText() })
            end
        end
        scanTooltip:Hide()
    end

    if #tooltipLines > 0 then
        local tooltipObjectives = {}

        for _, line in ipairs(tooltipLines) do
            local text = line.leftText
            local lineType = line.type
            if lineType and questTitleType and questPlayerType and questObjectiveType then
                if lineType == questTitleType then
                    hasPlayerLine = false
                    isPlayerBlock = nil
                    text = nil
                elseif lineType == questPlayerType then
                    hasPlayerLine = true
                    isPlayerBlock = (line.leftText == playerName)
                    text = nil
                elseif lineType == questObjectiveType then
                    if line.completed ~= nil and line.completed then
                        text = nil
                    elseif hasPlayerLine and not isPlayerBlock then
                        text = nil
                    end
                else
                    text = nil
                end
            end
            if type(text) ~= "string" then
                text = text and tostring(text) or nil
            end
            if not text or text == "" then
                -- Skip non-objective or empty lines
            else
                local numLeft, isPercent = GetRemainingFromObjectiveText(text)
                if numLeft and numLeft > 0 then
                    table.insert(tooltipObjectives, {
                        text = text,
                        amountNeeded = numLeft,
                        questID = line.questID,
                        isPercent = isPercent and true or false
                    })
                end
            end
        end

        if #tooltipObjectives > 0 then
            local chosen = tooltipObjectives[1]
            if unitNameNorm then
                for _, tooltipObj in ipairs(tooltipObjectives) do
                    local tNorm = NormalizeObjectiveText(tooltipObj.text)
                    if tNorm and (tNorm:find(unitNameNorm, 1, true) or unitNameNorm:find(tNorm, 1, true)) then
                        chosen = tooltipObj
                        break
                    end
                end
            end

            local objType = FindObjectiveTypeForText(chosen.text)
            if objType == "item" or objType == "object" then
                itemsNeeded = chosen.amountNeeded
            else
                objectiveCount = chosen.amountNeeded
            end
            progressGlob = chosen.text
            if chosen.isPercent then
                questType = 3
            else
                questType = questType or 1
            end
        end
    end

    -- *****************************************************************************
    -- ** Fallback Method: Name Matching (Original Logic)
    -- *****************************************************************************
    if not progressGlob then
        local function processObjectivesFallback(questID, questLogIndex)
            if not questID and not questLogIndex then return end
            local objectives = SQP.Compat.GetQuestObjectives(questID, questLogIndex)
            for _, obj in ipairs(objectives) do
                if obj.text and ObjectiveTextMatchesUnit(obj.text, unitNameNorm, obj.type) then
                    local numLeft, isPercent = GetRemainingFromObjectiveText(obj.text)
                    if numLeft and numLeft > 0 then
                        if obj.type == 'item' or obj.type == 'object' then
                            if numLeft > itemsNeeded then itemsNeeded = numLeft end
                        else -- kill or other
                            if numLeft > objectiveCount then objectiveCount = numLeft end
                        end
                        progressGlob = obj.text
                        questIdForItems = questID or questLogIndex
                        if isPercent then
                            questType = 3
                        end
                    end
                end
            end
        end

        if SQP.Compat.GetNumQuestLogEntries then
            for i = 1, SQP.Compat.GetNumQuestLogEntries() do
                local info = SQP.Compat.GetInfo(i)
                if info and not info.isHeader and not info.isHidden and (not info.isComplete or info.isComplete == 0) then
                    processObjectivesFallback(info.questID, i)
                end
            end
        end

        if C_TaskQuest then
            for _, questID in pairs(self.ActiveWorldQuests) do
                if questID then
                    processObjectivesFallback(questID)
                end
            end
        end
    end

    return progressGlob, progressGlob and (questType or 1) or nil, objectiveCount, itemsNeeded, questIdForItems
end

-- Update quest icon on nameplate
function SQP:UpdateQuestIcon(plate, unitID)
    local started = nowSeconds()
    if not SQPSettings.enabled then return end
    
    local Q = self.QuestPlates[plate]
    if not Q then return end
    
    unitID = unitID or plate._unitID
    if not unitID then return end
    
    -- Check if should hide in combat
    if SQPSettings.hideInCombat and UnitAffectingCombat("player") then
        Q:Hide()
        return
    end
    
    -- Check if should hide in instance
    if SQPSettings.hideInInstance then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or instanceType == "pvp" or instanceType == "arena") then
            Q:Hide()
            return
        end
    end
    
    -- Hide in mythic+ (only for retail)
    if C_Scenario and C_Scenario.GetInfo then
        local scenarioName, currentStage, numStages, flags, _, _, _, xp, money, scenarioType = C_Scenario.GetInfo()
        if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
            Q:Hide()
            return
        end
    end
    
    local progressGlob, questType, objectiveCount, itemsNeeded, questID = self:GetQuestProgress(unitID)
    local questRelatedOnly = false

    if not progressGlob and SQP.Compat and SQP.Compat.IsQuestRelatedUnit then
        local ok, related = pcall(SQP.Compat.IsQuestRelatedUnit, unitID)
        if ok and related then
            questRelatedOnly = true
        end
    end

    if questRelatedOnly then
        if UnitCanAttack and not UnitCanAttack("player", unitID) then
            questRelatedOnly = false
        end
        if UnitIsPlayer and UnitIsPlayer(unitID) then
            questRelatedOnly = false
        end
    end

    -- Decide if there is a relevant objective for this unit
    local showIcon = false
    local displayText = "?"
    local displayColor = {1, 1, 1} -- Default white
    local function IsIconStyleEnabled(typeKey)
        local value = SQPSettings[typeKey .. "ShowIconBackground"]
        if value == nil then
            value = SQPSettings.showIconBackground
        end
        return value ~= false
    end

    if progressGlob and questType ~= 2 then
        -- Priority: Item > Kill > Percent
        if itemsNeeded > 0 then
            showIcon = true
            displayText = itemsNeeded
            if not IsIconStyleEnabled("loot") then
                local px, py = strmatch(progressGlob or "", '(%d+)%s*/%s*(%d+)')
                if px and py then displayText = px .. "/" .. py end
            end
            displayColor = SQPSettings.itemColor or {0.2, 1, 0.2}
            Q.hasItem = true
            Q.questType = questType
        elseif objectiveCount > 0 then
            showIcon = true
            displayText = objectiveCount
            local styleTypeKey = (questType == 3) and "percent" or "kill"
            if not IsIconStyleEnabled(styleTypeKey) then
                local px, py = strmatch(progressGlob or "", '(%d+)%s*/%s*(%d+)')
                if px and py then displayText = px .. "/" .. py end
            end
            if questType == 1 then
                displayColor = SQPSettings.killColor or {1, 0.82, 0}
            elseif questType == 3 then
                 displayColor = SQPSettings.percentColor or {0.2, 1, 1}
            end
            Q.hasItem = false
            Q.questType = questType
        elseif questType == 3 then -- Percent quest without a specific kill count
            showIcon = true
            displayText = objectiveCount > 0 and objectiveCount or '?'
            displayColor = SQPSettings.percentColor or {0.2, 1, 1}
            Q.hasItem = false
            Q.questType = questType
        end
    end

    if questRelatedOnly and not showIcon then
        -- Only show "?" if at least one incomplete quest exists (prevents stale icons after quest completion)
        local hasIncomplete = false
        if SQP.Compat and SQP.Compat.GetNumQuestLogEntries then
            for i = 1, SQP.Compat.GetNumQuestLogEntries() do
                local info = SQP.Compat.GetInfo(i)
                if info and not info.isHeader and not info.isHidden and (not info.isComplete or info.isComplete == 0) then
                    hasIncomplete = true
                    break
                end
            end
        end
        if hasIncomplete then
            showIcon = true
            displayText = "?"
            displayColor = SQPSettings.killColor or {1, 0.82, 0}
            Q.hasItem = false
            Q.questType = 1
        end
    end

    Q.questRelatedOnly = questRelatedOnly

    -- Per-type tinting: determine effective quest type
    local effectiveType = (Q.hasItem and "loot") or ((questType or 0) == 3 and "percent") or "kill"
    local killTintEnabled = SQPSettings.killTintIcon and SQPSettings.killTintIconColor
    local killTintR, killTintG, killTintB, killTintA = 1, 1, 1, 1
    if killTintEnabled then
        killTintR, killTintG, killTintB, killTintA = unpack(SQPSettings.killTintIconColor)
    end
    local lootTintEnabled = SQPSettings.lootTintIcon and SQPSettings.lootTintIconColor
    local lootTintR, lootTintG, lootTintB, lootTintA = 1, 1, 1, 1
    if lootTintEnabled then
        lootTintR, lootTintG, lootTintB, lootTintA = unpack(SQPSettings.lootTintIconColor)
    end
    local percentTintEnabled = SQPSettings.percentTintIcon and SQPSettings.percentTintIconColor
    local percentTintR, percentTintG, percentTintB, percentTintA = 1, 1, 1, 1
    if percentTintEnabled then
        percentTintR, percentTintG, percentTintB, percentTintA = unpack(SQPSettings.percentTintIconColor)
    end

    local percentIconMode = IsIconStyleEnabled("percent")
    local showPercentIcon = showIcon and questType == 3 and SQPSettings.showPercentIcon ~= false
    local percentText = tostring(displayText) .. "%"
    if showPercentIcon then
        if Q.icon then
            if percentIconMode then
                Q.icon:Show()
            else
                Q.icon:Hide()
            end
        end
        if Q.percentIcon then
            -- Icon mode: show "%" as separate indicator; Text mode: show combined "75%"
            if percentIconMode then
                Q.percentIcon:SetText("%")
            else
                Q.percentIcon:SetText(percentText)
            end
            if percentTintEnabled then
                Q.percentIcon:SetTextColor(percentTintR, percentTintG, percentTintB, percentTintA or 1)
            else
                Q.percentIcon:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
            end
            Q.percentIcon:Show()
        end
        if Q.percentIconOutline then
            Q.percentIconOutline:SetText(percentText)
            local outlineWidth = SQP:GetOutlineInfo("percent")
            if outlineWidth and outlineWidth > 0 then
                Q.percentIconOutline:Show()
            else
                Q.percentIconOutline:Hide()
            end
        end
    else
        if Q.percentIcon then
            Q.percentIcon:Hide()
        end
        if Q.percentIconOutline then
            Q.percentIconOutline:Hide()
        end
        if Q.icon then
            if IsIconStyleEnabled(effectiveType) then
                Q.icon:Show()
            else
                Q.icon:Hide()
            end
        end
    end

    local animateMain = self:IsAnimationEnabled(effectiveType, false)
    local mainIconShown = Q.icon and Q.icon:IsShown()
    local percentTextShown = Q.percentIcon and Q.percentIcon:IsShown() and not mainIconShown

    if Q.iconPulse then
        self:ApplyPulseDuration(Q.iconPulse, self:GetAnimationDuration(effectiveType, true))
        if animateMain and showIcon and mainIconShown then
            if not Q.iconPulse:IsPlaying() then
                Q.iconPulse:Play()
            end
        else
            if Q.iconPulse:IsPlaying() then
                Q.iconPulse:Stop()
            end
            if Q.icon then
                Q.icon:SetAlpha(1)
            end
        end
    end
    if Q.percentPulse then
        self:ApplyPulseDuration(Q.percentPulse, self:GetAnimationDuration("percent", false))
        if animateMain and showIcon and percentTextShown then
            if not Q.percentPulse:IsPlaying() then
                Q.percentPulse:Play()
            end
        else
            if Q.percentPulse:IsPlaying() then
                Q.percentPulse:Stop()
            end
            if Q.percentIcon then
                Q.percentIcon:SetAlpha(1)
            end
        end
    end
    if Q.percentOutlinePulse then
        self:ApplyPulseDuration(Q.percentOutlinePulse, self:GetAnimationDuration("percent", false))
        if animateMain and showIcon and percentTextShown and Q.percentIconOutline and Q.percentIconOutline:IsShown() then
            if not Q.percentOutlinePulse:IsPlaying() then
                Q.percentOutlinePulse:Play()
            end
        else
            if Q.percentOutlinePulse:IsPlaying() then
                Q.percentOutlinePulse:Stop()
            end
            if Q.percentIconOutline then
                Q.percentIconOutline:SetAlpha(1)
            end
        end
    end

    if showIcon then
        -- Apply per-type font before rendering text
        local fontTypeKey
        if Q.hasItem then
            fontTypeKey = "loot"
        elseif questType == 3 then
            fontTypeKey = "percent"
        else
            fontTypeKey = "kill"
        end
        SQP:UpdateQuestFont(Q.iconText, Q.iconTextOutline, Q.percentIcon, Q.percentIconOutline, fontTypeKey)

        -- Update and show the icon; percent quests show number+% in percentIcon, not iconText
        if showPercentIcon then
            -- Icon mode: show the number on the jellybean; text mode: number is inside percentIcon
            if percentIconMode then
                Q.iconText:SetText(tostring(displayText))
                if Q.iconTextOutline then Q.iconTextOutline:SetText(tostring(displayText)) end
            else
                Q.iconText:SetText("")
                if Q.iconTextOutline then Q.iconTextOutline:SetText("") end
            end
        else
            Q.iconText:SetText(displayText)
            if Q.iconTextOutline then
                Q.iconTextOutline:SetText(displayText)
            end
        end
        Q.iconText:SetTextColor(unpack(displayColor))
        Q.icon:SetDesaturated(false)

        if not Q:IsVisible() then
            Q.ani:Stop()
            Q:Show()
            Q.ani:Play()
            if Q.icon then
                Q.icon:SetVertexColor(1, 1, 1, 1)
            end
            if SQPSettings.debug then
                self:PrintMessage(format("Showing quest plate for %s", UnitName(unitID) or "Unknown"), "DEBUG")
            end
        end
    else
        -- Hide the icon
        Q:Hide()
    end

    -- Update quest type icons based on settings
    if Q then
        if Q.questRelatedOnly then
                if Q.lootIcon then
                    Q.lootIcon:Hide()
                end
                if Q.killIcon then
                    Q.killIcon:Hide()
                end
            elseif Q.hasItem then
                if Q.lootIcon then
                    if SQPSettings.showLootIcon ~= false then
                        Q.lootIcon:Show()
                    else
                        Q.lootIcon:Hide()
                    end
                end
                if Q.killIcon then
                    Q.killIcon:Hide()
                end
            elseif questType == 1 then
                if Q.lootIcon then
                    Q.lootIcon:Hide()
                end
                if Q.killIcon then
                    if SQPSettings.showKillIcon ~= false then
                        Q.killIcon:Show()
                    else
                        Q.killIcon:Hide()
                    end
                end
            else
                if Q.lootIcon then
                    Q.lootIcon:Hide()
                end
                if Q.killIcon then
                    Q.killIcon:Hide()
                end
            end
    end

    if Q then
        if Q.killIcon then
            if killTintEnabled then
                Q.killIcon:SetVertexColor(killTintR, killTintG, killTintB, killTintA)
            else
                Q.killIcon:SetVertexColor(1, 1, 1, 1)
            end
        end
        if Q.lootIcon then
            if lootTintEnabled then
                Q.lootIcon:SetVertexColor(lootTintR, lootTintG, lootTintB, lootTintA)
            else
                Q.lootIcon:SetVertexColor(1, 1, 1, 1)
            end
        end
    end

    -- Animate quest type mini-icons
    if Q then
        local animateKillTask = self:IsAnimationEnabled("kill", true)
        local animateLootTask = self:IsAnimationEnabled("loot", true)

        if Q.killIconPulse then
            self:ApplyPulseDuration(Q.killIconPulse, self:GetAnimationDuration("kill", false))
            if animateKillTask and Q.killIcon and Q.killIcon:IsShown() then
                if not Q.killIconPulse:IsPlaying() then Q.killIconPulse:Play() end
            else
                if Q.killIconPulse:IsPlaying() then Q.killIconPulse:Stop() end
                if Q.killIcon then
                    Q.killIcon:SetAlpha(1)
                end
            end
        end
        if Q.lootIconPulse then
            self:ApplyPulseDuration(Q.lootIconPulse, self:GetAnimationDuration("loot", false))
            if animateLootTask and Q.lootIcon and Q.lootIcon:IsShown() then
                if not Q.lootIconPulse:IsPlaying() then Q.lootIconPulse:Play() end
            else
                if Q.lootIconPulse:IsPlaying() then Q.lootIconPulse:Stop() end
                if Q.lootIcon then
                    Q.lootIcon:SetAlpha(1)
                end
            end
        end
    end

    reportSlowPath("UpdateQuestIcon", started)
end

-- Cache quest indexes for faster lookups
function SQP:CacheQuestIndexes()
    wipe(self.QuestLogIndex)
    
    -- Use compatibility layer for quest log
    if SQP.Compat.GetNumQuestLogEntries then
        local numQuests = SQP.Compat.GetNumQuestLogEntries()
        for i = 1, numQuests do
            local info = SQP.Compat.GetInfo(i)
            if info and not info.isHeader and not info.isHidden then
                self.QuestLogIndex[info.title] = i
            end
        end
    end
end

-- Load world quests for current zone
function SQP:LoadWorldQuests()
    -- World quests don't exist in MoP Classic
    if not C_TaskQuest or not C_TaskQuest.GetQuestsForPlayerByMapID then
        return
    end
    
    local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit('player')
    if uiMapID then
        for _, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) or {}) do
            if task.inProgress then
                local questID = task.questID or task.questId  -- Handle both cases
                if questID then
                    local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
                    if questName then
                        self.ActiveWorldQuests[questName] = questID
                    end
                end
            end
        end
    end
end
