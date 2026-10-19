-- Shared contract, copied into each addon so every repository stays independent.
local addonName, ns = ...
local Client = {}
ns.ClientCompat = Client

Client.IsForever = WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
Client.IsRetail = WOW_PROJECT_MAINLINE ~= nil and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
Client.HasSpecializations = not Client.IsForever and type(GetSpecialization) == "function"

function Client.CanRead(value)
    return not issecretvalue or not issecretvalue(value)
end

function Client.RegisterEvent(frame, event, ...)
    if Client.IsForever and C_EventUtils and C_EventUtils.IsEventValid
        and not C_EventUtils.IsEventValid(event) then
        return false
    end
    frame:RegisterEvent(event, ...)
    return true
end

-- Report the actual client, not the interface declared in the addon TOC.
function Client.GetDiagnostics()
    local version, build, date, interface = GetBuildInfo()
    return {
        version = version, build = build, date = date, interface = interface,
        project = WOW_PROJECT_ID,
        edition = Client.IsForever and "Forever" or (Client.IsRetail and "Retail" or "Classic"),
    }
end

if SlashCmdList then
    local key = addonName:upper():gsub("[^A-Z0-9]", "") .. "CLIENT"
    _G["SLASH_" .. key .. "1"] = "/" .. addonName:lower():gsub("[^a-z0-9]", "") .. "client"
    SlashCmdList[key] = function()
        local info = Client.GetDiagnostics()
        print(addonName .. ": " .. info.edition .. " " .. tostring(info.version)
            .. ", build " .. tostring(info.build) .. ", interface " .. tostring(info.interface)
            .. ", project " .. tostring(info.project))
        if C_AddOns and C_AddOns.GetAddOnMetadata then
            print("Addon version: " .. tostring(C_AddOns.GetAddOnMetadata(addonName, "Version")))
            local deps = C_AddOns.GetAddOnMetadata(addonName, "Dependencies")
                or C_AddOns.GetAddOnMetadata(addonName, "RequiredDeps") or ""
            for dependency in deps:gmatch("[^,%s]+") do
                print(dependency .. ": " .. tostring(C_AddOns.GetAddOnMetadata(dependency, "Version")))
            end
        end
    end
end
