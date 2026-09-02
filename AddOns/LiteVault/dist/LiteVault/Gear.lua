local _, lv = ...

local PANEL_WIDTH = 446
local PANEL_HEIGHT = 500
local SLOT_SIZE = 42
local SLOT_STEP = 56
local HEADER_RIGHT_INSET = 12
local HEADER_TOP_INSET = 12
local UPDATED_TEXT_WIDTH = 120

local gearPanel
local currentGearChar

local GEAR_SLOT_ORDER = {
    { slotID = 1, global = "HEADSLOT", fallback = "Head", inventorySlot = "HeadSlot" },
    { slotID = 2, global = "NECKSLOT", fallback = "Neck", inventorySlot = "NeckSlot" },
    { slotID = 3, global = "SHOULDERSLOT", fallback = "Shoulder", inventorySlot = "ShoulderSlot" },
    { slotID = 5, global = "CHESTSLOT", fallback = "Chest", inventorySlot = "ChestSlot" },
    { slotID = 6, global = "WAISTSLOT", fallback = "Waist", inventorySlot = "WaistSlot" },
    { slotID = 7, global = "LEGSSLOT", fallback = "Legs", inventorySlot = "LegsSlot" },
    { slotID = 8, global = "FEETSLOT", fallback = "Feet", inventorySlot = "FeetSlot" },
    { slotID = 9, global = "WRISTSLOT", fallback = "Wrist", inventorySlot = "WristSlot" },
    { slotID = 10, global = "HANDSSLOT", fallback = "Hands", inventorySlot = "HandsSlot" },
    { slotID = 11, global = "FINGER0SLOT", fallback = "Finger 1", inventorySlot = "Finger0Slot" },
    { slotID = 12, global = "FINGER1SLOT", fallback = "Finger 2", inventorySlot = "Finger1Slot" },
    { slotID = 13, global = "TRINKET0SLOT", fallback = "Trinket 1", inventorySlot = "Trinket0Slot" },
    { slotID = 14, global = "TRINKET1SLOT", fallback = "Trinket 2", inventorySlot = "Trinket1Slot" },
    { slotID = 15, global = "BACKSLOT", fallback = "Back", inventorySlot = "BackSlot" },
    { slotID = 16, global = "MAINHANDSLOT", fallback = "Main Hand", inventorySlot = "MainHandSlot" },
    { slotID = 17, global = "SECONDARYHANDSLOT", fallback = "Off Hand", inventorySlot = "SecondaryHandSlot" },
}

local SLOT_LAYOUT = {
    [1] = { point = "TOPLEFT", x = 28, y = -88 },
    [2] = { point = "TOPLEFT", x = 28, y = -88 - (1 * SLOT_STEP) },
    [3] = { point = "TOPLEFT", x = 28, y = -88 - (2 * SLOT_STEP) },
    [15] = { point = "TOPLEFT", x = 28, y = -88 - (3 * SLOT_STEP) },
    [5] = { point = "TOPLEFT", x = 28, y = -88 - (4 * SLOT_STEP) },
    [9] = { point = "TOPLEFT", x = 28, y = -88 - (5 * SLOT_STEP) },
    [10] = { point = "TOPLEFT", x = 28, y = -88 - (6 * SLOT_STEP) },

    [6] = { point = "TOPRIGHT", x = -28, y = -88 },
    [7] = { point = "TOPRIGHT", x = -28, y = -88 - (1 * SLOT_STEP) },
    [8] = { point = "TOPRIGHT", x = -28, y = -88 - (2 * SLOT_STEP) },
    [11] = { point = "TOPRIGHT", x = -28, y = -88 - (3 * SLOT_STEP) },
    [12] = { point = "TOPRIGHT", x = -28, y = -88 - (4 * SLOT_STEP) },
    [13] = { point = "TOPRIGHT", x = -28, y = -88 - (5 * SLOT_STEP) },
    [14] = { point = "TOPRIGHT", x = -28, y = -88 - (6 * SLOT_STEP) },

    [16] = { point = "BOTTOM", x = -38, y = 76 },
    [17] = { point = "BOTTOM", x = 38, y = 76 },
}

