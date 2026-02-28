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
function SQP:UpdateQuestFont(fontString, outlineFontString, percentFontString, percentOutlineFontString)
    -- Use selected font or default
    local fontName = SQPSettings.fontFamily or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    
    local fontSize = SQPSettings.fontSize or 12
    local outlineWidth, fontOutline, noOutline = self:GetOutlineInfo()
    local outlineColor = SQPSettings.outlineColor or {0, 0, 0}
    local r, g, b = unpack(outlineColor)
    local a = SQPSettings.outlineAlpha ~= nil and SQPSettings.outlineAlpha or 1.0
    
    -- Set font (outline drawn by separate layer when available)
    local mainOutline = outlineFontString and "" or (noOutline and "" or fontOutline)
    fontString:SetFont(fontName, fontSize, mainOutline)
    
    -- Set standard shadow (only when no outline is selected)
    fontString:SetShadowOffset(1, -1)
    if outlineWidth <= 0 then
        fontString:SetShadowColor(0, 0, 0, 1)
    else
        fontString:SetShadowColor(0, 0, 0, 0)
    end

    if outlineFontString then
        if outlineWidth <= 0 then
            outlineFontString:Hide()
        else
            local outlineFlag = outlineWidth >= 3 and "THICKOUTLINE" or "OUTLINE"
            local outlineSize = math.max(6, fontSize - 2)
            outlineFontString:SetFont(fontName, outlineSize, outlineFlag)
            outlineFontString:SetTextColor(r or 0, g or 0, b or 0, a or 1)
            outlineFontString:SetShadowOffset(0, 0)
            outlineFontString:SetShadowColor(0, 0, 0, 0)
            outlineFontString:Show()
        end
    end

    if percentFontString then
        local percentSize = (SQPSettings and SQPSettings.percentIconSize) or (fontSize + 4)
        local percentMainOutline = percentOutlineFontString and "" or (noOutline and "" or fontOutline)
        percentFontString:SetFont(fontName, percentSize, percentMainOutline)
        percentFontString:SetShadowOffset(1, -1)
        if outlineWidth <= 0 then
            percentFontString:SetShadowColor(0, 0, 0, 1)
        else
            percentFontString:SetShadowColor(0, 0, 0, 0)
        end

        if percentOutlineFontString then
            if outlineWidth <= 0 then
                percentOutlineFontString:Hide()
            else
                local outlineFlag = outlineWidth >= 3 and "THICKOUTLINE" or "OUTLINE"
                local percentOutlineSize = math.max(6, percentSize - 2)
                percentOutlineFontString:SetFont(fontName, percentOutlineSize, outlineFlag)
                percentOutlineFontString:SetTextColor(r or 0, g or 0, b or 0, a or 1)
                percentOutlineFontString:SetShadowOffset(0, 0)
                percentOutlineFontString:SetShadowColor(0, 0, 0, 0)
                percentOutlineFontString:Show()
            end
        end
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
                self:UpdateQuestFont(
                    questFrame.iconText,
                    questFrame.iconTextOutline,
                    questFrame.percentIcon,
                    questFrame.percentIconOutline
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
                    questFrame.percentIcon:ClearAllPoints()
                    questFrame.percentIcon:SetPoint('CENTER', questFrame.icon, SQPSettings.percentIconOffsetX or 0, SQPSettings.percentIconOffsetY or 0)
                    questFrame.percentIcon:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                    questFrame.percentIcon:Show()
                    if questFrame.percentIconOutline then
                        questFrame.percentIconOutline:ClearAllPoints()
                        questFrame.percentIconOutline:SetPoint('CENTER', questFrame.icon, SQPSettings.percentIconOffsetX or 0, SQPSettings.percentIconOffsetY or 0)
                        local outlineWidth = SQP:GetOutlineInfo()
                        if outlineWidth and outlineWidth > 0 then
                            questFrame.percentIconOutline:Show()
                        else
                            questFrame.percentIconOutline:Hide()
                        end
                    end
                    if questFrame.icon then
                        questFrame.icon:Hide()
                    end
                else
                    questFrame.percentIcon:Hide()
                    if questFrame.percentIconOutline then
                        questFrame.percentIconOutline:Hide()
                    end
                    if questFrame.icon then
                        questFrame.icon:Show()
                    end
                end
            end
            
            -- Update icon tinting
            local mainTintEnabled = SQPSettings.iconTintMain and SQPSettings.iconTintMainColor
            local mainTintR, mainTintG, mainTintB, mainTintA = 1, 1, 1, 1
            if mainTintEnabled then
                mainTintR, mainTintG, mainTintB, mainTintA = unpack(SQPSettings.iconTintMainColor)
                questFrame.icon:SetVertexColor(mainTintR, mainTintG, mainTintB, mainTintA)
            else
                questFrame.icon:SetVertexColor(1, 1, 1, 1)
            end

            local questTintEnabled = SQPSettings.iconTintQuest and SQPSettings.iconTintQuestColor
            local questTintR, questTintG, questTintB, questTintA = 1, 1, 1, 1
            if questTintEnabled then
                questTintR, questTintG, questTintB, questTintA = unpack(SQPSettings.iconTintQuestColor)
            end

            if questFrame.killIcon then
                if questTintEnabled then
                    questFrame.killIcon:SetVertexColor(questTintR, questTintG, questTintB, questTintA)
                else
                    questFrame.killIcon:SetVertexColor(1, 1, 1, 1)
                end
            end
            if questFrame.lootIcon then
                if questTintEnabled then
                    questFrame.lootIcon:SetVertexColor(questTintR, questTintG, questTintB, questTintA)
                else
                    questFrame.lootIcon:SetVertexColor(1, 1, 1, 1)
                end
            end
            if questFrame.percentIcon and questFrame.questType == 3 then
                if mainTintEnabled then
                    questFrame.percentIcon:SetTextColor(mainTintR, mainTintG, mainTintB, mainTintA or 1)
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
