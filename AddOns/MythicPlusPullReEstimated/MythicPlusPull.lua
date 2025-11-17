local name, ns = ...
ns.data = {}

if select(4, GetBuildInfo()) >= 120000 then
    print('Mythic Plus Pull currently does not work in 12.0 and later. This may change depending on Blizzard.')

    return
end

local DIFFICULTY_MYTHIC_PLUS = 8

--- @class MythicPlusPull: AceAddon, AceConsole-3.0, AceEvent-3.0
local MPP = LibStub('AceAddon-3.0'):NewAddon(name, 'AceConsole-3.0', 'AceEvent-3.0');

local L = LibStub('AceLocale-3.0'):GetLocale(name)
local LibGetFrame = LibStub('LibGetFrame-1.0');

--[==[@debug@
_G.MythicPlusPull = MPP;
if not _G.MPP then _G.MPP = MPP; end
--@end-debug@]==]

--
-- Public API
--
--- @class MPP_API
MPP_API = {};
--- @param npcID number
--- @return number? rawCount
function MPP_API:GetNpcCount(npcID)
    return MPP:GetCountByNpcID(npcID)
end

--- Returns progress and pull count information. Pull count information is updated on a timer (roughly 5x per second)
--- @return number? currentCount # total count already cleared
--- @return number? maxCount # total count required for completion
--- @return number? pullCount # total count of NPCs in the current pull
function MPP_API:GetProgress()
    return MPP:GetCurrentCount(), MPP:GetTotalCountRequired(), MPP:GetCurrentPullCount()
end

--
-- Emulated MDT API
--
local MDTEmulated = {
    GetEnemyForces = function(_, npcID)
        local count = MPP:GetCountByNpcID(npcID);
        if count and count > 0 then
            local maxCount = MPP:GetTotalCountRequired();
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
        local maxCount = MPP:GetTotalCountRequired();
        return { normal = maxCount, teeming = maxCount, teemingEnabled = true };
    end});
end

local nameplateAccessor = function(unit)
    return LibGetFrame.GetUnitNameplate(unit);
end
do
    local defaultAccessor = nameplateAccessor
    local nameplateAddons = {
        {
            addonName = 'TidyPlates',
            nameplateAccessor = function(unit)
                local plate = defaultAccessor(unit);

                return plate and plate.extended or plate;
            end,
        },
    };
    for _, info in ipairs(nameplateAddons) do
        if C_AddOns.IsAddOnLoaded(info.addonName) then
            nameplateAccessor = info.nameplateAccessor;

            break;
        end
    end
end

ns.addon = MPP
MPP.ns = ns

MPP.loaded = false
MPP.previousQuantity = 0
--- @type table<string, FontString>
MPP.activeNameplates = {}

MPP.simulationActive = false
MPP.simulationMax = 220
MPP.simulationCurrent = 28
MPP.simulationMapID = 234 -- upper kara

MPP.warnings = {}

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

function MPP:OnInitialize()
    MMPEDB = MMPEDB or {}
    self.DB = MMPEDB

    local function init()
        return UIParent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    end
    local function reset(_, obj)
        if not obj then return end
        obj:ClearAllPoints()
        obj:SetText("")
        obj:Hide()
    end
    self.fontStringPool = CreateObjectPool(init, reset) --[[@as ObjectPool<FontString>]]

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", function(_, unit) self:OnAddNameplate(unit) end)
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(_, unit) self:RemoveNameplateText(unit) end)
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE");

    C_Timer.NewTicker(0.2, function() self:DoUpdate() end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip) self:OnUnitTooltip(tooltip) end)

    self:VerifyDB()
    self:FillNpcCountCache()
    self:CreatePullFrame()

    self:InitConfig()
    self:CheckMdtEmulation()

    local openConfig = function() self:OpenConfig() end
    self:RegisterChatCommand('mythicplusprogress', openConfig);
    self:RegisterChatCommand('mythicpluspull', openConfig);
    self:RegisterChatCommand('mypp', openConfig);
    self:RegisterChatCommand('mpp', openConfig);
    self:RegisterChatCommand('mppre', openConfig);
    self:RegisterChatCommand('mppe', openConfig);

    self.loaded = true

    if NumyProfiler then
        NumyProfiler:WrapModules('MythicPlusPull', 'Core', self);
    end
end

function MPP:CheckMdtEmulation()
    if C_AddOns.IsAddOnLoaded("MythicDungeonTools") then return end

    if self:GetSetting('enableMdtEmulation') then
        _G['MDT'] = _G['MDT'] or MDTEmulated
    elseif _G['MDT'] == MDTEmulated then
        _G['MDT'] = nil
    end
