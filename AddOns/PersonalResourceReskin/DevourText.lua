-- Only load for Demon Hunters
local _, class = UnitClass("player")
if class ~= "DEMONHUNTER" then return end

local frame = CreateFrame("Frame", "DevourTextFrame", UIParent)
frame:SetSize(60, 30)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("HIGH")
frame:SetFrameLevel(100)

frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
frame.text:SetAllPoints()
frame.text:SetJustifyH("CENTER")
frame.text:SetJustifyV("MIDDLE")
frame.text:SetText("0")

-- Make it movable (when unlocked)
frame:SetMovable(true)
frame:EnableMouse(false)
frame:RegisterForDrag("LeftButton")
local SavePosition, AnchorDevourText   -- below: remember / put back where you dropped it
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if SavePosition then SavePosition() end
end)

local function ShouldShowDevour()
    local _, class = UnitClass("player")
    if class ~= "DEMONHUNTER" then return false end
    local spec = GetSpecialization()
    return spec == 3 
end


local inVoidMetamorphosis = false

local function UpdateVoidMetamorphosisState()
    if Constants and Constants.UnitPowerSpellIDs and Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID then
        inVoidMetamorphosis = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.VOID_METAMORPHOSIS_SPELL_ID) and true or false
    end
end

local function GetDevourValue()
    if not (Constants and Constants.UnitPowerSpellIDs) then return "0" end

    if inVoidMetamorphosis and Constants.UnitPowerSpellIDs.SILENCE_THE_WHISPERS_SPELL_ID then
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.SILENCE_THE_WHISPERS_SPELL_ID)
        if aura then return tostring(aura.applications) end
    elseif Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID then
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(Constants.UnitPowerSpellIDs.DARK_HEART_SPELL_ID)
        if aura then return tostring(aura.applications) end
    end

    return "0"
end

local LSM = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

DevourTextDB = DevourTextDB or {}
local defaults = {
    devourFont = "Friz Quadrata TT",
    devourFontSize = 20,
    devourAnchorPoint = "CENTER",
    devourStrata = "HIGH",
    devourLocked = false,
    devourAttach = true,   -- sit on the alternate power bar (souls bar) and move with it
    devourX = 0, devourY = 0,           -- offset from the bar's middle (attached)
    devourFreeX = 0, devourFreeY = 0,   -- offset from the screen's middle (not attached)
}

local function CopyDefaults(dest, src)
    for k, v in pairs(src) do
        if dest[k] == nil then dest[k] = v end
    end
end
CopyDefaults(DevourTextDB, defaults)

function ApplyDevourFont()
    local font = LSM:Fetch("font", DevourTextDB.devourFont) or STANDARD_TEXT_FONT
    local size = DevourTextDB.devourFontSize or 20
    frame.text:SetFont(font, size, "OUTLINE")
    frame:SetFrameStrata(DevourTextDB.devourStrata or "HIGH")
end