local LEFT_COLUMN_SLOTS = {
    [1] = true, [2] = true, [3] = true, [15] = true, [5] = true, [9] = true, [10] = true,
}

local RIGHT_COLUMN_SLOTS = {
    [6] = true, [7] = true, [8] = true, [11] = true, [12] = true, [13] = true, [14] = true,
}

local WEAPON_SLOTS = {
    [16] = true, [17] = true,
}

local STATS_GOLD_R = 1
local STATS_GOLD_G = 0.82
local STATS_GOLD_B = 0

local function T(key, fallback)
    local value = lv.L and lv.L[key]
    if value and value ~= "" and value ~= key then
        return value
    end
    local enUS = lv.LocaleData and lv.LocaleData["enUS"]
    local baseValue = enUS and enUS[key]
    if baseValue and baseValue ~= "" then
        return baseValue
    end
    return fallback or key
end

local function GetGearLabel()
    return T("BUTTON_GEAR", "Gear")
end

local function GetEmptyLabel()
    return T("LABEL_EMPTY", "Empty")
end

local function GetGearSlotLabel(slotDef)
    if not slotDef then
        return ""
    end
    if slotDef.slotID >= 11 and slotDef.slotID <= 14 then
        local globalLabel = slotDef.global and _G[slotDef.global]
        local baseLabel = globalLabel or slotDef.fallback
        local ordinal = (slotDef.slotID == 11 or slotDef.slotID == 13) and 1 or 2
        return string.format(T("LABEL_INVENTORY_SLOT_NUMBER_FMT", "%s %d"), baseLabel, ordinal)
    end

    local globalLabel = slotDef and slotDef.global and _G[slotDef.global]
    if type(globalLabel) == "string" and globalLabel ~= "" then
        return globalLabel
    end
    return slotDef and slotDef.fallback or ""
end

local function GetCharacterClassColor(classTag)
    return C_ClassColor.GetClassColor(classTag or "WARRIOR") or C_ClassColor.GetClassColor("WARRIOR")
end

local function GetClassCoords(classTag)
    if type(CLASS_ICON_TCOORDS) == "table" and classTag and CLASS_ICON_TCOORDS[classTag] then
        return unpack(CLASS_ICON_TCOORDS[classTag])
    end
    return 0, 1, 0, 1
end

local function BuildUpdatedText(timestamp)
    if not timestamp then
        return T("TEXT_GEAR_UPDATED_NEVER", "Updated: Never")
    end

    local age = SecondsToTime(math.max(0, time() - timestamp), false, true, 1)
    return string.format(T("TEXT_GEAR_UPDATED_AGO_FMT", "Updated %s ago"), age)
end

local function GetSlotEntry(gearData, slotID)
    if not gearData then
        return nil
    end

    for _, entry in ipairs(gearData) do
        if entry and entry.slotID == slotID then
            return entry
        end
    end

    return nil
end

local function GetPanelTitle(charKey, db)
    local classColor = GetCharacterClassColor(db and db.class)
    local nameOnly = (charKey and charKey:match("^([^-]+)")) or charKey or "Unknown"
    return string.format("%s's %s", classColor:WrapTextInColorCode(nameOnly), GetGearLabel())
end

local function GetCenterName(charKey)
    return (charKey and charKey:match("^([^-]+)")) or charKey or "Unknown"
end

local function GetCenterIdentity(db)
    local raceText = db and db.race or ""
    local specText = db and db.specName or ""

    if raceText == "Scourge" then
        raceText = "Undead"
    end

    if raceText ~= "" and specText ~= "" then
        return string.format("%s | %s", raceText, specText)
    end
    if raceText ~= "" then
        return raceText
    end
    if specText ~= "" then
        return specText
    end

    return ""
end