end

function MPP:DoUpdate()
    if not self:IsMythicPlus() then
        self.currentPullFrame:Hide()

        return
    end
    self:UpdateCurrentPullEstimate()
    self:UpdateNameplateValues()
    self:UpdateNameplates()
end

function MPP:SCENARIO_CRITERIA_UPDATE(_, criteriaID)
    if not criteriaID or not self:GetSetting('debugCriteriaEvents') or not self:IsMythicPlus(true) then return end

    local mapID = self:GetCurrentMapID()
    local info = mapID and self.criteriaDebugData[mapID] and self.criteriaDebugData[mapID][criteriaID]
    if not info then return end

    self:Print('Criteria update for', criteriaID, 'should give count', info.count, '; associated npcID:', info.npcID)
end

function MPP:DebugPrint(...)
    if self:GetSetting('debug') then
        if (_G.DevTool and _G.DevTool.AddData) then
            _G.DevTool:AddData({ ... }, "MMPE DebugPrint")
        end
        self:Print(...)
    end
end

function MPP:HasWarned(message)
    for _, warning in pairs(self.warnings) do
        if warning == message then
            return true
        end
    end
    return false
end

function MPP:PrintWarning(message)
    if not self:HasWarned(message) then
        self:Print(message)
        table.insert(self.warnings, message)
        return true
    end
    return false
end

function MPP:VerifySettings(overwriteWithDefault)
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

function MPP:VerifyDB()
    if not self.DB or not self.DB.settings then
        self:Print(L["Running first time setup. This should only happen once. Enjoy! ;)"])
        wipe(MMPEDB)
        self.DB = MMPEDB
        self.DB.settings = {}
    end
    self:VerifySettings()
end

function MPP:FillNpcCountCache()
    self.npcData = {}
    self.dungeonOverrides = {}
    self.criteriaDebugData = {}

    local newPatchVersionInfo = { timestamp = 0 }
    for _, dataProvider in pairs(ns.data) do
        for npcID, npcData in pairs(dataProvider:GetNPCData()) do
            self.npcData[npcID] = npcData.count
        end
        if dataProvider.GetDungeonOverrides then
            self.dungeonOverrides = Mixin(self.dungeonOverrides, dataProvider:GetDungeonOverrides())
        end
        if dataProvider.GetDebugData then
            self.criteriaDebugData = Mixin(self.criteriaDebugData, dataProvider:GetDebugData())
        end

        local patchVersionInfo = dataProvider:GetPatchVersion()
        if newPatchVersionInfo.timestamp < patchVersionInfo.timestamp then
            newPatchVersionInfo = patchVersionInfo
        end
    end
    self.npcDataPatchVersionInfo = newPatchVersionInfo
end

--- @param unit UnitToken
--- @return number? npcID
function MPP:GetUnitCreatureID(unit)
    local guid = unit and UnitGUID(unit)
    if guid == nil then return nil end

    local targetType, _, _, _, _, npcID = strsplit("-", guid)
    if (targetType == "Creature" or targetType == "Vehicle") and npcID then
        return tonumber(npcID)
    end
end

function MPP:IsValidTarget(unit)
    return UnitCanAttack("player", unit)
end

--- @return number numberOfSteps
function MPP:GetNumberOfScenarioSteps()
    return select(3, C_Scenario.GetStepInfo()) or 0
end

function MPP:IsDungeonFinished(ignoreSimulation)
    if not ignoreSimulation and self.simulationActive then return false end

    return self:GetNumberOfScenarioSteps() < 1
end

function MPP:IsMythicPlus(ignoreSimulation)
    if not ignoreSimulation and self.simulationActive then return true end

    local difficulty = select(3, GetInstanceInfo()) or -1

    return difficulty == DIFFICULTY_MYTHIC_PLUS and not self:IsDungeonFinished(ignoreSimulation)
end

--- @return ScenarioCriteriaInfo? criteriaInfo
function MPP:GetProgressCriteriaInfo()
    if self:IsMythicPlus() then
        local numSteps = self:GetNumberOfScenarioSteps()
        if numSteps > 0 then
            local info = C_ScenarioInfo.GetCriteriaInfo(numSteps)

            return info.isWeightedProgress and info or nil
        end
    end
end

function MPP:GetTotalCountRequired()
    if self.simulationActive then return self.simulationMax end

    local info = self:GetProgressCriteriaInfo()
    if info then
        return info.totalQuantity
    end

    return 0
