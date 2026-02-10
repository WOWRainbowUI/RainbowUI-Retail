
local _, playerClass = UnitClass("player")
if playerClass ~= "MONK" then return end
local spec = GetSpecialization and GetSpecialization()
local specID = spec and GetSpecializationInfo(spec)
if specID ~= 269 then return end
function ShowDefaultChiBar() end
local function RegisterWWMonkOrbOptions()
    if PersonalResourceReskinPlus_Options and _G.MonkOrbTrackerOptions then
        if not _G.MonkOrbTrackerOptions.args then _G.MonkOrbTrackerOptions.args = {} end
        _G.MonkOrbTrackerOptions.args.wwMonkOrbSubpage = {
            type = "group",
            name = "Windwalker Monk Chi Orbs Bar",
            order = 2,
            args = {
                header = {
                    order = 0,
                    type = "header",
                    name = "Windwalker Monk Chi Orbs Bar",
                },
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = "Enable Chi Orbs Bar",
                    desc = "Show the custom Windwalker Monk Chi orbs bar.",
                    get = function() return CustomWindwalkerMonkOrbBarDB.enabled ~= false end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.enabled = val
                        UpdateVisibility()
                    end,
                },
                hideWhenMounted = {
                    order = 1.5,
                    type = "toggle",
                    name = "Hide When Mounted",
                    desc = "Hide the Chi Orbs bar while mounted.",
                    get = function() return CustomWindwalkerMonkOrbBarDB.hideWhenMounted end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.hideWhenMounted = val
                        UpdateVisibility()
                    end,
                },
                orbBgColor = {
                    order = 2,
                    type = "color",
                    name = "Orb Background Color",
                    hasAlpha = true,
                    get = function() return unpack(CustomWindwalkerMonkOrbBarDB.orbBgColor or {0, 0, 0, 0.5}) end,
                    set = function(_, r, g, b, a)
                        CustomWindwalkerMonkOrbBarDB.orbBgColor = {r, g, b, a}
                        UpdateChi()
                    end,
                },
                gradientColor1 = {
                    order = 3,
                    type = "color",
                    name = "Gradient Start Color",
                    hasAlpha = true,
                    get = function() return unpack(CustomWindwalkerMonkOrbBarDB.gradientColor1 or {0.0, 0.8, 0.6, 1}) end,
                    set = function(_, r, g, b, a)
                        CustomWindwalkerMonkOrbBarDB.gradientColor1 = {r, g, b, a}
                        UpdateChi()
                    end,
                },
                gradientColor2 = {
                    order = 4,
                    type = "color",
                    name = "Gradient End Color",
                    hasAlpha = true,
                    get = function() return unpack(CustomWindwalkerMonkOrbBarDB.gradientColor2 or {0.0, 1, 0.8, 1}) end,
                    set = function(_, r, g, b, a)
                        CustomWindwalkerMonkOrbBarDB.gradientColor2 = {r, g, b, a}
                        UpdateChi()
                    end,
                },
                orbWidth = {
                    order = 5,
                    type = "range",
                    name = "Orb Width",
                    min = 10, max = 100, step = 1,
                    get = function() return CustomWindwalkerMonkOrbBarDB.orbWidth end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.orbWidth = val
                        CreateOrbs()
                        ApplyBarSettings()
                    end,
                },
                orbHeight = {
                    order = 6,
                    type = "range",
                    name = "Orb Height",
                    min = 10, max = 100, step = 1,
                    get = function() return CustomWindwalkerMonkOrbBarDB.orbHeight end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.orbHeight = val
                        ApplyBarSettings()
                    end,
                },
                orbSpacing = {
                    order = 7,
                    type = "range",
                    name = "Orb Spacing",
                    min = 0, max = 40, step = 0.1,
                    get = function() return CustomWindwalkerMonkOrbBarDB.orbSpacing or 0 end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.orbSpacing = val
                        CreateOrbs()
                        ApplyBarSettings()
                    end,
                },
                yOffset = {
                    order = 8.1,
                    type = "range",
                    name = "Vertical Offset",
                    desc = "Vertical position when not anchored.",
                    min = -400, max = 400, step = 0.001,
                    get = function() return CustomWindwalkerMonkOrbBarDB.y or -120 end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.y = val
                        ApplyBarSettings()
                    end,
                    disabled = function() return CustomWindwalkerMonkOrbBarDB.anchorToPRD end,
                },
                anchorToPRD = {
                    order = 8.2,
                    type = "toggle",
                    name = "Anchor to Personal Resource Display",
                    desc = "Attach to PRD health or power bar.",
                    get = function() return CustomWindwalkerMonkOrbBarDB.anchorToPRD end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.anchorToPRD = val
                        ApplyBarSettings()
                    end,
                },
                anchorTarget = {
                    order = 8.3,
                    type = "select",
                    name = "Anchor Target",
                    desc = "Choose which PRD bar to anchor to.",
                    values = { HEALTH = "Health Bar", POWER = "Power Bar" },
                    get = function() return CustomWindwalkerMonkOrbBarDB.anchorTarget or "HEALTH" end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.anchorTarget = val
                        ApplyBarSettings()
                    end,
                    disabled = function() return not CustomWindwalkerMonkOrbBarDB.anchorToPRD end,
                },
                anchorPosition = {
                    order = 8.4,
                    type = "select",
                    name = "Anchor Position",
                    desc = "Place above or below the selected PRD bar.",
                    values = { ABOVE = "Above", BELOW = "Below" },
                    get = function() return CustomWindwalkerMonkOrbBarDB.anchorPosition or "BELOW" end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.anchorPosition = val
                        ApplyBarSettings()
                    end,
                    disabled = function() return not CustomWindwalkerMonkOrbBarDB.anchorToPRD end,
                },
                anchorOffset = {
                    order = 8.5,
                    type = "range",
                    name = "Anchor Offset",
                    desc = "Vertical offset from the PRD bar when anchored.",
                    min = -100, max = 200, step = 1,
                    get = function() return CustomWindwalkerMonkOrbBarDB.anchorOffset or 10 end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.anchorOffset = val
                        ApplyBarSettings()
                    end,
                    disabled = function() return not CustomWindwalkerMonkOrbBarDB.anchorToPRD end,
                },
                totalWidth = {
                    order = 8,
                    type = "range",
                    name = "Total Bar Width",
                    min = 60, max = 600, step = 1,
                    get = function() return CustomWindwalkerMonkOrbBarDB.totalWidth or 0 end,
                    set = function(_, val)
                        if val > 0 then
                            CustomWindwalkerMonkOrbBarDB.totalWidth = val
                        else
                            CustomWindwalkerMonkOrbBarDB.totalWidth = nil
                        end
                        CreateOrbs()
                        ApplyBarSettings()
                    end,
                },
                locked = {
                    order = 9,
                    type = "toggle",
                    name = "Lock Bar",
                    desc = "Lock or unlock the bar for dragging.",
                    get = function() return CustomWindwalkerMonkOrbBarDB.locked end,
                    set = function(_, val)
                        CustomWindwalkerMonkOrbBarDB.locked = val
                        ApplyBarSettings()
                    end,
                },
            },
        }
    end
