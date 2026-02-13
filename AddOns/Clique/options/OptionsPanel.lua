--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2024 - James N. Whitehead II
-------------------------------------------------------------------]] ---

local addonName = select(1, ...)

---@class addon
local addon = select(2, ...)
local L = addon.L

local LibDropDown = LibStub("LibDropDown")
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local Settings = Settings

--[[-------------------------------------------------------------------------
--  Addon 'About' Dialog for Interface Options
--
--  Some of this code was taken from/inspired by tekKonfigAboutPanel
--- and it's been moved from AddonCore due to taint issues.
-------------------------------------------------------------------------]]--

local about = CreateFrame("Frame", addonName .. "AboutPanel", InterfaceOptionsFramePanelContainer)
about.name = addonName
about:Hide()

local MAX_HIGHLIGHT_LEN = 99999999

function about.OnShow(frame)
    local fields = {"Version", "Author", "X-Category", "X-License", "X-Email", "X-Website", "X-Credits"}
    local notes = GetAddOnMetadata(addonName, "Notes")

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")

    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName)

    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetHeight(32)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetPoint("RIGHT", about, -32, 0)
    subtitle:SetNonSpaceWrap(true)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetJustifyV("TOP")
    subtitle:SetText(notes)

    local anchor
    for _,field in pairs(fields) do
            local val = GetAddOnMetadata(addonName, field)
            if val then
                    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
                    title:SetWidth(75)
                    if not anchor then title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -8)
                    else title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6) end
                    title:SetJustifyH("RIGHT")
                    title:SetText(field:gsub("X%-", ""))

                    local detail = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                    detail:SetPoint("LEFT", title, "RIGHT", 4, 0)
                    detail:SetPoint("RIGHT", -16, 0)
                    detail:SetJustifyH("LEFT")
                    detail:SetText(val)

                    anchor = title
            end
    end

    -- Clear the OnShow so it only happens once
    frame:SetScript("OnShow", nil)
end

addon.optpanels = addon.optpanels or {}
addon.optpanels.ABOUT = about

about:SetScript("OnShow", about.OnShow)
about:Hide()

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category, layout = Settings.RegisterCanvasLayoutCategory(addon.optpanels.ABOUT, L[addonName]) -- 自行修改選項名稱
    Settings.RegisterAddOnCategory(category)
    addon.optpanels.ABOUT.category = category
    addon.optpanels.ABOUT.layout = layout
elseif InterfaceOptions_AddCategory then
   InterfaceOptions_AddCategory(addon.optpanels.ABOUT)
end

--[[-------------------------------------------------------------------------
--  End Dialog
-------------------------------------------------------------------------]]--

local panel = CreateFrame("Frame")
panel:Hide()

panel.name = L["General Options"]
panel.parent = addonName

function panel:OnCommit()
    panel.okay()
end

function panel:OnDefault()
end

function panel:OnRefresh ()
    panel.refresh()
end

addon.optpanels.GENERAL = panel

panel:SetScript("OnShow", function(self)
    if not panel.initialized then
        panel:CreateOptions()
        panel.refresh()
    end
end)

local function make_checkbox(name, parent)
    local frame = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    frame.text = _G[frame:GetName() .. "Text"]
    frame.type = "checkbox"
    return frame
end

local function make_dropdown(name, parent)
    local frame = LibDropDown:NewButton(parent, name)
    frame.type = "dropdown"
    frame:SetStyle("MENU")
    return frame
end

local function make_label(name, parent, template)
    local label = parent:CreateFontString(name, "OVERLAY", template)
    label:SetWidth(parent:GetWidth())
    label:SetJustifyH("LEFT")
    label.type = "label"
    return label
end

