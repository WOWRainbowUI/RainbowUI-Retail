
local CAT_FORM_SPELL_ID = 768

-- Cat Form detection that doesn't depend on the shapeshift *index* (which
-- differs per client: Retail Bear 1 / Cat 2, Classic Bear 1 / Aquatic 2 / Cat 3
-- and it also shifts with which forms you've learned). Three independent
-- checks are tried, any one of them is enough:
--   1. GetShapeshiftFormID() == 1   (Cat Form's fixed ID)
--   2. the active form on the shapeshift bar is the Cat Form spell (768)
--   3. the player has the Cat Form buff
local function IsInCatForm()
    -- 1) form ID
    if GetShapeshiftFormID then
        local ok, id = pcall(GetShapeshiftFormID)
        if ok and id == 1 then return true end
    end

    -- 2) walk the shapeshift bar for the active form
    if GetNumShapeshiftForms and GetShapeshiftFormInfo then
        local catName
        if C_Spell and C_Spell.GetSpellName then
            catName = C_Spell.GetSpellName(CAT_FORM_SPELL_ID)
        elseif GetSpellInfo then
            catName = GetSpellInfo(CAT_FORM_SPELL_ID)
        end
        for i = 1, GetNumShapeshiftForms() do
            local ok, icon, b, c, d = pcall(GetShapeshiftFormInfo, i)
            if ok then
                local active, spellID, name
                if type(b) == "string" then
                    -- old layout: icon, name, active, castable
                    name, active = b, c
                else
                    -- new layout: icon, active, castable, spellID
                    active, spellID = b, d
                end
                if active and (spellID == CAT_FORM_SPELL_ID or (name and catName and name == catName)) then
                    return true
                end
            end
        end
    end

    -- 3) buff check
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, CAT_FORM_SPELL_ID)
        if ok and aura then return true end
    end

    return false
end

function ShouldShowComboPointBar()
    local _, class = UnitClass("player")
    if class ~= "DRUID" then return false end
    return IsInCatForm()
end

function UpdateDruidComboBarEnabled()
    local mounted = IsMounted and IsMounted() or (IsPlayerMounted and IsPlayerMounted())
    if CustomDruidComboBarDB.hideWhenMounted and mounted then
        comboPointBar:Hide()
        return
    end
    local showBar = (ShouldShowComboPointBar() or _G.CDCB_TestPoints ~= nil) and CustomDruidComboBarDB.enabled
    if showBar then
        comboPointBar:Show()
    else
        comboPointBar:Hide()
    end
    -- Hide Blizzard's prdClassFrame for Druids when custom bar is enabled
    if CustomDruidComboBarDB.enabled then
        if _G.prdClassFrame then
            _G.prdClassFrame:Hide()
            _G.prdClassFrame:SetAlpha(0)
        end
    else
        if _G.prdClassFrame then
            _G.prdClassFrame:Show()
            _G.prdClassFrame:SetAlpha(1)
        end
    end
end

local COMBO_POINT_TYPE = Enum and Enum.PowerType and Enum.PowerType.ComboPoints or 4 -- fallback to 4 if Enum not loaded

local chargedComboPoints = {}

-- In newer clients some values (e.g. UnitPower) come back as "secret" values
-- while our addon code is tainted. Secret values can't be compared or used in
-- arithmetic (that was the "attempt to compare local 'current'" error), but
-- they CAN be handed to StatusBar:SetValue. So combo points are drawn with
-- StatusBars and never compared against the raw number.
local issecret = _G.issecretvalue or function() return false end

