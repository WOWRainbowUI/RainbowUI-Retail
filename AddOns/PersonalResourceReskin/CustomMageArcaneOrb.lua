-- CustomMageArcaneOrb.lua

local ARCANE_CHARGES_TYPE = Enum and Enum.PowerType and Enum.PowerType.ArcaneCharges or 16 

CustomMageArcaneOrbDB = CustomMageArcaneOrbDB or {
    x = 0, y = -120, arcaneOrbWidth = 24, arcaneOrbHeight = 24, locked = false,
    totalWidth = nil,
    arcaneOrbBgColor = {0, 0, 0, 0.5},
    arcaneOrbFillColors = {
        {0.2, 0.4, 1, 1}, {0.2, 0.4, 1, 1}, {0.2, 0.4, 1, 1}, {0.2, 0.4, 1, 1},
    },
    gradientColoringEnabled = false,
    gradientColorStart = {0, 0, 1, 1},
    gradientColorEnd = {1, 1, 0, 1},
    anchorToPRD = false,
    anchorPosition = "BELOW",
    anchorOffset = 10,
    anchorTarget = "HEALTH", -- HEALTH or POWER
    debug = false,
    enabled = true,
}



local _, playerClass = UnitClass("player")
if playerClass ~= "MAGE" then return end

local isArcane = false

local ARCANE_CHARGES_TYPE = Enum and Enum.PowerType and Enum.PowerType.ArcaneCharges or 16

local function dprint(...)
    if CustomMageArcaneOrbDB and CustomMageArcaneOrbDB.debug then
        print("[CMAO]", ...)
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
    return _G.PersonalResourceDisplayPowerBar
end

