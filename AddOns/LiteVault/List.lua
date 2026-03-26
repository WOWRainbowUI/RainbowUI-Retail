-- List.lua (Enhanced Edition)
local addonName, lv = ...
local L = lv.L
local rows = {}
local isManaging = false
local MYTH_DAWNCREST_CURRENCY_ID = 3347

local function GetCurrencyButtonIcon()
    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(MYTH_DAWNCREST_CURRENCY_ID)
        if info and info.iconFileID then
            return info.iconFileID
        end
    end
    return "Interface\\Icons\\INV_Misc_Coin_01"
end

local function CreateVaultProgressSegment(parent, point, relativeTo, relativePoint, xOffset, yOffset, atlas, iconSize)
    local segment = CreateFrame("Frame", nil, parent)
    segment:SetSize(70, 20)
    segment:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)

    segment.icon = segment:CreateTexture(nil, "OVERLAY")
    segment.icon:SetSize(iconSize or 18, iconSize or 18)
    segment.icon:SetPoint("LEFT", 0, 0)
    segment.icon:SetAtlas(atlas, true)

    segment.count = segment:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    segment.count:SetPoint("LEFT", segment.icon, "RIGHT", 4, 0)
    segment.count:SetJustifyH("LEFT")
    segment.count:SetTextColor(1, 0.82, 0)
    if lv.ApplyLocaleFont then
        lv.ApplyLocaleFont(segment.count, 11)
    end

    return segment
end

local function SetVaultProgressTextColor(row, color)
    if not row then return end
    local r, g, b, a = unpack(color)
    if row.vaultRaid and row.vaultRaid.count then row.vaultRaid.count:SetTextColor(r, g, b, a or 1) end
    if row.vaultMythic and row.vaultMythic.count then row.vaultMythic.count:SetTextColor(r, g, b, a or 1) end
    if row.vaultDelve and row.vaultDelve.count then row.vaultDelve.count:SetTextColor(r, g, b, a or 1) end
end

local function SetVaultProgressCounts(row, raidSlots, mythicSlots, delveSlots)
    if not row then return end
    if row.vaultRaid and row.vaultRaid.count then row.vaultRaid.count:SetText(string.format("%d/3", tonumber(raidSlots) or 0)) end
    if row.vaultMythic and row.vaultMythic.count then row.vaultMythic.count:SetText(string.format("%d/3", tonumber(mythicSlots) or 0)) end
    if row.vaultDelve and row.vaultDelve.count then row.vaultDelve.count:SetText(string.format("%d/3", tonumber(delveSlots) or 0)) end
end

local function LayoutProfessionTracker(row, professionCount)
    if not row or not row.professionFrame then return end
    row.professionFrame:ClearAllPoints()

    if row.prof1Text then
        row.prof1Text:ClearAllPoints()
    end
    if row.prof2Text then
        row.prof2Text:ClearAllPoints()
    end

    if professionCount and professionCount > 1 then
        row.professionFrame:SetSize(74, 28)
        row.professionFrame:SetPoint("BOTTOMLEFT", row.dataBox, "BOTTOMLEFT", 10, 50)
        if row.prof1Badge then
            row.prof1Badge:ClearAllPoints()
            row.prof1Badge:SetPoint("CENTER", row.professionFrame, "CENTER", -18, 0)
        end
        if row.prof2Badge then
            row.prof2Badge:ClearAllPoints()
            row.prof2Badge:SetPoint("CENTER", row.professionFrame, "CENTER", 18, 0)
        end
    elseif professionCount == 1 then
        row.professionFrame:SetSize(38, 28)
        row.professionFrame:SetPoint("BOTTOMLEFT", row.dataBox, "BOTTOMLEFT", 10, 50)
        if row.prof1Badge then
            row.prof1Badge:ClearAllPoints()
            row.prof1Badge:SetPoint("CENTER", row.professionFrame, "CENTER", 0, 0)
        end
        if row.prof2Badge then
            row.prof2Badge:ClearAllPoints()
            row.prof2Badge:SetPoint("CENTER", row.professionFrame, "CENTER", 18, 0)
        end
    else
        row.professionFrame:SetSize(140, 28)
        row.professionFrame:SetPoint("BOTTOMLEFT", row.dataBox, "BOTTOMLEFT", 10, 50)
        if row.prof1Badge then
            row.prof1Badge:ClearAllPoints()
            row.prof1Badge:SetPoint("CENTER", row.professionFrame, "CENTER", -18, 0)
        end
        if row.prof2Badge then
            row.prof2Badge:ClearAllPoints()
            row.prof2Badge:SetPoint("CENTER", row.professionFrame, "CENTER", 18, 0)
        end
        if row.prof1Text then
            row.prof1Text:SetPoint("CENTER", row.professionFrame, "CENTER", 0, 0)
            row.prof1Text:SetJustifyH("CENTER")
            row.prof1Text:SetWordWrap(false)
        end
    end

    if row.upgradeFrame then
        row.upgradeFrame:ClearAllPoints()
        row.upgradeFrame:SetPoint("LEFT", row.professionFrame, "RIGHT", 10, 0)
    end
end

local SetCircularBadgeState = lv.SetCircularBadgeState
local SetCircularBadgeTexture = lv.SetCircularBadgeTexture
local CreateCircularBadge = lv.CreateCircularBadge

local PROF_TRACKER_BADGE_STYLE = {
    frameSize = 28,
    hoverSize = 24,
    shellSize = 22,
    innerSize = 18,
    iconSize = 22,
    texCoord = 0.02,
}

local PROF_TRACKER_ICON_PALETTE = {
    default = {
        shell = {1, 1, 1, 0},
        inner = {1, 1, 1, 0},
        icon = {1, 1, 1, 1},
        boost = {1, 1, 1, 0},
    },
    hover = {
        shell = {1, 1, 1, 0},
        inner = {1, 1, 1, 0},
        icon = {1, 1, 1, 1},
        boost = {1, 1, 1, 0.16},
    },
}

local DATA_BADGE_STYLE = {
    frameSize = 24,
    hoverSize = 22,
    shellSize = 20,
    innerSize = 18,
    iconSize = 18,
}

local LEDGER_BADGE_STYLE = {
    frameSize = 20,
    hoverSize = 18,
    shellSize = 16,
    innerSize = 14,
    iconSize = 14,
}

local function CreateProfessionBadge(parent, point, relativeTo, relativePoint, xOffset, yOffset)
    return CreateCircularBadge(parent, point, relativeTo, relativePoint, xOffset, yOffset, PROF_TRACKER_BADGE_STYLE, PROF_TRACKER_ICON_PALETTE)
end

-- Utils.lua owns the approved currency palette. Keep this as a reference only.
local CURRENCY_BADGE_PALETTE = lv.BadgePalettes and lv.BadgePalettes.currency

local function SetCurrencyBadgeState(badge, hovered)
    if lv.ApplyBadgePalette then
        lv.ApplyBadgePalette(badge, CURRENCY_BADGE_PALETTE, hovered)
        return
    end
    if not badge then return end
    local state = hovered and CURRENCY_BADGE_PALETTE.hover or CURRENCY_BADGE_PALETTE.default
    if hovered then
        if badge.hover then badge.hover:Show() end
    else
        if badge.hover then badge.hover:Hide() end
    end
    if badge.shell then badge.shell:SetVertexColor(unpack(state.shell)) end
    if badge.inner then badge.inner:SetVertexColor(unpack(state.inner)) end
    if badge.icon then badge.icon:SetVertexColor(unpack(state.icon)) end
    if badge.iconBoost then badge.iconBoost:SetVertexColor(unpack(state.boost)) end
end

local function SetCurrencyBadgeTexture(badge)
    if not badge then return end
    local texture = GetCurrencyButtonIcon()
    if badge.icon then
        badge.icon:SetTexture(texture)
    end
    if badge.iconBoost then
        badge.iconBoost:SetTexture(texture)
    end
end

lv.isManaging = function() return isManaging end
function lv.CloseAuxPanels(except)
    if except ~= "currency" and lv.LVCurrencyWindow then lv.LVCurrencyWindow:Hide() end
    if except ~= "vault" and lv.LVVaultWindow then lv.LVVaultWindow:Hide() end
    if except ~= "ledger" and lv.LVLedgerWindow then lv.LVLedgerWindow:Hide() end
    if except ~= "professions" and lv.LVProfessionWindow then lv.LVProfessionWindow:Hide() end
    if except ~= "bags" and lv.LVBagPanel then lv.LVBagPanel:Hide() end
    if except ~= "raids" and _G["LiteVaultRaidFrame"] then _G["LiteVaultRaidFrame"]:Hide() end
    if except ~= "instances" and _G["LiteVaultInstancePanel"] then _G["LiteVaultInstancePanel"]:Hide() end
    if except ~= "teleports" and _G["LiteVaultTeleportPanel"] then _G["LiteVaultTeleportPanel"]:Hide() end
    if except ~= "options" and lv.OptionsPanel then lv.OptionsPanel:Hide() end
end

function lv.HideAllActionMenus()
    for _, r in pairs(rows) do
        if r and r.actionMenu and r.actionMenu.Hide then
            r.actionMenu:Hide()
        end
    end
end

function lv.IsMouseOverActionMenu()
    for _, r in pairs(rows) do
        if r and r.actionMenu and r.actionMenu:IsShown() and r.actionMenu.IsMouseOver and r.actionMenu:IsMouseOver() then
            return true
        end
    end
    return false
end
local contextMenuFrame = CreateFrame("Frame", "LiteVaultCharacterContextMenu", UIParent, "UIDropDownMenuTemplate")

local function RemoveCharacterFromTracking(charKey)
    if not charKey or not LiteVaultDB or not LiteVaultDB[charKey] then return end
    LiteVaultDB[charKey] = nil
    if LiteVaultOrder then
        for i = #LiteVaultOrder, 1, -1 do
            if LiteVaultOrder[i] == charKey then
                table.remove(LiteVaultOrder, i)
                break
            end
        end
    end
    if lv.UpdateUI then lv.UpdateUI() end
end

local function IgnoreCharacter(charKey)
    if not charKey or not LiteVaultDB or not LiteVaultDB[charKey] then return end
    LiteVaultDB[charKey].isIgnored = true
    if lv.UpdateUI then lv.UpdateUI() end
end

local function RestoreCharacter(charKey)
    if not charKey or not LiteVaultDB or not LiteVaultDB[charKey] then return end
    LiteVaultDB[charKey].isIgnored = false
    if lv.UpdateUI then lv.UpdateUI() end
end

if not StaticPopupDialogs["LITEVAULT_CONFIRM_DELETE_CHARACTER"] then
    StaticPopupDialogs["LITEVAULT_CONFIRM_DELETE_CHARACTER"] = {
        text = (L["DIALOG_DELETE_CHAR"] ~= "DIALOG_DELETE_CHAR") and L["DIALOG_DELETE_CHAR"] or "Delete %s from LiteVault?",
        button1 = YES,
        button2 = NO,
        OnAccept = function(self, data)
            RemoveCharacterFromTracking(data)
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }
end

local function ShowCharacterContextMenu(charKey, ownerFrame)
    if not charKey or not LiteVaultDB or not LiteVaultDB[charKey] then return end
    local data = LiteVaultDB[charKey]
    if not data or data.class == "Bank" then return end

    local menu = {}
    if data.isIgnored then
        table.insert(menu, {
            text = (L["BUTTON_RESTORE"] ~= "BUTTON_RESTORE") and L["BUTTON_RESTORE"] or "Restore",
            func = function() RestoreCharacter(charKey) end,
            notCheckable = true,
        })
    else
        table.insert(menu, {
            text = (L["BUTTON_IGNORE"] ~= "BUTTON_IGNORE") and L["BUTTON_IGNORE"] or "Ignore",
            func = function() IgnoreCharacter(charKey) end,
            notCheckable = true,
        })
    end

    table.insert(menu, {
        text = (L["BUTTON_DELETE"] ~= "BUTTON_DELETE") and L["BUTTON_DELETE"] or "Delete",
        func = function()
            local nameOnly = charKey:match("^([^-]+)") or charKey
            StaticPopup_Show("LITEVAULT_CONFIRM_DELETE_CHARACTER", nameOnly, nil, charKey)
        end,
        notCheckable = true,
    })

    -- Future actions can be added here (Favorite, Rename, Reset Weekly, etc.).
    table.insert(menu, {
        text = CANCEL,
        notCheckable = true,
    })

    EasyMenu(menu, contextMenuFrame, "cursor", 0, 0, "MENU")
end

local function HandleCharacterCardMouseUp(self, button)
    local probe = self
    local hops = 0
    while probe and hops < 10 do
        if probe.isActionControl then
            return
        end
        probe = probe:GetParent()
        hops = hops + 1
    end

    if button ~= "RightButton" then
        if lv.IsMouseOverActionMenu and lv.IsMouseOverActionMenu() then
            return
        end
        if lv.HideAllActionMenus then lv.HideAllActionMenus() end
        return
    end
    local row = self
    local depth = 0
    while row and not row.charName and depth < 10 do
        row = row:GetParent()
        depth = depth + 1
    end
    local charKey = row and row.charName
    if charKey then
        ShowCharacterContextMenu(charKey, self)
    end
end

