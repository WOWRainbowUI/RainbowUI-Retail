--=====================================================================================
-- RGX | Simple Quest Plates! - nameplates.lua

-- Author: DonnieDice
-- Description: Nameplate management and tracking system
--=====================================================================================

local addonName, SQP = ...

-- Nameplate storage
SQP.Nameplates = {} -- [plate] = frame
SQP.ActiveNameplates = {} -- [plate] = frame (visible only)
SQP.PlateGUIDs = {} -- [guid] = plate
SQP.QuestPlates = {} -- [plate] = questFrame

-- Create quest plate frame for new nameplates
function SQP:CreateQuestPlate(nameplate)
    -- Check if nameplate already has quest frame to prevent duplicates
    if self.QuestPlates[nameplate] then
        return
    end
    
    -- Store reference to nameplate frame
    self.Nameplates[nameplate] = nameplate
    
    -- Create quest overlay directly on nameplate
    local questFrame = CreateFrame('frame', nil, nameplate)
    questFrame:Hide()
    questFrame:SetAllPoints(nameplate)
    self.QuestPlates[nameplate] = questFrame
    
    -- Quest icon (jellybean)
    local icon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    icon:SetSize(28, 22)
    icon:SetTexture('Interface/QuestFrame/AutoQuest-Parts')
    icon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)
    icon:SetPoint(
        SQPSettings.anchor or 'RIGHT', 
        nameplate, 
        SQPSettings.relativeTo or 'LEFT', 
        SQPSettings.offsetX or 0, 
        SQPSettings.offsetY or 0
    )
    questFrame.icon = icon

    -- Dramatic pulse for main quest icon (more noticeable)
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

    -- Subtle pulse for task type icons (kill/loot)
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
    
    -- Apply scale to the quest frame
    questFrame:SetScale(SQPSettings.scale or 1)
    
    -- Item texture
    local itemTexture = questFrame:CreateTexture(nil, nil, nil, 1)
    itemTexture:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
    itemTexture:SetSize(16, 16)
    itemTexture:SetMask('Interface/CharacterFrame/TempPortraitAlphaMask')
    itemTexture:Hide()
    questFrame.itemTexture = itemTexture

    -- Kill quest icon (hostile cursor knife/sword)
    local killIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    killIcon:SetPoint(
        'TOPRIGHT',
        icon,
        'BOTTOMLEFT',
        SQPSettings.killIconOffsetX or 12,
        SQPSettings.killIconOffsetY or 12
    )
    killIcon:SetSize(SQPSettings.killIconSize or 16, SQPSettings.killIconSize or 16)
    killIcon:SetTexture('Interface/Cursor/Attack')
    if not killIcon:GetTexture() then
        killIcon:SetTexture('Interface/Icons/INV_Sword_04')
        killIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    killIcon:Hide()
    questFrame.killIcon = killIcon
    questFrame.killIconPulse = CreatePulse(killIcon)

    -- Loot icon
    local lootIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    if lootIcon.SetAtlas then
        lootIcon:SetAtlas('Banker')
    else
        lootIcon:SetTexture('Interface/Icons/INV_Misc_Bag_10')
        lootIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    lootIcon:SetSize(SQPSettings.lootIconSize or 16, SQPSettings.lootIconSize or 16)
    lootIcon:SetPoint(
        'TOPLEFT',
        icon,
        'BOTTOMRIGHT',
        SQPSettings.lootIconOffsetX or -12,
        SQPSettings.lootIconOffsetY or 12
    )
    lootIcon:Hide()
    questFrame.lootIcon = lootIcon
    questFrame.lootIconPulse = CreatePulse(lootIcon)

    -- Quest count text
    local iconText = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if iconText.SetDrawLayer then
        iconText:SetDrawLayer('OVERLAY', 2)
    end
    iconText:SetPoint('CENTER', icon, 0.8, 0)
    iconText:SetShadowOffset(1, -1)
    iconText:SetTextColor(1, 0.82, 0)

    -- Outline text (separate layer for custom outline color)
    local iconTextOutline = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if iconTextOutline.SetDrawLayer then
        iconTextOutline:SetDrawLayer('OVERLAY', 1)
    end
    iconTextOutline:SetPoint('CENTER', icon, 0.8, 0)
    iconTextOutline:SetShadowOffset(0, 0)
    iconTextOutline:SetTextColor(0, 0, 0, 1)
    
    -- Percent icon (used for percentage quests)
    local percentIcon = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if percentIcon.SetDrawLayer then
        percentIcon:SetDrawLayer('OVERLAY', 2)
    end
    percentIcon:SetPoint('CENTER', icon, SQPSettings.percentIconOffsetX or 0, SQPSettings.percentIconOffsetY or 0)
    percentIcon:SetTextColor(0.2, 1, 1)
    percentIcon:Hide()

    local percentIconOutline = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if percentIconOutline.SetDrawLayer then
        percentIconOutline:SetDrawLayer('OVERLAY', 1)
    end
    percentIconOutline:SetPoint('CENTER', icon, SQPSettings.percentIconOffsetX or 0, SQPSettings.percentIconOffsetY or 0)
    percentIconOutline:SetTextColor(0, 0, 0, 1)
    percentIconOutline:Hide()

    -- Apply font settings
    self:UpdateQuestFont(iconText, iconTextOutline, percentIcon, percentIconOutline)
    
    questFrame.iconText = iconText
    questFrame.iconTextOutline = iconTextOutline
    questFrame.percentIcon = percentIcon
    questFrame.percentIconOutline = percentIconOutline
    questFrame.iconPulse = CreateMainPulse(icon)
    questFrame.percentPulse = CreatePulse(percentIcon)
    questFrame.percentOutlinePulse = CreatePulse(percentIconOutline)
    
    -- Quest complete animation
    local qmark = questFrame:CreateTexture(nil, 'OVERLAY', nil, 7)
    qmark:SetSize(28, 28)
    qmark:SetPoint('CENTER', icon)
    qmark:SetTexture('Interface/WorldMap/UI-WorldMap-QuestIcon')
    qmark:SetTexCoord(0, 0.56, 0.5, 1)
    qmark:SetAlpha(0)
    
    local duration = 1
    local group = qmark:CreateAnimationGroup()
    local alpha = group:CreateAnimation('Alpha')
    alpha:SetOrder(1)
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(0)
    
    local translation = group:CreateAnimation('Translation')
    translation:SetOrder(1)
    translation:SetOffset(0, 20)
    translation:SetDuration(duration)
    translation:SetSmoothing('OUT')
    
    local alpha2 = group:CreateAnimation('Alpha')
    alpha2:SetOrder(1)
    alpha2:SetFromAlpha(1)
    alpha2:SetToAlpha(0)
    alpha2:SetDuration(duration)
    alpha2:SetSmoothing('OUT')
    
    questFrame.ani = group
    
    questFrame:HookScript('OnShow', function(self)
        group:Play()
    end)
