-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local pairs = _G.pairs
local GetTime = _G.GetTime
local select = _G.select
local strsplit = _G.strsplit
local string = _G.string
local math = _G.math
local table = _G.table
local tonumber = _G.tonumber
local UnitCanAttack = _G.UnitCanAttack
local UnitIsDead = _G.UnitIsDead
local C_Scenario = _G.C_Scenario
local GetInstanceInfo = _G.GetInstanceInfo
local CreateFrame = _G.CreateFrame
local UnitGUID = _G.UnitGUID
local UIParent = _G.UIParent
local unpack = _G.unpack
local UnitThreatSituation = _G.UnitThreatSituation
local UnitPlayerControlled = _G.UnitPlayerControlled
local C_NamePlate = _G.C_NamePlate
local StaticPopup_Show = _G.StaticPopup_Show
local StaticPopupDialogs = _G.StaticPopupDialogs
local max = _G.max
local wipe = _G.wipe
local Mixin = _G.Mixin
local C_ChallengeMode = _G.C_ChallengeMode

local name, ns = ...

--- @class MMPE: AceAddon, AceConsole-3.0, AceHook-3.0, AceEvent-3.0
local MMPE = LibStub('AceAddon-3.0'):NewAddon(name, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0');
if not MMPE then return end

local L = LibStub('AceLocale-3.0'):GetLocale(name)

-- expose to the world that we exist
_G['MMPE'] = MMPE

--
-- Public API
--
MPP_API = {};
--- @param npcID number
--- @return number? rawCount
function MPP_API:GetNpcCount(npcID)
    return MMPE:GetValue(npcID)
end

--- Returns progress and pull count information. Pull count information is updated on a timer (roughly 5x per second)
--- @return number? currentCount # this is a best effort number, since blizzard's API does not return this data anymore; may return 0 instead of nil
--- @return number? maxCount # total count required for completion, can be used to calculate progress %
--- @return number? pullCount # total count of NPCs in the current pull
function MPP_API:GetProgress()
    return MMPE:GetCurrentQuantity(), MMPE:GetMaxQuantity(), MMPE:GetPulledProgress()
end

--
-- Emulated MDT API
--
local MDTEmulated = {
    GetEnemyForces = function(_, npcID)
        local count = MMPE:GetValue(npcID);
        if count and count > 0 then
            local maxCount = MMPE:GetMaxQuantity();
            return count, maxCount, maxCount, count;
        end
    end,
    GetCurrentPreset = function() end, -- some WA uses this for some reason /shrug
    IsPresetTeeming = function() return false; end, -- used together with GetCurrentPreset
    zoneIdToDungeonIdx = {},
    dungeonTotalCount = {},
};
do
    -- some addons use these internals, while they probably shouldn't.. we'll just hardcode a dungeonIndex of 1
    setmetatable(MDTEmulated.zoneIdToDungeonIdx, {__index = function(_, key)
        if key == C_Map.GetBestMapForUnit("player") then return 1; end
    end});
    setmetatable(MDTEmulated.dungeonTotalCount, {__index = function(_, key)
        if key ~= 1 then return; end
        local maxCount = MMPE:GetMaxQuantity();
        return { normal = maxCount, teeming = maxCount, teemingEnabled = true };
    end});
end

ns.addon = MMPE
ns.data = {}
MMPE.ns = ns

MMPE.loaded = false
MMPE.quantity = 0
MMPE.previousQuantity = 0
MMPE.lastKill = { 0 } -- To be populated later, do not remove the initial value. The zero means inconclusive/invalid data.
MMPE.currentPullUpdateTimer = 0
MMPE.activeNameplates = {}

MMPE.simulationActive = false
MMPE.simulationMax = 220
MMPE.simulationCurrent = 28
MMPE.simulationMapId = 234 -- upper kara

MMPE.warnings = {}

--
-- GENERAL ADDON UTILITY
--

local function GetTimeInMilliSeconds()
    return GetTime() * 1000
end

local function GetAbsoluteFramePosition(frame)
    return {
        ["anchorPoint"] = "TOPLEFT",
        ["relativeFrame"] = "UIParent",
        ["relativePoint"] = "BOTTOMLEFT",
        ["offX"] = frame:GetLeft(),
        ["offY"] = frame:GetTop(),
    }
end

local function SetFramePoint(frame, pointInfo)
    frame:ClearAllPoints()
    frame:SetPoint(
        pointInfo.anchorPoint,
        pointInfo.relativeFrame,
        pointInfo.relativePoint,
        pointInfo.offX,
        pointInfo.offY
    );
end

function MMPE:DebugPrint(...)
    if self:GetSetting('debug') then
        if(DevTool and DevTool.AddData) then
            DevTool:AddData({ ... }, "MMPE DebugPrint")
        end
        self:Print(...)
    end
end

function MMPE:HasWarned(message)
    for _,warning in pairs(self.warnings) do
        if warning == message then
            return true
        end
    end
    return false
end

function MMPE:PrintWarning(message)
    if not self:HasWarned(message) then
        self:Print(message)
        table.insert(self.warnings, message)
        return true
    end
    return false
end

--
-- WOW GENERAL WRAPPERS/EZUTILITIES
--

function MMPE:GetNPCID(guid)
    if guid == nil then
        return nil
    end
    local targetType, _,_,_,_, npcID = strsplit("-", guid)
    if targetType == "Creature" or targetType == "Vehicle" and npcID then
        return tonumber(npcID)
    end
end

function MMPE:IsValidTarget(unit)
    if UnitCanAttack("player", unit) then
        return true
    end
end

function MMPE:GetSteps()
    return select(3, C_Scenario.GetStepInfo())
end

function MMPE:IsDungeonFinished(ignoreSimulation)
    if not ignoreSimulation and self.simulationActive then return false end
    return (self:GetSteps() and self:GetSteps() < 1)
end

function MMPE:IsMythicPlus(ignoreSimulation)
    if not ignoreSimulation and self.simulationActive then return true end
    local difficulty = select(3, GetInstanceInfo()) or -1
    if difficulty == 8 and not self:IsDungeonFinished(ignoreSimulation) then
        return true
    else
        return false
    end
end

function MMPE:GetProgressInfo()
    if self:IsMythicPlus() then
        local numSteps = self:GetSteps()
        if numSteps and numSteps > 0 then
            local info = C_ScenarioInfo.GetCriteriaInfo(numSteps)
            return info.isWeightedProgress and info or nil
        end
    end
end

function MMPE:GetMaxQuantity()
    if self.simulationActive then return self.simulationMax end
    local info = self:GetProgressInfo()
    if info then
        return info.totalQuantity
    end

    return 0
end

function MMPE:GetCurrentQuantity()
    if self.simulationActive then return self.simulationCurrent end
    local info = self:GetProgressInfo()
    if info then
        self.countTracker:RefreshInfo()

        return self.countTracker.count
    end

    return 0
end

--- Returns exact float value of current enemies killed progress (1-100).
function MMPE:GetEnemyForcesProgress()
    local quantity = self:GetCurrentQuantity() or 0
    local maxQuantity = self:GetMaxQuantity() or 1
    local progress = (quantity / maxQuantity) * 100

    return progress
end

function MMPE:GetChallengeMapId()
    if self.simulationActive then return self.simulationMapId end

    return C_ChallengeMode.GetActiveChallengeMapID()
end

--
-- DB READ/WRITES
--

function MMPE:GetValue(npcID)
    local activeMapId = self:GetChallengeMapId()
    if (activeMapId and self.dungeonOverrides[activeMapId] and self.dungeonOverrides[activeMapId][npcID] and self.dungeonOverrides[activeMapId][npcID].count) then
        return self.dungeonOverrides[activeMapId][npcID].count
    end

    local npcData = self.DB.npcData[npcID]
    if npcData then
        local bestValue, maxOccurrence = nil, -1
        for value, occurrence in pairs(npcData["values"]) do
            if occurrence > maxOccurrence then
                bestValue, maxOccurrence = value, occurrence
            end
        end
        if bestValue ~= nil then
            return bestValue
        end
    end
    -- self:DebugPrint("GetValue failed to find NPC. Args:", npcID)
end

function MMPE:DeleteEntry(npcID)
    local exists = (self.DB.npcData[npcID] ~= nil)
    self.DB.npcData[npcID] = nil
    return exists
end

function MMPE:UpdateValue(npcID, value, npcName, updatedFromCombat, forceUpdate)
    local newValue = false
    if value <= 0 then
        self:DebugPrint("Discarding update for", npcName, "(", npcID, ") due to value being", value)
        return newValue
    end
    local npcData = self.DB.npcData[npcID]
    if not npcData then
        self.DB.npcData[npcID] = {values = {}, name = npcName or "Unknown"}
        npcData = self.DB.npcData[npcID]
    end

    local values = npcData.values
    if values[value] == nil then
        newValue = true
        values[value] = 1
    elseif updatedFromCombat then
        values[value] = values[value] + 1
    elseif forceUpdate then
        values[value] = 1
    end
    local bestValue, maxOccurrence = nil, -1
    local previousBestValue, previousMaxOccurrence = nil, -1
    for val, occurrence in pairs(values) do
        if ((val == value and (occurrence - 1) or occurrence) > previousMaxOccurrence) then
            previousBestValue, previousMaxOccurrence = val, occurrence
        end
        if val ~= value and updatedFromCombat then
            values[val] = occurrence * 0.75 -- Newer values will quickly overtake old ones
        end
        if val ~= value and forceUpdate then
            values[val] = nil -- Old values are deleted on forced updates
        end
        if occurrence > maxOccurrence then
            bestValue, maxOccurrence = val, occurrence
        end
    end

    if(updatedFromCombat and value == bestValue and value ~= previousBestValue and self:GetSetting('debugNewNPCScores')) then
        self:Print(string.format("New score for %s (%d): %d, old value: %d", npcName, npcID, value, previousBestValue))
    end

    return newValue
end

function MMPE:ExportData(onlyUpdatedData)
    if not StaticPopupDialogs["MPPEDataExportDialog"] then
        self:InitPopup()
    end
    local defaultValues = {}
    if onlyUpdatedData then
        for _, dataProvider in pairs(ns.data) do
            defaultValues = Mixin(defaultValues, dataProvider:GetNPCData())
        end
    end
    local editBoxText = "exported = { data = {\n"
    local count = 0
    for npcID, npcData in pairs(self.DB.npcData) do
        local value = self:GetValue(npcID)
        local npcName = npcData.name
        if(not onlyUpdatedData or value ~= (defaultValues[npcID] and defaultValues[npcID].count or 0)) then
            count = count + 1
            editBoxText = editBoxText .. string.format(
                "\t[%d] = {[\"name\"] = \"%s\", [\"count\"] = %d, [\"defaultCount\"] = %d},\n",
                npcID,
                npcName,
                value,
                (defaultValues[npcID] and defaultValues[npcID].count or -1)
            )
        end
    end
    editBoxText = editBoxText .. string.format("}, version = \"%s\", numberOfMobs = %d }", self.version, count)

    StaticPopup_Show("MPPEDataExportDialog", nil, nil, editBoxText);
end

--
-- Light DB wrap
--

function MMPE:GetEstimatedProgress(npcID)
    local npcValue = self:GetValue(npcID)
    local maxQuantity = self:GetMaxQuantity()
    if npcValue and maxQuantity then
        return (npcValue / maxQuantity) * 100, npcValue, maxQuantity
    end
end

--
-- TRIGGERS/HOOKS
--

-- Called when our enemy forces criteria increases, no matter how small the increase (but >0).
function MMPE:OnProgressUpdated(deltaProgress)
    self:DebugPrint("onProgressUpdated called. Args: " .. deltaProgress)
    if self.previousQuantity == self:GetMaxQuantity() then
        return
    end
    local timestamp, npcID, npcName, isDataUseful = unpack(self.lastKill) -- See what the last mob we killed was
    if timestamp and npcID and deltaProgress and isDataUseful then -- Assert that we have some useful data to work with
        local timeSinceKill = GetTimeInMilliSeconds() - timestamp
        self:DebugPrint("timeSinceKill: " .. timestamp .. " Current Time: " .. GetTimeInMilliSeconds() .. "Timestamp of kill: " .. timeSinceKill)
        if timeSinceKill <= self:GetSetting("maxTimeSinceKill") then
            self:DebugPrint(string.format("Gained %f%%. Last mob killed was %s (%i) %fs ago", deltaProgress, npcName, npcID, timeSinceKill/1000))
            if ((self.DB.autoLearnScores == 'newOnly' and self:GetValue(npcID)) or self.DB.autoLearnScores == 'off') then
                return
            end

            local updated = self:UpdateValue(npcID, deltaProgress, npcName, true) -- Looks like we have ourselves a valid entry. Set this in our database/list/whatever.
            if updated and self:GetSetting('debugNewNPCScores') then
                self:Print(string.format("Gained %f%%. Last mob killed was %s (%i) %fs ago", deltaProgress, npcName, npcID, timeSinceKill/1000))
            end
        else
            self:DebugPrint(string.format("Gained %f%%. Last mob killed was %s (%i) %fs ago (PAST CUTOFF!)", deltaProgress, npcName, npcID, timeSinceKill))
        end
    end
end

-- Called directly by our hook
function MMPE:OnCriteriaUpdate()
    self:DebugPrint("onCriteriaUpdate called")
    if not self.previousQuantity then
        self.previousQuantity = 0
    end
    if not self:IsMythicPlus() or not self.loaded or not self:GetSetting("enabled") then return end
    local newQuantity = self:GetCurrentQuantity()
    local deltaQuantity = newQuantity - self.previousQuantity
    if deltaQuantity > 0 then
        self.previousQuantity = newQuantity
        self:OnProgressUpdated(deltaQuantity)
    end
end

-- Called directly by our hook
function MMPE:OnCombatLogEvent(args)
    local _, combatType, _, _, _, _, _, destGUID, destName, _ = unpack(args)
    if combatType == "PARTY_KILL" then
        if not self:IsMythicPlus() then return end
        local npcID = self:GetNPCID(destGUID)
        if npcID then
            local isDataUseful = true
            local timeSinceLastKill = GetTimeInMilliSeconds() - self.lastKill[1]
            if timeSinceLastKill <= self:GetSetting("inconclusiveDataThreshold") then
                self:DebugPrint("Data not useful: " .. timeSinceLastKill .. " - " .. self.lastKill[1] .. " - " .. GetTimeInMilliSeconds())
                isDataUseful = false
            end
            self.lastKill = { GetTimeInMilliSeconds(), npcID, destName, isDataUseful} -- timestamp is not at all accurate, we use GetTime() instead.
            self:DebugPrint('lastKill:', unpack(self.lastKill))
        end
    end
end

function MMPE:VerifySettings(overwriteWithDefault)
    for setting, value in pairs(self.defaultSettings) do
        if self.DB.settings[setting] == nil or overwriteWithDefault then
            self.DB.settings[setting] = value
        end
    end
    if string.len(self.DB.settings["nameplateTextColor"]) == 6 then
        -- alpha got added in a later version
        self.DB.settings["nameplateTextColor"] = "FF" .. self.DB.settings["nameplateTextColor"]
    end
    self.DB.settings["offsetx"] = tonumber(self.DB.settings["offsetx"])
    self.DB.settings["offsety"] = tonumber(self.DB.settings["offsety"])
end

function MMPE:VerifyDB(fullWipe, npcDataWipe)
    if not self.DB or not self.DB.settings or not self.DB.npcData or fullWipe then
        self:Print(L["Running first time setup. This should only happen once. Enjoy! ;)"])
        wipe(MMPEDB)
        self.DB = MMPEDB
        self.DB.settings = {}
        self.DB.npcData = {}
    end
    self:VerifySettings()

    local emptyPatchVersionInfo = { timestamp = 0, version = "0.0.0", build = 0 }

    if npcDataWipe then
        wipe(self.DB.npcData)
        self.DB.npcDataPatchVersion = 0
        self.DB.npcDataPatchVersionInfo = emptyPatchVersionInfo
    end

    local currentPatchVersion = self.DB.npcDataPatchVersion or 0
    local newPatchVersion = currentPatchVersion
    local newPatchVersionInfo = self.DB.npcDataPatchVersionInfo or emptyPatchVersionInfo
    self.dungeonOverrides = {}
	for _, dataProvider in pairs(ns.data) do
        local patchVersionInfo = dataProvider:GetPatchVersion()
        local patchVersion = patchVersionInfo.timestamp
		local defaultValues = dataProvider:GetNPCData()

        local forceUpdate = false
        if currentPatchVersion < patchVersion then
            forceUpdate = true
            newPatchVersion = max(newPatchVersion, patchVersion)
            newPatchVersionInfo = patchVersionInfo
        end
        for npcId, npcData in pairs(defaultValues) do
            self:UpdateValue(npcId, npcData.count, npcData.name, false, forceUpdate)
        end
        if dataProvider.GetDungeonOverrides then
            self.dungeonOverrides = Mixin(self.dungeonOverrides, dataProvider:GetDungeonOverrides())
        end
	end
    self.DB.npcDataPatchVersion = newPatchVersion
    self.DB.npcDataPatchVersionInfo = newPatchVersionInfo

end

---
--- TOOLTIPS
---

function MMPE:ShouldAddTooltip(unit)
    if self.loaded and self:GetSetting("enabled") and self:GetSetting("enableTooltip") and self:IsMythicPlus() and self:IsValidTarget(unit) then
        return true
    end
    return false
end

function MMPE:GetTooltipMessage(npcID)
    local message = "|cFF"..self:GetSetting("tooltipColor") .. L["M+Progress:"] .. " "
    local estimatedProgress, count, maxCount = self:GetEstimatedProgress(npcID)
    if not estimatedProgress then
        return message .. L["No record."]
    end
    if estimatedProgress == 0 then
        return message .. L["No Progress."]
    end
    local mobsLeft = (maxCount - self:GetCurrentQuantity()) / count
    if self:GetSetting('includeCountInTooltip') then
        message = string.format("%s%.2f%% %i/%i (%i left)", message, estimatedProgress, count, maxCount, math.ceil(mobsLeft))
    else
        message = string.format("%s%.2f%% (%i left)", message, estimatedProgress, math.ceil(mobsLeft))
    end

    return message
end

function MMPE:OnNPCTooltip(tooltip)
    local unit = select(2, TooltipUtil.GetDisplayedUnit(tooltip))
    if not unit then return end
    local guid = UnitGUID(unit)
    local npcID = self:GetNPCID(guid)
    if npcID and self:ShouldAddTooltip(unit) then
        local tooltipMessage = self:GetTooltipMessage(npcID)
        if tooltipMessage then
            tooltip:AddDoubleLine(tooltipMessage)
            tooltip:Show()
        end
    end
end

---
--- SHITTY CURRENT PULL FRAME
---

function MMPE:CreatePullFrame()
    self.currentPullFrame = CreateFrame("frame", nil, UIParent)
    SetFramePoint(self.currentPullFrame, self.DB.settings.pullFramePoint)
    self.currentPullFrame:EnableMouse(not self.DB.settings.lockPullFrame)
    self.currentPullFrame:SetMovable(true)
    self.currentPullFrame:RegisterForDrag("LeftButton")
    self.currentPullFrame:SetScript("OnDragStart", function(frame)
        if self.DB.settings.lockPullFrame then return end
        frame:StartMoving()
    end)
    self.currentPullFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        self.DB.settings.pullFramePoint = GetAbsoluteFramePosition(frame)
    end)
    self.currentPullFrame:SetWidth(50)
    self.currentPullFrame:SetHeight(50)

    self.currentPullString = self.currentPullFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightLarge")
    self.currentPullString:SetPoint("CENTER");
    self.currentPullString:SetText(L["MPP String Uninitialized."])
