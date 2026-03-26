local _, lv = ...

local ICON_SIZE = 36
local COLS = 8
local PAD = 4

local bagPanel
local currentBagChar
local currentPanelMode = "bags"

local function T(key, fallback)
    local value = lv.L and lv.L[key]
    if not value or value == key then
        return fallback
    end
    return value
end

function lv.IsBagViewingEnabled()
    return not (LiteVaultDB and LiteVaultDB.disableBagViewing)
end

local function GetWarbandBankName(fallback)
    local localizedFallback = T("Warband Bank", fallback or T("BUTTON_WARBAND_BANK", "Warband Bank"))
    local candidates = {
        _G.ACCOUNT_BANK_PANEL_TITLE,
        _G.ACCOUNT_BANK_TITLE,
        _G.ACCOUNT_BANK_TAB_LABEL,
        _G.BANK_TAB_ACCOUNT,
        _G.WARBAND_BANK,
    }
    for _, name in ipairs(candidates) do
        if type(name) == "string" and name ~= "" and name ~= "Warband Bank" then
            return name
        end
    end
    return localizedFallback
end

local function GetBagTabLabel(mode)
    if mode == "bags" then
        return T("BUTTON_BAGS", "Bags")
    end
    if mode == "bank" then
        return T("BUTTON_BANK", "Bank")
    end
    return GetWarbandBankName(T("Warband Bank", T("BUTTON_WARBAND_BANK", "Warband Bank")))
end

local function GetBagTabWidth(btn)
    if not btn or not btn.Text then return 80 end
    return math.max(62, math.ceil(btn.Text:GetStringWidth() + 20))
end

local function LayoutBagTabs(panel)
    if not panel or not panel.tabs or not panel.title then return end

    local previous
    for index, btn in ipairs(panel.tabs) do
        btn:SetWidth(GetBagTabWidth(btn))
        btn:ClearAllPoints()
        if index == 1 then
            btn:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -8)
        else
            btn:SetPoint("LEFT", previous, "RIGHT", 6, 0)
        end
        previous = btn
    end
end

local function BuildStorageSlotInfoParts(timestamp, used, total)
    local base = string.format(T("LABEL_BAG_SLOTS", "Slots: %d / %d used"), used, total)
    if timestamp then
        local age = SecondsToTime(math.max(0, time() - timestamp), false, true, 1)
        return base, string.format("(%s %s)", T("LABEL_SCANNED", "scanned"), age)
    end
    return base, ""
end

local function ApplyBagPanelTheme(frame, theme)
    frame:SetBackdropColor(unpack(theme.backgroundSolid or theme.background))
    frame:SetBackdropBorderColor(unpack(theme.borderPrimary))
end

local function ApplyBagCloseButtonTheme(btn, theme)
    btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    if btn.Text then
        btn.Text:SetTextColor(unpack(theme.textPrimary))
    end
end