local function GetPRDAnchorFrame()
    if not CustomMageArcaneOrbDB.anchorToPRD then return nil end
    local target = CustomMageArcaneOrbDB.anchorTarget or "HEALTH"
    local f = (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
    dprint("GetPRDAnchorFrame target=", target, "found=", f and "yes" or "no")
    return f
end

local function HideDefaultArcaneOrbs()
    local _, class = UnitClass("player")
    if class ~= "MAGE" then return end
    if _G.prdClassFrame then
        for i, child in ipairs({_G.prdClassFrame:GetChildren()}) do
            if child and child:IsShown() then
                child:Hide()
                child:SetAlpha(0)
            end
        end
        _G.prdClassFrame:Hide()
        _G.prdClassFrame:SetAlpha(0)
    end
end

local function ShowDefaultArcaneOrbs()
    local _, class = UnitClass("player")
    if class ~= "MAGE" then return end
    if _G.prdClassFrame then
        _G.prdClassFrame:Show()
        _G.prdClassFrame:SetAlpha(1)
        for i, child in ipairs({_G.prdClassFrame:GetChildren()}) do
            if child then
                child:Show()
                child:SetAlpha(1)
            end
        end
    end
end

local arcaneOrbBar = CreateFrame("Frame", "CustomMageArcaneOrb", UIParent)
arcaneOrbBar.arcaneOrbs = {}

function UpdateMageArcaneOrbEnabled()
    if not isArcane then return end
    if CustomMageArcaneOrbDB.enabled then
        HideDefaultArcaneOrbs()
        arcaneOrbBar:Show()
    else
        ShowDefaultArcaneOrbs()
        arcaneOrbBar:Hide()
    end
end

local function GetMaxArcaneOrbs()
    return UnitPowerMax("player", ARCANE_CHARGES_TYPE) or 4
end

local function GetArcaneOrbWidth(numOrbs)
    if numOrbs == 0 then numOrbs = 4 end
    if CustomMageArcaneOrbDB.totalWidth and CustomMageArcaneOrbDB.totalWidth > 0 then
        return CustomMageArcaneOrbDB.totalWidth / numOrbs
    end
    return CustomMageArcaneOrbDB.arcaneOrbWidth or 24
end

local function CreateArcaneOrbs()
    for _, orb in ipairs(arcaneOrbBar.arcaneOrbs) do
        orb:Hide()
        orb:SetParent(nil)
    end
    arcaneOrbBar.arcaneOrbs = {}

    local numOrbs = GetMaxArcaneOrbs()
    local width = GetArcaneOrbWidth(numOrbs)
    local height = CustomMageArcaneOrbDB.arcaneOrbHeight or 24

    for i = 1, numOrbs do
        local arcaneOrb = CreateFrame("Frame", nil, arcaneOrbBar)
        arcaneOrb:SetSize(width, height)
        arcaneOrb:SetPoint("LEFT", arcaneOrbBar, "LEFT", (i-1)*width, 0)
        arcaneOrb:EnableMouse(false)

        arcaneOrb.bg = arcaneOrb:CreateTexture(nil, "BACKGROUND")
        arcaneOrb.bg:SetAllPoints()

        arcaneOrb.fill = arcaneOrb:CreateTexture(nil, "ARTWORK")
        arcaneOrb.fill:SetPoint("BOTTOMLEFT", arcaneOrb, "BOTTOMLEFT")
        arcaneOrb.fill:SetPoint("BOTTOMRIGHT", arcaneOrb, "BOTTOMRIGHT")
        arcaneOrb.fill:SetHeight(height)

        arcaneOrb.borderTop = arcaneOrb:CreateTexture(nil, "OVERLAY")
        arcaneOrb.borderTop:SetColorTexture(0, 0, 0, 1)
        arcaneOrb.borderTop:SetPoint("TOPLEFT", arcaneOrb, "TOPLEFT", 0, 0)
        arcaneOrb.borderTop:SetPoint("TOPRIGHT", arcaneOrb, "TOPRIGHT", 0, 0)
        arcaneOrb.borderTop:SetHeight(1)

        arcaneOrb.borderBottom = arcaneOrb:CreateTexture(nil, "OVERLAY")
        arcaneOrb.borderBottom:SetColorTexture(0, 0, 0, 1)
        arcaneOrb.borderBottom:SetPoint("BOTTOMLEFT", arcaneOrb, "BOTTOMLEFT", 0, 0)
        arcaneOrb.borderBottom:SetPoint("BOTTOMRIGHT", arcaneOrb, "BOTTOMRIGHT", 0, 0)
        arcaneOrb.borderBottom:SetHeight(1)

        arcaneOrb.borderLeft = arcaneOrb:CreateTexture(nil, "OVERLAY")
        arcaneOrb.borderLeft:SetColorTexture(0, 0, 0, 1)
        arcaneOrb.borderLeft:SetPoint("TOPLEFT", arcaneOrb, "TOPLEFT", 0, 0)
        arcaneOrb.borderLeft:SetPoint("BOTTOMLEFT", arcaneOrb, "BOTTOMLEFT", 0, 0)
        arcaneOrb.borderLeft:SetWidth(1)

        arcaneOrb.borderRight = arcaneOrb:CreateTexture(nil, "OVERLAY")
        arcaneOrb.borderRight:SetColorTexture(0, 0, 0, 1)
        arcaneOrb.borderRight:SetPoint("TOPRIGHT", arcaneOrb, "TOPRIGHT", 0, 0)
        arcaneOrb.borderRight:SetPoint("BOTTOMRIGHT", arcaneOrb, "BOTTOMRIGHT", 0, 0)
        arcaneOrb.borderRight:SetWidth(1)

        arcaneOrbBar.arcaneOrbs[i] = arcaneOrb
    end

    UpdateMageArcaneOrbEnabled()
end

local function LerpColor(c1, c2, t)
    if type(c1) ~= "table" or not c1[1] then c1 = {1, 0, 0, 1} end
    if type(c2) ~= "table" or not c2[1] then c2 = {1, 1, 0, 1} end
    return c1[1] + (c2[1] - c1[1]) * t,
           c1[2] + (c2[2] - c1[2]) * t,
           c1[3] + (c2[3] - c1[3]) * t,
           c1[4] + (c2[4] - c1[4]) * t
end

local function UpdateArcaneOrbBarSize()
    local numOrbs = GetMaxArcaneOrbs()
    local width
    if CustomMageArcaneOrbDB.totalWidth and CustomMageArcaneOrbDB.totalWidth > 0 then
        width = CustomMageArcaneOrbDB.totalWidth
    else
        width = (CustomMageArcaneOrbDB.arcaneOrbWidth or 24) * numOrbs
    end
    arcaneOrbBar:SetSize(width, CustomMageArcaneOrbDB.arcaneOrbHeight or 24)
end

local function ApplyArcaneOrbBarSettings()
    UpdateArcaneOrbBarSize()
    arcaneOrbBar:ClearAllPoints()

    local anchorFrame = GetPRDAnchorFrame()
    dprint("Apply settings:", "anchorToPRD=", CustomMageArcaneOrbDB.anchorToPRD, "anchorFrame=", anchorFrame and "yes" or "no")

    if anchorFrame then
        if CustomMageArcaneOrbDB.anchorPosition == "ABOVE" then
            dprint("對齊到個人資源條上方，偏移量", CustomMageArcaneOrbDB.anchorOffset or 10)
            arcaneOrbBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, CustomMageArcaneOrbDB.anchorOffset or 10)
        else
            dprint("對齊到個人資源條下方，偏移量", CustomMageArcaneOrbDB.anchorOffset or 10)
            arcaneOrbBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -(CustomMageArcaneOrbDB.anchorOffset or 10))
        end
    else
        dprint("置中位置 x=", CustomMageArcaneOrbDB.x or 0, "y=", CustomMageArcaneOrbDB.y or 0)
        arcaneOrbBar:SetPoint("CENTER", UIParent, "CENTER", CustomMageArcaneOrbDB.x or 0, CustomMageArcaneOrbDB.y or 0)
    end
end

