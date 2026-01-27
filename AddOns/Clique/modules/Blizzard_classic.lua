--[[-------------------------------------------------------------------------
-- Blizzard_classic.lua
--
-- This file contains the definitions of the blizzard frame integration
-- options. These settings will not apply until the user interface is
-- reloaded.
--
-- Events registered:
--   * ADDON_LOADED - To watch for loading of the ArenaUI
-------------------------------------------------------------------------]]--

---@class addon
local addon = select(2, ...)
local L = addon.L

-- Only load if this is Classic
if not addon:ProjectIsClassic() then
    return
end

--addon:Printf("Loading Blizzard_classic integration")

function addon:IntegrateBlizzardFrames()
    addon:Classic_SelfFrames()

    addon:Classic_BlizzPartyFrames()
    addon:Classic_BlizzCompactUnitFrames()
    addon:Classic_BlizzBossFrames()
end


function addon:Classic_BlizzCompactUnitFrames()
    if not addon.settings.blizzframes.compactraid then
        return
    end

    hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame, ...)
        for i = 1, 3 do
            local buffFrame = frame.BuffFrame

            if buffFrame then
                addon:RegisterBlizzardFrame(buffFrame)
            end
        end

        addon:RegisterBlizzardFrame(frame)
    end)
end

function addon:Classic_SelfFrames()
    local frames = {
        "PlayerFrame",
        "PetFrame",
        "TargetFrame",
        "TargetFrameToT",
    }

    for idx, frame in ipairs(frames) do
        if addon.settings.blizzframes[frame] then
            addon:RegisterBlizzardFrame(frame)
        end
    end
end

function addon:Classic_BlizzPartyFrames()
    if not addon.settings.blizzframes.party then
        return
    end

    local frames = {
        "PartyMemberFrame1",
        "PartyMemberFrame2",
        "PartyMemberFrame3",
        "PartyMemberFrame4",
        --"PartyMemberFrame5",
        "PartyMemberFrame1PetFrame",
        "PartyMemberFrame2PetFrame",
        "PartyMemberFrame3PetFrame",
        "PartyMemberFrame4PetFrame",
        --"PartyMemberFrame5PetFrame",
    }
    for idx, frame in ipairs(frames) do
        addon:RegisterBlizzardFrame(frame)
    end
end


function addon:Classic_BlizzBossFrames()
    if not addon.settings.blizzframes.boss then
        return
    end

    local frames = {
        "Boss1TargetFrame",
        "Boss2TargetFrame",
        "Boss3TargetFrame",
        "Boss4TargetFrame",
    }
    for idx, frame in ipairs(frames) do
        addon:RegisterBlizzardFrame(frame)
    end
end