local function CreateBagPanel()
    local panel = CreateFrame("Frame", "LiteVaultBagPanel", UIParent, "BackdropTemplate")
    panel:SetSize(COLS * (ICON_SIZE + PAD) + PAD * 2 + 20, 400)
    panel:SetPoint("CENTER")
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
    panel:Hide()
    tinsert(UISpecialFrames, "LiteVaultBagPanel")

    panel.closeBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    panel.closeBtn:SetSize(70, 26)
    panel.closeBtn:SetPoint("TOPRIGHT", -12, -12)
    panel.closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    panel.closeBtn.Text = panel.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.closeBtn.Text:SetPoint("CENTER")
    panel.closeBtn.Text:SetText(T("BUTTON_CLOSE", "Close"))
    panel.closeBtn:SetScript("OnClick", function() panel:Hide() end)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", 12, -16)

    panel.tabs = {}
    local tabDefs = {
        { key = "bags", label = GetBagTabLabel("bags") },
        { key = "bank", label = GetBagTabLabel("bank") },
        { key = "warband", label = GetBagTabLabel("warband") },
    }
    for index, def in ipairs(tabDefs) do
        local btn = CreateFrame("Button", nil, panel, "BackdropTemplate")
        btn:SetSize(80, 24)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.Text:SetPoint("CENTER")
        btn.Text:SetText(def.label)
        btn.mode = def.key
        panel.tabs[index] = btn
    end
    LayoutBagTabs(panel)

    panel.slotInfo = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.slotInfo:SetPoint("TOPLEFT", 12, -72)
    panel.slotInfo:SetWidth(panel:GetWidth() - 140)
    panel.slotInfo:SetJustifyH("LEFT")
    panel.slotInfo:SetWordWrap(false)

    panel.slotMeta = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.slotMeta:SetPoint("RIGHT", -12, 0)
    panel.slotMeta:SetPoint("TOP", panel.slotInfo, "TOP", 0, 0)
    panel.slotMeta:SetJustifyH("RIGHT")
    panel.slotMeta:SetTextColor(0.53, 0.53, 0.53)
    panel.slotMeta:SetWordWrap(false)

    panel.emptyText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.emptyText:SetPoint("TOPLEFT", 12, -120)
    panel.emptyText:SetPoint("RIGHT", -12, 0)
    panel.emptyText:SetJustifyH("CENTER")
    panel.emptyText:SetText(T("BAGS_EMPTY_STATE", "No saved bag items for this character yet."))
    panel.emptyText:Hide()

    panel.scrollFrame = CreateFrame("ScrollFrame", nil, panel)
    panel.scrollFrame:SetPoint("TOPLEFT", 12, -96)
    panel.scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12)
    panel.scrollFrame:EnableMouseWheel(true)

    panel.scrollChild = CreateFrame("Frame", nil, panel.scrollFrame)
    panel.scrollChild:SetSize(1, 1)
    panel.scrollFrame:SetScrollChild(panel.scrollChild)

    panel.slots = {}

    panel.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step = ICON_SIZE + PAD
        local current = self:GetVerticalScroll()
        local maxScroll = math.max(0, panel.scrollChild:GetHeight() - self:GetHeight())
        if delta > 0 then
            self:SetVerticalScroll(math.max(0, current - step))
        else
            self:SetVerticalScroll(math.min(maxScroll, current + step))
        end
    end)

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(panel, ApplyBagPanelTheme)
            lv.RegisterThemedElement(panel.closeBtn, ApplyBagCloseButtonTheme)
            for _, btn in ipairs(panel.tabs) do
                lv.RegisterThemedElement(btn, ApplyBagCloseButtonTheme)
            end
            ApplyBagPanelTheme(panel, lv.GetTheme())
            ApplyBagCloseButtonTheme(panel.closeBtn, lv.GetTheme())
            for _, btn in ipairs(panel.tabs) do
                ApplyBagCloseButtonTheme(btn, lv.GetTheme())
            end
        end
    end)

    lv.LVBagPanel = panel
    return panel
end

local function UpdateScrollChildSize(panel, count)
    local rows = math.max(1, math.ceil((count or 0) / COLS))
    local contentHeight = rows * (ICON_SIZE + PAD) + PAD
    local contentWidth = COLS * (ICON_SIZE + PAD)
    panel.scrollChild:SetSize(contentWidth, contentHeight)
    panel.scrollFrame:SetVerticalScroll(0)
end

local function GetBagClassColor(classTag)
    return C_ClassColor.GetClassColor(classTag or "WARRIOR") or C_ClassColor.GetClassColor("WARRIOR")
end

local function GetModeData(charKey, mode)
    local db = LiteVaultDB and LiteVaultDB[charKey]
    if mode == "bags" then
        return db, db and db.bags or {}, db and db.bagUsedSlots or 0, db and db.bagTotalSlots or 0, db and db.bagLastScanned
    end
    if mode == "bank" then
        return db, db and db.bank or {}, db and db.bankUsedSlots or 0, db and db.bankTotalSlots or 0, db and db.bankLastScanned
    end

    local warband = LiteVaultDB and LiteVaultDB["Warband Bank"]
    return warband, warband and warband.items or {}, warband and warband.usedSlots or 0, warband and warband.totalSlots or 0, warband and warband.lastScanned