-- Returns the current combo points (may be a secret value on some clients).
-- On Classic, combo points belong to the *target* you built them on, and are
-- read with GetComboPoints. This bar is a free-standing custom bar, so we read
-- that value and simply display it; it doesn't need Blizzard's target-frame
-- combo display at all. Retail-style clients expose combo points as a player
-- power instead, which is the fallback.
local function GetCurrentComboPoints()
    if _G.CDCB_TestPoints then return _G.CDCB_TestPoints end -- /cdcbtest preview
    if GetComboPoints then
        -- ("player","target") = points on your current target,
        -- ("player") = points on whatever unit currently holds them.
        for _, target in ipairs({ "target", false }) do
            local ok, value
            if target then
                ok, value = pcall(GetComboPoints, "player", target)
            else
                ok, value = pcall(GetComboPoints, "player")
            end
            -- A secret value is fine: it goes straight into StatusBar:SetValue.
            if ok and type(value) == "number" and (issecret(value) or value > 0) then
                return value
            end
        end
        -- Both returned 0/nothing: fall through and ask the power API too, in
        -- case this client reports combo points as a player power.
    end
    local ok, power = pcall(UnitPower, "player", COMBO_POINT_TYPE)
    if ok and type(power) == "number" then return power end
    return 0
end

-- Early exit if not a Druid
local _, playerClass = UnitClass("player")
if playerClass ~= "DRUID" then return end

local function dprint(...)
    if CustomDruidComboBarDB and CustomDruidComboBarDB.debug then
        print("[CDCB]", ...)
    end
end

local function SafeUnpackColor(color, default)
    if type(color) ~= "table" then
        return unpack(default or {1,1,1,1})
    end
    if color.r then
        return tonumber(color.r) or (default and default[1]) or 1,
               tonumber(color.g) or (default and default[2]) or 1,
               tonumber(color.b) or (default and default[3]) or 1,
               tonumber(color.a) or (default and default[4]) or 1
    end
    return tonumber(color[1]) or (default and default[1]) or 1,
           tonumber(color[2]) or (default and default[2]) or 1,
           tonumber(color[3]) or (default and default[3]) or 1,
           tonumber(color[4]) or (default and default[4]) or 1
end

CustomDruidComboBarDB = CustomDruidComboBarDB or {
    x = 0, y = -120, comboPointWidth = 24, comboPointHeight = 24, locked = false,
    totalWidth = nil,
    comboPointBgColor = {0, 0, 0, 0.5},
    chargedComboPointBgColor = {0.1, 0.3, 0.5, 0.7},
    comboPointFillColors = {
        {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1},
        {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1},
    },
    chargedComboPointColor = {0.2, 0.6, 1, 1},
    gradientColoringEnabled = false,
    gradientColorStart = {1, 0, 0, 1},
    gradientColorEnd = {1, 1, 0, 1},
    anchorToPRD = false,
    anchorPosition = "BELOW",
    anchorOffset = 10,
    anchorTarget = "HEALTH", -- HEALTH or POWER
    debug = false,
    enabled = true,
    hideWhenMounted = false,
}

local function GetPRDHealthBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        return prd.HealthBarsContainer.healthBar
    end
    return _G.PersonalResourceDisplayHealthBar
end

local function GetPRDPowerBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.PowerBarsContainer and prd.PowerBarsContainer.powerBar then
        return prd.PowerBarsContainer.powerBar
    end
    if prd and prd.PowerBar then
        return prd.PowerBar
    end
    return _G.PersonalResourceDisplayPowerBar
end