end


---
--- NAMEPLATES
---

function MMPE:IsUnitPulled(unit)
    -- self:DebugPrint("IsUnitPulled with args: " ..target)
    local threat = UnitThreatSituation("player", unit) or -1 -- Is nil if we're not on their aggro table, so make it -1 instead.
    if self:IsValidTarget(unit) and (threat >= 0 or UnitPlayerControlled(unit .. "target")) then
        return true
    end
    return false
end

function MMPE:GetPulledUnits()
    local ret = {}
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        if nameplate.UnitFrame.unitExists then
            if self:IsUnitPulled(nameplate.UnitFrame.displayedUnit) then
                table.insert(ret, UnitGUID(nameplate.UnitFrame.displayedUnit))
            end
        end
    end
    return ret
end

function MMPE:GetPulledProgress()
    local pulledUnits = self:GetPulledUnits()
    local estimatedProgress = 0
    for _, guid in pairs(pulledUnits) do
        local npcID = self:GetNPCID(guid)
        if npcID then
            estimatedProgress = estimatedProgress + (self:GetValue(npcID) or 0)
        end
    end
    return estimatedProgress
end

function MMPE:ShouldShowCurrentPullEstimate(hasCount)
    if self:GetSetting("enabled") and self:GetSetting("enablePullEstimate") and self:IsMythicPlus() and not self:IsDungeonFinished() then
        if self:GetSetting("pullEstimateCombatOnly") and not hasCount then
            return false
        end
        return true
    end
    return false
