---@class RemixGemHelperPrivate
local Private = select(2, ...)

local const = Private.constants
local gemUtil = Private.GemUtil
local cache = Private.Cache
local uiElements = Private.UIElements
local misc = Private.Misc
local scrapUtil = Private.ScrapUtil
local addon = Private.Addon
local timeFormatter = CreateFromMixins(SecondsFormatterMixin)
timeFormatter:Init(1, 3, true, true)

Private.TimeFormatter = timeFormatter
Private.Frames = {}

local function itemListInitializer(frame, data)
    ---@class GemListEntry : Frame
    ---@field Name FontString
    ---@field Icon Texture
    ---@field Highlight Texture
    ---@field Stripe Texture
    ---@field Extract ExtractButton
    ---@field initialized boolean
    ---@field index number
    ---@field isHeader boolean|?
    ---@field id number|?
    ---@cast frame GemListEntry
    if not frame.initialized then
        local rowName = frame:CreateFontString(nil, "ARTWORK", const.FONT_OBJECTS.NORMAL)
        rowName:SetPoint("LEFT", 5, 0)
        frame.Name = rowName

        local iconTexture = frame:CreateTexture(nil, "OVERLAY")
        iconTexture:SetPoint("RIGHT", -5, 0)
        iconTexture:SetSize(16, 16)
        frame.Icon = iconTexture

        local highlightTexture = frame:CreateTexture()
        highlightTexture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        highlightTexture:SetPoint("BOTTOMLEFT", 5, 0)
        highlightTexture:SetPoint("TOPRIGHT", -5, 0)
        highlightTexture:Hide()
        frame.Highlight = highlightTexture

        local unevenStripe = frame:CreateTexture()
        unevenStripe:SetColorTexture(1, 1, 1, .08)
        unevenStripe:SetPoint("BOTTOMLEFT", 5, 0)
        unevenStripe:SetPoint("TOPRIGHT", -5, 0)
        frame.Stripe = unevenStripe

        local extractButton = uiElements:CreateExtractButton(frame)
        frame.Extract = extractButton

        frame:SetScript("OnEnter", function(self)
            self.Highlight:Show()
            if self.id then
                if not frame:IsVisible() then return end
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
                GameTooltip:SetHyperlink("item:" .. self.id)
                GameTooltip:Show()
                if not self.Extract then return end
                local info = self.Extract.info
                if not info then return end
                if info.locType ~= "EQUIP_SOCKET" then return end
                uiElements:HighlightEquipmentSlot(info.locIndex)
            end
        end)

        frame:SetScript("OnLeave", function(self)
            if uiElements.highlightFrame then
                uiElements.highlightFrame:Hide()
            end
            self.Highlight:Hide()
            if self.id then
                GameTooltip:Hide()
            end
        end)

        extractButton:HookScript("OnEnter", function()
            frame:GetScript("OnEnter")(frame)
        end)
        extractButton:HookScript("OnLeave", function()
            frame:GetScript("OnLeave")(frame)
        end)

        frame.initialized = true
    end
    local index = data.index
    local isHeader = data.isHeader or false
    local icon = data.icon
    local name = data.text
    local rowColor = data.color or CreateColor(1, 1, 1)

    frame.Icon:SetTexture(icon)
    frame.Name:SetTextColor(rowColor:GetRGBA())
    if isHeader then
        local used, maxS = gemUtil:GetSocketsInfo(name)
        local col = misc:GetPercentColor(used / maxS * 100)
        frame.Icon:SetDesaturated(false)
        frame.Name:SetFontObject(const.FONT_OBJECTS.HEADING)
        frame.Name:SetText(string.format("%s (%s%d/%d|r)", name, col:GenerateHexColorMarkup(), used, maxS))
        frame.Extract:Hide()
    else
        frame.Name:SetFontObject(const.FONT_OBJECTS.NORMAL)
        local exInf = data.info
        if exInf and exInf.locType ~= "UNCOLLECTED" then
            frame.Icon:SetDesaturated(false)
            frame.Extract:Show()
            frame.Extract:UpdateInfo(exInf)
        else
            frame.Icon:SetDesaturated(true)
            frame.Extract:Hide()
        end

        local state, color
        if exInf.locType == "EQUIP_SOCKET" then
            state, color = addon.Loc["Socketed"], const.COLORS.POSITIVE
        elseif exInf.locType == "BAG_GEM" then
            state, color = addon.Loc["In Bag"], const.COLORS.NEUTRAL
        elseif exInf.locType == "BAG_SOCKET" then
            state, color = addon.Loc["In Bag Item!"], const.COLORS.NEGATIVE
        else
            state, color = addon.Loc["Uncollected"], const.COLORS.GREY
            name = color:WrapTextInColorCode(name)
        end
        frame.Name:SetText(string.format("%s (%s)", name, color:WrapTextInColorCode(state)))
    end

    frame.index = index
    frame.id = data.id
    frame.Stripe:SetShown(data.index % 2 == 1)