local function GetPRDAnchorFrame()
    if not CustomDruidComboBarDB.anchorToPRD then return nil end
    local target = CustomDruidComboBarDB.anchorTarget or "HEALTH"
    local f = (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
    dprint("GetPRDAnchorFrame target=", target, "found=", f and "yes" or "no")
    return f
end

comboPointBar = CreateFrame("Frame", "CustomDruidComboBar", UIParent)
comboPointBar.comboPoints = {}

local function GetMaxComboPoints()
    -- Druids always have 5. UnitPowerMax can be 0 out of cat form on Classic,
    -- or a secret value, so never trust it below 5.
    local max = UnitPowerMax("player", COMBO_POINT_TYPE)
    if issecret(max) or type(max) ~= "number" or max < 5 then return 5 end
    return math.min(max, 7) -- 7 = number of fill colors we store
end

local function GetComboPointWidth(numPoints)
    if numPoints == 0 then numPoints = 5 end
    if CustomDruidComboBarDB.totalWidth and CustomDruidComboBarDB.totalWidth > 0 then
        return CustomDruidComboBarDB.totalWidth / numPoints
    end
    return CustomDruidComboBarDB.comboPointWidth or 24
end

local function CreateComboPoints()
    for _, cp in ipairs(comboPointBar.comboPoints) do
        cp:Hide()
        cp:SetParent(nil)
    end
    comboPointBar.comboPoints = {}

    local numPoints = GetMaxComboPoints()
    for i = 1, numPoints do
        if chargedComboPoints[i] == nil then chargedComboPoints[i] = false end
    end
    local width = GetComboPointWidth(numPoints)
    local height = CustomDruidComboBarDB.comboPointHeight or 24

    for i = 1, numPoints do
        local comboPoint = CreateFrame("Frame", nil, comboPointBar)
        comboPoint:SetSize(width, height)
        comboPoint:SetPoint("LEFT", comboPointBar, "LEFT", (i-1)*width, 0)
        comboPoint:EnableMouse(false)

        comboPoint.bg = comboPoint:CreateTexture(nil, "BACKGROUND")
        comboPoint.bg:SetAllPoints()

        -- The fill is a StatusBar spanning (i-1)..i so it shows full once the
        -- combo point count reaches i, even if that count is a secret value.
        comboPoint.fill = CreateFrame("StatusBar", nil, comboPoint)
        comboPoint.fill:SetAllPoints(comboPoint)
        comboPoint.fill:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        comboPoint.fill:SetMinMaxValues(i - 1, i)
        comboPoint.fill:SetValue(0)
        comboPoint.fill:EnableMouse(false)

        -- Borders live on their own frame above the fill so the fill can't cover them.
        local overlay = CreateFrame("Frame", nil, comboPoint)
        overlay:SetAllPoints(comboPoint)
        overlay:SetFrameLevel(comboPoint.fill:GetFrameLevel() + 1)
        overlay:EnableMouse(false)
        comboPoint.overlay = overlay

        comboPoint.borderTop = overlay:CreateTexture(nil, "OVERLAY")
        comboPoint.borderTop:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderTop:SetPoint("TOPLEFT", comboPoint, "TOPLEFT", 0, 0)
        comboPoint.borderTop:SetPoint("TOPRIGHT", comboPoint, "TOPRIGHT", 0, 0)
        comboPoint.borderTop:SetHeight(1)

        comboPoint.borderBottom = overlay:CreateTexture(nil, "OVERLAY")
        comboPoint.borderBottom:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderBottom:SetPoint("BOTTOMLEFT", comboPoint, "BOTTOMLEFT", 0, 0)
        comboPoint.borderBottom:SetPoint("BOTTOMRIGHT", comboPoint, "BOTTOMRIGHT", 0, 0)
        comboPoint.borderBottom:SetHeight(1)

        comboPoint.borderLeft = overlay:CreateTexture(nil, "OVERLAY")
        comboPoint.borderLeft:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderLeft:SetPoint("TOPLEFT", comboPoint, "TOPLEFT", 0, 0)
        comboPoint.borderLeft:SetPoint("BOTTOMLEFT", comboPoint, "BOTTOMLEFT", 0, 0)
        comboPoint.borderLeft:SetWidth(1)

        comboPoint.borderRight = overlay:CreateTexture(nil, "OVERLAY")
        comboPoint.borderRight:SetColorTexture(0, 0, 0, 1)
        comboPoint.borderRight:SetPoint("TOPRIGHT", comboPoint, "TOPRIGHT", 0, 0)
        comboPoint.borderRight:SetPoint("BOTTOMRIGHT", comboPoint, "BOTTOMRIGHT", 0, 0)
        comboPoint.borderRight:SetWidth(1)

        comboPointBar.comboPoints[i] = comboPoint
    end

    UpdateDruidComboBarEnabled()
end

local function LerpColor(c1, c2, t)
    if type(c1) ~= "table" or not c1[1] then c1 = {1, 0, 0, 1} end
    if type(c2) ~= "table" or not c2[1] then c2 = {1, 1, 0, 1} end
    return c1[1] + (c2[1] - c1[1]) * t,
           c1[2] + (c2[2] - c1[2]) * t,
           c1[3] + (c2[3] - c1[3]) * t,
           c1[4] + (c2[4] - c1[4]) * t
end

local function UpdateChargedComboPoints()
    for i = 1, #chargedComboPoints do chargedComboPoints[i] = false end
    if GetUnitChargedPowerPoints then
        local charged = GetUnitChargedPowerPoints("player")
        if charged then
            for _, idx in ipairs(charged) do
                chargedComboPoints[idx] = true
            end
        end
    end
end

local function UpdateComboPointBarSize()
    local numPoints = GetMaxComboPoints()
    local width
    if CustomDruidComboBarDB.totalWidth and CustomDruidComboBarDB.totalWidth > 0 then
        width = CustomDruidComboBarDB.totalWidth
    else
        width = (CustomDruidComboBarDB.comboPointWidth or 24) * numPoints
    end
    comboPointBar:SetSize(width, CustomDruidComboBarDB.comboPointHeight or 24)
end

local function ApplyComboBarSettings()
    UpdateComboPointBarSize()
    comboPointBar:ClearAllPoints()

    local anchorFrame = GetPRDAnchorFrame()
    dprint("Apply settings:", "anchorToPRD=", CustomDruidComboBarDB.anchorToPRD, "anchorFrame=", anchorFrame and "yes" or "no")

    if anchorFrame then
        if CustomDruidComboBarDB.anchorPosition == "ABOVE" then
            dprint("Anchoring ABOVE PRD with offset", CustomDruidComboBarDB.anchorOffset or 10)
            comboPointBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, CustomDruidComboBarDB.anchorOffset or 10)
        else
            dprint("Anchoring BELOW PRD with offset", CustomDruidComboBarDB.anchorOffset or 10)
            comboPointBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -(CustomDruidComboBarDB.anchorOffset or 10))
        end
    else
        dprint("Center position x=", CustomDruidComboBarDB.x or 0, "y=", CustomDruidComboBarDB.y or 0)
        comboPointBar:SetPoint("CENTER", UIParent, "CENTER", CustomDruidComboBarDB.x or 0, CustomDruidComboBarDB.y or 0)
    end