end

if IsLoggedIn and IsLoggedIn() then
    RegisterWWMonkOrbOptions()
else
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function()
        RegisterWWMonkOrbOptions()
    end)
end


local NUM_ORBS = 6 






local CHI_TYPE = Enum and Enum.PowerType and Enum.PowerType.Chi or 17

CustomWindwalkerMonkOrbBarDB = CustomWindwalkerMonkOrbBarDB or {
    x = 0, y = -120, orbWidth = 24, orbHeight = 24, locked = false,
    totalWidth = nil,
    orbSpacing = 0,
    orbBgColor = {0, 0, 0, 0.5},
    gradientColor1 = {0.0, 0.8, 0.6, 1}, 
    gradientColor2 = {0.0, 1, 0.8, 1},
    enabled = true,
    anchorToPRD = false,
    anchorTarget = "HEALTH",
    anchorPosition = "BELOW",
    anchorOffset = 10,
}




local function HideDefaultChiBar() end

HideDefaultChiBar()

local chiBar = CreateFrame("Frame", "CustomWindwalkerMonkOrbBar", UIParent)
chiBar:SetSize(180, 32)
chiBar:SetPoint("CENTER", UIParent, "CENTER", CustomWindwalkerMonkOrbBarDB.x, CustomWindwalkerMonkOrbBarDB.y)
chiBar.orbs = {}

local function GetMaxChi()
    return UnitPowerMax("player", CHI_TYPE) or 6
end

local function GetOrbWidth(numChi)
    local spacing = CustomWindwalkerMonkOrbBarDB.orbSpacing or 0
    if not numChi or numChi <= 0 then
        return CustomWindwalkerMonkOrbBarDB.orbWidth or 24
    end
    if CustomWindwalkerMonkOrbBarDB.totalWidth and CustomWindwalkerMonkOrbBarDB.totalWidth > 0 then
        return (CustomWindwalkerMonkOrbBarDB.totalWidth - spacing * (numChi - 1)) / numChi
    else
        return CustomWindwalkerMonkOrbBarDB.orbWidth or 24
    end
end