end

function MPP:GetCurrentCount()
    if self.simulationActive then return self.simulationCurrent end

    local info = self:GetProgressCriteriaInfo()
    if info and info.quantityString then
        return tonumber((info.quantityString:gsub('%%', '')))
    end

    return 0
end

--- @return number countPercent # a float from 0-100
function MPP:GetCountPercent()
    local quantity = self:GetCurrentCount() or 0
    local maxQuantity = self:GetTotalCountRequired() or 1
    local progress = (quantity / maxQuantity) * 100

    return progress
end

function MPP:GetCurrentMapID()
    if self.simulationActive then return self.simulationMapID end

    return C_ChallengeMode.GetActiveChallengeMapID()
end

--- @return number? count
function MPP:GetCountByNpcID(npcID)
    local mapID = self:GetCurrentMapID()
    if (mapID and self.dungeonOverrides[mapID] and self.dungeonOverrides[mapID][npcID] and self.dungeonOverrides[mapID][npcID].count) then
        return self.dungeonOverrides[mapID][npcID].count
    end

    local count = self.npcData[npcID]

    return count or (self.simulationActive and 3) or nil
end

--- @return number? percent # a float from 0-100
--- @return number? count
--- @return number? requiredCount
function MPP:GetEstimatedProgress(npcID)
    local npcValue = self:GetCountByNpcID(npcID)
    local maxQuantity = self:GetTotalCountRequired()
    if npcValue and maxQuantity then
        return (npcValue / maxQuantity) * 100, npcValue, maxQuantity
    end
end

---
--- TOOLTIPS
---
function MPP:ShouldAddToTooltip(unit)
    return self.loaded and self:GetSetting("enabled") and self:GetSetting("enableTooltip") and self:IsMythicPlus() and self:IsValidTarget(unit)
end

function MPP:GetTooltipMessage(npcID)
    local message = "|cFF" .. self:GetSetting("tooltipColor") .. L["M+Progress:"] .. " "
    local estimatedProgress, count, maxCount = self:GetEstimatedProgress(npcID)
    if not estimatedProgress then
        return message .. L["No record."]
    end
    if estimatedProgress == 0 then
        return message .. L["No Progress."]
    end
    local mobsLeft = (maxCount - self:GetCurrentCount()) / count
    if self:GetSetting('includeCountInTooltip') then
        message = string.format("%s%.2f%% %i/%i (%i left)", message, estimatedProgress, count, maxCount, math.ceil(mobsLeft))
    else
        message = string.format("%s%.2f%% (%i left)", message, estimatedProgress, math.ceil(mobsLeft))
    end

    return message
end

function MPP:OnUnitTooltip(tooltip)
    local unit = select(2, TooltipUtil.GetDisplayedUnit(tooltip))
    if not unit then return end

    local npcID = self:GetUnitCreatureID(unit)
    if not npcID or not self:ShouldAddToTooltip(unit) then return end

    local tooltipMessage = self:GetTooltipMessage(npcID)
    if tooltipMessage then
        tooltip:AddDoubleLine(tooltipMessage)
        tooltip:Show()
    end
end

---
--- SHITTY CURRENT PULL FRAME
---
function MPP:CreatePullFrame()
    self.currentPullFrame = CreateFrame("frame", nil, UIParent)
    SetFramePoint(self.currentPullFrame, self.DB.settings.pullFramePoint)
    self.currentPullFrame:EnableMouse(not self:GetSetting("lockPullFrame"))
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
    self.currentPullFrame:SetScale(self:GetSetting("pullFrameTextScale"))

    self.currentPullString = self.currentPullFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightLarge")
    self.currentPullString:SetPoint("CENTER");
    self.currentPullString:SetText("")
end

---
--- NAMEPLATES
---
function MPP:IsUnitPulled(unit)
    local threat = UnitThreatSituation("player", unit) or -1 -- Is nil if we're not on their aggro table, so make it -1 instead.

    return self:IsValidTarget(unit) and (threat >= 0 or UnitPlayerControlled(unit .. "target"))
end

--- @return UnitToken.nameplate[] pulledUnits
function MPP:GetPulledUnits()
    local pulledUnits = {}
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        if nameplate.UnitFrame.unitExists then
            if self:IsUnitPulled(nameplate.UnitFrame.displayedUnit) then
                tinsert(pulledUnits, nameplate.UnitFrame.displayedUnit)
            end
        end
    end

    return pulledUnits
end

