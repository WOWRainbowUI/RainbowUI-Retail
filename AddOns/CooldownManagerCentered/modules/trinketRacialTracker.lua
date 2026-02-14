local _, ns = ...

local TrinketRacialTracker = {}
ns.TrinketRacialTracker = TrinketRacialTracker

local LSM = LibStub("LibSharedMedia-3.0", true)
local LEM = LibStub("LibEQOLEditMode-1.0")
local WilduUICore = ns.WilduUICore

-- Config key for edit mode
local CONFIG_KEY = "trinketRacialTracker"

-- Items (potions/healthstone)
local ITEMS = {
    241304, -- Silvermoon Healing Potion
    241308, -- Light's Potential

    5512, -- Healthstone
    224464, -- Demonic Healthstone

    -- Invigorating Healing Potion
    244839,
    244838,
    244835,

    -- Tempered Potion
    212265, -- Tempered Potion (R3)
    212264, -- Tempered Potion (R2)
    212263, -- Tempered Potion (R1)

    -- Fleeting Tempered Potion
    212971,
    212970,
    212969,
}

-- Racials - simple list of spell IDs
local RACIALS = {
    7744, -- Will of the Forsaken
    20549, -- War Stomp
    20572, -- Blood Fury
    33697, -- Blood Fury
    33702, -- Blood Fury
    20589, -- Escape Artist
    20594, -- Stoneform
    26297, -- Berserking
    28880, -- Gift of the Naaru
    28880, -- Gift of the Naaru
    59542, -- Gift of the Naaru
    59543, -- Gift of the Naaru
    59544, -- Gift of the Naaru
    59545, -- Gift of the Naaru
    59547, -- Gift of the Naaru
    59548, -- Gift of the Naaru
    121093, -- Gift of the Naaru
    370626, -- Gift of the Naaru
    416250, -- Gift of the Naaru
    58984, -- Shadowmeld
    59752, -- Will to Survive
    68992, -- Darkflight
    69041, -- Rocket Barrage
    69070, -- Rocket Jump
    107079, -- Quaking Palm
    25046, -- Arcane Torrent
    28730, -- Arcane Torrent
    50613, -- Arcane Torrent
    69179, -- Arcane Torrent
    80483, -- Arcane Torrent
    202719, -- Arcane Torrent
    129597, -- Arcane Torrent
    155145, -- Arcane Torrent
    232633, -- Arcane Torrent
    255647, -- Light's Judgment
    255654, -- Bull Rush
    256948, -- Spatial Rift
    260364, -- Arcane Pulse
    265221, -- Fireblood
    274738, -- Ancestral Call
    287712, -- Haymaker
    291944, -- Regeneratin'
    312411, -- Bag of Tricks
    312924, -- Hyper Organic Light Originator
    357214, -- Wing Buffet
    368970, -- Tail Swipe
    436344, -- Azerite Surge
    1237885, -- Thorn Bloom
}

TrinketRacialTracker.ITEMS = ITEMS
TrinketRacialTracker.RACIALS = RACIALS

-- Constants
local DEFAULT_ICON_SIZE = 50
local DEFAULT_ICON_PADDING = 2
local BASE_SQUARE_MASK = "Interface\\AddOns\\CooldownManagerCentered\\Media\\Art\\Square"
local DEFAULT_MASK_TEXTURE = 6707800

-- Orientation anchor mapping for correct growth direction
local ORIENTATION_ANCHORS = {
    ["Horizontal Right"] = { primary = "LEFT", offsetX = 1, offsetY = 0 },
    ["Horizontal Left"] = { primary = "RIGHT", offsetX = -1, offsetY = 0 },
    ["Vertical Down"] = { primary = "TOP", offsetX = 0, offsetY = -1 },
    ["Vertical Up"] = { primary = "BOTTOM", offsetX = 0, offsetY = 1 },
}

local trackerAnchor = nil
local iconFrames = {}

local DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"

local function GetFontPath(fontName)
    if not fontName or fontName == "" then
        return DEFAULT_FONT_PATH
    end

    if LSM then
        local fontPath = LSM:Fetch("font", fontName)
        if fontPath then
            return fontPath
        end
    end
    return DEFAULT_FONT_PATH
end

local function GetStackFontName()
    if ns.db and ns.db.profile and ns.db.profile.cooldownManager_stackFontName then
        return ns.db.profile.cooldownManager_stackFontName
    end
    return "Friz Quadrata TT"