local function make_editbox_with_button(editName, buttonName, parent)
    local editbox = CreateFrame("EditBox", editName, parent)
    editbox:SetHeight(32)
    editbox:SetWidth(200)
    editbox:SetAutoFocus(false)
    editbox:SetFontObject('GameFontHighlightSmall')
    editbox.type = "editbox"

    local left = editbox:CreateTexture(nil, "BACKGROUND")
    left:SetWidth(8)
    left:SetHeight(20)
    left:SetPoint("LEFT", -5, 0)
    left:SetTexture("Interface\\Common\\Common-Input-Border")
    left:SetTexCoord(0, 0.0625, 0, 0.625)

    local right = editbox:CreateTexture(nil, "BACKGROUND")
    right:SetWidth(8)
    right:SetHeight(20)
    right:SetPoint("RIGHT", 0, 0)
    right:SetTexture("Interface\\Common\\Common-Input-Border")
    right:SetTexCoord(0.9375, 1, 0, 0.625)

    local center = editbox:CreateTexture(nil, "BACKGROUND")
    center:SetHeight(20)
    center:SetPoint("RIGHT", right, "LEFT", 0, 0)
    center:SetPoint("LEFT", left, "RIGHT", 0, 0)
    center:SetTexture("Interface\\Common\\Common-Input-Border")
    center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

    editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
    editbox:SetScript("OnEnterPressed", editbox.ClearFocus)
    editbox:SetScript("OnEditFocusGained", function()
        editbox:HighlightText(0, MAX_HIGHLIGHT_LEN)
    end)

    local button = CreateFrame("Button", buttonName, editbox, "UIPanelButtonTemplate")
    button:Show()
    button:SetHeight(22)
    button:SetWidth(75)
    button:SetPoint("LEFT", editbox, "RIGHT", 0, 0)
    return editbox, button
end