--- @return number currentPullCount
function MPP:GetCurrentPullCount()
    local pulledUnits = self:GetPulledUnits()
    local estimatedProgress = 0
    for _, unit in pairs(pulledUnits) do
        local npcID = self:GetUnitCreatureID(unit)
        if npcID then
            estimatedProgress = estimatedProgress + (self:GetCountByNpcID(npcID) or 0)
        end
    end

    return estimatedProgress
end

function MPP:ShouldShowCurrentPullEstimate(hasCount)
    if self:GetSetting("enabled") and self:GetSetting("enablePullEstimate") and self:IsMythicPlus() and not self:IsDungeonFinished() then
        return hasCount or not self:GetSetting("pullEstimateCombatOnly")
    end

    return false
end

function MPP:SetCurrentPullEstimateLabel(s)
    self.currentPullString:SetText(s)
    self.currentPullFrame:SetWidth(self.currentPullString:GetStringWidth())
    self.currentPullFrame:SetHeight(self.currentPullString:GetStringHeight())
end

function MPP:UpdateCurrentPullEstimate()
    local estimatedCount = self:GetCurrentPullCount()
    if not self:ShouldShowCurrentPullEstimate(estimatedCount > 0) then
        self.currentPullFrame:Hide()

        return
    end

    self.currentPullFrame:Show()
    local message
    local maxCount = self:GetTotalCountRequired()
    local currentCount = self:GetCurrentCount()
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

function MPP:CreateNameplateText(unit)
    local npcID = self:GetUnitCreatureID(unit)
    if not npcID then return end

    if self.activeNameplates[unit] then -- This should never happen
        self:RemoveNameplateText(unit)
    end
    --- @type Frame?
    local nameplate = nameplateAccessor(unit)
    if nameplate then
        if not nameplate:IsVisible() then
            nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        end
        self.activeNameplates[unit] = self.fontStringPool:Acquire()
        self.activeNameplates[unit]:SetParent(nameplate)
        self.activeNameplates[unit]:SetFont(STANDARD_TEXT_FONT, 8, "") -- 自行修改
        self.activeNameplates[unit]:SetText("+?%")
        self.activeNameplates[unit]:SetScale(self:GetSetting('nameplateTextScale'))
    end
end

function MPP:RemoveNameplateText(unit)
    if self.activeNameplates[unit] ~= nil then
        self.fontStringPool:Release(self.activeNameplates[unit])
        self.activeNameplates[unit] = nil
    end
end

function MPP:UpdateNameplateValue(unit)
    local npcID = self:GetUnitCreatureID(unit)
    if npcID then
        local estProg, count = self:GetEstimatedProgress(npcID)
        if count and count > 0 then
            local message = "|c" .. self:GetSetting("nameplateTextColor")
            message = message .. self:GetSetting("nameplateTextFormat") --[[@as string]]
            local placeholderReplacements = {
                ['%$percent%$'] = string.format("%.2f", estProg),
                ['%$count%$'] = count,
            };
            for placeholder, replacement in pairs(placeholderReplacements) do
                message = string.gsub(message, placeholder, replacement);
            end

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

function MPP:UpdateNameplateValues()
    for unit, _ in pairs(self.activeNameplates) do
        self:UpdateNameplateValue(unit)
    end
end

function MPP:UpdateNameplatePosition(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.unitExists and self.activeNameplates[unit] ~= nil then
        local offsetx = self:GetSetting('offsetx')
        local offsety = self:GetSetting('offsety')
        self.activeNameplates[unit]:SetPoint("LEFT", self.activeNameplates[unit]:GetParent(), "RIGHT", offsetx, offsety)
    else
        self:RemoveNameplateText(unit)
        self:DebugPrint("Unit", unit, "does not seem to exist. Why are we trying to update it?")
    end
end

function MPP:ShouldShowNameplateTexts()
    return self:GetSetting("enabled") and self:GetSetting("enableNameplateText") and self:IsMythicPlus() and not self:IsDungeonFinished()
end

function MPP:OnAddNameplate(unit)
    if self:ShouldShowNameplateTexts() then
        RunNextFrame(function() -- allow nameplate addons to create their frames first
            self:CreateNameplateText(unit)
            self:UpdateNameplateValue(unit)
            self:UpdateNameplatePosition(unit)
        end)
    end
end

function MPP:UpdateNameplates()
    local shouldShow = self:ShouldShowNameplateTexts()
    for unit, _ in pairs(CopyTable(self.activeNameplates)) do
        if shouldShow then
            self:UpdateNameplatePosition(unit)
        else
            self:RemoveNameplateText(unit)
        end
    end
end
