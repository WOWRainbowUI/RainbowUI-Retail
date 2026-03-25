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

local blacklistCache = {}

-- =========================================================================
-- BLACKLIST
-- =========================================================================

function Classifier:IsBlacklisted(frame, knownFrameName)
    if not frame then return false end
    if blacklistCache[frame] ~= nil then return blacklistCache[frame] end

    local currentObj = frame
    local frameName = knownFrameName or (frame.GetName and frame:GetName()) or ""
    local parent = frame.GetParent and frame:GetParent() or nil
    local parentName = parent and parent.GetName and parent:GetName() or ""

    local parentBlacklist = BLACKLIST_EXACT_PAIRS[parentName]
    if parentBlacklist and parentBlacklist[frameName ~= "" and frameName or "AnonymousFrame"] then 
        blacklistCache[frame] = true
        return true 
    end

    -- Check up to 4 levels of parents
    for i = 1, 4 do
        if not currentObj then break end
        
        local nm = currentObj.GetName and currentObj:GetName() or ""
        
        if i == 1 and knownFrameName then 
            nm = knownFrameName 
        end

        for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
            if (nm ~= "" and strfind(nm, key, 1, true)) then
                blacklistCache[frame] = true
                return true
            end
        end
        currentObj = currentObj.GetParent and currentObj:GetParent()
    end

    blacklistCache[frame] = false
    return false
end