end

local function GetStackFontFlags()
    local fontFlags = ns.db.profile.cooldownManager_stackFontFlags or {}
    local fontFlag = ""
    for n, v in pairs(fontFlags) do
        if v == true then
            fontFlag = fontFlag .. n .. ","
        end
    end
    return fontFlag
end

local function IsSquareIconsEnabled()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_squareIcons) or false
end

local function GetBorderThickness()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_borderThickness) or 1
end

local function GetIconZoom()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_iconZoom) or 0.3
end

local function GetStackAnchor()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_stackAnchor) or "BOTTOMRIGHT"
end

local function GetStackFontSize()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_stackFontSize) or 14
end

local function GetStackOffsetX()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_stackOffsetX) or -1
end

local function GetStackOffsetY()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_stackOffsetY) or 1
end

-- Edit mode setting helpers
local function GetIconSize()
    if ns.db and ns.db.profile and ns.db.profile.editMode and ns.db.profile.editMode[CONFIG_KEY] then
        return ns.db.profile.editMode[CONFIG_KEY].iconSize or DEFAULT_ICON_SIZE
    end
    return DEFAULT_ICON_SIZE
end

local function GetIconPadding()
    if ns.db and ns.db.profile and ns.db.profile.editMode and ns.db.profile.editMode[CONFIG_KEY] then
        return ns.db.profile.editMode[CONFIG_KEY].iconPadding or DEFAULT_ICON_PADDING
    end
    return DEFAULT_ICON_PADDING
end

local function GetOrientation()
    if ns.db and ns.db.profile and ns.db.profile.editMode and ns.db.profile.editMode[CONFIG_KEY] then
        return ns.db.profile.editMode[CONFIG_KEY].orientation or "Horizontal Right"
    end
    return "Horizontal Right"
end

local function IsRacialIgnored(spellName)
    local ignoredRacials = (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_ignoredRacials) or {}
    return ignoredRacials[spellName] == true
end

local function IsItemIgnored(itemName)
    local ignoredItems = (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_ignoredItems) or {}
    return ignoredItems[itemName] == true
end

local function ApplySquareStyle(frame)
    local borderThickness = GetBorderThickness()
    local zoom = GetIconZoom()

    local crop = zoom * 0.5
    if frame.tex and frame.tex.SetTexCoord then
        frame.tex:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
    end

    if frame.cd then
        frame.cd:SetSwipeTexture(BASE_SQUARE_MASK)
        frame.cd:ClearAllPoints()
        frame.cd:SetPoint("TOPLEFT", frame, "TOPLEFT", borderThickness, -borderThickness)
        frame.cd:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -borderThickness, borderThickness)
    end

    if frame.mask then
        frame.mask:SetTexture(BASE_SQUARE_MASK)
        frame.mask:Show()
    end

    if not frame.cmcBorder then
        frame.cmcBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.cmcBorder:SetFrameLevel(frame:GetFrameLevel() + 1)
    end
    frame.cmcBorder:ClearAllPoints()
    frame.cmcBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.cmcBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    if borderThickness <= 0 then
        frame.cmcBorder:Hide()
    else
        frame.cmcBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = borderThickness,
        })
        frame.cmcBorder:SetBackdropBorderColor(0, 0, 0, 1)
        frame.cmcBorder:Show()
    end

    frame._cmcSquareStyled = true
end

local function RestoreDefaultStyle(frame)
    if frame.tex and frame.tex.SetTexCoord then
        frame.tex:SetTexCoord(0, 1, 0, 1)
    end

    if frame.cd then
        frame.cd:SetSwipeTexture(DEFAULT_MASK_TEXTURE)
        frame.cd:ClearAllPoints()
        frame.cd:SetAllPoints(frame)
    end

    if frame.mask then
        frame.mask:SetTexture(DEFAULT_MASK_TEXTURE)
        frame.mask:Show()
    end

    if frame.cmcBorder then
        frame.cmcBorder:Hide()
    end

    frame._cmcSquareStyled = false
end

local function ApplyStyleToFrame(frame)
    if IsSquareIconsEnabled() then
        ApplySquareStyle(frame)
    else
        RestoreDefaultStyle(frame)
    end
end