local options = {
    name = "|cFFA330C9吞噬文字字型|r",
    type = "group",
    args = {
        devourStrata = {
            name = "吞噬文字框架層級",
            desc = "設定吞噬文字的框架層級，控制前後顯示順序。",
            type = "select",
            values = {
                BACKGROUND = "BACKGROUND",
                LOW = "LOW",
                MEDIUM = "MEDIUM",
                HIGH = "HIGH",
                DIALOG = "DIALOG",
                FULLSCREEN = "FULLSCREEN",
                FULLSCREEN_DIALOG = "FULLSCREEN_DIALOG",
                TOOLTIP = "TOOLTIP",
            },
            get = function() return DevourTextDB.devourStrata or "HIGH" end,
            set = function(_, val)
                DevourTextDB.devourStrata = val
                frame:SetFrameStrata(val)
            end,
            order = 2.5,
        },
        devourFont = {
            name = "吞噬文字字型",
            desc = "選擇吞噬文字的字型。",
            type = "select",
            values = function()
                local fonts = LSM:HashTable("font")
                local short = {}
                for k, _ in pairs(fonts) do short[k] = k end
                return short
            end,
            get = function() return DevourTextDB.devourFont or "Friz Quadrata TT" end,
            set = function(_, val)
                DevourTextDB.devourFont = val
                ApplyDevourFont()
            end,
            order = 1,
        },
        devourFontSize = {
            name = "吞噬文字大小",
            desc = "設定吞噬文字的字型大小。",
            type = "range",
            min = 8, max = 48, step = 1,
            get = function() return DevourTextDB.devourFontSize or 20 end,
            set = function(_, val)
                DevourTextDB.devourFontSize = val
                ApplyDevourFont()
            end,
            order = 2,
        },
        devourAttach = {
            name = "對齊靈魂能量條",
            desc = "啟用：文字對齊替代能量（靈魂）條並隨之移動。停用：文字保留在你放置的畫面位置。",
            type = "toggle",
            order = 2.6,
            get = function() return DevourTextDB.devourAttach ~= false end,
            set = function(_, val) DevourTextDB.devourAttach = val; if AnchorDevourText then AnchorDevourText() end end,
        },
        devourX = {
            name = "左右位置",
            type = "range", min = -600, max = 600, step = 1, order = 2.7,
            get = function() return DevourTextDB.devourAttach ~= false and (DevourTextDB.devourX or 0) or (DevourTextDB.devourFreeX or 0) end,
            set = function(_, val)
                if DevourTextDB.devourAttach ~= false then DevourTextDB.devourX = val else DevourTextDB.devourFreeX = val end
                if AnchorDevourText then AnchorDevourText() end
            end,
        },
        devourY = {
            name = "上下位置",
            type = "range", min = -600, max = 600, step = 1, order = 2.8,
            get = function() return DevourTextDB.devourAttach ~= false and (DevourTextDB.devourY or 0) or (DevourTextDB.devourFreeY or 0) end,
            set = function(_, val)
                if DevourTextDB.devourAttach ~= false then DevourTextDB.devourY = val else DevourTextDB.devourFreeY = val end
                if AnchorDevourText then AnchorDevourText() end
            end,
        },
        resetDevourPos = {
            name = "重設位置",
            type = "execute", order = 2.9,
            func = function()
                DevourTextDB.devourX, DevourTextDB.devourY, DevourTextDB.devourFreeX, DevourTextDB.devourFreeY = 0, 0, 0, 0
                if AnchorDevourText then AnchorDevourText() end
            end,
        },
        lockDevourText = {
            name = "鎖定吞噬文字",
            desc = "鎖定吞噬文字的位置（停用拖曳）。",
            type = "execute",
            order = 3,
            func = function()
                frame:EnableMouse(false)
                DevourTextDB.devourLocked = true
            end,
            disabled = function() return DevourTextDB.devourLocked end,
        },
        unlockDevourText = {
            name = "解鎖吞噬文字",
            desc = "解鎖吞噬文字以便拖曳。",
            type = "execute",
            order = 4,
            func = function()
                frame:EnableMouse(true)
                DevourTextDB.devourLocked = false
            end,
            disabled = function() return not DevourTextDB.devourLocked end,
        },
    },
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    ApplyDevourFont()
end)


local function OnInitialize()
    CopyDefaults(DevourTextDB, defaults)
    ApplyDevourFont()
    if DevourTextDB.devourLocked then
        frame:EnableMouse(false)
    else
        frame:EnableMouse(true)
    end
    if PersonalResourceReskinPlus_Options then
        PersonalResourceReskinPlus_Options.RegisterSubOptions("DevourText", options)
    end
end

OnInitialize()

local function UpdateDevourText()
    if ShouldShowDevour() then
        local value = GetDevourValue()
        frame.text:SetText(value or "0")
        frame:Show()
    else
        frame:Hide()
    end
end

local BuildTicks  -- forward declaration for use in event handler

frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_AURA" then
        local unit = ...
        if unit ~= "player" then return end
    end
    local wasVoidMeta = inVoidMetamorphosis
    UpdateVoidMetamorphosisState()
    UpdateDevourText()
    -- Rebuild ticks if void metamorphosis state changed (30 vs 35/50 max)
    if inVoidMetamorphosis ~= wasVoidMeta then
        BuildTicks(true)
    end
