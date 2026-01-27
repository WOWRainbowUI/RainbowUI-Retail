--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2024 - James N. Whitehead II

This file contains an abstraction of the spellbook APIs, ensuring that
Clique has a common interface between different versions of WoW.
-------------------------------------------------------------------]] ---

local addonName = select(1, ...)

---@class addon
local addon = select(2, ...)
local L = addon.L

local libDropDown = LibStub("LibDropDown")

local libCatalog = addon.catalog
local libActions = addon.actionCatalog
local libSpellbook = addon.spellbookCatalog
local libMacros = addon.macroCatalog

---@class BindingConfig
local config = addon:GetBindingConfig()

-- Globals used in this file
local GameFontHighlight = GameFontHighlight
local SearchBoxTemplate_OnTextChanged = SearchBoxTemplate_OnTextChanged

local window = {}

function config:GetActionCatalogWindow()
    return window
end

function window:Initialize()
    if window.initialized then
        return
    end

    window.initialized = true

    window.frame = CreateFrame("Frame", "CliqueConfigUIActionCatalogFrame", config.ui, "DefaultPanelTemplate")
    local cf = window.frame

    cf:SetHeight(450)
    cf:SetWidth(465)
    cf:SetFrameStrata("MEDIUM")

    cf:ClearAllPoints()
    cf:SetPoint("LEFT", config.ui, "RIGHT", -5, 0)

    cf.next = CreateFrame("Button", nil, cf)
    cf.next:SetHeight(32)
    cf.next:SetWidth(32)

    cf.next.bg = cf.next:CreateTexture(nil, "BACKGROUND")
    cf.next.bg:ClearAllPoints()
    cf.next.bg:SetAllPoints()
    cf.next.bg:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    cf.next:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    cf.next:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
    cf.next:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    cf.next:ClearAllPoints()
    cf.next:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT", -5, 10)

    cf.prev = CreateFrame("Button", nil, cf)
    cf.prev:SetHeight(32)
    cf.prev:SetWidth(32)

    cf.prev.bg = cf.prev:CreateTexture(nil, "BACKGROUND")
    cf.prev.bg:ClearAllPoints()
    cf.prev.bg:SetAllPoints()
    cf.prev.bg:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    cf.prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    cf.prev:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    cf.prev:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    cf.prev:ClearAllPoints()
    cf.prev:SetPoint("RIGHT", cf.next, "LEFT", 0, 0)

    cf.pageSize = 16
    cf.buttons = {}

    for i = 1, cf.pageSize do
        local name = "CliqueUICatalogFrameButton" .. i
        local button = CreateFrame("Button", name, cf)
        button:SetHeight(32)
        button:SetWidth(32)

        button:EnableKeyboard(false)
        button:EnableMouseWheel(true)
        button:RegisterForClicks("AnyDown")

        -- Attach all behaviour scripts
        window:ActionCatalogButton_Initialize(button)

        button.background = button:CreateTexture(nil, "BACKGROUND")
        button.background:ClearAllPoints()
        button.background:SetAllPoints()
        button.background:SetAtlas("common-button-square-gray-up", false)
        button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

        button.name = cf:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        local fontFile, height, flags = GameFontHighlight:GetFont()
        button.name:SetFont(fontFile, height, flags)
        button.name:SetText("Lorem Ipsum")
        button.name:SetJustifyH("LEFT")
        button.name:SetJustifyV("TOP")

        button.name:ClearAllPoints()
        button.name:SetPoint("LEFT", button, "RIGHT", 5, 0)
        button.name:SetWidth(175)

        table.insert(cf.buttons, button)
    end

    -- Disable keyboard until the right time
    for idx, button in ipairs(cf.buttons) do
        button:EnableKeyboard(false)
    end

    -- Layout the buttons
    for idx, button in ipairs(cf.buttons) do
        button:ClearAllPoints()
        if idx == 1 then
            button:SetPoint("TOPLEFT", cf, "TOPLEFT", 15, -75)
        else
            if idx % 2 == 0 then
                button:SetPoint("LEFT", cf.buttons[idx - 1], "RIGHT", 190, 0)
            else
                button:SetPoint("TOPLEFT", cf.buttons[idx - 2], "BOTTOMLEFT", 0, -10)
            end
        end
    end

    cf.searchBox = CreateFrame("EditBox", "CliqueConfigUISpellbookSearch", cf, "SearchBoxTemplate")

    cf.filterButton = CreateFrame("DropDownToggleButton", "CliqueConfigUISpellbookFilterButton", cf, "UIMenuButtonStretchTemplate")
    cf.filterButton.Icon = cf.filterButton:CreateTexture(nil, "ARTWORK")
    cf.filterButton.ResetButton = CreateFrame("Button", "CliqueConfigUISpellbookFilterButtonReset", cf.filterButton)

    cf.searchBox:SetHeight(22)
    cf.searchBox:SetWidth(325)
    cf.searchBox:SetFrameStrata("DIALOG")
    cf.searchBox:ClearAllPoints()
    cf.searchBox:SetPoint("TOPLEFT", cf, "TOPLEFT", 20, -30)

    window:EnableCatalogTooltipsAndSetupQuickbind()
    window:EnableSearch()
    window:EnablePaging()
    window:EnableCatalogFilter()

    window:ResetFilter()
    window:UPDATE_CATALOG_WINDOW()

    local function triggerCatalogUpdate(self, elapsed)
        if not self.delay then
            self.delay = 0.1
        end

        self.delay = self.delay - elapsed
        if self.delay <= 0 then
            self:SetScript("OnUpdate", nil)
            self.delay = nil
            window:REFRESH_CATALOG_WINDOW()
        end
    end

    window.frame:RegisterEvent("SPELLS_CHANGED")
    window.frame:SetScript("OnEvent", function(self, event, ...)
        if self:IsVisible() then
           self:SetScript("OnUpdate", triggerCatalogUpdate)
        end
    end)