local function ApplyStackFontToFrame(frame)
    local fontName = GetStackFontName()
    local fontPath = GetFontPath(fontName)
    local fontFlags = GetStackFontFlags()
    local fontSize = GetStackFontSize()
    local anchor = GetStackAnchor()
    local offsetX = GetStackOffsetX()
    local offsetY = GetStackOffsetY()

    if frame.count then
        frame.count:SetFont(fontPath, fontSize, fontFlags)
        frame.count:ClearAllPoints()
        frame.count:SetPoint(anchor, frame, anchor, offsetX, offsetY)
    end

    if frame.charges then
        frame.charges:SetFont(fontPath, fontSize, fontFlags)
        frame.charges:ClearAllPoints()
        frame.charges:SetPoint(anchor, frame, anchor, offsetX, offsetY)
    end
end

local function CreateIconFrame(parent, index)
    local iconSize = GetIconSize()
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(iconSize, iconSize)
    frame:SetFrameStrata("MEDIUM")

    local cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    cd:SetAllPoints(frame)
    cd:SetDrawEdge(false)
    cd:SetHideCountdownNumbers(false)
    frame.cd = cd

    local tex = frame:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(frame)
    frame.tex = tex

    local mask = frame:CreateMaskTexture()
    mask:SetAllPoints(frame.tex)
    mask:SetTexture(DEFAULT_MASK_TEXTURE)
    frame.tex:AddMaskTexture(mask)
    frame.mask = mask

    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    overlay:SetFrameLevel(cd:GetFrameLevel() + 5)

    local count = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    count:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    count:SetShadowOffset(1, -1)
    count:SetShadowColor(0, 0, 0, 1)
    frame.count = count

    local charges = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    charges:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    charges:SetPoint("CENTER", frame, "TOP", 0, -1)
    charges:SetShadowOffset(1, -1)
    charges:SetShadowColor(0, 0, 0, 1)
    frame.charges = charges

    frame.layoutIndex = index
    frame:Hide()

    ApplyStyleToFrame(frame)
    ApplyStackFontToFrame(frame)

    return frame
end

local function UpdateIconPosition(frame, visibleIndex)
    local iconSize = GetIconSize()
    local padding = GetIconPadding()
    local orientation = GetOrientation()
    local anchorData = ORIENTATION_ANCHORS[orientation] or ORIENTATION_ANCHORS["Horizontal Right"]

    frame:ClearAllPoints()

    local offset = (visibleIndex - 1) * (iconSize + padding)
    local xOffset = anchorData.offsetX * offset
    local yOffset = anchorData.offsetY * offset

    frame:SetPoint(anchorData.primary, trackerAnchor, anchorData.primary, xOffset, yOffset)
end

local function SetupTrinketIcon(frame, slotIndex)
    local itemId = GetInventoryItemID("player", slotIndex)
    if not itemId then
        frame:Hide()
        frame.itemId = nil
        return false
    end

    if not C_Item.IsUsableItem(itemId) then
        frame:Hide()
        frame.itemId = nil
        return false
    end

    local itemIcon = C_Item.GetItemIconByID(itemId)
    frame.tex:SetTexture(itemIcon)
    frame.icon = itemIcon
    frame.itemId = itemId
    frame.slotIndex = slotIndex
    frame.trackerType = "trinket"

    local start, duration, enable = C_Item.GetItemCooldown(itemId)
    frame.cd:SetCooldown(start, duration)

    ApplyStyleToFrame(frame)
    ApplyStackFontToFrame(frame)

    frame:Show()
    return true
end

local function SetupItemIcon(frame, itemId, existingTextures)
    local count = C_Item.GetItemCount(itemId, false, true)
    if count <= 0 then
        frame:Hide()
        frame.itemId = nil
        return false
    end

    local itemName = C_Item.GetItemNameByID(itemId)
    if itemName and IsItemIgnored(itemName) then
        frame:Hide()
        frame.itemId = nil
        return false
    end

    local itemIcon = C_Item.GetItemIconByID(itemId)
    if existingTextures and existingTextures[itemIcon] then
        frame:Hide()
        frame.itemId = nil
        return false
    end
    frame.tex:SetTexture(itemIcon)
    frame.itemId = itemId
    frame.icon = itemIcon
    frame.trackerType = "item"

    frame.count:SetText(count)

    local start, duration, enable = C_Item.GetItemCooldown(itemId)
    frame.cd:SetCooldown(start, duration)

    ApplyStyleToFrame(frame)
    ApplyStackFontToFrame(frame)

    frame:Show()
    return true, frame.icon
