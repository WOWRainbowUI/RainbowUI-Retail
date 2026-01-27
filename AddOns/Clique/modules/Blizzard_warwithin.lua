--[[-------------------------------------------------------------------------
-- Blizzard_warwithin.lua
--
-- Blizzard frame integration for the Retail branch for The War Within
-------------------------------------------------------------------------]]--

---@class addon
local addon = select(2, ...)
local L = addon.L

-- Only load if this is Retail AND Dragonflight
if not (addon:ProjectIsRetail() and addon:ProjectIsWarWithin()) then
    return
end

function addon:IntegrateBlizzardFrames()
    self:DragonflightPlayerFrame()
    self:DragonflightTargetFrame()
    self:DragonflightFocusFrame()
    self:DragonflightPartyFrame()

    self:DragonflightCompactRaidFrames()
    self:DragonflightBossFrames()
end

function addon:DragonflightPlayerFrame()
    if addon.settings.blizzframes.PlayerFrame then
        self:RegisterBlizzardFrame("PlayerFrame")
    end

    if addon.settings.blizzframes.PetFrame then
        self:RegisterBlizzardFrame("PetFrame")
    end
end

function addon:DragonflightTargetFrame()
    if addon.settings.blizzframes.TargetFrame then
        self:RegisterBlizzardFrame("TargetFrame")
    end

    if addon.settings.blizzframes.TargetFrameToT then
        self:RegisterBlizzardFrame("TargetFrameToT")
    end
end

function addon:DragonflightFocusFrame()
    if addon.settings.blizzframes.FocusFrame then
        self:RegisterBlizzardFrame("FocusFrame")
    end

    if addon.settings.blizzframes.FocusFrameToT then
        self:RegisterBlizzardFrame("FocusFrameToT")
    end
end

function addon:DragonflightPartyFrame()
    if not addon.settings.blizzframes.party then
        return
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")

    local eventHandler = function(self, event, ...)
        local partyframe = _G["PartyFrame"]
        if partyframe then
            for memberFrame in partyframe.PartyMemberFramePool:EnumerateActive() do
                addon:RegisterBlizzardFrame(memberFrame)
                addon:RegisterBlizzardFrame(memberFrame.PetFrame)
            end

            -- -- This is an ipairs for some reason
            -- for _, memberFrame in partyframe.PartyMemberFramePool:EnumerateInactive() do
            --     addon:RegisterBlizzardFrame(memberFrame)
            -- end
        end
    end

    frame:SetScript("OnEvent", eventHandler)

    -- Trigger the event handler now
    eventHandler()
end

local function enableCompactUnitFrame(name)
    addon:RegisterBlizzardFrame(name)

    for i = 1, 3 do
        addon:RegisterBlizzardFrame(name .. "Buff" .. i)
        addon:RegisterBlizzardFrame(name .. "Debuff" .. i)
        addon:RegisterBlizzardFrame(name .. "DispelDebuff" .. i)
    end

    addon:RegisterBlizzardFrame(name .. "CenterStatusIcon")
end

function addon:DragonflightCompactRaidFrames()
    if not addon.settings.blizzframes.compactraid then
        return
    end

    -- If the player frame is created, register it
    if _G["CompactPartyFrameMember1"] then
        enableCompactUnitFrame("CompactPartyFrameMember1")
    end

    hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame, ...)
        addon:RegisterBlizzardFrame(frame)
    end)
end

function addon:DragonflightBossFrames()
    if not addon.settings.blizzframes.boss then
        return
    end

    local frames = {
        "Boss1TargetFrame",
        "Boss2TargetFrame",
        "Boss3TargetFrame",
        "Boss4TargetFrame",
        "Boss5TargetFrame",
    }
    for idx, frame in ipairs(frames) do
        addon:RegisterBlizzardFrame(frame)
    end
end
