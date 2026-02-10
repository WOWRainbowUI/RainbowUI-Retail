-- Prevent any call to SetClampRectInsets on PlayerFrame to avoid protected function errors
local function IsInEditModeOrCombat()
    return InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive)
end

local function SafeBlockClampRectInsets(frame)
    if not frame or frame.__PRR_ClampBlocked then return end
    if not frame.SetClampRectInsets then return end
    if IsInEditModeOrCombat() then return end
    frame.__PRR_ClampBlocked = true
    hooksecurefunc(frame, "SetClampRectInsets", function()
        if not IsInEditModeOrCombat() then
            -- Blocked: Do nothing to avoid taint
        end
    end)
end

local function BlockAllClampRectInsets()
    if IsInEditModeOrCombat() then return end
    SafeBlockClampRectInsets(PlayerFrame)
    local prd = _G.PersonalResourceDisplayFrame
    SafeBlockClampRectInsets(prd)
    if prd then
        SafeBlockClampRectInsets(prd.PowerBar)
        SafeBlockClampRectInsets(prd.AlternatePowerBar)
    end
end

-- Initial block (if safe)
BlockAllClampRectInsets()

-- Re-block after Edit Mode or world entry, but only if not in combat or Edit Mode
local reblockFrame = CreateFrame("Frame")
reblockFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
reblockFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
reblockFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
reblockFrame:SetScript("OnEvent", function()
    BlockAllClampRectInsets()
end)
-- Moves the Alternate Power Bar using X/Y offsets from the profile
function _G.MoveAlternatePowerBar()
    local profile = PersonalResourceReskin.db and PersonalResourceReskin.db.profile
    if not profile then return end
    local prd = _G["PersonalResourceDisplayFrame"]
    -- Only move the Alternate Power Bar if explicitly called (e.g., from the X/Y slider), not on every update or event
    if prd and prd.AlternatePowerBar then
        if profile.altPowerBarWidth then
            prd.AlternatePowerBar:SetWidth(profile.altPowerBarWidth)
        end
        if profile.altPowerBarHeight then
            prd.AlternatePowerBar:SetHeight(profile.altPowerBarHeight)
        end
        -- Only set position if user is not in Edit Mode
        if not (EditModeManagerFrame and EditModeManagerFrame.editModeActive) then
            prd.AlternatePowerBar:ClearAllPoints()
            prd.AlternatePowerBar:SetPoint("CENTER", UIParent, "CENTER", profile.altPowerBarX or 0, profile.altPowerBarY or 0)
        end
    end
end
        -- Helper to apply legacy combo/rune spacing
        local function ApplyLegacyComboSpacing()
            -- Reapply legacy combo/rune offsets and scale after combat or world entry
            -- (Scaling of Blizzard runes is now fully disabled)
            local function ReapplyLegacyComboSettings()
                if type(ApplyLegacyComboSpacing) == "function" then ApplyLegacyComboSpacing() end
                -- Only scale legacy frames, not Blizzard's classResourceFrame
                local profile = PersonalResourceReskin.db and PersonalResourceReskin.db.profile
                if profile and profile.legacyComboScale then
                    local val = profile.legacyComboScale
                    if _G.LegacyComboFrame and _G.LegacyComboFrame.SetScale then
                        _G.LegacyComboFrame:SetScale(val)
                    end
                    if _G.prdClassFrame and _G.prdClassFrame.SetScale then
                        _G.prdClassFrame:SetScale(val)
                    end
                end
            end

            local legacyComboEventFrame = CreateFrame("Frame")
            legacyComboEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            legacyComboEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            legacyComboEventFrame:SetScript("OnEvent", function()
                C_Timer.After(0.1, ReapplyLegacyComboSettings) -- Delay to let Blizzard code run first
            end)
            local spacing = PersonalResourceReskin.db and PersonalResourceReskin.db.profile and PersonalResourceReskin.db.profile.legacyComboSpacing or 0
            local scaleVal = PersonalResourceReskin.db and PersonalResourceReskin.db.profile and PersonalResourceReskin.db.profile.legacyComboScale or 1
            local function spaceChildren(frame, prefix, count)
                if not frame then return end
                if InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive) then return end
                local x = 0
                for i = 1, count do
                    local child = frame[prefix .. i]
                    if child and child.SetPoint and child.ClearAllPoints then
                        child:ClearAllPoints()
                        child:SetPoint("LEFT", frame, "LEFT", x, 0)
                        x = x + (child:GetWidth() or 0) + spacing
                    end
                end
            end
            -- LegacyComboFrame
                -- Only set scale and position for prdClassFrame itself, do not modify children
                if _G.prdClassFrame and _G.prdClassFrame.SetScale then
                    _G.prdClassFrame:SetScale(scaleVal)
                end
                -- If you want to set position, do it here (example):
                -- if _G.prdClassFrame and _G.prdClassFrame.SetPoint then
                --     _G.prdClassFrame:ClearAllPoints()
                --     _G.prdClassFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                -- end
            -- Blizzard default combo point frames
            for _, name in ipairs({"ComboPointPlayerFrame", "ClassNameplateBarRogueFrame", "ClassNameplateBarDruidFrame", "prdClassFrame"}) do
                local f = _G[name]
                if f then
                    -- Optionally hide or adjust these frames for custom bars
                    f:Hide()
                    f:SetAlpha(0)
                end
            end
            -- PRD class resource frame
            -- Do not touch Blizzard's classResourceFrame (runes/combo points) at all
        end
        -- Helper to position children centered
        local function centerChildren(frame, prefix, count, scale, spacing)
            if not frame then return end
            if InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive) then return end
            local widths = {}
            local totalWidth = 0
            for i = 1, count do
                local child = frame[prefix .. i]
                if child and child.GetWidth then
                    local w = (child:GetWidth() or 0) * (scale or 1)
                    widths[i] = w
                    totalWidth = totalWidth + w
                else
                    widths[i] = 0
                end
            end
            totalWidth = totalWidth + spacing * (count - 1)
            local startX = -totalWidth / 2
            for i = 1, count do
                local child = frame[prefix .. i]
                if child and child.SetPoint and child.ClearAllPoints then
                    child:ClearAllPoints()
                    child:SetScale(scale or 1)
                    child:SetPoint("LEFT", frame, "CENTER", startX, 0)
                    startX = startX + widths[i] + spacing
                end
            end
        end

        -- Patch ApplyLegacyComboSpacing to use centerChildren
        local orig_ApplyLegacyComboSpacing = ApplyLegacyComboSpacing
        ApplyLegacyComboSpacing = function()
            local spacing = PersonalResourceReskin.db and PersonalResourceReskin.db.profile and PersonalResourceReskin.db.profile.legacyComboSpacing or 0
            local scaleVal = PersonalResourceReskin.db and PersonalResourceReskin.db.profile and PersonalResourceReskin.db.profile.legacyComboScale or 1
            if _G.LegacyComboFrame then
                centerChildren(_G.LegacyComboFrame, "ComboPoint", 10, scaleVal, spacing)
                -- centerChildren(_G.LegacyComboFrame, "Rune", 6, scaleVal, spacing) -- Disabled: do not touch Blizzard runes
            end
            -- PRD class resource frame (if needed)
            if _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.classResourceFrame then
                local frame = _G.PersonalResourceDisplayFrame.classResourceFrame
                if frame.comboPoints then
                    local x = 0
                    for i = 1, #frame.comboPoints do
                        local child = frame.comboPoints[i]
                        if child and child.SetPoint and child.ClearAllPoints then
                            child:ClearAllPoints()
                            child:SetPoint("LEFT", frame, "LEFT", x, 0)
                            x = x + (child:GetWidth() or 0) + spacing
                        end
                    end
                end
                -- centerChildren(frame, "Rune", 6) -- Disabled: do not touch Blizzard runes
            end
        end
        local function GetClassSpecProfileName()
            local _, class = UnitClass("player")
            local specIndex = GetSpecialization()
            local specName = specIndex and select(2, GetSpecializationInfo(specIndex)) or "Default"
            return class .. "_" .. (specName or "Default")
        end

        local function SwitchProfileForClassSpec()
            local profileName = GetClassSpecProfileName()
            -- print("[PersonalResourceReskin] Current profile:", PersonalResourceReskin.db:GetCurrentProfile(), "Desired:", profileName)
            if PersonalResourceReskin.db:GetCurrentProfile() ~= profileName then
                -- Only switch if the profile already exists, otherwise stay on current
                local profiles = {}
                PersonalResourceReskin.db:GetProfiles(profiles)
                for _, name in ipairs(profiles) do
                    if name == profileName then
                        -- print("[PersonalResourceReskin] Switching to profile:", profileName)
                        PersonalResourceReskin.db:SetProfile(profileName)
                        return
                    end
                end
                -- print("[PersonalResourceReskin] Profile not found, staying on current profile.")
            end
        end
                -- All references to CustomRogueComboBar and its options have been removed
            -- ...existing code...
-- Reskins the Personal Resource Display bar using LibSharedMedia

local ADDON_NAME = ...
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
if not LSM then
    print("|cffff0000[PersonalResourceReskin]|r LibSharedMedia-3.0 not loaded! Please check your TOC file and library installation.")
    return
end

