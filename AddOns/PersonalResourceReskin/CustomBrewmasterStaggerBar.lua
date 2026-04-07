--========================================================--
-- CustomBrewmasterStaggerBar
-- Replaces the default AlternatePowerBar for Brewmaster Monk
-- with a custom StatusBar that uses Blizzard's stagger API
-- and PowerBarColor coloring (green / yellow / red).
--========================================================--

local STAGGER_STATES = {
    RED    = { key = "red",    threshold = 0.60 },
    YELLOW = { key = "yellow", threshold = 0.30 },
    GREEN  = { key = "green" },
}

local STRATA_LIST = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG" }
local STRATA_MAP = {}
for i, v in ipairs(STRATA_LIST) do STRATA_MAP[v] = i end

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local LibEditMode = LibStub and LibStub("LibEditMode", true)

------------------------------------------------------------
-- Spec detection
------------------------------------------------------------
local function IsBrewmasterMonk()
    local _, class = UnitClass("player")
    if class ~= "MONK" then return false end
    local spec = GetSpecialization()
    if not spec then return false end
    return GetSpecializationInfo(spec) == 268
end

------------------------------------------------------------
-- State
------------------------------------------------------------
local barFrame          -- the custom StatusBar
local bgTexture         -- background texture
local borderFrame       -- border frame
local staggerText       -- FontString for stagger value
local staggerStateKey   -- current color state key
local blizzBarHidden = false
local editModeRegistered = false
local EvaluateVisibility  -- forward declaration (used in RegisterEditMode before definition)

local DEFAULT_POS = { point = "CENTER", x = 0, y = -150 }
local DEFAULT_WIDTH = 200
local DEFAULT_HEIGHT = 15

------------------------------------------------------------
-- Hide/restore the Blizzard AlternatePowerBar
------------------------------------------------------------
local function HideBlizzardAltBar()
    local prd = _G.PersonalResourceDisplayFrame
    if not prd or not prd.AlternatePowerBar then return end
    local bar = prd.AlternatePowerBar
    bar:Hide()
    bar:SetAlpha(0)
    if not bar.__ccmBrewHidden then
        bar.__ccmBrewHidden = true
        hooksecurefunc(bar, "Show", function(self)
            if IsBrewmasterMonk() then
                self:Hide()
                self:SetAlpha(0)
            end
        end)
    end
    blizzBarHidden = true
end

local function RestoreBlizzardAltBar()
    if not blizzBarHidden then return end
    local prd = _G.PersonalResourceDisplayFrame
    if not prd or not prd.AlternatePowerBar then return end
    prd.AlternatePowerBar:SetAlpha(1)
    blizzBarHidden = false
end

------------------------------------------------------------
-- Get saved DB
------------------------------------------------------------
local function GetSavedDB()
    CustomBrewmasterStaggerBarDB = CustomBrewmasterStaggerBarDB or {}
    return CustomBrewmasterStaggerBarDB
end

------------------------------------------------------------
-- Get the color for a stagger stage from DB or Blizzard
------------------------------------------------------------
local function GetStaggerColor(stateKey)
    local db = GetSavedDB()
    local custom = db.colors and db.colors[stateKey]
    if custom then
        return custom.r, custom.g, custom.b
    end
    local artInfo = PowerBarColor["STAGGER"]
    local colorInfo = artInfo and artInfo[stateKey]
    if colorInfo then
        return colorInfo.r, colorInfo.g, colorInfo.b
    end
    return 0.5, 1, 0.5
end

------------------------------------------------------------
-- Apply the current SharedMedia texture
------------------------------------------------------------
local lastTexKey
local function RefreshBarTexture()
    if not barFrame then return end
    local db = GetSavedDB()
    local texKey = db.texture
    if not texKey then
        -- Fall back to PRD profile texture
        local profile = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
        texKey = profile and (profile.altTexture or profile.texture)
    end
    if texKey == lastTexKey then return end
    lastTexKey = texKey
    local tex = (LSM and texKey and LSM:Fetch("statusbar", texKey))
              or "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status-Rectangle"
    barFrame:SetStatusBarTexture(tex)
    local sbTex = barFrame:GetStatusBarTexture()
    if sbTex then
        sbTex:SetTexelSnappingBias(0)
        sbTex:SetSnapToPixelGrid(false)
    end
    staggerStateKey = nil -- force color reapply
end