function CreateOrbs()
    for _, orb in ipairs(chiBar.orbs) do
        orb:Hide()
        orb:SetParent(nil)
    end
    chiBar.orbs = {}
    local numChi = GetMaxChi()
    local orbWidth = GetOrbWidth(numChi)
    local spacing = CustomWindwalkerMonkOrbBarDB.orbSpacing or 0
    for i = 1, numChi do
        local orb = CreateFrame("Frame", nil, chiBar)
        orb:SetSize(orbWidth, CustomWindwalkerMonkOrbBarDB.orbHeight)
        orb:SetPoint("LEFT", chiBar, "LEFT", (i-1)*(orbWidth+spacing), 0)
        orb.bg = orb:CreateTexture(nil, "BACKGROUND")
        orb.bg:SetAllPoints()
        local bg = CustomWindwalkerMonkOrbBarDB.orbBgColor or {0, 0, 0, 0.5}
        orb.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
        orb.fill = orb:CreateTexture(nil, "ARTWORK")
        orb.fill:SetAllPoints()
        orb.fill:SetColorTexture(1, 1, 1, 1)
        orb.fill:SetAlpha(0.2)
        orb.borderTop = orb:CreateTexture(nil, "OVERLAY")
        orb.borderTop:SetColorTexture(0, 0, 0, 1)
        orb.borderTop:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderTop:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderTop:SetHeight(1)
        orb.borderBottom = orb:CreateTexture(nil, "OVERLAY")
        orb.borderBottom:SetColorTexture(0, 0, 0, 1)
        orb.borderBottom:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderBottom:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderBottom:SetHeight(1)
        orb.borderLeft = orb:CreateTexture(nil, "OVERLAY")
        orb.borderLeft:SetColorTexture(0, 0, 0, 1)
        orb.borderLeft:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderLeft:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderLeft:SetWidth(1)
        orb.borderRight = orb:CreateTexture(nil, "OVERLAY")
        orb.borderRight:SetColorTexture(0, 0, 0, 1)
        orb.borderRight:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderRight:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderRight:SetWidth(1)
        chiBar.orbs[i] = orb
    end
end

CreateOrbs()

local lastMaxChi = GetMaxChi()
local function UpdateChi()
    local current = UnitPower("player", CHI_TYPE)
    local maxChi = GetMaxChi()
    if maxChi ~= lastMaxChi then
        lastMaxChi = maxChi
        CreateOrbs()
        ApplyBarSettings()
    end
    local c1 = CustomWindwalkerMonkOrbBarDB.gradientColor1 or {0.0, 0.8, 0.6, 1}
    local c2 = CustomWindwalkerMonkOrbBarDB.gradientColor2 or {0.0, 1, 0.8, 1}
    local bg = CustomWindwalkerMonkOrbBarDB.orbBgColor or {0, 0, 0, 0.5}
    for i, orb in ipairs(chiBar.orbs) do
        orb.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
        if i <= current then
            orb.fill:Show()
            orb.fill:SetAlpha(1)
            if orb.fill.SetVertexColor then
                orb.fill:SetVertexColor(1, 1, 1, 1)
            end
            if c1[1] == c2[1] and c1[2] == c2[2] and c1[3] == c2[3] and c1[4] == c2[4] then
                orb.fill:SetColorTexture(c1[1], c1[2], c1[3], c1[4])
            elseif orb.fill.SetGradient then
                orb.fill:SetGradient("HORIZONTAL",
                    CreateColor(c1[1], c1[2], c1[3], c1[4]),
                    CreateColor(c2[1], c2[2], c2[3], c2[4])
                )
            else
                orb.fill:SetColorTexture(c1[1], c1[2], c1[3], c1[4])
            end
        else
            orb.fill:Hide()
        end
    end
end

-- Event handler
chiBar:RegisterEvent("UNIT_POWER_UPDATE")
chiBar:RegisterEvent("PLAYER_ENTERING_WORLD")
chiBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
chiBar:RegisterEvent("PLAYER_LOGIN")
chiBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "CHI" or powerType == CHI_TYPE) then
            UpdateChi()
        end
    else
        UpdateChi()
    end
end)

local function ShouldShowChiBar()
    -- Only true for Windwalker Monk
    local _, class = UnitClass("player")
    if class ~= "MONK" then return false end
    local spec = GetSpecialization and GetSpecialization()
    if not spec then return false end
    local specID = GetSpecializationInfo(spec)
    return specID == 269
end


function UpdateVisibility()
    local mounted = IsMounted and IsMounted() or (IsPlayerMounted and IsPlayerMounted())
    if CustomWindwalkerMonkOrbBarDB.hideWhenMounted and mounted then
        chiBar:Hide()
        ShowDefaultChiBar()
        return
    end
    if CustomWindwalkerMonkOrbBarDB.enabled and ShouldShowChiBar() then
        HideDefaultChiBar()
        chiBar:Show()
        UpdateChi()
        C_Timer.After(0.05, HideDefaultChiBar)
    else
        chiBar:Hide()
        ShowDefaultChiBar()
    end
