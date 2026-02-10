local LSM = LibStub("LibSharedMedia-3.0")

local IRONFUR_SPELL_ID = 192081
local BASE_SEGMENT_DURATION = 7
local REINFORCED_FUR_ID = 393611
local GUARDIAN_OF_ELUNE_ID = 155578
local MANGLE_SPELL_ID = 33917
local GOOE_MANGLE_WINDOW = 5 -- seconds to allow Ironfur after Mangle

local lastMangleTime = 0
local gooeBonusActive = false

local function HasTalent(spellID)
    -- Use GetSpellInfo as a fallback for talent detection if IsPlayerSpell is deprecated
    if C_Spell and C_Spell.IsSpellKnown then
        return C_Spell.IsSpellKnown(spellID)
    elseif IsPlayerSpell then
        return IsPlayerSpell(spellID)
    else
        local name = GetSpellInfo(spellID)
        return name ~= nil
    end
end

local function GetSegmentDuration(forceGoOE)
    local dur = BASE_SEGMENT_DURATION
    if HasTalent(REINFORCED_FUR_ID) then
        dur = dur + 2
    end
    if forceGoOE then
        dur = dur + 3
    end
    return dur
end
local MAX_SEGMENTS = 30 -- Arbitrary, can be increased if needed

-- Standalone DB like other files
GuardianIronfurTrackerDB = GuardianIronfurTrackerDB or {}
local defaults = {
    width = 180,
    height = 24,
    maxSegments = 6,
    segmentColor = {0.5, 0.8, 1, 1},
    tickColor = {0, 0, 0, 1},
    bgColor = {0.08, 0.08, 0.08, 0.85},
    posX = 0,
    posY = -200,
    enabled = true,
    segmentTexture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
    fontPosition = "CENTER",
    fontSize = 20,
}

-- Only apply defaults after saved variables are loaded (PLAYER_ENTERING_WORLD)
local function ApplyDefaultsToDB()
    for k, v in pairs(defaults) do
        if GuardianIronfurTrackerDB[k] == nil then
            GuardianIronfurTrackerDB[k] = v
        end
    end
end

local ironfurBar = CreateFrame("Frame", "GuardianIronfurTracker", UIParent)
ironfurBar.bg = ironfurBar:CreateTexture(nil, "BACKGROUND")
-- Set the bar's frame strata to "LOW"
ironfurBar:SetFrameStrata("LOW")
ironfurBar:SetSize(GuardianIronfurTrackerDB.width or 180, GuardianIronfurTrackerDB.height or 24)
do
    local bgColor = GuardianIronfurTrackerDB.bgColor or {0.08, 0.08, 0.08, 0.85}
    ironfurBar.bg:SetColorTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    ironfurBar:SetPoint("CENTER", UIParent, "CENTER", GuardianIronfurTrackerDB.posX or 0, GuardianIronfurTrackerDB.posY or -200)
end
ironfurBar.bg:SetAllPoints(ironfurBar)
ironfurBar:SetMovable(true)
ironfurBar:EnableMouse(true)
ironfurBar:RegisterForDrag("LeftButton")
ironfurBar:SetScript("OnDragStart", function(self) self:StartMoving() end)
ironfurBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local uix, uiy = UIParent:GetCenter()
    local posX = x - uix
    local posY = y - uiy
    GuardianIronfurTrackerDB.posX = posX
    GuardianIronfurTrackerDB.posY = posY
end)
ironfurBar.segments = {}

