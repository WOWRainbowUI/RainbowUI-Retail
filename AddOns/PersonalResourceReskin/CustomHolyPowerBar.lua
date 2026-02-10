-- CustomHolyPowerBar.lua

local NUM_HOLY_POWER = 5 
local HOLY_POWER_TYPE = Enum and Enum.PowerType and Enum.PowerType.HolyPower or 9 
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

CustomHolyPowerBarDB = CustomHolyPowerBarDB or {
    enabled = true,
    x = 0, y = -120, orbWidth = 24, orbHeight = 24, locked = false,
    anchorPosition = "BELOW", anchorOffset = 10,
    orbBgColor = {0, 0, 0, 0.5},
    gradientColor1 = {1, 0.85, 0.3, 1},
    gradientColor2 = {1, 0.85, 0.3, 1},
    hideOnMount = true,
}

local function HideDefaultHolyPowerBar()
    local _, class = UnitClass("player")
    if class ~= "PALADIN" then return end
    -- Hide PRD/Nameplate style resource orbs/runes/holy power
    local _, class = UnitClass("player")
    if _G.prdClassFrame and class ~= "ROGUE" then
        for i, child in ipairs({ _G.prdClassFrame:GetChildren() }) do
            if child and child:IsShown() then
                local n = child:GetName() or ""
                -- Hide any child that looks like a default orb/rune/holy power
                if n:find("HolyPower") or n:find("Rune") or child.HolyPowerFill or child.FX or child.Blur or child.DepleteFlipbook then
                    child:Hide()
                    child:SetAlpha(0)
                    if type(child.UnregisterAllEvents) == "function" then child:UnregisterAllEvents() end
                    if type(child.SetScript) == "function" then child:SetScript("OnEvent", nil) end
                end
            end
        end
       
        _G.prdClassFrame:Hide()
        _G.prdClassFrame:SetAlpha(0)
        if type(_G.prdClassFrame.UnregisterAllEvents) == "function" then _G.prdClassFrame:UnregisterAllEvents() end
        if type(_G.prdClassFrame.SetScript) == "function" then _G.prdClassFrame:SetScript("OnEvent", nil) end
    end
    -- PlayerFrame style
    local paladinBar = _G.PaladinPowerBar
    if paladinBar and type(paladinBar.Hide) == "function" then
        paladinBar:Hide()
        if type(paladinBar.SetAlpha) == "function" then paladinBar:SetAlpha(0) end
        if type(paladinBar.UnregisterAllEvents) == "function" then paladinBar:UnregisterAllEvents() end
        if type(paladinBar.SetScript) == "function" then paladinBar:SetScript("OnEvent", nil) end
    end
end

HideDefaultHolyPowerBar()

-- Only load for Paladin
local _, class = UnitClass("player")
if class ~= "PALADIN" then return end

local holyBar = CreateFrame("Frame", "CustomHolyPowerBar", UIParent)
holyBar:SetSize(180, 32)
holyBar:SetPoint("CENTER", UIParent, "CENTER", 0, -120)

holyBar.orbs = {}


for i = 1, NUM_HOLY_POWER do
    local orb = CreateFrame("Frame", nil, holyBar)
    orb:SetSize(CustomHolyPowerBarDB.orbWidth or 24, CustomHolyPowerBarDB.orbHeight or 24)
    orb:SetPoint("LEFT", holyBar, "LEFT", (i-1)*((CustomHolyPowerBarDB.orbWidth or 24)+6), 0)
    orb.bg = orb:CreateTexture(nil, "BACKGROUND")
    orb.bg:SetAllPoints()
    -- Fill texture only covers the filled portion (dynamic height)
    orb.fill = orb:CreateTexture(nil, "ARTWORK")
    orb.fill:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT")
    orb.fill:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT")
    orb.fill:SetHeight(CustomHolyPowerBarDB.orbHeight) -- will be set dynamically
    -- Add 1-pixel black border using four thin textures
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
    holyBar.orbs[i] = orb
end

