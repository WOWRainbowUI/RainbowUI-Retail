-- WarriorTracker.lua
-- Based on SoulsTrackerVeng by Argium, adapted for Warrior
-- Modified for PersonalResourceReskin by [Ckraigfriend], 2026
-- This file is licensed under the GNU General Public License v3.0 (GPL-3.0)
-- See LICENSE for details.

-- WarriorTracker options
local function get(info)
    local key = info[#info]
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return nil end
    return db["WarriorTracker_"..key]
end

local function set(info, value)
    local key = info[#info]
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return end
    db["WarriorTracker_"..key] = value
    if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
end

-- Expose bar for options handlers
local bar

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local function GetLSMStatusbarList()
    if not LSM then return { ["Blizzard"] = "Blizzard" } end
    local bars = LSM:HashTable("statusbar")
    local list = {}
    for k, v in pairs(bars) do list[k] = k end
    return list
end

local WarriorTrackerOptions = {
    type = "group",
    name = "|cFFC79C6EWarrior Tracker|r",
    order = 901,
    args = {
        header = {
            order = 0,
            type = "header",
            name = "Warrior Resource Tracker Bar",
        },
        fillingTexture = {
            order = 2.5,
            type = "select",
            name = "Filling Texture",
            desc = "Select the filling (main bar) texture from SharedMedia.",
            values = function() return GetLSMStatusbarList() end,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return db and db.WarriorTracker_fillingTexture or "Blizzard"
            end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.WarriorTracker_fillingTexture = val
                if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
            end,
        },
        enabled = {
            order = 1,
            type = "toggle",
            name = "Enable Warrior Tracker",
            desc = "Show the segmented resource bar for Warrior.",
            get = function() return get({"enabled"}) ~= false end,
            set = function(_, val)
                set({"enabled"}, val)
                WarriorTrackerFrame:SetShown(val)
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
                if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
            end,
        },
        segmentGradientStart = {
            order = 8,
            type = "color",
            name = "Segment Gradient Start",
            hasAlpha = true,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                local c = db and db.WarriorTracker_segmentGradientStart or {0.78, 0.61, 0.43, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.WarriorTracker_segmentGradientStart = {r, g, b, a}
                if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
            end,
        },
        segmentGradientEnd = {
            order = 9,
            type = "color",
            name = "Segment Gradient End",
            hasAlpha = true,
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                local c = db and db.WarriorTracker_segmentGradientEnd or {0.50, 0.30, 0.15, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.WarriorTracker_segmentGradientEnd = {r, g, b, a}
                if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
            end,
        },
        hideWhenMounted = {
            order = 10,
            type = "toggle",
            name = "Hide When Mounted",
            desc = "Hide the resource bar while mounted.",
            get = function()
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                return db and db.WarriorTracker_hideWhenMounted or false
            end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.WarriorTracker_hideWhenMounted = val
                if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
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
                _G.WarriorTrackerFrame:SetWidth(val)
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
                _G.WarriorTrackerFrame:SetHeight(val)
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
                local x = db and (db.WarriorTracker_xOffset or 0) or 0
                db.WarriorTracker_yOffset = val
                _G.WarriorTrackerFrame:ClearAllPoints()
                _G.WarriorTrackerFrame:SetPoint("CENTER", UIParent, "CENTER", x, val)
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
            get = function() local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile return db and (db.WarriorTracker_xOffset or 0) or 0 end,
            set = function(_, val)
                local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if not db then return end
                db.WarriorTracker_xOffset = val
                if _G.WarriorTracker_Update then _G.WarriorTracker_Update() end
            end,
            disabled = function() return get({"anchorToPRD"}) end,
        },
        numSegments = {
            order = 11,
            type = "range",
            name = "Number of Segments",
            desc = "How many segments to divide the bar into.",
            min = 1, max = 10, step = 1,
            get = function() return get({"numSegments"}) or 6 end,
            set = function(_, val)
                set({"numSegments"}, val)
            end,
        },
    },
}

_G.WarriorTrackerOptions = WarriorTrackerOptions

-- WarriorTracker main code
-- Standalone resource tracker for Warrior

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
    if not db or not db.WarriorTracker_anchorToPRD then return nil end
    local target = db.WarriorTracker_anchorTarget or "HEALTH"
    return (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
end

local WarriorTracker = CreateFrame("Frame", "WarriorTrackerFrame", UIParent)
WarriorTracker:SetSize(120, 24)
WarriorTracker:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
WarriorTracker:Hide()


local DEFAULT_NUM_SEGMENTS = 4
local BAR_COLOR = {0.78, 0.61, 0.43, 1} -- Warrior brown/tan color
local BAR_BG_COLOR = {0.08, 0.08, 0.08, 0.75}

-- Whirlwind stack logic (from user)
local Whirlwind = {}
local iwStacks    = 0
local iwExpiresAt = nil
local noConsumeUntil     = 0
local seenCastGUID       = {}
Whirlwind.IW_MAX_STACKS = 4
local IW_DURATION   = 20
local REQUIRED_TALENT_ID = 12950   -- Improved Whirlwind talent
local UNHINGED_TALENT_ID = 386628  -- Unhinged
local GENERATOR_IDS = {
    [190411] = true, -- Whirlwind
    [435607] = true, -- Thunder Blast
}
local THUNDER_BLAST_ID = 435607
local SPENDER_IDS = {
    [23881]  = true, -- Bloodthirst
    [85288]  = true, -- Raging Blow
    [280735] = true, -- Execute
    [202168] = true, -- Impending Victory
    [184367] = true, -- Rampage
    [335096] = true, -- Bloodbath
    [335097] = true, -- Crushing Blow
    [5308]   = true, -- Execute (base)
}
local function HasUnhingedTalent()
    return C_SpellBook and C_SpellBook.IsSpellKnown(UNHINGED_TALENT_ID) or false
end
local function IsSpellInTargetRange(spellID)
    if C_Spell and C_Spell.IsSpellInRange then
        local ok = C_Spell.IsSpellInRange(spellID, "target")
        if ok ~= nil then return ok end
        if type(CheckInteractDistance) == "function" then
            return CheckInteractDistance("target", 3) == true
        end
        return false
    end
    return true
end
function Whirlwind:OnLoad(powerBar)
        local playerClass = select(2, UnitClass("player"))
        if playerClass == "WARRIOR" then
                powerBar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
                powerBar:RegisterEvent("PLAYER_DEAD")
                powerBar:RegisterEvent("PLAYER_ALIVE")
                powerBar:RegisterEvent("PLAYER_TALENT_UPDATE")
                powerBar:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
                powerBar:RegisterEvent("TRAIT_CONFIG_UPDATED")
        end
end
function Whirlwind:OnEvent(powerBar, event, ...)
    if event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" or event == "TRAIT_CONFIG_UPDATED" then
        return
    end
    if event == "PLAYER_DEAD" or event == "PLAYER_ALIVE" then
            iwStacks = 0
            iwExpiresAt = nil
            seenCastGUID = {}
            return
    end
    local unit, castGUID, spellID = ...
    if unit ~= "player" then return end
    if event ~= "UNIT_SPELLCAST_SUCCEEDED" then return end
    if castGUID and seenCastGUID[castGUID] then return end
    if castGUID then seenCastGUID[castGUID] = true end
    if HasUnhingedTalent() and (
             spellID == 50622 or spellID == 46924 or spellID == 227847 or spellID == 184362 or spellID == 446035
        ) then
        noConsumeUntil = GetTime() + 2
    end
    if GENERATOR_IDS[spellID] or (spellID == 6343 and C_SpellBook and C_SpellBook.IsSpellKnown(THUNDER_BLAST_ID)) then
          local hasTarget =
              UnitExists("target")
              and UnitCanAttack("player", "target")
              and not UnitIsDead("target")
          if hasTarget and not IsSpellInTargetRange(spellID) then return end
          C_Timer.After(0.15, function()
              if UnitAffectingCombat("player") then
                  iwStacks = Whirlwind.IW_MAX_STACKS
                  iwExpiresAt = GetTime() + IW_DURATION
              end
          end)
          return
      end
    if SPENDER_IDS[spellID] then
            if (GetTime() < noConsumeUntil) and (spellID == 23881) then return end
                    if (iwStacks or 0) <= 0 then return end
                    iwStacks = math.max(0, (iwStacks or 0) - 1)
                    if iwStacks == 0 then iwExpiresAt = nil end
            return
    end
end
function Whirlwind:GetStacks()
        if iwExpiresAt and GetTime() >= iwExpiresAt then
                iwStacks = 0
                iwExpiresAt = nil
        end
        return C_SpellBook.IsSpellKnown(REQUIRED_TALENT_ID) and self.IW_MAX_STACKS or nil, iwStacks
end


bar = CreateFrame("StatusBar", nil, WarriorTracker)
bar:SetAllPoints(WarriorTracker)
do
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local texName = db and db.WarriorTracker_fillingTexture or "Blizzard"
    local tex = LSM and LSM:Fetch("statusbar", texName) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    bar:SetStatusBarTexture(tex)
end
bar:SetStatusBarColor(unpack(BAR_COLOR))
-- Background
local bg = bar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(bar)
bg:SetColorTexture(unpack(BAR_BG_COLOR))
bar.bg = bg

-- Dynamic tick drawing
local ticks = {}
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local function UpdateTicks(numSegments)
    for _, tick in ipairs(ticks) do tick:Hide() end
    local w, h = bar:GetWidth(), bar:GetHeight()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local tickTextureName = db and db.WarriorTracker_tickTexture or "Blizzard"
    local tickTexture = LSM and LSM:Fetch("statusbar", tickTextureName) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    for i = 1, (numSegments or DEFAULT_NUM_SEGMENTS) - 1 do
        if not ticks[i] then
            ticks[i] = bar:CreateTexture(nil, "OVERLAY")
        end
        ticks[i]:SetTexture(tickTexture)
        ticks[i]:SetVertexColor(0, 0, 0, 1)
        ticks[i]:SetSize(2, h)
        ticks[i]:SetPoint("LEFT", bar, "LEFT", i * (w / (numSegments or DEFAULT_NUM_SEGMENTS)) - 1, 0)
        ticks[i]:Show()
    end
end
bar:SetScript("OnSizeChanged", function(self)
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    local numSegments = (db and db.WarriorTracker_numSegments) or DEFAULT_NUM_SEGMENTS
    UpdateTicks(numSegments)
end)
bar:GetScript("OnSizeChanged")(bar) -- Initial draw

local function GetTrackedCount()
    local max, stacks = Whirlwind:GetStacks()
    return stacks or 0
end

local function ApplySavedOptions()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not db then return end
    -- Filling texture
    local texName = db.WarriorTracker_fillingTexture or "Blizzard"
    local tex = LSM and LSM:Fetch("statusbar", texName) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    if bar and bar.SetStatusBarTexture then bar:SetStatusBarTexture(tex) end
    -- Color or gradient
    local gradStart = db.WarriorTracker_segmentGradientStart
    local gradEnd = db.WarriorTracker_segmentGradientEnd
    local useGradient = gradStart and gradEnd
    local barTexture = bar and bar.GetStatusBarTexture and bar:GetStatusBarTexture() or nil
    if useGradient and barTexture and barTexture.SetGradient then
        barTexture:SetGradient("HORIZONTAL",
            CreateColor(gradStart[1], gradStart[2], gradStart[3], gradStart[4]),
            CreateColor(gradEnd[1], gradEnd[2], gradEnd[3], gradEnd[4])
        )
    else
        local c = db.WarriorTracker_color or {0.78, 0.61, 0.43, 1}
        if bar and bar.SetStatusBarColor then bar:SetStatusBarColor(unpack(c)) end
        if barTexture and barTexture.SetGradient then
            barTexture:SetColorTexture(c[1], c[2], c[3], c[4])
        end
    end
    -- BG Color
    local bgc = db.WarriorTracker_bgColor or {0.08, 0.08, 0.08, 0.75}
    if bar and bar.bg then bar.bg:SetColorTexture(unpack(bgc)) end
    -- Size
    local w = db.WarriorTracker_width or 120
    local h = db.WarriorTracker_height or 24
    WarriorTracker:SetWidth(w)
    WarriorTracker:SetHeight(h)
    -- Position: anchor to PRD or use X/Y
    WarriorTracker:ClearAllPoints()
    local anchorFrame = GetPRDAnchorFrame()
    if anchorFrame then
        local pos = db.WarriorTracker_anchorPosition or "BELOW"
        local offset = db.WarriorTracker_anchorOffset or 10
        if pos == "ABOVE" then
            WarriorTracker:SetPoint("BOTTOM", anchorFrame, "TOP", 0, offset)
        else
            WarriorTracker:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -offset)
        end
    else
        local x = db.WarriorTracker_xOffset or 0
        local y = db.WarriorTracker_yOffset or -200
        WarriorTracker:SetPoint("CENTER", UIParent, "CENTER", x, y)
    end
    -- Enable/disable
    local enabled = db.WarriorTracker_enabled ~= false
    WarriorTracker:SetShown(enabled)
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
local updateFrequency = 0.066 -- ~15 FPS

local function UpdateTracker()
    ApplySavedOptions()
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    -- Hook to PRD if anchored
    if db and db.WarriorTracker_anchorToPRD and not prdHooked then
        HookPRDAnchor()
    end
    local hideWhenMounted = db and db.WarriorTracker_hideWhenMounted
    local enabled = db and (db.WarriorTracker_enabled ~= false)
    if not enabled or not IsFuryWarrior() then
        WarriorTracker:Hide()
        return
    end
    if hideWhenMounted and IsMounted() then
        WarriorTracker:Hide()
        return
    end
    local max, stacks = Whirlwind:GetStacks()
    local numSegments = (db and db.WarriorTracker_numSegments) or (max or DEFAULT_NUM_SEGMENTS)
    bar:SetMinMaxValues(0, numSegments)
    bar:SetValue(stacks or 0)
    UpdateTicks(numSegments)
    WarriorTracker:Show()
end

local function OnUpdateThrottled(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate >= updateFrequency then
        UpdateTracker()
        lastUpdate = 0
    end
end

WarriorTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
WarriorTracker:RegisterEvent("UNIT_POWER_UPDATE")
WarriorTracker:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
WarriorTracker:RegisterEvent("UNIT_DISPLAYPOWER")
WarriorTracker:RegisterEvent("UNIT_MAXPOWER")
WarriorTracker:RegisterEvent("PLAYER_TALENT_UPDATE")
WarriorTracker:RegisterEvent("PLAYER_REGEN_ENABLED")
WarriorTracker:RegisterEvent("PLAYER_REGEN_DISABLED")
WarriorTracker:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
WarriorTracker:RegisterEvent("PLAYER_DEAD")
WarriorTracker:RegisterEvent("PLAYER_ALIVE")
WarriorTracker:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
WarriorTracker:RegisterEvent("TRAIT_CONFIG_UPDATED")
WarriorTracker:SetScript("OnEvent", function(self, event, ...)
    local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not IsFuryWarrior() then
        WarriorTracker:Hide()
        WarriorTracker:UnregisterAllEvents()
        WarriorTracker:SetScript("OnUpdate", nil)
        return
    end
    local hideWhenMounted = db and db.WarriorTracker_hideWhenMounted
    local enabled = db and (db.WarriorTracker_enabled ~= false)
    if not enabled then
        WarriorTracker:Hide()
        WarriorTracker:SetScript("OnUpdate", nil)
        return
    end
    if hideWhenMounted and IsMounted() then
        WarriorTracker:Hide()
        WarriorTracker:SetScript("OnUpdate", nil)
        return
    end
    -- ...existing code...
end)

-- Expose for manual update/testing
_G.WarriorTracker_Update = UpdateTracker

function IsFuryWarrior()
    local _, class = UnitClass("player")
    if class ~= "WARRIOR" then return false end
    local spec = GetSpecialization and GetSpecialization() or nil
    return spec == 2 -- 2 = Fury
end

hooksecurefunc(WarriorTracker, "Show", function(self)
    if not IsFuryWarrior() then self:Hide() end
end)