end

local function ActionCatalogButton_OnClick(self, button)
    -- If we're quickbinding then do quickbindy things
    if config:InQuickbindMode() then
        local captured = addon:GetCapturedKey(button)
        window:AddNewBindingFromButton(self, captured)
    elseif config:EditPageShown() then
        local entryType = self.type
        local entryId = self.id
        config:SendActionToEditPage(entryType, entryId)
    elseif config:BrowsePageShown() then
        local entryType = self.type
        local entryId = self.id
        config:SendActionToNewEditPage(entryType, entryId)
    end
end

local function ActionCatalogButton_OnKeyDown(button, key)
    -- If we're quickbinding then do quickbindy things
    if config:InQuickbindMode() then
        local captured = addon:GetCapturedKey(key)
        window:AddNewBindingFromButton(button, captured)
    end
end


local function ActionCatalogButton_OnMouseWheel(activeButton, delta)
    -- If we're quickbinding then do quickbindy things
    if config:InQuickbindMode() then
        local button = (delta > 0) and "MOUSEWHEELUP" or "MOUSEWHEELDOWN"
        local captured = addon:GetCapturedKey(button)
        window:AddNewBindingFromButton(activeButton, captured)
    end
end

function window:ActionCatalogButton_Initialize(button)
    button:SetScript("OnClick", ActionCatalogButton_OnClick)
    button:SetScript("OnKeyDown", ActionCatalogButton_OnKeyDown)
    button:SetScript("OnMouseWheel", ActionCatalogButton_OnMouseWheel)
end

function window:AddNewBindingFromButton(button, key)
    local actionAttributes = config:GetActionAttributes(button.type, button.id)

    if not actionAttributes.type then
        return
    end

    if not key then
        return
    end

    -- Add the binding, using the config object
    local draft = config:GetDefaultBindTable()
    config:CopyActionFromTo(actionAttributes, draft)
    draft.key = key

    local keyText = addon:GetBindingKeyComboText(draft)
    local actionText = addon:GetBindingActionText(draft.type, draft)
    addon:Printf(L["Added '%s' to '%s'"]:format(actionText, keyText))

    config:AddBinding(draft)
end

local function ActionCatalogButton_OnEnter(button, motion)
    -- Check if we're quickbinding, we need to do some extra things there
    if config:InQuickbindMode() then
        button:EnableKeyboard(true)
    end

    config:ShowTooltip(button, button.type, button.id)
end

local function ActionCatalogButton_OnLeave(self, motion)
    self:EnableKeyboard(false)
    config:HideTooltip()
end

function window:EnableCatalogTooltipsAndSetupQuickbind(u)
    local cf = window.frame

    for idx, button in ipairs(cf.buttons) do
        button:SetScript("OnEnter", ActionCatalogButton_OnEnter)
        button:SetScript("OnLeave", ActionCatalogButton_OnLeave)
    end