end

function MMPE:SetCurrentPullEstimateLabel(s)
    self.currentPullString:SetText(s)
    self.currentPullFrame:SetWidth(self.currentPullString:GetStringWidth())
    self.currentPullFrame:SetHeight(self.currentPullString:GetStringHeight())
end

function MMPE:UpdateCurrentPullEstimate()
    local estimatedCount = self:GetPulledProgress()
    if not self:ShouldShowCurrentPullEstimate(estimatedCount > 0) then
        self.currentPullFrame:Hide()
        return
    else
        self.currentPullFrame:Show()
    end
    local message
    local maxCount = self:GetMaxQuantity()
    local currentCount = self:GetCurrentQuantity()
    local totalCount = (estimatedCount + currentCount)
    if estimatedCount == 0 then
        message = L["No recorded mobs pulled or nameplates inactive."]
    else
        message = self:GetSetting('pullFrameTextFormat'); --[[@as string]]
        local percentString = '%.2f%%%%';
        local placeholderReplacements = {
            ['%$current%$'] = currentCount,
            ['%$pull%$'] = estimatedCount,
            ['%$estimated%$'] = totalCount,
            ['%$required%$'] = maxCount,
            ['%$current%%%$'] = percentString:format((currentCount / maxCount) * 100),
            ['%$pull%%%$'] = percentString:format((estimatedCount / maxCount) * 100),
            ['%$estimated%%%$'] = percentString:format((totalCount / maxCount) * 100),
            ['%$required%%%$'] = percentString:format(100),
        };
        for placeholder, replacement in pairs(placeholderReplacements) do
            message = string.gsub(message, placeholder, replacement);
        end
    end
    self:SetCurrentPullEstimateLabel(message)