-- Update function

local function UpdateHolyPower()
    local current = UnitPower("player", HOLY_POWER_TYPE)
    local bgR, bgG, bgB, bgA = SafeUnpackColor(CustomHolyPowerBarDB.orbBgColor, {0, 0, 0, 0.5})
    local c1R, c1G, c1B, c1A = SafeUnpackColor(CustomHolyPowerBarDB.gradientColor1, {1, 0.85, 0.3, 1})
    local c2R, c2G, c2B, c2A = SafeUnpackColor(CustomHolyPowerBarDB.gradientColor2, {1, 0.85, 0.3, 1})
    for i, orb in ipairs(holyBar.orbs) do
        orb.bg:SetColorTexture(bgR, bgG, bgB, bgA)
        local fillAmount = 0
        if i <= current then
            fillAmount = 1
        else
            fillAmount = 0
        end
        if fillAmount > 0 then
            orb.fill:Show()
            orb.fill:SetHeight((CustomHolyPowerBarDB.orbHeight or 24) * fillAmount)
            orb.fill:ClearAllPoints()
            orb.fill:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT")
            orb.fill:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT")
            if c1R == c2R and c1G == c2G and c1B == c2B and c1A == c2A then
                orb.fill:SetColorTexture(c1R, c1G, c1B, c1A)
            elseif orb.fill.SetGradient then
                orb.fill:SetGradient("HORIZONTAL",
                    CreateColor and CreateColor(c1R, c1G, c1B, c1A) or {c1R, c1G, c1B, c1A},
                    CreateColor and CreateColor(c2R, c2G, c2B, c2A) or {c2R, c2G, c2B, c2A})
            else
                orb.fill:SetColorTexture(c1R, c1G, c1B, c1A)
            end
            orb.fill:SetAlpha(1)
        else
            orb.fill:Hide()
        end
    end
end

-- Event handler
holyBar:RegisterEvent("UNIT_POWER_UPDATE")
holyBar:RegisterEvent("PLAYER_ENTERING_WORLD")
holyBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "HOLY_POWER" or powerType == HOLY_POWER_TYPE) then
            UpdateHolyPower()
        end
    else
        UpdateHolyPower()
    end
end)

-- Only show for Paladin
local function ShouldShowHolyBar()
    local _, class = UnitClass("player")
    return class == "PALADIN" and CustomHolyPowerBarDB.enabled
end

local function UpdateVisibility()
    if ShouldShowHolyBar() then
        holyBar:Show()
        UpdateHolyPower()
    else
        holyBar:Hide()
    end
end

holyBar:RegisterEvent("PLAYER_LOGIN")
holyBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
holyBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "HOLY_POWER" or powerType == HOLY_POWER_TYPE) then
            UpdateHolyPower()
        end
    else
        UpdateVisibility()
    end
end)

-- Update bar size and position
local function GetPRDHealthBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        return prd.HealthBarsContainer.healthBar
    end
    -- Fallback to old global if present
    return _G.PersonalResourceDisplayHealthBar
end