local function BuildCombatStatsRowData(combatStats)
    if type(combatStats) ~= "table" then
        return nil
    end

    local function fmtPercent(value)
        value = tonumber(value) or 0
        return string.format("%.2f%%", value)
    end

    return {
        { label = "Crit", rating = tostring(tonumber(combatStats.critRating) or 0), percent = fmtPercent(combatStats.critPercent) },
        { label = "Haste", rating = tostring(tonumber(combatStats.hasteRating) or 0), percent = fmtPercent(combatStats.hastePercent) },
        { label = "Mastery", rating = tostring(tonumber(combatStats.masteryRating) or 0), percent = fmtPercent(combatStats.masteryPercent) },
        { label = "Vers", rating = tostring(tonumber(combatStats.versRating) or 0), percent = fmtPercent(combatStats.versPercent) },
    }
end

local function ApplyGearPanelTheme(frame, theme)
    frame:SetBackdropColor(unpack(theme.backgroundSolid or theme.background))
    lv.ApplyBorderStyle(frame, "panel", theme)
end

local function ApplyGearCloseButtonTheme(btn, theme)
    btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    if btn.Text then
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
end

local function ApplyCenterIconFrameTheme(frame, theme)
    frame:SetBackdropColor(unpack(theme.background))
    frame:SetBackdropBorderColor(unpack(theme.portraitBorder or theme.borderPrimary))
end

local function ApplyCombatStatsBlockTheme(frame, theme)
    if not frame then
        return
    end

    if frame.header then
        frame.header:SetTextColor(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B)
    end
    if frame.topLeftLine then
        frame.topLeftLine:SetColorTexture(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B, 0.85)
    end
    if frame.topRightLine then
        frame.topRightLine:SetColorTexture(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B, 0.85)
    end
    if frame.leftDiamond then
        frame.leftDiamond:SetColorTexture(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B, 0.95)
    end
    if frame.rightDiamond then
        frame.rightDiamond:SetColorTexture(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B, 0.95)
    end
    if frame.bottomDivider then
        frame.bottomDivider:SetColorTexture(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B, 0.75)
    end
    if frame.bottomDiamond then
        frame.bottomDiamond:SetColorTexture(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B, 0.95)
    end

    if frame.rows then
        for _, row in ipairs(frame.rows) do
            if row.labelText then
                row.labelText:SetTextColor(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B)
            end
            if row.ratingText then
                row.ratingText:SetTextColor(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B)
            end
            if row.percentText then
                row.percentText:SetTextColor(STATS_GOLD_R, STATS_GOLD_G, STATS_GOLD_B)
            end
        end
    end
end

