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
    local icon = questFrame:CreateTexture(nil, "OVERLAY", nil, 7)
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
    
    -- Apply scale to the quest frame
    questFrame:SetScale(SQPSettings.scale or 1)
    
    -- Item texture
    local itemTexture = questFrame:CreateTexture(nil, nil, nil, 1)
    itemTexture:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
    itemTexture:SetSize(16, 16)
    itemTexture:SetMask('Interface/CharacterFrame/TempPortraitAlphaMask')
    itemTexture:Hide()
    questFrame.itemTexture = itemTexture
    
    -- Loot icon
    local lootIcon = questFrame:CreateTexture(nil, nil, nil, 1)
    lootIcon:SetAtlas('Banker')
    lootIcon:SetSize(16, 16)
    lootIcon:SetPoint('TOPLEFT', icon, 'BOTTOMRIGHT', -12, 12)
    lootIcon:Hide()
    questFrame.lootIcon = lootIcon
    
    -- Quest count text
    local iconText = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    iconText:SetPoint('CENTER', icon, 0.8, 0)
    iconText:SetShadowOffset(1, -1)
    iconText:SetTextColor(1, 0.82, 0)
    
    -- Apply font settings
    self:UpdateQuestFont(iconText)
    
    questFrame.iconText = iconText
    
    -- Quest complete animation
    local qmark = questFrame:CreateTexture(nil, 'OVERLAY')
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
function SQP:UpdateQuestFont(fontString)
    -- Use selected font or default
    local fontName = SQPSettings.fontFamily or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    
    local fontSize = SQPSettings.fontSize or 12
    local fontOutline = SQPSettings.fontOutline or "OUTLINE"
    
    -- Set font with outline
    fontString:SetFont(fontName, fontSize, fontOutline)
    
    -- Set standard shadow
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
end

-- Refresh all nameplate positions and settings
function SQP:RefreshAllNameplates()
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
            
            -- Update font settings
            if questFrame.iconText then
                self:UpdateQuestFont(questFrame.iconText)
                
                -- Re-apply text color based on stored quest info
                if questFrame.hasItem then
                    -- Item quest
                    questFrame.iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
                elseif questFrame.questType then
                    if questFrame.questType == 1 then
                        -- Kill quest
                        questFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
                    elseif questFrame.questType == 2 then
                        -- Completed quest
                        questFrame.iconText:SetTextColor(1, 1, 1)
                    elseif questFrame.questType == 3 then
                        -- Progress quest
                        questFrame.iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                    end
                end
            end
            
            -- Update icon tinting
            if SQPSettings.iconTintColor then
                questFrame.icon:SetVertexColor(unpack(SQPSettings.iconTintColor))
            else
                questFrame.icon:SetVertexColor(1, 1, 1, 1)
            end
        end
    end
    
    -- Force update quest display
    for plate in pairs(self.ActiveNameplates) do
        self:UpdateQuestIcon(plate, plate._unitID)
    end
end