function panel:CreateOptions()
    -- Ensure the panel isn't created twice (thanks haste)
    panel.initialized = true

    -- Create the general options panel here:
    local bits = {}

    self.disableDuringHousing = make_checkbox("CliqueOptionsDisableDuringHousing", self)
    self.disableDuringHousing.text:SetText(L["Disable all bindings when in housing edit mode"])

    self.cvardirection = make_checkbox("CliqueOptionsCvarDirection", self)
    self.cvardirection.text:SetText(L["[Temp] Match the behaviour of the ActionButtonUseKeyDown CVar"])

    self.updown = make_checkbox("CliqueOptionsUpDownClick", self)
    self.updown.text:SetText(L["Trigger bindings on the 'down' portion of the click (experimental)"])

    -- Set up multiple talent profiles
    self.talentProfiles = {}
    self.specswap = make_checkbox("CliqueOptionsSpecSwap", self)
    self.specswap.text:SetText(L["Swap profiles based on talent spec"])
    self.specswap.EnableDisable = function()
        local enabled = self.specswap:GetChecked()
        for i = 1, #panel.talentProfiles do
            if enabled then
                self.talentProfiles[i].Button:Enable()
            else
                self.talentProfiles[i].Button:Disable()
            end
        end
    end
    self.specswap:SetScript("PostClick", self.specswap.EnableDisable)

    if addon:GameVersionHasTalentSpecs() then
        for i = 1, addon:GetNumTalentSpecs() do
            local specName = addon:GetTalentSpecName(i)
            local name = "CliqueOptionsSpec" .. i
            local label = make_label(name .. "Label", self, "GameFontNormalSmall")
            label:SetText(L["Talent profile: %s"]:format(specName))

            self.talentProfiles[i] = make_dropdown(name, self)
            self.talentProfiles[i].profileLabel = label
        end
    end

    self.profilelabel = make_label("CliqueOptionsProfileMgmtLabel", self, "GameFontNormalSmall")
    self.profilelabel:SetText(L["Profile Management:"])
    self.profiledd = make_dropdown("CliqueOptionsProfileMgmt", self)

    self.stopcastingfix = make_checkbox("CliqueOptionsStopCastingFix", self)
    self.stopcastingfix.text:SetText(L["Attempt to fix the issue introduced in 4.3 with casting on dead targets"])

    self.exportbindingslabel = make_label("CliqueOptionsExportBindingsLabel", self, "GameFontNormalSmall")
    self.exportbindingslabel:SetText(L["Export bindings:"])
    self.exportbindingseditbox, self.exportbindingsbutton = make_editbox_with_button("CliqueOptionsExportBindingsEditbox", "CliqueOptionsExportBindingsEditboxButton", self)

    self.exportbindingsbutton:SetText(L["Generate"])
    self.exportbindingsbutton:SetScript("OnClick", function(self, button)
        local payload = addon:GetExportString()
        local editbox = self:GetParent()
        editbox:SetText(payload)
        editbox:SetFocus()
        editbox:HighlightText(0, MAX_HIGHLIGHT_LEN)
    end)

    self.importbindingslabel = make_label("CliqueOptionsImportBindingsLabel", self, "GameFontNormalSmall")
    self.importbindingslabel:SetText(L["Import bindings:"])
    local importEditbox, importButton = make_editbox_with_button("CliqueOptionsImportBindingsEditbox", "CliqueOptionsImportBindingsEditboxButton", self)
    self.importbindingseditbox, self.importbindingsbutton = importEditbox, importButton
    self.importbindingseditbox:SetScript("OnTextChanged", function(self, userInput)
        importButton.validated = false
        importButton:SetText(L["Validate"])
    end)

    self.importbindingsbutton.validated = false
    self.importbindingsbutton:SetText(L["Validate"])
    self.importbindingsbutton:SetScript("OnClick", function(self, button)
        if self.validated then
            if not InCombatLockdown() then
                addon:ImportBindings(self.bindingData)
            end
            self:SetText(L["Success!"])
            importEditbox:SetText("")
        else
            local editbox = self:GetParent()
            local payload = editbox:GetText()

            local bindingData = addon:DecodeExportString(payload)
            if bindingData then
                self:SetText(L["Import"])
                self.validated = true
                self.bindingData = bindingData
            else
                self:SetText(L["Invalid"])
                self.validated = false
            end
        end
    end)

    -- Collect and anchor the bits together
    table.insert(bits, self.disableDuringHousing)
    table.insert(bits, self.cvardirection)
    table.insert(bits, self.updown)
    table.insert(bits, self.stopcastingfix)

    if #self.talentProfiles > 0 then
        table.insert(bits, self.specswap)

        for i = 1, #self.talentProfiles do
            table.insert(bits, self.talentProfiles[i].profileLabel)
            table.insert(bits, self.talentProfiles[i])
        end
    end

    table.insert(bits, self.profilelabel)
    table.insert(bits, self.profiledd)

    table.insert(bits, self.exportbindingslabel)
    table.insert(bits, self.exportbindingseditbox)

    table.insert(bits, self.importbindingslabel)
    table.insert(bits, self.importbindingseditbox)

    bits[1]:SetPoint("TOPLEFT", 5, -5)

    for i = 2, #bits, 1 do
        if bits[i].type == "label" then
            if bits[i-1].type == "editbox" then
                bits[i]:SetPoint("TOPLEFT", bits[i-1], "BOTTOMLEFT", -15, -5)
            else
                bits[i]:SetPoint("TOPLEFT", bits[i-1], "BOTTOMLEFT", 5, -5)
            end
        elseif bits[i].type == "dropdown" then
            bits[i]:SetPoint("TOPLEFT", bits[i-1], "BOTTOMLEFT", -5, -5)
        elseif bits[i].type == "editbox" then
            bits[i]:SetPoint("TOPLEFT", bits[i-1], "BOTTOMLEFT", 15, -5)
        else
            bits[i]:SetPoint("TOPLEFT", bits[i-1], "BOTTOMLEFT", 0, -5)
        end
    end
end

StaticPopupDialogs["CLIQUE_CONFIRM_PROFILE_DELETE"] = {
    preferredIndex = STATICPOPUPS_NUMDIALOGS,
    button1 = L["Yes"],
    button2 = L["No"],
    hideOnEscape = 1,
    timeout = 0,
    whileDead = 1,
}

local function messageAndSwitchProfile(profileName)
    addon.db:SetProfile(profileName)
    addon:Printf(L["Created and switched to new profile: %s"], profileName)
    panel.refresh()
end

