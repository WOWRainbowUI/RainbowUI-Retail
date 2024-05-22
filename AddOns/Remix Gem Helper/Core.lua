---@class RemixGemHelperPrivate
local Private = select(2, ...)

local const = Private.constants
local gemUtil = Private.GemUtil
local cache = Private.Cache
local settings = Private.Settings
local uiElements = Private.UIElements
local misc = Private.Misc
local timeFormatter = CreateFromMixins(SecondsFormatterMixin);
timeFormatter:Init(1, 3, true, true);

Private.TimeFormatter = timeFormatter
Private.Frames = {}

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
            state, color = "已鑲嵌", const.COLORS.POSITIVE
        elseif exInf.locType == "BAG_GEM" then
            state, color = "背包", const.COLORS.NEUTRAL
        elseif exInf.locType == "BAG_SOCKET" then
            state, color = "背包物品", const.COLORS.NEGATIVE
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
    local gems = uiElements:CreateBaseFrame(CharacterFrame, {
        title = "混搭寶石助手",
        width = 300
    })
    gems:RegisterEvent("BAG_UPDATE_DELAYED")

    ---@class ResocketPopup:BaseFrame
    local resocketPopup = uiElements:CreateBaseFrame(UIParent, {
        title = "Resocket Gems",
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
                castButton:SetPoint("LEFT", self, "CENTER", gemsStart + (gemIndex - 1 ) * 50, 5)
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
        GameTooltip:AddLine(string.format("顯示混搭寶石助手", const.ADDON_NAME), 1, 1, 1)
        GameTooltip:Show()
    end)
    frameToggle:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    frameToggle:SetScript("OnMouseDown", function()
        settings:UpdateSetting("show_frame", not settings:GetSetting("show_frame"))
    end)

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

    local openLootbox = uiElements:CreateIcon(gems, {
        points = {
            { "TOPLEFT", gems, "BOTTOMLEFT", 5, -5 }
        },
        isClickable = true,
        actionType = "ITEM",
        actionID = 211279
    })

    local openRandomGemP = uiElements:CreateIcon(gems, {
        points = {
            { "LEFT", openLootbox, "RIGHT", 5, 0 }
        },
        isClickable = true,
        actionType = "ITEM",
        actionID = 223907
    })

    local openRandomGemT = uiElements:CreateIcon(gems, {
        points = {
            { "LEFT", openRandomGemP, "RIGHT", 5, 0 }
        },
        isClickable = true,
        actionType = "ITEM",
        actionID = 223906
    })

    local openRandomGemC = uiElements:CreateIcon(gems, {
        points = {
            { "LEFT", openRandomGemT, "RIGHT", 5, 0 }
        },
        isClickable = true,
        actionType = "ITEM",
        actionID = 223904
    })

    local openRandomGemM = uiElements:CreateIcon(gems, {
        points = {
            { "LEFT", openRandomGemC, "RIGHT", 5, 0 }
        },
        isClickable = true,
        actionType = "ITEM",
        actionID = 223905
    })

    local helpText =
        "|A:newplayertutorial-icon-mouse-leftbutton:16:16|a 點擊列表中的寶石來鑲嵌或拆卸。\n" ..
        "'背包物品' 或 '已鑲嵌' 表示你要拆卸它。\n" ..
        "'背包' 表示寶石在你的背包中，可以鑲嵌。\n\n" ..
        "當你將滑鼠懸停在 '已鑲嵌' 的寶石上時，你將在角色面板中看到該物品被顯示標示。\n" ..
        "你可以使用頂部的下拉選單或搜尋欄來過濾列表。\n" ..
        "此插件還添加了你的披風的當前等級和屬性到披風的浮動提示資訊中。\n" ..
        "你應該在角色視窗的右上角看到一個圖標，可以用來隱藏或顯示此框架。\n" ..
        "在寶石列表下方，你應該有一些可點擊的按鈕，可以快速打開寶箱或組合寶石。\n\n" ..
        "要消除這個框架，只需按住 Shift 鍵並點擊它。\n祝你玩得開心！"

    local helpButton = CreateFrame("Button", nil, gems, "MainHelpPlateButton")
    helpButton:SetScript("OnEnter", function(self)
        HelpTip:Show(self, { text = helpText })
    end)
    helpButton:SetScript("OnLeave", function(self)
        HelpTip:Hide(self)
    end)
    helpButton:SetScript("OnClick", function(self)
        if IsLeftShiftKeyDown() then
            settings:UpdateSetting("show_helpframe", false)
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
    settings:CreateSettingCallback("show_frame", function(_, newState)
        gems:SetShown(newState)
    end)
    settings:CreateSettingCallback("show_unowned", function(_, newState)
        selectionTreeUpdate()
        showUnowned:SetChecked(newState)
    end)
    settings:CreateSettingCallback("show_primordial", function(_, newState)
        selectionTreeUpdate()
        showPrimordial:SetChecked(newState)
    end)
    settings:CreateSettingCallback("show_helpframe", function(_, newState)
        helpButton:SetShown(newState)
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
        elseif (C_AddOns.IsAddOnLoaded("TinyInspect") or C_AddOns.IsAddOnLoaded("TinyInspect-Reforged")) and PaperDollFrame.inspectFrame and PaperDollFrame.inspectFrame:IsVisible() then
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
eventFrame:SetScript("OnEvent", function(_, event)
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
    end
    if event ~= "PLAYER_ENTERING_WORLD" then return end

    for itemID in pairs(const.GEM_SOCKET_TYPE) do
        cache:CacheItemInfo(itemID)
    end
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    createFrame()
end)