end

-- Nameplate show callback
function SQP:OnPlateShow(nameplate, unitID)
    -- Store unit ID on nameplate itself
    nameplate._unitID = unitID
    self.ActiveNameplates[nameplate] = nameplate
    
    local ok, guid = pcall(UnitGUID, unitID)
    if ok and guid then
        local setOk = pcall(function() self.PlateGUIDs[guid] = nameplate end)
    end

    self:UpdateQuestIcon(nameplate, unitID)

    -- Recheck shortly after show to allow tooltip data to populate
    if C_Timer and C_Timer.After then
        local addon = self
        local plateRef = nameplate
        local unitRef = unitID
        C_Timer.After(0.15, function()
            if addon.ActiveNameplates[plateRef] and plateRef._unitID == unitRef then
                addon:UpdateQuestIcon(plateRef, unitRef)
            end
        end)
    end
end

-- Nameplate hide callback
function SQP:OnPlateHide(nameplate, unitID)
    self.ActiveNameplates[nameplate] = nil
    
    -- Only try to get GUID if we have a valid unitID
    if unitID then
        local ok, guid = pcall(UnitGUID, unitID)
        if ok and guid then
            pcall(function() self.PlateGUIDs[guid] = nil end)
        end
    end
    
    if self.QuestPlates[nameplate] then
        self.QuestPlates[nameplate]:Hide()
    end
end

