local _, ns = ...

local DB = ns.TrackerDB
local ItemsData = ns.TrackerItemsData
local ItemVisuals = ns.TrackerItemVisuals
local WilduUICore = ns.WilduUICore
local LSM = LibStub("LibSharedMedia-3.0", true)
local LEM = LibStub("LibEQOLEditMode-1.0")

local ItemViewer = ns.TrackerItemViewer or {}
ns.TrackerItemViewer = ItemViewer

local DEFAULT_ICON_SIZE = 50
local DEFAULT_ICON_PADDING = 2
local BASE_SQUARE_MASK = "Interface\\AddOns\\CooldownManagerCentered\\Media\\Art\\Square"
local DEFAULT_MASK_TEXTURE = 6707800
local DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"

local ORIENTATION_ANCHORS = {
    ["Horizontal Right"] = { primary = "LEFT", offsetX = 1, offsetY = 0 },
    ["Horizontal Left"] = { primary = "RIGHT", offsetX = -1, offsetY = 0 },
    ["Vertical Down"] = { primary = "TOP", offsetX = 0, offsetY = -1 },
    ["Vertical Up"] = { primary = "BOTTOM", offsetX = 0, offsetY = 1 },
}

local function IsSquareIconsEnabled()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_squareIcons) or false
end

local function GetBorderThickness()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_borderThickness) or 1
end

local function GetIconZoom()
    return (ns.db and ns.db.profile and ns.db.profile.trinketRacialTracker_iconZoom) or 0.3
end

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

local function ApplySquareStyle(frame)
    local borderThickness = GetBorderThickness()
    local zoom = GetIconZoom()
    local crop = zoom * 0.5

    if frame.Icon and frame.Icon.SetTexCoord then
        frame.Icon:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
    end

    if frame.Cooldown then
        frame.Cooldown:SetSwipeTexture(BASE_SQUARE_MASK)
        frame.Cooldown:ClearAllPoints()
        frame.Cooldown:SetPoint("TOPLEFT", frame, "TOPLEFT", borderThickness, -borderThickness)
        frame.Cooldown:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -borderThickness, borderThickness)
    end

    if frame.mask then
        frame.mask:SetTexture(BASE_SQUARE_MASK)
        frame.mask:Show()
    else
        local mask = frame:CreateMaskTexture()
        mask:SetAllPoints(frame.Icon)
        mask:SetTexture(BASE_SQUARE_MASK)
        frame.Icon:AddMaskTexture(mask)
        frame.mask = mask
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
    frame._CMC_SquareStyle = true
end

local function RestoreDefaultStyle(frame)
    if not frame._CMC_SquareStyle then
        return
    end
    if frame.Icon and frame.Icon.SetTexCoord then
        frame.Icon:SetTexCoord(0, 1, 0, 1)
    end

    if frame.Cooldown then
        frame.Cooldown:SetSwipeTexture(DEFAULT_MASK_TEXTURE)
        frame.Cooldown:ClearAllPoints()
        frame.Cooldown:SetAllPoints(frame)
    end

    if frame.cmcBorder then
        frame.cmcBorder:Hide()
    end
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

local ItemViewerFrame = {}
ItemViewerFrame.__index = ItemViewerFrame