local AceDB = LibStub("AceDB-3.0")
local AceAddon = LibStub("AceAddon-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local PersonalResourceReskin = AceAddon:NewAddon("PersonalResourceReskin", "AceConsole-3.0")
_G["PersonalResourceReskin"] = PersonalResourceReskin

LSM:Register("statusbar", "White8x8", "Interface\\AddOns\\Personal Resource Display\\media\\White8x8.tga")

-- Register shrub.tga as a custom texture
LSM:Register("statusbar", "Shrub", "Interface\\AddOns\\PersonalResourceReskin\\Media\\shrub.tga")

local defaults = {
    profile = {
        texture = "White8x8",
        font = "Friz Quadrata TT",
        fontFlags = "OUTLINE",
        fontColor = {1, 1, 1, 1},
        powerBgColor = {0, 0, 0, 0.5},
        healthBgColor = {0, 0, 0, 0.5},
        healthBarColor = {0.2, 0.8, 0.2, 1}, -- default green
        altPowerBgColor = {0, 0, 0, 0.5},
        useClassColor = false,
        width = 220, -- PowerBar width
        frameWidth = 220, -- Overall frame width
        healthHeight = 24, -- Health bar height
        prdScale = 1, -- Overall PRD scale
        healthTextScale = 1, -- Health text scale
        healthTextSize = 14,
        showHealthText = true,
        legacyComboScale = 1,
        legacyComboSpacing = 0,
        -- PRD PowerBar gradient colors (defaults: blue to cyan)
        prdGradientColor1 = {0, 0.8, 1, 1},
        prdGradientColor2 = {0, 0.2, 1, 1},
        -- Alternate Power Bar gradient colors (defaults: purple to magenta)
        altPowerGradientColor1 = {0.6, 0.2, 1, 1},
        altPowerGradientColor2 = {1, 0.2, 0.8, 1},
        legacyComboXOffset = {
            name = "Legacy Combo X Offset",
            desc = "Set the X offset for each legacy combo/rune child in prdClassFrame.",
            type = "range",
            min = -100, max = 100, step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.legacyComboXOffset or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.legacyComboXOffset = val
                    ApplyLegacyComboSpacing()
                end
            end,
            order = 0.837,
        },
        legacyComboYOffset = {
            name = "Legacy Combo Y Offset",
            desc = "Set the Y offset for each legacy combo/rune child in prdClassFrame.",
            type = "range",
            min = -100, max = 100, step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.legacyComboYOffset or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.legacyComboYOffset = val
                    ApplyLegacyComboSpacing()
                end
            end,
            order = 0.838,
        },
        resourceYOffset = 14,
        resourceXOffset = 0,
        absorbTexture = "White8x8", -- Default absorb bar texture
        hideOnMount = true -- Hide PRD when mounted
    }
}

local function GetProfile()
    -- Always use the latest db reference, and only after OnInitialize
    return PersonalResourceReskin.db and PersonalResourceReskin.db.profile or defaults.profile
end

local function ReskinBar(bar, barType)
    if not bar then return end
    local profile = GetProfile()
    local tex = LSM:Fetch("statusbar", profile.texture) or "Blizzard"
    if bar.SetStatusBarTexture then
        bar:SetStatusBarTexture(tex)
    end
    -- Add a 'T' marker at 32% width for the PowerBar for all Death Knight specs
    if barType == "power" then
        local _, class = UnitClass("player")
        local spec = GetSpecialization() -- 1: Blood, 2: Frost, 3: Unholy
        if class == "DEATHKNIGHT" and (spec == 1 or spec == 2 or spec == 3) then
            if not bar.__PRD_IMarker then
                -- Vertical line
                local vLine = bar:CreateTexture(nil, "OVERLAY")
                -- Horizontal line
                local hLine = bar:CreateTexture(nil, "OVERLAY")
                bar.__PRD_IMarker = {vLine = vLine, hLine = hLine}
            end
            local barWidth = bar:GetWidth() or 220
            local barHeight = bar:GetHeight() or 20
            local x = barWidth * 0.32
            local vLine = bar.__PRD_IMarker.vLine
            local hLine = bar.__PRD_IMarker.hLine
            vLine:SetColorTexture(1, 1, 1, 1)
            vLine:SetSize(2, bar:GetHeight() * 1)
            vLine:ClearAllPoints()
            vLine:SetPoint("BOTTOM", bar, "BOTTOMLEFT", x, 0)
            hLine:SetColorTexture(0, 0, 0, 0)
            hLine:SetSize(12, 2)
            hLine:ClearAllPoints()
            hLine:SetPoint("BOTTOM", vLine, "TOP", 0, 0)
            vLine:SetHeight(bar:GetHeight() * 1)
            hLine:SetWidth(12)
            vLine:Show()
            hLine:Show()
        end
    end
    -- Hide marker for classes that are not Death Knight or Demon Hunter
    if barType == "power" then
        local _, class = UnitClass("player")
        if class ~= "DEATHKNIGHT" and class ~= "DEMONHUNTER" and bar.__PRD_IMarker then
            bar.__PRD_IMarker.vLine:Hide()
            bar.__PRD_IMarker.hLine:Hide()
        end
    end
       -- Add a 'T' marker at 29.17% width for the PowerBar
    if barType == "power" then
        local _, class = UnitClass("player")
        local spec = GetSpecialization() -- 1: havoc, 2: Vengeance, 3: devour
        if class == "DEMONHUNTER" and spec == 2 then
            if not bar.__PRD_IMarker then
                -- Vertical line
                local vLine = bar:CreateTexture(nil, "OVERLAY")
                vLine:SetColorTexture(0, 0, 0, 1)
                vLine:SetSize(2, bar:GetHeight() * 1)
                -- Horizontal line
                local hLine = bar:CreateTexture(nil, "OVERLAY")
                hLine:SetColorTexture(0, 0, 0, 0)
                hLine:SetSize(12, 2)
                bar.__PRD_IMarker = {vLine = vLine, hLine = hLine}
            end
            local barWidth = bar:GetWidth() or 220
            local barHeight = bar:GetHeight() or 20
            local x = barWidth * 0.2917
            local vLine = bar.__PRD_IMarker.vLine
            local hLine = bar.__PRD_IMarker.hLine
            vLine:ClearAllPoints()
            vLine:SetPoint("BOTTOM", bar, "BOTTOMLEFT", x, 0)
            hLine:ClearAllPoints()
            hLine:SetPoint("BOTTOM", vLine, "TOP", 0, 0)
            vLine:SetHeight(bar:GetHeight() * 1)
            hLine:SetWidth(12)
            vLine:Show()
            hLine:Show()
        end
    end
        -- Add a 'T' marker at 33.33% width for the PowerBar
    if barType == "power" then
        local _, class = UnitClass("player")
        local spec = GetSpecialization() -- 1: havoc, 2: Vengeance, 3: devour
        if class == "DEMONHUNTER" and spec == 1 then
            if not bar.__PRD_IMarker then
                -- Vertical line
                local vLine = bar:CreateTexture(nil, "OVERLAY")
                vLine:SetColorTexture(0, 0, 0, 1)
                vLine:SetSize(2, bar:GetHeight() * 1)
                -- Horizontal line
                local hLine = bar:CreateTexture(nil, "OVERLAY")
                hLine:SetColorTexture(0, 0, 0, 0)
                hLine:SetSize(12, 2)
                bar.__PRD_IMarker = {vLine = vLine, hLine = hLine}
            end
            local barWidth = bar:GetWidth() or 220
            local barHeight = bar:GetHeight() or 20
            local x = barWidth * 0.3333
            local vLine = bar.__PRD_IMarker.vLine
            local hLine = bar.__PRD_IMarker.hLine
            vLine:ClearAllPoints()
            vLine:SetPoint("BOTTOM", bar, "BOTTOMLEFT", x, 0)
            hLine:ClearAllPoints()
            hLine:SetPoint("BOTTOM", vLine, "TOP", 0, 0)
            vLine:SetHeight(bar:GetHeight() * 1)
            hLine:SetWidth(12)
            vLine:Show()
            hLine:Show()
        end
    end
        -- Add a 'T' marker at 83.333% width for the PowerBar
    if barType == "power" then
        local _, class = UnitClass("player")
        local spec = GetSpecialization() -- 1: havoc, 2: Vengeance, 3: devour
        if class == "DEMONHUNTER" and spec == 3 then
            if not bar.__PRD_IMarker then
                -- Vertical line
                local vLine = bar:CreateTexture(nil, "OVERLAY")
                vLine:SetColorTexture(1, 1, 1, 1)
                vLine:SetSize(2, bar:GetHeight() * 1)
                -- Horizontal line
                local hLine = bar:CreateTexture(nil, "OVERLAY")
                hLine:SetColorTexture(0, 0, 0, 0)
                hLine:SetSize(12, 2)
                bar.__PRD_IMarker = {vLine = vLine, hLine = hLine}
            end
            local barWidth = bar:GetWidth() or 220
            local barHeight = bar:GetHeight() or 20
            local x = barWidth * 0.8333
            local vLine = bar.__PRD_IMarker.vLine
            local hLine = bar.__PRD_IMarker.hLine
            vLine:ClearAllPoints()
            vLine:SetPoint("BOTTOM", bar, "BOTTOMLEFT", x, 0)
            hLine:ClearAllPoints()
            hLine:SetPoint("BOTTOM", vLine, "TOP", 0, 0)
            vLine:SetHeight(bar:GetHeight() * 1)
            hLine:SetWidth(12)
            vLine:Show()
            hLine:Show()
        end
    end
    -- Hide marker for non-Demon Hunter classes
    if barType == "power" then
        local _, class = UnitClass("player")
        if class ~= "DEMONHUNTER" and bar.__PRD_IMarker then
            bar.__PRD_IMarker.vLine:Hide()
            bar.__PRD_IMarker.hLine:Hide()
        end
    end
-- Add 'T' markers at multiple percentages for the Alternate Power Bar
if barType == "altpower" then
    local _, class = UnitClass("player")
    local spec = GetSpecialization() -- 1: havoc, 2: Vengeance, 3: devour
    if class == "DEMONHUNTER" and spec == 3 then
        local percents = {0.14286, 0.28571, 0.42857, 0.57143, 0.71429, 0.85714, 1.0}
        bar.__PRD_AltMarkers = bar.__PRD_AltMarkers or {}
        local barWidth = bar:GetWidth() or 220
        local barHeight = bar:GetHeight() or 20
        -- Create or update markers
        for i, pct in ipairs(percents) do
            if not bar.__PRD_AltMarkers[i] then
                local vLine = bar:CreateTexture(nil, "OVERLAY")
                vLine:SetColorTexture(0, 0, 0, 0.9)
                vLine:SetSize(2, barHeight)
                local hLine = bar:CreateTexture(nil, "OVERLAY")
                hLine:SetColorTexture(0, 0, 0, 0)
                hLine:SetSize(12, 2)
                bar.__PRD_AltMarkers[i] = {vLine = vLine, hLine = hLine}
            end
            local x = barWidth * pct
            local vLine = bar.__PRD_AltMarkers[i].vLine
            local hLine = bar.__PRD_AltMarkers[i].hLine
            vLine:ClearAllPoints()
            vLine:SetPoint("BOTTOM", bar, "BOTTOMLEFT", x, 0)
            hLine:ClearAllPoints()
            hLine:SetPoint("BOTTOM", vLine, "TOP", 0, 0)
            vLine:SetHeight(barHeight)
            hLine:SetWidth(12)
            vLine:Show()
            hLine:Show()
        end
        -- Hide any extra markers if the table is too long
        for i = #percents + 1, #bar.__PRD_AltMarkers do
            local marker = bar.__PRD_AltMarkers[i]
            if marker then
                marker.vLine:Hide()
                marker.hLine:Hide()
            end
        end

        -- Hook SetHeight to always update marker heights if not already hooked
        if not bar.__PRD_AltMarkers_HeightHooked then
            bar.__PRD_AltMarkers_HeightHooked = true
            local origSetHeight = bar.SetHeight
            bar.SetHeight = function(self, newHeight, ...)
                local result = origSetHeight(self, newHeight, ...)
                -- Only update markers if they exist and this is the right bar
                if self.__PRD_AltMarkers and type(self.__PRD_AltMarkers) == "table" then
                    local barWidth = self:GetWidth() or 220
                    for i, marker in ipairs(self.__PRD_AltMarkers) do
                        if marker and marker.vLine and marker.hLine then
                            marker.vLine:SetHeight(newHeight)
                            -- Optionally, reposition in case barWidth changed
                            local pct = percents[i]
                            if pct then
                                local x = barWidth * pct
                                marker.vLine:ClearAllPoints()
                                marker.vLine:SetPoint("BOTTOM", self, "BOTTOMLEFT", x, 0)
                                marker.hLine:ClearAllPoints()
                                marker.hLine:SetPoint("BOTTOM", marker.vLine, "TOP", 0, 0)
                            end
                        end
                    end
                end
                return result
            end
        end
    elseif bar.__PRD_AltMarkers then
        for _, marker in ipairs(bar.__PRD_AltMarkers) do
            marker.vLine:Hide()
            marker.hLine:Hide()
        end
    end
elseif bar.__PRD_AltMarkers then
    for _, marker in ipairs(bar.__PRD_AltMarkers) do
        marker.vLine:Hide()
        marker.hLine:Hide()
    end
end
   
    -- Set or update background
    local bgColor
    if barType == "power" then
        bgColor = profile.powerBgColor
    elseif barType == "altpower" then
        bgColor = profile.altPowerBgColor
    else
        bgColor = profile.healthBgColor
    end
    if not bar.__PRD_BG then
        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(bar)
        bg:SetColorTexture(unpack(bgColor))
        bar.__PRD_BG = bg
    else
        bar.__PRD_BG:SetColorTexture(unpack(bgColor))
    end

    -- Add or update text
    if not bar.__PRD_Text then
        local text = bar:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", bar, "CENTER", 0, 0)
        bar.__PRD_Text = text
    end
    local fontPath = LSM:Fetch("font", profile.font)
    bar.__PRD_Text:SetFont(fontPath, profile.healthTextSize or 14, profile.fontFlags ~= "NONE" and profile.fontFlags or nil)
    bar.__PRD_Text:SetTextColor(unpack(profile.fontColor))

    -- Set health bar color: use class color if enabled, otherwise use gradient
    if barType == "health" and bar.SetStatusBarTexture and bar.GetStatusBarTexture then
        local texObj = bar:GetStatusBarTexture()
        if profile.useClassColor and RAID_CLASS_COLORS and UnitClass("player") then
            local _, class = UnitClass("player")
            local classColor = RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1, a = 1 }
            local r, g, b, a = classColor.r, classColor.g, classColor.b, classColor.a or 1
            if texObj and texObj.SetColorTexture then
                texObj:SetColorTexture(r, g, b, a)
            elseif texObj and texObj.SetVertexColor then
                texObj:SetVertexColor(r, g, b, a)
            end
            if bar.barTexture and bar.barTexture.SetColorTexture then
                bar.barTexture:SetColorTexture(r, g, b, a)
            elseif bar.barTexture and bar.barTexture.SetVertexColor then
                bar.barTexture:SetVertexColor(r, g, b, a)
            end
        else
            -- Clear any solid color so gradient is visible
            if texObj and texObj.SetColorTexture then
                texObj:SetColorTexture(1, 1, 1, 1)
            elseif texObj and texObj.SetVertexColor then
                texObj:SetVertexColor(1, 1, 1, 1)
            end
            if bar.barTexture and bar.barTexture.SetColorTexture then
                bar.barTexture:SetColorTexture(1, 1, 1, 1)
            elseif bar.barTexture and bar.barTexture.SetVertexColor then
                bar.barTexture:SetVertexColor(1, 1, 1, 1)
            end
            local c1 = profile.healthGradientColor1 or {0.2, 0.8, 0.2, 1}
            local c2 = profile.healthGradientColor2 or {1, 1, 0.2, 1}
            if texObj and texObj.SetGradient then
                texObj:SetGradient("HORIZONTAL",
                    CreateColor(c1[1], c1[2], c1[3], c1[4]),
                    CreateColor(c2[1], c2[2], c2[3], c2[4])
                )
            end
            if bar.barTexture and bar.barTexture.SetGradient then
                bar.barTexture:SetGradient("HORIZONTAL",
                    CreateColor(c1[1], c1[2], c1[3], c1[4]),
                    CreateColor(c2[1], c2[2], c2[3], c2[4])
                )
            end
        end
    end

    -- PRD PowerBar gradient (class toggle)
    if barType == "power" and bar.SetStatusBarTexture and bar.GetStatusBarTexture then
        local _, class = UnitClass("player")
        local enabled = (profile.prdGradientEnabled or {})[class]
        if enabled ~= false then
            local c1 = profile.prdGradientColor1 or {0, 0.8, 1, 1}
            local c2 = profile.prdGradientColor2 or {0, 0.2, 1, 1}
            local texObj = bar:GetStatusBarTexture()
            if texObj and texObj.SetGradient then
                texObj:SetGradient("HORIZONTAL",
                    CreateColor(c1[1], c1[2], c1[3], c1[4]),
                    CreateColor(c2[1], c2[2], c2[3], c2[4])
                )
            end
        end
    end
    -- Alternate PowerBar gradient
    if barType == "altpower" and bar.SetStatusBarTexture and bar.GetStatusBarTexture then
        local c1 = profile.altPowerGradientColor1 or {0.6, 0.2, 1, 1}
        local c2 = profile.altPowerGradientColor2 or {1, 0.2, 0.8, 1}
        local texObj = bar:GetStatusBarTexture()
        if texObj and texObj.SetGradient then
            texObj:SetGradient("HORIZONTAL",
                CreateColor(c1[1], c1[2], c1[3], c1[4]),
                CreateColor(c2[1], c2[2], c2[3], c2[4])
            )
        end
    end

    -- Set width
    if barType == "power" then
        if profile.width and type(profile.width) == "number" then
            bar:SetWidth(profile.width)
        end
    elseif barType == "health" then
        if profile.healthWidth and type(profile.healthWidth) == "number" then
            bar:SetWidth(profile.healthWidth)
        end
    end