-- Update font for quest text
-- typeKey: "kill", "loot", "percent", or nil (falls back to global settings)
function SQP:UpdateQuestFont(fontString, outlineFontString, percentFontString, percentOutlineFontString, typeKey)
    local S = SQPSettings or {}

    local function applyFont(main, outline, tk)
        local fontName    = (tk and S[tk.."FontFamily"])   or S.fontFamily  or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
        local fontSize    = (tk and S[tk.."FontSize"])     or S.fontSize    or 12
        local fontOutline = (tk and S[tk.."FontOutline"])  or S.fontOutline or ""
        local outlineWidth= (tk and S[tk.."OutlineWidth"])
        if outlineWidth == nil then outlineWidth = S.outlineWidth or 0 end
        local outlineAlpha= (tk and S[tk.."OutlineAlpha"])
        if outlineAlpha  == nil then outlineAlpha  = S.outlineAlpha  or 0 end
        local outlineColor= (tk and S[tk.."OutlineColor"]) or S.outlineColor or {0, 0, 0}

        local noOutline = fontOutline == "" or fontOutline == "NONE"
        if noOutline then outlineWidth = 0 end
        if outlineWidth < 0 then outlineWidth = 0 end

        local mainFlag = outline and "" or (noOutline and "" or fontOutline)
        main:SetFont(fontName, fontSize, mainFlag)
        main:SetShadowOffset(1, -1)
        if outlineWidth <= 0 then
            main:SetShadowColor(0, 0, 0, 1)
        else
            main:SetShadowColor(0, 0, 0, 0)
        end

        if outline then
            if outlineWidth <= 0 then
                outline:Hide()
            else
                local flag = outlineWidth >= 3 and "THICKOUTLINE" or "OUTLINE"
                -- Use same fontSize as main so the border aligns correctly
                outline:SetFont(fontName, fontSize, flag)
                local r, g, b = unpack(outlineColor)
                outline:SetTextColor(r, g, b, outlineAlpha)
                outline:SetShadowOffset(0, 0)
                outline:SetShadowColor(0, 0, 0, 0)
                outline:Show()
            end
        end
    end

    -- Main count text uses the provided typeKey
    applyFont(fontString, outlineFontString, typeKey)

    -- Percent symbol always uses "percent" settings
    if percentFontString then
        applyFont(percentFontString, percentOutlineFontString, "percent")
    end
end