-- Create or update segments
local function CreateOrUpdateSegments()
    local segCount = GuardianIronfurTrackerDB.maxSegments or 6
    local textureKey = GuardianIronfurTrackerDB.segmentTexture or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    local texture = LSM:Fetch("statusbar", textureKey) or textureKey
    local inset = 2
    local segWidth = (GuardianIronfurTrackerDB.width or 180) - inset * 2
    local segHeight = (GuardianIronfurTrackerDB.height or 24) - inset * 2
    for i = 1, segCount do
        local seg = ironfurBar.segments[i]
        if not seg then
            seg = CreateFrame("StatusBar", nil, ironfurBar)
            seg:SetMinMaxValues(0, GetSegmentDuration())
            seg:SetValue(0)
            seg.tick = seg:CreateTexture(nil, "OVERLAY")
            seg.tick:SetPoint("RIGHT", seg, "RIGHT", 0, 0)
            seg.tick:Hide()
            ironfurBar.segments[i] = seg
        end
        seg:SetStatusBarTexture(texture)
        seg:SetSize(segWidth, segHeight)
        seg:ClearAllPoints()
        seg:SetPoint("LEFT", ironfurBar, "LEFT", inset, 0)
        seg:Hide()
        local tickC = GuardianIronfurTrackerDB.tickColor or {0, 0, 0, 1}
        seg.tick:SetColorTexture(tickC[1], tickC[2], tickC[3], tickC[4])
        seg.tick:SetSize(2, segHeight)
    end
end

-- Initial segment creation
CreateOrUpdateSegments()

-- Add a FontString to display a number in the center of the bar
local centerText = CreateFrame("Frame", nil, ironfurBar)
centerText:SetAllPoints(ironfurBar)
centerText:SetFrameStrata("MEDIUM")
centerText.text = centerText:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
centerText.text:SetPoint("CENTER", centerText, "CENTER", 0, 0)
centerText.text:SetText("")
centerText.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
centerText.text:SetTextColor(1, 1, 1, 1)

local activeSegments = {}

-- Add a helper to update font position
local function UpdateFontPosition()
    local val = GuardianIronfurTrackerDB.fontPosition or "CENTER"
    if val == "LEFT" then
        centerText.text:ClearAllPoints()
        centerText.text:SetPoint("LEFT", centerText, "LEFT", 10, 0)
        centerText.text:SetJustifyH("LEFT")
    elseif val == "RIGHT" then
        centerText.text:ClearAllPoints()
        centerText.text:SetPoint("RIGHT", centerText, "RIGHT", -10, 0)
        centerText.text:SetJustifyH("RIGHT")
    else
        centerText.text:ClearAllPoints()
        centerText.text:SetPoint("CENTER", centerText, "CENTER", 0, 0)
        centerText.text:SetJustifyH("CENTER")
    end
end

local function IsGuardianDruidOrHasIronfur()
    local _, class = UnitClass("player")
    if class == "DRUID" then
        local spec = GetSpecialization()
        local specID = spec and GetSpecializationInfo(spec)
        if specID == 104 then return true end
    end
    -- Check if player has Ironfur spell (talented)
    if C_Spell and C_Spell.IsSpellKnown then
        return C_Spell.IsSpellKnown(192081)
    elseif IsPlayerSpell then
        return IsPlayerSpell(192081)
    else
        local name = GetSpellInfo(192081)
        return name ~= nil
    end
end

-- Only show bar if Guardian Druid or talented Ironfur
local function InBearForm()
    -- Bear Form is form id 1 for druids
    return (GetShapeshiftFormID and GetShapeshiftFormID() == 1) or (GetShapeshiftForm and GetShapeshiftForm() == 1)
end