end

local function UpdateComboPoints()
    UpdateChargedComboPoints()
    -- Only rebuild the frames when the number of points changed (this runs on
    -- every power/target event, so rebuilding each time leaked frames).
    if #comboPointBar.comboPoints ~= GetMaxComboPoints() then
        CreateComboPoints()
    end
    UpdateComboPointBarSize()
    ApplyComboBarSettings()

    local current = GetCurrentComboPoints() -- may be a secret value: never compare/do math on it
    local numPoints = GetMaxComboPoints()
    local width = GetComboPointWidth(numPoints)
    local height = CustomDruidComboBarDB.comboPointHeight or 24
    local bgR, bgG, bgB, bgA = SafeUnpackColor(CustomDruidComboBarDB.comboPointBgColor, {0, 0, 0, 0.5})

    for i = 1, numPoints do
        local comboPoint = comboPointBar.comboPoints[i]
        comboPoint:SetSize(width, height)
        comboPoint:SetPoint("LEFT", comboPointBar, "LEFT", (i-1)*width, 0)

        if chargedComboPoints[i] then
            local c = CustomDruidComboBarDB.chargedComboPointBgColor or {0.1, 0.3, 0.5, 0.7}
            comboPoint.bg:SetColorTexture(c[1], c[2], c[3], c[4])
        else
            comboPoint.bg:SetColorTexture(bgR, bgG, bgB, bgA)
        end

        local color
        if chargedComboPoints[i] then
            color = CustomDruidComboBarDB.chargedComboPointColor or {0.2, 0.6, 1, 1}
        elseif CustomDruidComboBarDB.gradientColoringEnabled then
            local t = (numPoints == 1) and 0 or (i-1)/(numPoints-1)
            color = {LerpColor(CustomDruidComboBarDB.gradientColorStart, CustomDruidComboBarDB.gradientColorEnd, t)}
        else
            color = (CustomDruidComboBarDB.comboPointFillColors and CustomDruidComboBarDB.comboPointFillColors[i]) or {1, 0.7, 0.2, 1}
        end
        comboPoint.fill:SetStatusBarColor(SafeUnpackColor(color, {1, 0.7, 0.2, 1}))

        -- Point i is full when current >= i and empty otherwise; the StatusBar
        -- does that comparison for us, so a secret value is fine here.
        comboPoint.fill:SetMinMaxValues(i - 1, i)
        comboPoint.fill:SetValue(current)
        comboPoint:Show()
    end

    for i = numPoints+1, #comboPointBar.comboPoints do
        if comboPointBar.comboPoints[i] then
            comboPointBar.comboPoints[i]:Hide()
        end
    end