end

function window:EnableSearch()
    local cf = window.frame

    cf.searchBox:SetScript("OnTextChanged", function(me)
        SearchBoxTemplate_OnTextChanged(me)
        window:SetFilterSearchText(me:GetText())
    end)
end

function window:EnablePaging()
    local cf = window.frame

    cf.page = 0
    cf.prev:SetScript("OnClick", function(button)
        local newPage = cf.page - 1
        if newPage < 0 then
            newPage = 0
        end

        cf.page = newPage

        if cf.page == 0 then
            cf.prev:Disable()
        elseif cf.page >= 1 then
            cf.prev:Enable()
        end

        window:CATALOG_FILTER_CHANGED()
    end)

    cf.next:SetScript("OnClick", function(button)
        cf.page = cf.page + 1
        cf.prev:Enable()
        window:CATALOG_FILTER_CHANGED()
    end)

    cf:SetScript("OnMouseWheel", function(frame, delta)
        if delta > 0 and cf.next:IsEnabled() then
            cf.next:Click()
        elseif delta < 0 and cf.prev:IsEnabled() then
            cf.prev:Click()
        end
    end)
end

function window:GetDefaultFilterSettings()
    local filter = {}

    filter.catalogs = {
        [libCatalog.catalogType.Action] = true,
        [libCatalog.catalogType.Spell] = true,
        [libCatalog.catalogType.Macro] = true,
    }

    filter.settings = {}
    filter.settings.includePassives = false
    filter.settings.includeOffspec = false
    filter.settings.includeGlobalMacros = true
    filter.settings.includeCharacterMacros = true
    filter.settings.includeGeneralTab = false

    filter.settings.name = ""
    return filter
end

function window:GetDefaultFilter()
    if not window.defaultFilter then
        local defaultSettings = window:GetDefaultFilterSettings()
        window.defaultFilter = window:GetFilterFromSettings(defaultSettings)
    end

    return window.defaultFilter
end

function window:GetFilterFromSettings(filterSettings)
    local catalogs = filterSettings.catalogs
    local settings = filterSettings.settings

    if settings.includeGlobalMacros or settings.includeCharacterMacros then
        catalogs[libCatalog.catalogType.Macro] = true
    end

    local filter = libCatalog:CreateFilter(catalogs, settings)
    return filter
end


function window:ResetFilter()
    window.filterSettings = window:GetDefaultFilterSettings()

    -- Also reset the search box
    local cf = window.frame
    cf.searchBox:SetText("")

    -- Hide the filter menu if it is shown
    cf.filterMenu:Hide()

    window:CATALOG_FILTER_CHANGED()
end

function window:FilterIncludesCatalog(catalogType)
    local filter = window.filterSettings
    return filter.catalogs[catalogType]
end

function window:FilterIncludesSetting(key)
    local filter = window.filterSettings
    return filter.settings[key]
end

function window:FilterSearchText()
    local filter = window.filterSettings
    return filter.settings.name
end

function window:SetFilterSearchText(text)
    local filter = window.filterSettings

    if filter and filter.settings then
        filter.settings.name = text
        window:CATALOG_FILTER_CHANGED()
    end
end

function window:SetFilterCatalog(catalogType, enabled)
    local filter = window.filterSettings
    filter.catalogs[catalogType] = not not enabled

    -- If we turn off spells, toggle all spell-related options
    if catalogType == libCatalog.catalogType.Spell then
        filter.settings["includePassives"] = false
        filter.settings["includeOffspec"] = false
        filter.settings["includeGeneralTab"] = false
    end

    window:CATALOG_FILTER_CHANGED()
end

function window:SetFilterSetting(key, enabled)
    local filter = window.filterSettings
    filter.settings[key] = not not enabled

    -- If any spell-related setting is selected, turn on the spell category
    if filter.settings["includePassives"] or filter.settings["includeOffspec"] or filter.settings["includeGeneralTab"] then
        filter.catalogs[libCatalog.catalogType.Spell] = true
    end
    window:CATALOG_FILTER_CHANGED()
end