------------------------------------------------------------
-- Apply frame strata from DB
------------------------------------------------------------
local function RefreshStrata()
    if not barFrame then return end
    local db = GetSavedDB()
    barFrame:SetFrameStrata(db.strata or "MEDIUM")
end

------------------------------------------------------------
-- Refresh background color + texture from DB
------------------------------------------------------------
local lastBgTexKey
local function RefreshBgColor()
    if not bgTexture then return end
    local db = GetSavedDB()

    local c = db.bgColor
    local r = c and c.r or 0.2
    local g = c and c.g or 0.2
    local b = c and c.b or 0.2
    local a = (c and c.a) or 0.65

    -- SharedMedia texture: use SetTexture + SetVertexColor for tint
    local texKey = db.bgTexture
    if texKey and LSM then
        local path = LSM:Fetch("statusbar", texKey)
        if path then
            bgTexture:SetTexture(path)
            bgTexture:SetTexelSnappingBias(0)
            bgTexture:SetSnapToPixelGrid(false)
            bgTexture:SetVertexColor(r, g, b, a)
            lastBgTexKey = texKey
            return
        end
    end

    -- Flat color mode: SetColorTexture sets color directly, reset vertex tint
    bgTexture:SetColorTexture(r, g, b, a)
    bgTexture:SetVertexColor(1, 1, 1, 1)
    lastBgTexKey = nil
end

------------------------------------------------------------
-- Refresh text settings
------------------------------------------------------------
local function RefreshTextSettings()
    if not staggerText then return end
    local db = GetSavedDB()
    local fontSize = db.fontSize or 12
    local fontPath = STANDARD_TEXT_FONT
    if LSM and db.font then
        fontPath = LSM:Fetch("font", db.font) or STANDARD_TEXT_FONT
    end
    staggerText:SetFont(fontPath, fontSize, "OUTLINE")
    local tc = db.textColor
    if tc then
        staggerText:SetTextColor(tc.r or 1, tc.g or 1, tc.b or 1, tc.a or 1)
    else
        staggerText:SetTextColor(1, 1, 1, 1)
    end
    staggerText:ClearAllPoints()
    staggerText:SetPoint("CENTER", barFrame, "CENTER", db.textOffsetX or 0, db.textOffsetY or 0)
    if db.hideText then
        staggerText:Hide()
    else
        staggerText:Show()
    end
end

------------------------------------------------------------
-- Anchor the custom bar
------------------------------------------------------------
local function AnchorCustomBar()
    if not barFrame then return end
    if InCombatLockdown() then return end

    local db = GetSavedDB()
    local w = db.width or DEFAULT_WIDTH
    local h = db.height or DEFAULT_HEIGHT
    -- Width sync: match cooldown viewer width if widthMode is not MANUAL
    local profile = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local widthMode = profile and profile.widthMode or "MANUAL"
    if widthMode ~= "MANUAL" then
        local viewerName = (widthMode == "ESSENTIAL") and "EssentialCooldownViewer" or "UtilityCooldownViewer"
        local viewer = _G[viewerName]
        if viewer and viewer.GetWidth then
            local vw = viewer:GetWidth()
            if vw and vw > 10 then w = vw end
        end
    end
    barFrame:SetSize(w, h)

    if editModeRegistered then
        if bgTexture then bgTexture:SetAllPoints(barFrame) end
        return
    end

    local saved = db.position
    local pt = (saved and saved.point) or DEFAULT_POS.point
    local x  = (saved and saved.x) or DEFAULT_POS.x
    local y  = (saved and saved.y) or DEFAULT_POS.y

    barFrame:ClearAllPoints()
    barFrame:SetPoint(pt, UIParent, pt, x, y)
    if bgTexture then bgTexture:SetAllPoints(barFrame) end
end

------------------------------------------------------------
-- Update stagger value + color + text
------------------------------------------------------------
local function UpdateStaggerBar()
    if not barFrame or not barFrame:IsShown() then return end

    local stagger   = tonumber(UnitStagger("player")) or 0
    local maxHealth = tonumber(UnitHealthMax("player")) or 1
    if maxHealth == 0 then maxHealth = 1 end

    barFrame:SetMinMaxValues(0, maxHealth)
    barFrame:SetValue(stagger)

    -- Determine color state
    local pct = stagger / maxHealth
    local newKey
    if pct >= STAGGER_STATES.RED.threshold then
        newKey = STAGGER_STATES.RED.key
    elseif pct >= STAGGER_STATES.YELLOW.threshold then
        newKey = STAGGER_STATES.YELLOW.key
    else
        newKey = STAGGER_STATES.GREEN.key
    end

    if newKey ~= staggerStateKey then
        staggerStateKey = newKey
        local r, g, b = GetStaggerColor(newKey)
        barFrame:SetStatusBarColor(r, g, b)
    end

    -- Update text
    if staggerText and staggerText:IsShown() then
        if type(AbbreviateNumbers) == "function" then
            staggerText:SetText(AbbreviateNumbers(stagger))
        else
            staggerText:SetText(string.format("%.0f", stagger))
        end
    end
