-- upvalue the globals
local _G = getfenv(0)
local LibStub = _G.LibStub
local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata
local pairs = _G.pairs
local GetTime = _G.GetTime
local select = _G.select
local strsplit = _G.strsplit
local strtrim = _G.strtrim
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
local UnitAffectingCombat = _G.UnitAffectingCombat
local C_NamePlate = _G.C_NamePlate
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory
local IsControlKeyDown = _G.IsControlKeyDown
local StaticPopup_Show = _G.StaticPopup_Show
local StaticPopupDialogs = _G.StaticPopupDialogs
local max = _G.max
local wipe = _G.wipe
local Mixin = _G.Mixin
local C_ChallengeMode = _G.C_ChallengeMode

local name, ns = ...

local MMPE = LibStub('AceAddon-3.0'):NewAddon(name, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0');
if not MMPE then return end

-- expose to the world, that we exist
_G['MMPE'] = MMPE

ns.addon = MMPE
ns.data = {}
MMPE.ns = ns

MMPE.loaded = false
MMPE.quantity = 0
MMPE.previousQuantity = 0
MMPE.lastKill = { 0} -- To be populated later, do not remove the initial value. The zero means inconclusive/invalid data.
MMPE.currentPullUpdateTimer = 0
MMPE.activeNameplates = {}

MMPE.simulationActive = false
MMPE.simulationMax = 220
MMPE.simulationCurrent = 28
MMPE.simulationMapId = 234 -- upper kara

MMPE.version = GetAddOnMetadata(name, "Version") or "unknown"
MMPE.defaultSettings = {
    enabled = true,

    autoLearnScores = 'newOnly',
    inconclusiveDataThreshold = 100, -- Mobs killed within this span of time (in milliseconds) will not be processed since we might not get the criteria update fast enough to know which mob gave what progress. Well, that's the theory anyway.
    maxTimeSinceKill = 600, -- Lag tolerance between a mob dying and the progress criteria updating, in milliseconds.

    enableTooltip = true,
    includeCountInTooltip = true,
    tooltipColor = "82E0FF",

    enablePullEstimate = true,
    pullEstimateCombatOnly = false,

    nameplateUpdateRate = 200, -- Rate (in milliseconds) at which we update the progress we get from the current pull, as estimated by active name plates you're in combat with. Also the update rate of getting new values for nameplate text overlay if enabled.

    offsetx = 0, -- extra offset for nameplate text
    offsety = 0,

    enableNameplateText = true,
    nameplateTextColor = "FFFFFFFF",

    lockPullFrame = false,
    pullFramePoint = {
        ["anchorPoint"] = "CENTER",
        ["relativeFrame"] = "UIParent",
        ["relativePoint"] = "CENTER",
        ["offX"] = 400,
        ["offY"] = 300,
    },

    debug = false,
    debugNewNPCScores = false,

    enableMdtEmulation = true,
}

MMPE.warnings = {}

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
};

--
-- GENERAL ADDON UTILITY
--

local function GetTimeInSeconds()
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
        else
            self:Print(...)
        end
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

function MMPE:GetSetting(setting)
    if (not setting or self.DB.settings[setting] == nil) then
        self:PrintWarning("MPP attempted to get missing setting: " .. (setting or "nil"))
        return
    end
    return self.DB.settings[setting]
end

function MMPE:SetSetting(setting, value)
    if (not setting or self.DB.settings[setting] == nil) then
        self:PrintWarning("MPP attempted to set missing setting: " .. (setting or "nil"))
        return
    end
    self.DB.settings[setting] = value
    return value
end

function MMPE:ToggleSetting(setting)
    return self:SetSetting(setting, not self:GetSetting(setting))
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
    if UnitCanAttack("player", unit) and not UnitIsDead(unit) then
        return true
    end
end

function MMPE:GetSteps()
    return select(3, C_Scenario.GetStepInfo())