end

function MMPE:CreateNameplateText(unit)
    local npcID = self:GetNPCID(UnitGUID(unit))
    if npcID then
        if self.activeNameplates[unit] then
            self.activeNameplates[unit]:Hide() -- This should never happen...
        end
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplate then
            self.activeNameplates[unit] = nameplate:CreateFontString(unit .."mppProgress", "OVERLAY", "GameFontHighlightSmall")
            self.activeNameplates[unit]:SetText("+?%")
        end
    end
end

function MMPE:RemoveNameplateText(unit)
    if self.activeNameplates[unit] ~= nil then
        self.activeNameplates[unit]:SetText("")
        self.activeNameplates[unit]:Hide()
        self.activeNameplates[unit] = nil
    end
end

function MMPE:UpdateNameplateValue(unit)
    local npcID = self:GetNPCID(UnitGUID(unit))
    if npcID then
        local estProg = self:GetEstimatedProgress(npcID)
        if estProg and estProg > 0 then
            local message = "|c" .. self:GetSetting("nameplateTextColor") .. "+"
            message = string.format("%s%.2f%%", message, estProg)
            self.activeNameplates[unit]:SetText(message)
            self.activeNameplates[unit]:Show()
            return true
        end
    end
    if self.activeNameplates[unit] then -- If mob dies, a new nameplate is created but not shown, and this ui widget will then not exist.
        self.activeNameplates[unit]:SetText("")
        self.activeNameplates[unit]:Hide()
    end
    return false