StaticPopupDialogs["CLIQUE_NEW_PROFILE"] = {
    preferredIndex = STATICPOPUPS_NUMDIALOGS,
    text = L["Enter the name of a new profile you'd like to create"],
    button1 = L["Okay"],
    button2 = L["Cancel"],
    OnAccept = function(self)
        local base = self:GetName()
        local editbox = _G[base .. "EditBox"]
        local profileName = editbox:GetText()
        messageAndSwitchProfile(profileName)
    end,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    showAlert = 1,
    hideOnEscape = 1,
    hasEditBox = 1,
    maxLetters = 32,
    OnShow = function(self)
        _G[self:GetName().."Button1"]:Disable();
        _G[self:GetName().."EditBox"]:SetFocus();
    end,
    EditBoxOnEnterPressed = function(self)
        local button = _G[self:GetParent():GetName().."Button1"]
        if addon:APIIsTrue(button:IsEnabled()) then
            local base = self:GetParent():GetName()
            local editbox = _G[base .. "EditBox"]
            local profileName = editbox:GetText()
            messageAndSwitchProfile(profileName)
        end
        self:GetParent():Hide();
    end,
    EditBoxOnTextChanged = function (self)
        local editBox = _G[self:GetParent():GetName().."EditBox"];
        local txt = editBox:GetText()
        if #txt > 0 then
            _G[self:GetParent():GetName().."Button1"]:Enable();
        else
            _G[self:GetParent():GetName().."Button1"]:Disable();
        end
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
        ClearCursor();
    end
}

local function getsorttbl()
    local profiles = addon.db:GetProfiles()
    local sort = {}
    for idx, profileName in ipairs(profiles) do
        table.insert(sort, profileName)
    end
    table.sort(sort)
    return sort
end

local function getProfileSubmenu(profileName, isCurrentProfile)
    local submenu = {}
    table.insert(submenu, {
        text = L["Profile: %s"]:format(profileName),
        isTitle = true,
    })
    table.insert(submenu, {
        text = L["Select profile: %s"]:format(profileName),
        value = profileName,
        func = function()
            addon:Printf(L["Switching to profile: %s"], profileName)
            addon.db:SetProfile(profileName)
            panel.refresh()
        end,
    })
    table.insert(submenu, {
        text = L["Delete profile: %s"]:format(profileName),
        value = profileName,
        disabled = isCurrentProfile,
        forceMotion = false,
        func = function()
            local dialog = StaticPopupDialogs["CLIQUE_CONFIRM_PROFILE_DELETE"]
            dialog.text = L["Delete profile '%s'"]:format(profileName)
            dialog.OnAccept = function(self)
                addon.db:DeleteProfile(profileName)
                addon:Printf(L["Deleted profile: %s"], profileName)
                panel.refresh()
            end
            StaticPopup_Show("CLIQUE_CONFIRM_PROFILE_DELETE")
        end,
    })

    return submenu
end

