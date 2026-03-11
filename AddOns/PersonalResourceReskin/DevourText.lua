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
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

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
    devourLocked = false
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
    name = "|cFFA330C9Devour Text Font|r",
    type = "group",
    args = {
        devourStrata = {
            name = "Devour Text Strata",
            desc = "Set the frame strata for the Devour text (controls layering).",
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
            name = "Devour Text Font",
            desc = "Select a font for the Devour text.",
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
            name = "Devour Text Size",
            desc = "Set the font size for the Devour text.",
            type = "range",
            min = 8, max = 48, step = 1,
            get = function() return DevourTextDB.devourFontSize or 20 end,
            set = function(_, val)
                DevourTextDB.devourFontSize = val
                ApplyDevourFont()
            end,
            order = 2,
        },
        lockDevourText = {
            name = "Lock Devour Text",
            desc = "Lock the Devour text position (disable dragging).",
            type = "execute",
            order = 3,
            func = function()
                frame:EnableMouse(false)
                DevourTextDB.devourLocked = true
            end,
            disabled = function() return DevourTextDB.devourLocked end,
        },
        unlockDevourText = {
            name = "Unlock Devour Text",
            desc = "Unlock the Devour text for dragging.",
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

local function AnchorToPRDBar()
    local prd = rawget(_G, "PersonalResourceDisplayFrame")
    local altBar = prd and prd.AlternatePowerBar or nil
    local background = altBar and altBar.background or nil
    if altBar and background then
        frame:SetParent(altBar)
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", background, "CENTER", 0, 0)
    else
        frame:SetParent(UIParent)
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    frame:SetFrameStrata(DevourTextDB.devourStrata or "HIGH")
    frame:SetFrameLevel(100)
    -- Re-enforce lock state after re-parent (SetParent can reset mouse)
    if DevourTextDB.devourLocked or DevourTextDB.devourLocked == nil then
        frame:EnableMouse(false)
    end
end

AnchorToPRDBar()

local function HookPRDBar()
    local prd = _G and _G.PersonalResourceDisplayFrame or nil
    local altBar = prd and prd.AlternatePowerBar or nil
    local background = altBar and altBar.background or nil
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
eventFrame:SetScript("OnEvent", function(_, event)
    AnchorToPRDBar()
    HookPRDBar()
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