local function UpdateArcaneOrbs()
    if not isArcane then return end
    CreateArcaneOrbs()
    UpdateArcaneOrbBarSize()
    ApplyArcaneOrbBarSettings()

    local current = UnitPower("player", ARCANE_CHARGES_TYPE)
    local numOrbs = GetMaxArcaneOrbs()
    local width = GetArcaneOrbWidth(numOrbs)
    local height = CustomMageArcaneOrbDB.arcaneOrbHeight or 24
    local bgR, bgG, bgB, bgA = SafeUnpackColor(CustomMageArcaneOrbDB.arcaneOrbBgColor, {0, 0, 0, 0.5})

    for i = 1, numOrbs do
        local arcaneOrb = arcaneOrbBar.arcaneOrbs[i]
        arcaneOrb:SetSize(width, height)
        arcaneOrb:SetPoint("LEFT", arcaneOrbBar, "LEFT", (i-1)*width, 0)

        arcaneOrb.bg:SetColorTexture(bgR, bgG, bgB, bgA)

        local fillAmount = (i <= current) and 1 or 0
        if fillAmount > 0 then
            arcaneOrb.fill:Show()
            arcaneOrb.fill:SetHeight(height * fillAmount)
            arcaneOrb.fill:ClearAllPoints()
            arcaneOrb.fill:SetPoint("BOTTOMLEFT", arcaneOrb, "BOTTOMLEFT")
            arcaneOrb.fill:SetPoint("BOTTOMRIGHT", arcaneOrb, "BOTTOMRIGHT")

            local color
            if CustomMageArcaneOrbDB.gradientColoringEnabled then
                local t = (numOrbs == 1) and 0 or (i-1)/(numOrbs-1)
                color = {LerpColor(CustomMageArcaneOrbDB.gradientColorStart, CustomMageArcaneOrbDB.gradientColorEnd, t)}
            else
                color = CustomMageArcaneOrbDB.arcaneOrbFillColors[i] or {0.2, 0.4, 1, 1}
            end
            arcaneOrb.fill:SetColorTexture(unpack(color))
            arcaneOrb.fill:SetAlpha(1)
        else
            arcaneOrb.fill:Hide()
        end
    end

    for i = numOrbs+1, #arcaneOrbBar.arcaneOrbs do
        if arcaneOrbBar.arcaneOrbs[i] then
            arcaneOrbBar.arcaneOrbs[i]:Hide()
        end
    end
end

local function HookPRDAnchor()
    local anchorFrame = GetPRDAnchorFrame()
    if not anchorFrame then return end
    anchorFrame._cmao_hooks = anchorFrame._cmao_hooks or {}

    if not anchorFrame._cmao_hooks.SetPoint then
        anchorFrame._cmao_hooks.SetPoint = true
        hooksecurefunc(anchorFrame, "SetPoint", function()
            if CustomMageArcaneOrbDB.anchorToPRD then ApplyArcaneOrbBarSettings() end
        end)
    end
    if not anchorFrame._cmao_hooks.SetSize then
        anchorFrame._cmao_hooks.SetSize = true
        hooksecurefunc(anchorFrame, "SetSize", function()
            if CustomMageArcaneOrbDB.anchorToPRD then ApplyArcaneOrbBarSettings() end
        end)
    end
end

local function TryHookPRDAnchor()
    HookPRDAnchor()
end

local function UpdateVisibility()
    if CustomMageArcaneOrbDB.enabled then
        arcaneOrbBar:Show()
    else
        arcaneOrbBar:Hide()
    end
end

arcaneOrbBar:SetMovable(true)
arcaneOrbBar:EnableMouse(true)
arcaneOrbBar:RegisterForDrag("LeftButton")
arcaneOrbBar:SetScript("OnDragStart", function(self)
    if not CustomMageArcaneOrbDB.locked and not CustomMageArcaneOrbDB.anchorToPRD then self:StartMoving() end
end)
arcaneOrbBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomMageArcaneOrbDB.x = x or 0
    CustomMageArcaneOrbDB.y = y or 0
    dprint("DragStop: updated x,y:", CustomMageArcaneOrbDB.x, CustomMageArcaneOrbDB.y)
end)

local function UpdateMageArcaneOrbSettings()
    ApplyArcaneOrbBarSettings()
    UpdateArcaneOrbs()
    if CustomMageArcaneOrbDB.anchorToPRD then
        TryHookPRDAnchor()
    end
end

arcaneOrbBar:RegisterEvent("UNIT_POWER_UPDATE")
arcaneOrbBar:RegisterEvent("PLAYER_ENTERING_WORLD")
arcaneOrbBar:RegisterEvent("PLAYER_LOGIN")
arcaneOrbBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
arcaneOrbBar:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        local spec = GetSpecialization()
        isArcane = spec and select(2, GetSpecializationInfo(spec)) == "Arcane"
    end
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "ARCANE_CHARGES" or powerType == ARCANE_CHARGES_TYPE) then
            UpdateArcaneOrbs()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        UpdateMageArcaneOrbEnabled()
        UpdateArcaneOrbs()
    else
        UpdateArcaneOrbs()
    end
end)

_G.UpdateArcaneOrbs = UpdateArcaneOrbs
_G.UpdateMageArcaneOrbSettings = UpdateMageArcaneOrbSettings