end

------------------------------------------------------------
-- Create the bar
------------------------------------------------------------
local function CreateCustomStaggerBar()
    if barFrame then return end

    local db = GetSavedDB()

    barFrame = CreateFrame("StatusBar", "CustomBrewmasterStaggerBar", UIParent)
    barFrame:SetSize(db.width or DEFAULT_WIDTH, db.height or DEFAULT_HEIGHT)
    barFrame:SetFrameStrata(db.strata or "MEDIUM")
    barFrame:SetFrameLevel(100)

    -- Background
    bgTexture = barFrame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints()
    RefreshBgColor()

    -- StatusBar texture via SharedMedia
    local texKey = db.texture
    if not texKey then
        local profile = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
        texKey = profile and (profile.altTexture or profile.texture)
    end
    local tex = (LSM and texKey and LSM:Fetch("statusbar", texKey))
              or "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status-Rectangle"
    barFrame:SetStatusBarTexture(tex)
    local sbTex = barFrame:GetStatusBarTexture()
    if sbTex then
        sbTex:SetTexelSnappingBias(0)
        sbTex:SetSnapToPixelGrid(false)
    end

    -- 1px solid border
    borderFrame = CreateFrame("Frame", nil, barFrame, "BackdropTemplate")
    borderFrame:SetPoint("TOPLEFT", -1, 1)
    borderFrame:SetPoint("BOTTOMRIGHT", 1, -1)
    borderFrame:SetFrameLevel(barFrame:GetFrameLevel() + 5)
    borderFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    borderFrame:SetBackdropBorderColor(0, 0, 0, 1)

    -- Stagger text (replaces Core.lua StaggerMonitor text)
    -- Parent to borderFrame so text renders above the border edge
    staggerText = borderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    staggerText:SetPoint("CENTER", barFrame, "CENTER")
    staggerText:SetDrawLayer("OVERLAY", 7)
    RefreshTextSettings()

    barFrame:SetMinMaxValues(0, 1)
    barFrame:SetValue(0)
    barFrame:Hide()

    _G.CustomBrewmasterStaggerBar = barFrame

    -- Global function for width sync from PRD ticker
    _G.CustomBrewmasterStaggerBar_SetSyncWidth = function(w)
        if not barFrame or not w or w < 10 then return end
        if InCombatLockdown() then
            -- In combat, only update width (no re-anchoring)
            barFrame:SetWidth(w)
            return
        end
        barFrame:SetWidth(w)
        if bgTexture then bgTexture:SetAllPoints(barFrame) end
        if borderFrame then
            borderFrame:ClearAllPoints()
            borderFrame:SetPoint("TOPLEFT", barFrame, "TOPLEFT", -1, 1)
            borderFrame:SetPoint("BOTTOMRIGHT", barFrame, "BOTTOMRIGHT", 1, -1)
        end
        if staggerText then
            local db = GetSavedDB()
            staggerText:ClearAllPoints()
            staggerText:SetPoint("CENTER", barFrame, "CENTER", db.textOffsetX or 0, db.textOffsetY or 0)
        end
        -- Anchor to PRD so the bar follows the nameplate
        local prd = _G.PersonalResourceDisplayFrame
        local profile = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
        local anchor = profile and profile.staggerSyncAnchor or "ABOVE"
        local offset = profile and profile.staggerSyncOffset or 2
        if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar and anchor == "ABOVE" then
            barFrame:ClearAllPoints()
            barFrame:SetPoint("BOTTOM", prd.HealthBarsContainer.healthBar, "TOP", 0, offset)
        elseif prd and prd.PowerBar then
            barFrame:ClearAllPoints()
            barFrame:SetPoint("TOP", prd.PowerBar, "BOTTOM", 0, -offset)
        end
    end

    -- Global function to restore LibEditMode positioning (called when widthMode goes back to MANUAL)
    _G.CustomBrewmasterStaggerBar_RestorePosition = function()
        if not barFrame then return end
        if InCombatLockdown() then return end
        local db = GetSavedDB()
        local saved = db.position
        local pt = (saved and saved.point) or DEFAULT_POS.point
        local x  = (saved and saved.x) or DEFAULT_POS.x
        local y  = (saved and saved.y) or DEFAULT_POS.y
        barFrame:ClearAllPoints()
        barFrame:SetPoint(pt, UIParent, pt, x, y)
        local w = db.width or DEFAULT_WIDTH
        barFrame:SetWidth(w)
        if bgTexture then bgTexture:SetAllPoints(barFrame) end
    end
