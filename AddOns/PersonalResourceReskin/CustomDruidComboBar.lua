
function ShouldShowComboPointBar()
    local _, class = UnitClass("player")
    if class ~= "DRUID" then return false end
    local form = GetShapeshiftForm and GetShapeshiftForm() or 0
    return form == 2 -- Cat Form
end

function UpdateDruidComboBarEnabled()
    local mounted = IsMounted and IsMounted() or (IsPlayerMounted and IsPlayerMounted())
    if CustomDruidComboBarDB.hideWhenMounted and mounted then
        comboPointBar:Hide()
        return
    end
    local showBar = ShouldShowComboPointBar() and CustomDruidComboBarDB.enabled
    if showBar then
        comboPointBar:Show()
    else
        comboPointBar:Hide()
    end
    -- Hide Blizzard's prdClassFrame for Druids when custom bar is enabled
    if CustomDruidComboBarDB.enabled then
        if _G.prdClassFrame then
            _G.prdClassFrame:Hide()
            _G.prdClassFrame:SetAlpha(0)
        end
    else
        if _G.prdClassFrame then
            _G.prdClassFrame:Show()
            _G.prdClassFrame:SetAlpha(1)
        end
    end
end

local COMBO_POINT_TYPE = Enum and Enum.PowerType and Enum.PowerType.ComboPoints or 4 -- fallback to 4 if Enum not loaded

local chargedComboPoints = {}

-- Early exit if not a Druid
local _, playerClass = UnitClass("player")
if playerClass ~= "DRUID" then return end

local function dprint(...)
    if CustomDruidComboBarDB and CustomDruidComboBarDB.debug then
        print("[CDCB]", ...)
    end
end

local function SafeUnpackColor(color, default)
    if type(color) ~= "table" then
        return unpack(default or {1,1,1,1})
    end
    if color.r then
        return tonumber(color.r) or (default and default[1]) or 1,
               tonumber(color.g) or (default and default[2]) or 1,
               tonumber(color.b) or (default and default[3]) or 1,
               tonumber(color.a) or (default and default[4]) or 1
    end
    return tonumber(color[1]) or (default and default[1]) or 1,
           tonumber(color[2]) or (default and default[2]) or 1,
           tonumber(color[3]) or (default and default[3]) or 1,
           tonumber(color[4]) or (default and default[4]) or 1
end

CustomDruidComboBarDB = CustomDruidComboBarDB or {
    x = 0, y = -120, comboPointWidth = 24, comboPointHeight = 24, locked = false,
    totalWidth = nil,
    comboPointBgColor = {0, 0, 0, 0.5},
    chargedComboPointBgColor = {0.1, 0.3, 0.5, 0.7},
    comboPointFillColors = {
        {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1},
        {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1},
    },
    chargedComboPointColor = {0.2, 0.6, 1, 1},
    gradientColoringEnabled = false,
    gradientColorStart = {1, 0, 0, 1},
    gradientColorEnd = {1, 1, 0, 1},
    anchorToPRD = false,
    anchorPosition = "BELOW",
    anchorOffset = 10,
    anchorTarget = "HEALTH", -- HEALTH or POWER
    debug = false,
    enabled = true,
    hideWhenMounted = false,
}

local function GetPRDHealthBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        return prd.HealthBarsContainer.healthBar
    end
    return _G.PersonalResourceDisplayHealthBar
end

local function GetPRDPowerBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.PowerBarsContainer and prd.PowerBarsContainer.powerBar then
        return prd.PowerBarsContainer.powerBar
    end
    if prd and prd.PowerBar then
        return prd.PowerBar
    end
    return _G.PersonalResourceDisplayPowerBar
end