end

local function HookPRDAnchor()
    local anchorFrame = GetPRDAnchorFrame()
    if not anchorFrame then return end
    anchorFrame._cdcb_hooks = anchorFrame._cdcb_hooks or {}

    if not anchorFrame._cdcb_hooks.SetPoint then
        anchorFrame._cdcb_hooks.SetPoint = true
        hooksecurefunc(anchorFrame, "SetPoint", function()
            if CustomDruidComboBarDB.anchorToPRD then ApplyComboBarSettings() end
        end)
    end
    if not anchorFrame._cdcb_hooks.SetSize then
        anchorFrame._cdcb_hooks.SetSize = true
        hooksecurefunc(anchorFrame, "SetSize", function()
            if CustomDruidComboBarDB.anchorToPRD then ApplyComboBarSettings() end
        end)
    end
    if not anchorFrame._cdcb_hooks.SetScale then
        anchorFrame._cdcb_hooks.SetScale = true
        hooksecurefunc(anchorFrame, "SetScale", function()
            if CustomDruidComboBarDB.anchorToPRD then ApplyComboBarSettings() end
        end)
    end
end

local function TryHookPRDAnchor()
    if GetPRDAnchorFrame() then
        HookPRDAnchor()
    else
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self)
            if GetPRDAnchorFrame() then
                HookPRDAnchor()
                self:UnregisterAllEvents()
            end
        end)
    end
end

local function ShouldShowComboPointBar()
    local _, class = UnitClass("player")
    return class == "DRUID"
end

comboPointBar:SetMovable(true)
comboPointBar:EnableMouse(true)
comboPointBar:RegisterForDrag("LeftButton")
comboPointBar:SetScript("OnDragStart", function(self)
    if not CustomDruidComboBarDB.locked and not CustomDruidComboBarDB.anchorToPRD then self:StartMoving() end
end)
comboPointBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomDruidComboBarDB.x = x or 0
    CustomDruidComboBarDB.y = y or 0
    dprint("DragStop: updated x,y:", CustomDruidComboBarDB.x, CustomDruidComboBarDB.y)
end)

local function UpdateVisibility()
    if ShouldShowComboPointBar() and CustomDruidComboBarDB.enabled then
        comboPointBar:Show()
    else
        comboPointBar:Hide()
    end
end

comboPointBar:RegisterEvent("UNIT_POWER_POINT_CHARGE")
comboPointBar:RegisterEvent("UNIT_POWER_UPDATE")
comboPointBar:RegisterEvent("PLAYER_ENTERING_WORLD")
comboPointBar:RegisterEvent("PLAYER_LOGIN")
comboPointBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
comboPointBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
comboPointBar:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
-- Classic tracks combo points on the target and fires these instead of (or as
-- well as) UNIT_POWER_UPDATE. pcall'd since not every client has every event.
pcall(comboPointBar.RegisterEvent, comboPointBar, "PLAYER_COMBO_POINTS")   -- Classic Era name
pcall(comboPointBar.RegisterEvent, comboPointBar, "UNIT_COMBO_POINTS")     -- TBC+ Classic name
pcall(comboPointBar.RegisterEvent, comboPointBar, "PLAYER_TARGET_CHANGED")
-- Stance fallbacks: some clients don't fire UPDATE_SHAPESHIFT_FORM reliably.
pcall(comboPointBar.RegisterEvent, comboPointBar, "UPDATE_SHAPESHIFT_FORMS")
pcall(comboPointBar.RegisterUnitEvent, comboPointBar, "UNIT_AURA", "player")
comboPointBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_POINT_CHARGE" then
        UpdateChargedComboPoints()
        UpdateComboPoints()
    elseif event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "COMBO_POINTS" or powerType == COMBO_POINT_TYPE) then
            UpdateComboPoints()
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_FORMS" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        UpdateDruidComboBarEnabled()
        UpdateComboPoints()
    elseif event == "UNIT_AURA" then
        -- Only a stance/visibility re-check; combo points don't change on aura events.
        UpdateDruidComboBarEnabled()
    else
        UpdateComboPoints()
    end
