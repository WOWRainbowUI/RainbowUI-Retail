---@class RemixGemHelperPrivate
local Private = select(2, ...)

local const = Private.constants
local gemUtil = Private.GemUtil
local cache = Private.Cache
local settings = Private.Settings
local uiElements = Private.UIElements
local misc = Private.Misc

local L = {}
L["Meta"] = "變換"
L["Cogwheel"] = "榫輪"
L["Tinker"] = "技工"
L["Prismatic"] = "稜彩"
L["Primordial"] = "原始"
L["All"] = "全部"

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
        frame.Name:SetText(string.format("%s (%s%d/%d|r)", L[name] or name, col:GenerateHexColorMarkup(), used, maxS)) -- 清單文字
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
            state, color = "已裝備", const.COLORS.POSITIVE
        elseif exInf.locType == "BAG_GEM" then
            state, color = "背包中", const.COLORS.NEUTRAL
        elseif exInf.locType == "BAG_SOCKET" then
            state, color = "背包中裝備!", const.COLORS.NEGATIVE
        else
            state, color = "未收集", const.COLORS.GREY
            name = color:WrapTextInColorCode(name)
        end
        frame.Name:SetText(string.format("%s (%s)", name, color:WrapTextInColorCode(state)))
    end

    frame.index = index
    frame.id = data.id
    frame.Stripe:SetShown(data.index % 2 == 1)
end

