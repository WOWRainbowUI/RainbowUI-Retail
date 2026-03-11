-- Alerts.lua – one-time version alerts shown at startup

local addonName = ...
local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Alerts = MCE:NewModule("Alerts")

local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"

local VERSION_ALERTS = {
    ["3.2.0"] = {
        updateLine = "|cff7dd3fcUpdate:|r CooldownManager viewers moved from |cffc084fcOthers|r to their own category - style them with |cfffacc15/minice|r.",
    },
}

function Alerts:PrintAlert(versionLine, updateLine)
    if versionLine and versionLine ~= "" then
        MCE:Print(versionLine)
    end

    if updateLine and updateLine ~= "" then
        MCE:Print(updateLine)
    end
end

function Alerts:OnEnable()
    local db = MCE.db
    if not db then return end

    db.global = db.global or {}
    db.global.versionAlertsShown = db.global.versionAlertsShown or {}

    local alertData = VERSION_ALERTS[addonVersion]
    if not alertData then return end

    if db.global.versionAlertsShown[addonVersion] then
        return
    end

    db.global.versionAlertsShown[addonVersion] = true
    self:PrintAlert("|cff93c5fdv" .. tostring(addonVersion) .. "|r", alertData.updateLine)
end
