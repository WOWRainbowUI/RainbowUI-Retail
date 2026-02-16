local _, class = UnitClass("player")
if class ~= "DEATHKNIGHT" then return end

-- PRD anchor helpers (copied from Rogue/Mage bars)
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
    return _G.PersonalResourceDisplayPowerBar
end

local function GetPRDAnchorFrame()
    if not CustomDeathKnightRuneBarDB.anchorToPRD then return nil end
    local target = CustomDeathKnightRuneBarDB.anchorTarget or "HEALTH"
    local f = (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
    if CustomDeathKnightRuneBarDB.debug then print("[DKRuneBar] GetPRDAnchorFrame target=", target, "found=", f and "yes" or "no") end
    return f
end

-- Hook PRD SetPoint/SetSize/SetScale to re-apply anchoring
local function HookPRDAnchor()
    local anchorFrame = GetPRDAnchorFrame()
    if not anchorFrame then return end
    anchorFrame._cdrb_hooks = anchorFrame._cdrb_hooks or {}
    if not anchorFrame._cdrb_hooks.SetPoint then
        anchorFrame._cdrb_hooks.SetPoint = true
        hooksecurefunc(anchorFrame, "SetPoint", function()
            if CustomDeathKnightRuneBarDB.anchorToPRD then ApplyBarSettings() end
        end)
    end
    if not anchorFrame._cdrb_hooks.SetSize then
        anchorFrame._cdrb_hooks.SetSize = true
        hooksecurefunc(anchorFrame, "SetSize", function()
            if CustomDeathKnightRuneBarDB.anchorToPRD then ApplyBarSettings() end
        end)
    end
    if not anchorFrame._cdrb_hooks.SetScale then
        anchorFrame._cdrb_hooks.SetScale = true
        hooksecurefunc(anchorFrame, "SetScale", function()
            if CustomDeathKnightRuneBarDB.anchorToPRD then ApplyBarSettings() end
        end)
    end
end
-- CustomDeathKnightRuneBar.lua
-- Standalone custom Death Knight Rune bar (ready to drop in)6mmm

local NUM_RUNES = 6 -- Max runes for Death Knight

-- SavedVariables for position, size, and lock state
if not CustomDeathKnightRuneBarDB or type(CustomDeathKnightRuneBarDB) ~= "table" then
    CustomDeathKnightRuneBarDB = {}
end
if CustomDeathKnightRuneBarDB.specColors == nil then
    CustomDeathKnightRuneBarDB.specColors = {
        [250] = {0.77, 0.12, 0.23, 1}, -- Blood (red)
        [251] = {0.20, 0.40, 0.80, 1}, -- Frost (blue)
        [252] = {0.13, 0.75, 0.13, 1}, -- Unholy (green)
    }
end
if CustomDeathKnightRuneBarDB.showRuneTimers == nil then
    CustomDeathKnightRuneBarDB.showRuneTimers = true
end
local function SetDefaultRuneBarDB()
    if CustomDeathKnightRuneBarDB.enabled == nil then CustomDeathKnightRuneBarDB.enabled = true end
    if CustomDeathKnightRuneBarDB.x == nil then CustomDeathKnightRuneBarDB.x = 0 end
    if CustomDeathKnightRuneBarDB.y == nil then CustomDeathKnightRuneBarDB.y = -120 end
    if CustomDeathKnightRuneBarDB.runeWidth == nil then CustomDeathKnightRuneBarDB.runeWidth = 24 end
    if CustomDeathKnightRuneBarDB.runeHeight == nil then CustomDeathKnightRuneBarDB.runeHeight = 24 end
    if CustomDeathKnightRuneBarDB.locked == nil then CustomDeathKnightRuneBarDB.locked = false end
    if CustomDeathKnightRuneBarDB.runeBgColor == nil then CustomDeathKnightRuneBarDB.runeBgColor = {0, 0, 0, 0.5} end
    if CustomDeathKnightRuneBarDB.gradientColor1 == nil then CustomDeathKnightRuneBarDB.gradientColor1 = {0.2, 0.8, 1, 1} end
    if CustomDeathKnightRuneBarDB.gradientColor2 == nil then CustomDeathKnightRuneBarDB.gradientColor2 = {0.2, 1, 0.8, 1} end
end
SetDefaultRuneBarDB()




-- Hide the default Rune bar and PRD runes if present
local function HideDefaultRuneBarAndPRDRunes()
    -- Classic DK rune bar
    -- Retail PRD runes (Personal Resource Display)
    if prdClassFrame and prdClassFrame.Rune1 then
        for i = 1, 6 do
            local rune = prdClassFrame["Rune"..i]
            if rune then
                rune:Hide()
                rune:SetAlpha(0)
                if rune.UnregisterAllEvents then rune:UnregisterAllEvents() end
                if rune.SetScript then rune:SetScript("OnEvent", nil) end
            end
        end
    end
end

HideDefaultRuneBarAndPRDRunes()

-- Create the custom rune bar frame
local runeBar = CreateFrame("Frame", "CustomDeathKnightRuneBar", UIParent)
runeBar:SetSize(180, 32)
runeBar:SetPoint("CENTER", UIParent, "CENTER", 0, -120)

runeBar.runes = {}

for i = 1, NUM_RUNES do
    local rune = CreateFrame("Frame", nil, runeBar)
    rune:SetSize(CustomDeathKnightRuneBarDB.runeWidth, CustomDeathKnightRuneBarDB.runeHeight)
    -- Standard: anchor runes from the LEFT, so rune 1 is leftmost, rune 6 is rightmost
    rune:SetPoint("LEFT", runeBar, "LEFT", (i-1)*(CustomDeathKnightRuneBarDB.runeWidth+6), 0)
    rune.bg = rune:CreateTexture(nil, "BACKGROUND")
    rune.bg:SetAllPoints()
    local bg = CustomDeathKnightRuneBarDB.runeBgColor or {0, 0, 0, 0.5}
    rune.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
    rune.fill = rune:CreateTexture(nil, "ARTWORK")
    rune.fill:SetPoint("LEFT", rune, "LEFT")
    rune.fill:SetHeight(rune:GetHeight())
    rune.fill:SetWidth(rune:GetWidth())
    rune.fill:SetColorTexture(1, 1, 1, 1)
    rune.fill:SetAlpha(0.2)
    -- Add cooldown timer text
    rune.timerText = rune:CreateFontString(nil, "OVERLAY")
    -- Set font to white, outlined, and size to match rune height
    local fontHeight = CustomDeathKnightRuneBarDB.runeHeight or 24
    rune.timerText:SetFont("Fonts\\FRIZQT__.TTF", fontHeight * 0.7, "OUTLINE")
    rune.timerText:SetTextColor(1, 1, 1, 1)
    rune.timerText:SetPoint("CENTER", rune, "CENTER")
    rune.timerText:SetText("")
    rune.timerText:Hide()
    rune.borderTop = rune:CreateTexture(nil, "OVERLAY")
    rune.borderTop:SetColorTexture(0, 0, 0, 1)
    rune.borderTop:SetPoint("TOPLEFT", rune, "TOPLEFT", 0, 0)
    rune.borderTop:SetPoint("TOPRIGHT", rune, "TOPRIGHT", 0, 0)
    rune.borderTop:SetHeight(1)
    rune.borderBottom = rune:CreateTexture(nil, "OVERLAY")
    rune.borderBottom:SetColorTexture(0, 0, 0, 1)
    rune.borderBottom:SetPoint("BOTTOMLEFT", rune, "BOTTOMLEFT", 0, 0)
    rune.borderBottom:SetPoint("BOTTOMRIGHT", rune, "BOTTOMRIGHT", 0, 0)
    rune.borderBottom:SetHeight(1)
    rune.borderLeft = rune:CreateTexture(nil, "OVERLAY")
    rune.borderLeft:SetColorTexture(0, 0, 0, 1)
    rune.borderLeft:SetPoint("TOPLEFT", rune, "TOPLEFT", 0, 0)
    rune.borderLeft:SetPoint("BOTTOMLEFT", rune, "BOTTOMLEFT", 0, 0)
    rune.borderLeft:SetWidth(1)
    rune.borderRight = rune:CreateTexture(nil, "OVERLAY")
    rune.borderRight:SetColorTexture(0, 0, 0, 1)
    rune.borderRight:SetPoint("TOPRIGHT", rune, "TOPRIGHT", 0, 0)
    rune.borderRight:SetPoint("BOTTOMRIGHT", rune, "BOTTOMRIGHT", 0, 0)
    rune.borderRight:SetWidth(1)
    -- Animation: OnUpdate handler for fill
    do
        local runeIndex = NUM_RUNES - i + 1
        rune:SetScript("OnUpdate", function(self, elapsed)
            local start, duration, ready = GetRuneCooldown(runeIndex)
            local w = self:GetWidth()
            local h = self:GetHeight()
            self.fill:SetHeight(h)
            if ready then
                self.fill:SetPoint("LEFT", self, "LEFT")
                self.fill:SetWidth(w)
                self.fill:SetAlpha(1)
            else
                local now = GetTime()
                local pct = (now - start) / (duration > 0 and duration or 1)
                pct = math.max(0, math.min(pct, 1))
                self.fill:SetPoint("LEFT", self, "LEFT")
                self.fill:SetWidth(w * pct)
                self.fill:SetAlpha(0.7)
            end
        end)
    end
    runeBar.runes[i] = rune
end

-- Update function
local function UpdateRunes()
    -- Only run for Death Knight class
    local _, class = UnitClass("player")
    if class ~= "DEATHKNIGHT" then
        -- Hide the bar and skip update
        if runeBar then runeBar:Hide() end
        return
    end
    -- Ensure specColors is always a table
    if type(CustomDeathKnightRuneBarDB.specColors) ~= "table" then
        CustomDeathKnightRuneBarDB.specColors = {
            [250] = {0.77, 0.12, 0.23, 1}, -- Blood
            [251] = {0.20, 0.40, 0.80, 1}, -- Frost
            [252] = {0.13, 0.75, 0.13, 1}, -- Unholy
        }
    end
    -- Gather rune states and cooldowns
    local runeStates = {}
    for i = 1, NUM_RUNES do
        local start, duration, ready = GetRuneCooldown(i)
        local remaining = 0
        if start == nil or duration == nil or ready == nil then
            -- Defensive: skip this rune if API returns nil (shouldn't happen for DKs)
            table.insert(runeStates, {index = i, ready = true, start = 0, duration = 0, remaining = 0})
        else
            if not ready then
                local now = GetTime()
                remaining = (start + duration) - now
            end
            table.insert(runeStates, {index = i, ready = ready, start = start, duration = duration, remaining = remaining})
        end
    end
    -- Sort: ready runes first, then by least remaining cooldown
    table.sort(runeStates, function(a, b)
        if a.ready ~= b.ready then
            return a.ready -- ready runes first
        else
            return a.remaining < b.remaining
        end
    end)
    local c1 = CustomDeathKnightRuneBarDB.gradientColor1 or {0.2, 0.8, 1, 1}
    local c2 = CustomDeathKnightRuneBarDB.gradientColor2 or {0.2, 1, 0.8, 1}
    local bg = CustomDeathKnightRuneBarDB.runeBgColor or {0, 0, 0, 0.5}
    local specID = GetSpecialization() and select(1, GetSpecializationInfo(GetSpecialization())) or 250
    local specColor = CustomDeathKnightRuneBarDB.specColors[specID] or {1, 1, 1, 1}
    -- For each bar slot (left to right), animate all runes on cooldown, show full for ready
    for i = 1, NUM_RUNES do
        local rune = runeBar.runes[i]
        rune.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
        local state = runeStates[i]
        if state.ready then
            rune.fill:Show()
            rune.fill:SetAlpha(1)
            rune.fill:SetHeight(rune:GetHeight())
            rune.fill:SetWidth(rune:GetWidth())
            -- Update font size in case bar was resized
            local fontHeight = rune:GetHeight() or 24
            rune.timerText:SetFont("Fonts\\FRIZQT__.TTF", fontHeight * 0.7, "OUTLINE")
            rune.timerText:Hide()
            rune:SetScript("OnUpdate", nil)
            if rune.fill.SetVertexColor then
                rune.fill:SetVertexColor(1, 1, 1, 1)
            end
            if CustomDeathKnightRuneBarDB.gradientColoringEnabled then
                if c1[1] == c2[1] and c1[2] == c2[2] and c1[3] == c2[3] and c1[4] == c2[4] then
                    rune.fill:SetColorTexture(c1[1], c1[2], c1[3], c1[4])
                elseif rune.fill.SetGradient then
                    rune.fill:SetGradient("HORIZONTAL",
                        CreateColor(c1[1], c1[2], c1[3], c1[4]),
                        CreateColor(c2[1], c2[2], c2[3], c2[4])
                    )
                else
                    rune.fill:SetColorTexture(c1[1], c1[2], c1[3], c1[4])
                end
            else
                rune.fill:SetColorTexture(specColor[1], specColor[2], specColor[3], specColor[4])
            end
            if not CustomDeathKnightRuneBarDB.showRuneTimers then
                rune.timerText:Hide()
            end
        else
            rune.fill:Show()
            rune.fill:SetAlpha(0.7)
            if CustomDeathKnightRuneBarDB.showRuneTimers then
                rune.timerText:Show()
            else
                rune.timerText:Hide()
            end
            rune:SetScript("OnUpdate", function(self, elapsed)
                local start, duration, ready = GetRuneCooldown(state.index)
                local w = self:GetWidth()
                local h = self:GetHeight()
                self.fill:SetHeight(h)
                -- Update font size in case bar was resized
                local fontHeight = h or 24
                self.timerText:SetFont("Fonts\\FRIZQT__.TTF", fontHeight * 0.7, "OUTLINE")
                if ready then
                    self.fill:SetPoint("LEFT", self, "LEFT")
                    self.fill:SetWidth(w)
                    self.fill:SetAlpha(1)
                    self.timerText:Hide()
                else
                    local now = GetTime()
                    local pct = (now - start) / (duration > 0 and duration or 1)
                    pct = math.max(0, math.min(pct, 1))
                    self.fill:SetPoint("LEFT", self, "LEFT")
                    self.fill:SetWidth(w * pct)
                    self.fill:SetAlpha(0.7)
                    local remaining = (start + duration) - now
                    if CustomDeathKnightRuneBarDB.showRuneTimers and remaining > 0 then
                        self.timerText:SetText(string.format("%.1fs", remaining))
                        self.timerText:Show()
                    else
                        self.timerText:Hide()
                    end
                end
            end)
        end
    end
end

-- Event handler
runeBar:RegisterEvent("RUNE_POWER_UPDATE")
runeBar:RegisterEvent("PLAYER_ENTERING_WORLD")
runeBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
runeBar:SetScript("OnEvent", function(self, event, ...)
    UpdateRunes()
end)

-- Only show for Death Knight
local function ShouldShowRuneBar()
    local _, class = UnitClass("player")
    return class == "DEATHKNIGHT"
end

local function UpdateVisibility()
    if CustomDeathKnightRuneBarDB.enabled == false then
        runeBar:Hide()
        -- Show default PRD runes if present
        if _G.prdClassFrame and _G.prdClassFrame.Rune1 then
            for i = 1, 6 do
                local rune = _G.prdClassFrame["Rune"..i]
                if rune then
                    rune:Show()
                    rune:SetAlpha(1)
                    if rune.RegisterAllEvents then rune:RegisterAllEvents() end
                    if rune.SetScript then rune:SetScript("OnEvent", nil) end
                end
            end
        end
        return
    end
    if ShouldShowRuneBar() then
        runeBar:Show()
        UpdateRunes()
        -- Hide default PRD runes if present
        if _G.prdClassFrame and _G.prdClassFrame.Rune1 then
            for i = 1, 6 do
                local rune = _G.prdClassFrame["Rune"..i]
                if rune then
                    rune:Hide()
                    rune:SetAlpha(0)
                    if rune.UnregisterAllEvents then rune:UnregisterAllEvents() end
                    if rune.SetScript then rune:SetScript("OnEvent", nil) end
                end
            end
        end
    else
        runeBar:Hide()
    end
end

-- Update bar size and position
local function ApplyBarSettings()
    local spacing = 0
    local runeCount = #runeBar.runes
    local runeWidth = CustomDeathKnightRuneBarDB.runeWidth
    local runeHeight = CustomDeathKnightRuneBarDB.runeHeight
    local totalWidth = (runeWidth + spacing) * runeCount - spacing
    if CustomDeathKnightRuneBarDB.totalWidth and CustomDeathKnightRuneBarDB.totalWidth > 0 then
        totalWidth = CustomDeathKnightRuneBarDB.totalWidth
        runeWidth = (totalWidth + spacing) / runeCount - spacing
    end
    runeBar:SetSize(totalWidth, runeHeight)
    runeBar:ClearAllPoints()
    -- Anchoring logic
    if CustomDeathKnightRuneBarDB.anchorToPRD then
        local anchorFrame = GetPRDAnchorFrame()
        HookPRDAnchor()
        if anchorFrame then
            if CustomDeathKnightRuneBarDB.anchorPosition == "ABOVE" then
                runeBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, CustomDeathKnightRuneBarDB.anchorOffset or 10)
                if CustomDeathKnightRuneBarDB.debug then print("[DKRuneBar] Anchoring ABOVE PRD with offset", CustomDeathKnightRuneBarDB.anchorOffset or 10) end
            else
                runeBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -(CustomDeathKnightRuneBarDB.anchorOffset or 10))
                if CustomDeathKnightRuneBarDB.debug then print("[DKRuneBar] Anchoring BELOW PRD with offset", CustomDeathKnightRuneBarDB.anchorOffset or 10) end
            end
        else
            runeBar:SetPoint("CENTER", UIParent, "CENTER", CustomDeathKnightRuneBarDB.x, CustomDeathKnightRuneBarDB.y)
            if CustomDeathKnightRuneBarDB.debug then print("[DKRuneBar] PRD anchor not found, defaulting to UIParent") end
        end
    else
        runeBar:SetPoint("CENTER", UIParent, "CENTER", CustomDeathKnightRuneBarDB.x, CustomDeathKnightRuneBarDB.y)
    end
    for i, rune in ipairs(runeBar.runes) do
        rune:SetSize(runeWidth, runeHeight)
        rune:ClearAllPoints()
        rune:SetPoint("LEFT", runeBar, "LEFT", (i-1)*(runeWidth+spacing), 0)
        -- Update border positions
        rune.borderTop:SetPoint("TOPLEFT", rune, "TOPLEFT", 0, 0)
        rune.borderTop:SetPoint("TOPRIGHT", rune, "TOPRIGHT", 0, 0)
        rune.borderTop:SetHeight(1)
        rune.borderBottom:SetPoint("BOTTOMLEFT", rune, "BOTTOMLEFT", 0, 0)
        rune.borderBottom:SetPoint("BOTTOMRIGHT", rune, "BOTTOMRIGHT", 0, 0)
        rune.borderBottom:SetHeight(1)
        rune.borderLeft:SetPoint("TOPLEFT", rune, "TOPLEFT", 0, 0)
        rune.borderLeft:SetPoint("BOTTOMLEFT", rune, "BOTTOMLEFT", 0, 0)
        rune.borderLeft:SetWidth(1)
        rune.borderRight:SetPoint("TOPRIGHT", rune, "TOPRIGHT", 0, 0)
        rune.borderRight:SetPoint("BOTTOMRIGHT", rune, "BOTTOMRIGHT", 0, 0)
        rune.borderRight:SetWidth(1)
    end
    -- Locking logic
    runeBar:SetMovable(not CustomDeathKnightRuneBarDB.locked)
    runeBar:EnableMouse(not CustomDeathKnightRuneBarDB.locked)
    if CustomDeathKnightRuneBarDB.debug then print("[DKRuneBar] ApplyBarSettings", "Width:", runeWidth, "Height:", runeHeight, "TotalWidth:", totalWidth, "Locked:", CustomDeathKnightRuneBarDB.locked) end
