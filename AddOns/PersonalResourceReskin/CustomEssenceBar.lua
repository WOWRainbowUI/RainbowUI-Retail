local _, class = UnitClass("player")
if class ~= "EVOKER" then return end

-- CustomEssenceBar.lua
local function GetMaxEssence()
    -- Power Nexus: spellid 369908
    if IsPlayerSpell and IsPlayerSpell(369908) then
        return 6
    end
    return 5
end
local ESSENCE_POWER_TYPE = Enum and Enum.PowerType and Enum.PowerType.Essence or 13 -- fallback to 13 if Enum not loaded


CustomEssenceBarDB = CustomEssenceBarDB or {
    x = 0, y = -120, orbWidth = 24, orbHeight = 24, locked = false,
    totalWidth = nil, 
    orbSpacing = 0, 
    orbBgColor = {0, 0, 0, 0.5}, 
    gradientColor1 = {0, 0.7, 1, 1}, 
    gradientColor2 = {0, 1, 0.7, 1}, 
    enabled = true, 
    showEssenceTimers = true, 
}

-- Hide the default Essence bar if present
local function HideDefaultEssenceBar()
    local _, class = UnitClass("player")
    if class == "EVOKER" and CustomEssenceBarDB.enabled then
        -- Hide essence orbs and prdClassFrame if present
        local f = _G.prdClassFrame
        if f then
            f:Hide()
            f:SetAlpha(0)
            if f.GetChildren then
                for _, child in ipairs({ f:GetChildren() }) do
                    if child and child.EssenceFillDone then
                        child:Hide()
                        child:SetAlpha(0)
                    end
                end
            end
        end
    end
end

HideDefaultEssenceBar()

local essenceBar = CreateFrame("Frame", "CustomEssenceBar", UIParent)
essenceBar:SetSize(180, 32)
essenceBar:SetPoint("CENTER", UIParent, "CENTER", 0, -120)


essenceBar.orbs = {}
local function GetOrbWidth(numEssence)
    local spacing = CustomEssenceBarDB.orbSpacing
    if spacing == nil then spacing = 0 end
    if CustomEssenceBarDB.totalWidth and CustomEssenceBarDB.totalWidth > 0 then
        return (CustomEssenceBarDB.totalWidth - spacing * (numEssence - 1)) / numEssence
    else
        return CustomEssenceBarDB.orbWidth or 24
    end
end

local function CreateOrbs()
    for _, orb in ipairs(essenceBar.orbs) do
        orb:Hide()
        orb:SetParent(nil)
    end
    essenceBar.orbs = {}
    local numEssence = GetMaxEssence()
    local orbWidth = GetOrbWidth(numEssence)
    local spacing = CustomEssenceBarDB.orbSpacing
    if spacing == nil then spacing = 0 end
    for i = 1, numEssence do
        local orb = CreateFrame("Frame", nil, essenceBar)
        orb:SetSize(orbWidth, CustomEssenceBarDB.orbHeight)
        orb:SetPoint("LEFT", essenceBar, "LEFT", (i-1)*(orbWidth+spacing), 0)
        orb.bg = orb:CreateTexture(nil, "BACKGROUND")
        orb.bg:SetAllPoints()
        local bg = CustomEssenceBarDB.orbBgColor or {0, 0, 0, 0.5}
        orb.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
        orb.fill = orb:CreateTexture(nil, "ARTWORK")
        orb.fill:SetPoint("LEFT", orb, "LEFT")
        orb.fill:SetHeight(orb:GetHeight())
        orb.fill:SetWidth(orb:GetWidth())
        orb.fill:SetColorTexture(1, 1, 1, 1)
        orb.fill:SetAlpha(0.2)
        -- Add cooldown timer text
        orb.timerText = orb:CreateFontString(nil, "OVERLAY")
        local fontHeight = CustomEssenceBarDB.orbHeight or 24
        orb.timerText:SetFont("Fonts\\FRIZQT__.TTF", fontHeight * 0.7, "OUTLINE")
        orb.timerText:SetTextColor(1, 1, 1, 1)
        orb.timerText:SetPoint("CENTER", orb, "CENTER")
        orb.timerText:SetText("")
        orb.timerText:Hide()
        orb.borderTop = orb:CreateTexture(nil, "OVERLAY")
        orb.borderTop:SetColorTexture(0, 0, 0, 1)
        orb.borderTop:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderTop:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderTop:SetHeight(1)
        orb.borderBottom = orb:CreateTexture(nil, "OVERLAY")
        orb.borderBottom:SetColorTexture(0, 0, 0, 1)
        orb.borderBottom:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderBottom:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderBottom:SetHeight(1)
        orb.borderLeft = orb:CreateTexture(nil, "OVERLAY")
        orb.borderLeft:SetColorTexture(0, 0, 0, 1)
        orb.borderLeft:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderLeft:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderLeft:SetWidth(1)
        orb.borderRight = orb:CreateTexture(nil, "OVERLAY")
        orb.borderRight:SetColorTexture(0, 0, 0, 1)
        orb.borderRight:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderRight:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderRight:SetWidth(1)
        essenceBar.orbs[i] = orb
    end