end

------------------------------------------------------------
-- Build SharedMedia texture list for dropdown
------------------------------------------------------------
local function GetSMTextureList()
    if not LSM then return { "Blizzard" } end
    local list = LSM:List("statusbar") or {}
    return list
end

------------------------------------------------------------
-- Register with LibEditMode
------------------------------------------------------------
local function RegisterEditMode()
    if editModeRegistered or not barFrame or not LibEditMode then return end
    editModeRegistered = true

    local db = GetSavedDB()

    -- 還原已儲存的位置
    local saved = db.position
    local pt = (saved and saved.point) or DEFAULT_POS.point
    local x  = (saved and saved.x) or DEFAULT_POS.x
    local y  = (saved and saved.y) or DEFAULT_POS.y
    barFrame:ClearAllPoints()
    barFrame:SetPoint(pt, UIParent, pt, x, y)

    LibEditMode:AddFrame(barFrame, function(frame, layoutName, pt2, fx, fy)
        if not layoutName then return end
        db.layoutPositions = db.layoutPositions or {}
        db.layoutPositions[layoutName] = { point = pt2, x = fx, y = fy }
        db.position = { point = pt2, x = fx, y = fy }
    end, DEFAULT_POS, "醉仙緩勁條")

    -- 從 SharedMedia 建立材質下拉選單值
    local texList = GetSMTextureList()
    local texDropdown = {}
    for i, name in ipairs(texList) do
        texDropdown[i] = { label = name, value = name }
    end

    LibEditMode:AddFrameSettings(barFrame, {
        -- 寬度
        {
            kind = LibEditMode.SettingType.Slider,
            name = "計量條寬度",
            default = DEFAULT_WIDTH,
            get = function() return db.width or DEFAULT_WIDTH end,
            set = function(_, v)
                db.width = v
                barFrame:SetWidth(v)
                if bgTexture then bgTexture:SetAllPoints(barFrame) end
            end,
            minValue = 50, maxValue = 500, valueStep = 1,
        },
        -- 高度
        {
            kind = LibEditMode.SettingType.Slider,
            name = "計量條高度",
            default = DEFAULT_HEIGHT,
            get = function() return db.height or DEFAULT_HEIGHT end,
            set = function(_, v)
                db.height = v
                barFrame:SetHeight(v)
                if bgTexture then bgTexture:SetAllPoints(barFrame) end
            end,
            minValue = 4, maxValue = 50, valueStep = 1,
        },
        -- 框架層級
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "框架層級",
            default = "MEDIUM",
            get = function()
                return db.strata or "MEDIUM"
            end,
            set = function(_, v)
                db.strata = v or "MEDIUM"
                barFrame:SetFrameStrata(db.strata)
            end,
            values = {
                { text = "背景層", value = "BACKGROUND" },
                { text = "低層",   value = "LOW" },
                { text = "中層",   value = "MEDIUM" },
                { text = "高層",   value = "HIGH" },
                { text = "對話層", value = "DIALOG" },
            },
        },
        -- 材質 (SharedMedia)
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "計量條材質",
            height = 300,
            default = GetSMTextureList()[1] or "Blizzard",
            get = function()
                return db.texture or GetSMTextureList()[1] or "Blizzard"
            end,
            set = function(_, v)
                if v then
                    db.texture = v
                    lastTexKey = nil
                    RefreshBarTexture()
                end
            end,
            values = (function()
                local list = GetSMTextureList()
                local vals = {}
                for i, name in ipairs(list) do
                    vals[i] = { text = name, value = name }
                end
                return vals
            end)(),
        },
        -- 背景顏色
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "背景顏色",
            default = CreateColor(0.2, 0.2, 0.2, 1),
            get = function()
                local c = db.bgColor
                if c then return CreateColor(c.r, c.g, c.b, 1) end
                return CreateColor(0.2, 0.2, 0.2, 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b = color:GetRGB()
                db.bgColor = { r = r, g = g, b = b, a = 0.65 }
                RefreshBgColor()
            end,
        },
        -- 背景材質 (SharedMedia)
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "背景材質",
            height = 300,
            default = "(純色)",
            get = function()
                return db.bgTexture or "(純色)"
            end,
            set = function(_, v)
                if v == "(純色)" then
                    db.bgTexture = nil
                else
                    db.bgTexture = v
                end
                RefreshBgColor()
            end,
            values = (function()
                local list = GetSMTextureList()
                local vals = { { text = "(純色)", value = "(純色)" } }
                for i, name in ipairs(list) do
                    vals[i + 1] = { text = name, value = name }
                end
                return vals
            end)(),
        },
        -- 綠色階段顏色
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "綠色階段顏色",
            default = CreateColor(0, 1, 0, 1),
            get = function()
                local c = db.colors and db.colors.green
                if c then return CreateColor(c.r, c.g, c.b, 1) end
                local info = PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"].green
                if info then return CreateColor(info.r, info.g, info.b, 1) end
                return CreateColor(0, 1, 0, 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b = color:GetRGB()
                db.colors = db.colors or {}
                db.colors.green = { r = r, g = g, b = b }
                staggerStateKey = nil
                UpdateStaggerBar()
            end,
        },
        -- 黃色階段顏色
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "黃色階段顏色",
            default = CreateColor(1, 1, 0, 1),
            get = function()
                local c = db.colors and db.colors.yellow
                if c then return CreateColor(c.r, c.g, c.b, 1) end
                local info = PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"].yellow
                if info then return CreateColor(info.r, info.g, info.b, 1) end
                return CreateColor(1, 1, 0, 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b = color:GetRGB()
                db.colors = db.colors or {}
                db.colors.yellow = { r = r, g = g, b = b }
                staggerStateKey = nil
                UpdateStaggerBar()
            end,
        },
        -- 紅色階段顏色
        {
            kind = LibEditMode.SettingType.ColorPicker,
            name = "紅色階段顏色",
            default = CreateColor(1, 0, 0, 1),
            get = function()
                local c = db.colors and db.colors.red
                if c then return CreateColor(c.r, c.g, c.b, 1) end
                local info = PowerBarColor["STAGGER"] and PowerBarColor["STAGGER"].red
                if info then return CreateColor(info.r, info.g, info.b, 1) end
                return CreateColor(1, 0, 0, 1)
            end,
            set = function(_, color)
                if not color then return end
                local r, g, b = color:GetRGB()
                db.colors = db.colors or {}
                db.colors.red = { r = r, g = g, b = b }
                staggerStateKey = nil
                UpdateStaggerBar()
            end,
        },
        -- 字體大小
        {
            kind = LibEditMode.SettingType.Slider,
            name = "文字字體大小",
            default = 12,
            get = function() return db.fontSize or 12 end,
            set = function(_, v)
                db.fontSize = v
                RefreshTextSettings()
            end,
            minValue = 6, maxValue = 32, valueStep = 1,
        },
        -- 文字 X 偏移
        {
            kind = LibEditMode.SettingType.Slider,
            name = "文字水平偏移",
            default = 0,
            get = function() return db.textOffsetX or 0 end,
            set = function(_, v)
                db.textOffsetX = v
                RefreshTextSettings()
            end,
            minValue = -200, maxValue = 200, valueStep = 1,
        },
        -- 文字 Y 偏移
        {
            kind = LibEditMode.SettingType.Slider,
            name = "文字垂直偏移",
            default = 0,
            get = function() return db.textOffsetY or 0 end,
            set = function(_, v)
                db.textOffsetY = v
                RefreshTextSettings()
            end,
            minValue = -200, maxValue = 200, valueStep = 1,
        },
        -- 騎乘時隱藏
        {
            kind = LibEditMode.SettingType.Checkbox,
            name = "騎乘時隱藏",
            default = true,
            get = function() return db.hideWhenMounted ~= false end,
            set = function(_, v)
                db.hideWhenMounted = v
                EvaluateVisibility()
            end,
        },
        -- Sync Anchor Position (above/below PRD when width synced)
        {
            kind = LibEditMode.SettingType.Dropdown,
            name = "Sync Position",
            get = function()
                local p = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return p and p.staggerSyncAnchor or "ABOVE"
            end,
            set = function(_, v)
                local p = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if p then p.staggerSyncAnchor = v end
                if type(_G.CustomBrewmasterStaggerBar_SetSyncWidth) == "function" then
                    local bw = barFrame and barFrame:GetWidth() or 200
                    _G.CustomBrewmasterStaggerBar_SetSyncWidth(bw)
                end
            end,
            values = {
                { text = "Above PRD", value = "ABOVE" },
                { text = "Below PRD", value = "BELOW" },
            },
        },
        -- Sync Offset (pixel gap from PRD when width synced)
        {
            kind = LibEditMode.SettingType.Slider,
            name = "Sync Offset",
            default = 2,
            get = function()
                local p = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return p and p.staggerSyncOffset or 2
            end,
            set = function(_, v)
                local p = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if p then p.staggerSyncOffset = v end
                if type(_G.CustomBrewmasterStaggerBar_SetSyncWidth) == "function" then
                    local bw = barFrame and barFrame:GetWidth() or 200
                    _G.CustomBrewmasterStaggerBar_SetSyncWidth(bw)
                end
            end,
            minValue = -20, maxValue = 40, valueStep = 1,
        },
    })