local function GetPRDAnchorFrame()
    if not CustomDruidComboBarDB.anchorToPRD then return nil end
    local target = CustomDruidComboBarDB.anchorTarget or "HEALTH"
    local f = (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
    dprint("GetPRDAnchorFrame target=", target, "found=", f and "yes" or "no")
    return f
end

comboPointBar = CreateFrame("Frame", "CustomDruidComboBar", UIParent)
comboPointBar.comboPoints = {}

local function GetMaxComboPoints()
    return UnitPowerMax("player", COMBO_POINT_TYPE) or 5
end

local function GetComboPointWidth(numPoints)
    if numPoints == 0 then numPoints = 5 end
    if CustomDruidComboBarDB.totalWidth and CustomDruidComboBarDB.totalWidth > 0 then
        return CustomDruidComboBarDB.totalWidth / numPoints
    end
    return CustomDruidComboBarDB.comboPointWidth or 24
end

local function CreateComboPoints()
    for _, cp in ipairs(comboPointBar.comboPoints) do
        cp:Hide()
        cp:SetParent(nil)
    end
    comboPointBar.comboPoints = {}

    local numPoints = GetMaxComboPoints()
    for i = 1, numPoints do
        if chargedComboPoints[i] == nil then chargedComboPoints[i] = false end
    end
    local width = GetComboPointWidth(numPoints)
    local height = CustomDruidComboBarDB.comboPointHeight or 24

    for i = 1, numPoints do
        local comboPoint = CreateFrame("Frame", nil, comboPointBar)
        comboPoint:SetSize(width, height)
        comboPoint:SetPoint("LEFT", comboPointBar, "LEFT", (i-1)*width, 0)
        comboPoint:EnableMouse(false)

        comboPoint.bg = comboPoint:CreateTexture(nil, "BACKGROUND")
        comboPoint.bg:SetAllPoints()

        comboPoint.fill = comboPoint:CreateTexture(nil, "ARTWORK")
        comboPoint.fill:SetPoint("BOTTOMLEFT", comboPoint, "BOTTOMLEFT")
        comboPoint.fill:SetPoint("BOTTOMRIGHT", comboPoint, "BOTTOMRIGHT")
        comboPoint.fill:SetHeight(height)

        comboPoint.borderTop = comboPoint:CreateTexture(nil, "OVERLAY")
        comboPoint.borderTop:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderTop:SetPoint("TOPLEFT", comboPoint, "TOPLEFT", 0, 0)
        comboPoint.borderTop:SetPoint("TOPRIGHT", comboPoint, "TOPRIGHT", 0, 0)
        comboPoint.borderTop:SetHeight(1)

        comboPoint.borderBottom = comboPoint:CreateTexture(nil, "OVERLAY")
        comboPoint.borderBottom:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderBottom:SetPoint("BOTTOMLEFT", comboPoint, "BOTTOMLEFT", 0, 0)
        comboPoint.borderBottom:SetPoint("BOTTOMRIGHT", comboPoint, "BOTTOMRIGHT", 0, 0)
        comboPoint.borderBottom:SetHeight(1)

        comboPoint.borderLeft = comboPoint:CreateTexture(nil, "OVERLAY")
        comboPoint.borderLeft:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderLeft:SetPoint("TOPLEFT", comboPoint, "TOPLEFT", 0, 0)
        comboPoint.borderLeft:SetPoint("BOTTOMLEFT", comboPoint, "BOTTOMLEFT", 0, 0)
        comboPoint.borderLeft:SetWidth(1)

        comboPoint.borderRight = comboPoint:CreateTexture(nil, "OVERLAY")
        comboPoint.borderRight:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderRight:SetPoint("TOPRIGHT", comboPoint, "TOPRIGHT", 0, 0)
        comboPoint.borderRight:SetPoint("BOTTOMRIGHT", comboPoint, "BOTTOMRIGHT", 0, 0)
        comboPoint.borderRight:SetWidth(1)

        comboPointBar.comboPoints[i] = comboPoint
    end

    UpdateDruidComboBarEnabled()
end

local function LerpColor(c1, c2, t)
    if type(c1) ~= "table" or not c1[1] then c1 = {1, 0, 0, 1} end
    if type(c2) ~= "table" or not c2[1] then c2 = {1, 1, 0, 1} end
    return c1[1] + (c2[1] - c1[1]) * t,
           c1[2] + (c2[2] - c1[2]) * t,
           c1[3] + (c2[3] - c1[3]) * t,
           c1[4] + (c2[4] - c1[4]) * t
end

local function UpdateChargedComboPoints()
    for i = 1, #chargedComboPoints do chargedComboPoints[i] = false end
    if GetUnitChargedPowerPoints then
        local charged = GetUnitChargedPowerPoints("player")
        if charged then
            for _, idx in ipairs(charged) do
                chargedComboPoints[idx] = true
            end
        end
    end
end

local function UpdateComboPointBarSize()
    local numPoints = GetMaxComboPoints()
    local width
    if CustomDruidComboBarDB.totalWidth and CustomDruidComboBarDB.totalWidth > 0 then
        width = CustomDruidComboBarDB.totalWidth
    else
        width = (CustomDruidComboBarDB.comboPointWidth or 24) * numPoints
    end
    comboPointBar:SetSize(width, CustomDruidComboBarDB.comboPointHeight or 24)
end

local function ApplyComboBarSettings()
    UpdateComboPointBarSize()
    comboPointBar:ClearAllPoints()

    local anchorFrame = GetPRDAnchorFrame()
    dprint("Apply settings:", "anchorToPRD=", CustomDruidComboBarDB.anchorToPRD, "anchorFrame=", anchorFrame and "yes" or "no")

    if anchorFrame then
        if CustomDruidComboBarDB.anchorPosition == "ABOVE" then
            dprint("Anchoring ABOVE PRD with offset", CustomDruidComboBarDB.anchorOffset or 10)
            comboPointBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, CustomDruidComboBarDB.anchorOffset or 10)
        else
            dprint("Anchoring BELOW PRD with offset", CustomDruidComboBarDB.anchorOffset or 10)
            comboPointBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -(CustomDruidComboBarDB.anchorOffset or 10))
        end
    else
        dprint("Center position x=", CustomDruidComboBarDB.x or 0, "y=", CustomDruidComboBarDB.y or 0)
        comboPointBar:SetPoint("CENTER", UIParent, "CENTER", CustomDruidComboBarDB.x or 0, CustomDruidComboBarDB.y or 0)
    end
