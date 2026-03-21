-- Alerts.lua – one-time version alerts shown at startup

local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Alerts = MCE:NewModule("Alerts")

local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or C.Addon.VersionFallback

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

    local alertData = C.Alerts.VersionAlerts[addonVersion]
    if not alertData then return end

    if db.global.versionAlertsShown[addonVersion] then
        return
    end

    db.global.versionAlertsShown[addonVersion] = true
    self:PrintAlert("|cff93c5fdv" .. tostring(addonVersion) .. "|r", alertData.updateLine)
end
