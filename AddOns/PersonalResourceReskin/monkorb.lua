
local _, class = UnitClass("player")
if class ~= "MONK" then return end

-- monkorb.lua
-- Originally from: Enhanced Cooldown Manager by Argium, Copyright (C) 2023 Argium
-- Modified for PersonalResourceReskin by [Ckraigfriend], 2026
-- This file is licensed under the GNU General Public License v3.0 (GPL-3.0)
-- See LICENSE for details.
-- Changelog:
-- [2026-01-25] Adapted for Brewmaster Monk Orb Tracker by [Ckraigfriend]

-- MonkOrbTracker options
local function get(info)
    local key = info[#info]
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return nil end
    return db["MonkOrbTracker_"..key]
end

local function set(info, value)
    local key = info[#info]
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return end
    db["MonkOrbTracker_"..key] = value
    if _G.MonkOrbTracker_Update then _G.MonkOrbTracker_Update() end
end

local bar

local MonkOrbTrackerOptions = {
    type = "group",
    name = "|cFF00FF96Brewmaster Stagger Orbs|r",
    order = 900,
    args = {
        monkOrbSubpage = {
            type = "group",
            name = "Brewmaster Orbs Bar",
            order = 1,
            args = {
                header = {
                    order = 0,
                    type = "header",
                    name = "Brewmaster Monk Stagger Orbs Bar",
                },
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = "Enable Orbs Tracker",
                    desc = "Show the segmented stagger orbs bar for Brewmaster Monk.",
                    get = function() return get({"enabled"}) ~= false end,
                    set = function(_, val)
                        set({"enabled"}, val)
                        if _G.MonkOrbTracker then _G.MonkOrbTracker:SetShown(val) end
                    end,
                },
                bgColor = {
                    order = 3,
                    type = "color",
                    name = "Background Color",
                    hasAlpha = true,
                    get = function()
                        local c = get({"bgColor"}) or {0.08, 0.08, 0.08, 0.75}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        set({"bgColor"}, {r, g, b, a})
                        if _G.MonkOrbTracker_Update then _G.MonkOrbTracker_Update() end
                    end,
                },
                segmentGradientStart = {
                    order = 8,
                    type = "color",
                    name = "Segment Gradient Start",
                    hasAlpha = true,
                    get = function()
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        local c = db and db.MonkOrbTracker_segmentGradientStart or {0.46, 0.98, 1.00, 1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        if not db then return end
                        db.MonkOrbTracker_segmentGradientStart = {r, g, b, a}
                        if _G.MonkOrbTracker_Update then _G.MonkOrbTracker_Update() end
                    end,
                },
                segmentGradientEnd = {
                    order = 9,
                    type = "color",
                    name = "Segment Gradient End",
                    hasAlpha = true,
                    get = function()
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        local c = db and db.MonkOrbTracker_segmentGradientEnd or {0.00, 0.50, 1.00, 1}
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(_, r, g, b, a)
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        if not db then return end
                        db.MonkOrbTracker_segmentGradientEnd = {r, g, b, a}
                        if _G.MonkOrbTracker_Update then _G.MonkOrbTracker_Update() end
                    end,
                },
                hideWhenMounted = {
                    order = 10,
                    type = "toggle",
                    name = "Hide When Mounted",
                    desc = "Hide the soul fragments bar while mounted.",
                    get = function()
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        return db and db.MonkOrbTracker_hideWhenMounted or false
                    end,
                    set = function(_, val)
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        if not db then return end
                        db.MonkOrbTracker_hideWhenMounted = val
                        if _G.MonkOrbTracker_Update then _G.MonkOrbTracker_Update() end
                    end,
                },
                width = {
                    order = 4,
                    type = "range",
                    name = "Bar Width",
                    min = 60, max = 400, step = 0.001,
                    get = function() return get({"width"}) or 120 end,
                    set = function(_, val)
                        set({"width"}, val)
                        if _G.MonkOrbTracker then _G.MonkOrbTracker:SetWidth(val) end
                    end,
                },
                height = {
                    order = 5,
                    type = "range",
                    name = "Bar Height",
                    min = 8, max = 80, step = 0.001,
                    get = function() return get({"height"}) or 24 end,
                    set = function(_, val)
                        set({"height"}, val)
                        if _G.MonkOrbTracker then _G.MonkOrbTracker:SetHeight(val) end
                    end,
                },
                yOffset = {
                    order = 6,
                    type = "range",
                    name = "Vertical Offset",
                    desc = "Vertical position when not anchored.",
                    min = -400, max = 400, step = 0.001,
                    get = function() return get({"yOffset"}) or -200 end,
                    set = function(_, val)
                        set({"yOffset"}, val)
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        local x = db and (db.MonkOrbTracker_xOffset or 0) or 0
                        db.MonkOrbTracker_yOffset = val
                        if _G.MonkOrbTracker then
                            _G.MonkOrbTracker:ClearAllPoints()
                            _G.MonkOrbTracker:SetPoint("CENTER", UIParent, "CENTER", x, val)
                        end
                    end,
                    disabled = function() return get({"anchorToPRD"}) end,
                },
                anchorToPRD = {
                    order = 6.1,
                    type = "toggle",
                    name = "Anchor to Personal Resource Display",
                    desc = "Attach to PRD health or power bar.",
                    get = function() return get({"anchorToPRD"}) end,
                    set = function(_, val)
                        set({"anchorToPRD"}, val)
                    end,
                },
                anchorTarget = {
                    order = 6.2,
                    type = "select",
                    name = "Anchor Target",
                    desc = "Choose which PRD bar to anchor to.",
                    values = { HEALTH = "Health Bar", POWER = "Power Bar" },
                    get = function() return get({"anchorTarget"}) or "HEALTH" end,
                    set = function(_, val)
                        set({"anchorTarget"}, val)
                    end,
                    disabled = function() return not get({"anchorToPRD"}) end,
                },
                anchorPosition = {
                    order = 6.3,
                    type = "select",
                    name = "Anchor Position",
                    desc = "Place above or below the selected PRD bar.",
                    values = { ABOVE = "Above", BELOW = "Below" },
                    get = function() return get({"anchorPosition"}) or "BELOW" end,
                    set = function(_, val)
                        set({"anchorPosition"}, val)
                    end,
                    disabled = function() return not get({"anchorToPRD"}) end,
                },
                anchorOffset = {
                    order = 6.4,
                    type = "range",
                    name = "Anchor Offset",
                    desc = "Vertical offset from the PRD bar when anchored.",
                    min = -100, max = 200, step = 1,
                    get = function() return get({"anchorOffset"}) or 10 end,
                    set = function(_, val)
                        set({"anchorOffset"}, val)
                    end,
                    disabled = function() return not get({"anchorToPRD"}) end,
                },
                xOffset = {
                    order = 7,
                    type = "range",
                    name = "Horizontal Offset",
                    desc = "Horizontal position when not anchored.",
                    min = -400, max = 400, step = 0.001,
                    get = function() local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile return db and (db.MonkOrbTracker_xOffset or 0) or 0 end,
                    set = function(_, val)
                        local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                        if not db then return end
                        db.MonkOrbTracker_xOffset = val
                        if _G.MonkOrbTracker_Update then _G.MonkOrbTracker_Update() end
                    end,
                    disabled = function() return get({"anchorToPRD"}) end,
                },
                link = {
                    order = 1000,
                    type = "input",
                    name = "Original Addon (copy URL):",
                    get = function() return "https://www.curseforge.com/wow/addons/enhanced-cooldown-manager" end,
                    set = function() end,
                    width = "full",
                    dialogControl = "EditBox",
                    desc = "Original by Argium. Logo available in addon folder as argium2.tga."
                },
                argiumlogo = {
                    order = 1001,
                    type = "description",
                    name = "",
                    image = "Interface\\AddOns\\PersonalResourceReskin\\argium.tga",
                    imageWidth = 500,
                    imageHeight = 500,
                },
            },
        },
    }
}

_G.MonkOrbTrackerOptions = MonkOrbTrackerOptions

-- SoulsTrackerVeng.lua
-- Standalone Soul Fragments tracker for Vengeance Demon Hunter

local function GetPRDHealthBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        return prd.HealthBarsContainer.healthBar
    end
    if _G.PersonalResourceDisplayHealthBar then
        return _G.PersonalResourceDisplayHealthBar
    end
    return nil
end

local function GetPRDPowerBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.PowerBar then
        return prd.PowerBar
    end
    return nil
end

local function GetPRDAnchorFrame()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db or not db.MonkOrbTracker_anchorToPRD then return nil end
    local target = db.MonkOrbTracker_anchorTarget or "HEALTH"
    return (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
end

local MonkOrbTracker = CreateFrame("Frame", "MonkOrbTrackerFrame", UIParent)
MonkOrbTracker:SetSize(120, 24)
MonkOrbTracker:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
MonkOrbTracker:Hide()


local DEFAULT_NUM_ORBS = 5
local ORB_SPELL_ID = 322101 -- Brewmaster Monk orb spell
local ORB_COLOR = {0.00, 1.00, 0.59, 1}
local ORB_BG_COLOR = {0.08, 0.08, 0.08, 0.75}


bar = CreateFrame("StatusBar", nil, MonkOrbTracker)
bar:SetAllPoints(MonkOrbTracker)
bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
bar:SetStatusBarColor(unpack(ORB_COLOR))
-- Background
local bg = bar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(bar)
bg:SetColorTexture(unpack(ORB_BG_COLOR))
bar.bg = bg

-- Dynamic tick drawing
local ticks = {}
local function UpdateTicks(numOrbs)
    for _, tick in ipairs(ticks) do tick:Hide() end
    local w, h = bar:GetWidth(), bar:GetHeight()
    for i = 1, (numOrbs or DEFAULT_NUM_ORBS) - 1 do
        if not ticks[i] then
            ticks[i] = bar:CreateTexture(nil, "OVERLAY")
            ticks[i]:SetColorTexture(0, 0, 0, 1)
        end
        ticks[i]:SetSize(2, h)
        ticks[i]:SetPoint("LEFT", bar, "LEFT", i * (w / (numOrbs or DEFAULT_NUM_ORBS)) - 1, 0)
        ticks[i]:Show()
    end
end
bar:SetScript("OnSizeChanged", function()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local numOrbs = (db and db.MonkOrbTracker_numOrbs) or DEFAULT_NUM_ORBS
    UpdateTicks(numOrbs)
end)
bar:GetScript("OnSizeChanged")(bar) -- Initial draw

local function GetOrbCount()
    local count = C_Spell.GetSpellCastCount and C_Spell.GetSpellCastCount(ORB_SPELL_ID)
    return count
end

local function ApplySavedOptions()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return end
    -- Color or gradient
    local gradStart = db.MonkOrbTracker_segmentGradientStart
    local gradEnd = db.MonkOrbTracker_segmentGradientEnd
    local useGradient = gradStart and gradEnd
    local barTexture = bar and bar.GetStatusBarTexture and bar:GetStatusBarTexture() or nil
    if useGradient and barTexture and barTexture.SetGradient then
        barTexture:SetGradient("HORIZONTAL",
            CreateColor(gradStart[1], gradStart[2], gradStart[3], gradStart[4]),
            CreateColor(gradEnd[1], gradEnd[2], gradEnd[3], gradEnd[4])
        )
    else
        local c = db.MonkOrbTracker_color or {0.00, 1.00, 0.59, 1}
        if bar and bar.SetStatusBarColor then bar:SetStatusBarColor(unpack(c)) end
        if barTexture and barTexture.SetGradient then
            -- Remove any previous gradient by setting a solid color
            barTexture:SetColorTexture(c[1], c[2], c[3], c[4])
        end
    end
    -- BG Color
    local bgc = db.MonkOrbTracker_bgColor or {0.08, 0.08, 0.08, 0.75}
    if bar and bar.bg then bar.bg:SetColorTexture(unpack(bgc)) end
    -- Size
    local w = db.MonkOrbTracker_width or 120
    local h = db.MonkOrbTracker_height or 24
    MonkOrbTracker:SetWidth(w)
    MonkOrbTracker:SetHeight(h)
    -- Position: anchor to PRD or use X/Y
    MonkOrbTracker:ClearAllPoints()
    local anchorFrame = GetPRDAnchorFrame()
    if anchorFrame then
        local pos = db.MonkOrbTracker_anchorPosition or "BELOW"
        local offset = db.MonkOrbTracker_anchorOffset or 10
        if pos == "ABOVE" then
            MonkOrbTracker:SetPoint("BOTTOM", anchorFrame, "TOP", 0, offset)
        else
            MonkOrbTracker:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -offset)
        end
    else
        local x = db.MonkOrbTracker_xOffset or 0
        local y = db.MonkOrbTracker_yOffset or -200
        MonkOrbTracker:SetPoint("CENTER", UIParent, "CENTER", x, y)
    end
    -- Enable/disable
    local enabled = db.MonkOrbTracker_enabled ~= false
    MonkOrbTracker:SetShown(enabled)
end

local prdHooked = false

local function HookPRDAnchor()
    local anchorFrame = GetPRDAnchorFrame()
    if not anchorFrame or prdHooked then return end
    
    local function OnPRDChange()
        ApplySavedOptions()
    end
    
    anchorFrame:HookScript("OnSizeChanged", OnPRDChange)
    if anchorFrame.SetPoint then
        hooksecurefunc(anchorFrame, "SetPoint", OnPRDChange)
    end
    if anchorFrame.SetScale then
        hooksecurefunc(anchorFrame, "SetScale", OnPRDChange)
    end
    
    prdHooked = true
end


local lastUpdate = 0
local updateFrequency = 0.066 -- ~15 FPS, configurable if desired

local function UpdateOrbs()
    ApplySavedOptions()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    -- Hook to PRD if anchored
    if db and db.MonkOrbTracker_anchorToPRD and not prdHooked then
        HookPRDAnchor()
    end
    local hideWhenMounted = db and db.MonkOrbTracker_hideWhenMounted
    if hideWhenMounted and IsMounted() then
        MonkOrbTracker:Hide()
        return
    end
    local numOrbs = (db and db.MonkOrbTracker_numOrbs) or DEFAULT_NUM_ORBS
    bar:SetMinMaxValues(0, numOrbs)
    local count = GetOrbCount()
    bar:SetValue(count or 0)
    UpdateTicks(numOrbs)
    MonkOrbTracker:Show()
end

local function OnUpdateThrottled(_, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate >= updateFrequency then
        UpdateOrbs()
        lastUpdate = 0
    end
end

MonkOrbTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
MonkOrbTracker:RegisterEvent("UNIT_POWER_UPDATE")
MonkOrbTracker:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
MonkOrbTracker:RegisterEvent("UNIT_DISPLAYPOWER")
MonkOrbTracker:RegisterEvent("UNIT_MAXPOWER")
MonkOrbTracker:RegisterEvent("PLAYER_TALENT_UPDATE")
MonkOrbTracker:RegisterEvent("PLAYER_REGEN_ENABLED")
MonkOrbTracker:RegisterEvent("PLAYER_REGEN_DISABLED")
MonkOrbTracker:RegisterEvent("RUNE_POWER_UPDATE")
MonkOrbTracker:RegisterEvent("RUNE_TYPE_UPDATE")
MonkOrbTracker:RegisterEvent("UNIT_AURA")
MonkOrbTracker:SetScript("OnEvent", function(self, event, ...)
    local function IsBrewmasterMonk()
        local _, class = UnitClass("player")
        if class ~= "MONK" then return false end
        local spec = GetSpecialization()
        return spec == 1 -- 1 = Brewmaster
    end

    if not IsBrewmasterMonk() then
        MonkOrbTracker:Hide()
        MonkOrbTracker:UnregisterAllEvents()
        MonkOrbTracker:SetScript("OnUpdate", nil)
        return
    end
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local hideWhenMounted = db and db.MonkOrbTracker_hideWhenMounted
    if hideWhenMounted and IsMounted() then
        MonkOrbTracker:Hide()
        MonkOrbTracker:SetScript("OnUpdate", nil)
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        ApplySavedOptions()
        UpdateOrbs()
        MonkOrbTracker:SetScript("OnUpdate", OnUpdateThrottled)
    elseif event == "UNIT_POWER_UPDATE" then
        local unit = ...
        if unit == "player" then
            UpdateOrbs()
        end
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            OnUpdateThrottled(self, updateFrequency) -- force a throttled update
        end
    elseif event == "RUNE_POWER_UPDATE" or event == "RUNE_TYPE_UPDATE" then
        UpdateOrbs()
    else
        UpdateOrbs()
    end
end)

-- Only show for Brewmaster Monk
local function ShouldShowMonkOrbBar()
    local _, class = UnitClass("player")
    if class ~= "MONK" then return false end
    local spec = GetSpecialization()
    return spec == 1 -- 1 = Brewmaster
end

hooksecurefunc(MonkOrbTracker, "Show", function(self)
    if not ShouldShowMonkOrbBar() then self:Hide() end
end)

-- Expose for manual update/testing
_G.MonkOrbTracker_Update = UpdateOrbs