end

function MMPE:IsDungeonFinished()
    if self.simulationActive then return false end
    return (self:GetSteps() and self:GetSteps() < 1)
end

function MMPE:IsMythicPlus()
    if self.simulationActive then return true end
    local difficulty = select(3, GetInstanceInfo()) or -1
    if difficulty == 8 and not self:IsDungeonFinished() then
        return true
    else
        return false
    end
end

function MMPE:GetProgressInfo()
    if self:IsMythicPlus() then
        local numSteps = select(3, C_Scenario.GetStepInfo())
        if numSteps and numSteps > 0 then
            local info = {C_Scenario.GetCriteriaInfo(numSteps)}
            if info[13] == true then -- if isWeightedProgress
                return info
            end
        end
    end
end

function MMPE:GetMaxQuantity()
    if self.simulationActive then return self.simulationMax end
    local info = self:GetProgressInfo()
    if info then
        return info[5]
    end

    return 0
end

function MMPE:GetCurrentQuantity()
    if self.simulationActive then return self.simulationCurrent end
    local info = self:GetProgressInfo()
    if info then
        return strtrim(info[8], "%")
    end

    return 0
end

function MMPE:GetEnemyForcesProgress()
    self:DebugPrint("getEnemyForcesProgress called.")
    -- Returns exact float value of current enemies killed progress (1-100).
    local quantity = self:GetCurrentQuantity() or 0
    local maxQuantity = self:GetMaxQuantity() or 1
    local progress = (quantity / maxQuantity) * 100
    self:DebugPrint(progress)

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
    self:DebugPrint("GetValue called. Args:", npcID)
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
    self:DebugPrint("getEstimatedProgress called. Args:", npcID)
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
        local timeSinceKill = GetTimeInSeconds() - timestamp
        self:DebugPrint("timeSinceKill: " .. timestamp .. " Current Time: " .. GetTimeInSeconds() .. "Timestamp of kill: " .. timeSinceKill)
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
            local timeSinceLastKill = GetTimeInSeconds() - self.lastKill[1]
            if timeSinceLastKill <= self:GetSetting("inconclusiveDataThreshold") then
                self:DebugPrint("Data not useful: " .. timeSinceLastKill .. " - " .. self.lastKill[1] .. " - " .. GetTimeInSeconds())
                isDataUseful = false
            end
            self.lastKill = { GetTimeInSeconds(), npcID, destName, isDataUseful} -- timestamp is not at all accurate, we use GetTime() instead.
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
        self:Print("Running first time setup. This should only happen once. Enjoy! ;)")
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
    local message = "|cFF"..self:GetSetting("tooltipColor") .. "M+Progress: "
    local estimatedProgress, count, maxCount = self:GetEstimatedProgress(npcID)
    if not estimatedProgress then
        return message .. "No record."
    end
    if estimatedProgress == 0 then
        return message .. "No Progress."
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
    self.currentPullString:SetText("MPP String Uninitialized.")
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

function MMPE:GetPulledProgress(pulledUnits)
    local estimatedProgress = 0
    for _, guid in pairs(pulledUnits) do
        local npcID = self:GetNPCID(guid)
        if npcID then
            estimatedProgress = estimatedProgress + (self:GetValue(npcID) or 0)
        end
    end
    return estimatedProgress
end

function MMPE:ShouldShowCurrentPullEstimate()
    if self:GetSetting("enabled") and self:GetSetting("enablePullEstimate") and self:IsMythicPlus() and not self:IsDungeonFinished() then
        if self:GetSetting("pullEstimateCombatOnly") and not UnitAffectingCombat("player") then
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
    if not self:ShouldShowCurrentPullEstimate() then
        self.currentPullFrame:Hide()
        return
    else
        self.currentPullFrame:Show()
    end
    local message
    local pulledUnits = self:GetPulledUnits()
    local estimatedCount = self:GetPulledProgress(pulledUnits)
    local maxCount = self:GetMaxQuantity()
    local currentCount = self:GetCurrentQuantity()
    local totalCount = (estimatedCount + currentCount)
    if estimatedCount == 0 then
        message = "No recorded mobs pulled or nameplates inactive."
    else
        message = string.format(
            "Current pull: %.2f%% + %.2f%% = %.2f%%",
            (currentCount / maxCount) * 100,
            (estimatedCount / maxCount) * 100,
            (totalCount / maxCount) * 100
        )
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
    self:DebugPrint('OnAddNameplate', unit)
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

