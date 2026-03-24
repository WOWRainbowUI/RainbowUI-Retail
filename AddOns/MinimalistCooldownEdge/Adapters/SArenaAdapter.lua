-- Adapters/SArenaAdapter.lua - sArena_Reloaded cooldown discovery

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("SArenaAdapter")

local ipairs, type = ipairs, type
local strmatch = string.match

local CATEGORY = C.Categories
local SARENA_FRAME_TYPE = C.SArenaFrameTypes
local SA = C.Adapter.SArena

local Registry

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.SArena, self)
end

local function IsSArenaArenaFrame(frame)
    if not frame or not frame.GetName then return false end
    local name = frame:GetName()
    return type(name) == "string" and strmatch(name, "^sArenaEnemyFrame%d+$") ~= nil
end

local function GetSArenaArenaFrame(frame)
    local current = frame
    for _ = 1, SA.MaxAncestorDepth do
        if not current then break end
        if IsSArenaArenaFrame(current) then return current end
        current = current.GetParent and current:GetParent() or nil
    end
    return nil
end

local function ResolveSArenaFrameType(cooldown)
    if not MCE:IsSArenaAvailable() or not cooldown or MCE:IsForbidden(cooldown) then return nil end

    local owner = cooldown.GetParent and cooldown:GetParent() or nil
    if not owner or MCE:IsForbidden(owner) then return nil end

    local arenaFrame = GetSArenaArenaFrame(owner)
    if not arenaFrame then return nil end

    if owner == arenaFrame.ClassIcon then
        return SARENA_FRAME_TYPE.ClassIcon
    end

    if owner == arenaFrame.Trinket then
        return SARENA_FRAME_TYPE.Trinket
    end

    if owner == arenaFrame.Racial then
        return SARENA_FRAME_TYPE.Racial
    end

    if owner.DRTextFrame and owner.Cooldown == cooldown then
        return SARENA_FRAME_TYPE.DR
    end

    return nil
end

local function RegisterOwnedCooldown(owner, subtype)
    local cooldown = owner and owner.Cooldown
    if cooldown and not MCE:IsForbidden(cooldown) then
        Registry:Register(cooldown, CATEGORY.SArena, subtype)
    end
end

local function ScanDRFrames(arenaFrame)
    if not arenaFrame or MCE:IsForbidden(arenaFrame) then return end

    if type(arenaFrame.drFrames) == "table" then
        for i = 1, #arenaFrame.drFrames do
            RegisterOwnedCooldown(arenaFrame.drFrames[i], SARENA_FRAME_TYPE.DR)
        end
        return
    end

    if arenaFrame.GetChildren then
        local children = { arenaFrame:GetChildren() }
        for i = 1, #children do
            local child = children[i]
            if child and not MCE:IsForbidden(child)
               and child.DRTextFrame and child.Cooldown then
                RegisterOwnedCooldown(child, SARENA_FRAME_TYPE.DR)
            end
        end
    end
end

local function GetArenaFrame(index)
    return _G["sArenaEnemyFrame" .. index]
        or (_G.sArena and _G.sArena["arena" .. index])
end

function Adapter:Rebuild()
    if not MCE:IsSArenaAvailable() then return end

    for i = 1, SA.MaxArenaOpponents do
        local arenaFrame = GetArenaFrame(i)
        if arenaFrame and not MCE:IsForbidden(arenaFrame) then
            RegisterOwnedCooldown(arenaFrame.ClassIcon, SARENA_FRAME_TYPE.ClassIcon)
            RegisterOwnedCooldown(arenaFrame.Trinket, SARENA_FRAME_TYPE.Trinket)
            RegisterOwnedCooldown(arenaFrame.Racial, SARENA_FRAME_TYPE.Racial)
            ScanDRFrames(arenaFrame)
        end
    end
end

function Adapter:TryClaim(cooldown)
    local frameType = ResolveSArenaFrameType(cooldown)
    if frameType then
        return CATEGORY.SArena, frameType
    end
    return nil
end