function window:EnableCatalogFilter()
    local cf = window.frame

    cf.filterButton:ClearAllPoints()
    cf.filterButton:SetPoint("TOPRIGHT", cf, "TOPRIGHT", -10, -30)
    cf.filterButton:SetWidth(93)
    cf.filterButton:SetHeight(22)
    cf.filterButton:SetText(L["Filter"])

    cf.filterButton.Icon:SetHeight(12)
    cf.filterButton.Icon:SetWidth(10)
    cf.filterButton.Icon:ClearAllPoints()
    cf.filterButton.Icon:SetPoint("RIGHT", cf.filterButton, "RIGHT", -10, 0)
    cf.filterButton.Icon:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")

    cf.filterButton:SetScript("OnCLick", function()
        cf.filterMenu:Toggle()
    end)

    cf.filterMenu = libDropDown:NewMenu(cf.filterButton, "CliqueBindOtherDropdown")
    CFFM = cf.filterMenu

    cf.filterMenu:SetAnchor("TOPLEFT", cf.filterButton, "BOTTOMLEFT", 20, -10)
    cf.filterMenu:SetStyle("MENU")
    cf.filterMenu:SetFrameStrata("DIALOG")

    cf.filterButton.ResetButton:SetHeight(23)
    cf.filterButton.ResetButton:SetWidth(23)
    cf.filterButton.ResetButton:ClearAllPoints()
    cf.filterButton.ResetButton:SetPoint("CENTER", cf.filterButton, "TOPRIGHT", -3, 0)
    cf.filterButton.ResetButton:SetNormalAtlas("auctionhouse-ui-filter-redx")
    cf.filterButton.ResetButton:SetHighlightAtlas("auctionhouse-ui-filter-redx", "ADD", 0.4)

    cf.filterButton.ResetButton:SetScript("OnClick", function(button)
        window:ResetFilter()
    end)

    local function createCatalogFilterCheck(catalogType)
        return function()
            return window:FilterIncludesCatalog(catalogType)
        end
    end

    local function createCatalogFilterToggle(catalogType)
        return function(button)
            local current = window:FilterIncludesCatalog(catalogType)
            local newValue = not current
            window:SetFilterCatalog(catalogType, newValue)
            button:SetCheckedState(newValue)
            cf.filterMenu:Hide()
            cf.filterMenu:Show()
        end
    end

    local function createFilterSettingCheck(key)
        return function()
            return window:FilterIncludesSetting(key)
        end
    end

    local function createFilterSettingToggle(key)
        return function(button)
            local current = window:FilterIncludesSetting(key)
            local newValue = not current
            window:SetFilterSetting(key, newValue)
            button:SetCheckedState(newValue)
            cf.filterMenu:Hide()
            cf.filterMenu:Show()
        end
    end

    cf.filterMenu:AddLine({
        text = L["Spell and macro catalogue"],
        isTitle = true,
    })
    cf.filterMenu:AddLine({
        isSpacer = true,
    })
    cf.filterMenu:AddLine({
        text = L["Include spells"],
        checked = createCatalogFilterCheck(libCatalog.catalogType.Spell),
        func = createCatalogFilterToggle(libCatalog.catalogType.Spell),
        keepShown = true,
    })
    cf.filterMenu:AddLine({
        text = L["Include spells from 'General' tab"],
        checked = createFilterSettingCheck("includeGeneralTab"),
        func = createFilterSettingToggle("includeGeneralTab"),
        keepShown = true,
    })
    cf.filterMenu:AddLine({
        text = L["Include passive spells"],
        checked = createFilterSettingCheck("includePassives"),
        func = createFilterSettingToggle("includePassives"),
        keepShown = true,
    })
    cf.filterMenu:AddLine({
        text = L["Include off-spec spells"],
        checked = createFilterSettingCheck("includeOffspec"),
        func = createFilterSettingToggle("includeOffspec"),
        keepShown = true,
    })
    cf.filterMenu:AddLine({
        isSpacer = true,
    })

    cf.filterMenu:AddLine({
        text = L["Include global macros"],
        checked = createFilterSettingCheck("includeGlobalMacros"),
        func = createFilterSettingToggle("includeGlobalMacros"),
        keepShown = true,
    })
    cf.filterMenu:AddLine({
        text = L["Include character macros"],
        checked =  createFilterSettingCheck("includeCharacterMacros"),
        func = createFilterSettingToggle("includeCharacterMacros"),

        keepShown = true,
    })
end

function window:ClearCatalogResults()
    window.allResults = nil