end

local function UpdateComboPoints()
    UpdateChargedComboPoints()
    CreateComboPoints()
    UpdateComboPointBarSize()
    ApplyComboBarSettings()

    local current = UnitPower("player", COMBO_POINT_TYPE)
    local numPoints = GetMaxComboPoints()
    local width = GetComboPointWidth(numPoints)
    local height = CustomDruidComboBarDB.comboPointHeight or 24
    local bgR, bgG, bgB, bgA = SafeUnpackColor(CustomDruidComboBarDB.comboPointBgColor, {0, 0, 0, 0.5})

    for i = 1, numPoints do
        local comboPoint = comboPointBar.comboPoints[i]
        comboPoint:SetSize(width, height)
        comboPoint:SetPoint("LEFT", comboPointBar, "LEFT", (i-1)*width, 0)

        if chargedComboPoints[i] then
            local c = CustomDruidComboBarDB.chargedComboPointBgColor or {0.1, 0.3, 0.5, 0.7}
            comboPoint.bg:SetColorTexture(c[1], c[2], c[3], c[4])
        else
            comboPoint.bg:SetColorTexture(bgR, bgG, bgB, bgA)
        end

        local fillAmount = (i <= current) and 1 or 0
        if fillAmount > 0 then
            comboPoint.fill:Show()
            comboPoint.fill:SetHeight(height * fillAmount)
            comboPoint.fill:ClearAllPoints()
            comboPoint.fill:SetPoint("BOTTOMLEFT", comboPoint, "BOTTOMLEFT")
            comboPoint.fill:SetPoint("BOTTOMRIGHT", comboPoint, "BOTTOMRIGHT")

            local color
            if chargedComboPoints[i] then
                color = CustomDruidComboBarDB.chargedComboPointColor or {0.2, 0.6, 1, 1}
            elseif CustomDruidComboBarDB.gradientColoringEnabled then
                local t = (numPoints == 1) and 0 or (i-1)/(numPoints-1)
                color = {LerpColor(CustomDruidComboBarDB.gradientColorStart, CustomDruidComboBarDB.gradientColorEnd, t)}
            else
                color = CustomDruidComboBarDB.comboPointFillColors[i] or {1, 0.7, 0.2, 1}
            end
            comboPoint.fill:SetColorTexture(unpack(color))
            comboPoint.fill:SetAlpha(1)
        else
            comboPoint.fill:Hide()
        end
    end

    for i = numPoints+1, #comboPointBar.comboPoints do
        if comboPointBar.comboPoints[i] then
            comboPointBar.comboPoints[i]:Hide()
        end
    end