end
------------------------------------------------------------
-- Show/hide logic
------------------------------------------------------------
EvaluateVisibility = function()
    if not IsBrewmasterMonk() then
        if barFrame then barFrame:Hide() end
        RestoreBlizzardAltBar()
        return
    end

    -- Don't show when mounted (unless user disabled the check)
    local db = GetSavedDB()
    if db.hideWhenMounted ~= false and type(IsMounted) == "function" and IsMounted() then
        if barFrame then barFrame:Hide() end
        return
    end

    -- PRD must be visible
    local prd = _G.PersonalResourceDisplayFrame
    if not prd or not prd:IsShown() then
        if barFrame then barFrame:Hide() end
        return
    end

    if not barFrame then CreateCustomStaggerBar() end
    RegisterEditMode()

    HideBlizzardAltBar()
    AnchorCustomBar()
    RefreshBarTexture()
    RefreshBgColor()
    barFrame:Show()
    staggerStateKey = nil -- force color update
    UpdateStaggerBar()
end

------------------------------------------------------------
-- Event driver
------------------------------------------------------------
local driver = CreateFrame("Frame")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
driver:RegisterEvent("UNIT_DISPLAYPOWER")
driver:RegisterEvent("PLAYER_TALENT_UPDATE")
driver:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
driver:RegisterUnitEvent("UNIT_AURA", "player")
driver:RegisterEvent("UNIT_STATS")
driver:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
driver:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
driver:RegisterEvent("PLAYER_REGEN_ENABLED")
driver:RegisterEvent("LOADING_SCREEN_ENABLED")
driver:RegisterEvent("LOADING_SCREEN_DISABLED")