end

function window:GetCatalogResults()
    local actionResults = libActions:GetActionCatalogEntries()
    local spellResults = libSpellbook:GetSpellCatalogEntries(#actionResults)
    local macroResults = libMacros:GetMacroCatalogEntries(#spellResults)

    local results = libCatalog:MergeCatalogs(actionResults, spellResults)
    results = libCatalog:MergeCatalogs(results, macroResults)
    libCatalog:SortCatalog(results)

    window.allResults = results
    return results
end

-- Called when the spells change
function window:REFRESH_CATALOG_WINDOW()
    -- Make sure the spell catalog is updated
    window:CATALOG_FILTER_CHANGED()

    -- Refresh the UI
    window:UPDATE_CATALOG_WINDOW()
end

function window:CATALOG_FILTER_CHANGED()
    local cf = window.frame

    local filterSettings = window.filterSettings
    local filter = window:GetFilterFromSettings(filterSettings)

    -- Show the reset button if the filter is different than default
    local defaultFilter = window:GetDefaultFilter()
    if not libCatalog:FiltersEqual(defaultFilter, filter) then
        cf.filterButton.ResetButton:Show()
    else
        cf.filterButton.ResetButton:Hide()
    end

    local catalog = window:GetCatalogResults()
    -- addon:Printf("Catalog has %d results", #catalog)

    local results = libCatalog:ApplyFilter(catalog, filter)
    -- addon:Printf("Applying filter has %d results", #results)

    window.results = results
    window:UPDATE_CATALOG_WINDOW()
end

function window:UPDATE_CATALOG_WINDOW()
    local cf = window.frame

    if not window.results then
        window:CATALOG_FILTER_CHANGED()
    end

    local results = window.results

    -- If a filter caused us to be beyond the last page, flip to the last page
    local maxPage = (#results / cf.pageSize)

    -- If we have than a page of results, reset to the first page
    if #results < cf.pageSize then
        cf.page = 0
    elseif cf.page >= maxPage then
        cf.page = maxPage - 1
    end

    local startId = (cf.page * cf.pageSize) + 1

    for idx = startId, startId + (cf.pageSize - 1) do
        local buttonIndex = (idx - startId) + 1
        local button = cf.buttons[buttonIndex]

        local entry = results[idx]
        if entry and entry.entryType == libCatalog.entryType.Spell then
            local spellId = entry.id
            local name = entry.name
            local icon = entry.icon
            local passive = entry.passive
            local offspec = entry.offspec

            button.type = libCatalog.entryType.Spell
            button.id = spellId

            local spellSubName = libSpellbook:GetSpellSubName(spellId)
            local spellName = name

            if spellSubName and spellSubName ~= "" then
                spellName = spellName .. " (" .. spellSubName .. ")"
            end

            button.name:SetText(spellName .. (passive and " (Passive)" or "") .. (offspec and " [Offspec]" or ""))
            button.background:SetTexture(icon)
            if offspec then
                button.background:SetDesaturated(true)
            else
                button.background:SetDesaturated(false)
            end
            button:Show()
            button.name:Show()
        elseif entry and entry.entryType == libCatalog.entryType.Macro then
            local name = entry.name
            local icon = entry.icon
            local char = entry.characterMacro

            button.type = libCatalog.entryType.Macro
            button.id = entry.id

            local macroType = L["global"]
            if char then
                macroType = L["character"]
            end

            local formattedName = string.format("%s %s (%s)", L["Macro:"], name, macroType)

            button.name:SetText(formattedName)
            button.background:SetTexture(icon)
            button.background:SetDesaturated(false)

            button:Show()
            button.name:Show()
        elseif entry and entry.entryType == libCatalog.entryType.Action then
            local name = entry.name
            local icon = entry.icon

            button.type = libCatalog.entryType.Action
            button.id = entry.id

            button.name:SetText(name)
            button.background:SetTexture(icon)
            button.background:SetDesaturated(false)

            button:Show()
            button.name:Show()
        else
            button:Hide()
            button.name:Hide()
            button.type = nil
            button.id = nil
        end
    end

    -- Update the previous and next buttons accordingly
    cf.prev:Enable()
    cf.next:Enable()

    if cf.page == 0 then
        cf.prev:Disable()
    end

    if cf.page >= (maxPage - 1) then
        cf.next:Disable()
    end
end
