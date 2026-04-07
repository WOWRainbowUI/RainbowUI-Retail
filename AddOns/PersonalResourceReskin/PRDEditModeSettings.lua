--========================================================--
-- PRDEditModeSettings
-- Registers a LibEditMode anchor for PersonalResourceReskin
-- settings, anchored near the PRD frame in Edit Mode.
-- The scrollable dialog provides all PRD bar configurations.
--========================================================--

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local LibEditMode = LibStub and LibStub("LibEditMode", true)

if not LibEditMode or not LSM then return end

local anchor
local registered = false

local DEFAULT_POS = { point = "CENTER", x = 0, y = -80 }

local function GetProfile()
    return PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
end

local function ApplyReskin()
    local prd = _G.PersonalResourceDisplayFrame
    if not prd then return end
    -- Trigger the existing ApplyReskinToPRD via event
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- Direct call: the function is local in PersonalResourceReskin.lua,
    -- so we use the profile callback path instead
    if PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.callbacks then
        PersonalResourceReskin.db.callbacks:Fire("OnProfileChanged", PersonalResourceReskin.db)
    end
end

-- Build SharedMedia texture list for dropdowns
local function GetSMTextureValues()
    local vals = {}
    for _, name in ipairs(LSM:List("statusbar")) do
        vals[#vals + 1] = { text = name, value = name }
    end
    return vals
end

local function RegisterPRDEditMode()
    if registered then return end
    registered = true

    local profile = GetProfile()
    if not profile then return end

    local prd = _G.PersonalResourceDisplayFrame
    if not prd then return end

    -- Create anchor frame that sits directly below the PRD edit mode box
    anchor = CreateFrame("Frame", "PRDReskinSettingsAnchor", UIParent)
    anchor:SetSize(prd:GetWidth() or 220, 20)
    anchor:SetPoint("TOP", prd, "BOTTOM", 0, -4)

    -- Keep width synced with PRD
    local syncFrame = CreateFrame("Frame")
    syncFrame:SetScript("OnUpdate", function()
        if not anchor or not prd or not prd:IsVisible() then return end
        local w = prd:GetWidth()
        if w and w > 0 and math.abs((anchor:GetWidth() or 0) - w) > 0.5 then
            anchor:SetWidth(w)
        end
    end)

    -- Save position callback (LibEditMode requires one, but we re-anchor every time)
    local function SavePos(frame, layoutName, pt, fx, fy)
        -- no-op: always anchored to PRD
    end

    LibEditMode:AddFrame(anchor, SavePos, DEFAULT_POS, "PRD Settings")

    -- Re-anchor after Edit Mode layout changes or PRD moves
    LibEditMode:RegisterCallback("layout", function()
        if anchor and prd then
            anchor:ClearAllPoints()
            anchor:SetPoint("TOP", prd, "BOTTOM", 0, -4)
        end
    end)
    LibEditMode:RegisterCallback("enter", function()
        if anchor and prd then
            anchor:ClearAllPoints()
            anchor:SetPoint("TOP", prd, "BOTTOM", 0, -4)
            anchor:SetWidth(prd:GetWidth() or 220)
        end
    end)

    -- Helper: refresh bars after a setting change
    local function Refresh()
        if PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.callbacks then
            PersonalResourceReskin.db.callbacks:Fire("OnProfileChanged", PersonalResourceReskin.db)
        end
    end

    LibEditMode:AddFrameSettings(anchor, {
        -- =====================
        -- TEXTURES
        -- =====================
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "Bar Texture",
            height = 300,
            get = function()
                local p = GetProfile()
                return p and p.texture or "White8x8"
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.texture = v; Refresh() end
            end,
            values = GetSMTextureValues(),
        },
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "Absorb Texture",
            height = 300,
            get = function()
                local p = GetProfile()
                return p and p.absorbTexture or "White8x8"
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.absorbTexture = v; Refresh() end
            end,
            values = GetSMTextureValues(),
        },
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "Alt Power Texture",
            height = 300,
            get = function()
                local p = GetProfile()
                return p and p.altTexture or p.texture or "White8x8"
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.altTexture = v; Refresh() end
            end,
            values = GetSMTextureValues(),
        },
        -- =====================
        -- SIZES
        -- =====================
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "Width Mode",
            get = function()
                local p = GetProfile()
                return p and p.widthMode or "MANUAL"
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.widthMode = v; Refresh() end
            end,
            values = {
                { text = "Manual", value = "MANUAL" },
                { text = "Match Essential Viewer", value = "ESSENTIAL" },
                { text = "Match Utility Viewer", value = "UTILITY" },
            },
        },
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "Stagger Bar Sync Position",
            get = function()
                local p = GetProfile()
                return p and p.staggerSyncAnchor or "ABOVE"
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.staggerSyncAnchor = v; Refresh() end
            end,
            values = {
                { text = "Above PRD", value = "ABOVE" },
                { text = "Below PRD", value = "BELOW" },
            },
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Stagger Bar Sync Offset",
            default = 2,
            get = function()
                local p = GetProfile()
                return p and p.staggerSyncOffset or 2
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.staggerSyncOffset = v; Refresh() end
            end,
            minValue = -20, maxValue = 40, valueStep = 1,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Overall Frame Width",
            default = 220,
            get = function()
                local p = GetProfile()
                return p and p.frameWidth or 220
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.frameWidth = v; Refresh() end
            end,
            minValue = 50, maxValue = 600, valueStep = 1,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Power Bar Width",
            default = 220,
            get = function()
                local p = GetProfile()
                return p and p.width or 220
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.width = v; Refresh() end
            end,
            minValue = 50, maxValue = 600, valueStep = 1,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Power Bar Height",
            default = 10,
            get = function()
                local p = GetProfile()
                return p and p.powerBarHeight or 10
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.powerBarHeight = v; Refresh() end
            end,
            minValue = 3, maxValue = 50, valueStep = 1,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Health Bar Height",
            default = 24,
            get = function()
                local p = GetProfile()
                return p and p.healthHeight or 24
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.healthHeight = v; Refresh() end
            end,
            minValue = 6, maxValue = 100, valueStep = 1,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Health Text Scale",
            default = 100,
            get = function()
                local p = GetProfile()
                return math.floor((p and p.healthTextScale or 1) * 100 + 0.5)
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.healthTextScale = v / 100; Refresh() end
            end,
            minValue = 10, maxValue = 200, valueStep = 5,
            formatter = function(v) return v .. "%" end,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Alt Power Bar Width",
            default = 220,
            get = function()
                local p = GetProfile()
                return p and p.altPowerBarWidth or 220
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then
                    p.altPowerBarWidth = v
                    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
                    Refresh()
                end
            end,
            minValue = 50, maxValue = 600, valueStep = 1,
        },
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Alt Power Bar Height",
            default = 20,
            get = function()
                local p = GetProfile()
                return p and p.altPowerBarHeight or 20
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then
                    p.altPowerBarHeight = v
                    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
                    Refresh()
                end
            end,
            minValue = 5, maxValue = 100, valueStep = 1,
        },
        -- =====================
        -- COLORS
        -- =====================
        {
            kind = LibEditMode.SettingType.Checkbox,
            name = "Use Class Color (Health)",
            default = false,
            get = function()
                local p = GetProfile()
                return p and p.useClassColor or false
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.useClassColor = v; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Health Gradient Color 1",
            hasOpacity = true,
            default = CreateColor(0.2, 0.8, 0.2, 1),
            get = function()
                local p = GetProfile()
                local c = p and p.healthGradientColor1 or {0.2, 0.8, 0.2, 1}
                return CreateColor(c[1], c[2], c[3], c[4] or 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.healthGradientColor1 = {r, g, b, a or 1}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Health Gradient Color 2",
            hasOpacity = true,
            default = CreateColor(1, 1, 0.2, 1),
            get = function()
                local p = GetProfile()
                local c = p and p.healthGradientColor2 or {1, 1, 0.2, 1}
                return CreateColor(c[1], c[2], c[3], c[4] or 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.healthGradientColor2 = {r, g, b, a or 1}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Health Background",
            hasOpacity = true,
            default = CreateColor(0, 0, 0, 0.5),
            get = function()
                local p = GetProfile()
                local c = p and p.healthBgColor or {0, 0, 0, 0.5}
                return CreateColor(c[1], c[2], c[3], c[4] or 0.5)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.healthBgColor = {r, g, b, a or 0.5}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.Checkbox,
            name = "Power Bar Gradient",
            default = true,
            get = function()
                local p = GetProfile()
                local _, class = UnitClass("player")
                local enabled = p and p.prdGradientEnabled and p.prdGradientEnabled[class]
                return enabled ~= false
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then
                    local _, class = UnitClass("player")
                    p.prdGradientEnabled = p.prdGradientEnabled or {}
                    p.prdGradientEnabled[class] = v
                    Refresh()
                end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Power Gradient Color 1",
            hasOpacity = true,
            default = CreateColor(0, 0.8, 1, 1),
            get = function()
                local p = GetProfile()
                local c = p and p.prdGradientColor1 or {0, 0.8, 1, 1}
                return CreateColor(c[1], c[2], c[3], c[4] or 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.prdGradientColor1 = {r, g, b, a or 1}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Power Gradient Color 2",
            hasOpacity = true,
            default = CreateColor(0, 0.2, 1, 1),
            get = function()
                local p = GetProfile()
                local c = p and p.prdGradientColor2 or {0, 0.2, 1, 1}
                return CreateColor(c[1], c[2], c[3], c[4] or 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.prdGradientColor2 = {r, g, b, a or 1}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Power Background",
            hasOpacity = true,
            default = CreateColor(0, 0, 0, 0.5),
            get = function()
                local p = GetProfile()
                local c = p and p.powerBgColor or {0, 0, 0, 0.5}
                return CreateColor(c[1], c[2], c[3], c[4] or 0.5)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.powerBgColor = {r, g, b, a or 0.5}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.Checkbox,
            name = "Alt Power Gradient",
            default = true,
            get = function()
                local p = GetProfile()
                local _, class = UnitClass("player")
                local enabled = p and p.altPowerGradientEnabled and p.altPowerGradientEnabled[class]
                return enabled ~= false
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then
                    local _, class = UnitClass("player")
                    p.altPowerGradientEnabled = p.altPowerGradientEnabled or {}
                    p.altPowerGradientEnabled[class] = v
                    Refresh()
                end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Alt Power Gradient 1",
            hasOpacity = true,
            default = CreateColor(0.6, 0.2, 1, 1),
            get = function()
                local p = GetProfile()
                local c = p and p.altPowerGradientColor1 or {0.6, 0.2, 1, 1}
                return CreateColor(c[1], c[2], c[3], c[4] or 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.altPowerGradientColor1 = {r, g, b, a or 1}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Alt Power Gradient 2",
            hasOpacity = true,
            default = CreateColor(1, 0.2, 0.8, 1),
            get = function()
                local p = GetProfile()
                local c = p and p.altPowerGradientColor2 or {1, 0.2, 0.8, 1}
                return CreateColor(c[1], c[2], c[3], c[4] or 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.altPowerGradientColor2 = {r, g, b, a or 1}; Refresh() end
            end,
        },
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "Alt Power Background",
            hasOpacity = true,
            default = CreateColor(0, 0, 0, 0.5),
            get = function()
                local p = GetProfile()
                local c = p and p.altPowerBgColor or {0, 0, 0, 0.5}
                return CreateColor(c[1], c[2], c[3], c[4] or 0.5)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b, a = color:GetRGBA()
                local p = GetProfile()
                if p then p.altPowerBgColor = {r, g, b, a or 0.5}; Refresh() end
            end,
        },
        -- =====================
        -- MISC
        -- =====================
        {
            kind = LibEditMode.SettingType.Checkbox,
            name = "Hide PRD When Mounted",
            default = true,
            get = function()
                local p = GetProfile()
                return p and p.hideOnMount ~= false
            end,
            set = function(_, v)
                local p = GetProfile()
                if p then p.hideOnMount = v end
            end,
        },
    })
end

-- Defer registration until after PersonalResourceReskin:OnInitialize has run
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(0.3, RegisterPRDEditMode)
end)