end

local function ApplyReskinToPRD()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd then return end
    local profile = GetProfile()
    -- Apply saved frame width
    if prd.SetWidth and profile.frameWidth then
        prd:SetWidth(profile.frameWidth)
    end
    -- Power Bar
    if prd.PowerBar then
        if profile.width then
            prd.PowerBar:SetWidth(profile.width)
        end
        if profile.powerBarHeight then
            prd.PowerBar:SetHeight(profile.powerBarHeight)
        end
        ReskinBar(prd.PowerBar, "power")
        -- Hook SetStatusBarColor and OnValueChanged to reapply gradient
        if not prd.PowerBar.__PRD_GradientHooked then
            prd.PowerBar.__PRD_GradientHooked = true
            local function reapplyGradient()
                local profile = GetProfile()
                local _, class = UnitClass("player")
                local enabled = (profile.prdGradientEnabled or {})[class]
                local texObj = prd.PowerBar:GetStatusBarTexture()
                if enabled == false then
                    -- Remove gradient by setting to solid white (or fallback color)
                    if texObj and texObj.SetColorTexture then
                        texObj:SetColorTexture(1, 1, 1, 1)
                    elseif texObj and texObj.SetVertexColor then
                        texObj:SetVertexColor(1, 1, 1, 1)
                    end
                    local feedback = prd.PowerBar.FeedbackFrame and prd.PowerBar.FeedbackFrame.BarTexture
                    if feedback and feedback.SetColorTexture then
                        feedback:SetColorTexture(1, 1, 1, 1)
                    elseif feedback and feedback.SetVertexColor then
                        feedback:SetVertexColor(1, 1, 1, 1)
                    end
                    return
                end
                local c1 = profile.prdGradientColor1 or {0, 0.8, 1, 1}
                local c2 = profile.prdGradientColor2 or {0, 0.2, 1, 1}
                if texObj and texObj.SetGradient then
                    texObj:SetGradient("HORIZONTAL",
                        CreateColor(c1[1], c1[2], c1[3], c1[4]),
                        CreateColor(c2[1], c2[2], c2[3], c2[4])
                    )
                end
                -- Also apply to FeedbackFrame.BarTexture if present
                local feedback = prd.PowerBar.FeedbackFrame and prd.PowerBar.FeedbackFrame.BarTexture
                if feedback and feedback.SetGradient then
                    feedback:SetGradient("HORIZONTAL",
                        CreateColor(c1[1], c1[2], c1[3], c1[4]),
                        CreateColor(c2[1], c2[2], c2[3], c2[4])
                    )
                end
            end
            hooksecurefunc(prd.PowerBar, "SetStatusBarColor", reapplyGradient)
            prd.PowerBar:HookScript("OnValueChanged", reapplyGradient)
            -- Also hook FeedbackFrame.BarTexture SetVertexColor if present
            local feedback = prd.PowerBar.FeedbackFrame and prd.PowerBar.FeedbackFrame.BarTexture
            if feedback and not feedback.__PRD_GradientHooked then
                feedback.__PRD_GradientHooked = true
                hooksecurefunc(feedback, "SetVertexColor", reapplyGradient)
            end
        end
    end
    -- Health Bar: try both healthBar and healthBar.healthBar
    local healthBar = nil
    if prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        if prd.HealthBarsContainer.healthBar.healthBar then
            healthBar = prd.HealthBarsContainer.healthBar.healthBar
        else
            healthBar = prd.HealthBarsContainer.healthBar
        end
    end
    if healthBar then
        ReskinBar(healthBar, "health")
    end
    -- Scale health bar container for height adjustment
    if prd.HealthBarsContainer and profile.healthHeight and type(profile.healthHeight) == "number" then
        local scaleVal = profile.healthHeight / 24 -- 24 is default height, scale relative to that
        prd.HealthBarsContainer:SetScale(scaleVal)
    end
    -- Scale health text independently
    if prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        for _, region in ipairs({prd.HealthBarsContainer.healthBar:GetRegions()}) do
            if region and region:IsObjectType("FontString") and region:GetName() == "PlayerHealthTextFontString" then
                if profile.healthTextScale and type(profile.healthTextScale) == "number" then
                    region:SetScale(profile.healthTextScale)
                end
            end
        end
    end
    if healthBar then
        -- Hook SetStatusBarColor and OnValueChanged to reapply gradient for HealthBar
        if not healthBar.__PRD_GradientHooked then
            healthBar.__PRD_GradientHooked = true
            local function reapplyHealthGradient()
                local profile = GetProfile()
                local texObj = healthBar:GetStatusBarTexture()
                if profile.useClassColor and RAID_CLASS_COLORS and UnitClass("player") then
                    local _, class = UnitClass("player")
                    local classColor = RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1, a = 1 }
                    local r, g, b, a = classColor.r, classColor.g, classColor.b, classColor.a or 1
                    -- Main status bar texture
                    if texObj and texObj.SetColorTexture then
                        texObj:SetColorTexture(r, g, b, a)
                    elseif texObj and texObj.SetVertexColor then
                        texObj:SetVertexColor(r, g, b, a)
                    end
                    if healthBar.barTexture and healthBar.barTexture.SetColorTexture then
                        healthBar.barTexture:SetColorTexture(r, g, b, a)
                    elseif healthBar.barTexture and healthBar.barTexture.SetVertexColor then
                        healthBar.barTexture:SetVertexColor(r, g, b, a)
                    end
                else
                    -- Clear any solid color so gradient is visible
                    if texObj and texObj.SetColorTexture then
                        texObj:SetColorTexture(1, 1, 1, 1)
                    elseif texObj and texObj.SetVertexColor then
                        texObj:SetVertexColor(1, 1, 1, 1)
                    end
                    if healthBar.barTexture and healthBar.barTexture.SetColorTexture then
                        healthBar.barTexture:SetColorTexture(1, 1, 1, 1)
                    elseif healthBar.barTexture and healthBar.barTexture.SetVertexColor then
                        healthBar.barTexture:SetVertexColor(1, 1, 1, 1)
                    end
                    local c1 = profile.healthGradientColor1 or {0.2, 0.8, 0.2, 1}
                    local c2 = profile.healthGradientColor2 or {1, 1, 0.2, 1}
                    -- Main status bar texture
                    if texObj and texObj.SetGradient then
                        texObj:SetGradient("HORIZONTAL",
                            CreateColor(c1[1], c1[2], c1[3], c1[4]),
                            CreateColor(c2[1], c2[2], c2[3], c2[4])
                        )
                    end
                    -- Also apply to .barTexture if present
                    if healthBar.barTexture and healthBar.barTexture.SetGradient then
                        healthBar.barTexture:SetGradient("HORIZONTAL",
                            CreateColor(c1[1], c1[2], c1[3], c1[4]),
                            CreateColor(c2[1], c2[2], c2[3], c2[4])
                        )
                    end
                end
            end
            hooksecurefunc(healthBar, "SetStatusBarColor", reapplyHealthGradient)
            healthBar:HookScript("OnValueChanged", reapplyHealthGradient)
        end
        -- Force apply the gradient immediately on load
        if healthBar:GetStatusBarTexture() and healthBar:GetStatusBarTexture().SetGradient then
            local c1 = profile.healthGradientColor1 or {0.2, 0.8, 0.2, 1}
            local c2 = profile.healthGradientColor2 or {1, 1, 0.2, 1}
            healthBar:GetStatusBarTexture():SetGradient("HORIZONTAL",
                CreateColor(c1[1], c1[2], c1[3], c1[4]),
                CreateColor(c2[1], c2[2], c2[3], c2[4])
            )
        end
        if healthBar.barTexture and healthBar.barTexture.SetGradient then
            local c1 = profile.healthGradientColor1 or {0.2, 0.8, 0.2, 1}
            local c2 = profile.healthGradientColor2 or {1, 1, 0.2, 1}
            healthBar.barTexture:SetGradient("HORIZONTAL",
                CreateColor(c1[1], c1[2], c1[3], c1[4]),
                CreateColor(c2[1], c2[2], c2[3], c2[4])
            )
        end
    end
    -- Alternate Power Bar
    if prd.AlternatePowerBar then
        local _, class = UnitClass("player")
        local enabled = (GetProfile().altPowerGradientEnabled or {})[class]
        if enabled ~= false then
            ReskinBar(prd.AlternatePowerBar, "altpower")
            -- Hook SetStatusBarColor and OnValueChanged to reapply gradient for AlternatePowerBar
            if not prd.AlternatePowerBar.__PRD_GradientHooked then
                prd.AlternatePowerBar.__PRD_GradientHooked = true
                local function reapplyAltGradient()
                    local profile = GetProfile()
                    local c1 = profile.altPowerGradientColor1 or {0.6, 0.2, 1, 1}
                    local c2 = profile.altPowerGradientColor2 or {1, 0.2, 0.8, 1}
                    local texObj = prd.AlternatePowerBar:GetStatusBarTexture() or prd.AlternatePowerBar.Texture
                    if texObj and texObj.SetGradient then
                        texObj:SetGradient("HORIZONTAL",
                            CreateColor(c1[1], c1[2], c1[3], c1[4]),
                            CreateColor(c2[1], c2[2], c2[3], c2[4])
                        )
                    end
                end
                hooksecurefunc(prd.AlternatePowerBar, "SetStatusBarColor", reapplyAltGradient)
                prd.AlternatePowerBar:HookScript("OnValueChanged", reapplyAltGradient)
            end
        end
    end
    if type(_G.UpdateMoveClassResource) == "function" then _G.UpdateMoveClassResource() end
    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
