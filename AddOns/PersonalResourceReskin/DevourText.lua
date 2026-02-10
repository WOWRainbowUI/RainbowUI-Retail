

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
    if DemonHunterSoulFragmentsBar and DemonHunterSoulFragmentsBar.GetValue then
        return DemonHunterSoulFragmentsBar:GetValue()
    end
    return 0
end

local LSM = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local defaults = {
    profile = {
        devourFont = "Friz Quadrata TT",
        devourFontSize = 20,
        devourAnchorPoint = "CENTER"
    }
}

local db

local function ApplyDevourFont()
    if db and db.profile and db.profile.devourFont then
        local font = LSM:Fetch("font", db.profile.devourFont) or STANDARD_TEXT_FONT
        local size = db.profile.devourFontSize or 20
        frame.text:SetFont(font, size, "OUTLINE")
    end
end

local options = {
    name = "|cFFA330C9Devour Text Font|r",
    type = "group",
    args = {
        devourFont = {
            name = "Devour Text Font",
            desc = "Select a font for the Devour text.",
            type = "select",
            values = function() return LSM:HashTable("font") end,
            get = function()
                return db and db.profile and db.profile.devourFont or "Friz Quadrata TT"
            end,
            set = function(_, val)
                if db and db.profile then
                    db.profile.devourFont = val
                    ApplyDevourFont()
                end
            end,
            order = 1,
        },
        devourFontSize = {
            name = "Devour Text Size",
            desc = "Set the font size for the Devour text.",
            type = "range",
            min = 8, max = 48, step = 1,
            get = function()
                return db and db.profile and db.profile.devourFontSize or 20
            end,
            set = function(_, val)
                if db and db.profile then
                    db.profile.devourFontSize = val
                    ApplyDevourFont()
                end
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
                if db and db.profile then db.profile.devourLocked = true end
            end,
            disabled = function() return db and db.profile and db.profile.devourLocked end,
        },
        unlockDevourText = {
            name = "Unlock Devour Text",
            desc = "Unlock the Devour text for dragging.",
            type = "execute",
            order = 4,
            func = function()
                frame:EnableMouse(true)
                if db and db.profile then db.profile.devourLocked = false end
            end,
            disabled = function() return db and db.profile and not db.profile.devourLocked end,
        },
    },
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    ApplyDevourFont()
end)


local function OnInitialize()
    db = LibStub("AceDB-3.0"):New("DevourTextDB", defaults, true)
    ApplyDevourFont()
    if db and db.profile and db.profile.devourLocked then
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
        ApplyDevourFont()
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
    local prd = _G.PersonalResourceDisplayFrame
    local altBar = prd and prd.AlternatePowerBar
    local background = altBar and altBar.background
    if altBar and background then
        frame:SetParent(altBar)
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", background, "CENTER", 0, 0)
    else
        frame:SetParent(UIParent)
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
end

AnchorToPRDBar()

local function HookPRDBar()
    local prd = _G.PersonalResourceDisplayFrame
    local altBar = prd and prd.AlternatePowerBar
    local background = altBar and altBar.background
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