end

CreateOrbs()

-- Update function
local lastMaxEssence = GetMaxEssence()
local function UpdateEssence()
    local current = UnitPower("player", ESSENCE_POWER_TYPE)
    local maxEssence = GetMaxEssence()
    if maxEssence ~= lastMaxEssence then
        lastMaxEssence = maxEssence
        CreateOrbs()
        ApplyBarSettings()
    end
    local c1 = CustomEssenceBarDB.gradientColor1 or {0, 0.7, 1, 1}
    local c2 = CustomEssenceBarDB.gradientColor2 or {0, 1, 0.7, 1}
    local bg = CustomEssenceBarDB.orbBgColor or {0, 0, 0, 0.5}
    for i, orb in ipairs(essenceBar.orbs) do
        orb.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
        local fontHeight = orb:GetHeight() or 24
        orb.timerText:SetFont("Fonts\\FRIZQT__.TTF", fontHeight * 0.7, "OUTLINE")
        local essenceReady = (i <= current)
        if essenceReady then
            orb.fill:Show()
            orb.fill:SetAlpha(1)
            orb.fill:SetHeight(orb:GetHeight())
            orb.fill:SetWidth(orb:GetWidth())
            orb.timerText:Hide()
            orb:SetScript("OnUpdate", nil)
            if orb.fill.SetVertexColor then
                orb.fill:SetVertexColor(1, 1, 1, 1)
            end
            if c1[1] == c2[1] and c1[2] == c2[2] and c1[3] == c2[3] and c1[4] == c2[4] then
                orb.fill:SetColorTexture(c1[1], c1[2], c1[3], c1[4])
            elseif orb.fill.SetGradient then
                orb.fill:SetGradient("HORIZONTAL",
                    CreateColor(c1[1], c1[2], c1[3], c1[4]),
                    CreateColor(c2[1], c2[2], c2[3], c2[4])
                )
            else
                orb.fill:SetColorTexture(c1[1], c1[2], c1[3], c1[4])
            end
            if not CustomEssenceBarDB.showEssenceTimers then
                orb.timerText:Hide()
            end
        else
            orb.fill:Show()
            orb.fill:SetAlpha(0.7)
            orb.fill:SetHeight(orb:GetHeight())
            if CustomEssenceBarDB.showEssenceTimers then
                orb.timerText:Show()
            else
                orb.timerText:Hide()
            end
            orb:SetScript("OnUpdate", function(self, elapsed)
                local w = self:GetWidth()
                local h = self:GetHeight()
                self.fill:SetHeight(h)
                local fontHeight = h or 24
                self.timerText:SetFont("Fonts\\FRIZQT__.TTF", fontHeight * 0.7, "OUTLINE")
                local missing = i - current
                local cooldownDuration = 5 * missing
                local now = GetTime()
                -- For animation, fill grows left-to-right over 5s per orb
                local pct = 1 - math.max(0, math.min(1, (cooldownDuration - (now % 5)) / 5))
                self.fill:SetPoint("LEFT", self, "LEFT")
                self.fill:SetWidth(w * pct)
                self.fill:SetAlpha(0.7)
                local remaining = cooldownDuration - (now % 5)
                if CustomEssenceBarDB.showEssenceTimers and remaining > 0 then
                    self.timerText:SetText(string.format("%.1fs", remaining))
                    self.timerText:Show()
                else
                    self.timerText:Hide()
                end
            end)
        end
    end
end

-- Event handler
essenceBar:RegisterEvent("UNIT_POWER_UPDATE")
essenceBar:RegisterEvent("PLAYER_ENTERING_WORLD")
essenceBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "ESSENCE" or powerType == ESSENCE_POWER_TYPE) then
            UpdateEssence()
        end
    else
        UpdateEssence()
    end
end)

-- Only show for Evoker
local function ShouldShowEssenceBar()
    local _, class = UnitClass("player")
    return class == "EVOKER"
end

local function IsMountedSafe()
    return IsMounted and IsMounted()
end

