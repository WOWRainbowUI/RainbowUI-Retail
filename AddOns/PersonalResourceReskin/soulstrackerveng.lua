-- soulstrackerveng.lua
-- Originally from: Enhanced Cooldown Manager by Argium, Copyright (C) 2023 Argium
-- Modified for PersonalResourceReskin by [Ckraigfriend], 2026
-- This file is licensed under the GNU General Public License v3.0 (GPL-3.0)
-- See LICENSE for details.
-- Changelog:
-- [2026-01-23] Adapted for PersonalResourceReskin by [Ckraigfriend]

-- Only load for Demon Hunters
local _, class = UnitClass("player")
if class ~= "DEMONHUNTER" then return end

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

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local function GetLSMStatusbarList()
    if not LSM then return { ["Blizzard"] = "Blizzard" } end
    local bars = LSM:HashTable("statusbar")
    local list = {}
    for k, v in pairs(bars) do
        local filename = v:match("[^\\/]+$") or v
        list[k] = filename
    end
    return list
end

local SoulsTrackerVengOptions = {
    type = "group",
    name = "|cFFA330C9復仇靈魂碎片|r",
    order = 900,
    args = {
        header = {
            order = 0,
            type = "header",
            name = "復仇惡魔獵人靈魂碎片條",
        },
        fillingTexture = {
            order = 2.5,
            type = "select",
            name = "填充材質",
			desc = "從 SharedMedia 選擇填充（主資源條）的材質。",
            dialogControl = "LSM30_Statusbar",
            values = function() return GetLSMStatusbarList() end,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return db and db.SoulsTrackerVeng_fillingTexture or "Blizzard"
            end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.SoulsTrackerVeng_fillingTexture = val
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
            end,
        },
        tickTexture = {
            order = 2.6,
            type = "select",
            name = "分段材質",
			desc = "從 SharedMedia 選擇分段 (刻度) 的材質。",
            dialogControl = "LSM30_Statusbar",
            values = function() return GetLSMStatusbarList() end,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return db and db.SoulsTrackerVeng_tickTexture or "Blizzard"
            end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.SoulsTrackerVeng_tickTexture = val
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
            end,
        },
        enabled = {
            order = 1,
            type = "toggle",
            name = "啟用追蹤器",
            desc = "顯示復仇惡魔獵人的分段靈魂碎片條。",
            get = function() return get({"enabled"}) ~= false end,
            set = function(_, val)
                set({"enabled"}, val)
                SoulsTrackerVengFrame:SetShown(val)
            end,
        },
        bgColor = {
            order = 3,
            type = "color",
            name = "背景顏色",
            hasAlpha = true,
            get = function()
                local c = get({"bgColor"}) or {0.08, 0.08, 0.08, 0.75}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                set({"bgColor"}, {r, g, b, a})
                if _G.SoulsTrackerVeng_Update then _G.SoulsTrackerVeng_Update() end
            end,
        },
        segmentGradientStart = {
            order = 8,
            type = "color",
            name = "分段漸層起始色",
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
            name = "分段漸層結束色",
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
            name = "騎乘時隱藏",
            desc = "騎乘時隱藏靈魂碎片條。",
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
            name = "寬度",
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
            name = "高度",
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
            name = "垂直位移",
            desc = "未對齊時的垂直位置。",
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
            name = "對齊到個人資源條",
            desc = "附加到個人資源條的血量條或能量條。",
            get = function() return get({"anchorToPRD"}) end,
            set = function(_, val)
                set({"anchorToPRD"}, val)
            end,
        },
        anchorTarget = {
            order = 6.2,
            type = "select",
            name = "對齊目標",
            desc = "選擇要對齊到的個人資源條。",
            values = { HEALTH = "血量條", POWER = "能量條" },
            get = function() return get({"anchorTarget"}) or "HEALTH" end,
            set = function(_, val)
                set({"anchorTarget"}, val)
            end,
            disabled = function() return not get({"anchorToPRD"}) end,
        },
        anchorPosition = {
            order = 6.3,
            type = "select",
            name = "對齊位置",
            desc = "放置在所選個人資源條的上方或下方。",
            values = { ABOVE = "上方", BELOW = "下方" },
            get = function() return get({"anchorPosition"}) or "BELOW" end,
            set = function(_, val)
                set({"anchorPosition"}, val)
            end,
            disabled = function() return not get({"anchorToPRD"}) end,
        },
        anchorOffset = {
            order = 6.4,
            type = "range",
            name = "對齊偏移",
            desc = "對齊時與個人資源條的垂直偏移。",
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
            name = "水平偏移",
            desc = "未對齊時的水平位置。",
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
            name = "原始插件（複製網址）：",
            get = function() return "https://www.curseforge.com/wow/addons/enhanced-cooldown-manager" end,
            set = function() end,
            width = "full",
            dialogControl = "EditBox",
            desc = "原作者 Argium。Logo 可在插件資料夾中找到，檔名為 argium2.tga."
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
bar:SetStatusBarColor(unpack(SOUL_COLOR))
bar:SetFrameStrata("LOW")
-- Background
local bg = bar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(bar)
bg:SetColorTexture(unpack(SOUL_BG_COLOR))
bar.bg = bg
-- Dynamic tick drawing
local ticks = {}
local function UpdateTicks(numSouls)
    for _, tick in ipairs(ticks) do tick:Hide() end
    local w, h = bar:GetWidth(), bar:GetHeight()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local tickTextureName = db and db.SoulsTrackerVeng_tickTexture or "Blizzard"
    local tickTexture = LSM and LSM:Fetch("statusbar", tickTextureName) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    for i = 1, (numSouls or DEFAULT_NUM_SOULS) - 1 do
        if not ticks[i] then
            ticks[i] = bar:CreateTexture(nil, "OVERLAY")
        end
        ticks[i]:SetTexture(tickTexture)
        ticks[i]:SetVertexColor(0, 0, 0, 1)
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
    -- Filling texture
    local texName = db.SoulsTrackerVeng_fillingTexture or "Blizzard"
    local tex = LSM and LSM:Fetch("statusbar", texName) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    if bar and bar.SetStatusBarTexture then bar:SetStatusBarTexture(tex) end
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

ApplySavedOptions() -- Apply initial textures

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