local function UpdateSegments()
    if not IsGuardianDruidOrHasIronfur() or not InBearForm() then
        -- Clear all active segments when leaving Bear Form or not eligible
        for i = 1, #activeSegments do
            activeSegments[i] = nil
        end
        ironfurBar:Hide()
        centerText:Hide()
        return
    end
    CreateOrUpdateSegments()
    UpdateFontPosition()
    centerText.text:SetFont("Fonts\\FRIZQT__.TTF", GuardianIronfurTrackerDB.fontSize or 20, "OUTLINE")
    local now = GetTime()
    local shown = 0
    for i, seg in ipairs(ironfurBar.segments) do
        local segData = activeSegments[i]
        if segData and segData.expire > now then
            seg:Show()
            local tickC = GuardianIronfurTrackerDB.tickColor or {0, 0, 0, 1}
            seg.tick:SetColorTexture(tickC[1], tickC[2], tickC[3], tickC[4])
            seg.tick:Show()
            seg:SetMinMaxValues(0, GetSegmentDuration())
            local remaining = segData.expire - now
            seg:SetValue(remaining)
            local c = GuardianIronfurTrackerDB.segmentColor or {0.5, 0.8, 1, 1}
            seg:SetStatusBarColor(c[1], c[2], c[3], c[4])
            -- Move tick to draining end
            local barWidth = seg:GetWidth()
            local percent = remaining / GetSegmentDuration()
            percent = math.max(0, math.min(1, percent))
            local tickX = barWidth * percent
            tickX = math.max(0, math.min(barWidth - seg.tick:GetWidth(), tickX))
            seg.tick:ClearAllPoints()
            seg.tick:SetPoint("LEFT", seg, "LEFT", tickX, 0)
            shown = shown + 1
        else
            seg:Hide()
            seg.tick:Hide()
        end
    end
    -- Display the number of active segments in the center
    if shown > 0 then
        centerText.text:SetText(tostring(shown))
        centerText:Show()
    else
        centerText.text:SetText("")
        centerText:Hide()
    end
    if GuardianIronfurTrackerDB.enabled ~= false then
        ironfurBar:Show()
    else
        ironfurBar:Hide()
    end
end

local function AddIronfurSegment()
    local now = GetTime()
    local useGoOE = false
    if gooeBonusActive and (now - lastMangleTime) <= GOOE_MANGLE_WINDOW then
        useGoOE = true
    end
    gooeBonusActive = false
    for i = 1, MAX_SEGMENTS do
        if not activeSegments[i] or activeSegments[i].expire <= now then
            activeSegments[i] = { expire = now + GetSegmentDuration(useGoOE) }
            break
        end
    end
    UpdateSegments()
end

local function OnUpdate(self, elapsed)
    UpdateSegments()
end

ironfurBar:SetScript("OnUpdate", OnUpdate)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:SetScript("OnEvent", function(_, event, unit, _, spellID)
    if unit ~= "player" then return end
    local now = GetTime()
    if spellID == MANGLE_SPELL_ID and HasTalent(GUARDIAN_OF_ELUNE_ID) then
        lastMangleTime = now
        gooeBonusActive = true
    elseif spellID == IRONFUR_SPELL_ID then
        AddIronfurSegment()
    end
end)

SLASH_IRONFURTRACKER1 = "/ironfurtracker"
SLASH_IRONFURTRACKER2 = "/iftsettings"
SlashCmdList["IRONFURTRACKER"] = function()
    AddIronfurSegment()
end