end

local function SetupRacialIcon(frame, spellId)
    if not IsPlayerSpell(spellId) then
        frame:Hide()
        frame.spellId = nil
        return false
    end

    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if not spellInfo then
        frame:Hide()
        frame.spellId = nil
        return false
    end

    if spellInfo.name and IsRacialIgnored(spellInfo.name) then
        frame:Hide()
        frame.spellId = nil
        return false
    end

    frame.tex:SetTexture(spellInfo.iconID)
    frame.icon = spellInfo.iconID
    frame.spellId = spellId
    frame.trackerType = "racial"
    local chargesInfo = C_Spell.GetSpellCharges(frame.spellId)
    if chargesInfo then
        frame.charges:SetText(chargesInfo.currentCharges)
        frame.cd:SetCooldown(chargesInfo.cooldownStartTime, chargesInfo.cooldownDuration)
    else
        local cooldownInfo = C_Spell.GetSpellCooldown(frame.spellId)
        if cooldownInfo then
            frame.cd:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration)
        end
    end

    ApplyStyleToFrame(frame)
    ApplyStackFontToFrame(frame)

    frame:Show()
    return true
end

local function RefreshAllIcons()
    if not trackerAnchor then
        return
    end

    local iconSize = GetIconSize()
    local padding = GetIconPadding()
    local orientation = GetOrientation()
    local anchorData = ORIENTATION_ANCHORS[orientation] or ORIENTATION_ANCHORS["Horizontal Right"]
    local visibleIndex = 0
    local existingTextures = {}

    for _, frame in ipairs(iconFrames) do
        local isVisible = false
        local icon
        if frame.trackerType == "trinket" then
            isVisible = SetupTrinketIcon(frame, frame.slotIndex)
        elseif frame.trackerType == "item" then
            isVisible, icon = SetupItemIcon(frame, frame.itemIdConfig, existingTextures)
        elseif frame.trackerType == "racial" then
            isVisible = SetupRacialIcon(frame, frame.spellIdConfig)
        end
        if isVisible and icon then
            existingTextures[icon] = true
        end
        if isVisible then
            visibleIndex = visibleIndex + 1
            UpdateIconPosition(frame, visibleIndex)
        end
    end

    -- Calculate total dimensions based on orientation
    local isHorizontal = orientation == "Horizontal Right" or orientation == "Horizontal Left"
    local totalSize = visibleIndex > 0 and (visibleIndex * iconSize + (visibleIndex - 1) * padding) or iconSize

    if isHorizontal then
        trackerAnchor:SetSize(totalSize, iconSize)
    else
        trackerAnchor:SetSize(iconSize, totalSize)
    end
end

local function UpdateIconLayout()
    local iconSize = GetIconSize()

    for _, frame in ipairs(iconFrames) do
        frame:SetSize(iconSize, iconSize)
    end

    RefreshAllIcons()
end

local function UpdateItemCooldown(frame)
    local start, duration = C_Item.GetItemCooldown(frame.itemId)
    frame.cd:SetCooldown(start, duration)
end

local function UpdateCooldowns()
    for _, frame in ipairs(iconFrames) do
        if frame:IsShown() then
            if (frame.trackerType == "trinket" or frame.trackerType == "item") and frame.itemId then
                UpdateItemCooldown(frame)
                if frame.trackerType == "item" then
                    local count = C_Item.GetItemCount(frame.itemId, false, true)
                    frame.count:SetText(count)
                end
            elseif frame.trackerType == "racial" and frame.spellId then
                local chargesInfo = C_Spell.GetSpellCharges(frame.spellId)
                if chargesInfo then
                    frame.charges:SetText(chargesInfo.currentCharges)
                    frame.cd:SetCooldown(chargesInfo.cooldownStartTime, chargesInfo.cooldownDuration)
                else
                    local cooldownInfo = C_Spell.GetSpellCooldown(frame.spellId)
                    if cooldownInfo then
                        frame.cd:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration)
                    end
                end
            end
        end
    end
end

