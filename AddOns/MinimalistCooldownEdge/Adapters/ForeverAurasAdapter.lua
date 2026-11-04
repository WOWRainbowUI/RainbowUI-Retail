-- ForeverAuras 1.1.0 retains the public WeakAuras API and WeakAurasCooldown
-- names. Claim only icon regions confirmed by GetRegion, including clones.
-- Reference: https://www.curseforge.com/wow/addons/foreverauras/files/9355908
local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("ForeverAurasAdapter")
local Registry

local function PublicField(object, key)
    local value = MCE:SafeTableGet(object, key)
    if not addon.IsSecretValue(value) and addon.CanAccessAllValues(value) then return value end
end

local function GetAPI()
    if not MCE:IsForeverAurasAvailable() then return nil end
    local api = _G.WeakAuras
    if type(api) == "table" and type(api.GetRegion) == "function" then
        return api
    end
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(C.Categories.ForeverAuras, self)
end

function Adapter:TryClaim(cooldown)
    local api = GetAPI()
    if not api or not MCE:CanUseFrameAsTableKey(cooldown) then return nil end
    local name = MCE:GetFrameName(cooldown)
    if addon.IsSecretValue(name) or type(name) ~= "string"
        or name:find("WeakAurasCooldown", 1, true) ~= 1 then return nil end
    local region = addon.GetParentSafe(cooldown)
    if PublicField(region, "regionType") ~= "icon"
        or PublicField(region, "cooldown") ~= cooldown then return nil end
    local id = PublicField(region, "id")
    local cloneId = PublicField(region, "cloneId")
    if type(id) ~= "string" or (cloneId ~= nil and type(cloneId) ~= "string") then return nil end
    local ok, owned = pcall(api.GetRegion, id, cloneId)
    if ok and not addon.IsSecretValue(owned) and owned == region then return C.Categories.ForeverAuras end
end

local function RegisterRegion(api, id, cloneId)
    local ok, region = pcall(api.GetRegion, id, cloneId)
    if not ok then return end
    local cooldown = PublicField(region, "cooldown")
    if Adapter:TryClaim(cooldown) then
        Registry:Register(cooldown, C.Categories.ForeverAuras)
    end
end

function Adapter:Rebuild()
    local api = GetAPI()
    local saved = _G.ForeverAurasSaved
    local displays = type(saved) == "table" and saved.displays
    if not api or type(displays) ~= "table" then return end
    -- Enumerate this provider's displays and active clone IDs only. Never
    -- inspect a live timer value, scan global frames, or poll each frame.
    for id in pairs(displays) do
        if not addon.IsSecretValue(id) and type(id) == "string" then
            RegisterRegion(api, id)
            if type(api.GetActiveStates) == "function" then
                local ok, states = pcall(api.GetActiveStates, id)
                if ok and type(states) == "table" and not addon.IsSecretValue(states) then
                    for cloneId in pairs(states) do
                        if not addon.IsSecretValue(cloneId) and type(cloneId) == "string" and cloneId ~= "" then
                            RegisterRegion(api, id, cloneId)
                        end
                    end
                end
            end
        end
    end
end

function Adapter:GetTimerOption(cooldown, option)
    if option == "hideCountdownNumbers" then
        -- This cache is maintained by ForeverAuras' own setter, including its
        -- duration visibility policy. Without it (e.g. OmniCC), leave ownership
        -- with the provider rather than enabling duplicate numbers.
        local hidden = PublicField(cooldown, "faHideNumbers")
        if type(hidden) == "boolean" then return hidden end
    end
    -- ForeverAuras replaces SetDrawSwipe and controls the swipe itself.
    return nil
end