GuardianIronfurTrackerOptions = {
    type = "group",
    name = "Guardian Ironfur Tracker",
    args = {
        width = {
            order = 6,
            type = "range",
            name = "Bar Width",
            min = 60, max = 400, step = 1,
            get = function() return GuardianIronfurTrackerDB.width or 180 end,
            set = function(_, val)
                GuardianIronfurTrackerDB.width = val
                ironfurBar:SetWidth(val)
                CreateOrUpdateSegments()
            end,
        },
        height = {
            order = 7,
            type = "range",
            name = "Bar Height",
            min = 8, max = 80, step = 1,
            get = function() return GuardianIronfurTrackerDB.height or 24 end,
            set = function(_, val)
                GuardianIronfurTrackerDB.height = val
                ironfurBar:SetHeight(val)
                CreateOrUpdateSegments()
            end,
        },
        maxSegments = {
            order = 10,
            type = "range",
            name = "Max Segments",
            min = 1, max = 30, step = 1,
            get = function() return GuardianIronfurTrackerDB.maxSegments or 6 end,
            set = function(_, val)
                GuardianIronfurTrackerDB.maxSegments = val
                CreateOrUpdateSegments()
            end,
        },
        segmentTexture = {
            order = 2,
            type = "select",
            dialogControl = "LSM30_Statusbar",
            name = "Segment Texture",
            desc = "Choose the texture for the Ironfur segments.",
            values = LSM:HashTable("statusbar"),
            get = function()
                return GuardianIronfurTrackerDB.segmentTexture or "Interface\\TARGETINGFRAME\\UI-StatusBar"
            end,
            set = function(_, val)
                GuardianIronfurTrackerDB.segmentTexture = val
                CreateOrUpdateSegments()
            end,
        },
        segmentColor = {
            order = 4,
            type = "color",
            name = "Segment Color",
            hasAlpha = true,
            get = function() return unpack(GuardianIronfurTrackerDB.segmentColor or {0.5, 0.8, 1, 1}) end,
            set = function(_, r, g, b, a)
                GuardianIronfurTrackerDB.segmentColor = {r, g, b, a}
                for _, seg in ipairs(ironfurBar.segments) do
                    seg:SetStatusBarColor(r, g, b, a)
                end
            end,
        },
        tickColor = {
            order = 5,
            type = "color",
            name = "Tick Color",
            hasAlpha = true,
            get = function() return unpack(GuardianIronfurTrackerDB.tickColor or {0, 0, 0, 1}) end,
            set = function(_, r, g, b, a)
                GuardianIronfurTrackerDB.tickColor = {r, g, b, a}
                for _, seg in ipairs(ironfurBar.segments) do
                    seg.tick:SetColorTexture(r, g, b, a)
                end
            end,
        },
        bgColor = {
            order = 3,
            type = "color",
            name = "Background Color",
            hasAlpha = true,
            get = function() return unpack(GuardianIronfurTrackerDB.bgColor or {0.08, 0.08, 0.08, 0.85}) end,
            set = function(_, r, g, b, a)
                GuardianIronfurTrackerDB.bgColor = {r, g, b, a}
                ironfurBar.bg:SetColorTexture(r, g, b, a)
            end,
        },
        posX = {
            order = 8,
            type = "range",
            name = "Horizontal Offset",
            min = -400, max = 400, step = 1,
            get = function() return GuardianIronfurTrackerDB.posX or 0 end,
            set = function(_, val)
                GuardianIronfurTrackerDB.posX = val
                ironfurBar:ClearAllPoints()
                ironfurBar:SetPoint("CENTER", UIParent, "CENTER", val, GuardianIronfurTrackerDB.posY or -200)
            end,
        },
        posY = {
            order = 9,
            type = "range",
            name = "Vertical Offset",
            min = -400, max = 400, step = 1,
            get = function() return GuardianIronfurTrackerDB.posY or -200 end,
            set = function(_, val)
                GuardianIronfurTrackerDB.posY = val
                ironfurBar:ClearAllPoints()
                ironfurBar:SetPoint("CENTER", UIParent, "CENTER", GuardianIronfurTrackerDB.posX or 0, val)
            end,
        },
        fontPosition = {
            order = 11,
            type = "select",
            name = "Font Position",
            desc = "Choose the position of the number on the bar.",
            values = {
                LEFT = "Left",
                CENTER = "Center",
                RIGHT = "Right",
            },
            get = function() return GuardianIronfurTrackerDB.fontPosition or "CENTER" end,
            set = function(_, val)
                GuardianIronfurTrackerDB.fontPosition = val
                -- Re-anchor font
                if val == "LEFT" then
                    centerText.text:ClearAllPoints()
                    centerText.text:SetPoint("LEFT", centerText, "LEFT", 10, 0)
                    centerText.text:SetJustifyH("LEFT")
                elseif val == "RIGHT" then
                    centerText.text:ClearAllPoints()
                    centerText.text:SetPoint("RIGHT", centerText, "RIGHT", -10, 0)
                    centerText.text:SetJustifyH("RIGHT")
                else
                    centerText.text:ClearAllPoints()
                    centerText.text:SetPoint("CENTER", centerText, "CENTER", 0, 0)
                    centerText.text:SetJustifyH("CENTER")
                end
            end,
        },
        fontSize = {
            order = 12,
            type = "range",
            name = "Font Size",
            desc = "Set the font size for the center number.",
            min = 8, max = 48, step = 1,
            get = function() return GuardianIronfurTrackerDB.fontSize or 20 end,
            set = function(_, val)
                GuardianIronfurTrackerDB.fontSize = val
                centerText.text:SetFont("Fonts\\FRIZQT__.TTF", val, "OUTLINE")
            end,
        },
    }
}

