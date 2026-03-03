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

-- Make it movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local function ShouldShowDevour()
    local _, class = UnitClass("player")
    if class ~= "DEMONHUNTER" then return false end
    local spec = GetSpecialization()
    return spec == 3 
end


local function GetDevourValue()
    -- If you want to show a real value, replace this with your logic
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
    name = "|cFFA330C9吞噬文字字型|r",
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

frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
    UpdateDevourText()
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