end

chiBar:RegisterEvent("PLAYER_LOGIN")
chiBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
chiBar:SetScript("OnEvent", function(self, event, ...)
    UpdateVisibility()
end)


function ApplyBarSettings()
    local spacing = CustomWindwalkerMonkOrbBarDB.orbSpacing or 0
    local numChi = GetMaxChi()
    local orbWidth = GetOrbWidth(numChi)
    local totalWidth = orbWidth * numChi + spacing * (numChi - 1)
    chiBar:SetSize(totalWidth, CustomWindwalkerMonkOrbBarDB.orbHeight)
    chiBar:ClearAllPoints()

    if CustomWindwalkerMonkOrbBarDB.anchorToPRD then

        local prd = _G.PersonalResourceDisplayFrame
        local anchorFrame = nil
        if prd then
            if CustomWindwalkerMonkOrbBarDB.anchorTarget == "POWER" and prd.PowerBarsContainer and prd.PowerBarsContainer.powerBar then
                anchorFrame = prd.PowerBarsContainer.powerBar
            elseif prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
                anchorFrame = prd.HealthBarsContainer.healthBar
            end
        end
        if anchorFrame then
            local relPoint, yOff = "BOTTOM", CustomWindwalkerMonkOrbBarDB.anchorOffset or 10
            if CustomWindwalkerMonkOrbBarDB.anchorPosition == "ABOVE" then
                relPoint = "TOP"
                yOff = -(CustomWindwalkerMonkOrbBarDB.anchorOffset or 10)
            end
            chiBar:SetPoint("CENTER", anchorFrame, relPoint, 0, yOff)
        else
            chiBar:SetPoint("CENTER", UIParent, "CENTER", CustomWindwalkerMonkOrbBarDB.x, CustomWindwalkerMonkOrbBarDB.y)
        end
    else
        chiBar:SetPoint("CENTER", UIParent, "CENTER", CustomWindwalkerMonkOrbBarDB.x, CustomWindwalkerMonkOrbBarDB.y)
    end

    for i, orb in ipairs(chiBar.orbs) do
        orb:SetSize(orbWidth, CustomWindwalkerMonkOrbBarDB.orbHeight)
        orb:ClearAllPoints()
        orb:SetPoint("LEFT", chiBar, "LEFT", (i-1)*(orbWidth+spacing), 0)
        orb.borderTop:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderTop:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderTop:SetHeight(1)
        orb.borderBottom:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderBottom:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderBottom:SetHeight(1)
        orb.borderLeft:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderLeft:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderLeft:SetWidth(1)
        orb.borderRight:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderRight:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderRight:SetWidth(1)
    end
    chiBar:SetMovable(not CustomWindwalkerMonkOrbBarDB.locked)
    chiBar:EnableMouse(not CustomWindwalkerMonkOrbBarDB.locked)
end

chiBar:SetMovable(true)
chiBar:EnableMouse(true)
chiBar:RegisterForDrag("LeftButton")
chiBar:SetScript("OnDragStart", function(self)
    if not CustomWindwalkerMonkOrbBarDB.locked then self:StartMoving() end
end)
chiBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomWindwalkerMonkOrbBarDB.x = x or 0
    CustomWindwalkerMonkOrbBarDB.y = y or 0
end)

-- Slash commands for config
SLASH_CUSTOMWWORB1 = "/wworb"
SlashCmdList["CUSTOMWWORB"] = function(msg)
    local cmd, arg1, arg2 = msg:match("^(%S*)%s*(%-?%d*)%s*(%-?%d*)$")
    cmd = cmd:lower() or ""
    if cmd == "lock" then
        CustomWindwalkerMonkOrbBarDB.locked = true
        print("CustomWindwalkerMonkOrbBar locked.")
    elseif cmd == "unlock" then
        CustomWindwalkerMonkOrbBarDB.locked = false
        print("CustomWindwalkerMonkOrbBar unlocked. Drag to move.")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomWindwalkerMonkOrbBarDB.orbWidth = tonumber(arg1)
        CustomWindwalkerMonkOrbBarDB.orbHeight = tonumber(arg2)
        CreateOrbs()
        ApplyBarSettings()
        print("CustomWindwalkerMonkOrbBar orb size set to "..arg1.."x"..arg2)
    else
        print("/wworb lock | unlock | size <width> <height>")
    end
end

ApplyBarSettings()
UpdateVisibility()