end

function MMPE:UpdateNameplateValues()
    for unit, _ in pairs(self.activeNameplates) do
        self:UpdateNameplateValue(unit)
    end
end

function MMPE:UpdateNameplatePosition(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.unitExists and self.activeNameplates[unit] ~= nil then
        local offsetx = self:GetSetting('offsetx')
        local offsety = self:GetSetting('offsety')
        self.activeNameplates[unit]:SetPoint("LEFT", nameplate.UnitFrame.name, "LEFT", nameplate.UnitFrame.name:GetWidth() + offsetx, 0 + offsety)
    else
        self:RemoveNameplateText(unit)
        self:DebugPrint("Unit", unit, "does not seem to exist. Why are we trying to update it?")
    end
end

function MMPE:ShouldShowNameplateTexts()
    if self:GetSetting("enabled") and self:GetSetting("enableNameplateText") and self:IsMythicPlus() and not self:IsDungeonFinished() then
        return true
    end
    return false
end

function MMPE:OnAddNameplate(unit)
    if self:ShouldShowNameplateTexts() then
        self:CreateNameplateText(unit)
        self:UpdateNameplateValue(unit)
        self:UpdateNameplatePosition(unit)
    end
end

function MMPE:OnRemoveNameplate(unit)
    self:RemoveNameplateText(unit)
    self.activeNameplates[unit] = nil -- This line has been made superflous tbh.
end

function MMPE:RemoveNameplates()
    for unit,_ in pairs(self.activeNameplates) do
        self:RemoveNameplateText(unit)
    end
end


function MMPE:UpdateNameplates()
    if self:ShouldShowNameplateTexts() then
        for unit,_ in pairs(self.activeNameplates) do
            self:UpdateNameplatePosition(unit)
        end
    else
        self:RemoveNameplates()
    end
end

---
--- SET UP HOOKS
---

function MMPE:OnInitialize()
    MMPEDB = MMPEDB or {}
    self.DB = MMPEDB

    ------------- disabled for now, might get re-enabled in the future, right now it's incorrectly detecting spiteful kills, and DH demon kills.
    --self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", function() self:OnCriteriaUpdate() end)
    --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(...) self:OnCombatLogEvent({CombatLogGetCurrentEventInfo()}) end)

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", function(_, unit) self:OnAddNameplate(unit) end)
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(_, unit) self:OnRemoveNameplate(unit) end)

    self.frame = CreateFrame("FRAME")
    self:HookScript(self.frame, "OnUpdate", function(_, elapsed) self:OnUpdate(elapsed) end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip) self:OnNPCTooltip(tooltip) end)

    --- wipe NPC data for now, just to make sure that old, bad data is removed for everyone.
    self:VerifyDB(false, true)
    if self:IsMythicPlus() then
        self.quantity = self:GetEnemyForcesProgress()
        self:DebugPrint("MPP Loaded in progress:", self.quantity, "in.")
    else
        self.quantity = 0
        self:DebugPrint("MPP loaded not in progress.")
    end
    self:CreatePullFrame()

    self:InitConfig()
    self:CheckMdtEmulation()

    local openConfig = function() self:OpenConfig() end
    self:RegisterChatCommand('mythicplusprogress', openConfig);
    self:RegisterChatCommand('mypp', openConfig);
    self:RegisterChatCommand('mpp', openConfig);
    self:RegisterChatCommand('mppre', openConfig);
    self:RegisterChatCommand('mppe', openConfig);

    self.loaded = true
end

function MMPE:CheckMdtEmulation()
    if C_AddOns.IsAddOnLoaded("MythicDungeonTools") then return end

    if self:GetSetting('enableMdtEmulation') then
        _G['MDT'] = _G['MDT'] or MDTEmulated
    elseif _G['MDT'] == MDTEmulated then
        _G['MDT'] = nil
    end
end


function MMPE:OnUpdate(elapsed)
    self.currentPullUpdateTimer = self.currentPullUpdateTimer + elapsed * 1000
    if self.currentPullUpdateTimer >= self:GetSetting("nameplateUpdateRate") then
        self.currentPullUpdateTimer = 0
        self:UpdateCurrentPullEstimate()
        self:UpdateNameplateValues()
    end
    self:UpdateNameplates()
end