local isLoadingScreen = false

driver:SetScript("OnEvent", function(self, event, arg1)
    if event == "LOADING_SCREEN_ENABLED" then
        isLoadingScreen = true
        if barFrame then barFrame:Hide() end
        return
    end
    if event == "LOADING_SCREEN_DISABLED" then
        isLoadingScreen = false
        C_Timer.After(0.1, EvaluateVisibility)
        return
    end

    if event == "UNIT_AURA" and arg1 ~= "player" then return end

    if event == "PLAYER_ENTERING_WORLD"
    or event == "PLAYER_SPECIALIZATION_CHANGED"
    or event == "UNIT_DISPLAYPOWER"
    or event == "PLAYER_TALENT_UPDATE"
    or event == "PLAYER_MOUNT_DISPLAY_CHANGED"
    or event == "PLAYER_REGEN_ENABLED" then
        -- Defer slightly so PRD has time to set up
        C_Timer.After(0.1, EvaluateVisibility)
        return
    end

    -- Fast-path: stagger value changed
    if barFrame and barFrame:IsShown() then
        UpdateStaggerBar()
    end
end)

-- OnUpdate for smooth bar movement (Blizzard does this too)
local elapsed_acc = 0
driver:SetScript("OnUpdate", function(self, elapsed)
    if isLoadingScreen then return end
    elapsed_acc = elapsed_acc + elapsed
    if elapsed_acc < 0.05 then return end
    elapsed_acc = 0
    if barFrame and barFrame:IsShown() then
        UpdateStaggerBar()
    end
end)