end

local function GetPanelTitle(charKey, db, mode)
    if mode == "warband" then
        return GetBagTabLabel("warband")
    end

    local classColor = GetBagClassColor(db and db.class)
    local nameOnly = (charKey and charKey:match("^([^-]+)")) or charKey or "Unknown"
    local label = mode == "bank" and T("BUTTON_BANK", "Bank") or T("BUTTON_BAGS", "Bags")
    return string.format("%s %s", classColor:WrapTextInColorCode(nameOnly), label)
end

local function UpdateTabState(panel)
    local theme = lv.GetTheme()
    for _, btn in ipairs(panel.tabs) do
        local isActive = btn.mode == currentPanelMode
        btn:SetBackdropColor(unpack(isActive and (theme.buttonBgHover or theme.buttonBg) or (theme.buttonBgAlt or theme.buttonBg)))
        btn:SetBackdropBorderColor(unpack(isActive and theme.borderHover or theme.borderPrimary))
        btn.Text:SetTextColor(unpack(isActive and theme.textPrimary or theme.textSecondary))
    end
end

local function ApplyBagCraftingQualityOverlay(btn, item)
    if not btn.ProfessionQualityOverlay then
        btn.ProfessionQualityOverlay = btn:CreateTexture(nil, "OVERLAY")
        btn.ProfessionQualityOverlay:SetPoint("TOPLEFT", -2, 2)
        btn.ProfessionQualityOverlay:SetDrawLayer("OVERLAY", 7)
    end

    btn.ProfessionQualityOverlay:Hide()

    if not item or not item.craftingQuality then
        return
    end

    if SetItemCraftingQualityOverlay and item.link then
        SetItemCraftingQualityOverlay(btn, item.link)
        if btn.ProfessionQualityOverlay then
            btn.ProfessionQualityOverlay:Show()
        end
        return
    end

    local atlas = ("Professions-Icon-Quality-Tier%d-Inv"):format(item.craftingQuality)
    btn.ProfessionQualityOverlay:SetAtlas(atlas, TextureKitConstants and TextureKitConstants.UseAtlasSize)
    btn.ProfessionQualityOverlay:Show()
end

function lv.RefreshBagPanelLocale()
    if not bagPanel then return end

    bagPanel.closeBtn.Text:SetText(T("BUTTON_CLOSE", "Close"))
    for _, btn in ipairs(bagPanel.tabs) do
        btn.Text:SetText(GetBagTabLabel(btn.mode))
    end
    LayoutBagTabs(bagPanel)

    if currentBagChar then
        local modeDB, items, used, total, scannedAt = GetModeData(currentBagChar, currentPanelMode)
        bagPanel.title:SetText(GetPanelTitle(currentBagChar, modeDB, currentPanelMode))
        local slotText, metaText = BuildStorageSlotInfoParts(scannedAt, used, total)
        bagPanel.slotInfo:SetText(slotText)
        bagPanel.slotMeta:SetText(metaText)
        bagPanel.emptyText:SetText(
            currentPanelMode == "bank" and T("BANK_EMPTY_STATE", "No saved bank items for this character yet.")
            or currentPanelMode == "warband" and T("WARBANK_EMPTY_STATE", "No saved warband bank items yet.")
            or T("BAGS_EMPTY_STATE", "No saved bag items for this character yet.")
        )
    end
end