-- Register options as a standalone AceConfig page
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfig:RegisterOptionsTable("GuardianIronfurTracker", GuardianIronfurTrackerOptions)
AceConfigDialog:AddToBlizOptions("GuardianIronfurTracker", "Guardian Ironfur Tracker")

_G.GuardianIronfurTrackerOptions = GuardianIronfurTrackerOptions
_G.GuardianIronfurTracker_Update = UpdateSegments
-- Forward declare so it exists for event handler

local ticker

local function CreateIronfurBar()
    if ironfurBar then return end
    ironfurBar = CreateFrame("Frame", "GuardianIronfurTracker", UIParent)
    ironfurBar.bg = ironfurBar:CreateTexture(nil, "BACKGROUND")
    ironfurBar:SetFrameStrata("MEDIUM")
    ironfurBar:SetMovable(true)
    ironfurBar:EnableMouse(true)
    ironfurBar:RegisterForDrag("LeftButton")
    ironfurBar:SetScript("OnDragStart", function(self) self:StartMoving() end)
    ironfurBar:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local uix, uiy = UIParent:GetCenter()
        local posX = x - uix
        local posY = y - uiy
        GuardianIronfurTrackerDB.posX = posX
        GuardianIronfurTrackerDB.posY = posY
    end)
    ironfurBar.segments = {}
end

local function ApplySavedSettingsToBar()
    if not ironfurBar then return end
    ironfurBar:SetWidth(GuardianIronfurTrackerDB.width or 180)
    ironfurBar:SetHeight(GuardianIronfurTrackerDB.height or 24)
    ironfurBar.bg:SetColorTexture(unpack(GuardianIronfurTrackerDB.bgColor or {0.08, 0.08, 0.08, 0.85}))
    ironfurBar:ClearAllPoints()
    ironfurBar:SetPoint("CENTER", UIParent, "CENTER", GuardianIronfurTrackerDB.posX or 0, GuardianIronfurTrackerDB.posY or -200)
    for _, seg in ipairs(ironfurBar.segments) do
        seg:SetStatusBarColor(unpack(GuardianIronfurTrackerDB.segmentColor or {0.5, 0.8, 1, 1}))
        seg.tick:SetColorTexture(unpack(GuardianIronfurTrackerDB.tickColor or {0, 0, 0, 1}))
    end
end

local function InitIronfurBar()
    ApplyDefaultsToDB()
    CreateIronfurBar()
    ApplySavedSettingsToBar()
    CreateOrUpdateSegments()
    if ticker then
        ticker:Cancel()
    end
    ticker = C_Timer.NewTicker(0.01, UpdateSegments)
end

-- Register options and initialize bar/settings after entering world
local function RegisterGuardianIronfurTrackerOptions()
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    AceConfig:RegisterOptionsTable("GuardianIronfurTracker", GuardianIronfurTrackerOptions)
    -- Only add to BlizOptions if not already present
    if not (AceConfigDialog.BlizOptions and AceConfigDialog.BlizOptions["GuardianIronfurTracker"]) then
        AceConfigDialog:AddToBlizOptions("GuardianIronfurTracker", "Guardian Ironfur Tracker")
    end
    _G.GuardianIronfurTrackerOptions = GuardianIronfurTrackerOptions
    _G.GuardianIronfurTracker_Update = UpdateSegments
end


local optionsEventFrame = CreateFrame("Frame")
optionsEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
optionsEventFrame:SetScript("OnEvent", function(self, event, ...)
    RegisterGuardianIronfurTrackerOptions()
    if InitIronfurBar then InitIronfurBar() end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
