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

local cachedEligible = nil
local cachedSegDuration = nil

local function IsGuardianDruidOrHasIronfur()
    if cachedEligible ~= nil then return cachedEligible end
    local _, class = UnitClass("player")
    if class == "DRUID" then
        local spec = GetSpecialization()
        local specID = spec and GetSpecializationInfo(spec)
        if specID == 104 then cachedEligible = true return true end
    end
    if C_Spell and C_Spell.IsSpellKnown then
        cachedEligible = C_Spell.IsSpellKnown(192081)
    elseif IsPlayerSpell then
        cachedEligible = IsPlayerSpell(192081)
    else
        cachedEligible = GetSpellInfo(192081) ~= nil
    end
    return cachedEligible
end

-- Only show bar if Guardian Druid or talented Ironfur
local function InBearForm()
    -- Bear Form is form id 1 for druids
    return (GetShapeshiftFormID and GetShapeshiftFormID() == 1) or (GetShapeshiftForm and GetShapeshiftForm() == 1)
end

-- Lightweight update: only changes values and tick positions (called from OnUpdate)
local function UpdateSegmentValues()
    if not ironfurBar:IsShown() then return end
    local now = GetTime()
    local segDur = cachedSegDuration or GetSegmentDuration()
    local shown = 0
    for i, seg in ipairs(ironfurBar.segments) do
        local segData = activeSegments[i]
        if segData and segData.expire > now then
            local remaining = segData.expire - now
            seg:SetValue(remaining)
            -- Move tick to draining end
            local barWidth = seg:GetWidth()
            local percent = remaining / segDur
            if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end
            local tickX = barWidth * percent
            local maxX = barWidth - seg.tick:GetWidth()
            if tickX > maxX then tickX = maxX end
            if tickX < 0 then tickX = 0 end
            seg.tick:ClearAllPoints()
            seg.tick:SetPoint("LEFT", seg, "LEFT", tickX, 0)
            if not seg:IsShown() then
                seg:Show()
                seg.tick:Show()
            end
            shown = shown + 1
        else
            if seg:IsShown() then
                seg:Hide()
                seg.tick:Hide()
            end
        end
    end
    if shown > 0 then
        centerText.text:SetText(tostring(shown))
        if not centerText:IsShown() then centerText:Show() end
    else
        centerText.text:SetText("")
        if centerText:IsShown() then centerText:Hide() end
    end
end

-- Full update: checks eligibility, rebuilds styles, then updates values
local function UpdateSegments()
    if not IsGuardianDruidOrHasIronfur() or not InBearForm() then
        for i = 1, #activeSegments do
            activeSegments[i] = nil
        end
        if ironfurBar:IsShown() then ironfurBar:Hide() end
        if centerText:IsShown() then centerText:Hide() end
        return
    end
    cachedSegDuration = GetSegmentDuration()
    CreateOrUpdateSegments()
    UpdateFontPosition()
    centerText.text:SetFont("Fonts\\FRIZQT__.TTF", GuardianIronfurTrackerDB.fontSize or 20, "OUTLINE")
    -- Apply colors once
    local c = GuardianIronfurTrackerDB.segmentColor or {0.5, 0.8, 1, 1}
    local tickC = GuardianIronfurTrackerDB.tickColor or {0, 0, 0, 1}
    for _, seg in ipairs(ironfurBar.segments) do
        seg:SetStatusBarColor(c[1], c[2], c[3], c[4])
        seg:SetMinMaxValues(0, cachedSegDuration)
        seg.tick:SetColorTexture(tickC[1], tickC[2], tickC[3], tickC[4])
    end
    if GuardianIronfurTrackerDB.enabled ~= false then
        if not ironfurBar:IsShown() then ironfurBar:Show() end
    else
        if ironfurBar:IsShown() then ironfurBar:Hide() end
    end
    UpdateSegmentValues()
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

local onUpdate_acc = 0
local function OnUpdate(self, elapsed)
    onUpdate_acc = onUpdate_acc + elapsed
    if onUpdate_acc < 0.05 then return end
    onUpdate_acc = 0
    UpdateSegmentValues()
end

ironfurBar:SetScript("OnUpdate", OnUpdate)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:SetScript("OnEvent", function(_, event, unit, _, spellID)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        cachedEligible = nil
        cachedSegDuration = nil
        UpdateSegments()
        return
    end
    if event == "UPDATE_SHAPESHIFT_FORM" then
        UpdateSegments()
        return
    end
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
-- Moved to RegisterGuardianIronfurTrackerOptions() to only register for Druids

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
    -- No ticker needed — OnUpdate handles animation, events handle state changes
end

-- Register options and initializSQSSEe bar/settings after entering world
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
    local _, class = UnitClass("player")
    if class ~= "DRUID" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        return
    end
    RegisterGuardianIronfurTrackerOptions()
    if InitIronfurBar then InitIronfurBar() end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
