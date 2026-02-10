-- soulstrackerveng.lua
-- Originally from: Enhanced Cooldown Manager by Argium, Copyright (C) 2023 Argium
-- Modified for PersonalResourceReskin by [Ckraigfriend], 2026
-- This file is licensed under the GNU General Public License v3.0 (GPL-3.0)
-- See LICENSE for details.
-- Changelog:
-- [2026-01-23] Adapted for PersonalResourceReskin by [Ckraigfriend]

-- SoulsTrackerVeng options
local function get(info)
    local key = info[#info]
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return nil end
    return db["SoulsTrackerVeng_"..key]
end

local function set(info, value)
    local key = info[#info]
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return end
    db["SoulsTrackerVeng_"..key] = value
    if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
end

-- Expose bar for options handlers
local bar

local SoulsTrackerVengOptions = {
    type = "group",
    name = "|cFFA330C9Vengeance Soul Fragments|r",
    order = 900,
    args = {
        header = {
            order = 0,
            type = "header",
            name = "Vengeance Demon Hunter Soul Fragments Bar",
        },
        enabled = {
            order = 1,
            type = "toggle",
            name = "Enable Souls Tracker",
            desc = "Show the segmented soul fragments bar for Vengeance Demon Hunter.",
            get = function() return get({"enabled"}) ~= false end,
            set = function(_, val)
                set({"enabled"}, val)
                SoulsTrackerVengFrame:SetShown(val)
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
                        _G.SoulsTrackerVengFrame:SetShown(val)
            end,
        },
        segmentGradientStart = {
            order = 8,
            type = "color",
            name = "Segment Gradient Start",
            hasAlpha = true,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                local c = db and db.SoulsTrackerVeng_segmentGradientStart or {0.46, 0.98, 1.00, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.SoulsTrackerVeng_segmentGradientStart = {r, g, b, a}
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
            end,
        },
        segmentGradientEnd = {
            order = 9,
            type = "color",
            name = "Segment Gradient End",
            hasAlpha = true,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                local c = db and db.SoulsTrackerVeng_segmentGradientEnd or {0.00, 0.50, 1.00, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.SoulsTrackerVeng_segmentGradientEnd = {r, g, b, a}
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
            end,
        },
        hideWhenMounted = {
            order = 10,
            type = "toggle",
            name = "Hide When Mounted",
            desc = "Hide the soul fragments bar while mounted.",
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return db and db.SoulsTrackerVeng_hideWhenMounted or false
            end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.SoulsTrackerVeng_hideWhenMounted = val
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
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
                _G.SoulsTrackerVengFrame:SetWidth(val)
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
                _G.SoulsTrackerVengFrame:SetHeight(val)
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
                -- Use saved x/y for consistent movement
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                local x = db and (db.SoulsTrackerVeng_xOffset or 0) or 0
                db.SoulsTrackerVeng_yOffset = val
                _G.SoulsTrackerVengFrame:ClearAllPoints()
                _G.SoulsTrackerVengFrame:SetPoint("CENTER", UIParent, "CENTER", x, val)
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
            get = function() local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile return db and (db.SoulsTrackerVeng_xOffset or 0) or 0 end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.SoulsTrackerVeng_xOffset = val
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
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
}

_G.SoulsTrackerVengOptions = SoulsTrackerVengOptions

-- SoulsTrackerVeng.lua
-- Standalone Soul Fragments tracker for Vengeance Demon Hunter

local function GetPRDHealthBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        return prd.HealthBarsContainer.healthBar
    end
    return _G.PersonalResourceDisplayHealthBar
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
    if not db or not db.SoulsTrackerVeng_anchorToPRD then return nil end
    local target = db.SoulsTrackerVeng_anchorTarget or "HEALTH"
    return (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
end


local SoulsTrackerVeng = CreateFrame("Frame", "SoulsTrackerVengFrame", UIParent)
SoulsTrackerVeng:SetSize(120, 24)
SoulsTrackerVeng:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
SoulsTrackerVeng:SetFrameStrata("LOW")
SoulsTrackerVeng:Hide()


local DEFAULT_NUM_SOULS = 6
local SOUL_SPELL_ID = 247454 -- Soul Fragment spell
local SOUL_COLOR = {0.46, 0.98, 1.00, 1}
local SOUL_BG_COLOR = {0.08, 0.08, 0.08, 0.75}


bar = CreateFrame("StatusBar", nil, SoulsTrackerVeng)
bar:SetAllPoints(SoulsTrackerVeng)
bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
bar:SetStatusBarColor(unpack(SOUL_COLOR))
bar:SetFrameStrata("LOW")
-- Background
local bg = bar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(bar)
bg:SetColorTexture(unpack(SOUL_BG_COLOR))
bar.bg = bg
        -- Background
-- Dynamic tick drawing
local ticks = {}
local function UpdateTicks(numSouls)
    for _, tick in ipairs(ticks) do tick:Hide() end
    local w, h = bar:GetWidth(), bar:GetHeight()
    for i = 1, (numSouls or DEFAULT_NUM_SOULS) - 1 do
        if not ticks[i] then
            ticks[i] = bar:CreateTexture(nil, "OVERLAY")
            ticks[i]:SetColorTexture(0, 0, 0, 1)
        end
        ticks[i]:SetSize(2, h)
        ticks[i]:SetPoint("LEFT", bar, "LEFT", i * (w / (numSouls or DEFAULT_NUM_SOULS)) - 1, 0)
        ticks[i]:Show()
    end
end
bar:SetScript("OnSizeChanged", function(self)
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local numSouls = (db and db.SoulsTrackerVeng_numSouls) or DEFAULT_NUM_SOULS
    UpdateTicks(numSouls)
end)
bar:GetScript("OnSizeChanged")(bar) -- Initial draw

local function GetSoulCount()
    local count = C_Spell.GetSpellCastCount and C_Spell.GetSpellCastCount(SOUL_SPELL_ID)
    return count
end

local function ApplySavedOptions()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return end
    -- Color or gradient
    local gradStart = db.SoulsTrackerVeng_segmentGradientStart
    local gradEnd = db.SoulsTrackerVeng_segmentGradientEnd
    local useGradient = gradStart and gradEnd
    local barTexture = bar and bar.GetStatusBarTexture and bar:GetStatusBarTexture() or nil
    if useGradient and barTexture and barTexture.SetGradient then
        barTexture:SetGradient("HORIZONTAL",
            CreateColor(gradStart[1], gradStart[2], gradStart[3], gradStart[4]),
            CreateColor(gradEnd[1], gradEnd[2], gradEnd[3], gradEnd[4])
        )
    else
        local c = db.SoulsTrackerVeng_color or {0.46, 0.98, 1.00, 1}
        if bar and bar.SetStatusBarColor then bar:SetStatusBarColor(unpack(c)) end
        if barTexture and barTexture.SetGradient then
            -- Remove any previous gradient by setting a solid color
            barTexture:SetColorTexture(c[1], c[2], c[3], c[4])
        end
    end
    -- BG Color
    local bgc = db.SoulsTrackerVeng_bgColor or {0.08, 0.08, 0.08, 0.75}
    if bar and bar.bg then bar.bg:SetColorTexture(unpack(bgc)) end
    -- Size
    local w = db.SoulsTrackerVeng_width or 120
    local h = db.SoulsTrackerVeng_height or 24
    SoulsTrackerVeng:SetWidth(w)
    SoulsTrackerVeng:SetHeight(h)
    -- Position: anchor to PRD or use X/Y
    SoulsTrackerVeng:ClearAllPoints()
    local anchorFrame = GetPRDAnchorFrame()
    if anchorFrame then
        local pos = db.SoulsTrackerVeng_anchorPosition or "BELOW"
        local offset = db.SoulsTrackerVeng_anchorOffset or 10
        if pos == "ABOVE" then
            SoulsTrackerVeng:SetPoint("BOTTOM", anchorFrame, "TOP", 0, offset)
        else
            SoulsTrackerVeng:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -offset)
        end
    else
        local x = db.SoulsTrackerVeng_xOffset or 0
        local y = db.SoulsTrackerVeng_yOffset or -200
        SoulsTrackerVeng:SetPoint("CENTER", UIParent, "CENTER", x, y)
    end
    -- Enable/disable
    local enabled = db.SoulsTrackerVeng_enabled ~= false
    SoulsTrackerVeng:SetShown(enabled)
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

local function UpdateSouls()
    ApplySavedOptions()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    
    -- Hook to PRD if anchored
    if db and db.SoulsTrackerVeng_anchorToPRD and not prdHooked then
        HookPRDAnchor()
    end
    
    local hideWhenMounted = db and db.SoulsTrackerVeng_hideWhenMounted
    if hideWhenMounted and IsMounted() then
        SoulsTrackerVeng:Hide()
        return
    end
    local numSouls = (db and db.SoulsTrackerVeng_numSouls) or DEFAULT_NUM_SOULS
    bar:SetMinMaxValues(0, numSouls)
    local count = GetSoulCount()
    bar:SetValue(count or 0)
    UpdateTicks(numSouls)
    SoulsTrackerVeng:Show()
end

local function OnUpdateThrottled(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate >= updateFrequency then
        UpdateSouls()
        lastUpdate = 0
    end
end

SoulsTrackerVeng:RegisterEvent("PLAYER_ENTERING_WORLD")
SoulsTrackerVeng:RegisterEvent("UNIT_POWER_UPDATE")
SoulsTrackerVeng:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
SoulsTrackerVeng:RegisterEvent("UNIT_DISPLAYPOWER")
SoulsTrackerVeng:RegisterEvent("UNIT_MAXPOWER")
SoulsTrackerVeng:RegisterEvent("PLAYER_TALENT_UPDATE")
SoulsTrackerVeng:RegisterEvent("PLAYER_REGEN_ENABLED")
SoulsTrackerVeng:RegisterEvent("PLAYER_REGEN_DISABLED")
SoulsTrackerVeng:RegisterEvent("RUNE_POWER_UPDATE")
SoulsTrackerVeng:RegisterEvent("RUNE_TYPE_UPDATE")
SoulsTrackerVeng:RegisterEvent("UNIT_AURA")
SoulsTrackerVeng:SetScript("OnEvent", function(self, event, ...)
    local function IsVengeanceDH()
        local _, class = UnitClass("player")
        if class ~= "DEMONHUNTER" then return false end
        local spec = GetSpecialization()
        return spec == 2 -- 2 = Vengeance
    end

    if not IsVengeanceDH() then
        SoulsTrackerVeng:Hide()
        SoulsTrackerVeng:UnregisterAllEvents()
        SoulsTrackerVeng:SetScript("OnUpdate", nil)
        return
    end
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local hideWhenMounted = db and db.SoulsTrackerVeng_hideWhenMounted
    if hideWhenMounted and IsMounted() then
        SoulsTrackerVeng:Hide()
        SoulsTrackerVeng:SetScript("OnUpdate", nil)
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        ApplySavedOptions()
        UpdateSouls()
        SoulsTrackerVeng:SetScript("OnUpdate", OnUpdateThrottled)
    elseif event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" then
            UpdateSouls()
        end
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            OnUpdateThrottled(self, updateFrequency) -- force a throttled update
        end
    elseif event == "RUNE_POWER_UPDATE" or event == "RUNE_TYPE_UPDATE" then
        UpdateSouls()
    else
        UpdateSouls()
    end
end)

-- Only show for Vengeance Demon Hunter
local function ShouldShowSoulsBar()
    local _, class = UnitClass("player")
    if class ~= "DEMONHUNTER" then return false end
    local spec = GetSpecialization()
    return spec == 2 -- 2 = Vengeance
end

hooksecurefunc(SoulsTrackerVeng, "Show", function(self)
    if not ShouldShowSoulsBar() then self:Hide() end
end)

-- Expose for manual update/testing
_G.SoulsTrackerVeng_Update = UpdateSouls
