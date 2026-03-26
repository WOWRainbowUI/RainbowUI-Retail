--[[ 
    This file contains version-aware wrappers for Blizzard API functions and UI behaviors.
    Its purpose is to abstract differences between WoW Retail, Classic, and Wrath clients,
    allowing the addon to call unified functions regardless of game version.
    We will update this file when Blizzard changes or deprecates core APIs across expansions.
    
    We are also adding style wrappers for icons, buttons, etc. to this file
]]
local addonName, ns = ...
local CCS = ns.CCS

-- Example: IsAddOnLoaded wrapper
function CCS.IsAddOnLoaded(addonName)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(addonName)
    elseif IsAddOnLoaded then
        return IsAddOnLoaded(addonName)
    end
    return false
end

-- Example: LoadAddOn wrapper
function CCS.LoadAddOn(addonName)
    if AddOnUtil and AddOnUtil.LoadAddOn then
        return AddOnUtil.LoadAddOn(addonName)
    elseif LoadAddOn then
        return LoadAddOn(addonName)
    end
    return false, "LoadAddOn not available"
end

-- Example: CreateColor wrapper
function CCS.CreateColor(r, g, b, a)
    if CreateColor then
        return CreateColor(r, g, b, a)
    else
        return { r = r, g = g, b = b, a = a }
    end
end