-- Refresh ledger button text for all rows (called when language changes)
function lv.RefreshLedgerButtons()
    for _, r in pairs(rows) do
        if r.ledgerBtn and r.ledgerBtn.text then
            r.ledgerBtn.text:SetText(L["BUTTON_LEDGER"])
        end
        if r.bagsBtn and r.bagsBtn.text then
            r.bagsBtn.text:SetText((L["BUTTON_BAGS"] ~= "BUTTON_BAGS") and L["BUTTON_BAGS"] or "Bags")
        end
        if r.raidBtn and r.raidBtn.text then
            r.raidBtn.text:SetText((L["BUTTON_RAIDS"] ~= "BUTTON_RAIDS") and L["BUTTON_RAIDS"] or "Raids")
        end
        if r.optionsBtn and r.optionsBtn.text then
            r.optionsBtn.text:SetText((L["BUTTON_ACTIONS"] ~= "BUTTON_ACTIONS") and L["BUTTON_ACTIONS"] or "Actions")
        end
        if r.favBtn and r.favBtn.text then
            r.favBtn.text:SetText((L["BUTTON_FAVORITE"] ~= "BUTTON_FAVORITE") and L["BUTTON_FAVORITE"] or "Favorite")
        end
        if r.deleteBtn and r.deleteBtn.text then
            r.deleteBtn.text:SetText((L["BUTTON_DELETE"] ~= "BUTTON_DELETE") and L["BUTTON_DELETE"] or "Delete")
        end
    end
end
local ContentChar, ScrollFrameChar