local function CreateCombatStatRow(parent, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(174, 18)
    row:SetPoint("TOP", parent, "TOP", 0, yOffset)

    row.labelText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.labelText:SetPoint("LEFT", row, "LEFT", 4, 0)
    row.labelText:SetWidth(62)
    row.labelText:SetJustifyH("LEFT")

    row.ratingText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.ratingText:SetPoint("RIGHT", row, "RIGHT", -68, 0)
    row.ratingText:SetWidth(36)
    row.ratingText:SetJustifyH("RIGHT")

    row.percentText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.percentText:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.percentText:SetWidth(56)
    row.percentText:SetJustifyH("RIGHT")

    return row
end

local function SetCombatStatRows(frame, rowData)
    if not frame or not frame.rows then
        return
    end

    if type(rowData) ~= "table" then
        if frame.header then
            frame.header:SetText("")
        end
        for _, row in ipairs(frame.rows) do
            row.labelText:SetText("")
            row.ratingText:SetText("")
            row.percentText:SetText("")
        end
        frame:Hide()
        return
    end

    if frame.header then
        frame.header:SetText(T("LABEL_STATS", "Stats"))
    end

    for index, row in ipairs(frame.rows) do
        local entry = rowData[index]
        if entry then
            row.labelText:SetText(entry.label or "")
            row.ratingText:SetText(entry.rating or "")
            row.percentText:SetText(entry.percent or "")
        else
            row.labelText:SetText("")
            row.ratingText:SetText("")
            row.percentText:SetText("")
        end
    end

    frame:Show()
end

local function CreateCombatStatsContainer(parent)
    local statsFrame = CreateFrame("Frame", nil, parent)
    statsFrame:SetSize(178, 116)
    statsFrame:SetClipsChildren(true)
    statsFrame:Hide()

    statsFrame.header = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsFrame.header:SetPoint("TOP", statsFrame, "TOP", 0, -2)
    statsFrame.header:SetJustifyH("CENTER")

    statsFrame.leftDiamond = statsFrame:CreateTexture(nil, "BORDER")
    statsFrame.leftDiamond:SetSize(5, 5)
    statsFrame.leftDiamond:SetPoint("RIGHT", statsFrame.header, "LEFT", -8, 0)
    statsFrame.leftDiamond:SetRotation(math.rad(45))

    statsFrame.rightDiamond = statsFrame:CreateTexture(nil, "BORDER")
    statsFrame.rightDiamond:SetSize(5, 5)
    statsFrame.rightDiamond:SetPoint("LEFT", statsFrame.header, "RIGHT", 8, 0)
    statsFrame.rightDiamond:SetRotation(math.rad(45))

    statsFrame.topLeftLine = statsFrame:CreateTexture(nil, "BORDER")
    statsFrame.topLeftLine:SetSize(44, 1)
    statsFrame.topLeftLine:SetPoint("RIGHT", statsFrame.leftDiamond, "LEFT", -6, 0)

    statsFrame.topRightLine = statsFrame:CreateTexture(nil, "BORDER")
    statsFrame.topRightLine:SetSize(44, 1)
    statsFrame.topRightLine:SetPoint("LEFT", statsFrame.rightDiamond, "RIGHT", 6, 0)

    statsFrame.bottomDivider = statsFrame:CreateTexture(nil, "BORDER")
    statsFrame.bottomDivider:SetSize(140, 1)
    statsFrame.bottomDivider:SetPoint("BOTTOM", statsFrame, "BOTTOM", 0, 1)

    statsFrame.bottomDiamond = statsFrame:CreateTexture(nil, "BORDER")
    statsFrame.bottomDiamond:SetSize(5, 5)
    statsFrame.bottomDiamond:SetPoint("CENTER", statsFrame.bottomDivider, "CENTER", 0, 0)
    statsFrame.bottomDiamond:SetRotation(math.rad(45))

    statsFrame.rows = {
        CreateCombatStatRow(statsFrame, -28),
        CreateCombatStatRow(statsFrame, -46),
        CreateCombatStatRow(statsFrame, -64),
        CreateCombatStatRow(statsFrame, -82),
    }

    return statsFrame
end

local function SetItemTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if self.link then
        GameTooltip:SetHyperlink(self.link)
    else
        GameTooltip:SetText(self.emptyText or GetEmptyLabel())
    end
    GameTooltip:Show()
end

local function ClearItemTooltip()
    GameTooltip:Hide()
end

local function ApplyItemLevelText(slot, itemLevel, quality)
    if not slot or not slot.itemLevelText then
        return
    end

    if itemLevel and itemLevel > 0 then
        slot.itemLevelText:SetText(tostring(itemLevel))
        if quality ~= nil then
            local r, g, b = GetItemQualityColor(quality)
            slot.itemLevelText:SetTextColor(r, g, b)
        else
            slot.itemLevelText:SetTextColor(1, 1, 1)
        end
    else
        slot.itemLevelText:SetText("")
        slot.itemLevelText:SetTextColor(1, 1, 1)
    end
end

local function ResolveEntryItemLevel(entry)
    if not entry then
        return nil
    end

    if entry.itemLevel and entry.itemLevel > 0 then
        return entry.itemLevel
    end

    local link = entry.link
    if not link then
        return nil
    end

    if GetDetailedItemLevelInfo then
        local itemLevel = GetDetailedItemLevelInfo(link)
        if itemLevel and itemLevel > 0 then
            return itemLevel
        end
    end

    if C_Item and C_Item.GetDetailedItemLevelInfo then
        local itemLevel = C_Item.GetDetailedItemLevelInfo(link)
        if itemLevel and itemLevel > 0 then
            return itemLevel
        end
    end

    return nil
end

local function ResolveEntryQuality(entry)
    if not entry then
        return nil
    end

    if entry.quality ~= nil then
        return entry.quality
    end

    local link = entry.link
    if link then
        local quality = select(3, GetItemInfo(link))
        if quality ~= nil then
            return quality
        end
    end

    local itemID = entry.itemID or (link and GetItemInfoInstant(link)) or nil
    if itemID and C_Item and C_Item.GetItemQualityByID then
        return C_Item.GetItemQualityByID(itemID)
    end

    return nil
end

local function GetEmptySlotTexture(slotDef)
    if not slotDef or not slotDef.inventorySlot or not GetInventorySlotInfo then
        return nil
    end

    local _, emptyTexture = GetInventorySlotInfo(slotDef.inventorySlot)
    return emptyTexture
end

local function CreateGearSlot(parent, slotDef)
    local layout = SLOT_LAYOUT[slotDef.slotID]
    local slot = CreateFrame("Button", nil, parent, "BackdropTemplate")
    slot:SetSize(SLOT_SIZE, SLOT_SIZE)
    slot:SetPoint(layout.point, parent, layout.point, layout.x, layout.y)
    slot:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    slot:SetBackdropColor(0, 0, 0, 0.82)
    slot:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
    slot:SetScript("OnEnter", SetItemTooltip)
    slot:SetScript("OnLeave", ClearItemTooltip)

    slot.icon = slot:CreateTexture(nil, "ARTWORK")
    slot.icon:SetPoint("TOPLEFT", 3, -3)
    slot.icon:SetPoint("BOTTOMRIGHT", -3, 3)

    slot.itemLevelText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slot.itemLevelText:SetShadowOffset(1, -1)
    slot.itemLevelText:SetShadowColor(0, 0, 0, 1)
    slot.itemLevelText:SetWidth(108)

    if LEFT_COLUMN_SLOTS[slotDef.slotID] then
        slot.itemLevelText:SetPoint("TOPLEFT", slot, "TOPRIGHT", 8, -20)
        slot.itemLevelText:SetJustifyH("LEFT")
    elseif RIGHT_COLUMN_SLOTS[slotDef.slotID] then
        slot.itemLevelText:SetPoint("TOPRIGHT", slot, "TOPLEFT", -8, -20)
        slot.itemLevelText:SetJustifyH("RIGHT")
    else
        slot.itemLevelText:SetWidth(64)
        slot.itemLevelText:SetPoint("BOTTOM", slot, "TOP", 0, 4)
        slot.itemLevelText:SetJustifyH("CENTER")
    end

    slot.slotLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    slot.slotLabel:SetWidth(108)
    slot.slotLabel:SetText(GetGearSlotLabel(slotDef))

    if LEFT_COLUMN_SLOTS[slotDef.slotID] then
        slot.slotLabel:SetPoint("TOPLEFT", slot, "TOPRIGHT", 8, -2)
        slot.slotLabel:SetJustifyH("LEFT")
    elseif RIGHT_COLUMN_SLOTS[slotDef.slotID] then
        slot.slotLabel:SetPoint("TOPRIGHT", slot, "TOPLEFT", -8, -2)
        slot.slotLabel:SetJustifyH("RIGHT")
    else
        slot.slotLabel:SetJustifyH("CENTER")
        slot.slotLabel:SetPoint("TOP", slot, "BOTTOM", 0, -2)
    end

    slot.slotID = slotDef.slotID
    slot.emptyText = GetEmptyLabel()

    return slot
end

local function CreateGearPanel()
    local panel = CreateFrame("Frame", "LiteVaultGearPanel", UIParent, "BackdropTemplate")
    panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    panel:SetPoint("CENTER")
    panel:SetClampedToScreen(true)
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    lv.EnsureBorderStyle(panel, "panel")
    panel:Hide()
    panel:SetScript("OnHide", function()
        currentGearChar = nil
    end)
    tinsert(UISpecialFrames, "LiteVaultGearPanel")

    panel.closeBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    panel.closeBtn:SetSize(70, 26)
    panel.closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -HEADER_RIGHT_INSET, -HEADER_TOP_INSET)
    panel.closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel.closeBtn.Text = panel.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.closeBtn.Text:SetPoint("CENTER")
    panel.closeBtn.Text:SetText(T("BUTTON_CLOSE", "Close"))
    panel.closeBtn:SetScript("OnClick", function()
        panel:Hide()
    end)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 12, -16)
    panel.title:SetPoint("RIGHT", panel.closeBtn, "LEFT", -10, 0)
    panel.title:SetJustifyH("LEFT")

    panel.updatedText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.updatedText:SetWidth(UPDATED_TEXT_WIDTH)
    panel.updatedText:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -HEADER_RIGHT_INSET, -(HEADER_TOP_INSET + 34))
    panel.updatedText:SetJustifyH("RIGHT")
    panel.updatedText:SetTextColor(0.53, 0.53, 0.53)

    panel.centerName = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.centerName:SetPoint("TOP", panel, "TOP", 0, -82)
    panel.centerName:SetJustifyH("CENTER")

    panel.centerIdentity = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.centerIdentity:SetPoint("TOP", panel.centerName, "BOTTOM", 0, -6)
    panel.centerIdentity:SetJustifyH("CENTER")
    panel.centerIdentity:SetTextColor(1, 0.82, 0)

    panel.classIconBorder = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    panel.classIconBorder:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 4,
    })
    panel.classIconBorder:SetBackdropColor(0, 0, 0, 0)
    panel.classIconBorder:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)

    panel.classIconFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    panel.classIconFrame:SetSize(68, 68)
    panel.classIconFrame:SetPoint("TOP", panel.centerIdentity, "BOTTOM", 0, -10)
    panel.classIconFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel.classIconBorder:SetPoint("TOPLEFT", panel.classIconFrame, "TOPLEFT", -3, 3)
    panel.classIconBorder:SetPoint("BOTTOMRIGHT", panel.classIconFrame, "BOTTOMRIGHT", 3, -3)
    panel.classIconBorder:SetFrameLevel(panel.classIconFrame:GetFrameLevel() + 2)

    panel.classIcon = panel.classIconFrame:CreateTexture(nil, "ARTWORK")
    panel.classIcon:SetPoint("TOPLEFT", 4, -4)
    panel.classIcon:SetPoint("BOTTOMRIGHT", -4, 4)
    panel.classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")

    panel.avgIlvlText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.avgIlvlText:SetPoint("TOP", panel.classIconFrame, "BOTTOM", 0, -8)
    panel.avgIlvlText:SetJustifyH("CENTER")

    panel.statsFrame = CreateCombatStatsContainer(panel)
    panel.statsFrame:SetPoint("TOP", panel.avgIlvlText, "BOTTOM", 0, -16)

    panel.slotButtons = {}
    for _, slotDef in ipairs(GEAR_SLOT_ORDER) do
        panel.slotButtons[slotDef.slotID] = CreateGearSlot(panel, slotDef)
    end

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(panel, ApplyGearPanelTheme)
            lv.RegisterThemedElement(panel.closeBtn, ApplyGearCloseButtonTheme)
            lv.RegisterThemedElement(panel.classIconFrame, ApplyCenterIconFrameTheme)
            lv.RegisterThemedElement(panel.statsFrame, ApplyCombatStatsBlockTheme)
            ApplyGearPanelTheme(panel, lv.GetTheme())
            ApplyGearCloseButtonTheme(panel.closeBtn, lv.GetTheme())
            ApplyCenterIconFrameTheme(panel.classIconFrame, lv.GetTheme())
            ApplyCombatStatsBlockTheme(panel.statsFrame, lv.GetTheme())
        end
    end)

    lv.LVGearPanel = panel
    return panel