function lv.OpenBagPanel(charKey, skipMenuClose)
    if not lv.IsBagViewingEnabled() then
        if bagPanel and bagPanel:IsShown() then
            bagPanel:Hide()
        end
        currentBagChar = nil
        return
    end

    local db = LiteVaultDB and LiteVaultDB[charKey]
    if not db then return end

    if bagPanel and bagPanel:IsShown() and currentBagChar == charKey then
        bagPanel:Hide()
        currentBagChar = nil
        return
    end

    if not skipMenuClose then
        if lv.HideAllActionMenus then lv.HideAllActionMenus() end
        if lv.CloseAuxPanels then lv.CloseAuxPanels("bags") end
    end

    if not bagPanel then
        bagPanel = CreateBagPanel()
        for _, btn in ipairs(bagPanel.tabs) do
            btn:SetScript("OnClick", function(self)
                local targetChar = currentBagChar or lv.PLAYER_KEY
                currentPanelMode = self.mode
                currentBagChar = nil
                lv.OpenBagPanel(targetChar, true)
            end)
        end
    end

    for _, btn in ipairs(bagPanel.slots) do
        btn:Hide()
        btn:ClearAllPoints()
    end

    local modeDB, items, used, total, scannedAt = GetModeData(charKey, currentPanelMode)

    bagPanel.title:SetText(GetPanelTitle(charKey, modeDB, currentPanelMode))
    local slotText, metaText = BuildStorageSlotInfoParts(scannedAt, used, total)
    bagPanel.slotInfo:SetText(slotText)
    bagPanel.slotMeta:SetText(metaText)
    bagPanel.emptyText:SetShown(#items == 0)
    bagPanel.emptyText:SetText(
        currentPanelMode == "bank" and T("BANK_EMPTY_STATE", "No saved bank items for this character yet.")
        or currentPanelMode == "warband" and T("WARBANK_EMPTY_STATE", "No saved warband bank items yet.")
        or T("BAGS_EMPTY_STATE", "No saved bag items for this character yet.")
    )
    UpdateTabState(bagPanel)

    UpdateScrollChildSize(bagPanel, #items)

    for i, item in ipairs(items) do
        local btn = bagPanel.slots[i]
        if not btn then
            btn = CreateFrame("Button", nil, bagPanel.scrollChild, "BackdropTemplate")
            btn:SetSize(ICON_SIZE, ICON_SIZE)
            btn.liteVaultNoItemLevel = true
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = 2,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            btn.tex = btn:CreateTexture(nil, "ARTWORK")
            btn.tex:SetPoint("TOPLEFT", 2, -2)
            btn.tex:SetPoint("BOTTOMRIGHT", -2, 2)
            btn.count = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
            btn.count:SetPoint("BOTTOMRIGHT", -2, 2)
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if self.link then
                    GameTooltip:SetHyperlink(self.link)
                else
                    GameTooltip:SetText(self.itemName or UNKNOWN)
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            bagPanel.slots[i] = btn
        end

        if lv.ClearItemLevelOverlay then
            lv.ClearItemLevelOverlay(btn)
        end

        local col = (i - 1) % COLS
        local row = math.floor((i - 1) / COLS)
        btn:SetPoint("TOPLEFT", col * (ICON_SIZE + PAD), -(row * (ICON_SIZE + PAD)))
        btn.tex:SetTexture((item.icon and item.icon ~= 0) and item.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        btn.itemName = item.name
        btn.link = item.link
        btn.count:SetText((item.count and item.count > 1) and item.count or "")
        ApplyBagCraftingQualityOverlay(btn, item)

        local quality = item.quality or ((Enum and Enum.ItemQuality and Enum.ItemQuality.Common) or 1)
        local r, g, b = GetItemQualityColor(quality)
        btn:SetBackdropColor(0, 0, 0, 0.75)
        btn:SetBackdropBorderColor(r, g, b)
        btn:Show()
    end

    currentBagChar = charKey
    bagPanel:Show()
end

function lv.RefreshBagPanelForCurrentChar(playerKey)
    if not lv.IsBagViewingEnabled() then
        if bagPanel and bagPanel:IsShown() then
            bagPanel:Hide()
        end
        currentBagChar = nil
        return
    end
    if not bagPanel or not bagPanel:IsShown() then return end
    if currentPanelMode ~= "warband" and currentBagChar ~= playerKey then return end

    currentBagChar = nil
    lv.OpenBagPanel(playerKey, true)
end