local function initProfileDropdown(menu)
    menu:SetJustifyH("LEFT")
    menu:SetWidth(300)
    menu:Clear()

    local sort = getsorttbl()
    local paged = (#sort >= 10)
    local currentProfile = addon.db:GetCurrentProfile()

    if not paged then
        for idx, entry in ipairs(sort) do
            local isCurrentProfile = entry == currentProfile
            menu:Add({
                text = entry,
                value = entry,
                menu = getProfileSubmenu(entry, isCurrentProfile),
            })
        end
    else
        for idx = 1, #sort, 10 do
            local lastidx = (idx + 9 > #sort) and #sort or (idx + 9)
            local first = sort[idx]
            local last = sort[lastidx]

            -- Fill in the paged menu with the sub-entries
            local pagedMenu = {}
            for idx = idx, lastidx, 1 do
                local subEntry = sort[idx]
                local isCurrentProfile = subEntry == currentProfile

                table.insert(pagedMenu, {
                    text = subEntry,
                    value = subEntry,
                    menu = getProfileSubmenu(subEntry, isCurrentProfile),
                })
            end

            menu:Add({
                text = first:sub(1, 5):trim() .. ".." .. last:sub(1, 5):trim(),
                value = idx,
                menu = pagedMenu,
            })
        end
    end

    menu:Add({
        text = L["Add new profile"],
        value = "add",
        func = function()
            menu:Toggle()
            StaticPopup_Show("CLIQUE_NEW_PROFILE")
        end,
    })
end

local function initTalentSpecDropdown(menu, settingsKey, specName)
    menu:SetJustifyH("LEFT")
    menu:SetWidth(300)
    menu:Clear()

    local sort = getsorttbl()
    local paged = (#sort >= 10)
    local currentProfile = addon.db:GetCurrentProfile()

    if not paged then
        for idx, entry in ipairs(sort) do
            local isCurrentProfile = entry == currentProfile
            menu:Add({
                text = entry,
                value = entry,
                func = function(self, button, ...)
                    menu:SetText(entry)
                end,
            })
        end
    else
        for idx = 1, #sort, 10 do
            local lastidx = (idx + 9 > #sort) and #sort or (idx + 9)
            local first = sort[idx]
            local last = sort[lastidx]

            -- Fill in the paged menu with the sub-entries
            local pagedMenu = {}
            for idx = idx, lastidx, 1 do
                local subEntry = sort[idx]
                local isCurrentProfile = subEntry == currentProfile

                table.insert(pagedMenu, {
                    text = subEntry,
                    value = subEntry,
                    func = function(self, button, ...)
                        menu:SetText(subEntry)
                    end,
                    })
            end

            menu:Add({
                text = first:sub(1, 5):trim() .. ".." .. last:sub(1, 5):trim(),
                value = idx,
                menu = pagedMenu,
            })
        end
    end
end

-- Update the elements on the panel to the current state
function panel.refresh()
    xpcall(function()

    if not panel.initialized then
        panel:CreateOptions()
    end

    -- Initialize the dropdowns
    local settings = addon.settings
    local currentProfile = addon.db:GetCurrentProfile()

    initProfileDropdown(panel.profiledd)
    panel.profiledd:SetText(L["Current profile: %s"]:format(currentProfile))

    if #panel.talentProfiles > 0 then
        local specSwappingEnabled = settings.specswap
        panel.specswap:SetChecked(specSwappingEnabled)

        for i = 1, #panel.talentProfiles do
            local dbKey = string.format("spec%d_profileKey", i)
            local dropdown = panel.talentProfiles[i]
            local selectedValue = settings[dbKey] or currentProfile
            local talentSpecName = addon:GetTalentSpecName(i)

            initTalentSpecDropdown(dropdown, dbKey, talentSpecName)
            dropdown:SetText(selectedValue)

            if specSwappingEnabled then
                dropdown.Button:Enable()
            else
                dropdown.Button:Disable()
            end
        end
    end


    panel.disableDuringHousing:SetChecked(settings.disableInHousing)
    panel.updown:SetChecked(settings.downclick)
    panel.cvardirection:SetChecked(settings.usecvardirection)
    panel.stopcastingfix:SetChecked(settings.stopcastingfix)

    end, geterrorhandler())
end

function panel.okay()
    xpcall(function ()

    local settings = addon.settings
    local currentProfile = addon.db:GetCurrentProfile()

    local changed = (not not panel.stopcastingfix:GetChecked()) ~= settings.stopcastingfix

    -- Update the saved variables
    settings.disableInHousing = not not panel.disableDuringHousing:GetChecked()
    settings.downclick = not not panel.updown:GetChecked()
    settings.usecvardirection = not not panel.cvardirection:GetChecked()
    settings.stopcastingfix = not not panel.stopcastingfix:GetChecked()

    if #panel.talentProfiles > 0 then
        settings.specswap = not not panel.specswap:GetChecked()

        for i = 1, #panel.talentProfiles do
            local settingsKey = string.format("spec%d_profileKey", i)
            local dropdown = panel.talentProfiles[i]
            local selectedValue = dropdown:GetText()
            settings[settingsKey] = selectedValue
        end

        -- If needed, ensure we're in the right profile
        if settings.specswap then
            addon:TalentGroupChanged()
        end
    end

    addon:HouseEditorModeChanged()

    if changed then
        addon:FireMessage("BINDINGS_CHANGED")
    end

    end, geterrorhandler())
end

panel.cancel = panel.refresh

function addon:UpdateOptionsPanel()
    if panel:IsVisible() and panel.initialized then
        panel.refresh()
    end
end

if Settings and Settings.RegisterCanvasLayoutSubcategory then
    local category, layout = Settings.RegisterCanvasLayoutSubcategory(addon.optpanels.ABOUT.category, addon.optpanels.GENERAL, addon.optpanels.GENERAL.name)
    addon.optpanels.GENERAL.category = category
    addon.optpanels.GENERAL.layout = layout
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel, addon.optpanels.ABOUT)
end