local function UpdateVisibility()
    -- Always try to hide Blizzard's prdClassFrame and orbs
    HideDefaultEssenceBar()
    if CustomEssenceBarDB.enabled and ShouldShowEssenceBar() and not (CustomEssenceBarDB.hideWhenMounted and IsMountedSafe()) then
        essenceBar:Show()
        UpdateEssence()
        C_Timer.After(0.05, HideDefaultEssenceBar)
    else
        essenceBar:Hide()
    end
end


essenceBar:RegisterEvent("PLAYER_LOGIN")
essenceBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
essenceBar:RegisterEvent("TRAIT_CONFIG_UPDATED")
essenceBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
essenceBar:RegisterEvent("PLAYER_TALENT_UPDATE")
essenceBar:RegisterEvent("UNIT_AURA") -- Mount/dismount detection

essenceBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "ESSENCE" or powerType == ESSENCE_POWER_TYPE) then
            UpdateEssence()
        end
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            UpdateVisibility()
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "TRAIT_CONFIG_UPDATED" or event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
        HideDefaultEssenceBar()
        CreateOrbs()
        ApplyBarSettings()
        UpdateEssence()
        UpdateVisibility()
    else
        UpdateVisibility()
    end
end)

-- Update bar size and position
ApplyBarSettings = function()
    local spacing = CustomEssenceBarDB.orbSpacing
    if spacing == nil then spacing = 0 end
    local numEssence = GetMaxEssence()
    local orbWidth = GetOrbWidth(numEssence)
    local totalWidth = orbWidth * numEssence + spacing * (numEssence - 1)
    essenceBar:SetSize(totalWidth, CustomEssenceBarDB.orbHeight)
    essenceBar:ClearAllPoints()
    essenceBar:SetPoint("CENTER", UIParent, "CENTER", CustomEssenceBarDB.x, CustomEssenceBarDB.y)
    for i, orb in ipairs(essenceBar.orbs) do
        orb:SetSize(orbWidth, CustomEssenceBarDB.orbHeight)
        orb:ClearAllPoints()
        orb:SetPoint("LEFT", essenceBar, "LEFT", (i-1)*(orbWidth+spacing), 0)
        -- Update border positions
        orb.borderTop:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderTop:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderTop:SetHeight(1)
        orb.borderBottom:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderBottom:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderBottom:SetHeight(1)
        orb.borderLeft:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderLeft:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderLeft:SetWidth(1)
        orb.borderRight:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderRight:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderRight:SetWidth(1)
    end
end
            orbSpacing = {
                name = "Orb Spacing",
                desc = "Set the spacing between each essence orb.",
                type = "range",
                min = 0, max = 40, step = 0.1,
                get = function() return CustomEssenceBarDB.orbSpacing or 6 end,
                set = function(_, val)
                    CustomEssenceBarDB.orbSpacing = val
                    CreateOrbs()
                    ApplyBarSettings()
                end,
                order = 2.7,
            },

essenceBar:SetMovable(true)
essenceBar:EnableMouse(true)
essenceBar:RegisterForDrag("LeftButton")
essenceBar:SetScript("OnDragStart", function(self)
    if not CustomEssenceBarDB.locked then self:StartMoving() end
end)
essenceBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomEssenceBarDB.x = x or 0
    CustomEssenceBarDB.y = y or 0
end)

-- Slash commands for config
SLASH_CUSTOMESSENCEBAR1 = "/ceb"
SlashCmdList["CUSTOMESSENCEBAR"] = function(msg)
    local cmd, arg1, arg2 = msg:match("^(%S*)%s*(%-?%d*)%s*(%-?%d*)$")
    cmd = cmd:lower() or ""
    if cmd == "lock" then
        CustomEssenceBarDB.locked = true
        print("CustomEssenceBar locked.")
    elseif cmd == "unlock" then
        CustomEssenceBarDB.locked = false
        print("CustomEssenceBar unlocked. Drag to move.")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomEssenceBarDB.orbWidth = tonumber(arg1)
        CustomEssenceBarDB.orbHeight = tonumber(arg2)
        ApplyBarSettings()
        print("CustomEssenceBar orb size set to "..arg1.."x"..arg2)
    else
        print("/ceb lock | unlock | size <width> <height>")
    end
end


