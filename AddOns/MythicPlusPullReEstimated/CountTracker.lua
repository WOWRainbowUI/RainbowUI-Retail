local name, ns = ...

--- @class MMPE
local MMPE = ns.addon

--- @class MPPECountTracker: Frame
local countTracker = CreateFrame('Frame');
countTracker.count = 0
countTracker.recentlyKilled = {}

MMPE.countTracker = countTracker

--[[
This file mostly existed as a workaround for not having any count information available in the API.
This has been resolved by blizzard, so most of the functionality has been disabled.
It has been left for posterity, since I might find it useful in the future.
--]]

--countTracker:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
--countTracker:RegisterEvent('PLAYER_ENTERING_WORLD')
--countTracker:RegisterEvent('PLAYER_LEAVING_WORLD')
--countTracker:RegisterEvent('CHALLENGE_MODE_START')

function countTracker:PLAYER_ENTERING_WORLD()
    self:UpdateRegisteredEvents()
    self:RefreshInfo()
end
function countTracker:PLAYER_LEAVING_WORLD()
    self:UpdateRegisteredEvents()
end
function countTracker:CHALLENGE_MODE_START()
    self:UpdateRegisteredEvents()
    self:RefreshInfo()
end

function countTracker:RefreshInfo()
    local info = MMPE:GetProgressInfo()
    if info then
        if info.quantityString then
            self.count = tonumber((info.quantityString:gsub('%%', '')))

            return self.count
        else
            MMPE:Print('error, C_ScenarioInfo.GetCriteriaInfo.quantityString not found')
            -- there was an issue in TWW, that C_ScenarioInfo.GetCriteriaInfo.quantity reports the % instead of raw quantity count, and .quantityString didn't exist yet
            -- this math does mean we lose quite a lot of precision
            local estimatedCountMin = math.floor(info.totalQuantity * (info.quantity / 100))
            local estimatedCountMax = math.ceil(info.totalQuantity * ((info.quantity + 1) / 100))

            local trackedCount = self.count
            if trackedCount < estimatedCountMin or trackedCount > estimatedCountMax then
                MMPE:DebugPrint('force updating count to', estimatedCountMin, '. old count:', trackedCount, 'estimatedMin:', estimatedCountMin, 'estimatedMax:', estimatedCountMax)
                self.count = estimatedCountMin
            end

            return self.count
        end
    end
end

function countTracker:UpdateRegisteredEvents()
    if true then return end -- disabled now that we have proper count info again. the workaround code is left in place for future reference
    if MMPE:IsMythicPlus(true) then
        MMPE:DebugPrint('MMPE: Listening for combat events')
        self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        self:SetScript('OnUpdate', self.OnUpdate)
    else
        MMPE:DebugPrint('MMPE: Stopped listening for combat events')
        self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        self:SetScript('OnUpdate', nil)
    end
end

local lastUpdate = 0
function countTracker:OnUpdate(elapsed)
    if (lastUpdate + elapsed) < 3 then
        lastUpdate = lastUpdate + elapsed
        return
    end
    local now = GetTime()
    for guid, time in pairs(self.recentlyKilled) do
        if (now - time) > 10 then
            self.recentlyKilled[guid] = nil
        end
    end
end

function countTracker:ResetTrackedData()
    MMPE:DebugPrint('MMPE: resetting count tracker')
    self.count = 0
    self.recentlyKilled = {}
end

function countTracker:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, _, _, _, _, destGUID, destName, _ = CombatLogGetCurrentEventInfo()

    if destGUID and (subEvent == 'UNIT_DIED' or subEvent == 'PARTY_KILL') then
        local npcID = MMPE:GetNPCID(destGUID)
        if not npcID then return end
        local count = MMPE:GetValue(npcID)
        if not count or count == 0 then return end
        local time = GetTime()
        if self.recentlyKilled[destGUID] and time - self.recentlyKilled[destGUID] < 5 then return end
        self.recentlyKilled[destGUID] = time
        self.count = self.count + count
        MMPE:DebugPrint('MMPE: Count increased to ' .. self.count, 'by', count, 'from killing', destName)
    end
end

