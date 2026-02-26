local LibEvent = LibStub:GetLibrary("LibEvent.7000")

--local function FindLine(tooltip, keyword)
--    local line, text
--    for i = 2, tooltip:NumLines() do
--        line = _G[tooltip:GetName() .. "TextLeft" .. i]
--        text = line:GetText() or ""
--        local check, found = pcall(string.find, text, keyword)
--        if (check and found) then
--            return line, i, _G[tooltip:GetName() .. "TextRight" .. i]
--        end
--    end
--end

function FindLine(tooltip, keyword)
    local line, text
    for i = 2, tooltip:NumLines() do
        line = _G[tooltip:GetName() .. "TextLeft" .. i]
        local check, value = pcall(function() return line and line:GetText() end)
        if (check) then
            local checkType, isStr = pcall(function() return type(value) == "string" end)
            if (checkType and isStr) then
                local checkNotEmpty, notEmpty = pcall(function() return value ~= "" end)
                if (checkNotEmpty and notEmpty) then
                    local checkFind, found = pcall(function() return strfind(value, keyword) end)
                    if (checkFind and found) then
                        return line, i, _G[tooltip:GetName() .. "TextRight" .. i]
                    end
                end
            end
        end
    end
end

local LevelLabel = STAT_AVERAGE_ITEM_LEVEL .. ": "
local SpecLabel = SPECIALIZATION .. ": "

local function SafeUnitIsPlayer(unit)
    if (not unit) then return false end
    local ok, value = pcall(UnitIsPlayer, unit)
    if (ok) then return value end
    return false
end

local function SafeUnitIsUnit(a, b)
    if (not a or not b) then return false end
    local ok, value = pcall(UnitIsUnit, a, b)
    if (ok) then return value end
    return true
end

local function SafeCanInspect(unit)
    if (not unit) then return false end
    local ok, value = pcall(CanInspect, unit)
    if (ok) then return value end
    return true
end

local function SafeUnitIsVisible(unit)
    if (not unit) then return false end
    local ok, value = pcall(UnitIsVisible, unit)
    if (ok) then return value end
    return true
end

local function AppendToGameTooltip(guid, ilevel, specIcon, spec, weaponLevel, isArtifact)
    spec = spec or ""
    specIcon = specIcon or ""
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB.EnableMouseSpecialization) then spec = "" end
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB.EnableSpecializationIcon) then specIcon = "" end
    local check, _, unit = pcall(GameTooltip.GetUnit, GameTooltip)
    if (not check or not unit) then return end
    local ilvlLine, _, lineRight = FindLine(GameTooltip, LevelLabel)
    local ilvlText = format("%s|cffffffff%s|r", LevelLabel, ilevel)
    local specText = format("|T%s:16:16:0:0:32:32:2:30:2:30|t |cffb8b8b8%s|r", specIcon, spec)
    if (weaponLevel and weaponLevel > 0 and TinyInspectReforgedDB.EnableMouseWeaponLevel) then
        ilvlText = ilvlText .. format(" (%s)", weaponLevel)
    end
    if (ilvlLine) then
        ilvlLine:SetText(ilvlText)
        lineRight:SetText(specText)
    else
        GameTooltip:AddDoubleLine(ilvlText, specText)
    end
    GameTooltip:Show()
end

if (GameTooltip.ProcessInfo) then
    hooksecurefunc(GameTooltip, "ProcessInfo", function(self, info)
        if (not info or not info.tooltipData) then return end
        local flag = info.tooltipData.type
        local guid = info.tooltipData.guid
        if (flag ~= 2) then return end

        local check, _, unit = pcall(self.GetUnit, self)
        if (not check or not unit) then return end
        if (TinyInspectReforgedDB and (TinyInspectReforgedDB.EnableMouseItemLevel or TinyInspectReforgedDB.EnableMouseSpecialization)) then
            if (not SafeUnitIsPlayer(unit)) then return end
            local data = GetInspectInfo(unit, 3)
            if (data and data.ilevel > 0 and SafeUnitIsUnit(data.unit, unit)) then
                return AppendToGameTooltip(guid, floor(data.ilevel), data.specIcon, data.spec, data.weaponLevel, data.isArtifact)
            end
            if (not SafeCanInspect(unit) or not SafeUnitIsVisible(unit)) then return end
            local inspecting = GetInspecting()
            if (inspecting) then
                if (inspecting.unit and not SafeUnitIsUnit(inspecting.unit, unit)) then
                    return AppendToGameTooltip(nil, "n/a")
                else
                    return AppendToGameTooltip(nil, "...")
                end
            end
            ClearInspectPlayer()
            NotifyInspect(unit)
            AppendToGameTooltip(nil, "...")
        end
    end)
end

LibEvent:attachTrigger("UNIT_INSPECT_READY", function(self, data)
    if (TinyInspectReforgedDB and not TinyInspectReforgedDB.EnableMouseItemLevel) then return end
    local check, isMouseover = pcall(function()
        return data.guid == UnitGUID("mouseover")
    end)
    if (check and isMouseOver) then
        AppendToGameTooltip(data.guid, floor(data.ilevel), data.spec, data.weaponLevel, data.isArtifact)
    end
end)
