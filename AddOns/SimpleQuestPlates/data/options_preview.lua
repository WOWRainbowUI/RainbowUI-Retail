--=====================================================================================
-- RGX | Simple Quest Plates! - options_preview.lua

-- Author: DonnieDice
-- Description: Preview nameplate for options panel
--=====================================================================================

local addonName, SQP = ...
local CreateFrame = CreateFrame
local floor = math.floor
local pcall = pcall
local tonumber = tonumber

-- Create preview nameplate section
function SQP:CreatePreviewSection(parent)
    -- Create preview container
    local previewFrame = CreateFrame("Frame", nil, parent)
    previewFrame:SetSize(parent:GetWidth() - 28, 82)
    previewFrame:SetPoint("CENTER", parent, "CENTER", 0, 0)

    -- Preview title (centered at top)
    local previewTitle = previewFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    previewTitle:SetPoint("TOP", previewFrame, "TOP", 0, -5)
    previewTitle:SetText("|cff58be81Live Preview|r")

    -- Type-switcher buttons (compact row)
    local killTypeBtn = self:CreateStyledButton(previewFrame, "Kill", 40, 16)
    local lootTypeBtn = self:CreateStyledButton(previewFrame, "Loot", 40, 16)
    local pctTypeBtn  = self:CreateStyledButton(previewFrame, "%",   18, 16)
    killTypeBtn:SetPoint("BOTTOMLEFT", previewFrame, "BOTTOM", -51, 3)
    lootTypeBtn:SetPoint("LEFT", killTypeBtn, "RIGHT", 4, 0)
    pctTypeBtn:SetPoint("LEFT",  lootTypeBtn, "RIGHT", 4, 0)

    -- Create fake nameplate (geometry is synced to a live nameplate when available)
    local nameplate = CreateFrame("Frame", nil, previewFrame)
    nameplate:SetSize(112, 44)
    nameplate:SetPoint("CENTER", previewFrame, "CENTER", 0, -5)

    -- Nameplate background
    local nameplateBackground = nameplate:CreateTexture(nil, "BACKGROUND")
    nameplateBackground:SetAllPoints()
    nameplateBackground:SetColorTexture(0.12, 0.12, 0.12, 0.45)

    local nameplateBorder = CreateFrame("Frame", nil, nameplate, "BackdropTemplate")
    nameplateBorder:SetAllPoints()
    nameplateBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    nameplateBorder:SetBackdropBorderColor(0.18, 0.18, 0.18, 0.9)

    -- Health bar
    local healthBar = CreateFrame("StatusBar", nil, nameplate)
    healthBar:SetSize(100, 12)
    healthBar:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBar:SetStatusBarColor(0.95, 0.16, 0.16)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetValue(75)

    -- Health bar background
    local healthBackground = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBackground:SetAllPoints()
    healthBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    -- Name text
    local nameText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("BOTTOM", healthBar, "TOP", 0, 1)
    nameText:SetText("Murloc Warrior")
    nameText:SetTextColor(1, 0.82, 0)

    -- Level text
    local levelText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    levelText:SetText("Level 15")
    levelText:SetTextColor(0.8, 0.8, 0.8)

    -- Create preview quest icon
    local questFrame = CreateFrame("Frame", nil, nameplate)
    questFrame:SetAllPoints()

    -- Quest icon
    local icon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    icon:SetSize(28, 22)
    icon:SetTexture('Interface/QuestFrame/AutoQuest-Parts')
    icon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)

    -- Quest count text
    local iconText = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if iconText.SetDrawLayer then
        iconText:SetDrawLayer("OVERLAY", 2)
    end
    iconText:SetPoint("CENTER", icon, 0.8, 0)
    iconText:SetShadowOffset(1, -1)
    iconText:SetTextColor(1, 0.82, 0)

    -- Outline text (separate layer for custom outline color)
    local iconTextOutline = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if iconTextOutline.SetDrawLayer then
        iconTextOutline:SetDrawLayer("OVERLAY", 1)
    end
    iconTextOutline:SetPoint("CENTER", icon, 0.8, 0)
    iconTextOutline:SetShadowOffset(0, 0)
    iconTextOutline:SetTextColor(0, 0, 0, 1)

    -- Percent icon (used for percentage quests)
    local percentIcon = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if percentIcon.SetDrawLayer then
        percentIcon:SetDrawLayer("OVERLAY", 2)
    end
    percentIcon:SetPoint("CENTER", icon, 0, 0)
    percentIcon:SetText("%")
    percentIcon:SetTextColor(0.2, 1, 1)
    percentIcon:Hide()

    local percentIconOutline = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if percentIconOutline.SetDrawLayer then
        percentIconOutline:SetDrawLayer("OVERLAY", 1)
    end
    percentIconOutline:SetPoint("CENTER", icon, 0, 0)
    percentIconOutline:SetText("%")
    percentIconOutline:SetTextColor(0, 0, 0, 1)
    percentIconOutline:Hide()

    -- Apply font settings first, then set text
    SQP:UpdateQuestFont(iconText, iconTextOutline, percentIcon, percentIconOutline)
    iconText:SetText("3")
    iconTextOutline:SetText("3")

    -- Default to showing kill quest type
    iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))

    -- Loot icon
    local lootIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    if lootIcon.SetAtlas then
        lootIcon:SetAtlas('Banker')
    else
        lootIcon:SetTexture('Interface/Icons/INV_Misc_Bag_10')
        lootIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    lootIcon:SetSize(16, 16)
    lootIcon:SetPoint('TOPLEFT', icon, 'BOTTOMRIGHT', -12, 12)
    lootIcon:Hide()

    -- Kill icon (hostile cursor knife/sword)
    local killIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    killIcon:SetTexture('Interface/Cursor/Attack')
    if not killIcon:GetTexture() then
        killIcon:SetTexture('Interface/Icons/INV_Sword_04')
        killIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    killIcon:SetSize(16, 16)
    killIcon:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
    killIcon:Hide()

    -- Use animation groups (matching live nameplate behavior) for stable preview pulses.
    local function CreateMainPulse(region)
        local pulse = region:CreateAnimationGroup()
        pulse:SetLooping("REPEAT")
        local fadeOut = pulse:CreateAnimation("Alpha")
        fadeOut:SetOrder(1)
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.15)
        fadeOut:SetDuration(0.5)
        fadeOut:SetSmoothing("IN_OUT")
        local fadeIn = pulse:CreateAnimation("Alpha")
        fadeIn:SetOrder(2)
        fadeIn:SetFromAlpha(0.15)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.5)
        fadeIn:SetSmoothing("IN_OUT")
        pulse._fadeOut = fadeOut
        pulse._fadeIn = fadeIn
        return pulse
    end

    local function CreatePulse(region)
        local pulse = region:CreateAnimationGroup()
        pulse:SetLooping("REPEAT")
        local fadeOut = pulse:CreateAnimation("Alpha")
        fadeOut:SetOrder(1)
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.6)
        fadeOut:SetDuration(0.6)
        fadeOut:SetSmoothing("IN_OUT")
        local fadeIn = pulse:CreateAnimation("Alpha")
        fadeIn:SetOrder(2)
        fadeIn:SetFromAlpha(0.6)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.6)
        fadeIn:SetSmoothing("IN_OUT")
        pulse._fadeOut = fadeOut
        pulse._fadeIn = fadeIn
        return pulse
    end

    -- Store references
    previewFrame.nameplate = nameplate
    previewFrame.nameplateBorder = nameplateBorder
    previewFrame.questFrame = questFrame
    previewFrame.icon = icon
    previewFrame.iconText = iconText
    previewFrame.iconTextOutline = iconTextOutline
    previewFrame.percentIcon = percentIcon
    previewFrame.percentIconOutline = percentIconOutline
    previewFrame.lootIcon = lootIcon
    previewFrame.killIcon = killIcon
    previewFrame.questType = "kill"
    previewFrame.iconPulse = CreateMainPulse(icon)
    previewFrame.percentPulse = CreatePulse(percentIcon)
    previewFrame.percentOutlinePulse = CreatePulse(percentIconOutline)
    previewFrame.killIconPulse = CreatePulse(killIcon)
    previewFrame.lootIconPulse = CreatePulse(lootIcon)

    -- Mirror a live nameplate's geometry so preview offsets match in-world placement.
    local function Clamp(value, minValue, maxValue)
        if value < minValue then return minValue end
        if value > maxValue then return maxValue end
        return value
    end

    -- Safely read frame dimensions that may be protected/tainted values.
    local function ToPlainNumber(value)
        if value == nil then return nil end
        local okString, stringValue = pcall(tostring, value)
        if not okString or not stringValue then
            return nil
        end
        return tonumber(stringValue)
    end

    local function GetFrameDimension(frame, methodName, fallback)
        if not frame then return fallback end
        local getter = frame[methodName]
        if type(getter) ~= "function" then return fallback end

        local okCall, rawValue = pcall(getter, frame)
        if not okCall then return fallback end

        local numericValue = ToPlainNumber(rawValue)
        if not numericValue then
            return fallback
        end

        return numericValue
    end

    local function GetReferenceNameplate()
        if SQP.ActiveNameplates then
            for plate in pairs(SQP.ActiveNameplates) do
                local w = GetFrameDimension(plate, "GetWidth", nil)
                local h = GetFrameDimension(plate, "GetHeight", nil)
                if w and h then
                    return plate
                end
            end
        end
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local targetPlate = C_NamePlate.GetNamePlateForUnit("target")
            if targetPlate and targetPlate.GetWidth and targetPlate.GetHeight then
                return targetPlate
            end
        end
        return nil
    end

    local function GetReferenceHealthBar(plate)
        if not plate or not plate.UnitFrame then return nil end
        return plate.UnitFrame.healthBar
            or plate.UnitFrame.HealthBar
            or plate.UnitFrame.healthbar
            or plate.UnitFrame.health
    end

    local function GetReferenceNameText(plate)
        if not plate or not plate.UnitFrame then return nil end
        return plate.UnitFrame.name
            or plate.UnitFrame.Name
            or plate.UnitFrame.nameText
    end

    -- Stop preview pulses when panel hides
    previewFrame:SetScript("OnHide", function(self)
        if self.iconPulse and self.iconPulse:IsPlaying() then self.iconPulse:Stop() end
        if self.percentPulse and self.percentPulse:IsPlaying() then self.percentPulse:Stop() end
        if self.percentOutlinePulse and self.percentOutlinePulse:IsPlaying() then self.percentOutlinePulse:Stop() end
        if self.killIconPulse and self.killIconPulse:IsPlaying() then self.killIconPulse:Stop() end
        if self.lootIconPulse and self.lootIconPulse:IsPlaying() then self.lootIconPulse:Stop() end
        icon:SetAlpha(1)
        percentIcon:SetAlpha(1)
        percentIconOutline:SetAlpha(1)
        killIcon:SetAlpha(1)
        lootIcon:SetAlpha(1)
    end)

    -- Update function
    function previewFrame:UpdatePreview()
        -- Sync preview nameplate + health bar size to a real nameplate when possible.
        local plateWidth, plateHeight = 112, 44
        local healthWidth, healthHeight = 100, 12
        local refPlate = GetReferenceNameplate()
        if refPlate then
            local refPlateWidth = GetFrameDimension(refPlate, "GetWidth", plateWidth)
            local refPlateHeight = GetFrameDimension(refPlate, "GetHeight", plateHeight)
            plateWidth = Clamp(floor(refPlateWidth + 0.5), 80, 260)
            plateHeight = Clamp(floor(refPlateHeight + 0.5), 24, 80)

            local refHealth = GetReferenceHealthBar(refPlate)
            local refHealthWidth = GetFrameDimension(refHealth, "GetWidth", nil)
            local refHealthHeight = GetFrameDimension(refHealth, "GetHeight", nil)
            if refHealthWidth and refHealthHeight then
                healthWidth = Clamp(floor(refHealthWidth + 0.5), 70, 240)
                healthHeight = Clamp(floor(refHealthHeight + 0.5), 6, 24)
            else
                healthWidth = Clamp(plateWidth - 12, 70, 240)
            end

            local statusTexture = refHealth.GetStatusBarTexture and refHealth:GetStatusBarTexture()
            if statusTexture and statusTexture.GetTexture then
                local texturePath = statusTexture:GetTexture()
                if texturePath then
                    healthBar:SetStatusBarTexture(texturePath)
                end
            end
            if refHealth.GetStatusBarColor then
                local r, g, b, a = refHealth:GetStatusBarColor()
                if r and g and b then
                    healthBar:SetStatusBarColor(r, g, b, a or 1)
                end
            end

            local refName = GetReferenceNameText(refPlate)
            if refName and refName.GetFont and nameText.SetFont then
                local font, size, flags = refName:GetFont()
                if font and size then
                    nameText:SetFont(font, size, flags)
                end
            end
            if refName and refName.GetTextColor and nameText.SetTextColor then
                local nr, ng, nb, na = refName:GetTextColor()
                if nr and ng and nb then
                    nameText:SetTextColor(nr, ng, nb, na or 1)
                end
            end
        end

        nameplate:SetSize(plateWidth, plateHeight)
        healthBar:SetSize(healthWidth, healthHeight)

        -- Update icon position
        icon:ClearAllPoints()
        icon:SetPoint(
            SQPSettings.anchor or 'RIGHT',
            nameplate,
            SQPSettings.relativeTo or 'LEFT',
            SQPSettings.offsetX or 0,
            SQPSettings.offsetY or 0
        )

        if self.killIcon then
            self.killIcon:ClearAllPoints()
            self.killIcon:SetPoint(
                'TOPRIGHT',
                icon,
                'BOTTOMLEFT',
                SQPSettings.killIconOffsetX or 2,
                SQPSettings.killIconOffsetY or 15
            )
            self.killIcon:SetSize(SQPSettings.killIconSize or 14, SQPSettings.killIconSize or 14)
        end
        if self.lootIcon then
            self.lootIcon:ClearAllPoints()
            self.lootIcon:SetPoint(
                'TOPLEFT',
                icon,
                'BOTTOMRIGHT',
                SQPSettings.lootIconOffsetX or -38,
                SQPSettings.lootIconOffsetY or 16
            )
            self.lootIcon:SetSize(SQPSettings.lootIconSize or 14, SQPSettings.lootIconSize or 14)
        end

        -- Update scale
        questFrame:SetScale(SQPSettings.scale or 1)

        -- Update font with current quest type
        local previewTypeKey = self.questType or "kill"
        SQP:UpdateQuestFont(iconText, iconTextOutline, percentIcon, percentIconOutline, previewTypeKey)

        -- Main icon tinting removed (redundant with color controls)
        icon:SetVertexColor(1, 1, 1, 1)

        local killTintEnabled = SQPSettings.killTintIcon and SQPSettings.killTintIconColor
        local lootTintEnabled = SQPSettings.lootTintIcon and SQPSettings.lootTintIconColor
        local percentTintEnabled = SQPSettings.percentTintIcon and SQPSettings.percentTintIconColor
        if self.killIcon then
            if killTintEnabled then
                local r, g, b, a = unpack(SQPSettings.killTintIconColor)
                self.killIcon:SetVertexColor(r, g, b, a or 1)
            else
                self.killIcon:SetVertexColor(1, 1, 1, 1)
            end
        end
        if self.lootIcon then
            if lootTintEnabled then
                local r, g, b, a = unpack(SQPSettings.lootTintIconColor)
                self.lootIcon:SetVertexColor(r, g, b, a or 1)
            else
                self.lootIcon:SetVertexColor(1, 1, 1, 1)
            end
        end

        local function SetPreviewPercentColor(fs)
            if not fs then return end
            if percentTintEnabled then
                local r, g, b, a = unpack(SQPSettings.percentTintIconColor)
                fs:SetTextColor(r, g, b, a or 1)
            else
                fs:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
            end
        end

        local function IsPreviewIconStyleEnabled(typeKey)
            local value = SQPSettings[typeKey .. "ShowIconBackground"]
            if value == nil then
                value = SQPSettings.showIconBackground
            end
            return value ~= false
        end

        -- Update quest type display
        if self.questType == "loot" then
            local lootIconMode = IsPreviewIconStyleEnabled("loot")
            if lootIconMode then icon:Show() else icon:Hide() end
            if self.percentIcon then self.percentIcon:Hide() end
            if self.percentIconOutline then self.percentIconOutline:Hide() end
            if self.lootIcon then
                if SQPSettings.showLootIcon ~= false then self.lootIcon:Show() else self.lootIcon:Hide() end
            end
            if self.killIcon then self.killIcon:Hide() end
            if lootIconMode then
                self.iconText:SetText("2")
                if self.iconTextOutline then self.iconTextOutline:SetText("2") end
            else
                self.iconText:SetText("2/5")
                if self.iconTextOutline then self.iconTextOutline:SetText("2/5") end
            end
        elseif self.questType == "kill" then
            local killIconMode = IsPreviewIconStyleEnabled("kill")
            if killIconMode then icon:Show() else icon:Hide() end
            if self.percentIcon then self.percentIcon:Hide() end
            if self.percentIconOutline then self.percentIconOutline:Hide() end
            if self.lootIcon then self.lootIcon:Hide() end
            if self.killIcon then
                if SQPSettings.showKillIcon ~= false then self.killIcon:Show() else self.killIcon:Hide() end
            end
            if killIconMode then
                self.iconText:SetText("5")
                if self.iconTextOutline then self.iconTextOutline:SetText("5") end
            else
                self.iconText:SetText("5/8")
                if self.iconTextOutline then self.iconTextOutline:SetText("5/8") end
            end
        else
            -- Percent quest
            local percentIconMode = IsPreviewIconStyleEnabled("percent")
            if self.lootIcon then self.lootIcon:Hide() end
            if self.killIcon  then self.killIcon:Hide()  end

            if SQPSettings.showPercentIcon ~= false then
                local pOffX = SQPSettings.percentIconOffsetX or 18
                local pOffY = SQPSettings.percentIconOffsetY or 0
                local pOW   = SQP:GetOutlineInfo("percent")
                if percentIconMode then
                    -- Icon mode: jellybean + number + "%" at offset
                    icon:Show()
                    self.iconText:SetText("75")
                    if self.iconTextOutline then self.iconTextOutline:SetText("75") end
                    if self.percentIcon then
                        self.percentIcon:ClearAllPoints()
                        self.percentIcon:SetPoint('CENTER', icon, pOffX, pOffY)
                        self.percentIcon:SetText("%")
                        SetPreviewPercentColor(self.percentIcon)
                        self.percentIcon:Show()
                    end
                    if self.percentIconOutline then
                        self.percentIconOutline:ClearAllPoints()
                        self.percentIconOutline:SetPoint('CENTER', icon, pOffX, pOffY)
                        self.percentIconOutline:SetText("%")
                        if pOW > 0 then self.percentIconOutline:Show() else self.percentIconOutline:Hide() end
                    end
                else
                    -- Text mode: floating "75%"
                    icon:Hide()
                    self.iconText:SetText("")
                    if self.iconTextOutline then self.iconTextOutline:SetText("") end
                    if self.percentIcon then
                        self.percentIcon:ClearAllPoints()
                        self.percentIcon:SetPoint('CENTER', icon, pOffX, pOffY)
                        self.percentIcon:SetText("75%")
                        SetPreviewPercentColor(self.percentIcon)
                        self.percentIcon:Show()
                    end
                    if self.percentIconOutline then
                        self.percentIconOutline:ClearAllPoints()
                        self.percentIconOutline:SetPoint('CENTER', icon, pOffX, pOffY)
                        self.percentIconOutline:SetText("75%")
                        if pOW > 0 then self.percentIconOutline:Show() else self.percentIconOutline:Hide() end
                    end
                end
            else
                -- showPercentIcon disabled
                if self.percentIcon then self.percentIcon:Hide() end
                if self.percentIconOutline then self.percentIconOutline:Hide() end
                if percentIconMode then
                    icon:Show()
                    self.iconText:SetText("75")
                    if self.iconTextOutline then self.iconTextOutline:SetText("75") end
                else
                    icon:Hide()
                    self.iconText:SetText("")
                    if self.iconTextOutline then self.iconTextOutline:SetText("") end
                end
            end
        end

        -- Manage main/icon text pulse animation with global override support.
        local animateMain = SQP:IsAnimationEnabled(previewTypeKey, false)
        local mainIconShown = icon:IsShown()
        local percentTextShown = self.percentIcon and self.percentIcon:IsShown() and not mainIconShown

        if self.iconPulse then
            SQP:ApplyPulseDuration(self.iconPulse, SQP:GetAnimationDuration(previewTypeKey, true))
            if animateMain and mainIconShown then
                if not self.iconPulse:IsPlaying() then self.iconPulse:Play() end
            else
                if self.iconPulse:IsPlaying() then self.iconPulse:Stop() end
                icon:SetAlpha(1)
            end
        end

        if self.percentPulse then
            SQP:ApplyPulseDuration(self.percentPulse, SQP:GetAnimationDuration("percent", false))
            if animateMain and percentTextShown then
                if not self.percentPulse:IsPlaying() then self.percentPulse:Play() end
            else
                if self.percentPulse:IsPlaying() then self.percentPulse:Stop() end
                percentIcon:SetAlpha(1)
            end
        end

        if self.percentOutlinePulse then
            SQP:ApplyPulseDuration(self.percentOutlinePulse, SQP:GetAnimationDuration("percent", false))
            if animateMain and percentTextShown and self.percentIconOutline and self.percentIconOutline:IsShown() then
                if not self.percentOutlinePulse:IsPlaying() then self.percentOutlinePulse:Play() end
            else
                if self.percentOutlinePulse:IsPlaying() then self.percentOutlinePulse:Stop() end
                percentIconOutline:SetAlpha(1)
            end
        end

        -- Manage task icon pulse animation (kill/loot mini icons) with global override.
        if self.killIconPulse then
            SQP:ApplyPulseDuration(self.killIconPulse, SQP:GetAnimationDuration("kill", false))
            if SQP:IsAnimationEnabled("kill", true) and self.killIcon and self.killIcon:IsShown() then
                if not self.killIconPulse:IsPlaying() then self.killIconPulse:Play() end
            else
                if self.killIconPulse:IsPlaying() then self.killIconPulse:Stop() end
                killIcon:SetAlpha(1)
            end
        end
        if self.lootIconPulse then
            SQP:ApplyPulseDuration(self.lootIconPulse, SQP:GetAnimationDuration("loot", false))
            if SQP:IsAnimationEnabled("loot", true) and self.lootIcon and self.lootIcon:IsShown() then
                if not self.lootIconPulse:IsPlaying() then self.lootIconPulse:Play() end
            else
                if self.lootIconPulse:IsPlaying() then self.lootIconPulse:Stop() end
                lootIcon:SetAlpha(1)
            end
        end
    end

    -- Restart animation when the panel becomes visible again
    previewFrame:SetScript("OnShow", function(self)
        self:UpdatePreview()
    end)

    -- Type-switcher button alpha updater
    local function UpdateTypeButtons(activeType)
        killTypeBtn:SetAlpha(activeType == "kill"    and 1 or 0.45)
        lootTypeBtn:SetAlpha(activeType == "loot"    and 1 or 0.45)
        pctTypeBtn:SetAlpha( activeType == "percent" and 1 or 0.45)
    end
    UpdateTypeButtons("kill")

    -- External helpers to switch preview mode from tab clicks and option controls
    previewFrame.activateKillMode = function()
        iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
        lootIcon:Hide()
        killIcon:Hide()
        previewFrame.questType = "kill"
        UpdateTypeButtons("kill")
        previewFrame:UpdatePreview()
    end

    previewFrame.activateLootMode = function()
        iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
        lootIcon:Show()
        killIcon:Hide()
        previewFrame.questType = "loot"
        UpdateTypeButtons("loot")
        previewFrame:UpdatePreview()
    end

    previewFrame.activatePercentMode = function()
        iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
        lootIcon:Hide()
        killIcon:Hide()
        previewFrame.questType = "percent"
        UpdateTypeButtons("percent")
        previewFrame:UpdatePreview()
    end

    -- Set button scripts (after activate functions are defined)
    killTypeBtn:SetScript("OnClick", function() previewFrame.activateKillMode() end)
    lootTypeBtn:SetScript("OnClick", function() previewFrame.activateLootMode() end)
    pctTypeBtn:SetScript("OnClick",  function() previewFrame.activatePercentMode() end)

    -- Initial update
    previewFrame:UpdatePreview()

    return previewFrame
end

-- Hook into refresh function
local oldRefresh = SQP.RefreshAllNameplates
function SQP:RefreshAllNameplates()
    -- Call original function
    if oldRefresh then
        oldRefresh(self)
    end

    -- Update preview if it exists
    if self.previewFrame then
        self.previewFrame:UpdatePreview()

        -- Re-apply current quest type colors
        if self.previewFrame.iconText then
            local qt = self.previewFrame.questType
            if qt == "kill" then
                self.previewFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
            elseif qt == "loot" then
                self.previewFrame.iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
            elseif qt == "percent" then
                self.previewFrame.iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
            end
        end
    end
end