-- Refresh all nameplate positions and settings
function SQP:RefreshAllNameplates()
    -- Classic/MoP clients can rescan nameplates to ensure active list stays valid
    if self.RescanNameplates then
        self:RescanNameplates()
    end

    -- Update settings for all quest plates
    for plate, questFrame in pairs(self.QuestPlates) do
        if questFrame and questFrame.icon then
            local function IsIconStyleEnabled(typeKey)
                local value = SQPSettings[typeKey .. "ShowIconBackground"]
                if value == nil then
                    value = SQPSettings.showIconBackground
                end
                return value ~= false
            end

            questFrame.icon:ClearAllPoints()
            questFrame.icon:SetPoint(
                SQPSettings.anchor or 'RIGHT',
                plate,
                SQPSettings.relativeTo or 'LEFT',
                SQPSettings.offsetX or 0,
                SQPSettings.offsetY or 0
            )
            questFrame:SetScale(SQPSettings.scale or 1)

            if questFrame.killIcon then
                questFrame.killIcon:ClearAllPoints()
                questFrame.killIcon:SetPoint(
                    'TOPRIGHT',
                    questFrame.icon,
                    'BOTTOMLEFT',
                    SQPSettings.killIconOffsetX or 12,
                    SQPSettings.killIconOffsetY or 12
                )
                questFrame.killIcon:SetSize(SQPSettings.killIconSize or 16, SQPSettings.killIconSize or 16)
            end
            if questFrame.lootIcon then
                questFrame.lootIcon:ClearAllPoints()
                questFrame.lootIcon:SetPoint(
                    'TOPLEFT',
                    questFrame.icon,
                    'BOTTOMRIGHT',
                    SQPSettings.lootIconOffsetX or -12,
                    SQPSettings.lootIconOffsetY or 12
                )
                questFrame.lootIcon:SetSize(SQPSettings.lootIconSize or 16, SQPSettings.lootIconSize or 16)
            end
            
            -- Update font settings
            if questFrame.iconText then
                local fontTypeKey
                if questFrame.hasItem then
                    fontTypeKey = "loot"
                elseif questFrame.questType == 3 then
                    fontTypeKey = "percent"
                else
                    fontTypeKey = "kill"
                end
                self:UpdateQuestFont(
                    questFrame.iconText,
                    questFrame.iconTextOutline,
                    questFrame.percentIcon,
                    questFrame.percentIconOutline,
                    fontTypeKey
                )
                
                -- Re-apply text color based on stored quest info
                if questFrame.questRelatedOnly then
                    questFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
                    if questFrame.lootIcon then
                        questFrame.lootIcon:Hide()
                    end
                    if questFrame.killIcon then
                        questFrame.killIcon:Hide()
                    end
                elseif questFrame.hasItem then
                    -- Item quest
                    questFrame.iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
                    if questFrame.lootIcon then
                        if SQPSettings.showLootIcon ~= false then
                            questFrame.lootIcon:Show()
                        else
                            questFrame.lootIcon:Hide()
                        end
                    end
                    if questFrame.killIcon then
                        questFrame.killIcon:Hide()
                    end
                elseif questFrame.questType then
                    if questFrame.questType == 1 then
                        -- Kill quest
                        questFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
                        if questFrame.lootIcon then
                            questFrame.lootIcon:Hide()
                        end
                        if questFrame.killIcon then
                            if SQPSettings.showKillIcon ~= false then
                                questFrame.killIcon:Show()
                            else
                                questFrame.killIcon:Hide()
                            end
                        end
                    elseif questFrame.questType == 2 then
                        -- Completed quest
                        questFrame.iconText:SetTextColor(1, 1, 1)
                        if questFrame.lootIcon then
                            questFrame.lootIcon:Hide()
                        end
                        if questFrame.killIcon then
                            questFrame.killIcon:Hide()
                        end
                    elseif questFrame.questType == 3 then
                        -- Progress quest
                        questFrame.iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                        if questFrame.lootIcon then
                            questFrame.lootIcon:Hide()
                        end
                        if questFrame.killIcon then
                            questFrame.killIcon:Hide()
                        end
                    end
                end
            end

            if questFrame.percentIcon then
                if questFrame.questType == 3 then
                    local percentIconMode = IsIconStyleEnabled("percent")
                    questFrame.percentIcon:ClearAllPoints()
                    questFrame.percentIcon:SetPoint('CENTER', questFrame.icon, SQPSettings.percentIconOffsetX or 0, SQPSettings.percentIconOffsetY or 0)
                    if SQPSettings.percentTintIcon and SQPSettings.percentTintIconColor then
                        local r, g, b, a = unpack(SQPSettings.percentTintIconColor)
                        questFrame.percentIcon:SetTextColor(r, g, b, a or 1)
                    else
                        questFrame.percentIcon:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                    end
                    questFrame.percentIcon:Show()
                    if questFrame.percentIconOutline then
                        questFrame.percentIconOutline:ClearAllPoints()
                        questFrame.percentIconOutline:SetPoint('CENTER', questFrame.icon, SQPSettings.percentIconOffsetX or 0, SQPSettings.percentIconOffsetY or 0)
                        local outlineWidth = SQP:GetOutlineInfo("percent")
                        if outlineWidth and outlineWidth > 0 then
                            questFrame.percentIconOutline:Show()
                        else
                            questFrame.percentIconOutline:Hide()
                        end
                    end
                    if questFrame.icon then
                        if percentIconMode then
                            questFrame.icon:Show()
                        else
                            questFrame.icon:Hide()
                        end
                    end
                else
                    local nonPercentType = questFrame.hasItem and "loot" or "kill"
                    local nonPercentIconMode = IsIconStyleEnabled(nonPercentType)
                    questFrame.percentIcon:Hide()
                    if questFrame.percentIconOutline then
                        questFrame.percentIconOutline:Hide()
                    end
                    if questFrame.icon then
                        if nonPercentIconMode then
                            questFrame.icon:Show()
                        else
                            questFrame.icon:Hide()
                        end
                    end
                end
            end
            
            -- Main icon tinting removed (redundant with color controls)
            questFrame.icon:SetVertexColor(1, 1, 1, 1)

            local killTintEnabled = SQPSettings.killTintIcon and SQPSettings.killTintIconColor
            local killTintR, killTintG, killTintB, killTintA = 1, 1, 1, 1
            if killTintEnabled then
                killTintR, killTintG, killTintB, killTintA = unpack(SQPSettings.killTintIconColor)
            end
            local lootTintEnabled = SQPSettings.lootTintIcon and SQPSettings.lootTintIconColor
            local lootTintR, lootTintG, lootTintB, lootTintA = 1, 1, 1, 1
            if lootTintEnabled then
                lootTintR, lootTintG, lootTintB, lootTintA = unpack(SQPSettings.lootTintIconColor)
            end
            local percentTintEnabled = SQPSettings.percentTintIcon and SQPSettings.percentTintIconColor
            local percentTintR, percentTintG, percentTintB, percentTintA = 1, 1, 1, 1
            if percentTintEnabled then
                percentTintR, percentTintG, percentTintB, percentTintA = unpack(SQPSettings.percentTintIconColor)
            end

            if questFrame.killIcon then
                if killTintEnabled then
                    questFrame.killIcon:SetVertexColor(killTintR, killTintG, killTintB, killTintA)
                else
                    questFrame.killIcon:SetVertexColor(1, 1, 1, 1)
                end
            end
            if questFrame.lootIcon then
                if lootTintEnabled then
                    questFrame.lootIcon:SetVertexColor(lootTintR, lootTintG, lootTintB, lootTintA)
                else
                    questFrame.lootIcon:SetVertexColor(1, 1, 1, 1)
                end
            end
            if questFrame.percentIcon and questFrame.questType == 3 then
                if percentTintEnabled then
                    questFrame.percentIcon:SetTextColor(percentTintR, percentTintG, percentTintB, percentTintA or 1)
                else
                    questFrame.percentIcon:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                end
            end
        end
    end
    
    -- Force update quest display
    for plate in pairs(self.ActiveNameplates) do
        self:UpdateQuestIcon(plate, plate._unitID)
    end
end