function MMPE:InitPopup()
    if not StaticPopupDialogs["MPPEDataExportDialog"] then
        StaticPopupDialogs["MPPEDataExportDialog"] = {
            text = "CTRL-C to copy",
            button1 = "Close",
            OnShow = function(dialog, data)
                local function HidePopup()
                    dialog:Hide();
                end
                dialog.editBox:SetScript("OnEscapePressed", HidePopup);
                dialog.editBox:SetScript("OnEnterPressed", HidePopup);
                dialog.editBox:SetScript("OnKeyUp", function(_, key)
                    if IsControlKeyDown() and key == "C" then
                        HidePopup();
                    end
                end);
                dialog.editBox:SetMaxLetters(0);
                dialog.editBox:SetText(data);
                dialog.editBox:HighlightText();
            end,
            hasEditBox = true,
            editBoxWidth = 240,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        };
    end
end

function MMPE:InitConfig()
    local mdtLoaded = C_AddOns.IsAddOnLoaded("MythicDungeonTools");

    local count = 0
    local function increment() count = count + 1; return count end
    local options = {
        type = "group",
        childGroups = "tab",
        name = "Mythic Plus Progress",
        desc = "Mythic Plus Progress tracker",
        get = function(info) return self:GetSetting(info[#info]) end,
        set = function(info, value) self:SetSetting(info[#info], value) end,
        args = {
            version = {
                order = increment(),
                type = "description",
                name = "Version: " .. self.version,
            },
            enabled = {
                order = increment(),
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the addon",
            },
            wipesettings = {
                order = increment(),
                type = "execute",
                name = "Reset Settings to default",
                desc = "Reset Settings to default",
                func = function()
                    self:VerifySettings(true)
                end,
                width = "double",
            },
------------- disabled for now, might get re-enabled in the future, right now it's incorrectly detecting spiteful kills, and DH demon kills.
--[[            scores = {
--                order = increment(),
--                type = "group",
--                name = "Auto Learn Scores",
--                args = {
--                    autoLearnScores = {
--                        order = increment(),
--                        name = "Auto Learn Scores",
--                        desc = "New Only >> Only learn scores that for new NPCs. Useful for new dungeons, and the addon isn't updated yet.\nAlways >> Always learn updated scores. This might make the percentage inaccurate.\nOff >> Don't learn scores.",
--                        type = "select",
--                        values = {
--                            newOnly = "New Only (Recommended)",
--                            always = "Always (Risky)",
--                            off = "Off",
--                        },
--                    },
--                    inconclusiveDataThreshold = {
--                        order = increment(),
--                        name = "Inconclusive Data Threshold",
--                        desc = "Mobs killed within this span of time (in milliseconds) will not be processed since we might not get the criteria update fast enough to know which mob gave what progress.",
--                        type = "range",
--                        min = 50,
--                        max = 400,
--                        step = 10,
--                        hidden = true,
--                    },
--                    maxTimeSinceKill = {
--                        order = increment(),
--                        name = "Max Time Since Kill",
--                        desc = "Lag tolerance between a mob dying and the progress criteria updating, in milliseconds.",
--                        type = "range",
--                        min = 0,
--                        max = 1000,
--                        step = 10,
--                        hidden = true,
--                    },
--                },
--            },--]]
            mainOptions = {
                order = increment(),
                type = "group",
                name = "Main Options",
                args = {
                    tooltip = {
                        order = increment(),
                        type = "group",
                        name = "Tooltip",
                        inline = true,
                        args = {
                            enableTooltip = {
                                order = increment(),
                                type = "toggle",
                                name = "Enable Tooltip",
                                desc = "Adds percentage info to the unit tooltip",
                            },
                            includeCountInTooltip = {
                                order = increment(),
                                type = "toggle",
                                name = "Include Count",
                                desc = "Include the raw count value in the tooltip, as well as the percentage",
                            },
                        },
                    },
                    pullEstimateFrame = {
                        order = increment(),
                        type = "group",
                        name = "Pull Estimate frame",
                        inline = true,
                        args = {
                            enablePullEstimate = {
                                order = increment(),
                                type = "toggle",
                                name = "Enable Current Pull frame",
                                desc = "Display a frame with current pull information",
                            },
                            pullEstimateCombatOnly = {
                                order = increment(),
                                type = "toggle",
                                name = "Only in combat",
                                desc = "Only show the frame when you are in combat",
                            },
                            lockPullFrame = {
                                order = increment(),
                                type = "toggle",
                                name = "Lock frame",
                                desc = "Lock the frame in place",
                                set = function(info, value)
                                    self:SetSetting(info[#info], value)
                                    self.currentPullFrame:EnableMouse(not value)
                                end,
                            },
                            reset = {
                                order = increment(),
                                type = "execute",
                                name = "Reset position",
                                desc = "Reset position of Current Pull frame to the default",
                                func = function()
                                    self.DB.settings.pullFramePoint = self.defaultSettings.pullFramePoint
                                    SetFramePoint(self.currentPullFrame, self.DB.settings.pullFramePoint)
                                end,
                            },
                        },
                    },
                    nameplate = {
                        order = increment(),
                        type = "group",
                        name = "Nameplate",
                        inline = true,
                        args = {
                            enableNameplateText = {
                                order = increment(),
                                type = "toggle",
                                name = "Enable Nameplate Text",
                                desc = "Adds the % info to the enemy nameplates",
                                descStyle = "inline",
                            },
                            nameplateTextColor = {
                                order = increment(),
                                type = "color",
                                name = "Nameplate Text Color",
                                desc = "Color of the text on the enemy nameplates",
                                hasAlpha = true,
                                get = function(info)
                                    local hex = self:GetSetting(info[#info])
                                    return tonumber(hex:sub(3,4), 16) / 255, tonumber(hex:sub(5,6), 16) / 255, tonumber(hex:sub(7,8), 16) / 255, tonumber(hex:sub(1,2), 16) / 255
                                end,
                                set = function(info, r, g, b, a)
                                    self:SetSetting(info[#info], string.format("%02x%02x%02x%02x", a * 255, r * 255, g * 255, b * 255))
                                end,
                            },
                            offsetx = {
                                order = increment(),
                                type = "range",
                                name = "Horizontal offset ( <-> )",
                                desc = "Horizontal offset of the nameplate text",
                                width = "double",
                                softMin = -100,
                                softMax = 100,
                                bigStep = 1,
                            },
                            offsety = {
                                order = increment(),
                                type = "range",
                                name = "Vertical Offset ( | )",
                                desc = "Vertical offset of the nameplate text",
                                width = "double",
                                softMin = -100,
                                softMax = 100,
                                bigStep = 1,
                            },
                        },
                    },
                    experimental = {
                        order = increment(),
                        type = "group",
                        name = "Experimental",
                        inline = true,
                        args = {
                            description = {
                                order = increment(),
                                type = "description",
                                name = "These options are experimental and may not work as intended.",
                            },
                            mdtEmulation = {
                                order = increment(),
                                type = "group",
                                inline = true,
                                name = "MDT Emulation",
                                args = {
                                    mdtEmulationDescription = {
                                        order = increment(),
                                        type = "description",
                                        name = mdtLoaded and "Disabled when MythicDungeonTools is loaded" or "Allows addons and WAs that use MythicDungeonTools for % info to work with this addon instead.",
                                        width = "double",
                                    },
                                    enableMdtEmulation = {
                                        order = increment(),
                                        type = "toggle",
                                        name = "Enable MDT Emulation",
                                        desc = "",
                                        set = function(info, value)
                                            self:SetSetting(info[#info], value)
                                            self:CheckMdtEmulation()
                                        end,
                                        disabled = mdtLoaded,
                                    },
                                },
                            },
                        },
                    },
                },
            },
            devOptions = {
                order = increment(),
                type = "group",
                name = "Developer Options",
                args = {
                    debug = {
                        order = increment(),
                        type = "toggle",
                        name = "Debug",
                        desc = "Enable/Disable debug prints",
                    },
                    debugNewNPCScores = {
                        order = increment(),
                        type = "toggle",
                        name = "Debug New NPC Scores",
                        desc = "Enable/Disable debug prints for new NPC scores",
                    },
                    exportData = {
                        order = increment(),
                        type = "execute",
                        name = "Export NPC data",
                        desc = "Opens a popup which allows copying the data",
                        func = function() self:ExportData() end,
                    },
                    exportUpdatedData = {
                        order = increment(),
                        type = "execute",
                        name = "Export updated NPC data",
                        desc = "Export only data that is different from the default values",
                        func = function() self:ExportData(true) end,
                    },
                    npcDataPatchVersion = {
                        order = increment(),
                        type = "description",
                        name = function() return
                        string.format(
                                "NPC data patch version: %s, build %d (ts %d)",
                                self.DB.npcDataPatchVersionInfo.version,
                                self.DB.npcDataPatchVersionInfo.build,
                                self.DB.npcDataPatchVersionInfo.timestamp
                        )
                        end,
                    },
                    resetNpcData = {
                        order = increment(),
                        type = "execute",
                        name = "Reset NPC data",
                        desc = "Reset the NPC data to the default values",
                        func = function() self:VerifyDB(false, true) end,
                        confirm = true,
                        confirmText = "Are you sure you want to reset the NPC data to the defaults?",
                    },
                    simulationActive = {
                        order = increment(),
                        type = "toggle",
                        name = "Simulation Mode",
                        desc = "Enable/Disable Simulation Mode",
                        width = "double",
                        get = function(info) return self.simulationActive end,
                        set = function(info, value) self.simulationActive = value end,
                    },
                    simulationMax = {
                        order = increment(),
                        type = "range",
                        name = "Simulation Required Points",
                        desc = "Simulated number of 'points' required to complete the run",
                        softMin = 1,
                        softMax = 100,
                        bigStep = 1,
                        get = function(info) return self.simulationMax end,
                        set = function(info, value) self.simulationMax = value end,
                    },
                    simulationCurrent = {
                        order = increment(),
                        type = "range",
                        name = "Simulation Current Points",
                        desc = "Simulated number of 'points' currently earned",
                        softMin = 1,
                        softMax = 100,
                        bigStep = 1,
                        get = function(info) return self.simulationCurrent end,
                        set = function(info, value) self.simulationCurrent = value end,
                    },
                    wipeAll = {
                        order = increment(),
                        type = "execute",
                        name = "Wipe All Data",
                        desc = "Wipe all data",
                        func = function() self:VerifyDB(true) end,
                        confirm = true,
                        confirmText = "Are you sure you want to wipe all data?",
                    },
                },
            },
        },
    }

    self.configCategory = "MythicPlusProgress"
    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.configCategory, options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.configCategory)
end

function MMPE:OpenConfig()
    InterfaceOptionsFrame_OpenToCategory(self.configCategory);
    InterfaceOptionsFrame_OpenToCategory(self.configCategory);
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