local function CreateTracker()
    if trackerAnchor then
        return
    end

    local DEFAULT_CONFIG = {
        point = "CENTER",
        x = 0,
        y = 200,
        scale = 1,
        strata = "MEDIUM",
        iconSize = DEFAULT_ICON_SIZE,
        iconPadding = DEFAULT_ICON_PADDING,
        orientation = "Horizontal Right",
    }

    WilduUICore.LoadFrameConfig(CONFIG_KEY, DEFAULT_CONFIG)
    local iconSize = GetIconSize()

    trackerAnchor = CreateFrame("Frame", "CMCTrinketRacialTracker", UIParent, "BackdropTemplate")
    trackerAnchor:SetSize(iconSize, iconSize)
    trackerAnchor:SetClampedToScreen(true)

    local frameIndex = 0

    -- Create trinket icon frames (slots 13 and 14)
    for _, slotIndex in ipairs({ 13, 14 }) do
        frameIndex = frameIndex + 1
        local frame = CreateIconFrame(trackerAnchor, frameIndex)
        frame.slotIndex = slotIndex
        frame.trackerType = "trinket"
        table.insert(iconFrames, frame)
    end

    for _, itemId in ipairs(ITEMS) do
        frameIndex = frameIndex + 1
        local frame = CreateIconFrame(trackerAnchor, frameIndex)
        frame.itemIdConfig = itemId
        frame.trackerType = "item"
        table.insert(iconFrames, frame)
    end

    for _, spellId in ipairs(RACIALS) do
        frameIndex = frameIndex + 1
        local frame = CreateIconFrame(trackerAnchor, frameIndex)
        frame.spellIdConfig = spellId
        frame.trackerType = "racial"
        table.insert(iconFrames, frame)
    end

    trackerAnchor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    trackerAnchor:RegisterEvent("BAG_UPDATE")
    trackerAnchor:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    trackerAnchor:RegisterEvent("SPELL_UPDATE_CHARGES")
    trackerAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
    trackerAnchor:RegisterEvent("PLAYER_TALENT_UPDATE")
    trackerAnchor:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    trackerAnchor:SetScript("OnEvent", function(self, event, arg1)
        if event == "PLAYER_EQUIPMENT_CHANGED" then
            if arg1 == 13 or arg1 == 14 then
                RefreshAllIcons()
            end
        elseif event == "BAG_UPDATE" then
            RefreshAllIcons()
        elseif event == "SPELL_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_CHARGES" then
            UpdateCooldowns()
        elseif
            event == "PLAYER_ENTERING_WORLD"
            or event == "PLAYER_TALENT_UPDATE"
            or event == "ACTIVE_TALENT_GROUP_CHANGED"
        then
            RefreshAllIcons()
        end
    end)

    -- Apply initial position from edit mode config
    -- Third parameter 'shouldHide' is true when tracker is disabled (feature not enabled)
    local shouldHide = not ns.db.profile.cooldownManager_experimental_trinketRacialTracker
    WilduUICore.ApplyFramePosition(trackerAnchor, CONFIG_KEY, shouldHide)

    -- Edit mode callbacks
    WilduUICore.RegisterEditModeCallbacks(trackerAnchor, CONFIG_KEY, function()
        return ns.db.profile.cooldownManager_experimental_trinketRacialTracker
    end)

    local RELATIVE_FACTORS = {
        LEFT = { x = 0, y = -0.5 },
        RIGHT = { x = -1, y = -0.5 },
        TOP = { x = -0.5, y = -1 },
        BOTTOM = { x = -0.5, y = 0 },
    }
    local function OnPositionChanged(frame, layoutName, _point, _x, _y)
        local orientation = GetOrientation()
        local anchorData = ORIENTATION_ANCHORS[orientation] or ORIENTATION_ANCHORS["Horizontal Right"]
        local anchor = (anchorData and anchorData.primary) or "RIGHT"

        local screenWidth, screenHeight = UIParent:GetSize()
        local frameWidth, frameHeight = frame:GetSize()
        local centerX, centerY = frame:GetCenter()

        if not centerX or not centerY or not frameWidth or not frameHeight then
            return
        end

        local frameScale = frame:GetEffectiveScale()
        local uiParentScale = UIParent:GetEffectiveScale()
        local scale = frameScale / uiParentScale

        centerX, centerY = centerX, centerY
        screenWidth, screenHeight = screenWidth / scale, screenHeight / scale
        frameWidth, frameHeight = frameWidth, frameHeight

        local newX, newY
        local factor = RELATIVE_FACTORS[anchor]

        if anchor == "LEFT" then
            newX = centerX - frameWidth / 2
            newY = centerY + (screenHeight * factor.y)
        elseif anchor == "RIGHT" then
            newX = centerX + frameWidth / 2 - screenWidth
            newY = centerY + (screenHeight * factor.y)
        elseif anchor == "TOP" then
            newX = centerX + (screenWidth * factor.x)
            newY = centerY + frameHeight / 2 - screenHeight
        elseif anchor == "BOTTOM" then
            newX = centerX + (screenWidth * factor.x)
            newY = centerY - frameHeight / 2
        end

        ns.db.profile.editMode[CONFIG_KEY].point = anchor
        ns.db.profile.editMode[CONFIG_KEY].x = newX
        ns.db.profile.editMode[CONFIG_KEY].y = newY

        WilduUICore.ApplyFramePosition(frame, CONFIG_KEY, false)
    end
    -- Edit mode settings
    local additionalSettings = {
        {
            name = "Icon Size",
            kind = LEM.SettingType.Slider,
            default = DEFAULT_ICON_SIZE,
            get = function()
                return ns.db.profile.editMode[CONFIG_KEY].iconSize or DEFAULT_ICON_SIZE
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[CONFIG_KEY].iconSize = value
                UpdateIconLayout()
            end,
            minValue = 16,
            maxValue = 80,
            valueStep = 2,
            formatter = function(value)
                return string.format("%d px", value)
            end,
        },
        {
            name = "Icon Padding",
            kind = LEM.SettingType.Slider,
            default = DEFAULT_ICON_PADDING,
            get = function()
                return ns.db.profile.editMode[CONFIG_KEY].iconPadding or DEFAULT_ICON_PADDING
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[CONFIG_KEY].iconPadding = value
                RefreshAllIcons()
            end,
            minValue = 0,
            maxValue = 20,
            valueStep = 1,
            formatter = function(value)
                return string.format("%d px", value)
            end,
        },
        {
            name = "Orientation",
            kind = LEM.SettingType.Dropdown,
            default = "Horizontal Right",
            get = function()
                return ns.db.profile.editMode[CONFIG_KEY].orientation or "Horizontal Right"
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[CONFIG_KEY].orientation = value
                OnPositionChanged(trackerAnchor, CONFIG_KEY)
                RefreshAllIcons()
            end,
            values = {
                { text = "Horizontal Right" },
                { text = "Horizontal Left" },
                { text = "Vertical Down" },
                { text = "Vertical Up" },
            },
        },
    }

    WilduUICore.RegisterFrameWithLEM(trackerAnchor, CONFIG_KEY, additionalSettings, OnPositionChanged)

    RefreshAllIcons()