-- 1. INITIALIZATION
function lv.InitList(parent, window)
    local charBg = CreateFrame("Frame", nil, window, "BackdropTemplate")
    charBg:SetPoint("TOPLEFT", 35, -100) -- Moved down from -75 to -100
    charBg:SetPoint("BOTTOMLEFT", 35, 85)
    charBg:SetWidth(lv.Layout.charListWidth)
    charBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14
    })

    -- Store reference for theming
    lv.charBg = charBg

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(charBg, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderSecondary))
            end)
            local t = lv.GetTheme()
            charBg:SetBackdropColor(unpack(t.background))
            charBg:SetBackdropBorderColor(unpack(t.borderSecondary))
        end
    end)

    ScrollFrameChar = CreateFrame("ScrollFrame", "LiteVaultScrollFrame", charBg)
    ScrollFrameChar:SetPoint("TOPLEFT", 5, -42)
    ScrollFrameChar:SetPoint("BOTTOMRIGHT", -5, 5)
    ScrollFrameChar:SetClipsChildren(true)

    ContentChar = CreateFrame("Frame", nil, ScrollFrameChar)
    ContentChar:SetSize(lv.Layout.charListWidth - 10, 1)
    ScrollFrameChar:SetScrollChild(ContentChar)

    -- Enable invisible mouse wheel scrolling
    ScrollFrameChar:EnableMouseWheel(true)
    ScrollFrameChar:SetScript("OnMouseWheel", function(self, delta)
        if lv.HideAllActionMenus then lv.HideAllActionMenus() end
        local current = self:GetVerticalScroll()
        local maxScroll = math.max(0, ContentChar:GetHeight() - self:GetHeight())
        local newScroll = math.max(0, math.min(maxScroll, current - (delta * 50)))
        self:SetVerticalScroll(newScroll)
    end)

    -- Options Panel
    local optionsPanelWidth = (lv.Layout and lv.Layout.optionsPanelWidth) or 280
    local optionsPanelHeight = (lv.Layout and lv.Layout.optionsPanelHeight) or 640
    local optionsDescWidth = (lv.Layout and lv.Layout.optionsPanelDescWidth) or 220
    local optionsLabelWidth = optionsDescWidth
    local languageButtonBaseWidth = (lv.Layout and lv.Layout.optionsPanelLangButtonWidth) or 150
    local languageButtonWidth = languageButtonBaseWidth

    local OptionsPanel = CreateFrame("Frame", "LiteVaultOptionsPanel", window, "BackdropTemplate")
    OptionsPanel:SetSize(optionsPanelWidth, optionsPanelHeight)
    OptionsPanel:SetPoint("TOPLEFT", window, "TOPLEFT", 35, -65)
    OptionsPanel:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -15, 25)
    OptionsPanel:SetFrameStrata("MEDIUM")
    OptionsPanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    OptionsPanel:Hide()

    -- Register options panel for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(OptionsPanel, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            OptionsPanel:SetBackdropColor(unpack(t.background))
            OptionsPanel:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    -- Options panel title
    local optionsPanelTitle = OptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionsPanelTitle:SetPoint("TOPLEFT", 15, -12)
    optionsPanelTitle:SetText(L["TITLE_OPTIONS"])
    optionsPanelTitle:SetTextColor(1, 0.82, 0)
    if lv.ApplyLocaleFont then
        lv.ApplyLocaleFont(optionsPanelTitle, 14)
    end

    local optionsScroll = CreateFrame("ScrollFrame", nil, OptionsPanel)
    optionsScroll:SetPoint("TOPLEFT", 10, -40)
    optionsScroll:SetPoint("BOTTOMRIGHT", -10, 42)
    optionsScroll:EnableMouseWheel(true)

    local changeLogPanel = CreateFrame("Frame", nil, OptionsPanel)
    changeLogPanel:SetPoint("TOPLEFT", 10, -40)
    changeLogPanel:SetPoint("BOTTOMRIGHT", -10, 42)
    changeLogPanel:Hide()
    local changeLogTitle = changeLogPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    changeLogTitle:SetPoint("TOPLEFT", 10, -10)
    changeLogTitle:SetPoint("RIGHT", -10, 0)
    changeLogTitle:SetJustifyH("LEFT")
    changeLogTitle:SetTextColor(1, 0.82, 0)

    local changeLogText = changeLogPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    changeLogText:SetPoint("TOPLEFT", changeLogTitle, "BOTTOMLEFT", 0, -12)
    changeLogText:SetPoint("RIGHT", -10, 0)
    changeLogText:SetJustifyH("LEFT")
    changeLogText:SetJustifyV("TOP")
    changeLogText:SetWordWrap(true)
    changeLogText:SetSpacing(6)

    local optionsContent = CreateFrame("Frame", nil, optionsScroll)
    optionsContent:SetSize(math.max(1, optionsPanelWidth - 24), 1)
    optionsScroll:SetScrollChild(optionsContent)
    optionsScroll:SetScript("OnMouseWheel", function(self, delta)
        local step = 36
        local current = self:GetVerticalScroll()
        local maxScroll = math.max(0, optionsContent:GetHeight() - self:GetHeight())
        if delta > 0 then
            self:SetVerticalScroll(math.max(0, current - step))
        else
            self:SetVerticalScroll(math.min(maxScroll, current + step))
        end
    end)

    local showingChangeLog = false
    local changeLogBtn

    function lv.UpdateChangeLogButtonLabel()
        if not changeLogBtn or not changeLogBtn.Text then return end
        local L = lv.L
        local label
        if showingChangeLog then
            label = ((L["Back"] ~= "Back") and L["Back"] or "Back")
        else
            label = ((L["Change Log"] ~= "Change Log") and L["Change Log"] or "Change Log")
        end
        changeLogBtn.Text:SetText(label)
        changeLogBtn:SetWidth(math.max(96, math.ceil(changeLogBtn.Text:GetStringWidth() + 22)))
    end

    function lv.UpdateChangeLogContent()
        local L = lv.L
        if changeLogTitle then
            changeLogTitle:SetText((L["LiteVault Update Summary"] ~= "LiteVault Update Summary") and L["LiteVault Update Summary"] or "LiteVault Update Summary")
        end
        if changeLogText then
            local lines = {
                "- " .. (((L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."] ~= "Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker.") and L["Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."]) or "Refreshed several core UI elements, including the currency icon, raid icon, professions bar, and Great Vault tracker."),
                "- " .. (((L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."] ~= "Updated vault item level display to more closely match Blizzard’s default Great Vault presentation.") and L["Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."]) or "Updated vault item level display to more closely match Blizzard’s default Great Vault presentation."),
                "- " .. (((L["Added a large batch of new translations across supported locales."] ~= "Added a large batch of new translations across supported locales.") and L["Added a large batch of new translations across supported locales."]) or "Added a large batch of new translations across supported locales."),
                "- " .. (((L["Improved localized text rendering and refresh behavior throughout the addon."] ~= "Improved localized text rendering and refresh behavior throughout the addon.") and L["Improved localized text rendering and refresh behavior throughout the addon."]) or "Improved localized text rendering and refresh behavior throughout the addon."),
                "- " .. (((L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."] ~= "Updated localization support for buttons, bag tabs, weekly text, and other UI labels.") and L["Updated localization support for buttons, bag tabs, weekly text, and other UI labels."]) or "Updated localization support for buttons, bag tabs, weekly text, and other UI labels."),
                "- " .. (((L["Fixed multiple localization-related layout issues."] ~= "Fixed multiple localization-related layout issues.") and L["Fixed multiple localization-related layout issues."]) or "Fixed multiple localization-related layout issues."),
                "- " .. (((L["Fixed several localization-related crash issues."] ~= "Fixed several localization-related crash issues.") and L["Fixed several localization-related crash issues."]) or "Fixed several localization-related crash issues.")
            }
            changeLogText:SetText(table.concat(lines, "\n"))
        end
    end

    local function UpdateChangeLogButtonStyle()
        if not changeLogBtn then return end
        local t = lv.GetTheme()
        if showingChangeLog then
            changeLogBtn:SetBackdropColor(unpack(t.tabActive or t.buttonBgHover or t.buttonBgAlt or t.buttonBg))
            changeLogBtn:SetBackdropBorderColor(unpack(t.tabActiveBorder or t.borderPrimary))
            changeLogBtn.Text:SetTextColor(1, 0.82, 0)
        else
            changeLogBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            changeLogBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
            changeLogBtn.Text:SetTextColor(unpack(t.textPrimary))
        end
    end

    local function SetOptionsSubpanel(showChangeLog)
        showingChangeLog = showChangeLog and true or false
        optionsScroll:SetShown(not showingChangeLog)
        changeLogPanel:SetShown(showingChangeLog)
        lv.UpdateChangeLogButtonLabel()
        UpdateChangeLogButtonStyle()
    end

    -- Disable Time Played checkbox
    local disableTimePlayedCB = CreateFrame("CheckButton", nil, optionsContent, "InterfaceOptionsCheckButtonTemplate")
    disableTimePlayedCB.Text:SetText(L["OPTION_DISABLE_TIMEPLAYED"])
    disableTimePlayedCB.Text:SetTextColor(1, 1, 1)
    disableTimePlayedCB.Text:SetWidth(optionsLabelWidth)
    disableTimePlayedCB.Text:SetJustifyH("LEFT")
    disableTimePlayedCB.Text:SetJustifyV("TOP")

    -- Description text
    local timePlayedDesc = optionsContent:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    timePlayedDesc:SetText(L["OPTION_DISABLE_TIMEPLAYED_DESC"])
    timePlayedDesc:SetTextColor(1, 0.82, 0)
    timePlayedDesc:SetWidth(optionsDescWidth)
    timePlayedDesc:SetJustifyH("LEFT")
    timePlayedDesc:SetJustifyV("TOP")

    -- Initialize checkbox from saved variable
    C_Timer.After(0.1, function()
        if LiteVaultDB then
            disableTimePlayedCB:SetChecked(LiteVaultDB.disableTimePlayed or false)
        end
    end)

    -- Save setting when checkbox changes
    disableTimePlayedCB:SetScript("OnClick", function(self)
        if LiteVaultDB then
            LiteVaultDB.disableTimePlayed = self:GetChecked() and true or false
            if LiteVaultDB.disableTimePlayed then
                -- Only call suppression with silent=false; let suppression logic print reload prompt if needed.
                if lv.SuppressTimePlayedChat then lv.SuppressTimePlayedChat(false) end
            else
                if lv.RestoreTimePlayedChat then lv.RestoreTimePlayedChat(false) end
            end
        end
    end)

    -- Time format checkbox (24h / 12h for ledger timestamps)
    local timeFormatCB = CreateFrame("CheckButton", nil, optionsContent, "InterfaceOptionsCheckButtonTemplate")
    timeFormatCB.Text:SetText(L["OPTION_ENABLE_24HR_CLOCK"])
    timeFormatCB.Text:SetTextColor(1, 1, 1)
    timeFormatCB.Text:SetWidth(optionsLabelWidth)
    timeFormatCB.Text:SetJustifyH("LEFT")
    timeFormatCB.Text:SetJustifyV("TOP")

    local timeFormatDesc = optionsContent:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    timeFormatDesc:SetText(L["OPTION_ENABLE_24HR_CLOCK_DESC"])
    timeFormatDesc:SetTextColor(1, 0.82, 0)
    timeFormatDesc:SetWidth(optionsDescWidth)
    timeFormatDesc:SetJustifyH("LEFT")
    timeFormatDesc:SetJustifyV("TOP")

    C_Timer.After(0.1, function()
        local use24 = false
        if GetCVarBool then
            use24 = GetCVarBool("timeMgrUseMilitaryTime")
        elseif LiteVaultDB then
            use24 = (LiteVaultDB.use24HourClock ~= false)
        end
        timeFormatCB:SetChecked(use24 and true or false)
    end)

    timeFormatCB:SetScript("OnClick", function(self)
        local enabled = self:GetChecked() and true or false
        if SetCVar then
            SetCVar("timeMgrUseMilitaryTime", enabled and "1" or "0")
        end
        if LiteVaultDB then
            LiteVaultDB.use24HourClock = enabled
        end
        if lv.RefreshOpenLedgerWindow then
            lv.RefreshOpenLedgerWindow()
        end
    end)

    -- Dark Mode checkbox
    local darkModeCB = CreateFrame("CheckButton", nil, optionsContent, "InterfaceOptionsCheckButtonTemplate")
    darkModeCB.Text:SetText(L["OPTION_DARK_MODE"])
    darkModeCB.Text:SetTextColor(1, 1, 1)
    darkModeCB.Text:SetWidth(optionsLabelWidth)
    darkModeCB.Text:SetJustifyH("LEFT")
    darkModeCB.Text:SetJustifyV("TOP")

    -- Description text for dark mode
    local darkModeDesc = optionsContent:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    darkModeDesc:SetText(L["OPTION_DARK_MODE_DESC"])
    darkModeDesc:SetTextColor(1, 0.82, 0)
    darkModeDesc:SetWidth(optionsDescWidth)
    darkModeDesc:SetJustifyH("LEFT")
    darkModeDesc:SetJustifyV("TOP")

    -- Initialize dark mode checkbox from saved variable
    C_Timer.After(0.1, function()
        if LiteVaultDB then
            darkModeCB:SetChecked(lv.currentTheme == "dark")
        end
    end)

    -- Toggle theme when checkbox changes
    darkModeCB:SetScript("OnClick", function(self)
        if self:GetChecked() then
            lv.SetTheme("dark")
        else
            lv.SetTheme("light")
        end
    end)

    local disableBagViewCB = CreateFrame("CheckButton", nil, optionsContent, "InterfaceOptionsCheckButtonTemplate")
    disableBagViewCB.Text:SetText((L["OPTION_DISABLE_BAG_VIEWING"] ~= "OPTION_DISABLE_BAG_VIEWING") and L["OPTION_DISABLE_BAG_VIEWING"] or "Disable bag, bank, and warband viewing")
    disableBagViewCB.Text:SetTextColor(1, 1, 1)
    disableBagViewCB.Text:SetWidth(optionsLabelWidth)
    disableBagViewCB.Text:SetJustifyH("LEFT")
    disableBagViewCB.Text:SetJustifyV("TOP")

    local disableBagViewDesc = optionsContent:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    disableBagViewDesc:SetText((L["OPTION_DISABLE_BAG_VIEWING_DESC"] ~= "OPTION_DISABLE_BAG_VIEWING_DESC") and L["OPTION_DISABLE_BAG_VIEWING_DESC"] or "Hide the Bags button and block LiteVault's saved bag, bank, and warband bank viewer.")
    disableBagViewDesc:SetTextColor(1, 0.82, 0)
    disableBagViewDesc:SetWidth(optionsDescWidth)
    disableBagViewDesc:SetJustifyH("LEFT")
    disableBagViewDesc:SetJustifyV("TOP")

    C_Timer.After(0.1, function()
        if LiteVaultDB then
            disableBagViewCB:SetChecked(LiteVaultDB.disableBagViewing or false)
        end
    end)

    disableBagViewCB:SetScript("OnClick", function(self)
        if LiteVaultDB then
            LiteVaultDB.disableBagViewing = self:GetChecked() and true or false
        end
        if LiteVaultDB and LiteVaultDB.disableBagViewing and lv.LVBagPanel and lv.LVBagPanel:IsShown() then
            lv.LVBagPanel:Hide()
        end
        if lv.UpdateUI then
            lv.UpdateUI()
        end
    end)

    local disableOverlayCB = CreateFrame("CheckButton", nil, optionsContent, "InterfaceOptionsCheckButtonTemplate")
    disableOverlayCB.Text:SetText((L["OPTION_DISABLE_CHARACTER_OVERLAY"] ~= "OPTION_DISABLE_CHARACTER_OVERLAY") and L["OPTION_DISABLE_CHARACTER_OVERLAY"] or "Disable overlay system")
    disableOverlayCB.Text:SetTextColor(1, 1, 1)
    disableOverlayCB.Text:SetWidth(optionsLabelWidth)
    disableOverlayCB.Text:SetJustifyH("LEFT")
    disableOverlayCB.Text:SetJustifyV("TOP")

    local disableOverlayDesc = optionsContent:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    disableOverlayDesc:SetText((L["OPTION_DISABLE_CHARACTER_OVERLAY_DESC"] ~= "OPTION_DISABLE_CHARACTER_OVERLAY_DESC") and L["OPTION_DISABLE_CHARACTER_OVERLAY_DESC"] or "Hide LiteVault's item level and lock overlays on character and inspect gear.")
    disableOverlayDesc:SetTextColor(1, 0.82, 0)
    disableOverlayDesc:SetWidth(optionsDescWidth)
    disableOverlayDesc:SetJustifyH("LEFT")
    disableOverlayDesc:SetJustifyV("TOP")

    C_Timer.After(0.1, function()
        if LiteVaultDB then
            disableOverlayCB:SetChecked(LiteVaultDB.disableCharacterOverlay or false)
        end
    end)

    disableOverlayCB:SetScript("OnClick", function(self)
        if LiteVaultDB then
            LiteVaultDB.disableCharacterOverlay = self:GetChecked() and true or false
        end
        if lv.RefreshCharacterOverlays then
            lv.RefreshCharacterOverlays()
        end
    end)

    local disableTeleportsCB = CreateFrame("CheckButton", nil, optionsContent, "InterfaceOptionsCheckButtonTemplate")
    disableTeleportsCB.Text:SetText((L["OPTION_DISABLE_MPLUS_TELEPORTS"] ~= "OPTION_DISABLE_MPLUS_TELEPORTS") and L["OPTION_DISABLE_MPLUS_TELEPORTS"] or "Disable M+ teleports")
    disableTeleportsCB.Text:SetTextColor(1, 1, 1)
    disableTeleportsCB.Text:SetWidth(optionsLabelWidth)
    disableTeleportsCB.Text:SetJustifyH("LEFT")
    disableTeleportsCB.Text:SetJustifyV("TOP")

    local disableTeleportsDesc = optionsContent:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    disableTeleportsDesc:SetText((L["OPTION_DISABLE_MPLUS_TELEPORTS_DESC"] ~= "OPTION_DISABLE_MPLUS_TELEPORTS_DESC") and L["OPTION_DISABLE_MPLUS_TELEPORTS_DESC"] or "Hide the M+ teleport badge and disable LiteVault's teleport panel.")
    disableTeleportsDesc:SetTextColor(1, 0.82, 0)
    disableTeleportsDesc:SetWidth(optionsDescWidth)
    disableTeleportsDesc:SetJustifyH("LEFT")
    disableTeleportsDesc:SetJustifyV("TOP")

    C_Timer.After(0.1, function()
        if LiteVaultDB then
            disableTeleportsCB:SetChecked(LiteVaultDB.disableMPlusTeleports or false)
        end
    end)

    disableTeleportsCB:SetScript("OnClick", function(self)
        if LiteVaultDB then
            LiteVaultDB.disableMPlusTeleports = self:GetChecked() and true or false
        end
        if LiteVaultDB and LiteVaultDB.disableMPlusTeleports and _G["LiteVaultTeleportPanel"] and _G["LiteVaultTeleportPanel"]:IsShown() then
            _G["LiteVaultTeleportPanel"]:Hide()
        end
        if lv.UpdateUI then
            lv.UpdateUI()
        end
    end)

    -- Theme-aware option description colors
    local function ApplyOptionDescColors(theme)
        -- Light mode: gold, Dark mode: void purple
        local r, g, b = 1, 0.82, 0
        if lv.currentTheme == "dark" then
            r, g, b = 0.6, 0.2, 1
        end
        timePlayedDesc:SetTextColor(r, g, b)
        timeFormatDesc:SetTextColor(r, g, b)
        darkModeDesc:SetTextColor(r, g, b)
        disableBagViewDesc:SetTextColor(r, g, b)
        disableOverlayDesc:SetTextColor(r, g, b)
        disableTeleportsDesc:SetTextColor(r, g, b)
    end

    C_Timer.After(0, function()
        ApplyOptionDescColors(lv.GetTheme())
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(timePlayedDesc, function(_, theme) ApplyOptionDescColors(theme) end)
            lv.RegisterThemedElement(timeFormatDesc, function(_, theme) ApplyOptionDescColors(theme) end)
            lv.RegisterThemedElement(darkModeDesc, function(_, theme) ApplyOptionDescColors(theme) end)
            lv.RegisterThemedElement(disableBagViewDesc, function(_, theme) ApplyOptionDescColors(theme) end)
            lv.RegisterThemedElement(disableOverlayDesc, function(_, theme) ApplyOptionDescColors(theme) end)
            lv.RegisterThemedElement(disableTeleportsDesc, function(_, theme) ApplyOptionDescColors(theme) end)
        end
    end)

    -- ======================================
    -- LANGUAGE SECTION
    -- ======================================

    -- Language section header
    local langSectionTitle = optionsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    langSectionTitle:SetText(L["TITLE_LANGUAGE_SELECT"])
    langSectionTitle:SetTextColor(1, 0.82, 0)

    -- Available languages
    local LANGUAGES = {
        {code = "auto", nameKey = "LANG_AUTO"},
        {code = "enUS", name = "English"},
        {code = "deDE", name = "Deutsch"},
        {code = "frFR", name = "Français"},
        {code = "esES", name = "Español"},
        {code = "ptBR", name = "Português"},
        {code = "ruRU", name = "Русский"},
        {code = "zhCN", name = "简体中文"},
        {code = "zhTW", name = "繁體中文"},
        {code = "koKR", name = "한국어"},
    }

    -- Store language buttons for updating
    local langButtons = {}
    local langDropdownExpanded = false

    local function GetCurrentLangCode()
        return lv.localeDebug.forcedLocale or "auto"
    end

    local function GetLanguageLabel(lang)
        return (lang and lang.nameKey and L[lang.nameKey]) or (lang and lang.name) or "Unknown"
    end

    local function GetOrderedLanguages()
        local currentLang = GetCurrentLangCode()
        local ordered = {}

        for _, lang in ipairs(LANGUAGES) do
            if lang.code == currentLang or (currentLang == "auto" and lang.code == "auto") then
                table.insert(ordered, lang)
                break
            end
        end

        for _, lang in ipairs(LANGUAGES) do
            if not (lang.code == currentLang or (currentLang == "auto" and lang.code == "auto")) then
                table.insert(ordered, lang)
            end
        end

        return ordered
    end

    -- Create language option buttons
    for i, lang in ipairs(LANGUAGES) do
        local btn = CreateFrame("Button", nil, optionsContent, "BackdropTemplate")
        btn:SetSize(languageButtonWidth, 20)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })

        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        btn.Text:SetPoint("CENTER")
        btn.Text:SetText(lang.nameKey and L[lang.nameKey] or lang.name)

        btn.langCode = lang.code
        btn.nameKey = lang.nameKey

        btn:SetScript("OnClick", function(self)
            local currentLang = GetCurrentLangCode()
            local isCurrent = (self.langCode == currentLang) or (currentLang == "auto" and self.langCode == "auto")

            if isCurrent then
                langDropdownExpanded = not langDropdownExpanded
                lv.UpdateLangButtons()
                if lv.UpdateOptionsPanelLayout then
                    lv.UpdateOptionsPanelLayout()
                end
                return
            end

            if self.langCode == "auto" then
                lv.localeDebug.forcedLocale = nil
                if LiteVaultDB then LiteVaultDB.forcedLocale = nil end
            else
                lv.localeDebug.forcedLocale = self.langCode
                if LiteVaultDB then LiteVaultDB.forcedLocale = self.langCode end
            end
            langDropdownExpanded = false

            -- Update all buttons immediately to show new selection
            lv.UpdateLangButtons()
            if lv.UpdateOptionsPanelLayout then
                lv.UpdateOptionsPanelLayout()
            end

            if lv.ReloadLocales then
                lv.ReloadLocales()
            end

            C_Timer.After(0, function()
                if lv.RefreshLocalizedUI then
                    lv.RefreshLocalizedUI()
                end
                lv.UpdateLangButtons()
                if lv.UpdateOptionsPanelLayout then
                    lv.UpdateOptionsPanelLayout()
                end
            end)
        end)

        btn:SetScript("OnEnter", function(self)
            local currentLang = GetCurrentLangCode()
            local isCurrent = (self.langCode == currentLang) or (currentLang == "auto" and self.langCode == "auto")
            if isCurrent or langDropdownExpanded then
                local t = lv.GetTheme()
                self:SetBackdropBorderColor(unpack(t.borderHover))
                self:SetBackdropColor(unpack(t.buttonBgHover))
            end
        end)

        btn:SetScript("OnLeave", function(self)
            lv.UpdateLangButtonStyle(self)
        end)

        langButtons[i] = btn
    end

    local optionRows = {
        { checkbox = disableTimePlayedCB, desc = timePlayedDesc },
        { checkbox = timeFormatCB, desc = timeFormatDesc },
        { checkbox = darkModeCB, desc = darkModeDesc },
        { checkbox = disableBagViewCB, desc = disableBagViewDesc },
        { checkbox = disableOverlayCB, desc = disableOverlayDesc },
        { checkbox = disableTeleportsCB, desc = disableTeleportsDesc },
    }

    function lv.UpdateOptionsPanelLayout()
        if not OptionsPanel then return end
        local contentWidth = math.max(1, optionsScroll:GetWidth() - 12)
        optionsContent:SetWidth(contentWidth)
        optionsLabelWidth = contentWidth - 55
        optionsDescWidth = contentWidth - 55
        languageButtonWidth = math.min(languageButtonBaseWidth, math.max(120, contentWidth - 20))

        disableTimePlayedCB.Text:SetWidth(optionsLabelWidth)
        timePlayedDesc:SetWidth(optionsDescWidth)
        timeFormatCB.Text:SetWidth(optionsLabelWidth)
        timeFormatDesc:SetWidth(optionsDescWidth)
        darkModeCB.Text:SetWidth(optionsLabelWidth)
        darkModeDesc:SetWidth(optionsDescWidth)
        disableBagViewCB.Text:SetWidth(optionsLabelWidth)
        disableBagViewDesc:SetWidth(optionsDescWidth)
        disableOverlayCB.Text:SetWidth(optionsLabelWidth)
        disableOverlayDesc:SetWidth(optionsDescWidth)
        disableTeleportsCB.Text:SetWidth(optionsLabelWidth)
        disableTeleportsDesc:SetWidth(optionsDescWidth)

        local topY = -35
        local rowGap = 14
        local descOffsetX = 30
        local descGap = 4
        local sectionGap = 18
        local languageGap = 20
        local buttonGap = 24

        langSectionTitle:ClearAllPoints()
        langSectionTitle:SetPoint("TOPLEFT", 15, topY)

        local langY = topY - languageGap
        local orderedLanguages = GetOrderedLanguages()
        local visibleButtonCount = 0
        for i, lang in ipairs(orderedLanguages) do
            local btn = langButtons[i]
            if btn then
                btn:SetSize(languageButtonWidth, 20)
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", 15, langY - (visibleButtonCount * buttonGap))
                local currentLang = GetCurrentLangCode()
                local isCurrent = (lang.code == currentLang) or (currentLang == "auto" and lang.code == "auto")
                btn:SetShown(isCurrent or langDropdownExpanded)
                if isCurrent or langDropdownExpanded then
                    visibleButtonCount = visibleButtonCount + 1
                end
            end
        end

        for i = #orderedLanguages + 1, #langButtons do
            local btn = langButtons[i]
            if btn then
                btn:Hide()
            end
        end

        local languageBlockBottomY = langY - (math.max(0, visibleButtonCount - 1) * buttonGap) - sectionGap - 10
        topY = languageBlockBottomY

        for _, row in ipairs(optionRows) do
            local cb = row.checkbox
            local desc = row.desc
            cb:ClearAllPoints()
            cb:SetPoint("TOPLEFT", 15, topY)

            local labelHeight = math.max(18, math.ceil(cb.Text:GetStringHeight() or 0))
            cb:SetHeight(math.max(24, labelHeight + 6))

            desc:ClearAllPoints()
            desc:SetPoint("TOPLEFT", cb, "TOPLEFT", descOffsetX, -(labelHeight + descGap))

            local descHeight = math.max(14, math.ceil(desc:GetStringHeight() or 0))
            topY = topY - math.max(cb:GetHeight() + descHeight + descGap, 52) - rowGap
        end

        local bottomY = topY - 22
        local contentHeight = math.max(optionsScroll:GetHeight(), math.abs(bottomY))
        optionsContent:SetHeight(contentHeight)
        optionsScroll:SetVerticalScroll(math.min(optionsScroll:GetVerticalScroll(), math.max(0, contentHeight - optionsScroll:GetHeight())))
    end

    -- Function to update language button styles
    function lv.UpdateLangButtonStyle(btn)
        local t = lv.GetTheme()
        local currentLang = GetCurrentLangCode()
        local isCurrent = (btn.langCode == currentLang) or (currentLang == "auto" and btn.langCode == "auto")

        if isCurrent then
            btn:SetBackdropColor(unpack(t.tabActive))
            btn:SetBackdropBorderColor(unpack(t.borderPrimary))
            btn.Text:SetTextColor(1, 0.82, 0)
        else
            btn:SetBackdropColor(unpack(t.buttonBg))
            btn:SetBackdropBorderColor(unpack(t.borderSubdued))
            btn.Text:SetTextColor(unpack(t.textSecondary))
        end
    end

    -- Function to update all language buttons
    function lv.UpdateLangButtons()
        local orderedLanguages = GetOrderedLanguages()
        local currentLang = GetCurrentLangCode()
        for i, lang in ipairs(orderedLanguages) do
            local btn = langButtons[i]
            if btn then
                btn.langCode = lang.code
                btn.nameKey = lang.nameKey
                local label = GetLanguageLabel(lang)
                btn.Text:SetText(label)
                lv.UpdateLangButtonStyle(btn)
            end
        end
        if lv.UpdateOptionsPanelLayout then
            lv.UpdateOptionsPanelLayout()
        end
    end

    -- Initialize button states and register for theming
    C_Timer.After(0.1, function()
        lv.UpdateLangButtons()
        if lv.UpdateOptionsPanelLayout then
            lv.UpdateOptionsPanelLayout()
        end
        -- Register each language button for theming
        if lv.RegisterThemedElement then
            for _, btn in ipairs(langButtons) do
                lv.RegisterThemedElement(btn, function(b, theme)
                    lv.UpdateLangButtonStyle(b)
                end)
            end
        end
    end)

    changeLogBtn = CreateFrame("Button", nil, OptionsPanel, "BackdropTemplate")
    changeLogBtn:SetSize(96, 24)
    changeLogBtn:SetPoint("BOTTOMRIGHT", OptionsPanel, "BOTTOMRIGHT", -16, 12)
    changeLogBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    changeLogBtn.Text = changeLogBtn:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
    changeLogBtn.Text:SetPoint("CENTER")
    lv.UpdateChangeLogButtonLabel()
    changeLogBtn:SetScript("OnClick", function()
        SetOptionsSubpanel(not showingChangeLog)
    end)
    changeLogBtn:SetScript("OnEnter", function(self)
        if showingChangeLog then return end
        local t = lv.GetTheme()
        self:SetBackdropColor(unpack(t.buttonBgHover or t.buttonBg))
        self:SetBackdropBorderColor(unpack(t.borderHover or t.borderPrimary))
    end)
    changeLogBtn:SetScript("OnLeave", function()
        UpdateChangeLogButtonStyle()
    end)

    C_Timer.After(0, function()
        lv.UpdateChangeLogContent()
        UpdateChangeLogButtonStyle()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(changeLogBtn, function()
                UpdateChangeLogButtonStyle()
            end)
        end
    end)

    -- Store references
    lv.OptionsPanel = OptionsPanel
    lv.changeLogBtn = changeLogBtn
    lv.changeLogPanel = changeLogPanel
    lv.changeLogTitle = changeLogTitle
    lv.changeLogText = changeLogText
    lv.optionsPanelTitle = optionsPanelTitle
    lv.disableTimePlayedCB = disableTimePlayedCB
    lv.timePlayedDesc = timePlayedDesc
    lv.timeFormatCB = timeFormatCB
    lv.timeFormatDesc = timeFormatDesc
    lv.darkModeCB = darkModeCB
    lv.darkModeDesc = darkModeDesc
    lv.disableBagViewCB = disableBagViewCB
    lv.disableBagViewDesc = disableBagViewDesc
    lv.disableOverlayCB = disableOverlayCB
    lv.disableOverlayDesc = disableOverlayDesc
    lv.disableTeleportsCB = disableTeleportsCB
    lv.disableTeleportsDesc = disableTeleportsDesc
    lv.langSectionTitle = langSectionTitle

    lv.ToggleOptionsPanel = function()
        if lv.SetMainView then
            if lv.GetMainView and lv.GetMainView() == "options" then
                lv.SetMainView("dashboard")
            else
                lv.SetMainView("options")
            end
        else
            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
            if lv.CloseAuxPanels then lv.CloseAuxPanels("options") end
            if OptionsPanel:IsShown() then
                OptionsPanel:Hide()
            else
                -- Refresh checkbox states
                if LiteVaultDB then
                    disableTimePlayedCB:SetChecked(LiteVaultDB.disableTimePlayed or false)
                    local use24 = false
                    if GetCVarBool then
                        use24 = GetCVarBool("timeMgrUseMilitaryTime")
                    else
                        use24 = (LiteVaultDB.use24HourClock ~= false)
                    end
                    timeFormatCB:SetChecked(use24 and true or false)
                    disableBagViewCB:SetChecked(LiteVaultDB.disableBagViewing or false)
                    disableOverlayCB:SetChecked(LiteVaultDB.disableCharacterOverlay or false)
                    disableTeleportsCB:SetChecked(LiteVaultDB.disableMPlusTeleports or false)
                end
                darkModeCB:SetChecked(lv.currentTheme == "dark")
                SetOptionsSubpanel(false)
                lv.UpdateLangButtons()
                if lv.UpdateOptionsPanelLayout then
                    lv.UpdateOptionsPanelLayout()
                end
                OptionsPanel:Show()
            end
        end
    end

    local manageBtn = CreateFrame("Button", nil, charBg, "BackdropTemplate")
    manageBtn:SetSize(90, 26) -- Increased from 80x22 to 90x26
    manageBtn:SetPoint("TOPLEFT", charBg, "TOPLEFT", 12, -10)
    manageBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })

    manageBtn.Text = manageBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal") -- Changed from Small to Normal
    manageBtn.Text:SetPoint("CENTER")
    manageBtn.Text:SetText(L["BUTTON_MANAGE"])

    -- Store reference for theming
    lv.manageBtn = manageBtn

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(manageBtn, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            manageBtn:SetBackdropColor(unpack(t.buttonBgAlt))
            manageBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
            manageBtn.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    manageBtn:SetScript("OnClick", function()
        if lv.HideAllActionMenus then lv.HideAllActionMenus() end
        if lv.CloseAuxPanels then lv.CloseAuxPanels(nil) end
        isManaging = not isManaging
        manageBtn.Text:SetText(isManaging and L["BUTTON_BACK"] or L["BUTTON_MANAGE"])
        if lv.UpdateUI then lv.UpdateUI() end
    end)
    manageBtn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["TOOLTIP_MANAGE_TITLE"], 1, 0.82, 0)
        if isManaging then
            GameTooltip:AddLine(L["TOOLTIP_MANAGE_BACK"], 1, 1, 1, true)
        else
            GameTooltip:AddLine(L["TOOLTIP_MANAGE_VIEW"], 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    manageBtn:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt))
        self.Text:SetTextColor(unpack(t.textPrimary))
        GameTooltip:Hide()
    end)
end

-- 2. LIST UPDATE (ENHANCED WITH NEW FEATURES)
function lv.UpdateList()
    local reopenActionMenuForChar = lv._reopenActionMenuForChar
    lv._reopenActionMenuForChar = nil

    for _, r in pairs(rows) do r:Hide() end
    local idx, totG, totP = 1, 0, 0
    lv.SyncOrderList()

    if LiteVaultOrder and LiteVaultDB then
        for i, name in ipairs(LiteVaultOrder) do
            local data = LiteVaultDB[name]
            if data and type(data) == "table" and data.class
                and (not data.region or data.region == lv.REGION) then
                if (isManaging and data.isIgnored) or (not isManaging and not data.isIgnored) then
                    if not rows[idx] then
                        local r = CreateFrame("Frame", nil, ContentChar)
                        r:SetSize(490, 250) -- Increased to 250 for profession display
                        r:EnableMouse(true)
                        r:SetScript("OnMouseUp", HandleCharacterCardMouseUp)
                        
                        -- Portrait/Class Icon Frame
                        r.pFrame = CreateFrame("Frame", nil, r, "BackdropTemplate")
                        r.pFrame:SetSize(70, 70)
                        r.pFrame:SetPoint("LEFT", 20, 20)
                        r.pFrame:EnableMouse(true)
                        r.pFrame:SetScript("OnMouseUp", HandleCharacterCardMouseUp)
                        r.pFrame:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 12
                        })
                        local t = lv.GetTheme()
                        -- Dedicated outer class ring so thickness can be adjusted
                        -- without changing portrait scale/appearance.
                        r.pClassBorder = CreateFrame("Frame", nil, r, "BackdropTemplate")
                        r.pClassBorder:SetPoint("TOPLEFT", r.pFrame, "TOPLEFT", -3, 3)
                        r.pClassBorder:SetPoint("BOTTOMRIGHT", r.pFrame, "BOTTOMRIGHT", 3, -3)
                        r.pClassBorder:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Buttons\\WHITE8X8",
                            edgeSize = 4
                        })
                        r.pClassBorder:SetBackdropColor(0, 0, 0, 0)
                        r.pClassBorder:SetBackdropBorderColor(unpack(t.portraitBorder))
                        r.pClassBorder:SetFrameLevel(r.pFrame:GetFrameLevel() + 2)
                        r.pFrame:SetBackdropColor(unpack(t.background))
                        r.pFrame:SetBackdropBorderColor(unpack(t.portraitBorder))
                        
                        r.face = r.pFrame:CreateTexture(nil, "ARTWORK")
                        r.face:SetSize(62, 62)
                        r.face:SetPoint("CENTER", 0, 0)

                        r.levelBadge = CreateFrame("Frame", nil, r, "BackdropTemplate")
                        r.levelBadge:SetSize(30, 30)
                        r.levelBadge.outer = r.levelBadge:CreateTexture(nil, "BACKGROUND")
                        r.levelBadge.outer:SetAllPoints()
                        r.levelBadge.outer:SetTexture("Interface\\Buttons\\WHITE8X8")
                        r.levelBadge.outer:SetVertexColor(unpack(t.portraitBorder))
                        r.levelBadge.outerMask = r.levelBadge:CreateMaskTexture()
                        r.levelBadge.outerMask:SetAllPoints(r.levelBadge.outer)
                        r.levelBadge.outerMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.levelBadge.outer:AddMaskTexture(r.levelBadge.outerMask)

                        r.levelBadge.inner = r.levelBadge:CreateTexture(nil, "BORDER")
                        r.levelBadge.inner:SetPoint("TOPLEFT", 2, -2)
                        r.levelBadge.inner:SetPoint("BOTTOMRIGHT", -2, 2)
                        r.levelBadge.inner:SetTexture("Interface\\Buttons\\WHITE8X8")
                        r.levelBadge.inner:SetVertexColor(0.02, 0.02, 0.02, 0.92)
                        r.levelBadge.innerMask = r.levelBadge:CreateMaskTexture()
                        r.levelBadge.innerMask:SetAllPoints(r.levelBadge.inner)
                        r.levelBadge.innerMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.levelBadge.inner:AddMaskTexture(r.levelBadge.innerMask)

                        r.levelText = r.levelBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        r.levelText:SetPoint("CENTER", 0, 0)
                        r.levelText:SetJustifyH("CENTER")
                        r.levelText:SetTextColor(1, 0.82, 0)
                        r.levelText:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
                        r.levelText:SetShadowOffset(1, -1)
                        r.levelText:SetShadowColor(0, 0, 0, 1)

                        r.portraitIlvlText = r.pFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        r.portraitIlvlText:SetPoint("BOTTOMLEFT", r.pFrame, "BOTTOMLEFT", 2, 2)
                        r.portraitIlvlText:SetJustifyH("LEFT")
                        r.portraitIlvlText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                        r.portraitIlvlText:SetShadowOffset(1, -1)
                        r.portraitIlvlText:SetShadowColor(0, 0, 0, 1)

                        r.portraitTimeText = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        r.portraitTimeText:SetPoint("BOTTOMRIGHT", r.pFrame, "TOPRIGHT", 0, 7)
                        r.portraitTimeText:SetJustifyH("RIGHT")
                        r.portraitTimeText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                        r.portraitTimeText:SetShadowOffset(1, -1)
                        r.portraitTimeText:SetShadowColor(0, 0, 0, 1)
                        
                        -- No mask - square portraits!
                        
                        -- Character Name
                        r.nameText = r:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
                        r.nameText:SetPoint("TOPLEFT", 105, -36)

                        r.identityText = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        r.identityText:SetPoint("LEFT", r.nameText, "RIGHT", 12, -3)
                        r.identityText:SetJustifyH("LEFT")
                        if lv.ApplyLocaleFont then
                            lv.ApplyLocaleFont(r.identityText, 12)
                        end

                        -- Freshness Indicator under the currency button
                        r.freshnessFrame = CreateFrame("Frame", nil, r)
                        r.freshnessFrame:SetSize(92, 12)
                        r.freshnessFrame:SetFrameLevel(r:GetFrameLevel() + 10)

                        r.freshnessText = r.freshnessFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        r.freshnessText:SetPoint("LEFT", 0, 0)
                        r.freshnessText:SetWidth(92)
                        r.freshnessText:SetJustifyH("LEFT")
                        if lv.ApplyLocaleFont then
                            lv.ApplyLocaleFont(r.freshnessText, 12)
                        end
                        
                        -- Raid Progress and Time (second line) - now includes iLvl
                        r.topDataText = r:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        r.topDataText:SetPoint("TOPLEFT", r.nameText, "BOTTOMLEFT", 0, -6)
                        
                        -- Main Data Box - larger and more organized
                        r.dataBox = CreateFrame("Frame", nil, r, "BackdropTemplate")
                        r.dataBox:SetPoint("TOPLEFT", 105, -58)
                        r.dataBox:SetPoint("BOTTOMRIGHT", -15, 15)
                        r.dataBox:EnableMouse(true)
                        if r.dataBox.SetPropagateMouseClicks then
                            r.dataBox:SetPropagateMouseClicks(true)
                        end
                        r.dataBox:SetScript("OnMouseUp", HandleCharacterCardMouseUp)
                        r.dataBox:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10
                        })
                        r.dataBox:SetBackdropColor(unpack(t.dataBoxBg))
                        r.dataBox:SetBackdropBorderColor(unpack(t.portraitBorder))
                        r.levelBadge:SetPoint("CENTER", r.pFrame, "TOPLEFT", -2, 2)
                        r.levelBadge:SetFrameLevel(r.pFrame:GetFrameLevel() + 4)
                        
                        -- Top row: M+ Score (iLvl moved to topDataText)
                        r.mplusText = r.dataBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        r.mplusText:SetPoint("TOPLEFT", 15, -15)
                        
                        -- Second row: Catalyst and Sparks
                        r.upgradeFrame = CreateFrame("Button", nil, r.dataBox, "BackdropTemplate")
                        r.upgradeFrame:SetPoint("BOTTOMLEFT", r.dataBox, "BOTTOMLEFT", 94, 50)
                        r.upgradeFrame:SetSize(96, 28)
                        r.upgradeFrame:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.upgradeFrame:SetBackdropColor(unpack(t.dataBoxBgVault))
                        r.upgradeFrame:SetBackdropBorderColor(unpack(t.portraitBorder))

                        r.catalystBtn = CreateFrame("Frame", nil, r.upgradeFrame)
                        r.catalystBtn:SetPoint("LEFT", r.upgradeFrame, "LEFT", 8, 0)
                        r.catalystBtn:SetSize(30, 24)

                        r.catalystBadge = CreateCircularBadge(r.catalystBtn, "LEFT", r.catalystBtn, "LEFT", 0, 0, DATA_BADGE_STYLE)
                        r.catalystBtn.badge = r.catalystBadge
                        r.catalystIcon = r.catalystBadge.icon
                        local catInfo = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(lv.CATALYST_ID)
                        SetCircularBadgeTexture(r.catalystBadge, (catInfo and catInfo.iconFileID) or 610613)

                        r.catalystText = r.catalystBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        r.catalystText:SetPoint("LEFT", r.catalystBadge, "RIGHT", 4, 0)

                        r.sparkBtn = CreateFrame("Frame", nil, r.upgradeFrame)
                        r.sparkBtn:SetPoint("LEFT", r.catalystBtn, "RIGHT", 12, 0)
                        r.sparkBtn:SetSize(30, 24)

                        r.sparkBadge = CreateCircularBadge(r.sparkBtn, "LEFT", r.sparkBtn, "LEFT", 0, 0, DATA_BADGE_STYLE)
                        r.sparkBtn.badge = r.sparkBadge

                        r.sparkText = r.sparkBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        r.sparkText:SetPoint("LEFT", r.sparkBadge, "RIGHT", 4, 0)

                        r.upgradeFrame.catalystBadge = r.catalystBadge
                        r.upgradeFrame.sparkBadge = r.sparkBadge
                        r.upgradeFrame:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
                            self:SetBackdropColor(unpack(theme.buttonBgHover or theme.dataBoxBgVault))
                            if self.catalystBadge then
                                SetCircularBadgeState(self.catalystBadge, true)
                            end
                            if self.sparkBadge then
                                SetCircularBadgeState(self.sparkBadge, true)
                            end
                            GameTooltip:SetOwner(self, "ANCHOR_TOP")
                            GameTooltip:SetText(string.format("%s / %s", L["TOOLTIP_CATALYST_TITLE"], L["TOOLTIP_SPARKS_TITLE"]), 1, 0.82, 0)
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddDoubleLine(L["TOOLTIP_CATALYST_TITLE"], tostring(self.catalystCount or 0), 1, 1, 1, 0, 0.82, 1)
                            GameTooltip:AddDoubleLine(L["TOOLTIP_SPARKS_TITLE"], tostring(self.fullSparks or 0), 1, 1, 1, 1, 0.67, 0)
                            GameTooltip:Show()
                        end)
                        r.upgradeFrame:SetScript("OnLeave", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.portraitBorder or theme.borderPrimary))
                            self:SetBackdropColor(unpack(theme.dataBoxBgVault or theme.buttonBg))
                            if self.catalystBadge then
                                SetCircularBadgeState(self.catalystBadge, false)
                            end
                            if self.sparkBadge then
                                SetCircularBadgeState(self.sparkBadge, false)
                            end
                            GameTooltip:Hide()
                        end)

                        r.teleportBtn = CreateFrame("Button", nil, r.dataBox)
                        r.teleportBtn:SetPoint("LEFT", r.upgradeFrame, "RIGHT", 18, 0)
                        r.teleportBtn:SetSize(60, 20)

                        r.teleportText = r.teleportBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        r.teleportText:SetPoint("LEFT")

                        r.teleportBtn:SetScript("OnEnter", function(self)
                            if not self.tpCount or self.tpCount <= 0 then return end
                            GameTooltip:SetOwner(self, "ANCHOR_TOP")
                            GameTooltip:SetText((L["TELEPORT_PANEL_TITLE"] ~= "TELEPORT_PANEL_TITLE") and L["TELEPORT_PANEL_TITLE"] or "M+ Teleports", 1, 0.82, 0)
                            GameTooltip:AddLine(string.format("%d/%d", self.tpCount or 0, #(lv.TELEPORT_DUNGEONS or {})), 1, 1, 1)
                            GameTooltip:Show()
                        end)
                        r.teleportBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                        
                        -- Gold - prominent on right side
                        r.goldText = r.dataBox:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.goldText:SetPoint("TOPRIGHT", -80, -15) -- Moved further left from -50 to -95 to make room for pin button
                        
                        -- Third row: M+ Key
                        r.keyText = r.dataBox:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.keyText:SetPoint("TOPLEFT", r.mplusText, "BOTTOMLEFT", 0, -45)
                        r.keyText:SetWidth(190)
                        r.keyText:SetJustifyH("LEFT")
                        r.keyText:SetWordWrap(false)
                        if r.keyText.SetMaxLines then
                            r.keyText:SetMaxLines(1)
                        end
                        
                        -- Profession Display (below key row)
                        r.professionFrame = CreateFrame("Button", nil, r.dataBox, "BackdropTemplate")
                        r.professionFrame:SetPoint("BOTTOMLEFT", r.dataBox, "BOTTOMLEFT", 10, 50)
                        r.professionFrame:SetSize(270, 28)
                        r.professionFrame:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.professionFrame:SetBackdropColor(unpack(t.dataBoxBgVault))
                        r.professionFrame:SetBackdropBorderColor(unpack(t.portraitBorder))
                        r.professionFrame:RegisterForClicks("LeftButtonUp")

                        -- Create two profession icon+text slots
                        r.prof1Badge = CreateProfessionBadge(r.professionFrame, "LEFT", r.professionFrame, "LEFT", 7, 0)
                        r.prof1Badge:Hide()
                        r.prof1Icon = r.prof1Badge.icon

                        r.prof1Text = r.professionFrame:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.prof1Text:SetPoint("LEFT", r.prof1Badge, "RIGHT", 4, 0)

                        r.prof2Badge = CreateProfessionBadge(r.professionFrame, "LEFT", r.prof1Text, "RIGHT", 15, 0)
                        r.prof2Badge:Hide()
                        r.prof2Icon = r.prof2Badge.icon

                        r.prof2Text = r.professionFrame:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.prof2Text:SetPoint("LEFT", r.prof2Badge, "RIGHT", 4, 0)
                        r.professionFrame.prof1Badge = r.prof1Badge
                        r.professionFrame.prof2Badge = r.prof2Badge

                        r.professionFrame:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
                            self:SetBackdropColor(unpack(theme.buttonBgHover or theme.dataBoxBgVault))
                            if self.prof1Badge and self.prof1Badge:IsShown() then
                                SetCircularBadgeState(self.prof1Badge, true)
                            end
                            if self.prof2Badge and self.prof2Badge:IsShown() then
                                SetCircularBadgeState(self.prof2Badge, true)
                            end
                            GameTooltip:SetOwner(self, "ANCHOR_TOP")
                            GameTooltip:SetText(L["TOOLTIP_PROFS_TITLE"], 1, 0.82, 0)
                            GameTooltip:AddLine(L["TOOLTIP_PROFS_DESC"], 0.85, 0.85, 0.85, true)
                            if self.professionNames and #self.professionNames > 0 then
                                GameTooltip:AddLine(" ")
                                for _, profName in ipairs(self.professionNames) do
                                    GameTooltip:AddLine("* " .. profName, 1, 1, 1)
                                end
                            end
                            GameTooltip:Show()
                        end)
                        r.professionFrame:SetScript("OnLeave", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.portraitBorder or theme.borderPrimary))
                            self:SetBackdropColor(unpack(theme.dataBoxBgVault or theme.buttonBg))
                            if self.prof1Badge then
                                SetCircularBadgeState(self.prof1Badge, false)
                            end
                            if self.prof2Badge then
                                SetCircularBadgeState(self.prof2Badge, false)
                            end
                            GameTooltip:Hide()
                        end)
                        r.professionFrame:SetScript("OnClick", function(self)
                            local row = self:GetParent():GetParent()
                            if not row then
                                return
                            end
                            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                            if lv.CloseAuxPanels then lv.CloseAuxPanels("professions") end
                            if lv.ShowProfessionWindow then
                                lv.ShowProfessionWindow(row.charName)
                            end
                        end)

                        -- Vault Progress Box - at the bottom
                        r.vaultBox = CreateFrame("Button", nil, r, "BackdropTemplate")
                        r.vaultBox:SetPoint("BOTTOMLEFT", r.dataBox, "BOTTOMLEFT", 10, 12)
                        r.vaultBox:SetSize(270, 28)
                        r.vaultBox:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.vaultBox:SetBackdropColor(unpack(t.dataBoxBgVault))
                        r.vaultBox:SetBackdropBorderColor(unpack(t.portraitBorder))
                        r.vaultBox:RegisterForClicks("LeftButtonUp")
                        
                        r.vaultProgress = CreateFrame("Frame", nil, r.vaultBox)
                        r.vaultProgress:SetSize(236, 20)
                        r.vaultProgress:SetPoint("CENTER", 0, 0)

                        r.vaultRaid = CreateVaultProgressSegment(r.vaultProgress, "LEFT", r.vaultProgress, "LEFT", 0, 0, "Raid", 16)
                        r.vaultRaid:SetSize(72, 20)

                        r.vaultMythic = CreateVaultProgressSegment(r.vaultProgress, "LEFT", r.vaultRaid, "RIGHT", 8, 0, "Dungeon", 16)
                        r.vaultMythic:SetSize(76, 20)

                        r.vaultDelve = CreateVaultProgressSegment(r.vaultProgress, "LEFT", r.vaultMythic, "RIGHT", 8, 0, "delves-regular", 18)
                        r.vaultDelve:SetSize(76, 20)

                        LayoutProfessionTracker(r, 0)

                        SetVaultProgressCounts(r, 0, 0, 0)

                        r.vaultBox:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            local row = self:GetParent()
                            local isActiveChar = row and row.charName == lv.PLAYER_KEY
                            self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
                            self:SetBackdropColor(unpack(theme.buttonBgHover or theme.dataBoxBgVault))
                            SetVaultProgressTextColor(r, theme.textPrimary or {1, 1, 1, 1})
                            GameTooltip:SetOwner(self, "ANCHOR_TOP")
                            if isActiveChar then
                                GameTooltip:SetText((L["BUTTON_VAULT"] ~= "BUTTON_VAULT") and L["BUTTON_VAULT"] or "Vault", 1, 0.82, 0)
                                GameTooltip:AddLine((L["TOOLTIP_VAULT_STATUS"] ~= "TOOLTIP_VAULT_STATUS") and L["TOOLTIP_VAULT_STATUS"] or "Check vault status.", 1, 1, 1)
                            else
                                GameTooltip:SetText((L["BUTTON_VAULT"] ~= "BUTTON_VAULT") and L["BUTTON_VAULT"] or "Vault", 1, 0.82, 0)
                                GameTooltip:AddLine((L["TOOLTIP_VAULT_STATUS"] ~= "TOOLTIP_VAULT_STATUS") and L["TOOLTIP_VAULT_STATUS"] or "Check vault status.", 0.85, 0.85, 0.85, true)
                            end
                            GameTooltip:Show()
                        end)
                        r.vaultBox:SetScript("OnLeave", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.portraitBorder or theme.borderPrimary))
                            self:SetBackdropColor(unpack(theme.dataBoxBgVault or theme.buttonBg))
                            SetVaultProgressTextColor(r, {1, 0.82, 0, 1})
                            GameTooltip:Hide()
                        end)
                        r.vaultBox:SetScript("OnClick", function(self)
                            local row = self:GetParent()
                            if not row then
                                return
                            end
                            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                            if lv.CloseAuxPanels then lv.CloseAuxPanels("vault") end
                            if lv.ShowVaultWindow then
                                lv.ShowVaultWindow(row.charName)
                            end
                        end)
                        
                        -- Currency Button
                        r.currencyBtn = CreateFrame("Button", nil, r)
                        r.currencyBtn:SetSize(36, 36)
                        r.currencyBtn:SetPoint("BOTTOMRIGHT", r.dataBox, "BOTTOMRIGHT", -24, 24)
                        r.currencyBtn:EnableMouse(true)

                        r.currencyBtn.hover = r.currencyBtn:CreateTexture(nil, "BACKGROUND")
                        r.currencyBtn.hover:SetSize(30, 30)
                        r.currencyBtn.hover:SetPoint("CENTER")
                        r.currencyBtn.hover:SetTexture("Interface\\Buttons\\WHITE8X8")
                        r.currencyBtn.hover:SetVertexColor(1, 0.88, 0.35, 0.08)
                        r.currencyBtn.hoverMask = r.currencyBtn:CreateMaskTexture()
                        r.currencyBtn.hoverMask:SetAllPoints(r.currencyBtn.hover)
                        r.currencyBtn.hoverMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.currencyBtn.hover:AddMaskTexture(r.currencyBtn.hoverMask)
                        r.currencyBtn.hover:Hide()

                        r.currencyBtn.shell = r.currencyBtn:CreateTexture(nil, "BORDER")
                        r.currencyBtn.shell:SetSize(28, 28)
                        r.currencyBtn.shell:SetPoint("CENTER")
                        r.currencyBtn.shell:SetTexture("Interface\\Buttons\\WHITE8X8")
                        r.currencyBtn.shell:SetVertexColor(unpack(CURRENCY_BADGE_PALETTE.default.shell))
                        r.currencyBtn.shellMask = r.currencyBtn:CreateMaskTexture()
                        r.currencyBtn.shellMask:SetAllPoints(r.currencyBtn.shell)
                        r.currencyBtn.shellMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.currencyBtn.shell:AddMaskTexture(r.currencyBtn.shellMask)

                        r.currencyBtn.inner = r.currencyBtn:CreateTexture(nil, "ARTWORK")
                        r.currencyBtn.inner:SetSize(24, 24)
                        r.currencyBtn.inner:SetPoint("CENTER")
                        r.currencyBtn.inner:SetTexture("Interface\\Buttons\\WHITE8X8")
                        r.currencyBtn.inner:SetVertexColor(unpack(CURRENCY_BADGE_PALETTE.default.inner))
                        r.currencyBtn.innerMask = r.currencyBtn:CreateMaskTexture()
                        r.currencyBtn.innerMask:SetAllPoints(r.currencyBtn.inner)
                        r.currencyBtn.innerMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.currencyBtn.inner:AddMaskTexture(r.currencyBtn.innerMask)

                        r.currencyBtn.icon = r.currencyBtn:CreateTexture(nil, "ARTWORK")
                        r.currencyBtn.icon:SetSize(24, 24)
                        r.currencyBtn.icon:SetPoint("CENTER")
                        r.currencyBtn.icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)
                        r.currencyBtn.icon:SetTexture(GetCurrencyButtonIcon())
                        r.currencyBtn.icon:SetBlendMode("BLEND")
                        r.currencyBtn.icon:SetVertexColor(unpack(CURRENCY_BADGE_PALETTE.default.icon))
                        r.currencyBtn.iconMask = r.currencyBtn:CreateMaskTexture()
                        r.currencyBtn.iconMask:SetAllPoints(r.currencyBtn.icon)
                        r.currencyBtn.iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.currencyBtn.icon:AddMaskTexture(r.currencyBtn.iconMask)

                        r.currencyBtn.iconBoost = r.currencyBtn:CreateTexture(nil, "OVERLAY")
                        r.currencyBtn.iconBoost:SetSize(24, 24)
                        r.currencyBtn.iconBoost:SetPoint("CENTER")
                        r.currencyBtn.iconBoost:SetTexCoord(0.04, 0.96, 0.04, 0.96)
                        r.currencyBtn.iconBoost:SetTexture(GetCurrencyButtonIcon())
                        r.currencyBtn.iconBoost:SetBlendMode("ADD")
                        r.currencyBtn.iconBoost:SetVertexColor(unpack(CURRENCY_BADGE_PALETTE.default.boost))
                        r.currencyBtn.iconBoostMask = r.currencyBtn:CreateMaskTexture()
                        r.currencyBtn.iconBoostMask:SetAllPoints(r.currencyBtn.iconBoost)
                        r.currencyBtn.iconBoostMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.currencyBtn.iconBoost:AddMaskTexture(r.currencyBtn.iconBoostMask)
                        SetCurrencyBadgeTexture(r.currencyBtn)
                        SetCurrencyBadgeState(r.currencyBtn, false)

                        r.currencyBtn:SetScript("OnClick", function(self)
                            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                            if lv.CloseAuxPanels then lv.CloseAuxPanels("currency") end
                            lv.ShowCurrencyWindow(self:GetParent().charName)
                        end)

                        r.currencyBtn:SetScript("OnEnter", function(self)
                            SetCurrencyBadgeState(self, true)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["TOOLTIP_CURRENCY_TITLE"], 1, 0.82, 0)
                            GameTooltip:AddLine(L["TOOLTIP_CURRENCY_DESC"], 1, 1, 1)
                            GameTooltip:Show()
                        end)
                        r.currencyBtn:SetScript("OnLeave", function(self)
                            SetCurrencyBadgeState(self, false)
                            GameTooltip:Hide()
                        end)
                        r.freshnessFrame:SetPoint("TOP", r.currencyBtn, "BOTTOM", 0, -5)
                        r.freshnessText:SetJustifyH("CENTER")

                        -- Ledger Button (Weekly Profit) - positioned under portrait
                        r.ledgerBtn = CreateFrame("Button", nil, r, "BackdropTemplate")
                        r.ledgerBtn:SetSize(76, 24)
                        r.ledgerBtn:SetPoint("TOP", r.freshnessText, "BOTTOM", 0, -4)
                        r.ledgerBtn:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.ledgerBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                        r.ledgerBtn:SetBackdropBorderColor(unpack(t.borderPrimary))

                        r.ledgerBtn.badge = CreateCircularBadge(r.ledgerBtn, "LEFT", r.ledgerBtn, "LEFT", 4, 0, LEDGER_BADGE_STYLE)
                        r.ledgerBtn.icon = r.ledgerBtn.badge.icon
                        SetCircularBadgeTexture(r.ledgerBtn.badge, "Interface\\Icons\\INV_Misc_Coin_02")

                        r.ledgerBtn.text = r.ledgerBtn:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.ledgerBtn.text:SetPoint("LEFT", r.ledgerBtn.badge, "RIGHT", 4, 0)
                        r.ledgerBtn.text:SetText(L["BUTTON_LEDGER"])

                        r.ledgerBtn:SetScript("OnClick", function(self)
                            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                            if lv.CloseAuxPanels then lv.CloseAuxPanels("ledger") end
                            lv.ShowLedgerWindow(self:GetParent().charName)
                        end)
                        r.ledgerBtn:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover))
                            if self.badge then
                                SetCircularBadgeState(self.badge, true)
                            end
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["TOOLTIP_LEDGER_TITLE"], 1, 0.82, 0)
                            GameTooltip:AddLine(L["TOOLTIP_LEDGER_DESC"], 1, 1, 1)
                            GameTooltip:Show()
                        end)
                        r.ledgerBtn:SetScript("OnLeave", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderPrimary))
                            if self.badge then
                                SetCircularBadgeState(self.badge, false)
                            end
                            GameTooltip:Hide()
                        end)

                        -- Bags Button - positioned above the currency button
                        r.bagsBtn = CreateFrame("Button", nil, r, "BackdropTemplate")
                        r.bagsBtn:SetSize(50, 22)
                        r.bagsBtn:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.bagsBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                        r.bagsBtn:SetBackdropBorderColor(unpack(t.borderPrimary))

                        r.bagsBtn.icon = r.bagsBtn:CreateTexture(nil, "ARTWORK")
                        r.bagsBtn.icon:SetSize(16, 16)
                        r.bagsBtn.icon:SetPoint("LEFT", 4, 0)
                        r.bagsBtn.icon:SetTexture("Interface\\ContainerFrame\\Backpack-Bag-Icon")

                        r.bagsBtn.text = r.bagsBtn:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.bagsBtn.text:SetPoint("LEFT", r.bagsBtn.icon, "RIGHT", -12, 0)
                        r.bagsBtn.text:SetText((L["BUTTON_BAGS"] ~= "BUTTON_BAGS") and L["BUTTON_BAGS"] or "Bags")

                        r.bagsBtn:SetScript("OnClick", function(self)
                            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                            if lv.CloseAuxPanels then lv.CloseAuxPanels("bags") end
                            if lv.OpenBagPanel then
                                lv.OpenBagPanel(self:GetParent().charName)
                            end
                        end)
                        r.bagsBtn:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover))
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText((L["TOOLTIP_BAGS_TITLE"] ~= "TOOLTIP_BAGS_TITLE") and L["TOOLTIP_BAGS_TITLE"] or "View Bags", 1, 0.82, 0)
                            GameTooltip:AddLine((L["TOOLTIP_BAGS_DESC"] ~= "TOOLTIP_BAGS_DESC") and L["TOOLTIP_BAGS_DESC"] or "View saved bag contents and reagent bag items for this character", 1, 1, 1, true)
                            GameTooltip:Show()
                        end)
                        r.bagsBtn:SetScript("OnLeave", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderPrimary))
                            GameTooltip:Hide()
                        end)

                        -- Raid Button - compact icon button stacked above the currency button
                        r.raidBtn = CreateFrame("Button", nil, r)
                        r.raidBtn:SetSize(44, 44)
                        r.raidBtn:SetPoint("BOTTOM", r.currencyBtn, "TOP", 0, 6)
                        r.raidBtn:EnableMouse(true)

                        r.raidBtn.hover = r.raidBtn:CreateTexture(nil, "BACKGROUND")
                        r.raidBtn.hover:SetSize(32, 32)
                        r.raidBtn.hover:SetPoint("CENTER")
                        r.raidBtn.hover:SetTexture("Interface\\Buttons\\WHITE8X8")
                        r.raidBtn.hover:SetVertexColor(1, 0.88, 0.35, 0.10)
                        r.raidBtn.hoverMask = r.raidBtn:CreateMaskTexture()
                        r.raidBtn.hoverMask:SetAllPoints(r.raidBtn.hover)
                        r.raidBtn.hoverMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                        r.raidBtn.hover:AddMaskTexture(r.raidBtn.hoverMask)
                        r.raidBtn.hover:Hide()

                        r.raidBtn.icon = r.raidBtn:CreateTexture(nil, "ARTWORK")
                        r.raidBtn.icon:SetSize(32, 32)
                        r.raidBtn.icon:SetPoint("CENTER")
                        r.raidBtn.icon:SetAtlas("Raid")

                        r.raidBtn:SetScript("OnClick", function(self)
                            if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                            if lv.CloseAuxPanels then lv.CloseAuxPanels("raids") end
                            if lv.ShowRaidLockoutWindow then
                                lv.ShowRaidLockoutWindow(self:GetParent().charName)
                            end
                        end)
                        r.raidBtn:SetScript("OnEnter", function(self)
                            self.hover:Show()
                            self.icon:SetVertexColor(1, 0.93, 0.55)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["TOOLTIP_RAID_LOCKOUTS_TITLE"], 1, 0.82, 0)
                            GameTooltip:AddLine((L["TOOLTIP_RAID_LOCKOUTS_DESC"] ~= "TOOLTIP_RAID_LOCKOUTS_DESC") and L["TOOLTIP_RAID_LOCKOUTS_DESC"] or "View raid lockouts and progression", 1, 1, 1)
                            GameTooltip:Show()
                        end)
                        r.raidBtn:SetScript("OnLeave", function(self)
                            self.hover:Hide()
                            self.icon:SetVertexColor(1, 1, 1)
                            GameTooltip:Hide()
                        end)

                        r.ledgerBtn:ClearAllPoints()
                        r.ledgerBtn:SetPoint("TOP", r.pFrame, "BOTTOM", 0, -10)

                        -- Data-box Options menu (Favorite / Ignore-Restore / Delete).
                        r.optionsBtn = CreateFrame("Button", nil, r.dataBox, "BackdropTemplate")
                        r.optionsBtn.isActionControl = true
                        r.optionsBtn:SetSize(50, 22)
                        r.optionsBtn:SetPoint("TOPRIGHT", r.dataBox, "TOPRIGHT", -6, -6)
                        r.optionsBtn:EnableMouse(true)
                        r.optionsBtn:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.optionsBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                        r.optionsBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                        r.optionsBtn.text = r.optionsBtn:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                        r.optionsBtn.text:SetPoint("CENTER")
                        r.optionsBtn.text:SetText((L["BUTTON_ACTIONS"] ~= "BUTTON_ACTIONS") and L["BUTTON_ACTIONS"] or "Actions")
                        r.bagsBtn:ClearAllPoints()
                        r.bagsBtn:SetPoint("TOPRIGHT", r.optionsBtn, "BOTTOMRIGHT", 0, -4)

                        r.optionsBtn:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover))
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText((L["TOOLTIP_ACTIONS_TITLE"] ~= "TOOLTIP_ACTIONS_TITLE") and L["TOOLTIP_ACTIONS_TITLE"] or "Character Actions", 1, 0.82, 0)
                            GameTooltip:AddLine((L["TOOLTIP_ACTIONS_DESC"] ~= "TOOLTIP_ACTIONS_DESC") and L["TOOLTIP_ACTIONS_DESC"] or "Open action menu", 1, 1, 1)
                            GameTooltip:Show()
                        end)
                        r.optionsBtn:SetScript("OnLeave", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderPrimary))
                            GameTooltip:Hide()
                        end)

                        r.actionMenu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                        r.actionMenu.isActionControl = true
                        r.actionMenu:SetSize(84, 102)
                        r.actionMenu:SetPoint("TOPLEFT", r.dataBox, "TOPRIGHT", 6, 0)
                        r.actionMenu:SetFrameStrata("DIALOG")
                        r.actionMenu:SetToplevel(true)
                        if r.actionMenu.SetPropagateMouseClicks then
                            r.actionMenu:SetPropagateMouseClicks(false)
                        end
                        r.actionMenu:SetBackdrop({
                            bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            edgeSize = 10,
                            insets = { left = 2, right = 2, top = 2, bottom = 2 }
                        })
                        r.actionMenu:SetBackdropColor(unpack(t.dataBoxBg))
                        r.actionMenu:SetBackdropBorderColor(unpack(t.borderPrimary))
                        r.actionMenu:Hide()

                        local function SetupActionMenuButton(btn, text)
                            btn.isActionControl = true
                            btn:SetSize(76, 24)
                            btn:EnableMouse(true)
                            if btn.SetPropagateMouseClicks then
                                btn:SetPropagateMouseClicks(false)
                            end
                            btn:SetBackdrop({
                                bgFile = "Interface\\Buttons\\WHITE8X8",
                                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                                edgeSize = 10,
                                insets = { left = 2, right = 2, top = 2, bottom = 2 }
                            })
                            btn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                            btn:SetBackdropBorderColor(unpack(t.borderPrimary))
                            btn.text = btn:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
                            btn.text:SetPoint("CENTER")
                            btn.text:SetText(text)
                            btn:SetScript("OnEnter", function(self)
                                local theme = lv.GetTheme()
                                self:SetBackdropBorderColor(unpack(theme.borderHover))
                            end)
                            btn:SetScript("OnLeave", function(self)
                                local theme = lv.GetTheme()
                                self:SetBackdropBorderColor(unpack(theme.borderPrimary))
                                GameTooltip:Hide()
                            end)
                        end

                        r.favBtn = CreateFrame("Button", nil, r.actionMenu, "BackdropTemplate")
                        r.favBtn:SetPoint("TOP", 0, -6)
                        SetupActionMenuButton(r.favBtn, (L["BUTTON_FAVORITE"] ~= "BUTTON_FAVORITE") and L["BUTTON_FAVORITE"] or "Favorite")
                        r.favBtn.ownerRow = r
                        r.favBtn:SetScript("OnClick", function(self)
                            local row = self.ownerRow
                            local charData = row and LiteVaultDB and LiteVaultDB[row.charName]
                            if not charData then return end
                            charData.isFavorite = not charData.isFavorite
                            lv._reopenActionMenuForChar = row.charName
                            if lv.UpdateUI then lv.UpdateUI() end
                        end)
                        r.favBtn:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover))
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["TOOLTIP_FAVORITE_TITLE"], 1, 0.82, 0)
                            GameTooltip:AddLine(L["TOOLTIP_FAVORITE_DESC"], 1, 1, 1)
                            GameTooltip:Show()
                        end)

                        r.actionBtn = CreateFrame("Button", nil, r.actionMenu, "BackdropTemplate")
                        r.actionBtn:SetPoint("TOP", r.favBtn, "BOTTOM", 0, -6)
                        SetupActionMenuButton(r.actionBtn, (L["BUTTON_IGNORE"] ~= "BUTTON_IGNORE") and L["BUTTON_IGNORE"] or "Ignore")
                        r.actionBtn.ownerRow = r
                        r.actionBtn:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover))
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            local row = self.ownerRow
                            local charData = row and LiteVaultDB and LiteVaultDB[row.charName]
                            if charData and charData.isIgnored then
                                GameTooltip:SetText(L["TOOLTIP_RESTORE_TITLE"], 1, 0.82, 0)
                                GameTooltip:AddLine(L["TOOLTIP_RESTORE_DESC"], 1, 1, 1)
                            else
                                GameTooltip:SetText(L["TOOLTIP_IGNORE_TITLE"], 1, 0.82, 0)
                                GameTooltip:AddLine(L["TOOLTIP_IGNORE_DESC"], 1, 1, 1)
                            end
                            GameTooltip:Show()
                        end)

                        r.deleteBtn = CreateFrame("Button", nil, r.actionMenu, "BackdropTemplate")
                        r.deleteBtn:SetPoint("TOP", r.actionBtn, "BOTTOM", 0, -6)
                        SetupActionMenuButton(r.deleteBtn, (L["BUTTON_DELETE"] ~= "BUTTON_DELETE") and L["BUTTON_DELETE"] or "Delete")
                        r.deleteBtn.ownerRow = r
                        r.deleteBtn:SetScript("OnEnter", function(self)
                            local theme = lv.GetTheme()
                            self:SetBackdropBorderColor(unpack(theme.borderHover))
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText("|cffff0000" .. L["TOOLTIP_DELETE_TITLE"] .. "|r", 1, 0, 0)
                            GameTooltip:AddLine(L["TOOLTIP_DELETE_DESC"], 1, 1, 1)
                            GameTooltip:AddLine("|cffff6666" .. L["TOOLTIP_DELETE_WARNING"] .. "|r", 1, 0.4, 0.4)
                            GameTooltip:Show()
                        end)

                        r.optionsBtn:SetScript("OnClick", function(self)
                            local row = self:GetParent():GetParent()
                            if row and row.actionMenu then
                                local wasShown = row.actionMenu:IsShown()
                                if lv.HideAllActionMenus then lv.HideAllActionMenus() end
                                if lv.CloseAuxPanels then lv.CloseAuxPanels(nil) end
                                if not wasShown then
                                    row.actionMenu:Show()
                                end
                            end
                        end)


                        r:SetScript("OnShow", function(self)
                            if self.charName and self.charName == lv.PLAYER_KEY then
                                SetPortraitTexture(self.face, "player")
                            end
                        end)

                        rows[idx] = r
                    end
                    
                    -- UPDATE ROW DATA
                    local r = rows[idx]
                    r.charName = name
                    r.characterData = data

                    -- Apply current theme colors to row elements
                    local t = lv.GetTheme()
                    r.pFrame:SetBackdropColor(unpack(t.backgroundAlt or t.background))
                    r.pFrame:SetBackdropBorderColor(unpack(t.portraitBorder))
                    r.pClassBorder:SetBackdropBorderColor(unpack(t.portraitBorder))
                    r.dataBox:SetBackdropColor(unpack(t.dataBoxBg))
                    r.dataBox:SetBackdropBorderColor(unpack(t.portraitBorder))
                    r.vaultBox:SetBackdropColor(unpack(t.dataBoxBgVault))
                    r.vaultBox:SetBackdropBorderColor(unpack(t.portraitBorder))
                    r.professionFrame:SetBackdropColor(unpack(t.dataBoxBgVault))
                    r.professionFrame:SetBackdropBorderColor(unpack(t.portraitBorder))
                    if r.upgradeFrame then
                        r.upgradeFrame:SetBackdropColor(unpack(t.dataBoxBgVault))
                        r.upgradeFrame:SetBackdropBorderColor(unpack(t.portraitBorder))
                    end
                    r.vaultBox:SetFrameLevel(r.dataBox:GetFrameLevel() + 9)
                    if r.vaultRaid and r.vaultRaid.count then r.vaultRaid.count:SetDrawLayer("OVERLAY", 8) end
                    if r.vaultMythic and r.vaultMythic.count then r.vaultMythic.count:SetDrawLayer("OVERLAY", 8) end
                    if r.vaultDelve and r.vaultDelve.count then r.vaultDelve.count:SetDrawLayer("OVERLAY", 8) end
                    r.ledgerBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                    r.ledgerBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.bagsBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                    r.bagsBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.optionsBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                    r.optionsBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.actionMenu:SetBackdropColor(unpack(t.dataBoxBg))
                    r.actionMenu:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.favBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                    r.favBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.actionBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                    r.actionBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.deleteBtn:SetBackdropColor(unpack(t.dataBoxBgAlt))
                    r.deleteBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                    r.bagsBtn:SetFrameLevel(r.dataBox:GetFrameLevel() + 8)
                    r.raidBtn:SetFrameLevel(r.dataBox:GetFrameLevel() + 8)
                    r.currencyBtn:SetFrameLevel(r.dataBox:GetFrameLevel() + 8)
                    r.optionsBtn:SetFrameLevel(r.dataBox:GetFrameLevel() + 8)
                    r.actionMenu:SetFrameLevel((r.dataBox:GetFrameLevel() or 1) + 25)
                    r.favBtn:SetFrameLevel(r.actionMenu:GetFrameLevel() + 1)
                    r.actionBtn:SetFrameLevel(r.actionMenu:GetFrameLevel() + 1)
                    r.deleteBtn:SetFrameLevel(r.actionMenu:GetFrameLevel() + 1)

                    -- Special handling for Warband Bank (no class color)
                    local cc
                    if data.class == "Bank" then
                        -- Create a custom color object for the bank (gold color)
                        cc = { 
                            r = 1.0,  -- Red component
                            g = 0.84, -- Green component  
                            b = 0.0,  -- Blue component (gold = FFD700)
                            GenerateHexColor = function() return "ffffd700" end 
                        }
                    else
                        cc = C_ClassColor.GetClassColor(data.class or "WARRIOR")
                        if not cc then
                            cc = {
                                r = 1,
                                g = 1,
                                b = 1,
                                GenerateHexColor = function() return "ffffffff" end
                            }
                        end
                    end
                    
                    if r.levelBadge and r.levelBadge.outer then
                        r.levelBadge.outer:SetVertexColor(cc.r or 1, cc.g or 0.82, cc.b or 0, 1)
                    end

                    -- Character Name
                    local displayName = name
                    if data.class == "Bank" then
                        displayName = ((L["Warband Bank"] ~= "Warband Bank") and L["Warband Bank"] or name)
                    end
                    r.nameText:SetText("|c" .. cc:GenerateHexColor() .. displayName .. "|r")
                    local raceText = data.race or ""
                    local specText = data.specName or ""
                    if data.class == "Bank" then
                        r.identityText:SetText("")
                    elseif raceText ~= "" and specText ~= "" then
                        r.identityText:SetText(string.format("|cffffd100%s | %s|r", raceText, specText))
                    elseif raceText ~= "" then
                        r.identityText:SetText(string.format("|cffffd100%s|r", raceText))
                    elseif specText ~= "" then
                        r.identityText:SetText(string.format("|cffffd100%s|r", specText))
                    else
                        r.identityText:SetText("")
                    end
                    
                    -- NEW: Freshness Indicator (text only, no fading)
                    if lv.GetFreshnessInfo then
                        local freshnessInfo = lv.GetFreshnessInfo(data.lastActiveTimestamp)
                        r.freshnessText:SetText(freshnessInfo.text)
                        r.freshnessText:SetTextColor(freshnessInfo.color[1], freshnessInfo.color[2], freshnessInfo.color[3])
                    else
                        r.freshnessText:SetText("")
                    end
                    r:SetAlpha(1.0)
                    
                    -- Keep fill neutral; use class color on border for cleaner separation.
                    local fill = t.backgroundAlt or t.background
                    r.pFrame:SetBackdropColor(fill[1], fill[2], fill[3], 0.95)
                    local br = math.min(1, (cc.r * 0.70) + 0.10)
                    local bg = math.min(1, (cc.g * 0.70) + 0.10)
                    local bb = math.min(1, (cc.b * 0.70) + 0.10)
                    r.pFrame:SetBackdropBorderColor(unpack(t.portraitBorder))
                    r.pClassBorder:SetBackdropBorderColor(br, bg, bb, 0.85)
                    
                    -- iLvl and Time Played
                    r.topDataText:SetText("")
                    r.portraitIlvlText:SetText(string.format("|c%s%d|r", lv.GetiLvLColor(data.ilvl or 0), (data.ilvl or 0)))
                    r.portraitTimeText:SetText(string.format("|cffffd100%dd %dh|r", math.floor((data.played or 0)/86400), math.floor(((data.played or 0)%86400)/3600)))
                    
                    -- Main Stats - now just M+ Score (iLvl moved to top)
                    local mplusLine = string.format("|c%s" .. L["LABEL_MPLUS_SCORE"] .. "|r",
                        lv.GetMPlusColor(data.mplus or 0), (data.mplus or 0))
                    local tpCount = (lv.IsMPlusTeleportsEnabled and lv.IsMPlusTeleportsEnabled()) and lv.GetTeleportCount(data) or 0
                    r.mplusText:SetText(mplusLine)
                    
                    -- Gold (right side)
                    r.goldText:SetText(GetCoinTextureString(data.gold or 0, 13))
                    
                    -- Catalyst Charges
                    local catInfo = C_CurrencyInfo.GetCurrencyInfo(lv.CATALYST_ID)
                    if catInfo and catInfo.iconFileID then
                        SetCircularBadgeTexture(r.catalystBadge, catInfo.iconFileID)
                    end
                    if data.catalyst and data.catalyst > 0 then
                        r.catalystText:SetText(string.format("|cff00ccff%d|r", data.catalyst))
                    else
                        r.catalystText:SetText("|cff6666660|r")
                    end
                    if r.upgradeFrame then
                        r.upgradeFrame.catalystCount = data.catalyst or 0
                    end
                    if r.catalystBtn and r.catalystBtn.badge then
                        local upgradeFrameHovered = r.upgradeFrame and r.upgradeFrame.IsMouseOver and r.upgradeFrame:IsMouseOver()
                        SetCircularBadgeState(r.catalystBtn.badge, upgradeFrameHovered)
                    end

                    if r.currencyBtn then
                        SetCurrencyBadgeTexture(r.currencyBtn)
                        SetCurrencyBadgeState(r.currencyBtn, r.currencyBtn.IsMouseOver and r.currencyBtn:IsMouseOver())
                    end
                    
                    -- Spark Display (Midnight-only: Spark of Radiance, no fractured sparks)
                    r.sparkBtn.fullSparks = data.fullSparks or 0
                    r.sparkBtn.fracturedSparks = data.fracturedSparks or 0
                    local fullSparks = data.fullSparks or 0
                    local sparkIcon = GetItemIcon(232875) or 0  -- Spark of Radiance
                    SetCircularBadgeTexture(r.sparkBadge, sparkIcon)
                    if fullSparks > 0 then
                        r.sparkText:SetText(string.format("|cffffaa00%d|r", fullSparks))
                    else
                        r.sparkText:SetText("|cff6666660|r")
                    end
                    if r.upgradeFrame then
                        r.upgradeFrame.fullSparks = fullSparks
                    end
                    if r.sparkBtn and r.sparkBtn.badge then
                        local upgradeFrameHovered = r.upgradeFrame and r.upgradeFrame.IsMouseOver and r.upgradeFrame:IsMouseOver()
                        SetCircularBadgeState(r.sparkBtn.badge, upgradeFrameHovered)
                    end
                    if r.ledgerBtn and r.ledgerBtn.badge then
                        SetCircularBadgeState(r.ledgerBtn.badge, r.ledgerBtn.IsMouseOver and r.ledgerBtn:IsMouseOver())
                    end

                    r.teleportBtn.tpCount = tpCount
                    if tpCount > 0 then
                        r.teleportBtn:Show()
                        r.teleportText:SetText(string.format("|TInterface\\Icons\\spell_arcane_teleportdalaran:14:14|t |cff3399ff%d/%d|r", tpCount, #lv.TELEPORT_DUNGEONS))
                    else
                        r.teleportBtn:Hide()
                        r.teleportText:SetText("")
                    end
                    
                    -- NEW: M+ Key Display
                    if data.currentKey then
                        r.keyText:SetText(string.format("|TInterface\\Icons\\inv_relics_hourglass:16:16|t |cff00ccff%s +%d|r", data.currentKey.name or "Unknown", data.currentKey.level or 0))
                    else
                        r.keyText:SetText("|cffffd700" .. L["LABEL_NO_KEY"] .. "|r")
                    end

                    -- NEW: Profession Display
                    if data.professions and #data.professions > 0 then
                        local professionFrameHovered = r.professionFrame and r.professionFrame.IsMouseOver and r.professionFrame:IsMouseOver()
                        r.professionFrame:Show()
                        r.professionFrame.professionNames = {}
                        LayoutProfessionTracker(r, math.min(#data.professions, 2))

                        -- First profession
                        if data.professions[1] then
                            local p = data.professions[1]
                            SetCircularBadgeTexture(r.prof1Badge, p.icon or 136243)
                            r.prof1Badge:Show()
                            SetCircularBadgeState(r.prof1Badge, professionFrameHovered)
                            local profName1 = L[p.name] or p.name or ""
                            if profName1 ~= "" then
                                table.insert(r.professionFrame.professionNames, profName1)
                            end
                            r.prof1Text:SetText("")
                            r.prof1Text:Hide()
                        else
                            r.prof1Badge:Hide()
                            r.prof1Text:Hide()
                        end

                        -- Second profession
                        if data.professions[2] then
                            local p = data.professions[2]
                            SetCircularBadgeTexture(r.prof2Badge, p.icon or 136243)
                            r.prof2Badge:Show()
                            SetCircularBadgeState(r.prof2Badge, professionFrameHovered)
                            local profName2 = L[p.name] or p.name or ""
                            if profName2 ~= "" then
                                table.insert(r.professionFrame.professionNames, profName2)
                            end
                            r.prof2Text:SetText("")
                            r.prof2Text:Hide()
                        else
                            r.prof2Badge:Hide()
                            r.prof2Text:Hide()
                        end
                    else
                        r.professionFrame:Show()
                        r.professionFrame.professionNames = nil
                        LayoutProfessionTracker(r, 0)
                        r.prof1Badge:Hide()
                        r.prof1Text:SetText("|cff666666" .. L["LABEL_NO_PROFESSIONS"] .. "|r")
                        r.prof1Text:Show()
                        r.prof2Badge:Hide()
                        r.prof2Text:Hide()
                    end

                    -- Vault Progress
                    SetVaultProgressCounts(r, data.vR or 0, data.vM or 0, data.vW or 0)
                    
                    -- Portrait Setup
                    if name == lv.PLAYER_KEY then
                        r.currencyBtn:Show()
                        r.ledgerBtn:Show()
                        if LiteVaultDB and LiteVaultDB.disableBagViewing then
                            r.bagsBtn:Hide()
                        else
                            r.bagsBtn:Show()
                        end
                        r.raidBtn:Show()
                        SetPortraitTexture(r.face, "player")
                        -- Crop the circular portrait to appear more square
                        r.face:SetTexCoord(0.15, 0.85, 0.15, 0.85)
                        r.levelText:SetText(tostring(UnitLevel("player") or data.level or ""))
                        r.levelBadge:Show()
                    else
                        r.currencyBtn:Show()

                        -- Special icon for Warband Bank
                        if data.class == "Bank" then
                            r.face:SetTexture("Interface\\Icons\\INV_Misc_Coin_19") -- Gold coin/bank icon
                            r.face:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Crop edges
                            r.ledgerBtn:Hide() -- No ledger for bank
                            r.bagsBtn:Hide() -- No bags for bank
                            r.raidBtn:Hide() -- No raids for bank
                            r.currencyBtn:Hide() -- No currencies for bank
                            r.professionFrame:Hide() -- No professions for bank
                            r.levelBadge:Hide()
                        else
                            -- Use square class icons with adjusted coords to remove gray border
                            r.face:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
                            local coords = CLASS_ICON_TCOORDS[data.class or "WARRIOR"]
                            if coords then
                                -- Crop the gray border by adjusting texture coordinates inward
                                local left, right, top, bottom = unpack(coords)
                                local cropAmount = 0.08 -- Crop 8% from each edge (increased from 2%)
                                local width = right - left
                                local height = bottom - top
                                r.face:SetTexCoord(
                                    left + (width * cropAmount),
                                    right - (width * cropAmount),
                                    top + (height * cropAmount),
                                    bottom - (height * cropAmount)
                                )
                            end
                            r.ledgerBtn:Show() -- Show ledger for other characters
                            if LiteVaultDB and LiteVaultDB.disableBagViewing then
                                r.bagsBtn:Hide()
                            else
                                r.bagsBtn:Show() -- Show bags for other characters
                            end
                            r.raidBtn:Show() -- Show raids for other characters
                            r.levelText:SetText(data.level and tostring(data.level) or "")
                            r.levelBadge:Show()
                        end
                    end

                    -- Update Favorite action state
                    if data.isFavorite then
                        r.favBtn.text:SetText((L["BUTTON_UNFAVORITE"] ~= "BUTTON_UNFAVORITE") and L["BUTTON_UNFAVORITE"] or "Unfavorite")
                        r.favBtn.text:SetTextColor(1, 0.82, 0)
                    else
                        r.favBtn.text:SetText((L["BUTTON_FAVORITE"] ~= "BUTTON_FAVORITE") and L["BUTTON_FAVORITE"] or "Favorite")
                        r.favBtn.text:SetTextColor(unpack(t.textPrimary))
                    end

                    -- Minimal data-box actions: always available for characters (not bank).
                    if data.class ~= "Bank" then
                        if data.isIgnored then
                            r.actionBtn.text:SetText((L["BUTTON_RESTORE"] ~= "BUTTON_RESTORE") and L["BUTTON_RESTORE"] or "Restore")
                        else
                            r.actionBtn.text:SetText((L["BUTTON_IGNORE"] ~= "BUTTON_IGNORE") and L["BUTTON_IGNORE"] or "Ignore")
                        end

                        r.actionBtn:SetScript("OnClick", function(self)
                            local row = self.ownerRow
                            local charKey = row and row.charName
                            local charData = charKey and LiteVaultDB and LiteVaultDB[charKey]
                            if not charData then return end
                            charData.isIgnored = not charData.isIgnored
                            lv._reopenActionMenuForChar = charKey
                            if lv.UpdateUI then lv.UpdateUI() end
                        end)

                        r.deleteBtn:SetScript("OnClick", function(self)
                            local row = self.ownerRow
                            local charKey = row and row.charName
                            if not charKey then return end
                            local nameOnly = charKey:match("^([^-]+)") or charKey
                            StaticPopup_Show("LITEVAULT_CONFIRM_DELETE_CHARACTER", nameOnly, nil, charKey)
                        end)
                    end
                    if reopenActionMenuForChar and name == reopenActionMenuForChar and data.class ~= "Bank" then
                        r.actionMenu:Show()
                    else
                        r.actionMenu:Hide()
                    end
                    
                    -- Manage Mode Setup
                    if isManaging then
                        r.currencyBtn:Hide()
                        r.ledgerBtn:Hide()
                        r.bagsBtn:Hide()
                        r.raidBtn:Hide()
                    else
                        r.currencyBtn:Show()
                        r.ledgerBtn:Show()
                        if LiteVaultDB and LiteVaultDB.disableBagViewing then
                            r.bagsBtn:Hide()
                        else
                            r.bagsBtn:Show()
                        end
                        r.raidBtn:Show()
                    end

                    if data.class == "Bank" then
                        r.optionsBtn:Hide()
                        r.optionsBtn:EnableMouse(false)
                        r.actionMenu:Hide()
                        r.favBtn:Hide()
                        r.favBtn:EnableMouse(false)
                        r.actionBtn:Hide()
                        r.actionBtn:EnableMouse(false)
                        r.deleteBtn:Hide()
                        r.deleteBtn:EnableMouse(false)
                    else
                        r.optionsBtn:Show()
                        r.optionsBtn:EnableMouse(true)
                        r.favBtn:Show()
                        r.favBtn:EnableMouse(true)
                        r.actionBtn:Show()
                        r.actionBtn:EnableMouse(true)
                        r.deleteBtn:Show()
                        r.deleteBtn:EnableMouse(true)
                    end
                    
                    r:SetPoint("TOPLEFT", 5, -(idx - 1) * 260) -- Increased to 260 for profession display
                    r:SetFrameLevel(ContentChar:GetFrameLevel() + idx) -- Each row above previous
                    r:Show()
                    totG, totP, idx = totG + (data.gold or 0), totP + (data.played or 0), idx + 1
                end
            end
        end
    end
    ContentChar:SetHeight(idx * 260)
    
    if lv.UpdateTotalDisplay then lv.UpdateTotalDisplay(totG, totP) end
end
