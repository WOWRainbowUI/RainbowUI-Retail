-- Classifier.lua – Blacklist filter (AceModule)
--
-- Provides IsBlacklisted, a lightweight check used by Styler and HookBridge
-- to skip known-irrelevant frames (character equipment slots, PVP queue
-- frames, etc.).  All primary classification is adapter-driven through
-- TargetRegistry:TryClaim.  There is no fallback classification path.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Classifier = MCE:NewModule("Classifier")

local pcall = pcall
local strfind, ipairs = string.find, ipairs
local issecretvalue = issecretvalue or function() return false end
local canaccessallvalues = canaccessallvalues

local CLASSIFIER_CONSTANTS = C.Classifier
local BLACKLIST_NAME_CONTAINS = CLASSIFIER_CONSTANTS.BlacklistNameContains
local BLACKLIST_PARENT_NAMES = CLASSIFIER_CONSTANTS.BlacklistParentNames
local weakMeta = addon.weakMeta
local frameState = addon.frameState

local blacklistCache = setmetatable({}, weakMeta)
local blacklistParentNameLookup = {}

for _, parentName in ipairs(BLACKLIST_PARENT_NAMES) do
    blacklistParentNameLookup[parentName] = true
end

-- =========================================================================
-- BLACKLIST
-- =========================================================================

local function IsSecretValue(value)
    if not issecretvalue then return false end
    local ok, result = pcall(issecretvalue, value)
    return ok and result or false
end

local function CanAccessAllValues(...)
    if not canaccessallvalues then return true end
    local ok, result = pcall(canaccessallvalues, ...)
    return ok and result or false
end

function Classifier:IsBlacklisted(frame, knownFrameName)
    if not frame then return false end
    if IsSecretValue(frame) or not CanAccessAllValues(frame) or MCE:IsForbidden(frame) then
        return true
    end

    local state = frameState[frame]
    if state and state.allowBlacklisted then
        blacklistCache[frame] = false
        return false
    end
    if blacklistCache[frame] ~= nil then return blacklistCache[frame] end

    local currentObj = frame
    local isFirstObject = true

    while currentObj do
        if IsSecretValue(currentObj) or not CanAccessAllValues(currentObj) or MCE:IsForbidden(currentObj) then
            blacklistCache[frame] = true
            return true
        end

        local name = currentObj.GetName and currentObj:GetName() or ""

        if isFirstObject and knownFrameName then
            name = knownFrameName
        end

        for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
            if name ~= "" and strfind(name, key, 1, true) then
                blacklistCache[frame] = true
                return true
            end
        end

        if name ~= "" and blacklistParentNameLookup[name] then
            blacklistCache[frame] = true
            return true
        end

        currentObj = currentObj.GetParent and currentObj:GetParent() or nil
        isFirstObject = false
    end

    blacklistCache[frame] = false
    return false
end