end

-- Make the bar movable when unlocked
runeBar:SetMovable(true)
runeBar:EnableMouse(true)
runeBar:RegisterForDrag("LeftButton")
runeBar:SetScript("OnDragStart", function(self)
    if not CustomDeathKnightRuneBarDB.locked then self:StartMoving() end
end)
runeBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomDeathKnightRuneBarDB.x = x or 0
    CustomDeathKnightRuneBarDB.y = y or 0

end)

-- Slash commands for config
SLASH_CUSTOMDKRUNEBAR1 = "/cdrb"
SlashCmdList["CUSTOMDKRUNEBAR"] = function(msg)
    local cmd, arg1, arg2 = msg:match("^(%S*)%s*(%-?%d*)%s*(%-?%d*)$")
    cmd = cmd:lower() or ""
    if cmd == "lock" then
        CustomDeathKnightRuneBarDB.locked = true
        ApplyBarSettings()
        print("CustomDeathKnightRuneBar locked.")
    elseif cmd == "unlock" then
        CustomDeathKnightRuneBarDB.locked = false
        ApplyBarSettings()
        print("CustomDeathKnightRuneBar unlocked. Drag to move.")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomDeathKnightRuneBarDB.runeWidth = tonumber(arg1)
        CustomDeathKnightRuneBarDB.runeHeight = tonumber(arg2)
        ApplyBarSettings()
        print("CustomDeathKnightRuneBar rune size set to "..arg1.."x"..arg2)
    elseif cmd == "debug" then
        CustomDeathKnightRuneBarDB.debug = not CustomDeathKnightRuneBarDB.debug
        print("CustomDeathKnightRuneBar debug mode:", CustomDeathKnightRuneBarDB.debug)
    else
        print("/cdrb lock | unlock | size <width> <height> | debug")
    end
