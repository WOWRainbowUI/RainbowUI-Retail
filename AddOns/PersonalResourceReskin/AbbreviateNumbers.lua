-- AbbreviateNumbers: Blizzard-style number abbreviation
-- Copied from PlayerHealthText.lua/PlayerPowerText.lua for reuse

local function AbbreviateNumbers(val, abbrevData)
    if type(val) ~= "number" then return tostring(val) end
    local breakpoints = abbrevData and abbrevData.breakpointData or {}
    for i = 1, #breakpoints do
        local bp = breakpoints[i]
        if math.abs(val) >= bp.breakpoint then
            local significand = math.floor(val / bp.significandDivisor)
            local fraction = math.floor((math.abs(val) % bp.significandDivisor) / bp.fractionDivisor)
            if fraction > 0 then
                return string.format("%d.%d%s", significand, fraction, bp.abbreviation)
            else
                return string.format("%d%s", significand, bp.abbreviation)
            end
        end
    end
    return tostring(val)
end

return AbbreviateNumbers
