--=====================================================================================
-- RGX | Simple Quest Plates! - options_preview.lua

-- Author: DonnieDice
-- Description: Preview nameplate for options panel
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global
local CreateFrame = CreateFrame
local pcall = pcall

-- Create preview nameplate section
function SQP:CreatePreviewSection(parent)
    -- The banner hosts either the client's own preview nameplate
    -- (NamePlatePreviewTemplate, the same mechanism Blizzard's nameplate
    -- settings use: a real driver-registered plate, verified in the 1.60.1
    -- Forever UI source) or, when that template is unavailable, a mock
    -- drawn with the client's verified Classic nameplate constants.
    -- Reserve a 30px strip at the bottom of the banner for the type buttons:
    -- the preview frame must clear it by that amount, not sit inside it.
    local BUTTON_STRIP = 30
    local previewFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    previewFrame:SetPoint("TOPLEFT",  parent, "TOPLEFT",  14, -3)
    previewFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -14, -3)
    previewFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 14, BUTTON_STRIP)
    previewFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -14, BUTTON_STRIP)
    -- The preview is a copy of the Blizzard nameplate, not a dialog box.
    -- Never reparent the actual nameplate: it is owned by the nameplate driver.
    previewFrame:SetBackdrop(nil)

    -- Type-switcher buttons (compact row, centered)
    local killTypeBtn = self:CreateStyledButton(previewFrame, "Kill", 46, 16)
    local lootTypeBtn = self:CreateStyledButton(previewFrame, "Loot", 46, 16)
    local pctTypeBtn  = self:CreateStyledButton(previewFrame, "%",   28, 16)
    -- Mirror the framework tab row's gap below the divider, using its actual
    -- divider region rather than this preview's inset bottom edge.
    local divider = parent.divider
    local dividerGap = parent.dividerGap or 10
    if divider then
        killTypeBtn:SetPoint("BOTTOMLEFT", divider, "TOP", -62, dividerGap)
    else
        killTypeBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOM", -62, dividerGap + 2)
    end
    lootTypeBtn:SetPoint("LEFT", killTypeBtn, "RIGHT", 4, 0)
    pctTypeBtn:SetPoint("LEFT",  lootTypeBtn, "RIGHT", 4, 0)

    -- Mode caption: small "Preview — <style>" label at the banner's
    -- top-left (the position the client's own settings preview uses).
    local modeCaption = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modeCaption:SetPoint("TOPLEFT", previewFrame, "TOPLEFT", 10, -6)
    previewFrame.modeCaption = modeCaption

    -- Shared overlay references: assigned by the mock construction below or
    -- by EnsureRealOverlay when the client preview template is used.
    local nameplate, healthBar, anchorAnalog, nameText
    local questFrame, icon, iconText, iconTextOutline
    local percentIcon, percentIconOutline, killIcon, lootIcon, questChip

    local useReal = false
    local realPlate
    if type(NamePlatePreviewMixin) == "table" and NamePlateDriverFrame ~= nil then
        -- NamePlatePreviewTemplate is a wrapper Frame; the driver-registered
        -- nameplate is its NamePlate child Button (whose OnShow registers the
        -- "preview" token, per the client's own settings preview). Instantiate
        -- the wrapper and adopt the child as the preview plate.
        local okReal, wrapper = pcall(CreateFrame, "Frame", nil, previewFrame, "NamePlatePreviewTemplate")
        if okReal and wrapper and wrapper.NamePlate then
            realPlate = wrapper.NamePlate
            useReal = true
            wrapper:ClearAllPoints()
            -- Fit the wrapper inside the preview body, above the reserved
            -- button strip. Its centered NamePlate rises with the shorter
            -- wrapper; this changes real-client placement, not only the mock.
            wrapper:SetSize(380, 48)
            wrapper:SetPoint("TOP", previewFrame, "TOP", 0, 0)
            -- The template ships its own options-chrome border and PREVIEW
            -- label (atlas options_frame_child); the quest preview must show
            -- only the nameplate, so drop that extra frame.
            if wrapper.Border then wrapper.Border:Hide() end
            if wrapper.Preview then wrapper.Preview:Hide() end
            wrapper:Show()
        end
    end
    previewFrame.plate = realPlate

    local function HidePreviewDecorations()
        local unit = realPlate and realPlate.UnitFrame
        if not unit then return end
        -- Forever 1.60.1 NamePlates.xml places these Blizzard decorations
        -- around the health bar (classification/raid-target to the left,
        -- aura buff/debuff lists over the plate). Suppress only this
        -- preview's copies; live nameplates keep their classification,
        -- raid-target, and aura icons.
        for _, key in ipairs({ "ClassificationFrame", "RaidTargetFrame", "AurasFrame" }) do
            local decoration = unit[key]
            if decoration then
                if not decoration._sqpPreviewHidden then
                    decoration._sqpPreviewHidden = true
                    decoration:HookScript("OnShow", function(self) self:Hide() end)
                end
                decoration:Hide()
            end
        end
    end
    if realPlate then realPlate:HookScript("OnShow", HidePreviewDecorations) end
    HidePreviewDecorations()

    -- Build the mock overlay only when the client's preview template is not
    -- available (e.g. the settings definitions are not loaded yet). Mock
    -- dimensions come from the verified Classic nameplate constants: plate
    -- width 152, health bar 104x10, name centered above the bar.
    if not useReal then
    nameplate = CreateFrame("Frame", nil, previewFrame)
    nameplate:SetSize(152, 44)
    -- Raised within its frame: the mock plate clears the reserved button
    -- strip while staying inside the banner top edge.
    nameplate:SetPoint("CENTER", previewFrame, "CENTER", 0, 18)

    -- Nameplate background (Blizzard nameplate navy)
    local nameplateBackground = nameplate:CreateTexture(nil, "BACKGROUND")
    nameplateBackground:SetAllPoints()
    nameplateBackground:Hide()

    local nameplateBorder = CreateFrame("Frame", nil, nameplate, "BackdropTemplate")
    nameplateBorder:SetAllPoints()
    nameplateBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    nameplateBorder:Hide()

    -- Health bar
    healthBar = CreateFrame("StatusBar", nil, nameplate)
    healthBar:SetSize(104, 10)
    healthBar:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT", 10, -10)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBar:SetStatusBarColor(0.23, 0.27, 0.68)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetValue(85)

    -- Health bar border (thin black edge around the bar)
    local healthBarBorder = CreateFrame("Frame", nil, healthBar, "BackdropTemplate")
    healthBarBorder:SetAllPoints()
    healthBarBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    healthBarBorder:SetBackdropBorderColor(0, 0, 0, 0.9)

    local healthBackground = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBackground:SetAllPoints()
    healthBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    -- Anchor analog: mirrors the real frame the live quest icon anchors to
    -- (Blizzard's HealthBarsContainer when present, the plate otherwise).
    -- The live code anchors to GetPlateAnchorTarget's result in BOTH unified
    -- and legacy modes, so the preview icon must anchor to this analog —
    -- never mode-switched between the mock bar and the mock plate.
    anchorAnalog = CreateFrame("Frame", nil, nameplate)
    anchorAnalog:SetAllPoints(healthBar)

    -- Blizzard target display: white centered name and a blue bar.
    nameText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("BOTTOM", healthBar, "TOP", 0, 1)
    nameText:SetText("Target Name")
    nameText:SetTextColor(1, 1, 1)

    -- Level text as a native level chip (small dark box right of the bar)
    local levelText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelText:SetPoint("LEFT", healthBar, "RIGHT", 9, 0)
    levelText:SetText("14")
    levelText:SetTextColor(1, 0.82, 0)

    local levelChipBg = nameplate:CreateTexture(nil, "ARTWORK", nil, -1)
    levelChipBg:SetColorTexture(0, 0, 0, 0.85)
    levelChipBg:SetPoint("TOPLEFT", levelText, "TOPLEFT", -3, 2)
    levelChipBg:SetPoint("BOTTOMRIGHT", levelText, "BOTTOMRIGHT", 3, -2)

    -- Static buff/debuff art is part of this mock, never real aura plumbing.
    -- Keep it in the same geometry calculation as the SQP quest marker.
    local auraIcons = {}
    local buffTextures = {
        "Interface\\Icons\\Spell_Fire_Fire",
        "Interface\\Icons\\Spell_Nature_Rejuvenation",
        "Interface\\Icons\\Ability_Warrior_BattleShout",
        "Interface\\Icons\\Spell_Holy_Renew",
        "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    }
    for i, texture in ipairs(buffTextures) do
        local aura = nameplate:CreateTexture(nil, "OVERLAY")
        aura:SetSize(11, 11)
        aura:SetTexture(texture)
        aura:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        aura:SetPoint("BOTTOM", nameText, "TOP", (i - 3) * 12, 1)
        auraIcons[#auraIcons + 1] = aura
    end
    -- Create preview quest icon
    questFrame = CreateFrame("Frame", nil, nameplate)
    questFrame:SetAllPoints()
    questFrame.isPreview = true

    -- Quest icon
    icon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    icon:SetSize(28, 22)
    icon:SetTexture('Interface\\QuestFrame\\AutoQuest-Parts')
    icon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)
    -- Preview toast stays silent until the Toast card's own controls select it;
    -- merely opening Animation or changing other options must not pop the mark.
    SQP:CreateQuestToast(questFrame, icon)
    SQP:SetQuestToastSelected(questFrame, false)

    -- Quest count text
    iconText = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if iconText.SetDrawLayer then
        iconText:SetDrawLayer("OVERLAY", 2)
    end
    iconText:SetPoint("CENTER", icon, 0.8, 0)
    iconText:SetShadowOffset(1, -1)
    iconText:SetTextColor(1, 0.82, 0)

    -- Outline text (separate layer for custom outline color)
    iconTextOutline = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if iconTextOutline.SetDrawLayer then
        iconTextOutline:SetDrawLayer("OVERLAY", 1)
    end
    iconTextOutline:SetPoint("CENTER", icon, 0.8, 0)
    iconTextOutline:SetShadowOffset(0, 0)
    iconTextOutline:SetTextColor(0, 0, 0, 1)

    -- Percent icon (used for percentage quests)
    percentIcon = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    if percentIcon.SetDrawLayer then
        percentIcon:SetDrawLayer("OVERLAY", 2)
    end
    percentIcon:SetPoint("CENTER", icon, 0, 0)
    percentIcon:SetText("%")
    percentIcon:SetTextColor(0.2, 1, 1)
    percentIcon:Hide()

    percentIconOutline = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
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
    lootIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    if lootIcon.SetAtlas then
        lootIcon:SetAtlas('Banker')
    else
        lootIcon:SetTexture('Interface\\Icons\\INV_Misc_Bag_10')
        lootIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    lootIcon:SetSize(16, 16)
    lootIcon:SetPoint('TOPLEFT', icon, 'BOTTOMRIGHT', -12, 12)
    lootIcon:Hide()

    -- Kill icon (hostile cursor knife/sword)
    killIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    killIcon:SetTexture('Interface\\Cursor\\Attack')
    if not killIcon:GetTexture() then
        killIcon:SetTexture('Interface\\Icons\\INV_Sword_04')
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

    -- Unified-mode count chip (level-style backdrop behind the number):
    -- same factory as live plates, including the client level-indicator
    -- atlas when available.
    questChip = SQP:CreateLevelChip(questFrame)
    -- Preview and live overlays share the same chip updater; the preview must
    -- never maintain its own sizing logic.
    questFrame.levelChip = questChip
    questFrame.iconText = iconText
    questFrame.iconTextOutline = iconTextOutline
    questFrame.icon = icon
    questFrame.killIcon = killIcon
    questFrame.lootIcon = lootIcon

    -- Store references
    previewFrame.nameplate = nameplate
    previewFrame.auraIcons = auraIcons
    previewFrame.nameplateBorder = nameplateBorder
    previewFrame.targetGlow = nil
    previewFrame.questGlow = nil
    previewFrame.questChip = questChip
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
    end -- mock construction

    -- Real-template mode: build the preview overlay through the exact live
    -- factory (SQP:CreateQuestPlate) on the driver-registered preview plate,
    -- so anchoring, scale, sizes and the chip are identical by construction.
    -- Rebuilt when the integration mode changes the expected parent.
    local function EnsureRealOverlay()
        if not useReal or not realPlate or not realPlate.UnitFrame then return end
        HidePreviewDecorations()
        local expectedParent = SQPSettings.unifiedNameplates == true and realPlate.UnitFrame or realPlate
        if questFrame and questFrame.GetParent and questFrame:GetParent() == expectedParent then
            return
        end
        if questFrame then
            questFrame:Hide()
            pcall(function() questFrame:SetParent(nil) end)
            SQP.QuestPlates[realPlate] = nil
        end
        SQP:CreateQuestPlate(realPlate)
        questFrame = SQP.QuestPlates[realPlate]
        if not questFrame then return end
        questFrame.isPreview = true
        SQP:SetQuestToastSelected(questFrame, false)
        icon = questFrame.icon
        iconText = questFrame.iconText
        iconTextOutline = questFrame.iconTextOutline
        percentIcon = questFrame.percentIcon
        percentIconOutline = questFrame.percentIconOutline
        killIcon = questFrame.killIcon
        lootIcon = questFrame.lootIcon
        questChip = questFrame.levelChip
        previewFrame.questChip = questChip
        previewFrame.questFrame = questFrame
        previewFrame.icon = icon
        previewFrame.iconText = iconText
        previewFrame.iconTextOutline = iconTextOutline
        previewFrame.percentIcon = percentIcon
        previewFrame.percentIconOutline = percentIconOutline
        previewFrame.lootIcon = lootIcon
        previewFrame.killIcon = killIcon
        previewFrame.questType = previewFrame.questType or "kill"
        previewFrame.iconPulse = questFrame.iconPulse
        previewFrame.percentPulse = questFrame.percentPulse
        previewFrame.percentOutlinePulse = questFrame.percentOutlinePulse
        previewFrame.killIconPulse = questFrame.killIconPulse
        previewFrame.lootIconPulse = questFrame.lootIconPulse
    end

    -- Mirror a live nameplate's geometry so preview offsets match in-world placement.
    -- Safely read frame dimensions that may be protected/tainted values.
    local function ToPlainNumber(value)
        local api = _G.RGXFramework and _G.RGXFramework.API
        if not api or type(api.CanAccessValue) ~= "function" then return nil end
        local ok, accessible = pcall(api.CanAccessValue, value)
        if not ok or accessible ~= true then return nil end
        if type(value) ~= "number" then return nil end
        if value ~= value or value == math.huge or value == -math.huge then return nil end
        return value
    end

    local function ReadPlainValues(frame, methodName)
        if not frame or type(frame[methodName]) ~= "function" then return nil end
        local values = { pcall(frame[methodName], frame) }
        if not values[1] then return nil end
        local api = _G.RGXFramework and _G.RGXFramework.API
        if not api or type(api.CanAccessValue) ~= "function" then return nil end
        for i = 2, #values do
            local ok, accessible = pcall(api.CanAccessValue, values[i])
            if not ok or accessible ~= true then return nil end
        end
        return unpack(values, 2)
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
        if (methodName == "GetWidth" or methodName == "GetHeight") and numericValue <= 0 then
            return fallback
        end

        return numericValue
    end

    local function GetReferenceNameplate()
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local targetPlate = nil -- options preview must not require a target
            if targetPlate and targetPlate.GetWidth and targetPlate.GetHeight then
                return targetPlate
            end
        end
        if SQP.ActiveNameplates then
            for plate in pairs(SQP.ActiveNameplates) do
                local w = GetFrameDimension(plate, "GetWidth", nil)
                local h = GetFrameDimension(plate, "GetHeight", nil)
                if w and h then
                    return plate
                end
            end
        end
        return nil
    end

    local function GetReferenceHealthBar(plate)
        if not plate or not plate.UnitFrame then return nil end
        if plate.UnitFrame.IsForbidden and plate.UnitFrame:IsForbidden() then return nil end
        return (plate.UnitFrame.HealthBarsContainer and plate.UnitFrame.HealthBarsContainer.healthBar)
            or plate.UnitFrame.healthBar
            or plate.UnitFrame.HealthBar
            or plate.UnitFrame.healthbar
            or plate.UnitFrame.health
    end

    local function GetReferenceNameText(plate)
        if not plate or not plate.UnitFrame then return nil end
        if plate.UnitFrame.IsForbidden and plate.UnitFrame:IsForbidden() then return nil end
        return plate.UnitFrame.name
            or plate.UnitFrame.Name
            or plate.UnitFrame.nameText
    end

    -- Stop preview pulses when panel hides
    previewFrame:SetScript("OnHide", function(self)
        local qf = self.questFrame or questFrame
        if qf then
            SQP:SetQuestToastSelected(qf, false)
            if qf.ani then qf.ani:Stop() end
            if qf.qmark then qf.qmark:SetAlpha(0) end
        end
        for _, key in ipairs({ "iconPulse", "percentPulse", "percentOutlinePulse", "killIconPulse", "lootIconPulse" }) do
            local pulse = self[key]
            if pulse and pulse.IsPlaying and pulse:IsPlaying() then pulse:Stop() end
        end
        SQP:ClearQuestPulseSync(self)
        for _, key in ipairs({ "icon", "percentIcon", "percentIconOutline", "killIcon", "lootIcon" }) do
            local region = self[key]
            if region and region.SetAlpha then region:SetAlpha(1) end
        end
        -- The banner's overlay must never outlive the options window: hides
        -- from panel close, Settings hide, and any detached preview parent.
        if self.plate then self.plate:Hide() end
        if self.questFrame then self.questFrame:Hide() end
    end)


    -- Update function
    function previewFrame:UpdatePreview()
        if useReal then
            EnsureRealOverlay()
            if not questFrame then return end
        end
        -- Keep the preview nameplate visible; the addon switch controls only
        -- SQP's quest overlay, just as it does on live nameplates.
        questFrame:SetShown(SQPSettings.enabled ~= false)
        questFrame._displayType = self.questType or "kill"

        if useReal then
            -- The preview plate is a real client nameplate registered with the
            -- driver: the overlay goes through the exact live anchor path.
            SQP:ApplyQuestLayout(questFrame, SQP:GetPlateAnchorTarget(realPlate))
        else
        -- Geometry: live-synced from a real nameplate, exactly like the
        -- working in-game example. All plates on a client share one size.
        local refPlate = GetReferenceNameplate()
        local plateWidth, plateHeight = 152, 44
        local healthWidth, healthHeight = 104, 10
        local refHealth
        if refPlate then
            plateWidth = GetFrameDimension(refPlate, "GetWidth", plateWidth)
            plateHeight = GetFrameDimension(refPlate, "GetHeight", plateHeight)

            refHealth = GetReferenceHealthBar(refPlate)
            local refHealthWidth = GetFrameDimension(refHealth, "GetWidth", nil)
            local refHealthHeight = GetFrameDimension(refHealth, "GetHeight", nil)
            if refHealthWidth and refHealthHeight then
                healthWidth = refHealthWidth
                healthHeight = refHealthHeight
            else
                healthWidth = math.max(1, plateWidth - 30)
            end

            local statusTexture = ReadPlainValues(refHealth, "GetStatusBarTexture")
            if statusTexture and statusTexture.GetTexture then
                local texturePath = ReadPlainValues(statusTexture, "GetTexture")
                if texturePath then
                    healthBar:SetStatusBarTexture(texturePath)
                end
            end
            if refHealth and refHealth.GetStatusBarColor then
                local r, g, b, a = ReadPlainValues(refHealth, "GetStatusBarColor")
                if r and g and b then
                    healthBar:SetStatusBarColor(r, g, b, a or 1)
                end
            end

            local refName = GetReferenceNameText(refPlate)
            if refName and refName.GetFont and nameText.SetFont then
                local font, size, flags = ReadPlainValues(refName, "GetFont")
                if font and size then
                    nameText:SetFont(font, size, flags)
                end
            end
            if refName and refName.GetTextColor and nameText.SetTextColor then
                local nr, ng, nb, na = ReadPlainValues(refName, "GetTextColor")
                if nr and ng and nb then
                    nameText:SetTextColor(nr, ng, nb, na or 1)
                end
            end
        end

        nameplate:SetSize(plateWidth, plateHeight)
        local previewScale = GetFrameDimension(previewFrame, "GetEffectiveScale", 1)
        local referenceScale = GetFrameDimension(refPlate, "GetEffectiveScale", previewScale)
        if previewScale <= 0 then previewScale = 1 end
        if referenceScale <= 0 then referenceScale = previewScale end
        nameplate:SetScale(referenceScale / previewScale)
        healthBar:ClearAllPoints()
        healthBar:SetSize(healthWidth, healthHeight)
        healthBar:SetScale(1)
        healthBar:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT", 10, -10)
        if refHealth and refPlate then
            local healthScale = GetFrameDimension(refHealth, "GetEffectiveScale", referenceScale)
            local plateLeft = GetFrameDimension(refPlate, "GetLeft", nil)
            local plateBottom = GetFrameDimension(refPlate, "GetBottom", nil)
            local healthLeft = GetFrameDimension(refHealth, "GetLeft", nil)
            local healthBottom = GetFrameDimension(refHealth, "GetBottom", nil)
            if healthScale > 0 and plateLeft and plateBottom and healthLeft and healthBottom then
                healthBar:ClearAllPoints()
                healthBar:SetScale(healthScale / referenceScale)
                healthBar:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT",
                    (healthLeft * healthScale - plateLeft * referenceScale) / healthScale,
                    (healthBottom * healthScale - plateBottom * referenceScale) / healthScale)
            end
        end

        -- The anchor analog mirrors the real frame the live icon anchors to:
        -- GetPlateAnchorTarget's HealthBarsContainer (or bar) with its true
        -- position inside the plate; falls back to the full mock plate when
        -- no reference plate is on screen.
        anchorAnalog:ClearAllPoints()
        anchorAnalog:SetScale(1)
        anchorAnalog:SetAllPoints(healthBar)
        if refPlate and SQP.GetPlateAnchorTarget then
            local okAnchor, refAnchor = pcall(SQP.GetPlateAnchorTarget, SQP, refPlate)
            if okAnchor and refAnchor then
                local anchorWidth = GetFrameDimension(refAnchor, "GetWidth", nil)
                local anchorHeight = GetFrameDimension(refAnchor, "GetHeight", nil)
                if anchorWidth and anchorHeight then
                    anchorAnalog:ClearAllPoints()
                    anchorAnalog:SetSize(anchorWidth, anchorHeight)
                    local plateLeft = GetFrameDimension(refPlate, "GetLeft", nil)
                    local plateBottom = GetFrameDimension(refPlate, "GetBottom", nil)
                    local anchorLeft = GetFrameDimension(refAnchor, "GetLeft", nil)
                    local anchorBottom = GetFrameDimension(refAnchor, "GetBottom", nil)
                    if plateLeft and plateBottom and anchorLeft and anchorBottom then
                        local anchorScale = GetFrameDimension(refAnchor, "GetEffectiveScale", referenceScale)
                        if anchorScale <= 0 then anchorScale = referenceScale end
                        anchorAnalog:SetScale(anchorScale / referenceScale)
                        anchorAnalog:SetPoint("BOTTOMLEFT", nameplate, "BOTTOMLEFT",
                            (anchorLeft * anchorScale - plateLeft * referenceScale) / anchorScale,
                            (anchorBottom * anchorScale - plateBottom * referenceScale) / anchorScale)
                    else
                        anchorAnalog:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
                    end
                end
            end
        end

        local referenceParent = refPlate
        if SQP:IsUnifiedMode(refPlate) then referenceParent = refPlate.UnitFrame end
        local referenceParentScale = GetFrameDimension(referenceParent, "GetEffectiveScale", referenceScale)
        if referenceParentScale <= 0 then referenceParentScale = referenceScale end
        questFrame._displayType = self.questType or "kill"
        SQP:ApplyQuestLayout(questFrame, anchorAnalog, referenceParentScale / referenceScale)
        end -- mock geometry

        if self.modeCaption then
            -- Small label at the top-left of the banner (where the client's
            -- own settings preview puts it); reports the live display style
            -- (Classic / Text / Forever) for the currently selected quest type.
            if SQPSettings.enabled == false then
                self.modeCaption:SetText("|cff9a9a9aPreview — SQP disabled|r")
            else
                local modeKey = self.questType or "kill"
                local styleText
                if SQP:UsesLevelChip(modeKey) then
                    styleText = SQP:UsesTextMode(modeKey) and "Forever + Text" or "Forever"
                else
                    local value = SQPSettings[modeKey .. "ShowIconBackground"]
                    if value == nil then value = SQPSettings.showIconBackground end
                    styleText = value == false and "Text" or "Classic"
                end
                self.modeCaption:SetText("|cff9a9a9aPreview — |r|cff58be81" .. styleText .. "|r")
            end
        end

        -- Update font with current quest type. Wrap in pcall so a font
        -- resolution failure (e.g. the registry not yet populated) cannot
        -- abort UpdatePreview before the icons get shown below.
        local previewTypeKey = self.questType or "kill"
        pcall(SQP.UpdateQuestFont, SQP, iconText, iconTextOutline, percentIcon, percentIconOutline, previewTypeKey)

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
            return not SQP:UsesTextMode(typeKey)
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
            local unifiedType = SQP:UsesLevelChip("percent")
            if self.lootIcon then self.lootIcon:Hide() end
            if self.killIcon  then self.killIcon:Hide()  end

            if SQPSettings.showPercentIcon == true then
                local pOW   = SQP:GetOutlineInfo("percent")
                -- The toggle hides only the "%" character; the number (and the
                -- chip in unified mode) always stays. Mirrors quest.lua.
                if percentIconMode or unifiedType then
                    -- Icon mode: jellybean + number + "%" at configured side
                    icon:Show()
                    self.iconText:SetText("75")
                    if self.iconTextOutline then self.iconTextOutline:SetText("75") end
                    if self.percentIcon then
                        SQP:AnchorPercentSign(self.percentIcon, icon, false)
                        self.percentIcon:SetText("%")
                        SetPreviewPercentColor(self.percentIcon)
                        self.percentIcon:Show()
                    end
                    if self.percentIconOutline then
                        SQP:AnchorPercentSign(self.percentIconOutline, icon, false)
                        self.percentIconOutline:SetText("%")
                        if pOW > 0 then self.percentIconOutline:Show() else self.percentIconOutline:Hide() end
                    end
                else
                    -- Text mode: floating "75%"
                    icon:Hide()
                    self.iconText:SetText("")
                    if self.iconTextOutline then self.iconTextOutline:SetText("") end
                    if self.percentIcon then
                        SQP:AnchorPercentSign(self.percentIcon, icon, true)
                        self.percentIcon:SetText("75%")
                        SetPreviewPercentColor(self.percentIcon)
                        self.percentIcon:Show()
                    end
                    if self.percentIconOutline then
                        SQP:AnchorPercentSign(self.percentIconOutline, icon, true)
                        self.percentIconOutline:SetText("75%")
                        if pOW > 0 then self.percentIconOutline:Show() else self.percentIconOutline:Hide() end
                    end
                end
            else
                -- "%" hidden: the number must still render in every style —
                -- icon mode keeps the jellybean, text mode shows the bare
                -- number, and unified keeps the chip with the number only.
                if self.percentIcon then self.percentIcon:Hide() end
                if self.percentIconOutline then self.percentIconOutline:Hide() end
                if percentIconMode then
                    icon:Show()
                else
                    icon:Hide()
                end
                self.iconText:SetText("75")
                if self.iconTextOutline then self.iconTextOutline:SetText("75") end
            end
        end

        -- Unified mode shows the count in a level-style chip (no jellybean);
        -- for percent quests the chip holds only the number and the "%" stays
        -- outside per the side/offset options (handled above).
        if self.questChip then
            if SQP:UsesLevelChip(previewTypeKey) then
                icon:Hide()
                if previewTypeKey == "percent" then
                    iconText:SetText("75")
                    if self.iconTextOutline then self.iconTextOutline:SetText("75") end
                end
                -- Same updater as live plates; do not maintain a parallel size
                -- path in the preview.
                SQP:UpdateUnifiedChip(questFrame)
            else
                self.questChip:Hide()
            end
        end

        -- Manage main/icon text pulse animation with global override support.
        local animateMain = SQP:IsAnimationEnabled(previewTypeKey, false)
        local mainIconShown = icon:IsShown()
        local percentTextShown = self.percentIcon and self.percentIcon:IsShown() and not mainIconShown
        local animatePercentSign = previewTypeKey == "percent"
            and SQPSettings.showPercentIcon == true
            and SQPSettings.percentShowIconBackground ~= false
            and SQP:IsAnimationEnabled("percent", true)

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
            if (animateMain and percentTextShown or animatePercentSign)
                and self.percentIcon and self.percentIcon:IsShown() then
                if not self.percentPulse:IsPlaying() then self.percentPulse:Play() end
            else
                if self.percentPulse:IsPlaying() then self.percentPulse:Stop() end
                percentIcon:SetAlpha(1)
            end
        end

        if self.percentOutlinePulse then
            SQP:ApplyPulseDuration(self.percentOutlinePulse, SQP:GetAnimationDuration("percent", false))
            if (animateMain and percentTextShown or animatePercentSign)
                and self.percentIconOutline and self.percentIconOutline:IsShown() then
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
        if SQPSettings.syncAnimations then
            SQP:SyncQuestPulses(self)
        else
            SQP:ClearQuestPulseSync(self)
        end
        -- Generic layout/animation refresh: settings converged, no trigger.
        SQP:UpdateQuestToast(questFrame, false)
        local typeEnabled = SQPSettings.enabled ~= false and SQPSettings[previewTypeKey .. "Enabled"] ~= false
        SQP:UpdateTextPulses(questFrame, previewTypeKey, typeEnabled)
        questFrame:SetShown(typeEnabled)
    end

    -- Restart animation when the panel becomes visible again
    previewFrame:SetScript("OnShow", function(self)
        if self.plate then self.plate:Show() end
        self:UpdatePreview()
    end)

    -- Type-switcher button state: alpha dims inactive buttons and the
    -- framework's selection styling keeps the current type highlighted.
    local function UpdateTypeButtons(activeType)
        killTypeBtn:SetAlpha(activeType == "kill"    and 1 or 0.45)
        lootTypeBtn:SetAlpha(activeType == "loot"    and 1 or 0.45)
        pctTypeBtn:SetAlpha( activeType == "percent" and 1 or 0.45)
        if killTypeBtn.SetSelected then
            -- Selected type keeps its hover highlight after the pointer leaves.
            killTypeBtn:SetSelected(activeType == "kill")
            lootTypeBtn:SetSelected(activeType == "loot")
            pctTypeBtn:SetSelected(activeType == "percent")
        end
    end
    UpdateTypeButtons(nil)
    previewFrame.clearTypeSelection = function()
        -- Switching preview type/page ends the replay toast; reselect to play.
        if SQP and SQP.SetQuestToastSelected and questFrame then
            SQP:SetQuestToastSelected(questFrame, false)
        end
        UpdateTypeButtons(nil)
    end

    -- External helpers to switch preview mode from tab clicks and option controls
    previewFrame.activateKillMode = function()
        if iconText then iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0})) end
        if lootIcon then lootIcon:Hide() end
        if killIcon then killIcon:Hide() end
        previewFrame.questType = "kill"
        UpdateTypeButtons("kill")
        previewFrame:UpdatePreview()
    end

    previewFrame.activateLootMode = function()
        if iconText then iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2})) end
        if lootIcon then lootIcon:Show() end
        if killIcon then killIcon:Hide() end
        previewFrame.questType = "loot"
        UpdateTypeButtons("loot")
        previewFrame:UpdatePreview()
    end

    previewFrame.activatePercentMode = function()
        if iconText then iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1})) end
        if lootIcon then lootIcon:Hide() end
        if killIcon then killIcon:Hide() end
        previewFrame.questType = "percent"
        UpdateTypeButtons("percent")
        previewFrame:UpdatePreview()
    end

    -- Set button scripts (after activate functions are defined)
    local function SelectType(page, activate)
        if SQP.optionsPanel then SQP.optionsPanel:SelectTabByName("Global") end
        if SQP.optionsPanel and SQP.optionsPanel.ClearTabHighlight then
            SQP.optionsPanel:ClearTabHighlight()
        end
        local pager = SQP.optionControls and SQP.optionControls.generalPager
        if pager then pager:SetPage(page) end
        activate()
    end
    killTypeBtn:SetScript("OnClick", function() SelectType(2, previewFrame.activateKillMode) end)
    lootTypeBtn:SetScript("OnClick", function() SelectType(3, previewFrame.activateLootMode) end)
    pctTypeBtn:SetScript("OnClick", function() SelectType(4, previewFrame.activatePercentMode) end)

    -- Hover selects the preview type persistently. Only a different type
    -- activation changes it; leaving a button restores its skin, not the type.
    for _, pair in ipairs({
        { killTypeBtn, previewFrame.activateKillMode },
        { lootTypeBtn, previewFrame.activateLootMode },
        { pctTypeBtn,  previewFrame.activatePercentMode },
    }) do
        local button, activate = pair[1], pair[2]
        -- HookScript so the framework button hover highlight keeps working;
        -- SetScript would have replaced it and killed the highlight.
        button:HookScript("OnEnter", function()
            local pager = SQP.optionControls and SQP.optionControls.generalPager
            local page = pager and pager.page
            local frame = page and pager.frames and pager.frames[page]
            -- Hidden Global subpages do not pin previews on other tabs.
            if page and page > 1 and frame and frame:IsVisible() then return end
            activate()
        end)
    end

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