end

-- Register options as a subgroup in the main options panel
if PersonalResourceReskinPlus_Options then
    PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomDeathKnightRuneBar", {
        name = "|cffff2020Custom Death Knight Rune Bar|r",
        type = "group",
        args = {
            enableCustomRuneBar = {
                name = "Enable Custom Rune Bar",
                desc = "Show the custom rune bar. Disable to use default PRD runes.",
                type = "toggle",
                get = function() return CustomDeathKnightRuneBarDB.enabled == true end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.enabled = val and true or false
                    UpdateVisibility()
                end,
                order = 0.5,
            },
                showRuneTimers = {
                    name = "Show Rune Cooldown Timers",
                    desc = "Show or hide the cooldown timer text on each rune.",
                    type = "toggle",
                    get = function() return CustomDeathKnightRuneBarDB.showRuneTimers ~= false end,
                    set = function(_, val)
                        CustomDeathKnightRuneBarDB.showRuneTimers = val
                        UpdateRunes()
                    end,
                    order = 0.6,
                },
            runeWidth = {
                name = "Rune Width (per rune)",
                desc = "Set the width of each rune. If 'Total Bar Width' is set, this is ignored.",
                type = "range",
                min = 10, max = 100, step = 0.001,
                get = function() return CustomDeathKnightRuneBarDB.runeWidth end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.runeWidth = val
                    ApplyBarSettings()
                end,
                order = 1,
            },
            totalWidth = {
                name = "Total Bar Width",
                desc = "Set the total width for all runes combined. If set, runes will auto-fit to this width.",
                type = "range",
                min = 60, max = 600, step = 0.1,
                get = function() return CustomDeathKnightRuneBarDB.totalWidth or 0 end,
                set = function(_, val)
                    if val > 0 then
                        CustomDeathKnightRuneBarDB.totalWidth = val
                    else
                        CustomDeathKnightRuneBarDB.totalWidth = nil
                    end
                    ApplyBarSettings()
                end,
                order = 1.5,
            },
            runeHeight = {
                name = "Rune Height",
                desc = "Set the height of each rune.",
                type = "range",
                min = 10, max = 100, step = 0.001,
                get = function() return CustomDeathKnightRuneBarDB.runeHeight end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.runeHeight = val
                    ApplyBarSettings()
                end,
                order = 2,
            },
            runeBgColor = {
                name = "Rune Background Color",
                desc = "Set the background color of the runes.",
                type = "color",
                hasAlpha = true,
                get = function()
                    local c = CustomDeathKnightRuneBarDB.runeBgColor or {0, 0, 0, 0.5}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    CustomDeathKnightRuneBarDB.runeBgColor = {r, g, b, a}
                    UpdateRunes()
                end,
                order = 3,
            },
            gradientColoringEnabled = {
                name = "Enable Gradient Coloring",
                desc = "Enable gradient coloring for the runes based on position.",
                type = "toggle",
                get = function() return CustomDeathKnightRuneBarDB.gradientColoringEnabled end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.gradientColoringEnabled = val
                    UpdateRunes()
                end,
                order = 4,
            },
            gradientColor1 = {
                name = "Gradient Start Color",
                desc = "Set the start color for gradient coloring.",
                type = "color",
                hasAlpha = true,
                get = function()
                    local c = CustomDeathKnightRuneBarDB.gradientColor1 or {0.2, 0.8, 1, 1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    CustomDeathKnightRuneBarDB.gradientColor1 = {r, g, b, a}
                    UpdateRunes()
                end,
                order = 5,
            },
            gradientColor2 = {
                name = "Gradient End Color",
                desc = "Set the end color for gradient coloring.",
                type = "color",
                hasAlpha = true,
                get = function()
                    local c = CustomDeathKnightRuneBarDB.gradientColor2 or {0.2, 1, 0.8, 1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    CustomDeathKnightRuneBarDB.gradientColor2 = {r, g, b, a}
                    UpdateRunes()
                end,
                order = 6,
            },
            bloodSpecColor = {
                name = "Blood Spec Color",
                desc = "Color for Blood specialization runes.",
                type = "color",
                hasAlpha = true,
                get = function()
                    local c = CustomDeathKnightRuneBarDB.specColors and CustomDeathKnightRuneBarDB.specColors[250] or {0.77, 0.12, 0.23, 1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    CustomDeathKnightRuneBarDB.specColors[250] = {r, g, b, a}
                    UpdateRunes()
                end,
                order = 13,
            },
            frostSpecColor = {
                name = "Frost Spec Color",
                desc = "Color for Frost specialization runes.",
                type = "color",
                hasAlpha = true,
                get = function()
                    local c = CustomDeathKnightRuneBarDB.specColors and CustomDeathKnightRuneBarDB.specColors[251] or {0.20, 0.40, 0.80, 1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    CustomDeathKnightRuneBarDB.specColors[251] = {r, g, b, a}
                    UpdateRunes()
                end,
                order = 14,
            },
            unholySpecColor = {
                name = "Unholy Spec Color",
                desc = "Color for Unholy specialization runes.",
                type = "color",
                hasAlpha = true,
                get = function()
                    local c = CustomDeathKnightRuneBarDB.specColors and CustomDeathKnightRuneBarDB.specColors[252] or {0.13, 0.75, 0.13, 1}
                    return c[1], c[2], c[3], c[4]
                end,
                set = function(_, r, g, b, a)
                    CustomDeathKnightRuneBarDB.specColors[252] = {r, g, b, a}
                    UpdateRunes()
                end,
                order = 15,
            },
            anchorToPRD = {
                name = "Anchor to PRD",
                desc = "Anchor the rune bar to the Personal Resource Display.",
                type = "toggle",
                get = function() return CustomDeathKnightRuneBarDB.anchorToPRD end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.anchorToPRD = val
                    ApplyBarSettings()
                end,
                order = 7,
            },
            anchorPosition = {
                name = "Anchor Position",
                desc = "Position the bar above or below the PRD.",
                type = "select",
                values = {
                    ABOVE = "Above",
                    BELOW = "Below",
                },
                get = function() return CustomDeathKnightRuneBarDB.anchorPosition end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.anchorPosition = val
                    ApplyBarSettings()
                end,
                order = 8,
            },
            anchorOffset = {
                name = "Anchor Offset",
                desc = "Offset from the PRD anchor point.",
                type = "range",
                min = -50, max = 50, step = 1,
                get = function() return CustomDeathKnightRuneBarDB.anchorOffset or 10 end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.anchorOffset = val
                    ApplyBarSettings()
                end,
                order = 9,
            },
            anchorTarget = {
                name = "Anchor Target",
                desc = "Which PRD bar to anchor to.",
                type = "select",
                values = {
                    HEALTH = "Health Bar",
                    POWER = "Power Bar",
                },
                get = function() return CustomDeathKnightRuneBarDB.anchorTarget end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.anchorTarget = val
                    ApplyBarSettings()
                end,
                order = 10,
            },
            locked = {
                name = "Lock Position",
                desc = "Lock the bar in place to prevent accidental movement.",
                type = "toggle",
                get = function() return CustomDeathKnightRuneBarDB.locked end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.locked = val
                    ApplyBarSettings()
                    if CustomDeathKnightRuneBarDB.debug then print("[DKRuneBar] Locked set to", val) end
                end,
                order = 11,
            },
            debug = {
                name = "Debug Mode",
                desc = "Enable debug prints.",
                type = "toggle",
                get = function() return CustomDeathKnightRuneBarDB.debug end,
                set = function(_, val)
                    CustomDeathKnightRuneBarDB.debug = val
                    if val then print("[DKRuneBar] Debug mode enabled") else print("[DKRuneBar] Debug mode disabled") end
                end,
                order = 12,
            },
        },
    })
end

-- Ensure bar settings are applied after PLAYER_LOGIN (when SavedVariables are loaded)
local function OnLoginOrReload()
    SetDefaultRuneBarDB()
    ApplyBarSettings()
    UpdateVisibility()
end
runeBar:RegisterEvent("PLAYER_LOGIN")
runeBar:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        OnLoginOrReload()
    end
end)

-- Do NOT call ApplyBarSettings() or UpdateVisibility() here.
-- They are now only called after PLAYER_LOGIN, so user settings are respected.