local function ApplyBarSettings()
    local spacing = 0
    local totalWidth = (CustomHolyPowerBarDB.orbWidth + spacing) * #holyBar.orbs - spacing
    holyBar:SetSize(totalWidth, CustomHolyPowerBarDB.orbHeight)
    holyBar:ClearAllPoints()
    local anchorFrame = CustomHolyPowerBarDB.anchorToPRD and GetPRDHealthBar() or nil
    if anchorFrame then
        if CustomHolyPowerBarDB.anchorPosition == "ABOVE" then
            holyBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, CustomHolyPowerBarDB.anchorOffset or 10)
        else
            holyBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -(CustomHolyPowerBarDB.anchorOffset or 10))
        end
    else
        holyBar:SetPoint("CENTER", UIParent, "CENTER", CustomHolyPowerBarDB.x or 0, CustomHolyPowerBarDB.y or 0)
    end
    local bgR, bgG, bgB, bgA = SafeUnpackColor(CustomHolyPowerBarDB.orbBgColor, {0, 0, 0, 0.5})
    local c1R, c1G, c1B, c1A = SafeUnpackColor(CustomHolyPowerBarDB.gradientColor1, {1, 0.85, 0.3, 1})
    local c2R, c2G, c2B, c2A = SafeUnpackColor(CustomHolyPowerBarDB.gradientColor2, {1, 0.85, 0.3, 1})
    local current = UnitPower("player", HOLY_POWER_TYPE)
    for i, orb in ipairs(holyBar.orbs) do
        orb:SetSize(CustomHolyPowerBarDB.orbWidth, CustomHolyPowerBarDB.orbHeight)
        orb:ClearAllPoints()
        orb:SetPoint("LEFT", holyBar, "LEFT", (i-1)*(CustomHolyPowerBarDB.orbWidth+spacing), 0)
        orb.bg:SetColorTexture(bgR, bgG, bgB, bgA)
        orb.fill:Show()
        if i <= current then
            orb.fill:SetAlpha(0.2)
            if c1R == c2R and c1G == c2G and c1B == c2B and c1A == c2A then
                orb.fill:SetColorTexture(c1R, c1G, c1B, c1A)
            elseif orb.fill.SetGradient then
                orb.fill:SetGradient("HORIZONTAL",
                    CreateColor and CreateColor(c1R, c1G, c1B, c1A) or {c1R, c1G, c1B, c1A},
                    CreateColor and CreateColor(c2R, c2G, c2B, c2A) or {c2R, c2G, c2B, c2A})
            else
                orb.fill:SetColorTexture(c1R, c1G, c1B, c1A)
            end
        else
            orb.fill:SetAlpha(1)
            if orb.fill.SetVertexColor then
                orb.fill:SetVertexColor(1, 1, 1, 1)
            end
            if c1R == c2R and c1G == c2G and c1B == c2B and c1A == c2A then
                orb.fill:SetColorTexture(c1R, c1G, c1B, c1A)
            elseif orb.fill.SetGradient then
                orb.fill:SetGradient("HORIZONTAL",
                    CreateColor and CreateColor(c1R, c1G, c1B, c1A) or {c1R, c1G, c1B, c1A},
                    CreateColor and CreateColor(c2R, c2G, c2B, c2A) or {c2R, c2G, c2B, c2A})
            else
                orb.fill:SetColorTexture(c1R, c1G, c1B, c1A)
            end
        end
        -- Update border positions
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
end

holyBar:SetMovable(true)
holyBar:EnableMouse(true)
holyBar:RegisterForDrag("LeftButton")
holyBar:SetScript("OnDragStart", function(self)
    if not CustomHolyPowerBarDB.locked then self:StartMoving() end
end)
holyBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomHolyPowerBarDB.x = x or 0
    CustomHolyPowerBarDB.y = y or 0
end)

-- Slash commands for config
SLASH_CUSTOMHOLYPOWERBAR1 = "/chpb"
SlashCmdList["CUSTOMHOLYPOWERBAR"] = function(msg)
    local cmd, arg1, arg2 = msg:match("^(%S*)%s*(%-?%d*)%s*(%-?%d*)$")
    cmd = cmd:lower() or ""
    if cmd == "lock" then
        CustomHolyPowerBarDB.locked = true
        print("自訂聖能條已鎖定。")
    elseif cmd == "unlock" then
        CustomHolyPowerBarDB.locked = false
        print("自訂聖能條已解鎖。拖曳以移動。")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomHolyPowerBarDB.orbWidth = tonumber(arg1)
        CustomHolyPowerBarDB.orbHeight = tonumber(arg2)
        ApplyBarSettings()
        print("自訂聖能條球體大小設定為 "..arg1.."x"..arg2)
    else
        print("/chpb lock | unlock | size <寬度> <高度>")
    end
end

