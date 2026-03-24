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

local strfind, ipairs = string.find, ipairs

local CLASSIFIER_CONSTANTS = C.Classifier
local BLACKLIST_NAME_CONTAINS = CLASSIFIER_CONSTANTS.BlacklistNameContains
local BLACKLIST_EXACT_PAIRS   = CLASSIFIER_CONSTANTS.BlacklistExactPairs

-- =========================================================================
-- BLACKLIST
-- =========================================================================

function Classifier:IsBlacklisted(frame, knownFrameName)
    if not frame then return false end

    local frameName = knownFrameName or (frame.GetName and frame:GetName()) or "AnonymousFrame"
    local parent = frame.GetParent and frame:GetParent() or nil
    local parentName = parent and parent.GetName and parent:GetName() or "NoParent"

    local parentBlacklist = BLACKLIST_EXACT_PAIRS[parentName]
    if parentBlacklist and parentBlacklist[frameName] then return true end

    for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
        if strfind(frameName, key, 1, true) or strfind(parentName, key, 1, true) then
            return true
        end
    end
    return false
end