-- Register options 
if PersonalResourceReskinPlus_Options then
    PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomEssenceBar", {
        name = "|cFF33937FCustom Essence Bar|r",
        type = "group",
        args = {
            showEssenceTimers = {
                name = "Show Essence Cooldown Timers",
                desc = "Show or hide the cooldown timer text on each essence orb.",
                type = "toggle",
                get = function() return CustomEssenceBarDB.showEssenceTimers ~= false end,
                set = function(_, val)
                    CustomEssenceBarDB.showEssenceTimers = val
                    UpdateEssence()
                end,
                order = 0.6,
            },
            enableCustomEssenceBar = {
                name = "Enable Custom Essence Bar",
                desc = "Show the custom essence bar. Disable to use default PRD essence.",
                type = "toggle",
                get = function() return CustomEssenceBarDB.enabled ~= false end,
                set = function(_, val)
                    CustomEssenceBarDB.enabled = val
                    UpdateVisibility()
                end,
                order = 0.5,
            },
            lock = {
                name = "Lock Bar",
                desc = "Lock or unlock the essence bar for dragging.",
                type = "toggle",
                get = function() return CustomEssenceBarDB.locked end,
                set = function(_, val)
                    CustomEssenceBarDB.locked = val
                    print("CustomEssenceBar "..(val and "locked." or "unlocked. Drag to move."))
                end,
                order = 1,
            },
            hideWhenMounted = {
                name = "Hide While Mounted",
                desc = "Hide the essence bar while mounted.",
                type = "toggle",
                get = function() return CustomEssenceBarDB.hideWhenMounted end,
                set = function(_, val)
                    CustomEssenceBarDB.hideWhenMounted = val
                    UpdateVisibility()
                end,
                order = 1.5,
            },
            orbWidth = {
                name = "Essence Width (per orb)",
                desc = "Set the width of each essence orb. If 'Total Bar Width' is set, this is ignored.",
                type = "range",
                min = 10, max = 100, step = 0.1,
                get = function() return CustomEssenceBarDB.orbWidth end,
                set = function(_, val)
                    CustomEssenceBarDB.orbWidth = val
                    CreateOrbs()
                    ApplyBarSettings()
                end,
                order = 2,
            },
            totalWidth = {
                name = "Total Bar Width",
                desc = "Set the total width for all orbs combined. If set, orbs will auto-fit to this width.",
                type = "range",
                min = 60, max = 600, step = 0.1,
                get = function() return CustomEssenceBarDB.totalWidth or 0 end,
                set = function(_, val)
                    if val > 0 then
                        CustomEssenceBarDB.totalWidth = val
                    else
                        CustomEssenceBarDB.totalWidth = nil
                    end
                    CreateOrbs()
                    ApplyBarSettings()
                end,
                order = 2.5,
            },
            orbHeight = {
                name = "Essence Height",
                desc = "Set the height of each essence orb.",
                type = "range",
                min = 10, max = 100, step = 1,
                get = function() return CustomEssenceBarDB.orbHeight end,
                set = function(_, val)
                    CustomEssenceBarDB.orbHeight = val
                    ApplyBarSettings()
                end,
                order = 3,
            },
            orbBgColor = {
                name = "Orb Background Color",
                desc = "Set the background color for each essence orb (behind the gradient fill).",
                type = "color",
                hasAlpha = true,
                order = 4,
                get = function() return unpack(CustomEssenceBarDB.orbBgColor or {0, 0, 0, 0.5}) end,
                set = function(_, r, g, b, a)
                    CustomEssenceBarDB.orbBgColor = {r, g, b, a}
                    UpdateEssence()
                end,
            },
            gradientColor1 = {
                name = "Orb Gradient Start",
                desc = "Set the gradient start color for the essence orb fill.",
                type = "color",
                hasAlpha = true,
                order = 5,
                get = function() return unpack(CustomEssenceBarDB.gradientColor1 or {0, 0.7, 1, 1}) end,
                set = function(_, r, g, b, a)
                    CustomEssenceBarDB.gradientColor1 = {r, g, b, a}
                    UpdateEssence()
                end,
            },
            gradientColor2 = {
                name = "Orb Gradient End",
                desc = "Set the gradient end color for the essence orb fill.",
                type = "color",
                hasAlpha = true,
                order = 6,
                get = function() return unpack(CustomEssenceBarDB.gradientColor2 or {0, 1, 0.7, 1}) end,
                set = function(_, r, g, b, a)
                    CustomEssenceBarDB.gradientColor2 = {r, g, b, a}
                    UpdateEssence()
                end,
            },
        },
    })
end

-- Ensure bar settings are applied after PLAYER_LOGIN
local function OnLoginOrReload()
    ApplyBarSettings()
end
essenceBar:RegisterEvent("PLAYER_LOGIN")
essenceBar:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        OnLoginOrReload()
    end
end)

-- Apply settings on load
ApplyBarSettings()

UpdateVisibility()