if PersonalResourceReskinPlus_Options then
    if CustomHolyPowerBarDB.anchorToPRD == nil then
        CustomHolyPowerBarDB.anchorToPRD = false
    end
    local holyPowerOptions = {
        name = "|cFFF58CBA自訂聖能條|r",
        type = "group",
        order = 50,
        args = {
            enabled = {
                name = "啟用自訂聖能條",
                desc = "顯示自訂聖能條。停用此選項會改用預設的個人資源條聖能顯示。",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.enabled end,
                set = function(_, val) CustomHolyPowerBarDB.enabled = val UpdateVisibility() end,
                order = 0.1,
            },
            anchorToPRD = {
                name = "對齊到個人資源條",
                desc = "啟用時，聖能條會跟隨個人資源條的血條。X/Y 滑桿將停用。",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.anchorToPRD end,
                set = function(_, val) CustomHolyPowerBarDB.anchorToPRD = val ApplyBarSettings() end,
                order = 0.5,
            },
            x = {
                name = "水平偏移",
                desc = "水平位置偏移。",
                type = "range",
                min = -500, max = 500, step = 1,
                get = function() return CustomHolyPowerBarDB.x end,
                set = function(_, val) CustomHolyPowerBarDB.x = val ApplyBarSettings() end,
                order = 0.6,
                disabled = function() return CustomHolyPowerBarDB.anchorToPRD end,
            },
            y = {
                name = "垂直偏移",
                desc = "垂直位置偏移。",
                type = "range",
                min = -500, max = 500, step = 1,
                get = function() return CustomHolyPowerBarDB.y end,
                set = function(_, val) CustomHolyPowerBarDB.y = val ApplyBarSettings() end,
                order = 0.7,
                disabled = function() return CustomHolyPowerBarDB.anchorToPRD end,
            },
            lock = {
                name = "鎖定聖能條",
                desc = "鎖定或解鎖聖能條以供拖曳。",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.locked end,
                set = function(_, val)
                    CustomHolyPowerBarDB.locked = val
                    print("自訂聖能條 "..(val and "已鎖定。" or "已解鎖。拖曳以移動。"))
                end,
                order = 1,
            },
            orbWidth = {
                name = "球體寬度",
                desc = "設定每個聖能球的寬度。",
                type = "input",
                pattern = "^%d*%.?%d*$",
                get = function() return tostring(CustomHolyPowerBarDB.orbWidth) end,
                set = function(_, val)
                    local num = tonumber(val)
                    if num and num >= 10 and num <= 100 then
                        CustomHolyPowerBarDB.orbWidth = num
                        ApplyBarSettings()
                    end
                end,
                order = 2,
            },
            orbHeight = {
                name = "球體高度",
                desc = "設定每個聖能球的高度。",
                type = "input",
                pattern = "^%d*%.?%d*$",
                get = function() return tostring(CustomHolyPowerBarDB.orbHeight) end,
                set = function(_, val)
                    local num = tonumber(val)
                    if num and num >= 10 and num <= 100 then
                        CustomHolyPowerBarDB.orbHeight = num
                        ApplyBarSettings()
                    end
                end,
                order = 3,
            },
            orbBgColor = {
                name = "背景顏色",
                desc = "設定每個聖能球的背景顏色（漸層填充後方）。",
                type = "color",
                hasAlpha = true,
                order = 4,
                get = function() return SafeUnpackColor(CustomHolyPowerBarDB.orbBgColor, {0, 0, 0, 0.5}) end,
                set = function(_, r, g, b, a)
                    CustomHolyPowerBarDB.orbBgColor = {r, g, b, a}
                    ApplyBarSettings()
                end,
            },
            gradientColor1 = {
                name = "漸層起始色",
                desc = "設定聖能球填充的漸層起始顏色。",
                type = "color",
                hasAlpha = true,
                order = 5,
                get = function() return SafeUnpackColor(CustomHolyPowerBarDB.gradientColor1, {1, 0.85, 0.3, 1}) end,
                set = function(_, r, g, b, a)
                    CustomHolyPowerBarDB.gradientColor1 = {r, g, b, a}
                    ApplyBarSettings()
                end,
            },
            gradientColor2 = {
                name = "漸層結束色",
                desc = "設定聖能球填充的漸層結束顏色。",
                type = "color",
                hasAlpha = true,
                order = 6,
                get = function() return SafeUnpackColor(CustomHolyPowerBarDB.gradientColor2, {1, 0.85, 0.3, 1}) end,
                set = function(_, r, g, b, a)
                    CustomHolyPowerBarDB.gradientColor2 = {r, g, b, a}
                    ApplyBarSettings()
                end,
            },
            anchorPosition = {
                name = "對齊位置",
                desc = "選擇聖能條顯示在個人資源條的上方或下方。",
                type = "select",
                values = { ABOVE = "上方", BELOW = "下方" },
                get = function() return CustomHolyPowerBarDB.anchorPosition or "BELOW" end,
                set = function(_, val) CustomHolyPowerBarDB.anchorPosition = val ApplyBarSettings() end,
                order = 0.55,
                disabled = function() return not CustomHolyPowerBarDB.anchorToPRD end,
            },
            anchorOffset = {
                name = "位置偏移",
                desc = "與個人資源條的像素偏移（可為小數）。",
                type = "input",
                pattern = "^-?%d*%.?%d*$",
                get = function() return tostring(CustomHolyPowerBarDB.anchorOffset or 10) end,
                set = function(_, val)
                    local num = tonumber(val)
                    if num then
                        CustomHolyPowerBarDB.anchorOffset = num
                        ApplyBarSettings()
                    end
                end,
                order = 0.56,
                disabled = function() return not CustomHolyPowerBarDB.anchorToPRD end,
            },
            hideOnMount = {
                name = "騎乘時隱藏",
                desc = "騎乘坐騎時自動隱藏自訂聖能條。",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.hideOnMount end,
                set = function(_, val)
                    CustomHolyPowerBarDB.hideOnMount = val
                    -- 立即套用
                    local chpb = _G.CustomHolyPowerBar
                    if chpb then
                        if val and IsMounted() then
                            chpb:Hide()
                        else
                            chpb:Show()
                        end
                    end
                end,
                order = 0.57,
            },
        },
    }
    PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomHolyPowerBar", holyPowerOptions)