end

local function HookPRDAnchor()
    local anchorFrame = GetPRDAnchorFrame()
    if not anchorFrame then return end
    anchorFrame._cdcb_hooks = anchorFrame._cdcb_hooks or {}

    if not anchorFrame._cdcb_hooks.SetPoint then
        anchorFrame._cdcb_hooks.SetPoint = true
        hooksecurefunc(anchorFrame, "SetPoint", function()
            if CustomDruidComboBarDB.anchorToPRD then ApplyComboBarSettings() end
        end)
    end
    if not anchorFrame._cdcb_hooks.SetSize then
        anchorFrame._cdcb_hooks.SetSize = true
        hooksecurefunc(anchorFrame, "SetSize", function()
            if CustomDruidComboBarDB.anchorToPRD then ApplyComboBarSettings() end
        end)
    end
    if not anchorFrame._cdcb_hooks.SetScale then
        anchorFrame._cdcb_hooks.SetScale = true
        hooksecurefunc(anchorFrame, "SetScale", function()
            if CustomDruidComboBarDB.anchorToPRD then ApplyComboBarSettings() end
        end)
    end
end

local function TryHookPRDAnchor()
    if GetPRDAnchorFrame() then
        HookPRDAnchor()
    else
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self)
            if GetPRDAnchorFrame() then
                HookPRDAnchor()
                self:UnregisterAllEvents()
            end
        end)
    end
end

local function ShouldShowComboPointBar()
    local _, class = UnitClass("player")
    return class == "DRUID"
end

comboPointBar:SetMovable(true)
comboPointBar:EnableMouse(true)
comboPointBar:RegisterForDrag("LeftButton")
comboPointBar:SetScript("OnDragStart", function(self)
    if not CustomDruidComboBarDB.locked and not CustomDruidComboBarDB.anchorToPRD then self:StartMoving() end
end)
comboPointBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomDruidComboBarDB.x = x or 0
    CustomDruidComboBarDB.y = y or 0
    dprint("DragStop: updated x,y:", CustomDruidComboBarDB.x, CustomDruidComboBarDB.y)
end)

local function UpdateVisibility()
    if ShouldShowComboPointBar() and CustomDruidComboBarDB.enabled then
        comboPointBar:Show()
    else
        comboPointBar:Hide()
    end
end

comboPointBar:RegisterEvent("UNIT_POWER_POINT_CHARGE")
comboPointBar:RegisterEvent("UNIT_POWER_UPDATE")
comboPointBar:RegisterEvent("PLAYER_ENTERING_WORLD")
comboPointBar:RegisterEvent("PLAYER_LOGIN")
comboPointBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
comboPointBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
comboPointBar:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
comboPointBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_POINT_CHARGE" then
        UpdateChargedComboPoints()
        UpdateComboPoints()
    elseif event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "COMBO_POINTS" or powerType == COMBO_POINT_TYPE) then
            UpdateComboPoints()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        UpdateDruidComboBarEnabled()
        UpdateComboPoints()
    else
        UpdateComboPoints()
    end
end)

-- Initial check on load
UpdateDruidComboBarEnabled()

local function UpdateDruidComboBarSettings()
    ApplyComboBarSettings()
    UpdateComboPoints()
    if CustomDruidComboBarDB.anchorToPRD then
        TryHookPRDAnchor()
    end
end

_G.UpdateComboPoints = UpdateComboPoints
_G.UpdateDruidComboBarSettings = UpdateDruidComboBarSettings