local function createFrame()
    ---@class GemsFrame : Frame
    ---@field CloseButton Button
    ---@field SetTitle fun(self:GemsFrame, title:string)
    ---@field Inset Frame
    ---@field TopTileStreaks Frame
    local gems = CreateFrame("Frame", nil, CharacterFrame, "ButtonFrameTemplate")
    gems:SetTitle("混搭寶石助手")
    gems:RegisterEvent("BAG_UPDATE_DELAYED")
    gems:SetWidth(300)
    gems:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT")
    gems:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT")

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
        GameTooltip:AddLine(string.format("顯示混搭寶石助手", const.ADDON_NAME), 1, 1, 1)
        GameTooltip:Show()
    end)
    frameToggle:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frameToggle:SetScript("OnMouseDown", function()
        settings:UpdateSetting("show_frame", not settings:GetSetting("show_frame"))
    end)

    ButtonFrameTemplate_HidePortrait(gems)
    gems.CloseButton:Hide()
    gems.Inset:ClearAllPoints()
    gems.Inset:SetPoint("TOP", 0, -65)
    gems.Inset:SetPoint("BOTTOM", 0, 35)
    gems.Inset:SetPoint("LEFT", 20, 0)
    gems.Inset:SetPoint("RIGHT", -20, 0)

    ---@class SearchFrame : EditBox
    ---@field Instructions FontString
    local search = CreateFrame("EditBox", nil, gems, "InputBoxInstructionsTemplate")
    search.Instructions:SetText("搜尋寶石")
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
                if socketType ~= "Primordial" or settings:GetSetting("show_primordial") then
                    info.func = self.SetValue
                    info.arg1 = i
                    info.checked = self.selection == i
                    info.text = L[socketType] or socketType -- 下拉選單文字
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
        text = "未擁有",
        tooltip = "在列表中顯示未擁有的寶石。",
        onClick = function(self)
            settings:UpdateSetting("show_unowned", self:GetChecked())
        end
    })

    local showPrimordial = uiElements:CreateCheckButton(gems, {
        point = { "BOTTOMRIGHT", -175, 7.5 },
        text = "原始的",
        tooltip = "在列表中顯示原始的寶石。",
        onClick = function(self)
            settings:UpdateSetting("show_primordial", self:GetChecked())
        end
    })

    ---@class ScrollBox : Frame
    ---@field GetScrollPercentage fun(self:ScrollBox)
    ---@field SetScrollPercentage fun(self:ScrollBox, percentage:number)
    local scrollBox = CreateFrame("Frame", nil, gems, "WowScrollBoxList")
    scrollBox:SetAllPoints(gems.Inset)

    ---@class MinimalScrollBar : EventFrame
    ---@field SetHideIfUnscrollable fun(self:MinimalScrollBar, state:boolean)
    local scrollBar = CreateFrame("EventFrame", nil, gems, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetHideIfUnscrollable(true)


    local scrollView = CreateScrollBoxListLinearView()
    scrollView:SetElementInitializer("BackDropTemplate", itemListInitializer)
    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    scrollView:SetElementExtent(25)

    function scrollView:UpdateTree(data)
        if not scrollBox:IsVisible() then return end
        if not data then return end
        local scrollPercent = scrollBox:GetScrollPercentage()
        self:Flush()
        local dataProvider = CreateDataProvider()
        self:SetDataProvider(dataProvider)
        for socketType, socketTypeData in pairs(data) do
            if #socketTypeData > 0 then
                local typeInfo = gemUtil:GetSocketTypeInfo(socketType)
                if typeInfo then
                    dataProvider:Insert({
                        text = typeInfo.name,
                        isHeader = true,
                        icon = typeInfo.icon,
                        index = 0
                    })
                    sort(socketTypeData, misc.ItemSorting)
                    for itemIndex, itemInfo in ipairs(socketTypeData) do
                        local cachedInfo = cache:GetItemInfo(itemInfo.itemID)
                        if not cachedInfo then return end
                        local txt = cachedInfo.name
                        if itemInfo.gemType == "Prismatic" then
                            txt = gemUtil:GetGemStats(cachedInfo.description)
                        end
                        dataProvider:Insert({
                            id = itemInfo.itemID,
                            icon = cachedInfo.icon,
                            text = txt or "",
                            index = itemIndex,
                            info = itemInfo,
                            cachedInfo = cachedInfo,
                        })
                    end
                end
            end
        end
        scrollBox:SetScrollPercentage(scrollPercent or 1)
    end

    local function selectionTreeUpdate()
        scrollView:UpdateTree(gemUtil:GetFilteredGems(dropDown.selection, search:GetText() or ""))
    end

    dropDown:SetCallback("selectionCallback", selectionTreeUpdate)

    search:HookScript("OnTextChanged", selectionTreeUpdate)

    gems:SetScript("OnEvent", function(_, event)
        if event == "BAG_UPDATE_DELAYED" then
            selectionTreeUpdate()
        end
    end)

    selectionTreeUpdate()
    settings:CreateSettingCallback("show_frame", function(_, newState)
        if newState then
            gems:Show()
        else
            gems:Hide()
        end
    end)
    settings:CreateSettingCallback("show_unowned", function(_, newState)
        selectionTreeUpdate()
        showUnowned:SetChecked(newState)
    end)
    settings:CreateSettingCallback("show_primordial", function(_, newState)
        selectionTreeUpdate()
        showPrimordial:SetChecked(newState)
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
        scrollView:UpdateTree({})
    end)
    gems:SetScript("OnShow", function(self)
        selectionTreeUpdate()
        if _G["CCSf"] then -- Chonky Character Sheets Frame
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT", CharacterFrameBg, "BOTTOMRIGHT")
            self:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT")
            self:SetWidth(1000)
        end
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
---@diagnostic disable-next-line: param-type-mismatch
eventFrame:RegisterEvent("SCRAPPING_MACHINE_ITEM_ADDED")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "SCRAPPING_MACHINE_ITEM_ADDED" then
        RunNextFrame(function()
            local mun = ScrappingMachineFrame
            for f in pairs(mun.ItemSlots.scrapButtons.activeObjects) do
                if f.itemLink then
                    local gemsList = gemUtil:GetItemGems(f.itemLink)
                    if #gemsList > 0 then
                        misc:PrintError("你正要摧毀已插上寶石的物品!!!")
                    end
                end
            end
        end)
    end
    if event ~= "PLAYER_ENTERING_WORLD" then return end

    for itemID in pairs(const.GEM_SOCKET_TYPE) do
        cache:CacheItemInfo(itemID)
    end
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    createFrame()
end)