end)

-- the souls bar of the Personal Resource Display (made late by the game,
-- sometimes after login / reload - so we look again a few times)
local function GetAltBar()
    local prd = rawget(_G, "PersonalResourceDisplayFrame")
    local altBar = prd and prd.AlternatePowerBar or nil
    local anchor = altBar and (altBar.background or altBar) or nil
    return altBar, anchor
end

local function AnchorToPRDBar()
    if InCombatLockdown() and frame:IsProtected() then return end
    local altBar, anchor = GetAltBar()
    frame:ClearAllPoints()
    if DevourTextDB.devourAttach ~= false and altBar and anchor then
        frame:SetParent(altBar)
        frame:SetPoint("CENTER", anchor, "CENTER", DevourTextDB.devourX or 0, DevourTextDB.devourY or 0)
    else
        frame:SetParent(UIParent)
        frame:SetPoint("CENTER", UIParent, "CENTER", DevourTextDB.devourFreeX or 0, DevourTextDB.devourFreeY or 0)
    end
    frame:SetUserPlaced(false)   -- our own saved spot, not the game's layout cache
    frame:SetFrameStrata(DevourTextDB.devourStrata or "HIGH")
    frame:SetFrameLevel(100)
    -- Re-enforce lock state after re-parent (SetParent can reset mouse)
    frame:EnableMouse(not DevourTextDB.devourLocked)
end
AnchorDevourText = AnchorToPRDBar

-- dropped after dragging: keep that spot (relative to the bar when attached)
SavePosition = function()
    local altBar, anchor = GetAltBar()
    local attached = DevourTextDB.devourAttach ~= false and altBar and anchor
    local host = attached and anchor or UIParent
    local fx, fy = frame:GetCenter()
    local hx, hy = host:GetCenter()
    if not (fx and hx) then return end
    local fs, hs = frame:GetEffectiveScale(), host:GetEffectiveScale()
    local dx = (fx * fs - hx * hs) / fs
    local dy = (fy * fs - hy * hs) / fs
    if attached then
        DevourTextDB.devourX, DevourTextDB.devourY = math.floor(dx + 0.5), math.floor(dy + 0.5)
    else
        DevourTextDB.devourFreeX, DevourTextDB.devourFreeY = math.floor(dx + 0.5), math.floor(dy + 0.5)
    end
    AnchorToPRDBar()
end

AnchorToPRDBar()

local function HookPRDBar()
    local prd = _G and _G.PersonalResourceDisplayFrame or nil
    local altBar = prd and prd.AlternatePowerBar or nil
    local background = altBar and altBar.background or nil
    if altBar and not altBar._devourTextShowHooked and altBar.HookScript then
        altBar._devourTextShowHooked = true
        altBar:HookScript("OnShow", function() AnchorToPRDBar() end)
    end
    if background and not background._devourTextHooked then
        background._devourTextHooked = true
        hooksecurefunc(background, "SetPoint", function()
            AnchorToPRDBar()
        end)
    end
    if prd and not prd._devourTextEditModeHooked then
        prd._devourTextEditModeHooked = true
        hooksecurefunc(prd, "SetPoint", function()
            AnchorToPRDBar()
        end)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event)
    -- the saved settings are only there now (after this file ran)
    if type(DevourTextDB) ~= "table" then DevourTextDB = {} end
    CopyDefaults(DevourTextDB, defaults)
    ApplyDevourFont()
    AnchorToPRDBar()
    HookPRDBar()
    -- the game may make the souls bar a moment later: look again
    for _, t in ipairs({ 0.5, 1.5, 3, 6 }) do
        C_Timer.After(t, function() AnchorToPRDBar(); HookPRDBar() end)
    end
end)

UpdateDevourText()

-- ======================================================
-- Static Tick Marks on AlternatePowerBar
-- Talent 1247534 → 35 max → 7 ticks (every 5)
-- No talent        → 50 max → 10 ticks (every 5)
-- ======================================================
local TICK_TALENT_SPELL_ID = 1247534
local TICK_WIDTH = 2
local TICK_COLOR = { 0, 0, 0, 1 } -- black