end


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("UNIT_DISPLAYPOWER")
f:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        local prd = _G.PersonalResourceDisplayFrame
        if prd then
            local profile = GetProfile()
            if profile.hideOnMount and IsMounted() then
                prd:Hide()
            else
                prd:Show()
            end
        end
        local chpb = _G.CustomHolyPowerBar
        if chpb then
            local profile = CustomHolyPowerBarDB and CustomHolyPowerBarDB.hideOnMount
            if profile and IsMounted() then
                chpb:Hide()
            else
                chpb:Show()
            end
        end
        return
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        SwitchProfileForClassSpec()
        ApplyReskinToPRD()
    else
        C_Timer.After(0.1, ApplyReskinToPRD)
    end
end)

-- Ensure AlternatePowerBar is repositioned after PRD is shown/hidden
C_Timer.After(0, function()
    local prd = _G.PersonalResourceDisplayFrame
    if prd then
        prd:HookScript("OnShow", function()
            if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
        end)
        prd:HookScript("OnHide", function()
            if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
        end)
    end
end)

-- AceConfig options table is now created in OnInitialize to ensure db is ready
local options

function PersonalResourceReskin:OnInitialize()
    self.db = AceDB:New("PersonalResourceReskinDB", defaults, true)
    -- Enable spec profile support using LibDualSpec
    local LibDualSpec = LibStub("LibDualSpec-1.0", true)
    if LibDualSpec then
        LibDualSpec:EnhanceDatabase(self.db, "PersonalResourceReskin")
    end
    -- Register callback to update bar live on profile change
    if self.db.RegisterCallback then
        self.db:RegisterCallback("OnProfileChanged", function() ApplyReskinToPRD() end)
        self.db:RegisterCallback("OnProfileCopied", function() ApplyReskinToPRD() end)
        self.db:RegisterCallback("OnProfileReset", function() ApplyReskinToPRD() end)
    end
    local function getSoulShardBarOptions()
        if _G.CustomSoulShardBarOptions then
            return _G.CustomSoulShardBarOptions
        elseif type(CustomSoulShardBarOptions) == "table" then
            return CustomSoulShardBarOptions
        else
            return {name = "Soul Shard Bar", type = "group", args = {}}
        end
    end
    options = {
        name = "PersonalResourceReskin",
        type = "group",
        args = {
            -- Remove soulShardBar subgroup from here; will be registered as a tab below
            phtCommands = {
                name = "Player Health Text Commands",
                type = "group",
                inline = true,
                order = 0.1,
                args = {
                    phtToggle = {
                        name = "Toggle Show/Hide",
                        desc = "Toggle the health text display.",
                        type = "execute",
                        func = function()
                            if _G.PlayerHealthTextDB then
                                if PlayerHealthTextDB.visibleAlpha > 0 then
                                    PlayerHealthTextDB.visibleAlpha = 0
                                    if PlayerHealthTextFrame then PlayerHealthTextFrame:Hide() end
                                else
                                    PlayerHealthTextDB.visibleAlpha = 1
                                    if PlayerHealthTextFrame then PlayerHealthTextFrame:Show() end
                                end
                            end
                        end,
                        order = 1,
                    },
                    phtShow = {
                        name = "Show",
                        desc = "Show the health text.",
                        type = "execute",
                        func = function()
                            if PlayerHealthTextFrame then PlayerHealthTextFrame:Show() end
                            if _G.PlayerHealthTextDB then PlayerHealthTextDB.visibleAlpha = 1 end
                        end,
                        order = 2,
                    },
                    phtHide = {
                        name = "Hide",
                        desc = "Hide the health text.",
                        type = "execute",
                        func = function()
                            if PlayerHealthTextFrame then PlayerHealthTextFrame:Hide() end
                            if _G.PlayerHealthTextDB then PlayerHealthTextDB.visibleAlpha = 0 end
                        end,
                        order = 3,
                    },
                    phtTextPosition = {
                        name = "Text Position",
                        desc = "Set the health text position on the PRD health bar.",
                        type = "select",
                        values = { center = "Center", left = "Left", right = "Right" },
                        get = function()
                            local db = _G.PlayerHealthTextDB or {}
                            return db.textPosition or "center"
                        end,
                        set = function(_, val)
                            if not _G.PlayerHealthTextDB then _G.PlayerHealthTextDB = {} end
                            _G.PlayerHealthTextDB.textPosition = val
                            if type(_G.ApplyDisplaySettings) == "function" then pcall(_G.ApplyDisplaySettings) end
                        end,
                        order = 4,
                    },
                    phtStyle = {
                        name = "Set Style",
                        desc = "Set health text style: Percent, Current, or Current / Percent.",
                        type = "select",
                        values = { percent = "Percent", current = "Current", both = "Current / Percent" },
                        get = function()
                            local db = _G.PlayerHealthTextDB or {}
                            local mode = db.displayMode or "percent"
                            if mode == "both" then return "both"
                            elseif mode == "current" then return "current"
                            else return "percent" end
                        end,
                        set = function(_, val)
                            if not _G.PlayerHealthTextDB then _G.PlayerHealthTextDB = {} end
                            if val == "both" then
                                _G.PlayerHealthTextDB.displayMode = "both"
                            elseif val == "current" then
                                _G.PlayerHealthTextDB.displayMode = "current"
                            else
                                _G.PlayerHealthTextDB.displayMode = "percent"
                            end
                            if type(_G.UpdateHealthText) == "function" then pcall(_G.UpdateHealthText) end
                        end,
                        order = 6,
                    },
                    phtReset = {
                        name = "Reset Position",
                        desc = "Reset the health text position to default.",
                        type = "execute",
                        func = function()
                            if _G.PlayerHealthTextDB then
                                PlayerHealthTextDB.point = nil
                                PlayerHealthTextDB.x = nil
                                PlayerHealthTextDB.y = nil
                                PlayerHealthTextDB.offsetX = 0
                                PlayerHealthTextDB.offsetY = -160
                            end
                            if PlayerHealthTextFrame then
                                if not (InCombatLockdown() or (EditModeManagerFrame and EditModeManagerFrame.editModeActive)) then
                                    PlayerHealthTextFrame:ClearAllPoints()
                                    PlayerHealthTextFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -160)
                                end
                            end
                            if type(_G.ApplyDisplaySettings) == "function" then pcall(_G.ApplyDisplaySettings) end
                        end,
                        order = 7,
                    },
                },
            },
            -- All other options (pptLock, playerPowerTextOptions, texture, absorbTexture, etc.) must be moved here inside args
            pptLock = {
                name = "Lock Player Power Text",
                desc = "Lock or unlock the PlayerPowerText frame for dragging.",
                type = "toggle",
                get = function()
                    return _G.PlayerPowerTextDB and _G.PlayerPowerTextDB.locked
                end,
                set = function(_, val)
                    if not _G.PlayerPowerTextDB then return end
                    _G.PlayerPowerTextDB.locked = val
                    local frame = _G.PlayerPowerTextFrame
                    if frame and type(frame.StopMovingOrSizing) == "function" then pcall(frame.StopMovingOrSizing, frame) end
                    if type(_G.ApplyDisplaySettings) == "function" then pcall(_G.ApplyDisplaySettings) end
                end,
                order = 0.6,
            },
            playerPowerTextOptions = {
                name = "PlayerPowerText Style",
                desc = "Set PlayerPowerText style: Percent, Current, Current / Max, or Current / Percent.",
                type = "select",
                values = { current = "Current", currentmax = "Current / Max" },
                get = function()
                    local db = _G.PlayerPowerTextDB or {}
                    local mode = db.displayMode or "current"
                    if mode == "currentmax" then return "currentmax"
                    else return "current" end
                end,
                set = function(_, val)
                    if not _G.PlayerPowerTextDB then _G.PlayerPowerTextDB = {} end
                    _G.PlayerPowerTextDB.displayMode = val
                    if type(_G.UpdatePlayerPowerText) == "function" then pcall(_G.UpdatePlayerPowerText) end
                end,
                order = 0.5,
            },
            texture = {
                name = "Bar Texture",
                desc = "Select the bar texture",
                type = "select",
                values = function()
                    local textures = LSM:HashTable("statusbar")
                    local short = {}
                    for k, v in pairs(textures) do
                        local filename = v:match("[^\\/]+$") or v
                        short[filename] = k -- map filename to LSM key
                    end
                    return short
                end,
                get = function()
                    local key = GetProfile().texture
                    local textures = LSM:HashTable("statusbar")
                    for k, v in pairs(textures) do
                        local filename = v:match("[^\\/]+$") or v
                        if k == key then
                            return filename
                        end
                    end
                    return key
                end,
                set = function(_, val)
                    -- val is the filename, map back to LSM key
                    local textures = LSM:HashTable("statusbar")
                    for k, v in pairs(textures) do
                        local filename = v:match("[^\\/]+$") or v
                        if filename == val then
                            GetProfile().texture = k
                            if type(_G.PRR_ApplySavedTexture) == "function" then
                                _G.PRR_ApplySavedTexture()
                            else
                                local texPath = LSM:Fetch("statusbar", k)
                                local prd = _G["PersonalResourceDisplayFrame"]
                                if prd and prd.PowerBar then
                                    prd.PowerBar:SetStatusBarTexture(texPath)
                                    if prd.PowerBar.Texture and prd.PowerBar.Texture.SetTexture then
                                        prd.PowerBar.Texture:SetTexture(texPath)
                                    end
                                end
                                if prd and prd.AlternatePowerBar then prd.AlternatePowerBar:SetStatusBarTexture(texPath) end
                                local healthBar = nil
                                if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
                                    if prd.HealthBarsContainer.healthBar.healthBar then
                                        healthBar = prd.HealthBarsContainer.healthBar.healthBar
                                    else
                                        healthBar = prd.HealthBarsContainer.healthBar
                                    end
                                end
                                if healthBar then healthBar:SetStatusBarTexture(texPath) end
                            end
                            break
                        end
                    end
                end,
                dialogControl = "Dropdown",
                width = 2,
            },
            absorbTexture = {
                name = "Absorb Bar Texture",
                desc = "Select the texture for the absorb status bar.",
                type = "select",
                values = function()
                    local textures = LSM:HashTable("statusbar")
                    local short = {}
                    for k, v in pairs(textures) do
                        local filename = v:match("[^\\/]+$") or v
                        short[k] = filename
                    end
                    return short
                end,
                get = function() return GetProfile().absorbTexture end,
                set = function(_, val)
                    GetProfile().absorbTexture = val
                    -- Update absorb bar immediately if present
                    local frame = _G["PersonalResourceDisplayFrame"]
                    if frame and frame.__blizzAbsorbBar and frame.__blizzAbsorbBar.SetStatusBarTexture then
                        local tex = LSM:Fetch("statusbar", val)
                        frame.__blizzAbsorbBar:SetStatusBarTexture(tex)
                    end
                    -- Also update absorbBarBG if present
                    local bg = _G["PersonalResourceDisplayFrame_AbsorbBarBG"]
                    if bg and bg.SetStatusBarTexture then
                        local tex = LSM:Fetch("statusbar", val)
                        bg:SetStatusBarTexture(tex)
                    end
                end,
                dialogControl = "Dropdown",
                width = 2,
            },
            -- Font dropdown removed as requested
            -- Font style dropdown removed as requested
            fontColor = {
                name = "Font Color",
                desc = "Set the font color for bar text",
                type = "color",
                hasAlpha = true,
                get = function() return unpack(GetProfile().fontColor) end,
                set = function(_, r, g, b, a)
                    GetProfile().fontColor = {r, g, b, a}
                    ApplyReskinToPRD()
                    -- Also update PlayerPowerText color if present
                    if _G.PlayerPowerTextDB then
                        _G.PlayerPowerTextDB.color = {r, g, b}
                        if type(_G.ApplyDisplaySettings) == "function" then pcall(_G.ApplyDisplaySettings) end
                    end
                end,
            },
            -- Removed old healthBarColor picker in favor of gradient color pickers
            useClassColor = {
                name = "Use Class Color",
                desc = "Use your class color for the health bar.",
                type = "toggle",
                get = function() return GetProfile().useClassColor end,
                set = function(_, val)
                    GetProfile().useClassColor = val
                    ApplyReskinToPRD()
                end,
                order = 0.46,
            },
            -- PRD PowerBar Gradient Toggle and Color Pickers
            prdGradientEnable = {
                name = "Enable Power Bar Gradient for this class",
                desc = "Show and use the power bar gradient color pickers for this class.",
                type = "toggle",
                order = 0.440,
                get = function()
                    local _, class = UnitClass("player")
                    local t = GetProfile().prdGradientEnabled or {}
                    return t[class] ~= false -- default true
                end,
                set = function(_, val)
                    local _, class = UnitClass("player")
                    GetProfile().prdGradientEnabled = GetProfile().prdGradientEnabled or {}
                    GetProfile().prdGradientEnabled[class] = val
                    ApplyReskinToPRD()
                end,
            },
            prdGradientColor1 = {
                name = "Power Bar Gradient Start",
                desc = "Set the gradient start color for the PRD Power Bar.",
                type = "color",
                hasAlpha = true,
                order = 0.441,
                get = function()
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().prdGradientEnabled or {})[class]
                    if enabled == false then return 0, 0.8, 1, 1 end
                    return unpack(GetProfile().prdGradientColor1 or {0, 0.8, 1, 1})
                end,
                set = function(_, r, g, b, a)
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().prdGradientEnabled or {})[class]
                    if enabled == false then return end
                    GetProfile().prdGradientColor1 = {r, g, b, a}
                    ApplyReskinToPRD()
                end,
            },
            prdGradientColor2 = {
                name = "Power Bar Gradient End",
                desc = "Set the gradient end color for the PRD Power Bar.",
                type = "color",
                hasAlpha = true,
                order = 0.442,
                get = function()
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().prdGradientEnabled or {})[class]
                    if enabled == false then return 0, 0.2, 1, 1 end
                    return unpack(GetProfile().prdGradientColor2 or {0, 0.2, 1, 1})
                end,
                set = function(_, r, g, b, a)
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().prdGradientEnabled or {})[class]
                    if enabled == false then return end
                    GetProfile().prdGradientColor2 = {r, g, b, a}
                    ApplyReskinToPRD()
                end,
            },
            -- Health Bar Gradient Color Pickers
            healthGradientColor1 = {
                name = "Health Bar Gradient Start",
                desc = "Set the gradient start color for the Health Bar.",
                type = "color",
                hasAlpha = true,
                get = function() return unpack(GetProfile().healthGradientColor1 or {0.2, 0.8, 0.2, 1}) end,
                set = function(_, r, g, b, a)
                    GetProfile().healthGradientColor1 = {r, g, b, a}
                    ApplyReskinToPRD()
                end,
                order = 0.445,
            },
            healthGradientColor2 = {
                name = "Health Bar Gradient End",
                desc = "Set the gradient end color for the Health Bar.",
                type = "color",
                hasAlpha = true,
                get = function() return unpack(GetProfile().healthGradientColor2 or {1, 1, 0.2, 1}) end,
                set = function(_, r, g, b, a)
                    GetProfile().healthGradientColor2 = {r, g, b, a}
                    ApplyReskinToPRD()
                end,
                order = 0.446,
            },
            -- Alternate PowerBar Gradient Color Pickers
            altPowerGradientEnable = {
                name = "Enable Alternate Power Bar Gradient for this class",
                desc = "Show and use the alternate power bar gradient color pickers for this class.",
                type = "toggle",
                order = 0.442,
                get = function()
                    local _, class = UnitClass("player")
                    local t = GetProfile().altPowerGradientEnabled or {}
                    return t[class] ~= false -- default true
                end,
                set = function(_, val)
                    local _, class = UnitClass("player")
                    GetProfile().altPowerGradientEnabled = GetProfile().altPowerGradientEnabled or {}
                    GetProfile().altPowerGradientEnabled[class] = val
                    ApplyReskinToPRD()
                end,
            },
            altPowerGradientColor1 = {
                name = "Alternate Power Bar Gradient Start",
                desc = "Set the gradient start color for the Alternate Power Bar.",
                type = "color",
                hasAlpha = true,
                order = 0.443,
                get = function()
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().altPowerGradientEnabled or {})[class]
                    if enabled == false then return 0.6, 0.2, 1, 1 end
                    return unpack(GetProfile().altPowerGradientColor1 or {0.6, 0.2, 1, 1})
                end,
                set = function(_, r, g, b, a)
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().altPowerGradientEnabled or {})[class]
                    if enabled == false then return end
                    GetProfile().altPowerGradientColor1 = {r, g, b, a}
                    ApplyReskinToPRD()
                end,
            },
            altPowerGradientColor2 = {
                name = "Alternate Power Bar Gradient End",
                desc = "Set the gradient end color for the Alternate Power Bar.",
                type = "color",
                hasAlpha = true,
                order = 0.444,
                get = function()
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().altPowerGradientEnabled or {})[class]
                    if enabled == false then return 1, 0.2, 0.8, 1 end
                    return unpack(GetProfile().altPowerGradientColor2 or {1, 0.2, 0.8, 1})
                end,
                set = function(_, r, g, b, a)
                    local _, class = UnitClass("player")
                    local enabled = (GetProfile().altPowerGradientEnabled or {})[class]
                    if enabled == false then return end
                    GetProfile().altPowerGradientColor2 = {r, g, b, a}
                    ApplyReskinToPRD()
                end,
            },
        healthBgColor = {
            name = "Health Bar Background",
            desc = "Set the background color for the health bar.",
            type = "color",
            hasAlpha = true,
            get = function() return unpack(GetProfile().healthBgColor) end,
            set = function(_, r, g, b, a)
                GetProfile().healthBgColor = {r, g, b, a}
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar and prd.HealthBarsContainer.healthBar.__PRD_BG then
                    prd.HealthBarsContainer.healthBar.__PRD_BG:SetColorTexture(r, g, b, a)
                end
                ApplyReskinToPRD()
            end,
        },
        altPowerBgColor = {
            name = "Alternate Power Bar Background",
            desc = "Set the background color for the alternate power bar.",
            type = "color",
            hasAlpha = true,
            get = function() return unpack(GetProfile().altPowerBgColor) end,
            set = function(_, r, g, b, a)
                GetProfile().altPowerBgColor = {r, g, b, a}
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.AlternatePowerBar and prd.AlternatePowerBar.__PRD_BG then
                    prd.AlternatePowerBar.__PRD_BG:SetColorTexture(r, g, b, a)
                end
                ApplyReskinToPRD()
            end,
        },
        width = {
            name = "Power Bar Width",
            desc = "Adjust the width of the mana/power bar.",
            type = "range",
            min = 1,
            max = 600,
            step = 1,
            get = function() return GetProfile().width end,
            set = function(_, val)
                GetProfile().width = val
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.PowerBar then
                    prd.PowerBar:SetWidth(val)
                end
                ApplyReskinToPRD()
            end,
            order = 0.81,
        },
        frameWidth = {
            name = "Overall Frame Width",
            desc = "Adjust the width of the entire Personal Resource Display frame (affects all bars).",
            type = "range",
            min = 1,
            max = 600,
            step = 1,
            get = function() return GetProfile().frameWidth end,
            set = function(_, val)
                GetProfile().frameWidth = val
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.SetWidth then
                    prd:SetWidth(val)
                end
                ApplyReskinToPRD()
            end,
            order = 0.8,
        },
        healthHeight = {
            name = "Health Bar Height Scale",
            desc = "Scale the PRD health bar height only (24 = default, 12 = half height, 48 = double height).",
            type = "range",
            min = 6,
            max = 100,
            step = 1,
            get = function() return GetProfile().healthHeight end,
            set = function(_, val)
                GetProfile().healthHeight = val
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.SetScale then
                    local scaleVal = val / 24 -- 24 is default
                    prd.HealthBarsContainer:SetScale(scaleVal)
                end
                ApplyReskinToPRD()
            end,
            order = 0.805,
        },
        healthTextScale = {
            name = "Health Text Scale",
            desc = "Scale the player health text independently from the health bar.",
            type = "range",
            min = 0.1,
            max = 2.0,
            step = 0.05,
            get = function() return GetProfile().healthTextScale end,
            set = function(_, val)
                GetProfile().healthTextScale = val
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
                    for _, region in ipairs({prd.HealthBarsContainer.healthBar:GetRegions()}) do
                        if region and region:IsObjectType("FontString") and region:GetName() == "PlayerHealthTextFontString" then
                            region:SetScale(val)
                        end
                    end
                end
                ApplyReskinToPRD()
            end,
            order = 0.806,
        },
        powerBarHeight = {
            name = "Power Bar Height",
            desc = "Adjust the height of the PRD power bar.",
            type = "range",
            min = 3,
            max = 50,
            step = 1,
            get = function() return GetProfile().powerBarHeight end,
            set = function(_, val)
                GetProfile().powerBarHeight = val
                local prd = _G["PersonalResourceDisplayFrame"]
                if prd and prd.PowerBar then
                    prd.PowerBar:SetHeight(val)
                end
                ApplyReskinToPRD()
            end,
            order = 0.8065,
        },
        -- These must be inside args, not at the root
        -- resourceYOffset and resourceXOffset moved below
        legacyComboScale = {
            name = "Legacy Combo Scale",
            desc = "Set the scale of legacy combo point frames.",
            type = "range",
            min = 0.5,
            max = 5,
            step = 0.01,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.legacyComboScale or 1) or 1
            end,
            set = function(_, val)
                if val and val > 0 and PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.legacyComboScale = val
                    if type(_G.MoveClassResourceFrames) == "function" then _G.MoveClassResourceFrames() end
                    local class = select(2, UnitClass("player"))
                    local found = false
                    -- Rogue Combo Points Scaling
                    local function scaleRogueComboPoints()
                        if _G.LegacyComboFrame and _G.LegacyComboFrame.SetScale then
                            _G.LegacyComboFrame:SetScale(val)
                            found = true
                            for i = 1, 10 do
                                local child = _G.LegacyComboFrame["ComboPoint" .. i]
                                if child and child.SetScale then
                                    child:SetScale(val)
                                    found = true
                                end
                            end
                        end
                        for _, name in ipairs({"ComboPointPlayerFrame", "ClassNameplateBarRogueFrame", "ClassNameplateBarDruidFrame", "prdClassFrame"}) do
                            if _G.prdClassFrame and _G.prdClassFrame.GetChildren then
                                for _, child in ipairs({ _G.prdClassFrame:GetChildren() }) do
                                    if child and child.SetScale then
                                        child:SetScale(val)
                                        found = true
                                    end
                                end
                            end
                        end
                        if _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.classResourceFrame and _G.PersonalResourceDisplayFrame.classResourceFrame.SetScale then
                            local frame = _G.PersonalResourceDisplayFrame.classResourceFrame
                            frame:SetScale(val)
                            found = true
                            if frame.comboPoints then
                                for i = 1, #frame.comboPoints do
                                    if frame.comboPoints[i] and frame.comboPoints[i].SetScale then
                                        frame.comboPoints[i]:SetScale(val)
                                        found = true
                                    end
                                end
                            end
                        end
                    end
                    -- Death Knight Rune Scaling
                    local function scaleDeathKnightRunes()
                        local function scaleRunes(frame)
                            for runeIndex = 1, 6 do
                                local rune = frame["Rune" .. runeIndex]
                                if rune then
                                    for _, subName in ipairs({"BG_Active","BG_Inactive","BG_Shadow","Glow","Glow2","Rune_Active","Rune_Eyes","Rune_Grad","Rune_Inactive","Rune_Lines","Rune_Mid","Smoke"}) do
                                        local subFrame = rune[subName]
                                        if subFrame and subFrame.SetScale then
                                            subFrame:SetScale(val)
                                            found = true
                                        end
                                    end
                                end
                            end
                        end
                        if _G.LegacyComboFrame then
                            scaleRunes(_G.LegacyComboFrame)
                        end
                        if _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.classResourceFrame then
                            scaleRunes(_G.PersonalResourceDisplayFrame.classResourceFrame)
                        end
                    end
                    -- Apply scaling based on class
                    if class == "ROGUE" or class == "DRUID" then
                        scaleRogueComboPoints()
                    elseif class == "DEATHKNIGHT" then
                        scaleDeathKnightRunes()
                    end
                    if not found then print("No legacy combo/rune frame found to scale.") end
                end
            end,
            order = 0.834,
        },
        legacyComboSpacing = {
            name = "Legacy Combo Spacing",
            desc = "Set the horizontal spacing between legacy combo/rune points.",
            type = "range",
            min = 0,
            max = 40,
            step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.legacyComboSpacing or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.legacyComboSpacing = val
                    ApplyLegacyComboSpacing()
                end
            end,
            order = 0.835,
        },
        legacyComboXOffset = {
            name = "Legacy Combo X Offset",
            desc = "Set the X offset for each legacy combo/rune child in prdClassFrame.",
            type = "range",
            min = -100, max = 100, step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.legacyComboXOffset or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.legacyComboXOffset = val
                    ApplyLegacyComboSpacing()
                end
            end,
            order = 0.836,
        },
        legacyComboYOffset = {
            name = "Legacy Combo Y Offset",
            desc = "Set the Y offset for each legacy combo/rune child in prdClassFrame.",
            type = "range",
            min = -100, max = 100, step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.legacyComboYOffset or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.legacyComboYOffset = val
                    ApplyLegacyComboSpacing()
                end
            end,
            order = 0.837,
        },

        manaCostPredictionBarTexture = {
            name = "Mana Cost Prediction Bar Texture",
            desc = "Select a texture for the Mana Cost Prediction Bar.",
            type = "select",
            values = function()
                local LSM = LibStub("LibSharedMedia-3.0")
                return LSM:HashTable("statusbar")
            end,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.manaCostPredictionBarTexture or "Blizzard")
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then

                    PersonalResourceReskin.db.profile.manaCostPredictionBarTexture = val
                    local prd = _G.PersonalResourceDisplayFrame
                    local bar = prd and prd.PowerBar and prd.PowerBar.ManaCostPredictionBar
                    if bar then
                        local LSM = LibStub("LibSharedMedia-3.0")
                        local tex = LSM:Fetch("statusbar", val) or "Blizzard"
                        bar:SetTexture(tex)
                    end
                end
            end,
            order = 0.837,
        },

        -- Alternate Power Bar Width
        altPowerBarWidth = {
            name = "Alternate Power Bar Width",
            desc = "Adjust the width of the Alternate Power Bar.",
            type = "range",
            min = 50,
            max = 600,
            step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.altPowerBarWidth or 220) or 220
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.altPowerBarWidth = val
                    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
                end
            end,
            order = 0.839,
        },
        altPowerBarX = {
            name = "Alternate Power Bar X Offset",
            desc = "Move the Alternate Power Bar left/right.",
            type = "range",
            min = -1000,
            max = 1000,
            step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.altPowerBarX or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.altPowerBarX = val
                    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
                end
            end,
            order = 0.84,
        },
        -- Alternate Power Bar Y Offset
        altPowerBarY = {
            name = "Alternate Power Bar Y Offset",
            desc = "Move the Alternate Power Bar up/down.",
            type = "range",
            min = -1000,
            max = 1000,
            step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.altPowerBarY or 0) or 0
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.altPowerBarY = val
                    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
                end
            end,
            order = 0.841,
        },

        -- Alternate Power Bar Height
        altPowerBarHeight = {
            name = "Alternate Power Bar Height",
            desc = "Adjust the height of the Alternate Power Bar.",
            type = "range",
            min = 5,
            max = 100,
            step = 1,
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and (PersonalResourceReskin.db.profile.altPowerBarHeight or 20) or 20
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.altPowerBarHeight = val
                    if type(_G.MoveAlternatePowerBar) == "function" then _G.MoveAlternatePowerBar() end
                end
            end,
            order = 0.842,
        },

        -- Anchor mode toggle
        devourAnchorToAltPowerBar = {
            name = "Anchor Devour Text to Alternate Power Bar",
            desc = "If enabled, Devour Text will be anchored to the Alternate Power Bar.",
            type = "toggle",
            get = function()
                return PersonalResourceReskin.db and PersonalResourceReskin.db.profile and PersonalResourceReskin.db.profile.devourAnchorToAltPowerBar
            end,
            set = function(_, val)
                if PersonalResourceReskin.db and PersonalResourceReskin.db.profile then
                    PersonalResourceReskin.db.profile.devourAnchorToAltPowerBar = val
                    if type(_G.UpdateDevourTextAnchor) == "function" then _G.UpdateDevourTextAnchor() end
                end
            end,
            order = 0.843,
        },

        hideOnMount = {
            name = "Hide PRD when Mounted",
            desc = "Automatically hide the Personal Resource Display when mounted.",
            type = "toggle",
            get = function() return GetProfile().hideOnMount end,
            set = function(_, val)
                GetProfile().hideOnMount = val
                -- Apply immediately
                local prd = _G.PersonalResourceDisplayFrame
                if prd then
                    if val and IsMounted() then
                        prd:Hide()
                    else
                        prd:Show()
                    end
                end
            end,
            order = 0.844,
        },
    }
}
-- End of options table
            -- Register Custom Essence Bar options as a subpage ONLY if player is an Evoker
            local _, class = UnitClass("player")
            if class == "EVOKER" and _G.CustomEssenceBarOptions then
                PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomEssenceBar", _G.CustomEssenceBarOptions)
            end
            -- Load and register Essence Bar Options ONLY if player is an Evoker
            local _, class = UnitClass("player")
            if class == "EVOKER" then
                if not _G.CustomEssenceBarOptions and type(loadfile) == "function" then
                    pcall(function() loadfile("Interface/AddOns/PersonalResourceReskin/CustomEssenceBarOptions.lua")() end)
                end
                if _G.CustomEssenceBarOptions then
                    PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomEssenceBar", _G.CustomEssenceBarOptions)
                end
            end
    -- Register main options as usual
    if PersonalResourceReskinPlus_Options then
        PersonalResourceReskinPlus_Options.RegisterSubOptions("PersonalResourceReskin", options)
        if _G.CustomSoulShardBarOptions then
            PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomSoulShardBar", _G.CustomSoulShardBarOptions)
        end
        -- Register Custom Druid Combo Bar options as a subpage ONLY if player is a Druid
        local _, class = UnitClass("player")
        if class == "DRUID" and _G.CustomDruidComboBarOptions then
            PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomDruidComboBar", _G.CustomDruidComboBarOptions)
        end
        -- Register SoulsTrackerVeng options as a subpage if available
        if _G.SoulsTrackerVengOptions then
            PersonalResourceReskinPlus_Options.RegisterSubOptions("SoulsTrackerVeng", _G.SoulsTrackerVengOptions)
        end
        -- Register MonkOrbTracker options as a subpage if available
        if _G.MonkOrbTrackerOptions then
            PersonalResourceReskinPlus_Options.RegisterSubOptions("MonkOrbTracker", _G.MonkOrbTrackerOptions)
        end
            -- Register WarriorPainTracker options as a subpage if available
            if _G.WarriorPainTrackerOptions then
                PersonalResourceReskinPlus_Options.RegisterSubOptions("WarriorPainTracker", _G.WarriorPainTrackerOptions)
            end
        -- Register WarriorTracker options as a subpage if available (Fury Warrior Whirlwind tracker)
        if _G.WarriorTrackerOptions then
            PersonalResourceReskinPlus_Options.RegisterSubOptions("WarriorTracker", _G.WarriorTrackerOptions)
        end
        -- Add a dedicated Profile Management subpage using AceDBOptions-3.0
        local AceDBOptions = LibStub and LibStub("AceDBOptions-3.0", true)
        local LibDualSpec = LibStub("LibDualSpec-1.0", true)
        if AceDBOptions and self.db then
            local profileOptions = AceDBOptions:GetOptionsTable(self.db)
            -- Enhance profile options with spec profile support
            if LibDualSpec then
                LibDualSpec:EnhanceOptions(profileOptions, self.db)
            end
            profileOptions.order = 1000
            profileOptions.name = "Profile Management"
            profileOptions.args = profileOptions.args or {}
            profileOptions.args._ckraigfriend_logo = {
                order = 9998,
                type = "description",
                name = "|TInterface/AddOns/PersonalResourceReskin/Media/ckraiglogo.tga:64:64:0:0|t",
                fontSize = "medium",
            }
            profileOptions.args._ckraigfriend_footer = {
                order = 9999,
                type = "description",
                name = "|cff888888|r\n\n|cffffffffMade by Ckraigfriend|r",
                fontSize = "medium",
            }
            profileOptions.args._current_profile_footer = {
                order = 10000,
                type = "description",
                name = function()
                    local db = PersonalResourceReskin and PersonalResourceReskin.db
                    local prof = db and db:GetCurrentProfile() or "Unknown"
                    return "|cffaaaaaaCurrent Profile:|r |cffffffff" .. prof .. "|r"
                end,
                fontSize = "medium",
            }
            PersonalResourceReskinPlus_Options.RegisterSubOptions("Profiles", profileOptions)
        end

        -- Add Custom Rogue Combo Bar options if available
        -- Load Rogue Combo Bar Options if not already loaded
        if not _G.CustomRogueComboBarOptions and type(loadfile) == "function" then
            pcall(function() loadfile("Interface/AddOns/PersonalResourceReskin/CustomRogueComboBarOptions.lua")() end)
        end
        if _G.CustomRogueComboBarOptions then
            PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomRogueComboBar", _G.CustomRogueComboBarOptions)
        end

        -- Load and register Druid Combo Bar Options ONLY if player is a Druid
        local _, class = UnitClass("player")
        if class == "DRUID" then
            if not _G.CustomDruidComboBarOptions and type(loadfile) == "function" then
                pcall(function() loadfile("Interface/AddOns/PersonalResourceReskin/CustomDruidComboBarOptions.lua")() end)
            end
            if _G.CustomDruidComboBarOptions then
                PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomDruidComboBar", _G.CustomDruidComboBarOptions)
            end
        end

        -- Add Custom Mage Arcane Orb Bar options if available
        if not _G.CustomMageArcaneOrbOptions and type(loadfile) == "function" then
            local ok, err = pcall(function() loadfile("Interface/AddOns/PersonalResourceReskin/CustomMageArcaneOrbOptions.lua")() end)
        end
        if _G.CustomMageArcaneOrbOptions then
            pcall(function() loadfile("Interface/AddOns/PersonalResourceReskin/CustomMageArcaneOrbOptions.lua")() end)
        end
    end
