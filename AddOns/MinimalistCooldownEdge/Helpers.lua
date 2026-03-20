-- Helpers.lua – shared utility helpers used across modules

local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")

local pcall, type = pcall, type

local Helpers = {}

local function checkForbidden(frame)
    return frame:IsForbidden()
end

function Helpers.IsForbidden(frame)
    if not frame then
        return true
    end

    local ok, value = pcall(checkForbidden, frame)
    return not ok or value
end

function Helpers.NormalizeFontStyle(style)
    if not style or style == "NONE" then
        return ""
    end
    return style
end

function Helpers.ResolveFontPath(fontPath)
    if fontPath == "GAMEDEFAULT" then
        return GameFontNormal:GetFont()
    end
    return fontPath
end

function Helpers.IsMiniCCAvailable()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("MiniCC") or false
end

function Helpers.ExtractUnitToken(unit)
    if type(unit) == "string" then
        return unit ~= "" and unit or nil
    end

    if type(unit) ~= "table" then
        return nil
    end

    local token = unit.unitid
        or unit.unitID
        or unit.unitToken
        or unit.displayedUnit
        or unit.memberUnit
        or unit.unit

    if type(token) == "string" and token ~= "" then
        return token
    end

    return nil
end

function Helpers.GetFrameUnit(frame)
    if not frame then
        return nil
    end

    local unit = Helpers.ExtractUnitToken(frame.unit)
        or Helpers.ExtractUnitToken(frame.unitid)
        or Helpers.ExtractUnitToken(frame.unitID)
        or Helpers.ExtractUnitToken(frame.unitToken)
        or Helpers.ExtractUnitToken(frame.displayedUnit)
        or Helpers.ExtractUnitToken(frame.memberUnit)
        or Helpers.ExtractUnitToken(frame.auraDataUnit)
    if unit then
        return unit
    end

    if frame.GetAttribute then
        local ok, attribute = pcall(frame.GetAttribute, frame, "unit")
        unit = ok and Helpers.ExtractUnitToken(attribute) or nil
        if unit then
            return unit
        end
    end

    return nil
end

function Helpers.GetFrameUnitToken(frame)
    return Helpers.GetFrameUnit(frame)
end

function Helpers.GetFrameAuraInstanceID(frame)
    if not frame then
        return nil
    end

    return frame.auraInstanceID
        or frame.auraDataInstanceID
        or frame.auraInstanceId
        or frame.auraDataInstanceId
end

function Helpers.GetDurationTextColorsConfig()
    local profile = MCE.db and MCE.db.profile
    if not profile then
        return nil
    end

    profile.durationTextColors = MCE.EnsureDurationTextColorConfig(profile.durationTextColors)
    return profile.durationTextColors
end

MCE.Helpers = Helpers

function MCE:IsForbidden(frame)
    return Helpers.IsForbidden(frame)
end

MCE.NormalizeFontStyle = Helpers.NormalizeFontStyle
MCE.ResolveFontPath = Helpers.ResolveFontPath

function MCE:IsMiniCCAvailable()
    return Helpers.IsMiniCCAvailable()
end