end

local function OnLoginOrReload()
    ApplyBarSettings()
end
holyBar:RegisterEvent("PLAYER_LOGIN")
holyBar:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        OnLoginOrReload()
    end
end)

ApplyBarSettings()
UpdateVisibility()


local function HookPRDAnchor()
    local anchorFrame = GetPRDHealthBar()
    if not anchorFrame then return end
    if holyBar._prdhook then return end
    holyBar._prdhook = true
    if not anchorFrame._chpb_hooks then anchorFrame._chpb_hooks = {} end
    if not anchorFrame._chpb_hooks.SetPoint then
        anchorFrame._chpb_hooks.SetPoint = true
        hooksecurefunc(anchorFrame, "SetPoint", function()
            if CustomHolyPowerBarDB.anchorToPRD then
                ApplyBarSettings()
            end
        end)
    end
    if not anchorFrame._chpb_hooks.SetSize then
        anchorFrame._chpb_hooks.SetSize = true
        hooksecurefunc(anchorFrame, "SetSize", function()
            if CustomHolyPowerBarDB.anchorToPRD then
                ApplyBarSettings()
            end
        end)
    end
    if not anchorFrame._chpb_hooks.SetScale then
        anchorFrame._chpb_hooks.SetScale = true
        hooksecurefunc(anchorFrame, "SetScale", function()
            if CustomHolyPowerBarDB.anchorToPRD then
                ApplyBarSettings()
            end
        end)
    end
end

local function TryHookPRDAnchor()
    if GetPRDHealthBar() then
        HookPRDAnchor()
    else
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self)
            if GetPRDHealthBar() then
                HookPRDAnchor()
                self:UnregisterAllEvents()
            end
        end)
    end
end

TryHookPRDAnchor()