end

local function bagItemInitiliazer(frame, data)
    if not frame.initialized then
        local clickable = uiElements:CreateIcon(frame, {
            points = {
                { "TOPLEFT" },
                { "BOTTOMRIGHT" }
            },
        })
        frame.clickable = clickable
        frame.initialized = true
    end
    frame.clickable:UpdateClickable(true, "ITEM", data.itemID, true, data.itemLink)
end

local function createScrapFrame()
    local scrapBagItems = uiElements:CreateBaseFrame(ScrappingMachineFrame, {
        frameStyle = "Flat",
        height = 250,
        title = addon.Loc["Scrappable Items"],
        points = {
            { "TOPLEFT",  ScrappingMachineFrame, "BOTTOMLEFT",  0, -2 },
            { "TOPRIGHT", ScrappingMachineFrame, "BOTTOMRIGHT", 0, -2 },
        }
    })
    local scrapItemsText = scrapBagItems:CreateFontString()
    scrapItemsText:SetFontObject(const.FONT_OBJECTS.HEADING)
    scrapItemsText:SetText(addon.Loc["NOTHING TO SCRAP"])
    scrapItemsText:SetPoint("CENTER", 0, -10)
    scrapItemsText:Hide()
    local allPointsScrap = {
        CreateAnchor("TOPLEFT", scrapBagItems, "TOPLEFT", 25, -35),
        CreateAnchor("BOTTOMRIGHT", scrapBagItems, "BOTTOMRIGHT", -25, 15)
    }
    local scrapItemScrollBox, scrapItemScrollView = uiElements:CreateScrollable(scrapBagItems, {
        element_height = 45,
        type = "GRID",
        initializer = bagItemInitiliazer,
        element_padding = 5,
        elements_per_row = math.floor((ScrappingMachineFrame:GetWidth() - 50) / 50),
        anchors = {
            with_scroll_bar = allPointsScrap,
            without_scroll_bar = allPointsScrap,
        }
    })
    local function updateScrapItems()
        if not scrapItemScrollBox:IsVisible() then return end
        scrapItemScrollView:UpdateContentData({})
        local scrappableItems = scrapUtil:GetScrappableItems()
        for _, itemInfo in ipairs(scrappableItems) do
            scrapItemScrollView:UpdateContentData(
                { { itemID = itemInfo.itemID, hideCount = true, itemLink = itemInfo.itemLink } }, true)
        end
        scrapBagItems:SetHeight(#scrappableItems > 0 and 250 or 75)
        scrapItemsText:SetShown(#scrappableItems < 1)
    end
    scrapItemScrollBox:RegisterEvent("BAG_UPDATE_DELAYED")
    scrapItemScrollBox:SetScript("OnEvent", updateScrapItems)
    scrapItemScrollBox:SetScript("OnShow", updateScrapItems)
end

local function createFrame()
    local gems = uiElements:CreateBaseFrame(CharacterFrame, {
        title = const.ADDON_NAME,
        width = 375
    })
    gems:RegisterEvent("BAG_UPDATE_DELAYED")

    ---@class ResocketPopup:BaseFrame
    local resocketPopup = uiElements:CreateBaseFrame(UIParent, {
        title = addon.Loc["Resocket Gems"],
        height = 150,
        width = 300,
        points = { { "CENTER" } },
        frameStrata = "DIALOG",
        frameStyle = "Flat",
    })
    Private.Frames.ResocketPopup = resocketPopup
    local closePopup = uiElements:CreateButton(resocketPopup, {
        text = DONE,
        width = resocketPopup:GetWidth() / 1.25,
        height = 25,
        points = {
            { "BOTTOM", 0, 15 },
        }
    })
    closePopup:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)
    local resocketButtons = {}
    for i = 1, 3 do
        local castButton = uiElements:CreateIcon(resocketPopup, {
            height = 45,
            width = 45,
        })
        castButton:Hide()
        tinsert(resocketButtons, castButton)
    end

    function resocketPopup:FillPopup(gemInfos)
        for _, btn in ipairs(resocketButtons) do
            btn:Hide()
            btn:UpdateClickable()
            btn:ClearAllPoints()
        end
        local gemsStart = (#gemInfos * 50) / 2 * -1
        for gemIndex, gemID in ipairs(gemInfos) do
            local castButton = resocketButtons[gemIndex]
            if castButton then
                castButton:UpdateClickable(true, "ITEM", gemID)
                castButton:SetPoint("LEFT", self, "CENTER", gemsStart + (gemIndex - 1) * 50, 5)
                castButton:Show()
            end
        end
        self:Show()
    end

    resocketPopup:Hide()

    local frameToggle = CreateFrame("Frame", nil, CharacterFrame)
    frameToggle:SetFrameStrata("HIGH")
    frameToggle:SetSize(42, 42)
    frameToggle:SetPoint("BOTTOMRIGHT", CharacterStatsPane, "TOPRIGHT", 5, 0)
    frameToggle:EnableMouse(true)
    local ftBg = frameToggle:CreateTexture()
    ftBg:SetAllPoints()
    ftBg:SetTexture(514608)
    ftBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.7812500)
    local ftTex = frameToggle:CreateTexture()
    ftTex:SetPoint("TOPLEFT", 10, -15)
    ftTex:SetPoint("BOTTOMRIGHT", -7.5, 7.5)
    ftTex:SetAtlas("timerunning-glues-icon")
    frameToggle:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:AddLine(string.format(addon.Loc["Toggle the %s UI"], const.ADDON_NAME), 1, 1, 1)
        GameTooltip:Show()
    end)
    frameToggle:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frameToggle:SetScript("OnMouseDown", function()
        addon:ToggleDatabaseValue("show_frame")
    end)

    ---@class SearchFrame : EditBox
    ---@field Instructions FontString
    local search = CreateFrame("EditBox", nil, gems, "InputBoxInstructionsTemplate")
    search.Instructions:SetText(addon.Loc["Search Gems"])
    search:ClearFocus()
    search:SetAutoFocus(false)
    search:SetPoint("TOPRIGHT", gems.TopTileStreaks, -5, -15)
    search:SetPoint("BOTTOMLEFT", gems.TopTileStreaks, "BOTTOM", 0, 15)

    local dropDown = uiElements:CreateDropdown(gems, {
        points = {
            { "TOPLEFT", gems.TopTileStreaks, -10,    -10 },
            { "RIGHT",   search,              "LEFT", -15, 0 }
        },
        initializer = function(self, info)
            for i = 0, #const.SOCKET_TYPES_INDEX do
                local socketType = gemUtil:GetSocketTypeName(i)
                if socketType ~= "Primordial" or addon:GetDatabaseValue("show_primordial") then
                    info.func = self.SetValue
                    info.arg1 = i
                    info.checked = self.selection == i
                    info.text = socketType
                    UIDropDownMenu_AddButton(info)
                end
            end
        end
    })

    local version = gems:CreateFontString(nil, "ARTWORK", "GameFontDisableSmallLeft")
    version:SetPoint("BOTTOMLEFT", 22, 15)
    version:SetText(string.format("v%s By Rasu", const.ADDON_VERSION))

    ---@class CheckButton
    ---@field Text FontString
    ---@field tooltip string

    local showUnowned = uiElements:CreateCheckButton(gems, {
        point = { "BOTTOMRIGHT", -75, 7.5 },
        text = addon.Loc["Unowned"],
        tooltip = addon.Loc["Show Unowned Gems in the List."],
        onClick = function(self)
            addon:SetDatabaseValue("show_unowned", self:GetChecked())
        end
    })

    local showPrimordial = uiElements:CreateCheckButton(gems, {
        point = { "BOTTOMRIGHT", -175, 7.5 },
        text = addon.Loc["Primordial"],
        tooltip = addon.Loc["Show Primordial Gems in the List."],
        onClick = function(self)
            addon:SetDatabaseValue("show_primordial", self:GetChecked())
        end
    })

    local openBagItems = uiElements:CreateBaseFrame(gems, {
        frameStyle = "Flat",
        height = 150,
        title = addon.Loc["Open, Use and Combine"],
        points = {
            { "TOPLEFT",  gems, "BOTTOMLEFT",  0, -2 },
            { "TOPRIGHT", gems, "BOTTOMRIGHT", 0, -2 },
        }
    })
    local openBagText = openBagItems:CreateFontString()
    openBagText:SetFontObject(const.FONT_OBJECTS.HEADING)
    openBagText:SetText(addon.Loc["NOTHING TO USE"])
    openBagText:SetPoint("CENTER", 0, -10)
    openBagText:Hide()
    local allPointsAnchorPoints = {
        CreateAnchor("TOPLEFT", openBagItems, "TOPLEFT", 25, -35),
        CreateAnchor("BOTTOMRIGHT", openBagItems, "BOTTOMRIGHT", -25, 15)
    }
    local openBagRowCount = math.floor((gems:GetWidth() - 50) / 50)
    local bagItemScrollBox, bagItemScrollView = uiElements:CreateScrollable(openBagItems, {
        element_height = 45,
        type = "GRID",
        initializer = bagItemInitiliazer,
        element_padding = 5,
        elements_per_row = openBagRowCount,
        anchors = {
            with_scroll_bar = allPointsAnchorPoints,
            without_scroll_bar = allPointsAnchorPoints,
        }
    })
    local function updateBagItems()
        if not bagItemScrollBox:IsVisible() then return end
        bagItemScrollView:UpdateContentData({})
        local added = 0
        for itemID, itemType in pairs(const.USABLE_BAG_ITEMS) do
            local count = C_Item.GetItemCount(itemID)
            local threshold = itemType == "GEM" and 3 or 1
            if count >= threshold then
                bagItemScrollView:UpdateContentData({ { itemID = itemID } }, true)
                added = added + 1
            end
        end
        openBagItems:SetHeight(added > openBagRowCount and 150 or added > 0 and 100 or 75)
        openBagText:SetShown(added < 1)
    end
    bagItemScrollBox:RegisterEvent("BAG_UPDATE_DELAYED")
    bagItemScrollBox:SetScript("OnEvent", updateBagItems)
    bagItemScrollBox:SetScript("OnShow", updateBagItems)

    local helpButton = CreateFrame("Button", nil, gems, "MainHelpPlateButton")
    helpButton:SetScript("OnEnter", function(self)
        HelpTip:Show(self, { text = addon.Loc["HelpText"] })
    end)
    helpButton:SetScript("OnLeave", function(self)
        HelpTip:Hide(self)
    end)
    helpButton:SetScript("OnClick", function()
        if IsLeftShiftKeyDown() then
            addon:SetDatabaseValue("show_helpframe", false)
        end
    end)
    helpButton:SetPoint("TOPRIGHT", 25, 25)

    local insetAnchorPoints = {
        CreateAnchor("TOPLEFT", gems.Inset, "TOPLEFT"),
        CreateAnchor("BOTTOMRIGHT", gems.Inset, "BOTTOMRIGHT")
    }
    local scrollBox, scrollView = uiElements:CreateScrollable(gems, {
        anchors = {
            with_scroll_bar = insetAnchorPoints,
            without_scroll_bar = insetAnchorPoints,
        },
        initializer = itemListInitializer,
        element_height = 25,
        template = "BackDropTemplate",
        type = "LIST",
    })

    local function updateTree(data)
        if not scrollBox:IsVisible() then return end
        if not data then return end
        scrollView:UpdateContentData({})
        for socketType, socketTypeData in pairs(data) do
            if #socketTypeData > 0 then
                local typeInfo = gemUtil:GetSocketTypeInfo(socketType)
                if typeInfo then
                    scrollView:UpdateContentData({ {
                        text = typeInfo.name,
                        isHeader = true,
                        icon = typeInfo.icon,
                        index = 0
                    } }, true)
                    sort(socketTypeData, misc.ItemSorting)
                    for itemIndex, itemInfo in ipairs(socketTypeData) do
                        local cachedInfo = cache:GetItemInfo(itemInfo.itemID)
                        if not cachedInfo then return end
                        local txt = cachedInfo.name
                        if itemInfo.gemType == "Prismatic" then
                            txt = gemUtil:GetGemStats(cachedInfo.description)
                        end
                        scrollView:UpdateContentData({ {
                            id = itemInfo.itemID,
                            icon = cachedInfo.icon,
                            text = txt or "",
                            index = itemIndex,
                            info = itemInfo,
                            cachedInfo = cachedInfo,
                        } }, true)
                    end
                end
            end
        end
    end

    local function selectionTreeUpdate()
        updateTree(gemUtil:GetFilteredGems(dropDown.selection, search:GetText() or ""))
    end

    dropDown:SetCallback("selectionCallback", selectionTreeUpdate)

    search:HookScript("OnTextChanged", selectionTreeUpdate)

    gems:SetScript("OnEvent", function(_, event)
        if event == "BAG_UPDATE_DELAYED" then
            selectionTreeUpdate()
        end
    end)

    selectionTreeUpdate()
    addon:CreateDatabaseCallback("show_frame", function (_, value)
        gems:SetShown(value)
    end)
    addon:CreateDatabaseCallback("show_unowned", function (_, value)
        selectionTreeUpdate()
        showUnowned:SetChecked(value)
    end)
    addon:CreateDatabaseCallback("show_primordial", function (_, value)
        selectionTreeUpdate()
        showPrimordial:SetChecked(value)
    end)
    addon:CreateDatabaseCallback("show_helpframe", function (_, value)
        helpButton:SetShown(value)
    end)


    hooksecurefunc("CharacterFrameTab_OnClick", function()
        if CharacterFrame.selectedTab ~= 1 then
            gems:Hide()
            frameToggle:Hide()
        else
            gems:Show()
            frameToggle:Show()
        end
    end)
    gems:SetScript("OnHide", function()
        updateTree({})
    end)
    gems:SetScript("OnShow", function(self)
        selectionTreeUpdate()
        -- Chonky Character Sheets Frame
        if _G["CCSf"] then
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT", CharacterFrameBg, "BOTTOMRIGHT")
            self:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT")
            self.defaultPosition = false
            -- TinyInspect
        elseif C_AddOns.IsAddOnLoaded("TinyInspect") and PaperDollFrame.inspectFrame and PaperDollFrame.inspectFrame:IsVisible() then
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT", PaperDollFrame.inspectFrame, "BOTTOMRIGHT")
            self:SetPoint("TOPLEFT", PaperDollFrame.inspectFrame, "TOPRIGHT")
            self.defaultPosition = false
        elseif not self.defaultPosition then
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT")
            self:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT")
            self.defaultPosition = true
        end
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SCRAPPING_MACHINE_ITEM_ADDED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "SCRAPPING_MACHINE_ITEM_ADDED" then
        RunNextFrame(function()
            local mun = ScrappingMachineFrame
            for f in pairs(mun.ItemSlots.scrapButtons.activeObjects) do
                if f.itemLink then
                    local gemsList = gemUtil:GetItemGems(f.itemLink)
                    if #gemsList > 0 then
                        Private.Frames.ResocketPopup:FillPopup(gemsList)
                    end
                end
            end
        end)
    elseif event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Blizzard_ScrappingMachineUI" then
            createScrapFrame()
        end
    end
    if event ~= "PLAYER_ENTERING_WORLD" then return end
    if 1 ~= PlayerGetTimerunningSeasonID() then return end

    for itemID in pairs(const.GEM_SOCKET_TYPE) do
        cache:CacheItemInfo(itemID)
    end
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    createFrame()
end)
