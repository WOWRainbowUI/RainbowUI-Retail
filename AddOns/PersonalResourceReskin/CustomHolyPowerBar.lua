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
        print("CustomHolyPowerBar locked.")
    elseif cmd == "unlock" then
        CustomHolyPowerBarDB.locked = false
        print("CustomHolyPowerBar unlocked. Drag to move.")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomHolyPowerBarDB.orbWidth = tonumber(arg1)
        CustomHolyPowerBarDB.orbHeight = tonumber(arg2)
        ApplyBarSettings()
        print("CustomHolyPowerBar orb size set to "..arg1.."x"..arg2)
    else
        print("/chpb lock | unlock | size <width> <height>")
    end
end



if PersonalResourceReskinPlus_Options then
    if CustomHolyPowerBarDB.anchorToPRD == nil then CustomHolyPowerBarDB.anchorToPRD = false end
    local holyPowerOptions = {
        name = "|cFFF58CBACustom Holy Power Bar|r",
        type = "group",
        order = 50,
        args = {
            enabled = {
                name = "Enable Custom Holy Power Bar",
                desc = "Show the custom Holy Power bar. Disable to use default PRD Holy Power.",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.enabled end,
                set = function(_, val)
                    CustomHolyPowerBarDB.enabled = val
                    UpdateVisibility()
                end,
                order = 0.1,
            },
            anchorToPRD = {
                name = "Anchor to Personal Resource Display",
                desc = "When enabled, the Holy Power bar will follow the Personal Resource Display health bar. X/Y sliders are disabled.",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.anchorToPRD end,
                set = function(_, val)
                    CustomHolyPowerBarDB.anchorToPRD = val
                    ApplyBarSettings()
                end,
                order = 0.5,
            },
            x = {
                name = "X Position",
                desc = "Horizontal position offset.",
                type = "range",
                min = -500, max = 500, step = 1,
                get = function() return CustomHolyPowerBarDB.x end,
                set = function(_, val)
                    CustomHolyPowerBarDB.x = val
                    ApplyBarSettings()
                end,
                order = 0.6,
                disabled = function() return CustomHolyPowerBarDB.anchorToPRD end,
            },
            y = {
                name = "Y Position",
                desc = "Vertical position offset.",
                type = "range",
                min = -500, max = 500, step = 1,
                get = function() return CustomHolyPowerBarDB.y end,
                set = function(_, val)
                    CustomHolyPowerBarDB.y = val
                    ApplyBarSettings()
                end,
                order = 0.7,
                disabled = function() return CustomHolyPowerBarDB.anchorToPRD end,
            },
            lock = {
                name = "Lock Bar",
                desc = "Lock or unlock the holy power bar for dragging.",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.locked end,
                set = function(_, val)
                    CustomHolyPowerBarDB.locked = val
                    print("CustomHolyPowerBar "..(val and "locked." or "unlocked. Drag to move."))
                end,
                order = 1,
            },
            orbWidth = {
                name = "Orb Width",
                desc = "Set the width of each holy power orb.",
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
                name = "Orb Height",
                desc = "Set the height of each holy power orb.",
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
                name = "Holybar Background Color",
                desc = "Set the background color for each holy power orb (behind the gradient fill).",
                type = "color",
                hasAlpha = true,
                order = 4,
                get = function()
                    return SafeUnpackColor(CustomHolyPowerBarDB.orbBgColor, {0, 0, 0, 0.5})
                end,
                set = function(_, r, g, b, a)
                    CustomHolyPowerBarDB.orbBgColor = {r, g, b, a}
                    ApplyBarSettings()
                end,
            },
            gradientColor1 = {
                name = "Holybar Gradient Start",
                desc = "Set the gradient start color for the holy power orb fill.",
                type = "color",
                hasAlpha = true,
                order = 5,
                get = function()
                    return SafeUnpackColor(CustomHolyPowerBarDB.gradientColor1, {1, 0.85, 0.3, 1})
                end,
                set = function(_, r, g, b, a)
                    CustomHolyPowerBarDB.gradientColor1 = {r, g, b, a}
                    ApplyBarSettings()
                end,
            },
            gradientColor2 = {
                name = "Holybar Gradient End",
                desc = "Set the gradient end color for the holy power orb fill.",
                type = "color",
                hasAlpha = true,
                order = 6,
                get = function()
                    return SafeUnpackColor(CustomHolyPowerBarDB.gradientColor2, {1, 0.85, 0.3, 1})
                end,
                set = function(_, r, g, b, a)
                    CustomHolyPowerBarDB.gradientColor2 = {r, g, b, a}
                    ApplyBarSettings()
                end,
            },
            anchorPosition = {
                name = "Anchor Position",
                desc = "Choose whether the bar appears above or below the Personal Resource Display.",
                type = "select",
                values = { ABOVE = "Above", BELOW = "Below" },
                get = function() return CustomHolyPowerBarDB.anchorPosition or "BELOW" end,
                set = function(_, val)
                    CustomHolyPowerBarDB.anchorPosition = val
                    ApplyBarSettings()
                end,
                order = 0.55,
                disabled = function() return not CustomHolyPowerBarDB.anchorToPRD end,
            },
            anchorOffset = {
                name = "Anchor Offset",
                desc = "Offset in pixels from the Personal Resource Display (can be decimal).",
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
                name = "Hide when Mounted",
                desc = "Automatically hide the CustomHolyPowerBar when mounted.",
                type = "toggle",
                get = function() return CustomHolyPowerBarDB.hideOnMount end,
                set = function(_, val)
                    CustomHolyPowerBarDB.hideOnMount = val
                    -- Apply immediately
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