local tickPool = {}        -- reusable texture pool
local activeTickCount = 0  -- how many ticks currently shown
local lastTickMax = nil    -- last known max to avoid redundant rebuilds
local lastTickBarW = nil   -- last known bar width
local lastTickBarH = nil   -- last known bar height
local tickSizeHooked = false -- whether we've hooked SetWidth/SetHeight

local function GetTickAltBar()
    local prd = rawget(_G, "PersonalResourceDisplayFrame")
    return prd and prd.AlternatePowerBar or nil
end

local function GetOrCreateTick(index, parent)
    if tickPool[index] then
        return tickPool[index]
    end
    local tick = parent:CreateTexture(nil, "OVERLAY", nil, 7)
    tick:SetColorTexture(TICK_COLOR[1], TICK_COLOR[2], TICK_COLOR[3], TICK_COLOR[4])
    tickPool[index] = tick
    return tick
end

BuildTicks = function(forceRebuild)
    local altBar = GetTickAltBar()
    if not altBar then return end

    -- Determine max based on void metamorphosis / talent
    local maxSouls
    if inVoidMetamorphosis then
        maxSouls = 30  -- Collapsing Star cost
    else
        local hasTalent = IsPlayerSpell and IsPlayerSpell(TICK_TALENT_SPELL_ID) or false
        maxSouls = hasTalent and 35 or 50
    end
    local numTicks = (maxSouls / 5) - 1  -- internal dividers only (5, 6, or 9)

    local barWidth = altBar:GetWidth()
    local barHeight = altBar:GetHeight()
    if barWidth == 0 then barWidth = 200 end
    if barHeight == 0 then barHeight = 15 end

    -- Skip rebuild if nothing changed
    if not forceRebuild and lastTickMax == maxSouls and lastTickBarW == barWidth and lastTickBarH == barHeight then
        return
    end
    lastTickMax = maxSouls
    lastTickBarW = barWidth
    lastTickBarH = barHeight

    -- Hide all old ticks
    for i = 1, #tickPool do
        tickPool[i]:Hide()
    end

    -- Total segments = maxSouls / 5, so internal dividers = segments - 1
    for i = 1, numTicks do
        local tick = GetOrCreateTick(i, altBar)
        tick:SetSize(TICK_WIDTH, barHeight)
        tick:ClearAllPoints()
        local xOffset = (barWidth / (numTicks + 1)) * i
        tick:SetPoint("LEFT", altBar, "LEFT", xOffset - (TICK_WIDTH / 2), 0)
        tick:Show()
    end

    activeTickCount = numTicks

    -- Hook size changes once so ticks reposition when bar is resized by the addon
    if not tickSizeHooked then
        tickSizeHooked = true
        hooksecurefunc(altBar, "SetWidth", function() BuildTicks() end)
        hooksecurefunc(altBar, "SetHeight", function() BuildTicks() end)
        hooksecurefunc(altBar, "SetSize", function() BuildTicks() end)
    end
end

-- Force rebuild on next call (e.g. talent change)
local function InvalidateTicks()
    lastTickMax = nil
    lastTickBarW = nil
    lastTickBarH = nil
    BuildTicks(true)
end

-- Listen for talent changes and spec changes to rebuild ticks
local tickFrame = CreateFrame("Frame")
tickFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
tickFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
tickFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
tickFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
tickFrame:SetScript("OnEvent", function(_, event)
    -- Small delay so talent APIs are ready after config commit
    C_Timer.After(0.2, function()
        if ShouldShowDevour() then
            InvalidateTicks()
        else
            -- Hide ticks if not Devourer spec
            for i = 1, #tickPool do
                tickPool[i]:Hide()
            end
            lastTickMax = nil
        end
    end)
end)

-- Initial build (delayed so PRD is ready)
C_Timer.After(1, function()
    if ShouldShowDevour() then
        BuildTicks()
    end
end)