function ItemViewerFrame:New(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("MEDIUM")
    local obj = setmetatable({ frame = frame }, ItemViewerFrame)
    obj:Initialize()
    return obj
end

function ItemViewerFrame:Initialize()
    local frame = self.frame
    if not frame.Icon then
        frame.Icon = frame:CreateTexture(nil, "ARTWORK")
        frame.Icon:SetAllPoints()
        frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    if not frame.Cooldown then
        frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        frame.Cooldown:SetAllPoints()
        frame.Cooldown:SetDrawEdge(false)
        frame.Cooldown:SetSwipeTexture(DEFAULT_MASK_TEXTURE)
        frame.Cooldown:SetHideCountdownNumbers(false)
    end
    if not frame.mask then
        local mask = frame:CreateMaskTexture()
        mask:SetAllPoints(frame.Icon)
        mask:SetTexture(DEFAULT_MASK_TEXTURE)
        frame.Icon:AddMaskTexture(mask)
        frame.mask = mask
    end

    if not frame.count then
        local overlay = CreateFrame("Frame", nil, frame)
        overlay:SetAllPoints(frame)
        overlay:SetFrameLevel(frame.Cooldown:GetFrameLevel() + 5)

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
    end
    ApplyStyleToFrame(frame)
    ApplyStackFontToFrame(frame)
    frame:Hide()
end

function ItemViewerFrame:Show()
    self.frame:Show()
end

function ItemViewerFrame:Hide()
    self.frame:Hide()
end

function ItemViewerFrame:UpdateEntry(entry)
    local frame = self.frame
    if not entry then
        frame._CMCTracker_EntryKind = nil
        frame._CMCTracker_EntryID = nil
        frame:Hide()
        return
    end

    frame._CMCTracker_EntryKind = entry.kind
    frame._CMCTracker_EntryID = entry.id

    ItemVisuals:ApplyEntryIcon(frame, entry.kind, entry.id)
    ItemVisuals:UpdateEntryCooldown(frame, entry.kind, entry.id)
    ApplyStyleToFrame(frame)
    ApplyStackFontToFrame(frame)

    frame:Show()
end

function ItemViewerFrame:UpdateCooldown()
    local frame = self.frame
    if not frame:IsShown() or not frame._CMCTracker_EntryKind or not frame._CMCTracker_EntryID then
        return
    end
    ItemVisuals:UpdateEntryCooldown(frame, frame._CMCTracker_EntryKind, frame._CMCTracker_EntryID)
end

local function GetConfigValue(configKey, key, default)
    if ns.db and ns.db.profile and ns.db.profile.editMode and ns.db.profile.editMode[configKey] then
        return ns.db.profile.editMode[configKey][key] or default
    end
    return default
end

local function EntriesMatch(a, b)
    if #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i].kind ~= b[i].kind or a[i].id ~= b[i].id then
            return false
        end
    end
    return true
end

local TrackerInstance = {}
TrackerInstance.__index = TrackerInstance

function TrackerInstance:New(configKey, frameName, getEntriesFn)
    local instance = setmetatable({
        configKey = configKey,
        frameName = frameName,
        getEntriesFn = getEntriesFn,
        anchor = nil,
        iconFrames = {},
        cachedEntries = {},
    }, TrackerInstance)
    return instance
end

function TrackerInstance:GetIconSize()
    return GetConfigValue(self.configKey, "iconSize", DEFAULT_ICON_SIZE)
end

function TrackerInstance:GetIconPadding()
    return GetConfigValue(self.configKey, "iconPadding", DEFAULT_ICON_PADDING)
end

function TrackerInstance:GetOrientation()
    return GetConfigValue(self.configKey, "orientation", "Horizontal Right")
end

function TrackerInstance:UpdateIconPosition(frame, visibleIndex)
    local iconSize = self:GetIconSize()
    local padding = self:GetIconPadding()
    local orientation = self:GetOrientation()
    local anchorData = ORIENTATION_ANCHORS[orientation] or ORIENTATION_ANCHORS["Horizontal Right"]

    frame:ClearAllPoints()
    local offset = (visibleIndex - 1) * (iconSize + padding)
    frame:SetPoint(
        anchorData.primary,
        self.anchor,
        anchorData.primary,
        anchorData.offsetX * offset,
        anchorData.offsetY * offset
    )
end

function TrackerInstance:UpdateCooldowns()
    for _, ivf in ipairs(self.iconFrames) do
        ivf:UpdateCooldown()
    end
end

function TrackerInstance:RefreshEntries(forceRefresh)
    if not self.anchor then
        return
    end

    local owned = ItemsData:ScanOwnedItems()
    ItemsData:EnsureTrackedItems(owned)
    local entries = self.getEntriesFn(owned)

    if not forceRefresh and EntriesMatch(entries, self.cachedEntries) then
        self:UpdateCooldowns()
        return
    end
    self.cachedEntries = entries

    local iconSize = self:GetIconSize()
    local padding = self:GetIconPadding()
    local orientation = self:GetOrientation()
    local count = #entries

    for i = 1, count do
        if not self.iconFrames[i] then
            self.iconFrames[i] = ItemViewerFrame:New(self.anchor)
        end
        local ivf = self.iconFrames[i]
        ivf.frame:SetSize(iconSize, iconSize)

        local db = DB.GetDB()
        if ivf.frame.Cooldown then
            ivf.frame.Cooldown:SetSwipeColor(unpack(DB.DEFAULT_COOLDOWN_SWIPE_COLOR))
            ivf.frame.Cooldown:SetDrawEdge(false)
        end

        ivf:UpdateEntry(entries[i])
        self:UpdateIconPosition(ivf.frame, i)
    end

    for i = count + 1, #self.iconFrames do
        self.iconFrames[i]:UpdateEntry(nil)
    end

    local isHorizontal = orientation == "Horizontal Right" or orientation == "Horizontal Left"
    local totalSize = count > 0 and (count * iconSize + (count - 1) * padding) or iconSize
    if isHorizontal then
        self.anchor:SetSize(totalSize, iconSize)
    else
        self.anchor:SetSize(iconSize, totalSize)
    end

    self.anchor:SetShown(count > 0 or self.anchor._CMCTracker_ForceShow)
end

function TrackerInstance:RefreshStyling()
    for _, ivf in ipairs(self.iconFrames) do
        if ivf.frame:IsShown() then
            ApplyStyleToFrame(ivf.frame)
            ApplyStackFontToFrame(ivf.frame)
        end
    end
end

function TrackerInstance:UpdateIconLayout()
    local iconSize = self:GetIconSize()
    for _, ivf in ipairs(self.iconFrames) do
        ivf.frame:SetSize(iconSize, iconSize)
    end
    self:RefreshEntries(true)
end

function TrackerInstance:Create()
    if self.anchor then
        return
    end

    local DEFAULT_CONFIG = {
        alpha = 1,
        point = "CENTER",
        x = 0,
        y = 200,
        scale = 1,
        strata = "MEDIUM",
        iconSize = DEFAULT_ICON_SIZE,
        iconPadding = DEFAULT_ICON_PADDING,
        orientation = "Horizontal Right",
    }

    WilduUICore.LoadFrameConfig(self.configKey, DEFAULT_CONFIG)
    local iconSize = self:GetIconSize()

    self.anchor = CreateFrame("Frame", self.frameName, UIParent, "BackdropTemplate")
    self.anchor:SetSize(iconSize, iconSize)
    self.anchor:SetClampedToScreen(true)

    self.anchor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self.anchor:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self.anchor:RegisterEvent("SPELL_UPDATE_CHARGES")
    self.anchor:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.anchor:RegisterEvent("PLAYER_TALENT_UPDATE")
    self.anchor:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    self.anchor:SetScript("OnEvent", function(_, event, arg1)
        if event == "SPELL_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_CHARGES" then
            self:UpdateCooldowns()
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            self:RefreshEntries(false)
        else
            self:RefreshEntries(true)
        end
    end)

    WilduUICore.ApplyFramePosition(self.anchor, self.configKey, false)

    WilduUICore.RegisterEditModeCallbacks(self.anchor, self.configKey, function()
        return true
    end)

    local configKey = self.configKey
    local anchor = self.anchor
    local instance = self

    local RELATIVE_FACTORS = {
        LEFT = { x = 0, y = -0.5 },
        RIGHT = { x = -1, y = -0.5 },
        TOP = { x = -0.5, y = -1 },
        BOTTOM = { x = -0.5, y = 0 },
    }

    local function OnPositionChanged(frame, layoutName, _point, _x, _y)
        local orientation = instance:GetOrientation()
        local anchorData = ORIENTATION_ANCHORS[orientation] or ORIENTATION_ANCHORS["Horizontal Right"]
        local anchorPrimary = (anchorData and anchorData.primary) or "RIGHT"

        local screenWidth, screenHeight = UIParent:GetSize()
        local frameWidth, frameHeight = frame:GetSize()
        local centerX, centerY = frame:GetCenter()

        if not centerX or not centerY or not frameWidth or not frameHeight then
            return
        end

        local frameScale = frame:GetEffectiveScale()
        local uiParentScale = UIParent:GetEffectiveScale()
        local scale = frameScale / uiParentScale

        screenWidth, screenHeight = screenWidth / scale, screenHeight / scale

        local newX, newY
        local factor = RELATIVE_FACTORS[anchorPrimary]

        if anchorPrimary == "LEFT" then
            newX = centerX - frameWidth / 2
            newY = centerY + (screenHeight * factor.y)
        elseif anchorPrimary == "RIGHT" then
            newX = centerX + frameWidth / 2 - screenWidth
            newY = centerY + (screenHeight * factor.y)
        elseif anchorPrimary == "TOP" then
            newX = centerX + (screenWidth * factor.x)
            newY = centerY + frameHeight / 2 - screenHeight
        elseif anchorPrimary == "BOTTOM" then
            newX = centerX + (screenWidth * factor.x)
            newY = centerY - frameHeight / 2
        end

        ns.db.profile.editMode[configKey].point = anchorPrimary
        ns.db.profile.editMode[configKey].x = newX
        ns.db.profile.editMode[configKey].y = newY

        WilduUICore.ApplyFramePosition(frame, configKey, false)
    end

    local additionalSettings = {
        {
            name = "Icon Size",
            kind = LEM.SettingType.Slider,
            default = DEFAULT_ICON_SIZE,
            get = function()
                return ns.db.profile.editMode[configKey].iconSize or DEFAULT_ICON_SIZE
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[configKey].iconSize = value
                instance:UpdateIconLayout()
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
                return ns.db.profile.editMode[configKey].iconPadding or DEFAULT_ICON_PADDING
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[configKey].iconPadding = value
                instance:RefreshEntries(true)
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
            default = DEFAULT_CONFIG.orientation,
            get = function()
                return ns.db.profile.editMode[configKey].orientation or DEFAULT_CONFIG.orientation
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[configKey].orientation = value
                OnPositionChanged(anchor, configKey)
                instance:RefreshEntries(true)
            end,
            values = {
                { text = "Horizontal Right" },
                { text = "Horizontal Left" },
                { text = "Vertical Down" },
                { text = "Vertical Up" },
            },
        },
        {
            name = "Alpha",
            kind = LEM.SettingType.Slider,
            default = DEFAULT_CONFIG.alpha,
            get = function()
                return ns.db.profile.editMode[configKey].alpha or DEFAULT_CONFIG.alpha
            end,
            set = function(layoutName, value)
                ns.db.profile.editMode[configKey].alpha = value
                anchor:SetAlpha(value)
            end,
            minValue = 0.1,
            maxValue = 1,
            valueStep = 0.01,
            formatter = function(value)
                return string.format("%.2f", value)
            end,
        },
    }

    WilduUICore.RegisterFrameWithLEM(self.anchor, self.configKey, additionalSettings, OnPositionChanged)

    self:RefreshEntries(true)
end

local tracker1 = TrackerInstance:New("tracker1", "CMCTracker1", function(owned)
    return ItemsData:GetTracker1Entries(owned)
end)

local tracker2 = TrackerInstance:New("tracker2", "CMCTracker2", function(owned)
    return ItemsData:GetTracker2Entries(owned)
end)

local trackers = { tracker1, tracker2 }

function ItemViewer:RefreshItemViewerFrames()
    for _, tracker in ipairs(trackers) do
        tracker:RefreshEntries(false)
    end
end

function ItemViewer:RefreshStyling()
    for _, tracker in ipairs(trackers) do
        tracker:RefreshStyling()
    end
end

function ItemViewer:Initialize()
    if not ns.db.profile.tracker_enabled then
        return
    end
    for _, tracker in ipairs(trackers) do
        tracker:Create()
    end
end
