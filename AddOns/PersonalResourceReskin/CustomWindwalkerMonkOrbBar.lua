
local function get(info)
    local key = info[#info]
    local db = CustomWindwalkerMonkOrbBarDB
    if not db then return nil end
    return db[key]
end

local function set(info, value)
    local key = info[#info]
    local db = CustomWindwalkerMonkOrbBarDB
    if not db then return end
    db[key] = value
    if ApplyBarSettings then ApplyBarSettings() end
end

function RegisterWWMonkOrbOptions()
    local wwMonkOrbOptions = {
        type = "group",
        name = "御風武僧真氣條",
        order = 1,
        args = {
            header = {
                order = 0,
                type = "header",
                name = "御風武僧真氣條",
            },
            enabled = {
                order = 1,
                type = "toggle",
                name = "啟用真氣條",
                desc = "顯示自訂的御風武僧真氣條。",
                get = function() return CustomWindwalkerMonkOrbBarDB.enabled ~= false end,
                set = function(_, val)
                    CustomWindwalkerMonkOrbBarDB.enabled = val
                    UpdateVisibility()
                end,
            },
            hideWhenMounted = {
                order = 1.5,
                type = "toggle",
                name = "騎乘時隱藏",
                desc = "騎乘時隱藏真氣條。",
                get = function() return CustomWindwalkerMonkOrbBarDB.hideWhenMounted end,
                set = function(_, val)
                    CustomWindwalkerMonkOrbBarDB.hideWhenMounted = val
                    UpdateVisibility()
                end,
            },
            orbBgColor = {
                order = 2,
                type = "color",
                name = "真氣珠背景顏色",
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
                name = "漸層開始色",
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
                name = "漸層結束色",
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
                name = "真氣珠寬度",
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
                name = "真氣珠高度",
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
                name = "真氣珠間距",
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
                name = "垂直位置",
                desc = "未對齊時的垂直位置。",
                min = -400, max = 400, step = 0.001,
                get = function(info) return get(info) or -120 end,
                set = function(info, val) set(info, val) end,
                disabled = function() return get({"anchorToPRD"}) end,
            },
            anchorToPRD = {
                order = 8.2,
                type = "toggle",
                name = "對齊個人資源條",
                desc = "對齊到個人資源條的血量或能量條。",
                get = function(info) return get(info) end,
                set = function(info, val) set(info, val) end,
            },
            anchorTarget = {
                order = 8.3,
                type = "select",
                name = "對齊到",
                desc = "選擇要對齊到的個人資源條。",
                values = { HEALTH = "血量條", POWER = "能量條" },
                get = function(info) return get(info) or "HEALTH" end,
                set = function(info, val) set(info, val) end,
                disabled = function() return not get({"anchorToPRD"}) end,
            },
            anchorPosition = {
                order = 8.4,
                type = "select",
                name = "位置",
                desc = "放置在選擇的個人資源條的上方或下方。",
                values = { ABOVE = "上方", BELOW = "下方" },
                get = function(info) return get(info) or "BELOW" end,
                set = function(info, val) set(info, val) end,
                disabled = function() return not get({"anchorToPRD"}) end,
            },
            anchorOffset = {
                order = 8.5,
                type = "range",
                name = "偏移",
                desc = "對齊時與個人資源條的的垂直距離。",
                min = -100, max = 200, step = 1,
                get = function(info) return get(info) or 10 end,
                set = function(info, val) set(info, val) end,
                disabled = function() return not get({"anchorToPRD"}) end,
            },
            totalWidth = {
                order = 8,
                type = "range",
                name = "真氣條總寬度",
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
                name = "鎖定真氣條",
                desc = "鎖定或解鎖真氣條以進行拖曳。",
                get = function() return CustomWindwalkerMonkOrbBarDB.locked end,
                set = function(_, val)
                    CustomWindwalkerMonkOrbBarDB.locked = val
                    ApplyBarSettings()
                end,
            },
        },
    }
    _G.CustomWindwalkerMonkOrbBarOptions = wwMonkOrbOptions
    if PersonalResourceReskinPlus_Options and PersonalResourceReskinPlus_Options.RegisterSubOptions then
        PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomWindwalkerMonkOrbBar", _G.CustomWindwalkerMonkOrbBarOptions)
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






local function HideDefaultChiBar()
    local _, class = UnitClass("player")
    if class ~= "MONK" then return end
    local prdClassFrame = _G.prdClassFrame or (_G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.classWidgetFrame)
    if prdClassFrame then
        for _, child in ipairs({prdClassFrame:GetChildren()}) do
            if child and child:IsShown() then
                local n = child.GetName and child:GetName() or ""
                if n:find("Chi") or child.ChiOrb or child.FX or child.Blur or child.DepleteFlipbook then
                    child:Hide()
                    child:SetAlpha(0)
                    if type(child.UnregisterAllEvents) == "function" then child:UnregisterAllEvents() end
                    if type(child.SetScript) == "function" then child:SetScript("OnEvent", nil) end
                end
            end
        end
        prdClassFrame:Hide()
        prdClassFrame:SetAlpha(0)
        if type(prdClassFrame.UnregisterAllEvents) == "function" then prdClassFrame:UnregisterAllEvents() end
    end
end

local function ShowDefaultChiBar()
    local _, class = UnitClass("player")
    if class ~= "MONK" then return end
    local prdClassFrame = _G.prdClassFrame or (_G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.classWidgetFrame)
    if prdClassFrame then
        prdClassFrame:Show()
        prdClassFrame:SetAlpha(1)
    end
end

-- Helper functions to get PRD anchor frames (from soulstrackerveng.lua)
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
    if not CustomWindwalkerMonkOrbBarDB or not CustomWindwalkerMonkOrbBarDB.anchorToPRD then return nil end
    local target = CustomWindwalkerMonkOrbBarDB.anchorTarget or "HEALTH"
    return (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
end

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
    local prdClassFrame = _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.classWidgetFrame
    if CustomWindwalkerMonkOrbBarDB.hideWhenMounted and mounted then
        chiBar:Hide()
        ShowDefaultChiBar()
        if prdClassFrame then prdClassFrame:Show() end
        ApplyBarSettings()
        return
    end
    if CustomWindwalkerMonkOrbBarDB.enabled and ShouldShowChiBar() then
        HideDefaultChiBar()
        chiBar:Show()
        UpdateChi()
        C_Timer.After(0.05, HideDefaultChiBar)
        if prdClassFrame then prdClassFrame:Hide() end
        ApplyBarSettings()
    else
        chiBar:Hide()
        ShowDefaultChiBar()
        if prdClassFrame then prdClassFrame:Show() end
        ApplyBarSettings()
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
        local anchorFrame = GetPRDAnchorFrame()
        if anchorFrame then
            local pos = CustomWindwalkerMonkOrbBarDB.anchorPosition or "BELOW"
            local offset = CustomWindwalkerMonkOrbBarDB.anchorOffset or 10
            chiBar:ClearAllPoints()
            if pos == "ABOVE" then
                chiBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, offset)
            else
                chiBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -offset)
            end
        else
            chiBar:ClearAllPoints()
            chiBar:SetPoint("CENTER", UIParent, "CENTER", CustomWindwalkerMonkOrbBarDB.x, CustomWindwalkerMonkOrbBarDB.y)
        end
    else
        chiBar:ClearAllPoints()
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
        print("CustomWindwalkerMonkOrbBar 已鎖定。")
    elseif cmd == "unlock" then
        CustomWindwalkerMonkOrbBarDB.locked = false
        print("CustomWindwalkerMonkOrbBar 已解鎖，可拖曳移動。")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomWindwalkerMonkOrbBarDB.orbWidth = tonumber(arg1)
        CustomWindwalkerMonkOrbBarDB.orbHeight = tonumber(arg2)
        CreateOrbs()
        ApplyBarSettings()
        print("CustomWindwalkerMonkOrbBar 大小已設為 "..arg1.."x"..arg2)
    else
        print("/wworb lock | unlock | size <寬度> <高度>")
    end
end

ApplyBarSettings()
UpdateVisibility()
