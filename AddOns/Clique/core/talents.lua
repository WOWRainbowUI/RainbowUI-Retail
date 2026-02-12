--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2026 - James N. Whitehead II
-------------------------------------------------------------------]]--

--- @class CliqueAddon
local addon = select(2, ...)
local L = addon.L

function addon:GameVersionHasTalentSpecs()
    if GetSpecialization or C_SpecializationInfo then
        return true
    elseif GetActiveTalentGroup then
        return true
    end

    return false
end

-- Returns the active talent spec, encapsulating the differences between
-- Retail and Wrath.
function addon:GetActiveTalentSpec()
    if GetSpecialization then
        return GetSpecialization()
    elseif C_SpecializationInfo then
        return C_SpecializationInfo.GetSpecialization()
    elseif GetActiveTalentGroup then
        return GetActiveTalentGroup()
    end
end

-- Returns an acceptable string for the given talent spec, covering the
-- differences between Retail and Wrath
function addon:GetTalentSpecName(idx)
    if GetSpecializationInfo then
        local _, specName = GetSpecializationInfo(idx)
        return specName
    elseif C_SpecializationInfo then
        local _, specName = C_SpecializationInfo.GetSpecializationInfo(idx)
        return specName
    elseif GetActiveTalentGroup then
        if idx == 1 then
            return L["Primary"]
        elseif idx == 2 then
            return L["Secondary"]
        end
    end
end

function addon:GetNumTalentSpecs()
    if GetNumSpecializations then
        return GetNumSpecializations()
    elseif GetActiveTalentGroup then
        return 2
    else
        return 0
    end
end

-- Handle automatic profile changes based on spec
function addon:TalentGroupChanged()
    local currentProfile = self.db:GetCurrentProfile()
    local newProfile

    local currentSpec = self:GetActiveTalentSpec()
    if self.settings.specswap and currentSpec then
        local settingsKey = string.format("spec%d_profileKey", currentSpec)
        if self.settings[settingsKey] then
            newProfile = self.settings[settingsKey]
        end

        if newProfile ~= currentProfile and type(newProfile) == "string" then
            self:Printf(L["Switching to profile: '%s'"]:format(newProfile))
            self.db:SetProfile(newProfile)
        end
    end

    self:FireMessage("BINDINGS_CHANGED")
end