end

function lv.OpenGearPanel(charKey, skipMenuClose)
    local db = LiteVaultDB and LiteVaultDB[charKey]
    if not db then
        return
    end

    if gearPanel and gearPanel:IsShown() and currentGearChar == charKey then
        gearPanel:Hide()
        currentGearChar = nil
        return
    end

    if not skipMenuClose then
        if lv.HideAllActionMenus then lv.HideAllActionMenus() end
        if lv.CloseAuxPanels then lv.CloseAuxPanels("gear") end
    end

    if not gearPanel then
        gearPanel = CreateGearPanel()
    end

    gearPanel.title:SetText(GetPanelTitle(charKey, db))
    gearPanel.updatedText:SetText(BuildUpdatedText(db.gearLastScanned))
    gearPanel.centerName:SetText(GetCenterName(charKey))
    gearPanel.centerIdentity:SetText(GetCenterIdentity(db))
    local avgItemLevel = tonumber(db.ilvl) or 0
    local avgItemLevelColor = (lv.GetiLvLColor and lv.GetiLvLColor(avgItemLevel)) or "ffffffff"
    gearPanel.avgIlvlText:SetText(string.format("iLvl |c%s%d|r", avgItemLevelColor, avgItemLevel))
    SetCombatStatRows(gearPanel.statsFrame, BuildCombatStatsRowData(db.combatStats))

    local classTag = db.class or "WARRIOR"
    gearPanel.classIcon:SetTexCoord(GetClassCoords(classTag))
    local classColor = GetCharacterClassColor(classTag)
    local theme = lv.GetTheme()
    if theme then
        ApplyCenterIconFrameTheme(gearPanel.classIconFrame, theme)
    end
    gearPanel.classIconBorder:SetBackdropBorderColor(classColor.r or 1, classColor.g or 1, classColor.b or 1, 0.85)

    for _, slotDef in ipairs(GEAR_SLOT_ORDER) do
        local slotBtn = gearPanel.slotButtons[slotDef.slotID]
        local entry = GetSlotEntry(db.gear, slotDef.slotID)
        local hasItem = entry and entry.link

        slotBtn.link = hasItem and entry.link or nil
        slotBtn.emptyText = GetEmptyLabel()
        slotBtn.slotLabel:SetText(GetGearSlotLabel(slotDef))

        if hasItem then
            local resolvedItemLevel = ResolveEntryItemLevel(entry)
            local resolvedQuality = ResolveEntryQuality(entry)

            slotBtn.icon:SetTexture((entry.icon and entry.icon ~= 0) and entry.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            slotBtn.icon:SetVertexColor(1, 1, 1, 1)
            ApplyItemLevelText(slotBtn, resolvedItemLevel, resolvedQuality)

            local quality = resolvedQuality
            if quality then
                local r, g, b = GetItemQualityColor(quality)
                slotBtn:SetBackdropBorderColor(r, g, b, 1)
            else
                slotBtn:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
            end
        else
            slotBtn.icon:SetTexture(GetEmptySlotTexture(slotDef))
            slotBtn.icon:SetVertexColor(1, 1, 1, 0.75)
            ApplyItemLevelText(slotBtn, nil, nil)
            slotBtn:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
        end
    end

    currentGearChar = charKey
    gearPanel:Show()
end

function lv.RefreshGearPanelForCurrentChar(playerKey)
    if not gearPanel or not gearPanel:IsShown() then return end
    playerKey = playerKey or currentGearChar
    if currentGearChar ~= playerKey then return end

    currentGearChar = nil
    lv.OpenGearPanel(playerKey, true)
end