end

local function DestroyTracker()
    if not trackerAnchor then
        return
    end

    trackerAnchor:UnregisterAllEvents()
    trackerAnchor:Hide()

    for _, frame in ipairs(iconFrames) do
        frame:Hide()
    end
end

local isInitialized = false

function TrinketRacialTracker:Initialize()
    if isInitialized then
        if trackerAnchor then
            WilduUICore.ApplyFramePosition(
                trackerAnchor,
                CONFIG_KEY,
                not ns.db.profile.cooldownManager_experimental_trinketRacialTracker
            )
        end
        return
    end

    if not ns.db or not ns.db.profile then
        return
    end

    if not ns.db.profile.cooldownManager_experimental_trinketRacialTracker then
        return
    end

    isInitialized = true
    CreateTracker()
end

function TrinketRacialTracker:OnSettingChanged()
    if ns.db.profile.cooldownManager_experimental_trinketRacialTracker then
        if not isInitialized then
            isInitialized = true
            CreateTracker()
        else
            WilduUICore.ApplyFramePosition(trackerAnchor, CONFIG_KEY, false)
            RefreshAllIcons()
        end
    else
        if trackerAnchor then
            WilduUICore.ApplyFramePosition(trackerAnchor, CONFIG_KEY, true)
        end
    end
end

function TrinketRacialTracker:RefreshStyling()
    if not trackerAnchor then
        return
    end

    for _, frame in ipairs(iconFrames) do
        if frame:IsShown() then
            ApplyStyleToFrame(frame)
            ApplyStackFontToFrame(frame)
        end
    end
end

function TrinketRacialTracker:RefreshAll()
    if trackerAnchor then
        RefreshAllIcons()
    end
end