end)

-- Initial check on load
UpdateDruidComboBarEnabled()

local function UpdateDruidComboBarSettings()
    ApplyComboBarSettings()
    UpdateComboPoints()
    if CustomDruidComboBarDB.anchorToPRD then
        TryHookPRDAnchor()
    end
end

_G.UpdateComboPoints = UpdateComboPoints
_G.UpdateDruidComboBarSettings = UpdateDruidComboBarSettings

-- /cdcbdebug : prints what THIS client reports for stance + combo points, so
-- the detection can be tuned if something doesn't line up.
local function SafeStr(v)
    if issecret(v) then return "<secret>" end
    return tostring(v)
end

local function SafeCall(fn, ...)
    if not fn then return "n/a" end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return "error" end
    return SafeStr(a) .. (b ~= nil and (", " .. SafeStr(b)) or "") ..
           (c ~= nil and (", " .. SafeStr(c)) or "") .. (d ~= nil and (", " .. SafeStr(d)) or "")
end

-- /cdcbtest 0-5 : force the bar visible with that many points filled, so you
-- can check look/position without being in Cat Form. /cdcbtest off to stop.
SLASH_CDCBTEST1 = "/cdcbtest"
SlashCmdList["CDCBTEST"] = function(msg)
    local n = tonumber(msg)
    if n then
        _G.CDCB_TestPoints = math.max(0, math.min(5, math.floor(n)))
        print("|cff66ccff[CDCB]|r preview:", _G.CDCB_TestPoints, "points. '/cdcbtest off' to stop.")
    else
        _G.CDCB_TestPoints = nil
        print("|cff66ccff[CDCB]|r preview off.")
    end
    UpdateDruidComboBarEnabled()
    UpdateComboPoints()
end

SLASH_CDCBDEBUG1 = "/cdcbdebug"
SlashCmdList["CDCBDEBUG"] = function()
    local toc = select(4, GetBuildInfo())
    print("|cff66ccff[CDCB debug]|r interface", toc)
    print(" GetShapeshiftForm():", SafeCall(GetShapeshiftForm))
    print(" GetShapeshiftFormID():", SafeCall(GetShapeshiftFormID))
    print(" GetNumShapeshiftForms():", SafeCall(GetNumShapeshiftForms))
    print(" level:", SafeCall(UnitLevel, "player"))
    print(" Cat Form buff (768):", C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
        and SafeCall(function() return C_UnitAuras.GetPlayerAuraBySpellID(768) ~= nil end) or "n/a")
    print(" Cat Form known (768):", SafeCall(function()
        if C_SpellBook and C_SpellBook.IsSpellKnown then return C_SpellBook.IsSpellKnown(768) end
        if IsSpellKnown then return IsSpellKnown(768) end
    end))
    if GetNumShapeshiftForms and GetShapeshiftFormInfo then
        for i = 1, GetNumShapeshiftForms() do
            print(" form bar slot", i, ":", SafeCall(GetShapeshiftFormInfo, i))
        end
    end
    print(" IsInCatForm():", tostring(IsInCatForm()))
    print(" GetComboPoints('player','target'):", SafeCall(GetComboPoints, "player", "target"))
    print(" GetComboPoints('player'):", SafeCall(GetComboPoints, "player"))
    print(" UnitPower(combo):", SafeCall(UnitPower, "player", COMBO_POINT_TYPE))
    print(" UnitPowerMax(combo):", SafeCall(UnitPowerMax, "player", COMBO_POINT_TYPE))
end