end

-- Hook spacing to key events and updates (should only be set up once)
do
    local spacingFrame = CreateFrame("Frame")
    spacingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    spacingFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    spacingFrame:RegisterEvent("UNIT_POWER_UPDATE")
    spacingFrame:RegisterEvent("RUNE_POWER_UPDATE")
    spacingFrame:SetScript("OnEvent", function(_, event)
        ApplyLegacyComboSpacing()
    end)
end

-- Global hook: block SetClampRectInsets for any frame
local function BlockClampRectInsets(frame)
    if frame and frame.SetClampRectInsets and not frame.__PRR_ClampBlocked then
        frame.__PRR_ClampBlocked = true
        hooksecurefunc(frame, "SetClampRectInsets", function()
            -- Blocked: Do nothing to avoid taint
        end)
    end
end
-- Initial frames
BlockClampRectInsets(PlayerFrame)
local prd = _G.PersonalResourceDisplayFrame
BlockClampRectInsets(prd)
if prd then
    BlockClampRectInsets(prd.PowerBar)
    BlockClampRectInsets(prd.AlternatePowerBar)
end
-- Dynamically hook new frames on Edit Mode or UI reload



local f = CreateFrame("Frame")
f:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    BlockClampRectInsets(_G.PersonalResourceDisplayFrame)
    if _G.PersonalResourceDisplayFrame then
        BlockClampRectInsets(_G.PersonalResourceDisplayFrame.PowerBar)
        BlockClampRectInsets(_G.PersonalResourceDisplayFrame.AlternatePowerBar)
    end
end)

-- Ticker to update legacy combo/rune bar spacing and scaling every 0.1 seconds
if not _G.PRR_LegacyComboTicker then
    _G.PRR_LegacyComboTicker = C_Timer.NewTicker(0.1, function()
        if type(ApplyLegacyComboSpacing) == "function" then
            ApplyLegacyComboSpacing()
        end
    end)
end
